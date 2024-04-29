--------------------------------------------------------
--  DDL for Package Body OKL_SEC_AGREEMENT_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_SEC_AGREEMENT_PVT_W" as
  /* $Header: OKLESZAB.pls 120.4 2008/01/07 11:08:13 sosharma noship $ */
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

  procedure rosetta_table_copy_in_p11(t out nocopy okl_sec_agreement_pvt.secagreement_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_200
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_VARCHAR2_TABLE_600
    , a5 JTF_DATE_TABLE
    , a6 JTF_DATE_TABLE
    , a7 JTF_DATE_TABLE
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_VARCHAR2_TABLE_100
    , a10 JTF_VARCHAR2_TABLE_100
    , a11 JTF_VARCHAR2_TABLE_100
    , a12 JTF_VARCHAR2_TABLE_100
    , a13 JTF_VARCHAR2_TABLE_100
    , a14 JTF_NUMBER_TABLE
    , a15 JTF_DATE_TABLE
    , a16 JTF_NUMBER_TABLE
    , a17 JTF_VARCHAR2_TABLE_100
    , a18 JTF_VARCHAR2_TABLE_100
    , a19 JTF_VARCHAR2_TABLE_100
    , a20 JTF_NUMBER_TABLE
    , a21 JTF_VARCHAR2_TABLE_100
    , a22 JTF_VARCHAR2_TABLE_500
    , a23 JTF_VARCHAR2_TABLE_500
    , a24 JTF_VARCHAR2_TABLE_500
    , a25 JTF_VARCHAR2_TABLE_500
    , a26 JTF_VARCHAR2_TABLE_500
    , a27 JTF_VARCHAR2_TABLE_500
    , a28 JTF_VARCHAR2_TABLE_500
    , a29 JTF_VARCHAR2_TABLE_500
    , a30 JTF_VARCHAR2_TABLE_500
    , a31 JTF_VARCHAR2_TABLE_500
    , a32 JTF_VARCHAR2_TABLE_500
    , a33 JTF_VARCHAR2_TABLE_500
    , a34 JTF_VARCHAR2_TABLE_500
    , a35 JTF_VARCHAR2_TABLE_500
    , a36 JTF_VARCHAR2_TABLE_500
    , a37 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).contract_number := a1(indx);
          t(ddindx).pdt_id := rosetta_g_miss_num_map(a2(indx));
          t(ddindx).pol_id := rosetta_g_miss_num_map(a3(indx));
          t(ddindx).short_description := a4(indx);
          t(ddindx).start_date := rosetta_g_miss_date_in_map(a5(indx));
          t(ddindx).end_date := rosetta_g_miss_date_in_map(a6(indx));
          t(ddindx).date_approved := rosetta_g_miss_date_in_map(a7(indx));
          t(ddindx).securitization_type := a8(indx);
          t(ddindx).lessor_serv_org_code := a9(indx);
          t(ddindx).recourse_code := a10(indx);
          t(ddindx).sts_code := a11(indx);
          t(ddindx).currency_code := a12(indx);
          t(ddindx).currency_conversion_type := a13(indx);
          t(ddindx).currency_conversion_rate := rosetta_g_miss_num_map(a14(indx));
          t(ddindx).currency_conversion_date := rosetta_g_miss_date_in_map(a15(indx));
          t(ddindx).trustee_party_roles_id := rosetta_g_miss_num_map(a16(indx));
          t(ddindx).trustee_object1_id1 := a17(indx);
          t(ddindx).trustee_object1_id2 := a18(indx);
          t(ddindx).trustee_jtot_object1_code := a19(indx);
          t(ddindx).after_tax_yield := rosetta_g_miss_num_map(a20(indx));
          t(ddindx).attribute_category := a21(indx);
          t(ddindx).attribute1 := a22(indx);
          t(ddindx).attribute2 := a23(indx);
          t(ddindx).attribute3 := a24(indx);
          t(ddindx).attribute4 := a25(indx);
          t(ddindx).attribute5 := a26(indx);
          t(ddindx).attribute6 := a27(indx);
          t(ddindx).attribute7 := a28(indx);
          t(ddindx).attribute8 := a29(indx);
          t(ddindx).attribute9 := a30(indx);
          t(ddindx).attribute10 := a31(indx);
          t(ddindx).attribute11 := a32(indx);
          t(ddindx).attribute12 := a33(indx);
          t(ddindx).attribute13 := a34(indx);
          t(ddindx).attribute14 := a35(indx);
          t(ddindx).attribute15 := a36(indx);
          t(ddindx).legal_entity_id := rosetta_g_miss_num_map(a37(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p11;
  procedure rosetta_table_copy_out_p11(t okl_sec_agreement_pvt.secagreement_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_200
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_VARCHAR2_TABLE_600
    , a5 out nocopy JTF_DATE_TABLE
    , a6 out nocopy JTF_DATE_TABLE
    , a7 out nocopy JTF_DATE_TABLE
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    , a9 out nocopy JTF_VARCHAR2_TABLE_100
    , a10 out nocopy JTF_VARCHAR2_TABLE_100
    , a11 out nocopy JTF_VARCHAR2_TABLE_100
    , a12 out nocopy JTF_VARCHAR2_TABLE_100
    , a13 out nocopy JTF_VARCHAR2_TABLE_100
    , a14 out nocopy JTF_NUMBER_TABLE
    , a15 out nocopy JTF_DATE_TABLE
    , a16 out nocopy JTF_NUMBER_TABLE
    , a17 out nocopy JTF_VARCHAR2_TABLE_100
    , a18 out nocopy JTF_VARCHAR2_TABLE_100
    , a19 out nocopy JTF_VARCHAR2_TABLE_100
    , a20 out nocopy JTF_NUMBER_TABLE
    , a21 out nocopy JTF_VARCHAR2_TABLE_100
    , a22 out nocopy JTF_VARCHAR2_TABLE_500
    , a23 out nocopy JTF_VARCHAR2_TABLE_500
    , a24 out nocopy JTF_VARCHAR2_TABLE_500
    , a25 out nocopy JTF_VARCHAR2_TABLE_500
    , a26 out nocopy JTF_VARCHAR2_TABLE_500
    , a27 out nocopy JTF_VARCHAR2_TABLE_500
    , a28 out nocopy JTF_VARCHAR2_TABLE_500
    , a29 out nocopy JTF_VARCHAR2_TABLE_500
    , a30 out nocopy JTF_VARCHAR2_TABLE_500
    , a31 out nocopy JTF_VARCHAR2_TABLE_500
    , a32 out nocopy JTF_VARCHAR2_TABLE_500
    , a33 out nocopy JTF_VARCHAR2_TABLE_500
    , a34 out nocopy JTF_VARCHAR2_TABLE_500
    , a35 out nocopy JTF_VARCHAR2_TABLE_500
    , a36 out nocopy JTF_VARCHAR2_TABLE_500
    , a37 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_200();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_VARCHAR2_TABLE_600();
    a5 := JTF_DATE_TABLE();
    a6 := JTF_DATE_TABLE();
    a7 := JTF_DATE_TABLE();
    a8 := JTF_VARCHAR2_TABLE_100();
    a9 := JTF_VARCHAR2_TABLE_100();
    a10 := JTF_VARCHAR2_TABLE_100();
    a11 := JTF_VARCHAR2_TABLE_100();
    a12 := JTF_VARCHAR2_TABLE_100();
    a13 := JTF_VARCHAR2_TABLE_100();
    a14 := JTF_NUMBER_TABLE();
    a15 := JTF_DATE_TABLE();
    a16 := JTF_NUMBER_TABLE();
    a17 := JTF_VARCHAR2_TABLE_100();
    a18 := JTF_VARCHAR2_TABLE_100();
    a19 := JTF_VARCHAR2_TABLE_100();
    a20 := JTF_NUMBER_TABLE();
    a21 := JTF_VARCHAR2_TABLE_100();
    a22 := JTF_VARCHAR2_TABLE_500();
    a23 := JTF_VARCHAR2_TABLE_500();
    a24 := JTF_VARCHAR2_TABLE_500();
    a25 := JTF_VARCHAR2_TABLE_500();
    a26 := JTF_VARCHAR2_TABLE_500();
    a27 := JTF_VARCHAR2_TABLE_500();
    a28 := JTF_VARCHAR2_TABLE_500();
    a29 := JTF_VARCHAR2_TABLE_500();
    a30 := JTF_VARCHAR2_TABLE_500();
    a31 := JTF_VARCHAR2_TABLE_500();
    a32 := JTF_VARCHAR2_TABLE_500();
    a33 := JTF_VARCHAR2_TABLE_500();
    a34 := JTF_VARCHAR2_TABLE_500();
    a35 := JTF_VARCHAR2_TABLE_500();
    a36 := JTF_VARCHAR2_TABLE_500();
    a37 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_200();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_VARCHAR2_TABLE_600();
      a5 := JTF_DATE_TABLE();
      a6 := JTF_DATE_TABLE();
      a7 := JTF_DATE_TABLE();
      a8 := JTF_VARCHAR2_TABLE_100();
      a9 := JTF_VARCHAR2_TABLE_100();
      a10 := JTF_VARCHAR2_TABLE_100();
      a11 := JTF_VARCHAR2_TABLE_100();
      a12 := JTF_VARCHAR2_TABLE_100();
      a13 := JTF_VARCHAR2_TABLE_100();
      a14 := JTF_NUMBER_TABLE();
      a15 := JTF_DATE_TABLE();
      a16 := JTF_NUMBER_TABLE();
      a17 := JTF_VARCHAR2_TABLE_100();
      a18 := JTF_VARCHAR2_TABLE_100();
      a19 := JTF_VARCHAR2_TABLE_100();
      a20 := JTF_NUMBER_TABLE();
      a21 := JTF_VARCHAR2_TABLE_100();
      a22 := JTF_VARCHAR2_TABLE_500();
      a23 := JTF_VARCHAR2_TABLE_500();
      a24 := JTF_VARCHAR2_TABLE_500();
      a25 := JTF_VARCHAR2_TABLE_500();
      a26 := JTF_VARCHAR2_TABLE_500();
      a27 := JTF_VARCHAR2_TABLE_500();
      a28 := JTF_VARCHAR2_TABLE_500();
      a29 := JTF_VARCHAR2_TABLE_500();
      a30 := JTF_VARCHAR2_TABLE_500();
      a31 := JTF_VARCHAR2_TABLE_500();
      a32 := JTF_VARCHAR2_TABLE_500();
      a33 := JTF_VARCHAR2_TABLE_500();
      a34 := JTF_VARCHAR2_TABLE_500();
      a35 := JTF_VARCHAR2_TABLE_500();
      a36 := JTF_VARCHAR2_TABLE_500();
      a37 := JTF_NUMBER_TABLE();
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
        a19.extend(t.count);
        a20.extend(t.count);
        a21.extend(t.count);
        a22.extend(t.count);
        a23.extend(t.count);
        a24.extend(t.count);
        a25.extend(t.count);
        a26.extend(t.count);
        a27.extend(t.count);
        a28.extend(t.count);
        a29.extend(t.count);
        a30.extend(t.count);
        a31.extend(t.count);
        a32.extend(t.count);
        a33.extend(t.count);
        a34.extend(t.count);
        a35.extend(t.count);
        a36.extend(t.count);
        a37.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).id);
          a1(indx) := t(ddindx).contract_number;
          a2(indx) := rosetta_g_miss_num_map(t(ddindx).pdt_id);
          a3(indx) := rosetta_g_miss_num_map(t(ddindx).pol_id);
          a4(indx) := t(ddindx).short_description;
          a5(indx) := t(ddindx).start_date;
          a6(indx) := t(ddindx).end_date;
          a7(indx) := t(ddindx).date_approved;
          a8(indx) := t(ddindx).securitization_type;
          a9(indx) := t(ddindx).lessor_serv_org_code;
          a10(indx) := t(ddindx).recourse_code;
          a11(indx) := t(ddindx).sts_code;
          a12(indx) := t(ddindx).currency_code;
          a13(indx) := t(ddindx).currency_conversion_type;
          a14(indx) := rosetta_g_miss_num_map(t(ddindx).currency_conversion_rate);
          a15(indx) := t(ddindx).currency_conversion_date;
          a16(indx) := rosetta_g_miss_num_map(t(ddindx).trustee_party_roles_id);
          a17(indx) := t(ddindx).trustee_object1_id1;
          a18(indx) := t(ddindx).trustee_object1_id2;
          a19(indx) := t(ddindx).trustee_jtot_object1_code;
          a20(indx) := rosetta_g_miss_num_map(t(ddindx).after_tax_yield);
          a21(indx) := t(ddindx).attribute_category;
          a22(indx) := t(ddindx).attribute1;
          a23(indx) := t(ddindx).attribute2;
          a24(indx) := t(ddindx).attribute3;
          a25(indx) := t(ddindx).attribute4;
          a26(indx) := t(ddindx).attribute5;
          a27(indx) := t(ddindx).attribute6;
          a28(indx) := t(ddindx).attribute7;
          a29(indx) := t(ddindx).attribute8;
          a30(indx) := t(ddindx).attribute9;
          a31(indx) := t(ddindx).attribute10;
          a32(indx) := t(ddindx).attribute11;
          a33(indx) := t(ddindx).attribute12;
          a34(indx) := t(ddindx).attribute13;
          a35(indx) := t(ddindx).attribute14;
          a36(indx) := t(ddindx).attribute15;
          a37(indx) := rosetta_g_miss_num_map(t(ddindx).legal_entity_id);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p11;

  procedure create_sec_agreement(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  VARCHAR2
    , p6_a2 out nocopy  NUMBER
    , p6_a3 out nocopy  NUMBER
    , p6_a4 out nocopy  VARCHAR2
    , p6_a5 out nocopy  DATE
    , p6_a6 out nocopy  DATE
    , p6_a7 out nocopy  DATE
    , p6_a8 out nocopy  VARCHAR2
    , p6_a9 out nocopy  VARCHAR2
    , p6_a10 out nocopy  VARCHAR2
    , p6_a11 out nocopy  VARCHAR2
    , p6_a12 out nocopy  VARCHAR2
    , p6_a13 out nocopy  VARCHAR2
    , p6_a14 out nocopy  NUMBER
    , p6_a15 out nocopy  DATE
    , p6_a16 out nocopy  NUMBER
    , p6_a17 out nocopy  VARCHAR2
    , p6_a18 out nocopy  VARCHAR2
    , p6_a19 out nocopy  VARCHAR2
    , p6_a20 out nocopy  NUMBER
    , p6_a21 out nocopy  VARCHAR2
    , p6_a22 out nocopy  VARCHAR2
    , p6_a23 out nocopy  VARCHAR2
    , p6_a24 out nocopy  VARCHAR2
    , p6_a25 out nocopy  VARCHAR2
    , p6_a26 out nocopy  VARCHAR2
    , p6_a27 out nocopy  VARCHAR2
    , p6_a28 out nocopy  VARCHAR2
    , p6_a29 out nocopy  VARCHAR2
    , p6_a30 out nocopy  VARCHAR2
    , p6_a31 out nocopy  VARCHAR2
    , p6_a32 out nocopy  VARCHAR2
    , p6_a33 out nocopy  VARCHAR2
    , p6_a34 out nocopy  VARCHAR2
    , p6_a35 out nocopy  VARCHAR2
    , p6_a36 out nocopy  VARCHAR2
    , p6_a37 out nocopy  NUMBER
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  VARCHAR2 := fnd_api.g_miss_char
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  DATE := fnd_api.g_miss_date
    , p5_a6  DATE := fnd_api.g_miss_date
    , p5_a7  DATE := fnd_api.g_miss_date
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  VARCHAR2 := fnd_api.g_miss_char
    , p5_a10  VARCHAR2 := fnd_api.g_miss_char
    , p5_a11  VARCHAR2 := fnd_api.g_miss_char
    , p5_a12  VARCHAR2 := fnd_api.g_miss_char
    , p5_a13  VARCHAR2 := fnd_api.g_miss_char
    , p5_a14  NUMBER := 0-1962.0724
    , p5_a15  DATE := fnd_api.g_miss_date
    , p5_a16  NUMBER := 0-1962.0724
    , p5_a17  VARCHAR2 := fnd_api.g_miss_char
    , p5_a18  VARCHAR2 := fnd_api.g_miss_char
    , p5_a19  VARCHAR2 := fnd_api.g_miss_char
    , p5_a20  NUMBER := 0-1962.0724
    , p5_a21  VARCHAR2 := fnd_api.g_miss_char
    , p5_a22  VARCHAR2 := fnd_api.g_miss_char
    , p5_a23  VARCHAR2 := fnd_api.g_miss_char
    , p5_a24  VARCHAR2 := fnd_api.g_miss_char
    , p5_a25  VARCHAR2 := fnd_api.g_miss_char
    , p5_a26  VARCHAR2 := fnd_api.g_miss_char
    , p5_a27  VARCHAR2 := fnd_api.g_miss_char
    , p5_a28  VARCHAR2 := fnd_api.g_miss_char
    , p5_a29  VARCHAR2 := fnd_api.g_miss_char
    , p5_a30  VARCHAR2 := fnd_api.g_miss_char
    , p5_a31  VARCHAR2 := fnd_api.g_miss_char
    , p5_a32  VARCHAR2 := fnd_api.g_miss_char
    , p5_a33  VARCHAR2 := fnd_api.g_miss_char
    , p5_a34  VARCHAR2 := fnd_api.g_miss_char
    , p5_a35  VARCHAR2 := fnd_api.g_miss_char
    , p5_a36  VARCHAR2 := fnd_api.g_miss_char
    , p5_a37  NUMBER := 0-1962.0724
  )

  as
    ddp_secagreement_rec okl_sec_agreement_pvt.secagreement_rec_type;
    ddx_secagreement_rec okl_sec_agreement_pvt.secagreement_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_secagreement_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_secagreement_rec.contract_number := p5_a1;
    ddp_secagreement_rec.pdt_id := rosetta_g_miss_num_map(p5_a2);
    ddp_secagreement_rec.pol_id := rosetta_g_miss_num_map(p5_a3);
    ddp_secagreement_rec.short_description := p5_a4;
    ddp_secagreement_rec.start_date := rosetta_g_miss_date_in_map(p5_a5);
    ddp_secagreement_rec.end_date := rosetta_g_miss_date_in_map(p5_a6);
    ddp_secagreement_rec.date_approved := rosetta_g_miss_date_in_map(p5_a7);
    ddp_secagreement_rec.securitization_type := p5_a8;
    ddp_secagreement_rec.lessor_serv_org_code := p5_a9;
    ddp_secagreement_rec.recourse_code := p5_a10;
    ddp_secagreement_rec.sts_code := p5_a11;
    ddp_secagreement_rec.currency_code := p5_a12;
    ddp_secagreement_rec.currency_conversion_type := p5_a13;
    ddp_secagreement_rec.currency_conversion_rate := rosetta_g_miss_num_map(p5_a14);
    ddp_secagreement_rec.currency_conversion_date := rosetta_g_miss_date_in_map(p5_a15);
    ddp_secagreement_rec.trustee_party_roles_id := rosetta_g_miss_num_map(p5_a16);
    ddp_secagreement_rec.trustee_object1_id1 := p5_a17;
    ddp_secagreement_rec.trustee_object1_id2 := p5_a18;
    ddp_secagreement_rec.trustee_jtot_object1_code := p5_a19;
    ddp_secagreement_rec.after_tax_yield := rosetta_g_miss_num_map(p5_a20);
    ddp_secagreement_rec.attribute_category := p5_a21;
    ddp_secagreement_rec.attribute1 := p5_a22;
    ddp_secagreement_rec.attribute2 := p5_a23;
    ddp_secagreement_rec.attribute3 := p5_a24;
    ddp_secagreement_rec.attribute4 := p5_a25;
    ddp_secagreement_rec.attribute5 := p5_a26;
    ddp_secagreement_rec.attribute6 := p5_a27;
    ddp_secagreement_rec.attribute7 := p5_a28;
    ddp_secagreement_rec.attribute8 := p5_a29;
    ddp_secagreement_rec.attribute9 := p5_a30;
    ddp_secagreement_rec.attribute10 := p5_a31;
    ddp_secagreement_rec.attribute11 := p5_a32;
    ddp_secagreement_rec.attribute12 := p5_a33;
    ddp_secagreement_rec.attribute13 := p5_a34;
    ddp_secagreement_rec.attribute14 := p5_a35;
    ddp_secagreement_rec.attribute15 := p5_a36;
    ddp_secagreement_rec.legal_entity_id := rosetta_g_miss_num_map(p5_a37);


    -- here's the delegated call to the old PL/SQL routine
    okl_sec_agreement_pvt.create_sec_agreement(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_secagreement_rec,
      ddx_secagreement_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_secagreement_rec.id);
    p6_a1 := ddx_secagreement_rec.contract_number;
    p6_a2 := rosetta_g_miss_num_map(ddx_secagreement_rec.pdt_id);
    p6_a3 := rosetta_g_miss_num_map(ddx_secagreement_rec.pol_id);
    p6_a4 := ddx_secagreement_rec.short_description;
    p6_a5 := ddx_secagreement_rec.start_date;
    p6_a6 := ddx_secagreement_rec.end_date;
    p6_a7 := ddx_secagreement_rec.date_approved;
    p6_a8 := ddx_secagreement_rec.securitization_type;
    p6_a9 := ddx_secagreement_rec.lessor_serv_org_code;
    p6_a10 := ddx_secagreement_rec.recourse_code;
    p6_a11 := ddx_secagreement_rec.sts_code;
    p6_a12 := ddx_secagreement_rec.currency_code;
    p6_a13 := ddx_secagreement_rec.currency_conversion_type;
    p6_a14 := rosetta_g_miss_num_map(ddx_secagreement_rec.currency_conversion_rate);
    p6_a15 := ddx_secagreement_rec.currency_conversion_date;
    p6_a16 := rosetta_g_miss_num_map(ddx_secagreement_rec.trustee_party_roles_id);
    p6_a17 := ddx_secagreement_rec.trustee_object1_id1;
    p6_a18 := ddx_secagreement_rec.trustee_object1_id2;
    p6_a19 := ddx_secagreement_rec.trustee_jtot_object1_code;
    p6_a20 := rosetta_g_miss_num_map(ddx_secagreement_rec.after_tax_yield);
    p6_a21 := ddx_secagreement_rec.attribute_category;
    p6_a22 := ddx_secagreement_rec.attribute1;
    p6_a23 := ddx_secagreement_rec.attribute2;
    p6_a24 := ddx_secagreement_rec.attribute3;
    p6_a25 := ddx_secagreement_rec.attribute4;
    p6_a26 := ddx_secagreement_rec.attribute5;
    p6_a27 := ddx_secagreement_rec.attribute6;
    p6_a28 := ddx_secagreement_rec.attribute7;
    p6_a29 := ddx_secagreement_rec.attribute8;
    p6_a30 := ddx_secagreement_rec.attribute9;
    p6_a31 := ddx_secagreement_rec.attribute10;
    p6_a32 := ddx_secagreement_rec.attribute11;
    p6_a33 := ddx_secagreement_rec.attribute12;
    p6_a34 := ddx_secagreement_rec.attribute13;
    p6_a35 := ddx_secagreement_rec.attribute14;
    p6_a36 := ddx_secagreement_rec.attribute15;
    p6_a37 := rosetta_g_miss_num_map(ddx_secagreement_rec.legal_entity_id);
  end;

  procedure update_sec_agreement(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  VARCHAR2
    , p6_a2 out nocopy  NUMBER
    , p6_a3 out nocopy  NUMBER
    , p6_a4 out nocopy  VARCHAR2
    , p6_a5 out nocopy  DATE
    , p6_a6 out nocopy  DATE
    , p6_a7 out nocopy  DATE
    , p6_a8 out nocopy  VARCHAR2
    , p6_a9 out nocopy  VARCHAR2
    , p6_a10 out nocopy  VARCHAR2
    , p6_a11 out nocopy  VARCHAR2
    , p6_a12 out nocopy  VARCHAR2
    , p6_a13 out nocopy  VARCHAR2
    , p6_a14 out nocopy  NUMBER
    , p6_a15 out nocopy  DATE
    , p6_a16 out nocopy  NUMBER
    , p6_a17 out nocopy  VARCHAR2
    , p6_a18 out nocopy  VARCHAR2
    , p6_a19 out nocopy  VARCHAR2
    , p6_a20 out nocopy  NUMBER
    , p6_a21 out nocopy  VARCHAR2
    , p6_a22 out nocopy  VARCHAR2
    , p6_a23 out nocopy  VARCHAR2
    , p6_a24 out nocopy  VARCHAR2
    , p6_a25 out nocopy  VARCHAR2
    , p6_a26 out nocopy  VARCHAR2
    , p6_a27 out nocopy  VARCHAR2
    , p6_a28 out nocopy  VARCHAR2
    , p6_a29 out nocopy  VARCHAR2
    , p6_a30 out nocopy  VARCHAR2
    , p6_a31 out nocopy  VARCHAR2
    , p6_a32 out nocopy  VARCHAR2
    , p6_a33 out nocopy  VARCHAR2
    , p6_a34 out nocopy  VARCHAR2
    , p6_a35 out nocopy  VARCHAR2
    , p6_a36 out nocopy  VARCHAR2
    , p6_a37 out nocopy  NUMBER
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  VARCHAR2 := fnd_api.g_miss_char
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  DATE := fnd_api.g_miss_date
    , p5_a6  DATE := fnd_api.g_miss_date
    , p5_a7  DATE := fnd_api.g_miss_date
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  VARCHAR2 := fnd_api.g_miss_char
    , p5_a10  VARCHAR2 := fnd_api.g_miss_char
    , p5_a11  VARCHAR2 := fnd_api.g_miss_char
    , p5_a12  VARCHAR2 := fnd_api.g_miss_char
    , p5_a13  VARCHAR2 := fnd_api.g_miss_char
    , p5_a14  NUMBER := 0-1962.0724
    , p5_a15  DATE := fnd_api.g_miss_date
    , p5_a16  NUMBER := 0-1962.0724
    , p5_a17  VARCHAR2 := fnd_api.g_miss_char
    , p5_a18  VARCHAR2 := fnd_api.g_miss_char
    , p5_a19  VARCHAR2 := fnd_api.g_miss_char
    , p5_a20  NUMBER := 0-1962.0724
    , p5_a21  VARCHAR2 := fnd_api.g_miss_char
    , p5_a22  VARCHAR2 := fnd_api.g_miss_char
    , p5_a23  VARCHAR2 := fnd_api.g_miss_char
    , p5_a24  VARCHAR2 := fnd_api.g_miss_char
    , p5_a25  VARCHAR2 := fnd_api.g_miss_char
    , p5_a26  VARCHAR2 := fnd_api.g_miss_char
    , p5_a27  VARCHAR2 := fnd_api.g_miss_char
    , p5_a28  VARCHAR2 := fnd_api.g_miss_char
    , p5_a29  VARCHAR2 := fnd_api.g_miss_char
    , p5_a30  VARCHAR2 := fnd_api.g_miss_char
    , p5_a31  VARCHAR2 := fnd_api.g_miss_char
    , p5_a32  VARCHAR2 := fnd_api.g_miss_char
    , p5_a33  VARCHAR2 := fnd_api.g_miss_char
    , p5_a34  VARCHAR2 := fnd_api.g_miss_char
    , p5_a35  VARCHAR2 := fnd_api.g_miss_char
    , p5_a36  VARCHAR2 := fnd_api.g_miss_char
    , p5_a37  NUMBER := 0-1962.0724
  )

  as
    ddp_secagreement_rec okl_sec_agreement_pvt.secagreement_rec_type;
    ddx_secagreement_rec okl_sec_agreement_pvt.secagreement_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_secagreement_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_secagreement_rec.contract_number := p5_a1;
    ddp_secagreement_rec.pdt_id := rosetta_g_miss_num_map(p5_a2);
    ddp_secagreement_rec.pol_id := rosetta_g_miss_num_map(p5_a3);
    ddp_secagreement_rec.short_description := p5_a4;
    ddp_secagreement_rec.start_date := rosetta_g_miss_date_in_map(p5_a5);
    ddp_secagreement_rec.end_date := rosetta_g_miss_date_in_map(p5_a6);
    ddp_secagreement_rec.date_approved := rosetta_g_miss_date_in_map(p5_a7);
    ddp_secagreement_rec.securitization_type := p5_a8;
    ddp_secagreement_rec.lessor_serv_org_code := p5_a9;
    ddp_secagreement_rec.recourse_code := p5_a10;
    ddp_secagreement_rec.sts_code := p5_a11;
    ddp_secagreement_rec.currency_code := p5_a12;
    ddp_secagreement_rec.currency_conversion_type := p5_a13;
    ddp_secagreement_rec.currency_conversion_rate := rosetta_g_miss_num_map(p5_a14);
    ddp_secagreement_rec.currency_conversion_date := rosetta_g_miss_date_in_map(p5_a15);
    ddp_secagreement_rec.trustee_party_roles_id := rosetta_g_miss_num_map(p5_a16);
    ddp_secagreement_rec.trustee_object1_id1 := p5_a17;
    ddp_secagreement_rec.trustee_object1_id2 := p5_a18;
    ddp_secagreement_rec.trustee_jtot_object1_code := p5_a19;
    ddp_secagreement_rec.after_tax_yield := rosetta_g_miss_num_map(p5_a20);
    ddp_secagreement_rec.attribute_category := p5_a21;
    ddp_secagreement_rec.attribute1 := p5_a22;
    ddp_secagreement_rec.attribute2 := p5_a23;
    ddp_secagreement_rec.attribute3 := p5_a24;
    ddp_secagreement_rec.attribute4 := p5_a25;
    ddp_secagreement_rec.attribute5 := p5_a26;
    ddp_secagreement_rec.attribute6 := p5_a27;
    ddp_secagreement_rec.attribute7 := p5_a28;
    ddp_secagreement_rec.attribute8 := p5_a29;
    ddp_secagreement_rec.attribute9 := p5_a30;
    ddp_secagreement_rec.attribute10 := p5_a31;
    ddp_secagreement_rec.attribute11 := p5_a32;
    ddp_secagreement_rec.attribute12 := p5_a33;
    ddp_secagreement_rec.attribute13 := p5_a34;
    ddp_secagreement_rec.attribute14 := p5_a35;
    ddp_secagreement_rec.attribute15 := p5_a36;
    ddp_secagreement_rec.legal_entity_id := rosetta_g_miss_num_map(p5_a37);


    -- here's the delegated call to the old PL/SQL routine
    okl_sec_agreement_pvt.update_sec_agreement(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_secagreement_rec,
      ddx_secagreement_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_secagreement_rec.id);
    p6_a1 := ddx_secagreement_rec.contract_number;
    p6_a2 := rosetta_g_miss_num_map(ddx_secagreement_rec.pdt_id);
    p6_a3 := rosetta_g_miss_num_map(ddx_secagreement_rec.pol_id);
    p6_a4 := ddx_secagreement_rec.short_description;
    p6_a5 := ddx_secagreement_rec.start_date;
    p6_a6 := ddx_secagreement_rec.end_date;
    p6_a7 := ddx_secagreement_rec.date_approved;
    p6_a8 := ddx_secagreement_rec.securitization_type;
    p6_a9 := ddx_secagreement_rec.lessor_serv_org_code;
    p6_a10 := ddx_secagreement_rec.recourse_code;
    p6_a11 := ddx_secagreement_rec.sts_code;
    p6_a12 := ddx_secagreement_rec.currency_code;
    p6_a13 := ddx_secagreement_rec.currency_conversion_type;
    p6_a14 := rosetta_g_miss_num_map(ddx_secagreement_rec.currency_conversion_rate);
    p6_a15 := ddx_secagreement_rec.currency_conversion_date;
    p6_a16 := rosetta_g_miss_num_map(ddx_secagreement_rec.trustee_party_roles_id);
    p6_a17 := ddx_secagreement_rec.trustee_object1_id1;
    p6_a18 := ddx_secagreement_rec.trustee_object1_id2;
    p6_a19 := ddx_secagreement_rec.trustee_jtot_object1_code;
    p6_a20 := rosetta_g_miss_num_map(ddx_secagreement_rec.after_tax_yield);
    p6_a21 := ddx_secagreement_rec.attribute_category;
    p6_a22 := ddx_secagreement_rec.attribute1;
    p6_a23 := ddx_secagreement_rec.attribute2;
    p6_a24 := ddx_secagreement_rec.attribute3;
    p6_a25 := ddx_secagreement_rec.attribute4;
    p6_a26 := ddx_secagreement_rec.attribute5;
    p6_a27 := ddx_secagreement_rec.attribute6;
    p6_a28 := ddx_secagreement_rec.attribute7;
    p6_a29 := ddx_secagreement_rec.attribute8;
    p6_a30 := ddx_secagreement_rec.attribute9;
    p6_a31 := ddx_secagreement_rec.attribute10;
    p6_a32 := ddx_secagreement_rec.attribute11;
    p6_a33 := ddx_secagreement_rec.attribute12;
    p6_a34 := ddx_secagreement_rec.attribute13;
    p6_a35 := ddx_secagreement_rec.attribute14;
    p6_a36 := ddx_secagreement_rec.attribute15;
    p6_a37 := rosetta_g_miss_num_map(ddx_secagreement_rec.legal_entity_id);
  end;

end okl_sec_agreement_pvt_w;

/
