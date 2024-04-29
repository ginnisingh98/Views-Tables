--------------------------------------------------------
--  DDL for Package JTF_TASK_REFERENCES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_TASK_REFERENCES_PUB" AUTHID CURRENT_USER AS
/* $Header: jtfptkns.pls 120.7 2006/07/27 11:23:08 sbarat ship $ */
/*#
 * A public interface for Tasks that can be used to create, update, and delete task references to an object.
 *
 * @rep:scope public
 * @rep:product CAC
 * @rep:lifecycle active
 * @rep:displayname Task Reference Management
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY CAC_CAL_TASK
 */

type references_rec is  RECORD
(
 TASK_REFERENCE_ID                 NUMBER,
 TASK_ID                           NUMBER,
 OBJECT_TYPE_CODE                  VARCHAR2(30) ,
 OBJECT_NAME                       VARCHAR2(80) ,
 OBJECT_ID                                NUMBER,
 OBJECT_DETAILS                           VARCHAR2(2000) ,
 REFERENCE_CODE                           VARCHAR2(30) ,
 ATTRIBUTE1                               VARCHAR2(150) ,
 ATTRIBUTE2                               VARCHAR2(150) ,
 ATTRIBUTE3                               VARCHAR2(150) ,
 ATTRIBUTE4                               VARCHAR2(150) ,
 ATTRIBUTE5                               VARCHAR2(150) ,
 ATTRIBUTE6                               VARCHAR2(150) ,
 ATTRIBUTE7                               VARCHAR2(150) ,
 ATTRIBUTE8                               VARCHAR2(150) ,
 ATTRIBUTE9                               VARCHAR2(150) ,
 ATTRIBUTE10                              VARCHAR2(150) ,
 ATTRIBUTE11                              VARCHAR2(150) ,
 ATTRIBUTE12                              VARCHAR2(150) ,
 ATTRIBUTE13                              VARCHAR2(150) ,
 ATTRIBUTE14                              VARCHAR2(150) ,
 ATTRIBUTE15                              VARCHAR2(150) ,
 ATTRIBUTE_CATEGORY                       VARCHAR2(30) ,
 USAGE                                    VARCHAR2(2000) ,
 OBJECT_VERSION_NUMBER             NUMBER
 );

 p_task_references_rec  references_rec ;

