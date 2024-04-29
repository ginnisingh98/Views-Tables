--------------------------------------------------------
--  DDL for Package OTA_LP_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_LP_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: otalpxmlp.pkh 120.0.12010000.2 2009/09/23 09:27:05 pekasi noship $ */

  P_LP_ID varchar2(40);
  P_LEARNER_ID varchar2(40);
  P_LP_STATUS_CODE varchar2(40);

  C_LP_NAME varchar2(80);
  C_LEARNER_NAME varchar2(240);
  C_LP_STATUS varchar2(80);

  Function C_LP_NAME_p return varchar2;
  Function C_LEARNER_NAME_p return varchar2;
  Function C_LP_STATUS_p return varchar2;
  Function AfterPForm return BOOLEAN;

END ota_lp_xmlp_pkg;


/
