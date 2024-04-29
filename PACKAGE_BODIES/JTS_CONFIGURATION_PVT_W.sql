--------------------------------------------------------
--  DDL for Package Body JTS_CONFIGURATION_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTS_CONFIGURATION_PVT_W" as
  /* $Header: jtswcfgb.pls 115.4 2002/03/22 19:07:52 pkm ship    $ */
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

  procedure rosetta_table_copy_in_p5(t out jts_configuration_pvt.config_rec_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_300
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_VARCHAR2_TABLE_100
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
    , a23 JTF_VARCHAR2_TABLE_200
    , a24 JTF_VARCHAR2_TABLE_200
    , a25 JTF_DATE_TABLE
    , a26 JTF_NUMBER_TABLE
    , a27 JTF_DATE_TABLE
    , a28 JTF_NUMBER_TABLE
    , a29 JTF_NUMBER_TABLE
    , a30 JTF_VARCHAR2_TABLE_100
    , a31 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).configuration_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).config_name := a1(indx);
          t(ddindx).description := a2(indx);
          t(ddindx).flow_id := rosetta_g_miss_num_map(a3(indx));
          t(ddindx).flow_name := a4(indx);
          t(ddindx).flow_type_code := a5(indx);
          t(ddindx).flow_type := a6(indx);
          t(ddindx).record_mode := a7(indx);
          t(ddindx).displayed_record_mode := a8(indx);
          t(ddindx).attribute_category := a9(indx);
          t(ddindx).attribute1 := a10(indx);
          t(ddindx).attribute2 := a11(indx);
          t(ddindx).attribute3 := a12(indx);
          t(ddindx).attribute4 := a13(indx);
          t(ddindx).attribute5 := a14(indx);
          t(ddindx).attribute6 := a15(indx);
          t(ddindx).attribute7 := a16(indx);
          t(ddindx).attribute8 := a17(indx);
          t(ddindx).attribute9 := a18(indx);
          t(ddindx).attribute10 := a19(indx);
          t(ddindx).attribute11 := a20(indx);
          t(ddindx).attribute12 := a21(indx);
          t(ddindx).attribute13 := a22(indx);
          t(ddindx).attribute14 := a23(indx);
          t(ddindx).attribute15 := a24(indx);
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a25(indx));
          t(ddindx).created_by := rosetta_g_miss_num_map(a26(indx));
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a27(indx));
          t(ddindx).last_updated_by := rosetta_g_miss_num_map(a28(indx));
          t(ddindx).last_update_login := rosetta_g_miss_num_map(a29(indx));
          t(ddindx).created_by_name := a30(indx);
          t(ddindx).last_updated_by_name := a31(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p5;
  procedure rosetta_table_copy_out_p5(t jts_configuration_pvt.config_rec_tbl_type, a0 out JTF_NUMBER_TABLE
    , a1 out JTF_VARCHAR2_TABLE_100
    , a2 out JTF_VARCHAR2_TABLE_300
    , a3 out JTF_NUMBER_TABLE
    , a4 out JTF_VARCHAR2_TABLE_100
    , a5 out JTF_VARCHAR2_TABLE_100
    , a6 out JTF_VARCHAR2_TABLE_100
    , a7 out JTF_VARCHAR2_TABLE_100
    , a8 out JTF_VARCHAR2_TABLE_100
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
    , a22 out JTF_VARCHAR2_TABLE_200
    , a23 out JTF_VARCHAR2_TABLE_200
    , a24 out JTF_VARCHAR2_TABLE_200
    , a25 out JTF_DATE_TABLE
    , a26 out JTF_NUMBER_TABLE
    , a27 out JTF_DATE_TABLE
    , a28 out JTF_NUMBER_TABLE
    , a29 out JTF_NUMBER_TABLE
    , a30 out JTF_VARCHAR2_TABLE_100
    , a31 out JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_VARCHAR2_TABLE_300();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_VARCHAR2_TABLE_100();
    a5 := JTF_VARCHAR2_TABLE_100();
    a6 := JTF_VARCHAR2_TABLE_100();
    a7 := JTF_VARCHAR2_TABLE_100();
    a8 := JTF_VARCHAR2_TABLE_100();
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
    a23 := JTF_VARCHAR2_TABLE_200();
    a24 := JTF_VARCHAR2_TABLE_200();
    a25 := JTF_DATE_TABLE();
    a26 := JTF_NUMBER_TABLE();
    a27 := JTF_DATE_TABLE();
    a28 := JTF_NUMBER_TABLE();
    a29 := JTF_NUMBER_TABLE();
    a30 := JTF_VARCHAR2_TABLE_100();
    a31 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_VARCHAR2_TABLE_300();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_VARCHAR2_TABLE_100();
      a5 := JTF_VARCHAR2_TABLE_100();
      a6 := JTF_VARCHAR2_TABLE_100();
      a7 := JTF_VARCHAR2_TABLE_100();
      a8 := JTF_VARCHAR2_TABLE_100();
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
      a23 := JTF_VARCHAR2_TABLE_200();
      a24 := JTF_VARCHAR2_TABLE_200();
      a25 := JTF_DATE_TABLE();
      a26 := JTF_NUMBER_TABLE();
      a27 := JTF_DATE_TABLE();
      a28 := JTF_NUMBER_TABLE();
      a29 := JTF_NUMBER_TABLE();
      a30 := JTF_VARCHAR2_TABLE_100();
      a31 := JTF_VARCHAR2_TABLE_100();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).configuration_id);
          a1(indx) := t(ddindx).config_name;
          a2(indx) := t(ddindx).description;
          a3(indx) := rosetta_g_miss_num_map(t(ddindx).flow_id);
          a4(indx) := t(ddindx).flow_name;
          a5(indx) := t(ddindx).flow_type_code;
          a6(indx) := t(ddindx).flow_type;
          a7(indx) := t(ddindx).record_mode;
          a8(indx) := t(ddindx).displayed_record_mode;
          a9(indx) := t(ddindx).attribute_category;
          a10(indx) := t(ddindx).attribute1;
          a11(indx) := t(ddindx).attribute2;
          a12(indx) := t(ddindx).attribute3;
          a13(indx) := t(ddindx).attribute4;
          a14(indx) := t(ddindx).attribute5;
          a15(indx) := t(ddindx).attribute6;
          a16(indx) := t(ddindx).attribute7;
          a17(indx) := t(ddindx).attribute8;
          a18(indx) := t(ddindx).attribute9;
          a19(indx) := t(ddindx).attribute10;
          a20(indx) := t(ddindx).attribute11;
          a21(indx) := t(ddindx).attribute12;
          a22(indx) := t(ddindx).attribute13;
          a23(indx) := t(ddindx).attribute14;
          a24(indx) := t(ddindx).attribute15;
          a25(indx) := t(ddindx).creation_date;
          a26(indx) := rosetta_g_miss_num_map(t(ddindx).created_by);
          a27(indx) := t(ddindx).last_update_date;
          a28(indx) := rosetta_g_miss_num_map(t(ddindx).last_updated_by);
          a29(indx) := rosetta_g_miss_num_map(t(ddindx).last_update_login);
          a30(indx) := t(ddindx).created_by_name;
          a31(indx) := t(ddindx).last_updated_by_name;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p5;

  procedure create_configuration(p_api_version  NUMBER
    , x_config_id out  NUMBER
    , x_return_status out  VARCHAR2
    , x_msg_count out  NUMBER
    , x_msg_data out  VARCHAR2
    , p1_a0  NUMBER := 0-1962.0724
    , p1_a1  VARCHAR2 := fnd_api.g_miss_char
    , p1_a2  VARCHAR2 := fnd_api.g_miss_char
    , p1_a3  NUMBER := 0-1962.0724
    , p1_a4  VARCHAR2 := fnd_api.g_miss_char
    , p1_a5  VARCHAR2 := fnd_api.g_miss_char
    , p1_a6  VARCHAR2 := fnd_api.g_miss_char
    , p1_a7  VARCHAR2 := fnd_api.g_miss_char
    , p1_a8  VARCHAR2 := fnd_api.g_miss_char
    , p1_a9  VARCHAR2 := fnd_api.g_miss_char
    , p1_a10  VARCHAR2 := fnd_api.g_miss_char
    , p1_a11  VARCHAR2 := fnd_api.g_miss_char
    , p1_a12  VARCHAR2 := fnd_api.g_miss_char
    , p1_a13  VARCHAR2 := fnd_api.g_miss_char
    , p1_a14  VARCHAR2 := fnd_api.g_miss_char
    , p1_a15  VARCHAR2 := fnd_api.g_miss_char
    , p1_a16  VARCHAR2 := fnd_api.g_miss_char
    , p1_a17  VARCHAR2 := fnd_api.g_miss_char
    , p1_a18  VARCHAR2 := fnd_api.g_miss_char
    , p1_a19  VARCHAR2 := fnd_api.g_miss_char
    , p1_a20  VARCHAR2 := fnd_api.g_miss_char
    , p1_a21  VARCHAR2 := fnd_api.g_miss_char
    , p1_a22  VARCHAR2 := fnd_api.g_miss_char
    , p1_a23  VARCHAR2 := fnd_api.g_miss_char
    , p1_a24  VARCHAR2 := fnd_api.g_miss_char
    , p1_a25  DATE := fnd_api.g_miss_date
    , p1_a26  NUMBER := 0-1962.0724
    , p1_a27  DATE := fnd_api.g_miss_date
    , p1_a28  NUMBER := 0-1962.0724
    , p1_a29  NUMBER := 0-1962.0724
    , p1_a30  VARCHAR2 := fnd_api.g_miss_char
    , p1_a31  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_configuration_rec jts_configuration_pvt.config_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    ddp_configuration_rec.configuration_id := rosetta_g_miss_num_map(p1_a0);
    ddp_configuration_rec.config_name := p1_a1;
    ddp_configuration_rec.description := p1_a2;
    ddp_configuration_rec.flow_id := rosetta_g_miss_num_map(p1_a3);
    ddp_configuration_rec.flow_name := p1_a4;
    ddp_configuration_rec.flow_type_code := p1_a5;
    ddp_configuration_rec.flow_type := p1_a6;
    ddp_configuration_rec.record_mode := p1_a7;
    ddp_configuration_rec.displayed_record_mode := p1_a8;
    ddp_configuration_rec.attribute_category := p1_a9;
    ddp_configuration_rec.attribute1 := p1_a10;
    ddp_configuration_rec.attribute2 := p1_a11;
    ddp_configuration_rec.attribute3 := p1_a12;
    ddp_configuration_rec.attribute4 := p1_a13;
    ddp_configuration_rec.attribute5 := p1_a14;
    ddp_configuration_rec.attribute6 := p1_a15;
    ddp_configuration_rec.attribute7 := p1_a16;
    ddp_configuration_rec.attribute8 := p1_a17;
    ddp_configuration_rec.attribute9 := p1_a18;
    ddp_configuration_rec.attribute10 := p1_a19;
    ddp_configuration_rec.attribute11 := p1_a20;
    ddp_configuration_rec.attribute12 := p1_a21;
    ddp_configuration_rec.attribute13 := p1_a22;
    ddp_configuration_rec.attribute14 := p1_a23;
    ddp_configuration_rec.attribute15 := p1_a24;
    ddp_configuration_rec.creation_date := rosetta_g_miss_date_in_map(p1_a25);
    ddp_configuration_rec.created_by := rosetta_g_miss_num_map(p1_a26);
    ddp_configuration_rec.last_update_date := rosetta_g_miss_date_in_map(p1_a27);
    ddp_configuration_rec.last_updated_by := rosetta_g_miss_num_map(p1_a28);
    ddp_configuration_rec.last_update_login := rosetta_g_miss_num_map(p1_a29);
    ddp_configuration_rec.created_by_name := p1_a30;
    ddp_configuration_rec.last_updated_by_name := p1_a31;





    -- here's the delegated call to the old PL/SQL routine
    jts_configuration_pvt.create_configuration(p_api_version,
      ddp_configuration_rec,
      x_config_id,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure get_configuration(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_config_id  NUMBER
    , p3_a0 out  NUMBER
    , p3_a1 out  VARCHAR2
    , p3_a2 out  VARCHAR2
    , p3_a3 out  NUMBER
    , p3_a4 out  VARCHAR2
    , p3_a5 out  VARCHAR2
    , p3_a6 out  VARCHAR2
    , p3_a7 out  VARCHAR2
    , p3_a8 out  VARCHAR2
    , p3_a9 out  VARCHAR2
    , p3_a10 out  VARCHAR2
    , p3_a11 out  VARCHAR2
    , p3_a12 out  VARCHAR2
    , p3_a13 out  VARCHAR2
    , p3_a14 out  VARCHAR2
    , p3_a15 out  VARCHAR2
    , p3_a16 out  VARCHAR2
    , p3_a17 out  VARCHAR2
    , p3_a18 out  VARCHAR2
    , p3_a19 out  VARCHAR2
    , p3_a20 out  VARCHAR2
    , p3_a21 out  VARCHAR2
    , p3_a22 out  VARCHAR2
    , p3_a23 out  VARCHAR2
    , p3_a24 out  VARCHAR2
    , p3_a25 out  DATE
    , p3_a26 out  NUMBER
    , p3_a27 out  DATE
    , p3_a28 out  NUMBER
    , p3_a29 out  NUMBER
    , p3_a30 out  VARCHAR2
    , p3_a31 out  VARCHAR2
    , x_return_status out  VARCHAR2
    , x_msg_count out  NUMBER
    , x_msg_data out  VARCHAR2
  )

  as
    ddx_configuration_rec jts_configuration_pvt.config_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    -- here's the delegated call to the old PL/SQL routine
    jts_configuration_pvt.get_configuration(p_api_version,
      p_init_msg_list,
      p_config_id,
      ddx_configuration_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any



    p3_a0 := rosetta_g_miss_num_map(ddx_configuration_rec.configuration_id);
    p3_a1 := ddx_configuration_rec.config_name;
    p3_a2 := ddx_configuration_rec.description;
    p3_a3 := rosetta_g_miss_num_map(ddx_configuration_rec.flow_id);
    p3_a4 := ddx_configuration_rec.flow_name;
    p3_a5 := ddx_configuration_rec.flow_type_code;
    p3_a6 := ddx_configuration_rec.flow_type;
    p3_a7 := ddx_configuration_rec.record_mode;
    p3_a8 := ddx_configuration_rec.displayed_record_mode;
    p3_a9 := ddx_configuration_rec.attribute_category;
    p3_a10 := ddx_configuration_rec.attribute1;
    p3_a11 := ddx_configuration_rec.attribute2;
    p3_a12 := ddx_configuration_rec.attribute3;
    p3_a13 := ddx_configuration_rec.attribute4;
    p3_a14 := ddx_configuration_rec.attribute5;
    p3_a15 := ddx_configuration_rec.attribute6;
    p3_a16 := ddx_configuration_rec.attribute7;
    p3_a17 := ddx_configuration_rec.attribute8;
    p3_a18 := ddx_configuration_rec.attribute9;
    p3_a19 := ddx_configuration_rec.attribute10;
    p3_a20 := ddx_configuration_rec.attribute11;
    p3_a21 := ddx_configuration_rec.attribute12;
    p3_a22 := ddx_configuration_rec.attribute13;
    p3_a23 := ddx_configuration_rec.attribute14;
    p3_a24 := ddx_configuration_rec.attribute15;
    p3_a25 := ddx_configuration_rec.creation_date;
    p3_a26 := rosetta_g_miss_num_map(ddx_configuration_rec.created_by);
    p3_a27 := ddx_configuration_rec.last_update_date;
    p3_a28 := rosetta_g_miss_num_map(ddx_configuration_rec.last_updated_by);
    p3_a29 := rosetta_g_miss_num_map(ddx_configuration_rec.last_update_login);
    p3_a30 := ddx_configuration_rec.created_by_name;
    p3_a31 := ddx_configuration_rec.last_updated_by_name;



  end;

  procedure get_configurations(p_api_version  NUMBER
    , p_where_clause  VARCHAR2
    , p_order_by  VARCHAR2
    , p_how_to_order  VARCHAR2
    , p4_a0 out JTF_NUMBER_TABLE
    , p4_a1 out JTF_VARCHAR2_TABLE_100
    , p4_a2 out JTF_VARCHAR2_TABLE_300
    , p4_a3 out JTF_NUMBER_TABLE
    , p4_a4 out JTF_VARCHAR2_TABLE_100
    , p4_a5 out JTF_VARCHAR2_TABLE_100
    , p4_a6 out JTF_VARCHAR2_TABLE_100
    , p4_a7 out JTF_VARCHAR2_TABLE_100
    , p4_a8 out JTF_VARCHAR2_TABLE_100
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
    , p4_a22 out JTF_VARCHAR2_TABLE_200
    , p4_a23 out JTF_VARCHAR2_TABLE_200
    , p4_a24 out JTF_VARCHAR2_TABLE_200
    , p4_a25 out JTF_DATE_TABLE
    , p4_a26 out JTF_NUMBER_TABLE
    , p4_a27 out JTF_DATE_TABLE
    , p4_a28 out JTF_NUMBER_TABLE
    , p4_a29 out JTF_NUMBER_TABLE
    , p4_a30 out JTF_VARCHAR2_TABLE_100
    , p4_a31 out JTF_VARCHAR2_TABLE_100
    , x_return_status out  VARCHAR2
    , x_msg_count out  NUMBER
    , x_msg_data out  VARCHAR2
  )

  as
    ddx_configuration_tbl jts_configuration_pvt.config_rec_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any








    -- here's the delegated call to the old PL/SQL routine
    jts_configuration_pvt.get_configurations(p_api_version,
      p_where_clause,
      p_order_by,
      p_how_to_order,
      ddx_configuration_tbl,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any




    jts_configuration_pvt_w.rosetta_table_copy_out_p5(ddx_configuration_tbl, p4_a0
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
      );



  end;

end jts_configuration_pvt_w;

/
