--------------------------------------------------------
--  DDL for Package Body CN_SCA_CRRULEATTR_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_SCA_CRRULEATTR_PVT_W" as
  /* $Header: cnwscrrb.pls 120.2 2005/09/14 03:43 vensrini noship $ */
  procedure rosetta_table_copy_in_p1(t out nocopy cn_sca_crruleattr_pvt.credit_rule_attr_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_VARCHAR2_TABLE_100
    , a9 JTF_VARCHAR2_TABLE_300
    , a10 JTF_VARCHAR2_TABLE_300
    , a11 JTF_VARCHAR2_TABLE_300
    , a12 JTF_VARCHAR2_TABLE_300
    , a13 JTF_VARCHAR2_TABLE_300
    , a14 JTF_VARCHAR2_TABLE_300
    , a15 JTF_VARCHAR2_TABLE_300
    , a16 JTF_VARCHAR2_TABLE_300
    , a17 JTF_VARCHAR2_TABLE_300
    , a18 JTF_VARCHAR2_TABLE_300
    , a19 JTF_VARCHAR2_TABLE_300
    , a20 JTF_VARCHAR2_TABLE_300
    , a21 JTF_VARCHAR2_TABLE_300
    , a22 JTF_VARCHAR2_TABLE_300
    , a23 JTF_VARCHAR2_TABLE_300
    , a24 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).sca_rule_attribute_id := a0(indx);
          t(ddindx).transaction_source := a1(indx);
          t(ddindx).destination_column := a2(indx);
          t(ddindx).user_name := a3(indx);
          t(ddindx).value_set_id := a4(indx);
          t(ddindx).data_type := a5(indx);
          t(ddindx).source_column := a6(indx);
          t(ddindx).enable_flag := a7(indx);
          t(ddindx).attribute_category := a8(indx);
          t(ddindx).attribute1 := a9(indx);
          t(ddindx).attribute2 := a10(indx);
          t(ddindx).attribute3 := a11(indx);
          t(ddindx).attribute4 := a12(indx);
          t(ddindx).attribute5 := a13(indx);
          t(ddindx).attribute6 := a14(indx);
          t(ddindx).attribute7 := a15(indx);
          t(ddindx).attribute8 := a16(indx);
          t(ddindx).attribute9 := a17(indx);
          t(ddindx).attribute10 := a18(indx);
          t(ddindx).attribute11 := a19(indx);
          t(ddindx).attribute12 := a20(indx);
          t(ddindx).attribute13 := a21(indx);
          t(ddindx).attribute14 := a22(indx);
          t(ddindx).attribute15 := a23(indx);
          t(ddindx).object_version_number := a24(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p1;
  procedure rosetta_table_copy_out_p1(t cn_sca_crruleattr_pvt.credit_rule_attr_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_NUMBER_TABLE
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    , a8 out nocopy JTF_VARCHAR2_TABLE_100
    , a9 out nocopy JTF_VARCHAR2_TABLE_300
    , a10 out nocopy JTF_VARCHAR2_TABLE_300
    , a11 out nocopy JTF_VARCHAR2_TABLE_300
    , a12 out nocopy JTF_VARCHAR2_TABLE_300
    , a13 out nocopy JTF_VARCHAR2_TABLE_300
    , a14 out nocopy JTF_VARCHAR2_TABLE_300
    , a15 out nocopy JTF_VARCHAR2_TABLE_300
    , a16 out nocopy JTF_VARCHAR2_TABLE_300
    , a17 out nocopy JTF_VARCHAR2_TABLE_300
    , a18 out nocopy JTF_VARCHAR2_TABLE_300
    , a19 out nocopy JTF_VARCHAR2_TABLE_300
    , a20 out nocopy JTF_VARCHAR2_TABLE_300
    , a21 out nocopy JTF_VARCHAR2_TABLE_300
    , a22 out nocopy JTF_VARCHAR2_TABLE_300
    , a23 out nocopy JTF_VARCHAR2_TABLE_300
    , a24 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_VARCHAR2_TABLE_100();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_VARCHAR2_TABLE_100();
    a6 := JTF_VARCHAR2_TABLE_100();
    a7 := JTF_VARCHAR2_TABLE_100();
    a8 := JTF_VARCHAR2_TABLE_100();
    a9 := JTF_VARCHAR2_TABLE_300();
    a10 := JTF_VARCHAR2_TABLE_300();
    a11 := JTF_VARCHAR2_TABLE_300();
    a12 := JTF_VARCHAR2_TABLE_300();
    a13 := JTF_VARCHAR2_TABLE_300();
    a14 := JTF_VARCHAR2_TABLE_300();
    a15 := JTF_VARCHAR2_TABLE_300();
    a16 := JTF_VARCHAR2_TABLE_300();
    a17 := JTF_VARCHAR2_TABLE_300();
    a18 := JTF_VARCHAR2_TABLE_300();
    a19 := JTF_VARCHAR2_TABLE_300();
    a20 := JTF_VARCHAR2_TABLE_300();
    a21 := JTF_VARCHAR2_TABLE_300();
    a22 := JTF_VARCHAR2_TABLE_300();
    a23 := JTF_VARCHAR2_TABLE_300();
    a24 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_VARCHAR2_TABLE_100();
      a6 := JTF_VARCHAR2_TABLE_100();
      a7 := JTF_VARCHAR2_TABLE_100();
      a8 := JTF_VARCHAR2_TABLE_100();
      a9 := JTF_VARCHAR2_TABLE_300();
      a10 := JTF_VARCHAR2_TABLE_300();
      a11 := JTF_VARCHAR2_TABLE_300();
      a12 := JTF_VARCHAR2_TABLE_300();
      a13 := JTF_VARCHAR2_TABLE_300();
      a14 := JTF_VARCHAR2_TABLE_300();
      a15 := JTF_VARCHAR2_TABLE_300();
      a16 := JTF_VARCHAR2_TABLE_300();
      a17 := JTF_VARCHAR2_TABLE_300();
      a18 := JTF_VARCHAR2_TABLE_300();
      a19 := JTF_VARCHAR2_TABLE_300();
      a20 := JTF_VARCHAR2_TABLE_300();
      a21 := JTF_VARCHAR2_TABLE_300();
      a22 := JTF_VARCHAR2_TABLE_300();
      a23 := JTF_VARCHAR2_TABLE_300();
      a24 := JTF_NUMBER_TABLE();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).sca_rule_attribute_id;
          a1(indx) := t(ddindx).transaction_source;
          a2(indx) := t(ddindx).destination_column;
          a3(indx) := t(ddindx).user_name;
          a4(indx) := t(ddindx).value_set_id;
          a5(indx) := t(ddindx).data_type;
          a6(indx) := t(ddindx).source_column;
          a7(indx) := t(ddindx).enable_flag;
          a8(indx) := t(ddindx).attribute_category;
          a9(indx) := t(ddindx).attribute1;
          a10(indx) := t(ddindx).attribute2;
          a11(indx) := t(ddindx).attribute3;
          a12(indx) := t(ddindx).attribute4;
          a13(indx) := t(ddindx).attribute5;
          a14(indx) := t(ddindx).attribute6;
          a15(indx) := t(ddindx).attribute7;
          a16(indx) := t(ddindx).attribute8;
          a17(indx) := t(ddindx).attribute9;
          a18(indx) := t(ddindx).attribute10;
          a19(indx) := t(ddindx).attribute11;
          a20(indx) := t(ddindx).attribute12;
          a21(indx) := t(ddindx).attribute13;
          a22(indx) := t(ddindx).attribute14;
          a23(indx) := t(ddindx).attribute15;
          a24(indx) := t(ddindx).object_version_number;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p1;

  procedure create_credit_ruleattr(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_valdiation_level  VARCHAR2
    , p_org_id  NUMBER
    , p5_a0  NUMBER
    , p5_a1  VARCHAR2
    , p5_a2  VARCHAR2
    , p5_a3  VARCHAR2
    , p5_a4  NUMBER
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
    , p5_a18  VARCHAR2
    , p5_a19  VARCHAR2
    , p5_a20  VARCHAR2
    , p5_a21  VARCHAR2
    , p5_a22  VARCHAR2
    , p5_a23  VARCHAR2
    , p5_a24  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_credit_rule_attr_rec cn_sca_crruleattr_pvt.credit_rule_attr_rec;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_credit_rule_attr_rec.sca_rule_attribute_id := p5_a0;
    ddp_credit_rule_attr_rec.transaction_source := p5_a1;
    ddp_credit_rule_attr_rec.destination_column := p5_a2;
    ddp_credit_rule_attr_rec.user_name := p5_a3;
    ddp_credit_rule_attr_rec.value_set_id := p5_a4;
    ddp_credit_rule_attr_rec.data_type := p5_a5;
    ddp_credit_rule_attr_rec.source_column := p5_a6;
    ddp_credit_rule_attr_rec.enable_flag := p5_a7;
    ddp_credit_rule_attr_rec.attribute_category := p5_a8;
    ddp_credit_rule_attr_rec.attribute1 := p5_a9;
    ddp_credit_rule_attr_rec.attribute2 := p5_a10;
    ddp_credit_rule_attr_rec.attribute3 := p5_a11;
    ddp_credit_rule_attr_rec.attribute4 := p5_a12;
    ddp_credit_rule_attr_rec.attribute5 := p5_a13;
    ddp_credit_rule_attr_rec.attribute6 := p5_a14;
    ddp_credit_rule_attr_rec.attribute7 := p5_a15;
    ddp_credit_rule_attr_rec.attribute8 := p5_a16;
    ddp_credit_rule_attr_rec.attribute9 := p5_a17;
    ddp_credit_rule_attr_rec.attribute10 := p5_a18;
    ddp_credit_rule_attr_rec.attribute11 := p5_a19;
    ddp_credit_rule_attr_rec.attribute12 := p5_a20;
    ddp_credit_rule_attr_rec.attribute13 := p5_a21;
    ddp_credit_rule_attr_rec.attribute14 := p5_a22;
    ddp_credit_rule_attr_rec.attribute15 := p5_a23;
    ddp_credit_rule_attr_rec.object_version_number := p5_a24;




    -- here's the delegated call to the old PL/SQL routine
    cn_sca_crruleattr_pvt.create_credit_ruleattr(p_api_version,
      p_init_msg_list,
      p_commit,
      p_valdiation_level,
      p_org_id,
      ddp_credit_rule_attr_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

  procedure update_credit_ruleattr(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_valdiation_level  VARCHAR2
    , p_org_id  NUMBER
    , p5_a0  NUMBER
    , p5_a1  VARCHAR2
    , p5_a2  VARCHAR2
    , p5_a3  VARCHAR2
    , p5_a4  NUMBER
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
    , p5_a18  VARCHAR2
    , p5_a19  VARCHAR2
    , p5_a20  VARCHAR2
    , p5_a21  VARCHAR2
    , p5_a22  VARCHAR2
    , p5_a23  VARCHAR2
    , p5_a24  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_credit_rule_attr_rec cn_sca_crruleattr_pvt.credit_rule_attr_rec;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_credit_rule_attr_rec.sca_rule_attribute_id := p5_a0;
    ddp_credit_rule_attr_rec.transaction_source := p5_a1;
    ddp_credit_rule_attr_rec.destination_column := p5_a2;
    ddp_credit_rule_attr_rec.user_name := p5_a3;
    ddp_credit_rule_attr_rec.value_set_id := p5_a4;
    ddp_credit_rule_attr_rec.data_type := p5_a5;
    ddp_credit_rule_attr_rec.source_column := p5_a6;
    ddp_credit_rule_attr_rec.enable_flag := p5_a7;
    ddp_credit_rule_attr_rec.attribute_category := p5_a8;
    ddp_credit_rule_attr_rec.attribute1 := p5_a9;
    ddp_credit_rule_attr_rec.attribute2 := p5_a10;
    ddp_credit_rule_attr_rec.attribute3 := p5_a11;
    ddp_credit_rule_attr_rec.attribute4 := p5_a12;
    ddp_credit_rule_attr_rec.attribute5 := p5_a13;
    ddp_credit_rule_attr_rec.attribute6 := p5_a14;
    ddp_credit_rule_attr_rec.attribute7 := p5_a15;
    ddp_credit_rule_attr_rec.attribute8 := p5_a16;
    ddp_credit_rule_attr_rec.attribute9 := p5_a17;
    ddp_credit_rule_attr_rec.attribute10 := p5_a18;
    ddp_credit_rule_attr_rec.attribute11 := p5_a19;
    ddp_credit_rule_attr_rec.attribute12 := p5_a20;
    ddp_credit_rule_attr_rec.attribute13 := p5_a21;
    ddp_credit_rule_attr_rec.attribute14 := p5_a22;
    ddp_credit_rule_attr_rec.attribute15 := p5_a23;
    ddp_credit_rule_attr_rec.object_version_number := p5_a24;




    -- here's the delegated call to the old PL/SQL routine
    cn_sca_crruleattr_pvt.update_credit_ruleattr(p_api_version,
      p_init_msg_list,
      p_commit,
      p_valdiation_level,
      p_org_id,
      ddp_credit_rule_attr_rec,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

end cn_sca_crruleattr_pvt_w;

/
