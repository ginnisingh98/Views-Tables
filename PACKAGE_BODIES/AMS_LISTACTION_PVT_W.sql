--------------------------------------------------------
--  DDL for Package Body AMS_LISTACTION_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_LISTACTION_PVT_W" as
  /* $Header: amswlsab.pls 115.13 2002/11/22 08:57:30 jieli ship $ */
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

  procedure create_listaction(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status OUT NOCOPY  VARCHAR2
    , x_msg_count OUT NOCOPY  NUMBER
    , x_msg_data OUT NOCOPY  VARCHAR2
    , x_action_id OUT NOCOPY  NUMBER
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  DATE := fnd_api.g_miss_date
    , p7_a2  NUMBER := 0-1962.0724
    , p7_a3  DATE := fnd_api.g_miss_date
    , p7_a4  NUMBER := 0-1962.0724
    , p7_a5  NUMBER := 0-1962.0724
    , p7_a6  NUMBER := 0-1962.0724
    , p7_a7  NUMBER := 0-1962.0724
    , p7_a8  VARCHAR2 := fnd_api.g_miss_char
    , p7_a9  VARCHAR2 := fnd_api.g_miss_char
    , p7_a10  NUMBER := 0-1962.0724
    , p7_a11  NUMBER := 0-1962.0724
    , p7_a12  NUMBER := 0-1962.0724
    , p7_a13  NUMBER := 0-1962.0724
    , p7_a14  NUMBER := 0-1962.0724
    , p7_a15  NUMBER := 0-1962.0724
    , p7_a16  VARCHAR2 := fnd_api.g_miss_char
    , p7_a17  VARCHAR2 := fnd_api.g_miss_char
    , p7_a18  VARCHAR2 := fnd_api.g_miss_char
    , p7_a19  NUMBER := 0-1962.0724
    , p7_a20  NUMBER := 0-1962.0724
    , p7_a21  VARCHAR2 := fnd_api.g_miss_char
  )
  as
    ddp_action_rec ams_listaction_pvt.action_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_action_rec.list_select_action_id := rosetta_g_miss_num_map(p7_a0);
    ddp_action_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a1);
    ddp_action_rec.last_updated_by := rosetta_g_miss_num_map(p7_a2);
    ddp_action_rec.creation_date := rosetta_g_miss_date_in_map(p7_a3);
    ddp_action_rec.created_by := rosetta_g_miss_num_map(p7_a4);
    ddp_action_rec.last_update_login := rosetta_g_miss_num_map(p7_a5);
    ddp_action_rec.object_version_number := rosetta_g_miss_num_map(p7_a6);
    ddp_action_rec.order_number := rosetta_g_miss_num_map(p7_a7);
    ddp_action_rec.list_action_type := p7_a8;
    ddp_action_rec.arc_incl_object_from := p7_a9;
    ddp_action_rec.incl_object_id := rosetta_g_miss_num_map(p7_a10);
    ddp_action_rec.rank := rosetta_g_miss_num_map(p7_a11);
    ddp_action_rec.no_of_rows_available := rosetta_g_miss_num_map(p7_a12);
    ddp_action_rec.no_of_rows_requested := rosetta_g_miss_num_map(p7_a13);
    ddp_action_rec.no_of_rows_used := rosetta_g_miss_num_map(p7_a14);
    ddp_action_rec.distribution_pct := rosetta_g_miss_num_map(p7_a15);
    ddp_action_rec.result_text := p7_a16;
    ddp_action_rec.description := p7_a17;
    ddp_action_rec.arc_action_used_by := p7_a18;
    ddp_action_rec.action_used_by_id := rosetta_g_miss_num_map(p7_a19);
    ddp_action_rec.no_of_rows_targeted := rosetta_g_miss_num_map(p7_a20);
    ddp_action_rec.incl_control_group := p7_a21;


    -- here's the delegated call to the old PL/SQL routine
    ams_listaction_pvt.create_listaction(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_action_rec,
      x_action_id);

    -- copy data back from the local OUT or IN-OUT args, if any








  end;

  procedure update_listaction(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status OUT NOCOPY  VARCHAR2
    , x_msg_count OUT NOCOPY  NUMBER
    , x_msg_data OUT NOCOPY  VARCHAR2
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  DATE := fnd_api.g_miss_date
    , p7_a2  NUMBER := 0-1962.0724
    , p7_a3  DATE := fnd_api.g_miss_date
    , p7_a4  NUMBER := 0-1962.0724
    , p7_a5  NUMBER := 0-1962.0724
    , p7_a6  NUMBER := 0-1962.0724
    , p7_a7  NUMBER := 0-1962.0724
    , p7_a8  VARCHAR2 := fnd_api.g_miss_char
    , p7_a9  VARCHAR2 := fnd_api.g_miss_char
    , p7_a10  NUMBER := 0-1962.0724
    , p7_a11  NUMBER := 0-1962.0724
    , p7_a12  NUMBER := 0-1962.0724
    , p7_a13  NUMBER := 0-1962.0724
    , p7_a14  NUMBER := 0-1962.0724
    , p7_a15  NUMBER := 0-1962.0724
    , p7_a16  VARCHAR2 := fnd_api.g_miss_char
    , p7_a17  VARCHAR2 := fnd_api.g_miss_char
    , p7_a18  VARCHAR2 := fnd_api.g_miss_char
    , p7_a19  NUMBER := 0-1962.0724
    , p7_a20  NUMBER := 0-1962.0724
    , p7_a21  VARCHAR2 := fnd_api.g_miss_char
  )
  as
    ddp_action_rec ams_listaction_pvt.action_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_action_rec.list_select_action_id := rosetta_g_miss_num_map(p7_a0);
    ddp_action_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a1);
    ddp_action_rec.last_updated_by := rosetta_g_miss_num_map(p7_a2);
    ddp_action_rec.creation_date := rosetta_g_miss_date_in_map(p7_a3);
    ddp_action_rec.created_by := rosetta_g_miss_num_map(p7_a4);
    ddp_action_rec.last_update_login := rosetta_g_miss_num_map(p7_a5);
    ddp_action_rec.object_version_number := rosetta_g_miss_num_map(p7_a6);
    ddp_action_rec.order_number := rosetta_g_miss_num_map(p7_a7);
    ddp_action_rec.list_action_type := p7_a8;
    ddp_action_rec.arc_incl_object_from := p7_a9;
    ddp_action_rec.incl_object_id := rosetta_g_miss_num_map(p7_a10);
    ddp_action_rec.rank := rosetta_g_miss_num_map(p7_a11);
    ddp_action_rec.no_of_rows_available := rosetta_g_miss_num_map(p7_a12);
    ddp_action_rec.no_of_rows_requested := rosetta_g_miss_num_map(p7_a13);
    ddp_action_rec.no_of_rows_used := rosetta_g_miss_num_map(p7_a14);
    ddp_action_rec.distribution_pct := rosetta_g_miss_num_map(p7_a15);
    ddp_action_rec.result_text := p7_a16;
    ddp_action_rec.description := p7_a17;
    ddp_action_rec.arc_action_used_by := p7_a18;
    ddp_action_rec.action_used_by_id := rosetta_g_miss_num_map(p7_a19);
    ddp_action_rec.no_of_rows_targeted := rosetta_g_miss_num_map(p7_a20);
    ddp_action_rec.incl_control_group := p7_a21;

    -- here's the delegated call to the old PL/SQL routine
    ams_listaction_pvt.update_listaction(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_action_rec);

    -- copy data back from the local OUT or IN-OUT args, if any







  end;

  procedure validate_listaction(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status OUT NOCOPY  VARCHAR2
    , x_msg_count OUT NOCOPY  NUMBER
    , x_msg_data OUT NOCOPY  VARCHAR2
    , p6_a0  NUMBER := 0-1962.0724
    , p6_a1  DATE := fnd_api.g_miss_date
    , p6_a2  NUMBER := 0-1962.0724
    , p6_a3  DATE := fnd_api.g_miss_date
    , p6_a4  NUMBER := 0-1962.0724
    , p6_a5  NUMBER := 0-1962.0724
    , p6_a6  NUMBER := 0-1962.0724
    , p6_a7  NUMBER := 0-1962.0724
    , p6_a8  VARCHAR2 := fnd_api.g_miss_char
    , p6_a9  VARCHAR2 := fnd_api.g_miss_char
    , p6_a10  NUMBER := 0-1962.0724
    , p6_a11  NUMBER := 0-1962.0724
    , p6_a12  NUMBER := 0-1962.0724
    , p6_a13  NUMBER := 0-1962.0724
    , p6_a14  NUMBER := 0-1962.0724
    , p6_a15  NUMBER := 0-1962.0724
    , p6_a16  VARCHAR2 := fnd_api.g_miss_char
    , p6_a17  VARCHAR2 := fnd_api.g_miss_char
    , p6_a18  VARCHAR2 := fnd_api.g_miss_char
    , p6_a19  NUMBER := 0-1962.0724
    , p6_a20  NUMBER := 0-1962.0724
    , p6_a21  VARCHAR2 := fnd_api.g_miss_char
  )
  as
    ddp_action_rec ams_listaction_pvt.action_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any






    ddp_action_rec.list_select_action_id := rosetta_g_miss_num_map(p6_a0);
    ddp_action_rec.last_update_date := rosetta_g_miss_date_in_map(p6_a1);
    ddp_action_rec.last_updated_by := rosetta_g_miss_num_map(p6_a2);
    ddp_action_rec.creation_date := rosetta_g_miss_date_in_map(p6_a3);
    ddp_action_rec.created_by := rosetta_g_miss_num_map(p6_a4);
    ddp_action_rec.last_update_login := rosetta_g_miss_num_map(p6_a5);
    ddp_action_rec.object_version_number := rosetta_g_miss_num_map(p6_a6);
    ddp_action_rec.order_number := rosetta_g_miss_num_map(p6_a7);
    ddp_action_rec.list_action_type := p6_a8;
    ddp_action_rec.arc_incl_object_from := p6_a9;
    ddp_action_rec.incl_object_id := rosetta_g_miss_num_map(p6_a10);
    ddp_action_rec.rank := rosetta_g_miss_num_map(p6_a11);
    ddp_action_rec.no_of_rows_available := rosetta_g_miss_num_map(p6_a12);
    ddp_action_rec.no_of_rows_requested := rosetta_g_miss_num_map(p6_a13);
    ddp_action_rec.no_of_rows_used := rosetta_g_miss_num_map(p6_a14);
    ddp_action_rec.distribution_pct := rosetta_g_miss_num_map(p6_a15);
    ddp_action_rec.result_text := p6_a16;
    ddp_action_rec.description := p6_a17;
    ddp_action_rec.arc_action_used_by := p6_a18;
    ddp_action_rec.action_used_by_id := rosetta_g_miss_num_map(p6_a19);
    ddp_action_rec.no_of_rows_targeted := rosetta_g_miss_num_map(p6_a20);
    ddp_action_rec.incl_control_group := p6_a21;

    -- here's the delegated call to the old PL/SQL routine
    ams_listaction_pvt.validate_listaction(p_api_version,
      p_init_msg_list,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_action_rec);

    -- copy data back from the local OUT or IN-OUT args, if any






  end;

  procedure init_action_rec(p0_a0 OUT NOCOPY  NUMBER
    , p0_a1 OUT NOCOPY  DATE
    , p0_a2 OUT NOCOPY  NUMBER
    , p0_a3 OUT NOCOPY  DATE
    , p0_a4 OUT NOCOPY  NUMBER
    , p0_a5 OUT NOCOPY  NUMBER
    , p0_a6 OUT NOCOPY  NUMBER
    , p0_a7 OUT NOCOPY  NUMBER
    , p0_a8 OUT NOCOPY  VARCHAR2
    , p0_a9 OUT NOCOPY  VARCHAR2
    , p0_a10 OUT NOCOPY  NUMBER
    , p0_a11 OUT NOCOPY  NUMBER
    , p0_a12 OUT NOCOPY  NUMBER
    , p0_a13 OUT NOCOPY  NUMBER
    , p0_a14 OUT NOCOPY  NUMBER
    , p0_a15 OUT NOCOPY  NUMBER
    , p0_a16 OUT NOCOPY  VARCHAR2
    , p0_a17 OUT NOCOPY  VARCHAR2
    , p0_a18 OUT NOCOPY  VARCHAR2
    , p0_a19 OUT NOCOPY  NUMBER
    , p0_a20 OUT NOCOPY  NUMBER
    , p0_a21 OUT NOCOPY  VARCHAR2
  )
  as
    ddx_action_rec ams_listaction_pvt.action_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    -- here's the delegated call to the old PL/SQL routine
    ams_listaction_pvt.init_action_rec(ddx_action_rec);

    -- copy data back from the local OUT or IN-OUT args, if any
    p0_a0 := rosetta_g_miss_num_map(ddx_action_rec.list_select_action_id);
    p0_a1 := ddx_action_rec.last_update_date;
    p0_a2 := rosetta_g_miss_num_map(ddx_action_rec.last_updated_by);
    p0_a3 := ddx_action_rec.creation_date;
    p0_a4 := rosetta_g_miss_num_map(ddx_action_rec.created_by);
    p0_a5 := rosetta_g_miss_num_map(ddx_action_rec.last_update_login);
    p0_a6 := rosetta_g_miss_num_map(ddx_action_rec.object_version_number);
    p0_a7 := rosetta_g_miss_num_map(ddx_action_rec.order_number);
    p0_a8 := ddx_action_rec.list_action_type;
    p0_a9 := ddx_action_rec.arc_incl_object_from;
    p0_a10 := rosetta_g_miss_num_map(ddx_action_rec.incl_object_id);
    p0_a11 := rosetta_g_miss_num_map(ddx_action_rec.rank);
    p0_a12 := rosetta_g_miss_num_map(ddx_action_rec.no_of_rows_available);
    p0_a13 := rosetta_g_miss_num_map(ddx_action_rec.no_of_rows_requested);
    p0_a14 := rosetta_g_miss_num_map(ddx_action_rec.no_of_rows_used);
    p0_a15 := rosetta_g_miss_num_map(ddx_action_rec.distribution_pct);
    p0_a16 := ddx_action_rec.result_text;
    p0_a17 := ddx_action_rec.description;
    p0_a18 := ddx_action_rec.arc_action_used_by;
    p0_a19 := rosetta_g_miss_num_map(ddx_action_rec.action_used_by_id);
    p0_a20 := rosetta_g_miss_num_map(ddx_action_rec.no_of_rows_targeted);
    p0_a21 := ddx_action_rec.incl_control_group;
  end;

  procedure complete_action_rec(p1_a0 OUT NOCOPY  NUMBER
    , p1_a1 OUT NOCOPY  DATE
    , p1_a2 OUT NOCOPY  NUMBER
    , p1_a3 OUT NOCOPY  DATE
    , p1_a4 OUT NOCOPY  NUMBER
    , p1_a5 OUT NOCOPY  NUMBER
    , p1_a6 OUT NOCOPY  NUMBER
    , p1_a7 OUT NOCOPY  NUMBER
    , p1_a8 OUT NOCOPY  VARCHAR2
    , p1_a9 OUT NOCOPY  VARCHAR2
    , p1_a10 OUT NOCOPY  NUMBER
    , p1_a11 OUT NOCOPY  NUMBER
    , p1_a12 OUT NOCOPY  NUMBER
    , p1_a13 OUT NOCOPY  NUMBER
    , p1_a14 OUT NOCOPY  NUMBER
    , p1_a15 OUT NOCOPY  NUMBER
    , p1_a16 OUT NOCOPY  VARCHAR2
    , p1_a17 OUT NOCOPY  VARCHAR2
    , p1_a18 OUT NOCOPY  VARCHAR2
    , p1_a19 OUT NOCOPY  NUMBER
    , p1_a20 OUT NOCOPY  NUMBER
    , p1_a21 OUT NOCOPY  VARCHAR2
    , p0_a0  NUMBER := 0-1962.0724
    , p0_a1  DATE := fnd_api.g_miss_date
    , p0_a2  NUMBER := 0-1962.0724
    , p0_a3  DATE := fnd_api.g_miss_date
    , p0_a4  NUMBER := 0-1962.0724
    , p0_a5  NUMBER := 0-1962.0724
    , p0_a6  NUMBER := 0-1962.0724
    , p0_a7  NUMBER := 0-1962.0724
    , p0_a8  VARCHAR2 := fnd_api.g_miss_char
    , p0_a9  VARCHAR2 := fnd_api.g_miss_char
    , p0_a10  NUMBER := 0-1962.0724
    , p0_a11  NUMBER := 0-1962.0724
    , p0_a12  NUMBER := 0-1962.0724
    , p0_a13  NUMBER := 0-1962.0724
    , p0_a14  NUMBER := 0-1962.0724
    , p0_a15  NUMBER := 0-1962.0724
    , p0_a16  VARCHAR2 := fnd_api.g_miss_char
    , p0_a17  VARCHAR2 := fnd_api.g_miss_char
    , p0_a18  VARCHAR2 := fnd_api.g_miss_char
    , p0_a19  NUMBER := 0-1962.0724
    , p0_a20  NUMBER := 0-1962.0724
    , p0_a21  VARCHAR2 := fnd_api.g_miss_char
  )
  as
    ddp_action_rec ams_listaction_pvt.action_rec_type;
    ddx_complete_rec ams_listaction_pvt.action_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_action_rec.list_select_action_id := rosetta_g_miss_num_map(p0_a0);
    ddp_action_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a1);
    ddp_action_rec.last_updated_by := rosetta_g_miss_num_map(p0_a2);
    ddp_action_rec.creation_date := rosetta_g_miss_date_in_map(p0_a3);
    ddp_action_rec.created_by := rosetta_g_miss_num_map(p0_a4);
    ddp_action_rec.last_update_login := rosetta_g_miss_num_map(p0_a5);
    ddp_action_rec.object_version_number := rosetta_g_miss_num_map(p0_a6);
    ddp_action_rec.order_number := rosetta_g_miss_num_map(p0_a7);
    ddp_action_rec.list_action_type := p0_a8;
    ddp_action_rec.arc_incl_object_from := p0_a9;
    ddp_action_rec.incl_object_id := rosetta_g_miss_num_map(p0_a10);
    ddp_action_rec.rank := rosetta_g_miss_num_map(p0_a11);
    ddp_action_rec.no_of_rows_available := rosetta_g_miss_num_map(p0_a12);
    ddp_action_rec.no_of_rows_requested := rosetta_g_miss_num_map(p0_a13);
    ddp_action_rec.no_of_rows_used := rosetta_g_miss_num_map(p0_a14);
    ddp_action_rec.distribution_pct := rosetta_g_miss_num_map(p0_a15);
    ddp_action_rec.result_text := p0_a16;
    ddp_action_rec.description := p0_a17;
    ddp_action_rec.arc_action_used_by := p0_a18;
    ddp_action_rec.action_used_by_id := rosetta_g_miss_num_map(p0_a19);
    ddp_action_rec.no_of_rows_targeted := rosetta_g_miss_num_map(p0_a20);
    ddp_action_rec.incl_control_group := p0_a21;


    -- here's the delegated call to the old PL/SQL routine
    ams_listaction_pvt.complete_action_rec(ddp_action_rec,
      ddx_complete_rec);

    -- copy data back from the local OUT or IN-OUT args, if any

    p1_a0 := rosetta_g_miss_num_map(ddx_complete_rec.list_select_action_id);
    p1_a1 := ddx_complete_rec.last_update_date;
    p1_a2 := rosetta_g_miss_num_map(ddx_complete_rec.last_updated_by);
    p1_a3 := ddx_complete_rec.creation_date;
    p1_a4 := rosetta_g_miss_num_map(ddx_complete_rec.created_by);
    p1_a5 := rosetta_g_miss_num_map(ddx_complete_rec.last_update_login);
    p1_a6 := rosetta_g_miss_num_map(ddx_complete_rec.object_version_number);
    p1_a7 := rosetta_g_miss_num_map(ddx_complete_rec.order_number);
    p1_a8 := ddx_complete_rec.list_action_type;
    p1_a9 := ddx_complete_rec.arc_incl_object_from;
    p1_a10 := rosetta_g_miss_num_map(ddx_complete_rec.incl_object_id);
    p1_a11 := rosetta_g_miss_num_map(ddx_complete_rec.rank);
    p1_a12 := rosetta_g_miss_num_map(ddx_complete_rec.no_of_rows_available);
    p1_a13 := rosetta_g_miss_num_map(ddx_complete_rec.no_of_rows_requested);
    p1_a14 := rosetta_g_miss_num_map(ddx_complete_rec.no_of_rows_used);
    p1_a15 := rosetta_g_miss_num_map(ddx_complete_rec.distribution_pct);
    p1_a16 := ddx_complete_rec.result_text;
    p1_a17 := ddx_complete_rec.description;
    p1_a18 := ddx_complete_rec.arc_action_used_by;
    p1_a19 := rosetta_g_miss_num_map(ddx_complete_rec.action_used_by_id);
    p1_a20 := rosetta_g_miss_num_map(ddx_complete_rec.no_of_rows_targeted);
    p1_a21 := ddx_complete_rec.incl_control_group;
  end;

end ams_listaction_pvt_w;

/
