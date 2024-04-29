--------------------------------------------------------
--  DDL for Package JTF_CAL_GRANTS_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_CAL_GRANTS_PVT_W" AUTHID CURRENT_USER as
  /* $Header: jtfwcgts.pls 115.5 2002/11/15 00:23:37 jawang ship $ */
  procedure rosetta_table_copy_in_p1(t out nocopy jtf_cal_grants_pvt.granteetbl, a0 JTF_VARCHAR2_TABLE_300
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p1(t jtf_cal_grants_pvt.granteetbl, a0 out nocopy JTF_VARCHAR2_TABLE_300
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    );

  procedure has_access_level(p_resourceid  VARCHAR2
    , p_groupid  VARCHAR2
    , ddrosetta_retval_bool OUT NOCOPY NUMBER
  );
end jtf_cal_grants_pvt_w;

 

/
