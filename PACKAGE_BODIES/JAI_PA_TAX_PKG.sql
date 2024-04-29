--------------------------------------------------------
--  DDL for Package Body JAI_PA_TAX_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JAI_PA_TAX_PKG" as
/* $Header: jai_pa_tax_pkg.plb 120.0.12010000.2 2009/04/02 13:15:10 mbremkum ship $ */

/*----------------------------------------------------------------------------------------
Change History
S.No.   DATE         Description
------------------------------------------------------------------------------------------

1      24/04/1005    cbabu for bug#6012570 (5876390) Version: 120.0
                      Projects Billing Enh.
                      forward ported from R11i to R12

---------------------------------------------------------------------------------------- */


------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------execution hirarchy--------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------
--  current parent        condition                                    calling object                      called object
--       level  level
------------------------------------------------------------------------------------------------------------------------------------------
--        1        1          insert or                                     trigger                            calc_taxes_for_invoices
--                            update on pa_draft_invoices_all
--
--        2        1          when request is not null                      calc_taxes_for_invoices            dflt_taxes_for_invoice_lines
--                            (work in loop for multi invoices)
--
--        2        1          pn_project_id is not null                     calc_taxes_for_invoices            dflt_taxes_for_invoice_lines
--                            and pn_draft_invoice_num is not null
--                            (call only single time invoice )
--
--        3        2                                                         dflt_taxes_for_invoice_lines       calculate_taxes
--
--        4        3           when event is default taxes                   calculate_taxes                     tax_defaultation_line
--
--        4        3           when event is recalculate taxes               calculate_taxes                     tax_recalculate_line
--
--        5        4           getting tax category                          tax_defaultation_line               get_tax_category
--
--        6        5           according to preference defined               tax_defaultation_line               get_event_tax_category
--
--        6        5           according to preference defined               tax_defaultation_line               get_project_tax_category
--
--        6        5           according to preference defined               tax_defaultation_line               get_cust_tax_category
--
--        6        5           according to preference defined               tax_defaultation_line               get_expn_tax_category
--
--        7        6           insert line info after tax category            tax_defaultation_line              insert_line_info
--
--        8        4           default taxes when tax category is not null    tax_defaultation_line              default_taxes
--
---------------------------------------------------------------------------------------------------------------
-----------------------------------------global variable information--------------------------------------------
--important-----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------
-- this following variable is just to store header level information
-- this variable no where initilaized and assigned again in package
-- these cariable initialized in following function
--   1. dflt_taxes_for_invoice_lines
--   2. initialize_variable

--lv_inv_currency_code
--ln_inv_exchange_rate
--ln_customer_id
--ln_bill_to_customer_id
--ln_ship_to_customer_id
--ln_bill_to_address_id
--ln_ship_to_address_id
--ln_draft_invoice_num_credited
--ln_write_off_flag
-------------------------------------------------------------------------------------------------------------
--  these variable is for to provide parent level information whenever
--  credit memo invoice is made and it is just passing parent invoice information
--  to il tables to store linking of credit invoice and parent project invoice to get the relation ship .
-- this variable initialize in following function
--  1. insert_line_info

--ln_line_amt
--ln_draft_invoice_line_id
--ln_draft_invoice_id

-- this record type variable holding information regarding header level table
-- this information is common to all lines level records
-------------------------------------------------------------------------------------------------------------

 type global_type is record
  (
   lv_inv_currency_code             pa_draft_invoices_all.inv_currency_code%type ,
   ln_inv_exchange_rate             pa_draft_invoices_all.inv_exchange_rate%type ,
   ln_customer_id                   pa_draft_invoices_all.customer_id%type       ,
   ln_bill_to_customer_id           pa_draft_invoices_all.bill_to_customer_id%type ,
   ln_ship_to_customer_id           pa_draft_invoices_all.ship_to_customer_id%type ,
   ln_bill_to_address_id            pa_draft_invoices_all.bill_to_address_id%type ,
   ln_ship_to_address_id            pa_draft_invoices_all.ship_to_address_id%type ,
-- for credit memo ( invoice ) variables
   ln_draft_invoice_num_credited     pa_draft_invoices_all.draft_invoice_num_credited%type ,
   ln_write_off_flag                 pa_draft_invoices_all.write_off_flag%type ,
   ln_draft_invoice_line_id          jai_pa_draft_invoice_lines.draft_invoice_line_id%type,
   ln_draft_invoice_id               jai_pa_draft_invoice_lines.draft_invoice_id%type ,
   ln_line_amt                       jai_pa_draft_invoice_lines.line_amt%type
   ) ;

 pkg_global_type global_type ;


    /*-------------------------------BEGIN LOCAL METHOD CALC_TAXES_FOR_INVOICES  -----------------------------*/
    procedure  calc_taxes_for_invoices
  (
         err_buf                out nocopy varchar2 ,
   retcode                out nocopy varchar2 ,
   pn_request_id          in  pa_draft_invoices_all.request_id%type ,
   pn_project_id          in  pa_draft_invoices_all.project_id%type  ,
   pn_draft_invoice_num   in  pa_draft_invoices_all.draft_invoice_num%type ,
   pv_event               in  varchar2
        )   is

-- cursor is responsible for getting range of invoices
   lr_get_invoices pa_draft_invoices_all%rowtype ;
   lv_process_flag       varchar2(30);
   lv_process_message    varchar2(2000);
   v_parent_request_id    NUMBER;
   req_status             BOOLEAN        := TRUE;
   v_phase                VARCHAR2(100);
   v_status               VARCHAR2(100);
   v_dev_phase            VARCHAR2(100);
   v_dev_status           VARCHAR2(100);
   v_message              VARCHAR2(100);

-- cursor for getting invoices detail depends upon request id
   cursor cur_get_invoices is
          select pa_draft_invoices_all.*
          from pa_draft_invoices_all
          where request_id = pn_request_id ;

