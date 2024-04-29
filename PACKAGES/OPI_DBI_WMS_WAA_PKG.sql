--------------------------------------------------------
--  DDL for Package OPI_DBI_WMS_WAA_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OPI_DBI_WMS_WAA_PKG" AUTHID CURRENT_USER AS
/* $Header: OPIDEWMSWAAS.pls 120.0 2005/05/24 18:41:02 appldev noship $ */
PROCEDURE initial_load(errbuf      IN OUT NOCOPY VARCHAR2
                      ,retcode     IN OUT NOCOPY VARCHAR2);
--
PROCEDURE incremental_load(errbuf      IN OUT NOCOPY VARCHAR2
                          ,retcode     IN OUT NOCOPY VARCHAR2);
END opi_dbi_wms_waa_pkg;

 

/
