import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:audioplayers/audioplayers.dart';

class AudioPlayerWidget extends HookWidget {
  final String audioUrl;

  const AudioPlayerWidget({Key? key, required this.audioUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final audioPlayer = useMemoized(() => AudioPlayer(), [audioUrl]);
    final isPlaying = useState(false);
    final duration = useState<Duration>(Duration.zero);
    final position = useState<Duration>(Duration.zero);
    final totalTime = useState<Duration>(Duration.zero);
    final initialized = useState(false);
    final hasStarted = useState(false);

    useEffect(() {
      Future<void> initAudio() async {
        await audioPlayer.setSourceUrl(audioUrl);
        // Bekleme süresini artırarak sürenin doğru hesaplanmasını bekleyin
        final totalDuration = await audioPlayer.getDuration();
        if (totalDuration != null) {
          duration.value = totalDuration;
          totalTime.value = totalDuration;
          position.value = Duration.zero;
          initialized.value = true;
        }
      }

      initAudio();

      final durationListener =
          audioPlayer.onDurationChanged.listen((newDuration) {
        duration.value = newDuration;
      });

      final positionListener =
          audioPlayer.onPositionChanged.listen((newPosition) {
        if (isPlaying.value || hasStarted.value) {
          position.value = newPosition;
        }
      });

      final stateListener = audioPlayer.onPlayerStateChanged.listen((state) {
        isPlaying.value = state == PlayerState.playing;
        if (state == PlayerState.completed) {
          audioPlayer.seek(Duration.zero);
          audioPlayer.pause();
          position.value = Duration.zero;
          hasStarted.value = false;
        }
      });

      return () {
        durationListener.cancel();
        positionListener.cancel();
        stateListener.cancel();
        audioPlayer.dispose();
      };
    }, [audioUrl]);

    void playPause() {
      if (isPlaying.value) {
        audioPlayer.pause();
      } else {
        audioPlayer.resume();
        hasStarted.value = true;
      }
    }

    String formatDuration(Duration duration) {
      String twoDigits(int n) => n.toString().padLeft(2, '0');
      final String twoDigitMinutes =
          twoDigits(duration.inMinutes.remainder(60));
      final String twoDigitSeconds =
          twoDigits(duration.inSeconds.remainder(60));
      return "${duration.inHours > 0 ? '${twoDigits(duration.inHours)}:' : ''}$twoDigitMinutes:$twoDigitSeconds";
    }

    return Column(
      children: [
        Row(
          children: [
            IconButton(
              icon: Icon(
                isPlaying.value ? Icons.pause : Icons.play_arrow,
              ),
              onPressed: initialized.value ? playPause : null,
            ),
            Slider(
              inactiveColor: Colors.white.withOpacity(0.6),
              activeColor: Colors.white,
              thumbColor: Colors.blue,
              min: 0,
              max: totalTime.value.inSeconds.toDouble(),
              value: position.value.inSeconds
                  .clamp(0, duration.value.inSeconds)
                  .toDouble(),
              onChanged: (value) {
                final newPosition = Duration(seconds: value.toInt());
                audioPlayer.seek(newPosition);
                position.value = newPosition;
                if (!isPlaying.value) {
                  hasStarted.value = true;
                }
              },
            ),
            Text(
              formatDuration(
                  hasStarted.value ? position.value : duration.value),
            ),
          ],
        ),
      ],
    );
  }
}
