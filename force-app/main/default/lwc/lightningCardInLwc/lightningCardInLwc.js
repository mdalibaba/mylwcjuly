 
import { LightningElement, track,api } from "lwc";
import chartjs from "@salesforce/resourceUrl/ChartJs";
import { loadScript } from "lightning/platformResourceLoader";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

export default class LightningCardInLwc extends LightningElement {

    @api chartDataset; 
    chart;    
     
    @api totalamount;
    @api averageamount;

    renderedCallback() {   
         
        Promise.all([loadScript(this, chartjs)]) 
          .then(() => {        
          const ctx = this.template.querySelector("canvas"); 
           this.chart = new window.Chart(ctx,

            {
                type: 'doughnut', 
                data: {
                  labels: [this.totalamount+' Total Earnings ', this.averageamount+' Total Deductions '],
                  datasets: [{
                    label: '# of Votes',
                    data: [this.totalamount, this.averageamount],
                    backgroundColor: ['#01335c', '#00a4e1' ],
                    borderColor: ['#00a4e1', '#01335c' ],
                    borderWidth: 1
                  }]
                },
                options: {
                  responsive: true,
                  maintainAspectRatio: false,
                  legend: {
                    position: 'right' 
                  },
                  legend: {
                    position: 'top',
                  },
                  title: {
                    display: true,
                    text: 'Paystub Summary'
                  },
                   
                   
                 
                }
            }
            
           );         
               })
               .catch(error => {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error loading Chart',
                            message: error.message,
                            variant: 'error',
                        })
                    );
                });
    }
     
}