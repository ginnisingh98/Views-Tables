--------------------------------------------------------
--  DDL for Package Body HZ_ORGANIZATION_INFO_V2PUB_JW
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_ORGANIZATION_INFO_V2PUB_JW" as
  /* $Header: ARH2OIJB.pls 120.3 2005/06/18 04:28:35 jhuang noship $ */
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

  procedure create_financial_report_1(p_init_msg_list  VARCHAR2
    , x_financial_report_id out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p1_a0  NUMBER := null
    , p1_a1  NUMBER := null
    , p1_a2  VARCHAR2 := null
    , p1_a3  VARCHAR2 := null
    , p1_a4  DATE := null
    , p1_a5  VARCHAR2 := null
    , p1_a6  DATE := null
    , p1_a7  DATE := null
    , p1_a8  VARCHAR2 := null
    , p1_a9  VARCHAR2 := null
    , p1_a10  VARCHAR2 := null
    , p1_a11  VARCHAR2 := null
    , p1_a12  VARCHAR2 := null
    , p1_a13  VARCHAR2 := null
    , p1_a14  VARCHAR2 := null
    , p1_a15  VARCHAR2 := null
    , p1_a16  VARCHAR2 := null
    , p1_a17  VARCHAR2 := null
    , p1_a18  VARCHAR2 := null
    , p1_a19  VARCHAR2 := null
    , p1_a20  VARCHAR2 := null
    , p1_a21  VARCHAR2 := null
    , p1_a22  VARCHAR2 := null
    , p1_a23  VARCHAR2 := null
    , p1_a24  VARCHAR2 := null
  )
  as
    ddp_financial_report_rec hz_organization_info_v2pub.financial_report_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    ddp_financial_report_rec.financial_report_id := rosetta_g_miss_num_map(p1_a0);
    ddp_financial_report_rec.party_id := rosetta_g_miss_num_map(p1_a1);
    ddp_financial_report_rec.type_of_financial_report := p1_a2;
    ddp_financial_report_rec.document_reference := p1_a3;
    ddp_financial_report_rec.date_report_issued := rosetta_g_miss_date_in_map(p1_a4);
    ddp_financial_report_rec.issued_period := p1_a5;
    ddp_financial_report_rec.report_start_date := rosetta_g_miss_date_in_map(p1_a6);
    ddp_financial_report_rec.report_end_date := rosetta_g_miss_date_in_map(p1_a7);
    ddp_financial_report_rec.actual_content_source := p1_a8;
    ddp_financial_report_rec.requiring_authority := p1_a9;
    ddp_financial_report_rec.audit_ind := p1_a10;
    ddp_financial_report_rec.consolidated_ind := p1_a11;
    ddp_financial_report_rec.estimated_ind := p1_a12;
    ddp_financial_report_rec.fiscal_ind := p1_a13;
    ddp_financial_report_rec.final_ind := p1_a14;
    ddp_financial_report_rec.forecast_ind := p1_a15;
    ddp_financial_report_rec.opening_ind := p1_a16;
    ddp_financial_report_rec.proforma_ind := p1_a17;
    ddp_financial_report_rec.qualified_ind := p1_a18;
    ddp_financial_report_rec.restated_ind := p1_a19;
    ddp_financial_report_rec.signed_by_principals_ind := p1_a20;
    ddp_financial_report_rec.trial_balance_ind := p1_a21;
    ddp_financial_report_rec.unbalanced_ind := p1_a22;
    ddp_financial_report_rec.status := p1_a23;
    ddp_financial_report_rec.created_by_module := p1_a24;





    -- here's the delegated call to the old PL/SQL routine
    hz_organization_info_v2pub.create_financial_report(p_init_msg_list,
      ddp_financial_report_rec,
      x_financial_report_id,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any





  end;

  procedure update_financial_report_2(p_init_msg_list  VARCHAR2
    , p_object_version_number in out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p1_a0  NUMBER := null
    , p1_a1  NUMBER := null
    , p1_a2  VARCHAR2 := null
    , p1_a3  VARCHAR2 := null
    , p1_a4  DATE := null
    , p1_a5  VARCHAR2 := null
    , p1_a6  DATE := null
    , p1_a7  DATE := null
    , p1_a8  VARCHAR2 := null
    , p1_a9  VARCHAR2 := null
    , p1_a10  VARCHAR2 := null
    , p1_a11  VARCHAR2 := null
    , p1_a12  VARCHAR2 := null
    , p1_a13  VARCHAR2 := null
    , p1_a14  VARCHAR2 := null
    , p1_a15  VARCHAR2 := null
    , p1_a16  VARCHAR2 := null
    , p1_a17  VARCHAR2 := null
    , p1_a18  VARCHAR2 := null
    , p1_a19  VARCHAR2 := null
    , p1_a20  VARCHAR2 := null
    , p1_a21  VARCHAR2 := null
    , p1_a22  VARCHAR2 := null
    , p1_a23  VARCHAR2 := null
    , p1_a24  VARCHAR2 := null
  )
  as
    ddp_financial_report_rec hz_organization_info_v2pub.financial_report_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    ddp_financial_report_rec.financial_report_id := rosetta_g_miss_num_map(p1_a0);
    ddp_financial_report_rec.party_id := rosetta_g_miss_num_map(p1_a1);
    ddp_financial_report_rec.type_of_financial_report := p1_a2;
    ddp_financial_report_rec.document_reference := p1_a3;
    ddp_financial_report_rec.date_report_issued := rosetta_g_miss_date_in_map(p1_a4);
    ddp_financial_report_rec.issued_period := p1_a5;
    ddp_financial_report_rec.report_start_date := rosetta_g_miss_date_in_map(p1_a6);
    ddp_financial_report_rec.report_end_date := rosetta_g_miss_date_in_map(p1_a7);
    ddp_financial_report_rec.actual_content_source := p1_a8;
    ddp_financial_report_rec.requiring_authority := p1_a9;
    ddp_financial_report_rec.audit_ind := p1_a10;
    ddp_financial_report_rec.consolidated_ind := p1_a11;
    ddp_financial_report_rec.estimated_ind := p1_a12;
    ddp_financial_report_rec.fiscal_ind := p1_a13;
    ddp_financial_report_rec.final_ind := p1_a14;
    ddp_financial_report_rec.forecast_ind := p1_a15;
    ddp_financial_report_rec.opening_ind := p1_a16;
    ddp_financial_report_rec.proforma_ind := p1_a17;
    ddp_financial_report_rec.qualified_ind := p1_a18;
    ddp_financial_report_rec.restated_ind := p1_a19;
    ddp_financial_report_rec.signed_by_principals_ind := p1_a20;
    ddp_financial_report_rec.trial_balance_ind := p1_a21;
    ddp_financial_report_rec.unbalanced_ind := p1_a22;
    ddp_financial_report_rec.status := p1_a23;
    ddp_financial_report_rec.created_by_module := p1_a24;





    -- here's the delegated call to the old PL/SQL routine
    hz_organization_info_v2pub.update_financial_report(p_init_msg_list,
      ddp_financial_report_rec,
      p_object_version_number,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any





  end;

  procedure create_financial_number_3(p_init_msg_list  VARCHAR2
    , x_financial_number_id out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p1_a0  NUMBER := null
    , p1_a1  NUMBER := null
    , p1_a2  NUMBER := null
    , p1_a3  VARCHAR2 := null
    , p1_a4  NUMBER := null
    , p1_a5  VARCHAR2 := null
    , p1_a6  VARCHAR2 := null
    , p1_a7  VARCHAR2 := null
    , p1_a8  VARCHAR2 := null
    , p1_a9  VARCHAR2 := null
  )
  as
    ddp_financial_number_rec hz_organization_info_v2pub.financial_number_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    ddp_financial_number_rec.financial_number_id := rosetta_g_miss_num_map(p1_a0);
    ddp_financial_number_rec.financial_report_id := rosetta_g_miss_num_map(p1_a1);
    ddp_financial_number_rec.financial_number := rosetta_g_miss_num_map(p1_a2);
    ddp_financial_number_rec.financial_number_name := p1_a3;
    ddp_financial_number_rec.financial_units_applied := rosetta_g_miss_num_map(p1_a4);
    ddp_financial_number_rec.financial_number_currency := p1_a5;
    ddp_financial_number_rec.projected_actual_flag := p1_a6;
    ddp_financial_number_rec.content_source_type := p1_a7;
    ddp_financial_number_rec.status := p1_a8;
    ddp_financial_number_rec.created_by_module := p1_a9;





    -- here's the delegated call to the old PL/SQL routine
    hz_organization_info_v2pub.create_financial_number(p_init_msg_list,
      ddp_financial_number_rec,
      x_financial_number_id,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any





  end;

  procedure update_financial_number_4(p_init_msg_list  VARCHAR2
    , p_object_version_number in out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p1_a0  NUMBER := null
    , p1_a1  NUMBER := null
    , p1_a2  NUMBER := null
    , p1_a3  VARCHAR2 := null
    , p1_a4  NUMBER := null
    , p1_a5  VARCHAR2 := null
    , p1_a6  VARCHAR2 := null
    , p1_a7  VARCHAR2 := null
    , p1_a8  VARCHAR2 := null
    , p1_a9  VARCHAR2 := null
  )
  as
    ddp_financial_number_rec hz_organization_info_v2pub.financial_number_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    ddp_financial_number_rec.financial_number_id := rosetta_g_miss_num_map(p1_a0);
    ddp_financial_number_rec.financial_report_id := rosetta_g_miss_num_map(p1_a1);
    ddp_financial_number_rec.financial_number := rosetta_g_miss_num_map(p1_a2);
    ddp_financial_number_rec.financial_number_name := p1_a3;
    ddp_financial_number_rec.financial_units_applied := rosetta_g_miss_num_map(p1_a4);
    ddp_financial_number_rec.financial_number_currency := p1_a5;
    ddp_financial_number_rec.projected_actual_flag := p1_a6;
    ddp_financial_number_rec.content_source_type := p1_a7;
    ddp_financial_number_rec.status := p1_a8;
    ddp_financial_number_rec.created_by_module := p1_a9;





    -- here's the delegated call to the old PL/SQL routine
    hz_organization_info_v2pub.update_financial_number(p_init_msg_list,
      ddp_financial_number_rec,
      p_object_version_number,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any





  end;

  procedure get_financial_report_rec_5(p_init_msg_list  VARCHAR2
    , p_financial_report_id  NUMBER
    , p2_a0 out nocopy  NUMBER
    , p2_a1 out nocopy  NUMBER
    , p2_a2 out nocopy  VARCHAR2
    , p2_a3 out nocopy  VARCHAR2
    , p2_a4 out nocopy  DATE
    , p2_a5 out nocopy  VARCHAR2
    , p2_a6 out nocopy  DATE
    , p2_a7 out nocopy  DATE
    , p2_a8 out nocopy  VARCHAR2
    , p2_a9 out nocopy  VARCHAR2
    , p2_a10 out nocopy  VARCHAR2
    , p2_a11 out nocopy  VARCHAR2
    , p2_a12 out nocopy  VARCHAR2
    , p2_a13 out nocopy  VARCHAR2
    , p2_a14 out nocopy  VARCHAR2
    , p2_a15 out nocopy  VARCHAR2
    , p2_a16 out nocopy  VARCHAR2
    , p2_a17 out nocopy  VARCHAR2
    , p2_a18 out nocopy  VARCHAR2
    , p2_a19 out nocopy  VARCHAR2
    , p2_a20 out nocopy  VARCHAR2
    , p2_a21 out nocopy  VARCHAR2
    , p2_a22 out nocopy  VARCHAR2
    , p2_a23 out nocopy  VARCHAR2
    , p2_a24 out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )
  as
    ddp_financial_report_rec hz_organization_info_v2pub.financial_report_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any






    -- here's the delegated call to the old PL/SQL routine
    hz_organization_info_v2pub.get_financial_report_rec(p_init_msg_list,
      p_financial_report_id,
      ddp_financial_report_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any


    p2_a0 := rosetta_g_miss_num_map(ddp_financial_report_rec.financial_report_id);
    p2_a1 := rosetta_g_miss_num_map(ddp_financial_report_rec.party_id);
    p2_a2 := ddp_financial_report_rec.type_of_financial_report;
    p2_a3 := ddp_financial_report_rec.document_reference;
    p2_a4 := ddp_financial_report_rec.date_report_issued;
    p2_a5 := ddp_financial_report_rec.issued_period;
    p2_a6 := ddp_financial_report_rec.report_start_date;
    p2_a7 := ddp_financial_report_rec.report_end_date;
    p2_a8 := ddp_financial_report_rec.actual_content_source;
    p2_a9 := ddp_financial_report_rec.requiring_authority;
    p2_a10 := ddp_financial_report_rec.audit_ind;
    p2_a11 := ddp_financial_report_rec.consolidated_ind;
    p2_a12 := ddp_financial_report_rec.estimated_ind;
    p2_a13 := ddp_financial_report_rec.fiscal_ind;
    p2_a14 := ddp_financial_report_rec.final_ind;
    p2_a15 := ddp_financial_report_rec.forecast_ind;
    p2_a16 := ddp_financial_report_rec.opening_ind;
    p2_a17 := ddp_financial_report_rec.proforma_ind;
    p2_a18 := ddp_financial_report_rec.qualified_ind;
    p2_a19 := ddp_financial_report_rec.restated_ind;
    p2_a20 := ddp_financial_report_rec.signed_by_principals_ind;
    p2_a21 := ddp_financial_report_rec.trial_balance_ind;
    p2_a22 := ddp_financial_report_rec.unbalanced_ind;
    p2_a23 := ddp_financial_report_rec.status;
    p2_a24 := ddp_financial_report_rec.created_by_module;



  end;

  procedure get_financial_number_rec_6(p_init_msg_list  VARCHAR2
    , p_financial_number_id  NUMBER
    , p2_a0 out nocopy  NUMBER
    , p2_a1 out nocopy  NUMBER
    , p2_a2 out nocopy  NUMBER
    , p2_a3 out nocopy  VARCHAR2
    , p2_a4 out nocopy  NUMBER
    , p2_a5 out nocopy  VARCHAR2
    , p2_a6 out nocopy  VARCHAR2
    , p2_a7 out nocopy  VARCHAR2
    , p2_a8 out nocopy  VARCHAR2
    , p2_a9 out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )
  as
    ddp_financial_number_rec hz_organization_info_v2pub.financial_number_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any






    -- here's the delegated call to the old PL/SQL routine
    hz_organization_info_v2pub.get_financial_number_rec(p_init_msg_list,
      p_financial_number_id,
      ddp_financial_number_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local OUT or IN-OUT args, if any


    p2_a0 := rosetta_g_miss_num_map(ddp_financial_number_rec.financial_number_id);
    p2_a1 := rosetta_g_miss_num_map(ddp_financial_number_rec.financial_report_id);
    p2_a2 := rosetta_g_miss_num_map(ddp_financial_number_rec.financial_number);
    p2_a3 := ddp_financial_number_rec.financial_number_name;
    p2_a4 := rosetta_g_miss_num_map(ddp_financial_number_rec.financial_units_applied);
    p2_a5 := ddp_financial_number_rec.financial_number_currency;
    p2_a6 := ddp_financial_number_rec.projected_actual_flag;
    p2_a7 := ddp_financial_number_rec.content_source_type;
    p2_a8 := ddp_financial_number_rec.status;
    p2_a9 := ddp_financial_number_rec.created_by_module;



  end;

end hz_organization_info_v2pub_jw;

/
