// We import the CSS which is extracted to its own file by esbuild.
// Remove this line if you add a your own CSS build pipeline (e.g postcss).

// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "../vendor/some-package.js"
//
// Alternatively, you can `npm install some-package --prefix assets` and import
// them using a path starting with the package name:
//
//     import "some-package"
//

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html";
// Establish Phoenix Socket and LiveView configuration.
import { Socket } from "phoenix";
import { LiveSocket } from "phoenix_live_view";
import topbar from "../vendor/topbar";

let csrfToken = document
  .querySelector("meta[name='csrf-token']")
  .getAttribute("content");

// Show progress bar on live navigation and form submits
topbar.config({ barColors: { 0: "#29d" }, shadowColor: "rgba(0, 0, 0, .3)" });
window.addEventListener("phx:page-loading-start", (info) => topbar.show());
window.addEventListener("phx:page-loading-stop", (info) => topbar.hide());

let Hooks = {};

Hooks.Chart = {
  mounted() {
    var events_in_the_system = [
      "Golf Event 1",
      "Golf Event 2",
      "Golf Event 3",
      "Golf Event 4",
      "Golf Event 5",
    ];
    var total_tickets_for_each_event = [12, 19, 17, 20, 18];
    var total_tickets_scanned_for_each_event = [9, 13, 10, 15, 9];

    var barColors = ["white", "white", "white", "white", "white"];

    new Chart("myChart", {
      type: "bar",
      color: "white",
      data: {
        labels: events_in_the_system,
        datasets: [
          {
            label: "Total Tickets",
            backgroundColor: barColors,
            data: total_tickets_for_each_event,
          },
          {
            label: "Total Tickets Scanned",
            backgroundColor: barColors,
            data: total_tickets_scanned_for_each_event,
          },
        ],
      },
      options: {
        responsive: true,

        scales: {
          y: {
            ticks: { color: "white", beginAtZero: true },
          },
          x: {
            ticks: { color: "white", beginAtZero: true },
          },
        },
        plugins: {
          title: {
            display: true,
            text: "Tickets Scanned for each Event",
            color: "white",
          },
          legend: {
            labels: {
              color: "white",
            },
          },
        },
      },
    });
  },
};

Hooks.Chart2 = {
  mounted() {
    var xValues = ["Golf Event 1", "Golf Event 2", "Golf Event 3", "Golf Event 4", "Golf Event 5"];
    var yValues = [55, 49, 44, 24, 15];
    var barColors = ["#b91d47", "#00aba9", "#2b5797", "#e8c3b9", "#1e7145"];

    new Chart("myChart2", {
      type: "pie",

      data: {
        labels: xValues,
        datasets: [
          {
            backgroundColor: barColors,
            data: yValues,
          },
        ],
      },

      options: {
        responsive: true,
        plugins: {
          title: {
            display: true,
            text: "Tickets Scanned for each Event",
            color: "white",
          },

          legend: {
            labels: {
              color: "white",
            },
          },
        },
      },
    });
  },
};

Hooks.Chart3 = {
  mounted() {
    var events_in_the_system = [
      "Golf Event 1",
      "Golf Event 2",
      "Golf Event 3",
      "Golf Event 4",
      "Golf Event 5",
    ];
    var total_tickets_for_each_event = [12, 19, 17, 20, 18];

    var barColors = ["white", "white", "white", "white", "white"];

    new Chart("myChart3", {
      type: "line",
      color: "white",
      data: {
        labels: events_in_the_system,
        datasets: [
          {
            label: "Total Tickets",
            backgroundColor: barColors,
            borderColor: "white",
            data: total_tickets_for_each_event,
          },
        ],
      },
      options: {
        responsive: true,

        scales: {
          y: {
            ticks: { color: "white", beginAtZero: true },
          },
          x: {
            ticks: { color: "white", beginAtZero: true },
          },
        },
        plugins: {
          title: {
            display: true,
            text: "Tickets Scanned for each Event",
            color: "white",
          },
          legend: {
            labels: {
              color: "white",
            },
          },
        },
      },
    });
  },
};

let liveSocket = new LiveSocket("/live", Socket, {
  hooks: Hooks,
  params: { _csrf_token: csrfToken },
});
// connect if there are any LiveViews on the page
liveSocket.connect();

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket;
