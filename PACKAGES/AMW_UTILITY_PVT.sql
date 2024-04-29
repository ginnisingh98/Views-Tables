--------------------------------------------------------
--  DDL for Package AMW_UTILITY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMW_UTILITY_PVT" AUTHID CURRENT_USER as
/*$Header: amwvutls.pls 120.5.12000000.2 2007/04/04 01:12:02 rjohnson ship $*/

------------------------------------------------------------------------------
-- HISTORY
------------------------------------------------------------------------------

g_number       CONSTANT NUMBER := 1;  -- data type is number
g_varchar2     CONSTANT NUMBER := 2;  -- data type is varchar2
g_amw_lookups  CONSTANT VARCHAR2(12) :=  'AMW_LOOKUPS';

resource_locked EXCEPTION;
pragma EXCEPTION_INIT(resource_locked, -54);

--------------
-- History
--- Creatd 04/01/2005 dliao
--------------------
/***
  Debug levels:
  0 = No debug
  1 = Log errors
  2 = Log errors and functional messages
  3 = Log errors, functional messages and SQL statements
  4 = Full Debug
***/
g_debug_level_none        CONSTANT NUMBER := 0;
g_debug_level_error       CONSTANT NUMBER := 1;
g_debug_level_medium      CONSTANT NUMBER := 2;
g_debug_level_sql         CONSTANT NUMBER := 3;
g_debug_level_full        CONSTANT NUMBER := 4;



---------------------------------------------------------------------
-- FUNCTION
--    check_fk_exists
--
-- PURPOSE
--    This function checks if a foreign key is valid.
--
-- NOTES
--    1. It will return FND_API.g_true/g_false.
--    2. Exception encountered will be raised to the caller.
--    3. p_pk_data_type can be AMW_Global_PVT.g_number/g_varchar2.
--    4. Please don't put 'AND' at the beginning of your additional
--       where clause.
---------------------------------------------------------------------
FUNCTION check_fk_exists(
   p_table_name   IN VARCHAR2,
   p_pk_name      IN VARCHAR2,
   p_pk_value     IN VARCHAR2,
   p_pk_data_type IN NUMBER := g_number,
   p_additional_where_clause  IN VARCHAR2 := NULL
)
RETURN VARCHAR2;  -- FND_API.g_true/g_false


---------------------------------------------------------------------
-- FUNCTION
--    check_lookup_exists
--
-- PURPOSE
--    This function checks if a lookup_code is valid.

---------------------------------------------------------------------
FUNCTION check_lookup_exists(
   p_lookup_table_name  IN VARCHAR2 := g_amw_lookups,
   p_lookup_type        IN VARCHAR2,
   p_lookup_code        IN VARCHAR2
)
Return VARCHAR2;  -- FND_API.g_true/g_false

---------------------------------------------------------------------
-- FUNCTION
--    check_lookup_exists
--
-- PURPOSE
--    This function checks if a lookup_code is valid from fnd_lookups when
--    view_application_id is passed in.
---------------------------------------------------------------------
FUNCTION check_lookup_exists(
   p_lookup_type          IN  VARCHAR2,
   p_lookup_code          IN  VARCHAR2,
   p_view_application_id  IN  NUMBER
)
Return VARCHAR2;  -- FND_API.g_true/g_false


---------------------------------------------------------------------
-- FUNCTION
--    check_uniqueness
--
-- PURPOSE
--    This function is to check the uniqueness of the keys.
--    In order to make this function more flexible, you need to
--    pass in where clause of your unique key's check.
---------------------------------------------------------------------
FUNCTION check_uniqueness(
   p_table_name    IN VARCHAR2,
   p_where_clause  IN VARCHAR2
)
RETURN VARCHAR2;  -- FND_API.g_true/g_false


---------------------------------------------------------------------
-- FUNCTION
--    is_Y_or_N
--
-- PURPOSE
--    Return FND_API.g_true if p_value='Y' or p_value='N';
--    return FND_API.g_flase otherwise.
---------------------------------------------------------------------
FUNCTION is_Y_or_N(
   p_value  IN  VARCHAR2
)
RETURN VARCHAR2;  -- FND_API.g_true/g_false


