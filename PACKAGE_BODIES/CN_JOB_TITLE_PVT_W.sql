--------------------------------------------------------
--  DDL for Package Body CN_JOB_TITLE_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_JOB_TITLE_PVT_W" as
  /* $Header: cnwjobb.pls 115.5 2002/11/25 22:24:21 nkodkani ship $ */
  rosetta_g_mistake_date date := to_date('01/01/+4713', 'MM/DD/SYYYY');
  rosetta_g_miss_date date := to_date('01/01/-4712', 'MM/DD/SYYYY');

  -- this is to workaround the JDBC bug regarding IN DATE of value GMiss
  function rosetta_g_miss_date_in_map(d date) return date as
  begin
    if d = rosetta_g_mistake_date then return fnd_api.g_miss_date; end if;
    return d;
  end;

  procedure rosetta_table_copy_in_p1(t out nocopy cn_job_title_pvt.job_title_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_300
    , a2 JTF_VARCHAR2_TABLE_300
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).job_title_id := a0(indx);
          t(ddindx).name := a1(indx);
          t(ddindx).job_code := a2(indx);
          t(ddindx).role_id := a3(indx);
          t(ddindx).role_name := a4(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p1;
  procedure rosetta_table_copy_out_p1(t cn_job_title_pvt.job_title_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_300
    , a2 out nocopy JTF_VARCHAR2_TABLE_300
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_300();
    a2 := JTF_VARCHAR2_TABLE_300();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_300();
      a2 := JTF_VARCHAR2_TABLE_300();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_VARCHAR2_TABLE_100();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        a3.extend(t.count);
        a4.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).job_title_id;
          a1(indx) := t(ddindx).name;
          a2(indx) := t(ddindx).job_code;
          a3(indx) := t(ddindx).role_id;
          a4(indx) := t(ddindx).role_name;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p1;

  procedure rosetta_table_copy_in_p3(t out nocopy cn_job_title_pvt.job_role_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_DATE_TABLE
    , a4 JTF_DATE_TABLE
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_VARCHAR2_TABLE_100
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
    , a22 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).job_role_id := a0(indx);
          t(ddindx).job_title_id := a1(indx);
          t(ddindx).role_id := a2(indx);
          t(ddindx).start_date := rosetta_g_miss_date_in_map(a3(indx));
          t(ddindx).end_date := rosetta_g_miss_date_in_map(a4(indx));
          t(ddindx).default_flag := a5(indx);
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
          t(ddindx).object_version_number := a22(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p3;
  procedure rosetta_table_copy_out_p3(t cn_job_title_pvt.job_role_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_DATE_TABLE
    , a4 out nocopy JTF_DATE_TABLE
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
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
    , a22 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_DATE_TABLE();
    a4 := JTF_DATE_TABLE();
    a5 := JTF_VARCHAR2_TABLE_100();
    a6 := JTF_VARCHAR2_TABLE_100();
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
    a22 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_DATE_TABLE();
      a4 := JTF_DATE_TABLE();
      a5 := JTF_VARCHAR2_TABLE_100();
      a6 := JTF_VARCHAR2_TABLE_100();
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
      a22 := JTF_NUMBER_TABLE();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).job_role_id;
          a1(indx) := t(ddindx).job_title_id;
          a2(indx) := t(ddindx).role_id;
          a3(indx) := t(ddindx).start_date;
          a4(indx) := t(ddindx).end_date;
          a5(indx) := t(ddindx).default_flag;
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
          a22(indx) := t(ddindx).object_version_number;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p3;

  procedure create_job_role(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p4_a0  NUMBER
    , p4_a1  NUMBER
    , p4_a2  NUMBER
    , p4_a3  DATE
    , p4_a4  DATE
    , p4_a5  VARCHAR2
    , p4_a6  VARCHAR2
    , p4_a7  VARCHAR2
    , p4_a8  VARCHAR2
    , p4_a9  VARCHAR2
    , p4_a10  VARCHAR2
    , p4_a11  VARCHAR2
    , p4_a12  VARCHAR2
    , p4_a13  VARCHAR2
    , p4_a14  VARCHAR2
    , p4_a15  VARCHAR2
    , p4_a16  VARCHAR2
    , p4_a17  VARCHAR2
    , p4_a18  VARCHAR2
    , p4_a19  VARCHAR2
    , p4_a20  VARCHAR2
    , p4_a21  VARCHAR2
    , p4_a22  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_job_role_id out nocopy  NUMBER
  )

  as
    ddp_rec cn_job_title_pvt.job_role_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    ddp_rec.job_role_id := p4_a0;
    ddp_rec.job_title_id := p4_a1;
    ddp_rec.role_id := p4_a2;
    ddp_rec.start_date := rosetta_g_miss_date_in_map(p4_a3);
    ddp_rec.end_date := rosetta_g_miss_date_in_map(p4_a4);
    ddp_rec.default_flag := p4_a5;
    ddp_rec.attribute_category := p4_a6;
    ddp_rec.attribute1 := p4_a7;
    ddp_rec.attribute2 := p4_a8;
    ddp_rec.attribute3 := p4_a9;
    ddp_rec.attribute4 := p4_a10;
    ddp_rec.attribute5 := p4_a11;
    ddp_rec.attribute6 := p4_a12;
    ddp_rec.attribute7 := p4_a13;
    ddp_rec.attribute8 := p4_a14;
    ddp_rec.attribute9 := p4_a15;
    ddp_rec.attribute10 := p4_a16;
    ddp_rec.attribute11 := p4_a17;
    ddp_rec.attribute12 := p4_a18;
    ddp_rec.attribute13 := p4_a19;
    ddp_rec.attribute14 := p4_a20;
    ddp_rec.attribute15 := p4_a21;
    ddp_rec.object_version_number := p4_a22;





    -- here's the delegated call to the old PL/SQL routine
    cn_job_title_pvt.create_job_role(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      ddp_rec,
      x_return_status,
      x_msg_count,
      x_msg_data,
      x_job_role_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

  procedure update_job_role(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p4_a0  NUMBER
    , p4_a1  NUMBER
    , p4_a2  NUMBER
    , p4_a3  DATE
    , p4_a4  DATE
    , p4_a5  VARCHAR2
    , p4_a6  VARCHAR2
    , p4_a7  VARCHAR2
    , p4_a8  VARCHAR2
    , p4_a9  VARCHAR2
    , p4_a10  VARCHAR2
    , p4_a11  VARCHAR2
    , p4_a12  VARCHAR2
    , p4_a13  VARCHAR2
    , p4_a14  VARCHAR2
    , p4_a15  VARCHAR2
    , p4_a16  VARCHAR2
    , p4_a17  VARCHAR2
    , p4_a18  VARCHAR2
    , p4_a19  VARCHAR2
    , p4_a20  VARCHAR2
    , p4_a21  VARCHAR2
    , p4_a22  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_rec cn_job_title_pvt.job_role_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    ddp_rec.job_role_id := p4_a0;
    ddp_rec.job_title_id := p4_a1;
    ddp_rec.role_id := p4_a2;
    ddp_rec.start_date := rosetta_g_miss_date_in_map(p4_a3);
    ddp_rec.end_date := rosetta_g_miss_date_in_map(p4_a4);
    ddp_rec.default_flag := p4_a5;
    ddp_rec.attribute_category := p4_a6;
    ddp_rec.attribute1 := p4_a7;
    ddp_rec.attribute2 := p4_a8;
    ddp_rec.attribute3 := p4_a9;
    ddp_rec.attribute4 := p4_a10;
    ddp_rec.attribute5 := p4_a11;
    ddp_rec.attribute6 := p4_a12;
    ddp_rec.attribute7 := p4_a13;
    ddp_rec.attribute8 := p4_a14;
    ddp_rec.attribute9 := p4_a15;
    ddp_rec.attribute10 := p4_a16;
    ddp_rec.attribute11 := p4_a17;
    ddp_rec.attribute12 := p4_a18;
    ddp_rec.attribute13 := p4_a19;
    ddp_rec.attribute14 := p4_a20;
    ddp_rec.attribute15 := p4_a21;
    ddp_rec.object_version_number := p4_a22;




    -- here's the delegated call to the old PL/SQL routine
    cn_job_title_pvt.update_job_role(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      ddp_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

  procedure get_job_details(p_job_title_id  NUMBER
    , p1_a0 out nocopy JTF_NUMBER_TABLE
    , p1_a1 out nocopy JTF_NUMBER_TABLE
    , p1_a2 out nocopy JTF_NUMBER_TABLE
    , p1_a3 out nocopy JTF_DATE_TABLE
    , p1_a4 out nocopy JTF_DATE_TABLE
    , p1_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p1_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p1_a7 out nocopy JTF_VARCHAR2_TABLE_200
    , p1_a8 out nocopy JTF_VARCHAR2_TABLE_200
    , p1_a9 out nocopy JTF_VARCHAR2_TABLE_200
    , p1_a10 out nocopy JTF_VARCHAR2_TABLE_200
    , p1_a11 out nocopy JTF_VARCHAR2_TABLE_200
    , p1_a12 out nocopy JTF_VARCHAR2_TABLE_200
    , p1_a13 out nocopy JTF_VARCHAR2_TABLE_200
    , p1_a14 out nocopy JTF_VARCHAR2_TABLE_200
    , p1_a15 out nocopy JTF_VARCHAR2_TABLE_200
    , p1_a16 out nocopy JTF_VARCHAR2_TABLE_200
    , p1_a17 out nocopy JTF_VARCHAR2_TABLE_200
    , p1_a18 out nocopy JTF_VARCHAR2_TABLE_200
    , p1_a19 out nocopy JTF_VARCHAR2_TABLE_200
    , p1_a20 out nocopy JTF_VARCHAR2_TABLE_200
    , p1_a21 out nocopy JTF_VARCHAR2_TABLE_200
    , p1_a22 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddx_result_tbl cn_job_title_pvt.job_role_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any


    -- here's the delegated call to the old PL/SQL routine
    cn_job_title_pvt.get_job_details(p_job_title_id,
      ddx_result_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any

    cn_job_title_pvt_w.rosetta_table_copy_out_p3(ddx_result_tbl, p1_a0
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
      );
  end;

  procedure get_job_titles(p_range_low  NUMBER
    , p_range_high  NUMBER
    , p_search_name  VARCHAR2
    , p_search_code  VARCHAR2
    , x_total_rows out nocopy  NUMBER
    , p5_a0 out nocopy JTF_NUMBER_TABLE
    , p5_a1 out nocopy JTF_VARCHAR2_TABLE_300
    , p5_a2 out nocopy JTF_VARCHAR2_TABLE_300
    , p5_a3 out nocopy JTF_NUMBER_TABLE
    , p5_a4 out nocopy JTF_VARCHAR2_TABLE_100
  )

  as
    ddx_result_tbl cn_job_title_pvt.job_title_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any






    -- here's the delegated call to the old PL/SQL routine
    cn_job_title_pvt.get_job_titles(p_range_low,
      p_range_high,
      p_search_name,
      p_search_code,
      x_total_rows,
      ddx_result_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





    cn_job_title_pvt_w.rosetta_table_copy_out_p1(ddx_result_tbl, p5_a0
      , p5_a1
      , p5_a2
      , p5_a3
      , p5_a4
      );
  end;

  procedure get_all_job_titles(p0_a0 out nocopy JTF_NUMBER_TABLE
    , p0_a1 out nocopy JTF_VARCHAR2_TABLE_300
    , p0_a2 out nocopy JTF_VARCHAR2_TABLE_300
    , p0_a3 out nocopy JTF_NUMBER_TABLE
    , p0_a4 out nocopy JTF_VARCHAR2_TABLE_100
  )

  as
    ddx_result_tbl cn_job_title_pvt.job_title_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    -- here's the delegated call to the old PL/SQL routine
    cn_job_title_pvt.get_all_job_titles(ddx_result_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any
    cn_job_title_pvt_w.rosetta_table_copy_out_p1(ddx_result_tbl, p0_a0
      , p0_a1
      , p0_a2
      , p0_a3
      , p0_a4
      );
  end;

  procedure get_job_roles(p0_a0 out nocopy JTF_NUMBER_TABLE
    , p0_a1 out nocopy JTF_VARCHAR2_TABLE_300
    , p0_a2 out nocopy JTF_VARCHAR2_TABLE_300
    , p0_a3 out nocopy JTF_NUMBER_TABLE
    , p0_a4 out nocopy JTF_VARCHAR2_TABLE_100
  )

  as
    ddx_result_tbl cn_job_title_pvt.job_title_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    -- here's the delegated call to the old PL/SQL routine
    cn_job_title_pvt.get_job_roles(ddx_result_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any
    cn_job_title_pvt_w.rosetta_table_copy_out_p1(ddx_result_tbl, p0_a0
      , p0_a1
      , p0_a2
      , p0_a3
      , p0_a4
      );
  end;

end cn_job_title_pvt_w;

/
