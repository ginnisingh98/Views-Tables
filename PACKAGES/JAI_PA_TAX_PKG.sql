--------------------------------------------------------
--  DDL for Package JAI_PA_TAX_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JAI_PA_TAX_PKG" AUTHID CURRENT_USER as
/* $Header: jai_pa_tax_pkg.pls 120.0.12000000.1 2007/10/24 18:20:45 rallamse noship $ */

/*----------------------------------------------------------------------------------------
Change History
S.No.   DATE         Description
------------------------------------------------------------------------------------------

1      24/04/1005    cbabu for bug#6012570 (5876390) Version: 120.0
                      Projects Billing Enh.
                      forward ported from R11i to R12

---------------------------------------------------------------------------------------- */


-- process_success  -- responsible for stating process execution success .....
-- process_fail     -- responsible for stating process execution failure .....
    process_success                     constant varchar2(20)           := 'SUCCESS';
    process_fail                        constant varchar2(20)           := 'FAIL';


--------------------------------------------------------------------------------------------------------------------------
--  procedure name         --  tax_defaultation
-- global procedure to call by trigger
-- it is called by trigger to do either defaultation of taxes or recalculation of taxes according to event send by trigger
------parameter details---------------------------------------------------------------------------------------------------
-- pn_request_id - request id of projects table pa_draft_invoices_all for concurrent
-- pn_project_id - project id
-- pn_draft_invoice_num -  draft invoice number
-- pv_event - either defaultation of taxes of recalculate taxes
--                     jai_constants.default_taxes
--             jai_constants.recalculate_taxes

--------------------------------------------------------------------------------------------
    procedure  calc_taxes_for_invoices
  (
         err_buf                out nocopy varchar2 ,
   retcode                out nocopy varchar2 ,
   pn_request_id          in  pa_draft_invoices_all.request_id%type ,
   pn_project_id          in  pa_draft_invoices_all.project_id%type  ,
   pn_draft_invoice_num   in  pa_draft_invoices_all.draft_invoice_num%type ,
   pv_event               in  varchar2
        ) ;

---------------------------------------------------------------------------------------------------------------
--  procedure name         --  tax_defaultation
--  procedure is responsible for calculate taxes for header level information in projects
--------------------------------------------------------------------------------------------

    procedure  dflt_taxes_for_invoice_lines(
          r_new   in     pa_draft_invoices_all%rowtype,
          pv_action in         varchar2,
          pv_process_message  out nocopy varchar2,
                pv_process_flag   out nocopy varchar2
             ) ;


---------------------------------------------------------------------------------------------------------------
--  procedure name         --  calculate_taxes
--  this procedure decides whether to call defaulting routine or call recalculating routine on basis of
--  pv_action
--  if pv_action is default_taxes then it will go for defaultation of taxes
--  if pv_action is recalculate_taxes then it will go for recalculation of taxes
--------------------------------------------------------------------------------------------
    procedure  calculate_taxes(
          r_new       in     pa_draft_invoice_items%rowtype,
          pv_action     in         varchar2,
          pv_process_message    out nocopy varchar2,
                pv_process_flag     out nocopy varchar2
             ) ;


---------------------------------------------------------------------------------------------------------------
--  procedure name         --  tax_defaultation_line
--- three operation
----                  1.    getting tax category
----                  2.    inserting header and detail information into india localization tables
----                  3.    default taxes for these information
--------------------------------------------------------------------------------------------

    procedure  tax_defaultation_line(
          r_new       in     pa_draft_invoice_items%rowtype,
          pv_action     in         varchar2,
          pv_process_message    out nocopy varchar2,
                pv_process_flag     out nocopy varchar2
             ) ;

---------------------------------------------------------------------------------------------------------------
--  procedure name         --  tax_recalculate_line
--- purpose                --  responsibility for reaclculating taxes
---------------------------------------------------------------------------------------------------------------
    procedure  tax_recalculate_line(
                                        r_new in     pa_draft_invoice_items%rowtype,
          pv_action in         varchar2,
          pv_process_message out nocopy varchar2,
                pv_process_flag out nocopy varchar2
             ) ;
------------------------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------------------
--  procedure name         --  get_tax_category
--- purpose                --  responsible for returning tax category to calling object for further operation
---------------------------------------------------------------------------------------------------------------
    procedure  get_tax_category(
          pn_project_id     in     pa_draft_invoices_all.project_id%type ,
          pn_draft_invoice_num    in     pa_draft_invoices_all.draft_invoice_num%type ,
          pn_line_num     in     pa_draft_invoice_items.line_num%type ,
          pn_event_task_id                in     pa_draft_invoice_items.event_task_id%type,
          pn_event_num                    in     pa_draft_invoice_items.event_num%type,
          pv_action     in         varchar2,
          pv_process_message    out nocopy varchar2,
                pv_process_flag     out nocopy varchar2,
          pn_tax_category_id out nocopy JAI_CMN_TAX_CTGS_ALL.tax_category_id%type
             ) ;
