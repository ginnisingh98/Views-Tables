--------------------------------------------------------
--  DDL for Package JTF_EC_REFERENCES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_EC_REFERENCES_PVT" AUTHID CURRENT_USER AS
/* $Header: jtfecres.pls 120.1 2005/07/02 00:41:32 appldev ship $ */
/*#
 * This is the private interface to the JTF Escalation Management.
 * This Interface is used to Create / Update / Delete References for
 * the escalations.
 *
 * @rep:scope private
 * @rep:product JTF
 * @rep:lifecycle active
 * @rep:displayname Escalation Management
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY JTA_ESCALATION
*/

/*#
* Creates an Escalation Reference.  After successful creation, triggers the BES for
* create escalation reference event.
*
* @param p_api_version the standard API version number
* @param p_init_msg_list the standard API flag allows API callers to request
* that the API does the initialization of the message list on their behalf.
* By default, the message list will not be initialized.
* @param p_commit the standard API flag is used by API callers to ask
* the API to commit on their behalf after performing its function
* By default, the commit will not be performed.
* @param p_escalation_id the escalation id
* @param p_escalation_number the escalation number
* @param p_object_type_code the refernce object type code
* @param p_object_name the reference object name
* @param p_object_id the reference object id
* @param p_object_details the reference object details
* @param p_reference_code the reference code eg. esc for escalations
* @param p_usage the usage for reference creation
* @param x_return_status the parameter that returns the result of all the operations performed.
* by the API and must have one of the following values:
*   <LI><Code>FND_API.G_RET_STS_SUCCESS</Code>
*   <LI><Code>FND_API.G_RET_STS_ERROR</Code>
*   <LI><Code>FND_API.G_RET_STS_UNEXP_ERROR</Code>
* @param x_msg_data the parameter that returns the FND Message in encoded format.
* @param x_msg_count the parameter that returns the number of messages in the FND message list.
* @param x_escalation_reference_id the parameter that returns the Escalation reference ID
* @param p_attribute1 the value of the flex field attribute1
* @param p_attribute2 the value of the flex field attribute2
* @param p_attribute3 the value of the flex field attribute3
* @param p_attribute4 the value of the flex field attribute4
* @param p_attribute5 the value of the flex field attribute5
* @param p_attribute6 the value of the flex field attribute6
* @param p_attribute7 the value of the flex field attribute7
* @param p_attribute8 the value of the flex field attribute8
* @param p_attribute9 the value of the flex field attribute9
* @param p_attribute10 the value of the flex field attribute10
* @param p_attribute11 the value of the flex field attribute11
* @param p_attribute12 the value of the flex field attribute12
* @param p_attribute13 the value of the flex field attribute13
* @param p_attribute14 the value of the flex field attribute14
* @param p_attribute15 the value of the flex field attribute15
* @param p_attribute_category the value of the flex field attribute category
* @rep:scope private
* @rep:lifecycle active
* @rep:displayname Create Escalation Reference
* @rep:compatibility S
*/
   PROCEDURE create_references (
      p_api_version               IN       NUMBER,
      p_init_msg_list             IN       VARCHAR2 DEFAULT fnd_api.g_false,
      p_commit                    IN       VARCHAR2 DEFAULT fnd_api.g_false,
      p_escalation_id             IN       NUMBER DEFAULT NULL,
      p_escalation_number         IN       VARCHAR2 DEFAULT NULL,
      p_object_type_code          IN       VARCHAR2,
      p_object_name               IN       VARCHAR2,
      p_object_id                 IN       NUMBER,
      p_object_details            IN       VARCHAR2 DEFAULT NULL,
      p_reference_code            IN       VARCHAR2 DEFAULT NULL,
      p_usage                     IN       VARCHAR2 DEFAULT NULL,
      x_return_status             OUT NOCOPY     VARCHAR2,
      x_msg_data                  OUT NOCOPY     VARCHAR2,
      x_msg_count                 OUT NOCOPY     NUMBER,
      x_escalation_reference_id   OUT NOCOPY     NUMBER,
      p_attribute1                IN       VARCHAR2 DEFAULT null ,
      p_attribute2                IN       VARCHAR2 DEFAULT null ,
      p_attribute3                IN       VARCHAR2 DEFAULT null ,
      p_attribute4                IN       VARCHAR2 DEFAULT null ,
      p_attribute5                IN       VARCHAR2 DEFAULT null ,
      p_attribute6                IN       VARCHAR2 DEFAULT null ,
      p_attribute7                IN       VARCHAR2 DEFAULT null ,
      p_attribute8                IN       VARCHAR2 DEFAULT null ,
      p_attribute9                IN       VARCHAR2 DEFAULT null ,
      p_attribute10               IN       VARCHAR2 DEFAULT null ,
      p_attribute11               IN       VARCHAR2 DEFAULT null ,
      p_attribute12               IN       VARCHAR2 DEFAULT null ,
      p_attribute13               IN       VARCHAR2 DEFAULT null ,
      p_attribute14               IN       VARCHAR2 DEFAULT null ,
      p_attribute15               IN       VARCHAR2 DEFAULT null ,
      p_attribute_category        IN       VARCHAR2 DEFAULT null

   );