/*#
 * Creates an object reference for a Task.
 *
 * @param p_api_version Standard API version number. See "Standard IN Parameters", Oracle Common Application Calendar API Reference Guide.
 * @rep:paraminfo {@rep:required}
 * @param p_init_msg_list Standard API flag allows API callers to request that the API does the initialization of the message list on their behalf. By default, the message list will not be initialized.
 * See "Standard IN Parameters", Oracle Common Application Calendar API Reference Guide.
 * @param p_commit Standard API flag is used by API callers to ask the API to commit on their behalf after performing its function. By default, the commit will not be performed.
 * See "Standard IN Parameters", Oracle Common Application Calendar API Reference Guide.
 * @param p_task_id Unique Identifier for the task to be used for reference creation. Either <code>p_task_id</code> or <code>p_task_number</code> must be passed.
 * @rep:paraminfo {@rep:required}
 * @param p_task_number Unique task number to be used for reference creation. Either <code>p_task_id</code> or <code>p_task_number</code> must be passed.
 * @rep:paraminfo {@rep:required}
 * @param p_object_type_code Object type code for reference creation.
 * @rep:paraminfo {@rep:required}
 * @param p_object_name Object name for reference creation.
 * @rep:paraminfo {@rep:required}
 * @param p_object_id Object identifier for reference creation.
 * @rep:paraminfo {@rep:required}
 * @param p_object_details Object details for reference creation.
 * @param p_reference_code Reference code for reference creation.
 * @param p_usage Usage for reference creation.
 * @param x_return_status Result of all the operations performed by the API. This will have one of the following values:
 *  <LI><Code>FND_API.G_RET_STS_SUCCESS</Code> - If the API processed the data successfully.
 *  <LI><Code>FND_API.G_RET_STS_ERROR</Code> - If there was an expected error in API processing.
 *  <LI><Code>FND_API.G_RET_STS_UNEXP_ERROR</Code> If there was an unexpected error in API processing.
 * @param x_msg_count Number of messages returned in the API message list.
 * @param x_msg_data Returned message data in an encoded format if <code>x_msg_count</code> returns non-zero value.
 * @param x_task_reference_id Unique reference identifier being created.
 * @param p_attribute1 Attribute1 of customer flex fields.
 * @param p_attribute2 Attribute2 of customer flex fields.
 * @param p_attribute3 Attribute3 of customer flex fields.
 * @param p_attribute4 Attribute4 of customer flex fields.
 * @param p_attribute5 Attribute5 of customer flex fields.
 * @param p_attribute6 Attribute6 of customer flex fields.
 * @param p_attribute7 Attribute7 of customer flex fields.
 * @param p_attribute8 Attribute8 of customer flex fields.
 * @param p_attribute9 Attribute9 of customer flex fields.
 * @param p_attribute10 Attribute10 of customer flex fields.
 * @param p_attribute11 Attribute11 of customer flex fields.
 * @param p_attribute12 Attribute12 of customer flex fields.
 * @param p_attribute13 Attribute13 of customer flex fields.
 * @param p_attribute14 Attribute14 of customer flex fields.
 * @param p_attribute15 Attribute15 of customer flex fields.
 * @param p_attribute_category Attribute category for the customer flex fields.
 *
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Task Reference
 * @rep:compatibility S
 */
   PROCEDURE create_references (
      p_api_version         IN       NUMBER,
      p_init_msg_list       IN       VARCHAR2 DEFAULT fnd_api.g_false,
      p_commit              IN       VARCHAR2 DEFAULT fnd_api.g_false,
      p_task_id             IN       NUMBER DEFAULT NULL,
      p_task_number         IN       VARCHAR2 DEFAULT NULL,
      p_object_type_code    IN       VARCHAR2 DEFAULT NULL,
      p_object_name         IN       VARCHAR2 ,
      p_object_id           IN       NUMBER,
      p_object_details      IN       VARCHAR2 DEFAULT NULL,
      p_reference_code      IN       VARCHAR2 DEFAULT NULL,
      p_usage               IN       VARCHAR2 DEFAULT NULL,
      x_return_status       OUT NOCOPY VARCHAR2,
      x_msg_data            OUT NOCOPY VARCHAR2,
      x_msg_count           OUT NOCOPY NUMBER,
      x_task_reference_id   OUT NOCOPY NUMBER,
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

-- Removed '#' to de-annotate this procedure. irep parser
-- will not pick up this annotation. Bug# 5406214

/*
 * Locks an existing object reference for a Task.
 *
 * @param p_api_version Standard API version number.
 * @rep:paraminfo {@rep:required}
 * @param p_init_msg_list Standard API flag allows API callers to request that the API does the initialization of the message list on their behalf. By default, the message list will not be initialized.
 * @param p_commit Standard API flag is used by API callers to ask the API to commit on their behalf after performing its function. By default, the commit will not be performed.
 * @param p_object_version_number Object version number of the current reference record.
 * @rep:paraminfo {@rep:required}
 * @param p_task_reference_id Unique reference identifier of the reference to be locked.
 * @rep:paraminfo {@rep:required}
 * @param x_return_status Result of all the operations performed by the API. This will have one of the following values:
 *  <LI><Code>FND_API.G_RET_STS_SUCCESS</Code> - If the API processed the data successfully.
 *  <LI><Code>FND_API.G_RET_STS_ERROR</Code> - If there was an expected error in API processing.
 *  <LI><Code>FND_API.G_RET_STS_UNEXP_ERROR</Code> If there was an unexpected error in API processing.
 * @param x_msg_count Number of messages returned in the API message list.
 * @param x_msg_data Returned message data in an encoded format if <code>x_msg_count</code> returns non-zero value.
 *
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Lock Task Reference
 * @rep:compatibility S
 */
   PROCEDURE lock_references (
      p_api_version       IN       NUMBER,
      p_init_msg_list     IN       VARCHAR2 DEFAULT fnd_api.g_false,
      p_commit            IN       VARCHAR2 DEFAULT fnd_api.g_false,
      p_task_reference_id   IN       NUMBER,
      p_object_version_number IN   NUMBER,
      x_return_status     OUT NOCOPY VARCHAR2,
      x_msg_data          OUT NOCOPY VARCHAR2,
      x_msg_count         OUT NOCOPY NUMBER
   )  ;

/*#
 * Updates an existing object reference for a Task.
 *
 * @param p_api_version Standard API version number. See "Standard IN Parameters", Oracle Common Application Calendar API Reference Guide.
 * @rep:paraminfo {@rep:required}
 * @param p_init_msg_list Standard API flag allows API callers to request that the API does the initialization of the message list on their behalf. By default, the message list will not be initialized.
 * See "Standard IN Parameters", Oracle Common Application Calendar API Reference Guide.
 * @param p_commit Standard API flag is used by API callers to ask the API to commit on their behalf after performing its function. By default, the commit will not be performed.
 * See "Standard IN Parameters", Oracle Common Application Calendar API Reference Guide.
 * @param p_object_version_number Object version number of the current reference record.
 * @rep:paraminfo {@rep:required}
 * @param p_task_reference_id Unique reference identifier of the reference to be updated.
 * @rep:paraminfo {@rep:required}
 * @param p_object_type_code Object type code for reference update.
 * @param p_object_name Object name for reference update.
 * @param p_object_id Object identifier for reference update.
 * @param p_object_details Object details for reference update.
 * @param p_reference_code Reference code for reference update.
 * @param p_usage Usage for reference update.
 * @param x_return_status Result of all the operations performed by the API. This will have one of the following values:
 *  <LI><Code>FND_API.G_RET_STS_SUCCESS</Code> - If the API processed the data successfully.
 *  <LI><Code>FND_API.G_RET_STS_ERROR</Code> - If there was an expected error in API processing.
 *  <LI><Code>FND_API.G_RET_STS_UNEXP_ERROR</Code> If there was an unexpected error in API processing.
 * @param x_msg_count Number of messages returned in the API message list.
 * @param x_msg_data Returned message data in an encoded format if <code>x_msg_count</code> returns non-zero value.
 * @param p_attribute1 Attribute1 of customer flex fields.
 * @param p_attribute2 Attribute2 of customer flex fields.
 * @param p_attribute3 Attribute3 of customer flex fields.
 * @param p_attribute4 Attribute4 of customer flex fields.
 * @param p_attribute5 Attribute5 of customer flex fields.
 * @param p_attribute6 Attribute6 of customer flex fields.
 * @param p_attribute7 Attribute7 of customer flex fields.
 * @param p_attribute8 Attribute8 of customer flex fields.
 * @param p_attribute9 Attribute9 of customer flex fields.
 * @param p_attribute10 Attribute10 of customer flex fields.
 * @param p_attribute11 Attribute11 of customer flex fields.
 * @param p_attribute12 Attribute12 of customer flex fields.
 * @param p_attribute13 Attribute13 of customer flex fields.
 * @param p_attribute14 Attribute14 of customer flex fields.
 * @param p_attribute15 Attribute15 of customer flex fields.
 * @param p_attribute_category Attribute category for the customer flex fields.
 *
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Update Task Reference
 * @rep:compatibility S
 */
   PROCEDURE update_references (
      p_api_version         IN       NUMBER,
      p_init_msg_list       IN       VARCHAR2 DEFAULT fnd_api.g_false,
      p_commit              IN       VARCHAR2 DEFAULT fnd_api.g_false,
      p_object_version_number   IN     OUT NOCOPY NUMBER ,
      p_task_reference_id   IN       NUMBER,
      p_object_type_code    IN       VARCHAR2 DEFAULT fnd_api.g_miss_char,
      p_object_name         IN       VARCHAR2 DEFAULT fnd_api.g_miss_char,
      p_object_id           IN       NUMBER DEFAULT  fnd_api.g_miss_num,
      p_object_details      IN       VARCHAR2 DEFAULT fnd_api.g_miss_char,
      p_reference_code      IN       VARCHAR2 DEFAULT fnd_api.g_miss_char,
      p_usage               IN       VARCHAR2 DEFAULT fnd_api.g_miss_char,
      x_return_status       OUT NOCOPY VARCHAR2,
      x_msg_data            OUT NOCOPY VARCHAR2,
      x_msg_count           OUT NOCOPY NUMBER,
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
 * Deletes an existing object reference for a Task.
 *
 * @param p_api_version Standard API version number. See "Standard IN Parameters", Oracle Common Application Calendar API Reference Guide.
 * @rep:paraminfo {@rep:required}
 * @param p_init_msg_list Standard API flag allows API callers to request that the API does the initialization of the message list on their behalf. By default, the message list will not be initialized.
 * See "Standard IN Parameters", Oracle Common Application Calendar API Reference Guide.
 * @param p_commit Standard API flag is used by API callers to ask the API to commit on their behalf after performing its function. By default, the commit will not be performed.
 * See "Standard IN Parameters", Oracle Common Application Calendar API Reference Guide.
 * @param p_object_version_number Object version number of the current reference record.
 * @rep:paraminfo {@rep:required}
 * @param p_task_reference_id Unique reference identifier of the reference to be deleted.
 * @rep:paraminfo {@rep:required}
 * @param x_return_status Result of all the operations performed by the API. This will have one of the following values:
 *  <LI><Code>FND_API.G_RET_STS_SUCCESS</Code> - If the API processed the data successfully.
 *  <LI><Code>FND_API.G_RET_STS_ERROR</Code> - If there was an expected error in API processing.
 *  <LI><Code>FND_API.G_RET_STS_UNEXP_ERROR</Code> If there was an unexpected error in API processing.
 * @param x_msg_count Number of messages returned in the API message list.
 * @param x_msg_data Returned message data in an encoded format if <code>x_msg_count</code> returns non-zero value.
 *
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Delete Task Reference
 * @rep:compatibility S
 */
   PROCEDURE delete_references (
      p_api_version         IN       NUMBER,
      p_init_msg_list       IN       VARCHAR2 DEFAULT fnd_api.g_false,
      p_commit              IN       VARCHAR2 DEFAULT fnd_api.g_false,
      p_object_version_number   IN     NUMBER ,
      p_task_reference_id   IN       NUMBER,
      x_return_status       OUT NOCOPY VARCHAR2,
      x_msg_data            OUT NOCOPY VARCHAR2,
      x_msg_count           OUT NOCOPY NUMBER
   );
END;

 

/
