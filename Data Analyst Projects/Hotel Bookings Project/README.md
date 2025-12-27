### Vesper Hotel Bookings Dashboard – Power BI

!\[Vesper Hotel Logo](assets/logo/vesper-logo.png)

A stylish and interactive Power BI dashboard analyzing hotel reservation data. It delivers clear insights into revenue, occupancy, guest behavior, booking channels, and stay patterns.



#### Project Overview

This dashboard provides hotel managers with actionable metrics, including:

* Total bookings, revenue, average room rate, and cancellation rates
* Guest preferences (weekends vs. weekdays, length of stay, advance booking windows)
* Loyalty program effectiveness and most-used booking channels
* Peak stay days and seasonal trends

#### 

**Note on originality**  
This project is inspired by a popular hotel bookings Power BI tutorial by Chandoo on YouTube. I built it as a hands-on learning exercise and then **extended and personalized it**:

* Added a **Multiple report page** with new visualizations (Revenue by Length of Stay, Loyal vs. Non-Loyal Bookings, Most Used Booking Channels, Status of Hotel Reservations, etc.)
* Redesigned the entire theme using a luxury dark/gold color palette
* Created and Added Dark \& Light Mode Switch on the project for a better visualization  (on the Top right Corner of the page)
* Created a custom **Vesper Hotel brand and logo**
* Included highlighted insight cards (e.g., “Most Preferred Stay Day” with emphasis styling)
* Changed the details and icons on the side bar (Reservations, Special Offers, ...)



The sample dataset is the one used in the original tutorial.



#### Screenshots

###### Page 1 – Executive Overview

!\[Page 1 - Executive Overview](screenshots/page-1-executive-overview.png)

###### Page 2 – Revenue \& Guest Insights

!\[Page 2 - Detailed Insights](screenshots/page-2-detailed-insights.png)

#### 

#### Design Decisions: Canvas Size \& Layout

This dashboard uses a custom canvas size of **1080 × 1920 pixels** (vertical/full-HD mobile orientation) instead of the standard 16:9 landscape format.



**Why this choice?**

\- **Mobile-first viewing experience**: Hotel managers and executives often review reports on tablets (e.g., iPad) or phones while on the move. A vertical layout ensures the entire dashboard is readable and interactive without excessive horizontal scrolling.

\- **More content at a glance**: The taller canvas allows displaying more key visuals and insights on a single page without overcrowding or requiring constant page switching. This reduces cognitive load and enables faster decision-making.

\- **Better storytelling flow**: The vertical design creates a natural top-to-bottom reading flow (similar to a mobile app or webpage), guiding the user from high-level KPIs at the top down to detailed breakdowns below.



This deliberate design decision (common in real-world BI projects targeting executive or field users) enhances usability and makes the insights more accessible in day-to-day hotel operations.



#### How to View the Dashboard

1. Download and install **Power BI Desktop** (free) from Microsoft:  
   https://powerbi.microsoft.com/desktop/
2. Open `Hotel Project.pbix`
3. Navigate between the two report pages – all visuals are fully interactive (slicers, filters, and drill-downs)

*Optional*: I can publish it to Power BI Service and share a public interactive link upon request.





#### Files Included

* `Hotel Project.pbix` – Main dashboard file
* `data/reservations.xlsx` – Sample dataset
* `assets/` – Custom icons, backgrounds, and logo

## 

#### Built With

* Power BI Desktop
* DAX for custom measures
* M language (using power query) for advanced queries and Custom Columns
* PowerPoint for designing the side bar
* Extensive visual formatting and branding
* illustrator and AI For the logo





This project strengthened my skills in data modeling, DAX, dashboard design, and visual storytelling.

Feedback and suggestions are very welcome!

