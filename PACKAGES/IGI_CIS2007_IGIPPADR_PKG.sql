--------------------------------------------------------
--  DDL for Package IGI_CIS2007_IGIPPADR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGI_CIS2007_IGIPPADR_PKG" AUTHID CURRENT_USER AS
-- $Header: IGIPPADS.pls 120.0.12000000.2 2007/07/12 12:46:39 vensubra noship $
  P_PERIOD          varchar2(15);
  P_SUPPLIER_FROM   varchar2(240);
  P_SUPPLIER_TO     varchar2(240);
  P_TOTAL_TYPE      varchar2(1);
  P_PRINT_TYPE      varchar2(1);
  P_ZERO_DEDUCTIONS varchar2(1);

  p_select_clause varchar2(32767);
  p_from_clause   varchar2(3000);
  p_where_clause  varchar2(32767);

  function BeforeReport return boolean;
  function get_PRINT_TYPE return varchar2;
  function get_ORG_NAME return varchar2;
  function get_PERIOD_END_DATE return varchar2;

end IGI_CIS2007_IGIPPADR_PKG;

 

/
