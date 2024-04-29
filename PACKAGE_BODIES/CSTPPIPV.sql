--------------------------------------------------------
--  DDL for Package Body CSTPPIPV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSTPPIPV" AS
/* $Header: CSTPIPVB.pls 120.12.12010000.6 2011/11/14 01:37:59 yuyun ship $ */

/*---------------------------------------------------------------------------*
|  PUBLIC PROCEDURE                                                          |
|       trf_invoice_to_inventory                                             |
|                                                                            |
|  p_item_option:       					             |
|             1:  All Asset items                                            |
|             2:  Specific Asset Item                                        |
|             5:  Category Items                                             |
|                                                                            |
|  p_invoice_project_option:                                                 |
|             1:  All invoices                                               |
|             2:  Project invoices                                           |
|                                                                            |
|  p_transaction_process_mode:                                               |
|             1:  Ready to be processed by Inventory Transaction Manager     |
|             2:  Hold                                                       |
|                                                                            |
|  aida.inventory_transfer_status:                                           |
|             N:     Not transferred                                         |
|             Null:  Transferred or Not Applicable                           |
|                                                                            |
*----------------------------------------------------------------------------*/

PROCEDURE trf_invoice_to_inventory(
        errbuf                     OUT NOCOPY      	VARCHAR2,
        retcode                    OUT NOCOPY      	NUMBER,
        p_organization_id          IN		NUMBER,
        p_description		   IN		VARCHAR2 DEFAULT NULL,
        p_item_option		   IN		NUMBER,
	p_item_dummy		   IN		NUMBER DEFAULT NULL,
	p_category_dummy	   IN		NUMBER DEFAULT NULL,
	p_specific_item_id	   IN		NUMBER DEFAULT NULL,
	p_category_set_id	   IN		NUMBER DEFAULT NULL,
 	p_category_validate_flag   IN     	VARCHAR2 DEFAULT NULL,
        p_category_structure       IN      	NUMBER DEFAULT NULL,
        p_category_id              IN      	NUMBER DEFAULT NULL,
        p_invoice_project_option   IN		NUMBER,
        p_project_dummy		   IN		NUMBER DEFAULT NULL,
        p_project_id		   IN		NUMBER DEFAULT NULL,
        p_adj_account_dummy        IN           NUMBER,
        p_adj_account		   IN		NUMBER,
        p_cutoff_date		   IN		VARCHAR2,
        p_transaction_process_mode IN      	NUMBER
)
IS

l_cutoff_date			DATE;
l_org_id			NUMBER;
l_cost_group_id			NUMBER;
l_batch_id			NUMBER;
l_request_id			NUMBER;
l_user_id			NUMBER;
l_prog_id			NUMBER;
l_prog_app_id			NUMBER;
l_login_id			NUMBER;
l_conc_program_id		NUMBER;
l_stmt_num                      NUMBER;
l_err_num                       NUMBER;
l_err_code                      VARCHAR2(240);
l_err_msg                       VARCHAR2(240);
l_cost_method			NUMBER;
l_default_txn_date              DATE;
l_first_date                    DATE;
l_last_date                     DATE;
l_txn_date_profile		NUMBER;
l_dummy				NUMBER;
l_debug				VARCHAR2(80);
l_default_cost_group_id         number;
conc_status			BOOLEAN;
cst_process_error		EXCEPTION;
cst_cstppipv_running		EXCEPTION;
cst_no_avg_org			EXCEPTION;

-- For a given org, this cursor will give list of items and cost group that
-- have invoices not yet interfaced with inventory


/* Skip Process Organizations Cost Manager Changes - Anand Thiyagarajan - 26-Oct-2004 Start */

   l_process_enabled_flag  mtl_parameters.process_enabled_flag%TYPE;
   l_organization_code     mtl_parameters.organization_code%TYPE;

/* Skip Process Organizations Cost Manager Changes - Anand Thiyagarajan - 26-Oct-2004 End */

/* Invoice Lines Project: lookup_code needs to be ITEM and ACCRUAL, not just ITEM */

CURSOR c_item
IS

        SELECT  DISTINCT cql.inventory_item_id item_id,
                         cql.cost_group_id cg_id,
                         cql.layer_id layer_id
        FROM    cst_quantity_layers cql
        WHERE   NVL(cql.layer_quantity,0) > 0
        AND     cql.organization_id = l_org_id
	AND     ( p_item_option = 1
                  OR  (p_item_option = 2
                       AND cql.inventory_item_id = p_specific_item_id
                      )
                  OR (p_item_option = 5
                      AND EXISTS
                          (  SELECT  'X'
                             FROM     mtl_item_categories mic
                             WHERE    mic.organization_id =
				         cql.organization_id
			     AND      mic.category_id =
                                         p_category_id
                             AND      mic.category_set_id =
                                         p_category_set_id
                             AND      mic.inventory_item_id =
                                         cql.inventory_item_id
                          )
                     )
                 )
        AND     EXISTS
                  ( SELECT  'X'
                    FROM    ap_invoice_distributions_all aida,
                            po_distributions_all pda,
                            po_line_locations_all plla,
                            po_lines_all pla
                    WHERE   aida.po_distribution_id = pda.po_distribution_id
		    AND	    aida.posted_flag = 'Y'
		    --AND	    NVL(aida.reversal_flag,'N') <> 'Y'
		    AND	    aida.accounting_date <= l_cutoff_date
                    AND     aida.inventory_transfer_status = 'N'
                    AND	    aida.line_type_lookup_code IN ('ITEM','ACCRUAL')
                    AND     pda.destination_type_code = 'INVENTORY'
                    AND     pda.destination_organization_id =
						l_org_id
                    AND     plla.line_location_id = pda.line_location_id
                    AND     pla.po_line_id = plla.po_line_id
                    AND     pla.item_id = cql.inventory_item_id
		    AND     (
			       (  p_invoice_project_option = 1
			          AND pda.project_id IS NULL
			          AND cql.cost_group_id = l_default_cost_group_id)
		               OR
			       (  pda.project_id IS NOT NULL
				  AND  EXISTS
				        (SELECT  'X'
				         FROM   pjm_project_parameters ppp
					 WHERE  ppp.organization_id = l_org_id
					 AND    ppp.costing_group_id =
							cql.cost_group_id
					 AND	ppp.project_id = pda.project_id
				         AND    ppp.project_id =
					        decode(p_invoice_project_option,
						     1, ppp.project_id,
						     p_project_id)
				        )
			       )
		          )
-- J Changes ----------------------------------------------------------------
--                    AND   aida.root_distribution_id IS NULL
------------------------------------------------------------------------------
/* Invoice Lines Project: root_distribution_id does not exist, replaced with corrected_invoice_dist_id */
                      AND aida.corrected_invoice_dist_id IS NULL
		  );
