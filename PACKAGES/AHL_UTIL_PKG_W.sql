--------------------------------------------------------
--  DDL for Package AHL_UTIL_PKG_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_UTIL_PKG_W" AUTHID CURRENT_USER as
  /* $Header: AHLUTLWS.pls 115.6 2003/03/20 10:46:06 sjayacha noship $ */
  procedure rosetta_table_copy_in_p1(t out nocopy ahl_util_pkg.err_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_2000
    );
  procedure rosetta_table_copy_out_p1(t ahl_util_pkg.err_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_2000
    );

  procedure err_mesg_to_table(p0_a0 out nocopy JTF_NUMBER_TABLE
    , p0_a1 out nocopy JTF_VARCHAR2_TABLE_2000
  );
end ahl_util_pkg_w;

 

/
