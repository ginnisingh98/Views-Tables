--------------------------------------------------------
--  DDL for Package Body MSD_AW_LOADER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSD_AW_LOADER" AS
/* $Header: msdawldb.pls 120.2 2005/11/02 11:41 ziahmed noship $ */

/* Public Procedures */

procedure attach_code_aw is
begin
  -- attach ODPCODE rw, create it if it does not exist
  -- dbms_aw.execute('awwaittime = 1000000; &(if aw(attached ''ODPCODE'') then ''shw NA'' else ''aw attach ODPCODE rw wait'')');
  dbms_aw.AW_ATTACH('ODPCODE',true,true,'wait');
end attach_code_aw;

procedure update_code_aw is
begin
  -- Issue an update if _noupdate flag is not set
  dbms_aw.execute('&(if exists(''_noupdate'') then ''shw na'' else ''upd'')');
end update_code_aw;

END MSD_AW_LOADER;

/
