--------------------------------------------------------
--  DDL for Package Body AMS_PS_CNDCLSES_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_PS_CNDCLSES_PVT_W" as
  /* $Header: amswcclb.pls 120.0 2005/06/01 01:05:48 appldev noship $ */
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

  procedure rosetta_table_copy_in_p3(t OUT NOCOPY ams_ps_cndclses_pvt.ps_cndclses_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_DATE_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_DATE_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_VARCHAR2_TABLE_100
    , a10 JTF_VARCHAR2_TABLE_100
    , a11 JTF_VARCHAR2_TABLE_100
    , a12 JTF_VARCHAR2_TABLE_1000
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).created_by := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a1(indx));
          t(ddindx).last_updated_by := rosetta_g_miss_num_map(a2(indx));
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a3(indx));
          t(ddindx).last_update_login := rosetta_g_miss_num_map(a4(indx));
          t(ddindx).object_version_number := rosetta_g_miss_num_map(a5(indx));
          t(ddindx).cnd_clause_id := rosetta_g_miss_num_map(a6(indx));
          t(ddindx).cnd_clause_datatype := a7(indx);
          t(ddindx).cnd_clause_ref_code := a8(indx);
          t(ddindx).cnd_comp_operator := a9(indx);
          t(ddindx).cnd_default_value := a10(indx);
          t(ddindx).cnd_clause_name := a11(indx);
          t(ddindx).cnd_clause_description := a12(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p3;
  procedure rosetta_table_copy_out_p3(t ams_ps_cndclses_pvt.ps_cndclses_tbl_type, a0 OUT NOCOPY JTF_NUMBER_TABLE
    , a1 OUT NOCOPY JTF_DATE_TABLE
    , a2 OUT NOCOPY JTF_NUMBER_TABLE
    , a3 OUT NOCOPY JTF_DATE_TABLE
    , a4 OUT NOCOPY JTF_NUMBER_TABLE
    , a5 OUT NOCOPY JTF_NUMBER_TABLE
    , a6 OUT NOCOPY JTF_NUMBER_TABLE
    , a7 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a8 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a9 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a10 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a11 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a12 OUT NOCOPY JTF_VARCHAR2_TABLE_1000
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_DATE_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_DATE_TABLE();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_VARCHAR2_TABLE_100();
    a8 := JTF_VARCHAR2_TABLE_100();
    a9 := JTF_VARCHAR2_TABLE_100();
    a10 := JTF_VARCHAR2_TABLE_100();
    a11 := JTF_VARCHAR2_TABLE_100();
    a12 := JTF_VARCHAR2_TABLE_1000();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_DATE_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_DATE_TABLE();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_VARCHAR2_TABLE_100();
      a8 := JTF_VARCHAR2_TABLE_100();
      a9 := JTF_VARCHAR2_TABLE_100();
      a10 := JTF_VARCHAR2_TABLE_100();
      a11 := JTF_VARCHAR2_TABLE_100();
      a12 := JTF_VARCHAR2_TABLE_1000();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).created_by);
          a1(indx) := t(ddindx).creation_date;
          a2(indx) := rosetta_g_miss_num_map(t(ddindx).last_updated_by);
          a3(indx) := t(ddindx).last_update_date;
          a4(indx) := rosetta_g_miss_num_map(t(ddindx).last_update_login);
          a5(indx) := rosetta_g_miss_num_map(t(ddindx).object_version_number);
          a6(indx) := rosetta_g_miss_num_map(t(ddindx).cnd_clause_id);
          a7(indx) := t(ddindx).cnd_clause_datatype;
          a8(indx) := t(ddindx).cnd_clause_ref_code;
          a9(indx) := t(ddindx).cnd_comp_operator;
          a10(indx) := t(ddindx).cnd_default_value;
          a11(indx) := t(ddindx).cnd_clause_name;
          a12(indx) := t(ddindx).cnd_clause_description;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p3;

  procedure create_ps_cndclses(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status OUT NOCOPY  VARCHAR2
    , x_msg_count OUT NOCOPY  NUMBER
    , x_msg_data OUT NOCOPY  VARCHAR2
    , x_cnd_clause_id OUT NOCOPY  NUMBER
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  DATE := fnd_api.g_miss_date
    , p7_a2  NUMBER := 0-1962.0724
    , p7_a3  DATE := fnd_api.g_miss_date
    , p7_a4  NUMBER := 0-1962.0724
    , p7_a5  NUMBER := 0-1962.0724
    , p7_a6  NUMBER := 0-1962.0724
    , p7_a7  VARCHAR2 := fnd_api.g_miss_char
    , p7_a8  VARCHAR2 := fnd_api.g_miss_char
    , p7_a9  VARCHAR2 := fnd_api.g_miss_char
    , p7_a10  VARCHAR2 := fnd_api.g_miss_char
    , p7_a11  VARCHAR2 := fnd_api.g_miss_char
    , p7_a12  VARCHAR2 := fnd_api.g_miss_char
  )
  as
    ddp_ps_cndclses_rec ams_ps_cndclses_pvt.ps_cndclses_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_ps_cndclses_rec.created_by := rosetta_g_miss_num_map(p7_a0);
    ddp_ps_cndclses_rec.creation_date := rosetta_g_miss_date_in_map(p7_a1);
    ddp_ps_cndclses_rec.last_updated_by := rosetta_g_miss_num_map(p7_a2);
    ddp_ps_cndclses_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a3);
    ddp_ps_cndclses_rec.last_update_login := rosetta_g_miss_num_map(p7_a4);
    ddp_ps_cndclses_rec.object_version_number := rosetta_g_miss_num_map(p7_a5);
    ddp_ps_cndclses_rec.cnd_clause_id := rosetta_g_miss_num_map(p7_a6);
    ddp_ps_cndclses_rec.cnd_clause_datatype := p7_a7;
    ddp_ps_cndclses_rec.cnd_clause_ref_code := p7_a8;
    ddp_ps_cndclses_rec.cnd_comp_operator := p7_a9;
    ddp_ps_cndclses_rec.cnd_default_value := p7_a10;
    ddp_ps_cndclses_rec.cnd_clause_name := p7_a11;
    ddp_ps_cndclses_rec.cnd_clause_description := p7_a12;


    -- here's the delegated call to the old PL/SQL routine
    ams_ps_cndclses_pvt.create_ps_cndclses(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_ps_cndclses_rec,
      x_cnd_clause_id);

    -- copy data back from the local OUT or IN-OUT args, if any








  end;

  procedure update_ps_cndclses(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status OUT NOCOPY  VARCHAR2
    , x_msg_count OUT NOCOPY  NUMBER
    , x_msg_data OUT NOCOPY  VARCHAR2
    , x_object_version_number OUT NOCOPY  NUMBER
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  DATE := fnd_api.g_miss_date
    , p7_a2  NUMBER := 0-1962.0724
    , p7_a3  DATE := fnd_api.g_miss_date
    , p7_a4  NUMBER := 0-1962.0724
    , p7_a5  NUMBER := 0-1962.0724
    , p7_a6  NUMBER := 0-1962.0724
    , p7_a7  VARCHAR2 := fnd_api.g_miss_char
    , p7_a8  VARCHAR2 := fnd_api.g_miss_char
    , p7_a9  VARCHAR2 := fnd_api.g_miss_char
    , p7_a10  VARCHAR2 := fnd_api.g_miss_char
    , p7_a11  VARCHAR2 := fnd_api.g_miss_char
    , p7_a12  VARCHAR2 := fnd_api.g_miss_char
  )
  as
    ddp_ps_cndclses_rec ams_ps_cndclses_pvt.ps_cndclses_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_ps_cndclses_rec.created_by := rosetta_g_miss_num_map(p7_a0);
    ddp_ps_cndclses_rec.creation_date := rosetta_g_miss_date_in_map(p7_a1);
    ddp_ps_cndclses_rec.last_updated_by := rosetta_g_miss_num_map(p7_a2);
    ddp_ps_cndclses_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a3);
    ddp_ps_cndclses_rec.last_update_login := rosetta_g_miss_num_map(p7_a4);
    ddp_ps_cndclses_rec.object_version_number := rosetta_g_miss_num_map(p7_a5);
    ddp_ps_cndclses_rec.cnd_clause_id := rosetta_g_miss_num_map(p7_a6);
    ddp_ps_cndclses_rec.cnd_clause_datatype := p7_a7;
    ddp_ps_cndclses_rec.cnd_clause_ref_code := p7_a8;
    ddp_ps_cndclses_rec.cnd_comp_operator := p7_a9;
    ddp_ps_cndclses_rec.cnd_default_value := p7_a10;
    ddp_ps_cndclses_rec.cnd_clause_name := p7_a11;
    ddp_ps_cndclses_rec.cnd_clause_description := p7_a12;


    -- here's the delegated call to the old PL/SQL routine
    ams_ps_cndclses_pvt.update_ps_cndclses(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_ps_cndclses_rec,
      x_object_version_number);

    -- copy data back from the local OUT or IN-OUT args, if any








  end;

  procedure validate_ps_cndclses(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status OUT NOCOPY  VARCHAR2
    , x_msg_count OUT NOCOPY  NUMBER
    , x_msg_data OUT NOCOPY  VARCHAR2
    , p3_a0  NUMBER := 0-1962.0724
    , p3_a1  DATE := fnd_api.g_miss_date
    , p3_a2  NUMBER := 0-1962.0724
    , p3_a3  DATE := fnd_api.g_miss_date
    , p3_a4  NUMBER := 0-1962.0724
    , p3_a5  NUMBER := 0-1962.0724
    , p3_a6  NUMBER := 0-1962.0724
    , p3_a7  VARCHAR2 := fnd_api.g_miss_char
    , p3_a8  VARCHAR2 := fnd_api.g_miss_char
    , p3_a9  VARCHAR2 := fnd_api.g_miss_char
    , p3_a10  VARCHAR2 := fnd_api.g_miss_char
    , p3_a11  VARCHAR2 := fnd_api.g_miss_char
    , p3_a12  VARCHAR2 := fnd_api.g_miss_char
  )
  as
    ddp_ps_cndclses_rec ams_ps_cndclses_pvt.ps_cndclses_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    ddp_ps_cndclses_rec.created_by := rosetta_g_miss_num_map(p3_a0);
    ddp_ps_cndclses_rec.creation_date := rosetta_g_miss_date_in_map(p3_a1);
    ddp_ps_cndclses_rec.last_updated_by := rosetta_g_miss_num_map(p3_a2);
    ddp_ps_cndclses_rec.last_update_date := rosetta_g_miss_date_in_map(p3_a3);
    ddp_ps_cndclses_rec.last_update_login := rosetta_g_miss_num_map(p3_a4);
    ddp_ps_cndclses_rec.object_version_number := rosetta_g_miss_num_map(p3_a5);
    ddp_ps_cndclses_rec.cnd_clause_id := rosetta_g_miss_num_map(p3_a6);
    ddp_ps_cndclses_rec.cnd_clause_datatype := p3_a7;
    ddp_ps_cndclses_rec.cnd_clause_ref_code := p3_a8;
    ddp_ps_cndclses_rec.cnd_comp_operator := p3_a9;
    ddp_ps_cndclses_rec.cnd_default_value := p3_a10;
    ddp_ps_cndclses_rec.cnd_clause_name := p3_a11;
    ddp_ps_cndclses_rec.cnd_clause_description := p3_a12;




    -- here's the delegated call to the old PL/SQL routine
    ams_ps_cndclses_pvt.validate_ps_cndclses(p_api_version_number,
      p_init_msg_list,
      p_validation_level,
      ddp_ps_cndclses_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any






  end;

  procedure check_ps_cndclses_items(p_validation_mode  VARCHAR2
    , x_return_status OUT NOCOPY  VARCHAR2
    , p0_a0  NUMBER := 0-1962.0724
    , p0_a1  DATE := fnd_api.g_miss_date
    , p0_a2  NUMBER := 0-1962.0724
    , p0_a3  DATE := fnd_api.g_miss_date
    , p0_a4  NUMBER := 0-1962.0724
    , p0_a5  NUMBER := 0-1962.0724
    , p0_a6  NUMBER := 0-1962.0724
    , p0_a7  VARCHAR2 := fnd_api.g_miss_char
    , p0_a8  VARCHAR2 := fnd_api.g_miss_char
    , p0_a9  VARCHAR2 := fnd_api.g_miss_char
    , p0_a10  VARCHAR2 := fnd_api.g_miss_char
    , p0_a11  VARCHAR2 := fnd_api.g_miss_char
    , p0_a12  VARCHAR2 := fnd_api.g_miss_char
  )
  as
    ddp_ps_cndclses_rec ams_ps_cndclses_pvt.ps_cndclses_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_ps_cndclses_rec.created_by := rosetta_g_miss_num_map(p0_a0);
    ddp_ps_cndclses_rec.creation_date := rosetta_g_miss_date_in_map(p0_a1);
    ddp_ps_cndclses_rec.last_updated_by := rosetta_g_miss_num_map(p0_a2);
    ddp_ps_cndclses_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a3);
    ddp_ps_cndclses_rec.last_update_login := rosetta_g_miss_num_map(p0_a4);
    ddp_ps_cndclses_rec.object_version_number := rosetta_g_miss_num_map(p0_a5);
    ddp_ps_cndclses_rec.cnd_clause_id := rosetta_g_miss_num_map(p0_a6);
    ddp_ps_cndclses_rec.cnd_clause_datatype := p0_a7;
    ddp_ps_cndclses_rec.cnd_clause_ref_code := p0_a8;
    ddp_ps_cndclses_rec.cnd_comp_operator := p0_a9;
    ddp_ps_cndclses_rec.cnd_default_value := p0_a10;
    ddp_ps_cndclses_rec.cnd_clause_name := p0_a11;
    ddp_ps_cndclses_rec.cnd_clause_description := p0_a12;



    -- here's the delegated call to the old PL/SQL routine
    ams_ps_cndclses_pvt.check_ps_cndclses_items(ddp_ps_cndclses_rec,
      p_validation_mode,
      x_return_status);

    -- copy data back from the local OUT or IN-OUT args, if any


  end;

  procedure validate_ps_cndclses_rec(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status OUT NOCOPY  VARCHAR2
    , x_msg_count OUT NOCOPY  NUMBER
    , x_msg_data OUT NOCOPY  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  DATE := fnd_api.g_miss_date
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  DATE := fnd_api.g_miss_date
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  VARCHAR2 := fnd_api.g_miss_char
    , p5_a10  VARCHAR2 := fnd_api.g_miss_char
    , p5_a11  VARCHAR2 := fnd_api.g_miss_char
    , p5_a12  VARCHAR2 := fnd_api.g_miss_char
  )
  as
    ddp_ps_cndclses_rec ams_ps_cndclses_pvt.ps_cndclses_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_ps_cndclses_rec.created_by := rosetta_g_miss_num_map(p5_a0);
    ddp_ps_cndclses_rec.creation_date := rosetta_g_miss_date_in_map(p5_a1);
    ddp_ps_cndclses_rec.last_updated_by := rosetta_g_miss_num_map(p5_a2);
    ddp_ps_cndclses_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a3);
    ddp_ps_cndclses_rec.last_update_login := rosetta_g_miss_num_map(p5_a4);
    ddp_ps_cndclses_rec.object_version_number := rosetta_g_miss_num_map(p5_a5);
    ddp_ps_cndclses_rec.cnd_clause_id := rosetta_g_miss_num_map(p5_a6);
    ddp_ps_cndclses_rec.cnd_clause_datatype := p5_a7;
    ddp_ps_cndclses_rec.cnd_clause_ref_code := p5_a8;
    ddp_ps_cndclses_rec.cnd_comp_operator := p5_a9;
    ddp_ps_cndclses_rec.cnd_default_value := p5_a10;
    ddp_ps_cndclses_rec.cnd_clause_name := p5_a11;
    ddp_ps_cndclses_rec.cnd_clause_description := p5_a12;

    -- here's the delegated call to the old PL/SQL routine
    ams_ps_cndclses_pvt.validate_ps_cndclses_rec(p_api_version_number,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_ps_cndclses_rec);

    -- copy data back from the local OUT or IN-OUT args, if any





  end;

end ams_ps_cndclses_pvt_w;

/
