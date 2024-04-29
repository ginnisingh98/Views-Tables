--------------------------------------------------------
--  DDL for Package Body LNS_CUSTOM_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."LNS_CUSTOM_PUB_W" as
  /* $Header: LNS_CUST_PUBJ_B.pls 120.0.12010000.4 2010/03/19 08:33:10 gparuchu ship $ */
  procedure rosetta_table_copy_in_p1(t out nocopy lns_custom_pub.custom_tbl, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_DATE_TABLE
    , a4 JTF_DATE_TABLE
    , a5 JTF_DATE_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_NUMBER_TABLE
    , a14 JTF_NUMBER_TABLE
    , a15 JTF_NUMBER_TABLE
    , a16 JTF_VARCHAR2_TABLE_100
    , a17 JTF_VARCHAR2_TABLE_200
    , a18 JTF_VARCHAR2_TABLE_200
    , a19 JTF_VARCHAR2_TABLE_200
    , a20 JTF_VARCHAR2_TABLE_200
    , a21 JTF_VARCHAR2_TABLE_200
    , a22 JTF_VARCHAR2_TABLE_200
    , a23 JTF_VARCHAR2_TABLE_200
    , a24 JTF_VARCHAR2_TABLE_200
    , a25 JTF_VARCHAR2_TABLE_200
    , a26 JTF_VARCHAR2_TABLE_200
    , a27 JTF_VARCHAR2_TABLE_200
    , a28 JTF_VARCHAR2_TABLE_200
    , a29 JTF_VARCHAR2_TABLE_200
    , a30 JTF_VARCHAR2_TABLE_200
    , a31 JTF_VARCHAR2_TABLE_200
    , a32 JTF_VARCHAR2_TABLE_200
    , a33 JTF_VARCHAR2_TABLE_200
    , a34 JTF_VARCHAR2_TABLE_200
    , a35 JTF_VARCHAR2_TABLE_200
    , a36 JTF_VARCHAR2_TABLE_200
    , a37 JTF_NUMBER_TABLE
    , a38 JTF_NUMBER_TABLE
    , a39 JTF_NUMBER_TABLE
    , a40 JTF_NUMBER_TABLE
    , a41 JTF_NUMBER_TABLE
    , a42 JTF_NUMBER_TABLE
    , a43 JTF_NUMBER_TABLE
    , a44 JTF_NUMBER_TABLE
    , a45 JTF_VARCHAR2_TABLE_100
    , a46 JTF_VARCHAR2_TABLE_100
    , a47 JTF_VARCHAR2_TABLE_100
    , a48 JTF_NUMBER_TABLE
    , a49 JTF_VARCHAR2_TABLE_2000
    , a50 JTF_VARCHAR2_TABLE_2000
    , a51 JTF_VARCHAR2_TABLE_2000
    , a52 JTF_VARCHAR2_TABLE_2000
    , a53 JTF_NUMBER_TABLE
    , a54 JTF_VARCHAR2_TABLE_200
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).custom_schedule_id := a0(indx);
          t(ddindx).loan_id := a1(indx);
          t(ddindx).payment_number := a2(indx);
          t(ddindx).due_date := a3(indx);
          t(ddindx).period_start_date := a4(indx);
          t(ddindx).period_end_date := a5(indx);
          t(ddindx).principal_amount := a6(indx);
          t(ddindx).interest_amount := a7(indx);
          t(ddindx).normal_int_amount := a8(indx);
          t(ddindx).add_prin_int_amount := a9(indx);
          t(ddindx).add_int_int_amount := a10(indx);
          t(ddindx).penal_int_amount := a11(indx);
          t(ddindx).principal_balance := a12(indx);
          t(ddindx).fee_amount := a13(indx);
          t(ddindx).other_amount := a14(indx);
          t(ddindx).object_version_number := a15(indx);
          t(ddindx).attribute_category := a16(indx);
          t(ddindx).attribute1 := a17(indx);
          t(ddindx).attribute2 := a18(indx);
          t(ddindx).attribute3 := a19(indx);
          t(ddindx).attribute4 := a20(indx);
          t(ddindx).attribute5 := a21(indx);
          t(ddindx).attribute6 := a22(indx);
          t(ddindx).attribute7 := a23(indx);
          t(ddindx).attribute8 := a24(indx);
          t(ddindx).attribute9 := a25(indx);
          t(ddindx).attribute10 := a26(indx);
          t(ddindx).attribute11 := a27(indx);
          t(ddindx).attribute12 := a28(indx);
          t(ddindx).attribute13 := a29(indx);
          t(ddindx).attribute14 := a30(indx);
          t(ddindx).attribute15 := a31(indx);
          t(ddindx).attribute16 := a32(indx);
          t(ddindx).attribute17 := a33(indx);
          t(ddindx).attribute18 := a34(indx);
          t(ddindx).attribute19 := a35(indx);
          t(ddindx).attribute20 := a36(indx);
          t(ddindx).current_term_payment := a37(indx);
          t(ddindx).installment_begin_balance := a38(indx);
          t(ddindx).installment_end_balance := a39(indx);
          t(ddindx).principal_paid_todate := a40(indx);
          t(ddindx).interest_paid_todate := a41(indx);
          t(ddindx).interest_rate := a42(indx);
          t(ddindx).unpaid_prin := a43(indx);
          t(ddindx).unpaid_int := a44(indx);
          t(ddindx).lock_prin := a45(indx);
          t(ddindx).lock_int := a46(indx);
          t(ddindx).action := a47(indx);
          t(ddindx).funded_amount := a48(indx);
          t(ddindx).normal_int_details := a49(indx);
          t(ddindx).add_prin_int_details := a50(indx);
          t(ddindx).add_int_int_details := a51(indx);
          t(ddindx).penal_int_details := a52(indx);
          t(ddindx).disbursement_amount := a53(indx);
          t(ddindx).period := a54(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p1;
  procedure rosetta_table_copy_out_p1(t lns_custom_pub.custom_tbl, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_DATE_TABLE
    , a4 out nocopy JTF_DATE_TABLE
    , a5 out nocopy JTF_DATE_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_NUMBER_TABLE
    , a12 out nocopy JTF_NUMBER_TABLE
    , a13 out nocopy JTF_NUMBER_TABLE
    , a14 out nocopy JTF_NUMBER_TABLE
    , a15 out nocopy JTF_NUMBER_TABLE
    , a16 out nocopy JTF_VARCHAR2_TABLE_100
    , a17 out nocopy JTF_VARCHAR2_TABLE_200
    , a18 out nocopy JTF_VARCHAR2_TABLE_200
    , a19 out nocopy JTF_VARCHAR2_TABLE_200
    , a20 out nocopy JTF_VARCHAR2_TABLE_200
    , a21 out nocopy JTF_VARCHAR2_TABLE_200
    , a22 out nocopy JTF_VARCHAR2_TABLE_200
    , a23 out nocopy JTF_VARCHAR2_TABLE_200
    , a24 out nocopy JTF_VARCHAR2_TABLE_200
    , a25 out nocopy JTF_VARCHAR2_TABLE_200
    , a26 out nocopy JTF_VARCHAR2_TABLE_200
    , a27 out nocopy JTF_VARCHAR2_TABLE_200
    , a28 out nocopy JTF_VARCHAR2_TABLE_200
    , a29 out nocopy JTF_VARCHAR2_TABLE_200
    , a30 out nocopy JTF_VARCHAR2_TABLE_200
    , a31 out nocopy JTF_VARCHAR2_TABLE_200
    , a32 out nocopy JTF_VARCHAR2_TABLE_200
    , a33 out nocopy JTF_VARCHAR2_TABLE_200
    , a34 out nocopy JTF_VARCHAR2_TABLE_200
    , a35 out nocopy JTF_VARCHAR2_TABLE_200
    , a36 out nocopy JTF_VARCHAR2_TABLE_200
    , a37 out nocopy JTF_NUMBER_TABLE
    , a38 out nocopy JTF_NUMBER_TABLE
    , a39 out nocopy JTF_NUMBER_TABLE
    , a40 out nocopy JTF_NUMBER_TABLE
    , a41 out nocopy JTF_NUMBER_TABLE
    , a42 out nocopy JTF_NUMBER_TABLE
    , a43 out nocopy JTF_NUMBER_TABLE
    , a44 out nocopy JTF_NUMBER_TABLE
    , a45 out nocopy JTF_VARCHAR2_TABLE_100
    , a46 out nocopy JTF_VARCHAR2_TABLE_100
    , a47 out nocopy JTF_VARCHAR2_TABLE_100
    , a48 out nocopy JTF_NUMBER_TABLE
    , a49 out nocopy JTF_VARCHAR2_TABLE_2000
    , a50 out nocopy JTF_VARCHAR2_TABLE_2000
    , a51 out nocopy JTF_VARCHAR2_TABLE_2000
    , a52 out nocopy JTF_VARCHAR2_TABLE_2000
    , a53 out nocopy JTF_NUMBER_TABLE
    , a54 out nocopy JTF_VARCHAR2_TABLE_200
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_DATE_TABLE();
    a4 := JTF_DATE_TABLE();
    a5 := JTF_DATE_TABLE();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_NUMBER_TABLE();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_NUMBER_TABLE();
    a11 := JTF_NUMBER_TABLE();
    a12 := JTF_NUMBER_TABLE();
    a13 := JTF_NUMBER_TABLE();
    a14 := JTF_NUMBER_TABLE();
    a15 := JTF_NUMBER_TABLE();
    a16 := JTF_VARCHAR2_TABLE_100();
    a17 := JTF_VARCHAR2_TABLE_200();
    a18 := JTF_VARCHAR2_TABLE_200();
    a19 := JTF_VARCHAR2_TABLE_200();
    a20 := JTF_VARCHAR2_TABLE_200();
    a21 := JTF_VARCHAR2_TABLE_200();
    a22 := JTF_VARCHAR2_TABLE_200();
    a23 := JTF_VARCHAR2_TABLE_200();
    a24 := JTF_VARCHAR2_TABLE_200();
    a25 := JTF_VARCHAR2_TABLE_200();
    a26 := JTF_VARCHAR2_TABLE_200();
    a27 := JTF_VARCHAR2_TABLE_200();
    a28 := JTF_VARCHAR2_TABLE_200();
    a29 := JTF_VARCHAR2_TABLE_200();
    a30 := JTF_VARCHAR2_TABLE_200();
    a31 := JTF_VARCHAR2_TABLE_200();
    a32 := JTF_VARCHAR2_TABLE_200();
    a33 := JTF_VARCHAR2_TABLE_200();
    a34 := JTF_VARCHAR2_TABLE_200();
    a35 := JTF_VARCHAR2_TABLE_200();
    a36 := JTF_VARCHAR2_TABLE_200();
    a37 := JTF_NUMBER_TABLE();
    a38 := JTF_NUMBER_TABLE();
    a39 := JTF_NUMBER_TABLE();
    a40 := JTF_NUMBER_TABLE();
    a41 := JTF_NUMBER_TABLE();
    a42 := JTF_NUMBER_TABLE();
    a43 := JTF_NUMBER_TABLE();
    a44 := JTF_NUMBER_TABLE();
    a45 := JTF_VARCHAR2_TABLE_100();
    a46 := JTF_VARCHAR2_TABLE_100();
    a47 := JTF_VARCHAR2_TABLE_100();
    a48 := JTF_NUMBER_TABLE();
    a49 := JTF_VARCHAR2_TABLE_2000();
    a50 := JTF_VARCHAR2_TABLE_2000();
    a51 := JTF_VARCHAR2_TABLE_2000();
    a52 := JTF_VARCHAR2_TABLE_2000();
    a53 := JTF_NUMBER_TABLE();
    a54 := JTF_VARCHAR2_TABLE_200();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_DATE_TABLE();
      a4 := JTF_DATE_TABLE();
      a5 := JTF_DATE_TABLE();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_NUMBER_TABLE();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_NUMBER_TABLE();
      a11 := JTF_NUMBER_TABLE();
      a12 := JTF_NUMBER_TABLE();
      a13 := JTF_NUMBER_TABLE();
      a14 := JTF_NUMBER_TABLE();
      a15 := JTF_NUMBER_TABLE();
      a16 := JTF_VARCHAR2_TABLE_100();
      a17 := JTF_VARCHAR2_TABLE_200();
      a18 := JTF_VARCHAR2_TABLE_200();
      a19 := JTF_VARCHAR2_TABLE_200();
      a20 := JTF_VARCHAR2_TABLE_200();
      a21 := JTF_VARCHAR2_TABLE_200();
      a22 := JTF_VARCHAR2_TABLE_200();
      a23 := JTF_VARCHAR2_TABLE_200();
      a24 := JTF_VARCHAR2_TABLE_200();
      a25 := JTF_VARCHAR2_TABLE_200();
      a26 := JTF_VARCHAR2_TABLE_200();
      a27 := JTF_VARCHAR2_TABLE_200();
      a28 := JTF_VARCHAR2_TABLE_200();
      a29 := JTF_VARCHAR2_TABLE_200();
      a30 := JTF_VARCHAR2_TABLE_200();
      a31 := JTF_VARCHAR2_TABLE_200();
      a32 := JTF_VARCHAR2_TABLE_200();
      a33 := JTF_VARCHAR2_TABLE_200();
      a34 := JTF_VARCHAR2_TABLE_200();
      a35 := JTF_VARCHAR2_TABLE_200();
      a36 := JTF_VARCHAR2_TABLE_200();
      a37 := JTF_NUMBER_TABLE();
      a38 := JTF_NUMBER_TABLE();
      a39 := JTF_NUMBER_TABLE();
      a40 := JTF_NUMBER_TABLE();
      a41 := JTF_NUMBER_TABLE();
      a42 := JTF_NUMBER_TABLE();
      a43 := JTF_NUMBER_TABLE();
      a44 := JTF_NUMBER_TABLE();
      a45 := JTF_VARCHAR2_TABLE_100();
      a46 := JTF_VARCHAR2_TABLE_100();
      a47 := JTF_VARCHAR2_TABLE_100();
      a48 := JTF_NUMBER_TABLE();
      a49 := JTF_VARCHAR2_TABLE_2000();
      a50 := JTF_VARCHAR2_TABLE_2000();
      a51 := JTF_VARCHAR2_TABLE_2000();
      a52 := JTF_VARCHAR2_TABLE_2000();
      a53 := JTF_NUMBER_TABLE();
      a54 := JTF_VARCHAR2_TABLE_200();
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
        a38.extend(t.count);
        a39.extend(t.count);
        a40.extend(t.count);
        a41.extend(t.count);
        a42.extend(t.count);
        a43.extend(t.count);
        a44.extend(t.count);
        a45.extend(t.count);
        a46.extend(t.count);
        a47.extend(t.count);
        a48.extend(t.count);
        a49.extend(t.count);
        a50.extend(t.count);
        a51.extend(t.count);
        a52.extend(t.count);
        a53.extend(t.count);
        a54.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).custom_schedule_id;
          a1(indx) := t(ddindx).loan_id;
          a2(indx) := t(ddindx).payment_number;
          a3(indx) := t(ddindx).due_date;
          a4(indx) := t(ddindx).period_start_date;
          a5(indx) := t(ddindx).period_end_date;
          a6(indx) := t(ddindx).principal_amount;
          a7(indx) := t(ddindx).interest_amount;
          a8(indx) := t(ddindx).normal_int_amount;
          a9(indx) := t(ddindx).add_prin_int_amount;
          a10(indx) := t(ddindx).add_int_int_amount;
          a11(indx) := t(ddindx).penal_int_amount;
          a12(indx) := t(ddindx).principal_balance;
          a13(indx) := t(ddindx).fee_amount;
          a14(indx) := t(ddindx).other_amount;
          a15(indx) := t(ddindx).object_version_number;
          a16(indx) := t(ddindx).attribute_category;
          a17(indx) := t(ddindx).attribute1;
          a18(indx) := t(ddindx).attribute2;
          a19(indx) := t(ddindx).attribute3;
          a20(indx) := t(ddindx).attribute4;
          a21(indx) := t(ddindx).attribute5;
          a22(indx) := t(ddindx).attribute6;
          a23(indx) := t(ddindx).attribute7;
          a24(indx) := t(ddindx).attribute8;
          a25(indx) := t(ddindx).attribute9;
          a26(indx) := t(ddindx).attribute10;
          a27(indx) := t(ddindx).attribute11;
          a28(indx) := t(ddindx).attribute12;
          a29(indx) := t(ddindx).attribute13;
          a30(indx) := t(ddindx).attribute14;
          a31(indx) := t(ddindx).attribute15;
          a32(indx) := t(ddindx).attribute16;
          a33(indx) := t(ddindx).attribute17;
          a34(indx) := t(ddindx).attribute18;
          a35(indx) := t(ddindx).attribute19;
          a36(indx) := t(ddindx).attribute20;
          a37(indx) := t(ddindx).current_term_payment;
          a38(indx) := t(ddindx).installment_begin_balance;
          a39(indx) := t(ddindx).installment_end_balance;
          a40(indx) := t(ddindx).principal_paid_todate;
          a41(indx) := t(ddindx).interest_paid_todate;
          a42(indx) := t(ddindx).interest_rate;
          a43(indx) := t(ddindx).unpaid_prin;
          a44(indx) := t(ddindx).unpaid_int;
          a45(indx) := t(ddindx).lock_prin;
          a46(indx) := t(ddindx).lock_int;
          a47(indx) := t(ddindx).action;
          a48(indx) := t(ddindx).funded_amount;
          a49(indx) := t(ddindx).normal_int_details;
          a50(indx) := t(ddindx).add_prin_int_details;
          a51(indx) := t(ddindx).add_int_int_details;
          a52(indx) := t(ddindx).penal_int_details;
          a53(indx) := t(ddindx).disbursement_amount;
          a54(indx) := t(ddindx).period;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p1;

  procedure resetcustomschedule(p_loan_id  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_update_header  number
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_update_header boolean;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    if p_update_header is null
      then ddp_update_header := null;
    elsif p_update_header = 0
      then ddp_update_header := false;
    else ddp_update_header := true;
    end if;




    -- here's the delegated call to the old PL/SQL routine
    lns_custom_pub.resetcustomschedule(p_loan_id,
      p_init_msg_list,
      p_commit,
      ddp_update_header,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






  end;

  procedure createcustomschedule(p0_a0 JTF_NUMBER_TABLE
    , p0_a1 JTF_NUMBER_TABLE
    , p0_a2 JTF_NUMBER_TABLE
    , p0_a3 JTF_DATE_TABLE
    , p0_a4 JTF_DATE_TABLE
    , p0_a5 JTF_DATE_TABLE
    , p0_a6 JTF_NUMBER_TABLE
    , p0_a7 JTF_NUMBER_TABLE
    , p0_a8 JTF_NUMBER_TABLE
    , p0_a9 JTF_NUMBER_TABLE
    , p0_a10 JTF_NUMBER_TABLE
    , p0_a11 JTF_NUMBER_TABLE
    , p0_a12 JTF_NUMBER_TABLE
    , p0_a13 JTF_NUMBER_TABLE
    , p0_a14 JTF_NUMBER_TABLE
    , p0_a15 JTF_NUMBER_TABLE
    , p0_a16 JTF_VARCHAR2_TABLE_100
    , p0_a17 JTF_VARCHAR2_TABLE_200
    , p0_a18 JTF_VARCHAR2_TABLE_200
    , p0_a19 JTF_VARCHAR2_TABLE_200
    , p0_a20 JTF_VARCHAR2_TABLE_200
    , p0_a21 JTF_VARCHAR2_TABLE_200
    , p0_a22 JTF_VARCHAR2_TABLE_200
    , p0_a23 JTF_VARCHAR2_TABLE_200
    , p0_a24 JTF_VARCHAR2_TABLE_200
    , p0_a25 JTF_VARCHAR2_TABLE_200
    , p0_a26 JTF_VARCHAR2_TABLE_200
    , p0_a27 JTF_VARCHAR2_TABLE_200
    , p0_a28 JTF_VARCHAR2_TABLE_200
    , p0_a29 JTF_VARCHAR2_TABLE_200
    , p0_a30 JTF_VARCHAR2_TABLE_200
    , p0_a31 JTF_VARCHAR2_TABLE_200
    , p0_a32 JTF_VARCHAR2_TABLE_200
    , p0_a33 JTF_VARCHAR2_TABLE_200
    , p0_a34 JTF_VARCHAR2_TABLE_200
    , p0_a35 JTF_VARCHAR2_TABLE_200
    , p0_a36 JTF_VARCHAR2_TABLE_200
    , p0_a37 JTF_NUMBER_TABLE
    , p0_a38 JTF_NUMBER_TABLE
    , p0_a39 JTF_NUMBER_TABLE
    , p0_a40 JTF_NUMBER_TABLE
    , p0_a41 JTF_NUMBER_TABLE
    , p0_a42 JTF_NUMBER_TABLE
    , p0_a43 JTF_NUMBER_TABLE
    , p0_a44 JTF_NUMBER_TABLE
    , p0_a45 JTF_VARCHAR2_TABLE_100
    , p0_a46 JTF_VARCHAR2_TABLE_100
    , p0_a47 JTF_VARCHAR2_TABLE_100
    , p0_a48 JTF_NUMBER_TABLE
    , p0_a49 JTF_VARCHAR2_TABLE_2000
    , p0_a50 JTF_VARCHAR2_TABLE_2000
    , p0_a51 JTF_VARCHAR2_TABLE_2000
    , p0_a52 JTF_VARCHAR2_TABLE_2000
    , p0_a53 JTF_NUMBER_TABLE
    , p0_a54 JTF_VARCHAR2_TABLE_200
    , p_loan_id  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_invalid_installment_num out nocopy  NUMBER
  )

  as
    ddp_custom_tbl lns_custom_pub.custom_tbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    lns_custom_pub_w.rosetta_table_copy_in_p1(ddp_custom_tbl, p0_a0
      , p0_a1
      , p0_a2
      , p0_a3
      , p0_a4
      , p0_a5
      , p0_a6
      , p0_a7
      , p0_a8
      , p0_a9
      , p0_a10
      , p0_a11
      , p0_a12
      , p0_a13
      , p0_a14
      , p0_a15
      , p0_a16
      , p0_a17
      , p0_a18
      , p0_a19
      , p0_a20
      , p0_a21
      , p0_a22
      , p0_a23
      , p0_a24
      , p0_a25
      , p0_a26
      , p0_a27
      , p0_a28
      , p0_a29
      , p0_a30
      , p0_a31
      , p0_a32
      , p0_a33
      , p0_a34
      , p0_a35
      , p0_a36
      , p0_a37
      , p0_a38
      , p0_a39
      , p0_a40
      , p0_a41
      , p0_a42
      , p0_a43
      , p0_a44
      , p0_a45
      , p0_a46
      , p0_a47
      , p0_a48
      , p0_a49
      , p0_a50
      , p0_a51
      , p0_a52
      , p0_a53
      , p0_a54
      );








    -- here's the delegated call to the old PL/SQL routine
    lns_custom_pub.createcustomschedule(ddp_custom_tbl,
      p_loan_id,
      p_init_msg_list,
      p_commit,
      x_return_status,
      x_msg_count,
      x_msg_data,
      x_invalid_installment_num);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

  procedure updatecustomschedule(p0_a0 JTF_NUMBER_TABLE
    , p0_a1 JTF_NUMBER_TABLE
    , p0_a2 JTF_NUMBER_TABLE
    , p0_a3 JTF_DATE_TABLE
    , p0_a4 JTF_DATE_TABLE
    , p0_a5 JTF_DATE_TABLE
    , p0_a6 JTF_NUMBER_TABLE
    , p0_a7 JTF_NUMBER_TABLE
    , p0_a8 JTF_NUMBER_TABLE
    , p0_a9 JTF_NUMBER_TABLE
    , p0_a10 JTF_NUMBER_TABLE
    , p0_a11 JTF_NUMBER_TABLE
    , p0_a12 JTF_NUMBER_TABLE
    , p0_a13 JTF_NUMBER_TABLE
    , p0_a14 JTF_NUMBER_TABLE
    , p0_a15 JTF_NUMBER_TABLE
    , p0_a16 JTF_VARCHAR2_TABLE_100
    , p0_a17 JTF_VARCHAR2_TABLE_200
    , p0_a18 JTF_VARCHAR2_TABLE_200
    , p0_a19 JTF_VARCHAR2_TABLE_200
    , p0_a20 JTF_VARCHAR2_TABLE_200
    , p0_a21 JTF_VARCHAR2_TABLE_200
    , p0_a22 JTF_VARCHAR2_TABLE_200
    , p0_a23 JTF_VARCHAR2_TABLE_200
    , p0_a24 JTF_VARCHAR2_TABLE_200
    , p0_a25 JTF_VARCHAR2_TABLE_200
    , p0_a26 JTF_VARCHAR2_TABLE_200
    , p0_a27 JTF_VARCHAR2_TABLE_200
    , p0_a28 JTF_VARCHAR2_TABLE_200
    , p0_a29 JTF_VARCHAR2_TABLE_200
    , p0_a30 JTF_VARCHAR2_TABLE_200
    , p0_a31 JTF_VARCHAR2_TABLE_200
    , p0_a32 JTF_VARCHAR2_TABLE_200
    , p0_a33 JTF_VARCHAR2_TABLE_200
    , p0_a34 JTF_VARCHAR2_TABLE_200
    , p0_a35 JTF_VARCHAR2_TABLE_200
    , p0_a36 JTF_VARCHAR2_TABLE_200
    , p0_a37 JTF_NUMBER_TABLE
    , p0_a38 JTF_NUMBER_TABLE
    , p0_a39 JTF_NUMBER_TABLE
    , p0_a40 JTF_NUMBER_TABLE
    , p0_a41 JTF_NUMBER_TABLE
    , p0_a42 JTF_NUMBER_TABLE
    , p0_a43 JTF_NUMBER_TABLE
    , p0_a44 JTF_NUMBER_TABLE
    , p0_a45 JTF_VARCHAR2_TABLE_100
    , p0_a46 JTF_VARCHAR2_TABLE_100
    , p0_a47 JTF_VARCHAR2_TABLE_100
    , p0_a48 JTF_NUMBER_TABLE
    , p0_a49 JTF_VARCHAR2_TABLE_2000
    , p0_a50 JTF_VARCHAR2_TABLE_2000
    , p0_a51 JTF_VARCHAR2_TABLE_2000
    , p0_a52 JTF_VARCHAR2_TABLE_2000
    , p0_a53 JTF_NUMBER_TABLE
    , p0_a54 JTF_VARCHAR2_TABLE_200
    , p_loan_id  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_invalid_installment_num out nocopy  NUMBER
  )

  as
    ddp_custom_tbl lns_custom_pub.custom_tbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    lns_custom_pub_w.rosetta_table_copy_in_p1(ddp_custom_tbl, p0_a0
      , p0_a1
      , p0_a2
      , p0_a3
      , p0_a4
      , p0_a5
      , p0_a6
      , p0_a7
      , p0_a8
      , p0_a9
      , p0_a10
      , p0_a11
      , p0_a12
      , p0_a13
      , p0_a14
      , p0_a15
      , p0_a16
      , p0_a17
      , p0_a18
      , p0_a19
      , p0_a20
      , p0_a21
      , p0_a22
      , p0_a23
      , p0_a24
      , p0_a25
      , p0_a26
      , p0_a27
      , p0_a28
      , p0_a29
      , p0_a30
      , p0_a31
      , p0_a32
      , p0_a33
      , p0_a34
      , p0_a35
      , p0_a36
      , p0_a37
      , p0_a38
      , p0_a39
      , p0_a40
      , p0_a41
      , p0_a42
      , p0_a43
      , p0_a44
      , p0_a45
      , p0_a46
      , p0_a47
      , p0_a48
      , p0_a49
      , p0_a50
      , p0_a51
      , p0_a52
      , p0_a53
      , p0_a54
      );








    -- here's the delegated call to the old PL/SQL routine
    lns_custom_pub.updatecustomschedule(ddp_custom_tbl,
      p_loan_id,
      p_init_msg_list,
      p_commit,
      x_return_status,
      x_msg_count,
      x_msg_data,
      x_invalid_installment_num);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

  procedure createcustomsched(p0_a0  NUMBER
    , p0_a1  NUMBER
    , p0_a2  NUMBER
    , p0_a3  DATE
    , p0_a4  DATE
    , p0_a5  DATE
    , p0_a6  NUMBER
    , p0_a7  NUMBER
    , p0_a8  NUMBER
    , p0_a9  NUMBER
    , p0_a10  NUMBER
    , p0_a11  NUMBER
    , p0_a12  NUMBER
    , p0_a13  NUMBER
    , p0_a14  NUMBER
    , p0_a15  NUMBER
    , p0_a16  VARCHAR2
    , p0_a17  VARCHAR2
    , p0_a18  VARCHAR2
    , p0_a19  VARCHAR2
    , p0_a20  VARCHAR2
    , p0_a21  VARCHAR2
    , p0_a22  VARCHAR2
    , p0_a23  VARCHAR2
    , p0_a24  VARCHAR2
    , p0_a25  VARCHAR2
    , p0_a26  VARCHAR2
    , p0_a27  VARCHAR2
    , p0_a28  VARCHAR2
    , p0_a29  VARCHAR2
    , p0_a30  VARCHAR2
    , p0_a31  VARCHAR2
    , p0_a32  VARCHAR2
    , p0_a33  VARCHAR2
    , p0_a34  VARCHAR2
    , p0_a35  VARCHAR2
    , p0_a36  VARCHAR2
    , p0_a37  NUMBER
    , p0_a38  NUMBER
    , p0_a39  NUMBER
    , p0_a40  NUMBER
    , p0_a41  NUMBER
    , p0_a42  NUMBER
    , p0_a43  NUMBER
    , p0_a44  NUMBER
    , p0_a45  VARCHAR2
    , p0_a46  VARCHAR2
    , p0_a47  VARCHAR2
    , p0_a48  NUMBER
    , p0_a49  VARCHAR2
    , p0_a50  VARCHAR2
    , p0_a51  VARCHAR2
    , p0_a52  VARCHAR2
    , p0_a53  NUMBER
    , p0_a54  VARCHAR2
    , x_custom_sched_id out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_custom_rec lns_custom_pub.custom_sched_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_custom_rec.custom_schedule_id := p0_a0;
    ddp_custom_rec.loan_id := p0_a1;
    ddp_custom_rec.payment_number := p0_a2;
    ddp_custom_rec.due_date := p0_a3;
    ddp_custom_rec.period_start_date := p0_a4;
    ddp_custom_rec.period_end_date := p0_a5;
    ddp_custom_rec.principal_amount := p0_a6;
    ddp_custom_rec.interest_amount := p0_a7;
    ddp_custom_rec.normal_int_amount := p0_a8;
    ddp_custom_rec.add_prin_int_amount := p0_a9;
    ddp_custom_rec.add_int_int_amount := p0_a10;
    ddp_custom_rec.penal_int_amount := p0_a11;
    ddp_custom_rec.principal_balance := p0_a12;
    ddp_custom_rec.fee_amount := p0_a13;
    ddp_custom_rec.other_amount := p0_a14;
    ddp_custom_rec.object_version_number := p0_a15;
    ddp_custom_rec.attribute_category := p0_a16;
    ddp_custom_rec.attribute1 := p0_a17;
    ddp_custom_rec.attribute2 := p0_a18;
    ddp_custom_rec.attribute3 := p0_a19;
    ddp_custom_rec.attribute4 := p0_a20;
    ddp_custom_rec.attribute5 := p0_a21;
    ddp_custom_rec.attribute6 := p0_a22;
    ddp_custom_rec.attribute7 := p0_a23;
    ddp_custom_rec.attribute8 := p0_a24;
    ddp_custom_rec.attribute9 := p0_a25;
    ddp_custom_rec.attribute10 := p0_a26;
    ddp_custom_rec.attribute11 := p0_a27;
    ddp_custom_rec.attribute12 := p0_a28;
    ddp_custom_rec.attribute13 := p0_a29;
    ddp_custom_rec.attribute14 := p0_a30;
    ddp_custom_rec.attribute15 := p0_a31;
    ddp_custom_rec.attribute16 := p0_a32;
    ddp_custom_rec.attribute17 := p0_a33;
    ddp_custom_rec.attribute18 := p0_a34;
    ddp_custom_rec.attribute19 := p0_a35;
    ddp_custom_rec.attribute20 := p0_a36;
    ddp_custom_rec.current_term_payment := p0_a37;
    ddp_custom_rec.installment_begin_balance := p0_a38;
    ddp_custom_rec.installment_end_balance := p0_a39;
    ddp_custom_rec.principal_paid_todate := p0_a40;
    ddp_custom_rec.interest_paid_todate := p0_a41;
    ddp_custom_rec.interest_rate := p0_a42;
    ddp_custom_rec.unpaid_prin := p0_a43;
    ddp_custom_rec.unpaid_int := p0_a44;
    ddp_custom_rec.lock_prin := p0_a45;
    ddp_custom_rec.lock_int := p0_a46;
    ddp_custom_rec.action := p0_a47;
    ddp_custom_rec.funded_amount := p0_a48;
    ddp_custom_rec.normal_int_details := p0_a49;
    ddp_custom_rec.add_prin_int_details := p0_a50;
    ddp_custom_rec.add_int_int_details := p0_a51;
    ddp_custom_rec.penal_int_details := p0_a52;
    ddp_custom_rec.disbursement_amount := p0_a53;
    ddp_custom_rec.period := p0_a54;





    -- here's the delegated call to the old PL/SQL routine
    lns_custom_pub.createcustomsched(ddp_custom_rec,
      x_custom_sched_id,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any




  end;

  procedure updatecustomsched(p0_a0  NUMBER
    , p0_a1  NUMBER
    , p0_a2  NUMBER
    , p0_a3  DATE
    , p0_a4  DATE
    , p0_a5  DATE
    , p0_a6  NUMBER
    , p0_a7  NUMBER
    , p0_a8  NUMBER
    , p0_a9  NUMBER
    , p0_a10  NUMBER
    , p0_a11  NUMBER
    , p0_a12  NUMBER
    , p0_a13  NUMBER
    , p0_a14  NUMBER
    , p0_a15  NUMBER
    , p0_a16  VARCHAR2
    , p0_a17  VARCHAR2
    , p0_a18  VARCHAR2
    , p0_a19  VARCHAR2
    , p0_a20  VARCHAR2
    , p0_a21  VARCHAR2
    , p0_a22  VARCHAR2
    , p0_a23  VARCHAR2
    , p0_a24  VARCHAR2
    , p0_a25  VARCHAR2
    , p0_a26  VARCHAR2
    , p0_a27  VARCHAR2
    , p0_a28  VARCHAR2
    , p0_a29  VARCHAR2
    , p0_a30  VARCHAR2
    , p0_a31  VARCHAR2
    , p0_a32  VARCHAR2
    , p0_a33  VARCHAR2
    , p0_a34  VARCHAR2
    , p0_a35  VARCHAR2
    , p0_a36  VARCHAR2
    , p0_a37  NUMBER
    , p0_a38  NUMBER
    , p0_a39  NUMBER
    , p0_a40  NUMBER
    , p0_a41  NUMBER
    , p0_a42  NUMBER
    , p0_a43  NUMBER
    , p0_a44  NUMBER
    , p0_a45  VARCHAR2
    , p0_a46  VARCHAR2
    , p0_a47  VARCHAR2
    , p0_a48  NUMBER
    , p0_a49  VARCHAR2
    , p0_a50  VARCHAR2
    , p0_a51  VARCHAR2
    , p0_a52  VARCHAR2
    , p0_a53  NUMBER
    , p0_a54  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_custom_rec lns_custom_pub.custom_sched_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_custom_rec.custom_schedule_id := p0_a0;
    ddp_custom_rec.loan_id := p0_a1;
    ddp_custom_rec.payment_number := p0_a2;
    ddp_custom_rec.due_date := p0_a3;
    ddp_custom_rec.period_start_date := p0_a4;
    ddp_custom_rec.period_end_date := p0_a5;
    ddp_custom_rec.principal_amount := p0_a6;
    ddp_custom_rec.interest_amount := p0_a7;
    ddp_custom_rec.normal_int_amount := p0_a8;
    ddp_custom_rec.add_prin_int_amount := p0_a9;
    ddp_custom_rec.add_int_int_amount := p0_a10;
    ddp_custom_rec.penal_int_amount := p0_a11;
    ddp_custom_rec.principal_balance := p0_a12;
    ddp_custom_rec.fee_amount := p0_a13;
    ddp_custom_rec.other_amount := p0_a14;
    ddp_custom_rec.object_version_number := p0_a15;
    ddp_custom_rec.attribute_category := p0_a16;
    ddp_custom_rec.attribute1 := p0_a17;
    ddp_custom_rec.attribute2 := p0_a18;
    ddp_custom_rec.attribute3 := p0_a19;
    ddp_custom_rec.attribute4 := p0_a20;
    ddp_custom_rec.attribute5 := p0_a21;
    ddp_custom_rec.attribute6 := p0_a22;
    ddp_custom_rec.attribute7 := p0_a23;
    ddp_custom_rec.attribute8 := p0_a24;
    ddp_custom_rec.attribute9 := p0_a25;
    ddp_custom_rec.attribute10 := p0_a26;
    ddp_custom_rec.attribute11 := p0_a27;
    ddp_custom_rec.attribute12 := p0_a28;
    ddp_custom_rec.attribute13 := p0_a29;
    ddp_custom_rec.attribute14 := p0_a30;
    ddp_custom_rec.attribute15 := p0_a31;
    ddp_custom_rec.attribute16 := p0_a32;
    ddp_custom_rec.attribute17 := p0_a33;
    ddp_custom_rec.attribute18 := p0_a34;
    ddp_custom_rec.attribute19 := p0_a35;
    ddp_custom_rec.attribute20 := p0_a36;
    ddp_custom_rec.current_term_payment := p0_a37;
    ddp_custom_rec.installment_begin_balance := p0_a38;
    ddp_custom_rec.installment_end_balance := p0_a39;
    ddp_custom_rec.principal_paid_todate := p0_a40;
    ddp_custom_rec.interest_paid_todate := p0_a41;
    ddp_custom_rec.interest_rate := p0_a42;
    ddp_custom_rec.unpaid_prin := p0_a43;
    ddp_custom_rec.unpaid_int := p0_a44;
    ddp_custom_rec.lock_prin := p0_a45;
    ddp_custom_rec.lock_int := p0_a46;
    ddp_custom_rec.action := p0_a47;
    ddp_custom_rec.funded_amount := p0_a48;
    ddp_custom_rec.normal_int_details := p0_a49;
    ddp_custom_rec.add_prin_int_details := p0_a50;
    ddp_custom_rec.add_int_int_details := p0_a51;
    ddp_custom_rec.penal_int_details := p0_a52;
    ddp_custom_rec.disbursement_amount := p0_a53;
    ddp_custom_rec.period := p0_a54;




    -- here's the delegated call to the old PL/SQL routine
    lns_custom_pub.updatecustomsched(ddp_custom_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any



  end;

  procedure validatecustomtable(p0_a0 JTF_NUMBER_TABLE
    , p0_a1 JTF_NUMBER_TABLE
    , p0_a2 JTF_NUMBER_TABLE
    , p0_a3 JTF_DATE_TABLE
    , p0_a4 JTF_DATE_TABLE
    , p0_a5 JTF_DATE_TABLE
    , p0_a6 JTF_NUMBER_TABLE
    , p0_a7 JTF_NUMBER_TABLE
    , p0_a8 JTF_NUMBER_TABLE
    , p0_a9 JTF_NUMBER_TABLE
    , p0_a10 JTF_NUMBER_TABLE
    , p0_a11 JTF_NUMBER_TABLE
    , p0_a12 JTF_NUMBER_TABLE
    , p0_a13 JTF_NUMBER_TABLE
    , p0_a14 JTF_NUMBER_TABLE
    , p0_a15 JTF_NUMBER_TABLE
    , p0_a16 JTF_VARCHAR2_TABLE_100
    , p0_a17 JTF_VARCHAR2_TABLE_200
    , p0_a18 JTF_VARCHAR2_TABLE_200
    , p0_a19 JTF_VARCHAR2_TABLE_200
    , p0_a20 JTF_VARCHAR2_TABLE_200
    , p0_a21 JTF_VARCHAR2_TABLE_200
    , p0_a22 JTF_VARCHAR2_TABLE_200
    , p0_a23 JTF_VARCHAR2_TABLE_200
    , p0_a24 JTF_VARCHAR2_TABLE_200
    , p0_a25 JTF_VARCHAR2_TABLE_200
    , p0_a26 JTF_VARCHAR2_TABLE_200
    , p0_a27 JTF_VARCHAR2_TABLE_200
    , p0_a28 JTF_VARCHAR2_TABLE_200
    , p0_a29 JTF_VARCHAR2_TABLE_200
    , p0_a30 JTF_VARCHAR2_TABLE_200
    , p0_a31 JTF_VARCHAR2_TABLE_200
    , p0_a32 JTF_VARCHAR2_TABLE_200
    , p0_a33 JTF_VARCHAR2_TABLE_200
    , p0_a34 JTF_VARCHAR2_TABLE_200
    , p0_a35 JTF_VARCHAR2_TABLE_200
    , p0_a36 JTF_VARCHAR2_TABLE_200
    , p0_a37 JTF_NUMBER_TABLE
    , p0_a38 JTF_NUMBER_TABLE
    , p0_a39 JTF_NUMBER_TABLE
    , p0_a40 JTF_NUMBER_TABLE
    , p0_a41 JTF_NUMBER_TABLE
    , p0_a42 JTF_NUMBER_TABLE
    , p0_a43 JTF_NUMBER_TABLE
    , p0_a44 JTF_NUMBER_TABLE
    , p0_a45 JTF_VARCHAR2_TABLE_100
    , p0_a46 JTF_VARCHAR2_TABLE_100
    , p0_a47 JTF_VARCHAR2_TABLE_100
    , p0_a48 JTF_NUMBER_TABLE
    , p0_a49 JTF_VARCHAR2_TABLE_2000
    , p0_a50 JTF_VARCHAR2_TABLE_2000
    , p0_a51 JTF_VARCHAR2_TABLE_2000
    , p0_a52 JTF_VARCHAR2_TABLE_2000
    , p0_a53 JTF_NUMBER_TABLE
    , p0_a54 JTF_VARCHAR2_TABLE_200
    , p_loan_id  NUMBER
    , p_create_flag  number
    , x_installment out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_cust_tbl lns_custom_pub.custom_tbl;
    ddp_create_flag boolean;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    lns_custom_pub_w.rosetta_table_copy_in_p1(ddp_cust_tbl, p0_a0
      , p0_a1
      , p0_a2
      , p0_a3
      , p0_a4
      , p0_a5
      , p0_a6
      , p0_a7
      , p0_a8
      , p0_a9
      , p0_a10
      , p0_a11
      , p0_a12
      , p0_a13
      , p0_a14
      , p0_a15
      , p0_a16
      , p0_a17
      , p0_a18
      , p0_a19
      , p0_a20
      , p0_a21
      , p0_a22
      , p0_a23
      , p0_a24
      , p0_a25
      , p0_a26
      , p0_a27
      , p0_a28
      , p0_a29
      , p0_a30
      , p0_a31
      , p0_a32
      , p0_a33
      , p0_a34
      , p0_a35
      , p0_a36
      , p0_a37
      , p0_a38
      , p0_a39
      , p0_a40
      , p0_a41
      , p0_a42
      , p0_a43
      , p0_a44
      , p0_a45
      , p0_a46
      , p0_a47
      , p0_a48
      , p0_a49
      , p0_a50
      , p0_a51
      , p0_a52
      , p0_a53
      , p0_a54
      );


    if p_create_flag is null
      then ddp_create_flag := null;
    elsif p_create_flag = 0
      then ddp_create_flag := false;
    else ddp_create_flag := true;
    end if;





    -- here's the delegated call to the old PL/SQL routine
    lns_custom_pub.validatecustomtable(ddp_cust_tbl,
      p_loan_id,
      ddp_create_flag,
      x_installment,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






  end;

  procedure validatecustomrow(p0_a0  NUMBER
    , p0_a1  NUMBER
    , p0_a2  NUMBER
    , p0_a3  DATE
    , p0_a4  DATE
    , p0_a5  DATE
    , p0_a6  NUMBER
    , p0_a7  NUMBER
    , p0_a8  NUMBER
    , p0_a9  NUMBER
    , p0_a10  NUMBER
    , p0_a11  NUMBER
    , p0_a12  NUMBER
    , p0_a13  NUMBER
    , p0_a14  NUMBER
    , p0_a15  NUMBER
    , p0_a16  VARCHAR2
    , p0_a17  VARCHAR2
    , p0_a18  VARCHAR2
    , p0_a19  VARCHAR2
    , p0_a20  VARCHAR2
    , p0_a21  VARCHAR2
    , p0_a22  VARCHAR2
    , p0_a23  VARCHAR2
    , p0_a24  VARCHAR2
    , p0_a25  VARCHAR2
    , p0_a26  VARCHAR2
    , p0_a27  VARCHAR2
    , p0_a28  VARCHAR2
    , p0_a29  VARCHAR2
    , p0_a30  VARCHAR2
    , p0_a31  VARCHAR2
    , p0_a32  VARCHAR2
    , p0_a33  VARCHAR2
    , p0_a34  VARCHAR2
    , p0_a35  VARCHAR2
    , p0_a36  VARCHAR2
    , p0_a37  NUMBER
    , p0_a38  NUMBER
    , p0_a39  NUMBER
    , p0_a40  NUMBER
    , p0_a41  NUMBER
    , p0_a42  NUMBER
    , p0_a43  NUMBER
    , p0_a44  NUMBER
    , p0_a45  VARCHAR2
    , p0_a46  VARCHAR2
    , p0_a47  VARCHAR2
    , p0_a48  NUMBER
    , p0_a49  VARCHAR2
    , p0_a50  VARCHAR2
    , p0_a51  VARCHAR2
    , p0_a52  VARCHAR2
    , p0_a53  NUMBER
    , p0_a54  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_custom_rec lns_custom_pub.custom_sched_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_custom_rec.custom_schedule_id := p0_a0;
    ddp_custom_rec.loan_id := p0_a1;
    ddp_custom_rec.payment_number := p0_a2;
    ddp_custom_rec.due_date := p0_a3;
    ddp_custom_rec.period_start_date := p0_a4;
    ddp_custom_rec.period_end_date := p0_a5;
    ddp_custom_rec.principal_amount := p0_a6;
    ddp_custom_rec.interest_amount := p0_a7;
    ddp_custom_rec.normal_int_amount := p0_a8;
    ddp_custom_rec.add_prin_int_amount := p0_a9;
    ddp_custom_rec.add_int_int_amount := p0_a10;
    ddp_custom_rec.penal_int_amount := p0_a11;
    ddp_custom_rec.principal_balance := p0_a12;
    ddp_custom_rec.fee_amount := p0_a13;
    ddp_custom_rec.other_amount := p0_a14;
    ddp_custom_rec.object_version_number := p0_a15;
    ddp_custom_rec.attribute_category := p0_a16;
    ddp_custom_rec.attribute1 := p0_a17;
    ddp_custom_rec.attribute2 := p0_a18;
    ddp_custom_rec.attribute3 := p0_a19;
    ddp_custom_rec.attribute4 := p0_a20;
    ddp_custom_rec.attribute5 := p0_a21;
    ddp_custom_rec.attribute6 := p0_a22;
    ddp_custom_rec.attribute7 := p0_a23;
    ddp_custom_rec.attribute8 := p0_a24;
    ddp_custom_rec.attribute9 := p0_a25;
    ddp_custom_rec.attribute10 := p0_a26;
    ddp_custom_rec.attribute11 := p0_a27;
    ddp_custom_rec.attribute12 := p0_a28;
    ddp_custom_rec.attribute13 := p0_a29;
    ddp_custom_rec.attribute14 := p0_a30;
    ddp_custom_rec.attribute15 := p0_a31;
    ddp_custom_rec.attribute16 := p0_a32;
    ddp_custom_rec.attribute17 := p0_a33;
    ddp_custom_rec.attribute18 := p0_a34;
    ddp_custom_rec.attribute19 := p0_a35;
    ddp_custom_rec.attribute20 := p0_a36;
    ddp_custom_rec.current_term_payment := p0_a37;
    ddp_custom_rec.installment_begin_balance := p0_a38;
    ddp_custom_rec.installment_end_balance := p0_a39;
    ddp_custom_rec.principal_paid_todate := p0_a40;
    ddp_custom_rec.interest_paid_todate := p0_a41;
    ddp_custom_rec.interest_rate := p0_a42;
    ddp_custom_rec.unpaid_prin := p0_a43;
    ddp_custom_rec.unpaid_int := p0_a44;
    ddp_custom_rec.lock_prin := p0_a45;
    ddp_custom_rec.lock_int := p0_a46;
    ddp_custom_rec.action := p0_a47;
    ddp_custom_rec.funded_amount := p0_a48;
    ddp_custom_rec.normal_int_details := p0_a49;
    ddp_custom_rec.add_prin_int_details := p0_a50;
    ddp_custom_rec.add_int_int_details := p0_a51;
    ddp_custom_rec.penal_int_details := p0_a52;
    ddp_custom_rec.disbursement_amount := p0_a53;
    ddp_custom_rec.period := p0_a54;




    -- here's the delegated call to the old PL/SQL routine
    lns_custom_pub.validatecustomrow(ddp_custom_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any



  end;

  procedure recalccustomschedule(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_loan_id  NUMBER
    , p_amort_method  VARCHAR2
    , p_based_on_terms  VARCHAR2
    , p7_a0 in out nocopy JTF_NUMBER_TABLE
    , p7_a1 in out nocopy JTF_NUMBER_TABLE
    , p7_a2 in out nocopy JTF_NUMBER_TABLE
    , p7_a3 in out nocopy JTF_DATE_TABLE
    , p7_a4 in out nocopy JTF_DATE_TABLE
    , p7_a5 in out nocopy JTF_DATE_TABLE
    , p7_a6 in out nocopy JTF_NUMBER_TABLE
    , p7_a7 in out nocopy JTF_NUMBER_TABLE
    , p7_a8 in out nocopy JTF_NUMBER_TABLE
    , p7_a9 in out nocopy JTF_NUMBER_TABLE
    , p7_a10 in out nocopy JTF_NUMBER_TABLE
    , p7_a11 in out nocopy JTF_NUMBER_TABLE
    , p7_a12 in out nocopy JTF_NUMBER_TABLE
    , p7_a13 in out nocopy JTF_NUMBER_TABLE
    , p7_a14 in out nocopy JTF_NUMBER_TABLE
    , p7_a15 in out nocopy JTF_NUMBER_TABLE
    , p7_a16 in out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a17 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a18 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a19 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a20 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a21 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a22 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a23 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a24 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a25 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a26 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a27 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a28 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a29 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a30 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a31 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a32 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a33 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a34 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a35 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a36 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a37 in out nocopy JTF_NUMBER_TABLE
    , p7_a38 in out nocopy JTF_NUMBER_TABLE
    , p7_a39 in out nocopy JTF_NUMBER_TABLE
    , p7_a40 in out nocopy JTF_NUMBER_TABLE
    , p7_a41 in out nocopy JTF_NUMBER_TABLE
    , p7_a42 in out nocopy JTF_NUMBER_TABLE
    , p7_a43 in out nocopy JTF_NUMBER_TABLE
    , p7_a44 in out nocopy JTF_NUMBER_TABLE
    , p7_a45 in out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a46 in out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a47 in out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a48 in out nocopy JTF_NUMBER_TABLE
    , p7_a49 in out nocopy JTF_VARCHAR2_TABLE_2000
    , p7_a50 in out nocopy JTF_VARCHAR2_TABLE_2000
    , p7_a51 in out nocopy JTF_VARCHAR2_TABLE_2000
    , p7_a52 in out nocopy JTF_VARCHAR2_TABLE_2000
    , p7_a53 in out nocopy JTF_NUMBER_TABLE
    , p7_a54 in out nocopy JTF_VARCHAR2_TABLE_200
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_custom_tbl lns_custom_pub.custom_tbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    lns_custom_pub_w.rosetta_table_copy_in_p1(ddp_custom_tbl, p7_a0
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
      );




    -- here's the delegated call to the old PL/SQL routine
    lns_custom_pub.recalccustomschedule(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      p_loan_id,
      p_amort_method,
      p_based_on_terms,
      ddp_custom_tbl,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







    lns_custom_pub_w.rosetta_table_copy_out_p1(ddp_custom_tbl, p7_a0
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
      );



  end;

  procedure loadcustomschedule(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_loan_id  NUMBER
    , p_based_on_terms  VARCHAR2
    , x_amort_method out nocopy  VARCHAR2
    , p7_a0 out nocopy JTF_NUMBER_TABLE
    , p7_a1 out nocopy JTF_NUMBER_TABLE
    , p7_a2 out nocopy JTF_NUMBER_TABLE
    , p7_a3 out nocopy JTF_DATE_TABLE
    , p7_a4 out nocopy JTF_DATE_TABLE
    , p7_a5 out nocopy JTF_DATE_TABLE
    , p7_a6 out nocopy JTF_NUMBER_TABLE
    , p7_a7 out nocopy JTF_NUMBER_TABLE
    , p7_a8 out nocopy JTF_NUMBER_TABLE
    , p7_a9 out nocopy JTF_NUMBER_TABLE
    , p7_a10 out nocopy JTF_NUMBER_TABLE
    , p7_a11 out nocopy JTF_NUMBER_TABLE
    , p7_a12 out nocopy JTF_NUMBER_TABLE
    , p7_a13 out nocopy JTF_NUMBER_TABLE
    , p7_a14 out nocopy JTF_NUMBER_TABLE
    , p7_a15 out nocopy JTF_NUMBER_TABLE
    , p7_a16 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a17 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a18 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a19 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a20 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a21 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a22 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a23 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a24 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a25 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a26 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a27 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a28 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a29 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a30 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a31 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a32 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a33 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a34 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a35 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a36 out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a37 out nocopy JTF_NUMBER_TABLE
    , p7_a38 out nocopy JTF_NUMBER_TABLE
    , p7_a39 out nocopy JTF_NUMBER_TABLE
    , p7_a40 out nocopy JTF_NUMBER_TABLE
    , p7_a41 out nocopy JTF_NUMBER_TABLE
    , p7_a42 out nocopy JTF_NUMBER_TABLE
    , p7_a43 out nocopy JTF_NUMBER_TABLE
    , p7_a44 out nocopy JTF_NUMBER_TABLE
    , p7_a45 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a46 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a47 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a48 out nocopy JTF_NUMBER_TABLE
    , p7_a49 out nocopy JTF_VARCHAR2_TABLE_2000
    , p7_a50 out nocopy JTF_VARCHAR2_TABLE_2000
    , p7_a51 out nocopy JTF_VARCHAR2_TABLE_2000
    , p7_a52 out nocopy JTF_VARCHAR2_TABLE_2000
    , p7_a53 out nocopy JTF_NUMBER_TABLE
    , p7_a54 out nocopy JTF_VARCHAR2_TABLE_200
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddx_custom_tbl lns_custom_pub.custom_tbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any











    -- here's the delegated call to the old PL/SQL routine
    lns_custom_pub.loadcustomschedule(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      p_loan_id,
      p_based_on_terms,
      x_amort_method,
      ddx_custom_tbl,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







    lns_custom_pub_w.rosetta_table_copy_out_p1(ddx_custom_tbl, p7_a0
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
      );



  end;

  procedure savecustomschedule(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_loan_id  NUMBER
    , p_amort_method  VARCHAR2
    , p_based_on_terms  VARCHAR2
    , p7_a0 in out nocopy JTF_NUMBER_TABLE
    , p7_a1 in out nocopy JTF_NUMBER_TABLE
    , p7_a2 in out nocopy JTF_NUMBER_TABLE
    , p7_a3 in out nocopy JTF_DATE_TABLE
    , p7_a4 in out nocopy JTF_DATE_TABLE
    , p7_a5 in out nocopy JTF_DATE_TABLE
    , p7_a6 in out nocopy JTF_NUMBER_TABLE
    , p7_a7 in out nocopy JTF_NUMBER_TABLE
    , p7_a8 in out nocopy JTF_NUMBER_TABLE
    , p7_a9 in out nocopy JTF_NUMBER_TABLE
    , p7_a10 in out nocopy JTF_NUMBER_TABLE
    , p7_a11 in out nocopy JTF_NUMBER_TABLE
    , p7_a12 in out nocopy JTF_NUMBER_TABLE
    , p7_a13 in out nocopy JTF_NUMBER_TABLE
    , p7_a14 in out nocopy JTF_NUMBER_TABLE
    , p7_a15 in out nocopy JTF_NUMBER_TABLE
    , p7_a16 in out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a17 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a18 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a19 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a20 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a21 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a22 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a23 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a24 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a25 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a26 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a27 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a28 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a29 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a30 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a31 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a32 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a33 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a34 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a35 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a36 in out nocopy JTF_VARCHAR2_TABLE_200
    , p7_a37 in out nocopy JTF_NUMBER_TABLE
    , p7_a38 in out nocopy JTF_NUMBER_TABLE
    , p7_a39 in out nocopy JTF_NUMBER_TABLE
    , p7_a40 in out nocopy JTF_NUMBER_TABLE
    , p7_a41 in out nocopy JTF_NUMBER_TABLE
    , p7_a42 in out nocopy JTF_NUMBER_TABLE
    , p7_a43 in out nocopy JTF_NUMBER_TABLE
    , p7_a44 in out nocopy JTF_NUMBER_TABLE
    , p7_a45 in out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a46 in out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a47 in out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a48 in out nocopy JTF_NUMBER_TABLE
    , p7_a49 in out nocopy JTF_VARCHAR2_TABLE_2000
    , p7_a50 in out nocopy JTF_VARCHAR2_TABLE_2000
    , p7_a51 in out nocopy JTF_VARCHAR2_TABLE_2000
    , p7_a52 in out nocopy JTF_VARCHAR2_TABLE_2000
    , p7_a53 in out nocopy JTF_NUMBER_TABLE
    , p7_a54 in out nocopy JTF_VARCHAR2_TABLE_200
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_custom_tbl lns_custom_pub.custom_tbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    lns_custom_pub_w.rosetta_table_copy_in_p1(ddp_custom_tbl, p7_a0
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
      );




    -- here's the delegated call to the old PL/SQL routine
    lns_custom_pub.savecustomschedule(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      p_loan_id,
      p_amort_method,
      p_based_on_terms,
      ddp_custom_tbl,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







    lns_custom_pub_w.rosetta_table_copy_out_p1(ddp_custom_tbl, p7_a0
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
      );



  end;

  procedure shiftcustomschedule(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_loan_id  NUMBER
    , p_old_due_date  DATE
    , p_new_due_date  DATE
    , p_amort_method  VARCHAR2
    , p_based_on_terms  VARCHAR2
    , p9_a0 in out nocopy JTF_NUMBER_TABLE
    , p9_a1 in out nocopy JTF_NUMBER_TABLE
    , p9_a2 in out nocopy JTF_NUMBER_TABLE
    , p9_a3 in out nocopy JTF_DATE_TABLE
    , p9_a4 in out nocopy JTF_DATE_TABLE
    , p9_a5 in out nocopy JTF_DATE_TABLE
    , p9_a6 in out nocopy JTF_NUMBER_TABLE
    , p9_a7 in out nocopy JTF_NUMBER_TABLE
    , p9_a8 in out nocopy JTF_NUMBER_TABLE
    , p9_a9 in out nocopy JTF_NUMBER_TABLE
    , p9_a10 in out nocopy JTF_NUMBER_TABLE
    , p9_a11 in out nocopy JTF_NUMBER_TABLE
    , p9_a12 in out nocopy JTF_NUMBER_TABLE
    , p9_a13 in out nocopy JTF_NUMBER_TABLE
    , p9_a14 in out nocopy JTF_NUMBER_TABLE
    , p9_a15 in out nocopy JTF_NUMBER_TABLE
    , p9_a16 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a17 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a18 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a19 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a20 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a21 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a22 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a23 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a24 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a25 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a26 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a27 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a28 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a29 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a30 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a31 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a32 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a33 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a34 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a35 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a36 in out nocopy JTF_VARCHAR2_TABLE_200
    , p9_a37 in out nocopy JTF_NUMBER_TABLE
    , p9_a38 in out nocopy JTF_NUMBER_TABLE
    , p9_a39 in out nocopy JTF_NUMBER_TABLE
    , p9_a40 in out nocopy JTF_NUMBER_TABLE
    , p9_a41 in out nocopy JTF_NUMBER_TABLE
    , p9_a42 in out nocopy JTF_NUMBER_TABLE
    , p9_a43 in out nocopy JTF_NUMBER_TABLE
    , p9_a44 in out nocopy JTF_NUMBER_TABLE
    , p9_a45 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a46 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a47 in out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a48 in out nocopy JTF_NUMBER_TABLE
    , p9_a49 in out nocopy JTF_VARCHAR2_TABLE_2000
    , p9_a50 in out nocopy JTF_VARCHAR2_TABLE_2000
    , p9_a51 in out nocopy JTF_VARCHAR2_TABLE_2000
    , p9_a52 in out nocopy JTF_VARCHAR2_TABLE_2000
    , p9_a53 in out nocopy JTF_NUMBER_TABLE
    , p9_a54 in out nocopy JTF_VARCHAR2_TABLE_200
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_custom_tbl lns_custom_pub.custom_tbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any









    lns_custom_pub_w.rosetta_table_copy_in_p1(ddp_custom_tbl, p9_a0
      , p9_a1
      , p9_a2
      , p9_a3
      , p9_a4
      , p9_a5
      , p9_a6
      , p9_a7
      , p9_a8
      , p9_a9
      , p9_a10
      , p9_a11
      , p9_a12
      , p9_a13
      , p9_a14
      , p9_a15
      , p9_a16
      , p9_a17
      , p9_a18
      , p9_a19
      , p9_a20
      , p9_a21
      , p9_a22
      , p9_a23
      , p9_a24
      , p9_a25
      , p9_a26
      , p9_a27
      , p9_a28
      , p9_a29
      , p9_a30
      , p9_a31
      , p9_a32
      , p9_a33
      , p9_a34
      , p9_a35
      , p9_a36
      , p9_a37
      , p9_a38
      , p9_a39
      , p9_a40
      , p9_a41
      , p9_a42
      , p9_a43
      , p9_a44
      , p9_a45
      , p9_a46
      , p9_a47
      , p9_a48
      , p9_a49
      , p9_a50
      , p9_a51
      , p9_a52
      , p9_a53
      , p9_a54
      );




    -- here's the delegated call to the old PL/SQL routine
    lns_custom_pub.shiftcustomschedule(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      p_loan_id,
      p_old_due_date,
      p_new_due_date,
      p_amort_method,
      p_based_on_terms,
      ddp_custom_tbl,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any









    lns_custom_pub_w.rosetta_table_copy_out_p1(ddp_custom_tbl, p9_a0
      , p9_a1
      , p9_a2
      , p9_a3
      , p9_a4
      , p9_a5
      , p9_a6
      , p9_a7
      , p9_a8
      , p9_a9
      , p9_a10
      , p9_a11
      , p9_a12
      , p9_a13
      , p9_a14
      , p9_a15
      , p9_a16
      , p9_a17
      , p9_a18
      , p9_a19
      , p9_a20
      , p9_a21
      , p9_a22
      , p9_a23
      , p9_a24
      , p9_a25
      , p9_a26
      , p9_a27
      , p9_a28
      , p9_a29
      , p9_a30
      , p9_a31
      , p9_a32
      , p9_a33
      , p9_a34
      , p9_a35
      , p9_a36
      , p9_a37
      , p9_a38
      , p9_a39
      , p9_a40
      , p9_a41
      , p9_a42
      , p9_a43
      , p9_a44
      , p9_a45
      , p9_a46
      , p9_a47
      , p9_a48
      , p9_a49
      , p9_a50
      , p9_a51
      , p9_a52
      , p9_a53
      , p9_a54
      );



  end;

  procedure addmissinginstallment(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p4_a0  NUMBER
    , p4_a1  NUMBER
    , p4_a2  NUMBER
    , p4_a3  DATE
    , p4_a4  DATE
    , p4_a5  DATE
    , p4_a6  NUMBER
    , p4_a7  NUMBER
    , p4_a8  NUMBER
    , p4_a9  NUMBER
    , p4_a10  NUMBER
    , p4_a11  NUMBER
    , p4_a12  NUMBER
    , p4_a13  NUMBER
    , p4_a14  NUMBER
    , p4_a15  NUMBER
    , p4_a16  VARCHAR2
    , p4_a17  VARCHAR2
    , p4_a18  VARCHAR2
    , p4_a19  VARCHAR2
    , p4_a20  VARCHAR2
    , p4_a21  VARCHAR2
    , p4_a22  VARCHAR2
    , p4_a23  VARCHAR2
    , p4_a24  VARCHAR2
    , p4_a25  VARCHAR2
    , p4_a26  VARCHAR2
    , p4_a27  VARCHAR2
    , p4_a28  VARCHAR2
    , p4_a29  VARCHAR2
    , p4_a30  VARCHAR2
    , p4_a31  VARCHAR2
    , p4_a32  VARCHAR2
    , p4_a33  VARCHAR2
    , p4_a34  VARCHAR2
    , p4_a35  VARCHAR2
    , p4_a36  VARCHAR2
    , p4_a37  NUMBER
    , p4_a38  NUMBER
    , p4_a39  NUMBER
    , p4_a40  NUMBER
    , p4_a41  NUMBER
    , p4_a42  NUMBER
    , p4_a43  NUMBER
    , p4_a44  NUMBER
    , p4_a45  VARCHAR2
    , p4_a46  VARCHAR2
    , p4_a47  VARCHAR2
    , p4_a48  NUMBER
    , p4_a49  VARCHAR2
    , p4_a50  VARCHAR2
    , p4_a51  VARCHAR2
    , p4_a52  VARCHAR2
    , p4_a53  NUMBER
    , p4_a54  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_installment_rec lns_custom_pub.custom_sched_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    ddp_installment_rec.custom_schedule_id := p4_a0;
    ddp_installment_rec.loan_id := p4_a1;
    ddp_installment_rec.payment_number := p4_a2;
    ddp_installment_rec.due_date := p4_a3;
    ddp_installment_rec.period_start_date := p4_a4;
    ddp_installment_rec.period_end_date := p4_a5;
    ddp_installment_rec.principal_amount := p4_a6;
    ddp_installment_rec.interest_amount := p4_a7;
    ddp_installment_rec.normal_int_amount := p4_a8;
    ddp_installment_rec.add_prin_int_amount := p4_a9;
    ddp_installment_rec.add_int_int_amount := p4_a10;
    ddp_installment_rec.penal_int_amount := p4_a11;
    ddp_installment_rec.principal_balance := p4_a12;
    ddp_installment_rec.fee_amount := p4_a13;
    ddp_installment_rec.other_amount := p4_a14;
    ddp_installment_rec.object_version_number := p4_a15;
    ddp_installment_rec.attribute_category := p4_a16;
    ddp_installment_rec.attribute1 := p4_a17;
    ddp_installment_rec.attribute2 := p4_a18;
    ddp_installment_rec.attribute3 := p4_a19;
    ddp_installment_rec.attribute4 := p4_a20;
    ddp_installment_rec.attribute5 := p4_a21;
    ddp_installment_rec.attribute6 := p4_a22;
    ddp_installment_rec.attribute7 := p4_a23;
    ddp_installment_rec.attribute8 := p4_a24;
    ddp_installment_rec.attribute9 := p4_a25;
    ddp_installment_rec.attribute10 := p4_a26;
    ddp_installment_rec.attribute11 := p4_a27;
    ddp_installment_rec.attribute12 := p4_a28;
    ddp_installment_rec.attribute13 := p4_a29;
    ddp_installment_rec.attribute14 := p4_a30;
    ddp_installment_rec.attribute15 := p4_a31;
    ddp_installment_rec.attribute16 := p4_a32;
    ddp_installment_rec.attribute17 := p4_a33;
    ddp_installment_rec.attribute18 := p4_a34;
    ddp_installment_rec.attribute19 := p4_a35;
    ddp_installment_rec.attribute20 := p4_a36;
    ddp_installment_rec.current_term_payment := p4_a37;
    ddp_installment_rec.installment_begin_balance := p4_a38;
    ddp_installment_rec.installment_end_balance := p4_a39;
    ddp_installment_rec.principal_paid_todate := p4_a40;
    ddp_installment_rec.interest_paid_todate := p4_a41;
    ddp_installment_rec.interest_rate := p4_a42;
    ddp_installment_rec.unpaid_prin := p4_a43;
    ddp_installment_rec.unpaid_int := p4_a44;
    ddp_installment_rec.lock_prin := p4_a45;
    ddp_installment_rec.lock_int := p4_a46;
    ddp_installment_rec.action := p4_a47;
    ddp_installment_rec.funded_amount := p4_a48;
    ddp_installment_rec.normal_int_details := p4_a49;
    ddp_installment_rec.add_prin_int_details := p4_a50;
    ddp_installment_rec.add_int_int_details := p4_a51;
    ddp_installment_rec.penal_int_details := p4_a52;
    ddp_installment_rec.disbursement_amount := p4_a53;
    ddp_installment_rec.period := p4_a54;




    -- here's the delegated call to the old PL/SQL routine
    lns_custom_pub.addmissinginstallment(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      ddp_installment_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

end lns_custom_pub_w;

/
