--------------------------------------------------------
--  DDL for Package Body JTS_CONFIG_UTIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTS_CONFIG_UTIL_PVT" as
/* $Header: jtsvcutb.pls 115.1 2002/04/10 18:10:16 pkm ship    $ */


-- --------------------------------------------------------------------
-- Package name     : JTS_CONFIG_UTIL_PVT
-- Purpose          : Utilities Package.
-- History          : 25-Feb-02  Sung Ha Huh  Created.
-- NOTE             :
-- --------------------------------------------------------------------

-- Opens the Versions cursor with its Select.
PROCEDURE GET_VERSIONS_CURSOR(p_api_version	IN  Number,
   		p_config_id			IN  Number,
		x_versions_csr 			OUT NOCOPY Versions_Csr_Type)
IS
   l_api_version   CONSTANT NUMBER        := 1.0;
   l_api_name      CONSTANT VARCHAR2 (30) := 'GET_VERSIONS_CURSOR';
BEGIN
OPEN x_versions_csr FOR
SELECT  version_id
FROM    jts_config_versions_b
WHERE	  configuration_id = p_config_id;

EXCEPTION
   WHEN OTHERS THEN
	APP_EXCEPTION.RAISE_EXCEPTION;
END GET_VERSIONS_CURSOR;


END JTS_CONFIG_UTIL_PVT;

/
