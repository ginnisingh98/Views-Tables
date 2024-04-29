--------------------------------------------------------
--  DDL for Package Body AMS_XML_ELEMENT_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_XML_ELEMENT_PVT_W" as
  /* $Header: amswxelb.pls 115.4 2002/11/14 01:24:11 jieli noship $ */
  rosetta_g_mistake_date date := to_date('01/01/+4713', 'MM/DD/SYYYY');
  rosetta_g_miss_date date := to_date('01/01/-4712', 'MM/DD/SYYYY');
  AMS_DEBUG_HIGH_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
AMS_DEBUG_LOW_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
AMS_DEBUG_MEDIUM_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);


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

procedure rosetta_table_copy_in_p1(t OUT NOCOPY ams_xml_element_pvt.num_data_set_type_w, a0 JTF_NUMBER_TABLE) as
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
  end rosetta_table_copy_in_p1;
  procedure rosetta_table_copy_out_p1(t ams_xml_element_pvt.num_data_set_type_w, a0 OUT NOCOPY JTF_NUMBER_TABLE) as
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
  end rosetta_table_copy_out_p1;

  procedure rosetta_table_copy_in_p2(t OUT NOCOPY ams_xml_element_pvt.varchar2_2000_set_type, a0 JTF_VARCHAR2_TABLE_2000) as
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
  end rosetta_table_copy_in_p2;
  procedure rosetta_table_copy_out_p2(t ams_xml_element_pvt.varchar2_2000_set_type, a0 OUT NOCOPY JTF_VARCHAR2_TABLE_2000) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_2000();
  else
      a0 := JTF_VARCHAR2_TABLE_2000();
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
  end rosetta_table_copy_out_p2;

  procedure rosetta_table_copy_in_p5(t OUT NOCOPY ams_xml_element_pvt.xml_element_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_DATE_TABLE
    , a6 JTF_DATE_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_VARCHAR2_TABLE_2000
    , a11 JTF_VARCHAR2_TABLE_2000
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_VARCHAR2_TABLE_100
    , a14 JTF_VARCHAR2_TABLE_100
    , a15 JTF_VARCHAR2_TABLE_300
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).imp_xml_element_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).last_updated_by := rosetta_g_miss_num_map(a1(indx));
          t(ddindx).object_version_number := rosetta_g_miss_num_map(a2(indx));
          t(ddindx).created_by := rosetta_g_miss_num_map(a3(indx));
          t(ddindx).last_update_login := rosetta_g_miss_num_map(a4(indx));
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a5(indx));
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a6(indx));
          t(ddindx).imp_xml_document_id := rosetta_g_miss_num_map(a7(indx));
          t(ddindx).order_initial := rosetta_g_miss_num_map(a8(indx));
          t(ddindx).order_final := rosetta_g_miss_num_map(a9(indx));
          t(ddindx).column_name := a10(indx);
          t(ddindx).data := a11(indx);
          t(ddindx).num_attr := rosetta_g_miss_num_map(a12(indx));
          t(ddindx).data_type := a13(indx);
          t(ddindx).load_status := a14(indx);
          t(ddindx).error_text := a15(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p5;
  procedure rosetta_table_copy_out_p5(t ams_xml_element_pvt.xml_element_tbl_type, a0 OUT NOCOPY JTF_NUMBER_TABLE
    , a1 OUT NOCOPY JTF_NUMBER_TABLE
    , a2 OUT NOCOPY JTF_NUMBER_TABLE
    , a3 OUT NOCOPY JTF_NUMBER_TABLE
    , a4 OUT NOCOPY JTF_NUMBER_TABLE
    , a5 OUT NOCOPY JTF_DATE_TABLE
    , a6 OUT NOCOPY JTF_DATE_TABLE
    , a7 OUT NOCOPY JTF_NUMBER_TABLE
    , a8 OUT NOCOPY JTF_NUMBER_TABLE
    , a9 OUT NOCOPY JTF_NUMBER_TABLE
    , a10 OUT NOCOPY JTF_VARCHAR2_TABLE_2000
    , a11 OUT NOCOPY JTF_VARCHAR2_TABLE_2000
    , a12 OUT NOCOPY JTF_NUMBER_TABLE
    , a13 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a14 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a15 OUT NOCOPY JTF_VARCHAR2_TABLE_300
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_DATE_TABLE();
    a6 := JTF_DATE_TABLE();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_NUMBER_TABLE();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_VARCHAR2_TABLE_2000();
    a11 := JTF_VARCHAR2_TABLE_2000();
    a12 := JTF_NUMBER_TABLE();
    a13 := JTF_VARCHAR2_TABLE_100();
    a14 := JTF_VARCHAR2_TABLE_100();
    a15 := JTF_VARCHAR2_TABLE_300();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_DATE_TABLE();
      a6 := JTF_DATE_TABLE();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_NUMBER_TABLE();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_VARCHAR2_TABLE_2000();
      a11 := JTF_VARCHAR2_TABLE_2000();
      a12 := JTF_NUMBER_TABLE();
      a13 := JTF_VARCHAR2_TABLE_100();
      a14 := JTF_VARCHAR2_TABLE_100();
      a15 := JTF_VARCHAR2_TABLE_300();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).imp_xml_element_id);
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).last_updated_by);
          a2(indx) := rosetta_g_miss_num_map(t(ddindx).object_version_number);
          a3(indx) := rosetta_g_miss_num_map(t(ddindx).created_by);
          a4(indx) := rosetta_g_miss_num_map(t(ddindx).last_update_login);
          a5(indx) := t(ddindx).last_update_date;
          a6(indx) := t(ddindx).creation_date;
          a7(indx) := rosetta_g_miss_num_map(t(ddindx).imp_xml_document_id);
          a8(indx) := rosetta_g_miss_num_map(t(ddindx).order_initial);
          a9(indx) := rosetta_g_miss_num_map(t(ddindx).order_final);
          a10(indx) := t(ddindx).column_name;
          a11(indx) := t(ddindx).data;
          a12(indx) := rosetta_g_miss_num_map(t(ddindx).num_attr);
          a13(indx) := t(ddindx).data_type;
          a14(indx) := t(ddindx).load_status;
          a15(indx) := t(ddindx).error_text;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p5;

  procedure create_xml_element(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status OUT NOCOPY  VARCHAR2
    , x_msg_count OUT NOCOPY  NUMBER
    , x_msg_data OUT NOCOPY  VARCHAR2
    , x_imp_xml_element_id OUT NOCOPY  NUMBER
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  NUMBER := 0-1962.0724
    , p7_a2  NUMBER := 0-1962.0724
    , p7_a3  NUMBER := 0-1962.0724
    , p7_a4  NUMBER := 0-1962.0724
    , p7_a5  DATE := fnd_api.g_miss_date
    , p7_a6  DATE := fnd_api.g_miss_date
    , p7_a7  NUMBER := 0-1962.0724
    , p7_a8  NUMBER := 0-1962.0724
    , p7_a9  NUMBER := 0-1962.0724
    , p7_a10  VARCHAR2 := fnd_api.g_miss_char
    , p7_a11  VARCHAR2 := fnd_api.g_miss_char
    , p7_a12  NUMBER := 0-1962.0724
    , p7_a13  VARCHAR2 := fnd_api.g_miss_char
    , p7_a14  VARCHAR2 := fnd_api.g_miss_char
    , p7_a15  VARCHAR2 := fnd_api.g_miss_char
  )
  as
    ddp_xml_element_rec ams_xml_element_pvt.xml_element_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_xml_element_rec.imp_xml_element_id := rosetta_g_miss_num_map(p7_a0);
    ddp_xml_element_rec.last_updated_by := rosetta_g_miss_num_map(p7_a1);
    ddp_xml_element_rec.object_version_number := rosetta_g_miss_num_map(p7_a2);
    ddp_xml_element_rec.created_by := rosetta_g_miss_num_map(p7_a3);
    ddp_xml_element_rec.last_update_login := rosetta_g_miss_num_map(p7_a4);
    ddp_xml_element_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a5);
    ddp_xml_element_rec.creation_date := rosetta_g_miss_date_in_map(p7_a6);
    ddp_xml_element_rec.imp_xml_document_id := rosetta_g_miss_num_map(p7_a7);
    ddp_xml_element_rec.order_initial := rosetta_g_miss_num_map(p7_a8);
    ddp_xml_element_rec.order_final := rosetta_g_miss_num_map(p7_a9);
    ddp_xml_element_rec.column_name := p7_a10;
    ddp_xml_element_rec.data := p7_a11;
    ddp_xml_element_rec.num_attr := rosetta_g_miss_num_map(p7_a12);
    ddp_xml_element_rec.data_type := p7_a13;
    ddp_xml_element_rec.load_status := p7_a14;
    ddp_xml_element_rec.error_text := p7_a15;


    -- here's the delegated call to the old PL/SQL routine
    ams_xml_element_pvt.create_xml_element(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_xml_element_rec,
      x_imp_xml_element_id);

    -- copy data back from the local OUT or IN-OUT args, if any








  end;

  procedure update_error_xml_element(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_xml_element_ids JTF_NUMBER_TABLE
    , p_xml_elements_data JTF_VARCHAR2_TABLE_2000
    , p_xml_elements_col_name JTF_VARCHAR2_TABLE_2000
    , x_return_status OUT NOCOPY  VARCHAR2
    , x_msg_count OUT NOCOPY  NUMBER
    , x_msg_data OUT NOCOPY  VARCHAR2
    , x_object_version_number OUT NOCOPY  NUMBER
    , p4_a0  NUMBER := 0-1962.0724
    , p4_a1  NUMBER := 0-1962.0724
    , p4_a2  NUMBER := 0-1962.0724
    , p4_a3  NUMBER := 0-1962.0724
    , p4_a4  NUMBER := 0-1962.0724
    , p4_a5  DATE := fnd_api.g_miss_date
    , p4_a6  DATE := fnd_api.g_miss_date
    , p4_a7  NUMBER := 0-1962.0724
    , p4_a8  NUMBER := 0-1962.0724
    , p4_a9  NUMBER := 0-1962.0724
    , p4_a10  VARCHAR2 := fnd_api.g_miss_char
    , p4_a11  VARCHAR2 := fnd_api.g_miss_char
    , p4_a12  NUMBER := 0-1962.0724
    , p4_a13  VARCHAR2 := fnd_api.g_miss_char
    , p4_a14  VARCHAR2 := fnd_api.g_miss_char
    , p4_a15  VARCHAR2 := fnd_api.g_miss_char
  )
  as
    ddp_xml_element_rec ams_xml_element_pvt.xml_element_rec_type;
    ddp_xml_element_ids ams_xml_element_pvt.num_data_set_type_w;
    ddp_xml_elements_data ams_xml_element_pvt.varchar2_2000_set_type;
    ddp_xml_elements_col_name ams_xml_element_pvt.varchar2_2000_set_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    ddp_xml_element_rec.imp_xml_element_id := rosetta_g_miss_num_map(p4_a0);
    ddp_xml_element_rec.last_updated_by := rosetta_g_miss_num_map(p4_a1);
    ddp_xml_element_rec.object_version_number := rosetta_g_miss_num_map(p4_a2);
    ddp_xml_element_rec.created_by := rosetta_g_miss_num_map(p4_a3);
    ddp_xml_element_rec.last_update_login := rosetta_g_miss_num_map(p4_a4);
    ddp_xml_element_rec.last_update_date := rosetta_g_miss_date_in_map(p4_a5);
    ddp_xml_element_rec.creation_date := rosetta_g_miss_date_in_map(p4_a6);
    ddp_xml_element_rec.imp_xml_document_id := rosetta_g_miss_num_map(p4_a7);
    ddp_xml_element_rec.order_initial := rosetta_g_miss_num_map(p4_a8);
    ddp_xml_element_rec.order_final := rosetta_g_miss_num_map(p4_a9);
    ddp_xml_element_rec.column_name := p4_a10;
    ddp_xml_element_rec.data := p4_a11;
    ddp_xml_element_rec.num_attr := rosetta_g_miss_num_map(p4_a12);
    ddp_xml_element_rec.data_type := p4_a13;
    ddp_xml_element_rec.load_status := p4_a14;
    ddp_xml_element_rec.error_text := p4_a15;

    ams_xml_element_pvt_w.rosetta_table_copy_in_p1(ddp_xml_element_ids, p_xml_element_ids);

    ams_xml_element_pvt_w.rosetta_table_copy_in_p2(ddp_xml_elements_data, p_xml_elements_data);

    ams_xml_element_pvt_w.rosetta_table_copy_in_p2(ddp_xml_elements_col_name, p_xml_elements_col_name);





    -- here's the delegated call to the old PL/SQL routine
    ams_xml_element_pvt.update_error_xml_element(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      ddp_xml_element_rec,
      ddp_xml_element_ids,
      ddp_xml_elements_data,
      ddp_xml_elements_col_name,
      x_return_status,
      x_msg_count,
      x_msg_data,
      x_object_version_number);

    -- copy data back from the local OUT or IN-OUT args, if any











  end;

  procedure update_xml_element(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status OUT NOCOPY  VARCHAR2
    , x_msg_count OUT NOCOPY  NUMBER
    , x_msg_data OUT NOCOPY  VARCHAR2
    , x_object_version_number OUT NOCOPY  NUMBER
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  NUMBER := 0-1962.0724
    , p7_a2  NUMBER := 0-1962.0724
    , p7_a3  NUMBER := 0-1962.0724
    , p7_a4  NUMBER := 0-1962.0724
    , p7_a5  DATE := fnd_api.g_miss_date
    , p7_a6  DATE := fnd_api.g_miss_date
    , p7_a7  NUMBER := 0-1962.0724
    , p7_a8  NUMBER := 0-1962.0724
    , p7_a9  NUMBER := 0-1962.0724
    , p7_a10  VARCHAR2 := fnd_api.g_miss_char
    , p7_a11  VARCHAR2 := fnd_api.g_miss_char
    , p7_a12  NUMBER := 0-1962.0724
    , p7_a13  VARCHAR2 := fnd_api.g_miss_char
    , p7_a14  VARCHAR2 := fnd_api.g_miss_char
    , p7_a15  VARCHAR2 := fnd_api.g_miss_char
  )
  as
    ddp_xml_element_rec ams_xml_element_pvt.xml_element_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_xml_element_rec.imp_xml_element_id := rosetta_g_miss_num_map(p7_a0);
    ddp_xml_element_rec.last_updated_by := rosetta_g_miss_num_map(p7_a1);
    ddp_xml_element_rec.object_version_number := rosetta_g_miss_num_map(p7_a2);
    ddp_xml_element_rec.created_by := rosetta_g_miss_num_map(p7_a3);
    ddp_xml_element_rec.last_update_login := rosetta_g_miss_num_map(p7_a4);
    ddp_xml_element_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a5);
    ddp_xml_element_rec.creation_date := rosetta_g_miss_date_in_map(p7_a6);
    ddp_xml_element_rec.imp_xml_document_id := rosetta_g_miss_num_map(p7_a7);
    ddp_xml_element_rec.order_initial := rosetta_g_miss_num_map(p7_a8);
    ddp_xml_element_rec.order_final := rosetta_g_miss_num_map(p7_a9);
    ddp_xml_element_rec.column_name := p7_a10;
    ddp_xml_element_rec.data := p7_a11;
    ddp_xml_element_rec.num_attr := rosetta_g_miss_num_map(p7_a12);
    ddp_xml_element_rec.data_type := p7_a13;
    ddp_xml_element_rec.load_status := p7_a14;
    ddp_xml_element_rec.error_text := p7_a15;


    -- here's the delegated call to the old PL/SQL routine
    ams_xml_element_pvt.update_xml_element(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_xml_element_rec,
      x_object_version_number);

    -- copy data back from the local OUT or IN-OUT args, if any








  end;

  procedure validate_xml_element(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , p_validation_mode  VARCHAR2
    , x_return_status OUT NOCOPY  VARCHAR2
    , x_msg_count OUT NOCOPY  NUMBER
    , x_msg_data OUT NOCOPY  VARCHAR2
    , p3_a0  NUMBER := 0-1962.0724
    , p3_a1  NUMBER := 0-1962.0724
    , p3_a2  NUMBER := 0-1962.0724
    , p3_a3  NUMBER := 0-1962.0724
    , p3_a4  NUMBER := 0-1962.0724
    , p3_a5  DATE := fnd_api.g_miss_date
    , p3_a6  DATE := fnd_api.g_miss_date
    , p3_a7  NUMBER := 0-1962.0724
    , p3_a8  NUMBER := 0-1962.0724
    , p3_a9  NUMBER := 0-1962.0724
    , p3_a10  VARCHAR2 := fnd_api.g_miss_char
    , p3_a11  VARCHAR2 := fnd_api.g_miss_char
    , p3_a12  NUMBER := 0-1962.0724
    , p3_a13  VARCHAR2 := fnd_api.g_miss_char
    , p3_a14  VARCHAR2 := fnd_api.g_miss_char
    , p3_a15  VARCHAR2 := fnd_api.g_miss_char
  )
  as
    ddp_xml_element_rec ams_xml_element_pvt.xml_element_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    ddp_xml_element_rec.imp_xml_element_id := rosetta_g_miss_num_map(p3_a0);
    ddp_xml_element_rec.last_updated_by := rosetta_g_miss_num_map(p3_a1);
    ddp_xml_element_rec.object_version_number := rosetta_g_miss_num_map(p3_a2);
    ddp_xml_element_rec.created_by := rosetta_g_miss_num_map(p3_a3);
    ddp_xml_element_rec.last_update_login := rosetta_g_miss_num_map(p3_a4);
    ddp_xml_element_rec.last_update_date := rosetta_g_miss_date_in_map(p3_a5);
    ddp_xml_element_rec.creation_date := rosetta_g_miss_date_in_map(p3_a6);
    ddp_xml_element_rec.imp_xml_document_id := rosetta_g_miss_num_map(p3_a7);
    ddp_xml_element_rec.order_initial := rosetta_g_miss_num_map(p3_a8);
    ddp_xml_element_rec.order_final := rosetta_g_miss_num_map(p3_a9);
    ddp_xml_element_rec.column_name := p3_a10;
    ddp_xml_element_rec.data := p3_a11;
    ddp_xml_element_rec.num_attr := rosetta_g_miss_num_map(p3_a12);
    ddp_xml_element_rec.data_type := p3_a13;
    ddp_xml_element_rec.load_status := p3_a14;
    ddp_xml_element_rec.error_text := p3_a15;





    -- here's the delegated call to the old PL/SQL routine
    ams_xml_element_pvt.validate_xml_element(p_api_version_number,
      p_init_msg_list,
      p_validation_level,
      ddp_xml_element_rec,
      p_validation_mode,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any







  end;

  procedure check_xml_element_items(p_validation_mode  VARCHAR2
    , x_return_status OUT NOCOPY  VARCHAR2
    , p0_a0  NUMBER := 0-1962.0724
    , p0_a1  NUMBER := 0-1962.0724
    , p0_a2  NUMBER := 0-1962.0724
    , p0_a3  NUMBER := 0-1962.0724
    , p0_a4  NUMBER := 0-1962.0724
    , p0_a5  DATE := fnd_api.g_miss_date
    , p0_a6  DATE := fnd_api.g_miss_date
    , p0_a7  NUMBER := 0-1962.0724
    , p0_a8  NUMBER := 0-1962.0724
    , p0_a9  NUMBER := 0-1962.0724
    , p0_a10  VARCHAR2 := fnd_api.g_miss_char
    , p0_a11  VARCHAR2 := fnd_api.g_miss_char
    , p0_a12  NUMBER := 0-1962.0724
    , p0_a13  VARCHAR2 := fnd_api.g_miss_char
    , p0_a14  VARCHAR2 := fnd_api.g_miss_char
    , p0_a15  VARCHAR2 := fnd_api.g_miss_char
  )
  as
    ddp_xml_element_rec ams_xml_element_pvt.xml_element_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_xml_element_rec.imp_xml_element_id := rosetta_g_miss_num_map(p0_a0);
    ddp_xml_element_rec.last_updated_by := rosetta_g_miss_num_map(p0_a1);
    ddp_xml_element_rec.object_version_number := rosetta_g_miss_num_map(p0_a2);
    ddp_xml_element_rec.created_by := rosetta_g_miss_num_map(p0_a3);
    ddp_xml_element_rec.last_update_login := rosetta_g_miss_num_map(p0_a4);
    ddp_xml_element_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a5);
    ddp_xml_element_rec.creation_date := rosetta_g_miss_date_in_map(p0_a6);
    ddp_xml_element_rec.imp_xml_document_id := rosetta_g_miss_num_map(p0_a7);
    ddp_xml_element_rec.order_initial := rosetta_g_miss_num_map(p0_a8);
    ddp_xml_element_rec.order_final := rosetta_g_miss_num_map(p0_a9);
    ddp_xml_element_rec.column_name := p0_a10;
    ddp_xml_element_rec.data := p0_a11;
    ddp_xml_element_rec.num_attr := rosetta_g_miss_num_map(p0_a12);
    ddp_xml_element_rec.data_type := p0_a13;
    ddp_xml_element_rec.load_status := p0_a14;
    ddp_xml_element_rec.error_text := p0_a15;



    -- here's the delegated call to the old PL/SQL routine
    ams_xml_element_pvt.check_xml_element_items(ddp_xml_element_rec,
      p_validation_mode,
      x_return_status);

    -- copy data back from the local OUT or IN-OUT args, if any


  end;

  procedure validate_xml_element_rec(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status OUT NOCOPY  VARCHAR2
    , x_msg_count OUT NOCOPY  NUMBER
    , x_msg_data OUT NOCOPY  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  DATE := fnd_api.g_miss_date
    , p5_a6  DATE := fnd_api.g_miss_date
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  VARCHAR2 := fnd_api.g_miss_char
    , p5_a11  VARCHAR2 := fnd_api.g_miss_char
    , p5_a12  NUMBER := 0-1962.0724
    , p5_a13  VARCHAR2 := fnd_api.g_miss_char
    , p5_a14  VARCHAR2 := fnd_api.g_miss_char
    , p5_a15  VARCHAR2 := fnd_api.g_miss_char
  )
  as
    ddp_xml_element_rec ams_xml_element_pvt.xml_element_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_xml_element_rec.imp_xml_element_id := rosetta_g_miss_num_map(p5_a0);
    ddp_xml_element_rec.last_updated_by := rosetta_g_miss_num_map(p5_a1);
    ddp_xml_element_rec.object_version_number := rosetta_g_miss_num_map(p5_a2);
    ddp_xml_element_rec.created_by := rosetta_g_miss_num_map(p5_a3);
    ddp_xml_element_rec.last_update_login := rosetta_g_miss_num_map(p5_a4);
    ddp_xml_element_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a5);
    ddp_xml_element_rec.creation_date := rosetta_g_miss_date_in_map(p5_a6);
    ddp_xml_element_rec.imp_xml_document_id := rosetta_g_miss_num_map(p5_a7);
    ddp_xml_element_rec.order_initial := rosetta_g_miss_num_map(p5_a8);
    ddp_xml_element_rec.order_final := rosetta_g_miss_num_map(p5_a9);
    ddp_xml_element_rec.column_name := p5_a10;
    ddp_xml_element_rec.data := p5_a11;
    ddp_xml_element_rec.num_attr := rosetta_g_miss_num_map(p5_a12);
    ddp_xml_element_rec.data_type := p5_a13;
    ddp_xml_element_rec.load_status := p5_a14;
    ddp_xml_element_rec.error_text := p5_a15;

    -- here's the delegated call to the old PL/SQL routine
    ams_xml_element_pvt.validate_xml_element_rec(p_api_version_number,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_xml_element_rec);

    -- copy data back from the local OUT or IN-OUT args, if any





  end;

end ams_xml_element_pvt_w;

/
