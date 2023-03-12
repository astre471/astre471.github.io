function setFavicons(favImg){
    let headTitle = document.querySelector('head');
    
    let favIcons = [
        { rel: 'apple-touch-icon' },
        { rel: 'apple-touch-startup-image' },
        { rel: 'shortcut icon' }
    ]
    
    favIcons.forEach(function(favIcon){
        let setFavicon = document.createElement('link');
        setFavicon.setAttribute('rel', favIcon.rel);
        setFavicon.setAttribute('href', favImg);
        headTitle.appendChild(setFavicon);
    });
}
setFavicons('https://straber.github.io/astre471/assets/images/favicon.png'); // TODO update: github and DNS move
