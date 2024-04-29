--------------------------------------------------------
--  DDL for Package HR_SECURITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_SECURITY" AUTHID CURRENT_USER AS
/* $Header: hrscsec.pkh 120.2 2006/06/09 06:25:34 bshukla ship $ */
   --
   -- WARNING - ALL FUNCTIONS IN THIS PACKAGE MUST ASSERT AT LEAST WNPS
   -- THIS IS DUE TO RDBMS LIMITATION 519783. The PRAGMA restrictions have
   -- been removed as this is no longer required for Oracle 8i +.
   --
   --
   -- Name
   --   get_hr_security_context
   -- Purpose
   --   Returns the security_profile_id for the current session.
   --   Previously this was stored in the client_info string but
   --   is now stored as a global variable in the hr_security_package.
   --
   --   WARNING:  HR DEVELOPMENT INTERNAL USE ONLY
   --
   -- Arguments
   --   *none*
   --
   FUNCTION get_hr_security_context RETURN NUMBER ;
   --
   -- Name
   --   get_security_profile
   -- Purpose
   --   Returns the security profile for the current user
   --   The value is determined from the current schema as follows :
   --
   --   APPS schema :
   --   An "APPS" schema is either universal,multi-currency or multi-lingual
   --   If set, use security_profile_id set in the package global.
   --   Otherwise use the value 0. This is the default view all security
   --   profile
   --
   --   Read-only schema :
   --   If the current schema is the reporting_oracle_username for an
   --   existing security profile then return its id. If there is no such
   --   profile then raise an error.
   --
   --   Custom schema :
   --   A custom schema is one which not an APPS schema and not
   --   oracle id. The function returns the seeded view all security profile
   --   ie 0.
   --
   -- Arguments
   --   *none*
   --
   FUNCTION get_security_profile RETURN NUMBER ;

   --
   -- Name
   --   globals_need_refreshing
   -- Purpose
   --   Returns TRUE or FALSE depending on whether the HR globals
   --   have become out-of-sync with the FND globals.  This typically
   --   occurs when a user changes responsibility.
   --
   FUNCTION globals_need_refreshing RETURN BOOLEAN;

   --
   -- Returns 'TRUE' if the record in the given table is accessible under
   -- the current security context.
   --
   function show_record
      (p_table_name     in varchar2
      ,p_unique_id      in number
      ,p_val1           in varchar2 default null
      ,p_val2           in varchar2 default null
      ,p_val3           in varchar2 default null
      ,p_val4           in varchar2 default null
      ,p_val5           in varchar2 default null
      )
   return varchar2 ;

   --
   -- (overloaded) show_person function to support npws.
   --
   FUNCTION show_person
      (p_person_id              IN NUMBER
      ,p_current_applicant_flag IN VARCHAR2
      ,p_current_employee_flag  IN VARCHAR2
      ,p_current_npw_flag       IN VARCHAR2
      ,p_employee_number        IN VARCHAR2
      ,p_applicant_number       IN VARCHAR2
      ,p_npw_number             IN VARCHAR2)
    Return VARCHAR2;
   --
   -- Under review
   --
   function view_all return varchar2 ;
   --
   -- Name
   --   Show_BIS_Record
   -- Purpose
   --   Returns 'TRUE' if the record in the given table is accessible
   --   under the current security context.
   -- Arguments
   --   p_org_id        organization to which the record belongs
   --
   FUNCTION Show_BIS_Record
      (p_org_id    IN  NUMBER
      )
   RETURN VARCHAR2;
   --
   --
   -- Name
   --   get_sec_profile_bg_id
   -- Purpose
   --   Returns the business_group_id value forthe current sessions security
   --   profile held in g_context.
   -- Arguments
   --   none
   --
   FUNCTION get_sec_profile_bg_id RETURN NUMBER;
   --
   --
   -- Name
   --   get_person_id
   -- Purpose
   --   Returns the named_person_id value for the current sessions security
   --   profile.
   -- Arguments
   --   none
   --
   FUNCTION get_person_id RETURN NUMBER;
   --
   PROCEDURE add_assignment(p_person_id number, p_assignment_id number);
   --
   PROCEDURE add_person(p_person_id number);
   --
   PROCEDURE remove_person(p_person_id number);
   --
   PROCEDURE add_organization(p_organization_id number,
                              p_security_profile_id  number);
   --
   PROCEDURE add_position(p_position_id number,
                          p_security_profile_id  number);
   --
   PROCEDURE add_payroll(p_payroll_id number);
   --
   FUNCTION restrict_on_individual_asg RETURN BOOLEAN;
   --
   FUNCTION restrict_by_supervisor_flag RETURN VARCHAR2;
   --
   PROCEDURE delete_list_for_bg(p_business_group_id NUMBER);
   --
   PROCEDURE delete_per_from_list(p_person_id  number);
   --
   PROCEDURE delete_org_from_list(p_organization_id   number);
   --
   PROCEDURE delete_pos_from_list(p_position_id     number);
   --
   PROCEDURE delete_payroll_from_list(p_payroll_id     number);
   --
END HR_SECURITY;

 

/

  GRANT EXECUTE ON "APPS"."HR_SECURITY" TO "HR_REPORTING_USER";
