--------------------------------------------------------
--  DDL for Package AMS_LIST_PURGE_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_LIST_PURGE_PVT_W" AUTHID CURRENT_USER as
  /* $Header: amswimcs.pls 120.0 2006/03/29 05:39 rmbhanda noship $ */
  procedure rosetta_table_copy_in_p0(t out nocopy ams_list_purge_pvt.t_rec_table, a0 JTF_NUMBER_TABLE);
  procedure rosetta_table_copy_out_p0(t ams_list_purge_pvt.t_rec_table, a0 out nocopy JTF_NUMBER_TABLE);

  procedure rosetta_table_copy_in_p2(t out nocopy ams_list_purge_pvt.list_header_id_tbl, a0 JTF_NUMBER_TABLE
    );
  procedure rosetta_table_copy_out_p2(t ams_list_purge_pvt.list_header_id_tbl, a0 out nocopy JTF_NUMBER_TABLE
    );

  procedure delete_entries_soft(p0_a0 JTF_NUMBER_TABLE
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
  procedure delete_entries_online(p0_a0 JTF_NUMBER_TABLE
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
end ams_list_purge_pvt_w;

 

/
