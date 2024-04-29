--------------------------------------------------------
--  DDL for Package Body CN_PAY_ELEMENT_INPUTS_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_PAY_ELEMENT_INPUTS_PVT_W" as
  /* $Header: cnwqpib.pls 115.3 2002/02/05 00:29:12 pkm ship      $ */
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

  procedure rosetta_table_copy_in_p2(t out cn_pay_element_inputs_pvt.pay_element_input_tbl_type, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_DATE_TABLE
    , a2 JTF_DATE_TABLE
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_VARCHAR2_TABLE_100
    , a14 JTF_VARCHAR2_TABLE_200
    , a15 JTF_VARCHAR2_TABLE_200
    , a16 JTF_VARCHAR2_TABLE_200
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
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).pay_element_name := a0(indx);
          t(ddindx).start_date := rosetta_g_miss_date_in_map(a1(indx));
          t(ddindx).end_date := rosetta_g_miss_date_in_map(a2(indx));
          t(ddindx).table_name := a3(indx);
          t(ddindx).column_name := a4(indx);
          t(ddindx).pay_input_name := a5(indx);
          t(ddindx).line_number := a6(indx);
          t(ddindx).pay_element_input_id := a7(indx);
          t(ddindx).quota_pay_element_id := a8(indx);
          t(ddindx).element_input_id := a9(indx);
          t(ddindx).element_type_id := a10(indx);
          t(ddindx).tab_object_id := a11(indx);
          t(ddindx).col_object_id := a12(indx);
          t(ddindx).attribute_category := a13(indx);
          t(ddindx).attribute1 := a14(indx);
          t(ddindx).attribute2 := a15(indx);
          t(ddindx).attribute3 := a16(indx);
          t(ddindx).attribute4 := a17(indx);
          t(ddindx).attribute5 := a18(indx);
          t(ddindx).attribute6 := a19(indx);
          t(ddindx).attribute7 := a20(indx);
          t(ddindx).attribute8 := a21(indx);
          t(ddindx).attribute9 := a22(indx);
          t(ddindx).attribute10 := a23(indx);
          t(ddindx).attribute11 := a24(indx);
          t(ddindx).attribute12 := a25(indx);
          t(ddindx).attribute13 := a26(indx);
          t(ddindx).attribute14 := a27(indx);
          t(ddindx).attribute15 := a28(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p2;
  procedure rosetta_table_copy_out_p2(t cn_pay_element_inputs_pvt.pay_element_input_tbl_type, a0 out JTF_VARCHAR2_TABLE_100
    , a1 out JTF_DATE_TABLE
    , a2 out JTF_DATE_TABLE
    , a3 out JTF_VARCHAR2_TABLE_100
    , a4 out JTF_VARCHAR2_TABLE_100
    , a5 out JTF_VARCHAR2_TABLE_100
    , a6 out JTF_NUMBER_TABLE
    , a7 out JTF_NUMBER_TABLE
    , a8 out JTF_NUMBER_TABLE
    , a9 out JTF_NUMBER_TABLE
    , a10 out JTF_NUMBER_TABLE
    , a11 out JTF_NUMBER_TABLE
    , a12 out JTF_NUMBER_TABLE
    , a13 out JTF_VARCHAR2_TABLE_100
    , a14 out JTF_VARCHAR2_TABLE_200
    , a15 out JTF_VARCHAR2_TABLE_200
    , a16 out JTF_VARCHAR2_TABLE_200
    , a17 out JTF_VARCHAR2_TABLE_200
    , a18 out JTF_VARCHAR2_TABLE_200
    , a19 out JTF_VARCHAR2_TABLE_200
    , a20 out JTF_VARCHAR2_TABLE_200
    , a21 out JTF_VARCHAR2_TABLE_200
    , a22 out JTF_VARCHAR2_TABLE_200
    , a23 out JTF_VARCHAR2_TABLE_200
    , a24 out JTF_VARCHAR2_TABLE_200
    , a25 out JTF_VARCHAR2_TABLE_200
    , a26 out JTF_VARCHAR2_TABLE_200
    , a27 out JTF_VARCHAR2_TABLE_200
    , a28 out JTF_VARCHAR2_TABLE_200
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_100();
    a1 := JTF_DATE_TABLE();
    a2 := JTF_DATE_TABLE();
    a3 := JTF_VARCHAR2_TABLE_100();
    a4 := JTF_VARCHAR2_TABLE_100();
    a5 := JTF_VARCHAR2_TABLE_100();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_NUMBER_TABLE();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_NUMBER_TABLE();
    a11 := JTF_NUMBER_TABLE();
    a12 := JTF_NUMBER_TABLE();
    a13 := JTF_VARCHAR2_TABLE_100();
    a14 := JTF_VARCHAR2_TABLE_200();
    a15 := JTF_VARCHAR2_TABLE_200();
    a16 := JTF_VARCHAR2_TABLE_200();
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
  else
      a0 := JTF_VARCHAR2_TABLE_100();
      a1 := JTF_DATE_TABLE();
      a2 := JTF_DATE_TABLE();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_VARCHAR2_TABLE_100();
      a5 := JTF_VARCHAR2_TABLE_100();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_NUMBER_TABLE();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_NUMBER_TABLE();
      a11 := JTF_NUMBER_TABLE();
      a12 := JTF_NUMBER_TABLE();
      a13 := JTF_VARCHAR2_TABLE_100();
      a14 := JTF_VARCHAR2_TABLE_200();
      a15 := JTF_VARCHAR2_TABLE_200();
      a16 := JTF_VARCHAR2_TABLE_200();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).pay_element_name;
          a1(indx) := t(ddindx).start_date;
          a2(indx) := t(ddindx).end_date;
          a3(indx) := t(ddindx).table_name;
          a4(indx) := t(ddindx).column_name;
          a5(indx) := t(ddindx).pay_input_name;
          a6(indx) := t(ddindx).line_number;
          a7(indx) := t(ddindx).pay_element_input_id;
          a8(indx) := t(ddindx).quota_pay_element_id;
          a9(indx) := t(ddindx).element_input_id;
          a10(indx) := t(ddindx).element_type_id;
          a11(indx) := t(ddindx).tab_object_id;
          a12(indx) := t(ddindx).col_object_id;
          a13(indx) := t(ddindx).attribute_category;
          a14(indx) := t(ddindx).attribute1;
          a15(indx) := t(ddindx).attribute2;
          a16(indx) := t(ddindx).attribute3;
          a17(indx) := t(ddindx).attribute4;
          a18(indx) := t(ddindx).attribute5;
          a19(indx) := t(ddindx).attribute6;
          a20(indx) := t(ddindx).attribute7;
          a21(indx) := t(ddindx).attribute8;
          a22(indx) := t(ddindx).attribute9;
          a23(indx) := t(ddindx).attribute10;
          a24(indx) := t(ddindx).attribute11;
          a25(indx) := t(ddindx).attribute12;
          a26(indx) := t(ddindx).attribute13;
          a27(indx) := t(ddindx).attribute14;
          a28(indx) := t(ddindx).attribute15;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p2;

  procedure rosetta_table_copy_in_p5(t out cn_pay_element_inputs_pvt.pay_element_input_out_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_DATE_TABLE
    , a7 JTF_DATE_TABLE
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_VARCHAR2_TABLE_100
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).pay_element_input_id := a0(indx);
          t(ddindx).quota_pay_element_id := a1(indx);
          t(ddindx).element_input_id := a2(indx);
          t(ddindx).element_type_id := a3(indx);
          t(ddindx).table_name := a4(indx);
          t(ddindx).column_name := a5(indx);
          t(ddindx).start_date := rosetta_g_miss_date_in_map(a6(indx));
          t(ddindx).end_date := rosetta_g_miss_date_in_map(a7(indx));
          t(ddindx).pay_element_name := a8(indx);
          t(ddindx).pay_input_name := a9(indx);
          t(ddindx).line_number := a10(indx);
          t(ddindx).tab_object_id := a11(indx);
          t(ddindx).col_object_id := a12(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p5;
  procedure rosetta_table_copy_out_p5(t cn_pay_element_inputs_pvt.pay_element_input_out_tbl_type, a0 out JTF_NUMBER_TABLE
    , a1 out JTF_NUMBER_TABLE
    , a2 out JTF_NUMBER_TABLE
    , a3 out JTF_NUMBER_TABLE
    , a4 out JTF_VARCHAR2_TABLE_100
    , a5 out JTF_VARCHAR2_TABLE_100
    , a6 out JTF_DATE_TABLE
    , a7 out JTF_DATE_TABLE
    , a8 out JTF_VARCHAR2_TABLE_100
    , a9 out JTF_VARCHAR2_TABLE_100
    , a10 out JTF_NUMBER_TABLE
    , a11 out JTF_NUMBER_TABLE
    , a12 out JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_VARCHAR2_TABLE_100();
    a5 := JTF_VARCHAR2_TABLE_100();
    a6 := JTF_DATE_TABLE();
    a7 := JTF_DATE_TABLE();
    a8 := JTF_VARCHAR2_TABLE_100();
    a9 := JTF_VARCHAR2_TABLE_100();
    a10 := JTF_NUMBER_TABLE();
    a11 := JTF_NUMBER_TABLE();
    a12 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_VARCHAR2_TABLE_100();
      a5 := JTF_VARCHAR2_TABLE_100();
      a6 := JTF_DATE_TABLE();
      a7 := JTF_DATE_TABLE();
      a8 := JTF_VARCHAR2_TABLE_100();
      a9 := JTF_VARCHAR2_TABLE_100();
      a10 := JTF_NUMBER_TABLE();
      a11 := JTF_NUMBER_TABLE();
      a12 := JTF_NUMBER_TABLE();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).pay_element_input_id;
          a1(indx) := t(ddindx).quota_pay_element_id;
          a2(indx) := t(ddindx).element_input_id;
          a3(indx) := t(ddindx).element_type_id;
          a4(indx) := t(ddindx).table_name;
          a5(indx) := t(ddindx).column_name;
          a6(indx) := t(ddindx).start_date;
          a7(indx) := t(ddindx).end_date;
          a8(indx) := t(ddindx).pay_element_name;
          a9(indx) := t(ddindx).pay_input_name;
          a10(indx) := t(ddindx).line_number;
          a11(indx) := t(ddindx).tab_object_id;
          a12(indx) := t(ddindx).col_object_id;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p5;

  procedure create_pay_element_input(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out  VARCHAR2
    , x_msg_count out  NUMBER
    , x_msg_data out  VARCHAR2
    , p7_a0  VARCHAR2
    , p7_a1  DATE
    , p7_a2  DATE
    , p7_a3  VARCHAR2
    , p7_a4  VARCHAR2
    , p7_a5  VARCHAR2
    , p7_a6  NUMBER
    , p7_a7  NUMBER
    , p7_a8  NUMBER
    , p7_a9  NUMBER
    , p7_a10  NUMBER
    , p7_a11  NUMBER
    , p7_a12  NUMBER
    , p7_a13  VARCHAR2
    , p7_a14  VARCHAR2
    , p7_a15  VARCHAR2
    , p7_a16  VARCHAR2
    , p7_a17  VARCHAR2
    , p7_a18  VARCHAR2
    , p7_a19  VARCHAR2
    , p7_a20  VARCHAR2
    , p7_a21  VARCHAR2
    , p7_a22  VARCHAR2
    , p7_a23  VARCHAR2
    , p7_a24  VARCHAR2
    , p7_a25  VARCHAR2
    , p7_a26  VARCHAR2
    , p7_a27  VARCHAR2
    , p7_a28  VARCHAR2
    , x_pay_element_input_id out  NUMBER
    , x_loading_status out  VARCHAR2
  )
  as
    ddp_pay_element_input_rec cn_pay_element_inputs_pvt.pay_element_input_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_pay_element_input_rec.pay_element_name := p7_a0;
    ddp_pay_element_input_rec.start_date := rosetta_g_miss_date_in_map(p7_a1);
    ddp_pay_element_input_rec.end_date := rosetta_g_miss_date_in_map(p7_a2);
    ddp_pay_element_input_rec.table_name := p7_a3;
    ddp_pay_element_input_rec.column_name := p7_a4;
    ddp_pay_element_input_rec.pay_input_name := p7_a5;
    ddp_pay_element_input_rec.line_number := p7_a6;
    ddp_pay_element_input_rec.pay_element_input_id := p7_a7;
    ddp_pay_element_input_rec.quota_pay_element_id := p7_a8;
    ddp_pay_element_input_rec.element_input_id := p7_a9;
    ddp_pay_element_input_rec.element_type_id := p7_a10;
    ddp_pay_element_input_rec.tab_object_id := p7_a11;
    ddp_pay_element_input_rec.col_object_id := p7_a12;
    ddp_pay_element_input_rec.attribute_category := p7_a13;
    ddp_pay_element_input_rec.attribute1 := p7_a14;
    ddp_pay_element_input_rec.attribute2 := p7_a15;
    ddp_pay_element_input_rec.attribute3 := p7_a16;
    ddp_pay_element_input_rec.attribute4 := p7_a17;
    ddp_pay_element_input_rec.attribute5 := p7_a18;
    ddp_pay_element_input_rec.attribute6 := p7_a19;
    ddp_pay_element_input_rec.attribute7 := p7_a20;
    ddp_pay_element_input_rec.attribute8 := p7_a21;
    ddp_pay_element_input_rec.attribute9 := p7_a22;
    ddp_pay_element_input_rec.attribute10 := p7_a23;
    ddp_pay_element_input_rec.attribute11 := p7_a24;
    ddp_pay_element_input_rec.attribute12 := p7_a25;
    ddp_pay_element_input_rec.attribute13 := p7_a26;
    ddp_pay_element_input_rec.attribute14 := p7_a27;
    ddp_pay_element_input_rec.attribute15 := p7_a28;



    -- here's the delegated call to the old PL/SQL routine
    cn_pay_element_inputs_pvt.create_pay_element_input(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_pay_element_input_rec,
      x_pay_element_input_id,
      x_loading_status);

    -- copy data back from the local OUT or IN-OUT args, if any









  end;

  procedure update_pay_element_input(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out  VARCHAR2
    , x_msg_count out  NUMBER
    , x_msg_data out  VARCHAR2
    , p7_a0  VARCHAR2
    , p7_a1  DATE
    , p7_a2  DATE
    , p7_a3  VARCHAR2
    , p7_a4  VARCHAR2
    , p7_a5  VARCHAR2
    , p7_a6  NUMBER
    , p7_a7  NUMBER
    , p7_a8  NUMBER
    , p7_a9  NUMBER
    , p7_a10  NUMBER
    , p7_a11  NUMBER
    , p7_a12  NUMBER
    , p7_a13  VARCHAR2
    , p7_a14  VARCHAR2
    , p7_a15  VARCHAR2
    , p7_a16  VARCHAR2
    , p7_a17  VARCHAR2
    , p7_a18  VARCHAR2
    , p7_a19  VARCHAR2
    , p7_a20  VARCHAR2
    , p7_a21  VARCHAR2
    , p7_a22  VARCHAR2
    , p7_a23  VARCHAR2
    , p7_a24  VARCHAR2
    , p7_a25  VARCHAR2
    , p7_a26  VARCHAR2
    , p7_a27  VARCHAR2
    , p7_a28  VARCHAR2
    , p8_a0  VARCHAR2
    , p8_a1  DATE
    , p8_a2  DATE
    , p8_a3  VARCHAR2
    , p8_a4  VARCHAR2
    , p8_a5  VARCHAR2
    , p8_a6  NUMBER
    , p8_a7  NUMBER
    , p8_a8  NUMBER
    , p8_a9  NUMBER
    , p8_a10  NUMBER
    , p8_a11  NUMBER
    , p8_a12  NUMBER
    , p8_a13  VARCHAR2
    , p8_a14  VARCHAR2
    , p8_a15  VARCHAR2
    , p8_a16  VARCHAR2
    , p8_a17  VARCHAR2
    , p8_a18  VARCHAR2
    , p8_a19  VARCHAR2
    , p8_a20  VARCHAR2
    , p8_a21  VARCHAR2
    , p8_a22  VARCHAR2
    , p8_a23  VARCHAR2
    , p8_a24  VARCHAR2
    , p8_a25  VARCHAR2
    , p8_a26  VARCHAR2
    , p8_a27  VARCHAR2
    , p8_a28  VARCHAR2
    , x_loading_status out  VARCHAR2
  )
  as
    ddpo_pay_element_input_rec cn_pay_element_inputs_pvt.pay_element_input_rec_type;
    ddp_pay_element_input_rec cn_pay_element_inputs_pvt.pay_element_input_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddpo_pay_element_input_rec.pay_element_name := p7_a0;
    ddpo_pay_element_input_rec.start_date := rosetta_g_miss_date_in_map(p7_a1);
    ddpo_pay_element_input_rec.end_date := rosetta_g_miss_date_in_map(p7_a2);
    ddpo_pay_element_input_rec.table_name := p7_a3;
    ddpo_pay_element_input_rec.column_name := p7_a4;
    ddpo_pay_element_input_rec.pay_input_name := p7_a5;
    ddpo_pay_element_input_rec.line_number := p7_a6;
    ddpo_pay_element_input_rec.pay_element_input_id := p7_a7;
    ddpo_pay_element_input_rec.quota_pay_element_id := p7_a8;
    ddpo_pay_element_input_rec.element_input_id := p7_a9;
    ddpo_pay_element_input_rec.element_type_id := p7_a10;
    ddpo_pay_element_input_rec.tab_object_id := p7_a11;
    ddpo_pay_element_input_rec.col_object_id := p7_a12;
    ddpo_pay_element_input_rec.attribute_category := p7_a13;
    ddpo_pay_element_input_rec.attribute1 := p7_a14;
    ddpo_pay_element_input_rec.attribute2 := p7_a15;
    ddpo_pay_element_input_rec.attribute3 := p7_a16;
    ddpo_pay_element_input_rec.attribute4 := p7_a17;
    ddpo_pay_element_input_rec.attribute5 := p7_a18;
    ddpo_pay_element_input_rec.attribute6 := p7_a19;
    ddpo_pay_element_input_rec.attribute7 := p7_a20;
    ddpo_pay_element_input_rec.attribute8 := p7_a21;
    ddpo_pay_element_input_rec.attribute9 := p7_a22;
    ddpo_pay_element_input_rec.attribute10 := p7_a23;
    ddpo_pay_element_input_rec.attribute11 := p7_a24;
    ddpo_pay_element_input_rec.attribute12 := p7_a25;
    ddpo_pay_element_input_rec.attribute13 := p7_a26;
    ddpo_pay_element_input_rec.attribute14 := p7_a27;
    ddpo_pay_element_input_rec.attribute15 := p7_a28;

    ddp_pay_element_input_rec.pay_element_name := p8_a0;
    ddp_pay_element_input_rec.start_date := rosetta_g_miss_date_in_map(p8_a1);
    ddp_pay_element_input_rec.end_date := rosetta_g_miss_date_in_map(p8_a2);
    ddp_pay_element_input_rec.table_name := p8_a3;
    ddp_pay_element_input_rec.column_name := p8_a4;
    ddp_pay_element_input_rec.pay_input_name := p8_a5;
    ddp_pay_element_input_rec.line_number := p8_a6;
    ddp_pay_element_input_rec.pay_element_input_id := p8_a7;
    ddp_pay_element_input_rec.quota_pay_element_id := p8_a8;
    ddp_pay_element_input_rec.element_input_id := p8_a9;
    ddp_pay_element_input_rec.element_type_id := p8_a10;
    ddp_pay_element_input_rec.tab_object_id := p8_a11;
    ddp_pay_element_input_rec.col_object_id := p8_a12;
    ddp_pay_element_input_rec.attribute_category := p8_a13;
    ddp_pay_element_input_rec.attribute1 := p8_a14;
    ddp_pay_element_input_rec.attribute2 := p8_a15;
    ddp_pay_element_input_rec.attribute3 := p8_a16;
    ddp_pay_element_input_rec.attribute4 := p8_a17;
    ddp_pay_element_input_rec.attribute5 := p8_a18;
    ddp_pay_element_input_rec.attribute6 := p8_a19;
    ddp_pay_element_input_rec.attribute7 := p8_a20;
    ddp_pay_element_input_rec.attribute8 := p8_a21;
    ddp_pay_element_input_rec.attribute9 := p8_a22;
    ddp_pay_element_input_rec.attribute10 := p8_a23;
    ddp_pay_element_input_rec.attribute11 := p8_a24;
    ddp_pay_element_input_rec.attribute12 := p8_a25;
    ddp_pay_element_input_rec.attribute13 := p8_a26;
    ddp_pay_element_input_rec.attribute14 := p8_a27;
    ddp_pay_element_input_rec.attribute15 := p8_a28;


    -- here's the delegated call to the old PL/SQL routine
    cn_pay_element_inputs_pvt.update_pay_element_input(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddpo_pay_element_input_rec,
      ddp_pay_element_input_rec,
      x_loading_status);

    -- copy data back from the local OUT or IN-OUT args, if any









  end;

  procedure get_pay_element_input(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out  VARCHAR2
    , x_msg_count out  NUMBER
    , x_msg_data out  VARCHAR2
    , p_element_type_id  NUMBER
    , p_start_record  NUMBER
    , p_increment_count  NUMBER
    , p_order_by  VARCHAR2
    , p11_a0 out JTF_NUMBER_TABLE
    , p11_a1 out JTF_NUMBER_TABLE
    , p11_a2 out JTF_NUMBER_TABLE
    , p11_a3 out JTF_NUMBER_TABLE
    , p11_a4 out JTF_VARCHAR2_TABLE_100
    , p11_a5 out JTF_VARCHAR2_TABLE_100
    , p11_a6 out JTF_DATE_TABLE
    , p11_a7 out JTF_DATE_TABLE
    , p11_a8 out JTF_VARCHAR2_TABLE_100
    , p11_a9 out JTF_VARCHAR2_TABLE_100
    , p11_a10 out JTF_NUMBER_TABLE
    , p11_a11 out JTF_NUMBER_TABLE
    , p11_a12 out JTF_NUMBER_TABLE
    , x_total_records out  NUMBER
    , x_status out  VARCHAR2
    , x_loading_status out  VARCHAR2
  )
  as
    ddx_pay_element_input_tbl cn_pay_element_inputs_pvt.pay_element_input_out_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any















    -- here's the delegated call to the old PL/SQL routine
    cn_pay_element_inputs_pvt.get_pay_element_input(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_element_type_id,
      p_start_record,
      p_increment_count,
      p_order_by,
      ddx_pay_element_input_tbl,
      x_total_records,
      x_status,
      x_loading_status);

    -- copy data back from the local OUT or IN-OUT args, if any











    cn_pay_element_inputs_pvt_w.rosetta_table_copy_out_p5(ddx_pay_element_input_tbl, p11_a0
      , p11_a1
      , p11_a2
      , p11_a3
      , p11_a4
      , p11_a5
      , p11_a6
      , p11_a7
      , p11_a8
      , p11_a9
      , p11_a10
      , p11_a11
      , p11_a12
      );



  end;

end cn_pay_element_inputs_pvt_w;

/
