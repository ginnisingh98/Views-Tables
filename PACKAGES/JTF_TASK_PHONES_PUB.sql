--------------------------------------------------------
--  DDL for Package JTF_TASK_PHONES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_TASK_PHONES_PUB" AUTHID CURRENT_USER AS
/* $Header: jtfptkps.pls 120.1 2005/07/02 00:59:54 appldev ship $ */
/*#
 * This is the public package to validate, crete, update, and delete task phones.
 *
 * @rep:scope internal
 * @rep:product CAC
 * @rep:lifecycle active
 * @rep:displayname Task Phone
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY CAC_CAL_TASK
 */


   TYPE task_phones_rec IS RECORD (
      task_phone_id                 NUMBER,
      task_contact_id               NUMBER,
      phone_id                      NUMBER,
      object_version_number         NUMBER,
      attribute1                    VARCHAR2(150),
      attribute2                    VARCHAR2(150),
      attribute3                    VARCHAR2(150),
      attribute4                    VARCHAR2(150),
      attribute5                    VARCHAR2(150),
      attribute6                    VARCHAR2(150),
      attribute7                    VARCHAR2(150),
      attribute8                    VARCHAR2(150),
      attribute9                    VARCHAR2(150),
      attribute10                   VARCHAR2(150),
      attribute11                   VARCHAR2(150),
      attribute12                   VARCHAR2(150),
      attribute13                   VARCHAR2(150),
      attribute14                   VARCHAR2(150),
      attribute15                   VARCHAR2(150),
      attribute_category            VARCHAR2(30),
      owner_table_name              VARCHAR2(30),
      primary_flag                  VARCHAR2(1)
   );

   p_task_phones_rec   task_phones_rec;

/*#
 * Task phones creation API.
 *
 * @param p_api_version the standard API version number
 * @param p_init_msg_list the standard API flag allows API callers to request
 * that the API does the initialization of the message list on their behalf.
 * By default, the message list will not be initialized.
 * @param p_commit the standard API flag is used by API callers to ask
 * the API to commit on their behalf after performing its function
 * By default, the commit will not be performed.
 * @param p_task_contact_id the task contact id for task phone creation
 * @param p_phone_id the phone id for task phone creation
 * @param x_task_phone_id the task phone id being created
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
 * @param p_owner_table_name the owner table name for task phone creation
 * @param p_primary_flag the primary flag for task phone creation
 * @paraminfo {@rep:precision 6000}
 * @rep:scope internal
 * @rep:lifecycle active
 * @rep:displayname Create Task Phone
 * @rep:compatibility S
 */
   PROCEDURE create_task_phones (
      p_api_version          IN       NUMBER,
      p_init_msg_list        IN       VARCHAR2 DEFAULT fnd_api.g_false,
      p_commit               IN       VARCHAR2 DEFAULT fnd_api.g_false,
      p_task_contact_id      IN       NUMBER,
      p_phone_id             IN       NUMBER,
      x_task_phone_id        OUT NOCOPY      NUMBER,
      x_return_status        OUT NOCOPY      VARCHAR2,
      x_msg_data             OUT NOCOPY      VARCHAR2,
      x_msg_count            OUT NOCOPY      NUMBER,
      p_attribute1           IN       VARCHAR2 DEFAULT NULL,
      p_attribute2           IN       VARCHAR2 DEFAULT NULL,
      p_attribute3           IN       VARCHAR2 DEFAULT NULL,
      p_attribute4           IN       VARCHAR2 DEFAULT NULL,
      p_attribute5           IN       VARCHAR2 DEFAULT NULL,
      p_attribute6           IN       VARCHAR2 DEFAULT NULL,
      p_attribute7           IN       VARCHAR2 DEFAULT NULL,
      p_attribute8           IN       VARCHAR2 DEFAULT NULL,
      p_attribute9           IN       VARCHAR2 DEFAULT NULL,
      p_attribute10          IN       VARCHAR2 DEFAULT NULL,
      p_attribute11          IN       VARCHAR2 DEFAULT NULL,
      p_attribute12          IN       VARCHAR2 DEFAULT NULL,
      p_attribute13          IN       VARCHAR2 DEFAULT NULL,
      p_attribute14          IN       VARCHAR2 DEFAULT NULL,
      p_attribute15          IN       VARCHAR2 DEFAULT NULL,
      p_attribute_category   IN       VARCHAR2 DEFAULT NULL,
      p_owner_table_name     IN       VARCHAR2 DEFAULT 'JTF_TASK_CONTACTS',
      p_primary_flag         IN       VARCHAR2 DEFAULT NULL
   );

