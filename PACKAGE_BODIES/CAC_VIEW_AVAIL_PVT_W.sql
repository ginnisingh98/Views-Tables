--------------------------------------------------------
--  DDL for Package Body CAC_VIEW_AVAIL_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CAC_VIEW_AVAIL_PVT_W" as
  /* $Header: cacwavb.pls 115.0 2003/10/28 00:59:35 cjang noship $ */
  procedure rosetta_table_copy_in_p1(t out nocopy cac_view_avail_pvt.rstab, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_400
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).resourceid := a0(indx);
          t(ddindx).resourcetype := a1(indx);
          t(ddindx).resourcename := a2(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p1;
  procedure rosetta_table_copy_out_p1(t cac_view_avail_pvt.rstab, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_400
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_VARCHAR2_TABLE_400();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_VARCHAR2_TABLE_400();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).resourceid;
          a1(indx) := t(ddindx).resourcetype;
          a2(indx) := t(ddindx).resourcename;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p1;

  procedure rosetta_table_copy_in_p3(t out nocopy cac_view_avail_pvt.avlbltb, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_400
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).resourceid := a0(indx);
          t(ddindx).resourcetype := a1(indx);
          t(ddindx).resourcename := a2(indx);
          t(ddindx).slotsequence := a3(indx);
          t(ddindx).slotavailable := a4(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p3;
  procedure rosetta_table_copy_out_p3(t cac_view_avail_pvt.avlbltb, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_400
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_VARCHAR2_TABLE_400();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_VARCHAR2_TABLE_400();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_NUMBER_TABLE();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        a3.extend(t.count);
        a4.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).resourceid;
          a1(indx) := t(ddindx).resourcetype;
          a2(indx) := t(ddindx).resourcename;
          a3(indx) := t(ddindx).slotsequence;
          a4(indx) := t(ddindx).slotavailable;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p3;

  procedure availability(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_VARCHAR2_TABLE_100
    , p5_a2 JTF_VARCHAR2_TABLE_400
    , p_startdatetime  DATE
    , p_enddatetime  DATE
    , p_slotsize  NUMBER
    , x_numberofslots out nocopy  NUMBER
    , p10_a0 out nocopy JTF_NUMBER_TABLE
    , p10_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a2 out nocopy JTF_VARCHAR2_TABLE_400
    , p10_a3 out nocopy JTF_NUMBER_TABLE
    , p10_a4 out nocopy JTF_NUMBER_TABLE
    , p11_a0 out nocopy JTF_NUMBER_TABLE
    , p11_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p11_a2 out nocopy JTF_VARCHAR2_TABLE_400
    , p11_a3 out nocopy JTF_NUMBER_TABLE
    , p11_a4 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_rslist cac_view_avail_pvt.rstab;
    ddx_availbltylist cac_view_avail_pvt.avlbltb;
    ddx_totalavailbltylist cac_view_avail_pvt.avlbltb;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    cac_view_avail_pvt_w.rosetta_table_copy_in_p1(ddp_rslist, p5_a0
      , p5_a1
      , p5_a2
      );







    -- here's the delegated call to the old PL/SQL routine
    cac_view_avail_pvt.availability(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_rslist,
      p_startdatetime,
      p_enddatetime,
      p_slotsize,
      x_numberofslots,
      ddx_availbltylist,
      ddx_totalavailbltylist);

    -- copy data back from the local variables to OUT or IN-OUT args, if any










    cac_view_avail_pvt_w.rosetta_table_copy_out_p3(ddx_availbltylist, p10_a0
      , p10_a1
      , p10_a2
      , p10_a3
      , p10_a4
      );

    cac_view_avail_pvt_w.rosetta_table_copy_out_p3(ddx_totalavailbltylist, p11_a0
      , p11_a1
      , p11_a2
      , p11_a3
      , p11_a4
      );
  end;

  procedure check_availability(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p2_a0 JTF_NUMBER_TABLE
    , p2_a1 JTF_VARCHAR2_TABLE_100
    , p2_a2 JTF_VARCHAR2_TABLE_400
    , p_startdatetime  DATE
    , p_enddatetime  DATE
    , p_slotsize  NUMBER
    , x_numberofslots out nocopy  NUMBER
    , p7_a0 out nocopy JTF_NUMBER_TABLE
    , p7_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a2 out nocopy JTF_VARCHAR2_TABLE_400
    , p7_a3 out nocopy JTF_NUMBER_TABLE
    , p7_a4 out nocopy JTF_NUMBER_TABLE
    , p8_a0 out nocopy JTF_NUMBER_TABLE
    , p8_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a2 out nocopy JTF_VARCHAR2_TABLE_400
    , p8_a3 out nocopy JTF_NUMBER_TABLE
    , p8_a4 out nocopy JTF_NUMBER_TABLE
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_rslist cac_view_avail_pvt.rstab;
    ddx_availbltylist cac_view_avail_pvt.avlbltb;
    ddx_totalavailbltylist cac_view_avail_pvt.avlbltb;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any


    cac_view_avail_pvt_w.rosetta_table_copy_in_p1(ddp_rslist, p2_a0
      , p2_a1
      , p2_a2
      );










    -- here's the delegated call to the old PL/SQL routine
    cac_view_avail_pvt.check_availability(p_api_version,
      p_init_msg_list,
      ddp_rslist,
      p_startdatetime,
      p_enddatetime,
      p_slotsize,
      x_numberofslots,
      ddx_availbltylist,
      ddx_totalavailbltylist,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







    cac_view_avail_pvt_w.rosetta_table_copy_out_p3(ddx_availbltylist, p7_a0
      , p7_a1
      , p7_a2
      , p7_a3
      , p7_a4
      );

    cac_view_avail_pvt_w.rosetta_table_copy_out_p3(ddx_totalavailbltylist, p8_a0
      , p8_a1
      , p8_a2
      , p8_a3
      , p8_a4
      );



  end;

  procedure check_availability(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_task_id  NUMBER
    , p_startdatetime  DATE
    , p_enddatetime  DATE
    , p_slotsize  NUMBER
    , x_numberofslots out nocopy  NUMBER
    , p7_a0 out nocopy JTF_NUMBER_TABLE
    , p7_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a2 out nocopy JTF_VARCHAR2_TABLE_400
    , p7_a3 out nocopy JTF_NUMBER_TABLE
    , p7_a4 out nocopy JTF_NUMBER_TABLE
    , p8_a0 out nocopy JTF_NUMBER_TABLE
    , p8_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a2 out nocopy JTF_VARCHAR2_TABLE_400
    , p8_a3 out nocopy JTF_NUMBER_TABLE
    , p8_a4 out nocopy JTF_NUMBER_TABLE
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddx_availbltylist cac_view_avail_pvt.avlbltb;
    ddx_totalavailbltylist cac_view_avail_pvt.avlbltb;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any












    -- here's the delegated call to the old PL/SQL routine
    cac_view_avail_pvt.check_availability(p_api_version,
      p_init_msg_list,
      p_task_id,
      p_startdatetime,
      p_enddatetime,
      p_slotsize,
      x_numberofslots,
      ddx_availbltylist,
      ddx_totalavailbltylist,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







    cac_view_avail_pvt_w.rosetta_table_copy_out_p3(ddx_availbltylist, p7_a0
      , p7_a1
      , p7_a2
      , p7_a3
      , p7_a4
      );

    cac_view_avail_pvt_w.rosetta_table_copy_out_p3(ddx_totalavailbltylist, p8_a0
      , p8_a1
      , p8_a2
      , p8_a3
      , p8_a4
      );



  end;

end cac_view_avail_pvt_w;

/
