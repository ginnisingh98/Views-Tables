--------------------------------------------------------
--  DDL for Package Body CN_SEAS_SCHEDULES_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_SEAS_SCHEDULES_PVT_W" as
  /* $Header: cnwsschb.pls 115.3 2002/11/25 22:32:08 nkodkani ship $ */
  rosetta_g_mistake_date date := to_date('01/01/+4713', 'MM/DD/SYYYY');
  rosetta_g_miss_date date := to_date('01/01/-4712', 'MM/DD/SYYYY');

  -- this is to workaround the JDBC bug regarding IN DATE of value GMiss
  function rosetta_g_miss_date_in_map(d date) return date as
  begin
    if d = rosetta_g_mistake_date then return fnd_api.g_miss_date; end if;
    return d;
  end;

  procedure rosetta_table_copy_in_p1(t out nocopy cn_seas_schedules_pvt.seas_schedules_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_DATE_TABLE
    , a5 JTF_DATE_TABLE
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).seas_schedule_id := a0(indx);
          t(ddindx).name := a1(indx);
          t(ddindx).description := a2(indx);
          t(ddindx).period_year := a3(indx);
          t(ddindx).start_date := rosetta_g_miss_date_in_map(a4(indx));
          t(ddindx).end_date := rosetta_g_miss_date_in_map(a5(indx));
          t(ddindx).validation_status := a6(indx);
          t(ddindx).object_version_number := a7(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p1;
  procedure rosetta_table_copy_out_p1(t cn_seas_schedules_pvt.seas_schedules_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_DATE_TABLE
    , a5 out nocopy JTF_DATE_TABLE
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    , a7 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_DATE_TABLE();
    a5 := JTF_DATE_TABLE();
    a6 := JTF_VARCHAR2_TABLE_100();
    a7 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_DATE_TABLE();
      a5 := JTF_DATE_TABLE();
      a6 := JTF_VARCHAR2_TABLE_100();
      a7 := JTF_NUMBER_TABLE();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        a3.extend(t.count);
        a4.extend(t.count);
        a5.extend(t.count);
        a6.extend(t.count);
        a7.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).seas_schedule_id;
          a1(indx) := t(ddindx).name;
          a2(indx) := t(ddindx).description;
          a3(indx) := t(ddindx).period_year;
          a4(indx) := t(ddindx).start_date;
          a5(indx) := t(ddindx).end_date;
          a6(indx) := t(ddindx).validation_status;
          a7(indx) := t(ddindx).object_version_number;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p1;

  procedure create_seas_schedule(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p4_a0  NUMBER
    , p4_a1  VARCHAR2
    , p4_a2  VARCHAR2
    , p4_a3  NUMBER
    , p4_a4  DATE
    , p4_a5  DATE
    , p4_a6  VARCHAR2
    , p4_a7  NUMBER
    , x_seas_schedule_id out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_seas_schedules_rec_type cn_seas_schedules_pvt.seas_schedules_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    ddp_seas_schedules_rec_type.seas_schedule_id := p4_a0;
    ddp_seas_schedules_rec_type.name := p4_a1;
    ddp_seas_schedules_rec_type.description := p4_a2;
    ddp_seas_schedules_rec_type.period_year := p4_a3;
    ddp_seas_schedules_rec_type.start_date := rosetta_g_miss_date_in_map(p4_a4);
    ddp_seas_schedules_rec_type.end_date := rosetta_g_miss_date_in_map(p4_a5);
    ddp_seas_schedules_rec_type.validation_status := p4_a6;
    ddp_seas_schedules_rec_type.object_version_number := p4_a7;





    -- here's the delegated call to the old PL/SQL routine
    cn_seas_schedules_pvt.create_seas_schedule(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      ddp_seas_schedules_rec_type,
      x_seas_schedule_id,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

  procedure update_seas_schedule(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p4_a0  NUMBER
    , p4_a1  VARCHAR2
    , p4_a2  VARCHAR2
    , p4_a3  NUMBER
    , p4_a4  DATE
    , p4_a5  DATE
    , p4_a6  VARCHAR2
    , p4_a7  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_seas_schedules_rec_type cn_seas_schedules_pvt.seas_schedules_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    ddp_seas_schedules_rec_type.seas_schedule_id := p4_a0;
    ddp_seas_schedules_rec_type.name := p4_a1;
    ddp_seas_schedules_rec_type.description := p4_a2;
    ddp_seas_schedules_rec_type.period_year := p4_a3;
    ddp_seas_schedules_rec_type.start_date := rosetta_g_miss_date_in_map(p4_a4);
    ddp_seas_schedules_rec_type.end_date := rosetta_g_miss_date_in_map(p4_a5);
    ddp_seas_schedules_rec_type.validation_status := p4_a6;
    ddp_seas_schedules_rec_type.object_version_number := p4_a7;




    -- here's the delegated call to the old PL/SQL routine
    cn_seas_schedules_pvt.update_seas_schedule(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      ddp_seas_schedules_rec_type,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

end cn_seas_schedules_pvt_w;

/
