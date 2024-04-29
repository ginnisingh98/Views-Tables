--------------------------------------------------------
--  DDL for Package CSE_WFM_PROC_LOGIC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSE_WFM_PROC_LOGIC" AUTHID CURRENT_USER AS
/* $Header: CSEWFPLS.pls 120.1 2006/05/31 20:51:58 brmanesh noship $ */

  PROCEDURE processing_logic(
    p_item_id                IN     NUMBER,
    p_revision               IN     VARCHAR2,
    p_lot_number             IN     VARCHAR2,
    p_serial_number          IN     VARCHAR2,
    p_quantity               IN     NUMBER,
    p_project_id             IN     NUMBER,
    p_task_id                IN     NUMBER,
    p_from_network_loc_id    IN     NUMBER,
    p_to_network_loc_id      IN     NUMBER,
    p_from_party_site_id     IN     NUMBER,
    p_to_party_site_id       IN     NUMBER,
    p_work_order_number      IN     VARCHAR2,
    p_transaction_date       IN     DATE,
    p_effective_date         IN     DATE,
    p_transacted_by          IN     NUMBER,
    p_message_id             IN     NUMBER,
    p_transaction_type       IN     VARCHAR2,
    x_return_status          OUT NOCOPY    VARCHAR2,
    x_error_message	     OUT NOCOPY    VARCHAR2);

END cse_wfm_proc_logic;

 

/
