--------------------------------------------------------
--  DDL for Package Body OKL_POOLCONC_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_POOLCONC_PVT_W" as
  /* $Header: OKLESZCB.pls 120.2 2007/12/18 06:51:29 ssdeshpa ship $ */
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

  procedure rosetta_table_copy_in_p74(t out nocopy okl_poolconc_pvt.error_message_type, a0 JTF_VARCHAR2_TABLE_2000) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx) := a0(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p74;
  procedure rosetta_table_copy_out_p74(t okl_poolconc_pvt.error_message_type, a0 out nocopy JTF_VARCHAR2_TABLE_2000) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_2000();
  else
      a0 := JTF_VARCHAR2_TABLE_2000();
      if t.count > 0 then
        a0.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p74;

  procedure add_pool_contents_ui(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_request_id out nocopy  NUMBER
    , p_sty_id1  NUMBER
    , p_sty_id2  NUMBER
    , p_stream_type_subclass  VARCHAR2
    , p_multi_org  VARCHAR2
    , p6_a0  NUMBER := 0-1962.0724
    , p6_a1  VARCHAR2 := fnd_api.g_miss_char
    , p6_a2  VARCHAR2 := fnd_api.g_miss_char
    , p6_a3  NUMBER := 0-1962.0724
    , p6_a4  VARCHAR2 := fnd_api.g_miss_char
    , p6_a5  NUMBER := 0-1962.0724
    , p6_a6  NUMBER := 0-1962.0724
    , p6_a7  VARCHAR2 := fnd_api.g_miss_char
    , p6_a8  NUMBER := 0-1962.0724
    , p6_a9  DATE := fnd_api.g_miss_date
    , p6_a10  DATE := fnd_api.g_miss_date
    , p6_a11  DATE := fnd_api.g_miss_date
    , p6_a12  DATE := fnd_api.g_miss_date
    , p6_a13  NUMBER := 0-1962.0724
    , p6_a14  VARCHAR2 := fnd_api.g_miss_char
    , p6_a15  VARCHAR2 := fnd_api.g_miss_char
    , p6_a16  NUMBER := 0-1962.0724
    , p6_a17  NUMBER := 0-1962.0724
    , p6_a18  VARCHAR2 := fnd_api.g_miss_char
    , p6_a19  VARCHAR2 := fnd_api.g_miss_char
    , p6_a20  VARCHAR2 := fnd_api.g_miss_char
    , p6_a21  NUMBER := 0-1962.0724
    , p6_a22  NUMBER := 0-1962.0724
    , p6_a23  NUMBER := 0-1962.0724
    , p6_a24  NUMBER := 0-1962.0724
    , p6_a25  NUMBER := 0-1962.0724
    , p6_a26  NUMBER := 0-1962.0724
    , p6_a27  NUMBER := 0-1962.0724
    , p6_a28  VARCHAR2 := fnd_api.g_miss_char
    , p6_a29  VARCHAR2 := fnd_api.g_miss_char
    , p6_a30  VARCHAR2 := fnd_api.g_miss_char
    , p6_a31  VARCHAR2 := fnd_api.g_miss_char
    , p6_a32  DATE := fnd_api.g_miss_date
    , p6_a33  DATE := fnd_api.g_miss_date
    , p6_a34  NUMBER := 0-1962.0724
    , p6_a35  NUMBER := 0-1962.0724
    , p6_a36  DATE := fnd_api.g_miss_date
    , p6_a37  DATE := fnd_api.g_miss_date
    , p6_a38  VARCHAR2 := fnd_api.g_miss_char
    , p6_a39  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_polsrch_rec okl_poolconc_pvt.polsrch_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any






    ddp_polsrch_rec.cust_object1_id1 := rosetta_g_miss_num_map(p6_a0);
    ddp_polsrch_rec.lessee := p6_a1;
    ddp_polsrch_rec.sic_code := p6_a2;
    ddp_polsrch_rec.dnz_chr_id := rosetta_g_miss_num_map(p6_a3);
    ddp_polsrch_rec.contract_number := p6_a4;
    ddp_polsrch_rec.pre_tax_yield_from := rosetta_g_miss_num_map(p6_a5);
    ddp_polsrch_rec.pre_tax_yield_to := rosetta_g_miss_num_map(p6_a6);
    ddp_polsrch_rec.book_classification := p6_a7;
    ddp_polsrch_rec.pdt_id := rosetta_g_miss_num_map(p6_a8);
    ddp_polsrch_rec.start_from_date := rosetta_g_miss_date_in_map(p6_a9);
    ddp_polsrch_rec.start_to_date := rosetta_g_miss_date_in_map(p6_a10);
    ddp_polsrch_rec.end_from_date := rosetta_g_miss_date_in_map(p6_a11);
    ddp_polsrch_rec.end_to_date := rosetta_g_miss_date_in_map(p6_a12);
    ddp_polsrch_rec.operating_unit := rosetta_g_miss_num_map(p6_a13);
    ddp_polsrch_rec.currency_code := p6_a14;
    ddp_polsrch_rec.tax_owner := p6_a15;
    ddp_polsrch_rec.kle_id := rosetta_g_miss_num_map(p6_a16);
    ddp_polsrch_rec.asset_id := rosetta_g_miss_num_map(p6_a17);
    ddp_polsrch_rec.asset_number := p6_a18;
    ddp_polsrch_rec.model_number := p6_a19;
    ddp_polsrch_rec.manufacturer_name := p6_a20;
    ddp_polsrch_rec.location_id := rosetta_g_miss_num_map(p6_a21);
    ddp_polsrch_rec.item_id1 := rosetta_g_miss_num_map(p6_a22);
    ddp_polsrch_rec.vendor_id1 := rosetta_g_miss_num_map(p6_a23);
    ddp_polsrch_rec.oec_from := rosetta_g_miss_num_map(p6_a24);
    ddp_polsrch_rec.oec_to := rosetta_g_miss_num_map(p6_a25);
    ddp_polsrch_rec.residual_percentage := rosetta_g_miss_num_map(p6_a26);
    ddp_polsrch_rec.sty_id := rosetta_g_miss_num_map(p6_a27);
    ddp_polsrch_rec.stream_type_code := p6_a28;
    ddp_polsrch_rec.stream_type_name := p6_a29;
    ddp_polsrch_rec.stream_say_code := p6_a30;
    ddp_polsrch_rec.stream_active_yn := p6_a31;
    ddp_polsrch_rec.stream_element_from_date := rosetta_g_miss_date_in_map(p6_a32);
    ddp_polsrch_rec.stream_element_to_date := rosetta_g_miss_date_in_map(p6_a33);
    ddp_polsrch_rec.stream_element_amount := rosetta_g_miss_num_map(p6_a34);
    ddp_polsrch_rec.pol_id := rosetta_g_miss_num_map(p6_a35);
    ddp_polsrch_rec.streams_from_date := rosetta_g_miss_date_in_map(p6_a36);
    ddp_polsrch_rec.streams_to_date := rosetta_g_miss_date_in_map(p6_a37);
    ddp_polsrch_rec.stream_element_payment_freq := p6_a38;
    ddp_polsrch_rec.cust_crd_clf_code := p6_a39;





    -- here's the delegated call to the old PL/SQL routine
    okl_poolconc_pvt.add_pool_contents_ui(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      x_request_id,
      ddp_polsrch_rec,
      p_sty_id1,
      p_sty_id2,
      p_stream_type_subclass,
      p_multi_org);

    -- copy data back from the local variables to OUT or IN-OUT args, if any










  end;

  procedure cleanup_pool_contents_ui(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_request_id out nocopy  NUMBER
    , p_stream_type_subclass  VARCHAR2
    , p_multi_org  VARCHAR2
    , p_action_code  VARCHAR2
    , p6_a0  NUMBER := 0-1962.0724
    , p6_a1  VARCHAR2 := fnd_api.g_miss_char
    , p6_a2  VARCHAR2 := fnd_api.g_miss_char
    , p6_a3  NUMBER := 0-1962.0724
    , p6_a4  VARCHAR2 := fnd_api.g_miss_char
    , p6_a5  NUMBER := 0-1962.0724
    , p6_a6  NUMBER := 0-1962.0724
    , p6_a7  VARCHAR2 := fnd_api.g_miss_char
    , p6_a8  NUMBER := 0-1962.0724
    , p6_a9  DATE := fnd_api.g_miss_date
    , p6_a10  DATE := fnd_api.g_miss_date
    , p6_a11  DATE := fnd_api.g_miss_date
    , p6_a12  DATE := fnd_api.g_miss_date
    , p6_a13  NUMBER := 0-1962.0724
    , p6_a14  VARCHAR2 := fnd_api.g_miss_char
    , p6_a15  VARCHAR2 := fnd_api.g_miss_char
    , p6_a16  NUMBER := 0-1962.0724
    , p6_a17  NUMBER := 0-1962.0724
    , p6_a18  VARCHAR2 := fnd_api.g_miss_char
    , p6_a19  VARCHAR2 := fnd_api.g_miss_char
    , p6_a20  VARCHAR2 := fnd_api.g_miss_char
    , p6_a21  NUMBER := 0-1962.0724
    , p6_a22  NUMBER := 0-1962.0724
    , p6_a23  NUMBER := 0-1962.0724
    , p6_a24  NUMBER := 0-1962.0724
    , p6_a25  NUMBER := 0-1962.0724
    , p6_a26  NUMBER := 0-1962.0724
    , p6_a27  NUMBER := 0-1962.0724
    , p6_a28  VARCHAR2 := fnd_api.g_miss_char
    , p6_a29  VARCHAR2 := fnd_api.g_miss_char
    , p6_a30  VARCHAR2 := fnd_api.g_miss_char
    , p6_a31  VARCHAR2 := fnd_api.g_miss_char
    , p6_a32  DATE := fnd_api.g_miss_date
    , p6_a33  DATE := fnd_api.g_miss_date
    , p6_a34  NUMBER := 0-1962.0724
    , p6_a35  NUMBER := 0-1962.0724
    , p6_a36  DATE := fnd_api.g_miss_date
    , p6_a37  DATE := fnd_api.g_miss_date
    , p6_a38  VARCHAR2 := fnd_api.g_miss_char
    , p6_a39  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_polsrch_rec okl_poolconc_pvt.polsrch_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any






    ddp_polsrch_rec.cust_object1_id1 := rosetta_g_miss_num_map(p6_a0);
    ddp_polsrch_rec.lessee := p6_a1;
    ddp_polsrch_rec.sic_code := p6_a2;
    ddp_polsrch_rec.dnz_chr_id := rosetta_g_miss_num_map(p6_a3);
    ddp_polsrch_rec.contract_number := p6_a4;
    ddp_polsrch_rec.pre_tax_yield_from := rosetta_g_miss_num_map(p6_a5);
    ddp_polsrch_rec.pre_tax_yield_to := rosetta_g_miss_num_map(p6_a6);
    ddp_polsrch_rec.book_classification := p6_a7;
    ddp_polsrch_rec.pdt_id := rosetta_g_miss_num_map(p6_a8);
    ddp_polsrch_rec.start_from_date := rosetta_g_miss_date_in_map(p6_a9);
    ddp_polsrch_rec.start_to_date := rosetta_g_miss_date_in_map(p6_a10);
    ddp_polsrch_rec.end_from_date := rosetta_g_miss_date_in_map(p6_a11);
    ddp_polsrch_rec.end_to_date := rosetta_g_miss_date_in_map(p6_a12);
    ddp_polsrch_rec.operating_unit := rosetta_g_miss_num_map(p6_a13);
    ddp_polsrch_rec.currency_code := p6_a14;
    ddp_polsrch_rec.tax_owner := p6_a15;
    ddp_polsrch_rec.kle_id := rosetta_g_miss_num_map(p6_a16);
    ddp_polsrch_rec.asset_id := rosetta_g_miss_num_map(p6_a17);
    ddp_polsrch_rec.asset_number := p6_a18;
    ddp_polsrch_rec.model_number := p6_a19;
    ddp_polsrch_rec.manufacturer_name := p6_a20;
    ddp_polsrch_rec.location_id := rosetta_g_miss_num_map(p6_a21);
    ddp_polsrch_rec.item_id1 := rosetta_g_miss_num_map(p6_a22);
    ddp_polsrch_rec.vendor_id1 := rosetta_g_miss_num_map(p6_a23);
    ddp_polsrch_rec.oec_from := rosetta_g_miss_num_map(p6_a24);
    ddp_polsrch_rec.oec_to := rosetta_g_miss_num_map(p6_a25);
    ddp_polsrch_rec.residual_percentage := rosetta_g_miss_num_map(p6_a26);
    ddp_polsrch_rec.sty_id := rosetta_g_miss_num_map(p6_a27);
    ddp_polsrch_rec.stream_type_code := p6_a28;
    ddp_polsrch_rec.stream_type_name := p6_a29;
    ddp_polsrch_rec.stream_say_code := p6_a30;
    ddp_polsrch_rec.stream_active_yn := p6_a31;
    ddp_polsrch_rec.stream_element_from_date := rosetta_g_miss_date_in_map(p6_a32);
    ddp_polsrch_rec.stream_element_to_date := rosetta_g_miss_date_in_map(p6_a33);
    ddp_polsrch_rec.stream_element_amount := rosetta_g_miss_num_map(p6_a34);
    ddp_polsrch_rec.pol_id := rosetta_g_miss_num_map(p6_a35);
    ddp_polsrch_rec.streams_from_date := rosetta_g_miss_date_in_map(p6_a36);
    ddp_polsrch_rec.streams_to_date := rosetta_g_miss_date_in_map(p6_a37);
    ddp_polsrch_rec.stream_element_payment_freq := p6_a38;
    ddp_polsrch_rec.cust_crd_clf_code := p6_a39;




    -- here's the delegated call to the old PL/SQL routine
    okl_poolconc_pvt.cleanup_pool_contents_ui(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      x_request_id,
      ddp_polsrch_rec,
      p_stream_type_subclass,
      p_multi_org,
      p_action_code);

    -- copy data back from the local variables to OUT or IN-OUT args, if any









  end;

end okl_poolconc_pvt_w;

/
