--------------------------------------------------------
--  DDL for Package Body OKC_K_ARTICLES_GRP_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_K_ARTICLES_GRP_W" as
  /* $Header: OKCWVCATB.pls 120.0.12010000.1 2013/11/29 13:09:30 serukull noship $ */
  procedure rosetta_table_copy_in_p0(t out nocopy okc_k_articles_grp.id_tbl_type, a0 JTF_NUMBER_TABLE) as
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
  end rosetta_table_copy_in_p0;
  procedure rosetta_table_copy_out_p0(t okc_k_articles_grp.id_tbl_type, a0 out nocopy JTF_NUMBER_TABLE) as
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
  end rosetta_table_copy_out_p0;

  procedure delete_articles(p_api_version  NUMBER
    , p_init_msg_list  VARCHAR2
    , p_validate_commit  VARCHAR2
    , p_validation_string  VARCHAR2
    , p_commit  VARCHAR2
    , p_mode  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , p_super_user_yn  VARCHAR2
    , p_amendment_description  VARCHAR2
    , p_print_text_yn  VARCHAR2
    , p_id_tbl JTF_NUMBER_TABLE
    , p_object_version_number JTF_NUMBER_TABLE
    , p_mandatory_clause_delete  VARCHAR2
    , p_lock_terms_yn  VARCHAR2
  )

  as
    ddp_id_tbl okc_k_articles_grp.id_tbl_type;
    ddp_object_version_number okc_k_articles_grp.id_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any












    okc_k_articles_grp_w.rosetta_table_copy_in_p0(ddp_id_tbl, p_id_tbl);

    okc_k_articles_grp_w.rosetta_table_copy_in_p0(ddp_object_version_number, p_object_version_number);



    -- here's the delegated call to the old PL/SQL routine
    okc_k_articles_grp.delete_articles(p_api_version,
      p_init_msg_list,
      p_validate_commit,
      p_validation_string,
      p_commit,
      p_mode,
      x_return_status,
      x_msg_count,
      x_msg_data,
      p_super_user_yn,
      p_amendment_description,
      p_print_text_yn,
      ddp_id_tbl,
      ddp_object_version_number,
      p_mandatory_clause_delete,
      p_lock_terms_yn);

    -- copy data back from the local variables to OUT or IN-OUT args, if any















  end;

end okc_k_articles_grp_w;

/
