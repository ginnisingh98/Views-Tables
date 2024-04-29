--------------------------------------------------------
--  DDL for Package Body OKL_FORMULAFUNCTION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_FORMULAFUNCTION_PVT" AS
/* $Header: OKLRFNCB.pls 115.2 2002/02/18 20:16:17 pkm ship       $ */


-- Start of comments
--
-- Function Name  : GET_TAX_VALUE
-- Description    :  A sample function.
-- Business Rules :
-- Parameters     :
--			p_contract_id - contract identifier.
--			p_line_id - line identifier.
--	 		Returns a NUMBER.
-- Version        : 1.0
--
-- End of comments

FUNCTION GET_TAX_VALUE(
 p_contract_id IN NUMBER,
 p_line_id IN NUMBER )
RETURN NUMBER
IS
BEGIN

	/** SBALASHA001 -
			INFO:
				This is a sample function to demonstrate
			        and to help developers to implement formula
				functions and parameter evaluation in
				formula engine.  Developer may write any
				logic in this function using a CONTRACT ID
				and LINE ID.  This function has to return
				a NUMBER which will be used as a parameter
				value for an Operand function. **/



	RETURN 1;

END GET_TAX_VALUE;

-- Start of comments
--
-- Function Name  : GET_REVENUE_VALUE
-- Description    :  A sample function.
-- Business Rules :
-- Parameters     :
--			p_contract_id - contract identifier.
--			p_line_id - line identifier.
--	 		Returns a NUMBER.
-- Version        : 1.0
--
-- End of comments

FUNCTION GET_REVENUE_VALUE(
 p_contract_id IN NUMBER,
 p_line_id IN NUMBER )
RETURN NUMBER
IS
BEGIN

	/** SBALASHA001 -
			INFO:
				This is a sample function to demonstrate
			        and to help developers to implement formula
				functions and parameter evaluation in
				formula engine.  Developer may write any
				logic in this function using a CONTRACT ID
				and LINE ID.  This function has to return
				a NUMBER which will be used as a parameter
				value for an Operand function. **/



	RETURN 1;

END GET_REVENUE_VALUE;

-- Start of comments
--
-- Function Name  : GET_BONUS_VALUE
-- Description    :  A sample function.
-- Business Rules :
-- Parameters     :
--			p_contract_id - contract identifier.
--			p_line_id - line identifier.
--	 		Returns a NUMBER.
-- Version        : 1.0
--
-- End of comments

FUNCTION GET_BONUS_VALUE(
 p_contract_id IN NUMBER,
 p_line_id IN NUMBER )
RETURN NUMBER
IS
BEGIN

	/** SBALASHA001 -
			INFO:
				This is a sample function to demonstrate
			        and to help developers to implement formula
				functions and parameter evaluation in
				formula engine.  Developer may write any
				logic in this function using a CONTRACT ID
				and LINE ID.  This function has to return
				a NUMBER which will be used as a parameter
				value for an Operand function. **/



	RETURN 1;

END GET_BONUS_VALUE;

END OKL_FORMULAFUNCTION_PVT;

/