BEGIN

        ---------------------------------------------------------------------
        -- Initializing Variables
        ---------------------------------------------------------------------
        l_err_num          := 0;
        l_err_code         := '';
        l_err_msg          := '';
        l_cost_group_id    := -1;
        l_request_id       := 0;
        l_user_id          := 0;
        l_prog_id          := 0;
        l_prog_app_id      := 0;
        l_login_id         := 0;
        l_default_txn_date := NULL;
        l_first_date       := NULL;
        l_last_date        := NULL;
        l_org_id           := p_organization_id;
        l_cutoff_date	   := FND_DATE.canonical_to_date(p_cutoff_date);

        /* Skip Process Organizations Cost Manager Changes - Anand Thiyagarajan - 26-Oct-2004 Start */
        BEGIN

           SELECT   default_cost_group_id
                    , nvl(process_enabled_flag,'N')
                    , organization_code
            INTO    l_default_cost_group_id
                    , l_process_enabled_flag
                    , l_organization_code
           FROM     mtl_parameters
           WHERE    organization_id = l_org_id;

           IF nvl(l_process_enabled_flag,'N') = 'Y' THEN
              l_err_num := 30001;
              fnd_message.set_name('GMF', 'GMF_PROCESS_ORG_ERROR');
              fnd_message.set_token('ORGCODE', l_organization_code);
              l_err_msg := FND_MESSAGE.Get;
              l_err_msg := substrb('CSTPIPVB : ' || l_err_msg,1,240);
              CONC_STATUS := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR',l_err_msg);
              fnd_file.put_line(fnd_file.log,l_err_msg);
              RETURN;
           END IF;

        EXCEPTION
           WHEN no_data_found THEN
              l_process_enabled_flag := 'N';
              l_organization_code := NULL;
        END;
        /* Skip Process Organizations Cost Manager Changes - Anand Thiyagarajan - 26-Oct-2004 End */

        ----------------------------------------------------------------------
        -- retrieving concurrent program information
        ----------------------------------------------------------------------
        l_stmt_num := 5;

        l_request_id       := FND_GLOBAL.conc_request_id;
        l_user_id          := FND_GLOBAL.user_id;
        l_prog_id          := FND_GLOBAL.conc_program_id;
        l_prog_app_id      := FND_GLOBAL.prog_appl_id;
        l_login_id         := FND_GLOBAL.conc_login_id;
	l_conc_program_id  := FND_GLOBAL.conc_program_id;
	l_debug		   := FND_PROFILE.VALUE('MRP_DEBUG');
	l_txn_date_profile := FND_PROFILE.VALUE('TRANSACTION_DATE');

	l_stmt_num := 10;

        FND_FILE.PUT_LINE(FND_FILE.LOG, 'Transfer Invoice to Inventory');

        FND_FILE.PUT_LINE(FND_FILE.LOG, 'request_id: '
					||to_char(l_request_id));
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'prog_appl_id: '
					||to_char(l_prog_app_id));
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'l_user_id: '
					||to_char(l_user_id));
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'l_program_id: '
					||to_char(l_prog_id));
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'l_login_id: '
					||to_char(l_login_id));
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'l_conc_program_id: '
					||to_char(l_conc_program_id));
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'Debug: '
					||l_debug);
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'Txn Date Profile: '
					||TO_CHAR(l_txn_date_profile));
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'Organization: '
					||TO_CHAR(p_organization_id));
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'Description: '
					||p_description);
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'Item Option: '
					||TO_CHAR(p_item_option));
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'Item dummy: '
					||TO_CHAR(p_item_dummy));
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'Category_dummy: '
					||TO_CHAR(p_category_dummy));
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'Specific Item: '
					||TO_CHAR(p_specific_item_id));
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'Category set id: '
					||TO_CHAR(p_category_set_id));
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'Category Validate Flag: '
					||p_category_validate_flag);
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'Category Structure: '
					||TO_CHAR(p_category_structure));
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'Category: '
					||TO_CHAR(p_category_id));
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'Invoice Project Option: '
					||TO_CHAR(p_invoice_project_option));
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'Project Dummy: '
					||TO_CHAR(p_project_dummy));
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'Project Id: '
					||TO_CHAR(p_project_id));
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'Adjustment Account Dummy: '
					||TO_CHAR(p_adj_account_dummy));
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'Adjustment Account: '
					||TO_CHAR(p_adj_account));
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'Invoice Cutoff Date: '
					||p_cutoff_date);
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'Txn Process Mode: '
					||TO_CHAR(p_transaction_process_mode));

        ----------------------------------------------------------------------
        -- Make sure there is no other program running with the same args
	-- argument1  = organization
	-- argument3  = item option
	-- argument6  = specific item
	-- argument11 = invoice project option
	-- argument13 = project
	-- Error out logic :-
	-- * If either program in the same org has item option of All/Catg
	-- * If both prog running with specif item but either have all projects
	-- * if both prog running with same item, specific proj but same proj
        ----------------------------------------------------------------------
	l_stmt_num := 15;

	BEGIN
	SELECT fcr.request_id
	INTO   l_dummy
	FROM   fnd_concurrent_requests fcr
	WHERE  program_application_id = 702
	AND    concurrent_program_id = l_conc_program_id
	AND    phase_code IN ('I','P','R')
	AND    argument1 = TO_CHAR(p_organization_id)
	AND    ( (argument3 IN ('1', '5') OR p_item_option IN (1,5))
                  OR (argument3 = '2'
                      AND argument6 = TO_CHAR(p_specific_item_id)
		      AND (argument11 = '1' OR p_invoice_project_option = 1)
                     )
                  OR (argument3 = '2'
                      AND argument6 = TO_CHAR(p_specific_item_id)
		      AND argument11 = '2'
		      AND argument13 = TO_CHAR(p_project_id)
                     )
                )
	AND     fcr.request_id <> l_request_id
	AND ROWNUM=1;

        EXCEPTION
        WHEN NO_DATA_FOUND THEN
            l_dummy := -1;
        END;

	IF (l_dummy <> -1) THEN
	    RAISE CST_CSTPPIPV_RUNNING;
	END IF;

        l_org_id := p_organization_id;

        ----------------------------------------------------------------------
        -- Check that the organization is average.
        ----------------------------------------------------------------------
	l_stmt_num := 20;

	SELECT mp.primary_cost_method
	INTO   l_cost_method
	FROM   mtl_parameters mp
	WHERE  mp.organization_id = l_org_id;

	IF  (l_cost_method <> 2) THEN
	   RAISE CST_NO_AVG_ORG;
	END IF;

        ----------------------------------------------------------------------
        -- Set aida rows with 'N' status but which have no IPV to NULL.
        -- Invoice Lines Project: no invoice_price_variance column...need to
        -- go to separate IPV distribution
        -- Added a filter of accounting date on aida and join of invoice_id
        -- between aida and aida2 for performance improvement -  bug4137765
        ----------------------------------------------------------------------
	l_stmt_num := 25;

        UPDATE ap_invoice_distributions_all aida
        SET    aida.inventory_transfer_status = NULL
        WHERE  po_distribution_id IS NOT NULL
	/*AND    aida.line_type_lookup_code IN ('ITEM','ACCRUAL','NONREC_TAX') */
	/*Bug 9823230: Commented as per internal discussion to enhance performance and set transfer status
	to null for all LINE_TYPE_LOOKUP_CODE not eligible for IPV transfer */
        AND    aida.inventory_transfer_status = 'N'
        AND    aida.posted_flag               = 'Y'   --BUG#5709567-FPBUG#5109100
        AND    aida.accounting_date <= l_cutoff_date
        AND NOT EXISTS
        (
           SELECT 'X'
           FROM ap_invoice_distributions_all aida2
           WHERE
		(
			(
				aida2.line_type_lookup_code = 'IPV'
				/* Start of bug 8270017 */
				AND  (
				(aida.invoice_id = aida2.invoice_id and aida.invoice_distribution_id = aida2.related_id)
				or
				(aida.invoice_distribution_id = aida2.corrected_invoice_dist_id)

				)
				/* End of bug 8270017 */
			)
			OR /* Start of Bug 8681379*/
			(
				aida2.line_type_lookup_code IN ('TIPV','TERV','TRV')
				and aida.invoice_id = aida2.invoice_id
				and (aida.invoice_distribution_id = aida2.charge_applicable_to_dist_id
					OR
					aida.invoice_distribution_id = aida2.related_id    /*added condition bug 8681379*/
				     )
			)

		)
        );

	IF (l_debug = 'Y') THEN
            FND_FILE.PUT_LINE(FND_FILE.LOG, TO_CHAR(SQL%ROWCOUNT)
                              ||' Rows marked as NULL in AIDA ');
	END IF;


        --------------------------------------------------------------------
        --  Create a batch for the the process                            --
        --------------------------------------------------------------------
	l_stmt_num := 30;

	SELECT cst_ap_variance_batches_s.nextval
	INTO   l_batch_id
	FROM   DUAL;

	-- Populate Batch table here
	l_stmt_num := 35;

        INSERT INTO cst_ap_variance_batches
        (           batch_id,
		    description,
                    organization_id,
                    item_option,
                    invoice_project_option,
                    adjustment_account,
                    cutoff_date,
                    transaction_process_mode,
                    specific_item_id,
                    specific_project_id,
                    creation_date,
                    last_update_date,
                    last_updated_by,
                    created_by,
                    request_id,
                    program_application_id,
                    program_id,
                    program_update_date,
                    last_update_login
          )
          VALUES
          (         l_batch_id,
		    p_description,
                    p_organization_id,
                    P_item_option,
                    p_invoice_project_option,
                    p_adj_account,
                    l_cutoff_date,
                    P_transaction_process_mode,
                    p_specific_item_id,
                    p_project_id,
                    SYSDATE,
                    SYSDATE,
                    l_user_id,
                    l_user_id,
                    l_request_id,
                    l_prog_app_id,
                    l_prog_id,
                    SYSDATE,
                    l_login_id
            );


        ------------------------------------------------------------------
        -- Calculate default transaction date
        ------------------------------------------------------------------
	l_stmt_num := 40;

        get_default_date (p_organization_id  => l_org_id,
			  x_default_date     => l_default_txn_date,
			  x_err_num	     => l_err_num,
			  x_err_code	     => l_err_code,
			  x_err_msg	     => l_err_msg
			 );

    	IF (l_err_num <> 0) THEN
      	    RAISE cst_process_error;
    	END IF;

	IF (l_debug = 'Y') THEN
            FND_FILE.PUT_LINE(FND_FILE.LOG, 'Batch: '||TO_CHAR(l_batch_id));
            FND_FILE.PUT_LINE(FND_FILE.LOG, 'Default Date: '
                              ||TO_CHAR(l_default_txn_date));
	END IF;

        --------------------------------------------------------------------
	-- Get all inventory item in this org that require variance adj
        --------------------------------------------------------------------
	l_stmt_num := 45;

        FOR c_item_rec IN c_item LOOP

	    l_cost_group_id := c_item_rec.cg_id;

	    IF (l_debug = 'Y') THEN
                FND_FILE.PUT_LINE(FND_FILE.LOG, 'Item: '
                                  ||TO_CHAR(c_item_rec.item_id));
                FND_FILE.PUT_LINE(FND_FILE.LOG, 'CG: '||TO_CHAR(l_cost_group_id));
	    END IF;

            l_stmt_num := 50;
	    CSTPPIPV.generate_trf_info
			  ( p_organization_id        => l_org_id,
			    p_inventory_item_id      => c_item_rec.item_id,
			    p_invoice_project_option => p_invoice_project_option,
			    p_project_id	     => p_project_id,
			    p_cost_group_id	     => l_cost_group_id,
			    p_cutoff_date	     => l_cutoff_date,
			    p_user_id		     => l_user_id,
			    p_login_id		     => l_login_id,
			    p_request_id	     => l_request_id,
			    p_prog_id		     => l_prog_id,
			    p_prog_app_id	     => l_prog_app_id,
			    p_batch_id		     => l_batch_id,
                            p_default_txn_date       => l_default_txn_date,
			    x_err_num		     => l_err_num,
			    x_err_code		     => l_err_code,
			    x_err_msg		     => l_err_msg
			  );

	    IF (l_err_num <> 0) THEN
                RAISE cst_process_error;
	    END IF;

	    END LOOP; -- c_item_rec

            -------------------------------------------------------------------
	    -- create MTL_TRANSACTIONS_INTERFACE row for each POD,
            -- with transaction_type = 80 (Average Cost Update)
	    -- If var_amount <> 0
            -------------------------------------------------------------------
	    l_stmt_num := 55;

            INSERT INTO mtl_transactions_interface
            (
                        transaction_interface_id,
                        source_code,
                        source_line_id,		-- cavh.variance_header_id
                        source_header_id,	-- cavh.batch_id
                        process_flag,
                        transaction_mode,
                        last_update_date,
                        last_updated_by,
                        creation_date,
                        created_by,
                        last_update_login,
                        request_id,
                        program_application_id,
                        program_id,
                        validation_required,
                        inventory_item_id,
                        organization_id,
                        cost_group_id,
                        transaction_date,
                        transaction_quantity,
                        transaction_uom,
                        transaction_type_id,
                        value_change,
                        material_account,
                        transaction_reference	-- cavh.po_distribution_id
               )
               (
                SELECT  mtl_material_transactions_s.nextval,
                        'VARIANCE TRF',
                        cavh.variance_header_id,
                        cavh.batch_id,
                        p_transaction_process_mode,
                        3,
                        SYSDATE,
                        l_user_id,
                        SYSDATE,
                        l_user_id,
                        l_login_id,
                        l_request_id,
                        l_prog_app_id,
                        l_prog_id,
                        1,
                        cavh.inventory_item_id,
                        cavh.organization_id,
                        cavh.cost_group_id,
                        decode(l_txn_date_profile, 2, SYSDATE,
					cavh.transaction_date),
                        0,
                        msi.primary_uom_code,
                        80,
                        cavh.var_amount,
                        p_adj_account,
                        'PO Distribution: '|| TO_CHAR (cavh.po_distribution_id)
                 FROM   cst_ap_variance_headers cavh,
                        mtl_system_items msi
                 WHERE  cavh.batch_id = l_batch_id
                 AND    cavh.var_amount <> 0
                 AND    cavh.inventory_item_id = msi.inventory_item_id
                 AND    cavh.organization_id = msi.organization_id
                );

	    IF (l_debug = 'Y') THEN
                FND_FILE.PUT_LINE(FND_FILE.LOG, TO_CHAR(SQL%ROWCOUNT)
                                  ||' Rows inserted into MTI');
	    END IF;

            -------------------------------------------------------------------
            -- Create detail row MTL_TXN_COST_DET_INTERFACE for each mti row
            -- previously created for the batch to ensure that value change
            -- will update this level/material cost element only.
            -------------------------------------------------------------------

	    l_stmt_num := 60;

            INSERT INTO mtl_txn_cost_det_interface
            (       transaction_interface_id,
                    last_update_date,
                    last_updated_by,
                    creation_date,
                    created_by,
                    last_update_login,
                    request_id,
                    program_application_id,
                    program_id,
                    organization_id,
                    cost_element_id,
                    level_type,
                    value_change
            )
            (SELECT    mti.transaction_interface_id,
                    SYSDATE,
                    l_user_id,
                    SYSDATE,
                    l_user_id,
                    l_login_id,
                    l_request_id,
                    l_prog_app_id,
                    l_prog_id,
                    mti.organization_id,
                    1,    --  cost element id = 1
                    1,    --  this level = 1
                    mti.value_change
             FROM     mtl_transactions_interface mti
             WHERE    mti.source_header_id = l_batch_id
            );

	    IF (l_debug = 'Y') THEN

              FND_FILE.PUT_LINE(FND_FILE.LOG, TO_CHAR(SQL%ROWCOUNT)
					||' Rows inserted into MTCDI');
	    END IF;

	COMMIT;

