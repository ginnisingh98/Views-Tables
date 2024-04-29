--------------------------------------------------------
--  DDL for Package FUN_SEQ_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FUN_SEQ_W" AUTHID CURRENT_USER as
  /* $Header: fun_seq_ws.pls 120.0 2003/09/11 21:34:04 masada noship $ */
  procedure rosetta_table_copy_in_p1(t out nocopy fun_seq.control_date_tbl_type, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_DATE_TABLE
    );
  procedure rosetta_table_copy_out_p1(t fun_seq.control_date_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_100
    , a1 out nocopy JTF_DATE_TABLE
    );

  procedure get_sequence_number(p_context_type  VARCHAR2
    , p_context_value  VARCHAR2
    , p_application_id  NUMBER
    , p_table_name  VARCHAR2
    , p_event_code  VARCHAR2
    , p5_a0  VARCHAR2
    , p5_a1  VARCHAR2
    , p5_a2  VARCHAR2
    , p5_a3  VARCHAR2
    , p5_a4  VARCHAR2
    , p5_a5  VARCHAR2
    , p6_a0 JTF_VARCHAR2_TABLE_100
    , p6_a1 JTF_DATE_TABLE
    , p_suppress_error  VARCHAR2
    , x_seq_version_id out nocopy  NUMBER
    , x_sequence_number out nocopy  NUMBER
    , x_assignment_id out nocopy  NUMBER
    , x_error_code out nocopy  VARCHAR2
  );
end fun_seq_w;

 

/
