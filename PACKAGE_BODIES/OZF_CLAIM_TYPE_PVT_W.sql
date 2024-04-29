--------------------------------------------------------
--  DDL for Package Body OZF_CLAIM_TYPE_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_CLAIM_TYPE_PVT_W" as
  /* $Header: ozfwclmb.pls 120.1 2006/05/17 01:15:48 sshivali noship $ */
  rosetta_g_mistake_date date := to_date('01/01/+4713', 'MM/DD/SYYYY');
  rosetta_g_miss_date date := to_date('01/01/-4712', 'MM/DD/SYYYY');
  rosetta_g_mistake_date_high date := to_date('01/01/+4710', 'MM/DD/SYYYY');
  rosetta_g_mistake_date_low date := to_date('01/01/-4710', 'MM/DD/SYYYY');

  -- this is to workaround the JDBC bug regarding IN DATE of value GMiss
  function rosetta_g_miss_date_in_map(d date) return date as
  begin
    if d > rosetta_g_mistake_date_high then return fnd_api.g_miss_date; end if;
    if d < rosetta_g_mistake_date_low then return fnd_api.g_miss_date; end if;
    return d;
  end;

  procedure create_claim_type(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0  NUMBER
    , p7_a1  NUMBER
    , p7_a2  DATE
    , p7_a3  NUMBER
    , p7_a4  DATE
    , p7_a5  NUMBER
    , p7_a6  NUMBER
    , p7_a7  NUMBER
    , p7_a8  NUMBER
    , p7_a9  DATE
    , p7_a10  NUMBER
    , p7_a11  VARCHAR2
    , p7_a12  VARCHAR2
    , p7_a13  NUMBER
    , p7_a14  VARCHAR2
    , p7_a15  DATE
    , p7_a16  DATE
    , p7_a17  VARCHAR2
    , p7_a18  NUMBER
    , p7_a19  NUMBER
    , p7_a20  NUMBER
    , p7_a21  NUMBER
    , p7_a22  NUMBER
    , p7_a23  NUMBER
    , p7_a24  NUMBER
    , p7_a25  NUMBER
    , p7_a26  NUMBER
    , p7_a27  NUMBER
    , p7_a28  VARCHAR2
    , p7_a29  VARCHAR2
    , p7_a30  VARCHAR2
    , p7_a31  VARCHAR2
    , p7_a32  VARCHAR2
    , p7_a33  VARCHAR2
    , p7_a34  VARCHAR2
    , p7_a35  VARCHAR2
    , p7_a36  VARCHAR2
    , p7_a37  VARCHAR2
    , p7_a38  VARCHAR2
    , p7_a39  VARCHAR2
    , p7_a40  VARCHAR2
    , p7_a41  VARCHAR2
    , p7_a42  VARCHAR2
    , p7_a43  VARCHAR2
    , p7_a44  NUMBER
    , p7_a45  VARCHAR2
    , p7_a46  VARCHAR2
    , p7_a47  VARCHAR2
    , p7_a48  VARCHAR2
    , p7_a49  VARCHAR2
    , p7_a50  NUMBER
    , p7_a51  NUMBER
    , p7_a52  VARCHAR2
    , x_claim_type_id out nocopy  NUMBER
  )

  as
    ddp_claim_rec ozf_claim_type_pvt.claim_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_claim_rec.claim_type_id := p7_a0;
    ddp_claim_rec.object_version_number := p7_a1;
    ddp_claim_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a2);
    ddp_claim_rec.last_updated_by := p7_a3;
    ddp_claim_rec.creation_date := rosetta_g_miss_date_in_map(p7_a4);
    ddp_claim_rec.created_by := p7_a5;
    ddp_claim_rec.last_update_login := p7_a6;
    ddp_claim_rec.request_id := p7_a7;
    ddp_claim_rec.program_application_id := p7_a8;
    ddp_claim_rec.program_update_date := rosetta_g_miss_date_in_map(p7_a9);
    ddp_claim_rec.program_id := p7_a10;
    ddp_claim_rec.created_from := p7_a11;
    ddp_claim_rec.claim_class := p7_a12;
    ddp_claim_rec.set_of_books_id := p7_a13;
    ddp_claim_rec.post_to_gl_flag := p7_a14;
    ddp_claim_rec.start_date := rosetta_g_miss_date_in_map(p7_a15);
    ddp_claim_rec.end_date := rosetta_g_miss_date_in_map(p7_a16);
    ddp_claim_rec.creation_sign := p7_a17;
    ddp_claim_rec.gl_id_ded_adj := p7_a18;
    ddp_claim_rec.gl_id_ded_adj_clearing := p7_a19;
    ddp_claim_rec.gl_id_ded_clearing := p7_a20;
    ddp_claim_rec.gl_id_accr_promo_liab := p7_a21;
    ddp_claim_rec.transaction_type := p7_a22;
    ddp_claim_rec.cm_trx_type_id := p7_a23;
    ddp_claim_rec.dm_trx_type_id := p7_a24;
    ddp_claim_rec.cb_trx_type_id := p7_a25;
    ddp_claim_rec.wo_rec_trx_id := p7_a26;
    ddp_claim_rec.adj_rec_trx_id := p7_a27;
    ddp_claim_rec.attribute_category := p7_a28;
    ddp_claim_rec.attribute1 := p7_a29;
    ddp_claim_rec.attribute2 := p7_a30;
    ddp_claim_rec.attribute3 := p7_a31;
    ddp_claim_rec.attribute4 := p7_a32;
    ddp_claim_rec.attribute5 := p7_a33;
    ddp_claim_rec.attribute6 := p7_a34;
    ddp_claim_rec.attribute7 := p7_a35;
    ddp_claim_rec.attribute8 := p7_a36;
    ddp_claim_rec.attribute9 := p7_a37;
    ddp_claim_rec.attribute10 := p7_a38;
    ddp_claim_rec.attribute11 := p7_a39;
    ddp_claim_rec.attribute12 := p7_a40;
    ddp_claim_rec.attribute13 := p7_a41;
    ddp_claim_rec.attribute14 := p7_a42;
    ddp_claim_rec.attribute15 := p7_a43;
    ddp_claim_rec.org_id := p7_a44;
    ddp_claim_rec.name := p7_a45;
    ddp_claim_rec.description := p7_a46;
    ddp_claim_rec.language := p7_a47;
    ddp_claim_rec.source_lang := p7_a48;
    ddp_claim_rec.adjustment_type := p7_a49;
    ddp_claim_rec.order_type_id := p7_a50;
    ddp_claim_rec.neg_wo_rec_trx_id := p7_a51;
    ddp_claim_rec.gl_balancing_flex_value := p7_a52;


    -- here's the delegated call to the old PL/SQL routine
    ozf_claim_type_pvt.create_claim_type(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_claim_rec,
      x_claim_type_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

  procedure update_claim_type(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0  NUMBER
    , p7_a1  NUMBER
    , p7_a2  DATE
    , p7_a3  NUMBER
    , p7_a4  DATE
    , p7_a5  NUMBER
    , p7_a6  NUMBER
    , p7_a7  NUMBER
    , p7_a8  NUMBER
    , p7_a9  DATE
    , p7_a10  NUMBER
    , p7_a11  VARCHAR2
    , p7_a12  VARCHAR2
    , p7_a13  NUMBER
    , p7_a14  VARCHAR2
    , p7_a15  DATE
    , p7_a16  DATE
    , p7_a17  VARCHAR2
    , p7_a18  NUMBER
    , p7_a19  NUMBER
    , p7_a20  NUMBER
    , p7_a21  NUMBER
    , p7_a22  NUMBER
    , p7_a23  NUMBER
    , p7_a24  NUMBER
    , p7_a25  NUMBER
    , p7_a26  NUMBER
    , p7_a27  NUMBER
    , p7_a28  VARCHAR2
    , p7_a29  VARCHAR2
    , p7_a30  VARCHAR2
    , p7_a31  VARCHAR2
    , p7_a32  VARCHAR2
    , p7_a33  VARCHAR2
    , p7_a34  VARCHAR2
    , p7_a35  VARCHAR2
    , p7_a36  VARCHAR2
    , p7_a37  VARCHAR2
    , p7_a38  VARCHAR2
    , p7_a39  VARCHAR2
    , p7_a40  VARCHAR2
    , p7_a41  VARCHAR2
    , p7_a42  VARCHAR2
    , p7_a43  VARCHAR2
    , p7_a44  NUMBER
    , p7_a45  VARCHAR2
    , p7_a46  VARCHAR2
    , p7_a47  VARCHAR2
    , p7_a48  VARCHAR2
    , p7_a49  VARCHAR2
    , p7_a50  NUMBER
    , p7_a51  NUMBER
    , p7_a52  VARCHAR2
    , p_mode  VARCHAR2
    , x_object_version out nocopy  NUMBER
  )

  as
    ddp_claim_rec ozf_claim_type_pvt.claim_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_claim_rec.claim_type_id := p7_a0;
    ddp_claim_rec.object_version_number := p7_a1;
    ddp_claim_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a2);
    ddp_claim_rec.last_updated_by := p7_a3;
    ddp_claim_rec.creation_date := rosetta_g_miss_date_in_map(p7_a4);
    ddp_claim_rec.created_by := p7_a5;
    ddp_claim_rec.last_update_login := p7_a6;
    ddp_claim_rec.request_id := p7_a7;
    ddp_claim_rec.program_application_id := p7_a8;
    ddp_claim_rec.program_update_date := rosetta_g_miss_date_in_map(p7_a9);
    ddp_claim_rec.program_id := p7_a10;
    ddp_claim_rec.created_from := p7_a11;
    ddp_claim_rec.claim_class := p7_a12;
    ddp_claim_rec.set_of_books_id := p7_a13;
    ddp_claim_rec.post_to_gl_flag := p7_a14;
    ddp_claim_rec.start_date := rosetta_g_miss_date_in_map(p7_a15);
    ddp_claim_rec.end_date := rosetta_g_miss_date_in_map(p7_a16);
    ddp_claim_rec.creation_sign := p7_a17;
    ddp_claim_rec.gl_id_ded_adj := p7_a18;
    ddp_claim_rec.gl_id_ded_adj_clearing := p7_a19;
    ddp_claim_rec.gl_id_ded_clearing := p7_a20;
    ddp_claim_rec.gl_id_accr_promo_liab := p7_a21;
    ddp_claim_rec.transaction_type := p7_a22;
    ddp_claim_rec.cm_trx_type_id := p7_a23;
    ddp_claim_rec.dm_trx_type_id := p7_a24;
    ddp_claim_rec.cb_trx_type_id := p7_a25;
    ddp_claim_rec.wo_rec_trx_id := p7_a26;
    ddp_claim_rec.adj_rec_trx_id := p7_a27;
    ddp_claim_rec.attribute_category := p7_a28;
    ddp_claim_rec.attribute1 := p7_a29;
    ddp_claim_rec.attribute2 := p7_a30;
    ddp_claim_rec.attribute3 := p7_a31;
    ddp_claim_rec.attribute4 := p7_a32;
    ddp_claim_rec.attribute5 := p7_a33;
    ddp_claim_rec.attribute6 := p7_a34;
    ddp_claim_rec.attribute7 := p7_a35;
    ddp_claim_rec.attribute8 := p7_a36;
    ddp_claim_rec.attribute9 := p7_a37;
    ddp_claim_rec.attribute10 := p7_a38;
    ddp_claim_rec.attribute11 := p7_a39;
    ddp_claim_rec.attribute12 := p7_a40;
    ddp_claim_rec.attribute13 := p7_a41;
    ddp_claim_rec.attribute14 := p7_a42;
    ddp_claim_rec.attribute15 := p7_a43;
    ddp_claim_rec.org_id := p7_a44;
    ddp_claim_rec.name := p7_a45;
    ddp_claim_rec.description := p7_a46;
    ddp_claim_rec.language := p7_a47;
    ddp_claim_rec.source_lang := p7_a48;
    ddp_claim_rec.adjustment_type := p7_a49;
    ddp_claim_rec.order_type_id := p7_a50;
    ddp_claim_rec.neg_wo_rec_trx_id := p7_a51;
    ddp_claim_rec.gl_balancing_flex_value := p7_a52;



    -- here's the delegated call to the old PL/SQL routine
    ozf_claim_type_pvt.update_claim_type(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_claim_rec,
      p_mode,
      x_object_version);

    -- copy data back from the local variables to OUT or IN-OUT args, if any









  end;

  procedure validate_claim_type(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0  NUMBER
    , p6_a1  NUMBER
    , p6_a2  DATE
    , p6_a3  NUMBER
    , p6_a4  DATE
    , p6_a5  NUMBER
    , p6_a6  NUMBER
    , p6_a7  NUMBER
    , p6_a8  NUMBER
    , p6_a9  DATE
    , p6_a10  NUMBER
    , p6_a11  VARCHAR2
    , p6_a12  VARCHAR2
    , p6_a13  NUMBER
    , p6_a14  VARCHAR2
    , p6_a15  DATE
    , p6_a16  DATE
    , p6_a17  VARCHAR2
    , p6_a18  NUMBER
    , p6_a19  NUMBER
    , p6_a20  NUMBER
    , p6_a21  NUMBER
    , p6_a22  NUMBER
    , p6_a23  NUMBER
    , p6_a24  NUMBER
    , p6_a25  NUMBER
    , p6_a26  NUMBER
    , p6_a27  NUMBER
    , p6_a28  VARCHAR2
    , p6_a29  VARCHAR2
    , p6_a30  VARCHAR2
    , p6_a31  VARCHAR2
    , p6_a32  VARCHAR2
    , p6_a33  VARCHAR2
    , p6_a34  VARCHAR2
    , p6_a35  VARCHAR2
    , p6_a36  VARCHAR2
    , p6_a37  VARCHAR2
    , p6_a38  VARCHAR2
    , p6_a39  VARCHAR2
    , p6_a40  VARCHAR2
    , p6_a41  VARCHAR2
    , p6_a42  VARCHAR2
    , p6_a43  VARCHAR2
    , p6_a44  NUMBER
    , p6_a45  VARCHAR2
    , p6_a46  VARCHAR2
    , p6_a47  VARCHAR2
    , p6_a48  VARCHAR2
    , p6_a49  VARCHAR2
    , p6_a50  NUMBER
    , p6_a51  NUMBER
    , p6_a52  VARCHAR2
  )

  as
    ddp_claim_rec ozf_claim_type_pvt.claim_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any






    ddp_claim_rec.claim_type_id := p6_a0;
    ddp_claim_rec.object_version_number := p6_a1;
    ddp_claim_rec.last_update_date := rosetta_g_miss_date_in_map(p6_a2);
    ddp_claim_rec.last_updated_by := p6_a3;
    ddp_claim_rec.creation_date := rosetta_g_miss_date_in_map(p6_a4);
    ddp_claim_rec.created_by := p6_a5;
    ddp_claim_rec.last_update_login := p6_a6;
    ddp_claim_rec.request_id := p6_a7;
    ddp_claim_rec.program_application_id := p6_a8;
    ddp_claim_rec.program_update_date := rosetta_g_miss_date_in_map(p6_a9);
    ddp_claim_rec.program_id := p6_a10;
    ddp_claim_rec.created_from := p6_a11;
    ddp_claim_rec.claim_class := p6_a12;
    ddp_claim_rec.set_of_books_id := p6_a13;
    ddp_claim_rec.post_to_gl_flag := p6_a14;
    ddp_claim_rec.start_date := rosetta_g_miss_date_in_map(p6_a15);
    ddp_claim_rec.end_date := rosetta_g_miss_date_in_map(p6_a16);
    ddp_claim_rec.creation_sign := p6_a17;
    ddp_claim_rec.gl_id_ded_adj := p6_a18;
    ddp_claim_rec.gl_id_ded_adj_clearing := p6_a19;
    ddp_claim_rec.gl_id_ded_clearing := p6_a20;
    ddp_claim_rec.gl_id_accr_promo_liab := p6_a21;
    ddp_claim_rec.transaction_type := p6_a22;
    ddp_claim_rec.cm_trx_type_id := p6_a23;
    ddp_claim_rec.dm_trx_type_id := p6_a24;
    ddp_claim_rec.cb_trx_type_id := p6_a25;
    ddp_claim_rec.wo_rec_trx_id := p6_a26;
    ddp_claim_rec.adj_rec_trx_id := p6_a27;
    ddp_claim_rec.attribute_category := p6_a28;
    ddp_claim_rec.attribute1 := p6_a29;
    ddp_claim_rec.attribute2 := p6_a30;
    ddp_claim_rec.attribute3 := p6_a31;
    ddp_claim_rec.attribute4 := p6_a32;
    ddp_claim_rec.attribute5 := p6_a33;
    ddp_claim_rec.attribute6 := p6_a34;
    ddp_claim_rec.attribute7 := p6_a35;
    ddp_claim_rec.attribute8 := p6_a36;
    ddp_claim_rec.attribute9 := p6_a37;
    ddp_claim_rec.attribute10 := p6_a38;
    ddp_claim_rec.attribute11 := p6_a39;
    ddp_claim_rec.attribute12 := p6_a40;
    ddp_claim_rec.attribute13 := p6_a41;
    ddp_claim_rec.attribute14 := p6_a42;
    ddp_claim_rec.attribute15 := p6_a43;
    ddp_claim_rec.org_id := p6_a44;
    ddp_claim_rec.name := p6_a45;
    ddp_claim_rec.description := p6_a46;
    ddp_claim_rec.language := p6_a47;
    ddp_claim_rec.source_lang := p6_a48;
    ddp_claim_rec.adjustment_type := p6_a49;
    ddp_claim_rec.order_type_id := p6_a50;
    ddp_claim_rec.neg_wo_rec_trx_id := p6_a51;
    ddp_claim_rec.gl_balancing_flex_value := p6_a52;

    -- here's the delegated call to the old PL/SQL routine
    ozf_claim_type_pvt.validate_claim_type(p_api_version,
      p_init_msg_list,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_claim_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






  end;

  procedure check_claim_type_items(p_validation_mode  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , p2_a0  NUMBER
    , p2_a1  NUMBER
    , p2_a2  DATE
    , p2_a3  NUMBER
    , p2_a4  DATE
    , p2_a5  NUMBER
    , p2_a6  NUMBER
    , p2_a7  NUMBER
    , p2_a8  NUMBER
    , p2_a9  DATE
    , p2_a10  NUMBER
    , p2_a11  VARCHAR2
    , p2_a12  VARCHAR2
    , p2_a13  NUMBER
    , p2_a14  VARCHAR2
    , p2_a15  DATE
    , p2_a16  DATE
    , p2_a17  VARCHAR2
    , p2_a18  NUMBER
    , p2_a19  NUMBER
    , p2_a20  NUMBER
    , p2_a21  NUMBER
    , p2_a22  NUMBER
    , p2_a23  NUMBER
    , p2_a24  NUMBER
    , p2_a25  NUMBER
    , p2_a26  NUMBER
    , p2_a27  NUMBER
    , p2_a28  VARCHAR2
    , p2_a29  VARCHAR2
    , p2_a30  VARCHAR2
    , p2_a31  VARCHAR2
    , p2_a32  VARCHAR2
    , p2_a33  VARCHAR2
    , p2_a34  VARCHAR2
    , p2_a35  VARCHAR2
    , p2_a36  VARCHAR2
    , p2_a37  VARCHAR2
    , p2_a38  VARCHAR2
    , p2_a39  VARCHAR2
    , p2_a40  VARCHAR2
    , p2_a41  VARCHAR2
    , p2_a42  VARCHAR2
    , p2_a43  VARCHAR2
    , p2_a44  NUMBER
    , p2_a45  VARCHAR2
    , p2_a46  VARCHAR2
    , p2_a47  VARCHAR2
    , p2_a48  VARCHAR2
    , p2_a49  VARCHAR2
    , p2_a50  NUMBER
    , p2_a51  NUMBER
    , p2_a52  VARCHAR2
  )

  as
    ddp_claim_rec ozf_claim_type_pvt.claim_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any


    ddp_claim_rec.claim_type_id := p2_a0;
    ddp_claim_rec.object_version_number := p2_a1;
    ddp_claim_rec.last_update_date := rosetta_g_miss_date_in_map(p2_a2);
    ddp_claim_rec.last_updated_by := p2_a3;
    ddp_claim_rec.creation_date := rosetta_g_miss_date_in_map(p2_a4);
    ddp_claim_rec.created_by := p2_a5;
    ddp_claim_rec.last_update_login := p2_a6;
    ddp_claim_rec.request_id := p2_a7;
    ddp_claim_rec.program_application_id := p2_a8;
    ddp_claim_rec.program_update_date := rosetta_g_miss_date_in_map(p2_a9);
    ddp_claim_rec.program_id := p2_a10;
    ddp_claim_rec.created_from := p2_a11;
    ddp_claim_rec.claim_class := p2_a12;
    ddp_claim_rec.set_of_books_id := p2_a13;
    ddp_claim_rec.post_to_gl_flag := p2_a14;
    ddp_claim_rec.start_date := rosetta_g_miss_date_in_map(p2_a15);
    ddp_claim_rec.end_date := rosetta_g_miss_date_in_map(p2_a16);
    ddp_claim_rec.creation_sign := p2_a17;
    ddp_claim_rec.gl_id_ded_adj := p2_a18;
    ddp_claim_rec.gl_id_ded_adj_clearing := p2_a19;
    ddp_claim_rec.gl_id_ded_clearing := p2_a20;
    ddp_claim_rec.gl_id_accr_promo_liab := p2_a21;
    ddp_claim_rec.transaction_type := p2_a22;
    ddp_claim_rec.cm_trx_type_id := p2_a23;
    ddp_claim_rec.dm_trx_type_id := p2_a24;
    ddp_claim_rec.cb_trx_type_id := p2_a25;
    ddp_claim_rec.wo_rec_trx_id := p2_a26;
    ddp_claim_rec.adj_rec_trx_id := p2_a27;
    ddp_claim_rec.attribute_category := p2_a28;
    ddp_claim_rec.attribute1 := p2_a29;
    ddp_claim_rec.attribute2 := p2_a30;
    ddp_claim_rec.attribute3 := p2_a31;
    ddp_claim_rec.attribute4 := p2_a32;
    ddp_claim_rec.attribute5 := p2_a33;
    ddp_claim_rec.attribute6 := p2_a34;
    ddp_claim_rec.attribute7 := p2_a35;
    ddp_claim_rec.attribute8 := p2_a36;
    ddp_claim_rec.attribute9 := p2_a37;
    ddp_claim_rec.attribute10 := p2_a38;
    ddp_claim_rec.attribute11 := p2_a39;
    ddp_claim_rec.attribute12 := p2_a40;
    ddp_claim_rec.attribute13 := p2_a41;
    ddp_claim_rec.attribute14 := p2_a42;
    ddp_claim_rec.attribute15 := p2_a43;
    ddp_claim_rec.org_id := p2_a44;
    ddp_claim_rec.name := p2_a45;
    ddp_claim_rec.description := p2_a46;
    ddp_claim_rec.language := p2_a47;
    ddp_claim_rec.source_lang := p2_a48;
    ddp_claim_rec.adjustment_type := p2_a49;
    ddp_claim_rec.order_type_id := p2_a50;
    ddp_claim_rec.neg_wo_rec_trx_id := p2_a51;
    ddp_claim_rec.gl_balancing_flex_value := p2_a52;

    -- here's the delegated call to the old PL/SQL routine
    ozf_claim_type_pvt.check_claim_type_items(p_validation_mode,
      x_return_status,
      ddp_claim_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any


  end;

  procedure check_claim_type_record(p0_a0  NUMBER
    , p0_a1  NUMBER
    , p0_a2  DATE
    , p0_a3  NUMBER
    , p0_a4  DATE
    , p0_a5  NUMBER
    , p0_a6  NUMBER
    , p0_a7  NUMBER
    , p0_a8  NUMBER
    , p0_a9  DATE
    , p0_a10  NUMBER
    , p0_a11  VARCHAR2
    , p0_a12  VARCHAR2
    , p0_a13  NUMBER
    , p0_a14  VARCHAR2
    , p0_a15  DATE
    , p0_a16  DATE
    , p0_a17  VARCHAR2
    , p0_a18  NUMBER
    , p0_a19  NUMBER
    , p0_a20  NUMBER
    , p0_a21  NUMBER
    , p0_a22  NUMBER
    , p0_a23  NUMBER
    , p0_a24  NUMBER
    , p0_a25  NUMBER
    , p0_a26  NUMBER
    , p0_a27  NUMBER
    , p0_a28  VARCHAR2
    , p0_a29  VARCHAR2
    , p0_a30  VARCHAR2
    , p0_a31  VARCHAR2
    , p0_a32  VARCHAR2
    , p0_a33  VARCHAR2
    , p0_a34  VARCHAR2
    , p0_a35  VARCHAR2
    , p0_a36  VARCHAR2
    , p0_a37  VARCHAR2
    , p0_a38  VARCHAR2
    , p0_a39  VARCHAR2
    , p0_a40  VARCHAR2
    , p0_a41  VARCHAR2
    , p0_a42  VARCHAR2
    , p0_a43  VARCHAR2
    , p0_a44  NUMBER
    , p0_a45  VARCHAR2
    , p0_a46  VARCHAR2
    , p0_a47  VARCHAR2
    , p0_a48  VARCHAR2
    , p0_a49  VARCHAR2
    , p0_a50  NUMBER
    , p0_a51  NUMBER
    , p0_a52  VARCHAR2
    , p1_a0  NUMBER
    , p1_a1  NUMBER
    , p1_a2  DATE
    , p1_a3  NUMBER
    , p1_a4  DATE
    , p1_a5  NUMBER
    , p1_a6  NUMBER
    , p1_a7  NUMBER
    , p1_a8  NUMBER
    , p1_a9  DATE
    , p1_a10  NUMBER
    , p1_a11  VARCHAR2
    , p1_a12  VARCHAR2
    , p1_a13  NUMBER
    , p1_a14  VARCHAR2
    , p1_a15  DATE
    , p1_a16  DATE
    , p1_a17  VARCHAR2
    , p1_a18  NUMBER
    , p1_a19  NUMBER
    , p1_a20  NUMBER
    , p1_a21  NUMBER
    , p1_a22  NUMBER
    , p1_a23  NUMBER
    , p1_a24  NUMBER
    , p1_a25  NUMBER
    , p1_a26  NUMBER
    , p1_a27  NUMBER
    , p1_a28  VARCHAR2
    , p1_a29  VARCHAR2
    , p1_a30  VARCHAR2
    , p1_a31  VARCHAR2
    , p1_a32  VARCHAR2
    , p1_a33  VARCHAR2
    , p1_a34  VARCHAR2
    , p1_a35  VARCHAR2
    , p1_a36  VARCHAR2
    , p1_a37  VARCHAR2
    , p1_a38  VARCHAR2
    , p1_a39  VARCHAR2
    , p1_a40  VARCHAR2
    , p1_a41  VARCHAR2
    , p1_a42  VARCHAR2
    , p1_a43  VARCHAR2
    , p1_a44  NUMBER
    , p1_a45  VARCHAR2
    , p1_a46  VARCHAR2
    , p1_a47  VARCHAR2
    , p1_a48  VARCHAR2
    , p1_a49  VARCHAR2
    , p1_a50  NUMBER
    , p1_a51  NUMBER
    , p1_a52  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
  )

  as
    ddp_claim_rec ozf_claim_type_pvt.claim_rec_type;
    ddp_complete_rec ozf_claim_type_pvt.claim_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_claim_rec.claim_type_id := p0_a0;
    ddp_claim_rec.object_version_number := p0_a1;
    ddp_claim_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a2);
    ddp_claim_rec.last_updated_by := p0_a3;
    ddp_claim_rec.creation_date := rosetta_g_miss_date_in_map(p0_a4);
    ddp_claim_rec.created_by := p0_a5;
    ddp_claim_rec.last_update_login := p0_a6;
    ddp_claim_rec.request_id := p0_a7;
    ddp_claim_rec.program_application_id := p0_a8;
    ddp_claim_rec.program_update_date := rosetta_g_miss_date_in_map(p0_a9);
    ddp_claim_rec.program_id := p0_a10;
    ddp_claim_rec.created_from := p0_a11;
    ddp_claim_rec.claim_class := p0_a12;
    ddp_claim_rec.set_of_books_id := p0_a13;
    ddp_claim_rec.post_to_gl_flag := p0_a14;
    ddp_claim_rec.start_date := rosetta_g_miss_date_in_map(p0_a15);
    ddp_claim_rec.end_date := rosetta_g_miss_date_in_map(p0_a16);
    ddp_claim_rec.creation_sign := p0_a17;
    ddp_claim_rec.gl_id_ded_adj := p0_a18;
    ddp_claim_rec.gl_id_ded_adj_clearing := p0_a19;
    ddp_claim_rec.gl_id_ded_clearing := p0_a20;
    ddp_claim_rec.gl_id_accr_promo_liab := p0_a21;
    ddp_claim_rec.transaction_type := p0_a22;
    ddp_claim_rec.cm_trx_type_id := p0_a23;
    ddp_claim_rec.dm_trx_type_id := p0_a24;
    ddp_claim_rec.cb_trx_type_id := p0_a25;
    ddp_claim_rec.wo_rec_trx_id := p0_a26;
    ddp_claim_rec.adj_rec_trx_id := p0_a27;
    ddp_claim_rec.attribute_category := p0_a28;
    ddp_claim_rec.attribute1 := p0_a29;
    ddp_claim_rec.attribute2 := p0_a30;
    ddp_claim_rec.attribute3 := p0_a31;
    ddp_claim_rec.attribute4 := p0_a32;
    ddp_claim_rec.attribute5 := p0_a33;
    ddp_claim_rec.attribute6 := p0_a34;
    ddp_claim_rec.attribute7 := p0_a35;
    ddp_claim_rec.attribute8 := p0_a36;
    ddp_claim_rec.attribute9 := p0_a37;
    ddp_claim_rec.attribute10 := p0_a38;
    ddp_claim_rec.attribute11 := p0_a39;
    ddp_claim_rec.attribute12 := p0_a40;
    ddp_claim_rec.attribute13 := p0_a41;
    ddp_claim_rec.attribute14 := p0_a42;
    ddp_claim_rec.attribute15 := p0_a43;
    ddp_claim_rec.org_id := p0_a44;
    ddp_claim_rec.name := p0_a45;
    ddp_claim_rec.description := p0_a46;
    ddp_claim_rec.language := p0_a47;
    ddp_claim_rec.source_lang := p0_a48;
    ddp_claim_rec.adjustment_type := p0_a49;
    ddp_claim_rec.order_type_id := p0_a50;
    ddp_claim_rec.neg_wo_rec_trx_id := p0_a51;
    ddp_claim_rec.gl_balancing_flex_value := p0_a52;

    ddp_complete_rec.claim_type_id := p1_a0;
    ddp_complete_rec.object_version_number := p1_a1;
    ddp_complete_rec.last_update_date := rosetta_g_miss_date_in_map(p1_a2);
    ddp_complete_rec.last_updated_by := p1_a3;
    ddp_complete_rec.creation_date := rosetta_g_miss_date_in_map(p1_a4);
    ddp_complete_rec.created_by := p1_a5;
    ddp_complete_rec.last_update_login := p1_a6;
    ddp_complete_rec.request_id := p1_a7;
    ddp_complete_rec.program_application_id := p1_a8;
    ddp_complete_rec.program_update_date := rosetta_g_miss_date_in_map(p1_a9);
    ddp_complete_rec.program_id := p1_a10;
    ddp_complete_rec.created_from := p1_a11;
    ddp_complete_rec.claim_class := p1_a12;
    ddp_complete_rec.set_of_books_id := p1_a13;
    ddp_complete_rec.post_to_gl_flag := p1_a14;
    ddp_complete_rec.start_date := rosetta_g_miss_date_in_map(p1_a15);
    ddp_complete_rec.end_date := rosetta_g_miss_date_in_map(p1_a16);
    ddp_complete_rec.creation_sign := p1_a17;
    ddp_complete_rec.gl_id_ded_adj := p1_a18;
    ddp_complete_rec.gl_id_ded_adj_clearing := p1_a19;
    ddp_complete_rec.gl_id_ded_clearing := p1_a20;
    ddp_complete_rec.gl_id_accr_promo_liab := p1_a21;
    ddp_complete_rec.transaction_type := p1_a22;
    ddp_complete_rec.cm_trx_type_id := p1_a23;
    ddp_complete_rec.dm_trx_type_id := p1_a24;
    ddp_complete_rec.cb_trx_type_id := p1_a25;
    ddp_complete_rec.wo_rec_trx_id := p1_a26;
    ddp_complete_rec.adj_rec_trx_id := p1_a27;
    ddp_complete_rec.attribute_category := p1_a28;
    ddp_complete_rec.attribute1 := p1_a29;
    ddp_complete_rec.attribute2 := p1_a30;
    ddp_complete_rec.attribute3 := p1_a31;
    ddp_complete_rec.attribute4 := p1_a32;
    ddp_complete_rec.attribute5 := p1_a33;
    ddp_complete_rec.attribute6 := p1_a34;
    ddp_complete_rec.attribute7 := p1_a35;
    ddp_complete_rec.attribute8 := p1_a36;
    ddp_complete_rec.attribute9 := p1_a37;
    ddp_complete_rec.attribute10 := p1_a38;
    ddp_complete_rec.attribute11 := p1_a39;
    ddp_complete_rec.attribute12 := p1_a40;
    ddp_complete_rec.attribute13 := p1_a41;
    ddp_complete_rec.attribute14 := p1_a42;
    ddp_complete_rec.attribute15 := p1_a43;
    ddp_complete_rec.org_id := p1_a44;
    ddp_complete_rec.name := p1_a45;
    ddp_complete_rec.description := p1_a46;
    ddp_complete_rec.language := p1_a47;
    ddp_complete_rec.source_lang := p1_a48;
    ddp_complete_rec.adjustment_type := p1_a49;
    ddp_complete_rec.order_type_id := p1_a50;
    ddp_complete_rec.neg_wo_rec_trx_id := p1_a51;
    ddp_complete_rec.gl_balancing_flex_value := p1_a52;


    -- here's the delegated call to the old PL/SQL routine
    ozf_claim_type_pvt.check_claim_type_record(ddp_claim_rec,
      ddp_complete_rec,
      x_return_status);

    -- copy data back from the local variables to OUT or IN-OUT args, if any


  end;

  procedure init_claim_type_rec(p0_a0 out nocopy  NUMBER
    , p0_a1 out nocopy  NUMBER
    , p0_a2 out nocopy  DATE
    , p0_a3 out nocopy  NUMBER
    , p0_a4 out nocopy  DATE
    , p0_a5 out nocopy  NUMBER
    , p0_a6 out nocopy  NUMBER
    , p0_a7 out nocopy  NUMBER
    , p0_a8 out nocopy  NUMBER
    , p0_a9 out nocopy  DATE
    , p0_a10 out nocopy  NUMBER
    , p0_a11 out nocopy  VARCHAR2
    , p0_a12 out nocopy  VARCHAR2
    , p0_a13 out nocopy  NUMBER
    , p0_a14 out nocopy  VARCHAR2
    , p0_a15 out nocopy  DATE
    , p0_a16 out nocopy  DATE
    , p0_a17 out nocopy  VARCHAR2
    , p0_a18 out nocopy  NUMBER
    , p0_a19 out nocopy  NUMBER
    , p0_a20 out nocopy  NUMBER
    , p0_a21 out nocopy  NUMBER
    , p0_a22 out nocopy  NUMBER
    , p0_a23 out nocopy  NUMBER
    , p0_a24 out nocopy  NUMBER
    , p0_a25 out nocopy  NUMBER
    , p0_a26 out nocopy  NUMBER
    , p0_a27 out nocopy  NUMBER
    , p0_a28 out nocopy  VARCHAR2
    , p0_a29 out nocopy  VARCHAR2
    , p0_a30 out nocopy  VARCHAR2
    , p0_a31 out nocopy  VARCHAR2
    , p0_a32 out nocopy  VARCHAR2
    , p0_a33 out nocopy  VARCHAR2
    , p0_a34 out nocopy  VARCHAR2
    , p0_a35 out nocopy  VARCHAR2
    , p0_a36 out nocopy  VARCHAR2
    , p0_a37 out nocopy  VARCHAR2
    , p0_a38 out nocopy  VARCHAR2
    , p0_a39 out nocopy  VARCHAR2
    , p0_a40 out nocopy  VARCHAR2
    , p0_a41 out nocopy  VARCHAR2
    , p0_a42 out nocopy  VARCHAR2
    , p0_a43 out nocopy  VARCHAR2
    , p0_a44 out nocopy  NUMBER
    , p0_a45 out nocopy  VARCHAR2
    , p0_a46 out nocopy  VARCHAR2
    , p0_a47 out nocopy  VARCHAR2
    , p0_a48 out nocopy  VARCHAR2
    , p0_a49 out nocopy  VARCHAR2
    , p0_a50 out nocopy  NUMBER
    , p0_a51 out nocopy  NUMBER
    , p0_a52 out nocopy  VARCHAR2
  )

  as
    ddx_claim_rec ozf_claim_type_pvt.claim_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    -- here's the delegated call to the old PL/SQL routine
    ozf_claim_type_pvt.init_claim_type_rec(ddx_claim_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any
    p0_a0 := ddx_claim_rec.claim_type_id;
    p0_a1 := ddx_claim_rec.object_version_number;
    p0_a2 := ddx_claim_rec.last_update_date;
    p0_a3 := ddx_claim_rec.last_updated_by;
    p0_a4 := ddx_claim_rec.creation_date;
    p0_a5 := ddx_claim_rec.created_by;
    p0_a6 := ddx_claim_rec.last_update_login;
    p0_a7 := ddx_claim_rec.request_id;
    p0_a8 := ddx_claim_rec.program_application_id;
    p0_a9 := ddx_claim_rec.program_update_date;
    p0_a10 := ddx_claim_rec.program_id;
    p0_a11 := ddx_claim_rec.created_from;
    p0_a12 := ddx_claim_rec.claim_class;
    p0_a13 := ddx_claim_rec.set_of_books_id;
    p0_a14 := ddx_claim_rec.post_to_gl_flag;
    p0_a15 := ddx_claim_rec.start_date;
    p0_a16 := ddx_claim_rec.end_date;
    p0_a17 := ddx_claim_rec.creation_sign;
    p0_a18 := ddx_claim_rec.gl_id_ded_adj;
    p0_a19 := ddx_claim_rec.gl_id_ded_adj_clearing;
    p0_a20 := ddx_claim_rec.gl_id_ded_clearing;
    p0_a21 := ddx_claim_rec.gl_id_accr_promo_liab;
    p0_a22 := ddx_claim_rec.transaction_type;
    p0_a23 := ddx_claim_rec.cm_trx_type_id;
    p0_a24 := ddx_claim_rec.dm_trx_type_id;
    p0_a25 := ddx_claim_rec.cb_trx_type_id;
    p0_a26 := ddx_claim_rec.wo_rec_trx_id;
    p0_a27 := ddx_claim_rec.adj_rec_trx_id;
    p0_a28 := ddx_claim_rec.attribute_category;
    p0_a29 := ddx_claim_rec.attribute1;
    p0_a30 := ddx_claim_rec.attribute2;
    p0_a31 := ddx_claim_rec.attribute3;
    p0_a32 := ddx_claim_rec.attribute4;
    p0_a33 := ddx_claim_rec.attribute5;
    p0_a34 := ddx_claim_rec.attribute6;
    p0_a35 := ddx_claim_rec.attribute7;
    p0_a36 := ddx_claim_rec.attribute8;
    p0_a37 := ddx_claim_rec.attribute9;
    p0_a38 := ddx_claim_rec.attribute10;
    p0_a39 := ddx_claim_rec.attribute11;
    p0_a40 := ddx_claim_rec.attribute12;
    p0_a41 := ddx_claim_rec.attribute13;
    p0_a42 := ddx_claim_rec.attribute14;
    p0_a43 := ddx_claim_rec.attribute15;
    p0_a44 := ddx_claim_rec.org_id;
    p0_a45 := ddx_claim_rec.name;
    p0_a46 := ddx_claim_rec.description;
    p0_a47 := ddx_claim_rec.language;
    p0_a48 := ddx_claim_rec.source_lang;
    p0_a49 := ddx_claim_rec.adjustment_type;
    p0_a50 := ddx_claim_rec.order_type_id;
    p0_a51 := ddx_claim_rec.neg_wo_rec_trx_id;
    p0_a52 := ddx_claim_rec.gl_balancing_flex_value;
  end;

  procedure complete_claim_type_rec(p0_a0  NUMBER
    , p0_a1  NUMBER
    , p0_a2  DATE
    , p0_a3  NUMBER
    , p0_a4  DATE
    , p0_a5  NUMBER
    , p0_a6  NUMBER
    , p0_a7  NUMBER
    , p0_a8  NUMBER
    , p0_a9  DATE
    , p0_a10  NUMBER
    , p0_a11  VARCHAR2
    , p0_a12  VARCHAR2
    , p0_a13  NUMBER
    , p0_a14  VARCHAR2
    , p0_a15  DATE
    , p0_a16  DATE
    , p0_a17  VARCHAR2
    , p0_a18  NUMBER
    , p0_a19  NUMBER
    , p0_a20  NUMBER
    , p0_a21  NUMBER
    , p0_a22  NUMBER
    , p0_a23  NUMBER
    , p0_a24  NUMBER
    , p0_a25  NUMBER
    , p0_a26  NUMBER
    , p0_a27  NUMBER
    , p0_a28  VARCHAR2
    , p0_a29  VARCHAR2
    , p0_a30  VARCHAR2
    , p0_a31  VARCHAR2
    , p0_a32  VARCHAR2
    , p0_a33  VARCHAR2
    , p0_a34  VARCHAR2
    , p0_a35  VARCHAR2
    , p0_a36  VARCHAR2
    , p0_a37  VARCHAR2
    , p0_a38  VARCHAR2
    , p0_a39  VARCHAR2
    , p0_a40  VARCHAR2
    , p0_a41  VARCHAR2
    , p0_a42  VARCHAR2
    , p0_a43  VARCHAR2
    , p0_a44  NUMBER
    , p0_a45  VARCHAR2
    , p0_a46  VARCHAR2
    , p0_a47  VARCHAR2
    , p0_a48  VARCHAR2
    , p0_a49  VARCHAR2
    , p0_a50  NUMBER
    , p0_a51  NUMBER
    , p0_a52  VARCHAR2
    , p1_a0 out nocopy  NUMBER
    , p1_a1 out nocopy  NUMBER
    , p1_a2 out nocopy  DATE
    , p1_a3 out nocopy  NUMBER
    , p1_a4 out nocopy  DATE
    , p1_a5 out nocopy  NUMBER
    , p1_a6 out nocopy  NUMBER
    , p1_a7 out nocopy  NUMBER
    , p1_a8 out nocopy  NUMBER
    , p1_a9 out nocopy  DATE
    , p1_a10 out nocopy  NUMBER
    , p1_a11 out nocopy  VARCHAR2
    , p1_a12 out nocopy  VARCHAR2
    , p1_a13 out nocopy  NUMBER
    , p1_a14 out nocopy  VARCHAR2
    , p1_a15 out nocopy  DATE
    , p1_a16 out nocopy  DATE
    , p1_a17 out nocopy  VARCHAR2
    , p1_a18 out nocopy  NUMBER
    , p1_a19 out nocopy  NUMBER
    , p1_a20 out nocopy  NUMBER
    , p1_a21 out nocopy  NUMBER
    , p1_a22 out nocopy  NUMBER
    , p1_a23 out nocopy  NUMBER
    , p1_a24 out nocopy  NUMBER
    , p1_a25 out nocopy  NUMBER
    , p1_a26 out nocopy  NUMBER
    , p1_a27 out nocopy  NUMBER
    , p1_a28 out nocopy  VARCHAR2
    , p1_a29 out nocopy  VARCHAR2
    , p1_a30 out nocopy  VARCHAR2
    , p1_a31 out nocopy  VARCHAR2
    , p1_a32 out nocopy  VARCHAR2
    , p1_a33 out nocopy  VARCHAR2
    , p1_a34 out nocopy  VARCHAR2
    , p1_a35 out nocopy  VARCHAR2
    , p1_a36 out nocopy  VARCHAR2
    , p1_a37 out nocopy  VARCHAR2
    , p1_a38 out nocopy  VARCHAR2
    , p1_a39 out nocopy  VARCHAR2
    , p1_a40 out nocopy  VARCHAR2
    , p1_a41 out nocopy  VARCHAR2
    , p1_a42 out nocopy  VARCHAR2
    , p1_a43 out nocopy  VARCHAR2
    , p1_a44 out nocopy  NUMBER
    , p1_a45 out nocopy  VARCHAR2
    , p1_a46 out nocopy  VARCHAR2
    , p1_a47 out nocopy  VARCHAR2
    , p1_a48 out nocopy  VARCHAR2
    , p1_a49 out nocopy  VARCHAR2
    , p1_a50 out nocopy  NUMBER
    , p1_a51 out nocopy  NUMBER
    , p1_a52 out nocopy  VARCHAR2
  )

  as
    ddp_claim_rec ozf_claim_type_pvt.claim_rec_type;
    ddx_complete_rec ozf_claim_type_pvt.claim_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_claim_rec.claim_type_id := p0_a0;
    ddp_claim_rec.object_version_number := p0_a1;
    ddp_claim_rec.last_update_date := rosetta_g_miss_date_in_map(p0_a2);
    ddp_claim_rec.last_updated_by := p0_a3;
    ddp_claim_rec.creation_date := rosetta_g_miss_date_in_map(p0_a4);
    ddp_claim_rec.created_by := p0_a5;
    ddp_claim_rec.last_update_login := p0_a6;
    ddp_claim_rec.request_id := p0_a7;
    ddp_claim_rec.program_application_id := p0_a8;
    ddp_claim_rec.program_update_date := rosetta_g_miss_date_in_map(p0_a9);
    ddp_claim_rec.program_id := p0_a10;
    ddp_claim_rec.created_from := p0_a11;
    ddp_claim_rec.claim_class := p0_a12;
    ddp_claim_rec.set_of_books_id := p0_a13;
    ddp_claim_rec.post_to_gl_flag := p0_a14;
    ddp_claim_rec.start_date := rosetta_g_miss_date_in_map(p0_a15);
    ddp_claim_rec.end_date := rosetta_g_miss_date_in_map(p0_a16);
    ddp_claim_rec.creation_sign := p0_a17;
    ddp_claim_rec.gl_id_ded_adj := p0_a18;
    ddp_claim_rec.gl_id_ded_adj_clearing := p0_a19;
    ddp_claim_rec.gl_id_ded_clearing := p0_a20;
    ddp_claim_rec.gl_id_accr_promo_liab := p0_a21;
    ddp_claim_rec.transaction_type := p0_a22;
    ddp_claim_rec.cm_trx_type_id := p0_a23;
    ddp_claim_rec.dm_trx_type_id := p0_a24;
    ddp_claim_rec.cb_trx_type_id := p0_a25;
    ddp_claim_rec.wo_rec_trx_id := p0_a26;
    ddp_claim_rec.adj_rec_trx_id := p0_a27;
    ddp_claim_rec.attribute_category := p0_a28;
    ddp_claim_rec.attribute1 := p0_a29;
    ddp_claim_rec.attribute2 := p0_a30;
    ddp_claim_rec.attribute3 := p0_a31;
    ddp_claim_rec.attribute4 := p0_a32;
    ddp_claim_rec.attribute5 := p0_a33;
    ddp_claim_rec.attribute6 := p0_a34;
    ddp_claim_rec.attribute7 := p0_a35;
    ddp_claim_rec.attribute8 := p0_a36;
    ddp_claim_rec.attribute9 := p0_a37;
    ddp_claim_rec.attribute10 := p0_a38;
    ddp_claim_rec.attribute11 := p0_a39;
    ddp_claim_rec.attribute12 := p0_a40;
    ddp_claim_rec.attribute13 := p0_a41;
    ddp_claim_rec.attribute14 := p0_a42;
    ddp_claim_rec.attribute15 := p0_a43;
    ddp_claim_rec.org_id := p0_a44;
    ddp_claim_rec.name := p0_a45;
    ddp_claim_rec.description := p0_a46;
    ddp_claim_rec.language := p0_a47;
    ddp_claim_rec.source_lang := p0_a48;
    ddp_claim_rec.adjustment_type := p0_a49;
    ddp_claim_rec.order_type_id := p0_a50;
    ddp_claim_rec.neg_wo_rec_trx_id := p0_a51;
    ddp_claim_rec.gl_balancing_flex_value := p0_a52;


    -- here's the delegated call to the old PL/SQL routine
    ozf_claim_type_pvt.complete_claim_type_rec(ddp_claim_rec,
      ddx_complete_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any

    p1_a0 := ddx_complete_rec.claim_type_id;
    p1_a1 := ddx_complete_rec.object_version_number;
    p1_a2 := ddx_complete_rec.last_update_date;
    p1_a3 := ddx_complete_rec.last_updated_by;
    p1_a4 := ddx_complete_rec.creation_date;
    p1_a5 := ddx_complete_rec.created_by;
    p1_a6 := ddx_complete_rec.last_update_login;
    p1_a7 := ddx_complete_rec.request_id;
    p1_a8 := ddx_complete_rec.program_application_id;
    p1_a9 := ddx_complete_rec.program_update_date;
    p1_a10 := ddx_complete_rec.program_id;
    p1_a11 := ddx_complete_rec.created_from;
    p1_a12 := ddx_complete_rec.claim_class;
    p1_a13 := ddx_complete_rec.set_of_books_id;
    p1_a14 := ddx_complete_rec.post_to_gl_flag;
    p1_a15 := ddx_complete_rec.start_date;
    p1_a16 := ddx_complete_rec.end_date;
    p1_a17 := ddx_complete_rec.creation_sign;
    p1_a18 := ddx_complete_rec.gl_id_ded_adj;
    p1_a19 := ddx_complete_rec.gl_id_ded_adj_clearing;
    p1_a20 := ddx_complete_rec.gl_id_ded_clearing;
    p1_a21 := ddx_complete_rec.gl_id_accr_promo_liab;
    p1_a22 := ddx_complete_rec.transaction_type;
    p1_a23 := ddx_complete_rec.cm_trx_type_id;
    p1_a24 := ddx_complete_rec.dm_trx_type_id;
    p1_a25 := ddx_complete_rec.cb_trx_type_id;
    p1_a26 := ddx_complete_rec.wo_rec_trx_id;
    p1_a27 := ddx_complete_rec.adj_rec_trx_id;
    p1_a28 := ddx_complete_rec.attribute_category;
    p1_a29 := ddx_complete_rec.attribute1;
    p1_a30 := ddx_complete_rec.attribute2;
    p1_a31 := ddx_complete_rec.attribute3;
    p1_a32 := ddx_complete_rec.attribute4;
    p1_a33 := ddx_complete_rec.attribute5;
    p1_a34 := ddx_complete_rec.attribute6;
    p1_a35 := ddx_complete_rec.attribute7;
    p1_a36 := ddx_complete_rec.attribute8;
    p1_a37 := ddx_complete_rec.attribute9;
    p1_a38 := ddx_complete_rec.attribute10;
    p1_a39 := ddx_complete_rec.attribute11;
    p1_a40 := ddx_complete_rec.attribute12;
    p1_a41 := ddx_complete_rec.attribute13;
    p1_a42 := ddx_complete_rec.attribute14;
    p1_a43 := ddx_complete_rec.attribute15;
    p1_a44 := ddx_complete_rec.org_id;
    p1_a45 := ddx_complete_rec.name;
    p1_a46 := ddx_complete_rec.description;
    p1_a47 := ddx_complete_rec.language;
    p1_a48 := ddx_complete_rec.source_lang;
    p1_a49 := ddx_complete_rec.adjustment_type;
    p1_a50 := ddx_complete_rec.order_type_id;
    p1_a51 := ddx_complete_rec.neg_wo_rec_trx_id;
    p1_a52 := ddx_complete_rec.gl_balancing_flex_value;
  end;

end ozf_claim_type_pvt_w;

/
