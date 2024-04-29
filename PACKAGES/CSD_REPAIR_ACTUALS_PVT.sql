--------------------------------------------------------
--  DDL for Package CSD_REPAIR_ACTUALS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSD_REPAIR_ACTUALS_PVT" AUTHID CURRENT_USER as
/* $Header: csdvacts.pls 120.2 2008/02/09 01:05:17 takwong ship $ csdvacts.pls */

-- ---------------------------------------------------------
-- Define global variables
-- ---------------------------------------------------------
G_PKG_NAME  CONSTANT VARCHAR2(30) := 'CSD_REPAIR_ACTUALS_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'csdvacts.pls';
g_debug              NUMBER       := csd_gen_utility_pvt.g_debug_level;

/*--------------------------------------------------------------------*/
/* Record name:  CSD_REPAIR_ACTUALS_REC_TYPE                          */
/* Description : Record used for Create/Update Repair Actuals         */
/*                                                                    */
/*                                                                    */
/* Called from : Depot Repair Actuals UI                              */
/* Change Hist :                                                      */
/*   08/11/03  travikan  Initial Creation.                            */
/*                                                                    */
/*                                                                    */
/*                                                                    */
/*--------------------------------------------------------------------*/
TYPE CSD_REPAIR_ACTUALS_REC_TYPE IS RECORD
(
       REPAIR_ACTUAL_ID                NUMBER
,       OBJECT_VERSION_NUMBER           NUMBER
,       REPAIR_LINE_ID                  NUMBER
,       CREATED_BY                      NUMBER
,       CREATION_DATE                   DATE
,       LAST_UPDATED_BY                 NUMBER
,       LAST_UPDATE_DATE                DATE
,       LAST_UPDATE_LOGIN               NUMBER
,       ATTRIBUTE_CATEGORY              VARCHAR2(30)
,       ATTRIBUTE1                      VARCHAR2(150)
,       ATTRIBUTE2                      VARCHAR2(150)
,       ATTRIBUTE3                      VARCHAR2(150)
,       ATTRIBUTE4                      VARCHAR2(150)
,       ATTRIBUTE5                      VARCHAR2(150)
,       ATTRIBUTE6                      VARCHAR2(150)
,       ATTRIBUTE7                      VARCHAR2(150)
,       ATTRIBUTE8                      VARCHAR2(150)
,       ATTRIBUTE9                      VARCHAR2(150)
,       ATTRIBUTE10                     VARCHAR2(150)
,       ATTRIBUTE11                     VARCHAR2(150)
,       ATTRIBUTE12                     VARCHAR2(150)
,       ATTRIBUTE13                     VARCHAR2(150)
,       ATTRIBUTE14                     VARCHAR2(150)
,       ATTRIBUTE15                     VARCHAR2(150)
,       BILL_TO_ACCOUNT_ID              NUMBER
,       BILL_TO_PARTY_ID                NUMBER
,       BILL_TO_PARTY_SITE_ID           NUMBER
);

/*--------------------------------------------------------------------*/
/* Type to Return the Record Type for Creating / Updating the         */
/*                                                                    */
/*                                                                    */
/* Called from : Depot Repair                                         */
/*--------------------------------------------------------------------*/
TYPE  CSD_REPAIR_ACTUALS_TBL_TYP      IS TABLE OF CSD_REPAIR_ACTUALS_REC_TYPE
                                         INDEX BY BINARY_INTEGER;


/*--------------------------------------------------------------------*/
/* procedure name: CREATE_REPAIR_ACTUALS                              */
/* description : procedure used to Create Repair Actuals              */
/*                                                                    */
/*                                                                    */
/*                                                                    */
/* Called from : Depot Repair Actuals UI                              */
/* Input Parm  :                                                      */
/*   p_api_version       NUMBER    Req Api Version number             */
/*   p_init_msg_list     VARCHAR2  Opt Initialize message stack       */
/*   p_commit            VARCHAR2  Opt Commits in API                 */
/*   p_validation_level  NUMBER    Opt validation steps               */
/*   px_CSD_REPAIR_ACTUALS_REC REC Req Actuals Record                 */
/* Output Parm :                                                      */
/*   x_return_status     VARCHAR2      Return status after the call.  */
/*   x_msg_count         NUMBER        Number of messages in stack    */
/*   x_msg_data          VARCHAR2      Mesg. text if x_msg_count >= 1 */
/* Change Hist :                                                      */
/*   08/11/03  travikan  Initial Creation.                            */
/*                                                                    */
/*                                                                    */
/*                                                                    */
/*--------------------------------------------------------------------*/
PROCEDURE CREATE_REPAIR_ACTUALS(
    P_Api_Version                IN            NUMBER,
    P_Commit                     IN            VARCHAR2,
    P_Init_Msg_List              IN            VARCHAR2,
    p_validation_level           IN            NUMBER,
    px_CSD_REPAIR_ACTUALS_REC    IN OUT NOCOPY CSD_REPAIR_ACTUALS_REC_TYPE,
    X_Return_Status              OUT    NOCOPY VARCHAR2,
    X_Msg_Count                  OUT    NOCOPY NUMBER,
    X_Msg_Data                   OUT    NOCOPY VARCHAR2
    );



