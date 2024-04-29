--------------------------------------------------------
--  DDL for Package IEX_CASE_UTL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEX_CASE_UTL_PUB" AUTHID CURRENT_USER AS
/* $Header: iexucass.pls 120.8 2006/08/24 17:52:36 raverma ship $ */
/*#
 * Case Utility APIs allow users to create,
 *                   update, and close Collections cases.
 * @rep:scope public
 * @rep:product IEX
 * @rep:displayname Create Update Collections Case
 * @rep:lifecycle active
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY IEX_COLLECTION_CASE
 */
G_DEFAULT_NUM_REC_FETCH  NUMBER := 30;
G_YES         CONSTANT VARCHAR2(1) := 'Y';
G_NO          CONSTANT VARCHAR2(1) := 'N';
G_NUMBER      CONSTANT NUMBER := 1;  -- data type is number
G_VARCHAR2    CONSTANT NUMBER := 2;  -- data type is varchar2

TYPE cas_Rec_Type IS RECORD
(      CAS_ID                          NUMBER := FND_API.G_MISS_NUM,
       CASE_NUMBER                     VARCHAR2(240) := FND_API.G_MISS_CHAR,
       ACTIVE_FLAG                     VARCHAR2(240) := FND_API.G_MISS_CHAR,
       PARTY_ID                        NUMBER := FND_API.G_MISS_NUM,
       ORIG_CAS_ID                     NUMBER := FND_API.G_MISS_NUM,
       CASE_STATE                      VARCHAR2(240) := FND_API.G_MISS_CHAR,
       STATUS_CODE                     VARCHAR2(240) := FND_API.G_MISS_CHAR,
       OBJECT_VERSION_NUMBER           NUMBER := FND_API.G_MISS_NUM,
       CASE_ESTABLISHED_DATE           DATE := FND_API.G_MISS_DATE,
       CASE_CLOSING_DATE               DATE := FND_API.G_MISS_DATE,
       OWNER_RESOURCE_ID               NUMBER := FND_API.G_MISS_NUM,
       ACCESS_RESOURCE_ID              NUMBER := FND_API.G_MISS_NUM,
       REQUEST_ID                      NUMBER := FND_API.G_MISS_NUM,
       PROGRAM_APPLICATION_ID          NUMBER := FND_API.G_MISS_NUM,
       PROGRAM_ID                      NUMBER := FND_API.G_MISS_NUM,
       PROGRAM_UPDATE_DATE             DATE := FND_API.G_MISS_DATE,
       ATTRIBUTE_CATEGORY              VARCHAR2(240) := FND_API.G_MISS_CHAR,
       ATTRIBUTE1                      VARCHAR2(240) := FND_API.G_MISS_CHAR,
       ATTRIBUTE2                      VARCHAR2(240) := FND_API.G_MISS_CHAR,
       ATTRIBUTE3                      VARCHAR2(240) := FND_API.G_MISS_CHAR,
       ATTRIBUTE4                      VARCHAR2(240) := FND_API.G_MISS_CHAR,
       ATTRIBUTE5                      VARCHAR2(240) := FND_API.G_MISS_CHAR,
       ATTRIBUTE6                      VARCHAR2(240) := FND_API.G_MISS_CHAR,
       ATTRIBUTE7                      VARCHAR2(240) := FND_API.G_MISS_CHAR,
       ATTRIBUTE8                      VARCHAR2(240) := FND_API.G_MISS_CHAR,
       ATTRIBUTE9                      VARCHAR2(240) := FND_API.G_MISS_CHAR,
       ATTRIBUTE10                     VARCHAR2(240) := FND_API.G_MISS_CHAR,
       ATTRIBUTE11                     VARCHAR2(240) := FND_API.G_MISS_CHAR,
       ATTRIBUTE12                     VARCHAR2(240) := FND_API.G_MISS_CHAR,
       ATTRIBUTE13                     VARCHAR2(240) := FND_API.G_MISS_CHAR,
       ATTRIBUTE14                     VARCHAR2(240) := FND_API.G_MISS_CHAR,
       ATTRIBUTE15                     VARCHAR2(240) := FND_API.G_MISS_CHAR,
       CREATED_BY                      NUMBER := FND_API.G_MISS_NUM,
       CREATION_DATE                   DATE := FND_API.G_MISS_DATE,
       LAST_UPDATED_BY                 NUMBER := FND_API.G_MISS_NUM,
       LAST_UPDATE_DATE                DATE := FND_API.G_MISS_DATE,
       LAST_UPDATE_LOGIN               NUMBER := FND_API.G_MISS_NUM,
       CLOSE_REASON                    VARCHAR2(240) := FND_API.G_MISS_CHAR,
       ORG_ID                          NUMBER := FND_API.G_MISS_NUM,
       COMMENTS                        VARCHAR2(240) := FND_API.G_MISS_CHAR,
       PREDICTED_RECOVERY_AMOUNT       NUMBER := FND_API.G_MISS_NUM,
       PREDICTED_CHANCE                NUMBER := FND_API.G_MISS_NUM
);

