--------------------------------------------------------
--  DDL for Package Body INVTRMQT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INVTRMQT" as
/* $Header: INVTRMQB.pls 120.1 2005/07/01 13:19:21 appldev ship $ */

  PROCEDURE delete_rows is
begin
  delete from mtl_org_report_temp;
  if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
commit;
end;
end INVTRMQT;

/
