--------------------------------------------------------
--  DDL for Package OTA_FRM_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_FRM_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: otafrmxmlp.pkh 120.3 2008/01/08 10:11:05 aabalakr noship $ */

  P_FORUM_ID varchar2(40);
  P_AUTHOR varchar2(40);
  P_MESSAGE varchar2(40);
  P_FROM_DATE varchar2(32767);
  P_TO_DATE varchar2(32767);

  C_FORUM_NAME varchar2(80);
  C_FROM_DATE varchar2(20);
  C_TO_DATE varchar2(20);

  Function C_FORUM_NAME_p return varchar2;
  Function C_FROM_DATE_p return varchar2;
  Function C_TO_DATE_p return varchar2;

END ota_frm_xmlp_pkg;


/
