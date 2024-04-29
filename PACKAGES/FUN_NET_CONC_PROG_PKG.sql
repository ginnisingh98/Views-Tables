--------------------------------------------------------
--  DDL for Package FUN_NET_CONC_PROG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FUN_NET_CONC_PROG_PKG" AUTHID CURRENT_USER AS
/* $Header: funntcps.pls 120.1 2006/01/05 16:00:03 asrivats ship $ */

   PROCEDURE Create_Net_Batch(
     errbuf  OUT NOCOPY VARCHAR2,
     retcode OUT NOCOPY VARCHAR2,
     p_batch_id IN fun_net_batches_all.batch_id%TYPE);

   PROCEDURE Submit_Net_Batch(
     errbuf  OUT NOCOPY VARCHAR2,
     retcode OUT NOCOPY VARCHAR2,
     p_batch_id IN fun_net_batches_all.batch_id%TYPE);

   PROCEDURE Settle_Net_Batch(
     errbuf  OUT NOCOPY VARCHAR2,
     retcode OUT NOCOPY VARCHAR2,
     p_batch_id IN fun_net_batches_all.batch_id%TYPE);

   PROCEDURE Reverse_Net_Batch(
     errbuf  OUT NOCOPY VARCHAR2,
     retcode OUT NOCOPY VARCHAR2,
     p_batch_id IN fun_net_batches_all.batch_id%TYPE);

END FUN_NET_CONC_PROG_PKG; -- Package spec

 

/
