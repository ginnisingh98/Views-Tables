--------------------------------------------------------
--  DDL for Package Body LNS_COND_ASSIGNMENT_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."LNS_COND_ASSIGNMENT_PUB_W" as
  /* $Header: LNS_CASGM_PUBJ_B.pls 120.2.12010000.2 2010/03/19 08:32:07 gparuchu ship $ */
  procedure rosetta_table_copy_in_p1(t out nocopy lns_cond_assignment_pub.cond_assignment_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_VARCHAR2_TABLE_300
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_DATE_TABLE
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_NUMBER_TABLE
    , a9 JTF_DATE_TABLE
    , a10 JTF_NUMBER_TABLE
    , a11 JTF_DATE_TABLE
    , a12 JTF_NUMBER_TABLE
    , a13 JTF_NUMBER_TABLE
    , a14 JTF_NUMBER_TABLE
    , a15 JTF_VARCHAR2_TABLE_100
    , a16 JTF_NUMBER_TABLE
    , a17 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).cond_assignment_id := a0(indx);
          t(ddindx).loan_id := a1(indx);
          t(ddindx).condition_id := a2(indx);
          t(ddindx).condition_description := a3(indx);
          t(ddindx).condition_met_flag := a4(indx);
          t(ddindx).fulfillment_date := a5(indx);
          t(ddindx).fulfillment_updated_by := a6(indx);
          t(ddindx).mandatory_flag := a7(indx);
          t(ddindx).created_by := a8(indx);
          t(ddindx).creation_date := a9(indx);
          t(ddindx).last_updated_by := a10(indx);
          t(ddindx).last_update_date := a11(indx);
          t(ddindx).last_update_login := a12(indx);
          t(ddindx).object_version_number := a13(indx);
          t(ddindx).disb_header_id := a14(indx);
          t(ddindx).delete_disabled_flag := a15(indx);
          t(ddindx).owner_object_id := a16(indx);
          t(ddindx).owner_table := a17(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p1;
  procedure rosetta_table_copy_out_p1(t lns_cond_assignment_pub.cond_assignment_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_VARCHAR2_TABLE_300
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_DATE_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    , a8 out nocopy JTF_NUMBER_TABLE
    , a9 out nocopy JTF_DATE_TABLE
    , a10 out nocopy JTF_NUMBER_TABLE
    , a11 out nocopy JTF_DATE_TABLE
    , a12 out nocopy JTF_NUMBER_TABLE
    , a13 out nocopy JTF_NUMBER_TABLE
    , a14 out nocopy JTF_NUMBER_TABLE
    , a15 out nocopy JTF_VARCHAR2_TABLE_100
    , a16 out nocopy JTF_NUMBER_TABLE
    , a17 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_VARCHAR2_TABLE_300();
    a4 := JTF_VARCHAR2_TABLE_100();
    a5 := JTF_DATE_TABLE();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_VARCHAR2_TABLE_100();
    a8 := JTF_NUMBER_TABLE();
    a9 := JTF_DATE_TABLE();
    a10 := JTF_NUMBER_TABLE();
    a11 := JTF_DATE_TABLE();
    a12 := JTF_NUMBER_TABLE();
    a13 := JTF_NUMBER_TABLE();
    a14 := JTF_NUMBER_TABLE();
    a15 := JTF_VARCHAR2_TABLE_100();
    a16 := JTF_NUMBER_TABLE();
    a17 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_VARCHAR2_TABLE_300();
      a4 := JTF_VARCHAR2_TABLE_100();
      a5 := JTF_DATE_TABLE();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_VARCHAR2_TABLE_100();
      a8 := JTF_NUMBER_TABLE();
      a9 := JTF_DATE_TABLE();
      a10 := JTF_NUMBER_TABLE();
      a11 := JTF_DATE_TABLE();
      a12 := JTF_NUMBER_TABLE();
      a13 := JTF_NUMBER_TABLE();
      a14 := JTF_NUMBER_TABLE();
      a15 := JTF_VARCHAR2_TABLE_100();
      a16 := JTF_NUMBER_TABLE();
      a17 := JTF_VARCHAR2_TABLE_100();
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
          a0(indx) := t(ddindx).cond_assignment_id;
          a1(indx) := t(ddindx).loan_id;
          a2(indx) := t(ddindx).condition_id;
          a3(indx) := t(ddindx).condition_description;
          a4(indx) := t(ddindx).condition_met_flag;
          a5(indx) := t(ddindx).fulfillment_date;
          a6(indx) := t(ddindx).fulfillment_updated_by;
          a7(indx) := t(ddindx).mandatory_flag;
          a8(indx) := t(ddindx).created_by;
          a9(indx) := t(ddindx).creation_date;
          a10(indx) := t(ddindx).last_updated_by;
          a11(indx) := t(ddindx).last_update_date;
          a12(indx) := t(ddindx).last_update_login;
          a13(indx) := t(ddindx).object_version_number;
          a14(indx) := t(ddindx).disb_header_id;
          a15(indx) := t(ddindx).delete_disabled_flag;
          a16(indx) := t(ddindx).owner_object_id;
          a17(indx) := t(ddindx).owner_table;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p1;

  procedure create_cond_assignment(p_init_msg_list  VARCHAR2
    , p1_a0  NUMBER
    , p1_a1  NUMBER
    , p1_a2  NUMBER
    , p1_a3  VARCHAR2
    , p1_a4  VARCHAR2
    , p1_a5  DATE
    , p1_a6  NUMBER
    , p1_a7  VARCHAR2
    , p1_a8  NUMBER
    , p1_a9  DATE
    , p1_a10  NUMBER
    , p1_a11  DATE
    , p1_a12  NUMBER
    , p1_a13  NUMBER
    , p1_a14  NUMBER
    , p1_a15  VARCHAR2
    , p1_a16  NUMBER
    , p1_a17  VARCHAR2
    , x_cond_assignment_id out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_cond_assignment_rec lns_cond_assignment_pub.cond_assignment_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    ddp_cond_assignment_rec.cond_assignment_id := p1_a0;
    ddp_cond_assignment_rec.loan_id := p1_a1;
    ddp_cond_assignment_rec.condition_id := p1_a2;
    ddp_cond_assignment_rec.condition_description := p1_a3;
    ddp_cond_assignment_rec.condition_met_flag := p1_a4;
    ddp_cond_assignment_rec.fulfillment_date := p1_a5;
    ddp_cond_assignment_rec.fulfillment_updated_by := p1_a6;
    ddp_cond_assignment_rec.mandatory_flag := p1_a7;
    ddp_cond_assignment_rec.created_by := p1_a8;
    ddp_cond_assignment_rec.creation_date := p1_a9;
    ddp_cond_assignment_rec.last_updated_by := p1_a10;
    ddp_cond_assignment_rec.last_update_date := p1_a11;
    ddp_cond_assignment_rec.last_update_login := p1_a12;
    ddp_cond_assignment_rec.object_version_number := p1_a13;
    ddp_cond_assignment_rec.disb_header_id := p1_a14;
    ddp_cond_assignment_rec.delete_disabled_flag := p1_a15;
    ddp_cond_assignment_rec.owner_object_id := p1_a16;
    ddp_cond_assignment_rec.owner_table := p1_a17;





    -- here's the delegated call to the old PL/SQL routine
    lns_cond_assignment_pub.create_cond_assignment(p_init_msg_list,
      ddp_cond_assignment_rec,
      x_cond_assignment_id,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure update_cond_assignment(p_init_msg_list  VARCHAR2
    , p1_a0  NUMBER
    , p1_a1  NUMBER
    , p1_a2  NUMBER
    , p1_a3  VARCHAR2
    , p1_a4  VARCHAR2
    , p1_a5  DATE
    , p1_a6  NUMBER
    , p1_a7  VARCHAR2
    , p1_a8  NUMBER
    , p1_a9  DATE
    , p1_a10  NUMBER
    , p1_a11  DATE
    , p1_a12  NUMBER
    , p1_a13  NUMBER
    , p1_a14  NUMBER
    , p1_a15  VARCHAR2
    , p1_a16  NUMBER
    , p1_a17  VARCHAR2
    , p_object_version_number in out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_cond_assignment_rec lns_cond_assignment_pub.cond_assignment_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    ddp_cond_assignment_rec.cond_assignment_id := p1_a0;
    ddp_cond_assignment_rec.loan_id := p1_a1;
    ddp_cond_assignment_rec.condition_id := p1_a2;
    ddp_cond_assignment_rec.condition_description := p1_a3;
    ddp_cond_assignment_rec.condition_met_flag := p1_a4;
    ddp_cond_assignment_rec.fulfillment_date := p1_a5;
    ddp_cond_assignment_rec.fulfillment_updated_by := p1_a6;
    ddp_cond_assignment_rec.mandatory_flag := p1_a7;
    ddp_cond_assignment_rec.created_by := p1_a8;
    ddp_cond_assignment_rec.creation_date := p1_a9;
    ddp_cond_assignment_rec.last_updated_by := p1_a10;
    ddp_cond_assignment_rec.last_update_date := p1_a11;
    ddp_cond_assignment_rec.last_update_login := p1_a12;
    ddp_cond_assignment_rec.object_version_number := p1_a13;
    ddp_cond_assignment_rec.disb_header_id := p1_a14;
    ddp_cond_assignment_rec.delete_disabled_flag := p1_a15;
    ddp_cond_assignment_rec.owner_object_id := p1_a16;
    ddp_cond_assignment_rec.owner_table := p1_a17;





    -- here's the delegated call to the old PL/SQL routine
    lns_cond_assignment_pub.update_cond_assignment(p_init_msg_list,
      ddp_cond_assignment_rec,
      p_object_version_number,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

end lns_cond_assignment_pub_w;

/
