--------------------------------------------------------
--  DDL for Package Body OKL_CREDIT_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_CREDIT_PUB_W" as
  /* $Header: OKLUCRDB.pls 115.7 2003/08/29 22:46:01 cklee noship $ */
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

  procedure rosetta_table_copy_in_p5(t out nocopy okl_credit_pub.clev_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_VARCHAR2_TABLE_200
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_VARCHAR2_TABLE_2000
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_DATE_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).chr_id := rosetta_g_miss_num_map(a1(indx));
          t(ddindx).lse_id := rosetta_g_miss_num_map(a2(indx));
          t(ddindx).line_number := a3(indx);
          t(ddindx).sts_code := a4(indx);
          t(ddindx).display_sequence := rosetta_g_miss_num_map(a5(indx));
          t(ddindx).dnz_chr_id := rosetta_g_miss_num_map(a6(indx));
          t(ddindx).item_description := a7(indx);
          t(ddindx).exception_yn := a8(indx);
          t(ddindx).start_date := rosetta_g_miss_date_in_map(a9(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p5;
  procedure rosetta_table_copy_out_p5(t okl_credit_pub.clev_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_VARCHAR2_TABLE_200
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_VARCHAR2_TABLE_2000
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    , a9 out nocopy JTF_DATE_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_VARCHAR2_TABLE_200();
    a4 := JTF_VARCHAR2_TABLE_100();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_VARCHAR2_TABLE_2000();
    a8 := JTF_VARCHAR2_TABLE_100();
    a9 := JTF_DATE_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_VARCHAR2_TABLE_200();
      a4 := JTF_VARCHAR2_TABLE_100();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_VARCHAR2_TABLE_2000();
      a8 := JTF_VARCHAR2_TABLE_100();
      a9 := JTF_DATE_TABLE();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).id);
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).chr_id);
          a2(indx) := rosetta_g_miss_num_map(t(ddindx).lse_id);
          a3(indx) := t(ddindx).line_number;
          a4(indx) := t(ddindx).sts_code;
          a5(indx) := rosetta_g_miss_num_map(t(ddindx).display_sequence);
          a6(indx) := rosetta_g_miss_num_map(t(ddindx).dnz_chr_id);
          a7(indx) := t(ddindx).item_description;
          a8(indx) := t(ddindx).exception_yn;
          a9(indx) := t(ddindx).start_date;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p5;

  procedure create_credit(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_contract_number  VARCHAR2
    , p_description  VARCHAR2
    , p_customer_id1  VARCHAR2
    , p_customer_id2  VARCHAR2
    , p_customer_code  VARCHAR2
    , p_customer_name  VARCHAR2
    , p_effective_from  date
    , p_effective_to  date
    , p_currency_code  VARCHAR2
    , p_currency_conv_type  VARCHAR2
    , p_currency_conv_rate  NUMBER
    , p_currency_conv_date  date
    , p_revolving_credit_yn  VARCHAR2
    , p_sts_code  VARCHAR2
    , p_credit_ckl_id  NUMBER
    , p_funding_ckl_id  NUMBER
    , p_cust_acct_id  NUMBER
    , p_cust_acct_number  VARCHAR2





    , p_org_id  NUMBER
    , p_organization_id  NUMBER
    , p_source_chr_id  NUMBER
    , x_chr_id out nocopy  NUMBER
  )

  as
    ddp_effective_from date;
    ddp_effective_to date;
    ddp_currency_conv_date date;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any











    ddp_effective_from := rosetta_g_miss_date_in_map(p_effective_from);

    ddp_effective_to := rosetta_g_miss_date_in_map(p_effective_to);




    ddp_currency_conv_date := rosetta_g_miss_date_in_map(p_currency_conv_date);











    -- here's the delegated call to the old PL/SQL routine
    okl_credit_pub.create_credit(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_contract_number,
      p_description,
      p_customer_id1,
      p_customer_id2,
      p_customer_code,
      p_customer_name,
      ddp_effective_from,
      ddp_effective_to,
      p_currency_code,
      p_currency_conv_type,
      p_currency_conv_rate,
      ddp_currency_conv_date,
      p_revolving_credit_yn,
      p_sts_code,
      p_credit_ckl_id,
      p_funding_ckl_id,
      p_cust_acct_id,
      p_cust_acct_number,
      p_org_id,
      p_organization_id,
      p_source_chr_id,
      x_chr_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any


























  end;

  procedure create_credit_header(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_credit_ckl_id  NUMBER
    , p_funding_ckl_id  NUMBER
    , p9_a0 out nocopy  NUMBER
    , p9_a1 out nocopy  NUMBER
    , p9_a2 out nocopy  VARCHAR2
    , p9_a3 out nocopy  NUMBER
    , p9_a4 out nocopy  NUMBER
    , p9_a5 out nocopy  NUMBER
    , p9_a6 out nocopy  NUMBER
    , p9_a7 out nocopy  VARCHAR2
    , p9_a8 out nocopy  NUMBER
    , p9_a9 out nocopy  VARCHAR2
    , p9_a10 out nocopy  VARCHAR2
    , p9_a11 out nocopy  VARCHAR2
    , p9_a12 out nocopy  VARCHAR2
    , p9_a13 out nocopy  VARCHAR2
    , p9_a14 out nocopy  VARCHAR2
    , p9_a15 out nocopy  VARCHAR2
    , p9_a16 out nocopy  VARCHAR2
    , p9_a17 out nocopy  VARCHAR2
    , p9_a18 out nocopy  VARCHAR2
    , p9_a19 out nocopy  VARCHAR2
    , p9_a20 out nocopy  VARCHAR2
    , p9_a21 out nocopy  VARCHAR2
    , p9_a22 out nocopy  VARCHAR2
    , p9_a23 out nocopy  VARCHAR2
    , p9_a24 out nocopy  VARCHAR2
    , p9_a25 out nocopy  DATE
    , p9_a26 out nocopy  DATE
    , p9_a27 out nocopy  NUMBER
    , p9_a28 out nocopy  DATE
    , p9_a29 out nocopy  DATE
    , p9_a30 out nocopy  VARCHAR2
    , p9_a31 out nocopy  VARCHAR2
    , p9_a32 out nocopy  VARCHAR2
    , p9_a33 out nocopy  VARCHAR2
    , p9_a34 out nocopy  VARCHAR2
    , p9_a35 out nocopy  VARCHAR2
    , p9_a36 out nocopy  NUMBER
    , p9_a37 out nocopy  NUMBER
    , p9_a38 out nocopy  DATE
    , p9_a39 out nocopy  DATE
    , p9_a40 out nocopy  DATE
    , p9_a41 out nocopy  DATE
    , p9_a42 out nocopy  DATE
    , p9_a43 out nocopy  VARCHAR2
    , p9_a44 out nocopy  DATE
    , p9_a45 out nocopy  DATE
    , p9_a46 out nocopy  NUMBER
    , p9_a47 out nocopy  VARCHAR2
    , p9_a48 out nocopy  VARCHAR2
    , p9_a49 out nocopy  NUMBER
    , p9_a50 out nocopy  NUMBER
    , p9_a51 out nocopy  NUMBER
    , p9_a52 out nocopy  VARCHAR2
    , p9_a53 out nocopy  VARCHAR2
    , p9_a54 out nocopy  NUMBER
    , p9_a55 out nocopy  NUMBER
    , p9_a56 out nocopy  VARCHAR2
    , p9_a57 out nocopy  NUMBER
    , p9_a58 out nocopy  VARCHAR2
    , p9_a59 out nocopy  NUMBER
    , p9_a60 out nocopy  NUMBER
    , p9_a61 out nocopy  NUMBER
    , p9_a62 out nocopy  DATE
    , p9_a63 out nocopy  DATE
    , p9_a64 out nocopy  DATE
    , p9_a65 out nocopy  NUMBER
    , p9_a66 out nocopy  NUMBER
    , p9_a67 out nocopy  NUMBER
    , p9_a68 out nocopy  VARCHAR2
    , p9_a69 out nocopy  VARCHAR2
    , p9_a70 out nocopy  VARCHAR2
    , p9_a71 out nocopy  VARCHAR2
    , p9_a72 out nocopy  VARCHAR2
    , p9_a73 out nocopy  VARCHAR2
    , p9_a74 out nocopy  VARCHAR2
    , p9_a75 out nocopy  VARCHAR2
    , p9_a76 out nocopy  VARCHAR2
    , p9_a77 out nocopy  VARCHAR2
    , p9_a78 out nocopy  VARCHAR2
    , p9_a79 out nocopy  VARCHAR2
    , p9_a80 out nocopy  VARCHAR2
    , p9_a81 out nocopy  VARCHAR2
    , p9_a82 out nocopy  VARCHAR2
    , p9_a83 out nocopy  VARCHAR2
    , p9_a84 out nocopy  NUMBER
    , p9_a85 out nocopy  DATE
    , p9_a86 out nocopy  NUMBER
    , p9_a87 out nocopy  DATE
    , p9_a88 out nocopy  NUMBER
    , p9_a89 out nocopy  VARCHAR2
    , p9_a90 out nocopy  VARCHAR2
    , p9_a91 out nocopy  VARCHAR2
    , p9_a92 out nocopy  VARCHAR2
    , p9_a93 out nocopy  VARCHAR2
    , p9_a94 out nocopy  NUMBER
    , p9_a95 out nocopy  DATE
    , p9_a96 out nocopy  NUMBER
    , p9_a97 out nocopy  NUMBER
    , p9_a98 out nocopy  NUMBER
    , p9_a99 out nocopy  NUMBER
    , p9_a100 out nocopy  VARCHAR2
    , p9_a101 out nocopy  NUMBER
    , p9_a102 out nocopy  DATE
    , p9_a103 out nocopy  NUMBER
    , p9_a104 out nocopy  NUMBER
    , p10_a0 out nocopy  NUMBER
    , p10_a1 out nocopy  NUMBER
    , p10_a2 out nocopy  NUMBER
    , p10_a3 out nocopy  NUMBER
    , p10_a4 out nocopy  NUMBER
    , p10_a5 out nocopy  VARCHAR2
    , p10_a6 out nocopy  DATE
    , p10_a7 out nocopy  VARCHAR2
    , p10_a8 out nocopy  VARCHAR2
    , p10_a9 out nocopy  DATE
    , p10_a10 out nocopy  VARCHAR2
    , p10_a11 out nocopy  NUMBER
    , p10_a12 out nocopy  VARCHAR2
    , p10_a13 out nocopy  DATE
    , p10_a14 out nocopy  VARCHAR2
    , p10_a15 out nocopy  VARCHAR2
    , p10_a16 out nocopy  DATE
    , p10_a17 out nocopy  DATE
    , p10_a18 out nocopy  DATE
    , p10_a19 out nocopy  DATE
    , p10_a20 out nocopy  VARCHAR2
    , p10_a21 out nocopy  VARCHAR2
    , p10_a22 out nocopy  VARCHAR2
    , p10_a23 out nocopy  VARCHAR2
    , p10_a24 out nocopy  VARCHAR2
    , p10_a25 out nocopy  VARCHAR2
    , p10_a26 out nocopy  VARCHAR2
    , p10_a27 out nocopy  VARCHAR2
    , p10_a28 out nocopy  VARCHAR2
    , p10_a29 out nocopy  VARCHAR2
    , p10_a30 out nocopy  VARCHAR2
    , p10_a31 out nocopy  VARCHAR2
    , p10_a32 out nocopy  VARCHAR2
    , p10_a33 out nocopy  VARCHAR2
    , p10_a34 out nocopy  VARCHAR2
    , p10_a35 out nocopy  VARCHAR2
    , p10_a36 out nocopy  NUMBER
    , p10_a37 out nocopy  DATE
    , p10_a38 out nocopy  NUMBER
    , p10_a39 out nocopy  DATE
    , p10_a40 out nocopy  NUMBER
    , p10_a41 out nocopy  NUMBER
    , p10_a42 out nocopy  NUMBER
    , p10_a43 out nocopy  NUMBER
    , p10_a44 out nocopy  NUMBER
    , p10_a45 out nocopy  NUMBER
    , p10_a46 out nocopy  NUMBER
    , p10_a47 out nocopy  NUMBER
    , p10_a48 out nocopy  NUMBER
    , p10_a49 out nocopy  DATE
    , p10_a50 out nocopy  VARCHAR2
    , p10_a51 out nocopy  NUMBER
    , p10_a52 out nocopy  NUMBER
    , p10_a53 out nocopy  DATE
    , p10_a54 out nocopy  DATE
    , p10_a55 out nocopy  VARCHAR2
    , p10_a56 out nocopy  VARCHAR2
    , p10_a57 out nocopy  VARCHAR2
    , p10_a58 out nocopy  NUMBER
    , p10_a59 out nocopy  DATE
    , p10_a60 out nocopy  VARCHAR2
    , p10_a61 out nocopy  VARCHAR2
    , p10_a62 out nocopy  VARCHAR2
    , p10_a63 out nocopy  VARCHAR2
    , p10_a64 out nocopy  VARCHAR2
    , p10_a65 out nocopy  VARCHAR2
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  NUMBER := 0-1962.0724
    , p7_a2  VARCHAR2 := fnd_api.g_miss_char
    , p7_a3  NUMBER := 0-1962.0724
    , p7_a4  NUMBER := 0-1962.0724
    , p7_a5  NUMBER := 0-1962.0724
    , p7_a6  NUMBER := 0-1962.0724
    , p7_a7  VARCHAR2 := fnd_api.g_miss_char
    , p7_a8  NUMBER := 0-1962.0724
    , p7_a9  VARCHAR2 := fnd_api.g_miss_char
    , p7_a10  VARCHAR2 := fnd_api.g_miss_char
    , p7_a11  VARCHAR2 := fnd_api.g_miss_char
    , p7_a12  VARCHAR2 := fnd_api.g_miss_char
    , p7_a13  VARCHAR2 := fnd_api.g_miss_char
    , p7_a14  VARCHAR2 := fnd_api.g_miss_char
    , p7_a15  VARCHAR2 := fnd_api.g_miss_char
    , p7_a16  VARCHAR2 := fnd_api.g_miss_char
    , p7_a17  VARCHAR2 := fnd_api.g_miss_char
    , p7_a18  VARCHAR2 := fnd_api.g_miss_char
    , p7_a19  VARCHAR2 := fnd_api.g_miss_char
    , p7_a20  VARCHAR2 := fnd_api.g_miss_char
    , p7_a21  VARCHAR2 := fnd_api.g_miss_char
    , p7_a22  VARCHAR2 := fnd_api.g_miss_char
    , p7_a23  VARCHAR2 := fnd_api.g_miss_char
    , p7_a24  VARCHAR2 := fnd_api.g_miss_char
    , p7_a25  DATE := fnd_api.g_miss_date
    , p7_a26  DATE := fnd_api.g_miss_date
    , p7_a27  NUMBER := 0-1962.0724
    , p7_a28  DATE := fnd_api.g_miss_date
    , p7_a29  DATE := fnd_api.g_miss_date
    , p7_a30  VARCHAR2 := fnd_api.g_miss_char
    , p7_a31  VARCHAR2 := fnd_api.g_miss_char
    , p7_a32  VARCHAR2 := fnd_api.g_miss_char
    , p7_a33  VARCHAR2 := fnd_api.g_miss_char
    , p7_a34  VARCHAR2 := fnd_api.g_miss_char
    , p7_a35  VARCHAR2 := fnd_api.g_miss_char
    , p7_a36  NUMBER := 0-1962.0724
    , p7_a37  NUMBER := 0-1962.0724
    , p7_a38  DATE := fnd_api.g_miss_date
    , p7_a39  DATE := fnd_api.g_miss_date
    , p7_a40  DATE := fnd_api.g_miss_date
    , p7_a41  DATE := fnd_api.g_miss_date
    , p7_a42  DATE := fnd_api.g_miss_date
    , p7_a43  VARCHAR2 := fnd_api.g_miss_char
    , p7_a44  DATE := fnd_api.g_miss_date
    , p7_a45  DATE := fnd_api.g_miss_date
    , p7_a46  NUMBER := 0-1962.0724
    , p7_a47  VARCHAR2 := fnd_api.g_miss_char
    , p7_a48  VARCHAR2 := fnd_api.g_miss_char
    , p7_a49  NUMBER := 0-1962.0724
    , p7_a50  NUMBER := 0-1962.0724
    , p7_a51  NUMBER := 0-1962.0724
    , p7_a52  VARCHAR2 := fnd_api.g_miss_char
    , p7_a53  VARCHAR2 := fnd_api.g_miss_char
    , p7_a54  NUMBER := 0-1962.0724
    , p7_a55  NUMBER := 0-1962.0724
    , p7_a56  VARCHAR2 := fnd_api.g_miss_char
    , p7_a57  NUMBER := 0-1962.0724
    , p7_a58  VARCHAR2 := fnd_api.g_miss_char
    , p7_a59  NUMBER := 0-1962.0724
    , p7_a60  NUMBER := 0-1962.0724
    , p7_a61  NUMBER := 0-1962.0724
    , p7_a62  DATE := fnd_api.g_miss_date
    , p7_a63  DATE := fnd_api.g_miss_date
    , p7_a64  DATE := fnd_api.g_miss_date
    , p7_a65  NUMBER := 0-1962.0724
    , p7_a66  NUMBER := 0-1962.0724
    , p7_a67  NUMBER := 0-1962.0724
    , p7_a68  VARCHAR2 := fnd_api.g_miss_char
    , p7_a69  VARCHAR2 := fnd_api.g_miss_char
    , p7_a70  VARCHAR2 := fnd_api.g_miss_char
    , p7_a71  VARCHAR2 := fnd_api.g_miss_char
    , p7_a72  VARCHAR2 := fnd_api.g_miss_char
    , p7_a73  VARCHAR2 := fnd_api.g_miss_char
    , p7_a74  VARCHAR2 := fnd_api.g_miss_char
    , p7_a75  VARCHAR2 := fnd_api.g_miss_char
    , p7_a76  VARCHAR2 := fnd_api.g_miss_char
    , p7_a77  VARCHAR2 := fnd_api.g_miss_char
    , p7_a78  VARCHAR2 := fnd_api.g_miss_char
    , p7_a79  VARCHAR2 := fnd_api.g_miss_char
    , p7_a80  VARCHAR2 := fnd_api.g_miss_char
    , p7_a81  VARCHAR2 := fnd_api.g_miss_char
    , p7_a82  VARCHAR2 := fnd_api.g_miss_char
    , p7_a83  VARCHAR2 := fnd_api.g_miss_char
    , p7_a84  NUMBER := 0-1962.0724
    , p7_a85  DATE := fnd_api.g_miss_date
    , p7_a86  NUMBER := 0-1962.0724
    , p7_a87  DATE := fnd_api.g_miss_date
    , p7_a88  NUMBER := 0-1962.0724
    , p7_a89  VARCHAR2 := fnd_api.g_miss_char
    , p7_a90  VARCHAR2 := fnd_api.g_miss_char
    , p7_a91  VARCHAR2 := fnd_api.g_miss_char
    , p7_a92  VARCHAR2 := fnd_api.g_miss_char
    , p7_a93  VARCHAR2 := fnd_api.g_miss_char
    , p7_a94  NUMBER := 0-1962.0724
    , p7_a95  DATE := fnd_api.g_miss_date
    , p7_a96  NUMBER := 0-1962.0724
    , p7_a97  NUMBER := 0-1962.0724
    , p7_a98  NUMBER := 0-1962.0724
    , p7_a99  NUMBER := 0-1962.0724
    , p7_a100  VARCHAR2 := fnd_api.g_miss_char
    , p7_a101  NUMBER := 0-1962.0724
    , p7_a102  DATE := fnd_api.g_miss_date
    , p7_a103  NUMBER := 0-1962.0724
    , p7_a104  NUMBER := 0-1962.0724
    , p8_a0  NUMBER := 0-1962.0724
    , p8_a1  NUMBER := 0-1962.0724
    , p8_a2  NUMBER := 0-1962.0724
    , p8_a3  NUMBER := 0-1962.0724
    , p8_a4  NUMBER := 0-1962.0724
    , p8_a5  VARCHAR2 := fnd_api.g_miss_char
    , p8_a6  DATE := fnd_api.g_miss_date
    , p8_a7  VARCHAR2 := fnd_api.g_miss_char
    , p8_a8  VARCHAR2 := fnd_api.g_miss_char
    , p8_a9  DATE := fnd_api.g_miss_date
    , p8_a10  VARCHAR2 := fnd_api.g_miss_char
    , p8_a11  NUMBER := 0-1962.0724
    , p8_a12  VARCHAR2 := fnd_api.g_miss_char
    , p8_a13  DATE := fnd_api.g_miss_date
    , p8_a14  VARCHAR2 := fnd_api.g_miss_char
    , p8_a15  VARCHAR2 := fnd_api.g_miss_char
    , p8_a16  DATE := fnd_api.g_miss_date
    , p8_a17  DATE := fnd_api.g_miss_date
    , p8_a18  DATE := fnd_api.g_miss_date
    , p8_a19  DATE := fnd_api.g_miss_date
    , p8_a20  VARCHAR2 := fnd_api.g_miss_char
    , p8_a21  VARCHAR2 := fnd_api.g_miss_char
    , p8_a22  VARCHAR2 := fnd_api.g_miss_char
    , p8_a23  VARCHAR2 := fnd_api.g_miss_char
    , p8_a24  VARCHAR2 := fnd_api.g_miss_char
    , p8_a25  VARCHAR2 := fnd_api.g_miss_char
    , p8_a26  VARCHAR2 := fnd_api.g_miss_char
    , p8_a27  VARCHAR2 := fnd_api.g_miss_char
    , p8_a28  VARCHAR2 := fnd_api.g_miss_char
    , p8_a29  VARCHAR2 := fnd_api.g_miss_char
    , p8_a30  VARCHAR2 := fnd_api.g_miss_char
    , p8_a31  VARCHAR2 := fnd_api.g_miss_char
    , p8_a32  VARCHAR2 := fnd_api.g_miss_char
    , p8_a33  VARCHAR2 := fnd_api.g_miss_char
    , p8_a34  VARCHAR2 := fnd_api.g_miss_char
    , p8_a35  VARCHAR2 := fnd_api.g_miss_char
    , p8_a36  NUMBER := 0-1962.0724
    , p8_a37  DATE := fnd_api.g_miss_date
    , p8_a38  NUMBER := 0-1962.0724
    , p8_a39  DATE := fnd_api.g_miss_date
    , p8_a40  NUMBER := 0-1962.0724
    , p8_a41  NUMBER := 0-1962.0724
    , p8_a42  NUMBER := 0-1962.0724
    , p8_a43  NUMBER := 0-1962.0724
    , p8_a44  NUMBER := 0-1962.0724
    , p8_a45  NUMBER := 0-1962.0724
    , p8_a46  NUMBER := 0-1962.0724
    , p8_a47  NUMBER := 0-1962.0724
    , p8_a48  NUMBER := 0-1962.0724
    , p8_a49  DATE := fnd_api.g_miss_date
    , p8_a50  VARCHAR2 := fnd_api.g_miss_char
    , p8_a51  NUMBER := 0-1962.0724
    , p8_a52  NUMBER := 0-1962.0724
    , p8_a53  DATE := fnd_api.g_miss_date
    , p8_a54  DATE := fnd_api.g_miss_date
    , p8_a55  VARCHAR2 := fnd_api.g_miss_char
    , p8_a56  VARCHAR2 := fnd_api.g_miss_char
    , p8_a57  VARCHAR2 := fnd_api.g_miss_char
    , p8_a58  NUMBER := 0-1962.0724
    , p8_a59  DATE := fnd_api.g_miss_date
    , p8_a60  VARCHAR2 := fnd_api.g_miss_char
    , p8_a61  VARCHAR2 := fnd_api.g_miss_char
    , p8_a62  VARCHAR2 := fnd_api.g_miss_char
    , p8_a63  VARCHAR2 := fnd_api.g_miss_char
    , p8_a64  VARCHAR2 := fnd_api.g_miss_char
    , p8_a65  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_chrv_rec okl_okc_migration_pvt.chrv_rec_type;
    ddp_khrv_rec okl_credit_pub.khrv_rec_type;
    ddx_chrv_rec okl_okc_migration_pvt.chrv_rec_type;
    ddx_khrv_rec okl_credit_pub.khrv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_chrv_rec.id := rosetta_g_miss_num_map(p7_a0);
    ddp_chrv_rec.object_version_number := rosetta_g_miss_num_map(p7_a1);
    ddp_chrv_rec.sfwt_flag := p7_a2;
    ddp_chrv_rec.chr_id_response := rosetta_g_miss_num_map(p7_a3);
    ddp_chrv_rec.chr_id_award := rosetta_g_miss_num_map(p7_a4);
    ddp_chrv_rec.chr_id_renewed := rosetta_g_miss_num_map(p7_a5);
    ddp_chrv_rec.inv_organization_id := rosetta_g_miss_num_map(p7_a6);
    ddp_chrv_rec.sts_code := p7_a7;
    ddp_chrv_rec.qcl_id := rosetta_g_miss_num_map(p7_a8);
    ddp_chrv_rec.scs_code := p7_a9;
    ddp_chrv_rec.contract_number := p7_a10;
    ddp_chrv_rec.currency_code := p7_a11;
    ddp_chrv_rec.contract_number_modifier := p7_a12;
    ddp_chrv_rec.archived_yn := p7_a13;
    ddp_chrv_rec.deleted_yn := p7_a14;
    ddp_chrv_rec.cust_po_number_req_yn := p7_a15;
    ddp_chrv_rec.pre_pay_req_yn := p7_a16;
    ddp_chrv_rec.cust_po_number := p7_a17;
    ddp_chrv_rec.short_description := p7_a18;
    ddp_chrv_rec.comments := p7_a19;
    ddp_chrv_rec.description := p7_a20;
    ddp_chrv_rec.dpas_rating := p7_a21;
    ddp_chrv_rec.cognomen := p7_a22;
    ddp_chrv_rec.template_yn := p7_a23;
    ddp_chrv_rec.template_used := p7_a24;
    ddp_chrv_rec.date_approved := rosetta_g_miss_date_in_map(p7_a25);
    ddp_chrv_rec.datetime_cancelled := rosetta_g_miss_date_in_map(p7_a26);
    ddp_chrv_rec.auto_renew_days := rosetta_g_miss_num_map(p7_a27);
    ddp_chrv_rec.date_issued := rosetta_g_miss_date_in_map(p7_a28);
    ddp_chrv_rec.datetime_responded := rosetta_g_miss_date_in_map(p7_a29);
    ddp_chrv_rec.non_response_reason := p7_a30;
    ddp_chrv_rec.non_response_explain := p7_a31;
    ddp_chrv_rec.rfp_type := p7_a32;
    ddp_chrv_rec.chr_type := p7_a33;
    ddp_chrv_rec.keep_on_mail_list := p7_a34;
    ddp_chrv_rec.set_aside_reason := p7_a35;
    ddp_chrv_rec.set_aside_percent := rosetta_g_miss_num_map(p7_a36);
    ddp_chrv_rec.response_copies_req := rosetta_g_miss_num_map(p7_a37);
    ddp_chrv_rec.date_close_projected := rosetta_g_miss_date_in_map(p7_a38);
    ddp_chrv_rec.datetime_proposed := rosetta_g_miss_date_in_map(p7_a39);
    ddp_chrv_rec.date_signed := rosetta_g_miss_date_in_map(p7_a40);
    ddp_chrv_rec.date_terminated := rosetta_g_miss_date_in_map(p7_a41);
    ddp_chrv_rec.date_renewed := rosetta_g_miss_date_in_map(p7_a42);
    ddp_chrv_rec.trn_code := p7_a43;
    ddp_chrv_rec.start_date := rosetta_g_miss_date_in_map(p7_a44);
    ddp_chrv_rec.end_date := rosetta_g_miss_date_in_map(p7_a45);
    ddp_chrv_rec.authoring_org_id := rosetta_g_miss_num_map(p7_a46);
    ddp_chrv_rec.buy_or_sell := p7_a47;
    ddp_chrv_rec.issue_or_receive := p7_a48;
    ddp_chrv_rec.estimated_amount := rosetta_g_miss_num_map(p7_a49);
    ddp_chrv_rec.chr_id_renewed_to := rosetta_g_miss_num_map(p7_a50);
    ddp_chrv_rec.estimated_amount_renewed := rosetta_g_miss_num_map(p7_a51);
    ddp_chrv_rec.currency_code_renewed := p7_a52;
    ddp_chrv_rec.upg_orig_system_ref := p7_a53;
    ddp_chrv_rec.upg_orig_system_ref_id := rosetta_g_miss_num_map(p7_a54);
    ddp_chrv_rec.application_id := rosetta_g_miss_num_map(p7_a55);
    ddp_chrv_rec.orig_system_source_code := p7_a56;
    ddp_chrv_rec.orig_system_id1 := rosetta_g_miss_num_map(p7_a57);
    ddp_chrv_rec.orig_system_reference1 := p7_a58;
    ddp_chrv_rec.program_id := rosetta_g_miss_num_map(p7_a59);
    ddp_chrv_rec.request_id := rosetta_g_miss_num_map(p7_a60);
    ddp_chrv_rec.price_list_id := rosetta_g_miss_num_map(p7_a61);
    ddp_chrv_rec.pricing_date := rosetta_g_miss_date_in_map(p7_a62);
    ddp_chrv_rec.sign_by_date := rosetta_g_miss_date_in_map(p7_a63);
    ddp_chrv_rec.program_update_date := rosetta_g_miss_date_in_map(p7_a64);
    ddp_chrv_rec.total_line_list_price := rosetta_g_miss_num_map(p7_a65);
    ddp_chrv_rec.program_application_id := rosetta_g_miss_num_map(p7_a66);
    ddp_chrv_rec.user_estimated_amount := rosetta_g_miss_num_map(p7_a67);
    ddp_chrv_rec.attribute_category := p7_a68;
    ddp_chrv_rec.attribute1 := p7_a69;
    ddp_chrv_rec.attribute2 := p7_a70;
    ddp_chrv_rec.attribute3 := p7_a71;
    ddp_chrv_rec.attribute4 := p7_a72;
    ddp_chrv_rec.attribute5 := p7_a73;
    ddp_chrv_rec.attribute6 := p7_a74;
    ddp_chrv_rec.attribute7 := p7_a75;
    ddp_chrv_rec.attribute8 := p7_a76;
    ddp_chrv_rec.attribute9 := p7_a77;
    ddp_chrv_rec.attribute10 := p7_a78;
    ddp_chrv_rec.attribute11 := p7_a79;
    ddp_chrv_rec.attribute12 := p7_a80;
    ddp_chrv_rec.attribute13 := p7_a81;
    ddp_chrv_rec.attribute14 := p7_a82;
    ddp_chrv_rec.attribute15 := p7_a83;
    ddp_chrv_rec.created_by := rosetta_g_miss_num_map(p7_a84);
    ddp_chrv_rec.creation_date := rosetta_g_miss_date_in_map(p7_a85);
    ddp_chrv_rec.last_updated_by := rosetta_g_miss_num_map(p7_a86);
    ddp_chrv_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a87);
    ddp_chrv_rec.last_update_login := rosetta_g_miss_num_map(p7_a88);
    ddp_chrv_rec.old_sts_code := p7_a89;
    ddp_chrv_rec.new_sts_code := p7_a90;
    ddp_chrv_rec.old_ste_code := p7_a91;
    ddp_chrv_rec.new_ste_code := p7_a92;
    ddp_chrv_rec.conversion_type := p7_a93;
    ddp_chrv_rec.conversion_rate := rosetta_g_miss_num_map(p7_a94);
    ddp_chrv_rec.conversion_rate_date := rosetta_g_miss_date_in_map(p7_a95);
    ddp_chrv_rec.conversion_euro_rate := rosetta_g_miss_num_map(p7_a96);
    ddp_chrv_rec.cust_acct_id := rosetta_g_miss_num_map(p7_a97);
    ddp_chrv_rec.bill_to_site_use_id := rosetta_g_miss_num_map(p7_a98);
    ddp_chrv_rec.inv_rule_id := rosetta_g_miss_num_map(p7_a99);
    ddp_chrv_rec.renewal_type_code := p7_a100;
    ddp_chrv_rec.renewal_notify_to := rosetta_g_miss_num_map(p7_a101);
    ddp_chrv_rec.renewal_end_date := rosetta_g_miss_date_in_map(p7_a102);
    ddp_chrv_rec.ship_to_site_use_id := rosetta_g_miss_num_map(p7_a103);
    ddp_chrv_rec.payment_term_id := rosetta_g_miss_num_map(p7_a104);

    ddp_khrv_rec.id := rosetta_g_miss_num_map(p8_a0);
    ddp_khrv_rec.object_version_number := rosetta_g_miss_num_map(p8_a1);
    ddp_khrv_rec.isg_id := rosetta_g_miss_num_map(p8_a2);
    ddp_khrv_rec.khr_id := rosetta_g_miss_num_map(p8_a3);
    ddp_khrv_rec.pdt_id := rosetta_g_miss_num_map(p8_a4);
    ddp_khrv_rec.amd_code := p8_a5;
    ddp_khrv_rec.date_first_activity := rosetta_g_miss_date_in_map(p8_a6);
    ddp_khrv_rec.generate_accrual_yn := p8_a7;
    ddp_khrv_rec.generate_accrual_override_yn := p8_a8;
    ddp_khrv_rec.date_refinanced := rosetta_g_miss_date_in_map(p8_a9);
    ddp_khrv_rec.credit_act_yn := p8_a10;
    ddp_khrv_rec.term_duration := rosetta_g_miss_num_map(p8_a11);
    ddp_khrv_rec.converted_account_yn := p8_a12;
    ddp_khrv_rec.date_conversion_effective := rosetta_g_miss_date_in_map(p8_a13);
    ddp_khrv_rec.syndicatable_yn := p8_a14;
    ddp_khrv_rec.salestype_yn := p8_a15;
    ddp_khrv_rec.date_deal_transferred := rosetta_g_miss_date_in_map(p8_a16);
    ddp_khrv_rec.datetime_proposal_effective := rosetta_g_miss_date_in_map(p8_a17);
    ddp_khrv_rec.datetime_proposal_ineffective := rosetta_g_miss_date_in_map(p8_a18);
    ddp_khrv_rec.date_proposal_accepted := rosetta_g_miss_date_in_map(p8_a19);
    ddp_khrv_rec.attribute_category := p8_a20;
    ddp_khrv_rec.attribute1 := p8_a21;
    ddp_khrv_rec.attribute2 := p8_a22;
    ddp_khrv_rec.attribute3 := p8_a23;
    ddp_khrv_rec.attribute4 := p8_a24;
    ddp_khrv_rec.attribute5 := p8_a25;
    ddp_khrv_rec.attribute6 := p8_a26;
    ddp_khrv_rec.attribute7 := p8_a27;
    ddp_khrv_rec.attribute8 := p8_a28;
    ddp_khrv_rec.attribute9 := p8_a29;
    ddp_khrv_rec.attribute10 := p8_a30;
    ddp_khrv_rec.attribute11 := p8_a31;
    ddp_khrv_rec.attribute12 := p8_a32;
    ddp_khrv_rec.attribute13 := p8_a33;
    ddp_khrv_rec.attribute14 := p8_a34;
    ddp_khrv_rec.attribute15 := p8_a35;
    ddp_khrv_rec.created_by := rosetta_g_miss_num_map(p8_a36);
    ddp_khrv_rec.creation_date := rosetta_g_miss_date_in_map(p8_a37);
    ddp_khrv_rec.last_updated_by := rosetta_g_miss_num_map(p8_a38);
    ddp_khrv_rec.last_update_date := rosetta_g_miss_date_in_map(p8_a39);
    ddp_khrv_rec.last_update_login := rosetta_g_miss_num_map(p8_a40);
    ddp_khrv_rec.pre_tax_yield := rosetta_g_miss_num_map(p8_a41);
    ddp_khrv_rec.after_tax_yield := rosetta_g_miss_num_map(p8_a42);
    ddp_khrv_rec.implicit_interest_rate := rosetta_g_miss_num_map(p8_a43);
    ddp_khrv_rec.implicit_non_idc_interest_rate := rosetta_g_miss_num_map(p8_a44);
    ddp_khrv_rec.target_pre_tax_yield := rosetta_g_miss_num_map(p8_a45);
    ddp_khrv_rec.target_after_tax_yield := rosetta_g_miss_num_map(p8_a46);
    ddp_khrv_rec.target_implicit_interest_rate := rosetta_g_miss_num_map(p8_a47);
    ddp_khrv_rec.target_implicit_nonidc_intrate := rosetta_g_miss_num_map(p8_a48);
    ddp_khrv_rec.date_last_interim_interest_cal := rosetta_g_miss_date_in_map(p8_a49);
    ddp_khrv_rec.deal_type := p8_a50;
    ddp_khrv_rec.pre_tax_irr := rosetta_g_miss_num_map(p8_a51);
    ddp_khrv_rec.after_tax_irr := rosetta_g_miss_num_map(p8_a52);
    ddp_khrv_rec.expected_delivery_date := rosetta_g_miss_date_in_map(p8_a53);
    ddp_khrv_rec.accepted_date := rosetta_g_miss_date_in_map(p8_a54);
    ddp_khrv_rec.prefunding_eligible_yn := p8_a55;

    ddp_khrv_rec.revolving_credit_yn := p8_a56;
    ddp_khrv_rec.currency_conversion_type := p8_a57;
    ddp_khrv_rec.currency_conversion_rate := rosetta_g_miss_num_map(p8_a58);
    ddp_khrv_rec.currency_conversion_date := rosetta_g_miss_date_in_map(p8_a59);
    ddp_khrv_rec.multi_gaap_yn := p8_a60;
    ddp_khrv_rec.recourse_code := p8_a61;
    ddp_khrv_rec.lessor_serv_org_code := p8_a62;
    ddp_khrv_rec.assignable_yn := p8_a63;
    ddp_khrv_rec.securitized_code := p8_a64;
    ddp_khrv_rec.securitization_type := p8_a65;



    -- here's the delegated call to the old PL/SQL routine
    okl_credit_pub.create_credit_header(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_credit_ckl_id,
      p_funding_ckl_id,
      ddp_chrv_rec,
      ddp_khrv_rec,
      ddx_chrv_rec,
      ddx_khrv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any









    p9_a0 := rosetta_g_miss_num_map(ddx_chrv_rec.id);
    p9_a1 := rosetta_g_miss_num_map(ddx_chrv_rec.object_version_number);
    p9_a2 := ddx_chrv_rec.sfwt_flag;
    p9_a3 := rosetta_g_miss_num_map(ddx_chrv_rec.chr_id_response);
    p9_a4 := rosetta_g_miss_num_map(ddx_chrv_rec.chr_id_award);
    p9_a5 := rosetta_g_miss_num_map(ddx_chrv_rec.chr_id_renewed);
    p9_a6 := rosetta_g_miss_num_map(ddx_chrv_rec.inv_organization_id);
    p9_a7 := ddx_chrv_rec.sts_code;
    p9_a8 := rosetta_g_miss_num_map(ddx_chrv_rec.qcl_id);
    p9_a9 := ddx_chrv_rec.scs_code;
    p9_a10 := ddx_chrv_rec.contract_number;
    p9_a11 := ddx_chrv_rec.currency_code;
    p9_a12 := ddx_chrv_rec.contract_number_modifier;
    p9_a13 := ddx_chrv_rec.archived_yn;
    p9_a14 := ddx_chrv_rec.deleted_yn;
    p9_a15 := ddx_chrv_rec.cust_po_number_req_yn;
    p9_a16 := ddx_chrv_rec.pre_pay_req_yn;
    p9_a17 := ddx_chrv_rec.cust_po_number;
    p9_a18 := ddx_chrv_rec.short_description;
    p9_a19 := ddx_chrv_rec.comments;
    p9_a20 := ddx_chrv_rec.description;
    p9_a21 := ddx_chrv_rec.dpas_rating;
    p9_a22 := ddx_chrv_rec.cognomen;
    p9_a23 := ddx_chrv_rec.template_yn;
    p9_a24 := ddx_chrv_rec.template_used;
    p9_a25 := ddx_chrv_rec.date_approved;
    p9_a26 := ddx_chrv_rec.datetime_cancelled;
    p9_a27 := rosetta_g_miss_num_map(ddx_chrv_rec.auto_renew_days);
    p9_a28 := ddx_chrv_rec.date_issued;
    p9_a29 := ddx_chrv_rec.datetime_responded;
    p9_a30 := ddx_chrv_rec.non_response_reason;
    p9_a31 := ddx_chrv_rec.non_response_explain;
    p9_a32 := ddx_chrv_rec.rfp_type;
    p9_a33 := ddx_chrv_rec.chr_type;
    p9_a34 := ddx_chrv_rec.keep_on_mail_list;
    p9_a35 := ddx_chrv_rec.set_aside_reason;
    p9_a36 := rosetta_g_miss_num_map(ddx_chrv_rec.set_aside_percent);
    p9_a37 := rosetta_g_miss_num_map(ddx_chrv_rec.response_copies_req);
    p9_a38 := ddx_chrv_rec.date_close_projected;
    p9_a39 := ddx_chrv_rec.datetime_proposed;
    p9_a40 := ddx_chrv_rec.date_signed;
    p9_a41 := ddx_chrv_rec.date_terminated;
    p9_a42 := ddx_chrv_rec.date_renewed;
    p9_a43 := ddx_chrv_rec.trn_code;
    p9_a44 := ddx_chrv_rec.start_date;
    p9_a45 := ddx_chrv_rec.end_date;
    p9_a46 := rosetta_g_miss_num_map(ddx_chrv_rec.authoring_org_id);
    p9_a47 := ddx_chrv_rec.buy_or_sell;
    p9_a48 := ddx_chrv_rec.issue_or_receive;
    p9_a49 := rosetta_g_miss_num_map(ddx_chrv_rec.estimated_amount);
    p9_a50 := rosetta_g_miss_num_map(ddx_chrv_rec.chr_id_renewed_to);
    p9_a51 := rosetta_g_miss_num_map(ddx_chrv_rec.estimated_amount_renewed);
    p9_a52 := ddx_chrv_rec.currency_code_renewed;
    p9_a53 := ddx_chrv_rec.upg_orig_system_ref;
    p9_a54 := rosetta_g_miss_num_map(ddx_chrv_rec.upg_orig_system_ref_id);
    p9_a55 := rosetta_g_miss_num_map(ddx_chrv_rec.application_id);
    p9_a56 := ddx_chrv_rec.orig_system_source_code;
    p9_a57 := rosetta_g_miss_num_map(ddx_chrv_rec.orig_system_id1);
    p9_a58 := ddx_chrv_rec.orig_system_reference1;
    p9_a59 := rosetta_g_miss_num_map(ddx_chrv_rec.program_id);
    p9_a60 := rosetta_g_miss_num_map(ddx_chrv_rec.request_id);
    p9_a61 := rosetta_g_miss_num_map(ddx_chrv_rec.price_list_id);
    p9_a62 := ddx_chrv_rec.pricing_date;
    p9_a63 := ddx_chrv_rec.sign_by_date;
    p9_a64 := ddx_chrv_rec.program_update_date;
    p9_a65 := rosetta_g_miss_num_map(ddx_chrv_rec.total_line_list_price);
    p9_a66 := rosetta_g_miss_num_map(ddx_chrv_rec.program_application_id);
    p9_a67 := rosetta_g_miss_num_map(ddx_chrv_rec.user_estimated_amount);
    p9_a68 := ddx_chrv_rec.attribute_category;
    p9_a69 := ddx_chrv_rec.attribute1;
    p9_a70 := ddx_chrv_rec.attribute2;
    p9_a71 := ddx_chrv_rec.attribute3;
    p9_a72 := ddx_chrv_rec.attribute4;
    p9_a73 := ddx_chrv_rec.attribute5;
    p9_a74 := ddx_chrv_rec.attribute6;
    p9_a75 := ddx_chrv_rec.attribute7;
    p9_a76 := ddx_chrv_rec.attribute8;
    p9_a77 := ddx_chrv_rec.attribute9;
    p9_a78 := ddx_chrv_rec.attribute10;
    p9_a79 := ddx_chrv_rec.attribute11;
    p9_a80 := ddx_chrv_rec.attribute12;
    p9_a81 := ddx_chrv_rec.attribute13;
    p9_a82 := ddx_chrv_rec.attribute14;
    p9_a83 := ddx_chrv_rec.attribute15;
    p9_a84 := rosetta_g_miss_num_map(ddx_chrv_rec.created_by);
    p9_a85 := ddx_chrv_rec.creation_date;
    p9_a86 := rosetta_g_miss_num_map(ddx_chrv_rec.last_updated_by);
    p9_a87 := ddx_chrv_rec.last_update_date;
    p9_a88 := rosetta_g_miss_num_map(ddx_chrv_rec.last_update_login);
    p9_a89 := ddx_chrv_rec.old_sts_code;
    p9_a90 := ddx_chrv_rec.new_sts_code;
    p9_a91 := ddx_chrv_rec.old_ste_code;
    p9_a92 := ddx_chrv_rec.new_ste_code;
    p9_a93 := ddx_chrv_rec.conversion_type;
    p9_a94 := rosetta_g_miss_num_map(ddx_chrv_rec.conversion_rate);
    p9_a95 := ddx_chrv_rec.conversion_rate_date;
    p9_a96 := rosetta_g_miss_num_map(ddx_chrv_rec.conversion_euro_rate);
    p9_a97 := rosetta_g_miss_num_map(ddx_chrv_rec.cust_acct_id);
    p9_a98 := rosetta_g_miss_num_map(ddx_chrv_rec.bill_to_site_use_id);
    p9_a99 := rosetta_g_miss_num_map(ddx_chrv_rec.inv_rule_id);
    p9_a100 := ddx_chrv_rec.renewal_type_code;
    p9_a101 := rosetta_g_miss_num_map(ddx_chrv_rec.renewal_notify_to);
    p9_a102 := ddx_chrv_rec.renewal_end_date;
    p9_a103 := rosetta_g_miss_num_map(ddx_chrv_rec.ship_to_site_use_id);
    p9_a104 := rosetta_g_miss_num_map(ddx_chrv_rec.payment_term_id);

    p10_a0 := rosetta_g_miss_num_map(ddx_khrv_rec.id);
    p10_a1 := rosetta_g_miss_num_map(ddx_khrv_rec.object_version_number);
    p10_a2 := rosetta_g_miss_num_map(ddx_khrv_rec.isg_id);
    p10_a3 := rosetta_g_miss_num_map(ddx_khrv_rec.khr_id);
    p10_a4 := rosetta_g_miss_num_map(ddx_khrv_rec.pdt_id);
    p10_a5 := ddx_khrv_rec.amd_code;
    p10_a6 := ddx_khrv_rec.date_first_activity;
    p10_a7 := ddx_khrv_rec.generate_accrual_yn;
    p10_a8 := ddx_khrv_rec.generate_accrual_override_yn;
    p10_a9 := ddx_khrv_rec.date_refinanced;
    p10_a10 := ddx_khrv_rec.credit_act_yn;
    p10_a11 := rosetta_g_miss_num_map(ddx_khrv_rec.term_duration);
    p10_a12 := ddx_khrv_rec.converted_account_yn;
    p10_a13 := ddx_khrv_rec.date_conversion_effective;
    p10_a14 := ddx_khrv_rec.syndicatable_yn;
    p10_a15 := ddx_khrv_rec.salestype_yn;
    p10_a16 := ddx_khrv_rec.date_deal_transferred;
    p10_a17 := ddx_khrv_rec.datetime_proposal_effective;
    p10_a18 := ddx_khrv_rec.datetime_proposal_ineffective;
    p10_a19 := ddx_khrv_rec.date_proposal_accepted;
    p10_a20 := ddx_khrv_rec.attribute_category;
    p10_a21 := ddx_khrv_rec.attribute1;
    p10_a22 := ddx_khrv_rec.attribute2;
    p10_a23 := ddx_khrv_rec.attribute3;
    p10_a24 := ddx_khrv_rec.attribute4;
    p10_a25 := ddx_khrv_rec.attribute5;
    p10_a26 := ddx_khrv_rec.attribute6;
    p10_a27 := ddx_khrv_rec.attribute7;
    p10_a28 := ddx_khrv_rec.attribute8;
    p10_a29 := ddx_khrv_rec.attribute9;
    p10_a30 := ddx_khrv_rec.attribute10;
    p10_a31 := ddx_khrv_rec.attribute11;
    p10_a32 := ddx_khrv_rec.attribute12;
    p10_a33 := ddx_khrv_rec.attribute13;
    p10_a34 := ddx_khrv_rec.attribute14;
    p10_a35 := ddx_khrv_rec.attribute15;
    p10_a36 := rosetta_g_miss_num_map(ddx_khrv_rec.created_by);
    p10_a37 := ddx_khrv_rec.creation_date;
    p10_a38 := rosetta_g_miss_num_map(ddx_khrv_rec.last_updated_by);
    p10_a39 := ddx_khrv_rec.last_update_date;
    p10_a40 := rosetta_g_miss_num_map(ddx_khrv_rec.last_update_login);
    p10_a41 := rosetta_g_miss_num_map(ddx_khrv_rec.pre_tax_yield);
    p10_a42 := rosetta_g_miss_num_map(ddx_khrv_rec.after_tax_yield);
    p10_a43 := rosetta_g_miss_num_map(ddx_khrv_rec.implicit_interest_rate);
    p10_a44 := rosetta_g_miss_num_map(ddx_khrv_rec.implicit_non_idc_interest_rate);
    p10_a45 := rosetta_g_miss_num_map(ddx_khrv_rec.target_pre_tax_yield);
    p10_a46 := rosetta_g_miss_num_map(ddx_khrv_rec.target_after_tax_yield);
    p10_a47 := rosetta_g_miss_num_map(ddx_khrv_rec.target_implicit_interest_rate);
    p10_a48 := rosetta_g_miss_num_map(ddx_khrv_rec.target_implicit_nonidc_intrate);
    p10_a49 := ddx_khrv_rec.date_last_interim_interest_cal;
    p10_a50 := ddx_khrv_rec.deal_type;
    p10_a51 := rosetta_g_miss_num_map(ddx_khrv_rec.pre_tax_irr);
    p10_a52 := rosetta_g_miss_num_map(ddx_khrv_rec.after_tax_irr);
    p10_a53 := ddx_khrv_rec.expected_delivery_date;
    p10_a54 := ddx_khrv_rec.accepted_date;
    p10_a55 := ddx_khrv_rec.prefunding_eligible_yn;
    p10_a56 := ddx_khrv_rec.revolving_credit_yn;
    p10_a57 := ddx_khrv_rec.currency_conversion_type;
    p10_a58 := rosetta_g_miss_num_map(ddx_khrv_rec.currency_conversion_rate);
    p10_a59 := ddx_khrv_rec.currency_conversion_date;
    p10_a60 := ddx_khrv_rec.multi_gaap_yn;
    p10_a61 := ddx_khrv_rec.recourse_code;
    p10_a62 := ddx_khrv_rec.lessor_serv_org_code;
    p10_a63 := ddx_khrv_rec.assignable_yn;
    p10_a64 := ddx_khrv_rec.securitized_code;
    p10_a65 := ddx_khrv_rec.securitization_type;
  end;

  procedure update_credit_header(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_restricted_update  VARCHAR2
    , p_chklst_tpl_rgp_id  NUMBER
    , p_chklst_tpl_rule_id  NUMBER
    , p_credit_ckl_id  NUMBER
    , p_funding_ckl_id  NUMBER
    , p12_a0 out nocopy  NUMBER
    , p12_a1 out nocopy  NUMBER
    , p12_a2 out nocopy  VARCHAR2
    , p12_a3 out nocopy  NUMBER
    , p12_a4 out nocopy  NUMBER
    , p12_a5 out nocopy  NUMBER
    , p12_a6 out nocopy  NUMBER
    , p12_a7 out nocopy  VARCHAR2
    , p12_a8 out nocopy  NUMBER
    , p12_a9 out nocopy  VARCHAR2
    , p12_a10 out nocopy  VARCHAR2
    , p12_a11 out nocopy  VARCHAR2
    , p12_a12 out nocopy  VARCHAR2
    , p12_a13 out nocopy  VARCHAR2
    , p12_a14 out nocopy  VARCHAR2
    , p12_a15 out nocopy  VARCHAR2
    , p12_a16 out nocopy  VARCHAR2
    , p12_a17 out nocopy  VARCHAR2
    , p12_a18 out nocopy  VARCHAR2
    , p12_a19 out nocopy  VARCHAR2
    , p12_a20 out nocopy  VARCHAR2
    , p12_a21 out nocopy  VARCHAR2
    , p12_a22 out nocopy  VARCHAR2
    , p12_a23 out nocopy  VARCHAR2
    , p12_a24 out nocopy  VARCHAR2
    , p12_a25 out nocopy  DATE
    , p12_a26 out nocopy  DATE
    , p12_a27 out nocopy  NUMBER
    , p12_a28 out nocopy  DATE
    , p12_a29 out nocopy  DATE
    , p12_a30 out nocopy  VARCHAR2
    , p12_a31 out nocopy  VARCHAR2
    , p12_a32 out nocopy  VARCHAR2
    , p12_a33 out nocopy  VARCHAR2
    , p12_a34 out nocopy  VARCHAR2
    , p12_a35 out nocopy  VARCHAR2
    , p12_a36 out nocopy  NUMBER
    , p12_a37 out nocopy  NUMBER
    , p12_a38 out nocopy  DATE
    , p12_a39 out nocopy  DATE
    , p12_a40 out nocopy  DATE
    , p12_a41 out nocopy  DATE
    , p12_a42 out nocopy  DATE
    , p12_a43 out nocopy  VARCHAR2
    , p12_a44 out nocopy  DATE
    , p12_a45 out nocopy  DATE
    , p12_a46 out nocopy  NUMBER
    , p12_a47 out nocopy  VARCHAR2
    , p12_a48 out nocopy  VARCHAR2
    , p12_a49 out nocopy  NUMBER
    , p12_a50 out nocopy  NUMBER
    , p12_a51 out nocopy  NUMBER
    , p12_a52 out nocopy  VARCHAR2
    , p12_a53 out nocopy  VARCHAR2
    , p12_a54 out nocopy  NUMBER
    , p12_a55 out nocopy  NUMBER
    , p12_a56 out nocopy  VARCHAR2
    , p12_a57 out nocopy  NUMBER
    , p12_a58 out nocopy  VARCHAR2
    , p12_a59 out nocopy  NUMBER
    , p12_a60 out nocopy  NUMBER
    , p12_a61 out nocopy  NUMBER
    , p12_a62 out nocopy  DATE
    , p12_a63 out nocopy  DATE
    , p12_a64 out nocopy  DATE
    , p12_a65 out nocopy  NUMBER
    , p12_a66 out nocopy  NUMBER
    , p12_a67 out nocopy  NUMBER
    , p12_a68 out nocopy  VARCHAR2
    , p12_a69 out nocopy  VARCHAR2
    , p12_a70 out nocopy  VARCHAR2
    , p12_a71 out nocopy  VARCHAR2
    , p12_a72 out nocopy  VARCHAR2
    , p12_a73 out nocopy  VARCHAR2
    , p12_a74 out nocopy  VARCHAR2
    , p12_a75 out nocopy  VARCHAR2
    , p12_a76 out nocopy  VARCHAR2
    , p12_a77 out nocopy  VARCHAR2
    , p12_a78 out nocopy  VARCHAR2
    , p12_a79 out nocopy  VARCHAR2
    , p12_a80 out nocopy  VARCHAR2
    , p12_a81 out nocopy  VARCHAR2
    , p12_a82 out nocopy  VARCHAR2
    , p12_a83 out nocopy  VARCHAR2
    , p12_a84 out nocopy  NUMBER
    , p12_a85 out nocopy  DATE
    , p12_a86 out nocopy  NUMBER
    , p12_a87 out nocopy  DATE
    , p12_a88 out nocopy  NUMBER
    , p12_a89 out nocopy  VARCHAR2
    , p12_a90 out nocopy  VARCHAR2
    , p12_a91 out nocopy  VARCHAR2
    , p12_a92 out nocopy  VARCHAR2
    , p12_a93 out nocopy  VARCHAR2
    , p12_a94 out nocopy  NUMBER
    , p12_a95 out nocopy  DATE
    , p12_a96 out nocopy  NUMBER
    , p12_a97 out nocopy  NUMBER
    , p12_a98 out nocopy  NUMBER
    , p12_a99 out nocopy  NUMBER
    , p12_a100 out nocopy  VARCHAR2
    , p12_a101 out nocopy  NUMBER
    , p12_a102 out nocopy  DATE
    , p12_a103 out nocopy  NUMBER
    , p12_a104 out nocopy  NUMBER
    , p13_a0 out nocopy  NUMBER
    , p13_a1 out nocopy  NUMBER
    , p13_a2 out nocopy  NUMBER
    , p13_a3 out nocopy  NUMBER
    , p13_a4 out nocopy  NUMBER
    , p13_a5 out nocopy  VARCHAR2
    , p13_a6 out nocopy  DATE
    , p13_a7 out nocopy  VARCHAR2
    , p13_a8 out nocopy  VARCHAR2
    , p13_a9 out nocopy  DATE
    , p13_a10 out nocopy  VARCHAR2
    , p13_a11 out nocopy  NUMBER
    , p13_a12 out nocopy  VARCHAR2
    , p13_a13 out nocopy  DATE
    , p13_a14 out nocopy  VARCHAR2
    , p13_a15 out nocopy  VARCHAR2
    , p13_a16 out nocopy  DATE
    , p13_a17 out nocopy  DATE
    , p13_a18 out nocopy  DATE
    , p13_a19 out nocopy  DATE
    , p13_a20 out nocopy  VARCHAR2
    , p13_a21 out nocopy  VARCHAR2
    , p13_a22 out nocopy  VARCHAR2
    , p13_a23 out nocopy  VARCHAR2
    , p13_a24 out nocopy  VARCHAR2
    , p13_a25 out nocopy  VARCHAR2
    , p13_a26 out nocopy  VARCHAR2
    , p13_a27 out nocopy  VARCHAR2
    , p13_a28 out nocopy  VARCHAR2
    , p13_a29 out nocopy  VARCHAR2
    , p13_a30 out nocopy  VARCHAR2
    , p13_a31 out nocopy  VARCHAR2
    , p13_a32 out nocopy  VARCHAR2
    , p13_a33 out nocopy  VARCHAR2
    , p13_a34 out nocopy  VARCHAR2
    , p13_a35 out nocopy  VARCHAR2
    , p13_a36 out nocopy  NUMBER
    , p13_a37 out nocopy  DATE
    , p13_a38 out nocopy  NUMBER
    , p13_a39 out nocopy  DATE
    , p13_a40 out nocopy  NUMBER
    , p13_a41 out nocopy  NUMBER
    , p13_a42 out nocopy  NUMBER
    , p13_a43 out nocopy  NUMBER
    , p13_a44 out nocopy  NUMBER
    , p13_a45 out nocopy  NUMBER
    , p13_a46 out nocopy  NUMBER
    , p13_a47 out nocopy  NUMBER
    , p13_a48 out nocopy  NUMBER
    , p13_a49 out nocopy  DATE
    , p13_a50 out nocopy  VARCHAR2
    , p13_a51 out nocopy  NUMBER
    , p13_a52 out nocopy  NUMBER
    , p13_a53 out nocopy  DATE
    , p13_a54 out nocopy  DATE
    , p13_a55 out nocopy  VARCHAR2
    , p13_a56 out nocopy  VARCHAR2
    , p13_a57 out nocopy  VARCHAR2
    , p13_a58 out nocopy  NUMBER
    , p13_a59 out nocopy  DATE
    , p13_a60 out nocopy  VARCHAR2
    , p13_a61 out nocopy  VARCHAR2
    , p13_a62 out nocopy  VARCHAR2
    , p13_a63 out nocopy  VARCHAR2
    , p13_a64 out nocopy  VARCHAR2
    , p13_a65 out nocopy  VARCHAR2
    , p10_a0  NUMBER := 0-1962.0724
    , p10_a1  NUMBER := 0-1962.0724
    , p10_a2  VARCHAR2 := fnd_api.g_miss_char
    , p10_a3  NUMBER := 0-1962.0724
    , p10_a4  NUMBER := 0-1962.0724
    , p10_a5  NUMBER := 0-1962.0724
    , p10_a6  NUMBER := 0-1962.0724
    , p10_a7  VARCHAR2 := fnd_api.g_miss_char
    , p10_a8  NUMBER := 0-1962.0724
    , p10_a9  VARCHAR2 := fnd_api.g_miss_char
    , p10_a10  VARCHAR2 := fnd_api.g_miss_char
    , p10_a11  VARCHAR2 := fnd_api.g_miss_char
    , p10_a12  VARCHAR2 := fnd_api.g_miss_char
    , p10_a13  VARCHAR2 := fnd_api.g_miss_char
    , p10_a14  VARCHAR2 := fnd_api.g_miss_char
    , p10_a15  VARCHAR2 := fnd_api.g_miss_char
    , p10_a16  VARCHAR2 := fnd_api.g_miss_char
    , p10_a17  VARCHAR2 := fnd_api.g_miss_char
    , p10_a18  VARCHAR2 := fnd_api.g_miss_char
    , p10_a19  VARCHAR2 := fnd_api.g_miss_char
    , p10_a20  VARCHAR2 := fnd_api.g_miss_char
    , p10_a21  VARCHAR2 := fnd_api.g_miss_char
    , p10_a22  VARCHAR2 := fnd_api.g_miss_char
    , p10_a23  VARCHAR2 := fnd_api.g_miss_char
    , p10_a24  VARCHAR2 := fnd_api.g_miss_char
    , p10_a25  DATE := fnd_api.g_miss_date
    , p10_a26  DATE := fnd_api.g_miss_date
    , p10_a27  NUMBER := 0-1962.0724
    , p10_a28  DATE := fnd_api.g_miss_date
    , p10_a29  DATE := fnd_api.g_miss_date
    , p10_a30  VARCHAR2 := fnd_api.g_miss_char
    , p10_a31  VARCHAR2 := fnd_api.g_miss_char
    , p10_a32  VARCHAR2 := fnd_api.g_miss_char
    , p10_a33  VARCHAR2 := fnd_api.g_miss_char
    , p10_a34  VARCHAR2 := fnd_api.g_miss_char
    , p10_a35  VARCHAR2 := fnd_api.g_miss_char
    , p10_a36  NUMBER := 0-1962.0724
    , p10_a37  NUMBER := 0-1962.0724
    , p10_a38  DATE := fnd_api.g_miss_date
    , p10_a39  DATE := fnd_api.g_miss_date
    , p10_a40  DATE := fnd_api.g_miss_date
    , p10_a41  DATE := fnd_api.g_miss_date
    , p10_a42  DATE := fnd_api.g_miss_date
    , p10_a43  VARCHAR2 := fnd_api.g_miss_char
    , p10_a44  DATE := fnd_api.g_miss_date
    , p10_a45  DATE := fnd_api.g_miss_date
    , p10_a46  NUMBER := 0-1962.0724
    , p10_a47  VARCHAR2 := fnd_api.g_miss_char
    , p10_a48  VARCHAR2 := fnd_api.g_miss_char
    , p10_a49  NUMBER := 0-1962.0724
    , p10_a50  NUMBER := 0-1962.0724
    , p10_a51  NUMBER := 0-1962.0724
    , p10_a52  VARCHAR2 := fnd_api.g_miss_char
    , p10_a53  VARCHAR2 := fnd_api.g_miss_char
    , p10_a54  NUMBER := 0-1962.0724
    , p10_a55  NUMBER := 0-1962.0724
    , p10_a56  VARCHAR2 := fnd_api.g_miss_char
    , p10_a57  NUMBER := 0-1962.0724
    , p10_a58  VARCHAR2 := fnd_api.g_miss_char
    , p10_a59  NUMBER := 0-1962.0724
    , p10_a60  NUMBER := 0-1962.0724
    , p10_a61  NUMBER := 0-1962.0724
    , p10_a62  DATE := fnd_api.g_miss_date
    , p10_a63  DATE := fnd_api.g_miss_date
    , p10_a64  DATE := fnd_api.g_miss_date
    , p10_a65  NUMBER := 0-1962.0724
    , p10_a66  NUMBER := 0-1962.0724
    , p10_a67  NUMBER := 0-1962.0724
    , p10_a68  VARCHAR2 := fnd_api.g_miss_char
    , p10_a69  VARCHAR2 := fnd_api.g_miss_char
    , p10_a70  VARCHAR2 := fnd_api.g_miss_char
    , p10_a71  VARCHAR2 := fnd_api.g_miss_char
    , p10_a72  VARCHAR2 := fnd_api.g_miss_char
    , p10_a73  VARCHAR2 := fnd_api.g_miss_char
    , p10_a74  VARCHAR2 := fnd_api.g_miss_char
    , p10_a75  VARCHAR2 := fnd_api.g_miss_char
    , p10_a76  VARCHAR2 := fnd_api.g_miss_char
    , p10_a77  VARCHAR2 := fnd_api.g_miss_char
    , p10_a78  VARCHAR2 := fnd_api.g_miss_char
    , p10_a79  VARCHAR2 := fnd_api.g_miss_char
    , p10_a80  VARCHAR2 := fnd_api.g_miss_char
    , p10_a81  VARCHAR2 := fnd_api.g_miss_char
    , p10_a82  VARCHAR2 := fnd_api.g_miss_char
    , p10_a83  VARCHAR2 := fnd_api.g_miss_char
    , p10_a84  NUMBER := 0-1962.0724
    , p10_a85  DATE := fnd_api.g_miss_date
    , p10_a86  NUMBER := 0-1962.0724
    , p10_a87  DATE := fnd_api.g_miss_date
    , p10_a88  NUMBER := 0-1962.0724
    , p10_a89  VARCHAR2 := fnd_api.g_miss_char
    , p10_a90  VARCHAR2 := fnd_api.g_miss_char
    , p10_a91  VARCHAR2 := fnd_api.g_miss_char
    , p10_a92  VARCHAR2 := fnd_api.g_miss_char
    , p10_a93  VARCHAR2 := fnd_api.g_miss_char
    , p10_a94  NUMBER := 0-1962.0724
    , p10_a95  DATE := fnd_api.g_miss_date
    , p10_a96  NUMBER := 0-1962.0724
    , p10_a97  NUMBER := 0-1962.0724
    , p10_a98  NUMBER := 0-1962.0724
    , p10_a99  NUMBER := 0-1962.0724
    , p10_a100  VARCHAR2 := fnd_api.g_miss_char
    , p10_a101  NUMBER := 0-1962.0724
    , p10_a102  DATE := fnd_api.g_miss_date
    , p10_a103  NUMBER := 0-1962.0724
    , p10_a104  NUMBER := 0-1962.0724
    , p11_a0  NUMBER := 0-1962.0724
    , p11_a1  NUMBER := 0-1962.0724
    , p11_a2  NUMBER := 0-1962.0724
    , p11_a3  NUMBER := 0-1962.0724
    , p11_a4  NUMBER := 0-1962.0724
    , p11_a5  VARCHAR2 := fnd_api.g_miss_char
    , p11_a6  DATE := fnd_api.g_miss_date
    , p11_a7  VARCHAR2 := fnd_api.g_miss_char
    , p11_a8  VARCHAR2 := fnd_api.g_miss_char
    , p11_a9  DATE := fnd_api.g_miss_date
    , p11_a10  VARCHAR2 := fnd_api.g_miss_char
    , p11_a11  NUMBER := 0-1962.0724
    , p11_a12  VARCHAR2 := fnd_api.g_miss_char
    , p11_a13  DATE := fnd_api.g_miss_date
    , p11_a14  VARCHAR2 := fnd_api.g_miss_char
    , p11_a15  VARCHAR2 := fnd_api.g_miss_char
    , p11_a16  DATE := fnd_api.g_miss_date
    , p11_a17  DATE := fnd_api.g_miss_date
    , p11_a18  DATE := fnd_api.g_miss_date
    , p11_a19  DATE := fnd_api.g_miss_date
    , p11_a20  VARCHAR2 := fnd_api.g_miss_char
    , p11_a21  VARCHAR2 := fnd_api.g_miss_char
    , p11_a22  VARCHAR2 := fnd_api.g_miss_char
    , p11_a23  VARCHAR2 := fnd_api.g_miss_char
    , p11_a24  VARCHAR2 := fnd_api.g_miss_char
    , p11_a25  VARCHAR2 := fnd_api.g_miss_char
    , p11_a26  VARCHAR2 := fnd_api.g_miss_char
    , p11_a27  VARCHAR2 := fnd_api.g_miss_char
    , p11_a28  VARCHAR2 := fnd_api.g_miss_char
    , p11_a29  VARCHAR2 := fnd_api.g_miss_char
    , p11_a30  VARCHAR2 := fnd_api.g_miss_char
    , p11_a31  VARCHAR2 := fnd_api.g_miss_char
    , p11_a32  VARCHAR2 := fnd_api.g_miss_char
    , p11_a33  VARCHAR2 := fnd_api.g_miss_char
    , p11_a34  VARCHAR2 := fnd_api.g_miss_char
    , p11_a35  VARCHAR2 := fnd_api.g_miss_char
    , p11_a36  NUMBER := 0-1962.0724
    , p11_a37  DATE := fnd_api.g_miss_date
    , p11_a38  NUMBER := 0-1962.0724
    , p11_a39  DATE := fnd_api.g_miss_date
    , p11_a40  NUMBER := 0-1962.0724
    , p11_a41  NUMBER := 0-1962.0724
    , p11_a42  NUMBER := 0-1962.0724
    , p11_a43  NUMBER := 0-1962.0724
    , p11_a44  NUMBER := 0-1962.0724
    , p11_a45  NUMBER := 0-1962.0724
    , p11_a46  NUMBER := 0-1962.0724
    , p11_a47  NUMBER := 0-1962.0724
    , p11_a48  NUMBER := 0-1962.0724
    , p11_a49  DATE := fnd_api.g_miss_date
    , p11_a50  VARCHAR2 := fnd_api.g_miss_char
    , p11_a51  NUMBER := 0-1962.0724
    , p11_a52  NUMBER := 0-1962.0724
    , p11_a53  DATE := fnd_api.g_miss_date
    , p11_a54  DATE := fnd_api.g_miss_date
    , p11_a55  VARCHAR2 := fnd_api.g_miss_char
    , p11_a56  VARCHAR2 := fnd_api.g_miss_char
    , p11_a57  VARCHAR2 := fnd_api.g_miss_char
    , p11_a58  NUMBER := 0-1962.0724
    , p11_a59  DATE := fnd_api.g_miss_date
    , p11_a60  VARCHAR2 := fnd_api.g_miss_char
    , p11_a61  VARCHAR2 := fnd_api.g_miss_char
    , p11_a62  VARCHAR2 := fnd_api.g_miss_char
    , p11_a63  VARCHAR2 := fnd_api.g_miss_char
    , p11_a64  VARCHAR2 := fnd_api.g_miss_char
    , p11_a65  VARCHAR2 := fnd_api.g_miss_char
  )

  as
    ddp_chrv_rec okl_okc_migration_pvt.chrv_rec_type;
    ddp_khrv_rec okl_credit_pub.khrv_rec_type;
    ddx_chrv_rec okl_okc_migration_pvt.chrv_rec_type;
    ddx_khrv_rec okl_credit_pub.khrv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any










    ddp_chrv_rec.id := rosetta_g_miss_num_map(p10_a0);
    ddp_chrv_rec.object_version_number := rosetta_g_miss_num_map(p10_a1);
    ddp_chrv_rec.sfwt_flag := p10_a2;
    ddp_chrv_rec.chr_id_response := rosetta_g_miss_num_map(p10_a3);
    ddp_chrv_rec.chr_id_award := rosetta_g_miss_num_map(p10_a4);
    ddp_chrv_rec.chr_id_renewed := rosetta_g_miss_num_map(p10_a5);
    ddp_chrv_rec.inv_organization_id := rosetta_g_miss_num_map(p10_a6);
    ddp_chrv_rec.sts_code := p10_a7;
    ddp_chrv_rec.qcl_id := rosetta_g_miss_num_map(p10_a8);
    ddp_chrv_rec.scs_code := p10_a9;
    ddp_chrv_rec.contract_number := p10_a10;
    ddp_chrv_rec.currency_code := p10_a11;
    ddp_chrv_rec.contract_number_modifier := p10_a12;
    ddp_chrv_rec.archived_yn := p10_a13;
    ddp_chrv_rec.deleted_yn := p10_a14;
    ddp_chrv_rec.cust_po_number_req_yn := p10_a15;
    ddp_chrv_rec.pre_pay_req_yn := p10_a16;
    ddp_chrv_rec.cust_po_number := p10_a17;
    ddp_chrv_rec.short_description := p10_a18;
    ddp_chrv_rec.comments := p10_a19;
    ddp_chrv_rec.description := p10_a20;
    ddp_chrv_rec.dpas_rating := p10_a21;
    ddp_chrv_rec.cognomen := p10_a22;
    ddp_chrv_rec.template_yn := p10_a23;
    ddp_chrv_rec.template_used := p10_a24;
    ddp_chrv_rec.date_approved := rosetta_g_miss_date_in_map(p10_a25);
    ddp_chrv_rec.datetime_cancelled := rosetta_g_miss_date_in_map(p10_a26);
    ddp_chrv_rec.auto_renew_days := rosetta_g_miss_num_map(p10_a27);
    ddp_chrv_rec.date_issued := rosetta_g_miss_date_in_map(p10_a28);
    ddp_chrv_rec.datetime_responded := rosetta_g_miss_date_in_map(p10_a29);
    ddp_chrv_rec.non_response_reason := p10_a30;
    ddp_chrv_rec.non_response_explain := p10_a31;
    ddp_chrv_rec.rfp_type := p10_a32;
    ddp_chrv_rec.chr_type := p10_a33;
    ddp_chrv_rec.keep_on_mail_list := p10_a34;
    ddp_chrv_rec.set_aside_reason := p10_a35;
    ddp_chrv_rec.set_aside_percent := rosetta_g_miss_num_map(p10_a36);
    ddp_chrv_rec.response_copies_req := rosetta_g_miss_num_map(p10_a37);
    ddp_chrv_rec.date_close_projected := rosetta_g_miss_date_in_map(p10_a38);
    ddp_chrv_rec.datetime_proposed := rosetta_g_miss_date_in_map(p10_a39);
    ddp_chrv_rec.date_signed := rosetta_g_miss_date_in_map(p10_a40);
    ddp_chrv_rec.date_terminated := rosetta_g_miss_date_in_map(p10_a41);
    ddp_chrv_rec.date_renewed := rosetta_g_miss_date_in_map(p10_a42);
    ddp_chrv_rec.trn_code := p10_a43;
    ddp_chrv_rec.start_date := rosetta_g_miss_date_in_map(p10_a44);
    ddp_chrv_rec.end_date := rosetta_g_miss_date_in_map(p10_a45);
    ddp_chrv_rec.authoring_org_id := rosetta_g_miss_num_map(p10_a46);
    ddp_chrv_rec.buy_or_sell := p10_a47;
    ddp_chrv_rec.issue_or_receive := p10_a48;
    ddp_chrv_rec.estimated_amount := rosetta_g_miss_num_map(p10_a49);
    ddp_chrv_rec.chr_id_renewed_to := rosetta_g_miss_num_map(p10_a50);
    ddp_chrv_rec.estimated_amount_renewed := rosetta_g_miss_num_map(p10_a51);
    ddp_chrv_rec.currency_code_renewed := p10_a52;
    ddp_chrv_rec.upg_orig_system_ref := p10_a53;
    ddp_chrv_rec.upg_orig_system_ref_id := rosetta_g_miss_num_map(p10_a54);
    ddp_chrv_rec.application_id := rosetta_g_miss_num_map(p10_a55);
    ddp_chrv_rec.orig_system_source_code := p10_a56;
    ddp_chrv_rec.orig_system_id1 := rosetta_g_miss_num_map(p10_a57);
    ddp_chrv_rec.orig_system_reference1 := p10_a58;
    ddp_chrv_rec.program_id := rosetta_g_miss_num_map(p10_a59);
    ddp_chrv_rec.request_id := rosetta_g_miss_num_map(p10_a60);
    ddp_chrv_rec.price_list_id := rosetta_g_miss_num_map(p10_a61);
    ddp_chrv_rec.pricing_date := rosetta_g_miss_date_in_map(p10_a62);
    ddp_chrv_rec.sign_by_date := rosetta_g_miss_date_in_map(p10_a63);
    ddp_chrv_rec.program_update_date := rosetta_g_miss_date_in_map(p10_a64);
    ddp_chrv_rec.total_line_list_price := rosetta_g_miss_num_map(p10_a65);
    ddp_chrv_rec.program_application_id := rosetta_g_miss_num_map(p10_a66);
    ddp_chrv_rec.user_estimated_amount := rosetta_g_miss_num_map(p10_a67);
    ddp_chrv_rec.attribute_category := p10_a68;
    ddp_chrv_rec.attribute1 := p10_a69;
    ddp_chrv_rec.attribute2 := p10_a70;
    ddp_chrv_rec.attribute3 := p10_a71;
    ddp_chrv_rec.attribute4 := p10_a72;
    ddp_chrv_rec.attribute5 := p10_a73;
    ddp_chrv_rec.attribute6 := p10_a74;
    ddp_chrv_rec.attribute7 := p10_a75;
    ddp_chrv_rec.attribute8 := p10_a76;
    ddp_chrv_rec.attribute9 := p10_a77;
    ddp_chrv_rec.attribute10 := p10_a78;

    ddp_chrv_rec.attribute11 := p10_a79;
    ddp_chrv_rec.attribute12 := p10_a80;
    ddp_chrv_rec.attribute13 := p10_a81;
    ddp_chrv_rec.attribute14 := p10_a82;
    ddp_chrv_rec.attribute15 := p10_a83;
    ddp_chrv_rec.created_by := rosetta_g_miss_num_map(p10_a84);
    ddp_chrv_rec.creation_date := rosetta_g_miss_date_in_map(p10_a85);
    ddp_chrv_rec.last_updated_by := rosetta_g_miss_num_map(p10_a86);
    ddp_chrv_rec.last_update_date := rosetta_g_miss_date_in_map(p10_a87);
    ddp_chrv_rec.last_update_login := rosetta_g_miss_num_map(p10_a88);
    ddp_chrv_rec.old_sts_code := p10_a89;
    ddp_chrv_rec.new_sts_code := p10_a90;
    ddp_chrv_rec.old_ste_code := p10_a91;
    ddp_chrv_rec.new_ste_code := p10_a92;
    ddp_chrv_rec.conversion_type := p10_a93;
    ddp_chrv_rec.conversion_rate := rosetta_g_miss_num_map(p10_a94);
    ddp_chrv_rec.conversion_rate_date := rosetta_g_miss_date_in_map(p10_a95);
    ddp_chrv_rec.conversion_euro_rate := rosetta_g_miss_num_map(p10_a96);
    ddp_chrv_rec.cust_acct_id := rosetta_g_miss_num_map(p10_a97);
    ddp_chrv_rec.bill_to_site_use_id := rosetta_g_miss_num_map(p10_a98);
    ddp_chrv_rec.inv_rule_id := rosetta_g_miss_num_map(p10_a99);
    ddp_chrv_rec.renewal_type_code := p10_a100;
    ddp_chrv_rec.renewal_notify_to := rosetta_g_miss_num_map(p10_a101);
    ddp_chrv_rec.renewal_end_date := rosetta_g_miss_date_in_map(p10_a102);
    ddp_chrv_rec.ship_to_site_use_id := rosetta_g_miss_num_map(p10_a103);
    ddp_chrv_rec.payment_term_id := rosetta_g_miss_num_map(p10_a104);

    ddp_khrv_rec.id := rosetta_g_miss_num_map(p11_a0);
    ddp_khrv_rec.object_version_number := rosetta_g_miss_num_map(p11_a1);
    ddp_khrv_rec.isg_id := rosetta_g_miss_num_map(p11_a2);
    ddp_khrv_rec.khr_id := rosetta_g_miss_num_map(p11_a3);
    ddp_khrv_rec.pdt_id := rosetta_g_miss_num_map(p11_a4);
    ddp_khrv_rec.amd_code := p11_a5;
    ddp_khrv_rec.date_first_activity := rosetta_g_miss_date_in_map(p11_a6);
    ddp_khrv_rec.generate_accrual_yn := p11_a7;
    ddp_khrv_rec.generate_accrual_override_yn := p11_a8;
    ddp_khrv_rec.date_refinanced := rosetta_g_miss_date_in_map(p11_a9);
    ddp_khrv_rec.credit_act_yn := p11_a10;
    ddp_khrv_rec.term_duration := rosetta_g_miss_num_map(p11_a11);
    ddp_khrv_rec.converted_account_yn := p11_a12;
    ddp_khrv_rec.date_conversion_effective := rosetta_g_miss_date_in_map(p11_a13);
    ddp_khrv_rec.syndicatable_yn := p11_a14;
    ddp_khrv_rec.salestype_yn := p11_a15;
    ddp_khrv_rec.date_deal_transferred := rosetta_g_miss_date_in_map(p11_a16);
    ddp_khrv_rec.datetime_proposal_effective := rosetta_g_miss_date_in_map(p11_a17);
    ddp_khrv_rec.datetime_proposal_ineffective := rosetta_g_miss_date_in_map(p11_a18);
    ddp_khrv_rec.date_proposal_accepted := rosetta_g_miss_date_in_map(p11_a19);
    ddp_khrv_rec.attribute_category := p11_a20;
    ddp_khrv_rec.attribute1 := p11_a21;
    ddp_khrv_rec.attribute2 := p11_a22;
    ddp_khrv_rec.attribute3 := p11_a23;
    ddp_khrv_rec.attribute4 := p11_a24;
    ddp_khrv_rec.attribute5 := p11_a25;
    ddp_khrv_rec.attribute6 := p11_a26;
    ddp_khrv_rec.attribute7 := p11_a27;
    ddp_khrv_rec.attribute8 := p11_a28;
    ddp_khrv_rec.attribute9 := p11_a29;
    ddp_khrv_rec.attribute10 := p11_a30;
    ddp_khrv_rec.attribute11 := p11_a31;
    ddp_khrv_rec.attribute12 := p11_a32;
    ddp_khrv_rec.attribute13 := p11_a33;
    ddp_khrv_rec.attribute14 := p11_a34;
    ddp_khrv_rec.attribute15 := p11_a35;
    ddp_khrv_rec.created_by := rosetta_g_miss_num_map(p11_a36);
    ddp_khrv_rec.creation_date := rosetta_g_miss_date_in_map(p11_a37);
    ddp_khrv_rec.last_updated_by := rosetta_g_miss_num_map(p11_a38);
    ddp_khrv_rec.last_update_date := rosetta_g_miss_date_in_map(p11_a39);
    ddp_khrv_rec.last_update_login := rosetta_g_miss_num_map(p11_a40);
    ddp_khrv_rec.pre_tax_yield := rosetta_g_miss_num_map(p11_a41);
    ddp_khrv_rec.after_tax_yield := rosetta_g_miss_num_map(p11_a42);
    ddp_khrv_rec.implicit_interest_rate := rosetta_g_miss_num_map(p11_a43);
    ddp_khrv_rec.implicit_non_idc_interest_rate := rosetta_g_miss_num_map(p11_a44);
    ddp_khrv_rec.target_pre_tax_yield := rosetta_g_miss_num_map(p11_a45);
    ddp_khrv_rec.target_after_tax_yield := rosetta_g_miss_num_map(p11_a46);
    ddp_khrv_rec.target_implicit_interest_rate := rosetta_g_miss_num_map(p11_a47);
    ddp_khrv_rec.target_implicit_nonidc_intrate := rosetta_g_miss_num_map(p11_a48);
    ddp_khrv_rec.date_last_interim_interest_cal := rosetta_g_miss_date_in_map(p11_a49);
    ddp_khrv_rec.deal_type := p11_a50;
    ddp_khrv_rec.pre_tax_irr := rosetta_g_miss_num_map(p11_a51);
    ddp_khrv_rec.after_tax_irr := rosetta_g_miss_num_map(p11_a52);
    ddp_khrv_rec.expected_delivery_date := rosetta_g_miss_date_in_map(p11_a53);
    ddp_khrv_rec.accepted_date := rosetta_g_miss_date_in_map(p11_a54);
    ddp_khrv_rec.prefunding_eligible_yn := p11_a55;
    ddp_khrv_rec.revolving_credit_yn := p11_a56;
    ddp_khrv_rec.currency_conversion_type := p11_a57;
    ddp_khrv_rec.currency_conversion_rate := rosetta_g_miss_num_map(p11_a58);
    ddp_khrv_rec.currency_conversion_date := rosetta_g_miss_date_in_map(p11_a59);
    ddp_khrv_rec.multi_gaap_yn := p11_a60;
    ddp_khrv_rec.recourse_code := p11_a61;
    ddp_khrv_rec.lessor_serv_org_code := p11_a62;
    ddp_khrv_rec.assignable_yn := p11_a63;
    ddp_khrv_rec.securitized_code := p11_a64;
    ddp_khrv_rec.securitization_type := p11_a65;



    -- here's the delegated call to the old PL/SQL routine
    okl_credit_pub.update_credit_header(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_restricted_update,
      p_chklst_tpl_rgp_id,
      p_chklst_tpl_rule_id,
      p_credit_ckl_id,
      p_funding_ckl_id,
      ddp_chrv_rec,
      ddp_khrv_rec,
      ddx_chrv_rec,
      ddx_khrv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any












    p12_a0 := rosetta_g_miss_num_map(ddx_chrv_rec.id);
    p12_a1 := rosetta_g_miss_num_map(ddx_chrv_rec.object_version_number);
    p12_a2 := ddx_chrv_rec.sfwt_flag;
    p12_a3 := rosetta_g_miss_num_map(ddx_chrv_rec.chr_id_response);
    p12_a4 := rosetta_g_miss_num_map(ddx_chrv_rec.chr_id_award);
    p12_a5 := rosetta_g_miss_num_map(ddx_chrv_rec.chr_id_renewed);
    p12_a6 := rosetta_g_miss_num_map(ddx_chrv_rec.inv_organization_id);
    p12_a7 := ddx_chrv_rec.sts_code;
    p12_a8 := rosetta_g_miss_num_map(ddx_chrv_rec.qcl_id);
    p12_a9 := ddx_chrv_rec.scs_code;
    p12_a10 := ddx_chrv_rec.contract_number;
    p12_a11 := ddx_chrv_rec.currency_code;
    p12_a12 := ddx_chrv_rec.contract_number_modifier;
    p12_a13 := ddx_chrv_rec.archived_yn;
    p12_a14 := ddx_chrv_rec.deleted_yn;
    p12_a15 := ddx_chrv_rec.cust_po_number_req_yn;
    p12_a16 := ddx_chrv_rec.pre_pay_req_yn;
    p12_a17 := ddx_chrv_rec.cust_po_number;
    p12_a18 := ddx_chrv_rec.short_description;
    p12_a19 := ddx_chrv_rec.comments;
    p12_a20 := ddx_chrv_rec.description;
    p12_a21 := ddx_chrv_rec.dpas_rating;
    p12_a22 := ddx_chrv_rec.cognomen;
    p12_a23 := ddx_chrv_rec.template_yn;
    p12_a24 := ddx_chrv_rec.template_used;
    p12_a25 := ddx_chrv_rec.date_approved;
    p12_a26 := ddx_chrv_rec.datetime_cancelled;
    p12_a27 := rosetta_g_miss_num_map(ddx_chrv_rec.auto_renew_days);
    p12_a28 := ddx_chrv_rec.date_issued;
    p12_a29 := ddx_chrv_rec.datetime_responded;
    p12_a30 := ddx_chrv_rec.non_response_reason;
    p12_a31 := ddx_chrv_rec.non_response_explain;
    p12_a32 := ddx_chrv_rec.rfp_type;
    p12_a33 := ddx_chrv_rec.chr_type;
    p12_a34 := ddx_chrv_rec.keep_on_mail_list;
    p12_a35 := ddx_chrv_rec.set_aside_reason;
    p12_a36 := rosetta_g_miss_num_map(ddx_chrv_rec.set_aside_percent);
    p12_a37 := rosetta_g_miss_num_map(ddx_chrv_rec.response_copies_req);
    p12_a38 := ddx_chrv_rec.date_close_projected;
    p12_a39 := ddx_chrv_rec.datetime_proposed;
    p12_a40 := ddx_chrv_rec.date_signed;
    p12_a41 := ddx_chrv_rec.date_terminated;
    p12_a42 := ddx_chrv_rec.date_renewed;
    p12_a43 := ddx_chrv_rec.trn_code;
    p12_a44 := ddx_chrv_rec.start_date;
    p12_a45 := ddx_chrv_rec.end_date;
    p12_a46 := rosetta_g_miss_num_map(ddx_chrv_rec.authoring_org_id);
    p12_a47 := ddx_chrv_rec.buy_or_sell;
    p12_a48 := ddx_chrv_rec.issue_or_receive;
    p12_a49 := rosetta_g_miss_num_map(ddx_chrv_rec.estimated_amount);
    p12_a50 := rosetta_g_miss_num_map(ddx_chrv_rec.chr_id_renewed_to);
    p12_a51 := rosetta_g_miss_num_map(ddx_chrv_rec.estimated_amount_renewed);
    p12_a52 := ddx_chrv_rec.currency_code_renewed;
    p12_a53 := ddx_chrv_rec.upg_orig_system_ref;
    p12_a54 := rosetta_g_miss_num_map(ddx_chrv_rec.upg_orig_system_ref_id);
    p12_a55 := rosetta_g_miss_num_map(ddx_chrv_rec.application_id);
    p12_a56 := ddx_chrv_rec.orig_system_source_code;
    p12_a57 := rosetta_g_miss_num_map(ddx_chrv_rec.orig_system_id1);
    p12_a58 := ddx_chrv_rec.orig_system_reference1;
    p12_a59 := rosetta_g_miss_num_map(ddx_chrv_rec.program_id);
    p12_a60 := rosetta_g_miss_num_map(ddx_chrv_rec.request_id);
    p12_a61 := rosetta_g_miss_num_map(ddx_chrv_rec.price_list_id);
    p12_a62 := ddx_chrv_rec.pricing_date;
    p12_a63 := ddx_chrv_rec.sign_by_date;
    p12_a64 := ddx_chrv_rec.program_update_date;
    p12_a65 := rosetta_g_miss_num_map(ddx_chrv_rec.total_line_list_price);
    p12_a66 := rosetta_g_miss_num_map(ddx_chrv_rec.program_application_id);
    p12_a67 := rosetta_g_miss_num_map(ddx_chrv_rec.user_estimated_amount);
    p12_a68 := ddx_chrv_rec.attribute_category;
    p12_a69 := ddx_chrv_rec.attribute1;
    p12_a70 := ddx_chrv_rec.attribute2;
    p12_a71 := ddx_chrv_rec.attribute3;
    p12_a72 := ddx_chrv_rec.attribute4;
    p12_a73 := ddx_chrv_rec.attribute5;
    p12_a74 := ddx_chrv_rec.attribute6;
    p12_a75 := ddx_chrv_rec.attribute7;
    p12_a76 := ddx_chrv_rec.attribute8;
    p12_a77 := ddx_chrv_rec.attribute9;
    p12_a78 := ddx_chrv_rec.attribute10;
    p12_a79 := ddx_chrv_rec.attribute11;
    p12_a80 := ddx_chrv_rec.attribute12;
    p12_a81 := ddx_chrv_rec.attribute13;
    p12_a82 := ddx_chrv_rec.attribute14;
    p12_a83 := ddx_chrv_rec.attribute15;
    p12_a84 := rosetta_g_miss_num_map(ddx_chrv_rec.created_by);
    p12_a85 := ddx_chrv_rec.creation_date;
    p12_a86 := rosetta_g_miss_num_map(ddx_chrv_rec.last_updated_by);
    p12_a87 := ddx_chrv_rec.last_update_date;
    p12_a88 := rosetta_g_miss_num_map(ddx_chrv_rec.last_update_login);
    p12_a89 := ddx_chrv_rec.old_sts_code;
    p12_a90 := ddx_chrv_rec.new_sts_code;
    p12_a91 := ddx_chrv_rec.old_ste_code;
    p12_a92 := ddx_chrv_rec.new_ste_code;
    p12_a93 := ddx_chrv_rec.conversion_type;
    p12_a94 := rosetta_g_miss_num_map(ddx_chrv_rec.conversion_rate);
    p12_a95 := ddx_chrv_rec.conversion_rate_date;
    p12_a96 := rosetta_g_miss_num_map(ddx_chrv_rec.conversion_euro_rate);
    p12_a97 := rosetta_g_miss_num_map(ddx_chrv_rec.cust_acct_id);
    p12_a98 := rosetta_g_miss_num_map(ddx_chrv_rec.bill_to_site_use_id);
    p12_a99 := rosetta_g_miss_num_map(ddx_chrv_rec.inv_rule_id);
    p12_a100 := ddx_chrv_rec.renewal_type_code;
    p12_a101 := rosetta_g_miss_num_map(ddx_chrv_rec.renewal_notify_to);
    p12_a102 := ddx_chrv_rec.renewal_end_date;
    p12_a103 := rosetta_g_miss_num_map(ddx_chrv_rec.ship_to_site_use_id);
    p12_a104 := rosetta_g_miss_num_map(ddx_chrv_rec.payment_term_id);

    p13_a0 := rosetta_g_miss_num_map(ddx_khrv_rec.id);
    p13_a1 := rosetta_g_miss_num_map(ddx_khrv_rec.object_version_number);
    p13_a2 := rosetta_g_miss_num_map(ddx_khrv_rec.isg_id);
    p13_a3 := rosetta_g_miss_num_map(ddx_khrv_rec.khr_id);
    p13_a4 := rosetta_g_miss_num_map(ddx_khrv_rec.pdt_id);
    p13_a5 := ddx_khrv_rec.amd_code;
    p13_a6 := ddx_khrv_rec.date_first_activity;
    p13_a7 := ddx_khrv_rec.generate_accrual_yn;
    p13_a8 := ddx_khrv_rec.generate_accrual_override_yn;
    p13_a9 := ddx_khrv_rec.date_refinanced;
    p13_a10 := ddx_khrv_rec.credit_act_yn;
    p13_a11 := rosetta_g_miss_num_map(ddx_khrv_rec.term_duration);
    p13_a12 := ddx_khrv_rec.converted_account_yn;

    p13_a13 := ddx_khrv_rec.date_conversion_effective;
    p13_a14 := ddx_khrv_rec.syndicatable_yn;
    p13_a15 := ddx_khrv_rec.salestype_yn;
    p13_a16 := ddx_khrv_rec.date_deal_transferred;
    p13_a17 := ddx_khrv_rec.datetime_proposal_effective;
    p13_a18 := ddx_khrv_rec.datetime_proposal_ineffective;
    p13_a19 := ddx_khrv_rec.date_proposal_accepted;
    p13_a20 := ddx_khrv_rec.attribute_category;
    p13_a21 := ddx_khrv_rec.attribute1;
    p13_a22 := ddx_khrv_rec.attribute2;
    p13_a23 := ddx_khrv_rec.attribute3;
    p13_a24 := ddx_khrv_rec.attribute4;
    p13_a25 := ddx_khrv_rec.attribute5;
    p13_a26 := ddx_khrv_rec.attribute6;
    p13_a27 := ddx_khrv_rec.attribute7;
    p13_a28 := ddx_khrv_rec.attribute8;
    p13_a29 := ddx_khrv_rec.attribute9;
    p13_a30 := ddx_khrv_rec.attribute10;
    p13_a31 := ddx_khrv_rec.attribute11;
    p13_a32 := ddx_khrv_rec.attribute12;
    p13_a33 := ddx_khrv_rec.attribute13;
    p13_a34 := ddx_khrv_rec.attribute14;
    p13_a35 := ddx_khrv_rec.attribute15;
    p13_a36 := rosetta_g_miss_num_map(ddx_khrv_rec.created_by);
    p13_a37 := ddx_khrv_rec.creation_date;
    p13_a38 := rosetta_g_miss_num_map(ddx_khrv_rec.last_updated_by);
    p13_a39 := ddx_khrv_rec.last_update_date;
    p13_a40 := rosetta_g_miss_num_map(ddx_khrv_rec.last_update_login);
    p13_a41 := rosetta_g_miss_num_map(ddx_khrv_rec.pre_tax_yield);
    p13_a42 := rosetta_g_miss_num_map(ddx_khrv_rec.after_tax_yield);
    p13_a43 := rosetta_g_miss_num_map(ddx_khrv_rec.implicit_interest_rate);
    p13_a44 := rosetta_g_miss_num_map(ddx_khrv_rec.implicit_non_idc_interest_rate);
    p13_a45 := rosetta_g_miss_num_map(ddx_khrv_rec.target_pre_tax_yield);
    p13_a46 := rosetta_g_miss_num_map(ddx_khrv_rec.target_after_tax_yield);
    p13_a47 := rosetta_g_miss_num_map(ddx_khrv_rec.target_implicit_interest_rate);
    p13_a48 := rosetta_g_miss_num_map(ddx_khrv_rec.target_implicit_nonidc_intrate);
    p13_a49 := ddx_khrv_rec.date_last_interim_interest_cal;
    p13_a50 := ddx_khrv_rec.deal_type;
    p13_a51 := rosetta_g_miss_num_map(ddx_khrv_rec.pre_tax_irr);
    p13_a52 := rosetta_g_miss_num_map(ddx_khrv_rec.after_tax_irr);
    p13_a53 := ddx_khrv_rec.expected_delivery_date;
    p13_a54 := ddx_khrv_rec.accepted_date;
    p13_a55 := ddx_khrv_rec.prefunding_eligible_yn;
    p13_a56 := ddx_khrv_rec.revolving_credit_yn;
    p13_a57 := ddx_khrv_rec.currency_conversion_type;
    p13_a58 := rosetta_g_miss_num_map(ddx_khrv_rec.currency_conversion_rate);
    p13_a59 := ddx_khrv_rec.currency_conversion_date;
    p13_a60 := ddx_khrv_rec.multi_gaap_yn;
    p13_a61 := ddx_khrv_rec.recourse_code;
    p13_a62 := ddx_khrv_rec.lessor_serv_org_code;
    p13_a63 := ddx_khrv_rec.assignable_yn;
    p13_a64 := ddx_khrv_rec.securitized_code;
    p13_a65 := ddx_khrv_rec.securitization_type;
  end;

  procedure validate_credit(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_chr_id  NUMBER
    , p_contract_number  VARCHAR2
    , p_description  VARCHAR2
    , p_customer_id1  VARCHAR2
    , p_customer_id2  VARCHAR2
    , p_customer_code  VARCHAR2
    , p_customer_name  VARCHAR2
    , p_effective_from  date
    , p_effective_to  date
    , p_currency_code  VARCHAR2
    , p_currency_conv_type  VARCHAR2
    , p_currency_conv_rate  NUMBER
    , p_currency_conv_date  date
    , p_credit_ckl_id  NUMBER
    , p_funding_ckl_id  NUMBER
    , p_cust_acct_id  NUMBER
    , p_cust_acct_number  VARCHAR2
    , p_sts_code  VARCHAR2
  )

  as
    ddp_effective_from date;
    ddp_effective_to date;
    ddp_currency_conv_date date;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any












    ddp_effective_from := rosetta_g_miss_date_in_map(p_effective_from);

    ddp_effective_to := rosetta_g_miss_date_in_map(p_effective_to);




    ddp_currency_conv_date := rosetta_g_miss_date_in_map(p_currency_conv_date);






    -- here's the delegated call to the old PL/SQL routine
    okl_credit_pub.validate_credit(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_chr_id,
      p_contract_number,
      p_description,
      p_customer_id1,
      p_customer_id2,
      p_customer_code,
      p_customer_name,
      ddp_effective_from,
      ddp_effective_to,
      p_currency_code,
      p_currency_conv_type,
      p_currency_conv_rate,
      ddp_currency_conv_date,
      p_credit_ckl_id,
      p_funding_ckl_id,
      p_cust_acct_id,
      p_cust_acct_number,
      p_sts_code);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






















  end;

  procedure validate_credit_limit(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_mode  VARCHAR2
    , p_chr_id  NUMBER
    , p_cle_id  NUMBER
    , p_cle_start_date  date
    , p_description  VARCHAR2
    , p_credit_nature  VARCHAR2
    , p_amount  NUMBER
  )

  as
    ddp_cle_start_date date;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any








    ddp_cle_start_date := rosetta_g_miss_date_in_map(p_cle_start_date);




    -- here's the delegated call to the old PL/SQL routine
    okl_credit_pub.validate_credit_limit(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_mode,
      p_chr_id,
      p_cle_id,
      ddp_cle_start_date,
      p_description,
      p_credit_nature,
      p_amount);

    -- copy data back from the local variables to OUT or IN-OUT args, if any











  end;

  procedure validate_credit_limit(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_mode  VARCHAR2
    , p6_a0  NUMBER := 0-1962.0724
    , p6_a1  NUMBER := 0-1962.0724
    , p6_a2  VARCHAR2 := fnd_api.g_miss_char
    , p6_a3  NUMBER := 0-1962.0724
    , p6_a4  NUMBER := 0-1962.0724
    , p6_a5  NUMBER := 0-1962.0724
    , p6_a6  NUMBER := 0-1962.0724
    , p6_a7  NUMBER := 0-1962.0724
    , p6_a8  VARCHAR2 := fnd_api.g_miss_char
    , p6_a9  VARCHAR2 := fnd_api.g_miss_char
    , p6_a10  NUMBER := 0-1962.0724
    , p6_a11  VARCHAR2 := fnd_api.g_miss_char
    , p6_a12  NUMBER := 0-1962.0724
    , p6_a13  VARCHAR2 := fnd_api.g_miss_char
    , p6_a14  VARCHAR2 := fnd_api.g_miss_char
    , p6_a15  VARCHAR2 := fnd_api.g_miss_char
    , p6_a16  VARCHAR2 := fnd_api.g_miss_char
    , p6_a17  VARCHAR2 := fnd_api.g_miss_char
    , p6_a18  NUMBER := 0-1962.0724
    , p6_a19  NUMBER := 0-1962.0724
    , p6_a20  NUMBER := 0-1962.0724
    , p6_a21  NUMBER := 0-1962.0724
    , p6_a22  VARCHAR2 := fnd_api.g_miss_char
    , p6_a23  VARCHAR2 := fnd_api.g_miss_char
    , p6_a24  VARCHAR2 := fnd_api.g_miss_char
    , p6_a25  VARCHAR2 := fnd_api.g_miss_char
    , p6_a26  VARCHAR2 := fnd_api.g_miss_char
    , p6_a27  VARCHAR2 := fnd_api.g_miss_char
    , p6_a28  DATE := fnd_api.g_miss_date
    , p6_a29  VARCHAR2 := fnd_api.g_miss_char
    , p6_a30  DATE := fnd_api.g_miss_date
    , p6_a31  DATE := fnd_api.g_miss_date
    , p6_a32  DATE := fnd_api.g_miss_date
    , p6_a33  VARCHAR2 := fnd_api.g_miss_char
    , p6_a34  NUMBER := 0-1962.0724
    , p6_a35  VARCHAR2 := fnd_api.g_miss_char
    , p6_a36  NUMBER := 0-1962.0724
    , p6_a37  VARCHAR2 := fnd_api.g_miss_char
    , p6_a38  VARCHAR2 := fnd_api.g_miss_char
    , p6_a39  VARCHAR2 := fnd_api.g_miss_char
    , p6_a40  VARCHAR2 := fnd_api.g_miss_char
    , p6_a41  VARCHAR2 := fnd_api.g_miss_char
    , p6_a42  VARCHAR2 := fnd_api.g_miss_char
    , p6_a43  VARCHAR2 := fnd_api.g_miss_char
    , p6_a44  VARCHAR2 := fnd_api.g_miss_char
    , p6_a45  VARCHAR2 := fnd_api.g_miss_char
    , p6_a46  VARCHAR2 := fnd_api.g_miss_char
    , p6_a47  VARCHAR2 := fnd_api.g_miss_char
    , p6_a48  VARCHAR2 := fnd_api.g_miss_char
    , p6_a49  VARCHAR2 := fnd_api.g_miss_char
    , p6_a50  VARCHAR2 := fnd_api.g_miss_char
    , p6_a51  VARCHAR2 := fnd_api.g_miss_char
    , p6_a52  VARCHAR2 := fnd_api.g_miss_char
    , p6_a53  VARCHAR2 := fnd_api.g_miss_char
    , p6_a54  NUMBER := 0-1962.0724
    , p6_a55  DATE := fnd_api.g_miss_date
    , p6_a56  NUMBER := 0-1962.0724
    , p6_a57  DATE := fnd_api.g_miss_date
    , p6_a58  VARCHAR2 := fnd_api.g_miss_char
    , p6_a59  VARCHAR2 := fnd_api.g_miss_char
    , p6_a60  VARCHAR2 := fnd_api.g_miss_char
    , p6_a61  NUMBER := 0-1962.0724
    , p6_a62  VARCHAR2 := fnd_api.g_miss_char
    , p6_a63  VARCHAR2 := fnd_api.g_miss_char
    , p6_a64  VARCHAR2 := fnd_api.g_miss_char
    , p6_a65  VARCHAR2 := fnd_api.g_miss_char
    , p6_a66  VARCHAR2 := fnd_api.g_miss_char
    , p6_a67  NUMBER := 0-1962.0724
    , p6_a68  NUMBER := 0-1962.0724
    , p6_a69  NUMBER := 0-1962.0724
    , p6_a70  DATE := fnd_api.g_miss_date
    , p6_a71  NUMBER := 0-1962.0724
    , p6_a72  DATE := fnd_api.g_miss_date
    , p6_a73  NUMBER := 0-1962.0724
    , p6_a74  NUMBER := 0-1962.0724
    , p6_a75  VARCHAR2 := fnd_api.g_miss_char
    , p6_a76  VARCHAR2 := fnd_api.g_miss_char
    , p6_a77  NUMBER := 0-1962.0724
    , p6_a78  NUMBER := 0-1962.0724
    , p6_a79  VARCHAR2 := fnd_api.g_miss_char
    , p6_a80  VARCHAR2 := fnd_api.g_miss_char
    , p6_a81  NUMBER := 0-1962.0724
    , p6_a82  VARCHAR2 := fnd_api.g_miss_char
    , p6_a83  NUMBER := 0-1962.0724
    , p6_a84  NUMBER := 0-1962.0724
    , p6_a85  NUMBER := 0-1962.0724
    , p6_a86  NUMBER := 0-1962.0724
    , p6_a87  VARCHAR2 := fnd_api.g_miss_char
    , p6_a88  NUMBER := 0-1962.0724
    , p6_a89  NUMBER := 0-1962.0724
    , p7_a0  NUMBER := 0-1962.0724
    , p7_a1  NUMBER := 0-1962.0724
    , p7_a2  NUMBER := 0-1962.0724

    , p7_a3  NUMBER := 0-1962.0724
    , p7_a4  VARCHAR2 := fnd_api.g_miss_char
    , p7_a5  VARCHAR2 := fnd_api.g_miss_char
    , p7_a6  VARCHAR2 := fnd_api.g_miss_char
    , p7_a7  NUMBER := 0-1962.0724
    , p7_a8  NUMBER := 0-1962.0724
    , p7_a9  DATE := fnd_api.g_miss_date
    , p7_a10  NUMBER := 0-1962.0724
    , p7_a11  NUMBER := 0-1962.0724
    , p7_a12  NUMBER := 0-1962.0724
    , p7_a13  NUMBER := 0-1962.0724
    , p7_a14  NUMBER := 0-1962.0724
    , p7_a15  NUMBER := 0-1962.0724
    , p7_a16  NUMBER := 0-1962.0724
    , p7_a17  NUMBER := 0-1962.0724
    , p7_a18  NUMBER := 0-1962.0724
    , p7_a19  NUMBER := 0-1962.0724
    , p7_a20  DATE := fnd_api.g_miss_date
    , p7_a21  DATE := fnd_api.g_miss_date
    , p7_a22  NUMBER := 0-1962.0724
    , p7_a23  NUMBER := 0-1962.0724
    , p7_a24  DATE := fnd_api.g_miss_date
    , p7_a25  DATE := fnd_api.g_miss_date
    , p7_a26  DATE := fnd_api.g_miss_date
    , p7_a27  NUMBER := 0-1962.0724
    , p7_a28  NUMBER := 0-1962.0724
    , p7_a29  NUMBER := 0-1962.0724
    , p7_a30  NUMBER := 0-1962.0724
    , p7_a31  NUMBER := 0-1962.0724
    , p7_a32  NUMBER := 0-1962.0724
    , p7_a33  NUMBER := 0-1962.0724
    , p7_a34  DATE := fnd_api.g_miss_date
    , p7_a35  VARCHAR2 := fnd_api.g_miss_char
    , p7_a36  DATE := fnd_api.g_miss_date
    , p7_a37  VARCHAR2 := fnd_api.g_miss_char
    , p7_a38  NUMBER := 0-1962.0724
    , p7_a39  NUMBER := 0-1962.0724
    , p7_a40  NUMBER := 0-1962.0724
    , p7_a41  VARCHAR2 := fnd_api.g_miss_char
    , p7_a42  DATE := fnd_api.g_miss_date
    , p7_a43  NUMBER := 0-1962.0724
    , p7_a44  NUMBER := 0-1962.0724
    , p7_a45  DATE := fnd_api.g_miss_date
    , p7_a46  NUMBER := 0-1962.0724
    , p7_a47  DATE := fnd_api.g_miss_date
    , p7_a48  DATE := fnd_api.g_miss_date
    , p7_a49  DATE := fnd_api.g_miss_date
    , p7_a50  NUMBER := 0-1962.0724
    , p7_a51  NUMBER := 0-1962.0724
    , p7_a52  VARCHAR2 := fnd_api.g_miss_char
    , p7_a53  NUMBER := 0-1962.0724
    , p7_a54  NUMBER := 0-1962.0724
    , p7_a55  VARCHAR2 := fnd_api.g_miss_char
    , p7_a56  VARCHAR2 := fnd_api.g_miss_char
    , p7_a57  NUMBER := 0-1962.0724
    , p7_a58  DATE := fnd_api.g_miss_date
    , p7_a59  NUMBER := 0-1962.0724
    , p7_a60  VARCHAR2 := fnd_api.g_miss_char
    , p7_a61  VARCHAR2 := fnd_api.g_miss_char
    , p7_a62  VARCHAR2 := fnd_api.g_miss_char
    , p7_a63  VARCHAR2 := fnd_api.g_miss_char
    , p7_a64  VARCHAR2 := fnd_api.g_miss_char
    , p7_a65  VARCHAR2 := fnd_api.g_miss_char
    , p7_a66  VARCHAR2 := fnd_api.g_miss_char
    , p7_a67  VARCHAR2 := fnd_api.g_miss_char
    , p7_a68  VARCHAR2 := fnd_api.g_miss_char
    , p7_a69  VARCHAR2 := fnd_api.g_miss_char
    , p7_a70  VARCHAR2 := fnd_api.g_miss_char
    , p7_a71  VARCHAR2 := fnd_api.g_miss_char
    , p7_a72  VARCHAR2 := fnd_api.g_miss_char
    , p7_a73  VARCHAR2 := fnd_api.g_miss_char
    , p7_a74  VARCHAR2 := fnd_api.g_miss_char
    , p7_a75  VARCHAR2 := fnd_api.g_miss_char
    , p7_a76  NUMBER := 0-1962.0724
    , p7_a77  NUMBER := 0-1962.0724
    , p7_a78  NUMBER := 0-1962.0724
    , p7_a79  DATE := fnd_api.g_miss_date
    , p7_a80  NUMBER := 0-1962.0724
    , p7_a81  DATE := fnd_api.g_miss_date
    , p7_a82  NUMBER := 0-1962.0724
    , p7_a83  DATE := fnd_api.g_miss_date
    , p7_a84  DATE := fnd_api.g_miss_date
    , p7_a85  DATE := fnd_api.g_miss_date
    , p7_a86  DATE := fnd_api.g_miss_date
    , p7_a87  NUMBER := 0-1962.0724
    , p7_a88  NUMBER := 0-1962.0724
    , p7_a89  NUMBER := 0-1962.0724
    , p7_a90  VARCHAR2 := fnd_api.g_miss_char
    , p7_a91  NUMBER := 0-1962.0724
    , p7_a92  VARCHAR2 := fnd_api.g_miss_char
    , p7_a93  NUMBER := 0-1962.0724
    , p7_a94  NUMBER := 0-1962.0724
    , p7_a95  DATE := fnd_api.g_miss_date
    , p7_a96  VARCHAR2 := fnd_api.g_miss_char
    , p7_a97  VARCHAR2 := fnd_api.g_miss_char
    , p7_a98  NUMBER := 0-1962.0724
  )

  as
    ddp_clev_rec okl_okc_migration_pvt.clev_rec_type;
    ddp_klev_rec okl_credit_pub.klev_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any






    ddp_clev_rec.id := rosetta_g_miss_num_map(p6_a0);
    ddp_clev_rec.object_version_number := rosetta_g_miss_num_map(p6_a1);
    ddp_clev_rec.sfwt_flag := p6_a2;
    ddp_clev_rec.chr_id := rosetta_g_miss_num_map(p6_a3);
    ddp_clev_rec.cle_id := rosetta_g_miss_num_map(p6_a4);
    ddp_clev_rec.cle_id_renewed := rosetta_g_miss_num_map(p6_a5);
    ddp_clev_rec.cle_id_renewed_to := rosetta_g_miss_num_map(p6_a6);
    ddp_clev_rec.lse_id := rosetta_g_miss_num_map(p6_a7);
    ddp_clev_rec.line_number := p6_a8;
    ddp_clev_rec.sts_code := p6_a9;
    ddp_clev_rec.display_sequence := rosetta_g_miss_num_map(p6_a10);
    ddp_clev_rec.trn_code := p6_a11;
    ddp_clev_rec.dnz_chr_id := rosetta_g_miss_num_map(p6_a12);
    ddp_clev_rec.comments := p6_a13;
    ddp_clev_rec.item_description := p6_a14;
    ddp_clev_rec.oke_boe_description := p6_a15;
    ddp_clev_rec.cognomen := p6_a16;
    ddp_clev_rec.hidden_ind := p6_a17;
    ddp_clev_rec.price_unit := rosetta_g_miss_num_map(p6_a18);
    ddp_clev_rec.price_unit_percent := rosetta_g_miss_num_map(p6_a19);
    ddp_clev_rec.price_negotiated := rosetta_g_miss_num_map(p6_a20);
    ddp_clev_rec.price_negotiated_renewed := rosetta_g_miss_num_map(p6_a21);
    ddp_clev_rec.price_level_ind := p6_a22;
    ddp_clev_rec.invoice_line_level_ind := p6_a23;
    ddp_clev_rec.dpas_rating := p6_a24;
    ddp_clev_rec.block23text := p6_a25;
    ddp_clev_rec.exception_yn := p6_a26;
    ddp_clev_rec.template_used := p6_a27;
    ddp_clev_rec.date_terminated := rosetta_g_miss_date_in_map(p6_a28);
    ddp_clev_rec.name := p6_a29;
    ddp_clev_rec.start_date := rosetta_g_miss_date_in_map(p6_a30);
    ddp_clev_rec.end_date := rosetta_g_miss_date_in_map(p6_a31);
    ddp_clev_rec.date_renewed := rosetta_g_miss_date_in_map(p6_a32);
    ddp_clev_rec.upg_orig_system_ref := p6_a33;
    ddp_clev_rec.upg_orig_system_ref_id := rosetta_g_miss_num_map(p6_a34);
    ddp_clev_rec.orig_system_source_code := p6_a35;
    ddp_clev_rec.orig_system_id1 := rosetta_g_miss_num_map(p6_a36);
    ddp_clev_rec.orig_system_reference1 := p6_a37;
    ddp_clev_rec.attribute_category := p6_a38;
    ddp_clev_rec.attribute1 := p6_a39;
    ddp_clev_rec.attribute2 := p6_a40;
    ddp_clev_rec.attribute3 := p6_a41;
    ddp_clev_rec.attribute4 := p6_a42;
    ddp_clev_rec.attribute5 := p6_a43;
    ddp_clev_rec.attribute6 := p6_a44;
    ddp_clev_rec.attribute7 := p6_a45;
    ddp_clev_rec.attribute8 := p6_a46;
    ddp_clev_rec.attribute9 := p6_a47;
    ddp_clev_rec.attribute10 := p6_a48;
    ddp_clev_rec.attribute11 := p6_a49;
    ddp_clev_rec.attribute12 := p6_a50;
    ddp_clev_rec.attribute13 := p6_a51;
    ddp_clev_rec.attribute14 := p6_a52;
    ddp_clev_rec.attribute15 := p6_a53;
    ddp_clev_rec.created_by := rosetta_g_miss_num_map(p6_a54);
    ddp_clev_rec.creation_date := rosetta_g_miss_date_in_map(p6_a55);
    ddp_clev_rec.last_updated_by := rosetta_g_miss_num_map(p6_a56);
    ddp_clev_rec.last_update_date := rosetta_g_miss_date_in_map(p6_a57);
    ddp_clev_rec.price_type := p6_a58;
    ddp_clev_rec.currency_code := p6_a59;
    ddp_clev_rec.currency_code_renewed := p6_a60;
    ddp_clev_rec.last_update_login := rosetta_g_miss_num_map(p6_a61);
    ddp_clev_rec.old_sts_code := p6_a62;
    ddp_clev_rec.new_sts_code := p6_a63;
    ddp_clev_rec.old_ste_code := p6_a64;
    ddp_clev_rec.new_ste_code := p6_a65;
    ddp_clev_rec.call_action_asmblr := p6_a66;
    ddp_clev_rec.request_id := rosetta_g_miss_num_map(p6_a67);
    ddp_clev_rec.program_application_id := rosetta_g_miss_num_map(p6_a68);
    ddp_clev_rec.program_id := rosetta_g_miss_num_map(p6_a69);
    ddp_clev_rec.program_update_date := rosetta_g_miss_date_in_map(p6_a70);
    ddp_clev_rec.price_list_id := rosetta_g_miss_num_map(p6_a71);
    ddp_clev_rec.pricing_date := rosetta_g_miss_date_in_map(p6_a72);
    ddp_clev_rec.price_list_line_id := rosetta_g_miss_num_map(p6_a73);
    ddp_clev_rec.line_list_price := rosetta_g_miss_num_map(p6_a74);
    ddp_clev_rec.item_to_price_yn := p6_a75;
    ddp_clev_rec.price_basis_yn := p6_a76;
    ddp_clev_rec.config_header_id := rosetta_g_miss_num_map(p6_a77);
    ddp_clev_rec.config_revision_number := rosetta_g_miss_num_map(p6_a78);
    ddp_clev_rec.config_complete_yn := p6_a79;
    ddp_clev_rec.config_valid_yn := p6_a80;
    ddp_clev_rec.config_top_model_line_id := rosetta_g_miss_num_map(p6_a81);
    ddp_clev_rec.config_item_type := p6_a82;
    ddp_clev_rec.config_item_id := rosetta_g_miss_num_map(p6_a83);
    ddp_clev_rec.cust_acct_id := rosetta_g_miss_num_map(p6_a84);
    ddp_clev_rec.bill_to_site_use_id := rosetta_g_miss_num_map(p6_a85);
    ddp_clev_rec.inv_rule_id := rosetta_g_miss_num_map(p6_a86);
    ddp_clev_rec.line_renewal_type_code := p6_a87;
    ddp_clev_rec.ship_to_site_use_id := rosetta_g_miss_num_map(p6_a88);
    ddp_clev_rec.payment_term_id := rosetta_g_miss_num_map(p6_a89);

    ddp_klev_rec.id := rosetta_g_miss_num_map(p7_a0);
    ddp_klev_rec.object_version_number := rosetta_g_miss_num_map(p7_a1);
    ddp_klev_rec.kle_id := rosetta_g_miss_num_map(p7_a2);
    ddp_klev_rec.sty_id := rosetta_g_miss_num_map(p7_a3);
    ddp_klev_rec.prc_code := p7_a4;
    ddp_klev_rec.fcg_code := p7_a5;
    ddp_klev_rec.nty_code := p7_a6;
    ddp_klev_rec.estimated_oec := rosetta_g_miss_num_map(p7_a7);
    ddp_klev_rec.lao_amount := rosetta_g_miss_num_map(p7_a8);
    ddp_klev_rec.title_date := rosetta_g_miss_date_in_map(p7_a9);
    ddp_klev_rec.fee_charge := rosetta_g_miss_num_map(p7_a10);
    ddp_klev_rec.lrs_percent := rosetta_g_miss_num_map(p7_a11);
    ddp_klev_rec.initial_direct_cost := rosetta_g_miss_num_map(p7_a12);
    ddp_klev_rec.percent_stake := rosetta_g_miss_num_map(p7_a13);
    ddp_klev_rec.percent := rosetta_g_miss_num_map(p7_a14);
    ddp_klev_rec.evergreen_percent := rosetta_g_miss_num_map(p7_a15);
    ddp_klev_rec.amount_stake := rosetta_g_miss_num_map(p7_a16);
    ddp_klev_rec.occupancy := rosetta_g_miss_num_map(p7_a17);
    ddp_klev_rec.coverage := rosetta_g_miss_num_map(p7_a18);
    ddp_klev_rec.residual_percentage := rosetta_g_miss_num_map(p7_a19);
    ddp_klev_rec.date_last_inspection := rosetta_g_miss_date_in_map(p7_a20);
    ddp_klev_rec.date_sold := rosetta_g_miss_date_in_map(p7_a21);
    ddp_klev_rec.lrv_amount := rosetta_g_miss_num_map(p7_a22);
    ddp_klev_rec.capital_reduction := rosetta_g_miss_num_map(p7_a23);
    ddp_klev_rec.date_next_inspection_due := rosetta_g_miss_date_in_map(p7_a24);
    ddp_klev_rec.date_residual_last_review := rosetta_g_miss_date_in_map(p7_a25);
    ddp_klev_rec.date_last_reamortisation := rosetta_g_miss_date_in_map(p7_a26);
    ddp_klev_rec.vendor_advance_paid := rosetta_g_miss_num_map(p7_a27);
    ddp_klev_rec.weighted_average_life := rosetta_g_miss_num_map(p7_a28);
    ddp_klev_rec.tradein_amount := rosetta_g_miss_num_map(p7_a29);
    ddp_klev_rec.bond_equivalent_yield := rosetta_g_miss_num_map(p7_a30);
    ddp_klev_rec.termination_purchase_amount := rosetta_g_miss_num_map(p7_a31);
    ddp_klev_rec.refinance_amount := rosetta_g_miss_num_map(p7_a32);
    ddp_klev_rec.year_built := rosetta_g_miss_num_map(p7_a33);
    ddp_klev_rec.delivered_date := rosetta_g_miss_date_in_map(p7_a34);
    ddp_klev_rec.credit_tenant_yn := p7_a35;
    ddp_klev_rec.date_last_cleanup := rosetta_g_miss_date_in_map(p7_a36);
    ddp_klev_rec.year_of_manufacture := p7_a37;
    ddp_klev_rec.coverage_ratio := rosetta_g_miss_num_map(p7_a38);
    ddp_klev_rec.remarketed_amount := rosetta_g_miss_num_map(p7_a39);
    ddp_klev_rec.gross_square_footage := rosetta_g_miss_num_map(p7_a40);
    ddp_klev_rec.prescribed_asset_yn := p7_a41;
    ddp_klev_rec.date_remarketed := rosetta_g_miss_date_in_map(p7_a42);
    ddp_klev_rec.net_rentable := rosetta_g_miss_num_map(p7_a43);
    ddp_klev_rec.remarket_margin := rosetta_g_miss_num_map(p7_a44);
    ddp_klev_rec.date_letter_acceptance := rosetta_g_miss_date_in_map(p7_a45);
    ddp_klev_rec.repurchased_amount := rosetta_g_miss_num_map(p7_a46);
    ddp_klev_rec.date_commitment_expiration := rosetta_g_miss_date_in_map(p7_a47);
    ddp_klev_rec.date_repurchased := rosetta_g_miss_date_in_map(p7_a48);
    ddp_klev_rec.date_appraisal := rosetta_g_miss_date_in_map(p7_a49);
    ddp_klev_rec.residual_value := rosetta_g_miss_num_map(p7_a50);
    ddp_klev_rec.appraisal_value := rosetta_g_miss_num_map(p7_a51);
    ddp_klev_rec.secured_deal_yn := p7_a52;
    ddp_klev_rec.gain_loss := rosetta_g_miss_num_map(p7_a53);
    ddp_klev_rec.floor_amount := rosetta_g_miss_num_map(p7_a54);
    ddp_klev_rec.re_lease_yn := p7_a55;
    ddp_klev_rec.previous_contract := p7_a56;
    ddp_klev_rec.tracked_residual := rosetta_g_miss_num_map(p7_a57);
    ddp_klev_rec.date_title_received := rosetta_g_miss_date_in_map(p7_a58);
    ddp_klev_rec.amount := rosetta_g_miss_num_map(p7_a59);
    ddp_klev_rec.attribute_category := p7_a60;
    ddp_klev_rec.attribute1 := p7_a61;
    ddp_klev_rec.attribute2 := p7_a62;
    ddp_klev_rec.attribute3 := p7_a63;
    ddp_klev_rec.attribute4 := p7_a64;
    ddp_klev_rec.attribute5 := p7_a65;
    ddp_klev_rec.attribute6 := p7_a66;
    ddp_klev_rec.attribute7 := p7_a67;
    ddp_klev_rec.attribute8 := p7_a68;
    ddp_klev_rec.attribute9 := p7_a69;
    ddp_klev_rec.attribute10 := p7_a70;
    ddp_klev_rec.attribute11 := p7_a71;
    ddp_klev_rec.attribute12 := p7_a72;
    ddp_klev_rec.attribute13 := p7_a73;
    ddp_klev_rec.attribute14 := p7_a74;
    ddp_klev_rec.attribute15 := p7_a75;
    ddp_klev_rec.sty_id_for := rosetta_g_miss_num_map(p7_a76);
    ddp_klev_rec.clg_id := rosetta_g_miss_num_map(p7_a77);
    ddp_klev_rec.created_by := rosetta_g_miss_num_map(p7_a78);
    ddp_klev_rec.creation_date := rosetta_g_miss_date_in_map(p7_a79);
    ddp_klev_rec.last_updated_by := rosetta_g_miss_num_map(p7_a80);
    ddp_klev_rec.last_update_date := rosetta_g_miss_date_in_map(p7_a81);
    ddp_klev_rec.last_update_login := rosetta_g_miss_num_map(p7_a82);
    ddp_klev_rec.date_funding := rosetta_g_miss_date_in_map(p7_a83);
    ddp_klev_rec.date_funding_required := rosetta_g_miss_date_in_map(p7_a84);
    ddp_klev_rec.date_accepted := rosetta_g_miss_date_in_map(p7_a85);
    ddp_klev_rec.date_delivery_expected := rosetta_g_miss_date_in_map(p7_a86);
    ddp_klev_rec.oec := rosetta_g_miss_num_map(p7_a87);
    ddp_klev_rec.capital_amount := rosetta_g_miss_num_map(p7_a88);
    ddp_klev_rec.residual_grnty_amount := rosetta_g_miss_num_map(p7_a89);
    ddp_klev_rec.residual_code := p7_a90;
    ddp_klev_rec.rvi_premium := rosetta_g_miss_num_map(p7_a91);
    ddp_klev_rec.credit_nature := p7_a92;
    ddp_klev_rec.capitalized_interest := rosetta_g_miss_num_map(p7_a93);
    ddp_klev_rec.capital_reduction_percent := rosetta_g_miss_num_map(p7_a94);
    ddp_klev_rec.date_pay_investor_start := rosetta_g_miss_date_in_map(p7_a95);
    ddp_klev_rec.pay_investor_frequency := p7_a96;
    ddp_klev_rec.pay_investor_event := p7_a97;
    ddp_klev_rec.pay_investor_remittance_days := rosetta_g_miss_num_map(p7_a98);

    -- here's the delegated call to the old PL/SQL routine
    okl_credit_pub.validate_credit_limit(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_mode,
      ddp_clev_rec,
      ddp_klev_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

  procedure validate_credit_limit(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_mode  VARCHAR2
    , p6_a0 JTF_NUMBER_TABLE
    , p6_a1 JTF_NUMBER_TABLE
    , p6_a2 JTF_VARCHAR2_TABLE_100
    , p6_a3 JTF_NUMBER_TABLE
    , p6_a4 JTF_NUMBER_TABLE
    , p6_a5 JTF_NUMBER_TABLE
    , p6_a6 JTF_NUMBER_TABLE
    , p6_a7 JTF_NUMBER_TABLE
    , p6_a8 JTF_VARCHAR2_TABLE_200
    , p6_a9 JTF_VARCHAR2_TABLE_100
    , p6_a10 JTF_NUMBER_TABLE
    , p6_a11 JTF_VARCHAR2_TABLE_100
    , p6_a12 JTF_NUMBER_TABLE
    , p6_a13 JTF_VARCHAR2_TABLE_2000
    , p6_a14 JTF_VARCHAR2_TABLE_2000
    , p6_a15 JTF_VARCHAR2_TABLE_2000
    , p6_a16 JTF_VARCHAR2_TABLE_300
    , p6_a17 JTF_VARCHAR2_TABLE_100
    , p6_a18 JTF_NUMBER_TABLE
    , p6_a19 JTF_NUMBER_TABLE
    , p6_a20 JTF_NUMBER_TABLE
    , p6_a21 JTF_NUMBER_TABLE
    , p6_a22 JTF_VARCHAR2_TABLE_100
    , p6_a23 JTF_VARCHAR2_TABLE_100
    , p6_a24 JTF_VARCHAR2_TABLE_100
    , p6_a25 JTF_VARCHAR2_TABLE_2000
    , p6_a26 JTF_VARCHAR2_TABLE_100
    , p6_a27 JTF_VARCHAR2_TABLE_200
    , p6_a28 JTF_DATE_TABLE
    , p6_a29 JTF_VARCHAR2_TABLE_200
    , p6_a30 JTF_DATE_TABLE
    , p6_a31 JTF_DATE_TABLE
    , p6_a32 JTF_DATE_TABLE
    , p6_a33 JTF_VARCHAR2_TABLE_100
    , p6_a34 JTF_NUMBER_TABLE
    , p6_a35 JTF_VARCHAR2_TABLE_100
    , p6_a36 JTF_NUMBER_TABLE
    , p6_a37 JTF_VARCHAR2_TABLE_100
    , p6_a38 JTF_VARCHAR2_TABLE_100
    , p6_a39 JTF_VARCHAR2_TABLE_500
    , p6_a40 JTF_VARCHAR2_TABLE_500
    , p6_a41 JTF_VARCHAR2_TABLE_500
    , p6_a42 JTF_VARCHAR2_TABLE_500
    , p6_a43 JTF_VARCHAR2_TABLE_500
    , p6_a44 JTF_VARCHAR2_TABLE_500
    , p6_a45 JTF_VARCHAR2_TABLE_500
    , p6_a46 JTF_VARCHAR2_TABLE_500
    , p6_a47 JTF_VARCHAR2_TABLE_500
    , p6_a48 JTF_VARCHAR2_TABLE_500
    , p6_a49 JTF_VARCHAR2_TABLE_500
    , p6_a50 JTF_VARCHAR2_TABLE_500
    , p6_a51 JTF_VARCHAR2_TABLE_500
    , p6_a52 JTF_VARCHAR2_TABLE_500
    , p6_a53 JTF_VARCHAR2_TABLE_500
    , p6_a54 JTF_NUMBER_TABLE
    , p6_a55 JTF_DATE_TABLE
    , p6_a56 JTF_NUMBER_TABLE
    , p6_a57 JTF_DATE_TABLE
    , p6_a58 JTF_VARCHAR2_TABLE_100
    , p6_a59 JTF_VARCHAR2_TABLE_100
    , p6_a60 JTF_VARCHAR2_TABLE_100
    , p6_a61 JTF_NUMBER_TABLE
    , p6_a62 JTF_VARCHAR2_TABLE_100
    , p6_a63 JTF_VARCHAR2_TABLE_100
    , p6_a64 JTF_VARCHAR2_TABLE_100
    , p6_a65 JTF_VARCHAR2_TABLE_100
    , p6_a66 JTF_VARCHAR2_TABLE_100
    , p6_a67 JTF_NUMBER_TABLE
    , p6_a68 JTF_NUMBER_TABLE
    , p6_a69 JTF_NUMBER_TABLE
    , p6_a70 JTF_DATE_TABLE
    , p6_a71 JTF_NUMBER_TABLE
    , p6_a72 JTF_DATE_TABLE
    , p6_a73 JTF_NUMBER_TABLE
    , p6_a74 JTF_NUMBER_TABLE
    , p6_a75 JTF_VARCHAR2_TABLE_100
    , p6_a76 JTF_VARCHAR2_TABLE_100
    , p6_a77 JTF_NUMBER_TABLE
    , p6_a78 JTF_NUMBER_TABLE
    , p6_a79 JTF_VARCHAR2_TABLE_100
    , p6_a80 JTF_VARCHAR2_TABLE_100
    , p6_a81 JTF_NUMBER_TABLE
    , p6_a82 JTF_VARCHAR2_TABLE_100
    , p6_a83 JTF_NUMBER_TABLE
    , p6_a84 JTF_NUMBER_TABLE
    , p6_a85 JTF_NUMBER_TABLE
    , p6_a86 JTF_NUMBER_TABLE
    , p6_a87 JTF_VARCHAR2_TABLE_100
    , p6_a88 JTF_NUMBER_TABLE
    , p6_a89 JTF_NUMBER_TABLE
    , p7_a0 JTF_NUMBER_TABLE
    , p7_a1 JTF_NUMBER_TABLE
    , p7_a2 JTF_NUMBER_TABLE
    , p7_a3 JTF_NUMBER_TABLE
    , p7_a4 JTF_VARCHAR2_TABLE_100
    , p7_a5 JTF_VARCHAR2_TABLE_100
    , p7_a6 JTF_VARCHAR2_TABLE_100
    , p7_a7 JTF_NUMBER_TABLE
    , p7_a8 JTF_NUMBER_TABLE
    , p7_a9 JTF_DATE_TABLE
    , p7_a10 JTF_NUMBER_TABLE
    , p7_a11 JTF_NUMBER_TABLE
    , p7_a12 JTF_NUMBER_TABLE
    , p7_a13 JTF_NUMBER_TABLE
    , p7_a14 JTF_NUMBER_TABLE
    , p7_a15 JTF_NUMBER_TABLE
    , p7_a16 JTF_NUMBER_TABLE
    , p7_a17 JTF_NUMBER_TABLE
    , p7_a18 JTF_NUMBER_TABLE
    , p7_a19 JTF_NUMBER_TABLE
    , p7_a20 JTF_DATE_TABLE
    , p7_a21 JTF_DATE_TABLE
    , p7_a22 JTF_NUMBER_TABLE
    , p7_a23 JTF_NUMBER_TABLE
    , p7_a24 JTF_DATE_TABLE
    , p7_a25 JTF_DATE_TABLE
    , p7_a26 JTF_DATE_TABLE
    , p7_a27 JTF_NUMBER_TABLE
    , p7_a28 JTF_NUMBER_TABLE
    , p7_a29 JTF_NUMBER_TABLE
    , p7_a30 JTF_NUMBER_TABLE
    , p7_a31 JTF_NUMBER_TABLE
    , p7_a32 JTF_NUMBER_TABLE
    , p7_a33 JTF_NUMBER_TABLE
    , p7_a34 JTF_DATE_TABLE
    , p7_a35 JTF_VARCHAR2_TABLE_100
    , p7_a36 JTF_DATE_TABLE
    , p7_a37 JTF_VARCHAR2_TABLE_300
    , p7_a38 JTF_NUMBER_TABLE
    , p7_a39 JTF_NUMBER_TABLE
    , p7_a40 JTF_NUMBER_TABLE
    , p7_a41 JTF_VARCHAR2_TABLE_100
    , p7_a42 JTF_DATE_TABLE
    , p7_a43 JTF_NUMBER_TABLE
    , p7_a44 JTF_NUMBER_TABLE
    , p7_a45 JTF_DATE_TABLE
    , p7_a46 JTF_NUMBER_TABLE
    , p7_a47 JTF_DATE_TABLE
    , p7_a48 JTF_DATE_TABLE
    , p7_a49 JTF_DATE_TABLE
    , p7_a50 JTF_NUMBER_TABLE
    , p7_a51 JTF_NUMBER_TABLE
    , p7_a52 JTF_VARCHAR2_TABLE_100
    , p7_a53 JTF_NUMBER_TABLE
    , p7_a54 JTF_NUMBER_TABLE
    , p7_a55 JTF_VARCHAR2_TABLE_100
    , p7_a56 JTF_VARCHAR2_TABLE_100
    , p7_a57 JTF_NUMBER_TABLE
    , p7_a58 JTF_DATE_TABLE
    , p7_a59 JTF_NUMBER_TABLE
    , p7_a60 JTF_VARCHAR2_TABLE_100
    , p7_a61 JTF_VARCHAR2_TABLE_500
    , p7_a62 JTF_VARCHAR2_TABLE_500
    , p7_a63 JTF_VARCHAR2_TABLE_500
    , p7_a64 JTF_VARCHAR2_TABLE_500
    , p7_a65 JTF_VARCHAR2_TABLE_500
    , p7_a66 JTF_VARCHAR2_TABLE_500
    , p7_a67 JTF_VARCHAR2_TABLE_500
    , p7_a68 JTF_VARCHAR2_TABLE_500
    , p7_a69 JTF_VARCHAR2_TABLE_500
    , p7_a70 JTF_VARCHAR2_TABLE_500
    , p7_a71 JTF_VARCHAR2_TABLE_500
    , p7_a72 JTF_VARCHAR2_TABLE_500
    , p7_a73 JTF_VARCHAR2_TABLE_500
    , p7_a74 JTF_VARCHAR2_TABLE_500
    , p7_a75 JTF_VARCHAR2_TABLE_500
    , p7_a76 JTF_NUMBER_TABLE
    , p7_a77 JTF_NUMBER_TABLE
    , p7_a78 JTF_NUMBER_TABLE
    , p7_a79 JTF_DATE_TABLE
    , p7_a80 JTF_NUMBER_TABLE
    , p7_a81 JTF_DATE_TABLE
    , p7_a82 JTF_NUMBER_TABLE
    , p7_a83 JTF_DATE_TABLE
    , p7_a84 JTF_DATE_TABLE
    , p7_a85 JTF_DATE_TABLE
    , p7_a86 JTF_DATE_TABLE
    , p7_a87 JTF_NUMBER_TABLE
    , p7_a88 JTF_NUMBER_TABLE
    , p7_a89 JTF_NUMBER_TABLE
    , p7_a90 JTF_VARCHAR2_TABLE_100
    , p7_a91 JTF_NUMBER_TABLE
    , p7_a92 JTF_VARCHAR2_TABLE_100
    , p7_a93 JTF_NUMBER_TABLE
    , p7_a94 JTF_NUMBER_TABLE
    , p7_a95 JTF_DATE_TABLE
    , p7_a96 JTF_VARCHAR2_TABLE_100
    , p7_a97 JTF_VARCHAR2_TABLE_100
    , p7_a98 JTF_NUMBER_TABLE
  )

  as
    ddp_clev_tbl okl_okc_migration_pvt.clev_tbl_type;
    ddp_klev_tbl okl_credit_pub.klev_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any






    okl_okc_migration_pvt_w.rosetta_table_copy_in_p5(ddp_clev_tbl, p6_a0
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
      , p6_a63
      , p6_a64
      , p6_a65
      , p6_a66
      , p6_a67
      , p6_a68
      , p6_a69
      , p6_a70
      , p6_a71
      , p6_a72
      , p6_a73
      , p6_a74
      , p6_a75
      , p6_a76
      , p6_a77
      , p6_a78
      , p6_a79
      , p6_a80
      , p6_a81
      , p6_a82
      , p6_a83
      , p6_a84
      , p6_a85
      , p6_a86
      , p6_a87
      , p6_a88
      , p6_a89
      );

    okl_kle_pvt_w.rosetta_table_copy_in_p8(ddp_klev_tbl, p7_a0
      , p7_a1
      , p7_a2
      , p7_a3
      , p7_a4
      , p7_a5
      , p7_a6
      , p7_a7
      , p7_a8
      , p7_a9
      , p7_a10
      , p7_a11
      , p7_a12
      , p7_a13
      , p7_a14
      , p7_a15
      , p7_a16
      , p7_a17
      , p7_a18
      , p7_a19
      , p7_a20
      , p7_a21
      , p7_a22
      , p7_a23
      , p7_a24
      , p7_a25
      , p7_a26
      , p7_a27
      , p7_a28
      , p7_a29
      , p7_a30
      , p7_a31
      , p7_a32
      , p7_a33
      , p7_a34
      , p7_a35
      , p7_a36
      , p7_a37
      , p7_a38
      , p7_a39
      , p7_a40
      , p7_a41
      , p7_a42
      , p7_a43
      , p7_a44
      , p7_a45
      , p7_a46
      , p7_a47
      , p7_a48
      , p7_a49
      , p7_a50
      , p7_a51
      , p7_a52
      , p7_a53
      , p7_a54
      , p7_a55
      , p7_a56
      , p7_a57
      , p7_a58
      , p7_a59
      , p7_a60
      , p7_a61
      , p7_a62
      , p7_a63
      , p7_a64
      , p7_a65
      , p7_a66
      , p7_a67
      , p7_a68
      , p7_a69
      , p7_a70
      , p7_a71
      , p7_a72
      , p7_a73
      , p7_a74
      , p7_a75
      , p7_a76
      , p7_a77
      , p7_a78
      , p7_a79
      , p7_a80
      , p7_a81
      , p7_a82
      , p7_a83
      , p7_a84
      , p7_a85
      , p7_a86
      , p7_a87
      , p7_a88
      , p7_a89
      , p7_a90
      , p7_a91
      , p7_a92
      , p7_a93
      , p7_a94
      , p7_a95
      , p7_a96
      , p7_a97
      , p7_a98
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_credit_pub.validate_credit_limit(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_mode,
      ddp_clev_tbl,
      ddp_klev_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

  procedure create_credit_limit(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_VARCHAR2_TABLE_200
    , p5_a4 JTF_VARCHAR2_TABLE_100
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_VARCHAR2_TABLE_2000
    , p5_a8 JTF_VARCHAR2_TABLE_100
    , p5_a9 JTF_DATE_TABLE
    , p6_a0 JTF_NUMBER_TABLE
    , p6_a1 JTF_NUMBER_TABLE
    , p6_a2 JTF_NUMBER_TABLE
    , p6_a3 JTF_NUMBER_TABLE
    , p6_a4 JTF_VARCHAR2_TABLE_100
    , p6_a5 JTF_VARCHAR2_TABLE_100
    , p6_a6 JTF_VARCHAR2_TABLE_100
    , p6_a7 JTF_NUMBER_TABLE
    , p6_a8 JTF_NUMBER_TABLE
    , p6_a9 JTF_DATE_TABLE
    , p6_a10 JTF_NUMBER_TABLE
    , p6_a11 JTF_NUMBER_TABLE
    , p6_a12 JTF_NUMBER_TABLE
    , p6_a13 JTF_NUMBER_TABLE
    , p6_a14 JTF_NUMBER_TABLE
    , p6_a15 JTF_NUMBER_TABLE
    , p6_a16 JTF_NUMBER_TABLE
    , p6_a17 JTF_NUMBER_TABLE
    , p6_a18 JTF_NUMBER_TABLE
    , p6_a19 JTF_NUMBER_TABLE
    , p6_a20 JTF_DATE_TABLE
    , p6_a21 JTF_DATE_TABLE
    , p6_a22 JTF_NUMBER_TABLE
    , p6_a23 JTF_NUMBER_TABLE
    , p6_a24 JTF_DATE_TABLE
    , p6_a25 JTF_DATE_TABLE
    , p6_a26 JTF_DATE_TABLE
    , p6_a27 JTF_NUMBER_TABLE
    , p6_a28 JTF_NUMBER_TABLE
    , p6_a29 JTF_NUMBER_TABLE
    , p6_a30 JTF_NUMBER_TABLE
    , p6_a31 JTF_NUMBER_TABLE
    , p6_a32 JTF_NUMBER_TABLE
    , p6_a33 JTF_NUMBER_TABLE
    , p6_a34 JTF_DATE_TABLE
    , p6_a35 JTF_VARCHAR2_TABLE_100
    , p6_a36 JTF_DATE_TABLE
    , p6_a37 JTF_VARCHAR2_TABLE_300
    , p6_a38 JTF_NUMBER_TABLE
    , p6_a39 JTF_NUMBER_TABLE
    , p6_a40 JTF_NUMBER_TABLE
    , p6_a41 JTF_VARCHAR2_TABLE_100
    , p6_a42 JTF_DATE_TABLE
    , p6_a43 JTF_NUMBER_TABLE
    , p6_a44 JTF_NUMBER_TABLE
    , p6_a45 JTF_DATE_TABLE
    , p6_a46 JTF_NUMBER_TABLE
    , p6_a47 JTF_DATE_TABLE
    , p6_a48 JTF_DATE_TABLE
    , p6_a49 JTF_DATE_TABLE
    , p6_a50 JTF_NUMBER_TABLE
    , p6_a51 JTF_NUMBER_TABLE
    , p6_a52 JTF_VARCHAR2_TABLE_100
    , p6_a53 JTF_NUMBER_TABLE
    , p6_a54 JTF_NUMBER_TABLE
    , p6_a55 JTF_VARCHAR2_TABLE_100
    , p6_a56 JTF_VARCHAR2_TABLE_100
    , p6_a57 JTF_NUMBER_TABLE
    , p6_a58 JTF_DATE_TABLE
    , p6_a59 JTF_NUMBER_TABLE
    , p6_a60 JTF_VARCHAR2_TABLE_100
    , p6_a61 JTF_VARCHAR2_TABLE_500
    , p6_a62 JTF_VARCHAR2_TABLE_500
    , p6_a63 JTF_VARCHAR2_TABLE_500
    , p6_a64 JTF_VARCHAR2_TABLE_500
    , p6_a65 JTF_VARCHAR2_TABLE_500
    , p6_a66 JTF_VARCHAR2_TABLE_500
    , p6_a67 JTF_VARCHAR2_TABLE_500
    , p6_a68 JTF_VARCHAR2_TABLE_500
    , p6_a69 JTF_VARCHAR2_TABLE_500
    , p6_a70 JTF_VARCHAR2_TABLE_500
    , p6_a71 JTF_VARCHAR2_TABLE_500
    , p6_a72 JTF_VARCHAR2_TABLE_500
    , p6_a73 JTF_VARCHAR2_TABLE_500
    , p6_a74 JTF_VARCHAR2_TABLE_500
    , p6_a75 JTF_VARCHAR2_TABLE_500
    , p6_a76 JTF_NUMBER_TABLE
    , p6_a77 JTF_NUMBER_TABLE
    , p6_a78 JTF_NUMBER_TABLE
    , p6_a79 JTF_DATE_TABLE
    , p6_a80 JTF_NUMBER_TABLE
    , p6_a81 JTF_DATE_TABLE
    , p6_a82 JTF_NUMBER_TABLE
    , p6_a83 JTF_DATE_TABLE
    , p6_a84 JTF_DATE_TABLE
    , p6_a85 JTF_DATE_TABLE
    , p6_a86 JTF_DATE_TABLE
    , p6_a87 JTF_NUMBER_TABLE
    , p6_a88 JTF_NUMBER_TABLE
    , p6_a89 JTF_NUMBER_TABLE
    , p6_a90 JTF_VARCHAR2_TABLE_100
    , p6_a91 JTF_NUMBER_TABLE
    , p6_a92 JTF_VARCHAR2_TABLE_100
    , p6_a93 JTF_NUMBER_TABLE
    , p6_a94 JTF_NUMBER_TABLE
    , p6_a95 JTF_DATE_TABLE
    , p6_a96 JTF_VARCHAR2_TABLE_100
    , p6_a97 JTF_VARCHAR2_TABLE_100
    , p6_a98 JTF_NUMBER_TABLE
    , p7_a0 out nocopy JTF_NUMBER_TABLE
    , p7_a1 out nocopy JTF_NUMBER_TABLE
    , p7_a2 out nocopy JTF_NUMBER_TABLE
    , p7_a3 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a5 out nocopy JTF_NUMBER_TABLE
    , p7_a6 out nocopy JTF_NUMBER_TABLE
    , p7_a7 out nocopy JTF_VARCHAR2_TABLE_2000
    , p7_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a9 out nocopy JTF_DATE_TABLE
    , p8_a0 out nocopy JTF_NUMBER_TABLE
    , p8_a1 out nocopy JTF_NUMBER_TABLE
    , p8_a2 out nocopy JTF_NUMBER_TABLE
    , p8_a3 out nocopy JTF_NUMBER_TABLE
    , p8_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a7 out nocopy JTF_NUMBER_TABLE
    , p8_a8 out nocopy JTF_NUMBER_TABLE
    , p8_a9 out nocopy JTF_DATE_TABLE
    , p8_a10 out nocopy JTF_NUMBER_TABLE
    , p8_a11 out nocopy JTF_NUMBER_TABLE
    , p8_a12 out nocopy JTF_NUMBER_TABLE
    , p8_a13 out nocopy JTF_NUMBER_TABLE
    , p8_a14 out nocopy JTF_NUMBER_TABLE
    , p8_a15 out nocopy JTF_NUMBER_TABLE

    , p8_a16 out nocopy JTF_NUMBER_TABLE
    , p8_a17 out nocopy JTF_NUMBER_TABLE
    , p8_a18 out nocopy JTF_NUMBER_TABLE
    , p8_a19 out nocopy JTF_NUMBER_TABLE
    , p8_a20 out nocopy JTF_DATE_TABLE
    , p8_a21 out nocopy JTF_DATE_TABLE
    , p8_a22 out nocopy JTF_NUMBER_TABLE
    , p8_a23 out nocopy JTF_NUMBER_TABLE
    , p8_a24 out nocopy JTF_DATE_TABLE
    , p8_a25 out nocopy JTF_DATE_TABLE
    , p8_a26 out nocopy JTF_DATE_TABLE
    , p8_a27 out nocopy JTF_NUMBER_TABLE
    , p8_a28 out nocopy JTF_NUMBER_TABLE
    , p8_a29 out nocopy JTF_NUMBER_TABLE
    , p8_a30 out nocopy JTF_NUMBER_TABLE
    , p8_a31 out nocopy JTF_NUMBER_TABLE
    , p8_a32 out nocopy JTF_NUMBER_TABLE
    , p8_a33 out nocopy JTF_NUMBER_TABLE
    , p8_a34 out nocopy JTF_DATE_TABLE
    , p8_a35 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a36 out nocopy JTF_DATE_TABLE
    , p8_a37 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a38 out nocopy JTF_NUMBER_TABLE
    , p8_a39 out nocopy JTF_NUMBER_TABLE
    , p8_a40 out nocopy JTF_NUMBER_TABLE
    , p8_a41 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a42 out nocopy JTF_DATE_TABLE
    , p8_a43 out nocopy JTF_NUMBER_TABLE
    , p8_a44 out nocopy JTF_NUMBER_TABLE
    , p8_a45 out nocopy JTF_DATE_TABLE
    , p8_a46 out nocopy JTF_NUMBER_TABLE
    , p8_a47 out nocopy JTF_DATE_TABLE
    , p8_a48 out nocopy JTF_DATE_TABLE
    , p8_a49 out nocopy JTF_DATE_TABLE
    , p8_a50 out nocopy JTF_NUMBER_TABLE
    , p8_a51 out nocopy JTF_NUMBER_TABLE
    , p8_a52 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a53 out nocopy JTF_NUMBER_TABLE
    , p8_a54 out nocopy JTF_NUMBER_TABLE
    , p8_a55 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a56 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a57 out nocopy JTF_NUMBER_TABLE
    , p8_a58 out nocopy JTF_DATE_TABLE
    , p8_a59 out nocopy JTF_NUMBER_TABLE
    , p8_a60 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a61 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a62 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a63 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a64 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a65 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a66 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a67 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a68 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a69 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a70 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a71 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a72 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a73 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a74 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a75 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a76 out nocopy JTF_NUMBER_TABLE
    , p8_a77 out nocopy JTF_NUMBER_TABLE
    , p8_a78 out nocopy JTF_NUMBER_TABLE
    , p8_a79 out nocopy JTF_DATE_TABLE
    , p8_a80 out nocopy JTF_NUMBER_TABLE
    , p8_a81 out nocopy JTF_DATE_TABLE
    , p8_a82 out nocopy JTF_NUMBER_TABLE
    , p8_a83 out nocopy JTF_DATE_TABLE
    , p8_a84 out nocopy JTF_DATE_TABLE
    , p8_a85 out nocopy JTF_DATE_TABLE
    , p8_a86 out nocopy JTF_DATE_TABLE
    , p8_a87 out nocopy JTF_NUMBER_TABLE
    , p8_a88 out nocopy JTF_NUMBER_TABLE
    , p8_a89 out nocopy JTF_NUMBER_TABLE
    , p8_a90 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a91 out nocopy JTF_NUMBER_TABLE
    , p8_a92 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a93 out nocopy JTF_NUMBER_TABLE
    , p8_a94 out nocopy JTF_NUMBER_TABLE
    , p8_a95 out nocopy JTF_DATE_TABLE
    , p8_a96 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a97 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a98 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_clev_tbl okl_credit_pub.clev_tbl_type;
    ddp_klev_tbl okl_credit_pub.klev_tbl_type;
    ddx_clev_tbl okl_credit_pub.clev_tbl_type;
    ddx_klev_tbl okl_credit_pub.klev_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_credit_pub_w.rosetta_table_copy_in_p5(ddp_clev_tbl, p5_a0
      , p5_a1
      , p5_a2
      , p5_a3
      , p5_a4
      , p5_a5
      , p5_a6
      , p5_a7
      , p5_a8
      , p5_a9
      );

    okl_kle_pvt_w.rosetta_table_copy_in_p8(ddp_klev_tbl, p6_a0
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
      , p6_a63
      , p6_a64
      , p6_a65
      , p6_a66
      , p6_a67
      , p6_a68
      , p6_a69
      , p6_a70
      , p6_a71
      , p6_a72
      , p6_a73
      , p6_a74
      , p6_a75
      , p6_a76
      , p6_a77
      , p6_a78
      , p6_a79
      , p6_a80
      , p6_a81
      , p6_a82
      , p6_a83
      , p6_a84
      , p6_a85
      , p6_a86
      , p6_a87
      , p6_a88
      , p6_a89
      , p6_a90
      , p6_a91
      , p6_a92
      , p6_a93
      , p6_a94
      , p6_a95
      , p6_a96
      , p6_a97
      , p6_a98
      );



    -- here's the delegated call to the old PL/SQL routine
    okl_credit_pub.create_credit_limit(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_clev_tbl,
      ddp_klev_tbl,
      ddx_clev_tbl,
      ddx_klev_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







    okl_credit_pub_w.rosetta_table_copy_out_p5(ddx_clev_tbl, p7_a0
      , p7_a1
      , p7_a2
      , p7_a3
      , p7_a4
      , p7_a5
      , p7_a6
      , p7_a7
      , p7_a8
      , p7_a9
      );

    okl_kle_pvt_w.rosetta_table_copy_out_p8(ddx_klev_tbl, p8_a0
      , p8_a1
      , p8_a2
      , p8_a3
      , p8_a4
      , p8_a5
      , p8_a6
      , p8_a7
      , p8_a8
      , p8_a9
      , p8_a10
      , p8_a11
      , p8_a12
      , p8_a13
      , p8_a14
      , p8_a15
      , p8_a16
      , p8_a17
      , p8_a18
      , p8_a19
      , p8_a20
      , p8_a21
      , p8_a22
      , p8_a23
      , p8_a24
      , p8_a25
      , p8_a26
      , p8_a27
      , p8_a28
      , p8_a29
      , p8_a30
      , p8_a31
      , p8_a32
      , p8_a33
      , p8_a34
      , p8_a35
      , p8_a36
      , p8_a37
      , p8_a38
      , p8_a39
      , p8_a40
      , p8_a41
      , p8_a42
      , p8_a43
      , p8_a44
      , p8_a45
      , p8_a46
      , p8_a47
      , p8_a48
      , p8_a49
      , p8_a50
      , p8_a51
      , p8_a52
      , p8_a53
      , p8_a54
      , p8_a55
      , p8_a56
      , p8_a57
      , p8_a58
      , p8_a59
      , p8_a60
      , p8_a61
      , p8_a62
      , p8_a63
      , p8_a64
      , p8_a65
      , p8_a66
      , p8_a67
      , p8_a68
      , p8_a69
      , p8_a70
      , p8_a71
      , p8_a72
      , p8_a73
      , p8_a74
      , p8_a75
      , p8_a76
      , p8_a77
      , p8_a78
      , p8_a79
      , p8_a80
      , p8_a81
      , p8_a82
      , p8_a83
      , p8_a84
      , p8_a85
      , p8_a86
      , p8_a87
      , p8_a88
      , p8_a89
      , p8_a90
      , p8_a91
      , p8_a92
      , p8_a93
      , p8_a94
      , p8_a95
      , p8_a96
      , p8_a97
      , p8_a98
      );
  end;

  procedure update_credit_limit(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_VARCHAR2_TABLE_200
    , p5_a4 JTF_VARCHAR2_TABLE_100
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_VARCHAR2_TABLE_2000
    , p5_a8 JTF_VARCHAR2_TABLE_100
    , p5_a9 JTF_DATE_TABLE
    , p6_a0 JTF_NUMBER_TABLE
    , p6_a1 JTF_NUMBER_TABLE
    , p6_a2 JTF_NUMBER_TABLE
    , p6_a3 JTF_NUMBER_TABLE
    , p6_a4 JTF_VARCHAR2_TABLE_100
    , p6_a5 JTF_VARCHAR2_TABLE_100
    , p6_a6 JTF_VARCHAR2_TABLE_100
    , p6_a7 JTF_NUMBER_TABLE
    , p6_a8 JTF_NUMBER_TABLE
    , p6_a9 JTF_DATE_TABLE
    , p6_a10 JTF_NUMBER_TABLE
    , p6_a11 JTF_NUMBER_TABLE
    , p6_a12 JTF_NUMBER_TABLE
    , p6_a13 JTF_NUMBER_TABLE
    , p6_a14 JTF_NUMBER_TABLE
    , p6_a15 JTF_NUMBER_TABLE
    , p6_a16 JTF_NUMBER_TABLE
    , p6_a17 JTF_NUMBER_TABLE
    , p6_a18 JTF_NUMBER_TABLE
    , p6_a19 JTF_NUMBER_TABLE
    , p6_a20 JTF_DATE_TABLE
    , p6_a21 JTF_DATE_TABLE
    , p6_a22 JTF_NUMBER_TABLE
    , p6_a23 JTF_NUMBER_TABLE
    , p6_a24 JTF_DATE_TABLE
    , p6_a25 JTF_DATE_TABLE
    , p6_a26 JTF_DATE_TABLE
    , p6_a27 JTF_NUMBER_TABLE
    , p6_a28 JTF_NUMBER_TABLE
    , p6_a29 JTF_NUMBER_TABLE
    , p6_a30 JTF_NUMBER_TABLE
    , p6_a31 JTF_NUMBER_TABLE
    , p6_a32 JTF_NUMBER_TABLE
    , p6_a33 JTF_NUMBER_TABLE
    , p6_a34 JTF_DATE_TABLE
    , p6_a35 JTF_VARCHAR2_TABLE_100
    , p6_a36 JTF_DATE_TABLE
    , p6_a37 JTF_VARCHAR2_TABLE_300
    , p6_a38 JTF_NUMBER_TABLE
    , p6_a39 JTF_NUMBER_TABLE
    , p6_a40 JTF_NUMBER_TABLE
    , p6_a41 JTF_VARCHAR2_TABLE_100
    , p6_a42 JTF_DATE_TABLE
    , p6_a43 JTF_NUMBER_TABLE
    , p6_a44 JTF_NUMBER_TABLE
    , p6_a45 JTF_DATE_TABLE
    , p6_a46 JTF_NUMBER_TABLE
    , p6_a47 JTF_DATE_TABLE
    , p6_a48 JTF_DATE_TABLE
    , p6_a49 JTF_DATE_TABLE
    , p6_a50 JTF_NUMBER_TABLE
    , p6_a51 JTF_NUMBER_TABLE
    , p6_a52 JTF_VARCHAR2_TABLE_100
    , p6_a53 JTF_NUMBER_TABLE
    , p6_a54 JTF_NUMBER_TABLE
    , p6_a55 JTF_VARCHAR2_TABLE_100
    , p6_a56 JTF_VARCHAR2_TABLE_100
    , p6_a57 JTF_NUMBER_TABLE
    , p6_a58 JTF_DATE_TABLE
    , p6_a59 JTF_NUMBER_TABLE
    , p6_a60 JTF_VARCHAR2_TABLE_100
    , p6_a61 JTF_VARCHAR2_TABLE_500
    , p6_a62 JTF_VARCHAR2_TABLE_500
    , p6_a63 JTF_VARCHAR2_TABLE_500
    , p6_a64 JTF_VARCHAR2_TABLE_500
    , p6_a65 JTF_VARCHAR2_TABLE_500
    , p6_a66 JTF_VARCHAR2_TABLE_500
    , p6_a67 JTF_VARCHAR2_TABLE_500
    , p6_a68 JTF_VARCHAR2_TABLE_500
    , p6_a69 JTF_VARCHAR2_TABLE_500
    , p6_a70 JTF_VARCHAR2_TABLE_500
    , p6_a71 JTF_VARCHAR2_TABLE_500
    , p6_a72 JTF_VARCHAR2_TABLE_500
    , p6_a73 JTF_VARCHAR2_TABLE_500
    , p6_a74 JTF_VARCHAR2_TABLE_500
    , p6_a75 JTF_VARCHAR2_TABLE_500
    , p6_a76 JTF_NUMBER_TABLE
    , p6_a77 JTF_NUMBER_TABLE
    , p6_a78 JTF_NUMBER_TABLE
    , p6_a79 JTF_DATE_TABLE
    , p6_a80 JTF_NUMBER_TABLE
    , p6_a81 JTF_DATE_TABLE
    , p6_a82 JTF_NUMBER_TABLE
    , p6_a83 JTF_DATE_TABLE
    , p6_a84 JTF_DATE_TABLE
    , p6_a85 JTF_DATE_TABLE
    , p6_a86 JTF_DATE_TABLE
    , p6_a87 JTF_NUMBER_TABLE
    , p6_a88 JTF_NUMBER_TABLE
    , p6_a89 JTF_NUMBER_TABLE
    , p6_a90 JTF_VARCHAR2_TABLE_100
    , p6_a91 JTF_NUMBER_TABLE
    , p6_a92 JTF_VARCHAR2_TABLE_100
    , p6_a93 JTF_NUMBER_TABLE
    , p6_a94 JTF_NUMBER_TABLE
    , p6_a95 JTF_DATE_TABLE
    , p6_a96 JTF_VARCHAR2_TABLE_100
    , p6_a97 JTF_VARCHAR2_TABLE_100
    , p6_a98 JTF_NUMBER_TABLE
    , p7_a0 out nocopy JTF_NUMBER_TABLE
    , p7_a1 out nocopy JTF_NUMBER_TABLE
    , p7_a2 out nocopy JTF_NUMBER_TABLE
    , p7_a3 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a5 out nocopy JTF_NUMBER_TABLE
    , p7_a6 out nocopy JTF_NUMBER_TABLE
    , p7_a7 out nocopy JTF_VARCHAR2_TABLE_2000
    , p7_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a9 out nocopy JTF_DATE_TABLE
    , p8_a0 out nocopy JTF_NUMBER_TABLE
    , p8_a1 out nocopy JTF_NUMBER_TABLE
    , p8_a2 out nocopy JTF_NUMBER_TABLE
    , p8_a3 out nocopy JTF_NUMBER_TABLE
    , p8_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a7 out nocopy JTF_NUMBER_TABLE
    , p8_a8 out nocopy JTF_NUMBER_TABLE
    , p8_a9 out nocopy JTF_DATE_TABLE
    , p8_a10 out nocopy JTF_NUMBER_TABLE
    , p8_a11 out nocopy JTF_NUMBER_TABLE
    , p8_a12 out nocopy JTF_NUMBER_TABLE
    , p8_a13 out nocopy JTF_NUMBER_TABLE
    , p8_a14 out nocopy JTF_NUMBER_TABLE
    , p8_a15 out nocopy JTF_NUMBER_TABLE
    , p8_a16 out nocopy JTF_NUMBER_TABLE
    , p8_a17 out nocopy JTF_NUMBER_TABLE
    , p8_a18 out nocopy JTF_NUMBER_TABLE
    , p8_a19 out nocopy JTF_NUMBER_TABLE
    , p8_a20 out nocopy JTF_DATE_TABLE
    , p8_a21 out nocopy JTF_DATE_TABLE
    , p8_a22 out nocopy JTF_NUMBER_TABLE
    , p8_a23 out nocopy JTF_NUMBER_TABLE
    , p8_a24 out nocopy JTF_DATE_TABLE
    , p8_a25 out nocopy JTF_DATE_TABLE
    , p8_a26 out nocopy JTF_DATE_TABLE
    , p8_a27 out nocopy JTF_NUMBER_TABLE
    , p8_a28 out nocopy JTF_NUMBER_TABLE
    , p8_a29 out nocopy JTF_NUMBER_TABLE
    , p8_a30 out nocopy JTF_NUMBER_TABLE
    , p8_a31 out nocopy JTF_NUMBER_TABLE
    , p8_a32 out nocopy JTF_NUMBER_TABLE
    , p8_a33 out nocopy JTF_NUMBER_TABLE
    , p8_a34 out nocopy JTF_DATE_TABLE
    , p8_a35 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a36 out nocopy JTF_DATE_TABLE
    , p8_a37 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a38 out nocopy JTF_NUMBER_TABLE
    , p8_a39 out nocopy JTF_NUMBER_TABLE
    , p8_a40 out nocopy JTF_NUMBER_TABLE
    , p8_a41 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a42 out nocopy JTF_DATE_TABLE
    , p8_a43 out nocopy JTF_NUMBER_TABLE
    , p8_a44 out nocopy JTF_NUMBER_TABLE
    , p8_a45 out nocopy JTF_DATE_TABLE
    , p8_a46 out nocopy JTF_NUMBER_TABLE
    , p8_a47 out nocopy JTF_DATE_TABLE
    , p8_a48 out nocopy JTF_DATE_TABLE
    , p8_a49 out nocopy JTF_DATE_TABLE
    , p8_a50 out nocopy JTF_NUMBER_TABLE
    , p8_a51 out nocopy JTF_NUMBER_TABLE
    , p8_a52 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a53 out nocopy JTF_NUMBER_TABLE
    , p8_a54 out nocopy JTF_NUMBER_TABLE
    , p8_a55 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a56 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a57 out nocopy JTF_NUMBER_TABLE
    , p8_a58 out nocopy JTF_DATE_TABLE
    , p8_a59 out nocopy JTF_NUMBER_TABLE
    , p8_a60 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a61 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a62 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a63 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a64 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a65 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a66 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a67 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a68 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a69 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a70 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a71 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a72 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a73 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a74 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a75 out nocopy JTF_VARCHAR2_TABLE_500
    , p8_a76 out nocopy JTF_NUMBER_TABLE
    , p8_a77 out nocopy JTF_NUMBER_TABLE
    , p8_a78 out nocopy JTF_NUMBER_TABLE
    , p8_a79 out nocopy JTF_DATE_TABLE
    , p8_a80 out nocopy JTF_NUMBER_TABLE
    , p8_a81 out nocopy JTF_DATE_TABLE
    , p8_a82 out nocopy JTF_NUMBER_TABLE
    , p8_a83 out nocopy JTF_DATE_TABLE
    , p8_a84 out nocopy JTF_DATE_TABLE
    , p8_a85 out nocopy JTF_DATE_TABLE
    , p8_a86 out nocopy JTF_DATE_TABLE
    , p8_a87 out nocopy JTF_NUMBER_TABLE
    , p8_a88 out nocopy JTF_NUMBER_TABLE
    , p8_a89 out nocopy JTF_NUMBER_TABLE
    , p8_a90 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a91 out nocopy JTF_NUMBER_TABLE
    , p8_a92 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a93 out nocopy JTF_NUMBER_TABLE
    , p8_a94 out nocopy JTF_NUMBER_TABLE
    , p8_a95 out nocopy JTF_DATE_TABLE
    , p8_a96 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a97 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a98 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_clev_tbl okl_credit_pub.clev_tbl_type;
    ddp_klev_tbl okl_credit_pub.klev_tbl_type;
    ddx_clev_tbl okl_credit_pub.clev_tbl_type;
    ddx_klev_tbl okl_credit_pub.klev_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_credit_pub_w.rosetta_table_copy_in_p5(ddp_clev_tbl, p5_a0
      , p5_a1
      , p5_a2
      , p5_a3
      , p5_a4
      , p5_a5
      , p5_a6
      , p5_a7
      , p5_a8
      , p5_a9
      );

    okl_kle_pvt_w.rosetta_table_copy_in_p8(ddp_klev_tbl, p6_a0
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
      , p6_a63
      , p6_a64
      , p6_a65
      , p6_a66
      , p6_a67
      , p6_a68
      , p6_a69
      , p6_a70
      , p6_a71
      , p6_a72
      , p6_a73
      , p6_a74
      , p6_a75
      , p6_a76
      , p6_a77
      , p6_a78
      , p6_a79
      , p6_a80
      , p6_a81
      , p6_a82
      , p6_a83
      , p6_a84
      , p6_a85

      , p6_a86
      , p6_a87
      , p6_a88
      , p6_a89
      , p6_a90
      , p6_a91
      , p6_a92
      , p6_a93
      , p6_a94
      , p6_a95
      , p6_a96
      , p6_a97
      , p6_a98
      );



    -- here's the delegated call to the old PL/SQL routine
    okl_credit_pub.update_credit_limit(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_clev_tbl,
      ddp_klev_tbl,
      ddx_clev_tbl,
      ddx_klev_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







    okl_credit_pub_w.rosetta_table_copy_out_p5(ddx_clev_tbl, p7_a0
      , p7_a1
      , p7_a2
      , p7_a3
      , p7_a4
      , p7_a5
      , p7_a6
      , p7_a7
      , p7_a8
      , p7_a9
      );

    okl_kle_pvt_w.rosetta_table_copy_out_p8(ddx_klev_tbl, p8_a0
      , p8_a1
      , p8_a2
      , p8_a3
      , p8_a4
      , p8_a5
      , p8_a6
      , p8_a7
      , p8_a8
      , p8_a9
      , p8_a10
      , p8_a11
      , p8_a12
      , p8_a13
      , p8_a14
      , p8_a15
      , p8_a16
      , p8_a17
      , p8_a18
      , p8_a19
      , p8_a20
      , p8_a21
      , p8_a22
      , p8_a23
      , p8_a24
      , p8_a25
      , p8_a26
      , p8_a27
      , p8_a28
      , p8_a29
      , p8_a30
      , p8_a31
      , p8_a32
      , p8_a33
      , p8_a34
      , p8_a35
      , p8_a36
      , p8_a37
      , p8_a38
      , p8_a39
      , p8_a40
      , p8_a41
      , p8_a42
      , p8_a43
      , p8_a44
      , p8_a45
      , p8_a46
      , p8_a47
      , p8_a48
      , p8_a49
      , p8_a50
      , p8_a51
      , p8_a52
      , p8_a53
      , p8_a54
      , p8_a55
      , p8_a56
      , p8_a57
      , p8_a58
      , p8_a59
      , p8_a60
      , p8_a61
      , p8_a62
      , p8_a63
      , p8_a64
      , p8_a65
      , p8_a66
      , p8_a67
      , p8_a68
      , p8_a69
      , p8_a70
      , p8_a71
      , p8_a72
      , p8_a73
      , p8_a74
      , p8_a75
      , p8_a76
      , p8_a77
      , p8_a78
      , p8_a79
      , p8_a80
      , p8_a81
      , p8_a82
      , p8_a83
      , p8_a84
      , p8_a85
      , p8_a86
      , p8_a87
      , p8_a88
      , p8_a89
      , p8_a90
      , p8_a91
      , p8_a92
      , p8_a93
      , p8_a94
      , p8_a95
      , p8_a96
      , p8_a97
      , p8_a98
      );
  end;

  procedure delete_credit_limit(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_VARCHAR2_TABLE_200
    , p5_a4 JTF_VARCHAR2_TABLE_100
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_VARCHAR2_TABLE_2000
    , p5_a8 JTF_VARCHAR2_TABLE_100
    , p5_a9 JTF_DATE_TABLE
    , p6_a0 JTF_NUMBER_TABLE
    , p6_a1 JTF_NUMBER_TABLE
    , p6_a2 JTF_NUMBER_TABLE
    , p6_a3 JTF_NUMBER_TABLE
    , p6_a4 JTF_VARCHAR2_TABLE_100
    , p6_a5 JTF_VARCHAR2_TABLE_100
    , p6_a6 JTF_VARCHAR2_TABLE_100
    , p6_a7 JTF_NUMBER_TABLE
    , p6_a8 JTF_NUMBER_TABLE
    , p6_a9 JTF_DATE_TABLE
    , p6_a10 JTF_NUMBER_TABLE
    , p6_a11 JTF_NUMBER_TABLE
    , p6_a12 JTF_NUMBER_TABLE
    , p6_a13 JTF_NUMBER_TABLE
    , p6_a14 JTF_NUMBER_TABLE
    , p6_a15 JTF_NUMBER_TABLE
    , p6_a16 JTF_NUMBER_TABLE
    , p6_a17 JTF_NUMBER_TABLE
    , p6_a18 JTF_NUMBER_TABLE
    , p6_a19 JTF_NUMBER_TABLE
    , p6_a20 JTF_DATE_TABLE
    , p6_a21 JTF_DATE_TABLE
    , p6_a22 JTF_NUMBER_TABLE
    , p6_a23 JTF_NUMBER_TABLE
    , p6_a24 JTF_DATE_TABLE
    , p6_a25 JTF_DATE_TABLE
    , p6_a26 JTF_DATE_TABLE
    , p6_a27 JTF_NUMBER_TABLE
    , p6_a28 JTF_NUMBER_TABLE
    , p6_a29 JTF_NUMBER_TABLE
    , p6_a30 JTF_NUMBER_TABLE
    , p6_a31 JTF_NUMBER_TABLE
    , p6_a32 JTF_NUMBER_TABLE
    , p6_a33 JTF_NUMBER_TABLE
    , p6_a34 JTF_DATE_TABLE
    , p6_a35 JTF_VARCHAR2_TABLE_100
    , p6_a36 JTF_DATE_TABLE
    , p6_a37 JTF_VARCHAR2_TABLE_300
    , p6_a38 JTF_NUMBER_TABLE
    , p6_a39 JTF_NUMBER_TABLE
    , p6_a40 JTF_NUMBER_TABLE
    , p6_a41 JTF_VARCHAR2_TABLE_100
    , p6_a42 JTF_DATE_TABLE
    , p6_a43 JTF_NUMBER_TABLE
    , p6_a44 JTF_NUMBER_TABLE
    , p6_a45 JTF_DATE_TABLE
    , p6_a46 JTF_NUMBER_TABLE
    , p6_a47 JTF_DATE_TABLE
    , p6_a48 JTF_DATE_TABLE
    , p6_a49 JTF_DATE_TABLE
    , p6_a50 JTF_NUMBER_TABLE
    , p6_a51 JTF_NUMBER_TABLE
    , p6_a52 JTF_VARCHAR2_TABLE_100
    , p6_a53 JTF_NUMBER_TABLE
    , p6_a54 JTF_NUMBER_TABLE
    , p6_a55 JTF_VARCHAR2_TABLE_100
    , p6_a56 JTF_VARCHAR2_TABLE_100
    , p6_a57 JTF_NUMBER_TABLE
    , p6_a58 JTF_DATE_TABLE
    , p6_a59 JTF_NUMBER_TABLE
    , p6_a60 JTF_VARCHAR2_TABLE_100
    , p6_a61 JTF_VARCHAR2_TABLE_500
    , p6_a62 JTF_VARCHAR2_TABLE_500
    , p6_a63 JTF_VARCHAR2_TABLE_500
    , p6_a64 JTF_VARCHAR2_TABLE_500
    , p6_a65 JTF_VARCHAR2_TABLE_500
    , p6_a66 JTF_VARCHAR2_TABLE_500
    , p6_a67 JTF_VARCHAR2_TABLE_500
    , p6_a68 JTF_VARCHAR2_TABLE_500
    , p6_a69 JTF_VARCHAR2_TABLE_500
    , p6_a70 JTF_VARCHAR2_TABLE_500
    , p6_a71 JTF_VARCHAR2_TABLE_500
    , p6_a72 JTF_VARCHAR2_TABLE_500
    , p6_a73 JTF_VARCHAR2_TABLE_500
    , p6_a74 JTF_VARCHAR2_TABLE_500
    , p6_a75 JTF_VARCHAR2_TABLE_500
    , p6_a76 JTF_NUMBER_TABLE
    , p6_a77 JTF_NUMBER_TABLE
    , p6_a78 JTF_NUMBER_TABLE
    , p6_a79 JTF_DATE_TABLE
    , p6_a80 JTF_NUMBER_TABLE
    , p6_a81 JTF_DATE_TABLE
    , p6_a82 JTF_NUMBER_TABLE
    , p6_a83 JTF_DATE_TABLE
    , p6_a84 JTF_DATE_TABLE
    , p6_a85 JTF_DATE_TABLE
    , p6_a86 JTF_DATE_TABLE
    , p6_a87 JTF_NUMBER_TABLE
    , p6_a88 JTF_NUMBER_TABLE
    , p6_a89 JTF_NUMBER_TABLE
    , p6_a90 JTF_VARCHAR2_TABLE_100
    , p6_a91 JTF_NUMBER_TABLE
    , p6_a92 JTF_VARCHAR2_TABLE_100
    , p6_a93 JTF_NUMBER_TABLE
    , p6_a94 JTF_NUMBER_TABLE
    , p6_a95 JTF_DATE_TABLE
    , p6_a96 JTF_VARCHAR2_TABLE_100
    , p6_a97 JTF_VARCHAR2_TABLE_100
    , p6_a98 JTF_NUMBER_TABLE
  )

  as
    ddp_clev_tbl okl_credit_pub.clev_tbl_type;
    ddp_klev_tbl okl_credit_pub.klev_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_credit_pub_w.rosetta_table_copy_in_p5(ddp_clev_tbl, p5_a0
      , p5_a1
      , p5_a2
      , p5_a3
      , p5_a4
      , p5_a5
      , p5_a6
      , p5_a7
      , p5_a8
      , p5_a9
      );

    okl_kle_pvt_w.rosetta_table_copy_in_p8(ddp_klev_tbl, p6_a0
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
      , p6_a63
      , p6_a64
      , p6_a65
      , p6_a66
      , p6_a67
      , p6_a68
      , p6_a69
      , p6_a70
      , p6_a71
      , p6_a72
      , p6_a73
      , p6_a74
      , p6_a75
      , p6_a76
      , p6_a77
      , p6_a78
      , p6_a79
      , p6_a80
      , p6_a81
      , p6_a82
      , p6_a83
      , p6_a84
      , p6_a85
      , p6_a86
      , p6_a87
      , p6_a88
      , p6_a89
      , p6_a90
      , p6_a91
      , p6_a92
      , p6_a93

      , p6_a94

      , p6_a95
      , p6_a96
      , p6_a97
      , p6_a98
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_credit_pub.delete_credit_limit(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_clev_tbl,
      ddp_klev_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






  end;

end okl_credit_pub_w;

/
