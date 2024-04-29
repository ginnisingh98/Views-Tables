--------------------------------------------------------
--  DDL for Package INV_TXN_PURGE_MAIN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_TXN_PURGE_MAIN" AUTHID CURRENT_USER AS
/*  $Header: INVTPGMS.pls 120.1 2005/09/29 05:54:08 amohamme noship $ */
  PROCEDURE TXN_PURGE_MAIN(
                            x_errbuf        OUT     NOCOPY VARCHAR2
                           ,x_retcode       OUT     NOCOPY NUMBER
                           ,p_orgid         IN      NUMBER
                           ,p_purge_date    IN      DATE
                       );

END INV_TXN_PURGE_MAIN;

 

/
