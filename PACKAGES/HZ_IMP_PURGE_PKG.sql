--------------------------------------------------------
--  DDL for Package HZ_IMP_PURGE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_IMP_PURGE_PKG" AUTHID CURRENT_USER AS
/*$Header: ARHLPRGS.pls 115.2 2003/10/13 20:46:50 sponnamb noship $ */
PROCEDURE Purge_Batch(     errbuf                          OUT NOCOPY   VARCHAR2,
                           retcode                         OUT NOCOPY   VARCHAR2,
                           P_BATCH_ID                      IN           VARCHAR2
);

END HZ_IMP_PURGE_PKG;

 

/
