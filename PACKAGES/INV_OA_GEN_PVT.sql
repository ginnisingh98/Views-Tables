--------------------------------------------------------
--  DDL for Package INV_OA_GEN_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_OA_GEN_PVT" AUTHID CURRENT_USER AS
  /* $Header: INVOAGES.pls 120.1 2005/10/10 07:18 methomas noship $ */
  -- Record Type for the lot number attributes columns
  TYPE assembly_lot_sel_rec_type IS RECORD
  (
-- Increased lot size to 80 Char - Mercy Thomas - B4625329
          Lot_number      VARCHAR2(80)    :=NULL
          , serial_number VARCHAR2(30)   :=NULL
  );
   -- Table type definition for an array of cb_chart_status_rec_type
   --   records.
  TYPE assembly_lot_sel_tbl_type is TABLE OF
  assembly_lot_sel_rec_type
    INDEX BY BINARY_INTEGER;

 PROCEDURE BUILD_ASSEMBLY_LOT_SERIAL_TBL(
          x_return_status out nocopy  VARCHAR2
	, x_msg_count out nocopy  NUMBER
        , x_msg_data out nocopy  VARCHAR2
        , p_assembly_lot_serial_tbl assembly_lot_sel_tbl_type
          );

  procedure rosetta_table_copy_in_p1(t out nocopy inv_oa_gen_pvt.assembly_lot_sel_tbl_type, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p1(t inv_oa_gen_pvt.assembly_lot_sel_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_100
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    );

  procedure build_assembly_lot_serial_tbl(x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p3_a0 JTF_VARCHAR2_TABLE_100
    , p3_a1 JTF_VARCHAR2_TABLE_100
  );

END INV_OA_GEN_PVT;

 

/
