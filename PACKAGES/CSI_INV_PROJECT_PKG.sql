--------------------------------------------------------
--  DDL for Package CSI_INV_PROJECT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSI_INV_PROJECT_PKG" AUTHID CURRENT_USER as
-- $Header: csiivtps.pls 120.0.12000000.1 2007/01/16 15:32:15 appldev ship $


   PROCEDURE ISSUE_TO_PROJECT(p_transaction_id     IN  NUMBER,
                              p_message_id         IN  NUMBER,
                              x_return_status      OUT NOCOPY VARCHAR2,
                              x_trx_error_rec      OUT NOCOPY CSI_DATASTRUCTURES_PUB.TRANSACTION_ERROR_REC);

   PROCEDURE MISC_RECEIPT_PROJTASK(p_transaction_id     IN  NUMBER,
                                   p_message_id         IN  NUMBER,
                                   x_return_status      OUT NOCOPY VARCHAR2,
                                   x_trx_error_rec      OUT NOCOPY CSI_DATASTRUCTURES_PUB.TRANSACTION_ERROR_REC);

   PROCEDURE MISC_ISSUE_PROJTASK(p_transaction_id     IN  NUMBER,
                                 p_message_id         IN  NUMBER,
                                 x_return_status      OUT NOCOPY VARCHAR2,
                                 x_trx_error_rec      OUT NOCOPY CSI_DATASTRUCTURES_PUB.TRANSACTION_ERROR_REC);

END CSI_INV_PROJECT_PKG;

 

/
