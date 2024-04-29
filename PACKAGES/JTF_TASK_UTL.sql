--------------------------------------------------------
--  DDL for Package JTF_TASK_UTL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_TASK_UTL" AUTHID CURRENT_USER AS
/* $Header: jtfptkls.pls 120.5.12010000.2 2010/03/31 12:05:22 anangupt ship $ */
   g_minimum_effort   NUMBER		      := 0;
---
--- The following variable is used in the function Validate_Time_UOM
---
   g_uom_time_class   mtl_units_of_measure.uom_class%TYPE
	:= fnd_profile.VALUE ('JTF_TIME_UOM_CLASS');

   -- Commented out by SBARAT on 29/12/2005 for bug# 4866066
   /*g_yes     CONSTANT CHAR		  := 'Y';
   g_no      CONSTANT CHAR		  := 'N';*/

   g_perz_suffix     CONSTANT VARCHAR2(9)    := ':JTF_TASK';
   g_validate_category	 boolean DEFAULT true;

   g_tasks_read_privelege constant VARCHAR2(30) := 'JTF_TASK_READ_ONLY' ;
   g_tasks_full_privelege constant VARCHAR2(30) := 'JTF_TASK_FULL_ACCESS' ;

   g_show_error_for_dup_reference Boolean DEFAULT True; -- 2102281

   -- Added by SBARAT on 29/12/2005 for bug# 4866066
   FUNCTION g_yes RETURN VARCHAR2;
   FUNCTION g_no RETURN VARCHAR2;

   FUNCTION validate_shift_construct (p_shift_construct_id IN NUMBER)
      RETURN BOOLEAN;

   PROCEDURE call_internal_hook (
      p_package_name	  IN	   VARCHAR2,
      p_api_name      IN       VARCHAR2,
      p_processing_type   IN	   VARCHAR2,
      x_return_status	  OUT NOCOPY	   VARCHAR2
   );

   FUNCTION get_escalation_owner (p_task_id IN NUMBER)
      RETURN VARCHAR2;

   FUNCTION get_escalation_level (p_task_id IN NUMBER)
      RETURN VARCHAR2;

   PROCEDURE validate_location_id (
      p_location_id	 IN          NUMBER,
      p_address_id	 IN          NUMBER,
      p_task_id          IN          NUMBER,
      x_return_status	 OUT NOCOPY	 VARCHAR2
   );

   FUNCTION validate_lookup (
      p_lookup_type    IN   VARCHAR2,
      p_lookup_code    IN   VARCHAR2,
      p_lookup_type_name   IN	VARCHAR2
      )
      RETURN BOOLEAN;

   PROCEDURE validate_contact (
      p_contact_id	IN	 NUMBER,
      p_task_id 	IN	 NUMBER,
      p_contact_type_code   IN	     VARCHAR2,
      x_return_status	    OUT NOCOPY	    VARCHAR2
   );

   PROCEDURE validate_contact_point (
      p_contact_id     IN	NUMBER,
      p_phone_id       IN	NUMBER,
      x_return_status	   OUT NOCOPY	    VARCHAR2,
      p_owner_table_name   IN	    VARCHAR2 DEFAULT 'JTF_TASK_CONTACTS'
   );

   PROCEDURE check_duplicate_contact (
      p_contact_id          IN           NUMBER,
      p_task_id             IN           NUMBER,
      p_contact_type_code   IN           VARCHAR2,
      p_task_contact_id     IN           NUMBER  DEFAULT NULL,
      x_return_status       OUT NOCOPY   VARCHAR2
   );

   PROCEDURE validate_distance (
      p_distance_units	 IN   NUMBER,
      p_distance_tag	 IN   VARCHAR2,
      x_return_status	 OUT NOCOPY   VARCHAR2
   );

   FUNCTION get_owner (p_object_type_code IN VARCHAR2, p_object_id IN NUMBER)
      RETURN VARCHAR2;

