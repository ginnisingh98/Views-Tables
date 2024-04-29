--------------------------------------------------------
--  DDL for Package AME_ATR_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AME_ATR_RKU" AUTHID CURRENT_USER as
/* $Header: amatrrhi.pkh 120.0 2005/09/02 03:51 mbocutt noship $ */
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
  ,p_attribute_id                 in number
  ,p_name                         in varchar2
  ,p_attribute_type               in varchar2
  ,p_line_item                    in varchar2
  ,p_start_date                   in date
  ,p_end_date                     in date
  ,p_description                  in varchar2
  ,p_security_group_id            in number
  ,p_approver_type_id             in number
  ,p_item_class_id                in number
  ,p_object_version_number        in number
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
end ame_atr_rku;

 

/
