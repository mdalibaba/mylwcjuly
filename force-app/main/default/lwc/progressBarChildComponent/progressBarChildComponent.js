import { LightningElement, api  } from 'lwc';

export default class ProgressBarChildComponent extends LightningElement {

    @api percentage;
    @api str;
    myst='MDA';
    get getStyle() {
        return 'width:' + this.percentage + '%';
    }
    @api mycmp( str1){
        this.myst=str1;
        const customEvent = new CustomEvent('myevent', {
            detail: { message: 'Hello from Child Component!'+str1 }
        });
        // Dispatch the event
        this.dispatchEvent(customEvent);
       // return this.str;
    }
}