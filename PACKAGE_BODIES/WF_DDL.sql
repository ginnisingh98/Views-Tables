--------------------------------------------------------
--  DDL for Package Body WF_DDL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WF_DDL" as
  /* $Header: WFDDLB.pls 115.2 2002/10/28 19:06:19 rwunderl noship $ */

 PROCEDURE DropIndex (IndexName      IN    VARCHAR2,
                      Owner          IN    VARCHAR2,
                      IgnoreNotFound IN    BOOLEAN ) is

  IndexNotFound   EXCEPTION;
  pragma exception_init(IndexNotFound, -1418);

  BEGIN
    execute IMMEDIATE 'drop index '||owner||'.'||IndexName;

  EXCEPTION
    when IndexNotFound then
      if (IgnoreNotFound) then
        null;

      else
        raise;

      end if;

    when OTHERS then
      WF_CORE.Context('WF_DDL', 'DropIndex', IndexName, Owner);
      raise;

  end;

 PROCEDURE TruncateTable (TableName      IN     VARCHAR2,
                          Owner          IN     VARCHAR2,
                          IgnoreNotFound IN     BOOLEAN )  is

    tableNotFound EXCEPTION;
    pragma exception_init(tableNotFound, -942);

  BEGIN
    execute IMMEDIATE 'truncate table '||Owner||'.'||TableName;

  EXCEPTION
    when tableNotFound then
      if (IgnoreNotFound) then
        null;

      else
        raise;

      end if;

    when OTHERS then
      WF_CORE.Context('WF_DDL', 'TruncateTable', TableName, Owner);
      raise;

  END;

end WF_DDL;

/
