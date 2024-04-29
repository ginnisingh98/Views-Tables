--------------------------------------------------------
--  DDL for Package CSD_REPAIRS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSD_REPAIRS_PVT" AUTHID CURRENT_USER AS
/* $Header: csdvdras.pls 120.7.12010000.2 2008/10/29 06:38:06 subhat ship $ */
--
-- Package name     : CSD_REPAIRS_PVT
-- Purpose          : This package contains the private APIs for creating,
--                    updating, deleting repair orders. Access is
--                    restricted to Oracle Depot Rapair Internal Development.
-- History          :
-- Version       Date       Name        Description
-- 115.0         11/17/99   pkdas       Created.
-- 115.1         12/20/99   pkdas
-- 115.2         01/04/00   pkdas
-- 115.3         02/14/00   pkdas       Added p_REPAIR_LINE_ID as IN parameter in the Create_Repairs
--                                      procedure.
--                                      Added p_REPAIR_NUMBER as OUT parameter in the Create_Repairs
--                                      procedure.
-- 115.4         02/29/00   pkdas       Changed the procedure name
--                                      Create_Repairs -> Create_Repair_Order
--                                      Update_Repairs -> Update_Repair_Order
-- 11.16         05/19/05   vparvath    Adding update_ro_status private API for R12 development.
--
-- NOTE             :


 -- Added new record for R12 development.
/*--------------------------------------------------*/
/* Record name : Flwsts_Wf_Rec_Type                 */
/* description : Record to create workflow for flow */
/*               status transition.                 */
/*--------------------------------------------------*/
   TYPE Flwsts_Wf_Rec_Type IS RECORD(
      repair_line_id 		NUMBER,
      repair_type_id 		NUMBER,
      from_flow_status_id 	NUMBER,
      to_flow_status_id 	NUMBER,
      object_version_number   NUMBER,
      wf_item_type		VARCHAR2(8),
      wf_item_key	            VARCHAR2(240),
      wf_process_name		VARCHAR2(30)
      );

/*--------------------------------------------------*/
/* Record name : RO_STATUS_BEVENT_REC_TYPE          */
/* description : Repair Order Status Business Event */
/*               Record                             */
/*--------------------------------------------------*/
   TYPE RO_STATUS_BEVENT_REC_TYPE IS RECORD(
      REPAIR_LINE_ID         NUMBER,
      FROM_FLOW_STATUS_ID    NUMBER,
      TO_FLOW_STATUS_ID      NUMBER,
      OBJECT_VERSION_NUMBER  NUMBER
      );

--
--   *******************************************************
--   API Name:  Create_Repair_Order
--   Type    :  Private
--   Pre-Req :  None
--   Parameters:
--   IN
--     p_api_version_number       IN   NUMBER     Required
--     p_init_msg_list            IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--     p_commit                   IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--     p_validation_level         IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--     p_REPAIR_LINE_ID           IN   NUMBER     Optional  Default = FND_API.G_MISS_NUM
--     p_REPLN_rec                IN   CSD_REPAIRS_PUB.REPLN_rec_type Required
--   OUT
--     x_REPAIR_LINE_ID           OUT NOCOPY  NUMBER
--     x_REPAIR_NUMBER            OUT NOCOPY  VARCHAR2
--     x_return_status            OUT NOCOPY  VARCHAR2
--     x_msg_count                OUT NOCOPY  NUMBER
--     x_msg_data                 OUT NOCOPY  VARCHAR2
--
--   Version : Current version 1.0
--             Initial Version 1.0
--
--   Notes: This API will create a Repair Order. User can pass REPAIR_LINE_ID.
--          If passed, it will be validated
--          for uniqueness and if valid, the same ID will be returned.
--          User can pass REPAIR_NUMBER also. If passed, it will be validated
--          for uniqueness and if valid, the same NUMBER will be returned.
--
PROCEDURE Create_Repair_Order(
  P_Api_Version_Number         IN   NUMBER,
  P_Init_Msg_List              IN   VARCHAR2     := Fnd_Api.G_FALSE,
  P_Commit                     IN   VARCHAR2     := Fnd_Api.G_FALSE,
  p_validation_level           IN   NUMBER       := Fnd_Api.G_VALID_LEVEL_FULL,
  p_REPAIR_LINE_ID             IN   NUMBER       := Fnd_Api.G_MISS_NUM,
  P_REPLN_Rec                  IN   Csd_Repairs_Pub.REPLN_Rec_Type,
  X_REPAIR_LINE_ID             OUT NOCOPY  NUMBER,
  X_REPAIR_NUMBER              OUT NOCOPY  VARCHAR2,
  X_Return_Status              OUT NOCOPY  VARCHAR2,
  X_Msg_Count                  OUT NOCOPY  NUMBER,
  X_Msg_Data                   OUT NOCOPY  VARCHAR2
  );

