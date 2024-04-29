--------------------------------------------------------
--  DDL for Package PQH_VLP_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_VLP_RKU" AUTHID CURRENT_USER as
/* $Header: pqvlprhi.pkh 120.0 2005/05/29 02:56:34 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (p_effective_date               in date
  ,p_validation_period_id         in number
  ,p_validation_id                in number
  ,p_start_date                   in date
  ,p_end_date                     in date
  ,p_previous_employer_id         in number
  ,p_assignment_category	  in varchar2
  ,p_normal_hours                 in number
  ,p_frequency                    in varchar2
  ,p_period_years                 in number
  ,p_period_months                in number
  ,p_period_days                  in number
  ,p_comments                     in varchar2
  ,p_validation_status            in varchar2
  ,p_object_version_number        in number
  ,p_validation_id_o              in number
  ,p_start_date_o                 in date
  ,p_end_date_o                   in date
  ,p_previous_employer_id_o       in number
  ,p_assignment_category_o	  in varchar2
  ,p_normal_hours_o               in number
  ,p_frequency_o                  in varchar2
  ,p_period_years_o               in number
  ,p_period_months_o              in number
  ,p_period_days_o                in number
  ,p_comments_o                   in varchar2
  ,p_validation_status_o          in varchar2
  ,p_object_version_number_o      in number
  );
--
end pqh_vlp_rku;

 

/
