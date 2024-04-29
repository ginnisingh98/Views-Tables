--------------------------------------------------------
--  DDL for Package Body FUN_SEQ_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FUN_SEQ_W" as
  /* $Header: fun_seq_wb.pls 120.0 2003/09/11 21:30:17 masada noship $ */
  procedure rosetta_table_copy_in_p1(t out nocopy fun_seq.control_date_tbl_type, a0 JTF_VARCHAR2_TABLE_100
    , a1 JTF_DATE_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if a0 is not null and a0.count=0 then
    t := fun_seq.control_date_tbl_type();
  elsif a0 is not null and a0.count > 0 then
      if a0.count > 0 then
      t := fun_seq.control_date_tbl_type();
      t.extend(a0.count);
        indx := a0.first;
        ddindx := 1;
        while true loop
          t(ddindx).date_type := a0(indx);
          t(ddindx).date_value := a1(indx);
          ddindx := ddindx+1;
          if a0.last =indx
            then exit;
          end if;
          indx := a0.next(indx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_in_p1;
  procedure rosetta_table_copy_out_p1(t fun_seq.control_date_tbl_type, a0 out nocopy JTF_VARCHAR2_TABLE_100
    , a1 out nocopy JTF_DATE_TABLE
    ) as
    ddindx binary_integer; indx binary_integer;
  begin
  if t is null then
    a0 := null;
    a1 := null;
  elsif t.count = 0 then
    a0 := JTF_VARCHAR2_TABLE_100();
    a1 := JTF_DATE_TABLE();
  else
      a0 := JTF_VARCHAR2_TABLE_100();
      a1 := JTF_DATE_TABLE();
      if t.count > 0 then
        a0.extend(t.count);
        a1.extend(t.count);
        ddindx := t.first;
        indx := 1;
        while true loop
          a0(indx) := t(ddindx).date_type;
          a1(indx) := t(ddindx).date_value;
          indx := indx+1;
          if t.last =ddindx
            then exit;
          end if;
          ddindx := t.next(ddindx);
        end loop;
      end if;
   end if;
  end rosetta_table_copy_out_p1;

  procedure get_sequence_number(p_context_type  VARCHAR2
    , p_context_value  VARCHAR2
    , p_application_id  NUMBER
    , p_table_name  VARCHAR2
    , p_event_code  VARCHAR2
    , p5_a0  VARCHAR2
    , p5_a1  VARCHAR2
    , p5_a2  VARCHAR2
    , p5_a3  VARCHAR2
    , p5_a4  VARCHAR2
    , p5_a5  VARCHAR2
    , p6_a0 JTF_VARCHAR2_TABLE_100
    , p6_a1 JTF_DATE_TABLE
    , p_suppress_error  VARCHAR2
    , x_seq_version_id out nocopy  NUMBER
    , x_sequence_number out nocopy  NUMBER
    , x_assignment_id out nocopy  NUMBER
    , x_error_code out nocopy  VARCHAR2
  )

  as
    ddp_control_attribute_rec fun_seq.control_attribute_rec_type;
    ddp_control_date_tbl fun_seq.control_date_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any





    ddp_control_attribute_rec.balance_type := p5_a0;
    ddp_control_attribute_rec.journal_source := p5_a1;
    ddp_control_attribute_rec.journal_category := p5_a2;
    ddp_control_attribute_rec.document_category := p5_a3;
    ddp_control_attribute_rec.accounting_event_type := p5_a4;
    ddp_control_attribute_rec.accounting_entry_type := p5_a5;

    fun_seq_w.rosetta_table_copy_in_p1(ddp_control_date_tbl, p6_a0
      , p6_a1
      );






    -- here's the delegated call to the old PL/SQL routine
    fun_seq.get_sequence_number(p_context_type,
      p_context_value,
      p_application_id,
      p_table_name,
      p_event_code,
      ddp_control_attribute_rec,
      ddp_control_date_tbl,
      p_suppress_error,
      x_seq_version_id,
      x_sequence_number,
      x_assignment_id,
      x_error_code);

    -- copy data back from the local variables to OUT or IN-OUT args, if any











  end;

end fun_seq_w;

/
