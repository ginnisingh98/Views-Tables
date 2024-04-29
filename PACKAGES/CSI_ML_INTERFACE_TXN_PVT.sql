--------------------------------------------------------
--  DDL for Package CSI_ML_INTERFACE_TXN_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSI_ML_INTERFACE_TXN_PVT" AUTHID CURRENT_USER AS
-- $Header: csimtxns.pls 120.2 2006/02/03 15:35:58 sguthiva noship $

PROCEDURE process_iface_txns( x_return_status  OUT NOCOPY VARCHAR2 ,
                             x_error_message  OUT NOCOPY VARCHAR2 ,
                             p_txn_from_date  IN VARCHAR2 ,
                             p_txn_to_date    IN VARCHAR2 ,
                             p_source_system_name IN VARCHAR2,
                             p_batch_name     IN VARCHAR2,
                             p_resolve_ids     IN VARCHAR2) ;

END CSI_ML_INTERFACE_TXN_PVT;

 

/
