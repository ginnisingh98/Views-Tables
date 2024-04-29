--------------------------------------------------------
--  DDL for Package HXC_APPROVAL_STYLES_BK_1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_APPROVAL_STYLES_BK_1" AUTHID CURRENT_USER as
/* $Header: hxchasapi.pkh 120.1 2006/06/08 14:47:44 gsirigin noship $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------<create_approval_styles_b >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_approval_styles_b
  (p_approval_style_id             in     number
  ,p_object_version_number         in     number
  ,p_name                          in     varchar2
  ,p_business_group_id		   in     number
  ,p_legislation_code		   in     varchar2
  ,p_description                   in     varchar2
  ,p_run_recipient_extensions      in     varchar2
  ,p_admin_role                    in     varchar2
  ,p_error_admin_role              in     varchar2
--  ,p_effective_date                in     date
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_approval_styles_a >---------------------|
-- ----------------------------------------------------------------------------
--
procedure create_approval_styles_a
  (p_approval_style_id             in     number
  ,p_object_version_number         in     number
  ,p_name                          in     varchar2
  ,p_business_group_id		   in     number
  ,p_legislation_code		   in     varchar2
  ,p_description                   in     varchar2
  ,p_run_recipient_extensions      in     varchar2
  ,p_admin_role                    in     varchar2
  ,p_error_admin_role              in     varchar2
--  ,p_effective_date                in     date
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_approval_styles_b >------------------|
-- ----------------------------------------------------------------------------
--
procedure update_approval_styles_b
  (p_approval_style_id             in     number
  ,p_object_version_number         in     number
  ,p_name                          in     varchar2
  ,p_business_group_id		   in     number
  ,p_legislation_code		   in     varchar2
  ,p_description                   in     varchar2
  ,p_run_recipient_extensions      in     varchar2
  ,p_admin_role                    in     varchar2
  ,p_error_admin_role              in     varchar2
 -- ,p_effective_date                in     date
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< update_approval_styles_a >---------------------|
-- ----------------------------------------------------------------------------
--
procedure update_approval_styles_a
  (p_approval_style_id             in     number
  ,p_object_version_number         in     number
  ,p_name                          in     varchar2
  ,p_business_group_id		   in     number
  ,p_legislation_code		   in     varchar2
  ,p_description                   in     varchar2
  ,p_run_recipient_extensions      in     varchar2
  ,p_admin_role                    in     varchar2
  ,p_error_admin_role              in     varchar2
  --,p_effective_date                in     date
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_approval_styles_b >---------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_approval_styles_b
  (p_approval_style_id              in  number
  ,p_object_version_number          in  number
  );
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_approval_styles_a >---------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_approval_styles_a
  (p_approval_style_id              in  number
  ,p_object_version_number          in  number
  );
--
end hxc_approval_styles_bk_1;

 

/
