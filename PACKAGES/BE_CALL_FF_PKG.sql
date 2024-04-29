--------------------------------------------------------
--  DDL for Package BE_CALL_FF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BE_CALL_FF_PKG" AUTHID CURRENT_USER AS
-- $Header: pebeclff.pkh 115.8 2003/02/07 09:52:19 atrivedi noship $
--
-- computes the employee's notice period
--
PROCEDURE calculate_notice_period
( p_service_years           IN NUMBER,
  p_service_months          IN NUMBER,
  p_age_years               IN NUMBER,
  p_age_months              IN NUMBER,
  p_salary                  IN NUMBER,
  p_notice_type             IN VARCHAR2,
  p_derivation_method       IN VARCHAR2,
  p_assignment_id           IN NUMBER,
  p_business_group_id       IN NUMBER,
  p_legislation_code        IN VARCHAR2,
  p_session_date            IN DATE,
  p_notice_period           IN OUT NOCOPY NUMBER,
  p_counter_notice          IN OUT NOCOPY NUMBER,
  p_leave_days              IN OUT NOCOPY VARCHAR2);

--
-- Validates the NI number
--
FUNCTION check_ni
( p_national_identifier     IN VARCHAR2,
  p_birth_date              IN DATE,
  p_gender                  IN VARCHAR2,
  p_event                   IN VARCHAR2,
  p_person_id               IN NUMBER,
  p_business_group_id       IN NUMBER,
  p_legislation_code        IN VARCHAR2 DEFAULT 'BE',
  p_session_date            IN DATE) RETURN VARCHAR2;

end be_call_ff_pkg;


 

/
