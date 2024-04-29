--------------------------------------------------------
--  DDL for Package IEO_SVR_LOCATOR_ADMIN_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEO_SVR_LOCATOR_ADMIN_PVT" AUTHID CURRENT_USER AS
/* $Header: IEOSVRAS.pls 115.7 2003/01/02 17:10:16 dolee ship $ */

--
-- Package name:	IEO_SVR_LOCATOR_ADMIN_PVT
-- Filename:		IEOSVRAS.pls
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
procedure nop;


END;

 

/
