--------------------------------------------------------
--  DDL for Package Body OKL_POPULATE_PRCENG_RST_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_POPULATE_PRCENG_RST_PUB_W" as
  /* $Header: OKLUPRSB.pls 120.1 2005/05/30 12:32:04 kthiruva noship $ */
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

  procedure rosetta_table_copy_in_p19(t out nocopy okl_populate_prceng_rst_pub.strm_tbl_type, a0 JTF_VARCHAR2_TABLE_200
    , a1 JTF_VARCHAR2_TABLE_200
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
          t(ddindx).strm_name := a0(indx);
          t(ddindx).strm_desc := a1(indx);
          t(ddindx).sre_date := a2(indx);
          t(ddindx).amount := rosetta_g_miss_num_map(a3(indx));
          t(ddindx).index_number := rosetta_g_miss_num_map(a4(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p19;
  procedure rosetta_table_copy_out_p19(t okl_populate_prceng_rst_pub.strm_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_200
    , a1 out nocopy JTF_VARCHAR2_TABLE_200
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_200();
    a1 := JTF_VARCHAR2_TABLE_200();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_VARCHAR2_TABLE_200();
      a1 := JTF_VARCHAR2_TABLE_200();
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
          a0(indx) := t(ddindx).strm_name;
          a1(indx) := t(ddindx).strm_desc;
          a2(indx) := t(ddindx).sre_date;
          a3(indx) := rosetta_g_miss_num_map(t(ddindx).amount);
          a4(indx) := rosetta_g_miss_num_map(t(ddindx).index_number);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p19;

  procedure rosetta_table_copy_in_p21(t out nocopy okl_populate_prceng_rst_pub.strm_excp_tbl_type, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_VARCHAR2_TABLE_300
    , a2 JTF_VARCHAR2_TABLE_1000
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).error_code := a0(indx);
          t(ddindx).error_message := a1(indx);
          t(ddindx).tag_name := a2(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p21;
  procedure rosetta_table_copy_out_p21(t okl_populate_prceng_rst_pub.strm_excp_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_100
    , a1 out nocopy JTF_VARCHAR2_TABLE_300
    , a2 out nocopy JTF_VARCHAR2_TABLE_1000
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_100();
    a1 := JTF_VARCHAR2_TABLE_300();
    a2 := JTF_VARCHAR2_TABLE_1000();
  else
      a0 := JTF_VARCHAR2_TABLE_100();
      a1 := JTF_VARCHAR2_TABLE_300();
      a2 := JTF_VARCHAR2_TABLE_1000();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).error_code;
          a1(indx) := t(ddindx).error_message;
          a2(indx) := t(ddindx).tag_name;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p21;

  procedure populate_sif_ret_strms(x_return_status out nocopy  VARCHAR2
    , p_index_number  NUMBER
    , p2_a0 JTF_VARCHAR2_TABLE_200
    , p2_a1 JTF_VARCHAR2_TABLE_200
    , p2_a2 JTF_VARCHAR2_TABLE_100
    , p2_a3 JTF_NUMBER_TABLE
    , p2_a4 JTF_NUMBER_TABLE
    , p_sir_id  NUMBER
  )

  as
    ddp_strm_tbl okl_populate_prceng_rst_pub.strm_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any


    okl_populate_prceng_rst_pub_w.rosetta_table_copy_in_p19(ddp_strm_tbl, p2_a0
      , p2_a1
      , p2_a2
      , p2_a3
      , p2_a4
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_populate_prceng_rst_pub.populate_sif_ret_strms(x_return_status,
      p_index_number,
      ddp_strm_tbl,
      p_sir_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any



  end;

  procedure populate_sif_ret_errors(x_return_status out nocopy  VARCHAR2
    , x_id out nocopy  NUMBER
    , p_sir_id  NUMBER
    , p3_a0 JTF_VARCHAR2_TABLE_100
    , p3_a1 JTF_VARCHAR2_TABLE_300
    , p3_a2 JTF_VARCHAR2_TABLE_1000
    , p_tag_attribute_name  VARCHAR2
    , p_tag_attribute_value  VARCHAR2
    , p_description  VARCHAR2
  )

  as
    ddp_strm_excp_tbl okl_populate_prceng_rst_pub.strm_excp_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any



    okl_populate_prceng_rst_pub_w.rosetta_table_copy_in_p21(ddp_strm_excp_tbl, p3_a0
      , p3_a1
      , p3_a2
      );




    -- here's the delegated call to the old PL/SQL routine
    okl_populate_prceng_rst_pub.populate_sif_ret_errors(x_return_status,
      x_id,
      p_sir_id,
      ddp_strm_excp_tbl,
      p_tag_attribute_name,
      p_tag_attribute_value,
      p_description);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






  end;

end okl_populate_prceng_rst_pub_w;

/
