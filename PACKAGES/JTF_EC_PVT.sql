--------------------------------------------------------
--  DDL for Package JTF_EC_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_EC_PVT" AUTHID CURRENT_USER AS
/* $Header: jtfecmas.pls 120.1 2005/07/02 00:41:26 appldev ship $ */
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

   g_pkg_name          CONSTANT VARCHAR2(30) := 'JTF_EC_PVT';
   g_user              CONSTANT VARCHAR2(30) := fnd_global.user_id;
   g_false             CONSTANT VARCHAR2(30) := fnd_api.g_false;
   g_true              CONSTANT VARCHAR2(30) := fnd_api.g_true;

/*#
* Creates an Escalation.  After successful creation, triggers the BES for
* create event.
*
* @param p_api_version the standard API version number
* @param p_init_msg_list the standard API flag allows API callers to request
* that the API does the initialization of the message list on their behalf.
* By default, the message list will not be initialized.
* @param p_commit the standard API flag is used by API callers to ask
* the API to commit on their behalf after performing its function
* By default, the commit will not be performed.
* @param p_esc_id the escalation ID
* @param p_escalation_name the escalation Name
* @param p_description the escalation description
* @param p_escalation_status_name the escalation status name
* @param p_escalation_status_id the escalation status id
* @param p_escalation_priority_name the escalation priority name
* @param p_escalation_priority_id the escalation priority id
* @param p_open_date the date when escalation was opened
* @param p_close_date the escalation when escalation gets closed
* @param p_escalation_owner_type_code the owner type for the escalation
* @param p_escalation_owner_id the owner id for the escalation
* @param p_owner_territory_id the owner id for the escalation
* @param p_assigned_by_name the name of the assigner
* @param p_assigned_by_id the id of the assigner
* @param p_customer_number the customer number
* @param p_customer_id the customer id
* @param p_cust_account_number the customer account number
* @param p_cust_account_id the customer account id
* @param p_address_id the customer address id
* @param p_address_number the customer address number
* @param p_target_date the target date for the escalation
* @param p_reason_code the reason code for the reason of escalation
* @param p_private_flag the private flag indicator
* @param p_publish_flag the publish flag indicator
* @param p_workflow_process_id the workflow process id for notifications of the created escalation
* @param p_escalation_level the escalation level
* @param x_return_status the parameter that returns the result of all the operations performed.
* by the API and must have one of the following values:
*   <LI><Code>FND_API.G_RET_STS_SUCCESS</Code>
*   <LI><Code>FND_API.G_RET_STS_ERROR</Code>
*   <LI><Code>FND_API.G_RET_STS_UNEXP_ERROR</Code>
* @param x_msg_count the parameter that returns the number of messages in the FND message list.
* @param x_msg_data the parameter that returns the FND Message in encoded format.
* @param x_escalation_id the parameter that returns the Escalation ID for the created Escalation
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
* @rep:displayname Create Escalation
* @rep:compatibility S
*/
   PROCEDURE create_escalation (
      p_api_version                IN       NUMBER,
      p_init_msg_list              IN       VARCHAR2 DEFAULT fnd_api.g_false,
      p_commit                     IN       VARCHAR2 DEFAULT fnd_api.g_false,
      p_esc_id			   IN       NUMBER DEFAULT NULL,
      p_escalation_name            IN       VARCHAR2,
      p_description                IN       VARCHAR2 DEFAULT NULL,
      p_escalation_status_name     IN       VARCHAR2 DEFAULT NULL,
      p_escalation_status_id       IN       NUMBER DEFAULT NULL,
      p_escalation_priority_name   IN       VARCHAR2 DEFAULT NULL,
      p_escalation_priority_id     IN       NUMBER DEFAULT NULL,
      p_open_date                  IN       DATE DEFAULT NULL,
      p_close_date                 IN       DATE DEFAULT NULL,
      p_escalation_owner_type_code IN       VARCHAR2 DEFAULT NULL,
      p_escalation_owner_id        IN       NUMBER DEFAULT NULL,
      p_owner_territory_id         IN       NUMBER DEFAULT NULL,
      p_assigned_by_name           IN       VARCHAR2 DEFAULT NULL,
      p_assigned_by_id             IN       NUMBER DEFAULT NULL,
      p_customer_number            IN       VARCHAR2 DEFAULT NULL,
      p_customer_id                IN       NUMBER DEFAULT NULL,
      p_cust_account_number        IN       VARCHAR2 DEFAULT NULL,
      p_cust_account_id            IN       NUMBER DEFAULT NULL,
      p_address_id                 IN       NUMBER DEFAULT NULL,
      p_address_number             IN       VARCHAR2 DEFAULT NULL,
      p_target_date                IN       DATE DEFAULT NULL,
      p_reason_code                IN       VARCHAR2 DEFAULT NULL,
      p_private_flag               IN       VARCHAR2 DEFAULT NULL,
      p_publish_flag               IN       VARCHAR2 DEFAULT NULL,
      p_workflow_process_id        IN       NUMBER DEFAULT NULL,
      p_escalation_level           IN       VARCHAR2 DEFAULT NULL,
      x_return_status              OUT NOCOPY     VARCHAR2,
      x_msg_count                  OUT NOCOPY     NUMBER,
      x_msg_data                   OUT NOCOPY     VARCHAR2,
      x_escalation_id              OUT NOCOPY     NUMBER,
      p_attribute1                 IN       VARCHAR2 DEFAULT null ,
      p_attribute2                 IN       VARCHAR2 DEFAULT null ,
      p_attribute3                 IN       VARCHAR2 DEFAULT null ,
      p_attribute4                 IN       VARCHAR2 DEFAULT null ,
      p_attribute5                 IN       VARCHAR2 DEFAULT null ,
      p_attribute6                 IN       VARCHAR2 DEFAULT null ,
      p_attribute7                 IN       VARCHAR2 DEFAULT null ,
      p_attribute8                 IN       VARCHAR2 DEFAULT null ,
      p_attribute9                 IN       VARCHAR2 DEFAULT null ,
      p_attribute10                IN       VARCHAR2 DEFAULT null ,
      p_attribute11                IN       VARCHAR2 DEFAULT null ,
      p_attribute12                IN       VARCHAR2 DEFAULT null ,
      p_attribute13                IN       VARCHAR2 DEFAULT null ,
      p_attribute14                IN       VARCHAR2 DEFAULT null ,
      p_attribute15                IN       VARCHAR2 DEFAULT null ,
      p_attribute_category         IN       VARCHAR2 DEFAULT null

   );

