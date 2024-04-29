--------------------------------------------------------
--  DDL for Package JTF_TASK_CONTACTS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_TASK_CONTACTS_PUB" AUTHID CURRENT_USER AS
/* $Header: jtfptkcs.pls 120.2 2006/06/26 07:31:16 sbarat ship $ */
/*#
 * This is the public package to validate, crete, update, and delete task contacts.
 *
 * @rep:scope internal
 * @rep:product CAC
 * @rep:lifecycle active
 * @rep:displayname Task Contact
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY CAC_CAL_TASK
 */

   g_pkg_name   VARCHAR2(30) := 'JTF_TASK_CONTACTS_PUB';

/*#
 * Task contacts creation API.
 *
 * @param p_api_version the standard API version number
 * @param p_init_msg_list the standard API flag allows API callers to request
 * that the API does the initialization of the message list on their behalf.
 * By default, the message list will not be initialized.
 * @param p_commit the standard API flag is used by API callers to ask
 * the API to commit on their behalf after performing its function
 * By default, the commit will not be performed.
 * @param p_task_id the task id for contact creation
 * @param p_task_number the task number for contact creation
 * @param p_contact_id the contact id for contact creation
 * @param p_contact_type_code the contact type code for contact creation
 * @param p_escalation_notify_flag the escalation notify flag to be applied
 * @param p_escalation_requester_flag the escalation requester flag to be applied
 * @param x_task_contact_id the task contact id being created
 * @param x_return_status returns the result of all the operations performed
 * by the API and must have one of the following values:
 *   <LI><Code>FND_API.G_RET_STS_SUCCESS</Code>
 *   <LI><Code>FND_API.G_RET_STS_ERROR</Code>
 *   <LI><Code>FND_API.G_RET_STS_UNEXP_ERROR</Code>
 * @param x_msg_data returns the message in an encoded format if
 * <code>x_msg_count</code> returns number one.
 * @param x_msg_count returns the number of messages in the API message list
 * @param p_attribute1 attribute1 for flexfield
 * @param p_attribute2 attribute2 for flexfield
 * @param p_attribute3 attribute3 for flexfield
 * @param p_attribute4 attribute4 for flexfield
 * @param p_attribute5 attribute5 for flexfield
 * @param p_attribute6 attribute6 for flexfield
 * @param p_attribute7 attribute7 for flexfield
 * @param p_attribute8 attribute8 for flexfield
 * @param p_attribute9 attribute9 for flexfield
 * @param p_attribute10 attribute10 for flexfield
 * @param p_attribute11 attribute11 for flexfield
 * @param p_attribute12 attribute12 for flexfield
 * @param p_attribute13 attribute13 for flexfield
 * @param p_attribute14 attribute14 for flexfield
 * @param p_attribute15 attribute15 for flexfield
 * @param p_attribute_category attribute category
 * @param p_primary_flag the primary flag to be applied
 * @paraminfo {@rep:precision 6000}
 * @rep:scope internal
 * @rep:lifecycle active
 * @rep:displayname Create Task Contact
 * @rep:compatibility S
 */
   PROCEDURE create_task_contacts (
      p_api_version                 IN       NUMBER,
      p_init_msg_list               IN       VARCHAR2 DEFAULT fnd_api.g_false,
      p_commit                      IN       VARCHAR2 DEFAULT fnd_api.g_false,
      p_task_id                     IN       NUMBER DEFAULT NULL,
      p_task_number                 IN       VARCHAR2 DEFAULT NULL,
      p_contact_id                  IN       NUMBER,
      p_contact_type_code           IN       VARCHAR2 DEFAULT NULL,
      p_escalation_notify_flag      IN       VARCHAR2 DEFAULT NULL,
      p_escalation_requester_flag   IN       VARCHAR2 DEFAULT NULL,
      x_task_contact_id             OUT NOCOPY     NUMBER,
      x_return_status               OUT NOCOPY     VARCHAR2,
      x_msg_data                    OUT NOCOPY     VARCHAR2,
      x_msg_count                   OUT NOCOPY     NUMBER ,
      p_attribute1                  IN       VARCHAR2 DEFAULT null ,
      p_attribute2                  IN       VARCHAR2 DEFAULT null ,
      p_attribute3                  IN       VARCHAR2 DEFAULT null ,
      p_attribute4                  IN       VARCHAR2 DEFAULT null ,
      p_attribute5                  IN       VARCHAR2 DEFAULT null ,
      p_attribute6                  IN       VARCHAR2 DEFAULT null ,
      p_attribute7                  IN       VARCHAR2 DEFAULT null ,
      p_attribute8                  IN       VARCHAR2 DEFAULT null ,
      p_attribute9                  IN       VARCHAR2 DEFAULT null ,
      p_attribute10                 IN       VARCHAR2 DEFAULT null ,
      p_attribute11                 IN       VARCHAR2 DEFAULT null ,
      p_attribute12                 IN       VARCHAR2 DEFAULT null ,
      p_attribute13                 IN       VARCHAR2 DEFAULT null ,
      p_attribute14                 IN       VARCHAR2 DEFAULT null ,
      p_attribute15                 IN       VARCHAR2 DEFAULT null ,
      p_attribute_category          IN       VARCHAR2 DEFAULT null ,
      p_primary_flag                IN       varchar2 default null
   );

