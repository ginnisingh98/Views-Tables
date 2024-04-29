--------------------------------------------------------
--  DDL for Package Body AMS_DMLIFT_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_DMLIFT_PVT_W" as
  /* $Header: amswdlfb.pls 120.1 2005/06/15 23:58:23 appldev  $ */
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

  procedure rosetta_table_copy_in_p3(t OUT NOCOPY ams_dmlift_pvt.lift_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_DATE_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_DATE_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_NUMBER_TABLE
    , a14 JTF_NUMBER_TABLE
    , a15 JTF_NUMBER_TABLE
    , a16 JTF_NUMBER_TABLE
    , a17 JTF_NUMBER_TABLE
    , a18 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).lift_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a1(indx));
          t(ddindx).last_updated_by := rosetta_g_miss_num_map(a2(indx));
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a3(indx));
          t(ddindx).created_by := rosetta_g_miss_num_map(a4(indx));
          t(ddindx).last_update_login := rosetta_g_miss_num_map(a5(indx));
          t(ddindx).object_version_number := rosetta_g_miss_num_map(a6(indx));
          t(ddindx).model_id := rosetta_g_miss_num_map(a7(indx));
          t(ddindx).quantile := rosetta_g_miss_num_map(a8(indx));
          t(ddindx).lift := rosetta_g_miss_num_map(a9(indx));
          t(ddindx).targets := rosetta_g_miss_num_map(a10(indx));
          t(ddindx).non_targets := rosetta_g_miss_num_map(a11(indx));
          t(ddindx).targets_cumm := rosetta_g_miss_num_map(a12(indx));
          t(ddindx).target_density_cumm := rosetta_g_miss_num_map(a13(indx));
          t(ddindx).target_density := rosetta_g_miss_num_map(a14(indx));
          t(ddindx).margin := rosetta_g_miss_num_map(a15(indx));
          t(ddindx).roi := rosetta_g_miss_num_map(a16(indx));
          t(ddindx).target_confidence := rosetta_g_miss_num_map(a17(indx));
          t(ddindx).non_target_confidence := rosetta_g_miss_num_map(a18(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p3;
  procedure rosetta_table_copy_out_p3(t ams_dmlift_pvt.lift_tbl_type, a0 OUT NOCOPY JTF_NUMBER_TABLE
    , a1 OUT NOCOPY JTF_DATE_TABLE
    , a2 OUT NOCOPY JTF_NUMBER_TABLE
    , a3 OUT NOCOPY JTF_DATE_TABLE
    , a4 OUT NOCOPY JTF_NUMBER_TABLE
    , a5 OUT NOCOPY JTF_NUMBER_TABLE
    , a6 OUT NOCOPY JTF_NUMBER_TABLE
    , a7 OUT NOCOPY JTF_NUMBER_TABLE
    , a8 OUT NOCOPY JTF_NUMBER_TABLE
    , a9 OUT NOCOPY JTF_NUMBER_TABLE
    , a10 OUT NOCOPY JTF_NUMBER_TABLE
    , a11 OUT NOCOPY JTF_NUMBER_TABLE
    , a12 OUT NOCOPY JTF_NUMBER_TABLE
    , a13 OUT NOCOPY JTF_NUMBER_TABLE
    , a14 OUT NOCOPY JTF_NUMBER_TABLE
    , a15 OUT NOCOPY JTF_NUMBER_TABLE
    , a16 OUT NOCOPY JTF_NUMBER_TABLE
    , a17 OUT NOCOPY JTF_NUMBER_TABLE
    , a18 OUT NOCOPY JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_DATE_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_DATE_TABLE();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_NUMBER_TABLE();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_NUMBER_TABLE();
    a11 := JTF_NUMBER_TABLE();
    a12 := JTF_NUMBER_TABLE();
    a13 := JTF_NUMBER_TABLE();
    a14 := JTF_NUMBER_TABLE();
    a15 := JTF_NUMBER_TABLE();
    a16 := JTF_NUMBER_TABLE();
    a17 := JTF_NUMBER_TABLE();
    a18 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_DATE_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_DATE_TABLE();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_NUMBER_TABLE();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_NUMBER_TABLE();
      a11 := JTF_NUMBER_TABLE();
      a12 := JTF_NUMBER_TABLE();
      a13 := JTF_NUMBER_TABLE();
      a14 := JTF_NUMBER_TABLE();
      a15 := JTF_NUMBER_TABLE();
      a16 := JTF_NUMBER_TABLE();
      a17 := JTF_NUMBER_TABLE();
      a18 := JTF_NUMBER_TABLE();
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
        a18.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).lift_id);
          a1(indx) := t(ddindx).last_update_date;
          a2(indx) := rosetta_g_miss_num_map(t(ddindx).last_updated_by);
          a3(indx) := t(ddindx).creation_date;
          a4(indx) := rosetta_g_miss_num_map(t(ddindx).created_by);
          a5(indx) := rosetta_g_miss_num_map(t(ddindx).last_update_login);
          a6(indx) := rosetta_g_miss_num_map(t(ddindx).object_version_number);
          a7(indx) := rosetta_g_miss_num_map(t(ddindx).model_id);
          a8(indx) := rosetta_g_miss_num_map(t(ddindx).quantile);
          a9(indx) := rosetta_g_miss_num_map(t(ddindx).lift);
          a10(indx) := rosetta_g_miss_num_map(t(ddindx).targets);
          a11(indx) := rosetta_g_miss_num_map(t(ddindx).non_targets);
          a12(indx) := rosetta_g_miss_num_map(t(ddindx).targets_cumm);
          a13(indx) := rosetta_g_miss_num_map(t(ddindx).target_density_cumm);
          a14(indx) := rosetta_g_miss_num_map(t(ddindx).target_density);
          a15(indx) := rosetta_g_miss_num_map(t(ddindx).margin);
          a16(indx) := rosetta_g_miss_num_map(t(ddindx).roi);
          a17(indx) := rosetta_g_miss_num_map(t(ddindx).target_confidence);
          a18(indx) := rosetta_g_miss_num_map(t(ddindx).non_target_confidence);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p3;

  procedure check_lift_items(p_validation_mode  VARCHAR2
    , x_return_status OUT NOCOPY  VARCHAR2
    , p0_a0  NUMBER := 0-1962.0724
    , p0_a1  DATE := fnd_api.g_miss_date
    , p0_a2  NUMBER := 0-1962.0724
    , p0_a3  DATE := fnd_api.g_miss_date
    , p0_a4  NUMBER := 0-1962.0724
    , p0_a5  NUMBER := 0-1962.0724
    , p0_a6  NUMBER := 0-1962.0724
    , p0_a7  NUMBER := 0-1962.0724
    , p0_a8  NUMBER := 0-1962.0724
    , p0_a9  NUMBER := 0-1962.0724
    , p0_a10  NUMBER := 0-1962.0724
    , p0_a11  NUMBER := 0-1962.0724
    , p0_a12  NUMBER := 0-1962.0724
    , p0_a13  NUMBER := 0-1962.0724
    , p0_a14  NUMBER := 0-1962.0724
    , p0_a15  NUMBER := 0-1962.0724
    , p0_a16  NUMBER := 0-1962.0724
    , p0_a17  NUMBER := 0-1962.0724
    , p0_a18  NUMBER := 0-1962.0724
  )
  as
    ddp_lift_rec ams_dmlift_pvt.lift_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_lift_rec.lift_id := rosetta_g_miss_num_map(p0_a0);
    ddp_lift_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a1);
    ddp_lift_rec.last_updated_by := rosetta_g_miss_num_map(p0_a2);
    ddp_lift_rec.creation_date := rosetta_g_miss_date_in_map(p0_a3);
    ddp_lift_rec.created_by := rosetta_g_miss_num_map(p0_a4);
    ddp_lift_rec.last_update_login := rosetta_g_miss_num_map(p0_a5);
    ddp_lift_rec.object_version_number := rosetta_g_miss_num_map(p0_a6);
    ddp_lift_rec.model_id := rosetta_g_miss_num_map(p0_a7);
    ddp_lift_rec.quantile := rosetta_g_miss_num_map(p0_a8);
    ddp_lift_rec.lift := rosetta_g_miss_num_map(p0_a9);
    ddp_lift_rec.targets := rosetta_g_miss_num_map(p0_a10);
    ddp_lift_rec.non_targets := rosetta_g_miss_num_map(p0_a11);
    ddp_lift_rec.targets_cumm := rosetta_g_miss_num_map(p0_a12);
    ddp_lift_rec.target_density_cumm := rosetta_g_miss_num_map(p0_a13);
    ddp_lift_rec.target_density := rosetta_g_miss_num_map(p0_a14);
    ddp_lift_rec.margin := rosetta_g_miss_num_map(p0_a15);
    ddp_lift_rec.roi := rosetta_g_miss_num_map(p0_a16);
    ddp_lift_rec.target_confidence := rosetta_g_miss_num_map(p0_a17);
    ddp_lift_rec.non_target_confidence := rosetta_g_miss_num_map(p0_a18);



    -- here's the delegated call to the old PL/SQL routine
    ams_dmlift_pvt.check_lift_items(ddp_lift_rec,
      p_validation_mode,
      x_return_status);

    -- copy data back from the local OUT or IN-OUT args, if any


  end;

  procedure create_lift(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status OUT NOCOPY  VARCHAR2
    , x_msg_count OUT NOCOPY  NUMBER
    , x_msg_data OUT NOCOPY  VARCHAR2
    , x_lift_id OUT NOCOPY  NUMBER
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  DATE := fnd_api.g_miss_date
    , p7_a2  NUMBER := 0-1962.0724
    , p7_a3  DATE := fnd_api.g_miss_date
    , p7_a4  NUMBER := 0-1962.0724
    , p7_a5  NUMBER := 0-1962.0724
    , p7_a6  NUMBER := 0-1962.0724
    , p7_a7  NUMBER := 0-1962.0724
    , p7_a8  NUMBER := 0-1962.0724
    , p7_a9  NUMBER := 0-1962.0724
    , p7_a10  NUMBER := 0-1962.0724
    , p7_a11  NUMBER := 0-1962.0724
    , p7_a12  NUMBER := 0-1962.0724
    , p7_a13  NUMBER := 0-1962.0724
    , p7_a14  NUMBER := 0-1962.0724
    , p7_a15  NUMBER := 0-1962.0724
    , p7_a16  NUMBER := 0-1962.0724
    , p7_a17  NUMBER := 0-1962.0724
    , p7_a18  NUMBER := 0-1962.0724
  )
  as
    ddp_lift_rec ams_dmlift_pvt.lift_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_lift_rec.lift_id := rosetta_g_miss_num_map(p7_a0);
    ddp_lift_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a1);
    ddp_lift_rec.last_updated_by := rosetta_g_miss_num_map(p7_a2);
    ddp_lift_rec.creation_date := rosetta_g_miss_date_in_map(p7_a3);
    ddp_lift_rec.created_by := rosetta_g_miss_num_map(p7_a4);
    ddp_lift_rec.last_update_login := rosetta_g_miss_num_map(p7_a5);
    ddp_lift_rec.object_version_number := rosetta_g_miss_num_map(p7_a6);
    ddp_lift_rec.model_id := rosetta_g_miss_num_map(p7_a7);
    ddp_lift_rec.quantile := rosetta_g_miss_num_map(p7_a8);
    ddp_lift_rec.lift := rosetta_g_miss_num_map(p7_a9);
    ddp_lift_rec.targets := rosetta_g_miss_num_map(p7_a10);
    ddp_lift_rec.non_targets := rosetta_g_miss_num_map(p7_a11);
    ddp_lift_rec.targets_cumm := rosetta_g_miss_num_map(p7_a12);
    ddp_lift_rec.target_density_cumm := rosetta_g_miss_num_map(p7_a13);
    ddp_lift_rec.target_density := rosetta_g_miss_num_map(p7_a14);
    ddp_lift_rec.margin := rosetta_g_miss_num_map(p7_a15);
    ddp_lift_rec.roi := rosetta_g_miss_num_map(p7_a16);
    ddp_lift_rec.target_confidence := rosetta_g_miss_num_map(p7_a17);
    ddp_lift_rec.non_target_confidence := rosetta_g_miss_num_map(p7_a18);


    -- here's the delegated call to the old PL/SQL routine
    ams_dmlift_pvt.create_lift(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_lift_rec,
      x_lift_id);

    -- copy data back from the local OUT or IN-OUT args, if any








  end;

  procedure update_lift(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status OUT NOCOPY  VARCHAR2
    , x_msg_count OUT NOCOPY  NUMBER
    , x_msg_data OUT NOCOPY  VARCHAR2
    , x_object_version_number OUT NOCOPY  NUMBER
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  DATE := fnd_api.g_miss_date
    , p7_a2  NUMBER := 0-1962.0724
    , p7_a3  DATE := fnd_api.g_miss_date
    , p7_a4  NUMBER := 0-1962.0724
    , p7_a5  NUMBER := 0-1962.0724
    , p7_a6  NUMBER := 0-1962.0724
    , p7_a7  NUMBER := 0-1962.0724
    , p7_a8  NUMBER := 0-1962.0724
    , p7_a9  NUMBER := 0-1962.0724
    , p7_a10  NUMBER := 0-1962.0724
    , p7_a11  NUMBER := 0-1962.0724
    , p7_a12  NUMBER := 0-1962.0724
    , p7_a13  NUMBER := 0-1962.0724
    , p7_a14  NUMBER := 0-1962.0724
    , p7_a15  NUMBER := 0-1962.0724
    , p7_a16  NUMBER := 0-1962.0724
    , p7_a17  NUMBER := 0-1962.0724
    , p7_a18  NUMBER := 0-1962.0724
  )
  as
    ddp_lift_rec ams_dmlift_pvt.lift_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_lift_rec.lift_id := rosetta_g_miss_num_map(p7_a0);
    ddp_lift_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a1);
    ddp_lift_rec.last_updated_by := rosetta_g_miss_num_map(p7_a2);
    ddp_lift_rec.creation_date := rosetta_g_miss_date_in_map(p7_a3);
    ddp_lift_rec.created_by := rosetta_g_miss_num_map(p7_a4);
    ddp_lift_rec.last_update_login := rosetta_g_miss_num_map(p7_a5);
    ddp_lift_rec.object_version_number := rosetta_g_miss_num_map(p7_a6);
    ddp_lift_rec.model_id := rosetta_g_miss_num_map(p7_a7);
    ddp_lift_rec.quantile := rosetta_g_miss_num_map(p7_a8);
    ddp_lift_rec.lift := rosetta_g_miss_num_map(p7_a9);
    ddp_lift_rec.targets := rosetta_g_miss_num_map(p7_a10);
    ddp_lift_rec.non_targets := rosetta_g_miss_num_map(p7_a11);
    ddp_lift_rec.targets_cumm := rosetta_g_miss_num_map(p7_a12);
    ddp_lift_rec.target_density_cumm := rosetta_g_miss_num_map(p7_a13);
    ddp_lift_rec.target_density := rosetta_g_miss_num_map(p7_a14);
    ddp_lift_rec.margin := rosetta_g_miss_num_map(p7_a15);
    ddp_lift_rec.roi := rosetta_g_miss_num_map(p7_a16);
    ddp_lift_rec.target_confidence := rosetta_g_miss_num_map(p7_a17);
    ddp_lift_rec.non_target_confidence := rosetta_g_miss_num_map(p7_a18);


    -- here's the delegated call to the old PL/SQL routine
    ams_dmlift_pvt.update_lift(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_lift_rec,
      x_object_version_number);

    -- copy data back from the local OUT or IN-OUT args, if any








  end;

  procedure validate_lift_rec(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status OUT NOCOPY  VARCHAR2
    , x_msg_count OUT NOCOPY  NUMBER
    , x_msg_data OUT NOCOPY  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  DATE := fnd_api.g_miss_date
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  DATE := fnd_api.g_miss_date
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  NUMBER := 0-1962.0724
    , p5_a11  NUMBER := 0-1962.0724
    , p5_a12  NUMBER := 0-1962.0724
    , p5_a13  NUMBER := 0-1962.0724
    , p5_a14  NUMBER := 0-1962.0724
    , p5_a15  NUMBER := 0-1962.0724
    , p5_a16  NUMBER := 0-1962.0724
    , p5_a17  NUMBER := 0-1962.0724
    , p5_a18  NUMBER := 0-1962.0724
  )
  as
    ddp_lift_rec ams_dmlift_pvt.lift_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_lift_rec.lift_id := rosetta_g_miss_num_map(p5_a0);
    ddp_lift_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a1);
    ddp_lift_rec.last_updated_by := rosetta_g_miss_num_map(p5_a2);
    ddp_lift_rec.creation_date := rosetta_g_miss_date_in_map(p5_a3);
    ddp_lift_rec.created_by := rosetta_g_miss_num_map(p5_a4);
    ddp_lift_rec.last_update_login := rosetta_g_miss_num_map(p5_a5);
    ddp_lift_rec.object_version_number := rosetta_g_miss_num_map(p5_a6);
    ddp_lift_rec.model_id := rosetta_g_miss_num_map(p5_a7);
    ddp_lift_rec.quantile := rosetta_g_miss_num_map(p5_a8);
    ddp_lift_rec.lift := rosetta_g_miss_num_map(p5_a9);
    ddp_lift_rec.targets := rosetta_g_miss_num_map(p5_a10);
    ddp_lift_rec.non_targets := rosetta_g_miss_num_map(p5_a11);
    ddp_lift_rec.targets_cumm := rosetta_g_miss_num_map(p5_a12);
    ddp_lift_rec.target_density_cumm := rosetta_g_miss_num_map(p5_a13);
    ddp_lift_rec.target_density := rosetta_g_miss_num_map(p5_a14);
    ddp_lift_rec.margin := rosetta_g_miss_num_map(p5_a15);
    ddp_lift_rec.roi := rosetta_g_miss_num_map(p5_a16);
    ddp_lift_rec.target_confidence := rosetta_g_miss_num_map(p5_a17);
    ddp_lift_rec.non_target_confidence := rosetta_g_miss_num_map(p5_a18);

    -- here's the delegated call to the old PL/SQL routine
    ams_dmlift_pvt.validate_lift_rec(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_lift_rec);

    -- copy data back from the local OUT or IN-OUT args, if any





  end;

  procedure validate_lift(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , p_validation_mode  VARCHAR2
    , x_return_status OUT NOCOPY  VARCHAR2
    , x_msg_count OUT NOCOPY  NUMBER
    , x_msg_data OUT NOCOPY  VARCHAR2
    , p4_a0  NUMBER := 0-1962.0724
    , p4_a1  DATE := fnd_api.g_miss_date
    , p4_a2  NUMBER := 0-1962.0724
    , p4_a3  DATE := fnd_api.g_miss_date
    , p4_a4  NUMBER := 0-1962.0724
    , p4_a5  NUMBER := 0-1962.0724
    , p4_a6  NUMBER := 0-1962.0724
    , p4_a7  NUMBER := 0-1962.0724
    , p4_a8  NUMBER := 0-1962.0724
    , p4_a9  NUMBER := 0-1962.0724
    , p4_a10  NUMBER := 0-1962.0724
    , p4_a11  NUMBER := 0-1962.0724
    , p4_a12  NUMBER := 0-1962.0724
    , p4_a13  NUMBER := 0-1962.0724
    , p4_a14  NUMBER := 0-1962.0724
    , p4_a15  NUMBER := 0-1962.0724
    , p4_a16  NUMBER := 0-1962.0724
    , p4_a17  NUMBER := 0-1962.0724
    , p4_a18  NUMBER := 0-1962.0724
  )
  as
    ddp_lift_rec ams_dmlift_pvt.lift_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    ddp_lift_rec.lift_id := rosetta_g_miss_num_map(p4_a0);
    ddp_lift_rec.last_update_date := rosetta_g_miss_date_in_map(p4_a1);
    ddp_lift_rec.last_updated_by := rosetta_g_miss_num_map(p4_a2);
    ddp_lift_rec.creation_date := rosetta_g_miss_date_in_map(p4_a3);
    ddp_lift_rec.created_by := rosetta_g_miss_num_map(p4_a4);
    ddp_lift_rec.last_update_login := rosetta_g_miss_num_map(p4_a5);
    ddp_lift_rec.object_version_number := rosetta_g_miss_num_map(p4_a6);
    ddp_lift_rec.model_id := rosetta_g_miss_num_map(p4_a7);
    ddp_lift_rec.quantile := rosetta_g_miss_num_map(p4_a8);
    ddp_lift_rec.lift := rosetta_g_miss_num_map(p4_a9);
    ddp_lift_rec.targets := rosetta_g_miss_num_map(p4_a10);
    ddp_lift_rec.non_targets := rosetta_g_miss_num_map(p4_a11);
    ddp_lift_rec.targets_cumm := rosetta_g_miss_num_map(p4_a12);
    ddp_lift_rec.target_density_cumm := rosetta_g_miss_num_map(p4_a13);
    ddp_lift_rec.target_density := rosetta_g_miss_num_map(p4_a14);
    ddp_lift_rec.margin := rosetta_g_miss_num_map(p4_a15);
    ddp_lift_rec.roi := rosetta_g_miss_num_map(p4_a16);
    ddp_lift_rec.target_confidence := rosetta_g_miss_num_map(p4_a17);
    ddp_lift_rec.non_target_confidence := rosetta_g_miss_num_map(p4_a18);




    -- here's the delegated call to the old PL/SQL routine
    ams_dmlift_pvt.validate_lift(p_api_version,
      p_init_msg_list,
      p_validation_level,
      p_validation_mode,
      ddp_lift_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any







  end;

end ams_dmlift_pvt_w;

/
