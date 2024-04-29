--------------------------------------------------------
--  DDL for Package Body JTF_RS_RES_SSWA_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_RS_RES_SSWA_PUB_W" as
  /* $Header: jtfrsrwb.pls 120.0 2005/05/11 08:21:52 appldev ship $ */
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

  procedure create_emp_resource(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_source_first_name  VARCHAR2
    , p_source_last_name  VARCHAR2
    , p_source_middle_name  VARCHAR2
    , p_employee_number  VARCHAR2
    , p_source_sex  VARCHAR2
    , p_source_title  VARCHAR2
    , p_source_job_id  NUMBER
    , p_source_email  VARCHAR2
    , p_source_start_date  date
    , p_source_end_date  date
    , p_user_name  VARCHAR2
    , p_source_address_id  NUMBER
    , p_source_office  VARCHAR2
    , p_source_mailstop  VARCHAR2
    , p_source_location  VARCHAR2
    , p_source_phone  VARCHAR2
    , p_salesrep_number  VARCHAR2
    , p_sales_credit_type_id  NUMBER
    , p_source_mgr_id  NUMBER
    , x_resource_id out NOCOPY  NUMBER
    , x_return_status out NOCOPY  VARCHAR2
    , x_msg_count out NOCOPY  NUMBER
    , x_msg_data out NOCOPY  VARCHAR2
    , p_called_from  VARCHAR2
    , p_user_password in out NOCOPY  VARCHAR2
  )
  as
    ddp_source_start_date date;
    ddp_source_end_date date;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any











    ddp_source_start_date := rosetta_g_miss_date_in_map(p_source_start_date);

    ddp_source_end_date := rosetta_g_miss_date_in_map(p_source_end_date);
















    -- here's the delegated call to the old PL/SQL routine
    jtf_rs_res_sswa_pub.create_emp_resource(p_api_version,
      p_init_msg_list,
      p_commit,
      p_source_first_name,
      p_source_last_name,
      p_source_middle_name,
      p_employee_number,
      p_source_sex,
      p_source_title,
      p_source_job_id,
      p_source_email,
      ddp_source_start_date,
      ddp_source_end_date,
      p_user_name,
      p_source_address_id,
      p_source_office,
      p_source_mailstop,
      p_source_location,
      p_source_phone,
      p_salesrep_number,
      p_sales_credit_type_id,
      p_source_mgr_id,
      x_resource_id,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_called_from,
      p_user_password);

    -- copy data back from the local OUT or IN-OUT args, if any



























  end;

  procedure update_resource(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_resource_id  NUMBER
    , p_resource_number  VARCHAR2
    , p_resource_name  VARCHAR2
    , p_source_name  VARCHAR2
    , p_address_id  VARCHAR2
    , p_source_office  VARCHAR2
    , p_source_mailstop  VARCHAR2
    , p_source_location  VARCHAR2
    , p_source_phone  VARCHAR2
    , p_source_email  VARCHAR2
    , p_object_version_number  NUMBER
    , p_approved  VARCHAR2
    , p_source_job_id  NUMBER
    , p_source_job_title  VARCHAR2
    , p_salesrep_number  VARCHAR2
    , p_sales_credit_type_id  NUMBER
    , p_end_date_active  date
    , p_user_id  NUMBER
    , p_user_name  VARCHAR2
    , p_mgr_resource_id  NUMBER
    , p_org_id  NUMBER
    , x_return_status out NOCOPY  VARCHAR2
    , x_msg_count out NOCOPY  NUMBER
    , x_msg_data out NOCOPY  VARCHAR2
    , p_time_zone  NUMBER
    , p_cost_per_hr  NUMBER
    , p_primary_language  VARCHAR2
    , p_secondary_language  VARCHAR2
    , p_support_site_id  NUMBER
    , p_source_mobile_phone  VARCHAR2
    , p_source_pager  VARCHAR2
  )
  as
    ddp_end_date_active date;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



















    ddp_end_date_active := rosetta_g_miss_date_in_map(p_end_date_active);















    -- here's the delegated call to the old PL/SQL routine
    jtf_rs_res_sswa_pub.update_resource(p_api_version,
      p_init_msg_list,
      p_commit,
      p_resource_id,
      p_resource_number,
      p_resource_name,
      p_source_name,
      p_address_id,
      p_source_office,
      p_source_mailstop,
      p_source_location,
      p_source_phone,
      p_source_email,
      p_object_version_number,
      p_approved,
      p_source_job_id,
      p_source_job_title,
      p_salesrep_number,
      p_sales_credit_type_id,
      ddp_end_date_active,
      p_user_id,
      p_user_name,
      p_mgr_resource_id,
      p_org_id,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_time_zone,
      p_cost_per_hr,
      p_primary_language,
      p_secondary_language,
      p_support_site_id,
      p_source_mobile_phone,
      p_source_pager);

    -- copy data back from the local OUT or IN-OUT args, if any

































  end;

end jtf_rs_res_sswa_pub_w;

/
