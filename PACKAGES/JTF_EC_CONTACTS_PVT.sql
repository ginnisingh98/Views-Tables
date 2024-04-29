--------------------------------------------------------
--  DDL for Package JTF_EC_CONTACTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_EC_CONTACTS_PVT" AUTHID CURRENT_USER AS
/* $Header: jtfeccos.pls 120.1 2005/07/02 00:41:16 appldev ship $ */
/*#
 * This is the private interface to the JTF Escalation Management.
 * This Interface is used to Create / Update / Delete Contacts for
 * the escalations.
 *
 * @rep:scope private
 * @rep:product JTF
 * @rep:lifecycle active
 * @rep:displayname Escalation Management
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY JTA_ESCALATION
*/

   g_pkg_name   constant VARCHAR2(30) := 'JTF_ESCALATION_CONTACTS_PVT';

/*#
* Creates Escalation Contacts
*
* @param p_api_version the standard API version number
* @param p_init_msg_list the standard API flag allows API callers to request
* that the API does the initialization of the message list on their behalf.
* By default, the message list will not be initialized.
* @param p_commit the standard API flag is used by API callers to ask
* the API to commit on their behalf after performing its function
* By default, the commit will not be performed.
* @param p_escalation_id the Escalation ID for which the contact is created
* @param p_escalation_number the Escalation Number for which the contact is created
* @param p_contact_id the contact ID of the Escalation Contact to be created
* @param p_contact_type_code the contact Type Code of the Escalation Contact to be created
* @param p_escalation_notify_flag the flag that checks if the notify option is checked
* @param p_escalation_requester_flag the flag that determines if the contact is requester for Escalation
* @param x_escalation_contact_id the parameter that returns the Escalation Contact ID for the created Escalation Contact
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
* @rep:scope private
* @rep:lifecycle active
* @rep:displayname Create Escalation Contacts
* @rep:compatibility S
*/
   PROCEDURE create_escalation_contacts (
      p_api_version                 	IN       NUMBER,
      p_init_msg_list               	IN       VARCHAR2 DEFAULT fnd_api.g_false,
      p_commit                      	IN       VARCHAR2 DEFAULT fnd_api.g_false,
      p_escalation_id                   IN       NUMBER DEFAULT NULL,
      p_escalation_number               IN       VARCHAR2 DEFAULT NULL,
      p_contact_id                  	IN       NUMBER,
      p_contact_type_code           	IN       VARCHAR2 DEFAULT NULL,
      p_escalation_notify_flag      	IN       VARCHAR2 DEFAULT NULL,
      p_escalation_requester_flag   	IN       VARCHAR2 DEFAULT NULL,
      x_escalation_contact_id           OUT NOCOPY     NUMBER,
      x_return_status               	OUT NOCOPY     VARCHAR2,
      x_msg_data                    	OUT NOCOPY     VARCHAR2,
      x_msg_count                   	OUT NOCOPY     NUMBER,
      p_attribute1              	IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
      p_attribute2              	IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
      p_attribute3              	IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
      p_attribute4              	IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
      p_attribute5              	IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
      p_attribute6              	IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
      p_attribute7              	IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
      p_attribute8              	IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
      p_attribute9              	IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
      p_attribute10             	IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
      p_attribute11             	IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
      p_attribute12             	IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
      p_attribute13             	IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
      p_attribute14             	IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
      p_attribute15             	IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
      p_attribute_category      	IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char
   );


/*#
* Updates Escalation Contacts
*
* @param p_api_version the standard API version number
* @param p_init_msg_list the standard API flag allows API callers to request
* that the API does the initialization of the message list on their behalf.
* By default, the message list will not be initialized.
* @param p_commit the standard API flag is used by API callers to ask
* the API to commit on their behalf after performing its function
* By default, the commit will not be performed.
* @param p_object_version_number the object version number of the escalation contact record
* @param p_escalation_contact_id the Escalation Contact ID for the Escalation Contact
* @param p_contact_id the contact ID of the Escalation Contact to be created
* @param p_contact_type_code the contact Type Code of the Escalation Contact to be created
* @param p_escalation_notify_flag the flag that checks if the notify option is checked
* @param p_escalation_requester_flag the flag that determines if the contact is requester for Escalation
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
* @rep:scope private
* @rep:lifecycle active
* @rep:displayname Update Escalation Contacts
* @rep:compatibility S
*/
   PROCEDURE update_escalation_contacts (
      p_api_version                 IN       NUMBER,
      p_init_msg_list               IN       VARCHAR2 DEFAULT fnd_api.g_false,
      p_commit                      IN       VARCHAR2 DEFAULT fnd_api.g_false,
      p_object_version_number       IN  OUT NOCOPY VARCHAR2 ,
      p_escalation_contact_id       IN       NUMBER DEFAULT NULL,
      p_contact_id                  IN       NUMBER,
      p_contact_type_code           IN       VARCHAR2 DEFAULT NULL,
      p_escalation_notify_flag      IN       VARCHAR2 DEFAULT NULL,
      p_escalation_requester_flag   IN       VARCHAR2 DEFAULT NULL,
      x_return_status               OUT NOCOPY     VARCHAR2,
      x_msg_data                    OUT NOCOPY     VARCHAR2,
      x_msg_count                   OUT NOCOPY     NUMBER,
      p_attribute1              	IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
      p_attribute2              	IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
      p_attribute3              	IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
      p_attribute4              	IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
      p_attribute5              	IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
      p_attribute6              	IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
      p_attribute7              	IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
      p_attribute8              	IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
      p_attribute9              	IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
      p_attribute10             	IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
      p_attribute11             	IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
      p_attribute12             	IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
      p_attribute13             	IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
      p_attribute14             	IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
      p_attribute15             	IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
      p_attribute_category      	IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char
   );

/*#
* Deletes Escalation Contacts
*
* @param p_api_version the standard API version number
* @param p_init_msg_list the standard API flag allows API callers to request
* that the API does the initialization of the message list on their behalf.
* By default, the message list will not be initialized.
* @param p_commit the standard API flag is used by API callers to ask
* the API to commit on their behalf after performing its function
* By default, the commit will not be performed.
* @param p_object_version_number the object version number of the escalation contact record
* @param p_escalation_contact_id the Escalation Contact ID for the Escalation Contact
* @param x_return_status the parameter that returns the result of all the operations performed.
* by the API and must have one of the following values:
*   <LI><Code>FND_API.G_RET_STS_SUCCESS</Code>
*   <LI><Code>FND_API.G_RET_STS_ERROR</Code>
*   <LI><Code>FND_API.G_RET_STS_UNEXP_ERROR</Code>
* @param x_msg_data the parameter that returns the FND Message in encoded format.
* @param x_msg_count the parameter that returns the number of messages in the FND message list.
* @rep:scope private
* @rep:lifecycle active
* @rep:displayname Delete Escalation Contacts
* @rep:compatibility S
*/
   PROCEDURE delete_escalation_contacts (
      p_api_version             IN       NUMBER,
      p_init_msg_list           IN       VARCHAR2 DEFAULT fnd_api.g_false,
      p_commit                  IN       VARCHAR2 DEFAULT fnd_api.g_false,
      p_object_version_number   IN       NUMBER,
      p_escalation_contact_id   IN       NUMBER,
      x_return_status           OUT NOCOPY     VARCHAR2,
      x_msg_data                OUT NOCOPY     VARCHAR2,
      x_msg_count               OUT NOCOPY     NUMBER
   ) ;


END;

 

/
