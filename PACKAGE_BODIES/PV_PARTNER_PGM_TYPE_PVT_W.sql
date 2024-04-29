--------------------------------------------------------
--  DDL for Package Body PV_PARTNER_PGM_TYPE_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PV_PARTNER_PGM_TYPE_PVT_W" as
  /* $Header: pvxwpptb.pls 115.2 2002/11/27 22:04:54 ktsao ship $ */
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

  procedure rosetta_table_copy_in_p2(t OUT NOCOPY pv_partner_pgm_type_pvt.ptr_prgm_type_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_DATE_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_DATE_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_VARCHAR2_TABLE_100
    , a10 JTF_VARCHAR2_TABLE_300
    , a11 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).program_type_id := a0(indx);
          t(ddindx).active_flag := a1(indx);
          t(ddindx).enabled_flag := a2(indx);
          t(ddindx).object_version_number := a3(indx);
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a4(indx));
          t(ddindx).created_by := a5(indx);
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a6(indx));
          t(ddindx).last_updated_by := a7(indx);
          t(ddindx).last_update_login := a8(indx);
          t(ddindx).program_type_name := a9(indx);
          t(ddindx).program_type_description := a10(indx);
          t(ddindx).source_lang := a11(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p2;
  procedure rosetta_table_copy_out_p2(t pv_partner_pgm_type_pvt.ptr_prgm_type_tbl_type, a0 OUT NOCOPY JTF_NUMBER_TABLE
    , a1 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a2 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a3 OUT NOCOPY JTF_NUMBER_TABLE
    , a4 OUT NOCOPY JTF_DATE_TABLE
    , a5 OUT NOCOPY JTF_NUMBER_TABLE
    , a6 OUT NOCOPY JTF_DATE_TABLE
    , a7 OUT NOCOPY JTF_NUMBER_TABLE
    , a8 OUT NOCOPY JTF_NUMBER_TABLE
    , a9 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a10 OUT NOCOPY JTF_VARCHAR2_TABLE_300
    , a11 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_DATE_TABLE();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_DATE_TABLE();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_NUMBER_TABLE();
    a9 := JTF_VARCHAR2_TABLE_100();
    a10 := JTF_VARCHAR2_TABLE_300();
    a11 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_DATE_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_DATE_TABLE();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_NUMBER_TABLE();
      a9 := JTF_VARCHAR2_TABLE_100();
      a10 := JTF_VARCHAR2_TABLE_300();
      a11 := JTF_VARCHAR2_TABLE_100();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).program_type_id;
          a1(indx) := t(ddindx).active_flag;
          a2(indx) := t(ddindx).enabled_flag;
          a3(indx) := t(ddindx).object_version_number;
          a4(indx) := t(ddindx).creation_date;
          a5(indx) := t(ddindx).created_by;
          a6(indx) := t(ddindx).last_update_date;
          a7(indx) := t(ddindx).last_updated_by;
          a8(indx) := t(ddindx).last_update_login;
          a9(indx) := t(ddindx).program_type_name;
          a10(indx) := t(ddindx).program_type_description;
          a11(indx) := t(ddindx).source_lang;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p2;

  procedure create_partner_pgm_type(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status OUT NOCOPY  VARCHAR2
    , x_msg_count OUT NOCOPY  NUMBER
    , x_msg_data OUT NOCOPY  VARCHAR2
    , p7_a0  NUMBER
    , p7_a1  VARCHAR2
    , p7_a2  VARCHAR2
    , p7_a3  NUMBER
    , p7_a4  DATE
    , p7_a5  NUMBER
    , p7_a6  DATE
    , p7_a7  NUMBER
    , p7_a8  NUMBER
    , p7_a9  VARCHAR2
    , p7_a10  VARCHAR2
    , p7_a11  VARCHAR2
    , x_program_type_id OUT NOCOPY  NUMBER
  )

  as
    ddp_ptr_prgm_type_rec pv_partner_pgm_type_pvt.ptr_prgm_type_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_ptr_prgm_type_rec.program_type_id := p7_a0;
    ddp_ptr_prgm_type_rec.active_flag := p7_a1;
    ddp_ptr_prgm_type_rec.enabled_flag := p7_a2;
    ddp_ptr_prgm_type_rec.object_version_number := p7_a3;
    ddp_ptr_prgm_type_rec.creation_date := rosetta_g_miss_date_in_map(p7_a4);
    ddp_ptr_prgm_type_rec.created_by := p7_a5;
    ddp_ptr_prgm_type_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a6);
    ddp_ptr_prgm_type_rec.last_updated_by := p7_a7;
    ddp_ptr_prgm_type_rec.last_update_login := p7_a8;
    ddp_ptr_prgm_type_rec.program_type_name := p7_a9;
    ddp_ptr_prgm_type_rec.program_type_description := p7_a10;
    ddp_ptr_prgm_type_rec.source_lang := p7_a11;


    -- here's the delegated call to the old PL/SQL routine
    pv_partner_pgm_type_pvt.create_partner_pgm_type(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_ptr_prgm_type_rec,
      x_program_type_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

  procedure update_partner_pgm_type(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status OUT NOCOPY  VARCHAR2
    , x_msg_count OUT NOCOPY  NUMBER
    , x_msg_data OUT NOCOPY  VARCHAR2
    , p7_a0  NUMBER
    , p7_a1  VARCHAR2
    , p7_a2  VARCHAR2
    , p7_a3  NUMBER
    , p7_a4  DATE
    , p7_a5  NUMBER
    , p7_a6  DATE
    , p7_a7  NUMBER
    , p7_a8  NUMBER
    , p7_a9  VARCHAR2
    , p7_a10  VARCHAR2
    , p7_a11  VARCHAR2
  )

  as
    ddp_ptr_prgm_type_rec pv_partner_pgm_type_pvt.ptr_prgm_type_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_ptr_prgm_type_rec.program_type_id := p7_a0;
    ddp_ptr_prgm_type_rec.active_flag := p7_a1;
    ddp_ptr_prgm_type_rec.enabled_flag := p7_a2;
    ddp_ptr_prgm_type_rec.object_version_number := p7_a3;
    ddp_ptr_prgm_type_rec.creation_date := rosetta_g_miss_date_in_map(p7_a4);
    ddp_ptr_prgm_type_rec.created_by := p7_a5;
    ddp_ptr_prgm_type_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a6);
    ddp_ptr_prgm_type_rec.last_updated_by := p7_a7;
    ddp_ptr_prgm_type_rec.last_update_login := p7_a8;
    ddp_ptr_prgm_type_rec.program_type_name := p7_a9;
    ddp_ptr_prgm_type_rec.program_type_description := p7_a10;
    ddp_ptr_prgm_type_rec.source_lang := p7_a11;

    -- here's the delegated call to the old PL/SQL routine
    pv_partner_pgm_type_pvt.update_partner_pgm_type(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_ptr_prgm_type_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

  procedure validate_partner_pgm_type(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , p3_a0  NUMBER
    , p3_a1  VARCHAR2
    , p3_a2  VARCHAR2
    , p3_a3  NUMBER
    , p3_a4  DATE
    , p3_a5  NUMBER
    , p3_a6  DATE
    , p3_a7  NUMBER
    , p3_a8  NUMBER
    , p3_a9  VARCHAR2
    , p3_a10  VARCHAR2
    , p3_a11  VARCHAR2
    , p_validation_mode  VARCHAR2
    , x_return_status OUT NOCOPY  VARCHAR2
    , x_msg_count OUT NOCOPY  NUMBER
    , x_msg_data OUT NOCOPY  VARCHAR2
  )

  as
    ddp_ptr_prgm_type_rec pv_partner_pgm_type_pvt.ptr_prgm_type_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    ddp_ptr_prgm_type_rec.program_type_id := p3_a0;
    ddp_ptr_prgm_type_rec.active_flag := p3_a1;
    ddp_ptr_prgm_type_rec.enabled_flag := p3_a2;
    ddp_ptr_prgm_type_rec.object_version_number := p3_a3;
    ddp_ptr_prgm_type_rec.creation_date := rosetta_g_miss_date_in_map(p3_a4);
    ddp_ptr_prgm_type_rec.created_by := p3_a5;
    ddp_ptr_prgm_type_rec.last_update_date := rosetta_g_miss_date_in_map(p3_a6);
    ddp_ptr_prgm_type_rec.last_updated_by := p3_a7;
    ddp_ptr_prgm_type_rec.last_update_login := p3_a8;
    ddp_ptr_prgm_type_rec.program_type_name := p3_a9;
    ddp_ptr_prgm_type_rec.program_type_description := p3_a10;
    ddp_ptr_prgm_type_rec.source_lang := p3_a11;





    -- here's the delegated call to the old PL/SQL routine
    pv_partner_pgm_type_pvt.validate_partner_pgm_type(p_api_version_number,
      p_init_msg_list,
      p_validation_level,
      ddp_ptr_prgm_type_rec,
      p_validation_mode,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

  procedure check_items(p0_a0  NUMBER
    , p0_a1  VARCHAR2
    , p0_a2  VARCHAR2
    , p0_a3  NUMBER
    , p0_a4  DATE
    , p0_a5  NUMBER
    , p0_a6  DATE
    , p0_a7  NUMBER
    , p0_a8  NUMBER
    , p0_a9  VARCHAR2
    , p0_a10  VARCHAR2
    , p0_a11  VARCHAR2
    , p_validation_mode  VARCHAR2
    , x_return_status OUT NOCOPY  VARCHAR2
  )

  as
    ddp_ptr_prgm_type_rec pv_partner_pgm_type_pvt.ptr_prgm_type_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_ptr_prgm_type_rec.program_type_id := p0_a0;
    ddp_ptr_prgm_type_rec.active_flag := p0_a1;
    ddp_ptr_prgm_type_rec.enabled_flag := p0_a2;
    ddp_ptr_prgm_type_rec.object_version_number := p0_a3;
    ddp_ptr_prgm_type_rec.creation_date := rosetta_g_miss_date_in_map(p0_a4);
    ddp_ptr_prgm_type_rec.created_by := p0_a5;
    ddp_ptr_prgm_type_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a6);
    ddp_ptr_prgm_type_rec.last_updated_by := p0_a7;
    ddp_ptr_prgm_type_rec.last_update_login := p0_a8;
    ddp_ptr_prgm_type_rec.program_type_name := p0_a9;
    ddp_ptr_prgm_type_rec.program_type_description := p0_a10;
    ddp_ptr_prgm_type_rec.source_lang := p0_a11;



    -- here's the delegated call to the old PL/SQL routine
    pv_partner_pgm_type_pvt.check_items(ddp_ptr_prgm_type_rec,
      p_validation_mode,
      x_return_status);

    -- copy data back from the local variables to OUT or IN-OUT args, if any


  end;

  procedure validate_rec(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status OUT NOCOPY  VARCHAR2
    , x_msg_count OUT NOCOPY  NUMBER
    , x_msg_data OUT NOCOPY  VARCHAR2
    , p5_a0  NUMBER
    , p5_a1  VARCHAR2
    , p5_a2  VARCHAR2
    , p5_a3  NUMBER
    , p5_a4  DATE
    , p5_a5  NUMBER
    , p5_a6  DATE
    , p5_a7  NUMBER
    , p5_a8  NUMBER
    , p5_a9  VARCHAR2
    , p5_a10  VARCHAR2
    , p5_a11  VARCHAR2
    , p_validation_mode  VARCHAR2
  )

  as
    ddp_ptr_prgm_type_rec pv_partner_pgm_type_pvt.ptr_prgm_type_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_ptr_prgm_type_rec.program_type_id := p5_a0;
    ddp_ptr_prgm_type_rec.active_flag := p5_a1;
    ddp_ptr_prgm_type_rec.enabled_flag := p5_a2;
    ddp_ptr_prgm_type_rec.object_version_number := p5_a3;
    ddp_ptr_prgm_type_rec.creation_date := rosetta_g_miss_date_in_map(p5_a4);
    ddp_ptr_prgm_type_rec.created_by := p5_a5;
    ddp_ptr_prgm_type_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a6);
    ddp_ptr_prgm_type_rec.last_updated_by := p5_a7;
    ddp_ptr_prgm_type_rec.last_update_login := p5_a8;
    ddp_ptr_prgm_type_rec.program_type_name := p5_a9;
    ddp_ptr_prgm_type_rec.program_type_description := p5_a10;
    ddp_ptr_prgm_type_rec.source_lang := p5_a11;


    -- here's the delegated call to the old PL/SQL routine
    pv_partner_pgm_type_pvt.validate_rec(p_api_version_number,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_ptr_prgm_type_rec,
      p_validation_mode);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






  end;

  procedure complete_rec(p0_a0  NUMBER
    , p0_a1  VARCHAR2
    , p0_a2  VARCHAR2
    , p0_a3  NUMBER
    , p0_a4  DATE
    , p0_a5  NUMBER
    , p0_a6  DATE
    , p0_a7  NUMBER
    , p0_a8  NUMBER
    , p0_a9  VARCHAR2
    , p0_a10  VARCHAR2
    , p0_a11  VARCHAR2
    , p1_a0 OUT NOCOPY  NUMBER
    , p1_a1 OUT NOCOPY  VARCHAR2
    , p1_a2 OUT NOCOPY  VARCHAR2
    , p1_a3 OUT NOCOPY  NUMBER
    , p1_a4 OUT NOCOPY  DATE
    , p1_a5 OUT NOCOPY  NUMBER
    , p1_a6 OUT NOCOPY  DATE
    , p1_a7 OUT NOCOPY  NUMBER
    , p1_a8 OUT NOCOPY  NUMBER
    , p1_a9 OUT NOCOPY  VARCHAR2
    , p1_a10 OUT NOCOPY  VARCHAR2
    , p1_a11 OUT NOCOPY  VARCHAR2
  )

  as
    ddp_ptr_prgm_type_rec pv_partner_pgm_type_pvt.ptr_prgm_type_rec_type;
    ddx_complete_rec pv_partner_pgm_type_pvt.ptr_prgm_type_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_ptr_prgm_type_rec.program_type_id := p0_a0;
    ddp_ptr_prgm_type_rec.active_flag := p0_a1;
    ddp_ptr_prgm_type_rec.enabled_flag := p0_a2;
    ddp_ptr_prgm_type_rec.object_version_number := p0_a3;
    ddp_ptr_prgm_type_rec.creation_date := rosetta_g_miss_date_in_map(p0_a4);
    ddp_ptr_prgm_type_rec.created_by := p0_a5;
    ddp_ptr_prgm_type_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a6);
    ddp_ptr_prgm_type_rec.last_updated_by := p0_a7;
    ddp_ptr_prgm_type_rec.last_update_login := p0_a8;
    ddp_ptr_prgm_type_rec.program_type_name := p0_a9;
    ddp_ptr_prgm_type_rec.program_type_description := p0_a10;
    ddp_ptr_prgm_type_rec.source_lang := p0_a11;


    -- here's the delegated call to the old PL/SQL routine
    pv_partner_pgm_type_pvt.complete_rec(ddp_ptr_prgm_type_rec,
      ddx_complete_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any

    p1_a0 := ddx_complete_rec.program_type_id;
    p1_a1 := ddx_complete_rec.active_flag;
    p1_a2 := ddx_complete_rec.enabled_flag;
    p1_a3 := ddx_complete_rec.object_version_number;
    p1_a4 := ddx_complete_rec.creation_date;
    p1_a5 := ddx_complete_rec.created_by;
    p1_a6 := ddx_complete_rec.last_update_date;
    p1_a7 := ddx_complete_rec.last_updated_by;
    p1_a8 := ddx_complete_rec.last_update_login;
    p1_a9 := ddx_complete_rec.program_type_name;
    p1_a10 := ddx_complete_rec.program_type_description;
    p1_a11 := ddx_complete_rec.source_lang;
  end;

end pv_partner_pgm_type_pvt_w;

/
