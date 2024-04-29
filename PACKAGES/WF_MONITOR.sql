--------------------------------------------------------
--  DDL for Package WF_MONITOR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WF_MONITOR" AUTHID CURRENT_USER as
/* $Header: wfmons.pls 120.7 2006/05/01 09:54:10 sramani ship $: */
/*#
 * Provides APIs to access the various pages of the Workflow Monitor.
 * @rep:scope public
 * @rep:product OWF
 * @rep:displayname Workflow Monitor
 * @rep:lifecycle active
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY WF_ENGINE
 * @rep:ihelp FND/@wfmonit See the related online help
 */
-- Html
--   Sends back a very simple dynamic HTML page to tell the browser what
--   applet to run.
procedure Html(
    x_item_type  in varchar2,
    x_item_key   in varchar2,
    x_admin_mode in varchar2,
    x_access_key in varchar2,
    x_nls_lang   in varchar2 default null);

-- GetRole
--   Called by Monitor.class.
--   Printf's all the role information back to the
--   Monitor applet, which reads them a line at a time, interpreting them.
-- IN
--  x_filter
procedure GetRole(p_titles_only varchar2,
                  P_FIND_CRITERIA varchar2 default null);

-- GetResource
--   Called by Monitor.class.
--   Printf's all the role information back to the
--   Monitor applet, which reads them a line at a time, interpreting them.
-- IN
--  x_filter
function GetResource(x_restype varchar2,
                      x_resname varchar2) return varchar2;

-- GetResources
--   Called by Monitor.class.
--   Printf's all the role information back to the
--   Monitor applet, which reads them a line at a time, interpreting them.
-- IN
--  x_filter
function GetResources(x_restype varchar2,
                      x_respattern varchar2) return varchar2;

-- GetProcess
--   Called by Monitor.class.
--   Printf's all the information about the workflow objects back to the
--   Monitor applet, which reads them a line at a time, interpreting them.
-- IN
--  x_item_type
--  x_item_key
--  x_proc_name
function GetProcess(
    x_item_type varchar2,
    x_item_key  varchar2,
    x_admin_mode varchar2,
    x_access_key varchar2,
    x_proc_name varchar2 default null,
    x_proc_type varchar2 default null) return clob;

-- GetAccessKey
/*#
 * Retrieves the access key password that controls access to the
 * Workflow Monitor. Each process instance has separate access
 * keys for running the Workflow Monitor in 'ADMIN' mode or 'USER'
 * mode.
 * @param x_item_type Item Type
 * @param x_item_key Item Key
 * @param x_admin_mode Administrator Mode
 * @return Access Key
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Get Access Key
 * @rep:ihelp FND/@wfmonit#getackey See the related online help
 */
function GetAccessKey(
    x_item_type  varchar2,
    x_item_key   varchar2,
    x_admin_mode varchar2) return varchar2;

function GetUrl (x_agent in varchar2,
                 x_item_type in varchar2,
                 x_item_key in varchar2,
                 x_admin_mode in varchar2 default 'NO') return varchar2;

/*#
 * Returns a URL that allows guest access to the Status
 * Diagram page in the administrator version of the Status
 * Monitor. The URL displays the Status Diagram page
 * for a specific instance of a workflow process, operating
 * either with or without administrator privileges.
 * @param x_agent Web Agent
 * @param x_item_type Item Type
 * @param x_item_key Item Key
 * @param x_admin_mode Administrator Mode
 * @return Status Diagram URL
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Get Status Diagram URL
 * @rep:ihelp FND/@wfmonit#geturl See the related online help
 */
function GetDiagramURL (x_agent in varchar2,
                 x_item_type in varchar2,
                 x_item_key in varchar2,
                 x_admin_mode in varchar2 default 'NO') return varchar2;

/*#
 * Returns a URL that allows guest access to the
 * Participant Responses page in the administrator version
 * of the Status Monitor. The URL displays the Participant
 * Responses page for a specific instance of a workflow
 * process, operating either with or without administrator
 * privileges.
 * @param x_agent Web Agent
 * @param x_item_type Item Type
 * @param x_item_key Item Key
 * @param x_admin_mode Administrator Mode
 * @return Participant Responses URL
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Get Participant Responses URL
 * @rep:ihelp FND/@wfmonit#getenv See the related online help
 */
