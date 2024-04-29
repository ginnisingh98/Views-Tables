--------------------------------------------------------
--  DDL for Package HR_CONTACT_EXTRA_INFO_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_CONTACT_EXTRA_INFO_BK3" AUTHID CURRENT_USER as
/* $Header: pereiapi.pkh 120.1 2005/10/02 02:23:41 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------< delete_contact_extra_info_b >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_contact_extra_info_b
  (p_effective_date                in     date,
--  ,p_business_group_id             in     number
--  ,p_non_mandatory_arg             in     number
  p_contact_extra_info_id	IN	NUMBER,
  p_object_version_number	IN	NUMBER,
  p_datetrack_delete_mode	IN	VARCHAR2
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------< delete_contact_extra_info_a >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_contact_extra_info_a
  (p_effective_date                in     date
--  ,p_business_group_id             in     number
--  ,p_non_mandatory_arg             in     number
  ,p_contact_extra_info_id         in     number
  ,p_object_version_number         in     number,
--  ,p_some_warning                  in     boolean
  p_datetrack_delete_mode	IN	VARCHAR2
  );
--
end hr_contact_extra_info_bk3;

 

/
