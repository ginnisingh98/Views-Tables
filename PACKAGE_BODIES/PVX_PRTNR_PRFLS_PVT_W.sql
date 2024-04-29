--------------------------------------------------------
--  DDL for Package Body PVX_PRTNR_PRFLS_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PVX_PRTNR_PRFLS_PVT_W" as
  /* $Header: pvxwppfb.pls 115.14 2003/11/19 07:39:23 rdsharma ship $ */
  procedure create_prtnr_prfls(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0  NUMBER
    , p7_a1  DATE
    , p7_a2  NUMBER
    , p7_a3  DATE
    , p7_a4  NUMBER
    , p7_a5  NUMBER
    , p7_a6  NUMBER
    , p7_a7  NUMBER
    , p7_a8  NUMBER
    , p7_a9  NUMBER
    , p7_a10  NUMBER
    , p7_a11  NUMBER
    , p7_a12  VARCHAR2
    , p7_a13  VARCHAR2
    , p7_a14  VARCHAR2
    , p7_a15  VARCHAR2
    , p7_a16  VARCHAR2
    , p7_a17  VARCHAR2
    , p7_a18  NUMBER
    , p7_a19  NUMBER
    , p7_a20  VARCHAR2
    , p7_a21  VARCHAR2
    , p7_a22  NUMBER
    , p7_a23  VARCHAR2
    , p7_a24  NUMBER
    , p7_a25  NUMBER
    , p7_a26  NUMBER
    , p7_a27  VARCHAR2
    , p7_a28  VARCHAR2
    , p7_a29  VARCHAR2
    , p7_a30  VARCHAR2
    , p7_a31  NUMBER
    , p7_a32  NUMBER
    , p7_a33  NUMBER
    , p7_a34  NUMBER
    , p7_a35  VARCHAR2
    , x_partner_profile_id out nocopy  NUMBER
  )

  as
    ddp_prtnr_prfls_rec pvx_prtnr_prfls_pvt.prtnr_prfls_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_prtnr_prfls_rec.partner_profile_id := p7_a0;
    ddp_prtnr_prfls_rec.last_update_date := p7_a1;
    ddp_prtnr_prfls_rec.last_updated_by := p7_a2;
    ddp_prtnr_prfls_rec.creation_date := p7_a3;
    ddp_prtnr_prfls_rec.created_by := p7_a4;
    ddp_prtnr_prfls_rec.last_update_login := p7_a5;
    ddp_prtnr_prfls_rec.object_version_number := p7_a6;
    ddp_prtnr_prfls_rec.partner_id := p7_a7;
    ddp_prtnr_prfls_rec.target_revenue_amt := p7_a8;
    ddp_prtnr_prfls_rec.actual_revenue_amt := p7_a9;
    ddp_prtnr_prfls_rec.target_revenue_pct := p7_a10;
    ddp_prtnr_prfls_rec.actual_revenue_pct := p7_a11;
    ddp_prtnr_prfls_rec.orig_system_reference := p7_a12;
    ddp_prtnr_prfls_rec.orig_system_type := p7_a13;
    ddp_prtnr_prfls_rec.capacity_size := p7_a14;
    ddp_prtnr_prfls_rec.capacity_amount := p7_a15;
    ddp_prtnr_prfls_rec.auto_match_allowed_flag := p7_a16;
    ddp_prtnr_prfls_rec.purchase_method := p7_a17;
    ddp_prtnr_prfls_rec.cm_id := p7_a18;
    ddp_prtnr_prfls_rec.ph_support_rep := p7_a19;
    ddp_prtnr_prfls_rec.lead_sharing_status := p7_a20;
    ddp_prtnr_prfls_rec.lead_share_appr_flag := p7_a21;
    ddp_prtnr_prfls_rec.partner_relationship_id := p7_a22;
    ddp_prtnr_prfls_rec.partner_level := p7_a23;
    ddp_prtnr_prfls_rec.preferred_vad_id := p7_a24;
    ddp_prtnr_prfls_rec.partner_group_id := p7_a25;
    ddp_prtnr_prfls_rec.partner_resource_id := p7_a26;
    ddp_prtnr_prfls_rec.partner_group_number := p7_a27;
    ddp_prtnr_prfls_rec.partner_resource_number := p7_a28;
    ddp_prtnr_prfls_rec.sales_partner_flag := p7_a29;
    ddp_prtnr_prfls_rec.indirectly_managed_flag := p7_a30;
    ddp_prtnr_prfls_rec.channel_marketing_manager := p7_a31;
    ddp_prtnr_prfls_rec.related_partner_id := p7_a32;
    ddp_prtnr_prfls_rec.max_users := p7_a33;
    ddp_prtnr_prfls_rec.partner_party_id := p7_a34;
    ddp_prtnr_prfls_rec.status := p7_a35;


    -- here's the delegated call to the old PL/SQL routine
    pvx_prtnr_prfls_pvt.create_prtnr_prfls(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_prtnr_prfls_rec,
      x_partner_profile_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

  procedure update_prtnr_prfls(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0  NUMBER
    , p7_a1  DATE
    , p7_a2  NUMBER
    , p7_a3  DATE
    , p7_a4  NUMBER
    , p7_a5  NUMBER
    , p7_a6  NUMBER
    , p7_a7  NUMBER
    , p7_a8  NUMBER
    , p7_a9  NUMBER
    , p7_a10  NUMBER
    , p7_a11  NUMBER
    , p7_a12  VARCHAR2
    , p7_a13  VARCHAR2
    , p7_a14  VARCHAR2
    , p7_a15  VARCHAR2
    , p7_a16  VARCHAR2
    , p7_a17  VARCHAR2
    , p7_a18  NUMBER
    , p7_a19  NUMBER
    , p7_a20  VARCHAR2
    , p7_a21  VARCHAR2
    , p7_a22  NUMBER
    , p7_a23  VARCHAR2
    , p7_a24  NUMBER
    , p7_a25  NUMBER
    , p7_a26  NUMBER
    , p7_a27  VARCHAR2
    , p7_a28  VARCHAR2
    , p7_a29  VARCHAR2
    , p7_a30  VARCHAR2
    , p7_a31  NUMBER
    , p7_a32  NUMBER
    , p7_a33  NUMBER
    , p7_a34  NUMBER
    , p7_a35  VARCHAR2
  )

  as
    ddp_prtnr_prfls_rec pvx_prtnr_prfls_pvt.prtnr_prfls_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_prtnr_prfls_rec.partner_profile_id := p7_a0;
    ddp_prtnr_prfls_rec.last_update_date := p7_a1;
    ddp_prtnr_prfls_rec.last_updated_by := p7_a2;
    ddp_prtnr_prfls_rec.creation_date := p7_a3;
    ddp_prtnr_prfls_rec.created_by := p7_a4;
    ddp_prtnr_prfls_rec.last_update_login := p7_a5;
    ddp_prtnr_prfls_rec.object_version_number := p7_a6;
    ddp_prtnr_prfls_rec.partner_id := p7_a7;
    ddp_prtnr_prfls_rec.target_revenue_amt := p7_a8;
    ddp_prtnr_prfls_rec.actual_revenue_amt := p7_a9;
    ddp_prtnr_prfls_rec.target_revenue_pct := p7_a10;
    ddp_prtnr_prfls_rec.actual_revenue_pct := p7_a11;
    ddp_prtnr_prfls_rec.orig_system_reference := p7_a12;
    ddp_prtnr_prfls_rec.orig_system_type := p7_a13;
    ddp_prtnr_prfls_rec.capacity_size := p7_a14;
    ddp_prtnr_prfls_rec.capacity_amount := p7_a15;
    ddp_prtnr_prfls_rec.auto_match_allowed_flag := p7_a16;
    ddp_prtnr_prfls_rec.purchase_method := p7_a17;
    ddp_prtnr_prfls_rec.cm_id := p7_a18;
    ddp_prtnr_prfls_rec.ph_support_rep := p7_a19;
    ddp_prtnr_prfls_rec.lead_sharing_status := p7_a20;
    ddp_prtnr_prfls_rec.lead_share_appr_flag := p7_a21;
    ddp_prtnr_prfls_rec.partner_relationship_id := p7_a22;
    ddp_prtnr_prfls_rec.partner_level := p7_a23;
    ddp_prtnr_prfls_rec.preferred_vad_id := p7_a24;
    ddp_prtnr_prfls_rec.partner_group_id := p7_a25;
    ddp_prtnr_prfls_rec.partner_resource_id := p7_a26;
    ddp_prtnr_prfls_rec.partner_group_number := p7_a27;
    ddp_prtnr_prfls_rec.partner_resource_number := p7_a28;
    ddp_prtnr_prfls_rec.sales_partner_flag := p7_a29;
    ddp_prtnr_prfls_rec.indirectly_managed_flag := p7_a30;
    ddp_prtnr_prfls_rec.channel_marketing_manager := p7_a31;
    ddp_prtnr_prfls_rec.related_partner_id := p7_a32;
    ddp_prtnr_prfls_rec.max_users := p7_a33;
    ddp_prtnr_prfls_rec.partner_party_id := p7_a34;
    ddp_prtnr_prfls_rec.status := p7_a35;

    -- here's the delegated call to the old PL/SQL routine
    pvx_prtnr_prfls_pvt.update_prtnr_prfls(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_prtnr_prfls_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

  procedure validate_prtnr_prfls(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0  NUMBER
    , p6_a1  DATE
    , p6_a2  NUMBER
    , p6_a3  DATE
    , p6_a4  NUMBER
    , p6_a5  NUMBER
    , p6_a6  NUMBER
    , p6_a7  NUMBER
    , p6_a8  NUMBER
    , p6_a9  NUMBER
    , p6_a10  NUMBER
    , p6_a11  NUMBER
    , p6_a12  VARCHAR2
    , p6_a13  VARCHAR2
    , p6_a14  VARCHAR2
    , p6_a15  VARCHAR2
    , p6_a16  VARCHAR2
    , p6_a17  VARCHAR2
    , p6_a18  NUMBER
    , p6_a19  NUMBER
    , p6_a20  VARCHAR2
    , p6_a21  VARCHAR2
    , p6_a22  NUMBER
    , p6_a23  VARCHAR2
    , p6_a24  NUMBER
    , p6_a25  NUMBER
    , p6_a26  NUMBER
    , p6_a27  VARCHAR2
    , p6_a28  VARCHAR2
    , p6_a29  VARCHAR2
    , p6_a30  VARCHAR2
    , p6_a31  NUMBER
    , p6_a32  NUMBER
    , p6_a33  NUMBER
    , p6_a34  NUMBER
    , p6_a35  VARCHAR2
  )

  as
    ddp_prtnr_prfls_rec pvx_prtnr_prfls_pvt.prtnr_prfls_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any






    ddp_prtnr_prfls_rec.partner_profile_id := p6_a0;
    ddp_prtnr_prfls_rec.last_update_date := p6_a1;
    ddp_prtnr_prfls_rec.last_updated_by := p6_a2;
    ddp_prtnr_prfls_rec.creation_date := p6_a3;
    ddp_prtnr_prfls_rec.created_by := p6_a4;
    ddp_prtnr_prfls_rec.last_update_login := p6_a5;
    ddp_prtnr_prfls_rec.object_version_number := p6_a6;
    ddp_prtnr_prfls_rec.partner_id := p6_a7;
    ddp_prtnr_prfls_rec.target_revenue_amt := p6_a8;
    ddp_prtnr_prfls_rec.actual_revenue_amt := p6_a9;
    ddp_prtnr_prfls_rec.target_revenue_pct := p6_a10;
    ddp_prtnr_prfls_rec.actual_revenue_pct := p6_a11;
    ddp_prtnr_prfls_rec.orig_system_reference := p6_a12;
    ddp_prtnr_prfls_rec.orig_system_type := p6_a13;
    ddp_prtnr_prfls_rec.capacity_size := p6_a14;
    ddp_prtnr_prfls_rec.capacity_amount := p6_a15;
    ddp_prtnr_prfls_rec.auto_match_allowed_flag := p6_a16;
    ddp_prtnr_prfls_rec.purchase_method := p6_a17;
    ddp_prtnr_prfls_rec.cm_id := p6_a18;
    ddp_prtnr_prfls_rec.ph_support_rep := p6_a19;
    ddp_prtnr_prfls_rec.lead_sharing_status := p6_a20;
    ddp_prtnr_prfls_rec.lead_share_appr_flag := p6_a21;
    ddp_prtnr_prfls_rec.partner_relationship_id := p6_a22;
    ddp_prtnr_prfls_rec.partner_level := p6_a23;
    ddp_prtnr_prfls_rec.preferred_vad_id := p6_a24;
    ddp_prtnr_prfls_rec.partner_group_id := p6_a25;
    ddp_prtnr_prfls_rec.partner_resource_id := p6_a26;
    ddp_prtnr_prfls_rec.partner_group_number := p6_a27;
    ddp_prtnr_prfls_rec.partner_resource_number := p6_a28;
    ddp_prtnr_prfls_rec.sales_partner_flag := p6_a29;
    ddp_prtnr_prfls_rec.indirectly_managed_flag := p6_a30;
    ddp_prtnr_prfls_rec.channel_marketing_manager := p6_a31;
    ddp_prtnr_prfls_rec.related_partner_id := p6_a32;
    ddp_prtnr_prfls_rec.max_users := p6_a33;
    ddp_prtnr_prfls_rec.partner_party_id := p6_a34;
    ddp_prtnr_prfls_rec.status := p6_a35;

    -- here's the delegated call to the old PL/SQL routine
    pvx_prtnr_prfls_pvt.validate_prtnr_prfls(p_api_version,
      p_init_msg_list,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_prtnr_prfls_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






  end;

  procedure check_prtnr_prfls_items(p_validation_mode  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , p2_a0  NUMBER
    , p2_a1  DATE
    , p2_a2  NUMBER
    , p2_a3  DATE
    , p2_a4  NUMBER
    , p2_a5  NUMBER
    , p2_a6  NUMBER
    , p2_a7  NUMBER
    , p2_a8  NUMBER
    , p2_a9  NUMBER
    , p2_a10  NUMBER
    , p2_a11  NUMBER
    , p2_a12  VARCHAR2
    , p2_a13  VARCHAR2
    , p2_a14  VARCHAR2
    , p2_a15  VARCHAR2
    , p2_a16  VARCHAR2
    , p2_a17  VARCHAR2
    , p2_a18  NUMBER
    , p2_a19  NUMBER
    , p2_a20  VARCHAR2
    , p2_a21  VARCHAR2
    , p2_a22  NUMBER
    , p2_a23  VARCHAR2
    , p2_a24  NUMBER
    , p2_a25  NUMBER
    , p2_a26  NUMBER
    , p2_a27  VARCHAR2
    , p2_a28  VARCHAR2
    , p2_a29  VARCHAR2
    , p2_a30  VARCHAR2
    , p2_a31  NUMBER
    , p2_a32  NUMBER
    , p2_a33  NUMBER
    , p2_a34  NUMBER
    , p2_a35  VARCHAR2
  )

  as
    ddp_prtnr_prfls_rec pvx_prtnr_prfls_pvt.prtnr_prfls_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any


    ddp_prtnr_prfls_rec.partner_profile_id := p2_a0;
    ddp_prtnr_prfls_rec.last_update_date := p2_a1;
    ddp_prtnr_prfls_rec.last_updated_by := p2_a2;
    ddp_prtnr_prfls_rec.creation_date := p2_a3;
    ddp_prtnr_prfls_rec.created_by := p2_a4;
    ddp_prtnr_prfls_rec.last_update_login := p2_a5;
    ddp_prtnr_prfls_rec.object_version_number := p2_a6;
    ddp_prtnr_prfls_rec.partner_id := p2_a7;
    ddp_prtnr_prfls_rec.target_revenue_amt := p2_a8;
    ddp_prtnr_prfls_rec.actual_revenue_amt := p2_a9;
    ddp_prtnr_prfls_rec.target_revenue_pct := p2_a10;
    ddp_prtnr_prfls_rec.actual_revenue_pct := p2_a11;
    ddp_prtnr_prfls_rec.orig_system_reference := p2_a12;
    ddp_prtnr_prfls_rec.orig_system_type := p2_a13;
    ddp_prtnr_prfls_rec.capacity_size := p2_a14;
    ddp_prtnr_prfls_rec.capacity_amount := p2_a15;
    ddp_prtnr_prfls_rec.auto_match_allowed_flag := p2_a16;
    ddp_prtnr_prfls_rec.purchase_method := p2_a17;
    ddp_prtnr_prfls_rec.cm_id := p2_a18;
    ddp_prtnr_prfls_rec.ph_support_rep := p2_a19;
    ddp_prtnr_prfls_rec.lead_sharing_status := p2_a20;
    ddp_prtnr_prfls_rec.lead_share_appr_flag := p2_a21;
    ddp_prtnr_prfls_rec.partner_relationship_id := p2_a22;
    ddp_prtnr_prfls_rec.partner_level := p2_a23;
    ddp_prtnr_prfls_rec.preferred_vad_id := p2_a24;
    ddp_prtnr_prfls_rec.partner_group_id := p2_a25;
    ddp_prtnr_prfls_rec.partner_resource_id := p2_a26;
    ddp_prtnr_prfls_rec.partner_group_number := p2_a27;
    ddp_prtnr_prfls_rec.partner_resource_number := p2_a28;
    ddp_prtnr_prfls_rec.sales_partner_flag := p2_a29;
    ddp_prtnr_prfls_rec.indirectly_managed_flag := p2_a30;
    ddp_prtnr_prfls_rec.channel_marketing_manager := p2_a31;
    ddp_prtnr_prfls_rec.related_partner_id := p2_a32;
    ddp_prtnr_prfls_rec.max_users := p2_a33;
    ddp_prtnr_prfls_rec.partner_party_id := p2_a34;
    ddp_prtnr_prfls_rec.status := p2_a35;

    -- here's the delegated call to the old PL/SQL routine
    pvx_prtnr_prfls_pvt.check_prtnr_prfls_items(p_validation_mode,
      x_return_status,
      ddp_prtnr_prfls_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any


  end;

  procedure check_prtnr_prfls_record(p0_a0  NUMBER
    , p0_a1  DATE
    , p0_a2  NUMBER
    , p0_a3  DATE
    , p0_a4  NUMBER
    , p0_a5  NUMBER
    , p0_a6  NUMBER
    , p0_a7  NUMBER
    , p0_a8  NUMBER
    , p0_a9  NUMBER
    , p0_a10  NUMBER
    , p0_a11  NUMBER
    , p0_a12  VARCHAR2
    , p0_a13  VARCHAR2
    , p0_a14  VARCHAR2
    , p0_a15  VARCHAR2
    , p0_a16  VARCHAR2
    , p0_a17  VARCHAR2
    , p0_a18  NUMBER
    , p0_a19  NUMBER
    , p0_a20  VARCHAR2
    , p0_a21  VARCHAR2
    , p0_a22  NUMBER
    , p0_a23  VARCHAR2
    , p0_a24  NUMBER
    , p0_a25  NUMBER
    , p0_a26  NUMBER
    , p0_a27  VARCHAR2
    , p0_a28  VARCHAR2
    , p0_a29  VARCHAR2
    , p0_a30  VARCHAR2
    , p0_a31  NUMBER
    , p0_a32  NUMBER
    , p0_a33  NUMBER
    , p0_a34  NUMBER
    , p0_a35  VARCHAR2
    , p1_a0  NUMBER
    , p1_a1  DATE
    , p1_a2  NUMBER
    , p1_a3  DATE
    , p1_a4  NUMBER
    , p1_a5  NUMBER
    , p1_a6  NUMBER
    , p1_a7  NUMBER
    , p1_a8  NUMBER
    , p1_a9  NUMBER
    , p1_a10  NUMBER
    , p1_a11  NUMBER
    , p1_a12  VARCHAR2
    , p1_a13  VARCHAR2
    , p1_a14  VARCHAR2
    , p1_a15  VARCHAR2
    , p1_a16  VARCHAR2
    , p1_a17  VARCHAR2
    , p1_a18  NUMBER
    , p1_a19  NUMBER
    , p1_a20  VARCHAR2
    , p1_a21  VARCHAR2
    , p1_a22  NUMBER
    , p1_a23  VARCHAR2
    , p1_a24  NUMBER
    , p1_a25  NUMBER
    , p1_a26  NUMBER
    , p1_a27  VARCHAR2
    , p1_a28  VARCHAR2
    , p1_a29  VARCHAR2
    , p1_a30  VARCHAR2
    , p1_a31  NUMBER
    , p1_a32  NUMBER
    , p1_a33  NUMBER
    , p1_a34  NUMBER
    , p1_a35  VARCHAR2
    , p_mode  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
  )

  as
    ddp_prtnr_prfls_rec pvx_prtnr_prfls_pvt.prtnr_prfls_rec_type;
    ddp_complete_rec pvx_prtnr_prfls_pvt.prtnr_prfls_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_prtnr_prfls_rec.partner_profile_id := p0_a0;
    ddp_prtnr_prfls_rec.last_update_date := p0_a1;
    ddp_prtnr_prfls_rec.last_updated_by := p0_a2;
    ddp_prtnr_prfls_rec.creation_date := p0_a3;
    ddp_prtnr_prfls_rec.created_by := p0_a4;
    ddp_prtnr_prfls_rec.last_update_login := p0_a5;
    ddp_prtnr_prfls_rec.object_version_number := p0_a6;
    ddp_prtnr_prfls_rec.partner_id := p0_a7;
    ddp_prtnr_prfls_rec.target_revenue_amt := p0_a8;
    ddp_prtnr_prfls_rec.actual_revenue_amt := p0_a9;
    ddp_prtnr_prfls_rec.target_revenue_pct := p0_a10;
    ddp_prtnr_prfls_rec.actual_revenue_pct := p0_a11;
    ddp_prtnr_prfls_rec.orig_system_reference := p0_a12;
    ddp_prtnr_prfls_rec.orig_system_type := p0_a13;
    ddp_prtnr_prfls_rec.capacity_size := p0_a14;
    ddp_prtnr_prfls_rec.capacity_amount := p0_a15;
    ddp_prtnr_prfls_rec.auto_match_allowed_flag := p0_a16;
    ddp_prtnr_prfls_rec.purchase_method := p0_a17;
    ddp_prtnr_prfls_rec.cm_id := p0_a18;
    ddp_prtnr_prfls_rec.ph_support_rep := p0_a19;
    ddp_prtnr_prfls_rec.lead_sharing_status := p0_a20;
    ddp_prtnr_prfls_rec.lead_share_appr_flag := p0_a21;
    ddp_prtnr_prfls_rec.partner_relationship_id := p0_a22;
    ddp_prtnr_prfls_rec.partner_level := p0_a23;
    ddp_prtnr_prfls_rec.preferred_vad_id := p0_a24;
    ddp_prtnr_prfls_rec.partner_group_id := p0_a25;
    ddp_prtnr_prfls_rec.partner_resource_id := p0_a26;
    ddp_prtnr_prfls_rec.partner_group_number := p0_a27;
    ddp_prtnr_prfls_rec.partner_resource_number := p0_a28;
    ddp_prtnr_prfls_rec.sales_partner_flag := p0_a29;
    ddp_prtnr_prfls_rec.indirectly_managed_flag := p0_a30;
    ddp_prtnr_prfls_rec.channel_marketing_manager := p0_a31;
    ddp_prtnr_prfls_rec.related_partner_id := p0_a32;
    ddp_prtnr_prfls_rec.max_users := p0_a33;
    ddp_prtnr_prfls_rec.partner_party_id := p0_a34;
    ddp_prtnr_prfls_rec.status := p0_a35;

    ddp_complete_rec.partner_profile_id := p1_a0;
    ddp_complete_rec.last_update_date := p1_a1;
    ddp_complete_rec.last_updated_by := p1_a2;
    ddp_complete_rec.creation_date := p1_a3;
    ddp_complete_rec.created_by := p1_a4;
    ddp_complete_rec.last_update_login := p1_a5;
    ddp_complete_rec.object_version_number := p1_a6;
    ddp_complete_rec.partner_id := p1_a7;
    ddp_complete_rec.target_revenue_amt := p1_a8;
    ddp_complete_rec.actual_revenue_amt := p1_a9;
    ddp_complete_rec.target_revenue_pct := p1_a10;
    ddp_complete_rec.actual_revenue_pct := p1_a11;
    ddp_complete_rec.orig_system_reference := p1_a12;
    ddp_complete_rec.orig_system_type := p1_a13;
    ddp_complete_rec.capacity_size := p1_a14;
    ddp_complete_rec.capacity_amount := p1_a15;
    ddp_complete_rec.auto_match_allowed_flag := p1_a16;
    ddp_complete_rec.purchase_method := p1_a17;
    ddp_complete_rec.cm_id := p1_a18;
    ddp_complete_rec.ph_support_rep := p1_a19;
    ddp_complete_rec.lead_sharing_status := p1_a20;
    ddp_complete_rec.lead_share_appr_flag := p1_a21;
    ddp_complete_rec.partner_relationship_id := p1_a22;
    ddp_complete_rec.partner_level := p1_a23;
    ddp_complete_rec.preferred_vad_id := p1_a24;
    ddp_complete_rec.partner_group_id := p1_a25;
    ddp_complete_rec.partner_resource_id := p1_a26;
    ddp_complete_rec.partner_group_number := p1_a27;
    ddp_complete_rec.partner_resource_number := p1_a28;
    ddp_complete_rec.sales_partner_flag := p1_a29;
    ddp_complete_rec.indirectly_managed_flag := p1_a30;
    ddp_complete_rec.channel_marketing_manager := p1_a31;
    ddp_complete_rec.related_partner_id := p1_a32;
    ddp_complete_rec.max_users := p1_a33;
    ddp_complete_rec.partner_party_id := p1_a34;
    ddp_complete_rec.status := p1_a35;



    -- here's the delegated call to the old PL/SQL routine
    pvx_prtnr_prfls_pvt.check_prtnr_prfls_record(ddp_prtnr_prfls_rec,
      ddp_complete_rec,
      p_mode,
      x_return_status);

    -- copy data back from the local variables to OUT or IN-OUT args, if any



  end;

  procedure init_prtnr_prfls_rec(p0_a0 out nocopy  NUMBER
    , p0_a1 out nocopy  DATE
    , p0_a2 out nocopy  NUMBER
    , p0_a3 out nocopy  DATE
    , p0_a4 out nocopy  NUMBER
    , p0_a5 out nocopy  NUMBER
    , p0_a6 out nocopy  NUMBER
    , p0_a7 out nocopy  NUMBER
    , p0_a8 out nocopy  NUMBER
    , p0_a9 out nocopy  NUMBER
    , p0_a10 out nocopy  NUMBER
    , p0_a11 out nocopy  NUMBER
    , p0_a12 out nocopy  VARCHAR2
    , p0_a13 out nocopy  VARCHAR2
    , p0_a14 out nocopy  VARCHAR2
    , p0_a15 out nocopy  VARCHAR2
    , p0_a16 out nocopy  VARCHAR2
    , p0_a17 out nocopy  VARCHAR2
    , p0_a18 out nocopy  NUMBER
    , p0_a19 out nocopy  NUMBER
    , p0_a20 out nocopy  VARCHAR2
    , p0_a21 out nocopy  VARCHAR2
    , p0_a22 out nocopy  NUMBER
    , p0_a23 out nocopy  VARCHAR2
    , p0_a24 out nocopy  NUMBER
    , p0_a25 out nocopy  NUMBER
    , p0_a26 out nocopy  NUMBER
    , p0_a27 out nocopy  VARCHAR2
    , p0_a28 out nocopy  VARCHAR2
    , p0_a29 out nocopy  VARCHAR2
    , p0_a30 out nocopy  VARCHAR2
    , p0_a31 out nocopy  NUMBER
    , p0_a32 out nocopy  NUMBER
    , p0_a33 out nocopy  NUMBER
    , p0_a34 out nocopy  NUMBER
    , p0_a35 out nocopy  VARCHAR2
  )

  as
    ddx_prtnr_prfls_rec pvx_prtnr_prfls_pvt.prtnr_prfls_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    -- here's the delegated call to the old PL/SQL routine
    pvx_prtnr_prfls_pvt.init_prtnr_prfls_rec(ddx_prtnr_prfls_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any
    p0_a0 := ddx_prtnr_prfls_rec.partner_profile_id;
    p0_a1 := ddx_prtnr_prfls_rec.last_update_date;
    p0_a2 := ddx_prtnr_prfls_rec.last_updated_by;
    p0_a3 := ddx_prtnr_prfls_rec.creation_date;
    p0_a4 := ddx_prtnr_prfls_rec.created_by;
    p0_a5 := ddx_prtnr_prfls_rec.last_update_login;
    p0_a6 := ddx_prtnr_prfls_rec.object_version_number;
    p0_a7 := ddx_prtnr_prfls_rec.partner_id;
    p0_a8 := ddx_prtnr_prfls_rec.target_revenue_amt;
    p0_a9 := ddx_prtnr_prfls_rec.actual_revenue_amt;
    p0_a10 := ddx_prtnr_prfls_rec.target_revenue_pct;
    p0_a11 := ddx_prtnr_prfls_rec.actual_revenue_pct;
    p0_a12 := ddx_prtnr_prfls_rec.orig_system_reference;
    p0_a13 := ddx_prtnr_prfls_rec.orig_system_type;
    p0_a14 := ddx_prtnr_prfls_rec.capacity_size;
    p0_a15 := ddx_prtnr_prfls_rec.capacity_amount;
    p0_a16 := ddx_prtnr_prfls_rec.auto_match_allowed_flag;
    p0_a17 := ddx_prtnr_prfls_rec.purchase_method;
    p0_a18 := ddx_prtnr_prfls_rec.cm_id;
    p0_a19 := ddx_prtnr_prfls_rec.ph_support_rep;
    p0_a20 := ddx_prtnr_prfls_rec.lead_sharing_status;
    p0_a21 := ddx_prtnr_prfls_rec.lead_share_appr_flag;
    p0_a22 := ddx_prtnr_prfls_rec.partner_relationship_id;
    p0_a23 := ddx_prtnr_prfls_rec.partner_level;
    p0_a24 := ddx_prtnr_prfls_rec.preferred_vad_id;
    p0_a25 := ddx_prtnr_prfls_rec.partner_group_id;
    p0_a26 := ddx_prtnr_prfls_rec.partner_resource_id;
    p0_a27 := ddx_prtnr_prfls_rec.partner_group_number;
    p0_a28 := ddx_prtnr_prfls_rec.partner_resource_number;
    p0_a29 := ddx_prtnr_prfls_rec.sales_partner_flag;
    p0_a30 := ddx_prtnr_prfls_rec.indirectly_managed_flag;
    p0_a31 := ddx_prtnr_prfls_rec.channel_marketing_manager;
    p0_a32 := ddx_prtnr_prfls_rec.related_partner_id;
    p0_a33 := ddx_prtnr_prfls_rec.max_users;
    p0_a34 := ddx_prtnr_prfls_rec.partner_party_id;
    p0_a35 := ddx_prtnr_prfls_rec.status;
  end;

  procedure complete_prtnr_prfls_rec(p0_a0  NUMBER
    , p0_a1  DATE
    , p0_a2  NUMBER
    , p0_a3  DATE
    , p0_a4  NUMBER
    , p0_a5  NUMBER
    , p0_a6  NUMBER
    , p0_a7  NUMBER
    , p0_a8  NUMBER
    , p0_a9  NUMBER
    , p0_a10  NUMBER
    , p0_a11  NUMBER
    , p0_a12  VARCHAR2
    , p0_a13  VARCHAR2
    , p0_a14  VARCHAR2
    , p0_a15  VARCHAR2
    , p0_a16  VARCHAR2
    , p0_a17  VARCHAR2
    , p0_a18  NUMBER
    , p0_a19  NUMBER
    , p0_a20  VARCHAR2
    , p0_a21  VARCHAR2
    , p0_a22  NUMBER
    , p0_a23  VARCHAR2
    , p0_a24  NUMBER
    , p0_a25  NUMBER
    , p0_a26  NUMBER
    , p0_a27  VARCHAR2
    , p0_a28  VARCHAR2
    , p0_a29  VARCHAR2
    , p0_a30  VARCHAR2
    , p0_a31  NUMBER
    , p0_a32  NUMBER
    , p0_a33  NUMBER
    , p0_a34  NUMBER
    , p0_a35  VARCHAR2
    , p1_a0 out nocopy  NUMBER
    , p1_a1 out nocopy  DATE
    , p1_a2 out nocopy  NUMBER
    , p1_a3 out nocopy  DATE
    , p1_a4 out nocopy  NUMBER
    , p1_a5 out nocopy  NUMBER
    , p1_a6 out nocopy  NUMBER
    , p1_a7 out nocopy  NUMBER
    , p1_a8 out nocopy  NUMBER
    , p1_a9 out nocopy  NUMBER
    , p1_a10 out nocopy  NUMBER
    , p1_a11 out nocopy  NUMBER
    , p1_a12 out nocopy  VARCHAR2
    , p1_a13 out nocopy  VARCHAR2
    , p1_a14 out nocopy  VARCHAR2
    , p1_a15 out nocopy  VARCHAR2
    , p1_a16 out nocopy  VARCHAR2
    , p1_a17 out nocopy  VARCHAR2
    , p1_a18 out nocopy  NUMBER
    , p1_a19 out nocopy  NUMBER
    , p1_a20 out nocopy  VARCHAR2
    , p1_a21 out nocopy  VARCHAR2
    , p1_a22 out nocopy  NUMBER
    , p1_a23 out nocopy  VARCHAR2
    , p1_a24 out nocopy  NUMBER
    , p1_a25 out nocopy  NUMBER
    , p1_a26 out nocopy  NUMBER
    , p1_a27 out nocopy  VARCHAR2
    , p1_a28 out nocopy  VARCHAR2
    , p1_a29 out nocopy  VARCHAR2
    , p1_a30 out nocopy  VARCHAR2
    , p1_a31 out nocopy  NUMBER
    , p1_a32 out nocopy  NUMBER
    , p1_a33 out nocopy  NUMBER
    , p1_a34 out nocopy  NUMBER
    , p1_a35 out nocopy  VARCHAR2
  )

  as
    ddp_prtnr_prfls_rec pvx_prtnr_prfls_pvt.prtnr_prfls_rec_type;
    ddx_complete_rec pvx_prtnr_prfls_pvt.prtnr_prfls_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_prtnr_prfls_rec.partner_profile_id := p0_a0;
    ddp_prtnr_prfls_rec.last_update_date := p0_a1;
    ddp_prtnr_prfls_rec.last_updated_by := p0_a2;
    ddp_prtnr_prfls_rec.creation_date := p0_a3;
    ddp_prtnr_prfls_rec.created_by := p0_a4;
    ddp_prtnr_prfls_rec.last_update_login := p0_a5;
    ddp_prtnr_prfls_rec.object_version_number := p0_a6;
    ddp_prtnr_prfls_rec.partner_id := p0_a7;
    ddp_prtnr_prfls_rec.target_revenue_amt := p0_a8;
    ddp_prtnr_prfls_rec.actual_revenue_amt := p0_a9;
    ddp_prtnr_prfls_rec.target_revenue_pct := p0_a10;
    ddp_prtnr_prfls_rec.actual_revenue_pct := p0_a11;
    ddp_prtnr_prfls_rec.orig_system_reference := p0_a12;
    ddp_prtnr_prfls_rec.orig_system_type := p0_a13;
    ddp_prtnr_prfls_rec.capacity_size := p0_a14;
    ddp_prtnr_prfls_rec.capacity_amount := p0_a15;
    ddp_prtnr_prfls_rec.auto_match_allowed_flag := p0_a16;
    ddp_prtnr_prfls_rec.purchase_method := p0_a17;
    ddp_prtnr_prfls_rec.cm_id := p0_a18;
    ddp_prtnr_prfls_rec.ph_support_rep := p0_a19;
    ddp_prtnr_prfls_rec.lead_sharing_status := p0_a20;
    ddp_prtnr_prfls_rec.lead_share_appr_flag := p0_a21;
    ddp_prtnr_prfls_rec.partner_relationship_id := p0_a22;
    ddp_prtnr_prfls_rec.partner_level := p0_a23;
    ddp_prtnr_prfls_rec.preferred_vad_id := p0_a24;
    ddp_prtnr_prfls_rec.partner_group_id := p0_a25;
    ddp_prtnr_prfls_rec.partner_resource_id := p0_a26;
    ddp_prtnr_prfls_rec.partner_group_number := p0_a27;
    ddp_prtnr_prfls_rec.partner_resource_number := p0_a28;
    ddp_prtnr_prfls_rec.sales_partner_flag := p0_a29;
    ddp_prtnr_prfls_rec.indirectly_managed_flag := p0_a30;
    ddp_prtnr_prfls_rec.channel_marketing_manager := p0_a31;
    ddp_prtnr_prfls_rec.related_partner_id := p0_a32;
    ddp_prtnr_prfls_rec.max_users := p0_a33;
    ddp_prtnr_prfls_rec.partner_party_id := p0_a34;
    ddp_prtnr_prfls_rec.status := p0_a35;


    -- here's the delegated call to the old PL/SQL routine
    pvx_prtnr_prfls_pvt.complete_prtnr_prfls_rec(ddp_prtnr_prfls_rec,
      ddx_complete_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any

    p1_a0 := ddx_complete_rec.partner_profile_id;
    p1_a1 := ddx_complete_rec.last_update_date;
    p1_a2 := ddx_complete_rec.last_updated_by;
    p1_a3 := ddx_complete_rec.creation_date;
    p1_a4 := ddx_complete_rec.created_by;
    p1_a5 := ddx_complete_rec.last_update_login;
    p1_a6 := ddx_complete_rec.object_version_number;
    p1_a7 := ddx_complete_rec.partner_id;
    p1_a8 := ddx_complete_rec.target_revenue_amt;
    p1_a9 := ddx_complete_rec.actual_revenue_amt;
    p1_a10 := ddx_complete_rec.target_revenue_pct;
    p1_a11 := ddx_complete_rec.actual_revenue_pct;
    p1_a12 := ddx_complete_rec.orig_system_reference;
    p1_a13 := ddx_complete_rec.orig_system_type;
    p1_a14 := ddx_complete_rec.capacity_size;
    p1_a15 := ddx_complete_rec.capacity_amount;
    p1_a16 := ddx_complete_rec.auto_match_allowed_flag;
    p1_a17 := ddx_complete_rec.purchase_method;
    p1_a18 := ddx_complete_rec.cm_id;
    p1_a19 := ddx_complete_rec.ph_support_rep;
    p1_a20 := ddx_complete_rec.lead_sharing_status;
    p1_a21 := ddx_complete_rec.lead_share_appr_flag;
    p1_a22 := ddx_complete_rec.partner_relationship_id;
    p1_a23 := ddx_complete_rec.partner_level;
    p1_a24 := ddx_complete_rec.preferred_vad_id;
    p1_a25 := ddx_complete_rec.partner_group_id;
    p1_a26 := ddx_complete_rec.partner_resource_id;
    p1_a27 := ddx_complete_rec.partner_group_number;
    p1_a28 := ddx_complete_rec.partner_resource_number;
    p1_a29 := ddx_complete_rec.sales_partner_flag;
    p1_a30 := ddx_complete_rec.indirectly_managed_flag;
    p1_a31 := ddx_complete_rec.channel_marketing_manager;
    p1_a32 := ddx_complete_rec.related_partner_id;
    p1_a33 := ddx_complete_rec.max_users;
    p1_a34 := ddx_complete_rec.partner_party_id;
    p1_a35 := ddx_complete_rec.status;
  end;

  procedure determine_partner_status(p0_a0  NUMBER
    , p0_a1  DATE
    , p0_a2  NUMBER
    , p0_a3  DATE
    , p0_a4  NUMBER
    , p0_a5  NUMBER
    , p0_a6  NUMBER
    , p0_a7  NUMBER
    , p0_a8  NUMBER
    , p0_a9  NUMBER
    , p0_a10  NUMBER
    , p0_a11  NUMBER
    , p0_a12  VARCHAR2
    , p0_a13  VARCHAR2
    , p0_a14  VARCHAR2
    , p0_a15  VARCHAR2
    , p0_a16  VARCHAR2
    , p0_a17  VARCHAR2
    , p0_a18  NUMBER
    , p0_a19  NUMBER
    , p0_a20  VARCHAR2
    , p0_a21  VARCHAR2
    , p0_a22  NUMBER
    , p0_a23  VARCHAR2
    , p0_a24  NUMBER
    , p0_a25  NUMBER
    , p0_a26  NUMBER
    , p0_a27  VARCHAR2
    , p0_a28  VARCHAR2
    , p0_a29  VARCHAR2
    , p0_a30  VARCHAR2
    , p0_a31  NUMBER
    , p0_a32  NUMBER
    , p0_a33  NUMBER
    , p0_a34  NUMBER
    , p0_a35  VARCHAR2
    , x_partner_status out nocopy  VARCHAR2
  )

  as
    ddp_prtnr_prfls_rec pvx_prtnr_prfls_pvt.prtnr_prfls_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_prtnr_prfls_rec.partner_profile_id := p0_a0;
    ddp_prtnr_prfls_rec.last_update_date := p0_a1;
    ddp_prtnr_prfls_rec.last_updated_by := p0_a2;
    ddp_prtnr_prfls_rec.creation_date := p0_a3;
    ddp_prtnr_prfls_rec.created_by := p0_a4;
    ddp_prtnr_prfls_rec.last_update_login := p0_a5;
    ddp_prtnr_prfls_rec.object_version_number := p0_a6;
    ddp_prtnr_prfls_rec.partner_id := p0_a7;
    ddp_prtnr_prfls_rec.target_revenue_amt := p0_a8;
    ddp_prtnr_prfls_rec.actual_revenue_amt := p0_a9;
    ddp_prtnr_prfls_rec.target_revenue_pct := p0_a10;
    ddp_prtnr_prfls_rec.actual_revenue_pct := p0_a11;
    ddp_prtnr_prfls_rec.orig_system_reference := p0_a12;
    ddp_prtnr_prfls_rec.orig_system_type := p0_a13;
    ddp_prtnr_prfls_rec.capacity_size := p0_a14;
    ddp_prtnr_prfls_rec.capacity_amount := p0_a15;
    ddp_prtnr_prfls_rec.auto_match_allowed_flag := p0_a16;
    ddp_prtnr_prfls_rec.purchase_method := p0_a17;
    ddp_prtnr_prfls_rec.cm_id := p0_a18;
    ddp_prtnr_prfls_rec.ph_support_rep := p0_a19;
    ddp_prtnr_prfls_rec.lead_sharing_status := p0_a20;
    ddp_prtnr_prfls_rec.lead_share_appr_flag := p0_a21;
    ddp_prtnr_prfls_rec.partner_relationship_id := p0_a22;
    ddp_prtnr_prfls_rec.partner_level := p0_a23;
    ddp_prtnr_prfls_rec.preferred_vad_id := p0_a24;
    ddp_prtnr_prfls_rec.partner_group_id := p0_a25;
    ddp_prtnr_prfls_rec.partner_resource_id := p0_a26;
    ddp_prtnr_prfls_rec.partner_group_number := p0_a27;
    ddp_prtnr_prfls_rec.partner_resource_number := p0_a28;
    ddp_prtnr_prfls_rec.sales_partner_flag := p0_a29;
    ddp_prtnr_prfls_rec.indirectly_managed_flag := p0_a30;
    ddp_prtnr_prfls_rec.channel_marketing_manager := p0_a31;
    ddp_prtnr_prfls_rec.related_partner_id := p0_a32;
    ddp_prtnr_prfls_rec.max_users := p0_a33;
    ddp_prtnr_prfls_rec.partner_party_id := p0_a34;
    ddp_prtnr_prfls_rec.status := p0_a35;


    -- here's the delegated call to the old PL/SQL routine
    pvx_prtnr_prfls_pvt.determine_partner_status(ddp_prtnr_prfls_rec,
      x_partner_status);

    -- copy data back from the local variables to OUT or IN-OUT args, if any

  end;

end pvx_prtnr_prfls_pvt_w;

/
