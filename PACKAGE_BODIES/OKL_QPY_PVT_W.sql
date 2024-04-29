--------------------------------------------------------
--  DDL for Package Body OKL_QPY_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_QPY_PVT_W" as
  /* $Header: OKLIQPYB.pls 115.3 2002/12/04 03:23:24 gkadarka noship $ */
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

  procedure rosetta_table_copy_in_p2(t out nocopy okl_qpy_pvt.qpy_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_DATE_TABLE
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_DATE_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_DATE_TABLE
    , a9 JTF_NUMBER_TABLE
    , a10 JTF_VARCHAR2_TABLE_100
    , a11 JTF_NUMBER_TABLE
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_VARCHAR2_TABLE_600
    , a14 JTF_VARCHAR2_TABLE_100
    , a15 JTF_VARCHAR2_TABLE_100
    , a16 JTF_VARCHAR2_TABLE_200
    , a17 JTF_VARCHAR2_TABLE_100
    , a18 JTF_VARCHAR2_TABLE_100
    , a19 JTF_VARCHAR2_TABLE_200
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).qte_id := rosetta_g_miss_num_map(a1(indx));
          t(ddindx).cpl_id := rosetta_g_miss_num_map(a2(indx));
          t(ddindx).object_version_number := rosetta_g_miss_num_map(a3(indx));
          t(ddindx).date_sent := rosetta_g_miss_date_in_map(a4(indx));
          t(ddindx).created_by := rosetta_g_miss_num_map(a5(indx));
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a6(indx));
          t(ddindx).last_updated_by := rosetta_g_miss_num_map(a7(indx));
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a8(indx));
          t(ddindx).last_update_login := rosetta_g_miss_num_map(a9(indx));
          t(ddindx).qpt_code := a10(indx);
          t(ddindx).delay_days := rosetta_g_miss_num_map(a11(indx));
          t(ddindx).allocation_percentage := rosetta_g_miss_num_map(a12(indx));
          t(ddindx).email_address := a13(indx);
          t(ddindx).party_jtot_object1_code := a14(indx);
          t(ddindx).party_object1_id1 := a15(indx);
          t(ddindx).party_object1_id2 := a16(indx);
          t(ddindx).contact_jtot_object1_code := a17(indx);
          t(ddindx).contact_object1_id1 := a18(indx);
          t(ddindx).contact_object1_id2 := a19(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p2;
  procedure rosetta_table_copy_out_p2(t okl_qpy_pvt.qpy_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_DATE_TABLE
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_DATE_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_DATE_TABLE
    , a9 out nocopy JTF_NUMBER_TABLE
    , a10 out nocopy JTF_VARCHAR2_TABLE_100
    , a11 out nocopy JTF_NUMBER_TABLE
    , a12 out nocopy JTF_NUMBER_TABLE
    , a13 out nocopy JTF_VARCHAR2_TABLE_600
    , a14 out nocopy JTF_VARCHAR2_TABLE_100
    , a15 out nocopy JTF_VARCHAR2_TABLE_100
    , a16 out nocopy JTF_VARCHAR2_TABLE_200
    , a17 out nocopy JTF_VARCHAR2_TABLE_100
    , a18 out nocopy JTF_VARCHAR2_TABLE_100
    , a19 out nocopy JTF_VARCHAR2_TABLE_200
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_DATE_TABLE();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_DATE_TABLE();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_DATE_TABLE();
    a9 := JTF_NUMBER_TABLE();
    a10 := JTF_VARCHAR2_TABLE_100();
    a11 := JTF_NUMBER_TABLE();
    a12 := JTF_NUMBER_TABLE();
    a13 := JTF_VARCHAR2_TABLE_600();
    a14 := JTF_VARCHAR2_TABLE_100();
    a15 := JTF_VARCHAR2_TABLE_100();
    a16 := JTF_VARCHAR2_TABLE_200();
    a17 := JTF_VARCHAR2_TABLE_100();
    a18 := JTF_VARCHAR2_TABLE_100();
    a19 := JTF_VARCHAR2_TABLE_200();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_DATE_TABLE();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_DATE_TABLE();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_DATE_TABLE();
      a9 := JTF_NUMBER_TABLE();
      a10 := JTF_VARCHAR2_TABLE_100();
      a11 := JTF_NUMBER_TABLE();
      a12 := JTF_NUMBER_TABLE();
      a13 := JTF_VARCHAR2_TABLE_600();
      a14 := JTF_VARCHAR2_TABLE_100();
      a15 := JTF_VARCHAR2_TABLE_100();
      a16 := JTF_VARCHAR2_TABLE_200();
      a17 := JTF_VARCHAR2_TABLE_100();
      a18 := JTF_VARCHAR2_TABLE_100();
      a19 := JTF_VARCHAR2_TABLE_200();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).id);
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).qte_id);
          a2(indx) := rosetta_g_miss_num_map(t(ddindx).cpl_id);
          a3(indx) := rosetta_g_miss_num_map(t(ddindx).object_version_number);
          a4(indx) := t(ddindx).date_sent;
          a5(indx) := rosetta_g_miss_num_map(t(ddindx).created_by);
          a6(indx) := t(ddindx).creation_date;
          a7(indx) := rosetta_g_miss_num_map(t(ddindx).last_updated_by);
          a8(indx) := t(ddindx).last_update_date;
          a9(indx) := rosetta_g_miss_num_map(t(ddindx).last_update_login);
          a10(indx) := t(ddindx).qpt_code;
          a11(indx) := rosetta_g_miss_num_map(t(ddindx).delay_days);
          a12(indx) := rosetta_g_miss_num_map(t(ddindx).allocation_percentage);
          a13(indx) := t(ddindx).email_address;
          a14(indx) := t(ddindx).party_jtot_object1_code;
          a15(indx) := t(ddindx).party_object1_id1;
          a16(indx) := t(ddindx).party_object1_id2;
          a17(indx) := t(ddindx).contact_jtot_object1_code;
          a18(indx) := t(ddindx).contact_object1_id1;
          a19(indx) := t(ddindx).contact_object1_id2;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p2;

  procedure rosetta_table_copy_in_p5(t out nocopy okl_qpy_pvt.qpyv_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_DATE_TABLE
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_NUMBER_TABLE
    , a8 JTF_VARCHAR2_TABLE_600
    , a9 JTF_VARCHAR2_TABLE_100
    , a10 JTF_VARCHAR2_TABLE_100
    , a11 JTF_VARCHAR2_TABLE_200
    , a12 JTF_VARCHAR2_TABLE_100
    , a13 JTF_VARCHAR2_TABLE_100
    , a14 JTF_VARCHAR2_TABLE_200
    , a15 JTF_NUMBER_TABLE
    , a16 JTF_DATE_TABLE
    , a17 JTF_NUMBER_TABLE
    , a18 JTF_DATE_TABLE
    , a19 JTF_NUMBER_TABLE
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
          t(ddindx).qte_id := rosetta_g_miss_num_map(a2(indx));
          t(ddindx).cpl_id := rosetta_g_miss_num_map(a3(indx));
          t(ddindx).date_sent := rosetta_g_miss_date_in_map(a4(indx));
          t(ddindx).qpt_code := a5(indx);
          t(ddindx).delay_days := rosetta_g_miss_num_map(a6(indx));
          t(ddindx).allocation_percentage := rosetta_g_miss_num_map(a7(indx));
          t(ddindx).email_address := a8(indx);
          t(ddindx).party_jtot_object1_code := a9(indx);
          t(ddindx).party_object1_id1 := a10(indx);
          t(ddindx).party_object1_id2 := a11(indx);
          t(ddindx).contact_jtot_object1_code := a12(indx);
          t(ddindx).contact_object1_id1 := a13(indx);
          t(ddindx).contact_object1_id2 := a14(indx);
          t(ddindx).created_by := rosetta_g_miss_num_map(a15(indx));
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a16(indx));
          t(ddindx).last_updated_by := rosetta_g_miss_num_map(a17(indx));
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a18(indx));
          t(ddindx).last_update_login := rosetta_g_miss_num_map(a19(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p5;
  procedure rosetta_table_copy_out_p5(t okl_qpy_pvt.qpyv_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_DATE_TABLE
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    , a8 out nocopy JTF_VARCHAR2_TABLE_600
    , a9 out nocopy JTF_VARCHAR2_TABLE_100
    , a10 out nocopy JTF_VARCHAR2_TABLE_100
    , a11 out nocopy JTF_VARCHAR2_TABLE_200
    , a12 out nocopy JTF_VARCHAR2_TABLE_100
    , a13 out nocopy JTF_VARCHAR2_TABLE_100
    , a14 out nocopy JTF_VARCHAR2_TABLE_200
    , a15 out nocopy JTF_NUMBER_TABLE
    , a16 out nocopy JTF_DATE_TABLE
    , a17 out nocopy JTF_NUMBER_TABLE
    , a18 out nocopy JTF_DATE_TABLE
    , a19 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_DATE_TABLE();
    a5 := JTF_VARCHAR2_TABLE_100();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_NUMBER_TABLE();
    a8 := JTF_VARCHAR2_TABLE_600();
    a9 := JTF_VARCHAR2_TABLE_100();
    a10 := JTF_VARCHAR2_TABLE_100();
    a11 := JTF_VARCHAR2_TABLE_200();
    a12 := JTF_VARCHAR2_TABLE_100();
    a13 := JTF_VARCHAR2_TABLE_100();
    a14 := JTF_VARCHAR2_TABLE_200();
    a15 := JTF_NUMBER_TABLE();
    a16 := JTF_DATE_TABLE();
    a17 := JTF_NUMBER_TABLE();
    a18 := JTF_DATE_TABLE();
    a19 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_DATE_TABLE();
      a5 := JTF_VARCHAR2_TABLE_100();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_NUMBER_TABLE();
      a8 := JTF_VARCHAR2_TABLE_600();
      a9 := JTF_VARCHAR2_TABLE_100();
      a10 := JTF_VARCHAR2_TABLE_100();
      a11 := JTF_VARCHAR2_TABLE_200();
      a12 := JTF_VARCHAR2_TABLE_100();
      a13 := JTF_VARCHAR2_TABLE_100();
      a14 := JTF_VARCHAR2_TABLE_200();
      a15 := JTF_NUMBER_TABLE();
      a16 := JTF_DATE_TABLE();
      a17 := JTF_NUMBER_TABLE();
      a18 := JTF_DATE_TABLE();
      a19 := JTF_NUMBER_TABLE();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).id);
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).object_version_number);
          a2(indx) := rosetta_g_miss_num_map(t(ddindx).qte_id);
          a3(indx) := rosetta_g_miss_num_map(t(ddindx).cpl_id);
          a4(indx) := t(ddindx).date_sent;
          a5(indx) := t(ddindx).qpt_code;
          a6(indx) := rosetta_g_miss_num_map(t(ddindx).delay_days);
          a7(indx) := rosetta_g_miss_num_map(t(ddindx).allocation_percentage);
          a8(indx) := t(ddindx).email_address;
          a9(indx) := t(ddindx).party_jtot_object1_code;
          a10(indx) := t(ddindx).party_object1_id1;
          a11(indx) := t(ddindx).party_object1_id2;
          a12(indx) := t(ddindx).contact_jtot_object1_code;
          a13(indx) := t(ddindx).contact_object1_id1;
          a14(indx) := t(ddindx).contact_object1_id2;
          a15(indx) := rosetta_g_miss_num_map(t(ddindx).created_by);
          a16(indx) := t(ddindx).creation_date;
          a17(indx) := rosetta_g_miss_num_map(t(ddindx).last_updated_by);
          a18(indx) := t(ddindx).last_update_date;
          a19(indx) := rosetta_g_miss_num_map(t(ddindx).last_update_login);
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
    , p6_a2 out nocopy  NUMBER
    , p6_a3 out nocopy  NUMBER
    , p6_a4 out nocopy  DATE
    , p6_a5 out nocopy  VARCHAR2
    , p6_a6 out nocopy  NUMBER
    , p6_a7 out nocopy  NUMBER
    , p6_a8 out nocopy  VARCHAR2
    , p6_a9 out nocopy  VARCHAR2
    , p6_a10 out nocopy  VARCHAR2
    , p6_a11 out nocopy  VARCHAR2
    , p6_a12 out nocopy  VARCHAR2
    , p6_a13 out nocopy  VARCHAR2
    , p6_a14 out nocopy  VARCHAR2
    , p6_a15 out nocopy  NUMBER
    , p6_a16 out nocopy  DATE
    , p6_a17 out nocopy  NUMBER
    , p6_a18 out nocopy  DATE
    , p6_a19 out nocopy  NUMBER
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  DATE := fnd_api.g_miss_date
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  VARCHAR2 := fnd_api.g_miss_char
    , p5_a10  VARCHAR2 := fnd_api.g_miss_char
    , p5_a11  VARCHAR2 := fnd_api.g_miss_char
    , p5_a12  VARCHAR2 := fnd_api.g_miss_char
    , p5_a13  VARCHAR2 := fnd_api.g_miss_char
    , p5_a14  VARCHAR2 := fnd_api.g_miss_char
    , p5_a15  NUMBER := 0-1962.0724
    , p5_a16  DATE := fnd_api.g_miss_date
    , p5_a17  NUMBER := 0-1962.0724
    , p5_a18  DATE := fnd_api.g_miss_date
    , p5_a19  NUMBER := 0-1962.0724
  )

  as
    ddp_qpyv_rec okl_qpy_pvt.qpyv_rec_type;
    ddx_qpyv_rec okl_qpy_pvt.qpyv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_qpyv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_qpyv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_qpyv_rec.qte_id := rosetta_g_miss_num_map(p5_a2);
    ddp_qpyv_rec.cpl_id := rosetta_g_miss_num_map(p5_a3);
    ddp_qpyv_rec.date_sent := rosetta_g_miss_date_in_map(p5_a4);
    ddp_qpyv_rec.qpt_code := p5_a5;
    ddp_qpyv_rec.delay_days := rosetta_g_miss_num_map(p5_a6);
    ddp_qpyv_rec.allocation_percentage := rosetta_g_miss_num_map(p5_a7);
    ddp_qpyv_rec.email_address := p5_a8;
    ddp_qpyv_rec.party_jtot_object1_code := p5_a9;
    ddp_qpyv_rec.party_object1_id1 := p5_a10;
    ddp_qpyv_rec.party_object1_id2 := p5_a11;
    ddp_qpyv_rec.contact_jtot_object1_code := p5_a12;
    ddp_qpyv_rec.contact_object1_id1 := p5_a13;
    ddp_qpyv_rec.contact_object1_id2 := p5_a14;
    ddp_qpyv_rec.created_by := rosetta_g_miss_num_map(p5_a15);
    ddp_qpyv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a16);
    ddp_qpyv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a17);
    ddp_qpyv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a18);
    ddp_qpyv_rec.last_update_login := rosetta_g_miss_num_map(p5_a19);


    -- here's the delegated call to the old PL/SQL routine
    okl_qpy_pvt.insert_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_qpyv_rec,
      ddx_qpyv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_qpyv_rec.id);
    p6_a1 := rosetta_g_miss_num_map(ddx_qpyv_rec.object_version_number);
    p6_a2 := rosetta_g_miss_num_map(ddx_qpyv_rec.qte_id);
    p6_a3 := rosetta_g_miss_num_map(ddx_qpyv_rec.cpl_id);
    p6_a4 := ddx_qpyv_rec.date_sent;
    p6_a5 := ddx_qpyv_rec.qpt_code;
    p6_a6 := rosetta_g_miss_num_map(ddx_qpyv_rec.delay_days);
    p6_a7 := rosetta_g_miss_num_map(ddx_qpyv_rec.allocation_percentage);
    p6_a8 := ddx_qpyv_rec.email_address;
    p6_a9 := ddx_qpyv_rec.party_jtot_object1_code;
    p6_a10 := ddx_qpyv_rec.party_object1_id1;
    p6_a11 := ddx_qpyv_rec.party_object1_id2;
    p6_a12 := ddx_qpyv_rec.contact_jtot_object1_code;
    p6_a13 := ddx_qpyv_rec.contact_object1_id1;
    p6_a14 := ddx_qpyv_rec.contact_object1_id2;
    p6_a15 := rosetta_g_miss_num_map(ddx_qpyv_rec.created_by);
    p6_a16 := ddx_qpyv_rec.creation_date;
    p6_a17 := rosetta_g_miss_num_map(ddx_qpyv_rec.last_updated_by);
    p6_a18 := ddx_qpyv_rec.last_update_date;
    p6_a19 := rosetta_g_miss_num_map(ddx_qpyv_rec.last_update_login);
  end;

  procedure insert_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_DATE_TABLE
    , p5_a5 JTF_VARCHAR2_TABLE_100
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_VARCHAR2_TABLE_600
    , p5_a9 JTF_VARCHAR2_TABLE_100
    , p5_a10 JTF_VARCHAR2_TABLE_100
    , p5_a11 JTF_VARCHAR2_TABLE_200
    , p5_a12 JTF_VARCHAR2_TABLE_100
    , p5_a13 JTF_VARCHAR2_TABLE_100
    , p5_a14 JTF_VARCHAR2_TABLE_200
    , p5_a15 JTF_NUMBER_TABLE
    , p5_a16 JTF_DATE_TABLE
    , p5_a17 JTF_NUMBER_TABLE
    , p5_a18 JTF_DATE_TABLE
    , p5_a19 JTF_NUMBER_TABLE
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_NUMBER_TABLE
    , p6_a3 out nocopy JTF_NUMBER_TABLE
    , p6_a4 out nocopy JTF_DATE_TABLE
    , p6_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a6 out nocopy JTF_NUMBER_TABLE
    , p6_a7 out nocopy JTF_NUMBER_TABLE
    , p6_a8 out nocopy JTF_VARCHAR2_TABLE_600
    , p6_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a10 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a11 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a12 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a13 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a14 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a15 out nocopy JTF_NUMBER_TABLE
    , p6_a16 out nocopy JTF_DATE_TABLE
    , p6_a17 out nocopy JTF_NUMBER_TABLE
    , p6_a18 out nocopy JTF_DATE_TABLE
    , p6_a19 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_qpyv_tbl okl_qpy_pvt.qpyv_tbl_type;
    ddx_qpyv_tbl okl_qpy_pvt.qpyv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_qpy_pvt_w.rosetta_table_copy_in_p5(ddp_qpyv_tbl, p5_a0
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
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_qpy_pvt.insert_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_qpyv_tbl,
      ddx_qpyv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_qpy_pvt_w.rosetta_table_copy_out_p5(ddx_qpyv_tbl, p6_a0
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
      );
  end;

  procedure lock_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  DATE := fnd_api.g_miss_date
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  VARCHAR2 := fnd_api.g_miss_char
    , p5_a10  VARCHAR2 := fnd_api.g_miss_char
    , p5_a11  VARCHAR2 := fnd_api.g_miss_char
    , p5_a12  VARCHAR2 := fnd_api.g_miss_char
    , p5_a13  VARCHAR2 := fnd_api.g_miss_char
    , p5_a14  VARCHAR2 := fnd_api.g_miss_char
    , p5_a15  NUMBER := 0-1962.0724
    , p5_a16  DATE := fnd_api.g_miss_date
    , p5_a17  NUMBER := 0-1962.0724
    , p5_a18  DATE := fnd_api.g_miss_date
    , p5_a19  NUMBER := 0-1962.0724
  )

  as
    ddp_qpyv_rec okl_qpy_pvt.qpyv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_qpyv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_qpyv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_qpyv_rec.qte_id := rosetta_g_miss_num_map(p5_a2);
    ddp_qpyv_rec.cpl_id := rosetta_g_miss_num_map(p5_a3);
    ddp_qpyv_rec.date_sent := rosetta_g_miss_date_in_map(p5_a4);
    ddp_qpyv_rec.qpt_code := p5_a5;
    ddp_qpyv_rec.delay_days := rosetta_g_miss_num_map(p5_a6);
    ddp_qpyv_rec.allocation_percentage := rosetta_g_miss_num_map(p5_a7);
    ddp_qpyv_rec.email_address := p5_a8;
    ddp_qpyv_rec.party_jtot_object1_code := p5_a9;
    ddp_qpyv_rec.party_object1_id1 := p5_a10;
    ddp_qpyv_rec.party_object1_id2 := p5_a11;
    ddp_qpyv_rec.contact_jtot_object1_code := p5_a12;
    ddp_qpyv_rec.contact_object1_id1 := p5_a13;
    ddp_qpyv_rec.contact_object1_id2 := p5_a14;
    ddp_qpyv_rec.created_by := rosetta_g_miss_num_map(p5_a15);
    ddp_qpyv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a16);
    ddp_qpyv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a17);
    ddp_qpyv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a18);
    ddp_qpyv_rec.last_update_login := rosetta_g_miss_num_map(p5_a19);

    -- here's the delegated call to the old PL/SQL routine
    okl_qpy_pvt.lock_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_qpyv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure lock_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_DATE_TABLE
    , p5_a5 JTF_VARCHAR2_TABLE_100
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_VARCHAR2_TABLE_600
    , p5_a9 JTF_VARCHAR2_TABLE_100
    , p5_a10 JTF_VARCHAR2_TABLE_100
    , p5_a11 JTF_VARCHAR2_TABLE_200
    , p5_a12 JTF_VARCHAR2_TABLE_100
    , p5_a13 JTF_VARCHAR2_TABLE_100
    , p5_a14 JTF_VARCHAR2_TABLE_200
    , p5_a15 JTF_NUMBER_TABLE
    , p5_a16 JTF_DATE_TABLE
    , p5_a17 JTF_NUMBER_TABLE
    , p5_a18 JTF_DATE_TABLE
    , p5_a19 JTF_NUMBER_TABLE
  )

  as
    ddp_qpyv_tbl okl_qpy_pvt.qpyv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_qpy_pvt_w.rosetta_table_copy_in_p5(ddp_qpyv_tbl, p5_a0
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
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_qpy_pvt.lock_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_qpyv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure update_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 out nocopy  NUMBER
    , p6_a1 out nocopy  NUMBER
    , p6_a2 out nocopy  NUMBER
    , p6_a3 out nocopy  NUMBER
    , p6_a4 out nocopy  DATE
    , p6_a5 out nocopy  VARCHAR2
    , p6_a6 out nocopy  NUMBER
    , p6_a7 out nocopy  NUMBER
    , p6_a8 out nocopy  VARCHAR2
    , p6_a9 out nocopy  VARCHAR2
    , p6_a10 out nocopy  VARCHAR2
    , p6_a11 out nocopy  VARCHAR2
    , p6_a12 out nocopy  VARCHAR2
    , p6_a13 out nocopy  VARCHAR2
    , p6_a14 out nocopy  VARCHAR2
    , p6_a15 out nocopy  NUMBER
    , p6_a16 out nocopy  DATE
    , p6_a17 out nocopy  NUMBER
    , p6_a18 out nocopy  DATE
    , p6_a19 out nocopy  NUMBER
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  DATE := fnd_api.g_miss_date
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  VARCHAR2 := fnd_api.g_miss_char
    , p5_a10  VARCHAR2 := fnd_api.g_miss_char
    , p5_a11  VARCHAR2 := fnd_api.g_miss_char
    , p5_a12  VARCHAR2 := fnd_api.g_miss_char
    , p5_a13  VARCHAR2 := fnd_api.g_miss_char
    , p5_a14  VARCHAR2 := fnd_api.g_miss_char
    , p5_a15  NUMBER := 0-1962.0724
    , p5_a16  DATE := fnd_api.g_miss_date
    , p5_a17  NUMBER := 0-1962.0724
    , p5_a18  DATE := fnd_api.g_miss_date
    , p5_a19  NUMBER := 0-1962.0724
  )

  as
    ddp_qpyv_rec okl_qpy_pvt.qpyv_rec_type;
    ddx_qpyv_rec okl_qpy_pvt.qpyv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_qpyv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_qpyv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_qpyv_rec.qte_id := rosetta_g_miss_num_map(p5_a2);
    ddp_qpyv_rec.cpl_id := rosetta_g_miss_num_map(p5_a3);
    ddp_qpyv_rec.date_sent := rosetta_g_miss_date_in_map(p5_a4);
    ddp_qpyv_rec.qpt_code := p5_a5;
    ddp_qpyv_rec.delay_days := rosetta_g_miss_num_map(p5_a6);
    ddp_qpyv_rec.allocation_percentage := rosetta_g_miss_num_map(p5_a7);
    ddp_qpyv_rec.email_address := p5_a8;
    ddp_qpyv_rec.party_jtot_object1_code := p5_a9;
    ddp_qpyv_rec.party_object1_id1 := p5_a10;
    ddp_qpyv_rec.party_object1_id2 := p5_a11;
    ddp_qpyv_rec.contact_jtot_object1_code := p5_a12;
    ddp_qpyv_rec.contact_object1_id1 := p5_a13;
    ddp_qpyv_rec.contact_object1_id2 := p5_a14;
    ddp_qpyv_rec.created_by := rosetta_g_miss_num_map(p5_a15);
    ddp_qpyv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a16);
    ddp_qpyv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a17);
    ddp_qpyv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a18);
    ddp_qpyv_rec.last_update_login := rosetta_g_miss_num_map(p5_a19);


    -- here's the delegated call to the old PL/SQL routine
    okl_qpy_pvt.update_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_qpyv_rec,
      ddx_qpyv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := rosetta_g_miss_num_map(ddx_qpyv_rec.id);
    p6_a1 := rosetta_g_miss_num_map(ddx_qpyv_rec.object_version_number);
    p6_a2 := rosetta_g_miss_num_map(ddx_qpyv_rec.qte_id);
    p6_a3 := rosetta_g_miss_num_map(ddx_qpyv_rec.cpl_id);
    p6_a4 := ddx_qpyv_rec.date_sent;
    p6_a5 := ddx_qpyv_rec.qpt_code;
    p6_a6 := rosetta_g_miss_num_map(ddx_qpyv_rec.delay_days);
    p6_a7 := rosetta_g_miss_num_map(ddx_qpyv_rec.allocation_percentage);
    p6_a8 := ddx_qpyv_rec.email_address;
    p6_a9 := ddx_qpyv_rec.party_jtot_object1_code;
    p6_a10 := ddx_qpyv_rec.party_object1_id1;
    p6_a11 := ddx_qpyv_rec.party_object1_id2;
    p6_a12 := ddx_qpyv_rec.contact_jtot_object1_code;
    p6_a13 := ddx_qpyv_rec.contact_object1_id1;
    p6_a14 := ddx_qpyv_rec.contact_object1_id2;
    p6_a15 := rosetta_g_miss_num_map(ddx_qpyv_rec.created_by);
    p6_a16 := ddx_qpyv_rec.creation_date;
    p6_a17 := rosetta_g_miss_num_map(ddx_qpyv_rec.last_updated_by);
    p6_a18 := ddx_qpyv_rec.last_update_date;
    p6_a19 := rosetta_g_miss_num_map(ddx_qpyv_rec.last_update_login);
  end;

  procedure update_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_DATE_TABLE
    , p5_a5 JTF_VARCHAR2_TABLE_100
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_VARCHAR2_TABLE_600
    , p5_a9 JTF_VARCHAR2_TABLE_100
    , p5_a10 JTF_VARCHAR2_TABLE_100
    , p5_a11 JTF_VARCHAR2_TABLE_200
    , p5_a12 JTF_VARCHAR2_TABLE_100
    , p5_a13 JTF_VARCHAR2_TABLE_100
    , p5_a14 JTF_VARCHAR2_TABLE_200
    , p5_a15 JTF_NUMBER_TABLE
    , p5_a16 JTF_DATE_TABLE
    , p5_a17 JTF_NUMBER_TABLE
    , p5_a18 JTF_DATE_TABLE
    , p5_a19 JTF_NUMBER_TABLE
    , p6_a0 out nocopy JTF_NUMBER_TABLE
    , p6_a1 out nocopy JTF_NUMBER_TABLE
    , p6_a2 out nocopy JTF_NUMBER_TABLE
    , p6_a3 out nocopy JTF_NUMBER_TABLE
    , p6_a4 out nocopy JTF_DATE_TABLE
    , p6_a5 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a6 out nocopy JTF_NUMBER_TABLE
    , p6_a7 out nocopy JTF_NUMBER_TABLE
    , p6_a8 out nocopy JTF_VARCHAR2_TABLE_600
    , p6_a9 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a10 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a11 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a12 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a13 out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a14 out nocopy JTF_VARCHAR2_TABLE_200
    , p6_a15 out nocopy JTF_NUMBER_TABLE
    , p6_a16 out nocopy JTF_DATE_TABLE
    , p6_a17 out nocopy JTF_NUMBER_TABLE
    , p6_a18 out nocopy JTF_DATE_TABLE
    , p6_a19 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_qpyv_tbl okl_qpy_pvt.qpyv_tbl_type;
    ddx_qpyv_tbl okl_qpy_pvt.qpyv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_qpy_pvt_w.rosetta_table_copy_in_p5(ddp_qpyv_tbl, p5_a0
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
      );


    -- here's the delegated call to the old PL/SQL routine
    okl_qpy_pvt.update_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_qpyv_tbl,
      ddx_qpyv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    okl_qpy_pvt_w.rosetta_table_copy_out_p5(ddx_qpyv_tbl, p6_a0
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
      );
  end;

  procedure delete_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  DATE := fnd_api.g_miss_date
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  VARCHAR2 := fnd_api.g_miss_char
    , p5_a10  VARCHAR2 := fnd_api.g_miss_char
    , p5_a11  VARCHAR2 := fnd_api.g_miss_char
    , p5_a12  VARCHAR2 := fnd_api.g_miss_char
    , p5_a13  VARCHAR2 := fnd_api.g_miss_char
    , p5_a14  VARCHAR2 := fnd_api.g_miss_char
    , p5_a15  NUMBER := 0-1962.0724
    , p5_a16  DATE := fnd_api.g_miss_date
    , p5_a17  NUMBER := 0-1962.0724
    , p5_a18  DATE := fnd_api.g_miss_date
    , p5_a19  NUMBER := 0-1962.0724
  )

  as
    ddp_qpyv_rec okl_qpy_pvt.qpyv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_qpyv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_qpyv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_qpyv_rec.qte_id := rosetta_g_miss_num_map(p5_a2);
    ddp_qpyv_rec.cpl_id := rosetta_g_miss_num_map(p5_a3);
    ddp_qpyv_rec.date_sent := rosetta_g_miss_date_in_map(p5_a4);
    ddp_qpyv_rec.qpt_code := p5_a5;
    ddp_qpyv_rec.delay_days := rosetta_g_miss_num_map(p5_a6);
    ddp_qpyv_rec.allocation_percentage := rosetta_g_miss_num_map(p5_a7);
    ddp_qpyv_rec.email_address := p5_a8;
    ddp_qpyv_rec.party_jtot_object1_code := p5_a9;
    ddp_qpyv_rec.party_object1_id1 := p5_a10;
    ddp_qpyv_rec.party_object1_id2 := p5_a11;
    ddp_qpyv_rec.contact_jtot_object1_code := p5_a12;
    ddp_qpyv_rec.contact_object1_id1 := p5_a13;
    ddp_qpyv_rec.contact_object1_id2 := p5_a14;
    ddp_qpyv_rec.created_by := rosetta_g_miss_num_map(p5_a15);
    ddp_qpyv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a16);
    ddp_qpyv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a17);
    ddp_qpyv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a18);
    ddp_qpyv_rec.last_update_login := rosetta_g_miss_num_map(p5_a19);

    -- here's the delegated call to the old PL/SQL routine
    okl_qpy_pvt.delete_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_qpyv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure delete_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_DATE_TABLE
    , p5_a5 JTF_VARCHAR2_TABLE_100
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_VARCHAR2_TABLE_600
    , p5_a9 JTF_VARCHAR2_TABLE_100
    , p5_a10 JTF_VARCHAR2_TABLE_100
    , p5_a11 JTF_VARCHAR2_TABLE_200
    , p5_a12 JTF_VARCHAR2_TABLE_100
    , p5_a13 JTF_VARCHAR2_TABLE_100
    , p5_a14 JTF_VARCHAR2_TABLE_200
    , p5_a15 JTF_NUMBER_TABLE
    , p5_a16 JTF_DATE_TABLE
    , p5_a17 JTF_NUMBER_TABLE
    , p5_a18 JTF_DATE_TABLE
    , p5_a19 JTF_NUMBER_TABLE
  )

  as
    ddp_qpyv_tbl okl_qpy_pvt.qpyv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_qpy_pvt_w.rosetta_table_copy_in_p5(ddp_qpyv_tbl, p5_a0
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
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_qpy_pvt.delete_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_qpyv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure validate_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0  NUMBER := 0-1962.0724
    , p5_a1  NUMBER := 0-1962.0724
    , p5_a2  NUMBER := 0-1962.0724
    , p5_a3  NUMBER := 0-1962.0724
    , p5_a4  DATE := fnd_api.g_miss_date
    , p5_a5  VARCHAR2 := fnd_api.g_miss_char
    , p5_a6  NUMBER := 0-1962.0724
    , p5_a7  NUMBER := 0-1962.0724
    , p5_a8  VARCHAR2 := fnd_api.g_miss_char
    , p5_a9  VARCHAR2 := fnd_api.g_miss_char
    , p5_a10  VARCHAR2 := fnd_api.g_miss_char
    , p5_a11  VARCHAR2 := fnd_api.g_miss_char
    , p5_a12  VARCHAR2 := fnd_api.g_miss_char
    , p5_a13  VARCHAR2 := fnd_api.g_miss_char
    , p5_a14  VARCHAR2 := fnd_api.g_miss_char
    , p5_a15  NUMBER := 0-1962.0724
    , p5_a16  DATE := fnd_api.g_miss_date
    , p5_a17  NUMBER := 0-1962.0724
    , p5_a18  DATE := fnd_api.g_miss_date
    , p5_a19  NUMBER := 0-1962.0724
  )

  as
    ddp_qpyv_rec okl_qpy_pvt.qpyv_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_qpyv_rec.id := rosetta_g_miss_num_map(p5_a0);
    ddp_qpyv_rec.object_version_number := rosetta_g_miss_num_map(p5_a1);
    ddp_qpyv_rec.qte_id := rosetta_g_miss_num_map(p5_a2);
    ddp_qpyv_rec.cpl_id := rosetta_g_miss_num_map(p5_a3);
    ddp_qpyv_rec.date_sent := rosetta_g_miss_date_in_map(p5_a4);
    ddp_qpyv_rec.qpt_code := p5_a5;
    ddp_qpyv_rec.delay_days := rosetta_g_miss_num_map(p5_a6);
    ddp_qpyv_rec.allocation_percentage := rosetta_g_miss_num_map(p5_a7);
    ddp_qpyv_rec.email_address := p5_a8;
    ddp_qpyv_rec.party_jtot_object1_code := p5_a9;
    ddp_qpyv_rec.party_object1_id1 := p5_a10;
    ddp_qpyv_rec.party_object1_id2 := p5_a11;
    ddp_qpyv_rec.contact_jtot_object1_code := p5_a12;
    ddp_qpyv_rec.contact_object1_id1 := p5_a13;
    ddp_qpyv_rec.contact_object1_id2 := p5_a14;
    ddp_qpyv_rec.created_by := rosetta_g_miss_num_map(p5_a15);
    ddp_qpyv_rec.creation_date := rosetta_g_miss_date_in_map(p5_a16);
    ddp_qpyv_rec.last_updated_by := rosetta_g_miss_num_map(p5_a17);
    ddp_qpyv_rec.last_update_date := rosetta_g_miss_date_in_map(p5_a18);
    ddp_qpyv_rec.last_update_login := rosetta_g_miss_num_map(p5_a19);

    -- here's the delegated call to the old PL/SQL routine
    okl_qpy_pvt.validate_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_qpyv_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure validate_row(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_DATE_TABLE
    , p5_a5 JTF_VARCHAR2_TABLE_100
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_VARCHAR2_TABLE_600
    , p5_a9 JTF_VARCHAR2_TABLE_100
    , p5_a10 JTF_VARCHAR2_TABLE_100
    , p5_a11 JTF_VARCHAR2_TABLE_200
    , p5_a12 JTF_VARCHAR2_TABLE_100
    , p5_a13 JTF_VARCHAR2_TABLE_100
    , p5_a14 JTF_VARCHAR2_TABLE_200
    , p5_a15 JTF_NUMBER_TABLE
    , p5_a16 JTF_DATE_TABLE
    , p5_a17 JTF_NUMBER_TABLE
    , p5_a18 JTF_DATE_TABLE
    , p5_a19 JTF_NUMBER_TABLE
  )

  as
    ddp_qpyv_tbl okl_qpy_pvt.qpyv_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    okl_qpy_pvt_w.rosetta_table_copy_in_p5(ddp_qpyv_tbl, p5_a0
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
      );

    -- here's the delegated call to the old PL/SQL routine
    okl_qpy_pvt.validate_row(p_api_version,
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_qpyv_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

end okl_qpy_pvt_w;

/