---------------------------------------------------------------------
-- FUNCTION
--    Find_Hierarchy_Level
-- PURPOSE
--    This function returns the level in hierarchy of an entity
--    to be displayed on the HGrid
-- HISTORY
--   4/23/2003  abedajna created.
---------------------------------------------------------------------
FUNCTION Find_Hierarchy_Level(
   entity_name      IN VARCHAR2
)
Return number;


---------------------------------------------------------------------
-- PROCEDURE
--    debug_message
--
-- PURPOSE
--    This procedure will check the message level and try to add a
--    debug message into the message table of FND_MSG_API package.
--    Note that this debug message won't be translated.
---------------------------------------------------------------------
PROCEDURE debug_message(
   p_message_text   IN  VARCHAR2,
   p_message_level  IN  NUMBER := NULL
);


---------------------------------------------------------------------
-- PROCEDURE
--    error_message
--
-- PURPOSE
--    Add an error message to the message_list for an expected error.
---------------------------------------------------------------------
PROCEDURE error_message(
   p_message_name VARCHAR2,
   p_token_name   VARCHAR2 := NULL,
   P_token_value  VARCHAR2 := NULL
);


---------------------------------------------------------------------
-- PROCEDURE
--    display_messages
--
-- PURPOSE
--    This procedure will display all messages in the message list
--    using DBMS_OUTPUT.put_line( ) .
---------------------------------------------------------------------
PROCEDURE display_messages;


--======================================================================
-- Procedure Name: send_wf_standalone_message
-- Type          : Generic utility
-- Pre-Req :
-- Notes:
--    Common utility to send standalone message without initiating
--    process using workflow.
-- Parameters:
--    IN:
--    p_item_type          IN  VARCHAR2   Required   Default =  'MAPGUTIL'
--                               item type for the workflow utility.
--    p_message_name       IN  VARCHAR2   Required   Default =  'GEN_STDLN_MESG'
--                               Internal name for standalone message name
--    p_subject            IN  VARCHAR2   Required
--                             Subject for the message
--    p_body               IN  VARCHAR2   Optional
--                             Body for the message
--    p_send_to_role_name  IN  VARCHAR2   Optional
--                             Role name to whom message is to be sent.
--                             Instead of this, one can send even p_send_to_res_id
--    p_send_to_res_id     IN   NUMBER   Optional
--                             Resource Id that will be used to get role name from WF_DIRECTORY.
--                             This is required if role name is not passed.

--   OUT:
--    x_notif_id           OUT  NUMBER
--                             Notification Id created that is being sent to recipient.
--    x_return_status      OUT   VARCHAR2
--                             Return status. If it is error, messages will be put in mesg pub.
-- History:
--======================================================================

PROCEDURE send_wf_standalone_message(
   p_item_type          IN       VARCHAR2 := 'AMWGUTIL'
  ,p_message_name       IN       VARCHAR2 := 'GEN_STDLN_MESG'
  ,p_subject            IN       VARCHAR2
  ,p_body               IN       VARCHAR2 := NULL
  ,p_send_to_role_name  IN       VARCHAR2  := NULL
  ,p_send_to_person_id     IN       NUMBER := NULL
  ,x_notif_id           OUT NOCOPY      NUMBER
  ,x_return_status      OUT NOCOPY      VARCHAR2
  );

---------------------------------------------------------------------
-- FUNCTION
--    get_lookup_meaning
-- USAGE
--    Example:
--       SELECT AMw_Utility_PVT.get_lookup_meaning ('AMS_RISK_STATUS', status_code)
--       FROM   amw ....;
-- HISTORY
-- 6/4/2003 mpande   Created.
---------------------------------------------------------------------
FUNCTION get_lookup_meaning (
   p_lookup_type IN VARCHAR2,
   p_lookup_code IN VARCHAR2
)
RETURN VARCHAR2;
---------------------------------------------------------------------
-- FUNCTION
--    get_employess_name
-- USAGE
--    Example:
--       SELECT AMW_Utility_PVT.get_employee_name (party_id)
--       FROM   dual
-- HISTORY
-- 6/19/2003 mpande  Created.
---------------------------------------------------------------------
FUNCTION get_employee_name (
   p_party_id IN VARCHAR2
)
RETURN VARCHAR2;

