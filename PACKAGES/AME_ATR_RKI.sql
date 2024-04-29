--------------------------------------------------------
--  DDL for Package AME_ATR_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AME_ATR_RKI" AUTHID CURRENT_USER as
/* $Header: amatrrhi.pkh 120.0 2005/09/02 03:51 mbocutt noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure after_insert
  (p_effective_date               in date
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
  );
end ame_atr_rki;

 

/