-- cursor for getting one single invoice detail for corresponding project id and draft invoice num

   Cursor cur_get_inv_detail is
          select pa_draft_invoices_all.*
          from pa_draft_invoices_all
          where project_id =  pn_project_id and
                draft_invoice_num = pn_draft_invoice_num ;

   begin
     if pn_request_id is not null then
             v_parent_request_id := pn_request_id ;
             req_status := Fnd_concurrent.wait_for_request(  v_parent_request_id,
                                                             60, -- default value - sleep time in secs
                                                             0, -- default value - max wait in secs
                                                             v_phase,
                                                             v_status,
                                                             v_dev_phase,
                                                             v_dev_status,
                                                              v_message );

       IF v_dev_phase = 'COMPLETE' THEN
          IF v_dev_status <> 'NORMAL' THEN
       Fnd_File.put_line(Fnd_File.LOG, 'Exiting with warning as parent request not completed with normal status');
       Fnd_File.put_line(Fnd_File.LOG, 'Message from parent request :' || v_message);
       retcode := 1;
       err_buf := 'Exiting with warningr as parent request not completed with normal status';
       RETURN;
          END IF;
      END IF;
     IF v_dev_phase = 'COMPLETE' /*OR v_dev_phase = 'INACTIVE'*/  THEN
         IF v_dev_status = 'NORMAL' THEN
               for r_get_invoices in cur_get_invoices
                 loop
                    dflt_taxes_for_invoice_lines(
                                     r_new              =>  r_get_invoices,
                                     pv_action          =>  pv_event,
                                     pv_process_message =>  lv_process_message ,
                                     pv_process_flag    =>  lv_process_flag
                                   );
                 end loop  ;
          end if ;
     end if;
     elsif ( pn_project_id is not null and pn_draft_invoice_num is not null ) then
       open cur_get_inv_detail ;
       fetch cur_get_inv_detail into lr_get_invoices ;
       close cur_get_inv_detail ;
       dflt_taxes_for_invoice_lines(
                                     r_new              =>  lr_get_invoices,
                                     pv_action          =>  pv_event,
                                     pv_process_message =>  lv_process_message ,
                                     pv_process_flag    =>  lv_process_flag
                                   );
      end if;
   end calc_taxes_for_invoices ;


    /*-------------------------------begin local method dflt_taxes_for_invoice_lines  -----------------------------*/


 procedure  dflt_taxes_for_invoice_lines(
                                         r_new              in  pa_draft_invoices_all%rowtype,
                                         pv_action          in  varchar2,
                                         pv_process_message out nocopy varchar2,
                                         pv_process_flag    out nocopy varchar2
                               )  is

 cursor cur_get_invoice_lines is
        select pdii.*
        from pa_draft_invoice_items pdii
        where pdii.project_id = r_new.project_id  and
              pdii.draft_invoice_num = r_new.draft_invoice_num ;
 begin
        ---- package level global variables  -----------------------------------------------------
        --   package global variable help to
  pkg_global_type.ln_customer_id                 :=  r_new.customer_id         ;
  pkg_global_type.ln_bill_to_customer_id         :=  r_new.bill_to_customer_id ;
  pkg_global_type.ln_ship_to_customer_id         :=  r_new.ship_to_customer_id ;
  pkg_global_type.ln_bill_to_address_id          :=  r_new.bill_to_address_id  ;
  pkg_global_type.ln_ship_to_address_id          :=  r_new.ship_to_address_id  ;
  pkg_global_type.lv_inv_currency_code           :=  r_new.inv_currency_code        ;
  pkg_global_type.ln_inv_exchange_rate           :=  r_new.inv_exchange_rate        ;
  pkg_global_type.ln_draft_invoice_num_credited  :=  r_new.draft_invoice_num_credited;
  pkg_global_type.ln_write_off_flag              :=  r_new.write_off_flag;
  pkg_global_type.ln_draft_invoice_line_id       :=  null;
  pkg_global_type.ln_draft_invoice_id            :=  null;
  pkg_global_type.ln_line_amt                    :=  null;
        -----------------------------------------------------------------------------
  for r_pa_draft_invoice_items in cur_get_invoice_lines
  loop
   jai_pa_tax_pkg.calculate_taxes(
                                  r_new              => r_pa_draft_invoice_items,
                                  pv_action          => pv_action,
                                  pv_process_message => pv_process_message,
                                  pv_process_flag    => pv_process_flag
                                 );
   fnd_file.put_line(fnd_file.log,' fire tax default ' || pv_action || pv_process_message || pv_process_flag  );
  end loop  ;
  end dflt_taxes_for_invoice_lines ;


    /*-------------------------------begin local method calculate_taxes  -----------------------------*/
  procedure  calculate_taxes
                               (
                                  r_new   in         pa_draft_invoice_items%rowtype,
                                  pv_action in       varchar2,
                                  pv_process_message out nocopy varchar2,
                                  pv_process_flag out nocopy varchar2
                               ) is
  begin
   if pv_action = jai_constants.default_taxes then
     jai_pa_tax_pkg.tax_defaultation_line(
                                     r_new              => r_new ,
                                     pv_action          => pv_action,
                                       pv_process_message => pv_process_message,
                                       pv_process_flag    => pv_process_flag
                );
   elsif pv_action = jai_constants.recalculate_taxes then
     jai_pa_tax_pkg.tax_recalculate_line(
            r_new              => r_new,
            pv_action          => pv_action,
            pv_process_message => pv_process_message,
            pv_process_flag    => pv_process_flag
               );
    end if ;
  end  calculate_taxes ;

    /*-------------------------------begin local method tax_defaultation_line  -----------------------------*/
 procedure  tax_defaultation_line
                               (
                                  r_new   in         pa_draft_invoice_items%rowtype,
                                  pv_action in       varchar2,
                                  pv_process_message out nocopy varchar2,
                                  pv_process_flag out nocopy varchar2
                               ) is
    ----------------variable declarations---------------------------
    ln_tax_category_id       JAI_CMN_TAX_CTGS_ALL.tax_category_id%type              ;
    ln_draft_invoice_id      jai_pa_draft_invoice_lines.draft_invoice_id%type      ;
    ln_draft_invoice_line_id jai_pa_draft_invoice_lines.draft_invoice_line_id%type ;
    ln_amount                number ;
    ln_tax_amount            number ;
    -----------------------------------------------------------------
 begin
 ----initialization part -----------------------------------------------------
 ln_tax_category_id       := null ;
 ln_draft_invoice_id      := null ;
 ln_draft_invoice_line_id := null ;
 ln_amount                := 0 ;
 ln_tax_amount            := 0 ;
-----------------------------------------------------------------------------

 -- assumption
 -- 1.    for customer
 --              first priority -  customer / site
 --              second priority  - customer null site
 -- 2.   in ship_to_customer id and bill to customer id
 --           if ship to customer_id is not present then consider bill to customer id
 -- step 1   - responsible for getting tax category for project id , invoice num , line num on basis of distribution rule

-- for credit memo invoice generation  , tax category is not required
 if pkg_global_type.ln_draft_invoice_num_credited is null then
     jai_pa_tax_pkg.get_tax_category(
                                  r_new.project_id           ,
                                  r_new.draft_invoice_num    ,
                                  r_new.line_num             ,
                                  r_new.event_task_id        ,
                                  r_new.event_num            ,
                                  pv_action                  ,
                                  pv_process_message         ,
                                  pv_process_flag            ,
                                  ln_tax_category_id ) ;
  end if;
-- step 2   - responsible for populating project information in india localalization table
--            it will populate india localization table even if tax category id is null

  jai_pa_tax_pkg.insert_line_info(
                                  r_new                    ,
                                  ln_tax_category_id       ,
                                  pv_action                ,
                                  ln_draft_invoice_id      ,
                                  ln_draft_invoice_line_id ,
                                  pv_process_message       ,
                                  pv_process_flag
                                  );
-- step 3   - responsible for default taxes
-------------if tax category id is null then no defaultation happen
 if ln_tax_category_id is not null or pkg_global_type.ln_draft_invoice_num_credited is not null then
     ln_amount :=  r_new.inv_amount ;   -- invoice amount instead of amount
     jai_pa_tax_pkg.default_taxes(
                                  pn_tax_category_id       =>   ln_tax_category_id,
                                  pn_draft_invoice_id      =>   ln_draft_invoice_id,
                                  pn_draft_invoice_line_id =>   ln_draft_invoice_line_id,
                                  pv_called_from           =>   null,
                                  pn_line_amount           =>   ln_amount,
                                  pn_tax_amount            =>   ln_tax_amount,
                                  pv_process_message       =>   pv_process_message,
                                  pv_process_flag          =>   pv_process_flag
                                 ) ;
 end if ;
end tax_defaultation_line ;

    /*-------------------------------BEGIN LOCAL METHOD GET_TAX_CATEGORY  -----------------------------*/