/*#
 * Task phone row locking API.
 *
 * @param p_api_version the standard API version number
 * @param p_init_msg_list the standard API flag allows API callers to request
 * that the API does the initialization of the message list on their behalf.
 * By default, the message list will not be initialized.
 * @param p_commit the standard API flag is used by API callers to ask
 * the API to commit on their behalf after performing its function
 * By default, the commit will not be performed.
 * @param p_task_phone_id the task phone id being locked
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
 * @rep:displayname Lock Task Phone
 * @rep:compatibility S
 */
   PROCEDURE lock_task_phones (
      p_api_version             IN       NUMBER,
      p_init_msg_list           IN       VARCHAR2 DEFAULT fnd_api.g_false,
      p_commit                  IN       VARCHAR2 DEFAULT fnd_api.g_false,
      p_task_phone_id           IN       NUMBER,
      p_object_version_number   IN       NUMBER,
      x_return_status           OUT NOCOPY      VARCHAR2,
      x_msg_data                OUT NOCOPY      VARCHAR2,
      x_msg_count               OUT NOCOPY      NUMBER
   );


/*#
 * Task phones update API.
 *
 * @param p_api_version the standard API version number
 * @param p_init_msg_list the standard API flag allows API callers to request
 * that the API does the initialization of the message list on their behalf.
 * By default, the message list will not be initialized.
 * @param p_commit the standard API flag is used by API callers to ask
 * the API to commit on their behalf after performing its function
 * By default, the commit will not be performed.
 * @param p_object_version_number the object version number for task phone update
 * @param p_task_phone_id the task phone id for task phone update
 * @param p_phone_id the phone id for task phone update
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
 * @param p_primary_flag the primary flag for task phone update
 * @paraminfo {@rep:precision 6000}
 * @rep:scope internal
 * @rep:lifecycle active
 * @rep:displayname Update Task Phone
 * @rep:compatibility S
 */
   PROCEDURE update_task_phones (
      p_api_version             IN       NUMBER,
      p_init_msg_list           IN       VARCHAR2 DEFAULT fnd_api.g_false,
      p_commit                  IN       VARCHAR2 DEFAULT fnd_api.g_false,
      p_object_version_number   IN OUT NOCOPY   NUMBER,
      p_task_phone_id           IN       NUMBER,
      p_phone_id                IN       NUMBER,
      x_return_status           OUT NOCOPY      VARCHAR2,
      x_msg_data                OUT NOCOPY      VARCHAR2,
      x_msg_count               OUT NOCOPY      NUMBER,
      p_attribute1              IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
      p_attribute2              IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
      p_attribute3              IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
      p_attribute4              IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
      p_attribute5              IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
      p_attribute6              IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
      p_attribute7              IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
      p_attribute8              IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
      p_attribute9              IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
      p_attribute10             IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
      p_attribute11             IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
      p_attribute12             IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
      p_attribute13             IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
      p_attribute14             IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
      p_attribute15             IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
      p_attribute_category      IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
      p_primary_flag            IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char
   );

/*#
 * Task phone delete API.
 *
 * @param p_api_version the standard API version number
 * @param p_init_msg_list the standard API flag allows API callers to request
 * that the API does the initialization of the message list on their behalf.
 * By default, the message list will not be initialized.
 * @param p_commit the standard API flag is used by API callers to ask
 * the API to commit on their behalf after performing its function
 * By default, the commit will not be performed.
 * @param p_object_version_number the object version number for delete
 * @param p_task_phone_id the task phone id being deleted
 * @param x_return_status returns the result of all the operations performed
 * by the API and must have one of the following values:
 *   <LI><Code>FND_API.G_RET_STS_SUCCESS</Code>
 *   <LI><Code>FND_API.G_RET_STS_ERROR</Code>
 *   <LI><Code>FND_API.G_RET_STS_UNEXP_ERROR</Code>
 * @param x_msg_count returns the number of messages in the API message list
 * @param x_msg_data returns the message in an encoded format if
 * <code>x_msg_count</code> returns number one.
 * @paraminfo {@rep:precision 6000}
 * @rep:scope internal
 * @rep:lifecycle active
 * @rep:displayname Delete Task Phone
 * @rep:compatibility S
 */

   PROCEDURE delete_task_phones (
      p_api_version             IN       NUMBER,
      p_init_msg_list           IN       VARCHAR2 DEFAULT fnd_api.g_false,
      p_commit                  IN       VARCHAR2 DEFAULT fnd_api.g_false,
      p_object_version_number   IN       NUMBER,
      p_task_phone_id           IN       NUMBER,
      x_return_status           OUT NOCOPY      VARCHAR2,
      x_msg_data                OUT NOCOPY      VARCHAR2,
      x_msg_count               OUT NOCOPY      NUMBER
   );
END;

 

/
