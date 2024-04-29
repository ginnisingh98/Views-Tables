--------------------------------------------------------
--  DDL for Package INV_TXN_PURGE_WORKER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_TXN_PURGE_WORKER" AUTHID CURRENT_USER AS
/*  $Header: INVTPGWS.pls 120.1 2005/09/29 06:11:51 amohamme noship $ */
  PROCEDURE Txn_Purge_Worker(
			    x_errbuf          	OUT NOCOPY VARCHAR2
			   ,x_retcode           OUT NOCOPY NUMBER
                           ,p_organization_id   IN  NUMBER
                           ,p_min_date          IN  VARCHAR2
                           ,p_max_date          IN  VARCHAR2
                          );


END INV_TXN_PURGE_WORKER ;

 

/
