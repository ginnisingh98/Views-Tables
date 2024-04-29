--------------------------------------------------------
--  DDL for Package AME_ITEM_CLASS_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AME_ITEM_CLASS_BK1" AUTHID CURRENT_USER as
/* $Header: amitcapi.pkh 120.3 2006/05/05 00:22 avarri noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------< create_ame_item_class_b >-------------------------|
-- ----------------------------------------------------------------------------
--
Procedure create_ame_item_class_b
                        (p_name                    in         varchar2
                        );
--
-- ----------------------------------------------------------------------------
-- |----------------------< create_ame_item_class_a >-------------------------|
-- ----------------------------------------------------------------------------
--
Procedure create_ame_item_class_a
                        (p_name                    in    varchar2
                        ,p_item_class_id           in    number
                        ,p_object_version_number   in    number
                        ,p_start_date              in    date
                        ,p_end_date                in    date
                        );
--
end ame_item_class_bk1;

 

/
