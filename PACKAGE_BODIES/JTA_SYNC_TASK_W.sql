--------------------------------------------------------
--  DDL for Package Body JTA_SYNC_TASK_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTA_SYNC_TASK_W" as
  /* $Header: jtavstwb.pls 120.2 2006/04/27 01:11 deeprao ship $ */
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

  procedure rosetta_table_copy_in_p3(t out nocopy jta_sync_task.task_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_DATE_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_VARCHAR2_TABLE_2000
    , a8 JTF_VARCHAR2_TABLE_4000
    , a9 JTF_VARCHAR2_TABLE_100
    , a10 JTF_DATE_TABLE
    , a11 JTF_DATE_TABLE
    , a12 JTF_DATE_TABLE
    , a13 JTF_DATE_TABLE
    , a14 JTF_DATE_TABLE
    , a15 JTF_DATE_TABLE
    , a16 JTF_NUMBER_TABLE
    , a17 JTF_NUMBER_TABLE
    , a18 JTF_VARCHAR2_TABLE_100
    , a19 JTF_DATE_TABLE
    , a20 JTF_VARCHAR2_TABLE_100
    , a21 JTF_VARCHAR2_TABLE_300
    , a22 JTF_NUMBER_TABLE
    , a23 JTF_VARCHAR2_TABLE_2000
    , a24 JTF_NUMBER_TABLE
    , a25 JTF_NUMBER_TABLE
    , a26 JTF_VARCHAR2_TABLE_300
    , a27 JTF_VARCHAR2_TABLE_2000
    , a28 JTF_VARCHAR2_TABLE_100
    , a29 JTF_NUMBER_TABLE
    , a30 JTF_DATE_TABLE
    , a31 JTF_DATE_TABLE
    , a32 JTF_VARCHAR2_TABLE_100
    , a33 JTF_VARCHAR2_TABLE_100
    , a34 JTF_VARCHAR2_TABLE_100
    , a35 JTF_VARCHAR2_TABLE_100
    , a36 JTF_VARCHAR2_TABLE_100
    , a37 JTF_VARCHAR2_TABLE_100
    , a38 JTF_VARCHAR2_TABLE_100
    , a39 JTF_NUMBER_TABLE
    , a40 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).syncid := a0(indx);
          t(ddindx).recordindex := a1(indx);
          t(ddindx).task_id := a2(indx);
          t(ddindx).syncanchor := rosetta_g_miss_date_in_map(a3(indx));
          t(ddindx).timezoneid := a4(indx);
          t(ddindx).eventtype := a5(indx);
          t(ddindx).objectcode := a6(indx);
          t(ddindx).subject := a7(indx);
          t(ddindx).description := a8(indx);
          t(ddindx).dateselected := a9(indx);
          t(ddindx).plannedstartdate := rosetta_g_miss_date_in_map(a10(indx));
          t(ddindx).plannedenddate := rosetta_g_miss_date_in_map(a11(indx));
          t(ddindx).scheduledstartdate := rosetta_g_miss_date_in_map(a12(indx));
          t(ddindx).scheduledenddate := rosetta_g_miss_date_in_map(a13(indx));
          t(ddindx).actualstartdate := rosetta_g_miss_date_in_map(a14(indx));
          t(ddindx).actualenddate := rosetta_g_miss_date_in_map(a15(indx));
          t(ddindx).statusid := a16(indx);
          t(ddindx).priorityid := a17(indx);
          t(ddindx).alarmflag := a18(indx);
          t(ddindx).alarmdate := rosetta_g_miss_date_in_map(a19(indx));
          t(ddindx).privateflag := a20(indx);
          t(ddindx).category := a21(indx);
          t(ddindx).resourceid := a22(indx);
          t(ddindx).resourcetype := a23(indx);
          t(ddindx).task_assignment_id := a24(indx);
          t(ddindx).resultid := a25(indx);
          t(ddindx).resultsystemmessage := a26(indx);
          t(ddindx).resultusermessage := a27(indx);
          t(ddindx).unit_of_measure := a28(indx);
          t(ddindx).occurs_every := a29(indx);
          t(ddindx).start_date := rosetta_g_miss_date_in_map(a30(indx));
          t(ddindx).end_date := rosetta_g_miss_date_in_map(a31(indx));
          t(ddindx).sunday := a32(indx);
          t(ddindx).monday := a33(indx);
          t(ddindx).tuesday := a34(indx);
          t(ddindx).wednesday := a35(indx);
          t(ddindx).thursday := a36(indx);
          t(ddindx).friday := a37(indx);
          t(ddindx).saturday := a38(indx);
          t(ddindx).date_of_month := a39(indx);
          t(ddindx).occurs_which := a40(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p3;
  procedure rosetta_table_copy_out_p3(t jta_sync_task.task_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_DATE_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    , a7 out nocopy JTF_VARCHAR2_TABLE_2000
    , a8 out nocopy JTF_VARCHAR2_TABLE_4000
    , a9 out nocopy JTF_VARCHAR2_TABLE_100
    , a10 out nocopy JTF_DATE_TABLE
    , a11 out nocopy JTF_DATE_TABLE
    , a12 out nocopy JTF_DATE_TABLE
    , a13 out nocopy JTF_DATE_TABLE
    , a14 out nocopy JTF_DATE_TABLE
    , a15 out nocopy JTF_DATE_TABLE
    , a16 out nocopy JTF_NUMBER_TABLE
    , a17 out nocopy JTF_NUMBER_TABLE
    , a18 out nocopy JTF_VARCHAR2_TABLE_100
    , a19 out nocopy JTF_DATE_TABLE
    , a20 out nocopy JTF_VARCHAR2_TABLE_100
    , a21 out nocopy JTF_VARCHAR2_TABLE_300
    , a22 out nocopy JTF_NUMBER_TABLE
    , a23 out nocopy JTF_VARCHAR2_TABLE_2000
    , a24 out nocopy JTF_NUMBER_TABLE
    , a25 out nocopy JTF_NUMBER_TABLE
    , a26 out nocopy JTF_VARCHAR2_TABLE_300
    , a27 out nocopy JTF_VARCHAR2_TABLE_2000
    , a28 out nocopy JTF_VARCHAR2_TABLE_100
    , a29 out nocopy JTF_NUMBER_TABLE
    , a30 out nocopy JTF_DATE_TABLE
    , a31 out nocopy JTF_DATE_TABLE
    , a32 out nocopy JTF_VARCHAR2_TABLE_100
    , a33 out nocopy JTF_VARCHAR2_TABLE_100
    , a34 out nocopy JTF_VARCHAR2_TABLE_100
    , a35 out nocopy JTF_VARCHAR2_TABLE_100
    , a36 out nocopy JTF_VARCHAR2_TABLE_100
    , a37 out nocopy JTF_VARCHAR2_TABLE_100
    , a38 out nocopy JTF_VARCHAR2_TABLE_100
    , a39 out nocopy JTF_NUMBER_TABLE
    , a40 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_DATE_TABLE();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_VARCHAR2_TABLE_100();
    a6 := JTF_VARCHAR2_TABLE_100();
    a7 := JTF_VARCHAR2_TABLE_2000();
    a8 := JTF_VARCHAR2_TABLE_4000();
    a9 := JTF_VARCHAR2_TABLE_100();
    a10 := JTF_DATE_TABLE();
    a11 := JTF_DATE_TABLE();
    a12 := JTF_DATE_TABLE();
    a13 := JTF_DATE_TABLE();
    a14 := JTF_DATE_TABLE();
    a15 := JTF_DATE_TABLE();
    a16 := JTF_NUMBER_TABLE();
    a17 := JTF_NUMBER_TABLE();
    a18 := JTF_VARCHAR2_TABLE_100();
    a19 := JTF_DATE_TABLE();
    a20 := JTF_VARCHAR2_TABLE_100();
    a21 := JTF_VARCHAR2_TABLE_300();
    a22 := JTF_NUMBER_TABLE();
    a23 := JTF_VARCHAR2_TABLE_2000();
    a24 := JTF_NUMBER_TABLE();
    a25 := JTF_NUMBER_TABLE();
    a26 := JTF_VARCHAR2_TABLE_300();
    a27 := JTF_VARCHAR2_TABLE_2000();
    a28 := JTF_VARCHAR2_TABLE_100();
    a29 := JTF_NUMBER_TABLE();
    a30 := JTF_DATE_TABLE();
    a31 := JTF_DATE_TABLE();
    a32 := JTF_VARCHAR2_TABLE_100();
    a33 := JTF_VARCHAR2_TABLE_100();
    a34 := JTF_VARCHAR2_TABLE_100();
    a35 := JTF_VARCHAR2_TABLE_100();
    a36 := JTF_VARCHAR2_TABLE_100();
    a37 := JTF_VARCHAR2_TABLE_100();
    a38 := JTF_VARCHAR2_TABLE_100();
    a39 := JTF_NUMBER_TABLE();
    a40 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_DATE_TABLE();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_VARCHAR2_TABLE_100();
      a6 := JTF_VARCHAR2_TABLE_100();
      a7 := JTF_VARCHAR2_TABLE_2000();
      a8 := JTF_VARCHAR2_TABLE_4000();
      a9 := JTF_VARCHAR2_TABLE_100();
      a10 := JTF_DATE_TABLE();
      a11 := JTF_DATE_TABLE();
      a12 := JTF_DATE_TABLE();
      a13 := JTF_DATE_TABLE();
      a14 := JTF_DATE_TABLE();
      a15 := JTF_DATE_TABLE();
      a16 := JTF_NUMBER_TABLE();
      a17 := JTF_NUMBER_TABLE();
      a18 := JTF_VARCHAR2_TABLE_100();
      a19 := JTF_DATE_TABLE();
      a20 := JTF_VARCHAR2_TABLE_100();
      a21 := JTF_VARCHAR2_TABLE_300();
      a22 := JTF_NUMBER_TABLE();
      a23 := JTF_VARCHAR2_TABLE_2000();
      a24 := JTF_NUMBER_TABLE();
      a25 := JTF_NUMBER_TABLE();
      a26 := JTF_VARCHAR2_TABLE_300();
      a27 := JTF_VARCHAR2_TABLE_2000();
      a28 := JTF_VARCHAR2_TABLE_100();
      a29 := JTF_NUMBER_TABLE();
      a30 := JTF_DATE_TABLE();
      a31 := JTF_DATE_TABLE();
      a32 := JTF_VARCHAR2_TABLE_100();
      a33 := JTF_VARCHAR2_TABLE_100();
      a34 := JTF_VARCHAR2_TABLE_100();
      a35 := JTF_VARCHAR2_TABLE_100();
      a36 := JTF_VARCHAR2_TABLE_100();
      a37 := JTF_VARCHAR2_TABLE_100();
      a38 := JTF_VARCHAR2_TABLE_100();
      a39 := JTF_NUMBER_TABLE();
      a40 := JTF_NUMBER_TABLE();
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
        a28.extend(t.count);
        a29.extend(t.count);
        a30.extend(t.count);
        a31.extend(t.count);
        a32.extend(t.count);
        a33.extend(t.count);
        a34.extend(t.count);
        a35.extend(t.count);
        a36.extend(t.count);
        a37.extend(t.count);
        a38.extend(t.count);
        a39.extend(t.count);
        a40.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).syncid;
          a1(indx) := t(ddindx).recordindex;
          a2(indx) := t(ddindx).task_id;
          a3(indx) := t(ddindx).syncanchor;
          a4(indx) := t(ddindx).timezoneid;
          a5(indx) := t(ddindx).eventtype;
          a6(indx) := t(ddindx).objectcode;
          a7(indx) := t(ddindx).subject;
          a8(indx) := t(ddindx).description;
          a9(indx) := t(ddindx).dateselected;
          a10(indx) := t(ddindx).plannedstartdate;
          a11(indx) := t(ddindx).plannedenddate;
          a12(indx) := t(ddindx).scheduledstartdate;
          a13(indx) := t(ddindx).scheduledenddate;
          a14(indx) := t(ddindx).actualstartdate;
          a15(indx) := t(ddindx).actualenddate;
          a16(indx) := t(ddindx).statusid;
          a17(indx) := t(ddindx).priorityid;
          a18(indx) := t(ddindx).alarmflag;
          a19(indx) := t(ddindx).alarmdate;
          a20(indx) := t(ddindx).privateflag;
          a21(indx) := t(ddindx).category;
          a22(indx) := t(ddindx).resourceid;
          a23(indx) := t(ddindx).resourcetype;
          a24(indx) := t(ddindx).task_assignment_id;
          a25(indx) := t(ddindx).resultid;
          a26(indx) := t(ddindx).resultsystemmessage;
          a27(indx) := t(ddindx).resultusermessage;
          a28(indx) := t(ddindx).unit_of_measure;
          a29(indx) := t(ddindx).occurs_every;
          a30(indx) := t(ddindx).start_date;
          a31(indx) := t(ddindx).end_date;
          a32(indx) := t(ddindx).sunday;
          a33(indx) := t(ddindx).monday;
          a34(indx) := t(ddindx).tuesday;
          a35(indx) := t(ddindx).wednesday;
          a36(indx) := t(ddindx).thursday;
          a37(indx) := t(ddindx).friday;
          a38(indx) := t(ddindx).saturday;
          a39(indx) := t(ddindx).date_of_month;
          a40(indx) := t(ddindx).occurs_which;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p3;

  procedure rosetta_table_copy_in_p4(t out nocopy jta_sync_task.exclusion_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_DATE_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).syncid := a0(indx);
          t(ddindx).exclusion_date := rosetta_g_miss_date_in_map(a1(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p4;
  procedure rosetta_table_copy_out_p4(t jta_sync_task.exclusion_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_DATE_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_DATE_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_DATE_TABLE();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).syncid;
          a1(indx) := t(ddindx).exclusion_date;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p4;

  procedure get_count(p_request_type  VARCHAR2
    , p_syncanchor  date
    , x_total out nocopy  NUMBER
    , x_totalnew out nocopy  NUMBER
    , x_totalmodified out nocopy  NUMBER
    , x_totaldeleted out nocopy  NUMBER
  )

  as
    ddp_syncanchor date;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    ddp_syncanchor := rosetta_g_miss_date_in_map(p_syncanchor);





    -- here's the delegated call to the old PL/SQL routine
    jta_sync_task.get_count(p_request_type,
      ddp_syncanchor,
      x_total,
      x_totalnew,
      x_totalmodified,
      x_totaldeleted);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure get_list(p_request_type  VARCHAR2
    , p_syncanchor  date
    , p2_a0 out nocopy JTF_NUMBER_TABLE
    , p2_a1 out nocopy JTF_NUMBER_TABLE
    , p2_a2 out nocopy JTF_NUMBER_TABLE
    , p2_a3 out nocopy JTF_DATE_TABLE
    , p2_a4 out nocopy JTF_NUMBER_TABLE
    , p2_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p2_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p2_a7 out nocopy JTF_VARCHAR2_TABLE_2000
    , p2_a8 out nocopy JTF_VARCHAR2_TABLE_4000
    , p2_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , p2_a10 out nocopy JTF_DATE_TABLE
    , p2_a11 out nocopy JTF_DATE_TABLE
    , p2_a12 out nocopy JTF_DATE_TABLE
    , p2_a13 out nocopy JTF_DATE_TABLE
    , p2_a14 out nocopy JTF_DATE_TABLE
    , p2_a15 out nocopy JTF_DATE_TABLE
    , p2_a16 out nocopy JTF_NUMBER_TABLE
    , p2_a17 out nocopy JTF_NUMBER_TABLE
    , p2_a18 out nocopy JTF_VARCHAR2_TABLE_100
    , p2_a19 out nocopy JTF_DATE_TABLE
    , p2_a20 out nocopy JTF_VARCHAR2_TABLE_100
    , p2_a21 out nocopy JTF_VARCHAR2_TABLE_300
    , p2_a22 out nocopy JTF_NUMBER_TABLE
    , p2_a23 out nocopy JTF_VARCHAR2_TABLE_2000
    , p2_a24 out nocopy JTF_NUMBER_TABLE
    , p2_a25 out nocopy JTF_NUMBER_TABLE
    , p2_a26 out nocopy JTF_VARCHAR2_TABLE_300
    , p2_a27 out nocopy JTF_VARCHAR2_TABLE_2000
    , p2_a28 out nocopy JTF_VARCHAR2_TABLE_100
    , p2_a29 out nocopy JTF_NUMBER_TABLE
    , p2_a30 out nocopy JTF_DATE_TABLE
    , p2_a31 out nocopy JTF_DATE_TABLE
    , p2_a32 out nocopy JTF_VARCHAR2_TABLE_100
    , p2_a33 out nocopy JTF_VARCHAR2_TABLE_100
    , p2_a34 out nocopy JTF_VARCHAR2_TABLE_100
    , p2_a35 out nocopy JTF_VARCHAR2_TABLE_100
    , p2_a36 out nocopy JTF_VARCHAR2_TABLE_100
    , p2_a37 out nocopy JTF_VARCHAR2_TABLE_100
    , p2_a38 out nocopy JTF_VARCHAR2_TABLE_100
    , p2_a39 out nocopy JTF_NUMBER_TABLE
    , p2_a40 out nocopy JTF_NUMBER_TABLE
    , p3_a0 out nocopy JTF_NUMBER_TABLE
    , p3_a1 out nocopy JTF_DATE_TABLE
  )

  as
    ddp_syncanchor date;
    ddx_data jta_sync_task.task_tbl;
    ddx_exclusion_data jta_sync_task.exclusion_tbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    ddp_syncanchor := rosetta_g_miss_date_in_map(p_syncanchor);



    -- here's the delegated call to the old PL/SQL routine
    jta_sync_task.get_list(p_request_type,
      ddp_syncanchor,
      ddx_data,
      ddx_exclusion_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any


    jta_sync_task_w.rosetta_table_copy_out_p3(ddx_data, p2_a0
      , p2_a1
      , p2_a2
      , p2_a3
      , p2_a4
      , p2_a5
      , p2_a6
      , p2_a7
      , p2_a8
      , p2_a9
      , p2_a10
      , p2_a11
      , p2_a12
      , p2_a13
      , p2_a14
      , p2_a15
      , p2_a16
      , p2_a17
      , p2_a18
      , p2_a19
      , p2_a20
      , p2_a21
      , p2_a22
      , p2_a23
      , p2_a24
      , p2_a25
      , p2_a26
      , p2_a27
      , p2_a28
      , p2_a29
      , p2_a30
      , p2_a31
      , p2_a32
      , p2_a33
      , p2_a34
      , p2_a35
      , p2_a36
      , p2_a37
      , p2_a38
      , p2_a39
      , p2_a40
      );

    jta_sync_task_w.rosetta_table_copy_out_p4(ddx_exclusion_data, p3_a0
      , p3_a1
      );
  end;

  procedure create_ids(p_num_req  NUMBER
    , p1_a0 in out nocopy JTF_NUMBER_TABLE
    , p1_a1 in out nocopy JTF_NUMBER_TABLE
    , p1_a2 in out nocopy JTF_NUMBER_TABLE
    , p1_a3 in out nocopy JTF_DATE_TABLE
    , p1_a4 in out nocopy JTF_NUMBER_TABLE
    , p1_a5 in out nocopy JTF_VARCHAR2_TABLE_100
    , p1_a6 in out nocopy JTF_VARCHAR2_TABLE_100
    , p1_a7 in out nocopy JTF_VARCHAR2_TABLE_2000
    , p1_a8 in out nocopy JTF_VARCHAR2_TABLE_4000
    , p1_a9 in out nocopy JTF_VARCHAR2_TABLE_100
    , p1_a10 in out nocopy JTF_DATE_TABLE
    , p1_a11 in out nocopy JTF_DATE_TABLE
    , p1_a12 in out nocopy JTF_DATE_TABLE
    , p1_a13 in out nocopy JTF_DATE_TABLE
    , p1_a14 in out nocopy JTF_DATE_TABLE
    , p1_a15 in out nocopy JTF_DATE_TABLE
    , p1_a16 in out nocopy JTF_NUMBER_TABLE
    , p1_a17 in out nocopy JTF_NUMBER_TABLE
    , p1_a18 in out nocopy JTF_VARCHAR2_TABLE_100
    , p1_a19 in out nocopy JTF_DATE_TABLE
    , p1_a20 in out nocopy JTF_VARCHAR2_TABLE_100
    , p1_a21 in out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a22 in out nocopy JTF_NUMBER_TABLE
    , p1_a23 in out nocopy JTF_VARCHAR2_TABLE_2000
    , p1_a24 in out nocopy JTF_NUMBER_TABLE
    , p1_a25 in out nocopy JTF_NUMBER_TABLE
    , p1_a26 in out nocopy JTF_VARCHAR2_TABLE_300
    , p1_a27 in out nocopy JTF_VARCHAR2_TABLE_2000
    , p1_a28 in out nocopy JTF_VARCHAR2_TABLE_100
    , p1_a29 in out nocopy JTF_NUMBER_TABLE
    , p1_a30 in out nocopy JTF_DATE_TABLE
    , p1_a31 in out nocopy JTF_DATE_TABLE
    , p1_a32 in out nocopy JTF_VARCHAR2_TABLE_100
    , p1_a33 in out nocopy JTF_VARCHAR2_TABLE_100
    , p1_a34 in out nocopy JTF_VARCHAR2_TABLE_100
    , p1_a35 in out nocopy JTF_VARCHAR2_TABLE_100
    , p1_a36 in out nocopy JTF_VARCHAR2_TABLE_100
    , p1_a37 in out nocopy JTF_VARCHAR2_TABLE_100
    , p1_a38 in out nocopy JTF_VARCHAR2_TABLE_100
    , p1_a39 in out nocopy JTF_NUMBER_TABLE
    , p1_a40 in out nocopy JTF_NUMBER_TABLE
  )

  as
    ddx_results jta_sync_task.task_tbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    jta_sync_task_w.rosetta_table_copy_in_p3(ddx_results, p1_a0
      , p1_a1
      , p1_a2
      , p1_a3
      , p1_a4
      , p1_a5
      , p1_a6
      , p1_a7
      , p1_a8
      , p1_a9
      , p1_a10
      , p1_a11
      , p1_a12
      , p1_a13
      , p1_a14
      , p1_a15
      , p1_a16
      , p1_a17
      , p1_a18
      , p1_a19
      , p1_a20
      , p1_a21
      , p1_a22
      , p1_a23
      , p1_a24
      , p1_a25
      , p1_a26
      , p1_a27
      , p1_a28
      , p1_a29
      , p1_a30
      , p1_a31
      , p1_a32
      , p1_a33
      , p1_a34
      , p1_a35
      , p1_a36
      , p1_a37
      , p1_a38
      , p1_a39
      , p1_a40
      );

    -- here's the delegated call to the old PL/SQL routine
    jta_sync_task.create_ids(p_num_req,
      ddx_results);

    -- copy data back from the local variables to OUT or IN-OUT args, if any

    jta_sync_task_w.rosetta_table_copy_out_p3(ddx_results, p1_a0
      , p1_a1
      , p1_a2
      , p1_a3
      , p1_a4
      , p1_a5
      , p1_a6
      , p1_a7
      , p1_a8
      , p1_a9
      , p1_a10
      , p1_a11
      , p1_a12
      , p1_a13
      , p1_a14
      , p1_a15
      , p1_a16
      , p1_a17
      , p1_a18
      , p1_a19
      , p1_a20
      , p1_a21
      , p1_a22
      , p1_a23
      , p1_a24
      , p1_a25
      , p1_a26
      , p1_a27
      , p1_a28
      , p1_a29
      , p1_a30
      , p1_a31
      , p1_a32
      , p1_a33
      , p1_a34
      , p1_a35
      , p1_a36
      , p1_a37
      , p1_a38
      , p1_a39
      , p1_a40
      );
  end;

  procedure update_data(p0_a0 in out nocopy JTF_NUMBER_TABLE
    , p0_a1 in out nocopy JTF_NUMBER_TABLE
    , p0_a2 in out nocopy JTF_NUMBER_TABLE
    , p0_a3 in out nocopy JTF_DATE_TABLE
    , p0_a4 in out nocopy JTF_NUMBER_TABLE
    , p0_a5 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a6 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a7 in out nocopy JTF_VARCHAR2_TABLE_2000
    , p0_a8 in out nocopy JTF_VARCHAR2_TABLE_4000
    , p0_a9 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a10 in out nocopy JTF_DATE_TABLE
    , p0_a11 in out nocopy JTF_DATE_TABLE
    , p0_a12 in out nocopy JTF_DATE_TABLE
    , p0_a13 in out nocopy JTF_DATE_TABLE
    , p0_a14 in out nocopy JTF_DATE_TABLE
    , p0_a15 in out nocopy JTF_DATE_TABLE
    , p0_a16 in out nocopy JTF_NUMBER_TABLE
    , p0_a17 in out nocopy JTF_NUMBER_TABLE
    , p0_a18 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a19 in out nocopy JTF_DATE_TABLE
    , p0_a20 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a21 in out nocopy JTF_VARCHAR2_TABLE_300
    , p0_a22 in out nocopy JTF_NUMBER_TABLE
    , p0_a23 in out nocopy JTF_VARCHAR2_TABLE_2000
    , p0_a24 in out nocopy JTF_NUMBER_TABLE
    , p0_a25 in out nocopy JTF_NUMBER_TABLE
    , p0_a26 in out nocopy JTF_VARCHAR2_TABLE_300
    , p0_a27 in out nocopy JTF_VARCHAR2_TABLE_2000
    , p0_a28 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a29 in out nocopy JTF_NUMBER_TABLE
    , p0_a30 in out nocopy JTF_DATE_TABLE
    , p0_a31 in out nocopy JTF_DATE_TABLE
    , p0_a32 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a33 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a34 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a35 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a36 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a37 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a38 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a39 in out nocopy JTF_NUMBER_TABLE
    , p0_a40 in out nocopy JTF_NUMBER_TABLE
    , p1_a0 JTF_NUMBER_TABLE
    , p1_a1 JTF_DATE_TABLE
  )

  as
    ddp_tasks jta_sync_task.task_tbl;
    ddp_exclusions jta_sync_task.exclusion_tbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    jta_sync_task_w.rosetta_table_copy_in_p3(ddp_tasks, p0_a0
      , p0_a1
      , p0_a2
      , p0_a3
      , p0_a4
      , p0_a5
      , p0_a6
      , p0_a7
      , p0_a8
      , p0_a9
      , p0_a10
      , p0_a11
      , p0_a12
      , p0_a13
      , p0_a14
      , p0_a15
      , p0_a16
      , p0_a17
      , p0_a18
      , p0_a19
      , p0_a20
      , p0_a21
      , p0_a22
      , p0_a23
      , p0_a24
      , p0_a25
      , p0_a26
      , p0_a27
      , p0_a28
      , p0_a29
      , p0_a30
      , p0_a31
      , p0_a32
      , p0_a33
      , p0_a34
      , p0_a35
      , p0_a36
      , p0_a37
      , p0_a38
      , p0_a39
      , p0_a40
      );

    jta_sync_task_w.rosetta_table_copy_in_p4(ddp_exclusions, p1_a0
      , p1_a1
      );

    -- here's the delegated call to the old PL/SQL routine
    jta_sync_task.update_data(ddp_tasks,
      ddp_exclusions);

    -- copy data back from the local variables to OUT or IN-OUT args, if any
    jta_sync_task_w.rosetta_table_copy_out_p3(ddp_tasks, p0_a0
      , p0_a1
      , p0_a2
      , p0_a3
      , p0_a4
      , p0_a5
      , p0_a6
      , p0_a7
      , p0_a8
      , p0_a9
      , p0_a10
      , p0_a11
      , p0_a12
      , p0_a13
      , p0_a14
      , p0_a15
      , p0_a16
      , p0_a17
      , p0_a18
      , p0_a19
      , p0_a20
      , p0_a21
      , p0_a22
      , p0_a23
      , p0_a24
      , p0_a25
      , p0_a26
      , p0_a27
      , p0_a28
      , p0_a29
      , p0_a30
      , p0_a31
      , p0_a32
      , p0_a33
      , p0_a34
      , p0_a35
      , p0_a36
      , p0_a37
      , p0_a38
      , p0_a39
      , p0_a40
      );

  end;

  procedure delete_data(p0_a0 in out nocopy JTF_NUMBER_TABLE
    , p0_a1 in out nocopy JTF_NUMBER_TABLE
    , p0_a2 in out nocopy JTF_NUMBER_TABLE
    , p0_a3 in out nocopy JTF_DATE_TABLE
    , p0_a4 in out nocopy JTF_NUMBER_TABLE
    , p0_a5 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a6 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a7 in out nocopy JTF_VARCHAR2_TABLE_2000
    , p0_a8 in out nocopy JTF_VARCHAR2_TABLE_4000
    , p0_a9 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a10 in out nocopy JTF_DATE_TABLE
    , p0_a11 in out nocopy JTF_DATE_TABLE
    , p0_a12 in out nocopy JTF_DATE_TABLE
    , p0_a13 in out nocopy JTF_DATE_TABLE
    , p0_a14 in out nocopy JTF_DATE_TABLE
    , p0_a15 in out nocopy JTF_DATE_TABLE
    , p0_a16 in out nocopy JTF_NUMBER_TABLE
    , p0_a17 in out nocopy JTF_NUMBER_TABLE
    , p0_a18 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a19 in out nocopy JTF_DATE_TABLE
    , p0_a20 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a21 in out nocopy JTF_VARCHAR2_TABLE_300
    , p0_a22 in out nocopy JTF_NUMBER_TABLE
    , p0_a23 in out nocopy JTF_VARCHAR2_TABLE_2000
    , p0_a24 in out nocopy JTF_NUMBER_TABLE
    , p0_a25 in out nocopy JTF_NUMBER_TABLE
    , p0_a26 in out nocopy JTF_VARCHAR2_TABLE_300
    , p0_a27 in out nocopy JTF_VARCHAR2_TABLE_2000
    , p0_a28 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a29 in out nocopy JTF_NUMBER_TABLE
    , p0_a30 in out nocopy JTF_DATE_TABLE
    , p0_a31 in out nocopy JTF_DATE_TABLE
    , p0_a32 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a33 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a34 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a35 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a36 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a37 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a38 in out nocopy JTF_VARCHAR2_TABLE_100
    , p0_a39 in out nocopy JTF_NUMBER_TABLE
    , p0_a40 in out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_tasks jta_sync_task.task_tbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    jta_sync_task_w.rosetta_table_copy_in_p3(ddp_tasks, p0_a0
      , p0_a1
      , p0_a2
      , p0_a3
      , p0_a4
      , p0_a5
      , p0_a6
      , p0_a7
      , p0_a8
      , p0_a9
      , p0_a10
      , p0_a11
      , p0_a12
      , p0_a13
      , p0_a14
      , p0_a15
      , p0_a16
      , p0_a17
      , p0_a18
      , p0_a19
      , p0_a20
      , p0_a21
      , p0_a22
      , p0_a23
      , p0_a24
      , p0_a25
      , p0_a26
      , p0_a27
      , p0_a28
      , p0_a29
      , p0_a30
      , p0_a31
      , p0_a32
      , p0_a33
      , p0_a34
      , p0_a35
      , p0_a36
      , p0_a37
      , p0_a38
      , p0_a39
      , p0_a40
      );

    -- here's the delegated call to the old PL/SQL routine
    jta_sync_task.delete_data(ddp_tasks);

    -- copy data back from the local variables to OUT or IN-OUT args, if any
    jta_sync_task_w.rosetta_table_copy_out_p3(ddp_tasks, p0_a0
      , p0_a1
      , p0_a2
      , p0_a3
      , p0_a4
      , p0_a5
      , p0_a6
      , p0_a7
      , p0_a8
      , p0_a9
      , p0_a10
      , p0_a11
      , p0_a12
      , p0_a13
      , p0_a14
      , p0_a15
      , p0_a16
      , p0_a17
      , p0_a18
      , p0_a19
      , p0_a20
      , p0_a21
      , p0_a22
      , p0_a23
      , p0_a24
      , p0_a25
      , p0_a26
      , p0_a27
      , p0_a28
      , p0_a29
      , p0_a30
      , p0_a31
      , p0_a32
      , p0_a33
      , p0_a34
      , p0_a35
      , p0_a36
      , p0_a37
      , p0_a38
      , p0_a39
      , p0_a40
      );
  end;

end jta_sync_task_w;

/