/*#
* Updates an Escalation.  After successful updation, triggers the BES for
* update event.
*
* @param p_api_version the standard API version number
* @param p_init_msg_list the standard API flag allows API callers to request
* that the API does the initialization of the message list on their behalf.
* By default, the message list will not be initialized.
* @param p_commit the standard API flag is used by API callers to ask
* the API to commit on their behalf after performing its function
* By default, the commit will not be performed.
* @param p_object_version_number the object version number of the escalation record
* @param p_escalation_id the escalation id
* @param p_escalation_number the escalation number
* @param p_escalation_name the escalation name
* @param p_description the escalation description
* @param p_escalation_status_name the escalation status name
* @param p_escalation_status_id the escalation status id
* @param p_open_date the date when escalation was opened
* @param p_close_date the escalation when escalation gets closed
* @param p_escalation_priority_name the escalation priority name
* @param p_escalation_priority_id the escalation priority id
* @param p_owner_id the owner id for the escalation
* @param p_escalation_owner_type_code the owner type for the escalation
* @param p_owner_territory_id the owner id for the escalation
* @param p_assigned_by_name the name of the assigner
* @param p_assigned_by_id the id of the assigner
* @param p_customer_number the customer number
* @param p_customer_id the customer id
* @param p_cust_account_number the customer account number
* @param p_cust_account_id the customer account id
* @param p_address_id the customer address id
* @param p_address_number the customer address number
* @param p_target_date the target date for the escalation
* @param p_reason_code the reason code for the reason of escalation
* @param p_private_flag the private flag indicator
* @param p_publish_flag the publish flag indicator
* @param p_workflow_process_id the workflow process id for notifications of the created escalation
* @param p_escalation_level the escalation level
* @param x_return_status the parameter that returns the result of all the operations performed.
* by the API and must have one of the following values:
*   <LI><Code>FND_API.G_RET_STS_SUCCESS</Code>
*   <LI><Code>FND_API.G_RET_STS_ERROR</Code>
*   <LI><Code>FND_API.G_RET_STS_UNEXP_ERROR</Code>
* @param x_msg_count the parameter that returns the number of messages in the FND message list.
* @param x_msg_data the parameter that returns the FND Message in encoded format.
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
* @rep:displayname Update Escalation
* @rep:compatibility S
*/
   PROCEDURE update_escalation (
      p_api_version                IN       NUMBER,
      p_init_msg_list              IN       VARCHAR2 DEFAULT fnd_api.g_false,
      p_commit                     IN       VARCHAR2 DEFAULT fnd_api.g_false,
      p_object_version_number      IN OUT NOCOPY  NUMBER,
      p_escalation_id              IN       NUMBER DEFAULT fnd_api.g_miss_num,
      p_escalation_number          IN       VARCHAR2 DEFAULT fnd_api.g_miss_char,
      p_escalation_name            IN       VARCHAR2 DEFAULT fnd_api.g_miss_char,
      p_description                IN       VARCHAR2 DEFAULT fnd_api.g_miss_char,
      p_escalation_status_name     IN       VARCHAR2 DEFAULT fnd_api.g_miss_char,
      p_escalation_status_id       IN       NUMBER DEFAULT fnd_api.g_miss_num,
      p_open_date                  in       DATE  DEFAULT fnd_api.g_miss_date,
      p_close_date                 in       DATE  DEFAULT fnd_api.g_miss_date,
      p_escalation_priority_name   IN       VARCHAR2 DEFAULT fnd_api.g_miss_char,
      p_escalation_priority_id     IN       NUMBER DEFAULT fnd_api.g_miss_num,
      p_owner_id                   IN       NUMBER DEFAULT fnd_api.g_miss_num,
      p_escalation_owner_type_code IN       VARCHAR2 DEFAULT fnd_api.g_miss_char,
      p_owner_territory_id         IN       NUMBER DEFAULT fnd_api.g_miss_num,
      p_assigned_by_name           IN       VARCHAR2 DEFAULT fnd_api.g_miss_char,
      p_assigned_by_id             IN       NUMBER DEFAULT fnd_api.g_miss_num,
      p_customer_number            IN       VARCHAR2 DEFAULT fnd_api.g_miss_char,
      p_customer_id                IN       NUMBER DEFAULT fnd_api.g_miss_num,
      p_cust_account_number        IN       VARCHAR2 DEFAULT fnd_api.g_miss_char,
      p_cust_account_id            IN       NUMBER DEFAULT fnd_api.g_miss_num,
      p_address_id                 IN       NUMBER DEFAULT fnd_api.g_miss_num,
      p_address_number             IN       VARCHAR2 DEFAULT fnd_api.g_miss_char,
      p_target_date                IN       DATE DEFAULT fnd_api.g_miss_date,
/*      p_timezone_id                IN       NUMBER DEFAULT fnd_api.g_miss_num,
      p_timezone_name              IN       VARCHAR2 DEFAULT fnd_api.g_miss_char,
*/    p_reason_code                IN       VARCHAR2 DEFAULT fnd_api.g_miss_char,
      p_private_flag               IN       VARCHAR2 DEFAULT fnd_api.g_miss_char,
      p_publish_flag               IN       VARCHAR2 DEFAULT fnd_api.g_miss_char,
      p_workflow_process_id        IN       NUMBER DEFAULT fnd_api.g_miss_num,
      p_escalation_level           IN       VARCHAR2 DEFAULT fnd_api.g_miss_char,
      x_return_status              OUT NOCOPY     VARCHAR2,
      x_msg_count                  OUT NOCOPY     NUMBER,
      x_msg_data                   OUT NOCOPY     VARCHAR2,
      p_attribute1                 IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
      p_attribute2                 IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
      p_attribute3                 IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
      p_attribute4                 IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
      p_attribute5                 IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
      p_attribute6                 IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
      p_attribute7                 IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
      p_attribute8                 IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
      p_attribute9                 IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
      p_attribute10                IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
      p_attribute11                IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
      p_attribute12                IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
      p_attribute13                IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
      p_attribute14                IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
      p_attribute15                IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
      p_attribute_category         IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char
   );

