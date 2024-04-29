--------------------------------------------------------
--  DDL for Package Body AS_SALES_LEAD_OWNER_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AS_SALES_LEAD_OWNER_W" as
  /* $Header: asxwslnb.pls 120.1 2005/06/23 15:45 appldev noship $ */
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

  procedure rosetta_table_copy_in_p1(t out nocopy as_sales_lead_owner.lead_owner_rec_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_DATE_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_DATE_TABLE
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_NUMBER_TABLE
    , a14 JTF_NUMBER_TABLE
    , a15 JTF_NUMBER_TABLE
    , a16 JTF_NUMBER_TABLE
    , a17 JTF_DATE_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count=0 then
    t := as_sales_lead_owner.lead_owner_rec_tbl_type();
  elsif a0 is not null and a0.count > 0 then
      if a0.count > 0 then
      t := as_sales_lead_owner.lead_owner_rec_tbl_type();
      t.extend(a0.count);
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).lead_owner_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).category := a1(indx);
          t(ddindx).country := a2(indx);
          t(ddindx).from_postal_code := a3(indx);
          t(ddindx).to_postal_code := a4(indx);
          t(ddindx).cm_resource_id := rosetta_g_miss_num_map(a5(indx));
          t(ddindx).referral_type := a6(indx);
          t(ddindx).owner_flag := a7(indx);
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a8(indx));
          t(ddindx).last_updated_by := rosetta_g_miss_num_map(a9(indx));
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a10(indx));
          t(ddindx).created_by := rosetta_g_miss_num_map(a11(indx));
          t(ddindx).last_update_login := rosetta_g_miss_num_map(a12(indx));
          t(ddindx).object_version_number := rosetta_g_miss_num_map(a13(indx));
          t(ddindx).request_id := rosetta_g_miss_num_map(a14(indx));
          t(ddindx).program_application_id := rosetta_g_miss_num_map(a15(indx));
          t(ddindx).program_id := rosetta_g_miss_num_map(a16(indx));
          t(ddindx).program_update_date := rosetta_g_miss_date_in_map(a17(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p1;
  procedure rosetta_table_copy_out_p1(t as_sales_lead_owner.lead_owner_rec_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    , a8 out nocopy JTF_DATE_TABLE
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_DATE_TABLE
    , a11 out nocopy JTF_NUMBER_TABLE
    , a12 out nocopy JTF_NUMBER_TABLE
    , a13 out nocopy JTF_NUMBER_TABLE
    , a14 out nocopy JTF_NUMBER_TABLE
    , a15 out nocopy JTF_NUMBER_TABLE
    , a16 out nocopy JTF_NUMBER_TABLE
    , a17 out nocopy JTF_DATE_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null then
    a0 := null;
    a1 := null;
    a2 := null;
    a3 := null;
    a4 := null;
    a5 := null;
    a6 := null;
    a7 := null;
    a8 := null;
    a9 := null;
    a10 := null;
    a11 := null;
    a12 := null;
    a13 := null;
    a14 := null;
    a15 := null;
    a16 := null;
    a17 := null;
  elsif t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_VARCHAR2_TABLE_100();
    a4 := JTF_VARCHAR2_TABLE_100();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_VARCHAR2_TABLE_100();
    a7 := JTF_VARCHAR2_TABLE_100();
    a8 := JTF_DATE_TABLE();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_DATE_TABLE();
    a11 := JTF_NUMBER_TABLE();
    a12 := JTF_NUMBER_TABLE();
    a13 := JTF_NUMBER_TABLE();
    a14 := JTF_NUMBER_TABLE();
    a15 := JTF_NUMBER_TABLE();
    a16 := JTF_NUMBER_TABLE();
    a17 := JTF_DATE_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_VARCHAR2_TABLE_100();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_VARCHAR2_TABLE_100();
      a7 := JTF_VARCHAR2_TABLE_100();
      a8 := JTF_DATE_TABLE();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_DATE_TABLE();
      a11 := JTF_NUMBER_TABLE();
      a12 := JTF_NUMBER_TABLE();
      a13 := JTF_NUMBER_TABLE();
      a14 := JTF_NUMBER_TABLE();
      a15 := JTF_NUMBER_TABLE();
      a16 := JTF_NUMBER_TABLE();
      a17 := JTF_DATE_TABLE();
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
        a13.extend(t.count);
        a14.extend(t.count);
        a15.extend(t.count);
        a16.extend(t.count);
        a17.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).lead_owner_id);
          a1(indx) := t(ddindx).category;
          a2(indx) := t(ddindx).country;
          a3(indx) := t(ddindx).from_postal_code;
          a4(indx) := t(ddindx).to_postal_code;
          a5(indx) := rosetta_g_miss_num_map(t(ddindx).cm_resource_id);
          a6(indx) := t(ddindx).referral_type;
          a7(indx) := t(ddindx).owner_flag;
          a8(indx) := t(ddindx).last_update_date;
          a9(indx) := rosetta_g_miss_num_map(t(ddindx).last_updated_by);
          a10(indx) := t(ddindx).creation_date;
          a11(indx) := rosetta_g_miss_num_map(t(ddindx).created_by);
          a12(indx) := rosetta_g_miss_num_map(t(ddindx).last_update_login);
          a13(indx) := rosetta_g_miss_num_map(t(ddindx).object_version_number);
          a14(indx) := rosetta_g_miss_num_map(t(ddindx).request_id);
          a15(indx) := rosetta_g_miss_num_map(t(ddindx).program_application_id);
          a16(indx) := rosetta_g_miss_num_map(t(ddindx).program_id);
          a17(indx) := t(ddindx).program_update_date;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p1;

  procedure create_lead_owner(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_lead_owner_id out nocopy  NUMBER
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  VARCHAR2 := fnd_api.g_miss_char
    , p7_a2  VARCHAR2 := fnd_api.g_miss_char
    , p7_a3  VARCHAR2 := fnd_api.g_miss_char
    , p7_a4  VARCHAR2 := fnd_api.g_miss_char
    , p7_a5  NUMBER := 0-1962.0724
    , p7_a6  VARCHAR2 := fnd_api.g_miss_char
    , p7_a7  VARCHAR2 := fnd_api.g_miss_char
    , p7_a8  DATE := fnd_api.g_miss_date
    , p7_a9  NUMBER := 0-1962.0724
    , p7_a10  DATE := fnd_api.g_miss_date
    , p7_a11  NUMBER := 0-1962.0724
    , p7_a12  NUMBER := 0-1962.0724
    , p7_a13  NUMBER := 0-1962.0724
    , p7_a14  NUMBER := 0-1962.0724
    , p7_a15  NUMBER := 0-1962.0724
    , p7_a16  NUMBER := 0-1962.0724
    , p7_a17  DATE := fnd_api.g_miss_date
  )

  as
    ddp_lead_owner_rec as_sales_lead_owner.lead_owner_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_lead_owner_rec.lead_owner_id := rosetta_g_miss_num_map(p7_a0);
    ddp_lead_owner_rec.category := p7_a1;
    ddp_lead_owner_rec.country := p7_a2;
    ddp_lead_owner_rec.from_postal_code := p7_a3;
    ddp_lead_owner_rec.to_postal_code := p7_a4;
    ddp_lead_owner_rec.cm_resource_id := rosetta_g_miss_num_map(p7_a5);
    ddp_lead_owner_rec.referral_type := p7_a6;
    ddp_lead_owner_rec.owner_flag := p7_a7;
    ddp_lead_owner_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a8);
    ddp_lead_owner_rec.last_updated_by := rosetta_g_miss_num_map(p7_a9);
    ddp_lead_owner_rec.creation_date := rosetta_g_miss_date_in_map(p7_a10);
    ddp_lead_owner_rec.created_by := rosetta_g_miss_num_map(p7_a11);
    ddp_lead_owner_rec.last_update_login := rosetta_g_miss_num_map(p7_a12);
    ddp_lead_owner_rec.object_version_number := rosetta_g_miss_num_map(p7_a13);
    ddp_lead_owner_rec.request_id := rosetta_g_miss_num_map(p7_a14);
    ddp_lead_owner_rec.program_application_id := rosetta_g_miss_num_map(p7_a15);
    ddp_lead_owner_rec.program_id := rosetta_g_miss_num_map(p7_a16);
    ddp_lead_owner_rec.program_update_date := rosetta_g_miss_date_in_map(p7_a17);


    -- here's the delegated call to the old PL/SQL routine
    as_sales_lead_owner.create_lead_owner(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_lead_owner_rec,
      x_lead_owner_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

  procedure update_lead_owner(p_api_version  NUMBER
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
    , p7_a4  VARCHAR2 := fnd_api.g_miss_char
    , p7_a5  NUMBER := 0-1962.0724
    , p7_a6  VARCHAR2 := fnd_api.g_miss_char
    , p7_a7  VARCHAR2 := fnd_api.g_miss_char
    , p7_a8  DATE := fnd_api.g_miss_date
    , p7_a9  NUMBER := 0-1962.0724
    , p7_a10  DATE := fnd_api.g_miss_date
    , p7_a11  NUMBER := 0-1962.0724
    , p7_a12  NUMBER := 0-1962.0724
    , p7_a13  NUMBER := 0-1962.0724
    , p7_a14  NUMBER := 0-1962.0724
    , p7_a15  NUMBER := 0-1962.0724
    , p7_a16  NUMBER := 0-1962.0724
    , p7_a17  DATE := fnd_api.g_miss_date
  )

  as
    ddp_lead_owner_rec as_sales_lead_owner.lead_owner_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_lead_owner_rec.lead_owner_id := rosetta_g_miss_num_map(p7_a0);
    ddp_lead_owner_rec.category := p7_a1;
    ddp_lead_owner_rec.country := p7_a2;
    ddp_lead_owner_rec.from_postal_code := p7_a3;
    ddp_lead_owner_rec.to_postal_code := p7_a4;
    ddp_lead_owner_rec.cm_resource_id := rosetta_g_miss_num_map(p7_a5);
    ddp_lead_owner_rec.referral_type := p7_a6;
    ddp_lead_owner_rec.owner_flag := p7_a7;
    ddp_lead_owner_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a8);
    ddp_lead_owner_rec.last_updated_by := rosetta_g_miss_num_map(p7_a9);
    ddp_lead_owner_rec.creation_date := rosetta_g_miss_date_in_map(p7_a10);
    ddp_lead_owner_rec.created_by := rosetta_g_miss_num_map(p7_a11);
    ddp_lead_owner_rec.last_update_login := rosetta_g_miss_num_map(p7_a12);
    ddp_lead_owner_rec.object_version_number := rosetta_g_miss_num_map(p7_a13);
    ddp_lead_owner_rec.request_id := rosetta_g_miss_num_map(p7_a14);
    ddp_lead_owner_rec.program_application_id := rosetta_g_miss_num_map(p7_a15);
    ddp_lead_owner_rec.program_id := rosetta_g_miss_num_map(p7_a16);
    ddp_lead_owner_rec.program_update_date := rosetta_g_miss_date_in_map(p7_a17);

    -- here's the delegated call to the old PL/SQL routine
    as_sales_lead_owner.update_lead_owner(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_lead_owner_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

  procedure get_salesreps(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_sales_lead_id  NUMBER
    , p5_a0 out nocopy JTF_NUMBER_TABLE
    , p5_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a5 out nocopy JTF_NUMBER_TABLE
    , p5_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a8 out nocopy JTF_DATE_TABLE
    , p5_a9 out nocopy JTF_NUMBER_TABLE
    , p5_a10 out nocopy JTF_DATE_TABLE
    , p5_a11 out nocopy JTF_NUMBER_TABLE
    , p5_a12 out nocopy JTF_NUMBER_TABLE
    , p5_a13 out nocopy JTF_NUMBER_TABLE
    , p5_a14 out nocopy JTF_NUMBER_TABLE
    , p5_a15 out nocopy JTF_NUMBER_TABLE
    , p5_a16 out nocopy JTF_NUMBER_TABLE
    , p5_a17 out nocopy JTF_DATE_TABLE
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddx_salesreps_tbl as_sales_lead_owner.lead_owner_rec_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any









    -- here's the delegated call to the old PL/SQL routine
    as_sales_lead_owner.get_salesreps(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      p_sales_lead_id,
      ddx_salesreps_tbl,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





    as_sales_lead_owner_w.rosetta_table_copy_out_p1(ddx_salesreps_tbl, p5_a0
      , p5_a1
      , p5_a2
      , p5_a3
      , p5_a4
      , p5_a5
      , p5_a6
      , p5_a7
      , p5_a8
      , p5_a9
      , p5_a10
      , p5_a11
      , p5_a12
      , p5_a13
      , p5_a14
      , p5_a15
      , p5_a16
      , p5_a17
      );



  end;

end as_sales_lead_owner_w;

/
