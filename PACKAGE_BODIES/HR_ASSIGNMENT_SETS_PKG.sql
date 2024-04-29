--------------------------------------------------------
--  DDL for Package Body HR_ASSIGNMENT_SETS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_ASSIGNMENT_SETS_PKG" as
/* $Header: pyass01t.pkb 115.0 99/07/17 05:43:21 porting ship $ */
--
  procedure insert_row(p_rowid             in out varchar2,
                       p_assignment_set_id     in number,
                       p_business_group_id     in number,
                       p_payroll_id            in number,
                       p_assignment_set_name   in varchar2,
                       p_formula_id            in number) is

  --
  begin
  --
    insert into HR_ASSIGNMENT_SETS
         ( ASSIGNMENT_SET_ID,
           BUSINESS_GROUP_ID,
           PAYROLL_ID,
           ASSIGNMENT_SET_NAME,
           FORMULA_ID)
    values
         ( p_assignment_set_id,
           p_business_group_id,
           p_payroll_id,
           p_assignment_set_name,
           p_formula_id);

      --
    select rowid
    into   p_rowid
    from   HR_ASSIGNMENT_SETS
    where  ASSIGNMENT_SET_ID = p_assignment_set_id;
      --
  end insert_row;
--
  procedure update_row(p_rowid                 in varchar2,
                       p_assignment_set_id     in number,
                       p_business_group_id     in number,
                       p_payroll_id            in number,
                       p_assignment_set_name   in varchar2,
                       p_formula_id            in number) is

  begin
  --
    update HR_ASSIGNMENT_SETS
    set    ASSIGNMENT_SET_ID         = p_assignment_set_id,
           BUSINESS_GROUP_ID         = p_business_group_id,
           PAYROLL_ID                = p_payroll_id,
           ASSIGNMENT_SET_NAME       = p_assignment_set_name,
           FORMULA_ID                = p_formula_id
    where  ROWID = p_rowid;
  --
  end update_row;
--
  procedure delete_row(p_rowid   in varchar2) is
  --
  begin
  --
    delete from HR_ASSIGNMENT_SETS
    where  ROWID = p_rowid;
  --
  end delete_row;
--
  procedure lock_row(p_rowid                   in varchar2,
                       p_assignment_set_id     in number,
                       p_business_group_id     in number,
                       p_payroll_id            in number,
                       p_assignment_set_name   in varchar2,
                       p_formula_id            in number) is

  --
    cursor C is select *
                from   HR_ASSIGNMENT_SETS
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
    rowinfo.assignment_set_name := rtrim(rowinfo.assignment_set_name);
    --
    if (   (  (rowinfo.ASSIGNMENT_SET_ID         = p_assignment_set_id)
           or (rowinfo.ASSIGNMENT_SET_ID         is null and p_assignment_set_id         is null))
       and (  (rowinfo.BUSINESS_GROUP_ID         = p_business_group_id)
           or (rowinfo.BUSINESS_GROUP_ID         is null and p_business_group_id         is null))
       and (  (rowinfo.PAYROLL_ID                = p_payroll_id)
           or (rowinfo.PAYROLL_ID                is null and p_payroll_id                is null))
       and (  (rowinfo.ASSIGNMENT_SET_NAME       = p_assignment_set_name)
           or (rowinfo.ASSIGNMENT_SET_NAME       is null and p_assignment_set_name       is null))
       and (  (rowinfo.FORMULA_ID                = p_formula_id)
           or (rowinfo.FORMULA_ID                is null and p_formula_id
               is null))) then
       return;
    else
       fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
       app_exception.raise_exception;
    end if;
  end lock_row;
--
end HR_ASSIGNMENT_SETS_PKG;

/
