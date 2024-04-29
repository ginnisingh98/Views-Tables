--------------------------------------------------------
--  DDL for Package PAY_USER_COLUMN_INSTANCE_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_USER_COLUMN_INSTANCE_BK2" AUTHID CURRENT_USER as
/* $Header: pyuciapi.pkh 120.1 2005/10/02 02:34 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |------------------< update_user_column_instance_b >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure update_user_column_instance_b
(p_effective_date                in     date
,p_user_column_instance_id       in     number
,p_datetrack_update_mode         in     varchar2
,p_value                         in     varchar2
,p_object_version_number         in     number
);
--
-- ----------------------------------------------------------------------------
-- |------------------< update_user_column_instance_a >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure update_user_column_instance_a
(p_effective_date                in     date
,p_user_column_instance_id       in     number
,p_datetrack_update_mode         in     varchar2
,p_value                         in     varchar2
,p_object_version_number         in     number
,p_effective_start_date          in     date
,p_effective_end_date            in     date
);
--
end pay_user_column_instance_bk2;

 

/
