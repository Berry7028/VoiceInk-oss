# Realtime

GET /v1/speech-to-text/realtime

Realtime speech-to-text transcription service. This WebSocket API enables streaming audio input and receiving transcription results.

## Event Flow
- Audio chunks are sent as `input_audio_chunk` messages
- Transcription results are streamed back in various formats (partial, committed, with timestamps)
- Supports manual commit or VAD-based automatic commit strategies

Authentication is done either by providing a valid API key in the `xi-api-key` header or by providing a valid token in the `token` query parameter. Tokens can be generated from the [single use token endpoint](/docs/api-reference/single-use/create). Use tokens if you want to transcribe audio from the client side.


Reference: https://elevenlabs.io/docs/api-reference/speech-to-text/v-1-speech-to-text-realtime

## AsyncAPI Specification

```yaml
asyncapi: 2.6.0
info:
  title: V 1 Speech To Text Realtime
  version: subpackage_v1SpeechToTextRealtime.v1SpeechToTextRealtime
  description: >
    Realtime speech-to-text transcription service. This WebSocket API enables
    streaming audio input and receiving transcription results.


    ## Event Flow

    - Audio chunks are sent as `input_audio_chunk` messages

    - Transcription results are streamed back in various formats (partial,
    committed, with timestamps)

    - Supports manual commit or VAD-based automatic commit strategies


    Authentication is done either by providing a valid API key in the
    `xi-api-key` header or by providing a valid token in the `token` query
    parameter. Tokens can be generated from the [single use token
    endpoint](/docs/api-reference/single-use/create). Use tokens if you want to
    transcribe audio from the client side.
channels:
  /v1/speech-to-text/realtime:
    description: >
      Realtime speech-to-text transcription service. This WebSocket API enables
      streaming audio input and receiving transcription results.


      ## Event Flow

      - Audio chunks are sent as `input_audio_chunk` messages

      - Transcription results are streamed back in various formats (partial,
      committed, with timestamps)

      - Supports manual commit or VAD-based automatic commit strategies


      Authentication is done either by providing a valid API key in the
      `xi-api-key` header or by providing a valid token in the `token` query
      parameter. Tokens can be generated from the [single use token
      endpoint](/docs/api-reference/single-use/create). Use tokens if you want
      to transcribe audio from the client side.
    bindings:
      ws:
        query:
          type: object
          properties:
            model_id:
              type: string
            token:
              type: string
            include_timestamps:
              type: boolean
            audio_format:
              $ref: '#/components/schemas/audio_format'
            language_code:
              type: string
            commit_strategy:
              $ref: '#/components/schemas/commit_strategy'
            vad_silence_threshold_secs:
              type: number
              format: double
            vad_threshold:
              type: number
              format: double
            min_speech_duration_ms:
              type: integer
            min_silence_duration_ms:
              type: integer
            enable_logging:
              type: boolean
        headers:
          type: object
          properties:
            xi-api-key:
              type: string
    publish:
      operationId: v-1-speech-to-text-realtime-publish
      summary: subscribe
      description: Receive transcription results from the WebSocket
      message:
        name: subscribe
        title: subscribe
        description: Receive transcription results from the WebSocket
        payload:
          $ref: '#/components/schemas/V1SpeechToTextRealtimeSubscribe'
    subscribe:
      operationId: v-1-speech-to-text-realtime-subscribe
      summary: publish
      description: Send audio data to the WebSocket
      message:
        name: publish
        title: publish
        description: Send audio data to the WebSocket
        payload:
          $ref: '#/components/schemas/V1SpeechToTextRealtimePublish'
servers:
  Production:
    url: wss://api.elevenlabs.io/
    protocol: wss
    x-default: true
  Production US:
    url: wss://api.us.elevenlabs.io/
    protocol: wss
  Production EU:
    url: wss://api.eu.residency.elevenlabs.io/
    protocol: wss
  Production India:
    url: wss://api.in.residency.elevenlabs.io/
    protocol: wss
components:
  schemas:
    audio_format:
      type: string
      enum:
        - value: pcm_8000
        - value: pcm_16000
        - value: pcm_22050
        - value: pcm_24000
        - value: pcm_44100
        - value: pcm_48000
        - value: ulaw_8000
    commit_strategy:
      type: string
      enum:
        - value: manual
        - value: vad
    AudioFormatEnum:
      type: string
      enum:
        - value: pcm_8000
        - value: pcm_16000
        - value: pcm_22050
        - value: pcm_24000
        - value: pcm_44100
        - value: pcm_48000
        - value: ulaw_8000
    MessagesSessionStartedConfigCommitStrategy:
      type: string
      enum:
        - value: manual
        - value: vad
    MessagesSessionStartedConfig:
      type: object
      properties:
        sample_rate:
          type: integer
        audio_format:
          $ref: '#/components/schemas/AudioFormatEnum'
        language_code:
          type: string
        commit_strategy:
          $ref: '#/components/schemas/MessagesSessionStartedConfigCommitStrategy'
        vad_silence_threshold_secs:
          type: number
          format: double
        vad_threshold:
          type: number
          format: double
        min_speech_duration_ms:
          type: integer
        min_silence_duration_ms:
          type: integer
        model_id:
          type: string
        enable_logging:
          type: boolean
    SessionStarted:
      type: object
      properties:
        message_type:
          type: string
          enum:
            - type: stringLiteral
              value: session_started
        session_id:
          type: string
        config:
          $ref: '#/components/schemas/MessagesSessionStartedConfig'
      required:
        - message_type
        - session_id
        - config
    PartialTranscript:
      type: object
      properties:
        message_type:
          type: string
          enum:
            - type: stringLiteral
              value: partial_transcript
        text:
          type: string
      required:
        - message_type
        - text
    CommittedTranscript:
      type: object
      properties:
        message_type:
          type: string
          enum:
            - type: stringLiteral
              value: committed_transcript
        text:
          type: string
      required:
        - message_type
        - text
    TranscriptionWordType:
      type: string
      enum:
        - value: word
        - value: spacing
    TranscriptionWord:
      type: object
      properties:
        text:
          type: string
        start:
          type: number
          format: double
        end:
          type: number
          format: double
        type:
          $ref: '#/components/schemas/TranscriptionWordType'
        speaker_id:
          type: string
        logprob:
          type: number
          format: double
        characters:
          type: array
          items:
            type: string
    CommittedTranscriptWithTimestamps:
      type: object
      properties:
        message_type:
          type: string
          enum:
            - type: stringLiteral
              value: committed_transcript_with_timestamps
        text:
          type: string
        language_code:
          type:
            - string
            - 'null'
        words:
          type:
            - array
            - 'null'
          items:
            $ref: '#/components/schemas/TranscriptionWord'
      required:
        - message_type
        - text
    ScribeError:
      type: object
      properties:
        message_type:
          type: string
          enum:
            - type: stringLiteral
              value: error
        error:
          type: string
      required:
        - message_type
        - error
    ScribeAuthError:
      type: object
      properties:
        message_type:
          type: string
          enum:
            - type: stringLiteral
              value: auth_error
        error:
          type: string
      required:
        - message_type
        - error
    ScribeQuotaExceededError:
      type: object
      properties:
        message_type:
          type: string
          enum:
            - type: stringLiteral
              value: quota_exceeded_error
        error:
          type: string
      required:
        - message_type
        - error
    V1SpeechToTextRealtimeSubscribe:
      oneOf:
        - $ref: '#/components/schemas/SessionStarted'
        - $ref: '#/components/schemas/PartialTranscript'
        - $ref: '#/components/schemas/CommittedTranscript'
        - $ref: '#/components/schemas/CommittedTranscriptWithTimestamps'
        - $ref: '#/components/schemas/ScribeError'
        - $ref: '#/components/schemas/ScribeAuthError'
        - $ref: '#/components/schemas/ScribeQuotaExceededError'
    InputAudioChunk:
      type: object
      properties:
        message_type:
          type: string
          enum:
            - type: stringLiteral
              value: input_audio_chunk
        audio_base_64:
          type: string
          format: base64
        commit:
          type: boolean
        sample_rate:
          type: integer
      required:
        - message_type
        - audio_base_64
        - commit
        - sample_rate
    V1SpeechToTextRealtimePublish:
      oneOf:
        - $ref: '#/components/schemas/InputAudioChunk'

```

---
title: Realtime Speech to Text
subtitle: Learn how to transcribe audio with ElevenLabs in realtime with WebSockets
---

## Overview

