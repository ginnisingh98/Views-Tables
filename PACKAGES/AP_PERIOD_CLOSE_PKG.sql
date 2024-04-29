--------------------------------------------------------
--  DDL for Package AP_PERIOD_CLOSE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_PERIOD_CLOSE_PKG" AUTHID CURRENT_USER as
/* $Header: apprdcls.pls 120.2.12010000.3 2009/01/15 14:06:58 njakkula noship $ */
  /*------------------------------------------------------------------------------------------------------------------------*/
  --  CONSTANTS
  /*------------------------------------------------------------------------------------------------------------------------*/
  G_ACTION_PERIOD_CLOSE                     constant varchar2(30) := 'PERIOD_CLOSE';
  G_ACTION_SWEEP                            constant varchar2(30) := 'SWEEP';
  G_ACTION_UTR                              constant varchar2(30) := 'UNACCT_TRX_REPORT';
  G_ACTION_PCER                             constant varchar2(30) := 'PERIOD_CLOSE_EXCP_REPORT';

  G_SRC_TAB_AP_INV_LINES_ALL                constant varchar2(30) := 'AP_INVOICE_LINES_ALL';
  G_SRC_TAB_AP_INV_DISTS_ALL                constant varchar2(30) := 'AP_INVOICE_DISTRIBUTIONS_ALL';
  G_SRC_TAB_AP_SELF_TAX_DIST_ALL	    constant varchar2(50) := 'AP_SELF_ASSESSED_TAX_DIST_ALL';
  G_SRC_TAB_AP_PMT_HISTORY                  constant varchar2(30) := 'AP_PAYMENT_HISTORY';
  G_SRC_TAB_AP_INV_PAYMENTS                 constant varchar2(30) := 'AP_INVOICE_PAYMENTS';
  G_SRC_TAB_AP_PREPAY_HIST                  constant varchar2(30) := 'AP_PREPAY_HISTORY_ALL';
  --Bug#7649020
  G_SRC_TAB_XLA_AE_HEADERS                  constant varchar2(30) := 'XLA_AE_HEADERS';

  G_SRC_TYP_LINES_WITHOUT_DISTS             constant varchar2 (30) := 'LINES_WITHOUT_DISTS';
  G_SRC_TYP_UNACCT_DISTS                    constant varchar2 (30) := 'UNACCT_DISTS';
  G_SRC_TYP_UNACCT_PMT_HISTORY              constant varchar2 (30) := 'UNACCT_PMT_HISTORY';
  G_SRC_TYP_UNACCT_INV_PMTS                 constant varchar2 (30) := 'UNACCT_INV_PAYMENTS';
  G_SRC_TYP_UNACCT_PREPAY_HIST              constant varchar2 (30) := 'UNACCT_PREPAY_HIST';
  --Bug#7649020
  G_SRC_TYP_UNTRANSFERED_HEADERS            constant varchar2 (30) := 'UNTRANSFERED_HEADERS';
  G_SRC_TYP_OTHER_EXCPS                     constant varchar2 (30) := 'OTHER_EXCEPTIONS';

  G_AP_APPLICATION_ID                       constant number        := 200;
  /*------------------------------------------------------------------------------------------------------------------------*/
  -- GLOBAL DECLARATION
  /*------------------------------------------------------------------------------------------------------------------------*/

  g_ledger_id         ap_system_parameters_all.set_of_books_id%type    ;
  g_org_id            ap_system_parameters_all.org_id%type;
  g_period_name       gl_periods.period_name%type;
  g_period_start_date gl_period_statuses.start_date%type;
  g_period_end_date   gl_period_statuses.end_date%type;
  g_action            varchar2 (30);
  g_sweep_to_period   gl_periods.period_name%type;
  g_sweep_to_date     gl_periods.start_date%type;
  g_sweep_now           varchar2 (1);
  g_reporting_level     number;
  g_reporting_entity_id number (15);

  g_ledger_name       gl_sets_of_books.name%type;
  g_cash_basis_flag   gl_sets_of_books.sla_ledger_cash_basis_flag%type;

  g_debug             varchar2 (1) := 'N';
  g_fetch_limit       number := 1000; -- per Perf Team, this is std limit size.

  g_orphan_message_text FND_NEW_MESSAGES.MESSAGE_TEXT%TYPE := NULL;

  -- Concurrent will pass date in canonical format.  So we will capture
  -- the date as passed by concurrent program in a varchar2 format and
  -- will use canonical_to_date function to conver it to a date
  g_start_date		varchar2 (30);
  g_end_date      varchar2 (30);

  cursor c_get_all_orgs
  is
    select    hou.name             operating_unit_name
            , hou.organization_id  org_id
            , aspa.recon_accounting_flag
            , aspa.when_to_account_pmt
	          , aspa.set_of_books_id
      from    hr_operating_units        hou
             ,ap_system_parameters_all  aspa
      where   aspa.org_id = hou.organization_id
      and    (  ( g_ledger_id is not null and aspa.set_of_books_id = g_ledger_id)
             and (g_org_id is null OR (g_org_id is not null and aspa.org_id = g_org_id))
             )
      and     trunc(sysdate) between hou.date_from and nvl(hou.date_to,trunc(sysdate))
      order by org_id desc;

  /*------------------------------------------------------------------------------------------------------------------------*/
  --  GLOBAL FUNCTIONS/PROCEDURES
  /*------------------------------------------------------------------------------------------------------------------------*/

  --
  -- process_period
  -- the main procedure to process period closing activity.
  -- overall flow is as below:
  --  1.  populate global variables to hold parameter values
  --  2.  derive missing parameters values based on the available parameters
  --  3.  populate ap_org_attributes_gt to hold all the orgs defined for a ledger
  --  4.  validate action (PERIOD_CLOSE, SWEEP, UTR, PCER)
  --  5.  populate the global temp table if action is not PERIOD_CLOSE
  --  6.  based on action either SWEEP or run UTR or PCER reports
  --

  procedure process_period
              ( p_ledger_id         in  number    default null
               ,p_org_id            in  number    default null
               ,p_period_name       in  varchar2  default null
               ,p_period_start_date in  date      default null
               ,p_period_end_date   in  date      default null
               ,p_sweep_to_period   in  varchar2  default null
               ,p_action            in  varchar2
               ,p_debug             in  varchar2 default 'N'
               ,p_process_flag      out nocopy varchar2
               ,p_process_message   out nocopy varchar2
              );

  --
  --  before report trigger for XMLP reports.  XMLP concurrent program will invoke
  --  this method before executing the report queries in that particular data template
  --
  function before_report_apxpcer
  return boolean;

  function before_report_apxuatr
  return boolean;

  --
  -- function to get name of reporting context which can be either a ledger name or operating unit name
  --

  function get_reporting_context
  return varchar2;

  function get_reporting_level_name
  return varchar2;

  --
  --  Checks if all the operating units defined under ledger are accessible
  --  p_process_flag = 'SS' indicates all the operating units for a ledger
  --  are accessible
  --

  procedure check_orgs_for_ledger
            (p_ledger_id in number
            ,p_process_flag out nocopy varchar2
            ,p_process_message out nocopy varchar2
            );



end ap_period_close_pkg;

/
