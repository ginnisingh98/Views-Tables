--------------------------------------------------------
--  DDL for Package CSI_INV_TXNSTUB_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSI_INV_TXNSTUB_PKG" AUTHID CURRENT_USER AS
-- $Header: csiinvhs.pls 120.0.12000000.1 2007/01/16 15:32:07 appldev ship $

PROCEDURE execute_trx_dpl(p_transaction_type    IN VARCHAR2,
                          p_transaction_id      IN NUMBER,
                          x_trx_return_status   OUT NOCOPY VARCHAR2,
                          x_trx_error_rec       IN OUT NOCOPY CSI_DATASTRUCTURES_PUB.TRANSACTION_ERROR_REC);

end CSI_INV_TXNSTUB_PKG;

 

/
