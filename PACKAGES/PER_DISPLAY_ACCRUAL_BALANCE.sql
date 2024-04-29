--------------------------------------------------------
--  DDL for Package PER_DISPLAY_ACCRUAL_BALANCE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_DISPLAY_ACCRUAL_BALANCE" AUTHID CURRENT_USER AS
/* $Header: peraccbal.pkh 120.3.12010000.2 2008/09/02 08:23:37 amunsi ship $ */

PROCEDURE GET_ACCRUAL_BALANCES(P_RESOURCE_ID IN NUMBER,
                               P_ELEMENT_SET_ID IN NUMBER,
			       P_EVALUATION_FUNCTION IN VARCHAR2,
                               P_EVALUATION_DATE IN DATE ,
			       P_ACCRUAL_BALANCE_TABLE OUT NOCOPY PER_ACCRUAL_BALANCE_TABLE_TYPE,
			       p_error_message OUT NOCOPY VARCHAR2);

function IsTerminatedEmployee(p_resource_id IN NUMBER,
                      p_evaluation_date IN DATE)
return varchar2;
PROCEDURE GET_ACCRUAL_BALANCES(P_RESOURCE_ID IN NUMBER,
                               P_EVALUATION_FUNCTION IN VARCHAR2,
                               P_EVALUATION_DATE IN DATE ,
                               P_ACCRUAL_BALANCE_TABLE OUT NOCOPY PER_ACCRUAL_BALANCE_TABLE_TYPE);
END PER_DISPLAY_ACCRUAL_BALANCE;

/
