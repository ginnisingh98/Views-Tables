--------------------------------------------------------
--  DDL for Package AME_ACA_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AME_ACA_RKD" AUTHID CURRENT_USER as
/* $Header: amacarhi.pkh 120.0 2005/09/02 03:47 mbocutt noship $ */
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
  ,p_start_date                   in date
  ,p_end_date                     in date
  ,p_fnd_application_id_o         in number
  ,p_application_name_o           in varchar2
  ,p_transaction_type_id_o        in varchar2
  ,p_line_item_id_query_o         in varchar2
  ,p_start_date_o                 in date
  ,p_end_date_o                   in date
  ,p_security_group_id_o          in number
  ,p_object_version_number_o      in number
  );
--
end ame_aca_rkd;

 

/
