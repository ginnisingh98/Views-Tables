--------------------------------------------------------
--  DDL for Package JTF_TASK_RECURRENCES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_TASK_RECURRENCES_PVT" AUTHID CURRENT_USER AS
/* $Header: jtfvtkus.pls 120.2 2006/04/13 03:53:01 sbarat ship $ */
    g_pkg_name           CONSTANT VARCHAR2(30) := 'JTF_TASK_RECURRENCE';


    TYPE output_dates_rec IS TABLE OF DATE
        INDEX BY BINARY_INTEGER;

    PROCEDURE create_task_recurrence (
        p_api_version            IN       NUMBER,
        p_init_msg_list          IN       VARCHAR2 DEFAULT fnd_api.g_false,
        p_commit                 IN       VARCHAR2 DEFAULT fnd_api.g_false,
        p_task_id                IN       NUMBER,
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
        x_return_status          OUT NOCOPY      VARCHAR2,
        x_msg_count              OUT NOCOPY      NUMBER,
        x_msg_data               OUT NOCOPY      VARCHAR2,
        x_recurrence_rule_id     OUT NOCOPY      NUMBER,
        x_task_rec               OUT NOCOPY      jtf_task_recurrences_pub.task_details_rec,
        x_output_dates_counter   OUT NOCOPY      INTEGER,
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

    PROCEDURE generate_dates (
        p_occurs_which                 NUMBER DEFAULT NULL,
        p_day_of_week                  NUMBER DEFAULT NULL,
        p_date_of_month                NUMBER DEFAULT NULL,
        p_occurs_month                 NUMBER DEFAULT NULL,
        p_occurs_uom                   VARCHAR2 DEFAULT NULL,
        p_occurs_every                 NUMBER DEFAULT NULL,
        p_occurs_number                NUMBER DEFAULT 0,
        p_start_date                   DATE DEFAULT NULL,
        p_end_date                     DATE DEFAULT SYSDATE,
        x_output_dates_tbl       OUT NOCOPY   jtf_task_recurrences_pvt.output_dates_rec,
        x_output_dates_counter   OUT NOCOPY   INTEGER,
        p_sunday                  IN       VARCHAR2 DEFAULT jtf_task_utl.g_no_char,
        p_monday                  IN       VARCHAR2 DEFAULT jtf_task_utl.g_no_char,
        p_tuesday                 IN       VARCHAR2 DEFAULT jtf_task_utl.g_no_char,
        p_wednesday               IN       VARCHAR2 DEFAULT jtf_task_utl.g_no_char,
        p_thursday                IN       VARCHAR2 DEFAULT jtf_task_utl.g_no_char,
        p_friday                  IN       VARCHAR2 DEFAULT jtf_task_utl.g_no_char,
        p_saturday                IN       VARCHAR2 DEFAULT jtf_task_utl.g_no_char,
        p_task_id                 IN       NUMBER   DEFAULT NULL                     -- Added by SBARAT on 13/04/2006 for bug# 5119803
    );

    PROCEDURE recur_main (
        p_occurs_which                 VARCHAR2 DEFAULT NULL,
        p_day_of_week                  VARCHAR2 DEFAULT NULL,
        p_date_of_month                NUMBER DEFAULT NULL,
        p_occurs_month                 NUMBER DEFAULT NULL,
        p_occurs_uom                   VARCHAR2 DEFAULT NULL,
        p_occurs_every                 NUMBER DEFAULT NULL,
        p_occurs_number                NUMBER DEFAULT 0,
        p_start_date                   DATE DEFAULT NULL,
        p_end_date                     DATE DEFAULT NULL,
        x_output_dates_tbl       OUT NOCOPY   jtf_task_recurrences_pvt.output_dates_rec,
        x_output_dates_counter   OUT NOCOPY   INTEGER,
        p_sunday                  IN       VARCHAR2 DEFAULT jtf_task_utl.g_no_char,
        p_monday                  IN       VARCHAR2 DEFAULT jtf_task_utl.g_no_char,
        p_tuesday                 IN       VARCHAR2 DEFAULT jtf_task_utl.g_no_char,
        p_wednesday               IN       VARCHAR2 DEFAULT jtf_task_utl.g_no_char,
        p_thursday                IN       VARCHAR2 DEFAULT jtf_task_utl.g_no_char,
        p_friday                  IN       VARCHAR2 DEFAULT jtf_task_utl.g_no_char,
        p_saturday                IN       VARCHAR2 DEFAULT jtf_task_utl.g_no_char,
        p_task_id                 IN       NUMBER   DEFAULT NULL                     -- Added by SBARAT on 13/04/2006 for bug# 5119803
    );

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