procedure  get_tax_category(
                            pn_project_id              in           pa_draft_invoices_all.project_id%type ,
                            pn_draft_invoice_num       in           pa_draft_invoices_all.draft_invoice_num%type ,
                            pn_line_num                in           pa_draft_invoice_items.line_num%type ,
                            pn_event_task_id           in           pa_draft_invoice_items.event_task_id%type,
                            pn_event_num               in           pa_draft_invoice_items.event_num%type,
                            pv_action                  in           varchar2,
                            pv_process_message         out nocopy   varchar2,
                            pv_process_flag            out nocopy   varchar2,
                            pn_tax_category_id         out nocopy   JAI_CMN_TAX_CTGS_ALL.tax_category_id%type
                           ) is

    ----------------VARIABLE DECLARATIONS---------------------------
 lv_distribution_rule                pa_projects_all.distribution_rule%type ;
 ln_tax_category_id                        JAI_CMN_TAX_CTGS_ALL.tax_category_id%type    ;
 ln_process_status                        varchar2(20)  ;
    -----------------------------------------------------------------
    ----------------cursor declarations------------------------------
    -- responsible for getting distribution rule of project id
 cursor cur_distribution_rule is
        select ppa.distribution_rule
        from pa_projects_all ppa
        where ppa.project_id  = pn_project_id and
                 distribution_rule is not null ;

    -- responsible for getting prefernece and context from india localization project setup table
 cursor cur_context_preference(cv_distribution_rule pa_projects_all.distribution_rule%type ) is
        select jpsp.distribution_rule , jpsc.context ,jpsp.preference
        from  jai_pa_setup_contexts jpsc , jai_pa_setup_preferences  jpsp
        where jpsc.context_id = jpsp.context_id and
              jpsp.distribution_rule = cv_distribution_rule
        order by jpsp.preference asc  ;
    ------------------------------------------------------------------

 begin
        ----initialization part -----------------------------------------------------
        lv_distribution_rule     := null ;
        ln_tax_category_id       := null ;
        ln_process_status        := jai_pa_tax_pkg.process_fail;
        -----------------------------------------------------------------------------

      open cur_distribution_rule      ;
      fetch cur_distribution_rule into lv_distribution_rule ;
      close cur_distribution_rule ;

      if lv_distribution_rule is null then
        pv_process_message := 'distribution rule not found ';
        pv_process_flag := jai_constants.expected_error;
        return ;
      end if ;

-- ln_process_status -- process status works as flag in which it tell about previous process was sucessfull or not
--                      if successfull then it comes out from loop other wise continue with other one .
      for rec_context_prefernece in  cur_context_preference(lv_distribution_rule)
      loop
       if jai_constants.setup_event_type = rec_context_prefernece.context then
          -- tax category for events
          jai_pa_tax_pkg.get_event_tax_category(
         pn_project_id                 ,
                           pn_draft_invoice_num          ,
                           pn_line_num                   ,
                           pn_event_task_id              ,
                           pn_event_num                  ,
                           ln_tax_category_id            ,
                           ln_process_status             ,
                           pv_process_message            ,
                           pv_process_flag
                                                ) ;
                     -- exit when tax category is found for events
          pn_tax_category_id := ln_tax_category_id ;
          exit when ln_process_status = jai_pa_tax_pkg.process_success ;
       end if ;
       if jai_constants.setup_expenditure_type = rec_context_prefernece.context then
          -- tax category for expenditure
          jai_pa_tax_pkg.get_expn_tax_category(
                      pn_project_id                ,
                            pn_draft_invoice_num         ,
                            pn_line_num                  ,
                            ln_tax_category_id           ,
                            ln_process_status            ,
                            pv_process_message           ,
                            pv_process_flag
                                               ) ;

                     -- exit when tax category is found for expenditure
          pn_tax_category_id := ln_tax_category_id ;
          exit when ln_process_status = jai_pa_tax_pkg.process_success ;
       end if ;
       if jai_constants.setup_project = rec_context_prefernece.context then
         -- tax category for projects
          jai_pa_tax_pkg.get_project_tax_category(
          pn_project_id               ,
                            pn_draft_invoice_num        ,
                            pn_line_num                 ,
                            ln_tax_category_id          ,
                            ln_process_status           ,
                            pv_process_message          ,
                            pv_process_flag
                                                 ) ;

        -- exit when tax category is found for projects
        pn_tax_category_id := ln_tax_category_id ;
        exit when ln_process_status = jai_pa_tax_pkg.process_success ;
        end if ;

       if jai_constants.setup_customer_site = rec_context_prefernece.context then
        -- tax category for customer/site or customer null site
           jai_pa_tax_pkg.get_cust_tax_category(
                               pn_project_id                ,
                                                 pn_draft_invoice_num         ,
                                                 pn_line_num                  ,
                                                 ln_tax_category_id           ,
                                                 ln_process_status            ,
                                                 pv_process_message           ,
                                                 pv_process_flag
                                                              ) ;
           --  exit when tax category is found for customer/site or customer null site .
           pn_tax_category_id := ln_tax_category_id ;
           exit when ln_process_status = jai_pa_tax_pkg.process_success ;
       end if ;
      end loop ;
      pv_process_message := '';
      pv_process_flag    := jai_constants.successful;
    exception when others then
      PV_PROCESS_MESSAGE :=  SUBSTR('GET_TAX_CATEGORY='|| SQLERRM,1,1999);
      pv_process_flag := jai_constants.expected_error;
    end get_tax_category ;
    /*-------------------------------BEGIN LOCAL METHOD GET_EVENT_TAX_CATEGORY  -----------------------------*/
    procedure get_event_tax_category(
      pn_project_id           in      pa_draft_invoices_all.project_id%type ,
                        pn_draft_invoice_num    in      pa_draft_invoices_all.draft_invoice_num%type ,
                        pn_line_num             in      pa_draft_invoice_items.line_num%type ,
                        pn_event_task_id        in      pa_draft_invoice_items.event_task_id%type,
                        pn_event_num            in      pa_draft_invoice_items.event_num%type,
                        pn_tax_category_id      out nocopy JAI_CMN_TAX_CTGS_ALL.tax_category_id%type  ,
                        pv_process_status       out nocopy varchar2 ,
                        pv_process_message      out nocopy varchar2,
                        pv_process_flag         out nocopy varchar2
                                 ) is

    ----------------VARIABLE DECLARATIONS---------------------------
   ln_event_task_id   pa_draft_invoice_items.event_task_id%type ;
   ln_event_num       pa_draft_invoice_items.event_num%type ;
   ln_event_type      pa_events.event_type%type ;
   ln_event_type_id   pa_event_types.event_type_id%type ;
   ln_tax_category_id JAI_CMN_TAX_CTGS_ALL.tax_category_id%type;
   ln_org_id          NUMBER;  /*Bug 8348822*/

    ----------------cursor declarations------------------------------
-- responsible for getting event type from pa_events

   cursor cur_get_event_type is
          select pe.event_type
          from   pa_events pe
          where  pe.project_id = pn_project_id and
                 ( pe.task_id    = ln_event_task_id or pe.task_id is null )    and
                 pe.event_num  = ln_event_num ;


