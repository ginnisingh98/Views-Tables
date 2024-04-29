--------------------------------------------------------
--  DDL for Package PAY_REVERSE_PAYROLL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_REVERSE_PAYROLL_PKG" AUTHID CURRENT_USER AS
/* $Header: pypra03t.pkh 115.0 99/07/17 06:26:12 porting ship $ */

   PROCEDURE INSERT_ROW(P_ACTION_TYPE                    VARCHAR2,
			P_BUSINESS_GROUP_ID              NUMBER,
                        P_CONSOLIDATION_SET_ID           NUMBER,
			P_PAYROLL_ID			 NUMBER,
		        P_ACTION_POPULATION_STATUS       VARCHAR2,
			P_ACTION_STATUS                  VARCHAR2,
			P_EFFECTIVE_DATE                 DATE,
			P_ASSIGNMENT_ACTION_ID           NUMBER);


END PAY_REVERSE_PAYROLL_PKG;

 

/
