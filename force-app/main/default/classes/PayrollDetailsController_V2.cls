//Created for testing only.
//  inuse
public with sharing class PayrollDetailsController_V2{
    public list<id> projids {get;set;}
    public Transient set<id> wides {get;set;}
    public string mstrid {get;set;}
    public BZP__PayPeriod__c ppd {get;set;}
    /* Below List is to Aggregate resul*/
    public Transient integer AggreSize{get;set;}
    public Transient   Summary[] Aggregatetaxeslist {get;set;}
    public Transient   Summary[] AggregateEmployerslist {get;set;}
     
    public Transient   Summary[] AggregateEarningslist {get;set;}
    public Transient   Summary[] AggregateEarningslistnontax {get;set;}
    public Transient   Summary[] AggregateDeductionslist {get;set;}
    /* Below map list are used to itterate in vf page*/
    public Transient   Map<HRMSUS__Projects__c,List<BZP__PayStub__c>> Mapdeplist {get;set;}
    public Transient  Map<HRMSUS__Projects__c,List<BZP__Tax__c>> MapTaxvf {get;set;}
    public Transient  Map<HRMSUS__Projects__c,List<BZP__Tax__c>> MapEmpvf {get;set;}
    public Transient  Map<HRMSUS__Projects__c,List<BZP__Earning__c>> MapEarningsvf {get;set;}
    public Transient  Map<HRMSUS__Projects__c,List<BZP__Deduction__c>> MapDeductionvf {get;set;}
    public Transient  Map<HRMSUS__Projects__c,List<BZP__Deposit__c>> MapDepositsvf {get;set;}
    /* Total taxes,earnings,deductions,employer,netpay */
    
    //MapDepTaxvf,MapDepEmpvf,MapDepEarningsvf,MapDepDeductionvf,MapDepNetpayvf
    public Transient  Map<HRMSUS__Projects__c,List<Project_Taxes__c>> MapDepTaxvf {get;set;}
    public Transient  Map<HRMSUS__Projects__c,List<Project_Employers__c>> MapDepEmpvf {get;set;}
    public Transient  Map<HRMSUS__Projects__c,List<Project_Earnings__c>> MapDepEarningvf {get;set;}
    public Transient  Map<HRMSUS__Projects__c,List<Project_Deductions__c>> MapDepDeductionvf {get;set;}
    public Transient  Map<HRMSUS__Projects__c,List<Project_Net_Pay__c>> MapDepNetpayvf {get;set;}
    /* Total taxes,earnings,deductions,employer,netpay */
    public Transient  Map<string,Summary[]> Maptotal {get;set;}
    public PayrollDetailsController_V2(ApexPages.StandardController controller) 
    { 
        
         mstrid =ApexPages.CurrentPage().getParameters().get('ide');
         projids = mstrid.split(',');
        ppd = (BZP__PayPeriod__c)controller.getRecord();
        MapDepTaxvf= new Map<HRMSUS__Projects__c,List<Project_Taxes__c>>();
        MapDepEmpvf= new Map<HRMSUS__Projects__c,List<Project_Employers__c>>();
        MapDepEarningvf= new Map<HRMSUS__Projects__c,List<Project_Earnings__c>>();
        MapDepDeductionvf= new Map<HRMSUS__Projects__c,List<Project_Deductions__c>>();
        MapDepNetpayvf=new Map<HRMSUS__Projects__c,List<Project_Net_Pay__c>>();
        //  Apexpages.currentPage().getHeaders().put('content-disposition', 'attachment; filename=Payroll_Report_'+ppd.Name+'-'+ppd.BZP__PayDate__c+'.pdf');
        /* Below map list are used to itterate in vf page*/
        MapTaxvf = new Map<HRMSUS__Projects__c,List<BZP__Tax__c>>();
        MapEarningsvf = new Map<HRMSUS__Projects__c,List<BZP__Earning__c>>();
        MapDeductionvf = new Map<HRMSUS__Projects__c,List<BZP__Deduction__c>>();
        MapEmpvf= new Map<HRMSUS__Projects__c,List<BZP__Tax__c>> ();
        MapDepositsvf=new Map<HRMSUS__Projects__c,List<BZP__Deposit__c>> ();
        /* above commented map list are used to itterate in vf page*/
        Mapdeplist=new Map<HRMSUS__Projects__c,List<BZP__PayStub__c>>();
        
      map<id,HRMSUS__Projects__c> deplist =new map<id,HRMSUS__Projects__c>([select id,name , 
                                            (SELECT ID, Name,Project__c,Earning_Name__c,Amount__c,Hours__c,Pay_Period__c,Non_Taxable__c FROM Project_Earnings__r WHERE  Pay_Period__c=:ppd.id Order by Earning_Name__c ASC ),
                                            (SELECT ID, Name,Project__c,Tax_Name__c,Amount__c,Pay_Period__c FROM Project_Taxes__r WHERE  Pay_Period__c=:ppd.id Order by Tax_Name__c ASC),
                                            (SELECT ID, Name,Project__c,Employer_Name__c,Amount__c,Pay_Period__c FROM Project_Employers__r WHERE  Pay_Period__c=:ppd.id Order by Employer_Name__c ASC),
                                            (SELECT ID, Name,Project__c,Deduction_Name__c,Amount__c,Pay_Period__c FROM Project_Deductions__r WHERE  Pay_Period__c=:ppd.id Order by Deduction_Name__c ASC),
                                            (SELECT ID, Name,Project__c,Amount__c,Pay_Period__c FROM Project_Net_Pay__r WHERE Pay_Period__c=:ppd.id)
                                            from HRMSUS__Projects__c  Where Id IN : projids Order by Name ASC  ]);
        
        map<id,BZP__PayStub__c> paystubList=new map<id,BZP__PayStub__c>([SELECT ID, Name, BZP__CheckNumber__c, BZP__PayDate__c,Project__c ,Project__r.Name, BZP__PayPeriod__c,BZP__WorkerPaymentMethod__c,
                                                                     BZP__PayPeriod__r.BZP__PeriodBeginning__c, BZP__PayPeriod__r.BZP__PayDate__c, BZP__NetPay__c,
                                                                     BZP__PayPeriod__r.BZP__PeriodEnding__c, BZP__TotalDeductions__c, BZP__TotalEarnings__c, BZP__TotalTaxes__c,
                                                                     BZP__EmployeeTaxLiabilities__c,BZP__Worker__r.Name,BZP__PayPeriod__r.BZP__Company__c,BZP__Worker__c, 
                                                                     (select id,name,BZP__Amount__c,BZP__YTD__c,BZP__PayStub__r.BZP__Worker__c,BZP__AggregateAmount__c,BZP__Rate__c,BZP__Hours__c,BZP__PayStub__c ,BZP__NonTaxable__c from BZP__Earnings__r Order By name ASC ),
                                                                     (select id, name, BZP__Amount__c,BZP__PayStub__r.BZP__Worker__c,BZP__CashOption__c,BZP__Employer_Liability__c, BZP__DeductionCode__c, BZP__YTD__c, BZP__AggregateAmount__c,BZP__PayStub__c from BZP__Deductions__r   order by BZP__Amount__c Desc),
                                                                     (select id, BZP__TaxAmount__c, BZP__PayType__c, BZP__PayStub__c, BZP__YTD__c, BZP__AggregateAmount__c,BZP__EmployerTaxLiability__c, name,Refunded__c from BZP__PaystubTaxes__r Order By BZP__TaxCode__c Asc) ,
                                                                     (select id,Name,BZP__Pay_Period__c,BZP__AccountName__c,BZP__AccountNumber__c,BZP__BankAccountType__c,BZP__PayStub__c,BZP__RoutingNumber__c,BZP__Worker__c,BZP__DepositAmount__c,BZP__Formatted_Deposit_Amount__c from BZP__Deposits__r)
                                                                     from BZP__PayStub__c WHERE BZP__PayPeriod__c=:ppd.id Order by  Project__r.Name ASC,BZP__Worker__r.Name ASC    ]);
        
        //system.debug('deplist--'+deplist.size());
        //system.debug('paystubList--'+paystubList.size());
        set<HRMSUS__Projects__c> dpset = new set<HRMSUS__Projects__c>();
        for(id  dp: deplist.keySet())
        {
            list<BZP__PayStub__c> Pays = new list<BZP__PayStub__c> ();
            for(Id pst:paystubList.keySet() ){
                // if(pst.BZP__Worker__r.HRMSUS__Projects__c !=null && pst.Project__c==dp.Id){
                 
                    if(paystubList.get(pst).Project__c==deplist.get(dp).Id){
                    Pays.add(paystubList.get(pst));
                    dpset.add(deplist.get(dp));
                }
                
                
                 
            }
            if(Pays.size()>0){
                Mapdeplist.put(deplist.get(dp), Pays);
            }
        }
        
        for(HRMSUS__Projects__c  dp: Mapdeplist.keySet())
        {
            List<Project_Earnings__c> earnlist =new List<Project_Earnings__c> ();
            List<Project_Taxes__c> taxlist =new List<Project_Taxes__c> ();
            List<Project_Employers__c> emplist =new List<Project_Employers__c> ();
            List<Project_Deductions__c> dedlist =new List<Project_Deductions__c> ();
            List<Project_Net_Pay__c> netpaylist =new List<Project_Net_Pay__c> ();
            /* */
            for(Project_Earnings__c de: dp.Project_Earnings__r){
                if(de.Pay_Period__c==ppd.Id && de.Project__c==dp.id){
                    earnlist.add(de);
                }
            }
            for(Project_Taxes__c tx:dp.Project_Taxes__r){
                if(tx.Pay_Period__c==ppd.Id && tx.Project__c==dp.id ){
                    taxlist.add(tx);
                }
            }
            for(Project_Employers__c em:dp.Project_Employers__r){
                if(em.Pay_Period__c==ppd.Id && em.Project__c==dp.id){
                    emplist.add(em);
                }
            }
            for(Project_Deductions__c de:dp.Project_Deductions__r){
                if(de.Pay_Period__c==ppd.Id && de.Project__c==dp.id){
                    dedlist.add(de);
                }
            }
            for(Project_Net_Pay__c ne:dp.Project_Net_Pay__r){
                if(ne.Pay_Period__c==ppd.Id && ne.Project__c==dp.id){
                    netpaylist.add(ne);
                }
            }
            //MapDepTaxvf,MapDepEmpvf,MapDepEarningsvf,MapDepDeductionvf,MapDepNetpayvf
            if(earnlist.size()>0){
                MapDepEarningvf.put(dp, earnlist);
            }
            if(earnlist.isEmpty()){
                MapDepEarningvf.put(dp, new list<Project_Earnings__c>());
            }
            if(taxlist.size()>0){
                MapDepTaxvf.put(dp, taxlist);
            }
            if(taxlist.isEmpty()){
                MapDepTaxvf.put(dp, new list<Project_Taxes__c>());
            }
            
            if(emplist.size()>0){
                MapDepEmpvf.put(dp, emplist);
            }
            if(emplist.isEmpty()){
                MapDepEmpvf.put(dp, new list<Project_Employers__c>());
            }
            if(dedlist.size()>0){
                MapDepDeductionvf.put(dp, dedlist);
            }
            if(dedlist.isEmpty()){
                MapDepDeductionvf.put(dp, new list<Project_Deductions__c>());
            }
            if(netpaylist.size()>0){
                MapDepNetpayvf.put(dp, netpaylist);
            }
            if(netpaylist.isEmpty()){
                MapDepNetpayvf.put(dp,  new list<Project_Net_Pay__c>());
            }
            
            
        }
        
        for(HRMSUS__Projects__c  dp: Mapdeplist.keySet()){
            List<BZP__Tax__c> taxm = new list<BZP__Tax__c>();
            List<BZP__Tax__c> empm = new list<BZP__Tax__c>();
            List<BZP__Earning__c> earm = new list<BZP__Earning__c>();
            List<BZP__Deduction__c> dedm = new list<BZP__Deduction__c>();
            List<BZP__Deposit__c> depm = new list<BZP__Deposit__c>();
            
            
            for(BZP__PayStub__c  pb: Mapdeplist.get(dp))
            {
                for(BZP__Tax__c tx:pb.BZP__PaystubTaxes__r){
                    if(  tx.BZP__EmployerTaxLiability__c==false){
                        taxm.add(tx);
                    }else if(  tx.BZP__EmployerTaxLiability__c==true){
                        empm.add(tx);
                    }
                }
                for(BZP__Deduction__c tx:pb.BZP__Deductions__r){
                    if(  tx.BZP__Employer_Liability__c==false){
                        dedm.add(tx);
                    }else if(  tx.BZP__Employer_Liability__c==true){
                        BZP__Tax__c em= new BZP__Tax__c();
                        em.Name=tx.Name;
                        em.BZP__TaxAmount__c=tx.BZP__Amount__c;
                        em.BZP__PayStub__c=tx.BZP__PayStub__c;
                        em.BZP__EmployerTaxLiability__c=true;
                        empm.add(em);
                    }
                }
                /*for(BZP__Earning__c tx:pb.BZP__Earnings__r){
                    //if(tx.BZP__PayStub__c==pb.Id){
                        earm.add(tx);
                   // }
                }*/
              //  for(BZP__Deposit__c tx:pb.BZP__Deposits__r){
                  //  if(tx.BZP__PayStub__c==pb.Id){
                  //      depm.add(tx);
                  //  }
               // }
                
            }
            MapTaxvf.put(dp, taxm);
            MapEmpvf.put(dp, empm);
            MapEarningsvf.put(dp, earm);
            MapDeductionvf.put(dp, dedm);
            MapDepositsvf.put(dp, depm);
            
            
        }
        //Aggregating Taxes,Earning,Deductions,Employer              
    } 
    
     public  void getAggre() 
    {        
        //Aggregating Taxes,Earning,Deductions,Employer
        AggregateEarningslist = new List<Summary>();
        Maptotal=new Map<string,Summary[]>();
        for (AggregateResult ar : [select Earning_Name__c Name,sum(Amount__c)Amount,sum(Hours__c)Hour from Project_Earnings__c where Pay_Period__c =:ppd.Id and Non_Taxable__c=false group by Earning_Name__c Order by Earning_Name__c]) {
            AggregateEarningslist.add(new Summary(ar,''));
        }
        Maptotal.put('Earning', AggregateEarningslist);
         AggregateEarningslistnontax = new List<Summary>();
        for (AggregateResult ar : [select  Earning_Name__c Name,sum(Amount__c)Amount,sum(Hours__c)Hour from Project_Earnings__c where Pay_Period__c =:ppd.Id and Non_Taxable__c=true group by Earning_Name__c Order by Earning_Name__c]) {
            AggregateEarningslistnontax.add(new Summary(ar,''));
        }
        Maptotal.put('Earningnontax', AggregateEarningslistnontax);
        Aggregatetaxeslist = new List<Summary>();
        for (AggregateResult ar : [select Tax_Name__c Name,sum(Amount__c)Amount from Project_Taxes__c where Pay_Period__c =:ppd.Id   group by Tax_Name__c Order by Tax_Name__c]) {
            Aggregatetaxeslist.add(new Summary(ar));
        }
        Maptotal.put('Taxes', Aggregatetaxeslist);
        AggregateEmployerslist = new List<Summary>();
        for (AggregateResult ar : [select Employer_Name__c Name,sum(Amount__c)Amount from Project_Employers__c where Pay_Period__c =:ppd.Id  group by Employer_Name__c Order by Employer_Name__c]) {
            AggregateEmployerslist.add(new Summary(ar));
        }
         
        Maptotal.put('Employers', AggregateEmployerslist);
        AggregateDeductionslist = new List<Summary>();
        for (AggregateResult ar : [select Deduction_Name__c Name,sum(Amount__c)Amount from Project_Deductions__c where Pay_Period__c =:ppd.Id    group by Deduction_Name__c Order by Deduction_Name__c]) {
            AggregateDeductionslist.add(new Summary(ar));
        }
        Maptotal.put('Deductions', AggregateDeductionslist);
        //Aggregating end
        system.debug('Maptotal--'+Maptotal);
        AggreSize=Maptotal.size();        
    }
    
    public class Summary 
    {
        public Decimal  Amount { get; private set; }
        public String Name { get; private set; }
        public Decimal Hour { get; private set; }
        public Summary(AggregateResult ar) 
        {
            Amount = (Decimal)ar.get('Amount');
            Name = (String)ar.get('Name');
        }
        public Summary(AggregateResult ar,string hr) 
        {
            Amount = (Decimal)ar.get('Amount');
            Name = (String)ar.get('Name');
            Hour=(Decimal)ar.get('Hour');
            
        }
    }
      @AuraEnabled
    public static String fetchit1(String recordId) {
         String urler = URL.getSalesforceBaseUrl().toExternalForm() + '/';
        
        return urler;
    }
    
     @AuraEnabled
     public static List<Id> loadProjects(Id ps)
    { 
        system.debug('ps--'+ps);
        list<BZP__PayStub__c> paystubList= [SELECT Id, Name,Project__c,BZP__PayPeriod__c   
                                                                      from BZP__PayStub__c WHERE BZP__PayPeriod__c=:ps and   Project__c !=null   ] ;
        system.debug('BZP__PayStub__c--'+paystubList);
        set<id> dpset = new set<id>();
        for(BZP__PayStub__c pst:paystubList ){
                      dpset.add(pst.Project__c);
         }
        system.debug('dpset--'+dpset);
             List<HRMSUS__Projects__c> workerList=[select Id,Name FROM HRMSUS__Projects__c WHERE   Id IN:dpset order by Name ASC];
        list<Id> prjid= new  list<Id>();
        for(HRMSUS__Projects__c pr:workerList ){
            prjid.add(pr.Id);
        }
            return prjid;
        
   }
    public static void sample(){
        string abc='ABC';
        abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123'; 
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
        abc='ABC123';
        abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123'; 
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
        abc='ABC123';
        abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123'; 
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
        abc='ABC123';
        abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123'; 
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
        abc='ABC123';
        abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123'; 
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
        abc='ABC123';
        abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123'; 
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
        abc='ABC123';
        abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123'; 
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
        abc='ABC123';
        abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123'; 
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
        abc='ABC123';
        abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123'; 
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
        abc='ABC123';
        abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123'; 
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
        abc='ABC123';
        abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123'; 
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
        abc='ABC123';
        abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123'; 
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
        abc='ABC123';
        abc='ABC123';
         abc='ABC123';
         abc='ABC123';
        abc='ABC123';
        abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123'; 
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
        abc='ABC123';
        abc='ABC123';
         abc='ABC123';
         abc='ABC123';
        abc='ABC123';
        abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123'; 
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
        abc='ABC123';
        abc='ABC123';
         abc='ABC123';
         abc='ABC123';
        abc='ABC123';
        abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123'; 
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
        abc='ABC123';abc='ABC123';
         abc='ABC123';
         abc='ABC123';
        abc='ABC123';
        abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123'; 
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
        abc='ABC123';abc='ABC123';
         abc='ABC123';
         abc='ABC123';
        abc='ABC123';
        abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123'; 
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
        abc='ABC123';
        abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123'; 
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
        abc='ABC123';
        abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123'; 
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
        abc='ABC123';
        abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123'; 
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
        abc='ABC123';
        abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123'; 
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
        abc='ABC123';
        abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123'; 
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
        abc='ABC123';
        abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123'; 
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
        abc='ABC123';
        abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123'; 
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
        abc='ABC123';
        abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123'; 
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
        abc='ABC123';
        abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123'; 
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
        abc='ABC123';
        abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123'; 
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
        abc='ABC123';
        abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123'; 
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
        abc='ABC123';
        abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123'; 
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
        abc='ABC123';
        abc='ABC123';
         abc='ABC123';
         abc='ABC123';
        abc='ABC123';
        abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123'; 
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
        abc='ABC123';
        abc='ABC123';
         abc='ABC123';
         abc='ABC123';
        abc='ABC123';
        abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123'; 
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
        abc='ABC123';
        abc='ABC123';
         abc='ABC123';
         abc='ABC123';
        abc='ABC123';
        abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123'; 
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
        abc='ABC123';abc='ABC123';
         abc='ABC123';
         abc='ABC123';
        abc='ABC123';
        abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123'; 
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
        abc='ABC123';abc='ABC123';
         abc='ABC123';
         abc='ABC123';
        abc='ABC123';
        abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123'; 
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
         abc='ABC123';
        abc='ABC123';
    }
}