--   *******************************************************
--   API Name:  Update_Repair_Order
--   Type    :  Private
--   Pre-Req :
--   Parameters:
--   IN
--     p_api_version_number      IN   NUMBER     Required
--     p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--     p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--     p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--     p_REPAIR_LINE_ID          IN   NUMBER     Required
--     P_REPLN_Rec               IN   CSD_REPAIRS_PUB.REPLN_Rec_Type  Required
--
--   OUT
--     x_return_status           OUT NOCOPY  VARCHAR2
--     x_msg_count               OUT NOCOPY  NUMBER
--     x_msg_data                OUT NOCOPY  VARCHAR2
--
--   Version : Current Version 1.0
--             Initial Verision 1.0
--
PROCEDURE Update_Repair_Order(
  P_Api_Version_Number     IN     NUMBER,
  P_Init_Msg_List          IN     VARCHAR2     := Fnd_Api.G_FALSE,
  P_Commit                 IN     VARCHAR2     := Fnd_Api.G_FALSE,
  p_validation_level       IN     NUMBER       := Fnd_Api.G_VALID_LEVEL_FULL,
  p_REPAIR_LINE_ID         IN     NUMBER,
  P_REPLN_Rec              IN OUT NOCOPY Csd_Repairs_Pub.REPLN_Rec_Type,
  X_Return_Status          OUT NOCOPY    VARCHAR2,
  X_Msg_Count              OUT NOCOPY    NUMBER,
  X_Msg_Data               OUT NOCOPY    VARCHAR2
  );

--   *******************************************************
--   API Name:  Delete_Repair_Order
--   Type    :  Private
--   Pre-Req :
--   Parameters:
--   IN
--     p_api_version_number      IN   NUMBER     Required
--     p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--     p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--     p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--     p_REPAIR_LINE_ID          IN   NUMBER     Required
--
--   OUT
--       x_return_status         OUT NOCOPY  VARCHAR2
--       x_msg_count             OUT NOCOPY  NUMBER
--       x_msg_data              OUT NOCOPY  VARCHAR2
--
--   Version : Current Version 1.0
--             Initial Version 1.0
--
PROCEDURE Delete_Repair_Order(
  P_Api_Version_Number         IN   NUMBER,
  P_Init_Msg_List              IN   VARCHAR2     := Fnd_Api.G_FALSE,
  P_Commit                     IN   VARCHAR2     := Fnd_Api.G_FALSE,
  p_validation_level           IN   NUMBER       := Fnd_Api.G_VALID_LEVEL_FULL,
  p_REPAIR_LINE_ID             IN   NUMBER,
  X_Return_Status              OUT NOCOPY  VARCHAR2,
  X_Msg_Count                  OUT NOCOPY  NUMBER,
  X_Msg_Data                   OUT NOCOPY  VARCHAR2
  );

--   *******************************************************
--   API Name:  Validate_Repairs
--   Type    :  Private
--   Pre-Req :  None
--   Parameters:
--   IN
--     p_api_version_number       IN   NUMBER     Required
--     p_init_msg_list            IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--     p_validation_level         IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--     P_Validation_mode          IN   VARCHAR2   Required
--     p_REPAIR_LINE_ID           IN   NUMBER     Optional  Default = FND_API.G_MISS_NUM
--     p_REPLN_rec                IN   CSD_REPAIRS_PUB.REPLN_rec_type Required
--   OUT
--     x_return_status            OUT NOCOPY  VARCHAR2
--     x_msg_count                OUT NOCOPY  NUMBER
--     x_msg_data                 OUT NOCOPY  VARCHAR2
--
--   Version : Current version 1.0
--             Initial Version 1.0
--
--   Notes: This API will validate the Repair Order.
--
PROCEDURE Validate_Repairs
  (
   P_Api_Version_Number         IN   NUMBER,
   p_init_msg_list              IN   VARCHAR2 := Fnd_Api.G_FALSE,
   p_validation_level           IN   NUMBER := Fnd_Api.G_VALID_LEVEL_FULL,
   P_Validation_mode            IN   VARCHAR2,
   p_repair_line_id             IN   NUMBER := Fnd_Api.G_MISS_NUM,
   P_REPLN_Rec                  IN   Csd_Repairs_Pub.REPLN_Rec_Type,
   P_OLD_REPLN_Rec              IN   Csd_Repairs_Pub.REPLN_Rec_Type := Csd_Repairs_Pub.G_MISS_REPLN_Rec,
   x_return_status              OUT NOCOPY  VARCHAR2,
   x_msg_count                  OUT NOCOPY  NUMBER,
   x_msg_data                   OUT NOCOPY  VARCHAR2,
   --bug#7242791, 12.1 FP, subhat
   x_dff_rec                    OUT NOCOPY CSD_REPAIRS_UTIL.DEF_Rec_Type
  );

