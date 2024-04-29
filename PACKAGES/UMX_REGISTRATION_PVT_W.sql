--------------------------------------------------------
--  DDL for Package UMX_REGISTRATION_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."UMX_REGISTRATION_PVT_W" AUTHID CURRENT_USER as
  /* $Header: UMXWREGS.pls 120.1.12010000.2 2009/07/22 19:04:32 jstyles ship $ */
  procedure rosetta_table_copy_in_p1(t out nocopy umx_registration_pvt.umx_registration_data_tbl, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_VARCHAR2_TABLE_2000
    );
  procedure rosetta_table_copy_out_p1(t umx_registration_pvt.umx_registration_data_tbl, a0 out nocopy JTF_VARCHAR2_TABLE_100
    , a1 out nocopy JTF_VARCHAR2_TABLE_2000
    );

  procedure umx_process_reg_request(p0_a0 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a1 in out nocopy JTF_VARCHAR2_TABLE_2000
    , x_return_status out NOCOPY varchar2
 		, x_message_data out NOCOPY varchar2);

  procedure populate_reg_data(p0_a0 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a1 in out nocopy JTF_VARCHAR2_TABLE_2000
  );
  procedure assign_role(p0_a0 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a1 in out nocopy JTF_VARCHAR2_TABLE_2000
    , x_return_status out NOCOPY varchar2
 		, x_message_data out NOCOPY varchar2);
end umx_registration_pvt_w;

/