EXCEPTION

 	WHEN CST_CSTPPIPV_RUNNING THEN
		ROLLBACK;
                l_err_num := 20009;

                l_err_code := SUBSTR('CSTPPIPV.trf_invoice_to_inventory('
                                || to_char(l_stmt_num)
                                || '): '
				|| 'Req_id: '
			        || TO_CHAR(l_dummy)
				||' '
                                || l_err_msg
                                || '. ',1,240);

                fnd_message.set_name('BOM', 'CST_CSTPPIPV_RUNNING');
                l_err_msg := fnd_message.get;
                l_err_msg := SUBSTR(l_err_msg,1,240);
        	FND_FILE.PUT_LINE(fnd_file.log,SUBSTR(l_err_code
						||' '
						||l_err_msg,1,240));
          	CONC_STATUS := FND_CONCURRENT.
				SET_COMPLETION_STATUS('ERROR',l_err_msg);


 	WHEN CST_NO_AVG_ORG THEN
		ROLLBACK;
                l_err_num := 20010;

                l_err_code := SUBSTR('CSTPPIPV.trf_invoice_to_inventory('
                                || to_char(l_stmt_num)
                                || '): '
                                || l_err_msg
                                || '. ',1,240);

                fnd_message.set_name('BOM', 'CST_NO_AVG_ORG');
                l_err_msg := fnd_message.get;
                l_err_msg := SUBSTR(l_err_msg,1,240);
        	FND_FILE.PUT_LINE(fnd_file.log,l_err_msg);
          	CONC_STATUS := FND_CONCURRENT.
				SET_COMPLETION_STATUS('ERROR',l_err_msg);


      	WHEN CST_PROCESS_ERROR THEN
		ROLLBACK;
                l_err_num  := l_err_num;
                l_err_code := l_err_code;
                l_err_msg  := SUBSTR(l_err_msg,1,240);
        	FND_FILE.PUT_LINE(fnd_file.log,l_err_msg);
          	CONC_STATUS := FND_CONCURRENT.
				SET_COMPLETION_STATUS('ERROR',l_err_msg);


        WHEN OTHERS THEN
                ROLLBACK;
                l_err_num := SQLCODE;
                l_err_code := NULL;
                l_err_msg := SUBSTR('CSTPPIPV.trf_invoice_to_inventory('
                                || to_char(l_stmt_num)
                                || '): '
                                ||SQLERRM,1,240);
        	FND_FILE.PUT_LINE(fnd_file.log,l_err_msg);
          	CONC_STATUS := FND_CONCURRENT.
				SET_COMPLETION_STATUS('ERROR',l_err_msg);


END trf_invoice_to_inventory;

/*---------------------------------------------------------------------------*
|  PRIVATE PROCEDURE                                                         |
|      trf_invoice_to_wip                                                    |
|      This procedure generates the necessary interface transactions to      |
|      transfer the invoice price variances of items that match the user     |
|      specified parameters to the corresponding work orders in Work In      |
|      Process. Currently it's only processing the invoice price variances   |
|      of Outside Processing and Direct items for Maintenance Work Order.    |
|                                                                            |
|  p_item_type:                                                              |
|      1:  Outside Processing and Direct items                               |
|      2:  Outside Processing items only                                     |
|      3:  Direct Items only                                                 |
|                                                                            |
|  p_item_option:       					             |
|      1:  All Asset items                                                   |
|      2:  Specific Asset Item                                               |
|      5:  Category Items                                                    |
|                                                                            |
|  p_invoice_project_option:                                                 |
|      1:  All invoices                                                      |
|      2:  Project invoices                                                  |
|                                                                            |
|  p_transaction_process_mode:                                               |
|      1:  Real transfer, update AP table to mark transferred invoices       |
|      2:  Simulated transfer, does not update AP tables                     |
|                                                                            |
|  aida.inventory_transfer_status:                                           |
|      N:  Not transferred                                                   |
|   Null:  Transferred or Not Applicable                                     |
|                                                                            |
*----------------------------------------------------------------------------*/

FUNCTION trf_invoice_to_wip(
        errbuf                     OUT NOCOPY      	VARCHAR2,
        retcode                    OUT NOCOPY      	NUMBER,
        p_organization_id          IN		NUMBER,
        p_description		   IN		VARCHAR2 DEFAULT NULL,
        p_work_order_id            IN           NUMBER DEFAULT NULL,
        p_item_type                IN           NUMBER,
        p_item_option		   IN		NUMBER DEFAULT NULL,
	p_specific_item_id	   IN		NUMBER DEFAULT NULL,
	p_category_set_id	   IN		NUMBER DEFAULT NULL,
        p_category_id              IN      	NUMBER DEFAULT NULL,
        p_project_id               IN           NUMBER DEFAULT NULL,
        p_adj_account		   IN		NUMBER,
        p_cutoff_date		   IN		VARCHAR2,
        p_transaction_process_mode IN      	NUMBER,
	p_request_id		   IN           NUMBER,
	p_user_id                  IN           NUMBER,
	p_login_id                 IN           NUMBER,
	p_prog_appl_id             IN           NUMBER,
	p_prog_id                  IN           NUMBER
)
RETURN NUMBER IS

l_cutoff_date			DATE;
l_batch_id			NUMBER;
l_request_id			NUMBER;
l_user_id			NUMBER;
l_item_option			NUMBER;
l_project_option		NUMBER;
l_prog_id			NUMBER;
l_prog_app_id			NUMBER;
l_login_id			NUMBER;
l_conc_program_id		NUMBER;
l_stmt_num                      NUMBER;
l_err_num                       NUMBER;
l_err_code                      VARCHAR2(240);
l_err_msg                       VARCHAR2(240);
l_default_txn_date              DATE;
l_txn_date_profile		NUMBER;
l_dummy				NUMBER;
l_debug				VARCHAR2(80);
l_legal_entity                  NUMBER;
l_row_count                     NUMBER;
l_server_day_time               DATE;
l_le_day_time                   DATE;
l_server_le_offset              NUMBER;
conc_status			BOOLEAN;
cst_process_error		EXCEPTION;
cst_cstppipv_running		EXCEPTION;

TYPE dists_tab_type is TABLE OF po_distributions_all.po_distribution_id%TYPE INDEX BY BINARY_INTEGER;
l_po_dists_tab dists_tab_type;

-- This cursor lists PO distributions w/ invoice distributions that has not been
-- transferred to Inventory nor WIP.

CURSOR c_po_dist
IS
   SELECT  DISTINCT
	    pda.po_distribution_id,
            pla.item_id inventory_item_id,
	    pda.project_id
    FROM    po_distributions_all pda,
	    po_line_locations_all plla,
            po_lines_all pla,
            wip_entities we,
            wip_discrete_jobs wdj
    WHERE   (   (   (   p_item_type = 1       -- OSP and direct
                    OR  p_item_type = 2)      -- OSP only
                AND (   (   l_item_option = 1 -- All items
			    AND EXISTS  (
                                SELECT  'X'
                                FROM    mtl_system_items_b msi
                                WHERE   msi.organization_id = p_organization_id
                                AND     msi.inventory_item_id = pla.item_id
                                AND     msi.outside_operation_flag = 'Y' and rownum <2) )
                    OR  (   l_item_option = 2 -- Specific item
                            AND EXISTS (
			        SELECT  'X'
			        FROM    mtl_system_items_b msi
			        WHERE   msi.organization_id = p_organization_id
				AND     msi.inventory_item_id = p_specific_item_id
			        AND     msi.inventory_item_id = pla.item_id
			        AND     msi.outside_operation_flag = 'Y' and rownum <2 )     )
                    OR  (   l_item_option = 5 -- Category items
                            AND  EXISTS   (
		                SELECT  'X'
                                FROM    mtl_item_categories mic,
				        mtl_system_items_b msi
                                WHERE   mic.organization_id = p_organization_id
		                AND     mic.category_id = p_category_id
                                AND     mic.category_set_id = p_category_set_id
                                AND     mic.inventory_item_id = msi.inventory_item_id
				AND     msi.organization_id = p_organization_id
                                AND     msi.inventory_item_id = pla.item_id
                                AND     msi.outside_operation_flag = 'Y' and rownum <2 )             )))
            OR  (   (   p_item_type = 1       -- OSP and direct
                    OR  p_item_type = 3)      -- direct only
                AND (   pla.item_id IS NULL
                    OR  EXISTS (
                          SELECT 'X'
                          FROM   mtl_system_items_b msi
                          WHERE  msi.organization_id = p_organization_id
                          AND    msi.inventory_item_id = pla.item_id
                          AND    msi.stock_enabled_flag = 'N'
                        )
                    )
                )
            )
    AND     plla.po_line_id = pla.po_line_id
    AND     pda.line_location_id = plla.line_location_id
    AND     pda.destination_type_code = 'SHOP FLOOR'
    AND     pda.destination_organization_id = p_organization_id
    AND     pda.wip_entity_id = nvl(p_work_order_id,pda.wip_entity_id)
    AND     we.wip_entity_id = pda.wip_entity_id
    AND     we.entity_type = 6                -- open maintenance work order
    AND     wdj.wip_entity_id = pda.wip_entity_id
    AND     wdj.status_type in (3,4)          -- released / completed work order
    AND     (  (   pda.project_id IS NULL
	       AND l_project_option = 1)
	    OR (   pda.project_id IS NOT NULL
	       AND EXISTS (
		   SELECT  'X'
		   FROM    pjm_project_parameters ppp
                   WHERE   ppp.organization_id = p_organization_id
		   AND     ppp.project_id = pda.project_id
		   AND     ppp.project_id = decode(
				l_project_option,
				1,
                                ppp.project_id,
				p_project_id)
		 and rownum <2)      ))
    AND     EXISTS (
	        SELECT  'X'
                FROM    ap_invoice_distributions_all aida
                WHERE   aida.po_distribution_id = pda.po_distribution_id
	        AND     aida.posted_flag = 'Y'
		AND     aida.accounting_date < l_cutoff_date
                AND     aida.inventory_transfer_status = 'N'
                AND     aida.line_type_lookup_code IN ('ITEM','ACCRUAL') --same change as earlier
-- J Changes -----------------------------------------------------------------
--              AND     aida.root_distribution_id IS NULL
-------------------------------------------------------------------------------
                AND     aida.corrected_invoice_dist_id IS NULL --same change as earlier
                and rownum <2    )  ;

/* bug 4873742 -- added to bypass performance repository issues */

