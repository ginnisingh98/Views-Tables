--------------------------------------------------------
--  DDL for Package HR_MULTI_TENANCY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_MULTI_TENANCY_PKG" AUTHID CURRENT_USER AS
/* $Header: permtpkg.pkh 120.0.12010000.7 2009/11/05 06:27:57 ppentapa noship $ */

  -- Called From
  -- 1. hr_signon
  -- All PL/SQL Code modified for enterprise should be wrapped in a call
  -- to this method.
  FUNCTION is_multi_tenant_system RETURN BOOLEAN;

  -- Called From
  -- 1. Assign Security Profiles form
  FUNCTION get_system_model RETURN VARCHAR2;

  -- Called from java layer when a new enterprise is created
  PROCEDURE insert_hr_name_formats ( p_enterprise_code IN varchar2);

  -- Called From
  -- 1. hr_signon with argument null.
  -- 2. HRMultiTenancyHelper.java(#resetContext) with argument ENT.
  -- Method to set/reset OLS enterprise context.
  procedure set_context (p_context_value      IN VARCHAR2);

  --
  --------------------------------------------------------------------
  --< set_context_for_person >----------------------------------------
  --------------------------------------------------------------------
  --
  -- Description:
  --    This is a public procedure to set the appropriate Context value
  --    for a person
  --
  PROCEDURE set_context_for_person (p_person_id           IN NUMBER);

  --
  --------------------------------------------------------------------
  --< set_context_for_enterprise >----------------------------------------
  --------------------------------------------------------------------
  --
  -- Description:
  --    This is a public procedure to set the appropriate Context value
  --    for a given enterprise short code
  --
  PROCEDURE set_context_for_enterprise (p_enterprise_short_code  IN VARCHAR2);

  -- Called From
  -- 1. HRApplicationModuleImpl.java without argument
  -- 2. MTHomeAMImpl.java with argument.
  -- Gets the corporate branding for the passed/current enterprise.
  FUNCTION get_corporate_branding (p_organization_id    IN VARCHAR2 DEFAULT NULL) RETURN VARCHAR2;

  -- Called from HR_SIGNON to RETURN the business group corresponding
  -- to the enterprise security group for buisness group initialization.
  FUNCTION get_bus_grp_from_sec_grp (p_security_group_id  IN NUMBER) RETURN NUMBER;

  -- Called from HR_API to set proper security group.
  procedure set_security_group_id  (p_security_group_id   IN NUMBER);

  -- Used in SSHR to derive the security group from person
  -- i.e. (Notifications/Workflow)
  FUNCTION get_org_id_for_person  (p_person_id          IN NUMBER) RETURN NUMBER;

  -- Used in SSHR New Hire flow
  -- Gets the HR Enterprise Organization ID in the passed business group belonging to
  -- to the same enterprise as the passed HR Person.
  FUNCTION get_org_id_for_person (p_person_id          IN NUMBER
                                 ,p_business_group_id  IN NUMBER) RETURN NUMBER;

  -- Called From PerAppModuleHelper
  FUNCTION get_label_from_bg (p_business_group_id  IN NUMBER) RETURN VARCHAR2;

  -- Called From PerAppModuleHelper
  FUNCTION get_org_id_from_bg_and_sl (p_business_group_id  IN NUMBER
                                     ,p_security_label     IN VARCHAR2) RETURN NUMBER;

  FUNCTION is_valid_sec_group (p_security_group_id  IN NUMBER
                              ,p_business_group_id  IN NUMBER) RETURN VARCHAR2;

  PROCEDURE add_language;

END hr_multi_tenancy_pkg;

/
