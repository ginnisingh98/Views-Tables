--------------------------------------------------------
--  DDL for Package IGC_CC_ROUTING_CTRLS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGC_CC_ROUTING_CTRLS_PKG" AUTHID CURRENT_USER as
/* $Header: IGCCCTLS.pls 120.3.12000000.2 2007/10/08 05:51:21 smannava ship $ */


/* ================================================================================
                         PROCEDURE Insert_Row
   ===============================================================================*/

  PROCEDURE Insert_Row(
		       p_api_version               IN       NUMBER,
                       p_init_msg_list             IN       VARCHAR2 := FND_API.G_FALSE,
                       p_commit                    IN       VARCHAR2 := FND_API.G_FALSE,
                       p_validation_level          IN       NUMBER   := FND_API.G_VALID_LEVEL_FULL,
                       x_return_status             OUT NOCOPY      VARCHAR2,
                       x_msg_count                 OUT NOCOPY      NUMBER,
                       x_msg_data                  OUT NOCOPY      VARCHAR2,
                       p_Rowid                IN OUT NOCOPY    VARCHAR2,
                       p_ORG_ID                       IGC_CC_ROUTING_CTRLS_ALL.ORG_ID%TYPE,
                       p_CC_TYPE                      IGC_CC_ROUTING_CTRLS_ALL.CC_TYPE%TYPE,
                       p_CC_STATE                     IGC_CC_ROUTING_CTRLS_ALL.CC_STATE%TYPE,
                       p_CC_CAN_PRPR_APPRV_FLAG       IGC_CC_ROUTING_CTRLS_ALL.CC_CAN_PRPR_APPRV_FLAG%TYPE,
                       p_CC_CAN_PRPR_ENCMBR_FLAG      IGC_CC_ROUTING_CTRLS_ALL.CC_CAN_PRPR_ENCMBR_FLAG%TYPE,
                       p_wf_approval_itemtype         IGC_CC_ROUTING_CTRLS_ALL.WF_APPROVAL_ITEMTYPE%TYPE,
                       p_wf_approval_process          IGC_CC_ROUTING_CTRLS_ALL.WF_APPROVAL_PROCESS%TYPE,
                       p_DEFAULT_APPROVAL_PATH_ID     IGC_CC_ROUTING_CTRLS_ALL.DEFAULT_APPROVAL_PATH_ID%TYPE,
                       p_LAST_UPDATE_DATE             IGC_CC_ROUTING_CTRLS_ALL.LAST_UPDATE_DATE%TYPE,
                       p_LAST_UPDATE_LOGIN            IGC_CC_ROUTING_CTRLS_ALL.LAST_UPDATE_LOGIN%TYPE,
                       p_CREATION_DATE                IGC_CC_ROUTING_CTRLS_ALL.CREATION_DATE%TYPE,
                       p_LAST_UPDATED_BY              IGC_CC_ROUTING_CTRLS_ALL.LAST_UPDATED_BY%TYPE,
                       p_CREATED_BY                   IGC_CC_ROUTING_CTRLS_ALL.CREATED_BY%TYPE
                      );

  PROCEDURE Lock_Row(
		       p_api_version               IN       NUMBER,
                       p_init_msg_list             IN       VARCHAR2 := FND_API.G_FALSE,
                       p_commit                    IN       VARCHAR2 := FND_API.G_FALSE,
                       p_validation_level          IN       NUMBER   := FND_API.G_VALID_LEVEL_FULL,
                       x_return_status             OUT NOCOPY      VARCHAR2,
                       x_msg_count                 OUT NOCOPY      NUMBER,
                       x_msg_data                  OUT NOCOPY      VARCHAR2,

                       p_Rowid                IN OUT NOCOPY    VARCHAR2,
                       p_ORG_ID                       IGC_CC_ROUTING_CTRLS_ALL.ORG_ID%TYPE,
                       p_CC_TYPE                      IGC_CC_ROUTING_CTRLS_ALL.CC_TYPE%TYPE,
                       p_CC_STATE                     IGC_CC_ROUTING_CTRLS_ALL.CC_STATE%TYPE,
                       p_CC_CAN_PRPR_APPRV_FLAG       IGC_CC_ROUTING_CTRLS_ALL.CC_CAN_PRPR_APPRV_FLAG%TYPE,
                       p_CC_CAN_PRPR_ENCMBR_FLAG      IGC_CC_ROUTING_CTRLS_ALL.CC_CAN_PRPR_ENCMBR_FLAG%TYPE,
                       p_wf_approval_itemtype         IGC_CC_ROUTING_CTRLS_ALL.WF_APPROVAL_ITEMTYPE%TYPE,
                       p_wf_approval_process          IGC_CC_ROUTING_CTRLS_ALL.WF_APPROVAL_PROCESS%TYPE,
                       p_DEFAULT_APPROVAL_PATH_ID     IGC_CC_ROUTING_CTRLS_ALL.DEFAULT_APPROVAL_PATH_ID%TYPE,
                       p_LAST_UPDATE_DATE             IGC_CC_ROUTING_CTRLS_ALL.LAST_UPDATE_DATE%TYPE,
                       p_LAST_UPDATE_LOGIN            IGC_CC_ROUTING_CTRLS_ALL.LAST_UPDATE_LOGIN%TYPE,
                       p_CREATION_DATE                IGC_CC_ROUTING_CTRLS_ALL.CREATION_DATE%TYPE,
                       p_LAST_UPDATED_BY              IGC_CC_ROUTING_CTRLS_ALL.LAST_UPDATED_BY%TYPE,
                       p_CREATED_BY                   IGC_CC_ROUTING_CTRLS_ALL.CREATED_BY%TYPE,
                       p_row_locked                OUT NOCOPY      VARCHAR2
                    );

  PROCEDURE Update_Row(
		       p_api_version               IN       NUMBER,
                       p_init_msg_list             IN       VARCHAR2 := FND_API.G_FALSE,
                       p_commit                    IN       VARCHAR2 := FND_API.G_FALSE,
                       p_validation_level          IN       NUMBER   := FND_API.G_VALID_LEVEL_FULL,
                       x_return_status             OUT NOCOPY      VARCHAR2,
                       x_msg_count                 OUT NOCOPY      NUMBER,
                       x_msg_data                  OUT NOCOPY      VARCHAR2,

                       p_Rowid                IN OUT NOCOPY    VARCHAR2,
                       p_ORG_ID                       IGC_CC_ROUTING_CTRLS_ALL.ORG_ID%TYPE,
                       p_CC_TYPE                      IGC_CC_ROUTING_CTRLS_ALL.CC_TYPE%TYPE,
                       p_CC_STATE                     IGC_CC_ROUTING_CTRLS_ALL.CC_STATE%TYPE,
                       p_CC_CAN_PRPR_APPRV_FLAG       IGC_CC_ROUTING_CTRLS_ALL.CC_CAN_PRPR_APPRV_FLAG%TYPE,
                       p_CC_CAN_PRPR_ENCMBR_FLAG      IGC_CC_ROUTING_CTRLS_ALL.CC_CAN_PRPR_ENCMBR_FLAG%TYPE,
                       p_wf_approval_itemtype         IGC_CC_ROUTING_CTRLS_ALL.WF_APPROVAL_ITEMTYPE%TYPE,
                       p_wf_approval_process          IGC_CC_ROUTING_CTRLS_ALL.WF_APPROVAL_PROCESS%TYPE,
                       p_DEFAULT_APPROVAL_PATH_ID     IGC_CC_ROUTING_CTRLS_ALL.DEFAULT_APPROVAL_PATH_ID%TYPE,
                       p_LAST_UPDATE_DATE             IGC_CC_ROUTING_CTRLS_ALL.LAST_UPDATE_DATE%TYPE,
                       p_LAST_UPDATE_LOGIN            IGC_CC_ROUTING_CTRLS_ALL.LAST_UPDATE_LOGIN%TYPE,
                       p_CREATION_DATE                IGC_CC_ROUTING_CTRLS_ALL.CREATION_DATE%TYPE,
                       p_LAST_UPDATED_BY              IGC_CC_ROUTING_CTRLS_ALL.LAST_UPDATED_BY%TYPE,
                       p_CREATED_BY                   IGC_CC_ROUTING_CTRLS_ALL.CREATED_BY%TYPE
                      );

  PROCEDURE Delete_Row(p_api_version               IN       NUMBER,
  			p_init_msg_list             IN       VARCHAR2 := FND_API.G_FALSE,
  			p_commit                    IN       VARCHAR2 := FND_API.G_FALSE,
 			p_validation_level          IN       NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  			x_return_status             OUT NOCOPY      VARCHAR2,
  			x_msg_count                 OUT NOCOPY      NUMBER,
  			x_msg_data                  OUT NOCOPY      VARCHAR2,
  			p_Rowid                              VARCHAR2);

END IGC_CC_ROUTING_CTRLS_PKG;
 

/
