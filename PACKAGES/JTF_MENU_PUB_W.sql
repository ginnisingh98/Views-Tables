--------------------------------------------------------
--  DDL for Package JTF_MENU_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_MENU_PUB_W" AUTHID CURRENT_USER as
  /* $Header: jtfmenws.pls 120.2 2005/10/25 05:23:56 psanyal ship $ */
  procedure rosetta_table_copy_in_p3(t OUT NOCOPY /* file.sql.39 change */ jtf_menu_pub.menu_table, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_300
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_VARCHAR2_TABLE_300
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_VARCHAR2_TABLE_300
    , a9 JTF_VARCHAR2_TABLE_100
    , a10 JTF_VARCHAR2_TABLE_100
    , a11 JTF_VARCHAR2_TABLE_100
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_VARCHAR2_TABLE_100
    , a14 JTF_NUMBER_TABLE
    , a15 JTF_DATE_TABLE
    , a16 JTF_VARCHAR2_TABLE_100
    , a17 JTF_VARCHAR2_TABLE_100
    , a18 JTF_VARCHAR2_TABLE_300
    );
  procedure rosetta_table_copy_out_p3(t jtf_menu_pub.menu_table, a0 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a1 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a2 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a3 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a4 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a5 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a6 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a7 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a8 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a9 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a10 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a11 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a12 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a13 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a14 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a15 OUT NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , a16 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a17 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a18 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    );

  procedure rosetta_table_copy_in_p4(t OUT NOCOPY /* file.sql.39 change */ jtf_menu_pub.number_table, a0 JTF_NUMBER_TABLE);
  procedure rosetta_table_copy_out_p4(t jtf_menu_pub.number_table, a0 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE);

  procedure rosetta_table_copy_in_p5(t OUT NOCOPY /* file.sql.39 change */ jtf_menu_pub.responsibility_table, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    );
  procedure rosetta_table_copy_out_p5(t jtf_menu_pub.responsibility_table, a0 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a1 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    );

  procedure get_excl_entire_menu_tree_tl(p_lang  VARCHAR2
    , p_respid  NUMBER
    , p_appid  NUMBER
    , p_max_depth  NUMBER
    , p4_a0 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p4_a1 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p5_a0 OUT NOCOPY /* file.sql.39 change */  NUMBER
    , p5_a1 OUT NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a2 OUT NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a3 OUT NOCOPY /* file.sql.39 change */  VARCHAR2
    , p6_a0 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p6_a1 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p6_a2 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p6_a3 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p6_a4 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p6_a5 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p6_a6 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p6_a7 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p6_a8 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p6_a9 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p6_a10 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p6_a11 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p6_a12 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p6_a13 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p6_a14 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p6_a15 OUT NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , p6_a16 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p6_a17 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p6_a18 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p_kids_menu_ids OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p8_a0 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p8_a1 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p8_a2 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p8_a3 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p8_a4 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p8_a5 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p8_a6 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p8_a7 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p8_a8 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p8_a9 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p8_a10 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p8_a11 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p8_a12 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p8_a13 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p8_a14 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p8_a15 OUT NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , p8_a16 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p8_a17 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p8_a18 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
  );
  procedure get_excluded_root_menu_tl(p_lang  VARCHAR2
    , p_respid  NUMBER
    , p_appid  NUMBER
    , p3_a0 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p3_a1 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p4_a0 OUT NOCOPY /* file.sql.39 change */  NUMBER
    , p4_a1 OUT NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a2 OUT NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a3 OUT NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a0 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p5_a1 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p5_a2 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p5_a3 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p5_a4 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p5_a5 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p5_a6 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p5_a7 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p5_a8 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p5_a9 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p5_a10 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p5_a11 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p5_a12 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p5_a13 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p5_a14 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p5_a15 OUT NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , p5_a16 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p5_a17 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p5_a18 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
  );
  procedure get_root_menu_tl(p_lang  VARCHAR2
    , p_respid  NUMBER
    , p_appid  NUMBER
    , p3_a0 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p3_a1 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p4_a0 OUT NOCOPY /* file.sql.39 change */  NUMBER
    , p4_a1 OUT NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a2 OUT NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a3 OUT NOCOPY /* file.sql.39 change */  VARCHAR2
    , p5_a0 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p5_a1 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p5_a2 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p5_a3 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p5_a4 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p5_a5 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p5_a6 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p5_a7 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p5_a8 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p5_a9 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p5_a10 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p5_a11 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p5_a12 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p5_a13 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p5_a14 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p5_a15 OUT NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , p5_a16 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p5_a17 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p5_a18 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
  );
  procedure get_root_menu(p_respid  NUMBER
    , p_appid  NUMBER
    , p2_a0 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p2_a1 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p3_a0 OUT NOCOPY /* file.sql.39 change */  NUMBER
    , p3_a1 OUT NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a2 OUT NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a3 OUT NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a0 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p4_a1 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p4_a2 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p4_a3 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p4_a4 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p4_a5 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p4_a6 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p4_a7 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p4_a8 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p4_a9 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p4_a10 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p4_a11 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p4_a12 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p4_a13 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p4_a14 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p4_a15 OUT NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , p4_a16 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p4_a17 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p4_a18 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
  );
  procedure get_excluded_menu_entries_tl(p_lang  VARCHAR2
    , p_menu_id  NUMBER
    , p_respid  NUMBER
    , p_appid  NUMBER
    , p4_a0 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p4_a1 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p4_a2 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p4_a3 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p4_a4 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p4_a5 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p4_a6 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p4_a7 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p4_a8 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p4_a9 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p4_a10 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p4_a11 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p4_a12 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p4_a13 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p4_a14 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p4_a15 OUT NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , p4_a16 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p4_a17 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p4_a18 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
  );
  procedure get_menu_entries_tl(p_lang  VARCHAR2
    , p_menu_id  NUMBER
    , p2_a0 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p2_a1 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p2_a2 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p2_a3 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p2_a4 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p2_a5 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p2_a6 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p2_a7 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p2_a8 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p2_a9 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p2_a10 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p2_a11 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p2_a12 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p2_a13 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p2_a14 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p2_a15 OUT NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , p2_a16 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p2_a17 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p2_a18 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
  );
  procedure get_menu_entries(p_menu_id  NUMBER
    , p1_a0 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p1_a1 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p1_a2 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p1_a3 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p1_a4 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p1_a5 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p1_a6 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p1_a7 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p1_a8 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p1_a9 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p1_a10 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p1_a11 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p1_a12 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p1_a13 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p1_a14 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p1_a15 OUT NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , p1_a16 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p1_a17 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p1_a18 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
  );
  procedure get_func_entries(p_menu_id  NUMBER
    , p1_a0 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p1_a1 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p1_a2 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p1_a3 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p1_a4 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p1_a5 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p1_a6 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p1_a7 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p1_a8 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p1_a9 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p1_a10 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p1_a11 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p1_a12 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p1_a13 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p1_a14 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p1_a15 OUT NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , p1_a16 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p1_a17 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p1_a18 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
  );
end jtf_menu_pub_w;

 

/
