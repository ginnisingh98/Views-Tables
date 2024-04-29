--------------------------------------------------------
--  DDL for Package Body QA_AUDIT_PKG_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QA_AUDIT_PKG_W" as
  /* $Header: qaaudwrb.pls 120.0 2005/06/09 09:41 srhariha noship $ */
  procedure rosetta_table_copy_in_p2(t out nocopy qa_audit_pkg.summaryparamarray, a0 JTF_VARCHAR2_TABLE_200
    ) is
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).standard := a0(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p2;
  procedure rosetta_table_copy_out_p2(t qa_audit_pkg.summaryparamarray, a0 out nocopy JTF_VARCHAR2_TABLE_200
    ) is
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
          a0(indx) := t(ddindx).standard;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p2;

  procedure rosetta_table_copy_in_p3(t out nocopy qa_audit_pkg.catsummaryparamarray, a0 JTF_VARCHAR2_TABLE_200
    , a1 JTF_VARCHAR2_TABLE_200
    , a2 JTF_VARCHAR2_TABLE_200
    , a3 JTF_VARCHAR2_TABLE_200
    ) is
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count > 0 then
      if a0.count > 0 then
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).standard := a0(indx);
          t(ddindx).section := a1(indx);
          t(ddindx).area := a2(indx);
          t(ddindx).category := a3(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p3;
  procedure rosetta_table_copy_out_p3(t qa_audit_pkg.catsummaryparamarray, a0 out nocopy JTF_VARCHAR2_TABLE_200
    , a1 out nocopy JTF_VARCHAR2_TABLE_200
    , a2 out nocopy JTF_VARCHAR2_TABLE_200
    , a3 out nocopy JTF_VARCHAR2_TABLE_200
    ) is
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_200();
    a1 := JTF_VARCHAR2_TABLE_200();
    a2 := JTF_VARCHAR2_TABLE_200();
    a3 := JTF_VARCHAR2_TABLE_200();
  else
      a0 := JTF_VARCHAR2_TABLE_200();
      a1 := JTF_VARCHAR2_TABLE_200();
      a2 := JTF_VARCHAR2_TABLE_200();
      a3 := JTF_VARCHAR2_TABLE_200();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        a2.extend(t.count);
        a3.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).standard;
          a1(indx) := t(ddindx).section;
          a2(indx) := t(ddindx).area;
          a3(indx) := t(ddindx).category;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p3;

  procedure copy_questions(p_audit_bank_plan_id  NUMBER
    , p_audit_bank_org_id  NUMBER
    , p2_a0 JTF_VARCHAR2_TABLE_200
    , p3_a0 JTF_VARCHAR2_TABLE_200
    , p3_a1 JTF_VARCHAR2_TABLE_200
    , p3_a2 JTF_VARCHAR2_TABLE_200
    , p3_a3 JTF_VARCHAR2_TABLE_200
    , p_audit_question_plan_id  NUMBER
    , p_audit_question_org_id  NUMBER
    , p_audit_num  VARCHAR2
    , x_count out nocopy  NUMBER
    , x_msg_count out nocopy  NUMBER
    , x_msg_data out nocopy  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
  )

  is
    ddp_summary_params qa_audit_pkg.summaryparamarray;
    ddp_cat_summary_params qa_audit_pkg.catsummaryparamarray;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any


    qa_audit_pkg_w.rosetta_table_copy_in_p2(ddp_summary_params, p2_a0
      );

    qa_audit_pkg_w.rosetta_table_copy_in_p3(ddp_cat_summary_params, p3_a0
      , p3_a1
      , p3_a2
      , p3_a3
      );








    -- here's the delegated call to the old PL/SQL routine
    qa_audit_pkg.copy_questions(p_audit_bank_plan_id,
      p_audit_bank_org_id,
      ddp_summary_params,
      ddp_cat_summary_params,
      p_audit_question_plan_id,
      p_audit_question_org_id,
      p_audit_num,
      x_count,
      x_msg_count,
      x_msg_data,
      x_return_status);

    -- copy data back from the local variables to OUT or IN-OUT args, if any










  end;

end qa_audit_pkg_w;

/
