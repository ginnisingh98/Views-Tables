--------------------------------------------------------
--  DDL for Package AME_ACF_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AME_ACF_RKD" AUTHID CURRENT_USER as
/* $Header: amacfrhi.pkh 120.0.12000000.1 2007/01/17 23:31:45 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_delete
  (p_effective_date               in date
  ,p_datetrack_mode               in varchar2
  ,p_validation_start_date        in date
  ,p_validation_end_date          in date
  ,p_application_id               in number
  ,p_action_type_id               in number
  ,p_start_date                   in date
  ,p_end_date                     in date
  ,p_voting_regime_o              in varchar2
  ,p_order_number_o               in number
  ,p_chain_ordering_mode_o        in varchar2
  ,p_start_date_o                 in date
  ,p_end_date_o                   in date
  ,p_object_version_number_o      in number
  );
--
end ame_acf_rkd;

 

/
