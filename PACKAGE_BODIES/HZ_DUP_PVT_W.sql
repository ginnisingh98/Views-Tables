--------------------------------------------------------
--  DDL for Package Body HZ_DUP_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_DUP_PVT_W" as
  /* $Header: ARHWDUPB.pls 120.3 2005/06/18 04:28:09 jhuang ship $ */
  rosetta_g_mistake_date date := to_date('01/01/+4713', 'MM/DD/SYYYY');
  rosetta_g_miss_date date := to_date('01/01/-4712', 'MM/DD/SYYYY');

  -- this is to workaround the JDBC bug regarding IN DATE of value GMiss
  function rosetta_g_miss_date_in_map(d date) return date as
  begin
    if d = rosetta_g_mistake_date then return fnd_api.g_miss_date; end if;
    return d;
  end;

  procedure rosetta_table_copy_in_p1(t out nocopy hz_dup_pvt.dup_party_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).party_id := a0(indx);
          t(ddindx).score := a1(indx);
          t(ddindx).merge_flag := a2(indx);
          t(ddindx).not_dup := a3(indx);
          t(ddindx).merge_seq_id := a4(indx);
          t(ddindx).merge_batch_id := a5(indx);
          t(ddindx).merge_batch_name := a6(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p1;
  procedure rosetta_table_copy_out_p1(t hz_dup_pvt.dup_party_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_VARCHAR2_TABLE_100();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_VARCHAR2_TABLE_100();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        a3.extend(t.count);
        a4.extend(t.count);
        a5.extend(t.count);
        a6.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).party_id;
          a1(indx) := t(ddindx).score;
          a2(indx) := t(ddindx).merge_flag;
          a3(indx) := t(ddindx).not_dup;
          a4(indx) := t(ddindx).merge_seq_id;
          a5(indx) := t(ddindx).merge_batch_id;
          a6(indx) := t(ddindx).merge_batch_name;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p1;

  procedure create_dup_set_1(p0_a0  NUMBER
    , p0_a1  NUMBER
    , p0_a2  VARCHAR2
    , p0_a3  NUMBER
    , p0_a4  VARCHAR2
    , p1_a0 JTF_NUMBER_TABLE
    , p1_a1 JTF_NUMBER_TABLE
    , p1_a2 JTF_VARCHAR2_TABLE_100
    , p1_a3 JTF_VARCHAR2_TABLE_100
    , p1_a4 JTF_NUMBER_TABLE
    , p1_a5 JTF_NUMBER_TABLE
    , p1_a6 JTF_VARCHAR2_TABLE_100
    , x_dup_set_id out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_dup_set_rec hz_dup_pvt.dup_set_rec_type;
    ddp_dup_party_tbl hz_dup_pvt.dup_party_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_dup_set_rec.dup_batch_id := p0_a0;
    ddp_dup_set_rec.winner_party_id := p0_a1;
    ddp_dup_set_rec.status := p0_a2;
    ddp_dup_set_rec.assigned_to_user_id := p0_a3;
    ddp_dup_set_rec.merge_type := p0_a4;

    hz_dup_pvt_w.rosetta_table_copy_in_p1(ddp_dup_party_tbl, p1_a0
      , p1_a1
      , p1_a2
      , p1_a3
      , p1_a4
      , p1_a5
      , p1_a6
      );





    -- here's the delegated call to the old PL/SQL routine
    hz_dup_pvt.create_dup_set(ddp_dup_set_rec,
      ddp_dup_party_tbl,
      x_dup_set_id,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure create_dup_batch_2(p0_a0  VARCHAR2
    , p0_a1  NUMBER
    , p0_a2  NUMBER
    , p0_a3  VARCHAR2
    , p1_a0  NUMBER
    , p1_a1  NUMBER
    , p1_a2  VARCHAR2
    , p1_a3  NUMBER
    , p1_a4  VARCHAR2
    , p2_a0 JTF_NUMBER_TABLE
    , p2_a1 JTF_NUMBER_TABLE
    , p2_a2 JTF_VARCHAR2_TABLE_100
    , p2_a3 JTF_VARCHAR2_TABLE_100
    , p2_a4 JTF_NUMBER_TABLE
    , p2_a5 JTF_NUMBER_TABLE
    , p2_a6 JTF_VARCHAR2_TABLE_100
    , x_dup_batch_id out nocopy  NUMBER
    , x_dup_set_id out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_dup_batch_rec hz_dup_pvt.dup_batch_rec_type;
    ddp_dup_set_rec hz_dup_pvt.dup_set_rec_type;
    ddp_dup_party_tbl hz_dup_pvt.dup_party_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_dup_batch_rec.dup_batch_name := p0_a0;
    ddp_dup_batch_rec.match_rule_id := p0_a1;
    ddp_dup_batch_rec.application_id := p0_a2;
    ddp_dup_batch_rec.request_type := p0_a3;

    ddp_dup_set_rec.dup_batch_id := p1_a0;
    ddp_dup_set_rec.winner_party_id := p1_a1;
    ddp_dup_set_rec.status := p1_a2;
    ddp_dup_set_rec.assigned_to_user_id := p1_a3;
    ddp_dup_set_rec.merge_type := p1_a4;

    hz_dup_pvt_w.rosetta_table_copy_in_p1(ddp_dup_party_tbl, p2_a0
      , p2_a1
      , p2_a2
      , p2_a3
      , p2_a4
      , p2_a5
      , p2_a6
      );






    -- here's the delegated call to the old PL/SQL routine
    hz_dup_pvt.create_dup_batch(ddp_dup_batch_rec,
      ddp_dup_set_rec,
      ddp_dup_party_tbl,
      x_dup_batch_id,
      x_dup_set_id,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

end hz_dup_pvt_w;

/
