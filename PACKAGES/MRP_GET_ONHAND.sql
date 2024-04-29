--------------------------------------------------------
--  DDL for Package MRP_GET_ONHAND
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MRP_GET_ONHAND" AUTHID CURRENT_USER AS
/* $Header: MRPGEOHS.pls 120.0 2005/05/24 17:40:51 appldev noship $ */

g_x_return_status VARCHAR2(20);
g_x_msg_data VARCHAR2(1000);
g_x_qoh NUMBER;

g_mrp_debug   VARCHAR2(1) := nvl(FND_PROFILE.Value('MRP_DEBUG'),'N');

PROCEDURE GET_OH_QTY (item_id IN NUMBER, org_id IN NUMBER,
                        include_nonnet IN NUMBER,
                        x_qoh OUT NOCOPY NUMBER,
                        x_return_status OUT NOCOPY VARCHAR2,
                        x_msg_data OUT NOCOPY VARCHAR2);


PROCEDURE do_restock
( x_return_status            OUT  NOCOPY VARCHAR2
, x_msg_count                OUT  NOCOPY NUMBER
, x_msg_data                 OUT  NOCOPY VARCHAR2
, p_item_id                  IN   NUMBER
, p_mbf                      IN   NUMBER
, p_handle_repetitive_item   IN   NUMBER
, p_repetitive_planned_item  IN   VARCHAR2
, p_qty                      IN   NUMBER
, p_fixed_lead_time          IN   NUMBER
, p_variable_lead_time       IN   NUMBER
, p_buying_lead_time         IN   NUMBER
, p_uom                      IN   VARCHAR2
, p_accru_acct               IN   NUMBER
, p_ipv_acct                 IN   NUMBER
, p_budget_acct              IN   NUMBER
, p_charge_acct              IN   NUMBER
, p_purch_flag               IN   VARCHAR2
, p_order_flag               IN   VARCHAR2
, p_transact_flag            IN   VARCHAR2
, p_unit_price               IN   NUMBER
, p_wip_id                   IN   NUMBER
, p_user_id                  IN   NUMBER
, p_sysd                     IN   DATE
, p_organization_id          IN   NUMBER
, p_approval                 IN   NUMBER
, p_build_in_wip             IN   VARCHAR2
, p_pick_components          IN   VARCHAR2
, p_src_type                 IN   NUMBER
, p_encum_flag               IN   VARCHAR2
, p_customer_id              IN   NUMBER
, p_cal_code                 IN   VARCHAR2
, p_except_id                IN   NUMBER
, p_employee_id              IN   NUMBER
, p_description              IN   VARCHAR2
, p_src_org                  IN   NUMBER
, p_src_subinv               IN   VARCHAR2
, p_subinv                   IN   VARCHAR2
, p_location_id              IN   NUMBER
, p_po_org_id                IN   NUMBER
, p_pur_revision             IN   NUMBER
);

END MRP_GET_ONHAND;

 

/
