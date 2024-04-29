--------------------------------------------------------
--  DDL for Package CS_PURGE_KM_SESSION_ATTRS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CS_PURGE_KM_SESSION_ATTRS_PKG" AUTHID CURRENT_USER AS
/* $Header: cskbsars.pls 120.1 2005/06/22 12:04:42 appldev ship $ */
PROCEDURE start_program( ERRBUF OUT NOCOPY VARCHAR2, RETCODE OUT NOCOPY VARCHAR2, DATE_OFFSET IN NUMBER :=1);
END CS_PURGE_KM_SESSION_ATTRS_PKG;

 

/
