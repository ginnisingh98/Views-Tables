--------------------------------------------------------
--  DDL for Package JTF_TASK_RECURRENCES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_TASK_RECURRENCES_PUB" AUTHID CURRENT_USER AS
/* $Header: jtfptkus.pls 120.1 2005/07/02 01:00:16 appldev ship $ */
/*#
 * This is the public package to validate, crete, update, and delete task recurrence.
 *
 * @rep:scope internal
 * @rep:product CAC
 * @rep:displayname Task Recurrence
 * @rep:lifecycle active
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY CAC_CAL_TASK
 */

    g_pkg_name                    VARCHAR2(30) := 'JTF_TASK_RECURRENCES_PUB';

    TYPE output_dates_rec IS TABLE OF DATE
        INDEX BY BINARY_INTEGER;

    TYPE task_details_rec IS RECORD (
        task_id                       NUMBER,
        task_number                   NUMBER,
        task_name                     VARCHAR2(30)
    );

   TYPE task_recurrence_rec IS RECORD (
      recurrence_rule_id            NUMBER,
      object_version_number         NUMBER,
      occurs_which                  NUMBER,
      day_of_week                   NUMBER,
      date_of_month                 NUMBER,
      occurs_month                  NUMBER,
      occurs_uom                    VARCHAR2(3),
      occurs_every                  NUMBER,
      occurs_number                 NUMBER,
      start_date_active             DATE,
      end_date_active               DATE,
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
      attribute_category            VARCHAR2(30) ,
      sunday                        VARCHAR2(1)  ,
      monday                        VARCHAR2(1)  ,
      tuesday                       VARCHAR2(1)  ,
      wednesday                     VARCHAR2(1)  ,
      thursday                      VARCHAR2(1)  ,
      friday                        VARCHAR2(1)  ,
      saturday                      VARCHAR2(1)
      );


    creating_recurrences          BOOLEAN := FALSE;

