--------------------------------------------------------
--  DDL for Package Body AST_CAMP_OUTCOME_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AST_CAMP_OUTCOME_PVT_W" as
  /* $Header: astwcopb.pls 115.2 2002/02/05 18:04:47 pkm ship      $ */
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

  procedure rosetta_table_copy_in_p3(t out ast_camp_outcome_pvt.camp_outcome_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_DATE_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_DATE_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).outcome_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).object_id := rosetta_g_miss_num_map(a1(indx));
          t(ddindx).object_version_number := rosetta_g_miss_num_map(a2(indx));
          t(ddindx).created_by := rosetta_g_miss_num_map(a3(indx));
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a4(indx));
          t(ddindx).last_updated_by := rosetta_g_miss_num_map(a5(indx));
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a6(indx));
          t(ddindx).last_update_login := rosetta_g_miss_num_map(a7(indx));
          t(ddindx).object_type := a8(indx);
          t(ddindx).source_code_id := rosetta_g_miss_num_map(a9(indx));
          t(ddindx).source_code := a10(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p3;
  procedure rosetta_table_copy_out_p3(t ast_camp_outcome_pvt.camp_outcome_tbl_type, a0 out JTF_NUMBER_TABLE
    , a1 out JTF_NUMBER_TABLE
    , a2 out JTF_NUMBER_TABLE
    , a3 out JTF_NUMBER_TABLE
    , a4 out JTF_DATE_TABLE
    , a5 out JTF_NUMBER_TABLE
    , a6 out JTF_DATE_TABLE
    , a7 out JTF_NUMBER_TABLE
    , a8 out JTF_VARCHAR2_TABLE_100
    , a9 out JTF_NUMBER_TABLE
    , a10 out JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_DATE_TABLE();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_DATE_TABLE();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_VARCHAR2_TABLE_100();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_DATE_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_DATE_TABLE();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_VARCHAR2_TABLE_100();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_VARCHAR2_TABLE_100();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).outcome_id);
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).object_id);
          a2(indx) := rosetta_g_miss_num_map(t(ddindx).object_version_number);
          a3(indx) := rosetta_g_miss_num_map(t(ddindx).created_by);
          a4(indx) := t(ddindx).creation_date;
          a5(indx) := rosetta_g_miss_num_map(t(ddindx).last_updated_by);
          a6(indx) := t(ddindx).last_update_date;
          a7(indx) := rosetta_g_miss_num_map(t(ddindx).last_update_login);
          a8(indx) := t(ddindx).object_type;
          a9(indx) := rosetta_g_miss_num_map(t(ddindx).source_code_id);
          a10(indx) := t(ddindx).source_code;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p3;

  procedure create_camp_outcome(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out  VARCHAR2
    , x_msg_count out  NUMBER
    , x_msg_data out  VARCHAR2
    , p4_a0  NUMBER := 0-1962.0724
    , p4_a1  NUMBER := 0-1962.0724
    , p4_a2  NUMBER := 0-1962.0724
    , p4_a3  NUMBER := 0-1962.0724
    , p4_a4  DATE := fnd_api.g_miss_date
    , p4_a5  NUMBER := 0-1962.0724
    , p4_a6  DATE := fnd_api.g_miss_date
    , p4_a7  NUMBER := 0-1962.0724
    , p4_a8  VARCHAR2 := fnd_api.g_miss_char
    , p4_a9  NUMBER := 0-1962.0724
    , p4_a10  VARCHAR2 := fnd_api.g_miss_char
  )
  as
    ddp_camp_outcome_rec ast_camp_outcome_pvt.camp_outcome_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    ddp_camp_outcome_rec.outcome_id := rosetta_g_miss_num_map(p4_a0);
    ddp_camp_outcome_rec.object_id := rosetta_g_miss_num_map(p4_a1);
    ddp_camp_outcome_rec.object_version_number := rosetta_g_miss_num_map(p4_a2);
    ddp_camp_outcome_rec.created_by := rosetta_g_miss_num_map(p4_a3);
    ddp_camp_outcome_rec.creation_date := rosetta_g_miss_date_in_map(p4_a4);
    ddp_camp_outcome_rec.last_updated_by := rosetta_g_miss_num_map(p4_a5);
    ddp_camp_outcome_rec.last_update_date := rosetta_g_miss_date_in_map(p4_a6);
    ddp_camp_outcome_rec.last_update_login := rosetta_g_miss_num_map(p4_a7);
    ddp_camp_outcome_rec.object_type := p4_a8;
    ddp_camp_outcome_rec.source_code_id := rosetta_g_miss_num_map(p4_a9);
    ddp_camp_outcome_rec.source_code := p4_a10;




    -- here's the delegated call to the old PL/SQL routine
    ast_camp_outcome_pvt.create_camp_outcome(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      ddp_camp_outcome_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any







  end;

  procedure delete_camp_outcome(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out  VARCHAR2
    , x_msg_count out  NUMBER
    , x_msg_data out  VARCHAR2
    , p4_a0  NUMBER := 0-1962.0724
    , p4_a1  NUMBER := 0-1962.0724
    , p4_a2  NUMBER := 0-1962.0724
    , p4_a3  NUMBER := 0-1962.0724
    , p4_a4  DATE := fnd_api.g_miss_date
    , p4_a5  NUMBER := 0-1962.0724
    , p4_a6  DATE := fnd_api.g_miss_date
    , p4_a7  NUMBER := 0-1962.0724
    , p4_a8  VARCHAR2 := fnd_api.g_miss_char
    , p4_a9  NUMBER := 0-1962.0724
    , p4_a10  VARCHAR2 := fnd_api.g_miss_char
  )
  as
    ddp_camp_outcome_rec ast_camp_outcome_pvt.camp_outcome_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    ddp_camp_outcome_rec.outcome_id := rosetta_g_miss_num_map(p4_a0);
    ddp_camp_outcome_rec.object_id := rosetta_g_miss_num_map(p4_a1);
    ddp_camp_outcome_rec.object_version_number := rosetta_g_miss_num_map(p4_a2);
    ddp_camp_outcome_rec.created_by := rosetta_g_miss_num_map(p4_a3);
    ddp_camp_outcome_rec.creation_date := rosetta_g_miss_date_in_map(p4_a4);
    ddp_camp_outcome_rec.last_updated_by := rosetta_g_miss_num_map(p4_a5);
    ddp_camp_outcome_rec.last_update_date := rosetta_g_miss_date_in_map(p4_a6);
    ddp_camp_outcome_rec.last_update_login := rosetta_g_miss_num_map(p4_a7);
    ddp_camp_outcome_rec.object_type := p4_a8;
    ddp_camp_outcome_rec.source_code_id := rosetta_g_miss_num_map(p4_a9);
    ddp_camp_outcome_rec.source_code := p4_a10;




    -- here's the delegated call to the old PL/SQL routine
    ast_camp_outcome_pvt.delete_camp_outcome(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      ddp_camp_outcome_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any







  end;

end ast_camp_outcome_pvt_w;

/