cursor c_po_dists2 is
SELECT pda.po_distribution_id
                FROM   po_distributions_all pda,
                       wip_entities we,
                       wip_discrete_jobs wdj,
                       wip_operation_resources wor
                WHERE  we.wip_entity_id = pda.wip_entity_id
                AND    we.entity_type = 6
                AND    wdj.wip_entity_id = pda.wip_entity_id
                AND    wdj.status_type = 3
                AND    wor.wip_entity_id = pda.wip_entity_id
	        AND    wor.operation_seq_num = pda.wip_operation_seq_num
                AND    wor.resource_seq_num = pda.wip_resource_seq_num
                AND    wor.standard_rate_flag = 1;

BEGIN

        ---------------------------------------------------------------------
        -- Initializing Variables
        ---------------------------------------------------------------------
        l_err_num          := 0;
        l_err_code         := '';
        l_err_msg          := '';
        l_request_id       := 0;
        l_user_id          := 0;
        l_prog_id          := 0;
        l_prog_app_id      := 0;
        l_login_id         := 0;
        l_default_txn_date := NULL;
        l_cutoff_date	   := FND_DATE.canonical_to_date(p_cutoff_date);
        l_row_count  := 0;

        -- Set item option to 1 (All items) if item type is not 2 (OSP only)
        IF (p_item_type <> 2) THEN
          l_item_option := 1;
        ELSE
          l_item_option := p_item_option;
        END IF;

        -- Set invoice project option to 1 if no project is specified
        IF (p_project_id IS NULL) THEN
          l_project_option := 1;
        ELSE
          l_project_option := 2;
        END IF;

        ----------------------------------------------------------------------
        -- Retrieving concurrent program information
        ----------------------------------------------------------------------
        l_stmt_num := 5;

        l_request_id       := p_request_id;
        l_user_id          := p_user_id;
        l_prog_id          := p_prog_id;
        l_prog_app_id      := p_prog_appl_id;
        l_login_id         := p_login_id;
	l_conc_program_id  := p_prog_id;
	l_debug		   := FND_PROFILE.VALUE('MRP_DEBUG');
	l_txn_date_profile := FND_PROFILE.VALUE('TRANSACTION_DATE');

	l_stmt_num := 10;

        FND_FILE.PUT_LINE(FND_FILE.LOG, 'Transfer Invoice to Work In Process');

        FND_FILE.PUT_LINE(FND_FILE.LOG, 'Request Id: '
					||to_char(l_request_id));
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'User Id: '
					||to_char(l_user_id));
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'Login Id: '
					||to_char(l_login_id));
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'Program Id: '
					||to_char(l_prog_id));
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'Prog Appl Id: '
					||to_char(l_prog_app_id));
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'Conc Program Id: '
					||to_char(l_conc_program_id));
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'Debug: '
					||l_debug);
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'Txn Date Profile: '
					||TO_CHAR(l_txn_date_profile));
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'Organization: '
					||TO_CHAR(p_organization_id));
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'Description: '
					||p_description);
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'Specific Work Order: '
					||TO_CHAR(p_work_order_id));
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'Item Type: '
					||TO_CHAR(p_item_type));
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'Item Option: '
					||TO_CHAR(l_item_option));
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'Specific Item: '
					||TO_CHAR(p_specific_item_id));
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'Category set id: '
					||TO_CHAR(p_category_set_id));
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'Category: '
					||TO_CHAR(p_category_id));
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'Invoice Project Option: '
					||TO_CHAR(l_project_option));
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'Project Id: '
					||TO_CHAR(p_project_id));
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'Adjustment Account: '
					||TO_CHAR(p_adj_account));
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'Invoice Cutoff Date: '
					||p_cutoff_date);
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'Txn Process Mode: '
					||TO_CHAR(p_transaction_process_mode));

        ----------------------------------------------------------------------
        -- Make sure there is no other program running with the same args
	-- argument2  = organization
	-- argument6  = item option
	-- argument9  = specific item
	-- argument14 = invoice project option
	-- argument16 = project
	-- Error out logic :-
	-- * If either program in the same org has item option of All/Catg
	-- * If both prog running with same item but either have all projects
	-- * if both prog running with same item, specific proj but same proj
        ----------------------------------------------------------------------

	l_stmt_num := 15;

	BEGIN
	SELECT  fcr.request_id
	INTO    l_dummy
	FROM    fnd_concurrent_requests fcr
	WHERE   program_application_id = 702
	AND     concurrent_program_id = l_conc_program_id
	AND     phase_code IN ('I','P','R')
	AND	argument2 = TO_CHAR(p_organization_id)
	AND     (   argument6 IN ('1', '5')
		OR  l_item_option IN (1,5)
                OR  (   argument6 = '2'
                        AND argument9 = TO_CHAR(p_specific_item_id)
		        AND (   argument14 = '1'
			    OR  l_project_option = 1
			    OR  (argument16 = TO_CHAR(p_project_id)))))
	AND     fcr.request_id <> l_request_id
	AND     ROWNUM=1;

        EXCEPTION
        WHEN NO_DATA_FOUND THEN
            l_dummy := -1;
        END;

	IF (l_dummy <> -1) THEN
	    RAISE CST_CSTPPIPV_RUNNING;
	END IF;

        ----------------------------------------------------------------------
        -- Set aida rows with 'N' status but which was created for an OSP
        -- with standard rate to 'S'.
        ----------------------------------------------------------------------

	l_stmt_num := 22;

	/* bug 4873742 -- added to bypass performance repository issues */

	open c_po_dists2;
	loop
	fetch c_po_dists2 bulk collect into l_po_dists_tab limit 1000 ;
	exit when (c_po_dists2%notfound);

	forall i in l_po_dists_tab.first..l_po_dists_tab.last


	UPDATE  ap_invoice_distributions_all aida
	SET     aida.inventory_transfer_status = 'S'
	WHERE   aida.inventory_transfer_status = 'N'
	AND	aida.posted_flag = 'Y'
        AND     aida.accounting_date <= p_cutoff_date
        AND     aida.po_distribution_id  = l_po_dists_tab(i);

	l_row_count := l_row_count +SQL%ROWCOUNT;

	end loop;

        close c_po_dists2;

	IF (l_debug = 'Y') THEN
          FND_FILE.PUT_LINE(FND_FILE.LOG, TO_CHAR(l_row_count)||' rows marked as S in AIDA');
	END IF;

        ----------------------------------------------------------------------
        -- Set aida rows with 'N' status but which have no IPV to NULL.
        -- Added a filter of accounting date on aida and join of invoice_id
        -- between aida and aida2 for performance improvement -  bug4137765
        ----------------------------------------------------------------------

	l_stmt_num := 25;

        UPDATE  ap_invoice_distributions_all aida
        SET     aida.inventory_transfer_status = NULL
        WHERE   po_distribution_id IS NOT NULL
	/*AND     aida.line_type_lookup_code IN ('ITEM','ACCRUAL','NONREC_TAX') */
	/* Bug 9823230: Commented as per internal discussion to enhance performance and set transfer status
	to null for all LINE_TYPE_LOOKUP_CODE not eligible for IPV transfer*/
        AND     aida.inventory_transfer_status = 'N'
        AND     aida.posted_flag = 'Y'
        AND     aida.accounting_date <= l_cutoff_date
        AND NOT EXISTS --same change as earlier
        (
           SELECT 'X'
           FROM ap_invoice_distributions_all aida2
           WHERE
		(
			(
				aida2.line_type_lookup_code = 'IPV'
				/* Start of bug 8270017 */
				AND
				(
				 (aida.invoice_id = aida2.invoice_id and aida.invoice_distribution_id = aida2.related_id)
				  or
				 (aida.invoice_distribution_id = aida2.corrected_invoice_dist_id)
				)
				/* End of bug 8270017 */
			)
			OR /* Start of Bug 8681379*/
			(
				aida2.line_type_lookup_code IN ('TIPV','TERV','TRV')
				and aida.invoice_id = aida2.invoice_id
				and (aida.invoice_distribution_id = aida2.charge_applicable_to_dist_id
					OR
					aida.invoice_distribution_id = aida2.related_id    /*added condition bug 8681379*/
				     )
			)  /*End of Bug 8681379*/
		)
        );


	IF (l_debug = 'Y') THEN
          FND_FILE.PUT_LINE(FND_FILE.LOG, TO_CHAR(SQL%ROWCOUNT)||' rows marked as NULL in AIDA');
	END IF;

        ----------------------------------------------------------------------
        --  Create a batch for the the process
        ----------------------------------------------------------------------

	l_stmt_num := 30;

	SELECT  cst_ap_variance_batches_s.nextval
	INTO    l_batch_id
	FROM	DUAL;

	-- Populate Batch table here
	l_stmt_num := 35;

        INSERT  INTO
		cst_ap_variance_batches
                (
		    batch_id,
                    organization_id,
                    item_option,
                    invoice_project_option,
                    adjustment_account,
                    cutoff_date,
                    transaction_process_mode,
                    specific_item_id,
                    specific_project_id,
		    category_id,
		    category_set_id,
                    creation_date,
                    last_update_date,
                    last_updated_by,
                    created_by,
                    request_id,
                    program_application_id,
                    program_id,
                    program_update_date,
                    last_update_login,
		    description,
		    wip_entity_id,
		    item_type)
        VALUES  (
		    l_batch_id,
                    p_organization_id,
                    l_item_option,
                    l_project_option,
                    p_adj_account,
                    l_cutoff_date,
                    p_transaction_process_mode,
                    p_specific_item_id,
                    p_project_id,
		    p_category_id,
		    p_category_set_id,
                    SYSDATE,
                    SYSDATE,
                    l_user_id,
                    l_user_id,
                    l_request_id,
                    l_prog_app_id,
                    l_prog_id,
                    SYSDATE,
                    l_login_id,
		    p_description,
		    p_work_order_id,
		    p_item_type);

        ----------------------------------------------------------------------
        -- Calculate default transaction date
        ----------------------------------------------------------------------

	l_stmt_num := 40;

        get_default_date (
	    p_organization_id  => p_organization_id,
	    x_default_date     => l_default_txn_date,
	    x_err_num	       => l_err_num,
	    x_err_code	       => l_err_code,
	    x_err_msg	       => l_err_msg
	);

    	IF (l_err_num <> 0) THEN
      	    RAISE cst_process_error;
    	END IF;

	IF (l_debug = 'Y') THEN
            FND_FILE.PUT_LINE(FND_FILE.LOG, 'Batch: '||TO_CHAR(l_batch_id));
            FND_FILE.PUT_LINE(FND_FILE.LOG, 'Default Date: '||TO_CHAR(l_default_txn_date));
	END IF;

        ----------------------------------------------------------------------
        -- Calculate timezone offset from legal entity time to server time
        ----------------------------------------------------------------------
        l_legal_entity     := 0;
        l_server_day_time  := NULL;
        l_le_day_time      := SYSDATE;
        l_server_le_offset := 0;

        l_stmt_num := 42;