/*#
* Updates an Escalation Reference.  After successful updation, triggers the BES for
* update escalation reference event.
*
* @param p_api_version the standard API version number
* @param p_init_msg_list the standard API flag allows API callers to request
* that the API does the initialization of the message list on their behalf.
* By default, the message list will not be initialized.
* @param p_commit the standard API flag is used by API callers to ask
* the API to commit on their behalf after performing its function
* By default, the commit will not be performed.
* @param p_object_version_number the object version number of the escalation reference record
* @param p_escalation_reference_id the escalation reference id
* @param p_object_type_code the reference object type code
* @param p_object_name the reference object name
* @param p_object_id the reference object id
* @param p_object_details the reference object details
* @param p_reference_code the reference code eg. esc for escalations
* @param p_usage the usage for reference creation
* @param x_return_status the parameter that returns the result of all the operations performed.
* by the API and must have one of the following values:
*   <LI><Code>FND_API.G_RET_STS_SUCCESS</Code>
*   <LI><Code>FND_API.G_RET_STS_ERROR</Code>
*   <LI><Code>FND_API.G_RET_STS_UNEXP_ERROR</Code>
* @param x_msg_data the parameter that returns the FND Message in encoded format.
* @param x_msg_count the parameter that returns the number of messages in the FND message list.
* @param p_attribute1 the value of the flex field attribute1
* @param p_attribute2 the value of the flex field attribute2
* @param p_attribute3 the value of the flex field attribute3
* @param p_attribute4 the value of the flex field attribute4
* @param p_attribute5 the value of the flex field attribute5
* @param p_attribute6 the value of the flex field attribute6
* @param p_attribute7 the value of the flex field attribute7
* @param p_attribute8 the value of the flex field attribute8
* @param p_attribute9 the value of the flex field attribute9
* @param p_attribute10 the value of the flex field attribute10
* @param p_attribute11 the value of the flex field attribute11
* @param p_attribute12 the value of the flex field attribute12
* @param p_attribute13 the value of the flex field attribute13
* @param p_attribute14 the value of the flex field attribute14
* @param p_attribute15 the value of the flex field attribute15
* @param p_attribute_category the value of the flex field attribute category
* @param p_task_id the escalation id
* @rep:scope private
* @rep:lifecycle active
* @rep:displayname Update Escalation Reference
* @rep:compatibility S
*/
   PROCEDURE update_references (
      p_api_version               IN       NUMBER,
      p_init_msg_list             IN       VARCHAR2 DEFAULT fnd_api.g_false,
      p_commit                    IN       VARCHAR2 DEFAULT fnd_api.g_false,
      p_object_version_number     IN OUT NOCOPY  NUMBER,
      p_escalation_reference_id   IN       NUMBER,
      p_object_type_code          IN       VARCHAR2 DEFAULT fnd_api.g_miss_char,
      p_object_name               IN       VARCHAR2 DEFAULT fnd_api.g_miss_char,
      p_object_id                 IN       NUMBER DEFAULT fnd_api.g_miss_num,
      p_object_details            IN       VARCHAR2 DEFAULT fnd_api.g_miss_char,
      p_reference_code            IN       VARCHAR2 DEFAULT fnd_api.g_miss_char,
      p_usage                     IN       VARCHAR2 DEFAULT fnd_api.g_miss_char,
      x_return_status             OUT NOCOPY     VARCHAR2,
      x_msg_data                  OUT NOCOPY     VARCHAR2,
      x_msg_count                 OUT NOCOPY     NUMBER,
      p_attribute1                IN       VARCHAR2 DEFAULT null ,
      p_attribute2                IN       VARCHAR2 DEFAULT null ,
      p_attribute3                IN       VARCHAR2 DEFAULT null ,
      p_attribute4                IN       VARCHAR2 DEFAULT null ,
      p_attribute5                IN       VARCHAR2 DEFAULT null ,
      p_attribute6                IN       VARCHAR2 DEFAULT null ,
      p_attribute7                IN       VARCHAR2 DEFAULT null ,
      p_attribute8                IN       VARCHAR2 DEFAULT null ,
      p_attribute9                IN       VARCHAR2 DEFAULT null ,
      p_attribute10               IN       VARCHAR2 DEFAULT null ,
      p_attribute11               IN       VARCHAR2 DEFAULT null ,
      p_attribute12               IN       VARCHAR2 DEFAULT null ,
      p_attribute13               IN       VARCHAR2 DEFAULT null ,
      p_attribute14               IN       VARCHAR2 DEFAULT null ,
      p_attribute15               IN       VARCHAR2 DEFAULT null ,
      p_attribute_category        IN       VARCHAR2 DEFAULT null ,
      p_task_id			  IN	   NUMBER DEFAULT fnd_api.g_miss_num
   );


