--------------------------------------------------------
--  DDL for Package JTS_CONFIG_UTIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTS_CONFIG_UTIL_PVT" AUTHID CURRENT_USER as
/* $Header: jtsvcuts.pls 115.1 2002/04/10 18:10:18 pkm ship    $ */


-----------------------------------------------------------
-- PACKAGE
--    JTS_CONFIG_UTIL_PVT
--
-- PURPOSE
--    Private API for Oracle Setup Online Configuration Management
--
-- PROCEDURES
--
------------------------------------------------------------

G_PKG_NAME      CONSTANT VARCHAR2(30)    := 'JTS_CONFIG_UTIL_PVT';
G_FILE_NAME     CONSTANT VARCHAR2(12)    := 'jtsvcutb.pls';

TYPE Versions_Csr_Type 	IS REF CURSOR;

-- Opens the Versions cursor with its Select.
PROCEDURE GET_VERSIONS_CURSOR(p_api_version	IN  NUMBER,
   		p_config_id			IN  NUMBER,
		x_versions_csr 			OUT NOCOPY Versions_Csr_Type);


END JTS_CONFIG_UTIL_PVT;

 

/
