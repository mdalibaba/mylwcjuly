import { LightningElement, api  } from 'lwc';

export default class ProgressBarChildComponent extends LightningElement {

    @api percentage;
    get getStyle() {
        return 'width:' + this.percentage + '%';
    }
    @api mycmp(str){
        alert(this.str);
    }
}