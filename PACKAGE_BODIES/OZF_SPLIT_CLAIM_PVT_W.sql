--------------------------------------------------------
--  DDL for Package Body OZF_SPLIT_CLAIM_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_SPLIT_CLAIM_PVT_W" as
  /* $Header: ozfwspcb.pls 120.1.12010000.2 2009/01/13 08:24:19 ateotia ship $ */
  rosetta_g_mistake_date date := to_date('01/01/+4713', 'MM/DD/SYYYY');
  rosetta_g_miss_date date := to_date('01/01/-4712', 'MM/DD/SYYYY');
  rosetta_g_mistake_date_high date := to_date('01/01/+4710', 'MM/DD/SYYYY');
  rosetta_g_mistake_date_low date := to_date('01/01/-4710', 'MM/DD/SYYYY');

  -- this is to workaround the JDBC bug regarding IN DATE of value GMiss
  function rosetta_g_miss_date_in_map(d date) return date as
  begin
    if d > rosetta_g_mistake_date_high then return fnd_api.g_miss_date; end if;
    if d < rosetta_g_mistake_date_low then return fnd_api.g_miss_date; end if;
    return d;
  end;

  procedure rosetta_table_copy_in_p1(t out nocopy ozf_split_claim_pvt.child_claim_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_VARCHAR2_TABLE_32767
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).claim_id := a0(indx);
          t(ddindx).object_version_number := a1(indx);
          t(ddindx).claim_type_id := a2(indx);
          t(ddindx).amount := a3(indx);
          t(ddindx).line_amount_sum := a4(indx);
          t(ddindx).reason_code_id := a5(indx);
          t(ddindx).parent_claim_id := a6(indx);
          t(ddindx).parent_object_ver_num := a7(indx);
          t(ddindx).line_table := a8(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p1;
  procedure rosetta_table_copy_out_p1(t ozf_split_claim_pvt.child_claim_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_VARCHAR2_TABLE_32767
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_VARCHAR2_TABLE_32767();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_VARCHAR2_TABLE_32767();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).claim_id;
          a1(indx) := t(ddindx).object_version_number;
          a2(indx) := t(ddindx).claim_type_id;
          a3(indx) := t(ddindx).amount;
          a4(indx) := t(ddindx).line_amount_sum;
          a5(indx) := t(ddindx).reason_code_id;
          a6(indx) := t(ddindx).parent_claim_id;
          a7(indx) := t(ddindx).parent_object_ver_num;
          a8(indx) := t(ddindx).line_table;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p1;

  procedure create_child_claim_tbl(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_data out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , p7_a0 JTF_NUMBER_TABLE
    , p7_a1 JTF_NUMBER_TABLE
    , p7_a2 JTF_NUMBER_TABLE
    , p7_a3 JTF_NUMBER_TABLE
    , p7_a4 JTF_NUMBER_TABLE
    , p7_a5 JTF_NUMBER_TABLE
    , p7_a6 JTF_NUMBER_TABLE
    , p7_a7 JTF_NUMBER_TABLE
    , p7_a8 JTF_VARCHAR2_TABLE_32767
    , p_mode  VARCHAR2
  )

  as
    ddp_child_claim_tbl ozf_split_claim_pvt.child_claim_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ozf_split_claim_pvt_w.rosetta_table_copy_in_p1(ddp_child_claim_tbl, p7_a0
      , p7_a1
      , p7_a2
      , p7_a3
      , p7_a4
      , p7_a5
      , p7_a6
      , p7_a7
      , p7_a8
      );


    -- here's the delegated call to the old PL/SQL routine
    ozf_split_claim_pvt.create_child_claim_tbl(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_data,
      x_msg_count,
      ddp_child_claim_tbl,
      p_mode);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

  procedure update_child_claim_tbl(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_data out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , p7_a0 JTF_NUMBER_TABLE
    , p7_a1 JTF_NUMBER_TABLE
    , p7_a2 JTF_NUMBER_TABLE
    , p7_a3 JTF_NUMBER_TABLE
    , p7_a4 JTF_NUMBER_TABLE
    , p7_a5 JTF_NUMBER_TABLE
    , p7_a6 JTF_NUMBER_TABLE
    , p7_a7 JTF_NUMBER_TABLE
    , p7_a8 JTF_VARCHAR2_TABLE_32767
    , p_mode  VARCHAR2
  )

  as
    ddp_child_claim_tbl ozf_split_claim_pvt.child_claim_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ozf_split_claim_pvt_w.rosetta_table_copy_in_p1(ddp_child_claim_tbl, p7_a0
      , p7_a1
      , p7_a2
      , p7_a3
      , p7_a4
      , p7_a5
      , p7_a6
      , p7_a7
      , p7_a8
      );


    -- here's the delegated call to the old PL/SQL routine
    ozf_split_claim_pvt.update_child_claim_tbl(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_data,
      x_msg_count,
      ddp_child_claim_tbl,
      p_mode);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

end ozf_split_claim_pvt_w;

/
