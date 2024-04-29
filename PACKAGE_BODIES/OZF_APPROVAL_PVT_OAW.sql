--------------------------------------------------------
--  DDL for Package Body OZF_APPROVAL_PVT_OAW
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_APPROVAL_PVT_OAW" as
  /* $Header: ozfaappb.pls 115.1 2003/12/10 16:03:42 feliu noship $ */
  procedure rosetta_table_copy_in_p1(t out nocopy ozf_approval_pvt.action_tbl_type, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count=0 then
    t := ozf_approval_pvt.action_tbl_type();
  elsif a0 is not null and a0.count > 0 then
      if a0.count > 0 then
      t := ozf_approval_pvt.action_tbl_type();
      t.extend(a0.count);
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).object_type := a0(indx);
          t(ddindx).object_id := a1(indx);
          t(ddindx).status_code := a2(indx);
          t(ddindx).action_code := a3(indx);
          t(ddindx).action_performed_by := a4(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p1;
  procedure rosetta_table_copy_out_p1(t ozf_approval_pvt.action_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_100
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null then
    a0 := null;
    a1 := null;
    a2 := null;
    a3 := null;
    a4 := null;
  elsif t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_100();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_VARCHAR2_TABLE_100();
    a4 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_VARCHAR2_TABLE_100();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_VARCHAR2_TABLE_100();
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
          a0(indx) := t(ddindx).object_type;
          a1(indx) := t(ddindx).object_id;
          a2(indx) := t(ddindx).status_code;
          a3(indx) := t(ddindx).action_code;
          a4(indx) := t(ddindx).action_performed_by;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p1;

  procedure rosetta_table_copy_in_p3(t out nocopy ozf_approval_pvt.approvers_tbl_type, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count=0 then
    t := ozf_approval_pvt.approvers_tbl_type();
  elsif a0 is not null and a0.count > 0 then
      if a0.count > 0 then
      t := ozf_approval_pvt.approvers_tbl_type();
      t.extend(a0.count);
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).approver_type := a0(indx);
          t(ddindx).approver_id := a1(indx);
          t(ddindx).approver_level := a2(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p3;
  procedure rosetta_table_copy_out_p3(t ozf_approval_pvt.approvers_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_100
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null then
    a0 := null;
    a1 := null;
    a2 := null;
  elsif t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_100();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_VARCHAR2_TABLE_100();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).approver_type;
          a1(indx) := t(ddindx).approver_id;
          a2(indx) := t(ddindx).approver_level;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p3;

  procedure update_user_action(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_data out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , p6_a0  VARCHAR2
    , p6_a1  NUMBER
    , p6_a2  VARCHAR2
    , p6_a3  VARCHAR2
    , p6_a4  NUMBER
  )

  as
    ddp_approval_rec ozf_approval_pvt.approval_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any






    ddp_approval_rec.object_type := p6_a0;
    ddp_approval_rec.object_id := p6_a1;
    ddp_approval_rec.status_code := p6_a2;
    ddp_approval_rec.action_code := p6_a3;
    ddp_approval_rec.action_performed_by := p6_a4;

    -- here's the delegated call to the old PL/SQL routine
    ozf_approval_pvt.update_user_action(p_api_version,
      p_init_msg_list,
      p_validation_level,
      x_return_status,
      x_msg_data,
      x_msg_count,
      ddp_approval_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






  end;

  procedure get_approvers(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_data out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , p6_a0  VARCHAR2
    , p6_a1  NUMBER
    , p6_a2  VARCHAR2
    , p6_a3  VARCHAR2
    , p6_a4  NUMBER
    , p7_a0 out nocopy JTF_VARCHAR2_TABLE_100
    , p7_a1 out nocopy JTF_NUMBER_TABLE
    , p7_a2 out nocopy JTF_NUMBER_TABLE
    , x_final_approval_flag out nocopy  VARCHAR2
  )

  as
    ddp_approval_rec ozf_approval_pvt.approval_rec_type;
    ddx_approvers ozf_approval_pvt.approvers_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any






    ddp_approval_rec.object_type := p6_a0;
    ddp_approval_rec.object_id := p6_a1;
    ddp_approval_rec.status_code := p6_a2;
    ddp_approval_rec.action_code := p6_a3;
    ddp_approval_rec.action_performed_by := p6_a4;



    -- here's the delegated call to the old PL/SQL routine
    ozf_approval_pvt.get_approvers(p_api_version,
      p_init_msg_list,
      p_validation_level,
      x_return_status,
      x_msg_data,
      x_msg_count,
      ddp_approval_rec,
      ddx_approvers,
      x_final_approval_flag);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







    ozf_approval_pvt_oaw.rosetta_table_copy_out_p3(ddx_approvers, p7_a0
      , p7_a1
      , p7_a2
      );

  end;

  procedure add_access(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , p7_a0  VARCHAR2
    , p7_a1  NUMBER
    , p7_a2  VARCHAR2
    , p7_a3  VARCHAR2
    , p7_a4  NUMBER
    , p8_a0 JTF_VARCHAR2_TABLE_100
    , p8_a1 JTF_NUMBER_TABLE
    , p8_a2 JTF_NUMBER_TABLE
  )

  as
    ddp_approval_rec ozf_approval_pvt.approval_rec_type;
    ddp_approvers ozf_approval_pvt.approvers_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_approval_rec.object_type := p7_a0;
    ddp_approval_rec.object_id := p7_a1;
    ddp_approval_rec.status_code := p7_a2;
    ddp_approval_rec.action_code := p7_a3;
    ddp_approval_rec.action_performed_by := p7_a4;

    ozf_approval_pvt_oaw.rosetta_table_copy_in_p3(ddp_approvers, p8_a0
      , p8_a1
      , p8_a2
      );

    -- here's the delegated call to the old PL/SQL routine
    ozf_approval_pvt.add_access(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_msg_data,
      x_msg_count,
      x_return_status,
      ddp_approval_rec,
      ddp_approvers);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

  procedure raise_event(x_return_status out nocopy  VARCHAR2
    , x_msg_data out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , p_event_name  VARCHAR2
    , p_event_key  VARCHAR2
    , p5_a0  VARCHAR2
    , p5_a1  NUMBER
    , p5_a2  VARCHAR2
    , p5_a3  VARCHAR2
    , p5_a4  NUMBER
  )

  as
    ddp_approval_rec ozf_approval_pvt.approval_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_approval_rec.object_type := p5_a0;
    ddp_approval_rec.object_id := p5_a1;
    ddp_approval_rec.status_code := p5_a2;
    ddp_approval_rec.action_code := p5_a3;
    ddp_approval_rec.action_performed_by := p5_a4;

    -- here's the delegated call to the old PL/SQL routine
    ozf_approval_pvt.raise_event(x_return_status,
      x_msg_data,
      x_msg_count,
      p_event_name,
      p_event_key,
      ddp_approval_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





  end;

  procedure send_notification(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_data out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , p_benefit_id  NUMBER
    , p_partner_id  NUMBER
    , p_msg_callback_api  VARCHAR2
    , p_user_callback_api  VARCHAR2
    , p11_a0  VARCHAR2
    , p11_a1  NUMBER
    , p11_a2  VARCHAR2
    , p11_a3  VARCHAR2
    , p11_a4  NUMBER
  )

  as
    ddp_approval_rec ozf_approval_pvt.approval_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any











    ddp_approval_rec.object_type := p11_a0;
    ddp_approval_rec.object_id := p11_a1;
    ddp_approval_rec.status_code := p11_a2;
    ddp_approval_rec.action_code := p11_a3;
    ddp_approval_rec.action_performed_by := p11_a4;

    -- here's the delegated call to the old PL/SQL routine
    ozf_approval_pvt.send_notification(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_data,
      x_msg_count,
      p_benefit_id,
      p_partner_id,
      p_msg_callback_api,
      p_user_callback_api,
      ddp_approval_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any











  end;

  procedure process_user_action(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_data out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , p7_a0  VARCHAR2
    , p7_a1  NUMBER
    , p7_a2  VARCHAR2
    , p7_a3  VARCHAR2
    , p7_a4  NUMBER
    , p_approver_id  NUMBER
    , x_final_approval_flag out nocopy  VARCHAR2
  )

  as
    ddp_approval_rec ozf_approval_pvt.approval_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_approval_rec.object_type := p7_a0;
    ddp_approval_rec.object_id := p7_a1;
    ddp_approval_rec.status_code := p7_a2;
    ddp_approval_rec.action_code := p7_a3;
    ddp_approval_rec.action_performed_by := p7_a4;



    -- here's the delegated call to the old PL/SQL routine
    ozf_approval_pvt.process_user_action(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_data,
      x_msg_count,
      ddp_approval_rec,
      p_approver_id,
      x_final_approval_flag);

    -- copy data back from the local variables to OUT or IN-OUT args, if any









  end;

end ozf_approval_pvt_oaw;

/