/*#
 * Creates a Task recurrence.
 *
 * @param p_api_version the standard API version number
 * @param p_init_msg_list the standard API flag allows API callers to request
 * that the API does the initialization of the message list on their behalf.
 * By default, the message list will not be initialized.
 * @param p_commit the standard API flag is used by API callers to ask
 * the API to commit on their behalf after performing its function
 * By default, the commit will not be performed.
 * @param p_task_id the task id for recurrence creation
 * @param p_task_number the task number for recurrence creation
 * @param p_occurs_which the occurs which for recurrence creation
 * @param p_template_flag the template flag for recurrence creation
 * @param p_day_of_week the day of week for recurrence creation
 * @param p_date_of_month the date of month for recurrence creation
 * @param p_occurs_month the occurs month for recurrence creation
 * @param p_occurs_uom the occurs uom for recurrence creation
 * @param p_occurs_every the occurs every for recurrence creation
 * @param p_occurs_number the occurs number for recurrence creation
 * @param p_start_date_active the start date active for recurrence creation
 * @param p_end_date_active the end date active for recurrence creation
 * @param x_return_status returns the result of all the operations performed
 * by the API and must have one of the following values:
 *   <LI><Code>FND_API.G_RET_STS_SUCCESS</Code>
 *   <LI><Code>FND_API.G_RET_STS_ERROR</Code>
 *   <LI><Code>FND_API.G_RET_STS_UNEXP_ERROR</Code>
 * @param x_msg_count returns the number of messages in the API message list
 * <code>x_msg_count</code> returns number one.
 * @param x_msg_data returns the message in an encoded format if
 * @param x_recurrence_rule_id the recurrence rule id being created
 * @param x_task_rec the task record being created
 * @param x_reccurences_generated the recurrences generated
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
 * @param p_sunday sunday
 * @param p_monday monday
 * @param p_tuesday tuesday
 * @param p_wednesday wednesday
 * @param p_thursday thursday
 * @param p_friday friday
 * @param p_saturday saturday
 * @rep:scope internal
 * @rep:lifecycle active
 * @rep:displayname Create Task Recurrence
 * @rep:compatibility S
 */

    PROCEDURE create_task_recurrence (
        p_api_version             IN       NUMBER,
        p_init_msg_list           IN       VARCHAR2 DEFAULT fnd_api.g_false,
        p_commit                  IN       VARCHAR2 DEFAULT fnd_api.g_false,
        p_task_id                 IN       NUMBER DEFAULT NULL,
        p_task_number             IN       VARCHAR2 DEFAULT NULL,
        p_occurs_which            IN       INTEGER DEFAULT NULL,
        p_template_flag           IN       VARCHAR2 DEFAULT jtf_task_utl.g_no_char,
        p_day_of_week             IN       INTEGER DEFAULT NULL,
        p_date_of_month           IN       INTEGER DEFAULT NULL,
        p_occurs_month            IN       INTEGER DEFAULT NULL,
        p_occurs_uom              IN       VARCHAR2 DEFAULT NULL,
        p_occurs_every            IN       INTEGER DEFAULT NULL,
        p_occurs_number           IN       INTEGER DEFAULT NULL,
        p_start_date_active       IN       DATE DEFAULT NULL,
        p_end_date_active         IN       DATE DEFAULT NULL,
        x_return_status           OUT NOCOPY      VARCHAR2,
        x_msg_count               OUT NOCOPY      NUMBER,
        x_msg_data                OUT NOCOPY      VARCHAR2,
        x_recurrence_rule_id      OUT NOCOPY      NUMBER,
        x_task_rec                OUT NOCOPY      jtf_task_recurrences_pub.task_details_rec,
        x_reccurences_generated   OUT NOCOPY      INTEGER,
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
        p_attribute_category      IN       VARCHAR2 DEFAULT null ,
        p_sunday                  IN       VARCHAR2 DEFAULT jtf_task_utl.g_no_char,
        p_monday                  IN       VARCHAR2 DEFAULT jtf_task_utl.g_no_char,
        p_tuesday                 IN       VARCHAR2 DEFAULT jtf_task_utl.g_no_char,
        p_wednesday               IN       VARCHAR2 DEFAULT jtf_task_utl.g_no_char,
        p_thursday                IN       VARCHAR2 DEFAULT jtf_task_utl.g_no_char,
        p_friday                  IN       VARCHAR2 DEFAULT jtf_task_utl.g_no_char,
        p_saturday                IN       VARCHAR2 DEFAULT jtf_task_utl.g_no_char
        );



