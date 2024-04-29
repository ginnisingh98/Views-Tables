--------------------------------------------------------
--  DDL for Package Body IBY_DISBURSE_UI_API_PUB_PKG_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBY_DISBURSE_UI_API_PUB_PKG_W" as
  /* $Header: ibydapiwb.pls 120.3.12010000.4 2010/05/20 13:01:36 gmaheswa ship $ */
  procedure rosetta_table_copy_in_p0(t out nocopy iby_disburse_ui_api_pub_pkg.docpayidtab, a0 JTF_NUMBER_TABLE) as
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
  procedure rosetta_table_copy_out_p0(t iby_disburse_ui_api_pub_pkg.docpayidtab, a0 out nocopy JTF_NUMBER_TABLE) as
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

  procedure rosetta_table_copy_in_p1(t out nocopy iby_disburse_ui_api_pub_pkg.docpaystatustab, a0 JTF_VARCHAR2_TABLE_100) as
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
  end rosetta_table_copy_in_p1;
  procedure rosetta_table_copy_out_p1(t iby_disburse_ui_api_pub_pkg.docpaystatustab, a0 out nocopy JTF_VARCHAR2_TABLE_100) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
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
  end rosetta_table_copy_out_p1;

  procedure rosetta_table_copy_in_p2(t out nocopy iby_disburse_ui_api_pub_pkg.pmtidtab, a0 JTF_NUMBER_TABLE) as
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
  end rosetta_table_copy_in_p2;
  procedure rosetta_table_copy_out_p2(t iby_disburse_ui_api_pub_pkg.pmtidtab, a0 out nocopy JTF_NUMBER_TABLE) as
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
  end rosetta_table_copy_out_p2;

  procedure rosetta_table_copy_in_p3(t out nocopy iby_disburse_ui_api_pub_pkg.pmtstatustab, a0 JTF_VARCHAR2_TABLE_100) as
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
  end rosetta_table_copy_in_p3;
  procedure rosetta_table_copy_out_p3(t iby_disburse_ui_api_pub_pkg.pmtstatustab, a0 out nocopy JTF_VARCHAR2_TABLE_100) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
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
  end rosetta_table_copy_out_p3;

  procedure rosetta_table_copy_in_p4(t out nocopy iby_disburse_ui_api_pub_pkg.pmtdocstab, a0 JTF_NUMBER_TABLE) as
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
  end rosetta_table_copy_in_p4;
  procedure rosetta_table_copy_out_p4(t iby_disburse_ui_api_pub_pkg.pmtdocstab, a0 out nocopy JTF_NUMBER_TABLE) as
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
  end rosetta_table_copy_out_p4;

  procedure rosetta_table_copy_in_p5(t out nocopy iby_disburse_ui_api_pub_pkg.paperdocnumtab, a0 JTF_NUMBER_TABLE) as
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
  end rosetta_table_copy_in_p5;
  procedure rosetta_table_copy_out_p5(t iby_disburse_ui_api_pub_pkg.paperdocnumtab, a0 out nocopy JTF_NUMBER_TABLE) as
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
  end rosetta_table_copy_out_p5;

  procedure rosetta_table_copy_in_p6(t out nocopy iby_disburse_ui_api_pub_pkg.paperdocusereasontab, a0 JTF_VARCHAR2_TABLE_100) as
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
  end rosetta_table_copy_in_p6;
  procedure rosetta_table_copy_out_p6(t iby_disburse_ui_api_pub_pkg.paperdocusereasontab, a0 out nocopy JTF_VARCHAR2_TABLE_100) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
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
  end rosetta_table_copy_out_p6;

  procedure rosetta_table_copy_in_p7(t out nocopy iby_disburse_ui_api_pub_pkg.appnamestab, a0 JTF_VARCHAR2_TABLE_100) as
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
  end rosetta_table_copy_in_p7;
  procedure rosetta_table_copy_out_p7(t iby_disburse_ui_api_pub_pkg.appnamestab, a0 out nocopy JTF_VARCHAR2_TABLE_100) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null or t.count = 0 then
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
  end rosetta_table_copy_out_p7;

  procedure rosetta_table_copy_in_p8(t out nocopy iby_disburse_ui_api_pub_pkg.appidstab, a0 JTF_NUMBER_TABLE) as
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
  procedure rosetta_table_copy_out_p8(t iby_disburse_ui_api_pub_pkg.appidstab, a0 out nocopy JTF_NUMBER_TABLE) as
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

  procedure remove_documents_payable(p_doc_list JTF_NUMBER_TABLE
    , p_doc_status_list JTF_VARCHAR2_TABLE_100
    , x_return_status out nocopy  VARCHAR2
  )

  as
    ddp_doc_list iby_disburse_ui_api_pub_pkg.docpayidtab;
    ddp_doc_status_list iby_disburse_ui_api_pub_pkg.docpaystatustab;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    iby_disburse_ui_api_pub_pkg_w.rosetta_table_copy_in_p0(ddp_doc_list, p_doc_list);

    iby_disburse_ui_api_pub_pkg_w.rosetta_table_copy_in_p1(ddp_doc_status_list, p_doc_status_list);


    -- here's the delegated call to the old PL/SQL routine
    iby_disburse_ui_api_pub_pkg.remove_documents_payable(ddp_doc_list,
      ddp_doc_status_list,
      x_return_status);

    -- copy data back from the local variables to OUT or IN-OUT args, if any


  end;

  procedure remove_payments(p_pmt_list JTF_NUMBER_TABLE
    , p_pmt_status_list JTF_VARCHAR2_TABLE_100
    , x_return_status out nocopy  VARCHAR2
  )

  as
    ddp_pmt_list iby_disburse_ui_api_pub_pkg.pmtidtab;
    ddp_pmt_status_list iby_disburse_ui_api_pub_pkg.pmtstatustab;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    iby_disburse_ui_api_pub_pkg_w.rosetta_table_copy_in_p2(ddp_pmt_list, p_pmt_list);

    iby_disburse_ui_api_pub_pkg_w.rosetta_table_copy_in_p3(ddp_pmt_status_list, p_pmt_status_list);


    -- here's the delegated call to the old PL/SQL routine
    iby_disburse_ui_api_pub_pkg.remove_payments(ddp_pmt_list,
      ddp_pmt_status_list,
      x_return_status);

    -- copy data back from the local variables to OUT or IN-OUT args, if any


  end;

  procedure stop_payments(p_pmt_list JTF_NUMBER_TABLE
    , p_pmt_status_list JTF_VARCHAR2_TABLE_100
    , x_return_status out nocopy  VARCHAR2
  )

  as
    ddp_pmt_list iby_disburse_ui_api_pub_pkg.pmtidtab;
    ddp_pmt_status_list iby_disburse_ui_api_pub_pkg.pmtstatustab;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any
    iby_disburse_ui_api_pub_pkg_w.rosetta_table_copy_in_p2(ddp_pmt_list, p_pmt_list);

    iby_disburse_ui_api_pub_pkg_w.rosetta_table_copy_in_p3(ddp_pmt_status_list, p_pmt_status_list);


    -- here's the delegated call to the old PL/SQL routine
    iby_disburse_ui_api_pub_pkg.stop_payments(ddp_pmt_list,
      ddp_pmt_status_list,
      x_return_status);

    -- copy data back from the local variables to OUT or IN-OUT args, if any


  end;

  procedure reprint_prenum_pmt_documents(p_instr_id  NUMBER
    , p_pmt_doc_id  NUMBER
    , p_pmt_list JTF_NUMBER_TABLE
    , p_new_ppr_docs_list JTF_NUMBER_TABLE
    , p_old_ppr_docs_list JTF_NUMBER_TABLE
    , p_printer_name  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
  )

  as
    ddp_pmt_list iby_disburse_ui_api_pub_pkg.pmtidtab;
    ddp_new_ppr_docs_list iby_disburse_ui_api_pub_pkg.pmtdocstab;
    ddp_old_ppr_docs_list iby_disburse_ui_api_pub_pkg.pmtdocstab;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any


    iby_disburse_ui_api_pub_pkg_w.rosetta_table_copy_in_p2(ddp_pmt_list, p_pmt_list);

    iby_disburse_ui_api_pub_pkg_w.rosetta_table_copy_in_p4(ddp_new_ppr_docs_list, p_new_ppr_docs_list);

    iby_disburse_ui_api_pub_pkg_w.rosetta_table_copy_in_p4(ddp_old_ppr_docs_list, p_old_ppr_docs_list);



    -- here's the delegated call to the old PL/SQL routine
    iby_disburse_ui_api_pub_pkg.reprint_prenum_pmt_documents(p_instr_id,
      p_pmt_doc_id,
      ddp_pmt_list,
      ddp_new_ppr_docs_list,
      ddp_old_ppr_docs_list,
      p_printer_name,
      x_return_status);

    -- copy data back from the local variables to OUT or IN-OUT args, if any






  end;

  procedure reprint_blank_pmt_documents(p_instr_id  NUMBER
    , p_pmt_list JTF_NUMBER_TABLE
    , p_printer_name  VARCHAR2
    , x_return_status out nocopy  VARCHAR2
  )

  as
    ddp_pmt_list iby_disburse_ui_api_pub_pkg.pmtidtab;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    iby_disburse_ui_api_pub_pkg_w.rosetta_table_copy_in_p2(ddp_pmt_list, p_pmt_list);



    -- here's the delegated call to the old PL/SQL routine
    iby_disburse_ui_api_pub_pkg.reprint_blank_pmt_documents(p_instr_id,
      ddp_pmt_list,
      p_printer_name,
      x_return_status);

    -- copy data back from the local variables to OUT or IN-OUT args, if any



  end;

  procedure finalize_print_status(p_instr_id  NUMBER
    , p_pmt_doc_id  NUMBER
    , p_used_docs_list JTF_NUMBER_TABLE
    , x_return_status out nocopy  VARCHAR2
  )

  as
    ddp_used_docs_list iby_disburse_ui_api_pub_pkg.paperdocnumtab;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any


    iby_disburse_ui_api_pub_pkg_w.rosetta_table_copy_in_p5(ddp_used_docs_list, p_used_docs_list);


    -- here's the delegated call to the old PL/SQL routine
    iby_disburse_ui_api_pub_pkg.finalize_print_status(p_instr_id,
      p_pmt_doc_id,
      ddp_used_docs_list,
      x_return_status);

    -- copy data back from the local variables to OUT or IN-OUT args, if any



  end;

  procedure finalize_print_status(p_instr_id  NUMBER
    , p_pmt_doc_id  NUMBER
    , p_used_docs_list JTF_NUMBER_TABLE
    , p_used_pmts_list JTF_NUMBER_TABLE
    , p_submit_postive_pay  number
    , x_return_status out nocopy  VARCHAR2
  )

  as
    ddp_used_docs_list iby_disburse_ui_api_pub_pkg.paperdocnumtab;
    ddp_used_pmts_list iby_disburse_ui_api_pub_pkg.paperdocnumtab;
    ddp_submit_postive_pay boolean;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any


    iby_disburse_ui_api_pub_pkg_w.rosetta_table_copy_in_p5(ddp_used_docs_list, p_used_docs_list);
    iby_disburse_ui_api_pub_pkg_w.rosetta_table_copy_in_p5(ddp_used_pmts_list, p_used_pmts_list);

    if p_submit_postive_pay is null
      then ddp_submit_postive_pay := null;
    elsif p_submit_postive_pay = 0
      then ddp_submit_postive_pay := false;
    else ddp_submit_postive_pay := true;
    end if;


    -- here's the delegated call to the old PL/SQL routine
    iby_disburse_ui_api_pub_pkg.finalize_print_status(p_instr_id,
      p_pmt_doc_id,
      ddp_used_docs_list,
      ddp_used_pmts_list,
      ddp_submit_postive_pay,
      x_return_status);

    -- copy data back from the local variables to OUT or IN-OUT args, if any


  end;
  procedure finalize_print_status(p_instr_id  NUMBER
    , p_pmt_doc_id  NUMBER
    , p_used_docs_list JTF_NUMBER_TABLE
    , p_used_pmts_list JTF_NUMBER_TABLE
    , p_skipped_docs_list JTF_NUMBER_TABLE
    , p_submit_postive_pay  number
    , x_return_status out nocopy  VARCHAR2
  )
  as
    ddp_used_docs_list iby_disburse_ui_api_pub_pkg.paperdocnumtab;
    ddp_used_pmts_list iby_disburse_ui_api_pub_pkg.paperdocnumtab;
    ddp_skipped_docs_list iby_disburse_ui_api_pub_pkg.paperdocnumtab;
    ddp_submit_postive_pay boolean;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any


    iby_disburse_ui_api_pub_pkg_w.rosetta_table_copy_in_p5(ddp_used_docs_list, p_used_docs_list);
    iby_disburse_ui_api_pub_pkg_w.rosetta_table_copy_in_p5(ddp_used_pmts_list, p_used_pmts_list);
    iby_disburse_ui_api_pub_pkg_w.rosetta_table_copy_in_p5(ddp_skipped_docs_list, p_skipped_docs_list);

    if p_submit_postive_pay is null
      then ddp_submit_postive_pay := null;
    elsif p_submit_postive_pay = 0
      then ddp_submit_postive_pay := false;
    else ddp_submit_postive_pay := true;
    end if;


    -- here's the delegated call to the old PL/SQL routine
    iby_disburse_ui_api_pub_pkg.finalize_print_status(p_instr_id,
      p_pmt_doc_id,
      ddp_used_docs_list,
      ddp_used_pmts_list,
      ddp_skipped_docs_list,
      ddp_submit_postive_pay,
      x_return_status);

    -- copy data back from the local variables to OUT or IN-OUT args, if any


  end;

  procedure finalize_instr_print_status(p_instr_id  NUMBER
    , p_submit_postive_pay  number
    , x_return_status out nocopy  VARCHAR2
  )

  as
    ddp_submit_postive_pay boolean;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    if p_submit_postive_pay is null
      then ddp_submit_postive_pay := null;
    elsif p_submit_postive_pay = 0
      then ddp_submit_postive_pay := false;
    else ddp_submit_postive_pay := true;
    end if;


    -- here's the delegated call to the old PL/SQL routine
    iby_disburse_ui_api_pub_pkg.finalize_instr_print_status(p_instr_id,
      ddp_submit_postive_pay,
      x_return_status);

    -- copy data back from the local variables to OUT or IN-OUT args, if any


  end;

  procedure mark_all_pmts_complete(p_instr_id  NUMBER
    , p_submit_postive_pay  number
    , x_return_status out nocopy  VARCHAR2
  )

  as
    ddp_submit_postive_pay boolean;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    if p_submit_postive_pay is null
      then ddp_submit_postive_pay := null;
    elsif p_submit_postive_pay = 0
      then ddp_submit_postive_pay := false;
    else ddp_submit_postive_pay := true;
    end if;


    -- here's the delegated call to the old PL/SQL routine
    iby_disburse_ui_api_pub_pkg.mark_all_pmts_complete(p_instr_id,
      ddp_submit_postive_pay,
      x_return_status);

    -- copy data back from the local variables to OUT or IN-OUT args, if any


  end;

  procedure checkifdocused(p_paper_doc_num  NUMBER
    , p_pmt_document_id  NUMBER
    , ddrosetta_retval_bool OUT NOCOPY NUMBER
  )

  as
    ddindx binary_integer; indx binary_integer;
    ddrosetta_retval boolean;
  begin

    -- copy data to the local IN or IN-OUT args, if any


    -- here's the delegated call to the old PL/SQL routine
    ddrosetta_retval := iby_disburse_ui_api_pub_pkg.checkifdocused(p_paper_doc_num,
      p_pmt_document_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any
    if ddrosetta_retval is null
      then ddrosetta_retval_bool := null;
    elsif ddrosetta_retval
      then ddrosetta_retval_bool := 1;
    else ddrosetta_retval_bool := 0;
    end if;

  end;

  procedure checkifallpmtsterminated(p_instr_id  NUMBER
    , ddrosetta_retval_bool OUT NOCOPY NUMBER
  )

  as
    ddindx binary_integer; indx binary_integer;
    ddrosetta_retval boolean;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    -- here's the delegated call to the old PL/SQL routine
    ddrosetta_retval := iby_disburse_ui_api_pub_pkg.checkifallpmtsterminated(p_instr_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any
    if ddrosetta_retval is null
      then ddrosetta_retval_bool := null;
    elsif ddrosetta_retval
      then ddrosetta_retval_bool := 1;
    else ddrosetta_retval_bool := 0;
    end if;
  end;

  procedure checkifpmtininstexists(p_payreq_id  NUMBER
    , ddrosetta_retval_bool OUT NOCOPY NUMBER
  )

  as
    ddindx binary_integer; indx binary_integer;
    ddrosetta_retval boolean;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    -- here's the delegated call to the old PL/SQL routine
    ddrosetta_retval := iby_disburse_ui_api_pub_pkg.checkifpmtininstexists(p_payreq_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any
    if ddrosetta_retval is null
      then ddrosetta_retval_bool := null;
    elsif ddrosetta_retval
      then ddrosetta_retval_bool := 1;
    else ddrosetta_retval_bool := 0;
    end if;
  end;

  procedure checkifinstrxmitoutsidesystem(p_instr_id  NUMBER
    , ddrosetta_retval_bool OUT NOCOPY NUMBER
  )

  as
    ddindx binary_integer; indx binary_integer;
    ddrosetta_retval boolean;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    -- here's the delegated call to the old PL/SQL routine
    ddrosetta_retval := iby_disburse_ui_api_pub_pkg.checkifinstrxmitoutsidesystem(p_instr_id);

    -- copy data back from the local variables to OUT or IN-OUT args, if any
    if ddrosetta_retval is null
      then ddrosetta_retval_bool := null;
    elsif ddrosetta_retval
      then ddrosetta_retval_bool := 1;
    else ddrosetta_retval_bool := 0;
    end if;
  end;

  procedure checkifpmtentitylocked(p_object_id  NUMBER
    , p_object_type  VARCHAR2
    , ddrosetta_retval_bool OUT NOCOPY NUMBER
  )

  as
    ddindx binary_integer; indx binary_integer;
    ddrosetta_retval boolean;
  begin

    -- copy data to the local IN or IN-OUT args, if any


    -- here's the delegated call to the old PL/SQL routine
    ddrosetta_retval := iby_disburse_ui_api_pub_pkg.checkifpmtentitylocked(p_object_id,
      p_object_type);

    -- copy data back from the local variables to OUT or IN-OUT args, if any
    if ddrosetta_retval is null
      then ddrosetta_retval_bool := null;
    elsif ddrosetta_retval
      then ddrosetta_retval_bool := 1;
    else ddrosetta_retval_bool := 0;
    end if;

  end;

end iby_disburse_ui_api_pub_pkg_w;

/
