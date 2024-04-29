--------------------------------------------------------
--  DDL for Package Body AMS_APPROVAL_DETAILS_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_APPROVAL_DETAILS_PVT_W" as
  /* $Header: amswapdb.pls 115.7 2002/12/29 08:28:52 vmodur ship $ */
  rosetta_g_mistake_date date := to_date('01/01/+4713', 'MM/DD/SYYYY');
  rosetta_g_miss_date date := to_date('01/01/-4712', 'MM/DD/SYYYY');

  function rosetta_g_miss_num_map(n number) return number as
    b number := 0-1962.0724;
  begin
    if n=fnd_api.g_miss_num then return b; end if;
    if n=b then return fnd_api.g_miss_num; end if;
    return n;
  end;

  -- this is to workaround the JDBC bug regarding IN DATE of value GMiss
  function rosetta_g_miss_date_in_map(d date) return date as
  begin
    if d = rosetta_g_mistake_date then return fnd_api.g_miss_date; end if;
    return d;
  end;

  procedure rosetta_table_copy_in_p1(t OUT NOCOPY ams_approval_details_pvt.t_approval_id_table, a0 JTF_NUMBER_TABLE) as
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
  end rosetta_table_copy_in_p1;
  procedure rosetta_table_copy_out_p1(t ams_approval_details_pvt.t_approval_id_table, a0 OUT NOCOPY JTF_NUMBER_TABLE) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
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
  end rosetta_table_copy_out_p1;

  procedure create_approval_details(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status OUT NOCOPY  VARCHAR2
    , x_msg_count OUT NOCOPY  NUMBER
    , x_msg_data OUT NOCOPY  VARCHAR2
    , p7_a0  DATE
    , p7_a1  DATE
    , p7_a2  NUMBER
    , p7_a3  DATE
    , p7_a4  NUMBER
    , p7_a5  DATE
    , p7_a6  NUMBER
    , p7_a7  NUMBER
    , p7_a8  NUMBER
    , p7_a9  NUMBER
    , p7_a10  NUMBER
    , p7_a11  NUMBER
    , p7_a12  NUMBER
    , p7_a13  NUMBER
    , p7_a14  VARCHAR2
    , p7_a15  VARCHAR2
    , p7_a16  VARCHAR2
    , p7_a17  VARCHAR2
    , p7_a18  NUMBER
    , p7_a19  NUMBER
    , p7_a20  VARCHAR2
    , p7_a21  VARCHAR2
    , p7_a22  VARCHAR2
    , p7_a23  VARCHAR2
    , p7_a24  VARCHAR2
    , p7_a25  VARCHAR2
    , x_approval_detail_id OUT NOCOPY  NUMBER
  )

  as
    ddp_approval_details_rec ams_approval_details_pvt.approval_details_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_approval_details_rec.start_date_active := rosetta_g_miss_date_in_map(p7_a0);
    ddp_approval_details_rec.end_date_active := rosetta_g_miss_date_in_map(p7_a1);
    ddp_approval_details_rec.approval_detail_id := p7_a2;
    ddp_approval_details_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a3);
    ddp_approval_details_rec.last_updated_by := p7_a4;
    ddp_approval_details_rec.creation_date := rosetta_g_miss_date_in_map(p7_a5);
    ddp_approval_details_rec.created_by := p7_a6;
    ddp_approval_details_rec.last_update_login := p7_a7;
    ddp_approval_details_rec.object_version_number := p7_a8;
    ddp_approval_details_rec.security_group_id := p7_a9;
    ddp_approval_details_rec.business_group_id := p7_a10;
    ddp_approval_details_rec.business_unit_id := p7_a11;
    ddp_approval_details_rec.organization_id := p7_a12;
    ddp_approval_details_rec.custom_setup_id := p7_a13;
    ddp_approval_details_rec.approval_object := p7_a14;
    ddp_approval_details_rec.approval_object_type := p7_a15;
    ddp_approval_details_rec.approval_type := p7_a16;
    ddp_approval_details_rec.approval_priority := p7_a17;
    ddp_approval_details_rec.approval_limit_to := p7_a18;
    ddp_approval_details_rec.approval_limit_from := p7_a19;
    ddp_approval_details_rec.seeded_flag := p7_a20;
    ddp_approval_details_rec.active_flag := p7_a21;
    ddp_approval_details_rec.currency_code := p7_a22;
    ddp_approval_details_rec.user_country_code := p7_a23;
    ddp_approval_details_rec.name := p7_a24;
    ddp_approval_details_rec.description := p7_a25;


    -- here's the delegated call to the old PL/SQL routine
    ams_approval_details_pvt.create_approval_details(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_approval_details_rec,
      x_approval_detail_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

  procedure update_approval_details(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status OUT NOCOPY  VARCHAR2
    , x_msg_count OUT NOCOPY  NUMBER
    , x_msg_data OUT NOCOPY  VARCHAR2
    , p7_a0  DATE
    , p7_a1  DATE
    , p7_a2  NUMBER
    , p7_a3  DATE
    , p7_a4  NUMBER
    , p7_a5  DATE
    , p7_a6  NUMBER
    , p7_a7  NUMBER
    , p7_a8  NUMBER
    , p7_a9  NUMBER
    , p7_a10  NUMBER
    , p7_a11  NUMBER
    , p7_a12  NUMBER
    , p7_a13  NUMBER
    , p7_a14  VARCHAR2
    , p7_a15  VARCHAR2
    , p7_a16  VARCHAR2
    , p7_a17  VARCHAR2
    , p7_a18  NUMBER
    , p7_a19  NUMBER
    , p7_a20  VARCHAR2
    , p7_a21  VARCHAR2
    , p7_a22  VARCHAR2
    , p7_a23  VARCHAR2
    , p7_a24  VARCHAR2
    , p7_a25  VARCHAR2
  )

  as
    ddp_approval_details_rec ams_approval_details_pvt.approval_details_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_approval_details_rec.start_date_active := rosetta_g_miss_date_in_map(p7_a0);
    ddp_approval_details_rec.end_date_active := rosetta_g_miss_date_in_map(p7_a1);
    ddp_approval_details_rec.approval_detail_id := p7_a2;
    ddp_approval_details_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a3);
    ddp_approval_details_rec.last_updated_by := p7_a4;
    ddp_approval_details_rec.creation_date := rosetta_g_miss_date_in_map(p7_a5);
    ddp_approval_details_rec.created_by := p7_a6;
    ddp_approval_details_rec.last_update_login := p7_a7;
    ddp_approval_details_rec.object_version_number := p7_a8;
    ddp_approval_details_rec.security_group_id := p7_a9;
    ddp_approval_details_rec.business_group_id := p7_a10;
    ddp_approval_details_rec.business_unit_id := p7_a11;
    ddp_approval_details_rec.organization_id := p7_a12;
    ddp_approval_details_rec.custom_setup_id := p7_a13;
    ddp_approval_details_rec.approval_object := p7_a14;
    ddp_approval_details_rec.approval_object_type := p7_a15;
    ddp_approval_details_rec.approval_type := p7_a16;
    ddp_approval_details_rec.approval_priority := p7_a17;
    ddp_approval_details_rec.approval_limit_to := p7_a18;
    ddp_approval_details_rec.approval_limit_from := p7_a19;
    ddp_approval_details_rec.seeded_flag := p7_a20;
    ddp_approval_details_rec.active_flag := p7_a21;
    ddp_approval_details_rec.currency_code := p7_a22;
    ddp_approval_details_rec.user_country_code := p7_a23;
    ddp_approval_details_rec.name := p7_a24;
    ddp_approval_details_rec.description := p7_a25;

    -- here's the delegated call to the old PL/SQL routine
    ams_approval_details_pvt.update_approval_details(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_approval_details_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

  procedure validate_approval_details(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status OUT NOCOPY  VARCHAR2
    , x_msg_count OUT NOCOPY  NUMBER
    , x_msg_data OUT NOCOPY  VARCHAR2
    , p7_a0  DATE
    , p7_a1  DATE
    , p7_a2  NUMBER
    , p7_a3  DATE
    , p7_a4  NUMBER
    , p7_a5  DATE
    , p7_a6  NUMBER
    , p7_a7  NUMBER
    , p7_a8  NUMBER
    , p7_a9  NUMBER
    , p7_a10  NUMBER
    , p7_a11  NUMBER
    , p7_a12  NUMBER
    , p7_a13  NUMBER
    , p7_a14  VARCHAR2
    , p7_a15  VARCHAR2
    , p7_a16  VARCHAR2
    , p7_a17  VARCHAR2
    , p7_a18  NUMBER
    , p7_a19  NUMBER
    , p7_a20  VARCHAR2
    , p7_a21  VARCHAR2
    , p7_a22  VARCHAR2
    , p7_a23  VARCHAR2
    , p7_a24  VARCHAR2
    , p7_a25  VARCHAR2
  )

  as
    ddp_approval_details_rec ams_approval_details_pvt.approval_details_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_approval_details_rec.start_date_active := rosetta_g_miss_date_in_map(p7_a0);
    ddp_approval_details_rec.end_date_active := rosetta_g_miss_date_in_map(p7_a1);
    ddp_approval_details_rec.approval_detail_id := p7_a2;
    ddp_approval_details_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a3);
    ddp_approval_details_rec.last_updated_by := p7_a4;
    ddp_approval_details_rec.creation_date := rosetta_g_miss_date_in_map(p7_a5);
    ddp_approval_details_rec.created_by := p7_a6;
    ddp_approval_details_rec.last_update_login := p7_a7;
    ddp_approval_details_rec.object_version_number := p7_a8;
    ddp_approval_details_rec.security_group_id := p7_a9;
    ddp_approval_details_rec.business_group_id := p7_a10;
    ddp_approval_details_rec.business_unit_id := p7_a11;
    ddp_approval_details_rec.organization_id := p7_a12;
    ddp_approval_details_rec.custom_setup_id := p7_a13;
    ddp_approval_details_rec.approval_object := p7_a14;
    ddp_approval_details_rec.approval_object_type := p7_a15;
    ddp_approval_details_rec.approval_type := p7_a16;
    ddp_approval_details_rec.approval_priority := p7_a17;
    ddp_approval_details_rec.approval_limit_to := p7_a18;
    ddp_approval_details_rec.approval_limit_from := p7_a19;
    ddp_approval_details_rec.seeded_flag := p7_a20;
    ddp_approval_details_rec.active_flag := p7_a21;
    ddp_approval_details_rec.currency_code := p7_a22;
    ddp_approval_details_rec.user_country_code := p7_a23;
    ddp_approval_details_rec.name := p7_a24;
    ddp_approval_details_rec.description := p7_a25;

    -- here's the delegated call to the old PL/SQL routine
    ams_approval_details_pvt.validate_approval_details(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_approval_details_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

  procedure check_approval_details_items(p0_a0  DATE
    , p0_a1  DATE
    , p0_a2  NUMBER
    , p0_a3  DATE
    , p0_a4  NUMBER
    , p0_a5  DATE
    , p0_a6  NUMBER
    , p0_a7  NUMBER
    , p0_a8  NUMBER
    , p0_a9  NUMBER
    , p0_a10  NUMBER
    , p0_a11  NUMBER
    , p0_a12  NUMBER
    , p0_a13  NUMBER
    , p0_a14  VARCHAR2
    , p0_a15  VARCHAR2
    , p0_a16  VARCHAR2
    , p0_a17  VARCHAR2
    , p0_a18  NUMBER
    , p0_a19  NUMBER
    , p0_a20  VARCHAR2
    , p0_a21  VARCHAR2
    , p0_a22  VARCHAR2
    , p0_a23  VARCHAR2
    , p0_a24  VARCHAR2
    , p0_a25  VARCHAR2
    , p_validation_mode  VARCHAR2
    , x_return_status OUT NOCOPY  VARCHAR2
  )

  as
    ddp_approval_details_rec ams_approval_details_pvt.approval_details_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_approval_details_rec.start_date_active := rosetta_g_miss_date_in_map(p0_a0);
    ddp_approval_details_rec.end_date_active := rosetta_g_miss_date_in_map(p0_a1);
    ddp_approval_details_rec.approval_detail_id := p0_a2;
    ddp_approval_details_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a3);
    ddp_approval_details_rec.last_updated_by := p0_a4;
    ddp_approval_details_rec.creation_date := rosetta_g_miss_date_in_map(p0_a5);
    ddp_approval_details_rec.created_by := p0_a6;
    ddp_approval_details_rec.last_update_login := p0_a7;
    ddp_approval_details_rec.object_version_number := p0_a8;
    ddp_approval_details_rec.security_group_id := p0_a9;
    ddp_approval_details_rec.business_group_id := p0_a10;
    ddp_approval_details_rec.business_unit_id := p0_a11;
    ddp_approval_details_rec.organization_id := p0_a12;
    ddp_approval_details_rec.custom_setup_id := p0_a13;
    ddp_approval_details_rec.approval_object := p0_a14;
    ddp_approval_details_rec.approval_object_type := p0_a15;
    ddp_approval_details_rec.approval_type := p0_a16;
    ddp_approval_details_rec.approval_priority := p0_a17;
    ddp_approval_details_rec.approval_limit_to := p0_a18;
    ddp_approval_details_rec.approval_limit_from := p0_a19;
    ddp_approval_details_rec.seeded_flag := p0_a20;
    ddp_approval_details_rec.active_flag := p0_a21;
    ddp_approval_details_rec.currency_code := p0_a22;
    ddp_approval_details_rec.user_country_code := p0_a23;
    ddp_approval_details_rec.name := p0_a24;
    ddp_approval_details_rec.description := p0_a25;



    -- here's the delegated call to the old PL/SQL routine
    ams_approval_details_pvt.check_approval_details_items(ddp_approval_details_rec,
      p_validation_mode,
      x_return_status);

    -- copy data back from the local variables to OUT or IN-OUT args, if any


  end;

  procedure check_approval_details_record(p0_a0  DATE
    , p0_a1  DATE
    , p0_a2  NUMBER
    , p0_a3  DATE
    , p0_a4  NUMBER
    , p0_a5  DATE
    , p0_a6  NUMBER
    , p0_a7  NUMBER
    , p0_a8  NUMBER
    , p0_a9  NUMBER
    , p0_a10  NUMBER
    , p0_a11  NUMBER
    , p0_a12  NUMBER
    , p0_a13  NUMBER
    , p0_a14  VARCHAR2
    , p0_a15  VARCHAR2
    , p0_a16  VARCHAR2
    , p0_a17  VARCHAR2
    , p0_a18  NUMBER
    , p0_a19  NUMBER
    , p0_a20  VARCHAR2
    , p0_a21  VARCHAR2
    , p0_a22  VARCHAR2
    , p0_a23  VARCHAR2
    , p0_a24  VARCHAR2
    , p0_a25  VARCHAR2
    , p1_a0  DATE
    , p1_a1  DATE
    , p1_a2  NUMBER
    , p1_a3  DATE
    , p1_a4  NUMBER
    , p1_a5  DATE
    , p1_a6  NUMBER
    , p1_a7  NUMBER
    , p1_a8  NUMBER
    , p1_a9  NUMBER
    , p1_a10  NUMBER
    , p1_a11  NUMBER
    , p1_a12  NUMBER
    , p1_a13  NUMBER
    , p1_a14  VARCHAR2
    , p1_a15  VARCHAR2
    , p1_a16  VARCHAR2
    , p1_a17  VARCHAR2
    , p1_a18  NUMBER
    , p1_a19  NUMBER
    , p1_a20  VARCHAR2
    , p1_a21  VARCHAR2
    , p1_a22  VARCHAR2
    , p1_a23  VARCHAR2
    , p1_a24  VARCHAR2
    , p1_a25  VARCHAR2
    , x_return_status OUT NOCOPY  VARCHAR2
  )

  as
    ddp_approval_details_rec ams_approval_details_pvt.approval_details_rec_type;
    ddp_complete_rec ams_approval_details_pvt.approval_details_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_approval_details_rec.start_date_active := rosetta_g_miss_date_in_map(p0_a0);
    ddp_approval_details_rec.end_date_active := rosetta_g_miss_date_in_map(p0_a1);
    ddp_approval_details_rec.approval_detail_id := p0_a2;
    ddp_approval_details_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a3);
    ddp_approval_details_rec.last_updated_by := p0_a4;
    ddp_approval_details_rec.creation_date := rosetta_g_miss_date_in_map(p0_a5);
    ddp_approval_details_rec.created_by := p0_a6;
    ddp_approval_details_rec.last_update_login := p0_a7;
    ddp_approval_details_rec.object_version_number := p0_a8;
    ddp_approval_details_rec.security_group_id := p0_a9;
    ddp_approval_details_rec.business_group_id := p0_a10;
    ddp_approval_details_rec.business_unit_id := p0_a11;
    ddp_approval_details_rec.organization_id := p0_a12;
    ddp_approval_details_rec.custom_setup_id := p0_a13;
    ddp_approval_details_rec.approval_object := p0_a14;
    ddp_approval_details_rec.approval_object_type := p0_a15;
    ddp_approval_details_rec.approval_type := p0_a16;
    ddp_approval_details_rec.approval_priority := p0_a17;
    ddp_approval_details_rec.approval_limit_to := p0_a18;
    ddp_approval_details_rec.approval_limit_from := p0_a19;
    ddp_approval_details_rec.seeded_flag := p0_a20;
    ddp_approval_details_rec.active_flag := p0_a21;
    ddp_approval_details_rec.currency_code := p0_a22;
    ddp_approval_details_rec.user_country_code := p0_a23;
    ddp_approval_details_rec.name := p0_a24;
    ddp_approval_details_rec.description := p0_a25;

    ddp_complete_rec.start_date_active := rosetta_g_miss_date_in_map(p1_a0);
    ddp_complete_rec.end_date_active := rosetta_g_miss_date_in_map(p1_a1);
    ddp_complete_rec.approval_detail_id := p1_a2;
    ddp_complete_rec.last_update_date := rosetta_g_miss_date_in_map(p1_a3);
    ddp_complete_rec.last_updated_by := p1_a4;
    ddp_complete_rec.creation_date := rosetta_g_miss_date_in_map(p1_a5);
    ddp_complete_rec.created_by := p1_a6;
    ddp_complete_rec.last_update_login := p1_a7;
    ddp_complete_rec.object_version_number := p1_a8;
    ddp_complete_rec.security_group_id := p1_a9;
    ddp_complete_rec.business_group_id := p1_a10;
    ddp_complete_rec.business_unit_id := p1_a11;
    ddp_complete_rec.organization_id := p1_a12;
    ddp_complete_rec.custom_setup_id := p1_a13;
    ddp_complete_rec.approval_object := p1_a14;
    ddp_complete_rec.approval_object_type := p1_a15;
    ddp_complete_rec.approval_type := p1_a16;
    ddp_complete_rec.approval_priority := p1_a17;
    ddp_complete_rec.approval_limit_to := p1_a18;
    ddp_complete_rec.approval_limit_from := p1_a19;
    ddp_complete_rec.seeded_flag := p1_a20;
    ddp_complete_rec.active_flag := p1_a21;
    ddp_complete_rec.currency_code := p1_a22;
    ddp_complete_rec.user_country_code := p1_a23;
    ddp_complete_rec.name := p1_a24;
    ddp_complete_rec.description := p1_a25;


    -- here's the delegated call to the old PL/SQL routine
    ams_approval_details_pvt.check_approval_details_record(ddp_approval_details_rec,
      ddp_complete_rec,
      x_return_status);

    -- copy data back from the local variables to OUT or IN-OUT args, if any


  end;

  procedure init_approval_details_rec(p0_a0 OUT NOCOPY  DATE
    , p0_a1 OUT NOCOPY  DATE
    , p0_a2 OUT NOCOPY  NUMBER
    , p0_a3 OUT NOCOPY  DATE
    , p0_a4 OUT NOCOPY  NUMBER
    , p0_a5 OUT NOCOPY  DATE
    , p0_a6 OUT NOCOPY  NUMBER
    , p0_a7 OUT NOCOPY  NUMBER
    , p0_a8 OUT NOCOPY  NUMBER
    , p0_a9 OUT NOCOPY  NUMBER
    , p0_a10 OUT NOCOPY  NUMBER
    , p0_a11 OUT NOCOPY  NUMBER
    , p0_a12 OUT NOCOPY  NUMBER
    , p0_a13 OUT NOCOPY  NUMBER
    , p0_a14 OUT NOCOPY  VARCHAR2
    , p0_a15 OUT NOCOPY  VARCHAR2
    , p0_a16 OUT NOCOPY  VARCHAR2
    , p0_a17 OUT NOCOPY  VARCHAR2
    , p0_a18 OUT NOCOPY  NUMBER
    , p0_a19 OUT NOCOPY  NUMBER
    , p0_a20 OUT NOCOPY  VARCHAR2
    , p0_a21 OUT NOCOPY  VARCHAR2
    , p0_a22 OUT NOCOPY  VARCHAR2
    , p0_a23 OUT NOCOPY  VARCHAR2
    , p0_a24 OUT NOCOPY  VARCHAR2
    , p0_a25 OUT NOCOPY  VARCHAR2
  )

  as
    ddx_approval_details_rec ams_approval_details_pvt.approval_details_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    -- here's the delegated call to the old PL/SQL routine
    ams_approval_details_pvt.init_approval_details_rec(ddx_approval_details_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any
    p0_a0 := ddx_approval_details_rec.start_date_active;
    p0_a1 := ddx_approval_details_rec.end_date_active;
    p0_a2 := ddx_approval_details_rec.approval_detail_id;
    p0_a3 := ddx_approval_details_rec.last_update_date;
    p0_a4 := ddx_approval_details_rec.last_updated_by;
    p0_a5 := ddx_approval_details_rec.creation_date;
    p0_a6 := ddx_approval_details_rec.created_by;
    p0_a7 := ddx_approval_details_rec.last_update_login;
    p0_a8 := ddx_approval_details_rec.object_version_number;
    p0_a9 := ddx_approval_details_rec.security_group_id;
    p0_a10 := ddx_approval_details_rec.business_group_id;
    p0_a11 := ddx_approval_details_rec.business_unit_id;
    p0_a12 := ddx_approval_details_rec.organization_id;
    p0_a13 := ddx_approval_details_rec.custom_setup_id;
    p0_a14 := ddx_approval_details_rec.approval_object;
    p0_a15 := ddx_approval_details_rec.approval_object_type;
    p0_a16 := ddx_approval_details_rec.approval_type;
    p0_a17 := ddx_approval_details_rec.approval_priority;
    p0_a18 := ddx_approval_details_rec.approval_limit_to;
    p0_a19 := ddx_approval_details_rec.approval_limit_from;
    p0_a20 := ddx_approval_details_rec.seeded_flag;
    p0_a21 := ddx_approval_details_rec.active_flag;
    p0_a22 := ddx_approval_details_rec.currency_code;
    p0_a23 := ddx_approval_details_rec.user_country_code;
    p0_a24 := ddx_approval_details_rec.name;
    p0_a25 := ddx_approval_details_rec.description;
  end;

  procedure complete_approval_details_rec(p0_a0  DATE
    , p0_a1  DATE
    , p0_a2  NUMBER
    , p0_a3  DATE
    , p0_a4  NUMBER
    , p0_a5  DATE
    , p0_a6  NUMBER
    , p0_a7  NUMBER
    , p0_a8  NUMBER
    , p0_a9  NUMBER
    , p0_a10  NUMBER
    , p0_a11  NUMBER
    , p0_a12  NUMBER
    , p0_a13  NUMBER
    , p0_a14  VARCHAR2
    , p0_a15  VARCHAR2
    , p0_a16  VARCHAR2
    , p0_a17  VARCHAR2
    , p0_a18  NUMBER
    , p0_a19  NUMBER
    , p0_a20  VARCHAR2
    , p0_a21  VARCHAR2
    , p0_a22  VARCHAR2
    , p0_a23  VARCHAR2
    , p0_a24  VARCHAR2
    , p0_a25  VARCHAR2
    , p1_a0 OUT NOCOPY  DATE
    , p1_a1 OUT NOCOPY  DATE
    , p1_a2 OUT NOCOPY  NUMBER
    , p1_a3 OUT NOCOPY  DATE
    , p1_a4 OUT NOCOPY  NUMBER
    , p1_a5 OUT NOCOPY  DATE
    , p1_a6 OUT NOCOPY  NUMBER
    , p1_a7 OUT NOCOPY  NUMBER
    , p1_a8 OUT NOCOPY  NUMBER
    , p1_a9 OUT NOCOPY  NUMBER
    , p1_a10 OUT NOCOPY  NUMBER
    , p1_a11 OUT NOCOPY  NUMBER
    , p1_a12 OUT NOCOPY  NUMBER
    , p1_a13 OUT NOCOPY  NUMBER
    , p1_a14 OUT NOCOPY  VARCHAR2
    , p1_a15 OUT NOCOPY  VARCHAR2
    , p1_a16 OUT NOCOPY  VARCHAR2
    , p1_a17 OUT NOCOPY  VARCHAR2
    , p1_a18 OUT NOCOPY  NUMBER
    , p1_a19 OUT NOCOPY  NUMBER
    , p1_a20 OUT NOCOPY  VARCHAR2
    , p1_a21 OUT NOCOPY  VARCHAR2
    , p1_a22 OUT NOCOPY  VARCHAR2
    , p1_a23 OUT NOCOPY  VARCHAR2
    , p1_a24 OUT NOCOPY  VARCHAR2
    , p1_a25 OUT NOCOPY  VARCHAR2
  )

  as
    ddp_approval_details_rec ams_approval_details_pvt.approval_details_rec_type;
    ddx_complete_rec ams_approval_details_pvt.approval_details_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_approval_details_rec.start_date_active := rosetta_g_miss_date_in_map(p0_a0);
    ddp_approval_details_rec.end_date_active := rosetta_g_miss_date_in_map(p0_a1);
    ddp_approval_details_rec.approval_detail_id := p0_a2;
    ddp_approval_details_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a3);
    ddp_approval_details_rec.last_updated_by := p0_a4;
    ddp_approval_details_rec.creation_date := rosetta_g_miss_date_in_map(p0_a5);
    ddp_approval_details_rec.created_by := p0_a6;
    ddp_approval_details_rec.last_update_login := p0_a7;
    ddp_approval_details_rec.object_version_number := p0_a8;
    ddp_approval_details_rec.security_group_id := p0_a9;
    ddp_approval_details_rec.business_group_id := p0_a10;
    ddp_approval_details_rec.business_unit_id := p0_a11;
    ddp_approval_details_rec.organization_id := p0_a12;
    ddp_approval_details_rec.custom_setup_id := p0_a13;
    ddp_approval_details_rec.approval_object := p0_a14;
    ddp_approval_details_rec.approval_object_type := p0_a15;
    ddp_approval_details_rec.approval_type := p0_a16;
    ddp_approval_details_rec.approval_priority := p0_a17;
    ddp_approval_details_rec.approval_limit_to := p0_a18;
    ddp_approval_details_rec.approval_limit_from := p0_a19;
    ddp_approval_details_rec.seeded_flag := p0_a20;
    ddp_approval_details_rec.active_flag := p0_a21;
    ddp_approval_details_rec.currency_code := p0_a22;
    ddp_approval_details_rec.user_country_code := p0_a23;
    ddp_approval_details_rec.name := p0_a24;
    ddp_approval_details_rec.description := p0_a25;


    -- here's the delegated call to the old PL/SQL routine
    ams_approval_details_pvt.complete_approval_details_rec(ddp_approval_details_rec,
      ddx_complete_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any

    p1_a0 := ddx_complete_rec.start_date_active;
    p1_a1 := ddx_complete_rec.end_date_active;
    p1_a2 := ddx_complete_rec.approval_detail_id;
    p1_a3 := ddx_complete_rec.last_update_date;
    p1_a4 := ddx_complete_rec.last_updated_by;
    p1_a5 := ddx_complete_rec.creation_date;
    p1_a6 := ddx_complete_rec.created_by;
    p1_a7 := ddx_complete_rec.last_update_login;
    p1_a8 := ddx_complete_rec.object_version_number;
    p1_a9 := ddx_complete_rec.security_group_id;
    p1_a10 := ddx_complete_rec.business_group_id;
    p1_a11 := ddx_complete_rec.business_unit_id;
    p1_a12 := ddx_complete_rec.organization_id;
    p1_a13 := ddx_complete_rec.custom_setup_id;
    p1_a14 := ddx_complete_rec.approval_object;
    p1_a15 := ddx_complete_rec.approval_object_type;
    p1_a16 := ddx_complete_rec.approval_type;
    p1_a17 := ddx_complete_rec.approval_priority;
    p1_a18 := ddx_complete_rec.approval_limit_to;
    p1_a19 := ddx_complete_rec.approval_limit_from;
    p1_a20 := ddx_complete_rec.seeded_flag;
    p1_a21 := ddx_complete_rec.active_flag;
    p1_a22 := ddx_complete_rec.currency_code;
    p1_a23 := ddx_complete_rec.user_country_code;
    p1_a24 := ddx_complete_rec.name;
    p1_a25 := ddx_complete_rec.description;
  end;

end ams_approval_details_pvt_w;

/
