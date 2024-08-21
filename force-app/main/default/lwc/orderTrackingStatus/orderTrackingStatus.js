import { LightningElement , api} from 'lwc';

export default class OrderTrackingStatus extends LightningElement {
    circle='circle '
    selectedEvent;

    isModalOpen = false;
    @api stages = [
        { id: 1, name: 'Order Placed', status: this.circle+'completed' ,css:'completed'},
        { id: 2, name: 'Shipped', status:this.circle+ 'completed',css:'completed' },
        { id: 3, name: 'Out for Delivery', status:this.circle+ 'in-progress',css:'in-progress' },
        { id: 4, name: 'Delivered', status: this.circle+'pending' ,css:'pending'}
    ];

    openModal(event) {
        this.isModalOpen = true;
       
        const clickedStage = event.target.dataset.key;
         
        
        console.log('Clicked stage value:', clickedStage);
        // Find the value of the clicked stage
        const stage = this.stages.find(stage => stage.id == clickedStage);
        
        if (stage) {
            this.selectedEvent=stage;
            console.log('Clicked stage value:', stage.value);
            // Perform additional actions with the clicked stage
        }
    }

    closeModal() {
        this.isModalOpen = false;

    }
}