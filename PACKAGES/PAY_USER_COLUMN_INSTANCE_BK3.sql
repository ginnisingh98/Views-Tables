--------------------------------------------------------
--  DDL for Package PAY_USER_COLUMN_INSTANCE_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_USER_COLUMN_INSTANCE_BK3" AUTHID CURRENT_USER as
/* $Header: pyuciapi.pkh 120.1 2005/10/02 02:34 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------< delete_user_column_instance_b >--------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_user_column_instance_b
(p_effective_date                in     date
,p_user_column_instance_id       in     number
,p_datetrack_update_mode         in     varchar2
,p_object_version_number         in     number
);
--
-- ----------------------------------------------------------------------------
-- |--------------------< delete_user_column_instance_a >---------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_user_column_instance_a
(p_effective_date                in     date
,p_user_column_instance_id       in     number
,p_datetrack_update_mode         in     varchar2
,p_object_version_number         in     number
,p_effective_start_date          in     date
,p_effective_end_date            in     date
);
--
end pay_user_column_instance_bk3;

 

/
