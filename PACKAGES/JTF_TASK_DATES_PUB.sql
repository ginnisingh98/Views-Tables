--------------------------------------------------------
--  DDL for Package JTF_TASK_DATES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_TASK_DATES_PUB" AUTHID CURRENT_USER AS
/* $Header: jtfptkds.pls 120.2 2006/09/29 22:23:27 twan ship $ */
/*#
 * This is the public package to validate, crete, update, and delete task dates. *
 * @rep:scope internal
 * @rep:product CAC
 * @rep:lifecycle active
 * @rep:displayname Task Date
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY CAC_CAL_TASK
 */


   TYPE task_dates_rec IS RECORD (
      task_date_id                  NUMBER,
      task_id                       NUMBER,
      date_type_id                  NUMBER,
      object_version_number         NUMBER,
      date_value                    DATE,
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
      attribute_category            VARCHAR2(30)
   );

   p_task_dates_rec task_dates_rec ;

/*#
 * Task date creation API.
 *
 * @param p_api_version the standard API version number
 * @param p_init_msg_list the standard API flag allows API callers to request
 * that the API does the initialization of the message list on their behalf.
 * By default, the message list will not be initialized.
 * @param p_commit the standard API flag is used by API callers to ask
 * the API to commit on their behalf after performing its function
 * By default, the commit will not be performed.
 * @param p_task_number the task number for dates creation
 * @param p_task_id the task id for dates creation
 * @param p_date_type_id the date type id for date creation
 * @param p_date_type_name the date type name for date creation
 * @param p_date_value the date value for date creation
 * @param x_return_status returns the result of all the operations performed
 * by the API and must have one of the following values:
 *   <LI><Code>FND_API.G_RET_STS_SUCCESS</Code>
 *   <LI><Code>FND_API.G_RET_STS_ERROR</Code>
 *   <LI><Code>FND_API.G_RET_STS_UNEXP_ERROR</Code>
 * @param x_msg_count returns the number of messages in the API message list
 * @param x_msg_data returns the message in an encoded format if
 * <code>x_msg_count</code> returns number one.
 * @param x_task_date_id returns the results of all the task dates created
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
 * @paraminfo {@rep:precision 6000}
 * @rep:scope internal
 * @rep:lifecycle active
 * @rep:displayname Create Task Date
 * @rep:compatibility S
 */

   PROCEDURE create_task_dates (
      p_api_version      IN       NUMBER,
      p_init_msg_list    IN       VARCHAR2 DEFAULT fnd_api.g_false,
      p_commit           IN       VARCHAR2 DEFAULT fnd_api.g_false,
      p_task_number      IN       VARCHAR2 DEFAULT NULL,
      p_task_id          IN       VARCHAR2 DEFAULT NULL,
      p_date_type_id     IN       VARCHAR2 DEFAULT NULL,
      p_date_type_name   IN       VARCHAR2 DEFAULT NULL,
      p_date_value       IN       DATE,
      x_return_status    OUT NOCOPY      VARCHAR2,
      x_msg_count        OUT NOCOPY      NUMBER,
      x_msg_data         OUT NOCOPY      VARCHAR2,
      x_task_date_id     OUT NOCOPY      NUMBER,
        p_attribute1              IN       VARCHAR2 DEFAULT null ,
        p_attribute2              IN       VARCHAR2 DEFAULT null ,
        p_attribute3              IN       VARCHAR2 DEFAULT null ,
        p_attribute4              IN       VARCHAR2 DEFAULT null ,
        p_attribute5              IN       VARCHAR2 DEFAULT null ,
        p_attribute6              IN       VARCHAR2 DEFAULT null ,
        p_attribute7              IN       VARCHAR2 DEFAULT null ,
        p_attribute8              IN       VARCHAR2 DEFAULT null ,
        p_attribute9              IN       VARCHAR2 DEFAULT null ,
        p_attribute10             IN       VARCHAR2 DEFAULT null ,
        p_attribute11             IN       VARCHAR2 DEFAULT null ,
        p_attribute12             IN       VARCHAR2 DEFAULT null ,
        p_attribute13             IN       VARCHAR2 DEFAULT null ,
        p_attribute14             IN       VARCHAR2 DEFAULT null ,
        p_attribute15             IN       VARCHAR2 DEFAULT null ,
        p_attribute_category      IN       VARCHAR2 DEFAULT null

   );


