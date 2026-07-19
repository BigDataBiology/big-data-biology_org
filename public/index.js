/** @typedef {{load: (Promise<unknown>); flags: (unknown)}} ElmPagesInit */

/** @type ElmPagesInit */
export default {
  load: async function (elmLoaded) {
    // <lazy-visible> fires a "visible" event the first time it scrolls near the
    // viewport, then stops observing.
    if (!customElements.get('lazy-visible')) {
      customElements.define('lazy-visible', class extends HTMLElement {
        connectedCallback() {
          const obs = new IntersectionObserver((entries) => {
            if (entries.some((e) => e.isIntersecting)) {
              obs.disconnect();                       // fire once
              this.dispatchEvent(new CustomEvent('visible'));
            }
          }, { rootMargin: '200px' });                // start fetching ~200px early
          obs.observe(this);
        }
      });
    }

    const app = await elmLoaded;
    var sc = document.createElement('script');
    sc.setAttribute('src', "https://www.googletagmanager.com/gtag/js?id=G-BT86QN3RMP");
    sc.setAttribute('async', true);
    document.getElementById('google-injection-site').appendChild(sc);

    sc = document.createElement('script');
    sc.setAttribute('src', "https://badge.dimensions.ai/badge.js");
    sc.setAttribute('async', true);
    document.getElementById('google-injection-site').appendChild(sc);

    sc = document.createElement('script');

    window.dataLayer = window.dataLayer || [];
    function gtag(){dataLayer.push(arguments);}
    gtag('js', new Date());
    gtag('config', 'G-BT86QN3RMP');

    app.ports.updatePath.subscribe(function(path) {
        gtag('event', 'page_view', { page_path: '/'+path });
    });
  },
  flags: function () {
    return "You can decode this in Shared.elm using Json.Decode.string!";
  },
};
