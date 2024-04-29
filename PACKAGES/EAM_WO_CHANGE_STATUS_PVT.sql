--------------------------------------------------------
--  DDL for Package EAM_WO_CHANGE_STATUS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EAM_WO_CHANGE_STATUS_PVT" AUTHID CURRENT_USER AS
/* $Header: EAMVWOSS.pls 120.3.12010000.4 2010/04/19 11:14:07 vchidura ship $ */
/***************************************************************************
--
--  Copyright (c) 2002 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      EAMVWOSS.pls
--
--  DESCRIPTION
--
--      Spec of package EAM_WO_CHANGE_STATUS_PVT
--
--  NOTES
--
--  HISTORY
--
--  12-JUN-2002    Amit Mondal     Initial Creation
***************************************************************************/


   PROCEDURE change_status (
                    p_api_version        IN       NUMBER
                   ,p_init_msg_list      IN       VARCHAR2 := fnd_api.g_false
                   ,p_commit             IN       VARCHAR2 := fnd_api.g_false
                   ,p_validation_level   IN       NUMBER := fnd_api.g_valid_level_full
                   ,p_wip_entity_id      IN       NUMBER
                   ,p_organization_id    IN       NUMBER
                   ,p_to_status_type     IN       NUMBER  := wip_constants.unreleased
                   ,p_user_id            IN       NUMBER  := null
                   ,p_responsibility_id  IN       NUMBER  := null
		   ,p_date_released      IN       DATE    := sysdate
		   , p_report_type           IN        NUMBER := null
                   , p_actual_close_date      IN    DATE := sysdate
                   , p_submission_date       IN     DATE  := sysdate
		   ,p_work_order_mode    IN       NUMBER  := EAM_PROCESS_WO_PVT.G_OPR_CREATE
                   ,x_request_id         OUT NOCOPY      NUMBER
                   ,x_return_status      OUT NOCOPY      VARCHAR2
                   ,x_msg_count          OUT NOCOPY      NUMBER
                   ,x_msg_data           OUT NOCOPY      VARCHAR2
                   ,x_Mesg_Token_Tbl     OUT NOCOPY EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type);

   /*Procedure to create osp requisitions at workorder release
     This procedure will check if there are any existing requisitions for each operation.
     If reqs. are not there then osp requisitions will be created for such operations
    */
    PROCEDURE create_osp_req_at_rel
                     (
		         p_wip_entity_id     IN   NUMBER,
			 p_organization_id   IN   NUMBER);

    FUNCTION PO_REQ_EXISTS ( p_wip_entity_id	in	NUMBER
			  ,p_rep_sched_id	in	NUMBER
			  ,p_organization_id	in	NUMBER
			  ,p_op_seq_num		in	NUMBER default NULL
			  ,p_res_seq_num	in	NUMBER default NULL
			  ,p_entity_type	in	NUMBER
			 ) RETURN BOOLEAN;

END EAM_WO_CHANGE_STATUS_PVT;






/
