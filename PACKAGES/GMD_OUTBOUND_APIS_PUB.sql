--------------------------------------------------------
--  DDL for Package GMD_OUTBOUND_APIS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMD_OUTBOUND_APIS_PUB" AUTHID CURRENT_USER AS
/*  $Header: GMDOAPIS.pls 120.11.12010000.2 2009/03/18 21:07:16 plowe ship $ */
/*#
 * This is Public level outbound GMD Quality API package
 * This package defines and implements the procedures and datatypes
 * required to fetch Results, Composite Results, Samples, Test Methods,
 * Tests, Specification Validity Rules and Sample Groups.
 * @rep:scope public
 * @rep:product GMD
 * @rep:lifecycle active
 * @rep:displayname Public level outbound GMD Quality API package
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY GMD_OUTBOUND_APIS_PUB
 */

--****************************************************************************************
--* FILE:      GMDOAPIS.pls                                                              *
--*                                                                                      *
--* CONTENTS:  Public level outbound GMD Quality API package                             *
--*                                                                                      *
--* AUTHOR:    Paul Schofield, OPM Development EMEA                                      *
--*                                                                                      *
--* DATE:      May 20th 2003                                                             *
--*                                                                                      *
--* VERSION    CHANGED BY         CHANGE                                                 *
--* =======    ==========         ======                                                 *
--* 20May03    P.J.Schofield      New file                                               *
--* 17Jun03    K.Y.Hunt           Merged in 3 new APIs                                   *
--* 04Jul03    P.J.Schofield      Added user_name parameters                             *
--* 28Aug03    Chetan Nagar       Added mini-pack K specific features.                   *
--* 15Jan04    Brenda Stone       Added mini-pack L specific features.                   *
--* 24Feb04    Brenda Stone       Bug 3394055; added L columns to Result a Result        *
--* 02May05  Saikiran Vankadari   Convergence changes done for fetch_spec_vrs() procedure.*
--*           Changed all references of OPM Inventory tables to Discrete inventory tables*
--* 10Oct05   RLNAGARA            Bug # 4548546 -- Added from and to revision variables  *
--* 10Nov05   RLNAGARA            Bug # 4616835 -- Changed all the references of TYPE    *
--*                               objects to the SYSTEM schema.                          *
--* 02Jun08   PLOWE               Bug # 7027149 support for LPN                        *
--*                                                                                      *
--****************************************************************************************
--*                                                                                      *
--* COPYRIGHT (c) Oracle Corporation 2003                                                *
--*                                                                                      *
--****************************************************************************************


api_version NUMBER := 2.0;

g_from_test_method_code    VARCHAR2(80);
g_to_test_method_code      VARCHAR2(80);
g_test_method_code         VARCHAR2(80);
g_test_method_id           NUMBER(10);
g_test_kit_organization_id NUMBER(10);
g_test_kit_inv_item_id NUMBER(10);
g_resource                 VARCHAR2(16);
g_delete_mark              NUMBER(5);
g_from_last_update_date    DATE;
g_to_last_update_date      DATE;
g_test_id                  NUMBER(10);
g_test_code                VARCHAR2(80);
g_priority                 VARCHAR2(2);
g_test_type                VARCHAR2(1);
g_test_class               VARCHAR2(8);
g_from_test_code           VARCHAR2(240);
g_to_test_code             VARCHAR2(240);
g_from_spec_name           VARCHAR2(240);
g_to_spec_name             VARCHAR2(240);
g_spec_id                  NUMBER(10);
g_spec_version             NUMBER(5);
g_spec_delete_mark         NUMBER(5);
g_from_grade_code          VARCHAR2(150);
g_to_grade_code            VARCHAR2(150);
g_from_item_number         VARCHAR2(240);  /*--NSRIVAST, INVCONV*/
g_to_item_number           VARCHAR2(240);  /*--NSRIVAST, INVCONV*/
g_from_inventory_item_id   NUMBER; /*NSRIVAST, INVCONV*/
g_to_inventory_item_id     NUMBER; /*NSRIVAST, INVCONV*/
g_from_revision            VARCHAR2(3); -- RLNAGARA Bug # 4548546
g_to_revision              VARCHAR2(3); -- RLNAGARA Bug # 4548546
g_inventory_item_id        NUMBER;
g_item_id                  NUMBER;
g_from_spec_last_update    DATE;
g_to_spec_last_update      DATE;
g_spec_type		           VARCHAR2(2);

g_owner_organization_code  VARCHAR2(3); /*--NSRIVAST, INVCONV*/
g_owner_orgn_id            MTL_ORGANIZATIONS.ORGANIZATION_ID%TYPE ;  /*NSRIVAST, INVCONV*/

g_spec_status   	   NUMBER;
g_test_qty_uom             VARCHAR2(3);
g_from_test_last_update    DATE;
g_to_test_last_update      DATE;
g_test_priority            VARCHAR2(2);
g_test_delete_mark         NUMBER(5);

-- START B3124291 Incorporated Mini-Pack K Features to Outboud APIs
-- Spec Related
g_overlay_ind              VARCHAR2(1);
g_base_spec_id             NUMBER;
g_base_spec_name           VARCHAR2(240);
g_base_spec_version        NUMBER;

-- Spec Test Related
g_from_base_ind            VARCHAR2(1);
g_exclude_ind              VARCHAR2(1);
g_modified_ind             VARCHAR2(1);
g_calc_uom_conv_ind        VARCHAR2(1);
g_to_qty_uom               VARCHAR2(3);

-- END B3124291 Incorporated Mini-Pack K Features to Outboud APIs


g_wip_vr_status	           NUMBER;
g_wip_vr_organization_code VARCHAR2(3); /*--NSRIVAST, INVCONV*/
g_wip_vr_batch_orgn_code VARCHAR2(3);   /*--NSRIVAST, INVCONV*/
g_wip_vr_orgn_id           MTL_ORGANIZATIONS.ORGANIZATION_ID%TYPE ; /*NSRIVAST, INVCONV*/
g_wip_vr_batch_orgn_id     MTL_ORGANIZATIONS.ORGANIZATION_ID%TYPE ; /*NSRIVAST, INVCONV*/

g_wip_vr_batch_no          VARCHAR2(32);
g_wip_vr_batch_id          NUMBER;
g_wip_vr_recipe_no         VARCHAR2(80);
g_wip_vr_recipe_version    NUMBER;
g_wip_vr_recipe_id         NUMBER;
g_wip_vr_formula_no        VARCHAR2(32);
g_wip_vr_formula_version   NUMBER;
g_wip_vr_formula_id        NUMBER;
g_wip_vr_formulaline_no    NUMBER;
g_wip_vr_formulaline_id    NUMBER;
g_wip_vr_line_type         NUMBER;
g_wip_vr_routing_no        VARCHAR2(32);
g_wip_vr_routing_version   NUMBER;
g_wip_vr_routing_id        NUMBER;
g_wip_vr_step_no           NUMBER;
g_wip_vr_step_id           NUMBER;
g_wip_vr_operation_no      VARCHAR2(16);
g_wip_vr_operation_version NUMBER;
g_wip_vr_operation_id      NUMBER;
g_wip_vr_start_date	   DATE;
g_wip_vr_end_date	   DATE;
g_wip_vr_coa_type	   VARCHAR2(1);
g_wip_vr_sampling_plan     VARCHAR2(80);
g_wip_vr_sampling_plan_id  NUMBER;
g_wip_vr_delete_mark	   NUMBER;
g_wip_vr_from_last_update  DATE;
g_wip_vr_to_last_update	   DATE;

g_cust_vr_start_date       DATE;
g_cust_vr_end_date         DATE;
g_cust_vr_status           NUMBER;
g_cust_vr_organization_code VARCHAR2(3); /*--NSRIVAST, INVCONV*/
g_cust_vr_orgn_id          MTL_ORGANIZATIONS.ORGANIZATION_ID%TYPE ;  /*NSRIVAST, INVCONV*/

g_cust_vr_org_id           NUMBER;
g_cust_vr_coa_type         VARCHAR2(1);
g_cust_vr_customer         VARCHAR2(240);
g_cust_vr_customer_id	   NUMBER;
g_cust_vr_order_number     NUMBER;
g_cust_vr_order_id         NUMBER;
g_cust_vr_order_type       NUMBER;
g_cust_vr_order_line_no    NUMBER;
g_cust_vr_order_line_id    NUMBER;
g_cust_vr_ship_to_location VARCHAR2(240);
g_cust_vr_ship_to_site_id  NUMBER;
g_cust_vr_operating_unit   VARCHAR(240);
g_cust_vr_delete_mark      NUMBER;
g_cust_vr_from_last_update DATE;
g_cust_vr_to_last_update   DATE;