/*#
 * Task contact row locking API.
 *
 * @param p_api_version the standard API version number
 * @param p_init_msg_list the standard API flag allows API callers to request
 * that the API does the initialization of the message list on their behalf.
 * By default, the message list will not be initialized.
 * @param p_commit the standard API flag is used by API callers to ask
 * the API to commit on their behalf after performing its function
 * By default, the commit will not be performed.
 * @param p_task_contact_id the task contact id being locked
 * @param p_object_version_number the object version number for lock
 * @param x_return_status returns the result of all the operations performed
 * by the API and must have one of the following values:
 *   <LI><Code>FND_API.G_RET_STS_SUCCESS</Code>
 *   <LI><Code>FND_API.G_RET_STS_ERROR</Code>
 *   <LI><Code>FND_API.G_RET_STS_UNEXP_ERROR</Code>
 * @param x_msg_data returns the message in an encoded format if
 * <code>x_msg_count</code> returns number one.
 * @param x_msg_count returns the number of messages in the API message list
 * @paraminfo {@rep:precision 6000}
 * @rep:scope private
 * @rep:lifecycle active
 * @rep:displayname Lock Task Contact
 * @rep:compatibility S
 */
   PROCEDURE lock_task_contacts (
      p_api_version             IN       NUMBER,
      p_init_msg_list           IN       VARCHAR2 DEFAULT fnd_api.g_false,
      p_commit                  IN       VARCHAR2 DEFAULT fnd_api.g_false,
      p_task_contact_id         IN       NUMBER,
      p_object_version_number   IN       NUMBER,
      x_return_status           OUT NOCOPY     VARCHAR2,
      x_msg_data                OUT NOCOPY     VARCHAR2,
      x_msg_count               OUT NOCOPY     NUMBER
   );