function GetEnvelopeURL (
  x_agent               IN VARCHAR2,
  x_item_type           IN VARCHAR2,
  x_item_key            IN VARCHAR2,
  x_admin_mode          IN VARCHAR2 DEFAULT 'NO'
) return varchar2;

/*#
 * Returns a URL that allows guest access to the Activity
 * History page in the administrator version of the
 * Status Monitor. The URL displays the Activity History
 * page for a specific instance of a workflow process,
 * operating either with or without administrator
 * privileges. All activity type and activity status
 * filtering options are automatically selected by
 * default.
 * @param x_agent Web Agent
 * @param x_item_type Item Type
 * @param x_item_key Item Key
 * @param x_admin_mode Administrator Mode
 * @param x_options Filtering Option
 * @return Activity History URL
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Get Activity History URL
 * @rep:ihelp FND/@wfmonit#getadenv See the related online help
 */
function GetAdvancedEnvelopeURL (
  x_agent               IN VARCHAR2,
  x_item_type           IN VARCHAR2,
  x_item_key            IN VARCHAR2,
  x_admin_mode          IN VARCHAR2 DEFAULT 'NO',
  x_options             IN VARCHAR2 DEFAULT NULL
) return varchar2;



-- EngApi
--  Called by Monitor class.
--  Directly communicate with the WF engine API and handle exceptions
-- IN
--  apiname
--  itype
--  ikey
--  thirdarg
--  fortharg
--  fiftharg
procedure EngApi (api_name in varchar2,
                  x_item_type in varchar2,
                  x_item_key in varchar2,
                  x_access_key in varchar2,
                  third_arg in varchar2,
                  forth_arg in varchar2 default '',
                  fifth_arg in varchar2 default '');

-- Show
--   This is to be called by forms when people want to link to workflow.
--   If nothing to be passed, this will take you to Find_Instance().
--   Otherwise, this will take you to the envelope() page.
procedure Show (
  item_type              VARCHAR2 DEFAULT NULL,
  item_key               VARCHAR2 DEFAULT NULL,
  admin_mode             VARCHAR2 DEFAULT 'N',
  access_key             VARCHAR2 DEFAULT NULL);

--
-- Find_Instance
--   Query page to find processes
--
procedure find_instance;

--
-- INSTANCE_LIST
--   Produce list of processes matching criteria
-- IN
--   x_active - Item active or complete (ACTIVE, COMPLETE, ALL)
--   x_itemtype - Itemtype (null for all)
--   x_ident - Itemkey (null for all)
--   x_process - Root process name (null for all)
--   x_status - Only with activities of status (SUSPEND, ERROR, ALL)
--   x_person - Only waiting for reponse from
--   x_numdays - No progress in x days
--
procedure instance_list (
  x_active      VARCHAR2 default null,
  x_itemtype    VARCHAR2 default null,
  x_ident       VARCHAR2 default null,
  x_user_ident  VARCHAR2 default null,
  x_process     VARCHAR2 default null,
  x_process_owner       VARCHAR2 default null,
  x_display_process_owner       VARCHAR2 default null,
  x_admin_privilege     VARCHAR2 default 'N',
  x_status      VARCHAR2 default null,
  x_person      VARCHAR2 default null,
  x_display_person      VARCHAR2 default null,
  x_numdays     VARCHAR2 default null);

/*
** The sorting issues are fairly complicated.
** You cannot use a decode statement to identify
** the direction of your sort only the column that
** will be used for the sort.  To get around this
** I've had to copy the select statement twice in the
** envelope procedure.  The first is the sort
** for the ascending list.  The second is the list
** for the descending sort.  The x_activity_cursor is
** shared across multiple selects and fetches its data
** into the wf_activity record.
*/
TYPE wf_activity_record IS RECORD
(
item_type               VARCHAR2(8),
item_key                VARCHAR2(240),
begin_date              DATE,
execution_time          NUMBER,
end_date                DATE,
begin_date_time         VARCHAR2(40),
duration                NUMBER,
activity_item_type      VARCHAR2(8),
activity_type           VARCHAR2(8),
parent_activity_name    VARCHAR2(30),
activity_name           VARCHAR2(30),
activity_display_name   VARCHAR2(80),
parent_display_name     VARCHAR2(80),
activity_status         VARCHAR2(8),
notification_status     VARCHAR2(8),
notification_id         NUMBER,
recipient_role          VARCHAR2(320),
recipient_role_name     VARCHAR2(4000),
activity_status_display VARCHAR2(4000),
result                  VARCHAR2(4000)
);