-- responsible for getting event type id from pa_events_types
   cursor cur_get_event_type_id is
          select event_type_id
          from pa_event_types
          where event_type = ln_event_type ;

 -- responsible for getting tax category for event
   cursor cur_get_tax_category is
          select setup_value1 tax_category
          from jai_pa_setup_values
          where  context    = jai_constants.setup_event_type and -- this will search only for events not for other context types
                 attribute1 = ln_event_type_id and
                 org_id = ln_org_id; /*Bug 8348822 - Tax defaulted based on ORG_ID of the project*/

   begin
        ----initialization part -----------------------------------------------------
                pv_process_status        :=   jai_pa_tax_pkg.process_fail;   -- package global variable
                pn_tax_category_id       :=   null ;
                ln_event_task_id         :=   null ;
                ln_event_num             :=   null ;
                ln_event_type            :=   null ;
                ln_event_type_id         :=   null ;
                ln_tax_category_id       :=   null ;
        -----------------------------------------------------------------------------
        ln_event_task_id :=  pn_event_task_id ;
        ln_event_num     :=  pn_event_num     ;

        /*Bug 8348822 - Fetch ORG_ID of the project*/
        select org_id into ln_org_id
        from pa_projects_all
        where project_id = pn_project_id;

     -- step1
     --         if event_task_id and ln_evnet_num is found null then returns ........................
        if ln_event_num is null then
         pv_process_status   := jai_pa_tax_pkg.process_fail;
         pn_tax_category_id  := null ;
         return ;
        end if ;

        open cur_get_event_type ;
        fetch cur_get_event_type into ln_event_type ;
        close cur_get_event_type ;

     --         if no event type it's found then returns
        if ln_event_type is null then
         pv_process_status  := jai_pa_tax_pkg.process_fail;
         pn_tax_category_id := null ;
         return ;
        end if ;

        open  cur_get_event_type_id ;
        fetch cur_get_event_type_id into ln_event_type_id ;
        close cur_get_event_type_id ;

     -- if event_type_id is not presnet then returns
        if ln_event_type_id is null then
         pv_process_status   := jai_pa_tax_pkg.process_fail;
         pn_tax_category_id  := null ;
         return ;
        end if ;

        open cur_get_tax_category;
        fetch cur_get_tax_category into ln_tax_category_id ;
        close cur_get_tax_category ;

     -- if tax_category_id is not presnet then returns
        if ln_tax_category_id is null then
         pv_process_status :=  jai_pa_tax_pkg.process_fail;
         pn_tax_category_id  :=  null ;
         return ;
        end if ;

        pn_tax_category_id := ln_tax_category_id ;
        pv_process_status  := jai_pa_tax_pkg.process_success;

        pv_process_message := '';
        pv_process_flag    := jai_constants.successful;

   exception when others then
    pv_process_status     :=  jai_pa_tax_pkg.process_fail;
    pn_tax_category_id    :=  null ;
    pv_process_message    :=  substr('get_event_tax_category='|| sqlerrm,1,1999);
    pv_process_flag       :=  jai_constants.unexpected_error;
   end get_event_tax_category ;

        /*-------------------------------begin local method get_project_tax_category  -----------------------------*/
    procedure get_project_tax_category
                                 (     pn_project_id           in  pa_draft_invoices_all.project_id%type ,
                                       pn_draft_invoice_num    in  pa_draft_invoices_all.draft_invoice_num%type ,
                                       pn_line_num             in  pa_draft_invoice_items.line_num%type ,
                                       pn_tax_category_id      out nocopy JAI_CMN_TAX_CTGS_ALL.tax_category_id%type  ,
                                       pv_process_status       out nocopy varchar2 ,
                                       pv_process_message      out nocopy varchar2,
                                       pv_process_flag         out nocopy varchar2
                                 ) is
   ----------------VARIABLE DECLARATIONS---------------------------
       ln_tax_category_id                JAI_CMN_TAX_CTGS_ALL.tax_category_id%type;
       ln_org_id          NUMBER;  /*Bug 8348822*/
    ----------------CURSOR DECLARATIONS------------------------------
    cursor cur_get_project_all is
           select setup_value1 tax_category
           from   jai_pa_setup_values
           where  context     = jai_constants.setup_project and
                  attribute1  = pn_project_id and
                  org_id = ln_org_id; /*Bug 8348822 - Tax defaulted based on ORG_ID of the project*/

   begin
----initialization part -----------------------------------------------------
   pv_process_status   := jai_pa_tax_pkg.process_fail;
   pn_tax_category_id  := null ;
   ln_tax_category_id  := null ;
-----------------------------------------------------------------------------

   /*Bug 8348822 - Fetch ORG_ID of the project*/
   select org_id into ln_org_id
   from pa_projects_all
   where project_id = pn_project_id;

   open cur_get_project_all ;
   fetch cur_get_project_all into ln_tax_category_id ;
   close cur_get_project_all ;

   if ln_tax_category_id is null  then
     pv_process_status        :=        jai_pa_tax_pkg.process_fail;
     pn_tax_category_id        :=        null ;
     return ;
   end if ;

   pn_tax_category_id := ln_tax_category_id ;
   pv_process_status := jai_pa_tax_pkg.process_success;

   pv_process_message := '';
   pv_process_flag    := jai_constants.successful;

   exception when others then
    pv_process_status        :=        jai_pa_tax_pkg.process_fail;
    pn_tax_category_id        :=        null ;

    pv_process_message :=  substr('get_project_tax_category='|| sqlerrm,1,1999);
    pv_process_flag := jai_constants.unexpected_error;
   end get_project_tax_category;
            /*-------------------------------begin local method get_cust_tax_category  -----------------------------*/
    procedure get_cust_tax_category
                                 (     pn_project_id          in  pa_draft_invoices_all.project_id%type ,
                                       pn_draft_invoice_num   in  pa_draft_invoices_all.draft_invoice_num%type ,
                                       pn_line_num            in  pa_draft_invoice_items.line_num%type ,
                                       pn_tax_category_id     out nocopy JAI_CMN_TAX_CTGS_ALL.tax_category_id%type  ,
                                       pv_process_status      out nocopy varchar2 ,
                                       pv_process_message     out nocopy varchar2,
                                       pv_process_flag        out nocopy varchar2
                                 ) is
   ----------------variable declarations---------------------------
 ln_tax_category_id                JAI_CMN_TAX_CTGS_ALL.tax_category_id%type;
 ln_tax_customer_id               pa_draft_invoices_all.ship_to_customer_id%type ;
 ln_tax_address_id                pa_draft_invoices_all.ship_to_address_id%type ;
 ln_org_id                        NUMBER;  /*Bug 8348822*/
    ----------------cursor declarations------------------------------
-- responsible for getting tax category attached with customer / site combination or customer / null site combination
    cursor cur_cust_site_tax(cn_customer_id  pa_draft_invoices_all.ship_to_customer_id%type  ,
                             cn_address_id pa_draft_invoices_all.ship_to_address_id%type)    is
           select setup_value1
           from jai_pa_setup_values
           where attribute1   = cn_customer_id        and
                 attribute2   = cn_address_id and
                 context      = jai_constants.setup_customer_site and
                 org_id = ln_org_id; /*Bug 8348822 - Tax defaulted based on ORG_ID of the project*/

    cursor cur_cust_tax(cn_customer_id  pa_draft_invoices_all.ship_to_customer_id%type)    is
           select setup_value1
           from jai_pa_setup_values
           where attribute1  = cn_customer_id        and
                 context     = jai_constants.setup_customer_site and
                 attribute2 is null and
                 org_id = ln_org_id; /*Bug 8348822 - Tax defaulted based on ORG_ID of the project*/
   begin
        ----initialization part -----------------------------------------------------
  pv_process_status  := jai_pa_tax_pkg.process_fail;
  pn_tax_category_id := null ;
  ln_tax_category_id := null ;
        -----------------------------------------------------------------------------
       -- responsible for getting customer info

  /*Bug 8348822 - Fetch ORG_ID of the project*/
  select org_id into ln_org_id
  from pa_projects_all
  where project_id = pn_project_id;

  if pkg_global_type.ln_ship_to_customer_id is null then
    ln_tax_customer_id := pkg_global_type.ln_bill_to_customer_id ;
    ln_tax_address_id  := pkg_global_type.ln_bill_to_address_id ;
  else
    ln_tax_customer_id := pkg_global_type.ln_ship_to_customer_id ;
    ln_tax_address_id  := pkg_global_type.ln_ship_to_address_id ;
  end if ;

  if ln_tax_address_id is not  null then
    open cur_cust_site_tax(ln_tax_customer_id,ln_tax_address_id)  ;
    fetch cur_cust_site_tax into ln_tax_category_id ;
    close cur_cust_site_tax ;
  end if ;

  if ln_tax_category_id is null  or ln_tax_address_id is  null  then
    open cur_cust_tax(ln_tax_customer_id)  ;
    fetch cur_cust_tax into ln_tax_category_id ;
    close cur_cust_tax ;
  end if ;

  if ln_tax_category_id is null then
    pv_process_status  := jai_pa_tax_pkg.process_fail;
    pn_tax_category_id := null ;
    return ;
  end if ;

