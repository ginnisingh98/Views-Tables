--------------------------------------------------------
--  DDL for Package PAY_PL_PERSONAL_PAY_METHOD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_PL_PERSONAL_PAY_METHOD" AUTHID CURRENT_USER as
/* $Header: pyplppmp.pkh 120.0.12010000.2 2009/12/18 10:42:05 bkeshary ship $ */
g_package   VARCHAR2(30);

PROCEDURE CREATE_PL_PERSONAL_PAY_METHOD
(P_SEGMENT1 varchar2
,P_SEGMENT2 varchar2
,P_SEGMENT3 varchar2
,p_SEGMENT12 varchar2
);

PROCEDURE UPDATE_PL_PERSONAL_PAY_METHOD
(P_SEGMENT1 varchar2
,P_SEGMENT2 varchar2
,P_SEGMENT3 varchar2
,P_SEGMENT12 varchar2
,p_personal_payment_method_id number
);
end PAY_PL_PERSONAL_PAY_METHOD;

/
