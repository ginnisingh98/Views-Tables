--------------------------------------------------------
--  DDL for Package Body JTF_CALENDAR_PUB_24HR_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_CALENDAR_PUB_24HR_W" as
  /* $Header: JTFPC24B.pls 120.2 2005/07/07 12:29:54 abraina ship $ */
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

  procedure rosetta_table_copy_in_p1(t out nocopy jtf_calendar_pub_24hr.shift_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_DATE_TABLE
    , a2 JTF_DATE_TABLE
    , a3 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).shift_construct_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).start_time := rosetta_g_miss_date_in_map(a1(indx));
          t(ddindx).end_time := rosetta_g_miss_date_in_map(a2(indx));
          t(ddindx).availability_type := a3(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p1;
  procedure rosetta_table_copy_out_p1(t jtf_calendar_pub_24hr.shift_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_DATE_TABLE
    , a2 out nocopy JTF_DATE_TABLE
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_DATE_TABLE();
    a2 := JTF_DATE_TABLE();
    a3 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_DATE_TABLE();
      a2 := JTF_DATE_TABLE();
      a3 := JTF_VARCHAR2_TABLE_100();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        a3.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).shift_construct_id);
          a1(indx) := t(ddindx).start_time;
          a2(indx) := t(ddindx).end_time;
          a3(indx) := t(ddindx).availability_type;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p1;

  procedure rosetta_table_copy_in_p3(t out nocopy jtf_calendar_pub_24hr.shift_tbl_attributes_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_DATE_TABLE
    , a2 JTF_DATE_TABLE
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_VARCHAR2_TABLE_200
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
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).shift_construct_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).start_time := rosetta_g_miss_date_in_map(a1(indx));
          t(ddindx).end_time := rosetta_g_miss_date_in_map(a2(indx));
          t(ddindx).availability_type := a3(indx);
          t(ddindx).attribute1 := a4(indx);
          t(ddindx).attribute2 := a5(indx);
          t(ddindx).attribute3 := a6(indx);
          t(ddindx).attribute4 := a7(indx);
          t(ddindx).attribute5 := a8(indx);
          t(ddindx).attribute6 := a9(indx);
          t(ddindx).attribute7 := a10(indx);
          t(ddindx).attribute8 := a11(indx);
          t(ddindx).attribute9 := a12(indx);
          t(ddindx).attribute10 := a13(indx);
          t(ddindx).attribute11 := a14(indx);
          t(ddindx).attribute12 := a15(indx);
          t(ddindx).attribute13 := a16(indx);
          t(ddindx).attribute14 := a17(indx);
          t(ddindx).attribute15 := a18(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p3;
  procedure rosetta_table_copy_out_p3(t jtf_calendar_pub_24hr.shift_tbl_attributes_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_DATE_TABLE
    , a2 out nocopy JTF_DATE_TABLE
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_VARCHAR2_TABLE_200
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
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_DATE_TABLE();
    a2 := JTF_DATE_TABLE();
    a3 := JTF_VARCHAR2_TABLE_100();
    a4 := JTF_VARCHAR2_TABLE_200();
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
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_DATE_TABLE();
      a2 := JTF_DATE_TABLE();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_VARCHAR2_TABLE_200();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).shift_construct_id);
          a1(indx) := t(ddindx).start_time;
          a2(indx) := t(ddindx).end_time;
          a3(indx) := t(ddindx).availability_type;
          a4(indx) := t(ddindx).attribute1;
          a5(indx) := t(ddindx).attribute2;
          a6(indx) := t(ddindx).attribute3;
          a7(indx) := t(ddindx).attribute4;
          a8(indx) := t(ddindx).attribute5;
          a9(indx) := t(ddindx).attribute6;
          a10(indx) := t(ddindx).attribute7;
          a11(indx) := t(ddindx).attribute8;
          a12(indx) := t(ddindx).attribute9;
          a13(indx) := t(ddindx).attribute10;
          a14(indx) := t(ddindx).attribute11;
          a15(indx) := t(ddindx).attribute12;
          a16(indx) := t(ddindx).attribute13;
          a17(indx) := t(ddindx).attribute14;
          a18(indx) := t(ddindx).attribute15;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p3;

  procedure get_available_time(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_resource_id  NUMBER
    , p_resource_type  VARCHAR2
    , p_start_date  date
    , p_end_date  date
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p9_a0 out nocopy JTF_NUMBER_TABLE
    , p9_a1 out nocopy JTF_DATE_TABLE
    , p9_a2 out nocopy JTF_DATE_TABLE
    , p9_a3 out nocopy JTF_VARCHAR2_TABLE_100
  )

  as
    ddp_start_date date;
    ddp_end_date date;
    ddx_shift jtf_calendar_pub_24hr.shift_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    ddp_start_date := rosetta_g_miss_date_in_map(p_start_date);

    ddp_end_date := rosetta_g_miss_date_in_map(p_end_date);





    -- here's the delegated call to the old PL/SQL routine
    jtf_calendar_pub_24hr.get_available_time(p_api_version,
      p_init_msg_list,
      p_resource_id,
      p_resource_type,
      ddp_start_date,
      ddp_end_date,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddx_shift);

    -- copy data back from the local variables to OUT or IN-OUT args, if any









    jtf_calendar_pub_24hr_w.rosetta_table_copy_out_p1(ddx_shift, p9_a0
      , p9_a1
      , p9_a2
      , p9_a3
      );
  end;

  procedure get_available_slot(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_resource_id  NUMBER
    , p_resource_type  VARCHAR2
    , p_start_date_time  date
    , p_end_date_time  date
    , p_duration  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_slot_start_date out nocopy  DATE
    , x_slot_end_date out nocopy  DATE
    , x_shift_construct_id out nocopy  NUMBER
    , x_availability_type out nocopy  VARCHAR2
  )

  as
    ddp_start_date_time date;
    ddp_end_date_time date;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    ddp_start_date_time := rosetta_g_miss_date_in_map(p_start_date_time);

    ddp_end_date_time := rosetta_g_miss_date_in_map(p_end_date_time);









    -- here's the delegated call to the old PL/SQL routine
    jtf_calendar_pub_24hr.get_available_slot(p_api_version,
      p_init_msg_list,
      p_resource_id,
      p_resource_type,
      ddp_start_date_time,
      ddp_end_date_time,
      p_duration,
      x_return_status,
      x_msg_count,
      x_msg_data,
      x_slot_start_date,
      x_slot_end_date,
      x_shift_construct_id,
      x_availability_type);

    -- copy data back from the local variables to OUT or IN-OUT args, if any













  end;

  procedure get_resource_shifts(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_resource_id  NUMBER
    , p_resource_type  VARCHAR2
    , p_start_date  date
    , p_end_date  date
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p9_a0 out nocopy JTF_NUMBER_TABLE
    , p9_a1 out nocopy JTF_DATE_TABLE
    , p9_a2 out nocopy JTF_DATE_TABLE
    , p9_a3 out nocopy JTF_VARCHAR2_TABLE_100
  )

  as
    ddp_start_date date;
    ddp_end_date date;
    ddx_shift jtf_calendar_pub_24hr.shift_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    ddp_start_date := rosetta_g_miss_date_in_map(p_start_date);

    ddp_end_date := rosetta_g_miss_date_in_map(p_end_date);





    -- here's the delegated call to the old PL/SQL routine
    jtf_calendar_pub_24hr.get_resource_shifts(p_api_version,
      p_init_msg_list,
      p_resource_id,
      p_resource_type,
      ddp_start_date,
      ddp_end_date,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddx_shift);

    -- copy data back from the local variables to OUT or IN-OUT args, if any









    jtf_calendar_pub_24hr_w.rosetta_table_copy_out_p1(ddx_shift, p9_a0
      , p9_a1
      , p9_a2
      , p9_a3
      );
  end;

  procedure get_resource_shifts(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_resource_id  NUMBER
    , p_resource_type  VARCHAR2
    , p_start_date  date
    , p_end_date  date
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p9_a0 out nocopy JTF_NUMBER_TABLE
    , p9_a1 out nocopy JTF_DATE_TABLE
    , p9_a2 out nocopy JTF_DATE_TABLE
    , p9_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a4 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a5 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a6 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a7 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a8 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a9 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a10 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a11 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a12 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a13 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a14 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a15 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a16 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a17 out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a18 out nocopy JTF_VARCHAR2_TABLE_200
  )

  as
    ddp_start_date date;
    ddp_end_date date;
    ddx_shift jtf_calendar_pub_24hr.shift_tbl_attributes_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    ddp_start_date := rosetta_g_miss_date_in_map(p_start_date);

    ddp_end_date := rosetta_g_miss_date_in_map(p_end_date);





    -- here's the delegated call to the old PL/SQL routine
    jtf_calendar_pub_24hr.get_resource_shifts(p_api_version,
      p_init_msg_list,
      p_resource_id,
      p_resource_type,
      ddp_start_date,
      ddp_end_date,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddx_shift);

    -- copy data back from the local variables to OUT or IN-OUT args, if any









    jtf_calendar_pub_24hr_w.rosetta_table_copy_out_p3(ddx_shift, p9_a0
      , p9_a1
      , p9_a2
      , p9_a3
      , p9_a4
      , p9_a5
      , p9_a6
      , p9_a7
      , p9_a8
      , p9_a9
      , p9_a10
      , p9_a11
      , p9_a12
      , p9_a13
      , p9_a14
      , p9_a15
      , p9_a16
      , p9_a17
      , p9_a18
      );
  end;

  procedure is_res_available(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_resource_id  NUMBER
    , p_resource_type  VARCHAR2
    , p_start_date_time  date
    , p_duration  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_avail out nocopy  VARCHAR2
  )

  as
    ddp_start_date_time date;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    ddp_start_date_time := rosetta_g_miss_date_in_map(p_start_date_time);






    -- here's the delegated call to the old PL/SQL routine
    jtf_calendar_pub_24hr.is_res_available(p_api_version,
      p_init_msg_list,
      p_resource_id,
      p_resource_type,
      ddp_start_date_time,
      p_duration,
      x_return_status,
      x_msg_count,
      x_msg_data,
      x_avail);

    -- copy data back from the local variables to OUT or IN-OUT args, if any









  end;

  procedure get_res_schedule(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_resource_id  NUMBER
    , p_resource_type  VARCHAR2
    , p_start_date  date
    , p_end_date  date
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p9_a0 out nocopy JTF_NUMBER_TABLE
    , p9_a1 out nocopy JTF_DATE_TABLE
    , p9_a2 out nocopy JTF_DATE_TABLE
    , p9_a3 out nocopy JTF_VARCHAR2_TABLE_100
  )

  as
    ddp_start_date date;
    ddp_end_date date;
    ddx_shift jtf_calendar_pub_24hr.shift_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    ddp_start_date := rosetta_g_miss_date_in_map(p_start_date);

    ddp_end_date := rosetta_g_miss_date_in_map(p_end_date);





    -- here's the delegated call to the old PL/SQL routine
    jtf_calendar_pub_24hr.get_res_schedule(p_api_version,
      p_init_msg_list,
      p_resource_id,
      p_resource_type,
      ddp_start_date,
      ddp_end_date,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddx_shift);

    -- copy data back from the local variables to OUT or IN-OUT args, if any









    jtf_calendar_pub_24hr_w.rosetta_table_copy_out_p1(ddx_shift, p9_a0
      , p9_a1
      , p9_a2
      , p9_a3
      );
  end;

  function resourcedt_to_serverdt(p_resource_dttime  date
    , p_resource_tz_id  NUMBER
    , p_server_tz_id  NUMBER
  ) return date

  as
    ddp_resource_dttime date;
    ddindx binary_integer; indx binary_integer;
    ddrosetta_retval date;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_resource_dttime := rosetta_g_miss_date_in_map(p_resource_dttime);



    -- here's the delegated call to the old PL/SQL routine
    ddrosetta_retval := jtf_calendar_pub_24hr.resourcedt_to_serverdt(ddp_resource_dttime,
      p_resource_tz_id,
      p_server_tz_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any



    return ddrosetta_retval;
  end;

  procedure validate_cal_date(p_calendar_id  NUMBER
    , p_shift_date  date
    , ddrosetta_retval_bool OUT NOCOPY NUMBER
  )

  as
    ddp_shift_date date;
    ddindx binary_integer; indx binary_integer;
    ddrosetta_retval boolean;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    ddp_shift_date := rosetta_g_miss_date_in_map(p_shift_date);

    -- here's the delegated call to the old PL/SQL routine
    ddrosetta_retval := jtf_calendar_pub_24hr.validate_cal_date(p_calendar_id,
      ddp_shift_date);

    -- copy data back from the local variables to OUT or IN-OUT args, if any
    if ddrosetta_retval is null
      then ddrosetta_retval_bool := null;
    elsif ddrosetta_retval
      then ddrosetta_retval_bool := 1;
    else ddrosetta_retval_bool := 0;
    end if;

  end;

end jtf_calendar_pub_24hr_w;

/
