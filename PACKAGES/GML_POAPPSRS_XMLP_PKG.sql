--------------------------------------------------------
--  DDL for Package GML_POAPPSRS_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GML_POAPPSRS_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: POAPPSRSS.pls 120.0 2007/12/24 13:28:19 nchinnam noship $ */
  P_ORGN_CODE VARCHAR2(4);

  P_PO_NO_FROM NUMBER;

  P_PO_NO_TO NUMBER;

  P_RECV_DATE_FROM DATE;

  P_RECV_DATE_TO DATE;

  P_VENDOR_NO_FROM VARCHAR2(32);

  P_VENDOR_NO_TO VARCHAR2(32);

  P_RECV_NO_FROM NUMBER;

  P_RECV_NO_TO NUMBER;

  P_WHSE_CODE_FROM VARCHAR2(4);

  P_WHSE_CODE_TO VARCHAR2(4);

  PARAM_WHERE_CLAUSE VARCHAR2(1500);

  P_USER_ID VARCHAR2(32);

  NONBLOCKSQK VARCHAR2(5);

  P_CHAR VARCHAR2(240);

  P_CONC_REQUEST_ID NUMBER;

  FUNCTION AFTERPFORM RETURN BOOLEAN;

  FUNCTION BEFOREREPORT RETURN BOOLEAN;

  FUNCTION AFTERREPORT RETURN BOOLEAN;

  PRN_ROWS NUMBER;
  F_recv_no_from varchar2(100);
  F_recv_no_to varchar2(100);
  F_po_no_from varchar2(100);
  F_po_no_to varchar2(100);

  function F_recv_no_fromFormatTrigger return varchar2;
  function F_recv_no_toFormatTrigger return varchar2;
  function F_po_no_fromFormatTrigger return varchar2;
  function F_po_no_toFormatTrigger return varchar2;

END GML_POAPPSRS_XMLP_PKG;


/
