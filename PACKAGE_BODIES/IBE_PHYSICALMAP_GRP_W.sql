--------------------------------------------------------
--  DDL for Package Body IBE_PHYSICALMAP_GRP_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBE_PHYSICALMAP_GRP_W" as
  /* $Header: IBEGRPSB.pls 115.4 2002/12/18 07:09:16 schak ship $ */
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

  procedure rosetta_table_copy_in_p0(t out nocopy ibe_physicalmap_grp.language_code_tbl_type, a0 JTF_VARCHAR2_TABLE_100) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is null then
    t := null;
  elsif a0.count = 0 then
    t := ibe_physicalmap_grp.language_code_tbl_type();
  else
      if a0.count > 0 then
      t := ibe_physicalmap_grp.language_code_tbl_type();
      t.extend(a0.count);
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx) := a0(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p0;
  procedure rosetta_table_copy_out_p0(t ibe_physicalmap_grp.language_code_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_100) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null then
    a0 := null;
  elsif t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_VARCHAR2_TABLE_100();
      if t.count > 0 then
        a0.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p0;

  procedure rosetta_table_copy_in_p2(t out nocopy ibe_physicalmap_grp.msite_lang_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).msite_id := rosetta_g_miss_num_map(a0(indx));
          t(ddindx).lang_count := rosetta_g_miss_num_map(a1(indx));
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p2;
  procedure rosetta_table_copy_out_p2(t ibe_physicalmap_grp.msite_lang_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := rosetta_g_miss_num_map(t(ddindx).msite_id);
          a1(indx) := rosetta_g_miss_num_map(t(ddindx).lang_count);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p2;

  procedure rosetta_table_copy_in_p3(t out nocopy ibe_physicalmap_grp.lgl_phys_map_id_tbl_type, a0 JTF_NUMBER_TABLE) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
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
  end rosetta_table_copy_in_p3;
  procedure rosetta_table_copy_out_p3(t ibe_physicalmap_grp.lgl_phys_map_id_tbl_type, a0 out nocopy JTF_NUMBER_TABLE) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
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
  end rosetta_table_copy_out_p3;

  procedure rosetta_table_copy_in_p4(t out nocopy ibe_physicalmap_grp.msite_id_tbl_type, a0 JTF_NUMBER_TABLE) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
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
  end rosetta_table_copy_in_p4;
  procedure rosetta_table_copy_out_p4(t ibe_physicalmap_grp.msite_id_tbl_type, a0 out nocopy JTF_NUMBER_TABLE) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
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
  end rosetta_table_copy_out_p4;

  procedure save_physicalmap(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_attachment_id  NUMBER
    , p_msite_id  NUMBER
    , p_language_code_tbl JTF_VARCHAR2_TABLE_100
  )

  as
    ddp_language_code_tbl ibe_physicalmap_grp.language_code_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any








    ibe_physicalmap_grp_w.rosetta_table_copy_in_p0(ddp_language_code_tbl, p_language_code_tbl);

    -- here's the delegated call to the old PL/SQL routine
    ibe_physicalmap_grp.save_physicalmap(p_api_version,
      p_init_msg_list,
      p_commit,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_attachment_id,
      p_msite_id,
      ddp_language_code_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

  procedure save_physicalmap(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_attachment_id  NUMBER
    , p7_a0 JTF_NUMBER_TABLE
    , p7_a1 JTF_NUMBER_TABLE
    , p_language_code_tbl JTF_VARCHAR2_TABLE_100
  )

  as
    ddp_msite_lang_tbl ibe_physicalmap_grp.msite_lang_tbl_type;
    ddp_language_code_tbl ibe_physicalmap_grp.language_code_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ibe_physicalmap_grp_w.rosetta_table_copy_in_p2(ddp_msite_lang_tbl, p7_a0
      , p7_a1
      );

    ibe_physicalmap_grp_w.rosetta_table_copy_in_p0(ddp_language_code_tbl, p_language_code_tbl);

    -- here's the delegated call to the old PL/SQL routine
    ibe_physicalmap_grp.save_physicalmap(p_api_version,
      p_init_msg_list,
      p_commit,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_attachment_id,
      ddp_msite_lang_tbl,
      ddp_language_code_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any








  end;

  procedure delete_physicalmap(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_lgl_phys_map_id_tbl JTF_NUMBER_TABLE
  )

  as
    ddp_lgl_phys_map_id_tbl ibe_physicalmap_grp.lgl_phys_map_id_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any






    ibe_physicalmap_grp_w.rosetta_table_copy_in_p3(ddp_lgl_phys_map_id_tbl, p_lgl_phys_map_id_tbl);

    -- here's the delegated call to the old PL/SQL routine
    ibe_physicalmap_grp.delete_physicalmap(p_api_version,
      p_init_msg_list,
      p_commit,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_lgl_phys_map_id_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






  end;

  procedure delete_attachment_msite(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_attachment_id  NUMBER
    , p_msite_id_tbl JTF_NUMBER_TABLE
  )

  as
    ddp_msite_id_tbl ibe_physicalmap_grp.msite_id_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ibe_physicalmap_grp_w.rosetta_table_copy_in_p4(ddp_msite_id_tbl, p_msite_id_tbl);

    -- here's the delegated call to the old PL/SQL routine
    ibe_physicalmap_grp.delete_attachment_msite(p_api_version,
      p_init_msg_list,
      p_commit,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_attachment_id,
      ddp_msite_id_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







  end;

  procedure save_physicalmap(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_deliverable_id  NUMBER
    , p_old_content_key  VARCHAR2
    , p_new_content_key  VARCHAR2
    , p9_a0 JTF_NUMBER_TABLE
    , p9_a1 JTF_NUMBER_TABLE
    , p_language_code_tbl JTF_VARCHAR2_TABLE_100
  )

  as
    ddp_msite_lang_tbl ibe_physicalmap_grp.msite_lang_tbl_type;
    ddp_language_code_tbl ibe_physicalmap_grp.language_code_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any









    ibe_physicalmap_grp_w.rosetta_table_copy_in_p2(ddp_msite_lang_tbl, p9_a0
      , p9_a1
      );

    ibe_physicalmap_grp_w.rosetta_table_copy_in_p0(ddp_language_code_tbl, p_language_code_tbl);

    -- here's the delegated call to the old PL/SQL routine
    ibe_physicalmap_grp.save_physicalmap(p_api_version,
      p_init_msg_list,
      p_commit,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_deliverable_id,
      p_old_content_key,
      p_new_content_key,
      ddp_msite_lang_tbl,
      ddp_language_code_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any










  end;

end ibe_physicalmap_grp_w;

/
