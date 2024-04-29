--------------------------------------------------------
--  DDL for Package PAY_GET_TAX_EXISTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_GET_TAX_EXISTS_PKG" AUTHID CURRENT_USER AS
/* $Header: pytaxexi.pkh 120.5.12010000.2 2009/09/03 15:43:26 tclewis ship $ */


TYPE balance_record IS RECORD
 (jurisdiction_code  varchar2(11),
  location           varchar2(12),
  balance_name       varchar2(30),
  amount             number);

TYPE balance_table IS TABLE OF balance_record INDEX BY BINARY_INTEGER;

tax_balances balance_table;

FUNCTION store_pretax_redns
        (p_juri_code          IN varchar2,
         p_tax_type           IN varchar2,
         p_mode               IN varchar2,
         p_125_redns          IN OUT NOCOPY number,
         p_401_redns          IN OUT NOCOPY number,
         p_403_redns          IN OUT NOCOPY number,
         p_457_redns          IN OUT NOCOPY number,
         p_dep_care_redns     IN OUT NOCOPY number,
         p_other_pretax_redns IN OUT NOCOPY number,
         p_gross              IN OUT NOCOPY number,
         p_subj_nwhable       IN OUT NOCOPY number,
         p_location           IN varchar2,
         p_reduced_subj       IN number,
         p_subj               IN number)
RETURN number;

FUNCTION get_stored_balance
        (p_juri_code          IN varchar2,
         p_balance_name       IN varchar2,
         p_location           IN varchar2)
RETURN number;

PROCEDURE reset_stored_balance
        (p_juri_code          IN varchar2,
         p_balance_name       IN varchar2,
         p_location           IN varchar2);

FUNCTION  get_wage_accum_rule
        (p_juri_code   IN varchar2,
         p_date_earned IN date,
         p_tax_unit_id IN number,
         p_assign_id   IN number,
   	 p_pact_id     IN number,
         p_type        IN varchar2,
         p_wage_accum  IN varchar2)
RETURN varchar2;

FUNCTION get_wage_accumulation_flag
         (p_pact_id     IN number)
RETURN varchar2;

FUNCTION  get_tax_exists (p_juri_code   IN VARCHAR2,
                          p_date_earned IN DATE,
                          p_tax_unit_id IN NUMBER,
                          p_assign_id   IN NUMBER,
                          p_type        IN VARCHAR2
                          )  RETURN VARCHAR2;

FUNCTION  get_tax_exists
		(
		p_juri_code IN varchar2,
		p_date_earned IN date,
		p_tax_unit_id IN number,
		p_assign_id   IN number,
		p_pact_id     IN number,
		p_type IN varchar2
		)
 		RETURN varchar2;

FUNCTION  get_tax_exists
        (
        p_juri_code IN varchar2,
        p_date_earned IN date,
        p_tax_unit_id IN number,
        p_assign_id   IN number,
	p_pact_id     IN number,
        p_type IN varchar2,
        p_call IN varchar2)
        RETURN varchar2;

FUNCTION  check_tax_exists
		(
		p_date_earned IN date,
		p_tax_unit_id IN number,
		p_assign_id   IN number,
                p_pact_id     IN number,
		p_juri_code IN varchar2,
		p_type IN varchar2
		)
 		RETURN varchar2;

end pay_get_tax_exists_pkg;

/