/*
** Create the appropriate cursor for the requested sort
** order.  We currently fetch all the activity rows for
** the given process and then programatically determine
** which rows to display based on your activity list
** filters.
*/
TYPE wf_activity_cursor IS REF CURSOR RETURN wf_activity_record;


/*
** ENVELOPE
**   Produce list of activities matching selected process
** IN
**-----------------------------------------------------------------------
**   x_item_type - Item type of this process instance
**   x_item_key - Internal key for this process instance
**   x_admin_mode - Are you in admin mode
**   x_access_key - Access key for this process
**-----------------------------------------------------------------------
**   These parameters are for future use when youll want to navigate
**   from six advanced searches deep directly back to the process list.
**-----------------------------------------------------------------------
**   x_active_find - Item active or complete (ACTIVE, COMPLETE, ALL)
**                   find window.  Needed to differentiate between
**                   this and x_active which is one of the advanced
**                   search options.
**   x_itemtype_find - Itemtype (null for all) from the find window.
**                   Needed to differentiate between
**                   this and x_item_type which is one for this specific
**                   process
**   x_ident - Itemkey (null for all)
**   x_process - Root process name (null for all)
**   x_status - Only with activities of status (SUSPEND, ERROR, ALL)
**   x_person - Only waiting for reponse from
**   x_numdays - No progress in x days
**-----------------------------------------------------------------------
**  x_advanced - Are you in advanced mode or standard (TRUE, FALSE, FIRST)
**               (First means youre going into advanced mode for the first
**                time.  The function behaves slightly differently in this
**                case.
**-----------------------------------------------------------------------
**   These parameters are for the advanced filter options.  The first
**   four are for the status checkboxes.  When one of these checkboxes
**   are set they get passed in as 'ACTIVE' or 'COMPLETE'.
**   They are Null if they are not checked. IN ( then do some comparisons
**   to see if the current status of the activity matches the checked
**   checkboxes.  x_active include statuses of ACTIVE, WAITING, DEFERRED,
**   and NOTIFIED
**-----------------------------------------------------------------------
**  x_active
**  x_complete
**  x_error
**  x_suspend
**-----------------------------------------------------------------------
**   These parameters are for the advanced filter options.  These four
**   are for the activity type checkboxes.  They are passed in as 'Y'
**   when they are checked.  They are Null if they are not checked.
**-----------------------------------------------------------------------
**  x_proc_func   - Show processes and functions
**  x_note_resp   - Show notifications with responses
**  x_note_noresp - Show FYI notifications
**  x_func_std    - Show Standard Workflow activities
**-----------------------------------------------------------------------
**  x_sort_column - The current column that the list is sorted by
**  x_sort_order - The sort order direction (ASC, DESC)
**-----------------------------------------------------------------------
*/
procedure envelope (
  x_item_type              VARCHAR2,
  x_item_key               VARCHAR2,
  x_admin_mode             VARCHAR2,
  x_access_key             VARCHAR2,
  x_advanced               VARCHAR2 DEFAULT NULL,
  x_active                 VARCHAR2 DEFAULT NULL,
  x_complete               VARCHAR2 DEFAULT NULL,
  x_error                  VARCHAR2 DEFAULT NULL,
  x_suspend                VARCHAR2 DEFAULT NULL,
  x_proc_func              VARCHAR2 DEFAULT NULL,
  x_note_resp              VARCHAR2 DEFAULT NULL,
  x_note_noresp            VARCHAR2 DEFAULT NULL,
  x_func_std               VARCHAR2 DEFAULT NULL,
  x_event                  VARCHAR2 DEFAULT NULL,
  x_sort_column            VARCHAR2 DEFAULT NULL,
  x_sort_order             VARCHAR2 DEFAULT NULL,
  x_nls_lang               VARCHAR2 DEFAULT NULL
);

