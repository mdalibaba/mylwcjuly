import { LightningElement, track } from 'lwc';

export default class Calendar extends LightningElement {
    @track currentDate = new Date();
    @track daysOfWeek = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    @track weeks = [];
    @track monthYear;

    connectedCallback() {
        this.generateCalendar();
    }

    generateCalendar() {
        const date = new Date(this.currentDate);
        date.setDate(1);
        const firstDayIndex = date.getDay();

        const lastDay = new Date(date.getFullYear(), date.getMonth() + 1, 0);
        const lastDayIndex = lastDay.getDay();

        const prevLastDay = new Date(date.getFullYear(), date.getMonth(), 0).getDate();

        const nextDays = 7 - lastDayIndex - 1;

        this.weeks = [];
        let week = [];
        for (let x = firstDayIndex; x > 0; x--) {
            week.push({
                date: prevLastDay - x + 1,
                class: 'prev-date'
            });
        }

        for (let i = 1; i <= lastDay.getDate(); i++) {
            if (week.length === 7) {
                this.weeks.push(week);
                week = [];
            }
            week.push({
                date: i,
                class: 'current-date'
            });
        }

        for (let j = 1; j <= nextDays; j++) {
            if (week.length === 7) {
                this.weeks.push(week);
                week = [];
            }
            week.push({
                date: j,
                class: 'next-date'
            });
        }

        if (week.length) {
            this.weeks.push(week);
        }

        const month = this.currentDate.toLocaleString('default', { month: 'long' });
        const year = this.currentDate.getFullYear();
        this.monthYear = `${month} ${year}`;
    }

    prevMonth() {
        this.currentDate.setMonth(this.currentDate.getMonth() - 1);
        this.generateCalendar();
    }

    nextMonth() {
        this.currentDate.setMonth(this.currentDate.getMonth() + 1);
        this.generateCalendar();
    }
}