/*#
* Deletes an Escalation.  After successful deletion, triggers the BES for
* delete event.
*
* @param p_api_version the standard API version number
* @param p_init_msg_list the standard API flag allows API callers to request
* that the API does the initialization of the message list on their behalf.
* By default, the message list will not be initialized.
* @param p_commit the standard API flag is used by API callers to ask
* the API to commit on their behalf after performing its function
* By default, the commit will not be performed.
* @param p_object_version_number the object version number of the escalation record
* @param p_escalation_id the escalation id
* @param p_escalation_number the escalation number
* @param x_return_status the parameter that returns the result of all the operations performed.
* by the API and must have one of the following values:
*   <LI><Code>FND_API.G_RET_STS_SUCCESS</Code>
*   <LI><Code>FND_API.G_RET_STS_ERROR</Code>
*   <LI><Code>FND_API.G_RET_STS_UNEXP_ERROR</Code>
* @param x_msg_count the parameter that returns the number of messages in the FND message list.
* @param x_msg_data the parameter that returns the FND Message in encoded format.
* @rep:scope private
* @rep:lifecycle active
* @rep:displayname Delete Escalation
* @rep:compatibility S
*/
    PROCEDURE delete_escalation (
        p_api_version             IN       NUMBER,
        p_init_msg_list           IN       VARCHAR2 DEFAULT fnd_api.g_false,
        p_commit                  IN       VARCHAR2 DEFAULT fnd_api.g_false,
        p_object_version_number   IN       NUMBER ,
        p_escalation_id           IN       NUMBER DEFAULT NULL,
        p_escalation_number       IN       VARCHAR2 DEFAULT NULL,
        x_return_status           OUT NOCOPY     VARCHAR2,
        x_msg_count               OUT NOCOPY     NUMBER,
        x_msg_data                OUT NOCOPY     VARCHAR2
    );

--Created for BES enh 2660883

TYPE Esc_rec_type IS RECORD (
	ESCALATION_ID		JTF_TASKS_B.TASK_ID %TYPE := FND_API.G_MISS_NUM,
	ESCALATION_LEVEL	JTF_TASKS_B.ESCALATION_LEVEL%TYPE := FND_API.G_MISS_CHAR,
	TASK_AUDIT_ID		JTF_TASK_AUDITS_B.TASK_AUDIT_ID%TYPE := FND_API.G_MISS_NUM
	);

END;

 

/