-- when process sucess in getting tax  category----------------------------------------
  pn_tax_category_id := ln_tax_category_id ;
  pv_process_status := jai_pa_tax_pkg.process_success;
  pv_process_message := '';
  pv_process_flag    := jai_constants.successful;
---------------------------------------------------------------------------------------
 exception when others then
  pv_process_status        :=        jai_pa_tax_pkg.process_fail;
  pn_tax_category_id        :=        null ;
  pv_process_message :=  substr('get_event_tax_category='|| sqlerrm,1,1999);
  pv_process_flag := jai_constants.unexpected_error;
 end get_cust_tax_category;

            /*-------------------------------BEGIN LOCAL METHOD GET_EXPN_TAX_CATEGORY  -----------------------------*/
 procedure get_expn_tax_category
                                 ( pn_project_id         in        pa_draft_invoices_all.project_id%type ,
                                   pn_draft_invoice_num  in        pa_draft_invoices_all.draft_invoice_num%type ,
                                   pn_line_num           in      pa_draft_invoice_items.line_num%type ,
                                   pn_tax_category_id    out nocopy JAI_CMN_TAX_CTGS_ALL.tax_category_id%type  ,
                                   pv_process_status     out nocopy varchar2  ,
                                   pv_process_message    out nocopy varchar2,
                                   pv_process_flag       out nocopy varchar2
                                 ) is
   ----------------variable declarations---------------------------
  ln_tax_category_id   JAI_CMN_TAX_CTGS_ALL.tax_category_id%type;
  ln_count_expend_type number ;
  lv_expenditure_type  pa_expenditure_types.expenditure_type%type ;
  ln_org_id            NUMBER;  /*Bug 8348822*/
    ----------------cursor declarations------------------------------
-- count different types of expenditure defined in invoices lines
     cursor cur_count_expend_type is
            select count(distinct expenditure_type)
            from pa_expenditure_items_all peia
            where peia.expenditure_item_id in
                (  select expenditure_item_id
                   from pa_cust_rev_dist_lines_all pdida
                   where pdida.project_id = pn_project_id and
                         pdida.draft_invoice_num = pn_draft_invoice_num and
                         pdida.draft_invoice_item_line_num  = pn_line_num
                );
-- find out expenditure type if invoice lines contains same type of expenditure type
     cursor cur_expend_type is
            select distinct expenditure_type
            from pa_expenditure_items_all peia
            where peia.expenditure_item_id in
                   ( select expenditure_item_id
                     from pa_cust_rev_dist_lines_all  pdida
                     where pdida.project_id        = pn_project_id and
                           pdida.draft_invoice_num = pn_draft_invoice_num and
                           pdida.draft_invoice_item_line_num = pn_line_num
                );

-- find out tax category for expenditure types;
    cursor cur_expn_tax_category(cv_expenditure_type pa_expenditure_types.expenditure_type%type ) is
           select jpsv.setup_value1
           from jai_pa_setup_values  jpsv,
          pa_expenditure_types pet
           where jpsv.context     = jai_constants.setup_expenditure_type and
                 jpsv.attribute1  = pet.expenditure_type_id and
                 pet.expenditure_type =cv_expenditure_type and
                 org_id = ln_org_id; /*Bug 8348822 - Tax defaulted based on ORG_ID of the project*/
   begin
        ----initialization part -----------------------------------------------------
  pv_process_status    := jai_pa_tax_pkg.process_fail;
  pn_tax_category_id   := null ;
  ln_tax_category_id   := null ;
  ln_count_expend_type := 0 ;
  lv_expenditure_type  := null ;
        -----------------------------------------------------------------------------

  /*Bug 8348822 - Fetch ORG_ID of the project*/
  select org_id into ln_org_id
  from pa_projects_all
  where project_id = pn_project_id;

  open cur_count_expend_type ;
  fetch cur_count_expend_type into ln_count_expend_type ;
  close cur_count_expend_type ;

-- if expenditure defined for draft invoice lines is greater than 1 then skip this one and continue with next preference
  if nvl(ln_count_expend_type,0) = 0 or nvl(ln_count_expend_type,0) > 1 then
    pv_process_status  := jai_pa_tax_pkg.process_fail;
    pn_tax_category_id := null ;
    return ;
  end if ;

  open cur_expend_type;
  fetch cur_expend_type into lv_expenditure_type  ;
  close cur_expend_type ;

  open cur_expn_tax_category( lv_expenditure_type  ) ;
  fetch cur_expn_tax_category into ln_tax_category_id ;
  close cur_expn_tax_category ;

-- when process successful in getting tax  category----------------------------------------
  if ln_tax_category_id is null then
    pv_process_status  := jai_pa_tax_pkg.process_fail;
    pn_tax_category_id := null ;
    return ;
  end if ;

    pn_tax_category_id := ln_tax_category_id ;
    pv_process_status := jai_pa_tax_pkg.process_success;

    pv_process_message := '';
    pv_process_flag    := jai_constants.successful;
---------------------------------------------------------------------------------------
   exception when others then
    pv_process_status        :=        jai_pa_tax_pkg.process_fail;
    pn_tax_category_id        :=        null ;

    pv_process_message :=  substr('get_event_tax_category='|| sqlerrm,1,1999);
    pv_process_flag := jai_constants.unexpected_error;
   end get_expn_tax_category ;

            /*-------------------------------BEGIN LOCAL METHOD INSERT_LINE_INFO  -----------------------------*/

procedure insert_line_info (
                            r_new               in pa_draft_invoice_items%rowtype,
                            pn_tax_category_id  in JAI_CMN_TAX_CTGS_ALL.tax_category_id%type  ,
                            pv_action           in varchar2,
                            pn_draft_invoice_id out nocopy jai_pa_draft_invoice_lines.draft_invoice_id%type      ,
                            pn_draft_invoice_line_id out nocopy jai_pa_draft_invoice_lines.draft_invoice_line_id%type ,
                            pv_process_message       out nocopy varchar2,
                            pv_process_flag          out nocopy varchar2
                           ) is

ln_draft_invoice_id          jai_pa_draft_invoice_lines.draft_invoice_id%type       ;
ln_draft_invoice_line_id  jai_pa_draft_invoice_lines.draft_invoice_line_id%type  ;
ln_count                  number ;
-- credit memo changes
----------------------------------------------------------------------------------------
ln_organization_id   jai_pa_draft_invoices.organization_id%type;
ln_location_id       jai_pa_draft_invoices.location_id%type;
lv_service_type_code jai_pa_draft_invoice_lines.service_type_code%type;
ln_parent_draft_invoice_id jai_pa_draft_invoice_lines.parent_draft_invoice_id%type;
ln_parent_tax_category_id  jai_pa_draft_invoice_lines.tax_category_id%type;
ln_tax_category_id         jai_pa_draft_invoice_lines.tax_category_id%type;
----------------------------------------------------------------------------------------
-- get draft invoice id for existing draft invoice lines

cursor cur_draft_invoice_id is
       select  draft_invoice_id
       from jai_pa_draft_invoices
       where project_id         =  r_new.project_id and
             draft_invoice_num  =  r_new.draft_invoice_num ;

