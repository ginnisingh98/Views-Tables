--------------------------------------------------------
--  DDL for Package JTF_DPF_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_DPF_W" AUTHID CURRENT_USER as
  /* $Header: jtfdpws.pls 120.2 2005/10/25 05:19:31 psanyal ship $ */
  procedure rosetta_table_copy_in_p9(t OUT NOCOPY /* file.sql.39 change */ jtf_dpf.new_rule_param_tbl, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p9(t jtf_dpf.new_rule_param_tbl, a0 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a1 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a2 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    );

  procedure rosetta_table_copy_in_p11(t OUT NOCOPY /* file.sql.39 change */ jtf_dpf.new_phys_non_def_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    );
  procedure rosetta_table_copy_out_p11(t jtf_dpf.new_phys_non_def_tbl, a0 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a1 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    );

  procedure rosetta_table_copy_in_p13(t OUT NOCOPY /* file.sql.39 change */ jtf_dpf.new_next_log_non_def_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    );
  procedure rosetta_table_copy_out_p13(t jtf_dpf.new_next_log_non_def_tbl, a0 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a1 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    );

  procedure rosetta_table_copy_in_p15(t OUT NOCOPY /* file.sql.39 change */ jtf_dpf.new_phys_attribs_tbl, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_VARCHAR2_TABLE_300
    );
  procedure rosetta_table_copy_out_p15(t jtf_dpf.new_phys_attribs_tbl, a0 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a1 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    );

  procedure rosetta_table_copy_in_p16(t OUT NOCOPY /* file.sql.39 change */ jtf_dpf.dpf_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_VARCHAR2_TABLE_200
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_VARCHAR2_TABLE_100
    , a10 JTF_VARCHAR2_TABLE_100
    , a11 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p16(t jtf_dpf.dpf_tbl, a0 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a1 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a2 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a3 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a4 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a5 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a6 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_200
    , a7 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a8 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a9 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a10 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a11 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    );

  procedure rosetta_table_copy_in_p17(t OUT NOCOPY /* file.sql.39 change */ jtf_dpf.logical_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_VARCHAR2_TABLE_200
    , a5 JTF_VARCHAR2_TABLE_300
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p17(t jtf_dpf.logical_tbl, a0 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a1 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a2 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a3 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a4 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_200
    , a5 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a6 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a7 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a8 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    );

  procedure rosetta_table_copy_in_p18(t OUT NOCOPY /* file.sql.39 change */ jtf_dpf.physical_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p18(t jtf_dpf.physical_tbl, a0 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a1 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a2 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    );

  procedure rosetta_table_copy_in_p19(t OUT NOCOPY /* file.sql.39 change */ jtf_dpf.physical_non_default_tbl, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p19(t jtf_dpf.physical_non_default_tbl, a0 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a1 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a2 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a3 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a4 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a5 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a6 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    );

  procedure rosetta_table_copy_in_p20(t OUT NOCOPY /* file.sql.39 change */ jtf_dpf.rule_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p20(t jtf_dpf.rule_tbl, a0 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a1 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a2 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a3 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a4 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a5 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    );

  procedure rosetta_table_copy_in_p21(t OUT NOCOPY /* file.sql.39 change */ jtf_dpf.next_logical_default_tbl, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p21(t jtf_dpf.next_logical_default_tbl, a0 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a1 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a2 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a3 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a4 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a5 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    );

  procedure rosetta_table_copy_in_p22(t OUT NOCOPY /* file.sql.39 change */ jtf_dpf.next_logical_non_default_tbl, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p22(t jtf_dpf.next_logical_non_default_tbl, a0 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a1 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a2 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a3 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a4 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a5 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a6 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a7 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    );

  procedure rosetta_table_copy_in_p23(t OUT NOCOPY /* file.sql.39 change */ jtf_dpf.physical_attribs_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_300
    );
  procedure rosetta_table_copy_out_p23(t jtf_dpf.physical_attribs_tbl, a0 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a1 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a2 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    );

  procedure get(asn  VARCHAR2
    , p_lang IN OUT NOCOPY /* file.sql.39 change */  VARCHAR2
    , descrs_only  number
    , p3_a0 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p3_a1 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p3_a2 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p3_a3 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p3_a4 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p3_a5 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p3_a6 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_200
    , p3_a7 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p3_a8 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p3_a9 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p3_a10 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p3_a11 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p4_a0 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p4_a1 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p4_a2 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p4_a3 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p4_a4 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_200
    , p4_a5 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p4_a6 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p4_a7 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p4_a8 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p5_a0 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p5_a1 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p5_a2 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p6_a0 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p6_a1 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p6_a2 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p6_a3 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p6_a4 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p6_a5 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p6_a6 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p7_a0 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p7_a1 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p7_a2 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p7_a3 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p7_a4 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p7_a5 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p8_a0 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p8_a1 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p8_a2 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p8_a3 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p8_a4 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p8_a5 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p9_a0 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p9_a1 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p9_a2 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p9_a3 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p9_a4 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p9_a5 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p9_a6 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p9_a7 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p10_a0 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p10_a1 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p10_a2 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
  );
  function rule_update(p_rule_id  NUMBER
    , p1_a0  VARCHAR2 := fnd_api.g_miss_char
    , p1_a1  VARCHAR2 := fnd_api.g_miss_char
    , p1_a2  VARCHAR2 := fnd_api.g_miss_char
  ) return number;
  function rule_new(p_asn  VARCHAR2
    , p_name  VARCHAR2
    , p_descr  VARCHAR2
    , p3_a0 JTF_VARCHAR2_TABLE_100
    , p3_a1 JTF_VARCHAR2_TABLE_100
    , p3_a2 JTF_VARCHAR2_TABLE_100
  ) return number;
  procedure rule_set_params(p_rule_id  NUMBER
    , p1_a0 JTF_VARCHAR2_TABLE_100
    , p1_a1 JTF_VARCHAR2_TABLE_100
    , p1_a2 JTF_VARCHAR2_TABLE_100
  );
  function phys_update(p_ppid  NUMBER
    , p1_a0  VARCHAR2 := fnd_api.g_miss_char
    , p1_a1  VARCHAR2 := fnd_api.g_miss_char
    , p1_a2  VARCHAR2 := fnd_api.g_miss_char
  ) return number;
  procedure phys_attribs_update(p_ppid  NUMBER
    , p1_a0 JTF_VARCHAR2_TABLE_100
    , p1_a1 JTF_VARCHAR2_TABLE_300
  );
  function flow_update(p_logical_flow_id  NUMBER
    , p1_a0  VARCHAR2 := fnd_api.g_miss_char
    , p1_a1  VARCHAR2 := fnd_api.g_miss_char
    , p1_a2  VARCHAR2 := fnd_api.g_miss_char
    , p1_a3  VARCHAR2 := fnd_api.g_miss_char
    , p1_a4  VARCHAR2 := fnd_api.g_miss_char
    , p1_a5  VARCHAR2 := fnd_api.g_miss_char
    , p1_a6  NUMBER := 0-1962.0724
    , p1_a7  NUMBER := 0-1962.0724
  ) return number;
  function logical_update(p_logical_page_id  NUMBER
    , p1_a0  VARCHAR2 := fnd_api.g_miss_char
    , p1_a1  VARCHAR2 := fnd_api.g_miss_char
    , p1_a2  VARCHAR2 := fnd_api.g_miss_char
    , p1_a3  VARCHAR2 := fnd_api.g_miss_char
    , p1_a4  VARCHAR2 := fnd_api.g_miss_char
    , p1_a5  VARCHAR2 := fnd_api.g_miss_char
    , p1_a6  NUMBER := 0-1962.0724
  ) return number;
  procedure logical_set_non_default_phys(p_logical_page_id  NUMBER
    , p1_a0 JTF_NUMBER_TABLE
    , p1_a1 JTF_NUMBER_TABLE
  );
  procedure next_logical_set_non_default(p_flow_id  NUMBER
    , p_log_page_id  NUMBER
    , p2_a0 JTF_NUMBER_TABLE
    , p2_a1 JTF_NUMBER_TABLE
  );
end jtf_dpf_w;

 

/
