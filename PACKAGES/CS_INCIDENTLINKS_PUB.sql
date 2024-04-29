--------------------------------------------------------
--  DDL for Package CS_INCIDENTLINKS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CS_INCIDENTLINKS_PUB" AUTHID CURRENT_USER AS
/* $Header: cspsrls.pls 120.0 2005/11/08 10:11:43 smisra noship $ */
/*#
 * Service Request Links provides functions to enable user to create, update and delete
 * service request links to a service request object.
 *
 * @rep:scope public
 * @rep:product CS
 * @rep:displayname Service Request Link
 * @rep:lifecycle active
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY CS_SERVICE_REQUEST
 */

/**** Above text has been added to enable the integration repository to extract the data
      from the source code file and populate the integration repository schema so that the
      interfaces defined in this package appears in the integration repository.
****/

   -- Added record structures to be used as IN parameters
   -- New for 1159
   -- This will be used in the overloaded procedures for create/update links.
   -- Note : The record type does **not** have the object version number.
   --        Also it does not have the four 1159 obsoleted parameters.
   --        ie. from_incident_id, from_incident_number, to_incident_id and
   --        to_incident_number
   TYPE CS_INCIDENT_LINK_REC_TYPE IS RECORD (
      LINK_ID                        NUMBER         := NULL, -- new for 1159
      SUBJECT_ID                     NUMBER         := NULL, -- new for 1159
      SUBJECT_TYPE                   VARCHAR2(30)   := NULL, -- new for 1159
      OBJECT_ID                      NUMBER         := NULL, -- new for 1159
      OBJECT_NUMBER                  VARCHAR2(90)   := NULL, -- new for 1159
      OBJECT_TYPE                    VARCHAR2(30)   := NULL, -- new for 1159
      LINK_TYPE_ID                   NUMBER         := NULL, -- new for 1159
      LINK_TYPE		             VARCHAR2(240), -- no change
      REQUEST_ID                     NUMBER         := NULL,  -- new for 1159
      PROGRAM_APPLICATION_ID         NUMBER         := NULL,  -- new for 1159
      PROGRAM_ID                     NUMBER         := NULL,  -- new for 1159
      PROGRAM_UPDATE_DATE            DATE           := NULL,  -- new for 1159
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
      LINK_SEGMENT11	             VARCHAR2(150)  := FND_API.G_MISS_CHAR, -- new for 1159
      LINK_SEGMENT12	             VARCHAR2(150)  := FND_API.G_MISS_CHAR, -- new for 1159
      LINK_SEGMENT13	             VARCHAR2(150)  := FND_API.G_MISS_CHAR, -- new for 1159
      LINK_SEGMENT14	             VARCHAR2(150)  := FND_API.G_MISS_CHAR, -- new for 1159
      LINK_SEGMENT15	             VARCHAR2(150)  := FND_API.G_MISS_CHAR, -- new for 1159
      LINK_CONTEXT		     VARCHAR2(30)   := FND_API.G_MISS_CHAR );

   -- Overloaded procedure (new for 1159) that accepts a record structure. This
   -- procedure calls the create procedure with the detailed list of parameters.
   -- Invoking programs can use either one of the procedures.
/*#
 * Create Service Request Link enables user to create service request link for
 * an instance of a service request object.
 * Please refer to the Metalink for parameter details.
 *
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:compatibility S
 * @rep:displayname Create Service Request Link
 * @rep:primaryinstance
 * @rep:businessevent oracle.apps.cs.sr.ServiceRequest.relationshipcreated
 * @rep:metalink 131739.1 Oracle Teleservice Implementation Guide Release 11.5.9
 */


