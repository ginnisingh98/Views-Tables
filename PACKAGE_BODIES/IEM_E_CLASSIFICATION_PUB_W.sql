--------------------------------------------------------
--  DDL for Package Body IEM_E_CLASSIFICATION_PUB_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEM_E_CLASSIFICATION_PUB_W" as
  /* $Header: IEMVCLSB.pls 115.1 2000/02/18 14:48:45 pkm ship     $ */
  /*
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

  procedure rosetta_table_copy_in_p2(t out iem_e_classification_pub.emclass_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).classification_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).classification := a1(indx);
          t(ddindx).score := a2(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p2;
  procedure rosetta_table_copy_out_p2(t iem_e_classification_pub.emclass_tbl_type, a0 out JTF_NUMBER_TABLE
    , a1 out JTF_VARCHAR2_TABLE_100
    , a2 out JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_VARCHAR2_TABLE_100();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).classification_id);
          a1(indx) := t(ddindx).classification;
          a2(indx) := t(ddindx).score;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p2;

  procedure getclassification(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_email_account_id  NUMBER
    , p_message_id  NUMBER
    , p5_a0 out JTF_NUMBER_TABLE
    , p5_a1 out JTF_VARCHAR2_TABLE_100
    , p5_a2 out JTF_VARCHAR2_TABLE_100
  )
  as
    ddx_email_classn_tbl iem_e_classification_pub.emclass_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any






    -- here's the delegated call to the old PL/SQL routine
    iem_e_classification_pub.getclassification(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_email_account_id,
      p_message_id,
      ddx_email_classn_tbl);

    -- copy data back from the local OUT or IN-OUT args, if any





    iem_e_classification_pub_w.rosetta_table_copy_out_p2(ddx_email_classn_tbl, p5_a0
      , p5_a1
      , p5_a2
      );
  end;
*/
end iem_e_classification_pub_w;

/
