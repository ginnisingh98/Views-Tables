--------------------------------------------------------
--  DDL for Package Body AMS_CELL_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_CELL_PVT_W" as
  /* $Header: amswcelb.pls 115.19 2002/11/22 08:56:52 jieli ship $ */
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

  procedure rosetta_table_copy_in_p2(t OUT NOCOPY ams_cell_pvt.t_number, a0 JTF_NUMBER_TABLE) as
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
  procedure rosetta_table_copy_out_p2(t ams_cell_pvt.t_number, a0 OUT NOCOPY JTF_NUMBER_TABLE) as
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
  end rosetta_table_copy_out_p2;

  procedure create_cell(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status OUT NOCOPY  VARCHAR2
    , x_msg_count OUT NOCOPY  NUMBER
    , x_msg_data OUT NOCOPY  VARCHAR2
    , x_cell_id OUT NOCOPY  NUMBER
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  VARCHAR2 := fnd_api.g_miss_char
    , p7_a2  DATE := fnd_api.g_miss_date
    , p7_a3  NUMBER := 0-1962.0724
    , p7_a4  DATE := fnd_api.g_miss_date
    , p7_a5  NUMBER := 0-1962.0724
    , p7_a6  NUMBER := 0-1962.0724
    , p7_a7  NUMBER := 0-1962.0724
    , p7_a8  VARCHAR2 := fnd_api.g_miss_char
    , p7_a9  VARCHAR2 := fnd_api.g_miss_char
    , p7_a10  NUMBER := 0-1962.0724
    , p7_a11  NUMBER := 0-1962.0724
    , p7_a12  NUMBER := 0-1962.0724
    , p7_a13  NUMBER := 0-1962.0724
    , p7_a14  VARCHAR2 := fnd_api.g_miss_char
    , p7_a15  VARCHAR2 := fnd_api.g_miss_char
    , p7_a16  VARCHAR2 := fnd_api.g_miss_char
    , p7_a17  DATE := fnd_api.g_miss_date
    , p7_a18  NUMBER := 0-1962.0724
  )
  as
    ddp_cell_rec ams_cell_pvt.cell_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_cell_rec.cell_id := rosetta_g_miss_num_map(p7_a0);
    ddp_cell_rec.sel_type := p7_a1;
    ddp_cell_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a2);
    ddp_cell_rec.last_updated_by := rosetta_g_miss_num_map(p7_a3);
    ddp_cell_rec.creation_date := rosetta_g_miss_date_in_map(p7_a4);
    ddp_cell_rec.created_by := rosetta_g_miss_num_map(p7_a5);
    ddp_cell_rec.last_update_login := rosetta_g_miss_num_map(p7_a6);
    ddp_cell_rec.object_version_number := rosetta_g_miss_num_map(p7_a7);
    ddp_cell_rec.cell_code := p7_a8;
    ddp_cell_rec.enabled_flag := p7_a9;
    ddp_cell_rec.original_size := rosetta_g_miss_num_map(p7_a10);
    ddp_cell_rec.parent_cell_id := rosetta_g_miss_num_map(p7_a11);
    ddp_cell_rec.org_id := rosetta_g_miss_num_map(p7_a12);
    ddp_cell_rec.owner_id := rosetta_g_miss_num_map(p7_a13);
    ddp_cell_rec.cell_name := p7_a14;
    ddp_cell_rec.description := p7_a15;
    ddp_cell_rec.status_code := p7_a16;
    ddp_cell_rec.status_date := rosetta_g_miss_date_in_map(p7_a17);
    ddp_cell_rec.user_status_id := rosetta_g_miss_num_map(p7_a18);


    -- here's the delegated call to the old PL/SQL routine
    ams_cell_pvt.create_cell(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_cell_rec,
      x_cell_id);

    -- copy data back from the local OUT or IN-OUT args, if any








  end;

  procedure update_cell(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status OUT NOCOPY  VARCHAR2
    , x_msg_count OUT NOCOPY  NUMBER
    , x_msg_data OUT NOCOPY  VARCHAR2
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  VARCHAR2 := fnd_api.g_miss_char
    , p7_a2  DATE := fnd_api.g_miss_date
    , p7_a3  NUMBER := 0-1962.0724
    , p7_a4  DATE := fnd_api.g_miss_date
    , p7_a5  NUMBER := 0-1962.0724
    , p7_a6  NUMBER := 0-1962.0724
    , p7_a7  NUMBER := 0-1962.0724
    , p7_a8  VARCHAR2 := fnd_api.g_miss_char
    , p7_a9  VARCHAR2 := fnd_api.g_miss_char
    , p7_a10  NUMBER := 0-1962.0724
    , p7_a11  NUMBER := 0-1962.0724
    , p7_a12  NUMBER := 0-1962.0724
    , p7_a13  NUMBER := 0-1962.0724
    , p7_a14  VARCHAR2 := fnd_api.g_miss_char
    , p7_a15  VARCHAR2 := fnd_api.g_miss_char
    , p7_a16  VARCHAR2 := fnd_api.g_miss_char
    , p7_a17  DATE := fnd_api.g_miss_date
    , p7_a18  NUMBER := 0-1962.0724
  )
  as
    ddp_cell_rec ams_cell_pvt.cell_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_cell_rec.cell_id := rosetta_g_miss_num_map(p7_a0);
    ddp_cell_rec.sel_type := p7_a1;
    ddp_cell_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a2);
    ddp_cell_rec.last_updated_by := rosetta_g_miss_num_map(p7_a3);
    ddp_cell_rec.creation_date := rosetta_g_miss_date_in_map(p7_a4);
    ddp_cell_rec.created_by := rosetta_g_miss_num_map(p7_a5);
    ddp_cell_rec.last_update_login := rosetta_g_miss_num_map(p7_a6);
    ddp_cell_rec.object_version_number := rosetta_g_miss_num_map(p7_a7);
    ddp_cell_rec.cell_code := p7_a8;
    ddp_cell_rec.enabled_flag := p7_a9;
    ddp_cell_rec.original_size := rosetta_g_miss_num_map(p7_a10);
    ddp_cell_rec.parent_cell_id := rosetta_g_miss_num_map(p7_a11);
    ddp_cell_rec.org_id := rosetta_g_miss_num_map(p7_a12);
    ddp_cell_rec.owner_id := rosetta_g_miss_num_map(p7_a13);
    ddp_cell_rec.cell_name := p7_a14;
    ddp_cell_rec.description := p7_a15;
    ddp_cell_rec.status_code := p7_a16;
    ddp_cell_rec.status_date := rosetta_g_miss_date_in_map(p7_a17);
    ddp_cell_rec.user_status_id := rosetta_g_miss_num_map(p7_a18);

    -- here's the delegated call to the old PL/SQL routine
    ams_cell_pvt.update_cell(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_cell_rec);

    -- copy data back from the local OUT or IN-OUT args, if any







  end;

  procedure validate_cell(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status OUT NOCOPY  VARCHAR2
    , x_msg_count OUT NOCOPY  NUMBER
    , x_msg_data OUT NOCOPY  VARCHAR2
    , p6_a0  NUMBER := 0-1962.0724
    , p6_a1  VARCHAR2 := fnd_api.g_miss_char
    , p6_a2  DATE := fnd_api.g_miss_date
    , p6_a3  NUMBER := 0-1962.0724
    , p6_a4  DATE := fnd_api.g_miss_date
    , p6_a5  NUMBER := 0-1962.0724
    , p6_a6  NUMBER := 0-1962.0724
    , p6_a7  NUMBER := 0-1962.0724
    , p6_a8  VARCHAR2 := fnd_api.g_miss_char
    , p6_a9  VARCHAR2 := fnd_api.g_miss_char
    , p6_a10  NUMBER := 0-1962.0724
    , p6_a11  NUMBER := 0-1962.0724
    , p6_a12  NUMBER := 0-1962.0724
    , p6_a13  NUMBER := 0-1962.0724
    , p6_a14  VARCHAR2 := fnd_api.g_miss_char
    , p6_a15  VARCHAR2 := fnd_api.g_miss_char
    , p6_a16  VARCHAR2 := fnd_api.g_miss_char
    , p6_a17  DATE := fnd_api.g_miss_date
    , p6_a18  NUMBER := 0-1962.0724
  )
  as
    ddp_cell_rec ams_cell_pvt.cell_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any






    ddp_cell_rec.cell_id := rosetta_g_miss_num_map(p6_a0);
    ddp_cell_rec.sel_type := p6_a1;
    ddp_cell_rec.last_update_date := rosetta_g_miss_date_in_map(p6_a2);
    ddp_cell_rec.last_updated_by := rosetta_g_miss_num_map(p6_a3);
    ddp_cell_rec.creation_date := rosetta_g_miss_date_in_map(p6_a4);
    ddp_cell_rec.created_by := rosetta_g_miss_num_map(p6_a5);
    ddp_cell_rec.last_update_login := rosetta_g_miss_num_map(p6_a6);
    ddp_cell_rec.object_version_number := rosetta_g_miss_num_map(p6_a7);
    ddp_cell_rec.cell_code := p6_a8;
    ddp_cell_rec.enabled_flag := p6_a9;
    ddp_cell_rec.original_size := rosetta_g_miss_num_map(p6_a10);
    ddp_cell_rec.parent_cell_id := rosetta_g_miss_num_map(p6_a11);
    ddp_cell_rec.org_id := rosetta_g_miss_num_map(p6_a12);
    ddp_cell_rec.owner_id := rosetta_g_miss_num_map(p6_a13);
    ddp_cell_rec.cell_name := p6_a14;
    ddp_cell_rec.description := p6_a15;
    ddp_cell_rec.status_code := p6_a16;
    ddp_cell_rec.status_date := rosetta_g_miss_date_in_map(p6_a17);
    ddp_cell_rec.user_status_id := rosetta_g_miss_num_map(p6_a18);

    -- here's the delegated call to the old PL/SQL routine
    ams_cell_pvt.validate_cell(p_api_version,
      p_init_msg_list,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_cell_rec);

    -- copy data back from the local OUT or IN-OUT args, if any






  end;

  procedure check_cell_items(p_validation_mode  VARCHAR2
    , x_return_status OUT NOCOPY  VARCHAR2
    , p0_a0  NUMBER := 0-1962.0724
    , p0_a1  VARCHAR2 := fnd_api.g_miss_char
    , p0_a2  DATE := fnd_api.g_miss_date
    , p0_a3  NUMBER := 0-1962.0724
    , p0_a4  DATE := fnd_api.g_miss_date
    , p0_a5  NUMBER := 0-1962.0724
    , p0_a6  NUMBER := 0-1962.0724
    , p0_a7  NUMBER := 0-1962.0724
    , p0_a8  VARCHAR2 := fnd_api.g_miss_char
    , p0_a9  VARCHAR2 := fnd_api.g_miss_char
    , p0_a10  NUMBER := 0-1962.0724
    , p0_a11  NUMBER := 0-1962.0724
    , p0_a12  NUMBER := 0-1962.0724
    , p0_a13  NUMBER := 0-1962.0724
    , p0_a14  VARCHAR2 := fnd_api.g_miss_char
    , p0_a15  VARCHAR2 := fnd_api.g_miss_char
    , p0_a16  VARCHAR2 := fnd_api.g_miss_char
    , p0_a17  DATE := fnd_api.g_miss_date
    , p0_a18  NUMBER := 0-1962.0724
  )
  as
    ddp_cell_rec ams_cell_pvt.cell_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_cell_rec.cell_id := rosetta_g_miss_num_map(p0_a0);
    ddp_cell_rec.sel_type := p0_a1;
    ddp_cell_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a2);
    ddp_cell_rec.last_updated_by := rosetta_g_miss_num_map(p0_a3);
    ddp_cell_rec.creation_date := rosetta_g_miss_date_in_map(p0_a4);
    ddp_cell_rec.created_by := rosetta_g_miss_num_map(p0_a5);
    ddp_cell_rec.last_update_login := rosetta_g_miss_num_map(p0_a6);
    ddp_cell_rec.object_version_number := rosetta_g_miss_num_map(p0_a7);
    ddp_cell_rec.cell_code := p0_a8;
    ddp_cell_rec.enabled_flag := p0_a9;
    ddp_cell_rec.original_size := rosetta_g_miss_num_map(p0_a10);
    ddp_cell_rec.parent_cell_id := rosetta_g_miss_num_map(p0_a11);
    ddp_cell_rec.org_id := rosetta_g_miss_num_map(p0_a12);
    ddp_cell_rec.owner_id := rosetta_g_miss_num_map(p0_a13);
    ddp_cell_rec.cell_name := p0_a14;
    ddp_cell_rec.description := p0_a15;
    ddp_cell_rec.status_code := p0_a16;
    ddp_cell_rec.status_date := rosetta_g_miss_date_in_map(p0_a17);
    ddp_cell_rec.user_status_id := rosetta_g_miss_num_map(p0_a18);



    -- here's the delegated call to the old PL/SQL routine
    ams_cell_pvt.check_cell_items(ddp_cell_rec,
      p_validation_mode,
      x_return_status);

    -- copy data back from the local OUT or IN-OUT args, if any


  end;

  procedure init_cell_rec(p0_a0 OUT NOCOPY  NUMBER
    , p0_a1 OUT NOCOPY  VARCHAR2
    , p0_a2 OUT NOCOPY  DATE
    , p0_a3 OUT NOCOPY  NUMBER
    , p0_a4 OUT NOCOPY  DATE
    , p0_a5 OUT NOCOPY  NUMBER
    , p0_a6 OUT NOCOPY  NUMBER
    , p0_a7 OUT NOCOPY  NUMBER
    , p0_a8 OUT NOCOPY  VARCHAR2
    , p0_a9 OUT NOCOPY  VARCHAR2
    , p0_a10 OUT NOCOPY  NUMBER
    , p0_a11 OUT NOCOPY  NUMBER
    , p0_a12 OUT NOCOPY  NUMBER
    , p0_a13 OUT NOCOPY  NUMBER
    , p0_a14 OUT NOCOPY  VARCHAR2
    , p0_a15 OUT NOCOPY  VARCHAR2
    , p0_a16 OUT NOCOPY  VARCHAR2
    , p0_a17 OUT NOCOPY  DATE
    , p0_a18 OUT NOCOPY  NUMBER
  )
  as
    ddx_cell_rec ams_cell_pvt.cell_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    -- here's the delegated call to the old PL/SQL routine
    ams_cell_pvt.init_cell_rec(ddx_cell_rec);

    -- copy data back from the local OUT or IN-OUT args, if any
    p0_a0 := rosetta_g_miss_num_map(ddx_cell_rec.cell_id);
    p0_a1 := ddx_cell_rec.sel_type;
    p0_a2 := ddx_cell_rec.last_update_date;
    p0_a3 := rosetta_g_miss_num_map(ddx_cell_rec.last_updated_by);
    p0_a4 := ddx_cell_rec.creation_date;
    p0_a5 := rosetta_g_miss_num_map(ddx_cell_rec.created_by);
    p0_a6 := rosetta_g_miss_num_map(ddx_cell_rec.last_update_login);
    p0_a7 := rosetta_g_miss_num_map(ddx_cell_rec.object_version_number);
    p0_a8 := ddx_cell_rec.cell_code;
    p0_a9 := ddx_cell_rec.enabled_flag;
    p0_a10 := rosetta_g_miss_num_map(ddx_cell_rec.original_size);
    p0_a11 := rosetta_g_miss_num_map(ddx_cell_rec.parent_cell_id);
    p0_a12 := rosetta_g_miss_num_map(ddx_cell_rec.org_id);
    p0_a13 := rosetta_g_miss_num_map(ddx_cell_rec.owner_id);
    p0_a14 := ddx_cell_rec.cell_name;
    p0_a15 := ddx_cell_rec.description;
    p0_a16 := ddx_cell_rec.status_code;
    p0_a17 := ddx_cell_rec.status_date;
    p0_a18 := rosetta_g_miss_num_map(ddx_cell_rec.user_status_id);
  end;

  procedure complete_cell_rec(p1_a0 OUT NOCOPY  NUMBER
    , p1_a1 OUT NOCOPY  VARCHAR2
    , p1_a2 OUT NOCOPY  DATE
    , p1_a3 OUT NOCOPY  NUMBER
    , p1_a4 OUT NOCOPY  DATE
    , p1_a5 OUT NOCOPY  NUMBER
    , p1_a6 OUT NOCOPY  NUMBER
    , p1_a7 OUT NOCOPY  NUMBER
    , p1_a8 OUT NOCOPY  VARCHAR2
    , p1_a9 OUT NOCOPY  VARCHAR2
    , p1_a10 OUT NOCOPY  NUMBER
    , p1_a11 OUT NOCOPY  NUMBER
    , p1_a12 OUT NOCOPY  NUMBER
    , p1_a13 OUT NOCOPY  NUMBER
    , p1_a14 OUT NOCOPY  VARCHAR2
    , p1_a15 OUT NOCOPY  VARCHAR2
    , p1_a16 OUT NOCOPY  VARCHAR2
    , p1_a17 OUT NOCOPY  DATE
    , p1_a18 OUT NOCOPY  NUMBER
    , p0_a0  NUMBER := 0-1962.0724
    , p0_a1  VARCHAR2 := fnd_api.g_miss_char
    , p0_a2  DATE := fnd_api.g_miss_date
    , p0_a3  NUMBER := 0-1962.0724
    , p0_a4  DATE := fnd_api.g_miss_date
    , p0_a5  NUMBER := 0-1962.0724
    , p0_a6  NUMBER := 0-1962.0724
    , p0_a7  NUMBER := 0-1962.0724
    , p0_a8  VARCHAR2 := fnd_api.g_miss_char
    , p0_a9  VARCHAR2 := fnd_api.g_miss_char
    , p0_a10  NUMBER := 0-1962.0724
    , p0_a11  NUMBER := 0-1962.0724
    , p0_a12  NUMBER := 0-1962.0724
    , p0_a13  NUMBER := 0-1962.0724
    , p0_a14  VARCHAR2 := fnd_api.g_miss_char
    , p0_a15  VARCHAR2 := fnd_api.g_miss_char
    , p0_a16  VARCHAR2 := fnd_api.g_miss_char
    , p0_a17  DATE := fnd_api.g_miss_date
    , p0_a18  NUMBER := 0-1962.0724
  )
  as
    ddp_cell_rec ams_cell_pvt.cell_rec_type;
    ddx_complete_rec ams_cell_pvt.cell_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_cell_rec.cell_id := rosetta_g_miss_num_map(p0_a0);
    ddp_cell_rec.sel_type := p0_a1;
    ddp_cell_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a2);
    ddp_cell_rec.last_updated_by := rosetta_g_miss_num_map(p0_a3);
    ddp_cell_rec.creation_date := rosetta_g_miss_date_in_map(p0_a4);
    ddp_cell_rec.created_by := rosetta_g_miss_num_map(p0_a5);
    ddp_cell_rec.last_update_login := rosetta_g_miss_num_map(p0_a6);
    ddp_cell_rec.object_version_number := rosetta_g_miss_num_map(p0_a7);
    ddp_cell_rec.cell_code := p0_a8;
    ddp_cell_rec.enabled_flag := p0_a9;
    ddp_cell_rec.original_size := rosetta_g_miss_num_map(p0_a10);
    ddp_cell_rec.parent_cell_id := rosetta_g_miss_num_map(p0_a11);
    ddp_cell_rec.org_id := rosetta_g_miss_num_map(p0_a12);
    ddp_cell_rec.owner_id := rosetta_g_miss_num_map(p0_a13);
    ddp_cell_rec.cell_name := p0_a14;
    ddp_cell_rec.description := p0_a15;
    ddp_cell_rec.status_code := p0_a16;
    ddp_cell_rec.status_date := rosetta_g_miss_date_in_map(p0_a17);
    ddp_cell_rec.user_status_id := rosetta_g_miss_num_map(p0_a18);


    -- here's the delegated call to the old PL/SQL routine
    ams_cell_pvt.complete_cell_rec(ddp_cell_rec,
      ddx_complete_rec);

    -- copy data back from the local OUT or IN-OUT args, if any

    p1_a0 := rosetta_g_miss_num_map(ddx_complete_rec.cell_id);
    p1_a1 := ddx_complete_rec.sel_type;
    p1_a2 := ddx_complete_rec.last_update_date;
    p1_a3 := rosetta_g_miss_num_map(ddx_complete_rec.last_updated_by);
    p1_a4 := ddx_complete_rec.creation_date;
    p1_a5 := rosetta_g_miss_num_map(ddx_complete_rec.created_by);
    p1_a6 := rosetta_g_miss_num_map(ddx_complete_rec.last_update_login);
    p1_a7 := rosetta_g_miss_num_map(ddx_complete_rec.object_version_number);
    p1_a8 := ddx_complete_rec.cell_code;
    p1_a9 := ddx_complete_rec.enabled_flag;
    p1_a10 := rosetta_g_miss_num_map(ddx_complete_rec.original_size);
    p1_a11 := rosetta_g_miss_num_map(ddx_complete_rec.parent_cell_id);
    p1_a12 := rosetta_g_miss_num_map(ddx_complete_rec.org_id);
    p1_a13 := rosetta_g_miss_num_map(ddx_complete_rec.owner_id);
    p1_a14 := ddx_complete_rec.cell_name;
    p1_a15 := ddx_complete_rec.description;
    p1_a16 := ddx_complete_rec.status_code;
    p1_a17 := ddx_complete_rec.status_date;
    p1_a18 := rosetta_g_miss_num_map(ddx_complete_rec.user_status_id);
  end;

  procedure create_sql_cell(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status OUT NOCOPY  VARCHAR2
    , x_msg_count OUT NOCOPY  NUMBER
    , x_msg_data OUT NOCOPY  VARCHAR2
    , x_cell_id OUT NOCOPY  NUMBER
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  VARCHAR2 := fnd_api.g_miss_char
    , p7_a2  DATE := fnd_api.g_miss_date
    , p7_a3  NUMBER := 0-1962.0724
    , p7_a4  DATE := fnd_api.g_miss_date
    , p7_a5  NUMBER := 0-1962.0724
    , p7_a6  NUMBER := 0-1962.0724
    , p7_a7  NUMBER := 0-1962.0724
    , p7_a8  VARCHAR2 := fnd_api.g_miss_char
    , p7_a9  VARCHAR2 := fnd_api.g_miss_char
    , p7_a10  NUMBER := 0-1962.0724
    , p7_a11  NUMBER := 0-1962.0724
    , p7_a12  NUMBER := 0-1962.0724
    , p7_a13  NUMBER := 0-1962.0724
    , p7_a14  VARCHAR2 := fnd_api.g_miss_char
    , p7_a15  VARCHAR2 := fnd_api.g_miss_char
    , p7_a16  VARCHAR2 := fnd_api.g_miss_char
    , p7_a17  DATE := fnd_api.g_miss_date
    , p7_a18  NUMBER := 0-1962.0724
    , p7_a19  NUMBER := 0-1962.0724
    , p7_a20  VARCHAR2 := fnd_api.g_miss_char
    , p7_a21  VARCHAR2 := fnd_api.g_miss_char
    , p7_a22  VARCHAR2 := fnd_api.g_miss_char
    , p7_a23  NUMBER := 0-1962.0724
    , p7_a24  NUMBER := 0-1962.0724
    , p7_a25  NUMBER := 0-1962.0724
    , p7_a26  VARCHAR2 := fnd_api.g_miss_char
    , p7_a27  VARCHAR2 := fnd_api.g_miss_char
    , p7_a28  NUMBER := 0-1962.0724
  )
  as
    ddp_sql_cell_rec ams_cell_pvt.sqlcell_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_sql_cell_rec.cell_id := rosetta_g_miss_num_map(p7_a0);
    ddp_sql_cell_rec.sel_type := p7_a1;
    ddp_sql_cell_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a2);
    ddp_sql_cell_rec.last_updated_by := rosetta_g_miss_num_map(p7_a3);
    ddp_sql_cell_rec.creation_date := rosetta_g_miss_date_in_map(p7_a4);
    ddp_sql_cell_rec.created_by := rosetta_g_miss_num_map(p7_a5);
    ddp_sql_cell_rec.last_update_login := rosetta_g_miss_num_map(p7_a6);
    ddp_sql_cell_rec.object_version_number := rosetta_g_miss_num_map(p7_a7);
    ddp_sql_cell_rec.cell_code := p7_a8;
    ddp_sql_cell_rec.enabled_flag := p7_a9;
    ddp_sql_cell_rec.original_size := rosetta_g_miss_num_map(p7_a10);
    ddp_sql_cell_rec.parent_cell_id := rosetta_g_miss_num_map(p7_a11);
    ddp_sql_cell_rec.org_id := rosetta_g_miss_num_map(p7_a12);
    ddp_sql_cell_rec.owner_id := rosetta_g_miss_num_map(p7_a13);
    ddp_sql_cell_rec.cell_name := p7_a14;
    ddp_sql_cell_rec.description := p7_a15;
    ddp_sql_cell_rec.status_code := p7_a16;
    ddp_sql_cell_rec.status_date := rosetta_g_miss_date_in_map(p7_a17);
    ddp_sql_cell_rec.user_status_id := rosetta_g_miss_num_map(p7_a18);
    ddp_sql_cell_rec.discoverer_sql_id := rosetta_g_miss_num_map(p7_a19);
    ddp_sql_cell_rec.workbook_owner := p7_a20;
    ddp_sql_cell_rec.workbook_name := p7_a21;
    ddp_sql_cell_rec.worksheet_name := p7_a22;
    ddp_sql_cell_rec.activity_discoverer_id := rosetta_g_miss_num_map(p7_a23);
    ddp_sql_cell_rec.act_disc_version_number := rosetta_g_miss_num_map(p7_a24);
    ddp_sql_cell_rec.list_query_id := rosetta_g_miss_num_map(p7_a25);
    ddp_sql_cell_rec.list_sql_string := p7_a26;
    ddp_sql_cell_rec.source_object_name := p7_a27;
    ddp_sql_cell_rec.list_query_version_number := rosetta_g_miss_num_map(p7_a28);


    -- here's the delegated call to the old PL/SQL routine
    ams_cell_pvt.create_sql_cell(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_sql_cell_rec,
      x_cell_id);

    -- copy data back from the local OUT or IN-OUT args, if any








  end;

  procedure update_sql_cell(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status OUT NOCOPY  VARCHAR2
    , x_msg_count OUT NOCOPY  NUMBER
    , x_msg_data OUT NOCOPY  VARCHAR2
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  VARCHAR2 := fnd_api.g_miss_char
    , p7_a2  DATE := fnd_api.g_miss_date
    , p7_a3  NUMBER := 0-1962.0724
    , p7_a4  DATE := fnd_api.g_miss_date
    , p7_a5  NUMBER := 0-1962.0724
    , p7_a6  NUMBER := 0-1962.0724
    , p7_a7  NUMBER := 0-1962.0724
    , p7_a8  VARCHAR2 := fnd_api.g_miss_char
    , p7_a9  VARCHAR2 := fnd_api.g_miss_char
    , p7_a10  NUMBER := 0-1962.0724
    , p7_a11  NUMBER := 0-1962.0724
    , p7_a12  NUMBER := 0-1962.0724
    , p7_a13  NUMBER := 0-1962.0724
    , p7_a14  VARCHAR2 := fnd_api.g_miss_char
    , p7_a15  VARCHAR2 := fnd_api.g_miss_char
    , p7_a16  VARCHAR2 := fnd_api.g_miss_char
    , p7_a17  DATE := fnd_api.g_miss_date
    , p7_a18  NUMBER := 0-1962.0724
    , p7_a19  NUMBER := 0-1962.0724
    , p7_a20  VARCHAR2 := fnd_api.g_miss_char
    , p7_a21  VARCHAR2 := fnd_api.g_miss_char
    , p7_a22  VARCHAR2 := fnd_api.g_miss_char
    , p7_a23  NUMBER := 0-1962.0724
    , p7_a24  NUMBER := 0-1962.0724
    , p7_a25  NUMBER := 0-1962.0724
    , p7_a26  VARCHAR2 := fnd_api.g_miss_char
    , p7_a27  VARCHAR2 := fnd_api.g_miss_char
    , p7_a28  NUMBER := 0-1962.0724
  )
  as
    ddp_sql_cell_rec ams_cell_pvt.sqlcell_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_sql_cell_rec.cell_id := rosetta_g_miss_num_map(p7_a0);
    ddp_sql_cell_rec.sel_type := p7_a1;
    ddp_sql_cell_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a2);
    ddp_sql_cell_rec.last_updated_by := rosetta_g_miss_num_map(p7_a3);
    ddp_sql_cell_rec.creation_date := rosetta_g_miss_date_in_map(p7_a4);
    ddp_sql_cell_rec.created_by := rosetta_g_miss_num_map(p7_a5);
    ddp_sql_cell_rec.last_update_login := rosetta_g_miss_num_map(p7_a6);
    ddp_sql_cell_rec.object_version_number := rosetta_g_miss_num_map(p7_a7);
    ddp_sql_cell_rec.cell_code := p7_a8;
    ddp_sql_cell_rec.enabled_flag := p7_a9;
    ddp_sql_cell_rec.original_size := rosetta_g_miss_num_map(p7_a10);
    ddp_sql_cell_rec.parent_cell_id := rosetta_g_miss_num_map(p7_a11);
    ddp_sql_cell_rec.org_id := rosetta_g_miss_num_map(p7_a12);
    ddp_sql_cell_rec.owner_id := rosetta_g_miss_num_map(p7_a13);
    ddp_sql_cell_rec.cell_name := p7_a14;
    ddp_sql_cell_rec.description := p7_a15;
    ddp_sql_cell_rec.status_code := p7_a16;
    ddp_sql_cell_rec.status_date := rosetta_g_miss_date_in_map(p7_a17);
    ddp_sql_cell_rec.user_status_id := rosetta_g_miss_num_map(p7_a18);
    ddp_sql_cell_rec.discoverer_sql_id := rosetta_g_miss_num_map(p7_a19);
    ddp_sql_cell_rec.workbook_owner := p7_a20;
    ddp_sql_cell_rec.workbook_name := p7_a21;
    ddp_sql_cell_rec.worksheet_name := p7_a22;
    ddp_sql_cell_rec.activity_discoverer_id := rosetta_g_miss_num_map(p7_a23);
    ddp_sql_cell_rec.act_disc_version_number := rosetta_g_miss_num_map(p7_a24);
    ddp_sql_cell_rec.list_query_id := rosetta_g_miss_num_map(p7_a25);
    ddp_sql_cell_rec.list_sql_string := p7_a26;
    ddp_sql_cell_rec.source_object_name := p7_a27;
    ddp_sql_cell_rec.list_query_version_number := rosetta_g_miss_num_map(p7_a28);

    -- here's the delegated call to the old PL/SQL routine
    ams_cell_pvt.update_sql_cell(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_sql_cell_rec);

    -- copy data back from the local OUT or IN-OUT args, if any







  end;

end ams_cell_pvt_w;

/