g_supl_vr_start_date       DATE;
g_supl_vr_end_date         DATE;
g_supl_vr_status           NUMBER;
g_supl_vr_organization_code VARCHAR2(3); /*--NSRIVAST, INVCONV*/
g_supl_vr_orgn_id           MTL_ORGANIZATIONS.ORGANIZATION_ID%TYPE ;  /*NSRIVAST, INVCONV*/

g_supl_vr_org_id           NUMBER;
g_supl_vr_coa_type         VARCHAR2(1);
g_supl_vr_supplier         VARCHAR2(240);
g_supl_vr_supplier_id      NUMBER;
g_supl_vr_po_number        NUMBER;
g_supl_vr_po_id            NUMBER;
g_supl_vr_po_line_no       NUMBER;
g_supl_vr_po_line_id       NUMBER;
g_supl_vr_supplier_site    VARCHAR2(240);
g_supl_vr_supplier_site_id NUMBER;
g_supl_vr_operating_unit   VARCHAR(240);
g_supl_vr_delete_mark      NUMBER;
g_supl_vr_from_last_update DATE;
g_supl_vr_to_last_update   DATE;

g_inv_vr_start_date        DATE;
g_inv_vr_end_date          DATE;
g_inv_vr_status            NUMBER;
g_inv_vr_organization_code VARCHAR2(3); /*--NSRIVAST, INVCONV*/
g_inv_vr_orgn_id           MTL_ORGANIZATIONS.ORGANIZATION_ID%TYPE ; /*NSRIVAST, INVCONV*/

g_inv_vr_org_id            NUMBER;
g_inv_vr_coa_type          VARCHAR2(1);
g_inv_vr_item_number       VARCHAR2(40);
g_inv_vr_inventory_item_id NUMBER;
g_inv_vr_parent_lot_number VARCHAR2(80);
g_inv_vr_lot_number        VARCHAR2(80);
g_inv_vr_subinventory      MTL_SECONDARY_INVENTORIES.SECONDARY_INVENTORY_NAME%TYPE ;/*NSRIVAST, INVCONV*/
g_inv_vr_locator           VARCHAR2(204);
g_inv_vr_locator_id        NUMBER;
g_inv_vr_sampling_plan     VARCHAR2(80);
g_inv_vr_sampling_plan_id  NUMBER;
g_inv_vr_delete_mark       NUMBER;
g_inv_vr_from_last_update  DATE;
g_inv_vr_to_last_update    DATE;
-- START B3124291 Incorporated Mini-Pack K Features to Outboud APIs
g_mon_vr_status            NUMBER(5);
g_mon_vr_rule_type         VARCHAR2(2);
g_mon_vr_lct_organization_code      VARCHAR2(3);  /*--NSRIVAST, INVCONV*/
g_mon_vr_loct_orgn_id       MTL_ORGANIZATIONS.ORGANIZATION_ID%TYPE ;  /*NSRIVAST, INVCONV*/

g_mon_vr_subinventory     MTL_SECONDARY_INVENTORIES.SECONDARY_INVENTORY_NAME%TYPE ;/*NSRIVAST, INVCONV*/
g_mon_vr_locator_id             NUMBER;
g_mon_vr_locator                VARCHAR2(204);
g_mon_vr_rsr_organization_code     VARCHAR2(3);  /*--NSRIVAST, INVCONV*/
g_mon_vr_resource_orgn_id     MTL_ORGANIZATIONS.ORGANIZATION_ID%TYPE ; /*NSRIVAST, INVCONV*/

g_mon_vr_resources              VARCHAR2(16);
g_mon_vr_resource_instance_id   NUMBER;
g_mon_vr_sampling_plan          VARCHAR2(80);
g_mon_vr_sampling_plan_id       NUMBER;
g_mon_vr_start_date             DATE;
g_mon_vr_end_date               DATE;
g_mon_vr_from_last_update_date  DATE;
g_mon_vr_to_last_update_date    DATE;
g_mon_vr_delete_mark            NUMBER(5);
-- END B3124291 Incorporated Mini-Pack K Features to Outboud APIs




g_orgn_code                 VARCHAR2(4); /*--NSRIVAST, INVCONV*/
g_qc_lab_orgn_code          VARCHAR2(4); /*--NSRIVAST, INVCONV*/
g_orgn_id                   MTL_ORGANIZATIONS.ORGANIZATION_ID%TYPE ;  /*NSRIVAST, INVCONV*/
g_lab_organization_id       MTL_ORGANIZATIONS.ORGANIZATION_ID%TYPE ; /*NSRIVAST, INVCONV*/
g_ss_organization_id        MTL_ORGANIZATIONS.ORGANIZATION_ID%TYPE ; /*sxfeinst, INVCONV*/

g_from_sample_no            VARCHAR2(80);
g_to_sample_no              VARCHAR2(80);
g_sample_id                 NUMBER;
g_from_result_date          DATE;
g_to_result_date            DATE;
--g_sample_disposition        VARCHAR2(3);
g_in_spec_ind               VARCHAR2(1);
g_evaluation_ind            VARCHAR2(2);
g_tester                    VARCHAR2(30);
g_tester_id                 NUMBER;
g_test_provider_id          NUMBER;
g_planned_resource          VARCHAR2(16);
g_actual_resource           VARCHAR2(16);
g_planned_resource_instance NUMBER;
g_actual_resource_instance  NUMBER;
g_from_test_by_date         DATE;
g_to_test_by_date           DATE;
--g_from_last_update_date     DATE;
--g_to_last_update_date       DATE;
-- START B3124291 Incorporated Mini-Pack K Features to Outboud APIs
--g_planned_resource          VARCHAR2(16);
--g_planned_resource_instance NUMBER;
--g_actual_resource           VARCHAR2(16);
--g_actual_resource_instance  NUMBER;
g_from_planned_result_date  DATE;
g_to_planned_result_date    DATE;
--g_from_test_by_date         DATE;
--g_to_test_by_date           DATE;
-- END B3124291 Incorporated Mini-Pack K Features to Outboud APIs


g_sampling_event_id        NUMBER;
g_from_lot_number          VARCHAR2(80);
g_to_lot_number            VARCHAR2(80);
g_lot_number               VARCHAR2(80);  /*NSRIVAST, INVCONV*/
g_lot_id                    NUMBER;       /*--NSRIVAST, INVCONV*/

g_sample_type	   	    VARCHAR2(2);
g_sublot_no		    VARCHAR2(32); /*NSRIVAST, INVCONV*/
--g_priority		    VARCHAR2(2);
g_spec_name 		    VARCHAR2(80);
g_spec_vers		    NUMBER(10);
g_source		    VARCHAR2(1);
g_from_date_drawn	    DATE;
g_to_date_drawn		    DATE;
g_from_expiration_date	    DATE;
g_to_expiration_date	    DATE;

g_source_whse		    VARCHAR2(4); /*--NSRIVAST, INVCONV*/
g_source_subinventory        MTL_SECONDARY_INVENTORIES.SECONDARY_INVENTORY_NAME%TYPE ;/*NSRIVAST, INVCONV*/

g_source_location	    VARCHAR2(16);
g_grade			    VARCHAR2(4);
g_sample_disposition	    VARCHAR2(3);
g_storage_whse	    VARCHAR2(4); /*--NSRIVAST, INVCONV*/
g_storage_subinventory       MTL_SECONDARY_INVENTORIES.SECONDARY_INVENTORY_NAME%TYPE ;/*NSRIVAST, INVCONV*/

g_storage_location	    VARCHAR2(16);
--g_qc_lab_orgn_code	    VARCHAR2(4);
g_external_id		    VARCHAR2(32);
g_sampler		    VARCHAR2(30);
g_from_date_required	    DATE;
g_to_date_required	    DATE;
g_from_date_received	    DATE;
g_to_date_received	    DATE;
g_lot_retest_ind	    VARCHAR2(1);
g_whse_code		    VARCHAR2(4); /*--NSRIVAST, INVCONV*/
g_subinventory              MTL_SECONDARY_INVENTORIES.SECONDARY_INVENTORY_NAME%TYPE ;/*NSRIVAST, INVCONV*/

g_location		    VARCHAR(16);
g_location_id		    NUMBER;
g_locator_id		    GMD_SAMPLES.locator_id%TYPE; /*--SXFEINST, INVCONV*/
g_source_locator_id		    GMD_SAMPLES.locator_id%TYPE; /*--SXFEINST, INVCONV*/
g_storage_locator_id		    GMD_SAMPLES.locator_id%TYPE; /*--SXFEINST, INVCONV*/