-- *************************************************************
--   API Name:  Copy_Attachments
--   Type    :  Private
--   Pre-Req :  None
--   Parameters:
--   IN
--     p_api_version           IN  NUMBER
--     p_commit                IN  VARCHAR2
--     p_init_msg_list         IN  VARCHAR2
--     P_validation_mode       IN  NUMBER
--     p_original_ro_id        IN  NUMBER
--     p_new_ro_id             IN  NUMBER
--   OUT
--     x_return_status
--     x_msg_count
--     x_msg_data
--
--   Version : Current version 1.0
--             Initial Version 1.0
--
--   Description : This API Copies all the Attachments from the
--                 original Repair order to the new Repair order.
-- ***************************************************************

PROCEDURE Copy_Attachments
  (
  p_api_version       IN          NUMBER,
  p_commit            IN          VARCHAR2,
  p_init_msg_list     IN          VARCHAR2,
  p_validation_level  IN          NUMBER,
  x_return_status     OUT NOCOPY  VARCHAR2,
  x_msg_count         OUT NOCOPY  NUMBER,
  x_msg_data          OUT NOCOPY  VARCHAR2,
  p_original_ro_id    IN          NUMBER,
  p_new_ro_id         IN          NUMBER
);

--   *******************************************************
--   API Name:  Delete_Attachments
--   Type    :  Private
--   Pre-Req :  None
--   Parameters:
--   IN
--     p_api_version        IN  NUMBER
--     p_commit             IN  VARCHAR2
--     p_init_msg_list      IN  VARCHAR2
--     P_validation_level   IN  NUMBER
--     p_repair_line_id     IN  NUMBER
--   OUT
--     x_return_status
--     x_msg_count
--     x_msg_data
--
--   Version : Current version 1.0
--             Initial Version 1.0
--
--   Description : This API Deletes all the Attachments linked
--                 to the Repair order (p_repair_line_id).
--
-- ***********************************************************

PROCEDURE Delete_Attachments
  (
  p_api_version       IN          NUMBER,
  p_commit            IN          VARCHAR2,
  p_init_msg_list     IN          VARCHAR2,
  p_validation_level  IN          NUMBER,
  x_return_status     OUT NOCOPY  VARCHAR2,
  x_msg_count         OUT NOCOPY  NUMBER,
  x_msg_data          OUT NOCOPY  VARCHAR2,
  p_repair_line_id    IN          NUMBER
);

-- R12 development changes begin...
--   *******************************************************
--   API Name:  update_ro_status
--   Type    :  Private
--   Pre-Req :  None
--   Parameters:
--   IN
--     p_api_version               IN     NUMBER,
--     p_commit                    IN     VARCHAR2,
--     p_init_msg_list             IN     VARCHAR2,
--     p_validation_level          IN     NUMBER,
--     p_repair_status_rec         IN     CSD_REPAIRS_PUB.REPAIR_STATUS_REC,
--     p_status_control_rec  	     IN     CSD_REPAIRS_PUB.STATUS_UPD_CONTROL_REC,
--   OUT
--     x_return_status
--     x_msg_count
--     x_msg_data
--     x_object_version_number     OUT     NUMBER
--
--   Version : Current version 1.0
--             Initial Version 1.0
--
--   Description : This API updates the repair status to a given value.
--                 It checks for the open tasks/wipjobs based on the input
--                 flag p_check_task_wip in the status control record.
--
--
-- ***********************************************************
	PROCEDURE UPDATE_RO_STATUS
	(
		p_api_version               IN     NUMBER,
		p_commit                    IN     VARCHAR2,
		p_init_msg_list             IN     VARCHAR2,
		p_validation_level          IN     NUMBER,
		x_return_status             OUT    NOCOPY    VARCHAR2,
		x_msg_count                 OUT    NOCOPY    NUMBER,
		x_msg_data                  OUT    NOCOPY    VARCHAR2,
		p_repair_status_Rec         IN     Csd_Repairs_Pub.REPAIR_STATUS_REC_TYPE,
		p_status_control_rec        IN     Csd_Repairs_Pub.STATUS_UPD_CONTROL_REC_TYPE,
		x_object_version_number     OUT    NOCOPY     NUMBER
	);


