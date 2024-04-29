--------------------------------------------------------
--  DDL for Package ARP_RECUR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_RECUR_PKG" AUTHID CURRENT_USER AS
/* $Header: ARTIRECS.pls 115.3 2002/11/15 03:51:40 anukumar ship $ */
PROCEDURE insert_p(
                    p_rec_rec         IN  ra_recur_interim%rowtype,
                    p_batch_source_id IN  ra_batch_sources.batch_source_id%type,
                    p_trx_number      OUT NOCOPY ra_recur_interim.trx_number%type);
END ARP_RECUR_PKG;

 

/
