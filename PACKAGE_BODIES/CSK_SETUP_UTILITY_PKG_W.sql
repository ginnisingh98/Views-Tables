--------------------------------------------------------
--  DDL for Package Body CSK_SETUP_UTILITY_PKG_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSK_SETUP_UTILITY_PKG_W" as
  /* $Header: csktsuwb.pls 120.0 2005/06/01 11:49:35 appldev noship $ */
  procedure rosetta_table_copy_in_p12(t out nocopy csk_setup_utility_pkg.stmt_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_VARCHAR2_TABLE_2000
    , a5 JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count=0 then
    t := csk_setup_utility_pkg.stmt_tbl_type();
  elsif a0 is not null and a0.count > 0 then
      if a0.count > 0 then
      t := csk_setup_utility_pkg.stmt_tbl_type();
      t.extend(a0.count);
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).element_id := a0(indx);
          t(ddindx).element_number := a1(indx);
          t(ddindx).element_type_id := a2(indx);
          t(ddindx).access_level := a3(indx);
          t(ddindx).name := a4(indx);
          t(ddindx).content_type := a5(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p12;
  procedure rosetta_table_copy_out_p12(t csk_setup_utility_pkg.stmt_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_VARCHAR2_TABLE_2000
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null then
    a0 := null;
    a1 := null;
    a2 := null;
    a3 := null;
    a4 := null;
    a5 := null;
  elsif t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_VARCHAR2_TABLE_2000();
    a5 := JTF_VARCHAR2_TABLE_100();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_VARCHAR2_TABLE_2000();
      a5 := JTF_VARCHAR2_TABLE_100();
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
          a0(indx) := t(ddindx).element_id;
          a1(indx) := t(ddindx).element_number;
          a2(indx) := t(ddindx).element_type_id;
          a3(indx) := t(ddindx).access_level;
          a4(indx) := t(ddindx).name;
          a5(indx) := t(ddindx).content_type;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p12;

  procedure rosetta_table_copy_in_p13(t out nocopy csk_setup_utility_pkg.cat_tbl_type, a0 JTF_NUMBER_TABLE) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is null then
    t := null;
  elsif a0.count = 0 then
    t := csk_setup_utility_pkg.cat_tbl_type();
  else
      if a0.count > 0 then
      t := csk_setup_utility_pkg.cat_tbl_type();
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
  end rosetta_table_copy_in_p13;
  procedure rosetta_table_copy_out_p13(t csk_setup_utility_pkg.cat_tbl_type, a0 out nocopy JTF_NUMBER_TABLE) as
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
          a0(indx) := t(ddindx);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p13;

  procedure create_solution(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_commit  VARCHAR2
    , p_validation_level  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p7_a0  NUMBER
    , p7_a1  VARCHAR2
    , p7_a2  NUMBER
    , p7_a3  VARCHAR2
    , p7_a4  VARCHAR2
    , p8_a0 JTF_NUMBER_TABLE
    , p8_a1 JTF_VARCHAR2_TABLE_100
    , p8_a2 JTF_NUMBER_TABLE
    , p8_a3 JTF_NUMBER_TABLE
    , p8_a4 JTF_VARCHAR2_TABLE_2000
    , p8_a5 JTF_VARCHAR2_TABLE_100
    , p_cat_tbl JTF_NUMBER_TABLE
    , p_publish  number
  )

  as
    ddp_soln_rec csk_setup_utility_pkg.soln_rec_type;
    ddp_stmt_tbl csk_setup_utility_pkg.stmt_tbl_type;
    ddp_cat_tbl csk_setup_utility_pkg.cat_tbl_type;
    ddp_publish boolean;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    ddp_soln_rec.set_id := p7_a0;
    ddp_soln_rec.set_number := p7_a1;
    ddp_soln_rec.set_type_id := p7_a2;
    ddp_soln_rec.name := p7_a3;
    ddp_soln_rec.visibility_id := p7_a4;

    csk_setup_utility_pkg_w.rosetta_table_copy_in_p12(ddp_stmt_tbl, p8_a0
      , p8_a1
      , p8_a2
      , p8_a3
      , p8_a4
      , p8_a5
      );

    csk_setup_utility_pkg_w.rosetta_table_copy_in_p13(ddp_cat_tbl, p_cat_tbl);

    if p_publish is null
      then ddp_publish := null;
    elsif p_publish = 0
      then ddp_publish := false;
    else ddp_publish := true;
    end if;

    -- here's the delegated call to the old PL/SQL routine
    csk_setup_utility_pkg.create_solution(p_api_version,
      p_init_msg_list,
      p_commit,
      p_validation_level,
      x_return_status,
      x_msg_count,
      x_msg_data,
      ddp_soln_rec,
      ddp_stmt_tbl,
      ddp_cat_tbl,
      ddp_publish);

    -- copy data back from the local variables to OUT or IN-OUT args, if any










  end;

end csk_setup_utility_pkg_w;

/
