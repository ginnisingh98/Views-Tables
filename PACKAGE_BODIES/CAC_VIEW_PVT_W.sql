--------------------------------------------------------
--  DDL for Package Body CAC_VIEW_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CAC_VIEW_PVT_W" as
  /* $Header: cacvpwb.pls 120.3 2006/02/22 07:23:26 sankgupt noship $ */
  procedure rosetta_table_copy_in_p1(t out nocopy cac_view_pvt.callsttbltype, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_400
    , a3 JTF_VARCHAR2_TABLE_100
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
          t(ddindx).calendarname := a2(indx);
          t(ddindx).accesslevel := a3(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p1;
  procedure rosetta_table_copy_out_p1(t cac_view_pvt.callsttbltype, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_400
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_VARCHAR2_TABLE_400();
    a3 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_VARCHAR2_TABLE_400();
      a3 := JTF_VARCHAR2_TABLE_100();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        a3.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).resourceid;
          a1(indx) := t(ddindx).resourcetype;
          a2(indx) := t(ddindx).calendarname;
          a3(indx) := t(ddindx).accesslevel;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p1;

  procedure rosetta_table_copy_in_p4(t out nocopy cac_view_pvt.queryouttab, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_VARCHAR2_TABLE_2000
    , a4 JTF_VARCHAR2_TABLE_2000
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_DATE_TABLE
    , a12 JTF_VARCHAR2_TABLE_100
    , a13 JTF_DATE_TABLE
    , a14 JTF_VARCHAR2_TABLE_2000
    , a15 JTF_VARCHAR2_TABLE_2000
    , a16 JTF_VARCHAR2_TABLE_2000
    , a17 JTF_VARCHAR2_TABLE_4000
    , a18 JTF_VARCHAR2_TABLE_100
    , a19 JTF_VARCHAR2_TABLE_100
    , a20 JTF_VARCHAR2_TABLE_100
    , a21 JTF_VARCHAR2_TABLE_100
    , a22 JTF_VARCHAR2_TABLE_100
    , a23 JTF_VARCHAR2_TABLE_400
    , a24 JTF_VARCHAR2_TABLE_4000
    , a25 JTF_NUMBER_TABLE
    , a26 JTF_VARCHAR2_TABLE_100
    , a27 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).itemdisplaytype := a0(indx);
          t(ddindx).itemsourceid := a1(indx);
          t(ddindx).itemsourcecode := a2(indx);
          t(ddindx).source := a3(indx);
          t(ddindx).customer := a4(indx);
          t(ddindx).itemname := a5(indx);
          t(ddindx).accesslevel := a6(indx);
          t(ddindx).assignmentstatus := a7(indx);
          t(ddindx).inviteindicator := a8(indx);
          t(ddindx).repeatindicator := a9(indx);
          t(ddindx).remindindicator := a10(indx);
          t(ddindx).startdate := a11(indx);
          t(ddindx).sourceobjecttypecode := a12(indx);
          t(ddindx).enddate := a13(indx);
          t(ddindx).url := a14(indx);
          t(ddindx).urlparamlist := a15(indx);
          t(ddindx).attendees := a16(indx);
          t(ddindx).location := a17(indx);
          t(ddindx).customerconfirmation := a18(indx);
          t(ddindx).status := a19(indx);
          t(ddindx).assigneestatus := a20(indx);
          t(ddindx).priority := a21(indx);
          t(ddindx).tasktype := a22(indx);
          t(ddindx).owner := a23(indx);
          t(ddindx).description := a24(indx);
          t(ddindx).grouprsid := a25(indx);
          t(ddindx).freebusytype := a26(indx);
          t(ddindx).displaycolor := a27(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p4;
  procedure rosetta_table_copy_out_p4(t cac_view_pvt.queryouttab, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_VARCHAR2_TABLE_2000
    , a4 out nocopy JTF_VARCHAR2_TABLE_2000
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_DATE_TABLE
    , a12 out nocopy JTF_VARCHAR2_TABLE_100
    , a13 out nocopy JTF_DATE_TABLE
    , a14 out nocopy JTF_VARCHAR2_TABLE_2000
    , a15 out nocopy JTF_VARCHAR2_TABLE_2000
    , a16 out nocopy JTF_VARCHAR2_TABLE_2000
    , a17 out nocopy JTF_VARCHAR2_TABLE_4000
    , a18 out nocopy JTF_VARCHAR2_TABLE_100
    , a19 out nocopy JTF_VARCHAR2_TABLE_100
    , a20 out nocopy JTF_VARCHAR2_TABLE_100
    , a21 out nocopy JTF_VARCHAR2_TABLE_100
    , a22 out nocopy JTF_VARCHAR2_TABLE_100
    , a23 out nocopy JTF_VARCHAR2_TABLE_400
    , a24 out nocopy JTF_VARCHAR2_TABLE_4000
    , a25 out nocopy JTF_NUMBER_TABLE
    , a26 out nocopy JTF_VARCHAR2_TABLE_100
    , a27 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_VARCHAR2_TABLE_2000();
    a4 := JTF_VARCHAR2_TABLE_2000();
    a5 := JTF_VARCHAR2_TABLE_100();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_NUMBER_TABLE();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_NUMBER_TABLE();
    a11 := JTF_DATE_TABLE();
    a12 := JTF_VARCHAR2_TABLE_100();
    a13 := JTF_DATE_TABLE();
    a14 := JTF_VARCHAR2_TABLE_2000();
    a15 := JTF_VARCHAR2_TABLE_2000();
    a16 := JTF_VARCHAR2_TABLE_2000();
    a17 := JTF_VARCHAR2_TABLE_4000();
    a18 := JTF_VARCHAR2_TABLE_100();
    a19 := JTF_VARCHAR2_TABLE_100();
    a20 := JTF_VARCHAR2_TABLE_100();
    a21 := JTF_VARCHAR2_TABLE_100();
    a22 := JTF_VARCHAR2_TABLE_100();
    a23 := JTF_VARCHAR2_TABLE_400();
    a24 := JTF_VARCHAR2_TABLE_4000();
    a25 := JTF_NUMBER_TABLE();
    a26 := JTF_VARCHAR2_TABLE_100();
    a27 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_VARCHAR2_TABLE_2000();
      a4 := JTF_VARCHAR2_TABLE_2000();
      a5 := JTF_VARCHAR2_TABLE_100();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_NUMBER_TABLE();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_NUMBER_TABLE();
      a11 := JTF_DATE_TABLE();
      a12 := JTF_VARCHAR2_TABLE_100();
      a13 := JTF_DATE_TABLE();
      a14 := JTF_VARCHAR2_TABLE_2000();
      a15 := JTF_VARCHAR2_TABLE_2000();
      a16 := JTF_VARCHAR2_TABLE_2000();
      a17 := JTF_VARCHAR2_TABLE_4000();
      a18 := JTF_VARCHAR2_TABLE_100();
      a19 := JTF_VARCHAR2_TABLE_100();
      a20 := JTF_VARCHAR2_TABLE_100();
      a21 := JTF_VARCHAR2_TABLE_100();
      a22 := JTF_VARCHAR2_TABLE_100();
      a23 := JTF_VARCHAR2_TABLE_400();
      a24 := JTF_VARCHAR2_TABLE_4000();
      a25 := JTF_NUMBER_TABLE();
      a26 := JTF_VARCHAR2_TABLE_100();
      a27 := JTF_VARCHAR2_TABLE_100();
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
        a11.extend(t.count);
        a12.extend(t.count);
        a13.extend(t.count);
        a14.extend(t.count);
        a15.extend(t.count);
        a16.extend(t.count);
        a17.extend(t.count);
        a18.extend(t.count);
        a19.extend(t.count);
        a20.extend(t.count);
        a21.extend(t.count);
        a22.extend(t.count);
        a23.extend(t.count);
        a24.extend(t.count);
        a25.extend(t.count);
        a26.extend(t.count);
        a27.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).itemdisplaytype;
          a1(indx) := t(ddindx).itemsourceid;
          a2(indx) := t(ddindx).itemsourcecode;
          a3(indx) := t(ddindx).source;
          a4(indx) := t(ddindx).customer;
          a5(indx) := t(ddindx).itemname;
          a6(indx) := t(ddindx).accesslevel;
          a7(indx) := t(ddindx).assignmentstatus;
          a8(indx) := t(ddindx).inviteindicator;
          a9(indx) := t(ddindx).repeatindicator;
          a10(indx) := t(ddindx).remindindicator;
          a11(indx) := t(ddindx).startdate;
          a12(indx) := t(ddindx).sourceobjecttypecode;
          a13(indx) := t(ddindx).enddate;
          a14(indx) := t(ddindx).url;
          a15(indx) := t(ddindx).urlparamlist;
          a16(indx) := t(ddindx).attendees;
          a17(indx) := t(ddindx).location;
          a18(indx) := t(ddindx).customerconfirmation;
          a19(indx) := t(ddindx).status;
          a20(indx) := t(ddindx).assigneestatus;
          a21(indx) := t(ddindx).priority;
          a22(indx) := t(ddindx).tasktype;
          a23(indx) := t(ddindx).owner;
          a24(indx) := t(ddindx).description;
          a25(indx) := t(ddindx).grouprsid;
          a26(indx) := t(ddindx).freebusytype;
          a27(indx) := t(ddindx).displaycolor;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p4;

  procedure getcalendarlist(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_resourceid in out nocopy  NUMBER
    , p_resourcetype in out nocopy  VARCHAR2
    , p_userid  NUMBER
    , p9_a0 out nocopy JTF_NUMBER_TABLE
    , p9_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a2 out nocopy JTF_VARCHAR2_TABLE_400
    , p9_a3 out nocopy JTF_VARCHAR2_TABLE_100
  )

  as
    ddx_calendarlist cac_view_pvt.callsttbltype;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any










    -- here's the delegated call to the old PL/SQL routine
    cac_view_pvt.getcalendarlist(p_api_version,
      p_init_msg_list,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_resourceid,
      p_resourcetype,
      p_userid,
      ddx_calendarlist);

    -- copy data back from the local variables to OUT or IN-OUT args, if any









    cac_view_pvt_w.rosetta_table_copy_out_p1(ddx_calendarlist, p9_a0
      , p9_a1
      , p9_a2
      , p9_a3
      );
  end;

  procedure getview(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0  NUMBER
    , p6_a1  NUMBER
    , p6_a2  VARCHAR2
    , p6_a3  NUMBER
    , p6_a4  VARCHAR2
    , p6_a5  NUMBER
    , p6_a6  DATE
    , p6_a7  DATE
    , p6_a8  NUMBER
    , p6_a9  CHAR
    , p6_a10  CHAR
    , p6_a11  CHAR
    , p6_a12  CHAR
    , p6_a13  CHAR
    , p6_a14  CHAR
    , p6_a15  CHAR
    , p6_a16  CHAR
    , p6_a17  CHAR
    , p6_a18  CHAR
    , p6_a19  CHAR
    , p6_a20  CHAR
    , p6_a21  CHAR
    , p6_a22  CHAR
    , p6_a23  CHAR
    , p6_a24  CHAR
    , p6_a25  CHAR
    , p6_a26  CHAR
    , p6_a27  CHAR
    , p6_a28  CHAR
    , p6_a29  CHAR
    , p6_a30  CHAR
    , p6_a31  CHAR
    , p6_a32  CHAR
    , p6_a33  NUMBER
    , p7_a0 out nocopy JTF_NUMBER_TABLE
    , p7_a1 out nocopy JTF_NUMBER_TABLE
    , p7_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a3 out nocopy JTF_VARCHAR2_TABLE_2000
    , p7_a4 out nocopy JTF_VARCHAR2_TABLE_2000
    , p7_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a6 out nocopy JTF_NUMBER_TABLE
    , p7_a7 out nocopy JTF_NUMBER_TABLE
    , p7_a8 out nocopy JTF_NUMBER_TABLE
    , p7_a9 out nocopy JTF_NUMBER_TABLE
    , p7_a10 out nocopy JTF_NUMBER_TABLE
    , p7_a11 out nocopy JTF_DATE_TABLE
    , p7_a12 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a13 out nocopy JTF_DATE_TABLE
    , p7_a14 out nocopy JTF_VARCHAR2_TABLE_2000
    , p7_a15 out nocopy JTF_VARCHAR2_TABLE_2000
    , p7_a16 out nocopy JTF_VARCHAR2_TABLE_2000
    , p7_a17 out nocopy JTF_VARCHAR2_TABLE_4000
    , p7_a18 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a19 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a20 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a21 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a22 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a23 out nocopy JTF_VARCHAR2_TABLE_400
    , p7_a24 out nocopy JTF_VARCHAR2_TABLE_4000
    , p7_a25 out nocopy JTF_NUMBER_TABLE
    , p7_a26 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a27 out nocopy JTF_VARCHAR2_TABLE_100
  )

  as
    ddp_input cac_view_pvt.queryin;
    ddx_displayitems cac_view_pvt.queryouttab;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any






    ddp_input.userid := p6_a0;
    ddp_input.loggedonrsid := p6_a1;
    ddp_input.loggedonrstype := p6_a2;
    ddp_input.queryrsid := p6_a3;
    ddp_input.queryrstype := p6_a4;
    ddp_input.emploctimezoneid := p6_a5;
    ddp_input.startdate := p6_a6;
    ddp_input.enddate := p6_a7;
    ddp_input.querymode := p6_a8;
    ddp_input.showapts := p6_a9;
    ddp_input.showtasks := p6_a10;
    ddp_input.showevents := p6_a11;
    ddp_input.showopeninvite := p6_a12;
    ddp_input.showdeclined := p6_a13;
    ddp_input.showbookings := p6_a14;
    ddp_input.showhrcalendarevents := p6_a15;
    ddp_input.showschedules := p6_a16;
    ddp_input.aptfirstdetail := p6_a17;
    ddp_input.aptseconddetail := p6_a18;
    ddp_input.aptthirddetail := p6_a19;
    ddp_input.invfirstdetail := p6_a20;
    ddp_input.invseconddetail := p6_a21;
    ddp_input.invthirddetail := p6_a22;
    ddp_input.declfirstdetail := p6_a23;
    ddp_input.declseconddetail := p6_a24;
    ddp_input.declthirddetail := p6_a25;
    ddp_input.showbusytask := p6_a26;
    ddp_input.showfreetask := p6_a27;
    ddp_input.showtentativetask := p6_a28;
    ddp_input.taskfirstdetail := p6_a29;
    ddp_input.taskseconddetail := p6_a30;
    ddp_input.taskthirddetail := p6_a31;
    ddp_input.usecalendarsecurity := p6_a32;
    ddp_input.viewtimezoneid := p6_a33;


    -- here's the delegated call to the old PL/SQL routine
    cac_view_pvt.getview(p_api_version,
      p_init_msg_list,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_input,
      ddx_displayitems);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







    cac_view_pvt_w.rosetta_table_copy_out_p4(ddx_displayitems, p7_a0
      , p7_a1
      , p7_a2
      , p7_a3
      , p7_a4
      , p7_a5
      , p7_a6
      , p7_a7
      , p7_a8
      , p7_a9
      , p7_a10
      , p7_a11
      , p7_a12
      , p7_a13
      , p7_a14
      , p7_a15
      , p7_a16
      , p7_a17
      , p7_a18
      , p7_a19
      , p7_a20
      , p7_a21
      , p7_a22
      , p7_a23
      , p7_a24
      , p7_a25
      , p7_a26
      , p7_a27
      );
  end;

end cac_view_pvt_w;

/
