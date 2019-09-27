# video capture

<form>
  <input type="file" accept="video/*" capture="environment" id="recorder">
  <button>Submit</button>
</form>

<video id="player" controls style="display:none"></video>

<script>
  var recorder = document.getElementById('recorder');
  var player = document.getElementById('player');

  recorder.addEventListener('change', function(e) {
    player.style = 'display:visible';
    var file = e.target.files[0];
    // Do something with the video file.
    player.src = URL.createObjectURL(file);
  });
</script>
