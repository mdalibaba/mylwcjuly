import { LightningElement, track,api } from "lwc"
import chartjs from "@salesforce/resourceUrl/ChartJs";
import getAcc from "@salesforce/apex/getAcc.getAccount";
import { loadScript } from "lightning/platformResourceLoader";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
 
    export default class DonutLwc extends LightningElement {
        @api chartDataset; 
        chart;    
        @api recordId;
        @api  acc;
         
      
      renderedCallback() {    
 
        

        getAcc({recordId:this.recordId})
        .then((result)=>{
            this.acc = result;
            console.log('attachment id=' + this.acc.Id);
            //show success message
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Acc  Id:' + this.acc.Id,
                    variant: 'success',
                }),
            );

            Promise.all([loadScript(this, chartjs)])
          .then(() => {        
          const ctx = this.template.querySelector("canvas");
           this.chart = new window.Chart(ctx,

            {
                type: 'doughnut',
                data: {
                  labels: [this.acc.Total_Amount__c+' :Total Amount ', this.acc.Average_Amount__c+' :Average Amount '],
                  datasets: [{
                    label: '# of Votes',
                    data: [this.acc.Total_Amount__c, this.acc.Average_Amount__c],
                    backgroundColor: ['rgba(255, 99, 132, 0.2)', 'rgba(54, 162, 235, 0.2)' ],
                    borderColor: ['rgba(255, 99, 132, 1)', 'rgba(54, 162, 235, 1)' ],
                    borderWidth: 1
                  }]
                },
                options: {
                  responsive: true,
                  maintainAspectRatio: false,
                  legend: {
                    position: 'right'
                  }
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
        })
        .catch(error=>{
            //show error message
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error creating Attachment record',
                    message: error.body.message,
                    variant: 'error',
                }),
            );
        })

        
      }
    };