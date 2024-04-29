--------------------------------------------------------
--  DDL for Package AME_ATTRIBUTE_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AME_ATTRIBUTE_BK1" AUTHID CURRENT_USER as
/* $Header: amatrapi.pkh 120.3.12010000.2 2019/09/12 12:02:21 jaakhtar ship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------< <create_ame_attribute_b >--------------------|
-- ----------------------------------------------------------------------------
--
procedure create_ame_attribute_b
  (p_name                          in     varchar2
  ,p_description                   in     varchar2
  ,p_attribute_type                in     varchar2
  ,p_item_class_id                 in     number
  ,p_approver_type_id              in     number
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_ame_attribute_a >---------------------|
-- ----------------------------------------------------------------------------
--
procedure create_ame_attribute_a
  (p_name                          in     varchar2
  ,p_description                   in     varchar2
  ,p_attribute_type                in     varchar2
  ,p_item_class_id                 in     number
  ,p_approver_type_id              in     number
  ,p_attribute_id                  in     number
  ,p_atr_object_version_number     in     number
  ,p_atr_start_date                in     date
  ,p_atr_end_date                      in     date
  );
--
--
end ame_attribute_bk1;

/
