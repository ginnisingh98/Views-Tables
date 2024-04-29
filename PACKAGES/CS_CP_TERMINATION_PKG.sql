--------------------------------------------------------
--  DDL for Package CS_CP_TERMINATION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CS_CP_TERMINATION_PKG" AUTHID CURRENT_USER AS
/* $Header: csxcpsts.pls 115.0 2000/02/01 16:34:32 pkm ship    $ */

PROCEDURE Update_CP_Term_Status
(
	errbuf	OUT	VARCHAR2,
	retcode	OUT	NUMBER
);

END CS_CP_Termination_PKG;

 

/