g_wip_plant_code	    VARCHAR2(4);
g_wip_batch_no		    VARCHAR2(32);
g_wip_batch_id		    NUMBER;
g_wip_recipe_no		    VARCHAR2(32);
g_wip_recipe_version	    NUMBER;
g_wip_recipe_id		    NUMBER;
g_wip_formula_no	    VARCHAR2(32);
g_wip_formula_id	    NUMBER;
g_wip_formulaline	    NUMBER(5);
g_wip_formulaline_id	    NUMBER;
g_wip_line_type		    NUMBER(5);
g_wip_routing_no	    VARCHAR2(32);
g_wip_routing_vers  	    NUMBER(5);
g_wip_routing_id	    NUMBER;
g_wip_batchstep_no          NUMBER(10);
g_wip_batchstep_id	    NUMBER(15);
g_wip_oprn_no		    VARCHAR2(16);
g_wip_oprn_vers		    NUMBER(5);
g_wip_oprn_id		    NUMBER;
g_cust_name		    VARCHAR2(240);
g_cust_id		    NUMBER;
--g_cust_org_id		    NUMBER;  /* INVCONV,SXFEINST */
g_org_id		    NUMBER;
g_cust_ship_to_site_id	    NUMBER;
g_cust_order		    NUMBER;
g_cust_order_id		    NUMBER;
g_cust_order_type	    VARCHAR2(30);
g_cust_order_line	    NUMBER;
g_cust_order_line_id	    NUMBER;
g_supplier		    VARCHAR2(30);
g_supplier_id		    NUMBER;
g_supplier_site_id	    NUMBER;
g_supplier_po		    VARCHAR2(20);
g_supplier_po_id	    NUMBER;
g_supplier_po_line	    NUMBER;
g_supplier_po_line_id       NUMBER;
g_non_item_resource	    VARCHAR2(16);
g_non_item_resource_instance NUMBER;

g_from_lot_no               VARCHAR2(80);
g_to_lot_no                 VARCHAR2(80);
g_from_parent_lot_number    VARCHAR2(80); /*--sxfeinst, INVCONV*/
g_to_parent_lot_number      VARCHAR2(80); /*--sxfeinst, INVCONV*/
g_parent_lot_number         VARCHAR2(80); /*--sxfeinst, INVCONV*/
g_from_sublot_no            VARCHAR2(32); /*--NSRIVAST, INVCONV*/
g_to_sublot_no              VARCHAR2(32); /*--NSRIVAST, INVCONV*/
g_sample_event_id           NUMBER;
g_disposition               VARCHAR2(80);

g_wip_orgn_code             VARCHAR2(4);   /*--NSRIVAST, INVCONV*/
g_wip_orgn_id                MTL_ORGANIZATIONS.ORGANIZATION_ID%TYPE ; /*NSRIVAST, INVCONV*/

g_wip_recipe_vers            NUMBER;
g_wip_formula_vers           NUMBER;
g_wip_formulaline_no         NUMBER;
g_wip_formulaline_type       NUMBER;
--g_wip_routing_no             VARCHAR2(32);
--g_wip_routing_vers           NUMBER;
--g_wip_routing_id             NUMBER;
g_wip_step_no                NUMBER;
g_wip_step_id                NUMBER;
--g_wip_oprn_vers              NUMBER;
g_customer                   VARCHAR2(240);
g_customer_id                NUMBER;
g_customer_org_id            NUMBER;
g_customer_ship_to_location  VARCHAR2(240);
g_customer_ship_to_location_id NUMBER;
g_customer_order_number      NUMBER;
g_customer_order_id          NUMBER;
g_customer_order_type        NUMBER;
g_customer_order_line        NUMBER;
g_customer_order_line_id     NUMBER;
g_supplier_site              VARCHAR2(240);
g_supplier_po_number         NUMBER;
-- START B3124291 Incorporated Mini-Pack K Features to Outboud APIs
--g_from_date_received         DATE;
--g_to_date_received           DATE;
--g_from_date_required         DATE;
--g_to_date_required           DATE;
g_resources                  VARCHAR2(16);
g_instance_id                NUMBER;
g_from_retrieval_date        DATE;
g_to_retrieval_date          DATE;
--g_sample_type                VARCHAR2(2);
g_ss_id                      NUMBER;
--g_ss_orgn_code               VARCHAR2(4);
g_ss_no                      VARCHAR2(30);
g_variant_id                 NUMBER;
g_variant_no                 NUMBER;
g_time_point_id              NUMBER;
--g_sg_orgn_code               VARCHAR2(4);/*sxfeinst, INVCONV*/
g_sg_organization_id        MTL_ORGANIZATIONS.ORGANIZATION_ID%TYPE ; /*sxfeinst, INVCONV*/
-- END B3124291 Incorporated Mini-Pack K Features to Outboud APIs
-- Start Incorporated Mini-Pack L Features to Outboud APIs
g_reserve_sample_id          NUMBER;
g_retain_as                  VARCHAR2(3);
-- END Incorporated Mini-Pack L Features to Outboud APIs

/*These variables need to be deleted once all the procedures in this package
are changed for convergence*/
g_from_item_no             VARCHAR2(240); /*--NSRIVAST, INVCONV*/
g_to_item_no               VARCHAR2(240); /*--NSRIVAST, INVCONV*/
g_from_inventory_item_id   NUMBER; /*NSRIVAST, INVCONV*/
g_to_inventory_item_id     NUMBER; /*NSRIVAST, INVCONV*/

-- PLOWE               Bug # 7027149 support for LPN
g_lpn_id NUMBER;
g_lpn VARCHAR2(30);


g_test_methods_table       system.gmd_test_methods_tab_type;
g_tests_table              system.gmd_qc_tests_tab_type;
g_specifications_table     system.gmd_specifications_tab_type;
g_results_table            system.gmd_results_tab_type;
g_composite_results_table  system.gmd_composite_results_tab_type;
g_samples_table   	       system.gmd_samples_tab_type;
g_sample_groups_table      system.gmd_sampling_events_tab_type;

/*#
 * Fetches Sample Test Results
 * This is a PL/SQL procedure to fetch Sample Test Results satisfying
 * the query criterion passed through parameters.
 * @param p_api_version API version field
 * @param p_init_msg_list Flag to check if message list is initialized
 * @param p_user_name Login User Name
 * @param p_orgn_code Organization Code
 * @param p_from_sample_no Starting Sample number
 * @param p_to_sample_no Ending Sample number
 * @param p_sample_id Sample Identifier
 * @param p_from_result_date From Result Date
 * @param p_to_result_date To Result Date
 * @param p_sample_disposition Sample Disposition
 * @param p_in_spec_ind In Specification Indicator
 * @param p_qc_lab_orgn_code Lab Organization Code
 * @param p_evaluation_ind Evaluation Indicator
 * @param p_tester Tester
 * @param p_tester_id Tester Identifier
 * @param p_test_provider_id Test Provider Identifier
 * @param p_delete_mark Delete Mark
 * @param p_from_last_update_date Starting Last Update Date
 * @param p_to_last_update_date Ending Last Update Date
 * @param p_planned_resource Planned Resource
 * @param p_planned_resource_instance Planned Resource Instance
 * @param p_actual_resource Actual Resource
 * @param p_actual_resource_instance Actual Resource Instance
 * @param p_from_planned_result_date Starting Planned Result Date
 * @param p_to_planned_result_date Ending Planned Result Date
 * @param p_from_test_by_date Starting Test By Date
 * @param p_to_test_by_date Ending Test By Date
 * @param p_reserve_sample_id Reserve Sample Identifier
 * @param x_results_table Table Structure of Results table
 * @param x_return_status  'S'-Success, 'E'-Error, 'U'-Unexpected Error
 * @param x_msg_count Number of messages on message stack
 * @param x_msg_data Actual message data on message stack
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Fetch Sample Test Results procedure
 * @rep:compatibility S
 */