/* select legal entity from HR_ORGANIZATION_INFORMATION instead of cst_organization_definitions
for performance improvement */

        SELECT org_information2
        INTO   l_legal_entity
        FROM   HR_ORGANIZATION_INFORMATION
	where	ORG_INFORMATION_CONTEXT = 'Accounting Information'
	and organization_id = p_organization_id;

        l_server_day_time := INV_LE_TIMEZONE_PUB.GET_SERVER_DAY_TIME_FOR_LE(
                               l_le_day_time,
                               l_legal_entity);

        l_server_le_offset := l_server_day_time - l_le_day_time;

        ----------------------------------------------------------------------
	-- Generate IPV information for the obtained PO distributions
        ----------------------------------------------------------------------

	l_stmt_num := 45;

	FOR c_po_dist_rec IN c_po_dist LOOP

	    IF (l_debug = 'Y') THEN
                FND_FILE.PUT_LINE(FND_FILE.LOG, 'PO Distribution: '
			||TO_CHAR(c_po_dist_rec.po_distribution_id));
	    END IF;

            l_stmt_num := 50;

	    CSTPPIPV.generate_wip_info (
		p_organization_id          => p_organization_id,
		p_inventory_item_id        => c_po_dist_rec.inventory_item_id,
		p_project_id               => c_po_dist_rec.project_id,
		p_po_distribution_id       => c_po_dist_rec.po_distribution_id,
		p_cutoff_date	           => l_cutoff_date,
		p_user_id		   => l_user_id,
		p_login_id		   => l_login_id,
		p_request_id	           => l_request_id,
		p_prog_id		   => l_prog_id,
		p_prog_app_id	           => l_prog_app_id,
		p_batch_id		   => l_batch_id,
		p_transaction_process_mode => p_transaction_process_mode,
                p_default_txn_date         => l_default_txn_date,
		x_err_num		   => l_err_num,
		x_err_code		   => l_err_code,
		x_err_msg		   => l_err_msg
	    );

	    IF (l_err_num <> 0) THEN
	        RAISE cst_process_error;
	    END IF;

	END LOOP; -- c_po_dist_rec

        -------------------------------------------------------------------
        -- create WIP_COST_TXN_INTERFACE row for each POD,
        -- with transaction_type 3 (OSP) and 17 (DP)
	-- If var_amount <> 0
        -------------------------------------------------------------------

	l_stmt_num := 55;

	IF (p_transaction_process_mode = 1) THEN
            INSERT  INTO
	            wip_cost_txn_interface (
                        transaction_id,
                        last_update_date,
                        last_updated_by,
			last_updated_by_name,
                        creation_date,
                        created_by,
		        created_by_name,
                        last_update_login,
                        request_id,
                        program_application_id,
                        program_id,
		        program_update_date,
                        source_code,
                        source_line_id,
                        process_phase,
                        process_status,
                        transaction_type,
                        organization_id,
			organization_code,
                        wip_entity_id,
                        entity_type,
                        primary_item_id,
                        transaction_date,
                        acct_period_id,
                        operation_seq_num,
                        resource_seq_num,
                        department_id,
                        resource_id,
		        usage_rate_or_amount,
		        basis_type,
		        autocharge_type,
                        standard_rate_flag,
		        transaction_quantity,
		        transaction_uom,
                        primary_quantity,
		        primary_uom,
                        actual_resource_rate,
                        reference,
                        po_header_id,
                        po_line_id,
		        receiving_account_id)
            (
            SELECT  NULL,
	            SYSDATE,
                    l_user_id,
		    fu.user_name,
                    SYSDATE,
                    l_user_id,
		    fu.user_name,
                    l_login_id,
                    l_request_id,
                    l_prog_app_id,
                    l_prog_id,
	    	    SYSDATE,
                    'IPV',
		    cavh.variance_header_id,
                    decode(nvl(wor.resource_id,-1),-1,2,1),
                    1,
                    decode(nvl(wor.resource_id,-1),-1,17,3),
                    cavh.organization_id,
		    mp.organization_code,
	    	    pda.wip_entity_id,
                    6, -- Open Maintenance Job
                    cavh.inventory_item_id,
                    decode(l_txn_date_profile,2,SYSDATE,cavh.transaction_date),
		    oap.acct_period_id,
                    pda.wip_operation_seq_num,
                    pda.wip_resource_seq_num,
                    wor.department_id,
                    wor.resource_id,
		    cavh.var_amount,
		    wor.basis_type,
		    wor.autocharge_type,
                    2, -- Standard Rate Flag
                    0, -- Transaction Quantity
		    wor.uom_code,
                    0, -- Primary Quantity
		    wor.uom_code,
                    cavh.var_amount,
                    'PO Distribution: '|| TO_CHAR (cavh.po_distribution_id),
                    pda.po_header_id,
                    pda.po_line_id,
                    p_adj_account
            FROM    cst_ap_variance_headers cavh,
		    po_distributions_all pda,
		    wip_operation_resources wor,
                    org_acct_periods oap,
		    mtl_parameters mp,
		    fnd_user fu
            WHERE   cavh.batch_id = l_batch_id
            AND     cavh.var_amount <> 0
            AND     pda.po_distribution_id = cavh.po_distribution_id
	    AND	    wor.wip_entity_id (+) = pda.wip_entity_id
	    AND     wor.operation_seq_num (+) = pda.wip_operation_seq_num
	    AND	    wor.resource_seq_num (+) = pda.wip_resource_seq_num
	    AND     oap.organization_id = cavh.organization_id
            AND     decode(l_txn_date_profile,2,SYSDATE,cavh.transaction_date)
                    BETWEEN (oap.period_start_date + l_server_le_offset)
                    AND     (oap.schedule_close_date+.99999 + l_server_le_offset)
	    AND     mp.organization_id = cavh.organization_id
            AND     fu.user_id = l_user_id);

	    IF (l_debug = 'Y') THEN
               FND_FILE.PUT_LINE(FND_FILE.LOG, TO_CHAR(SQL%ROWCOUNT)
					||' Rows inserted into WCTI');
	    END IF;

	END IF;

	RETURN l_batch_id;

EXCEPTION
 	WHEN CST_CSTPPIPV_RUNNING THEN
		ROLLBACK;
	        retcode := 1;
                l_err_num  := 20009;
                l_err_code := SUBSTR('CSTPPIPV.trf_invoice_to_wip('
                                || to_char(l_stmt_num)
                                || '): '
				|| 'Req_id: '
			        || TO_CHAR(l_dummy)
				||' '
                                || l_err_msg
                                || '. ',1,240);

                fnd_message.set_name('BOM', 'CST_CSTPPIPV_RUNNING');
                l_err_msg := fnd_message.get;
                l_err_msg := SUBSTR(l_err_msg,1,240);
        	FND_FILE.PUT_LINE(fnd_file.log,SUBSTR(l_err_code
						||' '
						||l_err_msg,1,240));
          	CONC_STATUS := FND_CONCURRENT.
				SET_COMPLETION_STATUS('ERROR',l_err_msg);

      	WHEN CST_PROCESS_ERROR THEN
		ROLLBACK;
		retcode := 1;
                l_err_num  := l_err_num;
                l_err_code := l_err_code;
                l_err_msg  := SUBSTR(l_err_msg,1,240);
        	FND_FILE.PUT_LINE(fnd_file.log,l_err_msg);
          	CONC_STATUS := FND_CONCURRENT.
				SET_COMPLETION_STATUS('ERROR',l_err_msg);

        WHEN OTHERS THEN
                ROLLBACK;
		retcode := 1;
                l_err_num  := SQLCODE;
                l_err_code := NULL;
                l_err_msg  := SUBSTR('CSTPPIPV.trf_invoice_to_wip('
                                || to_char(l_stmt_num)
                                || '): '
                                ||SQLERRM,1,240);
        	FND_FILE.PUT_LINE(fnd_file.log,l_err_msg);
          	CONC_STATUS := FND_CONCURRENT.
				SET_COMPLETION_STATUS('ERROR',l_err_msg);
END trf_invoice_to_wip;

PROCEDURE trf_invoice_to_wip(
        errbuf                     OUT NOCOPY      	VARCHAR2,
        retcode                    OUT NOCOPY      	NUMBER,
        p_organization_id          IN		NUMBER,
        p_description		   IN		VARCHAR2 DEFAULT NULL,
        p_work_order_id            IN           NUMBER DEFAULT NULL,
        p_item_type                IN           NUMBER,
        p_item_type_dummy          IN           NUMBER DEFAULT NULL,
        p_item_option		   IN		NUMBER DEFAULT NULL,
	p_item_dummy		   IN		NUMBER DEFAULT NULL,
	p_category_dummy	   IN		NUMBER DEFAULT NULL,
	p_specific_item_id	   IN		NUMBER DEFAULT NULL,
	p_category_set_id	   IN		NUMBER DEFAULT NULL,
 	p_category_validate_flag   IN     	VARCHAR2 DEFAULT NULL,
        p_category_structure       IN      	NUMBER DEFAULT NULL,
        p_category_id              IN      	NUMBER DEFAULT NULL,
        p_project_dummy		   IN		NUMBER DEFAULT NULL,
        p_project_id		   IN		NUMBER DEFAULT NULL,
        p_adj_account_dummy        IN           NUMBER,
        p_adj_account		   IN		NUMBER,
        p_cutoff_date		   IN		VARCHAR2,
        p_transaction_process_mode IN      	NUMBER
)
IS
   l_stmt_num         NUMBER;
   l_err_num          NUMBER;
   l_err_code         VARCHAR2(240);
   l_err_msg          VARCHAR2(240);
  	l_batch_id         NUMBER;
	l_request_id       NUMBER;
	l_user_id          NUMBER;
	l_prog_id          NUMBER;
	l_prog_appl_id     NUMBER;
	l_login_id         NUMBER;
	l_conc_program_id  NUMBER;
   conc_status        BOOLEAN;

/* Skip Process Organizations Cost Manager Changes - Anand Thiyagarajan - 26-Oct-2004 Start */

   l_process_enabled_flag  mtl_parameters.process_enabled_flag%TYPE;
   l_organization_code     mtl_parameters.organization_code%TYPE;

/* Skip Process Organizations Cost Manager Changes - Anand Thiyagarajan - 26-Oct-2004 End */

