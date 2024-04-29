--------------------------------------------------------
--  DDL for Package ARP_TAX_RATE_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_TAX_RATE_UPD" AUTHID CURRENT_USER as
/* $Header: ARTAXRATES.pls 120.1 2005/10/30 04:46:00 appldev ship $ */

 PROCEDURE  update_tax_rate( errbuf       OUT NOCOPY   VARCHAR2,
                            retcode       OUT NOCOPY   VARCHAR2,
                            p_batch_size  IN NUMBER,
                            p_worker_id   IN NUMBER,
                            p_num_workers IN NUMBER) ;

 Procedure Master_Conc_Parallel_Upgrade(
                                       errbuf    OUT NOCOPY   VARCHAR2,
                                       retcode    OUT NOCOPY   VARCHAR2,
                                       p_batch_commit_size IN NUMBER,
                                       p_num_workers IN NUMBER);
end ARP_TAX_RATE_UPD;

 

/