/**** Above text has been added to enable the integration repository to extract the data
      from the source code file and populate the integration repository schema so that
      Create_IncidentLink API appears in the integration repository.
****/

   PROCEDURE CREATE_INCIDENTLINK (
      P_API_VERSION		IN     NUMBER,
      P_INIT_MSG_LIST           IN     VARCHAR2  := FND_API.G_FALSE,
      P_COMMIT     		IN     VARCHAR2  := FND_API.G_FALSE,
      P_RESP_APPL_ID		IN     NUMBER    := NULL, -- not used
      P_RESP_ID			IN     NUMBER    := NULL, -- not used
      P_USER_ID			IN     NUMBER    := NULL,
      P_LOGIN_ID		IN     NUMBER    := FND_API.G_MISS_NUM,
      P_ORG_ID			IN     NUMBER    := NULL, -- not used
      P_LINK_REC                IN     CS_INCIDENT_LINK_REC_TYPE := NULL,
      X_RETURN_STATUS	        OUT NOCOPY   VARCHAR2,
      X_MSG_COUNT		OUT NOCOPY   NUMBER,
      X_MSG_DATA		OUT NOCOPY   VARCHAR2,
      X_OBJECT_VERSION_NUMBER   OUT NOCOPY   NUMBER, -- new for 1159
      X_RECIPROCAL_LINK_ID      OUT NOCOPY   NUMBER, -- new for 1159
      X_LINK_ID			OUT NOCOPY   NUMBER );

   -- This is an overloaded procedure introduced for backward compatibility in 11.5.9.1
   -- The signature is the same as the pre-11.5.9 version of this procedure.

   PROCEDURE CREATE_INCIDENTLINK (
      P_API_VERSION		IN     NUMBER,
      P_INIT_MSG_LIST         	IN     VARCHAR2  := FND_API.G_FALSE,
      P_COMMIT     		IN     VARCHAR2  := FND_API.G_FALSE,
      P_RESP_APPL_ID		IN     NUMBER    := NULL, -- not used
      P_RESP_ID			IN     NUMBER    := NULL, -- not used
      P_USER_ID			IN     NUMBER    := NULL,
      P_LOGIN_ID		IN     NUMBER    := FND_API.G_MISS_NUM,
      P_ORG_ID			IN     NUMBER    := NULL, -- not used
      P_LINK_TYPE		IN     VARCHAR2  := NULL, -- existed prior to 1159. Made this
						 	  -- param non mandatory in 1159
      P_FROM_INCIDENT_ID      IN     NUMBER    := NULL,
      P_FROM_INCIDENT_NUMBER  IN     VARCHAR2  := NULL,
      P_TO_INCIDENT_ID	      IN     NUMBER    := NULL,
      P_TO_INCIDENT_NUMBER    IN     VARCHAR2  := NULL,
      P_LINK_SEGMENT1	      IN     VARCHAR2  := FND_API.G_MISS_CHAR,
      P_LINK_SEGMENT2	      IN     VARCHAR2  := FND_API.G_MISS_CHAR,
      P_LINK_SEGMENT3	      IN     VARCHAR2  := FND_API.G_MISS_CHAR,
      P_LINK_SEGMENT4	      IN     VARCHAR2  := FND_API.G_MISS_CHAR,
      P_LINK_SEGMENT5	      IN     VARCHAR2  := FND_API.G_MISS_CHAR,
      P_LINK_SEGMENT6	      IN     VARCHAR2  := FND_API.G_MISS_CHAR,
      P_LINK_SEGMENT7	      IN     VARCHAR2  := FND_API.G_MISS_CHAR,
      P_LINK_SEGMENT8	      IN     VARCHAR2  := FND_API.G_MISS_CHAR,
      P_LINK_SEGMENT9	      IN     VARCHAR2  := FND_API.G_MISS_CHAR,
      P_LINK_SEGMENT10	      IN     VARCHAR2  := FND_API.G_MISS_CHAR,
      P_LINK_CONTEXT	      IN     VARCHAR2  := FND_API.G_MISS_CHAR, -- new for 1159
      X_RETURN_STATUS	      OUT NOCOPY   VARCHAR2,
      X_MSG_COUNT	      OUT NOCOPY   NUMBER,
      X_MSG_DATA	      OUT NOCOPY   VARCHAR2,
      X_LINK_ID		      OUT NOCOPY   NUMBER );


   PROCEDURE CREATE_INCIDENTLINK (
      P_API_VERSION		IN     NUMBER,
      P_INIT_MSG_LIST           IN     VARCHAR2  := FND_API.G_FALSE,
      P_COMMIT     		IN     VARCHAR2  := FND_API.G_FALSE,
      P_RESP_APPL_ID		IN     NUMBER    := NULL, -- not used
      P_RESP_ID			IN     NUMBER    := NULL, -- not used
      P_USER_ID			IN     NUMBER    := NULL,
      P_LOGIN_ID		IN     NUMBER    := FND_API.G_MISS_NUM,
      P_ORG_ID			IN     NUMBER    := NULL, -- not used
      P_LINK_ID                 IN     NUMBER    := NULL, -- new for 1159
      P_SUBJECT_ID              IN     NUMBER    := NULL, -- new for 1159
      P_SUBJECT_TYPE            IN     VARCHAR2  := NULL, -- new for 1159
      P_OBJECT_ID               IN     NUMBER    := NULL, -- new for 1159
      P_OBJECT_NUMBER           IN     VARCHAR2  := NULL, -- new for 1159
      P_OBJECT_TYPE             IN     VARCHAR2  := NULL, -- new for 1159
      P_LINK_TYPE_ID            IN     NUMBER    := NULL, -- new for 1159
      P_LINK_TYPE		IN     VARCHAR2  := NULL, -- existed prior to 1159. Made this
						 	  -- param non mandatory in 1159
      P_REQUEST_ID              IN     NUMBER    := NULL,  -- new for 1159
      P_PROGRAM_APPLICATION_ID  IN     NUMBER    := NULL,  -- new for 1159
      P_PROGRAM_ID              IN     NUMBER    := NULL,  -- new for 1159
      P_PROGRAM_UPDATE_DATE     IN     DATE      := NULL,  -- new for 1159
      P_FROM_INCIDENT_ID	IN     NUMBER    := NULL, -- obsoleted for 1159
      P_FROM_INCIDENT_NUMBER	IN     VARCHAR2  := NULL, -- obsoleted for 1159
      P_TO_INCIDENT_ID	        IN     NUMBER    := NULL, -- obsoleted for 1159
      P_TO_INCIDENT_NUMBER	IN     VARCHAR2  := NULL, -- obsoleted for 1159
      P_LINK_SEGMENT1	        IN     VARCHAR2  := FND_API.G_MISS_CHAR,
      P_LINK_SEGMENT2	        IN     VARCHAR2  := FND_API.G_MISS_CHAR,
      P_LINK_SEGMENT3	        IN     VARCHAR2  := FND_API.G_MISS_CHAR,
      P_LINK_SEGMENT4	        IN     VARCHAR2  := FND_API.G_MISS_CHAR,
      P_LINK_SEGMENT5	        IN     VARCHAR2  := FND_API.G_MISS_CHAR,
      P_LINK_SEGMENT6	        IN     VARCHAR2  := FND_API.G_MISS_CHAR,
      P_LINK_SEGMENT7	        IN     VARCHAR2  := FND_API.G_MISS_CHAR,
      P_LINK_SEGMENT8	        IN     VARCHAR2  := FND_API.G_MISS_CHAR,
      P_LINK_SEGMENT9	        IN     VARCHAR2  := FND_API.G_MISS_CHAR,
      P_LINK_SEGMENT10	        IN     VARCHAR2  := FND_API.G_MISS_CHAR,
      P_LINK_SEGMENT11	        IN     VARCHAR2  := FND_API.G_MISS_CHAR, -- new for 1159
      P_LINK_SEGMENT12	        IN     VARCHAR2  := FND_API.G_MISS_CHAR, -- new for 1159
      P_LINK_SEGMENT13	        IN     VARCHAR2  := FND_API.G_MISS_CHAR, -- new for 1159
      P_LINK_SEGMENT14	        IN     VARCHAR2  := FND_API.G_MISS_CHAR, -- new for 1159
      P_LINK_SEGMENT15	        IN     VARCHAR2  := FND_API.G_MISS_CHAR, -- new for 1159
      P_LINK_CONTEXT		IN     VARCHAR2  := FND_API.G_MISS_CHAR, -- new for 1159
      X_RETURN_STATUS	        OUT NOCOPY   VARCHAR2,
      X_MSG_COUNT		OUT NOCOPY   NUMBER,
      X_MSG_DATA		OUT NOCOPY   VARCHAR2,
      X_RECIPROCAL_LINK_ID      OUT NOCOPY   NUMBER, -- new for 1159
      X_OBJECT_VERSION_NUMBER   OUT NOCOPY   NUMBER, -- new for 1159
      X_LINK_ID			        OUT NOCOPY   NUMBER );

   -- Overloaded procedure (new for 1159) that accepts a record structure. This
   -- procedure calls the update procedure with the detailed list of parameters.
   -- Invoking programs can use either one of the procedures.
