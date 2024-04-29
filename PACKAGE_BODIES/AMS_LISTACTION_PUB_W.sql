--------------------------------------------------------
--  DDL for Package Body AMS_LISTACTION_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_LISTACTION_PUB_W" as
  /* $Header: amszlsab.pls 115.7 2002/11/22 08:58:22 jieli ship $ */
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
    ams_listaction_pub.create_listaction(p_api_version,
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
    ams_listaction_pub.update_listaction(p_api_version,
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
    ams_listaction_pub.validate_listaction(p_api_version,
      p_init_msg_list,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_action_rec);

    -- copy data back from the local OUT or IN-OUT args, if any






  end;

end ams_listaction_pub_w;

/
