--------------------------------------------------------
--  DDL for Package AMS_IMPORTCLIENT_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_IMPORTCLIENT_PVT_W" AUTHID CURRENT_USER as
  /* $Header: amswmics.pls 115.9 2003/05/15 22:37:13 huili ship $ */
  procedure rosetta_table_copy_in_p0(t OUT NOCOPY ams_importclient_pvt.char_data_set_type_w, a0 JTF_VARCHAR2_TABLE_4000);
  procedure rosetta_table_copy_out_p0(t ams_importclient_pvt.char_data_set_type_w, a0 OUT NOCOPY JTF_VARCHAR2_TABLE_4000);

  procedure rosetta_table_copy_in_p1(t OUT NOCOPY ams_importclient_pvt.num_data_set_type_w, a0 JTF_NUMBER_TABLE);
  procedure rosetta_table_copy_out_p1(t ams_importclient_pvt.num_data_set_type_w, a0 OUT NOCOPY JTF_NUMBER_TABLE);

  procedure rosetta_table_copy_in_p2(t OUT NOCOPY ams_importclient_pvt.varchar2_4000_set_type, a0 JTF_VARCHAR2_TABLE_4000);
  procedure rosetta_table_copy_out_p2(t ams_importclient_pvt.varchar2_4000_set_type, a0 OUT NOCOPY JTF_VARCHAR2_TABLE_4000);

  procedure rosetta_table_copy_in_p3(t OUT NOCOPY ams_importclient_pvt.varchar2_150_set_type, a0 JTF_VARCHAR2_TABLE_200);
  procedure rosetta_table_copy_out_p3(t ams_importclient_pvt.varchar2_150_set_type, a0 OUT NOCOPY JTF_VARCHAR2_TABLE_200);

  procedure insert_lead_data(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_import_list_header_id  NUMBER
    , p_data JTF_VARCHAR2_TABLE_4000
    , p_error_rows JTF_NUMBER_TABLE
    , p_row_count  NUMBER
    , x_return_status OUT NOCOPY  VARCHAR2
    , x_msg_count OUT NOCOPY  NUMBER
    , x_msg_data OUT NOCOPY  VARCHAR2
  );
  procedure insert_list_data(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_import_list_header_id  NUMBER
    , p_data JTF_VARCHAR2_TABLE_4000
    , p_row_count  NUMBER
    , p_error_rows JTF_NUMBER_TABLE
    , x_return_status OUT NOCOPY  VARCHAR2
    , x_msg_count OUT NOCOPY  NUMBER
    , x_msg_data OUT NOCOPY  VARCHAR2
  );
end ams_importclient_pvt_w;

 

/
