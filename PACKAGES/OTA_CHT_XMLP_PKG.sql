--------------------------------------------------------
--  DDL for Package OTA_CHT_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_CHT_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: otachttxmlp.pkh 120.1 2008/01/08 10:13:34 aabalakr noship $ */

  P_MESSAGE_START_DATE varchar2(32767);
  P_MESSAGE_END_DATE varchar2(32767);
  P_CHAT_ID varchar2(40);
  P_TYPE varchar2(30);

  C_CHAT_NAME varchar2(80);
  C_CHAT_CONTENT_TYPE varchar2(80);
  C_FROM_DATE varchar2(20);
  C_TO_DATE varchar2(20);


  Function C_CHAT_NAME_p return varchar2;
  Function C_CHAT_CONTENT_TYPE_p return varchar2;
  Function C_FROM_DATE_p return varchar2;
  Function C_TO_DATE_p return varchar2;

END ota_cht_xmlp_pkg;


/
