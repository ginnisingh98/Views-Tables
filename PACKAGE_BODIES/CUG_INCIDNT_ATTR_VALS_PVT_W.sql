--------------------------------------------------------
--  DDL for Package Body CUG_INCIDNT_ATTR_VALS_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CUG_INCIDNT_ATTR_VALS_PVT_W" as
  /* $Header: CUGRINWB.pls 115.4 2003/12/30 19:50:48 aneemuch ship $ */
  rosetta_g_mistake_date date := to_date('01/01/+4713', 'MM/DD/SYYYY');
  rosetta_g_miss_date date := to_date('01/01/-4712', 'MM/DD/SYYYY');

  -- this is to workaround the JDBC bug regarding IN DATE of value GMiss
  function rosetta_g_miss_date_in_map(d date) return date as
  begin
    if d = rosetta_g_mistake_date then return fnd_api.g_miss_date; end if;
    return d;
  end;

  procedure rosetta_table_copy_in_p1(t out nocopy cug_incidnt_attr_vals_pvt.sr_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_300
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_VARCHAR2_TABLE_2000
    , a5 JTF_DATE_TABLE
    , a6 JTF_DATE_TABLE
    , a7 JTF_VARCHAR2_TABLE_200
    , a8 JTF_VARCHAR2_TABLE_200
    , a9 JTF_VARCHAR2_TABLE_200
    , a10 JTF_VARCHAR2_TABLE_200
    , a11 JTF_VARCHAR2_TABLE_200
    , a12 JTF_VARCHAR2_TABLE_200
    , a13 JTF_VARCHAR2_TABLE_200
    , a14 JTF_VARCHAR2_TABLE_200
    , a15 JTF_VARCHAR2_TABLE_200
    , a16 JTF_VARCHAR2_TABLE_200
    , a17 JTF_VARCHAR2_TABLE_200
    , a18 JTF_VARCHAR2_TABLE_200
    , a19 JTF_VARCHAR2_TABLE_200
    , a20 JTF_VARCHAR2_TABLE_200
    , a21 JTF_VARCHAR2_TABLE_200
    , a22 JTF_VARCHAR2_TABLE_200
    , a23 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).incidnt_attr_val_id := a0(indx);
          t(ddindx).incident_id := a1(indx);
          t(ddindx).sr_question := a2(indx);
          t(ddindx).override_addr_valid_flag := a3(indx);
          t(ddindx).sr_answer := a4(indx);
          t(ddindx).start_date := rosetta_g_miss_date_in_map(a5(indx));
          t(ddindx).end_date := rosetta_g_miss_date_in_map(a6(indx));
          t(ddindx).attribute_category := a7(indx);
          t(ddindx).attribute1 := a8(indx);
          t(ddindx).attribute2 := a9(indx);
          t(ddindx).attribute3 := a10(indx);
          t(ddindx).attribute4 := a11(indx);
          t(ddindx).attribute5 := a12(indx);
          t(ddindx).attribute6 := a13(indx);
          t(ddindx).attribute7 := a14(indx);
          t(ddindx).attribute8 := a15(indx);
          t(ddindx).attribute9 := a16(indx);
          t(ddindx).attribute10 := a17(indx);
          t(ddindx).attribute11 := a18(indx);
          t(ddindx).attribute12 := a19(indx);
          t(ddindx).attribute13 := a20(indx);
          t(ddindx).attribute14 := a21(indx);
          t(ddindx).attribute15 := a22(indx);
          t(ddindx).object_version_number := a23(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p1;
  procedure rosetta_table_copy_out_p1(t cug_incidnt_attr_vals_pvt.sr_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_300
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_VARCHAR2_TABLE_2000
    , a5 out nocopy JTF_DATE_TABLE
    , a6 out nocopy JTF_DATE_TABLE
    , a7 out nocopy JTF_VARCHAR2_TABLE_200
    , a8 out nocopy JTF_VARCHAR2_TABLE_200
    , a9 out nocopy JTF_VARCHAR2_TABLE_200
    , a10 out nocopy JTF_VARCHAR2_TABLE_200
    , a11 out nocopy JTF_VARCHAR2_TABLE_200
    , a12 out nocopy JTF_VARCHAR2_TABLE_200
    , a13 out nocopy JTF_VARCHAR2_TABLE_200
    , a14 out nocopy JTF_VARCHAR2_TABLE_200
    , a15 out nocopy JTF_VARCHAR2_TABLE_200
    , a16 out nocopy JTF_VARCHAR2_TABLE_200
    , a17 out nocopy JTF_VARCHAR2_TABLE_200
    , a18 out nocopy JTF_VARCHAR2_TABLE_200
    , a19 out nocopy JTF_VARCHAR2_TABLE_200
    , a20 out nocopy JTF_VARCHAR2_TABLE_200
    , a21 out nocopy JTF_VARCHAR2_TABLE_200
    , a22 out nocopy JTF_VARCHAR2_TABLE_200
    , a23 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_VARCHAR2_TABLE_300();
    a3 := JTF_VARCHAR2_TABLE_100();
    a4 := JTF_VARCHAR2_TABLE_2000();
    a5 := JTF_DATE_TABLE();
    a6 := JTF_DATE_TABLE();
    a7 := JTF_VARCHAR2_TABLE_200();
    a8 := JTF_VARCHAR2_TABLE_200();
    a9 := JTF_VARCHAR2_TABLE_200();
    a10 := JTF_VARCHAR2_TABLE_200();
    a11 := JTF_VARCHAR2_TABLE_200();
    a12 := JTF_VARCHAR2_TABLE_200();
    a13 := JTF_VARCHAR2_TABLE_200();
    a14 := JTF_VARCHAR2_TABLE_200();
    a15 := JTF_VARCHAR2_TABLE_200();
    a16 := JTF_VARCHAR2_TABLE_200();
    a17 := JTF_VARCHAR2_TABLE_200();
    a18 := JTF_VARCHAR2_TABLE_200();
    a19 := JTF_VARCHAR2_TABLE_200();
    a20 := JTF_VARCHAR2_TABLE_200();
    a21 := JTF_VARCHAR2_TABLE_200();
    a22 := JTF_VARCHAR2_TABLE_200();
    a23 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_VARCHAR2_TABLE_300();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_VARCHAR2_TABLE_2000();
      a5 := JTF_DATE_TABLE();
      a6 := JTF_DATE_TABLE();
      a7 := JTF_VARCHAR2_TABLE_200();
      a8 := JTF_VARCHAR2_TABLE_200();
      a9 := JTF_VARCHAR2_TABLE_200();
      a10 := JTF_VARCHAR2_TABLE_200();
      a11 := JTF_VARCHAR2_TABLE_200();
      a12 := JTF_VARCHAR2_TABLE_200();
      a13 := JTF_VARCHAR2_TABLE_200();
      a14 := JTF_VARCHAR2_TABLE_200();
      a15 := JTF_VARCHAR2_TABLE_200();
      a16 := JTF_VARCHAR2_TABLE_200();
      a17 := JTF_VARCHAR2_TABLE_200();
      a18 := JTF_VARCHAR2_TABLE_200();
      a19 := JTF_VARCHAR2_TABLE_200();
      a20 := JTF_VARCHAR2_TABLE_200();
      a21 := JTF_VARCHAR2_TABLE_200();
      a22 := JTF_VARCHAR2_TABLE_200();
      a23 := JTF_NUMBER_TABLE();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).incidnt_attr_val_id;
          a1(indx) := t(ddindx).incident_id;
          a2(indx) := t(ddindx).sr_question;
          a3(indx) := t(ddindx).override_addr_valid_flag;
          a4(indx) := t(ddindx).sr_answer;
          a5(indx) := t(ddindx).start_date;
          a6(indx) := t(ddindx).end_date;
          a7(indx) := t(ddindx).attribute_category;
          a8(indx) := t(ddindx).attribute1;
          a9(indx) := t(ddindx).attribute2;
          a10(indx) := t(ddindx).attribute3;
          a11(indx) := t(ddindx).attribute4;
          a12(indx) := t(ddindx).attribute5;
          a13(indx) := t(ddindx).attribute6;
          a14(indx) := t(ddindx).attribute7;
          a15(indx) := t(ddindx).attribute8;
          a16(indx) := t(ddindx).attribute9;
          a17(indx) := t(ddindx).attribute10;
          a18(indx) := t(ddindx).attribute11;
          a19(indx) := t(ddindx).attribute12;
          a20(indx) := t(ddindx).attribute13;
          a21(indx) := t(ddindx).attribute14;
          a22(indx) := t(ddindx).attribute15;
          a23(indx) := t(ddindx).object_version_number;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p1;

  procedure create_runtime_data(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR
    , p3_a0 in out nocopy JTF_NUMBER_TABLE
    , p3_a1 in out nocopy JTF_NUMBER_TABLE
    , p3_a2 in out nocopy JTF_VARCHAR2_TABLE_300
    , p3_a3 in out nocopy JTF_VARCHAR2_TABLE_100
    , p3_a4 in out nocopy JTF_VARCHAR2_TABLE_2000
    , p3_a5 in out nocopy JTF_DATE_TABLE
    , p3_a6 in out nocopy JTF_DATE_TABLE
    , p3_a7 in out nocopy JTF_VARCHAR2_TABLE_200
    , p3_a8 in out nocopy JTF_VARCHAR2_TABLE_200
    , p3_a9 in out nocopy JTF_VARCHAR2_TABLE_200
    , p3_a10 in out nocopy JTF_VARCHAR2_TABLE_200
    , p3_a11 in out nocopy JTF_VARCHAR2_TABLE_200
    , p3_a12 in out nocopy JTF_VARCHAR2_TABLE_200
    , p3_a13 in out nocopy JTF_VARCHAR2_TABLE_200
    , p3_a14 in out nocopy JTF_VARCHAR2_TABLE_200
    , p3_a15 in out nocopy JTF_VARCHAR2_TABLE_200
    , p3_a16 in out nocopy JTF_VARCHAR2_TABLE_200
    , p3_a17 in out nocopy JTF_VARCHAR2_TABLE_200
    , p3_a18 in out nocopy JTF_VARCHAR2_TABLE_200
    , p3_a19 in out nocopy JTF_VARCHAR2_TABLE_200
    , p3_a20 in out nocopy JTF_VARCHAR2_TABLE_200
    , p3_a21 in out nocopy JTF_VARCHAR2_TABLE_200
    , p3_a22 in out nocopy JTF_VARCHAR2_TABLE_200
    , p3_a23 in out nocopy JTF_NUMBER_TABLE
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
  )

  as
    ddp_sr_tbl cug_incidnt_attr_vals_pvt.sr_tbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    cug_incidnt_attr_vals_pvt_w.rosetta_table_copy_in_p1(ddp_sr_tbl, p3_a0
      , p3_a1
      , p3_a2
      , p3_a3
      , p3_a4
      , p3_a5
      , p3_a6
      , p3_a7
      , p3_a8
      , p3_a9
      , p3_a10
      , p3_a11
      , p3_a12
      , p3_a13
      , p3_a14
      , p3_a15
      , p3_a16
      , p3_a17
      , p3_a18
      , p3_a19
      , p3_a20
      , p3_a21
      , p3_a22
      , p3_a23
      );




    -- here's the delegated call to the old PL/SQL routine
    cug_incidnt_attr_vals_pvt.create_runtime_data(p_api_version,
      p_init_msg_list,
      p_commit,
      ddp_sr_tbl,
      x_msg_count,
      x_msg_data,
      x_return_status);

    -- copy data back from the local variables to OUT or IN-OUT args, if any



    cug_incidnt_attr_vals_pvt_w.rosetta_table_copy_out_p1(ddp_sr_tbl, p3_a0
      , p3_a1
      , p3_a2
      , p3_a3
      , p3_a4
      , p3_a5
      , p3_a6
      , p3_a7
      , p3_a8
      , p3_a9
      , p3_a10
      , p3_a11
      , p3_a12
      , p3_a13
      , p3_a14
      , p3_a15
      , p3_a16
      , p3_a17
      , p3_a18
      , p3_a19
      , p3_a20
      , p3_a21
      , p3_a22
      , p3_a23
      );



  end;

end cug_incidnt_attr_vals_pvt_w;

/
