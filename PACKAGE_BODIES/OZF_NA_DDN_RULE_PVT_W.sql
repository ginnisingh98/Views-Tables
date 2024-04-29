--------------------------------------------------------
--  DDL for Package Body OZF_NA_DDN_RULE_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_NA_DDN_RULE_PVT_W" as
  /* $Header: ozfwdnrb.pls 120.2 2006/02/25 19:23 julou noship $ */
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

  procedure rosetta_table_copy_in_p2(t out nocopy ozf_na_ddn_rule_pvt.na_ddn_rule_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_DATE_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_DATE_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_VARCHAR2_TABLE_4000
    , a12 JTF_VARCHAR2_TABLE_4000
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).na_deduction_rule_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).transaction_source_code := a1(indx);
          t(ddindx).transaction_type_code := a2(indx);
          t(ddindx).deduction_identifier_id := a3(indx);
          t(ddindx).deduction_identifier_org_id := rosetta_g_miss_num_map(a4(indx));
          t(ddindx).object_version_number := rosetta_g_miss_num_map(a5(indx));
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a6(indx));
          t(ddindx).created_by := rosetta_g_miss_num_map(a7(indx));
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a8(indx));
          t(ddindx).last_updated_by := rosetta_g_miss_num_map(a9(indx));
          t(ddindx).last_update_login := rosetta_g_miss_num_map(a10(indx));
          t(ddindx).name := a11(indx);
          t(ddindx).description := a12(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p2;
  procedure rosetta_table_copy_out_p2(t ozf_na_ddn_rule_pvt.na_ddn_rule_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_DATE_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_DATE_TABLE
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_VARCHAR2_TABLE_4000
    , a12 out nocopy JTF_VARCHAR2_TABLE_4000
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_VARCHAR2_TABLE_100();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_DATE_TABLE();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_DATE_TABLE();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_NUMBER_TABLE();
    a11 := JTF_VARCHAR2_TABLE_4000();
    a12 := JTF_VARCHAR2_TABLE_4000();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_DATE_TABLE();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_DATE_TABLE();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_NUMBER_TABLE();
      a11 := JTF_VARCHAR2_TABLE_4000();
      a12 := JTF_VARCHAR2_TABLE_4000();
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
        a12.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).na_deduction_rule_id);
          a1(indx) := t(ddindx).transaction_source_code;
          a2(indx) := t(ddindx).transaction_type_code;
          a3(indx) := t(ddindx).deduction_identifier_id;
          a4(indx) := rosetta_g_miss_num_map(t(ddindx).deduction_identifier_org_id);
          a5(indx) := rosetta_g_miss_num_map(t(ddindx).object_version_number);
          a6(indx) := t(ddindx).creation_date;
          a7(indx) := rosetta_g_miss_num_map(t(ddindx).created_by);
          a8(indx) := t(ddindx).last_update_date;
          a9(indx) := rosetta_g_miss_num_map(t(ddindx).last_updated_by);
          a10(indx) := rosetta_g_miss_num_map(t(ddindx).last_update_login);
          a11(indx) := t(ddindx).name;
          a12(indx) := t(ddindx).description;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p2;

  procedure create_na_ddn_rule(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_na_deduction_rule_id out nocopy  NUMBER
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  VARCHAR2 := fnd_api.g_miss_char
    , p7_a2  VARCHAR2 := fnd_api.g_miss_char
    , p7_a3  VARCHAR2 := fnd_api.g_miss_char
    , p7_a4  NUMBER := 0-1962.0724
    , p7_a5  NUMBER := 0-1962.0724
    , p7_a6  DATE := fnd_api.g_miss_date
    , p7_a7  NUMBER := 0-1962.0724
    , p7_a8  DATE := fnd_api.g_miss_date
    , p7_a9  NUMBER := 0-1962.0724
    , p7_a10  NUMBER := 0-1962.0724
    , p7_a11  VARCHAR2 := fnd_api.g_miss_char
    , p7_a12  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_na_ddn_rule_rec ozf_na_ddn_rule_pvt.na_ddn_rule_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_na_ddn_rule_rec.na_deduction_rule_id := rosetta_g_miss_num_map(p7_a0);
    ddp_na_ddn_rule_rec.transaction_source_code := p7_a1;
    ddp_na_ddn_rule_rec.transaction_type_code := p7_a2;
    ddp_na_ddn_rule_rec.deduction_identifier_id := p7_a3;
    ddp_na_ddn_rule_rec.deduction_identifier_org_id := rosetta_g_miss_num_map(p7_a4);
    ddp_na_ddn_rule_rec.object_version_number := rosetta_g_miss_num_map(p7_a5);
    ddp_na_ddn_rule_rec.creation_date := rosetta_g_miss_date_in_map(p7_a6);
    ddp_na_ddn_rule_rec.created_by := rosetta_g_miss_num_map(p7_a7);
    ddp_na_ddn_rule_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a8);
    ddp_na_ddn_rule_rec.last_updated_by := rosetta_g_miss_num_map(p7_a9);
    ddp_na_ddn_rule_rec.last_update_login := rosetta_g_miss_num_map(p7_a10);
    ddp_na_ddn_rule_rec.name := p7_a11;
    ddp_na_ddn_rule_rec.description := p7_a12;


    -- here's the delegated call to the old PL/SQL routine
    ozf_na_ddn_rule_pvt.create_na_ddn_rule(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_na_ddn_rule_rec,
      x_na_deduction_rule_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

  procedure update_na_ddn_rule(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  VARCHAR2 := fnd_api.g_miss_char
    , p7_a2  VARCHAR2 := fnd_api.g_miss_char
    , p7_a3  VARCHAR2 := fnd_api.g_miss_char
    , p7_a4  NUMBER := 0-1962.0724
    , p7_a5  NUMBER := 0-1962.0724
    , p7_a6  DATE := fnd_api.g_miss_date
    , p7_a7  NUMBER := 0-1962.0724
    , p7_a8  DATE := fnd_api.g_miss_date
    , p7_a9  NUMBER := 0-1962.0724
    , p7_a10  NUMBER := 0-1962.0724
    , p7_a11  VARCHAR2 := fnd_api.g_miss_char
    , p7_a12  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_na_ddn_rule_rec ozf_na_ddn_rule_pvt.na_ddn_rule_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_na_ddn_rule_rec.na_deduction_rule_id := rosetta_g_miss_num_map(p7_a0);
    ddp_na_ddn_rule_rec.transaction_source_code := p7_a1;
    ddp_na_ddn_rule_rec.transaction_type_code := p7_a2;
    ddp_na_ddn_rule_rec.deduction_identifier_id := p7_a3;
    ddp_na_ddn_rule_rec.deduction_identifier_org_id := rosetta_g_miss_num_map(p7_a4);
    ddp_na_ddn_rule_rec.object_version_number := rosetta_g_miss_num_map(p7_a5);
    ddp_na_ddn_rule_rec.creation_date := rosetta_g_miss_date_in_map(p7_a6);
    ddp_na_ddn_rule_rec.created_by := rosetta_g_miss_num_map(p7_a7);
    ddp_na_ddn_rule_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a8);
    ddp_na_ddn_rule_rec.last_updated_by := rosetta_g_miss_num_map(p7_a9);
    ddp_na_ddn_rule_rec.last_update_login := rosetta_g_miss_num_map(p7_a10);
    ddp_na_ddn_rule_rec.name := p7_a11;
    ddp_na_ddn_rule_rec.description := p7_a12;

    -- here's the delegated call to the old PL/SQL routine
    ozf_na_ddn_rule_pvt.update_na_ddn_rule(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_na_ddn_rule_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

  procedure validate_na_ddn_rule(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , p_validation_mode  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p3_a0  NUMBER := 0-1962.0724
    , p3_a1  VARCHAR2 := fnd_api.g_miss_char
    , p3_a2  VARCHAR2 := fnd_api.g_miss_char
    , p3_a3  VARCHAR2 := fnd_api.g_miss_char
    , p3_a4  NUMBER := 0-1962.0724
    , p3_a5  NUMBER := 0-1962.0724
    , p3_a6  DATE := fnd_api.g_miss_date
    , p3_a7  NUMBER := 0-1962.0724
    , p3_a8  DATE := fnd_api.g_miss_date
    , p3_a9  NUMBER := 0-1962.0724
    , p3_a10  NUMBER := 0-1962.0724
    , p3_a11  VARCHAR2 := fnd_api.g_miss_char
    , p3_a12  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_na_ddn_rule_rec ozf_na_ddn_rule_pvt.na_ddn_rule_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    ddp_na_ddn_rule_rec.na_deduction_rule_id := rosetta_g_miss_num_map(p3_a0);
    ddp_na_ddn_rule_rec.transaction_source_code := p3_a1;
    ddp_na_ddn_rule_rec.transaction_type_code := p3_a2;
    ddp_na_ddn_rule_rec.deduction_identifier_id := p3_a3;
    ddp_na_ddn_rule_rec.deduction_identifier_org_id := rosetta_g_miss_num_map(p3_a4);
    ddp_na_ddn_rule_rec.object_version_number := rosetta_g_miss_num_map(p3_a5);
    ddp_na_ddn_rule_rec.creation_date := rosetta_g_miss_date_in_map(p3_a6);
    ddp_na_ddn_rule_rec.created_by := rosetta_g_miss_num_map(p3_a7);
    ddp_na_ddn_rule_rec.last_update_date := rosetta_g_miss_date_in_map(p3_a8);
    ddp_na_ddn_rule_rec.last_updated_by := rosetta_g_miss_num_map(p3_a9);
    ddp_na_ddn_rule_rec.last_update_login := rosetta_g_miss_num_map(p3_a10);
    ddp_na_ddn_rule_rec.name := p3_a11;
    ddp_na_ddn_rule_rec.description := p3_a12;





    -- here's the delegated call to the old PL/SQL routine
    ozf_na_ddn_rule_pvt.validate_na_ddn_rule(p_api_version_number,
      p_init_msg_list,
      p_validation_level,
      ddp_na_ddn_rule_rec,
      p_validation_mode,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

  procedure check_na_ddn_rule_items(p_validation_mode  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , p0_a0  NUMBER := 0-1962.0724
    , p0_a1  VARCHAR2 := fnd_api.g_miss_char
    , p0_a2  VARCHAR2 := fnd_api.g_miss_char
    , p0_a3  VARCHAR2 := fnd_api.g_miss_char
    , p0_a4  NUMBER := 0-1962.0724
    , p0_a5  NUMBER := 0-1962.0724
    , p0_a6  DATE := fnd_api.g_miss_date
    , p0_a7  NUMBER := 0-1962.0724
    , p0_a8  DATE := fnd_api.g_miss_date
    , p0_a9  NUMBER := 0-1962.0724
    , p0_a10  NUMBER := 0-1962.0724
    , p0_a11  VARCHAR2 := fnd_api.g_miss_char
    , p0_a12  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_na_ddn_rule_rec ozf_na_ddn_rule_pvt.na_ddn_rule_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_na_ddn_rule_rec.na_deduction_rule_id := rosetta_g_miss_num_map(p0_a0);
    ddp_na_ddn_rule_rec.transaction_source_code := p0_a1;
    ddp_na_ddn_rule_rec.transaction_type_code := p0_a2;
    ddp_na_ddn_rule_rec.deduction_identifier_id := p0_a3;
    ddp_na_ddn_rule_rec.deduction_identifier_org_id := rosetta_g_miss_num_map(p0_a4);
    ddp_na_ddn_rule_rec.object_version_number := rosetta_g_miss_num_map(p0_a5);
    ddp_na_ddn_rule_rec.creation_date := rosetta_g_miss_date_in_map(p0_a6);
    ddp_na_ddn_rule_rec.created_by := rosetta_g_miss_num_map(p0_a7);
    ddp_na_ddn_rule_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a8);
    ddp_na_ddn_rule_rec.last_updated_by := rosetta_g_miss_num_map(p0_a9);
    ddp_na_ddn_rule_rec.last_update_login := rosetta_g_miss_num_map(p0_a10);
    ddp_na_ddn_rule_rec.name := p0_a11;
    ddp_na_ddn_rule_rec.description := p0_a12;



    -- here's the delegated call to the old PL/SQL routine
    ozf_na_ddn_rule_pvt.check_na_ddn_rule_items(ddp_na_ddn_rule_rec,
      p_validation_mode,
      x_return_status);

    -- copy data back from the local variables to OUT or IN-OUT args, if any


  end;

  procedure validate_na_ddn_rule_rec(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  VARCHAR2 := fnd_api.g_miss_char
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  DATE := fnd_api.g_miss_date
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  DATE := fnd_api.g_miss_date
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  NUMBER := 0-1962.0724
    , p5_a11  VARCHAR2 := fnd_api.g_miss_char
    , p5_a12  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_na_ddn_rule_rec ozf_na_ddn_rule_pvt.na_ddn_rule_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_na_ddn_rule_rec.na_deduction_rule_id := rosetta_g_miss_num_map(p5_a0);
    ddp_na_ddn_rule_rec.transaction_source_code := p5_a1;
    ddp_na_ddn_rule_rec.transaction_type_code := p5_a2;
    ddp_na_ddn_rule_rec.deduction_identifier_id := p5_a3;
    ddp_na_ddn_rule_rec.deduction_identifier_org_id := rosetta_g_miss_num_map(p5_a4);
    ddp_na_ddn_rule_rec.object_version_number := rosetta_g_miss_num_map(p5_a5);
    ddp_na_ddn_rule_rec.creation_date := rosetta_g_miss_date_in_map(p5_a6);
    ddp_na_ddn_rule_rec.created_by := rosetta_g_miss_num_map(p5_a7);
    ddp_na_ddn_rule_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a8);
    ddp_na_ddn_rule_rec.last_updated_by := rosetta_g_miss_num_map(p5_a9);
    ddp_na_ddn_rule_rec.last_update_login := rosetta_g_miss_num_map(p5_a10);
    ddp_na_ddn_rule_rec.name := p5_a11;
    ddp_na_ddn_rule_rec.description := p5_a12;

    -- here's the delegated call to the old PL/SQL routine
    ozf_na_ddn_rule_pvt.validate_na_ddn_rule_rec(p_api_version_number,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_na_ddn_rule_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

end ozf_na_ddn_rule_pvt_w;

/