G_MISS_cas_REC          cas_Rec_Type;
TYPE  cas_Tbl_Type      IS TABLE OF cas_Rec_Type INDEX BY BINARY_INTEGER;
G_MISS_cas_TBL          cas_Tbl_Type;

TYPE case_definition_Rec_Type IS RECORD
(
   COLUMN_NAME               VARCHAR2(240) ,
   COLUMN_VALUE              VARCHAR2(240) ,
   TABLE_NAME                VARCHAR2(240) DEFAULT NULL,
   DATA_TYPE                 NUMBER       DEFAULT G_NUMBER
);

G_MISS_CASE_DEFINITION_REC      CASE_DEFINITION_REC_TYPE;
TYPE  CASE_DEFINITION_TBL_TYPE  IS TABLE OF  CASE_DEFINITION_REC_TYPE INDEX BY BINARY_INTEGER;
G_MISS_CASE_DEF_TBL             CASE_DEFINITION_TBL_TYPE;

/** Case contact table definition **/

TYPE case_contact_Rec_Type IS RECORD
(
   CONTACT_PARTY_ID          VARCHAR2(30) ,
   PRIMARY_FLAG              VARCHAR2(1) DEFAULT G_NO,
   ADDRESS_ID                NUMBER       DEFAULT NULL,
   PHONE_ID                  NUMBER       DEFAULT NULL
);

G_MISS_CASE_CONTACT_REC      CASE_CONTACT_REC_TYPE;
TYPE  CASE_CONTACT_TBL_TYPE  IS TABLE OF  CASE_CONTACT_REC_TYPE INDEX BY BINARY_INTEGER;
G_MISS_CASE_CONTACT_TBL      CASE_CONTACT_TBL_TYPE;

/* Name   CheckCaseDef
** It Checks if all the elements of the case which defines a case are valid
** Values
*/
/*#
 * validates all elements that define a case
 * @param P_case_definition_tbl Collections Case Definition Pl/sql Table
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Check Case Definition
 */
Function CheckCaseDef(P_case_definition_tbl        IN   CASE_DEFINITION_TBL_TYPE DEFAULT G_MISS_CASE_DEF_TBL)Return BOOLEAN ;

/* Name   GetCaseID
** Return matching case id for the given case definition
*/
/*#
 * retrieves the case ID for a case definition.
 * @param P_case_definition_tbl Collections Case Definition Pl/sql Table
 * @param x_cas_id    Case Iddentifier
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Fetch Case ID
 */
Procedure GetCaseID
          (P_case_definition_tbl        IN   CASE_DEFINITION_TBL_TYPE DEFAULT G_MISS_CASE_DEF_TBL,
           x_cas_id                     OUT NOCOPY NUMBER    );

/* Name   PopulateCaseDefTbl
** Populates  case definition for the given cas_id
*/
/*#
 * Adds the case definition for  a case ID to the PL/SQL table
 * when creating, reassigning, or checking Collections cases.
 * Do not run this sub-routine by itself.
 * @param p_cas_id   Case identifier for case definition to be populated
 * @param x_case_definition_tbl Collections Case Definition PL/SQL Table-output
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Populate Case Definition PL/SQL Table
 */

Procedure PopulateCaseDefTbl
         ( p_cas_id                     IN  NUMBER,
           X_case_definition_tbl        OUT NOCOPY CASE_DEFINITION_TBL_TYPE
          );

