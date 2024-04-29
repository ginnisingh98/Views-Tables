--------------------------------------------------------
--  DDL for Package OKS_CODE_HOOK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKS_CODE_HOOK" AUTHID CURRENT_USER AS
/* $Header: OKSCCHKS.pls 120.0.12010000.5 2009/06/12 08:57:30 cgopinee noship $ */

/* PROCEDURE
 tax_trx_date     This routine is used to set a Transaction Date to calculate tax.

 INPUT PARAMETERS
 p_chr_id         Contract Header Id
 p_cle_id         Contract Line Id
 p_hdr_start_date Contract Header Start Date
 p_lin_start_date Contract Line   Start Date

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
 );

 /*added for bug7668259*/
/*Procedure
 billing_interface_st_date  This routine is a client extension that lets the user
                            have different approach while running service contracts
                            main billing program.

 PARAMETERS

 RETURN VALUE
 x_hook          1   Hook has been used
                 0   Hook has not been used
                -1   Error in Hook
 x_date              Billing Interface Start Date
 x_hint              Type of Parallel Thread Processing
                     Only Value allowed is "FULL"*/

 PROCEDURE billing_interface_st_date
 (x_hook OUT NOCOPY NUMBER,
  x_date OUT NOCOPY DATE,
  x_hint OUT NOCOPY VARCHAR2);

 /* Added by sjanakir for Bug# 5073827 */
 /* PROCEDURE
 calc_header_amt     This routine is a client extension that lets the user have
                     different approach for calculating header amount and header tax.

 PARAMETERS
 p_contract_id       Contract Header Id

 RETURN VALUE
 x_hook          1   Hook has been used
                 0   Hook has not been used
                -1   Error in Hook
 x_tax               Header Tax Amount
 x_total             Total Contract Header Amount */

 PROCEDURE calc_header_amt
 (p_contract_id	IN  NUMBER,
  x_hook         OUT NOCOPY NUMBER,
  x_tax          OUT NOCOPY NUMBER,
  x_total        OUT NOCOPY NUMBER);

/* Added by cgopinee for bug #7687114
/* FUNCTION
custom_function  This function can be used to derive any custom data specific to a contract.

INPUT PARAMETERS
p_chr_id         Contract Header Id

RETURN VALUE
l_custom_value    custom data to be derived by the customer.
*/

FUNCTION custom_function
(p_chr_id          IN NUMBER
)Return VARCHAR2;

END oks_code_hook;


/
