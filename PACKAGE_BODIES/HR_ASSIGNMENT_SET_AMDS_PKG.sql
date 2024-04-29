--------------------------------------------------------
--  DDL for Package Body HR_ASSIGNMENT_SET_AMDS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_ASSIGNMENT_SET_AMDS_PKG" as
/* $Header: pyasm01t.pkb 115.0 99/07/17 05:43:14 porting ship $ */
--
  procedure insert_row(p_rowid                 in out varchar2,
                       p_assignment_id         in number,
                       p_assignment_set_id     in number,
                       p_include_or_exclude    in varchar2) is
  --
  begin
  --
    insert into HR_ASSIGNMENT_SET_AMENDMENTS
         ( ASSIGNMENT_ID,
           ASSIGNMENT_SET_ID,
           INCLUDE_OR_EXCLUDE)
    values
        (  p_assignment_id,
           p_assignment_set_id,
           p_include_or_exclude);
      --
      --
    select rowid
    into   p_rowid
    from   HR_ASSIGNMENT_SET_AMENDMENTS
    where  ASSIGNMENT_SET_ID = p_assignment_set_id
    and    ASSIGNMENT_ID     = p_assignment_id;
      --
  end insert_row;
--
  procedure update_row(p_rowid                 in varchar2,
                       p_assignment_id         in number,
                       p_assignment_set_id     in number,
                       p_include_or_exclude    in varchar2) is

  begin
  --
    update HR_ASSIGNMENT_SET_AMENDMENTS
    set    ASSIGNMENT_ID             = p_assignment_id,
           ASSIGNMENT_SET_ID         = p_assignment_set_id,
           INCLUDE_OR_EXCLUDE        = p_include_or_exclude
    where  ROWID = p_rowid;
  --
  end update_row;
--
  procedure delete_row(p_rowid   in varchar2) is
  --
  begin
  --
    delete from HR_ASSIGNMENT_SET_AMENDMENTS
    where  ROWID = p_rowid;
  --
  end delete_row;
--
  procedure lock_row(p_rowid                   in varchar2,
                       p_assignment_id         in number,
                       p_assignment_set_id     in number,
                       p_include_or_exclude    in varchar2) is
  --
    cursor C is select *
                from  HR_ASSIGNMENT_SET_AMENDMENTS
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
    rowinfo.INCLUDE_OR_EXCLUDE := rtrim(rowinfo.INCLUDE_OR_EXCLUDE);
    --
    if (   (  (rowinfo.ASSIGNMENT_SET_ID         = p_assignment_set_id)
           or (rowinfo.ASSIGNMENT_SET_ID         is null and p_assignment_set_id    is null))
       and (  (rowinfo.ASSIGNMENT_ID             = p_assignment_id)
           or (rowinfo.ASSIGNMENT_ID             is null and p_assignment_id        is null))
       and (  (rowinfo.INCLUDE_OR_EXCLUDE        = p_include_or_exclude)
           or (rowinfo.INCLUDE_OR_EXCLUDE        is null and p_include_or_exclude   is null))) then
      return;
    else
       fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
       app_exception.raise_exception;
    end if;
  end lock_row;
--
end HR_ASSIGNMENT_SET_AMDS_PKG;

/
