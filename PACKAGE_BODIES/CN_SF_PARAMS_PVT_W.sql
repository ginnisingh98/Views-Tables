--------------------------------------------------------
--  DDL for Package Body CN_SF_PARAMS_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_SF_PARAMS_PVT_W" as
  /* $Header: cnwprmsb.pls 115.4 2002/12/04 05:05:17 fmburu ship $ */
  rosetta_g_mistake_date date := to_date('01/01/+4713', 'MM/DD/SYYYY');
  rosetta_g_miss_date date := to_date('01/01/-4712', 'MM/DD/SYYYY');

  -- this is to workaround the JDBC bug regarding IN DATE of value GMiss
  function rosetta_g_miss_date_in_map(d date) return date as
  begin
    if d = rosetta_g_mistake_date then return fnd_api.g_miss_date; end if;
    return d;
  end;

  procedure rosetta_table_copy_in_p1(t out nocopy cn_sf_params_pvt.sf_repositories_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_2000
    , a3 JTF_VARCHAR2_TABLE_1000
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).repository_id := a0(indx);
          t(ddindx).contract_title := a1(indx);
          t(ddindx).terms_and_conditions := a2(indx);
          t(ddindx).club_qual_text := a3(indx);
          t(ddindx).approver_name := a4(indx);
          t(ddindx).approver_title := a5(indx);
          t(ddindx).approver_org_name := a6(indx);
          t(ddindx).file_id := a7(indx);
          t(ddindx).formu_activated_flag := a8(indx);
          t(ddindx).transaction_calendar_id := a9(indx);
          t(ddindx).object_version_number := a10(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p1;
  procedure rosetta_table_copy_out_p1(t cn_sf_params_pvt.sf_repositories_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_2000
    , a3 out nocopy JTF_VARCHAR2_TABLE_1000
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_VARCHAR2_TABLE_2000();
    a3 := JTF_VARCHAR2_TABLE_1000();
    a4 := JTF_VARCHAR2_TABLE_100();
    a5 := JTF_VARCHAR2_TABLE_100();
    a6 := JTF_VARCHAR2_TABLE_100();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_VARCHAR2_TABLE_100();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_VARCHAR2_TABLE_2000();
      a3 := JTF_VARCHAR2_TABLE_1000();
      a4 := JTF_VARCHAR2_TABLE_100();
      a5 := JTF_VARCHAR2_TABLE_100();
      a6 := JTF_VARCHAR2_TABLE_100();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_VARCHAR2_TABLE_100();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_NUMBER_TABLE();
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
          a0(indx) := t(ddindx).repository_id;
          a1(indx) := t(ddindx).contract_title;
          a2(indx) := t(ddindx).terms_and_conditions;
          a3(indx) := t(ddindx).club_qual_text;
          a4(indx) := t(ddindx).approver_name;
          a5(indx) := t(ddindx).approver_title;
          a6(indx) := t(ddindx).approver_org_name;
          a7(indx) := t(ddindx).file_id;
          a8(indx) := t(ddindx).formu_activated_flag;
          a9(indx) := t(ddindx).transaction_calendar_id;
          a10(indx) := t(ddindx).object_version_number;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p1;

  procedure get_sf_parameters(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p4_a0 out nocopy  NUMBER
    , p4_a1 out nocopy  VARCHAR2
    , p4_a2 out nocopy  VARCHAR2
    , p4_a3 out nocopy  VARCHAR2
    , p4_a4 out nocopy  VARCHAR2
    , p4_a5 out nocopy  VARCHAR2
    , p4_a6 out nocopy  VARCHAR2
    , p4_a7 out nocopy  NUMBER
    , p4_a8 out nocopy  VARCHAR2
    , p4_a9 out nocopy  NUMBER
    , p4_a10 out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_sf_param_rec cn_sf_params_pvt.cn_sf_repositories_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any








    -- here's the delegated call to the old PL/SQL routine
    cn_sf_params_pvt.get_sf_parameters(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      ddp_sf_param_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any




    p4_a0 := ddp_sf_param_rec.repository_id;
    p4_a1 := ddp_sf_param_rec.contract_title;
    p4_a2 := ddp_sf_param_rec.terms_and_conditions;
    p4_a3 := ddp_sf_param_rec.club_qual_text;
    p4_a4 := ddp_sf_param_rec.approver_name;
    p4_a5 := ddp_sf_param_rec.approver_title;
    p4_a6 := ddp_sf_param_rec.approver_org_name;
    p4_a7 := ddp_sf_param_rec.file_id;
    p4_a8 := ddp_sf_param_rec.formu_activated_flag;
    p4_a9 := ddp_sf_param_rec.transaction_calendar_id;
    p4_a10 := ddp_sf_param_rec.object_version_number;



  end;

  procedure update_sf_parameters(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p4_a0  NUMBER
    , p4_a1  VARCHAR2
    , p4_a2  VARCHAR2
    , p4_a3  VARCHAR2
    , p4_a4  VARCHAR2
    , p4_a5  VARCHAR2
    , p4_a6  VARCHAR2
    , p4_a7  NUMBER
    , p4_a8  VARCHAR2
    , p4_a9  NUMBER
    , p4_a10  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_sf_repositories_rec cn_sf_params_pvt.cn_sf_repositories_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    ddp_sf_repositories_rec.repository_id := p4_a0;
    ddp_sf_repositories_rec.contract_title := p4_a1;
    ddp_sf_repositories_rec.terms_and_conditions := p4_a2;
    ddp_sf_repositories_rec.club_qual_text := p4_a3;
    ddp_sf_repositories_rec.approver_name := p4_a4;
    ddp_sf_repositories_rec.approver_title := p4_a5;
    ddp_sf_repositories_rec.approver_org_name := p4_a6;
    ddp_sf_repositories_rec.file_id := p4_a7;
    ddp_sf_repositories_rec.formu_activated_flag := p4_a8;
    ddp_sf_repositories_rec.transaction_calendar_id := p4_a9;
    ddp_sf_repositories_rec.object_version_number := p4_a10;




    -- here's the delegated call to the old PL/SQL routine
    cn_sf_params_pvt.update_sf_parameters(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      ddp_sf_repositories_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

  procedure insert_sf_parameters(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p4_a0  NUMBER
    , p4_a1  VARCHAR2
    , p4_a2  VARCHAR2
    , p4_a3  VARCHAR2
    , p4_a4  VARCHAR2
    , p4_a5  VARCHAR2
    , p4_a6  VARCHAR2
    , p4_a7  NUMBER
    , p4_a8  VARCHAR2
    , p4_a9  NUMBER
    , p4_a10  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_sf_repositories_rec cn_sf_params_pvt.cn_sf_repositories_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    ddp_sf_repositories_rec.repository_id := p4_a0;
    ddp_sf_repositories_rec.contract_title := p4_a1;
    ddp_sf_repositories_rec.terms_and_conditions := p4_a2;
    ddp_sf_repositories_rec.club_qual_text := p4_a3;
    ddp_sf_repositories_rec.approver_name := p4_a4;
    ddp_sf_repositories_rec.approver_title := p4_a5;
    ddp_sf_repositories_rec.approver_org_name := p4_a6;
    ddp_sf_repositories_rec.file_id := p4_a7;
    ddp_sf_repositories_rec.formu_activated_flag := p4_a8;
    ddp_sf_repositories_rec.transaction_calendar_id := p4_a9;
    ddp_sf_repositories_rec.object_version_number := p4_a10;




    -- here's the delegated call to the old PL/SQL routine
    cn_sf_params_pvt.insert_sf_parameters(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      ddp_sf_repositories_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

end cn_sf_params_pvt_w;

/
