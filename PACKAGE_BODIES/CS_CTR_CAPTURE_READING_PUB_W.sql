--------------------------------------------------------
--  DDL for Package Body CS_CTR_CAPTURE_READING_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_CTR_CAPTURE_READING_PUB_W" as
  /* $Header: csxwcrdb.pls 115.17 2004/08/25 19:17:37 rktow ship $ */
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

  procedure rosetta_table_copy_in_p4(t out nocopy cs_ctr_capture_reading_pub.ctr_rdg_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_DATE_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_VARCHAR2_TABLE_300
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_NUMBER_TABLE
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
    , a23 JTF_VARCHAR2_TABLE_200
    , a24 JTF_VARCHAR2_TABLE_200
    , a25 JTF_VARCHAR2_TABLE_200
    , a26 JTF_VARCHAR2_TABLE_100
    , a27 JTF_VARCHAR2_TABLE_100
    , a28 JTF_VARCHAR2_TABLE_100
    , a29 JTF_VARCHAR2_TABLE_2000
    , a30 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).counter_value_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).counter_id := rosetta_g_miss_num_map(a1(indx));
          t(ddindx).value_timestamp := rosetta_g_miss_date_in_map(a2(indx));
          t(ddindx).counter_reading := rosetta_g_miss_num_map(a3(indx));
          t(ddindx).reset_flag := a4(indx);
          t(ddindx).reset_reason := a5(indx);
          t(ddindx).pre_reset_last_rdg := rosetta_g_miss_num_map(a6(indx));
          t(ddindx).post_reset_first_rdg := rosetta_g_miss_num_map(a7(indx));
          t(ddindx).misc_reading_type := a8(indx);
          t(ddindx).misc_reading := rosetta_g_miss_num_map(a9(indx));
          t(ddindx).object_version_number := rosetta_g_miss_num_map(a10(indx));
          t(ddindx).attribute1 := a11(indx);
          t(ddindx).attribute2 := a12(indx);
          t(ddindx).attribute3 := a13(indx);
          t(ddindx).attribute4 := a14(indx);
          t(ddindx).attribute5 := a15(indx);
          t(ddindx).attribute6 := a16(indx);
          t(ddindx).attribute7 := a17(indx);
          t(ddindx).attribute8 := a18(indx);
          t(ddindx).attribute9 := a19(indx);
          t(ddindx).attribute10 := a20(indx);
          t(ddindx).attribute11 := a21(indx);
          t(ddindx).attribute12 := a22(indx);
          t(ddindx).attribute13 := a23(indx);
          t(ddindx).attribute14 := a24(indx);
          t(ddindx).attribute15 := a25(indx);
          t(ddindx).context := a26(indx);
          t(ddindx).valid_flag := a27(indx);
          t(ddindx).override_valid_flag := a28(indx);
          t(ddindx).comments := a29(indx);
          t(ddindx).filter_reading_count := rosetta_g_miss_num_map(a30(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p4;
  procedure rosetta_table_copy_out_p4(t cs_ctr_capture_reading_pub.ctr_rdg_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_DATE_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_VARCHAR2_TABLE_300
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_NUMBER_TABLE
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
    , a23 out nocopy JTF_VARCHAR2_TABLE_200
    , a24 out nocopy JTF_VARCHAR2_TABLE_200
    , a25 out nocopy JTF_VARCHAR2_TABLE_200
    , a26 out nocopy JTF_VARCHAR2_TABLE_100
    , a27 out nocopy JTF_VARCHAR2_TABLE_100
    , a28 out nocopy JTF_VARCHAR2_TABLE_100
    , a29 out nocopy JTF_VARCHAR2_TABLE_2000
    , a30 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_DATE_TABLE();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_VARCHAR2_TABLE_100();
    a5 := JTF_VARCHAR2_TABLE_300();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_VARCHAR2_TABLE_100();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_NUMBER_TABLE();
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
    a23 := JTF_VARCHAR2_TABLE_200();
    a24 := JTF_VARCHAR2_TABLE_200();
    a25 := JTF_VARCHAR2_TABLE_200();
    a26 := JTF_VARCHAR2_TABLE_100();
    a27 := JTF_VARCHAR2_TABLE_100();
    a28 := JTF_VARCHAR2_TABLE_100();
    a29 := JTF_VARCHAR2_TABLE_2000();
    a30 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_DATE_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_VARCHAR2_TABLE_100();
      a5 := JTF_VARCHAR2_TABLE_300();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_VARCHAR2_TABLE_100();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_NUMBER_TABLE();
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
      a23 := JTF_VARCHAR2_TABLE_200();
      a24 := JTF_VARCHAR2_TABLE_200();
      a25 := JTF_VARCHAR2_TABLE_200();
      a26 := JTF_VARCHAR2_TABLE_100();
      a27 := JTF_VARCHAR2_TABLE_100();
      a28 := JTF_VARCHAR2_TABLE_100();
      a29 := JTF_VARCHAR2_TABLE_2000();
      a30 := JTF_NUMBER_TABLE();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).counter_value_id);
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).counter_id);
          a2(indx) := t(ddindx).value_timestamp;
          a3(indx) := rosetta_g_miss_num_map(t(ddindx).counter_reading);
          a4(indx) := t(ddindx).reset_flag;
          a5(indx) := t(ddindx).reset_reason;
          a6(indx) := rosetta_g_miss_num_map(t(ddindx).pre_reset_last_rdg);
          a7(indx) := rosetta_g_miss_num_map(t(ddindx).post_reset_first_rdg);
          a8(indx) := t(ddindx).misc_reading_type;
          a9(indx) := rosetta_g_miss_num_map(t(ddindx).misc_reading);
          a10(indx) := rosetta_g_miss_num_map(t(ddindx).object_version_number);
          a11(indx) := t(ddindx).attribute1;
          a12(indx) := t(ddindx).attribute2;
          a13(indx) := t(ddindx).attribute3;
          a14(indx) := t(ddindx).attribute4;
          a15(indx) := t(ddindx).attribute5;
          a16(indx) := t(ddindx).attribute6;
          a17(indx) := t(ddindx).attribute7;
          a18(indx) := t(ddindx).attribute8;
          a19(indx) := t(ddindx).attribute9;
          a20(indx) := t(ddindx).attribute10;
          a21(indx) := t(ddindx).attribute11;
          a22(indx) := t(ddindx).attribute12;
          a23(indx) := t(ddindx).attribute13;
          a24(indx) := t(ddindx).attribute14;
          a25(indx) := t(ddindx).attribute15;
          a26(indx) := t(ddindx).context;
          a27(indx) := t(ddindx).valid_flag;
          a28(indx) := t(ddindx).override_valid_flag;
          a29(indx) := t(ddindx).comments;
          a30(indx) := rosetta_g_miss_num_map(t(ddindx).filter_reading_count);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p4;

  procedure rosetta_table_copy_in_p8(t out nocopy cs_ctr_capture_reading_pub.prop_rdg_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_DATE_TABLE
    , a3 JTF_VARCHAR2_TABLE_300
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_VARCHAR2_TABLE_200
    , a6 JTF_VARCHAR2_TABLE_200
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
    , a20 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).counter_prop_value_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).counter_property_id := rosetta_g_miss_num_map(a1(indx));
          t(ddindx).value_timestamp := rosetta_g_miss_date_in_map(a2(indx));
          t(ddindx).property_value := a3(indx);
          t(ddindx).object_version_number := rosetta_g_miss_num_map(a4(indx));
          t(ddindx).attribute1 := a5(indx);
          t(ddindx).attribute2 := a6(indx);
          t(ddindx).attribute3 := a7(indx);
          t(ddindx).attribute4 := a8(indx);
          t(ddindx).attribute5 := a9(indx);
          t(ddindx).attribute6 := a10(indx);
          t(ddindx).attribute7 := a11(indx);
          t(ddindx).attribute8 := a12(indx);
          t(ddindx).attribute9 := a13(indx);
          t(ddindx).attribute10 := a14(indx);
          t(ddindx).attribute11 := a15(indx);
          t(ddindx).attribute12 := a16(indx);
          t(ddindx).attribute13 := a17(indx);
          t(ddindx).attribute14 := a18(indx);
          t(ddindx).attribute15 := a19(indx);
          t(ddindx).context := a20(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p8;
  procedure rosetta_table_copy_out_p8(t cs_ctr_capture_reading_pub.prop_rdg_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_DATE_TABLE
    , a3 out nocopy JTF_VARCHAR2_TABLE_300
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_VARCHAR2_TABLE_200
    , a6 out nocopy JTF_VARCHAR2_TABLE_200
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
    , a20 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_DATE_TABLE();
    a3 := JTF_VARCHAR2_TABLE_300();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_VARCHAR2_TABLE_200();
    a6 := JTF_VARCHAR2_TABLE_200();
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
    a20 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_DATE_TABLE();
      a3 := JTF_VARCHAR2_TABLE_300();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_VARCHAR2_TABLE_200();
      a6 := JTF_VARCHAR2_TABLE_200();
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
      a20 := JTF_VARCHAR2_TABLE_100();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).counter_prop_value_id);
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).counter_property_id);
          a2(indx) := t(ddindx).value_timestamp;
          a3(indx) := t(ddindx).property_value;
          a4(indx) := rosetta_g_miss_num_map(t(ddindx).object_version_number);
          a5(indx) := t(ddindx).attribute1;
          a6(indx) := t(ddindx).attribute2;
          a7(indx) := t(ddindx).attribute3;
          a8(indx) := t(ddindx).attribute4;
          a9(indx) := t(ddindx).attribute5;
          a10(indx) := t(ddindx).attribute6;
          a11(indx) := t(ddindx).attribute7;
          a12(indx) := t(ddindx).attribute8;
          a13(indx) := t(ddindx).attribute9;
          a14(indx) := t(ddindx).attribute10;
          a15(indx) := t(ddindx).attribute11;
          a16(indx) := t(ddindx).attribute12;
          a17(indx) := t(ddindx).attribute13;
          a18(indx) := t(ddindx).attribute14;
          a19(indx) := t(ddindx).attribute15;
          a20(indx) := t(ddindx).context;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p8;

  procedure capture_counter_reading(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_DATE_TABLE
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_VARCHAR2_TABLE_100
    , p5_a5 JTF_VARCHAR2_TABLE_300
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_VARCHAR2_TABLE_100
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_NUMBER_TABLE
    , p5_a11 JTF_VARCHAR2_TABLE_200
    , p5_a12 JTF_VARCHAR2_TABLE_200
    , p5_a13 JTF_VARCHAR2_TABLE_200
    , p5_a14 JTF_VARCHAR2_TABLE_200
    , p5_a15 JTF_VARCHAR2_TABLE_200
    , p5_a16 JTF_VARCHAR2_TABLE_200
    , p5_a17 JTF_VARCHAR2_TABLE_200
    , p5_a18 JTF_VARCHAR2_TABLE_200
    , p5_a19 JTF_VARCHAR2_TABLE_200
    , p5_a20 JTF_VARCHAR2_TABLE_200
    , p5_a21 JTF_VARCHAR2_TABLE_200
    , p5_a22 JTF_VARCHAR2_TABLE_200
    , p5_a23 JTF_VARCHAR2_TABLE_200
    , p5_a24 JTF_VARCHAR2_TABLE_200
    , p5_a25 JTF_VARCHAR2_TABLE_200
    , p5_a26 JTF_VARCHAR2_TABLE_100
    , p5_a27 JTF_VARCHAR2_TABLE_100
    , p5_a28 JTF_VARCHAR2_TABLE_100
    , p5_a29 JTF_VARCHAR2_TABLE_2000
    , p5_a30 JTF_NUMBER_TABLE
    , p6_a0 JTF_NUMBER_TABLE
    , p6_a1 JTF_NUMBER_TABLE
    , p6_a2 JTF_DATE_TABLE
    , p6_a3 JTF_VARCHAR2_TABLE_300
    , p6_a4 JTF_NUMBER_TABLE
    , p6_a5 JTF_VARCHAR2_TABLE_200
    , p6_a6 JTF_VARCHAR2_TABLE_200
    , p6_a7 JTF_VARCHAR2_TABLE_200
    , p6_a8 JTF_VARCHAR2_TABLE_200
    , p6_a9 JTF_VARCHAR2_TABLE_200
    , p6_a10 JTF_VARCHAR2_TABLE_200
    , p6_a11 JTF_VARCHAR2_TABLE_200
    , p6_a12 JTF_VARCHAR2_TABLE_200
    , p6_a13 JTF_VARCHAR2_TABLE_200
    , p6_a14 JTF_VARCHAR2_TABLE_200
    , p6_a15 JTF_VARCHAR2_TABLE_200
    , p6_a16 JTF_VARCHAR2_TABLE_200
    , p6_a17 JTF_VARCHAR2_TABLE_200
    , p6_a18 JTF_VARCHAR2_TABLE_200
    , p6_a19 JTF_VARCHAR2_TABLE_200
    , p6_a20 JTF_VARCHAR2_TABLE_100
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p4_a0  NUMBER := 0-1962.0724
    , p4_a1  NUMBER := 0-1962.0724
    , p4_a2  DATE := fnd_api.g_miss_date
    , p4_a3  NUMBER := 0-1962.0724
    , p4_a4  VARCHAR2 := fnd_api.g_miss_char
    , p4_a5  VARCHAR2 := fnd_api.g_miss_char
    , p4_a6  VARCHAR2 := fnd_api.g_miss_char
    , p4_a7  VARCHAR2 := fnd_api.g_miss_char
    , p4_a8  VARCHAR2 := fnd_api.g_miss_char
    , p4_a9  VARCHAR2 := fnd_api.g_miss_char
    , p4_a10  VARCHAR2 := fnd_api.g_miss_char
    , p4_a11  VARCHAR2 := fnd_api.g_miss_char
    , p4_a12  VARCHAR2 := fnd_api.g_miss_char
    , p4_a13  VARCHAR2 := fnd_api.g_miss_char
    , p4_a14  VARCHAR2 := fnd_api.g_miss_char
    , p4_a15  VARCHAR2 := fnd_api.g_miss_char
    , p4_a16  VARCHAR2 := fnd_api.g_miss_char
    , p4_a17  VARCHAR2 := fnd_api.g_miss_char
    , p4_a18  VARCHAR2 := fnd_api.g_miss_char
    , p4_a19  VARCHAR2 := fnd_api.g_miss_char
    , p4_a20  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_ctr_grp_log_rec cs_ctr_capture_reading_pub.ctr_grp_log_rec_type;
    ddp_ctr_rdg_tbl cs_ctr_capture_reading_pub.ctr_rdg_tbl_type;
    ddp_prop_rdg_tbl cs_ctr_capture_reading_pub.prop_rdg_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    ddp_ctr_grp_log_rec.counter_grp_log_id := rosetta_g_miss_num_map(p4_a0);
    ddp_ctr_grp_log_rec.counter_group_id := rosetta_g_miss_num_map(p4_a1);
    ddp_ctr_grp_log_rec.value_timestamp := rosetta_g_miss_date_in_map(p4_a2);
    ddp_ctr_grp_log_rec.source_transaction_id := rosetta_g_miss_num_map(p4_a3);
    ddp_ctr_grp_log_rec.source_transaction_code := p4_a4;
    ddp_ctr_grp_log_rec.attribute1 := p4_a5;
    ddp_ctr_grp_log_rec.attribute2 := p4_a6;
    ddp_ctr_grp_log_rec.attribute3 := p4_a7;
    ddp_ctr_grp_log_rec.attribute4 := p4_a8;
    ddp_ctr_grp_log_rec.attribute5 := p4_a9;
    ddp_ctr_grp_log_rec.attribute6 := p4_a10;
    ddp_ctr_grp_log_rec.attribute7 := p4_a11;
    ddp_ctr_grp_log_rec.attribute8 := p4_a12;
    ddp_ctr_grp_log_rec.attribute9 := p4_a13;
    ddp_ctr_grp_log_rec.attribute10 := p4_a14;
    ddp_ctr_grp_log_rec.attribute11 := p4_a15;
    ddp_ctr_grp_log_rec.attribute12 := p4_a16;
    ddp_ctr_grp_log_rec.attribute13 := p4_a17;
    ddp_ctr_grp_log_rec.attribute14 := p4_a18;
    ddp_ctr_grp_log_rec.attribute15 := p4_a19;
    ddp_ctr_grp_log_rec.context := p4_a20;

    cs_ctr_capture_reading_pub_w.rosetta_table_copy_in_p4(ddp_ctr_rdg_tbl, p5_a0
      , p5_a1
      , p5_a2
      , p5_a3
      , p5_a4
      , p5_a5
      , p5_a6
      , p5_a7
      , p5_a8
      , p5_a9
      , p5_a10
      , p5_a11
      , p5_a12
      , p5_a13
      , p5_a14
      , p5_a15
      , p5_a16
      , p5_a17
      , p5_a18
      , p5_a19
      , p5_a20
      , p5_a21
      , p5_a22
      , p5_a23
      , p5_a24
      , p5_a25
      , p5_a26
      , p5_a27
      , p5_a28
      , p5_a29
      , p5_a30
      );

    cs_ctr_capture_reading_pub_w.rosetta_table_copy_in_p8(ddp_prop_rdg_tbl, p6_a0
      , p6_a1
      , p6_a2
      , p6_a3
      , p6_a4
      , p6_a5
      , p6_a6
      , p6_a7
      , p6_a8
      , p6_a9
      , p6_a10
      , p6_a11
      , p6_a12
      , p6_a13
      , p6_a14
      , p6_a15
      , p6_a16
      , p6_a17
      , p6_a18
      , p6_a19
      , p6_a20
      );




    -- here's the delegated call to the old PL/SQL routine
    cs_ctr_capture_reading_pub.capture_counter_reading(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      ddp_ctr_grp_log_rec,
      ddp_ctr_rdg_tbl,
      ddp_prop_rdg_tbl,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any

   IF NOT(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
CSI_GEN_UTILITY_PVT.dump_x_msg_data(x_msg_count, x_msg_data);
END IF;







  end;

  procedure update_counter_reading(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_ctr_grp_log_id  NUMBER
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_DATE_TABLE
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_VARCHAR2_TABLE_100
    , p5_a5 JTF_VARCHAR2_TABLE_300
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_VARCHAR2_TABLE_100
    , p5_a9 JTF_NUMBER_TABLE
    , p5_a10 JTF_NUMBER_TABLE
    , p5_a11 JTF_VARCHAR2_TABLE_200
    , p5_a12 JTF_VARCHAR2_TABLE_200
    , p5_a13 JTF_VARCHAR2_TABLE_200
    , p5_a14 JTF_VARCHAR2_TABLE_200
    , p5_a15 JTF_VARCHAR2_TABLE_200
    , p5_a16 JTF_VARCHAR2_TABLE_200
    , p5_a17 JTF_VARCHAR2_TABLE_200
    , p5_a18 JTF_VARCHAR2_TABLE_200
    , p5_a19 JTF_VARCHAR2_TABLE_200
    , p5_a20 JTF_VARCHAR2_TABLE_200
    , p5_a21 JTF_VARCHAR2_TABLE_200
    , p5_a22 JTF_VARCHAR2_TABLE_200
    , p5_a23 JTF_VARCHAR2_TABLE_200
    , p5_a24 JTF_VARCHAR2_TABLE_200
    , p5_a25 JTF_VARCHAR2_TABLE_200
    , p5_a26 JTF_VARCHAR2_TABLE_100
    , p5_a27 JTF_VARCHAR2_TABLE_100
    , p5_a28 JTF_VARCHAR2_TABLE_100
    , p5_a29 JTF_VARCHAR2_TABLE_2000
    , p5_a30 JTF_NUMBER_TABLE
    , p6_a0 JTF_NUMBER_TABLE
    , p6_a1 JTF_NUMBER_TABLE
    , p6_a2 JTF_DATE_TABLE
    , p6_a3 JTF_VARCHAR2_TABLE_300
    , p6_a4 JTF_NUMBER_TABLE
    , p6_a5 JTF_VARCHAR2_TABLE_200
    , p6_a6 JTF_VARCHAR2_TABLE_200
    , p6_a7 JTF_VARCHAR2_TABLE_200
    , p6_a8 JTF_VARCHAR2_TABLE_200
    , p6_a9 JTF_VARCHAR2_TABLE_200
    , p6_a10 JTF_VARCHAR2_TABLE_200
    , p6_a11 JTF_VARCHAR2_TABLE_200
    , p6_a12 JTF_VARCHAR2_TABLE_200
    , p6_a13 JTF_VARCHAR2_TABLE_200
    , p6_a14 JTF_VARCHAR2_TABLE_200
    , p6_a15 JTF_VARCHAR2_TABLE_200
    , p6_a16 JTF_VARCHAR2_TABLE_200
    , p6_a17 JTF_VARCHAR2_TABLE_200
    , p6_a18 JTF_VARCHAR2_TABLE_200
    , p6_a19 JTF_VARCHAR2_TABLE_200
    , p6_a20 JTF_VARCHAR2_TABLE_100
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_ctr_rdg_tbl cs_ctr_capture_reading_pub.ctr_rdg_tbl_type;
    ddp_prop_rdg_tbl cs_ctr_capture_reading_pub.prop_rdg_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    cs_ctr_capture_reading_pub_w.rosetta_table_copy_in_p4(ddp_ctr_rdg_tbl, p5_a0
      , p5_a1
      , p5_a2
      , p5_a3
      , p5_a4
      , p5_a5
      , p5_a6
      , p5_a7
      , p5_a8
      , p5_a9
      , p5_a10
      , p5_a11
      , p5_a12
      , p5_a13
      , p5_a14
      , p5_a15
      , p5_a16
      , p5_a17
      , p5_a18
      , p5_a19
      , p5_a20
      , p5_a21
      , p5_a22
      , p5_a23
      , p5_a24
      , p5_a25
      , p5_a26
      , p5_a27
      , p5_a28
      , p5_a29
      , p5_a30
      );

    cs_ctr_capture_reading_pub_w.rosetta_table_copy_in_p8(ddp_prop_rdg_tbl, p6_a0
      , p6_a1
      , p6_a2
      , p6_a3
      , p6_a4
      , p6_a5
      , p6_a6
      , p6_a7
      , p6_a8
      , p6_a9
      , p6_a10
      , p6_a11
      , p6_a12
      , p6_a13
      , p6_a14
      , p6_a15
      , p6_a16
      , p6_a17
      , p6_a18
      , p6_a19
      , p6_a20
      );




    -- here's the delegated call to the old PL/SQL routine
    cs_ctr_capture_reading_pub.update_counter_reading(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      p_ctr_grp_log_id,
      ddp_ctr_rdg_tbl,
      ddp_prop_rdg_tbl,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any









  end;

  procedure capture_counter_reading(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_counter_grp_log_id  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p4_a0  NUMBER := 0-1962.0724
    , p4_a1  NUMBER := 0-1962.0724
    , p4_a2  DATE := fnd_api.g_miss_date
    , p4_a3  NUMBER := 0-1962.0724
    , p4_a4  VARCHAR2 := fnd_api.g_miss_char
    , p4_a5  VARCHAR2 := fnd_api.g_miss_char
    , p4_a6  NUMBER := 0-1962.0724
    , p4_a7  NUMBER := 0-1962.0724
    , p4_a8  VARCHAR2 := fnd_api.g_miss_char
    , p4_a9  NUMBER := 0-1962.0724
    , p4_a10  NUMBER := 0-1962.0724
    , p4_a11  VARCHAR2 := fnd_api.g_miss_char
    , p4_a12  VARCHAR2 := fnd_api.g_miss_char
    , p4_a13  VARCHAR2 := fnd_api.g_miss_char
    , p4_a14  VARCHAR2 := fnd_api.g_miss_char
    , p4_a15  VARCHAR2 := fnd_api.g_miss_char
    , p4_a16  VARCHAR2 := fnd_api.g_miss_char
    , p4_a17  VARCHAR2 := fnd_api.g_miss_char
    , p4_a18  VARCHAR2 := fnd_api.g_miss_char
    , p4_a19  VARCHAR2 := fnd_api.g_miss_char
    , p4_a20  VARCHAR2 := fnd_api.g_miss_char
    , p4_a21  VARCHAR2 := fnd_api.g_miss_char
    , p4_a22  VARCHAR2 := fnd_api.g_miss_char
    , p4_a23  VARCHAR2 := fnd_api.g_miss_char
    , p4_a24  VARCHAR2 := fnd_api.g_miss_char
    , p4_a25  VARCHAR2 := fnd_api.g_miss_char
    , p4_a26  VARCHAR2 := fnd_api.g_miss_char
    , p4_a27  VARCHAR2 := fnd_api.g_miss_char
    , p4_a28  VARCHAR2 := fnd_api.g_miss_char
    , p4_a29  VARCHAR2 := fnd_api.g_miss_char
    , p4_a30  NUMBER := 0-1962.0724
  )

  as
    ddp_ctr_rdg_rec cs_ctr_capture_reading_pub.ctr_rdg_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    ddp_ctr_rdg_rec.counter_value_id := rosetta_g_miss_num_map(p4_a0);
    ddp_ctr_rdg_rec.counter_id := rosetta_g_miss_num_map(p4_a1);
    ddp_ctr_rdg_rec.value_timestamp := rosetta_g_miss_date_in_map(p4_a2);
    ddp_ctr_rdg_rec.counter_reading := rosetta_g_miss_num_map(p4_a3);
    ddp_ctr_rdg_rec.reset_flag := p4_a4;
    ddp_ctr_rdg_rec.reset_reason := p4_a5;
    ddp_ctr_rdg_rec.pre_reset_last_rdg := rosetta_g_miss_num_map(p4_a6);
    ddp_ctr_rdg_rec.post_reset_first_rdg := rosetta_g_miss_num_map(p4_a7);
    ddp_ctr_rdg_rec.misc_reading_type := p4_a8;
    ddp_ctr_rdg_rec.misc_reading := rosetta_g_miss_num_map(p4_a9);
    ddp_ctr_rdg_rec.object_version_number := rosetta_g_miss_num_map(p4_a10);
    ddp_ctr_rdg_rec.attribute1 := p4_a11;
    ddp_ctr_rdg_rec.attribute2 := p4_a12;
    ddp_ctr_rdg_rec.attribute3 := p4_a13;
    ddp_ctr_rdg_rec.attribute4 := p4_a14;
    ddp_ctr_rdg_rec.attribute5 := p4_a15;
    ddp_ctr_rdg_rec.attribute6 := p4_a16;
    ddp_ctr_rdg_rec.attribute7 := p4_a17;
    ddp_ctr_rdg_rec.attribute8 := p4_a18;
    ddp_ctr_rdg_rec.attribute9 := p4_a19;
    ddp_ctr_rdg_rec.attribute10 := p4_a20;
    ddp_ctr_rdg_rec.attribute11 := p4_a21;
    ddp_ctr_rdg_rec.attribute12 := p4_a22;
    ddp_ctr_rdg_rec.attribute13 := p4_a23;
    ddp_ctr_rdg_rec.attribute14 := p4_a24;
    ddp_ctr_rdg_rec.attribute15 := p4_a25;
    ddp_ctr_rdg_rec.context := p4_a26;
    ddp_ctr_rdg_rec.valid_flag := p4_a27;
    ddp_ctr_rdg_rec.override_valid_flag := p4_a28;
    ddp_ctr_rdg_rec.comments := p4_a29;
    ddp_ctr_rdg_rec.filter_reading_count := rosetta_g_miss_num_map(p4_a30);





    -- here's the delegated call to the old PL/SQL routine
    cs_ctr_capture_reading_pub.capture_counter_reading(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      ddp_ctr_rdg_rec,
      p_counter_grp_log_id,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

  procedure update_counter_reading(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_counter_grp_log_id  NUMBER
    , p_object_version_number  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p4_a0  NUMBER := 0-1962.0724
    , p4_a1  NUMBER := 0-1962.0724
    , p4_a2  DATE := fnd_api.g_miss_date
    , p4_a3  NUMBER := 0-1962.0724
    , p4_a4  VARCHAR2 := fnd_api.g_miss_char
    , p4_a5  VARCHAR2 := fnd_api.g_miss_char
    , p4_a6  NUMBER := 0-1962.0724
    , p4_a7  NUMBER := 0-1962.0724
    , p4_a8  VARCHAR2 := fnd_api.g_miss_char
    , p4_a9  NUMBER := 0-1962.0724
    , p4_a10  NUMBER := 0-1962.0724
    , p4_a11  VARCHAR2 := fnd_api.g_miss_char
    , p4_a12  VARCHAR2 := fnd_api.g_miss_char
    , p4_a13  VARCHAR2 := fnd_api.g_miss_char
    , p4_a14  VARCHAR2 := fnd_api.g_miss_char
    , p4_a15  VARCHAR2 := fnd_api.g_miss_char
    , p4_a16  VARCHAR2 := fnd_api.g_miss_char
    , p4_a17  VARCHAR2 := fnd_api.g_miss_char
    , p4_a18  VARCHAR2 := fnd_api.g_miss_char
    , p4_a19  VARCHAR2 := fnd_api.g_miss_char
    , p4_a20  VARCHAR2 := fnd_api.g_miss_char
    , p4_a21  VARCHAR2 := fnd_api.g_miss_char
    , p4_a22  VARCHAR2 := fnd_api.g_miss_char
    , p4_a23  VARCHAR2 := fnd_api.g_miss_char
    , p4_a24  VARCHAR2 := fnd_api.g_miss_char
    , p4_a25  VARCHAR2 := fnd_api.g_miss_char
    , p4_a26  VARCHAR2 := fnd_api.g_miss_char
    , p4_a27  VARCHAR2 := fnd_api.g_miss_char
    , p4_a28  VARCHAR2 := fnd_api.g_miss_char
    , p4_a29  VARCHAR2 := fnd_api.g_miss_char
    , p4_a30  NUMBER := 0-1962.0724
  )

  as
    ddp_ctr_rdg_rec cs_ctr_capture_reading_pub.ctr_rdg_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    ddp_ctr_rdg_rec.counter_value_id := rosetta_g_miss_num_map(p4_a0);
    ddp_ctr_rdg_rec.counter_id := rosetta_g_miss_num_map(p4_a1);
    ddp_ctr_rdg_rec.value_timestamp := rosetta_g_miss_date_in_map(p4_a2);
    ddp_ctr_rdg_rec.counter_reading := rosetta_g_miss_num_map(p4_a3);
    ddp_ctr_rdg_rec.reset_flag := p4_a4;
    ddp_ctr_rdg_rec.reset_reason := p4_a5;
    ddp_ctr_rdg_rec.pre_reset_last_rdg := rosetta_g_miss_num_map(p4_a6);
    ddp_ctr_rdg_rec.post_reset_first_rdg := rosetta_g_miss_num_map(p4_a7);
    ddp_ctr_rdg_rec.misc_reading_type := p4_a8;
    ddp_ctr_rdg_rec.misc_reading := rosetta_g_miss_num_map(p4_a9);
    ddp_ctr_rdg_rec.object_version_number := rosetta_g_miss_num_map(p4_a10);
    ddp_ctr_rdg_rec.attribute1 := p4_a11;
    ddp_ctr_rdg_rec.attribute2 := p4_a12;
    ddp_ctr_rdg_rec.attribute3 := p4_a13;
    ddp_ctr_rdg_rec.attribute4 := p4_a14;
    ddp_ctr_rdg_rec.attribute5 := p4_a15;
    ddp_ctr_rdg_rec.attribute6 := p4_a16;
    ddp_ctr_rdg_rec.attribute7 := p4_a17;
    ddp_ctr_rdg_rec.attribute8 := p4_a18;
    ddp_ctr_rdg_rec.attribute9 := p4_a19;
    ddp_ctr_rdg_rec.attribute10 := p4_a20;
    ddp_ctr_rdg_rec.attribute11 := p4_a21;
    ddp_ctr_rdg_rec.attribute12 := p4_a22;
    ddp_ctr_rdg_rec.attribute13 := p4_a23;
    ddp_ctr_rdg_rec.attribute14 := p4_a24;
    ddp_ctr_rdg_rec.attribute15 := p4_a25;
    ddp_ctr_rdg_rec.context := p4_a26;
    ddp_ctr_rdg_rec.valid_flag := p4_a27;
    ddp_ctr_rdg_rec.override_valid_flag := p4_a28;
    ddp_ctr_rdg_rec.comments := p4_a29;
    ddp_ctr_rdg_rec.filter_reading_count := rosetta_g_miss_num_map(p4_a30);






    -- here's the delegated call to the old PL/SQL routine
    cs_ctr_capture_reading_pub.update_counter_reading(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      ddp_ctr_rdg_rec,
      p_counter_grp_log_id,
      p_object_version_number,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any









  end;

  procedure pre_capture_ctr_reading(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_counter_grp_log_id in out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p4_a0  NUMBER := 0-1962.0724
    , p4_a1  NUMBER := 0-1962.0724
    , p4_a2  DATE := fnd_api.g_miss_date
    , p4_a3  NUMBER := 0-1962.0724
    , p4_a4  VARCHAR2 := fnd_api.g_miss_char
    , p4_a5  VARCHAR2 := fnd_api.g_miss_char
    , p4_a6  VARCHAR2 := fnd_api.g_miss_char
    , p4_a7  VARCHAR2 := fnd_api.g_miss_char
    , p4_a8  VARCHAR2 := fnd_api.g_miss_char
    , p4_a9  VARCHAR2 := fnd_api.g_miss_char
    , p4_a10  VARCHAR2 := fnd_api.g_miss_char
    , p4_a11  VARCHAR2 := fnd_api.g_miss_char
    , p4_a12  VARCHAR2 := fnd_api.g_miss_char
    , p4_a13  VARCHAR2 := fnd_api.g_miss_char
    , p4_a14  VARCHAR2 := fnd_api.g_miss_char
    , p4_a15  VARCHAR2 := fnd_api.g_miss_char
    , p4_a16  VARCHAR2 := fnd_api.g_miss_char
    , p4_a17  VARCHAR2 := fnd_api.g_miss_char
    , p4_a18  VARCHAR2 := fnd_api.g_miss_char
    , p4_a19  VARCHAR2 := fnd_api.g_miss_char
    , p4_a20  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_ctr_grp_log_rec cs_ctr_capture_reading_pub.ctr_grp_log_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    ddp_ctr_grp_log_rec.counter_grp_log_id := rosetta_g_miss_num_map(p4_a0);
    ddp_ctr_grp_log_rec.counter_group_id := rosetta_g_miss_num_map(p4_a1);
    ddp_ctr_grp_log_rec.value_timestamp := rosetta_g_miss_date_in_map(p4_a2);
    ddp_ctr_grp_log_rec.source_transaction_id := rosetta_g_miss_num_map(p4_a3);
    ddp_ctr_grp_log_rec.source_transaction_code := p4_a4;
    ddp_ctr_grp_log_rec.attribute1 := p4_a5;
    ddp_ctr_grp_log_rec.attribute2 := p4_a6;
    ddp_ctr_grp_log_rec.attribute3 := p4_a7;
    ddp_ctr_grp_log_rec.attribute4 := p4_a8;
    ddp_ctr_grp_log_rec.attribute5 := p4_a9;
    ddp_ctr_grp_log_rec.attribute6 := p4_a10;
    ddp_ctr_grp_log_rec.attribute7 := p4_a11;
    ddp_ctr_grp_log_rec.attribute8 := p4_a12;
    ddp_ctr_grp_log_rec.attribute9 := p4_a13;
    ddp_ctr_grp_log_rec.attribute10 := p4_a14;
    ddp_ctr_grp_log_rec.attribute11 := p4_a15;
    ddp_ctr_grp_log_rec.attribute12 := p4_a16;
    ddp_ctr_grp_log_rec.attribute13 := p4_a17;
    ddp_ctr_grp_log_rec.attribute14 := p4_a18;
    ddp_ctr_grp_log_rec.attribute15 := p4_a19;
    ddp_ctr_grp_log_rec.context := p4_a20;





    -- here's the delegated call to the old PL/SQL routine
    cs_ctr_capture_reading_pub.pre_capture_ctr_reading(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      ddp_ctr_grp_log_rec,
      x_counter_grp_log_id,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

  procedure capture_ctr_prop_reading(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_counter_grp_log_id  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p4_a0  NUMBER := 0-1962.0724
    , p4_a1  NUMBER := 0-1962.0724
    , p4_a2  DATE := fnd_api.g_miss_date
    , p4_a3  VARCHAR2 := fnd_api.g_miss_char
    , p4_a4  NUMBER := 0-1962.0724
    , p4_a5  VARCHAR2 := fnd_api.g_miss_char
    , p4_a6  VARCHAR2 := fnd_api.g_miss_char
    , p4_a7  VARCHAR2 := fnd_api.g_miss_char
    , p4_a8  VARCHAR2 := fnd_api.g_miss_char
    , p4_a9  VARCHAR2 := fnd_api.g_miss_char
    , p4_a10  VARCHAR2 := fnd_api.g_miss_char
    , p4_a11  VARCHAR2 := fnd_api.g_miss_char
    , p4_a12  VARCHAR2 := fnd_api.g_miss_char
    , p4_a13  VARCHAR2 := fnd_api.g_miss_char
    , p4_a14  VARCHAR2 := fnd_api.g_miss_char
    , p4_a15  VARCHAR2 := fnd_api.g_miss_char
    , p4_a16  VARCHAR2 := fnd_api.g_miss_char
    , p4_a17  VARCHAR2 := fnd_api.g_miss_char
    , p4_a18  VARCHAR2 := fnd_api.g_miss_char
    , p4_a19  VARCHAR2 := fnd_api.g_miss_char
    , p4_a20  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_prop_rdg_rec cs_ctr_capture_reading_pub.prop_rdg_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    ddp_prop_rdg_rec.counter_prop_value_id := rosetta_g_miss_num_map(p4_a0);
    ddp_prop_rdg_rec.counter_property_id := rosetta_g_miss_num_map(p4_a1);
    ddp_prop_rdg_rec.value_timestamp := rosetta_g_miss_date_in_map(p4_a2);
    ddp_prop_rdg_rec.property_value := p4_a3;
    ddp_prop_rdg_rec.object_version_number := rosetta_g_miss_num_map(p4_a4);
    ddp_prop_rdg_rec.attribute1 := p4_a5;
    ddp_prop_rdg_rec.attribute2 := p4_a6;
    ddp_prop_rdg_rec.attribute3 := p4_a7;
    ddp_prop_rdg_rec.attribute4 := p4_a8;
    ddp_prop_rdg_rec.attribute5 := p4_a9;
    ddp_prop_rdg_rec.attribute6 := p4_a10;
    ddp_prop_rdg_rec.attribute7 := p4_a11;
    ddp_prop_rdg_rec.attribute8 := p4_a12;
    ddp_prop_rdg_rec.attribute9 := p4_a13;
    ddp_prop_rdg_rec.attribute10 := p4_a14;
    ddp_prop_rdg_rec.attribute11 := p4_a15;
    ddp_prop_rdg_rec.attribute12 := p4_a16;
    ddp_prop_rdg_rec.attribute13 := p4_a17;
    ddp_prop_rdg_rec.attribute14 := p4_a18;
    ddp_prop_rdg_rec.attribute15 := p4_a19;
    ddp_prop_rdg_rec.context := p4_a20;





    -- here's the delegated call to the old PL/SQL routine
    cs_ctr_capture_reading_pub.capture_ctr_prop_reading(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      ddp_prop_rdg_rec,
      p_counter_grp_log_id,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

  procedure update_ctr_prop_reading(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_counter_grp_log_id  NUMBER
    , p_object_version_number  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p4_a0  NUMBER := 0-1962.0724
    , p4_a1  NUMBER := 0-1962.0724
    , p4_a2  DATE := fnd_api.g_miss_date
    , p4_a3  VARCHAR2 := fnd_api.g_miss_char
    , p4_a4  NUMBER := 0-1962.0724
    , p4_a5  VARCHAR2 := fnd_api.g_miss_char
    , p4_a6  VARCHAR2 := fnd_api.g_miss_char
    , p4_a7  VARCHAR2 := fnd_api.g_miss_char
    , p4_a8  VARCHAR2 := fnd_api.g_miss_char
    , p4_a9  VARCHAR2 := fnd_api.g_miss_char
    , p4_a10  VARCHAR2 := fnd_api.g_miss_char
    , p4_a11  VARCHAR2 := fnd_api.g_miss_char
    , p4_a12  VARCHAR2 := fnd_api.g_miss_char
    , p4_a13  VARCHAR2 := fnd_api.g_miss_char
    , p4_a14  VARCHAR2 := fnd_api.g_miss_char
    , p4_a15  VARCHAR2 := fnd_api.g_miss_char
    , p4_a16  VARCHAR2 := fnd_api.g_miss_char
    , p4_a17  VARCHAR2 := fnd_api.g_miss_char
    , p4_a18  VARCHAR2 := fnd_api.g_miss_char
    , p4_a19  VARCHAR2 := fnd_api.g_miss_char
    , p4_a20  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_prop_rdg_rec cs_ctr_capture_reading_pub.prop_rdg_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    ddp_prop_rdg_rec.counter_prop_value_id := rosetta_g_miss_num_map(p4_a0);
    ddp_prop_rdg_rec.counter_property_id := rosetta_g_miss_num_map(p4_a1);
    ddp_prop_rdg_rec.value_timestamp := rosetta_g_miss_date_in_map(p4_a2);
    ddp_prop_rdg_rec.property_value := p4_a3;
    ddp_prop_rdg_rec.object_version_number := rosetta_g_miss_num_map(p4_a4);
    ddp_prop_rdg_rec.attribute1 := p4_a5;
    ddp_prop_rdg_rec.attribute2 := p4_a6;
    ddp_prop_rdg_rec.attribute3 := p4_a7;
    ddp_prop_rdg_rec.attribute4 := p4_a8;
    ddp_prop_rdg_rec.attribute5 := p4_a9;
    ddp_prop_rdg_rec.attribute6 := p4_a10;
    ddp_prop_rdg_rec.attribute7 := p4_a11;
    ddp_prop_rdg_rec.attribute8 := p4_a12;
    ddp_prop_rdg_rec.attribute9 := p4_a13;
    ddp_prop_rdg_rec.attribute10 := p4_a14;
    ddp_prop_rdg_rec.attribute11 := p4_a15;
    ddp_prop_rdg_rec.attribute12 := p4_a16;
    ddp_prop_rdg_rec.attribute13 := p4_a17;
    ddp_prop_rdg_rec.attribute14 := p4_a18;
    ddp_prop_rdg_rec.attribute15 := p4_a19;
    ddp_prop_rdg_rec.context := p4_a20;






    -- here's the delegated call to the old PL/SQL routine
    cs_ctr_capture_reading_pub.update_ctr_prop_reading(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      ddp_prop_rdg_rec,
      p_counter_grp_log_id,
      p_object_version_number,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any









  end;

end cs_ctr_capture_reading_pub_w;

/
