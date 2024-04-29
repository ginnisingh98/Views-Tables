--------------------------------------------------------
--  DDL for Package AME_ITEM_CLASS_BK5
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AME_ITEM_CLASS_BK5" AUTHID CURRENT_USER as
/* $Header: amitcapi.pkh 120.3 2006/05/05 00:22 avarri noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------< update_ame_item_class_usage_b >--------------------|
-- ----------------------------------------------------------------------------
--
procedure update_ame_item_class_usage_b
          (p_application_id               in     number
          ,p_item_class_id                in     number
          ,p_object_version_number        in     number
          ,p_item_id_query                in     varchar2
          ,p_item_class_order_number      in     number
          ,p_item_class_par_mode          in     varchar2
          ,p_item_class_sublist_mode      in     varchar2
          );
--
-- ----------------------------------------------------------------------------
-- |---------------------< update_ame_item_class_usage_a >--------------------|
-- ----------------------------------------------------------------------------
--
procedure update_ame_item_class_usage_a
          (p_application_id               in  number
          ,p_item_class_id                in  number
          ,p_object_version_number        in  number
          ,p_item_id_query                in  varchar2
          ,p_item_class_order_number      in  number
          ,p_item_class_par_mode          in  varchar2
          ,p_item_class_sublist_mode      in  varchar2
          ,p_start_date                   in  date
          ,p_end_date                     in  date
          );
--
end ame_item_class_bk5;

 

/
