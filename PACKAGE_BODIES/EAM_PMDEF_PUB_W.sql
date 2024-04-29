--------------------------------------------------------
--  DDL for Package Body EAM_PMDEF_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EAM_PMDEF_PUB_W" as
  /* $Header: EAMWPMDB.pls 120.2 2005/10/14 12:11:19 hkarmach noship $ */
  procedure rosetta_table_copy_in_p2(t out nocopy eam_pmdef_pub.pm_activities_grp_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_DATE_TABLE
    , a6 JTF_DATE_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).pm_schedule_id := a0(indx);
          t(ddindx).activity_association_id := a1(indx);
          t(ddindx).interval_multiple := a2(indx);
          t(ddindx).allow_repeat_in_cycle := a3(indx);
          t(ddindx).day_tolerance := a4(indx);
          t(ddindx).next_service_start_date := a5(indx);
          t(ddindx).next_service_end_date := a6(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p2;
  procedure rosetta_table_copy_out_p2(t eam_pmdef_pub.pm_activities_grp_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_DATE_TABLE
    , a6 out nocopy JTF_DATE_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_VARCHAR2_TABLE_100();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_DATE_TABLE();
    a6 := JTF_DATE_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_DATE_TABLE();
      a6 := JTF_DATE_TABLE();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        a3.extend(t.count);
        a4.extend(t.count);
        a5.extend(t.count);
        a6.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).pm_schedule_id;
          a1(indx) := t(ddindx).activity_association_id;
          a2(indx) := t(ddindx).interval_multiple;
          a3(indx) := t(ddindx).allow_repeat_in_cycle;
          a4(indx) := t(ddindx).day_tolerance;
          a5(indx) := t(ddindx).next_service_start_date;
          a6(indx) := t(ddindx).next_service_end_date;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p2;

  procedure rosetta_table_copy_in_p4(t out nocopy eam_pmdef_pub.pm_rule_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_DATE_TABLE
    , a10 JTF_DATE_TABLE
    , a11 JTF_DATE_TABLE
    , a12 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).rule_id := a0(indx);
          t(ddindx).pm_schedule_id := a1(indx);
          t(ddindx).rule_type := a2(indx);
          t(ddindx).day_interval := a3(indx);
          t(ddindx).meter_id := a4(indx);
          t(ddindx).runtime_interval := a5(indx);
          t(ddindx).last_service_reading := a6(indx);
          t(ddindx).effective_reading_from := a7(indx);
          t(ddindx).effective_reading_to := a8(indx);
          t(ddindx).effective_date_from := a9(indx);
          t(ddindx).effective_date_to := a10(indx);
          t(ddindx).list_date := a11(indx);
          t(ddindx).list_date_desc := a12(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p4;
  procedure rosetta_table_copy_out_p4(t eam_pmdef_pub.pm_rule_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_DATE_TABLE
    , a10 out nocopy JTF_DATE_TABLE
    , a11 out nocopy JTF_DATE_TABLE
    , a12 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_NUMBER_TABLE();
    a9 := JTF_DATE_TABLE();
    a10 := JTF_DATE_TABLE();
    a11 := JTF_DATE_TABLE();
    a12 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_NUMBER_TABLE();
      a9 := JTF_DATE_TABLE();
      a10 := JTF_DATE_TABLE();
      a11 := JTF_DATE_TABLE();
      a12 := JTF_VARCHAR2_TABLE_100();
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
          a0(indx) := t(ddindx).rule_id;
          a1(indx) := t(ddindx).pm_schedule_id;
          a2(indx) := t(ddindx).rule_type;
          a3(indx) := t(ddindx).day_interval;
          a4(indx) := t(ddindx).meter_id;
          a5(indx) := t(ddindx).runtime_interval;
          a6(indx) := t(ddindx).last_service_reading;
          a7(indx) := t(ddindx).effective_reading_from;
          a8(indx) := t(ddindx).effective_reading_to;
          a9(indx) := t(ddindx).effective_date_from;
          a10(indx) := t(ddindx).effective_date_to;
          a11(indx) := t(ddindx).list_date;
          a12(indx) := t(ddindx).list_date_desc;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p4;

  procedure rosetta_table_copy_in_p6(t out nocopy eam_pmdef_pub.pm_date_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_DATE_TABLE
    , a2 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).index1 := a0(indx);
          t(ddindx).date1 := a1(indx);
          t(ddindx).other := a2(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p6;
  procedure rosetta_table_copy_out_p6(t eam_pmdef_pub.pm_date_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_DATE_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_DATE_TABLE();
    a2 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_DATE_TABLE();
      a2 := JTF_NUMBER_TABLE();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).index1;
          a1(indx) := t(ddindx).date1;
          a2(indx) := t(ddindx).other;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p6;

  procedure rosetta_table_copy_in_p8(t out nocopy eam_pmdef_pub.pm_num_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).index1 := a0(indx);
          t(ddindx).num1 := a1(indx);
          t(ddindx).other := a2(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p8;
  procedure rosetta_table_copy_out_p8(t eam_pmdef_pub.pm_num_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).index1;
          a1(indx) := t(ddindx).num1;
          a2(indx) := t(ddindx).other;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p8;

  procedure instantiate_pm_defs(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_activity_assoc_id_tbl JTF_NUMBER_TABLE
  )

  as
    ddp_activity_assoc_id_tbl eam_objectinstantiation_pub.association_id_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    eam_objectinstantiation_pub_w.rosetta_table_copy_in_p0(ddp_activity_assoc_id_tbl, p_activity_assoc_id_tbl);

    -- here's the delegated call to the old PL/SQL routine
    eam_pmdef_pub.instantiate_pm_defs(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_activity_assoc_id_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

  procedure create_pm_def(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0  NUMBER
    , p7_a1  NUMBER
    , p7_a2  VARCHAR2
    , p7_a3  DATE
    , p7_a4  DATE
    , p7_a5  NUMBER
    , p7_a6  NUMBER
    , p7_a7  VARCHAR2
    , p7_a8  VARCHAR2
    , p7_a9  VARCHAR2
    , p7_a10  VARCHAR2
    , p7_a11  VARCHAR2
    , p7_a12  VARCHAR2
    , p7_a13  VARCHAR2
    , p7_a14  VARCHAR2
    , p7_a15  VARCHAR2
    , p7_a16  VARCHAR2
    , p7_a17  VARCHAR2
    , p7_a18  VARCHAR2
    , p7_a19  VARCHAR2
    , p7_a20  VARCHAR2
    , p7_a21  VARCHAR2
    , p7_a22  VARCHAR2
    , p7_a23  NUMBER
    , p7_a24  VARCHAR2
    , p7_a25  VARCHAR2
    , p7_a26  VARCHAR2
    , p7_a27  VARCHAR2
    , p7_a28  VARCHAR2
    , p7_a29  NUMBER
    , p7_a30  NUMBER
    , p7_a31  NUMBER
    , p7_a32  DATE
    , p7_a33  DATE
    , p7_a34  NUMBER
    , p7_a35  VARCHAR2
    , p7_a36  VARCHAR2
    , p7_a37  VARCHAR2
    , p7_a38  NUMBER
    , p7_a39  NUMBER
    , p7_a40  NUMBER
    , p7_a41  NUMBER
    , p7_a42  NUMBER
    , p7_a43  DATE
    , p7_a44  NUMBER
    , p7_a45  NUMBER
    , p7_a46  NUMBER
    , p7_a47  NUMBER
    , p8_a0 JTF_NUMBER_TABLE
    , p8_a1 JTF_NUMBER_TABLE
    , p8_a2 JTF_NUMBER_TABLE
    , p8_a3 JTF_VARCHAR2_TABLE_100
    , p8_a4 JTF_NUMBER_TABLE
    , p8_a5 JTF_DATE_TABLE
    , p8_a6 JTF_DATE_TABLE
    , p9_a0 JTF_NUMBER_TABLE
    , p9_a1 JTF_NUMBER_TABLE
    , p9_a2 JTF_NUMBER_TABLE
    , p9_a3 JTF_NUMBER_TABLE
    , p9_a4 JTF_NUMBER_TABLE
    , p9_a5 JTF_NUMBER_TABLE
    , p9_a6 JTF_NUMBER_TABLE
    , p9_a7 JTF_NUMBER_TABLE
    , p9_a8 JTF_NUMBER_TABLE
    , p9_a9 JTF_DATE_TABLE
    , p9_a10 JTF_DATE_TABLE
    , p9_a11 JTF_DATE_TABLE
    , p9_a12 JTF_VARCHAR2_TABLE_100
    , p10_a0 JTF_NUMBER_TABLE
    , p10_a1 JTF_NUMBER_TABLE
    , p10_a2 JTF_NUMBER_TABLE
    , p10_a3 JTF_NUMBER_TABLE
    , p10_a4 JTF_NUMBER_TABLE
    , p10_a5 JTF_NUMBER_TABLE
    , p10_a6 JTF_NUMBER_TABLE
    , p10_a7 JTF_NUMBER_TABLE
    , p10_a8 JTF_NUMBER_TABLE
    , p10_a9 JTF_DATE_TABLE
    , p10_a10 JTF_DATE_TABLE
    , p10_a11 JTF_DATE_TABLE
    , p10_a12 JTF_VARCHAR2_TABLE_100
    , p11_a0 JTF_NUMBER_TABLE
    , p11_a1 JTF_NUMBER_TABLE
    , p11_a2 JTF_NUMBER_TABLE
    , p11_a3 JTF_NUMBER_TABLE
    , p11_a4 JTF_NUMBER_TABLE
    , p11_a5 JTF_NUMBER_TABLE
    , p11_a6 JTF_NUMBER_TABLE
    , p11_a7 JTF_NUMBER_TABLE
    , p11_a8 JTF_NUMBER_TABLE
    , p11_a9 JTF_DATE_TABLE
    , p11_a10 JTF_DATE_TABLE
    , p11_a11 JTF_DATE_TABLE
    , p11_a12 JTF_VARCHAR2_TABLE_100
    , x_new_pm_schedule_id out nocopy  NUMBER
  )

  as
    ddp_pm_schedule_rec eam_pmdef_pub.pm_scheduling_rec_type;
    ddp_pm_activities_tbl eam_pmdef_pub.pm_activities_grp_tbl_type;
    ddp_pm_day_interval_rules_tbl eam_pmdef_pub.pm_rule_tbl_type;
    ddp_pm_runtime_rules_tbl eam_pmdef_pub.pm_rule_tbl_type;
    ddp_pm_list_date_rules_tbl eam_pmdef_pub.pm_rule_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_pm_schedule_rec.pm_schedule_id := p7_a0;
    ddp_pm_schedule_rec.activity_association_id := p7_a1;
    ddp_pm_schedule_rec.non_scheduled_flag := p7_a2;
    ddp_pm_schedule_rec.from_effective_date := p7_a3;
    ddp_pm_schedule_rec.to_effective_date := p7_a4;
    ddp_pm_schedule_rec.rescheduling_point := p7_a5;
    ddp_pm_schedule_rec.lead_time := p7_a6;
    ddp_pm_schedule_rec.attribute_category := p7_a7;
    ddp_pm_schedule_rec.attribute1 := p7_a8;
    ddp_pm_schedule_rec.attribute2 := p7_a9;
    ddp_pm_schedule_rec.attribute3 := p7_a10;
    ddp_pm_schedule_rec.attribute4 := p7_a11;
    ddp_pm_schedule_rec.attribute5 := p7_a12;
    ddp_pm_schedule_rec.attribute6 := p7_a13;
    ddp_pm_schedule_rec.attribute7 := p7_a14;
    ddp_pm_schedule_rec.attribute8 := p7_a15;
    ddp_pm_schedule_rec.attribute9 := p7_a16;
    ddp_pm_schedule_rec.attribute10 := p7_a17;
    ddp_pm_schedule_rec.attribute11 := p7_a18;
    ddp_pm_schedule_rec.attribute12 := p7_a19;
    ddp_pm_schedule_rec.attribute13 := p7_a20;
    ddp_pm_schedule_rec.attribute14 := p7_a21;
    ddp_pm_schedule_rec.attribute15 := p7_a22;
    ddp_pm_schedule_rec.day_tolerance := p7_a23;
    ddp_pm_schedule_rec.source_code := p7_a24;
    ddp_pm_schedule_rec.source_line := p7_a25;
    ddp_pm_schedule_rec.default_implement := p7_a26;
    ddp_pm_schedule_rec.whichever_first := p7_a27;
    ddp_pm_schedule_rec.include_manual := p7_a28;
    ddp_pm_schedule_rec.set_name_id := p7_a29;
    ddp_pm_schedule_rec.scheduling_method_code := p7_a30;
    ddp_pm_schedule_rec.type_code := p7_a31;
    ddp_pm_schedule_rec.next_service_start_date := p7_a32;
    ddp_pm_schedule_rec.next_service_end_date := p7_a33;
    ddp_pm_schedule_rec.source_tmpl_id := p7_a34;
    ddp_pm_schedule_rec.auto_instantiation_flag := p7_a35;
    ddp_pm_schedule_rec.name := p7_a36;
    ddp_pm_schedule_rec.tmpl_flag := p7_a37;
    ddp_pm_schedule_rec.generate_wo_status := p7_a38;
    ddp_pm_schedule_rec.interval_per_cycle := p7_a39;
    ddp_pm_schedule_rec.current_cycle := p7_a40;
    ddp_pm_schedule_rec.current_seq := p7_a41;
    ddp_pm_schedule_rec.current_wo_seq := p7_a42;
    ddp_pm_schedule_rec.base_date := p7_a43;
    ddp_pm_schedule_rec.base_reading := p7_a44;
    ddp_pm_schedule_rec.eam_last_cyclic_act := p7_a45;
    ddp_pm_schedule_rec.maintenance_object_id := p7_a46;
    ddp_pm_schedule_rec.maintenance_object_type := p7_a47;

    eam_pmdef_pub_w.rosetta_table_copy_in_p2(ddp_pm_activities_tbl, p8_a0
      , p8_a1
      , p8_a2
      , p8_a3
      , p8_a4
      , p8_a5
      , p8_a6
      );

    eam_pmdef_pub_w.rosetta_table_copy_in_p4(ddp_pm_day_interval_rules_tbl, p9_a0
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
      );

    eam_pmdef_pub_w.rosetta_table_copy_in_p4(ddp_pm_runtime_rules_tbl, p10_a0
      , p10_a1
      , p10_a2
      , p10_a3
      , p10_a4
      , p10_a5
      , p10_a6
      , p10_a7
      , p10_a8
      , p10_a9
      , p10_a10
      , p10_a11
      , p10_a12
      );

    eam_pmdef_pub_w.rosetta_table_copy_in_p4(ddp_pm_list_date_rules_tbl, p11_a0
      , p11_a1
      , p11_a2
      , p11_a3
      , p11_a4
      , p11_a5
      , p11_a6
      , p11_a7
      , p11_a8
      , p11_a9
      , p11_a10
      , p11_a11
      , p11_a12
      );


    -- here's the delegated call to the old PL/SQL routine
    eam_pmdef_pub.create_pm_def(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_pm_schedule_rec,
      ddp_pm_activities_tbl,
      ddp_pm_day_interval_rules_tbl,
      ddp_pm_runtime_rules_tbl,
      ddp_pm_list_date_rules_tbl,
      x_new_pm_schedule_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any












  end;

  procedure update_pm_def(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0  NUMBER
    , p7_a1  NUMBER
    , p7_a2  VARCHAR2
    , p7_a3  DATE
    , p7_a4  DATE
    , p7_a5  NUMBER
    , p7_a6  NUMBER
    , p7_a7  VARCHAR2
    , p7_a8  VARCHAR2
    , p7_a9  VARCHAR2
    , p7_a10  VARCHAR2
    , p7_a11  VARCHAR2
    , p7_a12  VARCHAR2
    , p7_a13  VARCHAR2
    , p7_a14  VARCHAR2
    , p7_a15  VARCHAR2
    , p7_a16  VARCHAR2
    , p7_a17  VARCHAR2
    , p7_a18  VARCHAR2
    , p7_a19  VARCHAR2
    , p7_a20  VARCHAR2
    , p7_a21  VARCHAR2
    , p7_a22  VARCHAR2
    , p7_a23  NUMBER
    , p7_a24  VARCHAR2
    , p7_a25  VARCHAR2
    , p7_a26  VARCHAR2
    , p7_a27  VARCHAR2
    , p7_a28  VARCHAR2
    , p7_a29  NUMBER
    , p7_a30  NUMBER
    , p7_a31  NUMBER
    , p7_a32  DATE
    , p7_a33  DATE
    , p7_a34  NUMBER
    , p7_a35  VARCHAR2
    , p7_a36  VARCHAR2
    , p7_a37  VARCHAR2
    , p7_a38  NUMBER
    , p7_a39  NUMBER
    , p7_a40  NUMBER
    , p7_a41  NUMBER
    , p7_a42  NUMBER
    , p7_a43  DATE
    , p7_a44  NUMBER
    , p7_a45  NUMBER
    , p7_a46  NUMBER
    , p7_a47  NUMBER
    , p8_a0 JTF_NUMBER_TABLE
    , p8_a1 JTF_NUMBER_TABLE
    , p8_a2 JTF_NUMBER_TABLE
    , p8_a3 JTF_VARCHAR2_TABLE_100
    , p8_a4 JTF_NUMBER_TABLE
    , p8_a5 JTF_DATE_TABLE
    , p8_a6 JTF_DATE_TABLE
    , p9_a0 JTF_NUMBER_TABLE
    , p9_a1 JTF_NUMBER_TABLE
    , p9_a2 JTF_NUMBER_TABLE
    , p9_a3 JTF_NUMBER_TABLE
    , p9_a4 JTF_NUMBER_TABLE
    , p9_a5 JTF_NUMBER_TABLE
    , p9_a6 JTF_NUMBER_TABLE
    , p9_a7 JTF_NUMBER_TABLE
    , p9_a8 JTF_NUMBER_TABLE
    , p9_a9 JTF_DATE_TABLE
    , p9_a10 JTF_DATE_TABLE
    , p9_a11 JTF_DATE_TABLE
    , p9_a12 JTF_VARCHAR2_TABLE_100
    , p10_a0 JTF_NUMBER_TABLE
    , p10_a1 JTF_NUMBER_TABLE
    , p10_a2 JTF_NUMBER_TABLE
    , p10_a3 JTF_NUMBER_TABLE
    , p10_a4 JTF_NUMBER_TABLE
    , p10_a5 JTF_NUMBER_TABLE
    , p10_a6 JTF_NUMBER_TABLE
    , p10_a7 JTF_NUMBER_TABLE
    , p10_a8 JTF_NUMBER_TABLE
    , p10_a9 JTF_DATE_TABLE
    , p10_a10 JTF_DATE_TABLE
    , p10_a11 JTF_DATE_TABLE
    , p10_a12 JTF_VARCHAR2_TABLE_100
    , p11_a0 JTF_NUMBER_TABLE
    , p11_a1 JTF_NUMBER_TABLE
    , p11_a2 JTF_NUMBER_TABLE
    , p11_a3 JTF_NUMBER_TABLE
    , p11_a4 JTF_NUMBER_TABLE
    , p11_a5 JTF_NUMBER_TABLE
    , p11_a6 JTF_NUMBER_TABLE
    , p11_a7 JTF_NUMBER_TABLE
    , p11_a8 JTF_NUMBER_TABLE
    , p11_a9 JTF_DATE_TABLE
    , p11_a10 JTF_DATE_TABLE
    , p11_a11 JTF_DATE_TABLE
    , p11_a12 JTF_VARCHAR2_TABLE_100
  )

  as
    ddp_pm_schedule_rec eam_pmdef_pub.pm_scheduling_rec_type;
    ddp_pm_activities_tbl eam_pmdef_pub.pm_activities_grp_tbl_type;
    ddp_pm_day_interval_rules_tbl eam_pmdef_pub.pm_rule_tbl_type;
    ddp_pm_runtime_rules_tbl eam_pmdef_pub.pm_rule_tbl_type;
    ddp_pm_list_date_rules_tbl eam_pmdef_pub.pm_rule_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_pm_schedule_rec.pm_schedule_id := p7_a0;
    ddp_pm_schedule_rec.activity_association_id := p7_a1;
    ddp_pm_schedule_rec.non_scheduled_flag := p7_a2;
    ddp_pm_schedule_rec.from_effective_date := p7_a3;
    ddp_pm_schedule_rec.to_effective_date := p7_a4;
    ddp_pm_schedule_rec.rescheduling_point := p7_a5;
    ddp_pm_schedule_rec.lead_time := p7_a6;
    ddp_pm_schedule_rec.attribute_category := p7_a7;
    ddp_pm_schedule_rec.attribute1 := p7_a8;
    ddp_pm_schedule_rec.attribute2 := p7_a9;
    ddp_pm_schedule_rec.attribute3 := p7_a10;
    ddp_pm_schedule_rec.attribute4 := p7_a11;
    ddp_pm_schedule_rec.attribute5 := p7_a12;
    ddp_pm_schedule_rec.attribute6 := p7_a13;
    ddp_pm_schedule_rec.attribute7 := p7_a14;
    ddp_pm_schedule_rec.attribute8 := p7_a15;
    ddp_pm_schedule_rec.attribute9 := p7_a16;
    ddp_pm_schedule_rec.attribute10 := p7_a17;
    ddp_pm_schedule_rec.attribute11 := p7_a18;
    ddp_pm_schedule_rec.attribute12 := p7_a19;
    ddp_pm_schedule_rec.attribute13 := p7_a20;
    ddp_pm_schedule_rec.attribute14 := p7_a21;
    ddp_pm_schedule_rec.attribute15 := p7_a22;
    ddp_pm_schedule_rec.day_tolerance := p7_a23;
    ddp_pm_schedule_rec.source_code := p7_a24;
    ddp_pm_schedule_rec.source_line := p7_a25;
    ddp_pm_schedule_rec.default_implement := p7_a26;
    ddp_pm_schedule_rec.whichever_first := p7_a27;
    ddp_pm_schedule_rec.include_manual := p7_a28;
    ddp_pm_schedule_rec.set_name_id := p7_a29;
    ddp_pm_schedule_rec.scheduling_method_code := p7_a30;
    ddp_pm_schedule_rec.type_code := p7_a31;
    ddp_pm_schedule_rec.next_service_start_date := p7_a32;
    ddp_pm_schedule_rec.next_service_end_date := p7_a33;
    ddp_pm_schedule_rec.source_tmpl_id := p7_a34;
    ddp_pm_schedule_rec.auto_instantiation_flag := p7_a35;
    ddp_pm_schedule_rec.name := p7_a36;
    ddp_pm_schedule_rec.tmpl_flag := p7_a37;
    ddp_pm_schedule_rec.generate_wo_status := p7_a38;
    ddp_pm_schedule_rec.interval_per_cycle := p7_a39;
    ddp_pm_schedule_rec.current_cycle := p7_a40;
    ddp_pm_schedule_rec.current_seq := p7_a41;
    ddp_pm_schedule_rec.current_wo_seq := p7_a42;
    ddp_pm_schedule_rec.base_date := p7_a43;
    ddp_pm_schedule_rec.base_reading := p7_a44;
    ddp_pm_schedule_rec.eam_last_cyclic_act := p7_a45;
    ddp_pm_schedule_rec.maintenance_object_id := p7_a46;
    ddp_pm_schedule_rec.maintenance_object_type := p7_a47;

    eam_pmdef_pub_w.rosetta_table_copy_in_p2(ddp_pm_activities_tbl, p8_a0
      , p8_a1
      , p8_a2
      , p8_a3
      , p8_a4
      , p8_a5
      , p8_a6
      );

    eam_pmdef_pub_w.rosetta_table_copy_in_p4(ddp_pm_day_interval_rules_tbl, p9_a0
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
      );

    eam_pmdef_pub_w.rosetta_table_copy_in_p4(ddp_pm_runtime_rules_tbl, p10_a0
      , p10_a1
      , p10_a2
      , p10_a3
      , p10_a4
      , p10_a5
      , p10_a6
      , p10_a7
      , p10_a8
      , p10_a9
      , p10_a10
      , p10_a11
      , p10_a12
      );

    eam_pmdef_pub_w.rosetta_table_copy_in_p4(ddp_pm_list_date_rules_tbl, p11_a0
      , p11_a1
      , p11_a2
      , p11_a3
      , p11_a4
      , p11_a5
      , p11_a6
      , p11_a7
      , p11_a8
      , p11_a9
      , p11_a10
      , p11_a11
      , p11_a12
      );

    -- here's the delegated call to the old PL/SQL routine
    eam_pmdef_pub.update_pm_def(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_pm_schedule_rec,
      ddp_pm_activities_tbl,
      ddp_pm_day_interval_rules_tbl,
      ddp_pm_runtime_rules_tbl,
      ddp_pm_list_date_rules_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any











  end;

  procedure validate_pm_header(p0_a0  NUMBER
    , p0_a1  NUMBER
    , p0_a2  VARCHAR2
    , p0_a3  DATE
    , p0_a4  DATE
    , p0_a5  NUMBER
    , p0_a6  NUMBER
    , p0_a7  VARCHAR2
    , p0_a8  VARCHAR2
    , p0_a9  VARCHAR2
    , p0_a10  VARCHAR2
    , p0_a11  VARCHAR2
    , p0_a12  VARCHAR2
    , p0_a13  VARCHAR2
    , p0_a14  VARCHAR2
    , p0_a15  VARCHAR2
    , p0_a16  VARCHAR2
    , p0_a17  VARCHAR2
    , p0_a18  VARCHAR2
    , p0_a19  VARCHAR2
    , p0_a20  VARCHAR2
    , p0_a21  VARCHAR2
    , p0_a22  VARCHAR2
    , p0_a23  NUMBER
    , p0_a24  VARCHAR2
    , p0_a25  VARCHAR2
    , p0_a26  VARCHAR2
    , p0_a27  VARCHAR2
    , p0_a28  VARCHAR2
    , p0_a29  NUMBER
    , p0_a30  NUMBER
    , p0_a31  NUMBER
    , p0_a32  DATE
    , p0_a33  DATE
    , p0_a34  NUMBER
    , p0_a35  VARCHAR2
    , p0_a36  VARCHAR2
    , p0_a37  VARCHAR2
    , p0_a38  NUMBER
    , p0_a39  NUMBER
    , p0_a40  NUMBER
    , p0_a41  NUMBER
    , p0_a42  NUMBER
    , p0_a43  DATE
    , p0_a44  NUMBER
    , p0_a45  NUMBER
    , p0_a46  NUMBER
    , p0_a47  NUMBER
    , x_reason_failed out nocopy  VARCHAR2
    , ddrosetta_retval_bool OUT NOCOPY NUMBER
  )

  as
    ddp_pm_schedule_rec eam_pmdef_pub.pm_scheduling_rec_type;
    ddindx binary_integer; indx binary_integer;
    ddrosetta_retval boolean;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_pm_schedule_rec.pm_schedule_id := p0_a0;
    ddp_pm_schedule_rec.activity_association_id := p0_a1;
    ddp_pm_schedule_rec.non_scheduled_flag := p0_a2;
    ddp_pm_schedule_rec.from_effective_date := p0_a3;
    ddp_pm_schedule_rec.to_effective_date := p0_a4;
    ddp_pm_schedule_rec.rescheduling_point := p0_a5;
    ddp_pm_schedule_rec.lead_time := p0_a6;
    ddp_pm_schedule_rec.attribute_category := p0_a7;
    ddp_pm_schedule_rec.attribute1 := p0_a8;
    ddp_pm_schedule_rec.attribute2 := p0_a9;
    ddp_pm_schedule_rec.attribute3 := p0_a10;
    ddp_pm_schedule_rec.attribute4 := p0_a11;
    ddp_pm_schedule_rec.attribute5 := p0_a12;
    ddp_pm_schedule_rec.attribute6 := p0_a13;
    ddp_pm_schedule_rec.attribute7 := p0_a14;
    ddp_pm_schedule_rec.attribute8 := p0_a15;
    ddp_pm_schedule_rec.attribute9 := p0_a16;
    ddp_pm_schedule_rec.attribute10 := p0_a17;
    ddp_pm_schedule_rec.attribute11 := p0_a18;
    ddp_pm_schedule_rec.attribute12 := p0_a19;
    ddp_pm_schedule_rec.attribute13 := p0_a20;
    ddp_pm_schedule_rec.attribute14 := p0_a21;
    ddp_pm_schedule_rec.attribute15 := p0_a22;
    ddp_pm_schedule_rec.day_tolerance := p0_a23;
    ddp_pm_schedule_rec.source_code := p0_a24;
    ddp_pm_schedule_rec.source_line := p0_a25;
    ddp_pm_schedule_rec.default_implement := p0_a26;
    ddp_pm_schedule_rec.whichever_first := p0_a27;
    ddp_pm_schedule_rec.include_manual := p0_a28;
    ddp_pm_schedule_rec.set_name_id := p0_a29;
    ddp_pm_schedule_rec.scheduling_method_code := p0_a30;
    ddp_pm_schedule_rec.type_code := p0_a31;
    ddp_pm_schedule_rec.next_service_start_date := p0_a32;
    ddp_pm_schedule_rec.next_service_end_date := p0_a33;
    ddp_pm_schedule_rec.source_tmpl_id := p0_a34;
    ddp_pm_schedule_rec.auto_instantiation_flag := p0_a35;
    ddp_pm_schedule_rec.name := p0_a36;
    ddp_pm_schedule_rec.tmpl_flag := p0_a37;
    ddp_pm_schedule_rec.generate_wo_status := p0_a38;
    ddp_pm_schedule_rec.interval_per_cycle := p0_a39;
    ddp_pm_schedule_rec.current_cycle := p0_a40;
    ddp_pm_schedule_rec.current_seq := p0_a41;
    ddp_pm_schedule_rec.current_wo_seq := p0_a42;
    ddp_pm_schedule_rec.base_date := p0_a43;
    ddp_pm_schedule_rec.base_reading := p0_a44;
    ddp_pm_schedule_rec.eam_last_cyclic_act := p0_a45;
    ddp_pm_schedule_rec.maintenance_object_id := p0_a46;
    ddp_pm_schedule_rec.maintenance_object_type := p0_a47;


    -- here's the delegated call to the old PL/SQL routine
    ddrosetta_retval := eam_pmdef_pub.validate_pm_header(ddp_pm_schedule_rec,
      x_reason_failed);

    -- copy data back from the local variables to OUT or IN-OUT args, if any
    if ddrosetta_retval is null
      then ddrosetta_retval_bool := null;
    elsif ddrosetta_retval
      then ddrosetta_retval_bool := 1;
    else ddrosetta_retval_bool := 0;
    end if;

  end;

  procedure validate_pm_day_interval_rule(p0_a0  NUMBER
    , p0_a1  NUMBER
    , p0_a2  NUMBER
    , p0_a3  NUMBER
    , p0_a4  NUMBER
    , p0_a5  NUMBER
    , p0_a6  NUMBER
    , p0_a7  NUMBER
    , p0_a8  NUMBER
    , p0_a9  DATE
    , p0_a10  DATE
    , p0_a11  DATE
    , p0_a12  VARCHAR2
    , x_reason_failed out nocopy  VARCHAR2
    , ddrosetta_retval_bool OUT NOCOPY NUMBER
  )

  as
    ddp_pm_rule_rec eam_pmdef_pub.pm_rule_rec_type;
    ddindx binary_integer; indx binary_integer;
    ddrosetta_retval boolean;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_pm_rule_rec.rule_id := p0_a0;
    ddp_pm_rule_rec.pm_schedule_id := p0_a1;
    ddp_pm_rule_rec.rule_type := p0_a2;
    ddp_pm_rule_rec.day_interval := p0_a3;
    ddp_pm_rule_rec.meter_id := p0_a4;
    ddp_pm_rule_rec.runtime_interval := p0_a5;
    ddp_pm_rule_rec.last_service_reading := p0_a6;
    ddp_pm_rule_rec.effective_reading_from := p0_a7;
    ddp_pm_rule_rec.effective_reading_to := p0_a8;
    ddp_pm_rule_rec.effective_date_from := p0_a9;
    ddp_pm_rule_rec.effective_date_to := p0_a10;
    ddp_pm_rule_rec.list_date := p0_a11;
    ddp_pm_rule_rec.list_date_desc := p0_a12;


    -- here's the delegated call to the old PL/SQL routine
    ddrosetta_retval := eam_pmdef_pub.validate_pm_day_interval_rule(ddp_pm_rule_rec,
      x_reason_failed);

    -- copy data back from the local variables to OUT or IN-OUT args, if any
    if ddrosetta_retval is null
      then ddrosetta_retval_bool := null;
    elsif ddrosetta_retval
      then ddrosetta_retval_bool := 1;
    else ddrosetta_retval_bool := 0;
    end if;

  end;

  procedure validate_pm_runtime_rule(p0_a0  NUMBER
    , p0_a1  NUMBER
    , p0_a2  NUMBER
    , p0_a3  NUMBER
    , p0_a4  NUMBER
    , p0_a5  NUMBER
    , p0_a6  NUMBER
    , p0_a7  NUMBER
    , p0_a8  NUMBER
    , p0_a9  DATE
    , p0_a10  DATE
    , p0_a11  DATE
    , p0_a12  VARCHAR2
    , x_reason_failed out nocopy  VARCHAR2
    , ddrosetta_retval_bool OUT NOCOPY NUMBER
  )

  as
    ddp_pm_rule_rec eam_pmdef_pub.pm_rule_rec_type;
    ddindx binary_integer; indx binary_integer;
    ddrosetta_retval boolean;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_pm_rule_rec.rule_id := p0_a0;
    ddp_pm_rule_rec.pm_schedule_id := p0_a1;
    ddp_pm_rule_rec.rule_type := p0_a2;
    ddp_pm_rule_rec.day_interval := p0_a3;
    ddp_pm_rule_rec.meter_id := p0_a4;
    ddp_pm_rule_rec.runtime_interval := p0_a5;
    ddp_pm_rule_rec.last_service_reading := p0_a6;
    ddp_pm_rule_rec.effective_reading_from := p0_a7;
    ddp_pm_rule_rec.effective_reading_to := p0_a8;
    ddp_pm_rule_rec.effective_date_from := p0_a9;
    ddp_pm_rule_rec.effective_date_to := p0_a10;
    ddp_pm_rule_rec.list_date := p0_a11;
    ddp_pm_rule_rec.list_date_desc := p0_a12;


    -- here's the delegated call to the old PL/SQL routine
    ddrosetta_retval := eam_pmdef_pub.validate_pm_runtime_rule(ddp_pm_rule_rec,
      x_reason_failed);

    -- copy data back from the local variables to OUT or IN-OUT args, if any
    if ddrosetta_retval is null
      then ddrosetta_retval_bool := null;
    elsif ddrosetta_retval
      then ddrosetta_retval_bool := 1;
    else ddrosetta_retval_bool := 0;
    end if;

  end;

  procedure validate_pm_list_date(p0_a0  NUMBER
    , p0_a1  NUMBER
    , p0_a2  NUMBER
    , p0_a3  NUMBER
    , p0_a4  NUMBER
    , p0_a5  NUMBER
    , p0_a6  NUMBER
    , p0_a7  NUMBER
    , p0_a8  NUMBER
    , p0_a9  DATE
    , p0_a10  DATE
    , p0_a11  DATE
    , p0_a12  VARCHAR2
    , x_reason_failed out nocopy  VARCHAR2
    , ddrosetta_retval_bool OUT NOCOPY NUMBER
  )

  as
    ddp_pm_rule_rec eam_pmdef_pub.pm_rule_rec_type;
    ddindx binary_integer; indx binary_integer;
    ddrosetta_retval boolean;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_pm_rule_rec.rule_id := p0_a0;
    ddp_pm_rule_rec.pm_schedule_id := p0_a1;
    ddp_pm_rule_rec.rule_type := p0_a2;
    ddp_pm_rule_rec.day_interval := p0_a3;
    ddp_pm_rule_rec.meter_id := p0_a4;
    ddp_pm_rule_rec.runtime_interval := p0_a5;
    ddp_pm_rule_rec.last_service_reading := p0_a6;
    ddp_pm_rule_rec.effective_reading_from := p0_a7;
    ddp_pm_rule_rec.effective_reading_to := p0_a8;
    ddp_pm_rule_rec.effective_date_from := p0_a9;
    ddp_pm_rule_rec.effective_date_to := p0_a10;
    ddp_pm_rule_rec.list_date := p0_a11;
    ddp_pm_rule_rec.list_date_desc := p0_a12;


    -- here's the delegated call to the old PL/SQL routine
    ddrosetta_retval := eam_pmdef_pub.validate_pm_list_date(ddp_pm_rule_rec,
      x_reason_failed);

    -- copy data back from the local variables to OUT or IN-OUT args, if any
    if ddrosetta_retval is null
      then ddrosetta_retval_bool := null;
    elsif ddrosetta_retval
      then ddrosetta_retval_bool := 1;
    else ddrosetta_retval_bool := 0;
    end if;

  end;

  procedure validate_pm_day_interval_rules(p0_a0 JTF_NUMBER_TABLE
    , p0_a1 JTF_NUMBER_TABLE
    , p0_a2 JTF_NUMBER_TABLE
    , p0_a3 JTF_NUMBER_TABLE
    , p0_a4 JTF_NUMBER_TABLE
    , p0_a5 JTF_NUMBER_TABLE
    , p0_a6 JTF_NUMBER_TABLE
    , p0_a7 JTF_NUMBER_TABLE
    , p0_a8 JTF_NUMBER_TABLE
    , p0_a9 JTF_DATE_TABLE
    , p0_a10 JTF_DATE_TABLE
    , p0_a11 JTF_DATE_TABLE
    , p0_a12 JTF_VARCHAR2_TABLE_100
    , x_reason_failed out nocopy  VARCHAR2
    , ddrosetta_retval_bool OUT NOCOPY NUMBER
  )

  as
    ddp_pm_rules_tbl eam_pmdef_pub.pm_rule_tbl_type;
    ddindx binary_integer; indx binary_integer;
    ddrosetta_retval boolean;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    eam_pmdef_pub_w.rosetta_table_copy_in_p4(ddp_pm_rules_tbl, p0_a0
      , p0_a1
      , p0_a2
      , p0_a3
      , p0_a4
      , p0_a5
      , p0_a6
      , p0_a7
      , p0_a8
      , p0_a9
      , p0_a10
      , p0_a11
      , p0_a12
      );


    -- here's the delegated call to the old PL/SQL routine
    ddrosetta_retval := eam_pmdef_pub.validate_pm_day_interval_rules(ddp_pm_rules_tbl,
      x_reason_failed);

    -- copy data back from the local variables to OUT or IN-OUT args, if any
    if ddrosetta_retval is null
      then ddrosetta_retval_bool := null;
    elsif ddrosetta_retval
      then ddrosetta_retval_bool := 1;
    else ddrosetta_retval_bool := 0;
    end if;

  end;

  procedure validate_pm_runtime_rules(p0_a0 JTF_NUMBER_TABLE
    , p0_a1 JTF_NUMBER_TABLE
    , p0_a2 JTF_NUMBER_TABLE
    , p0_a3 JTF_NUMBER_TABLE
    , p0_a4 JTF_NUMBER_TABLE
    , p0_a5 JTF_NUMBER_TABLE
    , p0_a6 JTF_NUMBER_TABLE
    , p0_a7 JTF_NUMBER_TABLE
    , p0_a8 JTF_NUMBER_TABLE
    , p0_a9 JTF_DATE_TABLE
    , p0_a10 JTF_DATE_TABLE
    , p0_a11 JTF_DATE_TABLE
    , p0_a12 JTF_VARCHAR2_TABLE_100
    , x_reason_failed out nocopy  VARCHAR2
    , ddrosetta_retval_bool OUT NOCOPY NUMBER
  )

  as
    ddp_pm_rules_tbl eam_pmdef_pub.pm_rule_tbl_type;
    ddindx binary_integer; indx binary_integer;
    ddrosetta_retval boolean;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    eam_pmdef_pub_w.rosetta_table_copy_in_p4(ddp_pm_rules_tbl, p0_a0
      , p0_a1
      , p0_a2
      , p0_a3
      , p0_a4
      , p0_a5
      , p0_a6
      , p0_a7
      , p0_a8
      , p0_a9
      , p0_a10
      , p0_a11
      , p0_a12
      );


    -- here's the delegated call to the old PL/SQL routine
    ddrosetta_retval := eam_pmdef_pub.validate_pm_runtime_rules(ddp_pm_rules_tbl,
      x_reason_failed);

    -- copy data back from the local variables to OUT or IN-OUT args, if any
    if ddrosetta_retval is null
      then ddrosetta_retval_bool := null;
    elsif ddrosetta_retval
      then ddrosetta_retval_bool := 1;
    else ddrosetta_retval_bool := 0;
    end if;

  end;

  procedure validate_pm_list_date_rules(p0_a0 JTF_NUMBER_TABLE
    , p0_a1 JTF_NUMBER_TABLE
    , p0_a2 JTF_NUMBER_TABLE
    , p0_a3 JTF_NUMBER_TABLE
    , p0_a4 JTF_NUMBER_TABLE
    , p0_a5 JTF_NUMBER_TABLE
    , p0_a6 JTF_NUMBER_TABLE
    , p0_a7 JTF_NUMBER_TABLE
    , p0_a8 JTF_NUMBER_TABLE
    , p0_a9 JTF_DATE_TABLE
    , p0_a10 JTF_DATE_TABLE
    , p0_a11 JTF_DATE_TABLE
    , p0_a12 JTF_VARCHAR2_TABLE_100
    , x_reason_failed out nocopy  VARCHAR2
    , ddrosetta_retval_bool OUT NOCOPY NUMBER
  )

  as
    ddp_pm_rules_tbl eam_pmdef_pub.pm_rule_tbl_type;
    ddindx binary_integer; indx binary_integer;
    ddrosetta_retval boolean;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    eam_pmdef_pub_w.rosetta_table_copy_in_p4(ddp_pm_rules_tbl, p0_a0
      , p0_a1
      , p0_a2
      , p0_a3
      , p0_a4
      , p0_a5
      , p0_a6
      , p0_a7
      , p0_a8
      , p0_a9
      , p0_a10
      , p0_a11
      , p0_a12
      );


    -- here's the delegated call to the old PL/SQL routine
    ddrosetta_retval := eam_pmdef_pub.validate_pm_list_date_rules(ddp_pm_rules_tbl,
      x_reason_failed);

    -- copy data back from the local variables to OUT or IN-OUT args, if any
    if ddrosetta_retval is null
      then ddrosetta_retval_bool := null;
    elsif ddrosetta_retval
      then ddrosetta_retval_bool := 1;
    else ddrosetta_retval_bool := 0;
    end if;

  end;

  procedure validate_pm_header_and_rules(p0_a0  NUMBER
    , p0_a1  NUMBER
    , p0_a2  VARCHAR2
    , p0_a3  DATE
    , p0_a4  DATE
    , p0_a5  NUMBER
    , p0_a6  NUMBER
    , p0_a7  VARCHAR2
    , p0_a8  VARCHAR2
    , p0_a9  VARCHAR2
    , p0_a10  VARCHAR2
    , p0_a11  VARCHAR2
    , p0_a12  VARCHAR2
    , p0_a13  VARCHAR2
    , p0_a14  VARCHAR2
    , p0_a15  VARCHAR2
    , p0_a16  VARCHAR2
    , p0_a17  VARCHAR2
    , p0_a18  VARCHAR2
    , p0_a19  VARCHAR2
    , p0_a20  VARCHAR2
    , p0_a21  VARCHAR2
    , p0_a22  VARCHAR2
    , p0_a23  NUMBER
    , p0_a24  VARCHAR2
    , p0_a25  VARCHAR2
    , p0_a26  VARCHAR2
    , p0_a27  VARCHAR2
    , p0_a28  VARCHAR2
    , p0_a29  NUMBER
    , p0_a30  NUMBER
    , p0_a31  NUMBER
    , p0_a32  DATE
    , p0_a33  DATE
    , p0_a34  NUMBER
    , p0_a35  VARCHAR2
    , p0_a36  VARCHAR2
    , p0_a37  VARCHAR2
    , p0_a38  NUMBER
    , p0_a39  NUMBER
    , p0_a40  NUMBER
    , p0_a41  NUMBER
    , p0_a42  NUMBER
    , p0_a43  DATE
    , p0_a44  NUMBER
    , p0_a45  NUMBER
    , p0_a46  NUMBER
    , p0_a47  NUMBER
    , p1_a0 JTF_NUMBER_TABLE
    , p1_a1 JTF_NUMBER_TABLE
    , p1_a2 JTF_NUMBER_TABLE
    , p1_a3 JTF_NUMBER_TABLE
    , p1_a4 JTF_NUMBER_TABLE
    , p1_a5 JTF_NUMBER_TABLE
    , p1_a6 JTF_NUMBER_TABLE
    , p1_a7 JTF_NUMBER_TABLE
    , p1_a8 JTF_NUMBER_TABLE
    , p1_a9 JTF_DATE_TABLE
    , p1_a10 JTF_DATE_TABLE
    , p1_a11 JTF_DATE_TABLE
    , p1_a12 JTF_VARCHAR2_TABLE_100
    , p2_a0 JTF_NUMBER_TABLE
    , p2_a1 JTF_NUMBER_TABLE
    , p2_a2 JTF_NUMBER_TABLE
    , p2_a3 JTF_NUMBER_TABLE
    , p2_a4 JTF_NUMBER_TABLE
    , p2_a5 JTF_NUMBER_TABLE
    , p2_a6 JTF_NUMBER_TABLE
    , p2_a7 JTF_NUMBER_TABLE
    , p2_a8 JTF_NUMBER_TABLE
    , p2_a9 JTF_DATE_TABLE
    , p2_a10 JTF_DATE_TABLE
    , p2_a11 JTF_DATE_TABLE
    , p2_a12 JTF_VARCHAR2_TABLE_100
    , p3_a0 JTF_NUMBER_TABLE
    , p3_a1 JTF_NUMBER_TABLE
    , p3_a2 JTF_NUMBER_TABLE
    , p3_a3 JTF_NUMBER_TABLE
    , p3_a4 JTF_NUMBER_TABLE
    , p3_a5 JTF_NUMBER_TABLE
    , p3_a6 JTF_NUMBER_TABLE
    , p3_a7 JTF_NUMBER_TABLE
    , p3_a8 JTF_NUMBER_TABLE
    , p3_a9 JTF_DATE_TABLE
    , p3_a10 JTF_DATE_TABLE
    , p3_a11 JTF_DATE_TABLE
    , p3_a12 JTF_VARCHAR2_TABLE_100
    , x_reason_failed out nocopy  VARCHAR2
    , ddrosetta_retval_bool OUT NOCOPY NUMBER
  )

  as
    ddp_pm_schedule_rec eam_pmdef_pub.pm_scheduling_rec_type;
    ddp_pm_day_interval_rules_tbl eam_pmdef_pub.pm_rule_tbl_type;
    ddp_pm_runtime_rules_tbl eam_pmdef_pub.pm_rule_tbl_type;
    ddp_pm_list_date_rules_tbl eam_pmdef_pub.pm_rule_tbl_type;
    ddindx binary_integer; indx binary_integer;
    ddrosetta_retval boolean;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_pm_schedule_rec.pm_schedule_id := p0_a0;
    ddp_pm_schedule_rec.activity_association_id := p0_a1;
    ddp_pm_schedule_rec.non_scheduled_flag := p0_a2;
    ddp_pm_schedule_rec.from_effective_date := p0_a3;
    ddp_pm_schedule_rec.to_effective_date := p0_a4;
    ddp_pm_schedule_rec.rescheduling_point := p0_a5;
    ddp_pm_schedule_rec.lead_time := p0_a6;
    ddp_pm_schedule_rec.attribute_category := p0_a7;
    ddp_pm_schedule_rec.attribute1 := p0_a8;
    ddp_pm_schedule_rec.attribute2 := p0_a9;
    ddp_pm_schedule_rec.attribute3 := p0_a10;
    ddp_pm_schedule_rec.attribute4 := p0_a11;
    ddp_pm_schedule_rec.attribute5 := p0_a12;
    ddp_pm_schedule_rec.attribute6 := p0_a13;
    ddp_pm_schedule_rec.attribute7 := p0_a14;
    ddp_pm_schedule_rec.attribute8 := p0_a15;
    ddp_pm_schedule_rec.attribute9 := p0_a16;
    ddp_pm_schedule_rec.attribute10 := p0_a17;
    ddp_pm_schedule_rec.attribute11 := p0_a18;
    ddp_pm_schedule_rec.attribute12 := p0_a19;
    ddp_pm_schedule_rec.attribute13 := p0_a20;
    ddp_pm_schedule_rec.attribute14 := p0_a21;
    ddp_pm_schedule_rec.attribute15 := p0_a22;
    ddp_pm_schedule_rec.day_tolerance := p0_a23;
    ddp_pm_schedule_rec.source_code := p0_a24;
    ddp_pm_schedule_rec.source_line := p0_a25;
    ddp_pm_schedule_rec.default_implement := p0_a26;
    ddp_pm_schedule_rec.whichever_first := p0_a27;
    ddp_pm_schedule_rec.include_manual := p0_a28;
    ddp_pm_schedule_rec.set_name_id := p0_a29;
    ddp_pm_schedule_rec.scheduling_method_code := p0_a30;
    ddp_pm_schedule_rec.type_code := p0_a31;
    ddp_pm_schedule_rec.next_service_start_date := p0_a32;
    ddp_pm_schedule_rec.next_service_end_date := p0_a33;
    ddp_pm_schedule_rec.source_tmpl_id := p0_a34;
    ddp_pm_schedule_rec.auto_instantiation_flag := p0_a35;
    ddp_pm_schedule_rec.name := p0_a36;
    ddp_pm_schedule_rec.tmpl_flag := p0_a37;
    ddp_pm_schedule_rec.generate_wo_status := p0_a38;
    ddp_pm_schedule_rec.interval_per_cycle := p0_a39;
    ddp_pm_schedule_rec.current_cycle := p0_a40;
    ddp_pm_schedule_rec.current_seq := p0_a41;
    ddp_pm_schedule_rec.current_wo_seq := p0_a42;
    ddp_pm_schedule_rec.base_date := p0_a43;
    ddp_pm_schedule_rec.base_reading := p0_a44;
    ddp_pm_schedule_rec.eam_last_cyclic_act := p0_a45;
    ddp_pm_schedule_rec.maintenance_object_id := p0_a46;
    ddp_pm_schedule_rec.maintenance_object_type := p0_a47;

    eam_pmdef_pub_w.rosetta_table_copy_in_p4(ddp_pm_day_interval_rules_tbl, p1_a0
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
      );

    eam_pmdef_pub_w.rosetta_table_copy_in_p4(ddp_pm_runtime_rules_tbl, p2_a0
      , p2_a1
      , p2_a2
      , p2_a3
      , p2_a4
      , p2_a5
      , p2_a6
      , p2_a7
      , p2_a8
      , p2_a9
      , p2_a10
      , p2_a11
      , p2_a12
      );

    eam_pmdef_pub_w.rosetta_table_copy_in_p4(ddp_pm_list_date_rules_tbl, p3_a0
      , p3_a1
      , p3_a2
      , p3_a3
      , p3_a4
      , p3_a5
      , p3_a6
      , p3_a7
      , p3_a8
      , p3_a9
      , p3_a10
      , p3_a11
      , p3_a12
      );


    -- here's the delegated call to the old PL/SQL routine
    ddrosetta_retval := eam_pmdef_pub.validate_pm_header_and_rules(ddp_pm_schedule_rec,
      ddp_pm_day_interval_rules_tbl,
      ddp_pm_runtime_rules_tbl,
      ddp_pm_list_date_rules_tbl,
      x_reason_failed);

    -- copy data back from the local variables to OUT or IN-OUT args, if any
    if ddrosetta_retval is null
      then ddrosetta_retval_bool := null;
    elsif ddrosetta_retval
      then ddrosetta_retval_bool := 1;
    else ddrosetta_retval_bool := 0;
    end if;




  end;

  procedure validate_pm_activity(p0_a0  NUMBER
    , p0_a1  NUMBER
    , p0_a2  NUMBER
    , p0_a3  VARCHAR2
    , p0_a4  NUMBER
    , p0_a5  DATE
    , p0_a6  DATE
    , p1_a0 JTF_NUMBER_TABLE
    , p1_a1 JTF_NUMBER_TABLE
    , p1_a2 JTF_NUMBER_TABLE
    , p1_a3 JTF_NUMBER_TABLE
    , p1_a4 JTF_NUMBER_TABLE
    , p1_a5 JTF_NUMBER_TABLE
    , p1_a6 JTF_NUMBER_TABLE
    , p1_a7 JTF_NUMBER_TABLE
    , p1_a8 JTF_NUMBER_TABLE
    , p1_a9 JTF_DATE_TABLE
    , p1_a10 JTF_DATE_TABLE
    , p1_a11 JTF_DATE_TABLE
    , p1_a12 JTF_VARCHAR2_TABLE_100
    , p2_a0  NUMBER
    , p2_a1  NUMBER
    , p2_a2  VARCHAR2
    , p2_a3  DATE
    , p2_a4  DATE
    , p2_a5  NUMBER
    , p2_a6  NUMBER
    , p2_a7  VARCHAR2
    , p2_a8  VARCHAR2
    , p2_a9  VARCHAR2
    , p2_a10  VARCHAR2
    , p2_a11  VARCHAR2
    , p2_a12  VARCHAR2
    , p2_a13  VARCHAR2
    , p2_a14  VARCHAR2
    , p2_a15  VARCHAR2
    , p2_a16  VARCHAR2
    , p2_a17  VARCHAR2
    , p2_a18  VARCHAR2
    , p2_a19  VARCHAR2
    , p2_a20  VARCHAR2
    , p2_a21  VARCHAR2
    , p2_a22  VARCHAR2
    , p2_a23  NUMBER
    , p2_a24  VARCHAR2
    , p2_a25  VARCHAR2
    , p2_a26  VARCHAR2
    , p2_a27  VARCHAR2
    , p2_a28  VARCHAR2
    , p2_a29  NUMBER
    , p2_a30  NUMBER
    , p2_a31  NUMBER
    , p2_a32  DATE
    , p2_a33  DATE
    , p2_a34  NUMBER
    , p2_a35  VARCHAR2
    , p2_a36  VARCHAR2
    , p2_a37  VARCHAR2
    , p2_a38  NUMBER
    , p2_a39  NUMBER
    , p2_a40  NUMBER
    , p2_a41  NUMBER
    , p2_a42  NUMBER
    , p2_a43  DATE
    , p2_a44  NUMBER
    , p2_a45  NUMBER
    , p2_a46  NUMBER
    , p2_a47  NUMBER
    , x_reason_failed out nocopy  VARCHAR2
    , x_message out nocopy  VARCHAR2
    , ddrosetta_retval_bool OUT NOCOPY NUMBER
  )

  as
    ddp_pm_activity_grp_rec eam_pmdef_pub.pm_activities_grp_rec_type;
    ddp_pm_runtime_rules_tbl eam_pmdef_pub.pm_rule_tbl_type;
    ddp_pm_schedule_rec eam_pmdef_pub.pm_scheduling_rec_type;
    ddindx binary_integer; indx binary_integer;
    ddrosetta_retval boolean;
    l_activities varchar2(80);
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_pm_activity_grp_rec.pm_schedule_id := p0_a0;
    ddp_pm_activity_grp_rec.activity_association_id := p0_a1;
    ddp_pm_activity_grp_rec.interval_multiple := p0_a2;
    ddp_pm_activity_grp_rec.allow_repeat_in_cycle := p0_a3;
    ddp_pm_activity_grp_rec.day_tolerance := p0_a4;
    ddp_pm_activity_grp_rec.next_service_start_date := p0_a5;
    ddp_pm_activity_grp_rec.next_service_end_date := p0_a6;

    eam_pmdef_pub_w.rosetta_table_copy_in_p4(ddp_pm_runtime_rules_tbl, p1_a0
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
      );

    ddp_pm_schedule_rec.pm_schedule_id := p2_a0;
    ddp_pm_schedule_rec.activity_association_id := p2_a1;
    ddp_pm_schedule_rec.non_scheduled_flag := p2_a2;
    ddp_pm_schedule_rec.from_effective_date := p2_a3;
    ddp_pm_schedule_rec.to_effective_date := p2_a4;
    ddp_pm_schedule_rec.rescheduling_point := p2_a5;
    ddp_pm_schedule_rec.lead_time := p2_a6;
    ddp_pm_schedule_rec.attribute_category := p2_a7;
    ddp_pm_schedule_rec.attribute1 := p2_a8;
    ddp_pm_schedule_rec.attribute2 := p2_a9;
    ddp_pm_schedule_rec.attribute3 := p2_a10;
    ddp_pm_schedule_rec.attribute4 := p2_a11;
    ddp_pm_schedule_rec.attribute5 := p2_a12;
    ddp_pm_schedule_rec.attribute6 := p2_a13;
    ddp_pm_schedule_rec.attribute7 := p2_a14;
    ddp_pm_schedule_rec.attribute8 := p2_a15;
    ddp_pm_schedule_rec.attribute9 := p2_a16;
    ddp_pm_schedule_rec.attribute10 := p2_a17;
    ddp_pm_schedule_rec.attribute11 := p2_a18;
    ddp_pm_schedule_rec.attribute12 := p2_a19;
    ddp_pm_schedule_rec.attribute13 := p2_a20;
    ddp_pm_schedule_rec.attribute14 := p2_a21;
    ddp_pm_schedule_rec.attribute15 := p2_a22;
    ddp_pm_schedule_rec.day_tolerance := p2_a23;
    ddp_pm_schedule_rec.source_code := p2_a24;
    ddp_pm_schedule_rec.source_line := p2_a25;
    ddp_pm_schedule_rec.default_implement := p2_a26;
    ddp_pm_schedule_rec.whichever_first := p2_a27;
    ddp_pm_schedule_rec.include_manual := p2_a28;
    ddp_pm_schedule_rec.set_name_id := p2_a29;
    ddp_pm_schedule_rec.scheduling_method_code := p2_a30;
    ddp_pm_schedule_rec.type_code := p2_a31;
    ddp_pm_schedule_rec.next_service_start_date := p2_a32;
    ddp_pm_schedule_rec.next_service_end_date := p2_a33;
    ddp_pm_schedule_rec.source_tmpl_id := p2_a34;
    ddp_pm_schedule_rec.auto_instantiation_flag := p2_a35;
    ddp_pm_schedule_rec.name := p2_a36;
    ddp_pm_schedule_rec.tmpl_flag := p2_a37;
    ddp_pm_schedule_rec.generate_wo_status := p2_a38;
    ddp_pm_schedule_rec.interval_per_cycle := p2_a39;
    ddp_pm_schedule_rec.current_cycle := p2_a40;
    ddp_pm_schedule_rec.current_seq := p2_a41;
    ddp_pm_schedule_rec.current_wo_seq := p2_a42;
    ddp_pm_schedule_rec.base_date := p2_a43;
    ddp_pm_schedule_rec.base_reading := p2_a44;
    ddp_pm_schedule_rec.eam_last_cyclic_act := p2_a45;
    ddp_pm_schedule_rec.maintenance_object_id := p2_a46;
    ddp_pm_schedule_rec.maintenance_object_type := p2_a47;



    -- here's the delegated call to the old PL/SQL routine
    ddrosetta_retval := eam_pmdef_pub.validate_pm_activity(ddp_pm_activity_grp_rec,
      ddp_pm_runtime_rules_tbl,
      ddp_pm_schedule_rec,
      x_reason_failed,
      x_message,
      l_activities);

    -- copy data back from the local variables to OUT or IN-OUT args, if any
    if ddrosetta_retval is null
      then ddrosetta_retval_bool := null;
    elsif ddrosetta_retval
      then ddrosetta_retval_bool := 1;
    else ddrosetta_retval_bool := 0;
    end if;




  end;

  procedure validate_pm_activity(p0_a0  NUMBER
    , p0_a1  NUMBER
    , p0_a2  NUMBER
    , p0_a3  VARCHAR2
    , p0_a4  NUMBER
    , p0_a5  DATE
    , p0_a6  DATE
    , p1_a0  NUMBER
    , p1_a1  NUMBER
    , p1_a2  VARCHAR2
    , p1_a3  DATE
    , p1_a4  DATE
    , p1_a5  NUMBER
    , p1_a6  NUMBER
    , p1_a7  VARCHAR2
    , p1_a8  VARCHAR2
    , p1_a9  VARCHAR2
    , p1_a10  VARCHAR2
    , p1_a11  VARCHAR2
    , p1_a12  VARCHAR2
    , p1_a13  VARCHAR2
    , p1_a14  VARCHAR2
    , p1_a15  VARCHAR2
    , p1_a16  VARCHAR2
    , p1_a17  VARCHAR2
    , p1_a18  VARCHAR2
    , p1_a19  VARCHAR2
    , p1_a20  VARCHAR2
    , p1_a21  VARCHAR2
    , p1_a22  VARCHAR2
    , p1_a23  NUMBER
    , p1_a24  VARCHAR2
    , p1_a25  VARCHAR2
    , p1_a26  VARCHAR2
    , p1_a27  VARCHAR2
    , p1_a28  VARCHAR2
    , p1_a29  NUMBER
    , p1_a30  NUMBER
    , p1_a31  NUMBER
    , p1_a32  DATE
    , p1_a33  DATE
    , p1_a34  NUMBER
    , p1_a35  VARCHAR2
    , p1_a36  VARCHAR2
    , p1_a37  VARCHAR2
    , p1_a38  NUMBER
    , p1_a39  NUMBER
    , p1_a40  NUMBER
    , p1_a41  NUMBER
    , p1_a42  NUMBER
    , p1_a43  DATE
    , p1_a44  NUMBER
    , p1_a45  NUMBER
    , p1_a46  NUMBER
    , p1_a47  NUMBER
    , x_reason_failed out nocopy  VARCHAR2
    , ddrosetta_retval_bool OUT NOCOPY NUMBER
  )

  as
    ddp_pm_activity_grp_rec eam_pmdef_pub.pm_activities_grp_rec_type;
    ddp_pm_schedule_rec eam_pmdef_pub.pm_scheduling_rec_type;
    ddindx binary_integer; indx binary_integer;
    ddrosetta_retval boolean;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_pm_activity_grp_rec.pm_schedule_id := p0_a0;
    ddp_pm_activity_grp_rec.activity_association_id := p0_a1;
    ddp_pm_activity_grp_rec.interval_multiple := p0_a2;
    ddp_pm_activity_grp_rec.allow_repeat_in_cycle := p0_a3;
    ddp_pm_activity_grp_rec.day_tolerance := p0_a4;
    ddp_pm_activity_grp_rec.next_service_start_date := p0_a5;
    ddp_pm_activity_grp_rec.next_service_end_date := p0_a6;

    ddp_pm_schedule_rec.pm_schedule_id := p1_a0;
    ddp_pm_schedule_rec.activity_association_id := p1_a1;
    ddp_pm_schedule_rec.non_scheduled_flag := p1_a2;
    ddp_pm_schedule_rec.from_effective_date := p1_a3;
    ddp_pm_schedule_rec.to_effective_date := p1_a4;
    ddp_pm_schedule_rec.rescheduling_point := p1_a5;
    ddp_pm_schedule_rec.lead_time := p1_a6;
    ddp_pm_schedule_rec.attribute_category := p1_a7;
    ddp_pm_schedule_rec.attribute1 := p1_a8;
    ddp_pm_schedule_rec.attribute2 := p1_a9;
    ddp_pm_schedule_rec.attribute3 := p1_a10;
    ddp_pm_schedule_rec.attribute4 := p1_a11;
    ddp_pm_schedule_rec.attribute5 := p1_a12;
    ddp_pm_schedule_rec.attribute6 := p1_a13;
    ddp_pm_schedule_rec.attribute7 := p1_a14;
    ddp_pm_schedule_rec.attribute8 := p1_a15;
    ddp_pm_schedule_rec.attribute9 := p1_a16;
    ddp_pm_schedule_rec.attribute10 := p1_a17;
    ddp_pm_schedule_rec.attribute11 := p1_a18;
    ddp_pm_schedule_rec.attribute12 := p1_a19;
    ddp_pm_schedule_rec.attribute13 := p1_a20;
    ddp_pm_schedule_rec.attribute14 := p1_a21;
    ddp_pm_schedule_rec.attribute15 := p1_a22;
    ddp_pm_schedule_rec.day_tolerance := p1_a23;
    ddp_pm_schedule_rec.source_code := p1_a24;
    ddp_pm_schedule_rec.source_line := p1_a25;
    ddp_pm_schedule_rec.default_implement := p1_a26;
    ddp_pm_schedule_rec.whichever_first := p1_a27;
    ddp_pm_schedule_rec.include_manual := p1_a28;
    ddp_pm_schedule_rec.set_name_id := p1_a29;
    ddp_pm_schedule_rec.scheduling_method_code := p1_a30;
    ddp_pm_schedule_rec.type_code := p1_a31;
    ddp_pm_schedule_rec.next_service_start_date := p1_a32;
    ddp_pm_schedule_rec.next_service_end_date := p1_a33;
    ddp_pm_schedule_rec.source_tmpl_id := p1_a34;
    ddp_pm_schedule_rec.auto_instantiation_flag := p1_a35;
    ddp_pm_schedule_rec.name := p1_a36;
    ddp_pm_schedule_rec.tmpl_flag := p1_a37;
    ddp_pm_schedule_rec.generate_wo_status := p1_a38;
    ddp_pm_schedule_rec.interval_per_cycle := p1_a39;
    ddp_pm_schedule_rec.current_cycle := p1_a40;
    ddp_pm_schedule_rec.current_seq := p1_a41;
    ddp_pm_schedule_rec.current_wo_seq := p1_a42;
    ddp_pm_schedule_rec.base_date := p1_a43;
    ddp_pm_schedule_rec.base_reading := p1_a44;
    ddp_pm_schedule_rec.eam_last_cyclic_act := p1_a45;
    ddp_pm_schedule_rec.maintenance_object_id := p1_a46;
    ddp_pm_schedule_rec.maintenance_object_type := p1_a47;


    -- here's the delegated call to the old PL/SQL routine
    ddrosetta_retval := eam_pmdef_pub.validate_pm_activity(ddp_pm_activity_grp_rec,
      ddp_pm_schedule_rec,
      x_reason_failed);

    -- copy data back from the local variables to OUT or IN-OUT args, if any
    if ddrosetta_retval is null
      then ddrosetta_retval_bool := null;
    elsif ddrosetta_retval
      then ddrosetta_retval_bool := 1;
    else ddrosetta_retval_bool := 0;
    end if;


  end;

  procedure validate_pm_activities(p0_a0 JTF_NUMBER_TABLE
    , p0_a1 JTF_NUMBER_TABLE
    , p0_a2 JTF_NUMBER_TABLE
    , p0_a3 JTF_VARCHAR2_TABLE_100
    , p0_a4 JTF_NUMBER_TABLE
    , p0_a5 JTF_DATE_TABLE
    , p0_a6 JTF_DATE_TABLE
    , p1_a0 JTF_NUMBER_TABLE
    , p1_a1 JTF_NUMBER_TABLE
    , p1_a2 JTF_NUMBER_TABLE
    , p1_a3 JTF_NUMBER_TABLE
    , p1_a4 JTF_NUMBER_TABLE
    , p1_a5 JTF_NUMBER_TABLE
    , p1_a6 JTF_NUMBER_TABLE
    , p1_a7 JTF_NUMBER_TABLE
    , p1_a8 JTF_NUMBER_TABLE
    , p1_a9 JTF_DATE_TABLE
    , p1_a10 JTF_DATE_TABLE
    , p1_a11 JTF_DATE_TABLE
    , p1_a12 JTF_VARCHAR2_TABLE_100
    , p2_a0  NUMBER
    , p2_a1  NUMBER
    , p2_a2  VARCHAR2
    , p2_a3  DATE
    , p2_a4  DATE
    , p2_a5  NUMBER
    , p2_a6  NUMBER
    , p2_a7  VARCHAR2
    , p2_a8  VARCHAR2
    , p2_a9  VARCHAR2
    , p2_a10  VARCHAR2
    , p2_a11  VARCHAR2
    , p2_a12  VARCHAR2
    , p2_a13  VARCHAR2
    , p2_a14  VARCHAR2
    , p2_a15  VARCHAR2
    , p2_a16  VARCHAR2
    , p2_a17  VARCHAR2
    , p2_a18  VARCHAR2
    , p2_a19  VARCHAR2
    , p2_a20  VARCHAR2
    , p2_a21  VARCHAR2
    , p2_a22  VARCHAR2
    , p2_a23  NUMBER
    , p2_a24  VARCHAR2
    , p2_a25  VARCHAR2
    , p2_a26  VARCHAR2
    , p2_a27  VARCHAR2
    , p2_a28  VARCHAR2
    , p2_a29  NUMBER
    , p2_a30  NUMBER
    , p2_a31  NUMBER
    , p2_a32  DATE
    , p2_a33  DATE
    , p2_a34  NUMBER
    , p2_a35  VARCHAR2
    , p2_a36  VARCHAR2
    , p2_a37  VARCHAR2
    , p2_a38  NUMBER
    , p2_a39  NUMBER
    , p2_a40  NUMBER
    , p2_a41  NUMBER
    , p2_a42  NUMBER
    , p2_a43  DATE
    , p2_a44  NUMBER
    , p2_a45  NUMBER
    , p2_a46  NUMBER
    , p2_a47  NUMBER
    , x_reason_failed out nocopy  VARCHAR2
    , x_message out nocopy  VARCHAR2
    , ddrosetta_retval_bool OUT NOCOPY NUMBER
  )

  as
    ddp_pm_activities_grp_tbl eam_pmdef_pub.pm_activities_grp_tbl_type;
    ddp_pm_runtime_rules_tbl eam_pmdef_pub.pm_rule_tbl_type;
    ddp_pm_schedule_rec eam_pmdef_pub.pm_scheduling_rec_type;
    ddindx binary_integer; indx binary_integer;
    ddrosetta_retval boolean;
    l_activities varchar2(80);
  begin

    -- copy data to the local IN or IN-OUT args, if any
    eam_pmdef_pub_w.rosetta_table_copy_in_p2(ddp_pm_activities_grp_tbl, p0_a0
      , p0_a1
      , p0_a2
      , p0_a3
      , p0_a4
      , p0_a5
      , p0_a6
      );

    eam_pmdef_pub_w.rosetta_table_copy_in_p4(ddp_pm_runtime_rules_tbl, p1_a0
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
      );

    ddp_pm_schedule_rec.pm_schedule_id := p2_a0;
    ddp_pm_schedule_rec.activity_association_id := p2_a1;
    ddp_pm_schedule_rec.non_scheduled_flag := p2_a2;
    ddp_pm_schedule_rec.from_effective_date := p2_a3;
    ddp_pm_schedule_rec.to_effective_date := p2_a4;
    ddp_pm_schedule_rec.rescheduling_point := p2_a5;
    ddp_pm_schedule_rec.lead_time := p2_a6;
    ddp_pm_schedule_rec.attribute_category := p2_a7;
    ddp_pm_schedule_rec.attribute1 := p2_a8;
    ddp_pm_schedule_rec.attribute2 := p2_a9;
    ddp_pm_schedule_rec.attribute3 := p2_a10;
    ddp_pm_schedule_rec.attribute4 := p2_a11;
    ddp_pm_schedule_rec.attribute5 := p2_a12;
    ddp_pm_schedule_rec.attribute6 := p2_a13;
    ddp_pm_schedule_rec.attribute7 := p2_a14;
    ddp_pm_schedule_rec.attribute8 := p2_a15;
    ddp_pm_schedule_rec.attribute9 := p2_a16;
    ddp_pm_schedule_rec.attribute10 := p2_a17;
    ddp_pm_schedule_rec.attribute11 := p2_a18;
    ddp_pm_schedule_rec.attribute12 := p2_a19;
    ddp_pm_schedule_rec.attribute13 := p2_a20;
    ddp_pm_schedule_rec.attribute14 := p2_a21;
    ddp_pm_schedule_rec.attribute15 := p2_a22;
    ddp_pm_schedule_rec.day_tolerance := p2_a23;
    ddp_pm_schedule_rec.source_code := p2_a24;
    ddp_pm_schedule_rec.source_line := p2_a25;
    ddp_pm_schedule_rec.default_implement := p2_a26;
    ddp_pm_schedule_rec.whichever_first := p2_a27;
    ddp_pm_schedule_rec.include_manual := p2_a28;
    ddp_pm_schedule_rec.set_name_id := p2_a29;
    ddp_pm_schedule_rec.scheduling_method_code := p2_a30;
    ddp_pm_schedule_rec.type_code := p2_a31;
    ddp_pm_schedule_rec.next_service_start_date := p2_a32;
    ddp_pm_schedule_rec.next_service_end_date := p2_a33;
    ddp_pm_schedule_rec.source_tmpl_id := p2_a34;
    ddp_pm_schedule_rec.auto_instantiation_flag := p2_a35;
    ddp_pm_schedule_rec.name := p2_a36;
    ddp_pm_schedule_rec.tmpl_flag := p2_a37;
    ddp_pm_schedule_rec.generate_wo_status := p2_a38;
    ddp_pm_schedule_rec.interval_per_cycle := p2_a39;
    ddp_pm_schedule_rec.current_cycle := p2_a40;
    ddp_pm_schedule_rec.current_seq := p2_a41;
    ddp_pm_schedule_rec.current_wo_seq := p2_a42;
    ddp_pm_schedule_rec.base_date := p2_a43;
    ddp_pm_schedule_rec.base_reading := p2_a44;
    ddp_pm_schedule_rec.eam_last_cyclic_act := p2_a45;
    ddp_pm_schedule_rec.maintenance_object_id := p2_a46;
    ddp_pm_schedule_rec.maintenance_object_type := p2_a47;



    -- here's the delegated call to the old PL/SQL routine
    ddrosetta_retval := eam_pmdef_pub.validate_pm_activities(ddp_pm_activities_grp_tbl,
      ddp_pm_runtime_rules_tbl,
      ddp_pm_schedule_rec,
      x_reason_failed,
      x_message,
      l_activities);

    -- copy data back from the local variables to OUT or IN-OUT args, if any
    if ddrosetta_retval is null
      then ddrosetta_retval_bool := null;
    elsif ddrosetta_retval
      then ddrosetta_retval_bool := 1;
    else ddrosetta_retval_bool := 0;
    end if;




  end;

  procedure sort_table_by_date(p0_a0 JTF_NUMBER_TABLE
    , p0_a1 JTF_DATE_TABLE
    , p0_a2 JTF_NUMBER_TABLE
    , p_num_rows  NUMBER
    , p2_a0 out nocopy JTF_NUMBER_TABLE
    , p2_a1 out nocopy JTF_DATE_TABLE
    , p2_a2 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_date_table eam_pmdef_pub.pm_date_tbl_type;
    ddx_sorted_date_table eam_pmdef_pub.pm_date_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    eam_pmdef_pub_w.rosetta_table_copy_in_p6(ddp_date_table, p0_a0
      , p0_a1
      , p0_a2
      );



    -- here's the delegated call to the old PL/SQL routine
    eam_pmdef_pub.sort_table_by_date(ddp_date_table,
      p_num_rows,
      ddx_sorted_date_table);

    -- copy data back from the local variables to OUT or IN-OUT args, if any


    eam_pmdef_pub_w.rosetta_table_copy_out_p6(ddx_sorted_date_table, p2_a0
      , p2_a1
      , p2_a2
      );
  end;

  procedure sort_table_by_number(p0_a0 JTF_NUMBER_TABLE
    , p0_a1 JTF_NUMBER_TABLE
    , p0_a2 JTF_NUMBER_TABLE
    , p_num_rows  NUMBER
    , p2_a0 out nocopy JTF_NUMBER_TABLE
    , p2_a1 out nocopy JTF_NUMBER_TABLE
    , p2_a2 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_num_table eam_pmdef_pub.pm_num_tbl_type;
    ddx_sorted_num_table eam_pmdef_pub.pm_num_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    eam_pmdef_pub_w.rosetta_table_copy_in_p8(ddp_num_table, p0_a0
      , p0_a1
      , p0_a2
      );



    -- here's the delegated call to the old PL/SQL routine
    eam_pmdef_pub.sort_table_by_number(ddp_num_table,
      p_num_rows,
      ddx_sorted_num_table);

    -- copy data back from the local variables to OUT or IN-OUT args, if any


    eam_pmdef_pub_w.rosetta_table_copy_out_p8(ddx_sorted_num_table, p2_a0
      , p2_a1
      , p2_a2
      );
  end;

  procedure merge_rules(p0_a0 JTF_NUMBER_TABLE
    , p0_a1 JTF_NUMBER_TABLE
    , p0_a2 JTF_NUMBER_TABLE
    , p0_a3 JTF_NUMBER_TABLE
    , p0_a4 JTF_NUMBER_TABLE
    , p0_a5 JTF_NUMBER_TABLE
    , p0_a6 JTF_NUMBER_TABLE
    , p0_a7 JTF_NUMBER_TABLE
    , p0_a8 JTF_NUMBER_TABLE
    , p0_a9 JTF_DATE_TABLE
    , p0_a10 JTF_DATE_TABLE
    , p0_a11 JTF_DATE_TABLE
    , p0_a12 JTF_VARCHAR2_TABLE_100
    , p1_a0 JTF_NUMBER_TABLE
    , p1_a1 JTF_NUMBER_TABLE
    , p1_a2 JTF_NUMBER_TABLE
    , p1_a3 JTF_NUMBER_TABLE
    , p1_a4 JTF_NUMBER_TABLE
    , p1_a5 JTF_NUMBER_TABLE
    , p1_a6 JTF_NUMBER_TABLE
    , p1_a7 JTF_NUMBER_TABLE
    , p1_a8 JTF_NUMBER_TABLE
    , p1_a9 JTF_DATE_TABLE
    , p1_a10 JTF_DATE_TABLE
    , p1_a11 JTF_DATE_TABLE
    , p1_a12 JTF_VARCHAR2_TABLE_100
    , p2_a0 out nocopy JTF_NUMBER_TABLE
    , p2_a1 out nocopy JTF_NUMBER_TABLE
    , p2_a2 out nocopy JTF_NUMBER_TABLE
    , p2_a3 out nocopy JTF_NUMBER_TABLE
    , p2_a4 out nocopy JTF_NUMBER_TABLE
    , p2_a5 out nocopy JTF_NUMBER_TABLE
    , p2_a6 out nocopy JTF_NUMBER_TABLE
    , p2_a7 out nocopy JTF_NUMBER_TABLE
    , p2_a8 out nocopy JTF_NUMBER_TABLE
    , p2_a9 out nocopy JTF_DATE_TABLE
    , p2_a10 out nocopy JTF_DATE_TABLE
    , p2_a11 out nocopy JTF_DATE_TABLE
    , p2_a12 out nocopy JTF_VARCHAR2_TABLE_100
  )

  as
    ddp_rules_tbl1 eam_pmdef_pub.pm_rule_tbl_type;
    ddp_rules_tbl2 eam_pmdef_pub.pm_rule_tbl_type;
    ddx_merged_rules_tbl eam_pmdef_pub.pm_rule_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    eam_pmdef_pub_w.rosetta_table_copy_in_p4(ddp_rules_tbl1, p0_a0
      , p0_a1
      , p0_a2
      , p0_a3
      , p0_a4
      , p0_a5
      , p0_a6
      , p0_a7
      , p0_a8
      , p0_a9
      , p0_a10
      , p0_a11
      , p0_a12
      );

    eam_pmdef_pub_w.rosetta_table_copy_in_p4(ddp_rules_tbl2, p1_a0
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
      );


    -- here's the delegated call to the old PL/SQL routine
    eam_pmdef_pub.merge_rules(ddp_rules_tbl1,
      ddp_rules_tbl2,
      ddx_merged_rules_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any


    eam_pmdef_pub_w.rosetta_table_copy_out_p4(ddx_merged_rules_tbl, p2_a0
      , p2_a1
      , p2_a2
      , p2_a3
      , p2_a4
      , p2_a5
      , p2_a6
      , p2_a7
      , p2_a8
      , p2_a9
      , p2_a10
      , p2_a11
      , p2_a12
      );
  end;

end eam_pmdef_pub_w;

/