/*#
 * Update Service Request Link enables user to update service request link.
 * This version is primarily used for release 11.5.9 and other forward releases.
 * Please refer to the Metalink for parameter details.
 *
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:compatibility S
 * @rep:displayname Update Service Request Link
 * @rep:primaryinstance
 * @rep:businessevent oracle.apps.cs.sr.ServiceRequest.relationshipcreated
 * @rep:metalink 131739.1 Oracle Teleservice Implementation Guide Release 11.5.9
 *
 */

/**** Above text has been added to enable the integration repository to extract the data
      from the source code file and populate the integration repository schema so that
      Update_IncidentLink API appears in the integration repository.
****/

   PROCEDURE UPDATE_INCIDENTLINK (
      P_API_VERSION		IN     NUMBER,
      P_INIT_MSG_LIST		IN     VARCHAR2  := FND_API.G_FALSE,
      P_COMMIT			IN     VARCHAR2  := FND_API.G_FALSE,
      P_RESP_APPL_ID		IN     NUMBER    := NULL,  -- not used
      P_RESP_ID			IN     NUMBER    := NULL,  -- not used
      P_USER_ID			IN     NUMBER    := NULL,
      P_LOGIN_ID		IN     NUMBER    := FND_API.G_MISS_NUM,
      P_ORG_ID			IN     NUMBER    := NULL,  -- not used
      P_LINK_ID			IN     NUMBER,             -- no change
      P_OBJECT_VERSION_NUMBER   IN     NUMBER,             -- new for 1159
      P_LINK_REC                IN     CS_INCIDENT_LINK_REC_TYPE := NULL,
      X_RETURN_STATUS	        OUT NOCOPY   VARCHAR2,
      X_OBJECT_VERSION_NUMBER   OUT NOCOPY   NUMBER, -- new for 1159
      X_MSG_COUNT		OUT NOCOPY   NUMBER,
      X_MSG_DATA		OUT NOCOPY   VARCHAR2  );

   -- This is an overloaded procedure introduced for backward compatibility in 11.5.9.1
   -- The signature is the same as the pre-11.5.9 version of this procedure.

   PROCEDURE UPDATE_INCIDENTLINK (
      P_API_VERSION		IN     NUMBER,
      P_INIT_MSG_LIST		IN     VARCHAR2        := FND_API.G_FALSE,
      P_COMMIT			IN     VARCHAR2        := FND_API.G_FALSE,
      P_RESP_APPL_ID		IN     NUMBER          := NULL,
      P_RESP_ID			IN     NUMBER          := NULL,
      P_USER_ID			IN     NUMBER          := NULL,
      P_LOGIN_ID		IN     NUMBER          := FND_API.G_MISS_NUM,
      P_ORG_ID			IN     NUMBER          := NULL,
      P_LINK_ID			IN     NUMBER,
      P_FROM_INCIDENT_ID	IN     NUMBER          := NULL,
      P_FROM_INCIDENT_NUMBER	IN     VARCHAR2   := NULL,
      P_TO_INCIDENT_ID	        IN     NUMBER          := NULL,
      P_TO_INCIDENT_NUMBER	IN     VARCHAR2   := NULL,
      P_LINK_TYPE		IN     VARCHAR2        := NULL,
      P_LINK_SEGMENT1		IN     VARCHAR2        := FND_API.G_MISS_CHAR,
      P_LINK_SEGMENT2		IN     VARCHAR2        := FND_API.G_MISS_CHAR,
      P_LINK_SEGMENT3		IN     VARCHAR2        := FND_API.G_MISS_CHAR,
      P_LINK_SEGMENT4		IN     VARCHAR2        := FND_API.G_MISS_CHAR,
      P_LINK_SEGMENT5		IN     VARCHAR2        := FND_API.G_MISS_CHAR,
      P_LINK_SEGMENT6		IN     VARCHAR2        := FND_API.G_MISS_CHAR,
      P_LINK_SEGMENT7		IN     VARCHAR2        := FND_API.G_MISS_CHAR,
      P_LINK_SEGMENT8		IN     VARCHAR2        := FND_API.G_MISS_CHAR,
      P_LINK_SEGMENT9		IN     VARCHAR2        := FND_API.G_MISS_CHAR,
      P_LINK_SEGMENT10		IN     VARCHAR2        := FND_API.G_MISS_CHAR,
      P_LINK_CONTEXT		IN     VARCHAR2        := FND_API.G_MISS_CHAR,
      X_RETURN_STATUS	OUT NOCOPY    VARCHAR2,
      X_MSG_COUNT		OUT NOCOPY    NUMBER,
      X_MSG_DATA		OUT NOCOPY    VARCHAR2);


   PROCEDURE UPDATE_INCIDENTLINK (
      P_API_VERSION		IN     NUMBER,
      P_INIT_MSG_LIST	        IN     VARCHAR2  := FND_API.G_FALSE,
      P_COMMIT			IN     VARCHAR2  := FND_API.G_FALSE,
      P_RESP_APPL_ID		IN     NUMBER    := NULL,  -- not used
      P_RESP_ID			IN     NUMBER    := NULL,  -- not used
      P_USER_ID			IN     NUMBER    := NULL,
      P_LOGIN_ID		IN     NUMBER    := FND_API.G_MISS_NUM,
      P_ORG_ID			IN     NUMBER    := NULL,  -- not used
      P_LINK_ID			IN     NUMBER,             -- no change
      P_OBJECT_VERSION_NUMBER   IN     NUMBER,             -- new for 1159
      P_SUBJECT_ID              IN     NUMBER    := NULL,  -- new for 1159
      P_SUBJECT_TYPE            IN     VARCHAR2  := NULL,  -- new for 1159
      P_LINK_TYPE_ID            IN     NUMBER    := NULL,  -- new for 1159
      P_LINK_TYPE	 	IN     VARCHAR2  := NULL,  -- no change
      P_OBJECT_ID               IN     NUMBER    := NULL,  -- new for 1159
      P_OBJECT_NUMBER           IN     VARCHAR2  := NULL,  -- new for 1159
      P_OBJECT_TYPE             IN     VARCHAR2  := NULL,  -- new for 1159
      P_REQUEST_ID              IN     NUMBER    := NULL,  -- new for 1159
      P_PROGRAM_APPLICATION_ID  IN     NUMBER    := NULL,  -- new for 1159
      P_PROGRAM_ID              IN     NUMBER    := NULL,  -- new for 1159
      P_PROGRAM_UPDATE_DATE     IN     DATE      := NULL,  -- new for 1159
      P_FROM_INCIDENT_ID	IN     NUMBER    := NULL,  -- not used
      P_FROM_INCIDENT_NUMBER	IN     VARCHAR2  := NULL,  -- not used
      P_TO_INCIDENT_ID	        IN     NUMBER    := NULL,  -- not used
      P_TO_INCIDENT_NUMBER	IN     VARCHAR2  := NULL,  -- not used
      P_LINK_SEGMENT1	        IN     VARCHAR2  := FND_API.G_MISS_CHAR,
      P_LINK_SEGMENT2	        IN     VARCHAR2  := FND_API.G_MISS_CHAR,
      P_LINK_SEGMENT3	        IN     VARCHAR2  := FND_API.G_MISS_CHAR,
      P_LINK_SEGMENT4	        IN     VARCHAR2  := FND_API.G_MISS_CHAR,
      P_LINK_SEGMENT5	        IN     VARCHAR2  := FND_API.G_MISS_CHAR,
      P_LINK_SEGMENT6	        IN     VARCHAR2  := FND_API.G_MISS_CHAR,
      P_LINK_SEGMENT7	        IN     VARCHAR2  := FND_API.G_MISS_CHAR,
      P_LINK_SEGMENT8	        IN     VARCHAR2  := FND_API.G_MISS_CHAR,
      P_LINK_SEGMENT9	        IN     VARCHAR2  := FND_API.G_MISS_CHAR,
      P_LINK_SEGMENT10	        IN     VARCHAR2  := FND_API.G_MISS_CHAR,
      P_LINK_SEGMENT11	        IN     VARCHAR2  := FND_API.G_MISS_CHAR, -- new for 1159
      P_LINK_SEGMENT12	        IN     VARCHAR2  := FND_API.G_MISS_CHAR, -- new for 1159
      P_LINK_SEGMENT13	        IN     VARCHAR2  := FND_API.G_MISS_CHAR, -- new for 1159
      P_LINK_SEGMENT14	        IN     VARCHAR2  := FND_API.G_MISS_CHAR, -- new for 1159
      P_LINK_SEGMENT15	        IN     VARCHAR2  := FND_API.G_MISS_CHAR, -- new for 1159
      P_LINK_CONTEXT		IN     VARCHAR2  := FND_API.G_MISS_CHAR,
      X_RETURN_STATUS	        OUT NOCOPY   VARCHAR2,
      X_OBJECT_VERSION_NUMBER   OUT NOCOPY   NUMBER, -- new for 1159
      X_MSG_COUNT		OUT NOCOPY   NUMBER,
      X_MSG_DATA		OUT NOCOPY   VARCHAR2  );

