--------------------------------------------------------
--  DDL for Package Body EDR_QUERY_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EDR_QUERY_UTIL" as
/* $Header: EDRGQRYB.pls 120.0.12000000.1 2007/01/18 05:53:51 appldev ship $ */
procedure GET_CLOB (pkval in number, p_load out NOCOPY VARCHAR2)
IS
  p_clob CLOB;
BEGIN
  return;
END GET_CLOB;

procedure GET_LENGTH (pkval in number, len out NOCOPY number)
IS
  p_clob CLOB;
BEGIN
 return;
END GET_LENGTH;


procedure GET_CLOB (pkval in number, p_size in number,
                    p_offset in number, p_load out NOCOPY VARCHAR2)
IS
  p_clob CLOB;
BEGIN
 return;
END GET_CLOB;

procedure ALTER_INDEX (p_tag in VARCHAR2, p_section in VARCHAR2)
AS
BEGIN
 return;
END ALTER_INDEX;

end EDR_QUERY_UTIL;

/
