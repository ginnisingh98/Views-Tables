--------------------------------------------------------
--  DDL for Package PAY_SE_GENERAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_SE_GENERAL" AUTHID CURRENT_USER AS
/* $Header: pysegen.pkh 120.1 2006/05/26 20:04:08 rravi noship $ */
 --
 FUNCTION get_tax_card_details
 (p_assignment_id				NUMBER
 ,p_date_earned				IN  DATE
 ,p_tax_card_type         	OUT NOCOPY	VARCHAR2
 ,p_Tax_Percentage		OUT NOCOPY	NUMBER
 ,p_Tax_Table_Number		OUT NOCOPY	NUMBER
 ,p_Tax_Column         		OUT NOCOPY	VARCHAR2
 ,p_Tax_Free_Threshold		OUT NOCOPY	NUMBER
 ,p_Calculation_Code 		OUT NOCOPY	VARCHAR2
 ,p_Calculation_Sum 		OUT NOCOPY	NUMBER

 ) RETURN NUMBER;
 --
  FUNCTION Get_Tax_Amount(
                 p_DATE_EARNED in Date,
                 p_ASSIGNMENT_ID      in Number,
                 p_Period_Type  in varchar2,
                 p_Tax_Table_No in  Number,
                 p_Taxable_Base in  Number,
                 p_Tax_Column   in  Number
                          )
           RETURN Number;

 --
  FUNCTION Get_no_of_payroll
                (
                 p_PAYROLL_ID     in Number,
                 p_EMP_START_DATE in Date,
		 p_CURR_PAY_END_DATE in date
                )
return number;

FUNCTION Get_Absence_Detail(
		p_ASG_Id	IN 	Number,
		p_Effective_date IN	Date,
		p_ASG_Absent_days	IN	Number,
		p_ASG_Absent_hours IN	Number,
		p_Gross_Pay_ASG_Run IN  Number
			   )
		RETURN NUMBER;

END pay_se_general;

/
