--------------------------------------------------------
--  DDL for Package CS_INCIDENTLINKS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CS_INCIDENTLINKS_PVT" AUTHID CURRENT_USER AS
/* $Header: csvsrls.pls 120.1 2005/08/02 07:30:55 varnaray noship $ */

   -- Renamed existing rec. type G_LINKS_REC to CS_INCIDENT_LINKS_REC_TYPE in 1159.
   -- The existing rec. type was not used anywhere and since it was defined in the
   -- private package, it is not publised for customers to use as well.
   -- The new rec. type is the same structure as the rec. type defined in the
   -- Public Spec.
   -- This will be used in the overloaded procedures for create/update links.
   -- Note : The record type does **not** have the object version number.
   --        Also it does not have the two 1159 obsoleted parameters.
   --        ie. from_incident_id and to_incident_id
   --        Also, the attributed don't have to be explictly defaulted to NULL as
   --        that happens implictly. Defaulting the link segments to FND_APIs for
   --        backward compatability.
   TYPE CS_INCIDENT_LINK_REC_TYPE IS RECORD (
      LINK_ID                        NUMBER,   -- new for 1159
      SUBJECT_ID                     NUMBER,   -- new for 1159
      SUBJECT_TYPE                   VARCHAR2(30), -- new for 1159
      OBJECT_ID                      NUMBER, -- new for 1159
      OBJECT_NUMBER                  VARCHAR2(90),-- new for 1159
      OBJECT_TYPE                    VARCHAR2(30), -- new for 1159
      LINK_TYPE_ID		     NUMBER,       -- new for 1159
      LINK_TYPE		             VARCHAR2(240), -- no change
      REQUEST_ID                     NUMBER,   -- new for 1159
      PROGRAM_APPLICATION_ID         NUMBER,   -- new for 1159
      PROGRAM_ID                     NUMBER,   -- new for 1159
      PROGRAM_UPDATE_DATE            DATE,     -- new for 1159
      FROM_INCIDENT_ID               NUMBER         := NULL, -- new in 11.5.9.1 for bugs 2972584 and 2972611
      FROM_INCIDENT_NUMBER           VARCHAR2(64)   := NULL, -- new in 11.5.9.1 for bugs 2972584 and 2972611
      TO_INCIDENT_ID                 NUMBER         := NULL, -- new in 11.5.9.1 for bugs 2972584 and 2972611
      TO_INCIDENT_NUMBER             VARCHAR2(64)   := NULL, -- new in 11.5.9.1 for bugs 2972584 and 2972611
      LINK_SEGMENT1	             VARCHAR2(150)  := FND_API.G_MISS_CHAR,
      LINK_SEGMENT2	             VARCHAR2(150)  := FND_API.G_MISS_CHAR,
      LINK_SEGMENT3	             VARCHAR2(150)  := FND_API.G_MISS_CHAR,
      LINK_SEGMENT4	             VARCHAR2(150)  := FND_API.G_MISS_CHAR,
      LINK_SEGMENT5	             VARCHAR2(150)  := FND_API.G_MISS_CHAR,
      LINK_SEGMENT6	             VARCHAR2(150)  := FND_API.G_MISS_CHAR,
      LINK_SEGMENT7	             VARCHAR2(150)  := FND_API.G_MISS_CHAR,
      LINK_SEGMENT8	             VARCHAR2(150)  := FND_API.G_MISS_CHAR,
      LINK_SEGMENT9	             VARCHAR2(150)  := FND_API.G_MISS_CHAR,
      LINK_SEGMENT10	             VARCHAR2(150)  := FND_API.G_MISS_CHAR,
      LINK_SEGMENT11	             VARCHAR2(150)  := FND_API.G_MISS_CHAR,   -- new for 1159
      LINK_SEGMENT12	             VARCHAR2(150)  := FND_API.G_MISS_CHAR,   -- new for 1159
      LINK_SEGMENT13	             VARCHAR2(150)  := FND_API.G_MISS_CHAR,   -- new for 1159
      LINK_SEGMENT14	             VARCHAR2(150)  := FND_API.G_MISS_CHAR,   -- new for 1159
      LINK_SEGMENT15	             VARCHAR2(150)  := FND_API.G_MISS_CHAR,   -- new for 1159
      LINK_CONTEXT		     VARCHAR2(150)  := FND_API.G_MISS_CHAR,
      LINK_ID_EXT		     NUMBER         := NULL ); 	-- new in 11.5.9.1 for bugs 2972584 and 2972611

   -- Removed type G_LINKS_EXT_REC as both internal and external links are treated the
   -- same from 1159.
   -- TYPE G_LINKS_EXT_REC IS RECORD (

   -- Added record type CS_INCIDENT_LINK_EXT_REC_TYPE based on the CS_INCIDENT_LINKS_EXT table structure.
   -- This is used for restoring the functionality of the _ext public procedures in 11.5.9.1 for backward compatibility.
   -- For bugs # 2972584 and 2972611

   TYPE CS_INCIDENT_LINK_EXT_REC_TYPE IS RECORD (
          LINK_ID                        NUMBER,
	  FROM_INCIDENT_ID               NUMBER,
	  TO_OBJECT_ID                   NUMBER,
	  TO_OBJECT_TYPE                 VARCHAR2(30),
	  TO_OBJECT_NUMBER               VARCHAR2(64),
	  LAST_UPDATE_DATE               DATE,
	  LAST_UPDATED_BY                NUMBER,
	  CREATION_DATE                  DATE,
	  CREATED_BY                     NUMBER,
	  LAST_UPDATE_LOGIN              NUMBER,
	  ATTRIBUTE1                     VARCHAR2(150)  := FND_API.G_MISS_CHAR,
	  ATTRIBUTE2                     VARCHAR2(150)  := FND_API.G_MISS_CHAR,
	  ATTRIBUTE3                     VARCHAR2(150)  := FND_API.G_MISS_CHAR,
	  ATTRIBUTE4                     VARCHAR2(150)  := FND_API.G_MISS_CHAR,
	  ATTRIBUTE5                     VARCHAR2(150)  := FND_API.G_MISS_CHAR,
	  ATTRIBUTE6                     VARCHAR2(150)  := FND_API.G_MISS_CHAR,
	  ATTRIBUTE7                     VARCHAR2(150)  := FND_API.G_MISS_CHAR,
	  ATTRIBUTE8                     VARCHAR2(150)  := FND_API.G_MISS_CHAR,
	  ATTRIBUTE9                     VARCHAR2(150)  := FND_API.G_MISS_CHAR,
	  ATTRIBUTE10                    VARCHAR2(150)  := FND_API.G_MISS_CHAR,
	  CONTEXT                        VARCHAR2(30)   := FND_API.G_MISS_CHAR,
	  OBJECT_VERSION_NUMBER          NUMBER);

   -- Overloaded procedure (new for 1159) that accepts a record structure. This
   -- procedure calls the create procedure with the detailed list of parameters.
   -- Invoking programs can use either one of the procedures.

   PROCEDURE CREATE_INCIDENTLINK (
      P_API_VERSION		IN     NUMBER,
      P_INIT_MSG_LIST     	IN     VARCHAR2 := FND_API.G_FALSE,
      P_COMMIT     		IN     VARCHAR2 := FND_API.G_FALSE,
      P_VALIDATION_LEVEL  	IN     NUMBER   := FND_API.G_VALID_LEVEL_FULL,
      P_RESP_APPL_ID		IN     NUMBER   := NULL, -- not used
      P_RESP_ID		        IN     NUMBER   := NULL, -- not used
      P_USER_ID		        IN     NUMBER   := NULL, -- not used
      P_LOGIN_ID		IN     NUMBER   := FND_API.G_MISS_NUM,
      P_ORG_ID		        IN     NUMBER   := NULL, -- not used
      P_LINK_REC                IN     CS_INCIDENT_LINK_REC_TYPE := NULL,
      X_RETURN_STATUS	        OUT NOCOPY   VARCHAR2,
      X_MSG_COUNT		OUT NOCOPY   NUMBER,
      X_MSG_DATA		OUT NOCOPY   VARCHAR2,
      X_OBJECT_VERSION_NUMBER   OUT NOCOPY   NUMBER,
      X_RECIPROCAL_LINK_ID      OUT NOCOPY   NUMBER,
      X_LINK_ID			OUT NOCOPY   NUMBER );

   PROCEDURE CREATE_INCIDENTLINK (
      P_API_VERSION		IN     NUMBER,
      P_INIT_MSG_LIST     	IN     VARCHAR2 := FND_API.G_FALSE,
      P_COMMIT     		IN     VARCHAR2 := FND_API.G_FALSE,
      P_VALIDATION_LEVEL  	IN     NUMBER   := FND_API.G_VALID_LEVEL_FULL,
      P_RESP_APPL_ID		IN     NUMBER   := NULL, -- not used
      P_RESP_ID		        IN     NUMBER   := NULL, -- not used
      P_USER_ID		        IN     NUMBER   := NULL, -- not used
      P_LOGIN_ID		IN     NUMBER   := FND_API.G_MISS_NUM,
      P_ORG_ID		        IN     NUMBER   := NULL, -- not used
      P_LINK_ID		        IN     NUMBER   := NULL, -- new for 1159
      P_SUBJECT_ID              IN     NUMBER   := NULL, -- new for 1159
      P_SUBJECT_TYPE            IN     VARCHAR2 := NULL, -- new for 1159
      P_OBJECT_ID               IN     NUMBER   := NULL, -- new for 1159
      P_OBJECT_NUMBER           IN     VARCHAR2 := NULL, -- new for 1159
      P_OBJECT_TYPE             IN     VARCHAR2 := NULL, -- new for 1159
      P_LINK_TYPE_ID		IN     NUMBER   := NULL, -- new for 1159
      P_LINK_TYPE		IN     VARCHAR2 := NULL, -- existed prior to 1159. Made this
							 -- param non mandatory in 1159
      P_REQUEST_ID              IN     NUMBER   := NULL, -- new for 1159
      P_PROGRAM_APPLICATION_ID  IN     NUMBER   := NULL, -- new for 1159
      P_PROGRAM_ID              IN     NUMBER   := NULL, -- new for 1159
      P_PROGRAM_UPDATE_DATE     IN     DATE     := NULL, -- new for 1159
      P_FROM_INCIDENT_ID	IN     NUMBER,           -- obsoleted for 1159
      P_TO_INCIDENT_ID	        IN     NUMBER,           -- obsoleted for 1159
      P_LINK_SEGMENT1		IN     VARCHAR2 := FND_API.G_MISS_CHAR,
      P_LINK_SEGMENT2		IN     VARCHAR2 := FND_API.G_MISS_CHAR,
      P_LINK_SEGMENT3		IN     VARCHAR2 := FND_API.G_MISS_CHAR,
      P_LINK_SEGMENT4		IN     VARCHAR2 := FND_API.G_MISS_CHAR,
      P_LINK_SEGMENT5		IN     VARCHAR2 := FND_API.G_MISS_CHAR,
      P_LINK_SEGMENT6		IN     VARCHAR2 := FND_API.G_MISS_CHAR,
      P_LINK_SEGMENT7		IN     VARCHAR2 := FND_API.G_MISS_CHAR,
      P_LINK_SEGMENT8		IN     VARCHAR2 := FND_API.G_MISS_CHAR,
      P_LINK_SEGMENT9		IN     VARCHAR2 := FND_API.G_MISS_CHAR,
      P_LINK_SEGMENT10	        IN     VARCHAR2 := FND_API.G_MISS_CHAR,
      P_LINK_SEGMENT11	        IN     VARCHAR2 := FND_API.G_MISS_CHAR,-- new for 1159
      P_LINK_SEGMENT12	        IN     VARCHAR2 := FND_API.G_MISS_CHAR,-- new for 1159
      P_LINK_SEGMENT13	        IN     VARCHAR2 := FND_API.G_MISS_CHAR,-- new for 1159
      P_LINK_SEGMENT14	        IN     VARCHAR2 := FND_API.G_MISS_CHAR,-- new for 1159
      P_LINK_SEGMENT15	        IN     VARCHAR2 := FND_API.G_MISS_CHAR,-- new for 1159
      P_LINK_CONTEXT		IN     VARCHAR2 := FND_API.G_MISS_CHAR,
      X_RETURN_STATUS	        OUT NOCOPY   VARCHAR2,
      X_MSG_COUNT		OUT NOCOPY   NUMBER,
      X_MSG_DATA		OUT NOCOPY   VARCHAR2,
      X_OBJECT_VERSION_NUMBER   OUT NOCOPY   NUMBER, -- new for 1159
      X_RECIPROCAL_LINK_ID      OUT NOCOPY   NUMBER, -- new for 1159
      X_LINK_ID			OUT NOCOPY   NUMBER );

   -- Overloaded procedure (new for 1159) that accepts a record structure. This
   -- procedure calls the update procedure with the detailed list of parameters.
   -- Invoking programs can use either one of the procedures.
   PROCEDURE UPDATE_INCIDENTLINK (
      P_API_VERSION		IN     NUMBER,
      P_INIT_MSG_LIST	        IN     VARCHAR2 := FND_API.G_FALSE,
      P_COMMIT			IN     VARCHAR2 := FND_API.G_FALSE,
      P_VALIDATION_LEVEL        IN     NUMBER   := FND_API.G_VALID_LEVEL_FULL,
      P_RESP_APPL_ID		IN     NUMBER   := NULL,  -- not used
      P_RESP_ID			IN     NUMBER   := NULL,  -- not used
      P_USER_ID			IN     NUMBER   := NULL,
      P_LOGIN_ID		IN     NUMBER   := FND_API.G_MISS_NUM,
      P_ORG_ID			IN     NUMBER   := NULL,  -- not used
      P_LINK_ID			IN     NUMBER,            -- no change
      P_OBJECT_VERSION_NUMBER   IN     NUMBER,            -- new for 1159
      P_LINK_REC                IN     CS_INCIDENT_LINK_REC_TYPE := NULL,
      X_RETURN_STATUS	        OUT NOCOPY   VARCHAR2,
      X_OBJECT_VERSION_NUMBER   OUT NOCOPY   NUMBER,  -- new for 1159
      X_MSG_COUNT		OUT NOCOPY   NUMBER,
      X_MSG_DATA		OUT NOCOPY   VARCHAR2 );

   PROCEDURE UPDATE_INCIDENTLINK (
      P_API_VERSION		IN     NUMBER,
      P_INIT_MSG_LIST	        IN     VARCHAR2 := FND_API.G_FALSE,
      P_COMMIT			IN     VARCHAR2 := FND_API.G_FALSE,
      P_VALIDATION_LEVEL        IN     NUMBER   := FND_API.G_VALID_LEVEL_FULL,
      P_RESP_APPL_ID		IN     NUMBER   := NULL,  -- not used
      P_RESP_ID			IN     NUMBER   := NULL,  -- not used
      P_USER_ID			IN     NUMBER   := NULL,
      P_LOGIN_ID		IN     NUMBER   := FND_API.G_MISS_NUM,
      P_ORG_ID			IN     NUMBER   := NULL,  -- not used
      P_LINK_ID			IN     NUMBER,            -- no change
      P_OBJECT_VERSION_NUMBER   IN     NUMBER,            -- new for 1159
      P_OBJECT_ID               IN     NUMBER   := NULL,  -- new for 1159
      P_OBJECT_NUMBER           IN     VARCHAR2 := NULL,  -- new for 1159
      P_OBJECT_TYPE             IN     VARCHAR2 := NULL,  -- new for 1159
      P_LINK_TYPE_ID		IN     NUMBER   := NULL,  -- new for 1159
      P_LINK_TYPE		IN     VARCHAR2 := NULL,  -- no change
      P_REQUEST_ID              IN     NUMBER   := NULL, -- new for 1159
      P_PROGRAM_APPLICATION_ID  IN     NUMBER   := NULL, -- new for 1159
      P_PROGRAM_ID              IN     NUMBER   := NULL, -- new for 1159
      P_PROGRAM_UPDATE_DATE     IN     DATE     := NULL, -- new for 1159
      P_FROM_INCIDENT_ID	IN     NUMBER   := NULL,  -- obsoleted for 1159
      P_TO_INCIDENT_ID	        IN     NUMBER   := NULL,  -- obsoleted for 1159
      P_LINK_SEGMENT1	        IN     VARCHAR2 := FND_API.G_MISS_CHAR,
      P_LINK_SEGMENT2	        IN     VARCHAR2 := FND_API.G_MISS_CHAR,
      P_LINK_SEGMENT3	        IN     VARCHAR2 := FND_API.G_MISS_CHAR,
      P_LINK_SEGMENT4	        IN     VARCHAR2 := FND_API.G_MISS_CHAR,
      P_LINK_SEGMENT5	        IN     VARCHAR2 := FND_API.G_MISS_CHAR,
      P_LINK_SEGMENT6	        IN     VARCHAR2 := FND_API.G_MISS_CHAR,
      P_LINK_SEGMENT7	        IN     VARCHAR2 := FND_API.G_MISS_CHAR,
      P_LINK_SEGMENT8	        IN     VARCHAR2 := FND_API.G_MISS_CHAR,
      P_LINK_SEGMENT9	        IN     VARCHAR2 := FND_API.G_MISS_CHAR,
      P_LINK_SEGMENT10	        IN     VARCHAR2 := FND_API.G_MISS_CHAR,
      P_LINK_SEGMENT11	        IN     VARCHAR2 := FND_API.G_MISS_CHAR, -- new for 1159
      P_LINK_SEGMENT12	        IN     VARCHAR2 := FND_API.G_MISS_CHAR, -- new for 1159
      P_LINK_SEGMENT13	        IN     VARCHAR2 := FND_API.G_MISS_CHAR, -- new for 1159
      P_LINK_SEGMENT14	        IN     VARCHAR2 := FND_API.G_MISS_CHAR, -- new for 1159
      P_LINK_SEGMENT15	        IN     VARCHAR2 := FND_API.G_MISS_CHAR, -- new for 1159
      P_LINK_CONTEXT		IN     VARCHAR2 := FND_API.G_MISS_CHAR,
      X_RETURN_STATUS	        OUT NOCOPY   VARCHAR2,
      X_OBJECT_VERSION_NUMBER   OUT NOCOPY   NUMBER,  -- new for 1159
      X_MSG_COUNT		OUT NOCOPY   NUMBER,
      X_MSG_DATA		OUT NOCOPY   VARCHAR2 );

   -- New, overloaded procedure with the 11.5.9 signature added for bugs 2972584 and 2972611
   PROCEDURE DELETE_INCIDENTLINK (
      P_API_VERSION		IN     NUMBER,
      P_INIT_MSG_LIST	        IN     VARCHAR2 := FND_API.G_FALSE,
      P_COMMIT			IN     VARCHAR2 := FND_API.G_FALSE,
      P_VALIDATION_LEVEL        IN     NUMBER   := FND_API.G_VALID_LEVEL_FULL, -- not used
      P_RESP_APPL_ID		IN     NUMBER   := NULL, -- not used
      P_RESP_ID			IN     NUMBER   := NULL, -- not used
      P_USER_ID			IN     NUMBER   := NULL,
      P_LOGIN_ID		IN     NUMBER   := FND_API.G_MISS_NUM,
      P_ORG_ID			IN     NUMBER   := NULL, -- not used
      P_LINK_ID			IN     NUMBER,           -- no change
      X_RETURN_STATUS	        OUT NOCOPY   VARCHAR2,
      X_MSG_COUNT		OUT NOCOPY   NUMBER,
      X_MSG_DATA		OUT NOCOPY   VARCHAR2 );

   PROCEDURE DELETE_INCIDENTLINK (
      P_API_VERSION		IN     NUMBER,
      P_INIT_MSG_LIST	        IN     VARCHAR2 := FND_API.G_FALSE,
      P_COMMIT			IN     VARCHAR2 := FND_API.G_FALSE,
      P_VALIDATION_LEVEL        IN     NUMBER   := FND_API.G_VALID_LEVEL_FULL, -- not used
      P_RESP_APPL_ID		IN     NUMBER   := NULL, -- not used
      P_RESP_ID			IN     NUMBER   := NULL, -- not used
      P_USER_ID			IN     NUMBER   := NULL,
      P_LOGIN_ID		IN     NUMBER   := FND_API.G_MISS_NUM,
      P_ORG_ID			IN     NUMBER   := NULL, -- not used
      P_LINK_ID			IN     NUMBER,           -- no change
      X_RETURN_STATUS	        OUT NOCOPY   VARCHAR2,
      X_MSG_COUNT		OUT NOCOPY   NUMBER,
      X_MSG_DATA		OUT NOCOPY   VARCHAR2,
      P_LINK_ID_EXT             IN     NUMBER  ); -- new in 11.5.9.1 for bugs 2972584 and 2972611

   PROCEDURE GET_DOC_NUMBER (
      S_SQL_STATEMENT		IN           VARCHAR2,
      S_DOC_NUMBER              OUT NOCOPY   VARCHAR2);

   PROCEDURE GET_DOC_DETAILS (
      S_SQL_STATEMENT		IN           VARCHAR2,
      S_DOC_ID			OUT NOCOPY   NUMBER,
      S_DOC_NUMBER		OUT NOCOPY   VARCHAR2,
      S_DOC_SEVERITY		OUT NOCOPY   VARCHAR2,
      S_DOC_STATUS		OUT NOCOPY   VARCHAR2,
      S_DOC_SUMMARY		OUT NOCOPY   VARCHAR2,
      S_DOC_PROD		OUT NOCOPY   VARCHAR2,
      S_DOC_PROD_DESC		OUT NOCOPY   VARCHAR2);

   /*******************
      The _EXT procedures are obsoleted for 11.5.9. All external links in 11.5.9 will
      be stored in table cs_incident_links. Procedures are not dropped, rather their
      implementations will be stubbed out for backward compatability
   ********************/

   PROCEDURE CREATE_INCIDENTLINK_EXT (
      P_API_VERSION		IN     NUMBER,
      P_INIT_MSG_LIST     	IN     VARCHAR2 := FND_API.G_FALSE,
      P_COMMIT     		IN     VARCHAR2 := FND_API.G_FALSE,
      P_VALIDATION_LEVEL  	IN     NUMBER   := FND_API.G_VALID_LEVEL_FULL,
      P_RESP_APPL_ID		IN     NUMBER   := NULL,
      P_RESP_ID		        IN     NUMBER   := NULL,
      P_USER_ID		        IN     NUMBER   := NULL,
      P_LOGIN_ID		IN     NUMBER   := FND_API.G_MISS_NUM,
      P_ORG_ID		        IN     NUMBER   := NULL,
      P_FROM_INCIDENT_ID	IN     NUMBER,
      P_TO_OBJECT_ID		IN     NUMBER,
      P_TO_OBJECT_NUMBER	IN     VARCHAR2,
      P_TO_OBJECT_TYPE	        IN     VARCHAR2,
      P_LINK_SEGMENT1		IN     VARCHAR2 := FND_API.G_MISS_CHAR,
      P_LINK_SEGMENT2		IN     VARCHAR2 := FND_API.G_MISS_CHAR,
      P_LINK_SEGMENT3		IN     VARCHAR2 := FND_API.G_MISS_CHAR,
      P_LINK_SEGMENT4		IN     VARCHAR2 := FND_API.G_MISS_CHAR,
      P_LINK_SEGMENT5		IN     VARCHAR2 := FND_API.G_MISS_CHAR,
      P_LINK_SEGMENT6		IN     VARCHAR2 := FND_API.G_MISS_CHAR,
      P_LINK_SEGMENT7		IN     VARCHAR2 := FND_API.G_MISS_CHAR,
      P_LINK_SEGMENT8		IN     VARCHAR2 := FND_API.G_MISS_CHAR,
      P_LINK_SEGMENT9		IN     VARCHAR2 := FND_API.G_MISS_CHAR,
      P_LINK_SEGMENT10	        IN     VARCHAR2 := FND_API.G_MISS_CHAR,
      P_LINK_CONTEXT		IN     VARCHAR2 := FND_API.G_MISS_CHAR,
      X_LINK_ID		        OUT NOCOPY   NUMBER,
      X_RETURN_STATUS		OUT NOCOPY   VARCHAR2,
      X_MSG_COUNT		OUT NOCOPY   NUMBER,
      X_MSG_DATA		OUT NOCOPY   VARCHAR2 );

   PROCEDURE UPDATE_INCIDENTLINK_EXT (
      P_API_VERSION		IN     NUMBER,
      P_INIT_MSG_LIST	        IN     VARCHAR2 := FND_API.G_FALSE,
      P_COMMIT			IN     VARCHAR2 := FND_API.G_FALSE,
      P_VALIDATION_LEVEL        IN     NUMBER   := FND_API.G_VALID_LEVEL_FULL,
      P_RESP_APPL_ID		IN     NUMBER   := NULL,
      P_RESP_ID			IN     NUMBER   := NULL,
      P_USER_ID			IN     NUMBER   := NULL,
      P_LOGIN_ID		IN     NUMBER   := FND_API.G_MISS_NUM,
      P_ORG_ID			IN     NUMBER   := NULL,
      P_LINK_ID			IN     NUMBER,
      P_FROM_INCIDENT_ID	IN     NUMBER   := NULL,
      P_TO_OBJECT_ID		IN     NUMBER   := NULL,
      P_TO_OBJECT_TYPE	        IN     VARCHAR2 := NULL,
      P_LINK_SEGMENT1	        IN     VARCHAR2 := FND_API.G_MISS_CHAR,
      P_LINK_SEGMENT2	        IN     VARCHAR2 := FND_API.G_MISS_CHAR,
      P_LINK_SEGMENT3	        IN     VARCHAR2 := FND_API.G_MISS_CHAR,
      P_LINK_SEGMENT4	        IN     VARCHAR2 := FND_API.G_MISS_CHAR,
      P_LINK_SEGMENT5	        IN     VARCHAR2 := FND_API.G_MISS_CHAR,
      P_LINK_SEGMENT6	        IN     VARCHAR2 := FND_API.G_MISS_CHAR,
      P_LINK_SEGMENT7	        IN     VARCHAR2 := FND_API.G_MISS_CHAR,
      P_LINK_SEGMENT8	        IN     VARCHAR2 := FND_API.G_MISS_CHAR,
      P_LINK_SEGMENT9	        IN     VARCHAR2 := FND_API.G_MISS_CHAR,
      P_LINK_SEGMENT10	        IN     VARCHAR2 := FND_API.G_MISS_CHAR,
      P_LINK_CONTEXT		IN     VARCHAR2 := FND_API.G_MISS_CHAR,
      X_RETURN_STATUS	        OUT NOCOPY   VARCHAR2,
      X_MSG_COUNT		OUT NOCOPY   NUMBER,
      X_MSG_DATA		OUT NOCOPY   VARCHAR2 );

   PROCEDURE DELETE_INCIDENTLINK_EXT (
      P_API_VERSION		IN     NUMBER,
      P_INIT_MSG_LIST	        IN     VARCHAR2 := FND_API.G_FALSE,
      P_COMMIT			IN     VARCHAR2 := FND_API.G_FALSE,
      P_VALIDATION_LEVEL        IN     NUMBER   := FND_API.G_VALID_LEVEL_FULL,
      P_RESP_APPL_ID		IN     NUMBER   := NULL,
      P_RESP_ID			IN     NUMBER   := NULL,
      P_USER_ID			IN     NUMBER   := NULL,
      P_LOGIN_ID		IN     NUMBER   := FND_API.G_MISS_NUM,
      P_ORG_ID			IN     NUMBER   := NULL,
      P_LINK_ID			IN     NUMBER,
      X_RETURN_STATUS	        OUT NOCOPY   VARCHAR2,
      X_MSG_COUNT		OUT NOCOPY   NUMBER,
      X_MSG_DATA		OUT NOCOPY   VARCHAR2 );

    PROCEDURE Delete_IncidentLink
    (
      p_api_version_number IN  NUMBER := 1.0
    , p_init_msg_list      IN  VARCHAR2 := FND_API.G_FALSE
    , p_commit             IN  VARCHAR2 := FND_API.G_FALSE
    , p_object_type        IN  VARCHAR2
    , p_processing_set_id  IN  NUMBER
    , x_return_status      OUT NOCOPY  VARCHAR2
    , x_msg_count          OUT NOCOPY  NUMBER
    , x_msg_data           OUT NOCOPY  VARCHAR2
    );

END CS_INCIDENTLINKS_PVT;

 

/
