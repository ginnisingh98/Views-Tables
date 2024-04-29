--------------------------------------------------------
--  DDL for Package Body QP_PERF_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QP_PERF_PVT" AS
/* $Header: QPXVPERB.pls 120.0 2005/06/02 00:12:49 appldev noship $ */

function enabled return varchar2
is
begin
if QP_CODE_CONTROL.Get_Code_Release_Level >= 110509 then
	return 'Y';
else
	return 'N';
end if;
end;

end QP_PERF_PVT;

/