/* Name   Close Case
/*#
 * updates the status of a case to Closed.
 * You can also copy the existing case objects to create a new case by
 * setting the p_copy_objects parameter to Y.
 * @param p_api_version   API Version Number
 * @param p_init_msg_list Intialize Message Stack
 * @param p_commit        Commit flag
 * @param P_Validation_Level Validation level
 * @param  p_cas_id        Case identifier for case definition to be populated
 * @param  p_close_date    Close Date for collections Case
 * @param  p_copy_objects  If Y, then create new case and copy all the case objects to the new case. If N, then do not copy the case objects. Default is N.
 * @param  p_cas_Rec       Collections case record type
 * @param x_return_status API return status
 * @param x_msg_count     Number of error messages
 * @param x_msg_data      Error message data
 * @rep:scope public
 * @rep:lifecycle planned
 * @rep:displayname Close Collections Case
 */
PROCEDURE CloseCase(
          P_Api_Version_Number         IN  NUMBER,
          P_Init_Msg_List              IN  VARCHAR2   ,
          P_Commit                     IN  VARCHAR2    ,
          P_validation_level           IN  NUMBER      ,
          P_cas_id                     IN NUMBER,
          p_close_date                 IN DATE         ,
          p_copy_objects               IN VARCHAR2     ,
          p_cas_Rec                    IN cas_Rec_Type  := G_MISS_cas_REC,
          X_Return_Status              OUT NOCOPY  VARCHAR2,
          X_Msg_Count                  OUT NOCOPY  NUMBER,
          X_Msg_Data                   OUT NOCOPY  VARCHAR2
          );

/*#
 * Creates case objects and validates case definition
 *  elements.If a case does not exist then it creates a new case with the
 *  given case definition.
 * @param p_api_version_number   API Version Number
 * @param p_init_msg_list Intialize Message Stack
 * @param p_commit        Commit flag
 * @param P_Validation_Level Validation level
 * @param p_cas_id        Case identifier for case definition to be populated
 * @param P_case_definition_tbl  Collections Case Definition Pl/sql Table
 * @param P_case_number           Collections case number
 * @param P_case_comments         Description for collections case
 * @param P_case_established_date Collections case start date
 * @param P_org_id               Organization identifier
 * @param P_object_code          Object code of the object ID
 * @param P_party_id             Party identifier
 * @param P_object_id            Case object identifier
 * @param X_case_object_id      output collections case identifier
 * @param p_cas_Rec             Collections case record type
 * @param x_return_status API return status
 * @param x_msg_count     Number of error messages
 * @param x_msg_data      Error message data
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Collections Case Objects
 */
PROCEDURE CreateCaseObjects(
          P_Api_Version_Number         IN   NUMBER,
          P_Init_Msg_List              IN   VARCHAR2    ,
          P_Commit                     IN   VARCHAR2    ,
          P_validation_level           IN   NUMBER      ,
          P_case_definition_tbl        IN   CASE_DEFINITION_TBL_TYPE,
          P_cas_id                     IN NUMBER        ,
          P_case_number                IN VARCHAR2      ,
          P_case_comments              IN VARCHAR2      ,
          P_case_established_date      IN DATE          ,
          P_org_id                     IN NUMBER        ,
          P_object_code                IN VARCHAR2      ,
          P_party_id                   IN NUMBER,
          P_object_id                  IN NUMBER,
          p_cas_rec                    IN    CAS_Rec_Type  DEFAULT G_MISS_CAS_REC,
          X_case_object_id             OUT  NOCOPY  NUMBER,
          X_Return_Status              OUT  NOCOPY  VARCHAR2,
          X_Msg_Count                  OUT  NOCOPY  NUMBER,
          X_Msg_Data                   OUT  NOCOPY  VARCHAR2
         );

/*#
 *  Updates collections case.
 *  Use this procedure to update a case or change the status from delinquent to current when
 *  the case is no longer delinquent. * @param p_api_version   API Version Number
 * @param p_api_version_number   API Version Number
 * @param p_init_msg_list Intialize message stack
 * @param p_commit        Commit flag
 * @param P_Validation_Level Validation level
 * @param  p_cas_Rec      Collections case record type
 * @param x_return_status API return status
 * @param x_msg_count     Number of error messages
 * @param x_msg_data      Error message data
 * @rep:scope public
 * @rep:lifecycle planned
 * @rep:displayname Update Collections Cases
 */
