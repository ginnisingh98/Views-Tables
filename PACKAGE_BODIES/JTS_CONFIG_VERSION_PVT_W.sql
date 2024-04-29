--------------------------------------------------------
--  DDL for Package Body JTS_CONFIG_VERSION_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTS_CONFIG_VERSION_PVT_W" as
  /* $Header: jtswcvrb.pls 115.5 2002/03/27 18:03:14 pkm ship    $ */
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

  procedure rosetta_table_copy_in_p4(t out jts_config_version_pvt.config_version_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_VARCHAR2_TABLE_300
    , a5 JTF_VARCHAR2_TABLE_100
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
    , a20 JTF_VARCHAR2_TABLE_200
    , a21 JTF_VARCHAR2_TABLE_200
    , a22 JTF_DATE_TABLE
    , a23 JTF_NUMBER_TABLE
    , a24 JTF_DATE_TABLE
    , a25 JTF_NUMBER_TABLE
    , a26 JTF_NUMBER_TABLE
    , a27 JTF_VARCHAR2_TABLE_100
    , a28 JTF_VARCHAR2_TABLE_100
    , a29 JTF_VARCHAR2_TABLE_100
    , a30 JTF_VARCHAR2_TABLE_300
    , a31 JTF_NUMBER_TABLE
    , a32 JTF_VARCHAR2_TABLE_100
    , a33 JTF_VARCHAR2_TABLE_100
    , a34 JTF_VARCHAR2_TABLE_100
    , a35 JTF_VARCHAR2_TABLE_100
    , a36 JTF_DATE_TABLE
    , a37 JTF_VARCHAR2_TABLE_100
    , a38 JTF_VARCHAR2_TABLE_100
    , a39 JTF_VARCHAR2_TABLE_100
    , a40 JTF_VARCHAR2_TABLE_100
    , a41 JTF_VARCHAR2_TABLE_100
    , a42 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).configuration_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).version_id := rosetta_g_miss_num_map(a1(indx));
          t(ddindx).version_name := a2(indx);
          t(ddindx).version_number := rosetta_g_miss_num_map(a3(indx));
          t(ddindx).description := a4(indx);
          t(ddindx).queue_name := a5(indx);
          t(ddindx).attribute_category := a6(indx);
          t(ddindx).attribute1 := a7(indx);
          t(ddindx).attribute2 := a8(indx);
          t(ddindx).attribute3 := a9(indx);
          t(ddindx).attribute4 := a10(indx);
          t(ddindx).attribute5 := a11(indx);
          t(ddindx).attribute6 := a12(indx);
          t(ddindx).attribute7 := a13(indx);
          t(ddindx).attribute8 := a14(indx);
          t(ddindx).attribute9 := a15(indx);
          t(ddindx).attribute10 := a16(indx);
          t(ddindx).attribute11 := a17(indx);
          t(ddindx).attribute12 := a18(indx);
          t(ddindx).attribute13 := a19(indx);
          t(ddindx).attribute14 := a20(indx);
          t(ddindx).attribute15 := a21(indx);
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a22(indx));
          t(ddindx).created_by := rosetta_g_miss_num_map(a23(indx));
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a24(indx));
          t(ddindx).last_updated_by := rosetta_g_miss_num_map(a25(indx));
          t(ddindx).last_update_login := rosetta_g_miss_num_map(a26(indx));
          t(ddindx).created_by_name := a27(indx);
          t(ddindx).last_updated_by_name := a28(indx);
          t(ddindx).config_name := a29(indx);
          t(ddindx).config_desc := a30(indx);
          t(ddindx).config_flow_id := rosetta_g_miss_num_map(a31(indx));
          t(ddindx).config_flow_name := a32(indx);
          t(ddindx).config_flow_type := a33(indx);
          t(ddindx).config_record_mode := a34(indx);
          t(ddindx).config_disp_record_mode := a35(indx);
          t(ddindx).replayed_date := rosetta_g_miss_date_in_map(a36(indx));
          t(ddindx).replayed_by_name := a37(indx);
          t(ddindx).replay_status_code := a38(indx);
          t(ddindx).version_status_code := a39(indx);
          t(ddindx).replay_status := a40(indx);
          t(ddindx).version_status := a41(indx);
          t(ddindx).percent_completed := rosetta_g_miss_num_map(a42(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p4;
  procedure rosetta_table_copy_out_p4(t jts_config_version_pvt.config_version_tbl_type, a0 out JTF_NUMBER_TABLE
    , a1 out JTF_NUMBER_TABLE
    , a2 out JTF_VARCHAR2_TABLE_100
    , a3 out JTF_NUMBER_TABLE
    , a4 out JTF_VARCHAR2_TABLE_300
    , a5 out JTF_VARCHAR2_TABLE_100
    , a6 out JTF_VARCHAR2_TABLE_200
    , a7 out JTF_VARCHAR2_TABLE_200
    , a8 out JTF_VARCHAR2_TABLE_200
    , a9 out JTF_VARCHAR2_TABLE_200
    , a10 out JTF_VARCHAR2_TABLE_200
    , a11 out JTF_VARCHAR2_TABLE_200
    , a12 out JTF_VARCHAR2_TABLE_200
    , a13 out JTF_VARCHAR2_TABLE_200
    , a14 out JTF_VARCHAR2_TABLE_200
    , a15 out JTF_VARCHAR2_TABLE_200
    , a16 out JTF_VARCHAR2_TABLE_200
    , a17 out JTF_VARCHAR2_TABLE_200
    , a18 out JTF_VARCHAR2_TABLE_200
    , a19 out JTF_VARCHAR2_TABLE_200
    , a20 out JTF_VARCHAR2_TABLE_200
    , a21 out JTF_VARCHAR2_TABLE_200
    , a22 out JTF_DATE_TABLE
    , a23 out JTF_NUMBER_TABLE
    , a24 out JTF_DATE_TABLE
    , a25 out JTF_NUMBER_TABLE
    , a26 out JTF_NUMBER_TABLE
    , a27 out JTF_VARCHAR2_TABLE_100
    , a28 out JTF_VARCHAR2_TABLE_100
    , a29 out JTF_VARCHAR2_TABLE_100
    , a30 out JTF_VARCHAR2_TABLE_300
    , a31 out JTF_NUMBER_TABLE
    , a32 out JTF_VARCHAR2_TABLE_100
    , a33 out JTF_VARCHAR2_TABLE_100
    , a34 out JTF_VARCHAR2_TABLE_100
    , a35 out JTF_VARCHAR2_TABLE_100
    , a36 out JTF_DATE_TABLE
    , a37 out JTF_VARCHAR2_TABLE_100
    , a38 out JTF_VARCHAR2_TABLE_100
    , a39 out JTF_VARCHAR2_TABLE_100
    , a40 out JTF_VARCHAR2_TABLE_100
    , a41 out JTF_VARCHAR2_TABLE_100
    , a42 out JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_VARCHAR2_TABLE_300();
    a5 := JTF_VARCHAR2_TABLE_100();
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
    a20 := JTF_VARCHAR2_TABLE_200();
    a21 := JTF_VARCHAR2_TABLE_200();
    a22 := JTF_DATE_TABLE();
    a23 := JTF_NUMBER_TABLE();
    a24 := JTF_DATE_TABLE();
    a25 := JTF_NUMBER_TABLE();
    a26 := JTF_NUMBER_TABLE();
    a27 := JTF_VARCHAR2_TABLE_100();
    a28 := JTF_VARCHAR2_TABLE_100();
    a29 := JTF_VARCHAR2_TABLE_100();
    a30 := JTF_VARCHAR2_TABLE_300();
    a31 := JTF_NUMBER_TABLE();
    a32 := JTF_VARCHAR2_TABLE_100();
    a33 := JTF_VARCHAR2_TABLE_100();
    a34 := JTF_VARCHAR2_TABLE_100();
    a35 := JTF_VARCHAR2_TABLE_100();
    a36 := JTF_DATE_TABLE();
    a37 := JTF_VARCHAR2_TABLE_100();
    a38 := JTF_VARCHAR2_TABLE_100();
    a39 := JTF_VARCHAR2_TABLE_100();
    a40 := JTF_VARCHAR2_TABLE_100();
    a41 := JTF_VARCHAR2_TABLE_100();
    a42 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_VARCHAR2_TABLE_300();
      a5 := JTF_VARCHAR2_TABLE_100();
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
      a20 := JTF_VARCHAR2_TABLE_200();
      a21 := JTF_VARCHAR2_TABLE_200();
      a22 := JTF_DATE_TABLE();
      a23 := JTF_NUMBER_TABLE();
      a24 := JTF_DATE_TABLE();
      a25 := JTF_NUMBER_TABLE();
      a26 := JTF_NUMBER_TABLE();
      a27 := JTF_VARCHAR2_TABLE_100();
      a28 := JTF_VARCHAR2_TABLE_100();
      a29 := JTF_VARCHAR2_TABLE_100();
      a30 := JTF_VARCHAR2_TABLE_300();
      a31 := JTF_NUMBER_TABLE();
      a32 := JTF_VARCHAR2_TABLE_100();
      a33 := JTF_VARCHAR2_TABLE_100();
      a34 := JTF_VARCHAR2_TABLE_100();
      a35 := JTF_VARCHAR2_TABLE_100();
      a36 := JTF_DATE_TABLE();
      a37 := JTF_VARCHAR2_TABLE_100();
      a38 := JTF_VARCHAR2_TABLE_100();
      a39 := JTF_VARCHAR2_TABLE_100();
      a40 := JTF_VARCHAR2_TABLE_100();
      a41 := JTF_VARCHAR2_TABLE_100();
      a42 := JTF_NUMBER_TABLE();
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
        a41.extend(t.count);
        a42.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).configuration_id);
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).version_id);
          a2(indx) := t(ddindx).version_name;
          a3(indx) := rosetta_g_miss_num_map(t(ddindx).version_number);
          a4(indx) := t(ddindx).description;
          a5(indx) := t(ddindx).queue_name;
          a6(indx) := t(ddindx).attribute_category;
          a7(indx) := t(ddindx).attribute1;
          a8(indx) := t(ddindx).attribute2;
          a9(indx) := t(ddindx).attribute3;
          a10(indx) := t(ddindx).attribute4;
          a11(indx) := t(ddindx).attribute5;
          a12(indx) := t(ddindx).attribute6;
          a13(indx) := t(ddindx).attribute7;
          a14(indx) := t(ddindx).attribute8;
          a15(indx) := t(ddindx).attribute9;
          a16(indx) := t(ddindx).attribute10;
          a17(indx) := t(ddindx).attribute11;
          a18(indx) := t(ddindx).attribute12;
          a19(indx) := t(ddindx).attribute13;
          a20(indx) := t(ddindx).attribute14;
          a21(indx) := t(ddindx).attribute15;
          a22(indx) := t(ddindx).creation_date;
          a23(indx) := rosetta_g_miss_num_map(t(ddindx).created_by);
          a24(indx) := t(ddindx).last_update_date;
          a25(indx) := rosetta_g_miss_num_map(t(ddindx).last_updated_by);
          a26(indx) := rosetta_g_miss_num_map(t(ddindx).last_update_login);
          a27(indx) := t(ddindx).created_by_name;
          a28(indx) := t(ddindx).last_updated_by_name;
          a29(indx) := t(ddindx).config_name;
          a30(indx) := t(ddindx).config_desc;
          a31(indx) := rosetta_g_miss_num_map(t(ddindx).config_flow_id);
          a32(indx) := t(ddindx).config_flow_name;
          a33(indx) := t(ddindx).config_flow_type;
          a34(indx) := t(ddindx).config_record_mode;
          a35(indx) := t(ddindx).config_disp_record_mode;
          a36(indx) := t(ddindx).replayed_date;
          a37(indx) := t(ddindx).replayed_by_name;
          a38(indx) := t(ddindx).replay_status_code;
          a39(indx) := t(ddindx).version_status_code;
          a40(indx) := t(ddindx).replay_status;
          a41(indx) := t(ddindx).version_status;
          a42(indx) := rosetta_g_miss_num_map(t(ddindx).percent_completed);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p4;

  procedure rosetta_table_copy_in_p5(t out jts_config_version_pvt.version_id_tbl_type, a0 JTF_NUMBER_TABLE) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx) := a0(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p5;
  procedure rosetta_table_copy_out_p5(t jts_config_version_pvt.version_id_tbl_type, a0 out JTF_NUMBER_TABLE) as
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
          a0(indx) := t(ddindx);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p5;

  procedure delete_some_versions(p_api_version  NUMBER
    , p_version_tbl JTF_NUMBER_TABLE
  )

  as
    ddp_version_tbl jts_config_version_pvt.version_id_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    jts_config_version_pvt_w.rosetta_table_copy_in_p5(ddp_version_tbl, p_version_tbl);

    -- here's the delegated call to the old PL/SQL routine
    jts_config_version_pvt.delete_some_versions(p_api_version,
      ddp_version_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any

  end;

  procedure get_version(p_api_version  NUMBER
    , p_version_id  NUMBER
    , p2_a0 out  NUMBER
    , p2_a1 out  NUMBER
    , p2_a2 out  VARCHAR2
    , p2_a3 out  NUMBER
    , p2_a4 out  VARCHAR2
    , p2_a5 out  VARCHAR2
    , p2_a6 out  VARCHAR2
    , p2_a7 out  VARCHAR2
    , p2_a8 out  VARCHAR2
    , p2_a9 out  VARCHAR2
    , p2_a10 out  VARCHAR2
    , p2_a11 out  VARCHAR2
    , p2_a12 out  VARCHAR2
    , p2_a13 out  VARCHAR2
    , p2_a14 out  VARCHAR2
    , p2_a15 out  VARCHAR2
    , p2_a16 out  VARCHAR2
    , p2_a17 out  VARCHAR2
    , p2_a18 out  VARCHAR2
    , p2_a19 out  VARCHAR2
    , p2_a20 out  VARCHAR2
    , p2_a21 out  VARCHAR2
    , p2_a22 out  DATE
    , p2_a23 out  NUMBER
    , p2_a24 out  DATE
    , p2_a25 out  NUMBER
    , p2_a26 out  NUMBER
    , p2_a27 out  VARCHAR2
    , p2_a28 out  VARCHAR2
    , p2_a29 out  VARCHAR2
    , p2_a30 out  VARCHAR2
    , p2_a31 out  NUMBER
    , p2_a32 out  VARCHAR2
    , p2_a33 out  VARCHAR2
    , p2_a34 out  VARCHAR2
    , p2_a35 out  VARCHAR2
    , p2_a36 out  DATE
    , p2_a37 out  VARCHAR2
    , p2_a38 out  VARCHAR2
    , p2_a39 out  VARCHAR2
    , p2_a40 out  VARCHAR2
    , p2_a41 out  VARCHAR2
    , p2_a42 out  NUMBER
    , x_return_status out  VARCHAR2
    , x_msg_count out  NUMBER
    , x_msg_data out  VARCHAR2
  )

  as
    ddx_version_rec jts_config_version_pvt.config_version_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any






    -- here's the delegated call to the old PL/SQL routine
    jts_config_version_pvt.get_version(p_api_version,
      p_version_id,
      ddx_version_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any


    p2_a0 := rosetta_g_miss_num_map(ddx_version_rec.configuration_id);
    p2_a1 := rosetta_g_miss_num_map(ddx_version_rec.version_id);
    p2_a2 := ddx_version_rec.version_name;
    p2_a3 := rosetta_g_miss_num_map(ddx_version_rec.version_number);
    p2_a4 := ddx_version_rec.description;
    p2_a5 := ddx_version_rec.queue_name;
    p2_a6 := ddx_version_rec.attribute_category;
    p2_a7 := ddx_version_rec.attribute1;
    p2_a8 := ddx_version_rec.attribute2;
    p2_a9 := ddx_version_rec.attribute3;
    p2_a10 := ddx_version_rec.attribute4;
    p2_a11 := ddx_version_rec.attribute5;
    p2_a12 := ddx_version_rec.attribute6;
    p2_a13 := ddx_version_rec.attribute7;
    p2_a14 := ddx_version_rec.attribute8;
    p2_a15 := ddx_version_rec.attribute9;
    p2_a16 := ddx_version_rec.attribute10;
    p2_a17 := ddx_version_rec.attribute11;
    p2_a18 := ddx_version_rec.attribute12;
    p2_a19 := ddx_version_rec.attribute13;
    p2_a20 := ddx_version_rec.attribute14;
    p2_a21 := ddx_version_rec.attribute15;
    p2_a22 := ddx_version_rec.creation_date;
    p2_a23 := rosetta_g_miss_num_map(ddx_version_rec.created_by);
    p2_a24 := ddx_version_rec.last_update_date;
    p2_a25 := rosetta_g_miss_num_map(ddx_version_rec.last_updated_by);
    p2_a26 := rosetta_g_miss_num_map(ddx_version_rec.last_update_login);
    p2_a27 := ddx_version_rec.created_by_name;
    p2_a28 := ddx_version_rec.last_updated_by_name;
    p2_a29 := ddx_version_rec.config_name;
    p2_a30 := ddx_version_rec.config_desc;
    p2_a31 := rosetta_g_miss_num_map(ddx_version_rec.config_flow_id);
    p2_a32 := ddx_version_rec.config_flow_name;
    p2_a33 := ddx_version_rec.config_flow_type;
    p2_a34 := ddx_version_rec.config_record_mode;
    p2_a35 := ddx_version_rec.config_disp_record_mode;
    p2_a36 := ddx_version_rec.replayed_date;
    p2_a37 := ddx_version_rec.replayed_by_name;
    p2_a38 := ddx_version_rec.replay_status_code;
    p2_a39 := ddx_version_rec.version_status_code;
    p2_a40 := ddx_version_rec.replay_status;
    p2_a41 := ddx_version_rec.version_status;
    p2_a42 := rosetta_g_miss_num_map(ddx_version_rec.percent_completed);



  end;

  procedure get_versions(p_api_version  NUMBER
    , p_config_id  NUMBER
    , p_order_by  VARCHAR2
    , p_how_to_order  VARCHAR2
    , p4_a0 out JTF_NUMBER_TABLE
    , p4_a1 out JTF_NUMBER_TABLE
    , p4_a2 out JTF_VARCHAR2_TABLE_100
    , p4_a3 out JTF_NUMBER_TABLE
    , p4_a4 out JTF_VARCHAR2_TABLE_300
    , p4_a5 out JTF_VARCHAR2_TABLE_100
    , p4_a6 out JTF_VARCHAR2_TABLE_200
    , p4_a7 out JTF_VARCHAR2_TABLE_200
    , p4_a8 out JTF_VARCHAR2_TABLE_200
    , p4_a9 out JTF_VARCHAR2_TABLE_200
    , p4_a10 out JTF_VARCHAR2_TABLE_200
    , p4_a11 out JTF_VARCHAR2_TABLE_200
    , p4_a12 out JTF_VARCHAR2_TABLE_200
    , p4_a13 out JTF_VARCHAR2_TABLE_200
    , p4_a14 out JTF_VARCHAR2_TABLE_200
    , p4_a15 out JTF_VARCHAR2_TABLE_200
    , p4_a16 out JTF_VARCHAR2_TABLE_200
    , p4_a17 out JTF_VARCHAR2_TABLE_200
    , p4_a18 out JTF_VARCHAR2_TABLE_200
    , p4_a19 out JTF_VARCHAR2_TABLE_200
    , p4_a20 out JTF_VARCHAR2_TABLE_200
    , p4_a21 out JTF_VARCHAR2_TABLE_200
    , p4_a22 out JTF_DATE_TABLE
    , p4_a23 out JTF_NUMBER_TABLE
    , p4_a24 out JTF_DATE_TABLE
    , p4_a25 out JTF_NUMBER_TABLE
    , p4_a26 out JTF_NUMBER_TABLE
    , p4_a27 out JTF_VARCHAR2_TABLE_100
    , p4_a28 out JTF_VARCHAR2_TABLE_100
    , p4_a29 out JTF_VARCHAR2_TABLE_100
    , p4_a30 out JTF_VARCHAR2_TABLE_300
    , p4_a31 out JTF_NUMBER_TABLE
    , p4_a32 out JTF_VARCHAR2_TABLE_100
    , p4_a33 out JTF_VARCHAR2_TABLE_100
    , p4_a34 out JTF_VARCHAR2_TABLE_100
    , p4_a35 out JTF_VARCHAR2_TABLE_100
    , p4_a36 out JTF_DATE_TABLE
    , p4_a37 out JTF_VARCHAR2_TABLE_100
    , p4_a38 out JTF_VARCHAR2_TABLE_100
    , p4_a39 out JTF_VARCHAR2_TABLE_100
    , p4_a40 out JTF_VARCHAR2_TABLE_100
    , p4_a41 out JTF_VARCHAR2_TABLE_100
    , p4_a42 out JTF_NUMBER_TABLE
    , x_return_status out  VARCHAR2
    , x_msg_count out  NUMBER
    , x_msg_data out  VARCHAR2
  )

  as
    ddx_version_tbl jts_config_version_pvt.config_version_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any








    -- here's the delegated call to the old PL/SQL routine
    jts_config_version_pvt.get_versions(p_api_version,
      p_config_id,
      p_order_by,
      p_how_to_order,
      ddx_version_tbl,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any




    jts_config_version_pvt_w.rosetta_table_copy_out_p4(ddx_version_tbl, p4_a0
      , p4_a1
      , p4_a2
      , p4_a3
      , p4_a4
      , p4_a5
      , p4_a6
      , p4_a7
      , p4_a8
      , p4_a9
      , p4_a10
      , p4_a11
      , p4_a12
      , p4_a13
      , p4_a14
      , p4_a15
      , p4_a16
      , p4_a17
      , p4_a18
      , p4_a19
      , p4_a20
      , p4_a21
      , p4_a22
      , p4_a23
      , p4_a24
      , p4_a25
      , p4_a26
      , p4_a27
      , p4_a28
      , p4_a29
      , p4_a30
      , p4_a31
      , p4_a32
      , p4_a33
      , p4_a34
      , p4_a35
      , p4_a36
      , p4_a37
      , p4_a38
      , p4_a39
      , p4_a40
      , p4_a41
      , p4_a42
      );



  end;

end jts_config_version_pvt_w;

/
