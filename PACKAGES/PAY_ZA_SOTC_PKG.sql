--------------------------------------------------------
--  DDL for Package PAY_ZA_SOTC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_ZA_SOTC_PKG" AUTHID CURRENT_USER AS
/* $Header: PYZASOTC.pkh 120.0.12010000.1 2009/11/27 10:42:15 dwkrishn noship $ */

P_BUSINESS_GROUP_ID  number;
P_LEGAL_ENTITY_ID    number;
P_TAX_YEAR           number;
P_PAYROLL_ACTION_ID  number;

C_PAYROLL_ACTION_ID  varchar2(2000);

CP_BG_NAME           varchar2(100);
CP_LE_NAME           varchar2(100);
CP_TAX_REF           varchar2(100);
CP_TAX_YEAR          number;
CP_PAYROLL_ACTION_ID varchar2(100);

CP_FIRST_CERT_NUM    varchar2(100);
CP_LAST_CERT_NUM     varchar2(100);
CP_CERT_COUNT        number;
CP_MAN_CERT_COUNT    number;

FUNCTION BEFOREREPORT RETURN BOOLEAN;

END PAY_ZA_SOTC_PKG;

/
