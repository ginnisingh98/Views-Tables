--------------------------------------------------------
--  DDL for Package Body OKL_SYSTEM_PARAMS_ALL_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_SYSTEM_PARAMS_ALL_PUB_W" as
  /* $Header: OKLUSYPB.pls 120.14.12010000.2 2008/11/13 16:20:44 kkorrapo ship $ */
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

  function rosetta_g_miss_num_map(n number) return number as
    a number := fnd_api.g_miss_num;
    b number := 0-1962.0724;
  begin
    if n=a then return b; end if;
    if n=b then return a; end if;
    return n;
  end;

  procedure insert_system_parameters(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  VARCHAR2
    , p6_a2 out nocopy  VARCHAR2
    , p6_a3 out nocopy  NUMBER
    , p6_a4 out nocopy  NUMBER
    , p6_a5 out nocopy  VARCHAR2
    , p6_a6 out nocopy  NUMBER
    , p6_a7 out nocopy  VARCHAR2
    , p6_a8 out nocopy  VARCHAR2
    , p6_a9 out nocopy  VARCHAR2
    , p6_a10 out nocopy  VARCHAR2
    , p6_a11 out nocopy  VARCHAR2
    , p6_a12 out nocopy  NUMBER
    , p6_a13 out nocopy  NUMBER
    , p6_a14 out nocopy  NUMBER
    , p6_a15 out nocopy  VARCHAR2
    , p6_a16 out nocopy  VARCHAR2
    , p6_a17 out nocopy  NUMBER
    , p6_a18 out nocopy  VARCHAR2
    , p6_a19 out nocopy  NUMBER
    , p6_a20 out nocopy  NUMBER
    , p6_a21 out nocopy  VARCHAR2
    , p6_a22 out nocopy  VARCHAR2
    , p6_a23 out nocopy  NUMBER
    , p6_a24 out nocopy  VARCHAR2
    , p6_a25 out nocopy  VARCHAR2
    , p6_a26 out nocopy  VARCHAR2
    , p6_a27 out nocopy  VARCHAR2
    , p6_a28 out nocopy  NUMBER
    , p6_a29 out nocopy  NUMBER
    , p6_a30 out nocopy  NUMBER
    , p6_a31 out nocopy  VARCHAR2
    , p6_a32 out nocopy  NUMBER
    , p6_a33 out nocopy  NUMBER
    , p6_a34 out nocopy  NUMBER
    , p6_a35 out nocopy  NUMBER
    , p6_a36 out nocopy  NUMBER
    , p6_a37 out nocopy  DATE
    , p6_a38 out nocopy  VARCHAR2
    , p6_a39 out nocopy  VARCHAR2
    , p6_a40 out nocopy  VARCHAR2
    , p6_a41 out nocopy  VARCHAR2
    , p6_a42 out nocopy  VARCHAR2
    , p6_a43 out nocopy  VARCHAR2
    , p6_a44 out nocopy  VARCHAR2
    , p6_a45 out nocopy  VARCHAR2
    , p6_a46 out nocopy  VARCHAR2
    , p6_a47 out nocopy  VARCHAR2
    , p6_a48 out nocopy  VARCHAR2
    , p6_a49 out nocopy  VARCHAR2
    , p6_a50 out nocopy  VARCHAR2
    , p6_a51 out nocopy  VARCHAR2
    , p6_a52 out nocopy  VARCHAR2
    , p6_a53 out nocopy  VARCHAR2
    , p6_a54 out nocopy  NUMBER
    , p6_a55 out nocopy  DATE
    , p6_a56 out nocopy  NUMBER
    , p6_a57 out nocopy  DATE
    , p6_a58 out nocopy  NUMBER
    , p6_a59 out nocopy  VARCHAR2
    , p6_a60 out nocopy  VARCHAR2
    , p6_a61 out nocopy  VARCHAR2
    , p6_a62 out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  VARCHAR2 := fnd_api.g_miss_char
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  VARCHAR2 := fnd_api.g_miss_char
    , p5_a10  VARCHAR2 := fnd_api.g_miss_char
    , p5_a11  VARCHAR2 := fnd_api.g_miss_char
    , p5_a12  NUMBER := 0-1962.0724
    , p5_a13  NUMBER := 0-1962.0724
    , p5_a14  NUMBER := 0-1962.0724
    , p5_a15  VARCHAR2 := fnd_api.g_miss_char
    , p5_a16  VARCHAR2 := fnd_api.g_miss_char
    , p5_a17  NUMBER := 0-1962.0724
    , p5_a18  VARCHAR2 := fnd_api.g_miss_char
    , p5_a19  NUMBER := 0-1962.0724
    , p5_a20  NUMBER := 0-1962.0724
    , p5_a21  VARCHAR2 := fnd_api.g_miss_char
    , p5_a22  VARCHAR2 := fnd_api.g_miss_char
    , p5_a23  NUMBER := 0-1962.0724
    , p5_a24  VARCHAR2 := fnd_api.g_miss_char
    , p5_a25  VARCHAR2 := fnd_api.g_miss_char
    , p5_a26  VARCHAR2 := fnd_api.g_miss_char
    , p5_a27  VARCHAR2 := fnd_api.g_miss_char
    , p5_a28  NUMBER := 0-1962.0724
    , p5_a29  NUMBER := 0-1962.0724
    , p5_a30  NUMBER := 0-1962.0724
    , p5_a31  VARCHAR2 := fnd_api.g_miss_char
    , p5_a32  NUMBER := 0-1962.0724
    , p5_a33  NUMBER := 0-1962.0724
    , p5_a34  NUMBER := 0-1962.0724
    , p5_a35  NUMBER := 0-1962.0724
    , p5_a36  NUMBER := 0-1962.0724
    , p5_a37  DATE := fnd_api.g_miss_date
    , p5_a38  VARCHAR2 := fnd_api.g_miss_char
    , p5_a39  VARCHAR2 := fnd_api.g_miss_char
    , p5_a40  VARCHAR2 := fnd_api.g_miss_char
    , p5_a41  VARCHAR2 := fnd_api.g_miss_char
    , p5_a42  VARCHAR2 := fnd_api.g_miss_char
    , p5_a43  VARCHAR2 := fnd_api.g_miss_char
    , p5_a44  VARCHAR2 := fnd_api.g_miss_char
    , p5_a45  VARCHAR2 := fnd_api.g_miss_char
    , p5_a46  VARCHAR2 := fnd_api.g_miss_char
    , p5_a47  VARCHAR2 := fnd_api.g_miss_char
    , p5_a48  VARCHAR2 := fnd_api.g_miss_char
    , p5_a49  VARCHAR2 := fnd_api.g_miss_char
    , p5_a50  VARCHAR2 := fnd_api.g_miss_char
    , p5_a51  VARCHAR2 := fnd_api.g_miss_char
    , p5_a52  VARCHAR2 := fnd_api.g_miss_char
    , p5_a53  VARCHAR2 := fnd_api.g_miss_char
    , p5_a54  NUMBER := 0-1962.0724
    , p5_a55  DATE := fnd_api.g_miss_date
    , p5_a56  NUMBER := 0-1962.0724
    , p5_a57  DATE := fnd_api.g_miss_date
    , p5_a58  NUMBER := 0-1962.0724
    , p5_a59  VARCHAR2 := fnd_api.g_miss_char
    , p5_a60  VARCHAR2 := fnd_api.g_miss_char
    , p5_a61  VARCHAR2 := fnd_api.g_miss_char
    , p5_a62  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_sypv_rec okl_system_params_all_pub.sypv_rec_type;
    ddx_sypv_rec okl_system_params_all_pub.sypv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_sypv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_sypv_rec.delink_yn := p5_a1;
    ddp_sypv_rec.remk_subinventory := p5_a2;
    ddp_sypv_rec.remk_organization_id := rosetta_g_miss_num_map(p5_a3);
    ddp_sypv_rec.remk_price_list_id := rosetta_g_miss_num_map(p5_a4);
    ddp_sypv_rec.remk_process_code := p5_a5;
    ddp_sypv_rec.remk_item_template_id := rosetta_g_miss_num_map(p5_a6);
    ddp_sypv_rec.remk_item_invoiced_code := p5_a7;
    ddp_sypv_rec.lease_inv_org_yn := p5_a8;
    ddp_sypv_rec.tax_upfront_yn := p5_a9;
    ddp_sypv_rec.tax_invoice_yn := p5_a10;
    ddp_sypv_rec.tax_schedule_yn := p5_a11;
    ddp_sypv_rec.tax_upfront_sty_id := rosetta_g_miss_num_map(p5_a12);
    ddp_sypv_rec.category_set_id := rosetta_g_miss_num_map(p5_a13);
    ddp_sypv_rec.validation_set_id := rosetta_g_miss_num_map(p5_a14);
    ddp_sypv_rec.cancel_quotes_yn := p5_a15;
    ddp_sypv_rec.chk_accrual_previous_mnth_yn := p5_a16;
    ddp_sypv_rec.task_template_group_id := rosetta_g_miss_num_map(p5_a17);
    ddp_sypv_rec.owner_type_code := p5_a18;
    ddp_sypv_rec.owner_id := rosetta_g_miss_num_map(p5_a19);
    ddp_sypv_rec.item_inv_org_id := rosetta_g_miss_num_map(p5_a20);
    ddp_sypv_rec.rpt_prod_book_type_code := p5_a21;
    ddp_sypv_rec.asst_add_book_type_code := p5_a22;
    ddp_sypv_rec.ccard_remittance_id := rosetta_g_miss_num_map(p5_a23);
    ddp_sypv_rec.corporate_book := p5_a24;
    ddp_sypv_rec.tax_book_1 := p5_a25;
    ddp_sypv_rec.tax_book_2 := p5_a26;
    ddp_sypv_rec.depreciate_yn := p5_a27;
    ddp_sypv_rec.fa_location_id := rosetta_g_miss_num_map(p5_a28);
    ddp_sypv_rec.formula_id := rosetta_g_miss_num_map(p5_a29);
    ddp_sypv_rec.asset_key_id := rosetta_g_miss_num_map(p5_a30);
    ddp_sypv_rec.part_trmnt_apply_round_diff := p5_a31;
    ddp_sypv_rec.object_version_number := rosetta_g_miss_num_map(p5_a32);
    ddp_sypv_rec.org_id := rosetta_g_miss_num_map(p5_a33);
    ddp_sypv_rec.request_id := rosetta_g_miss_num_map(p5_a34);
    ddp_sypv_rec.program_application_id := rosetta_g_miss_num_map(p5_a35);
    ddp_sypv_rec.program_id := rosetta_g_miss_num_map(p5_a36);
    ddp_sypv_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a37);
    ddp_sypv_rec.attribute_category := p5_a38;
    ddp_sypv_rec.attribute1 := p5_a39;
    ddp_sypv_rec.attribute2 := p5_a40;
    ddp_sypv_rec.attribute3 := p5_a41;
    ddp_sypv_rec.attribute4 := p5_a42;
    ddp_sypv_rec.attribute5 := p5_a43;
    ddp_sypv_rec.attribute6 := p5_a44;
    ddp_sypv_rec.attribute7 := p5_a45;
    ddp_sypv_rec.attribute8 := p5_a46;
    ddp_sypv_rec.attribute9 := p5_a47;
    ddp_sypv_rec.attribute10 := p5_a48;
    ddp_sypv_rec.attribute11 := p5_a49;
    ddp_sypv_rec.attribute12 := p5_a50;
    ddp_sypv_rec.attribute13 := p5_a51;
    ddp_sypv_rec.attribute14 := p5_a52;
    ddp_sypv_rec.attribute15 := p5_a53;
    ddp_sypv_rec.created_by := rosetta_g_miss_num_map(p5_a54);
    ddp_sypv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a55);
    ddp_sypv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a56);
    ddp_sypv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a57);
    ddp_sypv_rec.last_update_login := rosetta_g_miss_num_map(p5_a58);
    ddp_sypv_rec.lseapp_seq_prefix_txt := p5_a59;
    ddp_sypv_rec.lseopp_seq_prefix_txt := p5_a60;
    ddp_sypv_rec.qckqte_seq_prefix_txt := p5_a61;
    ddp_sypv_rec.lseqte_seq_prefix_txt := p5_a62;


    -- here's the delegated call to the old PL/SQL routine
    okl_system_params_all_pub.insert_system_parameters(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_sypv_rec,
      ddx_sypv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_sypv_rec.id);
    p6_a1 := ddx_sypv_rec.delink_yn;
    p6_a2 := ddx_sypv_rec.remk_subinventory;
    p6_a3 := rosetta_g_miss_num_map(ddx_sypv_rec.remk_organization_id);
    p6_a4 := rosetta_g_miss_num_map(ddx_sypv_rec.remk_price_list_id);
    p6_a5 := ddx_sypv_rec.remk_process_code;
    p6_a6 := rosetta_g_miss_num_map(ddx_sypv_rec.remk_item_template_id);
    p6_a7 := ddx_sypv_rec.remk_item_invoiced_code;
    p6_a8 := ddx_sypv_rec.lease_inv_org_yn;
    p6_a9 := ddx_sypv_rec.tax_upfront_yn;
    p6_a10 := ddx_sypv_rec.tax_invoice_yn;
    p6_a11 := ddx_sypv_rec.tax_schedule_yn;
    p6_a12 := rosetta_g_miss_num_map(ddx_sypv_rec.tax_upfront_sty_id);
    p6_a13 := rosetta_g_miss_num_map(ddx_sypv_rec.category_set_id);
    p6_a14 := rosetta_g_miss_num_map(ddx_sypv_rec.validation_set_id);
    p6_a15 := ddx_sypv_rec.cancel_quotes_yn;
    p6_a16 := ddx_sypv_rec.chk_accrual_previous_mnth_yn;
    p6_a17 := rosetta_g_miss_num_map(ddx_sypv_rec.task_template_group_id);
    p6_a18 := ddx_sypv_rec.owner_type_code;
    p6_a19 := rosetta_g_miss_num_map(ddx_sypv_rec.owner_id);
    p6_a20 := rosetta_g_miss_num_map(ddx_sypv_rec.item_inv_org_id);
    p6_a21 := ddx_sypv_rec.rpt_prod_book_type_code;
    p6_a22 := ddx_sypv_rec.asst_add_book_type_code;
    p6_a23 := rosetta_g_miss_num_map(ddx_sypv_rec.ccard_remittance_id);
    p6_a24 := ddx_sypv_rec.corporate_book;
    p6_a25 := ddx_sypv_rec.tax_book_1;
    p6_a26 := ddx_sypv_rec.tax_book_2;
    p6_a27 := ddx_sypv_rec.depreciate_yn;
    p6_a28 := rosetta_g_miss_num_map(ddx_sypv_rec.fa_location_id);
    p6_a29 := rosetta_g_miss_num_map(ddx_sypv_rec.formula_id);
    p6_a30 := rosetta_g_miss_num_map(ddx_sypv_rec.asset_key_id);
    p6_a31 := ddx_sypv_rec.part_trmnt_apply_round_diff;
    p6_a32 := rosetta_g_miss_num_map(ddx_sypv_rec.object_version_number);
    p6_a33 := rosetta_g_miss_num_map(ddx_sypv_rec.org_id);
    p6_a34 := rosetta_g_miss_num_map(ddx_sypv_rec.request_id);
    p6_a35 := rosetta_g_miss_num_map(ddx_sypv_rec.program_application_id);
    p6_a36 := rosetta_g_miss_num_map(ddx_sypv_rec.program_id);
    p6_a37 := ddx_sypv_rec.program_update_date;
    p6_a38 := ddx_sypv_rec.attribute_category;
    p6_a39 := ddx_sypv_rec.attribute1;
    p6_a40 := ddx_sypv_rec.attribute2;
    p6_a41 := ddx_sypv_rec.attribute3;
    p6_a42 := ddx_sypv_rec.attribute4;
    p6_a43 := ddx_sypv_rec.attribute5;
    p6_a44 := ddx_sypv_rec.attribute6;
    p6_a45 := ddx_sypv_rec.attribute7;
    p6_a46 := ddx_sypv_rec.attribute8;
    p6_a47 := ddx_sypv_rec.attribute9;
    p6_a48 := ddx_sypv_rec.attribute10;
    p6_a49 := ddx_sypv_rec.attribute11;
    p6_a50 := ddx_sypv_rec.attribute12;
    p6_a51 := ddx_sypv_rec.attribute13;
    p6_a52 := ddx_sypv_rec.attribute14;
    p6_a53 := ddx_sypv_rec.attribute15;
    p6_a54 := rosetta_g_miss_num_map(ddx_sypv_rec.created_by);
    p6_a55 := ddx_sypv_rec.creation_date;
    p6_a56 := rosetta_g_miss_num_map(ddx_sypv_rec.last_updated_by);
    p6_a57 := ddx_sypv_rec.last_update_date;
    p6_a58 := rosetta_g_miss_num_map(ddx_sypv_rec.last_update_login);
    p6_a59 := ddx_sypv_rec.lseapp_seq_prefix_txt;
    p6_a60 := ddx_sypv_rec.lseopp_seq_prefix_txt;
    p6_a61 := ddx_sypv_rec.qckqte_seq_prefix_txt;
    p6_a62 := ddx_sypv_rec.lseqte_seq_prefix_txt;
  end;

  procedure insert_system_parameters(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_VARCHAR2_TABLE_100
    , p5_a2 JTF_VARCHAR2_TABLE_100
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_VARCHAR2_TABLE_100
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_VARCHAR2_TABLE_100
    , p5_a8 JTF_VARCHAR2_TABLE_100
    , p5_a9 JTF_VARCHAR2_TABLE_100
    , p5_a10 JTF_VARCHAR2_TABLE_100
    , p5_a11 JTF_VARCHAR2_TABLE_100
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_NUMBER_TABLE
    , p5_a14 JTF_NUMBER_TABLE
    , p5_a15 JTF_VARCHAR2_TABLE_100
    , p5_a16 JTF_VARCHAR2_TABLE_100
    , p5_a17 JTF_NUMBER_TABLE
    , p5_a18 JTF_VARCHAR2_TABLE_100
    , p5_a19 JTF_NUMBER_TABLE
    , p5_a20 JTF_NUMBER_TABLE
    , p5_a21 JTF_VARCHAR2_TABLE_100
    , p5_a22 JTF_VARCHAR2_TABLE_100
    , p5_a23 JTF_NUMBER_TABLE
    , p5_a24 JTF_VARCHAR2_TABLE_100
    , p5_a25 JTF_VARCHAR2_TABLE_100
    , p5_a26 JTF_VARCHAR2_TABLE_100
    , p5_a27 JTF_VARCHAR2_TABLE_100
    , p5_a28 JTF_NUMBER_TABLE
    , p5_a29 JTF_NUMBER_TABLE
    , p5_a30 JTF_NUMBER_TABLE
    , p5_a31 JTF_VARCHAR2_TABLE_100
    , p5_a32 JTF_NUMBER_TABLE
    , p5_a33 JTF_NUMBER_TABLE
    , p5_a34 JTF_NUMBER_TABLE
    , p5_a35 JTF_NUMBER_TABLE
    , p5_a36 JTF_NUMBER_TABLE
    , p5_a37 JTF_DATE_TABLE
    , p5_a38 JTF_VARCHAR2_TABLE_100
    , p5_a39 JTF_VARCHAR2_TABLE_500
    , p5_a40 JTF_VARCHAR2_TABLE_500
    , p5_a41 JTF_VARCHAR2_TABLE_500
    , p5_a42 JTF_VARCHAR2_TABLE_500
    , p5_a43 JTF_VARCHAR2_TABLE_500
    , p5_a44 JTF_VARCHAR2_TABLE_500
    , p5_a45 JTF_VARCHAR2_TABLE_500
    , p5_a46 JTF_VARCHAR2_TABLE_500
    , p5_a47 JTF_VARCHAR2_TABLE_500
    , p5_a48 JTF_VARCHAR2_TABLE_500
    , p5_a49 JTF_VARCHAR2_TABLE_500
    , p5_a50 JTF_VARCHAR2_TABLE_500
    , p5_a51 JTF_VARCHAR2_TABLE_500
    , p5_a52 JTF_VARCHAR2_TABLE_500
    , p5_a53 JTF_VARCHAR2_TABLE_500
    , p5_a54 JTF_NUMBER_TABLE
    , p5_a55 JTF_DATE_TABLE
    , p5_a56 JTF_NUMBER_TABLE
    , p5_a57 JTF_DATE_TABLE
    , p5_a58 JTF_NUMBER_TABLE
    , p5_a59 JTF_VARCHAR2_TABLE_200
    , p5_a60 JTF_VARCHAR2_TABLE_200
    , p5_a61 JTF_VARCHAR2_TABLE_200
    , p5_a62 JTF_VARCHAR2_TABLE_200
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a3 out nocopy JTF_NUMBER_TABLE
    , p6_a4 out nocopy JTF_NUMBER_TABLE
    , p6_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a6 out nocopy JTF_NUMBER_TABLE
    , p6_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a10 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a11 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a12 out nocopy JTF_NUMBER_TABLE
    , p6_a13 out nocopy JTF_NUMBER_TABLE
    , p6_a14 out nocopy JTF_NUMBER_TABLE
    , p6_a15 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a16 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a17 out nocopy JTF_NUMBER_TABLE
    , p6_a18 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a19 out nocopy JTF_NUMBER_TABLE
    , p6_a20 out nocopy JTF_NUMBER_TABLE
    , p6_a21 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a22 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a23 out nocopy JTF_NUMBER_TABLE
    , p6_a24 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a25 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a26 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a27 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a28 out nocopy JTF_NUMBER_TABLE
    , p6_a29 out nocopy JTF_NUMBER_TABLE
    , p6_a30 out nocopy JTF_NUMBER_TABLE
    , p6_a31 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a32 out nocopy JTF_NUMBER_TABLE
    , p6_a33 out nocopy JTF_NUMBER_TABLE
    , p6_a34 out nocopy JTF_NUMBER_TABLE
    , p6_a35 out nocopy JTF_NUMBER_TABLE
    , p6_a36 out nocopy JTF_NUMBER_TABLE
    , p6_a37 out nocopy JTF_DATE_TABLE
    , p6_a38 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a39 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a40 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a41 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a42 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a43 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a44 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a45 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a46 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a47 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a48 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a49 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a50 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a51 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a52 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a53 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a54 out nocopy JTF_NUMBER_TABLE
    , p6_a55 out nocopy JTF_DATE_TABLE
    , p6_a56 out nocopy JTF_NUMBER_TABLE
    , p6_a57 out nocopy JTF_DATE_TABLE
    , p6_a58 out nocopy JTF_NUMBER_TABLE
    , p6_a59 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a60 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a61 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a62 out nocopy JTF_VARCHAR2_TABLE_200
  )

  as
    ddp_sypv_tbl okl_system_params_all_pub.sypv_tbl_type;
    ddx_sypv_tbl okl_system_params_all_pub.sypv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_syp_pvt_w.rosetta_table_copy_in_p2(ddp_sypv_tbl, p5_a0
      , p5_a1
      , p5_a2
      , p5_a3
      , p5_a4
      , p5_a5
      , p5_a6
      , p5_a7
      , p5_a8
      , p5_a9
      , p5_a10
      , p5_a11
      , p5_a12
      , p5_a13
      , p5_a14
      , p5_a15
      , p5_a16
      , p5_a17
      , p5_a18
      , p5_a19
      , p5_a20
      , p5_a21
      , p5_a22
      , p5_a23
      , p5_a24
      , p5_a25
      , p5_a26
      , p5_a27
      , p5_a28
      , p5_a29
      , p5_a30
      , p5_a31
      , p5_a32
      , p5_a33
      , p5_a34
      , p5_a35
      , p5_a36
      , p5_a37
      , p5_a38
      , p5_a39
      , p5_a40
      , p5_a41
      , p5_a42
      , p5_a43
      , p5_a44
      , p5_a45
      , p5_a46
      , p5_a47
      , p5_a48
      , p5_a49
      , p5_a50
      , p5_a51
      , p5_a52
      , p5_a53
      , p5_a54
      , p5_a55
      , p5_a56
      , p5_a57
      , p5_a58
      , p5_a59
      , p5_a60
      , p5_a61
      , p5_a62
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_system_params_all_pub.insert_system_parameters(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_sypv_tbl,
      ddx_sypv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_syp_pvt_w.rosetta_table_copy_out_p2(ddx_sypv_tbl, p6_a0
      , p6_a1
      , p6_a2
      , p6_a3
      , p6_a4
      , p6_a5
      , p6_a6
      , p6_a7
      , p6_a8
      , p6_a9
      , p6_a10
      , p6_a11
      , p6_a12
      , p6_a13
      , p6_a14
      , p6_a15
      , p6_a16
      , p6_a17
      , p6_a18
      , p6_a19
      , p6_a20
      , p6_a21
      , p6_a22
      , p6_a23
      , p6_a24
      , p6_a25
      , p6_a26
      , p6_a27
      , p6_a28
      , p6_a29
      , p6_a30
      , p6_a31
      , p6_a32
      , p6_a33
      , p6_a34
      , p6_a35
      , p6_a36
      , p6_a37
      , p6_a38
      , p6_a39
      , p6_a40
      , p6_a41
      , p6_a42
      , p6_a43
      , p6_a44
      , p6_a45
      , p6_a46
      , p6_a47
      , p6_a48
      , p6_a49
      , p6_a50
      , p6_a51
      , p6_a52
      , p6_a53
      , p6_a54
      , p6_a55
      , p6_a56
      , p6_a57
      , p6_a58
      , p6_a59
      , p6_a60
      , p6_a61
      , p6_a62
      );
  end;

  procedure lock_system_parameters(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  VARCHAR2 := fnd_api.g_miss_char
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  VARCHAR2 := fnd_api.g_miss_char
    , p5_a10  VARCHAR2 := fnd_api.g_miss_char
    , p5_a11  VARCHAR2 := fnd_api.g_miss_char
    , p5_a12  NUMBER := 0-1962.0724
    , p5_a13  NUMBER := 0-1962.0724
    , p5_a14  NUMBER := 0-1962.0724
    , p5_a15  VARCHAR2 := fnd_api.g_miss_char
    , p5_a16  VARCHAR2 := fnd_api.g_miss_char
    , p5_a17  NUMBER := 0-1962.0724
    , p5_a18  VARCHAR2 := fnd_api.g_miss_char
    , p5_a19  NUMBER := 0-1962.0724
    , p5_a20  NUMBER := 0-1962.0724
    , p5_a21  VARCHAR2 := fnd_api.g_miss_char
    , p5_a22  VARCHAR2 := fnd_api.g_miss_char
    , p5_a23  NUMBER := 0-1962.0724
    , p5_a24  VARCHAR2 := fnd_api.g_miss_char
    , p5_a25  VARCHAR2 := fnd_api.g_miss_char
    , p5_a26  VARCHAR2 := fnd_api.g_miss_char
    , p5_a27  VARCHAR2 := fnd_api.g_miss_char
    , p5_a28  NUMBER := 0-1962.0724
    , p5_a29  NUMBER := 0-1962.0724
    , p5_a30  NUMBER := 0-1962.0724
    , p5_a31  VARCHAR2 := fnd_api.g_miss_char
    , p5_a32  NUMBER := 0-1962.0724
    , p5_a33  NUMBER := 0-1962.0724
    , p5_a34  NUMBER := 0-1962.0724
    , p5_a35  NUMBER := 0-1962.0724
    , p5_a36  NUMBER := 0-1962.0724
    , p5_a37  DATE := fnd_api.g_miss_date
    , p5_a38  VARCHAR2 := fnd_api.g_miss_char
    , p5_a39  VARCHAR2 := fnd_api.g_miss_char
    , p5_a40  VARCHAR2 := fnd_api.g_miss_char
    , p5_a41  VARCHAR2 := fnd_api.g_miss_char
    , p5_a42  VARCHAR2 := fnd_api.g_miss_char
    , p5_a43  VARCHAR2 := fnd_api.g_miss_char
    , p5_a44  VARCHAR2 := fnd_api.g_miss_char
    , p5_a45  VARCHAR2 := fnd_api.g_miss_char
    , p5_a46  VARCHAR2 := fnd_api.g_miss_char
    , p5_a47  VARCHAR2 := fnd_api.g_miss_char
    , p5_a48  VARCHAR2 := fnd_api.g_miss_char
    , p5_a49  VARCHAR2 := fnd_api.g_miss_char
    , p5_a50  VARCHAR2 := fnd_api.g_miss_char
    , p5_a51  VARCHAR2 := fnd_api.g_miss_char
    , p5_a52  VARCHAR2 := fnd_api.g_miss_char
    , p5_a53  VARCHAR2 := fnd_api.g_miss_char
    , p5_a54  NUMBER := 0-1962.0724
    , p5_a55  DATE := fnd_api.g_miss_date
    , p5_a56  NUMBER := 0-1962.0724
    , p5_a57  DATE := fnd_api.g_miss_date
    , p5_a58  NUMBER := 0-1962.0724
    , p5_a59  VARCHAR2 := fnd_api.g_miss_char
    , p5_a60  VARCHAR2 := fnd_api.g_miss_char
    , p5_a61  VARCHAR2 := fnd_api.g_miss_char
    , p5_a62  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_sypv_rec okl_system_params_all_pub.sypv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_sypv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_sypv_rec.delink_yn := p5_a1;
    ddp_sypv_rec.remk_subinventory := p5_a2;
    ddp_sypv_rec.remk_organization_id := rosetta_g_miss_num_map(p5_a3);
    ddp_sypv_rec.remk_price_list_id := rosetta_g_miss_num_map(p5_a4);
    ddp_sypv_rec.remk_process_code := p5_a5;
    ddp_sypv_rec.remk_item_template_id := rosetta_g_miss_num_map(p5_a6);
    ddp_sypv_rec.remk_item_invoiced_code := p5_a7;
    ddp_sypv_rec.lease_inv_org_yn := p5_a8;
    ddp_sypv_rec.tax_upfront_yn := p5_a9;
    ddp_sypv_rec.tax_invoice_yn := p5_a10;
    ddp_sypv_rec.tax_schedule_yn := p5_a11;
    ddp_sypv_rec.tax_upfront_sty_id := rosetta_g_miss_num_map(p5_a12);
    ddp_sypv_rec.category_set_id := rosetta_g_miss_num_map(p5_a13);
    ddp_sypv_rec.validation_set_id := rosetta_g_miss_num_map(p5_a14);
    ddp_sypv_rec.cancel_quotes_yn := p5_a15;
    ddp_sypv_rec.chk_accrual_previous_mnth_yn := p5_a16;
    ddp_sypv_rec.task_template_group_id := rosetta_g_miss_num_map(p5_a17);
    ddp_sypv_rec.owner_type_code := p5_a18;
    ddp_sypv_rec.owner_id := rosetta_g_miss_num_map(p5_a19);
    ddp_sypv_rec.item_inv_org_id := rosetta_g_miss_num_map(p5_a20);
    ddp_sypv_rec.rpt_prod_book_type_code := p5_a21;
    ddp_sypv_rec.asst_add_book_type_code := p5_a22;
    ddp_sypv_rec.ccard_remittance_id := rosetta_g_miss_num_map(p5_a23);
    ddp_sypv_rec.corporate_book := p5_a24;
    ddp_sypv_rec.tax_book_1 := p5_a25;
    ddp_sypv_rec.tax_book_2 := p5_a26;
    ddp_sypv_rec.depreciate_yn := p5_a27;
    ddp_sypv_rec.fa_location_id := rosetta_g_miss_num_map(p5_a28);
    ddp_sypv_rec.formula_id := rosetta_g_miss_num_map(p5_a29);
    ddp_sypv_rec.asset_key_id := rosetta_g_miss_num_map(p5_a30);
    ddp_sypv_rec.part_trmnt_apply_round_diff := p5_a31;
    ddp_sypv_rec.object_version_number := rosetta_g_miss_num_map(p5_a32);
    ddp_sypv_rec.org_id := rosetta_g_miss_num_map(p5_a33);
    ddp_sypv_rec.request_id := rosetta_g_miss_num_map(p5_a34);
    ddp_sypv_rec.program_application_id := rosetta_g_miss_num_map(p5_a35);
    ddp_sypv_rec.program_id := rosetta_g_miss_num_map(p5_a36);
    ddp_sypv_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a37);
    ddp_sypv_rec.attribute_category := p5_a38;
    ddp_sypv_rec.attribute1 := p5_a39;
    ddp_sypv_rec.attribute2 := p5_a40;
    ddp_sypv_rec.attribute3 := p5_a41;
    ddp_sypv_rec.attribute4 := p5_a42;
    ddp_sypv_rec.attribute5 := p5_a43;
    ddp_sypv_rec.attribute6 := p5_a44;
    ddp_sypv_rec.attribute7 := p5_a45;
    ddp_sypv_rec.attribute8 := p5_a46;
    ddp_sypv_rec.attribute9 := p5_a47;
    ddp_sypv_rec.attribute10 := p5_a48;
    ddp_sypv_rec.attribute11 := p5_a49;
    ddp_sypv_rec.attribute12 := p5_a50;
    ddp_sypv_rec.attribute13 := p5_a51;
    ddp_sypv_rec.attribute14 := p5_a52;
    ddp_sypv_rec.attribute15 := p5_a53;
    ddp_sypv_rec.created_by := rosetta_g_miss_num_map(p5_a54);
    ddp_sypv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a55);
    ddp_sypv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a56);
    ddp_sypv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a57);
    ddp_sypv_rec.last_update_login := rosetta_g_miss_num_map(p5_a58);
    ddp_sypv_rec.lseapp_seq_prefix_txt := p5_a59;
    ddp_sypv_rec.lseopp_seq_prefix_txt := p5_a60;
    ddp_sypv_rec.qckqte_seq_prefix_txt := p5_a61;
    ddp_sypv_rec.lseqte_seq_prefix_txt := p5_a62;

    -- here's the delegated call to the old PL/SQL routine
    okl_system_params_all_pub.lock_system_parameters(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_sypv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure lock_system_parameters(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_VARCHAR2_TABLE_100
    , p5_a2 JTF_VARCHAR2_TABLE_100
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_VARCHAR2_TABLE_100
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_VARCHAR2_TABLE_100
    , p5_a8 JTF_VARCHAR2_TABLE_100
    , p5_a9 JTF_VARCHAR2_TABLE_100
    , p5_a10 JTF_VARCHAR2_TABLE_100
    , p5_a11 JTF_VARCHAR2_TABLE_100
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_NUMBER_TABLE
    , p5_a14 JTF_NUMBER_TABLE
    , p5_a15 JTF_VARCHAR2_TABLE_100
    , p5_a16 JTF_VARCHAR2_TABLE_100
    , p5_a17 JTF_NUMBER_TABLE
    , p5_a18 JTF_VARCHAR2_TABLE_100
    , p5_a19 JTF_NUMBER_TABLE
    , p5_a20 JTF_NUMBER_TABLE
    , p5_a21 JTF_VARCHAR2_TABLE_100
    , p5_a22 JTF_VARCHAR2_TABLE_100
    , p5_a23 JTF_NUMBER_TABLE
    , p5_a24 JTF_VARCHAR2_TABLE_100
    , p5_a25 JTF_VARCHAR2_TABLE_100
    , p5_a26 JTF_VARCHAR2_TABLE_100
    , p5_a27 JTF_VARCHAR2_TABLE_100
    , p5_a28 JTF_NUMBER_TABLE
    , p5_a29 JTF_NUMBER_TABLE
    , p5_a30 JTF_NUMBER_TABLE
    , p5_a31 JTF_VARCHAR2_TABLE_100
    , p5_a32 JTF_NUMBER_TABLE
    , p5_a33 JTF_NUMBER_TABLE
    , p5_a34 JTF_NUMBER_TABLE
    , p5_a35 JTF_NUMBER_TABLE
    , p5_a36 JTF_NUMBER_TABLE
    , p5_a37 JTF_DATE_TABLE
    , p5_a38 JTF_VARCHAR2_TABLE_100
    , p5_a39 JTF_VARCHAR2_TABLE_500
    , p5_a40 JTF_VARCHAR2_TABLE_500
    , p5_a41 JTF_VARCHAR2_TABLE_500
    , p5_a42 JTF_VARCHAR2_TABLE_500
    , p5_a43 JTF_VARCHAR2_TABLE_500
    , p5_a44 JTF_VARCHAR2_TABLE_500
    , p5_a45 JTF_VARCHAR2_TABLE_500
    , p5_a46 JTF_VARCHAR2_TABLE_500
    , p5_a47 JTF_VARCHAR2_TABLE_500
    , p5_a48 JTF_VARCHAR2_TABLE_500
    , p5_a49 JTF_VARCHAR2_TABLE_500
    , p5_a50 JTF_VARCHAR2_TABLE_500
    , p5_a51 JTF_VARCHAR2_TABLE_500
    , p5_a52 JTF_VARCHAR2_TABLE_500
    , p5_a53 JTF_VARCHAR2_TABLE_500
    , p5_a54 JTF_NUMBER_TABLE
    , p5_a55 JTF_DATE_TABLE
    , p5_a56 JTF_NUMBER_TABLE
    , p5_a57 JTF_DATE_TABLE
    , p5_a58 JTF_NUMBER_TABLE
    , p5_a59 JTF_VARCHAR2_TABLE_200
    , p5_a60 JTF_VARCHAR2_TABLE_200
    , p5_a61 JTF_VARCHAR2_TABLE_200
    , p5_a62 JTF_VARCHAR2_TABLE_200
  )

  as
    ddp_sypv_tbl okl_system_params_all_pub.sypv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_syp_pvt_w.rosetta_table_copy_in_p2(ddp_sypv_tbl, p5_a0
      , p5_a1
      , p5_a2
      , p5_a3
      , p5_a4
      , p5_a5
      , p5_a6
      , p5_a7
      , p5_a8
      , p5_a9
      , p5_a10
      , p5_a11
      , p5_a12
      , p5_a13
      , p5_a14
      , p5_a15
      , p5_a16
      , p5_a17
      , p5_a18
      , p5_a19
      , p5_a20
      , p5_a21
      , p5_a22
      , p5_a23
      , p5_a24
      , p5_a25
      , p5_a26
      , p5_a27
      , p5_a28
      , p5_a29
      , p5_a30
      , p5_a31
      , p5_a32
      , p5_a33
      , p5_a34
      , p5_a35
      , p5_a36
      , p5_a37
      , p5_a38
      , p5_a39
      , p5_a40
      , p5_a41
      , p5_a42
      , p5_a43
      , p5_a44
      , p5_a45
      , p5_a46
      , p5_a47
      , p5_a48
      , p5_a49
      , p5_a50
      , p5_a51
      , p5_a52
      , p5_a53
      , p5_a54
      , p5_a55
      , p5_a56
      , p5_a57
      , p5_a58
      , p5_a59
      , p5_a60
      , p5_a61
      , p5_a62
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_system_params_all_pub.lock_system_parameters(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_sypv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure update_system_parameters(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  VARCHAR2
    , p6_a2 out nocopy  VARCHAR2
    , p6_a3 out nocopy  NUMBER
    , p6_a4 out nocopy  NUMBER
    , p6_a5 out nocopy  VARCHAR2
    , p6_a6 out nocopy  NUMBER
    , p6_a7 out nocopy  VARCHAR2
    , p6_a8 out nocopy  VARCHAR2
    , p6_a9 out nocopy  VARCHAR2
    , p6_a10 out nocopy  VARCHAR2
    , p6_a11 out nocopy  VARCHAR2
    , p6_a12 out nocopy  NUMBER
    , p6_a13 out nocopy  NUMBER
    , p6_a14 out nocopy  NUMBER
    , p6_a15 out nocopy  VARCHAR2
    , p6_a16 out nocopy  VARCHAR2
    , p6_a17 out nocopy  NUMBER
    , p6_a18 out nocopy  VARCHAR2
    , p6_a19 out nocopy  NUMBER
    , p6_a20 out nocopy  NUMBER
    , p6_a21 out nocopy  VARCHAR2
    , p6_a22 out nocopy  VARCHAR2
    , p6_a23 out nocopy  NUMBER
    , p6_a24 out nocopy  VARCHAR2
    , p6_a25 out nocopy  VARCHAR2
    , p6_a26 out nocopy  VARCHAR2
    , p6_a27 out nocopy  VARCHAR2
    , p6_a28 out nocopy  NUMBER
    , p6_a29 out nocopy  NUMBER
    , p6_a30 out nocopy  NUMBER
    , p6_a31 out nocopy  VARCHAR2
    , p6_a32 out nocopy  NUMBER
    , p6_a33 out nocopy  NUMBER
    , p6_a34 out nocopy  NUMBER
    , p6_a35 out nocopy  NUMBER
    , p6_a36 out nocopy  NUMBER
    , p6_a37 out nocopy  DATE
    , p6_a38 out nocopy  VARCHAR2
    , p6_a39 out nocopy  VARCHAR2
    , p6_a40 out nocopy  VARCHAR2
    , p6_a41 out nocopy  VARCHAR2
    , p6_a42 out nocopy  VARCHAR2
    , p6_a43 out nocopy  VARCHAR2
    , p6_a44 out nocopy  VARCHAR2
    , p6_a45 out nocopy  VARCHAR2
    , p6_a46 out nocopy  VARCHAR2
    , p6_a47 out nocopy  VARCHAR2
    , p6_a48 out nocopy  VARCHAR2
    , p6_a49 out nocopy  VARCHAR2
    , p6_a50 out nocopy  VARCHAR2
    , p6_a51 out nocopy  VARCHAR2
    , p6_a52 out nocopy  VARCHAR2
    , p6_a53 out nocopy  VARCHAR2
    , p6_a54 out nocopy  NUMBER
    , p6_a55 out nocopy  DATE
    , p6_a56 out nocopy  NUMBER
    , p6_a57 out nocopy  DATE
    , p6_a58 out nocopy  NUMBER
    , p6_a59 out nocopy  VARCHAR2
    , p6_a60 out nocopy  VARCHAR2
    , p6_a61 out nocopy  VARCHAR2
    , p6_a62 out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  VARCHAR2 := fnd_api.g_miss_char
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  VARCHAR2 := fnd_api.g_miss_char
    , p5_a10  VARCHAR2 := fnd_api.g_miss_char
    , p5_a11  VARCHAR2 := fnd_api.g_miss_char
    , p5_a12  NUMBER := 0-1962.0724
    , p5_a13  NUMBER := 0-1962.0724
    , p5_a14  NUMBER := 0-1962.0724
    , p5_a15  VARCHAR2 := fnd_api.g_miss_char
    , p5_a16  VARCHAR2 := fnd_api.g_miss_char
    , p5_a17  NUMBER := 0-1962.0724
    , p5_a18  VARCHAR2 := fnd_api.g_miss_char
    , p5_a19  NUMBER := 0-1962.0724
    , p5_a20  NUMBER := 0-1962.0724
    , p5_a21  VARCHAR2 := fnd_api.g_miss_char
    , p5_a22  VARCHAR2 := fnd_api.g_miss_char
    , p5_a23  NUMBER := 0-1962.0724
    , p5_a24  VARCHAR2 := fnd_api.g_miss_char
    , p5_a25  VARCHAR2 := fnd_api.g_miss_char
    , p5_a26  VARCHAR2 := fnd_api.g_miss_char
    , p5_a27  VARCHAR2 := fnd_api.g_miss_char
    , p5_a28  NUMBER := 0-1962.0724
    , p5_a29  NUMBER := 0-1962.0724
    , p5_a30  NUMBER := 0-1962.0724
    , p5_a31  VARCHAR2 := fnd_api.g_miss_char
    , p5_a32  NUMBER := 0-1962.0724
    , p5_a33  NUMBER := 0-1962.0724
    , p5_a34  NUMBER := 0-1962.0724
    , p5_a35  NUMBER := 0-1962.0724
    , p5_a36  NUMBER := 0-1962.0724
    , p5_a37  DATE := fnd_api.g_miss_date
    , p5_a38  VARCHAR2 := fnd_api.g_miss_char
    , p5_a39  VARCHAR2 := fnd_api.g_miss_char
    , p5_a40  VARCHAR2 := fnd_api.g_miss_char
    , p5_a41  VARCHAR2 := fnd_api.g_miss_char
    , p5_a42  VARCHAR2 := fnd_api.g_miss_char
    , p5_a43  VARCHAR2 := fnd_api.g_miss_char
    , p5_a44  VARCHAR2 := fnd_api.g_miss_char
    , p5_a45  VARCHAR2 := fnd_api.g_miss_char
    , p5_a46  VARCHAR2 := fnd_api.g_miss_char
    , p5_a47  VARCHAR2 := fnd_api.g_miss_char
    , p5_a48  VARCHAR2 := fnd_api.g_miss_char
    , p5_a49  VARCHAR2 := fnd_api.g_miss_char
    , p5_a50  VARCHAR2 := fnd_api.g_miss_char
    , p5_a51  VARCHAR2 := fnd_api.g_miss_char
    , p5_a52  VARCHAR2 := fnd_api.g_miss_char
    , p5_a53  VARCHAR2 := fnd_api.g_miss_char
    , p5_a54  NUMBER := 0-1962.0724
    , p5_a55  DATE := fnd_api.g_miss_date
    , p5_a56  NUMBER := 0-1962.0724
    , p5_a57  DATE := fnd_api.g_miss_date
    , p5_a58  NUMBER := 0-1962.0724
    , p5_a59  VARCHAR2 := fnd_api.g_miss_char
    , p5_a60  VARCHAR2 := fnd_api.g_miss_char
    , p5_a61  VARCHAR2 := fnd_api.g_miss_char
    , p5_a62  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_sypv_rec okl_system_params_all_pub.sypv_rec_type;
    ddx_sypv_rec okl_system_params_all_pub.sypv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_sypv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_sypv_rec.delink_yn := p5_a1;
    ddp_sypv_rec.remk_subinventory := p5_a2;
    ddp_sypv_rec.remk_organization_id := rosetta_g_miss_num_map(p5_a3);
    ddp_sypv_rec.remk_price_list_id := rosetta_g_miss_num_map(p5_a4);
    ddp_sypv_rec.remk_process_code := p5_a5;
    ddp_sypv_rec.remk_item_template_id := rosetta_g_miss_num_map(p5_a6);
    ddp_sypv_rec.remk_item_invoiced_code := p5_a7;
    ddp_sypv_rec.lease_inv_org_yn := p5_a8;
    ddp_sypv_rec.tax_upfront_yn := p5_a9;
    ddp_sypv_rec.tax_invoice_yn := p5_a10;
    ddp_sypv_rec.tax_schedule_yn := p5_a11;
    ddp_sypv_rec.tax_upfront_sty_id := rosetta_g_miss_num_map(p5_a12);
    ddp_sypv_rec.category_set_id := rosetta_g_miss_num_map(p5_a13);
    ddp_sypv_rec.validation_set_id := rosetta_g_miss_num_map(p5_a14);
    ddp_sypv_rec.cancel_quotes_yn := p5_a15;
    ddp_sypv_rec.chk_accrual_previous_mnth_yn := p5_a16;
    ddp_sypv_rec.task_template_group_id := rosetta_g_miss_num_map(p5_a17);
    ddp_sypv_rec.owner_type_code := p5_a18;
    ddp_sypv_rec.owner_id := rosetta_g_miss_num_map(p5_a19);
    ddp_sypv_rec.item_inv_org_id := rosetta_g_miss_num_map(p5_a20);
    ddp_sypv_rec.rpt_prod_book_type_code := p5_a21;
    ddp_sypv_rec.asst_add_book_type_code := p5_a22;
    ddp_sypv_rec.ccard_remittance_id := rosetta_g_miss_num_map(p5_a23);
    ddp_sypv_rec.corporate_book := p5_a24;
    ddp_sypv_rec.tax_book_1 := p5_a25;
    ddp_sypv_rec.tax_book_2 := p5_a26;
    ddp_sypv_rec.depreciate_yn := p5_a27;
    ddp_sypv_rec.fa_location_id := rosetta_g_miss_num_map(p5_a28);
    ddp_sypv_rec.formula_id := rosetta_g_miss_num_map(p5_a29);
    ddp_sypv_rec.asset_key_id := rosetta_g_miss_num_map(p5_a30);
    ddp_sypv_rec.part_trmnt_apply_round_diff := p5_a31;
    ddp_sypv_rec.object_version_number := rosetta_g_miss_num_map(p5_a32);
    ddp_sypv_rec.org_id := rosetta_g_miss_num_map(p5_a33);
    ddp_sypv_rec.request_id := rosetta_g_miss_num_map(p5_a34);
    ddp_sypv_rec.program_application_id := rosetta_g_miss_num_map(p5_a35);
    ddp_sypv_rec.program_id := rosetta_g_miss_num_map(p5_a36);
    ddp_sypv_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a37);
    ddp_sypv_rec.attribute_category := p5_a38;
    ddp_sypv_rec.attribute1 := p5_a39;
    ddp_sypv_rec.attribute2 := p5_a40;
    ddp_sypv_rec.attribute3 := p5_a41;
    ddp_sypv_rec.attribute4 := p5_a42;
    ddp_sypv_rec.attribute5 := p5_a43;
    ddp_sypv_rec.attribute6 := p5_a44;
    ddp_sypv_rec.attribute7 := p5_a45;
    ddp_sypv_rec.attribute8 := p5_a46;
    ddp_sypv_rec.attribute9 := p5_a47;
    ddp_sypv_rec.attribute10 := p5_a48;
    ddp_sypv_rec.attribute11 := p5_a49;
    ddp_sypv_rec.attribute12 := p5_a50;
    ddp_sypv_rec.attribute13 := p5_a51;
    ddp_sypv_rec.attribute14 := p5_a52;
    ddp_sypv_rec.attribute15 := p5_a53;
    ddp_sypv_rec.created_by := rosetta_g_miss_num_map(p5_a54);
    ddp_sypv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a55);
    ddp_sypv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a56);
    ddp_sypv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a57);
    ddp_sypv_rec.last_update_login := rosetta_g_miss_num_map(p5_a58);
    ddp_sypv_rec.lseapp_seq_prefix_txt := p5_a59;
    ddp_sypv_rec.lseopp_seq_prefix_txt := p5_a60;
    ddp_sypv_rec.qckqte_seq_prefix_txt := p5_a61;
    ddp_sypv_rec.lseqte_seq_prefix_txt := p5_a62;


    -- here's the delegated call to the old PL/SQL routine
    okl_system_params_all_pub.update_system_parameters(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_sypv_rec,
      ddx_sypv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_sypv_rec.id);
    p6_a1 := ddx_sypv_rec.delink_yn;
    p6_a2 := ddx_sypv_rec.remk_subinventory;
    p6_a3 := rosetta_g_miss_num_map(ddx_sypv_rec.remk_organization_id);
    p6_a4 := rosetta_g_miss_num_map(ddx_sypv_rec.remk_price_list_id);
    p6_a5 := ddx_sypv_rec.remk_process_code;
    p6_a6 := rosetta_g_miss_num_map(ddx_sypv_rec.remk_item_template_id);
    p6_a7 := ddx_sypv_rec.remk_item_invoiced_code;
    p6_a8 := ddx_sypv_rec.lease_inv_org_yn;
    p6_a9 := ddx_sypv_rec.tax_upfront_yn;
    p6_a10 := ddx_sypv_rec.tax_invoice_yn;
    p6_a11 := ddx_sypv_rec.tax_schedule_yn;
    p6_a12 := rosetta_g_miss_num_map(ddx_sypv_rec.tax_upfront_sty_id);
    p6_a13 := rosetta_g_miss_num_map(ddx_sypv_rec.category_set_id);
    p6_a14 := rosetta_g_miss_num_map(ddx_sypv_rec.validation_set_id);
    p6_a15 := ddx_sypv_rec.cancel_quotes_yn;
    p6_a16 := ddx_sypv_rec.chk_accrual_previous_mnth_yn;
    p6_a17 := rosetta_g_miss_num_map(ddx_sypv_rec.task_template_group_id);
    p6_a18 := ddx_sypv_rec.owner_type_code;
    p6_a19 := rosetta_g_miss_num_map(ddx_sypv_rec.owner_id);
    p6_a20 := rosetta_g_miss_num_map(ddx_sypv_rec.item_inv_org_id);
    p6_a21 := ddx_sypv_rec.rpt_prod_book_type_code;
    p6_a22 := ddx_sypv_rec.asst_add_book_type_code;
    p6_a23 := rosetta_g_miss_num_map(ddx_sypv_rec.ccard_remittance_id);
    p6_a24 := ddx_sypv_rec.corporate_book;
    p6_a25 := ddx_sypv_rec.tax_book_1;
    p6_a26 := ddx_sypv_rec.tax_book_2;
    p6_a27 := ddx_sypv_rec.depreciate_yn;
    p6_a28 := rosetta_g_miss_num_map(ddx_sypv_rec.fa_location_id);
    p6_a29 := rosetta_g_miss_num_map(ddx_sypv_rec.formula_id);
    p6_a30 := rosetta_g_miss_num_map(ddx_sypv_rec.asset_key_id);
    p6_a31 := ddx_sypv_rec.part_trmnt_apply_round_diff;
    p6_a32 := rosetta_g_miss_num_map(ddx_sypv_rec.object_version_number);
    p6_a33 := rosetta_g_miss_num_map(ddx_sypv_rec.org_id);
    p6_a34 := rosetta_g_miss_num_map(ddx_sypv_rec.request_id);
    p6_a35 := rosetta_g_miss_num_map(ddx_sypv_rec.program_application_id);
    p6_a36 := rosetta_g_miss_num_map(ddx_sypv_rec.program_id);
    p6_a37 := ddx_sypv_rec.program_update_date;
    p6_a38 := ddx_sypv_rec.attribute_category;
    p6_a39 := ddx_sypv_rec.attribute1;
    p6_a40 := ddx_sypv_rec.attribute2;
    p6_a41 := ddx_sypv_rec.attribute3;
    p6_a42 := ddx_sypv_rec.attribute4;
    p6_a43 := ddx_sypv_rec.attribute5;
    p6_a44 := ddx_sypv_rec.attribute6;
    p6_a45 := ddx_sypv_rec.attribute7;
    p6_a46 := ddx_sypv_rec.attribute8;
    p6_a47 := ddx_sypv_rec.attribute9;
    p6_a48 := ddx_sypv_rec.attribute10;
    p6_a49 := ddx_sypv_rec.attribute11;
    p6_a50 := ddx_sypv_rec.attribute12;
    p6_a51 := ddx_sypv_rec.attribute13;
    p6_a52 := ddx_sypv_rec.attribute14;
    p6_a53 := ddx_sypv_rec.attribute15;
    p6_a54 := rosetta_g_miss_num_map(ddx_sypv_rec.created_by);
    p6_a55 := ddx_sypv_rec.creation_date;
    p6_a56 := rosetta_g_miss_num_map(ddx_sypv_rec.last_updated_by);
    p6_a57 := ddx_sypv_rec.last_update_date;
    p6_a58 := rosetta_g_miss_num_map(ddx_sypv_rec.last_update_login);
    p6_a59 := ddx_sypv_rec.lseapp_seq_prefix_txt;
    p6_a60 := ddx_sypv_rec.lseopp_seq_prefix_txt;
    p6_a61 := ddx_sypv_rec.qckqte_seq_prefix_txt;
    p6_a62 := ddx_sypv_rec.lseqte_seq_prefix_txt;
  end;

  procedure update_system_parameters(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_VARCHAR2_TABLE_100
    , p5_a2 JTF_VARCHAR2_TABLE_100
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_VARCHAR2_TABLE_100
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_VARCHAR2_TABLE_100
    , p5_a8 JTF_VARCHAR2_TABLE_100
    , p5_a9 JTF_VARCHAR2_TABLE_100
    , p5_a10 JTF_VARCHAR2_TABLE_100
    , p5_a11 JTF_VARCHAR2_TABLE_100
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_NUMBER_TABLE
    , p5_a14 JTF_NUMBER_TABLE
    , p5_a15 JTF_VARCHAR2_TABLE_100
    , p5_a16 JTF_VARCHAR2_TABLE_100
    , p5_a17 JTF_NUMBER_TABLE
    , p5_a18 JTF_VARCHAR2_TABLE_100
    , p5_a19 JTF_NUMBER_TABLE
    , p5_a20 JTF_NUMBER_TABLE
    , p5_a21 JTF_VARCHAR2_TABLE_100
    , p5_a22 JTF_VARCHAR2_TABLE_100
    , p5_a23 JTF_NUMBER_TABLE
    , p5_a24 JTF_VARCHAR2_TABLE_100
    , p5_a25 JTF_VARCHAR2_TABLE_100
    , p5_a26 JTF_VARCHAR2_TABLE_100
    , p5_a27 JTF_VARCHAR2_TABLE_100
    , p5_a28 JTF_NUMBER_TABLE
    , p5_a29 JTF_NUMBER_TABLE
    , p5_a30 JTF_NUMBER_TABLE
    , p5_a31 JTF_VARCHAR2_TABLE_100
    , p5_a32 JTF_NUMBER_TABLE
    , p5_a33 JTF_NUMBER_TABLE
    , p5_a34 JTF_NUMBER_TABLE
    , p5_a35 JTF_NUMBER_TABLE
    , p5_a36 JTF_NUMBER_TABLE
    , p5_a37 JTF_DATE_TABLE
    , p5_a38 JTF_VARCHAR2_TABLE_100
    , p5_a39 JTF_VARCHAR2_TABLE_500
    , p5_a40 JTF_VARCHAR2_TABLE_500
    , p5_a41 JTF_VARCHAR2_TABLE_500
    , p5_a42 JTF_VARCHAR2_TABLE_500
    , p5_a43 JTF_VARCHAR2_TABLE_500
    , p5_a44 JTF_VARCHAR2_TABLE_500
    , p5_a45 JTF_VARCHAR2_TABLE_500
    , p5_a46 JTF_VARCHAR2_TABLE_500
    , p5_a47 JTF_VARCHAR2_TABLE_500
    , p5_a48 JTF_VARCHAR2_TABLE_500
    , p5_a49 JTF_VARCHAR2_TABLE_500
    , p5_a50 JTF_VARCHAR2_TABLE_500
    , p5_a51 JTF_VARCHAR2_TABLE_500
    , p5_a52 JTF_VARCHAR2_TABLE_500
    , p5_a53 JTF_VARCHAR2_TABLE_500
    , p5_a54 JTF_NUMBER_TABLE
    , p5_a55 JTF_DATE_TABLE
    , p5_a56 JTF_NUMBER_TABLE
    , p5_a57 JTF_DATE_TABLE
    , p5_a58 JTF_NUMBER_TABLE
    , p5_a59 JTF_VARCHAR2_TABLE_200
    , p5_a60 JTF_VARCHAR2_TABLE_200
    , p5_a61 JTF_VARCHAR2_TABLE_200
    , p5_a62 JTF_VARCHAR2_TABLE_200
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a3 out nocopy JTF_NUMBER_TABLE
    , p6_a4 out nocopy JTF_NUMBER_TABLE
    , p6_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a6 out nocopy JTF_NUMBER_TABLE
    , p6_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a10 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a11 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a12 out nocopy JTF_NUMBER_TABLE
    , p6_a13 out nocopy JTF_NUMBER_TABLE
    , p6_a14 out nocopy JTF_NUMBER_TABLE
    , p6_a15 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a16 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a17 out nocopy JTF_NUMBER_TABLE
    , p6_a18 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a19 out nocopy JTF_NUMBER_TABLE
    , p6_a20 out nocopy JTF_NUMBER_TABLE
    , p6_a21 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a22 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a23 out nocopy JTF_NUMBER_TABLE
    , p6_a24 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a25 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a26 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a27 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a28 out nocopy JTF_NUMBER_TABLE
    , p6_a29 out nocopy JTF_NUMBER_TABLE
    , p6_a30 out nocopy JTF_NUMBER_TABLE
    , p6_a31 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a32 out nocopy JTF_NUMBER_TABLE
    , p6_a33 out nocopy JTF_NUMBER_TABLE
    , p6_a34 out nocopy JTF_NUMBER_TABLE
    , p6_a35 out nocopy JTF_NUMBER_TABLE
    , p6_a36 out nocopy JTF_NUMBER_TABLE
    , p6_a37 out nocopy JTF_DATE_TABLE
    , p6_a38 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a39 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a40 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a41 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a42 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a43 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a44 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a45 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a46 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a47 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a48 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a49 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a50 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a51 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a52 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a53 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a54 out nocopy JTF_NUMBER_TABLE
    , p6_a55 out nocopy JTF_DATE_TABLE
    , p6_a56 out nocopy JTF_NUMBER_TABLE
    , p6_a57 out nocopy JTF_DATE_TABLE
    , p6_a58 out nocopy JTF_NUMBER_TABLE
    , p6_a59 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a60 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a61 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a62 out nocopy JTF_VARCHAR2_TABLE_200
  )

  as
    ddp_sypv_tbl okl_system_params_all_pub.sypv_tbl_type;
    ddx_sypv_tbl okl_system_params_all_pub.sypv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_syp_pvt_w.rosetta_table_copy_in_p2(ddp_sypv_tbl, p5_a0
      , p5_a1
      , p5_a2
      , p5_a3
      , p5_a4
      , p5_a5
      , p5_a6
      , p5_a7
      , p5_a8
      , p5_a9
      , p5_a10
      , p5_a11
      , p5_a12
      , p5_a13
      , p5_a14
      , p5_a15
      , p5_a16
      , p5_a17
      , p5_a18
      , p5_a19
      , p5_a20
      , p5_a21
      , p5_a22
      , p5_a23
      , p5_a24
      , p5_a25
      , p5_a26
      , p5_a27
      , p5_a28
      , p5_a29
      , p5_a30
      , p5_a31
      , p5_a32
      , p5_a33
      , p5_a34
      , p5_a35
      , p5_a36
      , p5_a37
      , p5_a38
      , p5_a39
      , p5_a40
      , p5_a41
      , p5_a42
      , p5_a43
      , p5_a44
      , p5_a45
      , p5_a46
      , p5_a47
      , p5_a48
      , p5_a49
      , p5_a50
      , p5_a51
      , p5_a52
      , p5_a53
      , p5_a54
      , p5_a55
      , p5_a56
      , p5_a57
      , p5_a58
      , p5_a59
      , p5_a60
      , p5_a61
      , p5_a62
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_system_params_all_pub.update_system_parameters(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_sypv_tbl,
      ddx_sypv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_syp_pvt_w.rosetta_table_copy_out_p2(ddx_sypv_tbl, p6_a0
      , p6_a1
      , p6_a2
      , p6_a3
      , p6_a4
      , p6_a5
      , p6_a6
      , p6_a7
      , p6_a8
      , p6_a9
      , p6_a10
      , p6_a11
      , p6_a12
      , p6_a13
      , p6_a14
      , p6_a15
      , p6_a16
      , p6_a17
      , p6_a18
      , p6_a19
      , p6_a20
      , p6_a21
      , p6_a22
      , p6_a23
      , p6_a24
      , p6_a25
      , p6_a26
      , p6_a27
      , p6_a28
      , p6_a29
      , p6_a30
      , p6_a31
      , p6_a32
      , p6_a33
      , p6_a34
      , p6_a35
      , p6_a36
      , p6_a37
      , p6_a38
      , p6_a39
      , p6_a40
      , p6_a41
      , p6_a42
      , p6_a43
      , p6_a44
      , p6_a45
      , p6_a46
      , p6_a47
      , p6_a48
      , p6_a49
      , p6_a50
      , p6_a51
      , p6_a52
      , p6_a53
      , p6_a54
      , p6_a55
      , p6_a56
      , p6_a57
      , p6_a58
      , p6_a59
      , p6_a60
      , p6_a61
      , p6_a62
      );
  end;

  procedure delete_system_parameters(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  VARCHAR2 := fnd_api.g_miss_char
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  VARCHAR2 := fnd_api.g_miss_char
    , p5_a10  VARCHAR2 := fnd_api.g_miss_char
    , p5_a11  VARCHAR2 := fnd_api.g_miss_char
    , p5_a12  NUMBER := 0-1962.0724
    , p5_a13  NUMBER := 0-1962.0724
    , p5_a14  NUMBER := 0-1962.0724
    , p5_a15  VARCHAR2 := fnd_api.g_miss_char
    , p5_a16  VARCHAR2 := fnd_api.g_miss_char
    , p5_a17  NUMBER := 0-1962.0724
    , p5_a18  VARCHAR2 := fnd_api.g_miss_char
    , p5_a19  NUMBER := 0-1962.0724
    , p5_a20  NUMBER := 0-1962.0724
    , p5_a21  VARCHAR2 := fnd_api.g_miss_char
    , p5_a22  VARCHAR2 := fnd_api.g_miss_char
    , p5_a23  NUMBER := 0-1962.0724
    , p5_a24  VARCHAR2 := fnd_api.g_miss_char
    , p5_a25  VARCHAR2 := fnd_api.g_miss_char
    , p5_a26  VARCHAR2 := fnd_api.g_miss_char
    , p5_a27  VARCHAR2 := fnd_api.g_miss_char
    , p5_a28  NUMBER := 0-1962.0724
    , p5_a29  NUMBER := 0-1962.0724
    , p5_a30  NUMBER := 0-1962.0724
    , p5_a31  VARCHAR2 := fnd_api.g_miss_char
    , p5_a32  NUMBER := 0-1962.0724
    , p5_a33  NUMBER := 0-1962.0724
    , p5_a34  NUMBER := 0-1962.0724
    , p5_a35  NUMBER := 0-1962.0724
    , p5_a36  NUMBER := 0-1962.0724
    , p5_a37  DATE := fnd_api.g_miss_date
    , p5_a38  VARCHAR2 := fnd_api.g_miss_char
    , p5_a39  VARCHAR2 := fnd_api.g_miss_char
    , p5_a40  VARCHAR2 := fnd_api.g_miss_char
    , p5_a41  VARCHAR2 := fnd_api.g_miss_char
    , p5_a42  VARCHAR2 := fnd_api.g_miss_char
    , p5_a43  VARCHAR2 := fnd_api.g_miss_char
    , p5_a44  VARCHAR2 := fnd_api.g_miss_char
    , p5_a45  VARCHAR2 := fnd_api.g_miss_char
    , p5_a46  VARCHAR2 := fnd_api.g_miss_char
    , p5_a47  VARCHAR2 := fnd_api.g_miss_char
    , p5_a48  VARCHAR2 := fnd_api.g_miss_char
    , p5_a49  VARCHAR2 := fnd_api.g_miss_char
    , p5_a50  VARCHAR2 := fnd_api.g_miss_char
    , p5_a51  VARCHAR2 := fnd_api.g_miss_char
    , p5_a52  VARCHAR2 := fnd_api.g_miss_char
    , p5_a53  VARCHAR2 := fnd_api.g_miss_char
    , p5_a54  NUMBER := 0-1962.0724
    , p5_a55  DATE := fnd_api.g_miss_date
    , p5_a56  NUMBER := 0-1962.0724
    , p5_a57  DATE := fnd_api.g_miss_date
    , p5_a58  NUMBER := 0-1962.0724
    , p5_a59  VARCHAR2 := fnd_api.g_miss_char
    , p5_a60  VARCHAR2 := fnd_api.g_miss_char
    , p5_a61  VARCHAR2 := fnd_api.g_miss_char
    , p5_a62  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_sypv_rec okl_system_params_all_pub.sypv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_sypv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_sypv_rec.delink_yn := p5_a1;
    ddp_sypv_rec.remk_subinventory := p5_a2;
    ddp_sypv_rec.remk_organization_id := rosetta_g_miss_num_map(p5_a3);
    ddp_sypv_rec.remk_price_list_id := rosetta_g_miss_num_map(p5_a4);
    ddp_sypv_rec.remk_process_code := p5_a5;
    ddp_sypv_rec.remk_item_template_id := rosetta_g_miss_num_map(p5_a6);
    ddp_sypv_rec.remk_item_invoiced_code := p5_a7;
    ddp_sypv_rec.lease_inv_org_yn := p5_a8;
    ddp_sypv_rec.tax_upfront_yn := p5_a9;
    ddp_sypv_rec.tax_invoice_yn := p5_a10;
    ddp_sypv_rec.tax_schedule_yn := p5_a11;
    ddp_sypv_rec.tax_upfront_sty_id := rosetta_g_miss_num_map(p5_a12);
    ddp_sypv_rec.category_set_id := rosetta_g_miss_num_map(p5_a13);
    ddp_sypv_rec.validation_set_id := rosetta_g_miss_num_map(p5_a14);
    ddp_sypv_rec.cancel_quotes_yn := p5_a15;
    ddp_sypv_rec.chk_accrual_previous_mnth_yn := p5_a16;
    ddp_sypv_rec.task_template_group_id := rosetta_g_miss_num_map(p5_a17);
    ddp_sypv_rec.owner_type_code := p5_a18;
    ddp_sypv_rec.owner_id := rosetta_g_miss_num_map(p5_a19);
    ddp_sypv_rec.item_inv_org_id := rosetta_g_miss_num_map(p5_a20);
    ddp_sypv_rec.rpt_prod_book_type_code := p5_a21;
    ddp_sypv_rec.asst_add_book_type_code := p5_a22;
    ddp_sypv_rec.ccard_remittance_id := rosetta_g_miss_num_map(p5_a23);
    ddp_sypv_rec.corporate_book := p5_a24;
    ddp_sypv_rec.tax_book_1 := p5_a25;
    ddp_sypv_rec.tax_book_2 := p5_a26;
    ddp_sypv_rec.depreciate_yn := p5_a27;
    ddp_sypv_rec.fa_location_id := rosetta_g_miss_num_map(p5_a28);
    ddp_sypv_rec.formula_id := rosetta_g_miss_num_map(p5_a29);
    ddp_sypv_rec.asset_key_id := rosetta_g_miss_num_map(p5_a30);
    ddp_sypv_rec.part_trmnt_apply_round_diff := p5_a31;
    ddp_sypv_rec.object_version_number := rosetta_g_miss_num_map(p5_a32);
    ddp_sypv_rec.org_id := rosetta_g_miss_num_map(p5_a33);
    ddp_sypv_rec.request_id := rosetta_g_miss_num_map(p5_a34);
    ddp_sypv_rec.program_application_id := rosetta_g_miss_num_map(p5_a35);
    ddp_sypv_rec.program_id := rosetta_g_miss_num_map(p5_a36);
    ddp_sypv_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a37);
    ddp_sypv_rec.attribute_category := p5_a38;
    ddp_sypv_rec.attribute1 := p5_a39;
    ddp_sypv_rec.attribute2 := p5_a40;
    ddp_sypv_rec.attribute3 := p5_a41;
    ddp_sypv_rec.attribute4 := p5_a42;
    ddp_sypv_rec.attribute5 := p5_a43;
    ddp_sypv_rec.attribute6 := p5_a44;
    ddp_sypv_rec.attribute7 := p5_a45;
    ddp_sypv_rec.attribute8 := p5_a46;
    ddp_sypv_rec.attribute9 := p5_a47;
    ddp_sypv_rec.attribute10 := p5_a48;
    ddp_sypv_rec.attribute11 := p5_a49;
    ddp_sypv_rec.attribute12 := p5_a50;
    ddp_sypv_rec.attribute13 := p5_a51;
    ddp_sypv_rec.attribute14 := p5_a52;
    ddp_sypv_rec.attribute15 := p5_a53;
    ddp_sypv_rec.created_by := rosetta_g_miss_num_map(p5_a54);
    ddp_sypv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a55);
    ddp_sypv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a56);
    ddp_sypv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a57);
    ddp_sypv_rec.last_update_login := rosetta_g_miss_num_map(p5_a58);
    ddp_sypv_rec.lseapp_seq_prefix_txt := p5_a59;
    ddp_sypv_rec.lseopp_seq_prefix_txt := p5_a60;
    ddp_sypv_rec.qckqte_seq_prefix_txt := p5_a61;
    ddp_sypv_rec.lseqte_seq_prefix_txt := p5_a62;

    -- here's the delegated call to the old PL/SQL routine
    okl_system_params_all_pub.delete_system_parameters(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_sypv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure delete_system_parameters(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_VARCHAR2_TABLE_100
    , p5_a2 JTF_VARCHAR2_TABLE_100
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_VARCHAR2_TABLE_100
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_VARCHAR2_TABLE_100
    , p5_a8 JTF_VARCHAR2_TABLE_100
    , p5_a9 JTF_VARCHAR2_TABLE_100
    , p5_a10 JTF_VARCHAR2_TABLE_100
    , p5_a11 JTF_VARCHAR2_TABLE_100
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_NUMBER_TABLE
    , p5_a14 JTF_NUMBER_TABLE
    , p5_a15 JTF_VARCHAR2_TABLE_100
    , p5_a16 JTF_VARCHAR2_TABLE_100
    , p5_a17 JTF_NUMBER_TABLE
    , p5_a18 JTF_VARCHAR2_TABLE_100
    , p5_a19 JTF_NUMBER_TABLE
    , p5_a20 JTF_NUMBER_TABLE
    , p5_a21 JTF_VARCHAR2_TABLE_100
    , p5_a22 JTF_VARCHAR2_TABLE_100
    , p5_a23 JTF_NUMBER_TABLE
    , p5_a24 JTF_VARCHAR2_TABLE_100
    , p5_a25 JTF_VARCHAR2_TABLE_100
    , p5_a26 JTF_VARCHAR2_TABLE_100
    , p5_a27 JTF_VARCHAR2_TABLE_100
    , p5_a28 JTF_NUMBER_TABLE
    , p5_a29 JTF_NUMBER_TABLE
    , p5_a30 JTF_NUMBER_TABLE
    , p5_a31 JTF_VARCHAR2_TABLE_100
    , p5_a32 JTF_NUMBER_TABLE
    , p5_a33 JTF_NUMBER_TABLE
    , p5_a34 JTF_NUMBER_TABLE
    , p5_a35 JTF_NUMBER_TABLE
    , p5_a36 JTF_NUMBER_TABLE
    , p5_a37 JTF_DATE_TABLE
    , p5_a38 JTF_VARCHAR2_TABLE_100
    , p5_a39 JTF_VARCHAR2_TABLE_500
    , p5_a40 JTF_VARCHAR2_TABLE_500
    , p5_a41 JTF_VARCHAR2_TABLE_500
    , p5_a42 JTF_VARCHAR2_TABLE_500
    , p5_a43 JTF_VARCHAR2_TABLE_500
    , p5_a44 JTF_VARCHAR2_TABLE_500
    , p5_a45 JTF_VARCHAR2_TABLE_500
    , p5_a46 JTF_VARCHAR2_TABLE_500
    , p5_a47 JTF_VARCHAR2_TABLE_500
    , p5_a48 JTF_VARCHAR2_TABLE_500
    , p5_a49 JTF_VARCHAR2_TABLE_500
    , p5_a50 JTF_VARCHAR2_TABLE_500
    , p5_a51 JTF_VARCHAR2_TABLE_500
    , p5_a52 JTF_VARCHAR2_TABLE_500
    , p5_a53 JTF_VARCHAR2_TABLE_500
    , p5_a54 JTF_NUMBER_TABLE
    , p5_a55 JTF_DATE_TABLE
    , p5_a56 JTF_NUMBER_TABLE
    , p5_a57 JTF_DATE_TABLE
    , p5_a58 JTF_NUMBER_TABLE
    , p5_a59 JTF_VARCHAR2_TABLE_200
    , p5_a60 JTF_VARCHAR2_TABLE_200
    , p5_a61 JTF_VARCHAR2_TABLE_200
    , p5_a62 JTF_VARCHAR2_TABLE_200
  )

  as
    ddp_sypv_tbl okl_system_params_all_pub.sypv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_syp_pvt_w.rosetta_table_copy_in_p2(ddp_sypv_tbl, p5_a0
      , p5_a1
      , p5_a2
      , p5_a3
      , p5_a4
      , p5_a5
      , p5_a6
      , p5_a7
      , p5_a8
      , p5_a9
      , p5_a10
      , p5_a11
      , p5_a12
      , p5_a13
      , p5_a14
      , p5_a15
      , p5_a16
      , p5_a17
      , p5_a18
      , p5_a19
      , p5_a20
      , p5_a21
      , p5_a22
      , p5_a23
      , p5_a24
      , p5_a25
      , p5_a26
      , p5_a27
      , p5_a28
      , p5_a29
      , p5_a30
      , p5_a31
      , p5_a32
      , p5_a33
      , p5_a34
      , p5_a35
      , p5_a36
      , p5_a37
      , p5_a38
      , p5_a39
      , p5_a40
      , p5_a41
      , p5_a42
      , p5_a43
      , p5_a44
      , p5_a45
      , p5_a46
      , p5_a47
      , p5_a48
      , p5_a49
      , p5_a50
      , p5_a51
      , p5_a52
      , p5_a53
      , p5_a54
      , p5_a55
      , p5_a56
      , p5_a57
      , p5_a58
      , p5_a59
      , p5_a60
      , p5_a61
      , p5_a62
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_system_params_all_pub.delete_system_parameters(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_sypv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure validate_system_parameters(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  VARCHAR2 := fnd_api.g_miss_char
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  VARCHAR2 := fnd_api.g_miss_char
    , p5_a10  VARCHAR2 := fnd_api.g_miss_char
    , p5_a11  VARCHAR2 := fnd_api.g_miss_char
    , p5_a12  NUMBER := 0-1962.0724
    , p5_a13  NUMBER := 0-1962.0724
    , p5_a14  NUMBER := 0-1962.0724
    , p5_a15  VARCHAR2 := fnd_api.g_miss_char
    , p5_a16  VARCHAR2 := fnd_api.g_miss_char
    , p5_a17  NUMBER := 0-1962.0724
    , p5_a18  VARCHAR2 := fnd_api.g_miss_char
    , p5_a19  NUMBER := 0-1962.0724
    , p5_a20  NUMBER := 0-1962.0724
    , p5_a21  VARCHAR2 := fnd_api.g_miss_char
    , p5_a22  VARCHAR2 := fnd_api.g_miss_char
    , p5_a23  NUMBER := 0-1962.0724
    , p5_a24  VARCHAR2 := fnd_api.g_miss_char
    , p5_a25  VARCHAR2 := fnd_api.g_miss_char
    , p5_a26  VARCHAR2 := fnd_api.g_miss_char
    , p5_a27  VARCHAR2 := fnd_api.g_miss_char
    , p5_a28  NUMBER := 0-1962.0724
    , p5_a29  NUMBER := 0-1962.0724
    , p5_a30  NUMBER := 0-1962.0724
    , p5_a31  VARCHAR2 := fnd_api.g_miss_char
    , p5_a32  NUMBER := 0-1962.0724
    , p5_a33  NUMBER := 0-1962.0724
    , p5_a34  NUMBER := 0-1962.0724
    , p5_a35  NUMBER := 0-1962.0724
    , p5_a36  NUMBER := 0-1962.0724
    , p5_a37  DATE := fnd_api.g_miss_date
    , p5_a38  VARCHAR2 := fnd_api.g_miss_char
    , p5_a39  VARCHAR2 := fnd_api.g_miss_char
    , p5_a40  VARCHAR2 := fnd_api.g_miss_char
    , p5_a41  VARCHAR2 := fnd_api.g_miss_char
    , p5_a42  VARCHAR2 := fnd_api.g_miss_char
    , p5_a43  VARCHAR2 := fnd_api.g_miss_char
    , p5_a44  VARCHAR2 := fnd_api.g_miss_char
    , p5_a45  VARCHAR2 := fnd_api.g_miss_char
    , p5_a46  VARCHAR2 := fnd_api.g_miss_char
    , p5_a47  VARCHAR2 := fnd_api.g_miss_char
    , p5_a48  VARCHAR2 := fnd_api.g_miss_char
    , p5_a49  VARCHAR2 := fnd_api.g_miss_char
    , p5_a50  VARCHAR2 := fnd_api.g_miss_char
    , p5_a51  VARCHAR2 := fnd_api.g_miss_char
    , p5_a52  VARCHAR2 := fnd_api.g_miss_char
    , p5_a53  VARCHAR2 := fnd_api.g_miss_char
    , p5_a54  NUMBER := 0-1962.0724
    , p5_a55  DATE := fnd_api.g_miss_date
    , p5_a56  NUMBER := 0-1962.0724
    , p5_a57  DATE := fnd_api.g_miss_date
    , p5_a58  NUMBER := 0-1962.0724
    , p5_a59  VARCHAR2 := fnd_api.g_miss_char
    , p5_a60  VARCHAR2 := fnd_api.g_miss_char
    , p5_a61  VARCHAR2 := fnd_api.g_miss_char
    , p5_a62  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_sypv_rec okl_system_params_all_pub.sypv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_sypv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_sypv_rec.delink_yn := p5_a1;
    ddp_sypv_rec.remk_subinventory := p5_a2;
    ddp_sypv_rec.remk_organization_id := rosetta_g_miss_num_map(p5_a3);
    ddp_sypv_rec.remk_price_list_id := rosetta_g_miss_num_map(p5_a4);
    ddp_sypv_rec.remk_process_code := p5_a5;
    ddp_sypv_rec.remk_item_template_id := rosetta_g_miss_num_map(p5_a6);
    ddp_sypv_rec.remk_item_invoiced_code := p5_a7;
    ddp_sypv_rec.lease_inv_org_yn := p5_a8;
    ddp_sypv_rec.tax_upfront_yn := p5_a9;
    ddp_sypv_rec.tax_invoice_yn := p5_a10;
    ddp_sypv_rec.tax_schedule_yn := p5_a11;
    ddp_sypv_rec.tax_upfront_sty_id := rosetta_g_miss_num_map(p5_a12);
    ddp_sypv_rec.category_set_id := rosetta_g_miss_num_map(p5_a13);
    ddp_sypv_rec.validation_set_id := rosetta_g_miss_num_map(p5_a14);
    ddp_sypv_rec.cancel_quotes_yn := p5_a15;
    ddp_sypv_rec.chk_accrual_previous_mnth_yn := p5_a16;
    ddp_sypv_rec.task_template_group_id := rosetta_g_miss_num_map(p5_a17);
    ddp_sypv_rec.owner_type_code := p5_a18;
    ddp_sypv_rec.owner_id := rosetta_g_miss_num_map(p5_a19);
    ddp_sypv_rec.item_inv_org_id := rosetta_g_miss_num_map(p5_a20);
    ddp_sypv_rec.rpt_prod_book_type_code := p5_a21;
    ddp_sypv_rec.asst_add_book_type_code := p5_a22;
    ddp_sypv_rec.ccard_remittance_id := rosetta_g_miss_num_map(p5_a23);
    ddp_sypv_rec.corporate_book := p5_a24;
    ddp_sypv_rec.tax_book_1 := p5_a25;
    ddp_sypv_rec.tax_book_2 := p5_a26;
    ddp_sypv_rec.depreciate_yn := p5_a27;
    ddp_sypv_rec.fa_location_id := rosetta_g_miss_num_map(p5_a28);
    ddp_sypv_rec.formula_id := rosetta_g_miss_num_map(p5_a29);
    ddp_sypv_rec.asset_key_id := rosetta_g_miss_num_map(p5_a30);
    ddp_sypv_rec.part_trmnt_apply_round_diff := p5_a31;
    ddp_sypv_rec.object_version_number := rosetta_g_miss_num_map(p5_a32);
    ddp_sypv_rec.org_id := rosetta_g_miss_num_map(p5_a33);
    ddp_sypv_rec.request_id := rosetta_g_miss_num_map(p5_a34);
    ddp_sypv_rec.program_application_id := rosetta_g_miss_num_map(p5_a35);
    ddp_sypv_rec.program_id := rosetta_g_miss_num_map(p5_a36);
    ddp_sypv_rec.program_update_date := rosetta_g_miss_date_in_map(p5_a37);
    ddp_sypv_rec.attribute_category := p5_a38;
    ddp_sypv_rec.attribute1 := p5_a39;
    ddp_sypv_rec.attribute2 := p5_a40;
    ddp_sypv_rec.attribute3 := p5_a41;
    ddp_sypv_rec.attribute4 := p5_a42;
    ddp_sypv_rec.attribute5 := p5_a43;
    ddp_sypv_rec.attribute6 := p5_a44;
    ddp_sypv_rec.attribute7 := p5_a45;
    ddp_sypv_rec.attribute8 := p5_a46;
    ddp_sypv_rec.attribute9 := p5_a47;
    ddp_sypv_rec.attribute10 := p5_a48;
    ddp_sypv_rec.attribute11 := p5_a49;
    ddp_sypv_rec.attribute12 := p5_a50;
    ddp_sypv_rec.attribute13 := p5_a51;
    ddp_sypv_rec.attribute14 := p5_a52;
    ddp_sypv_rec.attribute15 := p5_a53;
    ddp_sypv_rec.created_by := rosetta_g_miss_num_map(p5_a54);
    ddp_sypv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a55);
    ddp_sypv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a56);
    ddp_sypv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a57);
    ddp_sypv_rec.last_update_login := rosetta_g_miss_num_map(p5_a58);
    ddp_sypv_rec.lseapp_seq_prefix_txt := p5_a59;
    ddp_sypv_rec.lseopp_seq_prefix_txt := p5_a60;
    ddp_sypv_rec.qckqte_seq_prefix_txt := p5_a61;
    ddp_sypv_rec.lseqte_seq_prefix_txt := p5_a62;

    -- here's the delegated call to the old PL/SQL routine
    okl_system_params_all_pub.validate_system_parameters(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_sypv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure validate_system_parameters(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_VARCHAR2_TABLE_100
    , p5_a2 JTF_VARCHAR2_TABLE_100
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_VARCHAR2_TABLE_100
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_VARCHAR2_TABLE_100
    , p5_a8 JTF_VARCHAR2_TABLE_100
    , p5_a9 JTF_VARCHAR2_TABLE_100
    , p5_a10 JTF_VARCHAR2_TABLE_100
    , p5_a11 JTF_VARCHAR2_TABLE_100
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_NUMBER_TABLE
    , p5_a14 JTF_NUMBER_TABLE
    , p5_a15 JTF_VARCHAR2_TABLE_100
    , p5_a16 JTF_VARCHAR2_TABLE_100
    , p5_a17 JTF_NUMBER_TABLE
    , p5_a18 JTF_VARCHAR2_TABLE_100
    , p5_a19 JTF_NUMBER_TABLE
    , p5_a20 JTF_NUMBER_TABLE
    , p5_a21 JTF_VARCHAR2_TABLE_100
    , p5_a22 JTF_VARCHAR2_TABLE_100
    , p5_a23 JTF_NUMBER_TABLE
    , p5_a24 JTF_VARCHAR2_TABLE_100
    , p5_a25 JTF_VARCHAR2_TABLE_100
    , p5_a26 JTF_VARCHAR2_TABLE_100
    , p5_a27 JTF_VARCHAR2_TABLE_100
    , p5_a28 JTF_NUMBER_TABLE
    , p5_a29 JTF_NUMBER_TABLE
    , p5_a30 JTF_NUMBER_TABLE
    , p5_a31 JTF_VARCHAR2_TABLE_100
    , p5_a32 JTF_NUMBER_TABLE
    , p5_a33 JTF_NUMBER_TABLE
    , p5_a34 JTF_NUMBER_TABLE
    , p5_a35 JTF_NUMBER_TABLE
    , p5_a36 JTF_NUMBER_TABLE
    , p5_a37 JTF_DATE_TABLE
    , p5_a38 JTF_VARCHAR2_TABLE_100
    , p5_a39 JTF_VARCHAR2_TABLE_500
    , p5_a40 JTF_VARCHAR2_TABLE_500
    , p5_a41 JTF_VARCHAR2_TABLE_500
    , p5_a42 JTF_VARCHAR2_TABLE_500
    , p5_a43 JTF_VARCHAR2_TABLE_500
    , p5_a44 JTF_VARCHAR2_TABLE_500
    , p5_a45 JTF_VARCHAR2_TABLE_500
    , p5_a46 JTF_VARCHAR2_TABLE_500
    , p5_a47 JTF_VARCHAR2_TABLE_500
    , p5_a48 JTF_VARCHAR2_TABLE_500
    , p5_a49 JTF_VARCHAR2_TABLE_500
    , p5_a50 JTF_VARCHAR2_TABLE_500
    , p5_a51 JTF_VARCHAR2_TABLE_500
    , p5_a52 JTF_VARCHAR2_TABLE_500
    , p5_a53 JTF_VARCHAR2_TABLE_500
    , p5_a54 JTF_NUMBER_TABLE
    , p5_a55 JTF_DATE_TABLE
    , p5_a56 JTF_NUMBER_TABLE
    , p5_a57 JTF_DATE_TABLE
    , p5_a58 JTF_NUMBER_TABLE
    , p5_a59 JTF_VARCHAR2_TABLE_200
    , p5_a60 JTF_VARCHAR2_TABLE_200
    , p5_a61 JTF_VARCHAR2_TABLE_200
    , p5_a62 JTF_VARCHAR2_TABLE_200
  )

  as
    ddp_sypv_tbl okl_system_params_all_pub.sypv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_syp_pvt_w.rosetta_table_copy_in_p2(ddp_sypv_tbl, p5_a0
      , p5_a1
      , p5_a2
      , p5_a3
      , p5_a4
      , p5_a5
      , p5_a6
      , p5_a7
      , p5_a8
      , p5_a9
      , p5_a10
      , p5_a11
      , p5_a12
      , p5_a13
      , p5_a14
      , p5_a15
      , p5_a16
      , p5_a17
      , p5_a18
      , p5_a19
      , p5_a20
      , p5_a21
      , p5_a22
      , p5_a23
      , p5_a24
      , p5_a25
      , p5_a26
      , p5_a27
      , p5_a28
      , p5_a29
      , p5_a30
      , p5_a31
      , p5_a32
      , p5_a33
      , p5_a34
      , p5_a35
      , p5_a36
      , p5_a37
      , p5_a38
      , p5_a39
      , p5_a40
      , p5_a41
      , p5_a42
      , p5_a43
      , p5_a44
      , p5_a45
      , p5_a46
      , p5_a47
      , p5_a48
      , p5_a49
      , p5_a50
      , p5_a51
      , p5_a52
      , p5_a53
      , p5_a54
      , p5_a55
      , p5_a56
      , p5_a57
      , p5_a58
      , p5_a59
      , p5_a60
      , p5_a61
      , p5_a62
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_system_params_all_pub.validate_system_parameters(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_sypv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

end okl_system_params_all_pub_w;

/
