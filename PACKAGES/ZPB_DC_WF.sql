--------------------------------------------------------
--  DDL for Package ZPB_DC_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ZPB_DC_WF" AUTHID CURRENT_USER AS
/* $Header: ZPBDCWFS.pls 120.3 2007/12/04 14:34:45 mbhat ship $ */

TYPE aw_user_tab IS TABLE OF NUMBER(15);

  PROCEDURE generate_template(
    itemtype    IN varchar2,
	itemkey     IN varchar2,
	actid       IN number,
 	funcmode    IN varchar2,
    resultout   OUT nocopy varchar2
  );

  PROCEDURE get_review_option(
    itemtype    IN varchar2,
	itemkey     IN varchar2,
	actid       IN number,
 	funcmode    IN varchar2,
    resultout   OUT nocopy varchar2
  );

  PROCEDURE auto_distribute(
    itemtype    IN varchar2,
	itemkey     IN varchar2,
	actid       IN number,
 	funcmode    IN varchar2,
    resultout   OUT nocopy varchar2
  );

  PROCEDURE manual_distribute(
    itemtype    IN varchar2,
	itemkey     IN varchar2,
	actid       IN number,
 	funcmode    IN varchar2,
    resultout   OUT nocopy varchar2
  );

  PROCEDURE raise_distribution_event(
    p_api_version               IN   NUMBER,
    p_init_msg_list             IN   VARCHAR2,
    p_commit                    IN   VARCHAR2,
    p_validation_level          IN   NUMBER,
    x_return_status             OUT  NOCOPY  VARCHAR2,
    x_msg_count                 OUT  NOCOPY  NUMBER,
    x_msg_data                  OUT  NOCOPY  VARCHAR2,
    --
    p_object_id       IN number,
	p_recipient_type  IN varchar2,
	p_dist_list_id    IN number,
	p_approver_type   IN varchar2,
	p_deadline_date   IN varchar2,
	p_overwrite_cust  IN varchar2,
	p_overwrite_data  IN varchar2,
	p_distribution_message IN varchar2
  );

  PROCEDURE set_ws_recipient(
    itemtype    IN varchar2,
	itemkey     IN varchar2,
	actid       IN number,
 	funcmode    IN varchar2,
    resultout   OUT nocopy varchar2
  );

  PROCEDURE review_complete(
    itemtype    IN varchar2,
	itemkey     IN varchar2,
	actid       IN number,
 	funcmode    IN varchar2,
    resultout   OUT nocopy varchar2
  );

  PROCEDURE get_template_count(
    itemtype    IN varchar2,
	itemkey     IN varchar2,
	actid       IN number,
 	funcmode    IN varchar2,
    resultout   OUT nocopy varchar2
  );

  PROCEDURE manage_submission(
    itemtype    IN varchar2,
	itemkey     IN varchar2,
	actid       IN number,
 	funcmode    IN varchar2,
    resultout   OUT nocopy varchar2
  );

  PROCEDURE set_template_recipient(
    itemtype    IN varchar2,
	itemkey     IN varchar2,
	actid       IN number,
 	funcmode    IN varchar2,
    resultout   OUT nocopy varchar2
  );

  PROCEDURE set_template_status(
    itemtype    IN varchar2,
	itemkey     IN varchar2,
	actid       IN number,
 	funcmode    IN varchar2,
    resultout   OUT nocopy varchar2
  );

  PROCEDURE check_template_status(
    itemtype    IN varchar2,
	itemkey     IN varchar2,
	actid       IN number,
 	funcmode    IN varchar2,
    resultout   OUT nocopy varchar2
  );

  PROCEDURE raise_submission_event(
    p_api_version               IN   NUMBER,
    p_init_msg_list             IN   VARCHAR2,
    p_commit                    IN   VARCHAR2,
    p_validation_level          IN   NUMBER,
    x_return_status             OUT  NOCOPY  VARCHAR2,
    x_msg_count                 OUT  NOCOPY  NUMBER,
    x_msg_data                  OUT  NOCOPY  VARCHAR2,
    --
    p_object_id                 IN number,
	p_submission_message        IN varchar2
  );

  PROCEDURE check_object_type(
    itemtype    IN varchar2,
	itemkey     IN varchar2,
	actid       IN number,
 	funcmode    IN varchar2,
    resultout   OUT nocopy varchar2
  );

  PROCEDURE freeze_template(
    itemtype    IN varchar2,
	itemkey     IN varchar2,
	actid       IN number,
 	funcmode    IN varchar2,
    resultout   OUT nocopy varchar2
  );

  PROCEDURE freeze_worksheet(
    itemtype    IN varchar2,
	itemkey     IN varchar2,
	actid       IN number,
 	funcmode    IN varchar2,
    resultout   OUT nocopy varchar2
  );

  PROCEDURE find_approver(
    itemtype    IN varchar2,
	itemkey     IN varchar2,
	actid       IN number,
 	funcmode    IN varchar2,
    resultout   OUT nocopy varchar2
  );

  PROCEDURE set_submit_ntf_recipients(
    itemtype    IN varchar2,
	itemkey     IN varchar2,
	actid       IN number,
 	funcmode    IN varchar2,
    resultout   OUT nocopy varchar2
  );

  PROCEDURE update_aw(
    itemtype    IN varchar2,
	itemkey     IN varchar2,
	actid       IN number,
 	funcmode    IN varchar2,
    resultout   OUT nocopy varchar2
  );

  PROCEDURE check_update_aw_type(
    itemtype    IN varchar2,
	itemkey     IN varchar2,
	actid       IN number,
 	funcmode    IN varchar2,
    resultout   OUT nocopy varchar2
  );

  PROCEDURE raise_approval_event(
    p_api_version               IN   NUMBER,
    p_init_msg_list             IN   VARCHAR2,
    p_commit                    IN   VARCHAR2,
    p_validation_level          IN   NUMBER,
    x_return_status             OUT  NOCOPY  VARCHAR2,
    x_msg_count                 OUT  NOCOPY  NUMBER,
    x_msg_data                  OUT  NOCOPY  VARCHAR2,
    --
    p_object_id                 IN number,
    p_approver_user_id          IN number,
	p_approval_message          IN varchar2
  );

  PROCEDURE raise_rejection_event(
    p_api_version               IN   NUMBER,
    p_init_msg_list             IN   VARCHAR2,
    p_commit                    IN   VARCHAR2,
    p_validation_level          IN   NUMBER,
    x_return_status             OUT  NOCOPY  VARCHAR2,
    x_msg_count                 OUT  NOCOPY  NUMBER,
    x_msg_data                  OUT  NOCOPY  VARCHAR2,
    --
    p_object_id                 IN number,
    p_approver_user_id          IN number,
	p_rejection_message         IN varchar2
  );

  PROCEDURE set_worksheet_status(
      itemtype    IN varchar2,
  	itemkey     IN varchar2,
  	actid       IN number,
   	funcmode    IN varchar2,
      resultout   OUT nocopy varchar2
  );

  PROCEDURE unblock_manage_submission(
        itemtype    IN varchar2,
    	itemkey     IN varchar2,
    	actid       IN number,
     	funcmode    IN varchar2,
        resultout   OUT nocopy varchar2
  );

  PROCEDURE check_all_ws_submitted(
        itemtype    IN varchar2,
      	itemkey     IN varchar2,
      	actid       IN number,
       	funcmode    IN varchar2,
        resultout   OUT nocopy varchar2
  );

END ZPB_DC_WF;

/
