--------------------------------------------------------
--  DDL for Package Body IEX_COSTS_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEX_COSTS_PVT_W" as
  /* $Header: iexwcosb.pls 120.1 2005/07/06 14:04:24 schekuri noship $ */
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

  procedure rosetta_table_copy_in_p3(t out nocopy iex_costs_pvt.costs_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_VARCHAR2_TABLE_300
    , a4 JTF_VARCHAR2_TABLE_300
    , a5 JTF_VARCHAR2_TABLE_300
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_DATE_TABLE
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_VARCHAR2_TABLE_100
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_DATE_TABLE
    , a14 JTF_VARCHAR2_TABLE_300
    , a15 JTF_VARCHAR2_TABLE_300
    , a16 JTF_NUMBER_TABLE
    , a17 JTF_NUMBER_TABLE
    , a18 JTF_DATE_TABLE
    , a19 JTF_NUMBER_TABLE
    , a20 JTF_DATE_TABLE
    , a21 JTF_NUMBER_TABLE
    , a22 JTF_NUMBER_TABLE
    , a23 JTF_NUMBER_TABLE
    , a24 JTF_DATE_TABLE
    , a25 JTF_VARCHAR2_TABLE_300
    , a26 JTF_VARCHAR2_TABLE_300
    , a27 JTF_VARCHAR2_TABLE_300
    , a28 JTF_VARCHAR2_TABLE_300
    , a29 JTF_VARCHAR2_TABLE_300
    , a30 JTF_VARCHAR2_TABLE_300
    , a31 JTF_VARCHAR2_TABLE_300
    , a32 JTF_VARCHAR2_TABLE_300
    , a33 JTF_VARCHAR2_TABLE_300
    , a34 JTF_VARCHAR2_TABLE_300
    , a35 JTF_VARCHAR2_TABLE_300
    , a36 JTF_VARCHAR2_TABLE_300
    , a37 JTF_VARCHAR2_TABLE_300
    , a38 JTF_VARCHAR2_TABLE_300
    , a39 JTF_VARCHAR2_TABLE_300
    , a40 JTF_VARCHAR2_TABLE_300
    , a41 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).cost_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).case_id := rosetta_g_miss_num_map(a1(indx));
          t(ddindx).delinquency_id := rosetta_g_miss_num_map(a2(indx));
          t(ddindx).cost_type_code := a3(indx);
          t(ddindx).cost_item_type_code := a4(indx);
          t(ddindx).cost_item_type_desc := a5(indx);
          t(ddindx).cost_item_amount := rosetta_g_miss_num_map(a6(indx));
          t(ddindx).cost_item_currency_code := a7(indx);
          t(ddindx).cost_item_qty := rosetta_g_miss_num_map(a8(indx));
          t(ddindx).cost_item_date := rosetta_g_miss_date_in_map(a9(indx));
          t(ddindx).functional_amount := rosetta_g_miss_num_map(a10(indx));
          t(ddindx).exchange_type := a11(indx);
          t(ddindx).exchange_rate := rosetta_g_miss_num_map(a12(indx));
          t(ddindx).exchange_date := rosetta_g_miss_date_in_map(a13(indx));
          t(ddindx).cost_item_approved := a14(indx);
          t(ddindx).active_flag := a15(indx);
          t(ddindx).object_version_number := rosetta_g_miss_num_map(a16(indx));
          t(ddindx).created_by := rosetta_g_miss_num_map(a17(indx));
          t(ddindx).creation_date := rosetta_g_miss_date_in_map(a18(indx));
          t(ddindx).last_updated_by := rosetta_g_miss_num_map(a19(indx));
          t(ddindx).last_update_date := rosetta_g_miss_date_in_map(a20(indx));
          t(ddindx).request_id := rosetta_g_miss_num_map(a21(indx));
          t(ddindx).program_application_id := rosetta_g_miss_num_map(a22(indx));
          t(ddindx).program_id := rosetta_g_miss_num_map(a23(indx));
          t(ddindx).program_update_date := rosetta_g_miss_date_in_map(a24(indx));
          t(ddindx).attribute_category := a25(indx);
          t(ddindx).attribute1 := a26(indx);
          t(ddindx).attribute2 := a27(indx);
          t(ddindx).attribute3 := a28(indx);
          t(ddindx).attribute4 := a29(indx);
          t(ddindx).attribute5 := a30(indx);
          t(ddindx).attribute6 := a31(indx);
          t(ddindx).attribute7 := a32(indx);
          t(ddindx).attribute8 := a33(indx);
          t(ddindx).attribute9 := a34(indx);
          t(ddindx).attribute10 := a35(indx);
          t(ddindx).attribute11 := a36(indx);
          t(ddindx).attribute12 := a37(indx);
          t(ddindx).attribute13 := a38(indx);
          t(ddindx).attribute14 := a39(indx);
          t(ddindx).attribute15 := a40(indx);
          t(ddindx).last_update_login := rosetta_g_miss_num_map(a41(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p3;
  procedure rosetta_table_copy_out_p3(t iex_costs_pvt.costs_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_VARCHAR2_TABLE_300
    , a4 out nocopy JTF_VARCHAR2_TABLE_300
    , a5 out nocopy JTF_VARCHAR2_TABLE_300
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_DATE_TABLE
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_VARCHAR2_TABLE_100
    , a12 out nocopy JTF_NUMBER_TABLE
    , a13 out nocopy JTF_DATE_TABLE
    , a14 out nocopy JTF_VARCHAR2_TABLE_300
    , a15 out nocopy JTF_VARCHAR2_TABLE_300
    , a16 out nocopy JTF_NUMBER_TABLE
    , a17 out nocopy JTF_NUMBER_TABLE
    , a18 out nocopy JTF_DATE_TABLE
    , a19 out nocopy JTF_NUMBER_TABLE
    , a20 out nocopy JTF_DATE_TABLE
    , a21 out nocopy JTF_NUMBER_TABLE
    , a22 out nocopy JTF_NUMBER_TABLE
    , a23 out nocopy JTF_NUMBER_TABLE
    , a24 out nocopy JTF_DATE_TABLE
    , a25 out nocopy JTF_VARCHAR2_TABLE_300
    , a26 out nocopy JTF_VARCHAR2_TABLE_300
    , a27 out nocopy JTF_VARCHAR2_TABLE_300
    , a28 out nocopy JTF_VARCHAR2_TABLE_300
    , a29 out nocopy JTF_VARCHAR2_TABLE_300
    , a30 out nocopy JTF_VARCHAR2_TABLE_300
    , a31 out nocopy JTF_VARCHAR2_TABLE_300
    , a32 out nocopy JTF_VARCHAR2_TABLE_300
    , a33 out nocopy JTF_VARCHAR2_TABLE_300
    , a34 out nocopy JTF_VARCHAR2_TABLE_300
    , a35 out nocopy JTF_VARCHAR2_TABLE_300
    , a36 out nocopy JTF_VARCHAR2_TABLE_300
    , a37 out nocopy JTF_VARCHAR2_TABLE_300
    , a38 out nocopy JTF_VARCHAR2_TABLE_300
    , a39 out nocopy JTF_VARCHAR2_TABLE_300
    , a40 out nocopy JTF_VARCHAR2_TABLE_300
    , a41 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_VARCHAR2_TABLE_300();
    a4 := JTF_VARCHAR2_TABLE_300();
    a5 := JTF_VARCHAR2_TABLE_300();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_VARCHAR2_TABLE_100();
    a8 := JTF_NUMBER_TABLE();
    a9 := JTF_DATE_TABLE();
    a10 := JTF_NUMBER_TABLE();
    a11 := JTF_VARCHAR2_TABLE_100();
    a12 := JTF_NUMBER_TABLE();
    a13 := JTF_DATE_TABLE();
    a14 := JTF_VARCHAR2_TABLE_300();
    a15 := JTF_VARCHAR2_TABLE_300();
    a16 := JTF_NUMBER_TABLE();
    a17 := JTF_NUMBER_TABLE();
    a18 := JTF_DATE_TABLE();
    a19 := JTF_NUMBER_TABLE();
    a20 := JTF_DATE_TABLE();
    a21 := JTF_NUMBER_TABLE();
    a22 := JTF_NUMBER_TABLE();
    a23 := JTF_NUMBER_TABLE();
    a24 := JTF_DATE_TABLE();
    a25 := JTF_VARCHAR2_TABLE_300();
    a26 := JTF_VARCHAR2_TABLE_300();
    a27 := JTF_VARCHAR2_TABLE_300();
    a28 := JTF_VARCHAR2_TABLE_300();
    a29 := JTF_VARCHAR2_TABLE_300();
    a30 := JTF_VARCHAR2_TABLE_300();
    a31 := JTF_VARCHAR2_TABLE_300();
    a32 := JTF_VARCHAR2_TABLE_300();
    a33 := JTF_VARCHAR2_TABLE_300();
    a34 := JTF_VARCHAR2_TABLE_300();
    a35 := JTF_VARCHAR2_TABLE_300();
    a36 := JTF_VARCHAR2_TABLE_300();
    a37 := JTF_VARCHAR2_TABLE_300();
    a38 := JTF_VARCHAR2_TABLE_300();
    a39 := JTF_VARCHAR2_TABLE_300();
    a40 := JTF_VARCHAR2_TABLE_300();
    a41 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_VARCHAR2_TABLE_300();
      a4 := JTF_VARCHAR2_TABLE_300();
      a5 := JTF_VARCHAR2_TABLE_300();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_VARCHAR2_TABLE_100();
      a8 := JTF_NUMBER_TABLE();
      a9 := JTF_DATE_TABLE();
      a10 := JTF_NUMBER_TABLE();
      a11 := JTF_VARCHAR2_TABLE_100();
      a12 := JTF_NUMBER_TABLE();
      a13 := JTF_DATE_TABLE();
      a14 := JTF_VARCHAR2_TABLE_300();
      a15 := JTF_VARCHAR2_TABLE_300();
      a16 := JTF_NUMBER_TABLE();
      a17 := JTF_NUMBER_TABLE();
      a18 := JTF_DATE_TABLE();
      a19 := JTF_NUMBER_TABLE();
      a20 := JTF_DATE_TABLE();
      a21 := JTF_NUMBER_TABLE();
      a22 := JTF_NUMBER_TABLE();
      a23 := JTF_NUMBER_TABLE();
      a24 := JTF_DATE_TABLE();
      a25 := JTF_VARCHAR2_TABLE_300();
      a26 := JTF_VARCHAR2_TABLE_300();
      a27 := JTF_VARCHAR2_TABLE_300();
      a28 := JTF_VARCHAR2_TABLE_300();
      a29 := JTF_VARCHAR2_TABLE_300();
      a30 := JTF_VARCHAR2_TABLE_300();
      a31 := JTF_VARCHAR2_TABLE_300();
      a32 := JTF_VARCHAR2_TABLE_300();
      a33 := JTF_VARCHAR2_TABLE_300();
      a34 := JTF_VARCHAR2_TABLE_300();
      a35 := JTF_VARCHAR2_TABLE_300();
      a36 := JTF_VARCHAR2_TABLE_300();
      a37 := JTF_VARCHAR2_TABLE_300();
      a38 := JTF_VARCHAR2_TABLE_300();
      a39 := JTF_VARCHAR2_TABLE_300();
      a40 := JTF_VARCHAR2_TABLE_300();
      a41 := JTF_NUMBER_TABLE();
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
        a31.extend(t.count);
        a32.extend(t.count);
        a33.extend(t.count);
        a34.extend(t.count);
        a35.extend(t.count);
        a36.extend(t.count);
        a37.extend(t.count);
        a38.extend(t.count);
        a39.extend(t.count);
        a40.extend(t.count);
        a41.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).cost_id);
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).case_id);
          a2(indx) := rosetta_g_miss_num_map(t(ddindx).delinquency_id);
          a3(indx) := t(ddindx).cost_type_code;
          a4(indx) := t(ddindx).cost_item_type_code;
          a5(indx) := t(ddindx).cost_item_type_desc;
          a6(indx) := rosetta_g_miss_num_map(t(ddindx).cost_item_amount);
          a7(indx) := t(ddindx).cost_item_currency_code;
          a8(indx) := rosetta_g_miss_num_map(t(ddindx).cost_item_qty);
          a9(indx) := t(ddindx).cost_item_date;
          a10(indx) := rosetta_g_miss_num_map(t(ddindx).functional_amount);
          a11(indx) := t(ddindx).exchange_type;
          a12(indx) := rosetta_g_miss_num_map(t(ddindx).exchange_rate);
          a13(indx) := t(ddindx).exchange_date;
          a14(indx) := t(ddindx).cost_item_approved;
          a15(indx) := t(ddindx).active_flag;
          a16(indx) := rosetta_g_miss_num_map(t(ddindx).object_version_number);
          a17(indx) := rosetta_g_miss_num_map(t(ddindx).created_by);
          a18(indx) := t(ddindx).creation_date;
          a19(indx) := rosetta_g_miss_num_map(t(ddindx).last_updated_by);
          a20(indx) := t(ddindx).last_update_date;
          a21(indx) := rosetta_g_miss_num_map(t(ddindx).request_id);
          a22(indx) := rosetta_g_miss_num_map(t(ddindx).program_application_id);
          a23(indx) := rosetta_g_miss_num_map(t(ddindx).program_id);
          a24(indx) := t(ddindx).program_update_date;
          a25(indx) := t(ddindx).attribute_category;
          a26(indx) := t(ddindx).attribute1;
          a27(indx) := t(ddindx).attribute2;
          a28(indx) := t(ddindx).attribute3;
          a29(indx) := t(ddindx).attribute4;
          a30(indx) := t(ddindx).attribute5;
          a31(indx) := t(ddindx).attribute6;
          a32(indx) := t(ddindx).attribute7;
          a33(indx) := t(ddindx).attribute8;
          a34(indx) := t(ddindx).attribute9;
          a35(indx) := t(ddindx).attribute10;
          a36(indx) := t(ddindx).attribute11;
          a37(indx) := t(ddindx).attribute12;
          a38(indx) := t(ddindx).attribute13;
          a39(indx) := t(ddindx).attribute14;
          a40(indx) := t(ddindx).attribute15;
          a41(indx) := rosetta_g_miss_num_map(t(ddindx).last_update_login);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p3;

  procedure create_costs(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_cost_id out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p4_a0  NUMBER := 0-1962.0724
    , p4_a1  NUMBER := 0-1962.0724
    , p4_a2  NUMBER := 0-1962.0724
    , p4_a3  VARCHAR2 := fnd_api.g_miss_char
    , p4_a4  VARCHAR2 := fnd_api.g_miss_char
    , p4_a5  VARCHAR2 := fnd_api.g_miss_char
    , p4_a6  NUMBER := 0-1962.0724
    , p4_a7  VARCHAR2 := fnd_api.g_miss_char
    , p4_a8  NUMBER := 0-1962.0724
    , p4_a9  DATE := fnd_api.g_miss_date
    , p4_a10  NUMBER := 0-1962.0724
    , p4_a11  VARCHAR2 := fnd_api.g_miss_char
    , p4_a12  NUMBER := 0-1962.0724
    , p4_a13  DATE := fnd_api.g_miss_date
    , p4_a14  VARCHAR2 := fnd_api.g_miss_char
    , p4_a15  VARCHAR2 := fnd_api.g_miss_char
    , p4_a16  NUMBER := 0-1962.0724
    , p4_a17  NUMBER := 0-1962.0724
    , p4_a18  DATE := fnd_api.g_miss_date
    , p4_a19  NUMBER := 0-1962.0724
    , p4_a20  DATE := fnd_api.g_miss_date
    , p4_a21  NUMBER := 0-1962.0724
    , p4_a22  NUMBER := 0-1962.0724
    , p4_a23  NUMBER := 0-1962.0724
    , p4_a24  DATE := fnd_api.g_miss_date
    , p4_a25  VARCHAR2 := fnd_api.g_miss_char
    , p4_a26  VARCHAR2 := fnd_api.g_miss_char
    , p4_a27  VARCHAR2 := fnd_api.g_miss_char
    , p4_a28  VARCHAR2 := fnd_api.g_miss_char
    , p4_a29  VARCHAR2 := fnd_api.g_miss_char
    , p4_a30  VARCHAR2 := fnd_api.g_miss_char
    , p4_a31  VARCHAR2 := fnd_api.g_miss_char
    , p4_a32  VARCHAR2 := fnd_api.g_miss_char
    , p4_a33  VARCHAR2 := fnd_api.g_miss_char
    , p4_a34  VARCHAR2 := fnd_api.g_miss_char
    , p4_a35  VARCHAR2 := fnd_api.g_miss_char
    , p4_a36  VARCHAR2 := fnd_api.g_miss_char
    , p4_a37  VARCHAR2 := fnd_api.g_miss_char
    , p4_a38  VARCHAR2 := fnd_api.g_miss_char
    , p4_a39  VARCHAR2 := fnd_api.g_miss_char
    , p4_a40  VARCHAR2 := fnd_api.g_miss_char
    , p4_a41  NUMBER := 0-1962.0724
  )

  as
    ddp_costs_rec iex_costs_pvt.costs_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    ddp_costs_rec.cost_id := rosetta_g_miss_num_map(p4_a0);
    ddp_costs_rec.case_id := rosetta_g_miss_num_map(p4_a1);
    ddp_costs_rec.delinquency_id := rosetta_g_miss_num_map(p4_a2);
    ddp_costs_rec.cost_type_code := p4_a3;
    ddp_costs_rec.cost_item_type_code := p4_a4;
    ddp_costs_rec.cost_item_type_desc := p4_a5;
    ddp_costs_rec.cost_item_amount := rosetta_g_miss_num_map(p4_a6);
    ddp_costs_rec.cost_item_currency_code := p4_a7;
    ddp_costs_rec.cost_item_qty := rosetta_g_miss_num_map(p4_a8);
    ddp_costs_rec.cost_item_date := rosetta_g_miss_date_in_map(p4_a9);
    ddp_costs_rec.functional_amount := rosetta_g_miss_num_map(p4_a10);
    ddp_costs_rec.exchange_type := p4_a11;
    ddp_costs_rec.exchange_rate := rosetta_g_miss_num_map(p4_a12);
    ddp_costs_rec.exchange_date := rosetta_g_miss_date_in_map(p4_a13);
    ddp_costs_rec.cost_item_approved := p4_a14;
    ddp_costs_rec.active_flag := p4_a15;
    ddp_costs_rec.object_version_number := rosetta_g_miss_num_map(p4_a16);
    ddp_costs_rec.created_by := rosetta_g_miss_num_map(p4_a17);
    ddp_costs_rec.creation_date := rosetta_g_miss_date_in_map(p4_a18);
    ddp_costs_rec.last_updated_by := rosetta_g_miss_num_map(p4_a19);
    ddp_costs_rec.last_update_date := rosetta_g_miss_date_in_map(p4_a20);
    ddp_costs_rec.request_id := rosetta_g_miss_num_map(p4_a21);
    ddp_costs_rec.program_application_id := rosetta_g_miss_num_map(p4_a22);
    ddp_costs_rec.program_id := rosetta_g_miss_num_map(p4_a23);
    ddp_costs_rec.program_update_date := rosetta_g_miss_date_in_map(p4_a24);
    ddp_costs_rec.attribute_category := p4_a25;
    ddp_costs_rec.attribute1 := p4_a26;
    ddp_costs_rec.attribute2 := p4_a27;
    ddp_costs_rec.attribute3 := p4_a28;
    ddp_costs_rec.attribute4 := p4_a29;
    ddp_costs_rec.attribute5 := p4_a30;
    ddp_costs_rec.attribute6 := p4_a31;
    ddp_costs_rec.attribute7 := p4_a32;
    ddp_costs_rec.attribute8 := p4_a33;
    ddp_costs_rec.attribute9 := p4_a34;
    ddp_costs_rec.attribute10 := p4_a35;
    ddp_costs_rec.attribute11 := p4_a36;
    ddp_costs_rec.attribute12 := p4_a37;
    ddp_costs_rec.attribute13 := p4_a38;
    ddp_costs_rec.attribute14 := p4_a39;
    ddp_costs_rec.attribute15 := p4_a40;
    ddp_costs_rec.last_update_login := rosetta_g_miss_num_map(p4_a41);





    -- here's the delegated call to the old PL/SQL routine
    iex_costs_pvt.create_costs(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      ddp_costs_rec,
      x_cost_id,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

  procedure update_costs(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , xo_object_version_number out nocopy  NUMBER
    , p4_a0  NUMBER := 0-1962.0724
    , p4_a1  NUMBER := 0-1962.0724
    , p4_a2  NUMBER := 0-1962.0724
    , p4_a3  VARCHAR2 := fnd_api.g_miss_char
    , p4_a4  VARCHAR2 := fnd_api.g_miss_char
    , p4_a5  VARCHAR2 := fnd_api.g_miss_char
    , p4_a6  NUMBER := 0-1962.0724
    , p4_a7  VARCHAR2 := fnd_api.g_miss_char
    , p4_a8  NUMBER := 0-1962.0724
    , p4_a9  DATE := fnd_api.g_miss_date
    , p4_a10  NUMBER := 0-1962.0724
    , p4_a11  VARCHAR2 := fnd_api.g_miss_char
    , p4_a12  NUMBER := 0-1962.0724
    , p4_a13  DATE := fnd_api.g_miss_date
    , p4_a14  VARCHAR2 := fnd_api.g_miss_char
    , p4_a15  VARCHAR2 := fnd_api.g_miss_char
    , p4_a16  NUMBER := 0-1962.0724
    , p4_a17  NUMBER := 0-1962.0724
    , p4_a18  DATE := fnd_api.g_miss_date
    , p4_a19  NUMBER := 0-1962.0724
    , p4_a20  DATE := fnd_api.g_miss_date
    , p4_a21  NUMBER := 0-1962.0724
    , p4_a22  NUMBER := 0-1962.0724
    , p4_a23  NUMBER := 0-1962.0724
    , p4_a24  DATE := fnd_api.g_miss_date
    , p4_a25  VARCHAR2 := fnd_api.g_miss_char
    , p4_a26  VARCHAR2 := fnd_api.g_miss_char
    , p4_a27  VARCHAR2 := fnd_api.g_miss_char
    , p4_a28  VARCHAR2 := fnd_api.g_miss_char
    , p4_a29  VARCHAR2 := fnd_api.g_miss_char
    , p4_a30  VARCHAR2 := fnd_api.g_miss_char
    , p4_a31  VARCHAR2 := fnd_api.g_miss_char
    , p4_a32  VARCHAR2 := fnd_api.g_miss_char
    , p4_a33  VARCHAR2 := fnd_api.g_miss_char
    , p4_a34  VARCHAR2 := fnd_api.g_miss_char
    , p4_a35  VARCHAR2 := fnd_api.g_miss_char
    , p4_a36  VARCHAR2 := fnd_api.g_miss_char
    , p4_a37  VARCHAR2 := fnd_api.g_miss_char
    , p4_a38  VARCHAR2 := fnd_api.g_miss_char
    , p4_a39  VARCHAR2 := fnd_api.g_miss_char
    , p4_a40  VARCHAR2 := fnd_api.g_miss_char
    , p4_a41  NUMBER := 0-1962.0724
  )

  as
    ddp_costs_rec iex_costs_pvt.costs_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any




    ddp_costs_rec.cost_id := rosetta_g_miss_num_map(p4_a0);
    ddp_costs_rec.case_id := rosetta_g_miss_num_map(p4_a1);
    ddp_costs_rec.delinquency_id := rosetta_g_miss_num_map(p4_a2);
    ddp_costs_rec.cost_type_code := p4_a3;
    ddp_costs_rec.cost_item_type_code := p4_a4;
    ddp_costs_rec.cost_item_type_desc := p4_a5;
    ddp_costs_rec.cost_item_amount := rosetta_g_miss_num_map(p4_a6);
    ddp_costs_rec.cost_item_currency_code := p4_a7;
    ddp_costs_rec.cost_item_qty := rosetta_g_miss_num_map(p4_a8);
    ddp_costs_rec.cost_item_date := rosetta_g_miss_date_in_map(p4_a9);
    ddp_costs_rec.functional_amount := rosetta_g_miss_num_map(p4_a10);
    ddp_costs_rec.exchange_type := p4_a11;
    ddp_costs_rec.exchange_rate := rosetta_g_miss_num_map(p4_a12);
    ddp_costs_rec.exchange_date := rosetta_g_miss_date_in_map(p4_a13);
    ddp_costs_rec.cost_item_approved := p4_a14;
    ddp_costs_rec.active_flag := p4_a15;
    ddp_costs_rec.object_version_number := rosetta_g_miss_num_map(p4_a16);
    ddp_costs_rec.created_by := rosetta_g_miss_num_map(p4_a17);
    ddp_costs_rec.creation_date := rosetta_g_miss_date_in_map(p4_a18);
    ddp_costs_rec.last_updated_by := rosetta_g_miss_num_map(p4_a19);
    ddp_costs_rec.last_update_date := rosetta_g_miss_date_in_map(p4_a20);
    ddp_costs_rec.request_id := rosetta_g_miss_num_map(p4_a21);
    ddp_costs_rec.program_application_id := rosetta_g_miss_num_map(p4_a22);
    ddp_costs_rec.program_id := rosetta_g_miss_num_map(p4_a23);
    ddp_costs_rec.program_update_date := rosetta_g_miss_date_in_map(p4_a24);
    ddp_costs_rec.attribute_category := p4_a25;
    ddp_costs_rec.attribute1 := p4_a26;
    ddp_costs_rec.attribute2 := p4_a27;
    ddp_costs_rec.attribute3 := p4_a28;
    ddp_costs_rec.attribute4 := p4_a29;
    ddp_costs_rec.attribute5 := p4_a30;
    ddp_costs_rec.attribute6 := p4_a31;
    ddp_costs_rec.attribute7 := p4_a32;
    ddp_costs_rec.attribute8 := p4_a33;
    ddp_costs_rec.attribute9 := p4_a34;
    ddp_costs_rec.attribute10 := p4_a35;
    ddp_costs_rec.attribute11 := p4_a36;
    ddp_costs_rec.attribute12 := p4_a37;
    ddp_costs_rec.attribute13 := p4_a38;
    ddp_costs_rec.attribute14 := p4_a39;
    ddp_costs_rec.attribute15 := p4_a40;
    ddp_costs_rec.last_update_login := rosetta_g_miss_num_map(p4_a41);





    -- here's the delegated call to the old PL/SQL routine
    iex_costs_pvt.update_costs(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      ddp_costs_rec,
      x_return_status,
      x_msg_count,
      x_msg_data,
      xo_object_version_number);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

end iex_costs_pvt_w;

/
