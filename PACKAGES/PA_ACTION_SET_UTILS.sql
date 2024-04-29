--------------------------------------------------------
--  DDL for Package PA_ACTION_SET_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_ACTION_SET_UTILS" AUTHID CURRENT_USER AS
/*$Header: PARASUTS.pls 120.1 2005/08/19 16:48:35 mwasowic noship $*/
--

G_PERFORMED_ACTIVE              CONSTANT VARCHAR2(80) := 'Performed Active';
G_PERFORMED_COMPLETE            CONSTANT VARCHAR2(80) := 'Performed Complete';
G_NOT_PERFORMED                 CONSTANT VARCHAR2(80) := 'Not Performed';
G_REVERSED_DEFAULT_AUDIT        CONSTANT VARCHAR2(80) := 'Reversed Default Audit';
G_REVERSED_CUSTOM_AUDIT         CONSTANT VARCHAR2(80) := 'Reversed Custom Audit';
G_UPDATED_DEFAULT_AUDIT         CONSTANT VARCHAR2(80) := 'Updated Default Audit';
G_UPDATED_CUSTOM_AUDIT          CONSTANT VARCHAR2(80) := 'Updated Custom Audit';


G_ERROR_EXISTS    VARCHAR2(1);

   TYPE number_tbl_type IS TABLE OF NUMBER
      INDEX BY BINARY_INTEGER;

   TYPE varchar_tbl_type IS TABLE OF VARCHAR2(2000)
      INDEX BY BINARY_INTEGER;

   TYPE date_tbl_type IS TABLE OF DATE
      INDEX BY BINARY_INTEGER;

TYPE action_set_lines_tbl_type IS TABLE OF pa_action_set_lines%ROWTYPE
   INDEX BY BINARY_INTEGER;

TYPE action_line_cond_tbl_type IS TABLE OF pa_action_set_line_cond%ROWTYPE
   INDEX BY BINARY_INTEGER;

l_empty_condition_tbl   action_line_cond_tbl_type;

TYPE action_set_line_id_tbl_type IS TABLE OF NUMBER
    INDEX BY BINARY_INTEGER;

TYPE object_name_tbl_type IS TABLE OF VARCHAR2(80)
    INDEX BY BINARY_INTEGER;

TYPE project_number_tbl_type IS TABLE OF VARCHAR2(25)
    INDEX BY BINARY_INTEGER;

TYPE insert_audit_lines_rec_type IS RECORD
   (reason_code                  VARCHAR2(30),
    action_code                  VARCHAR2(30),
    audit_display_attribute      VARCHAR2(240),
    audit_attribute              VARCHAR2(150),  -- Changed the length to 150 for bug 2863834
    encoded_error_message        VARCHAR2(2000),
    reversed_action_set_line_id  NUMBER);

TYPE insert_audit_lines_tbl_type IS TABLE OF insert_audit_lines_rec_type
    INDEX BY BINARY_INTEGER;

TYPE audit_lines_tbl_type IS TABLE OF pa_action_set_line_aud%ROWTYPE
    INDEX BY BINARY_INTEGER;

FUNCTION get_action_set_id(p_action_set_type_code IN VARCHAR2,
                           p_object_type          IN VARCHAR2,
                           p_object_id            IN NUMBER)
   RETURN NUMBER;

FUNCTION get_action_set_lines(p_action_set_id     IN NUMBER)
   RETURN action_set_lines_tbl_type;

FUNCTION get_action_set_line (p_action_set_line_id     IN NUMBER)
  RETURN pa_action_set_lines%ROWTYPE;

FUNCTION get_action_line_conditions (p_action_set_line_id     IN NUMBER)
  RETURN action_line_cond_tbl_type;

FUNCTION get_action_set_details (p_action_set_line_id     IN NUMBER)
   RETURN pa_action_sets%ROWTYPE;

FUNCTION get_active_audit_lines (p_action_set_line_id     IN NUMBER)
  RETURN audit_lines_tbl_type;

PROCEDURE add_message(p_app_short_name  IN      VARCHAR2,
                      p_msg_name        IN      VARCHAR2,
                      p_token1		IN	VARCHAR2 DEFAULT NULL,
		      p_value1		IN	VARCHAR2 DEFAULT NULL,
		      p_token2		IN	VARCHAR2 DEFAULT NULL,
		      p_value2		IN	VARCHAR2 DEFAULT NULL,
		      p_token3		IN	VARCHAR2 DEFAULT NULL,
		      p_value3		IN	VARCHAR2 DEFAULT NULL,
		      p_token4		IN	VARCHAR2 DEFAULT NULL,
                      p_value4		IN	VARCHAR2 DEFAULT NULL,
	              p_token5		IN	VARCHAR2 DEFAULT NULL,
	              p_value5		IN	VARCHAR2 DEFAULT NULL );

FUNCTION is_name_unique_in_type(p_action_set_type_code  IN  VARCHAR2,
                                p_action_set_name       IN  VARCHAR2,
                                p_action_set_id         IN  NUMBER :=NULL)
  RETURN VARCHAR2;

FUNCTION is_action_set_a_source(p_action_set_id  IN  NUMBER)
  RETURN VARCHAR2;

FUNCTION do_lines_exist(p_action_set_id  IN  NUMBER)
  RETURN VARCHAR2;

FUNCTION do_audit_lines_exist(p_action_set_line_id  IN  NUMBER)
  RETURN VARCHAR2;

FUNCTION get_last_performed_date(p_action_set_line_id  IN  NUMBER)
  RETURN DATE;

PROCEDURE Check_Action_Set_Name_Or_Id (p_action_set_id        IN pa_action_sets.action_set_id%TYPE := NULL
                                      ,p_action_set_name      IN pa_action_sets.action_set_name%TYPE
                                      ,p_action_set_type_code IN pa_action_set_types.action_set_type_code%TYPE
                                      ,p_check_id_flag        IN VARCHAR2
                                      ,p_date                 IN DATE := SYSDATE
                                      ,x_action_set_id       OUT NOCOPY pa_action_sets.action_set_id%TYPE --File.Sql.39 bug 4440895
                                      ,x_return_status       OUT NOCOPY VARCHAR2       --File.Sql.39 bug 4440895
                                      ,x_error_message_code  OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

 PROCEDURE get_line_information_messages(x_line_numbers_tbl  OUT NOCOPY SYSTEM.pa_num_tbl_type, --File.Sql.39 bug 4440895
                                         x_line_messages_tbl OUT NOCOPY SYSTEm.pa_varchar2_2000_tbl_type); --File.Sql.39 bug 4440895


END pa_action_set_utils;

 

/
