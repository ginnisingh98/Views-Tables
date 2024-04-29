--------------------------------------------------------
--  DDL for Package AME_GCF_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AME_GCF_RKU" AUTHID CURRENT_USER as
/* $Header: amgcfrhi.pkh 120.0 2005/09/02 03:59 mbocutt noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_update
  (p_effective_date               in date
  ,p_datetrack_mode               in varchar2
  ,p_validation_start_date        in date
  ,p_validation_end_date          in date
  ,p_application_id               in number
  ,p_approval_group_id            in number
  ,p_voting_regime                in varchar2
  ,p_order_number                 in number
  ,p_start_date                   in date
  ,p_end_date                     in date
  ,p_object_version_number        in number
  ,p_voting_regime_o              in varchar2
  ,p_order_number_o               in number
  ,p_start_date_o                 in date
  ,p_end_date_o                   in date
  ,p_object_version_number_o      in number
  );
--
end ame_gcf_rku;

 

/
