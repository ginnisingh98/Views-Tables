--------------------------------------------------------
--  DDL for Package ENI_PROD_VALUESET
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ENI_PROD_VALUESET" AUTHID CURRENT_USER AS
/* $Header: ENIVSTPS.pls 115.0 2003/09/10 22:29:09 sbag noship $  */

  PROCEDURE UPDATE_VALUESET_FROM_CATEGORY(
       errbuf OUT NOCOPY VARCHAR2,
       retcode OUT NOCOPY VARCHAR2);
END ENI_PROD_VALUESET;


 

/