BEGIN

   /* Skip Process Organizations Cost Manager Changes - Anand Thiyagarajan - 26-Oct-2004 Start */
   BEGIN
      SELECT   nvl(process_enabled_flag,'N'), organization_code
      INTO     l_process_enabled_flag, l_organization_code
      FROM     mtl_parameters
      WHERE    organization_id = p_organization_id;

      IF nvl(l_process_enabled_flag,'N') = 'Y' THEN
         l_err_num := 30001;
         fnd_message.set_name('GMF', 'GMF_PROCESS_ORG_ERROR');
         fnd_message.set_token('ORGCODE', l_organization_code);
         l_err_msg := FND_MESSAGE.Get;
         l_err_msg := substrb('CSTPIPVB : ' || l_err_msg,1,240);
         CONC_STATUS := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR',l_err_msg);
         fnd_file.put_line(fnd_file.log,l_err_msg);
         RETURN;
      END IF;

   EXCEPTION
      WHEN no_data_found THEN
         l_process_enabled_flag := 'N';
         l_organization_code := NULL;
   END;
   /* Skip Process Organizations Cost Manager Changes - Anand Thiyagarajan - 26-Oct-2004 End */

	l_stmt_num         := 7;
        l_request_id       := FND_GLOBAL.conc_request_id;
        l_user_id          := FND_GLOBAL.user_id;
        l_prog_id          := FND_GLOBAL.conc_program_id;
        l_prog_appl_id     := FND_GLOBAL.prog_appl_id;
        l_login_id         := FND_GLOBAL.conc_login_id;
        l_conc_program_id  := FND_GLOBAL.conc_program_id;
        l_stmt_num         := 14;
	l_batch_id         := trf_invoice_to_wip(
                            errbuf                     => errbuf,
                            retcode                    => retcode,
                            p_organization_id          => p_organization_id,
                            p_description              => p_description,
                            p_work_order_id            => p_work_order_id,
                            p_item_type                => p_item_type,
                            p_item_option              => p_item_option,
                            p_specific_item_id         => p_specific_item_id,
                            p_category_set_id          => p_category_set_id,
                            p_category_id              => p_category_id,
                            p_project_id               => p_project_id,
                            p_adj_account              => p_adj_account,
                            p_cutoff_date              => p_cutoff_date,
                            p_transaction_process_mode => p_transaction_process_mode,
                            p_request_id               => l_user_id,
                            p_user_id                  => l_user_id,
                            p_login_id                 => l_login_id,
                            p_prog_appl_id             => l_prog_appl_id,
                            p_prog_id                  => l_prog_id
        );
EXCEPTION
        WHEN OTHERS THEN
                ROLLBACK;
                retcode := 1;
                l_err_num  := SQLCODE;
                l_err_code := NULL;
                l_err_msg  := SUBSTR('CSTPPIPV.trf_invoice_to_wip('
                                || to_char(l_stmt_num)
                                || '): '
                                ||SQLERRM,1,240);
                FND_FILE.PUT_LINE(fnd_file.log,l_err_msg);
                CONC_STATUS := FND_CONCURRENT.
                                SET_COMPLETION_STATUS('ERROR',l_err_msg);
END trf_invoice_to_wip;

/*---------------------------------------------------------------------------*
|  PUBLIC PROCEDURE                                                          |
|       generate_trf_info                                                    |
|                                                                            |
*----------------------------------------------------------------------------*/

PROCEDURE generate_trf_info (
			        p_organization_id    	 IN	 NUMBER,
				p_inventory_item_id  	 IN	 NUMBER,
				p_invoice_project_option IN	 NUMBER,
				p_project_id	     	 IN	 NUMBER,
			        p_cost_group_id	     	 IN	 NUMBER,
				p_cutoff_date	     	 IN	 DATE,
				p_user_id		 IN	 NUMBER,
				p_login_id		 IN	 NUMBER,
				p_request_id		 IN	 NUMBER,
				p_prog_id		 IN	 NUMBER,
				p_prog_app_id		 IN	 NUMBER,
				p_batch_id	     	 IN 	 NUMBER,
                                p_default_txn_date       IN      DATE,
				x_err_num	     	 OUT NOCOPY 	 NUMBER,
				x_err_code	     	 OUT NOCOPY 	 VARCHAR2,
				x_err_msg	     	 OUT NOCOPY 	 VARCHAR2
                              )
IS

l_txn_date			DATE;
l_header_id			NUMBER;
l_po_dist_id			NUMBER;
l_stmt_num                      NUMBER;
l_err_num                       NUMBER;
l_err_code                      VARCHAR2(240);
l_err_msg                       VARCHAR2(240);
l_default_cost_group_id         number;
conc_status			BOOLEAN;
cst_process_error          	EXCEPTION;

-------------------------------------------------------------------------------
-- dist_match_type	po_distribution_id	rcv_transaction_id
-- 'ITEM_TO_PO'			X			NULL
-- 'ITEM_TO_RECEIPT'		X			X
-- 'OTHER_TO_RECEIPT'		NULL			X
-------------------------------------------------------------------------------


CURSOR c_cavl_po ( p_batch_id NUMBER,p_cost_group_id NUMBER,p_inventory_item_id NUMBER)
IS

	SELECT   cavl.po_distribution_id,
		 SUM(NVL(cavl.var_amount,0)) var_amount
	FROM 	 cst_ap_variance_lines cavl
	WHERE    cavl.batch_id = p_batch_id
	AND	 cavl.cost_group_id = p_cost_group_id
	AND      cavl.inventory_item_id = p_inventory_item_id
	GROUP BY cavl.po_distribution_id;

BEGIN

        ---------------------------------------------------------------------
        -- Initializing Variables
        ---------------------------------------------------------------------
        l_err_num      := 0;
        l_err_code     := '';
        l_err_msg      := '';

        select  default_cost_group_id
          into  l_default_cost_group_id
          from  mtl_parameters
         where  organization_id = p_organization_id;
	---------------------------------------------------------------------
	-- Get all relevant records
        ---------------------------------------------------------------------
        ---------------------------------------------------------------------
        -- Invoice Lines Project:
        -- No {base_}invoice_price_variance columns in ap_invoice_distributions_all
        -- IPV is a separate distribution, therefore the query needs to have a
        -- self-join on the table to get the IPV information in addition to the
        -- ITEM/ACCRUAL information
        -- Added a filter of accounting date and posted flag on aida and join of
        -- invoice_id between aida and aida2 for performance improvement -  bug4137765
        ---------------------------------------------------------------------

/* bug 4873742 -- performance repository issues */

	l_stmt_num := 5;

	INSERT INTO cst_ap_variance_lines
        (
		variance_header_id,
		variance_line_id,
		batch_id,
		invoice_distribution_id,
		invoice_id,
		distribution_line_number,
		po_distribution_id,
		invoice_price_variance,
		base_invoice_price_variance,
		var_amount,
		project_id,
		organization_id,
		inventory_item_id,
		creation_date,
		last_update_date,
		last_updated_by,
		created_by,
		request_id,
		program_application_id,
		program_id,
		program_update_date,
		last_update_login,
		cost_group_id
	)
	(
        SELECT
		-1	 		variance_header_id,
		cst_ap_variance_lines_s.nextval variance_line_id,
		p_batch_id		batch_id,
		aida.invoice_distribution_id
					invoice_distribution_id,
		aida.invoice_id		invoice_id,
		aida.distribution_line_number
					distribution_line_number,
		aida.po_distribution_id	po_distribution_id,
		aida2.amount invoice_price_variance,
		aida2.base_amount base_invoice_price_variance,
		NVL(aida2.base_amount,0) var_amount,
		pda.project_id 	project_id,
		p_organization_id 	organization_id,
		p_inventory_item_id 	inventory_item_id,
		SYSDATE			creation_date,
		SYSDATE			last_updated_date,
		p_user_id		last_updated_by,
		p_user_id		created_by,
		p_request_id,
	        p_prog_app_id,
		p_prog_id,
		SYSDATE,
		p_login_id,
		p_cost_group_id
        FROM    ap_invoice_distributions_all aida,
                ap_invoice_distributions_all aida2,
		po_distributions pda
	WHERE	aida.posted_flag = 'Y'
	AND	aida.accounting_date <= p_cutoff_date
        AND     aida2.posted_flag = 'Y'
        AND     aida2.accounting_date <= p_cutoff_date
	AND	aida.inventory_transfer_status = 'N'
        /* Start of bug 8270017 */
        AND (
		(
			aida2.line_type_lookup_code  IN ('IPV')
			and
			(
				(aida.invoice_id = aida2.invoice_id and aida.invoice_distribution_id = aida2.related_id)
				or
				(aida.invoice_distribution_id = aida2.corrected_invoice_dist_id)
			)
		)
		OR /*Start of bug 8681379 */
		(
			 aida2.line_type_lookup_code IN ('TIPV','TERV','TRV')
			 and aida.invoice_id = aida2.invoice_id
			 and aida.invoice_distribution_id = aida2.charge_applicable_to_dist_id

		)
			/*End of bug 8681379 */
	)
        /* End of bug 8270017 */
	/*Added NONREC_TAX and other tax component 'TIPV','TERV','TRV' for bug 8681379  */
	AND	aida.line_type_lookup_code IN ('ITEM','ACCRUAL','NONREC_TAX')
	AND     aida2.line_type_lookup_code  IN ('IPV','TIPV','TERV','TRV')
	AND	pda.po_distribution_id = aida.po_distribution_id
	AND     (
		       (  p_invoice_project_option = 1
		          AND pda.project_id IS NULL
		          AND p_cost_group_id = l_default_cost_group_id)
	               OR
		       (  pda.project_id IS NOT NULL
			  AND  EXISTS
			        (SELECT  'X'
			         FROM   pjm_project_parameters ppp
				 WHERE  ppp.organization_id = p_organization_id
				 AND    ppp.costing_group_id = p_cost_group_id
				 AND	ppp.project_id = pda.project_id
			         AND    ppp.project_id =
					   decode(p_invoice_project_option,
					     1, ppp.project_id,
					     p_project_id)
			        )
		       )
	            )
	AND	aida.po_distribution_id IS NOT NULL
-- bug3673238 -------------------------------------------------------
        AND     pda.destination_organization_id = p_organization_id
        AND     pda.destination_type_code = 'INVENTORY'
	/* changes for performance improvement bug4873742 */
        AND     EXISTS (
               SELECT  'X'
               FROM    po_line_locations_all     plla,
                       po_lines_all         pla
               WHERE   pla.po_line_id = plla.po_line_id
               AND     pla.item_id = p_inventory_item_id
	       AND     nvl(plla.lcm_flag,'N') = 'N'
               AND     pda.line_location_id = plla.line_location_id)
-- end bug3673238 ---------------------------------------------------
-- J Changes ----------------------------------------------------------------
--      AND    aida.root_distribution_id IS NULL
------------------------------------------------------------------------------
        AND    aida.corrected_invoice_dist_id IS NULL --same as change made earlier
	);


        FND_FILE.PUT_LINE(FND_FILE.LOG, TO_CHAR(SQL%ROWCOUNT)
				|| ' Rows inserted into CAVL');

	l_stmt_num := 10;

	---------------------------------------------------------------------
	-- Create header with net ipv amount
	-- Even if var_amount is zero still create a record.
	---------------------------------------------------------------------

	FOR c_cavl_po_rec IN c_cavl_po(p_batch_id,p_cost_group_id,
					p_inventory_item_id) LOOP

            l_stmt_num := 15;

            -- Get transaction date for header records

            CSTPPIPV.get_upd_txn_date
                 (
                    p_po_distribution_id => c_cavl_po_rec.po_distribution_id,
                    p_default_txn_date   => p_default_txn_date,
                    p_organization_id    => p_organization_id, --BUG#5709567 - FPBUG#5109100 --Bug #13075737, Release commented p_organization_id
                    x_transaction_date   => l_txn_date,
                    x_err_num            => l_err_num,
                    x_err_code           => l_err_code,
                    x_err_msg            => l_err_msg
                 );

             IF (l_err_num <> 0) THEN
                 RAISE cst_process_error;
             END IF;

	     l_stmt_num := 20;

	     INSERT  INTO cst_ap_variance_headers
	     (
		  variance_header_id,
  		  po_distribution_id,
  		  var_amount,
                  organization_id,
                  inventory_item_id,
                  cost_group_id,
  		  transaction_date,
  		  batch_id,
  		  creation_date,
  		  created_by,
  		  last_update_date,
  		  last_updated_by,
  		  request_id,
  		  program_application_id,
  		  program_id,
  		  program_update_date,
  		  last_update_login
	  )
	  (
	  SELECT  cst_ap_variance_headers_s.nextval,	-- header_id
		  c_cavl_po_rec.po_distribution_id,	-- po_dist
		  c_cavl_po_rec.var_amount,		-- var_amount
                  p_organization_id,
                  p_inventory_item_id,
                  p_cost_group_id,
		  l_txn_date,   			-- txn_date
		  p_batch_id,
		  SYSDATE,
		  -1,
		  SYSDATE,
		  -1,
		  p_request_id,
                  p_prog_app_id,
		  p_prog_id,
		  SYSDATE,
		  p_login_id
	  FROM DUAL
	  );

	-- Debug statements -----------------------------------------------
	-- FND_FILE.PUT_LINE(FND_FILE.LOG,'cavh.podist: '
	--		||to_char(c_cavl_po_rec.po_distribution_id));
	-- FND_FILE.PUT_LINE(FND_FILE.LOG,'cavh.batch_id: '
	--	||to_char(p_batch_id));
	-- FND_FILE.PUT_LINE(FND_FILE.LOG,'cavh.var_amt: '
	-- 		||to_char(c_cavl_po_rec.var_amount));
	-- End Debug ------------------------------------------------------

	END LOOP; -- c_cavl_po_rec

	---------------------------------------------------------------------
	-- Update the ipv header id of all the detail lines
	---------------------------------------------------------------------

	l_stmt_num := 30;

	UPDATE cst_ap_variance_lines cavl
	SET    cavl.variance_header_id =
	         (SELECT  cavh.variance_header_id
		  FROM    cst_ap_variance_headers cavh
	          WHERE   cavh.batch_id = cavl.batch_id
		  AND     cavh.po_distribution_id = cavl.po_distribution_id
		  AND	  cavh.cost_group_id = cavl.cost_group_id
                 )
        WHERE cavl.batch_id = p_batch_id
 	AND  EXISTS
		( SELECT  'X'
		  FROM    cst_ap_variance_headers cavh2
	          WHERE   cavh2.batch_id = p_batch_id
		  AND     cavh2.po_distribution_id = cavl.po_distribution_id
		  AND	  cavh2.cost_group_id = cavl.cost_group_id
		);

        ---------------------------------------------------------------------
        -- Set AIDA.inventory_transfer_code = NULL i.e. transferred
        ---------------------------------------------------------------------

	l_stmt_num := 35;

	UPDATE  ap_invoice_distributions_all aida
	SET     aida.inventory_transfer_status = NULL
	WHERE	aida.inventory_transfer_status = 'N' --Perf Bug 1866130
        --   Line below is not needed because cst_ap_variance_lines won't have null IPV
        --AND     NVL(aida.base_invoice_price_variance,0) <> 0
	AND	EXISTS
		(  SELECT  'X'
		   FROM    cst_ap_variance_lines cavl
		   WHERE   cavl.batch_id = p_batch_id
		   AND	   cavl.invoice_distribution_id =
				aida.invoice_distribution_id
		   AND     cavl.cost_group_id = p_cost_group_id
		   AND	   cavl.inventory_item_id = p_inventory_item_id
                );

        FND_FILE.PUT_LINE(FND_FILE.LOG, TO_CHAR(SQL%ROWCOUNT)
				|| ' Rows marked as transferred in AIDA');


