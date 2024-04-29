--------------------------------------------------------
--  DDL for Package Body OKL_LA_PAYMENTS_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_LA_PAYMENTS_PVT_W" as
  /* $Header: OKLEPYTB.pls 115.6 2003/11/15 01:29:04 ashariff noship $ */
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

  procedure rosetta_table_copy_in_p3(t out nocopy okl_la_payments_pvt.pym_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_500
    , a2 JTF_VARCHAR2_TABLE_500
    , a3 JTF_VARCHAR2_TABLE_500
    , a4 JTF_VARCHAR2_TABLE_500
    , a5 JTF_VARCHAR2_TABLE_500
    , a6 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).rule_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).stub_days := a1(indx);
          t(ddindx).stub_amount := a2(indx);
          t(ddindx).period := a3(indx);
          t(ddindx).amount := a4(indx);
          t(ddindx).sort_date := a5(indx);
          t(ddindx).update_type := a6(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p3;
  procedure rosetta_table_copy_out_p3(t okl_la_payments_pvt.pym_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_500
    , a2 out nocopy JTF_VARCHAR2_TABLE_500
    , a3 out nocopy JTF_VARCHAR2_TABLE_500
    , a4 out nocopy JTF_VARCHAR2_TABLE_500
    , a5 out nocopy JTF_VARCHAR2_TABLE_500
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_500();
    a2 := JTF_VARCHAR2_TABLE_500();
    a3 := JTF_VARCHAR2_TABLE_500();
    a4 := JTF_VARCHAR2_TABLE_500();
    a5 := JTF_VARCHAR2_TABLE_500();
    a6 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_500();
      a2 := JTF_VARCHAR2_TABLE_500();
      a3 := JTF_VARCHAR2_TABLE_500();
      a4 := JTF_VARCHAR2_TABLE_500();
      a5 := JTF_VARCHAR2_TABLE_500();
      a6 := JTF_VARCHAR2_TABLE_100();
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
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).rule_id);
          a1(indx) := t(ddindx).stub_days;
          a2(indx) := t(ddindx).stub_amount;
          a3(indx) := t(ddindx).period;
          a4(indx) := t(ddindx).amount;
          a5(indx) := t(ddindx).sort_date;
          a6(indx) := t(ddindx).update_type;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p3;

  procedure rosetta_table_copy_in_p4(t out nocopy okl_la_payments_pvt.pym_del_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).chr_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).rgp_id := rosetta_g_miss_num_map(a1(indx));
          t(ddindx).slh_id := rosetta_g_miss_num_map(a2(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p4;
  procedure rosetta_table_copy_out_p4(t okl_la_payments_pvt.pym_del_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).chr_id);
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).rgp_id);
          a2(indx) := rosetta_g_miss_num_map(t(ddindx).slh_id);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p4;

  procedure process_payment(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_chr_id  NUMBER
    , p_service_fee_id  NUMBER
    , p_asset_id  NUMBER
    , p_payment_id  NUMBER
    , p10_a0 JTF_NUMBER_TABLE
    , p10_a1 JTF_VARCHAR2_TABLE_500
    , p10_a2 JTF_VARCHAR2_TABLE_500
    , p10_a3 JTF_VARCHAR2_TABLE_500
    , p10_a4 JTF_VARCHAR2_TABLE_500
    , p10_a5 JTF_VARCHAR2_TABLE_500
    , p10_a6 JTF_VARCHAR2_TABLE_100
    , p_update_type  VARCHAR2
    , p12_a0 out nocopy JTF_NUMBER_TABLE
    , p12_a1 out nocopy JTF_NUMBER_TABLE
    , p12_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a6 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a7 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a8 out nocopy JTF_VARCHAR2_TABLE_200
    , p12_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a10 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a11 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a12 out nocopy JTF_NUMBER_TABLE
    , p12_a13 out nocopy JTF_NUMBER_TABLE
    , p12_a14 out nocopy JTF_NUMBER_TABLE
    , p12_a15 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a16 out nocopy JTF_VARCHAR2_TABLE_2000
    , p12_a17 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a18 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a19 out nocopy JTF_VARCHAR2_TABLE_500
    , p12_a20 out nocopy JTF_VARCHAR2_TABLE_500
    , p12_a21 out nocopy JTF_VARCHAR2_TABLE_500
    , p12_a22 out nocopy JTF_VARCHAR2_TABLE_500
    , p12_a23 out nocopy JTF_VARCHAR2_TABLE_500
    , p12_a24 out nocopy JTF_VARCHAR2_TABLE_500
    , p12_a25 out nocopy JTF_VARCHAR2_TABLE_500
    , p12_a26 out nocopy JTF_VARCHAR2_TABLE_500
    , p12_a27 out nocopy JTF_VARCHAR2_TABLE_500
    , p12_a28 out nocopy JTF_VARCHAR2_TABLE_500
    , p12_a29 out nocopy JTF_VARCHAR2_TABLE_500
    , p12_a30 out nocopy JTF_VARCHAR2_TABLE_500
    , p12_a31 out nocopy JTF_VARCHAR2_TABLE_500
    , p12_a32 out nocopy JTF_VARCHAR2_TABLE_500
    , p12_a33 out nocopy JTF_VARCHAR2_TABLE_500
    , p12_a34 out nocopy JTF_NUMBER_TABLE
    , p12_a35 out nocopy JTF_DATE_TABLE
    , p12_a36 out nocopy JTF_NUMBER_TABLE
    , p12_a37 out nocopy JTF_DATE_TABLE
    , p12_a38 out nocopy JTF_NUMBER_TABLE
    , p12_a39 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a40 out nocopy JTF_VARCHAR2_TABLE_500
    , p12_a41 out nocopy JTF_VARCHAR2_TABLE_500
    , p12_a42 out nocopy JTF_VARCHAR2_TABLE_500
    , p12_a43 out nocopy JTF_VARCHAR2_TABLE_500
    , p12_a44 out nocopy JTF_VARCHAR2_TABLE_500
    , p12_a45 out nocopy JTF_VARCHAR2_TABLE_500
    , p12_a46 out nocopy JTF_VARCHAR2_TABLE_500
    , p12_a47 out nocopy JTF_VARCHAR2_TABLE_500
    , p12_a48 out nocopy JTF_VARCHAR2_TABLE_500
    , p12_a49 out nocopy JTF_VARCHAR2_TABLE_500
    , p12_a50 out nocopy JTF_VARCHAR2_TABLE_500
    , p12_a51 out nocopy JTF_VARCHAR2_TABLE_500
    , p12_a52 out nocopy JTF_VARCHAR2_TABLE_500
    , p12_a53 out nocopy JTF_VARCHAR2_TABLE_500
    , p12_a54 out nocopy JTF_VARCHAR2_TABLE_500
    , p12_a55 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a56 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a57 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a58 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a59 out nocopy JTF_NUMBER_TABLE
    , p9_a0  VARCHAR2 := fnd_api.g_miss_char
    , p9_a1  VARCHAR2 := fnd_api.g_miss_char
    , p9_a2  VARCHAR2 := fnd_api.g_miss_char
    , p9_a3  VARCHAR2 := fnd_api.g_miss_char
    , p9_a4  VARCHAR2 := fnd_api.g_miss_char
    , p9_a5  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_pym_hdr_rec okl_la_payments_pvt.pym_hdr_rec_type;
    ddp_pym_tbl okl_la_payments_pvt.pym_tbl_type;
    ddx_rulv_tbl okl_la_payments_pvt.rulv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any









    ddp_pym_hdr_rec.structure := p9_a0;
    ddp_pym_hdr_rec.structure_name := p9_a1;
    ddp_pym_hdr_rec.frequency := p9_a2;
    ddp_pym_hdr_rec.frequency_name := p9_a3;
    ddp_pym_hdr_rec.arrears := p9_a4;
    ddp_pym_hdr_rec.arrears_name := p9_a5;

    okl_la_payments_pvt_w.rosetta_table_copy_in_p3(ddp_pym_tbl, p10_a0
      , p10_a1
      , p10_a2
      , p10_a3
      , p10_a4
      , p10_a5
      , p10_a6
      );



    -- here's the delegated call to the old PL/SQL routine
    okl_la_payments_pvt.process_payment(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_chr_id,
      p_service_fee_id,
      p_asset_id,
      p_payment_id,
      ddp_pym_hdr_rec,
      ddp_pym_tbl,
      p_update_type,
      ddx_rulv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any












    okl_rule_pub_w.rosetta_table_copy_out_p2(ddx_rulv_tbl, p12_a0
      , p12_a1
      , p12_a2
      , p12_a3
      , p12_a4
      , p12_a5
      , p12_a6
      , p12_a7
      , p12_a8
      , p12_a9
      , p12_a10
      , p12_a11
      , p12_a12
      , p12_a13
      , p12_a14
      , p12_a15
      , p12_a16
      , p12_a17
      , p12_a18
      , p12_a19
      , p12_a20
      , p12_a21
      , p12_a22
      , p12_a23
      , p12_a24
      , p12_a25
      , p12_a26
      , p12_a27
      , p12_a28
      , p12_a29
      , p12_a30
      , p12_a31
      , p12_a32
      , p12_a33
      , p12_a34
      , p12_a35
      , p12_a36
      , p12_a37
      , p12_a38
      , p12_a39
      , p12_a40
      , p12_a41
      , p12_a42
      , p12_a43
      , p12_a44
      , p12_a45
      , p12_a46
      , p12_a47
      , p12_a48
      , p12_a49
      , p12_a50
      , p12_a51
      , p12_a52
      , p12_a53
      , p12_a54
      , p12_a55
      , p12_a56
      , p12_a57
      , p12_a58
      , p12_a59
      );
  end;

  procedure process_payment(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_chr_id  NUMBER
    , p_service_fee_id  NUMBER
    , p_asset_id  NUMBER
    , p_payment_id  NUMBER
    , p_update_type  VARCHAR2
    , p10_a0 out nocopy JTF_NUMBER_TABLE
    , p10_a1 out nocopy JTF_NUMBER_TABLE
    , p10_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a6 out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a7 out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a8 out nocopy JTF_VARCHAR2_TABLE_200
    , p10_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a10 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a11 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a12 out nocopy JTF_NUMBER_TABLE
    , p10_a13 out nocopy JTF_NUMBER_TABLE
    , p10_a14 out nocopy JTF_NUMBER_TABLE
    , p10_a15 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a16 out nocopy JTF_VARCHAR2_TABLE_2000
    , p10_a17 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a18 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a19 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a20 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a21 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a22 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a23 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a24 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a25 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a26 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a27 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a28 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a29 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a30 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a31 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a32 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a33 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a34 out nocopy JTF_NUMBER_TABLE
    , p10_a35 out nocopy JTF_DATE_TABLE
    , p10_a36 out nocopy JTF_NUMBER_TABLE
    , p10_a37 out nocopy JTF_DATE_TABLE
    , p10_a38 out nocopy JTF_NUMBER_TABLE
    , p10_a39 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a40 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a41 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a42 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a43 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a44 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a45 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a46 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a47 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a48 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a49 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a50 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a51 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a52 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a53 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a54 out nocopy JTF_VARCHAR2_TABLE_500
    , p10_a55 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a56 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a57 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a58 out nocopy JTF_VARCHAR2_TABLE_100
    , p10_a59 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddx_rulv_tbl okl_la_payments_pvt.rulv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any











    -- here's the delegated call to the old PL/SQL routine
    okl_la_payments_pvt.process_payment(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_chr_id,
      p_service_fee_id,
      p_asset_id,
      p_payment_id,
      p_update_type,
      ddx_rulv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any










    okl_rule_pub_w.rosetta_table_copy_out_p2(ddx_rulv_tbl, p10_a0
      , p10_a1
      , p10_a2
      , p10_a3
      , p10_a4
      , p10_a5
      , p10_a6
      , p10_a7
      , p10_a8
      , p10_a9
      , p10_a10
      , p10_a11
      , p10_a12
      , p10_a13
      , p10_a14
      , p10_a15
      , p10_a16
      , p10_a17
      , p10_a18
      , p10_a19
      , p10_a20
      , p10_a21
      , p10_a22
      , p10_a23
      , p10_a24
      , p10_a25
      , p10_a26
      , p10_a27
      , p10_a28
      , p10_a29
      , p10_a30
      , p10_a31
      , p10_a32
      , p10_a33
      , p10_a34
      , p10_a35
      , p10_a36
      , p10_a37
      , p10_a38
      , p10_a39
      , p10_a40
      , p10_a41
      , p10_a42
      , p10_a43
      , p10_a44
      , p10_a45
      , p10_a46
      , p10_a47
      , p10_a48
      , p10_a49
      , p10_a50
      , p10_a51
      , p10_a52
      , p10_a53
      , p10_a54
      , p10_a55
      , p10_a56
      , p10_a57
      , p10_a58
      , p10_a59
      );
  end;

  procedure delete_payment(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
  )

  as
    ddp_del_pym_tbl okl_la_payments_pvt.pym_del_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_la_payments_pvt_w.rosetta_table_copy_in_p4(ddp_del_pym_tbl, p5_a0
      , p5_a1
      , p5_a2
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_la_payments_pvt.delete_payment(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_del_pym_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

end okl_la_payments_pvt_w;

/
