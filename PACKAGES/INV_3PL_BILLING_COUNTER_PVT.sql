--------------------------------------------------------
--  DDL for Package INV_3PL_BILLING_COUNTER_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_3PL_BILLING_COUNTER_PVT" AUTHID CURRENT_USER AS
/* $Header: INVVBLCS.pls 120.0.12010000.2 2010/01/17 10:26:43 gjyoti noship $ */

PROCEDURE inv_insert_readings_using_api
    ( p_counter_id      NUMBER,
      p_count_date      DATE,
      p_new_reading     NUMBER,
      p_net_reading     NUMBER,
      p_transaction_id  NUMBER );

FUNCTION get_top_counter_details (p_contract_id NUMBER, p_cle_id NUMBER)
RETURN NUMBER;

END INV_3PL_BILLING_COUNTER_PVT;

/