/*#
 * Task contacts update API.
 *
 * @param p_api_version the standard API version number
 * @param p_init_msg_list the standard API flag allows API callers to request
 * that the API does the initialization of the message list on their behalf.
 * By default, the message list will not be initialized.
 * @param p_commit the standard API flag is used by API callers to ask
 * the API to commit on their behalf after performing its function
 * By default, the commit will not be performed.
 * @param p_object_version_number the object version number for contact update
 * @param p_task_contact_id the task contact id for contact update
 * @param p_contact_id the contact id for contact update
 * @param p_contact_type_code the contact type code for contact update
 * @param p_escalation_notify_flag the escalation notify flag to be applied
 * @param p_escalation_requester_flag the escalation requester flag to be applied
 * @param x_return_status returns the result of all the operations performed
 * by the API and must have one of the following values:
 *   <LI><Code>FND_API.G_RET_STS_SUCCESS</Code>
 *   <LI><Code>FND_API.G_RET_STS_ERROR</Code>
 *   <LI><Code>FND_API.G_RET_STS_UNEXP_ERROR</Code>
 * @param x_msg_data returns the message in an encoded format if
 * <code>x_msg_count</code> returns number one.
 * @param x_msg_count returns the number of messages in the API message list
 * @param p_attribute1 attribute1 for flexfield
 * @param p_attribute2 attribute2 for flexfield
 * @param p_attribute3 attribute3 for flexfield
 * @param p_attribute4 attribute4 for flexfield
 * @param p_attribute5 attribute5 for flexfield
 * @param p_attribute6 attribute6 for flexfield
 * @param p_attribute7 attribute7 for flexfield
 * @param p_attribute8 attribute8 for flexfield
 * @param p_attribute9 attribute9 for flexfield
 * @param p_attribute10 attribute10 for flexfield
 * @param p_attribute11 attribute11 for flexfield
 * @param p_attribute12 attribute12 for flexfield
 * @param p_attribute13 attribute13 for flexfield
 * @param p_attribute14 attribute14 for flexfield
 * @param p_attribute15 attribute15 for flexfield
 * @param p_attribute_category attribute category
 * @param p_primary_flag the primary flag to be applied
 * @paraminfo {@rep:precision 6000}
 * @rep:scope internal
 * @rep:lifecycle active
 * @rep:displayname Update Task Contact
 * @rep:compatibility S
 */
   PROCEDURE update_task_contacts (
      p_api_version                 IN       NUMBER,
      p_init_msg_list               IN       VARCHAR2 DEFAULT fnd_api.g_false,
      p_commit                      IN       VARCHAR2 DEFAULT fnd_api.g_false,
      p_object_version_number       IN       OUT NOCOPY   NUMBER,
      p_task_contact_id             IN       NUMBER,
      p_contact_id                  IN       NUMBER default fnd_api.g_miss_num,
      p_contact_type_code           IN       VARCHAR2 DEFAULT fnd_api.g_miss_char,
      p_escalation_notify_flag      IN       VARCHAR2 DEFAULT fnd_api.g_miss_char,
      p_escalation_requester_flag   IN       VARCHAR2 DEFAULT fnd_api.g_miss_char,
      x_return_status               OUT NOCOPY     VARCHAR2,
      x_msg_data                    OUT NOCOPY     VARCHAR2,
      x_msg_count                   OUT NOCOPY     NUMBER ,
      p_attribute1                  IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
      p_attribute2                  IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
      p_attribute3                  IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
      p_attribute4                  IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
      p_attribute5                  IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
      p_attribute6                  IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
      p_attribute7                  IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
      p_attribute8                  IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
      p_attribute9                  IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
      p_attribute10                 IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
      p_attribute11                 IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
      p_attribute12                 IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
      p_attribute13                 IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
      p_attribute14                 IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
      p_attribute15                 IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
      p_attribute_category          IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
      p_primary_flag                IN       VARCHAR2 default jtf_task_utl.g_miss_char
   );

/*#
 * Task contacts delete API.
 *
 * @param p_api_version the standard API version number
 * @param p_init_msg_list the standard API flag allows API callers to request
 * that the API does the initialization of the message list on their behalf.
 * By default, the message list will not be initialized.
 * @param p_commit the standard API flag is used by API callers to ask
 * the API to commit on their behalf after performing its function
 * By default, the commit will not be performed.
 * @param p_object_version_number the object version number for delete
 * @param p_task_contact_id the task contact id being deleted
 * @param x_return_status returns the result of all the operations performed
 * by the API and must have one of the following values:
 *   <LI><Code>FND_API.G_RET_STS_SUCCESS</Code>
 *   <LI><Code>FND_API.G_RET_STS_ERROR</Code>
 *   <LI><Code>FND_API.G_RET_STS_UNEXP_ERROR</Code>
 * @param x_msg_count returns the number of messages in the API message list
 * @param x_msg_data returns the message in an encoded format if
 * <code>x_msg_count</code> returns number one.
 * @param p_delete_cascade the delete cascade
 * @paraminfo {@rep:precision 6000}
 * @rep:scope internal
 * @rep:lifecycle active
 * @rep:displayname Delete Task Contact
 * @rep:compatibility S
 */
   PROCEDURE delete_task_contacts (
      p_api_version             IN       NUMBER,
      p_init_msg_list           IN       VARCHAR2 DEFAULT fnd_api.g_false,
      p_commit                  IN       VARCHAR2 DEFAULT fnd_api.g_false,
      p_object_version_number   IN       NUMBER,
      p_task_contact_id         IN       NUMBER,
      x_return_status           OUT NOCOPY     VARCHAR2,
      x_msg_data                OUT NOCOPY     VARCHAR2,
      x_msg_count               OUT NOCOPY     NUMBER,
      p_delete_cascade          IN       VARCHAR2 DEFAULT jtf_task_utl.g_no_char
   );
END;

 

/
