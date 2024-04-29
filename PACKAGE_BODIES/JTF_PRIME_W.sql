--------------------------------------------------------
--  DDL for Package Body JTF_PRIME_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_PRIME_W" as
  /* $Header: JTFPRMWB.pls 120.2 2005/11/28 22:22:44 skothe ship $ */
  rosetta_g_mistake_date date := to_date('01/01/+4713', 'MM/DD/SYYYY');
  rosetta_g_miss_date date := to_date('01/01/-4712', 'MM/DD/SYYYY');

  function rosetta_g_miss_num_map(n number) return number as
    a number := fnd_api.g_miss_num;
    b number := 0-1962.0724;
  begin
    if n=a then return b; end if;
    if n=b then return a; end if;
    return n;
  end;

  -- this is to workaround the JDBC bug regarding IN DATE of value GMiss
  function rosetta_g_miss_date_in_map(d date) return date as
  begin
    if d = rosetta_g_mistake_date then return fnd_api.g_miss_date; end if;
    return d;
  end;

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
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).n := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).d := rosetta_g_miss_date_in_map(a1(indx));
          t(ddindx).vc01 := a2(indx);
          t(ddindx).vc02 := a3(indx);
          t(ddindx).vc03 := a4(indx);
          t(ddindx).vc04 := a5(indx);
          t(ddindx).vc10 := a6(indx);
          t(ddindx).vc20 := a7(indx);
          t(ddindx).vc30 := a8(indx);
          t(ddindx).vc40 := a9(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p1;
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
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_DATE_TABLE();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_VARCHAR2_TABLE_200();
    a4 := JTF_VARCHAR2_TABLE_300();
    a5 := JTF_VARCHAR2_TABLE_400();
    a6 := JTF_VARCHAR2_TABLE_1000();
    a7 := JTF_VARCHAR2_TABLE_2000();
    a8 := JTF_VARCHAR2_TABLE_3000();
    a9 := JTF_VARCHAR2_TABLE_4000();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_DATE_TABLE();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_VARCHAR2_TABLE_200();
      a4 := JTF_VARCHAR2_TABLE_300();
      a5 := JTF_VARCHAR2_TABLE_400();
      a6 := JTF_VARCHAR2_TABLE_1000();
      a7 := JTF_VARCHAR2_TABLE_2000();
      a8 := JTF_VARCHAR2_TABLE_3000();
      a9 := JTF_VARCHAR2_TABLE_4000();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        a3.extend(t.count);
        a4.extend(t.count);
        a5.extend(t.count);
        a6.extend(t.count);
        a7.extend(t.count);
        a8.extend(t.count);
        a9.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).n);
          a1(indx) := t(ddindx).d;
          a2(indx) := t(ddindx).vc01;
          a3(indx) := t(ddindx).vc02;
          a4(indx) := t(ddindx).vc03;
          a5(indx) := t(ddindx).vc04;
          a6(indx) := t(ddindx).vc10;
          a7(indx) := t(ddindx).vc20;
          a8(indx) := t(ddindx).vc30;
          a9(indx) := t(ddindx).vc40;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p1;

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
  )
  as
    ddt jtf_prime.tab01;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    -- here's the delegated call to the old PL/SQL routine
    jtf_prime.proc1(ddt);

    -- copy data back from the local OUT or IN-OUT args, if any
    jtf_prime_w.rosetta_table_copy_out_p1(ddt, p0_a0
      , p0_a1
      , p0_a2
      , p0_a3
      , p0_a4
      , p0_a5
      , p0_a6
      , p0_a7
      , p0_a8
      , p0_a9
      );
  end;

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
  )
  as
    ddt jtf_prime.tab01;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    jtf_prime_w.rosetta_table_copy_in_p1(ddt, p0_a0
      , p0_a1
      , p0_a2
      , p0_a3
      , p0_a4
      , p0_a5
      , p0_a6
      , p0_a7
      , p0_a8
      , p0_a9
      );

    -- here's the delegated call to the old PL/SQL routine
    jtf_prime.proc2(ddt);

    -- copy data back from the local OUT or IN-OUT args, if any
    jtf_prime_w.rosetta_table_copy_out_p1(ddt, p0_a0
      , p0_a1
      , p0_a2
      , p0_a3
      , p0_a4
      , p0_a5
      , p0_a6
      , p0_a7
      , p0_a8
      , p0_a9
      );
  end;

end jtf_prime_w;

/
