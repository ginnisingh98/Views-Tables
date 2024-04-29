--------------------------------------------------------
--  DDL for Package PQH_FR_VALIDATION_PERIODS_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_FR_VALIDATION_PERIODS_BK1" AUTHID CURRENT_USER as
/* $Header: pqvlpapi.pkh 120.1 2005/10/02 02:28:53 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |--------------------------< <Insert_Validation_Period_b> >---------------------|
-- ----------------------------------------------------------------------------
procedure Insert_Validation_Period_b
  (p_effective_date               in     date
  ,p_validation_id                  in     number
  ,p_start_date                     in     date
  ,p_end_date                       in     date
  ,p_previous_employer_id           in     number
  ,p_assignment_category            in     varchar2
  ,p_normal_hours                   in     number
  ,p_frequency                      in     varchar2
  ,p_period_years                   in     number
  ,p_period_months                  in     number
  ,p_period_days                    in     number
  ,p_comments                       in     varchar2
  ,p_validation_status              in     varchar2);

--
-- ----------------------------------------------------------------------------
-- |-------------------------< Insert_Validation_Period_a >-------------------------|
-- ----------------------------------------------------------------------------
--

procedure Insert_Validation_Period_a
  (p_effective_date               in     date
  ,p_validation_id                  in     number
  ,p_start_date                     in     date
  ,p_end_date                       in     date
  ,p_previous_employer_id           in     number
  ,p_assignment_category	    in     varchar2
  ,p_normal_hours                   in     number
  ,p_frequency                      in     varchar2
  ,p_period_years                   in     number
  ,p_period_months                  in     number
  ,p_period_days                    in     number
  ,p_comments                       in     varchar2
  ,p_validation_status              in     varchar2);

 --
end pqh_fr_validation_periods_bk1;

 

/
