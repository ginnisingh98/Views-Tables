--------------------------------------------------------
--  DDL for Package UMX_ACCESS_ROLES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."UMX_ACCESS_ROLES_PVT" AUTHID CURRENT_USER AS
/*$Header: UMXVARPS.pls 120.2.12010000.2 2009/12/02 18:25:10 jstyles ship $*/

function getParentRoles(p_role_name varchar2) return varchar2;

function getAffectedRoles(p_role_name varchar2) return varchar2;

  PROCEDURE  insert_role(p_role_name        in varchar2,
                         p_orig_system      in varchar2,
                         p_orig_system_id   in number,
                         p_start_date       in date,
                         p_expiration_date  in date,
                         p_display_name     in varchar2,
                         p_owner_tag        in varchar2,
                         p_description      in varchar2);

  PROCEDURE  update_role(p_role_name        in varchar2,
                         p_orig_system      in varchar2,
                         p_orig_system_id   in number,
                         p_start_date       in date,
                         p_expiration_date  in date,
                         p_display_name     in varchar2,
                         p_owner_tag        in varchar2,
                         p_description      in varchar2);

/* Wrapper on top of WF_LOCAL_SYNC.propagateUserRole which passes the hardcoded overwrite boolean flag */
PROCEDURE propagateUserRole(p_user_name             in varchar2,
                            p_role_name             in varchar2,
                            p_start_date            in date,
                            p_expiration_date       in date);

/* Wrapper on top of WF_LOCAL_SYNC.propagateUserRole which passes the hardcoded overwrite boolean flag */
/* This one allows assignmentReason to be overwritten */
PROCEDURE propagateUserRole(p_user_name             in varchar2,
                            p_role_name             in varchar2,
                            p_start_date            in date,
                            p_expiration_date       in date,
                            p_assignmentReason	    in varchar2);

/* Wrapper on top of WF_ROLE_HIERARCHY.propagateUserRole which passes the hardcoded overwrite boolean flag */
function HierarchyEnabled (p_origSystem in VARCHAR2) return varchar2;

  --
  -- TEST
  --   Wrapper to Test if function is accessible under current responsibility.
  -- IN
  --   p_function_name          - function to test
  --   p_TEST_MAINT_AVAILABILTY - 'Y' (default) means check if available for
  --                              current value of profile APPS_MAINTENANCE_MODE
  --                              'N' means the caller is checking so it's
  --                              unnecessary to check.
  -- RETURNS
  --  'Y' if function is accessible
  --
  function test (p_function_name           in varchar2,
                 p_test_maint_availability in varchar2 default 'Y') return varchar2;

end UMX_ACCESS_ROLES_PVT;

/
