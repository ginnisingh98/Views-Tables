--------------------------------------------------------
--  DDL for Package Body IEM_TAGPROCESS_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEM_TAGPROCESS_PUB_W" as
  /* $Header: IEMPTGWB.pls 115.2 2002/12/12 22:54:44 txliu noship $ */
  rosetta_g_mistake_date date := to_date('01/01/+4713', 'MM/DD/SYYYY');
  rosetta_g_miss_date date := to_date('01/01/-4712', 'MM/DD/SYYYY');

  -- this is to workaround the JDBC bug regarding IN DATE of value GMiss
  function rosetta_g_miss_date_in_map(d date) return date as
  begin
    if d = rosetta_g_mistake_date then return fnd_api.g_miss_date; end if;
    return d;
  end;

  procedure rosetta_table_copy_in_p2(t out nocopy iem_tagprocess_pub.keyvals_tbl_type, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_VARCHAR2_TABLE_300
    , a2 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).key := a0(indx);
          t(ddindx).value := a1(indx);
          t(ddindx).datatype := a2(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p2;
  procedure rosetta_table_copy_out_p2(t iem_tagprocess_pub.keyvals_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_100
    , a1 out nocopy JTF_VARCHAR2_TABLE_300
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_100();
    a1 := JTF_VARCHAR2_TABLE_300();
    a2 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_VARCHAR2_TABLE_100();
      a1 := JTF_VARCHAR2_TABLE_300();
      a2 := JTF_VARCHAR2_TABLE_100();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).key;
          a1(indx) := t(ddindx).value;
          a2(indx) := t(ddindx).datatype;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p2;

  procedure getencryptid(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_email_account_id  NUMBER
    , p_agent_id  NUMBER
    , p_interaction_id  NUMBER
    , p6_a0 JTF_VARCHAR2_TABLE_100
    , p6_a1 JTF_VARCHAR2_TABLE_300
    , p6_a2 JTF_VARCHAR2_TABLE_100
    , x_encrypted_id out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_biz_keyval_tab iem_tagprocess_pub.keyvals_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any






    iem_tagprocess_pub_w.rosetta_table_copy_in_p2(ddp_biz_keyval_tab, p6_a0
      , p6_a1
      , p6_a2
      );





    -- here's the delegated call to the old PL/SQL routine
    iem_tagprocess_pub.getencryptid(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_email_account_id,
      p_agent_id,
      p_interaction_id,
      ddp_biz_keyval_tab,
      x_encrypted_id,
      x_msg_count,
      x_return_status,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any










  end;

  procedure gettagvalues(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_encrypted_id  VARCHAR2
    , p_message_id  NUMBER
    , p5_a0 out nocopy JTF_VARCHAR2_TABLE_100
    , p5_a1 out nocopy JTF_VARCHAR2_TABLE_300
    , p5_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , x_msg_count out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddx_key_value iem_tagprocess_pub.keyvals_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any









    -- here's the delegated call to the old PL/SQL routine
    iem_tagprocess_pub.gettagvalues(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_encrypted_id,
      p_message_id,
      ddx_key_value,
      x_msg_count,
      x_return_status,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





    iem_tagprocess_pub_w.rosetta_table_copy_out_p2(ddx_key_value, p5_a0
      , p5_a1
      , p5_a2
      );



  end;

  procedure gettagvalues_on_msgid(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_message_id  NUMBER
    , p4_a0 out nocopy JTF_VARCHAR2_TABLE_100
    , p4_a1 out nocopy JTF_VARCHAR2_TABLE_300
    , p4_a2 out nocopy JTF_VARCHAR2_TABLE_100
    , x_encrypted_id out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddx_key_value iem_tagprocess_pub.keyvals_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any









    -- here's the delegated call to the old PL/SQL routine
    iem_tagprocess_pub.gettagvalues_on_msgid(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_message_id,
      ddx_key_value,
      x_encrypted_id,
      x_msg_count,
      x_return_status,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any




    iem_tagprocess_pub_w.rosetta_table_copy_out_p2(ddx_key_value, p4_a0
      , p4_a1
      , p4_a2
      );




  end;

  procedure isvalidagent(p_agent_id  NUMBER
    , p_email_acct_id  NUMBER
    , ddrosetta_retval_bool OUT NOCOPY NUMBER
  )

  as
    ddindx binary_integer; indx binary_integer;
    ddrosetta_retval boolean;
  begin

    -- copy data to the local IN or IN-OUT args, if any


    -- here's the delegated call to the old PL/SQL routine
    ddrosetta_retval := iem_tagprocess_pub.isvalidagent(p_agent_id,
      p_email_acct_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any
    if ddrosetta_retval is null
      then ddrosetta_retval_bool := null;
    elsif ddrosetta_retval
      then ddrosetta_retval_bool := 1;
    else ddrosetta_retval_bool := 0;
    end if;

  end;

end iem_tagprocess_pub_w;

/
