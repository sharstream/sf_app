public with sharing class psaOpportunityResourceRoleSummary {

    private Opportunity opty;
    public List<ResourceRequestWrapper> resourceRequestWrapperList {get; set;}
    public Decimal totalRRHours {get; set;}
    public Decimal totalStandardRevenue {get; set;}
    public Decimal totalDiscountRevenue {get; set;}
    public Decimal totalFixedPriceRevenue {get; set;}
    public Decimal totalProjectedCost {get; set;}
    public Decimal totalDiscountPct {get; set;}
    public Decimal averageCostRate {get; set;}
    public Decimal averageStandardRate {get; set;}
    public Decimal averageDiscountRate {get; set;}
    public String optyCurrencyIsoCode {get; set;}
    public Boolean noData {get; set;}


    public psaOpportunityResourceRoleSummary(ApexPages.StandardController controller) {
        this.opty = (Opportunity)controller.getRecord();
        totalRRHours = 0.00;
        totalStandardRevenue = 0.00;
        totalDiscountRevenue = 0.00;
        totalFixedPriceRevenue = 0.00;
        totalProjectedCost = 0.00;
        totalDiscountPct = 0.00;
        averageCostRate = 0.00;
        averageStandardRate = 0.00;
        averageDiscountRate = 0.00;
        noData = false;
        buildResourceRequestList();
        
    }

    public void buildResourceRequestList()
    {
        system.debug('*** psaOpportunityResourceRoleSummary buildResourceRequestList  ### START ###');
        resourceRequestWrapperList = new List<ResourceRequestWrapper>();

        List<pse__Resource_Request__c> rrList = [
            SELECT id, 
                   pse__Start_Date__c,
                   pse__End_Date__c,
                   pse__Resource_Role__c, 
                   pse__Requested_Bill_Rate__c, 
                   pse__Average_Cost_Rate_Number__c,
                   pse__Average_Cost_Rate__c,
                   pse__SOW_Hours__c,
                   sell_Price__c,
                   Normal_Bill_Rate__c,
                   discount__c,
                   t_m_Total__c,
                   projected_Cost__c,
                   currencyIsoCode,
                   fixed_price_total__c,
                   Opportunity_Product_Name__c
              FROM pse__Resource_Request__c 
             WHERE pse__Opportunity__c = :opty.Id
          ORDER BY Opportunity_Product_Name__c, pse__Resource_Role__c, pse__Start_Date__c];

        if(rrList.size() > 0)
        {
            String oppProductName = null;
            ResourceRequestWrapper tmpRRWrapper = null;

            for(pse__Resource_Request__c rr : rrList)
            {
                pse__Resource_Request__c tmpRR = new pse__Resource_Request__c();

                tmpRR = rr;
                tmpRR.pse__Resource_Role__c = rr.pse__Resource_Role__c;
                tmpRR.pse__Requested_Bill_Rate__c = rr.pse__Requested_Bill_Rate__c <> null ? rr.pse__Requested_Bill_Rate__c : 0;
                tmpRR.pse__Average_Cost_Rate_Number__c = rr.pse__Average_Cost_Rate_Number__c <> null ? rr.pse__Average_Cost_Rate_Number__c : 0;
                tmpRR.pse__SOW_Hours__c = rr.pse__SOW_Hours__c <> null ? rr.pse__SOW_Hours__c : 0;
                tmpRR.discount__c = rr.discount__c <> null ? rr.discount__c : 0;

                if (oppProductName != rr.Opportunity_Product_Name__c)
                {
                    tmpRRWrapper = new ResourceRequestWrapper(rr, rr.Opportunity_Product_Name__c);
                    resourceRequestWrapperList.add(tmpRRWrapper);
                    oppProductName = rr.Opportunity_Product_Name__c;
                }
                else
                {
                    tmpRRWrapper.rrList.add(rr);
                }

                system.debug('*** psaOpportunityResourceRoleSummary tmpRR: ' + tmpRR);


                // Update the totals 
                tmpRRWrapper.totalRRHours+= tmpRR.pse__SOW_Hours__c.setScale(2);
                totalRRHours+= tmpRR.pse__SOW_Hours__c.setScale(2);

                if (tmpRR.Normal_Bill_Rate__c != null)
                {
                    tmpRRWrapper.totalStandardRevenue+= (tmpRR.Normal_Bill_Rate__c * tmpRR.pse__SOW_Hours__c).setScale(2);
                    totalStandardRevenue+= (tmpRR.Normal_Bill_Rate__c * tmpRR.pse__SOW_Hours__c).setScale(2);
                }
                
                tmpRRWrapper.totalDiscountRevenue+= tmpRR.sell_Price__c <> null ? (tmpRR.sell_Price__c * tmpRR.pse__SOW_Hours__c).setScale(2) : 0;
                totalDiscountRevenue+= tmpRR.sell_Price__c <> null ? (tmpRR.sell_Price__c * tmpRR.pse__SOW_Hours__c).setScale(2) : 0;

                //totalFixedPriceRevenue+= tmpRR.sell_Price__c <> null ? (tmpRR.sell_Price__c * tmpRR.pse__SOW_Hours__c).setScale(2) : 0;

                tmpRRWrapper.totalFixedPriceRevenue+= tmpRR.fixed_price_total__c <> null ? tmpRR.fixed_price_total__c.setScale(2) : 0;
                totalFixedPriceRevenue+= tmpRR.fixed_price_total__c <> null ? tmpRR.fixed_price_total__c.setScale(2) : 0;

                tmpRRWrapper.totalProjectedCost+= tmpRR.projected_Cost__c <> null ? tmpRR.projected_Cost__c.setScale(2) : 0;
                totalProjectedCost+= tmpRR.projected_Cost__c <> null ? tmpRR.projected_Cost__c.setScale(2) : 0;

                tmpRRWrapper.optyCurrencyIsoCode = tmpRR.currencyIsoCode;  // RR currency should match Opty currency
                optyCurrencyIsoCode = tmpRR.currencyIsoCode;  // RR currency should match Opty currency
            }  

            // Calculate the 'totals row' fields that need aggreated data
            totalDiscountPct = totalStandardRevenue <> 0 ? (1 - (totalDiscountRevenue / totalStandardRevenue)) * 100 : 0;
            totalDiscountPct = totalDiscountPct.setScale(2);
            averageCostRate = totalRRHours <> 0 ? (totalProjectedCost / totalRRHours).setScale(2) : 0;
            averageStandardRate = totalRRHours <> 0 ? (totalStandardRevenue / totalRRHours).setScale(2) : 0;
            averageDiscountRate = totalRRHours <> 0 ? (totalDiscountRevenue / totalRRHours).setScale(2) : 0;

            system.debug('*** psaOpportunityResourceRoleSummary resourceRequestWrapperList: ' + resourceRequestWrapperList);
        }
        else
        {
            noData = true;
        }

    }
    
    public class ResourceRequestWrapper {
        public List<pse__Resource_Request__c> rrList {get; set;}  
        public string opptyProductName {get; set;} 
         public Decimal totalRRHours {get; set;}
        public Decimal totalStandardRevenue {get; set;}
        public Decimal totalDiscountRevenue {get; set;}
        public Decimal totalFixedPriceRevenue {get; set;}
        public Decimal totalProjectedCost {get; set;}
        public Decimal totalDiscountPct {
            get
            {
                return (totalStandardRevenue <> 0 ? ((1 - (totalDiscountRevenue / totalStandardRevenue)) * 100).setScale(2) : 0);
            } 
            set;}
        public Decimal averageCostRate {
            get
            {
                return (totalRRHours <> 0 ? (totalProjectedCost / totalRRHours).setScale(2) : 0);
            } 
            set;}
        public Decimal averageStandardRate {
            get
            {
                return totalRRHours <> 0 ? (totalStandardRevenue / totalRRHours).setScale(2) : 0;
            }
         set;}
        public Decimal averageDiscountRate {
            get
            {
                return totalRRHours <> 0 ? (totalDiscountRevenue / totalRRHours).setScale(2) : 0;
            } 
            set;}
        public String optyCurrencyIsoCode {get; set;}
        
        public Decimal tmMargin
        {
            get
            {
                return (1 -(totalProjectedCost / totalDiscountRevenue)) * 100;
            }
        }
        public Decimal ffMargin
        {
            get
            {
                return (1-(totalProjectedCost / totalFixedPriceRevenue)) * 100;
            }
        }
        public ResourceRequestWrapper(pse__Resource_Request__c inputResourceRequest, String opptyProductName)
        {
            rrList = new List<pse__Resource_Request__c>();
            rrList.add(inputResourceRequest); 
            this.opptyProductName = opptyProductName;
            totalRRHours = 0.00;
            totalStandardRevenue = 0.00;
            totalDiscountRevenue = 0.00;
            totalFixedPriceRevenue = 0.00;
            totalProjectedCost = 0.00;
            totalDiscountPct = 0.00;
            averageCostRate = 0.00;
            averageStandardRate = 0.00;
            averageDiscountRate = 0.00;
        }

    }
}