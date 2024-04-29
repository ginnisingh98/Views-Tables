--------------------------------------------------------
--  DDL for Package Body GMF_MIGRATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMF_MIGRATION" AS
/* $Header: gmfmigrb.pls 120.48.12010000.3 2009/02/19 15:43:20 rpatangy ship $ */

	 /**********************************************************************
	 *    FUNCTION:                                                        *
	 *      Get_Inventory_Item_Id                                          *
	 *                                                                     *
	 *    DESCRIPTION:                                                     *
	 *      This is an internal function used to retrieve the Inventory    *
	 *      Item Id value for the OPM Item Id passed                       *
	 *                                                                     *
	 *    PARAMETERS:                                                      *
	 *      p_item_id    - OPM Item Id to retrieve the value.              *
	 *                                                                     *
	 *    SYNOPSIS:                                                        *
	 *      Get_Inventory_Item_Id (p_Item_id => 12121);                    *
	 *                                                                     *
	 *    HISTORY                                                          *
	 *       27-Apr-2005 Created  Anand Thiyagarajan                       *
	 **********************************************************************/
	 FUNCTION Get_Inventory_Item_Id
	 (
	 p_Item_id               IN             NUMBER
	 )
	 RETURN NUMBER
	 IS

			/************************
			* Local Variables       *
			************************/

			l_Inventory_item_id           mtl_system_items_b.inventory_item_id%TYPE;

			/****************
			* Cursors       *
			****************/

			CURSOR      cur_Inventory_item_id
			(
			p_Item_id            IN       NUMBER
			)
			IS
			SELECT      inventory_item_id
			FROM        ic_item_mst_b_mig
			WHERE       item_id = p_item_id
			AND         inventory_item_id IS NOT NULL
			AND         ROWNUM = 1;

	 BEGIN

			OPEN Cur_Inventory_item_id(p_item_id);
			FETCH Cur_Inventory_item_id INTO L_Inventory_item_id;

			IF Cur_Inventory_item_id%NOTFOUND THEN
				CLOSE Cur_Inventory_item_id;
				RAISE NO_DATA_FOUND;
			END IF;

			CLOSE Cur_Inventory_item_id;

			RETURN(L_Inventory_item_id);

	 EXCEPTION
			WHEN OTHERS THEN

				 /********************************
				 * Migration Started Log Message *
				 ********************************/

				 GMA_COMMON_LOGGING.gma_migration_central_log
				 (
				 p_run_id             =>       G_migration_run_id,
				 p_log_level          =>       FND_LOG.LEVEL_ERROR,
				 p_message_token      =>       'GMA_MIG_ITEM_ERROR',
				 p_table_name         =>       G_Table_name,
				 p_context            =>       G_context,
				 p_token1             =>       'ITEM_ID',
				 p_param1             =>       p_item_id,
				 p_db_error           =>       NULL,
				 p_app_short_name     =>       'GMA'
				 );

				RETURN NULL;

	 END Get_Inventory_item_id;

	 /****************************************************************************
	 *    FUNCTION:                                                              *
	 *      Get_Legal_entity_Id                                                  *
	 *                                                                           *
	 *    DESCRIPTION:                                                           *
	 *      This is an internal function used to retrieve the Legal Entity Id    *
	 *      value for the Company Code passed                                    *
	 *                                                                           *
	 *    PARAMETERS:                                                            *
	 *      p_co_code    - Company Code to retrieve the value.                   *
	 *                                                                           *
	 *    SYNOPSIS:                                                              *
	 *      Get_Legal_entity_Id (p_co_code => 'PR1',                             *
	 *                          p_source_type => 'O');                           *
	 *                                                                           *
	 *    HISTORY                                                                *
	 *       27-Apr-2005 Created  Anand Thiyagarajan                             *
	 *                                                                           *
	 ****************************************************************************/
	 FUNCTION Get_Legal_Entity_Id
	 (
	 p_co_code               IN             VARCHAR2,
	 p_source_type           IN             VARCHAR2
	 )
	 RETURN NUMBER
	 IS

			/************************
			* Local Variables       *
			************************/

			L_legal_entity_id       gmf_fiscal_policies.legal_entity_id%TYPE;

			/****************
			* Cursors       *
			****************/

			CURSOR      cur_legal_entity
			(
			p_co_code      IN    VARCHAR2,
			p_source_type  IN    VARCHAR2
			)
			IS
			SELECT      to_number(a.org_information2) legal_entity_id
			FROM        hr_organization_information a, gl_plcy_mst b
			WHERE       a.organization_id = b.org_id
			AND         b.co_code = p_co_code
			AND         p_source_type = 'O'
			and         a.org_information_context = 'Operating Unit Information'
			UNION
			SELECT      a.legal_entity_id
			FROM        gl_plcy_mst a
			WHERE       a.co_code = p_co_code
			AND         p_source_type = 'N';

	 BEGIN

			OPEN Cur_legal_entity(p_co_code, p_source_type);
			FETCH Cur_legal_entity INTO L_legal_entity_id;

			IF Cur_legal_entity%NOTFOUND THEN
				CLOSE Cur_legal_entity;
				RAISE NO_DATA_FOUND;
			END IF;

			CLOSE Cur_legal_entity;

			RETURN(L_legal_entity_id);

	 EXCEPTION
			WHEN no_data_found THEN

				 /********************************
				 * Migration Started Log Message *
				 ********************************/

				 GMA_COMMON_LOGGING.gma_migration_central_log
				 (
				 p_run_id             =>       G_migration_run_id,
				 p_log_level          =>       FND_LOG.LEVEL_PROCEDURE,
				 p_message_token      =>       'GMA_MIG_LE_CO_ERROR',
				 p_table_name         =>       G_Table_name,
				 p_context            =>       G_context,
				 p_token1             =>       'CO_CODE',
				 p_param1             =>       p_co_code,
				 p_db_error           =>       NULL,
				 p_app_short_name     =>       'GMA'
				 );

				RETURN NULL;

	 END Get_Legal_Entity_id;

	 /****************************************************************************
	 *    FUNCTION:                                                              *
	 *      Get_Legal_entity_Id                                                  *
	 *                                                                           *
	 *    DESCRIPTION:                                                           *
	 *      This is a overhealoaded function used to retrieve the Legal Entity Id*
	 *      value for the Organization Id passed                                 *
	 *                                                                           *
	 *    PARAMETERS:                                                            *
	 *      p_organization_id - Organization Id to retrieve the value.           *
	 *                                                                           *
	 *    SYNOPSIS:                                                              *
	 *      Get_Legal_entity_Id (p_organization_id => 1381);                     *
	 *                                                                           *
	 *    HISTORY                                                                *
	 *       27-Apr-2005 Created  Anand Thiyagarajan                             *
	 *                                                                           *
	 ****************************************************************************/
	 FUNCTION Get_Legal_Entity_Id
	 (
	 p_organization_id       IN             NUMBER
	 )
	 RETURN NUMBER
	 IS

			/************************
			* Local Variables       *
			************************/

			L_legal_entity_id       gmf_fiscal_policies.legal_entity_id%TYPE;

			/****************
			* Cursors       *
			****************/

			CURSOR      cur_legal_entity
			(
			p_organization_id   IN    NUMBER
			)
			IS
			SELECT      to_number(a.org_information2) legal_entity_id
			FROM        hr_organization_information a
			WHERE       a.organization_id = p_organization_id
			AND         a.org_information_context = 'Accounting Information';

	 BEGIN

			OPEN Cur_legal_entity(p_organization_id);
			FETCH Cur_legal_entity INTO L_legal_entity_id;

			IF Cur_legal_entity%NOTFOUND THEN
				CLOSE Cur_legal_entity;
				RAISE NO_DATA_FOUND;
			END IF;

			CLOSE Cur_legal_entity;

			RETURN(L_legal_entity_id);

	 EXCEPTION
			WHEN no_data_found THEN

				 /********************************
				 * Migration Started Log Message *
				 ********************************/

				 GMA_COMMON_LOGGING.gma_migration_central_log
				 (
				 p_run_id             =>       G_migration_run_id,
				 p_log_level          =>       FND_LOG.LEVEL_PROCEDURE,
				 p_message_token      =>       'GMA_MIG_LE_ORG_ERROR',
				 p_table_name         =>       G_Table_name,
				 p_context            =>       G_context,
				 p_token1             =>       'ORGANIZATION_ID',
				 p_param1             =>       p_organization_id,
				 p_db_error           =>       NULL,
				 p_app_short_name     =>       'GMA'
				 );

				RETURN NULL;

	 END Get_Legal_Entity_id;

	 /****************************************************************************
	 *    FUNCTION:                                                              *
	 *      Get_Legal_entity_Id                                                  *
	 *                                                                           *
	 *    DESCRIPTION:                                                           *
	 *      This is a overhealoaded function used to retrieve the Legal Entity Id*
	 *      value for the Warehouse Code passed                                  *
	 *                                                                           *
	 *    PARAMETERS:                                                            *
	 *      p_whse_code_id - Warehouse code to retrieve the value.               *
	 *                                                                           *
	 *    SYNOPSIS:                                                              *
	 *      Get_Legal_entity_Id (p_whse_code=> 'PR1');                           *
	 *                                                                           *
	 *    HISTORY                                                                *
	 *       27-Apr-2005 Created  Anand Thiyagarajan                             *
	 *                                                                           *
	 ****************************************************************************/
	 FUNCTION Get_Legal_Entity_Id
	 (
	 p_whse_code             IN             VARCHAR2
	 )
	 RETURN NUMBER
	 IS

			/************************
			* Local Variables       *
			************************/

			L_legal_entity_id       gmf_fiscal_policies.legal_entity_id%TYPE;

			/****************
			* Cursors       *
			****************/

			CURSOR      cur_legal_entity
			(
			p_whse_code   IN    VARCHAR2
			)
			IS
			SELECT      to_number(a.org_information2) legal_entity_id
			FROM        hr_organization_information a, ic_whse_mst b
			WHERE       a.organization_id = decode(nvl(b.subinventory_ind_flag, 'N'), 'Y', b.organization_id, b.mtl_organization_id)
			AND         b.whse_code = p_whse_code
			AND         a.org_information_context = 'Accounting Information';

	 BEGIN

			OPEN Cur_legal_entity(p_whse_code);
			FETCH Cur_legal_entity INTO L_legal_entity_id;

			IF Cur_legal_entity%NOTFOUND THEN
				CLOSE Cur_legal_entity;
				RAISE NO_DATA_FOUND;
			END IF;

			CLOSE Cur_legal_entity;

			RETURN(L_legal_entity_id);

	 EXCEPTION
			WHEN no_data_found THEN

				 /********************************
				 * Migration Started Log Message *
				 ********************************/

				 GMA_COMMON_LOGGING.gma_migration_central_log
				 (
				 p_run_id             =>       G_migration_run_id,
				 p_log_level          =>       FND_LOG.LEVEL_PROCEDURE,
				 p_message_token      =>       'GMA_MIG_LE_WHSE_ERROR',
				 p_table_name         =>       G_Table_name,
				 p_context            =>       G_context,
				 p_token1             =>       'WHSE_CODE',
				 p_param1             =>       p_whse_code,
				 p_db_error           =>       NULL,
				 p_app_short_name     =>       'GMA'
				 );

				RETURN NULL;

	 END Get_Legal_Entity_id;

	 /**********************************************************************
	 *    FUNCTION:                                                        *
	 *      Get_Item_number                                                *
	 *                                                                     *
	 *    DESCRIPTION:                                                     *
	 *      This is an internal function used to retrieve the Item Number  *
	 *                                                                     *
	 *    PARAMETERS:                                                      *
	 *      p_inventory_item_id - ODM Item Id to retrieve the value.       *
	 *                                                                     *
	 *    SYNOPSIS:                                                        *
	 *      Get_Item_number (p_inventory_Item_id => 12121);                *
	 *                                                                     *
	 *    HISTORY                                                          *
	 *       27-Apr-2005 Created  Anand Thiyagarajan                       *
	 **********************************************************************/
	 FUNCTION Get_Item_Number
	 (
	 p_inventory_item_id     IN             NUMBER
	 )
	 RETURN VARCHAR2
	 IS

			/************************
			* Local Variables       *
			************************/

			l_Item_number           mtl_item_flexfields.item_number%TYPE;

			/****************
			* Cursors       *
			****************/

			CURSOR      cur_item_number
			(
			p_Inventory_item_id  IN       NUMBER
			)
			IS
			SELECT      item_number
			FROM        mtl_item_flexfields
			WHERE       inventory_item_id = p_inventory_item_id
			AND         ROWNUM = 1;

	 BEGIN

			OPEN Cur_item_number(p_inventory_item_id);
			FETCH Cur_item_number INTO L_item_number;

			IF Cur_item_number%NOTFOUND THEN
				CLOSE Cur_item_number;
				RAISE NO_DATA_FOUND;
			END IF;

			CLOSE Cur_item_number;

			RETURN(L_item_number);

	 EXCEPTION
			WHEN OTHERS THEN

				 /********************************
				 * Migration Started Log Message *
				 ********************************/

				 GMA_COMMON_LOGGING.gma_migration_central_log
				 (
				 p_run_id             =>       G_migration_run_id,
				 p_log_level          =>       FND_LOG.LEVEL_ERROR,
				 p_message_token      =>       'GMA_MIG_ITEM_NO_ERROR',
				 p_table_name         =>       G_Table_name,
				 p_context            =>       G_context,
				 p_token1             =>       'INVENTORY_ITEM_ID',
				 p_param1             =>       p_inventory_item_id,
				 p_db_error           =>       NULL,
				 p_app_short_name     =>       'GMA'
				 );

				RETURN NULL;

	 END Get_item_number;

	 /**********************************************************************
	 *    FUNCTION:                                                        *
	 *      Get_Customer_no                                                *
	 *                                                                     *
	 *    DESCRIPTION:                                                     *
	 *      This is an internal function used to retrieve the Customer No  *
	 *                                                                     *
	 *    PARAMETERS:                                                      *
	 *      p_cust_id - OPM Customer Id to retrieve the value.             *
	 *                                                                     *
	 *    SYNOPSIS:                                                        *
	 *      Get_Customer_no (p_cust_id => 12121);                          *
	 *                                                                     *
	 *    HISTORY                                                          *
	 *       27-Apr-2005 Created  Anand Thiyagarajan                       *
	 **********************************************************************/
	 FUNCTION Get_Customer_no
	 (
	 p_cust_id     IN             NUMBER
	 )
	 RETURN VARCHAR2
	 IS

			/************************
			* Local Variables       *
			************************/

			l_customer_no                 op_cust_mst.cust_no%TYPE;

			/****************
			* Cursors       *
			****************/

			CURSOR      cur_cust_no
			(
			p_cust_id  IN       NUMBER
			)
			IS
			SELECT      cust_no
			FROM        op_cust_mst
			WHERE       cust_id = p_cust_id;

	 BEGIN

			OPEN Cur_cust_no(p_cust_id);
			FETCH Cur_cust_no INTO l_customer_no;

			IF Cur_cust_no%NOTFOUND THEN
				CLOSE Cur_cust_no;
				RAISE NO_DATA_FOUND;
			END IF;

			CLOSE Cur_cust_no;

			RETURN(l_customer_no);

	 EXCEPTION
			WHEN OTHERS THEN

				 /********************************
				 * Migration Started Log Message *
				 ********************************/

				 GMA_COMMON_LOGGING.gma_migration_central_log
				 (
				 p_run_id             =>       G_migration_run_id,
				 p_log_level          =>       FND_LOG.LEVEL_ERROR,
				 p_message_token      =>       'GMA_MIG_CUSTOMER_ERROR',
				 p_table_name         =>       G_Table_name,
				 p_context            =>       G_context,
				 p_token1             =>       'CUST_ID',
				 p_param1             =>       p_cust_id,
				 p_db_error           =>       NULL,
				 p_app_short_name     =>       'GMA'
				 );

				RETURN NULL;

	 END Get_Customer_no;

	 /**********************************************************************
	 *    FUNCTION:                                                        *
	 *      Get_Vendor_id                                                  *
	 *                                                                     *
	 *    DESCRIPTION:                                                     *
	 *      This is an internal function used to retrieve the Vendor No    *
	 *                                                                     *
	 *    PARAMETERS:                                                      *
	 *      p_vendor_id - OPM Vendor Id to retrieve the value.             *
	 *                                                                     *
	 *    SYNOPSIS:                                                        *
	 *      Get_Vendor_id (p_vendor_id => 12121);                          *
	 *                                                                     *
	 *    HISTORY                                                          *
	 *       27-Apr-2005  Created  Anand Thiyagarajan                      *
   *       12-Oct-2006  Modified Anand Thiyagarajan                      *
   *          Modified Procedure to fetch of_vendor_site_id              *
	 **********************************************************************/
	 FUNCTION Get_Vendor_id
	 (
	 p_vendor_id       IN             NUMBER
	 )
	 RETURN NUMBER
	 IS

			/************************
			* Local Variables       *
			************************/

			l_vendor_site_id                   po_vend_mst.of_vendor_site_id%TYPE;

			/****************
			* Cursors       *
			****************/

			CURSOR      cur_vendor_id
			(
			p_vendor_id  IN       NUMBER
			)
			IS
			SELECT      of_vendor_site_id
			FROM        po_vend_mst
			WHERE       vendor_id = p_vendor_id;

	 BEGIN
			OPEN cur_vendor_id(p_vendor_id);
			FETCH cur_vendor_id INTO l_vendor_site_id;
			IF cur_vendor_id%NOTFOUND THEN
				CLOSE cur_vendor_id;
				RAISE NO_DATA_FOUND;
			END IF;
			CLOSE cur_vendor_id;
			RETURN(l_vendor_site_id);
	 EXCEPTION
			WHEN OTHERS THEN
				 /********************************
				 * Migration Started Log Message *
				 ********************************/
				 GMA_COMMON_LOGGING.gma_migration_central_log
				 (
				 p_run_id             =>       G_migration_run_id,
				 p_log_level          =>       FND_LOG.LEVEL_ERROR,
				 p_message_token      =>       'GMA_MIG_VENDOR_ERROR',
				 p_table_name         =>       G_Table_name,
				 p_context            =>       G_context,
				 p_token1             =>       'VENDOR_ID',
				 p_param1             =>       p_vendor_id,
				 p_db_error           =>       NULL,
				 p_app_short_name     =>       'GMA'
				 );
				RETURN NULL;
	 END Get_Vendor_id;

	 /**********************************************************************
	 *    FUNCTION:                                                        *
	 *      Get_Vendor_no                                                  *
	 *                                                                     *
	 *    DESCRIPTION:                                                     *
	 *      This is an internal function used to retrieve the Vendor No    *
	 *                                                                     *
	 *    PARAMETERS:                                                      *
	 *      p_vendor_id - OPM Vendor Id to retrieve the value.             *
	 *                                                                     *
	 *    SYNOPSIS:                                                        *
	 *      Get_Vendor_no (p_vendor_id => 12121);                          *
	 *                                                                     *
	 *    HISTORY                                                          *
	 *       27-Apr-2005 Created  Anand Thiyagarajan                       *
	 **********************************************************************/
	 FUNCTION Get_Vendor_no
	 (
	 p_vendor_id       IN             NUMBER
	 )
	 RETURN VARCHAR2
	 IS
			/************************
			* Local Variables       *
			************************/
			l_vendor_no                   po_vend_mst.vendor_no%TYPE;
			/****************
			* Cursors       *
			****************/
			CURSOR      cur_vendor_no
			(
			p_vendor_id  IN       NUMBER
			)
			IS
			SELECT      vendor_no
			FROM        po_vend_mst
			WHERE       vendor_id = p_vendor_id;
	 BEGIN
			OPEN cur_vendor_no(p_vendor_id);
			FETCH cur_vendor_no INTO l_vendor_no;
			IF cur_vendor_no%NOTFOUND THEN
				CLOSE cur_vendor_no;
				RAISE NO_DATA_FOUND;
			END IF;
			CLOSE cur_vendor_no;
			RETURN(l_vendor_no);
	 EXCEPTION
			WHEN OTHERS THEN
				 /********************************
				 * Migration Started Log Message *
				 ********************************/
				 GMA_COMMON_LOGGING.gma_migration_central_log
				 (
				 p_run_id             =>       G_migration_run_id,
				 p_log_level          =>       FND_LOG.LEVEL_ERROR,
				 p_message_token      =>       'GMA_MIG_VENDOR_ERROR',
				 p_table_name         =>       G_Table_name,
				 p_context            =>       G_context,
				 p_token1             =>       'VENDOR_ID',
				 p_param1             =>       p_vendor_id,
				 p_db_error           =>       NULL,
				 p_app_short_name     =>       'GMA'
				 );
				RETURN NULL;
	 END Get_Vendor_no;

	 /**********************************************************************
	 *    FUNCTION:                                                        *
	 *      Get_reason_id                                                  *
	 *                                                                     *
	 *    DESCRIPTION:                                                     *
	 *      This is an internal function used to retrieve the Reason_id    *
	 *                                                                     *
	 *    PARAMETERS:                                                      *
	 *      p_reason_code - OPM Reason Code to retrieve the value.         *
	 *                                                                     *
	 *    SYNOPSIS:                                                        *
	 *      Get_Reason_id(p_reason_code => 'ADD');                         *
	 *                                                                     *
	 *    HISTORY                                                          *
	 *       28-Sep-2006 Created  Anand Thiyagarajan                       *
	 **********************************************************************/
	 FUNCTION Get_reason_id
	 (
	 p_reason_code        IN          VARCHAR2
	 )
	 RETURN NUMBER
	 IS

			/************************
			* Local Variables       *
			************************/

			l_reason_id                   mtl_transaction_Reasons.reason_id%TYPE;

			/****************
			* Cursors       *
			****************/

			CURSOR      cur_reason_id
			(
			p_reason_Code   IN      VARCHAR2
			)
			IS
			SELECT      reason_id
			FROM        mtl_transaction_Reasons
			WHERE       reason_name = p_reason_code;

	 BEGIN

			OPEN cur_reason_id(p_reason_code);
			FETCH cur_reason_id INTO l_reason_id;

			IF cur_reason_id%NOTFOUND THEN
				CLOSE cur_reason_id;
				RAISE NO_DATA_FOUND;
			END IF;

			CLOSE cur_reason_id;

			RETURN(l_reason_id);

	 EXCEPTION
			WHEN OTHERS THEN
				RETURN NULL;
	 END Get_reason_id;

	 /**********************************************************************
	 *    PROCEDURE                                                        *
	 *      Get_Routing_no                                                 *
	 *                                                                     *
	 *    DESCRIPTION:                                                     *
	 *      This is an internal procedure used to retrieve the routing No  *
	 *                                                                     *
	 *    PARAMETERS:                                                      *
	 *      p_routing_id - OPM routing Id to retrieve the value.           *
	 *                                                                     *
	 *    SYNOPSIS:                                                        *
	 *      Get_routing_no (p_routing_id => 12121);                        *
	 *                                                                     *
	 *    HISTORY                                                          *
	 *       27-Apr-2005 Created  Anand Thiyagarajan                       *
	 **********************************************************************/
	 PROCEDURE Get_Routing_no
	 (
	 p_routing_id         IN                NUMBER,
	 x_routing_no            OUT   NOCOPY   VARCHAR2,
	 x_routing_vers          OUT   NOCOPY   NUMBER
	 )
	 IS

			/************************
			* Local Variables       *
			************************/

			l_routing_no                   GMD_ROUTINGS_B.routing_no%TYPE;
			l_routing_vers                 GMD_ROUTINGS_B.routing_vers%TYPE;

			/****************
			* Cursors       *
			****************/

			CURSOR      cur_routing_no
			(
			p_routing_id  IN       NUMBER
			)
			IS
			SELECT      routing_no,
									routing_vers
			FROM        GMD_ROUTINGS_B
			WHERE       routing_id = p_routing_id;

	 BEGIN

			OPEN cur_routing_no(p_routing_id);
			FETCH cur_routing_no INTO l_routing_no, l_routing_vers;

			IF cur_routing_no%NOTFOUND THEN
				CLOSE cur_routing_no;
				RAISE NO_DATA_FOUND;
			END IF;

			CLOSE cur_routing_no;

			x_routing_no := l_routing_no;
			x_routing_vers := l_routing_vers;

	 EXCEPTION
			WHEN OTHERS THEN

				 /********************************
				 * Migration Started Log Message *
				 ********************************/

				 GMA_COMMON_LOGGING.gma_migration_central_log
				 (
				 p_run_id             =>       G_migration_run_id,
				 p_log_level          =>       FND_LOG.LEVEL_ERROR,
				 p_message_token      =>       'GMA_MIG_ROUTING_ERROR',
				 p_table_name         =>       G_Table_name,
				 p_context            =>       G_context,
				 p_token1             =>       'ROUTING_ID',
				 p_param1             =>       p_routing_id,
				 p_db_error           =>       NULL,
				 p_app_short_name     =>       'GMA'
				 );

			x_routing_no := NULL;
			x_routing_vers := NULL;

	 END Get_routing_no;

	 /**********************************************************************
	 *    FUNCTION:                                                        *
	 *      Get_aqui_cost_code                                             *
	 *                                                                     *
	 *    DESCRIPTION:                                                     *
	 *      This is an internal function used to retrieve aqui cost Code   *
	 *                                                                     *
	 *    PARAMETERS:                                                      *
	 *      p_aqui_cost_id - OPM aqui_cost Id to retrieve the value.       *
	 *                                                                     *
	 *    SYNOPSIS:                                                        *
	 *      Get_aqui_cost_code (p_aqui_cost_id => 12121);                  *
	 *                                                                     *
	 *    HISTORY                                                          *
	 *       27-Apr-2005 Created  Anand Thiyagarajan                       *
	 **********************************************************************/
	 FUNCTION Get_price_element_Type_id
	 (
	 p_aqui_cost_id       IN             NUMBER
	 )
	 RETURN NUMBER
	 IS
			/************************
			* Local Variables       *
			************************/
			l_price_element_type_id          po_cost_mst.price_element_type_id%TYPE;
			/****************
			* Cursors       *
			****************/
			CURSOR      cur_price_element_type_id
			(
			p_aqui_cost_id  IN       NUMBER
			)
			IS
			SELECT      price_element_type_id
			FROM        po_cost_mst
			WHERE       aqui_cost_id = p_aqui_cost_id
			AND         nvl(migrated_ind, 0) = 1;

	 BEGIN

			OPEN cur_price_element_type_id(p_aqui_cost_id);
			FETCH cur_price_element_type_id INTO l_price_element_type_id;

			IF cur_price_element_type_id%NOTFOUND THEN
				CLOSE cur_price_element_type_id;
				RAISE NO_DATA_FOUND;
			END IF;
			CLOSE cur_price_element_type_id;
			RETURN(l_price_element_type_id);
	 EXCEPTION
			WHEN OTHERS THEN
				 /********************************
				 * Migration Started Log Message *
				 ********************************/
				 GMA_COMMON_LOGGING.gma_migration_central_log
				 (
				 p_run_id             =>       G_migration_run_id,
				 p_log_level          =>       FND_LOG.LEVEL_ERROR,
				 p_message_token      =>       'GMA_MIG_AQUI_CODE_ERROR',
				 p_table_name         =>       G_Table_name,
				 p_context            =>       G_context,
				 p_token1             =>       'AQUI_COST_ID',
				 p_param1             =>       p_aqui_cost_id,
				 p_db_error           =>       NULL,
				 p_app_short_name     =>       'GMA'
				 );
				RETURN NULL;
	 END Get_price_element_Type_id;

	 /**********************************************************************
	 *    FUNCTION:                                                        *
	 *      Get_cost_cmpntcls_code                                         *
	 *                                                                     *
	 *    DESCRIPTION:                                                     *
	 *      This is an internal function used to retrieve costcmpntcls Code*
	 *                                                                     *
	 *    PARAMETERS:                                                      *
	 *      p_cost_cmpntcls_id - OPM cost_cmpntcls Id to retrieve the value*
	 *                                                                     *
	 *    SYNOPSIS:                                                        *
	 *      Get_cost_cmpntcls_code (p_cost_cmpntcls_id => 12121);          *
	 *                                                                     *
	 *    HISTORY                                                          *
	 *       27-Apr-2005 Created  Anand Thiyagarajan                       *
	 **********************************************************************/
	 FUNCTION Get_Cost_cmpntcls_code
	 (
	 p_cost_cmpntcls_id       IN             NUMBER
	 )
	 RETURN VARCHAR2
	 IS

			/************************
			* Local Variables       *
			************************/

			l_cost_cmpntcls_code                   cm_cmpt_mst.cost_cmpntcls_code%TYPE;

			/****************
			* Cursors       *
			****************/

			CURSOR      cur_cost_cmpntcls_code
			(
			p_cost_cmpntcls_id  IN       NUMBER
			)
			IS
			SELECT      cost_cmpntcls_code
			FROM        cm_cmpt_mst
			WHERE       cost_cmpntcls_id = p_cost_cmpntcls_id;

	 BEGIN

			OPEN cur_cost_cmpntcls_code(p_cost_cmpntcls_id);
			FETCH cur_cost_cmpntcls_code INTO l_cost_cmpntcls_code;

			IF cur_cost_cmpntcls_code%NOTFOUND THEN
				CLOSE cur_cost_cmpntcls_code;
				RAISE NO_DATA_FOUND;
			END IF;

			CLOSE cur_cost_cmpntcls_code;

			RETURN(l_cost_cmpntcls_code);

	 EXCEPTION
			WHEN OTHERS THEN

				 /********************************
				 * Migration Started Log Message *
				 ********************************/

				 GMA_COMMON_LOGGING.gma_migration_central_log
				 (
				 p_run_id             =>       G_migration_run_id,
				 p_log_level          =>       FND_LOG.LEVEL_ERROR,
				 p_message_token      =>       'GMA_MIG_CMPNTCLS_ERROR',
				 p_table_name         =>       G_Table_name,
				 p_context            =>       G_context,
				 p_token1             =>       'COST_CMPNTCLS_ID',
				 p_param1             =>       p_cost_cmpntcls_id,
				 p_db_error           =>       NULL,
				 p_app_short_name     =>       'GMA'
				 );

				RETURN NULL;

	 END Get_cost_cmpntcls_code;

	 /**********************************************************************
	 *    FUNCTION:                                                        *
	 *      Get_Order_type_code                                            *
	 *                                                                     *
	 *    DESCRIPTION:                                                     *
	 *      This is an internal function used to retrieve Order_type Code  *
	 *                                                                     *
	 *    PARAMETERS:                                                      *
	 *      p_Order_type_id - OPM Order_type Id to retrieve the value.     *
	 *                                                                     *
	 *    SYNOPSIS:                                                        *
	 *      Get_Order_type_code (p_Order_type_id => 12121);                *
	 *                                                                     *
	 *    HISTORY                                                          *
	 *       27-Apr-2005 Created  Anand Thiyagarajan                       *
	 **********************************************************************/
	 FUNCTION Get_Order_type_code
	 (
	 p_Order_type            IN             NUMBER,
	 p_source_type           IN             NUMBER
	 )
	 RETURN VARCHAR2
	 IS

			/************************
			* Local Variables       *
			************************/

			l_Order_type_code                   OP_ORDR_TYP.Order_type_code%TYPE;

			/****************
			* Cursors       *
			****************/

			CURSOR      cur_Order_type_code
			(
			p_Order_type      IN       NUMBER,
			p_source_type     IN       NUMBER
			)
			IS
			SELECT      order_type_code
			FROM        op_ordr_typ
			WHERE       lang_code = userenv('LANG')
			AND         nvl(p_source_type,0) = 0
			AND         order_type = p_Order_type
			UNION ALL
			SELECT      tl.name
			FROM        oe_transaction_types_all t,
									oe_transaction_types_tl tl
			WHERE       t.transaction_type_id = tl.transaction_type_id
			AND         tl.language = userenv('LANG')
			AND         nvl(p_source_type,0) = 11
			AND         t.transaction_type_code = 'ORDER'
			AND         t.transaction_type_id = p_Order_type;

	 BEGIN

			OPEN cur_Order_type_code(p_Order_type, p_source_type);
			FETCH cur_Order_type_code INTO l_Order_type_code;

			IF cur_Order_type_code%NOTFOUND THEN
				CLOSE cur_Order_type_code;
				RAISE NO_DATA_FOUND;
			END IF;

			CLOSE cur_Order_type_code;

			RETURN(l_Order_type_code);

	 EXCEPTION
			WHEN OTHERS THEN

				 /********************************
				 * Migration Started Log Message *
				 ********************************/

				 GMA_COMMON_LOGGING.gma_migration_central_log
				 (
				 p_run_id             =>       G_migration_run_id,
				 p_log_level          =>       FND_LOG.LEVEL_ERROR,
				 p_message_token      =>       'GMA_MIG_ORDER_TYPE_ERROR',
				 p_table_name         =>       G_Table_name,
				 p_context            =>       G_context,
				 p_token1             =>       'ORDER_TYPE',
				 p_param1             =>       p_Order_type,
				 p_db_error           =>       NULL,
				 p_app_short_name     =>       'GMA'
				 );

				RETURN NULL;

	 END Get_Order_type_code;

	 /**********************************************************************
	 *    FUNCTION:                                                        *
	 *      Get_Line_type_code                                             *
	 *                                                                     *
	 *    DESCRIPTION:                                                     *
	 *      This is an internal function used to retrieve Line_type Code   *
	 *                                                                     *
	 *    PARAMETERS:                                                      *
	 *      p_Line_type_id - OPM Line_type Id to retrieve the value.       *
	 *                                                                     *
	 *    SYNOPSIS:                                                        *
	 *      Get_Line_type_code (p_Line_type => 12121);                     *
	 *                                                                     *
	 *    HISTORY                                                          *
	 *       27-Apr-2005 Created  Anand Thiyagarajan                       *
	 **********************************************************************/
	 FUNCTION Get_Line_type_code
	 (
	 p_Line_type            IN             NUMBER
	 )
	 RETURN VARCHAR2
	 IS

			/************************
			* Local Variables       *
			************************/

			l_Line_type_code                    gem_lookups.meaning%TYPE;
			l_om                                NUMBER;
			l_opm_om                            VARCHAR2(10);

			/****************
			* Cursors       *
			****************/

			CURSOR      cur_Line_type_code
			(
			p_Line_type       IN       NUMBER
			)
			IS
			SELECT         meaning
			FROM           gem_lookups
			WHERE          lookup_type = 'LINE_TYPE'
			AND            nvl(start_date_active,sysdate) <= sysdate
			AND            nvl(end_date_active,sysdate) >= sysdate
			AND            enabled_flag = 'Y'
			AND            lookup_code = p_line_type;

	 BEGIN

			OPEN cur_Line_type_code(p_Line_type);
			FETCH cur_Line_type_code INTO l_Line_type_code;

			IF cur_Line_type_code%NOTFOUND THEN
				CLOSE cur_Line_type_code;
				RAISE NO_DATA_FOUND;
			END IF;

			CLOSE cur_Line_type_code;

			RETURN(l_Line_type_code);

	 EXCEPTION
			WHEN OTHERS THEN

				 /********************************
				 * Migration Started Log Message *
				 ********************************/

				 GMA_COMMON_LOGGING.gma_migration_central_log
				 (
				 p_run_id             =>       G_migration_run_id,
				 p_log_level          =>       FND_LOG.LEVEL_ERROR,
				 p_message_token      =>       'GMA_MIG_LINE_TYPE_ERROR',
				 p_table_name         =>       G_Table_name,
				 p_context            =>       G_context,
				 p_token1             =>       'LINE_TYPE',
				 p_param1             =>       p_Line_type,
				 p_db_error           =>       NULL,
				 p_app_short_name     =>       'GMA'
				 );

				RETURN NULL;

	 END Get_Line_type_code;

	 /**********************************************************************
	 *    FUNCTION:                                                        *
	 *      Get_ar_trx_type_code                                           *
	 *                                                                     *
	 *    DESCRIPTION:                                                     *
	 *      This is an internal function used to retrieve costcmpntcls Code*
	 *                                                                     *
	 *    PARAMETERS:                                                      *
	 *      p_ar_trx_type_id - OPM ar_trx_type Id to retrieve the value    *
	 *                                                                     *
	 *    SYNOPSIS:                                                        *
	 *      Get_Ar_trx_type_code ( p_ar_trx_type_id => 12121,              *
	 *                             p_co_code = 'PRU');                     *
	 *                                                                     *
	 *    HISTORY                                                          *
	 *       27-Apr-2005 Created  Anand Thiyagarajan                       *
	 **********************************************************************/
	 FUNCTION Get_Ar_trx_type_code
	 (
	 p_ar_trx_type_id        IN             NUMBER,
	 p_legal_entity_id       IN             NUMBER
	 )
	 RETURN VARCHAR2
	 IS

			/************************
			* Local Variables       *
			************************/

			l_ar_trx_type_code                  RA_CUST_TRX_TYPES_ALL.name%TYPE;

			/****************
			* Cursors       *
			****************/

			CURSOR      cur_Ar_trx_type_code
			(
			p_Ar_trx_type_id        IN       NUMBER,
			p_legal_entity_id       IN       NUMBER
			)
			IS
			SELECT            rctta.name
			FROM              ra_cust_trx_types_all rctta, ar_lookups al, gl_plcy_mst plcy
			WHERE             sysdate between nvl(rctta.start_date, sysdate-1) and nvl(rctta.end_date, sysdate+1)
			AND               al.lookup_type = 'INV/CM'
			AND               al.lookup_code = rctta.type
			AND               rctta.org_id = plcy.org_id
			AND               plcy.legal_entity_id = p_legal_entity_id
			AND               rctta.cust_trx_type_id = p_Ar_trx_type_id;

	 BEGIN

			OPEN cur_Ar_trx_type_code(p_Ar_trx_type_id, p_legal_entity_id);
			FETCH cur_Ar_trx_type_code INTO l_Ar_trx_type_code;

			IF cur_Ar_trx_type_code%NOTFOUND THEN
				CLOSE cur_Ar_trx_type_code;
				RAISE NO_DATA_FOUND;
			END IF;

			CLOSE cur_Ar_trx_type_code;

			RETURN(l_Ar_trx_type_code);

	 EXCEPTION
			WHEN OTHERS THEN

				 /********************************
				 * Migration Started Log Message *
				 ********************************/

				 GMA_COMMON_LOGGING.gma_migration_central_log
				 (
				 p_run_id             =>       G_migration_run_id,
				 p_log_level          =>       FND_LOG.LEVEL_ERROR,
				 p_message_token      =>       'GMA_MIG_AR_TRX_TYPE_ERROR',
				 p_table_name         =>       G_Table_name,
				 p_context            =>       G_context,
				 p_token1             =>       'AR_TRX_TYPE_ID',
				 p_param1             =>       p_Ar_trx_type_id,
				 p_db_error           =>       NULL,
				 p_app_short_name     =>       'GMA'
				 );

				RETURN NULL;

	 END Get_Ar_trx_type_code;

	 /**********************************************************************
	 *    FUNCTION:                                                        *
	 *      Get_gl_business_class_cat                                      *
	 *                                                                     *
	 *    DESCRIPTION:                                                     *
	 *      This is an internal function used to retrieve gl_business_class*
	 *                                                                     *
	 *    PARAMETERS:                                                      *
	 *      p_gl_business_class_cat_id - OPM gl_business_class_cat Id      *
	 *                                   to retrieve the value             *
	 *                                                                     *
	 *    SYNOPSIS:                                                        *
	 *      Get_gl_business_class_cat (p_gl_business_class_cat_id => 12121)*
	 *                                                                     *
	 *    HISTORY                                                          *
	 *       27-Apr-2005 Created  Anand Thiyagarajan                       *
	 **********************************************************************/
	 FUNCTION Get_Gl_business_class_cat
	 (
	 p_Gl_business_class_cat_id          IN             NUMBER
	 )
	 RETURN VARCHAR2
	 IS

			/************************
			* Local Variables       *
			************************/

			l_Gl_business_class_cat                  MTL_CATEGORIES_VL.description%TYPE;

			/****************
			* Cursors       *
			****************/

			CURSOR      cur_Gl_business_class_cat
			(
			p_Gl_business_class_cat_id    IN       NUMBER
			)
			IS
			SELECT               description
			FROM                 mtl_categories_vl
			WHERE                structure_id IN   (
																						 SELECT       fifs.id_flex_num
																						 FROM         fnd_id_flex_structures_vl fifs
																						 WHERE        fifs.application_id = 401
																						 AND          fifs.id_flex_code = 'MCAT'
																						 AND          fifs.id_flex_structure_code = 'GL_BUSINESS_CLASS'
																						 AND          enabled_flag = 'Y'
																						 )
			AND                  category_id = p_Gl_business_class_cat_id;

	 BEGIN

			OPEN cur_Gl_business_class_cat(p_Gl_business_class_cat_id);
			FETCH cur_Gl_business_class_cat INTO l_Gl_business_class_cat;

			IF cur_Gl_business_class_cat%NOTFOUND THEN
				CLOSE cur_Gl_business_class_cat;
				RAISE NO_DATA_FOUND;
			END IF;

			CLOSE cur_Gl_business_class_cat;

			RETURN(l_Gl_business_class_cat);

	 EXCEPTION
			WHEN OTHERS THEN

				 /********************************
				 * Migration Started Log Message *
				 ********************************/

				 GMA_COMMON_LOGGING.gma_migration_central_log
				 (
				 p_run_id             =>       G_migration_run_id,
				 p_log_level          =>       FND_LOG.LEVEL_ERROR,
				 p_message_token      =>       'GMA_MIG_GL_BUS_CLASS_ERROR',
				 p_table_name         =>       G_Table_name,
				 p_context            =>       G_context,
				 p_token1             =>       'GL_BUSINESS_CLASS_CAT_ID',
				 p_param1             =>       p_Gl_business_class_cat_id,
				 p_db_error           =>       NULL,
				 p_app_short_name     =>       'GMA'
				 );

				RETURN NULL;

	 END Get_Gl_business_class_cat;

	 /**********************************************************************
	 *    FUNCTION:                                                        *
	 *      Get_gl_product_line_cat                                      *
	 *                                                                     *
	 *    DESCRIPTION:                                                     *
	 *      This is an internal function used to retrieve gl_product_line*
	 *                                                                     *
	 *    PARAMETERS:                                                      *
	 *      p_gl_product_line_cat_id - OPM gl_product_line_cat Id      *
	 *                                   to retrieve the value             *
	 *                                                                     *
	 *    SYNOPSIS:                                                        *
	 *      Get_gl_product_line_cat (p_gl_product_line_cat_id => 12121)*
	 *                                                                     *
	 *    HISTORY                                                          *
	 *       27-Apr-2005 Created  Anand Thiyagarajan                       *
	 **********************************************************************/
	 FUNCTION Get_Gl_product_line_cat
	 (
	 p_Gl_product_line_cat_id          IN             NUMBER
	 )
	 RETURN VARCHAR2
	 IS

			/************************
			* Local Variables       *
			************************/

			l_Gl_product_line_cat                  MTL_CATEGORIES_VL.description%TYPE;

			/****************
			* Cursors       *
			****************/

			CURSOR      cur_Gl_product_line_cat
			(
			p_Gl_product_line_cat_id    IN       NUMBER
			)
			IS
			SELECT               description
			FROM                 mtl_categories_vl
			WHERE                structure_id IN
																						 (
																						 SELECT       fifs.id_flex_num
																						 FROM         fnd_id_flex_structures_vl fifs
																						 WHERE        fifs.application_id = 401
																						 AND          fifs.id_flex_code = 'MCAT'
																						 AND          fifs.id_flex_structure_code = 'GL_PRODUCT_LINE'
																						 AND          enabled_flag = 'Y'
																						 )
			AND                  category_id = p_Gl_product_line_cat_id;

	 BEGIN

			OPEN cur_Gl_product_line_cat(p_Gl_product_line_cat_id);
			FETCH cur_Gl_product_line_cat INTO l_Gl_product_line_cat;

			IF cur_Gl_product_line_cat%NOTFOUND THEN
				CLOSE cur_Gl_product_line_cat;
				RAISE NO_DATA_FOUND;
			END IF;

			CLOSE cur_Gl_product_line_cat;

			RETURN(l_Gl_product_line_cat);

	 EXCEPTION
			WHEN OTHERS THEN

				 /********************************
				 * Migration Started Log Message *
				 ********************************/

				 GMA_COMMON_LOGGING.gma_migration_central_log
				 (
				 p_run_id             =>       G_migration_run_id,
				 p_log_level          =>       FND_LOG.LEVEL_ERROR,
				 p_message_token      =>       'GMA_MIG_GL_PROD_LINE_ERROR',
				 p_table_name         =>       G_Table_name,
				 p_context            =>       G_context,
				 p_token1             =>       'GL_PRODUCT_LINE_CAT_ID',
				 p_param1             =>       p_Gl_product_line_cat_id,
				 p_db_error           =>       NULL,
				 p_app_short_name     =>       'GMA'
				 );

				RETURN NULL;

	 END Get_Gl_product_line_cat;

	 /**********************************************************************
	 *    FUNCTION:                                                        *
	 *      Get_UOM_code                                                   *
	 *                                                                     *
	 *    DESCRIPTION:                                                     *
	 *      This is an internal function used to retrieve the UOM Code     *
	 *      for the OPM UM passed                                          *
	 *                                                                     *
	 *    PARAMETERS:                                                      *
	 *      p_UM_code  - Unit Of Measure Code                              *
	 *                                                                     *
	 *    SYNOPSIS:                                                        *
	 *      Get_UOM_code (p_UM_Code => 'Hours');                           *
	 *                                                                     *
	 *    HISTORY                                                          *
	 *       27-Apr-2005 Created  Anand Thiyagarajan                       *
	 **********************************************************************/
	 FUNCTION Get_Uom_Code
	 (
	 p_um_code               IN             VARCHAR2
	 )
	 RETURN VARCHAR2
	 IS

			/************************
			* Local Variables       *
			************************/

			L_uom_code           sy_uoms_mst.uom_code%TYPE;

			/****************
			* Cursors       *
			****************/

			CURSOR      cur_uom_code
			(
			p_um_code            IN       VARCHAR2
			)
			IS
			SELECT      uom_code
			FROM        sy_uoms_mst
			WHERE       um_code = p_um_code;

	 BEGIN

			OPEN cur_uom_code(p_um_code);
			FETCH cur_uom_code INTO L_uom_code;

			IF cur_uom_code%NOTFOUND THEN
				CLOSE cur_uom_code;
				RAISE NO_DATA_FOUND;
			END IF;

			CLOSE cur_uom_code;

			RETURN(L_uom_code);

	 EXCEPTION
			WHEN OTHERS THEN

				 /********************************
				 * Migration Started Log Message *
				 ********************************/

				 GMA_COMMON_LOGGING.gma_migration_central_log
				 (
				 p_run_id             =>       G_migration_run_id,
				 p_log_level          =>       FND_LOG.LEVEL_ERROR,
				 p_message_token      =>       'GMA_MIG_UOM_ERROR',
				 p_table_name         =>       G_Table_name,
				 p_context            =>       G_context,
				 p_token1             =>       'UM_CODE',
				 p_param1             =>       p_um_code,
				 p_db_error           =>       NULL,
				 p_app_short_name     =>       'GMA'
				 );

				RETURN NULL;

	 END Get_uom_Code;

	 /**********************************************************************
	 *    FUNCTION:                                                        *
	 *      Get_Account_Id                                                 *
	 *                                                                     *
	 *    DESCRIPTION:                                                     *
	 *      This is an internal function used to retrieve the Account Id   *
	 *      value from the Financials setup for the Account Code and       *
	 *      Company Code passed                                            *
	 *                                                                     *
	 *    PARAMETERS:                                                      *
	 *      p_Account_code      - Account Code                             *
	 *      p_co_code           - Company Code                             *
	 *                                                                     *
	 *    SYNOPSIS:                                                        *
	 *      Get_Account_Id (p_Account_Code => '100-0000-0000-0000-0000',   *
	 *                      p_co_code => 'PRU');                           *
	 *                                                                     *
	 *    HISTORY                                                          *
	 *       27-Apr-2005 Created  Anand Thiyagarajan                       *
	 *       05-Jul-2006 rseshadr bug 5374823 - date has to be formatted   *
	 *         appropriate in the call to fnd_flex_ext.                    *
	 **********************************************************************/
	 FUNCTION Get_Account_Id
	 (
	 p_account_code          IN             VARCHAR2,
	 p_co_code               IN             VARCHAR2
	 )
	 RETURN VARCHAR2
	 IS

			/*****************************
			* PL/SQL Table Definition    *
			*****************************/

			TYPE segment_values_tbl IS TABLE OF VARCHAR2(240) INDEX BY BINARY_INTEGER;

			/******************
			* Local Variables *
			******************/

			L_segment               segment_values_tbl;
			L_segment_index         NUMBER(10) DEFAULT 0;
			L_value                 NUMBER(10);
			L_index                 NUMBER(10);
			L_position              NUMBER(10) DEFAULT 1;
			L_length                NUMBER(10);
			L_result                VARCHAR2(2000);
			L_segment_values        gmf_get_mappings.my_opm_seg_values;
			L_segment_delimiter     VARCHAR2(10);
			L_chart_of_accounts_id  NUMBER;
			L_Account_Id            NUMBER;

			/**********
			* Cursors *
			**********/

			CURSOR      cur_plcy_seg
			IS
			SELECT      p.type,
									p.length,
									p.segment_no segment_ref,
									pm.segment_delimiter
			FROM        gl_plcy_seg p,
									gl_plcy_mst pm,
									fnd_id_flex_segments f,
									gl_sets_of_books s
			WHERE       p.co_code = p_co_code
			AND         p.delete_mark = 0
			AND         p.co_code = pm.co_code
			AND         pm.sob_id = s.set_of_books_id
			AND         s.chart_of_accounts_id = f.id_flex_num
			AND         f.application_id = 101
			AND         f.id_flex_code = 'GL#'
			AND         LOWER(f.segment_name)  = LOWER(p.short_name)
			AND         f.enabled_flag         = 'Y'
			ORDER BY    f.segment_num;

			CURSOR cur_segment_delimiter
			IS
			SELECT      concatenated_segment_delimiter,
									glsob.chart_of_accounts_id
			FROM        gl_sets_of_books glsob,
									fnd_id_flex_structures fifstr,
									fnd_application fa,
									gl_plcy_mst gpm
			WHERE       glsob.chart_of_accounts_id = fifstr.id_flex_num
			AND         fifstr.id_flex_code = 'GL#'
			AND         fifstr.application_id = fa.application_id
			AND         fa.application_short_name = 'SQLGL'
			AND         gpm.sob_id = glsob.set_of_books_id
			AND         gpm.co_code = p_co_code;

	 BEGIN

			OPEN cur_segment_delimiter;
			FETCH cur_segment_delimiter INTO L_segment_delimiter, L_Chart_of_accounts_id;

			IF cur_segment_delimiter%NOTFOUND THEN
				CLOSE cur_segment_delimiter;
				RAISE NO_DATA_FOUND;
			END IF;

			CLOSE cur_segment_delimiter;

			L_segment_values := gmf_get_mappings.get_opm_segment_values(p_account_code,p_co_code,2);

			FOR i IN 1..30 LOOP
				 L_segment(i) := NULL;
			END LOOP;

			FOR cur_plcy_seg_tmp IN cur_plcy_seg LOOP

				 L_segment_index := L_segment_index + 1;

				 IF (cur_plcy_seg_tmp.segment_ref = 0) THEN
						L_value := L_segment_index;
				 ELSE
						L_value := cur_plcy_seg_tmp.segment_ref;
				 END IF;

				 L_index  := L_value;
				 L_length := cur_plcy_seg_tmp.length;
				 L_segment(L_index) := L_segment_values(L_position);
				 L_position := L_position +  1;

			END LOOP;

			FOR i IN 1..30 LOOP
				IF (i < 30) THEN
					 L_result := L_result||L_segment(i)||L_segment_delimiter;
				ELSE
						L_result := L_result||L_segment(i);
				END IF;
			END LOOP;

			/**
			* rseshadr bug 5374823 - format date in call to fnd_flex_ext otherwise
			* raises an error
			**/
			L_Account_id := fnd_flex_ext.get_ccid(
				application_short_name => 'SQLGL',
				key_flex_code => 'GL#',
				structure_number => L_Chart_of_Accounts_id,
				validation_date => TO_CHAR(SYSDATE, FND_FLEX_EXT.DATE_FORMAT),
				concatenated_segments => L_Result);

			IF L_Account_id IS NULL OR L_Account_id <= 0 THEN
				 RAISE NO_DATA_FOUND;
			END IF;

			RETURN (L_Account_id);

	 EXCEPTION
			WHEN OTHERS THEN

				 /********************************
				 * Migration Started Log Message *
				 ********************************/

				 GMA_COMMON_LOGGING.gma_migration_central_log
				 (
				 p_run_id             =>       G_migration_run_id,
				 p_log_level          =>       FND_LOG.LEVEL_ERROR,
				 p_message_token      =>       'GMA_MIG_ACCOUNT_ERROR',
				 p_table_name         =>       G_Table_name,
				 p_context            =>       G_context,
				 p_token1             =>       'ACCOUNT_CODE',
				 p_token2             =>       'CO_CODE',
				 p_param1             =>       p_account_code,
				 p_param2             =>       p_co_code,
				 p_db_error           =>       NULL,
				 p_app_short_name     =>       'GMA'
				 );

				RETURN NULL;

	 END get_account_id;

	 /****************************************************************************
	 *    FUNCTION:                                                              *
	 *      Get_co_code                                                          *
	 *                                                                           *
	 *    DESCRIPTION:                                                           *
	 *      This is an internal function used to retrieve the Company Code       *
	 *      value for the Warehouse Code passed                                  *
	 *                                                                           *
	 *    PARAMETERS:                                                            *
	 *      p_whse_code    - Warehouse Code to retrieve the value.               *
	 *                                                                           *
	 *    SYNOPSIS:                                                              *
	 *      Get_Co_Code (p_whse_code => 'PR1');                                  *
	 *                                                                           *
	 *    HISTORY                                                                *
	 *       27-Apr-2005 Created  Anand Thiyagarajan                             *
	 *                                                                           *
	 ****************************************************************************/
	 FUNCTION Get_Co_Code
	 (
	 p_whse_code             IN             VARCHAR2
	 )
	 RETURN VARCHAR2
	 IS

			/************************
			* Local Variables       *
			************************/

			L_co_code  sy_orgn_mst.co_code%TYPE;

			/****************
			* Cursors       *
			****************/

			CURSOR      cur_co_code
			(
			p_whse_code   IN    VARCHAR2
			)
			IS
			select      a.co_code
			from        sy_orgn_mst a,
									ic_whse_mst b
			where       a.orgn_code = b.orgn_code
			and         b.whse_code = p_whse_code;

	 BEGIN

			OPEN Cur_co_code(p_whse_code);
			FETCH Cur_co_code INTO L_co_code;

			IF Cur_co_code%NOTFOUND THEN
				CLOSE Cur_co_code;
				RAISE NO_DATA_FOUND;
			END IF;

			CLOSE Cur_co_code;

			RETURN(L_co_code);

	 EXCEPTION
			WHEN OTHERS THEN

				 /********************************
				 * Migration Started Log Message *
				 ********************************/

				 GMA_COMMON_LOGGING.gma_migration_central_log
				 (
				 p_run_id             =>       G_migration_run_id,
				 p_log_level          =>       FND_LOG.LEVEL_ERROR,
				 p_message_token      =>       'GMA_MIG_CO_WHSE_ERROR',
				 p_table_name         =>       G_Table_name,
				 p_context            =>       G_context,
				 p_token1             =>       'WHSE_CODE',
				 p_param1             =>       p_whse_code,
				 p_db_error           =>       NULL,
				 p_app_short_name     =>       'GMA'
				 );

				RETURN NULL;

	 END get_co_code;

	 /**********************************************************************
	 * PROCEDURE:                                                          *
	 *   Migrate_Fiscal_policies_LE                                        *
	 *                                                                     *
	 * DESCRIPTION:                                                        *
	 *   This PL/SQL procedure is used to migrate the Fiscal Policies from *
	 *   GL_PLCY_MST to GMF_FISCAL_POLICIES table.                         *
	 *                                                                     *
	 * PARAMETERS:                                                         *
	 *   P_migration_run_id - id to use to right to migration log          *
	 *   x_exception_count  - Number of exceptions occurred.               *
	 *                                                                     *
	 * SYNOPSIS:                                                           *
	 *   Migrate_Fiscal_policies_LE(p_migartion_id    => l_migration_id,   *
	 *                    p_commit          => 'T',                        *
	 *                    x_exception_count => l_exception_count );        *
	 *                                                                     *
	 * HISTORY                                                             *
	 *    27-Apr-2005 Created  Anand Thiyagarajan                          *
	 *    24-May-2006 rseshadr bug 5246510 - Use the new cost mthd if      *
	 *       set by the user otherwise default from the old cost mthd      *
	 *       Also, ordered the main cursor by le_id because if a null      *
	 *       LE row comes first but the Company points to already mapped   *
	 *       LE, then we may end up with an incorrect gl cost mthd for     *
	 *       the already mapped LEs.  Removed the L_new_legal_entity_id    *
	 *       variable reference in update                                  *
	 *    23-Jun-2006 rseshadr bug 5354837 - do not rely on the view       *
	 *      gmf_legal_entities.  The underlying tables are not populated   *
	 *      until after a much later phase (upg+74).  Use the same logic   *
	 *      as an auto upgrade without the pre-mig ui                      *
	 *                                                                     *
	 **********************************************************************/
	 PROCEDURE Migrate_Fiscal_Policies_LE
	 (
	 P_migration_run_id      IN             NUMBER,
	 P_commit                IN             VARCHAR2,
	 X_failure_count         OUT   NOCOPY   NUMBER
	 )
	 IS

			/***************************
			* PL/SQL Table Definitions *
			***************************/

			/************************
			* Local Variables       *
			************************/

			L_legal_entity_id             NUMBER(15);
			L_ledger_id                   NUMBER(15);
			/* L_new_legal_entity_id         NUMBER(15); */
			l_le_count                    NUMBER;

			/****************
			* Cursors       *
			****************/

			CURSOR      cur_get_fiscal_policies IS
			SELECT      *
			FROM        gl_plcy_mst
			WHERE       NVL(migrated_ind,'~') <> '1'
			ORDER BY legal_entity_id NULLS LAST;

	 BEGIN

			G_Migration_run_id := P_migration_run_id;
			G_Table_name := 'GMF_FISCAL_POLICIES';
			G_Context := 'Fiscal Policies LE Migration';
			X_failure_count := 0;

			/********************************
			* Migration Started Log Message *
			********************************/

			GMA_COMMON_LOGGING.gma_migration_central_log
			(
			p_run_id             =>       G_migration_run_id,
			p_log_level          =>       FND_LOG.LEVEL_STATEMENT,
			p_message_token      =>       'GMA_MIGRATION_TABLE_STARTED',
			p_table_name         =>       G_Table_name,
			p_context            =>       G_Context,
			p_db_error           =>       NULL,
			p_app_short_name     =>       'GMA'
			);


			/****************************************
			* Insert a row into gmf_fiscal_policies *
			****************************************/

			FOR i IN Cur_get_fiscal_policies
			LOOP
				 IF i.legal_entity_id IS NULL THEN
					 BEGIN
							SELECT   to_number(org_information2),
											 to_number(org_information3)
							INTO     l_legal_entity_id,
											 l_ledger_id
							FROM     hr_organization_information
							WHERE    org_information_context = 'Operating Unit Information'
							AND      organization_id = i.org_id;
					 EXCEPTION
							WHEN OTHERS THEN
								 L_legal_entity_id := NULL;
								 L_ledger_id := NULL;
					 END;
				 ELSE
					 L_legal_entity_id := i.legal_entity_id;
					 BEGIN
						 SELECT   to_number(org_information3)
						 INTO     l_ledger_id
						 FROM     hr_organization_information
						 WHERE    org_information_context = 'Operating Unit Information'
						 AND      organization_id = i.org_id;
					 EXCEPTION
						 WHEN OTHERS THEN
							 L_ledger_id := NULL;
					 END;
				 END IF;

				 BEGIN
						SELECT         count(1)
						INTO           l_le_count
						FROM           gmf_fiscal_policies
						WHERE          legal_entity_id = L_legal_entity_id;
				 EXCEPTION
						WHEN no_data_found THEN
							 l_le_count := 0;
						WHEN too_many_rows THEN
							 l_le_count := 99;
						WHEN OTHERS THEN
							 l_le_count := 0;
				 END;

				 IF L_legal_entity_id IS NOT NULL AND nvl(l_le_count,0) = 0 THEN

						BEGIN
							 INSERT INTO gmf_fiscal_policies
							 (
							 LEGAL_ENTITY_ID,
							 BASE_CURRENCY_CODE,
							 LEDGER_ID,
							 MTL_CMPNTCLS_ID,
							 MTL_ANALYSIS_CODE,
							 GL_COST_MTHD,
							 COST_BASIS,
							 TEXT_CODE,
							 DELETE_MARK,
							 CREATED_BY,
							 CREATION_DATE,
							 LAST_UPDATE_LOGIN,
							 LAST_UPDATE_DATE,
							 LAST_UPDATED_BY,
							 ATTRIBUTE1,
							 ATTRIBUTE2,
							 ATTRIBUTE3,
							 ATTRIBUTE4,
							 ATTRIBUTE5,
							 ATTRIBUTE6,
							 ATTRIBUTE7,
							 ATTRIBUTE8,
							 ATTRIBUTE9,
							 ATTRIBUTE10,
							 ATTRIBUTE11,
							 ATTRIBUTE12,
							 ATTRIBUTE13,
							 ATTRIBUTE14,
							 ATTRIBUTE15,
							 ATTRIBUTE16,
							 ATTRIBUTE17,
							 ATTRIBUTE18,
							 ATTRIBUTE19,
							 ATTRIBUTE20,
							 ATTRIBUTE21,
							 ATTRIBUTE22,
							 ATTRIBUTE23,
							 ATTRIBUTE24,
							 ATTRIBUTE25,
							 ATTRIBUTE26,
							 ATTRIBUTE27,
							 ATTRIBUTE28,
							 ATTRIBUTE29,
							 ATTRIBUTE30,
							 ATTRIBUTE_CATEGORY
							 )
							 VALUES
							 (
							 L_legal_entity_id,
							 i.base_currency_code,
							 L_ledger_id,
							 i.mtl_cmpntcls_id,
							 i.mtl_analysis_code,
							 NVL(i.new_le_cost_mthd_code,i.gl_cost_mthd),
							 i.cost_basis,
							 i.text_code,
							 i.delete_mark,
							 i.created_by,
							 i.creation_date,
							 i.last_update_login,
							 i.last_update_date,
							 i.last_updated_by,
							 i.attribute1,
							 i.attribute2,
							 i.attribute3,
							 i.attribute4,
							 i.attribute5,
							 i.attribute6,
							 i.attribute7,
							 i.attribute8,
							 i.attribute9,
							 i.attribute10,
							 i.attribute11,
							 i.attribute12,
							 i.attribute13,
							 i.attribute14,
							 i.attribute15,
							 i.attribute16,
							 i.attribute17,
							 i.attribute18,
							 i.attribute19,
							 i.attribute20,
							 i.attribute21,
							 i.attribute22,
							 i.attribute23,
							 i.attribute24,
							 i.attribute25,
							 i.attribute26,
							 i.attribute27,
							 i.attribute28,
							 i.attribute29,
							 i.attribute30,
							 i.attribute_category
							 );

							 UPDATE   gl_plcy_mst
							 SET      migrated_ind = '1',
												legal_entity_id = decode(legal_entity_id, NULL, L_legal_entity_id, legal_entity_id),
												last_update_date = SYSDATE
							 WHERE    co_code = i.co_code;

						EXCEPTION
							 WHEN OTHERS THEN

									/************************************************
									* Increment Failure Count for Failed Migrations *
									************************************************/
									x_failure_count := x_failure_count + 1;

									GMA_COMMON_LOGGING.gma_migration_central_log
									(
									p_run_id             =>       G_migration_run_id,
									p_log_level          =>       FND_LOG.LEVEL_ERROR,
									p_message_token      =>       'GMA_MIGRATION_DB_ERROR',
									p_table_name         =>       G_Table_name,
									p_context            =>       G_Context,
									p_db_error           =>       SQLERRM,
									p_app_short_name     =>       'GMA'
									);

									GMA_COMMON_LOGGING.gma_migration_central_log
									(
									p_run_id             =>       G_migration_run_id,
									p_log_level          =>       FND_LOG.LEVEL_ERROR,
									p_message_token      =>       'GMA_TABLE_MIGRATION_TABLE_FAIL',
									p_table_name         =>       G_Table_name,
									p_context            =>       G_Context,
									p_db_error           =>       NULL,
									p_app_short_name     =>       'GMA'
									);
						END;

					ELSIF L_legal_entity_id IS NOT NULL AND nvl(l_le_count,0) > 0 THEN

						 UPDATE   gl_plcy_mst
						 SET      migrated_ind = '1',
											legal_entity_id = decode(legal_entity_id, NULL, L_legal_entity_id, legal_entity_id),
											last_update_date = SYSDATE
						 WHERE    co_code = i.co_code;

					ELSE

						 x_failure_count := x_failure_count + 1;
						 L_legal_entity_id := NULL;

						 GMA_COMMON_LOGGING.gma_migration_central_log
						 (
						 p_run_id             =>       G_migration_run_id,
						 p_log_level          =>       FND_LOG.LEVEL_ERROR,
						 p_message_token      =>       'GMA_MIG_FISCAL_DUP_LE_ERROR',
						 p_table_name         =>       G_Table_name,
						 p_context            =>       G_Context,
						 p_token1             =>       'CO_CODE',
						 p_param1             =>       i.co_code,
						 p_db_error           =>       NULL,
						 p_app_short_name     =>       'GMA'
						 );

				 END IF;

			END LOOP;

			/**********************************************
			* Handle all the rows which were not migrated *
			**********************************************/

			SELECT            count(*)
			INTO              x_failure_count
			FROM              gl_plcy_mst
			WHERE             (legal_entity_id IS NULL AND co_code IS NOT NULL);

			IF nvl(x_failure_count,0) > 0 THEN

				/**************************************
				* Migration Failure Log Message       *
				**************************************/

				GMA_COMMON_LOGGING.gma_migration_central_log
				(
				p_run_id             =>       gmf_migration.G_migration_run_id,
				p_log_level          =>       FND_LOG.LEVEL_PROCEDURE,
				p_message_token      =>       'GMA_TABLE_MIGRATION_TABLE_FAIL',
				p_table_name         =>       gmf_migration.G_Table_name,
				p_context            =>       gmf_migration.G_context,
				p_db_error           =>       NULL,
				p_app_short_name     =>       'GMA'
				);

			ELSE

				/**************************************
				* Migration Success Log Message       *
				**************************************/

				GMA_COMMON_LOGGING.gma_migration_central_log
				(
				p_run_id             =>       G_migration_run_id,
				p_log_level          =>       FND_LOG.LEVEL_STATEMENT,
				p_message_token      =>       'GMA_MIGRATION_TABLE_SUCCESS',
				p_table_name         =>       G_Table_name,
				p_context            =>       G_Context,
				p_param1             =>       1,
				p_param2             =>       0,
				p_db_error           =>       NULL,
				p_app_short_name     =>       'GMA'
				);

			END IF;

			/****************************************************************
			* Lets save the changes now based on the commit parameter       *
			****************************************************************/

			IF NVL(p_commit,'~') = FND_API.G_TRUE THEN
				 COMMIT;
			END IF;

	 EXCEPTION
			WHEN OTHERS THEN

				 /************************************************
				 * Increment Failure Count for Failed Migrations *
				 ************************************************/
				 x_failure_count := x_failure_count + 1;

				 /**************************************
				 * Migration DB Error Log Message      *
				 **************************************/

				 GMA_COMMON_LOGGING.gma_migration_central_log
				 (
				 p_run_id             =>       G_migration_run_id,
				 p_log_level          =>       FND_LOG.LEVEL_ERROR,
				 p_message_token      =>       'GMA_MIGRATION_DB_ERROR',
				 p_table_name         =>       G_Table_name,
				 p_context            =>       G_Context,
				 p_db_error           =>       SQLERRM,
				 p_app_short_name     =>       'GMA'
				 );

				 /**************************************
				 * Migration Failure Log Message       *
				 **************************************/

				 GMA_COMMON_LOGGING.gma_migration_central_log
				 (
				 p_run_id             =>       G_migration_run_id,
				 p_log_level          =>       FND_LOG.LEVEL_ERROR,
				 p_message_token      =>       'GMA_TABLE_MIGRATION_TABLE_FAIL',
				 p_table_name         =>       G_Table_name,
				 p_context            =>       G_Context,
				 p_db_error           =>       NULL,
				 p_app_short_name     =>       'GMA'
				 );

	 END Migrate_Fiscal_policies_LE;

	 /**********************************************************************
	 * PROCEDURE:                                                          *
	 *   Migrate_Fiscal_Policies_Others                                    *
	 *                                                                     *
	 * DESCRIPTION:                                                        *
	 *   This PL/SQL procedure is used to migrate the Cost Method          *
	 *   and Periods                                                       *
	 *                                                                     *
	 * PARAMETERS:                                                         *
	 *   P_migration_run_id - id to use to right to migration log          *
	 *   x_exception_count  - Number of exceptions occurred.               *
	 *                                                                     *
	 * SYNOPSIS:                                                           *
	 *   Migrate_Fiscal_Policies_Others(p_migartion_id => l_migration_id,  *
	 *                    p_commit          => 'T',                        *
	 *                    x_exception_count => l_exception_count );        *
	 *                                                                     *
	 * HISTORY                                                             *
	 *       27-Apr-2005 Created  Anand Thiyagarajan                       *
	 *       22-aug-2006 bug 5473365, pmarada, inserting records in        *
	 *                   gmf_ledger_valuation_methods table                *
	 *                                                                     *
	 **********************************************************************/
	 PROCEDURE Migrate_Fiscal_Policies_Others
	 (
	 P_migration_run_id      IN             NUMBER,
	 P_commit                IN             VARCHAR2,
	 X_failure_count         OUT   NOCOPY   NUMBER
	 )
	 IS

			/**************************
			* PL/SQL Table Definition *
			**************************/

			/******************
			* Local Variables *
			******************/

	 BEGIN

			G_Migration_run_id := P_migration_run_id;
			G_Table_name := 'GMF_FISCAL_POLICIES';
			G_Context := 'Fiscal Policies Migration - Others';
			X_failure_count := 0;

			/********************************
			* Migration Started Log Message *
			********************************/

			GMA_COMMON_LOGGING.gma_migration_central_log
			(
			p_run_id             =>       G_migration_run_id,
			p_log_level          =>       FND_LOG.LEVEL_STATEMENT,
			p_message_token      =>       'GMA_MIGRATION_TABLE_STARTED',
			p_table_name         =>       G_Table_name,
			p_context            =>       G_Context,
			p_db_error           =>       NULL,
			p_app_short_name     =>       'GMA'
			);

			/********************************************************
			* Update a row in GMF_FISCAL_POLICIES for GL cost Types *
			********************************************************/

			BEGIN
				 UPDATE      gmf_fiscal_policies a
				 SET         a.cost_type_id =  (
																			 SELECT      x.cost_type_id
																			 FROM        cm_mthd_mst x
																			 WHERE       x.cost_mthd_code = a.gl_cost_mthd
																			 )
				 WHERE       a.cost_type_id IS NULL AND a.gl_cost_mthd IS NOT NULL;

				/*************************************************************************
				* Insert rows in GMF_ledger_valuation_methods table for the legal entity *
				**************************************************************************/

				INSERT INTO gmf_ledger_valuation_methods
				(
				legal_entity_id,
				ledger_id,
				cost_type_id,
				creation_date,
				created_by,
				last_update_date,
				last_updated_by,
				last_update_login,
				text_code,
				delete_mark
				)
				SELECT        gfp.legal_entity_id,
											gfp.ledger_id,
											gfp.cost_type_id,
											gfp.creation_date,
											gfp.created_by,
											gfp.last_update_date,
											gfp.last_updated_by,
											gfp.last_update_login,
											gfp.text_code,
											0
				FROM          gmf_fiscal_policies gfp
				WHERE         NOT EXISTS  (
																	SELECT          '1'
																	FROM            gmf_ledger_valuation_methods glvm
																	WHERE           glvm.legal_entity_id = gfp.legal_entity_id
																	AND             glvm.ledger_id = gfp.ledger_id
																	);

			EXCEPTION
				 WHEN OTHERS THEN

						/************************************************
						* Increment Failure Count for Failed Migrations *
						************************************************/

						x_failure_count := x_failure_count + 1;

						/**************************************
						* Migration DB Error Log Message      *
						**************************************/

						GMA_COMMON_LOGGING.gma_migration_central_log
						(
						p_run_id             =>       G_migration_run_id,
						p_log_level          =>       FND_LOG.LEVEL_ERROR,
						p_message_token      =>       'GMA_MIGRATION_DB_ERROR',
						p_table_name         =>       G_Table_name,
						p_context            =>       G_Context,
						p_db_error           =>       SQLERRM,
						p_app_short_name     =>       'GMA'
						);

						/**************************************
						* Migration Failure Log Message       *
						**************************************/

						GMA_COMMON_LOGGING.gma_migration_central_log
						(
						p_run_id             =>       G_migration_run_id,
						p_log_level          =>       FND_LOG.LEVEL_ERROR,
						p_message_token      =>       'GMA_TABLE_MIGRATION_TABLE_FAIL',
						p_table_name         =>       G_Table_name,
						p_context            =>       G_Context,
						p_db_error           =>       NULL,
						p_app_short_name     =>       'GMA'
						);

			END;

			/**********************************************
			* Handle all the rows which were not migrated *
			**********************************************/

			SELECT            count(*)
			INTO              x_failure_count
			FROM              gmf_fiscal_policies
			WHERE             (cost_type_id IS NULL AND gl_cost_mthd IS NOT NULL);

			IF nvl(x_failure_count,0) > 0 THEN

				/**************************************
				* Migration Failure Log Message       *
				**************************************/

				GMA_COMMON_LOGGING.gma_migration_central_log
				(
				p_run_id             =>       gmf_migration.G_migration_run_id,
				p_log_level          =>       FND_LOG.LEVEL_PROCEDURE,
				p_message_token      =>       'GMA_TABLE_MIGRATION_TABLE_FAIL',
				p_table_name         =>       gmf_migration.G_Table_name,
				p_context            =>       gmf_migration.G_context,
				p_db_error           =>       NULL,
				p_app_short_name     =>       'GMA'
				);

			ELSE

				/**************************************
				* Migration Success Log Message       *
				**************************************/

				GMA_COMMON_LOGGING.gma_migration_central_log
				(
				p_run_id             =>       G_migration_run_id,
				p_log_level          =>       FND_LOG.LEVEL_STATEMENT,
				p_message_token      =>       'GMA_MIGRATION_TABLE_SUCCESS',
				p_table_name         =>       G_Table_name,
				p_context            =>       G_Context,
				p_param1             =>       1,
				p_param2             =>       0,
				p_db_error           =>       NULL,
				p_app_short_name     =>       'GMA'
				);

			END IF;

			/****************************************************************
			* Lets save the changes now based on the commit parameter       *
			****************************************************************/

			IF NVL(p_commit,'~') = FND_API.G_TRUE THEN
				 COMMIT;
			END IF;

	 EXCEPTION
			WHEN OTHERS THEN

				 /************************************************
				 * Increment Failure Count for Failed Migrations *
				 ************************************************/

				 x_failure_count := x_failure_count + 1;

				 /**************************************
				 * Migration DB Error Log Message      *
				 **************************************/

				 GMA_COMMON_LOGGING.gma_migration_central_log
				 (
				 p_run_id             =>       G_migration_run_id,
				 p_log_level          =>       FND_LOG.LEVEL_ERROR,
				 p_message_token      =>       'GMA_MIGRATION_DB_ERROR',
				 p_table_name         =>       G_Table_name,
				 p_context            =>       G_Context,
				 p_db_error           =>       SQLERRM,
				 p_app_short_name     =>       'GMA'
				 );

				 /**************************************
				 * Migration Failure Log Message       *
				 **************************************/

				 GMA_COMMON_LOGGING.gma_migration_central_log
				 (
				 p_run_id             =>       G_migration_run_id,
				 p_log_level          =>       FND_LOG.LEVEL_ERROR,
				 p_message_token      =>       'GMA_TABLE_MIGRATION_TABLE_FAIL',
				 p_table_name         =>       G_Table_name,
				 p_context            =>       G_Context,
				 p_db_error           =>       NULL,
				 p_app_short_name     =>       'GMA'
				 );

	 END Migrate_Fiscal_Policies_Others;

	 /**********************************************************************
	 * PROCEDURE:                                                          *
	 *   Migrate_Cost_Methods                                              *
	 *                                                                     *
	 * DESCRIPTION:                                                        *
	 *   This PL/SQL procedure is used to transform the Cost Methods       *
	 *   data in CM_MTHD_MST                                               *
	 *                                                                     *
	 * PARAMETERS:                                                         *
	 *   P_migration_run_id - id to use to right to migration log          *
	 *   x_exception_count  - Number of exceptions occurred.               *
	 *                                                                     *
	 * SYNOPSIS:                                                           *
	 *   Migrate_cost_methods(p_migartion_id    => l_migration_id,         *
	 *                    p_commit          => 'T',                        *
	 *                    x_exception_count => l_exception_count );        *
	 *                                                                     *
	 * HISTORY                                                             *
	 *       27-Apr-2005 Created  Anand Thiyagarajan                       *
	 *                                                                     *
	 **********************************************************************/
	 PROCEDURE Migrate_Cost_Methods
	 (
	 P_migration_run_id      IN             NUMBER,
	 P_commit                IN             VARCHAR2,
	 X_failure_count         OUT   NOCOPY   NUMBER
	 )
	 IS

			/****************
			* PL/SQL Tables *
			****************/

			/******************
			* Local Variables *
			******************/

	 BEGIN

			G_Migration_run_id := P_migration_run_id;
			G_Table_name := 'CM_MTHD_MST';
			G_Context := 'Cost Types Migration';
			X_failure_count := 0;

			/********************************
			* Migration Started Log Message *
			********************************/

			GMA_COMMON_LOGGING.gma_migration_central_log
			(
			p_run_id             =>       G_migration_run_id,
			p_log_level          =>       FND_LOG.LEVEL_STATEMENT,
			p_message_token      =>       'GMA_MIGRATION_TABLE_STARTED',
			p_table_name         =>       G_table_name,
			p_context            =>       G_context,
			p_db_error           =>       NULL,
			p_app_short_name     =>       'GMA'
			);

			/*****************************************
			* Update rows For Cost Type Identifier   *
			*****************************************/

			UPDATE      cm_mthd_mst
			SET         cost_type_id = gmf_cost_type_id_s.NEXTVAL
			WHERE       (cost_type_id IS NULL AND cost_mthd_code IS NOT NULL);

			/**********************************************
			* Handle all the rows which were not migrated *
			**********************************************/

			SELECT               count(*)
			INTO                 x_failure_count
			FROM                 cm_mthd_mst
			WHERE                (cost_type_id IS NULL AND cost_mthd_code IS NOT NULL);

			IF nvl(x_failure_count,0) > 0 THEN

				/**************************************
				* Migration Failure Log Message       *
				**************************************/

				GMA_COMMON_LOGGING.gma_migration_central_log
				(
				p_run_id             =>       gmf_migration.G_migration_run_id,
				p_log_level          =>       FND_LOG.LEVEL_PROCEDURE,
				p_message_token      =>       'GMA_TABLE_MIGRATION_TABLE_FAIL',
				p_table_name         =>       gmf_migration.G_Table_name,
				p_context            =>       gmf_migration.G_context,
				p_db_error           =>       NULL,
				p_app_short_name     =>       'GMA'
				);

			ELSE

				/**************************************
				* Migration Success Log Message       *
				**************************************/

				GMA_COMMON_LOGGING.gma_migration_central_log
				(
				p_run_id             =>       G_migration_run_id,
				p_log_level          =>       FND_LOG.LEVEL_STATEMENT,
				p_message_token      =>       'GMA_MIGRATION_TABLE_SUCCESS',
				p_table_name         =>       G_Table_name,
				p_context            =>       G_Context,
				p_param1             =>       1,
				p_param2             =>       0,
				p_db_error           =>       NULL,
				p_app_short_name     =>       'GMA'
				);

			END IF;

			/****************************************************************
			*Lets save the changes now based on the commit parameter        *
			****************************************************************/

			IF NVL(p_commit,'~') = FND_API.G_TRUE THEN
				 COMMIT;
			END IF;

	 EXCEPTION
			WHEN OTHERS THEN

				 /************************************************
				 * Increment Failure Count for Failed Migrations *
				 ************************************************/
				 x_failure_count := x_failure_count + 1;

				 /**************************************
				 * Migration DB Error Log Message      *
				 **************************************/

				 GMA_COMMON_LOGGING.gma_migration_central_log
				 (
				 p_run_id             =>       G_migration_run_id,
				 p_log_level          =>       FND_LOG.LEVEL_ERROR,
				 p_message_token      =>       'GMA_MIGRATION_DB_ERROR',
				 p_table_name         =>       G_table_name,
				 p_context            =>       G_context,
				 p_db_error           =>       SQLERRM,
				 p_app_short_name     =>       'GMA'
				 );

				 /**************************************
				 * Migration Failure Log Message       *
				 **************************************/

				 GMA_COMMON_LOGGING.gma_migration_central_log
				 (
				 p_run_id             =>       G_migration_run_id,
				 p_log_level          =>       FND_LOG.LEVEL_ERROR,
				 p_message_token      =>       'GMA_TABLE_MIGRATION_TABLE_FAIL',
				 p_table_name         =>       G_table_name,
				 p_context            =>       G_context,
				 p_db_error           =>       NULL,
				 p_app_short_name     =>       'GMA'
				 );

	 END Migrate_Cost_Methods;

	 /**********************************************************************
	 * PROCEDURE:                                                          *
	 *   Migrate_Lot_Cost_Methods                                          *
	 *                                                                     *
	 * DESCRIPTION:                                                        *
	 *   This PL/SQL procedure is used to transform the Lot Cost Methods   *
	 *   data in CM_MTHD_MST                                               *
	 *                                                                     *
	 * PARAMETERS:                                                         *
	 *   P_migration_run_id - id to use to right to migration log          *
	 *   x_exception_count  - Number of exceptions occurred.               *
	 *                                                                     *
	 * SYNOPSIS:                                                           *
	 *   Migrate_lot_cost_methods(p_migartion_id    => l_migration_id,     *
	 *                    p_commit          => 'T',                        *
	 *                    x_exception_count => l_exception_count );        *
	 *                                                                     *
	 * HISTORY                                                             *
	 *       27-Apr-2005 Created  Anand Thiyagarajan                       *
	 *                                                                     *
	 **********************************************************************/
	 PROCEDURE Migrate_Lot_Cost_Methods
	 (
	 P_migration_run_id      IN             NUMBER,
	 P_commit                IN             VARCHAR2,
	 X_failure_count         OUT   NOCOPY   NUMBER
	 )
	 IS

			/**************************
			* PL/SQL Table Definition *
			**************************/

			/******************
			* Local Variables *
			******************/

			/**********
			* Cursors *
			**********/

	 BEGIN

			G_Migration_run_id := P_migration_run_id;
			G_Table_name := 'CM_MTHD_MST';
			G_Context := 'Lot Cost Types Migration';
			X_failure_count := 0;

			/********************************
			* Migration Started Log Message *
			********************************/

			GMA_COMMON_LOGGING.gma_migration_central_log
			(
			p_run_id             =>       G_migration_run_id,
			p_log_level          =>       FND_LOG.LEVEL_STATEMENT,
			p_message_token      =>       'GMA_MIGRATION_TABLE_STARTED',
			p_table_name         =>       G_table_name,
			p_context            =>       G_context,
			p_db_error           =>       NULL,
			p_app_short_name     =>       'GMA'
			);

			/*********************************************
			* Update a row in cm_mthd_mst for Lot Costs *
			*********************************************/
			BEGIN

				 UPDATE      cm_mthd_mst a
				 SET         a.default_lot_cost_type_id =  (
																									 SELECT         x.cost_type_id
																									 FROM           cm_mthd_mst x
																									 WHERE          x.cost_mthd_code = a.default_lot_cost_mthd
																									 ),
										 a.cost_type = 6,
										 a.lot_actual_cost = NULL
				 WHERE       cost_type_id IS NOT NULL
				 AND         a.cost_type = 1
				 AND         nvl(a.lot_actual_cost,-1) = 1;

			EXCEPTION
				 WHEN OTHERS THEN

						/************************************************
						* Increment Failure Count for Failed Migrations *
						************************************************/

						x_failure_count := x_failure_count + 1;

						/**************************************
						* Migration DB Error Log Message      *
						**************************************/

						GMA_COMMON_LOGGING.gma_migration_central_log
						(
						p_run_id             =>       G_migration_run_id,
						p_log_level          =>       FND_LOG.LEVEL_ERROR,
						p_message_token      =>       'GMA_MIGRATION_DB_ERROR',
						p_table_name         =>       G_table_name,
						p_context            =>       G_context,
						p_db_error           =>       SQLERRM,
						p_app_short_name     =>       'GMA'
						);

						/**************************************
						* Migration Failure Log Message       *
						**************************************/

						GMA_COMMON_LOGGING.gma_migration_central_log
						(
						p_run_id             =>       G_migration_run_id,
						p_log_level          =>       FND_LOG.LEVEL_ERROR,
						p_message_token      =>       'GMA_TABLE_MIGRATION_TABLE_FAIL',
						p_table_name         =>       G_table_name,
						p_context            =>       G_context,
						p_db_error           =>       NULL,
						p_app_short_name     =>       'GMA'
						);

			END;

			/**********************************************
			* Handle all the rows which were not migrated *
			**********************************************/

			SELECT            count(*)
			INTO              x_failure_count
			FROM              cm_mthd_mst
			WHERE             (
												(default_lot_cost_type_id IS NULL AND default_lot_cost_mthd IS NOT NULL)
			OR                (cost_type = 1 AND nvl(lot_actual_cost,-1) = 1)
												);

			IF nvl(x_failure_count,0) > 0 THEN

				/**************************************
				* Migration Failure Log Message       *
				**************************************/

				GMA_COMMON_LOGGING.gma_migration_central_log
				(
				p_run_id             =>       gmf_migration.G_migration_run_id,
				p_log_level          =>       FND_LOG.LEVEL_PROCEDURE,
				p_message_token      =>       'GMA_TABLE_MIGRATION_TABLE_FAIL',
				p_table_name         =>       gmf_migration.G_Table_name,
				p_context            =>       gmf_migration.G_context,
				p_db_error           =>       NULL,
				p_app_short_name     =>       'GMA'
				);

			ELSE

				/**************************************
				* Migration Success Log Message       *
				**************************************/

				GMA_COMMON_LOGGING.gma_migration_central_log
				(
				p_run_id             =>       G_migration_run_id,
				p_log_level          =>       FND_LOG.LEVEL_STATEMENT,
				p_message_token      =>       'GMA_MIGRATION_TABLE_SUCCESS',
				p_table_name         =>       G_Table_name,
				p_context            =>       G_Context,
				p_param1             =>       1,
				p_param2             =>       0,
				p_db_error           =>       NULL,
				p_app_short_name     =>       'GMA'
				);

			END IF;

			/****************************************************************
			*Lets save the changes now based on the commit parameter        *
			****************************************************************/

			IF NVL(p_commit,'~') = FND_API.G_TRUE THEN
				 COMMIT;
			END IF;

	 EXCEPTION
			WHEN OTHERS THEN

				 /************************************************
				 * Increment Failure Count for Failed Migrations *
				 ************************************************/

				 x_failure_count := x_failure_count + 1;

				 /**************************************
				 * Migration DB Error Log Message      *
				 **************************************/

				 GMA_COMMON_LOGGING.gma_migration_central_log
				 (
				 p_run_id             =>       G_migration_run_id,
				 p_log_level          =>       FND_LOG.LEVEL_ERROR,
				 p_message_token      =>       'GMA_MIGRATION_DB_ERROR',
				 p_table_name         =>       G_table_name,
				 p_context            =>       G_context,
				 p_db_error           =>       SQLERRM,
				 p_app_short_name     =>       'GMA'
				 );

				 /**************************************
				 * Migration Failure Log Message       *
				 **************************************/

				 GMA_COMMON_LOGGING.gma_migration_central_log
				 (
				 p_run_id             =>       G_migration_run_id,
				 p_log_level          =>       FND_LOG.LEVEL_ERROR,
				 p_message_token      =>       'GMA_TABLE_MIGRATION_TABLE_FAIL',
				 p_table_name         =>       G_table_name,
				 p_context            =>       G_context,
				 p_db_error           =>       NULL,
				 p_app_short_name     =>       'GMA'
				 );

	 END Migrate_Lot_Cost_Methods;

	 /**********************************************************************
	 * PROCEDURE:                                                          *
	 *   Migrate_Cost_Calendars                                            *
	 *                                                                     *
	 * DESCRIPTION:                                                        *
	 *   This PL/SQL procedure is used to transform the Cost Calendars     *
	 *   data in CM_CLDR_HDR_B AND CM_CLDR_DTL to GMF_CALENDAR_ASSIGNMENTS *
	 *   and GMF_PERIOD_STATUSES                                           *
	 *                                                                     *
	 * PARAMETERS:                                                         *
	 *   P_migration_run_id - id to use to right to migration log          *
	 *   x_exception_count  - Number of exceptions occurred.               *
	 *                                                                     *
	 * SYNOPSIS:                                                           *
	 *   Migrate_cost_calendars(p_migartion_id    => l_migration_id,       *
	 *                    p_commit          => 'T',                        *
	 *                    x_exception_count => l_exception_count );        *
	 *                                                                     *
	 * HISTORY                                                             *
	 *       27-Apr-2005 Created  Anand Thiyagarajan                       *
   *       16-Dec-2006 Bug#5716122 Anand Thiyagarajan                    *
   *        Modified Code to remve call to gmf_legal_entity_tz API       *
   *        since dates in t he DB are always stored in SRV TZ and not   *
   *        in LE TZ                                                     *
	 *                                                                     *
	 **********************************************************************/
	 PROCEDURE Migrate_Cost_Calendars
	 (
	 P_migration_run_id      IN             NUMBER,
	 P_commit                IN             VARCHAR2,
	 X_failure_count         OUT   NOCOPY   NUMBER
	 )
	 IS

			/*****************
			* PL/SQL Cursors *
			*****************/

			CURSOR cur_overlap_Calendar
			IS
			SELECT      a.legal_entity_id,
									a.cost_Type_id,
									a.calendar_code
			FROM        gmf_calendar_assignments a
			ORDER BY    a.legal_entity_id,
									a.cost_Type_id,
									a.calendar_code;

			/******************
			* Local Variables *
			******************/

			l_exception_count                   NUMBER := 0;

	 BEGIN

			G_Migration_run_id := P_migration_run_id;
			G_Table_name := 'GMF_CALENDAR_ASSIGNMENTS';
			G_Context := 'Cost Calendar Assignments Migration';
			X_failure_count := 0;

			/********************************
			* Migration Started Log Message *
			********************************/

			GMA_COMMON_LOGGING.gma_migration_central_log
			(
			p_run_id             =>       G_migration_run_id,
			p_log_level          =>       FND_LOG.LEVEL_STATEMENT,
			p_message_token      =>       'GMA_MIGRATION_TABLE_STARTED',
			p_table_name         =>       G_table_name,
			p_context            =>       G_context,
			p_db_error           =>       NULL,
			p_app_short_name     =>       'GMA'
			);

			/****************************************************************************
			* Insert a row in gmf_calendar_assignments for Direct Calendar Assignments  *
			*****************************************************************************/
			BEGIN

				INSERT      INTO     gmf_calendar_assignments
				(
				ASSIGNMENT_ID,
				CALENDAR_CODE,
				LEGAL_ENTITY_ID,
				COST_TYPE_ID,
				CREATION_DATE,
				CREATED_BY,
				LAST_UPDATE_DATE,
				LAST_UPDATED_BY,
				LAST_UPDATE_LOGIN,
				TEXT_CODE,
				DELETE_MARK
				)
				SELECT        gmf_calendar_assignments_s.NEXTVAL,
											a.calendar_code,
											b.legal_entity_id,
											c.cost_type_id,
											a.creation_date,
											a.created_by,
											a.last_update_date,
											a.last_updated_by,
											a.last_update_login,
											a.text_code,
											a.delete_mark
				FROM          cm_cldr_hdr_b a,
											gl_plcy_mst b,
											cm_mthd_mst c
				WHERE         a.cost_mthd_code IS NOT NULL
				AND           a.co_code IS NOT NULL
				AND           b.legal_entity_id IS NOT NULL
				AND           c.cost_type_id IS NOT NULL
				AND           a.co_code = b.co_code
				AND           c.cost_mthd_code = a.cost_mthd_code
				AND           NOT EXISTS  (
																	SELECT     'X'
																	FROM        gmf_calendar_assignments x
																	WHERE       x.calendar_code = a.calendar_code
																	AND         x.cost_type_id = c.cost_type_id
																	AND         x.legal_entity_id = b.legal_entity_id
																	);

			EXCEPTION
				 WHEN OTHERS THEN

						/************************************************
						* Increment Failure Count for Failed Migrations *
						************************************************/

						x_failure_count := x_failure_count + 1;

						/**************************************
						* Migration DB Error Log Message      *
						**************************************/

						GMA_COMMON_LOGGING.gma_migration_central_log
						(
						p_run_id             =>       G_migration_run_id,
						p_log_level          =>       FND_LOG.LEVEL_ERROR,
						p_message_token      =>       'GMA_MIGRATION_DB_ERROR',
						p_table_name         =>       G_Table_name,
						p_context            =>       G_context,
						p_db_error           =>       SQLERRM,
						p_app_short_name     =>       'GMA'
						);

						/**************************************
						* Migration Failure Log Message       *
						**************************************/

						GMA_COMMON_LOGGING.gma_migration_central_log
						(
						p_run_id             =>       G_migration_run_id,
						p_log_level          =>       FND_LOG.LEVEL_ERROR,
						p_message_token      =>       'GMA_TABLE_MIGRATION_TABLE_FAIL',
						p_table_name         =>       G_Table_name,
						p_context            =>       G_context,
						p_db_error           =>       NULL,
						p_app_short_name     =>       'GMA'
						);
			END;

			/**********************************************************************
			* Insert a row in gmf_calendar_assignments for transaction table data *
			**********************************************************************/
			BEGIN

				 INSERT      INTO     gmf_calendar_assignments
				 (
				 ASSIGNMENT_ID,
				 CALENDAR_CODE,
				 LEGAL_ENTITY_ID,
				 COST_TYPE_ID,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN,
				 TEXT_CODE,
				 DELETE_MARK
				 )
				 (
				 SELECT       gmf_calendar_assignments_s.NEXTVAL,
											g.calendar_code,
											i.legal_entity_id,
											h.cost_type_id,
											g.creation_date,
											g.created_by,
											g.last_update_date,
											g.last_updated_by,
											g.last_update_login,
											g.text_code,
											1
				FROM          cm_cldr_hdr_b g,
											cm_mthd_mst h,
											gl_plcy_mst i
				WHERE         g.co_code IS NOT NULL
				AND           i.legal_entity_id IS NOT NULL
				AND           g.cost_mthd_code <> h.cost_mthd_code
				AND           i.co_code = g.co_code
				AND           EXISTS  (
															SELECT      'CM_RSRC_DTL'
															FROM        cm_rsrc_dtl a
															WHERE       a.calendar_code is not null
															AND         a.cost_mthd_Code is not null
															AND         a.calendar_code = g.calendar_code
															AND         a.cost_mthd_code = h.cost_mthd_code
															UNION
															SELECT      'CM_CMPT_DTL'
															FROM        cm_cmpt_dtl a
															WHERE       a.calendar_code is not null
															AND         a.cost_mthd_Code is not null
															AND         a.calendar_code = g.calendar_code
															AND         a.cost_mthd_code = h.cost_mthd_code
															UNION
															SELECT      'CM_BRDN_DTL'
															FROM        cm_brdn_dtl a
															WHERE       a.calendar_code is not null
															AND         a.cost_mthd_Code is not null
															AND         a.calendar_code = g.calendar_code
															AND         a.cost_mthd_code = h.cost_mthd_code
															UNION
															SELECT      'CM_ADJS_DTL'
															FROM        cm_adjs_dtl a
															WHERE       a.calendar_code is not null
															AND         a.cost_mthd_Code is not null
															AND         a.calendar_code = g.calendar_code
															AND         a.cost_mthd_code = h.cost_mthd_code
															UNION
															SELECT      'CM_RLUP_CTL'
															FROM        cm_rlup_ctl a
															WHERE       a.calendar_code is not null
															AND         a.cost_mthd_Code is not null
															AND         a.calendar_code = g.calendar_code
															AND         a.cost_mthd_code = h.cost_mthd_code
															UNION
															SELECT      'CM_ACPR_CTL'
															FROM        cm_acpr_ctl a
															WHERE       a.calendar_code is not null
															AND         a.cost_mthd_Code is not null
															AND         a.calendar_code = g.calendar_code
															AND         a.cost_mthd_code = h.cost_mthd_code
															UNION
															SELECT      'CM_CUPD_CTL'
															FROM        cm_cupd_ctl a
															WHERE       a.calendar_code is not null
															AND         a.cost_mthd_Code is not null
															AND         a.calendar_code = g.calendar_code
															AND         a.cost_mthd_code = h.cost_mthd_code
															)
				AND           NOT EXISTS  (
																	SELECT     'X'
																	FROM        gmf_calendar_assignments x
																	WHERE       x.calendar_code = g.calendar_code
																	AND         x.cost_type_id = h.cost_type_id
																	AND         x.legal_entity_id = i.legal_entity_id
																	)
				 );

			EXCEPTION
				 WHEN OTHERS THEN

						/************************************************
						* Increment Failure Count for Failed Migrations *
						************************************************/

						x_failure_count := x_failure_count + 1;

						/**************************************
						* Migration DB Error Log Message      *
						**************************************/

						GMA_COMMON_LOGGING.gma_migration_central_log
						(
						p_run_id             =>       G_migration_run_id,
						p_log_level          =>       FND_LOG.LEVEL_ERROR,
						p_message_token      =>       'GMA_MIGRATION_DB_ERROR',
						p_table_name         =>       G_Table_name,
						p_context            =>       G_context,
						p_db_error           =>       SQLERRM,
						p_app_short_name     =>       'GMA'
						);

						/**************************************
						* Migration Failure Log Message       *
						**************************************/

						GMA_COMMON_LOGGING.gma_migration_central_log
						(
						p_run_id             =>       G_migration_run_id,
						p_log_level          =>       FND_LOG.LEVEL_ERROR,
						p_message_token      =>       'GMA_TABLE_MIGRATION_TABLE_FAIL',
						p_table_name         =>       G_Table_name,
						p_context            =>       G_context,
						p_db_error           =>       NULL,
						p_app_short_name     =>       'GMA'
						);
			END;

			/**********************************************************************
			* Insert a row in gmf_calendar_assignments for CM_RSRC_DTL table data *
			**********************************************************************/
			BEGIN

				 INSERT      INTO     gmf_calendar_assignments
				 (
				 ASSIGNMENT_ID,
				 CALENDAR_CODE,
				 LEGAL_ENTITY_ID,
				 COST_TYPE_ID,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN,
				 TEXT_CODE,
				 DELETE_MARK
				 )
				 (
				 SELECT       gmf_calendar_assignments_s.NEXTVAL,
											x.*
				 FROM         (
											SELECT        DISTINCT
																		g.calendar_code,
																		i.legal_entity_id,
																		h.cost_type_id,
																		g.creation_date,
																		g.created_by,
																		g.last_update_date,
																		g.last_updated_by,
																		g.last_update_login,
																		g.text_code,
																		1
											FROM          cm_cldr_hdr_b g,
																		cm_mthd_mst h,
																		gl_plcy_mst i,
																		sy_orgn_mst j,
																		cm_rsrc_dtl k
											WHERE         g.co_code IS NOT NULL
											AND           j.orgn_code = k.orgn_code
											AND           i.co_code = j.co_code
											AND           i.legal_entity_id IS NOT NULL
											AND           j.co_code <> g.co_code
											AND           h.cost_mthd_code = k.cost_mthd_code
											AND           g.calendar_code = k.calendar_code
											AND           NOT EXISTS  (
																								SELECT        'X'
																								FROM          gmf_calendar_assignments x
																								WHERE         x.calendar_code = g.calendar_code
																								AND           x.cost_type_id = h.cost_Type_id
																								AND           x.legal_entity_id = i.legal_Entity_id
																								)
											) x
				 );

			EXCEPTION
				 WHEN OTHERS THEN

						/************************************************
						* Increment Failure Count for Failed Migrations *
						************************************************/

						x_failure_count := x_failure_count + 1;

						/**************************************
						* Migration DB Error Log Message      *
						**************************************/

						GMA_COMMON_LOGGING.gma_migration_central_log
						(
						p_run_id             =>       G_migration_run_id,
						p_log_level          =>       FND_LOG.LEVEL_ERROR,
						p_message_token      =>       'GMA_MIGRATION_DB_ERROR',
						p_table_name         =>       G_Table_name,
						p_context            =>       G_context,
						p_db_error           =>       SQLERRM,
						p_app_short_name     =>       'GMA'
						);

						/**************************************
						* Migration Failure Log Message       *
						**************************************/

						GMA_COMMON_LOGGING.gma_migration_central_log
						(
						p_run_id             =>       G_migration_run_id,
						p_log_level          =>       FND_LOG.LEVEL_ERROR,
						p_message_token      =>       'GMA_TABLE_MIGRATION_TABLE_FAIL',
						p_table_name         =>       G_Table_name,
						p_context            =>       G_context,
						p_db_error           =>       NULL,
						p_app_short_name     =>       'GMA'
						);
			END;

			/**********************************************************************
			* Insert a row in gmf_calendar_assignments for CM_BRDN_DTL table data *
			**********************************************************************/
			BEGIN

				 INSERT      INTO     gmf_calendar_assignments
				 (
				 ASSIGNMENT_ID,
				 CALENDAR_CODE,
				 LEGAL_ENTITY_ID,
				 COST_TYPE_ID,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN,
				 TEXT_CODE,
				 DELETE_MARK
				 )
				 (
				 SELECT       gmf_calendar_assignments_s.NEXTVAL,
											x.*
				 FROM         (
											SELECT        DISTINCT
																		g.calendar_code,
																		i.legal_entity_id,
																		h.cost_type_id,
																		g.creation_date,
																		g.created_by,
																		g.last_update_date,
																		g.last_updated_by,
																		g.last_update_login,
																		g.text_code,
																		1
											FROM          cm_cldr_hdr_b g,
																		cm_mthd_mst h,
																		gl_plcy_mst i,
																		sy_orgn_mst j,
																		cm_brdn_dtl k
											WHERE         g.co_code IS NOT NULL
											AND           j.orgn_code = k.orgn_code
											AND           i.co_code = j.co_code
											AND           i.legal_entity_id IS NOT NULL
											AND           j.co_code <> g.co_code
											AND           h.cost_mthd_code = k.cost_mthd_code
											AND           g.calendar_code = k.calendar_code
											AND           NOT EXISTS  (
																								SELECT        'X'
																								FROM          gmf_calendar_assignments x
																								WHERE         x.calendar_code = g.calendar_code
																								AND           x.cost_type_id = h.cost_Type_id
																								AND           x.legal_entity_id = i.legal_Entity_id
																								)
											) x
				 );

			EXCEPTION
				 WHEN OTHERS THEN

						/************************************************
						* Increment Failure Count for Failed Migrations *
						************************************************/

						x_failure_count := x_failure_count + 1;

						/**************************************
						* Migration DB Error Log Message      *
						**************************************/

						GMA_COMMON_LOGGING.gma_migration_central_log
						(
						p_run_id             =>       G_migration_run_id,
						p_log_level          =>       FND_LOG.LEVEL_ERROR,
						p_message_token      =>       'GMA_MIGRATION_DB_ERROR',
						p_table_name         =>       G_Table_name,
						p_context            =>       G_context,
						p_db_error           =>       SQLERRM,
						p_app_short_name     =>       'GMA'
						);

						/**************************************
						* Migration Failure Log Message       *
						**************************************/

						GMA_COMMON_LOGGING.gma_migration_central_log
						(
						p_run_id             =>       G_migration_run_id,
						p_log_level          =>       FND_LOG.LEVEL_ERROR,
						p_message_token      =>       'GMA_TABLE_MIGRATION_TABLE_FAIL',
						p_table_name         =>       G_Table_name,
						p_context            =>       G_context,
						p_db_error           =>       NULL,
						p_app_short_name     =>       'GMA'
						);
			END;

			/**********************************************************************
			* Insert a row in gmf_calendar_assignments for CM_CMPT_DTL table data *
			**********************************************************************/
			BEGIN

				 INSERT      INTO     gmf_calendar_assignments
				 (
				 ASSIGNMENT_ID,
				 CALENDAR_CODE,
				 LEGAL_ENTITY_ID,
				 COST_TYPE_ID,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN,
				 TEXT_CODE,
				 DELETE_MARK
				 )
				 (
				 SELECT       gmf_calendar_assignments_s.NEXTVAL,
											x.*
				 FROM         (
											SELECT        DISTINCT
																		g.calendar_code,
																		i.legal_entity_id,
																		h.cost_type_id,
																		g.creation_date,
																		g.created_by,
																		g.last_update_date,
																		g.last_updated_by,
																		g.last_update_login,
																		g.text_code,
																		1
											FROM          cm_cldr_hdr_b g,
																		cm_mthd_mst h,
																		gl_plcy_mst i,
																		sy_orgn_mst j,
																		cm_cmpt_dtl k,
																		ic_whse_mst l
											WHERE         g.co_code IS NOT NULL
											AND           l.whse_code = k.whse_code
											AND           j.orgn_code = l.orgn_code
											AND           i.co_code = j.co_code
											AND           i.legal_entity_id IS NOT NULL
											AND           j.co_code <> g.co_code
											AND           h.cost_mthd_code = k.cost_mthd_code
											AND           g.calendar_code = k.calendar_code
											AND           NOT EXISTS  (
																								SELECT        'X'
																								FROM          gmf_calendar_assignments x
																								WHERE         x.calendar_code = g.calendar_code
																								AND           x.cost_type_id = h.cost_Type_id
																								AND           x.legal_entity_id = i.legal_Entity_id
																								)
											) x
				 );

			EXCEPTION
				 WHEN OTHERS THEN

						/************************************************
						* Increment Failure Count for Failed Migrations *
						************************************************/

						x_failure_count := x_failure_count + 1;

						/**************************************
						* Migration DB Error Log Message      *
						**************************************/

						GMA_COMMON_LOGGING.gma_migration_central_log
						(
						p_run_id             =>       G_migration_run_id,
						p_log_level          =>       FND_LOG.LEVEL_ERROR,
						p_message_token      =>       'GMA_MIGRATION_DB_ERROR',
						p_table_name         =>       G_Table_name,
						p_context            =>       G_context,
						p_db_error           =>       SQLERRM,
						p_app_short_name     =>       'GMA'
						);

						/**************************************
						* Migration Failure Log Message       *
						**************************************/

						GMA_COMMON_LOGGING.gma_migration_central_log
						(
						p_run_id             =>       G_migration_run_id,
						p_log_level          =>       FND_LOG.LEVEL_ERROR,
						p_message_token      =>       'GMA_TABLE_MIGRATION_TABLE_FAIL',
						p_table_name         =>       G_Table_name,
						p_context            =>       G_context,
						p_db_error           =>       NULL,
						p_app_short_name     =>       'GMA'
						);
			END;

			/**********************************************************************
			* Insert a row in gmf_calendar_assignments for CM_ADJS_DTL table data *
			**********************************************************************/
			BEGIN

				 INSERT      INTO     gmf_calendar_assignments
				 (
				 ASSIGNMENT_ID,
				 CALENDAR_CODE,
				 LEGAL_ENTITY_ID,
				 COST_TYPE_ID,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN,
				 TEXT_CODE,
				 DELETE_MARK
				 )
				 (
				 SELECT       gmf_calendar_assignments_s.NEXTVAL,
											x.*
				 FROM         (
											SELECT        DISTINCT
																		g.calendar_code,
																		i.legal_entity_id,
																		h.cost_type_id,
																		g.creation_date,
																		g.created_by,
																		g.last_update_date,
																		g.last_updated_by,
																		g.last_update_login,
																		g.text_code,
																		1
											FROM          cm_cldr_hdr_b g,
																		cm_mthd_mst h,
																		gl_plcy_mst i,
																		sy_orgn_mst j,
																		cm_adjs_dtl k,
																		ic_whse_mst l
											WHERE         g.co_code IS NOT NULL
											AND           l.whse_code = k.whse_code
											AND           j.orgn_code = l.orgn_code
											AND           i.co_code = j.co_code
											AND           i.legal_entity_id IS NOT NULL
											AND           j.co_code <> g.co_code
											AND           h.cost_mthd_code = k.cost_mthd_code
											AND           g.calendar_code = k.calendar_code
											AND           NOT EXISTS  (
																								SELECT        'X'
																								FROM          gmf_calendar_assignments x
																								WHERE         x.calendar_code = g.calendar_code
																								AND           x.cost_type_id = h.cost_Type_id
																								AND           x.legal_entity_id = i.legal_Entity_id
																								)
											) x
				 );

			EXCEPTION
				 WHEN OTHERS THEN

						/************************************************
						* Increment Failure Count for Failed Migrations *
						************************************************/

						x_failure_count := x_failure_count + 1;

						/**************************************
						* Migration DB Error Log Message      *
						**************************************/

						GMA_COMMON_LOGGING.gma_migration_central_log
						(
						p_run_id             =>       G_migration_run_id,
						p_log_level          =>       FND_LOG.LEVEL_ERROR,
						p_message_token      =>       'GMA_MIGRATION_DB_ERROR',
						p_table_name         =>       G_Table_name,
						p_context            =>       G_context,
						p_db_error           =>       SQLERRM,
						p_app_short_name     =>       'GMA'
						);

						/**************************************
						* Migration Failure Log Message       *
						**************************************/

						GMA_COMMON_LOGGING.gma_migration_central_log
						(
						p_run_id             =>       G_migration_run_id,
						p_log_level          =>       FND_LOG.LEVEL_ERROR,
						p_message_token      =>       'GMA_TABLE_MIGRATION_TABLE_FAIL',
						p_table_name         =>       G_Table_name,
						p_context            =>       G_context,
						p_db_error           =>       NULL,
						p_app_short_name     =>       'GMA'
						);
			END;

			FOR i IN cur_overlap_calendar loop
				UPDATE  GMF_CALENDAR_ASSIGNMENTS g
				SET     g.delete_mark = 1
				WHERE   g.delete_mark <> 1
				AND     EXISTS  (
												SELECT          'X'
												FROM            gmf_calendar_assignments a,
																				cm_cldr_dtl b
												WHERE           a.calendar_code = b.calendar_code
												AND             a.calendar_code = g.calendar_code
												AND             a.legal_entity_id = g.legal_entity_id
												AND             a.cost_Type_id = g.cost_type_id
												AND             EXISTS  (
																								SELECT 'X' FROM (
																																SELECT      m.legal_entity_id,
																																						m.cost_type_id,
																																						m.calendar_code,
																																						min(n.start_date) mindate,
																																						max(n.end_date) maxdate
																																FROM        gmf_calendar_assignments m,
																																						cm_cldr_dtl n
																																WHERE       m.calendar_code = n.calendar_code
																																AND         m.calendar_code = i.calendar_code
																																AND         m.legal_entity_id = i.legal_entity_id
																																AND         m.cost_type_id = i.cost_type_id
																																AND         m.delete_mark <> 1
																																GROUP by    m.legal_entity_id,
																																						m.calendar_code,
																																						m.cost_type_id
																																) x
																								WHERE   x.legal_entity_id = a.legal_entity_id
																								AND     x.cost_type_id = a.cost_Type_id
																								AND     x.calendar_code <> a.calendar_Code
																								AND     (
																												b.start_date BETWEEN x.mindate AND x.maxdate
																												OR
																												b.end_date BETWEEN x.mindate AND x.maxdate
																												)
																								)
													);
				END LOOP;

			/**************************************
			* Migration Success Log Message       *
			**************************************/

			GMA_COMMON_LOGGING.gma_migration_central_log
			(
			p_run_id             =>       G_migration_run_id,
			p_log_level          =>       FND_LOG.LEVEL_STATEMENT,
			p_message_token      =>       'GMA_MIGRATION_TABLE_SUCCESS',
			p_table_name         =>       G_Table_name,
			p_context            =>       G_context,
			p_param1             =>       1,
			p_param2             =>       0,
			p_db_error           =>       NULL,
			p_app_short_name     =>       'GMA'
			);

			G_Migration_run_id := P_migration_run_id;
			G_Table_name := 'GMF_PERIOD_STATUSES';
			G_Context := 'Cost Calendar Period Statuses Migration';

			/********************************
			* Migration Started Log Message *
			********************************/

			GMA_COMMON_LOGGING.gma_migration_central_log
			(
			p_run_id             =>       G_migration_run_id,
			p_log_level          =>       FND_LOG.LEVEL_STATEMENT,
			p_message_token      =>       'GMA_MIGRATION_TABLE_STARTED',
			p_table_name         =>       G_Table_name,
			p_context            =>       G_context,
			p_db_error           =>       NULL,
			p_app_short_name     =>       'GMA'
			);

			/*****************************************
			* Insert a row into gmf_period_statuses  *
			*****************************************/

			BEGIN

				 INSERT    INTO    gmf_period_statuses
				 (
				 PERIOD_ID,
				 LEGAL_ENTITY_ID,
				 COST_TYPE_ID,
				 CALENDAR_CODE,
				 PERIOD_CODE,
				 START_DATE,
				 END_DATE,
				 PERIOD_STATUS,
				 CREATION_DATE,
				 CREATED_BY,
				 LAST_UPDATE_DATE,
				 LAST_UPDATED_BY,
				 LAST_UPDATE_LOGIN,
				 TEXT_CODE,
				 DELETE_MARK
				 )
				 SELECT      gmf_period_id_s.NEXTVAL,
										 a.legal_entity_id,
										 a.cost_type_id,
										 a.calendar_code,
										 b.period_code,
										 b.start_date, /* Bug#5716122 ANTHIYAG 16-Dec-2006 */
										 b.end_date, /* Bug#5716122 ANTHIYAG 16-Dec-2006 */
										 decode(b.period_status, 0, 'O', 1, 'F', 2, 'C', 'O') period_status,
										 b.creation_date,
										 b.created_by,
										 b.last_update_date,
										 b.last_updated_by,
										 b.last_update_login,
										 b.text_code,
										 decode(a.delete_mark + b.delete_mark, 0, 0, 1)
				 FROM        gmf_calendar_assignments a,
										 cm_cldr_dtl b,
										 cm_cldr_hdr_b h
				 WHERE       a.calendar_code = b.calendar_code
				 AND         b.calendar_code = h.calendar_code
				 AND         h.co_code IS NOT NULL
				 AND         h.cost_mthd_code IS NOT NULL
				 AND         NOT EXISTS (
																SELECT   'X'
																FROM     gmf_period_statuses p
																WHERE    p.legal_entity_id = a.legal_entity_id
																AND      p.cost_type_id = a.cost_type_id
																AND      p.calendar_code = b.calendar_code
																AND      p.period_code = b.period_code
																);

				 UPDATE     gmf_period_statuses a
				 SET        a.delete_mark = 1
				 WHERE      EXISTS (
													 SELECT          'X'
													 FROM            gmf_calendar_assignments x
													 WHERE           x.legal_entity_id = a.legal_entity_id
													 AND             x.calendar_code = a.calendar_code
													 AND             x.cost_type_id = a.cost_type_id
													 AND             x.delete_mark = 1
													 );

			EXCEPTION
				 WHEN OTHERS THEN

						/************************************************
						* Increment Failure Count for Failed Migrations *
						************************************************/

						x_failure_count := x_failure_count + 1;

						/**************************************
						* Migration DB Error Log Message      *
						**************************************/

						GMA_COMMON_LOGGING.gma_migration_central_log
						(
						p_run_id             =>       G_migration_run_id,
						p_log_level          =>       FND_LOG.LEVEL_ERROR,
						p_message_token      =>       'GMA_MIGRATION_DB_ERROR',
						p_table_name         =>       G_Table_name,
						p_context            =>       G_context,
						p_db_error           =>       SQLERRM,
						p_app_short_name     =>       'GMA'
						);

						/**************************************
						* Migration Failure Log Message       *
						**************************************/

						GMA_COMMON_LOGGING.gma_migration_central_log
						(
						p_run_id             =>       G_migration_run_id,
						p_log_level          =>       FND_LOG.LEVEL_ERROR,
						p_message_token      =>       'GMA_TABLE_MIGRATION_TABLE_FAIL',
						p_table_name         =>       G_Table_name,
						p_context            =>       G_context,
						p_db_error           =>       NULL,
						p_app_short_name     =>       'GMA'
						);

			END;

			/**************************************
			* Migration Success Log Message       *
			**************************************/

			GMA_COMMON_LOGGING.gma_migration_central_log
			(
			p_run_id             =>       G_migration_run_id,
			p_log_level          =>       FND_LOG.LEVEL_STATEMENT,
			p_message_token      =>       'GMA_MIGRATION_TABLE_SUCCESS',
			p_table_name         =>       G_Table_name,
			p_context            =>       G_context,
			p_param1             =>       1,
			p_param2             =>       0,
			p_db_error           =>       NULL,
			p_app_short_name     =>       'GMA'
			);

			/****************************************************************
			* Lets save the changes now based on the commit parameter       *
			****************************************************************/

			IF NVL(p_commit,'~') = FND_API.G_TRUE THEN
				 COMMIT;
			END IF;

	 EXCEPTION
			WHEN OTHERS THEN

				 /************************************************
				 * Increment Failure Count for Failed Migrations *
				 ************************************************/

				 x_failure_count := x_failure_count + 1;

				 /**************************************
				 * Migration DB Error Log Message      *
				 **************************************/

				 GMA_COMMON_LOGGING.gma_migration_central_log
				 (
				 p_run_id             =>       G_migration_run_id,
				 p_log_level          =>       FND_LOG.LEVEL_ERROR,
				 p_message_token      =>       'GMA_MIGRATION_DB_ERROR',
				 p_table_name         =>       G_Table_name,
				 p_context            =>       G_context,
				 p_db_error           =>       SQLERRM,
				 p_app_short_name     =>       'GMA'
				 );

				 /**************************************
				 * Migration Failure Log Message       *
				 **************************************/

				 GMA_COMMON_LOGGING.gma_migration_central_log
				 (
				 p_run_id             =>       G_migration_run_id,
				 p_log_level          =>       FND_LOG.LEVEL_ERROR,
				 p_message_token      =>       'GMA_TABLE_MIGRATION_TABLE_FAIL',
				 p_table_name         =>       G_Table_name,
				 p_context            =>       G_context,
				 p_db_error           =>       NULL,
				 p_app_short_name     =>       'GMA'
				 );

	 END Migrate_Cost_Calendars;

	 /**********************************************************************
	 * PROCEDURE:                                                          *
	 *   Migrate_Burden_Percentages                                        *
	 *                                                                     *
	 * DESCRIPTION:                                                        *
	 *   This PL/SQL procedure is used to migrate the Burden Percentages   *
	 *                                                                     *
	 * PARAMETERS:                                                         *
	 *   P_migration_run_id - id to use to right to migration log          *
	 *   x_exception_count  - Number of exceptions occurred.               *
	 *                                                                     *
	 * SYNOPSIS:                                                           *
	 *   Migrate_Burden_Percentages(p_migartion_id    => l_migration_id,   *
	 *                    p_commit          => 'T',                        *
	 *                    x_exception_count => l_exception_count );        *
	 *                                                                     *
	 * HISTORY                                                             *
	 *       27-Apr-2005 Created  Anand Thiyagarajan                       *
	 *       05-Jul-2006 rseshadr bug 5374823 - call item mig inline for   *
	 *         the current table                                           *
	 *                                                                     *
	 **********************************************************************/
	 PROCEDURE Migrate_Burden_Percentages
	 (
	 P_migration_run_id      IN             NUMBER,
	 P_commit                IN             VARCHAR2,
	 X_failure_count         OUT   NOCOPY   NUMBER
	 )
	 IS

			/****************
			* PL/SQL Tables *
			****************/

			/******************
			* Local Variables *
			******************/

			l_inventory_item_id                 NUMBER;
			l_itm_failure_count                 NUMBER;
			l_itm_failure_count_all             NUMBER;

			/****************
			* Cursors       *
			****************/

			CURSOR            cur_get_gmf_items IS
			SELECT            DISTINCT item_id,
												organization_id
			FROM              (
												SELECT            a.item_id,
																					nvl(DECODE(NVL(c.subinventory_ind_flag,'N'), 'Y', c.organization_id, c.mtl_organization_id), DECODE(NVL(b.subinventory_ind_flag,'N'), 'Y', b.organization_id, b.mtl_organization_id)) organization_id
												FROM              gmf_burden_percentages a,
																					ic_whse_mst b,
																					ic_whse_mst c
												WHERE             a.item_id IS NOT NULL
												AND               b.orgn_code = a.orgn_code
												AND               c.whse_code(+) = a.whse_code
												);

	 BEGIN

			G_Migration_run_id := P_migration_run_id;
			G_Table_name := 'GMF_BURDEN_PERCENTAGES';
			G_Context := 'Burden Percentages Migration';
			X_failure_count := 0;

			/********************************
			* Migration Started Log Message *
			********************************/

			GMA_COMMON_LOGGING.gma_migration_central_log
			(
			p_run_id             =>       G_migration_run_id,
			p_log_level          =>       FND_LOG.LEVEL_STATEMENT,
			p_message_token      =>       'GMA_MIGRATION_TABLE_STARTED',
			p_table_name         =>       G_Table_name,
			p_context            =>       G_context,
			p_db_error           =>       NULL,
			p_app_short_name     =>       'GMA'
			);

			/********************************************
			* rseshadr bug 5374823                      *
			* Call Item Migration API in a loop         *
			* To Migrate necessary items for this table *
			*********************************************/

			FOR i IN cur_get_gmf_items
			LOOP
				IF i.item_id IS NOT NULL AND i.organization_id IS NOT NULL THEN
					inv_opm_item_migration.get_odm_item
					(
					p_migration_run_id        =>        p_migration_run_id,
					p_item_id                 =>        i.item_id,
					p_organization_id         =>        i.organization_id,
					p_mode                    =>        NULL,
					p_commit                  =>        FND_API.G_TRUE,
					x_inventory_item_id       =>        l_inventory_item_id,
					x_failure_count           =>        l_itm_failure_count
					);
				END IF;
				l_itm_failure_count_all := nvl(l_itm_failure_count_all,0) + nvl(l_itm_failure_count,0);
			END LOOP;

			/********************************************************
			* Update a row in GMF_BURDEN_PERCENTAGES                *
			********************************************************/

			BEGIN

				INSERT
				INTO        gmf_burden_percentages
				(
				burden_percentage_id,
				calendar_code,
				period_code,
				cost_mthd_code,
				burden_id,
				orgn_code,
				whse_code,
				item_id,
				percentage,
				created_by,
				creation_date,
				last_updated_by,
				last_update_date,
				last_update_login,
				delete_mark,
				gl_business_category_id,
				gl_category_id,
				cost_category_id,
				gl_prod_line_category_id
				)
				(
				SELECT      gmf_burden_percentage_id_s.NEXTVAL,
										a.calendar_code,
										a.period_code,
										a.cost_mthd_code,
										a.burden_id,
										a.orgn_code,
										e.whse_code,
										a.item_id,
										a.percentage,
										a.created_by,
										sysdate,
										a.last_updated_by,
										sysdate,
										a.last_update_login,
										a.delete_mark,
										a.gl_business_category_id,
										a.gl_category_id,
										a.cost_category_id,
										a.gl_prod_line_category_id
				FROM        gmf_burden_percentages a,
										ic_whse_mst e
				WHERE       a.orgn_code IS NOT NULL
				AND         a.whse_code IS NULL
				AND         a.orgn_code = e.orgn_code
				AND         e.mtl_organization_id IS NOT NULL
				AND         nvl(e.subinventory_ind_flag,'N') <> 'Y'
				AND         NOT EXISTS  (
																SELECT            'X'
																FROM              gmf_burden_percentages x
																WHERE             x.calendar_code = a.calendar_code
																AND               x.period_code = a.period_code
																AND               x.cost_mthd_code = a.cost_mthd_code
																AND               x.burden_id = a.burden_id
																AND               x.orgn_code = a.orgn_code
																AND               x.whse_code = e.whse_code
																AND               nvl(x.item_id, -1) = nvl(a.item_id, -1)
																AND               nvl(x.gl_category_id, -1) = nvl(a.gl_category_id, -1)
																AND               nvl(x.cost_category_id, -1) = nvl(a.cost_category_id, -1)
																AND               nvl(x.gl_business_category_id, -1) = nvl(a.gl_business_category_id, -1)
																AND               nvl(x.gl_prod_line_category_id, -1) = nvl(a.gl_prod_line_category_id, -1)
																)
				);

				UPDATE      gmf_burden_percentages a
				SET         (
										a.cost_type_id,
										a.period_id,
										a.legal_entity_id
										)
				=           (
										SELECT      x.cost_type_id,
																x.period_id,
																x.legal_entity_id
										FROM        gmf_period_statuses x,
																cm_mthd_mst y,
																cm_cldr_hdr_b z,
																gl_plcy_mst w
										WHERE       y.cost_mthd_code = a.cost_mthd_code
										AND         x.cost_type_id   = y.cost_type_id
										AND         x.calendar_code  = a.calendar_code
										AND         x.period_code    = a.period_code
										AND         z.calendar_code  = x.calendar_code
										AND         z.co_code        = w.co_code
										AND         x.legal_entity_id= w.legal_entity_id
										),
										(
										a.organization_id,
										a.delete_mark
										)
				=           (
										SELECT            DECODE(a.whse_code, null, DECODE(NVL(Y.INVENTORY_ORG_IND,'N'), 'Y', y.organization_id, NULL), DECODE(NVL(x.subinventory_ind_flag,'N'), 'Y', x.organization_id, x.mtl_organization_id)),
																			DECODE(a.delete_mark, 1, a.delete_mark, DECODE(a.whse_code, null, DECODE(NVL(Y.INVENTORY_ORG_IND,'N'), 'Y', 0, 1), DECODE(NVL(x.subinventory_ind_flag,'N'), 'Y', 1, 0)))
										FROM              ic_whse_mst x, sy_orgn_mst y
										WHERE             x.whse_code = nvl(a.whse_code, x.whse_code)
										and               y.orgn_code = DECODE(a.whse_code, NULL, a.orgn_code, x.orgn_code)
										AND               ROWNUM = 1
										)
				WHERE       (
										(a.cost_type_id IS NULL AND a.cost_mthd_code IS NOT NULL)
				OR          (a.calendar_code IS NOT NULL AND a.period_code IS NOT NULL AND a.period_id IS NULL)
				OR          (a.calendar_code IS NOT NULL AND a.legal_entity_id IS NULL)
				OR          (a.organization_id IS NULL AND (a.whse_code IS NOT NULL OR a.orgn_code IS NOT NULL))
										);

			EXCEPTION
				 WHEN OTHERS THEN

						/************************************************
						* Increment Failure Count for Failed Migrations *
						************************************************/

						x_failure_count := x_failure_count + 1;

						/**************************************
						* Migration DB Error Log Message      *
						**************************************/

						GMA_COMMON_LOGGING.gma_migration_central_log
						(
						p_run_id             =>       G_migration_run_id,
						p_log_level          =>       FND_LOG.LEVEL_ERROR,
						p_message_token      =>       'GMA_MIGRATION_DB_ERROR',
						p_table_name         =>       G_Table_name,
						p_context            =>       G_context,
						p_db_error           =>       SQLERRM,
						p_app_short_name     =>       'GMA'
						);

						/**************************************
						* Migration Failure Log Message       *
						**************************************/

						GMA_COMMON_LOGGING.gma_migration_central_log
						(
						p_run_id             =>       G_migration_run_id,
						p_log_level          =>       FND_LOG.LEVEL_ERROR,
						p_message_token      =>       'GMA_TABLE_MIGRATION_TABLE_FAIL',
						p_table_name         =>       G_Table_name,
						p_context            =>       G_context,
						p_db_error           =>       NULL,
						p_app_short_name     =>       'GMA'
						);

			END;

			BEGIN
				UPDATE      gmf_burden_percentages a
				SET         (
										a.master_organization_id,
										a.inventory_item_id
										)
				=           (
										SELECT            z.master_organization_id,
																			y.inventory_item_id
										FROM              ic_item_mst_b_mig y,
																			mtl_parameters z,
																			hr_organization_information hoi
										WHERE             y.item_id = a.item_id
										AND               y.organization_id = z.organization_id
										AND               hoi.organization_id = z.organization_id
										AND               hoi.org_information_context = 'Accounting Information'
										AND               hoi.org_information2 = a.legal_entity_id
										AND               ROWNUM = 1
										)
				WHERE       (a.inventory_item_id IS NULL AND a.item_id IS NOT NULL)
				OR          (a.master_organization_id IS NULL AND a.item_id IS NOT NULL);

				UPDATE      gmf_burden_percentages a
				SET         a.delete_mark = 1
				WHERE       ROWID NOT IN  (
																	SELECT  MIN(x.ROWID)
																	FROM    gmf_burden_percentages x
																	WHERE   x.legal_entity_id = a.legal_entity_id
																	AND     x.period_id = a.period_id
																	AND     x.cost_type_id = a.cost_type_id
																	AND     x.burden_id = a.burden_id
																	AND     nvl(x.inventory_item_id, -1) = nvl(a.inventory_item_id, -1)
																	AND     nvl(x.organization_id, -1) = nvl(a.organization_id, -1)
																	AND     nvl(x.gl_category_id, -1) = nvl(a.gl_category_id, -1)
																	AND     nvl(x.cost_category_id, -1) = nvl(a.cost_category_id, -1)
																	AND     nvl(x.gl_business_category_id, -1) = nvl(a.gl_business_category_id, -1)
																	AND     nvl(x.gl_prod_line_category_id, -1) = nvl(a.gl_prod_line_category_id, -1)
																	AND     x.delete_mark <> 1
																	);

			EXCEPTION
				WHEN OTHERS THEN

						/************************************************
						* Increment Failure Count for Failed Migrations *
						************************************************/

						x_failure_count := x_failure_count + 1;

						/**************************************
						* Migration DB Error Log Message      *
						**************************************/

						GMA_COMMON_LOGGING.gma_migration_central_log
						(
						p_run_id             =>       G_migration_run_id,
						p_log_level          =>       FND_LOG.LEVEL_ERROR,
						p_message_token      =>       'GMA_MIGRATION_DB_ERROR',
						p_table_name         =>       G_Table_name,
						p_context            =>       G_context,
						p_db_error           =>       SQLERRM,
						p_app_short_name     =>       'GMA'
						);

						/**************************************
						* Migration Failure Log Message       *
						**************************************/

						GMA_COMMON_LOGGING.gma_migration_central_log
						(
						p_run_id             =>       G_migration_run_id,
						p_log_level          =>       FND_LOG.LEVEL_ERROR,
						p_message_token      =>       'GMA_TABLE_MIGRATION_TABLE_FAIL',
						p_table_name         =>       G_Table_name,
						p_context            =>       G_context,
						p_db_error           =>       NULL,
						p_app_short_name     =>       'GMA'
						);

			END;

			/**********************************************
			* Handle all the rows which were not migrated *
			**********************************************/

			SELECT               count(*)
			INTO                 x_failure_count
			FROM                 gmf_burden_percentages
			WHERE                (
													 (cost_type_id IS NULL AND cost_mthd_code IS NOT NULL)
			OR                   (calendar_code IS NOT NULL AND period_code IS NOT NULL AND period_id IS NULL)
			OR                   (calendar_code IS NOT NULL AND legal_entity_id IS NULL)
			OR                   (organization_id IS NULL AND delete_mark = 0 AND (whse_code IS NOT NULL OR orgn_code IS NOT NULL))
			OR                   (inventory_item_id IS NULL AND item_id IS NOT NULL)
			OR                   (master_organization_id IS NULL AND item_id IS NOT NULL)
													 );

			IF nvl(x_failure_count,0) > 0 THEN

				/**************************************
				* Migration Failure Log Message       *
				**************************************/

				GMA_COMMON_LOGGING.gma_migration_central_log
				(
				p_run_id             =>       gmf_migration.G_migration_run_id,
				p_log_level          =>       FND_LOG.LEVEL_PROCEDURE,
				p_message_token      =>       'GMA_TABLE_MIGRATION_TABLE_FAIL',
				p_table_name         =>       gmf_migration.G_Table_name,
				p_context            =>       gmf_migration.G_context,
				p_db_error           =>       NULL,
				p_app_short_name     =>       'GMA'
				);

			ELSE

				/**************************************
				* Migration Success Log Message       *
				**************************************/

				GMA_COMMON_LOGGING.gma_migration_central_log
				(
				p_run_id             =>       G_migration_run_id,
				p_log_level          =>       FND_LOG.LEVEL_STATEMENT,
				p_message_token      =>       'GMA_MIGRATION_TABLE_SUCCESS',
				p_table_name         =>       G_Table_name,
				p_context            =>       G_Context,
				p_param1             =>       1,
				p_param2             =>       0,
				p_db_error           =>       NULL,
				p_app_short_name     =>       'GMA'
				);

			END IF;

			/****************************************************************
			* Lets save the changes now based on the commit parameter       *
			****************************************************************/

			IF NVL(p_commit,'~') = FND_API.G_TRUE THEN
				 COMMIT;
			END IF;

	 EXCEPTION
			WHEN OTHERS THEN

				 /************************************************
				 * Increment Failure Count for Failed Migrations *
				 ************************************************/

				 x_failure_count := x_failure_count + 1;

				 /**************************************
				 * Migration DB Error Log Message      *
				 **************************************/

				 GMA_COMMON_LOGGING.gma_migration_central_log
				 (
				 p_run_id             =>       G_migration_run_id,
				 p_log_level          =>       FND_LOG.LEVEL_ERROR,
				 p_message_token      =>       'GMA_MIGRATION_DB_ERROR',
				 p_table_name         =>       G_Table_name,
				 p_context            =>       G_context,
				 p_db_error           =>       SQLERRM,
				 p_app_short_name     =>       'GMA'
				 );

				 /**************************************
				 * Migration Failure Log Message       *
				 **************************************/

				 GMA_COMMON_LOGGING.gma_migration_central_log
				 (
				 p_run_id             =>       G_migration_run_id,
				 p_log_level          =>       FND_LOG.LEVEL_ERROR,
				 p_message_token      =>       'GMA_TABLE_MIGRATION_TABLE_FAIL',
				 p_table_name         =>       G_Table_name,
				 p_context            =>       G_context,
				 p_db_error           =>       NULL,
				 p_app_short_name     =>       'GMA'
				 );

	 END Migrate_Burden_Percentages;

	 /**********************************************************************
	 * PROCEDURE:                                                          *
	 *   Migrate_Lot_Costs                                                 *
	 *                                                                     *
	 * DESCRIPTION:                                                        *
	 *   This PL/SQL procedure is used to migrate the Lot Costs            *
	 *                                                                     *
	 * PARAMETERS:                                                         *
	 *   P_migration_run_id - id to use to right to migration log          *
	 *   x_exception_count  - Number of exceptions occurred.               *
	 *                                                                     *
	 * SYNOPSIS:                                                           *
	 *   Migrate_Lot_Costs(p_migartion_id    => l_migration_id,            *
	 *                    p_commit          => 'T',                        *
	 *                    x_exception_count => l_exception_count );        *
	 *                                                                     *
	 * HISTORY                                                             *
	 *       27-Apr-2005 Created  Anand Thiyagarajan                       *
   *       31-Oct-2006 Modified Anand Thiyagarajan                       *
   *          Modified Code to add insertion of Lot cost records for new *
   *          lots created by the Lot migration process for lot id's     *
	 *                                                                     *
	 **********************************************************************/
	 PROCEDURE Migrate_Lot_Costs
	 (
	 P_migration_run_id      IN             NUMBER,
	 P_commit                IN             VARCHAR2,
	 X_failure_count         OUT   NOCOPY   NUMBER
	 )
	 IS

			/**************************
			* PL/SQL Table Definition *
			**************************/

			/******************
			* Local Variables *
			******************/

	 BEGIN

			G_Migration_run_id := P_migration_run_id;
			G_Table_name := 'GMF_LOT_COSTS';
			G_Context := 'Lot Costs Migration';
			X_failure_count := 0;

			/********************************
			* Migration Started Log Message *
			********************************/

			GMA_COMMON_LOGGING.gma_migration_central_log
			(
			p_run_id             =>       G_migration_run_id,
			p_log_level          =>       FND_LOG.LEVEL_STATEMENT,
			p_message_token      =>       'GMA_MIGRATION_TABLE_STARTED',
			p_table_name         =>       G_Table_name,
			p_context            =>       G_context,
			p_db_error           =>       NULL,
			p_app_short_name     =>       'GMA'
			);

			BEGIN

				 /******************************
				 * Update a row for cost Types *
				 ******************************/

				 UPDATE      gmf_lot_costs a
				 SET         a.cost_type_id
				 =           (
										 SELECT      x.cost_Type_id
										 FROM        cm_mthd_mst x
										 WHERE       x.cost_mthd_code = a.cost_mthd_code
										 ),
										 (
										 a.organization_id,
										 a.inventory_item_id
										 )
				 =           (
										 SELECT      decode(x.cost_organization_id, -1, -1, y.organization_id),
																 y.inventory_item_id
										 FROM        ic_whse_mst x,
																 ic_item_mst_b_mig y
										 WHERE       x.whse_code = a.whse_code
										 AND         y.item_id = a.item_id
										 AND         y.organization_id = NVL(DECODE(x.cost_organization_id, -1, x.mtl_organization_id, x.cost_organization_id), x.mtl_organization_id)
										 )
				 WHERE       (
										 (a.cost_type_id IS NULL AND a.cost_mthd_code IS NOT NULL)
				 OR          (a.organization_id IS NULL AND a.whse_code IS NOT NULL)
				 OR          (a.inventory_item_id IS NULL AND a.item_id IS NOT NULL)
										 );

			EXCEPTION
				 WHEN OTHERS THEN

						/************************************************
						* Increment Failure Count for Failed Migrations *
						************************************************/

						x_failure_count := x_failure_count + 1;

						/**************************************
						* Migration DB Error Log Message      *
						**************************************/

						GMA_COMMON_LOGGING.gma_migration_central_log
						(
						p_run_id             =>       G_migration_run_id,
						p_log_level          =>       FND_LOG.LEVEL_ERROR,
						p_message_token      =>       'GMA_MIGRATION_DB_ERROR',
						p_table_name         =>       G_Table_name,
						p_context            =>       G_context,
						p_db_error           =>       SQLERRM,
						p_app_short_name     =>       'GMA'
						);

						/**************************************
						* Migration Failure Log Message       *
						**************************************/

						GMA_COMMON_LOGGING.gma_migration_central_log
						(
						p_run_id             =>       G_migration_run_id,
						p_log_level          =>       FND_LOG.LEVEL_ERROR,
						p_message_token      =>       'GMA_TABLE_MIGRATION_TABLE_FAIL',
						p_table_name         =>       G_Table_name,
						p_context            =>       G_context,
						p_db_error           =>       NULL,
						p_app_short_name     =>       'GMA'
						);

			END;

      BEGIN
         /****************************************************************************
         * Insert rows for Additional Lots Created as part of Lot Balances Migration *
         ****************************************************************************/
          INSERT INTO           gmf_lot_costs
          (
          header_id,
          unit_cost,
          cost_date,
          onhand_qty,
          frozen_ind,
          attribute1,
          attribute2,
          attribute3,
          attribute4,
          attribute5,
          attribute6,
          attribute7,
          attribute8,
          attribute9,
          attribute10,
          attribute11,
          attribute12,
          attribute13,
          attribute14,
          attribute15,
          attribute16,
          attribute17,
          attribute18,
          attribute19,
          attribute20,
          attribute21,
          attribute22,
          attribute23,
          attribute24,
          attribute25,
          attribute26,
          attribute27,
          attribute28,
          attribute29,
          attribute30,
          attribute_category,
          creation_date,
          created_by,
          last_update_date,
          last_updated_by,
          last_update_login,
          text_code,
          delete_mark,
          final_cost_flag,
          cost_type_id,
          inventory_item_id,
          lot_number,
          organization_id
          )
          (
          SELECT                gmf_cost_header_id_s.NEXTVAL,
                                a.unit_cost,
                                a.cost_date,
                                a.onhand_qty,
                                a.frozen_ind,
                                a.attribute1,
                                a.attribute2,
                                a.attribute3,
                                a.attribute4,
                                a.attribute5,
                                a.attribute6,
                                a.attribute7,
                                a.attribute8,
                                a.attribute9,
                                a.attribute10,
                                a.attribute11,
                                a.attribute12,
                                a.attribute13,
                                a.attribute14,
                                a.attribute15,
                                a.attribute16,
                                a.attribute17,
                                a.attribute18,
                                a.attribute19,
                                a.attribute20,
                                a.attribute21,
                                a.attribute22,
                                a.attribute23,
                                a.attribute24,
                                a.attribute25,
                                a.attribute26,
                                a.attribute27,
                                a.attribute28,
                                a.attribute29,
                                a.attribute30,
                                a.attribute_category,
                                sysdate,
                                a.created_by,
                                sysdate,
                                a.last_updated_by,
                                a.last_update_login,
                                a.header_id,
                                a.delete_mark,
                                a.final_cost_flag,
                                a.cost_type_id,
                                a.inventory_item_id,
                                b.lot_number,
                                a.organization_id
          FROM                  gmf_lot_costs a,
                                ic_lots_mst_mig b
          WHERE                 a.lot_id = b.lot_id
          AND                   nvl(b.additional_status_lot,0) = 1
          AND                   (
                                (a.cost_type_id IS NOT NULL AND a.cost_mthd_code IS NOT NULL)
          OR                    (a.organization_id IS NOT NULL AND a.whse_code IS NOT NULL)
          OR                    (a.inventory_item_id IS NOT NULL AND a.item_id IS NOT NULL)
          OR                    (a.lot_number IS NOT NULL AND a.lot_id IS NOT NULL)
                                )
          AND                   NOT EXISTS  (
                                            SELECT            'RECORD_ALREADY_EXISTS'
                                            FROM              gmf_lot_costs x
                                            WHERE             x.organization_id = a.organization_id
                                            AND               x.inventory_item_id = a.inventory_item_id
                                            AND               x.cost_type_id = a.cost_type_id
                                            AND               x.lot_number = b.lot_number
                                            AND               x.cost_date = a.cost_date
                                            )
          );
      EXCEPTION
         WHEN OTHERS THEN
            /************************************************
            * Increment Failure Count for Failed Migrations *
            ************************************************/
            x_failure_count := x_failure_count + 1;
            /**************************************
            * Migration DB Error Log Message      *
            **************************************/
            GMA_COMMON_LOGGING.gma_migration_central_log
            (
            p_run_id             =>       G_migration_run_id,
            p_log_level          =>       FND_LOG.LEVEL_ERROR,
            p_message_token      =>       'GMA_MIGRATION_DB_ERROR',
            p_table_name         =>       G_Table_name,
            p_context            =>       G_context,
            p_db_error           =>       SQLERRM,
            p_app_short_name     =>       'GMA'
            );
            /**************************************
            * Migration Failure Log Message       *
            **************************************/
            GMA_COMMON_LOGGING.gma_migration_central_log
            (
            p_run_id             =>       G_migration_run_id,
            p_log_level          =>       FND_LOG.LEVEL_ERROR,
            p_message_token      =>       'GMA_TABLE_MIGRATION_TABLE_FAIL',
            p_table_name         =>       G_Table_name,
            p_context            =>       G_context,
            p_db_error           =>       NULL,
            p_app_short_name     =>       'GMA'
            );
      END;

      BEGIN
        /****************************************************************************
        * Insert rows for Additional Lots Created as part of Lot Balances Migration *
        ****************************************************************************/
        INSERT  INTO                    gmf_lot_cost_details
        (
        header_id,
        detail_id,
        cost_cmpntcls_id,
        cost_analysis_code,
        cost_level,
        component_cost,
        burden_ind,
        cost_origin,
        frozen_ind,
        attribute1,
        attribute2,
        attribute3,
        attribute4,
        attribute5,
        attribute6,
        attribute7,
        attribute8,
        attribute9,
        attribute10,
        attribute11,
        attribute12,
        attribute13,
        attribute14,
        attribute15,
        attribute16,
        attribute17,
        attribute18,
        attribute19,
        attribute20,
        attribute21,
        attribute22,
        attribute23,
        attribute24,
        attribute25,
        attribute26,
        attribute27,
        attribute28,
        attribute29,
        attribute30,
        attribute_category,
        creation_date,
        created_by,
        last_update_date,
        last_updated_by,
        last_update_login,
        text_code,
        delete_mark,
        final_cost_flag
        )
        (
        SELECT                          b.header_id,
                                        gmf_cost_detail_id_s.NEXTVAL,
                                        a.cost_cmpntcls_id,
                                        a.cost_analysis_code,
                                        a.cost_level,
                                        a.component_cost,
                                        a.burden_ind,
                                        a.cost_origin,
                                        a.frozen_ind,
                                        a.attribute1,
                                        a.attribute2,
                                        a.attribute3,
                                        a.attribute4,
                                        a.attribute5,
                                        a.attribute6,
                                        a.attribute7,
                                        a.attribute8,
                                        a.attribute9,
                                        a.attribute10,
                                        a.attribute11,
                                        a.attribute12,
                                        a.attribute13,
                                        a.attribute14,
                                        a.attribute15,
                                        a.attribute16,
                                        a.attribute17,
                                        a.attribute18,
                                        a.attribute19,
                                        a.attribute20,
                                        a.attribute21,
                                        a.attribute22,
                                        a.attribute23,
                                        a.attribute24,
                                        a.attribute25,
                                        a.attribute26,
                                        a.attribute27,
                                        a.attribute28,
                                        a.attribute29,
                                        a.attribute30,
                                        a.attribute_category,
                                        SYSDATE,
                                        a.created_by,
                                        SYSDATE,
                                        a.last_updated_by,
                                        a.last_update_login,
                                        a.detail_id,
                                        a.delete_mark,
                                        a.final_cost_flag
        FROM                            gmf_lot_cost_details a,
                                        gmf_lot_costs b
        WHERE                           a.header_id = b.text_code
        AND                             b.text_code IS NOT NULL
        AND                             (
                                        (b.cost_type_id IS NOT NULL AND b.cost_mthd_code IS NULL)
        OR                              (b.organization_id IS NOT NULL AND b.whse_code IS NULL)
        OR                              (b.inventory_item_id IS NOT NULL AND b.item_id IS NULL)
        OR                              (b.lot_number IS NOT NULL AND b.lot_id IS NULL)
                                        )
        AND                             NOT EXISTS  (
                                                    SELECT            'RECORD_ALREADY_EXISTS'
                                                    FROM              gmf_lot_cost_details x
                                                    WHERE             b.header_id = x.header_id
                                                    )
        );
      EXCEPTION
         WHEN OTHERS THEN
            /************************************************
            * Increment Failure Count for Failed Migrations *
            ************************************************/
            x_failure_count := x_failure_count + 1;
            /**************************************
            * Migration DB Error Log Message      *
            **************************************/
            GMA_COMMON_LOGGING.gma_migration_central_log
            (
            p_run_id             =>       G_migration_run_id,
            p_log_level          =>       FND_LOG.LEVEL_ERROR,
            p_message_token      =>       'GMA_MIGRATION_DB_ERROR',
            p_table_name         =>       G_Table_name,
            p_context            =>       G_context,
            p_db_error           =>       SQLERRM,
            p_app_short_name     =>       'GMA'
            );
            /**************************************
            * Migration Failure Log Message       *
            **************************************/
            GMA_COMMON_LOGGING.gma_migration_central_log
            (
            p_run_id             =>       G_migration_run_id,
            p_log_level          =>       FND_LOG.LEVEL_ERROR,
            p_message_token      =>       'GMA_TABLE_MIGRATION_TABLE_FAIL',
            p_table_name         =>       G_Table_name,
            p_context            =>       G_context,
            p_db_error           =>       NULL,
            p_app_short_name     =>       'GMA'
            );
      END;

			/**********************************************
			* Handle all the rows which were not migrated *
			**********************************************/
			gmf_migration.Log_Errors  (
																p_log_level               =>          1,
																p_from_rowid              =>          NULL,
																p_to_rowid                =>          NULL
																);

			/****************************************************************
			* Lets save the changes now based on the commit parameter       *
			****************************************************************/

			IF NVL(p_commit,'~') = FND_API.G_TRUE THEN
				 COMMIT;
			END IF;

	 EXCEPTION
			WHEN OTHERS THEN

				 /************************************************
				 * Increment Failure Count for Failed Migrations *
				 ************************************************/

				 x_failure_count := x_failure_count + 1;

				 /**************************************
				 * Migration DB Error Log Message      *
				 **************************************/

				 GMA_COMMON_LOGGING.gma_migration_central_log
				 (
				 p_run_id             =>       G_migration_run_id,
				 p_log_level          =>       FND_LOG.LEVEL_ERROR,
				 p_message_token      =>       'GMA_MIGRATION_DB_ERROR',
				 p_table_name         =>       G_Table_name,
				 p_context            =>       G_context,
				 p_db_error           =>       SQLERRM,
				 p_app_short_name     =>       'GMA'
				 );

				 /**************************************
				 * Migration Failure Log Message       *
				 **************************************/

				 GMA_COMMON_LOGGING.gma_migration_central_log
				 (
				 p_run_id             =>       G_migration_run_id,
				 p_log_level          =>       FND_LOG.LEVEL_ERROR,
				 p_message_token      =>       'GMA_TABLE_MIGRATION_TABLE_FAIL',
				 p_table_name         =>       G_Table_name,
				 p_context            =>       G_context,
				 p_db_error           =>       NULL,
				 p_app_short_name     =>       'GMA'
				 );

	 END Migrate_Lot_Costs;

	 /**********************************************************************
	 * PROCEDURE:                                                          *
	 *   Migrate_Lot_Costed_Items                                          *
	 *                                                                     *
	 * DESCRIPTION:                                                        *
	 *   This PL/SQL procedure is used to migrate the Lot Costed Items     *
	 *                                                                     *
	 * PARAMETERS:                                                         *
	 *   P_migration_run_id - id to use to right to migration log          *
	 *   x_exception_count  - Number of exceptions occurred.               *
	 *                                                                     *
	 * SYNOPSIS:                                                           *
	 *   Migrate_Lot_Costed_Items(p_migartion_id    => l_migration_id,     *
	 *                    p_commit          => 'T',                        *
	 *                    x_exception_count => l_exception_count );        *
	 *                                                                     *
	 * HISTORY                                                             *
	 *       27-Apr-2005 Created  Anand Thiyagarajan                       *
	 *                                                                     *
	 **********************************************************************/
	 PROCEDURE Migrate_Lot_Costed_Items
	 (
	 P_migration_run_id      IN             NUMBER,
	 P_commit                IN             VARCHAR2,
	 X_failure_count         OUT   NOCOPY   NUMBER
	 )
	 IS

			/**************************
			* PL/SQL Table Definition *
			**************************/

			/******************
			* Local Variables *
			******************/

	 BEGIN

			G_Migration_run_id := P_migration_run_id;
			G_Table_name := 'GMF_LOT_COSTED_ITEMS';
			G_Context := 'Lot Costed Items Migration';
			X_failure_count := 0;

			/********************************
			* Migration Started Log Message *
			********************************/

			GMA_COMMON_LOGGING.gma_migration_central_log
			(
			p_run_id             =>       G_migration_run_id,
			p_log_level          =>       FND_LOG.LEVEL_STATEMENT,
			p_message_token      =>       'GMA_MIGRATION_TABLE_STARTED',
			p_table_name         =>       G_Table_name,
			p_context            =>       G_context,
			p_db_error           =>       NULL,
			p_app_short_name     =>       'GMA'
			);

			BEGIN

				 /***************************************************************
				 * Update a row for cost Types, LE, Organization Id and Item Id *
				 ***************************************************************/

				 UPDATE      gmf_lot_costed_items a
				 SET         a.cost_type_id
				 =           (
										 SELECT      x.cost_Type_id
										 FROM        cm_mthd_mst x
										 WHERE       x.cost_mthd_code = a.cost_mthd_code
										 ),
										 a.legal_entity_id
				 =           (
										 SELECT            x.legal_entity_id
										 FROM              gl_plcy_mst x
										 WHERE             x.co_code = a.co_code
										 )
				 WHERE       (a.cost_type_id IS NULL AND a.cost_mthd_code IS NOT NULL)
										 OR (a.legal_entity_id IS NULL AND a.co_code IS NOT NULL);

			EXCEPTION
				 WHEN OTHERS THEN

						/************************************************
						* Increment Failure Count for Failed Migrations *
						************************************************/

						x_failure_count := x_failure_count + 1;

						/**************************************
						* Migration DB Error Log Message      *
						**************************************/

						GMA_COMMON_LOGGING.gma_migration_central_log
						(
						p_run_id             =>       G_migration_run_id,
						p_log_level          =>       FND_LOG.LEVEL_ERROR,
						p_message_token      =>       'GMA_MIGRATION_DB_ERROR',
						p_table_name         =>       G_Table_name,
						p_context            =>       G_context,
						p_db_error           =>       SQLERRM,
						p_app_short_name     =>       'GMA'
						);

						/**************************************
						* Migration Failure Log Message       *
						**************************************/

						GMA_COMMON_LOGGING.gma_migration_central_log
						(
						p_run_id             =>       G_migration_run_id,
						p_log_level          =>       FND_LOG.LEVEL_ERROR,
						p_message_token      =>       'GMA_TABLE_MIGRATION_TABLE_FAIL',
						p_table_name         =>       G_Table_name,
						p_context            =>       G_context,
						p_db_error           =>       NULL,
						p_app_short_name     =>       'GMA'
						);

			END;

			BEGIN

				 /***************************************************************
				 * Update a row for Master_Organization Id and Item Id          *
				 ***************************************************************/

				 UPDATE      gmf_lot_costed_items a
				 SET         (
										 a.master_organization_id,
										 a.inventory_item_id
										 )
				 =
										 (
										 SELECT         z.master_organization_id,
																		y.inventory_item_id
										 FROM           ic_item_mst_b_mig y,
																		mtl_parameters z,
																		hr_organization_information hoi
										 WHERE          y.item_id = a.item_id
										 AND            y.organization_id = z.organization_id
										 AND            hoi.organization_id = z.organization_id
										 AND            hoi.org_information_context = 'Accounting Information'
										 AND            hoi.org_information2 = a.legal_entity_id
										 AND            ROWNUM = 1
										 )
				 WHERE       (a.inventory_item_id IS NULL AND a.item_id IS NOT NULL)
				 OR          (a.master_organization_id IS NULL AND a.item_id IS NOT NULL);

			EXCEPTION
				 WHEN OTHERS THEN

						/************************************************
						* Increment Failure Count for Failed Migrations *
						************************************************/

						x_failure_count := x_failure_count + 1;

						/**************************************
						* Migration DB Error Log Message      *
						**************************************/

						GMA_COMMON_LOGGING.gma_migration_central_log
						(
						p_run_id             =>       G_migration_run_id,
						p_log_level          =>       FND_LOG.LEVEL_ERROR,
						p_message_token      =>       'GMA_MIGRATION_DB_ERROR',
						p_table_name         =>       G_Table_name,
						p_context            =>       G_context,
						p_db_error           =>       SQLERRM,
						p_app_short_name     =>       'GMA'
						);

						/**************************************
						* Migration Failure Log Message       *
						**************************************/

						GMA_COMMON_LOGGING.gma_migration_central_log
						(
						p_run_id             =>       G_migration_run_id,
						p_log_level          =>       FND_LOG.LEVEL_ERROR,
						p_message_token      =>       'GMA_TABLE_MIGRATION_TABLE_FAIL',
						p_table_name         =>       G_Table_name,
						p_context            =>       G_context,
						p_db_error           =>       NULL,
						p_app_short_name     =>       'GMA'
						);

			END;

			/**********************************************
			* Handle all the rows which were not migrated *
			**********************************************/
			gmf_migration.Log_Errors  (
																p_log_level               =>          1,
																p_from_rowid              =>          NULL,
																p_to_rowid                =>          NULL
																);

			/****************************************************************
			* Lets save the changes now based on the commit parameter       *
			****************************************************************/

			IF NVL(p_commit,'~') = FND_API.G_TRUE THEN
				 COMMIT;
			END IF;

	 EXCEPTION
			WHEN OTHERS THEN

				 /************************************************
				 * Increment Failure Count for Failed Migrations *
				 ************************************************/

				 x_failure_count := x_failure_count + 1;

				 /**************************************
				 * Migration DB Error Log Message      *
				 **************************************/

				 GMA_COMMON_LOGGING.gma_migration_central_log
				 (
				 p_run_id             =>       G_migration_run_id,
				 p_log_level          =>       FND_LOG.LEVEL_ERROR,
				 p_message_token      =>       'GMA_MIGRATION_DB_ERROR',
				 p_table_name         =>       G_Table_name,
				 p_context            =>       G_context,
				 p_db_error           =>       SQLERRM,
				 p_app_short_name     =>       'GMA'
				 );

				 /**************************************
				 * Migration Failure Log Message       *
				 **************************************/

				 GMA_COMMON_LOGGING.gma_migration_central_log
				 (
				 p_run_id             =>       G_migration_run_id,
				 p_log_level          =>       FND_LOG.LEVEL_ERROR,
				 p_message_token      =>       'GMA_TABLE_MIGRATION_TABLE_FAIL',
				 p_table_name         =>       G_Table_name,
				 p_context            =>       G_context,
				 p_db_error           =>       NULL,
				 p_app_short_name     =>       'GMA'
				 );

	 END Migrate_Lot_Costed_Items;

	 /**********************************************************************
	 * PROCEDURE:                                                          *
	 *   Migrate_Lot_Cost_Adjustments                                      *
	 *                                                                     *
	 * DESCRIPTION:                                                        *
	 *   This PL/SQL procedure is used to migrate the Lot Cost Adjustments *
	 *                                                                     *
	 * PARAMETERS:                                                         *
	 *   P_migration_run_id - id to use to right to migration log          *
	 *   x_exception_count  - Number of exceptions occurred.               *
	 *                                                                     *
	 * SYNOPSIS:                                                           *
	 *   Migrate_Lot_Cost_adjustments(p_migartion_id    => l_migration_id, *
	 *                    p_commit          => 'T',                        *
	 *                    x_exception_count => l_exception_count );        *
	 *                                                                     *
	 * HISTORY                                                             *
	 *       27-Apr-2005 Created  Anand Thiyagarajan                       *
	 *                                                                     *
	 **********************************************************************/
	 PROCEDURE Migrate_Lot_Cost_Adjustments
	 (
	 P_migration_run_id      IN             NUMBER,
	 P_commit                IN             VARCHAR2,
	 X_failure_count         OUT   NOCOPY   NUMBER
	 )
	 IS

			/**************************
			* PL/SQL Table Definition *
			**************************/

			/******************
			* Local Variables *
			******************/

	 BEGIN

			G_Migration_run_id := P_migration_run_id;
			G_Table_name := 'GMF_LOT_COST_ADJUSTMENTS';
			G_Context := 'Lot Cost Adjustments Migration';
			X_failure_count := 0;

			/********************************
			* Migration Started Log Message *
			********************************/

			GMA_COMMON_LOGGING.gma_migration_central_log
			(
			p_run_id             =>       G_migration_run_id,
			p_log_level          =>       FND_LOG.LEVEL_STATEMENT,
			p_message_token      =>       'GMA_MIGRATION_TABLE_STARTED',
			p_table_name         =>       G_Table_name,
			p_context            =>       G_context,
			p_db_error           =>       NULL,
			p_app_short_name     =>       'GMA'
			);

			BEGIN

				 /**********************************************************
				 * Update a row in GMF_LOT_COST_ADJUSTMENTS for cost Types *
				 **********************************************************/

				 UPDATE      gmf_lot_cost_adjustments a
				 SET         a.cost_type_id
				 =           (
										 SELECT      x.cost_Type_id
										 FROM        cm_mthd_mst x
										 WHERE       x.cost_mthd_code = a.cost_mthd_code
										 ),
										 a.legal_entity_id
				 =           (
										 SELECT            x.legal_entity_id
										 FROM              gl_plcy_mst x
										 WHERE             x.co_code = a.co_code
										 ),
										 (
										 a.organization_id,
										 a.inventory_item_id
										 )
				 =           (
										 SELECT      decode(x.cost_organization_id, -1, -1, y.organization_id),
																 y.inventory_item_id
										 FROM        ic_whse_mst x,
																 ic_item_mst_b_mig y
										 WHERE       x.whse_code = a.whse_code
										 AND         y.item_id = a.item_id
										 AND         y.organization_id = NVL(DECODE(x.cost_organization_id, -1, x.mtl_organization_id, x.cost_organization_id), x.mtl_organization_id)
										 )
				 WHERE       (
										 (a.cost_type_id IS NULL AND a.cost_mthd_code IS NOT NULL)
				 OR          (a.organization_id IS NULL AND a.whse_code IS NOT NULL)
				 OR          (a.inventory_item_id IS NULL AND a.item_id IS NOT NULL)
				 OR          (a.legal_entity_id IS NULL AND a.co_code IS NOT NULL)
										 );

			EXCEPTION
				 WHEN OTHERS THEN

						/************************************************
						* Increment Failure Count for Failed Migrations *
						************************************************/

						x_failure_count := x_failure_count + 1;

						/**************************************
						* Migration DB Error Log Message      *
						**************************************/

						GMA_COMMON_LOGGING.gma_migration_central_log
						(
						p_run_id             =>       G_migration_run_id,
						p_log_level          =>       FND_LOG.LEVEL_ERROR,
						p_message_token      =>       'GMA_MIGRATION_DB_ERROR',
						p_table_name         =>       G_Table_name,
						p_context            =>       G_context,
						p_db_error           =>       SQLERRM,
						p_app_short_name     =>       'GMA'
						);

						/**************************************
						* Migration Failure Log Message       *
						**************************************/

						GMA_COMMON_LOGGING.gma_migration_central_log
						(
						p_run_id             =>       G_migration_run_id,
						p_log_level          =>       FND_LOG.LEVEL_ERROR,
						p_message_token      =>       'GMA_TABLE_MIGRATION_TABLE_FAIL',
						p_table_name         =>       G_Table_name,
						p_context            =>       G_context,
						p_db_error           =>       NULL,
						p_app_short_name     =>       'GMA'
						);

			END;

      BEGIN
        /****************************************************************************
        * Insert rows for Additional Lots Created as part of Lot Balances Migration *
        ****************************************************************************/
        INSERT INTO             gmf_lot_cost_adjustments
        (
        adjustment_id,
        adjustment_date,
        reason_code,
        applied_ind,
        gl_posted_ind,
        delete_mark,
        text_code,
        created_by,
        creation_date,
        last_updated_by,
        last_update_login,
        last_update_date,
        attribute1,
        attribute2,
        attribute3,
        attribute4,
        attribute5,
        attribute6,
        attribute7,
        attribute8,
        attribute9,
        attribute10,
        attribute11,
        attribute12,
        attribute13,
        attribute14,
        attribute15,
        attribute16,
        attribute17,
        attribute18,
        attribute19,
        attribute20,
        attribute21,
        attribute22,
        attribute23,
        attribute24,
        attribute25,
        attribute26,
        attribute27,
        attribute28,
        attribute29,
        attribute30,
        attribute_category,
        onhand_qty,
        cost_type_id,
        inventory_item_id,
        legal_entity_id,
        lot_number,
        organization_id
        )
        (
        SELECT               gmf_lot_cost_adjs_id_s.NEXTVAL,
                             a.adjustment_date,
                             a.reason_code,
                             a.applied_ind,
                             a.gl_posted_ind,
                             a.delete_mark,
                             a.adjustment_id,
                             a.created_by,
                             SYSDATE,
                             a.last_updated_by,
                             a.last_update_login,
                             SYSDATE,
                             a.attribute1,
                             a.attribute2,
                             a.attribute3,
                             a.attribute4,
                             a.attribute5,
                             a.attribute6,
                             a.attribute7,
                             a.attribute8,
                             a.attribute9,
                             a.attribute10,
                             a.attribute11,
                             a.attribute12,
                             a.attribute13,
                             a.attribute14,
                             a.attribute15,
                             a.attribute16,
                             a.attribute17,
                             a.attribute18,
                             a.attribute19,
                             a.attribute20,
                             a.attribute21,
                             a.attribute22,
                             a.attribute23,
                             a.attribute24,
                             a.attribute25,
                             a.attribute26,
                             a.attribute27,
                             a.attribute28,
                             a.attribute29,
                             a.attribute30,
                             a.attribute_category,
                             a.onhand_qty,
                             a.cost_type_id,
                             a.inventory_item_id,
                             a.legal_entity_id,
                             b.lot_number,
                             a.organization_id
        FROM                 gmf_lot_cost_adjustments a,
                             ic_lots_mst_mig b
        WHERE                a.lot_id = b.lot_id
        AND                  nvl(b.additional_status_lot,0) = 1
        AND                  (
                             (a.cost_type_id IS NOT NULL AND a.cost_mthd_code IS NOT NULL)
        OR                   (a.organization_id IS NOT NULL AND a.whse_code IS NOT NULL)
        OR                   (a.inventory_item_id IS NOT NULL AND a.item_id IS NOT NULL)
        OR                   (a.legal_entity_id IS NOT NULL AND a.co_code IS NOT NULL)
                             )
        AND                  NOT EXISTS  (
                                         SELECT            'RECORD_ALREADY_EXISTS'
                                         FROM              gmf_lot_cost_adjustments x
                                         WHERE             x.legal_entity_id = a.legal_entity_id
                                         AND               x.organization_id = a.organization_id
                                         AND               x.inventory_item_id = a.inventory_item_id
                                         AND               x.cost_type_id = a.cost_type_id
                                         AND               x.lot_number = b.lot_number
                                         AND               x.adjustment_date = a.adjustment_date
                                         )
        );
      EXCEPTION
         WHEN OTHERS THEN
            /************************************************
            * Increment Failure Count for Failed Migrations *
            ************************************************/
            x_failure_count := x_failure_count + 1;
            /**************************************
            * Migration DB Error Log Message      *
            **************************************/
            GMA_COMMON_LOGGING.gma_migration_central_log
            (
            p_run_id             =>       G_migration_run_id,
            p_log_level          =>       FND_LOG.LEVEL_ERROR,
            p_message_token      =>       'GMA_MIGRATION_DB_ERROR',
            p_table_name         =>       G_Table_name,
            p_context            =>       G_context,
            p_db_error           =>       SQLERRM,
            p_app_short_name     =>       'GMA'
            );
            /**************************************
            * Migration Failure Log Message       *
            **************************************/
            GMA_COMMON_LOGGING.gma_migration_central_log
            (
            p_run_id             =>       G_migration_run_id,
            p_log_level          =>       FND_LOG.LEVEL_ERROR,
            p_message_token      =>       'GMA_TABLE_MIGRATION_TABLE_FAIL',
            p_table_name         =>       G_Table_name,
            p_context            =>       G_context,
            p_db_error           =>       NULL,
            p_app_short_name     =>       'GMA'
            );
      END;

      BEGIN
        /****************************************************************************
        * Insert rows for Additional Lots Created as part of Lot Balances Migration *
        ****************************************************************************/
        INSERT  INTO                    gmf_lot_cost_adjustment_dtls
        (
        adjustment_dtl_id,
        adjustment_id,
        cost_cmpntcls_id,
        cost_analysis_code,
        adjustment_cost,
        delete_mark,
        text_code,
        created_by,
        creation_date,
        last_updated_by,
        last_update_login,
        last_update_date
        )
        (
        SELECT                          gmf_lot_cost_adjs_dtl_id_s.NEXTVAL,
                                        b.adjustment_id,
                                        a.cost_cmpntcls_id,
                                        a.cost_analysis_code,
                                        a.adjustment_cost,
                                        a.delete_mark,
                                        a.adjustment_dtl_id,
                                        a.created_by,
                                        SYSDATE,
                                        a.last_updated_by,
                                        a.last_update_login,
                                        SYSDATE
        FROM                            gmf_lot_cost_adjustment_dtls a,
                                        gmf_lot_cost_adjustments b
        WHERE                           a.adjustment_id = b.text_code
        AND                             b.text_code IS NOT NULL
        AND                             (
                                        (b.cost_type_id IS NOT NULL AND b.cost_mthd_code IS NULL)
        OR                              (b.organization_id IS NOT NULL AND b.whse_code IS NULL)
        OR                              (b.inventory_item_id IS NOT NULL AND b.item_id IS NULL)
        OR                              (b.legal_entity_id IS NOT NULL AND b.co_code IS NULL)
                                        )
        AND                             NOT EXISTS  (
                                                    SELECT            'RECORD_ALREADY_EXISTS'
                                                    FROM              gmf_lot_cost_adjustment_dtls x
                                                    WHERE             b.adjustment_id = x.adjustment_id
                                                    )
        );
      EXCEPTION
        WHEN OTHERS THEN
           /************************************************
           * Increment Failure Count for Failed Migrations *
           ************************************************/
           x_failure_count := x_failure_count + 1;
           /**************************************
           * Migration DB Error Log Message      *
           **************************************/
           GMA_COMMON_LOGGING.gma_migration_central_log
           (
           p_run_id             =>       G_migration_run_id,
           p_log_level          =>       FND_LOG.LEVEL_ERROR,
           p_message_token      =>       'GMA_MIGRATION_DB_ERROR',
           p_table_name         =>       G_Table_name,
           p_context            =>       G_context,
           p_db_error           =>       SQLERRM,
           p_app_short_name     =>       'GMA'
           );
           /**************************************
           * Migration Failure Log Message       *
           **************************************/
           GMA_COMMON_LOGGING.gma_migration_central_log
           (
           p_run_id             =>       G_migration_run_id,
           p_log_level          =>       FND_LOG.LEVEL_ERROR,
           p_message_token      =>       'GMA_TABLE_MIGRATION_TABLE_FAIL',
           p_table_name         =>       G_Table_name,
           p_context            =>       G_context,
           p_db_error           =>       NULL,
           p_app_short_name     =>       'GMA'
           );
      END;

			/**********************************************
			* Handle all the rows which were not migrated *
			**********************************************/
			gmf_migration.Log_Errors  (
																p_log_level               =>          1,
																p_from_rowid              =>          NULL,
																p_to_rowid                =>          NULL
																);

			/****************************************************************
			* Lets save the changes now based on the commit parameter       *
			****************************************************************/

			IF NVL(p_commit,'~') = FND_API.G_TRUE THEN
				 COMMIT;
			END IF;

	 EXCEPTION
			WHEN OTHERS THEN

				 /************************************************
				 * Increment Failure Count for Failed Migrations *
				 ************************************************/

				 x_failure_count := x_failure_count + 1;

				 /**************************************
				 * Migration DB Error Log Message      *
				 **************************************/

				 GMA_COMMON_LOGGING.gma_migration_central_log
				 (
				 p_run_id             =>       G_migration_run_id,
				 p_log_level          =>       FND_LOG.LEVEL_ERROR,
				 p_message_token      =>       'GMA_MIGRATION_DB_ERROR',
				 p_table_name         =>       G_Table_name,
				 p_context            =>       G_context,
				 p_db_error           =>       SQLERRM,
				 p_app_short_name     =>       'GMA'
				 );

				 /**************************************
				 * Migration Failure Log Message       *
				 **************************************/

				 GMA_COMMON_LOGGING.gma_migration_central_log
				 (
				 p_run_id             =>       G_migration_run_id,
				 p_log_level          =>       FND_LOG.LEVEL_ERROR,
				 p_message_token      =>       'GMA_TABLE_MIGRATION_TABLE_FAIL',
				 p_table_name         =>       G_Table_name,
				 p_context            =>       G_context,
				 p_db_error           =>       NULL,
				 p_app_short_name     =>       'GMA'
				 );

	 END Migrate_Lot_Cost_Adjustments;

	 /**********************************************************************
	 * PROCEDURE:                                                          *
	 *   Migrate_Material_Lot_Cost_Txns                                    *
	 *                                                                     *
	 * DESCRIPTION:                                                        *
	 *   This PL/SQL procedure is used to migrate the Lot Cost Adjustments *
	 *                                                                     *
	 * PARAMETERS:                                                         *
	 *   P_migration_run_id - id to use to right to migration log          *
	 *   x_exception_count  - Number of exceptions occurred.               *
	 *                                                                     *
	 * SYNOPSIS:                                                           *
	 *   Migrate_Material_Lot_Cost_Txns(p_migartion_id  => l_migration_id, *
	 *                    p_commit          => 'T',                        *
	 *                    x_exception_count => l_exception_count );        *
	 *                                                                     *
	 * HISTORY                                                             *
	 *       27-Apr-2005 Created  Anand Thiyagarajan                       *
	 *                                                                     *
	 **********************************************************************/
	 PROCEDURE Migrate_Material_Lot_Cost_Txns
	 (
	 P_migration_run_id      IN             NUMBER,
	 P_commit                IN             VARCHAR2,
	 X_failure_count         OUT   NOCOPY   NUMBER
	 )
	 IS

			/**************************
			* PL/SQL Table Definition *
			**************************/

			/******************
			* Local Variables *
			******************/

	 BEGIN

			G_Migration_run_id := P_migration_run_id;
			G_Table_name := 'GMF_MATERIAL_LOT_COST_TXNS';
			G_Context := 'Material Lot Cost Transactions Migration';
			X_failure_count := 0;

			/********************************
			* Migration Started Log Message *
			********************************/

			GMA_COMMON_LOGGING.gma_migration_central_log
			(
			p_run_id             =>       G_migration_run_id,
			p_log_level          =>       FND_LOG.LEVEL_STATEMENT,
			p_message_token      =>       'GMA_MIGRATION_TABLE_STARTED',
			p_table_name         =>       G_Table_name,
			p_context            =>       G_context,
			p_db_error           =>       NULL,
			p_app_short_name     =>       'GMA'
			);

			BEGIN

				 /**********************************************************
				 * Update a row in GMF_MATERIAL_LOT_COST_TXNS for cost Types *
				 **********************************************************/

				 UPDATE      gmf_material_lot_cost_txns a
				 SET         a.cost_type_id =  (
																			 SELECT      x.cost_Type_id
																			 FROM        cm_mthd_mst x
																			 WHERE       x.cost_mthd_code = a.cost_type_code
																			 ),
										 a.cost_trans_um = (
																			 SELECT      x.uom_Code
																			 FROM        sy_uoms_mst x
																			 WHERE       x.um_code = a.cost_trans_uom
																			 )
				 WHERE       (
										 (a.cost_type_id IS NULL AND a.cost_type_code IS NOT NULL)
				 OR          (a.cost_trans_um IS NULL AND a.cost_trans_uom IS NOT NULL)
										 );

			EXCEPTION
				 WHEN OTHERS THEN

						/************************************************
						* Increment Failure Count for Failed Migrations *
						************************************************/

						x_failure_count := x_failure_count + 1;

						/**************************************
						* Migration DB Error Log Message      *
						**************************************/

						GMA_COMMON_LOGGING.gma_migration_central_log
						(
						p_run_id             =>       G_migration_run_id,
						p_log_level          =>       FND_LOG.LEVEL_ERROR,
						p_message_token      =>       'GMA_MIGRATION_DB_ERROR',
						p_table_name         =>       G_Table_name,
						p_context            =>       G_context,
						p_db_error           =>       SQLERRM,
						p_app_short_name     =>       'GMA'
						);

						/**************************************
						* Migration Failure Log Message       *
						**************************************/

						GMA_COMMON_LOGGING.gma_migration_central_log
						(
						p_run_id             =>       G_migration_run_id,
						p_log_level          =>       FND_LOG.LEVEL_ERROR,
						p_message_token      =>       'GMA_TABLE_MIGRATION_TABLE_FAIL',
						p_table_name         =>       G_Table_name,
						p_context            =>       G_context,
						p_db_error           =>       NULL,
						p_app_short_name     =>       'GMA'
						);

			END;

			/**********************************************
			* Handle all the rows which were not migrated *
			**********************************************/
			gmf_migration.Log_Errors  (
																p_log_level               =>          1,
																p_from_rowid              =>          NULL,
																p_to_rowid                =>          NULL
																);

			/****************************************************************
			* Lets save the changes now based on the commit parameter       *
			****************************************************************/

			IF NVL(p_commit,'~') = FND_API.G_TRUE THEN
				 COMMIT;
			END IF;

	 EXCEPTION
			WHEN OTHERS THEN

				 /************************************************
				 * Increment Failure Count for Failed Migrations *
				 ************************************************/

				 x_failure_count := x_failure_count + 1;

				 /**************************************
				 * Migration DB Error Log Message      *
				 **************************************/

				 GMA_COMMON_LOGGING.gma_migration_central_log
				 (
				 p_run_id             =>       G_migration_run_id,
				 p_log_level          =>       FND_LOG.LEVEL_ERROR,
				 p_message_token      =>       'GMA_MIGRATION_DB_ERROR',
				 p_table_name         =>       G_Table_name,
				 p_context            =>       G_context,
				 p_db_error           =>       SQLERRM,
				 p_app_short_name     =>       'GMA'
				 );

				 /**************************************
				 * Migration Failure Log Message       *
				 **************************************/

				 GMA_COMMON_LOGGING.gma_migration_central_log
				 (
				 p_run_id             =>       G_migration_run_id,
				 p_log_level          =>       FND_LOG.LEVEL_ERROR,
				 p_message_token      =>       'GMA_TABLE_MIGRATION_TABLE_FAIL',
				 p_table_name         =>       G_Table_name,
				 p_context            =>       G_context,
				 p_db_error           =>       NULL,
				 p_app_short_name     =>       'GMA'
				 );

	 END Migrate_Material_Lot_Cost_txns;

	 /**********************************************************************
	 * PROCEDURE:                                                          *
	 *   Migrate_Lot_Cost_Burdens                                          *
	 *                                                                     *
	 * DESCRIPTION:                                                        *
	 *   This PL/SQL procedure is used to migrate the Lot Cost Burdens     *
	 *                                                                     *
	 * PARAMETERS:                                                         *
	 *   P_migration_run_id - id to use to right to migration log          *
	 *   x_exception_count  - Number of exceptions occurred.               *
	 *                                                                     *
	 * SYNOPSIS:                                                           *
	 *   Migrate_Lot_Cost_Burdens(p_migartion_id    => l_migration_id,     *
	 *                    p_commit          => 'T',                        *
	 *                    x_exception_count => l_exception_count );        *
	 *                                                                     *
	 * HISTORY                                                             *
	 *       27-Apr-2005 Created  Anand Thiyagarajan                       *
	 *                                                                     *
	 **********************************************************************/
	 PROCEDURE Migrate_Lot_Cost_Burdens
	 (
	 P_migration_run_id      IN             NUMBER,
	 P_commit                IN             VARCHAR2,
	 X_failure_count         OUT   NOCOPY   NUMBER
	 )
	 IS

			/**************************
			* PL/SQL Table Definition *
			**************************/

			/******************
			* Local Variables *
			******************/

			/**********
			* Cursors *
			**********/

	 BEGIN

			G_Migration_run_id := P_migration_run_id;
			G_Table_name := 'GMF_LOT_COST_BURDENS';
			G_Context := 'Lot Cost Burdens Migration';
			X_failure_count := 0;

			/********************************
			* Migration Started Log Message *
			********************************/

			GMA_COMMON_LOGGING.gma_migration_central_log
			(
			p_run_id             =>       G_migration_run_id,
			p_log_level          =>       FND_LOG.LEVEL_STATEMENT,
			p_message_token      =>       'GMA_MIGRATION_TABLE_STARTED',
			p_table_name         =>       G_Table_name,
			p_context            =>       G_context,
			p_db_error           =>       NULL,
			p_app_short_name     =>       'GMA'
			);

			BEGIN

				 /******************************************************
				 * Update a row in GMF_LOT_COST_BURDENS for cost Types *
				 ******************************************************/

				 UPDATE      gmf_lot_cost_burdens a
				 SET         a.cost_type_id
				 =           (
										 SELECT      x.cost_Type_id
										 FROM        cm_mthd_mst x
										 WHERE       x.cost_mthd_code = a.cost_mthd_code
										 ),
										 a.item_uom
				 =           (
										 SELECT      x.uom_code
										 FROM        sy_uoms_mst x
										 WHERE       x.um_code = a.item_um
										 ),
										 a.resource_uom
				 =           (
										 SELECT      y.uom_code
										 FROM        sy_uoms_mst y
										 WHERE       y.um_code = a.resource_um
										 ),
										 (
										 a.organization_id,
										 a.inventory_item_id
										 )
				 =           (
										 SELECT      decode(x.cost_organization_id, -1, -1, y.organization_id),
																 y.inventory_item_id
										 FROM        ic_whse_mst x,
																 ic_item_mst_b_mig y
										 WHERE       x.whse_code = a.whse_code
										 AND         y.item_id = a.item_id
										 AND         y.organization_id = NVL(DECODE(x.cost_organization_id, -1, x.mtl_organization_id, x.cost_organization_id), x.mtl_organization_id)
										 )
				 WHERE       (
										 (a.cost_type_id IS NULL AND a.cost_mthd_code IS NOT NULL)
				 OR          (a.item_uom IS NULL AND a.item_um IS NOT NULL)
				 OR          (a.resource_uom IS NULL AND a.resource_um IS NOT NULL)
				 OR          (a.organization_id IS NULL AND a.whse_code IS NOT NULL)
				 OR          (a.inventory_item_id IS NULL AND a.item_id IS NOT NULL)
										 );

			EXCEPTION
				 WHEN OTHERS THEN

						/************************************************
						* Increment Failure Count for Failed Migrations *
						************************************************/

						x_failure_count := x_failure_count + 1;

						/**************************************
						* Migration DB Error Log Message      *
						**************************************/

						GMA_COMMON_LOGGING.gma_migration_central_log
						(
						p_run_id             =>       G_migration_run_id,
						p_log_level          =>       FND_LOG.LEVEL_ERROR,
						p_message_token      =>       'GMA_MIGRATION_DB_ERROR',
						p_table_name         =>       G_Table_name,
						p_context            =>       G_context,
						p_db_error           =>       SQLERRM,
						p_app_short_name     =>       'GMA'
						);

						/**************************************
						* Migration Failure Log Message       *
						**************************************/

						GMA_COMMON_LOGGING.gma_migration_central_log
						(
						p_run_id             =>       G_migration_run_id,
						p_log_level          =>       FND_LOG.LEVEL_ERROR,
						p_message_token      =>       'GMA_TABLE_MIGRATION_TABLE_FAIL',
						p_table_name         =>       G_Table_name,
						p_context            =>       G_context,
						p_db_error           =>       NULL,
						p_app_short_name     =>       'GMA'
						);

			END;
      BEGIN
        /****************************************************************************
        * Insert rows for Additional Lots Created as part of Lot Balances Migration *
        ****************************************************************************/
        INSERT INTO             gmf_lot_cost_burdens
        (
        lot_burden_line_id,
        resources,
        cost_cmpntcls_id,
        cost_analysis_code,
        start_date,
        end_date,
        resource_usage,
        resource_count,
        item_qty,
        burden_factor,
        applied_ind,
        delete_mark,
        text_code,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        last_update_login,
        attribute1,
        attribute2,
        attribute3,
        attribute4,
        attribute5,
        attribute6,
        attribute7,
        attribute8,
        attribute9,
        attribute10,
        attribute11,
        attribute12,
        attribute13,
        attribute14,
        attribute15,
        attribute16,
        attribute17,
        attribute18,
        attribute19,
        attribute20,
        attribute21,
        attribute22,
        attribute23,
        attribute24,
        attribute25,
        attribute26,
        attribute27,
        attribute28,
        attribute29,
        attribute30,
        attribute_category,
        cost_type_id,
        inventory_item_id,
        item_uom,
        lot_number,
        organization_id,
        resource_uom
        )
        (
        SELECT                GMF_LOT_BURDEN_LINE_ID_S.NEXTVAL,
                              a.resources,
                              a.cost_cmpntcls_id,
                              a.cost_analysis_code,
                              a.start_date,
                              a.end_date,
                              a.resource_usage,
                              a.resource_count,
                              a.item_qty,
                              a.burden_factor,
                              a.applied_ind,
                              a.delete_mark,
                              a.lot_burden_line_id,
                              a.created_by,
                              SYSDATE,
                              a.last_updated_by,
                              SYSDATE,
                              a.last_update_login,
                              a.attribute1,
                              a.attribute2,
                              a.attribute3,
                              a.attribute4,
                              a.attribute5,
                              a.attribute6,
                              a.attribute7,
                              a.attribute8,
                              a.attribute9,
                              a.attribute10,
                              a.attribute11,
                              a.attribute12,
                              a.attribute13,
                              a.attribute14,
                              a.attribute15,
                              a.attribute16,
                              a.attribute17,
                              a.attribute18,
                              a.attribute19,
                              a.attribute20,
                              a.attribute21,
                              a.attribute22,
                              a.attribute23,
                              a.attribute24,
                              a.attribute25,
                              a.attribute26,
                              a.attribute27,
                              a.attribute28,
                              a.attribute29,
                              a.attribute30,
                              a.attribute_category,
                              a.cost_type_id,
                              a.inventory_item_id,
                              a.item_uom,
                              b.lot_number,
                              a.organization_id,
                              a.resource_uom
        FROM                  gmf_lot_cost_burdens a,
                              ic_lots_mst_mig b
        WHERE                 a.lot_id = b.lot_id
        AND                   nvl(b.additional_status_lot,0) = 1
        AND                   (
							                (a.cost_type_id IS NOT NULL AND a.cost_mthd_code IS NOT NULL)
	      OR                    (a.item_uom IS NOT NULL AND a.item_um IS NOT NULL)
		    OR                    (a.resource_uom IS NOT NULL AND a.resource_um IS NOT NULL)
		    OR                    (a.organization_id IS NOT NULL AND a.whse_code IS NOT NULL)
		    OR                    (a.inventory_item_id IS NOT NULL AND a.item_id IS NOT NULL)
							                )
        AND                   NOT EXISTS  (
                                          SELECT            'RECORD_ALREADY_EXISTS'
                                          FROM              gmf_lot_cost_burdens x
                                          WHERE             x.organization_id = a.organization_id
                                          AND               x.inventory_item_id = a.inventory_item_id
                                          AND               x.cost_type_id = a.cost_type_id
                                          AND               x.lot_number = b.lot_number
                                          AND               x.resources = a.resources
                                          AND               x.cost_cmpntcls_id = a.cost_cmpntcls_id
                                          AND               x.cost_analysis_code = a.cost_analysis_code
                                          )
        );
      EXCEPTION
         WHEN OTHERS THEN
            /************************************************
            * Increment Failure Count for Failed Migrations *
            ************************************************/
            x_failure_count := x_failure_count + 1;
            /**************************************
            * Migration DB Error Log Message      *
            **************************************/
            GMA_COMMON_LOGGING.gma_migration_central_log
            (
            p_run_id             =>       G_migration_run_id,
            p_log_level          =>       FND_LOG.LEVEL_ERROR,
            p_message_token      =>       'GMA_MIGRATION_DB_ERROR',
            p_table_name         =>       G_Table_name,
            p_context            =>       G_context,
            p_db_error           =>       SQLERRM,
            p_app_short_name     =>       'GMA'
            );
            /**************************************
            * Migration Failure Log Message       *
            **************************************/
            GMA_COMMON_LOGGING.gma_migration_central_log
            (
            p_run_id             =>       G_migration_run_id,
            p_log_level          =>       FND_LOG.LEVEL_ERROR,
            p_message_token      =>       'GMA_TABLE_MIGRATION_TABLE_FAIL',
            p_table_name         =>       G_Table_name,
            p_context            =>       G_context,
            p_db_error           =>       NULL,
            p_app_short_name     =>       'GMA'
            );
      END;

			/**********************************************
			* Handle all the rows which were not migrated *
			**********************************************/
			gmf_migration.Log_Errors  (
																p_log_level               =>          1,
																p_from_rowid              =>          NULL,
																p_to_rowid                =>          NULL
																);

			/****************************************************************
			* Lets save the changes now based on the commit parameter       *
			****************************************************************/

			IF NVL(p_commit,'~') = FND_API.G_TRUE THEN
				 COMMIT;
			END IF;

	 EXCEPTION
			WHEN OTHERS THEN

				 /************************************************
				 * Increment Failure Count for Failed Migrations *
				 ************************************************/

				 x_failure_count := x_failure_count + 1;

				 /**************************************
				 * Migration DB Error Log Message      *
				 **************************************/

				 GMA_COMMON_LOGGING.gma_migration_central_log
				 (
				 p_run_id             =>       G_migration_run_id,
				 p_log_level          =>       FND_LOG.LEVEL_ERROR,
				 p_message_token      =>       'GMA_MIGRATION_DB_ERROR',
				 p_table_name         =>       G_Table_name,
				 p_context            =>       G_context,
				 p_db_error           =>       SQLERRM,
				 p_app_short_name     =>       'GMA'
				 );

				 /**************************************
				 * Migration Failure Log Message       *
				 **************************************/

				 GMA_COMMON_LOGGING.gma_migration_central_log
				 (
				 p_run_id             =>       G_migration_run_id,
				 p_log_level          =>       FND_LOG.LEVEL_ERROR,
				 p_message_token      =>       'GMA_TABLE_MIGRATION_TABLE_FAIL',
				 p_table_name         =>       G_Table_name,
				 p_context            =>       G_context,
				 p_db_error           =>       NULL,
				 p_app_short_name     =>       'GMA'
				 );

	 END Migrate_Lot_Cost_Burdens;

	 /**********************************************************************
	 * PROCEDURE:                                                          *
	 *   Migrate_Allocation_Basis                                          *
	 *                                                                     *
	 * DESCRIPTION:                                                        *
	 *   This PL/SQL procedure is used to migrate the Expense Allocation   *
	 *   Basis Records                                                     *
	 *                                                                     *
	 * PARAMETERS:                                                         *
	 *   P_migration_run_id - id to use to right to migration log          *
	 *   x_exception_count  - Number of exceptions occurred.               *
	 *                                                                     *
	 * SYNOPSIS:                                                           *
	 *   Migrate_Allocation_Basis(p_migartion_id    => l_migration_id,     *
	 *                    p_commit          => 'T',                        *
	 *                    x_exception_count => l_exception_count );        *
	 *                                                                     *
	 * HISTORY                                                             *
	 *       27-Apr-2005 Created  Anand Thiyagarajan                       *
	 *                                                                     *
	 **********************************************************************/
	 PROCEDURE Migrate_Allocation_Basis
	 (
	 P_migration_run_id      IN             NUMBER,
	 P_commit                IN             VARCHAR2,
	 X_failure_count         OUT   NOCOPY   NUMBER
	 )
	 IS

			/**************************
			* PL/SQL Table Definition *
			**************************/

			/******************
			* Local Variables *
			******************/

			l_inventory_item_id                 NUMBER;
			l_itm_failure_count                 NUMBER;
			l_itm_failure_count_all             NUMBER;

			/**********
			* Cursors *
			**********/

			CURSOR            cur_get_gmf_items
			IS
			SELECT            DISTINCT
												item_id,
												organization_id
			FROM              (
												SELECT            a.item_id,
																					DECODE(NVL(b.subinventory_ind_flag,'N'), 'Y', b.organization_id, b.mtl_organization_id) organization_id
												FROM              gl_aloc_bas a,
																					ic_whse_mst b
												WHERE             a.item_id IS NOT NULL
												AND               b.whse_code = a.whse_code
												);

	 BEGIN

			G_Migration_run_id := P_migration_run_id;
			G_Table_name := 'GL_ALOC_BAS';
			G_Context := 'Expense Allocation Basis Migration';
			X_failure_count := 0;

			/********************************
			* Migration Started Log Message *
			********************************/

			GMA_COMMON_LOGGING.gma_migration_central_log
			(
			p_run_id             =>       G_migration_run_id,
			p_log_level          =>       FND_LOG.LEVEL_STATEMENT,
			p_message_token      =>       'GMA_MIGRATION_TABLE_STARTED',
			p_table_name         =>       G_Table_name,
			p_context            =>       G_context,
			p_db_error           =>       NULL,
			p_app_short_name     =>       'GMA'
			);

			/****************************************************************
			* Migrating Items IN GL_ALOC_BAS table to Converged Item Master *
			****************************************************************/

			FOR i IN cur_get_gmf_items
			LOOP
				IF  i.item_id IS NOT NULL
				AND i.organization_id IS NOT NULL
				THEN
					inv_opm_item_migration.get_odm_item
					(
					p_migration_run_id        =>        p_migration_run_id,
					p_item_id                 =>        i.item_id,
					p_organization_id         =>        i.organization_id,
					p_mode                    =>        NULL,
					p_commit                  =>        FND_API.G_TRUE,
					x_inventory_item_id       =>        l_inventory_item_id,
					x_failure_count           =>        l_itm_failure_count
					);
				END IF;
				l_itm_failure_count_all := nvl(l_itm_failure_count_all,0) + nvl(l_itm_failure_count,0);
			END LOOP;

			/**********************************************************
			* Update a row in GL_ALOC_BAS for Account Codes           *
			**********************************************************/

			BEGIN
                        /*  B8266256 -- Splitting update into 2 parts Starts */
		--		 UPDATE      gl_aloc_bas a
		--		 SET         a.basis_account_id
		--		 =           (
		--								 SELECT      gmf_migration.get_account_id(a.basis_Account_key, x.co_code)
		--								 FROM        gl_aloc_mst x
		--								 WHERE       x.alloc_id = a.alloc_id
		--								 ),
		--								 a.basis_type = decode(a.alloc_method, 0, a.basis_type, 1),
		--								 (
		--								 a.organization_id,
		--								 a.inventory_item_id
		--								 )
		--		 =           (
		--								 SELECT      y.organization_id,
		--														 y.inventory_item_id
		--								 FROM        ic_whse_mst x,
		--														 ic_item_mst_b_mig y
		--								 WHERE       x.whse_code = a.whse_code
		--								 AND         y.item_id = a.item_id
		--								 AND         y.organization_id = DECODE(NVL(x.subinventory_ind_flag, 'N'), 'Y', x.organization_id, x.mtl_organization_id)
		--								 )
		--		 WHERE       (
		--								 (a.basis_account_key IS NOT NULL AND a.basis_account_id IS NULL)
		--		 OR          (a.inventory_item_id IS NULL AND a.item_id IS NOT NULL)
		--		 OR          (a.organization_id IS NULL AND a.whse_code IS NOT NULL)
		--								 );

                                 /* For fixed percentage allocations */
				 UPDATE gl_aloc_bas a
				 SET    a.basis_type = decode(a.alloc_method, 0, a.basis_type, 1),
					(
					a.organization_id,
					a.inventory_item_id
				        )
				=       (
					SELECT  y.organization_id,
				                y.inventory_item_id
					FROM    ic_whse_mst x,
					        ic_item_mst_b_mig y
				        WHERE   x.whse_code = a.whse_code
				          AND   y.item_id = a.item_id
				          AND   y.organization_id = DECODE(NVL(x.subinventory_ind_flag, 'N'), 'Y', x.organization_id, x.mtl_organization_id)
				         )
				WHERE       (
				     (a.basis_account_key IS NOT NULL AND a.basis_account_id IS NULL)
				 OR  (a.inventory_item_id IS NULL AND a.item_id IS NOT NULL)
				 OR  (a.organization_id IS NULL AND a.whse_code IS NOT NULL)
				             )
                                 AND a.alloc_method <> 0 ;

                                 /* For GL Balance percentage allocations */
				 UPDATE gl_aloc_bas a
				 SET    a.basis_account_id
				 =      (
					SELECT      decode(a.alloc_method,0, gmf_migration.get_account_id(a.basis_Account_key, x.co_code), NULL)
					FROM        gl_aloc_mst x
					WHERE       x.alloc_id = a.alloc_id
					),
					a.basis_type = decode(a.alloc_method, 0, a.basis_type, 1),
					(
					a.organization_id,
					a.inventory_item_id
					)
				 =      (
					SELECT  y.organization_id,
					        y.inventory_item_id
					FROM    ic_whse_mst x,
					        ic_item_mst_b_mig y
					WHERE   x.whse_code = a.whse_code
					AND     y.item_id = a.item_id
					AND     y.organization_id = DECODE(NVL(x.subinventory_ind_flag, 'N'), 'Y', x.organization_id, x.mtl_organization_id)
					)
				 WHERE  (
					(a.basis_account_key IS NOT NULL AND a.basis_account_id IS NULL)
				 OR     (a.inventory_item_id IS NULL AND a.item_id IS NOT NULL)
				 OR     (a.organization_id IS NULL AND a.whse_code IS NOT NULL)
					)
                                 AND a.alloc_method = 0 ;
                          /*  B8266256 -- Ends */


			EXCEPTION
				 WHEN OTHERS THEN

						/************************************************
						* Increment Failure Count for Failed Migrations *
						************************************************/

						x_failure_count := x_failure_count + 1;

						/**************************************
						* Migration DB Error Log Message      *
						**************************************/

						GMA_COMMON_LOGGING.gma_migration_central_log
						(
						p_run_id             =>       G_migration_run_id,
						p_log_level          =>       FND_LOG.LEVEL_ERROR,
						p_message_token      =>       'GMA_MIGRATION_DB_ERROR',
						p_table_name         =>       G_Table_name,
						p_context            =>       G_context,
						p_db_error           =>       SQLERRM,
						p_app_short_name     =>       'GMA'
						);

						/**************************************
						* Migration Failure Log Message       *
						**************************************/

						GMA_COMMON_LOGGING.gma_migration_central_log
						(
						p_run_id             =>       G_migration_run_id,
						p_log_level          =>       FND_LOG.LEVEL_ERROR,
						p_message_token      =>       'GMA_TABLE_MIGRATION_TABLE_FAIL',
						p_table_name         =>       G_Table_name,
						p_context            =>       G_context,
						p_db_error           =>       NULL,
						p_app_short_name     =>       'GMA'
						);

			END;

			/**********************************************
			* Handle all the rows which were not migrated *
			**********************************************/

			SELECT               count(*)
			INTO                 x_failure_count
			FROM                 gl_aloc_bas
			WHERE                (
													 (basis_account_key IS NOT NULL AND basis_account_id IS NULL)
			OR                   (inventory_item_id IS NULL AND item_id IS NOT NULL)
			OR                   (organization_id IS NULL AND whse_code IS NOT NULL)
													 );

			IF nvl(x_failure_count,0) > 0 THEN

				/**************************************
				* Migration Failure Log Message       *
				**************************************/

				GMA_COMMON_LOGGING.gma_migration_central_log
				(
				p_run_id             =>       gmf_migration.G_migration_run_id,
				p_log_level          =>       FND_LOG.LEVEL_PROCEDURE,
				p_message_token      =>       'GMA_TABLE_MIGRATION_TABLE_FAIL',
				p_table_name         =>       gmf_migration.G_Table_name,
				p_context            =>       gmf_migration.G_context,
				p_db_error           =>       NULL,
				p_app_short_name     =>       'GMA'
				);

			ELSE

				/**************************************
				* Migration Success Log Message       *
				**************************************/

				GMA_COMMON_LOGGING.gma_migration_central_log
				(
				p_run_id             =>       G_migration_run_id,
				p_log_level          =>       FND_LOG.LEVEL_STATEMENT,
				p_message_token      =>       'GMA_MIGRATION_TABLE_SUCCESS',
				p_table_name         =>       G_Table_name,
				p_context            =>       G_Context,
				p_param1             =>       1,
				p_param2             =>       0,
				p_db_error           =>       NULL,
				p_app_short_name     =>       'GMA'
				);

			END IF;

			/****************************************************************
			* Lets save the changes now based on the commit parameter       *
			****************************************************************/

			IF NVL(p_commit,'~') = FND_API.G_TRUE THEN
				 COMMIT;
			END IF;

	 EXCEPTION
			WHEN OTHERS THEN

				 /************************************************
				 * Increment Failure Count for Failed Migrations *
				 ************************************************/

				 x_failure_count := x_failure_count + 1;

				 /**************************************
				 * Migration DB Error Log Message      *
				 **************************************/

				 GMA_COMMON_LOGGING.gma_migration_central_log
				 (
				 p_run_id             =>       G_migration_run_id,
				 p_log_level          =>       FND_LOG.LEVEL_ERROR,
				 p_message_token      =>       'GMA_MIGRATION_DB_ERROR',
				 p_table_name         =>       G_Table_name,
				 p_context            =>       G_context,
				 p_db_error           =>       SQLERRM,
				 p_app_short_name     =>       'GMA'
				 );

				 /**************************************
				 * Migration Failure Log Message       *
				 **************************************/

				 GMA_COMMON_LOGGING.gma_migration_central_log
				 (
				 p_run_id             =>       G_migration_run_id,
				 p_log_level          =>       FND_LOG.LEVEL_ERROR,
				 p_message_token      =>       'GMA_TABLE_MIGRATION_TABLE_FAIL',
				 p_table_name         =>       G_Table_name,
				 p_context            =>       G_context,
				 p_db_error           =>       NULL,
				 p_app_short_name     =>       'GMA'
				 );

	 END Migrate_Allocation_Basis;

	 /**********************************************************************
	 * PROCEDURE:                                                          *
	 *   Migrate_Allocation_Expenses                                       *
	 *                                                                     *
	 * DESCRIPTION:                                                        *
	 *   This PL/SQL procedure is used to migrate the Expense Allocation   *
	 *   Expenses Records                                                  *
	 *                                                                     *
	 * PARAMETERS:                                                         *
	 *   P_migration_run_id - id to use to right to migration log          *
	 *   x_exception_count  - Number of exceptions occurred.               *
	 *                                                                     *
	 * SYNOPSIS:                                                           *
	 *   Migrate_Allocation_Expenses(p_migartion_id    => l_migration_id,  *
	 *                    p_commit          => 'T',                        *
	 *                    x_exception_count => l_exception_count );        *
	 *                                                                     *
	 * HISTORY                                                             *
	 *       27-Apr-2005 Created  Anand Thiyagarajan                       *
	 *                                                                     *
	 **********************************************************************/
	 PROCEDURE Migrate_Allocation_Expenses
	 (
	 P_migration_run_id      IN             NUMBER,
	 P_commit                IN             VARCHAR2,
	 X_failure_count         OUT   NOCOPY   NUMBER
	 )
	 IS

			/***************************
			* PL/SQL Table Definitions *
			***************************/

			/******************
			* Local Variables *
			******************/

	 BEGIN

			G_Migration_run_id := P_migration_run_id;
			G_Table_name := 'GL_ALOC_EXP';
			G_Context := 'Expense Allocation Expenses Migration';
			X_failure_count := 0;

			/********************************
			* Migration Started Log Message *
			********************************/

			GMA_COMMON_LOGGING.gma_migration_central_log
			(
			p_run_id             =>       G_migration_run_id,
			p_log_level          =>       FND_LOG.LEVEL_STATEMENT,
			p_message_token      =>       'GMA_MIGRATION_TABLE_STARTED',
			p_table_name         =>       G_Table_name,
			p_context            =>       G_context,
			p_db_error           =>       NULL,
			p_app_short_name     =>       'GMA'
			);


			/**********************************************************
			* Update a row in GL_ALOC_EXP for Account Codes           *
			**********************************************************/

			BEGIN
				 UPDATE         gl_aloc_exp a
				 SET            (
												a.from_account_id,
												a.to_account_id
												)
				 =              (
												SELECT      gmf_migration.get_account_id(a.from_account, x.co_code),
																		gmf_migration.get_account_id(a.to_account, x.co_code)
												FROM        gl_aloc_mst x
												WHERE       x.alloc_id = a.alloc_id
												)
				 WHERE          (
												(from_account_id IS NULL AND from_account IS NOT NULL)
				 OR             (to_account_id IS NULL AND to_account IS NOT NULL)
												);

			EXCEPTION
				 WHEN OTHERS THEN

						/************************************************
						* Increment Failure Count for Failed Migrations *
						************************************************/

						x_failure_count := x_failure_count + 1;

						/**************************************
						* Migration DB Error Log Message      *
						**************************************/

						GMA_COMMON_LOGGING.gma_migration_central_log
						(
						p_run_id             =>       G_migration_run_id,
						p_log_level          =>       FND_LOG.LEVEL_ERROR,
						p_message_token      =>       'GMA_MIGRATION_DB_ERROR',
						p_table_name         =>       G_Table_name,
						p_context            =>       G_context,
						p_db_error           =>       SQLERRM,
						p_app_short_name     =>       'GMA'
						);

						/**************************************
						* Migration Failure Log Message       *
						**************************************/

						GMA_COMMON_LOGGING.gma_migration_central_log
						(
						p_run_id             =>       G_migration_run_id,
						p_log_level          =>       FND_LOG.LEVEL_ERROR,
						p_message_token      =>       'GMA_TABLE_MIGRATION_TABLE_FAIL',
						p_table_name         =>       G_Table_name,
						p_context            =>       G_context,
						p_db_error           =>       NULL,
						p_app_short_name     =>       'GMA'
						);

			END;

			/**********************************************
			* Handle all the rows which were not migrated *
			**********************************************/

			SELECT               count(*)
			INTO                 x_failure_count
			FROM                 gl_aloc_exp
			WHERE                (
													 (from_account_id IS NULL AND from_account IS NOT NULL)
			OR                   (to_account_id IS NULL AND to_account IS NOT NULL)
													 );

			IF nvl(x_failure_count,0) > 0 THEN

				/**************************************
				* Migration Failure Log Message       *
				**************************************/

				GMA_COMMON_LOGGING.gma_migration_central_log
				(
				p_run_id             =>       gmf_migration.G_migration_run_id,
				p_log_level          =>       FND_LOG.LEVEL_PROCEDURE,
				p_message_token      =>       'GMA_TABLE_MIGRATION_TABLE_FAIL',
				p_table_name         =>       gmf_migration.G_Table_name,
				p_context            =>       gmf_migration.G_context,
				p_db_error           =>       NULL,
				p_app_short_name     =>       'GMA'
				);

			ELSE

				/**************************************
				* Migration Success Log Message       *
				**************************************/

				GMA_COMMON_LOGGING.gma_migration_central_log
				(
				p_run_id             =>       G_migration_run_id,
				p_log_level          =>       FND_LOG.LEVEL_STATEMENT,
				p_message_token      =>       'GMA_MIGRATION_TABLE_SUCCESS',
				p_table_name         =>       G_Table_name,
				p_context            =>       G_Context,
				p_param1             =>       1,
				p_param2             =>       0,
				p_db_error           =>       NULL,
				p_app_short_name     =>       'GMA'
				);

			END IF;

			/****************************************************************
			* Lets save the changes now based on the commit parameter       *
			****************************************************************/

			IF NVL(p_commit,'~') = FND_API.G_TRUE THEN
				 COMMIT;
			END IF;

	 EXCEPTION

			WHEN OTHERS THEN

				 /************************************************
				 * Increment Failure Count for Failed Migrations *
				 ************************************************/

				 x_failure_count := x_failure_count + 1;

				 /**************************************
				 * Migration DB Error Log Message      *
				 **************************************/

				 GMA_COMMON_LOGGING.gma_migration_central_log
				 (
				 p_run_id             =>       G_migration_run_id,
				 p_log_level          =>       FND_LOG.LEVEL_ERROR,
				 p_message_token      =>       'GMA_MIGRATION_DB_ERROR',
				 p_table_name         =>       G_Table_name,
				 p_context            =>       G_context,
				 p_param1             =>       NULL,
				 p_param2             =>       NULL,
				 p_db_error           =>       SQLERRM,
				 p_app_short_name     =>       'GMA'
				 );

				 /**************************************
				 * Migration Failure Log Message       *
				 **************************************/

				 GMA_COMMON_LOGGING.gma_migration_central_log
				 (
				 p_run_id             =>       G_migration_run_id,
				 p_log_level          =>       FND_LOG.LEVEL_ERROR,
				 p_message_token      =>       'GMA_TABLE_MIGRATION_TABLE_FAIL',
				 p_table_name         =>       G_Table_name,
				 p_context            =>       G_context,
				 p_db_error           =>       NULL,
				 p_app_short_name     =>       'GMA'
				 );

	 END Migrate_Allocation_Expenses;

	 /**********************************************************************
	 * PROCEDURE:                                                          *
	 *   Migrate_Account_Mappings                                          *
	 *                                                                     *
	 * DESCRIPTION:                                                        *
	 *   This PL/SQL procedure is used to migrate the Account Mappings from*
	 *   OPM Data model to SLA ADR Model                                   *
	 *                                                                     *
	 * PARAMETERS:                                                         *
	 *   P_migration_run_id - id to use to right to migration log          *
	 *   x_exception_count  - Number of exceptions occurred.               *
	 *                                                                     *
	 * SYNOPSIS:                                                           *
	 *   Migrate_Account_Mappings(p_migartion_id => l_migration_id,        *
	 *                    p_commit          => 'T',                        *
	 *                    x_exception_count => l_exception_count );        *
	 *                                                                     *
	 * HISTORY                                                             *
	 *       27-Apr-2005 Created  Anand Thiyagarajan                       *
	 *                                                                     *
	 **********************************************************************/
	 PROCEDURE Migrate_Account_Mappings
	 (
	 P_migration_run_id      IN             NUMBER,
	 P_commit                IN             VARCHAR2,
	 X_failure_count         OUT   NOCOPY   NUMBER
	 )
	 IS

			/**************************
			* PL/SQL Table Definition *
			**************************/

			TYPE my_order_tbl IS TABLE OF NUMBER(2) INDEX BY BINARY_INTEGER;
			TYPE t_event_class_code IS TABLE OF VARCHAR2(30) INDEX BY VARCHAR2(4);
			TYPE t_event_type_code IS TABLE OF VARCHAR2(30) INDEX BY VARCHAR2(4);

			TYPE t_co_code IS TABLE OF GL_ACCT_MAP.CO_CODE%TYPE INDEX BY BINARY_INTEGER;
			TYPE t_orgn_code IS TABLE OF GL_ACCT_MAP.ORGN_CODE%TYPE INDEX BY BINARY_INTEGER;
			TYPE t_whse_code IS TABLE OF GL_ACCT_MAP.WHSE_CODE%TYPE INDEX BY BINARY_INTEGER;
			TYPE t_item_id IS TABLE OF GL_ACCT_MAP.ITEM_ID%TYPE INDEX BY BINARY_INTEGER;
			TYPE t_vendor_id IS TABLE OF GL_ACCT_MAP.VENDOR_ID%TYPE INDEX BY BINARY_INTEGER;
			TYPE t_cust_id IS TABLE OF GL_ACCT_MAP.CUST_ID%TYPE INDEX BY BINARY_INTEGER;
			TYPE t_reason_code IS TABLE OF GL_ACCT_MAP.REASON_CODE%TYPE INDEX BY BINARY_INTEGER;
			TYPE t_gl_category_id IS TABLE OF GL_ACCT_MAP.GL_CATEGORY_ID%TYPE INDEX BY BINARY_INTEGER;
			TYPE t_vendgl_class IS TABLE OF GL_ACCT_MAP.VENDGL_CLASS%TYPE INDEX BY BINARY_INTEGER;
			TYPE t_custgl_class IS TABLE OF GL_ACCT_MAP.CUSTGL_CLASS%TYPE INDEX BY BINARY_INTEGER;
			TYPE t_currency_code IS TABLE OF GL_ACCT_MAP.CURRENCY_CODE%TYPE INDEX BY BINARY_INTEGER;
			TYPE t_routing_id IS TABLE OF GL_ACCT_MAP.ROUTING_ID%TYPE INDEX BY BINARY_INTEGER;
			TYPE t_charge_id IS TABLE OF GL_ACCT_MAP.CHARGE_ID%TYPE INDEX BY BINARY_INTEGER;
			TYPE t_taxauth_id IS TABLE OF GL_ACCT_MAP.TAXAUTH_ID%TYPE INDEX BY BINARY_INTEGER;
			TYPE t_acct_id IS TABLE OF GL_ACCT_MAP.ACCT_ID%TYPE INDEX BY BINARY_INTEGER;
			TYPE t_aqui_cost_id IS TABLE OF GL_ACCT_MAP.AQUI_COST_ID%TYPE INDEX BY BINARY_INTEGER;
			TYPE t_resources IS TABLE OF GL_ACCT_MAP.RESOURCES%TYPE INDEX BY BINARY_INTEGER;
			TYPE t_cost_cmpntcls_id IS TABLE OF GL_ACCT_MAP.COST_CMPNTCLS_ID%TYPE INDEX BY BINARY_INTEGER;
			TYPE t_cost_analysis_code IS TABLE OF GL_ACCT_MAP.COST_ANALYSIS_CODE%TYPE INDEX BY BINARY_INTEGER;
			TYPE t_order_type IS TABLE OF GL_ACCT_MAP.ORDER_TYPE%TYPE INDEX BY BINARY_INTEGER;
			TYPE t_gl_business_class_cat_id IS TABLE OF GL_ACCT_MAP.GL_BUSINESS_CLASS_CAT_ID%TYPE INDEX BY BINARY_INTEGER;
			TYPE t_gl_product_line_cat_id IS TABLE OF GL_ACCT_MAP.GL_PRODUCT_LINE_CAT_ID%TYPE INDEX BY BINARY_INTEGER;
			TYPE t_line_type IS TABLE OF GL_ACCT_MAP.LINE_TYPE%TYPE INDEX BY BINARY_INTEGER;
			TYPE t_ar_trx_type_id IS TABLE OF GL_ACCT_MAP.AR_TRX_TYPE_ID%TYPE INDEX BY BINARY_INTEGER;
			TYPE t_rowid IS TABLE OF ROWID INDEX BY BINARY_INTEGER;
			TYPE t_inventory_org_ind IS TABLE OF SY_ORGN_MST.INVENTORY_ORG_IND%TYPE INDEX BY BINARY_INTEGER;
			TYPE t_organization_id IS TABLE OF SY_ORGN_MST.ORGANIZATION_ID%TYPE INDEX BY BINARY_INTEGER;
			TYPE t_mtl_organization_id IS TABLE OF IC_WHSE_MST.MTL_ORGANIZATION_ID%TYPE INDEX BY BINARY_INTEGER;
			TYPE t_subinventory_ind_flag IS TABLE OF IC_WHSE_MST.SUBINVENTORY_IND_FLAG%TYPE INDEX BY BINARY_INTEGER;
			TYPE t_acct_no IS TABLE OF GL_ACCT_MST.ACCT_NO%TYPE INDEX BY BINARY_INTEGER;
			TYPE t_source_type IS TABLE OF GL_ACCT_MAP.SOURCE_TYPE%TYPE INDEX BY BINARY_INTEGER;

			/******************
			* Local Variables *
			******************/

			l_legal_entity_id             GMF_FISCAL_POLICIES.LEGAL_ENTITY_ID%TYPE;
			l_adr_priority                NUMBER := 10;
			l_adr_condition_priority      NUMBER := 10;
			l_old_adr_condition_priority  NUMBER := 10;
			l_adr_rule_code               VARCHAR2(30);
			l_adr_rule_name               VARCHAR2(80);
			l_acctg_unit_count            NUMBER;
			l_segment_value               VARCHAR2(240);

			X_sqlstmt                     VARCHAR2(32000);
			X_sqlwhere                    VARCHAR2(32000);
			X_my_order_by                 VARCHAR2(200);
			X_sqlcolumns                  VARCHAR2(32000);
			X_sqlordby                    VARCHAR2(32000);
			X_tmp1                        NUMBER(10);
			X_cursor_handle               INTEGER;
			X_var_col                     VARCHAR2(32000);
			X_rows_processed              NUMBER(15);

			x_order_tbl                   my_order_tbl;

			l_inventory_item_id           MTL_SYSTEM_ITEMS_B.inventory_item_id%TYPE;
			l_item                        MTL_ITEM_FLEXFIELDS.item_number%TYPE;
			l_customer_no                 OP_CUST_MST.cust_no%TYPE;
			l_vendor_site_id              PO_VEND_MST.of_vendor_site_id%TYPE;
			l_taxauth_code                TX_TAXA_MST.taxauth_code%TYPE;
			l_Charge_code                 OP_CHRG_MST.Charge_code%TYPE;
			l_routing_no                  GMD_ROUTINGS_B.routing_no%TYPE;
			l_routing_vers                GMD_ROUTINGS_B.routing_vers%TYPE;
			l_price_element_type_id       PO_COST_MST.price_element_type_id%TYPE;
			l_cost_cmpntcls_code          CM_CMPT_MST.cost_cmpntcls_code%TYPE;
			l_Order_type_code             OP_ORDR_TYP.Order_type_code%TYPE;
			l_Line_type_code              GEM_LOOKUPS.meaning%TYPE;
			l_ar_trx_type_code            RA_CUST_TRX_TYPES_ALL.name%TYPE;

			l_co_code                     t_co_code;
			l_orgn_code                   t_orgn_code;
			l_whse_code                   t_whse_code;
			l_item_id                     t_item_id;
			l_vendor_id                   t_vendor_id;
			l_cust_id                     t_cust_id;
			l_reason_code                 t_reason_code;
			l_gl_category_id              t_gl_category_id;
			l_vendgl_class                t_vendgl_class;
			l_custgl_class                t_custgl_class;
			l_currency_code               t_currency_code;
			l_routing_id                  t_routing_id;
			l_charge_id                   t_charge_id;
			l_taxauth_id                  t_taxauth_id;
			l_acct_id                     t_acct_id;
			l_aqui_cost_id                t_aqui_cost_id;
			l_resources                   t_resources;
			l_cost_cmpntcls_id            t_cost_cmpntcls_id;
			l_cost_analysis_code          t_cost_analysis_code;
			l_order_type                  t_order_type;
			l_gl_business_class_cat_id    t_gl_business_class_cat_id;
			l_gl_product_line_cat_id      t_gl_product_line_cat_id;
			l_line_type                   t_line_type;
			l_ar_trx_type_id              t_ar_trx_type_id;
			l_rowid                       t_rowid;
			l_acct_no                     t_acct_no;
			l_inventory_org_ind           t_inventory_org_ind;
			l_subinventory_ind_flag       t_subinventory_ind_flag;
			l_source_type                 t_source_type;
			l_organization_id             t_organization_id;
			l_mtl_organization_id         t_mtl_organization_id;

			l_orgn_code_pri               GL_ACCT_HRC.ORGN_CODE_PRI%TYPE := 0;
			l_whse_code_pri               GL_ACCT_HRC.WHSE_CODE_PRI%TYPE := 0;
			l_item_pri                    GL_ACCT_HRC.ITEM_PRI%TYPE := 0;
			l_vendor_pri                  GL_ACCT_HRC.VENDOR_PRI%TYPE := 0;
			l_customer_pri                GL_ACCT_HRC.CUSTOMER_PRI%TYPE := 0;
			l_reason_code_pri             GL_ACCT_HRC.REASON_CODE_PRI%TYPE := 0;
			l_icgl_class_pri              GL_ACCT_HRC.ICGL_CLASS_PRI%TYPE := 0;
			l_vendgl_class_pri            GL_ACCT_HRC.VENDGL_CLASS_PRI%TYPE := 0;
			l_custgl_class_pri            GL_ACCT_HRC.CUSTGL_CLASS_PRI%TYPE := 0;
			l_currency_code_pri           GL_ACCT_HRC.CURRENCY_CODE_PRI%TYPE := 0;
			l_routing_pri                 GL_ACCT_HRC.ROUTING_PRI%TYPE := 0;
			l_charge_pri                  GL_ACCT_HRC.CHARGE_PRI%TYPE := 0;
			l_tax_auth_pri                GL_ACCT_HRC.TAX_AUTH_PRI%TYPE := 0;
			l_aqui_cost_code_pri          GL_ACCT_HRC.AQUI_COST_CODE_PRI%TYPE := 0;
			l_resource_pri                GL_ACCT_HRC.RESOURCE_PRI%TYPE := 0;
			l_cost_cmpntcls_pri           GL_ACCT_HRC.COST_CMPNTCLS_PRI%TYPE := 0;
			l_cost_analysis_pri           GL_ACCT_HRC.COST_ANALYSIS_PRI%TYPE := 0;
			l_order_type_pri              GL_ACCT_HRC.ORDER_TYPE_PRI%TYPE := 0;
			l_gl_business_class_pri       GL_ACCT_HRC.GL_BUSINESS_CLASS_PRI%TYPE := 0;
			l_gl_product_line_pri         GL_ACCT_HRC.GL_PRODUCT_LINE_PRI%TYPE := 0;
			l_line_type_pri               GL_ACCT_HRC.LINE_TYPE_PRI%TYPE := 0;
			l_ar_trx_type_pri             GL_ACCT_HRC.AR_TRX_TYPE_PRI%TYPE := 0;
			l_co_code1                    GL_ACCT_HRC.CO_CODE%TYPE;

			l_reason_id                   MTL_TRANSACTION_REASONS.REASON_ID%TYPE;
			l_row_id                      ROWID;

			xct                           PLS_INTEGER := 1;
			xrt                           PLS_INTEGER := 1;
			xlat                          PLS_INTEGER := 1;
			xrdt                          PLS_INTEGER := 1;
			mcnt                          PLS_INTEGER := 1;
			l_event_class_code            t_event_class_code;
			l_event_type_code             t_event_type_code;
			l_segment_rule_detail_id      NUMBER(38);
			l_old_segment_rule_detail_id  NUMBER(38);
			l_amb_context                 VARCHAR2(30);

			/**********
			* Cursors *
			**********/

			CURSOR               cur_legal_entities
			IS
			SELECT               a.legal_entity_id,
													 d.organization_code,
													 c.legal_entity_name organization_name,
													 b.segment_delimiter,
													 b.co_code,
													 e.chart_of_accounts_id,
													 e.short_name,
													 e.name,
													 e.ledger_id
			FROM                 gmf_fiscal_policies a,
													 gl_plcy_mst b,
													 gmf_legal_entities c,
													 mtl_parameters d,
													 gl_ledgers e
			WHERE                a.legal_entity_id = b.legal_entity_id
			AND                  c.legal_entity_id = a.legal_entity_id
			AND                  d.organization_id(+) = c.legal_entity_id
			AND                  e.ledger_id = a.ledger_id
			ORDER BY             a.legal_entity_id;

			CURSOR               cur_account_title
			IS
			SELECT               DISTINCT
													 DECODE(acct_ttl_code, 'PCO', 'COGS', 'IPF', 'IOPR', 'XFC', 'XTC', acct_ttl_code) acct_ttl_code,
													 DECODE(acct_ttl_code, 'PCO', 'Cost of Goods Sold' , 'IPF', 'Inter-Org Profit', 'XFC', 'Inter-org Transfer Credit', acct_ttl_desc) acct_ttl_desc,
													 acct_ttl_type
			FROM                 gl_acct_ttl
			ORDER BY             acct_ttl_code;

			CURSOR               cur_plcy_seg
			(
			p_co_code           IN                VARCHAR2,
			p_coa_id            IN                NUMBER
			)
			IS
			SELECT               a.segment_no,
													 a.type,
													 b.segment_name short_name,
													 b.application_column_name,
													 c.id_flex_structure_code structure_code,
													 c.id_flex_structure_name structure_name
			FROM                 gl_plcy_seg a,
													 fnd_id_flex_segments b,
													 fnd_id_flex_structures_vl c
			WHERE                a.co_code = p_co_code
			AND                  b.segment_num = a.segment_ref
			AND                  b.id_flex_num = p_coa_id
			AND                  b.enabled_flag = 'Y'
			AND                  b.id_flex_code = 'GL#'
			AND                  b.application_id = 101
			AND                  c.application_id = b.application_id
			AND                  c.id_flex_code = b.id_flex_code
			AND                  c.id_flex_num = b.id_flex_num
			ORDER BY             a.type,
													 a.segment_no;

			CURSOR               cur_account_unit_map
			(
			p_co_code           IN                VARCHAR2
			)
			IS
			SELECT               a.co_code,
													 a.orgn_code,
													 NVL(c.inventory_org_ind,'N') inventory_org_ind,
													 c.organization_id,
													 a.whse_code,
													 NVL(d.subinventory_ind_flag,'N') subinventory_ind_flag,
													 d.mtl_organization_id,
													 b.acctg_unit_id,
													 b.acctg_unit_no,
													 a.accu_map_id
			FROM                 gl_accu_map a,
													 gl_accu_mst b,
													 sy_orgn_mst c,
													 ic_whse_mst d
			WHERE                a.co_code = p_co_code
			AND                  b.acctg_unit_id = a.acctg_unit_id
			AND                  c.orgn_code(+) = a.orgn_code
			AND                  d.whse_code(+) = a.whse_code
		  AND                  nvl(a.migrated_ind,0) <> 1
			ORDER BY             a.co_code,
													 a.orgn_code NULLS LAST,
													 a.whse_code NULLS LAST;

			CURSOR               cur_whse_accu
			(
			p_orgn_code          IN                   VARCHAR2,
			p_co_code            IN                   VARCHAR2,
			p_acctg_unit_id      IN                   VARCHAR2
			)
			IS
			SELECT               a.whse_code,
													 a.whse_name,
													 NVL(a.subinventory_ind_flag,'N') subinventory_ind_flag,
													 a.mtl_organization_id
			FROM                 ic_whse_mst a
			WHERE                a.orgn_code = p_orgn_code
			AND                  NOT EXISTS
																		(
																		SELECT      'X'
																		FROM        gl_accu_map x
																		WHERE       x.whse_code = a.whse_code
																		AND         x.co_code = p_co_code
																		AND         x.orgn_code = a.orgn_code
																		AND         x.acctg_unit_id = p_acctg_unit_id
																		)
			ORDER BY             a.whse_code;

			CURSOR               cur_whse_acct
			(
			p_orgn_code          IN                   VARCHAR2,
			p_co_code            IN                   VARCHAR2,
			p_acct_id            IN                   VARCHAR2
			)
			IS
			SELECT               a.whse_code,
													 a.whse_name,
													 NVL(a.subinventory_ind_flag,'N') subinventory_ind_flag,
													 a.mtl_organization_id
			FROM                 ic_whse_mst a
			WHERE                a.orgn_code = p_orgn_code
			AND                  NOT EXISTS
																		(
																		SELECT      'X'
																		FROM        gl_acct_map x
																		WHERE       x.whse_code = a.whse_code
																		AND         x.co_code = p_co_code
																		AND         x.orgn_code = a.orgn_code
																		AND         x.acct_id = p_acct_id
																		)
			ORDER BY             a.whse_code;

			CURSOR               cur_sub_event_code
			(
			p_acct_ttl_type     IN      gl_acct_ttl.acct_ttl_type%TYPE
			)
			IS
			SELECT              DISTINCT c.sub_event_code,
													d.event_class_code,
													d.event_Type_code
			FROM                gl_sevt_ttl a,
													gl_sevt_mst c,
													gmf_xla_event_model d
			WHERE               a.acct_ttl_type = p_acct_ttl_type
			AND                 c.sub_event_type = a.sub_event_type
			AND                 c.sub_event_type = d.sub_event_type
      AND                 1 = 2; /* Stubbed to avoid migration for Line Assignments */

			/*********************
			* Local Sub-Programs *
			*********************/

			PROCEDURE            insert_conditions
			(
			p_condition_tag               IN                VARCHAR2,
			p_sequence                    IN OUT   NOCOPY   NUMBER,
			p_source                      IN                VARCHAR2,
			p_comparision_operator        IN                VARCHAR2,
			p_value_type                  IN                VARCHAR2,
			p_value                       IN                VARCHAR2,
			p_logical_operator            IN                VARCHAR2,
			p_segment_rule_detail_id      IN                NUMBER
			)
			IS
				 l_logical_operator_code                      VARCHAR2(1);
			BEGIN
				 IF p_condition_tag IN ('FIRST', 'ONLY') THEN
						p_sequence := 10;
						IF p_condition_tag = 'ONLY' THEN
							l_logical_operator_code := NULL;
						ELSE
							l_logical_operator_code := p_logical_operator;
						END IF;
				 ELSE
						p_sequence := nvl(p_sequence,0) + 10;
						IF p_condition_tag <> 'LAST' THEN
							l_logical_operator_code := p_logical_operator;
						END IF;
				 END IF;
				/***************************************
				* Loading XLA_CONDITIONS_T Structure   *
				***************************************/
				INSERT INTO xla_conditions_t
				(
				CONDITION_ID,
				APPLICATION_ID,
				AMB_CONTEXT_CODE,
				SEGMENT_RULE_DETAIL_ID,
				USER_SEQUENCE,
				BRACKET_LEFT_CODE,
				BRACKET_RIGHT_CODE,
				VALUE_TYPE_CODE,
				SOURCE_APPLICATION_ID,
				SOURCE_TYPE_CODE,
				SOURCE_CODE,
				FLEXFIELD_SEGMENT_CODE,
				VALUE_FLEXFIELD_SEGMENT_CODE,
				VALUE_SOURCE_APPLICATION_ID,
				VALUE_SOURCE_TYPE_CODE,
				VALUE_SOURCE_CODE,
				VALUE_CONSTANT,
				LINE_OPERATOR_CODE,
				LOGICAL_OPERATOR_CODE,
				INDEPENDENT_VALUE_CONSTANT,
				ERROR_VALUE
				)
				VALUES
				(
				xla_conditions_s.NEXTVAL,
				G_Application_id,
				l_amb_context,
				p_segment_rule_detail_id,
				p_sequence,
				NULL,
				NULL,
				p_value_type,
				G_Application_id,
				'S',
				p_source,
				NULL,
				NULL,
				NULL,
				NULL,
				NULL,
				p_value,
				p_comparision_operator,
				l_logical_operator_code,
				NULL,
				0
				);
			END insert_conditions;
	 BEGIN

			G_Migration_run_id := P_migration_run_id;
			G_Table_name := 'SLA_ADR_MIGRATION';
			G_Context := 'Account Mappings Migration';
			X_failure_count := 0;

			/********************************
			* Migration Started Log Message *
			********************************/
			GMA_COMMON_LOGGING.gma_migration_central_log
			(
			p_run_id             =>       G_migration_run_id,
			p_log_level          =>       FND_LOG.LEVEL_STATEMENT,
			p_message_token      =>       'GMA_MIGRATION_TABLE_STARTED',
			p_table_name         =>       G_Table_name,
			p_context            =>       G_Context,
			p_db_error           =>       NULL,
			p_app_short_name     =>       'GMA'
			);

      l_amb_context := 'DEFAULT';

      <<ACCOUNT_TITLES>>
			FOR k IN cur_account_title LOOP
				 <<LEGAL_ENTITIES>>
				 FOR i IN cur_legal_entities LOOP
						/***************************************************************************************************
						* Looping through Company Codes to migrate the Accounting Unit and Accounting Number Mappings once *
						***************************************************************************************************/
						BEGIN
							SELECT         count(1)
							INTO           l_acctg_unit_count
							FROM           gl_plcy_seg a
							WHERE          TYPE = 0
							AND            a.co_code = i.co_code;
						EXCEPTION
							WHEN OTHERS THEN
								l_acctg_unit_count := 0;
						END;
						<<POLICY_SEGMENTS>>
						FOR j IN cur_plcy_seg(p_co_code => i.co_code, p_coa_id => i.chart_of_accounts_id) LOOP
							IF j.TYPE = 0 THEN /* Accounting Unit Mapping */
									l_adr_rule_code := REPLACE( UPPER (SUBSTRB(i.short_name, 1, 14) ||'_'||k.acct_ttl_code||'_'||SUBSTRB(j.short_name, 1, 10)), ' ', '_');
									l_adr_rule_name := SUBSTRB(i.name, 1, 20 )||': ('|| k.acct_ttl_code ||') '|| SUBSTRB(k.acct_ttl_desc, 1, 25) ||' For '||SUBSTRB(j.short_name, 1, 10)||' Segment';
									xrt := 0;
									/********************************
									* Loading XLA_RULES_T GTMP      *
									********************************/
									BEGIN
										SELECT          count(*)
										INTO            xrt
										FROM            xla_rules_t
										WHERE           application_id = G_Application_id
										AND             segment_rule_code = l_adr_rule_code
										AND             amb_context_code = l_amb_context;
									EXCEPTION
										WHEN no_data_found THEN
											xrt := 0;
									END;
									IF nvl(xrt,0) = 0 THEN
										INSERT INTO xla_rules_t
										(
										APPLICATION_ID,
										AMB_CONTEXT_CODE,
										SEGMENT_RULE_TYPE_CODE,
										SEGMENT_RULE_CODE,
										TRANSACTION_COA_ID,
										ACCOUNTING_COA_ID,
										FLEXFIELD_ASSIGN_MODE_CODE,
										FLEXFIELD_SEGMENT_CODE,
										ENABLED_FLAG,
										NAME,
										DESCRIPTION,
										ERROR_VALUE
										)
										VALUES
										(
										G_Application_id,
										l_amb_context,
										'C',
										l_adr_rule_code,
										i.chart_of_accounts_id,
										i.chart_of_accounts_id,
										'S',
										j.application_column_name,
										'Y',
										l_adr_rule_name,
										'ADR for Ledger: '|| i.name ||' - JLT: ('|| k.acct_ttl_code ||') '||SUBSTRB(k.acct_ttl_desc, 1, 25)||' - Segment: '||j.short_name,
										0
										);
										l_adr_priority := 10;
									ELSE
										BEGIN
											SELECT        nvl(MAX(nvl(user_sequence,0)) + 10,10)
											INTO          l_adr_priority
											FROM          xla_rule_details_t
											WHERE         application_id = G_Application_id
											AND           segment_rule_code = l_adr_rule_code
											AND           amb_context_code = l_amb_context;
										EXCEPTION
											WHEN no_data_found THEN
												l_adr_priority := 10;
										END;
									END IF;
									<<SUB_EVENT_CODE_1>>
									FOR m IN cur_sub_event_code (k.acct_ttl_type) LOOP
										/***************************************
										* Loading XLA_LINE_ASSGNS_T Structure  *
										***************************************/
										BEGIN
											SELECT      count(*)
											INTO        xlat
											FROM        xla_line_assgns_t
											WHERE       application_id = G_Application_id
											AND         amb_context_code = l_amb_context
											AND         event_class_code = m.event_class_code
											AND         event_type_code = m.event_type_code
											AND         line_definition_code = m.event_type_code
											AND         accounting_line_code = k.acct_ttl_code
											AND         segment_rule_code = l_adr_rule_code
											AND         flexfield_segment_code = j.application_column_name;
										EXCEPTION
											WHEN no_data_found THEN
												xlat := 0;
										END;
										IF nvl(xlat,0) = 0 THEN
											INSERT INTO xla_line_assgns_t
											(
											APPLICATION_ID,
											AMB_CONTEXT_CODE,
											EVENT_CLASS_CODE,
											EVENT_TYPE_CODE,
											LINE_DEFINITION_OWNER_CODE,
											LINE_DEFINITION_CODE,
											ACCOUNTING_LINE_TYPE_CODE,
											ACCOUNTING_LINE_CODE,
											FLEXFIELD_SEGMENT_CODE,
											SEGMENT_RULE_TYPE_CODE,
											SEGMENT_RULE_CODE,
											ERROR_VALUE
											)
											VALUES
											(
											G_Application_id,
											l_amb_context,
											m.event_class_code,
											m.event_type_code,
											'C',
											m.event_type_code,
											'S',
											k.acct_ttl_code,
											j.application_column_name,
											'C',
											l_adr_rule_code,
											0
											);
										END IF;
									END LOOP SUB_EVENT_CODE_1;
									<<ACCOUNTING_UNITS>>
									FOR l IN cur_account_unit_map(p_co_code => i.co_code) LOOP
										 SELECT      substrb(a, decode(b-1, 0, 1, instr(a, c, 1, (b-1))+ 1), decode(instr(a, c, 1, b), 0, (length(a) - instr(a, c, 1, (b-1))+ 1), (instr(a, c, 1, b)) - decode(b-1, 0, 1, instr(a, c, 1, (b-1))+ 1)))
										 INTO        l_segment_value
										 FROM        (
																 SELECT      l.acctg_unit_no a,
																						 j.segment_no b,
																						 i.segment_delimiter c
																 FROM        dual
																 );
										/***************************************
										* Loading XLA_RULE_DETAILS_T Structure *
										***************************************/
										BEGIN
											SELECT        nvl(MAX(nvl(user_sequence,0)) + 10,10)
											INTO          l_adr_priority
											FROM          xla_rule_details_t
											WHERE         application_id = G_Application_id
											AND           segment_rule_code = l_adr_rule_code
											AND           amb_context_code = l_amb_context;
										EXCEPTION
											WHEN no_data_found THEN
												l_adr_priority := 10;
										END;
										l_segment_rule_detail_id := NULL;
										INSERT INTO xla_rule_details_t
										(
										APPLICATION_ID,
										AMB_CONTEXT_CODE,
										SEGMENT_RULE_TYPE_CODE,
										SEGMENT_RULE_CODE,
										SEGMENT_RULE_DETAIL_ID,
										USER_SEQUENCE,
										VALUE_TYPE_CODE,
										VALUE_SOURCE_APPLICATION_ID,
										VALUE_SOURCE_TYPE_CODE,
										VALUE_SOURCE_CODE,
										VALUE_CONSTANT,
										VALUE_CODE_COMBINATION_ID,
										VALUE_MAPPING_SET_CODE,
										VALUE_FLEXFIELD_SEGMENT_CODE,
										INPUT_SOURCE_APPLICATION_ID,
										INPUT_SOURCE_TYPE_CODE,
										INPUT_SOURCE_CODE,
										VALUE_SEGMENT_RULE_APPL_ID,
										VALUE_SEGMENT_RULE_TYPE_CODE,
										VALUE_SEGMENT_RULE_CODE,
										VALUE_ADR_VERSION_NUM,
										ERROR_VALUE
										)
										VALUES
										(
										G_Application_id,
										l_amb_context,
										'C',
										l_adr_rule_code,
										xla_seg_rule_details_s.NEXTVAL,
										l_adr_priority,
										'C',
										NULL,
										NULL,
										NULL,
										l_segment_value,
										NULL,
										NULL,
										NULL,
										NULL,
										NULL,
										NULL,
										NULL,
										NULL,
										NULL,
										NULL,
										0
										) returning segment_rule_detail_id INTO l_segment_rule_detail_id;
										IF l_segment_rule_detail_id IS NOT NULL THEN
											insert_conditions (
																				p_condition_tag               =>                'FIRST',
																				p_sequence                    =>                l_adr_condition_priority,
																				p_source                      =>                G_Journal_Line_Type,
																				p_comparision_operator        =>                G_Equal,
																				p_value_type                  =>                G_constant,
																				p_value                       =>                k.acct_ttl_code,
																				p_logical_operator            =>                G_And,
																				p_segment_rule_detail_id      =>                l_segment_rule_detail_id
																				);
											insert_conditions (
																				p_condition_tag               =>                'MID',
																				p_sequence                    =>                l_adr_condition_priority,
																				p_source                      =>                G_ledger_id,
																				p_comparision_operator        =>                G_Equal,
																				p_value_type                  =>                G_constant,
																				p_value                       =>                i.ledger_id,
																				p_logical_operator            =>                G_And,
																				p_segment_rule_detail_id      =>                l_segment_rule_detail_id
																				);
											insert_conditions (
																				p_condition_tag               =>                'MID',
																				p_sequence                    =>                l_adr_condition_priority,
																				p_source                      =>                G_legal_entity,
																				p_comparision_operator        =>                G_Equal,
																				p_value_type                  =>                G_constant,
																				p_value                       =>                i.legal_entity_id,
																				p_logical_operator            =>                G_And,
																				p_segment_rule_detail_id      =>                l_segment_rule_detail_id
																				);
											IF l.orgn_code IS NOT NULL THEN
												IF l.whse_code IS NOT NULL AND nvl(l.subinventory_ind_flag,'N') = 'Y' AND NVL(l.inventory_org_ind,'N') = 'Y' THEN
													/************************************************************
													* OPM Organizations is Migrated as inventory Organization   *
													************************************************************/
													insert_conditions (
																						p_condition_tag               =>                'MID',
																						p_sequence                    =>                l_adr_condition_priority,
																						p_source                      =>                G_Organization,
																						p_comparision_operator        =>                G_Equal,
																						p_value_type                  =>                G_constant,
																						p_value                       =>                l.organization_id,
																						p_logical_operator            =>                G_and,
																						p_segment_rule_detail_id       =>               l_segment_rule_detail_id
																						);
													 /*******************************************************************
													 * Warehouse Code Is specified and is migrated as subinventories    *
													 *******************************************************************/
													 insert_conditions (
																						 p_condition_tag               =>                'LAST',
																						 p_sequence                    =>                l_adr_condition_priority,
																						 p_source                      =>                G_subinventory,
																						 p_comparision_operator        =>                G_Equal,
																						 p_value_type                  =>                G_constant,
																						 p_value                       =>                l.whse_code,
																						 p_logical_operator            =>                NULL,
																						 p_segment_rule_detail_id      =>                l_segment_rule_detail_id
																						 );
												ELSIF l.whse_code IS NOT NULL AND nvl(l.subinventory_ind_flag,'N') <> 'Y' THEN
													/****************************************************************************
													* Warehouse Code Is specified and is migrated as Inventory Organizations    *
													****************************************************************************/
													 insert_conditions (
																						 p_condition_tag               =>                'LAST',
																						 p_sequence                    =>                l_adr_condition_priority,
																						 p_source                      =>                G_Organization,
																						 p_comparision_operator        =>                G_Equal,
																						 p_value_type                  =>                G_constant,
																						 p_value                       =>                l.mtl_organization_id,
																						 p_logical_operator            =>                NULL,
																						 p_segment_rule_detail_id      =>                l_segment_rule_detail_id
																						 );
												ELSE
													/*******************************************************************************************************
													* Warehouse Code Is not specified, so inserting a record for all warehouses under the OPM organization *
													*******************************************************************************************************/
													mcnt := 1;
													<<WAREHOUSE_ACCU>>
													FOR m IN cur_whse_accu (l.orgn_code, i.co_code, l.acctg_unit_id) LOOP
														IF m.mtl_organization_id <> nvl(l.organization_id, -1) THEN
															IF mcnt > 1 THEN
																BEGIN
																	SELECT        nvl(MAX(nvl(user_sequence,0)) + 10,10)
																	INTO          l_adr_priority
																	FROM          xla_rule_details_t
																	WHERE         application_id = G_Application_id
																	AND           segment_rule_code = l_adr_rule_code
																	AND           amb_context_code = l_amb_context;
																EXCEPTION
																	WHEN no_data_found THEN
																		l_adr_priority := 10;
																END;
																l_segment_rule_detail_id := NULL;
																INSERT INTO xla_rule_details_t
																(
																APPLICATION_ID,
																AMB_CONTEXT_CODE,
																SEGMENT_RULE_TYPE_CODE,
																SEGMENT_RULE_CODE,
																SEGMENT_RULE_DETAIL_ID,
																USER_SEQUENCE,
																VALUE_TYPE_CODE,
																VALUE_SOURCE_APPLICATION_ID,
																VALUE_SOURCE_TYPE_CODE,
																VALUE_SOURCE_CODE,
																VALUE_CONSTANT,
																VALUE_CODE_COMBINATION_ID,
																VALUE_MAPPING_SET_CODE,
																VALUE_FLEXFIELD_SEGMENT_CODE,
																INPUT_SOURCE_APPLICATION_ID,
																INPUT_SOURCE_TYPE_CODE,
																INPUT_SOURCE_CODE,
																VALUE_SEGMENT_RULE_APPL_ID,
																VALUE_SEGMENT_RULE_TYPE_CODE,
																VALUE_SEGMENT_RULE_CODE,
																VALUE_ADR_VERSION_NUM,
																ERROR_VALUE
																)
																VALUES
																(
																G_Application_id,
																l_amb_context,
																'C',
																l_adr_rule_code,
																xla_seg_rule_details_s.NEXTVAL,
																l_adr_priority,
																'C',
																NULL,
																NULL,
																NULL,
																l_segment_value,
																NULL,
																NULL,
																NULL,
																NULL,
																NULL,
																NULL,
																NULL,
																NULL,
																NULL,
																NULL,
																0
																) returning segment_rule_detail_id INTO l_segment_rule_detail_id;
																insert_conditions (
																									p_condition_tag               =>                'FIRST',
																									p_sequence                    =>                l_adr_condition_priority,
																									p_source                      =>                G_Journal_Line_Type,
																									p_comparision_operator        =>                G_Equal,
																									p_value_type                  =>                G_constant,
																									p_value                       =>                k.acct_ttl_code,
																									p_logical_operator            =>                G_And,
																									p_segment_rule_detail_id      =>                l_segment_rule_detail_id
																									);
																insert_conditions (
																									p_condition_tag               =>                'MID',
																									p_sequence                    =>                l_adr_condition_priority,
																									p_source                      =>                G_ledger_id,
																									p_comparision_operator        =>                G_Equal,
																									p_value_type                  =>                G_constant,
																									p_value                       =>                i.ledger_id,
																									p_logical_operator            =>                G_And,
																									p_segment_rule_detail_id      =>                l_segment_rule_detail_id
																									);
																insert_conditions (
																									p_condition_tag               =>                'MID',
																									p_sequence                    =>                l_adr_condition_priority,
																									p_source                      =>                G_legal_entity,
																									p_comparision_operator        =>                G_Equal,
																									p_value_type                  =>                G_constant,
																									p_value                       =>                i.legal_entity_id,
																									p_logical_operator            =>                G_And,
																									p_segment_rule_detail_id      =>                l_segment_rule_detail_id
																									);
															END IF;
															IF nvl(m.subinventory_ind_flag,'N') = 'Y' THEN
																/************************************************************
																* OPM Organizations is Migrated as inventory Organization   *
																************************************************************/
																insert_conditions (
																									p_condition_tag               =>                'MID',
																									p_sequence                    =>                l_adr_condition_priority,
																									p_source                      =>                G_Organization,
																									p_comparision_operator        =>                G_Equal,
																									p_value_type                  =>                G_constant,
																									p_value                       =>                l.organization_id,
																									p_logical_operator            =>                G_and,
																									p_segment_rule_detail_id       =>               l_segment_rule_detail_id
																									);
																 /*******************************************************************
																 * Warehouse Code Is specified and is migrated as subinventories    *
																 *******************************************************************/
																 insert_conditions (
																									 p_condition_tag               =>                'LAST',
																									 p_sequence                    =>                l_adr_condition_priority,
																									 p_source                      =>                G_subinventory,
																									 p_comparision_operator        =>                G_Equal,
																									 p_value_type                  =>                G_constant,
																									 p_value                       =>                m.whse_code,
																									 p_logical_operator            =>                NULL,
																									 p_segment_rule_detail_id      =>                l_segment_rule_detail_id
																									 );
															ELSIF nvl(m.subinventory_ind_flag,'N') <> 'Y' THEN
																/****************************************************************************
																* Warehouse Code Is specified and is migrated as Inventory Organizations    *
																****************************************************************************/
																insert_conditions  (
																									 p_condition_tag               =>                'LAST',
																									 p_sequence                    =>                l_adr_condition_priority,
																									 p_source                      =>                G_Organization,
																									 p_comparision_operator        =>                G_Equal,
																									 p_value_type                  =>                G_constant,
																									 p_value                       =>                m.mtl_organization_id,
																									 p_logical_operator            =>                NULL,
																									 p_segment_rule_detail_id      =>                l_segment_rule_detail_id
																									 );
															END IF;
															mcnt := nvl(mcnt,1) + 1;
														END IF;
													END LOOP WAREHOUSE_ACCU;
													IF NVL(l.inventory_org_ind,'N') = 'Y' AND nvl(mcnt, 1) > 1 THEN
														BEGIN
															SELECT        nvl(MAX(nvl(user_sequence,0)) + 10,10)
															INTO          l_adr_priority
															FROM          xla_rule_details_t
															WHERE         application_id = G_Application_id
															AND           segment_rule_code = l_adr_rule_code
															AND           amb_context_code = l_amb_context;
														EXCEPTION
															WHEN no_data_found THEN
																l_adr_priority := 10;
														END;
														 l_segment_rule_detail_id := NULL;
														 INSERT INTO xla_rule_details_t
														 (
														 APPLICATION_ID,
														 AMB_CONTEXT_CODE,
														 SEGMENT_RULE_TYPE_CODE,
														 SEGMENT_RULE_CODE,
														 SEGMENT_RULE_DETAIL_ID,
														 USER_SEQUENCE,
														 VALUE_TYPE_CODE,
														 VALUE_SOURCE_APPLICATION_ID,
														 VALUE_SOURCE_TYPE_CODE,
														 VALUE_SOURCE_CODE,
														 VALUE_CONSTANT,
														 VALUE_CODE_COMBINATION_ID,
														 VALUE_MAPPING_SET_CODE,
														 VALUE_FLEXFIELD_SEGMENT_CODE,
														 INPUT_SOURCE_APPLICATION_ID,
														 INPUT_SOURCE_TYPE_CODE,
														 INPUT_SOURCE_CODE,
														 VALUE_SEGMENT_RULE_APPL_ID,
														 VALUE_SEGMENT_RULE_TYPE_CODE,
														 VALUE_SEGMENT_RULE_CODE,
														 VALUE_ADR_VERSION_NUM,
														 ERROR_VALUE
														 )
														 VALUES
														 (
														 G_Application_id,
														 l_amb_context,
														 'C',
														 l_adr_rule_code,
														 xla_seg_rule_details_s.NEXTVAL,
														 l_adr_priority,
														 'C',
														 NULL,
														 NULL,
														 NULL,
														 l_segment_value,
														 NULL,
														 NULL,
														 NULL,
														 NULL,
														 NULL,
														 NULL,
														 NULL,
														 NULL,
														 NULL,
														 NULL,
														 0
														 ) returning segment_rule_detail_id INTO l_segment_rule_detail_id;
														 IF l_segment_rule_detail_id IS NOT NULL THEN
															 insert_conditions (
																								 p_condition_tag               =>                'FIRST',
																								 p_sequence                    =>                l_adr_condition_priority,
																								 p_source                      =>                G_Journal_Line_Type,
																								 p_comparision_operator        =>                G_Equal,
																								 p_value_type                  =>                G_constant,
																								 p_value                       =>                k.acct_ttl_code,
																								 p_logical_operator            =>                G_And,
																								 p_segment_rule_detail_id      =>                l_segment_rule_detail_id
																								 );
															 insert_conditions (
																								 p_condition_tag               =>                'MID',
																								 p_sequence                    =>                l_adr_condition_priority,
																								 p_source                      =>                G_ledger_id,
																								 p_comparision_operator        =>                G_Equal,
																								 p_value_type                  =>                G_constant,
																								 p_value                       =>                i.ledger_id,
																								 p_logical_operator            =>                G_And,
																								 p_segment_rule_detail_id      =>                l_segment_rule_detail_id
																								 );
															 insert_conditions (
																								 p_condition_tag               =>                'MID',
																								 p_sequence                    =>                l_adr_condition_priority,
																								 p_source                      =>                G_legal_entity,
																								 p_comparision_operator        =>                G_Equal,
																								 p_value_type                  =>                G_constant,
																								 p_value                       =>                i.legal_entity_id,
																								 p_logical_operator            =>                G_And,
																								 p_segment_rule_detail_id      =>                l_segment_rule_detail_id
																								 );
															 insert_conditions (
																								 p_condition_tag               =>                'LAST',
																								 p_sequence                    =>                l_adr_condition_priority,
																								 p_source                      =>                G_Organization,
																								 p_comparision_operator        =>                G_Equal,
																								 p_value_type                  =>                G_constant,
																								 p_value                       =>                l.organization_id,
																								 p_logical_operator            =>                NULL,
																								 p_segment_rule_detail_id      =>                l_segment_rule_detail_id
																								 );
														 END IF;
													ELSIF NVL(l.inventory_org_ind,'N') <> 'Y' THEN
														BEGIN
															UPDATE    xla_conditions_t
															SET       logical_operator_code = NULL
															WHERE     user_sequence = l_adr_condition_priority
															AND       segment_rule_detail_id = l_segment_rule_detail_id
															AND       amb_context_code = l_amb_context;
														EXCEPTION
															WHEN OTHERS THEN
																NULL;
														END;
													ELSE
														insert_conditions (
																							p_condition_tag               =>                'LAST',
																							p_sequence                    =>                l_adr_condition_priority,
																							p_source                      =>                G_Organization,
																							p_comparision_operator        =>                G_Equal,
																							p_value_type                  =>                G_constant,
																							p_value                       =>                l.organization_id,
																							p_logical_operator            =>                NULL,
																							p_segment_rule_detail_id      =>                l_segment_rule_detail_id
																							);
													END IF;
												 END IF;
											 ELSE
												 BEGIN
													 UPDATE    xla_conditions_t
													 SET       logical_operator_code = NULL
													 WHERE     user_sequence = l_adr_condition_priority
													 AND       segment_rule_detail_id = l_segment_rule_detail_id
													 AND       amb_context_code = l_amb_context;
												 EXCEPTION
													 WHEN OTHERS THEN
														 NULL;
												 END;
											 END IF;
										END IF;
									END LOOP ACCOUNTING_UNITS;
								ELSE /* Account Mapping */
									/***************************************
									* Migration of Account Number Mappings *
									***************************************/
									l_adr_rule_code := REPLACE (UPPER (SUBSTRB(i.short_name, 1, 14) ||'_'||k.acct_ttl_code||'_'||SUBSTRB(j.short_name, 1, 10)), ' ', '_');
                  l_adr_rule_name := SUBSTRB(i.name, 1, 20 )||': ('|| k.acct_ttl_code ||') '|| SUBSTRB(k.acct_ttl_desc, 1, 25) ||' For '||SUBSTRB(j.short_name, 1, 10)||' Segment';
									xrt := 0;
									/********************************
									* Loading XLA_RULES_T GTMP      *
									********************************/
									BEGIN
										SELECT          count(*)
										INTO            xrt
										FROM            xla_rules_t
										WHERE           application_id = G_Application_id
										AND             SEGMENT_RULE_CODE = l_adr_rule_code
										AND             amb_context_code = l_amb_context;
									EXCEPTION
										WHEN no_data_found THEN
											xrt := 0;
									END;
									IF nvl(xrt,0) = 0 THEN
										INSERT INTO xla_rules_t
										(
										APPLICATION_ID,
										AMB_CONTEXT_CODE,
										SEGMENT_RULE_TYPE_CODE,
										SEGMENT_RULE_CODE,
										TRANSACTION_COA_ID,
										ACCOUNTING_COA_ID,
										FLEXFIELD_ASSIGN_MODE_CODE,
										FLEXFIELD_SEGMENT_CODE,
										ENABLED_FLAG,
										NAME,
										DESCRIPTION,
										ERROR_VALUE
										)
										VALUES
										(
										G_Application_id,
										l_amb_context,
										'C',
										l_adr_rule_code,
										i.chart_of_accounts_id,
										i.chart_of_accounts_id,
										'S',
										j.application_column_name,
										'Y',
										l_adr_rule_name,
                    'ADR for Ledger: '|| i.name ||' - JLT: ('|| k.acct_ttl_code ||') '||SUBSTRB(k.acct_ttl_desc, 1, 25)||' - Segment: '||j.short_name,
										0
										);
										l_adr_priority := 10;
									ELSE
										BEGIN
											SELECT        nvl(MAX(nvl(user_sequence,0)) + 10,10)
											INTO          l_adr_priority
											FROM          xla_rule_details_t
											WHERE         application_id = G_Application_id
											AND           segment_rule_code = l_adr_rule_code
											AND           amb_context_code = l_amb_context;
										EXCEPTION
											WHEN no_data_found THEN
												l_adr_priority := 10;
										END;
									END IF;
									<<SUB_EVENT_CODE_2>>
									FOR m IN cur_sub_event_code (k.acct_ttl_type) LOOP
										/***************************************
										* Loading XLA_LINE_ASSGNS_T Structure  *
										***************************************/
										BEGIN
											SELECT      count(*)
											INTO        xlat
											FROM        xla_line_assgns_t
											WHERE       application_id = G_Application_id
											AND         amb_context_code = l_amb_context
											AND         event_class_code = m.event_class_code
											AND         event_type_code = m.event_type_code
											AND         line_definition_code = m.event_type_code
											AND         accounting_line_code = k.acct_ttl_code
											AND         segment_rule_code = l_adr_rule_code
											AND         flexfield_segment_code = j.application_column_name;
										EXCEPTION
											WHEN no_data_found THEN
												xlat := 0;
										END;
										IF nvl(xlat,0) = 0 THEN
											INSERT INTO xla_line_assgns_t
											(
											APPLICATION_ID,
											AMB_CONTEXT_CODE,
											EVENT_CLASS_CODE,
											EVENT_TYPE_CODE,
											LINE_DEFINITION_OWNER_CODE,
											LINE_DEFINITION_CODE,
											ACCOUNTING_LINE_TYPE_CODE,
											ACCOUNTING_LINE_CODE,
											FLEXFIELD_SEGMENT_CODE,
											SEGMENT_RULE_TYPE_CODE,
											SEGMENT_RULE_CODE,
											ERROR_VALUE
											)
											VALUES
											(
											G_Application_id,
											l_amb_context,
											m.event_class_code,
											m.event_type_code,
											'C',
											m.event_type_code,
											'S',
											k.acct_ttl_code,
											j.application_column_name,
											'C',
											l_adr_rule_code,
											0
											);
										END IF;
									END LOOP SUB_EVENT_CODE_2;
									X_sqlstmt :=  'SELECT     a.co_code,
																						a.orgn_code_pri,
																						a.whse_code_pri,
																						a.icgl_class_pri,
																						a.custgl_class_pri,
																						a.vendgl_class_pri ,
																						a.item_pri,
																						a.customer_pri,
																						a.vendor_pri,
																						a.tax_auth_pri,
																						a.charge_pri,
																						a.currency_code_pri,
																						a.reason_code_pri,
																						a.routing_pri,
																						a.aqui_cost_code_pri,
																						a.resource_pri,
																						a.cost_cmpntcls_pri,
																						a.cost_analysis_pri,
																						a.order_type_pri,
																						a.gl_business_class_pri,
																						a.gl_product_line_pri,
																						a.line_type_pri,
																						a.ar_trx_type_pri
																FROM        gl_acct_hrc a
																WHERE       a.acct_ttl_type = :p_acct_ttl_type
																AND         a.co_code = :p_co_code
																ORDER BY    1 desc';
									BEGIN
										EXECUTE   IMMEDIATE X_sqlstmt
										INTO      l_co_code1,       l_orgn_code_pri,        l_whse_code_pri,
															l_icgl_class_pri, l_custgl_class_pri,     l_vendgl_class_pri,
															l_item_pri,       l_customer_pri,         l_vendor_pri,
															l_tax_auth_pri,   l_charge_pri,           l_currency_code_pri,
															l_reason_code_pri,l_routing_pri,          l_aqui_cost_code_pri,
															l_resource_pri,   l_cost_cmpntcls_pri,    l_cost_analysis_pri,
															l_order_type_pri, l_gl_business_class_pri,l_gl_product_line_pri,
															l_line_type_pri,  l_ar_trx_type_pri
										 using    k.acct_ttl_type, i.co_code;
									EXCEPTION
										WHEN no_data_found THEN
											NULL;
									END;
									FOR z IN 1..23 LOOP
										X_order_tbl(z) := 0;
									END LOOP;
									X_my_order_by :=  ' ORDER BY 1';
									IF sql%rowcount > 0  THEN
										IF l_orgn_code_pri > 0 THEN
											x_tmp1:= l_orgn_code_pri + 1;
											X_order_tbl(x_tmp1) := 2;
										END IF;
										IF l_whse_code_pri > 0 THEN
											x_tmp1:= l_whse_code_pri + 1;
											X_order_tbl(x_tmp1) := 3;
										END IF;
										IF l_icgl_class_pri > 0 THEN
											x_tmp1:= l_icgl_class_pri + 1;
											X_order_tbl(x_tmp1) := 4;
										END IF;
										IF l_custgl_class_pri > 0 THEN
											x_tmp1:= l_custgl_class_pri + 1;
											X_order_tbl(x_tmp1) := 5;
										END IF;
										IF l_vendgl_class_pri > 0 THEN
											x_tmp1:= l_vendgl_class_pri + 1;
											X_order_tbl(x_tmp1) := 6;
										END IF;
										IF l_item_pri > 0 THEN
											x_tmp1:= l_item_pri + 1;
											X_order_tbl(x_tmp1) := 7;
										END IF;
										IF l_customer_pri > 0 THEN
											x_tmp1:= l_customer_pri + 1;
											X_order_tbl(x_tmp1) := 8;
										END IF;
										IF l_vendor_pri > 0 THEN
											x_tmp1:= l_vendor_pri + 1;
											X_order_tbl(x_tmp1) := 9;
										END IF;
										IF l_tax_auth_pri > 0 THEN
											x_tmp1:= l_tax_auth_pri + 1;
											X_order_tbl(x_tmp1) := 10;
										END IF;
										IF l_charge_pri > 0 THEN
											x_tmp1:= l_charge_pri + 1;
											X_order_tbl(x_tmp1) := 11;
										END IF;
										IF l_currency_code_pri > 0 THEN
											x_tmp1:= l_currency_code_pri + 1;
											X_order_tbl(x_tmp1) := 12;
										END IF;
										IF l_reason_code_pri > 0 THEN
											x_tmp1:= l_reason_code_pri + 1;
											X_order_tbl(x_tmp1) := 13;
										END IF;
										IF l_routing_pri > 0 THEN
											x_tmp1:= l_routing_pri + 1;
											X_order_tbl(x_tmp1) := 14;
										END IF;
										IF l_aqui_cost_code_pri > 0 THEN
											x_tmp1:= l_aqui_cost_code_pri + 1;
											X_order_tbl(x_tmp1) := 15;
										END IF;
										IF l_resource_pri > 0 THEN
											x_tmp1:= l_resource_pri + 1;
											X_order_tbl(x_tmp1) := 16;
										END IF;
										IF l_cost_cmpntcls_pri > 0 THEN
											x_tmp1:= l_cost_cmpntcls_pri + 1;
											X_order_tbl(x_tmp1) := 17;
										END IF;
										IF l_cost_analysis_pri > 0 THEN
											x_tmp1:= l_cost_analysis_pri + 1;
											X_order_tbl(x_tmp1) := 18;
										END IF;
										IF l_order_type_pri > 0 THEN
											x_tmp1:= l_order_type_pri + 1;
											X_order_tbl(x_tmp1) := 19;
										END IF;
										IF l_gl_business_class_pri > 0 THEN
											x_tmp1:= l_gl_business_class_pri + 1;
											X_order_tbl(x_tmp1) := 20;
										END IF;
										IF l_gl_product_line_pri > 0 THEN
											x_tmp1:= l_gl_product_line_pri + 1;
											X_order_tbl(x_tmp1) := 21;
										END IF;
										IF l_line_type_pri > 0 THEN
											x_tmp1:= l_line_type_pri + 1;
											X_order_tbl(x_tmp1) := 22;
										END IF;
										IF l_ar_trx_type_pri > 0 THEN
											x_tmp1:= l_ar_trx_type_pri + 1;
											X_order_tbl(x_tmp1) := 23;
										END IF;
									END IF;
									FOR z IN 2..23 LOOP
										IF X_order_tbl(z) > 0 THEN
											X_my_order_by := X_my_order_by||', '||to_char(x_order_tbl(z))||' NULLS LAST ';
										END IF;
									END LOOP;
									X_sqlcolumns:=  ' SELECT          a.co_code,
																										a.orgn_code,
																										a.whse_code,
																										a.gl_category_id,
																										a.custgl_class,
																										a.vendgl_class,
																										a.item_id,
																										a.cust_id,
																										a.vendor_id,
																										a.taxauth_id,
																										a.charge_id,
																										a.currency_code,
																										a.reason_code,
																										a.routing_id,
																										a.aqui_cost_id,
																										a.resources,
																										a.cost_cmpntcls_id,
																										a.cost_analysis_code,
																										a.order_type,
																										a.gl_business_class_cat_id,
																										a.gl_product_line_cat_id,
																										a.line_type,
																										a.ar_trx_type_id,
																										b.acct_id,
																										b.acct_no,
																										NVL(c.inventory_org_ind,''N'') inventory_org_ind,
																										NVL(d.subinventory_ind_flag,''N'') subinventory_ind_flag,
																										a.ROWID,
																										a.source_type,
																										c.organization_id,
																										d.mtl_organization_id ';
									X_sqlwhere := ' WHERE             a.acct_ttl_type = :p_acct_ttl_type
																	AND               a.co_code = :p_co_code
																	AND               a.co_code = b.co_code
																	AND               a.acct_id = b.acct_id
																	AND               c.orgn_code(+) = a.orgn_code
																	AND               d.whse_code(+) = a.whse_code
                                  AND               a.taxauth_id IS NULL
                                  AND               a.charge_id IS NULL
                                  AND               nvl(a.migrated_ind,0) <> 1 ';
									X_sqlordby:=      X_my_order_by;
									BEGIN
										EXECUTE IMMEDIATE     X_sqlcolumns  ||
																					' FROM        gl_acct_map a,
																												gl_acct_mst b,
																												sy_orgn_mst c,
																												ic_whse_mst d '
																												||
																												X_sqlwhere
																												||
																												X_sqlordby
										BULK COLLECT INTO     l_co_code,
																					l_orgn_code,
																					l_whse_code,
																					l_gl_category_id,
																					l_custgl_class,
																					l_vendgl_class,
																					l_item_id,
																					l_cust_id,
																					l_vendor_id,
																					l_taxauth_id,
																					l_charge_id,
																					l_currency_code,
																					l_reason_code,
																					l_routing_id,
																					l_aqui_cost_id,
																					l_resources,
																					l_cost_cmpntcls_id,
																					l_cost_analysis_code,
																					l_order_type,
																					l_gl_business_class_cat_id,
																					l_gl_product_line_cat_id,
																					l_line_type,
																					l_ar_trx_type_id,
																					l_acct_id,
																					l_acct_no,
																					l_inventory_org_ind,
																					l_subinventory_ind_flag,
																					l_rowid,
																					l_source_type,
																					l_organization_id,
																					l_mtl_organization_id
										USING                 k.acct_ttl_type,
																					i.co_code;
									EXCEPTION
										WHEN no_data_found THEN
											NULL;
									END;
									IF nvl(l_rowid.count,0) > 0 THEN
										<<GL_ACCT_MAP>>
										FOR m in l_rowid.FIRST..l_rowid.LAST LOOP
											SELECT      substrb(a, decode(b-1, 0, 1, instr(a, c, 1, (b-1))+ 1), decode(instr(a, c, 1, b), 0, (length(a) - instr(a, c, 1, (b-1))+ 1), (instr(a, c, 1, b)) - decode(b-1, 0, 1, instr(a, c, 1, (b-1))+ 1)))
											INTO        l_segment_value
											FROM        (
																	SELECT      l_acct_no(m) a,
																							(j.segment_no - l_acctg_unit_count) b,
																							i.segment_delimiter c
																	FROM        dual
																	);
											/***************************************
											* Loading XLA_RULE_DETAILS_T Structure *
											***************************************/
											BEGIN
												SELECT        NVL(MAX(nvl(user_sequence,0)) + 10,10)
												INTO          l_adr_priority
												FROM          xla_rule_details_t
												WHERE         application_id = G_Application_id
												AND           segment_rule_code = l_adr_rule_code
												AND           amb_context_code = l_amb_context;
											EXCEPTION
												WHEN no_data_found THEN
													l_adr_priority := 10;
											END;
											l_segment_rule_detail_id := NULL;
											INSERT INTO xla_rule_details_t
											(
											APPLICATION_ID,
											AMB_CONTEXT_CODE,
											SEGMENT_RULE_TYPE_CODE,
											SEGMENT_RULE_CODE,
											SEGMENT_RULE_DETAIL_ID,
											USER_SEQUENCE,
											VALUE_TYPE_CODE,
											VALUE_SOURCE_APPLICATION_ID,
											VALUE_SOURCE_TYPE_CODE,
											VALUE_SOURCE_CODE,
											VALUE_CONSTANT,
											VALUE_CODE_COMBINATION_ID,
											VALUE_MAPPING_SET_CODE,
											VALUE_FLEXFIELD_SEGMENT_CODE,
											INPUT_SOURCE_APPLICATION_ID,
											INPUT_SOURCE_TYPE_CODE,
											INPUT_SOURCE_CODE,
											VALUE_SEGMENT_RULE_APPL_ID,
											VALUE_SEGMENT_RULE_TYPE_CODE,
											VALUE_SEGMENT_RULE_CODE,
											VALUE_ADR_VERSION_NUM,
											ERROR_VALUE
											)
											VALUES
											(
											G_Application_id,
											l_amb_context,
											'C',
											l_adr_rule_code,
											xla_seg_rule_details_s.NEXTVAL,
											l_adr_priority,
											'C',
											NULL,
											NULL,
											NULL,
											l_segment_value,
											NULL,
											NULL,
											NULL,
											NULL,
											NULL,
											NULL,
											NULL,
											NULL,
											NULL,
											NULL,
											0
											) returning segment_rule_detail_id INTO l_segment_rule_detail_id;
											IF l_segment_rule_detail_id IS NOT NULL THEN
												insert_conditions (
																					p_condition_tag               =>                'FIRST',
																					p_sequence                    =>                l_adr_condition_priority,
																					p_source                      =>                G_Journal_Line_Type,
																					p_comparision_operator        =>                G_Equal,
																					p_value_type                  =>                G_constant,
																					p_value                       =>                k.acct_ttl_code,
																					p_logical_operator            =>                G_And,
																					p_segment_rule_detail_id      =>                l_segment_rule_detail_id
																					);
												insert_conditions (
																					p_condition_tag               =>                'MID',
																					p_sequence                    =>                l_adr_condition_priority,
																					p_source                      =>                G_ledger_id,
																					p_comparision_operator        =>                G_Equal,
																					p_value_type                  =>                G_constant,
																					p_value                       =>                i.ledger_id,
																					p_logical_operator            =>                G_And,
																					p_segment_rule_detail_id      =>                l_segment_rule_detail_id
																					);
												insert_conditions (
																					p_condition_tag               =>                'MID',
																					p_sequence                    =>                l_adr_condition_priority,
																					p_source                      =>                G_legal_entity,
																					p_comparision_operator        =>                G_Equal,
																					p_value_type                  =>                G_constant,
																					p_value                       =>                i.legal_entity_id,
																					p_logical_operator            =>                G_And,
																					p_segment_rule_detail_id      =>                l_segment_rule_detail_id
																					);
												IF l_gl_category_id(m) IS NOT NULL THEN
													insert_conditions (
																						p_condition_tag               =>                'MID',
																						p_sequence                    =>                l_adr_condition_priority,
																						p_source                      =>                G_gl_category_id,
																						p_comparision_operator        =>                G_Equal,
																						p_value_type                  =>                G_constant,
																						p_value                       =>                l_gl_category_id(m),
																						p_logical_operator            =>                G_And,
																						p_segment_rule_detail_id      =>                l_segment_rule_detail_id
																						);
												END IF;
												IF l_custgl_class(m) IS NOT NULL THEN
													insert_conditions (
																						p_condition_tag               =>                'MID',
																						p_sequence                    =>                l_adr_condition_priority,
																						p_source                      =>                G_custgl_class,
																						p_comparision_operator        =>                G_Equal,
																						p_value_type                  =>                G_constant,
																						p_value                       =>                l_custgl_class(m),
																						p_logical_operator            =>                G_And,
																						p_segment_rule_detail_id      =>                l_segment_rule_detail_id
																						);
												END IF;
												IF l_vendgl_class(m) IS NOT NULL THEN
													insert_conditions (
																						p_condition_tag               =>                'MID',
																						p_sequence                    =>                l_adr_condition_priority,
																						p_source                      =>                G_vendgl_class,
																						p_comparision_operator        =>                G_Equal,
																						p_value_type                  =>                G_constant,
																						p_value                       =>                l_vendgl_class(m),
																						p_logical_operator            =>                G_And,
																						p_segment_rule_detail_id      =>                l_segment_rule_detail_id
																						);
												END IF;
												IF l_item_id(m) IS NOT NULL THEN
													l_inventory_item_id := gmf_migration.get_inventory_item_id(p_item_id => l_item_id(m));
													IF l_inventory_item_id IS NOT NULL THEN
														insert_conditions (
																							p_condition_tag               =>                'MID',
																							p_sequence                    =>                l_adr_condition_priority,
																							p_source                      =>                G_Inventory_item_id,
																							p_comparision_operator        =>                G_Equal,
																							p_value_type                  =>                G_constant,
																							p_value                       =>                l_inventory_item_id,
																							p_logical_operator            =>                G_And,
																							p_segment_rule_detail_id      =>                l_segment_rule_detail_id
																							);
													END IF;
												END IF;
												IF l_cust_id(m) IS NOT NULL THEN
													insert_conditions (
																						p_condition_tag               =>                'MID',
																						p_sequence                    =>                l_adr_condition_priority,
																						p_source                      =>                G_customer,
																						p_comparision_operator        =>                G_Equal,
																						p_value_type                  =>                G_constant,
																						p_value                       =>                l_cust_id(m),
																						p_logical_operator            =>                G_And,
																						p_segment_rule_detail_id      =>                l_segment_rule_detail_id
																						);
												END IF;
												IF l_vendor_id(m) IS NOT NULL THEN
                          l_vendor_site_id := Get_Vendor_id (p_vendor_id => l_vendor_id(m));
                          IF l_vendor_site_id IS NOT NULL THEN
  													insert_conditions (
  																						p_condition_tag               =>                'MID',
  																						p_sequence                    =>                l_adr_condition_priority,
  																						p_source                      =>                G_vendor,
  																						p_comparision_operator        =>                G_Equal,
  																						p_value_type                  =>                G_constant,
  																						p_value                       =>                l_vendor_site_id,
  																						p_logical_operator            =>                G_And,
  																						p_segment_rule_detail_id      =>                l_segment_rule_detail_id
  																						);
                          END IF;
												END IF;
												IF l_currency_code(m) IS NOT NULL THEN
													insert_conditions (
																						p_condition_tag               =>                'MID',
																						p_sequence                    =>                l_adr_condition_priority,
																						p_source                      =>                G_currency_code,
																						p_comparision_operator        =>                G_Equal,
																						p_value_type                  =>                G_constant,
																						p_value                       =>                l_currency_code(m),
																						p_logical_operator            =>                G_And,
																						p_segment_rule_detail_id      =>                l_segment_rule_detail_id
																						);
												END IF;
												IF l_reason_code(m) IS NOT NULL THEN
													l_reason_id := gmf_migration.Get_reason_id(p_reason_code => l_reason_code(m));
													IF l_reason_id IS NOT NULL THEN
														insert_conditions (
																							p_condition_tag               =>                'MID',
																							p_sequence                    =>                l_adr_condition_priority,
																							p_source                      =>                G_reason_id,
																							p_comparision_operator        =>                G_Equal,
																							p_value_type                  =>                G_constant,
																							p_value                       =>                l_reason_id,
																							p_logical_operator            =>                G_And,
																							p_segment_rule_detail_id      =>                l_segment_rule_detail_id
																							);
													END IF;
												END IF;
												IF l_routing_id(m) IS NOT NULL THEN
													insert_conditions (
																						p_condition_tag               =>                'MID',
																						p_sequence                    =>                l_adr_condition_priority,
																						p_source                      =>                G_routing_id,
																						p_comparision_operator        =>                G_Equal,
																						p_value_type                  =>                G_constant,
																						p_value                       =>                l_routing_id(m),
																						p_logical_operator            =>                G_And,
																						p_segment_rule_detail_id      =>                l_segment_rule_detail_id
																						);
												END IF;
												IF l_aqui_cost_id(m) IS NOT NULL THEN
													l_price_element_type_id := gmf_migration.Get_price_element_type_id(p_aqui_cost_id => l_aqui_cost_id(m));
													IF l_price_element_type_id IS NOT NULL THEN
														insert_conditions (
																							p_condition_tag               =>                'MID',
																							p_sequence                    =>                l_adr_condition_priority,
																							p_source                      =>                G_price_element_type_id,
																							p_comparision_operator        =>                G_Equal,
																							p_value_type                  =>                G_constant,
																							p_value                       =>                l_price_element_type_id,
																							p_logical_operator            =>                G_And,
																							p_segment_rule_detail_id      =>                l_segment_rule_detail_id
																							);
													END IF;
												END IF;
												IF l_resources(m) IS NOT NULL THEN
													insert_conditions (
																						p_condition_tag               =>                'MID',
																						p_sequence                    =>                l_adr_condition_priority,
																						p_source                      =>                G_resources,
																						p_comparision_operator        =>                G_Equal,
																						p_value_type                  =>                G_constant,
																						p_value                       =>                l_resources(m),
																						p_logical_operator            =>                G_And,
																						p_segment_rule_detail_id      =>                l_segment_rule_detail_id
																						);
												END IF;
												IF l_cost_cmpntcls_id(m) IS NOT NULL THEN
													insert_conditions (
																						p_condition_tag               =>                'MID',
																						p_sequence                    =>                l_adr_condition_priority,
																						p_source                      =>                G_cost_cmpntcls_id,
																						p_comparision_operator        =>                G_Equal,
																						p_value_type                  =>                G_constant,
																						p_value                       =>                l_cost_cmpntcls_id(m),
																						p_logical_operator            =>                G_And,
																						p_segment_rule_detail_id      =>                l_segment_rule_detail_id
																						);
												END IF;
												IF l_cost_analysis_code(m) IS NOT NULL THEN
													insert_conditions (
																						p_condition_tag               =>                'MID',
																						p_sequence                    =>                l_adr_condition_priority,
																						p_source                      =>                G_cost_analysis_code,
																						p_comparision_operator        =>                G_Equal,
																						p_value_type                  =>                G_constant,
																						p_value                       =>                l_cost_analysis_code(m),
																						p_logical_operator            =>                G_And,
																						p_segment_rule_detail_id      =>                l_segment_rule_detail_id
																						);
												END IF;
												IF l_order_type(m) IS NOT NULL THEN
													insert_conditions (
																						p_condition_tag               =>                'MID',
																						p_sequence                    =>                l_adr_condition_priority,
																						p_source                      =>                G_order_type,
																						p_comparision_operator        =>                G_Equal,
																						p_value_type                  =>                G_constant,
																						p_value                       =>                l_order_type(m),
																						p_logical_operator            =>                G_And,
																						p_segment_rule_detail_id      =>                l_segment_rule_detail_id
																						);
												END IF;
												IF l_gl_business_class_cat_id(m) IS NOT NULL THEN
													insert_conditions (
																						p_condition_tag               =>                'MID',
																						p_sequence                    =>                l_adr_condition_priority,
																						p_source                      =>                G_gl_business_class_cat_id,
																						p_comparision_operator        =>                G_Equal,
																						p_value_type                  =>                G_constant,
																						p_value                       =>                l_gl_business_class_cat_id(m),
																						p_logical_operator            =>                G_And,
																						p_segment_rule_detail_id      =>                l_segment_rule_detail_id
																						);
												END IF;
												IF l_gl_product_line_cat_id(m) IS NOT NULL THEN
													insert_conditions (
																						p_condition_tag               =>                'MID',
																						p_sequence                    =>                l_adr_condition_priority,
																						p_source                      =>                G_gl_product_line_cat_id,
																						p_comparision_operator        =>                G_Equal,
																						p_value_type                  =>                G_constant,
																						p_value                       =>                l_gl_product_line_cat_id(m),
																						p_logical_operator            =>                G_And,
																						p_segment_rule_detail_id      =>                l_segment_rule_detail_id
																						);
												END IF;
												IF l_line_type(m) IS NOT NULL THEN
													insert_conditions (
																						p_condition_tag               =>                'MID',
																						p_sequence                    =>                l_adr_condition_priority,
																						p_source                      =>                G_line_type,
																						p_comparision_operator        =>                G_Equal,
																						p_value_type                  =>                G_constant,
																						p_value                       =>                l_line_type(m),
																						p_logical_operator            =>                G_And,
																						p_segment_rule_detail_id      =>                l_segment_rule_detail_id
																						);
												END IF;
												IF l_ar_trx_type_id(m) IS NOT NULL THEN
													insert_conditions (
																						p_condition_tag               =>                'MID',
																						p_sequence                    =>                l_adr_condition_priority,
																						p_source                      =>                G_ar_trx_type,
																						p_comparision_operator        =>                G_Equal,
																						p_value_type                  =>                G_constant,
																						p_value                       =>                l_ar_trx_type_id(m),
																						p_logical_operator            =>                G_And,
																						p_segment_rule_detail_id      =>                l_segment_rule_detail_id
																						);
												END IF;
												IF l_orgn_code(m) IS NOT NULL THEN
													IF l_whse_code(m) IS NOT NULL AND nvl(l_subinventory_ind_flag(m),'N') = 'Y' AND NVL(l_inventory_org_ind(m),'N') = 'Y' THEN
														/************************************************************
														* OPM Organizations is Migrated as inventory Organization   *
														************************************************************/
														insert_conditions (
																							p_condition_tag               =>                'MID',
																							p_sequence                    =>                l_adr_condition_priority,
																							p_source                      =>                G_Organization,
																							p_comparision_operator        =>                G_Equal,
																							p_value_type                  =>                G_constant,
																							p_value                       =>                l_organization_id(m),
																							p_logical_operator            =>                G_and,
																							p_segment_rule_detail_id       =>               l_segment_rule_detail_id
																							);
														 /*******************************************************************
														 * Warehouse Code Is specified and is migrated as subinventories    *
														 *******************************************************************/
														 insert_conditions (
																							 p_condition_tag               =>                'LAST',
																							 p_sequence                    =>                l_adr_condition_priority,
																							 p_source                      =>                G_subinventory,
																							 p_comparision_operator        =>                G_Equal,
																							 p_value_type                  =>                G_constant,
																							 p_value                       =>                l_whse_code(m),
																							 p_logical_operator            =>                NULL,
																							 p_segment_rule_detail_id      =>                l_segment_rule_detail_id
																							 );
													ELSIF l_whse_code(m) IS NOT NULL AND nvl(l_subinventory_ind_flag(m),'N') <> 'Y' THEN
														insert_conditions (
																							p_condition_tag               =>                'LAST',
																							p_sequence                    =>                l_adr_condition_priority,
																							p_source                      =>                G_Organization,
																							p_comparision_operator        =>                G_Equal,
																							p_value_type                  =>                G_constant,
																							p_value                       =>                l_mtl_organization_id(m),
																							p_logical_operator            =>                G_and,
																							p_segment_rule_detail_id       =>               l_segment_rule_detail_id
																							);
													ELSE
														l_old_segment_rule_detail_id := l_segment_rule_detail_id;
														l_old_adr_condition_priority := l_adr_condition_priority;
														mcnt := 1;
														<<WAREHOUSE_ACCOUNT>>
														FOR n IN cur_whse_acct(l_orgn_code(m), i.co_code, l_acct_id(m)) LOOP
															IF n.mtl_organization_id <> nvl(l_organization_id(m), -1) THEN
																IF mcnt > 1 THEN
																	BEGIN
																		SELECT          NVL(MAX(nvl(user_sequence,0)) + 10,10)
																		INTO            l_adr_priority
																		FROM            xla_rule_details_t
																		WHERE           application_id = G_Application_id
																		AND             segment_rule_code = l_adr_rule_code
																		AND             amb_context_code = l_amb_context;
																	EXCEPTION
																		WHEN no_data_found THEN
																			l_adr_priority := 10;
																	END;
																	INSERT INTO xla_rule_details_t
																	(
																	APPLICATION_ID,
																	AMB_CONTEXT_CODE,
																	SEGMENT_RULE_TYPE_CODE,
																	SEGMENT_RULE_CODE,
																	SEGMENT_RULE_DETAIL_ID,
																	USER_SEQUENCE,
																	VALUE_TYPE_CODE,
																	VALUE_SOURCE_APPLICATION_ID,
																	VALUE_SOURCE_TYPE_CODE,
																	VALUE_SOURCE_CODE,
																	VALUE_CONSTANT,
																	VALUE_CODE_COMBINATION_ID,
																	VALUE_MAPPING_SET_CODE,
																	VALUE_FLEXFIELD_SEGMENT_CODE,
																	INPUT_SOURCE_APPLICATION_ID,
																	INPUT_SOURCE_TYPE_CODE,
																	INPUT_SOURCE_CODE,
																	VALUE_SEGMENT_RULE_APPL_ID,
																	VALUE_SEGMENT_RULE_TYPE_CODE,
																	VALUE_SEGMENT_RULE_CODE,
																	VALUE_ADR_VERSION_NUM,
																	ERROR_VALUE
																	)
																	VALUES
																	(
																	G_Application_id,
																	l_amb_context,
																	'C',
																	l_adr_rule_code,
																	xla_seg_rule_details_s.NEXTVAL,
																	l_adr_priority,
																	'C',
																	NULL,
																	NULL,
																	NULL,
																	l_segment_value,
																	NULL,
																	NULL,
																	NULL,
																	NULL,
																	NULL,
																	NULL,
																	NULL,
																	NULL,
																	NULL,
																	NULL,
																	0
																	) returning segment_rule_detail_id INTO l_segment_rule_detail_id;
																	INSERT INTO xla_conditions_t
																	(
																	CONDITION_ID,
																	APPLICATION_ID,
																	AMB_CONTEXT_CODE,
																	SEGMENT_RULE_DETAIL_ID,
																	USER_SEQUENCE,
																	BRACKET_LEFT_CODE,
																	BRACKET_RIGHT_CODE,
																	VALUE_TYPE_CODE,
																	SOURCE_APPLICATION_ID,
																	SOURCE_TYPE_CODE,
																	SOURCE_CODE,
																	FLEXFIELD_SEGMENT_CODE,
																	VALUE_FLEXFIELD_SEGMENT_CODE,
																	VALUE_SOURCE_APPLICATION_ID,
																	VALUE_SOURCE_TYPE_CODE,
																	VALUE_SOURCE_CODE,
																	VALUE_CONSTANT,
																	LINE_OPERATOR_CODE,
																	LOGICAL_OPERATOR_CODE,
																	INDEPENDENT_VALUE_CONSTANT,
																	ERROR_VALUE
																	)
																	(
																	SELECT          xla_conditions_s.NEXTVAL,
																									APPLICATION_ID,
																									AMB_CONTEXT_CODE,
																									l_segment_rule_detail_id,
																									USER_SEQUENCE,
																									BRACKET_LEFT_CODE,
																									BRACKET_RIGHT_CODE,
																									VALUE_TYPE_CODE,
																									SOURCE_APPLICATION_ID,
																									SOURCE_TYPE_CODE,
																									SOURCE_CODE,
																									FLEXFIELD_SEGMENT_CODE,
																									VALUE_FLEXFIELD_SEGMENT_CODE,
																									VALUE_SOURCE_APPLICATION_ID,
																									VALUE_SOURCE_TYPE_CODE,
																									VALUE_SOURCE_CODE,
																									VALUE_CONSTANT,
																									LINE_OPERATOR_CODE,
																									LOGICAL_OPERATOR_CODE,
																									INDEPENDENT_VALUE_CONSTANT,
																									ERROR_VALUE
																	FROM            xla_conditions_t
																	WHERE           segment_rule_detail_id = l_old_segment_rule_detail_id
																	AND             amb_context_code = l_amb_context
																	AND             user_sequence <= l_old_adr_condition_priority
																	);
																	l_adr_condition_priority := l_old_adr_condition_priority;
																END IF;
																IF nvl(n.subinventory_ind_flag,'N') = 'Y' THEN
																	/************************************************************
																	* OPM Organizations is Migrated as inventory Organization   *
																	************************************************************/
																	insert_conditions (
																										p_condition_tag               =>                'MID',
																										p_sequence                    =>                l_adr_condition_priority,
																										p_source                      =>                G_Organization,
																										p_comparision_operator        =>                G_Equal,
																										p_value_type                  =>                G_constant,
																										p_value                       =>                l_organization_id(m),
																										p_logical_operator            =>                G_and,
																										p_segment_rule_detail_id       =>               l_segment_rule_detail_id
																										);
																	 /*******************************************************************
																	 * Warehouse Code Is specified and is migrated as subinventories    *
																	 *******************************************************************/
																	 insert_conditions (
																										 p_condition_tag               =>                'LAST',
																										 p_sequence                    =>                l_adr_condition_priority,
																										 p_source                      =>                G_subinventory,
																										 p_comparision_operator        =>                G_Equal,
																										 p_value_type                  =>                G_constant,
																										 p_value                       =>                n.whse_code,
																										 p_logical_operator            =>                NULL,
																										 p_segment_rule_detail_id      =>                l_segment_rule_detail_id
																										 );
																ELSIF nvl(n.subinventory_ind_flag,'N') <> 'Y' THEN
																	insert_conditions (
																										p_condition_tag               =>                'LAST',
																										p_sequence                    =>                l_adr_condition_priority,
																										p_source                      =>                G_Organization,
																										p_comparision_operator        =>                G_Equal,
																										p_value_type                  =>                G_constant,
																										p_value                       =>                n.mtl_organization_id,
																										p_logical_operator            =>                G_and,
																										p_segment_rule_detail_id       =>               l_segment_rule_detail_id
																										);
																END IF;
																mcnt := nvl(mcnt,1) + 1;
															END IF;
														END LOOP WAREHOUSE_ACCOUNT;
														IF NVL(l_inventory_org_ind(m),'N') = 'Y' AND nvl(mcnt, 1) > 1 THEN
															BEGIN
																SELECT        NVL(MAX(nvl(user_sequence,0)) + 10,10)
																INTO          l_adr_priority
																FROM          xla_rule_details_t
																WHERE         application_id = G_Application_id
																AND           segment_rule_code = l_adr_rule_code
																AND           amb_context_code = l_amb_context;
															EXCEPTION
																WHEN no_data_found THEN
																	l_adr_priority := 10;
															END;
															l_segment_rule_detail_id := NULL;
															INSERT INTO xla_rule_details_t
															(
															APPLICATION_ID,
															AMB_CONTEXT_CODE,
															SEGMENT_RULE_TYPE_CODE,
															SEGMENT_RULE_CODE,
															SEGMENT_RULE_DETAIL_ID,
															USER_SEQUENCE,
															VALUE_TYPE_CODE,
															VALUE_SOURCE_APPLICATION_ID,
															VALUE_SOURCE_TYPE_CODE,
															VALUE_SOURCE_CODE,
															VALUE_CONSTANT,
															VALUE_CODE_COMBINATION_ID,
															VALUE_MAPPING_SET_CODE,
															VALUE_FLEXFIELD_SEGMENT_CODE,
															INPUT_SOURCE_APPLICATION_ID,
															INPUT_SOURCE_TYPE_CODE,
															INPUT_SOURCE_CODE,
															VALUE_SEGMENT_RULE_APPL_ID,
															VALUE_SEGMENT_RULE_TYPE_CODE,
															VALUE_SEGMENT_RULE_CODE,
															VALUE_ADR_VERSION_NUM,
															ERROR_VALUE
															)
															VALUES
															(
															G_Application_id,
															l_amb_context,
															'C',
															l_adr_rule_code,
															xla_seg_rule_details_s.NEXTVAL,
															l_adr_priority,
															'C',
															NULL,
															NULL,
															NULL,
															l_segment_value,
															NULL,
															NULL,
															NULL,
															NULL,
															NULL,
															NULL,
															NULL,
															NULL,
															NULL,
															NULL,
															0
															) returning segment_rule_detail_id INTO l_segment_rule_detail_id;
															INSERT INTO xla_conditions_t
															(
															CONDITION_ID,
															APPLICATION_ID,
															AMB_CONTEXT_CODE,
															SEGMENT_RULE_DETAIL_ID,
															USER_SEQUENCE,
															BRACKET_LEFT_CODE,
															BRACKET_RIGHT_CODE,
															VALUE_TYPE_CODE,
															SOURCE_APPLICATION_ID,
															SOURCE_TYPE_CODE,
															SOURCE_CODE,
															FLEXFIELD_SEGMENT_CODE,
															VALUE_FLEXFIELD_SEGMENT_CODE,
															VALUE_SOURCE_APPLICATION_ID,
															VALUE_SOURCE_TYPE_CODE,
															VALUE_SOURCE_CODE,
															VALUE_CONSTANT,
															LINE_OPERATOR_CODE,
															LOGICAL_OPERATOR_CODE,
															INDEPENDENT_VALUE_CONSTANT,
															ERROR_VALUE
															)
															(
															SELECT          xla_conditions_s.NEXTVAL,
																							APPLICATION_ID,
																							AMB_CONTEXT_CODE,
																							l_segment_rule_detail_id,
																							USER_SEQUENCE,
																							BRACKET_LEFT_CODE,
																							BRACKET_RIGHT_CODE,
																							VALUE_TYPE_CODE,
																							SOURCE_APPLICATION_ID,
																							SOURCE_TYPE_CODE,
																							SOURCE_CODE,
																							FLEXFIELD_SEGMENT_CODE,
																							VALUE_FLEXFIELD_SEGMENT_CODE,
																							VALUE_SOURCE_APPLICATION_ID,
																							VALUE_SOURCE_TYPE_CODE,
																							VALUE_SOURCE_CODE,
																							VALUE_CONSTANT,
																							LINE_OPERATOR_CODE,
																							LOGICAL_OPERATOR_CODE,
																							INDEPENDENT_VALUE_CONSTANT,
																							ERROR_VALUE
															FROM            xla_conditions_t
															WHERE           segment_rule_detail_id = l_old_segment_rule_detail_id
															AND             amb_context_code = l_amb_context
															AND             user_sequence <= l_old_adr_condition_priority
															);
															l_adr_condition_priority := l_old_adr_condition_priority;
															insert_conditions (
																								p_condition_tag               =>                'LAST',
																								p_sequence                    =>                l_adr_condition_priority,
																								p_source                      =>                G_Organization,
																								p_comparision_operator        =>                G_Equal,
																								p_value_type                  =>                G_constant,
																								p_value                       =>                l_organization_id(m),
																								p_logical_operator            =>                G_and,
																								p_segment_rule_detail_id       =>               l_segment_rule_detail_id
																								);
														ELSIF NVL(l_inventory_org_ind(m),'N') <> 'Y' THEN
															BEGIN
																UPDATE    xla_conditions_t
																SET       logical_operator_code = NULL
																WHERE     user_sequence = l_adr_condition_priority
																AND       segment_rule_detail_id = l_segment_rule_detail_id
																AND       amb_context_code = l_amb_context;
															EXCEPTION
																WHEN OTHERS THEN
																	NULL;
															END;
														ELSE
															insert_conditions (
																								p_condition_tag               =>                'LAST',
																								p_sequence                    =>                l_adr_condition_priority,
																								p_source                      =>                G_Organization,
																								p_comparision_operator        =>                G_Equal,
																								p_value_type                  =>                G_constant,
																								p_value                       =>                l_organization_id(m),
																								p_logical_operator            =>                G_and,
																								p_segment_rule_detail_id       =>               l_segment_rule_detail_id
																								);
														END IF;
													END IF;
												ELSE
													BEGIN
														UPDATE    xla_conditions_t
														SET       logical_operator_code = NULL
														WHERE     user_sequence = l_adr_condition_priority
														AND       segment_rule_detail_id = l_segment_rule_detail_id
														AND       amb_context_code = l_amb_context;
													EXCEPTION
														WHEN OTHERS THEN
															NULL;
													END;
												END IF;
										END IF;
									END LOOP GL_ACCT_MAP;
								END IF;
							END IF;
						END LOOP POLICY_SEGMENTS;
						BEGIN
							UPDATE    gl_acct_map
							SET       migrated_ind = 1
							WHERE     co_code = i.co_code
							AND       acct_ttl_type = k.acct_ttl_type;
						EXCEPTION
							WHEN OTHERS THEN
								RAISE;
						END;
				 END LOOP LEGAL_ENTITIES;
			END LOOP ACCOUNT_TITLE;
      BEGIN
				UPDATE    GL_ACCU_MAP
				SET       MIGRATED_IND = 1;
			EXCEPTION
				WHEN OTHERS THEN
					RAISE;
			END;
			/******************************************************
			* Upload Data IN XLA interface tables into XLA tables *
			******************************************************/
			xla_adr_interface_pkg.upload_rules;
			/****************************************************************
			* Lets save the changes now based on the commit parameter       *
			****************************************************************/
			IF NVL(p_commit,'~') = FND_API.G_TRUE THEN
				COMMIT;
			END IF;
			/************************************
			* ADR Rules Migration Error Logging *
			************************************/
			gmf_migration.G_Table_name := 'XLA_RULES_T';
			gmf_migration.G_context := 'GMF Error Logging';
			gmf_migration.Log_Errors  (
																p_log_level               =>          1,
																p_from_rowid              =>          NULL,
																p_to_rowid                =>          NULL
																);
			/*******************************************
			* ADR Rule Details Migration Error Logging *
			*******************************************/
			gmf_migration.G_Table_name := 'XLA_RULE_DETAILS_T';
			gmf_migration.G_context := 'GMF Error Logging';
			gmf_migration.Log_Errors  (
																p_log_level               =>          1,
																p_from_rowid              =>          NULL,
																p_to_rowid                =>          NULL
																);
			/*****************************************
			* ADR Conditions Migration Error Logging *
			*****************************************/
			gmf_migration.G_Table_name := 'XLA_CONDITIONS_T';
			gmf_migration.G_context := 'GMF Error Logging';
			gmf_migration.Log_Errors  (
																p_log_level               =>          1,
																p_from_rowid              =>          NULL,
																p_to_rowid                =>          NULL
																);
			/***********************************************
			* ADR Line Assignments Migration Error Logging *
			***********************************************/
			gmf_migration.G_Table_name := 'XLA_LINE_ASSGNS_T';
			gmf_migration.G_context := 'GMF Error Logging';
			gmf_migration.Log_Errors  (
																p_log_level               =>          1,
																p_from_rowid              =>          NULL,
																p_to_rowid                =>          NULL
																);
	EXCEPTION
		WHEN OTHERS THEN
			/************************************************
			* Increment Failure Count for Failed Migrations *
			************************************************/
			x_failure_count := x_failure_count + 1;
			/**************************************
			* Migration DB Error Log Message      *
			**************************************/
			GMA_COMMON_LOGGING.gma_migration_central_log
			(
			p_run_id             =>       G_migration_run_id,
			p_log_level          =>       FND_LOG.LEVEL_ERROR,
			p_message_token      =>       'GMA_MIGRATION_DB_ERROR',
			p_table_name         =>       G_Table_name,
			p_context            =>       G_Context,
			p_db_error           =>       SQLERRM,
			p_app_short_name     =>       'GMA'
			);
			/**************************************
			* Migration Failure Log Message       *
			**************************************/
			GMA_COMMON_LOGGING.gma_migration_central_log
			(
			p_run_id             =>       G_migration_run_id,
			p_log_level          =>       FND_LOG.LEVEL_ERROR,
			p_message_token      =>       'GMA_TABLE_MIGRATION_TABLE_FAIL',
			p_table_name         =>       G_Table_name,
			p_context            =>       G_Context,
			p_db_error           =>       NULL,
			p_app_short_name     =>       'GMA'
			);
	 END Migrate_Account_Mappings;

	 /**********************************************************************
	 * PROCEDURE:                                                          *
	 *   Migrate_Acquisition_codes                                         *
	 *                                                                     *
	 * DESCRIPTION:                                                        *
	 *   This PL/SQL procedure is used to migrate the Acquisition Codes    *
	 *                                                                     *
	 * PARAMETERS:                                                         *
	 *   P_migration_run_id - id to use to right to migration log          *
	 *   x_exception_count  - Number of exceptions occurred.               *
	 *                                                                     *
	 * SYNOPSIS:                                                           *
	 *   Migrate_Acquisition_Codes(p_migartion_id    => l_migration_id,    *
	 *                    p_commit          => 'T',                        *
	 *                    x_exception_count => l_exception_count );        *
	 *                                                                     *
	 * HISTORY                                                             *
	 *       27-Apr-2005 Created  Anand Thiyagarajan                       *
	 *                                                                     *
	 **********************************************************************/
	 PROCEDURE Migrate_Acquisition_Codes
	 (
	 P_migration_run_id      IN             NUMBER,
	 P_commit                IN             VARCHAR2,
	 X_failure_count         OUT   NOCOPY   NUMBER
	 )
	 IS

			/**************************
			* PL/SQL Table Definition *
			**************************/

			TYPE t_rowid IS TABLE OF ROWID INDEX BY BINARY_INTEGER;
			TYPE t_price_element_type_id IS TABLE OF PO_COST_MST.PRICE_ELEMENT_TYPE_ID%TYPE INDEX BY BINARY_INTEGER;
			TYPE t_aqui_cost_code IS TABLE OF PO_COST_MST.AQUI_COST_CODE%TYPE INDEX BY BINARY_INTEGER;
			TYPE t_aqui_cost_desc IS TABLE OF PO_COST_MST.AQUI_COST_DESC%TYPE INDEX BY BINARY_INTEGER;
			TYPE t_cmpntcls_id IS TABLE OF PO_COST_MST.CMPNTCLS_ID%TYPE INDEX BY BINARY_INTEGER;
			TYPE t_analysis_code IS TABLE OF PO_COST_MST.ANALYSIS_CODE%TYPE INDEX BY BINARY_INTEGER;
			TYPE t_incl_ind IS TABLE OF PO_COST_MST.INCL_IND%TYPE INDEX BY BINARY_INTEGER;

			/******************
			* Local Variables *
			******************/

			l_rowid                             t_rowid;
			l_aqui_cost_code                    t_aqui_cost_code;
			l_aqui_cost_desc                    t_aqui_cost_desc;
			l_cmpntcls_id                       t_cmpntcls_id;
			l_analysis_code                     t_analysis_code;
			l_incl_ind                          t_incl_ind;
			l_price_element_type_id             t_price_element_type_id;

			l_exception_count                   NUMBER := 0;
			l_pricing_basis                     VARCHAR2(10);
			l_cost_acquisition_code             VARCHAR2(1);
			l_return_status                     VARCHAR2(1);
			l_msg_data                          VARCHAR2(2000);
			l_msg_count                         NUMBER;
			l_insert_update_flag                VARCHAR2(10);

	 BEGIN

			G_Migration_run_id := P_migration_run_id;
			G_Table_name := 'PO_COST_MST';
			G_Context := 'Acquisiton Codes Migration';
			X_failure_count := 0;

			/********************************
			* Migration Started Log Message *
			********************************/

			GMA_COMMON_LOGGING.gma_migration_central_log
			(
			p_run_id             =>       G_migration_run_id,
			p_log_level          =>       FND_LOG.LEVEL_STATEMENT,
			p_message_token      =>       'GMA_MIGRATION_TABLE_STARTED',
			p_table_name         =>       G_Table_name,
			p_context            =>       G_context,
			p_db_error           =>       NULL,
			p_app_short_name     =>       'GMA'
			);

			SELECT               ROWID,
													 aqui_cost_code,
													 aqui_cost_desc,
													 cmpntcls_id,
													 analysis_code,
													 incl_ind
			BULK COLLECT INTO    l_rowid,
													 l_aqui_cost_code,
													 l_aqui_cost_desc,
													 l_cmpntcls_id,
													 l_analysis_code,
													 l_incl_ind
			FROM                 po_cost_mst
			WHERE                price_element_type_id IS NULL;

			l_pricing_basis := 'PER_UNIT';

			IF SQL%FOUND THEN

				 FOR i IN l_rowid.FIRST..l_rowid.LAST LOOP

						CASE l_incl_ind(i)
							 WHEN 1 THEN
								 l_cost_acquisition_code := 'I';
							 WHEN 0 THEN
								 l_cost_acquisition_code := 'E';
							 ELSE
								 l_cost_acquisition_code := 'I';
						END CASE;

						PON_CF_TYPE_GRP.opm_create_update_cost_factor
						(
						p_api_version               =>             1.0
						, p_price_element_code      =>             l_aqui_cost_code(i)
						, p_pricing_basis           =>             'PER_UNIT'
						, p_cost_component_class_id =>             l_cmpntcls_id(i)
						, p_cost_analysis_code      =>             l_analysis_code(i)
						, p_cost_acquisition_code   =>             l_cost_acquisition_code
						, p_name                    =>             l_aqui_cost_code(i)
						, p_description             =>             l_aqui_cost_desc(i)
						, x_insert_update_action    =>             l_insert_update_flag
						, x_price_element_type_id   =>             l_price_element_type_id(i)
						, x_pricing_basis           =>             l_pricing_basis
						, x_return_status           =>             l_return_status
						, x_msg_data                =>             l_msg_data
						, x_msg_count               =>             l_msg_count
						);

				 END LOOP;

				 FORALL j IN indices OF l_rowid SAVE EXCEPTIONS
						UPDATE      po_cost_mst
						SET         migrated_ind = 1,
												price_element_type_id = l_price_element_type_id(j)
						WHERE       ROWID = l_rowid(j)
						AND         price_element_type_id IS NULL;

				 l_exception_count := nvl(l_exception_count,0) + SQL%BULK_EXCEPTIONS.COUNT;

				 FOR i IN 1..SQL%BULK_EXCEPTIONS.COUNT LOOP

						/************************************************
						* Increment Failure Count for Failed Migrations *
						************************************************/

						x_failure_count := x_failure_count + 1;

						/**************************************
						* Migration DB Error Log Message      *
						**************************************/

						GMA_COMMON_LOGGING.gma_migration_central_log
						(
						p_run_id             =>       G_migration_run_id,
						p_log_level          =>       FND_LOG.LEVEL_ERROR,
						p_message_token      =>       'GMA_MIGRATION_DB_ERROR',
						p_table_name         =>       G_Table_name,
						p_context            =>       G_context,
						p_db_error           =>       SQLERRM(SQL%BULK_EXCEPTIONS(i).ERROR_CODE),
						p_app_short_name     =>       'GMA'
						);

						/**************************************
						* Migration Failure Log Message       *
						**************************************/

						GMA_COMMON_LOGGING.gma_migration_central_log
						(
						p_run_id             =>       G_migration_run_id,
						p_log_level          =>       FND_LOG.LEVEL_ERROR,
						p_message_token      =>       'GMA_TABLE_MIGRATION_TABLE_FAIL',
						p_table_name         =>       G_Table_name,
						p_context            =>       G_context,
						p_app_short_name     =>       'GMA'
						);

				 END LOOP;

				 /**********************************************
				 * Handle all the rows which were not migrated *
				 **********************************************/

				 SELECT               count(*)
				 INTO                 x_failure_count
				 FROM                 po_cost_mst
				 WHERE                price_element_type_id IS NULL;

				 IF nvl(x_failure_count,0) > 0 THEN

					 /**************************************
					 * Migration Failure Log Message       *
					 **************************************/

					 GMA_COMMON_LOGGING.gma_migration_central_log
					 (
					 p_run_id             =>       gmf_migration.G_migration_run_id,
					 p_log_level          =>       FND_LOG.LEVEL_PROCEDURE,
					 p_message_token      =>       'GMA_TABLE_MIGRATION_TABLE_FAIL',
					 p_table_name         =>       gmf_migration.G_Table_name,
					 p_context            =>       gmf_migration.G_context,
					 p_db_error           =>       NULL,
					 p_app_short_name     =>       'GMA'
					 );

				 ELSE

					 /**************************************
					 * Migration Success Log Message       *
					 **************************************/

					 GMA_COMMON_LOGGING.gma_migration_central_log
					 (
					 p_run_id             =>       G_migration_run_id,
					 p_log_level          =>       FND_LOG.LEVEL_STATEMENT,
					 p_message_token      =>       'GMA_MIGRATION_TABLE_SUCCESS',
					 p_table_name         =>       G_Table_name,
					 p_context            =>       G_Context,
					 p_param1             =>       1,
					 p_param2             =>       0,
					 p_db_error           =>       NULL,
					 p_app_short_name     =>       'GMA'
					 );

				 END IF;

				 /****************************************************************
				 * Lets save the changes now based on the commit parameter       *
				 ****************************************************************/

				 IF NVL(p_commit,'~') = FND_API.G_TRUE THEN
						COMMIT;
				 END IF;

			END IF;

	 EXCEPTION
			WHEN OTHERS THEN

				 /************************************************
				 * Increment Failure Count for Failed Migrations *
				 ************************************************/

				 x_failure_count := x_failure_count + 1;

				 /**************************************
				 * Migration DB Error Log Message      *
				 **************************************/

				 GMA_COMMON_LOGGING.gma_migration_central_log
				 (
				 p_run_id             =>       G_migration_run_id,
				 p_log_level          =>       FND_LOG.LEVEL_ERROR,
				 p_message_token      =>       'GMA_MIGRATION_DB_ERROR',
				 p_table_name         =>       G_Table_name,
				 p_context            =>       G_context,
				 p_db_error           =>       SQLERRM,
				 p_app_short_name     =>       'GMA'
				 );

				 /**************************************
				 * Migration Failure Log Message       *
				 **************************************/

				 GMA_COMMON_LOGGING.gma_migration_central_log
				 (
				 p_run_id             =>       G_migration_run_id,
				 p_log_level          =>       FND_LOG.LEVEL_ERROR,
				 p_message_token      =>       'GMA_TABLE_MIGRATION_TABLE_FAIL',
				 p_table_name         =>       G_Table_name,
				 p_context            =>       G_context,
				 p_db_error           =>       NULL,
				 p_app_short_name     =>       'GMA'
				 );

	 END Migrate_Acquisition_Codes;

	 /**********************************************************************
	 * PROCEDURE:                                                          *
	 *   Migrate_Period_Balances                                           *
	 *                                                                     *
	 * DESCRIPTION:                                                        *
	 *   This PL/SQL procedure is used to migrate the Period Balances      *
	 *                                                                     *
	 * PARAMETERS:                                                         *
	 *   P_migration_run_id - id to use to right to migration log          *
	 *   x_exception_count  - Number of exceptions occurred.               *
	 *                                                                     *
	 * SYNOPSIS:                                                           *
	 *   Migrate_Period_Balances(p_migartion_id    => l_migration_id,      *
	 *                    p_commit          => 'T',                        *
	 *                    x_exception_count => l_exception_count );        *
	 *                                                                     *
	 * HISTORY                                                             *
	 *       27-Apr-2005 Created  Anand Thiyagarajan                       *
	 *                                                                     *
	 **********************************************************************/
	 PROCEDURE Migrate_Period_Balances
	 (
	 P_migration_run_id      IN             NUMBER,
	 P_commit                IN             VARCHAR2,
	 X_failure_count         OUT   NOCOPY   NUMBER
	 )
	 IS

			/**************************
			* PL/SQL Table Definition *
			**************************/

			/******************
			* Local Variables *
			******************/

			l_perd_bal_count                    NUMBER := 0;

			/**********
			* Cursors *
			**********/

			CURSOR               cur_orgn_periods
			IS
			SELECT   DISTINCT    a.orgn_code,
													 e.whse_code,
													 NVL(e.subinventory_ind_flag,'N') subinventory_ind_flag,
													 DECODE(NVL(e.subinventory_ind_flag,'N'), 'Y', e.organization_id, e.mtl_organization_id) organization_id,
													 d.acct_period_id,
													 d.period_start_date,
													 d.schedule_close_date,
													 b.period_id curr_period_id,
													 b.period_end_date curr_period_end_date,
													 c.period_id prior_period_id,
													 c.period_end_date prior_period_end_date,
													 c.closed_period_ind prior_period_closed_ind
			FROM                 sy_orgn_mst a,
													 ic_cldr_dtl b,
													 ic_cldr_dtl c,
													 org_acct_periods d,
													 hr_organization_information hoi,
													 ic_whse_mst e,
													 gl_ledgers f
			WHERE                a.orgn_code = b.orgn_code
			AND                  c.orgn_code = a.orgn_code
			AND                  e.orgn_code = a.orgn_code
			AND                  d.organization_id = e.cost_organization_id
			AND                  hoi.organization_id = d.organization_id
			AND                  hoi.org_information_context = 'Accounting Information'
			AND                  hoi.org_information1 = f.ledger_id
			AND                  f.period_set_name = d.period_Set_name
			AND                  c.period_end_date = d.schedule_close_date
			AND                  nvl(c.closed_period_ind, 1) = 3
			AND                  b.period_end_date =  (
																								SELECT      MIN(x.period_end_date)
																								FROM        ic_cldr_dtl x
																								WHERE       a.orgn_code = x.orgn_code
																								AND         SYSDATE < x.period_end_date
																								)
			AND                  c.period_end_date =  (
																								SELECT      MAX(y.period_end_date)
																								FROM        ic_cldr_dtl y
																								WHERE       a.orgn_code = y.orgn_code
																								AND         SYSDATE > y.period_end_Date
																								);

	 BEGIN

			G_Migration_run_id := P_migration_run_id;
			G_Table_name := 'GMF_PERIOD_BALANCES';
			G_Context := 'Period Balances Migration';
			X_failure_count := 0;

			/********************************
			* Migration Started Log Message *
			********************************/

			GMA_COMMON_LOGGING.gma_migration_central_log
			(
			p_run_id             =>       G_migration_run_id,
			p_log_level          =>       FND_LOG.LEVEL_STATEMENT,
			p_message_token      =>       'GMA_MIGRATION_TABLE_STARTED',
			p_table_name         =>       G_Table_name,
			p_context            =>       G_context,
			p_db_error           =>       NULL,
			p_app_short_name     =>       'GMA'
			);

			<<WAREHOUSES>>
			FOR i IN cur_orgn_periods LOOP

				 SELECT            count(1)
				 INTO              l_perd_bal_count
				 FROM              ic_perd_bal
				 WHERE             whse_code = i.whse_code
				 AND               period_id = i.prior_period_id;

				 INSERT   INTO     gmf_period_balances
				 (
				 period_balance_id,
				 acct_period_id,
				 organization_id,
				 cost_group_id,
				 subinventory_code,
				 inventory_item_id,
				 lot_number,
				 locator_id,
				 primary_quantity,
				 secondary_quantity,
				 intransit_primary_quantity,
				 intransit_secondary_quantity,
				 accounted_value,
				 intransit_accounted_value,
				 costed_flag,
				 creation_date,
				 created_by,
				 last_update_date,
				 last_updated_by,
				 last_update_login,
				 request_id,
				 program_application_id,
				 program_id,
				 program_update_date
				 )
				 (
				 SELECT            gmf_period_balances_s.NEXTVAL,
													 i.acct_period_id,
													 i.organization_id,
													 decode(i.subinventory_ind_flag, 'N', NULL, e.default_cost_group_id),
													 decode(i.subinventory_ind_flag, 'N', NULL, e.secondary_inventory_name),
													 b.inventory_item_id,
													 c.lot_number,
													 d.inventory_location_id,
													 a.loct_onhand,
													 a.loct_onhand2,
													 0,
													 0,
													 a.loct_value,
													 0,
													 NULL,
													 SYSDATE,
													 1,
													 SYSDATE,
													 1,
													 1,
													 NULL,
													 NULL,
													 NULL,
													 NULL
				 FROM              ic_perd_bal a,
													 ic_item_mst_b_mig b,
													 ic_lots_mst_mig c,
													 ic_loct_mst d,
													 mtl_secondary_inventories e
				 WHERE             a.whse_code = i.whse_code
				 AND               a.period_id = i.prior_period_id
				 AND               b.organization_id = i.organization_id
				 AND               e.secondary_inventory_name(+) = i.whse_code
				 AND               e.organization_id(+) = i.organization_id
				 AND               b.item_id = a.item_id
				 AND               c.item_id = a.item_id
				 AND               c.lot_id = a.lot_id
				 AND               c.whse_code = a.whse_code
				 AND               c.location = a.location
				 AND               d.whse_code = a.whse_code
				 AND               d.location = a.location
				 AND               NOT EXISTS (
																			SELECT            'X'
																			FROM              gmf_period_balances x
																			WHERE             x.acct_period_id = i.acct_period_id
																			AND               x.organization_id = i.organization_id
																			AND               x.inventory_item_id = b.inventory_item_id
																			AND               nvl(x.subinventory_code, '~') = nvl(decode(i.subinventory_ind_flag, 'N', NULL, e.secondary_inventory_name), '~')
																			AND               nvl(x.lot_number,'~') = nvl(c.lot_number, '~')
																			AND               nvl(x.locator_id, -1) = nvl(d.inventory_location_id, -1)
																			)
				 );

				 IF l_perd_bal_count = SQL%ROWCOUNT THEN

						/**********************************************************************
						* Handle the periods for which the period balances have been migrated *
						**********************************************************************/

						UPDATE               org_acct_periods
						SET                  period_close_date = SYSDATE,
																 open_flag = 'N',
																 summarized_flag = 'Y'
						WHERE                acct_period_id = i.prior_period_id
						AND                  organization_id = i.organization_id;

				 ELSE

						/**********************************************
						* Handle all the rows which were not migrated *
						**********************************************/

						SELECT               count(*)
						INTO                 x_failure_count
						FROM                 ic_perd_bal
						WHERE                whse_code = i.whse_code
						AND                  period_id = i.prior_period_id;

						IF nvl(x_failure_count,0) > 0 THEN

							/**************************************
							* Migration Failure Log Message       *
							**************************************/

							GMA_COMMON_LOGGING.gma_migration_central_log
							(
							p_run_id             =>       gmf_migration.G_migration_run_id,
							p_log_level          =>       FND_LOG.LEVEL_PROCEDURE,
							p_message_token      =>       'GMA_TABLE_MIGRATION_TABLE_FAIL',
							p_table_name         =>       gmf_migration.G_Table_name,
							p_context            =>       gmf_migration.G_context,
							p_db_error           =>       NULL,
							p_app_short_name     =>       'GMA'
							);

						ELSE

							/**************************************
							* Migration Success Log Message       *
							**************************************/

							GMA_COMMON_LOGGING.gma_migration_central_log
							(
							p_run_id             =>       G_migration_run_id,
							p_log_level          =>       FND_LOG.LEVEL_STATEMENT,
							p_message_token      =>       'GMA_MIGRATION_TABLE_SUCCESS',
							p_table_name         =>       G_Table_name,
							p_context            =>       G_Context,
							p_param1             =>       1,
							p_param2             =>       0,
							p_db_error           =>       NULL,
							p_app_short_name     =>       'GMA'
							);

						END IF;

				 END IF;

			END LOOP WAREHOUSES;

			/**************************************
			* Migration Success Log Message       *
			**************************************/

			GMA_COMMON_LOGGING.gma_migration_central_log
			(
			p_run_id             =>       G_migration_run_id,
			p_log_level          =>       FND_LOG.LEVEL_STATEMENT,
			p_message_token      =>       'GMA_MIGRATION_TABLE_SUCCESS',
			p_table_name         =>       G_Table_name,
			p_context            =>       G_context,
			p_param1             =>       1,
			p_param2             =>       0,
			p_db_error           =>       NULL,
			p_app_short_name     =>       'GMA'
			);

			/****************************************************************
			* Lets save the changes now based on the commit parameter       *
			****************************************************************/

			IF NVL(p_commit,'~') = FND_API.G_TRUE THEN
				 COMMIT;
			END IF;

	 EXCEPTION
			WHEN OTHERS THEN

				 /************************************************
				 * Increment Failure Count for Failed Migrations *
				 ************************************************/

				 x_failure_count := x_failure_count + 1;

				 /**************************************
				 * Migration DB Error Log Message      *
				 **************************************/

				 GMA_COMMON_LOGGING.gma_migration_central_log
				 (
				 p_run_id             =>       G_migration_run_id,
				 p_log_level          =>       FND_LOG.LEVEL_ERROR,
				 p_message_token      =>       'GMA_MIGRATION_DB_ERROR',
				 p_table_name         =>       G_Table_name,
				 p_context            =>       G_context,
				 p_db_error           =>       SQLERRM,
				 p_app_short_name     =>       'GMA'
				 );

				 /**************************************
				 * Migration Failure Log Message       *
				 **************************************/

				 GMA_COMMON_LOGGING.gma_migration_central_log
				 (
				 p_run_id             =>       G_migration_run_id,
				 p_log_level          =>       FND_LOG.LEVEL_ERROR,
				 p_message_token      =>       'GMA_TABLE_MIGRATION_TABLE_FAIL',
				 p_table_name         =>       G_Table_name,
				 p_context            =>       G_context,
				 p_db_error           =>       NULL,
				 p_app_short_name     =>       'GMA'
				 );

	 END Migrate_Period_Balances;

	 /**********************************************************************
	 * PROCEDURE:                                                          *
	 *   Migrate_Allocation_Inputs                                         *
	 *                                                                     *
	 * DESCRIPTION:                                                        *
	 *   This PL/SQL procedure is used to migrate the Expense Allocation   *
	 *   Input Records used for Account Balance maintenance                *
	 *                                                                     *
	 * PARAMETERS:                                                         *
	 *   P_migration_run_id - id to use to right to migration log          *
	 *   x_exception_count  - Number of exceptions occurred.               *
	 *                                                                     *
	 * SYNOPSIS:                                                           *
	 *   Migrate_Allocation_Inputs(p_migartion_id    => l_migration_id,    *
	 *                    p_commit          => 'T',                        *
	 *                    x_exception_count => l_exception_count );        *
	 *                                                                     *
	 * HISTORY                                                             *
	 *       27-Apr-2005 Created  Anand Thiyagarajan                       *
	 *                                                                     *
	 **********************************************************************/
	 PROCEDURE Migrate_Allocation_Inputs
	 (
	 P_migration_run_id      IN             NUMBER,
	 P_commit                IN             VARCHAR2,
	 X_failure_count         OUT   NOCOPY   NUMBER
	 )
	 IS

			/***************************
			* PL/SQL Table Definitions *
			***************************/

			/******************
			* Local Variables *
			******************/

	 BEGIN

			G_Migration_run_id := P_migration_run_id;
			G_Table_name := 'GL_ALOC_INP';
			G_Context := 'Expense Allocation Inputs Migration';
			X_failure_count := 0;

			/********************************
			* Migration Started Log Message *
			********************************/

			GMA_COMMON_LOGGING.gma_migration_central_log
			(
			p_run_id             =>       G_migration_run_id,
			p_log_level          =>       FND_LOG.LEVEL_STATEMENT,
			p_message_token      =>       'GMA_MIGRATION_TABLE_STARTED',
			p_table_name         =>       G_Table_name,
			p_context            =>       G_context,
			p_db_error           =>       NULL,
			p_app_short_name     =>       'GMA'
			);

			/**********************************************************
			* Update a row in GL_ALOC_INP for Account Codes           *
			**********************************************************/

			BEGIN

				 UPDATE         gl_aloc_inp a
				 SET            a.account_id  =  (
																			 SELECT      gmf_migration.get_account_id(a.account_key, x.co_code)
																			 FROM        gl_aloc_mst x
																			 WHERE       x.alloc_id = a.alloc_id
																			 )
				 WHERE          (account_id IS NULL AND a.account_key IS NOT NULL);

			EXCEPTION

				 WHEN OTHERS THEN

						/************************************************
						* Increment Failure Count for Failed Migrations *
						************************************************/

						x_failure_count := x_failure_count + 1;

						/**************************************
						* Migration DB Error Log Message      *
						**************************************/

						GMA_COMMON_LOGGING.gma_migration_central_log
						(
						p_run_id             =>       G_migration_run_id,
						p_log_level          =>       FND_LOG.LEVEL_ERROR,
						p_message_token      =>       'GMA_MIGRATION_DB_ERROR',
						p_table_name         =>       G_Table_name,
						p_context            =>       G_context,
						p_param1             =>       NULL,
						p_param2             =>       NULL,
						p_db_error           =>       SQLERRM,
						p_app_short_name     =>       'GMA'
						);

						/**************************************
						* Migration Failure Log Message       *
						**************************************/

						GMA_COMMON_LOGGING.gma_migration_central_log
						(
						p_run_id             =>       G_migration_run_id,
						p_log_level          =>       FND_LOG.LEVEL_ERROR,
						p_message_token      =>       'GMA_TABLE_MIGRATION_TABLE_FAIL',
						p_table_name         =>       G_Table_name,
						p_context            =>       G_context,
						p_db_error           =>       NULL,
						p_app_short_name     =>       'GMA'
						);

			END;

			/**********************************************
			* Handle all the rows which were not migrated *
			**********************************************/

			SELECT               count(*)
			INTO                 x_failure_count
			FROM                 gl_aloc_inp
			WHERE                (account_id IS NULL AND account_key IS NOT NULL);

			IF nvl(x_failure_count,0) > 0 THEN

				/**************************************
				* Migration Failure Log Message       *
				**************************************/

				GMA_COMMON_LOGGING.gma_migration_central_log
				(
				p_run_id             =>       gmf_migration.G_migration_run_id,
				p_log_level          =>       FND_LOG.LEVEL_PROCEDURE,
				p_message_token      =>       'GMA_TABLE_MIGRATION_TABLE_FAIL',
				p_table_name         =>       gmf_migration.G_Table_name,
				p_context            =>       gmf_migration.G_context,
				p_db_error           =>       NULL,
				p_app_short_name     =>       'GMA'
				);

			ELSE

				/**************************************
				* Migration Success Log Message       *
				**************************************/

				GMA_COMMON_LOGGING.gma_migration_central_log
				(
				p_run_id             =>       G_migration_run_id,
				p_log_level          =>       FND_LOG.LEVEL_STATEMENT,
				p_message_token      =>       'GMA_MIGRATION_TABLE_SUCCESS',
				p_table_name         =>       G_Table_name,
				p_context            =>       G_Context,
				p_param1             =>       1,
				p_param2             =>       0,
				p_db_error           =>       NULL,
				p_app_short_name     =>       'GMA'
				);

			END IF;

			/****************************************************************
			* Lets save the changes now based on the commit parameter       *
			****************************************************************/

			IF NVL(p_commit,'~') = FND_API.G_TRUE THEN
				 COMMIT;
			END IF;

	 EXCEPTION

			WHEN OTHERS THEN

				 /************************************************
				 * Increment Failure Count for Failed Migrations *
				 ************************************************/

				 x_failure_count := x_failure_count + 1;

				 /**************************************
				 * Migration DB Error Log Message      *
				 **************************************/

				 GMA_COMMON_LOGGING.gma_migration_central_log
				 (
				 p_run_id             =>       G_migration_run_id,
				 p_log_level          =>       FND_LOG.LEVEL_ERROR,
				 p_message_token      =>       'GMA_MIGRATION_DB_ERROR',
				 p_table_name         =>       G_Table_name,
				 p_context            =>       G_context,
				 p_param1             =>       NULL,
				 p_param2             =>       NULL,
				 p_db_error           =>       SQLERRM,
				 p_app_short_name     =>       'GMA'
				 );

				 /**************************************
				 * Migration Failure Log Message       *
				 **************************************/

				 GMA_COMMON_LOGGING.gma_migration_central_log
				 (
				 p_run_id             =>       G_migration_run_id,
				 p_log_level          =>       FND_LOG.LEVEL_ERROR,
				 p_message_token      =>       'GMA_TABLE_MIGRATION_TABLE_FAIL',
				 p_table_name         =>       G_Table_name,
				 p_context            =>       G_context,
				 p_db_error           =>       NULL,
				 p_app_short_name     =>       'GMA'
				 );

	 END Migrate_Allocation_Inputs;

	 /**********************************************************************
	 * PROCEDURE:                                                          *
	 *   Migrate_Burden_Priorities                                         *
	 *                                                                     *
	 * DESCRIPTION:                                                        *
	 *   This PL/SQL procedure is used to migrate the Burden Priorities    *
	 *                                                                     *
	 * PARAMETERS:                                                         *
	 *   P_migration_run_id - id to use to right to migration log          *
	 *   x_exception_count  - Number of exceptions occurred.               *
	 *                                                                     *
	 * SYNOPSIS:                                                           *
	 *   Migrate_Burden_Priorities(p_migartion_id    => l_migration_id,    *
	 *                    p_commit          => 'T',                        *
	 *                    x_exception_count => l_exception_count );        *
	 *                                                                     *
	 * HISTORY                                                             *
	 *       27-Apr-2005 Created  Anand Thiyagarajan                       *
	 *                                                                     *
	 **********************************************************************/
	 PROCEDURE Migrate_Burden_Priorities
	 (
	 P_migration_run_id      IN             NUMBER,
	 P_commit                IN             VARCHAR2,
	 X_failure_count         OUT   NOCOPY   NUMBER
	 )
	 IS
			/***************************
			* PL/SQL Table Definitions *
			***************************/

			/*******************
			* Local Variables  *
			*******************/

	 BEGIN

			G_Migration_run_id := P_migration_run_id;
			G_Table_name := 'GMF_BURDEN_PRIORITIES';
			G_Context := 'Burden Priorities Migration';
			X_failure_count := 0;

			/********************************
			* Migration Started Log Message *
			********************************/

			GMA_COMMON_LOGGING.gma_migration_central_log
			(
			p_run_id             =>       G_migration_run_id,
			p_log_level          =>       FND_LOG.LEVEL_STATEMENT,
			p_message_token      =>       'GMA_MIGRATION_TABLE_STARTED',
			p_table_name         =>       G_table_name,
			p_context            =>       G_context,
			p_db_error           =>       NULL,
			p_app_short_name     =>       'GMA'
			);

			/*****************************************
			* Update rows For Organization Priority  *
			*****************************************/

			UPDATE      gmf_burden_priorities a
			SET         a.organization_pri = nvl(a.whse_code_pri, a.orgn_code_pri),
									a.legal_entity_id
			=           (
									SELECT      x.legal_entity_id
									FROM        gl_plcy_mst x
									WHERE       x.co_code = a.co_code
									)
			WHERE       ((a.whse_code_pri IS NOT NULL OR a.orgn_code_pri IS NOT null) AND a.organization_pri IS NULL)
			OR          (a.co_code IS NOT NULL AND a.legal_entity_id IS NULL);

			UPDATE      gmf_burden_priorities a
			SET         a.delete_mark = 1
			WHERE       a.ROWID NOT IN  (
																	SELECT      MIN(x.ROWID)
																	FROM        gmf_burden_priorities x
																	WHERE       x.burden_id = a.burden_id
																	AND         x.legal_entity_id = a.legal_Entity_id
																	AND         x.delete_mark <> 1
																	);

			UPDATE      gmf_burden_priorities
			SET         organization_pri      =  decode(trunc(nvl(organization_pri,0) / orgn_code_pri), 0, organization_pri, organization_pri - 1),
									item_id_pri           =  decode(trunc(nvl(item_id_pri,0) / orgn_code_pri), 0, item_id_pri, item_id_pri - 1),
									icgl_class_pri        =  decode(trunc(nvl(icgl_class_pri,0) / orgn_code_pri), 0, icgl_class_pri, icgl_class_pri - 1),
									itemcost_class_pri    =  decode(trunc(nvl(itemcost_class_pri,0) / orgn_code_pri), 0, itemcost_class_pri, itemcost_class_pri - 1),
									gl_prod_line_pri      =  decode(trunc(nvl(gl_prod_line_pri,0) / orgn_code_pri), 0, gl_prod_line_pri, gl_prod_line_pri - 1),
									gl_business_class_pri =  decode(trunc(nvl(gl_business_class_pri,0) / orgn_code_pri), 0, gl_business_class_pri, gl_business_class_pri - 1),
									orgn_code_pri = NULL
			WHERE       orgn_code_pri IS NOT NULL
			AND         orgn_code_pri < 7
			AND         whse_code_pri IS NOT NULL;

			/**********************************************
			* Handle all the rows which were not migrated *
			**********************************************/

			SELECT               count(*)
			INTO                 x_failure_count
			FROM                 gmf_burden_priorities a
			WHERE                ((a.whse_code_pri IS NOT NULL OR a.orgn_code_pri IS NOT null) AND a.organization_pri IS NULL)
			OR                   (a.co_code IS NOT NULL AND a.legal_entity_id IS NULL);

			IF nvl(x_failure_count,0) > 0 THEN

				/**************************************
				* Migration Failure Log Message       *
				**************************************/

				GMA_COMMON_LOGGING.gma_migration_central_log
				(
				p_run_id             =>       gmf_migration.G_migration_run_id,
				p_log_level          =>       FND_LOG.LEVEL_PROCEDURE,
				p_message_token      =>       'GMA_TABLE_MIGRATION_TABLE_FAIL',
				p_table_name         =>       gmf_migration.G_Table_name,
				p_context            =>       gmf_migration.G_context,
				p_db_error           =>       NULL,
				p_app_short_name     =>       'GMA'
				);

			ELSE

				/**************************************
				* Migration Success Log Message       *
				**************************************/

				GMA_COMMON_LOGGING.gma_migration_central_log
				(
				p_run_id             =>       G_migration_run_id,
				p_log_level          =>       FND_LOG.LEVEL_STATEMENT,
				p_message_token      =>       'GMA_MIGRATION_TABLE_SUCCESS',
				p_table_name         =>       G_Table_name,
				p_context            =>       G_Context,
				p_param1             =>       1,
				p_param2             =>       0,
				p_db_error           =>       NULL,
				p_app_short_name     =>       'GMA'
				);

			END IF;

			/****************************************************************
			* Lets save the changes now based on the commit parameter       *
			****************************************************************/

			IF NVL(p_commit,'~') = FND_API.G_TRUE THEN
				 COMMIT;
			END IF;

	 EXCEPTION
			WHEN OTHERS THEN

				 /************************************************
				 * Increment Failure Count for Failed Migrations *
				 ************************************************/
				 x_failure_count := x_failure_count + 1;

				 /**************************************
				 * Migration DB Error Log Message      *
				 **************************************/

				 GMA_COMMON_LOGGING.gma_migration_central_log
				 (
				 p_run_id             =>       G_migration_run_id,
				 p_log_level          =>       FND_LOG.LEVEL_ERROR,
				 p_message_token      =>       'GMA_MIGRATION_DB_ERROR',
				 p_table_name         =>       G_table_name,
				 p_context            =>       G_context,
				 p_db_error           =>       SQLERRM,
				 p_app_short_name     =>       'GMA'
				 );

				 /**************************************
				 * Migration Failure Log Message       *
				 **************************************/

				 GMA_COMMON_LOGGING.gma_migration_central_log
				 (
				 p_run_id             =>       G_migration_run_id,
				 p_log_level          =>       FND_LOG.LEVEL_ERROR,
				 p_message_token      =>       'GMA_TABLE_MIGRATION_TABLE_FAIL',
				 p_table_name         =>       G_table_name,
				 p_context            =>       G_context,
				 p_db_error           =>       NULL,
				 p_app_short_name     =>       'GMA'
				 );

	 END Migrate_Burden_Priorities;

	 /**********************************************************************
	 * PROCEDURE:                                                          *
	 *   Migrate_Component_Materials                                       *
	 *                                                                     *
	 * DESCRIPTION:                                                        *
	 *   This PL/SQL procedure is used to migrate the Material Components  *
	 *                                                                     *
	 * PARAMETERS:                                                         *
	 *   P_migration_run_id - id to use to right to migration log          *
	 *   x_exception_count  - Number of exceptions occurred.               *
	 *                                                                     *
	 * SYNOPSIS:                                                           *
	 *   Migrate_component_Materials(p_migartion_id    => l_migration_id,  *
	 *                    p_commit          => 'T',                        *
	 *                    x_exception_count => l_exception_count );        *
	 *                                                                     *
	 * HISTORY                                                             *
	 *       27-Apr-2005 Created  Anand Thiyagarajan                       *
	 *       05-Jul-2006 rseshadr bug 5374823 - call item mig inline for   *
	 *         the current table                                           *
	 *                                                                     *
	 **********************************************************************/
	 PROCEDURE Migrate_Component_Materials
	 (
	 P_migration_run_id      IN             NUMBER,
	 P_commit                IN             VARCHAR2,
	 X_failure_count         OUT   NOCOPY   NUMBER
	 )
	 IS
			/***************************
			* PL/SQL Table Definitions *
			***************************/

			/*******************
			* Local Variables  *
			*******************/

			l_inventory_item_id                 NUMBER;
			l_itm_failure_count                 NUMBER;
			l_itm_failure_count_all             NUMBER;


			/****************
			* Cursors       *
			****************/

			CURSOR      cur_get_gmf_items IS
			SELECT      DISTINCT
									item_id,
									organization_id
			FROM        (
									SELECT        a.item_id,
																decode(NVL(c.subinventory_ind_flag,'N'), 'Y', c.organization_id, c.mtl_organization_id) organization_id
									FROM          cm_cmpt_mtl a,
																sy_orgn_mst b,
																ic_whse_mst c
									WHERE         a.item_id IS NOT NULL
									AND           a.co_code = b.co_code
									AND           b.orgn_code = c.orgn_code
									AND           nvl(c.subinventory_ind_flag, 'N') <> 'Y'
									);

	 BEGIN

			G_Migration_run_id := P_migration_run_id;
			G_Table_name := 'CM_CMPT_MTL';
			G_Context := 'Material Cost Components Migration';
			X_failure_count := 0;

			/********************************
			* Migration Started Log Message *
			********************************/

			GMA_COMMON_LOGGING.gma_migration_central_log
			(
			p_run_id             =>       G_migration_run_id,
			p_log_level          =>       FND_LOG.LEVEL_STATEMENT,
			p_message_token      =>       'GMA_MIGRATION_TABLE_STARTED',
			p_table_name         =>       G_table_name,
			p_context            =>       G_context,
			p_db_error           =>       NULL,
			p_app_short_name     =>       'GMA'
			);

			/********************************************
			* rseshadr bug 5374823                      *
			* Call Item Migration API in a loop         *
			* To Migrate necessary items for this table *
			*********************************************/

			FOR i IN cur_get_gmf_items
			LOOP
				IF i.item_id IS NOT NULL AND i.organization_id IS NOT NULL THEN
					inv_opm_item_migration.get_odm_item
					(
						p_migration_run_id        =>        p_migration_run_id,
						p_item_id                 =>        i.item_id,
						p_organization_id         =>        i.organization_id,
						p_mode                    =>        NULL,
						p_commit                  =>        FND_API.G_TRUE,
						x_inventory_item_id       =>        l_inventory_item_id,
						x_failure_count           =>        l_itm_failure_count
					);
				END IF;
				l_itm_failure_count_all := nvl(l_itm_failure_count_all,0) + nvl(l_itm_failure_count,0);
			END LOOP;

			/*****************************************
			* Update rows For Legal Entity and Item  *
			*****************************************/

			UPDATE      cm_cmpt_mtl a
			SET         a.legal_entity_id
			=           (
									SELECT            x.legal_entity_id
									FROM              gl_plcy_mst x
									WHERE             x.co_code = a.co_code
									)
			WHERE       (a.legal_entity_id IS NULL AND a.co_code IS NOT NULL);

			UPDATE      cm_cmpt_mtl a
			SET         (
									a.master_organization_id,
									a.inventory_item_id
									)
			=           (
									SELECT            z.master_organization_id,
																		y.inventory_item_id
									FROM              ic_item_mst_b_mig y,
																		mtl_parameters z,
																		hr_organization_information hoi
									WHERE             y.item_id = a.item_id
									AND               y.organization_id = z.organization_id
									AND               hoi.organization_id = z.organization_id
									AND               hoi.org_information_context = 'Accounting Information'
									AND               hoi.org_information2 = a.legal_entity_id
									AND               ROWNUM = 1
									)
			WHERE       (a.inventory_item_id IS NULL AND a.item_id IS NOT NULL)
			OR          (a.master_organization_id IS NULL AND a.item_id IS NOT NULL);

			UPDATE      cm_cmpt_mtl a
			SET         a.delete_mark = 1
			WHERE       a.ROWID NOT IN  (
																	SELECT      MIN(x.ROWID)
																	FROM        cm_cmpt_mtl x
																	WHERE       x.legal_entity_id = a.legal_Entity_id
																	AND         nvl(x.inventory_item_id, -1) = nvl(a.inventory_item_id, -1)
																	AND         nvl(x.cost_category_id, -1) = nvl(a.cost_category_id, -1)
																	AND         x.delete_mark <> 1
																	AND         (
																							a.eff_start_date BETWEEN x.eff_start_date and x.eff_end_date
																							OR
																							a.eff_end_date BETWEEN x.eff_start_date  and x.eff_end_date
																							)
																	);

			/**********************************************
			* Handle all the rows which were not migrated *
			**********************************************/

			SELECT                count(*)
			INTO                  x_failure_count
			FROM                  cm_cmpt_mtl
			WHERE                 (
														(inventory_item_id IS NULL AND item_id IS NOT NULL)
			OR                    (legal_entity_id IS NULL AND co_code IS NOT NULL)
			OR                    (master_organization_id IS NULL AND item_id IS NOT NULL)
														);

			IF nvl(x_failure_count,0) > 0 THEN

				/**************************************
				* Migration Failure Log Message       *
				**************************************/

				GMA_COMMON_LOGGING.gma_migration_central_log
				(
				p_run_id             =>       gmf_migration.G_migration_run_id,
				p_log_level          =>       FND_LOG.LEVEL_PROCEDURE,
				p_message_token      =>       'GMA_TABLE_MIGRATION_TABLE_FAIL',
				p_table_name         =>       gmf_migration.G_Table_name,
				p_context            =>       gmf_migration.G_context,
				p_db_error           =>       NULL,
				p_app_short_name     =>       'GMA'
				);

			ELSE

				/**************************************
				* Migration Success Log Message       *
				**************************************/

				GMA_COMMON_LOGGING.gma_migration_central_log
				(
				p_run_id             =>       G_migration_run_id,
				p_log_level          =>       FND_LOG.LEVEL_STATEMENT,
				p_message_token      =>       'GMA_MIGRATION_TABLE_SUCCESS',
				p_table_name         =>       G_Table_name,
				p_context            =>       G_Context,
				p_param1             =>       1,
				p_param2             =>       0,
				p_db_error           =>       NULL,
				p_app_short_name     =>       'GMA'
				);

			END IF;

			/****************************************************************
			* Lets save the changes now based on the commit parameter       *
			****************************************************************/

			IF NVL(p_commit,'~') = FND_API.G_TRUE THEN
				 COMMIT;
			END IF;

	 EXCEPTION
			WHEN OTHERS THEN

				 /************************************************
				 * Increment Failure Count for Failed Migrations *
				 ************************************************/
				 x_failure_count := x_failure_count + 1;

				 /**************************************
				 * Migration DB Error Log Message      *
				 **************************************/

				 GMA_COMMON_LOGGING.gma_migration_central_log
				 (
				 p_run_id             =>       G_migration_run_id,
				 p_log_level          =>       FND_LOG.LEVEL_ERROR,
				 p_message_token      =>       'GMA_MIGRATION_DB_ERROR',
				 p_table_name         =>       G_table_name,
				 p_context            =>       G_context,
				 p_db_error           =>       SQLERRM,
				 p_app_short_name     =>       'GMA'
				 );

				 /**************************************
				 * Migration Failure Log Message       *
				 **************************************/

				 GMA_COMMON_LOGGING.gma_migration_central_log
				 (
				 p_run_id             =>       G_migration_run_id,
				 p_log_level          =>       FND_LOG.LEVEL_ERROR,
				 p_message_token      =>       'GMA_TABLE_MIGRATION_TABLE_FAIL',
				 p_table_name         =>       G_table_name,
				 p_context            =>       G_context,
				 p_db_error           =>       NULL,
				 p_app_short_name     =>       'GMA'
				 );

	 END Migrate_Component_Materials;

	 /**********************************************************************
	 * PROCEDURE:                                                          *
	 *   Migrate_Allocation_Codes                                          *
	 *                                                                     *
	 * DESCRIPTION:                                                        *
	 *   This PL/SQL procedure is used to migrate the Expense Allocation   *
	 *   Basis Records                                                     *
	 *                                                                     *
	 * PARAMETERS:                                                         *
	 *   P_migration_run_id - id to use to right to migration log          *
	 *   x_exception_count  - Number of exceptions occurred.               *
	 *                                                                     *
	 * SYNOPSIS:                                                           *
	 *   Migrate_Allocation_Codes(p_migartion_id    => l_migration_id,     *
	 *                    p_commit          => 'T',                        *
	 *                    x_exception_count => l_exception_count );        *
	 *                                                                     *
	 * HISTORY                                                             *
	 *       27-Apr-2005 Created  Anand Thiyagarajan                       *
	 *                                                                     *
	 **********************************************************************/
	 PROCEDURE Migrate_Allocation_Codes
	 (
	 P_migration_run_id      IN             NUMBER,
	 P_commit                IN             VARCHAR2,
	 X_failure_count         OUT   NOCOPY   NUMBER
	 )
	 IS
			/***************************
			* PL/SQL Table Definitions *
			***************************/

			/**********
			* Cursors *
			**********/

			CURSOR        c_gl_aloc_bas
			IS
			SELECT        y.alloc_id,
										y.mina,
										count(x.alloc_id) cnt
			FROM          gl_aloc_bas x,  (
																		SELECT        a.alloc_id,
																									(
																									SELECT          MIN(h.alloc_id)
																									FROM            gl_aloc_mst h
																									WHERE           (h.legal_entity_id, h.alloc_code) IN  (
																																																				SELECT        i.legal_entity_id, i.alloc_code
																																																				FROM          gl_aloc_mst i
																																																				WHERE         i.alloc_id = a.alloc_id
																																																				)
																									) mina
																		FROM          gl_aloc_bas a
																		GROUP BY      a.alloc_id
																		) y
			WHERE         x.alloc_id(+) = y.mina
			GROUP BY      y.alloc_id,
										x.alloc_id,
										y.mina
			HAVING        y.alloc_id <> y.mina;

			CURSOR        c_gl_aloc_exp
			IS
			SELECT        y.alloc_id,
										y.mina,
										count(x.alloc_id) cnt
			FROM          gl_aloc_exp x,  (
																		SELECT        a.alloc_id,
																									(
																									SELECT          MIN(h.alloc_id)
																									FROM            gl_aloc_mst h
																									WHERE           (h.legal_entity_id, h.alloc_code) IN  (
																																																				SELECT        i.legal_entity_id, i.alloc_code
																																																				FROM          gl_aloc_mst i
																																																				WHERE         i.alloc_id = a.alloc_id
																																																				)
																									) mina
																		FROM          gl_aloc_exp a
																		GROUP BY      a.alloc_id
																		) y
			WHERE         x.alloc_id(+) = y.mina
			GROUP BY      y.alloc_id,
										x.alloc_id,
										y.mina
			HAVING        y.alloc_id <> y.mina;

			CURSOR        c_gl_aloc_inp
			IS
			SELECT        y.alloc_id,
										y.mina,
										count(x.alloc_id) cnt
			FROM          gl_aloc_inp x,  (
																		SELECT        a.alloc_id,
																									(
																									SELECT          MIN(h.alloc_id)
																									FROM            gl_aloc_mst h
																									WHERE           (h.legal_entity_id, h.alloc_code) IN  (
																																																				SELECT        i.legal_entity_id, i.alloc_code
																																																				FROM          gl_aloc_mst i
																																																				WHERE         i.alloc_id = a.alloc_id
																																																				)
																									) mina
																		FROM          gl_aloc_inp a
																		GROUP BY      a.alloc_id
																		) y
			WHERE         x.alloc_id(+) = y.mina
			GROUP BY      y.alloc_id,
										x.alloc_id,
										y.mina
			HAVING        y.alloc_id <> y.mina;

			/*******************
			* Local Variables  *
			*******************/

	 BEGIN

			G_Migration_run_id := P_migration_run_id;
			G_Table_name := 'GL_ALOC_MST';
			G_Context := 'Expense Allocation Codes Migration';
			X_failure_count := 0;

			/********************************
			* Migration Started Log Message *
			********************************/

			GMA_COMMON_LOGGING.gma_migration_central_log
			(
			p_run_id             =>       G_migration_run_id,
			p_log_level          =>       FND_LOG.LEVEL_STATEMENT,
			p_message_token      =>       'GMA_MIGRATION_TABLE_STARTED',
			p_table_name         =>       G_table_name,
			p_context            =>       G_context,
			p_db_error           =>       NULL,
			p_app_short_name     =>       'GMA'
			);

			/*****************************************
			* Update rows For Legal Entity           *
			*****************************************/

			UPDATE      gl_aloc_mst a
			SET         a.legal_entity_id =  (
																			 SELECT      x.legal_entity_id
																			 FROM        gl_plcy_mst x
																			 WHERE       x.co_code = a.co_code
																			 )
			WHERE       (a.legal_entity_id IS NULL AND a.co_code IS NOT NULL);

			/**************************************************************************************************************
			* Migrating records can have duplicate value of Allocation codes since, codes from different companies        *
			* are merged together to form the legal entities allocation records. so we delete the duplicate records       *
			* from the allocation tables. Since there are some references too the allocation codes in Allocation basis    *
			* we have to delete the records from those tables as well.                                                    *
			**************************************************************************************************************/

			UPDATE      gl_aloc_mst a
			SET         a.delete_mark = 1
			WHERE       a.ROWID NOT IN  (
																	SELECT      MIN(x.ROWID)
																	FROM        gl_aloc_mst x
																	WHERE       x.alloc_code = a.alloc_code
																	AND         x.legal_entity_id = a.legal_Entity_id
																	AND         x.delete_mark <> 1
																	);

			/******************************************************************
			* Deleting referenced records and updating records in GL_ALOC_BAS *
			******************************************************************/

			FOR i IN c_gl_aloc_bas LOOP
				IF i.cnt > 0 THEN
					UPDATE    gl_aloc_bas a
					SET       a.delete_mark = 1
					WHERE     a.alloc_id = i.alloc_id
					AND       a.delete_mark <> 1;
				ELSE
					UPDATE    gl_aloc_bas a
					SET       a.alloc_id = i.mina
					WHERE     a.alloc_id = i.alloc_id
					AND       a.delete_mark <> 1;
				END IF;
			END LOOP;

			/******************************************************************
			* Deleting referenced records and updating records in GL_ALOC_EXP *
			******************************************************************/

			FOR i IN c_gl_aloc_exp LOOP
				IF i.cnt > 0 THEN
					UPDATE    gl_aloc_exp a
					SET       a.delete_mark = 1
					WHERE     a.alloc_id = i.alloc_id
					AND       a.delete_mark <> 1;
				ELSE
					UPDATE    gl_aloc_exp a
					SET       a.alloc_id = i.mina
					WHERE     a.alloc_id = i.alloc_id
					AND       a.delete_mark <> 1;
				END IF;
			END LOOP;

			/******************************************************************
			* Deleting referenced records and updating records in GL_ALOC_INP *
			******************************************************************/

			FOR i IN c_gl_aloc_inp LOOP
				IF i.cnt > 0 THEN
					UPDATE    gl_aloc_inp a
					SET       a.delete_mark = 1
					WHERE     a.alloc_id = i.alloc_id
					AND       a.delete_mark <> 1;
				ELSE
					UPDATE    gl_aloc_inp a
					SET       a.alloc_id = i.mina
					WHERE     a.alloc_id = i.alloc_id
					AND       a.delete_mark <> 1;
				END IF;
			END LOOP;

			/**********************************************
			* Handle all the rows which were not migrated *
			**********************************************/

			SELECT               count(*)
			INTO                 x_failure_count
			FROM                 gl_aloc_mst
			WHERE                (legal_entity_id IS NULL AND co_code IS NOT NULL);

			IF nvl(x_failure_count,0) > 0 THEN

				/**************************************
				* Migration Failure Log Message       *
				**************************************/

				GMA_COMMON_LOGGING.gma_migration_central_log
				(
				p_run_id             =>       gmf_migration.G_migration_run_id,
				p_log_level          =>       FND_LOG.LEVEL_PROCEDURE,
				p_message_token      =>       'GMA_TABLE_MIGRATION_TABLE_FAIL',
				p_table_name         =>       gmf_migration.G_Table_name,
				p_context            =>       gmf_migration.G_context,
				p_db_error           =>       NULL,
				p_app_short_name     =>       'GMA'
				);

			ELSE

				/**************************************
				* Migration Success Log Message       *
				**************************************/

				GMA_COMMON_LOGGING.gma_migration_central_log
				(
				p_run_id             =>       G_migration_run_id,
				p_log_level          =>       FND_LOG.LEVEL_STATEMENT,
				p_message_token      =>       'GMA_MIGRATION_TABLE_SUCCESS',
				p_table_name         =>       G_Table_name,
				p_context            =>       G_Context,
				p_param1             =>       1,
				p_param2             =>       0,
				p_db_error           =>       NULL,
				p_app_short_name     =>       'GMA'
				);

			END IF;

			/****************************************************************
			* Lets save the changes now based on the commit parameter       *
			****************************************************************/

			IF NVL(p_commit,'~') = FND_API.G_TRUE THEN
				 COMMIT;
			END IF;

	 EXCEPTION
			WHEN OTHERS THEN

				 /************************************************
				 * Increment Failure Count for Failed Migrations *
				 ************************************************/
				 x_failure_count := x_failure_count + 1;

				 /**************************************
				 * Migration DB Error Log Message      *
				 **************************************/

				 GMA_COMMON_LOGGING.gma_migration_central_log
				 (
				 p_run_id             =>       G_migration_run_id,
				 p_log_level          =>       FND_LOG.LEVEL_ERROR,
				 p_message_token      =>       'GMA_MIGRATION_DB_ERROR',
				 p_table_name         =>       G_table_name,
				 p_context            =>       G_context,
				 p_db_error           =>       SQLERRM,
				 p_app_short_name     =>       'GMA'
				 );

				 /**************************************
				 * Migration Failure Log Message       *
				 **************************************/

				 GMA_COMMON_LOGGING.gma_migration_central_log
				 (
				 p_run_id             =>       G_migration_run_id,
				 p_log_level          =>       FND_LOG.LEVEL_ERROR,
				 p_message_token      =>       'GMA_TABLE_MIGRATION_TABLE_FAIL',
				 p_table_name         =>       G_table_name,
				 p_context            =>       G_context,
				 p_db_error           =>       NULL,
				 p_app_short_name     =>       'GMA'
				 );

	 END Migrate_Allocation_Codes;

	 /**********************************************************************
	 * PROCEDURE:                                                          *
	 *   Migrate_Event Policies                                            *
	 *                                                                     *
	 * DESCRIPTION:                                                        *
	 *   This PL/SQL procedure is used to migrate the Event Fiscal Policies*
	 *                                                                     *
	 * PARAMETERS:                                                         *
	 *   P_migration_run_id - id to use to right to migration log          *
	 *   x_exception_count  - Number of exceptions occurred.               *
	 *                                                                     *
	 * SYNOPSIS:                                                           *
	 *   Migrate_Evenr_Policies(p_migartion_id    => l_migration_id,       *
	 *                    p_commit          => 'T',                        *
	 *                    x_exception_count => l_exception_count );        *
	 *                                                                     *
	 * HISTORY                                                             *
	 *       27-Apr-2005 Created  Anand Thiyagarajan                       *
	 *                                                                     *
	 **********************************************************************/
	 PROCEDURE Migrate_Event_Policies
	 (
	 P_migration_run_id      IN             NUMBER,
	 P_commit                IN             VARCHAR2,
	 X_failure_count         OUT   NOCOPY   NUMBER
	 )
	 IS

			/***************************
			* PL/SQL Table Definitions *
			***************************/

			/*******************
			* Local Variables  *
			*******************/

	 BEGIN

			G_Migration_run_id := P_migration_run_id;
			G_Table_name := 'GL_EVNT_PLC';
			G_Context := 'Event Fiscal Policies Migration';
			X_failure_count := 0;

			/********************************
			* Migration Started Log Message *
			********************************/

			GMA_COMMON_LOGGING.gma_migration_central_log
			(
			p_run_id             =>       G_migration_run_id,
			p_log_level          =>       FND_LOG.LEVEL_STATEMENT,
			p_message_token      =>       'GMA_MIGRATION_TABLE_STARTED',
			p_table_name         =>       G_table_name,
			p_context            =>       G_context,
			p_db_error           =>       NULL,
			p_app_short_name     =>       'GMA'
			);

			/*****************************************
			* Update rows For Legal Entity           *
			*****************************************/

			UPDATE      gl_evnt_plc a
			SET         a.legal_entity_id =  (
																			 SELECT      x.legal_entity_id
																			 FROM        gl_plcy_mst x
																			 WHERE       x.co_code = a.co_code
																			 ),
									a.entity_code = decode(a.trans_source_type, 12, 'PURCHASING', NULL),
									a.event_class_code = decode(a.event_type, 110, 'DELIVER', NULL)
			WHERE       (a.legal_entity_id IS NULL AND a.co_code IS NOT NULL);

			/**************************************************************************************************************
			* Migrating records can have duplicate value of Event Fiscal Policies since, codes from different companies   *
			* are merged together to form the LE Event Fiscal Policy records.so we delete the duplicate records           *
			* from the Event Fiscal Policy tables.                                                                        *
			**************************************************************************************************************/

			UPDATE      gl_evnt_plc a
			SET         a.delete_mark = 1
			WHERE       a.ROWID NOT IN  (
																	SELECT      MIN(x.ROWID)
																	FROM        gl_evnt_plc x
																	WHERE       x.legal_entity_id = a.legal_Entity_id
																	AND         nvl(x.trans_source_type, -1) = nvl(a.trans_source_type, -1)
																	AND         nvl(x.event_type, -1) = nvl(a.event_type, -1)
																	AND         x.delete_mark <> 1
																	);

			/**********************************************
			* Handle all the rows which were not migrated *
			**********************************************/

			SELECT               count(*)
			INTO                 x_failure_count
			FROM                 gl_evnt_plc
			WHERE                (legal_entity_id IS NULL AND co_code IS NOT NULL);

			IF nvl(x_failure_count,0) > 0 THEN

				/**************************************
				* Migration Failure Log Message       *
				**************************************/

				GMA_COMMON_LOGGING.gma_migration_central_log
				(
				p_run_id             =>       gmf_migration.G_migration_run_id,
				p_log_level          =>       FND_LOG.LEVEL_PROCEDURE,
				p_message_token      =>       'GMA_TABLE_MIGRATION_TABLE_FAIL',
				p_table_name         =>       gmf_migration.G_Table_name,
				p_context            =>       gmf_migration.G_context,
				p_db_error           =>       NULL,
				p_app_short_name     =>       'GMA'
				);

			ELSE

				/**************************************
				* Migration Success Log Message       *
				**************************************/

				GMA_COMMON_LOGGING.gma_migration_central_log
				(
				p_run_id             =>       G_migration_run_id,
				p_log_level          =>       FND_LOG.LEVEL_STATEMENT,
				p_message_token      =>       'GMA_MIGRATION_TABLE_SUCCESS',
				p_table_name         =>       G_Table_name,
				p_context            =>       G_Context,
				p_param1             =>       1,
				p_param2             =>       0,
				p_db_error           =>       NULL,
				p_app_short_name     =>       'GMA'
				);

			END IF;

			/****************************************************************
			* Lets save the changes now based on the commit parameter       *
			****************************************************************/

			IF NVL(p_commit,'~') = FND_API.G_TRUE THEN
				 COMMIT;
			END IF;

	 EXCEPTION
			WHEN OTHERS THEN

				 /************************************************
				 * Increment Failure Count for Failed Migrations *
				 ************************************************/
				 x_failure_count := x_failure_count + 1;

				 /**************************************
				 * Migration DB Error Log Message      *
				 **************************************/

				 GMA_COMMON_LOGGING.gma_migration_central_log
				 (
				 p_run_id             =>       G_migration_run_id,
				 p_log_level          =>       FND_LOG.LEVEL_ERROR,
				 p_message_token      =>       'GMA_MIGRATION_DB_ERROR',
				 p_table_name         =>       G_table_name,
				 p_context            =>       G_context,
				 p_db_error           =>       SQLERRM,
				 p_app_short_name     =>       'GMA'
				 );

				 /**************************************
				 * Migration Failure Log Message       *
				 **************************************/

				 GMA_COMMON_LOGGING.gma_migration_central_log
				 (
				 p_run_id             =>       G_migration_run_id,
				 p_log_level          =>       FND_LOG.LEVEL_ERROR,
				 p_message_token      =>       'GMA_TABLE_MIGRATION_TABLE_FAIL',
				 p_table_name         =>       G_table_name,
				 p_context            =>       G_context,
				 p_db_error           =>       NULL,
				 p_app_short_name     =>       'GMA'
				 );

	 END Migrate_Event_Policies;

	 /**********************************************************************
	 * PROCEDURE:                                                          *
	 *   Migrate_source_Warehouses                                         *
	 *                                                                     *
	 * DESCRIPTION:                                                        *
	 *   This PL/SQL procedure is used to transform the Source Warehouses  *
	 *   data in CM_WHSE_SRC                                               *
	 *                                                                     *
	 * PARAMETERS:                                                         *
	 *   P_migration_run_id - id to use to right to migration log          *
	 *   x_exception_count  - Number of exceptions occurred.               *
	 *                                                                     *
	 * SYNOPSIS:                                                           *
	 *   Migrate_Source_Warehouses(p_migartion_id    => l_migration_id,    *
	 *                    p_commit          => 'T',                        *
	 *                    x_exception_count => l_exception_count );        *
	 *                                                                     *
	 * HISTORY                                                             *
	 *       04-Apr-2006 Created  anthiyag                                 *
	 *                                                                     *
	 **********************************************************************/
	 PROCEDURE Migrate_Source_Warehouses
	 (
	 P_migration_run_id      IN             NUMBER,
	 P_commit                IN             VARCHAR2,
	 X_failure_count         OUT   NOCOPY   NUMBER
	 )
	 IS

			/****************
			* PL/SQL Tables *
			****************/

			/******************
			* Local Variables *
			******************/

	 BEGIN

			G_Migration_run_id := P_migration_run_id;
			G_Table_name := 'CM_WHSE_SRC';
			G_Context := 'Source Warehouses Migration';
			X_failure_count := 0;

			/********************************
			* Migration Started Log Message *
			********************************/

			GMA_COMMON_LOGGING.gma_migration_central_log
			(
			p_run_id             =>       G_migration_run_id,
			p_log_level          =>       FND_LOG.LEVEL_STATEMENT,
			p_message_token      =>       'GMA_MIGRATION_TABLE_STARTED',
			p_table_name         =>       G_table_name,
			p_context            =>       G_context,
			p_db_error           =>       NULL,
			p_app_short_name     =>       'GMA'
			);

			/***********************************************
			* Update rows For Source Warehouses            *
			***********************************************/

			UPDATE      cm_whse_src a
			SET         (
									a.organization_id,
									a.legal_entity_id,
									a.delete_mark
									)
			=           (
									SELECT      w.organization_id, z.legal_entity_id, decode(a.delete_mark, 1, 1, decode(nvl(w.inventory_org_ind, 'N'), 'Y', 0, 1))
									FROM        gl_plcy_mst z, sy_orgn_mst w
									WHERE       w.orgn_code = a.orgn_code
									AND         w.co_code = z.co_code
									),
									a.source_organization_id =  (
																							SELECT            DECODE(NVL(subinventory_ind_flag,'N'), 'Y', organization_id, mtl_organization_id)
																							FROM              ic_whse_mst w1
																							WHERE             w1.whse_code = a.whse_code
																							)
			WHERE       (a.legal_entity_id IS NULL AND a.orgn_code IS NOT NULL)
			OR          (a.organization_id IS NULL AND a.orgn_code IS NOT NULL)
			OR          (a.source_organization_id IS NULL AND a.whse_code IS NOT NULL);

			UPDATE      cm_whse_src a
			SET         (
									a.master_organization_id,
									a.inventory_item_id
									)
			=
									(
									SELECT         z.master_organization_id,
																 y.inventory_item_id
									FROM           ic_item_mst_b_mig y,
																 mtl_parameters z,
																 hr_organization_information hoi
									WHERE          y.item_id = a.item_id
									AND            y.organization_id = z.organization_id
									AND            hoi.organization_id = z.organization_id
									AND            hoi.org_information_context = 'Accounting Information'
									AND            hoi.org_information2 = a.legal_entity_id
									AND            y.organization_id = nvl(a.organization_id, y.organization_id)
									AND            ROWNUM = 1
									)
			WHERE       (a.inventory_item_id IS NULL AND a.item_id IS NOT NULL)
			OR          (a.master_organization_id IS NULL AND a.item_id IS NOT NULL);

			/********************************************************************************************************
			* Insert records for Warehouses falling under OPM Organizations not migrated as Inventory Organizations *
			********************************************************************************************************/

			INSERT
			INTO        cm_whse_src
			(
			src_whse_id,
			calendar_code,
			period_code,
			sourcing_alloc_pct,
			creation_date,
			created_by,
			last_update_date,
			trans_cnt,
			text_code,
			delete_mark,
			last_updated_by,
			last_update_login,
			cost_category_id,
			inventory_item_id,
			organization_id,
			source_organization_id,
			master_organization_id,
			legal_entity_id
			)
			(
			SELECT      /*+ ROWID(a) */
									GEM5_src_whse_id_s.NEXTVAL,
									a.calendar_code,
									a.period_code,
									a.sourcing_alloc_pct,
									a.creation_date,
									a.created_by,
									a.last_update_date,
									a.trans_cnt,
									a.text_code,
									0,
									a.last_updated_by,
									a.last_update_login,
									a.cost_category_id,
									a.inventory_item_id,
									e.mtl_organization_id,
									a.source_organization_id,
									a.master_organization_id,
									a.legal_entity_id
			FROM        cm_whse_src a,
									ic_whse_mst e
			WHERE       NOT EXISTS  (
															SELECT  'X'
															FROM     cm_whse_src x
															WHERE    x.legal_entity_id = a.legal_entity_id
															AND      nvl(x.organization_id, -1) = nvl(e.mtl_organization_id, -1)
															AND      x.calendar_code = a.calendar_code
															AND      x.period_code = a.period_code
															AND      nvl(x.inventory_item_id, -1) = nvl(a.inventory_item_id, -1)
															AND      nvl(x.cost_category_id, -1) = nvl(a.cost_category_id, -1)
															)
			AND         e.orgn_code = a.orgn_code
			AND         nvl(e.subinventory_ind_flag,'N') <> 'Y'
			AND         e.mtl_organization_id IS NOT NULL
      AND         a.source_organization_id IS NOT NULL
      AND         a.inventory_item_id IS NOT NULL
      AND         a.legal_entity_id IS NOT NULL
			);

			/**********************************************
			* Handle all the rows which were not migrated *
			**********************************************/
			gmf_migration.Log_Errors  (
																p_log_level               =>          1,
																p_from_rowid              =>          NULL,
																p_to_rowid                =>          NULL
																);

			/****************************************************************
			*Lets save the changes now based on the commit parameter        *
			****************************************************************/

			IF NVL(p_commit,'~') = FND_API.G_TRUE THEN
				 COMMIT;
			END IF;

	 EXCEPTION
			WHEN OTHERS THEN

				 /************************************************
				 * Increment Failure Count for Failed Migrations *
				 ************************************************/
				 x_failure_count := x_failure_count + 1;

				 /**************************************
				 * Migration DB Error Log Message      *
				 **************************************/

				 GMA_COMMON_LOGGING.gma_migration_central_log
				 (
				 p_run_id             =>       G_migration_run_id,
				 p_log_level          =>       FND_LOG.LEVEL_ERROR,
				 p_message_token      =>       'GMA_MIGRATION_DB_ERROR',
				 p_table_name         =>       G_table_name,
				 p_context            =>       G_context,
				 p_db_error           =>       SQLERRM,
				 p_app_short_name     =>       'GMA'
				 );

				 /**************************************
				 * Migration Failure Log Message       *
				 **************************************/

				 GMA_COMMON_LOGGING.gma_migration_central_log
				 (
				 p_run_id             =>       G_migration_run_id,
				 p_log_level          =>       FND_LOG.LEVEL_ERROR,
				 p_message_token      =>       'GMA_TABLE_MIGRATION_TABLE_FAIL',
				 p_table_name         =>       G_table_name,
				 p_context            =>       G_context,
				 p_db_error           =>       NULL,
				 p_app_short_name     =>       'GMA'
				 );

	 END Migrate_Source_Warehouses;

	 /**********************************************************************
	 * PROCEDURE:                                                          *
	 *   Migrate_Items                                                     *
	 *                                                                     *
	 * DESCRIPTION:                                                        *
	 *   This PL/SQL procedure is used to migrate all OPM Financials Items *
	 *                                                                     *
	 * PARAMETERS:                                                         *
	 *                                                                     *
	 * SYNOPSIS:                                                           *
	 *   Migrate_Items;                                                    *
	 *                                                                     *
	 * HISTORY                                                             *
	 *       26-May-2006 Created  Anand Thiyagarajan                       *
	 *       05-Jul-2006 rseshadr bug 5374823 - removed cm_cmpt_mtl and    *
	 *         burden_percentages from cursor as these are now done inline *
	 *                                                                     *
	 **********************************************************************/
	 PROCEDURE Migrate_Items
	 (
	 P_migration_run_id      IN             NUMBER,
	 P_commit                IN             VARCHAR2,
	 X_failure_count         OUT   NOCOPY   NUMBER
	 )
	 IS

			/***************************
			* PL/SQL Table Definitions *
			***************************/

			/************************
			* Local Variables       *
			************************/

			l_inventory_item_id                 NUMBER;
			l_failure_count                     NUMBER;

			/****************
			* Cursors       *
			****************/

			CURSOR            cur_get_gmf_items IS
			SELECT            DISTINCT
												item_id,
												organization_id
			FROM
			(
			SELECT            a.item_id,
												NVL(DECODE(b.cost_organization_id, -1, b.mtl_organization_id, b.cost_organization_id), b.mtl_organization_id) organization_id
			FROM              cm_acst_led a,
												ic_whse_mst b
			WHERE             a.item_id IS NOT NULL
			AND               a.whse_code = b.whse_code
			UNION
			SELECT            a.item_id,
												NVL(DECODE(b.cost_organization_id, -1, b.mtl_organization_id, b.cost_organization_id), b.mtl_organization_id) organization_id
			FROM              cm_adjs_dtl a,
												ic_whse_mst b
			WHERE             a.item_id IS NOT NULL
			AND               a.whse_code = b.whse_code
			UNION
			SELECT            a.item_id,
												NVL(DECODE(b.cost_organization_id, -1, b.mtl_organization_id, b.cost_organization_id), b.mtl_organization_id) organization_id
			FROM              cm_brdn_dtl a,
												ic_whse_mst b
			WHERE             a.item_id IS NOT NULL
			AND               a.whse_code = b.whse_code
			UNION
			SELECT            a.item_id,
												NVL(DECODE(b.cost_organization_id, -1, b.mtl_organization_id, b.cost_organization_id), b.mtl_organization_id) organization_id
			FROM              cm_cmpt_dtl a,
												ic_whse_mst b
			WHERE             a.item_id IS NOT NULL
			AND               a.whse_code = b.whse_code
			UNION
			SELECT            a.item_id,
												NVL(DECODE(b.cost_organization_id, -1, b.mtl_organization_id, b.cost_organization_id), b.mtl_organization_id) organization_id
			FROM              cm_scst_led a,
												ic_whse_mst b
			WHERE             a.item_id IS NOT NULL
			AND               a.whse_code = b.whse_code
			UNION
			SELECT            a.item_id,
												nvl(DECODE(NVL(c.subinventory_ind_flag,'N'), 'Y', c.organization_id, c.mtl_organization_id), DECODE(NVL(b.subinventory_ind_flag,'N'), 'Y', b.organization_id, b.mtl_organization_id)) organization_id
			FROM              cm_whse_src a,
												ic_whse_mst b,
												ic_whse_mst c
			WHERE             a.item_id IS NOT NULL
			AND               b.orgn_code = a.orgn_code
			AND               c.whse_code(+) = a.whse_code
			UNION
			SELECT            a.item_id,
												NVL(DECODE(b.cost_organization_id, -1, b.mtl_organization_id, b.cost_organization_id), b.mtl_organization_id) organization_id
			FROM              gl_item_cst a,
												ic_whse_mst b
			WHERE             a.item_id IS NOT NULL
			AND               a.whse_code = b.whse_code
			UNION
			SELECT            a.item_id,
												DECODE(NVL(c.subinventory_ind_flag,'N'), 'Y', c.organization_id, c.mtl_organization_id) organization_id
			FROM              gmf_lot_costed_items a,
												sy_orgn_mst b,
												ic_whse_mst c
			WHERE             a.item_id IS NOT NULL
			AND               a.co_code = b.co_Code
			AND               b.orgn_code = c.orgn_code
			AND               nvl(c.subinventory_ind_flag,'N') <> 'Y'
			UNION
			SELECT            a.item_id,
												NVL(DECODE(b.cost_organization_id, -1, b.mtl_organization_id, b.cost_organization_id), b.mtl_organization_id) organization_id
			FROM              gmf_lot_Costs a,
												ic_whse_mst b
			WHERE             a.item_id IS NOT NULL
			AND               a.whse_code = b.whse_code
			UNION
			SELECT            a.item_id,
												NVL(DECODE(b.cost_organization_id, -1, b.mtl_organization_id, b.cost_organization_id), b.mtl_organization_id) organization_id
			FROM              gmf_lot_Cost_adjustments a,
												ic_whse_mst b
			WHERE             a.item_id IS NOT NULL
			AND               a.whse_code = b.whse_code
			UNION
			SELECT            a.item_id,
												NVL(DECODE(b.cost_organization_id, -1, b.mtl_organization_id, b.cost_organization_id), b.mtl_organization_id) organization_id
			FROM              gmf_lot_Cost_burdens a,
												ic_whse_mst b
			WHERE             a.item_id IS NOT NULL
			AND               a.whse_code = b.whse_code
			) x
			WHERE             NOT EXISTS
												(
												SELECT        'X'
												FROM          ic_item_mst_b_mig y
												WHERE         y.item_id = x.item_id
												AND           y.organization_id = x.organization_id
												);

	 BEGIN

			G_Migration_run_id := P_migration_run_id;
			G_Table_name := 'GMF_ITEMS_MIGRATION';
			G_Context := 'Process Costing Items Migration';
			X_failure_count := 0;

			/********************************
			* Migration Started Log Message *
			********************************/

			GMA_COMMON_LOGGING.gma_migration_central_log
			(
			p_run_id             =>       G_migration_run_id,
			p_log_level          =>       FND_LOG.LEVEL_STATEMENT,
			p_message_token      =>       'GMA_MIGRATION_TABLE_STARTED',
			p_table_name         =>       G_Table_name,
			p_context            =>       G_Context,
			p_db_error           =>       NULL,
			p_app_short_name     =>       'GMA'
			);

			/****************************************
			* Call Item Migration API in a loop     *
			****************************************/

			FOR i IN cur_get_gmf_items
			LOOP
				IF i.item_id IS NOT NULL AND i.organization_id IS NOT NULL THEN
					inv_opm_item_migration.get_odm_item
					(
					p_migration_run_id        =>        p_migration_run_id,
					p_item_id                 =>        i.item_id,
					p_organization_id         =>        i.organization_id,
					p_mode                    =>        NULL,
					p_commit                  =>        FND_API.G_TRUE,
					x_inventory_item_id       =>        l_inventory_item_id,
					x_failure_count           =>        l_failure_count
					);
				END IF;
				x_failure_count := nvl(x_failure_count,0) + nvl(l_failure_count,0);
			END LOOP;

			/****************************************************************
			* Lets save the changes now based on the commit parameter       *
			****************************************************************/

			IF NVL(p_commit,'~') = FND_API.G_TRUE THEN
				 COMMIT;
			END IF;

	 EXCEPTION
			WHEN OTHERS THEN

				 /************************************************
				 * Increment Failure Count for Failed Migrations *
				 ************************************************/
				 x_failure_count := x_failure_count + 1;

				 /**************************************
				 * Migration DB Error Log Message      *
				 **************************************/

				 GMA_COMMON_LOGGING.gma_migration_central_log
				 (
				 p_run_id             =>       G_migration_run_id,
				 p_log_level          =>       FND_LOG.LEVEL_ERROR,
				 p_message_token      =>       'GMA_MIGRATION_DB_ERROR',
				 p_table_name         =>       G_Table_name,
				 p_context            =>       G_Context,
				 p_db_error           =>       SQLERRM,
				 p_app_short_name     =>       'GMA'
				 );

				 /**************************************
				 * Migration Failure Log Message       *
				 **************************************/

				 GMA_COMMON_LOGGING.gma_migration_central_log
				 (
				 p_run_id             =>       G_migration_run_id,
				 p_log_level          =>       FND_LOG.LEVEL_ERROR,
				 p_message_token      =>       'GMA_TABLE_MIGRATION_TABLE_FAIL',
				 p_table_name         =>       G_Table_name,
				 p_context            =>       G_Context,
				 p_db_error           =>       NULL,
				 p_app_short_name     =>       'GMA'
				 );

	 END Migrate_Items;

	 /**********************************************************************
	 * PROCEDURE:                                                          *
	 *   Migrate_ActualCost_control                                        *
	 *                                                                     *
	 * DESCRIPTION:                                                        *
	 *   This PL/SQL procedure is used to migrate the Actual cost control  *
	 *   date Records                                                      *
	 *                                                                     *
	 * PARAMETERS:                                                         *
	 *   P_migration_run_id - id to use to right to migration log          *
	 *   x_exception_count  - Number of exceptions occurred.               *
	 *                                                                     *
	 * SYNOPSIS:                                                           *
	 *   Migrate_ActualCost_control(p_migartion_id    => l_migration_id,   *
	 *                    p_commit          => 'T',                        *
	 *                    x_exception_count => l_exception_count );        *
	 *                                                                     *
	 * HISTORY                                                             *
	 *       22-Aug-2006 Created  Prasad Marada, bug 5473343               *
	 *                                                                     *
	 **********************************************************************/
	 PROCEDURE Migrate_ActualCost_control
	 (
	 P_migration_run_id      IN             NUMBER,
	 P_commit                IN             VARCHAR2,
	 X_failure_count         OUT   NOCOPY   NUMBER
	 )
	 IS

			/***************************
			* PL/SQL Table Definitions *
			***************************/

			/******************
			* Local Variables *
			******************/

	 BEGIN

			G_Migration_run_id := P_migration_run_id;
			G_Table_name := 'CM_ACPR_CTL';
			G_Context := 'Actual cost control data Migration';
			X_failure_count := 0;

			/********************************
			* Migration Started Log Message *
			********************************/

			GMA_COMMON_LOGGING.gma_migration_central_log
			(
			p_run_id             =>       G_migration_run_id,
			p_log_level          =>       FND_LOG.LEVEL_STATEMENT,
			p_message_token      =>       'GMA_MIGRATION_TABLE_STARTED',
			p_table_name         =>       G_Table_name,
			p_context            =>       G_context,
			p_db_error           =>       NULL,
			p_app_short_name     =>       'GMA'
			);


			/**********************************
			* Update row in CM_ACPR_CTL table *
			***********************************/

			BEGIN
				UPDATE        cm_acpr_ctl cac
				SET           (
											cac.legal_entity_id,
											cac.period_id,
											cac.cost_type_id
											)
				=
											(
											select        gps.legal_entity_id, gps.period_id, gps.cost_type_id
											from          gmf_period_statuses gps,
																		cm_mthd_mst cmm,
																		cm_cldr_hdr_b cch,
																		gl_plcy_mst gpm
											where         gps.calendar_code = cac.calendar_code
											and           cch.calendar_code = cac.calendar_code
											and           cch.co_code = gpm.co_code
											and           gps.legal_entity_id = gpm.legal_entity_id
											and           gps.period_code = cac.period_code
											and           cmm.cost_mthd_code = cac.cost_mthd_code
											and           cmm.cost_type_id = gps.cost_type_id
											)
				where         (cac.calendar_code is not null and cac.legal_entity_id is null)
				OR            (cac.cost_mthd_code is not null AND cac.cost_type_id is null)
				OR            (cac.calendar_code is not null and cac.period_code is not NULL AND cac.period_id is null);

			EXCEPTION
				 WHEN OTHERS THEN

						/************************************************
						* Increment Failure Count for Failed Migrations *
						************************************************/

						x_failure_count := x_failure_count + 1;

						/**************************************
						* Migration DB Error Log Message      *
						**************************************/

						GMA_COMMON_LOGGING.gma_migration_central_log
						(
						p_run_id             =>       G_migration_run_id,
						p_log_level          =>       FND_LOG.LEVEL_ERROR,
						p_message_token      =>       'GMA_MIGRATION_DB_ERROR',
						p_table_name         =>       G_Table_name,
						p_context            =>       G_context,
						p_db_error           =>       SQLERRM,
						p_app_short_name     =>       'GMA'
						);

						/**************************************
						* Migration Failure Log Message       *
						**************************************/

						GMA_COMMON_LOGGING.gma_migration_central_log
						(
						p_run_id             =>       G_migration_run_id,
						p_log_level          =>       FND_LOG.LEVEL_ERROR,
						p_message_token      =>       'GMA_TABLE_MIGRATION_TABLE_FAIL',
						p_table_name         =>       G_Table_name,
						p_context            =>       G_context,
						p_db_error           =>       NULL,
						p_app_short_name     =>       'GMA'
						);

			END;

			/**********************************************
			* Handle all the rows which were not migrated *
			**********************************************/
			gmf_migration.Log_Errors  (
																p_log_level               =>          1,
																p_from_rowid              =>          NULL,
																p_to_rowid                =>          NULL
																);

			/****************************************************************
			* Lets save the changes now based on the commit parameter       *
			****************************************************************/

			IF NVL(p_commit,'~') = FND_API.G_TRUE THEN
				 COMMIT;
			END IF;

	 EXCEPTION

			WHEN OTHERS THEN

				 /************************************************
				 * Increment Failure Count for Failed Migrations *
				 ************************************************/

				 x_failure_count := x_failure_count + 1;

				 /**************************************
				 * Migration DB Error Log Message      *
				 **************************************/

				 GMA_COMMON_LOGGING.gma_migration_central_log
				 (
				 p_run_id             =>       G_migration_run_id,
				 p_log_level          =>       FND_LOG.LEVEL_ERROR,
				 p_message_token      =>       'GMA_MIGRATION_DB_ERROR',
				 p_table_name         =>       G_Table_name,
				 p_context            =>       G_context,
				 p_param1             =>       NULL,
				 p_param2             =>       NULL,
				 p_db_error           =>       SQLERRM,
				 p_app_short_name     =>       'GMA'
				 );

				 /**************************************
				 * Migration Failure Log Message       *
				 **************************************/

				 GMA_COMMON_LOGGING.gma_migration_central_log
				 (
				 p_run_id             =>       G_migration_run_id,
				 p_log_level          =>       FND_LOG.LEVEL_ERROR,
				 p_message_token      =>       'GMA_TABLE_MIGRATION_TABLE_FAIL',
				 p_table_name         =>       G_Table_name,
				 p_context            =>       G_context,
				 p_db_error           =>       NULL,
				 p_app_short_name     =>       'GMA'
				 );

	 END Migrate_ActualCost_control;

	 /**********************************************************************
	 * PROCEDURE:                                                          *
	 *   Migrate_Rollup_control                                            *
	 *                                                                     *
	 * DESCRIPTION:                                                        *
	 *   This PL/SQL procedure is used to migrate the rollup cost control  *
	 *   data Records                                                      *
	 *                                                                     *
	 * PARAMETERS:                                                         *
	 *   P_migration_run_id - id to use to right to migration log          *
	 *   x_exception_count  - Number of exceptions occurred.               *
	 *                                                                     *
	 * SYNOPSIS:                                                           *
	 *   Migrate_rollup_control(p_migartion_id    => l_migration_id,       *
	 *                    p_commit          => 'T',                        *
	 *                    x_exception_count => l_exception_count );        *
	 *                                                                     *
	 * HISTORY                                                             *
	 *       30-Aug-2006 Created  Prasad Marada, bug 5473343               *
	 *                                                                     *
	 **********************************************************************/
	 PROCEDURE Migrate_Rollup_control
	 (
	 P_migration_run_id      IN             NUMBER,
	 P_commit                IN             VARCHAR2,
	 X_failure_count         OUT   NOCOPY   NUMBER
	 )
	 IS

			/***************************
			* PL/SQL Table Definitions *
			***************************/

			/******************
			* Local Variables *
			******************/

	 BEGIN

			G_Migration_run_id := P_migration_run_id;
			G_Table_name := 'CM_RLUP_CTL';
			G_Context := 'Rollup Control Record Migration';
			X_failure_count := 0;

			/********************************
			* Migration Started Log Message *
			********************************/

			GMA_COMMON_LOGGING.gma_migration_central_log
			(
			p_run_id             =>       G_migration_run_id,
			p_log_level          =>       FND_LOG.LEVEL_STATEMENT,
			p_message_token      =>       'GMA_MIGRATION_TABLE_STARTED',
			p_table_name         =>       G_Table_name,
			p_context            =>       G_context,
			p_db_error           =>       NULL,
			p_app_short_name     =>       'GMA'
			);

			/**********************************
			* Update row in CM_RLUP_CTL table *
			***********************************/

			BEGIN

				UPDATE            cm_rlup_ctl crc
				SET               (
													crc.legal_entity_id,
													crc.period_id,
													crc.cost_type_id
													)
				=
													(
													SELECT        gps.legal_entity_id,
																				gps.period_id,
																				gps.cost_type_id
													FROM          gmf_period_statuses gps,
																				cm_mthd_mst cmm,
																				cm_cldr_hdr_b cch,
																				gl_plcy_mst gpm
													WHERE         gps.calendar_code = crc.calendar_code
													AND           cch.calendar_code = crc.calendar_code
													AND           cch.co_code = gpm.co_code
													AND           gps.legal_entity_id = gpm.legal_entity_id
													AND           gps.period_code = crc.period_code
													AND           cmm.cost_mthd_code = crc.cost_mthd_code
													AND           cmm.cost_type_id = gps.cost_type_id
													)
				WHERE             (crc.CALENDAR_CODE IS NOT NULL  AND crc.PERIOD_CODE IS NOT NULL AND crc.PERIOD_ID IS NULL)
				OR                (crc.COST_MTHD_CODE IS NOT NULL AND crc.COST_TYPE_ID IS NULL)
				OR                (crc.CALENDAR_CODE IS NOT NULL  AND crc.LEGAL_ENTITY_ID IS NULL);

				UPDATE            cm_rlup_ctl a
				SET               (
													a.master_organization_id,
													a.inventory_item_id
													)
				=                 (
													SELECT            z.master_organization_id,
																						y.inventory_item_id
													FROM              ic_item_mst_b_mig y,
																						mtl_parameters z,
																						hr_organization_information hoi
													WHERE             y.item_id = a.item_id
													AND               y.organization_id = z.organization_id
													AND               hoi.organization_id = z.organization_id
													AND               hoi.org_information_context = 'Accounting Information'
													AND               hoi.org_information2 = a.legal_entity_id
													AND               ROWNUM = 1
													)
				WHERE             (a.inventory_item_id IS NULL AND a.item_id IS NOT NULL)
				OR                (a.master_organization_id IS NULL AND a.item_id IS NOT NULL);

			EXCEPTION
				 WHEN OTHERS THEN

						/************************************************
						* Increment Failure Count for Failed Migrations *
						************************************************/

						x_failure_count := x_failure_count + 1;

						/**************************************
						* Migration DB Error Log Message      *
						**************************************/

						GMA_COMMON_LOGGING.gma_migration_central_log
						(
						p_run_id             =>       G_migration_run_id,
						p_log_level          =>       FND_LOG.LEVEL_ERROR,
						p_message_token      =>       'GMA_MIGRATION_DB_ERROR',
						p_table_name         =>       G_Table_name,
						p_context            =>       G_context,
						p_db_error           =>       SQLERRM,
						p_app_short_name     =>       'GMA'
						);

						/**************************************
						* Migration Failure Log Message       *
						**************************************/

						GMA_COMMON_LOGGING.gma_migration_central_log
						(
						p_run_id             =>       G_migration_run_id,
						p_log_level          =>       FND_LOG.LEVEL_ERROR,
						p_message_token      =>       'GMA_TABLE_MIGRATION_TABLE_FAIL',
						p_table_name         =>       G_Table_name,
						p_context            =>       G_context,
						p_db_error           =>       NULL,
						p_app_short_name     =>       'GMA'
						);

			END;

			/**********************************************
			* Handle all the rows which were not migrated *
			**********************************************/
			gmf_migration.Log_Errors  (
																p_log_level               =>          1,
																p_from_rowid              =>          NULL,
																p_to_rowid                =>          NULL
																);

			G_Table_name := 'CM_RLUP_ITM';
			G_Context := 'Rollup Items Migration';
			X_failure_count := 0;

			/********************************
			* Migration Started Log Message *
			********************************/

			GMA_COMMON_LOGGING.gma_migration_central_log
			(
			p_run_id             =>       G_migration_run_id,
			p_log_level          =>       FND_LOG.LEVEL_STATEMENT,
			p_message_token      =>       'GMA_MIGRATION_TABLE_STARTED',
			p_table_name         =>       G_Table_name,
			p_context            =>       G_context,
			p_db_error           =>       NULL,
			p_app_short_name     =>       'GMA'
			);

			/**********************************
			* Update row in CM_RLUP_ITM table *
			***********************************/

			BEGIN

				UPDATE            cm_rlup_itm a
				SET               (
													a.organization_id,
													a.inventory_item_id
													)
				=                 (
													SELECT            z.master_organization_id,
																						y.inventory_item_id
													FROM              ic_item_mst_b_mig y,
																						mtl_parameters z,
																						hr_organization_information hoi,
																						cm_rlup_ctl x
													WHERE             y.item_id = a.item_id
													AND               y.organization_id = z.organization_id
													AND               hoi.organization_id = z.organization_id
													AND               hoi.org_information_context = 'Accounting Information'
													AND               hoi.org_information2 = x.legal_entity_id
													AND               x.rollup_id = a.rollup_id
													AND               ROWNUM = 1
													)
				WHERE             (a.inventory_item_id IS NULL AND a.item_id IS NOT NULL)
				OR                (a.organization_id IS NULL AND a.item_id IS NOT NULL);

			EXCEPTION
				 WHEN OTHERS THEN

						/************************************************
						* Increment Failure Count for Failed Migrations *
						************************************************/

						x_failure_count := x_failure_count + 1;

						/**************************************
						* Migration DB Error Log Message      *
						**************************************/

						GMA_COMMON_LOGGING.gma_migration_central_log
						(
						p_run_id             =>       G_migration_run_id,
						p_log_level          =>       FND_LOG.LEVEL_ERROR,
						p_message_token      =>       'GMA_MIGRATION_DB_ERROR',
						p_table_name         =>       G_Table_name,
						p_context            =>       G_context,
						p_db_error           =>       SQLERRM,
						p_app_short_name     =>       'GMA'
						);

						/**************************************
						* Migration Failure Log Message       *
						**************************************/

						GMA_COMMON_LOGGING.gma_migration_central_log
						(
						p_run_id             =>       G_migration_run_id,
						p_log_level          =>       FND_LOG.LEVEL_ERROR,
						p_message_token      =>       'GMA_TABLE_MIGRATION_TABLE_FAIL',
						p_table_name         =>       G_Table_name,
						p_context            =>       G_context,
						p_db_error           =>       NULL,
						p_app_short_name     =>       'GMA'
						);

			END;

			/**********************************************
			* Handle all the rows which were not migrated *
			**********************************************/
			gmf_migration.Log_Errors  (
																p_log_level               =>          1,
																p_from_rowid              =>          NULL,
																p_to_rowid                =>          NULL
																);

			/****************************************************************
			* Lets save the changes now based on the commit parameter       *
			****************************************************************/

			IF NVL(p_commit,'~') = FND_API.G_TRUE THEN
				 COMMIT;
			END IF;

	 EXCEPTION

			WHEN OTHERS THEN

				 /************************************************
				 * Increment Failure Count for Failed Migrations *
				 ************************************************/

				 x_failure_count := x_failure_count + 1;

				 /**************************************
				 * Migration DB Error Log Message      *
				 **************************************/

				 GMA_COMMON_LOGGING.gma_migration_central_log
				 (
				 p_run_id             =>       G_migration_run_id,
				 p_log_level          =>       FND_LOG.LEVEL_ERROR,
				 p_message_token      =>       'GMA_MIGRATION_DB_ERROR',
				 p_table_name         =>       G_Table_name,
				 p_context            =>       G_context,
				 p_param1             =>       NULL,
				 p_param2             =>       NULL,
				 p_db_error           =>       SQLERRM,
				 p_app_short_name     =>       'GMA'
				 );

				 /**************************************
				 * Migration Failure Log Message       *
				 **************************************/

				 GMA_COMMON_LOGGING.gma_migration_central_log
				 (
				 p_run_id             =>       G_migration_run_id,
				 p_log_level          =>       FND_LOG.LEVEL_ERROR,
				 p_message_token      =>       'GMA_TABLE_MIGRATION_TABLE_FAIL',
				 p_table_name         =>       G_Table_name,
				 p_context            =>       G_context,
				 p_db_error           =>       NULL,
				 p_app_short_name     =>       'GMA'
				 );

	 END Migrate_Rollup_control;

	 /**********************************************************************
	 * PROCEDURE:                                                          *
	 *   Migrate_CostUpdate_control                                        *
	 *                                                                     *
	 * DESCRIPTION:                                                        *
	 *   This PL/SQL procedure is used to migrate the Cost Update control  *
	 *   date Records                                                      *
	 *                                                                     *
	 * PARAMETERS:                                                         *
	 *   P_migration_run_id - id to use to right to migration log          *
	 *   x_exception_count  - Number of exceptions occurred.               *
	 *                                                                     *
	 * SYNOPSIS:                                                           *
	 *   Migrate_CostUpdate_control(p_migartion_id    => l_migration_id,   *
	 *                    p_commit          => 'T',                        *
	 *                    x_exception_count => l_exception_count );        *
	 *                                                                     *
	 * HISTORY                                                             *
	 *       08-Sep-2006 Created  Anand Thiyagarajan                       *
	 *                                                                     *
	 **********************************************************************/
	 PROCEDURE Migrate_CostUpdate_control
	 (
	 P_migration_run_id      IN             NUMBER,
	 P_commit                IN             VARCHAR2,
	 X_failure_count         OUT   NOCOPY   NUMBER
	 )
	 IS

			/***************************
			* PL/SQL Table Definitions *
			***************************/

			/******************
			* Local Variables *
			******************/

	 BEGIN

			G_Migration_run_id := P_migration_run_id;
			G_Table_name := 'CM_CUPD_CTL';
			G_Context := 'Cost Update control data Migration';
			X_failure_count := 0;

			/********************************
			* Migration Started Log Message *
			********************************/

			GMA_COMMON_LOGGING.gma_migration_central_log
			(
			p_run_id             =>       G_migration_run_id,
			p_log_level          =>       FND_LOG.LEVEL_STATEMENT,
			p_message_token      =>       'GMA_MIGRATION_TABLE_STARTED',
			p_table_name         =>       G_Table_name,
			p_context            =>       G_context,
			p_db_error           =>       NULL,
			p_app_short_name     =>       'GMA'
			);


			/**********************************
			* Update row in CM_ACPR_CTL table *
			***********************************/

			BEGIN
				UPDATE        cm_cupd_ctl ccc
				SET           (
											ccc.legal_entity_id,
											ccc.period_id,
											ccc.cost_type_id
											)
				=
											(
											select        gps.legal_entity_id, gps.period_id, gps.cost_type_id
											from          gmf_period_statuses gps,
																		cm_mthd_mst cmm,
																		gl_plcy_mst gpm
											where         gps.calendar_code = ccc.calendar_code
											and           gpm.co_code = ccc.co_code
											and           gps.period_code = ccc.period_code
											and           cmm.cost_mthd_code = ccc.cost_mthd_code
											and           gps.legal_entity_id = gpm.legal_entity_id
											and           cmm.cost_type_id = gps.cost_type_id
											)
				where         (ccc.calendar_code is not null and ccc.legal_entity_id is null)
				OR            (ccc.cost_mthd_code is not null AND ccc.cost_type_id is null)
				OR            (ccc.calendar_code is not null and ccc.period_code is not NULL AND ccc.period_id is null);

			EXCEPTION
				 WHEN OTHERS THEN

						/************************************************
						* Increment Failure Count for Failed Migrations *
						************************************************/

						x_failure_count := x_failure_count + 1;

						/**************************************
						* Migration DB Error Log Message      *
						**************************************/

						GMA_COMMON_LOGGING.gma_migration_central_log
						(
						p_run_id             =>       G_migration_run_id,
						p_log_level          =>       FND_LOG.LEVEL_ERROR,
						p_message_token      =>       'GMA_MIGRATION_DB_ERROR',
						p_table_name         =>       G_Table_name,
						p_context            =>       G_context,
						p_db_error           =>       SQLERRM,
						p_app_short_name     =>       'GMA'
						);

						/**************************************
						* Migration Failure Log Message       *
						**************************************/

						GMA_COMMON_LOGGING.gma_migration_central_log
						(
						p_run_id             =>       G_migration_run_id,
						p_log_level          =>       FND_LOG.LEVEL_ERROR,
						p_message_token      =>       'GMA_TABLE_MIGRATION_TABLE_FAIL',
						p_table_name         =>       G_Table_name,
						p_context            =>       G_context,
						p_db_error           =>       NULL,
						p_app_short_name     =>       'GMA'
						);

			END;

			/**********************************************
			* Handle all the rows which were not migrated *
			**********************************************/
			gmf_migration.Log_Errors  (
																p_log_level               =>          1,
																p_from_rowid              =>          NULL,
																p_to_rowid                =>          NULL
																);

			/****************************************************************
			* Lets save the changes now based on the commit parameter       *
			****************************************************************/

			IF NVL(p_commit,'~') = FND_API.G_TRUE THEN
				 COMMIT;
			END IF;

	 EXCEPTION

			WHEN OTHERS THEN

				 /************************************************
				 * Increment Failure Count for Failed Migrations *
				 ************************************************/

				 x_failure_count := x_failure_count + 1;

				 /**************************************
				 * Migration DB Error Log Message      *
				 **************************************/

				 GMA_COMMON_LOGGING.gma_migration_central_log
				 (
				 p_run_id             =>       G_migration_run_id,
				 p_log_level          =>       FND_LOG.LEVEL_ERROR,
				 p_message_token      =>       'GMA_MIGRATION_DB_ERROR',
				 p_table_name         =>       G_Table_name,
				 p_context            =>       G_context,
				 p_param1             =>       NULL,
				 p_param2             =>       NULL,
				 p_db_error           =>       SQLERRM,
				 p_app_short_name     =>       'GMA'
				 );

				 /**************************************
				 * Migration Failure Log Message       *
				 **************************************/

				 GMA_COMMON_LOGGING.gma_migration_central_log
				 (
				 p_run_id             =>       G_migration_run_id,
				 p_log_level          =>       FND_LOG.LEVEL_ERROR,
				 p_message_token      =>       'GMA_TABLE_MIGRATION_TABLE_FAIL',
				 p_table_name         =>       G_Table_name,
				 p_context            =>       G_context,
				 p_db_error           =>       NULL,
				 p_app_short_name     =>       'GMA'
				 );

	 END Migrate_CostUpdate_control;

	 /**********************************************************************
	 * PROCEDURE:                                                          *
	 *   Migrate_SubLedger_control                                         *
	 *                                                                     *
	 * DESCRIPTION:                                                        *
	 *   This PL/SQL procedure is used to migrate the Sub Ledger control   *
	 *   date Records                                                      *
	 *                                                                     *
	 * PARAMETERS:                                                         *
	 *   P_migration_run_id - id to use to right to migration log          *
	 *   x_exception_count  - Number of exceptions occurred.               *
	 *                                                                     *
	 * SYNOPSIS:                                                           *
	 *   Migrate_SubLedger_control(p_migartion_id    => l_migration_id,    *
	 *                    p_commit          => 'T',                        *
	 *                    x_exception_count => l_exception_count );        *
	 *                                                                     *
	 * HISTORY                                                             *
	 *       08-Sep-2006 Created  Anand Thiyagarajan                       *
	 *                                                                     *
	 **********************************************************************/
	 PROCEDURE Migrate_SubLedger_control
	 (
	 P_migration_run_id      IN             NUMBER,
	 P_commit                IN             VARCHAR2,
	 X_failure_count         OUT   NOCOPY   NUMBER
	 )
	 IS

			/***************************
			* PL/SQL Table Definitions *
			***************************/

			/******************
			* Local Variables *
			******************/

	 BEGIN

			G_Migration_run_id := P_migration_run_id;
			G_Table_name := 'GL_SUBR_STA';
			G_Context := 'Sub Ledger control data Migration';
			X_failure_count := 0;

			/********************************
			* Migration Started Log Message *
			********************************/

			GMA_COMMON_LOGGING.gma_migration_central_log
			(
			p_run_id             =>       G_migration_run_id,
			p_log_level          =>       FND_LOG.LEVEL_STATEMENT,
			p_message_token      =>       'GMA_MIGRATION_TABLE_STARTED',
			p_table_name         =>       G_Table_name,
			p_context            =>       G_context,
			p_db_error           =>       NULL,
			p_app_short_name     =>       'GMA'
			);


			/**********************************
			* Update row in GL_SUBR_STA table *
			***********************************/

			BEGIN
				UPDATE        gl_subr_sta a
				SET           (
											a.legal_entity_id,
											a.legal_entity_name,
											a.base_currency,
											a.ledger_id,
											a.cost_mthd_code,
											a.cost_type,
											a.cost_type_id,
											a.default_cost_mthd_code,
											a.default_cost_type_id,
											a.cost_basis
											)
				=
											(
											select        gfp.legal_entity_id,
																		xep.name,
																		gfp.base_currency_code,
																		gfp.ledger_id,
																		cmm.cost_mthd_code,
																		cmm.cost_type,
																		cmm.cost_type_id,
																		dcmm.cost_mthd_code default_lot_cost_mthd_code,
																		cmm.default_lot_cost_type_id,
																		gfp.cost_basis
											from          cm_mthd_mst cmm,
																		cm_mthd_mst dcmm,
																		gl_plcy_mst gpm,
																		gmf_fiscal_policies gfp,
																		xle_entity_profiles xep
											where         gpm.co_code = a.co_code
											and           gfp.legal_entity_id = gpm.legal_entity_id
											and           xep.legal_entity_id = gfp.legal_entity_id
											and           cmm.cost_type_id = gfp.cost_type_id
											and           cmm.default_lot_cost_type_id = dcmm.cost_type_id(+)
											),
											a.post_cm_rval = decode(a.post_cm, 1, 1, 0),
											a.post_cm_cadj = 0
				where         (a.co_code is not null and a.legal_entity_id is null)
				OR            (a.co_code is not null and a.cost_type_id is null);

				UPDATE        gl_subr_sta gss
				SET           (
											gss.crev_curr_cost_type_id,
											gss.crev_curr_period_id
											)
				=
											(
											select        gps.cost_type_id , gps.period_id
											from          gmf_period_statuses gps,
																		cm_mthd_mst cmm
											where         gps.calendar_code = gss.crev_curr_calendar
											and           gps.period_code = gss.crev_curr_period
											and           cmm.cost_mthd_code = gss.crev_curr_mthd
											and           gps.legal_entity_id = gss.legal_entity_id
											and           cmm.cost_type_id = gps.cost_type_id
											),
											(
											gss.crev_prev_cost_type_id,
											gss.crev_prev_period_id
											)
				=
											(
											select        gps.cost_type_id , gps.period_id
											from          gmf_period_statuses gps,
																		cm_mthd_mst cmm
											where         gps.calendar_code = gss.crev_prev_calendar
											and           gps.period_code = gss.crev_prev_period
											and           cmm.cost_mthd_code = gss.crev_prev_mthd
											and           gps.legal_entity_id = gss.legal_entity_id
											and           cmm.cost_type_id = gps.cost_type_id
											),
											gss.period_id
				=             (
											SELECT        x.period_id
											FROM          gmf_period_statuses x
											WHERE         x.legal_entity_id = gss.legal_entity_id
											AND           x.cost_type_id    = gss.cost_type_id
											AND           gss.period_start_date between x.start_date and x.end_date
											AND           gss.period_end_date between x.start_date and x.end_date
											AND           x.delete_mark <> 1
											AND           ROWNUM = 1
											)
				where         (gss.crev_curr_mthd is not null AND gss.crev_curr_cost_type_id IS NULL)
				OR            (gss.crev_curr_calendar is not null and gss.crev_curr_period is not NULL AND gss.crev_curr_period_id is null)
				OR            (gss.crev_prev_mthd is not null AND gss.crev_prev_cost_type_id IS NULL)
				OR            (gss.crev_prev_calendar is not null and gss.crev_prev_period is not NULL AND gss.crev_prev_period_id is null)
				OR            (gss.legal_entity_id IS NOT NULL AND gss.cost_type_id IS NOT NULL AND gss.period_id IS NULL);

			EXCEPTION
				 WHEN OTHERS THEN

						/************************************************
						* Increment Failure Count for Failed Migrations *
						************************************************/

						x_failure_count := x_failure_count + 1;

						/**************************************
						* Migration DB Error Log Message      *
						**************************************/

						GMA_COMMON_LOGGING.gma_migration_central_log
						(
						p_run_id             =>       G_migration_run_id,
						p_log_level          =>       FND_LOG.LEVEL_ERROR,
						p_message_token      =>       'GMA_MIGRATION_DB_ERROR',
						p_table_name         =>       G_Table_name,
						p_context            =>       G_context,
						p_db_error           =>       SQLERRM,
						p_app_short_name     =>       'GMA'
						);

						/**************************************
						* Migration Failure Log Message       *
						**************************************/

						GMA_COMMON_LOGGING.gma_migration_central_log
						(
						p_run_id             =>       G_migration_run_id,
						p_log_level          =>       FND_LOG.LEVEL_ERROR,
						p_message_token      =>       'GMA_TABLE_MIGRATION_TABLE_FAIL',
						p_table_name         =>       G_Table_name,
						p_context            =>       G_context,
						p_db_error           =>       NULL,
						p_app_short_name     =>       'GMA'
						);

			END;

			/**********************************************
			* Handle all the rows which were not migrated *
			**********************************************/
			gmf_migration.Log_Errors  (
																p_log_level               =>          1,
																p_from_rowid              =>          NULL,
																p_to_rowid                =>          NULL
																);

			/****************************************************************
			* Lets save the changes now based on the commit parameter       *
			****************************************************************/

			IF NVL(p_commit,'~') = FND_API.G_TRUE THEN
				 COMMIT;
			END IF;

	 EXCEPTION

			WHEN OTHERS THEN

				 /************************************************
				 * Increment Failure Count for Failed Migrations *
				 ************************************************/

				 x_failure_count := x_failure_count + 1;

				 /**************************************
				 * Migration DB Error Log Message      *
				 **************************************/

				 GMA_COMMON_LOGGING.gma_migration_central_log
				 (
				 p_run_id             =>       G_migration_run_id,
				 p_log_level          =>       FND_LOG.LEVEL_ERROR,
				 p_message_token      =>       'GMA_MIGRATION_DB_ERROR',
				 p_table_name         =>       G_Table_name,
				 p_context            =>       G_context,
				 p_param1             =>       NULL,
				 p_param2             =>       NULL,
				 p_db_error           =>       SQLERRM,
				 p_app_short_name     =>       'GMA'
				 );

				 /**************************************
				 * Migration Failure Log Message       *
				 **************************************/

				 GMA_COMMON_LOGGING.gma_migration_central_log
				 (
				 p_run_id             =>       G_migration_run_id,
				 p_log_level          =>       FND_LOG.LEVEL_ERROR,
				 p_message_token      =>       'GMA_TABLE_MIGRATION_TABLE_FAIL',
				 p_table_name         =>       G_Table_name,
				 p_context            =>       G_context,
				 p_db_error           =>       NULL,
				 p_app_short_name     =>       'GMA'
				 );

	 END Migrate_SubLedger_control;

	/**********************************************************************
	* PROCEDURE:                                                          *
	*   Migrate_Cost_Warehouses                                           *
	*                                                                     *
	* DESCRIPTION:                                                        *
	*   This PL/SQL procedure is used to transform the Cost Warehouses    *
	*   data in CM_WHSE_ASC                                               *
	*                                                                     *
	* PARAMETERS:                                                         *
	*   P_migration_run_id - id to use to right to migration log          *
	*   x_exception_count  - Number of exceptions occurred.               *
	*                                                                     *
	* SYNOPSIS:                                                           *
	*   Migrate_Cost_Warehouses(p_migartion_id    => l_migration_id,      *
	*                    p_commit          => 'T',                        *
	*                    x_exception_count => l_exception_count );        *
	*                                                                     *
	* HISTORY                                                             *
	*       04-Nov-2005 Created  rseshadr                                 *
	*                                                                     *
	**********************************************************************/
	PROCEDURE Migrate_Cost_Warehouses
	(
	P_migration_run_id      IN             NUMBER,
	P_commit                IN             VARCHAR2,
	X_failure_count         OUT   NOCOPY   NUMBER
	)
	IS

			/****************
			* PL/SQL Tables *
			****************/

			/******************
			* Local Variables *
			******************/

			l_costing_organization_id           NUMBER;

			/**********
			* Cursors *
			**********/
		 CURSOR                 cur_ic_whse_mst
		 IS
		 SELECT                 a.whse_code,
														NVL(a.subinventory_ind_flag, 'N') subinventory_ind_flag,
														a.mtl_organization_id,
														a.organization_id,
														b.orgn_code,
														NVL(b.inventory_org_ind, 'N') inventory_org_ind,
														NVL(b.migrate_as_ind, 0) orgn_migrated_as_ind,
														decode(a.organization_id, a.mtl_organization_id, 'Y', 'N') same_plant_whse,
														SUM(decode(NVL(c.subinventory_ind_flag, 'N'), 'N', 0, 1)) Subinventory_count,
														DECODE(COUNT(d.cost_whse_code), 0, 'N', 'Y') cost_warehouse,
														DECODE(COUNT(f.cost_whse_code), 0, 'N', 'Y') same_plant_cost_warehouse,
														DECODE(SUM(DECODE(f.cost_whse_code, NULL, 0, DECODE(NVL(c.subinventory_ind_flag, 'N'), 'N', 0, 1))), 0, 'N', 'Y') cost_whse_is_subinv,
														DECODE(COUNT(e.whse_code), 0, 'N', 'Y') inv_warehouse
		 FROM                   ic_whse_mst a,
														sy_orgn_mst b,
														ic_whse_mst c,
														cm_whse_asc d,
														cm_whse_asc e,
														cm_whse_asc f
		 WHERE                  a.orgn_code = b.orgn_code
		 AND                    c.orgn_code = a.orgn_code
		 AND                    d.cost_whse_code(+) = a.whse_code
		 AND                    f.cost_whse_code(+) = c.whse_code
		 AND                    e.whse_code(+) = a.whse_code
		 AND                    SYSDATE BETWEEN d.eff_start_date(+) AND d.eff_end_date(+)
		 AND                    SYSDATE BETWEEN e.eff_start_date(+) AND e.eff_end_date(+)
		 AND                    SYSDATE BETWEEN f.eff_start_date(+) AND f.eff_end_date(+)
		 GROUP BY               a.whse_code,
														a.subinventory_ind_flag,
														a.mtl_organization_id,
														a.organization_id,
														b.orgn_code,
														b.inventory_org_ind,
														b.migrate_as_ind,
														b.organization_id
		 ORDER BY               a.whse_code;
	BEGIN

		G_Migration_run_id := P_migration_run_id;
		G_Table_name := 'CM_WHSE_ASC';
		G_Context := 'Cost Warehouses Migration';
		X_failure_count := 0;

		/********************************
		* Migration Started Log Message *
		********************************/

		GMA_COMMON_LOGGING.gma_migration_central_log
		(
		p_run_id             =>       G_migration_run_id,
		p_log_level          =>       FND_LOG.LEVEL_STATEMENT,
		p_message_token      =>       'GMA_MIGRATION_TABLE_STARTED',
		p_table_name         =>       G_table_name,
		p_context            =>       G_context,
		p_db_error           =>       NULL,
		p_app_short_name     =>       'GMA'
		);

		/***********************************************************************************
		* Migrate warehouse records in IC_WHSE_MST to facilitate Cost Warehouse Derivation *
		***********************************************************************************/
		FOR i IN cur_ic_whse_mst LOOP
			IF nvl(i.subinventory_ind_flag, 'N') <> 'Y' THEN            /* Migrated as Inventory Organization */
				l_costing_organization_id := i.mtl_organization_id;
			ELSE                                                        /* Migrated as Sub-Inventory */
				IF nvl(i.Subinventory_count,0) = 1  THEN                  /* Only Warehouse under the plant Migrated as Sub-Inventory */
					l_costing_organization_id := i.organization_id;
				ELSE                                                      /* More than One Sub-inventory under the plant */
					IF NVL(i.cost_warehouse,'N') = 'Y' THEN                 /* Exists as Cost Warehoue */
						IF NVL(i.orgn_migrated_as_ind, 0) IN (1, 2) THEN      /* OPM Plant Migrated as New or Existing Organization*/
							l_costing_organization_id := i.organization_id;
						ELSE                                                  /* OPM Plant Migrated as None or Inactive */
							l_costing_organization_id := i.mtl_organization_id;
						END IF;
					ELSIF NVL(i.inv_warehouse,'N') = 'Y' THEN               /* Exists as Inventory Warehoue under a Cost Warehouse */
						IF nvl(i.same_plant_whse, 'N') = 'Y'
						AND nvl(i.same_plant_cost_warehouse, 'N') = 'Y'
						AND nvl(i.cost_whse_is_subinv, 'N') = 'Y' THEN         /* OPM Plant Migrated to Own Warehouse's Organization Id */
							l_costing_organization_id := -1;
						ELSE                                                  /* Migrated to Different Warehouse's Organization Id */
							l_costing_organization_id := i.mtl_organization_id;
						END IF;
					ELSE                                                    /* Doesnt Exist as INV or Cost Warehouse */
						l_costing_organization_id := i.mtl_organization_id;
					END IF;
				END IF;
			END IF;

			UPDATE              ic_whse_mst a
			SET                 a.cost_organization_id = l_costing_organization_id
			WHERE               a.whse_code = i.whse_code;
		END LOOP;

		UPDATE                  cm_whse_asc a
		SET                     (
														a.organization_id
														)
		=                       (
														SELECT            x.cost_organization_id
														FROM              ic_whse_mst x
														WHERE             x.whse_code = a.whse_code
														),
														(
														a.cost_organization_id
														)
		=                       (
														SELECT            x.cost_organization_id
														FROM              ic_whse_mst x
														WHERE             x.whse_code = a.cost_whse_code
														);

		UPDATE                  cm_whse_asc a
		SET                     delete_mark = 1
		WHERE                   (
														ROWID NOT IN  (
																					SELECT        MIN(ROWID)
																					FROM          cm_whse_asc x
																					WHERE         x.cost_organization_id = a.cost_organization_id
																					AND           x.organization_id = a.organization_id
																					AND           x.delete_mark <> 1
																					AND           (
																												(a.eff_start_date BETWEEN x.eff_start_date AND x.eff_end_date)
																												OR
																												(a.eff_end_date BETWEEN x.eff_start_date AND x.eff_end_date)
																												)
																					)
														)
		OR                      cost_organization_id = -1;

		/**********************************************
		* Handle all the rows which were not migrated *
		**********************************************/

		SELECT               count(*)
		INTO                 x_failure_count
		FROM                 cm_whse_asc
		WHERE                (organization_id IS NULL AND whse_code IS NOT NULL)
		OR                   (cost_organization_id IS NULL AND cost_whse_code IS NOT NULL);

		IF nvl(x_failure_count,0) > 0 THEN

			/**************************************
			* Migration Failure Log Message       *
			**************************************/

			GMA_COMMON_LOGGING.gma_migration_central_log
			(
			p_run_id             =>       gmf_migration.G_migration_run_id,
			p_log_level          =>       FND_LOG.LEVEL_PROCEDURE,
			p_message_token      =>       'GMA_TABLE_MIGRATION_TABLE_FAIL',
			p_table_name         =>       gmf_migration.G_Table_name,
			p_context            =>       gmf_migration.G_context,
			p_db_error           =>       NULL,
			p_app_short_name     =>       'GMA'
			);

		ELSE

			/**************************************
			* Migration Success Log Message       *
			**************************************/

			GMA_COMMON_LOGGING.gma_migration_central_log
			(
			p_run_id             =>       G_migration_run_id,
			p_log_level          =>       FND_LOG.LEVEL_STATEMENT,
			p_message_token      =>       'GMA_MIGRATION_TABLE_SUCCESS',
			p_table_name         =>       G_Table_name,
			p_context            =>       G_Context,
			p_param1             =>       1,
			p_param2             =>       0,
			p_db_error           =>       NULL,
			p_app_short_name     =>       'GMA'
			);

		END IF;

		/****************************************************************
		* Lets save the changes now based on the commit parameter       *
		****************************************************************/

		IF NVL(p_commit,'~') = FND_API.G_TRUE THEN
			 COMMIT;
		END IF;

	 EXCEPTION
			WHEN OTHERS THEN

				 /************************************************
				 * Increment Failure Count for Failed Migrations *
				 ************************************************/
				 x_failure_count := x_failure_count + 1;

				 /**************************************
				 * Migration DB Error Log Message      *
				 **************************************/

				 GMA_COMMON_LOGGING.gma_migration_central_log
				 (
				 p_run_id             =>       G_migration_run_id,
				 p_log_level          =>       FND_LOG.LEVEL_ERROR,
				 p_message_token      =>       'GMA_MIGRATION_DB_ERROR',
				 p_table_name         =>       G_table_name,
				 p_context            =>       G_context,
				 p_db_error           =>       SQLERRM,
				 p_app_short_name     =>       'GMA'
				 );

				 /**************************************
				 * Migration Failure Log Message       *
				 **************************************/

				 GMA_COMMON_LOGGING.gma_migration_central_log
				 (
				 p_run_id             =>       G_migration_run_id,
				 p_log_level          =>       FND_LOG.LEVEL_ERROR,
				 p_message_token      =>       'GMA_TABLE_MIGRATION_TABLE_FAIL',
				 p_table_name         =>       G_table_name,
				 p_context            =>       G_context,
				 p_db_error           =>       NULL,
				 p_app_short_name     =>       'GMA'
				 );

	 END Migrate_Cost_Warehouses;

	/**********************************************************************
	* PROCEDURE:                                                          *
	*   Log_Errors                                                        *
	*                                                                     *
	* DESCRIPTION:                                                        *
	*   This PL/SQL procedure is used to Log Errors from the Migration Run*
	*                                                                     *
	* PARAMETERS:                                                         *
	*                                                                     *
	* SYNOPSIS:                                                           *
	*   Log Errors;                                                       *
	*                                                                     *
	* HISTORY                                                             *
	*       23-Sep-2006 Created  Anand Thiyagarajan                       *
	*                                                                     *
	**********************************************************************/
	PROCEDURE Log_Errors
	(
	p_log_level             IN             PLS_INTEGER DEFAULT 2,
	p_from_rowid            IN             ROWID,
	p_to_rowid              IN             ROWID
	)
	IS

			/****************
			* PL/SQL Tables *
			****************/
			TYPE p_error_rec IS RECORD (table_name VARCHAR2(30), column_name VARCHAR2(30), parameters VARCHAR2(1000), records BINARY_INTEGER);
			TYPE p_error_tbl IS TABLE OF p_error_rec INDEX BY BINARY_INTEGER;

      TYPE p_cur_gmf_log_errors IS REF CURSOR;

			/******************
			* Local Variables *
			******************/
			l_error_tbl                     p_error_tbl;
			l_table_name                    VARCHAR2(256) := gmf_migration.G_Table_name;
			l_sql_statement                 VARCHAR2(32000) := 'SELECT count(*) FROM '||l_table_name||' WHERE ';
			l_failure_count                 NUMBER;
			l_legal_entity_count            PLS_INTEGER := 0;
			l_organization_count            PLS_INTEGER := 0;
			l_source_organization_count     PLS_INTEGER := 0;
			l_master_organization_count     PLS_INTEGER := 0;
			l_inventory_item_count          PLS_INTEGER := 0;
      l_lot_number_count              PLS_INTEGER := 0;
			l_cost_type_count               PLS_INTEGER := 0;
			l_prev_cost_type_count          PLS_INTEGER := 0;
			l_curr_cost_type_count          PLS_INTEGER := 0;
			l_period_count                  PLS_INTEGER := 0;
			l_prev_period_count             PLS_INTEGER := 0;
			l_curr_period_count             PLS_INTEGER := 0;
			l_adjustment_ind_count          PLS_INTEGER := 0;
			l_uom_count1                    PLS_INTEGER := 0;
			l_uom_count2                    PLS_INTEGER := 0;
			l_uom_count3                    PLS_INTEGER := 0;
			l_unique_error_count            PLS_INTEGER := 0;
			l_not_null_error_count          PLS_INTEGER := 0;
			l_value_error_count             PLS_INTEGER := 0;
			l_parent_key_error_count        PLS_INTEGER := 0;
			l_too_long_error_count          PLS_INTEGER := 0;
			l_invalid_number_error_count    PLS_INTEGER := 0;
      l_not_picked_up_error_count     PLS_INTEGER := 0;
			l_total_error_count             PLS_INTEGER := 0;

			l_cm_rsrc_dtl                   VARCHAR2(32000) := 'SELECT                ''CM_RSRC_DTL'' table_name,
                                                  														  cm_rsrc_dtl.*
                                                    			FROM                  (
                                                    														SELECT                ''LEGAL_ENTITY_ID'' column_name,
                                                    																									''Orgn Code: ''|| orgn_code parameters,
                                                    																									count(*) records
                                                    														FROM                  cm_rsrc_dtl
                                                    														WHERE                 (legal_entity_id IS NULL AND orgn_code IS NOT NULL)
                                                    														GROUP BY              orgn_code
                                                    														HAVING                count(*) > 0
                                                    														UNION
                                                    														SELECT                ''ORGANIZATION_ID'' column_name,
                                                    																									''Orgn Code: ''|| orgn_code parameters,
                                                    																									count(*) records
                                                    														FROM                  cm_rsrc_dtl
                                                    														WHERE                 (organization_id IS NULL AND delete_mark = 0 AND orgn_code IS NOT NULL)
                                                    														GROUP BY              orgn_code
                                                    														HAVING                count(*) > 0
                                                    														UNION
                                                    														SELECT                ''COST_TYPE_ID'' column_name,
                                                    																									''Cost Method Code: ''|| cost_mthd_code parameters,
                                                    																									count(*) records
                                                    														FROM                  cm_rsrc_dtl
                                                    														WHERE                 (cost_type_id IS NULL AND cost_mthd_code IS NOT NULL)
                                                    														GROUP BY              cost_mthd_code
                                                    														HAVING                count(*) > 0
                                                    														UNION
                                                    														SELECT                ''PERIOD_ID'' column_name,
                                                    																									''Calendar Code: ''|| calendar_code ||'', Period Code: ''|| period_code parameters,
                                                    																									count(*) records
                                                    														FROM                  cm_rsrc_dtl
                                                    														WHERE                 (period_id IS NULL AND calendar_code IS NOT NULL AND period_code IS NOT NULL)
                                                    														GROUP BY              calendar_code, period_code
                                                    														HAVING                count(*) > 0
                                                    														UNION
                                                    														SELECT                ''USAGE_UOM'' column_name,
                                                    																									''UM Code: ''|| usage_um parameters,
                                                    																									count(*) records
                                                    														FROM                  cm_rsrc_dtl
                                                    														WHERE                 (usage_uom IS NULL AND usage_um IS NOT NULL)
                                                    														GROUP BY              usage_um
                                                    														HAVING                count(*) > 0
                                                    														) cm_rsrc_dtl';
			l_cm_adjs_dtl                   VARCHAR2(32000) := 'SELECT                ''CM_ADJS_DTL'' table_name,
                                                                                cm_adjs_dtl.*
                                                            FROM                (
                                                                                SELECT                ''ORGANIZATION_ID'' column_name,
                                                                                                      ''Warehouse Code: ''|| whse_code parameters,
                                                                                                      count(*) records
                                                                                FROM                  cm_adjs_dtl
                                                                                WHERE                 (organization_id IS NULL AND whse_code IS NOT NULL)
                                                                                GROUP BY              whse_code
                                                                                HAVING                count(*) > 0
                                                                                UNION
                                                                                SELECT                ''INVENTORY_ITEM_ID'' column_name,
                                                                                                      ''Item No: ''|| b.item_no parameters,
                                                                                                      count(*) records
                                                                                FROM                  cm_adjs_dtl a, ic_item_mst b
                                                                                WHERE                 (a.inventory_item_id IS NULL AND a.item_id IS NOT NULL)
                                                                                AND                   b.item_id = a.item_id
                                                                                GROUP BY              b.item_no
                                                                                HAVING                count(*) > 0
                                                                                UNION
                                                                                SELECT                ''COST_TYPE_ID'' column_name,
                                                                                                      ''Cost Method Code: ''|| cost_mthd_code parameters,
                                                                                                      count(*) records
                                                                                FROM                  cm_adjs_dtl
                                                                                WHERE                 (cost_type_id IS NULL AND cost_mthd_code IS NOT NULL)
                                                                                GROUP BY              cost_mthd_code
                                                                                HAVING                count(*) > 0
                                                                                UNION
                                                                                SELECT                ''PERIOD_ID'' column_name,
                                                                                                      ''Calendar Code: ''|| calendar_code ||'', Period Code: ''|| period_code parameters,
                                                                                                      count(*) records
                                                                                FROM                  cm_adjs_dtl
                                                                                WHERE                 (period_id IS NULL AND calendar_code IS NOT NULL AND period_code IS NOT NULL)
                                                                                GROUP BY              calendar_code, period_code
                                                                                HAVING                count(*) > 0
                                                                                UNION
                                                                                SELECT                ''ADJUST_QTY_UOM'' column_name,
                                                                                                      ''Adjust qty UM: ''|| adjust_qty_um parameters,
                                                                                                      count(*) records
                                                                                FROM                  cm_adjs_dtl
                                                                                WHERE                 (adjust_qty_uom IS NULL AND adjust_qty_um IS NOT NULL)
                                                                                GROUP BY              adjust_qty_um
                                                                                HAVING                count(*) > 0
                                                                                UNION
                                                                                SELECT                ''ADJUSTMENT_IND'' column_name,
                                                                                                      ''NULL'' parameters,
                                                                                                      count(*) records
                                                                                FROM                  cm_adjs_dtl
                                                                                WHERE                 (adjustment_ind IS NULL)
                                                                                HAVING                count(*) > 0
                                                                                ) cm_adjs_dtl';
			l_cm_cmpt_dtl                   VARCHAR2(32000) := 'SELECT                ''CM_CMPT_DTL'' table_name,
                                                    														cm_cmpt_dtl.*
                                                    			FROM                  (
                                                    														SELECT                ''ORGANIZATION_ID'' column_name,
                                                    																									''Warehouse Code: ''|| whse_code parameters,
                                                    																									count(*) records
                                                    														FROM                  cm_cmpt_dtl
                                                    														WHERE                 (organization_id IS NULL AND whse_code IS NOT NULL)
                                                    														GROUP BY              whse_code
                                                    														HAVING                count(*) > 0
                                                    														UNION
                                                    														SELECT                ''INVENTORY_ITEM_ID'' column_name,
                                                    																									''Item No: ''|| b.item_no parameters,
                                                    																									count(*) records
                                                    														FROM                  cm_cmpt_dtl a, ic_item_mst b
                                                    														WHERE                 (a.inventory_item_id IS NULL AND a.item_id IS NOT NULL)
                                                    														AND                   b.item_id = a.item_id
                                                    														GROUP BY              b.item_no
                                                    														HAVING                count(*) > 0
                                                    														UNION
                                                    														SELECT                ''COST_TYPE_ID'' column_name,
                                                    																									''Cost Method Code: ''|| cost_mthd_code parameters,
                                                    																									count(*) records
                                                    														FROM                  cm_cmpt_dtl
                                                    														WHERE                 (cost_type_id IS NULL AND cost_mthd_code IS NOT NULL)
                                                    														GROUP BY              cost_mthd_code
                                                    														HAVING                count(*) > 0
                                                    														UNION
                                                    														SELECT                ''PERIOD_ID'' column_name,
                                                    																									''Calendar Code: ''|| calendar_code ||'', Period Code: ''|| period_code parameters,
                                                    																									count(*) records
                                                    														FROM                  cm_cmpt_dtl
                                                    														WHERE                 (period_id IS NULL AND calendar_code IS NOT NULL AND period_code IS NOT NULL)
                                                    														GROUP BY              calendar_code, period_code
                                                    														HAVING                count(*) > 0
                                                    														) cm_cmpt_dtl';
      l_cm_brdn_dtl                   VARCHAR2(32000) := 'SELECT                ''CM_BRDN_DTL'' table_name,
                                                      														cm_brdn_dtl.*
                                                          FROM                  (
                                                                                SELECT                ''ORGANIZATION_ID'' column_name,
                                                                                                      ''Warehouse Code: ''|| whse_code parameters,
                                                                                                      count(*) records
                                                                                FROM                  cm_brdn_dtl
                                                                                WHERE                 (organization_id IS NULL AND whse_code IS NOT NULL)
                                                                                GROUP BY              whse_code
                                                                                HAVING                count(*) > 0
                                                                                UNION
                                                                                SELECT                ''INVENTORY_ITEM_ID'' column_name,
                                                                                                      ''Item No: ''|| b.item_no parameters,
                                                                                                      count(*) records
                                                                                FROM                  cm_brdn_dtl a, ic_item_mst b
                                                                                WHERE                 (a.inventory_item_id IS NULL AND a.item_id IS NOT NULL)
                                                                                AND                   b.item_id = a.item_id
                                                                                GROUP BY              b.item_no
                                                                                HAVING                count(*) > 0
                                                                                UNION
                                                                                SELECT                ''COST_TYPE_ID'' column_name,
                                                                                                      ''Cost Method Code: ''|| cost_mthd_code parameters,
                                                                                                      count(*) records
                                                                                FROM                  cm_brdn_dtl
                                                                                WHERE                 (cost_type_id IS NULL AND cost_mthd_code IS NOT NULL)
                                                                                GROUP BY              cost_mthd_code
                                                                                HAVING                count(*) > 0
                                                                                UNION
                                                                                SELECT                ''PERIOD_ID'' column_name,
                                                                                                      ''Calendar Code: ''|| calendar_code ||'', Period Code: ''|| period_code parameters,
                                                                                                      count(*) records
                                                                                FROM                  cm_brdn_dtl
                                                                                WHERE                 (period_id IS NULL AND calendar_code IS NOT NULL AND period_code IS NOT NULL)
                                                                                GROUP BY              calendar_code, period_code
                                                                                HAVING                count(*) > 0
                                                                                UNION
                                                                                SELECT                ''ITEM_UOM'' column_name,
                                                                                                      ''Item UM: ''|| item_um parameters,
                                                                                                      count(*) records
                                                                                FROM                  cm_brdn_dtl
                                                                                WHERE                 (item_uom IS NULL AND item_um IS NOT NULL)
                                                                                GROUP BY              item_um
                                                                                HAVING                count(*) > 0
                                                                                UNION
                                                                                SELECT                ''BURDEN_UOM'' column_name,
                                                                                                      ''Burden UM: ''|| burden_um parameters,
                                                                                                      count(*) records
                                                                                FROM                  cm_brdn_dtl
                                                                                WHERE                 (burden_uom IS NULL AND burden_um IS NOT NULL)
                                                                                GROUP BY              burden_um
                                                                                HAVING                count(*) > 0
                                                                                ) cm_brdn_dtl';
			l_gl_item_cst                   VARCHAR2(32000) := 'SELECT                ''GL_ITEM_CST'' table_name,
                                                                                  gl_item_cst.*
                                                          FROM                  (
                                                                                SELECT                ''ORGANIZATION_ID'' column_name,
                                                                                                      ''Warehouse Code: ''|| whse_code parameters,
                                                                                                      count(*) records
                                                                                FROM                  gl_item_cst
                                                                                WHERE                 (organization_id IS NULL AND whse_code IS NOT NULL)
                                                                                GROUP BY              whse_code
                                                                                HAVING                count(*) > 0
                                                                                UNION
                                                                                SELECT                ''INVENTORY_ITEM_ID'' column_name,
                                                                                                      ''Item No: ''|| b.item_no parameters,
                                                                                                      count(*) records
                                                                                FROM                  gl_item_cst a, ic_item_mst b
                                                                                WHERE                 (a.inventory_item_id IS NULL AND a.item_id IS NOT NULL)
                                                                                AND                   b.item_id = a.item_id
                                                                                GROUP BY              b.item_no
                                                                                HAVING                count(*) > 0
                                                                                UNION
                                                                                SELECT                ''COST_TYPE_ID'' column_name,
                                                                                                      ''Cost Method Code: ''|| cost_mthd_code parameters,
                                                                                                      count(*) records
                                                                                FROM                  gl_item_cst
                                                                                WHERE                 (cost_type_id IS NULL AND cost_mthd_code IS NOT NULL)
                                                                                GROUP BY              cost_mthd_code
                                                                                HAVING                count(*) > 0
                                                                                UNION
                                                                                SELECT                ''PERIOD_ID'' column_name,
                                                                                                      ''Calendar Code: ''|| calendar_code ||'', Period Code: ''|| period_code parameters,
                                                                                                      count(*) records
                                                                                FROM                  gl_item_cst
                                                                                WHERE                 (period_id IS NULL AND calendar_code IS NOT NULL AND period_code IS NOT NULL)
                                                                                GROUP BY              calendar_code, period_code
                                                                                HAVING                count(*) > 0
                                                                                ) gl_item_cst';
      l_cm_scst_led                   VARCHAR2(32000) := 'SELECT                ''CM_SCST_LED'' table_name,
                                                      														cm_scst_led.*
                                                          FROM                  (
                                                                                SELECT                ''ORGANIZATION_ID'' column_name,
                                                                                                      ''Warehouse Code: ''|| whse_code parameters,
                                                                                                      count(*) records
                                                                                FROM                  cm_scst_led
                                                                                WHERE                 (organization_id IS NULL AND whse_code IS NOT NULL)
                                                                                GROUP BY              whse_code
                                                                                HAVING                count(*) > 0
                                                                                UNION
                                                                                SELECT                ''INVENTORY_ITEM_ID'' column_name,
                                                                                                      ''Item No: ''|| b.item_no parameters,
                                                                                                      count(*) records
                                                                                FROM                  cm_scst_led a, ic_item_mst b
                                                                                WHERE                 (a.inventory_item_id IS NULL AND a.item_id IS NOT NULL)
                                                                                AND                   b.item_id = a.item_id
                                                                                GROUP BY              b.item_no
                                                                                HAVING                count(*) > 0
                                                                                UNION
                                                                                SELECT                ''FORM_PROD_UOM'' column_name,
                                                                                                      ''Formula UM: ''|| form_prod_um parameters,
                                                                                                      count(*) records
                                                                                FROM                  cm_scst_led
                                                                                WHERE                 (form_prod_uom IS NULL AND form_prod_um IS NOT NULL)
                                                                                GROUP BY              form_prod_um
                                                                                HAVING                count(*) > 0
                                                                                UNION
                                                                                SELECT                ''ITEM_FMQTY_UOM'' column_name,
                                                                                                      ''Item UOM: ''|| item_fmqty_um parameters,
                                                                                                      count(*) records
                                                                                FROM                  cm_scst_led
                                                                                WHERE                 (item_fmqty_uom IS NULL AND item_fmqty_um IS NOT NULL)
                                                                                GROUP BY              item_fmqty_um
                                                                                HAVING                count(*) > 0
                                                                                UNION
                                                                                SELECT                ''USAGE_UOM'' column_name,
                                                                                                      ''Usage UOM: ''|| usage_um parameters,
                                                                                                      count(*) records
                                                                                FROM                  cm_scst_led
                                                                                WHERE                 (usage_uom IS NULL AND usage_um IS NOT NULL)
                                                                                GROUP BY              usage_um
                                                                                HAVING                count(*) > 0
                                                                                ) cm_scst_led';
			l_cm_acst_led                   VARCHAR2(32000) := 'SELECT                ''CM_ACST_LED'' table_name,
                                                    														cm_acst_led.*
                                                    			FROM                  (
                                                    														SELECT                ''ORGANIZATION_ID'' column_name,
                                                    																									''Warehouse Code: ''|| whse_code parameters,
                                                    																									count(*) records
                                                    														FROM                  cm_acst_led
                                                    														WHERE                 (organization_id IS NULL AND whse_code IS NOT NULL)
                                                    														GROUP BY              whse_code
                                                    														HAVING                count(*) > 0
                                                    														UNION
                                                    														SELECT                ''INVENTORY_ITEM_ID'' column_name,
                                                    																									''Item No: ''|| b.item_no parameters,
                                                    																									count(*) records
                                                    														FROM                  cm_acst_led a, ic_item_mst b
                                                    														WHERE                 (a.inventory_item_id IS NULL AND a.item_id IS NOT NULL)
                                                    														AND                   b.item_id = a.item_id
                                                    														GROUP BY              b.item_no
                                                    														HAVING                count(*) > 0
                                                    														UNION
                                                    														SELECT                ''COST_TYPE_ID'' column_name,
                                                    																									''Cost Method Code: ''|| cost_mthd_code parameters,
                                                    																									count(*) records
                                                    														FROM                  cm_acst_led
                                                    														WHERE                 (cost_type_id IS NULL AND cost_mthd_code IS NOT NULL)
                                                    														GROUP BY              cost_mthd_code
                                                    														HAVING                count(*) > 0
                                                    														UNION
                                                    														SELECT                ''PERIOD_ID'' column_name,
                                                    																									''Calendar Code: ''|| calendar_code ||'', Period Code: ''|| period_code parameters,
                                                    																									count(*) records
                                                    														FROM                  cm_acst_led
                                                    														WHERE                 (period_id IS NULL AND calendar_code IS NOT NULL AND period_code IS NOT NULL)
                                                    														GROUP BY              calendar_code, period_code
                                                    														HAVING                count(*) > 0
                                                    														) cm_acst_led';
			l_gmf_lot_costs                 VARCHAR2(32000) := 'SELECT                ''GMF_LOT_COSTS'' table_name,
                                                                                gmf_lot_costs.*
                                                          FROM                  (
                                                                                SELECT                ''ORGANIZATION_ID'' column_name,
                                                                                                      ''Warehouse Code: ''|| whse_code parameters,
                                                                                                      count(*) records
                                                                                FROM                  gmf_lot_costs
                                                                                WHERE                 (organization_id IS NULL AND whse_code IS NOT NULL)
                                                                                GROUP BY              whse_code
                                                                                HAVING                count(*) > 0
                                                                                UNION
                                                                                SELECT                ''INVENTORY_ITEM_ID'' column_name,
                                                                                                      ''Item No: ''|| b.item_no parameters,
                                                                                                      count(*) records
                                                                                FROM                  gmf_lot_costs a, ic_item_mst b
                                                                                WHERE                 (a.inventory_item_id IS NULL AND a.item_id IS NOT NULL)
                                                                                AND                   b.item_id = a.item_id
                                                                                GROUP BY              b.item_no
                                                                                HAVING                count(*) > 0
                                                                                UNION
                                                                                SELECT                ''COST_TYPE_ID'' column_name,
                                                                                                      ''Cost Method Code: ''|| cost_mthd_code parameters,
                                                                                                      count(*) records
                                                                                FROM                  gmf_lot_costs
                                                                                WHERE                 (cost_type_id IS NULL AND cost_mthd_code IS NOT NULL)
                                                                                GROUP BY              cost_mthd_code
                                                                                HAVING                count(*) > 0
                                                                                UNION
                                                                                SELECT                ''LOT_NUMBER'' column_name,
                                                                                                      ''Lot Id: ''|| lot_id parameters,
                                                                                                      count(*) records
                                                                                FROM                  gmf_lot_costs
                                                                                WHERE                 (lot_number IS NULL AND lot_id IS NOT NULL)
                                                                                GROUP BY              lot_id
                                                                                HAVING                count(*) > 0
                                                                                ) gmf_lot_costs';
			l_gmf_lot_costed_items          VARCHAR2(32000) := 'SELECT                ''GMF_LOT_COSTED_ITEMS'' table_name,
                                                    														gmf_lot_costed_items.*
                                                    			FROM                  (
                                                    														SELECT                ''LEGAL_ENTITY_ID'' column_name,
                                                    																									''Co Code: ''|| co_code parameters,
                                                    																									count(*) records
                                                    														FROM                  gmf_lot_costed_items
                                                    														WHERE                 (legal_entity_id IS NULL AND co_code IS NOT NULL)
                                                    														GROUP BY              co_code
                                                    														HAVING                count(*) > 0
                                                    														UNION
                                                    														SELECT                ''MASTER_ORGANIZATION_ID'' column_name,
                                                    																									''Item No: ''|| b.item_no ||'' Legal Entity: ''||a.legal_entity_id parameters,
                                                    																									count(*) records
                                                    														FROM                  gmf_lot_costed_items a, ic_item_mst b
                                                    														WHERE                 (a.legal_entity_id IS NULL AND a.item_id IS NOT NULL)
                                                    														AND                   b.item_id = a.item_id
                                                    														GROUP BY              b.item_no, a.legal_entity_id
                                                    														HAVING                count(*) > 0
                                                    														UNION
                                                    														SELECT                ''INVENTORY_ITEM_ID'' column_name,
                                                    																									''Item No: ''|| b.item_no parameters,
                                                    																									count(*) records
                                                    														FROM                  gmf_lot_costed_items a, ic_item_mst b
                                                    														WHERE                 (a.inventory_item_id IS NULL AND a.item_id IS NOT NULL)
                                                    														AND                   b.item_id = a.item_id
                                                    														GROUP BY              b.item_no
                                                    														HAVING                count(*) > 0
                                                    														UNION
                                                    														SELECT                ''COST_TYPE_ID'' column_name,
                                                    																									''Cost Method Code: ''|| cost_mthd_code parameters,
                                                    																									count(*) records
                                                    														FROM                  gmf_lot_costed_items
                                                    														WHERE                 (cost_type_id IS NULL AND cost_mthd_code IS NOT NULL)
                                                    														GROUP BY              cost_mthd_code
                                                    														HAVING                count(*) > 0
                                                    														) gmf_lot_costed_items';
			l_gmf_lot_cost_burdens          VARCHAR2(32000) := 'SELECT                ''GMF_LOT_COST_BURDENS'' table_name,
                                                    														gmf_lot_cost_burdens.*
                                                    			FROM                  (
                                                    														SELECT                ''ORGANIZATION_ID'' column_name,
                                                    																									''Warehouse Code: ''|| whse_code parameters,
                                                    																									count(*) records
                                                    														FROM                  gmf_lot_cost_burdens
                                                    														WHERE                 (organization_id IS NULL AND whse_code IS NOT NULL)
                                                    														GROUP BY              whse_code
                                                    														HAVING                count(*) > 0
                                                    														UNION
                                                    														SELECT                ''INVENTORY_ITEM_ID'' column_name,
                                                    																									''Item No: ''|| b.item_no parameters,
                                                    																									count(*) records
                                                    														FROM                  gmf_lot_cost_burdens a, ic_item_mst b
                                                    														WHERE                 (a.inventory_item_id IS NULL AND a.item_id IS NOT NULL)
                                                    														AND                   b.item_id = a.item_id
                                                    														GROUP BY              b.item_no
                                                    														HAVING                count(*) > 0
                                                    														UNION
                                                    														SELECT                ''COST_TYPE_ID'' column_name,
                                                    																									''Cost Method Code: ''|| cost_mthd_code parameters,
                                                    																									count(*) records
                                                    														FROM                  gmf_lot_cost_burdens
                                                    														WHERE                 (cost_type_id IS NULL AND cost_mthd_code IS NOT NULL)
                                                    														GROUP BY              cost_mthd_code
                                                    														HAVING                count(*) > 0
                                                    														UNION
                                                    														SELECT                ''ITEM_UOM'' column_name,
                                                    																									''Item UOM: ''|| Item_um parameters,
                                                    																									count(*) records
                                                    														FROM                  gmf_lot_cost_burdens
                                                    														WHERE                 (item_uom IS NULL AND item_um IS NOT NULL)
                                                    														GROUP BY              item_um
                                                    														HAVING                count(*) > 0
                                                    														UNION
                                                    														SELECT                ''RESOURCE_UOM'' column_name,
                                                    																									''Resource UOM: ''|| Resource_um parameters,
                                                    																									count(*) records
                                                    														FROM                  gmf_lot_cost_burdens
                                                    														WHERE                 (resource_uom IS NULL AND resource_um IS NOT NULL)
                                                    														GROUP BY              resource_um
                                                    														HAVING                count(*) > 0
                                                                                UNION
                                                                                SELECT                ''LOT_NUMBER'' column_name,
                                                                                                      ''Lot Id: ''|| lot_id parameters,
                                                                                                      count(*) records
                                                                                FROM                  gmf_lot_cost_burdens
                                                                                WHERE                 (lot_number IS NULL AND lot_id IS NOT NULL)
                                                                                GROUP BY              lot_id
                                                                                HAVING                count(*) > 0
                                                    														) gmf_lot_cost_burdens';
			l_gmf_lot_cost_adjustments      VARCHAR2(32000) := 'SELECT                ''GMF_LOT_COST_ADJUSTMENTS'' table_name,
                                                    														gmf_lot_cost_adjustments.*
                                                    			FROM                  (
                                                    														SELECT                ''ORGANIZATION_ID'' column_name,
                                                    																									''Warehouse Code: ''|| whse_code parameters,
                                                    																									count(*) records
                                                    														FROM                  gmf_lot_cost_adjustments
                                                    														WHERE                 (organization_id IS NULL AND whse_code IS NOT NULL)
                                                    														GROUP BY              whse_code
                                                    														HAVING                count(*) > 0
                                                    														UNION
                                                    														SELECT                ''INVENTORY_ITEM_ID'' column_name,
                                                    																									''Item No: ''|| b.item_no parameters,
                                                    																									count(*) records
                                                    														FROM                  gmf_lot_cost_adjustments a, ic_item_mst b
                                                    														WHERE                 (a.inventory_item_id IS NULL AND a.item_id IS NOT NULL)
                                                    														AND                   b.item_id = a.item_id
                                                    														GROUP BY              b.item_no
                                                    														HAVING                count(*) > 0
                                                    														UNION
                                                    														SELECT                ''COST_TYPE_ID'' column_name,
                                                    																									''Cost Method Code: ''|| cost_mthd_code parameters,
                                                    																									count(*) records
                                                    														FROM                  gmf_lot_cost_adjustments
                                                    														WHERE                 (cost_type_id IS NULL AND cost_mthd_code IS NOT NULL)
                                                    														GROUP BY              cost_mthd_code
                                                    														HAVING                count(*) > 0
                                                    														UNION
                                                    														SELECT                ''LEGAL_ENTITY_ID'' column_name,
                                                    																									''Co Code: ''|| co_code parameters,
                                                    																									count(*) records
                                                    														FROM                  gmf_lot_cost_adjustments
                                                    														WHERE                 (legal_entity_id IS NULL AND co_code IS NOT NULL)
                                                    														GROUP BY              co_code
                                                    														HAVING                count(*) > 0
                                                                                UNION
                                                                                SELECT                ''LOT_NUMBER'' column_name,
                                                                                                      ''Lot Id: ''|| lot_id parameters,
                                                                                                      count(*) records
                                                                                FROM                  gmf_lot_cost_adjustments
                                                                                WHERE                 (lot_number IS NULL AND lot_id IS NOT NULL)
                                                                                GROUP BY              lot_id
                                                                                HAVING                count(*) > 0
                                                    														) gmf_lot_cost_adjustments';
			l_gmf_material_lot_cost_txns    VARCHAR2(32000) := 'SELECT                ''GMF_MATERIAL_LOT_COST_TXNS'' table_name,
                                                                                gmf_material_lot_cost_txns.*
                                                          FROM                  (
                                                                                SELECT                ''COST_TYPE_ID'' column_name,
                                                                                                      ''Cost Type Code: ''|| cost_type_code parameters,
                                                                                                      count(*) records
                                                                                FROM                  gmf_material_lot_cost_txns
                                                                                WHERE                 (cost_type_id IS NULL AND cost_type_code IS NOT NULL)
                                                                                GROUP BY              cost_type_code
                                                                                HAVING                count(*) > 0
                                                                                UNION
                                                                                SELECT                ''COST_TRANS_UOM'' column_name,
                                                                                                      ''Cost Trans UOM: ''|| cost_trans_uom parameters,
                                                                                                      count(*) records
                                                                                FROM                  gmf_material_lot_cost_txns
                                                                                WHERE                 (cost_trans_um IS NULL AND cost_trans_uom IS NOT NULL)
                                                                                GROUP BY              cost_trans_uom
                                                                                HAVING                count(*) > 0
                                                                                ) gmf_material_lot_cost_txns';
			l_cm_whse_src                   VARCHAR2(32000) := 'SELECT                ''CM_WHSE_SRC'' table_name,
                                                                                cm_whse_src.*
                                                          FROM                  (
                                                                                SELECT                ''SOURCE_ORGANIZATION_ID'' column_name,
                                                                                                      ''Warehouse Code: ''|| whse_code parameters,
                                                                                                      count(*) records
                                                                                FROM                  cm_whse_src
                                                                                WHERE                 (source_organization_id IS NULL AND whse_code IS NOT NULL)
                                                                                GROUP BY              whse_code
                                                                                HAVING                count(*) > 0
                                                                                UNION
                                                                                SELECT                ''ORGANIZATION_ID'' column_name,
                                                                                                      ''Orgn Code: ''|| orgn_code parameters,
                                                                                                      count(*) records
                                                                                FROM                  cm_whse_src
                                                                                WHERE                 (organization_id IS NULL AND orgn_code IS NOT NULL AND delete_mark = 0)
                                                                                GROUP BY              orgn_code
                                                                                HAVING                count(*) > 0
                                                                                UNION
                                                                                SELECT                ''MASTER_ORGANIZATION_ID'' column_name,
                                                                                                      ''Item No: ''|| b.item_no ||'' Legal Entity: ''||a.legal_entity_id parameters,
                                                                                                      count(*) records
                                                                                FROM                  cm_whse_src a, ic_item_mst b
                                                                                WHERE                 (a.legal_entity_id IS NULL AND a.item_id IS NOT NULL)
                                                                                AND                   b.item_id = a.item_id
                                                                                GROUP BY              b.item_no, a.legal_entity_id
                                                                                HAVING                count(*) > 0
                                                                                UNION
                                                                                SELECT                ''INVENTORY_ITEM_ID'' column_name,
                                                                                                      ''Item No: ''|| b.item_no parameters,
                                                                                                      count(*) records
                                                                                FROM                  cm_whse_src a, ic_item_mst b
                                                                                WHERE                 (a.inventory_item_id IS NULL AND a.item_id IS NOT NULL)
                                                                                AND                   b.item_id = a.item_id
                                                                                GROUP BY              b.item_no
                                                                                HAVING                count(*) > 0
                                                                                UNION
                                                                                SELECT                ''LEGAL_ENTITY_ID'' column_name,
                                                                                                      ''Orgn Code: ''|| orgn_code parameters,
                                                                                                      count(*) records
                                                                                FROM                  cm_whse_src
                                                                                WHERE                 (legal_entity_id IS NULL AND orgn_code IS NOT NULL)
                                                                                GROUP BY              orgn_code
                                                                                HAVING                count(*) > 0
                                                                                ) cm_whse_src';
			l_cm_acpr_ctl                   VARCHAR2(32000) := 'SELECT                ''CM_ACPR_CTL'' table_name,
                                                    														cm_acpr_ctl.*
                                                    			FROM                  (
                                                    														SELECT                ''COST_TYPE_ID'' column_name,
                                                    																									''Cost Method Code: ''|| cost_mthd_code parameters,
                                                    																									count(*) records
                                                    														FROM                  cm_acpr_ctl
                                                    														WHERE                 (cost_type_id IS NULL AND cost_mthd_code IS NOT NULL)
                                                    														GROUP BY              cost_mthd_code
                                                    														HAVING                count(*) > 0
                                                    														UNION
                                                    														SELECT                ''PERIOD_ID'' column_name,
                                                    																									''Calendar Code: ''|| calendar_code ||'', Period Code: ''|| period_code parameters,
                                                    																									count(*) records
                                                    														FROM                  cm_acpr_ctl
                                                    														WHERE                 (period_id IS NULL AND calendar_code IS NOT NULL AND period_code IS NOT NULL)
                                                    														GROUP BY              calendar_code, period_code
                                                    														HAVING                count(*) > 0
                                                    														UNION
                                                    														SELECT                ''LEGAL_ENTITY_ID'' column_name,
                                                    																									''Calendar Code: ''|| calendar_code parameters,
                                                    																									count(*) records
                                                    														FROM                  cm_acpr_ctl
                                                    														WHERE                 (legal_entity_id IS NULL AND calendar_code IS NOT NULL)
                                                    														GROUP BY              calendar_code
                                                    														HAVING                count(*) > 0
                                                    														) cm_acpr_ctl';
			l_cm_rlup_ctl                   VARCHAR2(32000) := 'SELECT                ''CM_RLUP_CTL'' table_name,
                                                    														cm_rlup_ctl.*
                                                    			FROM                  (
                                                    														SELECT                ''COST_TYPE_ID'' column_name,
                                                    																									''Cost Method Code: ''|| cost_mthd_code parameters,
                                                    																									count(*) records
                                                    														FROM                  cm_rlup_ctl
                                                    														WHERE                 (cost_type_id IS NULL AND cost_mthd_code IS NOT NULL)
                                                    														GROUP BY              cost_mthd_code
                                                    														HAVING                count(*) > 0
                                                    														UNION
                                                    														SELECT                ''PERIOD_ID'' column_name,
                                                    																									''Calendar Code: ''|| calendar_code ||'', Period Code: ''|| period_code parameters,
                                                    																									count(*) records
                                                    														FROM                  cm_rlup_ctl
                                                    														WHERE                 (period_id IS NULL AND calendar_code IS NOT NULL AND period_code IS NOT NULL)
                                                    														GROUP BY              calendar_code, period_code
                                                    														HAVING                count(*) > 0
                                                    														UNION
                                                    														SELECT                ''LEGAL_ENTITY_ID'' column_name,
                                                    																									''Calendar Code: ''|| calendar_code parameters,
                                                    																									count(*) records
                                                    														FROM                  cm_rlup_ctl
                                                    														WHERE                 (legal_entity_id IS NULL AND calendar_code IS NOT NULL)
                                                    														GROUP BY              calendar_code
                                                    														HAVING                count(*) > 0
                                                    														UNION
                                                    														SELECT                ''MASTER_ORGANIZATION_ID'' column_name,
                                                    																									''Item No: ''|| b.item_no ||'' Legal Entity: ''||a.legal_entity_id parameters,
                                                    																									count(*) records
                                                    														FROM                  cm_rlup_ctl a, ic_item_mst b
                                                    														WHERE                 (a.legal_entity_id IS NULL AND a.item_id IS NOT NULL)
                                                    														AND                   b.item_id = a.item_id
                                                    														GROUP BY              b.item_no, a.legal_entity_id
                                                    														HAVING                count(*) > 0
                                                    														UNION
                                                    														SELECT                ''INVENTORY_ITEM_ID'' column_name,
                                                    																									''Item No: ''|| b.item_no parameters,
                                                    																									count(*) records
                                                    														FROM                  cm_rlup_ctl a, ic_item_mst b
                                                    														WHERE                 (a.inventory_item_id IS NULL AND a.item_id IS NOT NULL)
                                                    														AND                   b.item_id = a.item_id
                                                    														GROUP BY              b.item_no
                                                    														HAVING                count(*) > 0
                                                    														) cm_rlup_ctl';
			l_cm_rlup_itm                   VARCHAR2(32000) := 'SELECT                ''CM_RLUP_ITM'' table_name,
                                                    														cm_rlup_itm.*
                                                    			FROM                  (
                                                    														SELECT                ''ORGANIZATION_ID'' column_name,
                                                    																									''Item No: ''|| b.item_no ||'' Legal Entity: ''||c.legal_entity_id parameters,
                                                    																									count(*) records
                                                    														FROM                  cm_rlup_ctl a, ic_item_mst b, cm_rlup_ctl c
                                                    														WHERE                 (a.legal_entity_id IS NULL AND a.item_id IS NOT NULL)
                                                    														AND                   b.item_id = a.item_id
                                                    														AND                   c.rollup_id = a.rollup_id
                                                    														GROUP BY              b.item_no, c.legal_entity_id
                                                    														HAVING                count(*) > 0
                                                    														UNION
                                                    														SELECT                ''INVENTORY_ITEM_ID'' column_name,
                                                    																									''Item No: ''|| b.item_no parameters,
                                                    																									count(*) records
                                                    														FROM                  cm_rlup_itm a, ic_item_mst b
                                                    														WHERE                 (a.inventory_item_id IS NULL AND a.item_id IS NOT NULL)
                                                    														AND                   b.item_id = a.item_id
                                                    														GROUP BY              b.item_no
                                                    														HAVING                count(*) > 0
                                                    														) cm_rlup_itm';
      l_cm_cupd_ctl                   VARCHAR2(32000) := 'SELECT                ''CM_CUPD_CTL'' table_name,
                                                                                cm_cupd_ctl.*
                                                          FROM                  (
                                                                                SELECT                ''COST_TYPE_ID'' column_name,
                                                                                                      ''Cost Method Code: ''|| cost_mthd_code parameters,
                                                                                                      count(*) records
                                                                                FROM                  cm_cupd_ctl
                                                                                WHERE                 (cost_type_id IS NULL AND cost_mthd_code IS NOT NULL)
                                                                                GROUP BY              cost_mthd_code
                                                                                HAVING                count(*) > 0
                                                                                UNION
                                                                                SELECT                ''PERIOD_ID'' column_name,
                                                                                                      ''Calendar Code: ''|| calendar_code ||'', Period Code: ''|| period_code parameters,
                                                                                                      count(*) records
                                                                                FROM                  cm_cupd_ctl
                                                                                WHERE                 (period_id IS NULL AND calendar_code IS NOT NULL AND period_code IS NOT NULL)
                                                                                GROUP BY              calendar_code, period_code
                                                                                HAVING                count(*) > 0
                                                                                UNION
                                                                                SELECT                ''LEGAL_ENTITY_ID'' column_name,
                                                                                                      ''Calendar Code: ''|| calendar_code parameters,
                                                                                                      count(*) records
                                                                                FROM                  cm_cupd_ctl
                                                                                WHERE                 (legal_entity_id IS NULL AND calendar_code IS NOT NULL)
                                                                                GROUP BY              calendar_code
                                                                                HAVING                count(*) > 0
                                                                                ) cm_cupd_ctl';
      l_gl_subr_sta                   VARCHAR2(32000) := 'SELECT                ''GL_SUBR_STA'' table_name,
                                                    														gl_subr_sta.*
                                                    			FROM                  (
                                                    														SELECT                ''CREV_CURR_COST_TYPE_ID'' column_name,
                                                    																									''Current Cost Method Code: ''|| crev_curr_mthd parameters,
                                                    																									count(*) records
                                                    														FROM                  gl_subr_sta
                                                    														WHERE                 (crev_curr_cost_type_id IS NULL AND crev_curr_mthd IS NOT NULL)
                                                    														GROUP BY              crev_curr_mthd
                                                    														HAVING                count(*) > 0
                                                    														UNION
                                                    														SELECT                ''CREV_CURR_PERIOD_ID'' column_name,
                                                    																									''Current Calendar Code: ''|| crev_curr_calendar ||'', Period Code: ''|| crev_curr_period parameters,
                                                    																									count(*) records
                                                    														FROM                  gl_subr_sta
                                                    														WHERE                 (crev_curr_calendar is not null and crev_curr_period is not NULL AND crev_curr_period_id is null)
                                                    														GROUP BY              crev_curr_calendar, crev_curr_period
                                                    														HAVING                count(*) > 0
                                                    														UNION
                                                    														SELECT                ''CREV_PREV_COST_TYPE_ID'' column_name,
                                                    																									''Previous Cost Method Code: ''|| crev_prev_mthd parameters,
                                                    																									count(*) records
                                                    														FROM                  gl_subr_sta
                                                    														WHERE                 (crev_prev_cost_type_id IS NULL AND crev_prev_mthd IS NOT NULL)
                                                    														GROUP BY              crev_prev_mthd
                                                    														HAVING                count(*) > 0
                                                    														UNION
                                                    														SELECT                ''CREV_PREV_PERIOD_ID'' column_name,
                                                    																									''Previous Calendar Code: ''|| crev_prev_calendar ||'', Period Code: ''|| crev_prev_period parameters,
                                                    																									count(*) records
                                                    														FROM                  gl_subr_sta
                                                    														WHERE                 (crev_prev_calendar is not null and crev_prev_period is not NULL AND crev_prev_period_id is null)
                                                    														GROUP BY              crev_prev_calendar, crev_prev_period
                                                    														HAVING                count(*) > 0
                                                    														UNION
                                                    														SELECT                ''LEGAL_ENTITY_ID'' column_name,
                                                    																									''Co Code: ''|| co_code parameters,
                                                    																									count(*) records
                                                    														FROM                  gl_subr_sta
                                                    														WHERE                 (legal_entity_id IS NULL AND co_code IS NOT NULL)
                                                    														GROUP BY              co_code
                                                    														HAVING                count(*) > 0
                                                    														UNION
                                                    														SELECT                ''COST_TYPE_ID'' column_name,
                                                    																									''Co Code: ''|| co_code parameters,
                                                    																									count(*) records
                                                    														FROM                  gl_subr_sta
                                                    														WHERE                 (cost_type_id IS NULL AND co_code IS NOT NULL)
                                                    														GROUP BY              co_code
                                                    														HAVING                count(*) > 0
                                                    														) gl_subr_sta';
			l_xla_rules_t                   VARCHAR2(32000) := 'SELECT                ''XLA_RULES_T'' table_name,
                                                    														xla_rules_t.*
                                                    			FROM                  (
                                                    														SELECT                ''ALL'' column_name,
                                                    																									''Unique Constraint Error'' parameters,
                                                    																									count(*) records
                                                    														FROM                  xla_rules_t
                                                    														WHERE                 error_value = -1
                                                    														HAVING                count(*) > 0
                                                    														UNION
                                                    														SELECT                ''ALL'' column_name,
                                                    																									''Not Null Constraint'' parameters,
                                                    																									count(*) records
                                                    														FROM                  xla_rules_t
                                                    														WHERE                 error_value = -1400
                                                    														HAVING                count(*) > 0
                                                    														UNION
                                                    														SELECT                ''ALL'' column_name,
                                                    																									''Invalid Value Error'' parameters,
                                                    																									count(*) records
                                                    														FROM                  xla_rules_t
                                                    														WHERE                 error_value = -6502
                                                    														HAVING                count(*) > 0
                                                    														UNION
                                                    														SELECT                ''ALL'' column_name,
                                                    																									''Parent-Key Not Found Error'' parameters,
                                                    																									count(*) records
                                                    														FROM                  xla_rules_t
                                                    														WHERE                 error_value = -2291
                                                    														HAVING                count(*) > 0
                                                    														UNION
                                                    														SELECT                ''ALL'' column_name,
                                                    																									''Value Too Long Error'' parameters,
                                                    																									count(*) records
                                                    														FROM                  xla_rules_t
                                                    														WHERE                 error_value in (-1438, -12899)
                                                    														HAVING                count(*) > 0
                                                    														UNION
                                                    														SELECT                ''ALL'' column_name,
                                                    																									''Invalid Number Error'' parameters,
                                                    																									count(*) records
                                                    														FROM                  xla_rules_t
                                                    														WHERE                 error_value = -1722
                                                    														HAVING                count(*) > 0
                                                    														UNION
                                                    														SELECT                ''ALL'' column_name,
                                                    																									''Records not Picked up'' parameters,
                                                    																									count(*) records
                                                    														FROM                  xla_rules_t
                                                    														WHERE                 error_value = 0
                                                    														HAVING                count(*) > 0
                                                    														UNION
                                                    														SELECT                ''ALL'' column_name,
                                                    																									''Other Errors'' parameters,
                                                    																									count(*) records
                                                    														FROM                  xla_rules_t
                                                    														WHERE                 error_value not in (-1, -1400, -6502, -2291, -1438, -12899, -1722, 1, 0)
                                                    														HAVING                count(*) > 0
                                                    														) xla_rules_t';
			l_xla_rule_details_t            VARCHAR2(32000) := 'SELECT                ''XLA_RULE_DETAILS_T'' table_name,
                                                    														xla_rule_details_t.*
                                                    			FROM                  (
                                                    														SELECT                ''ALL'' column_name,
                                                    																									''Unique Constraint Error'' parameters,
                                                    																									count(*) records
                                                    														FROM                  xla_rule_details_t
                                                    														WHERE                 error_value = -1
                                                    														HAVING                count(*) > 0
                                                    														UNION
                                                    														SELECT                ''ALL'' column_name,
                                                    																									''Not Null Constraint'' parameters,
                                                    																									count(*) records
                                                    														FROM                  xla_rule_details_t
                                                    														WHERE                 error_value = -1400
                                                    														HAVING                count(*) > 0
                                                    														UNION
                                                    														SELECT                ''ALL'' column_name,
                                                    																									''Invalid Value Error'' parameters,
                                                    																									count(*) records
                                                    														FROM                  xla_rule_details_t
                                                    														WHERE                 error_value = -6502
                                                    														HAVING                count(*) > 0
                                                    														UNION
                                                    														SELECT                ''ALL'' column_name,
                                                    																									''Parent-Key Not Found Error'' parameters,
                                                    																									count(*) records
                                                    														FROM                  xla_rule_details_t
                                                    														WHERE                 error_value = -2291
                                                    														HAVING                count(*) > 0
                                                    														UNION
                                                    														SELECT                ''ALL'' column_name,
                                                    																									''Value Too Long Error'' parameters,
                                                    																									count(*) records
                                                    														FROM                  xla_rule_details_t
                                                    														WHERE                 error_value in (-1438, -12899)
                                                    														HAVING                count(*) > 0
                                                    														UNION
                                                    														SELECT                ''ALL'' column_name,
                                                    																									''Invalid Number Error'' parameters,
                                                    																									count(*) records
                                                    														FROM                  xla_rule_details_t
                                                    														WHERE                 error_value = -1722
                                                    														HAVING                count(*) > 0
                                                    														UNION
                                                    														SELECT                ''ALL'' column_name,
                                                    																									''Records not Picked up'' parameters,
                                                    																									count(*) records
                                                    														FROM                  xla_rule_details_t
                                                    														WHERE                 error_value = 0
                                                    														HAVING                count(*) > 0
                                                    														UNION
                                                    														SELECT                ''ALL'' column_name,
                                                    																									''Other Errors'' parameters,
                                                    																									count(*) records
                                                    														FROM                  xla_rule_details_t
                                                    														WHERE                 error_value not in (-1, -1400, -6502, -2291, -1438, -12899, -1722, 1, 0)
                                                    														HAVING                count(*) > 0
                                                    														) xla_rule_details_t';
			l_xla_conditions_t              VARCHAR2(32000) := 'SELECT                ''XLA_CONDITIONS_T'' table_name,
                                                    														xla_conditions_t.*
                                                    			FROM                  (
                                                    														SELECT                ''ALL'' column_name,
                                                    																									''Unique Constraint Error'' parameters,
                                                    																									count(*) records
                                                    														FROM                  xla_conditions_t
                                                    														WHERE                 error_value = -1
                                                    														HAVING                count(*) > 0
                                                    														UNION
                                                    														SELECT                ''ALL'' column_name,
                                                    																									''Not Null Constraint'' parameters,
                                                    																									count(*) records
                                                    														FROM                  xla_conditions_t
                                                    														WHERE                 error_value = -1400
                                                    														HAVING                count(*) > 0
                                                    														UNION
                                                    														SELECT                ''ALL'' column_name,
                                                    																									''Invalid Value Error'' parameters,
                                                    																									count(*) records
                                                    														FROM                  xla_conditions_t
                                                    														WHERE                 error_value = -6502
                                                    														HAVING                count(*) > 0
                                                    														UNION
                                                    														SELECT                ''ALL'' column_name,
                                                    																									''Parent-Key Not Found Error'' parameters,
                                                    																									count(*) records
                                                    														FROM                  xla_conditions_t
                                                    														WHERE                 error_value = -2291
                                                    														HAVING                count(*) > 0
                                                    														UNION
                                                    														SELECT                ''ALL'' column_name,
                                                    																									''Value Too Long Error'' parameters,
                                                    																									count(*) records
                                                    														FROM                  xla_conditions_t
                                                    														WHERE                 error_value in (-1438, -12899)
                                                    														HAVING                count(*) > 0
                                                    														UNION
                                                    														SELECT                ''ALL'' column_name,
                                                    																									''Invalid Number Error'' parameters,
                                                    																									count(*) records
                                                    														FROM                  xla_conditions_t
                                                    														WHERE                 error_value = -1722
                                                    														HAVING                count(*) > 0
                                                    														UNION
                                                    														SELECT                ''ALL'' column_name,
                                                    																									''Records not Picked up'' parameters,
                                                    																									count(*) records
                                                    														FROM                  xla_conditions_t
                                                    														WHERE                 error_value = 0
                                                    														HAVING                count(*) > 0
                                                    														UNION
                                                    														SELECT                ''ALL'' column_name,
                                                    																									''Other Errors'' parameters,
                                                    																									count(*) records
                                                    														FROM                  xla_conditions_t
                                                    														WHERE                 error_value not in (-1, -1400, -6502, -2291, -1438, -12899, -1722, 1, 0)
                                                    														HAVING                count(*) > 0
                                                    														) xla_conditions_t';
			l_xla_line_assgns_t             VARCHAR2(32000) := 'SELECT                ''XLA_LINE_ASSGNS_T'' table_name,
                                                      														xla_line_assgns_t.*
                                                          FROM                  (
                                                                                SELECT                ''ALL'' column_name,
                                                                                                      ''Unique Constraint Error'' parameters,
                                                                                                      count(*) records
                                                                                FROM                  xla_line_assgns_t
                                                                                WHERE                 error_value = -1
                                                                                HAVING                count(*) > 0
                                                                                UNION
                                                                                SELECT                ''ALL'' column_name,
                                                                                                      ''Not Null Constraint'' parameters,
                                                                                                      count(*) records
                                                                                FROM                  xla_line_assgns_t
                                                                                WHERE                 error_value = -1400
                                                                                HAVING                count(*) > 0
                                                                                UNION
                                                                                SELECT                ''ALL'' column_name,
                                                                                                      ''Invalid Value Error'' parameters,
                                                                                                      count(*) records
                                                                                FROM                  xla_line_assgns_t
                                                                                WHERE                 error_value = -6502
                                                                                HAVING                count(*) > 0
                                                                                UNION
                                                                                SELECT                ''ALL'' column_name,
                                                                                                      ''Parent-Key Not Found Error'' parameters,
                                                                                                      count(*) records
                                                                                FROM                  xla_line_assgns_t
                                                                                WHERE                 error_value = -2291
                                                                                HAVING                count(*) > 0
                                                                                UNION
                                                                                SELECT                ''ALL'' column_name,
                                                                                                      ''Value Too Long Error'' parameters,
                                                                                                      count(*) records
                                                                                FROM                  xla_line_assgns_t
                                                                                WHERE                 error_value in (-1438, -12899)
                                                                                HAVING                count(*) > 0
                                                                                UNION
                                                                                SELECT                ''ALL'' column_name,
                                                                                                      ''Invalid Number Error'' parameters,
                                                                                                      count(*) records
                                                                                FROM                  xla_line_assgns_t
                                                                                WHERE                 error_value = -1722
                                                                                HAVING                count(*) > 0
                                                                                UNION
                                                                                SELECT                ''ALL'' column_name,
                                                                                                      ''Records not Picked up'' parameters,
                                                                                                      count(*) records
                                                                                FROM                  xla_line_assgns_t
                                                                                WHERE                 error_value = 0
                                                                                HAVING                count(*) > 0
                                                                                UNION
                                                                                SELECT                ''ALL'' column_name,
                                                                                                      ''Other Errors'' parameters,
                                                                                                      count(*) records
                                                                                FROM                  xla_line_assgns_t
                                                                                WHERE                 error_value not in (-1, -1400, -6502, -2291, -1438, -12899, -1722, 1, 0)
                                                                                HAVING                count(*) > 0
                                                                                ) xla_line_assgns_t';

    /*****************
    * PL/SQL Cursors *
    *****************/
    cur_gmf_log_errors              p_cur_gmf_log_errors;

	BEGIN
		/*****************************************************************************
		* ROWID's are required only when called from inside a LTU Migration Loop and *
		* it cannot be passed for a Detailed Error Log                               *
		*****************************************************************************/
		IF p_from_rowid IS NOT NULL AND p_to_rowid IS NOT NULL THEN
			IF p_log_level <> 1 THEN
				RETURN;
			ELSE
				l_sql_statement := l_sql_statement||' ROWID BETWEEN :1 AND :2 AND ';
			END IF;
		END IF;
		/**************************************************************************
		* Printing Error Log's for all tables cannot be done in Log Level 1 and 2 *
		**************************************************************************/
		IF l_table_name = 'GMF_LOG_ERRORS' AND p_log_level IN (1, 2) THEN
			RETURN;
		END IF;
		IF p_log_level IN (1, 2) THEN
			/************************************************
			* Migration Error Logging for table CM_RSRC_DTL *
			************************************************/
			IF l_table_name IN ('CM_RSRC_DTL') THEN
				IF p_log_level = 1 THEN
					l_sql_statement :=  l_sql_statement
															||
															'(                (legal_entity_id IS NULL AND orgn_code IS NOT NULL)
															OR                (cost_type_id IS NULL AND cost_mthd_code IS NOT NULL)
															OR                (period_id IS NULL AND period_code IS NOT NULL AND calendar_code is not null)
															OR                (usage_uom IS NULL AND usage_um IS NOT NULL)
															OR                (organization_id IS NULL AND delete_mark = 0 AND orgn_code IS NOT NULL)
															)';
					IF p_from_rowid IS NOT NULL AND p_to_rowid IS NOT NULL THEN
						execute IMMEDIATE l_sql_statement INTO l_failure_count using p_from_rowid, p_to_rowid;
					ELSE
						execute IMMEDIATE l_sql_statement INTO l_failure_count;
					END IF;
				ELSIF p_log_level = 2 THEN
					SELECT        SUM(CASE WHEN (legal_entity_id IS NULL AND orgn_code IS NOT NULL) THEN 1 ELSE 0 END),
												SUM(CASE WHEN (cost_type_id IS NULL AND cost_mthd_code IS NOT NULL) THEN 1 ELSE 0 END),
												SUM(CASE WHEN (period_id IS NULL AND period_code IS NOT NULL AND calendar_code IS NOT NULL) THEN 1 ELSE 0 END),
												SUM(CASE WHEN (usage_uom IS NULL AND usage_um IS NOT NULL) THEN 1 ELSE 0 END),
												SUM(CASE WHEN (organization_id IS NULL AND delete_mark = 0 AND orgn_code IS NOT NULL) THEN 1 ELSE 0 END)
					INTO          l_legal_entity_count,
												l_cost_type_count,
												l_period_count,
												l_uom_count1,
												l_organization_count
					FROM          cm_rsrc_dtl;
				END IF;
			END IF;
			/************************************************
			* Migration Error Logging for table CM_ADJS_DTL *
			************************************************/
			IF l_table_name IN ('CM_ADJS_DTL') THEN
				IF p_log_level = 1 THEN
					l_sql_statement :=  l_sql_statement
															||
															'(                (organization_id IS NULL AND whse_code IS NOT NULL)
															OR                (inventory_item_id IS NULL AND item_id IS NOT NULL)
															OR                (cost_type_id IS NULL AND cost_mthd_code IS NOT NULL)
															OR                (period_id IS NULL AND period_code IS NOT NULL AND calendar_code IS NOT NULL)
															OR                (adjust_qty_uom IS NULL AND adjust_qty_um IS NOT NULL)
															OR                (adjustment_ind IS NULL)
															)';
					IF p_from_rowid IS NOT NULL AND p_to_rowid IS NOT NULL THEN
						execute IMMEDIATE l_sql_statement INTO l_failure_count using p_from_rowid, p_to_rowid;
					ELSE
						execute IMMEDIATE l_sql_statement INTO l_failure_count;
					END IF;
				ELSIF p_log_level = 2 THEN
					SELECT        SUM(CASE WHEN (organization_id IS NULL AND whse_code IS NOT NULL) THEN 1 ELSE 0 END),
												SUM(CASE WHEN (inventory_item_id IS NULL AND item_id IS NOT NULL) THEN 1 ELSE 0 END),
												SUM(CASE WHEN (cost_type_id IS NULL AND cost_mthd_code IS NOT NULL) THEN 1 ELSE 0 END),
												SUM(CASE WHEN (period_id IS NULL AND period_code IS NOT NULL AND calendar_code IS NOT NULL) THEN 1 ELSE 0 END),
												SUM(CASE WHEN (adjust_qty_uom IS NULL AND adjust_qty_um IS NOT NULL) THEN 1 ELSE 0 END),
												SUM(CASE WHEN (adjustment_ind IS NULL) THEN 1 ELSE 0 END)
					INTO          l_organization_count,
												l_inventory_item_count,
												l_cost_type_count,
												l_period_count,
												l_uom_count1,
												l_adjustment_ind_count
					FROM          cm_adjs_dtl;
				END IF;
			END IF;
			/************************************************
			* Migration Error Logging for table CM_CMPT_DTL *
			************************************************/
			IF l_table_name IN ('CM_CMPT_DTL') THEN
				IF p_log_level = 1 THEN
					l_sql_statement :=  l_sql_statement
															||
															'(                (organization_id IS NULL AND whse_code IS NOT NULL)
															OR                (inventory_item_id IS NULL AND item_id IS NOT NULL)
															OR                (cost_type_id IS NULL AND cost_mthd_code IS NOT NULL)
															OR                (period_id IS NULL AND period_code IS NOT NULL)
															)';
					IF p_from_rowid IS NOT NULL AND p_to_rowid IS NOT NULL THEN
						execute IMMEDIATE l_sql_statement INTO l_failure_count using p_from_rowid, p_to_rowid;
					ELSE
						execute IMMEDIATE l_sql_statement INTO l_failure_count;
					END IF;
				ELSIF p_log_level = 2 THEN
					SELECT        SUM(CASE WHEN (organization_id IS NULL AND whse_code IS NOT NULL) THEN 1 ELSE 0 END),
												SUM(CASE WHEN (inventory_item_id IS NULL AND item_id IS NOT NULL) THEN 1 ELSE 0 END),
												SUM(CASE WHEN (cost_type_id IS NULL AND cost_mthd_code IS NOT NULL) THEN 1 ELSE 0 END),
												SUM(CASE WHEN (period_id IS NULL AND period_code IS NOT NULL AND calendar_code IS NOT NULL) THEN 1 ELSE 0 END)
					INTO          l_organization_count,
												l_inventory_item_count,
												l_cost_type_count,
												l_period_count
					FROM          cm_cmpt_dtl;
				END IF;
			END IF;
			/************************************************
			* Migration Error Logging for table CM_BRDN_DTL *
			************************************************/
			IF l_table_name IN ('CM_BRDN_DTL') THEN
				IF p_log_level = 1 THEN
					l_sql_statement :=  l_sql_statement
															||
															'(                (organization_id IS NULL AND whse_code IS NOT NULL)
															OR                (inventory_item_id IS NULL AND item_id IS NOT NULL)
															OR                (cost_type_id IS NULL AND cost_mthd_code IS NOT NULL)
															OR                (period_id IS NULL AND period_code IS NOT NULL)
															OR                (item_uom IS NULL AND item_um IS NOT NULL)
															OR                (burden_uom IS NULL AND burden_um IS NOT NULL)
															)';
					IF p_from_rowid IS NOT NULL AND p_to_rowid IS NOT NULL THEN
						execute IMMEDIATE l_sql_statement INTO l_failure_count using p_from_rowid, p_to_rowid;
					ELSE
						execute IMMEDIATE l_sql_statement INTO l_failure_count;
					END IF;
				ELSIF p_log_level = 2 THEN
					SELECT        SUM(CASE WHEN (organization_id IS NULL AND whse_code IS NOT NULL) THEN 1 ELSE 0 END),
												SUM(CASE WHEN (inventory_item_id IS NULL AND item_id IS NOT NULL) THEN 1 ELSE 0 END),
												SUM(CASE WHEN (cost_type_id IS NULL AND cost_mthd_code IS NOT NULL) THEN 1 ELSE 0 END),
												SUM(CASE WHEN (period_id IS NULL AND period_code IS NOT NULL AND calendar_code IS NOT NULL) THEN 1 ELSE 0 END),
												SUM(CASE WHEN (item_uom IS NULL AND item_um IS NOT NULL) THEN 1 ELSE 0 END),
												SUM(CASE WHEN (burden_uom IS NULL AND burden_um IS NOT NULL) THEN 1 ELSE 0 END)
					INTO          l_organization_count,
												l_inventory_item_count,
												l_cost_type_count,
												l_period_count,
												l_uom_count1,
												l_uom_count2
					FROM          cm_brdn_dtl;
				END IF;
			END IF;
			/************************************************
			* Migration Error Logging for table GL_ITEM_CST *
			************************************************/
			IF l_table_name IN ('GL_ITEM_CST') THEN
				IF p_log_level = 1 THEN
					l_sql_statement :=  l_sql_statement
															||
															'(                (organization_id IS NULL AND whse_code IS NOT NULL)
															OR                (inventory_item_id IS NULL AND item_id IS NOT NULL)
															OR                (cost_type_id IS NULL AND cost_mthd_code IS NOT NULL)
															OR                (period_id IS NULL AND period_code IS NOT NULL)
															)';
					IF p_from_rowid IS NOT NULL AND p_to_rowid IS NOT NULL THEN
						execute IMMEDIATE l_sql_statement INTO l_failure_count using p_from_rowid, p_to_rowid;
					ELSE
						execute IMMEDIATE l_sql_statement INTO l_failure_count;
					END IF;
				ELSIF p_log_level = 2 THEN
					SELECT        SUM(CASE WHEN (organization_id IS NULL AND whse_code IS NOT NULL) THEN 1 ELSE 0 END),
												SUM(CASE WHEN (inventory_item_id IS NULL AND item_id IS NOT NULL) THEN 1 ELSE 0 END),
												SUM(CASE WHEN (cost_type_id IS NULL AND cost_mthd_code IS NOT NULL) THEN 1 ELSE 0 END),
												SUM(CASE WHEN (period_id IS NULL AND period_code IS NOT NULL AND calendar_code IS NOT NULL) THEN 1 ELSE 0 END)
					INTO          l_organization_count,
												l_inventory_item_count,
												l_cost_type_count,
												l_period_count
					FROM          gl_item_cst;
				END IF;
			END IF;
			/************************************************
			* Migration Error Logging for table CM_SCST_LED *
			************************************************/
			IF l_table_name IN ('CM_SCST_LED') THEN
				IF p_log_level = 1 THEN
					l_sql_statement :=  l_sql_statement
															||
															'(                (organization_id IS NULL AND whse_code IS NOT NULL)
															OR                (inventory_item_id IS NULL AND item_id IS NOT NULL)
															OR                (form_prod_uom IS NULL AND form_prod_um IS NOT NULL)
															OR                (item_fmqty_uom IS NULL AND item_fmqty_um IS NOT NULL)
															OR                (usage_uom IS NULL AND usage_um IS NOT NULL)
															)';
					IF p_from_rowid IS NOT NULL AND p_to_rowid IS NOT NULL THEN
						execute IMMEDIATE l_sql_statement INTO l_failure_count using p_from_rowid, p_to_rowid;
					ELSE
						execute IMMEDIATE l_sql_statement INTO l_failure_count;
					END IF;
				ELSIF p_log_level = 2 THEN
					SELECT        SUM(CASE WHEN (organization_id IS NULL AND whse_code IS NOT NULL) THEN 1 ELSE 0 END),
												SUM(CASE WHEN (inventory_item_id IS NULL AND item_id IS NOT NULL) THEN 1 ELSE 0 END),
												SUM(CASE WHEN (form_prod_uom IS NULL AND form_prod_um IS NOT NULL) THEN 1 ELSE 0 END),
												SUM(CASE WHEN (item_fmqty_uom IS NULL AND item_fmqty_um IS NOT NULL) THEN 1 ELSE 0 END),
												SUM(CASE WHEN (usage_uom IS NULL AND usage_um IS NOT NULL) THEN 1 ELSE 0 END)
					INTO          l_organization_count,
												l_inventory_item_count,
												l_uom_count1,
												l_uom_count2,
												l_uom_count3
					FROM          cm_scst_led;
				END IF;
			END IF;
			/************************************************
			* Migration Error Logging for table CM_ACST_LED *
			************************************************/
			IF l_table_name IN ('CM_ACST_LED') THEN
				IF p_log_level = 1 THEN
					l_sql_statement :=  l_sql_statement
															||
															'(                (organization_id IS NULL AND whse_code IS NOT NULL)
															OR                (inventory_item_id IS NULL AND item_id IS NOT NULL)
															OR                (cost_type_id IS NULL AND cost_mthd_code IS NOT NULL)
															OR                (period_id IS NULL AND period_code IS NOT NULL)
															)';
					IF p_from_rowid IS NOT NULL AND p_to_rowid IS NOT NULL THEN
						execute IMMEDIATE l_sql_statement INTO l_failure_count using p_from_rowid, p_to_rowid;
					ELSE
						execute IMMEDIATE l_sql_statement INTO l_failure_count;
					END IF;
				ELSIF p_log_level = 2 THEN
					SELECT        SUM(CASE WHEN (organization_id IS NULL AND whse_code IS NOT NULL) THEN 1 ELSE 0 END),
												SUM(CASE WHEN (inventory_item_id IS NULL AND item_id IS NOT NULL) THEN 1 ELSE 0 END),
												SUM(CASE WHEN (cost_type_id IS NULL AND cost_mthd_code IS NOT NULL) THEN 1 ELSE 0 END),
												SUM(CASE WHEN (period_id IS NULL AND period_code IS NOT NULL AND calendar_code IS NOT NULL) THEN 1 ELSE 0 END)
					INTO          l_organization_count,
												l_inventory_item_count,
												l_cost_type_count,
												l_period_count
					FROM          cm_acst_led;
				END IF;
			END IF;
			/************************************************
			* Migration Error Logging for table XLA_RULES_T *
			************************************************/
			IF l_table_name IN ('XLA_RULES_T') THEN
				IF p_log_level = 1 THEN
					l_sql_statement :=  l_sql_statement || ' ERROR_VALUE <> 1 ';
					execute IMMEDIATE l_sql_statement INTO l_failure_count;
				ELSIF p_log_level = 2 THEN
					SELECT        SUM(DECODE(error_value, -1, 1, 0)),
												SUM(DECODE(error_value, -1400, 1, 0)),
												SUM(DECODE(error_value, -6502, 1, 0)),
												SUM(DECODE(error_value, -2291, 1, 0)),
												SUM(DECODE(error_value, -1438, 1, -12899, 1, 0)),
												SUM(DECODE(error_value, -1722, 1, 0)),
                        SUM(DECODE(error_value, 0, 1, 0)),
												SUM(DECODE(error_value, 1, 0, 1))
					INTO          l_unique_error_count,
												l_not_null_error_count,
												l_value_error_count,
												l_parent_key_error_count,
												l_too_long_error_count,
												l_invalid_number_error_count,
                        l_not_picked_up_error_count,
												l_total_error_count
					FROM          xla_rules_t;
				END IF;
			END IF;
			/*******************************************************
			* Migration Error Logging for table XLA_RULE_DETAILS_T *
			*******************************************************/
			IF l_table_name IN ('XLA_RULE_DETAILS_T') THEN
				IF p_log_level = 1 THEN
					l_sql_statement :=  l_sql_statement || ' ERROR_VALUE <> 1 ';
					execute IMMEDIATE l_sql_statement INTO l_failure_count;
				ELSIF p_log_level = 2 THEN
					SELECT        SUM(DECODE(error_value, -1, 1, 0)),
												SUM(DECODE(error_value, -1400, 1, 0)),
												SUM(DECODE(error_value, -6502, 1, 0)),
												SUM(DECODE(error_value, -2291, 1, 0)),
												SUM(DECODE(error_value, -1438, 1, -12899, 1, 0)),
												SUM(DECODE(error_value, -1722, 1, 0)),
                        SUM(DECODE(error_value, 0, 1, 0)),
												SUM(DECODE(error_value, 1, 0, 1))
					INTO          l_unique_error_count,
												l_not_null_error_count,
												l_value_error_count,
												l_parent_key_error_count,
												l_too_long_error_count,
												l_invalid_number_error_count,
                        l_not_picked_up_error_count,
												l_total_error_count
					FROM          xla_rule_details_t;
				END IF;
			END IF;
			/*******************************************************
			* Migration Error Logging for table XLA_CONDITIONS_T *
			*******************************************************/
			IF l_table_name IN ('XLA_CONDITIONS_T') THEN
				IF p_log_level = 1 THEN
					l_sql_statement :=  l_sql_statement || ' ERROR_VALUE <> 1 ';
					execute IMMEDIATE l_sql_statement INTO l_failure_count;
				ELSIF p_log_level = 2 THEN
					SELECT        SUM(DECODE(error_value, -1, 1, 0)),
												SUM(DECODE(error_value, -1400, 1, 0)),
												SUM(DECODE(error_value, -6502, 1, 0)),
												SUM(DECODE(error_value, -2291, 1, 0)),
												SUM(DECODE(error_value, -1438, 1, -12899, 1, 0)),
												SUM(DECODE(error_value, -1722, 1, 0)),
                        SUM(DECODE(error_value, 0, 1, 0)),
												SUM(DECODE(error_value, 1, 0, 1))
					INTO          l_unique_error_count,
												l_not_null_error_count,
												l_value_error_count,
												l_parent_key_error_count,
												l_too_long_error_count,
												l_invalid_number_error_count,
                        l_not_picked_up_error_count,
												l_total_error_count
					FROM          xla_conditions_t;
				END IF;
			END IF;
			/*******************************************************
			* Migration Error Logging for table XLA_LINE_ASSGNS_T *
			*******************************************************/
			IF l_table_name IN ('XLA_LINE_ASSGNS_T') THEN
				IF p_log_level = 1 THEN
					l_sql_statement :=  l_sql_statement || ' ERROR_VALUE <> 1 ';
					execute IMMEDIATE l_sql_statement INTO l_failure_count;
				ELSIF p_log_level = 2 THEN
					SELECT        SUM(DECODE(error_value, -1, 1, 0)),
												SUM(DECODE(error_value, -1400, 1, 0)),
												SUM(DECODE(error_value, -6502, 1, 0)),
												SUM(DECODE(error_value, -2291, 1, 0)),
												SUM(DECODE(error_value, -1438, 1, -12899, 1, 0)),
												SUM(DECODE(error_value, -1722, 1, 0)),
                        SUM(DECODE(error_value, 0, 1, 0)),
												SUM(DECODE(error_value, 1, 0, 1))
					INTO          l_unique_error_count,
												l_not_null_error_count,
												l_value_error_count,
												l_parent_key_error_count,
												l_too_long_error_count,
												l_invalid_number_error_count,
                        l_not_picked_up_error_count,
												l_total_error_count
					FROM          xla_line_assgns_t;
				END IF;
			END IF;
			/**************************************************
			* Migration Error Logging for table GMF_LOT_COSTS *
			**************************************************/
			IF l_table_name IN ('GMF_LOT_COSTS') THEN
				IF p_log_level = 1 THEN
					l_sql_statement :=  l_sql_statement
															||
															'(                (cost_type_id IS NULL AND cost_mthd_code IS NOT NULL)
															OR                (organization_id IS NULL AND whse_code IS NOT NULL)
															OR                (inventory_item_id IS NULL AND item_id IS NOT NULL)
                              OR                (lot_number IS NULL AND lot_id IS NOT NULL)
															)';
					execute IMMEDIATE l_sql_statement INTO l_failure_count;
				ELSIF p_log_level = 2 THEN
					SELECT        SUM(CASE WHEN (organization_id IS NULL AND whse_code IS NOT NULL) THEN 1 ELSE 0 END),
												SUM(CASE WHEN (inventory_item_id IS NULL AND item_id IS NOT NULL) THEN 1 ELSE 0 END),
												SUM(CASE WHEN (cost_type_id IS NULL AND cost_mthd_code IS NOT NULL) THEN 1 ELSE 0 END),
                        SUM(CASE WHEN (lot_number IS NULL AND lot_id IS NOT NULL) THEN 1 ELSE 0 END)
					INTO          l_organization_count,
												l_inventory_item_count,
												l_cost_type_count,
                        l_lot_number_count
					FROM          gmf_lot_costs;
				END IF;
			END IF;
			/*********************************************************
			* Migration Error Logging for table GMF_LOT_COSTED_ITEMS *
			*********************************************************/
			IF l_table_name IN ('GMF_LOT_COSTED_ITEMS') THEN
				IF p_log_level = 1 THEN
					l_sql_statement :=  l_sql_statement
															||
															'(                (cost_type_id IS NULL AND cost_mthd_code IS NOT NULL)
															OR                (legal_entity_id IS NULL AND co_code IS NOT NULL)
															OR                (inventory_item_id IS NULL AND item_id IS NOT NULL)
															OR                (master_organization_id IS NULL AND item_id IS NOT NULL)
															)';
					execute IMMEDIATE l_sql_statement INTO l_failure_count;
				ELSIF p_log_level = 2 THEN
					SELECT        SUM(CASE WHEN (master_organization_id IS NULL AND item_id IS NOT NULL) THEN 1 ELSE 0 END),
												SUM(CASE WHEN (inventory_item_id IS NULL AND item_id IS NOT NULL) THEN 1 ELSE 0 END),
												SUM(CASE WHEN (cost_type_id IS NULL AND cost_mthd_code IS NOT NULL) THEN 1 ELSE 0 END),
												SUM(CASE WHEN (legal_entity_id IS NULL AND co_code IS NOT NULL) THEN 1 ELSE 0 END)
					INTO          l_master_organization_count,
												l_inventory_item_count,
												l_cost_type_count,
												l_legal_entity_count
					FROM          gmf_lot_costed_items;
				END IF;
			END IF;
			/*********************************************************
			* Migration Error Logging for table GMF_LOT_COST_BURDENS *
			*********************************************************/
			IF l_table_name IN ('GMF_LOT_COST_BURDENS') THEN
				IF p_log_level = 1 THEN
					l_sql_statement :=  l_sql_statement
															||
															'(                (cost_type_id IS NULL AND cost_mthd_code IS NOT NULL)
															OR                (organization_id IS NULL AND whse_code IS NOT NULL)
															OR                (inventory_item_id IS NULL AND item_id IS NOT NULL)
															OR                (item_uom IS NULL AND item_um IS NOT NULL)
															OR                (resource_uom IS NULL AND resource_um IS NOT NULL)
                              OR                (lot_number IS NULL AND lot_id IS NOT NULL)
															)';
					execute IMMEDIATE l_sql_statement INTO l_failure_count;
				ELSIF p_log_level = 2 THEN
					SELECT        SUM(CASE WHEN (organization_id IS NULL AND whse_code IS NOT NULL) THEN 1 ELSE 0 END),
												SUM(CASE WHEN (inventory_item_id IS NULL AND item_id IS NOT NULL) THEN 1 ELSE 0 END),
												SUM(CASE WHEN (cost_type_id IS NULL AND cost_mthd_code IS NOT NULL) THEN 1 ELSE 0 END),
												SUM(CASE WHEN (item_uom IS NULL AND item_um IS NOT NULL) THEN 1 ELSE 0 END),
												SUM(CASE WHEN (resource_uom IS NULL AND resource_um IS NOT NULL) THEN 1 ELSE 0 END),
                        SUM(CASE WHEN (lot_number IS NULL AND lot_id IS NOT NULL) THEN 1 ELSE 0 END)
					INTO          l_organization_count,
												l_inventory_item_count,
												l_cost_type_count,
												l_uom_count1,
												l_uom_count2,
                        l_lot_number_count
					FROM          gmf_lot_cost_burdens;
				END IF;
			END IF;
			/*************************************************************
			* Migration Error Logging for table GMF_LOT_COST_ADJUSTMENTS *
			*************************************************************/
			IF l_table_name IN ('GMF_LOT_COST_ADJUSTMENTS') THEN
				IF p_log_level = 1 THEN
					l_sql_statement :=  l_sql_statement
															||
															'(                (cost_type_id IS NULL AND cost_mthd_code IS NOT NULL)
															OR                (organization_id IS NULL AND whse_code IS NOT NULL)
															OR                (inventory_item_id IS NULL AND item_id IS NOT NULL)
															OR                (legal_entity_id IS NULL AND co_code IS NOT NULL)
                              OR                (lot_number IS NULL AND lot_id IS NOT NULL)
															)';
					execute IMMEDIATE l_sql_statement INTO l_failure_count;
				ELSIF p_log_level = 2 THEN
					SELECT        SUM(CASE WHEN (organization_id IS NULL AND whse_code IS NOT NULL) THEN 1 ELSE 0 END),
												SUM(CASE WHEN (inventory_item_id IS NULL AND item_id IS NOT NULL) THEN 1 ELSE 0 END),
												SUM(CASE WHEN (cost_type_id IS NULL AND cost_mthd_code IS NOT NULL) THEN 1 ELSE 0 END),
												SUM(CASE WHEN (legal_entity_id IS NULL AND co_code IS NOT NULL) THEN 1 ELSE 0 END),
                        SUM(CASE WHEN (lot_number IS NULL AND lot_id IS NOT NULL) THEN 1 ELSE 0 END)
					INTO          l_organization_count,
												l_inventory_item_count,
												l_cost_type_count,
												l_legal_entity_count,
                        l_lot_number_count
					FROM          gmf_lot_cost_adjustments;
				END IF;
			END IF;
			/***************************************************************
			* Migration Error Logging for table GMF_MATERIAL_LOT_COST_TXNS *
			***************************************************************/
			IF l_table_name IN ('GMF_MATERIAL_LOT_COST_TXNS') THEN
				IF p_log_level = 1 THEN
					l_sql_statement :=  l_sql_statement
															||
															'(                (cost_type_id IS NULL AND cost_type_code IS NOT NULL)
															OR                (cost_trans_um IS NULL AND cost_trans_uom IS NOT NULL)
															)';
					execute IMMEDIATE l_sql_statement INTO l_failure_count;
				ELSIF p_log_level = 2 THEN
					SELECT        SUM(CASE WHEN (cost_type_id IS NULL AND cost_type_code IS NOT NULL) THEN 1 ELSE 0 END),
												SUM(CASE WHEN (cost_trans_um IS NULL AND cost_trans_uom IS NOT NULL) THEN 1 ELSE 0 END)
					INTO          l_cost_type_count,
												l_uom_count1
					FROM          gmf_material_lot_cost_txns;
				END IF;
			END IF;
			/************************************************
			* Migration Error Logging for table CM_WHSE_SRC *
			************************************************/
			IF l_table_name IN ('CM_WHSE_SRC') THEN
				IF p_log_level = 1 THEN
					l_sql_statement :=  l_sql_statement
															||
															'(                    (legal_entity_id IS NULL AND orgn_code IS NOT NULL)
															OR                    (source_organization_id IS NULL AND whse_code IS NOT NULL)
															OR                    (inventory_item_id IS NULL AND item_id IS NOT NULL)
															OR                    (master_organization_id IS NULL AND item_id IS NOT NULL)
															OR                    (organization_id IS NULL AND delete_mark = 0 AND orgn_code IS NOT NULL)
															)';
					execute IMMEDIATE l_sql_statement INTO l_failure_count;
				ELSIF p_log_level = 2 THEN
					SELECT        SUM(CASE WHEN (source_organization_id IS NULL AND whse_code IS NOT NULL) THEN 1 ELSE 0 END),
												SUM(CASE WHEN (inventory_item_id IS NULL AND item_id IS NOT NULL) THEN 1 ELSE 0 END),
												SUM(CASE WHEN (organization_id IS NULL AND delete_mark = 0 AND orgn_code IS NOT NULL) THEN 1 ELSE 0 END),
												SUM(CASE WHEN (legal_entity_id IS NULL AND orgn_code IS NOT NULL) THEN 1 ELSE 0 END),
												SUM(CASE WHEN (master_organization_id IS NULL AND item_id IS NOT NULL) THEN 1 ELSE 0 END)
					INTO          l_source_organization_count,
												l_inventory_item_count,
												l_organization_count,
												l_legal_entity_count,
												l_master_organization_count
					FROM          cm_whse_src;
				END IF;
			END IF;
			/************************************************
			* Migration Error Logging for table CM_ACPR_CTL *
			************************************************/
			IF l_table_name IN ('CM_ACPR_CTL') THEN
				IF p_log_level = 1 THEN
					l_sql_statement :=  l_sql_statement
															||
															'(              (calendar_code IS NOT NULL AND period_code IS NOT NULL and period_id IS NULL)
															OR              (cost_mthd_code IS NOT NULL AND cost_type_id is NULL)
															OR              (calendar_code IS NOT NULL AND legal_entity_id IS NULL)
															)';
					execute IMMEDIATE l_sql_statement INTO l_failure_count;
				ELSIF p_log_level = 2 THEN
					SELECT        SUM(CASE WHEN (calendar_code IS NOT NULL AND period_code IS NOT NULL and period_id IS NULL) THEN 1 ELSE 0 END),
												SUM(CASE WHEN (cost_mthd_code IS NOT NULL AND cost_type_id is NULL) THEN 1 ELSE 0 END),
												SUM(CASE WHEN (calendar_code IS NOT NULL AND legal_entity_id IS NULL) THEN 1 ELSE 0 END)
					INTO          l_period_count,
												l_cost_type_count,
												l_legal_entity_count
					FROM          cm_acpr_ctl;
				END IF;
			END IF;
			/************************************************
			* Migration Error Logging for table CM_RLUP_CTL *
			************************************************/
			IF l_table_name IN ('CM_RLUP_CTL') THEN
				IF p_log_level = 1 THEN
					l_sql_statement :=  l_sql_statement
															||
															'(                (calendar_code is not null and period_code is not null and period_id is null)
															or                (cost_mthd_code is not null and cost_type_id is null)
															or                (calendar_code is not null and legal_entity_id is null)
															or                (inventory_item_id is null and item_id is not null)
															or                (master_organization_id is null and item_id is not null)
															)';
					execute IMMEDIATE l_sql_statement INTO l_failure_count;
				ELSIF p_log_level = 2 THEN
					SELECT        SUM(CASE WHEN (calendar_code IS NOT NULL AND period_code IS NOT NULL and period_id IS NULL) THEN 1 ELSE 0 END),
												SUM(CASE WHEN (cost_mthd_code IS NOT NULL AND cost_type_id is NULL) THEN 1 ELSE 0 END),
												SUM(CASE WHEN (calendar_code IS NOT NULL AND legal_entity_id IS NULL) THEN 1 ELSE 0 END),
												SUM(CASE WHEN (inventory_item_id IS NULL AND item_id IS NOT NULL) THEN 1 ELSE 0 END),
												SUM(CASE WHEN (master_organization_id IS NULL AND item_id IS NOT NULL) THEN 1 ELSE 0 END)
					INTO          l_period_count,
												l_cost_type_count,
												l_legal_entity_count,
												l_inventory_item_count,
												l_master_organization_count
					FROM          cm_rlup_ctl;
				END IF;
			END IF;
			/************************************************
			* Migration Error Logging for table CM_RLUP_ITM *
			************************************************/
			IF l_table_name IN ('CM_RLUP_ITM') THEN
				IF p_log_level = 1 THEN
					l_sql_statement :=  l_sql_statement
															||
															'(                (inventory_item_id is null and item_id is not null)
															or                (organization_id is null and item_id is not null)
															)';
					execute IMMEDIATE l_sql_statement INTO l_failure_count;
				ELSIF p_log_level = 2 THEN
					SELECT        SUM(CASE WHEN (inventory_item_id IS NULL AND item_id IS NOT NULL) THEN 1 ELSE 0 END),
												SUM(CASE WHEN (organization_id IS NULL AND item_id IS NOT NULL) THEN 1 ELSE 0 END)
					INTO          l_inventory_item_count,
												l_master_organization_count
					FROM          cm_rlup_itm;
				END IF;
			END IF;
			/************************************************
			* Migration Error Logging for table CM_CUPD_CTL *
			************************************************/
			IF l_table_name IN ('CM_CUPD_CTL') THEN
				IF p_log_level = 1 THEN
					l_sql_statement :=  l_sql_statement
															||
															'(              (calendar_code IS NOT NULL AND period_code IS NOT NULL and period_id IS NULL)
															OR              (cost_mthd_code IS NOT NULL AND cost_type_id is NULL)
															OR              (calendar_code IS NOT NULL AND legal_entity_id IS NULL)
															)';
					execute IMMEDIATE l_sql_statement INTO l_failure_count;
				ELSIF p_log_level = 2 THEN
					SELECT        SUM(CASE WHEN (calendar_code IS NOT NULL AND period_code IS NOT NULL and period_id IS NULL) THEN 1 ELSE 0 END),
												SUM(CASE WHEN (cost_mthd_code IS NOT NULL AND cost_type_id is NULL) THEN 1 ELSE 0 END),
												SUM(CASE WHEN (calendar_code IS NOT NULL AND legal_entity_id IS NULL) THEN 1 ELSE 0 END)
					INTO          l_period_count,
												l_cost_type_count,
												l_legal_entity_count
					FROM          cm_cupd_ctl;
				END IF;
			END IF;
			/************************************************
			* Migration Error Logging for table GL_SUBR_STA *
			************************************************/
			IF l_table_name IN ('GL_SUBR_STA') THEN
				IF p_log_level = 1 THEN
					l_sql_statement :=  l_sql_statement
															||
															'(              (crev_curr_mthd is not null AND crev_curr_cost_type_id IS NULL)
															OR              (crev_curr_calendar is not null and crev_curr_period is not NULL AND crev_curr_period_id is null)
															OR              (crev_prev_mthd is not null AND crev_prev_cost_type_id IS NULL)
															OR              (crev_prev_calendar is not null and crev_prev_period is not NULL AND crev_prev_period_id is null)
															OR              (co_code is not null and legal_entity_id is null)
															OR              (co_code is not null AND cost_type_id is null)
															)';
					execute IMMEDIATE l_sql_statement INTO l_failure_count;
				ELSIF p_log_level = 2 THEN
					SELECT        SUM(CASE WHEN (crev_curr_mthd is not null AND crev_curr_cost_type_id IS NULL) THEN 1 ELSE 0 END),
												SUM(CASE WHEN (crev_curr_calendar is not null and crev_curr_period is not NULL AND crev_curr_period_id is null) THEN 1 ELSE 0 END),
												SUM(CASE WHEN (crev_prev_mthd is not null AND crev_prev_cost_type_id IS NULL) THEN 1 ELSE 0 END),
												SUM(CASE WHEN (crev_prev_calendar is not null and crev_prev_period is not NULL AND crev_prev_period_id is null) THEN 1 ELSE 0 END),
												SUM(CASE WHEN (co_code is not null and legal_entity_id is null) THEN 1 ELSE 0 END),
												SUM(CASE WHEN (co_code is not null AND cost_type_id is null) THEN 1 ELSE 0 END)
					INTO          l_curr_cost_type_count,
												l_curr_period_count,
												l_prev_cost_type_count,
												l_prev_period_count,
												l_legal_entity_count,
												l_cost_type_count
					FROM          gl_subr_sta;
				END IF;
			END IF;
		ELSIF p_log_level = 3 THEN
      IF l_table_name = 'CM_RSRC_DTL' THEN
  			OPEN cur_gmf_log_errors FOR l_cm_rsrc_dtl;
  			FETCH cur_gmf_log_errors bulk collect INTO l_error_tbl;
  			CLOSE cur_gmf_log_errors;
      ELSIF l_table_name = 'CM_ADJS_DTL' THEN
  			OPEN cur_gmf_log_errors FOR l_cm_adjs_dtl;
  			FETCH cur_gmf_log_errors bulk collect INTO l_error_tbl;
  			CLOSE cur_gmf_log_errors;
      ELSIF l_table_name = 'CM_CMPT_DTL' THEN
        OPEN cur_gmf_log_errors FOR l_cm_cmpt_dtl;
        FETCH cur_gmf_log_errors bulk collect INTO l_error_tbl;
        CLOSE cur_gmf_log_errors;
      ELSIF l_table_name = 'CM_BRDN_DTL' THEN
        OPEN cur_gmf_log_errors FOR l_cm_brdn_dtl;
        FETCH cur_gmf_log_errors bulk collect INTO l_error_tbl;
        CLOSE cur_gmf_log_errors;
      ELSIF l_table_name = 'GL_ITEM_CST' THEN
        OPEN cur_gmf_log_errors FOR l_gl_item_cst;
        FETCH cur_gmf_log_errors bulk collect INTO l_error_tbl;
        CLOSE cur_gmf_log_errors;
      ELSIF l_table_name = 'CM_SCST_LED' THEN
        OPEN cur_gmf_log_errors FOR l_cm_scst_led;
        FETCH cur_gmf_log_errors bulk collect INTO l_error_tbl;
        CLOSE cur_gmf_log_errors;
      ELSIF l_table_name = 'CM_ACST_LED' THEN
        OPEN cur_gmf_log_errors FOR l_cm_acst_led;
        FETCH cur_gmf_log_errors bulk collect INTO l_error_tbl;
        CLOSE cur_gmf_log_errors;
      ELSIF l_table_name = 'XLA_RULES_T' THEN
        OPEN cur_gmf_log_errors FOR l_xla_rules_t;
        FETCH cur_gmf_log_errors bulk collect INTO l_error_tbl;
        CLOSE cur_gmf_log_errors;
      ELSIF l_table_name = 'XLA_RULE_DETAILS_T' THEN
        OPEN cur_gmf_log_errors FOR l_xla_rule_details_t;
        FETCH cur_gmf_log_errors bulk collect INTO l_error_tbl;
        CLOSE cur_gmf_log_errors;
      ELSIF l_table_name = 'XLA_CONDITIONS_T' THEN
        OPEN cur_gmf_log_errors FOR l_xla_conditions_t;
        FETCH cur_gmf_log_errors bulk collect INTO l_error_tbl;
        CLOSE cur_gmf_log_errors;
      ELSIF l_table_name = 'XLA_LINE_ASSGNS_T' THEN
        OPEN cur_gmf_log_errors FOR l_xla_line_assgns_t;
        FETCH cur_gmf_log_errors bulk collect INTO l_error_tbl;
        CLOSE cur_gmf_log_errors;
      ELSIF l_table_name = 'GMF_LOT_COSTS' THEN
        OPEN cur_gmf_log_errors FOR l_gmf_lot_costs;
        FETCH cur_gmf_log_errors bulk collect INTO l_error_tbl;
        CLOSE cur_gmf_log_errors;
      ELSIF l_table_name = 'GMF_LOT_COSTED_ITEMS' THEN
        OPEN cur_gmf_log_errors FOR l_gmf_lot_costed_items;
        FETCH cur_gmf_log_errors bulk collect INTO l_error_tbl;
        CLOSE cur_gmf_log_errors;
      ELSIF l_table_name = 'GMF_LOT_COST_BURDENS' THEN
        OPEN cur_gmf_log_errors FOR l_gmf_lot_cost_burdens;
        FETCH cur_gmf_log_errors bulk collect INTO l_error_tbl;
        CLOSE cur_gmf_log_errors;
      ELSIF l_table_name = 'GMF_LOT_COST_ADJUSTMENTS' THEN
        OPEN cur_gmf_log_errors FOR l_gmf_lot_cost_adjustments;
        FETCH cur_gmf_log_errors bulk collect INTO l_error_tbl;
        CLOSE cur_gmf_log_errors;
      ELSIF l_table_name = 'GMF_MATERIAL_LOT_COST_TXNS' THEN
        OPEN cur_gmf_log_errors FOR l_gmf_material_lot_cost_txns;
        FETCH cur_gmf_log_errors bulk collect INTO l_error_tbl;
        CLOSE cur_gmf_log_errors;
      ELSIF l_table_name = 'CM_WHSE_SRC' THEN
        OPEN cur_gmf_log_errors FOR l_cm_whse_src;
        FETCH cur_gmf_log_errors bulk collect INTO l_error_tbl;
        CLOSE cur_gmf_log_errors;
      ELSIF l_table_name = 'CM_ACPR_CTL' THEN
        OPEN cur_gmf_log_errors FOR l_cm_acpr_ctl;
        FETCH cur_gmf_log_errors bulk collect INTO l_error_tbl;
        CLOSE cur_gmf_log_errors;
      ELSIF l_table_name = 'CM_RLUP_CTL' THEN
        OPEN cur_gmf_log_errors FOR l_cm_rlup_ctl;
        FETCH cur_gmf_log_errors bulk collect INTO l_error_tbl;
        CLOSE cur_gmf_log_errors;
      ELSIF l_table_name = 'CM_RLUP_ITM' THEN
        OPEN cur_gmf_log_errors FOR l_cm_rlup_itm;
        FETCH cur_gmf_log_errors bulk collect INTO l_error_tbl;
        CLOSE cur_gmf_log_errors;
      ELSIF l_table_name = 'CM_CUPD_CTL' THEN
        OPEN cur_gmf_log_errors FOR l_cm_cupd_ctl;
        FETCH cur_gmf_log_errors bulk collect INTO l_error_tbl;
        CLOSE cur_gmf_log_errors;
      ELSIF l_table_name = 'GL_SUBR_STA' THEN
        OPEN cur_gmf_log_errors FOR l_gl_subr_sta;
        FETCH cur_gmf_log_errors bulk collect INTO l_error_tbl;
        CLOSE cur_gmf_log_errors;
      END IF;
		END IF;
		/********************************************
		* Logging Errors in GMA_MIGRATION_LOG table *
		********************************************/
		IF p_log_level = 1 THEN
			IF nvl(l_failure_count,0) > 0 THEN
				/**************************************
				* Migration Failure Log Message       *
				**************************************/
				GMA_COMMON_LOGGING.gma_migration_central_log
				(
				p_run_id             =>       gmf_migration.G_migration_run_id,
				p_log_level          =>       FND_LOG.LEVEL_PROCEDURE,
				p_message_token      =>       'GMA_TABLE_MIGRATION_TABLE_FAIL',
				p_table_name         =>       gmf_migration.G_Table_name,
				p_context            =>       gmf_migration.G_context,
				p_db_error           =>       NULL,
				p_app_short_name     =>       'GMA'
				);
			ELSE
				/**************************************
				* Migration Success Log Message       *
				**************************************/
				GMA_COMMON_LOGGING.gma_migration_central_log
				(
				p_run_id             =>       gmf_migration.G_migration_run_id,
				p_log_level          =>       FND_LOG.LEVEL_PROCEDURE,
				p_message_token      =>       'GMA_MIGRATION_TABLE_SUCCESS',
				p_table_name         =>       gmf_migration.G_Table_name,
				p_context            =>       gmf_migration.G_context,
				p_param1             =>       1,
				p_param2             =>       0,
				p_db_error           =>       NULL,
				p_app_short_name     =>       'GMA'
				);
			END IF;
		ELSIF p_log_level = 2 THEN
			l_failure_count :=  nvl(l_legal_entity_count, 0) + nvl(l_organization_count, 0) + nvl(l_cost_type_count, 0) +
													nvl(l_period_count, 0) + nvl(l_uom_count1, 0) + nvl(l_uom_count2, 0) + nvl(l_uom_count3, 0) +
													nvl(l_inventory_item_count, 0) + nvl(l_adjustment_ind_count, 0) + nvl(l_source_organization_count, 0) +
													nvl(l_master_organization_count, 0) + nvl(l_prev_cost_type_count, 0) + nvl(l_prev_period_count, 0) +
													nvl(l_curr_cost_type_count, 0) + nvl(l_curr_period_count, 0) + nvl(l_total_error_count, 0) +
                          nvl(l_lot_number_count, 0);
			IF nvl(l_failure_count,0) > 0 THEN
				/***********************************
				* Legal Entity Migration Error Log *
				***********************************/
				IF nvl(l_legal_entity_count,0) > 0 THEN
					GMA_COMMON_LOGGING.gma_migration_central_log
					(
					p_run_id             =>       gmf_migration.G_migration_run_id,
					p_log_level          =>       FND_LOG.LEVEL_ERROR,
					p_message_token      =>       'GMA_MIGRATION_ERROR_ABSTRACT',
					p_table_name         =>       gmf_migration.G_Table_name,
					p_context            =>       gmf_migration.G_Context,
					p_token1             =>       'TABLE_NAME',
					p_token2             =>       'COLUMN_NAME',
					p_token3             =>       'RECORD_COUNT',
					p_param1             =>       gmf_migration.G_Table_name,
					p_param2             =>       'Legal Entities',
					p_param3             =>       l_legal_entity_count,
					p_db_error           =>       NULL,
					p_app_short_name     =>       'GMA'
					);
				END IF;
				/***********************************
				* Organization Migration Error Log *
				***********************************/
				IF nvl(l_organization_count,0) > 0 THEN
					GMA_COMMON_LOGGING.gma_migration_central_log
					(
					p_run_id             =>       gmf_migration.G_migration_run_id,
					p_log_level          =>       FND_LOG.LEVEL_ERROR,
					p_message_token      =>       'GMA_MIGRATION_ERROR_ABSTRACT',
					p_table_name         =>       gmf_migration.G_Table_name,
					p_context            =>       gmf_migration.G_Context,
					p_token1             =>       'TABLE_NAME',
					p_token2             =>       'COLUMN_NAME',
					p_token3             =>       'RECORD_COUNT',
					p_param1             =>       gmf_migration.G_Table_name,
					p_param2             =>       'Organizations',
					p_param3             =>       l_organization_count,
					p_db_error           =>       NULL,
					p_app_short_name     =>       'GMA'
					);
				END IF;
				/******************************************
				* Source Organization Migration Error Log *
				******************************************/
				IF nvl(l_source_organization_count,0) > 0 THEN
					GMA_COMMON_LOGGING.gma_migration_central_log
					(
					p_run_id             =>       gmf_migration.G_migration_run_id,
					p_log_level          =>       FND_LOG.LEVEL_ERROR,
					p_message_token      =>       'GMA_MIGRATION_ERROR_ABSTRACT',
					p_table_name         =>       gmf_migration.G_Table_name,
					p_context            =>       gmf_migration.G_Context,
					p_token1             =>       'TABLE_NAME',
					p_token2             =>       'COLUMN_NAME',
					p_token3             =>       'RECORD_COUNT',
					p_param1             =>       gmf_migration.G_Table_name,
					p_param2             =>       'Source Organizations',
					p_param3             =>       l_source_organization_count,
					p_db_error           =>       NULL,
					p_app_short_name     =>       'GMA'
					);
				END IF;
				/******************************************
				* Master Organization Migration Error Log *
				******************************************/
				IF nvl(l_master_organization_count,0) > 0 THEN
					GMA_COMMON_LOGGING.gma_migration_central_log
					(
					p_run_id             =>       gmf_migration.G_migration_run_id,
					p_log_level          =>       FND_LOG.LEVEL_ERROR,
					p_message_token      =>       'GMA_MIGRATION_ERROR_ABSTRACT',
					p_table_name         =>       gmf_migration.G_Table_name,
					p_context            =>       gmf_migration.G_Context,
					p_token1             =>       'TABLE_NAME',
					p_token2             =>       'COLUMN_NAME',
					p_token3             =>       'RECORD_COUNT',
					p_param1             =>       gmf_migration.G_Table_name,
					p_param2             =>       'Master Organizations',
					p_param3             =>       l_master_organization_count,
					p_db_error           =>       NULL,
					p_app_short_name     =>       'GMA'
					);
				END IF;
				/***************************
				* Item Migration Error Log *
				***************************/
				IF nvl(l_inventory_item_count,0) > 0 THEN
					GMA_COMMON_LOGGING.gma_migration_central_log
					(
					p_run_id             =>       gmf_migration.G_migration_run_id,
					p_log_level          =>       FND_LOG.LEVEL_ERROR,
					p_message_token      =>       'GMA_MIGRATION_ERROR_ABSTRACT',
					p_table_name         =>       gmf_migration.G_Table_name,
					p_context            =>       gmf_migration.G_Context,
					p_token1             =>       'TABLE_NAME',
					p_token2             =>       'COLUMN_NAME',
					p_token3             =>       'RECORD_COUNT',
					p_param1             =>       gmf_migration.G_Table_name,
					p_param2             =>       'Items',
					p_param3             =>       l_inventory_item_count,
					p_db_error           =>       NULL,
					p_app_short_name     =>       'GMA'
					);
				END IF;
				/***********************************
				* Cost Type Migration Error Log    *
				***********************************/
				IF nvl(l_cost_type_count,0) > 0 THEN
					GMA_COMMON_LOGGING.gma_migration_central_log
					(
					p_run_id             =>       gmf_migration.G_migration_run_id,
					p_log_level          =>       FND_LOG.LEVEL_ERROR,
					p_message_token      =>       'GMA_MIGRATION_ERROR_ABSTRACT',
					p_table_name         =>       gmf_migration.G_Table_name,
					p_context            =>       gmf_migration.G_Context,
					p_token1             =>       'TABLE_NAME',
					p_token2             =>       'COLUMN_NAME',
					p_token3             =>       'RECORD_COUNT',
					p_param1             =>       gmf_migration.G_Table_name,
					p_param2             =>       'Cost Types',
					p_param3             =>       l_cost_type_count,
					p_db_error           =>       NULL,
					p_app_short_name     =>       'GMA'
					);
				END IF;
				/********************************************
				* Previous Cost Type Migration Error Log    *
				********************************************/
				IF nvl(l_prev_cost_type_count,0) > 0 THEN
					GMA_COMMON_LOGGING.gma_migration_central_log
					(
					p_run_id             =>       gmf_migration.G_migration_run_id,
					p_log_level          =>       FND_LOG.LEVEL_ERROR,
					p_message_token      =>       'GMA_MIGRATION_ERROR_ABSTRACT',
					p_table_name         =>       gmf_migration.G_Table_name,
					p_context            =>       gmf_migration.G_Context,
					p_token1             =>       'TABLE_NAME',
					p_token2             =>       'COLUMN_NAME',
					p_token3             =>       'RECORD_COUNT',
					p_param1             =>       gmf_migration.G_Table_name,
					p_param2             =>       'Previous Cost Types',
					p_param3             =>       l_prev_cost_type_count,
					p_db_error           =>       NULL,
					p_app_short_name     =>       'GMA'
					);
				END IF;
				/*******************************************
				* Current Cost Type Migration Error Log    *
				*******************************************/
				IF nvl(l_curr_cost_type_count,0) > 0 THEN
					GMA_COMMON_LOGGING.gma_migration_central_log
					(
					p_run_id             =>       gmf_migration.G_migration_run_id,
					p_log_level          =>       FND_LOG.LEVEL_ERROR,
					p_message_token      =>       'GMA_MIGRATION_ERROR_ABSTRACT',
					p_table_name         =>       gmf_migration.G_Table_name,
					p_context            =>       gmf_migration.G_Context,
					p_token1             =>       'TABLE_NAME',
					p_token2             =>       'COLUMN_NAME',
					p_token3             =>       'RECORD_COUNT',
					p_param1             =>       gmf_migration.G_Table_name,
					p_param2             =>       'Current Cost Types',
					p_param3             =>       l_curr_cost_type_count,
					p_db_error           =>       NULL,
					p_app_short_name     =>       'GMA'
					);
				END IF;
				/***********************************
				* Periods Migration Error Log      *
				***********************************/
				IF nvl(l_period_count,0) > 0 THEN
					GMA_COMMON_LOGGING.gma_migration_central_log
					(
					p_run_id             =>       gmf_migration.G_migration_run_id,
					p_log_level          =>       FND_LOG.LEVEL_ERROR,
					p_message_token      =>       'GMA_MIGRATION_ERROR_ABSTRACT',
					p_table_name         =>       gmf_migration.G_Table_name,
					p_context            =>       gmf_migration.G_Context,
					p_token1             =>       'TABLE_NAME',
					p_token2             =>       'COLUMN_NAME',
					p_token3             =>       'RECORD_COUNT',
					p_param1             =>       gmf_migration.G_Table_name,
					p_param2             =>       'Periods',
					p_param3             =>       l_period_count,
					p_db_error           =>       NULL,
					p_app_short_name     =>       'GMA'
					);
				END IF;
				/********************************************
				* Previous Periods Migration Error Log      *
				********************************************/
				IF nvl(l_prev_period_count,0) > 0 THEN
					GMA_COMMON_LOGGING.gma_migration_central_log
					(
					p_run_id             =>       gmf_migration.G_migration_run_id,
					p_log_level          =>       FND_LOG.LEVEL_ERROR,
					p_message_token      =>       'GMA_MIGRATION_ERROR_ABSTRACT',
					p_table_name         =>       gmf_migration.G_Table_name,
					p_context            =>       gmf_migration.G_Context,
					p_token1             =>       'TABLE_NAME',
					p_token2             =>       'COLUMN_NAME',
					p_token3             =>       'RECORD_COUNT',
					p_param1             =>       gmf_migration.G_Table_name,
					p_param2             =>       'Previous Periods',
					p_param3             =>       l_prev_period_count,
					p_db_error           =>       NULL,
					p_app_short_name     =>       'GMA'
					);
				END IF;
				/********************************************
				* Current Periods Migration Error Log      *
				********************************************/
				IF nvl(l_curr_period_count,0) > 0 THEN
					GMA_COMMON_LOGGING.gma_migration_central_log
					(
					p_run_id             =>       gmf_migration.G_migration_run_id,
					p_log_level          =>       FND_LOG.LEVEL_ERROR,
					p_message_token      =>       'GMA_MIGRATION_ERROR_ABSTRACT',
					p_table_name         =>       gmf_migration.G_Table_name,
					p_context            =>       gmf_migration.G_Context,
					p_token1             =>       'TABLE_NAME',
					p_token2             =>       'COLUMN_NAME',
					p_token3             =>       'RECORD_COUNT',
					p_param1             =>       gmf_migration.G_Table_name,
					p_param2             =>       'Current Periods',
					p_param3             =>       l_curr_period_count,
					p_db_error           =>       NULL,
					p_app_short_name     =>       'GMA'
					);
				END IF;
				/***********************************
				* UOM-1 Migration Error Log        *
				***********************************/
				IF nvl(l_uom_count1,0) > 0 THEN
					GMA_COMMON_LOGGING.gma_migration_central_log
					(
					p_run_id             =>       gmf_migration.G_migration_run_id,
					p_log_level          =>       FND_LOG.LEVEL_ERROR,
					p_message_token      =>       'GMA_MIGRATION_ERROR_ABSTRACT',
					p_table_name         =>       gmf_migration.G_Table_name,
					p_context            =>       gmf_migration.G_Context,
					p_token1             =>       'TABLE_NAME',
					p_token2             =>       'COLUMN_NAME',
					p_token3             =>       'RECORD_COUNT',
					p_param1             =>       gmf_migration.G_Table_name,
					p_param2             =>       'UOMs',
					p_param3             =>       l_uom_count1,
					p_db_error           =>       NULL,
					p_app_short_name     =>       'GMA'
					);
				END IF;
				/***********************************
				* UOM-2 Migration Error Log        *
				***********************************/
				IF nvl(l_uom_count2,0) > 0 THEN
					GMA_COMMON_LOGGING.gma_migration_central_log
					(
					p_run_id             =>       gmf_migration.G_migration_run_id,
					p_log_level          =>       FND_LOG.LEVEL_ERROR,
					p_message_token      =>       'GMA_MIGRATION_ERROR_ABSTRACT',
					p_table_name         =>       gmf_migration.G_Table_name,
					p_context            =>       gmf_migration.G_Context,
					p_token1             =>       'TABLE_NAME',
					p_token2             =>       'COLUMN_NAME',
					p_token3             =>       'RECORD_COUNT',
					p_param1             =>       gmf_migration.G_Table_name,
					p_param2             =>       'UOMs',
					p_param3             =>       l_uom_count2,
					p_db_error           =>       NULL,
					p_app_short_name     =>       'GMA'
					);
				END IF;
				/***********************************
				* UOM-3 Migration Error Log        *
				***********************************/
				IF nvl(l_uom_count3,0) > 0 THEN
					GMA_COMMON_LOGGING.gma_migration_central_log
					(
					p_run_id             =>       gmf_migration.G_migration_run_id,
					p_log_level          =>       FND_LOG.LEVEL_ERROR,
					p_message_token      =>       'GMA_MIGRATION_ERROR_ABSTRACT',
					p_table_name         =>       gmf_migration.G_Table_name,
					p_context            =>       gmf_migration.G_Context,
					p_token1             =>       'TABLE_NAME',
					p_token2             =>       'COLUMN_NAME',
					p_token3             =>       'RECORD_COUNT',
					p_param1             =>       gmf_migration.G_Table_name,
					p_param2             =>       'UOMs',
					p_param3             =>       l_uom_count3,
					p_db_error           =>       NULL,
					p_app_short_name     =>       'GMA'
					);
				END IF;
				/*******************************************
				* Adjustment Indicator Migration Error Log *
				*******************************************/
				IF nvl(l_adjustment_ind_count,0) > 0 THEN
					GMA_COMMON_LOGGING.gma_migration_central_log
					(
					p_run_id             =>       gmf_migration.G_migration_run_id,
					p_log_level          =>       FND_LOG.LEVEL_ERROR,
					p_message_token      =>       'GMA_MIGRATION_ERROR_ABSTRACT',
					p_table_name         =>       gmf_migration.G_Table_name,
					p_context            =>       gmf_migration.G_Context,
					p_token1             =>       'TABLE_NAME',
					p_token2             =>       'COLUMN_NAME',
					p_token3             =>       'RECORD_COUNT',
					p_param1             =>       gmf_migration.G_Table_name,
					p_param2             =>       'Adjustment Indicators',
					p_param3             =>       l_adjustment_ind_count,
					p_db_error           =>       NULL,
					p_app_short_name     =>       'GMA'
					);
				END IF;
        /***********************************
        * Lot Number Migration Error Log *
        ***********************************/
        IF nvl(l_lot_number_count,0) > 0 THEN
          GMA_COMMON_LOGGING.gma_migration_central_log
          (
          p_run_id             =>       gmf_migration.G_migration_run_id,
          p_log_level          =>       FND_LOG.LEVEL_ERROR,
          p_message_token      =>       'GMA_MIGRATION_ERROR_ABSTRACT',
          p_table_name         =>       gmf_migration.G_Table_name,
          p_context            =>       gmf_migration.G_Context,
          p_token1             =>       'TABLE_NAME',
          p_token2             =>       'COLUMN_NAME',
          p_token3             =>       'RECORD_COUNT',
          p_param1             =>       gmf_migration.G_Table_name,
          p_param2             =>       'Lot Numbers',
          p_param3             =>       l_lot_number_count,
          p_db_error           =>       NULL,
          p_app_short_name     =>       'GMA'
          );
        END IF;
				/****************************************
				* Unique Constraint Migration Error Log *
				****************************************/
				IF nvl(l_unique_error_count,0) > 0 THEN
					GMA_COMMON_LOGGING.gma_migration_central_log
					(
					p_run_id             =>       gmf_migration.G_migration_run_id,
					p_log_level          =>       FND_LOG.LEVEL_ERROR,
					p_message_token      =>       'GMA_MIGRATION_ERROR_ABSTRACT',
					p_table_name         =>       gmf_migration.G_Table_name,
					p_context            =>       gmf_migration.G_Context,
					p_token1             =>       'TABLE_NAME',
					p_token2             =>       'COLUMN_NAME',
					p_token3             =>       'RECORD_COUNT',
					p_param1             =>       gmf_migration.G_Table_name,
					p_param2             =>       'Unique Constraint',
					p_param3             =>       l_unique_error_count,
					p_db_error           =>       NULL,
					p_app_short_name     =>       'GMA'
					);
				END IF;
				/******************************************
				* Not Null Constraint Migration Error Log *
				******************************************/
				IF nvl(l_not_null_error_count,0) > 0 THEN
					GMA_COMMON_LOGGING.gma_migration_central_log
					(
					p_run_id             =>       gmf_migration.G_migration_run_id,
					p_log_level          =>       FND_LOG.LEVEL_ERROR,
					p_message_token      =>       'GMA_MIGRATION_ERROR_ABSTRACT',
					p_table_name         =>       gmf_migration.G_Table_name,
					p_context            =>       gmf_migration.G_Context,
					p_token1             =>       'TABLE_NAME',
					p_token2             =>       'COLUMN_NAME',
					p_token3             =>       'RECORD_COUNT',
					p_param1             =>       gmf_migration.G_Table_name,
					p_param2             =>       'Not Null Constraint',
					p_param3             =>       l_not_null_error_count,
					p_db_error           =>       NULL,
					p_app_short_name     =>       'GMA'
					);
				END IF;
				/************************************
				* Invalid Value Migration Error Log *
				************************************/
				IF nvl(l_value_error_count,0) > 0 THEN
					GMA_COMMON_LOGGING.gma_migration_central_log
					(
					p_run_id             =>       gmf_migration.G_migration_run_id,
					p_log_level          =>       FND_LOG.LEVEL_ERROR,
					p_message_token      =>       'GMA_MIGRATION_ERROR_ABSTRACT',
					p_table_name         =>       gmf_migration.G_Table_name,
					p_context            =>       gmf_migration.G_Context,
					p_token1             =>       'TABLE_NAME',
					p_token2             =>       'COLUMN_NAME',
					p_token3             =>       'RECORD_COUNT',
					p_param1             =>       gmf_migration.G_Table_name,
					p_param2             =>       'Invalid Value',
					p_param3             =>       l_value_error_count,
					p_db_error           =>       NULL,
					p_app_short_name     =>       'GMA'
					);
				END IF;
				/*******************************************
				* Parent Key Not-found Migration Error Log *
				*******************************************/
				IF nvl(l_parent_key_error_count,0) > 0 THEN
					GMA_COMMON_LOGGING.gma_migration_central_log
					(
					p_run_id             =>       gmf_migration.G_migration_run_id,
					p_log_level          =>       FND_LOG.LEVEL_ERROR,
					p_message_token      =>       'GMA_MIGRATION_ERROR_ABSTRACT',
					p_table_name         =>       gmf_migration.G_Table_name,
					p_context            =>       gmf_migration.G_Context,
					p_token1             =>       'TABLE_NAME',
					p_token2             =>       'COLUMN_NAME',
					p_token3             =>       'RECORD_COUNT',
					p_param1             =>       gmf_migration.G_Table_name,
					p_param2             =>       'Parent Key Constraint',
					p_param3             =>       l_parent_key_error_count,
					p_db_error           =>       NULL,
					p_app_short_name     =>       'GMA'
					);
				END IF;
				/*************************************
				* Value Too Long Migration Error Log *
				*************************************/
				IF nvl(l_too_long_error_count,0) > 0 THEN
					GMA_COMMON_LOGGING.gma_migration_central_log
					(
					p_run_id             =>       gmf_migration.G_migration_run_id,
					p_log_level          =>       FND_LOG.LEVEL_ERROR,
					p_message_token      =>       'GMA_MIGRATION_ERROR_ABSTRACT',
					p_table_name         =>       gmf_migration.G_Table_name,
					p_context            =>       gmf_migration.G_Context,
					p_token1             =>       'TABLE_NAME',
					p_token2             =>       'COLUMN_NAME',
					p_token3             =>       'RECORD_COUNT',
					p_param1             =>       gmf_migration.G_Table_name,
					p_param2             =>       'Value Too Long Error',
					p_param3             =>       l_too_long_error_count,
					p_db_error           =>       NULL,
					p_app_short_name     =>       'GMA'
					);
				END IF;
				/*************************************
				* Invalid Number Migration Error Log *
				*************************************/
				IF nvl(l_invalid_number_error_count,0) > 0 THEN
					GMA_COMMON_LOGGING.gma_migration_central_log
					(
					p_run_id             =>       gmf_migration.G_migration_run_id,
					p_log_level          =>       FND_LOG.LEVEL_ERROR,
					p_message_token      =>       'GMA_MIGRATION_ERROR_ABSTRACT',
					p_table_name         =>       gmf_migration.G_Table_name,
					p_context            =>       gmf_migration.G_Context,
					p_token1             =>       'TABLE_NAME',
					p_token2             =>       'COLUMN_NAME',
					p_token3             =>       'RECORD_COUNT',
					p_param1             =>       gmf_migration.G_Table_name,
					p_param2             =>       'Invalid Number Error',
					p_param3             =>       l_invalid_number_error_count,
					p_db_error           =>       NULL,
					p_app_short_name     =>       'GMA'
					);
				END IF;
        /********************************************
        * Records not picked up Migration Error Log *
        ********************************************/
        IF nvl(l_not_picked_up_error_count,0) > 0 THEN
          GMA_COMMON_LOGGING.gma_migration_central_log
          (
          p_run_id             =>       gmf_migration.G_migration_run_id,
          p_log_level          =>       FND_LOG.LEVEL_ERROR,
          p_message_token      =>       'GMA_MIGRATION_ERROR_ABSTRACT',
          p_table_name         =>       gmf_migration.G_Table_name,
          p_context            =>       gmf_migration.G_Context,
          p_token1             =>       'TABLE_NAME',
          p_token2             =>       'COLUMN_NAME',
          p_token3             =>       'RECORD_COUNT',
          p_param1             =>       gmf_migration.G_Table_name,
          p_param2             =>       'Records not Picked up Error',
          p_param3             =>       l_not_picked_up_error_count,
          p_db_error           =>       NULL,
          p_app_short_name     =>       'GMA'
          );
        END IF;
				/***********************************
				* Other Errors Migration Error Log *
				***********************************/
				IF nvl(l_total_error_count,0) - (
																				nvl(l_unique_error_count,0) +
																				nvl(l_not_null_error_count,0) +
																				nvl(l_value_error_count,0) +
																				nvl(l_parent_key_error_count,0) +
																				nvl(l_invalid_number_error_count,0) +
                                        nvl(l_not_picked_up_error_count,0) +
																				nvl(l_too_long_error_count,0)
																				) > 0 THEN
					GMA_COMMON_LOGGING.gma_migration_central_log
					(
					p_run_id             =>       gmf_migration.G_migration_run_id,
					p_log_level          =>       FND_LOG.LEVEL_ERROR,
					p_message_token      =>       'GMA_MIGRATION_ERROR_ABSTRACT',
					p_table_name         =>       gmf_migration.G_Table_name,
					p_context            =>       gmf_migration.G_Context,
					p_token1             =>       'TABLE_NAME',
					p_token2             =>       'COLUMN_NAME',
					p_token3             =>       'RECORD_COUNT',
					p_param1             =>       gmf_migration.G_Table_name,
					p_param2             =>       'Other Errors',
					p_param3             =>       nvl(l_total_error_count,0) -  (
																																			nvl(l_unique_error_count,0) +
																																			nvl(l_not_null_error_count,0) +
																																			nvl(l_value_error_count,0) +
																																			nvl(l_parent_key_error_count,0) +
																																			nvl(l_invalid_number_error_count,0) +
                                                                      nvl(l_not_picked_up_error_count,0) +
																																			nvl(l_too_long_error_count,0)
																																			),
					p_db_error           =>       NULL,
					p_app_short_name     =>       'GMA'
					);
				END IF;
			ELSE
				/**************************************
				* Migration Success Log Message       *
				**************************************/
				GMA_COMMON_LOGGING.gma_migration_central_log
				(
				p_run_id             =>       gmf_migration.G_migration_run_id,
				p_log_level          =>       FND_LOG.LEVEL_PROCEDURE,
				p_message_token      =>       'GMA_MIGRATION_TABLE_SUCCESS',
				p_table_name         =>       gmf_migration.G_Table_name,
				p_context            =>       gmf_migration.G_context,
				p_param1             =>       1,
				p_param2             =>       0,
				p_db_error           =>       NULL,
				p_app_short_name     =>       'GMA'
				);
			END IF;
		ELSIF p_log_level = 3 THEN
			IF l_error_tbl.count > 0 THEN
				FOR i IN l_error_tbl.first..l_error_tbl.last LOOP
					GMA_COMMON_LOGGING.gma_migration_central_log
					(
					p_run_id             =>       gmf_migration.G_migration_run_id,
					p_log_level          =>       FND_LOG.LEVEL_ERROR,
					p_message_token      =>       'GMA_MIGRATION_ERROR_DETAIL',
					p_table_name         =>       gmf_migration.G_Table_name,
					p_context            =>       gmf_migration.G_Context,
					p_token1             =>       'TABLE_NAME',
					p_token2             =>       'COLUMN_NAME',
					p_token3             =>       'PARAMETERS',
					p_token4             =>       'RECORD_COUNT',
					p_param1             =>       l_error_tbl(i).table_name,
					p_param2             =>       l_error_tbl(i).column_name,
					p_param3             =>       l_error_tbl(i).parameters,
					p_param4             =>       l_error_tbl(i).records,
					p_db_error           =>       NULL,
					p_app_short_name     =>       'GMA'
					);
				END LOOP;
			ELSE
				/**************************************
				* Migration Success Log Message       *
				**************************************/
				GMA_COMMON_LOGGING.gma_migration_central_log
				(
				p_run_id             =>       gmf_migration.G_migration_run_id,
				p_log_level          =>       FND_LOG.LEVEL_PROCEDURE,
				p_message_token      =>       'GMA_MIGRATION_TABLE_SUCCESS',
				p_table_name         =>       gmf_migration.G_Table_name,
				p_context            =>       gmf_migration.G_context,
				p_param1             =>       1,
				p_param2             =>       0,
				p_db_error           =>       NULL,
				p_app_short_name     =>       'GMA'
				);
			END IF;
		END IF;
	END Log_Errors;

	/**********************************************************************
	* PROCEDURE:                                                          *
	*   Migrate_Vendor Id                                                 *
	*                                                                     *
	* DESCRIPTION:                                                        *
	*   This PL/SQL procedure is used to transform the Vendor Id          *
	*   data in GL_ACCT_MAP                                               *
	*                                                                     *
	* PARAMETERS:                                                         *
	*   P_migration_run_id - id to use to right to migration log          *
	*   x_exception_count  - Number of exceptions occurred.               *
	*                                                                     *
	* SYNOPSIS:                                                           *
	*   Migrate_Vendor_id(p_migartion_id    => l_migration_id,            *
	*                    p_commit          => 'T',                        *
	*                    x_exception_count => l_exception_count );        *
	*                                                                     *
	* HISTORY                                                             *
	*       05-Oct-2006 Created  Anand Thiyagarajan                       *
  *       12-Oct-2006 Modified Anand Thiyagarajan                       *
  *         Stubbed PROCEDURE not to migrate records as this being done *
  *         in the ADR migration scripts itself                         *
	*                                                                     *
	**********************************************************************/
	PROCEDURE Migrate_Vendor_id
	(
	P_migration_run_id      IN             NUMBER,
	P_commit                IN             VARCHAR2,
	X_failure_count         OUT   NOCOPY   NUMBER
	)
	IS
		/****************
		* PL/SQL Tables *
		****************/

		/******************
		* Local Variables *
		 ******************/

  BEGIN

    /****************************************************************************************
    * Commented the following code snippet to avoid migrating the records for vendor Id,    *
    * as the fetching of_vendor_site_id vendor_site_id is done ine the ADR migration script *
    * itself directly.                                                                      *
    ****************************************************************************************/
    /****************************************************************************************
		G_Migration_run_id := P_migration_run_id;
		G_Table_name := 'GL_ACCT_MAP';
		G_Context := 'Vendor Id Migration';
		X_failure_count := 0;

		GMA_COMMON_LOGGING.gma_migration_central_log
		(
		p_run_id             =>       G_migration_run_id,
		p_log_level          =>       FND_LOG.LEVEL_STATEMENT,
		p_message_token      =>       'GMA_MIGRATION_TABLE_STARTED',
		p_table_name         =>       G_table_name,
		p_context            =>       G_context,
		p_db_error           =>       NULL,
		p_app_short_name     =>       'GMA'
		);

		UPDATE              gl_acct_map gam
		SET                 gam.vendor_id
		=                   (
												SELECT        v.of_vendor_site_id
												FROM          po_vend_mst v
												WHERE         v.vendor_id = gam.vendor_id
												),
                        gam.migrated_ind = 1
		WHERE               gam.vendor_id IS NOT NULL
    AND                 nvl(gam.migrated_ind, -1) <> 1;

		IF NVL(p_commit,'~') = FND_API.G_TRUE THEN
			COMMIT;
		END IF;
    ****************************************************************************************/
    NULL;

	EXCEPTION
		WHEN OTHERS THEN
			/************************************************
			* Increment Failure Count for Failed Migrations *
			************************************************/
			x_failure_count := x_failure_count + 1;

			/**************************************
			* Migration DB Error Log Message      *
			**************************************/
			GMA_COMMON_LOGGING.gma_migration_central_log
			(
			p_run_id             =>       G_migration_run_id,
			p_log_level          =>       FND_LOG.LEVEL_ERROR,
			p_message_token      =>       'GMA_MIGRATION_DB_ERROR',
			p_table_name         =>       G_table_name,
			p_context            =>       G_context,
			p_db_error           =>       SQLERRM,
			p_app_short_name     =>       'GMA'
			);

			/**************************************
			* Migration Failure Log Message       *
			**************************************/
			GMA_COMMON_LOGGING.gma_migration_central_log
			(
			p_run_id             =>       G_migration_run_id,
			p_log_level          =>       FND_LOG.LEVEL_ERROR,
			p_message_token      =>       'GMA_TABLE_MIGRATION_TABLE_FAIL',
			p_table_name         =>       G_table_name,
			p_context            =>       G_context,
			p_db_error           =>       NULL,
			p_app_short_name     =>       'GMA'
			);
	END Migrate_Vendor_id;

END GMF_MIGRATION;

/
