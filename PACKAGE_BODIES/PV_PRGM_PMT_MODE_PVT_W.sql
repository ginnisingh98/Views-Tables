--------------------------------------------------------
--  DDL for Package Body PV_PRGM_PMT_MODE_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PV_PRGM_PMT_MODE_PVT_W" as
  /* $Header: pvxwppmb.pls 120.0 2005/05/27 16:03:16 appldev noship $ */
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

  procedure rosetta_table_copy_in_p2(t OUT NOCOPY pv_prgm_pmt_mode_pvt.prgm_pmt_mode_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_DATE_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_DATE_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).program_payment_mode_id := a0(indx);
          t(ddindx).program_id := a1(indx);
          t(ddindx).geo_hierarchy_id := a2(indx);
          t(ddindx).mode_of_payment := a3(indx);
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a4(indx));
          t(ddindx).last_updated_by := a5(indx);
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a6(indx));
          t(ddindx).created_by := a7(indx);
          t(ddindx).last_update_login := a8(indx);
          t(ddindx).object_version_number := a9(indx);
          t(ddindx).mode_type := a10(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p2;
  procedure rosetta_table_copy_out_p2(t pv_prgm_pmt_mode_pvt.prgm_pmt_mode_tbl_type, a0 OUT NOCOPY JTF_NUMBER_TABLE
    , a1 OUT NOCOPY JTF_NUMBER_TABLE
    , a2 OUT NOCOPY JTF_NUMBER_TABLE
    , a3 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    , a4 OUT NOCOPY JTF_DATE_TABLE
    , a5 OUT NOCOPY JTF_NUMBER_TABLE
    , a6 OUT NOCOPY JTF_DATE_TABLE
    , a7 OUT NOCOPY JTF_NUMBER_TABLE
    , a8 OUT NOCOPY JTF_NUMBER_TABLE
    , a9 OUT NOCOPY JTF_NUMBER_TABLE
    , a10 OUT NOCOPY JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_VARCHAR2_TABLE_100();
    a4 := JTF_DATE_TABLE();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_DATE_TABLE();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_NUMBER_TABLE();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_DATE_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_DATE_TABLE();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_NUMBER_TABLE();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_VARCHAR2_TABLE_100();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).program_payment_mode_id;
          a1(indx) := t(ddindx).program_id;
          a2(indx) := t(ddindx).geo_hierarchy_id;
          a3(indx) := t(ddindx).mode_of_payment;
          a4(indx) := t(ddindx).last_update_date;
          a5(indx) := t(ddindx).last_updated_by;
          a6(indx) := t(ddindx).creation_date;
          a7(indx) := t(ddindx).created_by;
          a8(indx) := t(ddindx).last_update_login;
          a9(indx) := t(ddindx).object_version_number;
          a10(indx) := t(ddindx).mode_type;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p2;

  procedure create_prgm_pmt_mode(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status OUT NOCOPY  VARCHAR2
    , x_msg_count OUT NOCOPY  NUMBER
    , x_msg_data OUT NOCOPY  VARCHAR2
    , p7_a0  NUMBER
    , p7_a1  NUMBER
    , p7_a2  NUMBER
    , p7_a3  VARCHAR2
    , p7_a4  DATE
    , p7_a5  NUMBER
    , p7_a6  DATE
    , p7_a7  NUMBER
    , p7_a8  NUMBER
    , p7_a9  NUMBER
    , p7_a10  VARCHAR2
    , x_program_payment_mode_id OUT NOCOPY  NUMBER
  )

  as
    ddp_prgm_pmt_mode_rec pv_prgm_pmt_mode_pvt.prgm_pmt_mode_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_prgm_pmt_mode_rec.program_payment_mode_id := p7_a0;
    ddp_prgm_pmt_mode_rec.program_id := p7_a1;
    ddp_prgm_pmt_mode_rec.geo_hierarchy_id := p7_a2;
    ddp_prgm_pmt_mode_rec.mode_of_payment := p7_a3;
    ddp_prgm_pmt_mode_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a4);
    ddp_prgm_pmt_mode_rec.last_updated_by := p7_a5;
    ddp_prgm_pmt_mode_rec.creation_date := rosetta_g_miss_date_in_map(p7_a6);
    ddp_prgm_pmt_mode_rec.created_by := p7_a7;
    ddp_prgm_pmt_mode_rec.last_update_login := p7_a8;
    ddp_prgm_pmt_mode_rec.object_version_number := p7_a9;
    ddp_prgm_pmt_mode_rec.mode_type := p7_a10;


    -- here's the delegated call to the old PL/SQL routine
    pv_prgm_pmt_mode_pvt.create_prgm_pmt_mode(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_prgm_pmt_mode_rec,
      x_program_payment_mode_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

  procedure update_prgm_pmt_mode(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status OUT NOCOPY  VARCHAR2
    , x_msg_count OUT NOCOPY  NUMBER
    , x_msg_data OUT NOCOPY  VARCHAR2
    , p7_a0  NUMBER
    , p7_a1  NUMBER
    , p7_a2  NUMBER
    , p7_a3  VARCHAR2
    , p7_a4  DATE
    , p7_a5  NUMBER
    , p7_a6  DATE
    , p7_a7  NUMBER
    , p7_a8  NUMBER
    , p7_a9  NUMBER
    , p7_a10  VARCHAR2
  )

  as
    ddp_prgm_pmt_mode_rec pv_prgm_pmt_mode_pvt.prgm_pmt_mode_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_prgm_pmt_mode_rec.program_payment_mode_id := p7_a0;
    ddp_prgm_pmt_mode_rec.program_id := p7_a1;
    ddp_prgm_pmt_mode_rec.geo_hierarchy_id := p7_a2;
    ddp_prgm_pmt_mode_rec.mode_of_payment := p7_a3;
    ddp_prgm_pmt_mode_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a4);
    ddp_prgm_pmt_mode_rec.last_updated_by := p7_a5;
    ddp_prgm_pmt_mode_rec.creation_date := rosetta_g_miss_date_in_map(p7_a6);
    ddp_prgm_pmt_mode_rec.created_by := p7_a7;
    ddp_prgm_pmt_mode_rec.last_update_login := p7_a8;
    ddp_prgm_pmt_mode_rec.object_version_number := p7_a9;
    ddp_prgm_pmt_mode_rec.mode_type := p7_a10;

    -- here's the delegated call to the old PL/SQL routine
    pv_prgm_pmt_mode_pvt.update_prgm_pmt_mode(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_prgm_pmt_mode_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

  procedure validate_prgm_pmt_mode(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , p3_a0  NUMBER
    , p3_a1  NUMBER
    , p3_a2  NUMBER
    , p3_a3  VARCHAR2
    , p3_a4  DATE
    , p3_a5  NUMBER
    , p3_a6  DATE
    , p3_a7  NUMBER
    , p3_a8  NUMBER
    , p3_a9  NUMBER
    , p3_a10  VARCHAR2
    , p_validation_mode  VARCHAR2
    , x_return_status OUT NOCOPY  VARCHAR2
    , x_msg_count OUT NOCOPY  NUMBER
    , x_msg_data OUT NOCOPY  VARCHAR2
  )

  as
    ddp_prgm_pmt_mode_rec pv_prgm_pmt_mode_pvt.prgm_pmt_mode_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    ddp_prgm_pmt_mode_rec.program_payment_mode_id := p3_a0;
    ddp_prgm_pmt_mode_rec.program_id := p3_a1;
    ddp_prgm_pmt_mode_rec.geo_hierarchy_id := p3_a2;
    ddp_prgm_pmt_mode_rec.mode_of_payment := p3_a3;
    ddp_prgm_pmt_mode_rec.last_update_date := rosetta_g_miss_date_in_map(p3_a4);
    ddp_prgm_pmt_mode_rec.last_updated_by := p3_a5;
    ddp_prgm_pmt_mode_rec.creation_date := rosetta_g_miss_date_in_map(p3_a6);
    ddp_prgm_pmt_mode_rec.created_by := p3_a7;
    ddp_prgm_pmt_mode_rec.last_update_login := p3_a8;
    ddp_prgm_pmt_mode_rec.object_version_number := p3_a9;
    ddp_prgm_pmt_mode_rec.mode_type := p3_a10;





    -- here's the delegated call to the old PL/SQL routine
    pv_prgm_pmt_mode_pvt.validate_prgm_pmt_mode(p_api_version_number,
      p_init_msg_list,
      p_validation_level,
      ddp_prgm_pmt_mode_rec,
      p_validation_mode,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

  procedure check_items(p0_a0  NUMBER
    , p0_a1  NUMBER
    , p0_a2  NUMBER
    , p0_a3  VARCHAR2
    , p0_a4  DATE
    , p0_a5  NUMBER
    , p0_a6  DATE
    , p0_a7  NUMBER
    , p0_a8  NUMBER
    , p0_a9  NUMBER
    , p0_a10  VARCHAR2
    , p_validation_mode  VARCHAR2
    , x_return_status OUT NOCOPY  VARCHAR2
  )

  as
    ddp_prgm_pmt_mode_rec pv_prgm_pmt_mode_pvt.prgm_pmt_mode_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_prgm_pmt_mode_rec.program_payment_mode_id := p0_a0;
    ddp_prgm_pmt_mode_rec.program_id := p0_a1;
    ddp_prgm_pmt_mode_rec.geo_hierarchy_id := p0_a2;
    ddp_prgm_pmt_mode_rec.mode_of_payment := p0_a3;
    ddp_prgm_pmt_mode_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a4);
    ddp_prgm_pmt_mode_rec.last_updated_by := p0_a5;
    ddp_prgm_pmt_mode_rec.creation_date := rosetta_g_miss_date_in_map(p0_a6);
    ddp_prgm_pmt_mode_rec.created_by := p0_a7;
    ddp_prgm_pmt_mode_rec.last_update_login := p0_a8;
    ddp_prgm_pmt_mode_rec.object_version_number := p0_a9;
    ddp_prgm_pmt_mode_rec.mode_type := p0_a10;



    -- here's the delegated call to the old PL/SQL routine
    pv_prgm_pmt_mode_pvt.check_items(ddp_prgm_pmt_mode_rec,
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
    , p5_a1  NUMBER
    , p5_a2  NUMBER
    , p5_a3  VARCHAR2
    , p5_a4  DATE
    , p5_a5  NUMBER
    , p5_a6  DATE
    , p5_a7  NUMBER
    , p5_a8  NUMBER
    , p5_a9  NUMBER
    , p5_a10  VARCHAR2
    , p_validation_mode  VARCHAR2
  )

  as
    ddp_prgm_pmt_mode_rec pv_prgm_pmt_mode_pvt.prgm_pmt_mode_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_prgm_pmt_mode_rec.program_payment_mode_id := p5_a0;
    ddp_prgm_pmt_mode_rec.program_id := p5_a1;
    ddp_prgm_pmt_mode_rec.geo_hierarchy_id := p5_a2;
    ddp_prgm_pmt_mode_rec.mode_of_payment := p5_a3;
    ddp_prgm_pmt_mode_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a4);
    ddp_prgm_pmt_mode_rec.last_updated_by := p5_a5;
    ddp_prgm_pmt_mode_rec.creation_date := rosetta_g_miss_date_in_map(p5_a6);
    ddp_prgm_pmt_mode_rec.created_by := p5_a7;
    ddp_prgm_pmt_mode_rec.last_update_login := p5_a8;
    ddp_prgm_pmt_mode_rec.object_version_number := p5_a9;
    ddp_prgm_pmt_mode_rec.mode_type := p5_a10;


    -- here's the delegated call to the old PL/SQL routine
    pv_prgm_pmt_mode_pvt.validate_rec(p_api_version_number,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_prgm_pmt_mode_rec,
      p_validation_mode);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






  end;

  procedure complete_rec(p0_a0  NUMBER
    , p0_a1  NUMBER
    , p0_a2  NUMBER
    , p0_a3  VARCHAR2
    , p0_a4  DATE
    , p0_a5  NUMBER
    , p0_a6  DATE
    , p0_a7  NUMBER
    , p0_a8  NUMBER
    , p0_a9  NUMBER
    , p0_a10  VARCHAR2
    , p1_a0 OUT NOCOPY  NUMBER
    , p1_a1 OUT NOCOPY  NUMBER
    , p1_a2 OUT NOCOPY  NUMBER
    , p1_a3 OUT NOCOPY  VARCHAR2
    , p1_a4 OUT NOCOPY  DATE
    , p1_a5 OUT NOCOPY  NUMBER
    , p1_a6 OUT NOCOPY  DATE
    , p1_a7 OUT NOCOPY  NUMBER
    , p1_a8 OUT NOCOPY  NUMBER
    , p1_a9 OUT NOCOPY  NUMBER
    , p1_a10 OUT NOCOPY  VARCHAR2
  )

  as
    ddp_prgm_pmt_mode_rec pv_prgm_pmt_mode_pvt.prgm_pmt_mode_rec_type;
    ddx_complete_rec pv_prgm_pmt_mode_pvt.prgm_pmt_mode_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_prgm_pmt_mode_rec.program_payment_mode_id := p0_a0;
    ddp_prgm_pmt_mode_rec.program_id := p0_a1;
    ddp_prgm_pmt_mode_rec.geo_hierarchy_id := p0_a2;
    ddp_prgm_pmt_mode_rec.mode_of_payment := p0_a3;
    ddp_prgm_pmt_mode_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a4);
    ddp_prgm_pmt_mode_rec.last_updated_by := p0_a5;
    ddp_prgm_pmt_mode_rec.creation_date := rosetta_g_miss_date_in_map(p0_a6);
    ddp_prgm_pmt_mode_rec.created_by := p0_a7;
    ddp_prgm_pmt_mode_rec.last_update_login := p0_a8;
    ddp_prgm_pmt_mode_rec.object_version_number := p0_a9;
    ddp_prgm_pmt_mode_rec.mode_type := p0_a10;


    -- here's the delegated call to the old PL/SQL routine
    pv_prgm_pmt_mode_pvt.complete_rec(ddp_prgm_pmt_mode_rec,
      ddx_complete_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any

    p1_a0 := ddx_complete_rec.program_payment_mode_id;
    p1_a1 := ddx_complete_rec.program_id;
    p1_a2 := ddx_complete_rec.geo_hierarchy_id;
    p1_a3 := ddx_complete_rec.mode_of_payment;
    p1_a4 := ddx_complete_rec.last_update_date;
    p1_a5 := ddx_complete_rec.last_updated_by;
    p1_a6 := ddx_complete_rec.creation_date;
    p1_a7 := ddx_complete_rec.created_by;
    p1_a8 := ddx_complete_rec.last_update_login;
    p1_a9 := ddx_complete_rec.object_version_number;
    p1_a10 := ddx_complete_rec.mode_type;
  end;

end pv_prgm_pmt_mode_pvt_w;

/
