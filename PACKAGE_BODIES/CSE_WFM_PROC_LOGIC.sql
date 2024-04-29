--------------------------------------------------------
--  DDL for Package Body CSE_WFM_PROC_LOGIC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSE_WFM_PROC_LOGIC" AS
/* $Header: CSEWFPLB.pls 120.2 2006/05/31 20:52:09 brmanesh noship $ */

  l_debug VARCHAR2(1) := NVL(fnd_profile.value('cse_debug_option'),'N');

  PROCEDURE processing_logic(
    p_item_id                IN  NUMBER,
    p_revision               IN  VARCHAR2,
    p_lot_number             IN  VARCHAR2,
    p_serial_number          IN  VARCHAR2,
    p_quantity               IN  NUMBER,
    p_project_id             IN  NUMBER,
    p_task_id                IN  NUMBER,
    p_from_network_loc_id    IN  NUMBER,
    p_to_network_loc_id      IN  NUMBER,
    p_from_party_site_id     IN  NUMBER,
    p_to_party_site_id       IN  NUMBER,
    p_work_order_number      IN  VARCHAR2,
    p_transaction_date       IN  DATE,
    p_effective_date         IN  DATE,
    p_transacted_by          IN  NUMBER,
    p_message_id             IN  NUMBER,
    p_transaction_type       IN  VARCHAR2,
    x_return_status          OUT NOCOPY VARCHAR2,
    x_error_message	     OUT NOCOPY VARCHAR2)
  IS
  BEGIN
    null;
    -- need to put code here to call process transaction API
    -- in r12 all the eib transactions goes thru process transaction API
  END processing_logic;

END cse_wfm_proc_logic;

/
