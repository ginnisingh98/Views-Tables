--------------------------------------------------------
--  DDL for Package AME_ACF_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AME_ACF_RKI" AUTHID CURRENT_USER as
/* $Header: amacfrhi.pkh 120.0.12000000.1 2007/01/17 23:31:45 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_effective_date               in date
  ,p_validation_start_date        in date
  ,p_validation_end_date          in date
  ,p_application_id               in number
  ,p_action_type_id               in number
  ,p_voting_regime                in varchar2
  ,p_order_number                 in number
  ,p_chain_ordering_mode          in varchar2
  ,p_start_date                   in date
  ,p_end_date                     in date
  ,p_object_version_number        in number
  );
end ame_acf_rki;

 

/
