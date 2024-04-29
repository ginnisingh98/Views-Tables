--------------------------------------------------------
--  DDL for Package QLTDACTB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QLTDACTB" AUTHID CURRENT_USER as
/* $Header: qltdactb.pls 120.3.12010000.1 2008/07/25 09:21:43 appldev ship $ */

-- 2/8/95 - CREATED
-- Kevin Wiggen

--  This is a serverside package to be run in order to launch actions
--  It will check action triggers against data in qa_results and see in any
--  actions need to be launched

-- Changed the signature of DO_ACTIONS procedure for bug 1843356.
-- Added P_OCCURRENCE and P_PLAN_ID.
-- kabalakr 22 feb 02

  --
  -- changed all the parameter default value to NULL for
  -- performance purpose
  -- jezheng
  -- Wed Nov 27 15:14:48 PST 2002
  --

  -- Added X_ARGUMENT in the signature of DO_ACTIONS.
  -- Bug 3273447. suramasw

  FUNCTION DO_ACTIONS(X_TXN_HEADER_ID NUMBER,
		      X_CONCURRENT NUMBER DEFAULT null,
		      X_PO_TXN_PROCESSOR_MODE VARCHAR2 DEFAULT NULL,
                      X_GROUP_ID NUMBER DEFAULT NULL,
		      X_BACKGROUND BOOLEAN DEFAULT NULL,
		      X_DEBUG BOOLEAN DEFAULT NULL,
                      X_ACTION_TYPE VARCHAR2 DEFAULT NULL ,
                      X_PASSED_ID_NAME VARCHAR2 DEFAULT NULL,
		      P_OCCURRENCE NUMBER DEFAULT NULL,
		      P_PLAN_ID NUMBER DEFAULT NULL,
                      X_ARGUMENT VARCHAR2 DEFAULT NULL)
	RETURN BOOLEAN;

  PROCEDURE launch_workflow(X_PCA_ID NUMBER,
			    X_WF_ITEMTYPE VARCHAR2,
			    X_PLAN_ID NUMBER,
			    X_WORKFLOW_PROCESSES VARCHAR2);

  PROCEDURE FIRE_ALERT(X_PCA_ID NUMBER);

  PROCEDURE DO_ASSIGNMENT(X_PCA_ID NUMBER,
		          X_MESSAGE VARCHAR2,
			  X_ASSIGNED_CHAR_ID NUMBER,
			  X_COLLECTION_ID NUMBER,
			  X_OCCURRENCE NUMBER,
			  X_PLAN_ID NUMBER,
			  X_SQL_STATEMENT OUT NOCOPY VARCHAR2);


  -- Bug 3270283. This procedure takes care of defaulting the receiving
  -- subinventory and locator values to the transfer LPN from the
  -- parent LPN. kabalakr Mon Mar  8 08:01:35 PST 2004.

  -- Bug 6781108
  -- Added the two out parameters and deleted X_TRANSACTION_ID
  -- from the specification
  -- pdube Wed Feb  6 04:53:32 PST 2008
  PROCEDURE DEFAULT_LPN_SUB_LOC_INFO(X_LPN_ID         NUMBER,
                                     X_XFR_LPN_ID     NUMBER,
                                     -- X_TRANSACTION_ID NUMBER
                                     l_rti_sub_code  OUT  NOCOPY  mtl_secondary_inventories.secondary_inventory_name%TYPE,
                                     l_rti_loc_id    OUT  NOCOPY  NUMBER);

  -- 12.1 QWB Usability Improvements
  -- Function to replace tokens strings defined in
  -- an action message with Form field names
  --
  FUNCTION replace_tokens(p_plan_char_action_id IN NUMBER,
                          p_message_str IN VARCHAR2,
                          p_assign_type IN VARCHAr2,
                          P_assigned_elem_type IN NUMBER)
   RETURN VARCHAR2;

  -- 12.1 QWB Usability Improvements
  -- Function to compute the low value for action
  -- triggers
  FUNCTION low_val(p_plan_id in NUMBER,
                   p_spec_id in NUMBER,
                   p_char_id in number,
                   p_char_type in number,
                   p_lowval_lookup in NUMBER,
                   p_highval_lookup in NUMBER,
                   p_char_uom in VARCHAR2,
                   p_plan_uom in VARCHAR2,
                   p_precision in NUMBER)
   RETURN VARCHAR2;

  -- 12.1 QWB Usability Improvements
  -- Function to compute the high value for Spec
  -- triggers
  FUNCTION high_val(p_plan_id in NUMBER,
                    p_spec_id in NUMBER,
                    p_char_id in number,
                    p_char_type in number,
                    p_lowval_lookup in NUMBER,
                    p_highval_lookup in NUMBER,
                    p_char_uom in VARCHAR2,
                    p_plan_uom in VARCHAR2,
                    p_precision in NUMBER)
   RETURN VARCHAR2;




END QLTDACTB;




/
