--------------------------------------------------------
--  DDL for Package CSI_INV_INTERORG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSI_INV_INTERORG_PKG" AUTHID CURRENT_USER as
-- $Header: csiorgts.pls 120.0.12000000.1 2007/01/16 15:34:11 appldev ship $

   PROCEDURE INTRANSIT_SHIPMENT(p_transaction_id     IN  NUMBER,
                                p_message_id         IN  NUMBER,
                                x_return_status      OUT NOCOPY VARCHAR2,
                                x_trx_error_rec      OUT NOCOPY CSI_DATASTRUCTURES_PUB.TRANSACTION_ERROR_REC);

   PROCEDURE INTRANSIT_RECEIPT(p_transaction_id     IN  NUMBER,
                               p_message_id         IN  NUMBER,
                               x_return_status      OUT NOCOPY VARCHAR2,
                               x_trx_error_rec      OUT NOCOPY CSI_DATASTRUCTURES_PUB.TRANSACTION_ERROR_REC);

   PROCEDURE DIRECT_SHIPMENT(p_transaction_id     IN  NUMBER,
                             p_message_id         IN  NUMBER,
                             x_return_status      OUT NOCOPY VARCHAR2,
                             x_trx_error_rec      OUT NOCOPY CSI_DATASTRUCTURES_PUB.TRANSACTION_ERROR_REC);
END CSI_INV_INTERORG_PKG;

 

/
