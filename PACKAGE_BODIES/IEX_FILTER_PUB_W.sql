--------------------------------------------------------
--  DDL for Package Body IEX_FILTER_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEX_FILTER_PUB_W" as
  /* $Header: iexwfilb.pls 120.1 2005/07/05 19:56:13 ctlee noship $ */
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

  procedure rosetta_table_copy_in_p2(t out nocopy iex_filter_pub.universe_ids, a0 JTF_NUMBER_TABLE) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx) := rosetta_g_miss_num_map(a0(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p2;
  procedure rosetta_table_copy_out_p2(t iex_filter_pub.universe_ids, a0 out nocopy JTF_NUMBER_TABLE) as
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
          a0(indx) := rosetta_g_miss_num_map(t(ddindx));
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p2;

  procedure validate_filter(p_init_msg_list  VARCHAR2
    , x_dup_status out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p1_a0  NUMBER := 0-1962.0724
    , p1_a1  VARCHAR2 := fnd_api.g_miss_char
    , p1_a2  VARCHAR2 := fnd_api.g_miss_char
    , p1_a3  NUMBER := 0-1962.0724
    , p1_a4  VARCHAR2 := fnd_api.g_miss_char
    , p1_a5  VARCHAR2 := fnd_api.g_miss_char
    , p1_a6  VARCHAR2 := fnd_api.g_miss_char
    , p1_a7  NUMBER := 0-1962.0724
    , p1_a8  NUMBER := 0-1962.0724
    , p1_a9  NUMBER := 0-1962.0724
    , p1_a10  NUMBER := 0-1962.0724
    , p1_a11  DATE := fnd_api.g_miss_date
    , p1_a12  DATE := fnd_api.g_miss_date
    , p1_a13  NUMBER := 0-1962.0724
    , p1_a14  DATE := fnd_api.g_miss_date
    , p1_a15  NUMBER := 0-1962.0724
    , p1_a16  NUMBER := 0-1962.0724
  )

  as
    ddp_filter_rec iex_filter_pub.filter_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    ddp_filter_rec.object_filter_id := rosetta_g_miss_num_map(p1_a0);
    ddp_filter_rec.object_filter_type := p1_a1;
    ddp_filter_rec.object_filter_name := p1_a2;
    ddp_filter_rec.object_id := rosetta_g_miss_num_map(p1_a3);
    ddp_filter_rec.select_column := p1_a4;
    ddp_filter_rec.entity_name := p1_a5;
    ddp_filter_rec.active_flag := p1_a6;
    ddp_filter_rec.object_version_number := rosetta_g_miss_num_map(p1_a7);
    ddp_filter_rec.program_id := rosetta_g_miss_num_map(p1_a8);
    ddp_filter_rec.request_id := rosetta_g_miss_num_map(p1_a9);
    ddp_filter_rec.program_application_id := rosetta_g_miss_num_map(p1_a10);
    ddp_filter_rec.program_update_date := rosetta_g_miss_date_in_map(p1_a11);
    ddp_filter_rec.creation_date := rosetta_g_miss_date_in_map(p1_a12);
    ddp_filter_rec.created_by := rosetta_g_miss_num_map(p1_a13);
    ddp_filter_rec.last_update_date := rosetta_g_miss_date_in_map(p1_a14);
    ddp_filter_rec.last_updated_by := rosetta_g_miss_num_map(p1_a15);
    ddp_filter_rec.last_update_login := rosetta_g_miss_num_map(p1_a16);





    -- here's the delegated call to the old PL/SQL routine
    iex_filter_pub.validate_filter(p_init_msg_list,
      ddp_filter_rec,
      x_dup_status,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure create_object_filter(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , x_dup_status out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_filter_id out nocopy  NUMBER
    , p3_a0  NUMBER := 0-1962.0724
    , p3_a1  VARCHAR2 := fnd_api.g_miss_char
    , p3_a2  VARCHAR2 := fnd_api.g_miss_char
    , p3_a3  NUMBER := 0-1962.0724
    , p3_a4  VARCHAR2 := fnd_api.g_miss_char
    , p3_a5  VARCHAR2 := fnd_api.g_miss_char
    , p3_a6  VARCHAR2 := fnd_api.g_miss_char
    , p3_a7  NUMBER := 0-1962.0724
    , p3_a8  NUMBER := 0-1962.0724
    , p3_a9  NUMBER := 0-1962.0724
    , p3_a10  NUMBER := 0-1962.0724
    , p3_a11  DATE := fnd_api.g_miss_date
    , p3_a12  DATE := fnd_api.g_miss_date
    , p3_a13  NUMBER := 0-1962.0724
    , p3_a14  DATE := fnd_api.g_miss_date
    , p3_a15  NUMBER := 0-1962.0724
    , p3_a16  NUMBER := 0-1962.0724
  )

  as
    ddp_filter_rec iex_filter_pub.filter_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    ddp_filter_rec.object_filter_id := rosetta_g_miss_num_map(p3_a0);
    ddp_filter_rec.object_filter_type := p3_a1;
    ddp_filter_rec.object_filter_name := p3_a2;
    ddp_filter_rec.object_id := rosetta_g_miss_num_map(p3_a3);
    ddp_filter_rec.select_column := p3_a4;
    ddp_filter_rec.entity_name := p3_a5;
    ddp_filter_rec.active_flag := p3_a6;
    ddp_filter_rec.object_version_number := rosetta_g_miss_num_map(p3_a7);
    ddp_filter_rec.program_id := rosetta_g_miss_num_map(p3_a8);
    ddp_filter_rec.request_id := rosetta_g_miss_num_map(p3_a9);
    ddp_filter_rec.program_application_id := rosetta_g_miss_num_map(p3_a10);
    ddp_filter_rec.program_update_date := rosetta_g_miss_date_in_map(p3_a11);
    ddp_filter_rec.creation_date := rosetta_g_miss_date_in_map(p3_a12);
    ddp_filter_rec.created_by := rosetta_g_miss_num_map(p3_a13);
    ddp_filter_rec.last_update_date := rosetta_g_miss_date_in_map(p3_a14);
    ddp_filter_rec.last_updated_by := rosetta_g_miss_num_map(p3_a15);
    ddp_filter_rec.last_update_login := rosetta_g_miss_num_map(p3_a16);






    -- here's the delegated call to the old PL/SQL routine
    iex_filter_pub.create_object_filter(p_api_version,
      p_init_msg_list,
      p_commit,
      ddp_filter_rec,
      x_dup_status,
      x_return_status,
      x_msg_count,
      x_msg_data,
      x_filter_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

  procedure update_object_filter(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , x_dup_status out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p3_a0  NUMBER := 0-1962.0724
    , p3_a1  VARCHAR2 := fnd_api.g_miss_char
    , p3_a2  VARCHAR2 := fnd_api.g_miss_char
    , p3_a3  NUMBER := 0-1962.0724
    , p3_a4  VARCHAR2 := fnd_api.g_miss_char
    , p3_a5  VARCHAR2 := fnd_api.g_miss_char
    , p3_a6  VARCHAR2 := fnd_api.g_miss_char
    , p3_a7  NUMBER := 0-1962.0724
    , p3_a8  NUMBER := 0-1962.0724
    , p3_a9  NUMBER := 0-1962.0724
    , p3_a10  NUMBER := 0-1962.0724
    , p3_a11  DATE := fnd_api.g_miss_date
    , p3_a12  DATE := fnd_api.g_miss_date
    , p3_a13  NUMBER := 0-1962.0724
    , p3_a14  DATE := fnd_api.g_miss_date
    , p3_a15  NUMBER := 0-1962.0724
    , p3_a16  NUMBER := 0-1962.0724
  )

  as
    ddp_filter_rec iex_filter_pub.filter_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    ddp_filter_rec.object_filter_id := rosetta_g_miss_num_map(p3_a0);
    ddp_filter_rec.object_filter_type := p3_a1;
    ddp_filter_rec.object_filter_name := p3_a2;
    ddp_filter_rec.object_id := rosetta_g_miss_num_map(p3_a3);
    ddp_filter_rec.select_column := p3_a4;
    ddp_filter_rec.entity_name := p3_a5;
    ddp_filter_rec.active_flag := p3_a6;
    ddp_filter_rec.object_version_number := rosetta_g_miss_num_map(p3_a7);
    ddp_filter_rec.program_id := rosetta_g_miss_num_map(p3_a8);
    ddp_filter_rec.request_id := rosetta_g_miss_num_map(p3_a9);
    ddp_filter_rec.program_application_id := rosetta_g_miss_num_map(p3_a10);
    ddp_filter_rec.program_update_date := rosetta_g_miss_date_in_map(p3_a11);
    ddp_filter_rec.creation_date := rosetta_g_miss_date_in_map(p3_a12);
    ddp_filter_rec.created_by := rosetta_g_miss_num_map(p3_a13);
    ddp_filter_rec.last_update_date := rosetta_g_miss_date_in_map(p3_a14);
    ddp_filter_rec.last_updated_by := rosetta_g_miss_num_map(p3_a15);
    ddp_filter_rec.last_update_login := rosetta_g_miss_num_map(p3_a16);





    -- here's the delegated call to the old PL/SQL routine
    iex_filter_pub.update_object_filter(p_api_version,
      p_init_msg_list,
      p_commit,
      ddp_filter_rec,
      x_dup_status,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

end iex_filter_pub_w;

/