EXCEPTION

 	WHEN CST_PROCESS_ERROR THEN
                x_err_num  := l_err_num;
                x_err_code := l_err_code;
                x_err_msg  := SUBSTR(l_err_msg,1,240);

        WHEN OTHERS THEN
                ROLLBACK;
                x_err_num := SQLCODE;
                x_err_code := NULL;
                x_err_msg := SUBSTR('CSTPPIPV.generate_trf_info('
                                || to_char(l_stmt_num)
                                || '): '
                                ||SQLERRM,1,240);
END generate_trf_info;


/*---------------------------------------------------------------------------*
|  PUBLIC PROCEDURE                                                          |
|       generate_wip_info                                                    |
|       This procedure generates the invoice price variances information     |
|       for the specified po distribution and cutoff date.                   |
|                                                                            |
*----------------------------------------------------------------------------*/

PROCEDURE generate_wip_info (
	p_organization_id  	   IN	 NUMBER,
	p_inventory_item_id  	   IN	 NUMBER,
	p_project_id	     	   IN	 NUMBER,
	p_po_distribution_id  	   IN	 NUMBER,
	p_cutoff_date	     	   IN	 DATE,
	p_user_id		   IN	 NUMBER,
	p_login_id		   IN	 NUMBER,
	p_request_id		   IN	 NUMBER,
	p_prog_id		   IN	 NUMBER,
	p_prog_app_id		   IN	 NUMBER,
	p_batch_id	     	   IN 	 NUMBER,
	p_transaction_process_mode IN    NUMBER,
        p_default_txn_date         IN    DATE,
	x_err_num	     	   OUT NOCOPY 	 NUMBER,
	x_err_code	     	   OUT NOCOPY 	 VARCHAR2,
	x_err_msg	     	   OUT NOCOPY 	 VARCHAR2
)
IS

l_txn_date			DATE;
l_header_id			NUMBER;
l_var_amount                    NUMBER;
l_stmt_num                      NUMBER;
l_err_num                       NUMBER;
l_err_code                      VARCHAR2(240);
l_err_msg                       VARCHAR2(240);
conc_status			BOOLEAN;
cst_process_error          	EXCEPTION;

BEGIN

        ---------------------------------------------------------------------
        -- Initializing Variables
        ---------------------------------------------------------------------

        l_err_num      := 0;
        l_err_code     := '';
        l_err_msg      := '';

	---------------------------------------------------------------------
	-- Get all relevant records
        -- Added a filter of accounting date and posted flag on aida and join
        -- of invoice_id between aida and aida2 for performance
        -- improvement -  bug4137765
        ---------------------------------------------------------------------

	l_stmt_num := 5;

	INSERT  INTO
		cst_ap_variance_lines (
		    variance_header_id,
		    variance_line_id,
		    batch_id,
	  	    invoice_distribution_id,
		    invoice_id,
		    distribution_line_number,
		    po_distribution_id,
		    invoice_price_variance,
		    base_invoice_price_variance,
		    var_amount,
		    project_id,
		    organization_id,
		    inventory_item_id,
		    creation_date,
		    last_update_date,
		    last_updated_by,
		    created_by,
		    request_id,
		    program_application_id,
		    program_id,
		    program_update_date,
		    last_update_login,
		    cost_group_id)
	(
        SELECT  -1,
		cst_ap_variance_lines_s.nextval,
		p_batch_id,
		aida.invoice_distribution_id,
		aida.invoice_id,
		aida.distribution_line_number,
		aida.po_distribution_id,
		aida2.amount,
		aida2.base_amount,
		NVL(aida2.base_amount,0),
		p_project_id,
		p_organization_id,
		nvl(p_inventory_item_id,-1),
		SYSDATE,
		SYSDATE,
		p_user_id,
		p_user_id,
		p_request_id,
	        p_prog_app_id,
		p_prog_id,
		SYSDATE,
		p_login_id,
		NULL
        FROM    ap_invoice_distributions_all aida,
                ap_invoice_distributions_all aida2
	WHERE	aida.posted_flag = 'Y'
	AND	aida.accounting_date < p_cutoff_date
        AND     aida2.posted_flag = 'Y'
        AND     aida2.accounting_date < p_cutoff_date
	AND	aida.inventory_transfer_status = 'N'
        /* Start of bug 8270017 */
        AND
	(
		(
			aida2.line_type_lookup_code  IN ('IPV')
			and
			(
				(aida.invoice_id = aida2.invoice_id and aida.invoice_distribution_id = aida2.related_id)
				or
				(aida.invoice_distribution_id = aida2.corrected_invoice_dist_id)
			)
		)
		OR  /* Start of bug 8681379 */
		(
			aida2.line_type_lookup_code IN ('TIPV','TERV','TRV')
			and aida.invoice_id = aida2.invoice_id
			and aida.invoice_distribution_id = aida2.charge_applicable_to_dist_id
		)
		   /* End of bug 8681379 */
	)
        /* End of bug 8270017 */
	/*Added NONREC_TAX and other tax component 'TIPV','TERV','TRV' for bug 8681379  */
	AND	aida.line_type_lookup_code IN ('ITEM','ACCRUAL','NONREC_TAX')
        AND     aida2.line_type_lookup_code IN ('IPV','TIPV','TERV','TRV')
  /* Ensure that Price Correction Invoices are not picked up */
   --   AND     aida.root_distribution_id IS NULL
        AND     aida.corrected_invoice_dist_id IS NULL
	AND	aida.po_distribution_id = p_po_distribution_id);

        FND_FILE.PUT_LINE(FND_FILE.LOG, TO_CHAR(SQL%ROWCOUNT)|| ' Rows inserted into CAVL');

	l_stmt_num := 10;

	---------------------------------------------------------------------
	-- Create header with net ipv amount
	-- Even if var_amount is zero still create a record.
	---------------------------------------------------------------------

	l_stmt_num := 15;

        -- Get transaction date for header records
        CSTPPIPV.get_upd_txn_date(
            p_po_distribution_id => p_po_distribution_id,
            p_default_txn_date   => p_default_txn_date,
            p_organization_id    => p_organization_id, --BUG#5709567-FPBUG5109100 --Bug #13075737, Release commented p_organization_id
            x_transaction_date   => l_txn_date,
            x_err_num            => l_err_num,
            x_err_code           => l_err_code,
            x_err_msg            => l_err_msg
        );

        IF (l_err_num <> 0) THEN
            RAISE cst_process_error;
        END IF;

        l_stmt_num := 20;

	SELECT  SUM(NVL(cavl.var_amount,0))
	INTO    l_var_amount
        FROM    cst_ap_variance_lines cavl
        WHERE   cavl.batch_id = p_batch_id
        AND     cavl.po_distribution_id = p_po_distribution_id;

        SELECT  cst_ap_variance_headers_s.nextval
        INTO    l_header_id
        FROM    dual;


	l_stmt_num := 25;

	INSERT  INTO
                cst_ap_variance_headers(
		    variance_header_id,
  		    po_distribution_id,
  		    var_amount,
                    organization_id,
                    inventory_item_id,
                    cost_group_id,
  		    transaction_date,
  		    batch_id,
  		    creation_date,
  		    created_by,
  		    last_update_date,
  		    last_updated_by,
  		    request_id,
  		    program_application_id,
  		    program_id,
  		    program_update_date,
  		    last_update_login)
	VALUES  (   l_header_id,
		    p_po_distribution_id,
		    l_var_amount,
                    p_organization_id,
                    p_inventory_item_id,
                    NULL,
		    l_txn_date,
		    p_batch_id,
		    SYSDATE,
		    p_user_id,
		    SYSDATE,
		    p_user_id,
		    p_request_id,
                    p_prog_app_id,
		    p_prog_id,
		    SYSDATE,
		    p_login_id);

	---------------------------------------------------------------------
	-- Update the ipv header id of all the detail lines
	---------------------------------------------------------------------

	l_stmt_num := 30;

	UPDATE cst_ap_variance_lines cavl
	SET    cavl.variance_header_id = l_header_id
	WHERE  cavl.batch_id = p_batch_id
        AND    cavl.po_distribution_id = p_po_distribution_id;

        ---------------------------------------------------------------------
        -- Set AIDA.inventory_transfer_code = NULL i.e. transferred
        ---------------------------------------------------------------------

	l_stmt_num := 35;

	IF (p_transaction_process_mode = 1) THEN
	    UPDATE  ap_invoice_distributions_all aida
	    SET     aida.inventory_transfer_status = NULL
	    WHERE   aida.inventory_transfer_status = 'N' --Perf Bug 1866130
