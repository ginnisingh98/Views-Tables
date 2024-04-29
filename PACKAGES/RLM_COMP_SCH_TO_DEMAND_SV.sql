--------------------------------------------------------
--  DDL for Package RLM_COMP_SCH_TO_DEMAND_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."RLM_COMP_SCH_TO_DEMAND_SV" AUTHID CURRENT_USER as
/* $Header: RLMCOMDS.pls 115.1 2002/11/25 16:46:59 brana noship $*/

/*===========================================================================
  PACKAGE NAME:   rlm_comp_sch_to_demand_sv

  DESCRIPTION: Contains all server side code for populating the records in the
               temporary table for Compare schedule to demand report.

  CLIENT/SERVER:  Server

  LIBRARY NAME: None

  OWNER:    brana

  PROCEDURE/FUNCTIONS:
         proc_comp_sch_to_demand()
         get_weekly_quantity()
         get_monday_date()
         get_precision ()
 GLOBALS:
    g_SDEBUG
    g_DEBUG


===========================================================================*/
  g_DAY           CONSTANT VARCHAR2(10) := '1';
  g_WEEK          CONSTANT VARCHAR2(10) := '2';
  g_FLEXIBLE      CONSTANT VARCHAR2(10) := '3';
  g_MONTH         CONSTANT VARCHAR2(10) := '4';
  g_QUARTER       CONSTANT VARCHAR2(10) := '5';
  g_SUCCESS       CONSTANT NUMBER := 0;
  g_WARNING       CONSTANT NUMBER := 1;
  g_ERROR         CONSTANT NUMBER := 2;
  g_RaiseErr      CONSTANT NUMBER := -10;

/*===========================================================================
  PROCEDURE NAME: proc_comp_sch_to_demand

  DESCRIPTION:  This is the main procedure which is used for inserting the
                records in the  Temporary Table for the Compare Schedule
                to Demand Report.

  PARAMETERS:             p_schedule_type             IN      VARCHAR2,
                          p_header_id                 IN      NUMBER    :=NULL,
                          p_Customer_name_from        IN      varchar2  :=NULL,
                          p_Customer_name_to          IN      Varchar2  :=NULL,
                          p_ship_from_org_id          IN      NUMBER    :=NULL,
                          p_ship_to                   IN      NUMBER    :=NULL,
                          p_tp_code_from              IN      VARCHAR2  :=NULL,
                          p_tp_code_to                IN      VARCHAR2  :=NULL,
                          p_tp_location_from          IN      VARCHAR2  :=NULL,
                          p_tp_location_to            IN      VARCHAR2  :=NULL,
                          p_process_date_from         IN      VARCHAR2  :=NULL,
                          p_process_date_to           IN      VARCHAR2  :=NULL,
                          p_issue_date_from           IN      VARCHAR2  :=NULL,
                          p_issue_date_to             IN      VARCHAR2  :=NULL,
                          p_request_date_from         IN      VARCHAR2  :=NULL,
                          p_request_date_to           IN      VARCHAR2  :=NULL,
                          p_customer_item_from        IN      VARCHAR2  :=NULL,
                          p_customer_item_to          IN      VARCHAR2  :=NULL,
                          p_internal_item_from        IN      VARCHAR2  :=NULL,
                          p_internal_item_to          IN      VARCHAR2  :=NULL,
                          p_demand_type               IN      VARCHAR2  :=NULL,


 DESIGN REFERENCES: rlmdmddld.rtf

 ALGORITHM:

 NOTES:

 OPEN ISSUES:

 CLOSED ISSUES:

 CHANGE HISTORY: brana 11/15/02  created
===========================================================================*/
PROCEDURE  proc_comp_sch_to_demand
                         (p_schedule_type             IN      VARCHAR2,
                          p_header_id                 IN      NUMBER    :=NULL,
                          p_Customer_name_from        IN      Varchar2   :=NULL,
                          p_Customer_name_to          IN      Varchar2   :=NULL,
                          p_ship_from_org_id          IN      NUMBER    :=NULL,
                          p_ship_to                   IN      NUMBER    :=NULL,
                          p_tp_code_from              IN      VARCHAR2  :=NULL,
                          p_tp_code_to                IN      VARCHAR2  :=NULL,
                          p_tp_location_from          IN      VARCHAR2  :=NULL,
                          p_tp_location_to            IN      VARCHAR2  :=NULL,
                          p_process_date_from         IN      VARCHAR2  :=NULL,
                          p_process_date_to           IN      VARCHAR2  :=NULL,
                          p_issue_date_from           IN      VARCHAR2  :=NULL,
                          p_issue_date_to             IN      VARCHAR2  :=NULL,
                          p_request_date_from         IN      VARCHAR2  :=NULL,
                          p_request_date_to           IN      VARCHAR2  :=NULL,
                          p_customer_item_from        IN      VARCHAR2  :=NULL,
                          p_customer_item_to          IN      VARCHAR2  :=NULL,
                          p_internal_item_from        IN      VARCHAR2  :=NULL,
                          p_internal_item_to          IN      VARCHAR2  :=NULL,
                          p_demand_type               IN      VARCHAR2  :=NULL
                        ) ;


/*===========================================================================
  FUNCTION NAME:  get_monday_date

  DESCRIPTION:  This procedure finds the Monday date for a given week

  PARAMETERS:        P_DATE       IN Date

  DESIGN REFERENCES: rlmdmddld.rtf

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:   BRANA  11/15/02  created
===========================================================================*/
FUNCTION GET_MONDAY_DATE (P_DATE  date)
RETURN  DATE  ;


/*===========================================================================
  FUNCTION NAME:  week_name

  DESCRIPTION:  This procedure finds the Monday date for the given week

  PARAMETERS:        v_week_number       IN Number

  DESIGN REFERENCES: rlmdmddld.rtf

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:    BRANA 11/15/02  created
===========================================================================*/
 Function Get_week_Name(v_week_number in NUMBER)
 RETURN VARCHAR2 ;

END RLM_COMP_SCH_TO_DEMAND_SV;

 

/
