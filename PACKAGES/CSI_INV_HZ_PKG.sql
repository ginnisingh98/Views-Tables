--------------------------------------------------------
--  DDL for Package CSI_INV_HZ_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSI_INV_HZ_PKG" AUTHID CURRENT_USER as
-- $Header: csiivtzs.pls 120.0.12000000.1 2007/01/16 15:32:23 appldev ship $


   PROCEDURE ISSUE_TO_HZ_LOC(p_transaction_id     IN  NUMBER,
                             p_message_id         IN  NUMBER,
                             x_return_status      OUT NOCOPY VARCHAR2,
                             x_trx_error_rec      OUT NOCOPY CSI_DATASTRUCTURES_PUB.TRANSACTION_ERROR_REC);

   PROCEDURE MISC_RECEIPT_HZ_LOC(p_transaction_id     IN  NUMBER,
                                 p_message_id         IN  NUMBER,
                                 x_return_status      OUT NOCOPY VARCHAR2,
                                 x_trx_error_rec      OUT NOCOPY CSI_DATASTRUCTURES_PUB.TRANSACTION_ERROR_REC);

   PROCEDURE MISC_ISSUE_HZ_LOC(p_transaction_id     IN  NUMBER,
                               p_message_id         IN  NUMBER,
                               x_return_status      OUT NOCOPY VARCHAR2,
                               x_trx_error_rec      OUT NOCOPY CSI_DATASTRUCTURES_PUB.TRANSACTION_ERROR_REC);

END CSI_INV_HZ_PKG;

 

/