-- generate sequence for header id
cursor cur_draft_inv_seq is
       select  jai_pa_draft_invoices_s.nextval
       from dual ;

-- generate sequence for line id
cursor cur_draft_inv_line_seq is
       select jai_pa_draft_invoice_lines_s.nextval
       from dual ;

--for credit memo invoice generation
-- this cursor find out organization id and location id from header table

--credit memo invoice changes ----------------------------------------

cursor cur_get_header_var is
       select organization_id , location_id , draft_invoice_id
       from jai_pa_draft_invoices
       where project_id        = r_new.project_id and
             draft_invoice_num = pkg_global_type.ln_draft_invoice_num_credited;

cursor cur_get_detail_var is
       select service_type_code ,draft_invoice_id , draft_invoice_line_id ,line_amt , tax_category_id
       from jai_pa_draft_invoice_lines
       where project_id        =r_new.project_id and
             draft_invoice_num =pkg_global_type.ln_draft_invoice_num_credited and
            line_num           =r_new.draft_inv_line_num_credited ;
--end  ----------------------------------------

begin

 ----initialization part -----------------------------------------------------
 ln_draft_invoice_id        := null ;
 ln_draft_invoice_line_id   := null ;
 ln_count                   := 0 ;
 ln_organization_id         := null ;
 ln_location_id             := null ;
 lv_service_type_code       := null ;
 ln_parent_draft_invoice_id := null ;
 ln_parent_tax_category_id  := null ;
 ln_tax_category_id         := null ;

 pkg_global_type.ln_draft_invoice_id      := null ;
 pkg_global_type.ln_draft_invoice_line_id := null ;
 -----------------------------------------------------------------------------

--step 1 -- checking for draft invoice id whether record is already present or not
 open cur_draft_invoice_id ;
 fetch cur_draft_invoice_id into ln_draft_invoice_id ;
 close cur_draft_invoice_id ;

--step 1.1 -- for credit memo invoices , get organization id and location id
 if pkg_global_type.ln_draft_invoice_num_credited is not null then
     open cur_get_header_var ;
     fetch cur_get_header_var into ln_organization_id , ln_location_id ,ln_parent_draft_invoice_id;
     close cur_get_header_var ;

     open cur_get_detail_var ;
     fetch cur_get_detail_var into lv_service_type_code  ,pkg_global_type.ln_draft_invoice_id , pkg_global_type.ln_draft_invoice_line_id ,pkg_global_type.ln_line_amt  ,ln_parent_tax_category_id ;
     close cur_get_detail_var ;

     ln_tax_category_id := ln_parent_tax_category_id ;
  else
     ln_tax_category_id := pn_tax_category_id ;
  end if ;

--step 2 -- if it found null then sequence generated number is used
  if ln_draft_invoice_id is null then
      open  cur_draft_inv_seq ;
      fetch cur_draft_inv_seq into ln_draft_invoice_id ;
      close cur_draft_inv_seq;

      insert into jai_pa_draft_invoices (
                                         draft_invoice_id       ,
                                         project_id             ,
                                         draft_invoice_num      ,
                                         organization_id        ,
                                         location_id            ,
                                         creation_date          ,
                                         created_by             ,
                                         last_update_date       ,
                                         last_updated_by        ,
                                         last_update_login      ,
                                         parent_draft_invoice_id
                                        )
                        values          (
                                         ln_draft_invoice_id              ,
                                         r_new.project_id             ,
                                         r_new.draft_invoice_num      ,
                                         ln_organization_id              ,
                                         ln_location_id                      ,
                                         sysdate                      ,
                                         fnd_global.user_id              ,
                                         sysdate                      ,
                                         fnd_global.user_id              ,
                                         fnd_global.login_id          ,
                                         ln_parent_draft_invoice_id
                                         ) ;
  end if ;
--step3 -- generate line id from sequence generated number ;
  open cur_draft_inv_line_seq ;
  fetch cur_draft_inv_line_seq into ln_draft_invoice_line_id ;
  close cur_draft_inv_line_seq;

--step4 -- insert information into il table
  insert into jai_pa_draft_invoice_lines(
                                       draft_invoice_line_id            ,
                                       draft_invoice_id                 ,
                                       project_id                       ,
                                       draft_invoice_num                 ,
                                       line_num                         ,
                                       line_amt                         ,
                                       line_tax_amt                     ,
                                       tax_category_id                  ,
                                       creation_date                         ,
                                       created_by                         ,
                                       last_update_date                 ,
                                       last_updated_by                         ,
                                       last_update_login                ,
                                       service_type_code                ,
                                       parent_draft_invoice_id          ,
                                       parent_draft_invoice_line_id
                                       )
          values (
                                       ln_draft_invoice_line_id         ,
                                       ln_draft_invoice_id                 ,
                                       r_new.project_id                 ,
                                       r_new.draft_invoice_num                 ,
                                       r_new.line_num                         ,
                                       r_new.amount                         ,
                                       null                                 ,
                                       ln_tax_category_id                 ,
                                       sysdate                                 ,
                                       fnd_global.user_id                 ,
                                       sysdate                                 ,
                                       fnd_global.user_id                 ,
                                       fnd_global.login_id              ,
                                       lv_service_type_code             ,
                                       pkg_global_type.ln_draft_invoice_id ,
                                       pkg_global_type.ln_draft_invoice_line_id
                );

-- step5 - return invoice id and line id to calling object for further use .....
pn_draft_invoice_id := ln_draft_invoice_id;
pn_draft_invoice_line_id := ln_draft_invoice_line_id;

pv_process_message := '';
pv_process_flag    := jai_constants.successful;

exception when others then
 pv_process_message :=  substr('insert_line_info='|| sqlerrm,1,1999);
 pv_process_flag := jai_constants.unexpected_error;
end insert_line_info;

            /*-------------------------------BEGIN LOCAL METHOD DEFAULT_TAXES  -----------------------------*/
procedure default_taxes (
                         pn_tax_category_id       number ,
                         pn_draft_invoice_id      number ,
                         pn_draft_invoice_line_id number ,
                         pn_line_amount           number ,
                         pv_called_from           varchar2 default null ,
                         pn_tax_amount            out nocopy  number ,
                         pv_process_message       out nocopy varchar2 ,
                         pv_process_flag          out nocopy varchar2
                        ) is

----------------variable declarations---------------------------
 ln_tax_amount       number ;
 ln_tax_category_id  JAI_CMN_TAX_CTGS_ALL.tax_category_id%type ;
 lv_inv_currency_code pa_draft_invoices_all.inv_currency_code%type;
 ln_inv_exchange_rate pa_draft_invoices_all.inv_exchange_rate%type;
----------------------------------------------------------------
-- responsible to check for tax category id whether it is already exists .
cursor cur_get_tax_caegotry is
       select tax_category_id
       from   jai_cmn_document_taxes
       where source_doc_id      = pn_draft_invoice_id and
             source_doc_line_id = pn_draft_invoice_line_id and
             source_doc_type    = jai_constants.pa_draft_invoice ;

cursor cur_get_inv_info is
       select pdia.inv_currency_code , pdia.inv_exchange_rate
       from pa_draft_invoices_all pdia, jai_pa_draft_invoice_lines   jpdil
       where pdia.project_id = jpdil.project_id and
             pdia.draft_invoice_num = jpdil.draft_invoice_num and
             jpdil.draft_invoice_line_id = pn_draft_invoice_line_id and
             draft_invoice_id = pn_draft_invoice_id ;

cursor cur_get_tax_amount is
       select sum(tax_amt)
       from jai_cmn_document_taxes
       where source_doc_id = pn_draft_invoice_id and
             source_doc_line_id = pn_draft_invoice_line_id and
             source_doc_type = jai_constants.pa_draft_invoice ;
