--------------------------------------------------------
--  DDL for Package Body IBE_DISPLAYCONTEXT_GRP_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBE_DISPLAYCONTEXT_GRP_W" as
  /* $Header: IBEGRCXB.pls 115.4 2002/12/18 07:07:38 schak ship $ */
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

  procedure rosetta_table_copy_in_p3(t out nocopy ibe_displaycontext_grp.display_context_tbl_type, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_VARCHAR2_TABLE_300
    , a6 JTF_VARCHAR2_TABLE_100
    , a7 JTF_VARCHAR2_TABLE_100
    , a8 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).context_delete := a0(indx);
          t(ddindx).object_version_number := rosetta_g_miss_num_map(a1(indx));
          t(ddindx).context_id := rosetta_g_miss_num_map(a2(indx));
          t(ddindx).access_name := a3(indx);
          t(ddindx).display_name := a4(indx);
          t(ddindx).description := a5(indx);
          t(ddindx).context_type := a6(indx);
          t(ddindx).component_type_code := a7(indx);
          t(ddindx).default_deliverable_id := rosetta_g_miss_num_map(a8(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p3;
  procedure rosetta_table_copy_out_p3(t ibe_displaycontext_grp.display_context_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_100
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_VARCHAR2_TABLE_300
    , a6 out nocopy JTF_VARCHAR2_TABLE_100
    , a7 out nocopy JTF_VARCHAR2_TABLE_100
    , a8 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_100();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_VARCHAR2_TABLE_100();
    a4 := JTF_VARCHAR2_TABLE_100();
    a5 := JTF_VARCHAR2_TABLE_300();
    a6 := JTF_VARCHAR2_TABLE_100();
    a7 := JTF_VARCHAR2_TABLE_100();
    a8 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_VARCHAR2_TABLE_100();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_VARCHAR2_TABLE_100();
      a5 := JTF_VARCHAR2_TABLE_300();
      a6 := JTF_VARCHAR2_TABLE_100();
      a7 := JTF_VARCHAR2_TABLE_100();
      a8 := JTF_NUMBER_TABLE();
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
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).context_delete;
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).object_version_number);
          a2(indx) := rosetta_g_miss_num_map(t(ddindx).context_id);
          a3(indx) := t(ddindx).access_name;
          a4(indx) := t(ddindx).display_name;
          a5(indx) := t(ddindx).description;
          a6(indx) := t(ddindx).context_type;
          a7(indx) := t(ddindx).component_type_code;
          a8(indx) := rosetta_g_miss_num_map(t(ddindx).default_deliverable_id);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p3;

  procedure save_display_context(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 in out nocopy  VARCHAR2
    , p6_a1 in out nocopy  NUMBER
    , p6_a2 in out nocopy  NUMBER
    , p6_a3 in out nocopy  VARCHAR2
    , p6_a4 in out nocopy  VARCHAR2
    , p6_a5 in out nocopy  VARCHAR2
    , p6_a6 in out nocopy  VARCHAR2
    , p6_a7 in out nocopy  VARCHAR2
    , p6_a8 in out nocopy  NUMBER
  )

  as
    ddp_display_context_rec ibe_displaycontext_grp.display_context_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any






    ddp_display_context_rec.context_delete := p6_a0;
    ddp_display_context_rec.object_version_number := rosetta_g_miss_num_map(p6_a1);
    ddp_display_context_rec.context_id := rosetta_g_miss_num_map(p6_a2);
    ddp_display_context_rec.access_name := p6_a3;
    ddp_display_context_rec.display_name := p6_a4;
    ddp_display_context_rec.description := p6_a5;
    ddp_display_context_rec.context_type := p6_a6;
    ddp_display_context_rec.component_type_code := p6_a7;
    ddp_display_context_rec.default_deliverable_id := rosetta_g_miss_num_map(p6_a8);

    -- here's the delegated call to the old PL/SQL routine
    ibe_displaycontext_grp.save_display_context(p_api_version,
      p_init_msg_list,
      p_commit,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_display_context_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := ddp_display_context_rec.context_delete;
    p6_a1 := rosetta_g_miss_num_map(ddp_display_context_rec.object_version_number);
    p6_a2 := rosetta_g_miss_num_map(ddp_display_context_rec.context_id);
    p6_a3 := ddp_display_context_rec.access_name;
    p6_a4 := ddp_display_context_rec.display_name;
    p6_a5 := ddp_display_context_rec.description;
    p6_a6 := ddp_display_context_rec.context_type;
    p6_a7 := ddp_display_context_rec.component_type_code;
    p6_a8 := rosetta_g_miss_num_map(ddp_display_context_rec.default_deliverable_id);
  end;

  procedure save_delete_display_context(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 in out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a1 in out nocopy JTF_NUMBER_TABLE
    , p6_a2 in out nocopy JTF_NUMBER_TABLE
    , p6_a3 in out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a4 in out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a5 in out nocopy JTF_VARCHAR2_TABLE_300
    , p6_a6 in out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a7 in out nocopy JTF_VARCHAR2_TABLE_100
    , p6_a8 in out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_display_context_tbl ibe_displaycontext_grp.display_context_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any






    ibe_displaycontext_grp_w.rosetta_table_copy_in_p3(ddp_display_context_tbl, p6_a0
      , p6_a1
      , p6_a2
      , p6_a3
      , p6_a4
      , p6_a5
      , p6_a6
      , p6_a7
      , p6_a8
      );

    -- here's the delegated call to the old PL/SQL routine
    ibe_displaycontext_grp.save_delete_display_context(p_api_version,
      p_init_msg_list,
      p_commit,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_display_context_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    ibe_displaycontext_grp_w.rosetta_table_copy_out_p3(ddp_display_context_tbl, p6_a0
      , p6_a1
      , p6_a2
      , p6_a3
      , p6_a4
      , p6_a5
      , p6_a6
      , p6_a7
      , p6_a8
      );
  end;

  procedure delete_display_context(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p6_a0 in out nocopy  VARCHAR2
    , p6_a1 in out nocopy  NUMBER
    , p6_a2 in out nocopy  NUMBER
    , p6_a3 in out nocopy  VARCHAR2
    , p6_a4 in out nocopy  VARCHAR2
    , p6_a5 in out nocopy  VARCHAR2
    , p6_a6 in out nocopy  VARCHAR2
    , p6_a7 in out nocopy  VARCHAR2
    , p6_a8 in out nocopy  NUMBER
  )

  as
    ddp_display_context_rec ibe_displaycontext_grp.display_context_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any






    ddp_display_context_rec.context_delete := p6_a0;
    ddp_display_context_rec.object_version_number := rosetta_g_miss_num_map(p6_a1);
    ddp_display_context_rec.context_id := rosetta_g_miss_num_map(p6_a2);
    ddp_display_context_rec.access_name := p6_a3;
    ddp_display_context_rec.display_name := p6_a4;
    ddp_display_context_rec.description := p6_a5;
    ddp_display_context_rec.context_type := p6_a6;
    ddp_display_context_rec.component_type_code := p6_a7;
    ddp_display_context_rec.default_deliverable_id := rosetta_g_miss_num_map(p6_a8);

    -- here's the delegated call to the old PL/SQL routine
    ibe_displaycontext_grp.delete_display_context(p_api_version,
      p_init_msg_list,
      p_commit,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_display_context_rec);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






    p6_a0 := ddp_display_context_rec.context_delete;
    p6_a1 := rosetta_g_miss_num_map(ddp_display_context_rec.object_version_number);
    p6_a2 := rosetta_g_miss_num_map(ddp_display_context_rec.context_id);
    p6_a3 := ddp_display_context_rec.access_name;
    p6_a4 := ddp_display_context_rec.display_name;
    p6_a5 := ddp_display_context_rec.description;
    p6_a6 := ddp_display_context_rec.context_type;
    p6_a7 := ddp_display_context_rec.component_type_code;
    p6_a8 := rosetta_g_miss_num_map(ddp_display_context_rec.default_deliverable_id);
  end;

  procedure insert_row(x_rowid in out nocopy  VARCHAR2
    , x_context_id  NUMBER
    , x_object_version_number  NUMBER
    , x_access_name  VARCHAR2
    , x_context_type_code  VARCHAR2
    , x_item_id  NUMBER
    , x_name  VARCHAR2
    , x_description  VARCHAR2
    , x_creation_date  date
    , x_created_by  NUMBER
    , x_last_update_date  date
    , x_last_updated_by  NUMBER
    , x_last_update_login  NUMBER
    , x_component_type_code  VARCHAR2
  )

  as
    ddx_creation_date date;
    ddx_last_update_date date;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any








    ddx_creation_date := rosetta_g_miss_date_in_map(x_creation_date);


    ddx_last_update_date := rosetta_g_miss_date_in_map(x_last_update_date);




    -- here's the delegated call to the old PL/SQL routine
    ibe_displaycontext_grp.insert_row(x_rowid,
      x_context_id,
      x_object_version_number,
      x_access_name,
      x_context_type_code,
      x_item_id,
      x_name,
      x_description,
      ddx_creation_date,
      x_created_by,
      ddx_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      x_component_type_code);

    -- copy data back from the local variables to OUT or IN-OUT args, if any













  end;

  procedure update_row(x_context_id  NUMBER
    , x_object_version_number  NUMBER
    , x_access_name  VARCHAR2
    , x_context_type_code  VARCHAR2
    , x_item_id  NUMBER
    , x_name  VARCHAR2
    , x_description  VARCHAR2
    , x_last_update_date  date
    , x_last_updated_by  NUMBER
    , x_last_update_login  NUMBER
    , x_component_type_code  VARCHAR2
  )

  as
    ddx_last_update_date date;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddx_last_update_date := rosetta_g_miss_date_in_map(x_last_update_date);




    -- here's the delegated call to the old PL/SQL routine
    ibe_displaycontext_grp.update_row(x_context_id,
      x_object_version_number,
      x_access_name,
      x_context_type_code,
      x_item_id,
      x_name,
      x_description,
      ddx_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      x_component_type_code);

    -- copy data back from the local variables to OUT or IN-OUT args, if any










  end;

end ibe_displaycontext_grp_w;

/
