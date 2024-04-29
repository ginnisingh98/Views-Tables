--------------------------------------------------------
--  DDL for Package PAY_USER_COLUMN_INSTANCE_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_USER_COLUMN_INSTANCE_BK1" AUTHID CURRENT_USER as
/* $Header: pyuciapi.pkh 120.1 2005/10/02 02:34 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------< create_user_column_instance_b >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_user_column_instance_b
(p_effective_date                in     date
,p_user_row_id                   in     number
,p_user_column_id                in     number
,p_value                         in     varchar2
,p_business_group_id             in     number
,p_legislation_code              in     varchar2
);
--
-- ----------------------------------------------------------------------------
-- |--------------------< create_user_column_instance_a >---------------------|
-- ----------------------------------------------------------------------------
--
procedure create_user_column_instance_a
(p_effective_date                in     date
,p_user_row_id                   in     number
,p_user_column_id                in     number
,p_value                         in     varchar2
,p_business_group_id             in     number
,p_legislation_code              in     varchar2
,p_user_column_instance_id       in     number
,p_object_version_number         in     number
,p_effective_start_date          in     date
,p_effective_end_date            in     date
);
--
end pay_user_column_instance_bk1;

 

/