PROCEDURE fetch_results
( p_api_version                IN NUMBER
, p_init_msg_list              IN VARCHAR2 DEFAULT FND_API.G_FALSE
, p_user_name                  IN VARCHAR2
, p_orgn_code                  IN VARCHAR2 DEFAULT NULL
, p_from_sample_no             IN VARCHAR2 DEFAULT NULL
, p_to_sample_no               IN VARCHAR2 DEFAULT NULL
, p_sample_id                  IN NUMBER   DEFAULT NULL
, p_from_result_date           IN DATE     DEFAULT NULL
, p_to_result_date             IN DATE     DEFAULT NULL
, p_sample_disposition         IN VARCHAR2 DEFAULT NULL
, p_in_spec_ind                IN VARCHAR2 DEFAULT NULL
, p_qc_lab_orgn_code           IN VARCHAR2 DEFAULT NULL
, p_evaluation_ind             IN VARCHAR2 DEFAULT NULL
, p_tester                     IN VARCHAR2 DEFAULT NULL
, p_tester_id                  IN NUMBER   DEFAULT NULL
, p_test_provider_id           IN NUMBER   DEFAULT NULL
, p_delete_mark                IN NUMBER   DEFAULT NULL
, p_from_last_update_date      IN DATE     DEFAULT NULL
, p_to_last_update_date        IN DATE     DEFAULT NULL
, p_planned_resource           IN VARCHAR2 DEFAULT NULL
, p_planned_resource_instance  IN NUMBER   DEFAULT NULL
, p_actual_resource            IN VARCHAR2 DEFAULT NULL
, p_actual_resource_instance   IN NUMBER   DEFAULT NULL
, p_from_planned_result_date   IN DATE     DEFAULT NULL
, p_to_planned_result_date     IN DATE     DEFAULT NULL
, p_from_test_by_date          IN DATE     DEFAULT NULL
, p_to_test_by_date            IN DATE     DEFAULT NULL
, p_reserve_sample_id          IN NUMBER   DEFAULT NULL
, x_results_table              OUT NOCOPY system.gmd_results_tab_type
, x_return_status              OUT NOCOPY VARCHAR2
, x_msg_count                  OUT NOCOPY NUMBER
, x_msg_data                   OUT NOCOPY VARCHAR2
);

/*#
 * Fetches Composite Results
 * This is a PL/SQL procedure to fetch Composite Results satisfying
 * the query criterion passed through parameters.
 * @param p_api_version API version field
 * @param p_init_msg_list Flag to check if message list is initialized
 * @param p_user_name Login User Name
 * @param p_sampling_event_id Sampling Event Identifier
 * @param p_composite_result_disposition Composite Result Disposition
 * @param p_from_item_number Starting Item Number
 * @param p_to_item_number Ending Item Number
 * @param p_inventory_item_id Item Identifier
 * @param p_from_lot_number Starting Lot Number
 * @param p_lot_number Ending Lot Number
 * @param p_from_last_update_date Starting Last Update Date
 * @param p_to_last_update_date Ending Last Update Date
 * @param p_delete_mark Delete Mark
 * @param x_composite_results_table Table Structure of Composite Results
 * @param x_return_status  'S'-Success, 'E'-Error, 'U'-Unexpected Error
 * @param x_msg_count Number of messages on message stack
 * @param x_msg_data Actual message data on message stack
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Fetch Composite Results procedure
 * @rep:compatibility S
 */
PROCEDURE fetch_composite_results
( p_api_version                  IN NUMBER
, p_init_msg_list                IN VARCHAR2 DEFAULT FND_API.G_FALSE
, p_user_name                    IN VARCHAR2
, p_sampling_event_id            IN NUMBER   DEFAULT NULL
, p_composite_result_disposition IN VARCHAR2 DEFAULT NULL
, p_from_item_number             IN VARCHAR2 DEFAULT NULL /*NSRIVAST, INVCONV*/
, p_to_item_number               IN VARCHAR2 DEFAULT NULL /*NSRIVAST, INVCONV*/
, p_inventory_item_id            IN NUMBER   DEFAULT NULL /*NSRIVAST, INVCONV*/
, p_from_lot_number              IN VARCHAR2 DEFAULT NULL /*NSRIVAST, INVCONV*/
, p_to_lot_number                IN VARCHAR2 DEFAULT NULL /*NSRIVAST, INVCONV*/
, p_lot_number                   IN VARCHAR2 DEFAULT NULL /*NSRIVAST, INVCONV*/
, p_from_last_update_date        IN DATE     DEFAULT NULL
, p_to_last_update_date          IN DATE     DEFAULT NULL
, p_delete_mark                  IN NUMBER   DEFAULT NULL
, x_composite_results_table      OUT NOCOPY system.gmd_composite_results_tab_type
, x_return_status                OUT NOCOPY VARCHAR2
, x_msg_count                    OUT NOCOPY NUMBER
, x_msg_data                     OUT NOCOPY VARCHAR2
);

/*#
 * Fetches Samples
 * This is a PL/SQL procedure to fetch Samples satisfying
 * the query criterion passed through parameters.
 * @param p_api_version API version field
 * @param p_init_msg_list Flag to check if message list is initialized
 * @param p_user_name Login User Name
 * @param p_organization_id Organization
 * @param p_from_sample_no Starting Sample Number
 * @param p_to_sample_no Ending Sample Number
 * @param p_sample_id Sample Identifier
 * @param p_sampling_event_id Sampling Event Identifier
 * @param p_from_item_number Starting Item Number
 * @param p_to_item_number Ending Item Number
 * @param p_inventory_item_id	Item Identifier
 * @param p_from_lot_number	Starting Lot Number
 * @param p_to_lot_number	Ending Lot Number
 * @param p_parent_lot_number	Sub lot Number
 * @param p_priority Priority
 * @param p_spec_name Specification Name
 * @param p_spec_vers	Specification Version
 * @param p_spec_id	Specification Identifier
 * @param p_source Source
 * @param p_from_date_drawn Starting Date Drawn
 * @param p_to_date_drawn	Ending Date Drawn
 * @param p_from_expiration_date Starting Expiration Date
 * @param p_to_expiration_date Ending Expiration Date
 * @param p_source_subinventory	Source Subinventory
 * @param p_source_locator_id	Source Locator_id
 * @param p_grade_code	Grade
 * @param p_sample_disposition Sample Disposition
 * @param p_storage_subinventory Storage Subinventory
 * @param p_storage_locator_id Storage Locator
 * @param p_lab_organization_id Lab Organization Code
 * @param p_external_id	External Identifer
 * @param p_sampler	Sampler
 * @param p_lot_retest_ind Lot Retest Identifier
 * @param p_subinventory	Subinventory Code
 * @param p_locator_id Locator Identifier
 * @param p_wip_plant_code WIP Plant Code
 * @param p_wip_batch_no	WIP Batch Number
 * @param p_wip_batch_id	WIP Batch Identifier
 * @param p_wip_recipe_no	WIP Recipe Number
 * @param p_wip_recipe_version WIP Recipe Version
 * @param p_wip_recipe_id	WIP Recipe Identifier
 * @param p_wip_formula_no WIP Formula Number
 * @param p_wip_formula_version	WIP Formula Version
 * @param p_wip_formula_id WIP Formula Identifier
 * @param p_wip_formulaline	WIP Formula Line
 * @param p_wip_formulaline_id WIP Formula Line Identifier
 * @param p_wip_line_type	WIP Line Type
 * @param p_wip_routing_no WIP Routing Number
 * @param p_wip_routing_vers WIP Routing Version
 * @param p_wip_routing_id WIP Routing Identifier
 * @param p_wip_batchstep_no WIP Batch Step Number
 * @param p_wip_batchstep_id WIP Batch Step Identifier
 * @param p_wip_oprn_no	WIP Operation Number
 * @param p_wip_oprn_vers	WIP Operation Version
 * @param p_wip_oprn_id	WIP Operation Identifier
 * @param p_cust_name	Customer Name
 * @param p_cust_id	Customer Identifier
 * @param p_org_id Organization Identifier for Customer or Supplier
 * @param p_cust_ship_to_site_id Customer Ship to Site Identifier
 * @param p_cust_order Customer Order
 * @param p_cust_order_id	Customer Order Identifier
 * @param p_cust_order_type Customer Order Type
 * @param p_cust_order_line	Customer Order Line
 * @param p_cust_order_line_id Customer Order Line Identifier
 * @param p_supplier Supplier
 * @param p_supplier_id	Supplier Identifier
 * @param p_supplier_site_id Supplier Site Identifier
 * @param p_supplier_po Supplier Purchase Order
 * @param p_supplier_po_id Supplier Purchase Order Identifier
 * @param p_supplier_po_line Supplier Purchase Order Line
 * @param p_supplier_po_line_id	Supplier Purchase Order Line Identifier
 * @param p_from_date_received Starting Date Received
 * @param p_to_date_received Ending Date Received
 * @param p_from_date_required Starting Date Required
 * @param p_to_date_required Ending Date Required
 * @param p_resources Resource
 * @param p_instance_id Resource Instance Identifier
 * @param p_from_retrieval_date Starting Retrieval Date
 * @param p_to_retrieval_date Ending Retrieval Date
 * @param p_sample_type Sample Type
 * @param p_ss_id Stability Study Identifier
 * @param p_ss_organization_id Stability Study Organization
 * @param p_ss_no Stability Study Number
 * @param p_variant_id Variant Identifier
 * @param p_variant_no Variant Number
 * @param p_time_point_id Time Point Identifier
 * @param p_from_last_update_date Starting Last Update Date
 * @param p_to_last_update_date Ending Last Update Date
 * @param p_retain_as Retain As
 * @param p_delete_mark	Delete Mark
 * @param p_lpn License Plate Number
 * @param p_lpn_id License Plate Number Identifier
 * @param x_samples_table Table Structure of Samples
 * @param x_return_status  'S'-Success, 'E'-Error, 'U'-Unexpected Error
 * @param x_msg_count Number of messages on message stack
 * @param x_msg_data Actual message data on message stack
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Fetch Samples procedure
 * @rep:compatibility S
 */
