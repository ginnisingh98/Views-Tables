--------------------------------------------------------
--  DDL for Package JTF_PRIME_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_PRIME_W" AUTHID CURRENT_USER as
  /* $Header: JTFPRMWS.pls 120.2 2006/02/12 21:36:10 skothe ship $ */
  procedure rosetta_table_copy_in_p1(t OUT NOCOPY /* file.sql.39 change */ jtf_prime.tab01, a0 JTF_NUMBER_TABLE
    , a1 JTF_DATE_TABLE
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_VARCHAR2_TABLE_200
    , a4 JTF_VARCHAR2_TABLE_300
    , a5 JTF_VARCHAR2_TABLE_400
    , a6 JTF_VARCHAR2_TABLE_1000
    , a7 JTF_VARCHAR2_TABLE_2000
    , a8 JTF_VARCHAR2_TABLE_3000
    , a9 JTF_VARCHAR2_TABLE_4000
    );
  procedure rosetta_table_copy_out_p1(t jtf_prime.tab01, a0 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , a1 OUT NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , a2 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , a3 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_200
    , a4 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , a5 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_400
    , a6 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_1000
    , a7 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_2000
    , a8 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_3000
    , a9 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_4000
    );

  procedure proc1(p0_a0 OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p0_a1 OUT NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , p0_a2 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p0_a3 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_200
    , p0_a4 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p0_a5 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_400
    , p0_a6 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_1000
    , p0_a7 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_2000
    , p0_a8 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_3000
    , p0_a9 OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_4000
  );
  procedure proc2(p0_a0 IN OUT NOCOPY /* file.sql.39 change */ JTF_NUMBER_TABLE
    , p0_a1 IN OUT NOCOPY /* file.sql.39 change */ JTF_DATE_TABLE
    , p0_a2 IN OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_100
    , p0_a3 IN OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_200
    , p0_a4 IN OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_300
    , p0_a5 IN OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_400
    , p0_a6 IN OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_1000
    , p0_a7 IN OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_2000
    , p0_a8 IN OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_3000
    , p0_a9 IN OUT NOCOPY /* file.sql.39 change */ JTF_VARCHAR2_TABLE_4000
  );
end jtf_prime_w;

 

/