---------------------------------------------------------------------
-- PROCEDURE
--    wait_for_req
-- HISTORY
-- 8/22/2003 ABEDAJNA  Created.
---------------------------------------------------------------------
procedure wait_for_req (
p_request_id			IN NUMBER,
p_interval			IN number,
p_max_wait			IN number,
p_phase				OUT nocopy varchar2,
p_status			OUT nocopy varchar2,
p_dev_phase			OUT nocopy varchar2,
p_dev_status			OUT nocopy varchar2,
p_message			OUT nocopy varchar2,
p_init_msg_list			IN VARCHAR2 := FND_API.G_FALSE,
x_return_status			out nocopy varchar2,
x_msg_count			out nocopy number,
x_msg_data			out nocopy varchar2
);


---------------------------------------------------------------------
-- PROCEDURE
--    get_lob_meaning
-- HISTORY
-- 9/16/2003 ABEDAJNA  Created.
---------------------------------------------------------------------
FUNCTION get_lob_meaning(p_lob_name  in varchar2) return varchar2;


---------------------------------------------------------------------
-- PROCEDURE
--    get_process_name
-- HISTORY
-- 11/25/2003 ABEDAJNA  Created.
---------------------------------------------------------------------
FUNCTION get_process_name(p_process_id  in number) return varchar2;
---------------------------------------------------------------------
--Function
-- get_message_text
---------------------------------------------------------------------

FUNCTION get_message_text(p_message_name in varchar2) return varchar2;

---------------------------------------------------------------------
--FUNCTION
-- get_risk_name
-- HISTORY
--12/30/2003 KOSRINIV Created
---------------------------------------------------------------------
FUNCTION get_risk_name(p_risk_id in number) return varchar2;

---------------------------------------------------------------------
--FUNCTION
-- get_control_name
-- HISTORY
--12/30/2003 KOSRINIV Created
---------------------------------------------------------------------

FUNCTION get_control_name(p_control_id in number) return varchar2;


---------------------------------------------------------------------
--FUNCTION
-- get_organization_name
-- HISTORY
--12/30/2003 KOSRINIV Created
---------------------------------------------------------------------

FUNCTION get_organization_name(p_organization_id in number) return varchar2;

FUNCTION get_proc_org_opinion_status(p_process_id  in number, p_org_id in number, p_mode in varchar2) return varchar2;
FUNCTION get_proc_org_opinion_date(p_process_id  in number, p_org_id in number, p_mode in varchar2) return varchar2;

---------------------------------------------------------------------
--FUNCTION
-- get_exception_name
-- Notes :
-- gives the process display name of the processe in a process exception
-- Parameters :
-- p_type   :- 'A' (Add exception -for Adding process or replacing process)
--			'D' (Delete exception - for Deleted process or replaced processd)
--p_exception_id :- Exception Id
-- HISTORY
--04/29/2004 KOSRINIV Created
---------------------------------------------------------------------

FUNCTION get_exception_name(p_type in varchar2, p_exception_id in number) return varchar2;


procedure isUserProcessOwner (
p_pk				IN number,
p_userid			IN number,
p_objectContext			IN varchar2,
p_retval			OUT nocopy varchar2,
p_init_msg_list			IN VARCHAR2 := FND_API.G_FALSE,
x_return_status			out nocopy varchar2,
x_msg_count			out nocopy number,
x_msg_data			out nocopy varchar2
);

---------------------------------------------------------------------
--FUNCTION
-- get_risktype_text
-- Notes :
-- gives the Risk Type heading for webadi columns
-- Parameters :
-- p_type   :- p_risktype_token , The risk type name
-- HISTORY
--07/30/2004 KOSRINIV Created
---------------------------------------------------------------------

FUNCTION get_risktype_text(p_risktype_token in varchar2) return varchar2;


FUNCTION get_parameter(p_org_id in number, p_param_name in varchar2) return varchar2;

---------------------------------------------------------------------
--returns the display name of the current approved revision of
--process

--Parameters
--p_process_id :- the process id

--History
--11/05/2004 NIRMAKUM created
---------------------------------------------------------------------
FUNCTION get_process_name_approved(p_process_id in number) return varchar2;

---------------------------------------------------------------------
--returns the display name of the of process

--Parameters
--p_process_id :- the process id
--p_status : 'L' or 'A' (saying whether the latest process name is wanted or
--                       the latest approved process_name is wanted)

