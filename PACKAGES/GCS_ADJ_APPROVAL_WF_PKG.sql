--------------------------------------------------------
--  DDL for Package GCS_ADJ_APPROVAL_WF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GCS_ADJ_APPROVAL_WF_PKG" AUTHID CURRENT_USER AS
/* $Header: gcsameintgs.pls 120.0 2007/11/22 01:39:24 rguerrer ship $ */
--------------------------------------------------------------------------------
-- PUBLIC BODIES
--------------------------------------------------------------------------------

PROCEDURE Fch_Check_Approvals (p_item_type IN VARCHAR2,
                               p_item_key      IN  varchar2,
                               p_act_id        IN NUMBER,
                               p_funcmode      IN VARCHAR2,
                               x_result_out    out nocopy  varchar2);

PROCEDURE create_gcsadj_process(p_entry_id IN NUMBER
                               ,p_user_id IN NUMBER
							   ,p_user_name IN VARCHAR2
							   ,p_orig_entry_id IN NUMBER
                               ,p_ledger_id IN NUMBER
                               ,p_cal_period_name IN VARCHAR2
                               ,p_conversion_type IN VARCHAR2
							   ,p_writeback_flag IN VARCHAR2
                               ,p_wfitemkey OUT NOCOPY VARCHAR2);
--
-- PROCEDURE
--   GetNextApprover
--
-- DESCRIPTION
--   Gets the next approver for the approval request.
--
-- IN
--   p_item_type    - The workflow item type (GCSADJ)
--   p_item_key     - The workflow request id (ENTRY ID)
--   p_act_id       - The function activity
--   p_func_mode    - Run/Cancel/Timeout
--
-- OUT
--   x_result_out   - Indicates completion of workflow activity and it's result
--------------------------------------------------------------------------------

PROCEDURE Get_Next_Approver (
           p_item_type IN VARCHAR2,
           p_item_key IN VARCHAR2,
           p_act_id   IN NUMBER,
           p_funcmode IN VARCHAR2,
           x_result_out          out nocopy  varchar2);

PROCEDURE process_approval(p_item_type IN VARCHAR2,
                        p_item_key IN VARCHAR2,
                        p_actid   IN NUMBER,
                        p_funcmode IN VARCHAR2,
                        x_result_out  OUT NOCOPY VARCHAR2 );

PROCEDURE process_rejected(p_item_type IN VARCHAR2,
                        p_item_key IN VARCHAR2,
                        p_actid   IN NUMBER,
                        p_funcmode IN VARCHAR2,
                        x_result_out  OUT NOCOPY VARCHAR2 );

PROCEDURE update_adjustment(p_item_type IN VARCHAR2,
                        p_item_key IN VARCHAR2,
                        p_actid   IN NUMBER,
                        p_funcmode IN VARCHAR2,
                        x_result_out  OUT NOCOPY VARCHAR2 );

END GCS_ADJ_APPROVAL_WF_PKG;

/
