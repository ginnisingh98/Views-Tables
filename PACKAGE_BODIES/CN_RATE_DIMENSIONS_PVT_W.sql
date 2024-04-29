--------------------------------------------------------
--  DDL for Package Body CN_RATE_DIMENSIONS_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_RATE_DIMENSIONS_PVT_W" as
  /* $Header: cnwrdimb.pls 120.3 2006/01/18 15:30 jxsingh ship $ */
  procedure rosetta_table_copy_in_p1(t out nocopy cn_rate_dimensions_pvt.tiers_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_VARCHAR2_TABLE_1000
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).rate_dim_tier_id := a0(indx);
          t(ddindx).minimum_amount := a1(indx);
          t(ddindx).maximum_amount := a2(indx);
          t(ddindx).min_exp_id := a3(indx);
          t(ddindx).max_exp_id := a4(indx);
          t(ddindx).string_value := a5(indx);
          t(ddindx).tier_sequence := a6(indx);
          t(ddindx).object_version_number := a7(indx);
          t(ddindx).tier_description := a8(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p1;
  procedure rosetta_table_copy_out_p1(t cn_rate_dimensions_pvt.tiers_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_VARCHAR2_TABLE_1000
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_VARCHAR2_TABLE_100();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_VARCHAR2_TABLE_1000();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_VARCHAR2_TABLE_100();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_VARCHAR2_TABLE_1000();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).rate_dim_tier_id;
          a1(indx) := t(ddindx).minimum_amount;
          a2(indx) := t(ddindx).maximum_amount;
          a3(indx) := t(ddindx).min_exp_id;
          a4(indx) := t(ddindx).max_exp_id;
          a5(indx) := t(ddindx).string_value;
          a6(indx) := t(ddindx).tier_sequence;
          a7(indx) := t(ddindx).object_version_number;
          a8(indx) := t(ddindx).tier_description;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p1;

  procedure rosetta_table_copy_in_p2(t out nocopy cn_rate_dimensions_pvt.parent_rate_tables_tbl_type, a0 JTF_VARCHAR2_TABLE_100) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx) := a0(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p2;
  procedure rosetta_table_copy_out_p2(t cn_rate_dimensions_pvt.parent_rate_tables_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_100) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_VARCHAR2_TABLE_100();
      if t.count > 0 then
        a0.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p2;

  procedure create_dimension(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_name  VARCHAR2
    , p_description  VARCHAR2
    , p_dim_unit_code  VARCHAR2
    , p_number_tier  NUMBER
    , p8_a0 JTF_NUMBER_TABLE
    , p8_a1 JTF_NUMBER_TABLE
    , p8_a2 JTF_NUMBER_TABLE
    , p8_a3 JTF_NUMBER_TABLE
    , p8_a4 JTF_NUMBER_TABLE
    , p8_a5 JTF_VARCHAR2_TABLE_100
    , p8_a6 JTF_NUMBER_TABLE
    , p8_a7 JTF_NUMBER_TABLE
    , p8_a8 JTF_VARCHAR2_TABLE_1000
    , p_org_id  NUMBER
    , x_rate_dimension_id in out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_tiers_tbl cn_rate_dimensions_pvt.tiers_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any








    cn_rate_dimensions_pvt_w.rosetta_table_copy_in_p1(ddp_tiers_tbl, p8_a0
      , p8_a1
      , p8_a2
      , p8_a3
      , p8_a4
      , p8_a5
      , p8_a6
      , p8_a7
      , p8_a8
      );






    -- here's the delegated call to the old PL/SQL routine
    cn_rate_dimensions_pvt.create_dimension(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      p_name,
      p_description,
      p_dim_unit_code,
      p_number_tier,
      ddp_tiers_tbl,
      p_org_id,
      x_rate_dimension_id,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any













  end;

  procedure update_dimension(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_rate_dimension_id  NUMBER
    , p_name  VARCHAR2
    , p_description  VARCHAR2
    , p_dim_unit_code  VARCHAR2
    , p_number_tier  NUMBER
    , p9_a0 JTF_NUMBER_TABLE
    , p9_a1 JTF_NUMBER_TABLE
    , p9_a2 JTF_NUMBER_TABLE
    , p9_a3 JTF_NUMBER_TABLE
    , p9_a4 JTF_NUMBER_TABLE
    , p9_a5 JTF_VARCHAR2_TABLE_100
    , p9_a6 JTF_NUMBER_TABLE
    , p9_a7 JTF_NUMBER_TABLE
    , p9_a8 JTF_VARCHAR2_TABLE_1000
    , p_org_id  NUMBER
    , p_object_version_number in out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_tiers_tbl cn_rate_dimensions_pvt.tiers_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any









    cn_rate_dimensions_pvt_w.rosetta_table_copy_in_p1(ddp_tiers_tbl, p9_a0
      , p9_a1
      , p9_a2
      , p9_a3
      , p9_a4
      , p9_a5
      , p9_a6
      , p9_a7
      , p9_a8
      );






    -- here's the delegated call to the old PL/SQL routine
    cn_rate_dimensions_pvt.update_dimension(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      p_rate_dimension_id,
      p_name,
      p_description,
      p_dim_unit_code,
      p_number_tier,
      ddp_tiers_tbl,
      p_org_id,
      p_object_version_number,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any














  end;

end cn_rate_dimensions_pvt_w;

/
