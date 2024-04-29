--------------------------------------------------------
--  DDL for Package FII_CCC_SEC_UPL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FII_CCC_SEC_UPL_PKG" AUTHID CURRENT_USER AS
/* $Header: FIICCCSECS.pls 120.0.12000000.1 2007/04/12 21:43:39 lpoon ship $ */

PROCEDURE dbg(text IN VARCHAR2);

FUNCTION web_adi_upload (
			 x_grantee_name       IN  VARCHAR2 DEFAULT NULL,
			 --x_grantee_key        IN  VARCHAR2 DEFAULT NULL,
			 x_role_name          IN  VARCHAR2 DEFAULT NULL,
			 x_start_date         IN  DATE     DEFAULT NULL,
			 x_end_date           IN  DATE     DEFAULT NULL,
			 x_dimension_code     IN  VARCHAR2 DEFAULT NULL,
			 x_dimension_value    IN  VARCHAR2 DEFAULT NULL
			 ) return VARCHAR2;

PROCEDURE conc_upload
  (
   errbuf	OUT NOCOPY VARCHAR2,
   retcode	OUT NOCOPY VARCHAR2);

PROCEDURE purge_interface
  (
   errbuf	OUT NOCOPY VARCHAR2,
   retcode	OUT NOCOPY VARCHAR2);

END FII_CCC_SEC_UPL_PKG;


 

/
