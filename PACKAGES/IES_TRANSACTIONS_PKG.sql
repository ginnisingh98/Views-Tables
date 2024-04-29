--------------------------------------------------------
--  DDL for Package IES_TRANSACTIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IES_TRANSACTIONS_PKG" AUTHID CURRENT_USER AS
/* $Header: iestrans.pls 115.3 2002/12/09 21:13:28 appldev noship $ */
   procedure endSuspendedTransaction
   (
      p_api_version                    IN     NUMBER,
      p_transaction_id                 IN     NUMBER,
      x_return_status                  OUT NOCOPY     VARCHAR2,
      x_msg_count                      OUT NOCOPY     NUMBER,
      x_msg_data                       OUT NOCOPY     VARCHAR2
   );
END ies_transactions_pkg;

 

/
