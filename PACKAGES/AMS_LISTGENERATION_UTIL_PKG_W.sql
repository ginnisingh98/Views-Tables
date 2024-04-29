--------------------------------------------------------
--  DDL for Package AMS_LISTGENERATION_UTIL_PKG_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_LISTGENERATION_UTIL_PKG_W" AUTHID CURRENT_USER as
  /* $Header: amswlgus.pls 120.0 2006/02/23 00:55 rmbhanda noship $ */
  procedure rosetta_table_copy_in_p3(t out nocopy ams_listgeneration_util_pkg.spl_preview_count_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_32767
    , a2 JTF_NUMBER_TABLE
    );
  procedure rosetta_table_copy_out_p3(t ams_listgeneration_util_pkg.spl_preview_count_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_32767
    , a2 out nocopy JTF_NUMBER_TABLE
    );

  procedure get_split_preview_count(p0_a0 in out nocopy JTF_NUMBER_TABLE
    , p0_a1 in out nocopy JTF_VARCHAR2_TABLE_32767
    , p0_a2 in out nocopy JTF_NUMBER_TABLE
    , p_list_header_id  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  );
end ams_listgeneration_util_pkg_w;

 

/
