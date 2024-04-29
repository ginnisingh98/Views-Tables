--------------------------------------------------------
--  DDL for Package IGS_EN_DASHBOARD_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_EN_DASHBOARD_W" AUTHID CURRENT_USER as
  /* $Header: IGSENB3S.pls 120.0 2005/09/13 09:56:04 appldev noship $ */
  procedure rosetta_table_copy_in_p0(t out nocopy igs_en_dashboard.link_text_type, a0 JTF_VARCHAR2_TABLE_200);
  procedure rosetta_table_copy_out_p0(t igs_en_dashboard.link_text_type, a0 out nocopy JTF_VARCHAR2_TABLE_200);

  procedure rosetta_table_copy_in_p1(t out nocopy igs_en_dashboard.cal_type, a0 JTF_VARCHAR2_TABLE_100);
  procedure rosetta_table_copy_out_p1(t igs_en_dashboard.cal_type, a0 out nocopy JTF_VARCHAR2_TABLE_100);

  procedure rosetta_table_copy_in_p2(t out nocopy igs_en_dashboard.seq_num_type, a0 JTF_NUMBER_TABLE);
  procedure rosetta_table_copy_out_p2(t igs_en_dashboard.seq_num_type, a0 out nocopy JTF_NUMBER_TABLE);

  procedure rosetta_table_copy_in_p3(t out nocopy igs_en_dashboard.prg_car_type, a0 JTF_VARCHAR2_TABLE_100);
  procedure rosetta_table_copy_out_p3(t igs_en_dashboard.prg_car_type, a0 out nocopy JTF_VARCHAR2_TABLE_100);

  procedure rosetta_table_copy_in_p4(t out nocopy igs_en_dashboard.plan_sched_type, a0 JTF_VARCHAR2_TABLE_100);
  procedure rosetta_table_copy_out_p4(t igs_en_dashboard.plan_sched_type, a0 out nocopy JTF_VARCHAR2_TABLE_100);

  procedure student_api(p_n_person_id  NUMBER
    , p_c_person_type  VARCHAR2
    , p_text_tbl out nocopy JTF_VARCHAR2_TABLE_200
    , p_cal_tbl out nocopy JTF_VARCHAR2_TABLE_100
    , p_seq_tbl out nocopy JTF_NUMBER_TABLE
    , p_car_tbl out nocopy JTF_VARCHAR2_TABLE_100
    , p_typ_tbl out nocopy JTF_VARCHAR2_TABLE_100
    , p_sch_allow out nocopy  VARCHAR2
  );
end igs_en_dashboard_w;

 

/
