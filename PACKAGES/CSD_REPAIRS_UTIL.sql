--------------------------------------------------------
--  DDL for Package CSD_REPAIRS_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSD_REPAIRS_UTIL" AUTHID CURRENT_USER AS
/* $Header: csdxutls.pls 120.11.12010000.7 2010/05/06 01:35:14 takwong ship $ */
--
-- Package name     : CSD_REPAIRS_UTIL
-- Purpose          : This package contains utility programs for the Depot
--                    Repair module. Access is restricted to Oracle Depot
--                    Repair Internal Development.
-- History          :
-- Version       Date       Name        Description
-- 115.0         12/18/99   pkdas       Created.
-- 115.1         01/04/00   pkdas       Added some program units.
-- 115.2         01/18/00   pkdas       Added DATE_CLOSED to Convert_to_Repln_Rec_Type procedure.
-- 115.3         02/23/00   pkdas       Added CONTRACT_LINE_ID to Convert_to_Repln_Rec_Type procedure.
-- 115.4         11/30/01   travi       Added AUTO_PROCESS_RMA, OBJECT_VERSION_NUMBER and REPAIR_MODE to
--                                      Convert_to_Repln_Rec_Type
-- 115.5         01/14/02   travi       Added Item_REVISION col.
--
-- 115.19        05/19/05   vparvath    Added check_task_n_wipjob proc for
--                                      R12 development.
--
--
-- NOTE             :
--
TYPE DEF_Rec_Type IS RECORD
(
  attribute_category        VARCHAR2(30)  := Fnd_Api.G_MISS_CHAR,
  attribute1                VARCHAR2(150) := Fnd_Api.G_MISS_CHAR,
  attribute2                VARCHAR2(150) := Fnd_Api.G_MISS_CHAR,
  attribute3                VARCHAR2(150) := Fnd_Api.G_MISS_CHAR,
  attribute4                VARCHAR2(150) := Fnd_Api.G_MISS_CHAR,
  attribute5                VARCHAR2(150) := Fnd_Api.G_MISS_CHAR,
  attribute6                VARCHAR2(150) := Fnd_Api.G_MISS_CHAR,
  attribute7                VARCHAR2(150) := Fnd_Api.G_MISS_CHAR,
  attribute8                VARCHAR2(150) := Fnd_Api.G_MISS_CHAR,
  attribute9                VARCHAR2(150) := Fnd_Api.G_MISS_CHAR,
  attribute10               VARCHAR2(150) := Fnd_Api.G_MISS_CHAR,
  attribute11               VARCHAR2(150) := Fnd_Api.G_MISS_CHAR,
  attribute12               VARCHAR2(150) := Fnd_Api.G_MISS_CHAR,
  attribute13               VARCHAR2(150) := Fnd_Api.G_MISS_CHAR,
  attribute14               VARCHAR2(150) := Fnd_Api.G_MISS_CHAR,
  attribute15               VARCHAR2(150) := Fnd_Api.G_MISS_CHAR,
  attribute16               VARCHAR2(150) := FND_API.G_MISS_CHAR, -- subhat, dff changes(bug#7497907)
  attribute17               VARCHAR2(150) := FND_API.G_MISS_CHAR,
  attribute18               VARCHAR2(150) := FND_API.G_MISS_CHAR,
  attribute19               VARCHAR2(150) := FND_API.G_MISS_CHAR,
  attribute20               VARCHAR2(150) := FND_API.G_MISS_CHAR,
  attribute21               VARCHAR2(150) := FND_API.G_MISS_CHAR,
  attribute22               VARCHAR2(150) := FND_API.G_MISS_CHAR,
  attribute23               VARCHAR2(150) := FND_API.G_MISS_CHAR,
  attribute24               VARCHAR2(150) := FND_API.G_MISS_CHAR,
  attribute25               VARCHAR2(150) := FND_API.G_MISS_CHAR,
  attribute26               VARCHAR2(150) := FND_API.G_MISS_CHAR,
  attribute27               VARCHAR2(150) := FND_API.G_MISS_CHAR,
  attribute28               VARCHAR2(150) := FND_API.G_MISS_CHAR,
  attribute29             	VARCHAR2(150) := FND_API.G_MISS_CHAR,
  attribute30               VARCHAR2(150) := FND_API.G_MISS_CHAR
);


--
-- bug#7043215, subhat.
-- changed the function signature. Changed p_attr_values to IN OUT.
-- Added a new parameter p_validate_only.
-- For validate and default pass p_validate_only = FND_API.G_FALSE
-- For validation only, pass p_validate_only = FND_API.G_TRUE(Default)
--

FUNCTION Is_DescFlex_Valid
(
  p_api_name			 IN	VARCHAR2,
  p_desc_flex_name IN	VARCHAR2,
  p_attr_values		 IN OUT NOCOPY CSD_REPAIRS_UTIL.DEF_Rec_Type,
-- bug#7043215, subhat.
  p_validate_only  IN VARCHAR2 := FND_API.G_TRUE
-- end bug#7043215, subhat.
) RETURN BOOLEAN ;

PROCEDURE Convert_to_Repln_Rec_Type
(
  p_REPAIR_NUMBER             IN      VARCHAR2 := Fnd_Api.G_MISS_CHAR,
  p_INCIDENT_ID               IN      NUMBER := Fnd_Api.G_MISS_NUM,
  p_INVENTORY_ITEM_ID         IN      NUMBER := Fnd_Api.G_MISS_NUM,
  p_CUSTOMER_PRODUCT_ID       IN      NUMBER := Fnd_Api.G_MISS_NUM,
  p_UNIT_OF_MEASURE           IN      VARCHAR2 := Fnd_Api.G_MISS_CHAR,
  p_REPAIR_TYPE_ID            IN      NUMBER := Fnd_Api.G_MISS_NUM,
-- RESOURCE_GROUP Added by Vijay 10/28/2004
  p_RESOURCE_GROUP            IN      NUMBER := Fnd_Api.G_MISS_NUM,
  p_RESOURCE_ID               IN      NUMBER := Fnd_Api.G_MISS_NUM,
  p_PROJECT_ID                IN      NUMBER := Fnd_Api.G_MISS_NUM,
  p_TASK_ID                   IN      NUMBER := Fnd_Api.G_MISS_NUM,
  p_UNIT_NUMBER               IN      VARCHAR2 := FND_API.G_MISS_CHAR, -- rfieldma, prj integration
  p_CONTRACT_LINE_ID          IN      NUMBER := Fnd_Api.G_MISS_NUM,
  p_AUTO_PROCESS_RMA          IN      VARCHAR2 := Fnd_Api.G_MISS_CHAR,
  p_REPAIR_MODE               IN      VARCHAR2 := Fnd_Api.G_MISS_CHAR,
  p_OBJECT_VERSION_NUMBER     IN      NUMBER := Fnd_Api.G_MISS_NUM,
  p_ITEM_REVISION             IN      VARCHAR2 := Fnd_Api.G_MISS_CHAR,
  p_INSTANCE_ID               IN      NUMBER := Fnd_Api.G_MISS_NUM,
  p_STATUS                    IN      VARCHAR2 := Fnd_Api.G_MISS_CHAR,
  p_STATUS_REASON_CODE        IN       VARCHAR2 := Fnd_Api.G_MISS_CHAR,
  p_DATE_CLOSED               IN      DATE := Fnd_Api.G_MISS_DATE,
  p_APPROVAL_REQUIRED_FLAG    IN      VARCHAR2 := Fnd_Api.G_MISS_CHAR,
  p_APPROVAL_STATUS           IN      VARCHAR2 := Fnd_Api.G_MISS_CHAR,
  p_SERIAL_NUMBER             IN      VARCHAR2 := Fnd_Api.G_MISS_CHAR,
  p_PROMISE_DATE              IN      DATE := Fnd_Api.G_MISS_DATE,
  p_ATTRIBUTE_CATEGORY        IN      VARCHAR2 := Fnd_Api.G_MISS_CHAR,
  p_ATTRIBUTE1                IN      VARCHAR2 := Fnd_Api.G_MISS_CHAR,
  p_ATTRIBUTE2                IN      VARCHAR2 := Fnd_Api.G_MISS_CHAR,
  p_ATTRIBUTE3                IN      VARCHAR2 := Fnd_Api.G_MISS_CHAR,
  p_ATTRIBUTE4                IN      VARCHAR2 := Fnd_Api.G_MISS_CHAR,
  p_ATTRIBUTE5                IN      VARCHAR2 := Fnd_Api.G_MISS_CHAR,
  p_ATTRIBUTE6                IN      VARCHAR2 := Fnd_Api.G_MISS_CHAR,
  p_ATTRIBUTE7                IN      VARCHAR2 := Fnd_Api.G_MISS_CHAR,
  p_ATTRIBUTE8                IN      VARCHAR2 := Fnd_Api.G_MISS_CHAR,
  p_ATTRIBUTE9                IN      VARCHAR2 := Fnd_Api.G_MISS_CHAR,
  p_ATTRIBUTE10               IN      VARCHAR2 := Fnd_Api.G_MISS_CHAR,
  p_ATTRIBUTE11               IN      VARCHAR2 := Fnd_Api.G_MISS_CHAR,
  p_ATTRIBUTE12               IN      VARCHAR2 := Fnd_Api.G_MISS_CHAR,
  p_ATTRIBUTE13               IN      VARCHAR2 := Fnd_Api.G_MISS_CHAR,
  p_ATTRIBUTE14               IN      VARCHAR2 := Fnd_Api.G_MISS_CHAR,
  p_ATTRIBUTE15               IN      VARCHAR2 := Fnd_Api.G_MISS_CHAR,
  P_ATTRIBUTE16               IN      VARCHAR2 := FND_API.G_MISS_CHAR,-- SUBHAT, DFF CHANGES(bug#7497907)
  P_ATTRIBUTE17               IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  P_ATTRIBUTE18               IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  P_ATTRIBUTE19               IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  P_ATTRIBUTE20               IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  P_ATTRIBUTE21               IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  P_ATTRIBUTE22               IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  P_ATTRIBUTE23               IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  P_ATTRIBUTE24               IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  P_ATTRIBUTE25               IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  P_ATTRIBUTE26               IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  P_ATTRIBUTE27               IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  P_ATTRIBUTE28               IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  P_ATTRIBUTE29               IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  P_ATTRIBUTE30               IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_QUANTITY                  IN      NUMBER   := Fnd_Api.G_MISS_NUM,
  p_QUANTITY_IN_WIP           IN      NUMBER   := Fnd_Api.G_MISS_NUM,
  p_QUANTITY_RCVD             IN      NUMBER   := Fnd_Api.G_MISS_NUM,
  p_QUANTITY_SHIPPED          IN      NUMBER   := Fnd_Api.G_MISS_NUM,
  p_CURRENCY_CODE             IN      VARCHAR2 := Fnd_Api.G_MISS_CHAR,
  p_DEFAULT_PO_NUM            IN      VARCHAR2 := Fnd_Api.G_MISS_CHAR,
  p_REPAIR_GROUP_ID           IN      NUMBER   := Fnd_Api.G_MISS_NUM,
  p_RO_TXN_STATUS             IN      VARCHAR2 := Fnd_Api.G_MISS_CHAR,
  p_ORDER_LINE_ID             IN      NUMBER   := Fnd_Api.G_MISS_NUM,
  p_ORIGINAL_SOURCE_REFERENCE  IN     VARCHAR2 := Fnd_Api.G_MISS_CHAR,
  p_ORIGINAL_SOURCE_HEADER_ID  IN     NUMBER   := Fnd_Api.G_MISS_NUM,
  p_ORIGINAL_SOURCE_LINE_ID    IN     NUMBER   := Fnd_Api.G_MISS_NUM,
  p_PRICE_LIST_HEADER_ID       IN     NUMBER   := Fnd_Api.G_MISS_NUM,
  p_INVENTORY_ORG_ID           IN     NUMBER   := Fnd_Api.G_MISS_NUM,
  -- swai: bug 4666344 added problem description
  p_PROBLEM_DESCRIPTION        IN     VARCHAR2 := Fnd_Api.G_MISS_CHAR,
  p_RO_PRIORITY_CODE           IN     VARCHAR2 := Fnd_Api.G_MISS_CHAR, -- swai: R12
  p_RESOLVE_BY_DATE            IN     DATE     := Fnd_Api.G_MISS_DATE, -- rfieldma: 5355051
  p_BULLETIN_CHECK_DATE        IN     DATE     := Fnd_Api.G_MISS_DATE,
  p_ESCALATION_CODE            IN     VARCHAR2 := Fnd_Api.G_MISS_CHAR,
  p_RO_WARRANTY_STATUS_CODE    IN     VARCHAR2 := Fnd_Api.G_MISS_CHAR,
  x_Repln_Rec                  OUT NOCOPY     Csd_Repairs_Pub.Repln_Rec_Type
);

PROCEDURE Convert_to_DEF_Rec_Type
(
  p_attribute_category        IN      VARCHAR2 := Fnd_Api.G_MISS_CHAR,
  p_attribute1                IN      VARCHAR2 := Fnd_Api.G_MISS_CHAR,
  p_attribute2                IN      VARCHAR2 := Fnd_Api.G_MISS_CHAR,
  p_attribute3                IN      VARCHAR2 := Fnd_Api.G_MISS_CHAR,
  p_attribute4                IN      VARCHAR2 := Fnd_Api.G_MISS_CHAR,
  p_attribute5                IN      VARCHAR2 := Fnd_Api.G_MISS_CHAR,
  p_attribute6                IN      VARCHAR2 := Fnd_Api.G_MISS_CHAR,
  p_attribute7                IN      VARCHAR2 := Fnd_Api.G_MISS_CHAR,
  p_attribute8                IN      VARCHAR2 := Fnd_Api.G_MISS_CHAR,
  p_attribute9                IN      VARCHAR2 := Fnd_Api.G_MISS_CHAR,
  p_attribute10               IN      VARCHAR2 := Fnd_Api.G_MISS_CHAR,
  p_attribute11               IN      VARCHAR2 := Fnd_Api.G_MISS_CHAR,
  p_attribute12               IN      VARCHAR2 := Fnd_Api.G_MISS_CHAR,
  p_attribute13               IN      VARCHAR2 := Fnd_Api.G_MISS_CHAR,
  p_attribute14               IN      VARCHAR2 := Fnd_Api.G_MISS_CHAR,
  p_attribute15               IN      VARCHAR2 := Fnd_Api.G_MISS_CHAR,
  p_attribute16               IN      VARCHAR2 := FND_API.G_MISS_CHAR, -- subhat, dff changes(bug#7497907)
  p_attribute17               IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_attribute18               IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_attribute19               IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_attribute20               IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_attribute21               IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_attribute22               IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_attribute23               IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_attribute24               IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_attribute25               IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_attribute26               IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_attribute27               IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_attribute28               IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_attribute29               IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_attribute30               IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  x_DEF_Rec                   OUT NOCOPY     Csd_Repairs_Util.DEF_Rec_Type
);

PROCEDURE GET_ENTITLEMENTS
(
  P_API_VERSION_NUMBER     IN      NUMBER,
  P_INIT_MSG_LIST          IN      VARCHAR2 := 'F',
  P_COMMIT                 IN      VARCHAR2 := 'F',
  P_CONTRACT_NUMBER        IN      VARCHAR2 := NULL,
  P_SERVICE_LINE_ID        IN      NUMBER := NULL,
  P_CUSTOMER_ID            IN      NUMBER := NULL,
  P_SITE_ID                IN      NUMBER := NULL,
  P_CUSTOMER_ACCOUNT_ID    IN      NUMBER := NULL,
  P_SYSTEM_ID              IN      NUMBER := NULL,
  P_INVENTORY_ITEM_ID      IN      NUMBER := NULL,
  P_CUSTOMER_PRODUCT_ID    IN      NUMBER := NULL,
  P_REQUEST_DATE           IN      DATE := NULL,
  P_VALIDATE_FLAG          IN      VARCHAR2 := 'Y',
--Begin forwardporting bug fix for 2806199,2806661,2802141 By Vijay
  P_BUSINESS_PROCESS_ID    IN      NUMBER DEFAULT NULL,
  P_SEVERITY_ID            IN      NUMBER DEFAULT NULL,
  P_TIME_ZONE_ID           IN      NUMBER DEFAULT NULL,
  P_CALC_RESPTIME_FLAG     IN      VARCHAR2 DEFAULT NULL,
--End forwardporting bug fix for 2806199,2806661,2802141 By Vijay
  X_ENT_CONTRACTS          OUT NOCOPY     Oks_Entitlements_Pub.GET_CONTOP_TBL,
  X_RETURN_STATUS          OUT NOCOPY     VARCHAR2,
  X_MSG_COUNT              OUT NOCOPY     NUMBER,
  X_MSG_DATA               OUT NOCOPY     VARCHAR2
);

-- swai: bug 4939782 (FP of ER 4723163)
/*-----------------------------------------------------------------*/
/* procedure name: change_item_ib_owner                            */
/* description   : Procedure to Change the Install Base Owner for  */
/*                 a single item                                   */
/*-----------------------------------------------------------------*/
PROCEDURE CHANGE_ITEM_IB_OWNER
(
 p_create_tca_relation    IN         VARCHAR2 := NULL,
 p_instance_id            IN         NUMBER,
 p_new_owner_party_id     IN         NUMBER,
 p_new_owner_account_id   IN         NUMBER,
 p_current_owner_party_id IN         NUMBER,
 x_return_status         OUT  NOCOPY VARCHAR2,
 x_msg_count             OUT  NOCOPY NUMBER,
 x_msg_data              OUT  NOCOPY VARCHAR2,
 x_tca_relation_id       OUT  NOCOPY NUMBER
);
-- end swai: bug 4939782 (FP of ER 4723163)

PROCEDURE Get_KB_Element_Description
(
  p_element_id           IN  NUMBER,
  p_element_description  OUT NOCOPY VARCHAR2
);

PROCEDURE Check_Reqd_Param
(
  p_param_value   IN    NUMBER,
  p_param_name    IN    VARCHAR2,
  p_api_name      IN    VARCHAR2
);

PROCEDURE Check_Reqd_Param
(
  p_param_value   IN    VARCHAR2,
  p_param_name    IN    VARCHAR2,
  p_api_name      IN    VARCHAR2
);

PROCEDURE Check_Reqd_Param
(
  p_param_value   IN    DATE,
  p_param_name    IN    VARCHAR2,
  p_api_name      IN    VARCHAR2
);

-- R12 Development Begin
--   *******************************************************
--   API Name:  check_task_n_wip
--   Type    :  Private
--   Pre-Req :  None
--   Parameters:
--   IN
--     p_repair_line_id            IN     VARCHAR2,
--     p_repair_status             IN     VARCHAR2,
--   OUT
--     x_return_status
--     x_msg_count
--     x_msg_data
--
--   Version : Current version 1.0
--             Initial Version 1.0
--
--   Description : This API checks if there are any open tasks or wip jobs
--                  for the repair order if the status is 'C'. If there are
--                 open tasks or wipjobs depending on the mode, this api
--                 returns FAILURE otherwise SUCCESS.
--
--
-- ***********************************************************
PROCEDURE Check_Task_N_Wipjob
(
  p_repair_line_id        IN  NUMBER,
  p_repair_status         IN  VARCHAR2,
  x_return_status         OUT NOCOPY    VARCHAR2,
  x_msg_count             OUT NOCOPY    NUMBER,
  x_msg_data              OUT NOCOPY    VARCHAR2
 );


--   *******************************************************
--   API Name:  convert_Status_val_to_Id
--   Type    :  Private
--   Pre-Req :  None
--   Parameters:
--   IN
--     p_status_rec            IN    CSD_REPAIRS_PUB.REPAIR_STATUS_REC_TYPE ,
--   OUT
--     x_status_rec            OUT    CSD_REPAIRS_PUB.REPAIR_STATUS_REC_TYPE ,
--     x_return_status
--
--   Version : Current version 1.0
--             Initial Version 1.0
--
--   Description :  Converts value to Ids in the input repair status record.
--
-- ***********************************************************

PROCEDURE Convert_status_Val_to_Id(p_repair_status_rec      IN         Csd_Repairs_Pub.REPAIR_STATUS_REC_TYPE,
                     x_repair_status_rec      OUT NOCOPY Csd_Repairs_Pub.REPAIR_STATUS_REC_TYPE,
                     x_return_status   OUT NOCOPY VARCHAR2);

-- ***********************************************************
-- ***********************************************************
PROCEDURE Check_WebSrvc_Security
(
  p_repair_line_id        IN  NUMBER,
  x_return_status         OUT NOCOPY    VARCHAR2
 );

-- R12 Development End

--bug#5874431
Procedure create_csd_index (p_sql_stmt IN	varchar2,
                            p_object   IN   varchar2
						   );

--   *******************************************************
--   API Name:  get_contract_resolve_by_date
--   Type    :  Private
--   Pre-Req :  None
--   Parameters:
--   IN                                               required?
--     p_contract_line_id            IN     NUMBER,   Y
--     p_bus_proc_id                 IN     NUMBER,   Y
--     p_severity_id                 IN     NUMBER,   Y
--     p_request_date                IN     NUMBER,   N - if not passed, use sysdate
--   OUT
--     x_return_status
--     x_msg_count
--     x_msg_data
--     x_resolve_by_date             OUT    DATE
--
--   Version : Current version 1.0
--             Initial Version 1.0
--
--   Description : rfieldma: 5355051
--                 calls oks_entitlements_pub.get_react_resolve_by
--                 return resolve_by_date
--
--
--
--
-- ***********************************************************
PROCEDURE get_contract_resolve_by_date
(
  p_contract_line_id        IN  NUMBER,
  p_bus_proc_id             IN  NUMBER,
  p_severity_id             IN  NUMBER,
  p_request_date            IN  DATE := sysdate,
  x_return_status         OUT NOCOPY    VARCHAR2,
  x_msg_count             OUT NOCOPY    NUMBER,
  x_msg_data              OUT NOCOPY    VARCHAR2,
  x_resolve_by_date       OUT NOCOPY    DATE
 );


--   *******************************************************
--   API Name:  get_user_profile_option_name
--   Type    :  Private
--   Pre-Req :  None
--   Parameters:
--   IN                                           required?
--     p_profile_name            IN     VARHAR2   Y
--
--   Version : Current version 1.0
--             Initial Version 1.0
--
--   Description : rfieldma: utility function
--                 returns language specific user profile
--                 option name
--
--
--
--
-- ***********************************************************
FUNCTION get_user_profile_option_name
(
  p_profile_name         IN VARCHAR2
) RETURN VARCHAR2 ;

-- bug#7497790, 12.1 FP, subhat.
-- ***************************************************
-- Automatically update the RO status when the item is received.
-- The API receives the Repair line id and updates the RO status if the conditions are met.
-- Parameters:
-- p_event : Specify the event that is calling this program. Based on the event, the program logic might change.
-- p_reason_code: The reason code for the status change defaulted to null
-- p_comments: The comments for the flow status, defaulted to null
-- p_validation_level: validation level for the routine. Pass fnd_api.g_valid_level_full to get the messages from the API
-- 			     pass fnd_api.g_valid_level_none will ignore all error messages and return success always. The error messages
--			    will be logged in the fnd_log_messages if logging is enabled
--*****************************************************
procedure auto_update_ro_status(
                  p_api_version    in number,
                  p_commit         in varchar2,
                  p_init_msg_list  in varchar2,
                  p_repair_line_id in number,
                  x_return_status  out nocopy varchar2,
                  x_msg_count      out nocopy number,
                  x_msg_data       out nocopy varchar2,
                  p_event          in varchar2,
				          p_reason_code    in varchar2 default null,
				          p_comments       in varchar2 default null,
				          p_validation_level in number);


--

--   *******************************************************
--   API Name:  default_ro_attrs_from_rule
--   Type    :  Private
--   Pre-Req :  None
--   Parameters:
--   IN OUT                                           required?
--     px_repln_rec  in out nocopy CSD_REPAIRS_PUB.REPLN_REC_TYPE   Y
--
--   Version : Current version 1.0
--             Initial Version 1.0
--
--   Description : swai: utility procedure added for bug 7657379
--                 defaults Repair Order attributes from defaulting
--                 rules into px_repln_rec if the field is not already
--                 set.  Uses existing values in px_repln_rec to populate
--                 the rule input rec for defaulting rules.
--                 Currently, the following fields are defaulted if
--                 they are passed in as G_MISS:
--                   Inventory Org
--                   Repair Org
--                   Repair Owner
--                   Repair Priority
--                   Repair Type
--                 Note that the profile option value will be returned
--                 if no applicable rules exist.  For Repair Types,
--                 the profile value returned in for profile
--                 'CSD_DEFAULT_REPAIR_TYPE'
-- ***********************************************************
procedure default_ro_attrs_from_rule (
                  p_api_version    in number,
                  p_commit         in varchar2,
                  p_init_msg_list  in varchar2,
                  px_repln_rec     in out nocopy CSD_REPAIRS_PUB.repln_rec_type,
                  x_return_status  out nocopy varchar2,
                  x_msg_count      out nocopy number,
                  x_msg_data       out nocopy varchar2);

/**************************************************************************/
/* Procedure: create_requisition										  */
/* Description: This will insert the records into requisition interface   */
/*              table and subsequently launches the concurrent request to */
/*              create the requisitions.If the concurrent program is      */
/*              launched successfully then the concurrent request id is   */
/*			    is returned.											  */
/* Created by: subhat - 02-09-09                                          */
/**************************************************************************/

PROCEDURE create_requisition
(
    p_api_version_number                 IN NUMBER,
    p_init_msg_list                      IN VARCHAR2 DEFAULT FND_API.G_FALSE,
    p_commit                             IN VARCHAR2 DEFAULT FND_API.G_FALSE,
    x_return_Status                      OUT NOCOPY VARCHAR2,
    x_msg_count                          OUT NOCOPY NUMBER,
    x_msg_data                           OUT NOCOPY VARCHAR2,
    p_wip_entity_id_tbl                  IN  JTF_NUMBER_TABLE,
    p_quantity_tbl                       IN  JTF_NUMBER_TABLE,
    p_uom_code_tbl                       IN  VARCHAR2_TABLE_100,
    p_op_seq_num_tbl                     IN  JTF_NUMBER_TABLE,
    p_item_id_tbl                        IN  JTF_NUMBER_TABLE,
    p_item_description_tbl               IN  VARCHAR2_TABLE_100,
    p_organization_id                    IN  NUMBER,
    x_request_id                         OUT NOCOPY NUMBER

);

END Csd_Repairs_Util;

/