---------------------------------------------------------------------------------------------------------------
--  procedure name         --  get_event_tax_category
--- purpose                --  responsible for returning tax category for event types
---------------------------------------------------------------------------------------------------------------
    procedure get_event_tax_category (
               pn_project_id      in  pa_draft_invoices_all.project_id%type ,
                     pn_draft_invoice_num   in  pa_draft_invoices_all.draft_invoice_num%type ,
               pn_line_num      in      pa_draft_invoice_items.line_num%type ,
               pn_event_task_id                 in  pa_draft_invoice_items.event_task_id%type,
               pn_event_num                     in  pa_draft_invoice_items.event_num%type,
                                       pn_tax_category_id out nocopy JAI_CMN_TAX_CTGS_ALL.tax_category_id%type  ,
               pv_process_status out nocopy varchar2 ,
               pv_process_message   out nocopy varchar2,
               pv_process_flag      out nocopy varchar2
             );

---------------------------------------------------------------------------------------------------------------
--  procedure name         --  get_project_tax_category
--- purpose                --  responsible for returning tax category for project type
---------------------------------------------------------------------------------------------------------------

    procedure get_project_tax_category
           (
               pn_project_id      in  pa_draft_invoices_all.project_id%type ,
                     pn_draft_invoice_num   in  pa_draft_invoices_all.draft_invoice_num%type ,
               pn_line_num      in      pa_draft_invoice_items.line_num%type ,
                                       pn_tax_category_id out nocopy JAI_CMN_TAX_CTGS_ALL.tax_category_id%type  ,
               pv_process_status out nocopy varchar2 ,
                           pv_process_message   out nocopy varchar2,
               pv_process_flag      out nocopy varchar2
            );

---------------------------------------------------------------------------------------------------------------
--  procedure name         --  get_cust_tax_category
--- purpose                --  responsible for returning tax category for customer - site or customer - null site combination
---------------------------------------------------------------------------------------------------------------

    procedure get_cust_tax_category
           (   pn_project_id      in  pa_draft_invoices_all.project_id%type ,
                     pn_draft_invoice_num   in  pa_draft_invoices_all.draft_invoice_num%type ,
               pn_line_num      in      pa_draft_invoice_items.line_num%type ,
                                       pn_tax_category_id out nocopy JAI_CMN_TAX_CTGS_ALL.tax_category_id%type  ,
               pv_process_status out nocopy varchar2 ,
               pv_process_message   out nocopy varchar2,
               pv_process_flag      out nocopy varchar2
            );
---------------------------------------------------------------------------------------------------------------
--  procedure name         --  get_expn_tax_category
--- purpose                --  responsible for returning tax category for expenditure type
---------------------------------------------------------------------------------------------------------------
    procedure get_expn_tax_category
           (   pn_project_id      in  pa_draft_invoices_all.project_id%type ,
                     pn_draft_invoice_num   in  pa_draft_invoices_all.draft_invoice_num%type ,
               pn_line_num      in      pa_draft_invoice_items.line_num%type ,
                                       pn_tax_category_id out nocopy JAI_CMN_TAX_CTGS_ALL.tax_category_id%type  ,
               pv_process_status out nocopy varchar2 ,
               pv_process_message   out nocopy varchar2,
               pv_process_flag      out nocopy varchar2
            );
---------------------------------------------------------------------------------------------------------------
--  procedure name         --  insert_line_info
--- purpose                --  responsible for inserting information in to india localizations tables
---------------------------------------------------------------------------------------------------------------
    procedure insert_line_info     (
                                       r_new        in     pa_draft_invoice_items%rowtype,
               pn_tax_category_id   in     JAI_CMN_TAX_CTGS_ALL.tax_category_id%type  ,
               pv_action      in         varchar2,
               pn_draft_invoice_id out nocopy jai_pa_draft_invoice_lines.draft_invoice_id%type      ,
               pn_draft_invoice_line_id out nocopy jai_pa_draft_invoice_lines.draft_invoice_line_id%type ,
               pv_process_message   out nocopy varchar2,
               pv_process_flag      out nocopy varchar2
                                   ) ;
---------------------------------------------------------------------------------------------------------------
--  procedure name         --  default_taxes
--- purpose                --  responsible for defaulting of taxes  ..............
---------------------------------------------------------------------------------------------------------------
     procedure default_taxes      (
          pn_tax_category_id              number  ,
          pn_draft_invoice_id             number  ,
          pn_draft_invoice_line_id        number  ,
          pn_line_amount      number  ,
          pv_called_from       varchar2 default null,
          pn_tax_amount   out nocopy number  ,
          pv_process_message  out nocopy varchar2,
                pv_process_flag   out nocopy varchar2
                                  )  ;

------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------
--  procedure name         --  sync_deletion
--- purpose                --  responsible for sync. of draft invoice deletion in projects    ..............
---------------------------------------------------------------------------------------------------------------
     procedure sync_deletion      (
          pn_project_id                   number  ,
          pn_draft_invoice_num            number  ,
          pv_process_message  out nocopy varchar2,
                pv_process_flag   out nocopy varchar2
                                  )  ;

------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------
--  procedure name         --  initialize_variable
--- purpose                --  responsible for initilize for global package variable    ..............
---------------------------------------------------------------------------------------------------------------
     procedure initialize_variable ( pn_project_id                   number ,
             pn_draft_invoice_num            number ,
             pv_process_message out nocopy varchar2,
             pv_process_flag    out nocopy varchar2  );
------------------------------------------------------------------------------------------------------------------

END jai_pa_tax_pkg;
 

/