/*--------------------------------------------------------------------*/
/* procedure name: UPDATE_REPAIR_ACTUALS                              */
/* description : procedure used to Update Repair Actuals              */
/*                                                                    */
/*                                                                    */
/*                                                                    */
/* Called from : Depot Repair Actuals UI                              */
/* Input Parm  :                                                      */
/*   p_api_version       NUMBER    Req Api Version number             */
/*   p_init_msg_list     VARCHAR2  Opt Initialize message stack       */
/*   p_commit            VARCHAR2  Opt Commits in API                 */
/*   p_validation_level  NUMBER    Opt validation steps               */
/*   px_CSD_REPAIR_ACTUALS_REC REC Req Actuals Record                 */
/* Output Parm :                                                      */
/*   x_return_status     VARCHAR2      Return status after the call.  */
/*   x_msg_count         NUMBER        Number of messages in stack    */
/*   x_msg_data          VARCHAR2      Mesg. text if x_msg_count >= 1 */
/* Change Hist :                                                      */
/*   08/11/03  travikan  Initial Creation.                            */
/*                                                                    */
/*                                                                    */
/*                                                                    */
/*--------------------------------------------------------------------*/
PROCEDURE UPDATE_REPAIR_ACTUALS(
    P_Api_Version                IN            NUMBER,
    P_Commit                     IN            VARCHAR2,
    P_Init_Msg_List              IN            VARCHAR2,
    p_validation_level           IN            NUMBER,
    px_CSD_REPAIR_ACTUALS_REC    IN OUT NOCOPY CSD_REPAIR_ACTUALS_REC_TYPE,
    X_Return_Status              OUT    NOCOPY VARCHAR2,
    X_Msg_Count                  OUT    NOCOPY NUMBER,
    X_Msg_Data                   OUT    NOCOPY VARCHAR2
    );



/*--------------------------------------------------------------------*/
/* procedure name: DELETE_REPAIR_ACTUALS                              */
/* description : procedure used to Delete Repair Actuals              */
/*                                                                    */
/*                                                                    */
/*                                                                    */
/* Called from : Depot Repair Actuals UI                              */
/* Input Parm  :                                                      */
/*   p_api_version       NUMBER    Req Api Version number             */
/*   p_init_msg_list     VARCHAR2  Opt Initialize message stack       */
/*   p_commit            VARCHAR2  Opt Commits in API                 */
/*   p_validation_level  NUMBER    Opt validation steps               */
/*   px_CSD_REPAIR_ACTUALS_REC REC Req Actuals Record                 */
/* Output Parm :                                                      */
/*   x_return_status     VARCHAR2      Return status after the call.  */
/*   x_msg_count         NUMBER        Number of messages in stack    */
/*   x_msg_data          VARCHAR2      Mesg. text if x_msg_count >= 1 */
/* Change Hist :                                                      */
/*   08/11/03  travikan  Initial Creation.                            */
/*                                                                    */
/*                                                                    */
/*                                                                    */
/*--------------------------------------------------------------------*/
PROCEDURE DELETE_REPAIR_ACTUALS(
    P_Api_Version                IN            NUMBER,
    P_Commit                     IN            VARCHAR2,
    P_Init_Msg_List              IN            VARCHAR2,
    p_validation_level           IN            NUMBER,
    px_CSD_REPAIR_ACTUALS_REC    IN OUT NOCOPY CSD_REPAIR_ACTUALS_REC_TYPE,
    X_Return_Status              OUT    NOCOPY VARCHAR2,
    X_Msg_Count                  OUT    NOCOPY NUMBER,
    X_Msg_Data                   OUT    NOCOPY VARCHAR2
    );



/*--------------------------------------------------------------------*/
/* procedure name: LOCK_REPAIR_ACTUALS                                */
/* description : procedure used to Lock Repair Actuals              */
/*                                                                    */
/*                                                                    */
/*                                                                    */
/* Called from : Depot Repair Actuals UI                              */
/* Input Parm  :                                                      */
/*   p_api_version       NUMBER    Req Api Version number             */
/*   p_init_msg_list     VARCHAR2  Opt Initialize message stack       */
/*   p_commit            VARCHAR2  Opt Commits in API                 */
/*   p_validation_level  NUMBER    Opt validation steps               */
/*   px_CSD_REPAIR_ACTUALS_REC REC Req Actuals Record                 */
/* Output Parm :                                                      */
/*   x_return_status     VARCHAR2      Return status after the call.  */
/*   x_msg_count         NUMBER        Number of messages in stack    */
/*   x_msg_data          VARCHAR2      Mesg. text if x_msg_count >= 1 */
/* Change Hist :                                                      */
/*   08/11/03  travikan  Initial Creation.                            */
/*                                                                    */
/*                                                                    */
/*                                                                    */
/*--------------------------------------------------------------------*/
PROCEDURE LOCK_REPAIR_ACTUALS(
    P_Api_Version                IN            NUMBER,
    P_Commit                     IN            VARCHAR2,
    P_Init_Msg_List              IN            VARCHAR2,
    p_validation_level           IN            NUMBER,
    px_CSD_REPAIR_ACTUALS_REC    IN OUT NOCOPY CSD_REPAIR_ACTUALS_REC_TYPE,
    X_Return_Status              OUT    NOCOPY VARCHAR2,
    X_Msg_Count                  OUT    NOCOPY NUMBER,
    X_Msg_Data                   OUT    NOCOPY VARCHAR2
    );


End CSD_REPAIR_ACTUALS_PVT;

/
