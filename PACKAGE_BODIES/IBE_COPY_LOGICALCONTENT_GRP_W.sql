--------------------------------------------------------
--  DDL for Package Body IBE_COPY_LOGICALCONTENT_GRP_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBE_COPY_LOGICALCONTENT_GRP_W" as
  /* $Header: IBEGRCTB.pls 120.0.12010000.1 2009/12/16 05:24:47 pgoutia noship $ */
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

  procedure rosetta_table_copy_in_p2(t out nocopy ibe_copy_logicalcontent_grp.ids_list, a0 JTF_NUMBER_TABLE) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is null then
    t := null;
  elsif a0.count = 0 then
    t := ibe_copy_logicalcontent_grp.ids_list();
  else
      if a0.count > 0 then
      t := ibe_copy_logicalcontent_grp.ids_list();
      t.extend(a0.count);
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx) := rosetta_g_miss_num_map(a0(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p2;
  procedure rosetta_table_copy_out_p2(t ibe_copy_logicalcontent_grp.ids_list, a0 out nocopy JTF_NUMBER_TABLE) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null then
    a0 := null;
  elsif t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      if t.count > 0 then
        a0.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx));
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p2;

  procedure copy_lgl_ctnt(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_object_type_code  VARCHAR2
    , p_from_product_id  NUMBER
    , p_from_context_ids JTF_NUMBER_TABLE
    , p_to_product_ids JTF_NUMBER_TABLE
    , x_copy_status out nocopy JTF_NUMBER_TABLE
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_from_context_ids ibe_copy_logicalcontent_grp.ids_list;
    ddp_to_product_ids ibe_copy_logicalcontent_grp.ids_list;
    ddx_copy_status ibe_copy_logicalcontent_grp.ids_list;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ibe_copy_logicalcontent_grp_w.rosetta_table_copy_in_p2(ddp_from_context_ids, p_from_context_ids);

    ibe_copy_logicalcontent_grp_w.rosetta_table_copy_in_p2(ddp_to_product_ids, p_to_product_ids);





    -- here's the delegated call to the old PL/SQL routine
    ibe_copy_logicalcontent_grp.copy_lgl_ctnt(p_api_version,
      p_init_msg_list,
      p_commit,
      p_object_type_code,
      p_from_product_id,
      ddp_from_context_ids,
      ddp_to_product_ids,
      ddx_copy_status,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







    ibe_copy_logicalcontent_grp_w.rosetta_table_copy_out_p2(ddx_copy_status, x_copy_status);



  end;

  procedure copy_lgl_ctnt(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_object_type_code  VARCHAR2
    , p_from_product_id  NUMBER
    , p_from_context_ids JTF_NUMBER_TABLE
    , p_from_deliverable_ids JTF_NUMBER_TABLE
    , p_to_product_ids JTF_NUMBER_TABLE
    , x_copy_status out nocopy JTF_NUMBER_TABLE
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_from_context_ids ibe_copy_logicalcontent_grp.ids_list;
    ddp_from_deliverable_ids ibe_copy_logicalcontent_grp.ids_list;
    ddp_to_product_ids ibe_copy_logicalcontent_grp.ids_list;
    ddx_copy_status ibe_copy_logicalcontent_grp.ids_list;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ibe_copy_logicalcontent_grp_w.rosetta_table_copy_in_p2(ddp_from_context_ids, p_from_context_ids);

    ibe_copy_logicalcontent_grp_w.rosetta_table_copy_in_p2(ddp_from_deliverable_ids, p_from_deliverable_ids);

    ibe_copy_logicalcontent_grp_w.rosetta_table_copy_in_p2(ddp_to_product_ids, p_to_product_ids);





    -- here's the delegated call to the old PL/SQL routine
    ibe_copy_logicalcontent_grp.copy_lgl_ctnt(p_api_version,
      p_init_msg_list,
      p_commit,
      p_object_type_code,
      p_from_product_id,
      ddp_from_context_ids,
      ddp_from_deliverable_ids,
      ddp_to_product_ids,
      ddx_copy_status,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








    ibe_copy_logicalcontent_grp_w.rosetta_table_copy_out_p2(ddx_copy_status, x_copy_status);



  end;

end ibe_copy_logicalcontent_grp_w;

/
