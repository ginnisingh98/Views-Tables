--------------------------------------------------------
--  DDL for Package CSI_INV_TRANSFER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSI_INV_TRANSFER_PKG" AUTHID CURRENT_USER as
-- $Header: csiivtts.pls 120.0 2005/05/24 18:35:28 appldev noship $

   PROCEDURE SUBINV_TRANSFER(p_transaction_id     IN  NUMBER,
                             p_message_id         IN  NUMBER,
                             x_return_status      OUT NOCOPY VARCHAR2,
                             x_trx_error_rec      OUT NOCOPY CSI_DATASTRUCTURES_PUB.TRANSACTION_ERROR_REC);

END CSI_INV_TRANSFER_PKG;

 

/
