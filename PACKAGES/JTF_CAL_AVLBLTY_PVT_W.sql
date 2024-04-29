--------------------------------------------------------
--  DDL for Package JTF_CAL_AVLBLTY_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_CAL_AVLBLTY_PVT_W" AUTHID CURRENT_USER as
  /* $Header: jtfwavs.pls 120.2 2006/04/27 23:25 deeprao ship $ */
  procedure rosetta_table_copy_in_p1(t out nocopy jtf_cal_avlblty_pvt.rstab, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_400
    );
  procedure rosetta_table_copy_out_p1(t jtf_cal_avlblty_pvt.rstab, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_400
    );

  procedure rosetta_table_copy_in_p3(t out nocopy jtf_cal_avlblty_pvt.avlbltb, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_400
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    );
  procedure rosetta_table_copy_out_p3(t jtf_cal_avlblty_pvt.avlbltb, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_400
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    );

  procedure availability(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_VARCHAR2_TABLE_100
    , p5_a2 JTF_VARCHAR2_TABLE_400
    , p_startdatetime  date
    , p_enddatetime  date
    , p_slotsize  NUMBER
    , x_numberofslots out nocopy  NUMBER
    , p10_a0 out nocopy JTF_NUMBER_TABLE
    , p10_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a2 out nocopy JTF_VARCHAR2_TABLE_400
    , p10_a3 out nocopy JTF_NUMBER_TABLE
    , p10_a4 out nocopy JTF_NUMBER_TABLE
    , p11_a0 out nocopy JTF_NUMBER_TABLE
    , p11_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a2 out nocopy JTF_VARCHAR2_TABLE_400
    , p11_a3 out nocopy JTF_NUMBER_TABLE
    , p11_a4 out nocopy JTF_NUMBER_TABLE
  );
end jtf_cal_avlblty_pvt_w;

 

/