---------
---------   Validate Task Template Group
---------
   PROCEDURE validate_task_template_group (
      p_task_template_group_id	   IN	    NUMBER,
      p_task_template_group_name   IN	    VARCHAR2,
      x_return_status	       OUT NOCOPY	VARCHAR2,
      x_task_template_group_id	   IN OUT NOCOPY	NUMBER -- Fixed from OUT to IN OUT
   );

   PROCEDURE validate_costs (
      x_return_status	OUT NOCOPY   VARCHAR2,
      p_costs	    IN	 NUMBER,
      p_currency_code	IN   VARCHAR2
   );

   FUNCTION currency_code (p_currency_code IN VARCHAR2)
      RETURN VARCHAR2;

   PROCEDURE validate_object_type (
      p_object_code    IN	VARCHAR2,
      p_object_type_name   IN	    VARCHAR2,
      p_object_type_tag    IN	    VARCHAR2 DEFAULT NULL,
      p_object_usage	   IN	    VARCHAR2 DEFAULT NULL,
      x_return_status	   OUT NOCOPY	    VARCHAR2,
      x_object_code    IN OUT NOCOPY	   VARCHAR2 -- Fixed from OUT to IN OUT
   );

   PROCEDURE validate_party_site (
      p_party_site_id	    IN	     NUMBER,
      p_party_site_number   IN	     VARCHAR2,
      x_return_status	    OUT NOCOPY	    VARCHAR2,
      x_party_site_id	    IN OUT NOCOPY      NUMBER -- Fixed from OUT to IN OUT
   );

   PROCEDURE validate_party (
      p_party_id    IN	 NUMBER,
      p_party_number	IN   VARCHAR2,
      x_return_status	OUT NOCOPY   VARCHAR2,
      x_party_id    IN OUT NOCOPY   NUMBER -- Fixed from OUT to IN OUT
   );

   PROCEDURE validate_cust_account (
      p_cust_account_id       IN       NUMBER,
      p_cust_account_number   IN       VARCHAR2,
      x_return_status	      OUT NOCOPY      VARCHAR2,
      x_cust_account_id       IN OUT NOCOPY	 NUMBER -- Fixed from OUT to IN OUT
   );

   PROCEDURE validate_dates (
      p_date_tag    IN	 VARCHAR2 DEFAULT NULL,
      p_start_date  IN	 DATE DEFAULT NULL,
      p_end_date    IN	 DATE DEFAULT NULL,
      x_return_status	OUT NOCOPY   VARCHAR2
   );

   PROCEDURE validate_date_types (
      p_date_type_id	IN   NUMBER,
      p_date_type   IN	 VARCHAR2,
      x_return_status	OUT NOCOPY   VARCHAR2,
      x_date_type_id	IN OUT NOCOPY	NUMBER -- Fixed from OUT to IN OUT
   );

   FUNCTION validate_dependency_id (p_dependency_id IN NUMBER)
      RETURN BOOLEAN;

   FUNCTION to_boolean (x VARCHAR2)
      RETURN BOOLEAN;

   FUNCTION get_task_template_group (p_task_template_id IN NUMBER)
      RETURN NUMBER;

   FUNCTION created_by
      RETURN NUMBER;

   FUNCTION updated_by
      RETURN NUMBER;

   FUNCTION login_id
      RETURN NUMBER;

   PROCEDURE validate_customer_info (
      p_cust_account_number   IN       VARCHAR2,
      p_cust_account_id       IN       NUMBER,
      p_customer_number       IN       VARCHAR2,
      p_customer_id	  IN	   NUMBER,
      p_address_id	  IN	   NUMBER,
      p_address_number	      IN       VARCHAR2,
      x_return_status	      OUT NOCOPY      VARCHAR2,
      x_cust_account_id       IN OUT NOCOPY	 NUMBER, -- Fixed from OUT to IN OUT
      x_customer_id	  IN OUT NOCOPY      NUMBER, -- Fixed from OUT to IN OUT
      x_address_id	  IN OUT NOCOPY      NUMBER -- Fixed from OUT to IN OUT
   );

   PROCEDURE get_object_details (
      p_task_id 	 IN	  NUMBER,
      p_template_flag	     IN       VARCHAR2,
      x_return_status	     OUT NOCOPY      VARCHAR2,
      x_source_object_code   OUT NOCOPY      VARCHAR2
   );

   PROCEDURE validate_flag (
      p_api_name    IN	 VARCHAR2 DEFAULT NULL,
      p_init_msg_list	IN   VARCHAR2 DEFAULT fnd_api.g_false,
      x_return_status	OUT NOCOPY   VARCHAR2,
      p_flag_name   IN	 VARCHAR2,
      p_flag_value  IN	 VARCHAR2
   );

   PROCEDURE validate_task (
      x_return_status	OUT NOCOPY   VARCHAR2,
      p_task_id     IN	 NUMBER DEFAULT NULL,
      p_task_number IN	 VARCHAR2 DEFAULT NULL,
      x_task_id     IN OUT NOCOPY   NUMBER -- Fixed from OUT to IN OUT
   );

   PROCEDURE validate_task_template (
      x_return_status	OUT NOCOPY   VARCHAR2,
      p_task_id     IN	 NUMBER DEFAULT NULL,
      p_task_number IN	 VARCHAR2 DEFAULT NULL,
      x_task_id     IN OUT NOCOPY   NUMBER -- Fixed from OUT to IN OUT
   );

   FUNCTION validate_dependency_code (p_dependency_code IN VARCHAR2)
      RETURN BOOLEAN;

   FUNCTION validate_time_uom (p_uom_code IN VARCHAR2)
      RETURN VARCHAR2;

   PROCEDURE validate_effort (
      p_api_name    IN	 VARCHAR2 DEFAULT NULL,
      p_init_msg_list	IN   VARCHAR2 DEFAULT fnd_api.g_false,
      p_tag	IN   VARCHAR2 DEFAULT NULL,
      p_tag_uom     IN	 VARCHAR2 DEFAULT NULL,
      x_return_status	OUT NOCOPY   VARCHAR2,
      p_effort	    IN	 NUMBER,
      p_effort_uom  IN	 VARCHAR2
   );

   PROCEDURE validate_task_type (
      p_task_type_id	 IN   NUMBER,
      p_task_type_name	 IN   VARCHAR2,
      x_return_status	 OUT NOCOPY   VARCHAR2,
      x_task_type_id	 IN OUT NOCOPY	 NUMBER -- Fixed from OUT to IN OUT
   );

   PROCEDURE validate_task_status (
      p_task_status_id	   IN	    NUMBER,
      p_task_status_name   IN	    VARCHAR2,
      p_validation_type    IN	    VARCHAR2,
      x_return_status	   OUT NOCOPY	    VARCHAR2,
      x_task_status_id	   IN OUT NOCOPY       NUMBER -- Fixed from OUT to IN OUT
   );

   PROCEDURE validate_task_priority (
      p_task_priority_id     IN       NUMBER,
      p_task_priority_name   IN       VARCHAR2,
      x_return_status	     OUT NOCOPY      VARCHAR2,
      x_task_priority_id     IN OUT NOCOPY	NUMBER -- Fixed from OUT to IN OUT
   );

   PROCEDURE validate_task_owner (
      p_owner_type_name   IN	   VARCHAR2 DEFAULT NULL,
      p_owner_type_code   IN	   VARCHAR2,
      p_owner_id      IN       NUMBER,
      x_return_status	  OUT NOCOPY	   VARCHAR2,
      x_owner_id      IN OUT NOCOPY	  NUMBER, -- Fixed from OUT to IN OUT
      x_owner_type_code   IN OUT NOCOPY       VARCHAR2 -- Fixed from OUT to IN OUT
   );

   PROCEDURE validate_timezones (
      p_timezone_id IN	 NUMBER DEFAULT NULL,
      p_timezone_name	IN   VARCHAR2 DEFAULT NULL,
      x_return_status	OUT NOCOPY   VARCHAR2,
      x_timezone_id IN OUT NOCOPY   NUMBER -- Fixed from OUT to IN OUT
   );

   PROCEDURE validate_parent_task_id (
      p_parent_task_id	     IN       NUMBER,
      p_source_object_code   IN       VARCHAR2,
      p_source_object_id     IN       NUMBER,
      x_return_status	     OUT NOCOPY      VARCHAR2
   );

   PROCEDURE validate_notification (
      p_notification_flag     IN       VARCHAR2,
      p_notification_period   IN       NUMBER,
      p_notification_period_uom   IN	   VARCHAR2,
      x_return_status	      OUT NOCOPY       VARCHAR2
   );

   PROCEDURE validate_alarm (
      p_alarm_start	 IN	  NUMBER,
      p_alarm_start_uom      IN       VARCHAR2,
      p_alarm_on	 IN	  VARCHAR2,
      p_alarm_count	 IN	  NUMBER,
      p_alarm_interval	     IN       NUMBER,
      p_alarm_interval_uom   IN       VARCHAR2,
      x_return_status	     OUT NOCOPY      VARCHAR2
   );

   PROCEDURE validate_assigned_by (
      p_assigned_by_id	   IN	    NUMBER,
      p_assigned_by_name   IN	    VARCHAR2,
      x_return_status	   OUT NOCOPY	    VARCHAR2,
      x_assigned_by_id	   IN OUT NOCOPY       NUMBER -- Fixed from OUT to IN OUT
   );

   PROCEDURE validate_source_object (
      p_object_code IN	 VARCHAR2,
      p_object_id   IN	 NUMBER,
      p_tag	IN   VARCHAR2 DEFAULT NULL,
      p_object_name IN	 VARCHAR2,
      x_return_status	OUT NOCOPY   VARCHAR2
   );

   PROCEDURE validate_reference_codes (
      p_reference_code	 IN   VARCHAR2,
      x_return_status	 OUT NOCOPY   VARCHAR2
   );

   FUNCTION g_miss_char
      RETURN VARCHAR2;

   FUNCTION g_miss_date
      RETURN DATE;

   FUNCTION g_miss_number
      RETURN NUMBER;

   FUNCTION get_translated_lookup (
      p_lookup_type   IN   VARCHAR2,
      p_lookup_code   IN   VARCHAR2
      )
      RETURN VARCHAR2;

   PROCEDURE privelege_all_tasks (
      p_profile_name	      IN       VARCHAR2,
      x_privelege_all_tasks   OUT NOCOPY      VARCHAR2,
      x_return_status	      OUT NOCOPY      VARCHAR2
   );

   PROCEDURE get_default_owner (
      x_owner_type_code        OUT NOCOPY   VARCHAR2,
      x_owner_id	   OUT NOCOPY	NUMBER,
      x_owner_type_code_name   OUT NOCOPY   VARCHAR2,
      x_owner_name	   OUT NOCOPY	VARCHAR2,
      x_return_status	       OUT NOCOPY   VARCHAR2
   );

   ----
   ---- function returns the UOM class
   ----
   FUNCTION get_uom_time_class
      RETURN VARCHAR2;

   ----
   ----
   ----
   FUNCTION is_task_closed (p_task_status_id IN NUMBER)
      RETURN VARCHAR2;

   ----
   ----
   ----
   FUNCTION get_customer_name (p_customer_id IN NUMBER)
      RETURN VARCHAR2;

   ----
   ----
   ----
   PROCEDURE validate_missing_task_id (
      p_task_id     IN	 NUMBER,
      x_return_status	OUT NOCOPY   VARCHAR2
   );

   ----
   ----
   ----
   PROCEDURE validate_missing_contact_id (
      p_task_contact_id   IN	   NUMBER,
      x_return_status	  OUT NOCOPY	   VARCHAR2
   );

   -----
   -----
   -----
   PROCEDURE validate_missing_phone_id (
      p_task_phone_id	IN   NUMBER,
      x_return_status	OUT NOCOPY   VARCHAR2
   );

   -----
   -----
   -----
   PROCEDURE validate_application_id (
      p_application_id	 IN   NUMBER,
      x_return_status	 OUT NOCOPY   VARCHAR2
   );