--History
--11/18/2004 NIRMAKUM created
---------------------------------------------------------------------
FUNCTION get_process_name_by_status(p_process_id in number,
                                    p_status in varchar2) return varchar2;

---------------------------------------------------------------------
--NOTES
  --returns the display name of the current approved revision of
  --organization process
--Parameters
--p_process_id :- the process id,p_org_id   :- org Id
--History
--11/06/2004 KOSRINIV created
---------------------------------------------------------------------
FUNCTION get_approved_org_process_name (p_process_id in number, p_org_id in number) return varchar2 ;

----------------------------------------------------------------------------
-- utility function for use in hgrid sql ..return 'Y' if process locked, 'N' otherwise
--Parameters
--      p_process_id :- processId, p_org_id :- Organization id.
--History
--11/09/2004 KOSRINIV   created
------------------------------------------------------------------------------
FUNCTION is_process_locked(p_process_id in number, p_org_id in number) return varchar2;

----------------------------------------------------------------------------
-- utility function to get the count of audit projects for a given organization
--Parameters
--  p_org_id :- Organization id.
--History
--12/06/2004 KOSRINIV   created
------------------------------------------------------------------------------
FUNCTION get_project_count( p_org_id in number) return number;

FUNCTION get_contrlol_objective_name(p_org_id in number,p_proc_id in number,p_risk_id in number,p_control_id in number) return varchar2;
FUNCTION get_contrlol_objective_id(p_org_id in number,p_proc_id in number,p_risk_id in number,p_control_id in number) return NUMBER;
FUNCTION is_contrlol_objective_approved(p_org_id in number,p_proc_id in number,p_risk_id in number,p_control_id in number) return varchar2;
FUNCTION get_cobj_name_approved(p_org_id in number,p_proc_id in number,p_risk_id in number,p_control_id in number) return varchar2;
------------------------------------------------------------------------------------------------------------------------
-- utiltiy method to return a value if the process has presence in latest hierarchy.
--Parameters
--  p_org_id :- Organization id,p_proc_id = Process id
--History
--21/02/2004 KOSRINIV   created
------------------------------------------------------------------------------
FUNCTION exist_in_latest_hier(p_org_id in number,p_proc_id in number) return varchar2;
------------------------------------------------------------------------------------------------------------------------
-- utiltiy method to return change Id of the process . returns -99 if there no CR existing.
--Parameters
--  p_org_id :- Organization id,p_proc_id = Process id,p_rev_num= revision number
--History
--21/02/2004 KOSRINIV   created
------------------------------------------------------------------------------
FUNCTION get_proc_change_id(p_org_id in number,p_proc_id in number, p_rev_num in number) return NUMBER;

------------------------------------------------------------------------------------------------------------------------
-- utiltiy method to return Y if the  process is having more than one child in latest hierarchy.
--Parameters
--  p_org_id :- Organization id (-1 for RL), ,p_proc_id = Process id
--History
--21/02/2004 KOSRINIV   created
------------------------------------------------------------------------------
FUNCTION has_child_morethan_two(p_proc_id in number,p_org_id in number) return VARCHAR;

-- Method to check whether any control is associated with a particular risk.
--Parameters
--  p_process_id :- Process Id, p_revision_number :- Process Revision id, p_risk_id :- Risk Id
--History
--16/03/2005 DPATEL created
------------------------------------------------------------------------------
FUNCTION is_control_associated_to_risk(p_process_id in number, p_revision_number in number, p_risk_id in number) return varchar2;

-- Method to check whether any control is associated with all risks.
--Parameters
--  p_process_id :- Process Id, p_revision_number :- Process Revision id, p_risk_id :- Risk Id
--History
--17/03/2005 DPATEL created
------------------------------------------------------------------------------
FUNCTION is_ctrl_assotd_to_all_risks(p_process_id in number, p_revision_number in number, p_risk_id in number) return varchar2;

-- Method to check whether a control objective is approved.
--Parameters
--  p_process_id :- Process Id, p_risk_id :- Risk Id ,p_control_id :- Control Id
--History
--01/04/2005 DPATEL created
------------------------------------------------------------------------------
FUNCTION is_control_objective_approved(p_process_id in number, p_risk_id in number, p_control_id in number) return varchar2;

