--------------------------------------------------------
--  DDL for Package HR_SECURITY_USER_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_SECURITY_USER_BK2" AUTHID CURRENT_USER as
/* $Header: hrseuapi.pkh 120.5.12000000.1 2007/01/21 18:29:10 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |------------------------< update_security_user_b >------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_security_user_b
  (p_effective_date                in     date
  ,p_security_user_id              in     number
  ,p_user_id                       in     number
  ,p_security_profile_id           in     number
  ,p_process_in_next_run_flag      in     varchar2
  ,p_object_version_number         in     number
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< update_security_user_a >------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_security_user_a
  (p_effective_date                in     date
  ,p_security_user_id              in     number
  ,p_user_id                       in     number
  ,p_security_profile_id           in     number
  ,p_process_in_next_run_flag      in     varchar2
  ,p_object_version_number         in     number
  ,p_del_static_lists_warning      in     boolean
  );
--
end hr_security_user_bk2;

 

/
