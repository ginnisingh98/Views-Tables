--------------------------------------------------------
--  DDL for Package Body CN_SEASONALITIES_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_SEASONALITIES_PVT_W" as
  /* $Header: cnwseasb.pls 115.4 2002/11/25 22:30:20 nkodkani ship $ */
  rosetta_g_mistake_date date := to_date('01/01/+4713', 'MM/DD/SYYYY');
  rosetta_g_miss_date date := to_date('01/01/-4712', 'MM/DD/SYYYY');

  -- this is to workaround the JDBC bug regarding IN DATE of value GMiss
  function rosetta_g_miss_date_in_map(d date) return date as
  begin
    if d = rosetta_g_mistake_date then return fnd_api.g_miss_date; end if;
    return d;
  end;

  procedure rosetta_table_copy_in_p2(t out nocopy cn_seasonalities_pvt.seasonalities_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).seas_schedule_id := a0(indx);
          t(ddindx).seasonality_id := a1(indx);
          t(ddindx).pct_seasonality := a2(indx);
          t(ddindx).object_version_number := a3(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p2;
  procedure rosetta_table_copy_out_p2(t cn_seasonalities_pvt.seasonalities_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_NUMBER_TABLE();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        a3.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).seas_schedule_id;
          a1(indx) := t(ddindx).seasonality_id;
          a2(indx) := t(ddindx).pct_seasonality;
          a3(indx) := t(ddindx).object_version_number;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p2;

  procedure update_seasonalities(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p4_a0  NUMBER
    , p4_a1  NUMBER
    , p4_a2  NUMBER
    , p4_a3  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_seasonalities_rec_type cn_seasonalities_pvt.seasonalities_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    ddp_seasonalities_rec_type.seas_schedule_id := p4_a0;
    ddp_seasonalities_rec_type.seasonality_id := p4_a1;
    ddp_seasonalities_rec_type.pct_seasonality := p4_a2;
    ddp_seasonalities_rec_type.object_version_number := p4_a3;




    -- here's the delegated call to the old PL/SQL routine
    cn_seasonalities_pvt.update_seasonalities(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      ddp_seasonalities_rec_type,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

  procedure validate_seasonalities(p_api_version  NUMBER
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
    ddp_seas_schedule_rec_type cn_seasonalities_pvt.cp_seas_schedules_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    ddp_seas_schedule_rec_type.seas_schedule_id := p4_a0;
    ddp_seas_schedule_rec_type.name := p4_a1;
    ddp_seas_schedule_rec_type.description := p4_a2;
    ddp_seas_schedule_rec_type.period_year := p4_a3;
    ddp_seas_schedule_rec_type.start_date := rosetta_g_miss_date_in_map(p4_a4);
    ddp_seas_schedule_rec_type.end_date := rosetta_g_miss_date_in_map(p4_a5);
    ddp_seas_schedule_rec_type.validation_status := p4_a6;
    ddp_seas_schedule_rec_type.object_version_number := p4_a7;




    -- here's the delegated call to the old PL/SQL routine
    cn_seasonalities_pvt.validate_seasonalities(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      ddp_seas_schedule_rec_type,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

end cn_seasonalities_pvt_w;

/
