--------------------------------------------------------
--  DDL for Package OTA_CERT_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_CERT_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: otacertxmlp.pkh 120.2 2008/01/08 10:04:48 aabalakr noship $ */

  P_CERTIFICATION_ID VARCHAR2(40);
  P_LEARNER_NAME VARCHAR2(40);
  P_SUBSCRIPTION_STATUS VARCHAR2(40);
  P_SUBSCRIPTION_START_DATE varchar2(32767);
  P_SUBSCRIPTION_END_DATE varchar2(32767);
  P_EXPIRY_FROM_DATE varchar2(32767);
  P_EXPIRY_TO_DATE varchar2(32767);

  C_CERTIFICATION_NAME varchar2(80);
  C_SUBSCRIPTION_STATUS varchar2(80);
  C_SUBSCRIPTION_START_DATE varchar2(20);
  C_SUBSCRIPTION_END_DATE varchar2(20);
  C_EXPIRY_FROM_DATE varchar2(20);
  C_EXPIRY_TO_DATE varchar2(20);


  Function C_CERTIFICATION_NAME_p return varchar2;
  Function C_SUBSCRIPTION_STATUS_p return varchar2;
  Function C_SUBSCRIPTION_START_DATE_p return varchar2;
  Function C_SUBSCRIPTION_END_DATE_p return varchar2;
  Function C_EXPIRY_FROM_DATE_p return varchar2;
  Function C_EXPIRY_TO_DATE_p return varchar2;


END ota_cert_xmlp_pkg;


/
