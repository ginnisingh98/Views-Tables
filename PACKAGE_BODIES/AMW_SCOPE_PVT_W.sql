--------------------------------------------------------
--  DDL for Package Body AMW_SCOPE_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMW_SCOPE_PVT_W" as
  /* $Header: amwwscpb.pls 120.0 2005/05/31 21:35:35 appldev noship $ */
  procedure rosetta_table_copy_in_p1(t out nocopy amw_scope_pvt.sub_tbl_type, a0 JTF_VARCHAR2_TABLE_200
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).subsidiary_code := a0(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p1;
  procedure rosetta_table_copy_out_p1(t amw_scope_pvt.sub_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_200
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_200();
  else
      a0 := JTF_VARCHAR2_TABLE_200();
      if t.count > 0 then
        a0.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).subsidiary_code;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p1;

  procedure rosetta_table_copy_in_p3(t out nocopy amw_scope_pvt.sub_new_tbl_type, a0 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).subsidiary_id := a0(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p3;
  procedure rosetta_table_copy_out_p3(t amw_scope_pvt.sub_new_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    ) as
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
          a0(indx) := t(ddindx).subsidiary_id;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p3;

  procedure rosetta_table_copy_in_p5(t out nocopy amw_scope_pvt.lob_tbl_type, a0 JTF_VARCHAR2_TABLE_200
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).lob_code := a0(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p5;
  procedure rosetta_table_copy_out_p5(t amw_scope_pvt.lob_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_200
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_200();
  else
      a0 := JTF_VARCHAR2_TABLE_200();
      if t.count > 0 then
        a0.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).lob_code;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p5;

  procedure rosetta_table_copy_in_p7(t out nocopy amw_scope_pvt.lob_new_tbl_type, a0 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).lob_id := a0(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p7;
  procedure rosetta_table_copy_out_p7(t amw_scope_pvt.lob_new_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    ) as
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
          a0(indx) := t(ddindx).lob_id;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p7;

  procedure rosetta_table_copy_in_p9(t out nocopy amw_scope_pvt.org_tbl_type, a0 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).org_id := a0(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p9;
  procedure rosetta_table_copy_out_p9(t amw_scope_pvt.org_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    ) as
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
          a0(indx) := t(ddindx).org_id;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p9;

  procedure rosetta_table_copy_in_p11(t out nocopy amw_scope_pvt.process_tbl_type, a0 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).process_id := a0(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p11;
  procedure rosetta_table_copy_out_p11(t amw_scope_pvt.process_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    ) as
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
          a0(indx) := t(ddindx).process_id;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p11;

  procedure rosetta_table_copy_in_p13(t out nocopy amw_scope_pvt.proc_hier_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).top_process_id := a0(indx);
          t(ddindx).parent_process_id := a1(indx);
          t(ddindx).process_id := a2(indx);
          t(ddindx).level_id := a3(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p13;
  procedure rosetta_table_copy_out_p13(t amw_scope_pvt.proc_hier_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_NUMBER_TABLE();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        a3.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).top_process_id;
          a1(indx) := t(ddindx).parent_process_id;
          a2(indx) := t(ddindx).process_id;
          a3(indx) := t(ddindx).level_id;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p13;

  procedure add_scope(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_entity_id  NUMBER
    , p_entity_type  VARCHAR2
    , p_sub_vs  VARCHAR2
    , p_lob_vs  VARCHAR2
    , p8_a0 JTF_VARCHAR2_TABLE_200
    , p9_a0 JTF_VARCHAR2_TABLE_200
    , p10_a0 JTF_NUMBER_TABLE
    , p11_a0 JTF_NUMBER_TABLE
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_subsidiary_tbl amw_scope_pvt.sub_tbl_type;
    ddp_lob_tbl amw_scope_pvt.lob_tbl_type;
    ddp_org_tbl amw_scope_pvt.org_tbl_type;
    ddp_process_tbl amw_scope_pvt.process_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any








    amw_scope_pvt_w.rosetta_table_copy_in_p1(ddp_subsidiary_tbl, p8_a0
      );

    amw_scope_pvt_w.rosetta_table_copy_in_p5(ddp_lob_tbl, p9_a0
      );

    amw_scope_pvt_w.rosetta_table_copy_in_p9(ddp_org_tbl, p10_a0
      );

    amw_scope_pvt_w.rosetta_table_copy_in_p11(ddp_process_tbl, p11_a0
      );




    -- here's the delegated call to the old PL/SQL routine
    amw_scope_pvt.add_scope(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      p_entity_id,
      p_entity_type,
      p_sub_vs,
      p_lob_vs,
      ddp_subsidiary_tbl,
      ddp_lob_tbl,
      ddp_org_tbl,
      ddp_process_tbl,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any














  end;

  procedure populate_custom_hierarchy(p0_a0 JTF_NUMBER_TABLE
    , p_entity_id  NUMBER
    , p_entity_type  VARCHAR2
  )

  as
    ddp_org_tbl amw_scope_pvt.org_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    amw_scope_pvt_w.rosetta_table_copy_in_p9(ddp_org_tbl, p0_a0
      );



    -- here's the delegated call to the old PL/SQL routine
    amw_scope_pvt.populate_custom_hierarchy(ddp_org_tbl,
      p_entity_id,
      p_entity_type);

    -- copy data back from the local variables to OUT or IN-OUT args, if any


  end;

  procedure generate_organization_list(p_entity_id  NUMBER
    , p_entity_type  VARCHAR2
    , p2_a0 JTF_NUMBER_TABLE
    , p3_a0 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_org_tbl amw_scope_pvt.org_tbl_type;
    ddp_org_new_tbl amw_scope_pvt.org_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any


    amw_scope_pvt_w.rosetta_table_copy_in_p9(ddp_org_tbl, p2_a0
      );


    -- here's the delegated call to the old PL/SQL routine
    amw_scope_pvt.generate_organization_list(p_entity_id,
      p_entity_type,
      ddp_org_tbl,
      ddp_org_new_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any



    amw_scope_pvt_w.rosetta_table_copy_out_p9(ddp_org_new_tbl, p3_a0
      );
  end;

  procedure generate_subsidiary_list(p_entity_id  NUMBER
    , p_entity_type  VARCHAR2
    , p2_a0 JTF_NUMBER_TABLE
    , p3_a0 JTF_VARCHAR2_TABLE_200
    , p_sub_vs  VARCHAR2
    , p5_a0 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_org_new_tbl amw_scope_pvt.org_tbl_type;
    ddp_subsidiary_tbl amw_scope_pvt.sub_tbl_type;
    ddp_sub_new_tbl amw_scope_pvt.sub_new_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any


    amw_scope_pvt_w.rosetta_table_copy_in_p9(ddp_org_new_tbl, p2_a0
      );

    amw_scope_pvt_w.rosetta_table_copy_in_p1(ddp_subsidiary_tbl, p3_a0
      );



    -- here's the delegated call to the old PL/SQL routine
    amw_scope_pvt.generate_subsidiary_list(p_entity_id,
      p_entity_type,
      ddp_org_new_tbl,
      ddp_subsidiary_tbl,
      p_sub_vs,
      ddp_sub_new_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any





    amw_scope_pvt_w.rosetta_table_copy_out_p3(ddp_sub_new_tbl, p5_a0
      );
  end;

  procedure generate_lob_list(p_entity_id  NUMBER
    , p_entity_type  VARCHAR2
    , p2_a0 JTF_NUMBER_TABLE
    , p3_a0 JTF_VARCHAR2_TABLE_200
    , p_sub_vs  VARCHAR2
    , p5_a0 JTF_VARCHAR2_TABLE_200
    , p_lob_vs  VARCHAR2
    , p7_a0 out nocopy JTF_NUMBER_TABLE
  )

  as
    ddp_org_new_tbl amw_scope_pvt.org_tbl_type;
    ddp_subsidiary_tbl amw_scope_pvt.sub_tbl_type;
    ddp_lob_tbl amw_scope_pvt.lob_tbl_type;
    ddp_lob_new_tbl amw_scope_pvt.lob_new_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any


    amw_scope_pvt_w.rosetta_table_copy_in_p9(ddp_org_new_tbl, p2_a0
      );

    amw_scope_pvt_w.rosetta_table_copy_in_p1(ddp_subsidiary_tbl, p3_a0
      );


    amw_scope_pvt_w.rosetta_table_copy_in_p5(ddp_lob_tbl, p5_a0
      );



    -- here's the delegated call to the old PL/SQL routine
    amw_scope_pvt.generate_lob_list(p_entity_id,
      p_entity_type,
      ddp_org_new_tbl,
      ddp_subsidiary_tbl,
      p_sub_vs,
      ddp_lob_tbl,
      p_lob_vs,
      ddp_lob_new_tbl);

    -- copy data back from the local variables to OUT or IN-OUT args, if any







    amw_scope_pvt_w.rosetta_table_copy_out_p7(ddp_lob_new_tbl, p7_a0
      );
  end;

  procedure populate_process_hierarchy(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_entity_type  VARCHAR2
    , p_entity_id  NUMBER
    , p6_a0 JTF_NUMBER_TABLE
    , p7_a0 JTF_NUMBER_TABLE
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_org_tbl amw_scope_pvt.org_tbl_type;
    ddp_process_tbl amw_scope_pvt.process_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any






    amw_scope_pvt_w.rosetta_table_copy_in_p9(ddp_org_tbl, p6_a0
      );

    amw_scope_pvt_w.rosetta_table_copy_in_p11(ddp_process_tbl, p7_a0
      );




    -- here's the delegated call to the old PL/SQL routine
    amw_scope_pvt.populate_process_hierarchy(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      p_entity_type,
      p_entity_id,
      ddp_org_tbl,
      ddp_process_tbl,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any










  end;

  procedure populate_denormalized_tables(p_entity_type  VARCHAR2
    , p_entity_id  NUMBER
    , p2_a0 JTF_NUMBER_TABLE
    , p3_a0 JTF_NUMBER_TABLE
    , p_mode  VARCHAR2
  )

  as
    ddp_org_tbl amw_scope_pvt.org_tbl_type;
    ddp_process_tbl amw_scope_pvt.process_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any


    amw_scope_pvt_w.rosetta_table_copy_in_p9(ddp_org_tbl, p2_a0
      );

    amw_scope_pvt_w.rosetta_table_copy_in_p11(ddp_process_tbl, p3_a0
      );


    -- here's the delegated call to the old PL/SQL routine
    amw_scope_pvt.populate_denormalized_tables(p_entity_type,
      p_entity_id,
      ddp_org_tbl,
      ddp_process_tbl,
      p_mode);

    -- copy data back from the local variables to OUT or IN-OUT args, if any




  end;

  procedure manage_processes(p_api_version_number  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , p_entity_type  VARCHAR2
    , p_entity_id  NUMBER
    , p_organization_id  NUMBER
    , p7_a0 JTF_NUMBER_TABLE
    , p7_a1 JTF_NUMBER_TABLE
    , p7_a2 JTF_NUMBER_TABLE
    , p7_a3 JTF_NUMBER_TABLE
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_proc_hier_tbl amw_scope_pvt.proc_hier_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    amw_scope_pvt_w.rosetta_table_copy_in_p13(ddp_proc_hier_tbl, p7_a0
      , p7_a1
      , p7_a2
      , p7_a3
      );




    -- here's the delegated call to the old PL/SQL routine
    amw_scope_pvt.manage_processes(p_api_version_number,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      p_entity_type,
      p_entity_id,
      p_organization_id,
      ddp_proc_hier_tbl,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any










  end;

end amw_scope_pvt_w;

/
