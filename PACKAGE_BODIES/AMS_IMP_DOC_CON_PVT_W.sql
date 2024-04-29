--------------------------------------------------------
--  DDL for Package Body AMS_IMP_DOC_CON_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_IMP_DOC_CON_PVT_W" as
  /* $Header: amswidcb.pls 115.3 2002/11/12 23:44:26 jieli noship $ */
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

  procedure rosetta_table_copy_in_p2(t OUT NOCOPY ams_imp_doc_con_pvt.imp_doc_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_DATE_TABLE
    , a6 JTF_DATE_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_VARCHAR2_TABLE_2000
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).imp_doc_content_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).last_updated_by := rosetta_g_miss_num_map(a1(indx));
          t(ddindx).object_version_number := rosetta_g_miss_num_map(a2(indx));
          t(ddindx).created_by := rosetta_g_miss_num_map(a3(indx));
          t(ddindx).last_update_login := rosetta_g_miss_num_map(a4(indx));
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a5(indx));
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a6(indx));
          t(ddindx).import_list_header_id := rosetta_g_miss_num_map(a7(indx));
          t(ddindx).file_id := rosetta_g_miss_num_map(a8(indx));
          t(ddindx).file_name := a9(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p2;
  procedure rosetta_table_copy_out_p2(t ams_imp_doc_con_pvt.imp_doc_tbl_type, a0 OUT NOCOPY JTF_NUMBER_TABLE
    , a1 OUT NOCOPY JTF_NUMBER_TABLE
    , a2 OUT NOCOPY JTF_NUMBER_TABLE
    , a3 OUT NOCOPY JTF_NUMBER_TABLE
    , a4 OUT NOCOPY JTF_NUMBER_TABLE
    , a5 OUT NOCOPY JTF_DATE_TABLE
    , a6 OUT NOCOPY JTF_DATE_TABLE
    , a7 OUT NOCOPY JTF_NUMBER_TABLE
    , a8 OUT NOCOPY JTF_NUMBER_TABLE
    , a9 OUT NOCOPY JTF_VARCHAR2_TABLE_2000
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
    a9 := JTF_VARCHAR2_TABLE_2000();
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
      a9 := JTF_VARCHAR2_TABLE_2000();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).imp_doc_content_id);
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).last_updated_by);
          a2(indx) := rosetta_g_miss_num_map(t(ddindx).object_version_number);
          a3(indx) := rosetta_g_miss_num_map(t(ddindx).created_by);
          a4(indx) := rosetta_g_miss_num_map(t(ddindx).last_update_login);
          a5(indx) := t(ddindx).last_update_date;
          a6(indx) := t(ddindx).creation_date;
          a7(indx) := rosetta_g_miss_num_map(t(ddindx).import_list_header_id);
          a8(indx) := rosetta_g_miss_num_map(t(ddindx).file_id);
          a9(indx) := t(ddindx).file_name;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p2;

  procedure create_imp_doc_content(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status OUT NOCOPY  VARCHAR2
    , x_msg_count OUT NOCOPY  NUMBER
    , x_msg_data OUT NOCOPY  VARCHAR2
    , x_imp_doccontent_id OUT NOCOPY  NUMBER
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  NUMBER := 0-1962.0724
    , p7_a2  NUMBER := 0-1962.0724
    , p7_a3  NUMBER := 0-1962.0724
    , p7_a4  NUMBER := 0-1962.0724
    , p7_a5  DATE := fnd_api.g_miss_date
    , p7_a6  DATE := fnd_api.g_miss_date
    , p7_a7  NUMBER := 0-1962.0724
    , p7_a8  NUMBER := 0-1962.0724
    , p7_a9  VARCHAR2 := fnd_api.g_miss_char
  )
  as
    ddp_imp_doc_rec ams_imp_doc_con_pvt.imp_doccon_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_imp_doc_rec.imp_doc_content_id := rosetta_g_miss_num_map(p7_a0);
    ddp_imp_doc_rec.last_updated_by := rosetta_g_miss_num_map(p7_a1);
    ddp_imp_doc_rec.object_version_number := rosetta_g_miss_num_map(p7_a2);
    ddp_imp_doc_rec.created_by := rosetta_g_miss_num_map(p7_a3);
    ddp_imp_doc_rec.last_update_login := rosetta_g_miss_num_map(p7_a4);
    ddp_imp_doc_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a5);
    ddp_imp_doc_rec.creation_date := rosetta_g_miss_date_in_map(p7_a6);
    ddp_imp_doc_rec.import_list_header_id := rosetta_g_miss_num_map(p7_a7);
    ddp_imp_doc_rec.file_id := rosetta_g_miss_num_map(p7_a8);
    ddp_imp_doc_rec.file_name := p7_a9;


    -- here's the delegated call to the old PL/SQL routine
    ams_imp_doc_con_pvt.create_imp_doc_content(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_imp_doc_rec,
      x_imp_doccontent_id);

    -- copy data back from the local OUT or IN-OUT args, if any








  end;

  procedure update_imp_doc_con(p_api_version_number  NUMBER
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
    , p7_a9  VARCHAR2 := fnd_api.g_miss_char
  )
  as
    ddp_imp_doc_rec ams_imp_doc_con_pvt.imp_doccon_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_imp_doc_rec.imp_doc_content_id := rosetta_g_miss_num_map(p7_a0);
    ddp_imp_doc_rec.last_updated_by := rosetta_g_miss_num_map(p7_a1);
    ddp_imp_doc_rec.object_version_number := rosetta_g_miss_num_map(p7_a2);
    ddp_imp_doc_rec.created_by := rosetta_g_miss_num_map(p7_a3);
    ddp_imp_doc_rec.last_update_login := rosetta_g_miss_num_map(p7_a4);
    ddp_imp_doc_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a5);
    ddp_imp_doc_rec.creation_date := rosetta_g_miss_date_in_map(p7_a6);
    ddp_imp_doc_rec.import_list_header_id := rosetta_g_miss_num_map(p7_a7);
    ddp_imp_doc_rec.file_id := rosetta_g_miss_num_map(p7_a8);
    ddp_imp_doc_rec.file_name := p7_a9;


    -- here's the delegated call to the old PL/SQL routine
    ams_imp_doc_con_pvt.update_imp_doc_con(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_imp_doc_rec,
      x_object_version_number);

    -- copy data back from the local OUT or IN-OUT args, if any








  end;

  procedure validate_imp_doc(p_api_version_number  NUMBER
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
    , p3_a9  VARCHAR2 := fnd_api.g_miss_char
  )
  as
    ddp_imp_doc_rec ams_imp_doc_con_pvt.imp_doccon_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    ddp_imp_doc_rec.imp_doc_content_id := rosetta_g_miss_num_map(p3_a0);
    ddp_imp_doc_rec.last_updated_by := rosetta_g_miss_num_map(p3_a1);
    ddp_imp_doc_rec.object_version_number := rosetta_g_miss_num_map(p3_a2);
    ddp_imp_doc_rec.created_by := rosetta_g_miss_num_map(p3_a3);
    ddp_imp_doc_rec.last_update_login := rosetta_g_miss_num_map(p3_a4);
    ddp_imp_doc_rec.last_update_date := rosetta_g_miss_date_in_map(p3_a5);
    ddp_imp_doc_rec.creation_date := rosetta_g_miss_date_in_map(p3_a6);
    ddp_imp_doc_rec.import_list_header_id := rosetta_g_miss_num_map(p3_a7);
    ddp_imp_doc_rec.file_id := rosetta_g_miss_num_map(p3_a8);
    ddp_imp_doc_rec.file_name := p3_a9;





    -- here's the delegated call to the old PL/SQL routine
    ams_imp_doc_con_pvt.validate_imp_doc(p_api_version_number,
      p_init_msg_list,
      p_validation_level,
      ddp_imp_doc_rec,
      p_validation_mode,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any







  end;

  procedure check_imp_doc_items(p_validation_mode  VARCHAR2
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
    , p0_a9  VARCHAR2 := fnd_api.g_miss_char
  )
  as
    ddp_imp_doc_rec ams_imp_doc_con_pvt.imp_doccon_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_imp_doc_rec.imp_doc_content_id := rosetta_g_miss_num_map(p0_a0);
    ddp_imp_doc_rec.last_updated_by := rosetta_g_miss_num_map(p0_a1);
    ddp_imp_doc_rec.object_version_number := rosetta_g_miss_num_map(p0_a2);
    ddp_imp_doc_rec.created_by := rosetta_g_miss_num_map(p0_a3);
    ddp_imp_doc_rec.last_update_login := rosetta_g_miss_num_map(p0_a4);
    ddp_imp_doc_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a5);
    ddp_imp_doc_rec.creation_date := rosetta_g_miss_date_in_map(p0_a6);
    ddp_imp_doc_rec.import_list_header_id := rosetta_g_miss_num_map(p0_a7);
    ddp_imp_doc_rec.file_id := rosetta_g_miss_num_map(p0_a8);
    ddp_imp_doc_rec.file_name := p0_a9;



    -- here's the delegated call to the old PL/SQL routine
    ams_imp_doc_con_pvt.check_imp_doc_items(ddp_imp_doc_rec,
      p_validation_mode,
      x_return_status);

    -- copy data back from the local OUT or IN-OUT args, if any


  end;

  procedure validate_imp_doc_rec(p_api_version_number  NUMBER
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
    , p5_a9  VARCHAR2 := fnd_api.g_miss_char
  )
  as
    ddp_imp_doc_rec ams_imp_doc_con_pvt.imp_doccon_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_imp_doc_rec.imp_doc_content_id := rosetta_g_miss_num_map(p5_a0);
    ddp_imp_doc_rec.last_updated_by := rosetta_g_miss_num_map(p5_a1);
    ddp_imp_doc_rec.object_version_number := rosetta_g_miss_num_map(p5_a2);
    ddp_imp_doc_rec.created_by := rosetta_g_miss_num_map(p5_a3);
    ddp_imp_doc_rec.last_update_login := rosetta_g_miss_num_map(p5_a4);
    ddp_imp_doc_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a5);
    ddp_imp_doc_rec.creation_date := rosetta_g_miss_date_in_map(p5_a6);
    ddp_imp_doc_rec.import_list_header_id := rosetta_g_miss_num_map(p5_a7);
    ddp_imp_doc_rec.file_id := rosetta_g_miss_num_map(p5_a8);
    ddp_imp_doc_rec.file_name := p5_a9;

    -- here's the delegated call to the old PL/SQL routine
    ams_imp_doc_con_pvt.validate_imp_doc_rec(p_api_version_number,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_imp_doc_rec);

    -- copy data back from the local OUT or IN-OUT args, if any





  end;

end ams_imp_doc_con_pvt_w;

/