PROCEDURE fetch_samples
( p_api_version                  IN NUMBER
, p_init_msg_list                IN VARCHAR2 DEFAULT FND_API.G_FALSE
, p_user_name                    IN VARCHAR2
, p_organization_id              IN NUMBER   DEFAULT NULL
, p_from_sample_no               IN VARCHAR2 DEFAULT NULL
, p_to_sample_no                 IN VARCHAR2 DEFAULT NULL
, p_sample_id                    IN NUMBER   DEFAULT NULL
, p_sampling_event_id            IN NUMBER   DEFAULT NULL
, p_from_item_number             IN VARCHAR2 DEFAULT NULL /*bug 4165704, INVCONV*/
, p_to_item_number               IN VARCHAR2 DEFAULT NULL /*bug 4165704, INVCONV*/
, p_inventory_item_id            IN NUMBER   DEFAULT NULL /*bug 4165704, INVCONV*/
, p_revision                     IN VARCHAR2 DEFAULT NULL /*bug 4165704, INVCONV*/
, p_from_lot_number              IN VARCHAR2 DEFAULT NULL /*bug 4165704, INVCONV*/
, p_to_lot_number                IN VARCHAR2 DEFAULT NULL /*bug 4165704, INVCONV*/
, p_parent_lot_number            IN VARCHAR2 DEFAULT NULL /*bug 4165704, INVCONV*/
, p_priority                     IN VARCHAR2 DEFAULT NULL
, p_spec_name                    IN VARCHAR2 DEFAULT NULL
, p_spec_vers                    IN VARCHAR2 DEFAULT NULL
, p_spec_id                      IN NUMBER   DEFAULT NULL
, p_source                       IN VARCHAR2 DEFAULT NULL
, p_from_date_drawn              IN DATE     DEFAULT NULL
, p_to_date_drawn                IN DATE     DEFAULT NULL
, p_from_expiration_date         IN DATE     DEFAULT NULL
, p_to_expiration_date           IN DATE     DEFAULT NULL
, p_from_date_received           IN DATE     DEFAULT NULL
, p_to_date_received             IN DATE     DEFAULT NULL
, p_from_date_required           IN DATE     DEFAULT NULL
, p_to_date_required             IN DATE     DEFAULT NULL
, p_resources                    IN VARCHAR2 DEFAULT NULL
, p_instance_id                  IN NUMBER   DEFAULT NULL
, p_from_retrieval_date          IN DATE     DEFAULT NULL
, p_to_retrieval_date            IN DATE     DEFAULT NULL
, p_sample_type                  IN VARCHAR2 DEFAULT NULL
, p_ss_id                        IN NUMBER   DEFAULT NULL
, p_ss_organization_id           IN VARCHAR2 DEFAULT NULL
, p_ss_no                        IN VARCHAR2 DEFAULT NULL
, p_variant_id                   IN NUMBER   DEFAULT NULL
, p_variant_no                   IN NUMBER   DEFAULT NULL
, p_time_point_id                IN NUMBER   DEFAULT NULL
, p_source_subinventory          IN VARCHAR2 DEFAULT NULL
, p_source_locator_id            IN NUMBER   DEFAULT NULL
, p_grade_code                   IN VARCHAR2 DEFAULT NULL
, p_sample_disposition           IN VARCHAR2 DEFAULT NULL
, p_storage_subinventory         IN VARCHAR2 DEFAULT NULL
, p_storage_locator_id           IN NUMBER   DEFAULT NULL
, p_lab_organization_id          IN VARCHAR2 DEFAULT NULL
, p_external_id                  IN VARCHAR2 DEFAULT NULL
, p_sampler                      IN VARCHAR2 DEFAULT NULL
, p_lot_retest_ind               IN VARCHAR2 DEFAULT NULL
, p_subinventory                 IN VARCHAR2 DEFAULT NULL
, p_locator_id                   IN NUMBER   DEFAULT NULL
, p_wip_plant_code               IN VARCHAR2 DEFAULT NULL
, p_wip_batch_no                 IN VARCHAR2 DEFAULT NULL
, p_wip_batch_id                 IN NUMBER   DEFAULT NULL
, p_wip_recipe_no                IN VARCHAR2 DEFAULT NULL
, p_wip_recipe_version           IN NUMBER   DEFAULT NULL
, p_wip_recipe_id                IN NUMBER   DEFAULT NULL
, p_wip_formula_no               IN VARCHAR2 DEFAULT NULL
, p_wip_formula_version          IN NUMBER   DEFAULT NULL
, p_wip_formula_id               IN NUMBER   DEFAULT NULL
, p_wip_formulaline              IN NUMBER   DEFAULT NULL
, p_wip_formulaline_id           IN NUMBER   DEFAULT NULL
, p_wip_line_type                IN NUMBER   DEFAULT NULL
, p_wip_routing_no               IN VARCHAR2 DEFAULT NULL
, p_wip_routing_vers             IN NUMBER   DEFAULT NULL
, p_wip_routing_id               IN NUMBER   DEFAULT NULL
, p_wip_batchstep_no             IN NUMBER   DEFAULT NULL
, p_wip_batchstep_id             IN NUMBER   DEFAULT NULL
, p_wip_oprn_no                  IN VARCHAR2 DEFAULT NULL
, p_wip_oprn_vers                IN NUMBER   DEFAULT NULL
, p_wip_oprn_id                  IN NUMBER   DEFAULT NULL
, p_cust_name                    IN VARCHAR2 DEFAULT NULL
, p_cust_id                      IN NUMBER   DEFAULT NULL
, p_org_id                       IN NUMBER   DEFAULT NULL
, p_cust_ship_to_site_id         IN NUMBER   DEFAULT NULL
, p_cust_order                   IN VARCHAR2 DEFAULT NULL
, p_cust_order_id                IN NUMBER   DEFAULT NULL
, p_cust_order_type              IN VARCHAR2 DEFAULT NULL
, p_cust_order_line              IN NUMBER   DEFAULT NULL
, p_cust_order_line_id           IN NUMBER   DEFAULT NULL
, p_supplier                     IN VARCHAR2 DEFAULT NULL
, p_supplier_id                  IN NUMBER   DEFAULT NULL
, p_supplier_site_id             IN NUMBER   DEFAULT NULL
, p_supplier_po                  IN VARCHAR2 DEFAULT NULL
, p_supplier_po_id               IN NUMBER   DEFAULT NULL
, p_supplier_po_line             IN NUMBER   DEFAULT NULL
, p_supplier_po_line_id          IN NUMBER   DEFAULT NULL
, p_from_last_update_date        IN DATE     DEFAULT NULL
, p_to_last_update_date          IN DATE     DEFAULT NULL
, p_retain_as                    IN VARCHAR2 DEFAULT NULL
, p_delete_mark                  IN NUMBER   DEFAULT NULL
, p_lpn                          IN VARCHAR2 DEFAULT NULL -- 7027149
, p_lpn_id 	      	             IN NUMBER   DEFAULT NULL-- 7027149
, x_samples_table                OUT NOCOPY system.gmd_samples_tab_type
, x_return_status                OUT NOCOPY VARCHAR2
, x_msg_count                    OUT NOCOPY NUMBER
, x_msg_data                     OUT NOCOPY VARCHAR2
);

/*#
 * Fetches Test Methods
 * This is a PL/SQL procedure to fetch Test Methods satisfying
 * the query criterion passed through parameters.
 * @param p_api_version API version field
 * @param p_init_msg_list Flag to check if message list is initialized
 * @param p_user_name Login User Name
 * @param p_from_test_method_code Starting Test Method Code
 * @param p_to_test_method_code Ending Test Code
 * @param p_test_method_id Test Method Identifier
 * @param p_test_kit_organization_id Test Kit Item Number
 * @param p_test_kit_inv_item_id Test Kit Item Identifier
 * @param p_resource Resource
 * @param p_delete_mark Delete Mark
 * @param p_from_last_update_date Starting Last Update Date
 * @param p_to_last_update_date Ending Last Update Date
 * @param x_test_methods_table Test Methods Table
 * @param x_return_status  'S'-Success, 'E'-Error, 'U'-Unexpected Error
 * @param x_msg_count Number of messages on message stack
 * @param x_msg_data Actual message data on message stack
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Fetch Test Methods procedure
 * @rep:compatibility S
 */
