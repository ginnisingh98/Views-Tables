--------------------------------------------------------
--  DDL for Package QPR_DEAL_APPROVALS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QPR_DEAL_APPROVALS_PVT" AUTHID CURRENT_USER AS
/* $Header: QPRPNAPS.pls 120.9 2008/02/05 12:03:29 agbennet ship $ */

   PROCEDURE INIT_APPROVALS(
			    p_response_header_id IN NUMBER,
			    p_user_id IN NUMBER,
			    x_approvals_complete OUT NOCOPY VARCHAR2,
			    x_return_status OUT NOCOPY VARCHAR2
			    );

   PROCEDURE CHECK_COMPLIANCE(
			    p_response_header_id IN NUMBER,
			    o_comply out nocopy varchar2,
			    o_rules_desc out nocopy varchar2,
			    x_return_status OUT NOCOPY VARCHAR2
			    );

   procedure process_user_action(p_response_header_id in number,
				 p_user_id in number,
				 p_action_code in varchar2,
				 p_comments in varchar2,
				 p_standalone_call in boolean default false,
				 x_approvals_complete out nocopy varchar2,
				 x_return_status out nocopy varchar2);

   procedure process_user_action(p_response_header_id in number,
				 p_user_name in varchar2,
				 p_action_code in varchar2,
				 p_comments in varchar2,
				 p_standalone_call in boolean default false,
				 x_approvals_complete out nocopy varchar2,
				 x_return_status out nocopy varchar2);

   procedure synch_approvals(p_original_response_id in number,
			     p_new_response_id in number,
			     x_return_status out nocopy varchar2);

   procedure process_stuck_notifications(
					 p_response_header_id in number,
					 p_user_id in number,
					 p_action_code in varchar2,
					 x_return_status out nocopy varchar2);


   procedure clear_action_history(
				  p_response_header_id in number,
				  p_user_id in number,
				  p_action_code in varchar2,
				  x_return_status out nocopy varchar2);

END QPR_DEAL_APPROVALS_PVT;

/
