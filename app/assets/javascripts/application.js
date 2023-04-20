const zipSearch = () => {
  const req = new XMLHttpRequest();
  const zip = document.getElementById('zip');

  req.onload = (event) => {
    const response = JSON.parse(req.response);
    document.getElementById('current').textContent = `${response.current}`;
    document.getElementById('high').textContent = `${response.high}`;
    document.getElementById('low').textContent = `${response.low}`;
  };

  req.open('GET', `http://localhost:3000/weather/${zip.value}`);
  req.send();
};

