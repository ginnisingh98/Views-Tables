--------------------------------------------------------
--  DDL for Package PSB_WS_YEAR_TOTAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSB_WS_YEAR_TOTAL" AUTHID CURRENT_USER as
/* $Header: PSBVWYTS.pls 120.2 2005/07/13 11:31:38 shtripat ship $ */



  PROCEDURE Get_Totals
  (
    p_worksheet_id               NUMBER,
  --following 1 parameter addd for DDSP
    p_profile_worksheet_id       NUMBER,
    p_user_id                    NUMBER,
    p_template_id                NUMBER,
    p_account_flag               VARCHAR2,
    p_currency_flag              VARCHAR2,
    p_spkg_flag                  VARCHAR2,
    p_spkg_selection_exists      VARCHAR2,
    p_spkg_name                  VARCHAR2,
    p_flexfield_low              VARCHAR2,
    p_flexfield_high             VARCHAR2,
    p_flexfield_delimiter        VARCHAR2,
    p_chart_of_accounts          NUMBER,
/* Bug No 1328826 Start */
    p_flex_value                 VARCHAR2 default null,
/* Bug No 1328826 End */
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
    p12_amount           OUT  NOCOPY     NUMBER
  );
/* Bug No 667777 Start */
 PROCEDURE Position_Totals
 (
  pworksheet_id                 number,
--following 1 parameter added for DDSP
  pprofile_worksheet_id         number,
  pposition_line_id             number,
  paccount_flag                 varchar2,
  pcurrency_flag                varchar2,
  pservice_package_flag         varchar2,
  pselection_exists             varchar2,
  puser_id                      number,
  pchart_of_accounts_id         number   default null,
  pspkg_name                    varchar2,
  pflex_value                   varchar2,
  ptcolumn1             OUT  NOCOPY     number,
  ptcolumn2             OUT  NOCOPY     number,
  ptcolumn3             OUT  NOCOPY     number,
  ptcolumn4             OUT  NOCOPY     number,
  ptcolumn5             OUT  NOCOPY     number,
  ptcolumn6             OUT  NOCOPY     number,
  ptcolumn7             OUT  NOCOPY     number,
  ptcolumn8             OUT  NOCOPY     number,
  ptcolumn9             OUT  NOCOPY     number,
  ptcolumn10            OUT  NOCOPY     number,
  ptcolumn11            OUT  NOCOPY     number,
  ptcolumn12            OUT  NOCOPY     number
 );
/* Bug No 667777 End */


END PSB_WS_YEAR_TOTAL;

 

/
