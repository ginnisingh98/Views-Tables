--------------------------------------------------------
--  DDL for Package PER_SALADMIN_UTILITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_SALADMIN_UTILITY" AUTHID CURRENT_USER AS
/* $Header: pesalutl.pkh 120.11.12010000.2 2009/12/03 09:29:52 vkodedal ship $ */

-- =============================================================================
-- ~Global variables:
-- =============================================================================
g_proposal_rec per_pay_proposals%ROWTYPE;
g_new_sal_value number;



PROCEDURE get_sal_on_basis_chg
         (p_assignment_id     in number,
          p_new_pay_basis_id  in number,
          p_effective_date    in date,
          p_old_pay_basis_id  in number,
          p_curr_payroll_id   in number);

Procedure adjust_pay_proposals
        (
         p_assignment_id   number
        );

/**
PROCEDURE get_sal_on_basis_chg
         (p_assignment_id in number,
          p_pay_basis_id   in number);
**/
procedure insert_pay_proposal(p_assignment_id in number, p_validation_start_date in date);

  function Check_GSP_Manual_Override(p_assignment_id in NUMBER, p_effective_date in DATE)
  RETURN VARCHAR2;


function get_grd_max_pay(p_assignment_id in NUMBER
                        ,p_business_group_id in NUMBER
                        ,p_effective_date in date)
return number;

function get_grd_min_pay(p_assignment_id in NUMBER
                        ,p_business_group_id in NUMBER
                        ,p_effective_date in date)
return number;


FUNCTION get_currency_format (p_assignment_id IN NUMBER, p_change_date IN DATE)
      RETURN VARCHAR2;



FUNCTION get_query_only
return VARCHAR2;

  FUNCTION get_next_sal_review_date(p_assignment_id IN NUMBER,p_change_date IN DATE,p_business_group_id IN NUMBER)
    RETURN DATE;

  FUNCTION get_uom(p_pay_proposal_id IN NUMBER)
      RETURN VARCHAR2;

  Function get_previous_proposal_dt(p_assignment_id IN NUMBER,p_change_date IN DATE)
        return date;



   FUNCTION get_fte (p_assignment_id IN NUMBER, p_effective_date IN DATE)
      RETURN NUMBER;

    FUNCTION GET_ANNUALIZATION_FACTOR(p_assignment_id  NUMBER,p_effective_date DATE)
    RETURN number;

    FUNCTION get_basis_currency_code (p_assignment_id IN NUMBER,p_effective_date IN DATE )
    RETURN VARCHAR2;

   FUNCTION decode_grade_ladder ( p_grade_ladder_id IN NUMBER , p_effective_date IN DATE)
      RETURN VARCHAR2;

   FUNCTION get_annual_salary (
      p_proposed_salary   IN   NUMBER,
      p_assignment_id     IN   NUMBER,
      p_change_date       IN   DATE
   )
      RETURN NUMBER;


FUNCTION get_grade (p_assignment_id IN NUMBER,p_effective_date IN DATE )
RETURN VARCHAR2;

FUNCTION get_grade_currency (p_grade_id  in number,p_rate_id in number,p_effective_date in date,p_business_group_id in number )
RETURN VARCHAR2;

    FUNCTION get_pay_basis_frequency (p_assignment_id IN NUMBER,p_lookup_type IN varchar2,p_lookup_code IN varchar2,p_effective_date IN date  )
    RETURN VARCHAR2;

   FUNCTION get_lookup_desc ( p_lookup_type IN VARCHAR2,p_lookup_code IN VARCHAR2)
   RETURN VARCHAR2;

   FUNCTION get_pay_annualization_factor (p_assignment_id IN NUMBER, p_effective_date IN DATE, p_annualization_factor IN NUMBER, p_pay_basis IN VARCHAR2)
      RETURN NUMBER;

   FUNCTION get_currency (p_assignment_id IN NUMBER, p_change_date IN DATE)
      RETURN VARCHAR2;

   FUNCTION get_pay_basis (p_assignment_id IN NUMBER, p_change_date IN DATE)
      RETURN VARCHAR2;

   FUNCTION get_change_amount (p_assignment_id IN NUMBER,p_proposal_id IN NUMBER,p_proposed_salary in number)
      RETURN NUMBER;

Function get_next_sal_basis_chg_dt(p_assignment_id IN NUMBER, p_from_date IN DATE)
return date;

   FUNCTION get_proposed_salary (p_assignment_id IN NUMBER,p_effective_date IN DATE )
      RETURN NUMBER;

   FUNCTION get_change_percent (p_assignment_id IN NUMBER,p_proposal_id IN NUMBER,p_proposed_salary in number)
      RETURN NUMBER;

   Function get_previous_salary(p_assignment_id IN NUMBER,p_proposal_id in number)
   return number;

   function get_last_payroll_dt(p_assignment_id  NUMBER) RETURN date;

   function get_currency_rate(
		p_from_currency   VARCHAR2,
		p_to_currency     VARCHAR2,
		p_conversion_date DATE,
        p_business_group_id number) return number;

FUNCTION get_fte_factor(p_assignment_id IN NUMBER
                       ,p_effective_date IN DATE)
return NUMBER;

Function asg_pay_proposal_starts_at(p_assignment_id IN NUMBER, p_date in date)
return varchar2;

Function get_initial_proposal_start(p_assignment_id IN NUMBER)
return date;

function get_assignment_fte(p_assignment_id number, p_effective_date date) return number;

   FUNCTION get_basis_lookup (p_assignment_id IN NUMBER, p_change_date IN DATE)
      RETURN VARCHAR2;

FUNCTION get_pay_basis_id(p_assignment_id IN NUMBER, p_from_date IN DATE)
  RETURN NUMBER;

Function get_asg_sal_basis_end_dt(p_assignment_id IN NUMBER, p_from_date IN DATE)
return date;

function get_next_proposal_with_comp(p_assignment_id in number,
p_session_date in date)
return date;

------
----------called from core HR on Criteria change
-------
procedure handle_asg_crit_change
            (p_assignment_id     in number,
             p_effective_date    in date);

END PER_SALADMIN_UTILITY;


/