procedure envelope_frame (
  x_item_type              VARCHAR2,
  x_item_key               VARCHAR2,
  x_admin_mode             VARCHAR2,
  x_access_key             VARCHAR2,
  x_advanced               VARCHAR2 DEFAULT NULL,
  x_active                 VARCHAR2 DEFAULT NULL,
  x_complete               VARCHAR2 DEFAULT NULL,
  x_error                  VARCHAR2 DEFAULT NULL,
  x_suspend                VARCHAR2 DEFAULT NULL,
  x_proc_func              VARCHAR2 DEFAULT NULL,
  x_note_resp              VARCHAR2 DEFAULT NULL,
  x_note_noresp            VARCHAR2 DEFAULT NULL,
  x_func_std               VARCHAR2 DEFAULT NULL,
  x_event                  VARCHAR2 DEFAULT NULL,
  x_sort_column            VARCHAR2 DEFAULT NULL,
  x_sort_order             VARCHAR2 DEFAULT NULL,
  x_nls_lang               VARCHAR2 DEFAULT NULL
);

/*===========================================================================
  PROCEDURE NAME:       draw_activity_error

  DESCRIPTION:          Displays an HTML page with all the errors that have
                        occurred for a particular process instance

  PARAMETERS:
     x_item_type IN     Item type of this process instance
     x_item_key  IN     Internal key for this process instance

============================================================================*/
procedure draw_activity_error (
 x_item_type        VARCHAR2,
 x_item_key         VARCHAR2
);


/*
** Create a table to store child activities for a given process
*/
TYPE wf_items_rec_type IS RECORD
(
item_type               VARCHAR2(8),
item_key                VARCHAR2(240),
root_activity           VARCHAR2(30),
root_activity_version   NUMBER,
user_key                VARCHAR2(240),
owner_role              VARCHAR2(320),
begin_date              DATE,
end_date                DATE
);


/*
** Create the wf_items table based on the above record definition
*/
 TYPE wf_items_tbl_type IS TABLE OF
 wf_monitor.wf_items_rec_type
 INDEX BY BINARY_INTEGER;



procedure process_children (
x_item_type        IN VARCHAR2,
x_item_key         IN VARCHAR2,
x_admin_mode       IN VARCHAR2 DEFAULT 'NO',
x_nls_lang         IN VARCHAR2 DEFAULT null );

procedure draw_process_children (
p_parent_item_type IN VARCHAR2,
p_parent_item_key  IN VARCHAR2,
p_admin_mode       IN VARCHAR2 DEFAULT 'NO',
p_indent_level     IN NUMBER DEFAULT 0,
p_nls_lang         IN VARCHAR2 DEFAULT null);

procedure get_process_children (
p_parent_item_type IN VARCHAR2,
p_parent_item_key  IN VARCHAR2,
p_child_item_list  OUT NOCOPY wf_monitor.wf_items_tbl_type,
p_number_of_children OUT NOCOPY NUMBER);


PROCEDURE draw_header (
    x_item_type  varchar2,
    x_item_key   varchar2,
    x_admin_mode varchar2,
    x_access_key varchar2,
    x_advanced   varchar2,
    x_nls_lang   varchar2 default null);



function  createapplettags (
    x_item_type  in varchar2,
    x_item_key   in varchar2,
    x_admin_mode in varchar2,
    x_access_key in varchar2,
    x_nls_lang   in varchar2 default null,
    x_browser    in varchar2 default 'WIN') return varchar2;


-- Procedure to build URLs to access status monitor.
-- These Urls will take the user either the Status Monitor Diagram,
-- History or the Participant Responses page in the Guest Access mode.
PROCEDURE buildMonitorUrl (akRegionCode in varchar2 default null,
                           wa in varchar2 default null,
                           wm in varchar2 default null,
                           itemType in varchar2 default null,
                           itemKey in varchar2 default null,
                           ntfId in varchar2 default null);

PROCEDURE getFWKMonitorUrl(akRegionCode in varchar2 default null,
                           wa in varchar2 default null,
                           wm in varchar2 default null,
                           itemType in varchar2 default null,
                           itemKey in varchar2 default null,
			   l_lurl out nocopy varchar2);

FUNCTION getFunctionForRegion(akRegionCode in varchar2) return varchar2;

PROCEDURE updateToFWKMonitorUrl(oldUrl in varchar2,
                                newUrl out nocopy varchar2,
     		                errorCode out nocopy pls_integer);

PROCEDURE parseUrlForParams(paramName in varchar2,
                            l_oldUrl in varchar2,
 			    paramValue out nocopy varchar2);

end WF_MONITOR;

 

/
