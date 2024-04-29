--------------------------------------------------------
--  DDL for Package Body OKL_AGN_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_AGN_PVT_W" as
  /* $Header: OKLIAGNB.pls 120.2 2006/08/09 11:13:56 abhsaxen noship $ */
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

  procedure rosetta_table_copy_in_p2(t out nocopy okl_agn_pvt.agn_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_VARCHAR2_TABLE_100
    , a10 JTF_DATE_TABLE
    , a11 JTF_DATE_TABLE
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_NUMBER_TABLE
    , a14 JTF_DATE_TABLE
    , a15 JTF_NUMBER_TABLE
    , a16 JTF_DATE_TABLE
    , a17 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).line_number := rosetta_g_miss_num_map(a1(indx));
          t(ddindx).version := a2(indx);
          t(ddindx).aro_code := a3(indx);
          t(ddindx).arlo_code := a4(indx);
          t(ddindx).acro_code := a5(indx);
          t(ddindx).right_operand_literal := a6(indx);
          t(ddindx).object_version_number := rosetta_g_miss_num_map(a7(indx));
          t(ddindx).left_parentheses := a8(indx);
          t(ddindx).right_parentheses := a9(indx);
          t(ddindx).from_date := rosetta_g_miss_date_in_map(a10(indx));
          t(ddindx).to_date := rosetta_g_miss_date_in_map(a11(indx));
          t(ddindx).org_id := rosetta_g_miss_num_map(a12(indx));
          t(ddindx).created_by := rosetta_g_miss_num_map(a13(indx));
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a14(indx));
          t(ddindx).last_updated_by := rosetta_g_miss_num_map(a15(indx));
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a16(indx));
          t(ddindx).last_update_login := rosetta_g_miss_num_map(a17(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p2;
  procedure rosetta_table_copy_out_p2(t okl_agn_pvt.agn_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    , a9 out nocopy JTF_VARCHAR2_TABLE_100
    , a10 out nocopy JTF_DATE_TABLE
    , a11 out nocopy JTF_DATE_TABLE
    , a12 out nocopy JTF_NUMBER_TABLE
    , a13 out nocopy JTF_NUMBER_TABLE
    , a14 out nocopy JTF_DATE_TABLE
    , a15 out nocopy JTF_NUMBER_TABLE
    , a16 out nocopy JTF_DATE_TABLE
    , a17 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_VARCHAR2_TABLE_100();
    a4 := JTF_VARCHAR2_TABLE_100();
    a5 := JTF_VARCHAR2_TABLE_100();
    a6 := JTF_VARCHAR2_TABLE_100();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_VARCHAR2_TABLE_100();
    a9 := JTF_VARCHAR2_TABLE_100();
    a10 := JTF_DATE_TABLE();
    a11 := JTF_DATE_TABLE();
    a12 := JTF_NUMBER_TABLE();
    a13 := JTF_NUMBER_TABLE();
    a14 := JTF_DATE_TABLE();
    a15 := JTF_NUMBER_TABLE();
    a16 := JTF_DATE_TABLE();
    a17 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_VARCHAR2_TABLE_100();
      a5 := JTF_VARCHAR2_TABLE_100();
      a6 := JTF_VARCHAR2_TABLE_100();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_VARCHAR2_TABLE_100();
      a9 := JTF_VARCHAR2_TABLE_100();
      a10 := JTF_DATE_TABLE();
      a11 := JTF_DATE_TABLE();
      a12 := JTF_NUMBER_TABLE();
      a13 := JTF_NUMBER_TABLE();
      a14 := JTF_DATE_TABLE();
      a15 := JTF_NUMBER_TABLE();
      a16 := JTF_DATE_TABLE();
      a17 := JTF_NUMBER_TABLE();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).id);
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).line_number);
          a2(indx) := t(ddindx).version;
          a3(indx) := t(ddindx).aro_code;
          a4(indx) := t(ddindx).arlo_code;
          a5(indx) := t(ddindx).acro_code;
          a6(indx) := t(ddindx).right_operand_literal;
          a7(indx) := rosetta_g_miss_num_map(t(ddindx).object_version_number);
          a8(indx) := t(ddindx).left_parentheses;
          a9(indx) := t(ddindx).right_parentheses;
          a10(indx) := t(ddindx).from_date;
          a11(indx) := t(ddindx).to_date;
          a12(indx) := rosetta_g_miss_num_map(t(ddindx).org_id);
          a13(indx) := rosetta_g_miss_num_map(t(ddindx).created_by);
          a14(indx) := t(ddindx).creation_date;
          a15(indx) := rosetta_g_miss_num_map(t(ddindx).last_updated_by);
          a16(indx) := t(ddindx).last_update_date;
          a17(indx) := rosetta_g_miss_num_map(t(ddindx).last_update_login);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p2;

  procedure rosetta_table_copy_in_p5(t out nocopy okl_agn_pvt.agnv_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_VARCHAR2_TABLE_100
    , a10 JTF_DATE_TABLE
    , a11 JTF_DATE_TABLE
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_NUMBER_TABLE
    , a14 JTF_DATE_TABLE
    , a15 JTF_NUMBER_TABLE
    , a16 JTF_DATE_TABLE
    , a17 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).object_version_number := rosetta_g_miss_num_map(a1(indx));
          t(ddindx).aro_code := a2(indx);
          t(ddindx).arlo_code := a3(indx);
          t(ddindx).acro_code := a4(indx);
          t(ddindx).line_number := rosetta_g_miss_num_map(a5(indx));
          t(ddindx).version := a6(indx);
          t(ddindx).left_parentheses := a7(indx);
          t(ddindx).right_operand_literal := a8(indx);
          t(ddindx).right_parentheses := a9(indx);
          t(ddindx).from_date := rosetta_g_miss_date_in_map(a10(indx));
          t(ddindx).to_date := rosetta_g_miss_date_in_map(a11(indx));
          t(ddindx).org_id := rosetta_g_miss_num_map(a12(indx));
          t(ddindx).created_by := rosetta_g_miss_num_map(a13(indx));
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a14(indx));
          t(ddindx).last_updated_by := rosetta_g_miss_num_map(a15(indx));
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a16(indx));
          t(ddindx).last_update_login := rosetta_g_miss_num_map(a17(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p5;
  procedure rosetta_table_copy_out_p5(t okl_agn_pvt.agnv_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    , a9 out nocopy JTF_VARCHAR2_TABLE_100
    , a10 out nocopy JTF_DATE_TABLE
    , a11 out nocopy JTF_DATE_TABLE
    , a12 out nocopy JTF_NUMBER_TABLE
    , a13 out nocopy JTF_NUMBER_TABLE
    , a14 out nocopy JTF_DATE_TABLE
    , a15 out nocopy JTF_NUMBER_TABLE
    , a16 out nocopy JTF_DATE_TABLE
    , a17 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_VARCHAR2_TABLE_100();
    a4 := JTF_VARCHAR2_TABLE_100();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_VARCHAR2_TABLE_100();
    a7 := JTF_VARCHAR2_TABLE_100();
    a8 := JTF_VARCHAR2_TABLE_100();
    a9 := JTF_VARCHAR2_TABLE_100();
    a10 := JTF_DATE_TABLE();
    a11 := JTF_DATE_TABLE();
    a12 := JTF_NUMBER_TABLE();
    a13 := JTF_NUMBER_TABLE();
    a14 := JTF_DATE_TABLE();
    a15 := JTF_NUMBER_TABLE();
    a16 := JTF_DATE_TABLE();
    a17 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_VARCHAR2_TABLE_100();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_VARCHAR2_TABLE_100();
      a7 := JTF_VARCHAR2_TABLE_100();
      a8 := JTF_VARCHAR2_TABLE_100();
      a9 := JTF_VARCHAR2_TABLE_100();
      a10 := JTF_DATE_TABLE();
      a11 := JTF_DATE_TABLE();
      a12 := JTF_NUMBER_TABLE();
      a13 := JTF_NUMBER_TABLE();
      a14 := JTF_DATE_TABLE();
      a15 := JTF_NUMBER_TABLE();
      a16 := JTF_DATE_TABLE();
      a17 := JTF_NUMBER_TABLE();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).id);
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).object_version_number);
          a2(indx) := t(ddindx).aro_code;
          a3(indx) := t(ddindx).arlo_code;
          a4(indx) := t(ddindx).acro_code;
          a5(indx) := rosetta_g_miss_num_map(t(ddindx).line_number);
          a6(indx) := t(ddindx).version;
          a7(indx) := t(ddindx).left_parentheses;
          a8(indx) := t(ddindx).right_operand_literal;
          a9(indx) := t(ddindx).right_parentheses;
          a10(indx) := t(ddindx).from_date;
          a11(indx) := t(ddindx).to_date;
          a12(indx) := rosetta_g_miss_num_map(t(ddindx).org_id);
          a13(indx) := rosetta_g_miss_num_map(t(ddindx).created_by);
          a14(indx) := t(ddindx).creation_date;
          a15(indx) := rosetta_g_miss_num_map(t(ddindx).last_updated_by);
          a16(indx) := t(ddindx).last_update_date;
          a17(indx) := rosetta_g_miss_num_map(t(ddindx).last_update_login);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p5;

  procedure insert_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  VARCHAR2
    , p6_a3 out nocopy  VARCHAR2
    , p6_a4 out nocopy  VARCHAR2
    , p6_a5 out nocopy  NUMBER
    , p6_a6 out nocopy  VARCHAR2
    , p6_a7 out nocopy  VARCHAR2
    , p6_a8 out nocopy  VARCHAR2
    , p6_a9 out nocopy  VARCHAR2
    , p6_a10 out nocopy  DATE
    , p6_a11 out nocopy  DATE
    , p6_a12 out nocopy  NUMBER
    , p6_a13 out nocopy  NUMBER
    , p6_a14 out nocopy  DATE
    , p6_a15 out nocopy  NUMBER
    , p6_a16 out nocopy  DATE
    , p6_a17 out nocopy  NUMBER
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  VARCHAR2 := fnd_api.g_miss_char
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  VARCHAR2 := fnd_api.g_miss_char
    , p5_a10  DATE := fnd_api.g_miss_date
    , p5_a11  DATE := fnd_api.g_miss_date
    , p5_a12  NUMBER := 0-1962.0724
    , p5_a13  NUMBER := 0-1962.0724
    , p5_a14  DATE := fnd_api.g_miss_date
    , p5_a15  NUMBER := 0-1962.0724
    , p5_a16  DATE := fnd_api.g_miss_date
    , p5_a17  NUMBER := 0-1962.0724
  )

  as
    ddp_agnv_rec okl_agn_pvt.agnv_rec_type;
    ddx_agnv_rec okl_agn_pvt.agnv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_agnv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_agnv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_agnv_rec.aro_code := p5_a2;
    ddp_agnv_rec.arlo_code := p5_a3;
    ddp_agnv_rec.acro_code := p5_a4;
    ddp_agnv_rec.line_number := rosetta_g_miss_num_map(p5_a5);
    ddp_agnv_rec.version := p5_a6;
    ddp_agnv_rec.left_parentheses := p5_a7;
    ddp_agnv_rec.right_operand_literal := p5_a8;
    ddp_agnv_rec.right_parentheses := p5_a9;
    ddp_agnv_rec.from_date := rosetta_g_miss_date_in_map(p5_a10);
    ddp_agnv_rec.to_date := rosetta_g_miss_date_in_map(p5_a11);
    ddp_agnv_rec.org_id := rosetta_g_miss_num_map(p5_a12);
    ddp_agnv_rec.created_by := rosetta_g_miss_num_map(p5_a13);
    ddp_agnv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a14);
    ddp_agnv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a15);
    ddp_agnv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a16);
    ddp_agnv_rec.last_update_login := rosetta_g_miss_num_map(p5_a17);


    -- here's the delegated call to the old PL/SQL routine
    okl_agn_pvt.insert_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_agnv_rec,
      ddx_agnv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_agnv_rec.id);
    p6_a1 := rosetta_g_miss_num_map(ddx_agnv_rec.object_version_number);
    p6_a2 := ddx_agnv_rec.aro_code;
    p6_a3 := ddx_agnv_rec.arlo_code;
    p6_a4 := ddx_agnv_rec.acro_code;
    p6_a5 := rosetta_g_miss_num_map(ddx_agnv_rec.line_number);
    p6_a6 := ddx_agnv_rec.version;
    p6_a7 := ddx_agnv_rec.left_parentheses;
    p6_a8 := ddx_agnv_rec.right_operand_literal;
    p6_a9 := ddx_agnv_rec.right_parentheses;
    p6_a10 := ddx_agnv_rec.from_date;
    p6_a11 := ddx_agnv_rec.to_date;
    p6_a12 := rosetta_g_miss_num_map(ddx_agnv_rec.org_id);
    p6_a13 := rosetta_g_miss_num_map(ddx_agnv_rec.created_by);
    p6_a14 := ddx_agnv_rec.creation_date;
    p6_a15 := rosetta_g_miss_num_map(ddx_agnv_rec.last_updated_by);
    p6_a16 := ddx_agnv_rec.last_update_date;
    p6_a17 := rosetta_g_miss_num_map(ddx_agnv_rec.last_update_login);
  end;

  procedure insert_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_VARCHAR2_TABLE_100
    , p5_a3 JTF_VARCHAR2_TABLE_100
    , p5_a4 JTF_VARCHAR2_TABLE_100
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_VARCHAR2_TABLE_100
    , p5_a7 JTF_VARCHAR2_TABLE_100
    , p5_a8 JTF_VARCHAR2_TABLE_100
    , p5_a9 JTF_VARCHAR2_TABLE_100
    , p5_a10 JTF_DATE_TABLE
    , p5_a11 JTF_DATE_TABLE
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_NUMBER_TABLE
    , p5_a14 JTF_DATE_TABLE
    , p5_a15 JTF_NUMBER_TABLE
    , p5_a16 JTF_DATE_TABLE
    , p5_a17 JTF_NUMBER_TABLE
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a5 out nocopy JTF_NUMBER_TABLE
    , p6_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a10 out nocopy JTF_DATE_TABLE
    , p6_a11 out nocopy JTF_DATE_TABLE
    , p6_a12 out nocopy JTF_NUMBER_TABLE
    , p6_a13 out nocopy JTF_NUMBER_TABLE
    , p6_a14 out nocopy JTF_DATE_TABLE
    , p6_a15 out nocopy JTF_NUMBER_TABLE
    , p6_a16 out nocopy JTF_DATE_TABLE
    , p6_a17 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_agnv_tbl okl_agn_pvt.agnv_tbl_type;
    ddx_agnv_tbl okl_agn_pvt.agnv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_agn_pvt_w.rosetta_table_copy_in_p5(ddp_agnv_tbl, p5_a0
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
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_agn_pvt.insert_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_agnv_tbl,
      ddx_agnv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_agn_pvt_w.rosetta_table_copy_out_p5(ddx_agnv_tbl, p6_a0
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
      );
  end;

  procedure lock_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  VARCHAR2 := fnd_api.g_miss_char
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  VARCHAR2 := fnd_api.g_miss_char
    , p5_a10  DATE := fnd_api.g_miss_date
    , p5_a11  DATE := fnd_api.g_miss_date
    , p5_a12  NUMBER := 0-1962.0724
    , p5_a13  NUMBER := 0-1962.0724
    , p5_a14  DATE := fnd_api.g_miss_date
    , p5_a15  NUMBER := 0-1962.0724
    , p5_a16  DATE := fnd_api.g_miss_date
    , p5_a17  NUMBER := 0-1962.0724
  )

  as
    ddp_agnv_rec okl_agn_pvt.agnv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_agnv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_agnv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_agnv_rec.aro_code := p5_a2;
    ddp_agnv_rec.arlo_code := p5_a3;
    ddp_agnv_rec.acro_code := p5_a4;
    ddp_agnv_rec.line_number := rosetta_g_miss_num_map(p5_a5);
    ddp_agnv_rec.version := p5_a6;
    ddp_agnv_rec.left_parentheses := p5_a7;
    ddp_agnv_rec.right_operand_literal := p5_a8;
    ddp_agnv_rec.right_parentheses := p5_a9;
    ddp_agnv_rec.from_date := rosetta_g_miss_date_in_map(p5_a10);
    ddp_agnv_rec.to_date := rosetta_g_miss_date_in_map(p5_a11);
    ddp_agnv_rec.org_id := rosetta_g_miss_num_map(p5_a12);
    ddp_agnv_rec.created_by := rosetta_g_miss_num_map(p5_a13);
    ddp_agnv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a14);
    ddp_agnv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a15);
    ddp_agnv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a16);
    ddp_agnv_rec.last_update_login := rosetta_g_miss_num_map(p5_a17);

    -- here's the delegated call to the old PL/SQL routine
    okl_agn_pvt.lock_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_agnv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure lock_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_VARCHAR2_TABLE_100
    , p5_a3 JTF_VARCHAR2_TABLE_100
    , p5_a4 JTF_VARCHAR2_TABLE_100
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_VARCHAR2_TABLE_100
    , p5_a7 JTF_VARCHAR2_TABLE_100
    , p5_a8 JTF_VARCHAR2_TABLE_100
    , p5_a9 JTF_VARCHAR2_TABLE_100
    , p5_a10 JTF_DATE_TABLE
    , p5_a11 JTF_DATE_TABLE
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_NUMBER_TABLE
    , p5_a14 JTF_DATE_TABLE
    , p5_a15 JTF_NUMBER_TABLE
    , p5_a16 JTF_DATE_TABLE
    , p5_a17 JTF_NUMBER_TABLE
  )

  as
    ddp_agnv_tbl okl_agn_pvt.agnv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_agn_pvt_w.rosetta_table_copy_in_p5(ddp_agnv_tbl, p5_a0
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
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_agn_pvt.lock_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_agnv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure update_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  VARCHAR2
    , p6_a3 out nocopy  VARCHAR2
    , p6_a4 out nocopy  VARCHAR2
    , p6_a5 out nocopy  NUMBER
    , p6_a6 out nocopy  VARCHAR2
    , p6_a7 out nocopy  VARCHAR2
    , p6_a8 out nocopy  VARCHAR2
    , p6_a9 out nocopy  VARCHAR2
    , p6_a10 out nocopy  DATE
    , p6_a11 out nocopy  DATE
    , p6_a12 out nocopy  NUMBER
    , p6_a13 out nocopy  NUMBER
    , p6_a14 out nocopy  DATE
    , p6_a15 out nocopy  NUMBER
    , p6_a16 out nocopy  DATE
    , p6_a17 out nocopy  NUMBER
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  VARCHAR2 := fnd_api.g_miss_char
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  VARCHAR2 := fnd_api.g_miss_char
    , p5_a10  DATE := fnd_api.g_miss_date
    , p5_a11  DATE := fnd_api.g_miss_date
    , p5_a12  NUMBER := 0-1962.0724
    , p5_a13  NUMBER := 0-1962.0724
    , p5_a14  DATE := fnd_api.g_miss_date
    , p5_a15  NUMBER := 0-1962.0724
    , p5_a16  DATE := fnd_api.g_miss_date
    , p5_a17  NUMBER := 0-1962.0724
  )

  as
    ddp_agnv_rec okl_agn_pvt.agnv_rec_type;
    ddx_agnv_rec okl_agn_pvt.agnv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_agnv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_agnv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_agnv_rec.aro_code := p5_a2;
    ddp_agnv_rec.arlo_code := p5_a3;
    ddp_agnv_rec.acro_code := p5_a4;
    ddp_agnv_rec.line_number := rosetta_g_miss_num_map(p5_a5);
    ddp_agnv_rec.version := p5_a6;
    ddp_agnv_rec.left_parentheses := p5_a7;
    ddp_agnv_rec.right_operand_literal := p5_a8;
    ddp_agnv_rec.right_parentheses := p5_a9;
    ddp_agnv_rec.from_date := rosetta_g_miss_date_in_map(p5_a10);
    ddp_agnv_rec.to_date := rosetta_g_miss_date_in_map(p5_a11);
    ddp_agnv_rec.org_id := rosetta_g_miss_num_map(p5_a12);
    ddp_agnv_rec.created_by := rosetta_g_miss_num_map(p5_a13);
    ddp_agnv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a14);
    ddp_agnv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a15);
    ddp_agnv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a16);
    ddp_agnv_rec.last_update_login := rosetta_g_miss_num_map(p5_a17);


    -- here's the delegated call to the old PL/SQL routine
    okl_agn_pvt.update_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_agnv_rec,
      ddx_agnv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_agnv_rec.id);
    p6_a1 := rosetta_g_miss_num_map(ddx_agnv_rec.object_version_number);
    p6_a2 := ddx_agnv_rec.aro_code;
    p6_a3 := ddx_agnv_rec.arlo_code;
    p6_a4 := ddx_agnv_rec.acro_code;
    p6_a5 := rosetta_g_miss_num_map(ddx_agnv_rec.line_number);
    p6_a6 := ddx_agnv_rec.version;
    p6_a7 := ddx_agnv_rec.left_parentheses;
    p6_a8 := ddx_agnv_rec.right_operand_literal;
    p6_a9 := ddx_agnv_rec.right_parentheses;
    p6_a10 := ddx_agnv_rec.from_date;
    p6_a11 := ddx_agnv_rec.to_date;
    p6_a12 := rosetta_g_miss_num_map(ddx_agnv_rec.org_id);
    p6_a13 := rosetta_g_miss_num_map(ddx_agnv_rec.created_by);
    p6_a14 := ddx_agnv_rec.creation_date;
    p6_a15 := rosetta_g_miss_num_map(ddx_agnv_rec.last_updated_by);
    p6_a16 := ddx_agnv_rec.last_update_date;
    p6_a17 := rosetta_g_miss_num_map(ddx_agnv_rec.last_update_login);
  end;

  procedure update_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_VARCHAR2_TABLE_100
    , p5_a3 JTF_VARCHAR2_TABLE_100
    , p5_a4 JTF_VARCHAR2_TABLE_100
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_VARCHAR2_TABLE_100
    , p5_a7 JTF_VARCHAR2_TABLE_100
    , p5_a8 JTF_VARCHAR2_TABLE_100
    , p5_a9 JTF_VARCHAR2_TABLE_100
    , p5_a10 JTF_DATE_TABLE
    , p5_a11 JTF_DATE_TABLE
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_NUMBER_TABLE
    , p5_a14 JTF_DATE_TABLE
    , p5_a15 JTF_NUMBER_TABLE
    , p5_a16 JTF_DATE_TABLE
    , p5_a17 JTF_NUMBER_TABLE
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a3 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a5 out nocopy JTF_NUMBER_TABLE
    , p6_a6 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a7 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a8 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a10 out nocopy JTF_DATE_TABLE
    , p6_a11 out nocopy JTF_DATE_TABLE
    , p6_a12 out nocopy JTF_NUMBER_TABLE
    , p6_a13 out nocopy JTF_NUMBER_TABLE
    , p6_a14 out nocopy JTF_DATE_TABLE
    , p6_a15 out nocopy JTF_NUMBER_TABLE
    , p6_a16 out nocopy JTF_DATE_TABLE
    , p6_a17 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_agnv_tbl okl_agn_pvt.agnv_tbl_type;
    ddx_agnv_tbl okl_agn_pvt.agnv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_agn_pvt_w.rosetta_table_copy_in_p5(ddp_agnv_tbl, p5_a0
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
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_agn_pvt.update_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_agnv_tbl,
      ddx_agnv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_agn_pvt_w.rosetta_table_copy_out_p5(ddx_agnv_tbl, p6_a0
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
      );
  end;

  procedure delete_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  VARCHAR2 := fnd_api.g_miss_char
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  VARCHAR2 := fnd_api.g_miss_char
    , p5_a10  DATE := fnd_api.g_miss_date
    , p5_a11  DATE := fnd_api.g_miss_date
    , p5_a12  NUMBER := 0-1962.0724
    , p5_a13  NUMBER := 0-1962.0724
    , p5_a14  DATE := fnd_api.g_miss_date
    , p5_a15  NUMBER := 0-1962.0724
    , p5_a16  DATE := fnd_api.g_miss_date
    , p5_a17  NUMBER := 0-1962.0724
  )

  as
    ddp_agnv_rec okl_agn_pvt.agnv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_agnv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_agnv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_agnv_rec.aro_code := p5_a2;
    ddp_agnv_rec.arlo_code := p5_a3;
    ddp_agnv_rec.acro_code := p5_a4;
    ddp_agnv_rec.line_number := rosetta_g_miss_num_map(p5_a5);
    ddp_agnv_rec.version := p5_a6;
    ddp_agnv_rec.left_parentheses := p5_a7;
    ddp_agnv_rec.right_operand_literal := p5_a8;
    ddp_agnv_rec.right_parentheses := p5_a9;
    ddp_agnv_rec.from_date := rosetta_g_miss_date_in_map(p5_a10);
    ddp_agnv_rec.to_date := rosetta_g_miss_date_in_map(p5_a11);
    ddp_agnv_rec.org_id := rosetta_g_miss_num_map(p5_a12);
    ddp_agnv_rec.created_by := rosetta_g_miss_num_map(p5_a13);
    ddp_agnv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a14);
    ddp_agnv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a15);
    ddp_agnv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a16);
    ddp_agnv_rec.last_update_login := rosetta_g_miss_num_map(p5_a17);

    -- here's the delegated call to the old PL/SQL routine
    okl_agn_pvt.delete_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_agnv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure delete_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_VARCHAR2_TABLE_100
    , p5_a3 JTF_VARCHAR2_TABLE_100
    , p5_a4 JTF_VARCHAR2_TABLE_100
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_VARCHAR2_TABLE_100
    , p5_a7 JTF_VARCHAR2_TABLE_100
    , p5_a8 JTF_VARCHAR2_TABLE_100
    , p5_a9 JTF_VARCHAR2_TABLE_100
    , p5_a10 JTF_DATE_TABLE
    , p5_a11 JTF_DATE_TABLE
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_NUMBER_TABLE
    , p5_a14 JTF_DATE_TABLE
    , p5_a15 JTF_NUMBER_TABLE
    , p5_a16 JTF_DATE_TABLE
    , p5_a17 JTF_NUMBER_TABLE
  )

  as
    ddp_agnv_tbl okl_agn_pvt.agnv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_agn_pvt_w.rosetta_table_copy_in_p5(ddp_agnv_tbl, p5_a0
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
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_agn_pvt.delete_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_agnv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure validate_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  VARCHAR2 := fnd_api.g_miss_char
    , p5_a3  VARCHAR2 := fnd_api.g_miss_char
    , p5_a4  VARCHAR2 := fnd_api.g_miss_char
    , p5_a5  NUMBER := 0-1962.0724
    , p5_a6  VARCHAR2 := fnd_api.g_miss_char
    , p5_a7  VARCHAR2 := fnd_api.g_miss_char
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  VARCHAR2 := fnd_api.g_miss_char
    , p5_a10  DATE := fnd_api.g_miss_date
    , p5_a11  DATE := fnd_api.g_miss_date
    , p5_a12  NUMBER := 0-1962.0724
    , p5_a13  NUMBER := 0-1962.0724
    , p5_a14  DATE := fnd_api.g_miss_date
    , p5_a15  NUMBER := 0-1962.0724
    , p5_a16  DATE := fnd_api.g_miss_date
    , p5_a17  NUMBER := 0-1962.0724
  )

  as
    ddp_agnv_rec okl_agn_pvt.agnv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_agnv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_agnv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_agnv_rec.aro_code := p5_a2;
    ddp_agnv_rec.arlo_code := p5_a3;
    ddp_agnv_rec.acro_code := p5_a4;
    ddp_agnv_rec.line_number := rosetta_g_miss_num_map(p5_a5);
    ddp_agnv_rec.version := p5_a6;
    ddp_agnv_rec.left_parentheses := p5_a7;
    ddp_agnv_rec.right_operand_literal := p5_a8;
    ddp_agnv_rec.right_parentheses := p5_a9;
    ddp_agnv_rec.from_date := rosetta_g_miss_date_in_map(p5_a10);
    ddp_agnv_rec.to_date := rosetta_g_miss_date_in_map(p5_a11);
    ddp_agnv_rec.org_id := rosetta_g_miss_num_map(p5_a12);
    ddp_agnv_rec.created_by := rosetta_g_miss_num_map(p5_a13);
    ddp_agnv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a14);
    ddp_agnv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a15);
    ddp_agnv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a16);
    ddp_agnv_rec.last_update_login := rosetta_g_miss_num_map(p5_a17);

    -- here's the delegated call to the old PL/SQL routine
    okl_agn_pvt.validate_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_agnv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure validate_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_VARCHAR2_TABLE_100
    , p5_a3 JTF_VARCHAR2_TABLE_100
    , p5_a4 JTF_VARCHAR2_TABLE_100
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_VARCHAR2_TABLE_100
    , p5_a7 JTF_VARCHAR2_TABLE_100
    , p5_a8 JTF_VARCHAR2_TABLE_100
    , p5_a9 JTF_VARCHAR2_TABLE_100
    , p5_a10 JTF_DATE_TABLE
    , p5_a11 JTF_DATE_TABLE
    , p5_a12 JTF_NUMBER_TABLE
    , p5_a13 JTF_NUMBER_TABLE
    , p5_a14 JTF_DATE_TABLE
    , p5_a15 JTF_NUMBER_TABLE
    , p5_a16 JTF_DATE_TABLE
    , p5_a17 JTF_NUMBER_TABLE
  )

  as
    ddp_agnv_tbl okl_agn_pvt.agnv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_agn_pvt_w.rosetta_table_copy_in_p5(ddp_agnv_tbl, p5_a0
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
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_agn_pvt.validate_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_agnv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

end okl_agn_pvt_w;

/
