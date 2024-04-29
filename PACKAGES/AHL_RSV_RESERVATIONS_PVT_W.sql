--------------------------------------------------------
--  DDL for Package AHL_RSV_RESERVATIONS_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_RSV_RESERVATIONS_PVT_W" AUTHID CURRENT_USER as
  /* $Header: AHLWRSVS.pls 120.0 2005/07/01 03:20 anraj noship $ */
  procedure rosetta_table_copy_in_p2(t out nocopy ahl_rsv_reservations_pvt.serial_number_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p2(t ahl_rsv_reservations_pvt.serial_number_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    );

  procedure create_reservation(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_module_type  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_scheduled_material_id  NUMBER
    , p9_a0 JTF_NUMBER_TABLE
    , p9_a1 JTF_VARCHAR2_TABLE_100
  );
end ahl_rsv_reservations_pvt_w;

 

/