PROCEDURE fetch_test_methods
( p_api_version            IN NUMBER
, p_init_msg_list          IN VARCHAR2 DEFAULT FND_API.G_FALSE
, p_user_name              IN VARCHAR2
, p_from_test_method_code  IN VARCHAR2 DEFAULT NULL
, p_to_test_method_code    IN VARCHAR2 DEFAULT NULL
, p_test_method_id         IN NUMBER   DEFAULT NULL
, p_test_kit_organization_id IN NUMBER DEFAULT NULL
, p_test_kit_inv_item_id IN NUMBER DEFAULT NULL
, p_resource               IN VARCHAR2 DEFAULT NULL
, p_delete_mark            IN NUMBER   DEFAULT NULL
, p_from_last_update_date  IN DATE     DEFAULT NULL
, p_to_last_update_date    IN DATE     DEFAULT NULL
, x_test_methods_table     OUT NOCOPY system.gmd_test_methods_tab_type
, x_return_status          OUT NOCOPY VARCHAR2
, x_msg_count              OUT NOCOPY NUMBER
, x_msg_data               OUT NOCOPY VARCHAR2
);

/*#
 * Fetches Tests
 * This is a PL/SQL procedure to fetch Tests satisfying
 * the query criterion passed through parameters.
 * @param p_api_version API version field
 * @param p_init_msg_list Flag to check if message list is initialized
 * @param p_user_name Login User Name
 * @param p_from_test_code Starting Test Code
 * @param p_to_test_code Ending Test Code
 * @param p_from_test_method_code Starting Test Method Code
 * @param p_to_test_method_code Ending Test Method Code
 * @param p_test_id Testing Identifier
 * @param p_test_method_id Test Method Identifier
 * @param p_test_class Test Class
 * @param p_test_type Test Type
 * @param p_priority Priority
 * @param p_delete_mark Delete Mark
 * @param p_from_last_update_date Starting Last Update Date
 * @param p_to_last_update_date Ending Last Update Date
 * @param x_tests_table Table Structure of Tests
 * @param x_return_status  'S'-Success, 'E'-Error, 'U'-Unexpected Error
 * @param x_msg_count Number of messages on message stack
 * @param x_msg_data Actual message data on message stack
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Fetch Tests procedure
 * @rep:compatibility S
 */
PROCEDURE fetch_tests
( p_api_version            IN NUMBER
, p_init_msg_list          IN VARCHAR2 DEFAULT FND_API.G_FALSE
, p_user_name              IN VARCHAR2
, p_from_test_code         IN VARCHAR2 DEFAULT NULL
, p_to_test_code           IN VARCHAR2 DEFAULT NULL
, p_from_test_method_code  IN VARCHAR2 DEFAULT NULL
, p_to_test_method_code    IN VARCHAR2 DEFAULT NULL
, p_test_id                IN NUMBER   DEFAULT NULL
, p_test_method_id         IN NUMBER   DEFAULT NULL
, p_test_class             IN VARCHAR2 DEFAULT NULL
, p_test_type              IN VARCHAR2 DEFAULT NULL
, p_priority               IN VARCHAR2 DEFAULT NULL
, p_delete_mark            IN NUMBER   DEFAULT NULL
, p_from_last_update_date  IN DATE     DEFAULT NULL
, p_to_last_update_date    IN DATE     DEFAULT NULL
, x_tests_table            OUT NOCOPY system.gmd_qc_tests_tab_type
, x_return_status          OUT NOCOPY VARCHAR2
, x_msg_count              OUT NOCOPY NUMBER
, x_msg_data               OUT NOCOPY VARCHAR2
);