-- for credit invoice generation
begin
   ln_tax_amount         := 0 ;
-- for credit invoice generation , tax category should be copy from parent to credit memo
 if pkg_global_type.ln_draft_invoice_num_credited is not null  then
     insert into jai_cmn_document_taxes
                    (
                     doc_tax_id                     ,
                     tax_line_no                    ,
                     tax_id                         ,
                     tax_type                       ,
                     currency_code                  ,
                     tax_rate                       ,
                     qty_rate                       ,
                     uom                            ,
                     tax_amt                        ,
                     func_tax_amt                   ,
                     modvat_flag                    ,
                     tax_category_id                ,
                     source_doc_type                ,
                     source_doc_id                  ,
                     source_doc_line_id             ,
                     source_table_name              ,
                     tax_modified_by                ,
                     adhoc_flag                     ,
                     precedence_1                   ,
                     precedence_2                   ,
                     precedence_3                   ,
                     precedence_4                   ,
                     precedence_5                   ,
                     precedence_6                   ,
                     precedence_7                   ,
                     precedence_8                   ,
                     precedence_9                   ,
                     precedence_10                  ,
                     creation_date                  ,
                     created_by                     ,
                     last_update_date               ,
                     last_updated_by                ,
                     last_update_login
                     )
        select   jai_cmn_document_taxes_s.nextval       ,
                 j1.tax_line_no      ,
                 j1.tax_id           ,
                 j1.tax_type         ,
                 j1.currency_code    ,
                 j1.tax_rate         ,
                 j1.qty_rate         ,
                 j1.uom              ,
                 round(((pn_line_amount * ((j1.tax_amt *100)/pkg_global_type.ln_line_amt ) )/100),nvl(j2.rounding_factor,0)),
                 round(((pn_line_amount * ((j1.func_tax_amt *100)/pkg_global_type.ln_line_amt ) )/100),nvl(j2.rounding_factor,0))             ,
                 j1.modvat_flag      ,     j1.tax_category_id  ,
                 j1.source_doc_type  ,     pn_draft_invoice_id    ,
                 pn_draft_invoice_line_id                 ,
                 j1.source_table_name              ,
                 j1.tax_modified_by                ,
                 j1.adhoc_flag                     ,
                 j1.precedence_1                   ,
                 j1.precedence_2                   ,
                 j1.precedence_3                   ,
                 j1.precedence_4                   ,
                 j1.precedence_5                   ,
                 j1.precedence_6                   ,
                 j1.precedence_7                   ,
                 j1.precedence_8                   ,
                 j1.precedence_9                   ,
                 j1.precedence_10                  ,
                 sysdate                               ,
                 fnd_global.user_id               ,
                 sysdate                               ,
                 fnd_global.user_id               ,
                 fnd_global.login_id
       from  jai_cmn_document_taxes j1 , JAI_CMN_TAXES_ALL j2
       where j1.source_doc_id = pkg_global_type.ln_draft_invoice_id and
             j1.source_doc_line_id = pkg_global_type.ln_draft_invoice_line_id and
             j1.source_doc_type = jai_constants.pa_draft_invoice and
             j1.tax_id = j2.tax_id ;



      open cur_get_tax_amount ;
      fetch cur_get_tax_amount into ln_tax_amount ;
      close cur_get_tax_amount;

      update jai_pa_draft_invoice_lines
      set line_tax_amt  = ln_tax_amount
      where draft_invoice_line_id =  pn_draft_invoice_line_id and
            draft_invoice_id      =  pn_draft_invoice_id  ;

      pn_tax_amount := ln_tax_amount ;

   else

  lv_inv_currency_code := pkg_global_type.lv_inv_currency_code;
         if lv_inv_currency_code = jai_constants.func_curr then
    ln_inv_exchange_rate  := 1 ;  -- for multi currecncy support
         else
          ln_inv_exchange_rate := (1/nvl(pkg_global_type.ln_inv_exchange_rate,1));    -- for multi currecncy support
   end if;

         if pn_tax_category_id is null then
          pv_process_message  := 'tax category can not be null ';
          pv_process_flag     :=  jai_constants.expected_error;
          return ;
         end if;

         open cur_get_tax_caegotry ;
         fetch cur_get_tax_caegotry into ln_tax_category_id ;
         close cur_get_tax_caegotry ;

--if  tax category id is present and it is different then delete from taxes table
         if ln_tax_category_id is not null and  ln_tax_category_id <> pn_tax_category_id then
          delete from jai_cmn_document_taxes
          where source_doc_id =     pn_draft_invoice_id and
                source_doc_line_id =    pn_draft_invoice_line_id and
                source_doc_type = jai_constants.pa_draft_invoice ;
         end if ;

        IF PV_CALLED_FROM IS NOT NULL AND PV_CALLED_FROM = 'JAINRWDI' THEN
        -- procedure is being called from invoice review - india ui hence get currency related
        -- information from the header table (pa_draft_invoices_all).
        --
        -- if procedure is being called from trigger this control should never come here
        -- it will result in mutation
           open  cur_get_inv_info;
           fetch cur_get_inv_info
     into lv_inv_currency_code,
          ln_inv_exchange_rate ;
           close  cur_get_inv_info;

    if lv_inv_currency_code = jai_constants.func_curr then
      ln_inv_exchange_rate  := 1 ;  -- for multi currecncy support
          else
            ln_inv_exchange_rate := (1/nvl(ln_inv_exchange_rate,1));    -- FOR MULTI CURRECNCY SUPPORT
    END IF;
        END IF; -- PV_CALLED_FROM

-- if it is null or tax category id is different then default the taxes
 IF LN_TAX_CATEGORY_ID IS NULL OR LN_TAX_CATEGORY_ID <> PN_TAX_CATEGORY_ID THEN
     LN_TAX_AMOUNT := PN_LINE_AMOUNT;

     jai_cmn_tax_defaultation_pkg.JA_IN_CALC_PREC_TAXES
                    (
                     TRANSACTION_NAME       =>  JAI_CONSTANTS.PA_DRAFT_INVOICE,
                     P_TAX_CATEGORY_ID      =>  PN_TAX_CATEGORY_ID,
                     P_HEADER_ID            =>  PN_DRAFT_INVOICE_ID,
                     P_LINE_ID              =>  PN_DRAFT_INVOICE_LINE_ID,
                     P_TAX_AMOUNT           =>  LN_TAX_AMOUNT,
                     P_INVENTORY_ITEM_ID    =>  NULL,
                     P_ASSESSABLE_VALUE     =>  LN_TAX_AMOUNT,
                     P_VAT_ASSESSABLE_VALUE =>  LN_TAX_AMOUNT,
                     P_LINE_QUANTITY        =>  1,
                     P_UOM_CODE             =>  NULL,
                     P_VENDOR_ID            =>  NULL,
                     P_CURRENCY             =>  LV_INV_CURRENCY_CODE,
                     P_CURRENCY_CONV_FACTOR =>  LN_INV_EXCHANGE_RATE, -- FOR MULTI CURRENCT SUPPORT
                     P_CREATION_DATE        =>  SYSDATE,
                     P_CREATED_BY           =>  FND_GLOBAL.USER_ID,
                     P_LAST_UPDATE_DATE     =>  SYSDATE,
                     P_LAST_UPDATED_BY      =>  FND_GLOBAL.USER_ID,
                     P_LAST_UPDATE_LOGIN    =>  FND_GLOBAL.LOGIN_ID,
                     P_SOURCE_TRX_TYPE      =>  JAI_CONSTANTS.PA_DRAFT_INVOICE,
                     P_SOURCE_TABLE_NAME    =>  'JAI_PA_DRAFT_INVOICE_LINES',
                     P_ACTION               =>  JAI_CONSTANTS.DEFAULT_TAXES
                     )   ;


       pn_tax_amount := ln_tax_amount;

       update jai_pa_draft_invoice_lines
       set line_tax_amt  = pn_tax_amount
       where draft_invoice_line_id =  pn_draft_invoice_line_id and
             draft_invoice_id      =  pn_draft_invoice_id  ;
       end if ;
 END IF ;
 PV_PROCESS_MESSAGE := '';
 PV_PROCESS_FLAG    := JAI_CONSTANTS.SUCCESSFUL;
