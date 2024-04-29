--------------------------------------------------------
--  DDL for Package INV_RECEIVING_TRANSACTION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_RECEIVING_TRANSACTION" AUTHID CURRENT_USER AS
/* $Header: INVRCVFS.pls 120.0 2005/05/25 05:18:21 appldev noship $*/

PROCEDURE txn_complete(p_group_id      IN     NUMBER,
		       p_txn_status    IN     VARCHAR2, -- TRUE/FALSE
		       p_txn_mode      IN     VARCHAR2, -- ONLINE/IMMEDIATE
		       x_return_status    OUT NOCOPY VARCHAR2,
		       x_msg_data         OUT NOCOPY VARCHAR2,
		       x_msg_count        OUT NOCOPY NUMBER);

PROCEDURE txn_mobile_timeout_cleanup(p_group_id      IN     NUMBER,
                                     p_rti_rec_count IN     NUMBER,
                                     x_return_status OUT NOCOPY VARCHAR2,
                                     x_msg_data      OUT NOCOPY VARCHAR2,
                                     x_msg_count     OUT NOCOPY NUMBER);
END inv_receiving_transaction;

 

/