-----
-----
-----
   FUNCTION get_user_name (p_user_id IN NUMBER)
      RETURN VARCHAR2;

-----
-----
-----
   FUNCTION get_parent_task_number (p_task_id IN NUMBER)
      RETURN VARCHAR2;

-----
-----
-----
   FUNCTION get_territory_name (p_terr_id IN NUMBER)
      RETURN VARCHAR2;

-----
-----
-----
   PROCEDURE validate_phones_table (
      p_owner_table_name   IN	    VARCHAR2,
      x_return_status	   OUT NOCOPY	    VARCHAR2
   );
-----
-----
-----

   PROCEDURE validate_category (
    p_category_id in number,
    x_return_status out NOCOPY varchar2);
-----
-----
-----

   PROCEDURE check_security_privilege(
    p_task_id number,
    p_session varchar2,
    x_return_status out NOCOPY varchar2);
-----
-----
-----
   FUNCTION g_no_char
      RETURN VARCHAR2;
-----
-----
-----
   FUNCTION g_yes_char
      RETURN VARCHAR2;

-----
-----
-----
   FUNCTION g_false_char
      RETURN VARCHAR2;
-----
-----
-----
   FUNCTION g_true_char
      RETURN VARCHAR2;

   PROCEDURE validate_party_site_acct (
     p_party_id number,
     p_party_site_id number,
     p_cust_account_id number,
     x_return_status out NOCOPY varchar2);
