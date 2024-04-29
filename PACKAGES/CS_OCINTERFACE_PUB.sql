--------------------------------------------------------
--  DDL for Package CS_OCINTERFACE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CS_OCINTERFACE_PUB" AUTHID CURRENT_USER AS
/* $Header: csocints.pls 115.4 2001/11/26 17:42:35 pkm ship      $ */

-- ---------------------------------------------------------
-- Define global variables
-- ---------------------------------------------------------
G_PKG_NAME	CONSTANT VARCHAR2(30) := 'CS_OCInterface_PUB';
--G_USER 		CONSTANT VARCHAR2(30) := FND_GLOBAL.USER_ID;
-- ---------------------------------------------------------

-- ---------------------------------------------------------
-- Define public procedures
-- ---------------------------------------------------------

PROCEDURE Populate_InstalledBase
(
	ERRBUF	OUT VARCHAR2,
	RETCODE	OUT NUMBER
);

End CS_OCInterface_PUB;

 

/
