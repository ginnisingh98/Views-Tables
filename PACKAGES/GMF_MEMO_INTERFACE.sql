--------------------------------------------------------
--  DDL for Package GMF_MEMO_INTERFACE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMF_MEMO_INTERFACE" AUTHID CURRENT_USER AS
/* $Header: gmfarmos.pls 115.4 2002/11/11 00:29:44 rseshadr ship $ */
  PROCEDURE get_next_trx_line (
        t_init_flag             IN OUT  NOCOPY NUMBER,
        t_customer_trx_id       OUT     NOCOPY NUMBER,
        t_trx_type              OUT     NOCOPY VARCHAR2,
        error_status            OUT     NOCOPY NUMBER
  );
  PROCEDURE insert_error (t_customer_trx_id IN NUMBER, error_status OUT NOCOPY NUMBER);
  PROCEDURE validate_flexfields (
	t_customer_trx_id	IN	NUMBER,
	t_rctl_attribute7	IN	VARCHAR2,
	t_rctl_attribute8	IN	VARCHAR2,
	t_rctl_attribute9	IN	VARCHAR2,
	t_rctl_attribute10	IN	VARCHAR2,
	t_inventory_item_id     IN 	NUMBER,
	t_rctl_attribute1	IN	VARCHAR2,
	t_rctl_attribute5	IN	VARCHAR2,
	t_rctl_attribute15	IN	VARCHAR2
    );
END GMF_MEMO_INTERFACE;

 

/
