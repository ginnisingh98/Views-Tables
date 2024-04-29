--------------------------------------------------------
--  DDL for Package MSC_CL_MISCELLANEOUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSC_CL_MISCELLANEOUS" AUTHID CURRENT_USER AS -- specification
/* $Header: MSCCLGAS.pls 120.0 2005/05/25 19:52:59 appldev noship $ */

  ----- CONSTANTS --------------------------------------------------------

   SYS_YES                      CONSTANT NUMBER := 1;
   SYS_NO                       CONSTANT NUMBER := 2;

   G_SUCCESS                    CONSTANT NUMBER := 0;
   G_WARNING                    CONSTANT NUMBER := 1;
   G_ERROR                      CONSTANT NUMBER := 2;

   G_APPS107                    CONSTANT NUMBER := 1;
   G_APPS110                    CONSTANT NUMBER := 2;
   G_APPS115                    CONSTANT NUMBER := 3;

   G_INS_DISCRETE               CONSTANT NUMBER := 1;
   G_INS_PROCESS                CONSTANT NUMBER := 2;
   G_INS_OTHER                  CONSTANT NUMBER := 3;
   G_INS_MIXED                  CONSTANT NUMBER := 4;

   -- STAGING TABLE STATUS --

   G_ST_EMPTY                   CONSTANT NUMBER := 0;  -- no instance data exists;
   G_ST_PULLING                 CONSTANT NUMBER := 1;
   G_ST_READY                   CONSTANT NUMBER := 2;
   G_ST_COLLECTING              CONSTANT NUMBER := 3;

 ----- PARAMETERS --------------------------------------------------------

   v_lrn                        NUMBER;    -- Last Refresh Number
   v_crn                        NUMBER;    -- Current Refresh Number
   v_refresh_number             NUMBER;
   v_instance_id                NUMBER;
   v_dblink                     VARCHAR2(128);
   v_current_date               DATE;
   v_current_user               NUMBER;
   v_request_id                 NUMBER;
   v_last_calculated_date       DATE;

   v_debug                      BOOLEAN := FALSE;

   v_cp_enabled                 NUMBER;    -- SYS_YES: This program is launched as a concurrent program.

   -- ================== Worker Status ===================

   OK                           CONSTANT NUMBER := 1;
   FAIL                         CONSTANT NUMBER := 0;

  ---------------------- Task Number ----------------------------

   UNRESOLVABLE_ERROR           CONSTANT NUMBER := -9999999;

  ----------------------------------------------------------
   v_sql_stmt                   VARCHAR2(4000);

   --  ================= Procedures ====================

   PROCEDURE load_sourcing_history
             ( arg_instance_id       IN NUMBER,
               arg_refresh_number    IN NUMBER,
               arg_current_date      IN DATE,
               arg_current_user      IN NUMBER,
               arg_request_id        IN NUMBER );

   PROCEDURE load_po_receipts
             ( arg_instance_id       IN NUMBER,
               arg_org_sub_str       IN VARCHAR2 := NULL,
               arg_refresh_number    IN NUMBER,
               arg_current_date      IN DATE,
               arg_current_user      IN NUMBER,
               arg_request_id        IN NUMBER );

   PROCEDURE load_sourcing_history_sub1
             ( arg_assignment_set_id IN NUMBER );

   PROCEDURE get_sourcing_history
             ( arg_source_org           IN NUMBER,
               arg_sr_supplier_id       IN NUMBER,
               arg_supplier_id          IN NUMBER,
               arg_sr_supplier_site_id  IN NUMBER,
               arg_supplier_site_id     IN NUMBER,
               arg_sr_item_id           IN NUMBER,
               arg_item_id           IN NUMBER,
               arg_org_id            IN NUMBER,
               arg_sourcing_rule_id  IN NUMBER,
               arg_start_date        IN DATE,
               arg_end_date          IN DATE );

   FUNCTION inner_org_trx_qty
                 ( arg_inventory_item_id IN NUMBER,
                   arg_organization_id   IN NUMBER,
                   arg_start_date        IN DATE,
                   arg_end_date          IN DATE)
    RETURN NUMBER;

  FUNCTION inter_org_trx_qty
                 ( arg_inventory_item_id IN NUMBER,
                   arg_organization_id   IN NUMBER,
                   arg_source_org_id     IN NUMBER,
                   arg_start_date        IN DATE,
                   arg_end_date          IN DATE)
    RETURN NUMBER;

  FUNCTION po_supplier_trx_qty
                 ( arg_inventory_item_id IN NUMBER,
                   arg_organization_id   IN NUMBER,
                   arg_supplier_id       IN NUMBER,
                   arg_supplier_site_id  IN NUMBER,
                   arg_start_date        IN DATE,
                   arg_end_date          IN DATE)
    RETURN NUMBER;

    PROCEDURE LOG_MESSAGE(  pBUFF                   IN  VARCHAR2);

END MSC_CL_MISCELLANEOUS;
 

/
