--------------------------------------------------------
--  DDL for Package JTF_TASK_RECURRENCES_PUB_OA_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_TASK_RECURRENCES_PUB_OA_W" AUTHID CURRENT_USER as
  /* $Header: jtfbtkus.pls 115.1 2003/09/23 22:44:55 twan noship $ */
  procedure rosetta_table_copy_in_p1(t out nocopy jtf_task_recurrences_pub.output_dates_rec, a0 JTF_DATE_TABLE);
  procedure rosetta_table_copy_out_p1(t jtf_task_recurrences_pub.output_dates_rec, a0 out nocopy JTF_DATE_TABLE);

  procedure create_task_recurrence(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_task_id  NUMBER
    , p_task_number  VARCHAR2
    , p_occurs_which  INTEGER
    , p_template_flag  VARCHAR2
    , p_day_of_week  INTEGER
    , p_date_of_month  INTEGER
    , p_occurs_month  INTEGER
    , p_occurs_uom  VARCHAR2
    , p_occurs_every  INTEGER
    , p_occurs_number  INTEGER
    , p_start_date_active  DATE
    , p_end_date_active  DATE
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_recurrence_rule_id out nocopy  NUMBER
    , p19_a0 out nocopy  NUMBER
    , p19_a1 out nocopy  NUMBER
    , p19_a2 out nocopy  VARCHAR2
    , x_reccurences_generated out nocopy  INTEGER
    , p_attribute1  VARCHAR2
    , p_attribute2  VARCHAR2
    , p_attribute3  VARCHAR2
    , p_attribute4  VARCHAR2
    , p_attribute5  VARCHAR2
    , p_attribute6  VARCHAR2
    , p_attribute7  VARCHAR2
    , p_attribute8  VARCHAR2
    , p_attribute9  VARCHAR2
    , p_attribute10  VARCHAR2
    , p_attribute11  VARCHAR2
    , p_attribute12  VARCHAR2
    , p_attribute13  VARCHAR2
    , p_attribute14  VARCHAR2
    , p_attribute15  VARCHAR2
    , p_attribute_category  VARCHAR2
    , p_sunday  VARCHAR2
    , p_monday  VARCHAR2
    , p_tuesday  VARCHAR2
    , p_wednesday  VARCHAR2
    , p_thursday  VARCHAR2
    , p_friday  VARCHAR2
    , p_saturday  VARCHAR2
  );
end jtf_task_recurrences_pub_oa_w;

 

/
