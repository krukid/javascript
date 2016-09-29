function discoverGlobals(scriptUrl) {
  const oldGlobals = Object.keys(window);
  const script = document.createElement('script');
  const promise = new Promise((resolve, reject) => {
    script.onload = function() {
      const newGlobals = Object.keys(window);
      const diffGlobals = [];
      for (const global of newGlobals) {
        if (oldGlobals.indexOf(global) < 0) {
          diffGlobals.push(global);
        }
      }
      resolve(diffGlobals);
    }
  });
  script.src = scriptUrl;
  document.body.appendChild(script);
  return promise;
}

function discoverGlobalsAll(urls) {
  const diffGlobals = {};
  return urls.reduce((seq, url) =>
    seq
      .then(() => discoverGlobals(url))
      .then((r) => {
        diffGlobals[url] = r;
      }),
    Promise.resolve()
  ).then(() => diffGlobals);
}

const urls = [
  'https://code.jquery.com/jquery-3.1.0.js',
  'https://fb.me/react-15.1.0.js',
  'https://cdnjs.cloudflare.com/ajax/libs/Chart.js/2.3.0/Chart.bundle.min.js',
  'https://fb.me/react-dom-15.1.0.js',
  'https://cdnjs.cloudflare.com/ajax/libs/react-chartjs/0.8.0/react-chartjs.min.js',
];

discoverGlobalsAll(urls).then(map => {
  console.info(map);
})
