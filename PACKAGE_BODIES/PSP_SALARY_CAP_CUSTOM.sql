--------------------------------------------------------
--  DDL for Package Body PSP_SALARY_CAP_CUSTOM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSP_SALARY_CAP_CUSTOM" as
/* $Header: PSPSCCSB.pls 120.0 2005/06/02 16:00 appldev noship $ */
begin
  --- set the below variable to attribute name that contains the
  --- funding_source_id, for example if ATTRIBUTE1 has the id, then
  --- set g_parent_sponsor_field := 'ATTRIBUTE1';
g_parent_sponsor_field := null;
end;

/