--   *******************************************************
--   API Name:  UPDATE_RO_STATUS_WebSrvc
--   Type    :  Private
--   Pre-Req :  None
--   Parameters:
--   IN
--     p_api_version               IN     NUMBER,
--     p_commit                    IN     VARCHAR2,
--     p_init_msg_list             IN     VARCHAR2,
--     p_validation_level          IN     NUMBER,
--     p_repair_line_id           IN      NUMEBR
--     p_repair_status            IN
--   OUT
--     x_return_status
--     x_msg_count
--     x_msg_data
--
--   Version : Current version 1.0
--             Initial Version 1.0
--
--   Description : This API updates is a wrapper around the update_ro_Status
--                 private API. THis is used by the web service.
--
--
-- ***********************************************************
	PROCEDURE UPDATE_RO_STATUS_WebSrvc
	(
		p_api_version               IN     NUMBER,
		p_commit                    IN     VARCHAR2,
		p_init_msg_list             IN     VARCHAR2,
		x_return_status             OUT    NOCOPY    VARCHAR2,
		x_msg_count                 OUT    NOCOPY    NUMBER,
		x_msg_data                  OUT    NOCOPY    VARCHAR2,
		p_repair_line_id            IN     NUMBER,
		p_repair_status      	    IN    VARCHAR2,
		p_reason_code               IN     VARCHAR2,
		p_comments                  IN     VARCHAR2,
		p_check_task_wip	          IN     VARCHAR2,
		p_object_version_number     IN     NUMBER

	 );


   PROCEDURE Update_Flow_Status (
      p_api_version           IN    NUMBER,
      p_commit                IN    VARCHAR2,
      p_init_msg_list         IN    VARCHAR2,
      p_validation_level      IN    NUMBER,
      x_return_status         OUT 	NOCOPY    VARCHAR2,
      x_msg_count             OUT 	NOCOPY    NUMBER,
      x_msg_data              OUT 	NOCOPY    VARCHAR2,
      p_repair_line_id 		IN	NUMBER,
      p_repair_type_id 		IN	NUMBER,
      p_from_flow_status_id 	IN 	NUMBER,
      p_to_flow_status_id 	IN 	NUMBER,
      p_reason_code 		IN 	VARCHAR2,
      p_comments	 		IN 	VARCHAR2,
      p_check_access_flag 	IN 	VARCHAR2,
      p_object_version_number IN 	NUMBER,
      x_object_version_number OUT 	NOCOPY    NUMBER
      );

   FUNCTION Is_Rt_Update_Allowed (
      p_from_repair_type_id 	IN 	NUMBER,
      p_to_repair_type_id 	IN 	NUMBER,
      p_common_flow_status_id IN 	NUMBER,
      p_responsibility_id 	IN 	NUMBER
      ) RETURN BOOLEAN;

   PROCEDURE Update_Repair_Type (
      p_api_version           IN    NUMBER,
      p_commit                IN    VARCHAR2,
      p_init_msg_list         IN    VARCHAR2,
      p_validation_level      IN    NUMBER,
      x_return_status         OUT 	NOCOPY    VARCHAR2,
      x_msg_count             OUT 	NOCOPY    NUMBER,
      x_msg_data              OUT 	NOCOPY    VARCHAR2,
      p_repair_line_id        IN    NUMBER,
      p_from_repair_type_id 	IN 	NUMBER,
      p_to_repair_type_id 	IN 	NUMBER,
      p_common_flow_status_id IN    NUMBER,
      p_reason_code 		IN 	VARCHAR2,
      p_object_version_number IN 	NUMBER,
      x_object_version_number OUT 	NOCOPY NUMBER
      );

   FUNCTION Is_Flwsts_Update_Allowed(
      p_repair_type_id 		IN 	NUMBER,
      p_from_flow_status_id 	IN 	NUMBER,
      p_to_flow_status_id 	IN 	NUMBER,
      p_responsibility_id     IN    NUMBER
      ) RETURN BOOLEAN;

   PROCEDURE Launch_Flwsts_Wf (
      p_api_version           IN    NUMBER,
      p_commit                IN    VARCHAR2,
      p_init_msg_list         IN    VARCHAR2,
      p_validation_level      IN    NUMBER,
      x_return_status         OUT 	NOCOPY    VARCHAR2,
      x_msg_count             OUT 	NOCOPY    NUMBER,
      x_msg_data              OUT 	NOCOPY    VARCHAR2,
      p_flwsts_wf_rec         IN    Flwsts_Wf_Rec_Type
      );

