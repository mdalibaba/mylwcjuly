 
    import { LightningElement, api } from 'lwc';

    export default class AccordionSection extends LightningElement {
        @api imageUrl="/sfc/servlet.shepherd/version/download/068J10000001BmLIAU" ; // Image URL passed as a property
    
        handleMouseMove(event) {
            const imgContainer = this.template.querySelector('.image-container');
            const img = this.template.querySelector('.zoomable-image');
    
            const rect = imgContainer.getBoundingClientRect();
            const x = event.clientX - rect.left; // x position within the element
            const y = event.clientY - rect.top; // y position within the element
    
            // Calculate percentage positions
            const xPercent = (x / rect.width) * 100;
            const yPercent = (y / rect.height) * 100;
    
            // Set background position
            img.style.transformOrigin = `${xPercent}% ${yPercent}%`;
            img.style.transform = 'scale(2)'; // Adjust scale as needed
        }
    
        handleMouseLeave() {
            const img = this.template.querySelector('.zoomable-image');
            img.style.transform = 'scale(1)';
        }
    }
    
