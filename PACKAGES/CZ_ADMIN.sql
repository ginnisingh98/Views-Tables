--------------------------------------------------------
--  DDL for Package CZ_ADMIN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CZ_ADMIN" AUTHID CURRENT_USER AS
/*	$Header: czcadmns.pls 115.13 2004/03/01 18:47:59 sselahi ship $		  */

IMP_ACTIVE_SESSION_EXISTS     EXCEPTION;
IMP_UNEXP_SQL_ERROR           EXCEPTION;
IMP_MAXERR_REACHED            EXCEPTION;
IMP_MODEL_NOT_FOUND           EXCEPTION;
IMP_TOO_MANY_SERVERS          EXCEPTION;
IMP_NO_IMP_SERVER             EXCEPTION;
IMP_LINK_IS_DOWN              EXCEPTION;
CZ_LANGUAGES_DO_NOT_MATCH     EXCEPTION;

PROCEDURE VALIDATE_END_USERS;

PROCEDURE ENABLE_END_USERS;

PROCEDURE SPX_WAIT(nSeconds IN NUMBER DEFAULT 0);

PROCEDURE SPX_SYNC_IMPORTSESSIONS;

PROCEDURE SPX_SYNC_PUBLISHSESSIONS;

END CZ_ADMIN;

 

/