--04.01.2005 npanandi: added below method to return
--display value for Ineff Ctrls / Evaluated Ctrls / Total Ctrls
--bug 4201078 fix
function get_display_value(
   p_ineff_ctrl in number
  ,p_eval_ctrl  in number
  ,p_total_ctrl in number) return varchar2;

--04.01.2005 npanandi: added below method to return
--display value for Process/Org Certified vs. Total Processes/Orgs
--bug 4201078 fix
function get_display_proc_cert(
   p_sub_process_cert       in number
  ,p_total_sub_process_cert in number) return varchar2;

  -- utility methods for process variation report..
FUNCTION GET_EX_REASONS(p_action IN VARCHAR2,
						p_object IN VARCHAR2,
						p_pk1 IN VARCHAR2,
						p_pk2 IN VARCHAR2,
						p_pk3 IN VARCHAR2,
						p_pk4 IN VARCHAR2  := NULL,
						p_pk5 IN VARCHAR2 := NULL) RETURN VARCHAR2;
FUNCTION GET_EX_COMMENTS(p_action IN VARCHAR2,
						p_object IN VARCHAR2,
						p_pk1 IN VARCHAR2,
						p_pk2 IN VARCHAR2,
						p_pk3 IN VARCHAR2,
						p_pk4 IN VARCHAR2  := NULL,
						p_pk5 IN VARCHAR2 := NULL) RETURN VARCHAR2;

-------------------------------------------------------------------------
-- This procedure inserts a record into the FND_LOG_MESSAGES table
--   FND uses an autonomous transaction so even when the hookinsert is
--   rolled back because of an error the log messages still exists
--   and also writes log message in the fnd_file, which supports
--   concurrent program view-log message feature
--   History
---            Created on 04/01/2005 dliao
----------------------------------------------------------------------
PROCEDURE LOG_MSG( v_object_id   IN VARCHAR2
                 , v_object_name IN VARCHAR2
                 , v_message     IN VARCHAR2
 --                , v_level_id    IN NUMBER := -1
                 , v_module      IN VARCHAR2);

----------------------------------------------------------------------------
-- this  function returns 'Y','N' depending on the controls exists for a given org-process-risk in the given hierarchy..
-- History
--- Created on 04/11/2005 kosriniv
---------------------------------------------------------------------------------------------------
FUNCTION GET_RISK_CONTROLS_EXIST(p_org_id IN NUMBER, p_process_id IN NUMBER, p_risk_id IN NUMBER, p_appr_date IN DATE) RETURN VARCHAR2;

----------------------------------------------------------------------------
-- this  function returns 'Y','N' depending on the organization  parameters were set or not.
-- History
--- Created on 04/28/2005 kosriniv
---------------------------------------------------------------------------------------------------
FUNCTION IS_ORG_REGISTERED(p_org_id IN NUMBER) RETURN VARCHAR2;

PROCEDURE  submit_conc_request(p_template_code IN VARCHAR2,
                             p_template_lang IN VARCHAR2 default NULL,
                             p_template_territory IN VARCHAR2 default NULL,
                             p_certification_id IN NUMBER default NULL,
                             p_organization_id IN NUMBER default NULL,
                             p_process_id IN NUMBER default NULL,
                             p_from_date IN DATE default NULL,
                             p_to_date IN DATE default NULL,
                             p_include_orgs_with_issues IN VARCHAR2 default NULL,
                             p_key_controls IN VARCHAR2 default NULL,
                             p_material_risks IN VARCHAR2 default NULL,
                             p_significant_process IN VARCHAR2 default NULL,
                             p_request_id  OUT nocopy NUMBER);


--------------------------------------------------------------------------------------------------
-- to get the opinion result of an organization..
-- p_org_id :- organization Id, p_mode :- 'CERTIFICATION' or 'EVALUATION' etc..
-------------------------------------------------------------------------------------------------

FUNCTION get_org_opinion_status(p_org_id in number, p_mode in varchar2) return varchar2;

---------------------------------------------------------------------------------------------------
-- to cache the parameter values
-- kosriniv 09/03/06
-------------------------------------------------------------------------------------------------

type p_appr_opt_val_type is table of varchar2(1)
	index by pls_integer;
g_appr_opt_val p_appr_opt_val_type;

g_appr_values_cached boolean := false;

procedure cache_appr_options;

procedure unset_appr_cache;


END AMW_Utility_PVT;

 

/