/*#
 * Fetches Specification Validity Rules
 * This is a PL/SQL procedure to fetch Tests satisfying
 * the query criterion passed through parameters.
 * @param p_api_version API version field
 * @param p_init_msg_list Flag to check if message list is initialized
 * @param p_user_name Login User Name
 * @param p_from_spec_name Starting Specification Name
 * @param p_to_spec_name Ending Specification Name
 * @param p_spec_id Specification Identifier
 * @param p_spec_version Specification Version
 * @param p_from_grade_code Starting Grade Code
 * @param p_to_grade_code Ending Grade Code
 * @param p_from_item_number Starting Item Number
 * @param p_to_item_number Ending Item Number
 * @param p_inventory_item_id Item Identifier
 * @param p_from_spec_last_update Starting Specification Last Update Date
 * @param p_to_spec_last_update Ending Specification Last Update Date
 * @param p_spec_status Specification Status
 * @param p_owner_organization_code Owner Organization Code
 * @param p_spec_delete_mark Specification Delete Mark
 * @param p_overlay_ind Overlay Flag
 * @param p_spec_type Specification Type
 * @param p_base_spec_id Base Specification Identifier
 * @param p_base_spec_name Base Specification Name
 * @param p_base_spec_version Base Specification Version
 * @param p_test_code Test Code
 * @param p_test_id	Test Identifier
 * @param p_test_method_code Test Method Code
 * @param p_test_method_id Test Method Identifier
 * @param p_test_qty_uom Test Unit Of Measure
 * @param p_test_priority Test Priority
 * @param p_from_test_last_update Starting Test Last Update Date
 * @param p_to_test_last_update Ending Test Last Update Date
 * @param p_test_delete_mark Test Delete Mark
 * @param p_from_base_ind From Base Indicator
 * @param p_exclude_ind Exclude Indicator
 * @param p_modified_ind Modified Indicator
 * @param p_calc_uom_conv_ind Calculate uom Conversion Indicator
 * @param p_to_qty_uom To uom
 * @param p_wip_vr_status WIP Validity Rule Status
 * @param p_wip_vr_organization_code WIP Validity Rule Organization
 * @param p_wip_vr_batch_orgn_code WIP Validity Rule Batch Organization
 * @param p_wip_vr_batch_no WIP Validity Rule Batch Number
 * @param p_wip_vr_batch_id WIP Validity Rule Batch Identifier
 * @param p_wip_vr_recipe_no WIP Validity Rule Recipe Number
 * @param p_wip_vr_recipe_version WIP Validity Rule Recipe Version
 * @param p_wip_vr_recipe_id WIP Validity Rule Recipe Identifier
 * @param p_wip_vr_formula_no WIP Validity Rule Formula Number
 * @param p_wip_vr_formula_version WIP Validity Rule Formula Version
 * @param p_wip_vr_formula_id WIP Validity Rule Formula Identifier
 * @param p_wip_vr_formulaline_no WIP Validity Rule Formula Line Number
 * @param p_wip_vr_formulaline_id WIP Validity Rule Formula Line Identifier
 * @param p_wip_vr_line_type WIP Validity Rule Line Type
 * @param p_wip_vr_routing_no WIP Validity Rule Routing Number
 * @param p_wip_vr_routing_version WIP Validity Rule Routing Version
 * @param p_wip_vr_routing_id WIP Validity Rule Routing Identifier
 * @param p_wip_vr_step_no WIP Validity Rule Step Number
 * @param p_wip_vr_step_id WIP Validity Rule Step Identifier
 * @param p_wip_vr_operation_no WIP Validity Rule Operation Number
 * @param p_wip_vr_operation_version WIP Validity Rule Operation Version
 * @param p_wip_vr_operation_id WIP Validity Rule Operation Identifier
 * @param p_wip_vr_start_date WIP Validity Rule Start Date
 * @param p_wip_vr_end_date WIP Validity Rule End Date
 * @param p_wip_vr_coa_type WIP Validity Rule Certificate Type
 * @param p_wip_vr_sampling_plan WIP Validity Rule Sampling Plan
 * @param p_wip_vr_sampling_plan_id WIP Validity Rule Sampling Plan Identifier
 * @param p_wip_vr_delete_mark WIP Validity Rule Delete Mark
 * @param p_wip_vr_from_last_update Starting WIP Validity Rule Last Update Date
 * @param p_wip_vr_to_last_update Ending WIP Validity Rule Last Update Date
 * @param p_cust_vr_start_date Customer Validity Rule Start Date
 * @param p_cust_vr_end_date Customer Validity Rule End Date
 * @param p_cust_vr_status Customer Validity Rule Status
 * @param p_cust_vr_organization_code Customer Validity Rule Organization Code
 * @param p_cust_vr_org_id Customer Validity Rule Operating unit Identifier
 * @param p_cust_vr_coa_type Customer Validity Rule Certificate Type
 * @param p_cust_vr_customer Customer Validity Customer
 * @param p_cust_vr_customer_id Customer Validity Rule Customer Identifier
 * @param p_cust_vr_order_number Customer Validity Rule Order Number
 * @param p_cust_vr_order_id Customer Validity Rule Order Identifier
 * @param p_cust_vr_order_type Customer Validity Rule Order Type
 * @param p_cust_vr_order_line_no Customer Validity Rule Order Line Number
 * @param p_cust_vr_order_line_id Customer Validity Rule Order Line Identifier
 * @param p_cust_vr_ship_to_location Customer Validity Rule Ship to Location
 * @param p_cust_vr_ship_to_site_id Customer Validity Rule Ship to Site Identifier
 * @param p_cust_vr_operating_unit Customer Validity Rule Operating Unit
 * @param p_cust_vr_delete_mark Customer Validity Rule Delete Mark
 * @param p_cust_vr_from_last_update Starting Customer Validity Rule Last Update Date
 * @param p_cust_vr_to_last_update Ending Customer Validity Rule Last Update Date
 * @param p_supl_vr_start_date Supplier Validity Rule Start Date
 * @param p_supl_vr_end_date Supplier Validity Rule End Date
 * @param p_supl_vr_status Supplier Validity Rule Status
 * @param p_supl_vr_organization_code Supplier Validity Rule Organization Code
 * @param p_supl_vr_org_id Supplier Validity Rule Organization Identifier
 * @param p_supl_vr_coa_type Supplier Validity Rule Certificate Type
 * @param p_supl_vr_supplier Supplier Validity Rule Supplier
 * @param p_supl_vr_supplier_id Supplier Validity Rule Supplier Identifier
 * @param p_supl_vr_po_number Supplier Validity Rule Purchase Order Number
 * @param p_supl_vr_po_id Supplier Validity Rule Purchase Order Identifier
 * @param p_supl_vr_po_line_no Supplier Validity Rule Purchase Order Line Number
 * @param p_supl_vr_po_line_id Supplier Validity Rule Purchase Order Line Identifier
 * @param p_supl_vr_supplier_site Supplier Validity Rule Supplier Site
 * @param p_supl_vr_supplier_site_id Supplier Validity Rule Supplier Site Identifier
 * @param p_supl_vr_operating_unit Supplier Validity Rule Operating unit
 * @param p_supl_vr_delete_mark Supplier Validity Rule Delete Mark
 * @param p_supl_vr_from_last_update Starting Supplier Validity Rule Last Update Date
 * @param p_supl_vr_to_last_update Ending Supplier Validity Rule Last Update Date
 * @param p_inv_vr_start_date Inventory Validity Rule Start Date
 * @param p_inv_vr_end_date Inventory Validity Rule End Date
 * @param p_inv_vr_status Inventory Validity Rule Status
 * @param p_inv_vr_organization_code Inventory Validity Rule Organization Code
 * @param p_inv_vr_coa_type Inventory Validity Rule Certificate Type
 * @param p_inv_vr_item_number Inventory Validity Rule Item Number
 * @param p_inv_vr_inventory_item_id Inventory Validity Rule Item Identifier
 * @param p_inv_vr_parent_lot_number Inventory Validity Rule Parent Lot Number
 * @param p_inv_vr_lot_number Inventory Validity Rule Lot Number
 * @param p_inv_vr_subinventory Inventory Validity Rule Subinventory
 * @param p_inv_vr_locator Inventory Validity Rule Locator
 * @param p_inv_vr_locator_id Inventory Validity Rule Locator Identifier
 * @param p_inv_vr_sampling_plan Inventory Validity Rule Sampling Plan
 * @param p_inv_vr_sampling_plan_id Inventory Validity Rule Sampling Plan Identifier
 * @param p_inv_vr_delete_mark Inventory Validity Rule Delete Mark
 * @param p_inv_vr_from_last_update Starting Inventory Validity Rule Last Update Date
 * @param p_inv_vr_to_last_update Ending Inventory Validity Rule Last Update Date
 * @param p_mon_vr_status Monitoring Validity Rule Status
 * @param p_mon_vr_rule_type Monitoring Validity Rule Type
 * @param p_mon_vr_lct_organization_code Monitoring Validity Rule Location Organization Code
 * @param p_mon_vr_subinventory Monitoring Validity Rule Subinventory
 * @param p_mon_vr_locator_id Monitoring Validity Rule Locator Identifier
 * @param p_mon_vr_locator Monitoring Validity Rule Locator
 * @param p_mon_vr_rsr_organization_code Monitoring Validity Rule Resource Organization Code
 * @param p_mon_vr_resources Monitoring Validity Rule Resources
 * @param p_mon_vr_resource_instance_id Monitoring Validity Rule Resource Instance Identifier
 * @param p_mon_vr_sampling_plan Monitoring Validity Rule Sampling Plan
 * @param p_mon_vr_sampling_plan_id Monitoring Validity Rule Sampling Plan Identifier
 * @param p_mon_vr_start_date Monitoring Validity Rule Start Date
 * @param p_mon_vr_end_date Monitoring Validity Rule End Date
 * @param p_mon_vr_from_last_update_date Starting Monitoring Validity Rule Last Update Date
 * @param p_mon_vr_to_last_update_date Ending Monitoring Validity Rule Last Update Date
 * @param p_mon_vr_delete_mark Monitoring Validity Rule Delete Mark
 * @param x_specifications_tbl Table Structure of Specifications
 * @param x_return_status  'S'-Success, 'E'-Error, 'U'-Unexpected Error
 * @param x_msg_count Number of messages on message stack
 * @param x_msg_data Actual message data on message stack
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Fetch Specification Validity Rules procedure
 * @rep:compatibility S
 */
