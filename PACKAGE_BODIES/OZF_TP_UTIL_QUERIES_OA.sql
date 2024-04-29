--------------------------------------------------------
--  DDL for Package Body OZF_TP_UTIL_QUERIES_OA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_TP_UTIL_QUERIES_OA" as
  /* $Header: ozfatpqb.pls 115.0 2003/11/07 18:45:31 gramanat noship $ */
  procedure rosetta_table_copy_in_p1(t out nocopy ozf_tp_util_queries.qualifier_tbl_type, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).qualifier_context := a0(indx);
          t(ddindx).qualifier_attribute := a1(indx);
          t(ddindx).qualifier_attr_value := a2(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p1;
  procedure rosetta_table_copy_out_p1(t ozf_tp_util_queries.qualifier_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_100
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_100();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_VARCHAR2_TABLE_100();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_VARCHAR2_TABLE_100();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).qualifier_context;
          a1(indx) := t(ddindx).qualifier_attribute;
          a2(indx) := t(ddindx).qualifier_attr_value;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p1;

  procedure get_list_price(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_obj_id  NUMBER
    , p_obj_type  VARCHAR2
    , p_product_attribute  VARCHAR2
    , p_product_attr_value  VARCHAR2
    , p_fcst_uom  VARCHAR2
    , p_currency_code  VARCHAR2
    , p_price_list_id  NUMBER
    , p10_a0 JTF_VARCHAR2_TABLE_100
    , p10_a1 JTF_VARCHAR2_TABLE_100
    , p10_a2 JTF_VARCHAR2_TABLE_100
    , x_list_price out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_qualifier_tbl ozf_tp_util_queries.qualifier_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any










    ozf_tp_util_queries_oa.rosetta_table_copy_in_p1(ddp_qualifier_tbl, p10_a0
      , p10_a1
      , p10_a2
      );





    -- here's the delegated call to the old PL/SQL routine
    ozf_tp_util_queries.get_list_price(p_api_version,
      p_init_msg_list,
      p_commit,
      p_obj_id,
      p_obj_type,
      p_product_attribute,
      p_product_attr_value,
      p_fcst_uom,
      p_currency_code,
      p_price_list_id,
      ddp_qualifier_tbl,
      x_list_price,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any














  end;

end ozf_tp_util_queries_oa;

/