/*#
 * Delete Service Request Link enables user to delete service
 * request link.
 * Please refer to the Metalink for parameter details.
 *
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:compatibility S
 * @rep:displayname Delete Service Request Link
 * @rep:primaryinstance
 * @rep:businessevent oracle.apps.cs.sr.ServiceRequest.relationshipdeleted
 * @rep:metalink 131739.1 Oracle Teleservice Implementation Guide Release 11.5.9
 */


/**** Above text has been added to enable the integration repository to extract the data
      from the source code file and populate the integration repository schema so that
      Delete_IncidentLink API appears in the integration repository.
****/


   PROCEDURE DELETE_INCIDENTLINK (
      P_API_VERSION		IN     NUMBER,
      P_INIT_MSG_LIST	        IN     VARCHAR2  := FND_API.G_FALSE,
      P_COMMIT			IN     VARCHAR2  := FND_API.G_FALSE,
      P_RESP_APPL_ID		IN     NUMBER    := NULL, -- not used
      P_RESP_ID			IN     NUMBER    := NULL, -- not used
      P_USER_ID			IN     NUMBER    := NULL, -- not used
      P_LOGIN_ID		IN     NUMBER    := FND_API.G_MISS_NUM,
      P_ORG_ID			IN     NUMBER    := NULL, -- not used
      P_LINK_ID			IN     NUMBER,   -- no change
      X_RETURN_STATUS	        OUT NOCOPY   VARCHAR2,
      X_MSG_COUNT		OUT NOCOPY   NUMBER,
      X_MSG_DATA		OUT NOCOPY   VARCHAR2 );

   /* The _EXT procedures have been restored in 11.5.9.1 All external links in 11.5.9.1 will
      be stored both in table cs_incident_links and in table cs_incident_links_ext.
   ********************/

   PROCEDURE CREATE_INCIDENTLINK_EXT (
      P_API_VERSION		IN     NUMBER,
      P_INIT_MSG_LIST           IN     VARCHAR2   := FND_API.G_FALSE,
      P_COMMIT     		IN     VARCHAR2   := FND_API.G_FALSE,
      X_RETURN_STATUS	        OUT NOCOPY   VARCHAR2,
      X_MSG_COUNT		OUT NOCOPY   NUMBER,
      X_MSG_DATA		OUT NOCOPY   VARCHAR2,
      P_RESP_APPL_ID		IN     NUMBER     := NULL,
      P_RESP_ID		        IN     NUMBER     := NULL,
      P_USER_ID		        IN     NUMBER     := NULL,
      P_LOGIN_ID		IN     NUMBER     := FND_API.G_MISS_NUM,
      P_ORG_ID		        IN     NUMBER     := NULL,
      P_FROM_INCIDENT_ID	IN     NUMBER     := NULL,
      P_FROM_INCIDENT_NUMBER	IN     NUMBER     := NULL,
      P_TO_OBJECT_ID		IN     NUMBER,
      P_TO_OBJECT_TYPE	        IN     VARCHAR2,
      P_LINK_SEGMENT1	        IN     VARCHAR2   := FND_API.G_MISS_CHAR,
      P_LINK_SEGMENT2	        IN     VARCHAR2   := FND_API.G_MISS_CHAR,
      P_LINK_SEGMENT3	        IN     VARCHAR2   := FND_API.G_MISS_CHAR,
      P_LINK_SEGMENT4	        IN     VARCHAR2   := FND_API.G_MISS_CHAR,
      P_LINK_SEGMENT5	        IN     VARCHAR2   := FND_API.G_MISS_CHAR,
      P_LINK_SEGMENT6	        IN     VARCHAR2   := FND_API.G_MISS_CHAR,
      P_LINK_SEGMENT7	        IN     VARCHAR2   := FND_API.G_MISS_CHAR,
      P_LINK_SEGMENT8	        IN     VARCHAR2   := FND_API.G_MISS_CHAR,
      P_LINK_SEGMENT9	        IN     VARCHAR2   := FND_API.G_MISS_CHAR,
      P_LINK_SEGMENT10	        IN     VARCHAR2   := FND_API.G_MISS_CHAR,
      P_LINK_CONTEXT		IN     VARCHAR2   := FND_API.G_MISS_CHAR,
      X_LINK_ID		        OUT NOCOPY   NUMBER  );

   PROCEDURE UPDATE_INCIDENTLINK_EXT (
      P_API_VERSION		IN     NUMBER,
      P_INIT_MSG_LIST	        IN     VARCHAR2  := FND_API.G_FALSE,
      P_COMMIT			IN     VARCHAR2  := FND_API.G_FALSE,
      X_RETURN_STATUS	        OUT NOCOPY   VARCHAR2,
      X_MSG_COUNT		OUT NOCOPY   NUMBER,
      X_MSG_DATA		OUT NOCOPY   VARCHAR2,
      P_RESP_APPL_ID		IN     NUMBER    := NULL,
      P_RESP_ID			IN     NUMBER    := NULL,
      P_USER_ID			IN     NUMBER    := NULL,
      P_LOGIN_ID		IN     NUMBER    := FND_API.G_MISS_NUM,
      P_ORG_ID			IN     NUMBER    := NULL,
      P_LINK_ID			IN     NUMBER,
      P_FROM_INCIDENT_ID	IN     NUMBER    := NULL,
      P_FROM_INCIDENT_NUMBER	IN     VARCHAR2  := NULL,
      P_TO_OBJECT_ID		IN     NUMBER    := FND_API.G_MISS_NUM,
      P_TO_OBJECT_TYPE	        IN     VARCHAR2  := FND_API.G_MISS_CHAR,
      P_LINK_SEGMENT1	        IN     VARCHAR2  := FND_API.G_MISS_CHAR,
      P_LINK_SEGMENT2	        IN     VARCHAR2  := FND_API.G_MISS_CHAR,
      P_LINK_SEGMENT3	        IN     VARCHAR2  := FND_API.G_MISS_CHAR,
      P_LINK_SEGMENT4	        IN     VARCHAR2  := FND_API.G_MISS_CHAR,
      P_LINK_SEGMENT5	        IN     VARCHAR2  := FND_API.G_MISS_CHAR,
      P_LINK_SEGMENT6	        IN     VARCHAR2  := FND_API.G_MISS_CHAR,
      P_LINK_SEGMENT7	        IN     VARCHAR2  := FND_API.G_MISS_CHAR,
      P_LINK_SEGMENT8	        IN     VARCHAR2  := FND_API.G_MISS_CHAR,
      P_LINK_SEGMENT9	        IN     VARCHAR2  := FND_API.G_MISS_CHAR,
      P_LINK_SEGMENT10	        IN     VARCHAR2  := FND_API.G_MISS_CHAR,
      P_LINK_CONTEXT		IN     VARCHAR2  := FND_API.G_MISS_CHAR );

   PROCEDURE DELETE_INCIDENTLINK_EXT (
      P_API_VERSION		IN     NUMBER,
      P_INIT_MSG_LIST	        IN     VARCHAR2   := FND_API.G_FALSE,
      P_COMMIT			IN     VARCHAR2   := FND_API.G_FALSE,
      X_RETURN_STATUS	        OUT NOCOPY   VARCHAR2,
      X_MSG_COUNT		OUT NOCOPY   NUMBER,
      X_MSG_DATA		OUT NOCOPY   VARCHAR2,
      P_RESP_APPL_ID		IN     NUMBER     := NULL,
      P_RESP_ID			IN     NUMBER     := NULL,
      P_USER_ID			IN     NUMBER     := NULL,
      P_LOGIN_ID		IN     NUMBER     := FND_API.G_MISS_NUM,
      P_ORG_ID			IN     NUMBER     := NULL,
      P_LINK_ID			IN     NUMBER );

END CS_INCIDENTLINKS_PUB;

 

/
