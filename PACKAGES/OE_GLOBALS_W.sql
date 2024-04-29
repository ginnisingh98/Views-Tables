--------------------------------------------------------
--  DDL for Package OE_GLOBALS_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_GLOBALS_W" AUTHID CURRENT_USER as
  /* $Header: OERSGLBS.pls 120.0 2005/05/31 23:36:07 appldev noship $ */
  procedure rosetta_table_copy_in_p199(t out NOCOPY /* file.sql.39 change */ oe_globals.line_id_list, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    );
  procedure rosetta_table_copy_out_p199(t oe_globals.line_id_list, a0 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a1 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    );

  procedure rosetta_table_copy_in_p222(t out NOCOPY /* file.sql.39 change */ oe_globals.index_tbl_type, a0 JTF_NUMBER_TABLE);
  procedure rosetta_table_copy_out_p222(t oe_globals.index_tbl_type, a0 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE);

  procedure rosetta_table_copy_in_p226(t out NOCOPY /* file.sql.39 change */ oe_globals.oe_audit_trail_history_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p226(t oe_globals.oe_audit_trail_history_tbl, a0 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a1 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a2 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    );

  procedure rosetta_table_copy_in_p228(t out NOCOPY /* file.sql.39 change */ oe_globals.boolean_tbl_type, a0 JTF_NUMBER_TABLE);
  procedure rosetta_table_copy_out_p228(t oe_globals.boolean_tbl_type, a0 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE);

  procedure rosetta_table_copy_in_p229(t out NOCOPY /* file.sql.39 change */ oe_globals.number_tbl_type, a0 JTF_NUMBER_TABLE);
  procedure rosetta_table_copy_out_p229(t oe_globals.number_tbl_type, a0 out NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE);

  procedure rosetta_table_copy_in_p232(t out NOCOPY /* file.sql.39 change */ oe_globals.access_list, a0 JTF_VARCHAR2_TABLE_100);
  procedure rosetta_table_copy_out_p232(t oe_globals.access_list, a0 out NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100);

  procedure equal(p_attribute1  NUMBER
    , p_attribute2  NUMBER
    , ddrosetta_retval_bool OUT NOCOPY /* file.sql.39 change */ NUMBER
  );
  procedure equal(p_attribute1  VARCHAR2
    , p_attribute2  VARCHAR2
    , ddrosetta_retval_bool OUT NOCOPY /* file.sql.39 change */ NUMBER
  );
  procedure equal(p_attribute1  date
    , p_attribute2  date
    , ddrosetta_retval_bool OUT NOCOPY /* file.sql.39 change */ NUMBER
  );
end oe_globals_w;

 

/
