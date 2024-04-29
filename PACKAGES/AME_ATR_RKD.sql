--------------------------------------------------------
--  DDL for Package AME_ATR_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AME_ATR_RKD" AUTHID CURRENT_USER as
/* $Header: amatrrhi.pkh 120.0 2005/09/02 03:51 mbocutt noship $ */
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
  ,p_start_date                   in date
  ,p_end_date                     in date
  ,p_name_o                       in varchar2
  ,p_attribute_type_o             in varchar2
  ,p_line_item_o                  in varchar2
  ,p_start_date_o                 in date
  ,p_end_date_o                   in date
  ,p_description_o                in varchar2
  ,p_security_group_id_o          in number
  ,p_approver_type_id_o           in number
  ,p_item_class_id_o              in number
  ,p_object_version_number_o      in number
  );
--
end ame_atr_rkd;

 

/
