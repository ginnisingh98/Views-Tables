--------------------------------------------------------
--  DDL for Package Body OKC_TERMS_MULTIREC_GRP_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_TERMS_MULTIREC_GRP_W" as
  /* $Header: OKCWMULB.pls 120.3.12010000.2 2011/12/09 13:58:12 serukull ship $ */

  procedure rosetta_table_copy_in_p5(t out nocopy okc_terms_multirec_grp.art_var_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_VARCHAR2_TABLE_100
    , a2 JTF_VARCHAR2_TABLE_100
    , a3 JTF_VARCHAR2_TABLE_100
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_VARCHAR2_TABLE_2000
    , a6 JTF_NUMBER_TABLE
    , a7 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).cat_id := a0(indx);
          t(ddindx).variable_code := a1(indx);
          t(ddindx).variable_type := a2(indx);
          t(ddindx).external_yn := a3(indx);
          t(ddindx).variable_value_id := a4(indx);
          t(ddindx).variable_value := a5(indx);
          t(ddindx).attribute_value_set_id := a6(indx);
          t(ddindx).object_version_number := a7(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p5;
  procedure rosetta_table_copy_out_p5(t okc_terms_multirec_grp.art_var_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_VARCHAR2_TABLE_100
    , a2 out nocopy JTF_VARCHAR2_TABLE_100
    , a3 out nocopy JTF_VARCHAR2_TABLE_100
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_VARCHAR2_TABLE_2000
    , a6 out nocopy JTF_NUMBER_TABLE
    , a7 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_VARCHAR2_TABLE_100();
    a2 := JTF_VARCHAR2_TABLE_100();
    a3 := JTF_VARCHAR2_TABLE_100();
    a4 := JTF_VARCHAR2_TABLE_100();
    a5 := JTF_VARCHAR2_TABLE_2000();
    a6 := JTF_NUMBER_TABLE();
    a7 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_VARCHAR2_TABLE_100();
      a2 := JTF_VARCHAR2_TABLE_100();
      a3 := JTF_VARCHAR2_TABLE_100();
      a4 := JTF_VARCHAR2_TABLE_100();
      a5 := JTF_VARCHAR2_TABLE_2000();
      a6 := JTF_NUMBER_TABLE();
      a7 := JTF_NUMBER_TABLE();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        a3.extend(t.count);
        a4.extend(t.count);
        a5.extend(t.count);
        a6.extend(t.count);
        a7.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).cat_id;
          a1(indx) := t(ddindx).variable_code;
          a2(indx) := t(ddindx).variable_type;
          a3(indx) := t(ddindx).external_yn;
          a4(indx) := t(ddindx).variable_value_id;
          a5(indx) := t(ddindx).variable_value;
          a6(indx) := t(ddindx).attribute_value_set_id;
          a7(indx) := t(ddindx).object_version_number;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p5;

  procedure rosetta_table_copy_in_p6(t out nocopy okc_terms_multirec_grp.kart_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_VARCHAR2_TABLE_2000
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_NUMBER_TABLE
    , a6 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).id := a0(indx);
          t(ddindx).sav_sae_id := a1(indx);
          t(ddindx).article_version_id := a2(indx);
          t(ddindx).amendment_description := a3(indx);
          t(ddindx).print_text_yn := a4(indx);
          t(ddindx).ref_article_id := a5(indx);
          t(ddindx).ref_article_version_id := a6(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p6;
  procedure rosetta_table_copy_out_p6(t okc_terms_multirec_grp.kart_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_VARCHAR2_TABLE_2000
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_NUMBER_TABLE
    , a6 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_VARCHAR2_TABLE_2000();
    a4 := JTF_VARCHAR2_TABLE_100();
    a5 := JTF_NUMBER_TABLE();
    a6 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_VARCHAR2_TABLE_2000();
      a4 := JTF_VARCHAR2_TABLE_100();
      a5 := JTF_NUMBER_TABLE();
      a6 := JTF_NUMBER_TABLE();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        a3.extend(t.count);
        a4.extend(t.count);
        a5.extend(t.count);
        a6.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).id;
          a1(indx) := t(ddindx).sav_sae_id;
          a2(indx) := t(ddindx).article_version_id;
          a3(indx) := t(ddindx).amendment_description;
          a4(indx) := t(ddindx).print_text_yn;
          a5(indx) := t(ddindx).ref_article_id;
          a6(indx) := t(ddindx).ref_article_version_id;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p6;

  procedure rosetta_table_copy_in_p7(t out nocopy okc_terms_multirec_grp.structure_tbl_type, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    , a3 JTF_NUMBER_TABLE
    , a4 JTF_VARCHAR2_TABLE_100
    , a5 JTF_VARCHAR2_TABLE_100
    , a6 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).type := a0(indx);
          t(ddindx).id := a1(indx);
          t(ddindx).scn_id := a2(indx);
          t(ddindx).display_sequence := a3(indx);
          t(ddindx).label := a4(indx);
          t(ddindx).mandatory_yn := a5(indx);
          t(ddindx).object_version_number := a6(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p7;
  procedure rosetta_table_copy_out_p7(t okc_terms_multirec_grp.structure_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_100
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    , a3 out nocopy JTF_NUMBER_TABLE
    , a4 out nocopy JTF_VARCHAR2_TABLE_100
    , a5 out nocopy JTF_VARCHAR2_TABLE_100
    , a6 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_100();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
    a3 := JTF_NUMBER_TABLE();
    a4 := JTF_VARCHAR2_TABLE_100();
    a5 := JTF_VARCHAR2_TABLE_100();
    a6 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_VARCHAR2_TABLE_100();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      a3 := JTF_NUMBER_TABLE();
      a4 := JTF_VARCHAR2_TABLE_100();
      a5 := JTF_VARCHAR2_TABLE_100();
      a6 := JTF_NUMBER_TABLE();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        a3.extend(t.count);
        a4.extend(t.count);
        a5.extend(t.count);
        a6.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).type;
          a1(indx) := t(ddindx).id;
          a2(indx) := t(ddindx).scn_id;
          a3(indx) := t(ddindx).display_sequence;
          a4(indx) := t(ddindx).label;
          a5(indx) := t(ddindx).mandatory_yn;
          a6(indx) := t(ddindx).object_version_number;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p7;

  procedure rosetta_table_copy_in_p8(t out nocopy okc_terms_multirec_grp.article_id_tbl_type, a0 JTF_NUMBER_TABLE) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
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
  end rosetta_table_copy_in_p8;
  procedure rosetta_table_copy_out_p8(t okc_terms_multirec_grp.article_id_tbl_type, a0 out nocopy JTF_NUMBER_TABLE) as
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
          a0(indx) := t(ddindx);
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p8;

  procedure rosetta_table_copy_in_p9(t out nocopy okc_terms_multirec_grp.article_tbl_type, a0 JTF_NUMBER_TABLE
    , a1 JTF_NUMBER_TABLE
    , a2 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).cat_id := a0(indx);
          t(ddindx).article_version_id := a1(indx);
          t(ddindx).ovn := a2(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p9;
  procedure rosetta_table_copy_out_p9(t okc_terms_multirec_grp.article_tbl_type, a0 out nocopy JTF_NUMBER_TABLE
    , a1 out nocopy JTF_NUMBER_TABLE
    , a2 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_NUMBER_TABLE();
    a1 := JTF_NUMBER_TABLE();
    a2 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_NUMBER_TABLE();
      a1 := JTF_NUMBER_TABLE();
      a2 := JTF_NUMBER_TABLE();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).cat_id;
          a1(indx) := t(ddindx).article_version_id;
          a2(indx) := t(ddindx).ovn;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p9;

  procedure rosetta_table_copy_in_p10(t out nocopy okc_terms_multirec_grp.organize_tbl_type, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).object_type := a0(indx);
          t(ddindx).id := a1(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p10;
  procedure rosetta_table_copy_out_p10(t okc_terms_multirec_grp.organize_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_100
    , a1 out nocopy JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_100();
    a1 := JTF_NUMBER_TABLE();
  else
      a0 := JTF_VARCHAR2_TABLE_100();
      a1 := JTF_NUMBER_TABLE();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).object_type;
          a1(indx) := t(ddindx).id;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p10;

  procedure create_article(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_mode  VARCHAR2
    , p_validation_level  NUMBER
    , p_validate_commit  VARCHAR2
    , p_validation_string  VARCHAR2
    , p_commit  VARCHAR2
    , p_ref_type  VARCHAR2
    , p_ref_id  NUMBER
    , p_doc_type  VARCHAR2
    , p_doc_id  NUMBER
    , p11_a0 JTF_NUMBER_TABLE
    , p11_a1 JTF_NUMBER_TABLE
    , p11_a2 JTF_NUMBER_TABLE
    , p11_a3 JTF_VARCHAR2_TABLE_2000
    , p11_a4 JTF_VARCHAR2_TABLE_100
    , p11_a5 JTF_NUMBER_TABLE
    , p11_a6 JTF_NUMBER_TABLE
    , p12_a0 out nocopy JTF_NUMBER_TABLE
    , p12_a1 out nocopy JTF_NUMBER_TABLE
    , p12_a2 out nocopy JTF_NUMBER_TABLE
    , p12_a3 out nocopy JTF_VARCHAR2_TABLE_2000
    , p12_a4 out nocopy JTF_VARCHAR2_TABLE_100
    , p12_a5 out nocopy JTF_NUMBER_TABLE
    , p12_a6 out nocopy JTF_NUMBER_TABLE
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_kart_tbl okc_terms_multirec_grp.kart_tbl_type;
    ddx_kart_tbl okc_terms_multirec_grp.kart_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any











    okc_terms_multirec_grp_w.rosetta_table_copy_in_p6(ddp_kart_tbl, p11_a0
      , p11_a1
      , p11_a2
      , p11_a3
      , p11_a4
      , p11_a5
      , p11_a6
      );





    -- here's the delegated call to the old PL/SQL routine
    okc_terms_multirec_grp.create_article(p_api_version,
      p_init_msg_list,
      p_mode,
      p_validation_level,
      p_validate_commit,
      p_validation_string,
      p_commit,
      p_ref_type,
      p_ref_id,
      p_doc_type,
      p_doc_id,
      ddp_kart_tbl,
      ddx_kart_tbl,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any












    okc_terms_multirec_grp_w.rosetta_table_copy_out_p6(ddx_kart_tbl, p12_a0
      , p12_a1
      , p12_a2
      , p12_a3
      , p12_a4
      , p12_a5
      , p12_a6
      );



  end;

  procedure update_article_variable(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , p_validate_commit  VARCHAR2
    , p_validation_string  VARCHAR2
    , p_commit  VARCHAR2
    , p6_a0 JTF_NUMBER_TABLE
    , p6_a1 JTF_VARCHAR2_TABLE_100
    , p6_a2 JTF_VARCHAR2_TABLE_100
    , p6_a3 JTF_VARCHAR2_TABLE_100
    , p6_a4 JTF_VARCHAR2_TABLE_100
    , p6_a5 JTF_VARCHAR2_TABLE_2000
    , p6_a6 JTF_NUMBER_TABLE
    , p6_a7 JTF_NUMBER_TABLE
    , p_mode  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_lock_terms_yn   IN VARCHAR2
  )

  as
    ddp_art_var_tbl okc_terms_multirec_grp.art_var_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any






    okc_terms_multirec_grp_w.rosetta_table_copy_in_p5(ddp_art_var_tbl, p6_a0
      , p6_a1
      , p6_a2
      , p6_a3
      , p6_a4
      , p6_a5
      , p6_a6
      , p6_a7
      );





    -- here's the delegated call to the old PL/SQL routine
    okc_terms_multirec_grp.update_article_variable(p_api_version,
      p_init_msg_list,
      p_validation_level,
      p_validate_commit,
      p_validation_string,
      p_commit,
      ddp_art_var_tbl,
      p_mode,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_lock_terms_yn);

    -- copy data back from the local variables to OUT or IN-OUT args, if any










  end;

  procedure update_structure(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , p_validate_commit  VARCHAR2
    , p_validation_string  VARCHAR2
    , p_commit  VARCHAR2
    , p6_a0 JTF_VARCHAR2_TABLE_100
    , p6_a1 JTF_NUMBER_TABLE
    , p6_a2 JTF_NUMBER_TABLE
    , p6_a3 JTF_NUMBER_TABLE
    , p6_a4 JTF_VARCHAR2_TABLE_100
    , p6_a5 JTF_VARCHAR2_TABLE_100
    , p6_a6 JTF_NUMBER_TABLE
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_structure_tbl okc_terms_multirec_grp.structure_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any






    okc_terms_multirec_grp_w.rosetta_table_copy_in_p7(ddp_structure_tbl, p6_a0
      , p6_a1
      , p6_a2
      , p6_a3
      , p6_a4
      , p6_a5
      , p6_a6
      );




    -- here's the delegated call to the old PL/SQL routine
    okc_terms_multirec_grp.update_structure(p_api_version,
      p_init_msg_list,
      p_validation_level,
      p_validate_commit,
      p_validation_string,
      p_commit,
      ddp_structure_tbl,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any









  end;

  procedure sync_doc_with_expert(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validate_commit  VARCHAR2
    , p_validation_string  VARCHAR2
    , p_commit  VARCHAR2
    , p_doc_type  VARCHAR2
    , p_doc_id  NUMBER
    , p_article_id_tbl JTF_NUMBER_TABLE
    , p_mode  VARCHAR2
    , x_articles_dropped out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_lock_terms_yn   IN VARCHAR2
  )

  as
    ddp_article_id_tbl okc_terms_multirec_grp.article_id_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any







    okc_terms_multirec_grp_w.rosetta_table_copy_in_p8(ddp_article_id_tbl, p_article_id_tbl);






    -- here's the delegated call to the old PL/SQL routine
    okc_terms_multirec_grp.sync_doc_with_expert(p_api_version,
      p_init_msg_list,
      p_validate_commit,
      p_validation_string,
      p_commit,
      p_doc_type,
      p_doc_id,
      ddp_article_id_tbl,
      p_mode,
      x_articles_dropped,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_lock_terms_yn);

    -- copy data back from the local variables to OUT or IN-OUT args, if any












  end;

  procedure refresh_articles(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validate_commit  VARCHAR2
    , p_validation_string  VARCHAR2
    , p_commit  VARCHAR2
    , p_mode  VARCHAR2
    , p_doc_type  VARCHAR2
    , p_doc_id  NUMBER
    , p8_a0 JTF_NUMBER_TABLE
    , p8_a1 JTF_NUMBER_TABLE
    , p8_a2 JTF_NUMBER_TABLE
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
   , p_lock_terms_yn   IN VARCHAR2
  )

  as
    ddp_article_tbl okc_terms_multirec_grp.article_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any








    okc_terms_multirec_grp_w.rosetta_table_copy_in_p9(ddp_article_tbl, p8_a0
      , p8_a1
      , p8_a2
      );




    -- here's the delegated call to the old PL/SQL routine
    okc_terms_multirec_grp.refresh_articles(p_api_version,
      p_init_msg_list,
      p_validate_commit,
      p_validation_string,
      p_commit,
      p_mode,
      p_doc_type,
      p_doc_id,
      ddp_article_tbl,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_lock_terms_yn);

    -- copy data back from the local variables to OUT or IN-OUT args, if any











  end;

  procedure organize_layout(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , p_validate_commit  VARCHAR2
    , p_validation_string  VARCHAR2
    , p_commit  VARCHAR2
    , p6_a0 JTF_VARCHAR2_TABLE_100
    , p6_a1 JTF_NUMBER_TABLE
    , p_ref_point  VARCHAR2
    , p_doc_type  VARCHAR2
    , p_doc_id  NUMBER
    , p_to_object_type  VARCHAR2
    , p_to_object_id  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_organize_tbl okc_terms_multirec_grp.organize_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any






    okc_terms_multirec_grp_w.rosetta_table_copy_in_p10(ddp_organize_tbl, p6_a0
      , p6_a1
      );









    -- here's the delegated call to the old PL/SQL routine
    okc_terms_multirec_grp.organize_layout(p_api_version,
      p_init_msg_list,
      p_validation_level,
      p_validate_commit,
      p_validation_string,
      p_commit,
      ddp_organize_tbl,
      p_ref_point,
      p_doc_type,
      p_doc_id,
      p_to_object_type,
      p_to_object_id,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any














  end;


  procedure rosetta_table_copy_in_p11(t out nocopy okc_terms_multirec_grp.merge_review_tbl_type, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_NUMBER_TABLE, a2 JTF_NUMBER_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).object_type := a0(indx);
          t(ddindx).review_upld_terms_id := a1(indx);
          t(ddindx).object_version_number := a2(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p11;

  procedure merge_review_clauses(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , p_validate_commit  VARCHAR2
    , p_validation_string  VARCHAR2
    , p_commit  VARCHAR2
    , p6_a0 JTF_VARCHAR2_TABLE_100
    , p6_a1 JTF_NUMBER_TABLE
    , p6_a2 JTF_NUMBER_TABLE
    , p_doc_type  VARCHAR2
    , p_doc_id  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
  )

  as
    ddp_merge_review_clauses_tbl okc_terms_multirec_grp.merge_review_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any






    okc_terms_multirec_grp_w.rosetta_table_copy_in_p11(ddp_merge_review_clauses_tbl, p6_a0
      , p6_a1, p6_a2
      );









    -- here's the delegated call to the old PL/SQL routine
    okc_terms_multirec_grp.merge_review_clauses(p_api_version,
      p_init_msg_list,
      p_validation_level,
      p_validate_commit,
      p_validation_string,
      p_commit,
      ddp_merge_review_clauses_tbl,
      p_doc_type,
      p_doc_id,
      x_return_status,
      x_msg_count,
      x_msg_data);

    -- copy data back from the local variables to OUT or IN-OUT args, if any














  end;

end okc_terms_multirec_grp_w;

/
