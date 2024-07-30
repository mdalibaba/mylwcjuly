import { LightningElement } from 'lwc';
import { loadScript } from "lightning/platformResourceLoader";
import ChartJs from '@salesforce/resourceUrl/ChartJs';
import highchat from "@salesforce/resourceUrl/highchat";
import exportchat from "@salesforce/resourceUrl/exportchat";
import accesschart from "@salesforce/resourceUrl/accesschart";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
export default class Dchartdemo extends LightningElement {


    chart;
    chartInitialized = false;
  
    renderedCallback() {
      if (this.chartInitialized) {
        return;
      }
      this.chartInitialized = true;
  
      Promise.all([loadScript(this, ChartJs)])
        .then(() => {
          this.initializeChart();
        })
        .catch(error => {
          console.error(error);
        });
    }
  
    initializeChart() {
      const ctx = this.template.querySelector('canvas').getContext('2d');
      this.chart = new Chart(ctx, {
        type: 'doughnut',
        data: {
          labels: ['Red', 'Blue', 'Yellow'],
          datasets: [{
            data: [300, 50, 100],
            backgroundColor: ['#FF6384', '#36A2EB', '#FFCE56'],
            hoverBackgroundColor: ['#FF6384', '#36A2EB', '#FFCE56']
          }]
        },
        options: {
          responsive: true,
          maintainAspectRatio: false,
          animation: {
            animateScale: true,
            animateRotate: true
          }
        }
      });
    }
       
}