--------------------------------------------------------
--  DDL for Package AME_ITEM_CLASS_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AME_ITEM_CLASS_BK3" AUTHID CURRENT_USER as
/* $Header: amitcapi.pkh 120.3 2006/05/05 00:22 avarri noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------< delete_ame_item_class_b >------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_ame_item_class_b
                         (p_item_class_id             in    number
                         ,p_object_version_number     in    number
                         );
--
-- ----------------------------------------------------------------------------
-- |-----------------------< delete_ame_item_class_a >------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_ame_item_class_a
                         (p_item_class_id            in  number
                         ,p_object_version_number    in  number
                         ,p_start_date               in  date
                         ,p_end_date                 in  date
                          );
--
end ame_item_class_bk3;

 

/
