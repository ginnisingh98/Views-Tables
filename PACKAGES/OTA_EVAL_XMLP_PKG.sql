--------------------------------------------------------
--  DDL for Package OTA_EVAL_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_EVAL_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: otaevalxmlp.pkh 120.2 2008/01/08 10:14:42 aabalakr noship $ */

  P_ACTIVITY_ID varchar2(40);
  P_EVENT_ID varchar2(40);
  P_ANSWER_TYPE varchar2(30);
  P_FROM_DATE varchar2(32767);
  P_TO_DATE varchar2(32767);

  C_ACTIVITY_VERSION_NAME varchar2(80);
  C_EVENT_TITLE varchar2(80);
  C_ANSWER_TYPE varchar2(80);
  C_FROM_DATE varchar2(20);
  C_TO_DATE varchar2(20);

  Function C_ACTIVITY_VERSION_NAME_p return varchar2;
  Function C_EVENT_TITLE_p return varchar2;
  Function C_ANSWER_TYPE_p return varchar2;
  Function C_FROM_DATE_p return varchar2;
  Function C_TO_DATE_p return varchar2;

END ota_eval_xmlp_pkg;


/
