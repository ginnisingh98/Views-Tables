--------------------------------------------------------
--  DDL for Package CZ_OM_ATP_CALLBACK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CZ_OM_ATP_CALLBACK" AUTHID CURRENT_USER AS
/* $Header: czatpcbs.pls 115.8 2003/02/03 21:00:14 qmao ship $ */

  -- global variables used in dynamically call to extend atp rec
  g_atp_rec        MRP_ATP_PUB.ATP_Rec_Typ;
  g_return_status  VARCHAR2(1);
  g_count          NUMBER;

  PROCEDURE call_atp (p_config_session_key IN VARCHAR2,
                      p_warehouse_id IN NUMBER,
                      p_ship_to_org_id IN NUMBER,
                      p_customer_id IN NUMBER,
                      p_customer_site_id IN NUMBER,
                      p_requested_date IN DATE,
                      p_ship_to_group_date OUT NOCOPY DATE);

END cz_om_atp_callback;

 

/
