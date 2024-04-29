--------------------------------------------------------
--  DDL for Package Body OKS_CODE_HOOK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKS_CODE_HOOK" AS
/* $Header: OKSCCHKB.pls 120.0.12010000.5 2009/06/12 08:54:05 cgopinee noship $ */

/* PROCEDURE
tax_trx_date    This routine is used to set a Transaction Date to calculate tax.

INPUT PARAMETERS
p_chr_id         Contract Header Id
p_cle_id         Contract Line Id
p_hdr_start_date Contract Header Start Date
p_lin_start_date Contract Line Start Date

RETURN VALUE
x_hook          1   Hook has been used
                0   Hook has not been used
               -1   Error in Hook
x_date              Transaction Date for calculating tax
*/
PROCEDURE tax_trx_date
(p_chr_id          IN NUMBER,
 p_cle_id          IN NUMBER,
 p_hdr_start_date  IN DATE,
 p_lin_start_date  IN DATE,
 x_hook            OUT NOCOPY NUMBER,
 x_date            OUT NOCOPY DATE
 )
IS

 BEGIN

 x_hook := 0;
 x_date := NULL;

  /* When Input Parameter p_chr_id is NOT NULL and p_cle_id is NULL then tax calculation
     is for contract Header and p_hdr_start_date is contract header start date.

     When Input Parameter p_cle_id is NOT NULL and p_chr_id is NULL then tax calculation
     is for contract Line and p_lin_start_date is contract Line start date.

     Output parameter x_date should be set to the date on which the tax calculation should be based.
     If Hook is used then assign x_hook as 1.

     By Default x_hook = 0 and x_date is NULL Which means transaction date considered for tax
     calculation is contract header/line start date. */

 EXCEPTION
 WHEN OTHERS THEN
  x_hook          :=-1;
 END tax_trx_date;
 /*added for bug7668259*/
 /*----------------------------------------------------------------------------------------+
 Procedure
 billing_interface_st_date  This routine is a client extension that lets the user
                            have different approach while running service contracts
                            main billing program.

 PARAMETERS

 RETURN VALUE
 x_hook          1   Hook has been used
                 0   Hook has not been used
                -1   Error in Hook
 x_date              Billing Interface Start Date
 x_hint              Type of Parallel Processing
                     Only Allowed Value is "FULL".

 x_hint value is used only for the following case.
 Service Contracts Main Billing Program is submitted without providing
 any parameters i.e Main Billing Program Across Operating Units.
 If the customer wants to process the data in FULL Parallel mode; i.e parallel
 processing is used on oks_level_elements table and for contracts header
 and line table.
 x_hint is used by the Main billing Program for across operating units
 only if the value for x_hook is 0,x_date is NULL and x_hint is 'FULL'.

 x_hook and x_date is used by the Service Contracts Main Billing Program
  in following scenarios.
 1) Submitted for across operating units(i.e without providing any parameters).
 2) Submitted for a specific operating unit.
 3) Submitted with a combination of Contract Categry and Org id.
 4) Submitted with a combination of Contract Group and Ord id.
 +-----------------------------------------------------------------------------------------*/

 PROCEDURE billing_interface_st_date
 (x_hook OUT NOCOPY NUMBER,
  x_date OUT NOCOPY DATE,
  x_hint OUT NOCOPY VARCHAR2)
  IS
  BEGIN
    x_hook          := 0;
    x_date          := NULL;
    x_hint          := 'FULL';
   /* To customize this hook, Call the Custom Logic to derive the Billing interface start date
     and pass the start_date to x_date which is passed as an out parameter.If Hook is used
     assign x_hook as 1. This hook is used as part of Service Contract Main Billing program
     in order to filter the data based upon date_interface start and end dates

     x_hint value can be either NULL or FULL based upon the requirement by the customer*/

  EXCEPTION
     WHEN OTHERS THEN
         x_hook          :=-1;
 END billing_interface_st_date;

/* Added by sjanakir for Bug#5073827 */
/* PROCEDURE
calc_header_amt     This routine is a client extension that lets the user have
                    different approach for calculatiog header amount and tax.

PARAMETERS
p_contract_id       Contract Header Id

RETURN VALUE
x_hook          1   Hook has been used
                0   Hook has not been used
               -1   Error in Hook
x_tax               Header Tax Amount
x_total             Total Contract Header Amount */

PROCEDURE calc_header_amt
(p_contract_id IN  NUMBER,
 x_hook        OUT NOCOPY NUMBER,
 x_tax         OUT NOCOPY NUMBER,
 x_total       OUT NOCOPY NUMBER)
IS
BEGIN
	x_hook          := 0;
	x_tax 	        := 0;
	x_total		:= 0;

  /* To customize this hook, Assign x_hook as 1 and Call the Custom Logic to derive the total amount and total
     tax. Output parameters of Custom Logic should be x_total(Total Header Amount) and x_tax (Total Tax).
     By Default x_hook = 0 which means system would follow standard oracle logic to calculate the header amount
     and tax.
  */

EXCEPTION
WHEN OTHERS THEN
	x_hook          :=-1;
END calc_header_amt;

/* added for ER 7687114*/
----------------------------------------------------------------------------------
/* FUNCTION
custom_function  This function will be used to derive custom data specific to a contract

INPUT PARAMETERS
p_chr_id         Contract Header Id

RETURN VALUE
l_custom_value   Custom data to be derived by the customer.
*/
FUNCTION custom_function
(p_chr_id          IN NUMBER
)
Return VARCHAR2 IS

l_custom_value VARCHAR2(200);

BEGIN

l_custom_value := '-99';

/* The customer has to write their own logic to derive the required information based on
   their business needs and populate l_custom_value. Only one value should be passed back
   as return value.

   By default the return value is '-99'.
   */
RETURN  l_custom_value;
EXCEPTION
WHEN OTHERS THEN
     l_custom_value := '-99';
END custom_function;

END oks_code_hook;

/
