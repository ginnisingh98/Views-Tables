--------------------------------------------------------
--  DDL for Package JTF_PF_SOA_MIGRATE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_PF_SOA_MIGRATE_PKG" AUTHID CURRENT_USER AS
/* $Header: jtfpfsoamgrtpkgs.pls 120.1 2005/07/02 00:54:00 appldev noship $ */
	PROCEDURE MIGRATE_LOGINS_DATA(timezone_offset IN NUMBER);
	PROCEDURE MIGRATE_RESP_DATA(timezone_offset IN NUMBER);
	PROCEDURE MIGRATE_FORMS_DATA(timezone_offset IN NUMBER);
END JTF_PF_SOA_MIGRATE_PKG;

 

/