EXCEPTION WHEN OTHERS THEN
 PV_PROCESS_MESSAGE  := SUBSTR('DEFAULT_TAXES :  ' || sqlerrm , 1,1999);
 PV_PROCESS_FLAG     :=  JAI_CONSTANTS.UNEXPECTED_ERROR;
END DEFAULT_TAXES;

            /*-------------------------------BEGIN LOCAL METHOD SYNC_DELETION  -----------------------------*/

 procedure sync_deletion (
                          pn_project_id        number,
                          pn_draft_invoice_num number,
                          pv_process_message   out nocopy varchar2,
                          pv_process_flag      out nocopy varchar2
                         )  is
  begin
   delete from jai_cmn_document_taxes
   where ( source_doc_id , source_doc_line_id )  in
         ( select draft_invoice_id , draft_invoice_line_id
           from jai_pa_draft_invoice_lines
           where project_id = pn_project_id and
                 draft_invoice_num  = pn_draft_invoice_num
          ) ;

   delete from jai_pa_draft_invoice_lines
   where project_id = pn_project_id and
         draft_invoice_num  = pn_draft_invoice_num ;

   delete from jai_pa_draft_invoices
   where project_id =pn_project_id  and
         draft_invoice_num = pn_draft_invoice_num ;

  pv_process_message := '';
  pv_process_flag    := jai_constants.successful;

  exception when others then
   pv_process_message  := substr('sync_deletion  :  ' || sqlerrm , 1,1999);
   pv_process_flag     :=  jai_constants.unexpected_error;
  end  sync_deletion;
            /*-------------------------------BEGIN LOCAL METHOD INITIALIZE_VARIABLE  -----------------------------*/

procedure initialize_variable ( pn_project_id        number ,
                                pn_draft_invoice_num number ,
                                pv_process_message   out nocopy varchar2,
                                pv_process_flag out nocopy varchar2    )    is
 cursor cur_project_header is
        select
              inv_currency_code,
              inv_exchange_rate,
              customer_id,
              bill_to_customer_id,
              ship_to_customer_id,
              bill_to_address_id,
              ship_to_address_id,
              draft_invoice_num_credited,
              write_off_flag
        from pa_draft_invoices_all
  where project_id = pn_project_id and
              draft_invoice_num = pn_draft_invoice_num ;

begin
 open cur_project_header ;
 fetch cur_project_header
 into
       pkg_global_type.lv_inv_currency_code ,
       pkg_global_type.ln_inv_exchange_rate ,
       pkg_global_type.ln_customer_id       ,
       pkg_global_type.ln_bill_to_customer_id ,
       pkg_global_type.ln_ship_to_customer_id ,
       pkg_global_type.ln_bill_to_address_id  ,
       pkg_global_type.ln_ship_to_address_id  ,
       pkg_global_type.ln_draft_invoice_num_credited ,
       pkg_global_type.ln_write_off_flag             ;

    close cur_project_header ;
   pv_process_message := '';
   pv_process_flag    := jai_constants.successful;
  exception when others then
   pv_process_message  := substr('sync_deletion  :  ' || sqlerrm , 1,1999);
   pv_process_flag     :=  jai_constants.unexpected_error;
end  initialize_variable ;

            /*-------------------------------begin local method tax_recalculate_line  -----------------------------*/

procedure  tax_recalculate_line
                               (
                                  r_new   in   pa_draft_invoice_items%rowtype,
                                  pv_action in varchar2,
                                  pv_process_message out nocopy varchar2,
                                  pv_process_flag out nocopy varchar2
                               ) is

 lv_inv_currency_code pa_draft_invoices_all.inv_currency_code%type;
 ln_inv_exchange_rate pa_draft_invoices_all.inv_exchange_rate%type;
 ln_tax_amount       number ;

cursor cur_get_line_detail is
select draft_invoice_id , draft_invoice_line_id
from jai_pa_draft_invoice_lines
where project_id = r_new.project_id  and
      draft_invoice_num =  r_new.draft_invoice_num and
      line_num  = r_new.line_num  ;


begin
     lv_inv_currency_code := pkg_global_type.lv_inv_currency_code;
     if lv_inv_currency_code = jai_constants.func_curr then
       ln_inv_exchange_rate  := 1 ;  -- for multi currecncy support
     else
       ln_inv_exchange_rate := (1/nvl(pkg_global_type.ln_inv_exchange_rate,1));   -- for multi currecncy support
     end if;

   FOR R_GET_LINE_DETAIL IN CUR_GET_LINE_DETAIL
   LOOP
     LN_TAX_AMOUNT := R_NEW.INV_AMOUNT ;
     jai_cmn_tax_defaultation_pkg.JA_IN_CALC_PREC_TAXES
                    (
                     TRANSACTION_NAME       =>  JAI_CONSTANTS.PA_DRAFT_INVOICE,
                     P_TAX_CATEGORY_ID      =>  -1 ,  -- for recalculation tax category not required
                     P_HEADER_ID            =>  R_GET_LINE_DETAIL.DRAFT_INVOICE_ID,
                     P_LINE_ID              =>  R_GET_LINE_DETAIL.DRAFT_INVOICE_LINE_ID,
                     P_TAX_AMOUNT           =>  LN_TAX_AMOUNT,
                     P_INVENTORY_ITEM_ID    =>  NULL,
                     P_ASSESSABLE_VALUE     =>  LN_TAX_AMOUNT,
                     P_VAT_ASSESSABLE_VALUE =>  LN_TAX_AMOUNT,
                     P_LINE_QUANTITY        =>  1,
                     P_UOM_CODE             =>  NULL,
                     P_VENDOR_ID            =>  NULL,
                     P_CURRENCY             =>  LV_INV_CURRENCY_CODE,
                     P_CURRENCY_CONV_FACTOR =>  LN_INV_EXCHANGE_RATE, -- for multi currenct support
                     P_CREATION_DATE        =>  SYSDATE,
                     P_CREATED_BY           =>  FND_GLOBAL.USER_ID,
                     P_LAST_UPDATE_DATE     =>  SYSDATE,
                     P_LAST_UPDATED_BY      =>  FND_GLOBAL.USER_ID,
                     P_LAST_UPDATE_LOGIN    =>  FND_GLOBAL.LOGIN_ID,
                     P_SOURCE_TRX_TYPE      =>  JAI_CONSTANTS.PA_DRAFT_INVOICE,
                     P_SOURCE_TABLE_NAME    =>  'JAI_PA_DRAFT_INVOICE_LINES',
                     P_ACTION               =>  JAI_CONSTANTS.RECALCULATE_TAXES
                     )   ;

  update jai_pa_draft_invoice_lines
  set line_tax_amt  = ln_tax_amount ,
   line_amt      = r_new.inv_amount
  where draft_invoice_line_id =  r_get_line_detail.draft_invoice_line_id and
     draft_invoice_id      =  r_get_line_detail.draft_invoice_id  ;

   end loop ;
end tax_recalculate_line ;

END jai_pa_tax_pkg ;

/
