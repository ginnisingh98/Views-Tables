--------------------------------------------------------
--  DDL for Package Body CN_QUOTA_PAY_ELEMENTS_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_QUOTA_PAY_ELEMENTS_PVT_W" as
  /* $Header: cnwqpeb.pls 115.3 2002/02/05 00:29:09 pkm ship      $ */
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

  procedure rosetta_table_copy_in_p2(t out cn_quota_pay_elements_pvt.quota_pay_element_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_DATE_TABLE
    , a4 JTF_DATE_TABLE
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_DATE_TABLE
    , a9 JTF_DATE_TABLE
    , a10 JTF_VARCHAR2_TABLE_100
    , a11 JTF_VARCHAR2_TABLE_200
    , a12 JTF_VARCHAR2_TABLE_200
    , a13 JTF_VARCHAR2_TABLE_200
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
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).quota_pay_element_id := a0(indx);
          t(ddindx).quota_name := a1(indx);
          t(ddindx).pay_element_name := a2(indx);
          t(ddindx).pay_start_date := rosetta_g_miss_date_in_map(a3(indx));
          t(ddindx).pay_end_date := rosetta_g_miss_date_in_map(a4(indx));
          t(ddindx).status := a5(indx);
          t(ddindx).quota_id := a6(indx);
          t(ddindx).pay_element_type_id := a7(indx);
          t(ddindx).start_date := rosetta_g_miss_date_in_map(a8(indx));
          t(ddindx).end_date := rosetta_g_miss_date_in_map(a9(indx));
          t(ddindx).attribute_category := a10(indx);
          t(ddindx).attribute1 := a11(indx);
          t(ddindx).attribute2 := a12(indx);
          t(ddindx).attribute3 := a13(indx);
          t(ddindx).attribute4 := a14(indx);
          t(ddindx).attribute5 := a15(indx);
          t(ddindx).attribute6 := a16(indx);
          t(ddindx).attribute7 := a17(indx);
          t(ddindx).attribute8 := a18(indx);
          t(ddindx).attribute9 := a19(indx);
          t(ddindx).attribute10 := a20(indx);
          t(ddindx).attribute11 := a21(indx);
          t(ddindx).attribute12 := a22(indx);
          t(ddindx).attribute13 := a23(indx);
          t(ddindx).attribute14 := a24(indx);
          t(ddindx).attribute15 := a25(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p2;
  procedure rosetta_table_copy_out_p2(t cn_quota_pay_elements_pvt.quota_pay_element_tbl_type, a0 out JTF_NUMBER_TABLE
    , a1 out JTF_VARCHAR2_TABLE_100
    , a2 out JTF_VARCHAR2_TABLE_100
    , a3 out JTF_DATE_TABLE
    , a4 out JTF_DATE_TABLE
    , a5 out JTF_VARCHAR2_TABLE_100
    , a6 out JTF_NUMBER_TABLE
    , a7 out JTF_NUMBER_TABLE
    , a8 out JTF_DATE_TABLE
    , a9 out JTF_DATE_TABLE
    , a10 out JTF_VARCHAR2_TABLE_100
    , a11 out JTF_VARCHAR2_TABLE_200
    , a12 out JTF_VARCHAR2_TABLE_200
    , a13 out JTF_VARCHAR2_TABLE_200
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
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_DATE_TABLE();
    a4 := JTF_DATE_TABLE();
    a5 := JTF_VARCHAR2_TABLE_100();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_DATE_TABLE();
    a9 := JTF_DATE_TABLE();
    a10 := JTF_VARCHAR2_TABLE_100();
    a11 := JTF_VARCHAR2_TABLE_200();
    a12 := JTF_VARCHAR2_TABLE_200();
    a13 := JTF_VARCHAR2_TABLE_200();
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
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_DATE_TABLE();
      a4 := JTF_DATE_TABLE();
      a5 := JTF_VARCHAR2_TABLE_100();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_DATE_TABLE();
      a9 := JTF_DATE_TABLE();
      a10 := JTF_VARCHAR2_TABLE_100();
      a11 := JTF_VARCHAR2_TABLE_200();
      a12 := JTF_VARCHAR2_TABLE_200();
      a13 := JTF_VARCHAR2_TABLE_200();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).quota_pay_element_id;
          a1(indx) := t(ddindx).quota_name;
          a2(indx) := t(ddindx).pay_element_name;
          a3(indx) := t(ddindx).pay_start_date;
          a4(indx) := t(ddindx).pay_end_date;
          a5(indx) := t(ddindx).status;
          a6(indx) := t(ddindx).quota_id;
          a7(indx) := t(ddindx).pay_element_type_id;
          a8(indx) := t(ddindx).start_date;
          a9(indx) := t(ddindx).end_date;
          a10(indx) := t(ddindx).attribute_category;
          a11(indx) := t(ddindx).attribute1;
          a12(indx) := t(ddindx).attribute2;
          a13(indx) := t(ddindx).attribute3;
          a14(indx) := t(ddindx).attribute4;
          a15(indx) := t(ddindx).attribute5;
          a16(indx) := t(ddindx).attribute6;
          a17(indx) := t(ddindx).attribute7;
          a18(indx) := t(ddindx).attribute8;
          a19(indx) := t(ddindx).attribute9;
          a20(indx) := t(ddindx).attribute10;
          a21(indx) := t(ddindx).attribute11;
          a22(indx) := t(ddindx).attribute12;
          a23(indx) := t(ddindx).attribute13;
          a24(indx) := t(ddindx).attribute14;
          a25(indx) := t(ddindx).attribute15;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p2;

  procedure rosetta_table_copy_in_p5(t out cn_quota_pay_elements_pvt.quota_pay_element_out_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_DATE_TABLE
    , a5 JTF_DATE_TABLE
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_DATE_TABLE
    , a9 JTF_DATE_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).quota_pay_element_id := a0(indx);
          t(ddindx).quota_id := a1(indx);
          t(ddindx).pay_element_type_id := a2(indx);
          t(ddindx).status := a3(indx);
          t(ddindx).start_date := rosetta_g_miss_date_in_map(a4(indx));
          t(ddindx).end_date := rosetta_g_miss_date_in_map(a5(indx));
          t(ddindx).quota_name := a6(indx);
          t(ddindx).pay_element_name := a7(indx);
          t(ddindx).pay_start_date := rosetta_g_miss_date_in_map(a8(indx));
          t(ddindx).pay_end_date := rosetta_g_miss_date_in_map(a9(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p5;
  procedure rosetta_table_copy_out_p5(t cn_quota_pay_elements_pvt.quota_pay_element_out_tbl_type, a0 out JTF_NUMBER_TABLE
    , a1 out JTF_NUMBER_TABLE
    , a2 out JTF_NUMBER_TABLE
    , a3 out JTF_VARCHAR2_TABLE_100
    , a4 out JTF_DATE_TABLE
    , a5 out JTF_DATE_TABLE
    , a6 out JTF_VARCHAR2_TABLE_100
    , a7 out JTF_VARCHAR2_TABLE_100
    , a8 out JTF_DATE_TABLE
    , a9 out JTF_DATE_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_VARCHAR2_TABLE_100();
    a4 := JTF_DATE_TABLE();
    a5 := JTF_DATE_TABLE();
    a6 := JTF_VARCHAR2_TABLE_100();
    a7 := JTF_VARCHAR2_TABLE_100();
    a8 := JTF_DATE_TABLE();
    a9 := JTF_DATE_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_DATE_TABLE();
      a5 := JTF_DATE_TABLE();
      a6 := JTF_VARCHAR2_TABLE_100();
      a7 := JTF_VARCHAR2_TABLE_100();
      a8 := JTF_DATE_TABLE();
      a9 := JTF_DATE_TABLE();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).quota_pay_element_id;
          a1(indx) := t(ddindx).quota_id;
          a2(indx) := t(ddindx).pay_element_type_id;
          a3(indx) := t(ddindx).status;
          a4(indx) := t(ddindx).start_date;
          a5(indx) := t(ddindx).end_date;
          a6(indx) := t(ddindx).quota_name;
          a7(indx) := t(ddindx).pay_element_name;
          a8(indx) := t(ddindx).pay_start_date;
          a9(indx) := t(ddindx).pay_end_date;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p5;

  procedure create_quota_pay_element(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out  VARCHAR2
    , x_msg_count out  NUMBER
    , x_msg_data out  VARCHAR2
    , p7_a0  NUMBER
    , p7_a1  VARCHAR2
    , p7_a2  VARCHAR2
    , p7_a3  DATE
    , p7_a4  DATE
    , p7_a5  VARCHAR2
    , p7_a6  NUMBER
    , p7_a7  NUMBER
    , p7_a8  DATE
    , p7_a9  DATE
    , p7_a10  VARCHAR2
    , p7_a11  VARCHAR2
    , p7_a12  VARCHAR2
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
    , x_quota_pay_element_id out  NUMBER
    , x_loading_status out  VARCHAR2
  )
  as
    ddp_quota_pay_element_rec cn_quota_pay_elements_pvt.quota_pay_element_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_quota_pay_element_rec.quota_pay_element_id := p7_a0;
    ddp_quota_pay_element_rec.quota_name := p7_a1;
    ddp_quota_pay_element_rec.pay_element_name := p7_a2;
    ddp_quota_pay_element_rec.pay_start_date := rosetta_g_miss_date_in_map(p7_a3);
    ddp_quota_pay_element_rec.pay_end_date := rosetta_g_miss_date_in_map(p7_a4);
    ddp_quota_pay_element_rec.status := p7_a5;
    ddp_quota_pay_element_rec.quota_id := p7_a6;
    ddp_quota_pay_element_rec.pay_element_type_id := p7_a7;
    ddp_quota_pay_element_rec.start_date := rosetta_g_miss_date_in_map(p7_a8);
    ddp_quota_pay_element_rec.end_date := rosetta_g_miss_date_in_map(p7_a9);
    ddp_quota_pay_element_rec.attribute_category := p7_a10;
    ddp_quota_pay_element_rec.attribute1 := p7_a11;
    ddp_quota_pay_element_rec.attribute2 := p7_a12;
    ddp_quota_pay_element_rec.attribute3 := p7_a13;
    ddp_quota_pay_element_rec.attribute4 := p7_a14;
    ddp_quota_pay_element_rec.attribute5 := p7_a15;
    ddp_quota_pay_element_rec.attribute6 := p7_a16;
    ddp_quota_pay_element_rec.attribute7 := p7_a17;
    ddp_quota_pay_element_rec.attribute8 := p7_a18;
    ddp_quota_pay_element_rec.attribute9 := p7_a19;
    ddp_quota_pay_element_rec.attribute10 := p7_a20;
    ddp_quota_pay_element_rec.attribute11 := p7_a21;
    ddp_quota_pay_element_rec.attribute12 := p7_a22;
    ddp_quota_pay_element_rec.attribute13 := p7_a23;
    ddp_quota_pay_element_rec.attribute14 := p7_a24;
    ddp_quota_pay_element_rec.attribute15 := p7_a25;



    -- here's the delegated call to the old PL/SQL routine
    cn_quota_pay_elements_pvt.create_quota_pay_element(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_quota_pay_element_rec,
      x_quota_pay_element_id,
      x_loading_status);

    -- copy data back from the local OUT or IN-OUT args, if any









  end;

  procedure update_quota_pay_element(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out  VARCHAR2
    , x_msg_count out  NUMBER
    , x_msg_data out  VARCHAR2
    , p7_a0  NUMBER
    , p7_a1  VARCHAR2
    , p7_a2  VARCHAR2
    , p7_a3  DATE
    , p7_a4  DATE
    , p7_a5  VARCHAR2
    , p7_a6  NUMBER
    , p7_a7  NUMBER
    , p7_a8  DATE
    , p7_a9  DATE
    , p7_a10  VARCHAR2
    , p7_a11  VARCHAR2
    , p7_a12  VARCHAR2
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
    , p8_a0  NUMBER
    , p8_a1  VARCHAR2
    , p8_a2  VARCHAR2
    , p8_a3  DATE
    , p8_a4  DATE
    , p8_a5  VARCHAR2
    , p8_a6  NUMBER
    , p8_a7  NUMBER
    , p8_a8  DATE
    , p8_a9  DATE
    , p8_a10  VARCHAR2
    , p8_a11  VARCHAR2
    , p8_a12  VARCHAR2
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
    , x_loading_status out  VARCHAR2
  )
  as
    ddpo_quota_pay_element_rec cn_quota_pay_elements_pvt.quota_pay_element_rec_type;
    ddp_quota_pay_element_rec cn_quota_pay_elements_pvt.quota_pay_element_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddpo_quota_pay_element_rec.quota_pay_element_id := p7_a0;
    ddpo_quota_pay_element_rec.quota_name := p7_a1;
    ddpo_quota_pay_element_rec.pay_element_name := p7_a2;
    ddpo_quota_pay_element_rec.pay_start_date := rosetta_g_miss_date_in_map(p7_a3);
    ddpo_quota_pay_element_rec.pay_end_date := rosetta_g_miss_date_in_map(p7_a4);
    ddpo_quota_pay_element_rec.status := p7_a5;
    ddpo_quota_pay_element_rec.quota_id := p7_a6;
    ddpo_quota_pay_element_rec.pay_element_type_id := p7_a7;
    ddpo_quota_pay_element_rec.start_date := rosetta_g_miss_date_in_map(p7_a8);
    ddpo_quota_pay_element_rec.end_date := rosetta_g_miss_date_in_map(p7_a9);
    ddpo_quota_pay_element_rec.attribute_category := p7_a10;
    ddpo_quota_pay_element_rec.attribute1 := p7_a11;
    ddpo_quota_pay_element_rec.attribute2 := p7_a12;
    ddpo_quota_pay_element_rec.attribute3 := p7_a13;
    ddpo_quota_pay_element_rec.attribute4 := p7_a14;
    ddpo_quota_pay_element_rec.attribute5 := p7_a15;
    ddpo_quota_pay_element_rec.attribute6 := p7_a16;
    ddpo_quota_pay_element_rec.attribute7 := p7_a17;
    ddpo_quota_pay_element_rec.attribute8 := p7_a18;
    ddpo_quota_pay_element_rec.attribute9 := p7_a19;
    ddpo_quota_pay_element_rec.attribute10 := p7_a20;
    ddpo_quota_pay_element_rec.attribute11 := p7_a21;
    ddpo_quota_pay_element_rec.attribute12 := p7_a22;
    ddpo_quota_pay_element_rec.attribute13 := p7_a23;
    ddpo_quota_pay_element_rec.attribute14 := p7_a24;
    ddpo_quota_pay_element_rec.attribute15 := p7_a25;

    ddp_quota_pay_element_rec.quota_pay_element_id := p8_a0;
    ddp_quota_pay_element_rec.quota_name := p8_a1;
    ddp_quota_pay_element_rec.pay_element_name := p8_a2;
    ddp_quota_pay_element_rec.pay_start_date := rosetta_g_miss_date_in_map(p8_a3);
    ddp_quota_pay_element_rec.pay_end_date := rosetta_g_miss_date_in_map(p8_a4);
    ddp_quota_pay_element_rec.status := p8_a5;
    ddp_quota_pay_element_rec.quota_id := p8_a6;
    ddp_quota_pay_element_rec.pay_element_type_id := p8_a7;
    ddp_quota_pay_element_rec.start_date := rosetta_g_miss_date_in_map(p8_a8);
    ddp_quota_pay_element_rec.end_date := rosetta_g_miss_date_in_map(p8_a9);
    ddp_quota_pay_element_rec.attribute_category := p8_a10;
    ddp_quota_pay_element_rec.attribute1 := p8_a11;
    ddp_quota_pay_element_rec.attribute2 := p8_a12;
    ddp_quota_pay_element_rec.attribute3 := p8_a13;
    ddp_quota_pay_element_rec.attribute4 := p8_a14;
    ddp_quota_pay_element_rec.attribute5 := p8_a15;
    ddp_quota_pay_element_rec.attribute6 := p8_a16;
    ddp_quota_pay_element_rec.attribute7 := p8_a17;
    ddp_quota_pay_element_rec.attribute8 := p8_a18;
    ddp_quota_pay_element_rec.attribute9 := p8_a19;
    ddp_quota_pay_element_rec.attribute10 := p8_a20;
    ddp_quota_pay_element_rec.attribute11 := p8_a21;
    ddp_quota_pay_element_rec.attribute12 := p8_a22;
    ddp_quota_pay_element_rec.attribute13 := p8_a23;
    ddp_quota_pay_element_rec.attribute14 := p8_a24;
    ddp_quota_pay_element_rec.attribute15 := p8_a25;


    -- here's the delegated call to the old PL/SQL routine
    cn_quota_pay_elements_pvt.update_quota_pay_element(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddpo_quota_pay_element_rec,
      ddp_quota_pay_element_rec,
      x_loading_status);

    -- copy data back from the local OUT or IN-OUT args, if any









  end;

  procedure get_quota_pay_element(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out  VARCHAR2
    , x_msg_count out  NUMBER
    , x_msg_data out  VARCHAR2
    , p_quota_name  VARCHAR2
    , p_pay_element_name  VARCHAR2
    , p_start_record  NUMBER
    , p_increment_count  NUMBER
    , p_order_by  VARCHAR2
    , p12_a0 out JTF_NUMBER_TABLE
    , p12_a1 out JTF_NUMBER_TABLE
    , p12_a2 out JTF_NUMBER_TABLE
    , p12_a3 out JTF_VARCHAR2_TABLE_100
    , p12_a4 out JTF_DATE_TABLE
    , p12_a5 out JTF_DATE_TABLE
    , p12_a6 out JTF_VARCHAR2_TABLE_100
    , p12_a7 out JTF_VARCHAR2_TABLE_100
    , p12_a8 out JTF_DATE_TABLE
    , p12_a9 out JTF_DATE_TABLE
    , x_total_records out  NUMBER
    , x_status out  VARCHAR2
    , x_loading_status out  VARCHAR2
  )
  as
    ddx_quota_pay_element_tbl cn_quota_pay_elements_pvt.quota_pay_element_out_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
















    -- here's the delegated call to the old PL/SQL routine
    cn_quota_pay_elements_pvt.get_quota_pay_element(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_quota_name,
      p_pay_element_name,
      p_start_record,
      p_increment_count,
      p_order_by,
      ddx_quota_pay_element_tbl,
      x_total_records,
      x_status,
      x_loading_status);

    -- copy data back from the local OUT or IN-OUT args, if any












    cn_quota_pay_elements_pvt_w.rosetta_table_copy_out_p5(ddx_quota_pay_element_tbl, p12_a0
      , p12_a1
      , p12_a2
      , p12_a3
      , p12_a4
      , p12_a5
      , p12_a6
      , p12_a7
      , p12_a8
      , p12_a9
      );



  end;

end cn_quota_pay_elements_pvt_w;

/
