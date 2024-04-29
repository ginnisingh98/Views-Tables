--------------------------------------------------------
--  DDL for Package Body AS_MULTI_CURRENCIES_PKG_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AS_MULTI_CURRENCIES_PKG_W" as
  /* $Header: asxwmcpb.pls 120.1 2005/06/24 22:26 appldev ship $ */
  rosetta_g_mistake_date date := to_date('01/01/+4713', 'MM/DD/SYYYY');
  rosetta_g_miss_date date := to_date('01/01/-4712', 'MM/DD/SYYYY');

  -- this is to workaround the JDBC bug regarding IN DATE of value GMiss
  function rosetta_g_miss_date_in_map(d date) return date as
  begin
    if d = rosetta_g_mistake_date then return fnd_api.g_miss_date; end if;
    return d;
  end;

  function rosetta_g_miss_num_map(n number) return number as
    a number := fnd_api.g_miss_num;
    b number := 0-1962.0724;
  begin
    if n=a then return b; end if;
    if n=b then return a; end if;
    return n;
  end;

  procedure rosetta_table_copy_in_p3(t out nocopy as_multi_currencies_pkg.type_mappings_tbl_type, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_DATE_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_DATE_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).period_set_name := a0(indx);
          t(ddindx).period_type := a1(indx);
          t(ddindx).conversion_type := a2(indx);
          t(ddindx).description := a3(indx);
          t(ddindx).updateable_flag := a4(indx);
          t(ddindx).deleteable_flag := a5(indx);
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a6(indx));
          t(ddindx).last_updated_by := rosetta_g_miss_num_map(a7(indx));
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a8(indx));
          t(ddindx).created_by := rosetta_g_miss_num_map(a9(indx));
          t(ddindx).last_update_login := rosetta_g_miss_num_map(a10(indx));
          t(ddindx).security_group_id := rosetta_g_miss_num_map(a11(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p3;
  procedure rosetta_table_copy_out_p3(t as_multi_currencies_pkg.type_mappings_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_100
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_DATE_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_DATE_TABLE
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_100();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_VARCHAR2_TABLE_100();
    a4 := JTF_VARCHAR2_TABLE_100();
    a5 := JTF_VARCHAR2_TABLE_100();
    a6 := JTF_DATE_TABLE();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_DATE_TABLE();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_NUMBER_TABLE();
    a11 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_VARCHAR2_TABLE_100();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_VARCHAR2_TABLE_100();
      a5 := JTF_VARCHAR2_TABLE_100();
      a6 := JTF_DATE_TABLE();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_DATE_TABLE();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_NUMBER_TABLE();
      a11 := JTF_NUMBER_TABLE();
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
        a10.extend(t.count);
        a11.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).period_set_name;
          a1(indx) := t(ddindx).period_type;
          a2(indx) := t(ddindx).conversion_type;
          a3(indx) := t(ddindx).description;
          a4(indx) := t(ddindx).updateable_flag;
          a5(indx) := t(ddindx).deleteable_flag;
          a6(indx) := t(ddindx).last_update_date;
          a7(indx) := rosetta_g_miss_num_map(t(ddindx).last_updated_by);
          a8(indx) := t(ddindx).creation_date;
          a9(indx) := rosetta_g_miss_num_map(t(ddindx).created_by);
          a10(indx) := rosetta_g_miss_num_map(t(ddindx).last_update_login);
          a11(indx) := rosetta_g_miss_num_map(t(ddindx).security_group_id);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p3;

  procedure rosetta_table_copy_in_p7(t out nocopy as_multi_currencies_pkg.period_rates_tbl_type, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_DATE_TABLE
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).from_currency := a0(indx);
          t(ddindx).to_currency := a1(indx);
          t(ddindx).conversion_date := rosetta_g_miss_date_in_map(a2(indx));
          t(ddindx).conversion_type := a3(indx);
          t(ddindx).conversion_rate := rosetta_g_miss_num_map(a4(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p7;
  procedure rosetta_table_copy_out_p7(t as_multi_currencies_pkg.period_rates_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_100
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_DATE_TABLE
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_100();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_DATE_TABLE();
    a3 := JTF_VARCHAR2_TABLE_100();
    a4 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_VARCHAR2_TABLE_100();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_DATE_TABLE();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_NUMBER_TABLE();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        a3.extend(t.count);
        a4.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).from_currency;
          a1(indx) := t(ddindx).to_currency;
          a2(indx) := t(ddindx).conversion_date;
          a3(indx) := t(ddindx).conversion_type;
          a4(indx) := rosetta_g_miss_num_map(t(ddindx).conversion_rate);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p7;

  procedure insert_type_mappings(p0_a0 JTF_VARCHAR2_TABLE_100
    , p0_a1 JTF_VARCHAR2_TABLE_100
    , p0_a2 JTF_VARCHAR2_TABLE_100
    , p0_a3 JTF_VARCHAR2_TABLE_100
    , p0_a4 JTF_VARCHAR2_TABLE_100
    , p0_a5 JTF_VARCHAR2_TABLE_100
    , p0_a6 JTF_DATE_TABLE
    , p0_a7 JTF_NUMBER_TABLE
    , p0_a8 JTF_DATE_TABLE
    , p0_a9 JTF_NUMBER_TABLE
    , p0_a10 JTF_NUMBER_TABLE
    , p0_a11 JTF_NUMBER_TABLE
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_type_mappings_tbl as_multi_currencies_pkg.type_mappings_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    as_multi_currencies_pkg_w.rosetta_table_copy_in_p3(ddp_type_mappings_tbl, p0_a0
      , p0_a1
      , p0_a2
      , p0_a3
      , p0_a4
      , p0_a5
      , p0_a6
      , p0_a7
      , p0_a8
      , p0_a9
      , p0_a10
      , p0_a11
      );




    -- here's the delegated call to the old PL/SQL routine
    as_multi_currencies_pkg.insert_type_mappings(ddp_type_mappings_tbl,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any



  end;

  procedure update_type_mappings(p0_a0 JTF_VARCHAR2_TABLE_100
    , p0_a1 JTF_VARCHAR2_TABLE_100
    , p0_a2 JTF_VARCHAR2_TABLE_100
    , p0_a3 JTF_VARCHAR2_TABLE_100
    , p0_a4 JTF_VARCHAR2_TABLE_100
    , p0_a5 JTF_VARCHAR2_TABLE_100
    , p0_a6 JTF_DATE_TABLE
    , p0_a7 JTF_NUMBER_TABLE
    , p0_a8 JTF_DATE_TABLE
    , p0_a9 JTF_NUMBER_TABLE
    , p0_a10 JTF_NUMBER_TABLE
    , p0_a11 JTF_NUMBER_TABLE
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_type_mappings_tbl as_multi_currencies_pkg.type_mappings_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    as_multi_currencies_pkg_w.rosetta_table_copy_in_p3(ddp_type_mappings_tbl, p0_a0
      , p0_a1
      , p0_a2
      , p0_a3
      , p0_a4
      , p0_a5
      , p0_a6
      , p0_a7
      , p0_a8
      , p0_a9
      , p0_a10
      , p0_a11
      );




    -- here's the delegated call to the old PL/SQL routine
    as_multi_currencies_pkg.update_type_mappings(ddp_type_mappings_tbl,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any



  end;

  procedure delete_type_mappings(p0_a0 JTF_VARCHAR2_TABLE_100
    , p0_a1 JTF_VARCHAR2_TABLE_100
    , p0_a2 JTF_VARCHAR2_TABLE_100
    , p0_a3 JTF_VARCHAR2_TABLE_100
    , p0_a4 JTF_VARCHAR2_TABLE_100
    , p0_a5 JTF_VARCHAR2_TABLE_100
    , p0_a6 JTF_DATE_TABLE
    , p0_a7 JTF_NUMBER_TABLE
    , p0_a8 JTF_DATE_TABLE
    , p0_a9 JTF_NUMBER_TABLE
    , p0_a10 JTF_NUMBER_TABLE
    , p0_a11 JTF_NUMBER_TABLE
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_type_mappings_tbl as_multi_currencies_pkg.type_mappings_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    as_multi_currencies_pkg_w.rosetta_table_copy_in_p3(ddp_type_mappings_tbl, p0_a0
      , p0_a1
      , p0_a2
      , p0_a3
      , p0_a4
      , p0_a5
      , p0_a6
      , p0_a7
      , p0_a8
      , p0_a9
      , p0_a10
      , p0_a11
      );




    -- here's the delegated call to the old PL/SQL routine
    as_multi_currencies_pkg.delete_type_mappings(ddp_type_mappings_tbl,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any



  end;

  procedure insert_period_rates(p0_a0 JTF_VARCHAR2_TABLE_100
    , p0_a1 JTF_VARCHAR2_TABLE_100
    , p0_a2 JTF_DATE_TABLE
    , p0_a3 JTF_VARCHAR2_TABLE_100
    , p0_a4 JTF_NUMBER_TABLE
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_period_rates_tbl as_multi_currencies_pkg.period_rates_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    as_multi_currencies_pkg_w.rosetta_table_copy_in_p7(ddp_period_rates_tbl, p0_a0
      , p0_a1
      , p0_a2
      , p0_a3
      , p0_a4
      );




    -- here's the delegated call to the old PL/SQL routine
    as_multi_currencies_pkg.insert_period_rates(ddp_period_rates_tbl,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any



  end;

  procedure update_period_rates(p0_a0 JTF_VARCHAR2_TABLE_100
    , p0_a1 JTF_VARCHAR2_TABLE_100
    , p0_a2 JTF_DATE_TABLE
    , p0_a3 JTF_VARCHAR2_TABLE_100
    , p0_a4 JTF_NUMBER_TABLE
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_period_rates_tbl as_multi_currencies_pkg.period_rates_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    as_multi_currencies_pkg_w.rosetta_table_copy_in_p7(ddp_period_rates_tbl, p0_a0
      , p0_a1
      , p0_a2
      , p0_a3
      , p0_a4
      );




    -- here's the delegated call to the old PL/SQL routine
    as_multi_currencies_pkg.update_period_rates(ddp_period_rates_tbl,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any



  end;

  procedure delete_period_rates(p0_a0 JTF_VARCHAR2_TABLE_100
    , p0_a1 JTF_VARCHAR2_TABLE_100
    , p0_a2 JTF_DATE_TABLE
    , p0_a3 JTF_VARCHAR2_TABLE_100
    , p0_a4 JTF_NUMBER_TABLE
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_period_rates_tbl as_multi_currencies_pkg.period_rates_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    as_multi_currencies_pkg_w.rosetta_table_copy_in_p7(ddp_period_rates_tbl, p0_a0
      , p0_a1
      , p0_a2
      , p0_a3
      , p0_a4
      );




    -- here's the delegated call to the old PL/SQL routine
    as_multi_currencies_pkg.delete_period_rates(ddp_period_rates_tbl,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any



  end;

end as_multi_currencies_pkg_w;

/
