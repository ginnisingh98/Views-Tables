--------------------------------------------------------
--  DDL for Package HR_SECURITY_USER_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_SECURITY_USER_BK1" AUTHID CURRENT_USER as
/* $Header: hrseuapi.pkh 120.5.12000000.1 2007/01/21 18:29:10 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_security_user_b >------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_security_user_b
  (p_effective_date                in     date
  ,p_user_id                       in     number
  ,p_security_profile_id           in     number
  ,p_process_in_next_run_flag      in     varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_security_user_a >------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_security_user_a
  (p_effective_date                in     date
  ,p_user_id                       in     number
  ,p_security_profile_id           in     number
  ,p_process_in_next_run_flag      in     varchar2
  ,p_security_user_id              in     number
  ,p_object_version_number         in     number
  );
--
end hr_security_user_bk1;

 

/