-----
-----
-----

FUNCTION GET_CATEGORY_NAME_FOR_TASK ( p_task_id in number,
    p_resource_id in number,
    p_resource_type_code in varchar2 )
  RETURN  varchar2  ;
-----
-----
-----
FUNCTION GET_CATEGORY_NAME ( p_category_id  in number  )
  RETURN  varchar2 ;

procedure delete_category( p_category_name in varchar2 );

   PROCEDURE set_calendar_dates (
     p_show_on_calendar in varchar2 default null,
     p_date_selected in varchar2 default null,
     p_planned_start_date in date default null,
     p_planned_end_date in date default null,
     p_scheduled_start_date in date default null,
     p_scheduled_end_date in date default null,
     p_actual_start_date in date default null,
     p_actual_end_date in date default null,
     x_show_on_calendar in out NOCOPY varchar2, -- Fixed from OUT to IN OUT
     x_date_selected in out NOCOPY varchar2, -- Fixed from OUT to IN OUT
     x_calendar_start_date out NOCOPY date,
     x_calendar_end_date out NOCOPY date,
     x_return_status out NOCOPY varchar2
   );
-----
-----
-----
PROCEDURE validate_status (
      p_status_id     IN       NUMBER,
      p_type IN varchar2,
      x_return_status	   OUT NOCOPY	    VARCHAR2
      );

