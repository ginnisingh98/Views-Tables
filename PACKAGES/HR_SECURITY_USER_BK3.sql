--------------------------------------------------------
--  DDL for Package HR_SECURITY_USER_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_SECURITY_USER_BK3" AUTHID CURRENT_USER as
/* $Header: hrseuapi.pkh 120.5.12000000.1 2007/01/21 18:29:10 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_security_user_b >------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_security_user_b
  (p_security_user_id              in     number
  ,p_object_version_number         in     number
  );
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_security_user_a >------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_security_user_a
  (p_security_user_id              in     number
  ,p_object_version_number         in     number
  ,p_del_static_lists_warning      in     boolean
  );
--
end hr_security_user_bk3;

 

/
