--------------------------------------------------------
--  DDL for Package Body AMS_REL_ITEM_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_REL_ITEM_PVT_W" as
  /* $Header: amswritb.pls 120.1 2005/06/28 16:14 appldev ship $ */
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

  procedure rosetta_table_copy_in_p3(t out nocopy ams_rel_item_pvt.rel_item_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_DATE_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_DATE_TABLE
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_DATE_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).inventory_item_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).organization_id := rosetta_g_miss_num_map(a1(indx));
          t(ddindx).related_item_id := rosetta_g_miss_num_map(a2(indx));
          t(ddindx).relationship_type_id := rosetta_g_miss_num_map(a3(indx));
          t(ddindx).reciprocal_flag := a4(indx);
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a5(indx));
          t(ddindx).last_updated_by := rosetta_g_miss_num_map(a6(indx));
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a7(indx));
          t(ddindx).created_by := rosetta_g_miss_num_map(a8(indx));
          t(ddindx).last_update_login := rosetta_g_miss_num_map(a9(indx));
          t(ddindx).request_id := rosetta_g_miss_num_map(a10(indx));
          t(ddindx).program_application_id := rosetta_g_miss_num_map(a11(indx));
          t(ddindx).program_id := rosetta_g_miss_num_map(a12(indx));
          t(ddindx).program_update_date := rosetta_g_miss_date_in_map(a13(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p3;
  procedure rosetta_table_copy_out_p3(t ams_rel_item_pvt.rel_item_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_DATE_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_DATE_TABLE
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_NUMBER_TABLE
    , a12 out nocopy JTF_NUMBER_TABLE
    , a13 out nocopy JTF_DATE_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_VARCHAR2_TABLE_100();
    a5 := JTF_DATE_TABLE();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_DATE_TABLE();
    a8 := JTF_NUMBER_TABLE();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_NUMBER_TABLE();
    a11 := JTF_NUMBER_TABLE();
    a12 := JTF_NUMBER_TABLE();
    a13 := JTF_DATE_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_VARCHAR2_TABLE_100();
      a5 := JTF_DATE_TABLE();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_DATE_TABLE();
      a8 := JTF_NUMBER_TABLE();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_NUMBER_TABLE();
      a11 := JTF_NUMBER_TABLE();
      a12 := JTF_NUMBER_TABLE();
      a13 := JTF_DATE_TABLE();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).inventory_item_id);
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).organization_id);
          a2(indx) := rosetta_g_miss_num_map(t(ddindx).related_item_id);
          a3(indx) := rosetta_g_miss_num_map(t(ddindx).relationship_type_id);
          a4(indx) := t(ddindx).reciprocal_flag;
          a5(indx) := t(ddindx).last_update_date;
          a6(indx) := rosetta_g_miss_num_map(t(ddindx).last_updated_by);
          a7(indx) := t(ddindx).creation_date;
          a8(indx) := rosetta_g_miss_num_map(t(ddindx).created_by);
          a9(indx) := rosetta_g_miss_num_map(t(ddindx).last_update_login);
          a10(indx) := rosetta_g_miss_num_map(t(ddindx).request_id);
          a11(indx) := rosetta_g_miss_num_map(t(ddindx).program_application_id);
          a12(indx) := rosetta_g_miss_num_map(t(ddindx).program_id);
          a13(indx) := t(ddindx).program_update_date;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p3;

  procedure create_rel_item(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  NUMBER := 0-1962.0724
    , p7_a2  NUMBER := 0-1962.0724
    , p7_a3  NUMBER := 0-1962.0724
    , p7_a4  VARCHAR2 := fnd_api.g_miss_char
    , p7_a5  DATE := fnd_api.g_miss_date
    , p7_a6  NUMBER := 0-1962.0724
    , p7_a7  DATE := fnd_api.g_miss_date
    , p7_a8  NUMBER := 0-1962.0724
    , p7_a9  NUMBER := 0-1962.0724
    , p7_a10  NUMBER := 0-1962.0724
    , p7_a11  NUMBER := 0-1962.0724
    , p7_a12  NUMBER := 0-1962.0724
    , p7_a13  DATE := fnd_api.g_miss_date
  )

  as
    ddp_rel_item_rec ams_rel_item_pvt.rel_item_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_rel_item_rec.inventory_item_id := rosetta_g_miss_num_map(p7_a0);
    ddp_rel_item_rec.organization_id := rosetta_g_miss_num_map(p7_a1);
    ddp_rel_item_rec.related_item_id := rosetta_g_miss_num_map(p7_a2);
    ddp_rel_item_rec.relationship_type_id := rosetta_g_miss_num_map(p7_a3);
    ddp_rel_item_rec.reciprocal_flag := p7_a4;
    ddp_rel_item_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a5);
    ddp_rel_item_rec.last_updated_by := rosetta_g_miss_num_map(p7_a6);
    ddp_rel_item_rec.creation_date := rosetta_g_miss_date_in_map(p7_a7);
    ddp_rel_item_rec.created_by := rosetta_g_miss_num_map(p7_a8);
    ddp_rel_item_rec.last_update_login := rosetta_g_miss_num_map(p7_a9);
    ddp_rel_item_rec.request_id := rosetta_g_miss_num_map(p7_a10);
    ddp_rel_item_rec.program_application_id := rosetta_g_miss_num_map(p7_a11);
    ddp_rel_item_rec.program_id := rosetta_g_miss_num_map(p7_a12);
    ddp_rel_item_rec.program_update_date := rosetta_g_miss_date_in_map(p7_a13);

    -- here's the delegated call to the old PL/SQL routine
    ams_rel_item_pvt.create_rel_item(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_rel_item_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

  procedure update_rel_item(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  NUMBER := 0-1962.0724
    , p7_a2  NUMBER := 0-1962.0724
    , p7_a3  NUMBER := 0-1962.0724
    , p7_a4  VARCHAR2 := fnd_api.g_miss_char
    , p7_a5  DATE := fnd_api.g_miss_date
    , p7_a6  NUMBER := 0-1962.0724
    , p7_a7  DATE := fnd_api.g_miss_date
    , p7_a8  NUMBER := 0-1962.0724
    , p7_a9  NUMBER := 0-1962.0724
    , p7_a10  NUMBER := 0-1962.0724
    , p7_a11  NUMBER := 0-1962.0724
    , p7_a12  NUMBER := 0-1962.0724
    , p7_a13  DATE := fnd_api.g_miss_date
  )

  as
    ddp_rel_item_rec ams_rel_item_pvt.rel_item_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_rel_item_rec.inventory_item_id := rosetta_g_miss_num_map(p7_a0);
    ddp_rel_item_rec.organization_id := rosetta_g_miss_num_map(p7_a1);
    ddp_rel_item_rec.related_item_id := rosetta_g_miss_num_map(p7_a2);
    ddp_rel_item_rec.relationship_type_id := rosetta_g_miss_num_map(p7_a3);
    ddp_rel_item_rec.reciprocal_flag := p7_a4;
    ddp_rel_item_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a5);
    ddp_rel_item_rec.last_updated_by := rosetta_g_miss_num_map(p7_a6);
    ddp_rel_item_rec.creation_date := rosetta_g_miss_date_in_map(p7_a7);
    ddp_rel_item_rec.created_by := rosetta_g_miss_num_map(p7_a8);
    ddp_rel_item_rec.last_update_login := rosetta_g_miss_num_map(p7_a9);
    ddp_rel_item_rec.request_id := rosetta_g_miss_num_map(p7_a10);
    ddp_rel_item_rec.program_application_id := rosetta_g_miss_num_map(p7_a11);
    ddp_rel_item_rec.program_id := rosetta_g_miss_num_map(p7_a12);
    ddp_rel_item_rec.program_update_date := rosetta_g_miss_date_in_map(p7_a13);

    -- here's the delegated call to the old PL/SQL routine
    ams_rel_item_pvt.update_rel_item(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_rel_item_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

  procedure delete_rel_item(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  NUMBER := 0-1962.0724
    , p7_a2  NUMBER := 0-1962.0724
    , p7_a3  NUMBER := 0-1962.0724
    , p7_a4  VARCHAR2 := fnd_api.g_miss_char
    , p7_a5  DATE := fnd_api.g_miss_date
    , p7_a6  NUMBER := 0-1962.0724
    , p7_a7  DATE := fnd_api.g_miss_date
    , p7_a8  NUMBER := 0-1962.0724
    , p7_a9  NUMBER := 0-1962.0724
    , p7_a10  NUMBER := 0-1962.0724
    , p7_a11  NUMBER := 0-1962.0724
    , p7_a12  NUMBER := 0-1962.0724
    , p7_a13  DATE := fnd_api.g_miss_date
  )

  as
    ddp_rel_item_rec ams_rel_item_pvt.rel_item_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_rel_item_rec.inventory_item_id := rosetta_g_miss_num_map(p7_a0);
    ddp_rel_item_rec.organization_id := rosetta_g_miss_num_map(p7_a1);
    ddp_rel_item_rec.related_item_id := rosetta_g_miss_num_map(p7_a2);
    ddp_rel_item_rec.relationship_type_id := rosetta_g_miss_num_map(p7_a3);
    ddp_rel_item_rec.reciprocal_flag := p7_a4;
    ddp_rel_item_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a5);
    ddp_rel_item_rec.last_updated_by := rosetta_g_miss_num_map(p7_a6);
    ddp_rel_item_rec.creation_date := rosetta_g_miss_date_in_map(p7_a7);
    ddp_rel_item_rec.created_by := rosetta_g_miss_num_map(p7_a8);
    ddp_rel_item_rec.last_update_login := rosetta_g_miss_num_map(p7_a9);
    ddp_rel_item_rec.request_id := rosetta_g_miss_num_map(p7_a10);
    ddp_rel_item_rec.program_application_id := rosetta_g_miss_num_map(p7_a11);
    ddp_rel_item_rec.program_id := rosetta_g_miss_num_map(p7_a12);
    ddp_rel_item_rec.program_update_date := rosetta_g_miss_date_in_map(p7_a13);

    -- here's the delegated call to the old PL/SQL routine
    ams_rel_item_pvt.delete_rel_item(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_rel_item_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

  procedure validate_rel_item_rec(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  DATE := fnd_api.g_miss_date
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  DATE := fnd_api.g_miss_date
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  NUMBER := 0-1962.0724
    , p5_a11  NUMBER := 0-1962.0724
    , p5_a12  NUMBER := 0-1962.0724
    , p5_a13  DATE := fnd_api.g_miss_date
  )

  as
    ddp_rel_item_rec ams_rel_item_pvt.rel_item_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_rel_item_rec.inventory_item_id := rosetta_g_miss_num_map(p5_a0);
    ddp_rel_item_rec.organization_id := rosetta_g_miss_num_map(p5_a1);
    ddp_rel_item_rec.related_item_id := rosetta_g_miss_num_map(p5_a2);
    ddp_rel_item_rec.relationship_type_id := rosetta_g_miss_num_map(p5_a3);
    ddp_rel_item_rec.reciprocal_flag := p5_a4;
    ddp_rel_item_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a5);
    ddp_rel_item_rec.last_updated_by := rosetta_g_miss_num_map(p5_a6);
    ddp_rel_item_rec.creation_date := rosetta_g_miss_date_in_map(p5_a7);
    ddp_rel_item_rec.created_by := rosetta_g_miss_num_map(p5_a8);
    ddp_rel_item_rec.last_update_login := rosetta_g_miss_num_map(p5_a9);
    ddp_rel_item_rec.request_id := rosetta_g_miss_num_map(p5_a10);
    ddp_rel_item_rec.program_application_id := rosetta_g_miss_num_map(p5_a11);
    ddp_rel_item_rec.program_id := rosetta_g_miss_num_map(p5_a12);
    ddp_rel_item_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a13);

    -- here's the delegated call to the old PL/SQL routine
    ams_rel_item_pvt.validate_rel_item_rec(p_api_version_number,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_rel_item_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure validate_rel_item(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p3_a0  NUMBER := 0-1962.0724
    , p3_a1  NUMBER := 0-1962.0724
    , p3_a2  NUMBER := 0-1962.0724
    , p3_a3  NUMBER := 0-1962.0724
    , p3_a4  VARCHAR2 := fnd_api.g_miss_char
    , p3_a5  DATE := fnd_api.g_miss_date
    , p3_a6  NUMBER := 0-1962.0724
    , p3_a7  DATE := fnd_api.g_miss_date
    , p3_a8  NUMBER := 0-1962.0724
    , p3_a9  NUMBER := 0-1962.0724
    , p3_a10  NUMBER := 0-1962.0724
    , p3_a11  NUMBER := 0-1962.0724
    , p3_a12  NUMBER := 0-1962.0724
    , p3_a13  DATE := fnd_api.g_miss_date
  )

  as
    ddp_rel_item_rec ams_rel_item_pvt.rel_item_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    ddp_rel_item_rec.inventory_item_id := rosetta_g_miss_num_map(p3_a0);
    ddp_rel_item_rec.organization_id := rosetta_g_miss_num_map(p3_a1);
    ddp_rel_item_rec.related_item_id := rosetta_g_miss_num_map(p3_a2);
    ddp_rel_item_rec.relationship_type_id := rosetta_g_miss_num_map(p3_a3);
    ddp_rel_item_rec.reciprocal_flag := p3_a4;
    ddp_rel_item_rec.last_update_date := rosetta_g_miss_date_in_map(p3_a5);
    ddp_rel_item_rec.last_updated_by := rosetta_g_miss_num_map(p3_a6);
    ddp_rel_item_rec.creation_date := rosetta_g_miss_date_in_map(p3_a7);
    ddp_rel_item_rec.created_by := rosetta_g_miss_num_map(p3_a8);
    ddp_rel_item_rec.last_update_login := rosetta_g_miss_num_map(p3_a9);
    ddp_rel_item_rec.request_id := rosetta_g_miss_num_map(p3_a10);
    ddp_rel_item_rec.program_application_id := rosetta_g_miss_num_map(p3_a11);
    ddp_rel_item_rec.program_id := rosetta_g_miss_num_map(p3_a12);
    ddp_rel_item_rec.program_update_date := rosetta_g_miss_date_in_map(p3_a13);




    -- here's the delegated call to the old PL/SQL routine
    ams_rel_item_pvt.validate_rel_item(p_api_version_number,
      p_init_msg_list,
      p_validation_level,
      ddp_rel_item_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






  end;

end ams_rel_item_pvt_w;

/
