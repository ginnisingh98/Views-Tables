--------------------------------------------------------
--  DDL for Package Body OKL_K_RATE_PARAMS_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_K_RATE_PARAMS_PVT_W" as
  /* $Header: OKLUKRPB.pls 120.2 2005/11/22 23:41:07 ramurt noship $ */
  rosetta_g_mistake_date date := to_date('01/01/+4713', 'MM/DD/SYYYY');
  rosetta_g_miss_date date := to_date('01/01/-4712', 'MM/DD/SYYYY');

  -- this is to workaround the JDBC bug regarding IN DATE of value GMiss
  function rosetta_g_miss_date_in_map(d date) return date as
  begin
    if d = rosetta_g_mistake_date then return fnd_api.g_miss_date; end if;
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

  procedure rosetta_table_copy_in_p1(t out nocopy okl_k_rate_params_pvt.krpdel_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_DATE_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).khr_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).rate_type := a1(indx);
          t(ddindx).effective_from_date := rosetta_g_miss_date_in_map(a2(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p1;
  procedure rosetta_table_copy_out_p1(t okl_k_rate_params_pvt.krpdel_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_DATE_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_DATE_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_DATE_TABLE();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).khr_id);
          a1(indx) := t(ddindx).rate_type;
          a2(indx) := t(ddindx).effective_from_date;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p1;

  procedure rosetta_table_copy_in_p6(t out nocopy okl_k_rate_params_pvt.var_prm_tbl_type, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_DATE_TABLE
    , a5 JTF_DATE_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).param_identifier := a0(indx);
          t(ddindx).param_identifier_meaning := a1(indx);
          t(ddindx).parameter_type_code := a2(indx);
          t(ddindx).interest_index_id := rosetta_g_miss_num_map(a3(indx));
          t(ddindx).effective_from_date := rosetta_g_miss_date_in_map(a4(indx));
          t(ddindx).effective_to_date := rosetta_g_miss_date_in_map(a5(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p6;
  procedure rosetta_table_copy_out_p6(t okl_k_rate_params_pvt.var_prm_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_100
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_DATE_TABLE
    , a5 out nocopy JTF_DATE_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_100();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_DATE_TABLE();
    a5 := JTF_DATE_TABLE();
  else
      a0 := JTF_VARCHAR2_TABLE_100();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_DATE_TABLE();
      a5 := JTF_DATE_TABLE();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        a3.extend(t.count);
        a4.extend(t.count);
        a5.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).param_identifier;
          a1(indx) := t(ddindx).param_identifier_meaning;
          a2(indx) := t(ddindx).parameter_type_code;
          a3(indx) := rosetta_g_miss_num_map(t(ddindx).interest_index_id);
          a4(indx) := t(ddindx).effective_from_date;
          a5(indx) := t(ddindx).effective_to_date;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p6;

  procedure get_product(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_khr_id  NUMBER
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  VARCHAR2
    , p6_a2 out nocopy  DATE
    , p6_a3 out nocopy  DATE
    , p6_a4 out nocopy  VARCHAR2
    , p6_a5 out nocopy  NUMBER
    , p6_a6 out nocopy  NUMBER
    , p6_a7 out nocopy  NUMBER
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
    , p6_a18 out nocopy  VARCHAR2
    , p6_a19 out nocopy  VARCHAR2
    , p6_a20 out nocopy  VARCHAR2
    , p6_a21 out nocopy  VARCHAR2
    , p6_a22 out nocopy  VARCHAR2
    , p6_a23 out nocopy  VARCHAR2
    , p6_a24 out nocopy  VARCHAR2
    , p6_a25 out nocopy  VARCHAR2
    , p6_a26 out nocopy  VARCHAR2
    , p6_a27 out nocopy  VARCHAR2
    , p6_a28 out nocopy  VARCHAR2
    , p6_a29 out nocopy  VARCHAR2
    , p6_a30 out nocopy  NUMBER
    , p6_a31 out nocopy  VARCHAR2
  )

  as
    ddx_pdt_parameter_rec okl_setupproducts_pub.pdt_parameters_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    -- here's the delegated call to the old PL/SQL routine
    okl_k_rate_params_pvt.get_product(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_khr_id,
      ddx_pdt_parameter_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_pdt_parameter_rec.id);
    p6_a1 := ddx_pdt_parameter_rec.name;
    p6_a2 := ddx_pdt_parameter_rec.from_date;
    p6_a3 := ddx_pdt_parameter_rec.to_date;
    p6_a4 := ddx_pdt_parameter_rec.version;
    p6_a5 := rosetta_g_miss_num_map(ddx_pdt_parameter_rec.object_version_number);
    p6_a6 := rosetta_g_miss_num_map(ddx_pdt_parameter_rec.aes_id);
    p6_a7 := rosetta_g_miss_num_map(ddx_pdt_parameter_rec.ptl_id);
    p6_a8 := ddx_pdt_parameter_rec.legacy_product_yn;
    p6_a9 := ddx_pdt_parameter_rec.attribute_category;
    p6_a10 := ddx_pdt_parameter_rec.attribute1;
    p6_a11 := ddx_pdt_parameter_rec.attribute2;
    p6_a12 := ddx_pdt_parameter_rec.attribute3;
    p6_a13 := ddx_pdt_parameter_rec.attribute4;
    p6_a14 := ddx_pdt_parameter_rec.attribute5;
    p6_a15 := ddx_pdt_parameter_rec.attribute6;
    p6_a16 := ddx_pdt_parameter_rec.attribute7;
    p6_a17 := ddx_pdt_parameter_rec.attribute8;
    p6_a18 := ddx_pdt_parameter_rec.attribute9;
    p6_a19 := ddx_pdt_parameter_rec.attribute10;
    p6_a20 := ddx_pdt_parameter_rec.attribute11;
    p6_a21 := ddx_pdt_parameter_rec.attribute12;
    p6_a22 := ddx_pdt_parameter_rec.attribute13;
    p6_a23 := ddx_pdt_parameter_rec.attribute14;
    p6_a24 := ddx_pdt_parameter_rec.attribute15;
    p6_a25 := ddx_pdt_parameter_rec.product_subclass;
    p6_a26 := ddx_pdt_parameter_rec.deal_type;
    p6_a27 := ddx_pdt_parameter_rec.tax_owner;
    p6_a28 := ddx_pdt_parameter_rec.revenue_recognition_method;
    p6_a29 := ddx_pdt_parameter_rec.interest_calculation_basis;
    p6_a30 := rosetta_g_miss_num_map(ddx_pdt_parameter_rec.reporting_pdt_id);
    p6_a31 := ddx_pdt_parameter_rec.reporting_product;
  end;

  procedure create_k_rate_params(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  VARCHAR2
    , p6_a2 out nocopy  DATE
    , p6_a3 out nocopy  DATE
    , p6_a4 out nocopy  NUMBER
    , p6_a5 out nocopy  NUMBER
    , p6_a6 out nocopy  DATE
    , p6_a7 out nocopy  NUMBER
    , p6_a8 out nocopy  NUMBER
    , p6_a9 out nocopy  NUMBER
    , p6_a10 out nocopy  VARCHAR2
    , p6_a11 out nocopy  VARCHAR2
    , p6_a12 out nocopy  VARCHAR2
    , p6_a13 out nocopy  VARCHAR2
    , p6_a14 out nocopy  VARCHAR2
    , p6_a15 out nocopy  NUMBER
    , p6_a16 out nocopy  VARCHAR2
    , p6_a17 out nocopy  NUMBER
    , p6_a18 out nocopy  VARCHAR2
    , p6_a19 out nocopy  DATE
    , p6_a20 out nocopy  VARCHAR2
    , p6_a21 out nocopy  DATE
    , p6_a22 out nocopy  VARCHAR2
    , p6_a23 out nocopy  NUMBER
    , p6_a24 out nocopy  VARCHAR2
    , p6_a25 out nocopy  DATE
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
    , p6_a37 out nocopy  VARCHAR2
    , p6_a38 out nocopy  VARCHAR2
    , p6_a39 out nocopy  VARCHAR2
    , p6_a40 out nocopy  VARCHAR2
    , p6_a41 out nocopy  VARCHAR2
    , p6_a42 out nocopy  VARCHAR2
    , p6_a43 out nocopy  NUMBER
    , p6_a44 out nocopy  DATE
    , p6_a45 out nocopy  NUMBER
    , p6_a46 out nocopy  DATE
    , p6_a47 out nocopy  NUMBER
    , p6_a48 out nocopy  VARCHAR2
    , p_validate_flag  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  VARCHAR2 := fnd_api.g_miss_char
    , p5_a2  DATE := fnd_api.g_miss_date
    , p5_a3  DATE := fnd_api.g_miss_date
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  DATE := fnd_api.g_miss_date
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  VARCHAR2 := fnd_api.g_miss_char
    , p5_a11  VARCHAR2 := fnd_api.g_miss_char
    , p5_a12  VARCHAR2 := fnd_api.g_miss_char
    , p5_a13  VARCHAR2 := fnd_api.g_miss_char
    , p5_a14  VARCHAR2 := fnd_api.g_miss_char
    , p5_a15  NUMBER := 0-1962.0724
    , p5_a16  VARCHAR2 := fnd_api.g_miss_char
    , p5_a17  NUMBER := 0-1962.0724
    , p5_a18  VARCHAR2 := fnd_api.g_miss_char
    , p5_a19  DATE := fnd_api.g_miss_date
    , p5_a20  VARCHAR2 := fnd_api.g_miss_char
    , p5_a21  DATE := fnd_api.g_miss_date
    , p5_a22  VARCHAR2 := fnd_api.g_miss_char
    , p5_a23  NUMBER := 0-1962.0724
    , p5_a24  VARCHAR2 := fnd_api.g_miss_char
    , p5_a25  DATE := fnd_api.g_miss_date
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
    , p5_a37  VARCHAR2 := fnd_api.g_miss_char
    , p5_a38  VARCHAR2 := fnd_api.g_miss_char
    , p5_a39  VARCHAR2 := fnd_api.g_miss_char
    , p5_a40  VARCHAR2 := fnd_api.g_miss_char
    , p5_a41  VARCHAR2 := fnd_api.g_miss_char
    , p5_a42  VARCHAR2 := fnd_api.g_miss_char
    , p5_a43  NUMBER := 0-1962.0724
    , p5_a44  DATE := fnd_api.g_miss_date
    , p5_a45  NUMBER := 0-1962.0724
    , p5_a46  DATE := fnd_api.g_miss_date
    , p5_a47  NUMBER := 0-1962.0724
    , p5_a48  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_krpv_rec okl_k_rate_params_pvt.krpv_rec_type;
    ddx_krpv_rec okl_k_rate_params_pvt.krpv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_krpv_rec.khr_id := rosetta_g_miss_num_map(p5_a0);
    ddp_krpv_rec.parameter_type_code := p5_a1;
    ddp_krpv_rec.effective_from_date := rosetta_g_miss_date_in_map(p5_a2);
    ddp_krpv_rec.effective_to_date := rosetta_g_miss_date_in_map(p5_a3);
    ddp_krpv_rec.interest_index_id := rosetta_g_miss_num_map(p5_a4);
    ddp_krpv_rec.base_rate := rosetta_g_miss_num_map(p5_a5);
    ddp_krpv_rec.interest_start_date := rosetta_g_miss_date_in_map(p5_a6);
    ddp_krpv_rec.adder_rate := rosetta_g_miss_num_map(p5_a7);
    ddp_krpv_rec.maximum_rate := rosetta_g_miss_num_map(p5_a8);
    ddp_krpv_rec.minimum_rate := rosetta_g_miss_num_map(p5_a9);
    ddp_krpv_rec.principal_basis_code := p5_a10;
    ddp_krpv_rec.days_in_a_month_code := p5_a11;
    ddp_krpv_rec.days_in_a_year_code := p5_a12;
    ddp_krpv_rec.interest_basis_code := p5_a13;
    ddp_krpv_rec.rate_delay_code := p5_a14;
    ddp_krpv_rec.rate_delay_frequency := rosetta_g_miss_num_map(p5_a15);
    ddp_krpv_rec.compounding_frequency_code := p5_a16;
    ddp_krpv_rec.calculation_formula_id := rosetta_g_miss_num_map(p5_a17);
    ddp_krpv_rec.catchup_basis_code := p5_a18;
    ddp_krpv_rec.catchup_start_date := rosetta_g_miss_date_in_map(p5_a19);
    ddp_krpv_rec.catchup_settlement_code := p5_a20;
    ddp_krpv_rec.rate_change_start_date := rosetta_g_miss_date_in_map(p5_a21);
    ddp_krpv_rec.rate_change_frequency_code := p5_a22;
    ddp_krpv_rec.rate_change_value := rosetta_g_miss_num_map(p5_a23);
    ddp_krpv_rec.conversion_option_code := p5_a24;
    ddp_krpv_rec.next_conversion_date := rosetta_g_miss_date_in_map(p5_a25);
    ddp_krpv_rec.conversion_type_code := p5_a26;
    ddp_krpv_rec.attribute_category := p5_a27;
    ddp_krpv_rec.attribute1 := p5_a28;
    ddp_krpv_rec.attribute2 := p5_a29;
    ddp_krpv_rec.attribute3 := p5_a30;
    ddp_krpv_rec.attribute4 := p5_a31;
    ddp_krpv_rec.attribute5 := p5_a32;
    ddp_krpv_rec.attribute6 := p5_a33;
    ddp_krpv_rec.attribute7 := p5_a34;
    ddp_krpv_rec.attribute8 := p5_a35;
    ddp_krpv_rec.attribute9 := p5_a36;
    ddp_krpv_rec.attribute10 := p5_a37;
    ddp_krpv_rec.attribute11 := p5_a38;
    ddp_krpv_rec.attribute12 := p5_a39;
    ddp_krpv_rec.attribute13 := p5_a40;
    ddp_krpv_rec.attribute14 := p5_a41;
    ddp_krpv_rec.attribute15 := p5_a42;
    ddp_krpv_rec.created_by := rosetta_g_miss_num_map(p5_a43);
    ddp_krpv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a44);
    ddp_krpv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a45);
    ddp_krpv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a46);
    ddp_krpv_rec.last_update_login := rosetta_g_miss_num_map(p5_a47);
    ddp_krpv_rec.catchup_frequency_code := p5_a48;



    -- here's the delegated call to the old PL/SQL routine
    okl_k_rate_params_pvt.create_k_rate_params(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_krpv_rec,
      ddx_krpv_rec,
      p_validate_flag);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_krpv_rec.khr_id);
    p6_a1 := ddx_krpv_rec.parameter_type_code;
    p6_a2 := ddx_krpv_rec.effective_from_date;
    p6_a3 := ddx_krpv_rec.effective_to_date;
    p6_a4 := rosetta_g_miss_num_map(ddx_krpv_rec.interest_index_id);
    p6_a5 := rosetta_g_miss_num_map(ddx_krpv_rec.base_rate);
    p6_a6 := ddx_krpv_rec.interest_start_date;
    p6_a7 := rosetta_g_miss_num_map(ddx_krpv_rec.adder_rate);
    p6_a8 := rosetta_g_miss_num_map(ddx_krpv_rec.maximum_rate);
    p6_a9 := rosetta_g_miss_num_map(ddx_krpv_rec.minimum_rate);
    p6_a10 := ddx_krpv_rec.principal_basis_code;
    p6_a11 := ddx_krpv_rec.days_in_a_month_code;
    p6_a12 := ddx_krpv_rec.days_in_a_year_code;
    p6_a13 := ddx_krpv_rec.interest_basis_code;
    p6_a14 := ddx_krpv_rec.rate_delay_code;
    p6_a15 := rosetta_g_miss_num_map(ddx_krpv_rec.rate_delay_frequency);
    p6_a16 := ddx_krpv_rec.compounding_frequency_code;
    p6_a17 := rosetta_g_miss_num_map(ddx_krpv_rec.calculation_formula_id);
    p6_a18 := ddx_krpv_rec.catchup_basis_code;
    p6_a19 := ddx_krpv_rec.catchup_start_date;
    p6_a20 := ddx_krpv_rec.catchup_settlement_code;
    p6_a21 := ddx_krpv_rec.rate_change_start_date;
    p6_a22 := ddx_krpv_rec.rate_change_frequency_code;
    p6_a23 := rosetta_g_miss_num_map(ddx_krpv_rec.rate_change_value);
    p6_a24 := ddx_krpv_rec.conversion_option_code;
    p6_a25 := ddx_krpv_rec.next_conversion_date;
    p6_a26 := ddx_krpv_rec.conversion_type_code;
    p6_a27 := ddx_krpv_rec.attribute_category;
    p6_a28 := ddx_krpv_rec.attribute1;
    p6_a29 := ddx_krpv_rec.attribute2;
    p6_a30 := ddx_krpv_rec.attribute3;
    p6_a31 := ddx_krpv_rec.attribute4;
    p6_a32 := ddx_krpv_rec.attribute5;
    p6_a33 := ddx_krpv_rec.attribute6;
    p6_a34 := ddx_krpv_rec.attribute7;
    p6_a35 := ddx_krpv_rec.attribute8;
    p6_a36 := ddx_krpv_rec.attribute9;
    p6_a37 := ddx_krpv_rec.attribute10;
    p6_a38 := ddx_krpv_rec.attribute11;
    p6_a39 := ddx_krpv_rec.attribute12;
    p6_a40 := ddx_krpv_rec.attribute13;
    p6_a41 := ddx_krpv_rec.attribute14;
    p6_a42 := ddx_krpv_rec.attribute15;
    p6_a43 := rosetta_g_miss_num_map(ddx_krpv_rec.created_by);
    p6_a44 := ddx_krpv_rec.creation_date;
    p6_a45 := rosetta_g_miss_num_map(ddx_krpv_rec.last_updated_by);
    p6_a46 := ddx_krpv_rec.last_update_date;
    p6_a47 := rosetta_g_miss_num_map(ddx_krpv_rec.last_update_login);
    p6_a48 := ddx_krpv_rec.catchup_frequency_code;

  end;

  procedure create_k_rate_params(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  VARCHAR2
    , p6_a2 out nocopy  DATE
    , p6_a3 out nocopy  DATE
    , p6_a4 out nocopy  NUMBER
    , p6_a5 out nocopy  NUMBER
    , p6_a6 out nocopy  DATE
    , p6_a7 out nocopy  NUMBER
    , p6_a8 out nocopy  NUMBER
    , p6_a9 out nocopy  NUMBER
    , p6_a10 out nocopy  VARCHAR2
    , p6_a11 out nocopy  VARCHAR2
    , p6_a12 out nocopy  VARCHAR2
    , p6_a13 out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  VARCHAR2 := fnd_api.g_miss_char
    , p5_a2  DATE := fnd_api.g_miss_date
    , p5_a3  DATE := fnd_api.g_miss_date
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  DATE := fnd_api.g_miss_date
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  VARCHAR2 := fnd_api.g_miss_char
    , p5_a11  VARCHAR2 := fnd_api.g_miss_char
    , p5_a12  VARCHAR2 := fnd_api.g_miss_char
    , p5_a13  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_krpr_rec okl_k_rate_params_pvt.krpr_rec_type;
    ddx_krpr_rec okl_k_rate_params_pvt.krpr_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_krpr_rec.khr_id := rosetta_g_miss_num_map(p5_a0);
    ddp_krpr_rec.parameter_type_code := p5_a1;
    ddp_krpr_rec.effective_from_date := rosetta_g_miss_date_in_map(p5_a2);
    ddp_krpr_rec.effective_to_date := rosetta_g_miss_date_in_map(p5_a3);
    ddp_krpr_rec.interest_index_id := rosetta_g_miss_num_map(p5_a4);
    ddp_krpr_rec.base_rate := rosetta_g_miss_num_map(p5_a5);
    ddp_krpr_rec.interest_start_date := rosetta_g_miss_date_in_map(p5_a6);
    ddp_krpr_rec.adder_rate := rosetta_g_miss_num_map(p5_a7);
    ddp_krpr_rec.maximum_rate := rosetta_g_miss_num_map(p5_a8);
    ddp_krpr_rec.minimum_rate := rosetta_g_miss_num_map(p5_a9);
    ddp_krpr_rec.principal_basis_code := p5_a10;
    ddp_krpr_rec.days_in_a_month_code := p5_a11;
    ddp_krpr_rec.days_in_a_year_code := p5_a12;
    ddp_krpr_rec.interest_basis_code := p5_a13;


    -- here's the delegated call to the old PL/SQL routine
    okl_k_rate_params_pvt.create_k_rate_params(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_krpr_rec,
      ddx_krpr_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_krpr_rec.khr_id);
    p6_a1 := ddx_krpr_rec.parameter_type_code;
    p6_a2 := ddx_krpr_rec.effective_from_date;
    p6_a3 := ddx_krpr_rec.effective_to_date;
    p6_a4 := rosetta_g_miss_num_map(ddx_krpr_rec.interest_index_id);
    p6_a5 := rosetta_g_miss_num_map(ddx_krpr_rec.base_rate);
    p6_a6 := ddx_krpr_rec.interest_start_date;
    p6_a7 := rosetta_g_miss_num_map(ddx_krpr_rec.adder_rate);
    p6_a8 := rosetta_g_miss_num_map(ddx_krpr_rec.maximum_rate);
    p6_a9 := rosetta_g_miss_num_map(ddx_krpr_rec.minimum_rate);
    p6_a10 := ddx_krpr_rec.principal_basis_code;
    p6_a11 := ddx_krpr_rec.days_in_a_month_code;
    p6_a12 := ddx_krpr_rec.days_in_a_year_code;
    p6_a13 := ddx_krpr_rec.interest_basis_code;
  end;

  procedure create_k_rate_params(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  VARCHAR2
    , p6_a2 out nocopy  DATE
    , p6_a3 out nocopy  DATE
    , p6_a4 out nocopy  VARCHAR2
    , p6_a5 out nocopy  NUMBER
    , p6_a6 out nocopy  VARCHAR2
    , p6_a7 out nocopy  NUMBER
    , p6_a8 out nocopy  VARCHAR2
    , p6_a9 out nocopy  DATE
    , p6_a10 out nocopy  VARCHAR2
    , p6_a11 out nocopy  DATE
    , p6_a12 out nocopy  VARCHAR2
    , p6_a13 out nocopy  NUMBER
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  VARCHAR2 := fnd_api.g_miss_char
    , p5_a2  DATE := fnd_api.g_miss_date
    , p5_a3  DATE := fnd_api.g_miss_date
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  VARCHAR2 := fnd_api.g_miss_char
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  DATE := fnd_api.g_miss_date
    , p5_a10  VARCHAR2 := fnd_api.g_miss_char
    , p5_a11  DATE := fnd_api.g_miss_date
    , p5_a12  VARCHAR2 := fnd_api.g_miss_char
    , p5_a13  NUMBER := 0-1962.0724
  )

  as
    ddp_krpar_rec okl_k_rate_params_pvt.krpar_rec_type;
    ddx_krpar_rec okl_k_rate_params_pvt.krpar_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_krpar_rec.khr_id := rosetta_g_miss_num_map(p5_a0);
    ddp_krpar_rec.parameter_type_code := p5_a1;
    ddp_krpar_rec.effective_from_date := rosetta_g_miss_date_in_map(p5_a2);
    ddp_krpar_rec.effective_to_date := rosetta_g_miss_date_in_map(p5_a3);
    ddp_krpar_rec.rate_delay_code := p5_a4;
    ddp_krpar_rec.rate_delay_frequency := rosetta_g_miss_num_map(p5_a5);
    ddp_krpar_rec.compounding_frequency_code := p5_a6;
    ddp_krpar_rec.calculation_formula_id := rosetta_g_miss_num_map(p5_a7);
    ddp_krpar_rec.catchup_basis_code := p5_a8;
    ddp_krpar_rec.catchup_start_date := rosetta_g_miss_date_in_map(p5_a9);
    ddp_krpar_rec.catchup_settlement_code := p5_a10;
    ddp_krpar_rec.rate_change_start_date := rosetta_g_miss_date_in_map(p5_a11);
    ddp_krpar_rec.rate_change_frequency_code := p5_a12;
    ddp_krpar_rec.rate_change_value := rosetta_g_miss_num_map(p5_a13);


    -- here's the delegated call to the old PL/SQL routine
    okl_k_rate_params_pvt.create_k_rate_params(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_krpar_rec,
      ddx_krpar_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_krpar_rec.khr_id);
    p6_a1 := ddx_krpar_rec.parameter_type_code;
    p6_a2 := ddx_krpar_rec.effective_from_date;
    p6_a3 := ddx_krpar_rec.effective_to_date;
    p6_a4 := ddx_krpar_rec.rate_delay_code;
    p6_a5 := rosetta_g_miss_num_map(ddx_krpar_rec.rate_delay_frequency);
    p6_a6 := ddx_krpar_rec.compounding_frequency_code;
    p6_a7 := rosetta_g_miss_num_map(ddx_krpar_rec.calculation_formula_id);
    p6_a8 := ddx_krpar_rec.catchup_basis_code;
    p6_a9 := ddx_krpar_rec.catchup_start_date;
    p6_a10 := ddx_krpar_rec.catchup_settlement_code;
    p6_a11 := ddx_krpar_rec.rate_change_start_date;
    p6_a12 := ddx_krpar_rec.rate_change_frequency_code;
    p6_a13 := rosetta_g_miss_num_map(ddx_krpar_rec.rate_change_value);
  end;

  procedure create_k_rate_params(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  VARCHAR2
    , p6_a2 out nocopy  DATE
    , p6_a3 out nocopy  DATE
    , p6_a4 out nocopy  VARCHAR2
    , p6_a5 out nocopy  DATE
    , p6_a6 out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  VARCHAR2 := fnd_api.g_miss_char
    , p5_a2  DATE := fnd_api.g_miss_date
    , p5_a3  DATE := fnd_api.g_miss_date
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  DATE := fnd_api.g_miss_date
    , p5_a6  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_krpc_rec okl_k_rate_params_pvt.krpc_rec_type;
    ddx_krpc_rec okl_k_rate_params_pvt.krpc_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_krpc_rec.khr_id := rosetta_g_miss_num_map(p5_a0);
    ddp_krpc_rec.parameter_type_code := p5_a1;
    ddp_krpc_rec.effective_from_date := rosetta_g_miss_date_in_map(p5_a2);
    ddp_krpc_rec.effective_to_date := rosetta_g_miss_date_in_map(p5_a3);
    ddp_krpc_rec.conversion_option_code := p5_a4;
    ddp_krpc_rec.next_conversion_date := rosetta_g_miss_date_in_map(p5_a5);
    ddp_krpc_rec.conversion_type_code := p5_a6;


    -- here's the delegated call to the old PL/SQL routine
    okl_k_rate_params_pvt.create_k_rate_params(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_krpc_rec,
      ddx_krpc_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_krpc_rec.khr_id);
    p6_a1 := ddx_krpc_rec.parameter_type_code;
    p6_a2 := ddx_krpc_rec.effective_from_date;
    p6_a3 := ddx_krpc_rec.effective_to_date;
    p6_a4 := ddx_krpc_rec.conversion_option_code;
    p6_a5 := ddx_krpc_rec.next_conversion_date;
    p6_a6 := ddx_krpc_rec.conversion_type_code;
  end;

  procedure update_k_rate_params(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  VARCHAR2
    , p6_a2 out nocopy  DATE
    , p6_a3 out nocopy  DATE
    , p6_a4 out nocopy  NUMBER
    , p6_a5 out nocopy  NUMBER
    , p6_a6 out nocopy  DATE
    , p6_a7 out nocopy  NUMBER
    , p6_a8 out nocopy  NUMBER
    , p6_a9 out nocopy  NUMBER
    , p6_a10 out nocopy  VARCHAR2
    , p6_a11 out nocopy  VARCHAR2
    , p6_a12 out nocopy  VARCHAR2
    , p6_a13 out nocopy  VARCHAR2
    , p6_a14 out nocopy  VARCHAR2
    , p6_a15 out nocopy  NUMBER
    , p6_a16 out nocopy  VARCHAR2
    , p6_a17 out nocopy  NUMBER
    , p6_a18 out nocopy  VARCHAR2
    , p6_a19 out nocopy  DATE
    , p6_a20 out nocopy  VARCHAR2
    , p6_a21 out nocopy  DATE
    , p6_a22 out nocopy  VARCHAR2
    , p6_a23 out nocopy  NUMBER
    , p6_a24 out nocopy  VARCHAR2
    , p6_a25 out nocopy  DATE
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
    , p6_a37 out nocopy  VARCHAR2
    , p6_a38 out nocopy  VARCHAR2
    , p6_a39 out nocopy  VARCHAR2
    , p6_a40 out nocopy  VARCHAR2
    , p6_a41 out nocopy  VARCHAR2
    , p6_a42 out nocopy  VARCHAR2
    , p6_a43 out nocopy  NUMBER
    , p6_a44 out nocopy  DATE
    , p6_a45 out nocopy  NUMBER
    , p6_a46 out nocopy  DATE
    , p6_a47 out nocopy  NUMBER
    , p6_a48 out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  VARCHAR2 := fnd_api.g_miss_char
    , p5_a2  DATE := fnd_api.g_miss_date
    , p5_a3  DATE := fnd_api.g_miss_date
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  DATE := fnd_api.g_miss_date
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  VARCHAR2 := fnd_api.g_miss_char
    , p5_a11  VARCHAR2 := fnd_api.g_miss_char
    , p5_a12  VARCHAR2 := fnd_api.g_miss_char
    , p5_a13  VARCHAR2 := fnd_api.g_miss_char
    , p5_a14  VARCHAR2 := fnd_api.g_miss_char
    , p5_a15  NUMBER := 0-1962.0724
    , p5_a16  VARCHAR2 := fnd_api.g_miss_char
    , p5_a17  NUMBER := 0-1962.0724
    , p5_a18  VARCHAR2 := fnd_api.g_miss_char
    , p5_a19  DATE := fnd_api.g_miss_date
    , p5_a20  VARCHAR2 := fnd_api.g_miss_char
    , p5_a21  DATE := fnd_api.g_miss_date
    , p5_a22  VARCHAR2 := fnd_api.g_miss_char
    , p5_a23  NUMBER := 0-1962.0724
    , p5_a24  VARCHAR2 := fnd_api.g_miss_char
    , p5_a25  DATE := fnd_api.g_miss_date
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
    , p5_a37  VARCHAR2 := fnd_api.g_miss_char
    , p5_a38  VARCHAR2 := fnd_api.g_miss_char
    , p5_a39  VARCHAR2 := fnd_api.g_miss_char
    , p5_a40  VARCHAR2 := fnd_api.g_miss_char
    , p5_a41  VARCHAR2 := fnd_api.g_miss_char
    , p5_a42  VARCHAR2 := fnd_api.g_miss_char
    , p5_a43  NUMBER := 0-1962.0724
    , p5_a44  DATE := fnd_api.g_miss_date
    , p5_a45  NUMBER := 0-1962.0724
    , p5_a46  DATE := fnd_api.g_miss_date
    , p5_a47  NUMBER := 0-1962.0724
    , p5_a48  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_krpv_rec okl_k_rate_params_pvt.krpv_rec_type;
    ddx_krpv_rec okl_k_rate_params_pvt.krpv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_krpv_rec.khr_id := rosetta_g_miss_num_map(p5_a0);
    ddp_krpv_rec.parameter_type_code := p5_a1;
    ddp_krpv_rec.effective_from_date := rosetta_g_miss_date_in_map(p5_a2);
    ddp_krpv_rec.effective_to_date := rosetta_g_miss_date_in_map(p5_a3);
    ddp_krpv_rec.interest_index_id := rosetta_g_miss_num_map(p5_a4);
    ddp_krpv_rec.base_rate := rosetta_g_miss_num_map(p5_a5);
    ddp_krpv_rec.interest_start_date := rosetta_g_miss_date_in_map(p5_a6);
    ddp_krpv_rec.adder_rate := rosetta_g_miss_num_map(p5_a7);
    ddp_krpv_rec.maximum_rate := rosetta_g_miss_num_map(p5_a8);
    ddp_krpv_rec.minimum_rate := rosetta_g_miss_num_map(p5_a9);
    ddp_krpv_rec.principal_basis_code := p5_a10;
    ddp_krpv_rec.days_in_a_month_code := p5_a11;
    ddp_krpv_rec.days_in_a_year_code := p5_a12;
    ddp_krpv_rec.interest_basis_code := p5_a13;
    ddp_krpv_rec.rate_delay_code := p5_a14;
    ddp_krpv_rec.rate_delay_frequency := rosetta_g_miss_num_map(p5_a15);
    ddp_krpv_rec.compounding_frequency_code := p5_a16;
    ddp_krpv_rec.calculation_formula_id := rosetta_g_miss_num_map(p5_a17);
    ddp_krpv_rec.catchup_basis_code := p5_a18;
    ddp_krpv_rec.catchup_start_date := rosetta_g_miss_date_in_map(p5_a19);
    ddp_krpv_rec.catchup_settlement_code := p5_a20;
    ddp_krpv_rec.rate_change_start_date := rosetta_g_miss_date_in_map(p5_a21);
    ddp_krpv_rec.rate_change_frequency_code := p5_a22;
    ddp_krpv_rec.rate_change_value := rosetta_g_miss_num_map(p5_a23);
    ddp_krpv_rec.conversion_option_code := p5_a24;
    ddp_krpv_rec.next_conversion_date := rosetta_g_miss_date_in_map(p5_a25);
    ddp_krpv_rec.conversion_type_code := p5_a26;
    ddp_krpv_rec.attribute_category := p5_a27;
    ddp_krpv_rec.attribute1 := p5_a28;
    ddp_krpv_rec.attribute2 := p5_a29;
    ddp_krpv_rec.attribute3 := p5_a30;
    ddp_krpv_rec.attribute4 := p5_a31;
    ddp_krpv_rec.attribute5 := p5_a32;
    ddp_krpv_rec.attribute6 := p5_a33;
    ddp_krpv_rec.attribute7 := p5_a34;
    ddp_krpv_rec.attribute8 := p5_a35;
    ddp_krpv_rec.attribute9 := p5_a36;
    ddp_krpv_rec.attribute10 := p5_a37;
    ddp_krpv_rec.attribute11 := p5_a38;
    ddp_krpv_rec.attribute12 := p5_a39;
    ddp_krpv_rec.attribute13 := p5_a40;
    ddp_krpv_rec.attribute14 := p5_a41;
    ddp_krpv_rec.attribute15 := p5_a42;
    ddp_krpv_rec.created_by := rosetta_g_miss_num_map(p5_a43);
    ddp_krpv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a44);
    ddp_krpv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a45);
    ddp_krpv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a46);
    ddp_krpv_rec.last_update_login := rosetta_g_miss_num_map(p5_a47);
    ddp_krpv_rec.catchup_frequency_code := p5_a48;


    -- here's the delegated call to the old PL/SQL routine
    okl_k_rate_params_pvt.update_k_rate_params(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_krpv_rec,
      ddx_krpv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_krpv_rec.khr_id);
    p6_a1 := ddx_krpv_rec.parameter_type_code;
    p6_a2 := ddx_krpv_rec.effective_from_date;
    p6_a3 := ddx_krpv_rec.effective_to_date;
    p6_a4 := rosetta_g_miss_num_map(ddx_krpv_rec.interest_index_id);
    p6_a5 := rosetta_g_miss_num_map(ddx_krpv_rec.base_rate);
    p6_a6 := ddx_krpv_rec.interest_start_date;
    p6_a7 := rosetta_g_miss_num_map(ddx_krpv_rec.adder_rate);
    p6_a8 := rosetta_g_miss_num_map(ddx_krpv_rec.maximum_rate);
    p6_a9 := rosetta_g_miss_num_map(ddx_krpv_rec.minimum_rate);
    p6_a10 := ddx_krpv_rec.principal_basis_code;
    p6_a11 := ddx_krpv_rec.days_in_a_month_code;
    p6_a12 := ddx_krpv_rec.days_in_a_year_code;
    p6_a13 := ddx_krpv_rec.interest_basis_code;
    p6_a14 := ddx_krpv_rec.rate_delay_code;
    p6_a15 := rosetta_g_miss_num_map(ddx_krpv_rec.rate_delay_frequency);
    p6_a16 := ddx_krpv_rec.compounding_frequency_code;
    p6_a17 := rosetta_g_miss_num_map(ddx_krpv_rec.calculation_formula_id);
    p6_a18 := ddx_krpv_rec.catchup_basis_code;
    p6_a19 := ddx_krpv_rec.catchup_start_date;
    p6_a20 := ddx_krpv_rec.catchup_settlement_code;
    p6_a21 := ddx_krpv_rec.rate_change_start_date;
    p6_a22 := ddx_krpv_rec.rate_change_frequency_code;
    p6_a23 := rosetta_g_miss_num_map(ddx_krpv_rec.rate_change_value);
    p6_a24 := ddx_krpv_rec.conversion_option_code;
    p6_a25 := ddx_krpv_rec.next_conversion_date;
    p6_a26 := ddx_krpv_rec.conversion_type_code;
    p6_a27 := ddx_krpv_rec.attribute_category;
    p6_a28 := ddx_krpv_rec.attribute1;
    p6_a29 := ddx_krpv_rec.attribute2;
    p6_a30 := ddx_krpv_rec.attribute3;
    p6_a31 := ddx_krpv_rec.attribute4;
    p6_a32 := ddx_krpv_rec.attribute5;
    p6_a33 := ddx_krpv_rec.attribute6;
    p6_a34 := ddx_krpv_rec.attribute7;
    p6_a35 := ddx_krpv_rec.attribute8;
    p6_a36 := ddx_krpv_rec.attribute9;
    p6_a37 := ddx_krpv_rec.attribute10;
    p6_a38 := ddx_krpv_rec.attribute11;
    p6_a39 := ddx_krpv_rec.attribute12;
    p6_a40 := ddx_krpv_rec.attribute13;
    p6_a41 := ddx_krpv_rec.attribute14;
    p6_a42 := ddx_krpv_rec.attribute15;
    p6_a43 := rosetta_g_miss_num_map(ddx_krpv_rec.created_by);
    p6_a44 := ddx_krpv_rec.creation_date;
    p6_a45 := rosetta_g_miss_num_map(ddx_krpv_rec.last_updated_by);
    p6_a46 := ddx_krpv_rec.last_update_date;
    p6_a47 := rosetta_g_miss_num_map(ddx_krpv_rec.last_update_login);
    p6_a48 := ddx_krpv_rec.catchup_frequency_code;
  end;

  procedure update_k_rate_params(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  VARCHAR2
    , p6_a2 out nocopy  DATE
    , p6_a3 out nocopy  DATE
    , p6_a4 out nocopy  NUMBER
    , p6_a5 out nocopy  NUMBER
    , p6_a6 out nocopy  DATE
    , p6_a7 out nocopy  NUMBER
    , p6_a8 out nocopy  NUMBER
    , p6_a9 out nocopy  NUMBER
    , p6_a10 out nocopy  VARCHAR2
    , p6_a11 out nocopy  VARCHAR2
    , p6_a12 out nocopy  VARCHAR2
    , p6_a13 out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  VARCHAR2 := fnd_api.g_miss_char
    , p5_a2  DATE := fnd_api.g_miss_date
    , p5_a3  DATE := fnd_api.g_miss_date
    , p5_a4  NUMBER := 0-1962.0724
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  DATE := fnd_api.g_miss_date
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  NUMBER := 0-1962.0724
    , p5_a9  NUMBER := 0-1962.0724
    , p5_a10  VARCHAR2 := fnd_api.g_miss_char
    , p5_a11  VARCHAR2 := fnd_api.g_miss_char
    , p5_a12  VARCHAR2 := fnd_api.g_miss_char
    , p5_a13  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_krpr_rec okl_k_rate_params_pvt.krpr_rec_type;
    ddx_krpr_rec okl_k_rate_params_pvt.krpr_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_krpr_rec.khr_id := rosetta_g_miss_num_map(p5_a0);
    ddp_krpr_rec.parameter_type_code := p5_a1;
    ddp_krpr_rec.effective_from_date := rosetta_g_miss_date_in_map(p5_a2);
    ddp_krpr_rec.effective_to_date := rosetta_g_miss_date_in_map(p5_a3);
    ddp_krpr_rec.interest_index_id := rosetta_g_miss_num_map(p5_a4);
    ddp_krpr_rec.base_rate := rosetta_g_miss_num_map(p5_a5);
    ddp_krpr_rec.interest_start_date := rosetta_g_miss_date_in_map(p5_a6);
    ddp_krpr_rec.adder_rate := rosetta_g_miss_num_map(p5_a7);
    ddp_krpr_rec.maximum_rate := rosetta_g_miss_num_map(p5_a8);
    ddp_krpr_rec.minimum_rate := rosetta_g_miss_num_map(p5_a9);
    ddp_krpr_rec.principal_basis_code := p5_a10;
    ddp_krpr_rec.days_in_a_month_code := p5_a11;
    ddp_krpr_rec.days_in_a_year_code := p5_a12;
    ddp_krpr_rec.interest_basis_code := p5_a13;


    -- here's the delegated call to the old PL/SQL routine
    okl_k_rate_params_pvt.update_k_rate_params(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_krpr_rec,
      ddx_krpr_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_krpr_rec.khr_id);
    p6_a1 := ddx_krpr_rec.parameter_type_code;
    p6_a2 := ddx_krpr_rec.effective_from_date;
    p6_a3 := ddx_krpr_rec.effective_to_date;
    p6_a4 := rosetta_g_miss_num_map(ddx_krpr_rec.interest_index_id);
    p6_a5 := rosetta_g_miss_num_map(ddx_krpr_rec.base_rate);
    p6_a6 := ddx_krpr_rec.interest_start_date;
    p6_a7 := rosetta_g_miss_num_map(ddx_krpr_rec.adder_rate);
    p6_a8 := rosetta_g_miss_num_map(ddx_krpr_rec.maximum_rate);
    p6_a9 := rosetta_g_miss_num_map(ddx_krpr_rec.minimum_rate);
    p6_a10 := ddx_krpr_rec.principal_basis_code;
    p6_a11 := ddx_krpr_rec.days_in_a_month_code;
    p6_a12 := ddx_krpr_rec.days_in_a_year_code;
    p6_a13 := ddx_krpr_rec.interest_basis_code;
  end;

  procedure update_k_rate_params(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  VARCHAR2
    , p6_a2 out nocopy  DATE
    , p6_a3 out nocopy  DATE
    , p6_a4 out nocopy  VARCHAR2
    , p6_a5 out nocopy  NUMBER
    , p6_a6 out nocopy  VARCHAR2
    , p6_a7 out nocopy  NUMBER
    , p6_a8 out nocopy  VARCHAR2
    , p6_a9 out nocopy  DATE
    , p6_a10 out nocopy  VARCHAR2
    , p6_a11 out nocopy  DATE
    , p6_a12 out nocopy  VARCHAR2
    , p6_a13 out nocopy  NUMBER
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  VARCHAR2 := fnd_api.g_miss_char
    , p5_a2  DATE := fnd_api.g_miss_date
    , p5_a3  DATE := fnd_api.g_miss_date
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  VARCHAR2 := fnd_api.g_miss_char
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  DATE := fnd_api.g_miss_date
    , p5_a10  VARCHAR2 := fnd_api.g_miss_char
    , p5_a11  DATE := fnd_api.g_miss_date
    , p5_a12  VARCHAR2 := fnd_api.g_miss_char
    , p5_a13  NUMBER := 0-1962.0724
  )

  as
    ddp_krpar_rec okl_k_rate_params_pvt.krpar_rec_type;
    ddx_krpar_rec okl_k_rate_params_pvt.krpar_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_krpar_rec.khr_id := rosetta_g_miss_num_map(p5_a0);
    ddp_krpar_rec.parameter_type_code := p5_a1;
    ddp_krpar_rec.effective_from_date := rosetta_g_miss_date_in_map(p5_a2);
    ddp_krpar_rec.effective_to_date := rosetta_g_miss_date_in_map(p5_a3);
    ddp_krpar_rec.rate_delay_code := p5_a4;
    ddp_krpar_rec.rate_delay_frequency := rosetta_g_miss_num_map(p5_a5);
    ddp_krpar_rec.compounding_frequency_code := p5_a6;
    ddp_krpar_rec.calculation_formula_id := rosetta_g_miss_num_map(p5_a7);
    ddp_krpar_rec.catchup_basis_code := p5_a8;
    ddp_krpar_rec.catchup_start_date := rosetta_g_miss_date_in_map(p5_a9);
    ddp_krpar_rec.catchup_settlement_code := p5_a10;
    ddp_krpar_rec.rate_change_start_date := rosetta_g_miss_date_in_map(p5_a11);
    ddp_krpar_rec.rate_change_frequency_code := p5_a12;
    ddp_krpar_rec.rate_change_value := rosetta_g_miss_num_map(p5_a13);


    -- here's the delegated call to the old PL/SQL routine
    okl_k_rate_params_pvt.update_k_rate_params(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_krpar_rec,
      ddx_krpar_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_krpar_rec.khr_id);
    p6_a1 := ddx_krpar_rec.parameter_type_code;
    p6_a2 := ddx_krpar_rec.effective_from_date;
    p6_a3 := ddx_krpar_rec.effective_to_date;
    p6_a4 := ddx_krpar_rec.rate_delay_code;
    p6_a5 := rosetta_g_miss_num_map(ddx_krpar_rec.rate_delay_frequency);
    p6_a6 := ddx_krpar_rec.compounding_frequency_code;
    p6_a7 := rosetta_g_miss_num_map(ddx_krpar_rec.calculation_formula_id);
    p6_a8 := ddx_krpar_rec.catchup_basis_code;
    p6_a9 := ddx_krpar_rec.catchup_start_date;
    p6_a10 := ddx_krpar_rec.catchup_settlement_code;
    p6_a11 := ddx_krpar_rec.rate_change_start_date;
    p6_a12 := ddx_krpar_rec.rate_change_frequency_code;
    p6_a13 := rosetta_g_miss_num_map(ddx_krpar_rec.rate_change_value);
  end;

  procedure update_k_rate_params(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  VARCHAR2
    , p6_a2 out nocopy  DATE
    , p6_a3 out nocopy  DATE
    , p6_a4 out nocopy  VARCHAR2
    , p6_a5 out nocopy  DATE
    , p6_a6 out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  VARCHAR2 := fnd_api.g_miss_char
    , p5_a2  DATE := fnd_api.g_miss_date
    , p5_a3  DATE := fnd_api.g_miss_date
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  DATE := fnd_api.g_miss_date
    , p5_a6  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_krpc_rec okl_k_rate_params_pvt.krpc_rec_type;
    ddx_krpc_rec okl_k_rate_params_pvt.krpc_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_krpc_rec.khr_id := rosetta_g_miss_num_map(p5_a0);
    ddp_krpc_rec.parameter_type_code := p5_a1;
    ddp_krpc_rec.effective_from_date := rosetta_g_miss_date_in_map(p5_a2);
    ddp_krpc_rec.effective_to_date := rosetta_g_miss_date_in_map(p5_a3);
    ddp_krpc_rec.conversion_option_code := p5_a4;
    ddp_krpc_rec.next_conversion_date := rosetta_g_miss_date_in_map(p5_a5);
    ddp_krpc_rec.conversion_type_code := p5_a6;


    -- here's the delegated call to the old PL/SQL routine
    okl_k_rate_params_pvt.update_k_rate_params(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_krpc_rec,
      ddx_krpc_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_krpc_rec.khr_id);
    p6_a1 := ddx_krpc_rec.parameter_type_code;
    p6_a2 := ddx_krpc_rec.effective_from_date;
    p6_a3 := ddx_krpc_rec.effective_to_date;
    p6_a4 := ddx_krpc_rec.conversion_option_code;
    p6_a5 := ddx_krpc_rec.next_conversion_date;
    p6_a6 := ddx_krpc_rec.conversion_type_code;
  end;

  procedure delete_k_rate_params(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_VARCHAR2_TABLE_100
    , p5_a2 JTF_DATE_TABLE
  )

  as
    ddp_krpdel_tbl okl_k_rate_params_pvt.krpdel_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_k_rate_params_pvt_w.rosetta_table_copy_in_p1(ddp_krpdel_tbl, p5_a0
      , p5_a1
      , p5_a2
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_k_rate_params_pvt.delete_k_rate_params(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_krpdel_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure validate_k_rate_params(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_product_id  NUMBER
    , p6_a0 JTF_NUMBER_TABLE
    , p6_a1 JTF_VARCHAR2_TABLE_100
    , p6_a2 JTF_DATE_TABLE
    , p6_a3 JTF_DATE_TABLE
    , p6_a4 JTF_NUMBER_TABLE
    , p6_a5 JTF_NUMBER_TABLE
    , p6_a6 JTF_DATE_TABLE
    , p6_a7 JTF_NUMBER_TABLE
    , p6_a8 JTF_NUMBER_TABLE
    , p6_a9 JTF_NUMBER_TABLE
    , p6_a10 JTF_VARCHAR2_TABLE_100
    , p6_a11 JTF_VARCHAR2_TABLE_100
    , p6_a12 JTF_VARCHAR2_TABLE_100
    , p6_a13 JTF_VARCHAR2_TABLE_100
    , p6_a14 JTF_VARCHAR2_TABLE_100
    , p6_a15 JTF_NUMBER_TABLE
    , p6_a16 JTF_VARCHAR2_TABLE_100
    , p6_a17 JTF_NUMBER_TABLE
    , p6_a18 JTF_VARCHAR2_TABLE_100
    , p6_a19 JTF_DATE_TABLE
    , p6_a20 JTF_VARCHAR2_TABLE_100
    , p6_a21 JTF_DATE_TABLE
    , p6_a22 JTF_VARCHAR2_TABLE_100
    , p6_a23 JTF_NUMBER_TABLE
    , p6_a24 JTF_VARCHAR2_TABLE_100
    , p6_a25 JTF_DATE_TABLE
    , p6_a26 JTF_VARCHAR2_TABLE_100
    , p6_a27 JTF_VARCHAR2_TABLE_100
    , p6_a28 JTF_VARCHAR2_TABLE_500
    , p6_a29 JTF_VARCHAR2_TABLE_500
    , p6_a30 JTF_VARCHAR2_TABLE_500
    , p6_a31 JTF_VARCHAR2_TABLE_500
    , p6_a32 JTF_VARCHAR2_TABLE_500
    , p6_a33 JTF_VARCHAR2_TABLE_500
    , p6_a34 JTF_VARCHAR2_TABLE_500
    , p6_a35 JTF_VARCHAR2_TABLE_500
    , p6_a36 JTF_VARCHAR2_TABLE_500
    , p6_a37 JTF_VARCHAR2_TABLE_500
    , p6_a38 JTF_VARCHAR2_TABLE_500
    , p6_a39 JTF_VARCHAR2_TABLE_500
    , p6_a40 JTF_VARCHAR2_TABLE_500
    , p6_a41 JTF_VARCHAR2_TABLE_500
    , p6_a42 JTF_VARCHAR2_TABLE_500
    , p6_a43 JTF_NUMBER_TABLE
    , p6_a44 JTF_DATE_TABLE
    , p6_a45 JTF_NUMBER_TABLE
    , p6_a46 JTF_DATE_TABLE
    , p6_a47 JTF_NUMBER_TABLE
    , p6_a48 JTF_VARCHAR2_TABLE_100
  )

  as
    ddp_k_rate_tbl okl_k_rate_params_pvt.krpv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any






    okl_krp_pvt_w.rosetta_table_copy_in_p2(ddp_k_rate_tbl, p6_a0
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
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_k_rate_params_pvt.validate_k_rate_params(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_product_id,
      ddp_k_rate_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






  end;

  procedure generate_rate_summary(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_chr_id  NUMBER
    , p6_a0 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a3 out nocopy JTF_NUMBER_TABLE
    , p6_a4 out nocopy JTF_DATE_TABLE
    , p6_a5 out nocopy JTF_DATE_TABLE
  )

  as
    ddx_var_par_tbl okl_k_rate_params_pvt.var_prm_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    -- here's the delegated call to the old PL/SQL routine
    okl_k_rate_params_pvt.generate_rate_summary(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_chr_id,
      ddx_var_par_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_k_rate_params_pvt_w.rosetta_table_copy_out_p6(ddx_var_par_tbl, p6_a0
      , p6_a1
      , p6_a2
      , p6_a3
      , p6_a4
      , p6_a5
      );
  end;

  procedure default_k_rate_params(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_deal_type  VARCHAR2
    , p_rev_rec_method  VARCHAR2
    , p_int_calc_basis  VARCHAR2
    , p_column_name  VARCHAR2
    , p9_a0 in out nocopy  NUMBER
    , p9_a1 in out nocopy  VARCHAR2
    , p9_a2 in out nocopy  DATE
    , p9_a3 in out nocopy  DATE
    , p9_a4 in out nocopy  NUMBER
    , p9_a5 in out nocopy  NUMBER
    , p9_a6 in out nocopy  DATE
    , p9_a7 in out nocopy  NUMBER
    , p9_a8 in out nocopy  NUMBER
    , p9_a9 in out nocopy  NUMBER
    , p9_a10 in out nocopy  VARCHAR2
    , p9_a11 in out nocopy  VARCHAR2
    , p9_a12 in out nocopy  VARCHAR2
    , p9_a13 in out nocopy  VARCHAR2
    , p9_a14 in out nocopy  VARCHAR2
    , p9_a15 in out nocopy  NUMBER
    , p9_a16 in out nocopy  VARCHAR2
    , p9_a17 in out nocopy  NUMBER
    , p9_a18 in out nocopy  VARCHAR2
    , p9_a19 in out nocopy  DATE
    , p9_a20 in out nocopy  VARCHAR2
    , p9_a21 in out nocopy  DATE
    , p9_a22 in out nocopy  VARCHAR2
    , p9_a23 in out nocopy  NUMBER
    , p9_a24 in out nocopy  VARCHAR2
    , p9_a25 in out nocopy  DATE
    , p9_a26 in out nocopy  VARCHAR2
    , p9_a27 in out nocopy  VARCHAR2
    , p9_a28 in out nocopy  VARCHAR2
    , p9_a29 in out nocopy  VARCHAR2
    , p9_a30 in out nocopy  VARCHAR2
    , p9_a31 in out nocopy  VARCHAR2
    , p9_a32 in out nocopy  VARCHAR2
    , p9_a33 in out nocopy  VARCHAR2
    , p9_a34 in out nocopy  VARCHAR2
    , p9_a35 in out nocopy  VARCHAR2
    , p9_a36 in out nocopy  VARCHAR2
    , p9_a37 in out nocopy  VARCHAR2
    , p9_a38 in out nocopy  VARCHAR2
    , p9_a39 in out nocopy  VARCHAR2
    , p9_a40 in out nocopy  VARCHAR2
    , p9_a41 in out nocopy  VARCHAR2
    , p9_a42 in out nocopy  VARCHAR2
    , p9_a43 in out nocopy  NUMBER
    , p9_a44 in out nocopy  DATE
    , p9_a45 in out nocopy  NUMBER
    , p9_a46 in out nocopy  DATE
    , p9_a47 in out nocopy  NUMBER
    , p9_a48 in out nocopy  VARCHAR2
  )

  as
    ddp_krpv_rec okl_k_rate_params_pvt.krpv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any









    ddp_krpv_rec.khr_id := rosetta_g_miss_num_map(p9_a0);
    ddp_krpv_rec.parameter_type_code := p9_a1;
    ddp_krpv_rec.effective_from_date := rosetta_g_miss_date_in_map(p9_a2);
    ddp_krpv_rec.effective_to_date := rosetta_g_miss_date_in_map(p9_a3);
    ddp_krpv_rec.interest_index_id := rosetta_g_miss_num_map(p9_a4);
    ddp_krpv_rec.base_rate := rosetta_g_miss_num_map(p9_a5);
    ddp_krpv_rec.interest_start_date := rosetta_g_miss_date_in_map(p9_a6);
    ddp_krpv_rec.adder_rate := rosetta_g_miss_num_map(p9_a7);
    ddp_krpv_rec.maximum_rate := rosetta_g_miss_num_map(p9_a8);
    ddp_krpv_rec.minimum_rate := rosetta_g_miss_num_map(p9_a9);
    ddp_krpv_rec.principal_basis_code := p9_a10;
    ddp_krpv_rec.days_in_a_month_code := p9_a11;
    ddp_krpv_rec.days_in_a_year_code := p9_a12;
    ddp_krpv_rec.interest_basis_code := p9_a13;
    ddp_krpv_rec.rate_delay_code := p9_a14;
    ddp_krpv_rec.rate_delay_frequency := rosetta_g_miss_num_map(p9_a15);
    ddp_krpv_rec.compounding_frequency_code := p9_a16;
    ddp_krpv_rec.calculation_formula_id := rosetta_g_miss_num_map(p9_a17);
    ddp_krpv_rec.catchup_basis_code := p9_a18;
    ddp_krpv_rec.catchup_start_date := rosetta_g_miss_date_in_map(p9_a19);
    ddp_krpv_rec.catchup_settlement_code := p9_a20;
    ddp_krpv_rec.rate_change_start_date := rosetta_g_miss_date_in_map(p9_a21);
    ddp_krpv_rec.rate_change_frequency_code := p9_a22;
    ddp_krpv_rec.rate_change_value := rosetta_g_miss_num_map(p9_a23);
    ddp_krpv_rec.conversion_option_code := p9_a24;
    ddp_krpv_rec.next_conversion_date := rosetta_g_miss_date_in_map(p9_a25);
    ddp_krpv_rec.conversion_type_code := p9_a26;
    ddp_krpv_rec.attribute_category := p9_a27;
    ddp_krpv_rec.attribute1 := p9_a28;
    ddp_krpv_rec.attribute2 := p9_a29;
    ddp_krpv_rec.attribute3 := p9_a30;
    ddp_krpv_rec.attribute4 := p9_a31;
    ddp_krpv_rec.attribute5 := p9_a32;
    ddp_krpv_rec.attribute6 := p9_a33;
    ddp_krpv_rec.attribute7 := p9_a34;
    ddp_krpv_rec.attribute8 := p9_a35;
    ddp_krpv_rec.attribute9 := p9_a36;
    ddp_krpv_rec.attribute10 := p9_a37;
    ddp_krpv_rec.attribute11 := p9_a38;
    ddp_krpv_rec.attribute12 := p9_a39;
    ddp_krpv_rec.attribute13 := p9_a40;
    ddp_krpv_rec.attribute14 := p9_a41;
    ddp_krpv_rec.attribute15 := p9_a42;
    ddp_krpv_rec.created_by := rosetta_g_miss_num_map(p9_a43);
    ddp_krpv_rec.creation_date := rosetta_g_miss_date_in_map(p9_a44);
    ddp_krpv_rec.last_updated_by := rosetta_g_miss_num_map(p9_a45);
    ddp_krpv_rec.last_update_date := rosetta_g_miss_date_in_map(p9_a46);
    ddp_krpv_rec.last_update_login := rosetta_g_miss_num_map(p9_a47);
    ddp_krpv_rec.catchup_frequency_code := p9_a48;

    -- here's the delegated call to the old PL/SQL routine
    okl_k_rate_params_pvt.default_k_rate_params(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_deal_type,
      p_rev_rec_method,
      p_int_calc_basis,
      p_column_name,
      ddp_krpv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any









    p9_a0 := rosetta_g_miss_num_map(ddp_krpv_rec.khr_id);
    p9_a1 := ddp_krpv_rec.parameter_type_code;
    p9_a2 := ddp_krpv_rec.effective_from_date;
    p9_a3 := ddp_krpv_rec.effective_to_date;
    p9_a4 := rosetta_g_miss_num_map(ddp_krpv_rec.interest_index_id);
    p9_a5 := rosetta_g_miss_num_map(ddp_krpv_rec.base_rate);
    p9_a6 := ddp_krpv_rec.interest_start_date;
    p9_a7 := rosetta_g_miss_num_map(ddp_krpv_rec.adder_rate);
    p9_a8 := rosetta_g_miss_num_map(ddp_krpv_rec.maximum_rate);
    p9_a9 := rosetta_g_miss_num_map(ddp_krpv_rec.minimum_rate);
    p9_a10 := ddp_krpv_rec.principal_basis_code;
    p9_a11 := ddp_krpv_rec.days_in_a_month_code;
    p9_a12 := ddp_krpv_rec.days_in_a_year_code;
    p9_a13 := ddp_krpv_rec.interest_basis_code;
    p9_a14 := ddp_krpv_rec.rate_delay_code;
    p9_a15 := rosetta_g_miss_num_map(ddp_krpv_rec.rate_delay_frequency);
    p9_a16 := ddp_krpv_rec.compounding_frequency_code;
    p9_a17 := rosetta_g_miss_num_map(ddp_krpv_rec.calculation_formula_id);
    p9_a18 := ddp_krpv_rec.catchup_basis_code;
    p9_a19 := ddp_krpv_rec.catchup_start_date;
    p9_a20 := ddp_krpv_rec.catchup_settlement_code;
    p9_a21 := ddp_krpv_rec.rate_change_start_date;
    p9_a22 := ddp_krpv_rec.rate_change_frequency_code;
    p9_a23 := rosetta_g_miss_num_map(ddp_krpv_rec.rate_change_value);
    p9_a24 := ddp_krpv_rec.conversion_option_code;
    p9_a25 := ddp_krpv_rec.next_conversion_date;
    p9_a26 := ddp_krpv_rec.conversion_type_code;
    p9_a27 := ddp_krpv_rec.attribute_category;
    p9_a28 := ddp_krpv_rec.attribute1;
    p9_a29 := ddp_krpv_rec.attribute2;
    p9_a30 := ddp_krpv_rec.attribute3;
    p9_a31 := ddp_krpv_rec.attribute4;
    p9_a32 := ddp_krpv_rec.attribute5;
    p9_a33 := ddp_krpv_rec.attribute6;
    p9_a34 := ddp_krpv_rec.attribute7;
    p9_a35 := ddp_krpv_rec.attribute8;
    p9_a36 := ddp_krpv_rec.attribute9;
    p9_a37 := ddp_krpv_rec.attribute10;
    p9_a38 := ddp_krpv_rec.attribute11;
    p9_a39 := ddp_krpv_rec.attribute12;
    p9_a40 := ddp_krpv_rec.attribute13;
    p9_a41 := ddp_krpv_rec.attribute14;
    p9_a42 := ddp_krpv_rec.attribute15;
    p9_a43 := rosetta_g_miss_num_map(ddp_krpv_rec.created_by);
    p9_a44 := ddp_krpv_rec.creation_date;
    p9_a45 := rosetta_g_miss_num_map(ddp_krpv_rec.last_updated_by);
    p9_a46 := ddp_krpv_rec.last_update_date;
    p9_a47 := rosetta_g_miss_num_map(ddp_krpv_rec.last_update_login);
    p9_a48 := ddp_krpv_rec.catchup_frequency_code;
  end;

  procedure cascade_contract_start_date(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_chr_id  NUMBER
    , p_new_start_date  date
  )

  as
    ddp_new_start_date date;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any






    ddp_new_start_date := rosetta_g_miss_date_in_map(p_new_start_date);

    -- here's the delegated call to the old PL/SQL routine
    okl_k_rate_params_pvt.cascade_contract_start_date(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_chr_id,
      ddp_new_start_date);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






  end;

  procedure get_rate_rec(p_chr_id  NUMBER
    , p_parameter_type_code  VARCHAR2
    , p_effective_from_date  date
    , p3_a0 out nocopy  NUMBER
    , p3_a1 out nocopy  VARCHAR2
    , p3_a2 out nocopy  DATE
    , p3_a3 out nocopy  DATE
    , p3_a4 out nocopy  NUMBER
    , p3_a5 out nocopy  NUMBER
    , p3_a6 out nocopy  DATE
    , p3_a7 out nocopy  NUMBER
    , p3_a8 out nocopy  NUMBER
    , p3_a9 out nocopy  NUMBER
    , p3_a10 out nocopy  VARCHAR2
    , p3_a11 out nocopy  VARCHAR2
    , p3_a12 out nocopy  VARCHAR2
    , p3_a13 out nocopy  VARCHAR2
    , p3_a14 out nocopy  VARCHAR2
    , p3_a15 out nocopy  NUMBER
    , p3_a16 out nocopy  VARCHAR2
    , p3_a17 out nocopy  NUMBER
    , p3_a18 out nocopy  VARCHAR2
    , p3_a19 out nocopy  DATE
    , p3_a20 out nocopy  VARCHAR2
    , p3_a21 out nocopy  DATE
    , p3_a22 out nocopy  VARCHAR2
    , p3_a23 out nocopy  NUMBER
    , p3_a24 out nocopy  VARCHAR2
    , p3_a25 out nocopy  DATE
    , p3_a26 out nocopy  VARCHAR2
    , p3_a27 out nocopy  VARCHAR2
    , p3_a28 out nocopy  VARCHAR2
    , p3_a29 out nocopy  VARCHAR2
    , p3_a30 out nocopy  VARCHAR2
    , p3_a31 out nocopy  VARCHAR2
    , p3_a32 out nocopy  VARCHAR2
    , p3_a33 out nocopy  VARCHAR2
    , p3_a34 out nocopy  VARCHAR2
    , p3_a35 out nocopy  VARCHAR2
    , p3_a36 out nocopy  VARCHAR2
    , p3_a37 out nocopy  VARCHAR2
    , p3_a38 out nocopy  VARCHAR2
    , p3_a39 out nocopy  VARCHAR2
    , p3_a40 out nocopy  VARCHAR2
    , p3_a41 out nocopy  VARCHAR2
    , p3_a42 out nocopy  VARCHAR2
    , p3_a43 out nocopy  NUMBER
    , p3_a44 out nocopy  DATE
    , p3_a45 out nocopy  NUMBER
    , p3_a46 out nocopy  DATE
    , p3_a47 out nocopy  NUMBER
    , p3_a48 out nocopy  VARCHAR2
    , x_no_data_found out nocopy  number
  )

  as
    ddp_effective_from_date date;
    ddx_krpv_rec okl_k_rate_params_pvt.krpv_rec_type;
    ddx_no_data_found boolean;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any


    ddp_effective_from_date := rosetta_g_miss_date_in_map(p_effective_from_date);



    -- here's the delegated call to the old PL/SQL routine
    okl_k_rate_params_pvt.get_rate_rec(p_chr_id,
      p_parameter_type_code,
      ddp_effective_from_date,
      ddx_krpv_rec,
      ddx_no_data_found);

    -- copy data back from the local variables to OUT or IN-OUT args, if any



    p3_a0 := rosetta_g_miss_num_map(ddx_krpv_rec.khr_id);
    p3_a1 := ddx_krpv_rec.parameter_type_code;
    p3_a2 := ddx_krpv_rec.effective_from_date;
    p3_a3 := ddx_krpv_rec.effective_to_date;
    p3_a4 := rosetta_g_miss_num_map(ddx_krpv_rec.interest_index_id);
    p3_a5 := rosetta_g_miss_num_map(ddx_krpv_rec.base_rate);
    p3_a6 := ddx_krpv_rec.interest_start_date;
    p3_a7 := rosetta_g_miss_num_map(ddx_krpv_rec.adder_rate);
    p3_a8 := rosetta_g_miss_num_map(ddx_krpv_rec.maximum_rate);
    p3_a9 := rosetta_g_miss_num_map(ddx_krpv_rec.minimum_rate);
    p3_a10 := ddx_krpv_rec.principal_basis_code;
    p3_a11 := ddx_krpv_rec.days_in_a_month_code;
    p3_a12 := ddx_krpv_rec.days_in_a_year_code;
    p3_a13 := ddx_krpv_rec.interest_basis_code;
    p3_a14 := ddx_krpv_rec.rate_delay_code;
    p3_a15 := rosetta_g_miss_num_map(ddx_krpv_rec.rate_delay_frequency);
    p3_a16 := ddx_krpv_rec.compounding_frequency_code;
    p3_a17 := rosetta_g_miss_num_map(ddx_krpv_rec.calculation_formula_id);
    p3_a18 := ddx_krpv_rec.catchup_basis_code;
    p3_a19 := ddx_krpv_rec.catchup_start_date;
    p3_a20 := ddx_krpv_rec.catchup_settlement_code;
    p3_a21 := ddx_krpv_rec.rate_change_start_date;
    p3_a22 := ddx_krpv_rec.rate_change_frequency_code;
    p3_a23 := rosetta_g_miss_num_map(ddx_krpv_rec.rate_change_value);
    p3_a24 := ddx_krpv_rec.conversion_option_code;
    p3_a25 := ddx_krpv_rec.next_conversion_date;
    p3_a26 := ddx_krpv_rec.conversion_type_code;
    p3_a27 := ddx_krpv_rec.attribute_category;
    p3_a28 := ddx_krpv_rec.attribute1;
    p3_a29 := ddx_krpv_rec.attribute2;
    p3_a30 := ddx_krpv_rec.attribute3;
    p3_a31 := ddx_krpv_rec.attribute4;
    p3_a32 := ddx_krpv_rec.attribute5;
    p3_a33 := ddx_krpv_rec.attribute6;
    p3_a34 := ddx_krpv_rec.attribute7;
    p3_a35 := ddx_krpv_rec.attribute8;
    p3_a36 := ddx_krpv_rec.attribute9;
    p3_a37 := ddx_krpv_rec.attribute10;
    p3_a38 := ddx_krpv_rec.attribute11;
    p3_a39 := ddx_krpv_rec.attribute12;
    p3_a40 := ddx_krpv_rec.attribute13;
    p3_a41 := ddx_krpv_rec.attribute14;
    p3_a42 := ddx_krpv_rec.attribute15;
    p3_a43 := rosetta_g_miss_num_map(ddx_krpv_rec.created_by);
    p3_a44 := ddx_krpv_rec.creation_date;
    p3_a45 := rosetta_g_miss_num_map(ddx_krpv_rec.last_updated_by);
    p3_a46 := ddx_krpv_rec.last_update_date;
    p3_a47 := rosetta_g_miss_num_map(ddx_krpv_rec.last_update_login);
    p3_a48 := ddx_krpv_rec.catchup_frequency_code;

  if ddx_no_data_found is null
    then x_no_data_found := null;
  elsif ddx_no_data_found
    then x_no_data_found := 1;
  else x_no_data_found := 0;
  end if;
  end;

  procedure check_rebook_allowed(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_chr_id  NUMBER
    , p_rebook_date  date
  )

  as
    ddp_rebook_date date;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any






    ddp_rebook_date := rosetta_g_miss_date_in_map(p_rebook_date);

    -- here's the delegated call to the old PL/SQL routine
    okl_k_rate_params_pvt.check_rebook_allowed(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_chr_id,
      ddp_rebook_date);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






  end;

  procedure check_base_rate(p_khr_id  NUMBER
    , x_base_rate_defined out nocopy  number
    , x_return_status out nocopy  VARCHAR2
  )

  as
    ddx_base_rate_defined boolean;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    -- here's the delegated call to the old PL/SQL routine
    okl_k_rate_params_pvt.check_base_rate(p_khr_id,
      ddx_base_rate_defined,
      x_return_status);

    -- copy data back from the local variables to OUT or IN-OUT args, if any

  if ddx_base_rate_defined is null
    then x_base_rate_defined := null;
  elsif ddx_base_rate_defined
    then x_base_rate_defined := 1;
  else x_base_rate_defined := 0;
  end if;

  end;

  procedure check_principal_payment(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_chr_id  NUMBER
    , x_principal_payment_defined out nocopy  number
  )

  as
    ddx_principal_payment_defined boolean;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    -- here's the delegated call to the old PL/SQL routine
    okl_k_rate_params_pvt.check_principal_payment(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_chr_id,
      ddx_principal_payment_defined);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






  if ddx_principal_payment_defined is null
    then x_principal_payment_defined := null;
  elsif ddx_principal_payment_defined
    then x_principal_payment_defined := 1;
  else x_principal_payment_defined := 0;
  end if;
  end;

  procedure copy_k_rate_params(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_khr_id  NUMBER
    , p_effective_from_date  date
    , p_rate_type  VARCHAR2
    , p8_a0 out nocopy  NUMBER
    , p8_a1 out nocopy  VARCHAR2
    , p8_a2 out nocopy  DATE
    , p8_a3 out nocopy  DATE
    , p8_a4 out nocopy  NUMBER
    , p8_a5 out nocopy  NUMBER
    , p8_a6 out nocopy  DATE
    , p8_a7 out nocopy  NUMBER
    , p8_a8 out nocopy  NUMBER
    , p8_a9 out nocopy  NUMBER
    , p8_a10 out nocopy  VARCHAR2
    , p8_a11 out nocopy  VARCHAR2
    , p8_a12 out nocopy  VARCHAR2
    , p8_a13 out nocopy  VARCHAR2
    , p8_a14 out nocopy  VARCHAR2
    , p8_a15 out nocopy  NUMBER
    , p8_a16 out nocopy  VARCHAR2
    , p8_a17 out nocopy  NUMBER
    , p8_a18 out nocopy  VARCHAR2
    , p8_a19 out nocopy  DATE
    , p8_a20 out nocopy  VARCHAR2
    , p8_a21 out nocopy  DATE
    , p8_a22 out nocopy  VARCHAR2
    , p8_a23 out nocopy  NUMBER
    , p8_a24 out nocopy  VARCHAR2
    , p8_a25 out nocopy  DATE
    , p8_a26 out nocopy  VARCHAR2
    , p8_a27 out nocopy  VARCHAR2
    , p8_a28 out nocopy  VARCHAR2
    , p8_a29 out nocopy  VARCHAR2
    , p8_a30 out nocopy  VARCHAR2
    , p8_a31 out nocopy  VARCHAR2
    , p8_a32 out nocopy  VARCHAR2
    , p8_a33 out nocopy  VARCHAR2
    , p8_a34 out nocopy  VARCHAR2
    , p8_a35 out nocopy  VARCHAR2
    , p8_a36 out nocopy  VARCHAR2
    , p8_a37 out nocopy  VARCHAR2
    , p8_a38 out nocopy  VARCHAR2
    , p8_a39 out nocopy  VARCHAR2
    , p8_a40 out nocopy  VARCHAR2
    , p8_a41 out nocopy  VARCHAR2
    , p8_a42 out nocopy  VARCHAR2
    , p8_a43 out nocopy  NUMBER
    , p8_a44 out nocopy  DATE
    , p8_a45 out nocopy  NUMBER
    , p8_a46 out nocopy  DATE
    , p8_a47 out nocopy  NUMBER
    , p8_a48 out nocopy  VARCHAR2
  )

  as
    ddp_effective_from_date date;
    ddx_krpv_rec okl_k_rate_params_pvt.krpv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any






    ddp_effective_from_date := rosetta_g_miss_date_in_map(p_effective_from_date);



    -- here's the delegated call to the old PL/SQL routine
    okl_k_rate_params_pvt.copy_k_rate_params(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_khr_id,
      ddp_effective_from_date,
      p_rate_type,
      ddx_krpv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








    p8_a0 := rosetta_g_miss_num_map(ddx_krpv_rec.khr_id);
    p8_a1 := ddx_krpv_rec.parameter_type_code;
    p8_a2 := ddx_krpv_rec.effective_from_date;
    p8_a3 := ddx_krpv_rec.effective_to_date;
    p8_a4 := rosetta_g_miss_num_map(ddx_krpv_rec.interest_index_id);
    p8_a5 := rosetta_g_miss_num_map(ddx_krpv_rec.base_rate);
    p8_a6 := ddx_krpv_rec.interest_start_date;
    p8_a7 := rosetta_g_miss_num_map(ddx_krpv_rec.adder_rate);
    p8_a8 := rosetta_g_miss_num_map(ddx_krpv_rec.maximum_rate);
    p8_a9 := rosetta_g_miss_num_map(ddx_krpv_rec.minimum_rate);
    p8_a10 := ddx_krpv_rec.principal_basis_code;
    p8_a11 := ddx_krpv_rec.days_in_a_month_code;
    p8_a12 := ddx_krpv_rec.days_in_a_year_code;
    p8_a13 := ddx_krpv_rec.interest_basis_code;
    p8_a14 := ddx_krpv_rec.rate_delay_code;
    p8_a15 := rosetta_g_miss_num_map(ddx_krpv_rec.rate_delay_frequency);
    p8_a16 := ddx_krpv_rec.compounding_frequency_code;
    p8_a17 := rosetta_g_miss_num_map(ddx_krpv_rec.calculation_formula_id);
    p8_a18 := ddx_krpv_rec.catchup_basis_code;
    p8_a19 := ddx_krpv_rec.catchup_start_date;
    p8_a20 := ddx_krpv_rec.catchup_settlement_code;
    p8_a21 := ddx_krpv_rec.rate_change_start_date;
    p8_a22 := ddx_krpv_rec.rate_change_frequency_code;
    p8_a23 := rosetta_g_miss_num_map(ddx_krpv_rec.rate_change_value);
    p8_a24 := ddx_krpv_rec.conversion_option_code;
    p8_a25 := ddx_krpv_rec.next_conversion_date;
    p8_a26 := ddx_krpv_rec.conversion_type_code;
    p8_a27 := ddx_krpv_rec.attribute_category;
    p8_a28 := ddx_krpv_rec.attribute1;
    p8_a29 := ddx_krpv_rec.attribute2;
    p8_a30 := ddx_krpv_rec.attribute3;
    p8_a31 := ddx_krpv_rec.attribute4;
    p8_a32 := ddx_krpv_rec.attribute5;
    p8_a33 := ddx_krpv_rec.attribute6;
    p8_a34 := ddx_krpv_rec.attribute7;
    p8_a35 := ddx_krpv_rec.attribute8;
    p8_a36 := ddx_krpv_rec.attribute9;
    p8_a37 := ddx_krpv_rec.attribute10;
    p8_a38 := ddx_krpv_rec.attribute11;
    p8_a39 := ddx_krpv_rec.attribute12;
    p8_a40 := ddx_krpv_rec.attribute13;
    p8_a41 := ddx_krpv_rec.attribute14;
    p8_a42 := ddx_krpv_rec.attribute15;
    p8_a43 := rosetta_g_miss_num_map(ddx_krpv_rec.created_by);
    p8_a44 := ddx_krpv_rec.creation_date;
    p8_a45 := rosetta_g_miss_num_map(ddx_krpv_rec.last_updated_by);
    p8_a46 := ddx_krpv_rec.last_update_date;
    p8_a47 := rosetta_g_miss_num_map(ddx_krpv_rec.last_update_login);
    p8_a48 := ddx_krpv_rec.catchup_frequency_code;
  end;

end okl_k_rate_params_pvt_w;

/