/*#
 * Updates a Task recurrence.
 *
 * @param p_api_version the standard API version number
 * @param p_init_msg_list the standard API flag allows API callers to request
 * that the API does the initialization of the message list on their behalf.
 * By default, the message list will not be initialized.
 * @param p_commit the standard API flag is used by API callers to ask
 * the API to commit on their behalf after performing its function
 * By default, the commit will not be performed.
 * @param p_task_id the task id for recurrence update
 * @param p_recurrence_rule_id the recurrence rule id for recurrence update
 * @param p_occurs_which the occurs which for recurrence update
 * @param p_day_of_week the day of week for recurrence update
 * @param p_date_of_month the date of month for recurrence update
 * @param p_occurs_month the occurs month for recurrence update
 * @param p_occurs_uom the occurs uom for recurrence update
 * @param p_occurs_every the occurs every for recurrence update
 * @param p_occurs_number the occurs number for recurrence update
 * @param p_start_date_active the start date active for recurrence update
 * @param p_end_date_active the end date active for recurrence update
 * @param p_template_flag the template flag for recurrence update
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
 * @param p_sunday sunday
 * @param p_monday monday
 * @param p_tuesday tuesday
 * @param p_wednesday wednesday
 * @param p_thursday thursday
 * @param p_friday friday
 * @param p_saturday saturday
 * @param x_new_recurrence_rule_id the new recurrence rule id being created
 * @param x_return_status returns the result of all the operations performed
 * by the API and must have one of the following values:
 *   <LI><Code>FND_API.G_RET_STS_SUCCESS</Code>
 *   <LI><Code>FND_API.G_RET_STS_ERROR</Code>
 *   <LI><Code>FND_API.G_RET_STS_UNEXP_ERROR</Code>
 * @param x_msg_count returns the number of messages in the API message list
 * <code>x_msg_count</code> returns number one.
 * @param x_msg_data returns the message in an encoded format if
 * @rep:scope internal
 * @rep:lifecycle active
 * @rep:displayname Update Task Recurrence
 * @rep:compatibility S
 */
    PROCEDURE update_task_recurrence (
        p_api_version            IN       NUMBER,
        p_init_msg_list          IN       VARCHAR2 DEFAULT fnd_api.g_false,
        p_commit                 IN       VARCHAR2 DEFAULT fnd_api.g_false,
        p_task_id                IN       NUMBER,
        p_recurrence_rule_id     IN       NUMBER,
        p_occurs_which           IN       INTEGER DEFAULT NULL,
        p_day_of_week            IN       INTEGER DEFAULT NULL,
        p_date_of_month          IN       INTEGER DEFAULT NULL,
        p_occurs_month           IN       INTEGER DEFAULT NULL,
        p_occurs_uom             IN       VARCHAR2 DEFAULT NULL,
        p_occurs_every           IN       INTEGER DEFAULT NULL,
        p_occurs_number          IN       INTEGER DEFAULT NULL,
        p_start_date_active      IN       DATE DEFAULT NULL,
        p_end_date_active        IN       DATE DEFAULT NULL,
        p_template_flag          IN       VARCHAR2 DEFAULT jtf_task_utl.g_no_char,
        p_attribute1             IN       VARCHAR2 DEFAULT NULL ,
        p_attribute2             IN       VARCHAR2 DEFAULT NULL ,
        p_attribute3             IN       VARCHAR2 DEFAULT NULL ,
        p_attribute4             IN       VARCHAR2 DEFAULT NULL ,
        p_attribute5             IN       VARCHAR2 DEFAULT NULL ,
        p_attribute6             IN       VARCHAR2 DEFAULT NULL ,
        p_attribute7             IN       VARCHAR2 DEFAULT NULL ,
        p_attribute8             IN       VARCHAR2 DEFAULT NULL ,
        p_attribute9             IN       VARCHAR2 DEFAULT NULL ,
        p_attribute10            IN       VARCHAR2 DEFAULT NULL ,
        p_attribute11            IN       VARCHAR2 DEFAULT NULL ,
        p_attribute12            IN       VARCHAR2 DEFAULT NULL ,
        p_attribute13            IN       VARCHAR2 DEFAULT NULL ,
        p_attribute14            IN       VARCHAR2 DEFAULT NULL ,
        p_attribute15            IN       VARCHAR2 DEFAULT NULL ,
        p_attribute_category     IN       VARCHAR2 DEFAULT NULL ,
        p_sunday                 IN       VARCHAR2 DEFAULT jtf_task_utl.g_no_char,
        p_monday                 IN       VARCHAR2 DEFAULT jtf_task_utl.g_no_char,
        p_tuesday                IN       VARCHAR2 DEFAULT jtf_task_utl.g_no_char,
        p_wednesday              IN       VARCHAR2 DEFAULT jtf_task_utl.g_no_char,
        p_thursday               IN       VARCHAR2 DEFAULT jtf_task_utl.g_no_char,
        p_friday                 IN       VARCHAR2 DEFAULT jtf_task_utl.g_no_char,
        p_saturday               IN       VARCHAR2 DEFAULT jtf_task_utl.g_no_char,
        x_new_recurrence_rule_id OUT NOCOPY      NUMBER,
        x_return_status          OUT NOCOPY      VARCHAR2,
        x_msg_count              OUT NOCOPY      NUMBER,
        x_msg_data               OUT NOCOPY      VARCHAR2
    );
END;

 

/
