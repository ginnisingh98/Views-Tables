--------------------------------------------------------
--  DDL for Package Body OKL_PAY_INVOICES_MAN_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_PAY_INVOICES_MAN_PVT_W" as
  /* $Header: OKLIPIMB.pls 115.2 2003/01/28 23:03:20 pjgomes noship $ */
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

  procedure rosetta_table_copy_in_p7(t out nocopy okl_pay_invoices_man_pvt.man_inv_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_DATE_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_VARCHAR2_TABLE_300
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_VARCHAR2_TABLE_100
    , a13 JTF_VARCHAR2_TABLE_300
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).ipvs_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).khr_id := rosetta_g_miss_num_map(a1(indx));
          t(ddindx).currency := a2(indx);
          t(ddindx).vendor_id := rosetta_g_miss_num_map(a3(indx));
          t(ddindx).payment_method_code := a4(indx);
          t(ddindx).invoice_date := rosetta_g_miss_date_in_map(a5(indx));
          t(ddindx).pay_terms := rosetta_g_miss_num_map(a6(indx));
          t(ddindx).invoice_number := a7(indx);
          t(ddindx).invoice_category_code := a8(indx);
          t(ddindx).invoice_type := a9(indx);
          t(ddindx).amount := rosetta_g_miss_num_map(a10(indx));
          t(ddindx).sty_id := rosetta_g_miss_num_map(a11(indx));
          t(ddindx).pay_group_lookup_code := a12(indx);
          t(ddindx).vendor_invoice_number := a13(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p7;
  procedure rosetta_table_copy_out_p7(t okl_pay_invoices_man_pvt.man_inv_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_DATE_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    , a9 out nocopy JTF_VARCHAR2_TABLE_300
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_NUMBER_TABLE
    , a12 out nocopy JTF_VARCHAR2_TABLE_100
    , a13 out nocopy JTF_VARCHAR2_TABLE_300
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_VARCHAR2_TABLE_100();
    a5 := JTF_DATE_TABLE();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_VARCHAR2_TABLE_100();
    a8 := JTF_VARCHAR2_TABLE_100();
    a9 := JTF_VARCHAR2_TABLE_300();
    a10 := JTF_NUMBER_TABLE();
    a11 := JTF_NUMBER_TABLE();
    a12 := JTF_VARCHAR2_TABLE_100();
    a13 := JTF_VARCHAR2_TABLE_300();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_VARCHAR2_TABLE_100();
      a5 := JTF_DATE_TABLE();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_VARCHAR2_TABLE_100();
      a8 := JTF_VARCHAR2_TABLE_100();
      a9 := JTF_VARCHAR2_TABLE_300();
      a10 := JTF_NUMBER_TABLE();
      a11 := JTF_NUMBER_TABLE();
      a12 := JTF_VARCHAR2_TABLE_100();
      a13 := JTF_VARCHAR2_TABLE_300();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).ipvs_id);
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).khr_id);
          a2(indx) := t(ddindx).currency;
          a3(indx) := rosetta_g_miss_num_map(t(ddindx).vendor_id);
          a4(indx) := t(ddindx).payment_method_code;
          a5(indx) := t(ddindx).invoice_date;
          a6(indx) := rosetta_g_miss_num_map(t(ddindx).pay_terms);
          a7(indx) := t(ddindx).invoice_number;
          a8(indx) := t(ddindx).invoice_category_code;
          a9(indx) := t(ddindx).invoice_type;
          a10(indx) := rosetta_g_miss_num_map(t(ddindx).amount);
          a11(indx) := rosetta_g_miss_num_map(t(ddindx).sty_id);
          a12(indx) := t(ddindx).pay_group_lookup_code;
          a13(indx) := t(ddindx).vendor_invoice_number;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p7;

  procedure manual_entry(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  VARCHAR2
    , p6_a3 out nocopy  NUMBER
    , p6_a4 out nocopy  VARCHAR2
    , p6_a5 out nocopy  DATE
    , p6_a6 out nocopy  NUMBER
    , p6_a7 out nocopy  VARCHAR2
    , p6_a8 out nocopy  VARCHAR2
    , p6_a9 out nocopy  VARCHAR2
    , p6_a10 out nocopy  NUMBER
    , p6_a11 out nocopy  NUMBER
    , p6_a12 out nocopy  VARCHAR2
    , p6_a13 out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  DATE := fnd_api.g_miss_date
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  VARCHAR2 := fnd_api.g_miss_char
    , p5_a10  NUMBER := 0-1962.0724
    , p5_a11  NUMBER := 0-1962.0724
    , p5_a12  VARCHAR2 := fnd_api.g_miss_char
    , p5_a13  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_man_inv_rec okl_pay_invoices_man_pvt.man_inv_rec_type;
    ddx_man_inv_rec okl_pay_invoices_man_pvt.man_inv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_man_inv_rec.ipvs_id := rosetta_g_miss_num_map(p5_a0);
    ddp_man_inv_rec.khr_id := rosetta_g_miss_num_map(p5_a1);
    ddp_man_inv_rec.currency := p5_a2;
    ddp_man_inv_rec.vendor_id := rosetta_g_miss_num_map(p5_a3);
    ddp_man_inv_rec.payment_method_code := p5_a4;
    ddp_man_inv_rec.invoice_date := rosetta_g_miss_date_in_map(p5_a5);
    ddp_man_inv_rec.pay_terms := rosetta_g_miss_num_map(p5_a6);
    ddp_man_inv_rec.invoice_number := p5_a7;
    ddp_man_inv_rec.invoice_category_code := p5_a8;
    ddp_man_inv_rec.invoice_type := p5_a9;
    ddp_man_inv_rec.amount := rosetta_g_miss_num_map(p5_a10);
    ddp_man_inv_rec.sty_id := rosetta_g_miss_num_map(p5_a11);
    ddp_man_inv_rec.pay_group_lookup_code := p5_a12;
    ddp_man_inv_rec.vendor_invoice_number := p5_a13;


    -- here's the delegated call to the old PL/SQL routine
    okl_pay_invoices_man_pvt.manual_entry(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_man_inv_rec,
      ddx_man_inv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_man_inv_rec.ipvs_id);
    p6_a1 := rosetta_g_miss_num_map(ddx_man_inv_rec.khr_id);
    p6_a2 := ddx_man_inv_rec.currency;
    p6_a3 := rosetta_g_miss_num_map(ddx_man_inv_rec.vendor_id);
    p6_a4 := ddx_man_inv_rec.payment_method_code;
    p6_a5 := ddx_man_inv_rec.invoice_date;
    p6_a6 := rosetta_g_miss_num_map(ddx_man_inv_rec.pay_terms);
    p6_a7 := ddx_man_inv_rec.invoice_number;
    p6_a8 := ddx_man_inv_rec.invoice_category_code;
    p6_a9 := ddx_man_inv_rec.invoice_type;
    p6_a10 := rosetta_g_miss_num_map(ddx_man_inv_rec.amount);
    p6_a11 := rosetta_g_miss_num_map(ddx_man_inv_rec.sty_id);
    p6_a12 := ddx_man_inv_rec.pay_group_lookup_code;
    p6_a13 := ddx_man_inv_rec.vendor_invoice_number;
  end;

  procedure manual_entry(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_VARCHAR2_TABLE_100
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_VARCHAR2_TABLE_100
    , p5_a5 JTF_DATE_TABLE
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_VARCHAR2_TABLE_100
    , p5_a8 JTF_VARCHAR2_TABLE_100
    , p5_a9 JTF_VARCHAR2_TABLE_300
    , p5_a10 JTF_NUMBER_TABLE
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_VARCHAR2_TABLE_100
    , p5_a13 JTF_VARCHAR2_TABLE_300
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a3 out nocopy JTF_NUMBER_TABLE
    , p6_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a5 out nocopy JTF_DATE_TABLE
    , p6_a6 out nocopy JTF_NUMBER_TABLE
    , p6_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a9 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a10 out nocopy JTF_NUMBER_TABLE
    , p6_a11 out nocopy JTF_NUMBER_TABLE
    , p6_a12 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a13 out nocopy JTF_VARCHAR2_TABLE_300
  )

  as
    ddp_man_inv_tbl okl_pay_invoices_man_pvt.man_inv_tbl_type;
    ddx_man_inv_tbl okl_pay_invoices_man_pvt.man_inv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_pay_invoices_man_pvt_w.rosetta_table_copy_in_p7(ddp_man_inv_tbl, p5_a0
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
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_pay_invoices_man_pvt.manual_entry(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_man_inv_tbl,
      ddx_man_inv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_pay_invoices_man_pvt_w.rosetta_table_copy_out_p7(ddx_man_inv_tbl, p6_a0
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
      );
  end;

end okl_pay_invoices_man_pvt_w;

/