The ElevenLabs Realtime Speech to Text API enables you to transcribe audio streams in real-time with ultra-low latency using the ScribeRealtime v2 model. Whether you're building voice assistants, transcription services, or any application requiring live speech recognition, this WebSocket-based API delivers partial transcripts as you speak and committed transcripts when speech segments are complete.

## Key features

- **Ultra-low latency**: Get partial transcriptions in milliseconds
- **Streaming support**: Send audio in chunks while receiving transcripts in real-time
- **Multiple audio formats**: Support for PCM (8kHz to 48kHz) and μ-law encoding
- **Voice Activity Detection (VAD)**: Automatic speech segmentation based on silence detection
- **Manual commit control**: Full control over when to commit transcript segments

## Quickstart

ElevenLabs Scribe v2 Realtime can be implemented on either the client or the server side. Choose client if you want to transcribe audio in realtime on the client side, for instance via the microphone. If you want to transcribe audio from a URL, choose the server side implementation.

<Tabs>
  <Tab title="Client">
    <Steps>
      <Step title="Create an API key">
          [Create an API key in the dashboard here](https://elevenlabs.io/app/settings/api-keys), which you’ll use to securely [access the API](/docs/api-reference/authentication).
          
          Store the key as a managed secret and pass it to the SDKs either as a environment variable via an `.env` file, or directly in your app’s configuration depending on your preference.
          
          ```js title=".env"
          ELEVENLABS_API_KEY=<your_api_key_here>
          ```
          
      </Step>
      <Step title="Install the SDK">
        <CodeBlocks>
        ```bash title="React"
        npm install @elevenlabs/react
        ```

        ```bash title="JavaScript"
        npm install @elevenlabs/client
        ```
        </CodeBlocks>
      </Step>
      <Step title="Create a token">
        To use the client side SDK, you need to create a single use token. This can be done via the ElevenLabs API on the server side.

        <Warning>
          Never expose your API key to the client.
        </Warning>

        ```typescript
        // Node.js server
        app.get("/scribe-token", yourAuthMiddleware, async (req, res) => {
          const response = await fetch(
            "https://api.elevenlabs.io/v1/single-use-token/realtime_scribe",
            {
              method: "POST",
              headers: {
                "xi-api-key": process.env.ELEVENLABS_API_KEY,
              },
            }
          );

          const data = await response.json();
          res.json({ token: data.token });
        });
        ```

        Once generated, the token automatically expires after 15 minutes.
      </Step>
      <Step title="Configure the SDK">
        The client SDK provides two ways to transcribe audio in realtime, streaming from the microphone or manually chunking the audio.

        <Tabs>
          <Tab title="Streaming from the microphone">
            <CodeBlocks>
            ```typescript title="React"
            import { useScribe } from "@elevenlabs/react";

            function MyComponent() {
              const scribe = useScribe({
                modelId: "scribe_v2_realtime",
                onPartialTranscript: (data) => {
                  console.log("Partial:", data.text);
                },
                onCommittedTranscript: (data) => {
                  console.log("Committed:", data.text);
                },
                onCommittedTranscriptWithTimestamps: (data) => {
                  console.log("Committed with timestamps:", data.text);
                  console.log("Timestamps:", data.words);
                },
              });

              const handleStart = async () => {
                // Fetch a single use token from the server
                const token = await fetchTokenFromServer();

                await scribe.connect({
                  token,
                  microphone: {
                    echoCancellation: true,
                    noiseSuppression: true,
                  },
                });
              };

              return (
                <div>
                  <button onClick={handleStart} disabled={scribe.isConnected}>
                    Start Recording
                  </button>
                  <button onClick={scribe.disconnect} disabled={!scribe.isConnected}>
                    Stop
                  </button>

                  {scribe.partialTranscript && <p>Live: {scribe.partialTranscript}</p>}

                  <div>
                    {scribe.committedTranscripts.map((t) => (
                      <p key={t.id}>{t.text}</p>
                    ))}
                  </div>
                </div>
              );
            }
            ```

            ```typescript title="JavaScript"
            // Client side
            import { Scribe, RealtimeEvents } from "@elevenlabs/client";

            // Ensure you have authentication headers set up
            const response = await fetch("/scribe-token", yourAuthHeaders);
            const { token } = await response.json();

            const connection = Scribe.connect({
              token,
              modelId: "scribe_v2_realtime",
              includeTimestamps: true,
              microphone: {
                echoCancellation: true,
                noiseSuppression: true,
                autoGainControl: true,
              },
            });

            // Set up event handlers

            // Session started
            connection.on(RealtimeEvents.SESSION_STARTED, () => {
              console.log("Session started");
            });

            // Partial transcripts (interim results), use this in your UI to show the live transcript
            connection.on(RealtimeEvents.PARTIAL_TRANSCRIPT, (data) => {
              console.log("Partial:", data.text);
            });

            // Committed transcripts
            connection.on(RealtimeEvents.COMMITTED_TRANSCRIPT, (data) => {
              console.log("Committed:", data.text);
            });

            // Committed transcripts with word-level timestamps. Only received when includeTimestamps is set to true.
            connection.on(RealtimeEvents.COMMITTED_TRANSCRIPT_WITH_TIMESTAMPS, (data) => {
              console.log("Committed:", data.text);
              console.log("Timestamps:", data.words);
            });

            // Errors
            connection.on(RealtimeEvents.ERROR, (error) => {
              console.error("Error:", error);
            });

            // Authentication errors
            connection.on(RealtimeEvents.AUTH_ERROR, (data) => {
              console.error("Auth error:", data.error);
            });

            // Connection opened
            connection.on(RealtimeEvents.OPEN, () => {
              console.log("Connection opened");
            });

            // Connection closed
            connection.on(RealtimeEvents.CLOSE, () => {
              console.log("Connection closed");
            });

            // When you are done, close the connection
            connection.close();
            ```
            </CodeBlocks>
          </Tab>
          <Tab title="Manual audio chunking">
            <CodeBlocks>
            ```typescript title="React"
            import { useScribe, AudioFormat } from "@elevenlabs/react";

            function FileTranscription() {
              const [file, setFile] = useState<File | null>(null);
              const scribe = useScribe({
                modelId: "scribe_v2_realtime",
                audioFormat: AudioFormat.PCM_16000,
                sampleRate: 16000,
              });

              const transcribeFile = async () => {
                if (!file) return;

                // Fetch a single use token from the server
                const token = await fetchToken();
                await scribe.connect({ token });

                // Decode audio file
                const arrayBuffer = await file.arrayBuffer();
                const audioContext = new AudioContext({ sampleRate: 16000 });
                const audioBuffer = await audioContext.decodeAudioData(arrayBuffer);

                // Convert to PCM16
                const channelData = audioBuffer.getChannelData(0);
                const pcmData = new Int16Array(channelData.length);

                for (let i = 0; i < channelData.length; i++) {
                  const sample = Math.max(-1, Math.min(1, channelData[i]));
                  pcmData[i] = sample < 0 ? sample * 32768 : sample * 32767;
                }

                // Send in chunks
                const chunkSize = 4096;
                for (let offset = 0; offset < pcmData.length; offset += chunkSize) {
                  const chunk = pcmData.slice(offset, offset + chunkSize);
                  const bytes = new Uint8Array(chunk.buffer);
                  const base64 = btoa(String.fromCharCode(...bytes));

                  scribe.sendAudio(base64);
                  await new Promise((resolve) => setTimeout(resolve, 50));
                }

                // Commit transcription
                scribe.commit();
              };

              return (
                <div>
                  <input
                    type="file"
                    accept="audio/*"
                    onChange={(e) => setFile(e.target.files?.[0] || null)}
                  />
                  <button onClick={transcribeFile} disabled={!file || scribe.isConnected}>
                    Transcribe
                  </button>

                  {scribe.committedTranscripts.map((transcript) => (
                    <div key={transcript.id}>{transcript.text}</div>
                  ))}
                </div>
              );
            }
            ```

            ```typescript title="JavaScript"
            import { Scribe, AudioFormat, RealtimeEvents, CommitStrategy } from "@elevenlabs/client";

            // Ensure you have authentication headers set up
            const response = await fetch("/scribe-token", yourAuthHeaders);
            const { token } = await response.json();

            const connection = Scribe.connect({
              token,
              modelId: "scribe_v2_realtime",
              includeTimestamps: true,
              audioFormat: AudioFormat.PCM_16000,
              sampleRate: 16000,
              commitStrategy: CommitStrategy.MANUAL,
            });

            // Set up event handlers
            connection.on(RealtimeEvents.SESSION_STARTED, () => {
              console.log("Session started");
              sendAudio();
            });

            connection.on(RealtimeEvents.PARTIAL_TRANSCRIPT, (data) => {
              console.log("Partial:", data.text);
            });

            connection.on(RealtimeEvents.COMMITTED_TRANSCRIPT, (data) => {
              console.log("Committed:", data.text);
            });

            connection.on(RealtimeEvents.ERROR, (error) => {
              console.error("Error:", error);
            });

            // Committed transcripts with word-level timestamps. Only received when includeTimestamps is set to true.
            connection.on(RealtimeEvents.COMMITTED_TRANSCRIPT_WITH_TIMESTAMPS, (data) => {
              console.log("Committed:", data.text);
              console.log("Timestamps:", data.words);

              // Committed transcript received, close the connection
              connection.close();
            });

            async function sendAudio() {
              // Get file from input element
              const fileInput = document.querySelector('input[type="file"]');
              const audioFile = fileInput.files[0];

              // Read file as ArrayBuffer
              const arrayBuffer = await audioFile.arrayBuffer();
              const audioData = new Uint8Array(arrayBuffer);

              // Convert to base64 and send in chunks
              const chunkSize = 8192; // 8KB chunks
              for (let i = 0; i < audioData.length; i += chunkSize) {
                const chunk = audioData.slice(i, i + chunkSize);
                const base64 = btoa(String.fromCharCode(...chunk));

                // Send audio chunk
                connection.send({ audioBase64: base64 });

                // Optional: Add delay to simulate real-time streaming
                await new Promise((resolve) => setTimeout(resolve, 100));
              }

              // Signal end of audio segment
              connection.commit();
            }
            ```
            </CodeBlocks>
          </Tab>
        </Tabs>
      </Step>
    </Steps>

  </Tab>
  <Tab title="Server">
    <Steps>
    <Step title="Create an API key">
        [Create an API key in the dashboard here](https://elevenlabs.io/app/settings/api-keys), which you’ll use to securely [access the API](/docs/api-reference/authentication).
        
        Store the key as a managed secret and pass it to the SDKs either as a environment variable via an `.env` file, or directly in your app’s configuration depending on your preference.
        
        ```js title=".env"
        ELEVENLABS_API_KEY=<your_api_key_here>
        ```
        
    </Step>
    <Step title="Install the SDK">
        We'll also use the `dotenv` library to load our API key from an environment variable.
        
        <CodeBlocks>
            ```python
            pip install elevenlabs
            pip install python-dotenv
            ```
        
            ```typescript
            npm install @elevenlabs/elevenlabs-js
            npm install dotenv
            ```
        
        </CodeBlocks>
        
    </Step>
    <Step title="Configure the SDK">
        The SDK provides two ways to transcribe audio in realtime, streaming from a URL or manually chunking the audio.

        <Tabs>
          <Tab title="Stream from URL">
            This example shows how to stream an audio file from a URL.

            <Warning>
              The `ffmpeg` tool is required when streaming from an URL. Visit [their website](https://ffmpeg.org/download.html) for installation instructions.
            </Warning>

            Create a new file named `example.py` or `example.mts`, depending on your language of choice and add the following code:

            <CodeBlocks>
            ```python
            from dotenv import load_dotenv
            import os
            import asyncio
            from elevenlabs import ElevenLabs, RealtimeEvents, RealtimeUrlOptions

            load_dotenv()

            async def main():
                elevenlabs = ElevenLabs(api_key=os.getenv("ELEVENLABS_API_KEY"))

                # Create an event to signal when to stop
                stop_event = asyncio.Event()

                # Connect to a streaming audio URL
                connection = await elevenlabs.speech_to_text.realtime.connect(RealtimeUrlOptions(
                    model_id="scribe_v2_realtime",
                    url="https://npr-ice.streamguys1.com/live.mp3",
                    include_timestamps=True,
                ))

                # Set up event handlers
                def on_session_started(data):
                    print(f"Session started: {data}")

                def on_partial_transcript(data):
                    print(f"Partial: {data.get('text', '')}")

                def on_committed_transcript(data):
                    print(f"Committed: {data.get('text', '')}")

                # Committed transcripts with word-level timestamps. Only received when include_timestamps is set to True.
                def on_committed_transcript_with_timestamps(data):
                    print(f"Committed with timestamps: {data.get('words', '')}")

                def on_error(error):
                    print(f"Error: {error}")
                    # Signal to stop on error
                    stop_event.set()

                def on_close():
                    print("Connection closed")

                # Register event handlers
                connection.on(RealtimeEvents.SESSION_STARTED, on_session_started)
                connection.on(RealtimeEvents.PARTIAL_TRANSCRIPT, on_partial_transcript)
                connection.on(RealtimeEvents.COMMITTED_TRANSCRIPT, on_committed_transcript)
                connection.on(RealtimeEvents.COMMITTED_TRANSCRIPT_WITH_TIMESTAMPS, on_committed_transcript_with_timestamps)
                connection.on(RealtimeEvents.ERROR, on_error)
                connection.on(RealtimeEvents.CLOSE, on_close)

                print("Transcribing audio stream... (Press Ctrl+C to stop)")

                try:
                    # Wait until error occurs or connection closes
                    await stop_event.wait()
                except KeyboardInterrupt:
                    print("\nStopping transcription...")
                finally:
                    await connection.close()

            if __name__ == "__main__":
                asyncio.run(main())
            ```

            ```typescript
            import "dotenv/config";
            import { ElevenLabsClient, RealtimeEvents } from "@elevenlabs/elevenlabs-js";

            const elevenlabs = new ElevenLabsClient();

            const connection = await elevenlabs.speechToText.realtime.connect({
              modelId: "scribe_v2_realtime",
              url: "https://npr-ice.streamguys1.com/live.mp3",
              includeTimestamps: true,
            });

            connection.on(RealtimeEvents.SESSION_STARTED, (data) => {
              console.log("Session started", data);
            });

            connection.on(RealtimeEvents.PARTIAL_TRANSCRIPT, (transcript) => {
              console.log("Partial transcript", transcript);
            });

            connection.on(RealtimeEvents.COMMITTED_TRANSCRIPT, (transcript) => {
              console.log("Committed transcript", transcript);
            });

            connection.on(RealtimeEvents.COMMITTED_TRANSCRIPT_WITH_TIMESTAMPS, (transcript) => {
              console.log("Committed with timestamps", transcript);
            });

            connection.on(RealtimeEvents.ERROR, (error) => {
              console.log("Error", error);
            });

            connection.on(RealtimeEvents.CLOSE, () => {
              console.log("Connection closed");
            });

            ```

            ```python title="Python WebSocket example"
            # Use this example if you are unable to use the SDK
            import asyncio
            import base64
            import json
            import websockets
            from dotenv import load_dotenv
            import os

            load_dotenv()

            async def send_audio(ws, audio_data):
                """Send audio chunks to the websocket"""
                chunk_size = 32000  # 1 second of 16kHz audio

                for i in range(0, len(audio_data), chunk_size):
                    chunk = audio_data[i : i + chunk_size]
                    await ws.send(
                        json.dumps(
                            {
                                "message_type": "input_audio_chunk",
                                "audio_base_64": base64.b64encode(chunk).decode(),
                                "commit": False,
                                "sample_rate": 16000,
                            }
                        )
                    )
                    # Wait 1 second between chunks to simulate real-time streaming
                    await asyncio.sleep(1)

                # Small delay before final commit
                await asyncio.sleep(0.5)

                # Send final commit
                await ws.send(
                    json.dumps(
                        {
                            "message_type": "input_audio_chunk",
                            "audio_base_64": "",
                            "commit": True,
                            "sample_rate": 16000,
                        }
                    )
                )

            async def receive_transcripts(ws):
                """Receive and process transcripts from the websocket"""
                while True:
                    try:
                        # Wait for 10 seconds for a message
                        # Adjust the timeout in cases where audio files have more than 10 seconds before speech starts, or if the audio is longer than 10 seconds.
                        message = await asyncio.wait_for(ws.recv(), timeout=10.0)
                        data = json.loads(message)

                        if data["message_type"] == "partial_transcript":
                            print(f"Partial: {data['text']}")
                        elif data["message_type"] == "committed_transcript":
                            print(f"Committed: {data['text']}")
                        elif data["message_type"] == "committed_transcript_with_timestamps":
                            print(f"Committed with timestamps: {data['words']}")
                            break
                        elif data["message_type"] == "input_error":
                            print(f"Error: {data}")
                    except asyncio.TimeoutError:
                        print("Timeout waiting for transcript")


            async def transcribe():
                url = "wss://api.elevenlabs.io/v1/speech-to-text/realtime?model_id=scribe_v2_realtime"
                headers = {"xi-api-key": os.getenv("ELEVENLABS_API_KEY")}

                async with websockets.connect(url, additional_headers=headers) as ws:
                    # Connection established, wait for session_started
                    session_msg = await ws.recv()
                    print(f"Session started: {session_msg}")

                    # Read audio file (16 kHz, mono, 16-bit PCM, little-endian)
                    with open("/path/to/audio.pcm", "rb") as f:
                        audio_data = f.read()

                    # Run sending and receiving concurrently
                    await asyncio.gather(
                        send_audio(ws, audio_data),
                        receive_transcripts(ws)
                    )


            asyncio.run(transcribe())
            ```

            ```typescript title="TypeScript WebSocket example"
            // Use this example if you are unable to use the SDK
            import "dotenv/config";
            import * as fs from "node:fs";
            // Make sure to install the "ws" library beforehand
            import WebSocket from "ws";

            const uri = "wss://api.elevenlabs.io/v1/speech-to-text/realtime?model_id=scribe_v2_realtime";
            const websocket = new WebSocket(uri, {
              headers: {
                "xi-api-key": process.env.ELEVENLABS_API_KEY,
              },
            });

            websocket.on("open", async () => {
              console.log("WebSocket opened");
            });

            // Listen to the incoming message from the websocket connection
            websocket.on("message", function incoming(event) {
              const data = JSON.parse(event.toString());

              switch (data.message_type) {
                case "session_started":
                  console.log("Session started", data);
                  sendAudio();
                  break;
                case "partial_transcript":
                  console.log("Partial:", data);
                  break;
                case "committed_transcript":
                  console.log("Committed:", data);
                  break;
                // Committed transcripts with word-level timestamps. Only received when "include_timestamps=true" is included in the query parameters
                case "committed_transcript_with_timestamps":
                  console.log("Committed with timestamps:", data);
                  websocket.close();
                  break;
                default:
                  console.log(data);
                  break;
              }

            });

            async function sendAudio() {
              // 16 kHz, mono, 16-bit PCM, little-endian
              const pcmFilePath = "/path/to/audio.pcm";

              const chunkSize = 32000; // 1 second of 16kHz audio (16000 samples * 2 bytes per sample)

              // Read the entire file into a buffer
              const audioBuffer = fs.readFileSync(pcmFilePath);

              // Split the buffer into chunks of exactly chunkSize bytes
              const chunks: Buffer[] = [];
              for (let i = 0; i < audioBuffer.length; i += chunkSize) {
                const chunk = audioBuffer.subarray(i, i + chunkSize);
                chunks.push(chunk);
              }

              // Send each chunk via websocket payload
              for (let i = 0; i < chunks.length; i++) {
                const chunk = chunks[i];
                const chunkBase64 = chunk.toString("base64");

                websocket.send(JSON.stringify({
                  message_type: "input_audio_chunk",
                  audio_base_64: chunkBase64,
                  commit: false,
                  sample_rate: 16000,
                }));

                // Wait 1 second between chunks to simulate real-time streaming
                // (each chunk contains 1 second of audio at 16kHz)
                if (i < chunks.length - 1) {
                  await new Promise(resolve => setTimeout(resolve, 1000));
                }
              }

              // Small delay before final commit to let the last chunk process
              await new Promise(resolve => setTimeout(resolve, 500));

              // send final commit
              websocket.send(JSON.stringify({
                message_type: "input_audio_chunk",
                audio_base_64: "",
                commit: true,
                sample_rate: 16000,
              }));
            }
            ```
            </CodeBlocks>
          </Tab>
          <Tab title="Manual audio chunking">
            This example simulates a realtime transcription of an audio file.

            <CodeBlocks>
            ```python
            import asyncio
            import base64
            import os
            from dotenv import load_dotenv
            from pathlib import Path
            from elevenlabs import AudioFormat, CommitStrategy, ElevenLabs, RealtimeEvents, RealtimeAudioOptions

            load_dotenv()

            async def main():
                # Initialize the ElevenLabs client
                elevenlabs = ElevenLabs(api_key=os.getenv("ELEVENLABS_API_KEY"))

                # Create an event to signal when transcription is complete
                transcription_complete = asyncio.Event()

                # Connect with manual audio chunk mode
                connection = await elevenlabs.speech_to_text.realtime.connect(RealtimeAudioOptions(
                    model_id="scribe_v2_realtime",
                    audio_format=AudioFormat.PCM_16000,
                    sample_rate=16000,
                    commit_strategy=CommitStrategy.MANUAL,
                    include_timestamps=True,
                ))

                # Set up event handlers
                def on_session_started(data):
                    print(f"Session started: {data}")
                    # Start sending audio once session is ready
                    asyncio.create_task(send_audio())

                def on_partial_transcript(data):
                    transcript = data.get('text', '')
                    if transcript:
                        print(f"Partial: {transcript}")

                def on_committed_transcript(data):
                    transcript = data.get('text', '')
                    print(f"\nCommitted transcript: {transcript}")

                def on_committed_transcript_with_timestamps(data):
                    print(f"Timestamps: {data.get('words', '')}")
                    print("-" * 50)
                    # Signal that transcription is complete
                    transcription_complete.set()

                def on_error(error):
                    print(f"Error: {error}")
                    transcription_complete.set()

                def on_close():
                    print("Connection closed")
                    transcription_complete.set()

                # Register event handlers
                connection.on(RealtimeEvents.SESSION_STARTED, on_session_started)
                connection.on(RealtimeEvents.PARTIAL_TRANSCRIPT, on_partial_transcript)
                connection.on(RealtimeEvents.COMMITTED_TRANSCRIPT, on_committed_transcript)
                connection.on(RealtimeEvents.COMMITTED_TRANSCRIPT_WITH_TIMESTAMPS, on_committed_transcript_with_timestamps)
                connection.on(RealtimeEvents.ERROR, on_error)
                connection.on(RealtimeEvents.CLOSE, on_close)

                async def send_audio():
                    """Send audio chunks from a PCM file"""
                    # Path to your PCM audio file (16kHz, 16-bit, mono)
                    # You can convert any audio file to PCM with:
                    # ffmpeg -i input.mp3 -f s16le -ar 16000 -ac 1 output.pcm
                    pcm_file_path = Path("/path/to/audio.pcm")

                    try:
                        # Read the audio file
                        audio_data = pcm_file_path.read_bytes()

                        # Split into chunks (1 second of audio = 32000 bytes at 16kHz, 16-bit)
                        chunk_size = 32000
                        chunks = [audio_data[i:i + chunk_size] for i in range(0, len(audio_data), chunk_size)]

                        # Send each chunk
                        for i, chunk in enumerate(chunks):
                            chunk_base64 = base64.b64encode(chunk).decode('utf-8')
                            await connection.send({"audio_base_64": chunk_base64, "sample_rate": 16000})

                            # Wait 1 second between chunks (simulating real-time)
                            if i < len(chunks) - 1:
                                await asyncio.sleep(1)

                        # Small delay before committing to let last chunk process
                        await asyncio.sleep(0.5)

                        # Commit to finalize segment and get committed transcript
                        await connection.commit()

                    except Exception as e:
                        print(f"Error sending audio: {e}")
                        transcription_complete.set()

                try:
                    # Wait for transcription to complete
                    await transcription_complete.wait()
                except KeyboardInterrupt:
                    print("\nStopping...")
                finally:
                    await connection.close()

            if __name__ == "__main__":
                asyncio.run(main())

            ```

            ```typescript
            import "dotenv/config";
            import * as fs from "node:fs";
            import { ElevenLabsClient, RealtimeEvents, AudioFormat } from "@elevenlabs/elevenlabs-js";

            const elevenlabs = new ElevenLabsClient();

            const connection = await elevenlabs.speechToText.realtime.connect({
              modelId: "scribe_v2_realtime",
              audioFormat: AudioFormat.PCM_16000,
              sampleRate: 16000,
              includeTimestamps: true,
            });

            connection.on(RealtimeEvents.SESSION_STARTED, (data) => {
              console.log("Session started", data);
              sendAudio();
            });

            connection.on(RealtimeEvents.PARTIAL_TRANSCRIPT, (transcript) => {
              console.log("Partial transcript", transcript);
            });

            connection.on(RealtimeEvents.COMMITTED_TRANSCRIPT, (transcript) => {
              console.log("Committed transcript", transcript);
            });

            connection.on(RealtimeEvents.COMMITTED_TRANSCRIPT_WITH_TIMESTAMPS, (transcript) => {
              console.log("Committed with timestamps", transcript);
            });

            connection.on(RealtimeEvents.ERROR, (error) => {
              console.log("Error", error);
            });

            connection.on(RealtimeEvents.CLOSE, () => {
              console.log("Connection closed");
            });

            async function sendAudio() {
              const pcmFilePath = "/path/to/audio.pcm";

              const chunkSize = 32000; // 1 second of 16kHz audio (16000 samples * 2 bytes per sample)

              // Read the entire file into a buffer
              const audioBuffer = fs.readFileSync(pcmFilePath);

              // Split the buffer into chunks of exactly chunkSize bytes
              const chunks: Buffer[] = [];
              for (let i = 0; i < audioBuffer.length; i += chunkSize) {
                const chunk = audioBuffer.subarray(i, i + chunkSize);
                chunks.push(chunk);
              }

              // Send each chunk via websocket payload
              for (let i = 0; i < chunks.length; i++) {
                const chunk = chunks[i];
                const chunkBase64 = chunk.toString("base64");

                connection.send({
                  audioBase64: chunkBase64,
                  sampleRate: 16000,
                });

                // Wait 1 second between chunks to simulate real-time streaming
                // (each chunk contains 1 second of audio at 16kHz)
                if (i < chunks.length - 1) {
                  await new Promise(resolve => setTimeout(resolve, 1000));
                }
              }

              // Small delay before final commit to let the last chunk process
              await new Promise(resolve => setTimeout(resolve, 500));

              // send final commit
              connection.commit();
            }
            ```
            </CodeBlocks>
          </Tab>
        </Tabs>
    </Step>
    <Step title="Execute the code">
        <CodeBlocks>
            ```python
            python example.py
            ```

            ```typescript
            npx tsx example.mts
            ```
        </CodeBlocks>

        You should see the transcription of the audio file printed to the console in chunks.
    </Step>

</Steps>
  </Tab>
</Tabs>

## Query parameters

When using the Realtime Speech to Text WebSocket endpoint, you can configure the transcription session with optional query parameters. These parameters are specified in the `connect` method.

| Parameter                    | Type    | Default       | Description                                                                                                                                                                                                           |
| ---------------------------- | ------- | ------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `model_id`                   | string  | n/a           | Required model ID                                                                                                                                                                                                     |
| `language_code`              | string  | n/a           | An ISO-639-1 or ISO-639-3 language code corresponding to the language of the audio file. Can sometimes improve transcription performance if known beforehand. Leave empty to have the model auto-detect the language. |
| `audio_format`               | string  | `"pcm_16000"` | Audio encoding format. See "Supported audio formats" section                                                                                                                                                          |
| `commit_strategy`            | string  | `"manual"`    | How to segment speech: `manual` or `vad`                                                                                                                                                                              |
| `include_timestamps`         | boolean | `false`       | Whether to receive the `committed_transcript_with_timestamps` event, which includes word-level timestamps.                                                                                                            |
| `vad_silence_threshold_secs` | float   | 1.5           | Seconds of silence before VAD commits (0.3-3.0). Not applicable if `commit_strategy` is `manual`                                                                                                                      |
| `vad_threshold`              | float   | 0.4           | VAD sensitivity (0.1-0.9, lower indicates more sensitive). Not applicable if `commit_strategy` is `manual`                                                                                                            |
| `min_speech_duration_ms`     | int     | 100           | Minimum speech duration for VAD (50-2000ms). Not applicable if `commit_strategy` is `manual`                                                                                                                          |
| `min_silence_duration_ms`    | int     | 100           | Minimum silence duration for VAD (50-2000ms). Not applicable if `commit_strategy` is `manual`                                                                                                                         |

<CodeBlocks>
    ```typescript title="Client"
    import { Scribe, AudioFormat, CommitStrategy } from "@elevenlabs/client";

    const connection = Scribe.connect({
      token: "your-token",
      modelId: "scribe_v2_realtime",
      languageCode: "en",
      audioFormat: AudioFormat.PCM_16000,
      commitStrategy: CommitStrategy.VAD,
      vadSilenceThresholdSecs: 1.5,
      vadThreshold: 0.4,
      minSpeechDurationMs: 100,
      minSilenceDurationMs: 100,
      includeTimestamps: false,
    });
    ```
    ```python
    from elevenlabs import AudioFormat, CommitStrategy, ElevenLabs, RealtimeAudioOptions

    elevenlabs = ElevenLabs()

    connection = await elevenlabs.speech_to_text.realtime.connect(RealtimeAudioOptions(
        model_id="scribe_v2_realtime",
        language_code="en",
        audio_format=AudioFormat.PCM_16000,
        commit_strategy=CommitStrategy.VAD,
        vad_silence_threshold_secs=1.5,
        vad_threshold=0.4,
        min_speech_duration_ms=100,
        min_silence_duration_ms=100,
        include_timestamps=False,
    ))
    ```

    ```typescript title="TypeScript"
    import { ElevenLabsClient, AudioFormat, CommitStrategy } from '@elevenlabs/elevenlabs-js';

    const elevenlabs = new ElevenLabsClient();

    const connection = await elevenlabs.speechToText.realtime.connect({
      modelId: "scribe_v2_realtime",
      languageCode: "en",
      audioFormat: AudioFormat.PCM_16000,
      commitStrategy: CommitStrategy.VAD,
      vadSilenceThresholdSecs: 1.5,
      vadThreshold: 0.4,
      minSpeechDurationMs: 100,
      minSilenceDurationMs: 100,
      includeTimestamps: false,
    });
    ```

</CodeBlocks>

## Supported audio formats

| Format    | Sample Rate | Description                             |
| --------- | ----------- | --------------------------------------- |
| pcm_8000  | 8 kHz       | 16-bit PCM, little-endian               |
| pcm_16000 | 16 kHz      | 16-bit PCM, little-endian (recommended) |
| pcm_22050 | 22.05 kHz   | 16-bit PCM, little-endian               |
| pcm_24000 | 24 kHz      | 16-bit PCM, little-endian               |
| pcm_44100 | 44.1 kHz    | 16-bit PCM, little-endian               |
| pcm_48000 | 48 kHz      | 16-bit PCM, little-endian               |
| ulaw_8000 | 8 kHz       | 8-bit μ-law encoding                    |

## Commit strategies

When sending audio chunks via the WebSocket, transcript segments can be committed in two ways: Manual Commit or Voice Activity Detection (VAD).

### Manual commit

With the manual commit strategy, you control when to commit transcript segments. This is the strategy that is used by default. Committing a segment will clear the processed accumulated transcript and start a new segment without losing context. Committing every 20-30 seconds is good practice to improve latency. By default the stream will be automatically committed every 90 seconds.

For best results, commit during silence periods or another logical point like a turn model.

<Info>Transcript processing starts after the first 2 seconds of audio are sent.</Info>

<CodeBlocks>

```python
await connection.send({
  "audio_base_64": audio_base_64,
  "sample_rate": 16000,
})

# When ready to finalize the segment
await connection.commit()
```

```typescript
connection.send({
  audioBase64: audioBase64,
  sampleRate: 16000,
});

// When ready to finalize the segment
connection.commit();
```

</CodeBlocks>

<Warning>
  Committing manually several times in a short sequence can degrade model performance.
</Warning>

### Voice Activity Detection (VAD)

With the VAD strategy, the transcription engine automatically detects speech and silence segments. When a silence threshold is reached, the transcription engine will commit the transcript segment automatically.

See the [Query parameters](#query-parameters) section for more information on the VAD parameters.

## Error handling

If an error occurs, an error message will be returned before the WebSocket connection is closed.

| Error Type          | Description                                                                                           |
| ------------------- | ----------------------------------------------------------------------------------------------------- |
| `auth_error`        | An error occurred while authenticating the request. Double check your API key.                        |
| `quota_exceeded`    | You have exceeded your usage quota.                                                                   |
| `transcriber_error` | An error occurred while transcribing the audio.                                                       |
| `input_error`       | An error occurred while processing the audio chunk. Likely due to invalid input format or parameters. |
| `error`             | A generic server error.                                                                               |

## Best practices

### Audio quality

- For best results, use a 16kHz sample rate for an optimum balance of quality and bandwidth.
- Ensure clean audio input with minimal background noise.
- Use an appropriate microphone gain to avoid clipping.
- Only mono audio is supported at this time.

### Chunk size

- Send audio chunks of 0.1 - 1 second in length for smooth streaming.
- Smaller chunks result in lower latency but more overhead.
- Larger chunks are more efficient but can introduce latency.

### Reconnection logic

Implement reconnection logic to handle connection failures gracefully using the SDK's event-driven approach.

<CodeBlocks>

```python
import asyncio
from elevenlabs import RealtimeEvents

# Track connection state for reconnection
should_reconnect = {"value": False}
reconnect_event = asyncio.Event()

def on_error(error):
    print(f"Connection error: {error}")
    should_reconnect["value"] = True
    reconnect_event.set()

def on_close():
    print("Connection closed")
    reconnect_event.set()

# Register error handlers
connection.on(RealtimeEvents.ERROR, on_error)
connection.on(RealtimeEvents.CLOSE, on_close)

# Wait for connection to close or error
await reconnect_event.wait()

# Check if we should attempt reconnection
if should_reconnect["value"]:
    print("Reconnecting with exponential backoff...")
    for attempt in range(3):
        try:
            await asyncio.sleep(2 ** attempt)  # Exponential backoff
            connection = await elevenlabs.speech_to_text.realtime.connect(config)
            break
        except Exception as e:
            print(f"Reconnection attempt {attempt + 1} failed: {e}")
```

```typescript
import { RealtimeEvents } from '@elevenlabs/elevenlabs-js';

// Track connection state for reconnection
let shouldReconnect = false;

const reconnectPromise = new Promise<boolean>((resolve) => {
  connection.on(RealtimeEvents.ERROR, (error) => {
    console.log('Connection error:', error);
    shouldReconnect = true;
    resolve(true);
  });

  connection.on(RealtimeEvents.CLOSE, () => {
    console.log('Connection closed');
    resolve(shouldReconnect);
  });
});

// Wait for connection to close or error
const needsReconnect = await reconnectPromise;

// Check if we should attempt reconnection
if (needsReconnect) {
  console.log('Reconnecting with exponential backoff...');
  for (let attempt = 0; attempt < 3; attempt++) {
    try {
      await new Promise((resolve) => setTimeout(resolve, 2 ** attempt * 1000));
      const connection = await elevenlabs.speechToText.realtime.connect(config);
      break;
    } catch (e) {
      console.log(`Reconnection attempt ${attempt + 1} failed:`, e);
    }
  }
}
```

</CodeBlocks>

## Event reference

<AccordionGroup>
  <Accordion title="Sent events">

    | Event | Description | When to use |
    |-------|-------------|-------------|
    | `input_audio_chunk` | Send audio data for transcription | Continuously while streaming audio |

  </Accordion>
  <Accordion title="Received events">

    | Event | Description | When received |
    |-------|-------------|-------------|
    | `session_started` | Confirms connection and returns session configuration | Immediately after WebSocket connection is established |
    | `partial_transcript` | Live transcript update | During audio processing, before a commit is made |
    | `committed_transcript` | Transcript of the audio segment | After a commit (either manual or VAD triggered) |
    | `committed_transcript_with_timestamps` | Sent after the committed transcript of the audio segment. Contains word-level timestamps | Sent after the committed transcript of the audio segment. Only received when `include_timestamps=true` is included in the query parameters |
    | `auth_error` | Authentication error | Invalid or missing API key |
    | `quota_exceeded` | Usage limit reached | Account quota exhausted |
    | `transcriber_error` | Transcription engine error | Internal transcription failure |
    | `input_error` | Invalid input format | Malformed messages or invalid audio |
    | `error` | Generic server error | Unexpected server failure |

  </Accordion>
</AccordionGroup>

## Troubleshooting

<AccordionGroup>
  <Accordion title="No transcripts received">

    - Check audio format matches the configured format
    - Ensure audio data is properly base 64 encoded
    - Verify chunks include the `sample_rate` field
    - Check for authentication errors
    - Verify usage limits

  </Accordion>
  <Accordion title="Partial transcripts but no committed transcript">

    - Ensure you are sending commit messages
    - With VAD, ensure sufficient silence between segments to trigger committed commit

  </Accordion>
  <Accordion title="High latency">

    - Reduce audio chunk size
    - Check network connection
    - Consider using a lower sample rate

  </Accordion>
</AccordionGroup>





---
title: Speech to Text
subtitle: Learn how to turn spoken audio into text with ElevenLabs.
---

## Overview

The ElevenLabs [Speech to Text (STT)](/docs/api-reference/speech-to-text) API turns spoken audio into text with state of the art accuracy. Our Scribe v1 [model](/docs/models) adapts to textual cues across 99 languages and multiple voice styles and can be used to:

- Transcribe podcasts, interviews, and other audio or video content
- Generate transcripts for meetings and other audio or video recordings

<CardGroup cols={3}>
  <Card
    title="Developer tutorial"
    icon="duotone book-sparkles"
    href="/docs/cookbooks/speech-to-text/quickstart"
  >
    Learn how to integrate speech to text into your application.
  </Card>
  <Card
    title="Realtime speech to text"
    icon="duotone book-sparkles"
    href="/docs/cookbooks/speech-to-text/streaming"
  >
    Learn how to transcribe audio with ElevenLabs in realtime with WebSockets.
  </Card>
  <Card
    title="Product guide"
    icon="duotone book-user"
    href="/docs/product-guides/playground/speech-to-text"
  >
    Step-by-step guide for using speech to text in ElevenLabs.
  </Card>
</CardGroup>

<Info>
  Companies requiring HIPAA compliance must contact [ElevenLabs
  Sales](https://elevenlabs.io/contact-sales) to sign a Business Associate Agreement (BAA)
  agreement. Please ensure this step is completed before proceeding with any HIPAA-related
  integrations or deployments.
</Info>

## State of the art accuracy

The Scribe v1 model is capable of transcribing audio from up to 32 speakers with high accuracy. Optionally it can also transcribe audio events like laughter, applause, and other non-speech sounds.

The transcribed output supports exact timestamps for each word and audio event, plus diarization to identify the speaker for each word.

The Scribe v1 model is best used for when high-accuracy transcription is required rather than real-time transcription. A low-latency, real-time version will be released soon.

## Pricing

<Tabs>
  <Tab title="Scribe v1 Developer API">

| Tier     | Price/month | Hours included  | Price per included hour | Price per additional hour |
| -------- | ----------- | --------------- | ----------------------- | ------------------------- |
| Free     | \$0         | 2 hours 30 min  | Unavailable             | Unavailable               |
| Starter  | \$5         | 12 hours 30 min | \$0.4                   | Unavailable               |
| Creator  | \$22        | 62 hours 51 min | \$0.35                  | \$0.48                    |
| Pro      | \$99        | 300 hours       | \$0.33                  | \$0.4                     |
| Scale    | \$330       | 1,100 hours     | \$0.3                   | \$0.33                    |
| Business | \$1,320     | 6,000 hours     | \$0.22                  | \$0.22                    |

  </Tab>
  <Tab title="Scribe v2 Realtime Developer API">

| Tier     | Price/month | Hours included | Price per included hour | Price per additional hour |
| -------- | ----------- | -------------- | ----------------------- | ------------------------- |
| Free     | \$0         | Unavailable    | Unavailable             | Unavailable               |
| Starter  | \$5         | 10 hours       | \$0.48                  | Unavailable               |
| Creator  | \$22        | 48 hours       | \$0.46                  | \$0.63                    |
| Pro      | \$99        | 225 hours      | \$0.44                  | \$0.53                    |
| Scale    | \$330       | 786 hours      | \$0.42                  | \$0.46                    |
| Business | \$1,320     | 3,385 hours    | \$0.39                  | \$0.39                    |

  </Tab>
  <Tab title="Product interface pricing">

| Tier     | Price/month | Hours included  | Price per included hour |
| -------- | ----------- | --------------- | ----------------------- |
| Free     | \$0         | 12 minutes      | Unavailable             |
| Starter  | \$5         | 1 hour          | \$5                     |
| Creator  | \$22        | 4 hours 53 min  | \$4.5                   |
| Pro      | \$99        | 24 hours 45 min | \$4                     |
| Scale    | \$330       | 94 hours 17 min | \$3.5                   |
| Business | \$1,320     | 440 hours       | \$3                     |

  </Tab>

</Tabs>

<Note>
  For reduced pricing at higher scale than 6,000 hours/month in addition to custom MSAs and DPAs,
  please [contact sales](https://elevenlabs.io/contact-sales).

**Note: The free tier requires attribution and does not have commercial licensing.**

</Note>

Scribe has higher concurrency limits than other services from ElevenLabs.
Please see other concurrency limits [here](/docs/models#concurrency-and-priority)

| Plan       | STT Concurrency Limit |
| ---------- | --------------------- |
| Free       | 8                     |
| Starter    | 12                    |
| Creator    | 20                    |
| Pro        | 40                    |
| Scale      | 60                    |
| Business   | 60                    |
| Enterprise | Elevated              |

## Examples

The following example shows the output of the Scribe v1 model for a sample audio file.

<elevenlabs-audio-player
    audio-title="Nicole"
    audio-src="https://storage.googleapis.com/eleven-public-cdn/audio/marketing/nicole.mp3"
/>

```javascript
{
  "language_code": "en",
  "language_probability": 1,
  "text": "With a soft and whispery American accent, I'm the ideal choice for creating ASMR content, meditative guides, or adding an intimate feel to your narrative projects.",
  "words": [
    {
      "text": "With",
      "start": 0.119,
      "end": 0.259,
      "type": "word",
      "speaker_id": "speaker_0"
    },
    {
      "text": " ",
      "start": 0.239,
      "end": 0.299,
      "type": "spacing",
      "speaker_id": "speaker_0"
    },
    {
      "text": "a",
      "start": 0.279,
      "end": 0.359,
      "type": "word",
      "speaker_id": "speaker_0"
    },
    {
      "text": " ",
      "start": 0.339,
      "end": 0.499,
      "type": "spacing",
      "speaker_id": "speaker_0"
    },
    {
      "text": "soft",
      "start": 0.479,
      "end": 1.039,
      "type": "word",
      "speaker_id": "speaker_0"
    },
    {
      "text": " ",
      "start": 1.019,
      "end": 1.2,
      "type": "spacing",
      "speaker_id": "speaker_0"
    },
    {
      "text": "and",
      "start": 1.18,
      "end": 1.359,
      "type": "word",
      "speaker_id": "speaker_0"
    },
    {
      "text": " ",
      "start": 1.339,
      "end": 1.44,
      "type": "spacing",
      "speaker_id": "speaker_0"
    },
    {
      "text": "whispery",
      "start": 1.419,
      "end": 1.979,
      "type": "word",
      "speaker_id": "speaker_0"
    },
    {
      "text": " ",
      "start": 1.959,
      "end": 2.179,
      "type": "spacing",
      "speaker_id": "speaker_0"
    },
    {
      "text": "American",
      "start": 2.159,
      "end": 2.719,
      "type": "word",
      "speaker_id": "speaker_0"
    },
    {
      "text": " ",
      "start": 2.699,
      "end": 2.779,
      "type": "spacing",
      "speaker_id": "speaker_0"
    },
    {
      "text": "accent,",
      "start": 2.759,
      "end": 3.389,
      "type": "word",
      "speaker_id": "speaker_0"
    },
    {
      "text": " ",
      "start": 4.119,
      "end": 4.179,
      "type": "spacing",
      "speaker_id": "speaker_0"
    },
    {
      "text": "I'm",
      "start": 4.159,
      "end": 4.459,
      "type": "word",
      "speaker_id": "speaker_0"
    },
    {
      "text": " ",
      "start": 4.44,
      "end": 4.52,
      "type": "spacing",
      "speaker_id": "speaker_0"
    },
    {
      "text": "the",
      "start": 4.5,
      "end": 4.599,
      "type": "word",
      "speaker_id": "speaker_0"
    },
    {
      "text": " ",
      "start": 4.579,
      "end": 4.699,
      "type": "spacing",
      "speaker_id": "speaker_0"
    },
    {
      "text": "ideal",
      "start": 4.679,
      "end": 5.099,
      "type": "word",
      "speaker_id": "speaker_0"
    },
    {
      "text": " ",
      "start": 5.079,
      "end": 5.219,
      "type": "spacing",
      "speaker_id": "speaker_0"
    },
    {
      "text": "choice",
      "start": 5.199,
      "end": 5.719,
      "type": "word",
      "speaker_id": "speaker_0"
    },
    {
      "text": " ",
      "start": 5.699,
      "end": 6.099,
      "type": "spacing",
      "speaker_id": "speaker_0"
    },
    {
      "text": "for",
      "start": 6.099,
      "end": 6.199,
      "type": "word",
      "speaker_id": "speaker_0"
    },
    {
      "text": " ",
      "start": 6.179,
      "end": 6.279,
      "type": "spacing",
      "speaker_id": "speaker_0"
    },
    {
      "text": "creating",
      "start": 6.259,
      "end": 6.799,
      "type": "word",
      "speaker_id": "speaker_0"
    },
    {
      "text": " ",
      "start": 6.779,
      "end": 6.979,
      "type": "spacing",
      "speaker_id": "speaker_0"
    },
    {
      "text": "ASMR",
      "start": 6.959,
      "end": 7.739,
      "type": "word",
      "speaker_id": "speaker_0"
    },
    {
      "text": " ",
      "start": 7.719,
      "end": 7.859,
      "type": "spacing",
      "speaker_id": "speaker_0"
    },
    {
      "text": "content,",
      "start": 7.839,
      "end": 8.45,
      "type": "word",
      "speaker_id": "speaker_0"
    },
    {
      "text": " ",
      "start": 9,
      "end": 9.06,
      "type": "spacing",
      "speaker_id": "speaker_0"
    },
    {
      "text": "meditative",
      "start": 9.04,
      "end": 9.64,
      "type": "word",
      "speaker_id": "speaker_0"
    },
    {
      "text": " ",
      "start": 9.619,
      "end": 9.699,
      "type": "spacing",
      "speaker_id": "speaker_0"
    },
    {
      "text": "guides,",
      "start": 9.679,
      "end": 10.359,
      "type": "word",
      "speaker_id": "speaker_0"
    },
    {
      "text": " ",
      "start": 10.359,
      "end": 10.409,
      "type": "spacing",
      "speaker_id": "speaker_0"
    },
    {
      "text": "or",
      "start": 11.319,
      "end": 11.439,
      "type": "word",
      "speaker_id": "speaker_0"
    },
    {
      "text": " ",
      "start": 11.42,
      "end": 11.52,
      "type": "spacing",
      "speaker_id": "speaker_0"
    },
    {
      "text": "adding",
      "start": 11.5,
      "end": 11.879,
      "type": "word",
      "speaker_id": "speaker_0"
    },
    {
      "text": " ",
      "start": 11.859,
      "end": 12,
      "type": "spacing",
      "speaker_id": "speaker_0"
    },
    {
      "text": "an",
      "start": 11.979,
      "end": 12.079,
      "type": "word",
      "speaker_id": "speaker_0"
    },
    {
      "text": " ",
      "start": 12.059,
      "end": 12.179,
      "type": "spacing",
      "speaker_id": "speaker_0"
    },
    {
      "text": "intimate",
      "start": 12.179,
      "end": 12.579,
      "type": "word",
      "speaker_id": "speaker_0"
    },
    {
      "text": " ",
      "start": 12.559,
      "end": 12.699,
      "type": "spacing",
      "speaker_id": "speaker_0"
    },
    {
      "text": "feel",
      "start": 12.679,
      "end": 13.159,
      "type": "word",
      "speaker_id": "speaker_0"
    },
    {
      "text": " ",
      "start": 13.139,
      "end": 13.179,
      "type": "spacing",
      "speaker_id": "speaker_0"
    },
    {
      "text": "to",
      "start": 13.159,
      "end": 13.26,
      "type": "word",
      "speaker_id": "speaker_0"
    },
    {
      "text": " ",
      "start": 13.239,
      "end": 13.3,
      "type": "spacing",
      "speaker_id": "speaker_0"
    },
    {
      "text": "your",
      "start": 13.299,
      "end": 13.399,
      "type": "word",
      "speaker_id": "speaker_0"
    },
    {
      "text": " ",
      "start": 13.379,
      "end": 13.479,
      "type": "spacing",
      "speaker_id": "speaker_0"
    },
    {
      "text": "narrative",
      "start": 13.479,
      "end": 13.889,
      "type": "word",
      "speaker_id": "speaker_0"
    },
    {
      "text": " ",
      "start": 13.919,
      "end": 13.939,
      "type": "spacing",
      "speaker_id": "speaker_0"
    },
    {
      "text": "projects.",
      "start": 13.919,
      "end": 14.779,
      "type": "word",
      "speaker_id": "speaker_0"
    }
  ]
}
```

The output is classified in three category types:

- `word` - A word in the language of the audio
- `spacing` - The space between words, not applicable for languages that don't use spaces like Japanese, Mandarin, Thai, Lao, Burmese and Cantonese
- `audio_event` - Non-speech sounds like laughter or applause

## Models

<CardGroup cols={2} rows={1}>
  <Card title="Scribe v1" href="/docs/models#scribe-v1">
    State-of-the-art speech recognition model
    <div className="mt-4 space-y-2">
      <div className="text-sm">Accurate transcription in 99 languages</div>
      <div className="text-sm">Precise word-level timestamps</div>
      <div className="text-sm">Speaker diarization</div>
      <div className="text-sm">Dynamic audio tagging</div>
    </div>
  </Card>
  <Card title="Scribe v2 Realtime" href="/docs/models#scribe-v2-realtime">
    Real-time speech recognition model
    <div className="mt-4 space-y-2">
      <div className="text-sm">Accurate transcription in 99 languages</div>
      <div className="text-sm">Real-time transcription</div>
      <div className="text-sm">Low latency (~150ms&dagger;)</div>
      <div className="text-sm">Precise word-level timestamps</div>
    </div>
  </Card>
</CardGroup>


<div className="text-center">
  <div>[Explore all](/docs/models)</div>
</div>

## Concurrency and priority

Concurrency is the concept of how many requests can be processed at the same time.

For Speech to Text, files that are over 8 minutes long are transcribed in parallel internally in order to speed up processing. The audio is chunked into four segments to be transcribed concurrently.

You can calculate the concurrency limit with the following calculation:

$$
Concurrency = \min(4, \text{round\_up}(\frac{\text{audio\_duration\_secs}}{480}))
$$

For example, a 15 minute audio file will be transcribed with a concurrency of 2, while a 120 minute audio file will be transcribed with a concurrency of 4.

<Info>
  The above calculation is only applicable to Scribe v1. For Scribe v2 Realtime, see the
  [concurrency limit chart](/docs/models#concurrency-and-priority).
</Info>

## Supported languages

The Scribe v1 model supports 99 languages, including:

_Afrikaans (afr), Amharic (amh), Arabic (ara), Armenian (hye), Assamese (asm), Asturian (ast), Azerbaijani (aze), Belarusian (bel), Bengali (ben), Bosnian (bos), Bulgarian (bul), Burmese (mya), Cantonese (yue), Catalan (cat), Cebuano (ceb), Chichewa (nya), Croatian (hrv), Czech (ces), Danish (dan), Dutch (nld), English (eng), Estonian (est), Filipino (fil), Finnish (fin), French (fra), Fulah (ful), Galician (glg), Ganda (lug), Georgian (kat), German (deu), Greek (ell), Gujarati (guj), Hausa (hau), Hebrew (heb), Hindi (hin), Hungarian (hun), Icelandic (isl), Igbo (ibo), Indonesian (ind), Irish (gle), Italian (ita), Japanese (jpn), Javanese (jav), Kabuverdianu (kea), Kannada (kan), Kazakh (kaz), Khmer (khm), Korean (kor), Kurdish (kur), Kyrgyz (kir), Lao (lao), Latvian (lav), Lingala (lin), Lithuanian (lit), Luo (luo), Luxembourgish (ltz), Macedonian (mkd), Malay (msa), Malayalam (mal), Maltese (mlt), Mandarin Chinese (zho), Māori (mri), Marathi (mar), Mongolian (mon), Nepali (nep), Northern Sotho (nso), Norwegian (nor), Occitan (oci), Odia (ori), Pashto (pus), Persian (fas), Polish (pol), Portuguese (por), Punjabi (pan), Romanian (ron), Russian (rus), Serbian (srp), Shona (sna), Sindhi (snd), Slovak (slk), Slovenian (slv), Somali (som), Spanish (spa), Swahili (swa), Swedish (swe), Tamil (tam), Tajik (tgk), Telugu (tel), Thai (tha), Turkish (tur), Ukrainian (ukr), Umbundu (umb), Urdu (urd), Uzbek (uzb), Vietnamese (vie), Welsh (cym), Wolof (wol), Xhosa (xho) and Zulu (zul)._


### Breakdown of language support

Word Error Rate (WER) is a key metric used to evaluate the accuracy of transcription systems. It measures how many errors are present in a transcript compared to a reference transcript. Below is a breakdown of the WER for each language that Scribe v1 supports.

<AccordionGroup>
  <Accordion title="Excellent (≤ 5% WER)">
    Bulgarian (bul), Catalan (cat), Czech (ces), Danish (dan), Dutch (nld), English (eng), Finnish
    (fin), French (fra), Galician (glg), German (deu), Greek (ell), Hindi (hin), Indonesian (ind),
    Italian (ita), Japanese (jpn), Kannada (kan), Malay (msa), Malayalam (mal), Macedonian (mkd),
    Norwegian (nor), Polish (pol), Portuguese (por), Romanian (ron), Russian (rus), Serbian (srp),
    Slovak (slk), Spanish (spa), Swedish (swe), Turkish (tur), Ukrainian (ukr) and Vietnamese (vie).
  </Accordion>
  <Accordion title="High Accuracy (>5% to ≤10% WER)">
    Bengali (ben), Belarusian (bel), Bosnian (bos), Cantonese (yue), Estonian (est), Filipino (fil),
    Gujarati (guj), Hungarian (hun), Kazakh (kaz), Latvian (lav), Lithuanian (lit), Mandarin (cmn),
    Marathi (mar), Nepali (nep), Odia (ori), Persian (fas), Slovenian (slv), Tamil (tam) and Telugu
    (tel)
  </Accordion>
  <Accordion title="Good (>10% to ≤25% WER)">
    Afrikaans (afr), Arabic (ara), Armenian (hye), Assamese (asm), Asturian (ast), Azerbaijani
    (aze), Burmese (mya), Cebuano (ceb), Croatian (hrv), Georgian (kat), Hausa (hau), Hebrew (heb),
    Icelandic (isl), Javanese (jav), Kabuverdianu (kea), Korean (kor), Kyrgyz (kir), Lingala (lin),
    Maltese (mlt), Mongolian (mon), Māori (mri), Occitan (oci), Punjabi (pan), Sindhi (snd), Swahili
    (swa), Tajik (tgk), Thai (tha), Urdu (urd), Uzbek (uzb) and Welsh (cym).
  </Accordion>
  <Accordion title="Moderate (>25% to ≤50% WER)">
    Amharic (amh), Chichewa (nya), Fulah (ful), Ganda (lug), Igbo (ibo), Irish (gle), Khmer (khm),
    Kurdish (kur), Lao (lao), Luxembourgish (ltz), Luo (luo), Northern Sotho (nso), Pashto (pus),
    Shona (sna), Somali (som), Umbundu (umb), Wolof (wol), Xhosa (xho) and Zulu (zul).
  </Accordion>
</AccordionGroup>

## FAQ

<AccordionGroup>
  <Accordion title="Can I use speech to text with video files?">
    Yes, the API supports uploading both audio and video files for transcription.
  </Accordion>
   <Accordion title="What are the file size and duration limits?">
    Files up to 3 GB in size and up to 10 hours in duration are supported.
  </Accordion>
  <Accordion title="Which audio and video formats are supported?">
    The audio supported audio formats include:

    - audio/aac
    - audio/x-aac
    - audio/x-aiff
    - audio/ogg
    - audio/mpeg
    - audio/mp3
    - audio/mpeg3
    - audio/x-mpeg-3
    - audio/opus
    - audio/wav
    - audio/x-wav
    - audio/webm
    - audio/flac
    - audio/x-flac
    - audio/mp4
    - audio/aiff
    - audio/x-m4a

    Supported video formats include:

    - video/mp4
    - video/x-msvideo
    - video/x-matroska
    - video/quicktime
    - video/x-ms-wmv
    - video/x-flv
    - video/webm
    - video/mpeg
    - video/3gpp

  </Accordion>
  <Accordion title="When will you support more languages?">
    ElevenLabs is constantly expanding the number of languages supported by our models. Please check back frequently for updates.
  </Accordion>
     <Accordion title="Does speech to text API support webhooks?">
    Yes, asynchronous transcription results can be sent to webhooks configured in webhook settings in the UI. Learn more in the [webhooks cookbook](/docs/cookbooks/speech-to-text/webhooks).
  </Accordion>
  <Accordion title="Is a multichannel transcription mode supported?">
    Yes, the multichannel STT feature allows you to transcribe audio where each channel is processed independently and assigned a speaker ID based on its channel number. This feature supports up to 5 channels. Learn more in the [multichannel transcription cookbook](/docs/cookbooks/speech-to-text/multichannel-transcription).
  </Accordion>
  <Accordion title="How does billing work for speech to text?">
    ElevenLabs charges for speech to text based on the duration of the audio sent for transcription. Billing is calculated per hour of audio, with rates varying by tier and model. See the [pricing section](/docs/capabilities/speech-to-text#pricing) above for detailed pricing information.
  </Accordion>
</AccordionGroup>
