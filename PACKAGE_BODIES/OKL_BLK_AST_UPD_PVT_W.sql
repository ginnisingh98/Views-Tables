--------------------------------------------------------
--  DDL for Package Body OKL_BLK_AST_UPD_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_BLK_AST_UPD_PVT_W" as
  /* $Header: OKLEBAUB.pls 120.0 2007/05/25 13:18:32 asawanka noship $ */
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

  function rosetta_g_miss_num_map(n number) return number as
    a number := fnd_api.g_miss_num;
    b number := 0-1962.0724;
  begin
    if n=a then return b; end if;
    if n=b then return a; end if;
    return n;
  end;

  procedure rosetta_table_copy_in_p23(t out nocopy okl_blk_ast_upd_pvt.okl_loc_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_DATE_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).parent_line_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).loc_id := rosetta_g_miss_num_map(a1(indx));
          t(ddindx).party_site_id := rosetta_g_miss_num_map(a2(indx));
          t(ddindx).newsite_id1 := rosetta_g_miss_num_map(a3(indx));
          t(ddindx).newsite_id2 := a4(indx);
          t(ddindx).oldsite_id1 := rosetta_g_miss_num_map(a5(indx));
          t(ddindx).oldsite_id2 := a6(indx);
          t(ddindx).date_from := rosetta_g_miss_date_in_map(a7(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p23;
  procedure rosetta_table_copy_out_p23(t okl_blk_ast_upd_pvt.okl_loc_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    , a7 out nocopy JTF_DATE_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_VARCHAR2_TABLE_100();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_VARCHAR2_TABLE_100();
    a7 := JTF_DATE_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_VARCHAR2_TABLE_100();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_VARCHAR2_TABLE_100();
      a7 := JTF_DATE_TABLE();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        a3.extend(t.count);
        a4.extend(t.count);
        a5.extend(t.count);
        a6.extend(t.count);
        a7.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).parent_line_id);
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).loc_id);
          a2(indx) := rosetta_g_miss_num_map(t(ddindx).party_site_id);
          a3(indx) := rosetta_g_miss_num_map(t(ddindx).newsite_id1);
          a4(indx) := t(ddindx).newsite_id2;
          a5(indx) := rosetta_g_miss_num_map(t(ddindx).oldsite_id1);
          a6(indx) := t(ddindx).oldsite_id2;
          a7(indx) := t(ddindx).date_from;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p23;

  procedure update_location(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p2_a0  NUMBER := 0-1962.0724
    , p2_a1  NUMBER := 0-1962.0724
    , p2_a2  NUMBER := 0-1962.0724
    , p2_a3  NUMBER := 0-1962.0724
    , p2_a4  VARCHAR2 := fnd_api.g_miss_char
    , p2_a5  NUMBER := 0-1962.0724
    , p2_a6  VARCHAR2 := fnd_api.g_miss_char
    , p2_a7  DATE := fnd_api.g_miss_date
  )

  as
    ddp_loc_rec okl_blk_ast_upd_pvt.okl_loc_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any


    ddp_loc_rec.parent_line_id := rosetta_g_miss_num_map(p2_a0);
    ddp_loc_rec.loc_id := rosetta_g_miss_num_map(p2_a1);
    ddp_loc_rec.party_site_id := rosetta_g_miss_num_map(p2_a2);
    ddp_loc_rec.newsite_id1 := rosetta_g_miss_num_map(p2_a3);
    ddp_loc_rec.newsite_id2 := p2_a4;
    ddp_loc_rec.oldsite_id1 := rosetta_g_miss_num_map(p2_a5);
    ddp_loc_rec.oldsite_id2 := p2_a6;
    ddp_loc_rec.date_from := rosetta_g_miss_date_in_map(p2_a7);




    -- here's the delegated call to the old PL/SQL routine
    okl_blk_ast_upd_pvt.update_location(p_api_version,
      p_init_msg_list,
      ddp_loc_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure update_location(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p2_a0 JTF_NUMBER_TABLE
    , p2_a1 JTF_NUMBER_TABLE
    , p2_a2 JTF_NUMBER_TABLE
    , p2_a3 JTF_NUMBER_TABLE
    , p2_a4 JTF_VARCHAR2_TABLE_100
    , p2_a5 JTF_NUMBER_TABLE
    , p2_a6 JTF_VARCHAR2_TABLE_100
    , p2_a7 JTF_DATE_TABLE
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_loc_tbl okl_blk_ast_upd_pvt.okl_loc_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any


    okl_blk_ast_upd_pvt_w.rosetta_table_copy_in_p23(ddp_loc_tbl, p2_a0
      , p2_a1
      , p2_a2
      , p2_a3
      , p2_a4
      , p2_a5
      , p2_a6
      , p2_a7
      );




    -- here's the delegated call to the old PL/SQL routine
    okl_blk_ast_upd_pvt.update_location(p_api_version,
      p_init_msg_list,
      ddp_loc_tbl,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

end okl_blk_ast_upd_pvt_w;

/
