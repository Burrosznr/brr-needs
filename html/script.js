window.addEventListener('message', function(event) {
    const data = event.data;
  
    if (data.action === 'updateNeeds') {
      updateBar('pipi', data.pipi);
      updateBar('cacca', data.cacca);
      updateBar('sonno', data.sonno);
    } else if (data.action === 'show') {
      document.getElementById('hud').style.display = 'flex';
    } else if (data.action === 'hide') {
      document.getElementById('hud').style.display = 'none';
    }
  });

function updateBar(id, value) {
    const fill = document.querySelector(`#${id} .fill`);
    fill.style.width = `${value}%`;
}
  