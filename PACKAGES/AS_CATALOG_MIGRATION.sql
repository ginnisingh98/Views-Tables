--------------------------------------------------------
--  DDL for Package AS_CATALOG_MIGRATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AS_CATALOG_MIGRATION" AUTHID CURRENT_USER as
/* $Header: asxmcats.pls 115.2 2003/12/03 12:49:47 gbatra noship $ */

/*
This procedure creates new categories corresponding to interest types/codes
if required and then map these categories to interest types/codes. It will also
associate items to these newly created categories based on the old association
between items and interest types/codes
This will be called by concurrent program 'Product Catalog Mapping'
*/
PROCEDURE Migrate_Categories (
     ERRBUF     OUT NOCOPY    VARCHAR2,
     RETCODE    OUT NOCOPY    VARCHAR2,
     p_Debug_Flag   IN        VARCHAR2 Default 'N'
    );


END AS_CATALOG_MIGRATION;


 

/
