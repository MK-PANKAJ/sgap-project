"""
Bhashini — Government of India's AI Platform (FREE for all Indian languages)

API Flow:
  Step 1: Call /getModelsPipeline to discover which AI model to use
  Step 2: Call that model's endpoint with your audio/text

Supports: ASR (speech-to-text), NMT (translation), TTS (text-to-speech)
Docs: https://bhashini.gov.in/ulca
"""

import httpx
import base64
import logging
from app.config import settings

logger = logging.getLogger(__name__)


class BhashiniService:
    """Client for the Bhashini ULCA inference pipeline."""

    def __init__(self):
        self.pipeline_url = settings.BHASHINI_PIPELINE_URL
        self.user_id = settings.BHASHINI_USER_ID
        self.api_key = settings.BHASHINI_API_KEY

    def is_configured(self) -> bool:
        """Return True if Bhashini credentials are set."""
        return bool(self.user_id and self.api_key)

    # ── Step 1: Pipeline discovery ───────────────────────────────────

    async def _get_pipeline_config(
        self,
        task_type: str,
        source_lang: str,
        target_lang: str = None,
    ) -> dict:
        """
        Discover which AI model to use for a task.

        Returns dict with:
          - callback_url: the inference endpoint
          - authorization_key: bearer token for the endpoint
          - service_id: model identifier
        """
        if not self.is_configured():
            return None

        task_config = {
            "taskType": task_type,
            "config": {
                "language": {"sourceLanguage": source_lang},
            },
        }
        if target_lang and task_type == "translation":
            task_config["config"]["language"]["targetLanguage"] = target_lang

        payload = {
            "pipelineTasks": [task_config],
            "pipelineRequestConfig": {
                "pipelineId": "64392f96daac500b55c543cd",
            },
        }
        headers = {
            "Content-Type": "application/json",
            "userID": self.user_id,
            "ulcaApiKey": self.api_key,
        }

        try:
            async with httpx.AsyncClient() as client:
                response = await client.post(
                    self.pipeline_url,
                    json=payload,
                    headers=headers,
                    timeout=30.0,
                )
                if response.status_code == 200:
                    data = response.json()
                    inference_api = data.get("pipelineInferenceAPIEndPoint", {})
                    pipeline_response = data.get("pipelineResponseConfig", [{}])
                    config_list = (
                        pipeline_response[0].get("config", [{}])
                        if pipeline_response
                        else [{}]
                    )
                    service_id = (
                        config_list[0].get("serviceId", "") if config_list else ""
                    )
                    return {
                        "callback_url": inference_api.get("callbackUrl", ""),
                        "authorization_key": inference_api.get(
                            "inferenceApiKey", {}
                        ).get("value", ""),
                        "service_id": service_id,
                    }
                else:
                    logger.warning(
                        "Bhashini pipeline returned %s: %s",
                        response.status_code,
                        response.text[:200],
                    )
        except Exception as e:
            logger.error(f"Bhashini pipeline config error: {str(e)}")

        return None

    # ── Step 2a: Automatic Speech Recognition (ASR) ──────────────────

    async def speech_to_text(
        self,
        audio_base64: str,
        source_language: str = "hi",
    ) -> dict:
        """
        Convert speech audio to text using Bhashini ASR.

        Args:
            audio_base64: base64-encoded WAV audio
            source_language: BCP-47 code (hi, en, ta, bn, …)

        Returns:
            dict with keys: text, model_used, language, [error]
        """
        config = await self._get_pipeline_config("asr", source_language)
        if not config or not config.get("callback_url"):
            return {
                "text": "",
                "error": "Bhashini unavailable. Use on-device STT.",
                "model_used": "fallback",
            }

        payload = {
            "pipelineTasks": [
                {
                    "taskType": "asr",
                    "config": {
                        "language": {"sourceLanguage": source_language},
                        "serviceId": config["service_id"],
                        "audioFormat": "wav",
                        "samplingRate": 16000,
                    },
                }
            ],
            "inputData": {"audio": [{"audioContent": audio_base64}]},
        }
        headers = {
            "Content-Type": "application/json",
            "Authorization": config["authorization_key"],
        }

        try:
            async with httpx.AsyncClient() as client:
                response = await client.post(
                    config["callback_url"],
                    json=payload,
                    headers=headers,
                    timeout=60.0,
                )
                if response.status_code == 200:
                    data = response.json()
                    pipeline_out = data.get("pipelineResponse", [{}])
                    output = (
                        pipeline_out[0].get("output", [{}])
                        if pipeline_out
                        else [{}]
                    )
                    text = output[0].get("source", "") if output else ""
                    return {
                        "text": text,
                        "model_used": config["service_id"],
                        "language": source_language,
                    }
                else:
                    logger.warning(
                        "Bhashini ASR returned %s: %s",
                        response.status_code,
                        response.text[:200],
                    )
        except Exception as e:
            logger.error(f"Bhashini ASR error: {str(e)}")

        return {"text": "", "error": "ASR failed", "model_used": ""}

    # ── Step 2b: Neural Machine Translation (NMT) ───────────────────

    async def translate_text(
        self,
        text: str,
        source_lang: str,
        target_lang: str,
    ) -> str:
        """
        Translate text between Indian languages using Bhashini NMT.

        Falls back to returning the original text on any failure.
        """
        config = await self._get_pipeline_config(
            "translation", source_lang, target_lang
        )
        if not config or not config.get("callback_url"):
            return text

        payload = {
            "pipelineTasks": [
                {
                    "taskType": "translation",
                    "config": {
                        "language": {
                            "sourceLanguage": source_lang,
                            "targetLanguage": target_lang,
                        },
                        "serviceId": config["service_id"],
                    },
                }
            ],
            "inputData": {"input": [{"source": text}]},
        }
        headers = {
            "Content-Type": "application/json",
            "Authorization": config["authorization_key"],
        }

        try:
            async with httpx.AsyncClient() as client:
                response = await client.post(
                    config["callback_url"],
                    json=payload,
                    headers=headers,
                    timeout=30.0,
                )
                if response.status_code == 200:
                    data = response.json()
                    pipeline_out = data.get("pipelineResponse", [{}])
                    output = (
                        pipeline_out[0].get("output", [{}])
                        if pipeline_out
                        else [{}]
                    )
                    return output[0].get("target", text) if output else text
        except Exception as e:
            logger.error(f"Bhashini translation error: {str(e)}")

        return text

    # ── Step 2c: Text-to-Speech (TTS) ────────────────────────────────

    async def text_to_speech(
        self,
        text: str,
        language: str = "hi",
        gender: str = "female",
    ) -> str:
        """
        Convert text to speech.

        Returns base64-encoded audio string, or None on failure.
        """
        config = await self._get_pipeline_config("tts", language)
        if not config or not config.get("callback_url"):
            return None

        payload = {
            "pipelineTasks": [
                {
                    "taskType": "tts",
                    "config": {
                        "language": {"sourceLanguage": language},
                        "serviceId": config["service_id"],
                        "gender": gender,
                    },
                }
            ],
            "inputData": {"input": [{"source": text}]},
        }
        headers = {
            "Content-Type": "application/json",
            "Authorization": config["authorization_key"],
        }

        try:
            async with httpx.AsyncClient() as client:
                response = await client.post(
                    config["callback_url"],
                    json=payload,
                    headers=headers,
                    timeout=30.0,
                )
                if response.status_code == 200:
                    data = response.json()
                    pipeline_out = data.get("pipelineResponse", [{}])
                    audio = (
                        pipeline_out[0].get("audio", [{}])
                        if pipeline_out
                        else [{}]
                    )
                    return audio[0].get("audioContent", None) if audio else None
        except Exception as e:
            logger.error(f"Bhashini TTS error: {str(e)}")

        return None


# Module-level singleton
bhashini = BhashiniService()