/*#
 * Task date update API.
 *
 * @param p_api_version the standard API version number
 * @param p_init_msg_list the standard API flag allows API callers to request
 * that the API does the initialization of the message list on their behalf.
 * By default, the message list will not be initialized.
 * @param p_commit the standard API flag is used by API callers to ask
 * the API to commit on their behalf after performing its function
 * By default, the commit will not be performed.
 * @param p_object_version_number the object version number for dates update
 * @param p_task_date_id the task date id for dates update
 * @param p_date_type_name the date type name for date update
 * @param p_date_type_id the date type id for date update
 * @param p_date_value the date value for date update
 * @param x_return_status returns the result of all the operations performed
 * by the API and must have one of the following values:
 *   <LI><Code>FND_API.G_RET_STS_SUCCESS</Code>
 *   <LI><Code>FND_API.G_RET_STS_ERROR</Code>
 *   <LI><Code>FND_API.G_RET_STS_UNEXP_ERROR</Code>
 * @param x_msg_count returns the number of messages in the API message list
 * <code>x_msg_count</code> returns number one.
 * @param x_msg_data returns the message in an encoded format if
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
 * @paraminfo {@rep:precision 6000}
 * @rep:scope internal
 * @rep:lifecycle active
 * @rep:displayname Update Task Date
 * @rep:compatibility S
 */
    PROCEDURE update_task_dates (
        p_api_version             IN       NUMBER,
        p_init_msg_list           IN       VARCHAR2 DEFAULT fnd_api.g_false,
        p_commit                  IN       VARCHAR2 DEFAULT fnd_api.g_false,
        p_object_version_number   IN     OUT NOCOPY NUMBER ,
        p_task_date_id            IN       NUMBER,
        p_date_type_name          IN       VARCHAR2 DEFAULT fnd_api.g_miss_char,
        p_date_type_id            IN       NUMBER DEFAULT fnd_api.g_miss_num,
        p_date_value              IN       DATE DEFAULT fnd_api.g_miss_date,
        x_return_status           OUT NOCOPY      VARCHAR2,
        x_msg_count               OUT NOCOPY      NUMBER,
        x_msg_data                OUT NOCOPY      VARCHAR2,
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
        p_attribute_category      IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char
    );

/*#
 * Task date row locking API.
 *
 * @param p_api_version the standard API version number
 * @param p_init_msg_list the standard API flag allows API callers to request
 * that the API does the initialization of the message list on their behalf.
 * By default, the message list will not be initialized.
 * @param p_commit the standard API flag is used by API callers to ask
 * the API to commit on their behalf after performing its function
 * By default, the commit will not be performed.
 * @param p_task_date_id the task date id being locked
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
 * @rep:displayname Lock Task Date
 * @rep:compatibility S
 */
   PROCEDURE lock_task_dates (
      p_api_version       IN       NUMBER,
      p_init_msg_list     IN       VARCHAR2 DEFAULT fnd_api.g_false,
      p_commit            IN       VARCHAR2 DEFAULT fnd_api.g_false,
      p_task_date_id     IN       NUMBER,
      p_object_version_number   IN NUMBER ,
      x_return_status     OUT NOCOPY      VARCHAR2,
      x_msg_data          OUT NOCOPY      VARCHAR2,
      x_msg_count         OUT NOCOPY      NUMBER
   );

/*#
 * Task date delete API.
 *
 * @param p_api_version the standard API version number
 * @param p_init_msg_list the standard API flag allows API callers to request
 * that the API does the initialization of the message list on their behalf.
 * By default, the message list will not be initialized.
 * @param p_commit the standard API flag is used by API callers to ask
 * the API to commit on their behalf after performing its function
 * By default, the commit will not be performed.
 * @param p_object_version_number the object version number for delete
 * @param p_task_date_id the task date id being deleted.
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
 * @rep:displayname Delete Task Date
 * @rep:compatibility S
 */

   PROCEDURE delete_task_dates (
      p_api_version     IN       NUMBER,
      p_init_msg_list   IN       VARCHAR2 DEFAULT fnd_api.g_false,
      p_commit          IN       VARCHAR2 DEFAULT fnd_api.g_false,
      p_object_version_number   IN     NUMBER ,
      p_task_date_id    IN       NUMBER DEFAULT NULL,
      x_return_status   OUT NOCOPY      VARCHAR2,
      x_msg_data        OUT NOCOPY      VARCHAR2,
      x_msg_count       OUT NOCOPY      NUMBER
   );
END;

 

/
