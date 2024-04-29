--------------------------------------------------------
--  DDL for Package PAY_ZA_IRP5_IT3A_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_ZA_IRP5_IT3A_XMLP_PKG" AUTHID CURRENT_USER AS
--  /* $Header: pyzairp5.pkh 120.0.12010000.1 2009/12/07 10:34:57 dchindar noship $ */

C_ACTION_CONTEXT_ID varchar2(2000):=' ';
C_PAYROLL_ACTION_ID varchar2(2000):=' ';
C_CERTIFICATE_TYPE  varchar2(10);
C_ASSIGNMENT_NO     varchar2(2000);
C_SORT_ORDER        varchar2(2000):=' ';
P_LEGAL_ENTITY       number;
P_TAX_YEAR           varchar2(10);
P_PAYROLL            number;
P_PAYROLL_ACTION_ID  number;
P_ASSIGNMENT_NO      number;
P_DUMMY_RUN          varchar2(10);
P_REISSUE_IRP5       varchar2(10);
P_SORT_ORDER1        varchar2(10);
P_SORT_ORDER2        varchar2(10);
P_SORT_ORDER3        varchar2(10);
P_SORT_ORDER4        varchar2(10);
P_CERTIFICATE_TYPE   varchar2(10);
P_BUSINESS_GROUP_ID  number;

Function get_parameter
(
   name        in varchar2,
   parameter_list varchar2
)  return varchar2;

Function get_timestamp return number ;

FUNCTION BEFOREREPORT return boolean;

END PAY_ZA_IRP5_IT3A_XMLP_PKG;

/