PROCEDURE fetch_spec_vrs
( p_api_version            IN NUMBER
, p_init_msg_list          IN VARCHAR2 DEFAULT FND_API.G_FALSE
, p_user_name              IN VARCHAR2

-- Parameters relating to specifications

, p_from_spec_name	   IN VARCHAR2 DEFAULT NULL
, p_to_spec_name    	   IN VARCHAR2 DEFAULT NULL
, p_spec_id		   IN NUMBER   DEFAULT NULL
, p_spec_version    	   IN NUMBER   DEFAULT NULL
, p_from_grade_code        	   IN VARCHAR2 DEFAULT NULL
, p_to_grade_code               IN VARCHAR2 DEFAULT NULL
, p_from_item_number    	   IN VARCHAR2 DEFAULT NULL
, p_to_item_number  	   IN VARCHAR2 DEFAULT NULL
, p_inventory_item_id                IN NUMBER   DEFAULT NULL
, p_from_revision          IN VARCHAR2 DEFAULT NULL  -- RLNAGARA Bug # 4548546
, p_to_revision            IN VARCHAR2 DEFAULT NULL  -- RLNAGARA Bug # 4548546
, p_from_spec_last_update  IN DATE     DEFAULT NULL
, p_to_spec_last_update    IN DATE     DEFAULT NULL
, p_spec_status            IN NUMBER   DEFAULT NULL
, p_owner_organization_code IN VARCHAR2 DEFAULT NULL
, p_spec_delete_mark       IN NUMBER   DEFAULT NULL

-- START B3124291 Incorporated Mini-Pack K Features to Outboud APIs
, p_overlay_ind            IN VARCHAR2 DEFAULT NULL
, p_spec_type              IN VARCHAR2 DEFAULT NULL
, p_base_spec_id           IN NUMBER   DEFAULT NULL
, p_base_spec_name         IN VARCHAR2 DEFAULT NULL
, p_base_spec_version      IN NUMBER   DEFAULT NULL
-- END B3124291 Incorporated Mini-Pack K Features to Outboud APIs

-- Parameters relating to spec tests

, p_test_code		   IN VARCHAR2 DEFAULT NULL
, p_test_id  		   IN NUMBER   DEFAULT NULL
, p_test_method_code	   IN VARCHAR2 DEFAULT NULL
, p_test_method_id	   IN NUMBER   DEFAULT NULL
, p_test_qty_uom		   IN VARCHAR2 DEFAULT NULL
, p_test_priority	   IN VARCHAR2 DEFAULT NULL
, p_from_test_last_update  IN DATE     DEFAULT NULL
, p_to_test_last_update	   IN DATE     DEFAULT NULL
, p_test_delete_mark       IN NUMBER   DEFAULT NULL
-- START B3124291 Incorporated Mini-Pack K Features to Outboud APIs
, p_from_base_ind          IN VARCHAR2 DEFAULT NULL
, p_exclude_ind            IN VARCHAR2 DEFAULT NULL
, p_modified_ind           IN VARCHAR2 DEFAULT NULL
, p_calc_uom_conv_ind      IN VARCHAR2 DEFAULT NULL
, p_to_qty_uom             IN VARCHAR2 DEFAULT NULL
-- END B3124291 Incorporated Mini-Pack K Features to Outboud APIs

-- Parameters relating to wip spec validity rules

, p_wip_vr_status	   IN NUMBER   DEFAULT NULL
, p_wip_vr_organization_code  IN VARCHAR2 DEFAULT NULL
, p_wip_vr_batch_orgn_code IN VARCHAR2 DEFAULT NULL
, p_wip_vr_batch_no        IN VARCHAR2 DEFAULT NULL
, p_wip_vr_batch_id        IN NUMBER   DEFAULT NULL
, p_wip_vr_recipe_no       IN VARCHAR2 DEFAULT NULL
, p_wip_vr_recipe_version  IN NUMBER   DEFAULT NULL
, p_wip_vr_recipe_id       IN NUMBER   DEFAULT NULL
, p_wip_vr_formula_no      IN VARCHAR2 DEFAULT NULL
, p_wip_vr_formula_version IN NUMBER   DEFAULT NULL
, p_wip_vr_formula_id      IN NUMBER   DEFAULT NULL
, p_wip_vr_formulaline_no  IN NUMBER   DEFAULT NULL
, p_wip_vr_formulaline_id  IN NUMBER   DEFAULT NULL
, p_wip_vr_line_type       IN NUMBER   DEFAULT NULL
, p_wip_vr_routing_no      IN VARCHAR2 DEFAULT NULL
, p_wip_vr_routing_version IN NUMBER   DEFAULT NULL
, p_wip_vr_routing_id      IN NUMBER   DEFAULT NULL
, p_wip_vr_step_no         IN NUMBER   DEFAULT NULL
, p_wip_vr_step_id         IN NUMBER   DEFAULT NULL
, p_wip_vr_operation_no    IN VARCHAR2 DEFAULT NULL
, p_wip_vr_operation_version IN NUMBER   DEFAULT NULL
, p_wip_vr_operation_id    IN NUMBER   DEFAULT NULL
, p_wip_vr_start_date	   IN DATE     DEFAULT NULL
, p_wip_vr_end_date	   IN DATE     DEFAULT NULL
, p_wip_vr_coa_type	   IN VARCHAR2 DEFAULT NULL
, p_wip_vr_sampling_plan   IN VARCHAR2 DEFAULT NULL
, p_wip_vr_sampling_plan_id IN NUMBER   DEFAULT NULL
, p_wip_vr_delete_mark	   IN NUMBER   DEFAULT NULL
, p_wip_vr_from_last_update IN DATE     DEFAULT NULL
, p_wip_vr_to_last_update	 IN DATE     DEFAULT NULL

-- Parameters relating to customer spec validity rules
, p_cust_vr_start_date     IN DATE     DEFAULT NULL
, p_cust_vr_end_date       IN DATE     DEFAULT NULL
, p_cust_vr_status         IN NUMBER   DEFAULT NULL
, p_cust_vr_organization_code IN VARCHAR2 DEFAULT NULL
, p_cust_vr_org_id         IN NUMBER   DEFAULT NULL
, p_cust_vr_coa_type       IN VARCHAR2 DEFAULT NULL
, p_cust_vr_customer       IN VARCHAR2 DEFAULT NULL
, p_cust_vr_customer_id	   IN NUMBER   DEFAULT NULL
, p_cust_vr_order_number   IN NUMBER   DEFAULT NULL
, p_cust_vr_order_id       IN NUMBER   DEFAULT NULL
, p_cust_vr_order_type     IN NUMBER   DEFAULT NULL
, p_cust_vr_order_line_no  IN NUMBER   DEFAULT NULL
, p_cust_vr_order_line_id  IN NUMBER   DEFAULT NULL
, p_cust_vr_ship_to_location IN VARCHAR2 DEFAULT NULL
, p_cust_vr_ship_to_site_id  IN NUMBER   DEFAULT NULL
, p_cust_vr_operating_unit IN VARCHAR
, p_cust_vr_delete_mark    IN NUMBER   DEFAULT NULL
, p_cust_vr_from_last_update IN DATE     DEFAULT NULL
, p_cust_vr_to_last_update IN DATE     DEFAULT NULL

-- Parameters relating to supplier spec validity rules
, p_supl_vr_start_date     IN DATE     DEFAULT NULL
, p_supl_vr_end_date       IN DATE     DEFAULT NULL
, p_supl_vr_status         IN NUMBER   DEFAULT NULL
, p_supl_vr_organization_code IN VARCHAR2 DEFAULT NULL
, p_supl_vr_org_id         IN NUMBER   DEFAULT NULL
, p_supl_vr_coa_type       IN VARCHAR2 DEFAULT NULL
, p_supl_vr_supplier       IN VARCHAR2 DEFAULT NULL
, p_supl_vr_supplier_id    IN NUMBER   DEFAULT NULL
, p_supl_vr_po_number      IN NUMBER   DEFAULT NULL
, p_supl_vr_po_id          IN NUMBER   DEFAULT NULL
, p_supl_vr_po_line_no     IN NUMBER   DEFAULT NULL
, p_supl_vr_po_line_id     IN NUMBER   DEFAULT NULL
, p_supl_vr_supplier_site  IN VARCHAR2 DEFAULT NULL
, p_supl_vr_supplier_site_id IN NUMBER   DEFAULT NULL
, p_supl_vr_operating_unit IN VARCHAR2 DEFAULT NULL
, p_supl_vr_delete_mark         IN NUMBER   DEFAULT NULL
, p_supl_vr_from_last_update    IN DATE     DEFAULT NULL
, p_supl_vr_to_last_update IN DATE     DEFAULT NULL

-- Parameters relating to inventory spec validity rules
, p_inv_vr_start_date     IN DATE     DEFAULT NULL
, p_inv_vr_end_date       IN DATE     DEFAULT NULL
, p_inv_vr_status         IN NUMBER   DEFAULT NULL
, p_inv_vr_organization_code IN VARCHAR2 DEFAULT NULL
, p_inv_vr_coa_type       IN VARCHAR2 DEFAULT NULL
, p_inv_vr_item_number    IN VARCHAR2 DEFAULT NULL
, p_inv_vr_inventory_item_id  IN NUMBER   DEFAULT NULL
, p_inv_vr_parent_lot_number  IN VARCHAR2 DEFAULT NULL
, p_inv_vr_lot_number      IN VARCHAR2 DEFAULT NULL
, p_inv_vr_subinventory      IN VARCHAR2 DEFAULT NULL
, p_inv_vr_locator    IN VARCHAR2   DEFAULT NULL
, p_inv_vr_locator_id    IN NUMBER   DEFAULT NULL
, p_inv_vr_sampling_plan  IN VARCHAR2 DEFAULT NULL
, p_inv_vr_sampling_plan_id IN NUMBER   DEFAULT NULL
, p_inv_vr_delete_mark         IN NUMBER   DEFAULT NULL
, p_inv_vr_from_last_update    IN DATE     DEFAULT NULL
, p_inv_vr_to_last_update IN DATE     DEFAULT NULL

-- START B3124291 Incorporated Mini-Pack K Features to Outboud APIs
-- Parameters relating to monitor spec
, p_mon_vr_status                IN NUMBER   DEFAULT NULL
, p_mon_vr_rule_type             IN VARCHAR2 DEFAULT NULL
, p_mon_vr_lct_organization_code IN VARCHAR2 DEFAULT NULL
, p_mon_vr_subinventory          IN VARCHAR2 DEFAULT NULL
, p_mon_vr_locator_id            IN NUMBER DEFAULT NULL
, p_mon_vr_locator               IN VARCHAR2 DEFAULT NULL
, p_mon_vr_rsr_organization_code    IN VARCHAR2 DEFAULT NULL
, p_mon_vr_resources             IN VARCHAR2 DEFAULT NULL
, p_mon_vr_resource_instance_id  IN NUMBER   DEFAULT NULL
, p_mon_vr_sampling_plan         IN VARCHAR2 DEFAULT NULL
, p_mon_vr_sampling_plan_id      IN NUMBER   DEFAULT NULL
, p_mon_vr_start_date            IN DATE     DEFAULT NULL
, p_mon_vr_end_date              IN DATE     DEFAULT NULL
, p_mon_vr_from_last_update_date IN DATE     DEFAULT NULL
, p_mon_vr_to_last_update_date   IN DATE     DEFAULT NULL
, p_mon_vr_delete_mark           IN NUMBER   DEFAULT NULL
-- END B3124291 Incorporated Mini-Pack K Features to Outboud APIs

-- Return parameters

, x_specifications_tbl     OUT NOCOPY system.gmd_specifications_tab_type
, x_return_status     	   OUT NOCOPY VARCHAR2
, x_msg_count          	   OUT NOCOPY NUMBER
, x_msg_data               OUT NOCOPY VARCHAR2
);

end gmd_outbound_apis_pub;

/
