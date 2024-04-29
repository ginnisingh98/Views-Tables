--------------------------------------------------------
--  DDL for Package Body OKL_AM_SEND_FULFILLMENT_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_AM_SEND_FULFILLMENT_PVT_W" as
  /* $Header: OKLESFWB.pls 115.9 2002/12/13 19:34:08 gkadarka noship $ */
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

  procedure rosetta_table_copy_in_p9(t out nocopy okl_am_send_fulfillment_pvt.full_tbl_type, a0 JTF_VARCHAR2_TABLE_200
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_VARCHAR2_TABLE_200
    , a4 JTF_VARCHAR2_TABLE_200
    , a5 JTF_VARCHAR2_TABLE_200
    , a6 JTF_VARCHAR2_TABLE_200
    , a7 JTF_VARCHAR2_TABLE_200
    , a8 JTF_VARCHAR2_TABLE_200
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).p_ptm_code := a0(indx);
          t(ddindx).p_agent_id := rosetta_g_miss_num_map(a1(indx));
          t(ddindx).p_transaction_id := rosetta_g_miss_num_map(a2(indx));
          t(ddindx).p_recipient_type := a3(indx);
          t(ddindx).p_recipient_id := a4(indx);
          t(ddindx).p_expand_roles := a5(indx);
          t(ddindx).p_subject_line := a6(indx);
          t(ddindx).p_sender_email := a7(indx);
          t(ddindx).p_recipient_email := a8(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p9;
  procedure rosetta_table_copy_out_p9(t okl_am_send_fulfillment_pvt.full_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_200
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_VARCHAR2_TABLE_200
    , a4 out nocopy JTF_VARCHAR2_TABLE_200
    , a5 out nocopy JTF_VARCHAR2_TABLE_200
    , a6 out nocopy JTF_VARCHAR2_TABLE_200
    , a7 out nocopy JTF_VARCHAR2_TABLE_200
    , a8 out nocopy JTF_VARCHAR2_TABLE_200
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_200();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_VARCHAR2_TABLE_200();
    a4 := JTF_VARCHAR2_TABLE_200();
    a5 := JTF_VARCHAR2_TABLE_200();
    a6 := JTF_VARCHAR2_TABLE_200();
    a7 := JTF_VARCHAR2_TABLE_200();
    a8 := JTF_VARCHAR2_TABLE_200();
  else
      a0 := JTF_VARCHAR2_TABLE_200();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_VARCHAR2_TABLE_200();
      a4 := JTF_VARCHAR2_TABLE_200();
      a5 := JTF_VARCHAR2_TABLE_200();
      a6 := JTF_VARCHAR2_TABLE_200();
      a7 := JTF_VARCHAR2_TABLE_200();
      a8 := JTF_VARCHAR2_TABLE_200();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).p_ptm_code;
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).p_agent_id);
          a2(indx) := rosetta_g_miss_num_map(t(ddindx).p_transaction_id);
          a3(indx) := t(ddindx).p_recipient_type;
          a4(indx) := t(ddindx).p_recipient_id;
          a5(indx) := t(ddindx).p_expand_roles;
          a6(indx) := t(ddindx).p_subject_line;
          a7(indx) := t(ddindx).p_sender_email;
          a8(indx) := t(ddindx).p_recipient_email;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p9;

  procedure send_fulfillment(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy  VARCHAR2
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  NUMBER
    , p6_a3 out nocopy  VARCHAR2
    , p6_a4 out nocopy  VARCHAR2
    , p6_a5 out nocopy  VARCHAR2
    , p6_a6 out nocopy  VARCHAR2
    , p6_a7 out nocopy  VARCHAR2
    , p6_a8 out nocopy  VARCHAR2
    , p5_a0  VARCHAR2 := fnd_api.g_miss_char
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  VARCHAR2 := fnd_api.g_miss_char
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_send_rec okl_am_send_fulfillment_pvt.full_rec_type;
    ddx_send_rec okl_am_send_fulfillment_pvt.full_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_send_rec.p_ptm_code := p5_a0;
    ddp_send_rec.p_agent_id := rosetta_g_miss_num_map(p5_a1);
    ddp_send_rec.p_transaction_id := rosetta_g_miss_num_map(p5_a2);
    ddp_send_rec.p_recipient_type := p5_a3;
    ddp_send_rec.p_recipient_id := p5_a4;
    ddp_send_rec.p_expand_roles := p5_a5;
    ddp_send_rec.p_subject_line := p5_a6;
    ddp_send_rec.p_sender_email := p5_a7;
    ddp_send_rec.p_recipient_email := p5_a8;


    -- here's the delegated call to the old PL/SQL routine
    okl_am_send_fulfillment_pvt.send_fulfillment(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_send_rec,
      ddx_send_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := ddx_send_rec.p_ptm_code;
    p6_a1 := rosetta_g_miss_num_map(ddx_send_rec.p_agent_id);
    p6_a2 := rosetta_g_miss_num_map(ddx_send_rec.p_transaction_id);
    p6_a3 := ddx_send_rec.p_recipient_type;
    p6_a4 := ddx_send_rec.p_recipient_id;
    p6_a5 := ddx_send_rec.p_expand_roles;
    p6_a6 := ddx_send_rec.p_subject_line;
    p6_a7 := ddx_send_rec.p_sender_email;
    p6_a8 := ddx_send_rec.p_recipient_email;
  end;

  procedure send_fulfillment(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_VARCHAR2_TABLE_200
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_VARCHAR2_TABLE_200
    , p5_a4 JTF_VARCHAR2_TABLE_200
    , p5_a5 JTF_VARCHAR2_TABLE_200
    , p5_a6 JTF_VARCHAR2_TABLE_200
    , p5_a7 JTF_VARCHAR2_TABLE_200
    , p5_a8 JTF_VARCHAR2_TABLE_200
    , p6_a0 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_NUMBER_TABLE
    , p6_a3 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a4 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a5 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a6 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a7 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a8 out nocopy JTF_VARCHAR2_TABLE_200
  )

  as
    ddp_send_tbl okl_am_send_fulfillment_pvt.full_tbl_type;
    ddx_send_tbl okl_am_send_fulfillment_pvt.full_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_am_send_fulfillment_pvt_w.rosetta_table_copy_in_p9(ddp_send_tbl, p5_a0
      , p5_a1
      , p5_a2
      , p5_a3
      , p5_a4
      , p5_a5
      , p5_a6
      , p5_a7
      , p5_a8
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_am_send_fulfillment_pvt.send_fulfillment(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_send_tbl,
      ddx_send_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_am_send_fulfillment_pvt_w.rosetta_table_copy_out_p9(ddx_send_tbl, p6_a0
      , p6_a1
      , p6_a2
      , p6_a3
      , p6_a4
      , p6_a5
      , p6_a6
      , p6_a7
      , p6_a8
      );
  end;

  procedure send_terminate_quote(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_VARCHAR2_TABLE_100
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_VARCHAR2_TABLE_100
    , p5_a5 JTF_VARCHAR2_TABLE_100
    , p5_a6 JTF_DATE_TABLE
    , p5_a7 JTF_DATE_TABLE
    , p5_a8 JTF_NUMBER_TABLE
    , p5_a9 JTF_DATE_TABLE
    , p5_a10 JTF_NUMBER_TABLE
    , p5_a11 JTF_DATE_TABLE
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_NUMBER_TABLE
    , p5_a14 JTF_VARCHAR2_TABLE_100
    , p5_a15 JTF_VARCHAR2_TABLE_100
    , p5_a16 JTF_VARCHAR2_TABLE_100
    , p5_a17 JTF_VARCHAR2_TABLE_200
    , p5_a18 JTF_VARCHAR2_TABLE_100
    , p5_a19 JTF_VARCHAR2_TABLE_400
    , p5_a20 JTF_VARCHAR2_TABLE_2000
    , p5_a21 JTF_VARCHAR2_TABLE_100
    , p5_a22 JTF_VARCHAR2_TABLE_200
    , p5_a23 JTF_VARCHAR2_TABLE_100
    , p5_a24 JTF_VARCHAR2_TABLE_400
    , p5_a25 JTF_VARCHAR2_TABLE_2000
    , p5_a26 JTF_VARCHAR2_TABLE_2000
    , p5_a27 JTF_NUMBER_TABLE
    , p5_a28 JTF_DATE_TABLE
    , p5_a29 JTF_NUMBER_TABLE
    , p5_a30 JTF_VARCHAR2_TABLE_100
    , p5_a31 JTF_VARCHAR2_TABLE_100
    , p5_a32 JTF_VARCHAR2_TABLE_2000
    , p5_a33 JTF_VARCHAR2_TABLE_2000
    , p5_a34 JTF_NUMBER_TABLE
    , p5_a35 JTF_DATE_TABLE
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a3 out nocopy JTF_NUMBER_TABLE
    , p6_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a6 out nocopy JTF_DATE_TABLE
    , p6_a7 out nocopy JTF_DATE_TABLE
    , p6_a8 out nocopy JTF_NUMBER_TABLE
    , p6_a9 out nocopy JTF_DATE_TABLE
    , p6_a10 out nocopy JTF_NUMBER_TABLE
    , p6_a11 out nocopy JTF_DATE_TABLE
    , p6_a12 out nocopy JTF_NUMBER_TABLE
    , p6_a13 out nocopy JTF_NUMBER_TABLE
    , p6_a14 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a15 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a16 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a17 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a18 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a19 out nocopy JTF_VARCHAR2_TABLE_400
    , p6_a20 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a21 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a22 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a23 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a24 out nocopy JTF_VARCHAR2_TABLE_400
    , p6_a25 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a26 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a27 out nocopy JTF_NUMBER_TABLE
    , p6_a28 out nocopy JTF_DATE_TABLE
    , p6_a29 out nocopy JTF_NUMBER_TABLE
    , p6_a30 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a31 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a32 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a33 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a34 out nocopy JTF_NUMBER_TABLE
    , p6_a35 out nocopy JTF_DATE_TABLE
    , p8_a0 out nocopy  NUMBER
    , p8_a1 out nocopy  NUMBER
    , p8_a2 out nocopy  VARCHAR2
    , p8_a3 out nocopy  VARCHAR2
    , p8_a4 out nocopy  VARCHAR2
    , p8_a5 out nocopy  VARCHAR2
    , p8_a6 out nocopy  VARCHAR2
    , p8_a7 out nocopy  VARCHAR2
    , p8_a8 out nocopy  VARCHAR2
    , p8_a9 out nocopy  NUMBER
    , p8_a10 out nocopy  NUMBER
    , p8_a11 out nocopy  NUMBER
    , p8_a12 out nocopy  NUMBER
    , p8_a13 out nocopy  VARCHAR2
    , p8_a14 out nocopy  VARCHAR2
    , p8_a15 out nocopy  VARCHAR2
    , p8_a16 out nocopy  DATE
    , p8_a17 out nocopy  DATE
    , p8_a18 out nocopy  DATE
    , p8_a19 out nocopy  DATE
    , p8_a20 out nocopy  VARCHAR2
    , p8_a21 out nocopy  VARCHAR2
    , p8_a22 out nocopy  NUMBER
    , p8_a23 out nocopy  NUMBER
    , p8_a24 out nocopy  NUMBER
    , p8_a25 out nocopy  NUMBER
    , p8_a26 out nocopy  DATE
    , p8_a27 out nocopy  DATE
    , p8_a28 out nocopy  NUMBER
    , p8_a29 out nocopy  NUMBER
    , p8_a30 out nocopy  VARCHAR2
    , p8_a31 out nocopy  DATE
    , p8_a32 out nocopy  VARCHAR2
    , p8_a33 out nocopy  NUMBER
    , p8_a34 out nocopy  DATE
    , p8_a35 out nocopy  NUMBER
    , p8_a36 out nocopy  NUMBER
    , p8_a37 out nocopy  VARCHAR2
    , p8_a38 out nocopy  VARCHAR2
    , p8_a39 out nocopy  VARCHAR2
    , p8_a40 out nocopy  DATE
    , p8_a41 out nocopy  VARCHAR2
    , p8_a42 out nocopy  VARCHAR2
    , p8_a43 out nocopy  VARCHAR2
    , p8_a44 out nocopy  VARCHAR2
    , p8_a45 out nocopy  VARCHAR2
    , p8_a46 out nocopy  VARCHAR2
    , p8_a47 out nocopy  VARCHAR2
    , p8_a48 out nocopy  VARCHAR2
    , p8_a49 out nocopy  VARCHAR2
    , p8_a50 out nocopy  VARCHAR2
    , p8_a51 out nocopy  VARCHAR2
    , p8_a52 out nocopy  VARCHAR2
    , p8_a53 out nocopy  VARCHAR2
    , p8_a54 out nocopy  VARCHAR2
    , p8_a55 out nocopy  VARCHAR2
    , p8_a56 out nocopy  VARCHAR2
    , p8_a57 out nocopy  DATE
    , p8_a58 out nocopy  NUMBER
    , p8_a59 out nocopy  NUMBER
    , p8_a60 out nocopy  NUMBER
    , p8_a61 out nocopy  NUMBER
    , p8_a62 out nocopy  NUMBER
    , p8_a63 out nocopy  DATE
    , p8_a64 out nocopy  NUMBER
    , p8_a65 out nocopy  DATE
    , p8_a66 out nocopy  NUMBER
    , p8_a67 out nocopy  DATE
    , p8_a68 out nocopy  NUMBER
    , p8_a69 out nocopy  NUMBER
    , p8_a70 out nocopy  VARCHAR2
    , p8_a71 out nocopy  NUMBER
    , p8_a72 out nocopy  NUMBER
    , p8_a73 out nocopy  NUMBER
    , p8_a74 out nocopy  NUMBER
    , p8_a75 out nocopy  VARCHAR2
    , p8_a76 out nocopy  VARCHAR2
    , p8_a77 out nocopy  VARCHAR2
    , p8_a78 out nocopy  NUMBER
    , p8_a79 out nocopy  DATE
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  NUMBER := 0-1962.0724
    , p7_a2  VARCHAR2 := fnd_api.g_miss_char
    , p7_a3  VARCHAR2 := fnd_api.g_miss_char
    , p7_a4  VARCHAR2 := fnd_api.g_miss_char
    , p7_a5  VARCHAR2 := fnd_api.g_miss_char
    , p7_a6  VARCHAR2 := fnd_api.g_miss_char
    , p7_a7  VARCHAR2 := fnd_api.g_miss_char
    , p7_a8  VARCHAR2 := fnd_api.g_miss_char
    , p7_a9  NUMBER := 0-1962.0724
    , p7_a10  NUMBER := 0-1962.0724
    , p7_a11  NUMBER := 0-1962.0724
    , p7_a12  NUMBER := 0-1962.0724
    , p7_a13  VARCHAR2 := fnd_api.g_miss_char
    , p7_a14  VARCHAR2 := fnd_api.g_miss_char
    , p7_a15  VARCHAR2 := fnd_api.g_miss_char
    , p7_a16  DATE := fnd_api.g_miss_date
    , p7_a17  DATE := fnd_api.g_miss_date
    , p7_a18  DATE := fnd_api.g_miss_date
    , p7_a19  DATE := fnd_api.g_miss_date
    , p7_a20  VARCHAR2 := fnd_api.g_miss_char
    , p7_a21  VARCHAR2 := fnd_api.g_miss_char
    , p7_a22  NUMBER := 0-1962.0724
    , p7_a23  NUMBER := 0-1962.0724
    , p7_a24  NUMBER := 0-1962.0724
    , p7_a25  NUMBER := 0-1962.0724
    , p7_a26  DATE := fnd_api.g_miss_date
    , p7_a27  DATE := fnd_api.g_miss_date
    , p7_a28  NUMBER := 0-1962.0724
    , p7_a29  NUMBER := 0-1962.0724
    , p7_a30  VARCHAR2 := fnd_api.g_miss_char
    , p7_a31  DATE := fnd_api.g_miss_date
    , p7_a32  VARCHAR2 := fnd_api.g_miss_char
    , p7_a33  NUMBER := 0-1962.0724
    , p7_a34  DATE := fnd_api.g_miss_date
    , p7_a35  NUMBER := 0-1962.0724
    , p7_a36  NUMBER := 0-1962.0724
    , p7_a37  VARCHAR2 := fnd_api.g_miss_char
    , p7_a38  VARCHAR2 := fnd_api.g_miss_char
    , p7_a39  VARCHAR2 := fnd_api.g_miss_char
    , p7_a40  DATE := fnd_api.g_miss_date
    , p7_a41  VARCHAR2 := fnd_api.g_miss_char
    , p7_a42  VARCHAR2 := fnd_api.g_miss_char
    , p7_a43  VARCHAR2 := fnd_api.g_miss_char
    , p7_a44  VARCHAR2 := fnd_api.g_miss_char
    , p7_a45  VARCHAR2 := fnd_api.g_miss_char
    , p7_a46  VARCHAR2 := fnd_api.g_miss_char
    , p7_a47  VARCHAR2 := fnd_api.g_miss_char
    , p7_a48  VARCHAR2 := fnd_api.g_miss_char
    , p7_a49  VARCHAR2 := fnd_api.g_miss_char
    , p7_a50  VARCHAR2 := fnd_api.g_miss_char
    , p7_a51  VARCHAR2 := fnd_api.g_miss_char
    , p7_a52  VARCHAR2 := fnd_api.g_miss_char
    , p7_a53  VARCHAR2 := fnd_api.g_miss_char
    , p7_a54  VARCHAR2 := fnd_api.g_miss_char
    , p7_a55  VARCHAR2 := fnd_api.g_miss_char
    , p7_a56  VARCHAR2 := fnd_api.g_miss_char
    , p7_a57  DATE := fnd_api.g_miss_date
    , p7_a58  NUMBER := 0-1962.0724
    , p7_a59  NUMBER := 0-1962.0724
    , p7_a60  NUMBER := 0-1962.0724
    , p7_a61  NUMBER := 0-1962.0724
    , p7_a62  NUMBER := 0-1962.0724
    , p7_a63  DATE := fnd_api.g_miss_date
    , p7_a64  NUMBER := 0-1962.0724
    , p7_a65  DATE := fnd_api.g_miss_date
    , p7_a66  NUMBER := 0-1962.0724
    , p7_a67  DATE := fnd_api.g_miss_date
    , p7_a68  NUMBER := 0-1962.0724
    , p7_a69  NUMBER := 0-1962.0724
    , p7_a70  VARCHAR2 := fnd_api.g_miss_char
    , p7_a71  NUMBER := 0-1962.0724
    , p7_a72  NUMBER := 0-1962.0724
    , p7_a73  NUMBER := 0-1962.0724
    , p7_a74  NUMBER := 0-1962.0724
    , p7_a75  VARCHAR2 := fnd_api.g_miss_char
    , p7_a76  VARCHAR2 := fnd_api.g_miss_char
    , p7_a77  VARCHAR2 := fnd_api.g_miss_char
    , p7_a78  NUMBER := 0-1962.0724
    , p7_a79  DATE := fnd_api.g_miss_date
  )

  as
    ddp_party_tbl okl_am_send_fulfillment_pvt.q_party_uv_tbl_type;
    ddx_party_tbl okl_am_send_fulfillment_pvt.q_party_uv_tbl_type;
    ddp_qtev_rec okl_am_send_fulfillment_pvt.qtev_rec_type;
    ddx_qtev_rec okl_am_send_fulfillment_pvt.qtev_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_am_parties_pvt_w.rosetta_table_copy_in_p2(ddp_party_tbl, p5_a0
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
      );


    ddp_qtev_rec.id := rosetta_g_miss_num_map(p7_a0);
    ddp_qtev_rec.object_version_number := rosetta_g_miss_num_map(p7_a1);
    ddp_qtev_rec.sfwt_flag := p7_a2;
    ddp_qtev_rec.qrs_code := p7_a3;
    ddp_qtev_rec.qst_code := p7_a4;
    ddp_qtev_rec.qtp_code := p7_a5;
    ddp_qtev_rec.trn_code := p7_a6;
    ddp_qtev_rec.pop_code_end := p7_a7;
    ddp_qtev_rec.pop_code_early := p7_a8;
    ddp_qtev_rec.consolidated_qte_id := rosetta_g_miss_num_map(p7_a9);
    ddp_qtev_rec.khr_id := rosetta_g_miss_num_map(p7_a10);
    ddp_qtev_rec.art_id := rosetta_g_miss_num_map(p7_a11);
    ddp_qtev_rec.pdt_id := rosetta_g_miss_num_map(p7_a12);
    ddp_qtev_rec.early_termination_yn := p7_a13;
    ddp_qtev_rec.partial_yn := p7_a14;
    ddp_qtev_rec.preproceeds_yn := p7_a15;
    ddp_qtev_rec.date_requested := rosetta_g_miss_date_in_map(p7_a16);
    ddp_qtev_rec.date_proposal := rosetta_g_miss_date_in_map(p7_a17);
    ddp_qtev_rec.date_effective_to := rosetta_g_miss_date_in_map(p7_a18);
    ddp_qtev_rec.date_accepted := rosetta_g_miss_date_in_map(p7_a19);
    ddp_qtev_rec.summary_format_yn := p7_a20;
    ddp_qtev_rec.consolidated_yn := p7_a21;
    ddp_qtev_rec.principal_paydown_amount := rosetta_g_miss_num_map(p7_a22);
    ddp_qtev_rec.residual_amount := rosetta_g_miss_num_map(p7_a23);
    ddp_qtev_rec.yield := rosetta_g_miss_num_map(p7_a24);
    ddp_qtev_rec.rent_amount := rosetta_g_miss_num_map(p7_a25);
    ddp_qtev_rec.date_restructure_end := rosetta_g_miss_date_in_map(p7_a26);
    ddp_qtev_rec.date_restructure_start := rosetta_g_miss_date_in_map(p7_a27);
    ddp_qtev_rec.term := rosetta_g_miss_num_map(p7_a28);
    ddp_qtev_rec.purchase_percent := rosetta_g_miss_num_map(p7_a29);
    ddp_qtev_rec.comments := p7_a30;
    ddp_qtev_rec.date_due := rosetta_g_miss_date_in_map(p7_a31);
    ddp_qtev_rec.payment_frequency := p7_a32;
    ddp_qtev_rec.remaining_payments := rosetta_g_miss_num_map(p7_a33);
    ddp_qtev_rec.date_effective_from := rosetta_g_miss_date_in_map(p7_a34);
    ddp_qtev_rec.quote_number := rosetta_g_miss_num_map(p7_a35);
    ddp_qtev_rec.requested_by := rosetta_g_miss_num_map(p7_a36);
    ddp_qtev_rec.approved_yn := p7_a37;
    ddp_qtev_rec.accepted_yn := p7_a38;
    ddp_qtev_rec.payment_received_yn := p7_a39;
    ddp_qtev_rec.date_payment_received := rosetta_g_miss_date_in_map(p7_a40);
    ddp_qtev_rec.attribute_category := p7_a41;
    ddp_qtev_rec.attribute1 := p7_a42;
    ddp_qtev_rec.attribute2 := p7_a43;
    ddp_qtev_rec.attribute3 := p7_a44;
    ddp_qtev_rec.attribute4 := p7_a45;
    ddp_qtev_rec.attribute5 := p7_a46;
    ddp_qtev_rec.attribute6 := p7_a47;
    ddp_qtev_rec.attribute7 := p7_a48;
    ddp_qtev_rec.attribute8 := p7_a49;
    ddp_qtev_rec.attribute9 := p7_a50;
    ddp_qtev_rec.attribute10 := p7_a51;
    ddp_qtev_rec.attribute11 := p7_a52;
    ddp_qtev_rec.attribute12 := p7_a53;
    ddp_qtev_rec.attribute13 := p7_a54;
    ddp_qtev_rec.attribute14 := p7_a55;
    ddp_qtev_rec.attribute15 := p7_a56;
    ddp_qtev_rec.date_approved := rosetta_g_miss_date_in_map(p7_a57);
    ddp_qtev_rec.approved_by := rosetta_g_miss_num_map(p7_a58);
    ddp_qtev_rec.org_id := rosetta_g_miss_num_map(p7_a59);
    ddp_qtev_rec.request_id := rosetta_g_miss_num_map(p7_a60);
    ddp_qtev_rec.program_application_id := rosetta_g_miss_num_map(p7_a61);
    ddp_qtev_rec.program_id := rosetta_g_miss_num_map(p7_a62);
    ddp_qtev_rec.program_update_date := rosetta_g_miss_date_in_map(p7_a63);
    ddp_qtev_rec.created_by := rosetta_g_miss_num_map(p7_a64);
    ddp_qtev_rec.creation_date := rosetta_g_miss_date_in_map(p7_a65);
    ddp_qtev_rec.last_updated_by := rosetta_g_miss_num_map(p7_a66);
    ddp_qtev_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a67);
    ddp_qtev_rec.last_update_login := rosetta_g_miss_num_map(p7_a68);
    ddp_qtev_rec.purchase_amount := rosetta_g_miss_num_map(p7_a69);
    ddp_qtev_rec.purchase_formula := p7_a70;
    ddp_qtev_rec.asset_value := rosetta_g_miss_num_map(p7_a71);
    ddp_qtev_rec.residual_value := rosetta_g_miss_num_map(p7_a72);
    ddp_qtev_rec.unbilled_receivables := rosetta_g_miss_num_map(p7_a73);
    ddp_qtev_rec.gain_loss := rosetta_g_miss_num_map(p7_a74);
    ddp_qtev_rec.currency_code := p7_a75;
    ddp_qtev_rec.currency_conversion_code := p7_a76;
    ddp_qtev_rec.currency_conversion_type := p7_a77;
    ddp_qtev_rec.currency_conversion_rate := rosetta_g_miss_num_map(p7_a78);
    ddp_qtev_rec.currency_conversion_date := rosetta_g_miss_date_in_map(p7_a79);


    -- here's the delegated call to the old PL/SQL routine
    okl_am_send_fulfillment_pvt.send_terminate_quote(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_party_tbl,
      ddx_party_tbl,
      ddp_qtev_rec,
      ddx_qtev_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_am_parties_pvt_w.rosetta_table_copy_out_p2(ddx_party_tbl, p6_a0
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
      );


    p8_a0 := rosetta_g_miss_num_map(ddx_qtev_rec.id);
    p8_a1 := rosetta_g_miss_num_map(ddx_qtev_rec.object_version_number);
    p8_a2 := ddx_qtev_rec.sfwt_flag;
    p8_a3 := ddx_qtev_rec.qrs_code;
    p8_a4 := ddx_qtev_rec.qst_code;
    p8_a5 := ddx_qtev_rec.qtp_code;
    p8_a6 := ddx_qtev_rec.trn_code;
    p8_a7 := ddx_qtev_rec.pop_code_end;
    p8_a8 := ddx_qtev_rec.pop_code_early;
    p8_a9 := rosetta_g_miss_num_map(ddx_qtev_rec.consolidated_qte_id);
    p8_a10 := rosetta_g_miss_num_map(ddx_qtev_rec.khr_id);
    p8_a11 := rosetta_g_miss_num_map(ddx_qtev_rec.art_id);
    p8_a12 := rosetta_g_miss_num_map(ddx_qtev_rec.pdt_id);
    p8_a13 := ddx_qtev_rec.early_termination_yn;
    p8_a14 := ddx_qtev_rec.partial_yn;
    p8_a15 := ddx_qtev_rec.preproceeds_yn;
    p8_a16 := ddx_qtev_rec.date_requested;
    p8_a17 := ddx_qtev_rec.date_proposal;
    p8_a18 := ddx_qtev_rec.date_effective_to;
    p8_a19 := ddx_qtev_rec.date_accepted;
    p8_a20 := ddx_qtev_rec.summary_format_yn;
    p8_a21 := ddx_qtev_rec.consolidated_yn;
    p8_a22 := rosetta_g_miss_num_map(ddx_qtev_rec.principal_paydown_amount);
    p8_a23 := rosetta_g_miss_num_map(ddx_qtev_rec.residual_amount);
    p8_a24 := rosetta_g_miss_num_map(ddx_qtev_rec.yield);
    p8_a25 := rosetta_g_miss_num_map(ddx_qtev_rec.rent_amount);
    p8_a26 := ddx_qtev_rec.date_restructure_end;
    p8_a27 := ddx_qtev_rec.date_restructure_start;
    p8_a28 := rosetta_g_miss_num_map(ddx_qtev_rec.term);
    p8_a29 := rosetta_g_miss_num_map(ddx_qtev_rec.purchase_percent);
    p8_a30 := ddx_qtev_rec.comments;
    p8_a31 := ddx_qtev_rec.date_due;
    p8_a32 := ddx_qtev_rec.payment_frequency;
    p8_a33 := rosetta_g_miss_num_map(ddx_qtev_rec.remaining_payments);
    p8_a34 := ddx_qtev_rec.date_effective_from;
    p8_a35 := rosetta_g_miss_num_map(ddx_qtev_rec.quote_number);
    p8_a36 := rosetta_g_miss_num_map(ddx_qtev_rec.requested_by);
    p8_a37 := ddx_qtev_rec.approved_yn;
    p8_a38 := ddx_qtev_rec.accepted_yn;
    p8_a39 := ddx_qtev_rec.payment_received_yn;
    p8_a40 := ddx_qtev_rec.date_payment_received;
    p8_a41 := ddx_qtev_rec.attribute_category;
    p8_a42 := ddx_qtev_rec.attribute1;
    p8_a43 := ddx_qtev_rec.attribute2;
    p8_a44 := ddx_qtev_rec.attribute3;
    p8_a45 := ddx_qtev_rec.attribute4;
    p8_a46 := ddx_qtev_rec.attribute5;
    p8_a47 := ddx_qtev_rec.attribute6;
    p8_a48 := ddx_qtev_rec.attribute7;
    p8_a49 := ddx_qtev_rec.attribute8;
    p8_a50 := ddx_qtev_rec.attribute9;
    p8_a51 := ddx_qtev_rec.attribute10;
    p8_a52 := ddx_qtev_rec.attribute11;
    p8_a53 := ddx_qtev_rec.attribute12;
    p8_a54 := ddx_qtev_rec.attribute13;
    p8_a55 := ddx_qtev_rec.attribute14;
    p8_a56 := ddx_qtev_rec.attribute15;
    p8_a57 := ddx_qtev_rec.date_approved;
    p8_a58 := rosetta_g_miss_num_map(ddx_qtev_rec.approved_by);
    p8_a59 := rosetta_g_miss_num_map(ddx_qtev_rec.org_id);
    p8_a60 := rosetta_g_miss_num_map(ddx_qtev_rec.request_id);
    p8_a61 := rosetta_g_miss_num_map(ddx_qtev_rec.program_application_id);
    p8_a62 := rosetta_g_miss_num_map(ddx_qtev_rec.program_id);
    p8_a63 := ddx_qtev_rec.program_update_date;
    p8_a64 := rosetta_g_miss_num_map(ddx_qtev_rec.created_by);
    p8_a65 := ddx_qtev_rec.creation_date;
    p8_a66 := rosetta_g_miss_num_map(ddx_qtev_rec.last_updated_by);
    p8_a67 := ddx_qtev_rec.last_update_date;
    p8_a68 := rosetta_g_miss_num_map(ddx_qtev_rec.last_update_login);
    p8_a69 := rosetta_g_miss_num_map(ddx_qtev_rec.purchase_amount);
    p8_a70 := ddx_qtev_rec.purchase_formula;
    p8_a71 := rosetta_g_miss_num_map(ddx_qtev_rec.asset_value);
    p8_a72 := rosetta_g_miss_num_map(ddx_qtev_rec.residual_value);
    p8_a73 := rosetta_g_miss_num_map(ddx_qtev_rec.unbilled_receivables);
    p8_a74 := rosetta_g_miss_num_map(ddx_qtev_rec.gain_loss);
    p8_a75 := ddx_qtev_rec.currency_code;
    p8_a76 := ddx_qtev_rec.currency_conversion_code;
    p8_a77 := ddx_qtev_rec.currency_conversion_type;
    p8_a78 := rosetta_g_miss_num_map(ddx_qtev_rec.currency_conversion_rate);
    p8_a79 := ddx_qtev_rec.currency_conversion_date;
  end;

  procedure send_repurchase_quote(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_VARCHAR2_TABLE_200
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_VARCHAR2_TABLE_200
    , p5_a4 JTF_VARCHAR2_TABLE_200
    , p5_a5 JTF_VARCHAR2_TABLE_200
    , p5_a6 JTF_VARCHAR2_TABLE_200
    , p5_a7 JTF_VARCHAR2_TABLE_200
    , p5_a8 JTF_VARCHAR2_TABLE_200
    , p6_a0 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_NUMBER_TABLE
    , p6_a3 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a4 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a5 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a6 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a7 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a8 out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a0 out nocopy  NUMBER
    , p8_a1 out nocopy  NUMBER
    , p8_a2 out nocopy  VARCHAR2
    , p8_a3 out nocopy  VARCHAR2
    , p8_a4 out nocopy  VARCHAR2
    , p8_a5 out nocopy  VARCHAR2
    , p8_a6 out nocopy  VARCHAR2
    , p8_a7 out nocopy  VARCHAR2
    , p8_a8 out nocopy  VARCHAR2
    , p8_a9 out nocopy  NUMBER
    , p8_a10 out nocopy  NUMBER
    , p8_a11 out nocopy  NUMBER
    , p8_a12 out nocopy  NUMBER
    , p8_a13 out nocopy  VARCHAR2
    , p8_a14 out nocopy  VARCHAR2
    , p8_a15 out nocopy  VARCHAR2
    , p8_a16 out nocopy  DATE
    , p8_a17 out nocopy  DATE
    , p8_a18 out nocopy  DATE
    , p8_a19 out nocopy  DATE
    , p8_a20 out nocopy  VARCHAR2
    , p8_a21 out nocopy  VARCHAR2
    , p8_a22 out nocopy  NUMBER
    , p8_a23 out nocopy  NUMBER
    , p8_a24 out nocopy  NUMBER
    , p8_a25 out nocopy  NUMBER
    , p8_a26 out nocopy  DATE
    , p8_a27 out nocopy  DATE
    , p8_a28 out nocopy  NUMBER
    , p8_a29 out nocopy  NUMBER
    , p8_a30 out nocopy  VARCHAR2
    , p8_a31 out nocopy  DATE
    , p8_a32 out nocopy  VARCHAR2
    , p8_a33 out nocopy  NUMBER
    , p8_a34 out nocopy  DATE
    , p8_a35 out nocopy  NUMBER
    , p8_a36 out nocopy  NUMBER
    , p8_a37 out nocopy  VARCHAR2
    , p8_a38 out nocopy  VARCHAR2
    , p8_a39 out nocopy  VARCHAR2
    , p8_a40 out nocopy  DATE
    , p8_a41 out nocopy  VARCHAR2
    , p8_a42 out nocopy  VARCHAR2
    , p8_a43 out nocopy  VARCHAR2
    , p8_a44 out nocopy  VARCHAR2
    , p8_a45 out nocopy  VARCHAR2
    , p8_a46 out nocopy  VARCHAR2
    , p8_a47 out nocopy  VARCHAR2
    , p8_a48 out nocopy  VARCHAR2
    , p8_a49 out nocopy  VARCHAR2
    , p8_a50 out nocopy  VARCHAR2
    , p8_a51 out nocopy  VARCHAR2
    , p8_a52 out nocopy  VARCHAR2
    , p8_a53 out nocopy  VARCHAR2
    , p8_a54 out nocopy  VARCHAR2
    , p8_a55 out nocopy  VARCHAR2
    , p8_a56 out nocopy  VARCHAR2
    , p8_a57 out nocopy  DATE
    , p8_a58 out nocopy  NUMBER
    , p8_a59 out nocopy  NUMBER
    , p8_a60 out nocopy  NUMBER
    , p8_a61 out nocopy  NUMBER
    , p8_a62 out nocopy  NUMBER
    , p8_a63 out nocopy  DATE
    , p8_a64 out nocopy  NUMBER
    , p8_a65 out nocopy  DATE
    , p8_a66 out nocopy  NUMBER
    , p8_a67 out nocopy  DATE
    , p8_a68 out nocopy  NUMBER
    , p8_a69 out nocopy  NUMBER
    , p8_a70 out nocopy  VARCHAR2
    , p8_a71 out nocopy  NUMBER
    , p8_a72 out nocopy  NUMBER
    , p8_a73 out nocopy  NUMBER
    , p8_a74 out nocopy  NUMBER
    , p8_a75 out nocopy  VARCHAR2
    , p8_a76 out nocopy  VARCHAR2
    , p8_a77 out nocopy  VARCHAR2
    , p8_a78 out nocopy  NUMBER
    , p8_a79 out nocopy  DATE
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  NUMBER := 0-1962.0724
    , p7_a2  VARCHAR2 := fnd_api.g_miss_char
    , p7_a3  VARCHAR2 := fnd_api.g_miss_char
    , p7_a4  VARCHAR2 := fnd_api.g_miss_char
    , p7_a5  VARCHAR2 := fnd_api.g_miss_char
    , p7_a6  VARCHAR2 := fnd_api.g_miss_char
    , p7_a7  VARCHAR2 := fnd_api.g_miss_char
    , p7_a8  VARCHAR2 := fnd_api.g_miss_char
    , p7_a9  NUMBER := 0-1962.0724
    , p7_a10  NUMBER := 0-1962.0724
    , p7_a11  NUMBER := 0-1962.0724
    , p7_a12  NUMBER := 0-1962.0724
    , p7_a13  VARCHAR2 := fnd_api.g_miss_char
    , p7_a14  VARCHAR2 := fnd_api.g_miss_char
    , p7_a15  VARCHAR2 := fnd_api.g_miss_char
    , p7_a16  DATE := fnd_api.g_miss_date
    , p7_a17  DATE := fnd_api.g_miss_date
    , p7_a18  DATE := fnd_api.g_miss_date
    , p7_a19  DATE := fnd_api.g_miss_date
    , p7_a20  VARCHAR2 := fnd_api.g_miss_char
    , p7_a21  VARCHAR2 := fnd_api.g_miss_char
    , p7_a22  NUMBER := 0-1962.0724
    , p7_a23  NUMBER := 0-1962.0724
    , p7_a24  NUMBER := 0-1962.0724
    , p7_a25  NUMBER := 0-1962.0724
    , p7_a26  DATE := fnd_api.g_miss_date
    , p7_a27  DATE := fnd_api.g_miss_date
    , p7_a28  NUMBER := 0-1962.0724
    , p7_a29  NUMBER := 0-1962.0724
    , p7_a30  VARCHAR2 := fnd_api.g_miss_char
    , p7_a31  DATE := fnd_api.g_miss_date
    , p7_a32  VARCHAR2 := fnd_api.g_miss_char
    , p7_a33  NUMBER := 0-1962.0724
    , p7_a34  DATE := fnd_api.g_miss_date
    , p7_a35  NUMBER := 0-1962.0724
    , p7_a36  NUMBER := 0-1962.0724
    , p7_a37  VARCHAR2 := fnd_api.g_miss_char
    , p7_a38  VARCHAR2 := fnd_api.g_miss_char
    , p7_a39  VARCHAR2 := fnd_api.g_miss_char
    , p7_a40  DATE := fnd_api.g_miss_date
    , p7_a41  VARCHAR2 := fnd_api.g_miss_char
    , p7_a42  VARCHAR2 := fnd_api.g_miss_char
    , p7_a43  VARCHAR2 := fnd_api.g_miss_char
    , p7_a44  VARCHAR2 := fnd_api.g_miss_char
    , p7_a45  VARCHAR2 := fnd_api.g_miss_char
    , p7_a46  VARCHAR2 := fnd_api.g_miss_char
    , p7_a47  VARCHAR2 := fnd_api.g_miss_char
    , p7_a48  VARCHAR2 := fnd_api.g_miss_char
    , p7_a49  VARCHAR2 := fnd_api.g_miss_char
    , p7_a50  VARCHAR2 := fnd_api.g_miss_char
    , p7_a51  VARCHAR2 := fnd_api.g_miss_char
    , p7_a52  VARCHAR2 := fnd_api.g_miss_char
    , p7_a53  VARCHAR2 := fnd_api.g_miss_char
    , p7_a54  VARCHAR2 := fnd_api.g_miss_char
    , p7_a55  VARCHAR2 := fnd_api.g_miss_char
    , p7_a56  VARCHAR2 := fnd_api.g_miss_char
    , p7_a57  DATE := fnd_api.g_miss_date
    , p7_a58  NUMBER := 0-1962.0724
    , p7_a59  NUMBER := 0-1962.0724
    , p7_a60  NUMBER := 0-1962.0724
    , p7_a61  NUMBER := 0-1962.0724
    , p7_a62  NUMBER := 0-1962.0724
    , p7_a63  DATE := fnd_api.g_miss_date
    , p7_a64  NUMBER := 0-1962.0724
    , p7_a65  DATE := fnd_api.g_miss_date
    , p7_a66  NUMBER := 0-1962.0724
    , p7_a67  DATE := fnd_api.g_miss_date
    , p7_a68  NUMBER := 0-1962.0724
    , p7_a69  NUMBER := 0-1962.0724
    , p7_a70  VARCHAR2 := fnd_api.g_miss_char
    , p7_a71  NUMBER := 0-1962.0724
    , p7_a72  NUMBER := 0-1962.0724
    , p7_a73  NUMBER := 0-1962.0724
    , p7_a74  NUMBER := 0-1962.0724
    , p7_a75  VARCHAR2 := fnd_api.g_miss_char
    , p7_a76  VARCHAR2 := fnd_api.g_miss_char
    , p7_a77  VARCHAR2 := fnd_api.g_miss_char
    , p7_a78  NUMBER := 0-1962.0724
    , p7_a79  DATE := fnd_api.g_miss_date
  )

  as
    ddp_send_tbl okl_am_send_fulfillment_pvt.full_tbl_type;
    ddx_send_tbl okl_am_send_fulfillment_pvt.full_tbl_type;
    ddp_qtev_rec okl_am_send_fulfillment_pvt.qtev_rec_type;
    ddx_qtev_rec okl_am_send_fulfillment_pvt.qtev_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_am_send_fulfillment_pvt_w.rosetta_table_copy_in_p9(ddp_send_tbl, p5_a0
      , p5_a1
      , p5_a2
      , p5_a3
      , p5_a4
      , p5_a5
      , p5_a6
      , p5_a7
      , p5_a8
      );


    ddp_qtev_rec.id := rosetta_g_miss_num_map(p7_a0);
    ddp_qtev_rec.object_version_number := rosetta_g_miss_num_map(p7_a1);
    ddp_qtev_rec.sfwt_flag := p7_a2;
    ddp_qtev_rec.qrs_code := p7_a3;
    ddp_qtev_rec.qst_code := p7_a4;
    ddp_qtev_rec.qtp_code := p7_a5;
    ddp_qtev_rec.trn_code := p7_a6;
    ddp_qtev_rec.pop_code_end := p7_a7;
    ddp_qtev_rec.pop_code_early := p7_a8;
    ddp_qtev_rec.consolidated_qte_id := rosetta_g_miss_num_map(p7_a9);
    ddp_qtev_rec.khr_id := rosetta_g_miss_num_map(p7_a10);
    ddp_qtev_rec.art_id := rosetta_g_miss_num_map(p7_a11);
    ddp_qtev_rec.pdt_id := rosetta_g_miss_num_map(p7_a12);
    ddp_qtev_rec.early_termination_yn := p7_a13;
    ddp_qtev_rec.partial_yn := p7_a14;
    ddp_qtev_rec.preproceeds_yn := p7_a15;
    ddp_qtev_rec.date_requested := rosetta_g_miss_date_in_map(p7_a16);
    ddp_qtev_rec.date_proposal := rosetta_g_miss_date_in_map(p7_a17);
    ddp_qtev_rec.date_effective_to := rosetta_g_miss_date_in_map(p7_a18);
    ddp_qtev_rec.date_accepted := rosetta_g_miss_date_in_map(p7_a19);
    ddp_qtev_rec.summary_format_yn := p7_a20;
    ddp_qtev_rec.consolidated_yn := p7_a21;
    ddp_qtev_rec.principal_paydown_amount := rosetta_g_miss_num_map(p7_a22);
    ddp_qtev_rec.residual_amount := rosetta_g_miss_num_map(p7_a23);
    ddp_qtev_rec.yield := rosetta_g_miss_num_map(p7_a24);
    ddp_qtev_rec.rent_amount := rosetta_g_miss_num_map(p7_a25);
    ddp_qtev_rec.date_restructure_end := rosetta_g_miss_date_in_map(p7_a26);
    ddp_qtev_rec.date_restructure_start := rosetta_g_miss_date_in_map(p7_a27);
    ddp_qtev_rec.term := rosetta_g_miss_num_map(p7_a28);
    ddp_qtev_rec.purchase_percent := rosetta_g_miss_num_map(p7_a29);
    ddp_qtev_rec.comments := p7_a30;
    ddp_qtev_rec.date_due := rosetta_g_miss_date_in_map(p7_a31);
    ddp_qtev_rec.payment_frequency := p7_a32;
    ddp_qtev_rec.remaining_payments := rosetta_g_miss_num_map(p7_a33);
    ddp_qtev_rec.date_effective_from := rosetta_g_miss_date_in_map(p7_a34);
    ddp_qtev_rec.quote_number := rosetta_g_miss_num_map(p7_a35);
    ddp_qtev_rec.requested_by := rosetta_g_miss_num_map(p7_a36);
    ddp_qtev_rec.approved_yn := p7_a37;
    ddp_qtev_rec.accepted_yn := p7_a38;
    ddp_qtev_rec.payment_received_yn := p7_a39;
    ddp_qtev_rec.date_payment_received := rosetta_g_miss_date_in_map(p7_a40);
    ddp_qtev_rec.attribute_category := p7_a41;
    ddp_qtev_rec.attribute1 := p7_a42;
    ddp_qtev_rec.attribute2 := p7_a43;
    ddp_qtev_rec.attribute3 := p7_a44;
    ddp_qtev_rec.attribute4 := p7_a45;
    ddp_qtev_rec.attribute5 := p7_a46;
    ddp_qtev_rec.attribute6 := p7_a47;
    ddp_qtev_rec.attribute7 := p7_a48;
    ddp_qtev_rec.attribute8 := p7_a49;
    ddp_qtev_rec.attribute9 := p7_a50;
    ddp_qtev_rec.attribute10 := p7_a51;
    ddp_qtev_rec.attribute11 := p7_a52;
    ddp_qtev_rec.attribute12 := p7_a53;
    ddp_qtev_rec.attribute13 := p7_a54;
    ddp_qtev_rec.attribute14 := p7_a55;
    ddp_qtev_rec.attribute15 := p7_a56;
    ddp_qtev_rec.date_approved := rosetta_g_miss_date_in_map(p7_a57);
    ddp_qtev_rec.approved_by := rosetta_g_miss_num_map(p7_a58);
    ddp_qtev_rec.org_id := rosetta_g_miss_num_map(p7_a59);
    ddp_qtev_rec.request_id := rosetta_g_miss_num_map(p7_a60);
    ddp_qtev_rec.program_application_id := rosetta_g_miss_num_map(p7_a61);
    ddp_qtev_rec.program_id := rosetta_g_miss_num_map(p7_a62);
    ddp_qtev_rec.program_update_date := rosetta_g_miss_date_in_map(p7_a63);
    ddp_qtev_rec.created_by := rosetta_g_miss_num_map(p7_a64);
    ddp_qtev_rec.creation_date := rosetta_g_miss_date_in_map(p7_a65);
    ddp_qtev_rec.last_updated_by := rosetta_g_miss_num_map(p7_a66);
    ddp_qtev_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a67);
    ddp_qtev_rec.last_update_login := rosetta_g_miss_num_map(p7_a68);
    ddp_qtev_rec.purchase_amount := rosetta_g_miss_num_map(p7_a69);
    ddp_qtev_rec.purchase_formula := p7_a70;
    ddp_qtev_rec.asset_value := rosetta_g_miss_num_map(p7_a71);
    ddp_qtev_rec.residual_value := rosetta_g_miss_num_map(p7_a72);
    ddp_qtev_rec.unbilled_receivables := rosetta_g_miss_num_map(p7_a73);
    ddp_qtev_rec.gain_loss := rosetta_g_miss_num_map(p7_a74);
    ddp_qtev_rec.currency_code := p7_a75;
    ddp_qtev_rec.currency_conversion_code := p7_a76;
    ddp_qtev_rec.currency_conversion_type := p7_a77;
    ddp_qtev_rec.currency_conversion_rate := rosetta_g_miss_num_map(p7_a78);
    ddp_qtev_rec.currency_conversion_date := rosetta_g_miss_date_in_map(p7_a79);


    -- here's the delegated call to the old PL/SQL routine
    okl_am_send_fulfillment_pvt.send_repurchase_quote(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_send_tbl,
      ddx_send_tbl,
      ddp_qtev_rec,
      ddx_qtev_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_am_send_fulfillment_pvt_w.rosetta_table_copy_out_p9(ddx_send_tbl, p6_a0
      , p6_a1
      , p6_a2
      , p6_a3
      , p6_a4
      , p6_a5
      , p6_a6
      , p6_a7
      , p6_a8
      );


    p8_a0 := rosetta_g_miss_num_map(ddx_qtev_rec.id);
    p8_a1 := rosetta_g_miss_num_map(ddx_qtev_rec.object_version_number);
    p8_a2 := ddx_qtev_rec.sfwt_flag;
    p8_a3 := ddx_qtev_rec.qrs_code;
    p8_a4 := ddx_qtev_rec.qst_code;
    p8_a5 := ddx_qtev_rec.qtp_code;
    p8_a6 := ddx_qtev_rec.trn_code;
    p8_a7 := ddx_qtev_rec.pop_code_end;
    p8_a8 := ddx_qtev_rec.pop_code_early;
    p8_a9 := rosetta_g_miss_num_map(ddx_qtev_rec.consolidated_qte_id);
    p8_a10 := rosetta_g_miss_num_map(ddx_qtev_rec.khr_id);
    p8_a11 := rosetta_g_miss_num_map(ddx_qtev_rec.art_id);
    p8_a12 := rosetta_g_miss_num_map(ddx_qtev_rec.pdt_id);
    p8_a13 := ddx_qtev_rec.early_termination_yn;
    p8_a14 := ddx_qtev_rec.partial_yn;
    p8_a15 := ddx_qtev_rec.preproceeds_yn;
    p8_a16 := ddx_qtev_rec.date_requested;
    p8_a17 := ddx_qtev_rec.date_proposal;
    p8_a18 := ddx_qtev_rec.date_effective_to;
    p8_a19 := ddx_qtev_rec.date_accepted;
    p8_a20 := ddx_qtev_rec.summary_format_yn;
    p8_a21 := ddx_qtev_rec.consolidated_yn;
    p8_a22 := rosetta_g_miss_num_map(ddx_qtev_rec.principal_paydown_amount);
    p8_a23 := rosetta_g_miss_num_map(ddx_qtev_rec.residual_amount);
    p8_a24 := rosetta_g_miss_num_map(ddx_qtev_rec.yield);
    p8_a25 := rosetta_g_miss_num_map(ddx_qtev_rec.rent_amount);
    p8_a26 := ddx_qtev_rec.date_restructure_end;
    p8_a27 := ddx_qtev_rec.date_restructure_start;
    p8_a28 := rosetta_g_miss_num_map(ddx_qtev_rec.term);
    p8_a29 := rosetta_g_miss_num_map(ddx_qtev_rec.purchase_percent);
    p8_a30 := ddx_qtev_rec.comments;
    p8_a31 := ddx_qtev_rec.date_due;
    p8_a32 := ddx_qtev_rec.payment_frequency;
    p8_a33 := rosetta_g_miss_num_map(ddx_qtev_rec.remaining_payments);
    p8_a34 := ddx_qtev_rec.date_effective_from;
    p8_a35 := rosetta_g_miss_num_map(ddx_qtev_rec.quote_number);
    p8_a36 := rosetta_g_miss_num_map(ddx_qtev_rec.requested_by);
    p8_a37 := ddx_qtev_rec.approved_yn;
    p8_a38 := ddx_qtev_rec.accepted_yn;
    p8_a39 := ddx_qtev_rec.payment_received_yn;
    p8_a40 := ddx_qtev_rec.date_payment_received;
    p8_a41 := ddx_qtev_rec.attribute_category;
    p8_a42 := ddx_qtev_rec.attribute1;
    p8_a43 := ddx_qtev_rec.attribute2;
    p8_a44 := ddx_qtev_rec.attribute3;
    p8_a45 := ddx_qtev_rec.attribute4;
    p8_a46 := ddx_qtev_rec.attribute5;
    p8_a47 := ddx_qtev_rec.attribute6;
    p8_a48 := ddx_qtev_rec.attribute7;
    p8_a49 := ddx_qtev_rec.attribute8;
    p8_a50 := ddx_qtev_rec.attribute9;
    p8_a51 := ddx_qtev_rec.attribute10;
    p8_a52 := ddx_qtev_rec.attribute11;
    p8_a53 := ddx_qtev_rec.attribute12;
    p8_a54 := ddx_qtev_rec.attribute13;
    p8_a55 := ddx_qtev_rec.attribute14;
    p8_a56 := ddx_qtev_rec.attribute15;
    p8_a57 := ddx_qtev_rec.date_approved;
    p8_a58 := rosetta_g_miss_num_map(ddx_qtev_rec.approved_by);
    p8_a59 := rosetta_g_miss_num_map(ddx_qtev_rec.org_id);
    p8_a60 := rosetta_g_miss_num_map(ddx_qtev_rec.request_id);
    p8_a61 := rosetta_g_miss_num_map(ddx_qtev_rec.program_application_id);
    p8_a62 := rosetta_g_miss_num_map(ddx_qtev_rec.program_id);
    p8_a63 := ddx_qtev_rec.program_update_date;
    p8_a64 := rosetta_g_miss_num_map(ddx_qtev_rec.created_by);
    p8_a65 := ddx_qtev_rec.creation_date;
    p8_a66 := rosetta_g_miss_num_map(ddx_qtev_rec.last_updated_by);
    p8_a67 := ddx_qtev_rec.last_update_date;
    p8_a68 := rosetta_g_miss_num_map(ddx_qtev_rec.last_update_login);
    p8_a69 := rosetta_g_miss_num_map(ddx_qtev_rec.purchase_amount);
    p8_a70 := ddx_qtev_rec.purchase_formula;
    p8_a71 := rosetta_g_miss_num_map(ddx_qtev_rec.asset_value);
    p8_a72 := rosetta_g_miss_num_map(ddx_qtev_rec.residual_value);
    p8_a73 := rosetta_g_miss_num_map(ddx_qtev_rec.unbilled_receivables);
    p8_a74 := rosetta_g_miss_num_map(ddx_qtev_rec.gain_loss);
    p8_a75 := ddx_qtev_rec.currency_code;
    p8_a76 := ddx_qtev_rec.currency_conversion_code;
    p8_a77 := ddx_qtev_rec.currency_conversion_type;
    p8_a78 := rosetta_g_miss_num_map(ddx_qtev_rec.currency_conversion_rate);
    p8_a79 := ddx_qtev_rec.currency_conversion_date;
  end;

  procedure send_restructure_quote(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_VARCHAR2_TABLE_200
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_VARCHAR2_TABLE_200
    , p5_a4 JTF_VARCHAR2_TABLE_200
    , p5_a5 JTF_VARCHAR2_TABLE_200
    , p5_a6 JTF_VARCHAR2_TABLE_200
    , p5_a7 JTF_VARCHAR2_TABLE_200
    , p5_a8 JTF_VARCHAR2_TABLE_200
    , p6_a0 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_NUMBER_TABLE
    , p6_a3 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a4 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a5 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a6 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a7 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a8 out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a0 out nocopy  NUMBER
    , p8_a1 out nocopy  NUMBER
    , p8_a2 out nocopy  VARCHAR2
    , p8_a3 out nocopy  VARCHAR2
    , p8_a4 out nocopy  VARCHAR2
    , p8_a5 out nocopy  VARCHAR2
    , p8_a6 out nocopy  VARCHAR2
    , p8_a7 out nocopy  VARCHAR2
    , p8_a8 out nocopy  VARCHAR2
    , p8_a9 out nocopy  NUMBER
    , p8_a10 out nocopy  NUMBER
    , p8_a11 out nocopy  NUMBER
    , p8_a12 out nocopy  NUMBER
    , p8_a13 out nocopy  VARCHAR2
    , p8_a14 out nocopy  VARCHAR2
    , p8_a15 out nocopy  VARCHAR2
    , p8_a16 out nocopy  DATE
    , p8_a17 out nocopy  DATE
    , p8_a18 out nocopy  DATE
    , p8_a19 out nocopy  DATE
    , p8_a20 out nocopy  VARCHAR2
    , p8_a21 out nocopy  VARCHAR2
    , p8_a22 out nocopy  NUMBER
    , p8_a23 out nocopy  NUMBER
    , p8_a24 out nocopy  NUMBER
    , p8_a25 out nocopy  NUMBER
    , p8_a26 out nocopy  DATE
    , p8_a27 out nocopy  DATE
    , p8_a28 out nocopy  NUMBER
    , p8_a29 out nocopy  NUMBER
    , p8_a30 out nocopy  VARCHAR2
    , p8_a31 out nocopy  DATE
    , p8_a32 out nocopy  VARCHAR2
    , p8_a33 out nocopy  NUMBER
    , p8_a34 out nocopy  DATE
    , p8_a35 out nocopy  NUMBER
    , p8_a36 out nocopy  NUMBER
    , p8_a37 out nocopy  VARCHAR2
    , p8_a38 out nocopy  VARCHAR2
    , p8_a39 out nocopy  VARCHAR2
    , p8_a40 out nocopy  DATE
    , p8_a41 out nocopy  VARCHAR2
    , p8_a42 out nocopy  VARCHAR2
    , p8_a43 out nocopy  VARCHAR2
    , p8_a44 out nocopy  VARCHAR2
    , p8_a45 out nocopy  VARCHAR2
    , p8_a46 out nocopy  VARCHAR2
    , p8_a47 out nocopy  VARCHAR2
    , p8_a48 out nocopy  VARCHAR2
    , p8_a49 out nocopy  VARCHAR2
    , p8_a50 out nocopy  VARCHAR2
    , p8_a51 out nocopy  VARCHAR2
    , p8_a52 out nocopy  VARCHAR2
    , p8_a53 out nocopy  VARCHAR2
    , p8_a54 out nocopy  VARCHAR2
    , p8_a55 out nocopy  VARCHAR2
    , p8_a56 out nocopy  VARCHAR2
    , p8_a57 out nocopy  DATE
    , p8_a58 out nocopy  NUMBER
    , p8_a59 out nocopy  NUMBER
    , p8_a60 out nocopy  NUMBER
    , p8_a61 out nocopy  NUMBER
    , p8_a62 out nocopy  NUMBER
    , p8_a63 out nocopy  DATE
    , p8_a64 out nocopy  NUMBER
    , p8_a65 out nocopy  DATE
    , p8_a66 out nocopy  NUMBER
    , p8_a67 out nocopy  DATE
    , p8_a68 out nocopy  NUMBER
    , p8_a69 out nocopy  NUMBER
    , p8_a70 out nocopy  VARCHAR2
    , p8_a71 out nocopy  NUMBER
    , p8_a72 out nocopy  NUMBER
    , p8_a73 out nocopy  NUMBER
    , p8_a74 out nocopy  NUMBER
    , p8_a75 out nocopy  VARCHAR2
    , p8_a76 out nocopy  VARCHAR2
    , p8_a77 out nocopy  VARCHAR2
    , p8_a78 out nocopy  NUMBER
    , p8_a79 out nocopy  DATE
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  NUMBER := 0-1962.0724
    , p7_a2  VARCHAR2 := fnd_api.g_miss_char
    , p7_a3  VARCHAR2 := fnd_api.g_miss_char
    , p7_a4  VARCHAR2 := fnd_api.g_miss_char
    , p7_a5  VARCHAR2 := fnd_api.g_miss_char
    , p7_a6  VARCHAR2 := fnd_api.g_miss_char
    , p7_a7  VARCHAR2 := fnd_api.g_miss_char
    , p7_a8  VARCHAR2 := fnd_api.g_miss_char
    , p7_a9  NUMBER := 0-1962.0724
    , p7_a10  NUMBER := 0-1962.0724
    , p7_a11  NUMBER := 0-1962.0724
    , p7_a12  NUMBER := 0-1962.0724
    , p7_a13  VARCHAR2 := fnd_api.g_miss_char
    , p7_a14  VARCHAR2 := fnd_api.g_miss_char
    , p7_a15  VARCHAR2 := fnd_api.g_miss_char
    , p7_a16  DATE := fnd_api.g_miss_date
    , p7_a17  DATE := fnd_api.g_miss_date
    , p7_a18  DATE := fnd_api.g_miss_date
    , p7_a19  DATE := fnd_api.g_miss_date
    , p7_a20  VARCHAR2 := fnd_api.g_miss_char
    , p7_a21  VARCHAR2 := fnd_api.g_miss_char
    , p7_a22  NUMBER := 0-1962.0724
    , p7_a23  NUMBER := 0-1962.0724
    , p7_a24  NUMBER := 0-1962.0724
    , p7_a25  NUMBER := 0-1962.0724
    , p7_a26  DATE := fnd_api.g_miss_date
    , p7_a27  DATE := fnd_api.g_miss_date
    , p7_a28  NUMBER := 0-1962.0724
    , p7_a29  NUMBER := 0-1962.0724
    , p7_a30  VARCHAR2 := fnd_api.g_miss_char
    , p7_a31  DATE := fnd_api.g_miss_date
    , p7_a32  VARCHAR2 := fnd_api.g_miss_char
    , p7_a33  NUMBER := 0-1962.0724
    , p7_a34  DATE := fnd_api.g_miss_date
    , p7_a35  NUMBER := 0-1962.0724
    , p7_a36  NUMBER := 0-1962.0724
    , p7_a37  VARCHAR2 := fnd_api.g_miss_char
    , p7_a38  VARCHAR2 := fnd_api.g_miss_char
    , p7_a39  VARCHAR2 := fnd_api.g_miss_char
    , p7_a40  DATE := fnd_api.g_miss_date
    , p7_a41  VARCHAR2 := fnd_api.g_miss_char
    , p7_a42  VARCHAR2 := fnd_api.g_miss_char
    , p7_a43  VARCHAR2 := fnd_api.g_miss_char
    , p7_a44  VARCHAR2 := fnd_api.g_miss_char
    , p7_a45  VARCHAR2 := fnd_api.g_miss_char
    , p7_a46  VARCHAR2 := fnd_api.g_miss_char
    , p7_a47  VARCHAR2 := fnd_api.g_miss_char
    , p7_a48  VARCHAR2 := fnd_api.g_miss_char
    , p7_a49  VARCHAR2 := fnd_api.g_miss_char
    , p7_a50  VARCHAR2 := fnd_api.g_miss_char
    , p7_a51  VARCHAR2 := fnd_api.g_miss_char
    , p7_a52  VARCHAR2 := fnd_api.g_miss_char
    , p7_a53  VARCHAR2 := fnd_api.g_miss_char
    , p7_a54  VARCHAR2 := fnd_api.g_miss_char
    , p7_a55  VARCHAR2 := fnd_api.g_miss_char
    , p7_a56  VARCHAR2 := fnd_api.g_miss_char
    , p7_a57  DATE := fnd_api.g_miss_date
    , p7_a58  NUMBER := 0-1962.0724
    , p7_a59  NUMBER := 0-1962.0724
    , p7_a60  NUMBER := 0-1962.0724
    , p7_a61  NUMBER := 0-1962.0724
    , p7_a62  NUMBER := 0-1962.0724
    , p7_a63  DATE := fnd_api.g_miss_date
    , p7_a64  NUMBER := 0-1962.0724
    , p7_a65  DATE := fnd_api.g_miss_date
    , p7_a66  NUMBER := 0-1962.0724
    , p7_a67  DATE := fnd_api.g_miss_date
    , p7_a68  NUMBER := 0-1962.0724
    , p7_a69  NUMBER := 0-1962.0724
    , p7_a70  VARCHAR2 := fnd_api.g_miss_char
    , p7_a71  NUMBER := 0-1962.0724
    , p7_a72  NUMBER := 0-1962.0724
    , p7_a73  NUMBER := 0-1962.0724
    , p7_a74  NUMBER := 0-1962.0724
    , p7_a75  VARCHAR2 := fnd_api.g_miss_char
    , p7_a76  VARCHAR2 := fnd_api.g_miss_char
    , p7_a77  VARCHAR2 := fnd_api.g_miss_char
    , p7_a78  NUMBER := 0-1962.0724
    , p7_a79  DATE := fnd_api.g_miss_date
  )

  as
    ddp_send_tbl okl_am_send_fulfillment_pvt.full_tbl_type;
    ddx_send_tbl okl_am_send_fulfillment_pvt.full_tbl_type;
    ddp_qtev_rec okl_am_send_fulfillment_pvt.qtev_rec_type;
    ddx_qtev_rec okl_am_send_fulfillment_pvt.qtev_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_am_send_fulfillment_pvt_w.rosetta_table_copy_in_p9(ddp_send_tbl, p5_a0
      , p5_a1
      , p5_a2
      , p5_a3
      , p5_a4
      , p5_a5
      , p5_a6
      , p5_a7
      , p5_a8
      );


    ddp_qtev_rec.id := rosetta_g_miss_num_map(p7_a0);
    ddp_qtev_rec.object_version_number := rosetta_g_miss_num_map(p7_a1);
    ddp_qtev_rec.sfwt_flag := p7_a2;
    ddp_qtev_rec.qrs_code := p7_a3;
    ddp_qtev_rec.qst_code := p7_a4;
    ddp_qtev_rec.qtp_code := p7_a5;
    ddp_qtev_rec.trn_code := p7_a6;
    ddp_qtev_rec.pop_code_end := p7_a7;
    ddp_qtev_rec.pop_code_early := p7_a8;
    ddp_qtev_rec.consolidated_qte_id := rosetta_g_miss_num_map(p7_a9);
    ddp_qtev_rec.khr_id := rosetta_g_miss_num_map(p7_a10);
    ddp_qtev_rec.art_id := rosetta_g_miss_num_map(p7_a11);
    ddp_qtev_rec.pdt_id := rosetta_g_miss_num_map(p7_a12);
    ddp_qtev_rec.early_termination_yn := p7_a13;
    ddp_qtev_rec.partial_yn := p7_a14;
    ddp_qtev_rec.preproceeds_yn := p7_a15;
    ddp_qtev_rec.date_requested := rosetta_g_miss_date_in_map(p7_a16);
    ddp_qtev_rec.date_proposal := rosetta_g_miss_date_in_map(p7_a17);
    ddp_qtev_rec.date_effective_to := rosetta_g_miss_date_in_map(p7_a18);
    ddp_qtev_rec.date_accepted := rosetta_g_miss_date_in_map(p7_a19);
    ddp_qtev_rec.summary_format_yn := p7_a20;
    ddp_qtev_rec.consolidated_yn := p7_a21;
    ddp_qtev_rec.principal_paydown_amount := rosetta_g_miss_num_map(p7_a22);
    ddp_qtev_rec.residual_amount := rosetta_g_miss_num_map(p7_a23);
    ddp_qtev_rec.yield := rosetta_g_miss_num_map(p7_a24);
    ddp_qtev_rec.rent_amount := rosetta_g_miss_num_map(p7_a25);
    ddp_qtev_rec.date_restructure_end := rosetta_g_miss_date_in_map(p7_a26);
    ddp_qtev_rec.date_restructure_start := rosetta_g_miss_date_in_map(p7_a27);
    ddp_qtev_rec.term := rosetta_g_miss_num_map(p7_a28);
    ddp_qtev_rec.purchase_percent := rosetta_g_miss_num_map(p7_a29);
    ddp_qtev_rec.comments := p7_a30;
    ddp_qtev_rec.date_due := rosetta_g_miss_date_in_map(p7_a31);
    ddp_qtev_rec.payment_frequency := p7_a32;
    ddp_qtev_rec.remaining_payments := rosetta_g_miss_num_map(p7_a33);
    ddp_qtev_rec.date_effective_from := rosetta_g_miss_date_in_map(p7_a34);
    ddp_qtev_rec.quote_number := rosetta_g_miss_num_map(p7_a35);
    ddp_qtev_rec.requested_by := rosetta_g_miss_num_map(p7_a36);
    ddp_qtev_rec.approved_yn := p7_a37;
    ddp_qtev_rec.accepted_yn := p7_a38;
    ddp_qtev_rec.payment_received_yn := p7_a39;
    ddp_qtev_rec.date_payment_received := rosetta_g_miss_date_in_map(p7_a40);
    ddp_qtev_rec.attribute_category := p7_a41;
    ddp_qtev_rec.attribute1 := p7_a42;
    ddp_qtev_rec.attribute2 := p7_a43;
    ddp_qtev_rec.attribute3 := p7_a44;
    ddp_qtev_rec.attribute4 := p7_a45;
    ddp_qtev_rec.attribute5 := p7_a46;
    ddp_qtev_rec.attribute6 := p7_a47;
    ddp_qtev_rec.attribute7 := p7_a48;
    ddp_qtev_rec.attribute8 := p7_a49;
    ddp_qtev_rec.attribute9 := p7_a50;
    ddp_qtev_rec.attribute10 := p7_a51;
    ddp_qtev_rec.attribute11 := p7_a52;
    ddp_qtev_rec.attribute12 := p7_a53;
    ddp_qtev_rec.attribute13 := p7_a54;
    ddp_qtev_rec.attribute14 := p7_a55;
    ddp_qtev_rec.attribute15 := p7_a56;
    ddp_qtev_rec.date_approved := rosetta_g_miss_date_in_map(p7_a57);
    ddp_qtev_rec.approved_by := rosetta_g_miss_num_map(p7_a58);
    ddp_qtev_rec.org_id := rosetta_g_miss_num_map(p7_a59);
    ddp_qtev_rec.request_id := rosetta_g_miss_num_map(p7_a60);
    ddp_qtev_rec.program_application_id := rosetta_g_miss_num_map(p7_a61);
    ddp_qtev_rec.program_id := rosetta_g_miss_num_map(p7_a62);
    ddp_qtev_rec.program_update_date := rosetta_g_miss_date_in_map(p7_a63);
    ddp_qtev_rec.created_by := rosetta_g_miss_num_map(p7_a64);
    ddp_qtev_rec.creation_date := rosetta_g_miss_date_in_map(p7_a65);
    ddp_qtev_rec.last_updated_by := rosetta_g_miss_num_map(p7_a66);
    ddp_qtev_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a67);
    ddp_qtev_rec.last_update_login := rosetta_g_miss_num_map(p7_a68);
    ddp_qtev_rec.purchase_amount := rosetta_g_miss_num_map(p7_a69);
    ddp_qtev_rec.purchase_formula := p7_a70;
    ddp_qtev_rec.asset_value := rosetta_g_miss_num_map(p7_a71);
    ddp_qtev_rec.residual_value := rosetta_g_miss_num_map(p7_a72);
    ddp_qtev_rec.unbilled_receivables := rosetta_g_miss_num_map(p7_a73);
    ddp_qtev_rec.gain_loss := rosetta_g_miss_num_map(p7_a74);
    ddp_qtev_rec.currency_code := p7_a75;
    ddp_qtev_rec.currency_conversion_code := p7_a76;
    ddp_qtev_rec.currency_conversion_type := p7_a77;
    ddp_qtev_rec.currency_conversion_rate := rosetta_g_miss_num_map(p7_a78);
    ddp_qtev_rec.currency_conversion_date := rosetta_g_miss_date_in_map(p7_a79);


    -- here's the delegated call to the old PL/SQL routine
    okl_am_send_fulfillment_pvt.send_restructure_quote(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_send_tbl,
      ddx_send_tbl,
      ddp_qtev_rec,
      ddx_qtev_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_am_send_fulfillment_pvt_w.rosetta_table_copy_out_p9(ddx_send_tbl, p6_a0
      , p6_a1
      , p6_a2
      , p6_a3
      , p6_a4
      , p6_a5
      , p6_a6
      , p6_a7
      , p6_a8
      );


    p8_a0 := rosetta_g_miss_num_map(ddx_qtev_rec.id);
    p8_a1 := rosetta_g_miss_num_map(ddx_qtev_rec.object_version_number);
    p8_a2 := ddx_qtev_rec.sfwt_flag;
    p8_a3 := ddx_qtev_rec.qrs_code;
    p8_a4 := ddx_qtev_rec.qst_code;
    p8_a5 := ddx_qtev_rec.qtp_code;
    p8_a6 := ddx_qtev_rec.trn_code;
    p8_a7 := ddx_qtev_rec.pop_code_end;
    p8_a8 := ddx_qtev_rec.pop_code_early;
    p8_a9 := rosetta_g_miss_num_map(ddx_qtev_rec.consolidated_qte_id);
    p8_a10 := rosetta_g_miss_num_map(ddx_qtev_rec.khr_id);
    p8_a11 := rosetta_g_miss_num_map(ddx_qtev_rec.art_id);
    p8_a12 := rosetta_g_miss_num_map(ddx_qtev_rec.pdt_id);
    p8_a13 := ddx_qtev_rec.early_termination_yn;
    p8_a14 := ddx_qtev_rec.partial_yn;
    p8_a15 := ddx_qtev_rec.preproceeds_yn;
    p8_a16 := ddx_qtev_rec.date_requested;
    p8_a17 := ddx_qtev_rec.date_proposal;
    p8_a18 := ddx_qtev_rec.date_effective_to;
    p8_a19 := ddx_qtev_rec.date_accepted;
    p8_a20 := ddx_qtev_rec.summary_format_yn;
    p8_a21 := ddx_qtev_rec.consolidated_yn;
    p8_a22 := rosetta_g_miss_num_map(ddx_qtev_rec.principal_paydown_amount);
    p8_a23 := rosetta_g_miss_num_map(ddx_qtev_rec.residual_amount);
    p8_a24 := rosetta_g_miss_num_map(ddx_qtev_rec.yield);
    p8_a25 := rosetta_g_miss_num_map(ddx_qtev_rec.rent_amount);
    p8_a26 := ddx_qtev_rec.date_restructure_end;
    p8_a27 := ddx_qtev_rec.date_restructure_start;
    p8_a28 := rosetta_g_miss_num_map(ddx_qtev_rec.term);
    p8_a29 := rosetta_g_miss_num_map(ddx_qtev_rec.purchase_percent);
    p8_a30 := ddx_qtev_rec.comments;
    p8_a31 := ddx_qtev_rec.date_due;
    p8_a32 := ddx_qtev_rec.payment_frequency;
    p8_a33 := rosetta_g_miss_num_map(ddx_qtev_rec.remaining_payments);
    p8_a34 := ddx_qtev_rec.date_effective_from;
    p8_a35 := rosetta_g_miss_num_map(ddx_qtev_rec.quote_number);
    p8_a36 := rosetta_g_miss_num_map(ddx_qtev_rec.requested_by);
    p8_a37 := ddx_qtev_rec.approved_yn;
    p8_a38 := ddx_qtev_rec.accepted_yn;
    p8_a39 := ddx_qtev_rec.payment_received_yn;
    p8_a40 := ddx_qtev_rec.date_payment_received;
    p8_a41 := ddx_qtev_rec.attribute_category;
    p8_a42 := ddx_qtev_rec.attribute1;
    p8_a43 := ddx_qtev_rec.attribute2;
    p8_a44 := ddx_qtev_rec.attribute3;
    p8_a45 := ddx_qtev_rec.attribute4;
    p8_a46 := ddx_qtev_rec.attribute5;
    p8_a47 := ddx_qtev_rec.attribute6;
    p8_a48 := ddx_qtev_rec.attribute7;
    p8_a49 := ddx_qtev_rec.attribute8;
    p8_a50 := ddx_qtev_rec.attribute9;
    p8_a51 := ddx_qtev_rec.attribute10;
    p8_a52 := ddx_qtev_rec.attribute11;
    p8_a53 := ddx_qtev_rec.attribute12;
    p8_a54 := ddx_qtev_rec.attribute13;
    p8_a55 := ddx_qtev_rec.attribute14;
    p8_a56 := ddx_qtev_rec.attribute15;
    p8_a57 := ddx_qtev_rec.date_approved;
    p8_a58 := rosetta_g_miss_num_map(ddx_qtev_rec.approved_by);
    p8_a59 := rosetta_g_miss_num_map(ddx_qtev_rec.org_id);
    p8_a60 := rosetta_g_miss_num_map(ddx_qtev_rec.request_id);
    p8_a61 := rosetta_g_miss_num_map(ddx_qtev_rec.program_application_id);
    p8_a62 := rosetta_g_miss_num_map(ddx_qtev_rec.program_id);
    p8_a63 := ddx_qtev_rec.program_update_date;
    p8_a64 := rosetta_g_miss_num_map(ddx_qtev_rec.created_by);
    p8_a65 := ddx_qtev_rec.creation_date;
    p8_a66 := rosetta_g_miss_num_map(ddx_qtev_rec.last_updated_by);
    p8_a67 := ddx_qtev_rec.last_update_date;
    p8_a68 := rosetta_g_miss_num_map(ddx_qtev_rec.last_update_login);
    p8_a69 := rosetta_g_miss_num_map(ddx_qtev_rec.purchase_amount);
    p8_a70 := ddx_qtev_rec.purchase_formula;
    p8_a71 := rosetta_g_miss_num_map(ddx_qtev_rec.asset_value);
    p8_a72 := rosetta_g_miss_num_map(ddx_qtev_rec.residual_value);
    p8_a73 := rosetta_g_miss_num_map(ddx_qtev_rec.unbilled_receivables);
    p8_a74 := rosetta_g_miss_num_map(ddx_qtev_rec.gain_loss);
    p8_a75 := ddx_qtev_rec.currency_code;
    p8_a76 := ddx_qtev_rec.currency_conversion_code;
    p8_a77 := ddx_qtev_rec.currency_conversion_type;
    p8_a78 := rosetta_g_miss_num_map(ddx_qtev_rec.currency_conversion_rate);
    p8_a79 := ddx_qtev_rec.currency_conversion_date;
  end;

  procedure send_consolidate_quote(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_VARCHAR2_TABLE_200
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_VARCHAR2_TABLE_200
    , p5_a4 JTF_VARCHAR2_TABLE_200
    , p5_a5 JTF_VARCHAR2_TABLE_200
    , p5_a6 JTF_VARCHAR2_TABLE_200
    , p5_a7 JTF_VARCHAR2_TABLE_200
    , p5_a8 JTF_VARCHAR2_TABLE_200
    , p6_a0 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_NUMBER_TABLE
    , p6_a3 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a4 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a5 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a6 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a7 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a8 out nocopy JTF_VARCHAR2_TABLE_200
    , p8_a0 out nocopy  NUMBER
    , p8_a1 out nocopy  NUMBER
    , p8_a2 out nocopy  VARCHAR2
    , p8_a3 out nocopy  VARCHAR2
    , p8_a4 out nocopy  VARCHAR2
    , p8_a5 out nocopy  VARCHAR2
    , p8_a6 out nocopy  VARCHAR2
    , p8_a7 out nocopy  VARCHAR2
    , p8_a8 out nocopy  VARCHAR2
    , p8_a9 out nocopy  NUMBER
    , p8_a10 out nocopy  NUMBER
    , p8_a11 out nocopy  NUMBER
    , p8_a12 out nocopy  NUMBER
    , p8_a13 out nocopy  VARCHAR2
    , p8_a14 out nocopy  VARCHAR2
    , p8_a15 out nocopy  VARCHAR2
    , p8_a16 out nocopy  DATE
    , p8_a17 out nocopy  DATE
    , p8_a18 out nocopy  DATE
    , p8_a19 out nocopy  DATE
    , p8_a20 out nocopy  VARCHAR2
    , p8_a21 out nocopy  VARCHAR2
    , p8_a22 out nocopy  NUMBER
    , p8_a23 out nocopy  NUMBER
    , p8_a24 out nocopy  NUMBER
    , p8_a25 out nocopy  NUMBER
    , p8_a26 out nocopy  DATE
    , p8_a27 out nocopy  DATE
    , p8_a28 out nocopy  NUMBER
    , p8_a29 out nocopy  NUMBER
    , p8_a30 out nocopy  VARCHAR2
    , p8_a31 out nocopy  DATE
    , p8_a32 out nocopy  VARCHAR2
    , p8_a33 out nocopy  NUMBER
    , p8_a34 out nocopy  DATE
    , p8_a35 out nocopy  NUMBER
    , p8_a36 out nocopy  NUMBER
    , p8_a37 out nocopy  VARCHAR2
    , p8_a38 out nocopy  VARCHAR2
    , p8_a39 out nocopy  VARCHAR2
    , p8_a40 out nocopy  DATE
    , p8_a41 out nocopy  VARCHAR2
    , p8_a42 out nocopy  VARCHAR2
    , p8_a43 out nocopy  VARCHAR2
    , p8_a44 out nocopy  VARCHAR2
    , p8_a45 out nocopy  VARCHAR2
    , p8_a46 out nocopy  VARCHAR2
    , p8_a47 out nocopy  VARCHAR2
    , p8_a48 out nocopy  VARCHAR2
    , p8_a49 out nocopy  VARCHAR2
    , p8_a50 out nocopy  VARCHAR2
    , p8_a51 out nocopy  VARCHAR2
    , p8_a52 out nocopy  VARCHAR2
    , p8_a53 out nocopy  VARCHAR2
    , p8_a54 out nocopy  VARCHAR2
    , p8_a55 out nocopy  VARCHAR2
    , p8_a56 out nocopy  VARCHAR2
    , p8_a57 out nocopy  DATE
    , p8_a58 out nocopy  NUMBER
    , p8_a59 out nocopy  NUMBER
    , p8_a60 out nocopy  NUMBER
    , p8_a61 out nocopy  NUMBER
    , p8_a62 out nocopy  NUMBER
    , p8_a63 out nocopy  DATE
    , p8_a64 out nocopy  NUMBER
    , p8_a65 out nocopy  DATE
    , p8_a66 out nocopy  NUMBER
    , p8_a67 out nocopy  DATE
    , p8_a68 out nocopy  NUMBER
    , p8_a69 out nocopy  NUMBER
    , p8_a70 out nocopy  VARCHAR2
    , p8_a71 out nocopy  NUMBER
    , p8_a72 out nocopy  NUMBER
    , p8_a73 out nocopy  NUMBER
    , p8_a74 out nocopy  NUMBER
    , p8_a75 out nocopy  VARCHAR2
    , p8_a76 out nocopy  VARCHAR2
    , p8_a77 out nocopy  VARCHAR2
    , p8_a78 out nocopy  NUMBER
    , p8_a79 out nocopy  DATE
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  NUMBER := 0-1962.0724
    , p7_a2  VARCHAR2 := fnd_api.g_miss_char
    , p7_a3  VARCHAR2 := fnd_api.g_miss_char
    , p7_a4  VARCHAR2 := fnd_api.g_miss_char
    , p7_a5  VARCHAR2 := fnd_api.g_miss_char
    , p7_a6  VARCHAR2 := fnd_api.g_miss_char
    , p7_a7  VARCHAR2 := fnd_api.g_miss_char
    , p7_a8  VARCHAR2 := fnd_api.g_miss_char
    , p7_a9  NUMBER := 0-1962.0724
    , p7_a10  NUMBER := 0-1962.0724
    , p7_a11  NUMBER := 0-1962.0724
    , p7_a12  NUMBER := 0-1962.0724
    , p7_a13  VARCHAR2 := fnd_api.g_miss_char
    , p7_a14  VARCHAR2 := fnd_api.g_miss_char
    , p7_a15  VARCHAR2 := fnd_api.g_miss_char
    , p7_a16  DATE := fnd_api.g_miss_date
    , p7_a17  DATE := fnd_api.g_miss_date
    , p7_a18  DATE := fnd_api.g_miss_date
    , p7_a19  DATE := fnd_api.g_miss_date
    , p7_a20  VARCHAR2 := fnd_api.g_miss_char
    , p7_a21  VARCHAR2 := fnd_api.g_miss_char
    , p7_a22  NUMBER := 0-1962.0724
    , p7_a23  NUMBER := 0-1962.0724
    , p7_a24  NUMBER := 0-1962.0724
    , p7_a25  NUMBER := 0-1962.0724
    , p7_a26  DATE := fnd_api.g_miss_date
    , p7_a27  DATE := fnd_api.g_miss_date
    , p7_a28  NUMBER := 0-1962.0724
    , p7_a29  NUMBER := 0-1962.0724
    , p7_a30  VARCHAR2 := fnd_api.g_miss_char
    , p7_a31  DATE := fnd_api.g_miss_date
    , p7_a32  VARCHAR2 := fnd_api.g_miss_char
    , p7_a33  NUMBER := 0-1962.0724
    , p7_a34  DATE := fnd_api.g_miss_date
    , p7_a35  NUMBER := 0-1962.0724
    , p7_a36  NUMBER := 0-1962.0724
    , p7_a37  VARCHAR2 := fnd_api.g_miss_char
    , p7_a38  VARCHAR2 := fnd_api.g_miss_char
    , p7_a39  VARCHAR2 := fnd_api.g_miss_char
    , p7_a40  DATE := fnd_api.g_miss_date
    , p7_a41  VARCHAR2 := fnd_api.g_miss_char
    , p7_a42  VARCHAR2 := fnd_api.g_miss_char
    , p7_a43  VARCHAR2 := fnd_api.g_miss_char
    , p7_a44  VARCHAR2 := fnd_api.g_miss_char
    , p7_a45  VARCHAR2 := fnd_api.g_miss_char
    , p7_a46  VARCHAR2 := fnd_api.g_miss_char
    , p7_a47  VARCHAR2 := fnd_api.g_miss_char
    , p7_a48  VARCHAR2 := fnd_api.g_miss_char
    , p7_a49  VARCHAR2 := fnd_api.g_miss_char
    , p7_a50  VARCHAR2 := fnd_api.g_miss_char
    , p7_a51  VARCHAR2 := fnd_api.g_miss_char
    , p7_a52  VARCHAR2 := fnd_api.g_miss_char
    , p7_a53  VARCHAR2 := fnd_api.g_miss_char
    , p7_a54  VARCHAR2 := fnd_api.g_miss_char
    , p7_a55  VARCHAR2 := fnd_api.g_miss_char
    , p7_a56  VARCHAR2 := fnd_api.g_miss_char
    , p7_a57  DATE := fnd_api.g_miss_date
    , p7_a58  NUMBER := 0-1962.0724
    , p7_a59  NUMBER := 0-1962.0724
    , p7_a60  NUMBER := 0-1962.0724
    , p7_a61  NUMBER := 0-1962.0724
    , p7_a62  NUMBER := 0-1962.0724
    , p7_a63  DATE := fnd_api.g_miss_date
    , p7_a64  NUMBER := 0-1962.0724
    , p7_a65  DATE := fnd_api.g_miss_date
    , p7_a66  NUMBER := 0-1962.0724
    , p7_a67  DATE := fnd_api.g_miss_date
    , p7_a68  NUMBER := 0-1962.0724
    , p7_a69  NUMBER := 0-1962.0724
    , p7_a70  VARCHAR2 := fnd_api.g_miss_char
    , p7_a71  NUMBER := 0-1962.0724
    , p7_a72  NUMBER := 0-1962.0724
    , p7_a73  NUMBER := 0-1962.0724
    , p7_a74  NUMBER := 0-1962.0724
    , p7_a75  VARCHAR2 := fnd_api.g_miss_char
    , p7_a76  VARCHAR2 := fnd_api.g_miss_char
    , p7_a77  VARCHAR2 := fnd_api.g_miss_char
    , p7_a78  NUMBER := 0-1962.0724
    , p7_a79  DATE := fnd_api.g_miss_date
  )

  as
    ddp_send_tbl okl_am_send_fulfillment_pvt.full_tbl_type;
    ddx_send_tbl okl_am_send_fulfillment_pvt.full_tbl_type;
    ddp_qtev_rec okl_am_send_fulfillment_pvt.qtev_rec_type;
    ddx_qtev_rec okl_am_send_fulfillment_pvt.qtev_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_am_send_fulfillment_pvt_w.rosetta_table_copy_in_p9(ddp_send_tbl, p5_a0
      , p5_a1
      , p5_a2
      , p5_a3
      , p5_a4
      , p5_a5
      , p5_a6
      , p5_a7
      , p5_a8
      );


    ddp_qtev_rec.id := rosetta_g_miss_num_map(p7_a0);
    ddp_qtev_rec.object_version_number := rosetta_g_miss_num_map(p7_a1);
    ddp_qtev_rec.sfwt_flag := p7_a2;
    ddp_qtev_rec.qrs_code := p7_a3;
    ddp_qtev_rec.qst_code := p7_a4;
    ddp_qtev_rec.qtp_code := p7_a5;
    ddp_qtev_rec.trn_code := p7_a6;
    ddp_qtev_rec.pop_code_end := p7_a7;
    ddp_qtev_rec.pop_code_early := p7_a8;
    ddp_qtev_rec.consolidated_qte_id := rosetta_g_miss_num_map(p7_a9);
    ddp_qtev_rec.khr_id := rosetta_g_miss_num_map(p7_a10);
    ddp_qtev_rec.art_id := rosetta_g_miss_num_map(p7_a11);
    ddp_qtev_rec.pdt_id := rosetta_g_miss_num_map(p7_a12);
    ddp_qtev_rec.early_termination_yn := p7_a13;
    ddp_qtev_rec.partial_yn := p7_a14;
    ddp_qtev_rec.preproceeds_yn := p7_a15;
    ddp_qtev_rec.date_requested := rosetta_g_miss_date_in_map(p7_a16);
    ddp_qtev_rec.date_proposal := rosetta_g_miss_date_in_map(p7_a17);
    ddp_qtev_rec.date_effective_to := rosetta_g_miss_date_in_map(p7_a18);
    ddp_qtev_rec.date_accepted := rosetta_g_miss_date_in_map(p7_a19);
    ddp_qtev_rec.summary_format_yn := p7_a20;
    ddp_qtev_rec.consolidated_yn := p7_a21;
    ddp_qtev_rec.principal_paydown_amount := rosetta_g_miss_num_map(p7_a22);
    ddp_qtev_rec.residual_amount := rosetta_g_miss_num_map(p7_a23);
    ddp_qtev_rec.yield := rosetta_g_miss_num_map(p7_a24);
    ddp_qtev_rec.rent_amount := rosetta_g_miss_num_map(p7_a25);
    ddp_qtev_rec.date_restructure_end := rosetta_g_miss_date_in_map(p7_a26);
    ddp_qtev_rec.date_restructure_start := rosetta_g_miss_date_in_map(p7_a27);
    ddp_qtev_rec.term := rosetta_g_miss_num_map(p7_a28);
    ddp_qtev_rec.purchase_percent := rosetta_g_miss_num_map(p7_a29);
    ddp_qtev_rec.comments := p7_a30;
    ddp_qtev_rec.date_due := rosetta_g_miss_date_in_map(p7_a31);
    ddp_qtev_rec.payment_frequency := p7_a32;
    ddp_qtev_rec.remaining_payments := rosetta_g_miss_num_map(p7_a33);
    ddp_qtev_rec.date_effective_from := rosetta_g_miss_date_in_map(p7_a34);
    ddp_qtev_rec.quote_number := rosetta_g_miss_num_map(p7_a35);
    ddp_qtev_rec.requested_by := rosetta_g_miss_num_map(p7_a36);
    ddp_qtev_rec.approved_yn := p7_a37;
    ddp_qtev_rec.accepted_yn := p7_a38;
    ddp_qtev_rec.payment_received_yn := p7_a39;
    ddp_qtev_rec.date_payment_received := rosetta_g_miss_date_in_map(p7_a40);
    ddp_qtev_rec.attribute_category := p7_a41;
    ddp_qtev_rec.attribute1 := p7_a42;
    ddp_qtev_rec.attribute2 := p7_a43;
    ddp_qtev_rec.attribute3 := p7_a44;
    ddp_qtev_rec.attribute4 := p7_a45;
    ddp_qtev_rec.attribute5 := p7_a46;
    ddp_qtev_rec.attribute6 := p7_a47;
    ddp_qtev_rec.attribute7 := p7_a48;
    ddp_qtev_rec.attribute8 := p7_a49;
    ddp_qtev_rec.attribute9 := p7_a50;
    ddp_qtev_rec.attribute10 := p7_a51;
    ddp_qtev_rec.attribute11 := p7_a52;
    ddp_qtev_rec.attribute12 := p7_a53;
    ddp_qtev_rec.attribute13 := p7_a54;
    ddp_qtev_rec.attribute14 := p7_a55;
    ddp_qtev_rec.attribute15 := p7_a56;
    ddp_qtev_rec.date_approved := rosetta_g_miss_date_in_map(p7_a57);
    ddp_qtev_rec.approved_by := rosetta_g_miss_num_map(p7_a58);
    ddp_qtev_rec.org_id := rosetta_g_miss_num_map(p7_a59);
    ddp_qtev_rec.request_id := rosetta_g_miss_num_map(p7_a60);
    ddp_qtev_rec.program_application_id := rosetta_g_miss_num_map(p7_a61);
    ddp_qtev_rec.program_id := rosetta_g_miss_num_map(p7_a62);
    ddp_qtev_rec.program_update_date := rosetta_g_miss_date_in_map(p7_a63);
    ddp_qtev_rec.created_by := rosetta_g_miss_num_map(p7_a64);
    ddp_qtev_rec.creation_date := rosetta_g_miss_date_in_map(p7_a65);
    ddp_qtev_rec.last_updated_by := rosetta_g_miss_num_map(p7_a66);
    ddp_qtev_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a67);
    ddp_qtev_rec.last_update_login := rosetta_g_miss_num_map(p7_a68);
    ddp_qtev_rec.purchase_amount := rosetta_g_miss_num_map(p7_a69);
    ddp_qtev_rec.purchase_formula := p7_a70;
    ddp_qtev_rec.asset_value := rosetta_g_miss_num_map(p7_a71);
    ddp_qtev_rec.residual_value := rosetta_g_miss_num_map(p7_a72);
    ddp_qtev_rec.unbilled_receivables := rosetta_g_miss_num_map(p7_a73);
    ddp_qtev_rec.gain_loss := rosetta_g_miss_num_map(p7_a74);
    ddp_qtev_rec.currency_code := p7_a75;
    ddp_qtev_rec.currency_conversion_code := p7_a76;
    ddp_qtev_rec.currency_conversion_type := p7_a77;
    ddp_qtev_rec.currency_conversion_rate := rosetta_g_miss_num_map(p7_a78);
    ddp_qtev_rec.currency_conversion_date := rosetta_g_miss_date_in_map(p7_a79);


    -- here's the delegated call to the old PL/SQL routine
    okl_am_send_fulfillment_pvt.send_consolidate_quote(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_send_tbl,
      ddx_send_tbl,
      ddp_qtev_rec,
      ddx_qtev_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_am_send_fulfillment_pvt_w.rosetta_table_copy_out_p9(ddx_send_tbl, p6_a0
      , p6_a1
      , p6_a2
      , p6_a3
      , p6_a4
      , p6_a5
      , p6_a6
      , p6_a7
      , p6_a8
      );


    p8_a0 := rosetta_g_miss_num_map(ddx_qtev_rec.id);
    p8_a1 := rosetta_g_miss_num_map(ddx_qtev_rec.object_version_number);
    p8_a2 := ddx_qtev_rec.sfwt_flag;
    p8_a3 := ddx_qtev_rec.qrs_code;
    p8_a4 := ddx_qtev_rec.qst_code;
    p8_a5 := ddx_qtev_rec.qtp_code;
    p8_a6 := ddx_qtev_rec.trn_code;
    p8_a7 := ddx_qtev_rec.pop_code_end;
    p8_a8 := ddx_qtev_rec.pop_code_early;
    p8_a9 := rosetta_g_miss_num_map(ddx_qtev_rec.consolidated_qte_id);
    p8_a10 := rosetta_g_miss_num_map(ddx_qtev_rec.khr_id);
    p8_a11 := rosetta_g_miss_num_map(ddx_qtev_rec.art_id);
    p8_a12 := rosetta_g_miss_num_map(ddx_qtev_rec.pdt_id);
    p8_a13 := ddx_qtev_rec.early_termination_yn;
    p8_a14 := ddx_qtev_rec.partial_yn;
    p8_a15 := ddx_qtev_rec.preproceeds_yn;
    p8_a16 := ddx_qtev_rec.date_requested;
    p8_a17 := ddx_qtev_rec.date_proposal;
    p8_a18 := ddx_qtev_rec.date_effective_to;
    p8_a19 := ddx_qtev_rec.date_accepted;
    p8_a20 := ddx_qtev_rec.summary_format_yn;
    p8_a21 := ddx_qtev_rec.consolidated_yn;
    p8_a22 := rosetta_g_miss_num_map(ddx_qtev_rec.principal_paydown_amount);
    p8_a23 := rosetta_g_miss_num_map(ddx_qtev_rec.residual_amount);
    p8_a24 := rosetta_g_miss_num_map(ddx_qtev_rec.yield);
    p8_a25 := rosetta_g_miss_num_map(ddx_qtev_rec.rent_amount);
    p8_a26 := ddx_qtev_rec.date_restructure_end;
    p8_a27 := ddx_qtev_rec.date_restructure_start;
    p8_a28 := rosetta_g_miss_num_map(ddx_qtev_rec.term);
    p8_a29 := rosetta_g_miss_num_map(ddx_qtev_rec.purchase_percent);
    p8_a30 := ddx_qtev_rec.comments;
    p8_a31 := ddx_qtev_rec.date_due;
    p8_a32 := ddx_qtev_rec.payment_frequency;
    p8_a33 := rosetta_g_miss_num_map(ddx_qtev_rec.remaining_payments);
    p8_a34 := ddx_qtev_rec.date_effective_from;
    p8_a35 := rosetta_g_miss_num_map(ddx_qtev_rec.quote_number);
    p8_a36 := rosetta_g_miss_num_map(ddx_qtev_rec.requested_by);
    p8_a37 := ddx_qtev_rec.approved_yn;
    p8_a38 := ddx_qtev_rec.accepted_yn;
    p8_a39 := ddx_qtev_rec.payment_received_yn;
    p8_a40 := ddx_qtev_rec.date_payment_received;
    p8_a41 := ddx_qtev_rec.attribute_category;
    p8_a42 := ddx_qtev_rec.attribute1;
    p8_a43 := ddx_qtev_rec.attribute2;
    p8_a44 := ddx_qtev_rec.attribute3;
    p8_a45 := ddx_qtev_rec.attribute4;
    p8_a46 := ddx_qtev_rec.attribute5;
    p8_a47 := ddx_qtev_rec.attribute6;
    p8_a48 := ddx_qtev_rec.attribute7;
    p8_a49 := ddx_qtev_rec.attribute8;
    p8_a50 := ddx_qtev_rec.attribute9;
    p8_a51 := ddx_qtev_rec.attribute10;
    p8_a52 := ddx_qtev_rec.attribute11;
    p8_a53 := ddx_qtev_rec.attribute12;
    p8_a54 := ddx_qtev_rec.attribute13;
    p8_a55 := ddx_qtev_rec.attribute14;
    p8_a56 := ddx_qtev_rec.attribute15;
    p8_a57 := ddx_qtev_rec.date_approved;
    p8_a58 := rosetta_g_miss_num_map(ddx_qtev_rec.approved_by);
    p8_a59 := rosetta_g_miss_num_map(ddx_qtev_rec.org_id);
    p8_a60 := rosetta_g_miss_num_map(ddx_qtev_rec.request_id);
    p8_a61 := rosetta_g_miss_num_map(ddx_qtev_rec.program_application_id);
    p8_a62 := rosetta_g_miss_num_map(ddx_qtev_rec.program_id);
    p8_a63 := ddx_qtev_rec.program_update_date;
    p8_a64 := rosetta_g_miss_num_map(ddx_qtev_rec.created_by);
    p8_a65 := ddx_qtev_rec.creation_date;
    p8_a66 := rosetta_g_miss_num_map(ddx_qtev_rec.last_updated_by);
    p8_a67 := ddx_qtev_rec.last_update_date;
    p8_a68 := rosetta_g_miss_num_map(ddx_qtev_rec.last_update_login);
    p8_a69 := rosetta_g_miss_num_map(ddx_qtev_rec.purchase_amount);
    p8_a70 := ddx_qtev_rec.purchase_formula;
    p8_a71 := rosetta_g_miss_num_map(ddx_qtev_rec.asset_value);
    p8_a72 := rosetta_g_miss_num_map(ddx_qtev_rec.residual_value);
    p8_a73 := rosetta_g_miss_num_map(ddx_qtev_rec.unbilled_receivables);
    p8_a74 := rosetta_g_miss_num_map(ddx_qtev_rec.gain_loss);
    p8_a75 := ddx_qtev_rec.currency_code;
    p8_a76 := ddx_qtev_rec.currency_conversion_code;
    p8_a77 := ddx_qtev_rec.currency_conversion_type;
    p8_a78 := rosetta_g_miss_num_map(ddx_qtev_rec.currency_conversion_rate);
    p8_a79 := ddx_qtev_rec.currency_conversion_date;
  end;

end okl_am_send_fulfillment_pvt_w;

/
