--------------------------------------------------------
--  DDL for Package CUG_GENERIC_WF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CUG_GENERIC_WF_PKG" AUTHID CURRENT_USER AS
/* $Header: CUGGNWFS.pls 115.17 2003/02/20 22:31:51 rhungund noship $ */
--
-- To modify this template, edit file PKGSPEC.TXT in TEMPLATE
-- directory of SQL Navigator
--
-- Purpose: Briefly explain the functionality of the package
--
-- MODIFICATION HISTORY
-- Person      Date    Comments
-- ---------   ------  ------------------------------------------
   -- Enter package declarations as shown below



    PROCEDURE GET_OTHER_SR_ATTRIBUTES(
                itemtype	VARCHAR2,
				itemkey		VARCHAR2,
				actid		NUMBER,
				funmode		VARCHAR2,
				result		OUT NOCOPY VARCHAR2 );

    PROCEDURE REPLACE_SR_OWNER(
                itemtype	VARCHAR2,
				itemkey		VARCHAR2,
				actid		NUMBER,
				funmode		VARCHAR2,
				result		OUT NOCOPY VARCHAR2 );

    PROCEDURE ALLOW_ADDRESS_OVERWRITE(
                itemtype	VARCHAR2,
				itemkey		VARCHAR2,
				actid		NUMBER,
				funmode		VARCHAR2,
				result		OUT NOCOPY VARCHAR2 );

    PROCEDURE DUPLICATE_CHECKING_REQUIRED(
                itemtype	VARCHAR2,
				itemkey		VARCHAR2,
				actid		NUMBER,
				funmode		VARCHAR2,
				result		OUT NOCOPY VARCHAR2 );

    PROCEDURE SR_A_DUPLICATE(
                itemtype	VARCHAR2,
				itemkey		VARCHAR2,
				actid		NUMBER,
				funmode		VARCHAR2,
				result		OUT NOCOPY VARCHAR2 );

    PROCEDURE UPDATE_DUPLICATE_INFO(
                itemtype	VARCHAR2,
				itemkey		VARCHAR2,
				actid		NUMBER,
				funmode		VARCHAR2,
				result		OUT NOCOPY VARCHAR2 );

    PROCEDURE CREATE_ALL_SR_TASKS(
                itemtype	VARCHAR2,
				itemkey		VARCHAR2,
				actid		NUMBER,
				funmode		VARCHAR2,
				result		OUT NOCOPY VARCHAR2 );

    PROCEDURE CHECK_ON_TASK_STATUS(
                itemtype	VARCHAR2,
				itemkey		VARCHAR2,
				actid		NUMBER,
				funmode		VARCHAR2,
				result		OUT NOCOPY VARCHAR2 );


    PROCEDURE CALCULATE_DUPLICATE_TIME_FRAME(p_service_request_id NUMBER,
                                             p_request_type_id NUMBER,
                                             p_duplicate_time_frame OUT NOCOPY DATE);


   PROCEDURE CALCULATE_DATE(p_uom IN VARCHAR2,
                            p_offset IN NUMBER,
                            x_date OUT NOCOPY DATE);

  PROCEDURE start_task_workflow (
      p_api_version         IN       NUMBER,
      p_init_msg_list       IN       VARCHAR2 DEFAULT fnd_api.g_false,
      p_commit              IN       VARCHAR2 DEFAULT fnd_api.g_false,
      p_task_id             IN       NUMBER,
      p_old_assignee_code   IN       VARCHAR2 DEFAULT NULL,
      p_old_assignee_id     IN       NUMBER DEFAULT NULL,
      p_new_assignee_code   IN       VARCHAR2 DEFAULT NULL,
      p_new_assignee_id     IN       NUMBER DEFAULT NULL,
      p_old_owner_code      IN       VARCHAR2 DEFAULT NULL,
      p_old_owner_id        IN       NUMBER DEFAULT NULL,
      p_new_owner_code      IN       VARCHAR2 DEFAULT NULL,
      p_new_owner_id        IN       NUMBER DEFAULT NULL,
      p_wf_display_name     IN       VARCHAR2 DEFAULT NULL,
      p_tsk_typ_attr_dep_id IN       NUMBER,
      p_wf_process          IN       VARCHAR2 DEFAULT 'TASK_WORKFLOW',
      p_wf_item_type        IN       VARCHAR2 DEFAULT 'JTFTASK',
      x_return_status       OUT      NOCOPY VARCHAR2,
      x_msg_count           OUT      NOCOPY NUMBER,
      x_msg_data            OUT      NOCOPY VARCHAR2
   );


   PROCEDURE VALIDATE_TASK_DETAILS(p_task_type_id NUMBER,
                                   p_task_status_id NUMBER,
                                   p_task_priority_id NUMBER,
                                   p_itemkey  VARCHAR2,
                                   p_return_status OUT NOCOPY VARCHAR2);



  PROCEDURE Update_CIC_Request_Info ( itemtype  VARCHAR2,
                                  itemkey       VARCHAR2,
                                  actid         NUMBER,
                                  funmode       VARCHAR2,
                                  result        OUT NOCOPY VARCHAR2 );

  PROCEDURE CIC_Initialize_Request(itemtype        VARCHAR2,
                                itemkey         VARCHAR2,
                                actid           NUMBER,
                                funmode         VARCHAR2,
                                result          OUT NOCOPY VARCHAR2 );
END; -- Package spec

 

/
