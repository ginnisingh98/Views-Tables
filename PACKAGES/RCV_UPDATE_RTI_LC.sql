--------------------------------------------------------
--  DDL for Package RCV_UPDATE_RTI_LC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."RCV_UPDATE_RTI_LC" AUTHID CURRENT_USER AS
/* $Header: RCVUPLCS.pls 120.0.12010000.5 2008/11/06 00:52:16 musinha noship $ */

  TYPE rcv_cost_type IS RECORD
  (
     interface_id                  NUMBER,
     lcm_shipment_line_id          NUMBER,
     unit_landed_cost              NUMBER
  );

  TYPE rcv_cost_table IS table of rcv_cost_type;

  TYPE lcm_int_table IS TABLE OF NUMBER;

  PROCEDURE  update_rti (p_int_rec        IN rcv_cost_table,
                         x_lcm_int        OUT NOCOPY lcm_int_table);

END RCV_UPDATE_RTI_LC;


/
