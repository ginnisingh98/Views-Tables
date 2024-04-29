--------------------------------------------------------
--  DDL for Package WF_PLUG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WF_PLUG" AUTHID CURRENT_USER as
/* $Header: wfplugs.pls 120.1 2005/07/02 02:50:43 appldev ship $ */

--
-- Types
--

-- column name array for the worklist
type column_name_array is table of varchar2(30) index by binary_integer;
-- column size array for the worklist
type column_size_array is table of varchar2(4) index by binary_integer;

TYPE wf_worklist_definition_record IS RECORD
(
 ROW_ID	 			 ROWID,
 PLUG_ID			 NUMBER,
 USERNAME			 VARCHAR2(320),
 DEFINITION_NAME		 VARCHAR2(30),
 WHERE_STATUS			 VARCHAR2(30),
 WHERE_FROM			 VARCHAR2(30),
 WHERE_ITEM_TYPE 		 VARCHAR2(8),
 WHERE_NOTIF_TYPE		 VARCHAR2(30),
 WHERE_SUBJECT			 VARCHAR2(240),
 WHERE_SENT_START		 DATE,
 WHERE_SENT_END			 DATE,
 WHERE_DUE_START		 DATE,
 WHERE_DUE_END			 DATE,
 WHERE_PRIORITY			 VARCHAR2(10),
 WHERE_NOTIF_DEL_BY_ME		 VARCHAR2(1),
 ORDER_PRIMARY		         VARCHAR2(30),
 ORDER_ASC_DESC	  	         VARCHAR2(4)
);

TYPE  wf_worklist_col_def_record  IS RECORD
(
 ROW_ID	 			 ROWID,
 PLUG_ID			 NUMBER,
 USERNAME			 VARCHAR2(320),
 COLUMN_NUMBER			 NUMBER,
 COLUMN_NAME			 VARCHAR2(30),
 COLUMN_SIZE			 NUMBER
);

 TYPE wf_worklist_col_def_table IS TABLE OF
    wf_plug.wf_worklist_col_def_record
 INDEX BY BINARY_INTEGER;

--
-- WorkList
--   Construct the worklist (summary page) for user.
-- IN
--   orderkey - Key to order by (default PRIORITY)
--              Valid values are PRIORITY, MESSAGE_TYPE, SUBJECT, BEGIN_DATE,
--              DUE_DATE, END_DATE, STATUS.
--   status - Status to query (default OPEN)
--            Valid values are OPEN, CLOSED, CANCELED, ERROR.
--            If null query any status.
--   user - User to query notifications for.  If null query current user.
--          Note: only WF_ADMIN_ROLE can query other than the current user.
--
procedure WorkList(
  plug_id  in varchar2 default null,
  session_id in varchar2 default null,
  display_name in varchar2 default null
);

/*===========================================================================
  PROCEDURE NAME:	edit_worklist_definition

  DESCRIPTION:  	Allows you to modify the look and feel of your
			worklist.  This definition mechanism is used
			for both the standard Worklist UI as well as the
			plug UI.

			If the p_plug_id = '0' then it assumes you are
			defining the default look and feel for the
			Worklist plug

			If the p_username = '0' then it assumes you are
			defining the default look and feel for the
			standard Worklist UI.


  PARAMETERS:

	p_plug_id IN	Unique identifier for this plug for a particular
			home page

	p_username IN	Unique identifier for a given user for this definition
			of the standard worklist ui.

============================================================================*/
PROCEDURE edit_worklist_definition (p_plug_id    IN VARCHAR2 DEFAULT null,
				    p_username   IN VARCHAR2 DEFAULT null,
                                    p_add_column IN VARCHAR2 DEFAULT '0');


/*===========================================================================
  PROCEDURE NAME:	submit_worklist_definition

  DESCRIPTION:  	Saves the worklist definition in the database.

============================================================================*/
PROCEDURE submit_worklist_definition (
  plug_id         IN VARCHAR2 DEFAULT NULL,
  username        IN VARCHAR2 DEFAULT NULL,
  definition_name IN VARCHAR2 DEFAULT NULL,
  column_name     IN column_name_array,
  status 	  IN VARCHAR2 DEFAULT '*',
  fromuser 	  IN VARCHAR2 DEFAULT '*',
  user 		  IN VARCHAR2 DEFAULT NULL,
  ittype 	  IN VARCHAR2 DEFAULT '*',
  msubject 	  IN VARCHAR2 DEFAULT '*',
  beg_sent 	  IN VARCHAR2 DEFAULT '*',
  end_sent 	  IN VARCHAR2 DEFAULT '*',
  beg_due 	  IN VARCHAR2 DEFAULT '*',
  end_due 	  IN VARCHAR2 DEFAULT '*',
  hpriority 	  IN VARCHAR2 DEFAULT null,
  mpriority 	  IN VARCHAR2 DEFAULT null,
  lpriority 	  IN VARCHAR2 DEFAULT null,
  delegated_by_me IN VARCHAR2 DEFAULT '0',
  orderkey	  IN VARCHAR2 DEFAULT 'PRIORITY',
  definition_exists  IN VARCHAR2 DEFAULT 'N'
);

/*===========================================================================
  PROCEDURE NAME:	worklist_plug

  DESCRIPTION:  	creates the worklist plug for the ICX folks for
                        the customizable home page

============================================================================*/
PROCEDURE worklist_plug (
p_session_id     IN      VARCHAR2 DEFAULT NULL,
p_plug_id        IN      VARCHAR2 DEFAULT NULL,
p_display_name   IN      VARCHAR2 DEFAULT NULL,
p_delete         IN      VARCHAR2 DEFAULT 'N'
);

end WF_PLUG;

 

/
