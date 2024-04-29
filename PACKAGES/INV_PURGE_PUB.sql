--------------------------------------------------------
--  DDL for Package INV_PURGE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_PURGE_PUB" AUTHID CURRENT_USER AS
/*  $Header: INVTXPGS.pls 120.1 2005/09/29 07:24:12 amohamme noship $ */
PROCEDURE PURGE_TRANSACTIONS(
             x_errbuf        OUT     NOCOPY VARCHAR2,
             x_retcode       OUT     NOCOPY NUMBER,
             p_purge_date    IN      VARCHAR2,
             p_orgid         IN      NUMBER,
             p_purge_name    IN      VARCHAR2 ) ;

END INV_PURGE_PUB ;

 

/
