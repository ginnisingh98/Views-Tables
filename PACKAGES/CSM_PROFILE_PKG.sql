--------------------------------------------------------
--  DDL for Package CSM_PROFILE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSM_PROFILE_PKG" AUTHID CURRENT_USER AS
/* $Header: csmuprfs.pls 120.3.12010000.2 2009/08/05 02:43:33 trajasek ship $ */

--
-- Purpose: Briefly explain the functionality of the package
--	This package will contain routines getting profile values
-- MODIFICATION HISTORY
-- Person      Date    Comments
-- ---------   ------  ------------------------------------------
--	Melvin P	04/30/02	Base creation
-- Enter package declarations as shown below

g_CLIENT_WINS             CONSTANT varchar2(30) := 'CLIENT_WINS';
g_SERVER_WINS             CONSTANT varchar2(30) := 'SERVER_WINS';
g_JTM_APPL_CONFLICT_RULE  CONSTANT varchar2(30) := 'JTM_APPL_CONFLICT_RULE';
g_CSF_M_HISTORY_DAYS	  CONSTANT NUMBER		:= 7;

Function value_specific(p_profile_option_name in varchar2,
                        p_user_id fnd_user.user_id%type,
                        p_responsibility_id fnd_user_resp_groups.responsibility_id%type default null,
                        p_application_id fnd_application.application_id%type default null
                        )
return varchar2;

Function get_master_organization_id(p_user_id fnd_user.user_id%type,
                        p_responsibility_id fnd_user_resp_groups.responsibility_id%type default null,
                        p_application_id fnd_application.application_id%type default null
                        )
return number;

function get_service_validation_org(p_user_id in fnd_user.user_id%type,
                        p_responsibility_id fnd_user_resp_groups.responsibility_id%type default null,
                        p_application_id fnd_application.application_id%type default null)
return number;

Function get_organization_id(p_user_id fnd_user.user_id%type,
                        p_responsibility_id fnd_user_resp_groups.responsibility_id%type default null,
                        p_application_id fnd_application.application_id%type default null
                        )
return number;

Function get_category_set_id(p_user_id fnd_user.user_id%type,
                        p_responsibility_id fnd_user_resp_groups.responsibility_id%type default null,
                        p_application_id fnd_application.application_id%type default null
                        )
return number;

Function get_category_id(p_user_id fnd_user.user_id%type,
                        p_responsibility_id fnd_user_resp_groups.responsibility_id%type default null,
                        p_application_id fnd_application.application_id%type default null
                        )
return number;

Function get_history_count(p_user_id fnd_user.user_id%type,
                        p_responsibility_id fnd_user_resp_groups.responsibility_id%type default null,
                        p_application_id fnd_application.application_id%type default null
                        )
return number;

Function get_org_id(p_user_id fnd_user.user_id%type,
                    p_responsibility_id fnd_user_resp_groups.responsibility_id%type default null,
                    p_application_id fnd_application.application_id%type default null
                    )
return number;

Function GetDefaultStatusResponsibility( p_user_id fnd_user.user_id%type) return number;

Function get_change_completed_tasks(p_user_id fnd_user.user_id%type,
                        p_responsibility_id fnd_user_resp_groups.responsibility_id%type default null,
                        p_application_id fnd_application.application_id%type default null
                        )
return varchar2;

Function show_new_mail_only(p_user_id fnd_user.user_id%type,
                        p_responsibility_id fnd_user_resp_groups.responsibility_id%type default null,
                        p_application_id fnd_application.application_id%type default null
                        )
return varchar2;

Function get_task_history_days(p_user_id fnd_user.user_id%type,
                        p_responsibility_id fnd_user_resp_groups.responsibility_id%type default null,
                        p_application_id fnd_application.application_id%type default null
                        )
return number;

Function get_max_attachment_size(p_user_id fnd_user.user_id%type,
                        p_responsibility_id fnd_user_resp_groups.responsibility_id%type default null,
                        p_application_id fnd_application.application_id%type default null
                        )
return number;

Function get_max_ib_at_location(p_user_id fnd_user.user_id%type,
                        p_responsibility_id fnd_user_resp_groups.responsibility_id%type default null,
                        p_application_id fnd_application.application_id%type default null
                        )
return NUMBER;

FUNCTION get_max_readings_per_counter(p_user_id fnd_user.user_id%TYPE,
                        p_responsibility_id fnd_user_resp_groups.responsibility_id%TYPE DEFAULT NULL,
                        p_application_id fnd_application.application_id%TYPE DEFAULT NULL
                        )
RETURN NUMBER;

FUNCTION Get_Route_Data_To_Owner(p_user_id fnd_user.user_id%TYPE DEFAULT NULL,
                        p_responsibility_id fnd_user_resp_groups.responsibility_id%TYPE DEFAULT NULL,
                        p_application_id fnd_application.application_id%TYPE DEFAULT NULL
                        )
RETURN VARCHAR2;

FUNCTION Get_Mobile_Query_Schema( p_responsibility_id fnd_user_resp_groups.responsibility_id%TYPE DEFAULT NULL
                        )
RETURN VARCHAR2;

END CSM_PROFILE_PKG; -- Package spec



/
