--------------------------------------------------------
--  DDL for Package AME_MAN_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AME_MAN_RKD" AUTHID CURRENT_USER as
/* $Header: ammanrhi.pkh 120.0 2005/09/02 04:01 mbocutt noship $ */
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
  ,p_attribute_id                 in number
  ,p_action_type_id               in number
  ,p_start_date                   in date
  ,p_end_date                     in date
  ,p_start_date_o                 in date
  ,p_end_date_o                   in date
  ,p_security_group_id_o          in number
  ,p_object_version_number_o      in number
  );
--
end ame_man_rkd;

 

/
