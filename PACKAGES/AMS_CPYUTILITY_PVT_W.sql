--------------------------------------------------------
--  DDL for Package AMS_CPYUTILITY_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_CPYUTILITY_PVT_W" AUTHID CURRENT_USER as
  /* $Header: amswcpus.pls 115.5 2003/08/26 20:39:38 asaha noship $ */
  procedure rosetta_table_copy_in_p0(t out nocopy ams_cpyutility_pvt.copy_attributes_table_type, a0 JTF_VARCHAR2_TABLE_100);
  procedure rosetta_table_copy_out_p0(t ams_cpyutility_pvt.copy_attributes_table_type, a0 out nocopy JTF_VARCHAR2_TABLE_100);

  procedure rosetta_table_copy_in_p2(t out nocopy ams_cpyutility_pvt.copy_columns_table_type, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_VARCHAR2_TABLE_4000
    );
  procedure rosetta_table_copy_out_p2(t ams_cpyutility_pvt.copy_columns_table_type, a0 out nocopy JTF_VARCHAR2_TABLE_100
    , a1 out nocopy JTF_VARCHAR2_TABLE_4000
    );

  procedure rosetta_table_copy_in_p3(t out nocopy ams_cpyutility_pvt.log_mesg_type_table, a0 JTF_VARCHAR2_TABLE_100);
  procedure rosetta_table_copy_out_p3(t ams_cpyutility_pvt.log_mesg_type_table, a0 out nocopy JTF_VARCHAR2_TABLE_100);

  procedure rosetta_table_copy_in_p4(t out nocopy ams_cpyutility_pvt.log_mesg_txt_table, a0 JTF_VARCHAR2_TABLE_4000);
  procedure rosetta_table_copy_out_p4(t ams_cpyutility_pvt.log_mesg_txt_table, a0 out nocopy JTF_VARCHAR2_TABLE_4000);

  procedure rosetta_table_copy_in_p5(t out nocopy ams_cpyutility_pvt.log_act_used_by_table, a0 JTF_VARCHAR2_TABLE_100);
  procedure rosetta_table_copy_out_p5(t ams_cpyutility_pvt.log_act_used_by_table, a0 out nocopy JTF_VARCHAR2_TABLE_100);

  procedure rosetta_table_copy_in_p6(t out nocopy ams_cpyutility_pvt.log_act_used_id_table, a0 JTF_NUMBER_TABLE);
  procedure rosetta_table_copy_out_p6(t ams_cpyutility_pvt.log_act_used_id_table, a0 out nocopy JTF_NUMBER_TABLE);

  procedure get_column_value(p_column_name  VARCHAR2
    , p1_a0 JTF_VARCHAR2_TABLE_100
    , p1_a1 JTF_VARCHAR2_TABLE_4000
    , x_column_value out nocopy  VARCHAR2
  );
  function is_copy_attribute(p_attribute  VARCHAR2
    , p_attributes_table JTF_VARCHAR2_TABLE_100
  ) return varchar2;
end ams_cpyutility_pvt_w;

 

/