/*-----------------------------------------------------------------*/
/* procedure name: raise_ro_status_bevent                          */
/* description   : Procedure to raise a Business Even when the     */
/*                 status of the repair order changes              */
/*-----------------------------------------------------------------*/
    PROCEDURE raise_ro_status_bevent (
      p_ro_status_bevent_rec  IN   ro_status_bevent_rec_type,
      p_commit                IN   VARCHAR2,
      x_return_status         OUT  NOCOPY VARCHAR2,
      x_msg_count             OUT  NOCOPY NUMBER,
      x_msg_data              OUT  NOCOPY VARCHAR2
      );

-- R12 development changes End...

--  Fix for bug#5610891

/*-------------------------------------------------------------------------------------*/
/* Procedure name: UPDATE_RO_STATUS_WF                                                 */
/* Description   : Procedure called from workflow process to update repair order       */
/*                 status                                                              */
/*                                                                                     */
/* Called from   : Workflow                                                            */
/* PARAMETERS                                                                          */
/*  IN                                                                                 */
/*                                                                                     */
/*   itemtype  - type of the current item                                              */
/*   itemkey   - key of the current item                                               */
/*   actid     - process activity instance id                                          */
/*   funcmode  - function execution mode ('RUN', 'CANCEL', 'TIMEOUT', ...)             */
/*  OUT	                                                                               */
/*   result                                                                            */
/*       - COMPLETE[:<result>]                                                         */
/*           activity has completed with the indicated result                          */
/*       - WAITING                                                                     */
/*           activity is waiting for additional transitions                            */
/*       - DEFERED                                                                     */
/*           execution should be defered to background                                 */
/*       - NOTIFIED[:<notification_id>:<assigned_user>]                                */
/*           activity has notified an external entity that this                        */
/*           step must be performed.  A call to wf_engine.CompleteActivty              */
/*           will signal when this step is complete.  Optional                         */
/*           return of notification ID and assigned user.                              */
/*       - ERROR[:<error_code>]                                                        */
/*           function encountered an error.                                            */
/* Change Hist :                                                                       */
/*   04/18/07  mshirkol  Initial Creation.  ( Fix for bug#5610891 )                    */
/*-------------------------------------------------------------------------------------*/

Procedure UPDATE_RO_STATUS_WF
            (itemtype  in varchar2,
             itemkey   in varchar2,
             actid     in number,
             funcmode  in varchar2,
             resultout in out nocopy varchar2);

/*-------------------------------------------------------------------------------------*/
/* Procedure name: LAUNCH_WFEXCEPTIONS_BEVENT                                          */
/* Description   : Procedure to launch exceptions Business Event                       */
/*                                                                                     */
/* Called from   : CSD_UPDATE_PROGRAMS_PVT                                             */
/* PARAMETERS                                                                          */
/*  IN                                                                                 */
/*   p_return_status                                                                   */
/*   p_msg_count                                                                       */
/*   p_msg_data                                                                        */
/*   p_repair_line_id                                                                  */
/*   p_module_name                                                                     */
/*                                                                                     */
/* Change Hist :                                                                       */
/*   04/18/07  mshirkol  Initial Creation.  ( Fix for bug#5610891 )                    */
/*-------------------------------------------------------------------------------------*/

Procedure LAUNCH_WFEXCEPTION_BEVENT(
               p_return_status  in varchar2,
               p_msg_count      in number,
               p_msg_data       in varchar2,
               p_repair_line_id in number,
               p_module_name    in varchar2);


END Csd_Repairs_Pvt;

/
