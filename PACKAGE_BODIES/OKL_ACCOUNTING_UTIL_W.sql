--------------------------------------------------------
--  DDL for Package Body OKL_ACCOUNTING_UTIL_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_ACCOUNTING_UTIL_W" as
  /* $Header: OKLEAUTB.pls 120.4 2007/01/31 07:20:51 nikshah ship $ */
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

  procedure rosetta_table_copy_in_p0(t out nocopy okl_accounting_util.seg_num_array_type, a0 JTF_NUMBER_TABLE) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx) := rosetta_g_miss_num_map(a0(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p0;
  procedure rosetta_table_copy_out_p0(t okl_accounting_util.seg_num_array_type, a0 out nocopy JTF_NUMBER_TABLE) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      if t.count > 0 then
        a0.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx));
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p0;

  procedure rosetta_table_copy_in_p1(t out nocopy okl_accounting_util.seg_array_type, a0 JTF_VARCHAR2_TABLE_100) as
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
  end rosetta_table_copy_in_p1;
  procedure rosetta_table_copy_out_p1(t okl_accounting_util.seg_array_type, a0 out nocopy JTF_VARCHAR2_TABLE_100) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_VARCHAR2_TABLE_100();
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
  end rosetta_table_copy_out_p1;

  procedure rosetta_table_copy_in_p2(t out nocopy okl_accounting_util.seg_desc_array_type, a0 JTF_VARCHAR2_TABLE_100) as
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
  end rosetta_table_copy_in_p2;
  procedure rosetta_table_copy_out_p2(t okl_accounting_util.seg_desc_array_type, a0 out nocopy JTF_VARCHAR2_TABLE_100) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_VARCHAR2_TABLE_100();
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
  end rosetta_table_copy_out_p2;

  procedure rosetta_table_copy_in_p3(t out nocopy okl_accounting_util.error_message_type, a0 JTF_VARCHAR2_TABLE_2000) as
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
  end rosetta_table_copy_in_p3;
  procedure rosetta_table_copy_out_p3(t okl_accounting_util.error_message_type, a0 out nocopy JTF_VARCHAR2_TABLE_2000) as
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
  end rosetta_table_copy_out_p3;

  procedure rosetta_table_copy_in_p26(t out nocopy okl_accounting_util.overlap_attrib_tbl_type, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_200
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).attribute := a0(indx);
          t(ddindx).attrib_type := a1(indx);
          t(ddindx).value := a2(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p26;
  procedure rosetta_table_copy_out_p26(t okl_accounting_util.overlap_attrib_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_100
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_200
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_100();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_VARCHAR2_TABLE_200();
  else
      a0 := JTF_VARCHAR2_TABLE_100();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_VARCHAR2_TABLE_200();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).attribute;
          a1(indx) := t(ddindx).attrib_type;
          a2(indx) := t(ddindx).value;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p26;

  procedure get_segment_array(p_concate_segments  VARCHAR2
    , p_delimiter  VARCHAR2
    , p_seg_array_type out nocopy JTF_VARCHAR2_TABLE_100
  )

  as
    ddp_seg_array_type okl_accounting_util.seg_array_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    -- here's the delegated call to the old PL/SQL routine
    okl_accounting_util.get_segment_array(p_concate_segments,
      p_delimiter,
      ddp_seg_array_type);

    -- copy data back from the local variables to OUT or IN-OUT args, if any


    okl_accounting_util_w.rosetta_table_copy_out_p1(ddp_seg_array_type, p_seg_array_type);
  end;

  procedure get_error_message(p_all_message out nocopy JTF_VARCHAR2_TABLE_2000
  )

  as
    ddp_all_message okl_accounting_util.error_message_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    -- here's the delegated call to the old PL/SQL routine
    okl_accounting_util.get_error_message(ddp_all_message);

    -- copy data back from the local variables to OUT or IN-OUT args, if any
    okl_accounting_util_w.rosetta_table_copy_out_p3(ddp_all_message, p_all_message);
  end;

  procedure get_error_msg(p_all_message out nocopy JTF_VARCHAR2_TABLE_2000
  )

  as
    ddp_all_message okl_accounting_util.error_message_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    -- here's the delegated call to the old PL/SQL routine
    okl_accounting_util.get_error_msg(ddp_all_message);

    -- copy data back from the local variables to OUT or IN-OUT args, if any
    okl_accounting_util_w.rosetta_table_copy_out_p3(ddp_all_message, p_all_message);
  end;

  function get_curr_con_rate(p_from_curr_code  VARCHAR2
    , p_to_curr_code  VARCHAR2
    , p_con_date  date
    , p_con_type  VARCHAR2
  ) return number

  as
    ddp_con_date date;
    ddindx binary_integer; indx binary_integer;
    ddrosetta_retval number;
  begin

    -- copy data to the local IN or IN-OUT args, if any


    ddp_con_date := rosetta_g_miss_date_in_map(p_con_date);


    -- here's the delegated call to the old PL/SQL routine
    ddrosetta_retval := okl_accounting_util.get_curr_con_rate(p_from_curr_code,
      p_to_curr_code,
      ddp_con_date,
      p_con_type);

    -- copy data back from the local variables to OUT or IN-OUT args, if any




    return ddrosetta_retval;
  end;

  procedure get_curr_con_rate(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_from_curr_code  VARCHAR2
    , p_to_curr_code  VARCHAR2
    , p_con_date  date
    , p_con_type  VARCHAR2
    , x_conv_rate out nocopy  NUMBER
  )

  as
    ddp_con_date date;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_con_date := rosetta_g_miss_date_in_map(p_con_date);



    -- here's the delegated call to the old PL/SQL routine
    okl_accounting_util.get_curr_con_rate(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_from_curr_code,
      p_to_curr_code,
      ddp_con_date,
      p_con_type,
      x_conv_rate);

    -- copy data back from the local variables to OUT or IN-OUT args, if any









  end;

  procedure get_accounting_segment(p0_a0 out nocopy  JTF_NUMBER_TABLE
    , p0_a1 out nocopy  JTF_VARCHAR2_TABLE_100
    , p0_a2 out nocopy  JTF_VARCHAR2_TABLE_100
  )

  as
    ddp_segment_array okl_accounting_util.seg_num_name_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    -- here's the delegated call to the old PL/SQL routine
    okl_accounting_util.get_accounting_segment(ddp_segment_array);

    -- copy data back from the local variables to OUT or IN-OUT args, if any
    okl_accounting_util_w.rosetta_table_copy_out_p0(ddp_segment_array.seg_num, p0_a0);
    okl_accounting_util_w.rosetta_table_copy_out_p1(ddp_segment_array.seg_name, p0_a1);
    okl_accounting_util_w.rosetta_table_copy_out_p2(ddp_segment_array.seg_desc, p0_a2);
  end;

  procedure get_period_info(p_date  date
    , p_period_name out nocopy  VARCHAR2
    , p_start_date out nocopy  DATE
    , p_end_date out nocopy  DATE
    , p_ledger_id  NUMBER
  )

  as
    ddp_date date;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_date := rosetta_g_miss_date_in_map(p_date);





    -- here's the delegated call to the old PL/SQL routine
    okl_accounting_util.get_period_info(ddp_date,
      p_period_name,
      p_start_date,
      p_end_date,
      p_ledger_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any




  end;

  procedure check_overlaps(p_id  NUMBER
    , p1_a0 JTF_VARCHAR2_TABLE_100
    , p1_a1 JTF_VARCHAR2_TABLE_100
    , p1_a2 JTF_VARCHAR2_TABLE_200
    , p_start_date_attribute_name  VARCHAR2
    , p_start_date  date
    , p_end_date_attribute_name  VARCHAR2
    , p_end_date  date
    , p_view  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_valid out nocopy  number
  )

  as
    ddp_attrib_tbl okl_accounting_util.overlap_attrib_tbl_type;
    ddp_start_date date;
    ddp_end_date date;
    ddx_valid boolean;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    okl_accounting_util_w.rosetta_table_copy_in_p26(ddp_attrib_tbl, p1_a0
      , p1_a1
      , p1_a2
      );


    ddp_start_date := rosetta_g_miss_date_in_map(p_start_date);


    ddp_end_date := rosetta_g_miss_date_in_map(p_end_date);




    -- here's the delegated call to the old PL/SQL routine
    okl_accounting_util.check_overlaps(p_id,
      ddp_attrib_tbl,
      p_start_date_attribute_name,
      ddp_start_date,
      p_end_date_attribute_name,
      ddp_end_date,
      p_view,
      x_return_status,
      ddx_valid);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  if ddx_valid is null
    then x_valid := null;
  elsif ddx_valid
    then x_valid := 1;
  else x_valid := 0;
  end if;
  end;

  procedure get_version(p0_a0 JTF_VARCHAR2_TABLE_100
    , p0_a1 JTF_VARCHAR2_TABLE_100
    , p0_a2 JTF_VARCHAR2_TABLE_200
    , p_cur_version  VARCHAR2
    , p_end_date_attribute_name  VARCHAR2
    , p_end_date  date
    , p_view  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_new_version out nocopy  VARCHAR2
  )

  as
    ddp_attrib_tbl okl_accounting_util.overlap_attrib_tbl_type;
    ddp_end_date date;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    okl_accounting_util_w.rosetta_table_copy_in_p26(ddp_attrib_tbl, p0_a0
      , p0_a1
      , p0_a2
      );



    ddp_end_date := rosetta_g_miss_date_in_map(p_end_date);




    -- here's the delegated call to the old PL/SQL routine
    okl_accounting_util.get_version(ddp_attrib_tbl,
      p_cur_version,
      p_end_date_attribute_name,
      ddp_end_date,
      p_view,
      x_return_status,
      x_new_version);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






  end;

  procedure convert_to_functional_currency(p_khr_id  NUMBER
    , p_to_currency  VARCHAR2
    , p_transaction_date  date
    , p_amount  NUMBER
    , x_contract_currency out nocopy  VARCHAR2
    , x_currency_conversion_type out nocopy  VARCHAR2
    , x_currency_conversion_rate out nocopy  NUMBER
    , x_currency_conversion_date out nocopy  DATE
    , x_converted_amount out nocopy  NUMBER
  )

  as
    ddp_transaction_date date;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any


    ddp_transaction_date := rosetta_g_miss_date_in_map(p_transaction_date);







    -- here's the delegated call to the old PL/SQL routine
    okl_accounting_util.convert_to_functional_currency(p_khr_id,
      p_to_currency,
      ddp_transaction_date,
      p_amount,
      x_contract_currency,
      x_currency_conversion_type,
      x_currency_conversion_rate,
      x_currency_conversion_date,
      x_converted_amount);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

  procedure convert_to_functional_currency(p_khr_id  NUMBER
    , p_to_currency  VARCHAR2
    , p_transaction_date  date
    , p_amount  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_contract_currency out nocopy  VARCHAR2
    , x_currency_conversion_type out nocopy  VARCHAR2
    , x_currency_conversion_rate out nocopy  NUMBER
    , x_currency_conversion_date out nocopy  DATE
    , x_converted_amount out nocopy  NUMBER
  )

  as
    ddp_transaction_date date;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any


    ddp_transaction_date := rosetta_g_miss_date_in_map(p_transaction_date);








    -- here's the delegated call to the old PL/SQL routine
    okl_accounting_util.convert_to_functional_currency(p_khr_id,
      p_to_currency,
      ddp_transaction_date,
      p_amount,
      x_return_status,
      x_contract_currency,
      x_currency_conversion_type,
      x_currency_conversion_rate,
      x_currency_conversion_date,
      x_converted_amount);

    -- copy data back from the local variables to OUT or IN-OUT args, if any









  end;

  procedure convert_to_contract_currency(p_khr_id  NUMBER
    , p_from_currency  VARCHAR2
    , p_transaction_date  date
    , p_amount  NUMBER
    , x_contract_currency out nocopy  VARCHAR2
    , x_currency_conversion_type out nocopy  VARCHAR2
    , x_currency_conversion_rate out nocopy  NUMBER
    , x_currency_conversion_date out nocopy  DATE
    , x_converted_amount out nocopy  NUMBER
  )

  as
    ddp_transaction_date date;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any


    ddp_transaction_date := rosetta_g_miss_date_in_map(p_transaction_date);







    -- here's the delegated call to the old PL/SQL routine
    okl_accounting_util.convert_to_contract_currency(p_khr_id,
      p_from_currency,
      ddp_transaction_date,
      p_amount,
      x_contract_currency,
      x_currency_conversion_type,
      x_currency_conversion_rate,
      x_currency_conversion_date,
      x_converted_amount);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

  procedure convert_to_contract_currency(p_khr_id  NUMBER
    , p_from_currency  VARCHAR2
    , p_transaction_date  date
    , p_amount  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_contract_currency out nocopy  VARCHAR2
    , x_currency_conversion_type out nocopy  VARCHAR2
    , x_currency_conversion_rate out nocopy  NUMBER
    , x_currency_conversion_date out nocopy  DATE
    , x_converted_amount out nocopy  NUMBER
  )

  as
    ddp_transaction_date date;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any


    ddp_transaction_date := rosetta_g_miss_date_in_map(p_transaction_date);








    -- here's the delegated call to the old PL/SQL routine
    okl_accounting_util.convert_to_contract_currency(p_khr_id,
      p_from_currency,
      ddp_transaction_date,
      p_amount,
      x_return_status,
      x_contract_currency,
      x_currency_conversion_type,
      x_currency_conversion_rate,
      x_currency_conversion_date,
      x_converted_amount);

    -- copy data back from the local variables to OUT or IN-OUT args, if any









  end;

  function get_valid_gl_date(p_gl_date  date
    , p_ledger_id  NUMBER
  ) return date

  as
    ddp_gl_date date;
    ddindx binary_integer; indx binary_integer;
    ddrosetta_retval date;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    ddp_gl_date := rosetta_g_miss_date_in_map(p_gl_date);


    -- here's the delegated call to the old PL/SQL routine
    ddrosetta_retval := okl_accounting_util.get_valid_gl_date(ddp_gl_date,
      p_ledger_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any


    return ddrosetta_retval;
  end;

end okl_accounting_util_w;

/
