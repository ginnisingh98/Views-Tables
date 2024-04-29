--------------------------------------------------------
--  DDL for Package Body OKL_LOSS_PROV_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_LOSS_PROV_PVT_W" as
  /* $Header: OKLELPVB.pls 120.5 2005/10/30 03:20:11 appldev noship $ */
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

  procedure rosetta_table_copy_in_p3(t out nocopy okl_loss_prov_pvt.bucket_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).aging_bucket_line_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).bkt_id := rosetta_g_miss_num_map(a1(indx));
          t(ddindx).loss_rate := rosetta_g_miss_num_map(a2(indx));
          t(ddindx).bucket_name := a3(indx);
          t(ddindx).days_start := rosetta_g_miss_num_map(a4(indx));
          t(ddindx).days_to := rosetta_g_miss_num_map(a5(indx));
          t(ddindx).loss_amount := rosetta_g_miss_num_map(a6(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p3;
  procedure rosetta_table_copy_out_p3(t okl_loss_prov_pvt.bucket_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_VARCHAR2_TABLE_100();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_NUMBER_TABLE();
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
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).aging_bucket_line_id);
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).bkt_id);
          a2(indx) := rosetta_g_miss_num_map(t(ddindx).loss_rate);
          a3(indx) := t(ddindx).bucket_name;
          a4(indx) := rosetta_g_miss_num_map(t(ddindx).days_start);
          a5(indx) := rosetta_g_miss_num_map(t(ddindx).days_to);
          a6(indx) := rosetta_g_miss_num_map(t(ddindx).loss_amount);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p3;

  procedure rosetta_table_copy_in_p4(t out nocopy okl_loss_prov_pvt.slpv_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_VARCHAR2_TABLE_2000
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_DATE_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).khr_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).sty_id := rosetta_g_miss_num_map(a1(indx));
          t(ddindx).amount := rosetta_g_miss_num_map(a2(indx));
          t(ddindx).description := a3(indx);
          t(ddindx).reverse_flag := a4(indx);
          t(ddindx).tax_deductible_local := a5(indx);
          t(ddindx).tax_deductible_corporate := a6(indx);
          t(ddindx).provision_date := rosetta_g_miss_date_in_map(a7(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p4;
  procedure rosetta_table_copy_out_p4(t okl_loss_prov_pvt.slpv_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_VARCHAR2_TABLE_2000
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    , a7 out nocopy JTF_DATE_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_VARCHAR2_TABLE_2000();
    a4 := JTF_VARCHAR2_TABLE_100();
    a5 := JTF_VARCHAR2_TABLE_100();
    a6 := JTF_VARCHAR2_TABLE_100();
    a7 := JTF_DATE_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_VARCHAR2_TABLE_2000();
      a4 := JTF_VARCHAR2_TABLE_100();
      a5 := JTF_VARCHAR2_TABLE_100();
      a6 := JTF_VARCHAR2_TABLE_100();
      a7 := JTF_DATE_TABLE();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        a3.extend(t.count);
        a4.extend(t.count);
        a5.extend(t.count);
        a6.extend(t.count);
        a7.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).khr_id);
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).sty_id);
          a2(indx) := rosetta_g_miss_num_map(t(ddindx).amount);
          a3(indx) := t(ddindx).description;
          a4(indx) := t(ddindx).reverse_flag;
          a5(indx) := t(ddindx).tax_deductible_local;
          a6(indx) := t(ddindx).tax_deductible_corporate;
          a7(indx) := t(ddindx).provision_date;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p4;

  function submit_general_loss(x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  DATE := fnd_api.g_miss_date
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
  ) return number

  as
    ddp_glpv_rec okl_loss_prov_pvt.glpv_rec_type;
    ddindx binary_integer; indx binary_integer;
    ddrosetta_retval number;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_glpv_rec.product_id := rosetta_g_miss_num_map(p5_a0);
    ddp_glpv_rec.bucket_id := rosetta_g_miss_num_map(p5_a1);
    ddp_glpv_rec.entry_date := rosetta_g_miss_date_in_map(p5_a2);
    ddp_glpv_rec.tax_deductible_local := p5_a3;
    ddp_glpv_rec.tax_deductible_corporate := p5_a4;
    ddp_glpv_rec.description := p5_a5;

    -- here's the delegated call to the old PL/SQL routine
    ddrosetta_retval := okl_loss_prov_pvt.submit_general_loss(x_return_status,
      x_msg_count,
      x_msg_data,
      p_api_version,
      p_init_msg_list,
      ddp_glpv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    return ddrosetta_retval;
  end;

  procedure specific_loss_provision(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  VARCHAR2 := fnd_api.g_miss_char
    , p5_a7  DATE := fnd_api.g_miss_date
  )

  as
    ddp_slpv_rec okl_loss_prov_pvt.slpv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_slpv_rec.khr_id := rosetta_g_miss_num_map(p5_a0);
    ddp_slpv_rec.sty_id := rosetta_g_miss_num_map(p5_a1);
    ddp_slpv_rec.amount := rosetta_g_miss_num_map(p5_a2);
    ddp_slpv_rec.description := p5_a3;
    ddp_slpv_rec.reverse_flag := p5_a4;
    ddp_slpv_rec.tax_deductible_local := p5_a5;
    ddp_slpv_rec.tax_deductible_corporate := p5_a6;
    ddp_slpv_rec.provision_date := rosetta_g_miss_date_in_map(p5_a7);

    -- here's the delegated call to the old PL/SQL routine
    okl_loss_prov_pvt.specific_loss_provision(p_api_version,
      p_init_msg_list,
      x_msg_count,
      x_msg_data,
      x_return_status,
      ddp_slpv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

end okl_loss_prov_pvt_w;

/
