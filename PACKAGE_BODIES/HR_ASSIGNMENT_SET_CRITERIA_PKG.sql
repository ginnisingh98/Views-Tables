--------------------------------------------------------
--  DDL for Package Body HR_ASSIGNMENT_SET_CRITERIA_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_ASSIGNMENT_SET_CRITERIA_PKG" as
/* $Header: pyasc01t.pkb 115.0 99/07/17 05:42:46 porting ship $ */
--
  procedure insert_row(p_rowid             in out varchar2,
                       p_line_no               in number,
                       p_assignment_set_id     in number,
                       p_left_operand          in varchar2,
                       p_operator              in varchar2,
                       p_right_operand         in varchar2,
                       p_logical               in varchar2) is

  --
  begin
  --
    insert into HR_ASSIGNMENT_SET_CRITERIA
         ( LINE_NO,
           ASSIGNMENT_SET_ID,
           LEFT_OPERAND,
           OPERATOR,
           RIGHT_OPERAND,
           LOGICAL)
    values
        (  p_line_no,
           p_assignment_set_id,
           p_left_operand,
           p_operator,
           p_right_operand,
           p_logical);
      --
      --
    select rowid
    into   p_rowid
    from   HR_ASSIGNMENT_SET_CRITERIA
    where  ASSIGNMENT_SET_ID = p_assignment_set_id
    and    LINE_NO           = p_line_no;
      --
  end insert_row;
--
  procedure update_row(p_rowid                 in varchar2,
                       p_line_no               in number,
                       p_assignment_set_id     in number,
                       p_left_operand          in varchar2,
                       p_operator              in varchar2,
                       p_right_operand         in varchar2,
                       p_logical               in varchar2) is

  begin
  --
    update HR_ASSIGNMENT_SET_CRITERIA
    set    LINE_NO                   = p_line_no,
           ASSIGNMENT_SET_ID         = p_assignment_set_id,
           LEFT_OPERAND              = p_left_operand,
           OPERATOR                  = p_operator,
           RIGHT_OPERAND             = p_right_operand,
           LOGICAL                   = p_logical
    where  ROWID = p_rowid;
  --
  end update_row;
--
  procedure delete_row(p_rowid   in varchar2) is
  --
  begin
  --
    delete from HR_ASSIGNMENT_SET_CRITERIA
    where  ROWID = p_rowid;
  --
  end delete_row;
--
  procedure lock_row(p_rowid                   in varchar2,
                       p_line_no               in number,
                       p_assignment_set_id     in number,
                       p_left_operand          in varchar2,
                       p_operator              in varchar2,
                       p_right_operand         in varchar2,
                       p_logical               in varchar2) is

  --
    cursor C is select *
                from  HR_ASSIGNMENT_SET_CRITERIA
                where  rowid = p_rowid
                for update of ASSIGNMENT_SET_ID nowait;
  --
    rowinfo  C%rowtype;
  --
  begin
  --
    open C;
    fetch C into rowinfo;
    close C;
    --
    rowinfo.left_operand  := rtrim(rowinfo.left_operand);
    rowinfo.operator      := rtrim(rowinfo.operator);
    rowinfo.right_operand := rtrim(rowinfo.right_operand);
    rowinfo.logical       := rtrim(rowinfo.logical);
    --
    if (   (  (rowinfo.ASSIGNMENT_SET_ID         = p_assignment_set_id)
           or (rowinfo.ASSIGNMENT_SET_ID         is null and p_assignment_set_id    is null))
       and (  (rowinfo.LEFT_OPERAND              = p_left_operand)
           or (rowinfo.LEFT_OPERAND              is null and p_left_operand         is null))
       and (  (rowinfo.OPERATOR                  = p_operator)
           or (rowinfo.OPERATOR                  is null and p_operator             is null))
       and (  (rowinfo.RIGHT_OPERAND             = p_right_operand)
           or (rowinfo.RIGHT_OPERAND             is null and p_right_operand        is null))
       and (  (rowinfo.LOGICAL                   = p_logical)
           or (rowinfo.LOGICAL                   is null and p_logical              is null))) then
      return;

    else
       fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
       app_exception.raise_exception;
    end if;
  end lock_row;
--
end HR_ASSIGNMENT_SET_CRITERIA_PKG;

/
