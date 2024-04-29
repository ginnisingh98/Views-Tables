--------------------------------------------------------
--  DDL for Package Body JTF_LOGICALCONTENT_GRP_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_LOGICALCONTENT_GRP_W" as
  /* $Header: JTFGRLTB.pls 115.6 2004/07/09 18:50:44 applrt ship $ */
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

  procedure rosetta_table_copy_in_p3(t out jtf_logicalcontent_grp.obj_lgl_ctnt_tbl_type, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_NUMBER_TABLE
    , a5 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).obj_lgl_ctnt_delete := a0(indx);
          t(ddindx).obj_lgl_ctnt_id := a1(indx);
          t(ddindx).object_version_number := a2(indx);
          t(ddindx).object_id := a3(indx);
          t(ddindx).context_id := a4(indx);
          t(ddindx).deliverable_id := a5(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p3;
  procedure rosetta_table_copy_out_p3(t jtf_logicalcontent_grp.obj_lgl_ctnt_tbl_type, a0 out JTF_VARCHAR2_TABLE_100
    , a1 out JTF_NUMBER_TABLE
    , a2 out JTF_NUMBER_TABLE
    , a3 out JTF_NUMBER_TABLE
    , a4 out JTF_NUMBER_TABLE
    , a5 out JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_100();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_NUMBER_TABLE();
    a5 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_VARCHAR2_TABLE_100();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_NUMBER_TABLE();
      a5 := JTF_NUMBER_TABLE();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        a3.extend(t.count);
        a4.extend(t.count);
        a5.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).obj_lgl_ctnt_delete;
          a1(indx) := t(ddindx).obj_lgl_ctnt_id;
          a2(indx) := t(ddindx).object_version_number;
          a3(indx) := t(ddindx).object_id;
          a4(indx) := t(ddindx).context_id;
          a5(indx) := t(ddindx).deliverable_id;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p3;

  procedure save_delete_lgl_ctnt(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , x_return_status out  VARCHAR2
    , x_msg_count out  NUMBER
    , x_msg_data out  VARCHAR2
    , p_object_type_code  VARCHAR2
    , p7_a0 JTF_VARCHAR2_TABLE_100
    , p7_a1 JTF_NUMBER_TABLE
    , p7_a2 JTF_NUMBER_TABLE
    , p7_a3 JTF_NUMBER_TABLE
    , p7_a4 JTF_NUMBER_TABLE
    , p7_a5 JTF_NUMBER_TABLE
  )
  as
    ddp_lgl_ctnt_tbl jtf_logicalcontent_grp.obj_lgl_ctnt_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    jtf_logicalcontent_grp_w.rosetta_table_copy_in_p3(ddp_lgl_ctnt_tbl, p7_a0
      , p7_a1
      , p7_a2
      , p7_a3
      , p7_a4
      , p7_a5
      );

    -- here's the delegated call to the old PL/SQL routine
    jtf_logicalcontent_grp.save_delete_lgl_ctnt(p_api_version,
      p_init_msg_list,
      p_commit,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_object_type_code,
      ddp_lgl_ctnt_tbl);

    -- copy data back from the local OUT or IN-OUT args, if any







  end;

end jtf_logicalcontent_grp_w;

/
