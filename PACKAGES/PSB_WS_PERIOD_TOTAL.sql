--------------------------------------------------------
--  DDL for Package PSB_WS_PERIOD_TOTAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSB_WS_PERIOD_TOTAL" AUTHID CURRENT_USER as
/* $Header: PSBVWPTS.pls 115.8 2002/11/12 11:24:51 msuram ship $ */


  PROCEDURE Get_Totals
  (
    p_worksheet_id               NUMBER,
  --following 1 parameter added for DDSP
    p_profile_worksheet_id       NUMBER,
    p_budget_year_id             NUMBER,
    p_balance_type               VARCHAR2,
    p_user_id                    NUMBER,
    p_template_id                NUMBER,
    p_account_flag               VARCHAR2,
    p_currency_flag              VARCHAR2,
    p_spkg_flag                  VARCHAR2,
    p_spkg_selection_exists      VARCHAR2,
/* Bug No 2543015 Start */
    p_spkg_name                  VARCHAR2,
/* Bug No 2543015 End */
    p_flexfield_low              VARCHAR2,
    p_flexfield_high             VARCHAR2,
    p_flexfield_delimiter        VARCHAR2,
    p_chart_of_accounts          NUMBER,
    p1_amount            OUT  NOCOPY     NUMBER,
    p2_amount            OUT  NOCOPY     NUMBER,
    p3_amount            OUT  NOCOPY     NUMBER,
    p4_amount            OUT  NOCOPY     NUMBER,
    p5_amount            OUT  NOCOPY     NUMBER,
    p6_amount            OUT  NOCOPY     NUMBER,
    p7_amount            OUT  NOCOPY     NUMBER,
    p8_amount            OUT  NOCOPY     NUMBER,
    p9_amount            OUT  NOCOPY     NUMBER,
    p10_amount           OUT  NOCOPY     NUMBER,
    p11_amount           OUT  NOCOPY     NUMBER,
    p12_amount           OUT  NOCOPY     NUMBER,
    p_year_amount        OUT  NOCOPY     NUMBER
  );

 PROCEDURE Get_Data_Selection_Profile
 (
  p_current_worksheet_id   IN  NUMBER,
  p_current_user_id        IN  NUMBER,
  p_global_profile_user_id IN  NUMBER default NULL,
  p_profile_worksheet_id   OUT  NOCOPY NUMBER,
  p_profile_user_id        OUT  NOCOPY NUMBER
 );


END PSB_WS_PERIOD_TOTAL;

 

/