--          AND     NVL(aida.base_invoice_price_variance,0) <> 0  Not needed
	    AND     aida.posted_flag = 'Y'
	    AND	    EXISTS
		    (  SELECT  'X'
		       FROM    cst_ap_variance_lines cavl
		       WHERE   cavl.batch_id = p_batch_id
		       AND     cavl.invoice_distribution_id = aida.invoice_distribution_id
                    );

            FND_FILE.PUT_LINE(FND_FILE.LOG, TO_CHAR(SQL%ROWCOUNT)
		 		|| ' Rows marked as transferred in AIDA');
	END IF;

EXCEPTION

 	WHEN CST_PROCESS_ERROR THEN
                x_err_num  := l_err_num;
                x_err_code := l_err_code;
                x_err_msg  := SUBSTR(l_err_msg,1,240);

        WHEN OTHERS THEN
                ROLLBACK;
                x_err_num := SQLCODE;
                x_err_code := NULL;
                x_err_msg := SUBSTR('CSTPPIPV.generate_wip_info('
                                || to_char(l_stmt_num)
                                || '): '
                                ||SQLERRM,1,240);
END generate_wip_info;

------------------------------------------------------------------------
-- Procedure to determine the update transaction date.
------------------------------------------------------------------------
PROCEDURE get_upd_txn_date (
                            p_po_distribution_id        IN    NUMBER,
                            p_default_txn_date          IN    DATE,
                            p_organization_id           IN    NUMBER,  --BUG#5709567-FPBUG#5109100 --Bug #13075737, Release commented p_organization_id
                            x_transaction_date          OUT NOCOPY   DATE,
                            x_err_num                   OUT NOCOPY   NUMBER,
                            x_err_code                  OUT NOCOPY   VARCHAR2,
                            x_err_msg                   OUT NOCOPY   VARCHAR2
                            )
IS
        l_transaction_date       DATE;
        l_first_date             DATE;  --BUG#5709567-FPBUG5109100 --Bug #13075737, Release commented l_first_date and l_last_date
        l_last_date              DATE;
        l_legal_entity           NUMBER;
        l_stmt_num               NUMBER;

BEGIN
        l_stmt_num := 5;

        -- Get the most recent delivery date for the po distribution
        -- For Bug 2292853, use job release date (+1s) if deliver date
        -- equals job release date

        SELECT MAX(
                 decode(
                   trunc(rt.transaction_date),
                   trunc(wdj.date_released),
                   wdj.date_released+0.00001,
                   rt.transaction_date))
        INTO   l_transaction_date
        FROM   rcv_transactions rt,
               wip_discrete_jobs wdj
        WHERE  rt.wip_entity_id = wdj.wip_entity_id (+)
        AND    rt.transaction_type = 'DELIVER'
        AND    rt.po_distribution_id = p_po_distribution_id
        AND    rt.transaction_date = (
               SELECT MAX(rt.transaction_date)
               FROM   rcv_transactions rt
               WHERE  rt.transaction_type = 'DELIVER'
               AND    rt.po_distribution_id = p_po_distribution_id);

        l_stmt_num := 10;

        -- If there is no delivery, get the most recent receipt date
        -- Note: 'RECEIVE' rows may not have po_distribution_id.
        -- For Bug 2292853, use job release date (+1s) if deliver date
        -- equals job release date

        IF l_transaction_date is NULL THEN
            SELECT MAX(
                     decode(
                       trunc(rt.transaction_date),
                       trunc(wdj.date_released),
                       wdj.date_released+0.00001,
                       rt.transaction_date))
            INTO   l_transaction_date
            FROM   rcv_transactions rt,
                   po_distributions_all pda,
                   wip_discrete_jobs wdj
            WHERE  pda.wip_entity_id = wdj.wip_entity_id (+)
            AND    pda.po_distribution_id = p_po_distribution_id
            AND    rt.transaction_type = 'RECEIVE'
            AND    (   rt.po_distribution_id = p_po_distribution_id
                   OR  (   rt.po_line_location_id = pda.line_location_id
                       ))
            AND    rt.transaction_date = (
                   SELECT MAX(rt.transaction_date)
                   FROM   rcv_transactions rt,
                          po_distributions_all pda
                   WHERE  rt.transaction_type = 'RECEIVE'
                   AND pda.po_distribution_id = p_po_distribution_id
                   AND    (   rt.po_distribution_id = p_po_distribution_id     /* bug 4137765 - for performance improvement */
                          OR  (   rt.po_line_location_id = pda.line_location_id
                              )));
        END IF;

        -- If no receipt, use default date

        l_stmt_num := 15;

        IF l_transaction_date is NULL THEN
            l_transaction_date := p_default_txn_date;
--        END IF;

--{BUG#5709567-FPBUG#5109100:Commented out this portion --Bug #13075737, Release commented code
        ELSE

	-- Get first day of earliest open period and last day of the latest open period

/* combined l_stmt_num 20 and 25 to avoid two full table scans- bug 4873742 */

         l_stmt_num := 20;

          SELECT MIN(oap.period_start_date) ,
                 MAX(oap.schedule_close_date)+.99999
          INTO   l_first_date ,
                  l_last_date
          FROM   org_acct_periods oap
          WHERE  oap.organization_id = p_organization_id
          AND    oap.open_flag = 'Y'
          AND    oap.period_close_date is NULL;

          -- Get legal entity for timezone conversion.
          l_stmt_num := 30;

	  /* select legal entity from HR_ORGANIZATION_INFORMATION instead of cst_organization_definitions
for performance improvement */

        SELECT org_information2
        INTO   l_legal_entity
        FROM   HR_ORGANIZATION_INFORMATION
	where	ORG_INFORMATION_CONTEXT = 'Accounting Information'
	and organization_id = p_organization_id;

          -- Need to convert start and end dates to server time.
          l_stmt_num := 35;
          l_first_date := INV_LE_TIMEZONE_PUB.GET_SERVER_DAY_TIME_FOR_LE(
                            l_first_date,
                            l_legal_entity);

          l_stmt_num := 40;
          l_last_date := INV_LE_TIMEZONE_PUB.GET_SERVER_DAY_TIME_FOR_LE(
                            l_last_date,
                            l_legal_entity);

          l_stmt_num := 45;

          IF l_transaction_date < l_first_date THEN
            l_transaction_date := l_first_date;
          ELSIF l_transaction_date > l_last_date THEN
            l_transaction_date := l_last_date;
          END IF;
        END IF;
--} Bug #13075737, Release commented code
        x_transaction_date := l_transaction_date;

EXCEPTION

        WHEN OTHERS THEN
                ROLLBACK;
                x_err_num := SQLCODE;
                x_err_code := NULL;
                x_err_msg := SUBSTR('CSTPPIPV.get_upd_txn_date('
                                || to_char(l_stmt_num)
                                || '): '
                                ||SQLERRM,1,240);


END get_upd_txn_date;

-------------------------------------------------------------------------------
-- Procedure to return the default transaction date for cost updates
-- Determine the default transaction date of the cost update trans.
--         If sysdate < first day of the earliest open period
--                     ==> use first day of the earliest open period
--         If sysdate > last day of the latest open period
--                     ==> use last day of the latest open period
--         Otherwise, use sysdate as default transaction date
-------------------------------------------------------------------------------
PROCEDURE get_default_date (
                            p_organization_id  	IN    NUMBER,
			    x_default_date	OUT NOCOPY   DATE,
                            x_err_num           OUT NOCOPY   NUMBER,
                            x_err_code          OUT NOCOPY   VARCHAR2,
                            x_err_msg           OUT NOCOPY   VARCHAR2
                           )
IS
        l_first_date          DATE;
        l_last_date           DATE;
        l_default_txn_date    DATE;
        l_stmt_num            NUMBER;
        l_legal_entity        NUMBER;

BEGIN

	-- Get first day of earliest open period and last day of the latest open period

/* combined l_stmt_num 5 and 10 to avoid two full table scans- bug 4873742 */

         l_stmt_num := 5;

          SELECT MIN(oap.period_start_date) ,
                 MAX(oap.schedule_close_date)+(1-1/86400)   -- +.99999 BUG#5709567-FPBIG#5109100
	--Bug #13075737, Release commented code and modify to +(1-1/86400)
          INTO   l_first_date ,
                  l_last_date
          FROM   org_acct_periods oap
          WHERE  oap.organization_id = p_organization_id
          AND    oap.open_flag = 'Y'
          AND    oap.period_close_date is NULL;

        -- Get legal entity for timezone conversion.
        l_stmt_num := 15;

/* select legal entity from HR_ORGANIZATION_INFORMATION instead of cst_organization_definitions
for performance improvement */

       SELECT org_information2
        INTO   l_legal_entity
        FROM   HR_ORGANIZATION_INFORMATION
	where	ORG_INFORMATION_CONTEXT = 'Accounting Information'
	and organization_id = p_organization_id;

        -- Need to convert start and end dates to server time.
        l_stmt_num := 18;
        l_first_date := INV_LE_TIMEZONE_PUB.GET_SERVER_DAY_TIME_FOR_LE(
                          l_first_date,
                          l_legal_entity);

        l_stmt_num := 20;
        l_last_date := INV_LE_TIMEZONE_PUB.GET_SERVER_DAY_TIME_FOR_LE(
                          l_last_date,
                          l_legal_entity);

	l_stmt_num := 25;

        IF SYSDATE < l_first_date THEN
              l_default_txn_date := l_first_date;
        ELSIF
              SYSDATE > l_last_date THEN
              l_default_txn_date := l_last_date;
        ELSE
              l_default_txn_date := SYSDATE;
        END IF;

	x_default_date := l_default_txn_date;


EXCEPTION

        WHEN OTHERS THEN
                ROLLBACK;
                x_err_num := SQLCODE;
                x_err_code := NULL;
                x_err_msg := SUBSTR('CSTPPIPV.get_default_date('
                                || to_char(l_stmt_num)
                                || '): '
                                ||SQLERRM,1,240);

END get_default_date;

END CSTPPIPV;

/