function getURL ( p_web_function_name in varchar2 )
return varchar2 ;

function getURLparameter ( p_object_code in varchar2 )
return varchar2 ;

   FUNCTION check_truncation (p_object_name in varchar2)
      return varchar2;

-- Added for Enhancement # 2102281
   FUNCTION check_duplicate_reference (p_task_id jtf_tasks_b.task_id%type,
			   p_object_id hz_relationships.object_id%type,
			   p_object_type_code jtf_task_references_b.object_type_code%type)
      return boolean;

-- Added for Enhancement # 2102281
   FUNCTION check_reference_delete (p_task_id jtf_tasks_b.task_id%type,
			p_object_id hz_relationships.object_id%type)
    return boolean;

PROCEDURE create_party_reference (
    p_reference_from	in  varchar2,
    p_task_id	in  number,
    p_party_type_code	in  varchar2 default null,
    p_party_id	in  number,
    x_msg_count out NOCOPY number,
    x_msg_data	out NOCOPY varchar2,
    x_return_status	out NOCOPY varchar2);

PROCEDURE delete_party_reference (
    p_reference_from	in  varchar2,
    p_task_id	in  number,
    p_party_type_code	in  varchar2 default null,
    p_party_id	in  number,
    x_msg_count out NOCOPY number,
    x_msg_data	out NOCOPY varchar2,
    x_return_status	out NOCOPY varchar2);

--Bug 2467222  for assignee category update
      CURSOR c_assignee_or_owner (p_task_id NUMBER,p_category_id NUMBER) IS
       SELECT
	object_version_number,
	task_assignment_id,
	assignment_status_id,
      decode( p_category_id, fnd_api.g_miss_num, category_id, p_category_id) category_id
      FROM jtf_task_all_assignments
      WHERE task_id = p_task_id
      AND resource_id = ( SELECT resource_id
		FROM jtf_rs_resource_extns
		WHERE user_id = fnd_global.user_id)
      AND resource_type_code not in ('RS_GROUP','RS_TEAM');

      -- CBusiness Event System Enhancement # 2391065
      CURSOR c_ass_orig (b_task_assignment_id IN NUMBER) IS
       SELECT
	object_version_number,
	task_assignment_id,
	assignment_status_id,
	category_id,
		resource_id,
		resource_type_code,
		actual_start_date,
		actual_end_date,
		assignee_role,
		show_on_calendar
	  FROM jtf_task_all_assignments
      WHERE task_assignment_id = b_task_assignment_id;

 PROCEDURE update_task_category (
    p_api_version	    IN	     NUMBER,
    p_object_version_number IN OUT NOCOPY    NUMBER,
    p_task_assignment_id    IN	 NUMBER DEFAULT fnd_api.g_miss_num,
    p_category_id	    IN	     NUMBER   DEFAULT jtf_task_utl.g_miss_number,
    x_return_status	OUT NOCOPY	 VARCHAR2,
    x_msg_count 	OUT NOCOPY	 NUMBER,
    x_msg_data		OUT NOCOPY	 VARCHAR2);

   FUNCTION get_owner_detail (p_object_type_code IN VARCHAR2, p_object_id IN NUMBER)
      RETURN VARCHAR2;

   FUNCTION get_status_name (p_status_id IN NUMBER)
      RETURN VARCHAR2;

   FUNCTION enable_audit (p_enable IN BOOLEAN DEFAULT TRUE)
      RETURN BOOLEAN;

END;

/
