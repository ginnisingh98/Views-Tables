--------------------------------------------------------
--  DDL for Package JTF_CALENDAR_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_CALENDAR_PUB_W" AUTHID CURRENT_USER as
  /* $Header: jtfclaws.pls 120.2 2005/12/30 03:06 abraina ship $ */
  procedure rosetta_table_copy_in_p1(t out nocopy jtf_calendar_pub.shift_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_DATE_TABLE
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p1(t jtf_calendar_pub.shift_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_DATE_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    );

  procedure rosetta_table_copy_in_p3(t out nocopy jtf_calendar_pub.shift_tbl_attributes_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_DATE_TABLE
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_VARCHAR2_TABLE_200
    , a6 JTF_VARCHAR2_TABLE_200
    , a7 JTF_VARCHAR2_TABLE_200
    , a8 JTF_VARCHAR2_TABLE_200
    , a9 JTF_VARCHAR2_TABLE_200
    , a10 JTF_VARCHAR2_TABLE_200
    , a11 JTF_VARCHAR2_TABLE_200
    , a12 JTF_VARCHAR2_TABLE_200
    , a13 JTF_VARCHAR2_TABLE_200
    , a14 JTF_VARCHAR2_TABLE_200
    , a15 JTF_VARCHAR2_TABLE_200
    , a16 JTF_VARCHAR2_TABLE_200
    , a17 JTF_VARCHAR2_TABLE_200
    , a18 JTF_VARCHAR2_TABLE_200
    , a19 JTF_VARCHAR2_TABLE_200
    );
  procedure rosetta_table_copy_out_p3(t jtf_calendar_pub.shift_tbl_attributes_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_DATE_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_VARCHAR2_TABLE_200
    , a6 out nocopy JTF_VARCHAR2_TABLE_200
    , a7 out nocopy JTF_VARCHAR2_TABLE_200
    , a8 out nocopy JTF_VARCHAR2_TABLE_200
    , a9 out nocopy JTF_VARCHAR2_TABLE_200
    , a10 out nocopy JTF_VARCHAR2_TABLE_200
    , a11 out nocopy JTF_VARCHAR2_TABLE_200
    , a12 out nocopy JTF_VARCHAR2_TABLE_200
    , a13 out nocopy JTF_VARCHAR2_TABLE_200
    , a14 out nocopy JTF_VARCHAR2_TABLE_200
    , a15 out nocopy JTF_VARCHAR2_TABLE_200
    , a16 out nocopy JTF_VARCHAR2_TABLE_200
    , a17 out nocopy JTF_VARCHAR2_TABLE_200
    , a18 out nocopy JTF_VARCHAR2_TABLE_200
    , a19 out nocopy JTF_VARCHAR2_TABLE_200
    );

  procedure is_res_available(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_resource_id  NUMBER
    , p_resource_type  VARCHAR2
    , p_start_date_time  date
    , p_duration  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_avail out nocopy  VARCHAR2
  );
  procedure get_available_time(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_resource_id  NUMBER
    , p_resource_type  VARCHAR2
    , p_start_date  date
    , p_end_date  date
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p9_a0 out nocopy JTF_NUMBER_TABLE
    , p9_a1 out nocopy JTF_DATE_TABLE
    , p9_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a4 out nocopy JTF_VARCHAR2_TABLE_100
  );
  procedure get_available_slot(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_resource_id  NUMBER
    , p_resource_type  VARCHAR2
    , p_start_date_time  date
    , p_end_date_time  date
    , p_duration  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_slot_start_date out nocopy  DATE
    , x_slot_end_date out nocopy  DATE
    , x_shift_construct_id out nocopy  NUMBER
    , x_availability_type out nocopy  VARCHAR2
  );
  procedure get_resource_shifts(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_resource_id  NUMBER
    , p_resource_type  VARCHAR2
    , p_start_date  date
    , p_end_date  date
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p9_a0 out nocopy JTF_NUMBER_TABLE
    , p9_a1 out nocopy JTF_DATE_TABLE
    , p9_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a4 out nocopy JTF_VARCHAR2_TABLE_100
  );
  procedure get_resource_shifts(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_resource_id  NUMBER
    , p_resource_type  VARCHAR2
    , p_start_date  date
    , p_end_date  date
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p9_a0 out nocopy JTF_NUMBER_TABLE
    , p9_a1 out nocopy JTF_DATE_TABLE
    , p9_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a5 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a6 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a7 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a8 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a9 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a10 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a11 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a12 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a13 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a14 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a15 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a16 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a17 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a18 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a19 out nocopy JTF_VARCHAR2_TABLE_200
  );
  procedure get_res_schedule(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_resource_id  NUMBER
    , p_resource_type  VARCHAR2
    , p_start_date  date
    , p_end_date  date
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p9_a0 out nocopy JTF_NUMBER_TABLE
    , p9_a1 out nocopy JTF_DATE_TABLE
    , p9_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a4 out nocopy JTF_VARCHAR2_TABLE_100
  );
  function resourcedt_to_serverdt(p_resource_dttime  date
    , p_resource_tz_id  NUMBER
    , p_server_tz_id  NUMBER
  ) return date;
  procedure validate_cal_date(p_calendar_id  NUMBER
    , p_shift_date  date
    , ddrosetta_retval_bool OUT NOCOPY NUMBER
  );
end jtf_calendar_pub_w;

 

/
