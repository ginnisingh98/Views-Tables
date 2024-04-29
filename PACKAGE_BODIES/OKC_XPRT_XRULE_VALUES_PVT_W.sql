--------------------------------------------------------
--  DDL for Package Body OKC_XPRT_XRULE_VALUES_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_XPRT_XRULE_VALUES_PVT_W" as
  /* $Header: OKCWXXRULVB.pls 120.3 2005/12/14 16:11 arsundar noship $ */
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

  procedure rosetta_table_copy_in_p4(t out nocopy okc_xprt_xrule_values_pvt.sys_var_value_tbl_type, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_VARCHAR2_TABLE_2500
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).variable_code := a0(indx);
          t(ddindx).variable_value_id := a1(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p4;
  procedure rosetta_table_copy_out_p4(t okc_xprt_xrule_values_pvt.sys_var_value_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_100
    , a1 out nocopy JTF_VARCHAR2_TABLE_2500
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_100();
    a1 := JTF_VARCHAR2_TABLE_2500();
  else
      a0 := JTF_VARCHAR2_TABLE_100();
      a1 := JTF_VARCHAR2_TABLE_2500();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).variable_code;
          a1(indx) := t(ddindx).variable_value_id;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p4;

  procedure rosetta_table_copy_in_p5(t out nocopy okc_xprt_xrule_values_pvt.category_tbl_type, a0 JTF_VARCHAR2_TABLE_2000
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).category_name := a0(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p5;
  procedure rosetta_table_copy_out_p5(t okc_xprt_xrule_values_pvt.category_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_2000
    ) as
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
          a0(indx) := t(ddindx).category_name;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p5;

  procedure rosetta_table_copy_in_p6(t out nocopy okc_xprt_xrule_values_pvt.item_tbl_type, a0 JTF_VARCHAR2_TABLE_2000
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).name := a0(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p6;
  procedure rosetta_table_copy_out_p6(t okc_xprt_xrule_values_pvt.item_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_2000
    ) as
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
          a0(indx) := t(ddindx).name;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p6;

  procedure rosetta_table_copy_in_p7(t out nocopy okc_xprt_xrule_values_pvt.constant_tbl_type, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).constant_id := a0(indx);
          t(ddindx).value := a1(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p7;
  procedure rosetta_table_copy_out_p7(t okc_xprt_xrule_values_pvt.constant_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_100
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_100();
    a1 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_VARCHAR2_TABLE_100();
      a1 := JTF_VARCHAR2_TABLE_100();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).constant_id;
          a1(indx) := t(ddindx).value;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p7;

  procedure rosetta_table_copy_in_p9(t out nocopy okc_xprt_xrule_values_pvt.line_sys_var_value_tbl_type, a0 JTF_VARCHAR2_TABLE_300
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_2500
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).line_number := a0(indx);
          t(ddindx).variable_code := a1(indx);
          t(ddindx).variable_value := a2(indx);
          t(ddindx).item_id := rosetta_g_miss_num_map(a3(indx));
          t(ddindx).org_id := rosetta_g_miss_num_map(a4(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p9;
  procedure rosetta_table_copy_out_p9(t okc_xprt_xrule_values_pvt.line_sys_var_value_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_300
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_2500
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_300();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_VARCHAR2_TABLE_2500();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_VARCHAR2_TABLE_300();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_VARCHAR2_TABLE_2500();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_NUMBER_TABLE();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        a3.extend(t.count);
        a4.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).line_number;
          a1(indx) := t(ddindx).variable_code;
          a2(indx) := t(ddindx).variable_value;
          a3(indx) := rosetta_g_miss_num_map(t(ddindx).item_id);
          a4(indx) := rosetta_g_miss_num_map(t(ddindx).org_id);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p9;

  procedure rosetta_table_copy_in_p10(t out nocopy okc_xprt_xrule_values_pvt.udf_var_value_tbl_type, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_VARCHAR2_TABLE_2500
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).variable_code := a0(indx);
          t(ddindx).variable_value_id := a1(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p10;
  procedure rosetta_table_copy_out_p10(t okc_xprt_xrule_values_pvt.udf_var_value_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_100
    , a1 out nocopy JTF_VARCHAR2_TABLE_2500
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_100();
    a1 := JTF_VARCHAR2_TABLE_2500();
  else
      a0 := JTF_VARCHAR2_TABLE_100();
      a1 := JTF_VARCHAR2_TABLE_2500();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).variable_code;
          a1(indx) := t(ddindx).variable_value_id;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p10;

  procedure rosetta_table_copy_in_p11(t out nocopy okc_xprt_xrule_values_pvt.var_value_tbl_type, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_VARCHAR2_TABLE_2500
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).variable_code := a0(indx);
          t(ddindx).variable_value_id := a1(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p11;
  procedure rosetta_table_copy_out_p11(t okc_xprt_xrule_values_pvt.var_value_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_100
    , a1 out nocopy JTF_VARCHAR2_TABLE_2500
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_100();
    a1 := JTF_VARCHAR2_TABLE_2500();
  else
      a0 := JTF_VARCHAR2_TABLE_100();
      a1 := JTF_VARCHAR2_TABLE_2500();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).variable_code;
          a1(indx) := t(ddindx).variable_value_id;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p11;

  procedure get_system_variables(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_data out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , p_doc_type  VARCHAR2
    , p_doc_id  NUMBER
    , p_only_doc_variables  VARCHAR2
    , p8_a0 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a1 out nocopy JTF_VARCHAR2_TABLE_2500
  )

  as
    ddx_sys_var_value_tbl okc_xprt_xrule_values_pvt.var_value_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any









    -- here's the delegated call to the old PL/SQL routine
    okc_xprt_xrule_values_pvt.get_system_variables(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_data,
      x_msg_count,
      p_doc_type,
      p_doc_id,
      p_only_doc_variables,
      ddx_sys_var_value_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








    okc_xprt_xrule_values_pvt_w.rosetta_table_copy_out_p11(ddx_sys_var_value_tbl, p8_a0
      , p8_a1
      );
  end;

  procedure get_constant_values(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_intent  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_data out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , p6_a0 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a1 out nocopy JTF_VARCHAR2_TABLE_100
  )

  as
    ddx_constant_tbl okc_xprt_xrule_values_pvt.constant_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    -- here's the delegated call to the old PL/SQL routine
    okc_xprt_xrule_values_pvt.get_constant_values(p_api_version,
      p_init_msg_list,
      p_intent,
      x_return_status,
      x_msg_data,
      x_msg_count,
      ddx_constant_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okc_xprt_xrule_values_pvt_w.rosetta_table_copy_out_p7(ddx_constant_tbl, p6_a0
      , p6_a1
      );
  end;

  procedure get_line_system_variables(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_doc_type  VARCHAR2
    , p_doc_id  NUMBER
    , p_org_id  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_data out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , p8_a0 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a2 out nocopy JTF_VARCHAR2_TABLE_2500
    , p8_a3 out nocopy JTF_NUMBER_TABLE
    , p8_a4 out nocopy JTF_NUMBER_TABLE
    , x_line_count out nocopy  NUMBER
    , x_line_variables_count out nocopy  NUMBER
  )

  as
    ddx_line_sys_var_value_tbl okc_xprt_xrule_values_pvt.line_sys_var_value_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any











    -- here's the delegated call to the old PL/SQL routine
    okc_xprt_xrule_values_pvt.get_line_system_variables(p_api_version,
      p_init_msg_list,
      p_doc_type,
      p_doc_id,
      p_org_id,
      x_return_status,
      x_msg_data,
      x_msg_count,
      ddx_line_sys_var_value_tbl,
      x_line_count,
      x_line_variables_count);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








    okc_xprt_xrule_values_pvt_w.rosetta_table_copy_out_p9(ddx_line_sys_var_value_tbl, p8_a0
      , p8_a1
      , p8_a2
      , p8_a3
      , p8_a4
      );


  end;

  procedure get_user_defined_variables(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_doc_type  VARCHAR2
    , p_doc_id  NUMBER
    , p_org_id  NUMBER
    , p_intent  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_data out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , p9_a0 out nocopy JTF_VARCHAR2_TABLE_100
    , p9_a1 out nocopy JTF_VARCHAR2_TABLE_2500
  )

  as
    ddx_udf_var_value_tbl okc_xprt_xrule_values_pvt.udf_var_value_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any










    -- here's the delegated call to the old PL/SQL routine
    okc_xprt_xrule_values_pvt.get_user_defined_variables(p_api_version,
      p_init_msg_list,
      p_doc_type,
      p_doc_id,
      p_org_id,
      p_intent,
      x_return_status,
      x_msg_data,
      x_msg_count,
      ddx_udf_var_value_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any









    okc_xprt_xrule_values_pvt_w.rosetta_table_copy_out_p10(ddx_udf_var_value_tbl, p9_a0
      , p9_a1
      );
  end;

  procedure get_document_values(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_doc_type  VARCHAR2
    , p_doc_id  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_data out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , p7_a0 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a1 out nocopy JTF_VARCHAR2_TABLE_2500
    , p8_a0 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a2 out nocopy JTF_VARCHAR2_TABLE_2500
    , p8_a3 out nocopy JTF_NUMBER_TABLE
    , p8_a4 out nocopy JTF_NUMBER_TABLE
    , x_line_count out nocopy  NUMBER
    , x_line_variables_count out nocopy  NUMBER
    , x_intent out nocopy  VARCHAR2
    , x_org_id out nocopy  NUMBER
  )

  as
    ddx_hdr_var_value_tbl okc_xprt_xrule_values_pvt.var_value_tbl_type;
    ddx_line_sysvar_value_tbl okc_xprt_xrule_values_pvt.line_sys_var_value_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any













    -- here's the delegated call to the old PL/SQL routine
    okc_xprt_xrule_values_pvt.get_document_values(p_api_version,
      p_init_msg_list,
      p_doc_type,
      p_doc_id,
      x_return_status,
      x_msg_data,
      x_msg_count,
      ddx_hdr_var_value_tbl,
      ddx_line_sysvar_value_tbl,
      x_line_count,
      x_line_variables_count,
      x_intent,
      x_org_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







    okc_xprt_xrule_values_pvt_w.rosetta_table_copy_out_p11(ddx_hdr_var_value_tbl, p7_a0
      , p7_a1
      );

    okc_xprt_xrule_values_pvt_w.rosetta_table_copy_out_p9(ddx_line_sysvar_value_tbl, p8_a0
      , p8_a1
      , p8_a2
      , p8_a3
      , p8_a4
      );




  end;

end okc_xprt_xrule_values_pvt_w;

/
