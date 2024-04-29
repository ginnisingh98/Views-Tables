--------------------------------------------------------
--  DDL for Package FUN_NET_EXTRACT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FUN_NET_EXTRACT_PKG" AUTHID CURRENT_USER AS
/* $Header: funntdes.pls 120.0 2006/01/19 14:46:23 vgadde noship $ */

   PROCEDURE extract_data
     (errbuf  OUT NOCOPY VARCHAR2,
     retcode OUT NOCOPY VARCHAR2,
     p_batch_id IN fun_net_batches_all.batch_id%TYPE);

END FUN_NET_EXTRACT_PKG; -- Package spec

 

/
