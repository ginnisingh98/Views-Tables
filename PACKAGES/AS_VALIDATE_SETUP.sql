--------------------------------------------------------
--  DDL for Package AS_VALIDATE_SETUP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AS_VALIDATE_SETUP" AUTHID CURRENT_USER as
/* $Header: asxsetvs.pls 120.5 2006/09/01 09:49:36 mohali noship $ */

PROCEDURE Validate_Setup(
	ERRBUF	 OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
	RETCODE	 OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
	p_upgrade	IN VARCHAR2
);

END AS_VALIDATE_SETUP;

 

/
