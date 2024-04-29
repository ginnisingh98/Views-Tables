--------------------------------------------------------
--  DDL for Package Body IEO_SVR_LOCATOR_ADMIN_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEO_SVR_LOCATOR_ADMIN_PVT" AS
/* $Header: IEOSVRAB.pls 115.7 2003/01/02 17:09:38 dolee ship $ */

--
-- Package name:	IEO_SVR_LOCATOR_ADMIN_PVT
-- Filename:		IEOSVRAB.pls
-- Package purpose:	Provides business rules for inserting, udating, and
--			deleting IEO sever location data in the IEO tables:
--			IEO_SVR_SERVERS
--			IEO_SVR_GROUPS
--			IEO_SVR_VALUES
--
--			This package is dependent upon having valid seeded data
--			in the following IEO tables:
--			IEO_SVR_TYPES_B
--			IEO_SVR_TYPES_TL
--			IEO_SVR_PARAMS
--


-- added simply to make package valid
-- ref. bug # 1271637
--
-- (RCARDILL 04-20-00)
--
procedure nop
  as
begin
  null;
end nop;


END;

/
