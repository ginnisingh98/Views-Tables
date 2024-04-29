--------------------------------------------------------
--  DDL for Package Body QP_UTIL_OA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QP_UTIL_OA" as
  /* $Header: ozfaqpub.pls 115.0 2003/11/07 18:45:30 gramanat noship $ */
  procedure rosetta_table_copy_in_p1(t out nocopy qp_util.v_segs_upg_tab, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).context_code := a0(indx);
          t(ddindx).segment_name := a1(indx);
          t(ddindx).sequence := a2(indx);
          t(ddindx).datatype := a3(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p1;
  procedure rosetta_table_copy_out_p1(t qp_util.v_segs_upg_tab, a0 out nocopy JTF_VARCHAR2_TABLE_100
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_100();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_VARCHAR2_TABLE_100();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_VARCHAR2_TABLE_100();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        a3.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).context_code;
          a1(indx) := t(ddindx).segment_name;
          a2(indx) := t(ddindx).sequence;
          a3(indx) := t(ddindx).datatype;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p1;

  procedure rosetta_table_copy_in_p39(t out nocopy qp_util.create_context_out_tbl, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_VARCHAR2_TABLE_300
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).context_code := a0(indx);
          t(ddindx).context_name := a1(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p39;
  procedure rosetta_table_copy_out_p39(t qp_util.create_context_out_tbl, a0 out nocopy JTF_VARCHAR2_TABLE_100
    , a1 out nocopy JTF_VARCHAR2_TABLE_300
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_100();
    a1 := JTF_VARCHAR2_TABLE_300();
  else
      a0 := JTF_VARCHAR2_TABLE_100();
      a1 := JTF_VARCHAR2_TABLE_300();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).context_code;
          a1(indx) := t(ddindx).context_name;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p39;

  procedure rosetta_table_copy_in_p41(t out nocopy qp_util.create_attribute_out_tbl, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_VARCHAR2_TABLE_300
    , a2 JTF_VARCHAR2_TABLE_100
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
          t(ddindx).segment_mapping_column := a0(indx);
          t(ddindx).segment_name := a1(indx);
          t(ddindx).segment_code := a2(indx);
          t(ddindx).precedence := a3(indx);
          t(ddindx).valueset_id := a4(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p41;
  procedure rosetta_table_copy_out_p41(t qp_util.create_attribute_out_tbl, a0 out nocopy JTF_VARCHAR2_TABLE_100
    , a1 out nocopy JTF_VARCHAR2_TABLE_300
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_100();
    a1 := JTF_VARCHAR2_TABLE_300();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_VARCHAR2_TABLE_100();
      a1 := JTF_VARCHAR2_TABLE_300();
      a2 := JTF_VARCHAR2_TABLE_100();
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
          a0(indx) := t(ddindx).segment_mapping_column;
          a1(indx) := t(ddindx).segment_name;
          a2(indx) := t(ddindx).segment_code;
          a3(indx) := t(ddindx).precedence;
          a4(indx) := t(ddindx).valueset_id;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p41;

  procedure validate_qp_flexfield(flexfield_name  VARCHAR2
    , context  VARCHAR2
    , attribute  VARCHAR2
    , value  VARCHAR2
    , application_short_name  VARCHAR2
    , context_flag out nocopy  VARCHAR2
    , attribute_flag out nocopy  VARCHAR2
    , value_flag out nocopy  VARCHAR2
    , datatype out nocopy  VARCHAR2
    , precedence out nocopy  VARCHAR2
    , error_code out nocopy  NUMBER
    , check_enabled  number
  )

  as
    ddcheck_enabled boolean;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any











    if check_enabled is null
      then ddcheck_enabled := null;
    elsif check_enabled = 0
      then ddcheck_enabled := false;
    else ddcheck_enabled := true;
    end if;

    -- here's the delegated call to the old PL/SQL routine
    qp_util.validate_qp_flexfield(flexfield_name,
      context,
      attribute,
      value,
      application_short_name,
      context_flag,
      attribute_flag,
      value_flag,
      datatype,
      precedence,
      error_code,
      ddcheck_enabled);

    -- copy data back from the local variables to OUT or IN-OUT args, if any











  end;

  procedure get_segs_for_flex(flexfield_name  VARCHAR2
    , application_short_name  VARCHAR2
    , p2_a0 out nocopy JTF_VARCHAR2_TABLE_100
    , p2_a1 out nocopy JTF_VARCHAR2_TABLE_100
    , p2_a2 out nocopy JTF_NUMBER_TABLE
    , p2_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , error_code out nocopy  NUMBER
  )

  as
    ddx_segs_upg_t qp_util.v_segs_upg_tab;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    -- here's the delegated call to the old PL/SQL routine
    qp_util.get_segs_for_flex(flexfield_name,
      application_short_name,
      ddx_segs_upg_t,
      error_code);

    -- copy data back from the local variables to OUT or IN-OUT args, if any


    qp_util_oa.rosetta_table_copy_out_p1(ddx_segs_upg_t, p2_a0
      , p2_a1
      , p2_a2
      , p2_a3
      );

  end;

  procedure get_segs_flex_precedence(p0_a0 JTF_VARCHAR2_TABLE_100
    , p0_a1 JTF_VARCHAR2_TABLE_100
    , p0_a2 JTF_NUMBER_TABLE
    , p0_a3 JTF_VARCHAR2_TABLE_100
    , p_context  VARCHAR2
    , p_attribute  VARCHAR2
    , x_precedence out nocopy  NUMBER
    , x_datatype out nocopy  VARCHAR2
  )

  as
    ddp_segs_upg_t qp_util.v_segs_upg_tab;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    qp_util_oa.rosetta_table_copy_in_p1(ddp_segs_upg_t, p0_a0
      , p0_a1
      , p0_a2
      , p0_a3
      );





    -- here's the delegated call to the old PL/SQL routine
    qp_util.get_segs_flex_precedence(ddp_segs_upg_t,
      p_context,
      p_attribute,
      x_precedence,
      x_datatype);

    -- copy data back from the local variables to OUT or IN-OUT args, if any




  end;

  procedure web_create_context_lov(p_field_context  VARCHAR2
    , p_context_type  VARCHAR2
    , p_check_enabled  VARCHAR2
    , p_limits  VARCHAR2
    , p_list_line_type_code  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , p6_a0 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a1 out nocopy JTF_VARCHAR2_TABLE_300
  )

  as
    ddx_context_out_tbl qp_util.create_context_out_tbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    -- here's the delegated call to the old PL/SQL routine
    qp_util.web_create_context_lov(p_field_context,
      p_context_type,
      p_check_enabled,
      p_limits,
      p_list_line_type_code,
      x_return_status,
      ddx_context_out_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    qp_util_oa.rosetta_table_copy_out_p39(ddx_context_out_tbl, p6_a0
      , p6_a1
      );
  end;

  procedure web_create_attribute_lov(p_context_code  VARCHAR2
    , p_context_type  VARCHAR2
    , p_check_enabled  VARCHAR2
    , p_limits  VARCHAR2
    , p_list_line_type_code  VARCHAR2
    , p_segment_level  NUMBER
    , p_field_context  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , p8_a0 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a1 out nocopy JTF_VARCHAR2_TABLE_300
    , p8_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p8_a3 out nocopy JTF_NUMBER_TABLE
    , p8_a4 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddx_attribute_out_tbl qp_util.create_attribute_out_tbl;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any









    -- here's the delegated call to the old PL/SQL routine
    qp_util.web_create_attribute_lov(p_context_code,
      p_context_type,
      p_check_enabled,
      p_limits,
      p_list_line_type_code,
      p_segment_level,
      p_field_context,
      x_return_status,
      ddx_attribute_out_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








    qp_util_oa.rosetta_table_copy_out_p41(ddx_attribute_out_tbl, p8_a0
      , p8_a1
      , p8_a2
      , p8_a3
      , p8_a4
      );
  end;

end qp_util_oa;

/
