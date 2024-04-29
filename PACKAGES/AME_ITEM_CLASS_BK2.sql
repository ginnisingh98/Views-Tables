--------------------------------------------------------
--  DDL for Package AME_ITEM_CLASS_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AME_ITEM_CLASS_BK2" AUTHID CURRENT_USER as
/* $Header: amitcapi.pkh 120.3 2006/05/05 00:22 avarri noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------< update_ame_item_class_b >------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_ame_item_class_b
        (p_item_class_id                in     number
        ,p_user_item_class_name         in     varchar2
        ,p_object_version_number        in     number
        );
--
-- ----------------------------------------------------------------------------
-- |-----------------------< update_ame_item_class_a >------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_ame_item_class_a
        (p_item_class_id                in     number
        ,p_object_version_number        in     number
        ,p_user_item_class_name         in     varchar2
        ,p_start_date                   in     date
        ,p_end_date                     in     date
        );
--
end ame_item_class_bk2;

 

/
