--------------------------------------------------------
--  DDL for Package HRI_OLTP_DISC_SALARY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HRI_OLTP_DISC_SALARY" AUTHID CURRENT_USER AS
/* $Header: hriodsal.pkh 115.2 2003/04/02 15:07:55 jtitmas noship $ */


FUNCTION get_prev_salary_pro_amount(p_pay_proposal_id   NUMBER)
                RETURN NUMBER;

FUNCTION get_annual_salary_as_of_date(p_effective_date    DATE
                                     ,p_assignment_id     NUMBER)
          RETURN NUMBER;

FUNCTION convert_currency_amount(p_from_currency    IN VARCHAR2
                                ,p_to_currency      IN VARCHAR2
                                ,p_conversion_date  IN DATE
                                ,p_amount           IN NUMBER
                                ,p_precision        IN NUMBER)
            RETURN NUMBER;

FUNCTION convert_currency_amount(p_from_currency    IN VARCHAR2
                                ,p_to_currency      IN VARCHAR2
                                ,p_conversion_date  IN DATE
                                ,p_amount           IN NUMBER
                                ,p_rate_type        IN VARCHAR2)
            RETURN NUMBER;

FUNCTION convert_currency_amount(p_from_currency      IN VARCHAR2,
                                 p_to_currency        IN VARCHAR2,
                                 p_conversion_date    IN DATE,
                                 p_amount             IN NUMBER)
            RETURN NUMBER;

END hri_oltp_disc_salary;

 

/
