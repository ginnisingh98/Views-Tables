--------------------------------------------------------
--  DDL for Package PQH_CGN_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_CGN_RKI" AUTHID CURRENT_USER as
/* $Header: pqcgnrhi.pkh 120.0 2005/05/29 01:43:07 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_effective_date               in date
  ,p_case_group_id                in number
  ,p_case_group_number            in varchar2
  ,p_description                  in varchar2
  ,p_advanced_pay_grade           in number
  ,p_entries_in_minute            in varchar2
  ,p_period_of_prob_advmnt        in number
  ,p_period_of_time_advmnt        in number
  ,p_advancement_to               in number
  ,p_object_version_number        in number
  ,p_advancement_additional_pyt   in number
  ,p_time_advanced_pay_grade      in number
  ,p_time_advancement_to          in number
  ,p_business_group_id            in number
  ,p_time_advn_units              in varchar2
  ,p_prob_advn_units              in varchar2
  ,p_sub_csgrp_description        in varchar2
  );
end pqh_cgn_rki;

 

/
