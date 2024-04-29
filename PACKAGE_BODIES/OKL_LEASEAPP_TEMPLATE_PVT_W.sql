--------------------------------------------------------
--  DDL for Package Body OKL_LEASEAPP_TEMPLATE_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_LEASEAPP_TEMPLATE_PVT_W" as
  /* $Header: OKLELATB.pls 120.0 2005/09/16 11:40:48 pagarg noship $ */
  procedure rosetta_table_copy_in_p3(t out nocopy okl_leaseapp_template_pvt.error_msgs_tbl_type, a0 JTF_VARCHAR2_TABLE_2500
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).error_message := a0(indx);
          t(ddindx).error_type_code := a1(indx);
          t(ddindx).error_type_meaning := a2(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p3;
  procedure rosetta_table_copy_out_p3(t okl_leaseapp_template_pvt.error_msgs_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_2500
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_2500();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_VARCHAR2_TABLE_2500();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_VARCHAR2_TABLE_100();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).error_message;
          a1(indx) := t(ddindx).error_type_code;
          a2(indx) := t(ddindx).error_type_meaning;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p3;

  procedure create_leaseapp_template(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER
    , p5_a1  NUMBER
    , p5_a2  VARCHAR2
    , p5_a3  VARCHAR2
    , p5_a4  VARCHAR2
    , p5_a5  VARCHAR2
    , p5_a6  VARCHAR2
    , p5_a7  VARCHAR2
    , p5_a8  VARCHAR2
    , p5_a9  VARCHAR2
    , p5_a10  VARCHAR2
    , p5_a11  VARCHAR2
    , p5_a12  VARCHAR2
    , p5_a13  VARCHAR2
    , p5_a14  VARCHAR2
    , p5_a15  VARCHAR2
    , p5_a16  VARCHAR2
    , p5_a17  VARCHAR2
    , p5_a18  NUMBER
    , p5_a19  VARCHAR2
    , p5_a20  VARCHAR2
    , p5_a21  VARCHAR2
    , p5_a22  VARCHAR2
    , p5_a23  VARCHAR2
    , p5_a24  VARCHAR2
    , p5_a25  DATE
    , p5_a26  DATE
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  VARCHAR2
    , p6_a3 out nocopy  VARCHAR2
    , p6_a4 out nocopy  VARCHAR2
    , p6_a5 out nocopy  VARCHAR2
    , p6_a6 out nocopy  VARCHAR2
    , p6_a7 out nocopy  VARCHAR2
    , p6_a8 out nocopy  VARCHAR2
    , p6_a9 out nocopy  VARCHAR2
    , p6_a10 out nocopy  VARCHAR2
    , p6_a11 out nocopy  VARCHAR2
    , p6_a12 out nocopy  VARCHAR2
    , p6_a13 out nocopy  VARCHAR2
    , p6_a14 out nocopy  VARCHAR2
    , p6_a15 out nocopy  VARCHAR2
    , p6_a16 out nocopy  VARCHAR2
    , p6_a17 out nocopy  VARCHAR2
    , p6_a18 out nocopy  NUMBER
    , p6_a19 out nocopy  VARCHAR2
    , p6_a20 out nocopy  VARCHAR2
    , p6_a21 out nocopy  VARCHAR2
    , p6_a22 out nocopy  VARCHAR2
    , p6_a23 out nocopy  VARCHAR2
    , p6_a24 out nocopy  VARCHAR2
    , p6_a25 out nocopy  DATE
    , p6_a26 out nocopy  DATE
    , p7_a0  NUMBER
    , p7_a1  NUMBER
    , p7_a2  VARCHAR2
    , p7_a3  VARCHAR2
    , p7_a4  VARCHAR2
    , p7_a5  VARCHAR2
    , p7_a6  VARCHAR2
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
    , p7_a18  NUMBER
    , p7_a19  VARCHAR2
    , p7_a20  VARCHAR2
    , p7_a21  DATE
    , p7_a22  DATE
    , p7_a23  NUMBER
    , p7_a24  NUMBER
    , p7_a25  VARCHAR2
    , p8_a0 out nocopy  NUMBER
    , p8_a1 out nocopy  NUMBER
    , p8_a2 out nocopy  VARCHAR2
    , p8_a3 out nocopy  VARCHAR2
    , p8_a4 out nocopy  VARCHAR2
    , p8_a5 out nocopy  VARCHAR2
    , p8_a6 out nocopy  VARCHAR2
    , p8_a7 out nocopy  VARCHAR2
    , p8_a8 out nocopy  VARCHAR2
    , p8_a9 out nocopy  VARCHAR2
    , p8_a10 out nocopy  VARCHAR2
    , p8_a11 out nocopy  VARCHAR2
    , p8_a12 out nocopy  VARCHAR2
    , p8_a13 out nocopy  VARCHAR2
    , p8_a14 out nocopy  VARCHAR2
    , p8_a15 out nocopy  VARCHAR2
    , p8_a16 out nocopy  VARCHAR2
    , p8_a17 out nocopy  VARCHAR2
    , p8_a18 out nocopy  NUMBER
    , p8_a19 out nocopy  VARCHAR2
    , p8_a20 out nocopy  VARCHAR2
    , p8_a21 out nocopy  DATE
    , p8_a22 out nocopy  DATE
    , p8_a23 out nocopy  NUMBER
    , p8_a24 out nocopy  NUMBER
    , p8_a25 out nocopy  VARCHAR2
  )

  as
    ddp_latv_rec okl_leaseapp_template_pvt.latv_rec_type;
    ddx_latv_rec okl_leaseapp_template_pvt.latv_rec_type;
    ddp_lavv_rec okl_leaseapp_template_pvt.lavv_rec_type;
    ddx_lavv_rec okl_leaseapp_template_pvt.lavv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_latv_rec.id := p5_a0;
    ddp_latv_rec.object_version_number := p5_a1;
    ddp_latv_rec.attribute_category := p5_a2;
    ddp_latv_rec.attribute1 := p5_a3;
    ddp_latv_rec.attribute2 := p5_a4;
    ddp_latv_rec.attribute3 := p5_a5;
    ddp_latv_rec.attribute4 := p5_a6;
    ddp_latv_rec.attribute5 := p5_a7;
    ddp_latv_rec.attribute6 := p5_a8;
    ddp_latv_rec.attribute7 := p5_a9;
    ddp_latv_rec.attribute8 := p5_a10;
    ddp_latv_rec.attribute9 := p5_a11;
    ddp_latv_rec.attribute10 := p5_a12;
    ddp_latv_rec.attribute11 := p5_a13;
    ddp_latv_rec.attribute12 := p5_a14;
    ddp_latv_rec.attribute13 := p5_a15;
    ddp_latv_rec.attribute14 := p5_a16;
    ddp_latv_rec.attribute15 := p5_a17;
    ddp_latv_rec.org_id := p5_a18;
    ddp_latv_rec.name := p5_a19;
    ddp_latv_rec.template_status := p5_a20;
    ddp_latv_rec.credit_review_purpose := p5_a21;
    ddp_latv_rec.cust_credit_classification := p5_a22;
    ddp_latv_rec.industry_class := p5_a23;
    ddp_latv_rec.industry_code := p5_a24;
    ddp_latv_rec.valid_from := p5_a25;
    ddp_latv_rec.valid_to := p5_a26;


    ddp_lavv_rec.id := p7_a0;
    ddp_lavv_rec.object_version_number := p7_a1;
    ddp_lavv_rec.attribute_category := p7_a2;
    ddp_lavv_rec.attribute1 := p7_a3;
    ddp_lavv_rec.attribute2 := p7_a4;
    ddp_lavv_rec.attribute3 := p7_a5;
    ddp_lavv_rec.attribute4 := p7_a6;
    ddp_lavv_rec.attribute5 := p7_a7;
    ddp_lavv_rec.attribute6 := p7_a8;
    ddp_lavv_rec.attribute7 := p7_a9;
    ddp_lavv_rec.attribute8 := p7_a10;
    ddp_lavv_rec.attribute9 := p7_a11;
    ddp_lavv_rec.attribute10 := p7_a12;
    ddp_lavv_rec.attribute11 := p7_a13;
    ddp_lavv_rec.attribute12 := p7_a14;
    ddp_lavv_rec.attribute13 := p7_a15;
    ddp_lavv_rec.attribute14 := p7_a16;
    ddp_lavv_rec.attribute15 := p7_a17;
    ddp_lavv_rec.leaseapp_template_id := p7_a18;
    ddp_lavv_rec.version_status := p7_a19;
    ddp_lavv_rec.version_number := p7_a20;
    ddp_lavv_rec.valid_from := p7_a21;
    ddp_lavv_rec.valid_to := p7_a22;
    ddp_lavv_rec.checklist_id := p7_a23;
    ddp_lavv_rec.contract_template_id := p7_a24;
    ddp_lavv_rec.short_description := p7_a25;


    -- here's the delegated call to the old PL/SQL routine
    okl_leaseapp_template_pvt.create_leaseapp_template(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_latv_rec,
      ddx_latv_rec,
      ddp_lavv_rec,
      ddx_lavv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := ddx_latv_rec.id;
    p6_a1 := ddx_latv_rec.object_version_number;
    p6_a2 := ddx_latv_rec.attribute_category;
    p6_a3 := ddx_latv_rec.attribute1;
    p6_a4 := ddx_latv_rec.attribute2;
    p6_a5 := ddx_latv_rec.attribute3;
    p6_a6 := ddx_latv_rec.attribute4;
    p6_a7 := ddx_latv_rec.attribute5;
    p6_a8 := ddx_latv_rec.attribute6;
    p6_a9 := ddx_latv_rec.attribute7;
    p6_a10 := ddx_latv_rec.attribute8;
    p6_a11 := ddx_latv_rec.attribute9;
    p6_a12 := ddx_latv_rec.attribute10;
    p6_a13 := ddx_latv_rec.attribute11;
    p6_a14 := ddx_latv_rec.attribute12;
    p6_a15 := ddx_latv_rec.attribute13;
    p6_a16 := ddx_latv_rec.attribute14;
    p6_a17 := ddx_latv_rec.attribute15;
    p6_a18 := ddx_latv_rec.org_id;
    p6_a19 := ddx_latv_rec.name;
    p6_a20 := ddx_latv_rec.template_status;
    p6_a21 := ddx_latv_rec.credit_review_purpose;
    p6_a22 := ddx_latv_rec.cust_credit_classification;
    p6_a23 := ddx_latv_rec.industry_class;
    p6_a24 := ddx_latv_rec.industry_code;
    p6_a25 := ddx_latv_rec.valid_from;
    p6_a26 := ddx_latv_rec.valid_to;


    p8_a0 := ddx_lavv_rec.id;
    p8_a1 := ddx_lavv_rec.object_version_number;
    p8_a2 := ddx_lavv_rec.attribute_category;
    p8_a3 := ddx_lavv_rec.attribute1;
    p8_a4 := ddx_lavv_rec.attribute2;
    p8_a5 := ddx_lavv_rec.attribute3;
    p8_a6 := ddx_lavv_rec.attribute4;
    p8_a7 := ddx_lavv_rec.attribute5;
    p8_a8 := ddx_lavv_rec.attribute6;
    p8_a9 := ddx_lavv_rec.attribute7;
    p8_a10 := ddx_lavv_rec.attribute8;
    p8_a11 := ddx_lavv_rec.attribute9;
    p8_a12 := ddx_lavv_rec.attribute10;
    p8_a13 := ddx_lavv_rec.attribute11;
    p8_a14 := ddx_lavv_rec.attribute12;
    p8_a15 := ddx_lavv_rec.attribute13;
    p8_a16 := ddx_lavv_rec.attribute14;
    p8_a17 := ddx_lavv_rec.attribute15;
    p8_a18 := ddx_lavv_rec.leaseapp_template_id;
    p8_a19 := ddx_lavv_rec.version_status;
    p8_a20 := ddx_lavv_rec.version_number;
    p8_a21 := ddx_lavv_rec.valid_from;
    p8_a22 := ddx_lavv_rec.valid_to;
    p8_a23 := ddx_lavv_rec.checklist_id;
    p8_a24 := ddx_lavv_rec.contract_template_id;
    p8_a25 := ddx_lavv_rec.short_description;
  end;

  procedure update_leaseapp_template(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER
    , p5_a1  NUMBER
    , p5_a2  VARCHAR2
    , p5_a3  VARCHAR2
    , p5_a4  VARCHAR2
    , p5_a5  VARCHAR2
    , p5_a6  VARCHAR2
    , p5_a7  VARCHAR2
    , p5_a8  VARCHAR2
    , p5_a9  VARCHAR2
    , p5_a10  VARCHAR2
    , p5_a11  VARCHAR2
    , p5_a12  VARCHAR2
    , p5_a13  VARCHAR2
    , p5_a14  VARCHAR2
    , p5_a15  VARCHAR2
    , p5_a16  VARCHAR2
    , p5_a17  VARCHAR2
    , p5_a18  NUMBER
    , p5_a19  VARCHAR2
    , p5_a20  VARCHAR2
    , p5_a21  VARCHAR2
    , p5_a22  VARCHAR2
    , p5_a23  VARCHAR2
    , p5_a24  VARCHAR2
    , p5_a25  DATE
    , p5_a26  DATE
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  VARCHAR2
    , p6_a3 out nocopy  VARCHAR2
    , p6_a4 out nocopy  VARCHAR2
    , p6_a5 out nocopy  VARCHAR2
    , p6_a6 out nocopy  VARCHAR2
    , p6_a7 out nocopy  VARCHAR2
    , p6_a8 out nocopy  VARCHAR2
    , p6_a9 out nocopy  VARCHAR2
    , p6_a10 out nocopy  VARCHAR2
    , p6_a11 out nocopy  VARCHAR2
    , p6_a12 out nocopy  VARCHAR2
    , p6_a13 out nocopy  VARCHAR2
    , p6_a14 out nocopy  VARCHAR2
    , p6_a15 out nocopy  VARCHAR2
    , p6_a16 out nocopy  VARCHAR2
    , p6_a17 out nocopy  VARCHAR2
    , p6_a18 out nocopy  NUMBER
    , p6_a19 out nocopy  VARCHAR2
    , p6_a20 out nocopy  VARCHAR2
    , p6_a21 out nocopy  VARCHAR2
    , p6_a22 out nocopy  VARCHAR2
    , p6_a23 out nocopy  VARCHAR2
    , p6_a24 out nocopy  VARCHAR2
    , p6_a25 out nocopy  DATE
    , p6_a26 out nocopy  DATE
    , p7_a0  NUMBER
    , p7_a1  NUMBER
    , p7_a2  VARCHAR2
    , p7_a3  VARCHAR2
    , p7_a4  VARCHAR2
    , p7_a5  VARCHAR2
    , p7_a6  VARCHAR2
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
    , p7_a18  NUMBER
    , p7_a19  VARCHAR2
    , p7_a20  VARCHAR2
    , p7_a21  DATE
    , p7_a22  DATE
    , p7_a23  NUMBER
    , p7_a24  NUMBER
    , p7_a25  VARCHAR2
    , p8_a0 out nocopy  NUMBER
    , p8_a1 out nocopy  NUMBER
    , p8_a2 out nocopy  VARCHAR2
    , p8_a3 out nocopy  VARCHAR2
    , p8_a4 out nocopy  VARCHAR2
    , p8_a5 out nocopy  VARCHAR2
    , p8_a6 out nocopy  VARCHAR2
    , p8_a7 out nocopy  VARCHAR2
    , p8_a8 out nocopy  VARCHAR2
    , p8_a9 out nocopy  VARCHAR2
    , p8_a10 out nocopy  VARCHAR2
    , p8_a11 out nocopy  VARCHAR2
    , p8_a12 out nocopy  VARCHAR2
    , p8_a13 out nocopy  VARCHAR2
    , p8_a14 out nocopy  VARCHAR2
    , p8_a15 out nocopy  VARCHAR2
    , p8_a16 out nocopy  VARCHAR2
    , p8_a17 out nocopy  VARCHAR2
    , p8_a18 out nocopy  NUMBER
    , p8_a19 out nocopy  VARCHAR2
    , p8_a20 out nocopy  VARCHAR2
    , p8_a21 out nocopy  DATE
    , p8_a22 out nocopy  DATE
    , p8_a23 out nocopy  NUMBER
    , p8_a24 out nocopy  NUMBER
    , p8_a25 out nocopy  VARCHAR2
    , p_ident_flag  VARCHAR2
  )

  as
    ddp_latv_rec okl_leaseapp_template_pvt.latv_rec_type;
    ddx_latv_rec okl_leaseapp_template_pvt.latv_rec_type;
    ddp_lavv_rec okl_leaseapp_template_pvt.lavv_rec_type;
    ddx_lavv_rec okl_leaseapp_template_pvt.lavv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_latv_rec.id := p5_a0;
    ddp_latv_rec.object_version_number := p5_a1;
    ddp_latv_rec.attribute_category := p5_a2;
    ddp_latv_rec.attribute1 := p5_a3;
    ddp_latv_rec.attribute2 := p5_a4;
    ddp_latv_rec.attribute3 := p5_a5;
    ddp_latv_rec.attribute4 := p5_a6;
    ddp_latv_rec.attribute5 := p5_a7;
    ddp_latv_rec.attribute6 := p5_a8;
    ddp_latv_rec.attribute7 := p5_a9;
    ddp_latv_rec.attribute8 := p5_a10;
    ddp_latv_rec.attribute9 := p5_a11;
    ddp_latv_rec.attribute10 := p5_a12;
    ddp_latv_rec.attribute11 := p5_a13;
    ddp_latv_rec.attribute12 := p5_a14;
    ddp_latv_rec.attribute13 := p5_a15;
    ddp_latv_rec.attribute14 := p5_a16;
    ddp_latv_rec.attribute15 := p5_a17;
    ddp_latv_rec.org_id := p5_a18;
    ddp_latv_rec.name := p5_a19;
    ddp_latv_rec.template_status := p5_a20;
    ddp_latv_rec.credit_review_purpose := p5_a21;
    ddp_latv_rec.cust_credit_classification := p5_a22;
    ddp_latv_rec.industry_class := p5_a23;
    ddp_latv_rec.industry_code := p5_a24;
    ddp_latv_rec.valid_from := p5_a25;
    ddp_latv_rec.valid_to := p5_a26;


    ddp_lavv_rec.id := p7_a0;
    ddp_lavv_rec.object_version_number := p7_a1;
    ddp_lavv_rec.attribute_category := p7_a2;
    ddp_lavv_rec.attribute1 := p7_a3;
    ddp_lavv_rec.attribute2 := p7_a4;
    ddp_lavv_rec.attribute3 := p7_a5;
    ddp_lavv_rec.attribute4 := p7_a6;
    ddp_lavv_rec.attribute5 := p7_a7;
    ddp_lavv_rec.attribute6 := p7_a8;
    ddp_lavv_rec.attribute7 := p7_a9;
    ddp_lavv_rec.attribute8 := p7_a10;
    ddp_lavv_rec.attribute9 := p7_a11;
    ddp_lavv_rec.attribute10 := p7_a12;
    ddp_lavv_rec.attribute11 := p7_a13;
    ddp_lavv_rec.attribute12 := p7_a14;
    ddp_lavv_rec.attribute13 := p7_a15;
    ddp_lavv_rec.attribute14 := p7_a16;
    ddp_lavv_rec.attribute15 := p7_a17;
    ddp_lavv_rec.leaseapp_template_id := p7_a18;
    ddp_lavv_rec.version_status := p7_a19;
    ddp_lavv_rec.version_number := p7_a20;
    ddp_lavv_rec.valid_from := p7_a21;
    ddp_lavv_rec.valid_to := p7_a22;
    ddp_lavv_rec.checklist_id := p7_a23;
    ddp_lavv_rec.contract_template_id := p7_a24;
    ddp_lavv_rec.short_description := p7_a25;



    -- here's the delegated call to the old PL/SQL routine
    okl_leaseapp_template_pvt.update_leaseapp_template(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_latv_rec,
      ddx_latv_rec,
      ddp_lavv_rec,
      ddx_lavv_rec,
      p_ident_flag);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := ddx_latv_rec.id;
    p6_a1 := ddx_latv_rec.object_version_number;
    p6_a2 := ddx_latv_rec.attribute_category;
    p6_a3 := ddx_latv_rec.attribute1;
    p6_a4 := ddx_latv_rec.attribute2;
    p6_a5 := ddx_latv_rec.attribute3;
    p6_a6 := ddx_latv_rec.attribute4;
    p6_a7 := ddx_latv_rec.attribute5;
    p6_a8 := ddx_latv_rec.attribute6;
    p6_a9 := ddx_latv_rec.attribute7;
    p6_a10 := ddx_latv_rec.attribute8;
    p6_a11 := ddx_latv_rec.attribute9;
    p6_a12 := ddx_latv_rec.attribute10;
    p6_a13 := ddx_latv_rec.attribute11;
    p6_a14 := ddx_latv_rec.attribute12;
    p6_a15 := ddx_latv_rec.attribute13;
    p6_a16 := ddx_latv_rec.attribute14;
    p6_a17 := ddx_latv_rec.attribute15;
    p6_a18 := ddx_latv_rec.org_id;
    p6_a19 := ddx_latv_rec.name;
    p6_a20 := ddx_latv_rec.template_status;
    p6_a21 := ddx_latv_rec.credit_review_purpose;
    p6_a22 := ddx_latv_rec.cust_credit_classification;
    p6_a23 := ddx_latv_rec.industry_class;
    p6_a24 := ddx_latv_rec.industry_code;
    p6_a25 := ddx_latv_rec.valid_from;
    p6_a26 := ddx_latv_rec.valid_to;


    p8_a0 := ddx_lavv_rec.id;
    p8_a1 := ddx_lavv_rec.object_version_number;
    p8_a2 := ddx_lavv_rec.attribute_category;
    p8_a3 := ddx_lavv_rec.attribute1;
    p8_a4 := ddx_lavv_rec.attribute2;
    p8_a5 := ddx_lavv_rec.attribute3;
    p8_a6 := ddx_lavv_rec.attribute4;
    p8_a7 := ddx_lavv_rec.attribute5;
    p8_a8 := ddx_lavv_rec.attribute6;
    p8_a9 := ddx_lavv_rec.attribute7;
    p8_a10 := ddx_lavv_rec.attribute8;
    p8_a11 := ddx_lavv_rec.attribute9;
    p8_a12 := ddx_lavv_rec.attribute10;
    p8_a13 := ddx_lavv_rec.attribute11;
    p8_a14 := ddx_lavv_rec.attribute12;
    p8_a15 := ddx_lavv_rec.attribute13;
    p8_a16 := ddx_lavv_rec.attribute14;
    p8_a17 := ddx_lavv_rec.attribute15;
    p8_a18 := ddx_lavv_rec.leaseapp_template_id;
    p8_a19 := ddx_lavv_rec.version_status;
    p8_a20 := ddx_lavv_rec.version_number;
    p8_a21 := ddx_lavv_rec.valid_from;
    p8_a22 := ddx_lavv_rec.valid_to;
    p8_a23 := ddx_lavv_rec.checklist_id;
    p8_a24 := ddx_lavv_rec.contract_template_id;
    p8_a25 := ddx_lavv_rec.short_description;

  end;

  procedure version_duplicate_lseapp_tmpl(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER
    , p5_a1  NUMBER
    , p5_a2  VARCHAR2
    , p5_a3  VARCHAR2
    , p5_a4  VARCHAR2
    , p5_a5  VARCHAR2
    , p5_a6  VARCHAR2
    , p5_a7  VARCHAR2
    , p5_a8  VARCHAR2
    , p5_a9  VARCHAR2
    , p5_a10  VARCHAR2
    , p5_a11  VARCHAR2
    , p5_a12  VARCHAR2
    , p5_a13  VARCHAR2
    , p5_a14  VARCHAR2
    , p5_a15  VARCHAR2
    , p5_a16  VARCHAR2
    , p5_a17  VARCHAR2
    , p5_a18  NUMBER
    , p5_a19  VARCHAR2
    , p5_a20  VARCHAR2
    , p5_a21  VARCHAR2
    , p5_a22  VARCHAR2
    , p5_a23  VARCHAR2
    , p5_a24  VARCHAR2
    , p5_a25  DATE
    , p5_a26  DATE
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  VARCHAR2
    , p6_a3 out nocopy  VARCHAR2
    , p6_a4 out nocopy  VARCHAR2
    , p6_a5 out nocopy  VARCHAR2
    , p6_a6 out nocopy  VARCHAR2
    , p6_a7 out nocopy  VARCHAR2
    , p6_a8 out nocopy  VARCHAR2
    , p6_a9 out nocopy  VARCHAR2
    , p6_a10 out nocopy  VARCHAR2
    , p6_a11 out nocopy  VARCHAR2
    , p6_a12 out nocopy  VARCHAR2
    , p6_a13 out nocopy  VARCHAR2
    , p6_a14 out nocopy  VARCHAR2
    , p6_a15 out nocopy  VARCHAR2
    , p6_a16 out nocopy  VARCHAR2
    , p6_a17 out nocopy  VARCHAR2
    , p6_a18 out nocopy  NUMBER
    , p6_a19 out nocopy  VARCHAR2
    , p6_a20 out nocopy  VARCHAR2
    , p6_a21 out nocopy  VARCHAR2
    , p6_a22 out nocopy  VARCHAR2
    , p6_a23 out nocopy  VARCHAR2
    , p6_a24 out nocopy  VARCHAR2
    , p6_a25 out nocopy  DATE
    , p6_a26 out nocopy  DATE
    , p7_a0  NUMBER
    , p7_a1  NUMBER
    , p7_a2  VARCHAR2
    , p7_a3  VARCHAR2
    , p7_a4  VARCHAR2
    , p7_a5  VARCHAR2
    , p7_a6  VARCHAR2
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
    , p7_a18  NUMBER
    , p7_a19  VARCHAR2
    , p7_a20  VARCHAR2
    , p7_a21  DATE
    , p7_a22  DATE
    , p7_a23  NUMBER
    , p7_a24  NUMBER
    , p7_a25  VARCHAR2
    , p8_a0 out nocopy  NUMBER
    , p8_a1 out nocopy  NUMBER
    , p8_a2 out nocopy  VARCHAR2
    , p8_a3 out nocopy  VARCHAR2
    , p8_a4 out nocopy  VARCHAR2
    , p8_a5 out nocopy  VARCHAR2
    , p8_a6 out nocopy  VARCHAR2
    , p8_a7 out nocopy  VARCHAR2
    , p8_a8 out nocopy  VARCHAR2
    , p8_a9 out nocopy  VARCHAR2
    , p8_a10 out nocopy  VARCHAR2
    , p8_a11 out nocopy  VARCHAR2
    , p8_a12 out nocopy  VARCHAR2
    , p8_a13 out nocopy  VARCHAR2
    , p8_a14 out nocopy  VARCHAR2
    , p8_a15 out nocopy  VARCHAR2
    , p8_a16 out nocopy  VARCHAR2
    , p8_a17 out nocopy  VARCHAR2
    , p8_a18 out nocopy  NUMBER
    , p8_a19 out nocopy  VARCHAR2
    , p8_a20 out nocopy  VARCHAR2
    , p8_a21 out nocopy  DATE
    , p8_a22 out nocopy  DATE
    , p8_a23 out nocopy  NUMBER
    , p8_a24 out nocopy  NUMBER
    , p8_a25 out nocopy  VARCHAR2
    , p_mode  VARCHAR2
  )

  as
    ddp_latv_rec okl_leaseapp_template_pvt.latv_rec_type;
    ddx_latv_rec okl_leaseapp_template_pvt.latv_rec_type;
    ddp_lavv_rec okl_leaseapp_template_pvt.lavv_rec_type;
    ddx_lavv_rec okl_leaseapp_template_pvt.lavv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_latv_rec.id := p5_a0;
    ddp_latv_rec.object_version_number := p5_a1;
    ddp_latv_rec.attribute_category := p5_a2;
    ddp_latv_rec.attribute1 := p5_a3;
    ddp_latv_rec.attribute2 := p5_a4;
    ddp_latv_rec.attribute3 := p5_a5;
    ddp_latv_rec.attribute4 := p5_a6;
    ddp_latv_rec.attribute5 := p5_a7;
    ddp_latv_rec.attribute6 := p5_a8;
    ddp_latv_rec.attribute7 := p5_a9;
    ddp_latv_rec.attribute8 := p5_a10;
    ddp_latv_rec.attribute9 := p5_a11;
    ddp_latv_rec.attribute10 := p5_a12;
    ddp_latv_rec.attribute11 := p5_a13;
    ddp_latv_rec.attribute12 := p5_a14;
    ddp_latv_rec.attribute13 := p5_a15;
    ddp_latv_rec.attribute14 := p5_a16;
    ddp_latv_rec.attribute15 := p5_a17;
    ddp_latv_rec.org_id := p5_a18;
    ddp_latv_rec.name := p5_a19;
    ddp_latv_rec.template_status := p5_a20;
    ddp_latv_rec.credit_review_purpose := p5_a21;
    ddp_latv_rec.cust_credit_classification := p5_a22;
    ddp_latv_rec.industry_class := p5_a23;
    ddp_latv_rec.industry_code := p5_a24;
    ddp_latv_rec.valid_from := p5_a25;
    ddp_latv_rec.valid_to := p5_a26;


    ddp_lavv_rec.id := p7_a0;
    ddp_lavv_rec.object_version_number := p7_a1;
    ddp_lavv_rec.attribute_category := p7_a2;
    ddp_lavv_rec.attribute1 := p7_a3;
    ddp_lavv_rec.attribute2 := p7_a4;
    ddp_lavv_rec.attribute3 := p7_a5;
    ddp_lavv_rec.attribute4 := p7_a6;
    ddp_lavv_rec.attribute5 := p7_a7;
    ddp_lavv_rec.attribute6 := p7_a8;
    ddp_lavv_rec.attribute7 := p7_a9;
    ddp_lavv_rec.attribute8 := p7_a10;
    ddp_lavv_rec.attribute9 := p7_a11;
    ddp_lavv_rec.attribute10 := p7_a12;
    ddp_lavv_rec.attribute11 := p7_a13;
    ddp_lavv_rec.attribute12 := p7_a14;
    ddp_lavv_rec.attribute13 := p7_a15;
    ddp_lavv_rec.attribute14 := p7_a16;
    ddp_lavv_rec.attribute15 := p7_a17;
    ddp_lavv_rec.leaseapp_template_id := p7_a18;
    ddp_lavv_rec.version_status := p7_a19;
    ddp_lavv_rec.version_number := p7_a20;
    ddp_lavv_rec.valid_from := p7_a21;
    ddp_lavv_rec.valid_to := p7_a22;
    ddp_lavv_rec.checklist_id := p7_a23;
    ddp_lavv_rec.contract_template_id := p7_a24;
    ddp_lavv_rec.short_description := p7_a25;



    -- here's the delegated call to the old PL/SQL routine
    okl_leaseapp_template_pvt.version_duplicate_lseapp_tmpl(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_latv_rec,
      ddx_latv_rec,
      ddp_lavv_rec,
      ddx_lavv_rec,
      p_mode);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := ddx_latv_rec.id;
    p6_a1 := ddx_latv_rec.object_version_number;
    p6_a2 := ddx_latv_rec.attribute_category;
    p6_a3 := ddx_latv_rec.attribute1;
    p6_a4 := ddx_latv_rec.attribute2;
    p6_a5 := ddx_latv_rec.attribute3;
    p6_a6 := ddx_latv_rec.attribute4;
    p6_a7 := ddx_latv_rec.attribute5;
    p6_a8 := ddx_latv_rec.attribute6;
    p6_a9 := ddx_latv_rec.attribute7;
    p6_a10 := ddx_latv_rec.attribute8;
    p6_a11 := ddx_latv_rec.attribute9;
    p6_a12 := ddx_latv_rec.attribute10;
    p6_a13 := ddx_latv_rec.attribute11;
    p6_a14 := ddx_latv_rec.attribute12;
    p6_a15 := ddx_latv_rec.attribute13;
    p6_a16 := ddx_latv_rec.attribute14;
    p6_a17 := ddx_latv_rec.attribute15;
    p6_a18 := ddx_latv_rec.org_id;
    p6_a19 := ddx_latv_rec.name;
    p6_a20 := ddx_latv_rec.template_status;
    p6_a21 := ddx_latv_rec.credit_review_purpose;
    p6_a22 := ddx_latv_rec.cust_credit_classification;
    p6_a23 := ddx_latv_rec.industry_class;
    p6_a24 := ddx_latv_rec.industry_code;
    p6_a25 := ddx_latv_rec.valid_from;
    p6_a26 := ddx_latv_rec.valid_to;


    p8_a0 := ddx_lavv_rec.id;
    p8_a1 := ddx_lavv_rec.object_version_number;
    p8_a2 := ddx_lavv_rec.attribute_category;
    p8_a3 := ddx_lavv_rec.attribute1;
    p8_a4 := ddx_lavv_rec.attribute2;
    p8_a5 := ddx_lavv_rec.attribute3;
    p8_a6 := ddx_lavv_rec.attribute4;
    p8_a7 := ddx_lavv_rec.attribute5;
    p8_a8 := ddx_lavv_rec.attribute6;
    p8_a9 := ddx_lavv_rec.attribute7;
    p8_a10 := ddx_lavv_rec.attribute8;
    p8_a11 := ddx_lavv_rec.attribute9;
    p8_a12 := ddx_lavv_rec.attribute10;
    p8_a13 := ddx_lavv_rec.attribute11;
    p8_a14 := ddx_lavv_rec.attribute12;
    p8_a15 := ddx_lavv_rec.attribute13;
    p8_a16 := ddx_lavv_rec.attribute14;
    p8_a17 := ddx_lavv_rec.attribute15;
    p8_a18 := ddx_lavv_rec.leaseapp_template_id;
    p8_a19 := ddx_lavv_rec.version_status;
    p8_a20 := ddx_lavv_rec.version_number;
    p8_a21 := ddx_lavv_rec.valid_from;
    p8_a22 := ddx_lavv_rec.valid_to;
    p8_a23 := ddx_lavv_rec.checklist_id;
    p8_a24 := ddx_lavv_rec.contract_template_id;
    p8_a25 := ddx_lavv_rec.short_description;

  end;

  procedure validate_lease_app_template(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER
    , p5_a1  NUMBER
    , p5_a2  VARCHAR2
    , p5_a3  VARCHAR2
    , p5_a4  VARCHAR2
    , p5_a5  VARCHAR2
    , p5_a6  VARCHAR2
    , p5_a7  VARCHAR2
    , p5_a8  VARCHAR2
    , p5_a9  VARCHAR2
    , p5_a10  VARCHAR2
    , p5_a11  VARCHAR2
    , p5_a12  VARCHAR2
    , p5_a13  VARCHAR2
    , p5_a14  VARCHAR2
    , p5_a15  VARCHAR2
    , p5_a16  VARCHAR2
    , p5_a17  VARCHAR2
    , p5_a18  NUMBER
    , p5_a19  VARCHAR2
    , p5_a20  VARCHAR2
    , p5_a21  VARCHAR2
    , p5_a22  VARCHAR2
    , p5_a23  VARCHAR2
    , p5_a24  VARCHAR2
    , p5_a25  DATE
    , p5_a26  DATE
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  VARCHAR2
    , p6_a3 out nocopy  VARCHAR2
    , p6_a4 out nocopy  VARCHAR2
    , p6_a5 out nocopy  VARCHAR2
    , p6_a6 out nocopy  VARCHAR2
    , p6_a7 out nocopy  VARCHAR2
    , p6_a8 out nocopy  VARCHAR2
    , p6_a9 out nocopy  VARCHAR2
    , p6_a10 out nocopy  VARCHAR2
    , p6_a11 out nocopy  VARCHAR2
    , p6_a12 out nocopy  VARCHAR2
    , p6_a13 out nocopy  VARCHAR2
    , p6_a14 out nocopy  VARCHAR2
    , p6_a15 out nocopy  VARCHAR2
    , p6_a16 out nocopy  VARCHAR2
    , p6_a17 out nocopy  VARCHAR2
    , p6_a18 out nocopy  NUMBER
    , p6_a19 out nocopy  VARCHAR2
    , p6_a20 out nocopy  VARCHAR2
    , p6_a21 out nocopy  VARCHAR2
    , p6_a22 out nocopy  VARCHAR2
    , p6_a23 out nocopy  VARCHAR2
    , p6_a24 out nocopy  VARCHAR2
    , p6_a25 out nocopy  DATE
    , p6_a26 out nocopy  DATE
    , p7_a0  NUMBER
    , p7_a1  NUMBER
    , p7_a2  VARCHAR2
    , p7_a3  VARCHAR2
    , p7_a4  VARCHAR2
    , p7_a5  VARCHAR2
    , p7_a6  VARCHAR2
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
    , p7_a18  NUMBER
    , p7_a19  VARCHAR2
    , p7_a20  VARCHAR2
    , p7_a21  DATE
    , p7_a22  DATE
    , p7_a23  NUMBER
    , p7_a24  NUMBER
    , p7_a25  VARCHAR2
    , p8_a0 out nocopy  NUMBER
    , p8_a1 out nocopy  NUMBER
    , p8_a2 out nocopy  VARCHAR2
    , p8_a3 out nocopy  VARCHAR2
    , p8_a4 out nocopy  VARCHAR2
    , p8_a5 out nocopy  VARCHAR2
    , p8_a6 out nocopy  VARCHAR2
    , p8_a7 out nocopy  VARCHAR2
    , p8_a8 out nocopy  VARCHAR2
    , p8_a9 out nocopy  VARCHAR2
    , p8_a10 out nocopy  VARCHAR2
    , p8_a11 out nocopy  VARCHAR2
    , p8_a12 out nocopy  VARCHAR2
    , p8_a13 out nocopy  VARCHAR2
    , p8_a14 out nocopy  VARCHAR2
    , p8_a15 out nocopy  VARCHAR2
    , p8_a16 out nocopy  VARCHAR2
    , p8_a17 out nocopy  VARCHAR2
    , p8_a18 out nocopy  NUMBER
    , p8_a19 out nocopy  VARCHAR2
    , p8_a20 out nocopy  VARCHAR2
    , p8_a21 out nocopy  DATE
    , p8_a22 out nocopy  DATE
    , p8_a23 out nocopy  NUMBER
    , p8_a24 out nocopy  NUMBER
    , p8_a25 out nocopy  VARCHAR2
    , p_during_upd_flag  VARCHAR2
    , p10_a0 out nocopy JTF_VARCHAR2_TABLE_2500
    , p10_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a2 out nocopy JTF_VARCHAR2_TABLE_100
  )

  as
    ddp_latv_rec okl_leaseapp_template_pvt.latv_rec_type;
    ddx_latv_rec okl_leaseapp_template_pvt.latv_rec_type;
    ddp_lavv_rec okl_leaseapp_template_pvt.lavv_rec_type;
    ddx_lavv_rec okl_leaseapp_template_pvt.lavv_rec_type;
    ddx_error_msgs_tbl okl_leaseapp_template_pvt.error_msgs_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_latv_rec.id := p5_a0;
    ddp_latv_rec.object_version_number := p5_a1;
    ddp_latv_rec.attribute_category := p5_a2;
    ddp_latv_rec.attribute1 := p5_a3;
    ddp_latv_rec.attribute2 := p5_a4;
    ddp_latv_rec.attribute3 := p5_a5;
    ddp_latv_rec.attribute4 := p5_a6;
    ddp_latv_rec.attribute5 := p5_a7;
    ddp_latv_rec.attribute6 := p5_a8;
    ddp_latv_rec.attribute7 := p5_a9;
    ddp_latv_rec.attribute8 := p5_a10;
    ddp_latv_rec.attribute9 := p5_a11;
    ddp_latv_rec.attribute10 := p5_a12;
    ddp_latv_rec.attribute11 := p5_a13;
    ddp_latv_rec.attribute12 := p5_a14;
    ddp_latv_rec.attribute13 := p5_a15;
    ddp_latv_rec.attribute14 := p5_a16;
    ddp_latv_rec.attribute15 := p5_a17;
    ddp_latv_rec.org_id := p5_a18;
    ddp_latv_rec.name := p5_a19;
    ddp_latv_rec.template_status := p5_a20;
    ddp_latv_rec.credit_review_purpose := p5_a21;
    ddp_latv_rec.cust_credit_classification := p5_a22;
    ddp_latv_rec.industry_class := p5_a23;
    ddp_latv_rec.industry_code := p5_a24;
    ddp_latv_rec.valid_from := p5_a25;
    ddp_latv_rec.valid_to := p5_a26;


    ddp_lavv_rec.id := p7_a0;
    ddp_lavv_rec.object_version_number := p7_a1;
    ddp_lavv_rec.attribute_category := p7_a2;
    ddp_lavv_rec.attribute1 := p7_a3;
    ddp_lavv_rec.attribute2 := p7_a4;
    ddp_lavv_rec.attribute3 := p7_a5;
    ddp_lavv_rec.attribute4 := p7_a6;
    ddp_lavv_rec.attribute5 := p7_a7;
    ddp_lavv_rec.attribute6 := p7_a8;
    ddp_lavv_rec.attribute7 := p7_a9;
    ddp_lavv_rec.attribute8 := p7_a10;
    ddp_lavv_rec.attribute9 := p7_a11;
    ddp_lavv_rec.attribute10 := p7_a12;
    ddp_lavv_rec.attribute11 := p7_a13;
    ddp_lavv_rec.attribute12 := p7_a14;
    ddp_lavv_rec.attribute13 := p7_a15;
    ddp_lavv_rec.attribute14 := p7_a16;
    ddp_lavv_rec.attribute15 := p7_a17;
    ddp_lavv_rec.leaseapp_template_id := p7_a18;
    ddp_lavv_rec.version_status := p7_a19;
    ddp_lavv_rec.version_number := p7_a20;
    ddp_lavv_rec.valid_from := p7_a21;
    ddp_lavv_rec.valid_to := p7_a22;
    ddp_lavv_rec.checklist_id := p7_a23;
    ddp_lavv_rec.contract_template_id := p7_a24;
    ddp_lavv_rec.short_description := p7_a25;




    -- here's the delegated call to the old PL/SQL routine
    okl_leaseapp_template_pvt.validate_lease_app_template(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_latv_rec,
      ddx_latv_rec,
      ddp_lavv_rec,
      ddx_lavv_rec,
      p_during_upd_flag,
      ddx_error_msgs_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := ddx_latv_rec.id;
    p6_a1 := ddx_latv_rec.object_version_number;
    p6_a2 := ddx_latv_rec.attribute_category;
    p6_a3 := ddx_latv_rec.attribute1;
    p6_a4 := ddx_latv_rec.attribute2;
    p6_a5 := ddx_latv_rec.attribute3;
    p6_a6 := ddx_latv_rec.attribute4;
    p6_a7 := ddx_latv_rec.attribute5;
    p6_a8 := ddx_latv_rec.attribute6;
    p6_a9 := ddx_latv_rec.attribute7;
    p6_a10 := ddx_latv_rec.attribute8;
    p6_a11 := ddx_latv_rec.attribute9;
    p6_a12 := ddx_latv_rec.attribute10;
    p6_a13 := ddx_latv_rec.attribute11;
    p6_a14 := ddx_latv_rec.attribute12;
    p6_a15 := ddx_latv_rec.attribute13;
    p6_a16 := ddx_latv_rec.attribute14;
    p6_a17 := ddx_latv_rec.attribute15;
    p6_a18 := ddx_latv_rec.org_id;
    p6_a19 := ddx_latv_rec.name;
    p6_a20 := ddx_latv_rec.template_status;
    p6_a21 := ddx_latv_rec.credit_review_purpose;
    p6_a22 := ddx_latv_rec.cust_credit_classification;
    p6_a23 := ddx_latv_rec.industry_class;
    p6_a24 := ddx_latv_rec.industry_code;
    p6_a25 := ddx_latv_rec.valid_from;
    p6_a26 := ddx_latv_rec.valid_to;


    p8_a0 := ddx_lavv_rec.id;
    p8_a1 := ddx_lavv_rec.object_version_number;
    p8_a2 := ddx_lavv_rec.attribute_category;
    p8_a3 := ddx_lavv_rec.attribute1;
    p8_a4 := ddx_lavv_rec.attribute2;
    p8_a5 := ddx_lavv_rec.attribute3;
    p8_a6 := ddx_lavv_rec.attribute4;
    p8_a7 := ddx_lavv_rec.attribute5;
    p8_a8 := ddx_lavv_rec.attribute6;
    p8_a9 := ddx_lavv_rec.attribute7;
    p8_a10 := ddx_lavv_rec.attribute8;
    p8_a11 := ddx_lavv_rec.attribute9;
    p8_a12 := ddx_lavv_rec.attribute10;
    p8_a13 := ddx_lavv_rec.attribute11;
    p8_a14 := ddx_lavv_rec.attribute12;
    p8_a15 := ddx_lavv_rec.attribute13;
    p8_a16 := ddx_lavv_rec.attribute14;
    p8_a17 := ddx_lavv_rec.attribute15;
    p8_a18 := ddx_lavv_rec.leaseapp_template_id;
    p8_a19 := ddx_lavv_rec.version_status;
    p8_a20 := ddx_lavv_rec.version_number;
    p8_a21 := ddx_lavv_rec.valid_from;
    p8_a22 := ddx_lavv_rec.valid_to;
    p8_a23 := ddx_lavv_rec.checklist_id;
    p8_a24 := ddx_lavv_rec.contract_template_id;
    p8_a25 := ddx_lavv_rec.short_description;


    okl_leaseapp_template_pvt_w.rosetta_table_copy_out_p3(ddx_error_msgs_tbl, p10_a0
      , p10_a1
      , p10_a2
      );
  end;

  procedure max_valid_from_date(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER
    , p5_a1  NUMBER
    , p5_a2  VARCHAR2
    , p5_a3  VARCHAR2
    , p5_a4  VARCHAR2
    , p5_a5  VARCHAR2
    , p5_a6  VARCHAR2
    , p5_a7  VARCHAR2
    , p5_a8  VARCHAR2
    , p5_a9  VARCHAR2
    , p5_a10  VARCHAR2
    , p5_a11  VARCHAR2
    , p5_a12  VARCHAR2
    , p5_a13  VARCHAR2
    , p5_a14  VARCHAR2
    , p5_a15  VARCHAR2
    , p5_a16  VARCHAR2
    , p5_a17  VARCHAR2
    , p5_a18  NUMBER
    , p5_a19  VARCHAR2
    , p5_a20  VARCHAR2
    , p5_a21  VARCHAR2
    , p5_a22  VARCHAR2
    , p5_a23  VARCHAR2
    , p5_a24  VARCHAR2
    , p5_a25  DATE
    , p5_a26  DATE
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  VARCHAR2
    , p6_a3 out nocopy  VARCHAR2
    , p6_a4 out nocopy  VARCHAR2
    , p6_a5 out nocopy  VARCHAR2
    , p6_a6 out nocopy  VARCHAR2
    , p6_a7 out nocopy  VARCHAR2
    , p6_a8 out nocopy  VARCHAR2
    , p6_a9 out nocopy  VARCHAR2
    , p6_a10 out nocopy  VARCHAR2
    , p6_a11 out nocopy  VARCHAR2
    , p6_a12 out nocopy  VARCHAR2
    , p6_a13 out nocopy  VARCHAR2
    , p6_a14 out nocopy  VARCHAR2
    , p6_a15 out nocopy  VARCHAR2
    , p6_a16 out nocopy  VARCHAR2
    , p6_a17 out nocopy  VARCHAR2
    , p6_a18 out nocopy  NUMBER
    , p6_a19 out nocopy  VARCHAR2
    , p6_a20 out nocopy  VARCHAR2
    , p6_a21 out nocopy  VARCHAR2
    , p6_a22 out nocopy  VARCHAR2
    , p6_a23 out nocopy  VARCHAR2
    , p6_a24 out nocopy  VARCHAR2
    , p6_a25 out nocopy  DATE
    , p6_a26 out nocopy  DATE
  )

  as
    ddp_latv_rec okl_leaseapp_template_pvt.latv_rec_type;
    ddx_latv_rec okl_leaseapp_template_pvt.latv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_latv_rec.id := p5_a0;
    ddp_latv_rec.object_version_number := p5_a1;
    ddp_latv_rec.attribute_category := p5_a2;
    ddp_latv_rec.attribute1 := p5_a3;
    ddp_latv_rec.attribute2 := p5_a4;
    ddp_latv_rec.attribute3 := p5_a5;
    ddp_latv_rec.attribute4 := p5_a6;
    ddp_latv_rec.attribute5 := p5_a7;
    ddp_latv_rec.attribute6 := p5_a8;
    ddp_latv_rec.attribute7 := p5_a9;
    ddp_latv_rec.attribute8 := p5_a10;
    ddp_latv_rec.attribute9 := p5_a11;
    ddp_latv_rec.attribute10 := p5_a12;
    ddp_latv_rec.attribute11 := p5_a13;
    ddp_latv_rec.attribute12 := p5_a14;
    ddp_latv_rec.attribute13 := p5_a15;
    ddp_latv_rec.attribute14 := p5_a16;
    ddp_latv_rec.attribute15 := p5_a17;
    ddp_latv_rec.org_id := p5_a18;
    ddp_latv_rec.name := p5_a19;
    ddp_latv_rec.template_status := p5_a20;
    ddp_latv_rec.credit_review_purpose := p5_a21;
    ddp_latv_rec.cust_credit_classification := p5_a22;
    ddp_latv_rec.industry_class := p5_a23;
    ddp_latv_rec.industry_code := p5_a24;
    ddp_latv_rec.valid_from := p5_a25;
    ddp_latv_rec.valid_to := p5_a26;


    -- here's the delegated call to the old PL/SQL routine
    okl_leaseapp_template_pvt.max_valid_from_date(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_latv_rec,
      ddx_latv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := ddx_latv_rec.id;
    p6_a1 := ddx_latv_rec.object_version_number;
    p6_a2 := ddx_latv_rec.attribute_category;
    p6_a3 := ddx_latv_rec.attribute1;
    p6_a4 := ddx_latv_rec.attribute2;
    p6_a5 := ddx_latv_rec.attribute3;
    p6_a6 := ddx_latv_rec.attribute4;
    p6_a7 := ddx_latv_rec.attribute5;
    p6_a8 := ddx_latv_rec.attribute6;
    p6_a9 := ddx_latv_rec.attribute7;
    p6_a10 := ddx_latv_rec.attribute8;
    p6_a11 := ddx_latv_rec.attribute9;
    p6_a12 := ddx_latv_rec.attribute10;
    p6_a13 := ddx_latv_rec.attribute11;
    p6_a14 := ddx_latv_rec.attribute12;
    p6_a15 := ddx_latv_rec.attribute13;
    p6_a16 := ddx_latv_rec.attribute14;
    p6_a17 := ddx_latv_rec.attribute15;
    p6_a18 := ddx_latv_rec.org_id;
    p6_a19 := ddx_latv_rec.name;
    p6_a20 := ddx_latv_rec.template_status;
    p6_a21 := ddx_latv_rec.credit_review_purpose;
    p6_a22 := ddx_latv_rec.cust_credit_classification;
    p6_a23 := ddx_latv_rec.industry_class;
    p6_a24 := ddx_latv_rec.industry_code;
    p6_a25 := ddx_latv_rec.valid_from;
    p6_a26 := ddx_latv_rec.valid_to;
  end;

end okl_leaseapp_template_pvt_w;

/
