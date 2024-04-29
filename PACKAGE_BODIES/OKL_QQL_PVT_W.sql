--------------------------------------------------------
--  DDL for Package Body OKL_QQL_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_QQL_PVT_W" as
  /* $Header: OKLIQQLB.pls 120.0 2005/09/27 05:29:45 schodava noship $ */
  procedure rosetta_table_copy_in_p23(t out nocopy okl_qql_pvt.qqlv_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_VARCHAR2_TABLE_500
    , a4 JTF_VARCHAR2_TABLE_500
    , a5 JTF_VARCHAR2_TABLE_500
    , a6 JTF_VARCHAR2_TABLE_500
    , a7 JTF_VARCHAR2_TABLE_500
    , a8 JTF_VARCHAR2_TABLE_500
    , a9 JTF_VARCHAR2_TABLE_500
    , a10 JTF_VARCHAR2_TABLE_500
    , a11 JTF_VARCHAR2_TABLE_500
    , a12 JTF_VARCHAR2_TABLE_500
    , a13 JTF_VARCHAR2_TABLE_500
    , a14 JTF_VARCHAR2_TABLE_500
    , a15 JTF_VARCHAR2_TABLE_500
    , a16 JTF_VARCHAR2_TABLE_500
    , a17 JTF_VARCHAR2_TABLE_500
    , a18 JTF_NUMBER_TABLE
    , a19 JTF_VARCHAR2_TABLE_100
    , a20 JTF_VARCHAR2_TABLE_100
    , a21 JTF_NUMBER_TABLE
    , a22 JTF_NUMBER_TABLE
    , a23 JTF_NUMBER_TABLE
    , a24 JTF_NUMBER_TABLE
    , a25 JTF_NUMBER_TABLE
    , a26 JTF_NUMBER_TABLE
    , a27 JTF_NUMBER_TABLE
    , a28 JTF_VARCHAR2_TABLE_300
    , a29 JTF_VARCHAR2_TABLE_2000
    , a30 JTF_VARCHAR2_TABLE_2000
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).id := a0(indx);
          t(ddindx).object_version_number := a1(indx);
          t(ddindx).attribute_category := a2(indx);
          t(ddindx).attribute1 := a3(indx);
          t(ddindx).attribute2 := a4(indx);
          t(ddindx).attribute3 := a5(indx);
          t(ddindx).attribute4 := a6(indx);
          t(ddindx).attribute5 := a7(indx);
          t(ddindx).attribute6 := a8(indx);
          t(ddindx).attribute7 := a9(indx);
          t(ddindx).attribute8 := a10(indx);
          t(ddindx).attribute9 := a11(indx);
          t(ddindx).attribute10 := a12(indx);
          t(ddindx).attribute11 := a13(indx);
          t(ddindx).attribute12 := a14(indx);
          t(ddindx).attribute13 := a15(indx);
          t(ddindx).attribute14 := a16(indx);
          t(ddindx).attribute15 := a17(indx);
          t(ddindx).quick_quote_id := a18(indx);
          t(ddindx).type := a19(indx);
          t(ddindx).basis := a20(indx);
          t(ddindx).value := a21(indx);
          t(ddindx).end_of_term_value_default := a22(indx);
          t(ddindx).end_of_term_value := a23(indx);
          t(ddindx).percentage_of_total_cost := a24(indx);
          t(ddindx).item_category_id := a25(indx);
          t(ddindx).item_category_set_id := a26(indx);
          t(ddindx).lease_rate_factor := a27(indx);
          t(ddindx).short_description := a28(indx);
          t(ddindx).description := a29(indx);
          t(ddindx).comments := a30(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p23;
  procedure rosetta_table_copy_out_p23(t okl_qql_pvt.qqlv_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_VARCHAR2_TABLE_500
    , a4 out nocopy JTF_VARCHAR2_TABLE_500
    , a5 out nocopy JTF_VARCHAR2_TABLE_500
    , a6 out nocopy JTF_VARCHAR2_TABLE_500
    , a7 out nocopy JTF_VARCHAR2_TABLE_500
    , a8 out nocopy JTF_VARCHAR2_TABLE_500
    , a9 out nocopy JTF_VARCHAR2_TABLE_500
    , a10 out nocopy JTF_VARCHAR2_TABLE_500
    , a11 out nocopy JTF_VARCHAR2_TABLE_500
    , a12 out nocopy JTF_VARCHAR2_TABLE_500
    , a13 out nocopy JTF_VARCHAR2_TABLE_500
    , a14 out nocopy JTF_VARCHAR2_TABLE_500
    , a15 out nocopy JTF_VARCHAR2_TABLE_500
    , a16 out nocopy JTF_VARCHAR2_TABLE_500
    , a17 out nocopy JTF_VARCHAR2_TABLE_500
    , a18 out nocopy JTF_NUMBER_TABLE
    , a19 out nocopy JTF_VARCHAR2_TABLE_100
    , a20 out nocopy JTF_VARCHAR2_TABLE_100
    , a21 out nocopy JTF_NUMBER_TABLE
    , a22 out nocopy JTF_NUMBER_TABLE
    , a23 out nocopy JTF_NUMBER_TABLE
    , a24 out nocopy JTF_NUMBER_TABLE
    , a25 out nocopy JTF_NUMBER_TABLE
    , a26 out nocopy JTF_NUMBER_TABLE
    , a27 out nocopy JTF_NUMBER_TABLE
    , a28 out nocopy JTF_VARCHAR2_TABLE_300
    , a29 out nocopy JTF_VARCHAR2_TABLE_2000
    , a30 out nocopy JTF_VARCHAR2_TABLE_2000
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_VARCHAR2_TABLE_500();
    a4 := JTF_VARCHAR2_TABLE_500();
    a5 := JTF_VARCHAR2_TABLE_500();
    a6 := JTF_VARCHAR2_TABLE_500();
    a7 := JTF_VARCHAR2_TABLE_500();
    a8 := JTF_VARCHAR2_TABLE_500();
    a9 := JTF_VARCHAR2_TABLE_500();
    a10 := JTF_VARCHAR2_TABLE_500();
    a11 := JTF_VARCHAR2_TABLE_500();
    a12 := JTF_VARCHAR2_TABLE_500();
    a13 := JTF_VARCHAR2_TABLE_500();
    a14 := JTF_VARCHAR2_TABLE_500();
    a15 := JTF_VARCHAR2_TABLE_500();
    a16 := JTF_VARCHAR2_TABLE_500();
    a17 := JTF_VARCHAR2_TABLE_500();
    a18 := JTF_NUMBER_TABLE();
    a19 := JTF_VARCHAR2_TABLE_100();
    a20 := JTF_VARCHAR2_TABLE_100();
    a21 := JTF_NUMBER_TABLE();
    a22 := JTF_NUMBER_TABLE();
    a23 := JTF_NUMBER_TABLE();
    a24 := JTF_NUMBER_TABLE();
    a25 := JTF_NUMBER_TABLE();
    a26 := JTF_NUMBER_TABLE();
    a27 := JTF_NUMBER_TABLE();
    a28 := JTF_VARCHAR2_TABLE_300();
    a29 := JTF_VARCHAR2_TABLE_2000();
    a30 := JTF_VARCHAR2_TABLE_2000();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_VARCHAR2_TABLE_500();
      a4 := JTF_VARCHAR2_TABLE_500();
      a5 := JTF_VARCHAR2_TABLE_500();
      a6 := JTF_VARCHAR2_TABLE_500();
      a7 := JTF_VARCHAR2_TABLE_500();
      a8 := JTF_VARCHAR2_TABLE_500();
      a9 := JTF_VARCHAR2_TABLE_500();
      a10 := JTF_VARCHAR2_TABLE_500();
      a11 := JTF_VARCHAR2_TABLE_500();
      a12 := JTF_VARCHAR2_TABLE_500();
      a13 := JTF_VARCHAR2_TABLE_500();
      a14 := JTF_VARCHAR2_TABLE_500();
      a15 := JTF_VARCHAR2_TABLE_500();
      a16 := JTF_VARCHAR2_TABLE_500();
      a17 := JTF_VARCHAR2_TABLE_500();
      a18 := JTF_NUMBER_TABLE();
      a19 := JTF_VARCHAR2_TABLE_100();
      a20 := JTF_VARCHAR2_TABLE_100();
      a21 := JTF_NUMBER_TABLE();
      a22 := JTF_NUMBER_TABLE();
      a23 := JTF_NUMBER_TABLE();
      a24 := JTF_NUMBER_TABLE();
      a25 := JTF_NUMBER_TABLE();
      a26 := JTF_NUMBER_TABLE();
      a27 := JTF_NUMBER_TABLE();
      a28 := JTF_VARCHAR2_TABLE_300();
      a29 := JTF_VARCHAR2_TABLE_2000();
      a30 := JTF_VARCHAR2_TABLE_2000();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).id;
          a1(indx) := t(ddindx).object_version_number;
          a2(indx) := t(ddindx).attribute_category;
          a3(indx) := t(ddindx).attribute1;
          a4(indx) := t(ddindx).attribute2;
          a5(indx) := t(ddindx).attribute3;
          a6(indx) := t(ddindx).attribute4;
          a7(indx) := t(ddindx).attribute5;
          a8(indx) := t(ddindx).attribute6;
          a9(indx) := t(ddindx).attribute7;
          a10(indx) := t(ddindx).attribute8;
          a11(indx) := t(ddindx).attribute9;
          a12(indx) := t(ddindx).attribute10;
          a13(indx) := t(ddindx).attribute11;
          a14(indx) := t(ddindx).attribute12;
          a15(indx) := t(ddindx).attribute13;
          a16(indx) := t(ddindx).attribute14;
          a17(indx) := t(ddindx).attribute15;
          a18(indx) := t(ddindx).quick_quote_id;
          a19(indx) := t(ddindx).type;
          a20(indx) := t(ddindx).basis;
          a21(indx) := t(ddindx).value;
          a22(indx) := t(ddindx).end_of_term_value_default;
          a23(indx) := t(ddindx).end_of_term_value;
          a24(indx) := t(ddindx).percentage_of_total_cost;
          a25(indx) := t(ddindx).item_category_id;
          a26(indx) := t(ddindx).item_category_set_id;
          a27(indx) := t(ddindx).lease_rate_factor;
          a28(indx) := t(ddindx).short_description;
          a29(indx) := t(ddindx).description;
          a30(indx) := t(ddindx).comments;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p23;

  procedure insert_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_VARCHAR2_TABLE_100
    , p5_a3 JTF_VARCHAR2_TABLE_500
    , p5_a4 JTF_VARCHAR2_TABLE_500
    , p5_a5 JTF_VARCHAR2_TABLE_500
    , p5_a6 JTF_VARCHAR2_TABLE_500
    , p5_a7 JTF_VARCHAR2_TABLE_500
    , p5_a8 JTF_VARCHAR2_TABLE_500
    , p5_a9 JTF_VARCHAR2_TABLE_500
    , p5_a10 JTF_VARCHAR2_TABLE_500
    , p5_a11 JTF_VARCHAR2_TABLE_500
    , p5_a12 JTF_VARCHAR2_TABLE_500
    , p5_a13 JTF_VARCHAR2_TABLE_500
    , p5_a14 JTF_VARCHAR2_TABLE_500
    , p5_a15 JTF_VARCHAR2_TABLE_500
    , p5_a16 JTF_VARCHAR2_TABLE_500
    , p5_a17 JTF_VARCHAR2_TABLE_500
    , p5_a18 JTF_NUMBER_TABLE
    , p5_a19 JTF_VARCHAR2_TABLE_100
    , p5_a20 JTF_VARCHAR2_TABLE_100
    , p5_a21 JTF_NUMBER_TABLE
    , p5_a22 JTF_NUMBER_TABLE
    , p5_a23 JTF_NUMBER_TABLE
    , p5_a24 JTF_NUMBER_TABLE
    , p5_a25 JTF_NUMBER_TABLE
    , p5_a26 JTF_NUMBER_TABLE
    , p5_a27 JTF_NUMBER_TABLE
    , p5_a28 JTF_VARCHAR2_TABLE_300
    , p5_a29 JTF_VARCHAR2_TABLE_2000
    , p5_a30 JTF_VARCHAR2_TABLE_2000
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a3 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a4 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a5 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a6 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a7 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a8 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a9 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a10 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a11 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a12 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a13 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a14 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a15 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a16 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a17 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a18 out nocopy JTF_NUMBER_TABLE
    , p6_a19 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a20 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a21 out nocopy JTF_NUMBER_TABLE
    , p6_a22 out nocopy JTF_NUMBER_TABLE
    , p6_a23 out nocopy JTF_NUMBER_TABLE
    , p6_a24 out nocopy JTF_NUMBER_TABLE
    , p6_a25 out nocopy JTF_NUMBER_TABLE
    , p6_a26 out nocopy JTF_NUMBER_TABLE
    , p6_a27 out nocopy JTF_NUMBER_TABLE
    , p6_a28 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a29 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a30 out nocopy JTF_VARCHAR2_TABLE_2000
  )

  as
    ddp_qqlv_tbl okl_qql_pvt.qqlv_tbl_type;
    ddx_qqlv_tbl okl_qql_pvt.qqlv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_qql_pvt_w.rosetta_table_copy_in_p23(ddp_qqlv_tbl, p5_a0
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
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_qql_pvt.insert_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_qqlv_tbl,
      ddx_qqlv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_qql_pvt_w.rosetta_table_copy_out_p23(ddx_qqlv_tbl, p6_a0
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
      );
  end;

  procedure update_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_VARCHAR2_TABLE_100
    , p5_a3 JTF_VARCHAR2_TABLE_500
    , p5_a4 JTF_VARCHAR2_TABLE_500
    , p5_a5 JTF_VARCHAR2_TABLE_500
    , p5_a6 JTF_VARCHAR2_TABLE_500
    , p5_a7 JTF_VARCHAR2_TABLE_500
    , p5_a8 JTF_VARCHAR2_TABLE_500
    , p5_a9 JTF_VARCHAR2_TABLE_500
    , p5_a10 JTF_VARCHAR2_TABLE_500
    , p5_a11 JTF_VARCHAR2_TABLE_500
    , p5_a12 JTF_VARCHAR2_TABLE_500
    , p5_a13 JTF_VARCHAR2_TABLE_500
    , p5_a14 JTF_VARCHAR2_TABLE_500
    , p5_a15 JTF_VARCHAR2_TABLE_500
    , p5_a16 JTF_VARCHAR2_TABLE_500
    , p5_a17 JTF_VARCHAR2_TABLE_500
    , p5_a18 JTF_NUMBER_TABLE
    , p5_a19 JTF_VARCHAR2_TABLE_100
    , p5_a20 JTF_VARCHAR2_TABLE_100
    , p5_a21 JTF_NUMBER_TABLE
    , p5_a22 JTF_NUMBER_TABLE
    , p5_a23 JTF_NUMBER_TABLE
    , p5_a24 JTF_NUMBER_TABLE
    , p5_a25 JTF_NUMBER_TABLE
    , p5_a26 JTF_NUMBER_TABLE
    , p5_a27 JTF_NUMBER_TABLE
    , p5_a28 JTF_VARCHAR2_TABLE_300
    , p5_a29 JTF_VARCHAR2_TABLE_2000
    , p5_a30 JTF_VARCHAR2_TABLE_2000
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a3 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a4 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a5 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a6 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a7 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a8 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a9 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a10 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a11 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a12 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a13 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a14 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a15 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a16 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a17 out nocopy JTF_VARCHAR2_TABLE_500
    , p6_a18 out nocopy JTF_NUMBER_TABLE
    , p6_a19 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a20 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a21 out nocopy JTF_NUMBER_TABLE
    , p6_a22 out nocopy JTF_NUMBER_TABLE
    , p6_a23 out nocopy JTF_NUMBER_TABLE
    , p6_a24 out nocopy JTF_NUMBER_TABLE
    , p6_a25 out nocopy JTF_NUMBER_TABLE
    , p6_a26 out nocopy JTF_NUMBER_TABLE
    , p6_a27 out nocopy JTF_NUMBER_TABLE
    , p6_a28 out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a29 out nocopy JTF_VARCHAR2_TABLE_2000
    , p6_a30 out nocopy JTF_VARCHAR2_TABLE_2000
  )

  as
    ddp_qqlv_tbl okl_qql_pvt.qqlv_tbl_type;
    ddx_qqlv_tbl okl_qql_pvt.qqlv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_qql_pvt_w.rosetta_table_copy_in_p23(ddp_qqlv_tbl, p5_a0
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
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_qql_pvt.update_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_qqlv_tbl,
      ddx_qqlv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_qql_pvt_w.rosetta_table_copy_out_p23(ddx_qqlv_tbl, p6_a0
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
      );
  end;

  procedure delete_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_VARCHAR2_TABLE_100
    , p5_a3 JTF_VARCHAR2_TABLE_500
    , p5_a4 JTF_VARCHAR2_TABLE_500
    , p5_a5 JTF_VARCHAR2_TABLE_500
    , p5_a6 JTF_VARCHAR2_TABLE_500
    , p5_a7 JTF_VARCHAR2_TABLE_500
    , p5_a8 JTF_VARCHAR2_TABLE_500
    , p5_a9 JTF_VARCHAR2_TABLE_500
    , p5_a10 JTF_VARCHAR2_TABLE_500
    , p5_a11 JTF_VARCHAR2_TABLE_500
    , p5_a12 JTF_VARCHAR2_TABLE_500
    , p5_a13 JTF_VARCHAR2_TABLE_500
    , p5_a14 JTF_VARCHAR2_TABLE_500
    , p5_a15 JTF_VARCHAR2_TABLE_500
    , p5_a16 JTF_VARCHAR2_TABLE_500
    , p5_a17 JTF_VARCHAR2_TABLE_500
    , p5_a18 JTF_NUMBER_TABLE
    , p5_a19 JTF_VARCHAR2_TABLE_100
    , p5_a20 JTF_VARCHAR2_TABLE_100
    , p5_a21 JTF_NUMBER_TABLE
    , p5_a22 JTF_NUMBER_TABLE
    , p5_a23 JTF_NUMBER_TABLE
    , p5_a24 JTF_NUMBER_TABLE
    , p5_a25 JTF_NUMBER_TABLE
    , p5_a26 JTF_NUMBER_TABLE
    , p5_a27 JTF_NUMBER_TABLE
    , p5_a28 JTF_VARCHAR2_TABLE_300
    , p5_a29 JTF_VARCHAR2_TABLE_2000
    , p5_a30 JTF_VARCHAR2_TABLE_2000
  )

  as
    ddp_qqlv_tbl okl_qql_pvt.qqlv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_qql_pvt_w.rosetta_table_copy_in_p23(ddp_qqlv_tbl, p5_a0
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
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_qql_pvt.delete_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_qqlv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure insert_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER
    , p5_a1  NUMBER
    , p5_a2  VARCHAR2
    , p5_a3  VARCHAR2
    , p5_a4  VARCHAR2
    , p5_a5  VARCHAR2
    , p5_a6  VARCHAR2
    , p5_a7  VARCHAR2
    , p5_a8  VARCHAR2
    , p5_a9  VARCHAR2
    , p5_a10  VARCHAR2
    , p5_a11  VARCHAR2
    , p5_a12  VARCHAR2
    , p5_a13  VARCHAR2
    , p5_a14  VARCHAR2
    , p5_a15  VARCHAR2
    , p5_a16  VARCHAR2
    , p5_a17  VARCHAR2
    , p5_a18  NUMBER
    , p5_a19  VARCHAR2
    , p5_a20  VARCHAR2
    , p5_a21  NUMBER
    , p5_a22  NUMBER
    , p5_a23  NUMBER
    , p5_a24  NUMBER
    , p5_a25  NUMBER
    , p5_a26  NUMBER
    , p5_a27  NUMBER
    , p5_a28  VARCHAR2
    , p5_a29  VARCHAR2
    , p5_a30  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  VARCHAR2
    , p6_a3 out nocopy  VARCHAR2
    , p6_a4 out nocopy  VARCHAR2
    , p6_a5 out nocopy  VARCHAR2
    , p6_a6 out nocopy  VARCHAR2
    , p6_a7 out nocopy  VARCHAR2
    , p6_a8 out nocopy  VARCHAR2
    , p6_a9 out nocopy  VARCHAR2
    , p6_a10 out nocopy  VARCHAR2
    , p6_a11 out nocopy  VARCHAR2
    , p6_a12 out nocopy  VARCHAR2
    , p6_a13 out nocopy  VARCHAR2
    , p6_a14 out nocopy  VARCHAR2
    , p6_a15 out nocopy  VARCHAR2
    , p6_a16 out nocopy  VARCHAR2
    , p6_a17 out nocopy  VARCHAR2
    , p6_a18 out nocopy  NUMBER
    , p6_a19 out nocopy  VARCHAR2
    , p6_a20 out nocopy  VARCHAR2
    , p6_a21 out nocopy  NUMBER
    , p6_a22 out nocopy  NUMBER
    , p6_a23 out nocopy  NUMBER
    , p6_a24 out nocopy  NUMBER
    , p6_a25 out nocopy  NUMBER
    , p6_a26 out nocopy  NUMBER
    , p6_a27 out nocopy  NUMBER
    , p6_a28 out nocopy  VARCHAR2
    , p6_a29 out nocopy  VARCHAR2
    , p6_a30 out nocopy  VARCHAR2
  )

  as
    ddp_qqlv_rec okl_qql_pvt.qqlv_rec_type;
    ddx_qqlv_rec okl_qql_pvt.qqlv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_qqlv_rec.id := p5_a0;
    ddp_qqlv_rec.object_version_number := p5_a1;
    ddp_qqlv_rec.attribute_category := p5_a2;
    ddp_qqlv_rec.attribute1 := p5_a3;
    ddp_qqlv_rec.attribute2 := p5_a4;
    ddp_qqlv_rec.attribute3 := p5_a5;
    ddp_qqlv_rec.attribute4 := p5_a6;
    ddp_qqlv_rec.attribute5 := p5_a7;
    ddp_qqlv_rec.attribute6 := p5_a8;
    ddp_qqlv_rec.attribute7 := p5_a9;
    ddp_qqlv_rec.attribute8 := p5_a10;
    ddp_qqlv_rec.attribute9 := p5_a11;
    ddp_qqlv_rec.attribute10 := p5_a12;
    ddp_qqlv_rec.attribute11 := p5_a13;
    ddp_qqlv_rec.attribute12 := p5_a14;
    ddp_qqlv_rec.attribute13 := p5_a15;
    ddp_qqlv_rec.attribute14 := p5_a16;
    ddp_qqlv_rec.attribute15 := p5_a17;
    ddp_qqlv_rec.quick_quote_id := p5_a18;
    ddp_qqlv_rec.type := p5_a19;
    ddp_qqlv_rec.basis := p5_a20;
    ddp_qqlv_rec.value := p5_a21;
    ddp_qqlv_rec.end_of_term_value_default := p5_a22;
    ddp_qqlv_rec.end_of_term_value := p5_a23;
    ddp_qqlv_rec.percentage_of_total_cost := p5_a24;
    ddp_qqlv_rec.item_category_id := p5_a25;
    ddp_qqlv_rec.item_category_set_id := p5_a26;
    ddp_qqlv_rec.lease_rate_factor := p5_a27;
    ddp_qqlv_rec.short_description := p5_a28;
    ddp_qqlv_rec.description := p5_a29;
    ddp_qqlv_rec.comments := p5_a30;


    -- here's the delegated call to the old PL/SQL routine
    okl_qql_pvt.insert_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_qqlv_rec,
      ddx_qqlv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := ddx_qqlv_rec.id;
    p6_a1 := ddx_qqlv_rec.object_version_number;
    p6_a2 := ddx_qqlv_rec.attribute_category;
    p6_a3 := ddx_qqlv_rec.attribute1;
    p6_a4 := ddx_qqlv_rec.attribute2;
    p6_a5 := ddx_qqlv_rec.attribute3;
    p6_a6 := ddx_qqlv_rec.attribute4;
    p6_a7 := ddx_qqlv_rec.attribute5;
    p6_a8 := ddx_qqlv_rec.attribute6;
    p6_a9 := ddx_qqlv_rec.attribute7;
    p6_a10 := ddx_qqlv_rec.attribute8;
    p6_a11 := ddx_qqlv_rec.attribute9;
    p6_a12 := ddx_qqlv_rec.attribute10;
    p6_a13 := ddx_qqlv_rec.attribute11;
    p6_a14 := ddx_qqlv_rec.attribute12;
    p6_a15 := ddx_qqlv_rec.attribute13;
    p6_a16 := ddx_qqlv_rec.attribute14;
    p6_a17 := ddx_qqlv_rec.attribute15;
    p6_a18 := ddx_qqlv_rec.quick_quote_id;
    p6_a19 := ddx_qqlv_rec.type;
    p6_a20 := ddx_qqlv_rec.basis;
    p6_a21 := ddx_qqlv_rec.value;
    p6_a22 := ddx_qqlv_rec.end_of_term_value_default;
    p6_a23 := ddx_qqlv_rec.end_of_term_value;
    p6_a24 := ddx_qqlv_rec.percentage_of_total_cost;
    p6_a25 := ddx_qqlv_rec.item_category_id;
    p6_a26 := ddx_qqlv_rec.item_category_set_id;
    p6_a27 := ddx_qqlv_rec.lease_rate_factor;
    p6_a28 := ddx_qqlv_rec.short_description;
    p6_a29 := ddx_qqlv_rec.description;
    p6_a30 := ddx_qqlv_rec.comments;
  end;

  procedure update_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER
    , p5_a1  NUMBER
    , p5_a2  VARCHAR2
    , p5_a3  VARCHAR2
    , p5_a4  VARCHAR2
    , p5_a5  VARCHAR2
    , p5_a6  VARCHAR2
    , p5_a7  VARCHAR2
    , p5_a8  VARCHAR2
    , p5_a9  VARCHAR2
    , p5_a10  VARCHAR2
    , p5_a11  VARCHAR2
    , p5_a12  VARCHAR2
    , p5_a13  VARCHAR2
    , p5_a14  VARCHAR2
    , p5_a15  VARCHAR2
    , p5_a16  VARCHAR2
    , p5_a17  VARCHAR2
    , p5_a18  NUMBER
    , p5_a19  VARCHAR2
    , p5_a20  VARCHAR2
    , p5_a21  NUMBER
    , p5_a22  NUMBER
    , p5_a23  NUMBER
    , p5_a24  NUMBER
    , p5_a25  NUMBER
    , p5_a26  NUMBER
    , p5_a27  NUMBER
    , p5_a28  VARCHAR2
    , p5_a29  VARCHAR2
    , p5_a30  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  VARCHAR2
    , p6_a3 out nocopy  VARCHAR2
    , p6_a4 out nocopy  VARCHAR2
    , p6_a5 out nocopy  VARCHAR2
    , p6_a6 out nocopy  VARCHAR2
    , p6_a7 out nocopy  VARCHAR2
    , p6_a8 out nocopy  VARCHAR2
    , p6_a9 out nocopy  VARCHAR2
    , p6_a10 out nocopy  VARCHAR2
    , p6_a11 out nocopy  VARCHAR2
    , p6_a12 out nocopy  VARCHAR2
    , p6_a13 out nocopy  VARCHAR2
    , p6_a14 out nocopy  VARCHAR2
    , p6_a15 out nocopy  VARCHAR2
    , p6_a16 out nocopy  VARCHAR2
    , p6_a17 out nocopy  VARCHAR2
    , p6_a18 out nocopy  NUMBER
    , p6_a19 out nocopy  VARCHAR2
    , p6_a20 out nocopy  VARCHAR2
    , p6_a21 out nocopy  NUMBER
    , p6_a22 out nocopy  NUMBER
    , p6_a23 out nocopy  NUMBER
    , p6_a24 out nocopy  NUMBER
    , p6_a25 out nocopy  NUMBER
    , p6_a26 out nocopy  NUMBER
    , p6_a27 out nocopy  NUMBER
    , p6_a28 out nocopy  VARCHAR2
    , p6_a29 out nocopy  VARCHAR2
    , p6_a30 out nocopy  VARCHAR2
  )

  as
    ddp_qqlv_rec okl_qql_pvt.qqlv_rec_type;
    ddx_qqlv_rec okl_qql_pvt.qqlv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_qqlv_rec.id := p5_a0;
    ddp_qqlv_rec.object_version_number := p5_a1;
    ddp_qqlv_rec.attribute_category := p5_a2;
    ddp_qqlv_rec.attribute1 := p5_a3;
    ddp_qqlv_rec.attribute2 := p5_a4;
    ddp_qqlv_rec.attribute3 := p5_a5;
    ddp_qqlv_rec.attribute4 := p5_a6;
    ddp_qqlv_rec.attribute5 := p5_a7;
    ddp_qqlv_rec.attribute6 := p5_a8;
    ddp_qqlv_rec.attribute7 := p5_a9;
    ddp_qqlv_rec.attribute8 := p5_a10;
    ddp_qqlv_rec.attribute9 := p5_a11;
    ddp_qqlv_rec.attribute10 := p5_a12;
    ddp_qqlv_rec.attribute11 := p5_a13;
    ddp_qqlv_rec.attribute12 := p5_a14;
    ddp_qqlv_rec.attribute13 := p5_a15;
    ddp_qqlv_rec.attribute14 := p5_a16;
    ddp_qqlv_rec.attribute15 := p5_a17;
    ddp_qqlv_rec.quick_quote_id := p5_a18;
    ddp_qqlv_rec.type := p5_a19;
    ddp_qqlv_rec.basis := p5_a20;
    ddp_qqlv_rec.value := p5_a21;
    ddp_qqlv_rec.end_of_term_value_default := p5_a22;
    ddp_qqlv_rec.end_of_term_value := p5_a23;
    ddp_qqlv_rec.percentage_of_total_cost := p5_a24;
    ddp_qqlv_rec.item_category_id := p5_a25;
    ddp_qqlv_rec.item_category_set_id := p5_a26;
    ddp_qqlv_rec.lease_rate_factor := p5_a27;
    ddp_qqlv_rec.short_description := p5_a28;
    ddp_qqlv_rec.description := p5_a29;
    ddp_qqlv_rec.comments := p5_a30;


    -- here's the delegated call to the old PL/SQL routine
    okl_qql_pvt.update_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_qqlv_rec,
      ddx_qqlv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := ddx_qqlv_rec.id;
    p6_a1 := ddx_qqlv_rec.object_version_number;
    p6_a2 := ddx_qqlv_rec.attribute_category;
    p6_a3 := ddx_qqlv_rec.attribute1;
    p6_a4 := ddx_qqlv_rec.attribute2;
    p6_a5 := ddx_qqlv_rec.attribute3;
    p6_a6 := ddx_qqlv_rec.attribute4;
    p6_a7 := ddx_qqlv_rec.attribute5;
    p6_a8 := ddx_qqlv_rec.attribute6;
    p6_a9 := ddx_qqlv_rec.attribute7;
    p6_a10 := ddx_qqlv_rec.attribute8;
    p6_a11 := ddx_qqlv_rec.attribute9;
    p6_a12 := ddx_qqlv_rec.attribute10;
    p6_a13 := ddx_qqlv_rec.attribute11;
    p6_a14 := ddx_qqlv_rec.attribute12;
    p6_a15 := ddx_qqlv_rec.attribute13;
    p6_a16 := ddx_qqlv_rec.attribute14;
    p6_a17 := ddx_qqlv_rec.attribute15;
    p6_a18 := ddx_qqlv_rec.quick_quote_id;
    p6_a19 := ddx_qqlv_rec.type;
    p6_a20 := ddx_qqlv_rec.basis;
    p6_a21 := ddx_qqlv_rec.value;
    p6_a22 := ddx_qqlv_rec.end_of_term_value_default;
    p6_a23 := ddx_qqlv_rec.end_of_term_value;
    p6_a24 := ddx_qqlv_rec.percentage_of_total_cost;
    p6_a25 := ddx_qqlv_rec.item_category_id;
    p6_a26 := ddx_qqlv_rec.item_category_set_id;
    p6_a27 := ddx_qqlv_rec.lease_rate_factor;
    p6_a28 := ddx_qqlv_rec.short_description;
    p6_a29 := ddx_qqlv_rec.description;
    p6_a30 := ddx_qqlv_rec.comments;
  end;

  procedure delete_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER
    , p5_a1  NUMBER
    , p5_a2  VARCHAR2
    , p5_a3  VARCHAR2
    , p5_a4  VARCHAR2
    , p5_a5  VARCHAR2
    , p5_a6  VARCHAR2
    , p5_a7  VARCHAR2
    , p5_a8  VARCHAR2
    , p5_a9  VARCHAR2
    , p5_a10  VARCHAR2
    , p5_a11  VARCHAR2
    , p5_a12  VARCHAR2
    , p5_a13  VARCHAR2
    , p5_a14  VARCHAR2
    , p5_a15  VARCHAR2
    , p5_a16  VARCHAR2
    , p5_a17  VARCHAR2
    , p5_a18  NUMBER
    , p5_a19  VARCHAR2
    , p5_a20  VARCHAR2
    , p5_a21  NUMBER
    , p5_a22  NUMBER
    , p5_a23  NUMBER
    , p5_a24  NUMBER
    , p5_a25  NUMBER
    , p5_a26  NUMBER
    , p5_a27  NUMBER
    , p5_a28  VARCHAR2
    , p5_a29  VARCHAR2
    , p5_a30  VARCHAR2
  )

  as
    ddp_qqlv_rec okl_qql_pvt.qqlv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_qqlv_rec.id := p5_a0;
    ddp_qqlv_rec.object_version_number := p5_a1;
    ddp_qqlv_rec.attribute_category := p5_a2;
    ddp_qqlv_rec.attribute1 := p5_a3;
    ddp_qqlv_rec.attribute2 := p5_a4;
    ddp_qqlv_rec.attribute3 := p5_a5;
    ddp_qqlv_rec.attribute4 := p5_a6;
    ddp_qqlv_rec.attribute5 := p5_a7;
    ddp_qqlv_rec.attribute6 := p5_a8;
    ddp_qqlv_rec.attribute7 := p5_a9;
    ddp_qqlv_rec.attribute8 := p5_a10;
    ddp_qqlv_rec.attribute9 := p5_a11;
    ddp_qqlv_rec.attribute10 := p5_a12;
    ddp_qqlv_rec.attribute11 := p5_a13;
    ddp_qqlv_rec.attribute12 := p5_a14;
    ddp_qqlv_rec.attribute13 := p5_a15;
    ddp_qqlv_rec.attribute14 := p5_a16;
    ddp_qqlv_rec.attribute15 := p5_a17;
    ddp_qqlv_rec.quick_quote_id := p5_a18;
    ddp_qqlv_rec.type := p5_a19;
    ddp_qqlv_rec.basis := p5_a20;
    ddp_qqlv_rec.value := p5_a21;
    ddp_qqlv_rec.end_of_term_value_default := p5_a22;
    ddp_qqlv_rec.end_of_term_value := p5_a23;
    ddp_qqlv_rec.percentage_of_total_cost := p5_a24;
    ddp_qqlv_rec.item_category_id := p5_a25;
    ddp_qqlv_rec.item_category_set_id := p5_a26;
    ddp_qqlv_rec.lease_rate_factor := p5_a27;
    ddp_qqlv_rec.short_description := p5_a28;
    ddp_qqlv_rec.description := p5_a29;
    ddp_qqlv_rec.comments := p5_a30;

    -- here's the delegated call to the old PL/SQL routine
    okl_qql_pvt.delete_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_qqlv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

end okl_qql_pvt_w;

/
