--------------------------------------------------------
--  DDL for Package Body AR_CREDIT_MEMO_API_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_CREDIT_MEMO_API_PUB_W" as
  /* $Header: ARICMWFB.pls 120.2.12010000.4 2008/09/26 13:33:30 nkanchan ship $ */
  rosetta_g_mistake_date date := to_date('01/01/+4713', 'MM/DD/SYYYY');
  rosetta_g_miss_date date := to_date('01/01/-4712', 'MM/DD/SYYYY');

  function rosetta_g_miss_num_map(n number) return number as
    a number := fnd_api.g_miss_num;
    b number := 0-1962.0724;
  begin
    if n=a then return b; end if;
    if n=b then return a; end if;
    return n;
  end;

  -- this is to workaround the JDBC bug regarding IN DATE of value GMiss
  function rosetta_g_miss_date_in_map(d date) return date as
  begin
    if d = rosetta_g_mistake_date then return fnd_api.g_miss_date; end if;
    return d;
  end;

  procedure rosetta_table_copy_in_p1(t out nocopy cm_line_tbl_type_cover%type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).customer_trx_line_id := a0(indx);
          t(ddindx).extended_amount := a1(indx);
          t(ddindx).quantity_credited := a2(indx);
          t(ddindx).price := a3(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p1;
  procedure rosetta_table_copy_out_p1(t cm_line_tbl_type_cover%type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_NUMBER_TABLE();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        a3.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).customer_trx_line_id;
          a1(indx) := t(ddindx).extended_amount;
          a2(indx) := t(ddindx).quantity_credited;
          a3(indx) := t(ddindx).price;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p1;

  procedure rosetta_table_copy_in_p4(t out nocopy ar_credit_memo_api_pub.cm_notes_tbl_type_cover, a0 JTF_VARCHAR2_TABLE_300
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).notes := a0(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p4;
  procedure rosetta_table_copy_out_p4(t ar_credit_memo_api_pub.cm_notes_tbl_type_cover, a0 out nocopy JTF_VARCHAR2_TABLE_300
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_300();
  else
      a0 := JTF_VARCHAR2_TABLE_300();
      if t.count > 0 then
        a0.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).notes;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p4;

  procedure rosetta_table_copy_in_p7(t out nocopy ar_credit_memo_api_pub.cm_activity_tbl_type_cover, a0 JTF_DATE_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).begin_date := rosetta_g_miss_date_in_map(a0(indx));
          t(ddindx).activity_name := a1(indx);
          t(ddindx).status := a2(indx);
          t(ddindx).result_code := a3(indx);
          t(ddindx).user := a4(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p7;
  procedure rosetta_table_copy_out_p7(t ar_credit_memo_api_pub.cm_activity_tbl_type_cover, a0 out nocopy JTF_DATE_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_DATE_TABLE();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_VARCHAR2_TABLE_100();
    a4 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_DATE_TABLE();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_VARCHAR2_TABLE_100();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        a3.extend(t.count);
        a4.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).begin_date;
          a1(indx) := t(ddindx).activity_name;
          a2(indx) := t(ddindx).status;
          a3(indx) := t(ddindx).result_code;
          a4(indx) := t(ddindx).user;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p7;

  procedure create_request(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out  nocopy VARCHAR2
    , x_msg_count out nocopy NUMBER
    , x_msg_data out nocopy VARCHAR2
    , p_customer_trx_id  NUMBER
    , p_line_credit_flag  VARCHAR2
    , p_line_amount  NUMBER
    , p_tax_amount  NUMBER
    , p_freight_amount  NUMBER
    , p_cm_reason_code  VARCHAR2
    , p_comments  VARCHAR2
    , p_orig_trx_number  VARCHAR2
    , p_tax_ex_cert_num  VARCHAR2
    , p_request_url  VARCHAR2
    , p_transaction_url  VARCHAR2
    , p_trans_act_url  VARCHAR2
    , p19_a0 JTF_NUMBER_TABLE
    , p_skip_workflow_flag VARCHAR2
    , p_credit_method_installments VARCHAR2
    , p_credit_method_rules VARCHAR2
    , p_batch_source_name VARCHAR2
    , p_org_id NUMBER
    , x_request_id out nocopy VARCHAR2
    , p19_a1 JTF_NUMBER_TABLE
    , p19_a2 JTF_NUMBER_TABLE
    , p19_a3 JTF_NUMBER_TABLE
    , p_dispute_date DATE
    , p_internal_comment VARCHAR2
  )
  as
    ddp_cm_line_tbl cm_line_tbl_type_cover%type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



















    ar_credit_memo_api_pub_w.rosetta_table_copy_in_p1(ddp_cm_line_tbl, p19_a0
      , p19_a1
      , p19_a2
      , p19_a3
      );


    -- here's the delegated call to the old PL/SQL routine
    ar_credit_memo_api_pub.create_request(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_customer_trx_id,
      p_line_credit_flag,
      p_line_amount,
      p_tax_amount,
      p_freight_amount,
      p_cm_reason_code,
      p_comments,
      p_orig_trx_number,
      p_tax_ex_cert_num,
      p_request_url,
      p_transaction_url,
      p_trans_act_url,
      ddp_cm_line_tbl,
      null,
      null,
      null,
      null,
      null,
      x_request_id,
      null,
      null,
      null,
      null,
      p_internal_comment
      );

    -- copy data back from the local OUT or IN-OUT args, if any




















  end;

  procedure validate_request_parameters(p_customer_trx_id  NUMBER
    , p_line_credit_flag  VARCHAR2
    , p_line_amount  NUMBER
    , p_tax_amount  NUMBER
    , p_freight_amount  NUMBER
    , p_cm_reason_code  VARCHAR2
    , p_comments  VARCHAR2
    , p_request_url  VARCHAR2
    , p_transaction_url  VARCHAR2
    , p_trans_act_url  VARCHAR2
    , p10_a0 JTF_NUMBER_TABLE
    , p_org_id NUMBER
    , l_val_return_status out nocopy  VARCHAR2
    , p_skip_workflow_flag VARCHAR2
    , p_batch_source_name VARCHAR2
    , p10_a1 JTF_NUMBER_TABLE
    , p10_a2 JTF_NUMBER_TABLE
    , p10_a3 JTF_NUMBER_TABLE
    , p_dispute_date DATE
  )
  as
    ddp_cm_line_tbl cm_line_tbl_type_cover%type;
    ddindx binary_integer; indx binary_integer;
  begin
    -- copy data to the local IN or IN-OUT args, if any










    ar_credit_memo_api_pub_w.rosetta_table_copy_in_p1(ddp_cm_line_tbl, p10_a0
      , p10_a1
      , p10_a2
      , p10_a3
      );


    -- here's the delegated call to the old PL/SQL routine
    ar_credit_memo_api_pub.validate_request_parameters(p_customer_trx_id,
      p_line_credit_flag,
      p_line_amount,
      p_tax_amount,
      p_freight_amount,
      p_cm_reason_code,
      p_comments,
      p_request_url,
      p_transaction_url,
      p_trans_act_url,
      ddp_cm_line_tbl,
      null,
      l_val_return_status,
      null);

    -- copy data back from the local OUT or IN-OUT args, if any











  end;

end ar_credit_memo_api_pub_w;

/