/*#
* Deletes an Escalation Reference.  After successful deletion, triggers the BES for
* delete escalation reference event.
*
* @param p_api_version the standard API version number
* @param p_init_msg_list the standard API flag allows API callers to request
* that the API does the initialization of the message list on their behalf.
* By default, the message list will not be initialized.
* @param p_commit the standard API flag is used by API callers to ask
* the API to commit on their behalf after performing its function
* By default, the commit will not be performed.
* @param p_object_version_number the object version number of the escalation reference record
* @param p_escalation_reference_id the escalation reference id
* @param x_return_status the parameter that returns the result of all the operations performed.
* by the API and must have one of the following values:
*   <LI><Code>FND_API.G_RET_STS_SUCCESS</Code>
*   <LI><Code>FND_API.G_RET_STS_ERROR</Code>
*   <LI><Code>FND_API.G_RET_STS_UNEXP_ERROR</Code>
* @param x_msg_data the parameter that returns the FND Message in encoded format.
* @param x_msg_count the parameter that returns the number of messages in the FND message list.
* @rep:scope private
* @rep:lifecycle active
* @rep:displayname Update Escalation Reference
* @rep:compatibility S
*/
   PROCEDURE delete_references (
      p_api_version               IN       NUMBER,
      p_init_msg_list             IN       VARCHAR2 DEFAULT fnd_api.g_false,
      p_commit                    IN       VARCHAR2 DEFAULT fnd_api.g_false,
      p_object_version_number     IN       NUMBER,
      p_escalation_reference_id   IN       NUMBER,
      x_return_status             OUT NOCOPY     VARCHAR2,
      x_msg_data                  OUT NOCOPY     VARCHAR2,
      x_msg_count                 OUT NOCOPY     NUMBER
   );

--Created for BES enh 2660883

TYPE Esc_Ref_rec IS RECORD (
	TASK_REFERENCE_ID	JTF_TASK_REFERENCES_B.TASK_REFERENCE_ID%TYPE := FND_API.G_MISS_NUM,
	OBJECT_TYPE_CODE 	JTF_TASK_REFERENCES_B.OBJECT_TYPE_CODE%TYPE := FND_API.G_MISS_CHAR,
	REFERENCE_CODE		JTF_TASK_REFERENCES_B.REFERENCE_CODE%TYPE := FND_API.G_MISS_CHAR,
	OBJECT_ID		JTF_TASK_REFERENCES_B.OBJECT_ID%TYPE := FND_API.G_MISS_NUM,
	TASK_ID			JTF_TASK_REFERENCES_B.TASK_ID%TYPE := FND_API.G_MISS_NUM
	);

END;

 

/