PROCEDURE UpdateCase(
          P_Api_Version_Number         IN   NUMBER,
          P_Init_Msg_List              IN   VARCHAR2     ,
          P_Commit                     IN   VARCHAR2     ,
          P_validation_level           IN   NUMBER       ,
          p_cas_rec                    IN   CAS_Rec_Type  DEFAULT G_MISS_CAS_REC,
          X_Return_Status              OUT NOCOPY  VARCHAR2,
          X_Msg_Count                  OUT NOCOPY  NUMBER,
          X_Msg_Data                   OUT NOCOPY  VARCHAR2 );

/*#
 * Creates collections case contacts.
 * @param p_api_version_number   API Version Number
 * @param p_init_msg_list Intialize message stack
 * @param p_commit        Commit flag
 * @param P_Validation_Level Validation level
 * @param  P_case_contact_tbl     Collections case definition PL/SQL table
 * @param  p_cas_id               Case identifier for case definition to be populated
 * @param x_return_status API return status
 * @param x_msg_count     Number of error messages
 * @param x_msg_data      Error message data
 * @rep:scope public
 * @rep:lifecycle planned
 * @rep:displayname Create Collections Case Contacts
 */
PROCEDURE CreateCasecontacts(
          P_Api_Version_Number         IN   NUMBER,
          P_Init_Msg_List              IN   VARCHAR2     ,
          P_Commit                     IN   VARCHAR2     ,
          P_validation_level           IN   NUMBER       ,
          P_case_contact_tbl           IN   CASE_CONTACT_TBL_TYPE DEFAULT G_MISS_CASE_CONTACT_TBL,
          P_cas_id                     IN NUMBER       ,
          X_Return_Status              OUT NOCOPY  VARCHAR2,
          X_Msg_Count                  OUT NOCOPY  NUMBER,
          X_Msg_Data                   OUT NOCOPY  VARCHAR2
          );


/*#
* Creates a new case object or reassigns a case when the Bill To address or any case attribute changes.* @rep:scope public
* @param  P_ObjectID               Object identifier
* @rep:lifecycle active
* @rep:displayname Check Contract
*/
Function CheckContract
          (P_ObjectID   IN NUMBER
          )Return BOOLEAN ;


/*#
 * Reassigns a contract or creates a new case if no existing case matches the new case definition.
 * @param p_api_version_number   API Version Number
 * @param p_init_msg_list Intialize message stack
 * @param p_commit        Commit flag
 * @param P_Validation_Level Validation level
 * @param  p_cas_id       Case identifier for case definition to be populated
 * @param  P_case_definition_tbl  Collections case definition PL/SQL table
 * @param  P_case_number          Collections case number
 * @param  P_case_comments         Description for collections case
 * @param  P_case_established_date Collections case start date
 * @param  P_org_id                Organization Identifier
 * @param  P_object_code          Object Code of the Object ID
 * @param  P_party_id             Party identifier
 * @param  P_object_id            Case object identifier
 * @param  X_case_object_id      Output collections case identifier
 * @param  p_cas_Rec             Collections case record type
 * @param x_return_status API return status
 * @param x_msg_count     Number of error messages
 * @param x_msg_data      Error message data
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Reassign Collections Case Objects
 */
PROCEDURE ReassignCaseObjects(
          P_Api_Version_Number         IN   NUMBER,
          P_Init_Msg_List              IN   VARCHAR2    ,
          P_Commit                     IN   VARCHAR2    ,
          P_validation_level           IN   NUMBER  ,
          P_case_definition_tbl        IN   CASE_DEFINITION_TBL_TYPE,
          P_cas_id                     IN NUMBER        ,
          P_case_number                IN VARCHAR2      ,
          P_case_comments              IN VARCHAR2      ,
          P_case_established_date      IN DATE          ,
          P_org_id                     IN NUMBER        ,
          P_object_code                IN VARCHAR2      ,
          P_party_id                   IN NUMBER,
          P_object_id                  IN NUMBER,
          p_cas_rec                    IN    CAS_Rec_Type ,
          X_case_object_id             OUT  NOCOPY  NUMBER,
          X_Return_Status              OUT  NOCOPY  VARCHAR2,
          X_Msg_Count                  OUT  NOCOPY  NUMBER,
          X_Msg_Data                   OUT  NOCOPY  VARCHAR2
          );
END IEX_CASE_UTL_PUB;

/
