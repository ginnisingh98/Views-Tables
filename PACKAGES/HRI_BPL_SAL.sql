--------------------------------------------------------
--  DDL for Package HRI_BPL_SAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HRI_BPL_SAL" AUTHID CURRENT_USER AS
/* $Header: hribsal.pkh 120.0 2005/05/29 06:54:26 appldev noship $ */

PROCEDURE fetch_currency_and_salary(p_assignment_id     IN NUMBER,
                                      p_date              IN DATE);
--
FUNCTION get_assignment_sal(p_assignment_id  IN NUMBER,
                            p_date           IN DATE)
          RETURN NUMBER;
--
FUNCTION get_assignment_currency(p_assignment_id  IN NUMBER,
                                 p_date           IN DATE)
          RETURN VARCHAR2;
--
FUNCTION convert_amount(p_from_currency      IN VARCHAR2,
                        p_to_currency        IN VARCHAR2,
                        p_conversion_date    IN DATE,
                        p_amount             IN NUMBER,
                        p_business_group_id  IN NUMBER DEFAULT NULL)
            RETURN NUMBER;
--
FUNCTION convert_amount(p_from_currency      IN VARCHAR2,
                        p_to_currency        IN VARCHAR2,
                        p_conversion_date    IN DATE,
                        p_amount             IN NUMBER,
                        p_rate_type          IN VARCHAR2)
            RETURN NUMBER;
--
-- ----------------------------------------------------------------------------
-- FUNCTION    GET_PERD_ANNUALIZATION_FACTOR
-- ----------------------------------------------------------------------------
-- When the pay basis type is PERIOD then the annualization factor can be null.
-- In such cases the annualization factor is same as the yearly frequency of
-- the payroll. This function returns the annualization factor is such cases.
-- ----------------------------------------------------------------------------
--
FUNCTION get_perd_annualization_factor( p_assignment_id  IN NUMBER,
                                   p_effective_date IN DATE)
RETURN NUMBER;
--
END hri_bpl_sal;

 

/
