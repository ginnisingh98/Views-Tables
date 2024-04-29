--------------------------------------------------------
--  DDL for Package Body PA_FAXFACE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_FAXFACE" AS
/* $Header: PAFAXB.pls 120.49.12010000.15 2010/01/04 05:08:25 rrambati ship $ */

     TYPE t_rec is record (group_level_task_id			     NUMBER(15),
                           asset_category_id			     NUMBER(15),
                           system_linkage_function                   VARCHAR2(3),
                           document_header_id			     NUMBER(15),
                           document_line_number			     NUMBER(15),
                           document_distribution_id                  NUMBER(15),
                           expenditure_category                      VARCHAR2(30),
                           expenditure_type                          VARCHAR2(30),
                           non_labor_resource                        VARCHAR2(20),
                           cip_ccid			             NUMBER(15),
                           cip_cost			             NUMBER(15),
                           expenditure_item_id			     NUMBER(15),
                           line_num			             NUMBER(15),
                           cip_grouping_method_code                  VARCHAR2(30),
                           grouping_method                           VARCHAR2(2000),
                           override_asset_assignment_flag            VARCHAR2(1),
                           vendor_invoice_grouping_code              VARCHAR2(1),
                           project_id			             NUMBER(15),
                           task_id			             NUMBER(15),
	                   top_task			             NUMBER(15),
                           expenditure_id			     NUMBER(15),
                           organization_id			     NUMBER(15),
                           ATTRIBUTE1                                VARCHAR2(150),
                           ATTRIBUTE2                                VARCHAR2(150),
                           ATTRIBUTE3                                VARCHAR2(150),
                           ATTRIBUTE4                                VARCHAR2(150),
                           ATTRIBUTE5                                VARCHAR2(150),
                           ATTRIBUTE6                                VARCHAR2(150),
                           ATTRIBUTE7                                VARCHAR2(150),
                           ATTRIBUTE8                                VARCHAR2(150),
                           ATTRIBUTE9                                VARCHAR2(150),
                           ATTRIBUTE10                               VARCHAR2(150),
                           ATTRIBUTE_CATEGORY                        VARCHAR2(30),
                           capital_event_id number);

  TYPE OpenCursorType is REF CURSOR;

  l_mrc_flag        VARCHAR2(1) := paapimp_pkg.get_mrc_flag;

FUNCTION check_required_segment (structnum  number) RETURN varchar2 IS
        fftype          fnd_flex_key_api.flexfield_type;
        numstruct       number;
        liststruct      fnd_flex_key_api.structure_list;
        thestruct       fnd_flex_key_api.structure_type;
        numsegs         number;
        listsegs        fnd_flex_key_api.segment_list;
        segtype         fnd_flex_key_api.segment_type;
        segname         fnd_id_flex_segments.segment_name%TYPE;
BEGIN
fnd_flex_key_api.set_session_mode('seed_data');
fftype := fnd_flex_key_api.find_flexfield(appl_short_name =>'OFA',
                                          flex_code =>'KEY#');
thestruct := fnd_flex_key_api.find_structure(fftype,structnum);
fnd_flex_key_api.get_segments(fftype,thestruct,TRUE,numsegs,listsegs);
for i in 1 .. numsegs loop
        segtype := fnd_flex_key_api.find_segment(fftype,thestruct,listsegs(i));
        if (segtype.required_flag = 'Y' and segtype.enabled_flag = 'Y') then
                return('Y');
        end if;
end loop;
return('N');
END;


  PROCEDURE set_in_service_thru_date(x_passed_thru_date IN DATE) IS
  BEGIN
	x_in_service_thru_date := x_passed_thru_date;
  END set_in_service_thru_date;

  FUNCTION get_in_service_thru_date RETURN DATE is
  BEGIN
	return(x_in_service_thru_date);
  END get_in_service_thru_date;

   -- Initialize function
   FUNCTION initialize RETURN NUMBER IS
      x_err_code NUMBER:=0;
   BEGIN

     RETURN 0;
   EXCEPTION
    WHEN  OTHERS  THEN
      x_err_code := SQLCODE;
      RETURN x_err_code;
   END initialize;

   FUNCTION get_group_level_task_id
                ( x_task_id    IN NUMBER,
                   x_top_task_id IN NUMBER,
                  x_project_id IN NUMBER)
   RETURN NUMBER
   IS
     dummy      VARCHAR2(10);
     group_level_task_id NUMBER;
      cursor c_asset_on_task  is
                select task_id
                from   pa_project_asset_assignments
                where  project_id = x_project_id
                and   task_id = x_task_id ;
      cursor c_asset_on_top_task  is
                select task_id
                from   pa_project_asset_assignments
                where  project_id = x_project_id
                  and   task_id = x_top_task_id ;
     cursor c_asset_on_project  is
               select task_id
                from   pa_project_asset_assignments
                where  project_id = x_project_id ;
    BEGIN
             OPEN c_asset_on_task ;
             FETCH c_asset_on_task into group_level_task_id ;
               IF c_asset_on_task%NOTFOUND THEN
                  OPEN c_asset_on_top_task ;
                  FETCH c_asset_on_top_task into group_level_task_id ;
                    IF c_asset_on_top_task%NOTFOUND THEN
                     OPEN c_asset_on_project ;
                       FETCH c_asset_on_project into group_level_task_id ;
                       IF c_asset_on_project%NOTFOUND THEN
                         group_level_task_id := NULL ;
                       END IF ;
                       CLOSE c_asset_on_project ;
                    END IF ;
                  CLOSE c_asset_on_top_task ;
                END IF ;
             CLOSE c_asset_on_task ;
             RETURN group_level_task_id ;
          EXCEPTION
            WHEN OTHERS THEN
               RAISE;
   END get_group_level_task_id;

   /* R12 changes: Parameters will have following values :
      For AP : x_doc_header_id -> invoice_id
               x_doc_line_num  -> invoice_line_num
	       x_doc_dist_id   -> invoice_distribution_id

      For PO: x_doc_header_id  -> po_header_id
              x_doc_line_num   -> po_distribution_id
	      x_doc_dist_id    -> rcv_transaction_id
   */

   FUNCTION get_asset_category_id
		( x_doc_header_id               IN NUMBER,
		  x_doc_line_num                IN NUMBER,
		  x_doc_dist_id                 IN NUMBER,
                  x_transaction_source          IN VARCHAR2)
   RETURN NUMBER
   IS
     asset_category_id NUMBER;
    -- Fix for bug : 4878878
    -- PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');
   BEGIN

   --Bug 3250512: With receipt accruals the cdl.system_reference2 and cdl.system_reference3 corresponds to
   --po_header_id and po_distribution_id. Hence need to add another SQL to fetch asset category for
   --receipt accrual items.
   IF G_debug_mode  = 'Y' THEN
      pa_debug.debug('Inside get_asset_category_id, x_doc_header_id = ' || x_doc_header_id ||
                                               ' x_doc_line_num = '|| x_doc_line_num ||
                                               ' x_doc_dist_id = '|| x_doc_dist_id ||
                                               ' x_transaction_source = ' || x_transaction_source);
   END IF;
  -- Added 'CSE_IPV_ADJUSTMENT_DEPR','CSE_IPV_ADJUSTMENT' for bug: 5036815
   If x_transaction_source in ('AP INVOICE', 'AP EXPENSE', 'AP NRTAX', 'AP DISCOUNTS', 'AP VARIANCE', 'AP ERV', /* Bug 5284323 */
                               'CSE_IPV_ADJUSTMENT_DEPR','CSE_IPV_ADJUSTMENT') Then

     SELECT
	   mtlsi.asset_category_id
     INTO
	   asset_category_id
     FROM
	   ap_invoice_distributions_all apid,
	   po_distributions pod,
	   po_lines pol,
	   financials_system_parameters fsp,
	   mtl_system_items mtlsi
     WHERE
	   apid.invoice_id = x_doc_header_id
     AND   apid.invoice_distribution_id = x_doc_dist_id
     AND   apid.po_distribution_id = pod.po_distribution_id
     AND   pod.po_line_id = pol.po_line_id
     AND   pol.item_id = mtlsi.inventory_item_id
     AND   mtlsi.organization_id = fsp.inventory_organization_id;
   -- Added 'CSE_PO_RECEIPT_DEPR','CSE_PO_RECEIPT' for bug 5036815
   ElsIf x_transaction_source in ('PO RECEIPT', 'PO RECEIPT NRTAX',
                                  'PO RECEIPT NRTAX PRICE ADJ', 'PO RECEIPT PRICE ADJ','CSE_PO_RECEIPT_DEPR','CSE_PO_RECEIPT') Then

     SELECT
           mtlsi.asset_category_id
     INTO
           asset_category_id
     FROM
           po_distributions pod,
           po_lines pol,
           financials_system_parameters fsp,
           mtl_system_items mtlsi
     WHERE
           pod.po_header_id = x_doc_header_id
     AND   pod.po_distribution_id = x_doc_line_num
     AND   pod.po_line_id = pol.po_line_id
     AND   pol.item_id = mtlsi.inventory_item_id
     AND   mtlsi.organization_id = fsp.inventory_organization_id;

   End If;

   IF G_debug_mode  = 'Y' THEN
      pa_debug.debug('asset_category_id = ' || asset_category_id);
   END IF;

     RETURN asset_category_id;

     EXCEPTION
       WHEN NO_DATA_FOUND THEN
	  RETURN NULL;
       WHEN OTHERS THEN
	  RAISE;
   END get_asset_category_id;

   PROCEDURE  get_asset_id
                ( x_project_id               IN NUMBER,
                  x_system_linkage_function  IN VARCHAR2,
                  x_grp_level_task_id        IN NUMBER,
                  x_asset_category_id        IN NUMBER,
                  x_line_type                IN VARCHAR2,
                  x_capital_event_id         IN NUMBER,
                  x_asset_id                 OUT NOCOPY NUMBER,
                  x_num_asset_assigned       OUT NOCOPY NUMBER)
   IS
     CURSOR selassets IS
     SELECT
	  paa.project_asset_id,
	  ppa.asset_category_id
     FROM
	  pa_project_asset_assignments paa,
	  pa_project_assets ppa
     WHERE
	  paa.project_id = x_project_id
     AND  ppa.project_asset_type(+) = DECODE(x_line_type,'C','AS-BUILT','RETIREMENT_ADJUSTMENT')
     AND  ppa.capital_event_id(+) IS NOT NULL
     AND  ppa.capital_event_id(+) = x_capital_event_id
     AND  ppa.capital_hold_flag(+) = 'N'
     AND  ppa.project_asset_id(+) = paa.project_asset_id
     AND  paa.task_id = x_grp_level_task_id;

     assetrec              selassets%ROWTYPE;
     num_asset_assignments NUMBER;
     asset_id_matched      NUMBER;
     num_of_asset_matched  NUMBER;  --- Number of assets with matched categ.
     l_asset_id   	   NUMBER;

   BEGIN

     num_asset_assignments := 0;
     num_of_asset_matched  := 0;

     FOR assetrec IN selassets LOOP

       num_asset_assignments := num_asset_assignments + 1;
       x_num_asset_assigned:=num_asset_assignments;
       l_asset_id := assetrec.project_asset_id;

       IF x_asset_category_id IS NULL AND num_asset_assignments > 1 THEN
          x_asset_id:=0 ;
          RETURN  ;
       END IF;

       IF ( x_asset_category_id IS NOT NULL AND x_system_linkage_function = 'VI') THEN

	  -- try to match the asset category

	  IF ( x_asset_category_id = assetrec.asset_category_id ) THEN

	      num_of_asset_matched := num_of_asset_matched + 1;
	      asset_id_matched := assetrec.project_asset_id;

         IF num_of_asset_matched > 1 THEN
             x_asset_id:=0;
            RETURN  ;
         END IF;

	  END IF;
       END IF;
     END LOOP;

     IF ( num_of_asset_matched = 1 ) THEN
        x_asset_id:=asset_id_matched;
       RETURN ;
     END IF;

     IF ( num_asset_assignments = 1 ) THEN
       x_asset_id:= l_asset_id;
       RETURN ;

     END IF;

    x_asset_id:=0;

     EXCEPTION
       WHEN OTHERS THEN
	  RAISE;
   END get_asset_id;

   PROCEDURE get_asset_attributes
		( x_project_asset_id                IN  NUMBER,
		  x_depreciation_expense_ccid    IN OUT NOCOPY NUMBER,
		  x_err_stage        IN OUT NOCOPY VARCHAR2,
		  x_err_code         IN OUT NOCOPY NUMBER)
   IS
   BEGIN

     x_err_code  := 0;
     x_err_stage := 'Getting asset attributes';

     SELECT
	   depreciation_expense_ccid
     INTO
	   x_depreciation_expense_ccid
     FROM
	   pa_project_assets
     WHERE
	   project_asset_id = x_project_asset_id;

     EXCEPTION
       WHEN NO_DATA_FOUND THEN
	  NULL;
       WHEN OTHERS THEN
	  x_err_code := SQLCODE;
	  RAISE;
   END get_asset_attributes;

   -- This procedure updates the REVERSE_FLAG column for the given
   -- Project Id for the assets with reverse_flag = 'Y'

   PROCEDURE find_assets_to_be_reversed
                 (x_project_id                IN         NUMBER,
		  x_asset_found               IN OUT     NOCOPY BOOLEAN,
                  x_capital_event_id          IN         NUMBER,
                  x_err_stage                 IN OUT     NOCOPY VARCHAR2,
                  x_err_code                  IN OUT     NOCOPY NUMBER)
   IS
   BEGIN

     x_err_code     := 0;
     x_err_stage    := 'Finding the assets to be reversed';
     x_asset_found  := TRUE;

       UPDATE
	   pa_project_assets ppa
       SET
	   ppa.reverse_flag = 'S'
       WHERE
	   ppa.project_id = x_project_id
       AND ppa.capital_event_id = NVL(x_capital_event_id, ppa.capital_event_id)
       AND ppa.reverse_flag = 'Y';

       IF ( SQL%ROWCOUNT = 0 ) THEN
	  x_asset_found := FALSE;
       END IF;

     EXCEPTION
       WHEN OTHERS THEN
	 x_err_code := SQLCODE;
	 RAISE;
   END find_assets_to_be_reversed;

   -- This procedure checks for the given detail_id
   -- that all the lines are to be reversed are in the
   -- current batch or not


   PROCEDURE check_asset_to_be_reversed
                 (x_proj_asset_line_detail_id IN         NUMBER,
		  x_asset_found               IN OUT     NOCOPY BOOLEAN,
                  x_err_stage                 IN OUT     NOCOPY VARCHAR2,
                  x_err_code                  IN OUT     NOCOPY NUMBER)
   IS
     dummy     VARCHAR2(10);
   BEGIN

     x_err_code     := 0;
     x_err_stage    := 'Checking the assets to be reversed';
     x_asset_found  := TRUE;

        SELECT
	   'Exist'
        INTO
	   dummy
	FROM sys.dual
	WHERE exists
	(SELECT
	    'Yes'
        FROM
	    pa_project_asset_lines pal
        WHERE
	    pal.project_asset_line_detail_id = x_proj_asset_line_detail_id
	AND NOT EXISTS
	    ( SELECT
		     'This Line was adjusted before'
	      FROM
		   pa_project_asset_lines ppal
	      WHERE
		   ppal.rev_proj_asset_line_id = pal.project_asset_line_id
	     )
	AND pal.project_asset_id NOT IN
	    ( SELECT
		   project_asset_id
	      FROM
		   pa_project_assets pas
	      WHERE
	           pas.reverse_flag = 'S'
           AND pas.project_id = pal.project_id
	     )
	UNION
	SELECT
	    'Yes'
        FROM
	    pa_project_asset_lines pal
        WHERE
	    pal.project_asset_line_detail_id = x_proj_asset_line_detail_id
	AND pal.transfer_status_code <> 'T'
	AND pal.rev_proj_asset_line_id IS NULL
	AND pal.project_asset_id IN
	    ( SELECT
		   project_asset_id
	      FROM
		   pa_project_assets pas
	      WHERE
	          pas.reverse_flag = 'S'
           AND pas.project_id = pal.project_id
	     )
	);

     EXCEPTION
       WHEN NO_DATA_FOUND THEN
	  x_asset_found := FALSE;
       WHEN OTHERS THEN
	 x_err_code := SQLCODE;
	 RAISE;
   END check_asset_to_be_reversed;

   PROCEDURE check_proj_asset_lines
                 (x_proj_asset_line_detail_id IN         NUMBER,
		  x_line_found                IN OUT     NOCOPY BOOLEAN,
                  x_err_stage                 IN OUT     NOCOPY VARCHAR2,
                  x_err_code                  IN OUT     NOCOPY NUMBER)
   IS
     dummy     VARCHAR2(10);
   BEGIN

     x_err_code     := 0;
     x_err_stage    := 'Checking the asset lines to be regenerated';
     x_line_found   := TRUE;

        SELECT
	   'Exist'
        INTO
	   dummy
	FROM sys.dual
	WHERE exists
	(SELECT
	    'Yes'
        FROM
	    pa_project_asset_lines pal
        WHERE
	    pal.project_asset_line_detail_id = x_proj_asset_line_detail_id
	AND pal.transfer_status_code <> 'P'
	);

     EXCEPTION
       WHEN NO_DATA_FOUND THEN
	  x_line_found := FALSE;
       WHEN OTHERS THEN
	 x_err_code := SQLCODE;
	 RAISE;
   END check_proj_asset_lines;

   -- This procedure updates the pa_project_asset_line_details
   -- when all the project asset lines for a detail_line_id
   -- are reversed then the detail itself are marked as reversed

   PROCEDURE update_line_details
                 (x_proj_asset_line_detail_id IN         NUMBER,
                  x_err_stage                 IN OUT     NOCOPY VARCHAR2,
                  x_err_code                  IN OUT     NOCOPY NUMBER)
   IS
   BEGIN

     x_err_code     := 0;
     x_err_stage    := 'Updating the detail lines';

       UPDATE
	   pa_project_asset_line_details
       SET
	   reversed_flag = 'Y',
	   last_update_date = sysdate,
	   last_updated_by = x_last_updated_by,
	   last_update_login = x_last_update_login,
	   request_id = x_request_id,
	   program_application_id = x_program_application_id,
	   program_id = x_program_id,
	   program_update_date = sysdate
       WHERE
	   project_asset_line_detail_id =
		   x_proj_asset_line_detail_id;

     EXCEPTION
       WHEN OTHERS THEN
	 x_err_code := SQLCODE;
	 RAISE;
   END update_line_details;

   PROCEDURE update_expenditure_items
                 (x_proj_asset_line_detail_id IN         NUMBER,
		  x_revenue_distributed_flag  IN         VARCHAR2,
                  x_err_stage                 IN OUT     NOCOPY VARCHAR2,
                  x_err_code                  IN OUT     NOCOPY NUMBER)
   IS
   BEGIN

     x_err_code     := 0;
     x_err_stage    := 'Updating the expenditure_items';

       UPDATE
	   pa_expenditure_items_all pei
       SET
	   revenue_distributed_flag = x_revenue_distributed_flag,
	   last_update_date = sysdate,
	   last_updated_by = x_last_updated_by,
	   last_update_login = x_last_update_login,
	   request_id = x_request_id,
	   program_application_id = x_program_application_id,
	   program_id = x_program_id,
	   program_update_date = sysdate
       WHERE
	   pei.expenditure_item_id IN
	   ( SELECT
		  expenditure_item_id
	     FROM
		  pa_project_asset_line_details pald
	     WHERE
	          project_asset_line_detail_id =
		      x_proj_asset_line_detail_id
	     GROUP BY expenditure_item_id
	    );

     EXCEPTION
       WHEN OTHERS THEN
	 x_err_code := SQLCODE;
	 RAISE;
   END update_expenditure_items;

   -- procedure to update asset costs

   PROCEDURE update_asset_cost
                 (x_project_asset_id          IN         NUMBER,
		  x_grouped_cip_cost          IN         NUMBER,
		  x_capitalized_cost          IN         NUMBER,
                  x_err_stage                 IN OUT     NOCOPY VARCHAR2,
                  x_err_code                  IN OUT     NOCOPY NUMBER)
   IS
   BEGIN

     x_err_code     := 0;
     x_err_stage    := 'Updating the asset cost';

     -- Check if the project_asset_id is Valid

     IF ( x_project_asset_id > 0 ) THEN

       UPDATE
	   pa_project_assets ppa
       SET
	   ppa.grouped_cip_cost = NVL(ppa.grouped_cip_cost,0) +
					x_grouped_cip_cost,
	   ppa.capitalized_cost = NVL(ppa.capitalized_cost,0) +
					x_capitalized_cost
       WHERE
	   ppa.project_asset_id = x_project_asset_id;

     END IF;

     EXCEPTION
       WHEN OTHERS THEN
	 x_err_code := SQLCODE;
	 RAISE;
   END update_asset_cost;

   -- procedure to create project_asset_lines

   PROCEDURE create_project_asset_lines
              (x_description                   IN VARCHAR2,
               x_project_asset_id              IN NUMBER,
               x_project_id                    IN NUMBER,
               x_task_id                       IN NUMBER,
               x_cip_ccid                      IN NUMBER,
               x_asset_cost_ccid               IN NUMBER,
               x_original_asset_cost           IN NUMBER,
               x_current_asset_cost            IN NUMBER,
               x_project_asset_line_detail_id  IN NUMBER,
               x_gl_date                       IN DATE,
               x_transfer_status_code          IN VARCHAR2,
	       x_transfer_rejection_reason     IN VARCHAR2,
               x_amortize_flag                 IN VARCHAR2,
               x_asset_category_id             IN NUMBER,
               x_rev_proj_asset_line_id        IN NUMBER,
	       x_rev_from_proj_asset_line_id   IN NUMBER,
               x_invoice_number                IN VARCHAR2,
               x_vendor_number                 IN VARCHAR2,
               x_po_vendor_id                  IN NUMBER,
               x_po_number                     IN VARCHAR2,
               x_invoice_date                  IN DATE,
               x_invoice_created_by            IN NUMBER,
               x_invoice_updated_by            IN NUMBER,
               x_invoice_id                    IN NUMBER,
               x_payables_batch_name           IN VARCHAR2,
               x_ap_dist_line_number           IN Number,
               x_invoice_distribution_id       IN Number, -- R12 new
               x_orig_asset_id                 IN Number,
               x_line_type                     IN VARCHAR2,
               x_capital_event_id              IN NUMBER,
               x_retirement_cost_type          IN VARCHAR2,
               x_err_stage                  IN OUT NOCOPY VARCHAR2,
               x_err_code                   IN OUT NOCOPY NUMBER)
   IS
     project_asset_line_id  NUMBER;
	L_org_id NUMBER:=  PA_MOAC_UTILS.get_current_org_id ;
   BEGIN
     x_err_code     := 0;
     x_err_stage    := 'Create Project Asset Line';

     SELECT pa_project_asset_lines_s.nextval
     INTO   project_asset_line_id
     FROM sys.dual;

     INSERT INTO pa_project_asset_lines(
               project_asset_line_id,
               description,
               project_asset_id,
               project_id,
               task_id,
               cip_ccid,
               asset_cost_ccid,
               original_asset_cost,
               current_asset_cost,
               project_asset_line_detail_id,
               gl_date,
               transfer_status_code,
	          transfer_rejection_reason,
               amortize_flag,
               asset_category_id,
               last_update_date,
               last_updated_by,
               created_by,
               creation_date,
	       last_update_login,
               request_id,
               program_application_id,
               program_id,
               rev_proj_asset_line_id,
	       rev_from_proj_asset_line_id,
               invoice_number,
               vendor_number,
               po_vendor_id,
               po_number,
               invoice_date,
               invoice_created_by,
               invoice_updated_by,
               invoice_id,
               payables_batch_name,
               ap_distribution_line_number,
               invoice_distribution_id, -- R12 new
               original_asset_id
               ,line_type
               ,capital_event_id
               ,retirement_cost_type
	       ,org_id
     )
     SELECT
               project_asset_line_id,
               UPPER(x_description),
               x_project_asset_id,
               x_project_id,
               x_task_id,
               x_cip_ccid,
               x_asset_cost_ccid,
               x_original_asset_cost,
               x_current_asset_cost,
               x_project_asset_line_detail_id,
               x_gl_date,
               x_transfer_status_code,
	       x_transfer_rejection_reason,
               x_amortize_flag,
               x_asset_category_id,
               sysdate,
               x_last_updated_by,
               x_created_by,
               sysdate,
	       x_last_update_login,
               x_request_id,
               x_program_application_id,
               x_program_id,
               x_rev_proj_asset_line_id,
	       x_rev_from_proj_asset_line_id,
               x_invoice_number,
               x_vendor_number,
               x_po_vendor_id,
               x_po_number,
               x_invoice_date,
               x_invoice_created_by,
               x_invoice_updated_by,
               x_invoice_id,
               x_payables_batch_name,
               x_ap_dist_line_number,
               x_invoice_distribution_id, -- R12 new
               x_orig_asset_id
               ,x_line_type
               ,x_capital_event_id
               ,x_retirement_cost_type
	       ,L_org_id
     FROM
	       sys.dual;

     IF l_mrc_flag = 'Y' THEN
	   create_alc_proj_asset_lines	(project_asset_line_id,
					 x_project_asset_line_detail_id,
					 x_rev_proj_asset_line_id,
					 x_original_asset_cost,
					 x_current_asset_cost,
					 x_err_stage,
					 x_err_code);

     END IF;

     EXCEPTION
       WHEN OTHERS THEN
	 x_err_code := SQLCODE;
	 RAISE;
   END create_project_asset_lines;

   PROCEDURE reverse_asset_lines
                 (x_project_id                IN         NUMBER,
                  x_capital_event_id          IN         NUMBER,
                  x_err_stage                 IN OUT     NOCOPY VARCHAR2,
                  x_err_code                  IN OUT     NOCOPY NUMBER)
   IS

	-- procedure for getting the project_asset_line_detail_id
	-- for all the project asset line which need to be reversed

	CURSOR seldetailids IS
        SELECT
            pal.project_asset_line_detail_id
        FROM
	    pa_project_asset_lines pal
        WHERE
	    pal.project_id+0 = x_project_id
        AND pal.capital_event_id = NVL(x_capital_event_id, pal.capital_event_id)
	AND pal.project_asset_id IN
	    ( SELECT
		   project_asset_id
	      FROM
		   pa_project_assets pas
	      WHERE
	           pas.reverse_flag = 'S'
           AND  pas.project_id = pal.project_id
	     )
	AND pal.transfer_status_code||'' = 'T'
   AND pal.rev_proj_asset_line_id is NULL
	AND NOT EXISTS
	    ( SELECT
		     'This Line was adjusted before'
	      FROM
		   pa_project_asset_lines ppal
	      WHERE
		   ppal.rev_proj_asset_line_id = pal.project_asset_line_id
	     )
	GROUP by project_asset_line_detail_id;

	-- Cursor for selecting all the project_asset_lines
	-- which are candidates for reversal for the given
	-- project_asset_line_detail_id for all the assets

	CURSOR selprojassetlines(proj_asset_line_detail_id NUMBER) IS
        SELECT
            project_asset_line_id,
            description,
            project_asset_id,
            project_id,
            task_id,
            cip_ccid,
            asset_cost_ccid,
            original_asset_cost,
            current_asset_cost,
            project_asset_line_detail_id,
            gl_date,
            transfer_status_code,
            amortize_flag,
            asset_category_id,
            request_id,
	    rev_from_proj_asset_line_id,
            invoice_number,
            vendor_number,
            po_vendor_id,
            po_number,
            invoice_date,
            invoice_created_by,
            invoice_updated_by,
            invoice_id,
            payables_batch_name,
            ap_distribution_line_number,
            invoice_distribution_id, -- R12 new
            original_asset_id
            ,line_type
            ,capital_event_id
            ,retirement_cost_type
        FROM
	    pa_project_asset_lines pal
        WHERE
	    pal.project_id+0 = x_project_id
            AND pal.rev_proj_asset_line_id is NULL /*  Added this for the bug 3989536 */
        AND pal.capital_event_id = NVL(x_capital_event_id, pal.capital_event_id)
	AND pal.project_asset_line_detail_id = proj_asset_line_detail_id
      	AND pal.transfer_status_code||'' = 'T'
	AND pal.project_asset_id IN
	    ( SELECT
		   project_asset_id
	      FROM
		   pa_project_assets pas
	      WHERE
	           pas.reverse_flag = 'S'
           AND  pas.project_id = pal.project_id
	     )
	AND NOT EXISTS
	    ( SELECT
		     'This Line was adjusted before'
	      FROM
		   pa_project_asset_lines ppal
	      WHERE
		   ppal.rev_proj_asset_line_id = pal.project_asset_line_id
	     );

     assetlinerec              selprojassetlines%ROWTYPE;
     detailidrec               seldetailids%ROWTYPE;
     asset_found               BOOLEAN;
     project_asset_line_id     NUMBER;
     cdl_fully_reversible      BOOLEAN; -- This flag will indicate if the
					-- project asset line is fully reversed
     x_translated_reversal     VARCHAR2(80);
    -- Fix for bug : 4878878
    -- PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');
   BEGIN

	x_err_code   := 0;
	x_err_stage  := 'Reversing the Asset Lines';

	find_assets_to_be_reversed
		( x_project_id,
		  asset_found,
                  x_capital_event_id,
                  x_err_stage,
		  x_err_code);

	IF ( NOT asset_found ) THEN
	     IF G_debug_mode  = 'Y' THEN
	        pa_debug.debug('reverse_asset_lines: ' || '.  No assets to be reversed');
	     END IF;
	     RETURN;
	END IF;

	BEGIN
	  SELECT meaning
	  INTO x_translated_reversal
	  FROM pa_lookups
	  WHERE lookup_type = 'TRANSLATION' and
	      lookup_code = 'REVERSAL';
	EXCEPTION
          WHEN NO_DATA_FOUND THEN
            x_translated_reversal := 'REVERSAL:';
          WHEN OTHERS THEN
           x_err_code := SQLCODE;
           RAISE;
	END;


	FOR detailidrec IN seldetailids LOOP

	   cdl_fully_reversible := TRUE;

	   IF G_debug_mode  = 'Y' THEN
	      pa_debug.debug('reverse_asset_lines: ' || '.  Detail Line Id=' ||
			to_char(detailidrec.project_asset_line_detail_id));
	   END IF;
	   -- Check if the project_asset_id on the line is same as one
	   -- of the asset being reversed in this batch

           check_asset_to_be_reversed
                     (detailidrec.project_asset_line_detail_id,
		      asset_found,
                      x_err_stage,
                      x_err_code);

	   IF ( asset_found ) THEN
		-- one of the project asset line has been assigned to an
		-- asset not being reversed in the current process

	        IF G_debug_mode  = 'Y' THEN
	           pa_debug.debug('reverse_asset_lines: ' || '.  This line is not fully reversible');
	        END IF;
		cdl_fully_reversible := FALSE;

	   END IF;

	   FOR assetlinerec IN
	       selprojassetlines(detailidrec.project_asset_line_detail_id) LOOP

	       IF G_debug_mode  = 'Y' THEN
	          pa_debug.debug('reverse_asset_lines: ' || '.  Line ID=' ||
			  to_char(assetlinerec.project_asset_line_id));
	       END IF;


	     -- create a project_asset_line which will reverse the current
	     -- line with a -ve amount and transfer_status_code for pending
	     -- also populate the rev_project_asset_line_id as the
	     -- project_asset_line_id

	     -- also track the amount being currently reversed. Basically
	     -- we are creating a -ve grouped cost for this asset

             create_project_asset_lines
                 (x_translated_reversal||' '||assetlinerec.description,
                  assetlinerec.project_asset_id,
                  assetlinerec.project_id,
                  assetlinerec.task_id,
                  assetlinerec.cip_ccid,
                  assetlinerec.asset_cost_ccid,
                  assetlinerec.original_asset_cost,
                  -assetlinerec.current_asset_cost,
                  assetlinerec.project_asset_line_detail_id,
                  assetlinerec.gl_date,
                  'P',         --- Transfer_status_code
	          NULL,        --- transfer rejection reason
                  NULL,        --- amortize_flag,
                  assetlinerec.asset_category_id,
                  assetlinerec.project_asset_line_id,
	          assetlinerec.rev_from_proj_asset_line_id,
                  assetlinerec.invoice_number,
                  assetlinerec.vendor_number,
                  assetlinerec.po_vendor_id,
                  assetlinerec.po_number,
                  assetlinerec.invoice_date,
                  assetlinerec.invoice_created_by,
                  assetlinerec.invoice_updated_by,
                  assetlinerec.invoice_id,
                  assetlinerec.payables_batch_name,
                  assetlinerec.ap_distribution_line_number,
                  assetlinerec.invoice_distribution_id, --R12 new
                  assetlinerec.original_asset_id,
                  assetlinerec.line_type,
                  assetlinerec.capital_event_id,
                  assetlinerec.retirement_cost_type,
                  x_err_stage,
                  x_err_code);

	     IF ( cdl_fully_reversible ) THEN

	       -- Now maintain the asset grouped_cost figure
	       -- when we create an adjustment we will subtract the
	       -- adjustment amount from the grouped_cip_cost column

               update_asset_cost
                 (assetlinerec.project_asset_id,
		  -assetlinerec.current_asset_cost,
		  0,              --- capitalized_cost
                  x_err_stage,
                  x_err_code);

	     ELSE
		 -- create new project asset line
                 create_project_asset_lines
                     (assetlinerec.description,
                      0, --New lines are created as UNASSIGNED, rather than assigned to the Reversed asset
                      assetlinerec.project_id,
                      assetlinerec.task_id,
                      assetlinerec.cip_ccid,
                      assetlinerec.asset_cost_ccid,
                      assetlinerec.original_asset_cost,
                      assetlinerec.current_asset_cost,
                      assetlinerec.project_asset_line_detail_id,
                      assetlinerec.gl_date,
                      'P',         --- Transfer_status_code
	              NULL,        --- transfer rejection reason
                      NULL,        --- amortize_flag,
                      assetlinerec.asset_category_id,
		      NULL,        --- rev_proj_asset_line_id
                      assetlinerec.project_asset_line_id,
                      assetlinerec.invoice_number,
                      assetlinerec.vendor_number,
                      assetlinerec.po_vendor_id,
                      assetlinerec.po_number,
                      assetlinerec.invoice_date,
                      assetlinerec.invoice_created_by,
                      assetlinerec.invoice_updated_by,
                      assetlinerec.invoice_id,
                      assetlinerec.payables_batch_name,
                      assetlinerec.ap_distribution_line_number,
                      assetlinerec.invoice_distribution_id, --R12 new
                      assetlinerec.original_asset_id,
                      assetlinerec.line_type,
                      assetlinerec.capital_event_id,
                      assetlinerec.retirement_cost_type,
                      x_err_stage,
                      x_err_code);

	     END IF;

	   END LOOP;  --- FOR assetlinerec IN selprojassetlines .....

	   -- If the cdl_fully_reversible is true then mark all the
	   -- pa_project_asset_line_details as reversed
	   -- and update the cip_cost to Zero

	   IF ( cdl_fully_reversible ) THEN

              update_line_details
                 (detailidrec.project_asset_line_detail_id,
                  x_err_stage,
                  x_err_code);
	      -- Mark the expenditure item revenue distributed flag
              update_expenditure_items
                 (detailidrec.project_asset_line_detail_id,
		  'N',
                  x_err_stage,
                  x_err_code);

	   END IF;

	END LOOP; --- FOR detailidrec IN seldetailids LOOP

        -- At this time Project_asset_lines are reversed
        -- we need to interface the adjustment lines to FA now

	UPDATE
	     pa_project_assets
	SET
	     reverse_flag = 'N',
          /*  Automatic asset capitalization changes JPULTORAK 04-FEB-03 */
         --Commenting out this line since it is counter to business flow and erases key data (DPIS)
         --The CAPITAL_HOLD_FLAG will now be used to prevent new asset line generation
         --date_placed_in_service = NULL,
          /*  End of Automatic asset capitalization changes */
	     reversal_date = sysdate,
	     last_update_date = sysdate,
	     last_updated_by = x_last_updated_by,
	     last_update_login = x_last_update_login,
	     request_id = x_request_id,
	     program_application_id = x_program_application_id,
	     program_id = x_program_id,
	     program_update_date = sysdate
	WHERE
	     reverse_flag = 'S';

     EXCEPTION
       WHEN OTHERS THEN
	 x_err_code := SQLCODE;
	 RAISE;
   END reverse_asset_lines;

   PROCEDURE get_proj_asset_id
		 (x_project_id                IN         NUMBER,
		  x_task_id                   IN         NUMBER,
		  x_project_asset_id          IN OUT     NOCOPY NUMBER,
                  x_err_stage                 IN OUT     NOCOPY VARCHAR2,
                  x_err_code                  IN OUT     NOCOPY NUMBER)
   IS
   BEGIN
     x_err_code   := 0;
     x_err_stage  := 'Getting the Asset Id';
     x_project_asset_id := 0;

     BEGIN

       -- First get if there is any asset for project

       SELECT
	    paa.project_asset_id
       INTO
	    x_project_asset_id
       FROM
	    pa_project_asset_assignments paa
       WHERE
            paa.project_id =  x_project_id
       AND  paa.task_id = 0;

       EXCEPTION
         WHEN NO_DATA_FOUND THEN
	   NULL;
         WHEN OTHERS THEN
	   x_err_code := SQLCODE;
	   RAISE;
     END;

     --- Now get the top task level asset

     SELECT
	  paa.project_asset_id
     INTO
	  x_project_asset_id
     FROM
	  pa_project_asset_assignments paa
     WHERE
          paa.project_id =  x_project_id
     AND  paa.task_id =
                        (SELECT
                             task_id
                        FROM
                             pa_tasks
                        WHERE
                             parent_task_id is null    --- top task
                        CONNECT BY task_id = PRIOR parent_task_id
                        START WITH task_id = x_task_id
                        );

     EXCEPTION
       WHEN NO_DATA_FOUND THEN
         NULL;
       WHEN OTHERS THEN
	 x_err_code := SQLCODE;
	 RAISE;
   END get_proj_asset_id;

   --

   PROCEDURE delete_proj_asset_line
		 (x_project_asset_line_id     IN         NUMBER,
                  x_err_stage                 IN OUT     NOCOPY VARCHAR2,
                  x_err_code                  IN OUT     NOCOPY NUMBER)
   IS
   BEGIN
     x_err_code   := 0;
     x_err_stage  := 'Deleting the project asset line';

     DELETE
	pa_project_asset_lines
     WHERE
	project_asset_line_id = x_project_asset_line_id;

	IF l_mrc_flag = 'Y' THEN
	x_err_stage  := 'Deleting the ALC project asset line';

		DELETE PA_MC_PRJ_AST_LINES_ALL
		WHERE  project_asset_line_id = x_project_asset_line_id;
	END IF;

     EXCEPTION
       WHEN OTHERS THEN
	 x_err_code := SQLCODE;
	 RAISE;
   END delete_proj_asset_line;

   PROCEDURE delete_proj_asset_line_details
		 (x_project_asset_line_detail_id IN         NUMBER,
                  x_err_stage                    IN OUT     NOCOPY VARCHAR2,
                  x_err_code                     IN OUT     NOCOPY NUMBER)
   IS
   BEGIN
     x_err_code   := 0;
     x_err_stage  := 'Deleting the project asset line details';

     DELETE
	pa_project_asset_line_details
     WHERE
	project_asset_line_detail_id = x_project_asset_line_detail_id;

	IF l_mrc_flag = 'Y' THEN
	x_err_stage  := 'Deleting the ALC project asset line details';

		DELETE PA_MC_PRJ_AST_LINE_DTLS
		WHERE  PROJ_ASSET_LINE_DTL_UNIQ_ID    = x_project_asset_line_detail_id;
	END IF;

     EXCEPTION
       WHEN OTHERS THEN
	 x_err_code := SQLCODE;
	 RAISE;
   END delete_proj_asset_line_details;

   PROCEDURE delete_asset_lines
                 (x_project_id                IN         NUMBER,
                  x_capital_event_id          IN         NUMBER,
                  x_err_stage                 IN OUT     NOCOPY VARCHAR2,
                  x_err_code                  IN OUT     NOCOPY NUMBER)
   IS

	-- This cursor will return all the project asset line which are eligible
	-- for deletion

	CURSOR selassetlines IS
	SELECT
	     ppal.project_asset_line_detail_id,
	     ppal.project_asset_line_id,
	     ppal.project_asset_id,
	     ppal.current_asset_cost
	FROM
	     pa_project_asset_lines ppal
	WHERE
	    ppal.rev_proj_asset_line_id IS NULL
	AND ppal.transfer_status_code <> 'T'
    AND ppal.capital_event_id = NVL(x_capital_event_id, ppal.capital_event_id)
	AND ppal.project_asset_line_detail_id IN
	  (SELECT
	      /*+ INDEX (pal PA_PROJECT_ASSET_LINES_N2) */pal.project_asset_line_detail_id
           FROM
	      pa_project_asset_lines pal
           WHERE
               pal.project_id  = x_project_id
	   AND pal.rev_proj_asset_line_id IS NULL   -- This line is not an adjustment
	   AND pal.transfer_status_code <> 'T'
	   GROUP BY pal.project_asset_line_detail_id
	   HAVING SUM(current_asset_cost) =
	     ( SELECT
		     SUM(cip_cost)
	       FROM  pa_project_asset_line_details pald
	       WHERE pald.project_asset_line_detail_id = pal.project_asset_line_detail_id
	     )
	  )
	ORDER BY ppal.project_asset_line_detail_id;

     assetlinerec              selassetlines%ROWTYPE;
     curr_asset_line_detail_id NUMBER;
     update_detail_lines       BOOLEAN;
    -- Fix for bug : 4878878
    -- PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');

   BEGIN

	x_err_code   := 0;
	x_err_stage  := 'Deleting the Asset Lines';

	curr_asset_line_detail_id := 0;

	FOR assetlinerec IN selassetlines LOOP

	  IF (curr_asset_line_detail_id <>
	      assetlinerec.project_asset_line_detail_id ) THEN

	    check_proj_asset_lines
		   (assetlinerec.project_asset_line_detail_id,
		    update_detail_lines,
		    x_err_stage,
		    x_err_code);

	    -- Mark the expenditure item revenue distributed flag
            update_expenditure_items
                 (assetlinerec.project_asset_line_detail_id,
		  'N',
                  x_err_stage,
                  x_err_code);

	    IF (update_detail_lines) THEN
		-- update the reversed_flag = 'Y'
                update_line_details
                   (assetlinerec.project_asset_line_detail_id,
                    x_err_stage,
                    x_err_code);
	    ELSE

	IF G_debug_mode  = 'Y' THEN
	   pa_debug.debug('delete_asset_lines: ' || '.  Deleting detail for detail line id = ' ||
		     to_char(assetlinerec.project_asset_line_detail_id));
	END IF;

		-- delete all the details
	        delete_proj_asset_line_details
	           (assetlinerec.project_asset_line_detail_id,
		    x_err_stage,
		    x_err_code);

	    END IF;

	    curr_asset_line_detail_id := assetlinerec.project_asset_line_detail_id;
	  END IF;

	  -- now delete the projec asset line

	  delete_proj_asset_line
	       (assetlinerec.project_asset_line_id,
		x_err_stage,
		x_err_code);

          update_asset_cost
               (assetlinerec.project_asset_id,
	        -assetlinerec.current_asset_cost,
	        0,              --- capitalized_cost
                x_err_stage,
                x_err_code);
	END LOOP;

     EXCEPTION
       WHEN OTHERS THEN
	 x_err_code := SQLCODE;
	 RAISE;
   END delete_asset_lines;

   -- procedure to create project_asset_lines_details

   PROCEDURE create_proj_asset_line_details
              (x_expenditure_item_id           IN NUMBER,
               x_line_num                      IN NUMBER,
               x_project_asset_line_detail_id  IN NUMBER,
	       x_cip_cost                      IN NUMBER,
	       x_reversed_flag                 IN VARCHAR2,
               x_err_stage                  IN OUT NOCOPY VARCHAR2,
               x_err_code                   IN OUT NOCOPY NUMBER)
   IS
     proj_asset_line_detail_id  NUMBER;
     l_proj_asset_line_dtl_uniq_id NUMBER := 0;

   BEGIN

     x_err_code     := 0;
     x_err_stage    := 'Create Project Asset Line details';

     SELECT pa_proj_asset_line_dtls_uniq_s.nextval
     INTO l_proj_asset_line_dtl_uniq_id
     FROM sys.dual;

     INSERT INTO pa_project_asset_line_details(
               proj_asset_line_dtl_uniq_id,
               expenditure_item_id,
               line_num,
               project_asset_line_detail_id,
	       cip_cost,
	       reversed_flag,
               last_update_date,
               last_updated_by,
               created_by,
               creation_date,
	       last_update_login,
               request_id,
               program_application_id,
               program_id
     )
     SELECT
               l_proj_asset_line_dtl_uniq_id,
               x_expenditure_item_id,
               x_line_num,
               x_project_asset_line_detail_id,
	       x_cip_cost,
	       x_reversed_flag,
               sysdate,
               x_last_updated_by,
               x_created_by,
               sysdate,
	       x_last_update_login,
               x_request_id,
               x_program_application_id,
               x_program_id
     FROM
	       sys.dual;

     IF l_mrc_flag = 'Y' THEN
	create_alc_asset_line_details (l_proj_asset_line_dtl_uniq_id,
					    x_expenditure_item_id,
					    x_line_num,
					    x_project_asset_line_detail_id,
					    x_err_stage,
					    x_err_code);
     END IF;

     EXCEPTION
       WHEN OTHERS THEN
	 x_err_code := SQLCODE;
	 RAISE;
   END create_proj_asset_line_details;

   -- Procedure to generate summary asset lines
   Procedure fetch_vi_info ( /*Start changes for bug 7428263 */
                            /* x_invoice_id 	IN Number, */
			                 x_ref2             IN Number,
			                /*  x_ap_dist_line_number	IN Number, */
			                x_ref3             	IN Number,
			                x_ref4                     IN Number,
			                x_transaction_source       IN  VARCHAR2,
			                /*End of changes for bug 7428263 */
			                 x_employee_id		OUT NOCOPY Number,
			                 x_invoice_num		OUT NOCOPY VARCHAR2,
                             x_vendor_number            OUT NOCOPY VARCHAR2,
                             x_po_vendor_id             OUT NOCOPY NUMBER,
                             x_po_number                OUT NOCOPY VARCHAR2,
                             x_invoice_date             OUT NOCOPY DATE,
                             x_invoice_created_by       OUT NOCOPY NUMBER,
                             x_invoice_updated_by       OUT NOCOPY NUMBER,
                             x_payables_batch_name      OUT NOCOPY VARCHAR2,
                             x_err_stage                IN OUT NOCOPY VARCHAR2,
                             x_err_code                 IN OUT NOCOPY NUMBER)  IS
------bring VI info
    begin

           x_err_code := 0;
           x_err_stage := 'Fetching Vendor Invoice related information';

            If x_transaction_source in ('AP INVOICE', 'AP EXPENSE', 'AP NRTAX', 'AP DISCOUNTS', 'AP VARIANCE',
                      'CSE_IPV_ADJUSTMENT_DEPR') Then  /*adding CSE trx source*/

	   select rtrim(API.invoice_num),rtrim(POV.segment1),
                  POV.employee_id,
		  API.vendor_id,rtrim(upper(POH.segment1)),
		  API.invoice_date,API.created_by,
		  API.last_updated_by,
		  APB.batch_name
	  into    x_invoice_num, x_vendor_number,
                  x_employee_id,
		  x_po_vendor_id, x_po_number,
                  x_invoice_date, x_invoice_created_by,
                  x_invoice_updated_by,
                  x_payables_batch_name
	  from   ap_invoices_all API, ap_invoice_distributions_all APID, ap_batches_all APB,
		  po_vendors POV, po_headers_all POH ,po_distributions_all POD   /* Added _all for  bug 9253946 */
	  where   API.invoice_id = x_ref2
         and  APID.invoice_distribution_id = x_ref3 --bug 7428263
	     and  APID.invoice_id = API.invoice_id
	     and  APID.po_distribution_id = POD.po_distribution_id(+)
	     and  POD.po_header_id = POH.po_header_id(+)
	     and  POV.vendor_id = API.vendor_id
	     and  API.batch_id = APB.batch_id(+);


     ElsIf x_transaction_source in ('PO RECEIPT', 'PO RECEIPT NRTAX'
                                  , 'PO RECEIPT NRTAX PRICE ADJ', 'PO RECEIPT PRICE ADJ','CSE_PO_RECEIPT_DEPR') Then
              select  RCH.receipt_num,rtrim(POV.segment1),                                /*adding CSE trx source*/
                      POV.employee_id,RCH.vendor_id,
                      rtrim(upper(POH.segment1)),RCV.creation_date,
                      RCH.created_by,RCH.last_updated_by,null
              INTO
                     x_invoice_num,
                     x_vendor_number,
                     x_employee_id,
                     x_po_vendor_id,
                     x_po_number,
                     x_invoice_date,
                     x_invoice_created_by,
                     x_invoice_updated_by,
                     x_payables_batch_name
              from   rcv_shipment_headers RCH,
                     rcv_transactions RCV,
                     po_vendors POV,
		     po_headers_all POH           /* Added _all for bug 9253946 */
             where   RCV.po_header_id = x_ref2
             and  RCV.po_distribution_id = x_ref4
             and  RCV.transaction_id = x_ref3
	     and  RCV.po_header_id = POH.po_header_id
             and  RCV.vendor_id = POV.vendor_id
             and  RCV.shipment_header_id = RCH.shipment_header_id;


       	End if;



          exception when others then
                   x_err_code := SQLCODE;
 end fetch_vi_info;

   PROCEDURE generate_proj_asset_lines
	        ( x_project_id                IN  NUMBER,
	          x_in_service_date_through   IN  DATE,
	          x_common_tasks_flag         IN  VARCHAR2,
             	  x_pa_date                   IN  DATE,
                  x_capital_cost_type_code    IN  VARCHAR2 ,
                  x_cip_grouping_method_code  IN  VARCHAR2 ,
                  x_OVERRIDE_ASSET_ASSIGNMENT IN VARCHAR2,
                  x_VENDOR_INVOICE_GROUPING_CODE IN VARCHAR2,
                  x_capital_event_id       IN  NUMBER,
                  x_line_type              IN  VARCHAR2,
		  x_ledger_id              IN  NUMBER,
                  x_err_stage              IN OUT NOCOPY VARCHAR2,
                  x_err_code               IN OUT NOCOPY NUMBER)

   IS

/*  For manually entered burdened transactions, amount id 0 for CDL 'R'
    line, hence ignore those lines */

      CURSOR selcdls (p_project_id  NUMBER,
                      p_capital_cost_type_code VARCHAR2,
                      p_cip_grouping_method_code VARCHAR2,
                      p_override_asset_assignment VARCHAR2,
                      p_vendor_invoice_grouping_code VARCHAR2,
                      p_pa_through_date DATE,
                      p_common_tasks_flag  VARCHAR2,
                      p_in_service_date_through DATE,
		      p_ledger_id NUMBER,
                      p_amount_type varchar2 ) IS
     SELECT /*+ INDEX(pcdl PA_COST_DISTRIBUTION_LINES_U1) */ /* bug 5194567  added hint */
          pa_faxface.get_group_level_task_id(pei.task_id,pt.top_task_id,
                                              p_project_id) group_level_task_id,
           pa_faxface.get_asset_category_id(pei.document_header_id, -- R12 new
                                            pei.document_line_number, -- R12 new
                                            pei.document_distribution_id, -- R12 new
                                            pei.transaction_source) asset_category_id,
           pei.system_linkage_function,
           pei.document_header_id, -- R12 new
           pei.document_line_number, -- R12 new
           pei.document_distribution_id, -- R12 new
	   pet.expenditure_category,
	   pei.expenditure_type,
	   pei.non_labor_resource,
           PA_CLIENT_EXTN_CIP_ACCT_OVR.CIP_ACCT_OVERRIDE
            (decode(pcdl.acct_source_code,
                    'UPG', pcdl.dr_code_combination_id,
                    'EXT', pcdl.dr_code_combination_id,
		    'NA', pcdl.dr_code_combination_id,
                    NULL, decode(nvl(pei.historical_flag, 'Y'),
		                 'Y', decode(pcdl.line_type,
			                     'R', pcdl.dr_code_combination_id,
					     'D', pcdl.dr_code_combination_id,
					     'I', pa_xla_interface_pkg.get_post_acc_sla_ccid
					           (
					            pcdl.acct_event_id,
					            pcdl.transfer_status_code,
					            pei.transaction_source,
					            nvl(pei.historical_flag, 'Y'),
						    pcdl.expenditure_item_id,
						    pcdl.parent_line_num,
					            pcdl.line_type,
					            pcdl.dr_code_combination_id,
					            'DEBIT',
					            p_ledger_id
					            )
                                            ),
	                                  'N', decode(pcdl.system_reference4,'PJM',
 	                                                                         decode(pcdl.line_type,
 	                                                                         'R', pcdl.dr_code_combination_id,
 	                                                                         'D', pcdl.dr_code_combination_id,
 	                                                                         'I', pa_xla_interface_pkg.get_post_acc_sla_ccid
 	                                                                              (
 	                                                                               pcdl.acct_event_id,
 	                                                                               pcdl.transfer_status_code,
 	                                                                               pei.transaction_source,
 	                                                                               nvl(pei.historical_flag, 'Y'),
 	                                                                               pcdl.expenditure_item_id,
 	                                                                               pcdl.parent_line_num,
 	                                                                               pcdl.line_type,
 	                                                                               pcdl.dr_code_combination_id,
 	                                                                               'DEBIT',
 	                                                                               p_ledger_id
 	                                                                               )
 	                                                                              ), --Bug 8674676
 	                                         decode(pcdl.line_type,
					     'R', decode(pa_xla_interface_pkg.get_source(pei.transaction_source,
					                                                 pei.document_payment_id),
	                                                 'EXT', pcdl.dr_code_combination_id,
	                                                 pa_xla_interface_pkg.get_post_acc_sla_ccid
	                                                     (
	                                                     pcdl.acct_event_id,
	                                                     pcdl.transfer_status_code,
	                                                     pei.transaction_source,
	                                                     nvl(pei.historical_flag, 'Y'),
	                                                     decode(pa_xla_interface_pkg.get_source(pei.Transaction_Source,
					                                                    pei.document_payment_id),
		                                                    'PA', pcdl.expenditure_item_id,
		                                                    'AP_PAY', pcdl.system_reference5,
		                                                    'AP_INV', pei.document_distribution_id,
		                                                    'RCV', pcdl.system_reference5,
		                                                    'INV', pcdl.system_reference5,
		                                                    'WIP', pcdl.system_reference5), -- distribution_id1
	                                                    decode(pa_xla_interface_pkg.get_source(pei.Transaction_Source,
					                                                     pei.document_payment_id),
			                                                   'PA', pcdl.line_num,
			                                                   'AP_PAY', pei.document_distribution_id,
			                                                   'AP_INV', NULL,
			                                                   'RCV', NULL,
			                                                   'INV', NULL,
			                                                   'WIP', NULL),  -- distribution_id2
	                                                     pcdl.line_type,
	                                                     pcdl.dr_code_combination_id,
	                                                     'DEBIT',
	                                                     p_ledger_id
	                                                     )
	                                                ),
			                      pa_xla_interface_pkg.get_post_acc_sla_ccid
					           (
					            pcdl.acct_event_id,
					            pcdl.transfer_status_code,
					            pei.transaction_source,
					            nvl(pei.historical_flag, 'Y'),
						    pcdl.expenditure_item_id,
						    decode(pcdl.line_type,
						           'D', pcdl.line_num,
						           'I', pcdl.parent_line_num),
					            pcdl.line_type,
					            pcdl.dr_code_combination_id,
					            'DEBIT',
					            p_ledger_id
					            ) -- for I and D.
                                            ))
		                ), -- acct_source_code NULL
                    pa_xla_interface_pkg.get_post_acc_sla_ccid /* for all other acct source codes */
	                (
                         pcdl.acct_event_id,
                         pcdl.transfer_status_code,
                         pei.transaction_source,
                         nvl(pei.historical_flag, 'Y'),
                         pcdl.expenditure_item_id,
                         pcdl.line_num,
                         pcdl.line_type,
                         pcdl.dr_code_combination_id,
                         'DEBIT',
                         p_ledger_id
		        )
                   ),
             pcdl.expenditure_item_id,
             pcdl.line_num
	    ) cip_ccid,
           decode(p_amount_type,
                  'R', pcdl.amount,
                  decode(pcdl.line_type,
                         'D', pcdl.amount,
                         pcdl.burdened_cost)) cip_cost,
	   pcdl.expenditure_item_id,
	   pcdl.line_num,
	   NVL(p_cip_grouping_method_code,'ALL') cip_grouping_method_code,
           DECODE(x_line_type,
                  'R', PA_CLIENT_EXTN_RET_COST_TYPE.RETIREMENT_COST_TYPE
                                (pcdl.expenditure_item_id,
                                pcdl.line_num,
                                pei.expenditure_type),
                  DECODE(DECODE(p_vendor_invoice_grouping_code,'G','G','E')||pei.system_linkage_function,
                                'EVI', DECODE(p_cip_grouping_method_code,
                                              'EC', pet.expenditure_category,
                                              'ECNLR',pet.expenditure_category||'+'||pei.non_labor_resource,
                                              'ET',pei.expenditure_type,
                                              'ETNLR',pei.expenditure_type||'+'||pei.non_labor_resource,
                                              'CIPGCE',PA_CLIENT_EXTEN_CIP_GROUPING.CLIENT_GROUPING_METHOD(
                                                         p_project_id,
                                                         pei.task_id ,
                                                         pei.expenditure_item_id  ,
                                                         pei.expenditure_id  ,
                                                         pei.expenditure_type  ,
                                                         pet.expenditure_category ,
                                                         pei.attribute1  ,
                                                         pei.attribute2  ,
                                                         pei.attribute3  ,
                                                         pei.attribute4  ,
                                                         pei.attribute5  ,
                                                         pei.attribute6  ,
                                                         pei.attribute7  ,
                                                         pei.attribute8  ,
                                                         pei.attribute9  ,
                                                         pei.attribute10  ,
                                                         pei.attribute_category ,
                                                         pei.transaction_source,
                                                         pcdl.system_reference2,       /*bug 5523708- passing ref2,3,4*/
                                                         pcdl.system_reference3,
                                                         pcdl.system_reference4),
                                              'ALL')||'+'||pei.document_header_id||'+'||pei.document_distribution_id,
                                DECODE(p_cip_grouping_method_code,
                                       'EC',pet.expenditure_category,
                                       'ECNLR',pet.expenditure_category||'+'||pei.non_labor_resource,
                                       'ET',pei.expenditure_type,
                                       'ETNLR',pei.expenditure_type||'+'||pei.non_labor_resource,
                                       'CIPGCE',PA_CLIENT_EXTEN_CIP_GROUPING.CLIENT_GROUPING_METHOD(
                                                  p_project_id,
                                                  pei.task_id ,
                                                  pei.expenditure_item_id  ,
                                                  pei.expenditure_id  ,
                                                  pei.expenditure_type  ,
                                                  pet.expenditure_category ,
                                                  pei.attribute1  ,
                                                  pei.attribute2  ,
                                                  pei.attribute3  ,
                                                  pei.attribute4  ,
                                                  pei.attribute5  ,
                                                  pei.attribute6  ,
                                                  pei.attribute7  ,
                                                  pei.attribute8  ,
                                                  pei.attribute9  ,
                                                  pei.attribute10  ,
                                                  pei.attribute_category ,
                                                  pei.transaction_source,
                                                  pcdl.system_reference2,       /*bug 5454123- passing ref2,3,4*/
                                                  pcdl.system_reference3,
                                                  pcdl.system_reference4),
                                        'ALL' ))) GROUPING_METHOD,
             p_override_asset_assignment override_asset_assignment_flag,
	     p_vendor_invoice_grouping_code vendor_invoice_grouping_code,
	     p_project_id project_id,
             pei.task_id,
             pei.expenditure_id,
             pei.organization_id,
             pei.attribute1,
             pei.attribute2,
             pei.attribute3,
             pei.attribute4,
             pei.attribute5,
             pei.attribute6,
             pei.attribute7,
             pei.attribute8,
             pei.attribute9,
             pei.attribute10,
             pei.attribute_category,
             pei.capital_event_id,
             -- Added for bug : 4768332
             pcdl.acct_event_id,
             NVL(pei.transaction_source,'Projects') transaction_source
             --pa_xla_interface_pkg.get_source(pei.transaction_source, pei.document_payment_id) transaction_source

       FROM
	     pa_cost_distribution_lines_all pcdl,
	     pa_expenditure_items_all pei,
	     pa_expenditure_types pet,
	     pa_tasks pt
       WHERE
	     pcdl.expenditure_item_id = pei.expenditure_item_id
       AND   pei.revenue_distributed_flag||'' = 'N'
       AND   pei.cost_distributed_flag ='Y'
       AND   pcdl.transfer_status_code in ('P','A','V','T','R','G','B')    /*bug5672624*/ /*Modified for bug 7142829 */
       AND   (pcdl.line_type = p_capital_cost_type_code
              OR pcdl.line_type = DECODE(p_capital_cost_type_code,
                                         'R', 'I',
                                         p_capital_cost_type_code))
       AND   ((pcdl.line_type = 'I' and pcdl.transfer_status_code = 'G') OR
               pcdl.line_type in ('R', 'D') and pcdl.transfer_status_code in ('V', 'A'))
       AND   ((pcdl.billable_flag = 'Y' and x_line_type = 'C') OR x_line_type = 'R')  -- Bug 4860800
       --AND   pei.billable_flag = DECODE(x_line_type, 'C', 'Y', 'N') -- Bug 4860800
       AND   pei.capital_event_id IS NOT NULL
       AND   pei.capital_event_id = NVL(x_capital_event_id, pei.capital_event_id)
       AND   NVL(pt.retirement_cost_flag,'N') = DECODE(x_line_type,'R','Y','N')
       /* Added the below code as part of bug 7274814
          Fix is to prevent net-zeroing CDLs from being processed */
       AND NOT EXISTS
           /* Reversed CDL*/
           (SELECT NULL
            FROM   PA_COST_DISTRIBUTION_LINES_ALL CDL1,
                   PA_COST_DISTRIBUTION_LINES_ALL CDL2
            WHERE  CDL1.EXPENDITURE_ITEM_ID = PEI.EXPENDITURE_ITEM_ID
               AND CDL1.LINE_NUM = PCDL.LINE_NUM
               AND CDL1.REVERSED_FLAG = 'Y'
               AND CDL1.BILLABLE_FLAG = 'Y'
               AND CDL2.EXPENDITURE_ITEM_ID = PEI.EXPENDITURE_ITEM_ID
               AND CDL2.LINE_NUM_REVERSED = CDL1.LINE_NUM
               AND CDL2.BILLABLE_FLAG = 'Y'
               AND   TRUNC(CDL1.PA_DATE)  <= TRUNC(P_PA_THROUGH_DATE)		/* Added for Bug 7445771 */
            UNION ALL
            /* Reversal CDL*/
            SELECT NULL
            FROM   PA_COST_DISTRIBUTION_LINES_ALL CDL1,
                   PA_COST_DISTRIBUTION_LINES_ALL CDL2
            WHERE  CDL1.EXPENDITURE_ITEM_ID = PEI.EXPENDITURE_ITEM_ID
               AND CDL1.REVERSED_FLAG = 'Y'
               AND CDL1.BILLABLE_FLAG = 'Y'
               AND CDL2.EXPENDITURE_ITEM_ID = PEI.EXPENDITURE_ITEM_ID
               AND CDL2.LINE_NUM_REVERSED = CDL1.LINE_NUM
               AND CDL2.LINE_NUM = PCDL.LINE_NUM
               AND CDL2.BILLABLE_FLAG = 'Y'
               AND   TRUNC(CDL1.PA_DATE)  <= TRUNC(P_PA_THROUGH_DATE)		/* Added for Bug 7445771 */
               /* To check if the reversed CDL has been capitalized*/
               AND NOT EXISTS (SELECT NULL
                               FROM   PA_PROJECT_ASSET_LINE_DETAILS PALD1
                               WHERE  PALD1.EXPENDITURE_ITEM_ID = CDL1.EXPENDITURE_ITEM_ID
                                  AND PALD1.LINE_NUM = CDL1.LINE_NUM
                                  AND PALD1.REVERSED_FLAG ||'' = 'N')
            UNION ALL
            /* For ei adjustment e.g. transfer from cap to expense task
            SELECT NULL
            FROM   PA_EXPENDITURE_ITEMS_ALL EI1
            WHERE  EI1.EXPENDITURE_ITEM_ID = PEI.EXPENDITURE_ITEM_ID
               AND EI1.NET_ZERO_ADJUSTMENT_FLAG = 'Y'
               /* checking if the adjusted ei has already been capitalized
               AND NOT EXISTS (SELECT NULL
                               FROM   PA_PROJECT_ASSET_LINE_DETAILS PALD2
                               WHERE  PALD2.EXPENDITURE_ITEM_ID =
                                            DECODE(EI1.ADJUSTED_EXPENDITURE_ITEM_ID,NULL,- 99,
                                                   EI1.ADJUSTED_EXPENDITURE_ITEM_ID)
                                  AND PALD2.REVERSED_FLAG ||'' = 'N')
  Commented the above code and added below two selects for Bug 7445771 */
            SELECT NULL
            FROM   PA_EXPENDITURE_ITEMS_ALL EI1
            WHERE  EI1.EXPENDITURE_ITEM_ID = PEI.EXPENDITURE_ITEM_ID
               AND EI1.NET_ZERO_ADJUSTMENT_FLAG = 'Y'
               AND EI1.ADJUSTED_EXPENDITURE_ITEM_ID IS NULL
               AND NOT EXISTS (SELECT NULL
                       FROM   PA_PROJECT_ASSET_LINE_DETAILS PALD2,
                              PA_EXPENDITURE_ITEMS_ALL EI2
                       WHERE  EI2.ADJUSTED_EXPENDITURE_ITEM_ID = EI1.EXPENDITURE_ITEM_ID
                              AND PALD2.EXPENDITURE_ITEM_ID = EI2.ADJUSTED_EXPENDITURE_ITEM_ID
                              AND PALD2.REVERSED_FLAG||'' = 'N')
               AND EXISTS (SELECT 1
                   FROM   PA_EXPENDITURE_ITEMS_ALL EI3,
                          PA_COST_DISTRIBUTION_LINES_ALL PCDL2
                   WHERE  EI3.ADJUSTED_EXPENDITURE_ITEM_ID = EI1.EXPENDITURE_ITEM_ID
                          AND EI3.EXPENDITURE_ITEM_ID = PCDL2.EXPENDITURE_ITEM_ID
                          AND TRUNC(PCDL2.PA_DATE) <= TRUNC(P_PA_THROUGH_DATE))
           UNION ALL
           SELECT NULL
           FROM   PA_EXPENDITURE_ITEMS_ALL EI1
           WHERE  EI1.EXPENDITURE_ITEM_ID = PEI.EXPENDITURE_ITEM_ID
             AND  EI1.NET_ZERO_ADJUSTMENT_FLAG = 'Y'
             AND  EI1.ADJUSTED_EXPENDITURE_ITEM_ID IS NOT NULL
             AND  NOT EXISTS (SELECT NULL
                       FROM   PA_PROJECT_ASSET_LINE_DETAILS PALD2
                       WHERE  PALD2.EXPENDITURE_ITEM_ID = EI1.ADJUSTED_EXPENDITURE_ITEM_ID
                              AND PALD2.REVERSED_FLAG||'' = 'N')
             AND  EXISTS (SELECT 1
                   FROM   PA_COST_DISTRIBUTION_LINES_ALL PCDL2
                   WHERE  PCDL2.EXPENDITURE_ITEM_ID = EI1.ADJUSTED_EXPENDITURE_ITEM_ID
                          AND TRUNC(PCDL2.PA_DATE) <= TRUNC(P_PA_THROUGH_DATE))
   /* End of code changes for Bug 7445771 */
                                       )
       /* End of code changes done as part of bug 7274814 */
       AND   TRUNC(pcdl.pa_date)  <= TRUNC(p_pa_through_date)
       AND   decode(p_amount_type,
                    'R', pcdl.amount,
                    decode(pcdl.line_type,
                           'D', pcdl.amount,
                           pcdl.burdened_cost)) <> 0
       AND   pei.task_id = pt.task_id
       AND   pei.expenditure_type = pet.expenditure_type
       AND   pt.project_id =p_project_id
       /*start of change for bug 6037734*/
       AND   (pa_nl_installed.is_nl_installed='N'
        OR (pa_nl_installed.is_nl_installed='Y'
            AND EXISTS(select NULL from pa_expenditure_items_all ei1
                       where  ei1.expenditure_item_id = pei.expenditure_item_id
                       and (ei1.attribute6 is not null OR ei1.attribute7 is not null OR ei1.attribute8 is not null
                            OR ei1.attribute9 is not null OR ei1.attribute10 is not null)
                      )
            AND NOT EXISTS (select null from pa_expenditure_items_all ei2
                            where ei2.expenditure_item_id = pei.expenditure_item_id
                            and ei2.attribute8 is NULL
                            and ei2.attribute9 is NULL
                            )
           )
        OR (pa_nl_installed.is_nl_installed='Y'
            AND EXISTS(select null from pa_expenditure_items_all ei3
                       where ei3.expenditure_item_id = pei.expenditure_item_id
                       and ei3.attribute6 is NULL
                       and ei3.attribute7 is NULL
                       and ei3.attribute8 is NULL
                       and ei3.attribute9 is NULL
                       and ei3.attribute10 is NULL
                      )
           )
       )
     /* end of change for bug 6037734*/
       AND   EXISTS (  SELECT '1'                  -- Check for task_id to have asset assignment
                        FROM pa_project_assets ppa,
                             pa_project_asset_assignments paa
                       WHERE paa.project_id =  p_project_id
                         AND paa.task_id = pt.task_id
                         AND ppa.capital_event_id IS NOT NULL
                         AND ppa.capital_event_id = NVL(x_capital_event_id, pei.capital_event_id)
                         AND ppa.project_asset_type = DECODE(x_line_type,'C','AS-BUILT','RETIREMENT_ADJUSTMENT')
                         AND ppa.capital_hold_flag = 'N'
                         AND ppa.project_asset_id = paa.project_asset_id
                         AND TRUNC(ppa.date_placed_in_service) <= TRUNC(p_in_service_date_through)
                       UNION ALL
                       SELECT '1'           -- Check for top_task_id to have asset assignment
                        FROM pa_project_assets ppa,
                             pa_project_asset_assignments paa
                       WHERE paa.project_id =  p_project_id
                         AND paa.task_id = pt.top_task_id
                         AND ppa.capital_event_id IS NOT NULL
                         AND ppa.capital_event_id = NVL(x_capital_event_id, pei.capital_event_id)
                         AND ppa.project_asset_type = DECODE(x_line_type,'C','AS-BUILT','RETIREMENT_ADJUSTMENT')
                         AND ppa.capital_hold_flag = 'N'
                         AND ppa.project_asset_id = paa.project_asset_id
                         AND TRUNC(ppa.date_placed_in_service) <= TRUNC(p_in_service_date_through)
                       UNION ALL
                       SELECT '1'             -- Check for project level Asset Assignments
                        FROM pa_project_assets ppa,
                             pa_project_asset_assignments paa
                       WHERE paa.project_id =  p_project_id
                         AND nvl(paa.task_id,0) = 0
                         AND ppa.capital_event_id IS NOT NULL
                         AND ppa.capital_event_id = NVL(x_capital_event_id, pei.capital_event_id)
                         AND ppa.project_asset_type = DECODE(x_line_type,'C','AS-BUILT','RETIREMENT_ADJUSTMENT')
                         AND ppa.capital_hold_flag = 'N'
                         AND ppa.project_asset_id = paa.project_asset_id
                         AND TRUNC(ppa.date_placed_in_service) <= TRUNC(p_in_service_date_through)
                       UNION ALL
                      SELECT '1'               -- Check task_id is a common cost task
                       FROM  pa_project_asset_assignments paa
                       WHERE paa.project_id =  p_project_id
                       AND   task_id = pt.task_id
                       AND DECODE(paa.project_asset_id, 0,p_common_tasks_flag, 'N')  = 'Y'
                      UNION ALL
                      SELECT '1'               -- Check top_task_id is a common cost task
                       FROM  pa_project_asset_assignments paa
                       WHERE paa.project_id =  p_project_id
                       AND   task_id = pt.top_task_id
                       AND DECODE(paa.project_asset_id, 0,p_common_tasks_flag, 'N')  = 'Y'
                      UNION ALL
                      SELECT '1'               -- Check project is a common cost project
                       FROM  pa_project_asset_assignments paa
                       WHERE paa.project_id =  p_project_id
                       AND   nvl(task_id,0) = 0
                       AND DECODE(paa.project_asset_id, 0,p_common_tasks_flag, 'N')  = 'Y'
                     )

       AND NOT EXISTS
	    (
	        SELECT
		      'This CDL was summarized before'
	        FROM
		     pa_project_asset_line_details pald
	        WHERE
		     pald.expenditure_item_id = pcdl.expenditure_item_id
	        AND  pald.line_num = pcdl.line_num
	        AND  pald.reversed_flag||'' = 'N'
	      )
       ORDER BY
         1,           -- group level task Id
         2,           -- asset category id
         cip_ccid,
         pei.capital_event_id,
         GROUPING_METHOD;

  cursor c_proj_asset(p_asset_id in number) is
             select project_id, date_placed_in_service, capital_event_id,
	            capital_hold_flag, project_asset_type
             from pa_project_assets
             where project_asset_id = nvl(p_asset_id,0);

   l_amount_type             varchar2(1) := Null;
   l_tbc_flag                varchar2(1);
   l_capitalization          varchar2(30);
   cdlrec                    selcdls%ROWTYPE;
   first_rec                 BOOLEAN;
   curr_asset_id             NUMBER;
   prev_asset_id             NUMBER;
   l_asset_id                NUMBER;
   l_num_asset_assignment    NUMBER;
   curr_ccid                 NUMBER;
   prev_ccid                 NUMBER;
   curr_nlr                  pa_expenditure_items_all.non_labor_resource%TYPE;
   prev_nlr                  pa_expenditure_items_all.non_labor_resource%TYPE;
   curr_expend_type          VARCHAR2(100);
   prev_expend_type          VARCHAR2(100);
   curr_expend_cat           VARCHAR2(100);
   curr_grouping_method      VARCHAR2(255);
   prev_expend_cat           VARCHAR2(100);
   curr_grp_task_id          NUMBER:=-99;
   prev_grp_task_id          NUMBER:=-99;
   curr_asset_category_id    NUMBER;
   prev_asset_category_id    NUMBER;
   curr_asset_cost           NUMBER;
   prev_asset_cost           NUMBER;
   proj_asset_line_detail_id NUMBER;
   description               pa_project_asset_lines.description%TYPE;
   depreciation_expense_ccid NUMBER;
   prev_sys_link_fun         pa_expenditure_items_all.system_linkage_function%TYPE;

   curr_employee_id          po_vendors.employee_id%type;
   curr_invoice_num          ap_invoices.invoice_num%TYPE;
   curr_vendor_number        po_vendors.segment1%TYPE;
   curr_po_vendor_id         ap_invoices.vendor_id%TYPE;
   curr_po_number            po_headers.segment1%TYPE;
   curr_invoice_date         ap_invoices.invoice_date%TYPE;
   curr_invoice_created_by   ap_invoices.created_by%TYPE;
   curr_invoice_updated_by   ap_invoices.last_updated_by%TYPE;
   /*curr_invoice_id           ap_invoices.invoice_id%TYPE;*/ -- bug7428263
   curr_ref2                 pa_expenditure_items.document_header_id%TYPE; -- bug7428263
   curr_transaction_source   pa_expenditure_items.transaction_source%TYPE; -- bug7428263
   curr_payables_batch_name  ap_batches.batch_name%TYPE;
   curr_ap_dist_line_number  ap_invoice_distributions.distribution_line_number%TYPE;
   curr_ref3                 pa_expenditure_items.document_distribution_id%TYPE;-- bug7428263
   curr_ref4                 pa_expenditure_items.document_line_number%TYPE;-- bug7428263
   /*curr_ap_inv_dist_id       ap_invoice_distributions.invoice_distribution_id%TYPE;*/ -- bug7428263
   curr_inv_line_number      ap_invoice_distributions.invoice_line_number%TYPE;
   prev_employee_id          po_vendors.employee_id%type;
   prev_invoice_num          ap_invoices.invoice_num%TYPE;
   prev_vendor_number        po_vendors.segment1%TYPE;
   prev_po_vendor_id         ap_invoices.vendor_id%TYPE;
   prev_po_number            po_headers.segment1%TYPE;
   prev_invoice_date         ap_invoices.invoice_date%TYPE;
   prev_invoice_created_by   ap_invoices.created_by%TYPE;
   prev_invoice_updated_by   ap_invoices.last_updated_by%TYPE;
   /*prev_invoice_id           ap_invoices.invoice_id%TYPE;*/
   prev_ref2                 ap_invoices.invoice_id%TYPE;
   prev_payables_batch_name  ap_batches.batch_name%TYPE;
   prev_ap_dist_line_number  ap_invoice_distributions.distribution_line_number%TYPE;
   prev_ref3                 pa_expenditure_items.document_distribution_id%TYPE;-- bug7428263
   prev_ref4                 pa_expenditure_items.document_line_number%TYPE;-- bug7428263
   --prev_ap_inv_dist_id       ap_invoice_distributions.invoice_distribution_id%TYPE; -- bug7428263
   prev_inv_line_number      ap_invoice_distributions.invoice_line_number%TYPE;

   curr_capital_event_id     pa_capital_events.capital_event_id%TYPE;
   prev_capital_event_id     pa_capital_events.capital_event_id%TYPE;
   v_retirement_cost_type    pa_project_asset_lines_all.retirement_cost_type%TYPE := NULL;
   extn_capital_event_id     pa_capital_events.capital_event_id%TYPE;
   extn_capital_hold_flag    pa_project_assets_all.capital_hold_flag%TYPE;
   extn_project_asset_type   pa_project_assets_all.project_asset_type%TYPE;

   extn_project_id           number(15);
   extn_date_in_service      date;
   extn_error_code           varchar2(1);
   asset_valid               boolean;
   l_asset_v                 boolean;
   l_profile_no_dpis         varchar2(1); /* Added for bug 6788325 */
   orig_asset_id             number(15);
   client_asset_id           number(15);
   v_crl_profile             varchar2(1) := NVL(FND_PROFILE.value('PA_CRL_LICENSED'), 'N');  /*bug5523708*/
   l_call_vi_info            VARCHAR2(1):='Y'; /* Added for bug 7428263 */

    -- Fix for bug : 4878878
   -- PG_DEBUG varchar2(1) :=   NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');

   cdlrec           t_rec;

   BEGIN
     x_err_stage  := 'Generating project asset lines';
     x_err_code   := 0;

     first_rec    := TRUE;
     curr_asset_cost := 0;
     l_asset_v    :=FALSE;
     l_profile_no_dpis := NVL(UPPER(SUBSTR(fnd_profile.value_specific('PA_ASSIGN_ASSET_LINE_WITH_NO_DPIS'), 1, 1)), 'Y');
     /* Added for bug 6788325 */

     SELECT pt.capital_cost_type_code
       INTO l_amount_type
       FROM pa_projects ppr,
            pa_project_types pt
      WHERE ppr.project_type=pt.project_type
        AND project_id=x_project_id;

     FOR cdlrec IN selcdls(x_project_id,
                           x_capital_cost_type_code,
                           x_cip_grouping_method_code,
                           x_OVERRIDE_ASSET_ASSIGNMENT,
                           x_VENDOR_INVOICE_GROUPING_CODE ,
                           x_pa_date,
                           x_common_tasks_flag,
                           x_in_service_date_through,
                           x_ledger_id,
                           l_amount_type ) LOOP

       IF G_debug_mode  = 'Y' THEN
          pa_debug.debug('generate_proj_asset_lines: ' || '.  Processing Expenditure Item Id= '||
			     to_char(cdlrec.expenditure_item_id)||
			' CDL num = '||to_char(cdlrec.line_num));
       END IF;
        orig_asset_id := l_asset_id;

       -- R12 changes start..if ccid is null, reject the cdl
	  if cdlrec.cip_ccid is null then
		goto SKIP_NO_ACCOUNTS;
          end if;

       -- R12 changes end..get the account and call client extn to override

        /* added condition prev_sys_link_fun = 'VI' to following if condition.
	   This is done so that in case a VI is just processed and some asset
	   is assigned to it then same asset doesn't get assigned to the
           subsequenct cdls. */

	if (cdlrec.group_level_task_id <> curr_grp_task_id) or
            ( cdlrec.system_linkage_function ='VI') or
            (prev_sys_link_fun = 'VI') then
                 get_asset_id
                        ( x_project_id               => x_project_id,
                         x_system_linkage_function  => cdlrec.system_linkage_function,
                         x_grp_level_task_id        => cdlrec.group_level_task_id,
                         x_asset_category_id        => cdlrec.asset_category_id,
                         x_line_type                => x_line_type,
                         x_capital_event_id         => cdlrec.capital_event_id,
                         x_asset_id                 => l_asset_id ,
                         x_num_asset_assigned       => l_num_asset_assignment
                        );
            commit ;
        end if;
        curr_asset_id := l_asset_id;
        client_asset_id := l_asset_id;

/*bug5523708 - an eIB ct should be able to use fetch_vi_info for obtaining PO/Supplier info for non-eIB trxns
  added from crl_profile*/
   if (cdlrec.vendor_invoice_grouping_code <> 'G' and cdlrec.system_linkage_function='VI')
            OR
      (v_crl_profile  ='Y' AND
       cdlrec.vendor_invoice_grouping_code = 'G' AND
       cdlrec.system_linkage_function='VI' AND
       cdlrec.transaction_source in ('AP INVOICE', 'AP EXPENSE', 'AP NRTAX', 'AP DISCOUNTS', 'AP VARIANCE',
                              'PO RECEIPT', 'PO RECEIPT NRTAX', 'PO RECEIPT NRTAX PRICE ADJ', 'PO RECEIPT PRICE ADJ',
                              'CSE_IPV_ADJUSTMENT','CSE_PO_RECEIPT')
       ) THEN
        -- R12 changes..these variables are not used anywhere. do we need these at all ?
        --   curr_nlr           := cdlrec.non_labor_resource||cdlrec.system_reference2||cdlrec.system_reference3;
        --   curr_expend_type   := cdlrec.expenditure_type||cdlrec.system_reference2||cdlrec.system_reference3;
        --   curr_expend_cat    := cdlrec.expenditure_category||cdlrec.system_reference2||cdlrec.system_reference3;

      /* Added the following if condition for bug 7428263 */
	 If (curr_transaction_source = cdlrec.transaction_source) Then
		If ((cdlrec.transaction_source in  ('AP INVOICE', 'AP EXPENSE', 'AP NRTAX', 'AP DISCOUNTS',
										'AP VARIANCE', 'CSE_IPV_ADJUSTMENT_DEPR','CSE_IPV_ADJUSTMENT'))
			and (cdlrec.document_header_id = nvl(curr_ref2,-99))) Then
            	l_call_vi_info := 'N';
        elsIf ((cdlrec.transaction_source in  ('PO RECEIPT', 'PO RECEIPT NRTAX', 'PO RECEIPT NRTAX PRICE ADJ',
									'PO RECEIPT PRICE ADJ','CSE_PO_RECEIPT_DEPR','CSE_PO_RECEIPT'))
			and (cdlrec.document_distribution_id = nvl(curr_ref3,-99))) Then
			    l_call_vi_info := 'N';
        else
			    l_call_vi_info := 'Y';
        end if;
    end if;
     /* Ends added for bug 7428263 */

        --   curr_ap_dist_line_number := cdlrec.system_reference3;
	   --curr_ap_inv_dist_id  := cdlrec.document_distribution_id; -- bug7428263
	   curr_ref3 := cdlrec.document_distribution_id;
	   curr_ref4 := cdlrec.document_line_number;

--        if (cdlrec.system_reference2 <> nvl(curr_invoice_id,-99)) then
         /*if ((cdlrec.document_header_id <> nvl(curr_ref2,-99)) and (cdlrec.vendor_invoice_grouping_code <> 'G')) then /*Added for bug:7139484
          commented for bug 7428263*/

          if ((l_call_vi_info = 'Y') AND (cdlrec.vendor_invoice_grouping_code <> 'G')) then

             --curr_invoice_id := cdlrec.system_reference2;
             /*curr_invoice_id := cdlrec.document_header_id;*/ -- bug7428263
               curr_ref2:= cdlrec.document_header_id;
               curr_transaction_source := cdlrec.transaction_source;

             fetch_vi_info ( /*Start of changes for Bug 7428263  */
	                         /*x_invoice_id          => curr_invoice_id, */
	                         x_ref2                => curr_ref2,
			                 /*  x_ap_dist_line_number => curr_ap_dist_line_number, */
			                 x_ref3                => curr_ref3,
			                 x_ref4                => curr_ref4,
			                 x_transaction_source  => curr_transaction_source,
                             /*End of changes for Bug 7428263  */
			                 x_employee_id         => curr_employee_id,
			                 x_invoice_num         => curr_invoice_num,
                             x_vendor_number       => curr_vendor_number,
                             x_po_vendor_id        => curr_po_vendor_id,
                             x_po_number           => curr_po_number,
                             x_invoice_date        => curr_invoice_date,
                             x_invoice_created_by  => curr_invoice_created_by,
                             x_invoice_updated_by  => curr_invoice_updated_by,
                             x_payables_batch_name  => curr_payables_batch_name,
                             x_err_stage           => x_err_stage,
                             x_err_code            => x_err_code);
        end if;
   else
	      curr_invoice_num := null;
          curr_vendor_number := null;
	      curr_po_vendor_id:= null;
          curr_po_number := null;
          curr_invoice_date := null;
          curr_invoice_created_by := null;
          curr_invoice_updated_by := null;
          --curr_invoice_id := null;
          curr_ref2 := null; -- bug7428263
          curr_payables_batch_name := null;
          --curr_ap_dist_line_number:=null;
          curr_ref3 := null; -- bug7428263
          curr_ref4 := null; -- bug7428263
          curr_employee_id := null;
          --curr_nlr           := cdlrec.non_labor_resource;
          --curr_expend_type   := cdlrec.expenditure_type;
          --curr_expend_cat    := cdlrec.expenditure_category;
   end if;

-------------------------call client extension
asset_valid := TRUE;
if (curr_asset_id = 0 OR cdlrec.override_asset_assignment_flag = 'Y') then
PA_CLIENT_EXTN_GEN_ASSET_LINES.CLIENT_ASSET_ASSIGNMENT(cdlrec.project_id,
                                  cdlrec.task_id,
                                  cdlrec.expenditure_item_id,
                                  cdlrec.expenditure_id,
                                  cdlrec.expenditure_type,
                                  cdlrec.expenditure_category,
                                  cdlrec.system_linkage_function,
                                  cdlrec.organization_id,
                                  cdlrec.non_labor_resource,
                                 -- curr_invoice_id,
                                  curr_ref2, -- bug7428263
                                  --curr_ap_dist_line_number, -- R12 change
                                  --curr_ap_inv_dist_id, -- R12 change
                                  curr_ref3,-- bug7428263
                                  curr_po_vendor_id,
                                  curr_employee_id,
                                  cdlrec.attribute1,
                                  cdlrec.attribute2,
                                  cdlrec.attribute3,
                                  cdlrec.attribute4,
                                  cdlrec.attribute5,
                                  cdlrec.attribute6,
                                  cdlrec.attribute7,
                                  cdlrec.attribute8,
                                  cdlrec.attribute9,
                                  cdlrec.attribute10,
                                  cdlrec.attribute_category,
                                  x_in_service_date_through,
                                  client_asset_id);

 l_asset_v:=FALSE;
 if (client_asset_id > 0) then
 if (nvl(client_asset_id,0) <> curr_asset_id) then
          open c_proj_asset(client_asset_id);
          fetch c_proj_asset into extn_project_id,extn_date_in_service,
	        extn_capital_event_id,extn_capital_hold_flag,extn_project_asset_type;
          if extn_project_id is null then
            extn_error_code :='I';
            asset_valid :=FALSE;
          end if;
          if (nvl(extn_project_id,0) <> x_project_id) then
               extn_error_code := 'P';
               asset_valid := FALSE;
          elsif (extn_date_in_service is null) then
               extn_error_code := 'D';
	       /* Start: Added the following for bug 6788325 */
	       if (l_profile_no_dpis = 'N') then
            asset_valid := FALSE;
	       else
            asset_valid := TRUE;
	       end if;
	       /* End: Added the following for bug 6788325 */
                l_asset_v  := TRUE;
          elsif trunc(nvl(extn_date_in_service,'')) > trunc(x_in_service_date_through) then
               extn_error_code := 'B';
               asset_valid := FALSE;
          ELSIF x_line_type = 'C' AND extn_project_asset_type <> 'AS-BUILT' THEN
               extn_error_code := 'T';
               asset_valid := FALSE;
          ELSIF x_line_type = 'R' AND extn_project_asset_type <> 'RETIREMENT_ADJUSTMENT' THEN
               extn_error_code := 'T';
               asset_valid := FALSE;
          ELSIF extn_capital_hold_flag = 'Y' THEN
               extn_error_code := 'G';
               asset_valid := FALSE;
          ELSIF NVL(extn_capital_event_id,-1) <> cdlrec.capital_event_id THEN
               extn_error_code := 'E';
               asset_valid := FALSE;
          else
               asset_valid := TRUE;
          end if;
          close c_proj_asset;

/* Modified the following condition for bug 6788325 inorder to build the logic in such a way that
the capital exceptions should record all the exceptions when asset is not valid except for the
asset without date place in services when the profile option "PA_ASSIGN_ASSET_LINE_WITH_NO_DPIS"
is set to "No"/"N"(for Cingular)*/

           if (((asset_valid = FALSE) AND (l_asset_v = FALSE))  OR ((asset_valid = TRUE) AND (l_asset_v = TRUE))) then
           begin
	             insert into pa_capital_exceptions(request_id,
                                                     module,
	                                             record_type,
                                                     project_id,
                                                     project_asset_id,
                                                     error_code,
                                                     created_by,
                                                     creation_date)
                                     values (x_request_id,
                                             'CAPITAL',
                                             'E',
                                             x_project_id,
                                             nvl(client_asset_id,l_asset_id),
                                             extn_error_code,
                                             x_created_by,
                                             fnd_date.date_to_canonical(sysdate));
                     exception when others then
                             x_err_code := SQLCODE;
                             RAISE;
           end;
           end if;
  /* Commenting out this logic for bug 6788325 as this logic is already
  being handled outside the if loop for client_asset_id > 0
     IF (asset_valid = TRUE) OR (l_asset_v = TRUE) then
         curr_asset_id := client_asset_id;
     end if;
  */
 end if;
end if; /* if (client_asset_id > 0) */

/* Fix for bug : 4962096 */
IF (asset_valid = TRUE) then
    curr_asset_id := client_asset_id;
END IF;

end if;
------------------------end client extension
if (asset_valid = TRUE) then
   -- Process the CDL here

       curr_grp_task_id   := cdlrec.group_level_task_id;
           curr_ccid          := cdlrec.cip_ccid;
           curr_asset_category_id := cdlrec.asset_category_id;
           curr_capital_event_id := cdlrec.capital_event_id;

        if cdlrec.system_linkage_function ='VI' and l_num_asset_assignment=1 then
           curr_asset_category_id:=NULL;
        end if;

   IF FIRST_REC OR (((NVL(curr_asset_id,-1) = NVL(prev_asset_id,-1)) AND
      (NVL(curr_grp_task_id,-1) = NVL(prev_grp_task_id,-1)) AND
      (NVL(curr_asset_category_id,-1) = NVL(prev_asset_category_id,-1)) AND
      (NVL(curr_ccid,-1) = NVL(prev_ccid,-1)) AND
      (NVL(curr_grouping_method,'-1') = NVL(cdlrec.grouping_method,'-1')) AND
      (NVL(curr_capital_event_id,-1) = NVL(prev_capital_event_id,-1))
      )) then
		     -- This cdl is candidate for summarization

                if (first_rec) then
                    get_asset_attributes
		      (curr_asset_id,
		       depreciation_expense_ccid,
		       x_err_stage,
		       x_err_code);

                    SELECT pa_project_asset_line_det_s.nextval
                    INTO   proj_asset_line_detail_id
                    FROM sys.dual;
                curr_grouping_method:=cdlrec.grouping_method;
 	        description:= curr_grouping_method ;

            --Get Meaning from pa_lookups for Retirement Cost Type, populate Retirement Cost Type
            IF (x_line_type = 'R') THEN

                IF cdlrec.grouping_method = 'POS' THEN
                    v_retirement_cost_type := 'POS';
                ELSE
                    v_retirement_cost_type := 'COR';
                END IF;

                SELECT  meaning
                INTO    description
                FROM    pa_lookups
                WHERE   lookup_type = 'RETIREMENT_COST_TYPE'
                AND     lookup_code = cdlrec.grouping_method;

            END IF;

                    first_rec := FALSE;

                end if;
	        curr_asset_cost := NVL(cdlrec.cip_cost,0) + curr_asset_cost;


                -- create a detail line here
                   create_proj_asset_line_details
                      (cdlrec.expenditure_item_id,
                       cdlrec.line_num,
                       proj_asset_line_detail_id,
	               cdlrec.cip_cost,
	               'N',  -- Reversed_flag
                       x_err_stage,
		       x_err_code);

	   ELSE
                update_expenditure_items
                 (proj_asset_line_detail_id,
		  'Y',
                  x_err_stage,
                  x_err_code);

		-- we must create a new project asset line here

                create_project_asset_lines
                 (description,                  --x_description,
                  prev_asset_id,
                  x_project_id,
                  prev_grp_task_id,
                  prev_ccid,
                  depreciation_expense_ccid,  --x_asset_cost_ccid
                  prev_asset_cost,       -- original_asset_cost
                  prev_asset_cost,       -- current_asset_cost
                  proj_asset_line_detail_id,
                  SYSDATE,               --x_gl_date,
                  'P',                   --x_transfer_status_code,
	               NULL,                  --x_transfer_rejection_reason,
                  NULL,                  -- amortize_flag,
                  prev_asset_category_id,     --x_asset_category_id,
                  NULL,                  --x_rev_proj_asset_line_id,
	              NULL,                  --x_rev_from_proj_asset_line_id,
	              prev_invoice_num,
                  prev_vendor_number,
		         prev_po_vendor_id,
                  prev_po_number,
                  prev_invoice_date,
                  prev_invoice_created_by,
                  prev_invoice_updated_by,
                 -- prev_invoice_id,
                  prev_ref2, -- bug7428263
                  prev_payables_batch_name,
                  prev_ap_dist_line_number,
                  prev_ref3, -- bug7428263
		          --prev_ap_inv_dist_id, -- R12 new -- bug7428263
                  orig_asset_id,
                  x_line_type, --line_type,
                  prev_capital_event_id,
                  v_retirement_cost_type,
                  x_err_stage,
		          x_err_code);

                update_asset_cost
                 (prev_asset_id,
		  prev_asset_cost,
		  0,              --- capitalized_cost
                  x_err_stage,
                  x_err_code);

		-- also initialize the curr values here

                curr_asset_cost := nvl(cdlrec.cip_cost,0);
                curr_grouping_method:=cdlrec.grouping_method;
                description:= curr_grouping_method ;


            --Get Meaning from pa_lookups for Retirement Cost Type
            IF (x_line_type = 'R') THEN

                IF cdlrec.grouping_method = 'POS' THEN
                    v_retirement_cost_type := 'POS';
                ELSE
                    v_retirement_cost_type := 'COR';
                END IF;

                SELECT  meaning
                INTO    description
                FROM    pa_lookups
                WHERE   lookup_type = 'RETIREMENT_COST_TYPE'
                AND     lookup_code = cdlrec.grouping_method;

            END IF;

                -- get the attributes of the assets for which the
	        -- lines are to be created

                get_asset_attributes
		      (curr_asset_id,
		       depreciation_expense_ccid,
		       x_err_stage,
		       x_err_code);

                SELECT pa_project_asset_line_det_s.nextval
                INTO   proj_asset_line_detail_id
                FROM sys.dual;
		-- create a detail line here

                create_proj_asset_line_details
                      (cdlrec.expenditure_item_id,
                       cdlrec.line_num,
                       proj_asset_line_detail_id,
	               cdlrec.cip_cost,
	               'N',  -- Reversed_flag
                       x_err_stage,
		       x_err_code);

       END IF;
     -----------------------setting previous values
       prev_asset_id := curr_asset_id;
       prev_asset_cost := curr_asset_cost;
       prev_asset_category_id := curr_asset_category_id;
       prev_ccid := curr_ccid;
       prev_grp_task_id := curr_grp_task_id;
       prev_expend_cat := curr_expend_cat;
       prev_expend_type := curr_expend_type;
       prev_nlr := curr_nlr;
       prev_invoice_num := curr_invoice_num;
       prev_vendor_number := curr_vendor_number;
       prev_po_vendor_id := curr_po_vendor_id;
       prev_po_number := curr_po_number;
       prev_invoice_date := curr_invoice_date;
       prev_invoice_created_by := curr_invoice_created_by;
       prev_invoice_updated_by := curr_invoice_updated_by;
       --prev_invoice_id := curr_invoice_id;
       prev_ref2 := curr_ref2; -- bug7428263
       prev_payables_batch_name := curr_payables_batch_name;
       prev_ap_dist_line_number := curr_ap_dist_line_number;
       prev_ref3:= curr_ref3; -- bug7428263
       prev_ref4:= curr_ref4; -- bug7428263
       prev_inv_line_number := curr_inv_line_number; -- R12 new
      -- prev_ap_inv_dist_id := curr_ap_inv_dist_id; -- R12 new --bug 7428263
       prev_employee_id := curr_employee_id;
       prev_sys_link_fun := cdlrec.system_linkage_function;
       prev_capital_event_id := curr_capital_event_id;
     --------------------------

 end if;


 <<SKIP_NO_ACCOUNTS>>
 -- Added for bug : 4768332
        INSERT INTO pa_reporting_exceptions
                    (request_id,
                    context,
                    sub_context,
                    attribute1,  --project_id
                    attribute2,  --task_id
                    attribute3,  --expenditure_item_id
                    attribute4,  --expenditure_type
                    attribute5,  --line_num
                    attribute6,  --event_id
                    attribute7,  --amount
                    attribute8,  --rejection_code
                    attribute20  -- transaction_source
                     )
                VALUES
                    (x_request_id,
                    'GENERATE_PROJ_ASSET_LINES',
                    'NO_CC_ID',
            	    cdlrec.project_id,
                    cdlrec.task_id,
                    cdlrec.expenditure_item_id,
                    cdlrec.expenditure_type,
                    cdlrec.line_num,
                    cdlrec.ACCT_EVENT_ID,
                    cdlrec.cip_cost,
                    'PROJECT EVENT ERRORS',
                    cdlrec.transaction_source
                     );

  -- null;
 END LOOP;

     -- Create the asset line for the last cdl here

     IF ( NOT first_rec ) THEN
       -- mark the expenditure items revenue distributed_flag to 'Y'
       update_expenditure_items
                 (proj_asset_line_detail_id,
		  'Y',
                  x_err_stage,
                  x_err_code);

       create_project_asset_lines
                 (description,                  --description,
                  prev_asset_id,
                  x_project_id,
                  prev_grp_task_id,
                  prev_ccid,
                  depreciation_expense_ccid,  --x_asset_cost_ccid,
                  prev_asset_cost,       -- original_asset_cost
                  prev_asset_cost,       -- current_asset_cost
                  proj_asset_line_detail_id,
                  SYSDATE,               --x_gl_date,
                  'P',                   --x_transfer_status_code,
	              NULL,                  --x_transfer_rejection_reason,
                  NULL,                  -- amortize_flag,
                  prev_asset_category_id,--x_asset_category_id,
                  NULL,                  --x_rev_proj_asset_line_id,
	              NULL,                  --x_rev_from_proj_asset_line_id,
	              prev_invoice_num,
                  prev_vendor_number,
		          prev_po_vendor_id,
                  prev_po_number,
                  prev_invoice_date,
                  prev_invoice_created_by,
                  prev_invoice_updated_by,
                  --prev_invoice_id,
                  prev_ref2, -- 7428263
                  prev_payables_batch_name,
                  prev_ap_dist_line_number,
                  prev_ref3, -- 7428263
		          --prev_ap_inv_dist_id, -- R12 new -- 7428263
                  orig_asset_id,
                  x_line_type, --line_type,
                  prev_capital_event_id,
                  v_retirement_cost_type,
                  x_err_stage,
		          x_err_code);

       update_asset_cost
                 (prev_asset_id,
		  prev_asset_cost,
		  0,              --- capitalized_cost
                  x_err_stage,
                  x_err_code);
     END IF;

     EXCEPTION
       WHEN OTHERS THEN
	  x_err_code := SQLCODE;
	  RAISE;
   END generate_proj_asset_lines;

   -- The procedure given below marks the asset lines to be transferred
   -- to FA

   PROCEDURE mark_asset_lines_for_xfer
		( x_project_id              IN  NUMBER,
		  x_in_service_date_through IN  DATE,
                  x_line_type               IN  VARCHAR2,
		  x_rowcount             IN OUT NOCOPY NUMBER,
		  x_err_stage            IN OUT NOCOPY VARCHAR2,
		  x_err_code             IN OUT NOCOPY NUMBER)
   IS
        fa_install_status      VARCHAR2(1);
        x_rows_rejected        NUMBER;
   BEGIN

     x_err_code  := 0;
     x_err_stage := 'Marking project asset lines for transfer';

        UPDATE
	    pa_project_asset_lines pal
	SET
	    pal.transfer_status_code = 'X'
        WHERE
            pal.transfer_status_code||'' IN ('P','R')
        AND pal.project_id = x_project_id
        AND pal.line_type = x_line_type
        AND exists
	    (SELECT  null -- Update project asset lines belonging to new assets
	     FROM
		 pa_project_assets ppa
	     WHERE
                 ppa.project_id = pal.project_id
             AND ppa.project_asset_id = pal.project_asset_id
             AND
              (
                (ppa.capitalized_flag = 'N'
                 AND ppa.reverse_flag||'' = 'N'
                 AND TRUNC(ppa.date_placed_in_service) <=
                     TRUNC(NVL(x_in_service_date_through,
                             ppa.date_placed_in_service))
	        )
             OR
	       (-- Update project asset lines for the assets which were
                -- transferred to FA previously
                 ppa.capitalized_flag = 'Y'
                 AND ppa.reverse_flag||'' = 'N'
	         AND TRUNC(ppa.date_placed_in_service) <=
                     TRUNC(NVL(x_in_service_date_through,
                             ppa.date_placed_in_service))
                 AND pal.rev_proj_asset_line_id is null
               )
             OR
              ( ppa.capitalized_flag = 'Y'
                AND pal.rev_proj_asset_line_id is not null
              )
	    )
          );

        x_rowcount := SQL%ROWCOUNT;



     --obtain fa installation status
	fa_install_status := pa_asset_utils.fa_implementation_status;

	IF fa_install_status <> 'N' then
	-- perform check for if any asset belongs to future FA period

           reject_lines_check1 (x_rows_rejected,x_err_stage, x_err_code);

	   x_rowcount := x_rowcount - x_rows_rejected;
	END IF;
     EXCEPTION
       WHEN OTHERS THEN
	  x_err_code := SQLCODE;
	  RAISE;
   END mark_asset_lines_for_xfer;

   PROCEDURE mark_reversing_lines(x_project_id    IN  NUMBER,
                                x_capital_event_id IN  NUMBER,
                                x_line_type        IN  VARCHAR2,
		                        x_err_stage       IN OUT  NOCOPY VARCHAR2,
		                        x_err_code        IN OUT  NOCOPY NUMBER)
   IS
   BEGIN

     x_err_code     := 0;
     x_err_stage    := 'Marking reversing lines ';

     UPDATE
         pa_project_asset_lines  pal
     SET
         pal.transfer_status_code = 'X'
     WHERE pal.transfer_status_code||'' IN ('P','R')
     AND   rev_proj_asset_line_id is not null
     AND   pal.project_id = x_project_id
     AND   pal.capital_event_id = NVL(x_capital_event_id, pal.capital_event_id)
     AND   pal.line_type = x_line_type
        AND pal.project_asset_id IN
            (SELECT
                 ppa.project_asset_id
             FROM
                 pa_project_assets ppa
             WHERE
                 ppa.project_id = pal.project_id
             AND ppa.capitalized_flag = 'Y'
            );

     EXCEPTION
       WHEN OTHERS THEN
	 x_err_code := SQLCODE;
	 RAISE;
   END mark_reversing_lines;

   PROCEDURE update_asset_capitalized_flag
                 (x_project_asset_id          IN         NUMBER,
		  x_capitalized_flag          IN         VARCHAR2,
                  x_err_stage                 IN OUT     NOCOPY VARCHAR2,
                  x_err_code                  IN OUT     NOCOPY NUMBER)
   IS
   BEGIN

     x_err_code     := 0;
     x_err_stage    := 'Updating the asset status';

     UPDATE
	 pa_project_assets
     SET
	 capitalized_flag = x_capitalized_flag,
	 capitalized_date = sysdate,
         last_update_date = sysdate,
         last_updated_by = x_last_updated_by,
         last_update_login = x_last_update_login,
         request_id = x_request_id,
         program_application_id = x_program_application_id,
         program_id = x_program_id,
         program_update_date = sysdate
     WHERE
	 project_asset_id = x_project_asset_id;

     EXCEPTION
       WHEN OTHERS THEN
	 x_err_code := SQLCODE;
	 RAISE;
   END update_asset_capitalized_flag;

   PROCEDURE update_asset_adjustment_flag
                 (x_project_asset_id          IN         NUMBER,
		  x_adjustment_flag           IN         VARCHAR2,
		  x_adjustment_type	      IN	 VARCHAR2,
                  x_err_stage                 IN OUT     NOCOPY VARCHAR2,
                  x_err_code                  IN OUT     NOCOPY NUMBER)
   IS
   BEGIN

     x_err_code     := 0;
     x_err_stage    := 'Updating the asset status';

    IF x_adjustment_type = 'R' THEN
	--this is a reversing adjustment so do NOT update capitalized_date
       UPDATE
	 pa_project_assets
       SET
	cost_adjustment_flag = x_adjustment_flag,
	last_update_date = sysdate,
        last_updated_by = x_last_updated_by,
        last_update_login = x_last_update_login,
        request_id = x_request_id,
        program_application_id = x_program_application_id,
        program_id = x_program_id,
        program_update_date = sysdate
       WHERE
	 project_asset_id = x_project_asset_id;
    ELSE
	--this is a non-reversing adjustment.  Update capitalized_date
       UPDATE
         pa_project_assets
       SET
        cost_adjustment_flag = x_adjustment_flag,
        capitalized_date = sysdate,
        last_update_date = sysdate,
        last_updated_by = x_last_updated_by,
        last_update_login = x_last_update_login,
        request_id = x_request_id,
        program_application_id = x_program_application_id,
        program_id = x_program_id,
        program_update_date = sysdate
       WHERE
         project_asset_id = x_project_asset_id;
    END IF;


     EXCEPTION
       WHEN OTHERS THEN
	 x_err_code := SQLCODE;
	 RAISE;
   END update_asset_adjustment_flag;

   -- x_num_asset_found will return the number of assets found
   -- x_asset_id_in_FA is the asset_id in FA when the x_num_asset_found = 1
   -- otherwise it will be returned as NULL

   PROCEDURE check_asset_id_in_FA
                 (x_project_asset_id          IN         NUMBER,
		  x_asset_id_in_FA            IN OUT     NOCOPY NUMBER,
		  x_num_asset_found           IN OUT     NOCOPY NUMBER,
		  x_book_type_code	      IN	 VARCHAR2,
		  x_date_placed_in_service    IN OUT 	 NOCOPY DATE,
                  x_err_stage                 IN OUT     NOCOPY VARCHAR2,
                  x_err_code                  IN OUT     NOCOPY NUMBER)
   IS
   CURSOR selfaassets IS
   SELECT
	fai.asset_id
   FROM
	fa_asset_invoices fai,
	pa_project_asset_lines pal
   WHERE
	fai.project_asset_line_id = pal.project_asset_line_id
   AND  pal.project_asset_id = x_project_asset_id
   AND  pal.transfer_status_code||'' = 'T'
   GROUP BY
	fai.asset_id;

   faassetrec          selfaassets%ROWTYPE;
  -- Fix for bug : 4878878
  -- PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');

   v_fa_asset_id        PA_PROJECT_ASSETS_ALL.fa_asset_id%TYPE;


   BEGIN

     x_err_code     := 0;
     x_err_stage    := 'Finding the asset id in FA';

     x_asset_id_in_FA := NULL;
     x_num_asset_found  := 0;

     --The following code has been inserted to leverage the FA Tieback process.
     --This code looks for the FA_ASSET_ID on the Project Asset row, which is populated
     --if the project asset has been Tied Back.

     SELECT fa_asset_id
     INTO   v_fa_asset_id
     FROM   pa_project_assets_all
     WHERE  project_asset_id = x_project_asset_id;

     IF v_fa_asset_id IS NOT NULL THEN

        x_asset_id_in_FA := v_fa_asset_id;
        --Bug 3057423
        x_num_asset_found  := 1;

     ELSE

        --The following original code can be executed to determine the asset_id, since the
        --project asset has not been tied back



         FOR faassetrec IN selfaassets LOOP

        	x_num_asset_found := x_num_asset_found + 1;
            x_asset_id_in_FA  := faassetrec.asset_id;


            IF ( x_num_asset_found > 1 ) THEN

            	-- If more than one asset is found then return NULL x_asset_id_in_FA
	            x_asset_id_in_FA := NULL;
                x_date_placed_in_service := NULL;
                return;
            END IF;

         END LOOP;

         --  If no assets found then return
         if ( x_num_asset_found = 0 ) then
            return;
         end if;

    END IF;


	-- lookup the fa date placed in service
        -- Populate the Date placed in Service with the FA Open period Date

        BEGIN

          select GREATEST(fdp.calendar_period_open_date,
               LEAST(sysdate,fdp.calendar_period_close_date))
          into x_date_placed_in_service
          from fa_deprn_periods fdp
          where fdp.book_type_code = x_book_type_code
          and fdp.period_close_date is null;

        EXCEPTION
          WHEN NO_DATA_FOUND THEN
           IF G_debug_mode  = 'Y' THEN
              pa_debug.debug('check_asset_id_in_FA: ' || 'Current Deprn. Period not found for book : '||x_book_type_code);
           END IF;
           -- Initialised x_date_placed_in_service as NULL when deprn.
	   -- period is not found for book
           x_date_placed_in_service:=NULL;
        END;

     EXCEPTION
       WHEN OTHERS THEN
	 x_err_code := SQLCODE;
	 RAISE;
   END check_asset_id_in_FA;


   -- The procedure will reject the asset lines for the asset having
   -- the date_placed_in_service corresponding to a future date in FA
   -- This check need to be applied for new assets being transferred
   -- to FA

   PROCEDURE reject_lines_check1
		 (x_rows_rejected        IN OUT NOCOPY NUMBER,
		  x_err_stage            IN OUT NOCOPY VARCHAR2,
		  x_err_code             IN OUT NOCOPY NUMBER)
   IS

   transfer_rejection_reason   pa_lookups.meaning%TYPE;

   BEGIN

     x_err_code  := 0;
     x_err_stage := 'Applying Check1';

     -- Update project asset lines belonging to new assets

     UPDATE
	 pa_project_asset_lines pal
     SET
	 pal.transfer_status_code = 'R',
	 pal.transfer_rejection_reason = 'FUTURE_DPIS',
         pal.last_updated_by = x_last_updated_by,
         pal.last_update_date= sysdate,
         pal.created_by = x_created_by,
         pal.last_update_login = x_last_update_login,
         pal.request_id = x_request_id,
         pal.program_application_id = x_program_application_id,
         pal.program_id = x_program_id
     WHERE
         pal.transfer_status_code = 'X'
     AND exists
	    (SELECT
		 'Yes'
	     FROM
		 pa_project_assets ppa
	     WHERE
		 ppa.project_asset_id = pal.project_asset_id
             AND ppa.capitalized_flag = 'N'
             AND ppa.reverse_flag||'' = 'N'
             AND fa_mass_add_validate.valid_date_in_service(ppa.date_placed_in_service,ppa.book_type_code) = 0
	    );

     x_rows_rejected := SQL%ROWCOUNT;
     EXCEPTION
       WHEN OTHERS THEN
	  x_err_code := SQLCODE;
	  RAISE;
   END reject_lines_check1;

   PROCEDURE update_asset_lines
                 (x_proj_asset_line_id        IN     NUMBER,
		  x_transfer_rejection_reason IN     VARCHAR2,
		  x_transfer_status_code      IN     VARCHAR2,
		  x_amortize_flag             IN     VARCHAR2,
                  x_err_stage                 IN OUT NOCOPY VARCHAR2,
                  x_err_code                  IN OUT NOCOPY NUMBER)
   IS
   BEGIN

     x_err_code     := 0;
     x_err_stage    := 'Updating the project asset line';

       UPDATE
	   pa_project_asset_lines
       SET
	   transfer_rejection_reason = x_transfer_rejection_reason,
	   transfer_status_code = x_transfer_status_code,
	   amortize_flag = x_amortize_flag,
	   last_update_date = sysdate,
	   last_updated_by = x_last_updated_by,
	   last_update_login = x_last_update_login,
	   request_id = x_request_id,
	   program_application_id = x_program_application_id,
	   program_id = x_program_id,
	   program_update_date = sysdate
       WHERE
	   project_asset_line_id = x_proj_asset_line_id;

     EXCEPTION
       WHEN OTHERS THEN
	 x_err_code := SQLCODE;
	 RAISE;
   END update_asset_lines;

   -- Procedure to create mass addition lines

   PROCEDURE create_fa_mass_additions
             (x_accounting_date                  IN DATE,
              x_add_to_asset_id                  IN NUMBER,
              x_amortize_flag                    IN VARCHAR2,
              x_asset_category_id                IN NUMBER,
	      x_asset_key_ccid			 IN NUMBER,
              x_asset_number                     IN VARCHAR2,
              x_asset_type                       IN VARCHAR2,
              x_assigned_to                      IN NUMBER,
              x_book_type_code                   IN VARCHAR2,
              x_create_batch_date                IN DATE,
              x_create_batch_id                  IN NUMBER,
              x_date_placed_in_service           IN DATE,
              x_depreciate_flag                  IN VARCHAR2,
              x_description                      IN VARCHAR2,
              x_expense_code_combination_id      IN NUMBER,
              x_feeder_system_name               IN VARCHAR2,
              x_fixed_assets_cost                IN NUMBER,
              x_fixed_assets_units               IN NUMBER,
              x_location_id                      IN NUMBER,
              x_mass_addition_id             IN OUT NOCOPY NUMBER,
              x_merged_code                      IN VARCHAR2,
              x_merge_prnt_mass_additions_id     IN NUMBER,
              x_new_master_flag                  IN VARCHAR2,
              x_parent_mass_addition_id          IN NUMBER,
              x_payables_code_combination_id     IN NUMBER,
              x_payables_cost                    IN NUMBER,
              x_payables_units                   IN NUMBER,
              x_posting_status                   IN VARCHAR2,
              x_project_asset_line_id            IN NUMBER,
              x_project_id                       IN NUMBER,
              x_queue_name                       IN VARCHAR2,
              x_split_code                       IN VARCHAR2,
              x_split_merged_code                IN VARCHAR2,
              x_split_prnt_mass_additions_id     IN NUMBER,
              x_task_id                          IN NUMBER,
              x_invoice_number                IN VARCHAR2,
              x_vendor_number                 IN VARCHAR2,
              x_po_vendor_id                  IN NUMBER,
              x_po_number                     IN VARCHAR2,
              x_invoice_date                  IN DATE,
              x_invoice_created_by            IN NUMBER,
              x_invoice_updated_by            IN NUMBER,
              x_invoice_id                    IN NUMBER,
              x_payables_batch_name           IN VARCHAR2,
              x_ap_dist_line_number           IN Number,
              x_invoice_distribution_id       IN Number, -- R12 new
              x_parent_asset_id               IN NUMBER,
              x_manufacturer_name             IN VARCHAR2,
              x_model_number                  IN VARCHAR2,
              x_serial_number                 IN VARCHAR2,
              x_tag_number                    IN VARCHAR2,
	      x_err_stage                    IN OUT NOCOPY VARCHAR2,
	      x_err_code                     IN OUT NOCOPY NUMBER
             )
   IS
       x_inventorial_flag   VARCHAR2(3);
       l_amortization_start_date  DATE;
       -- Fix for bug : 4878878
       --PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');
       x_period_of_addition VARCHAR2(1);
       x_amort_flag         VARCHAR2(3);

   BEGIN

       x_err_code := 0;
       x_err_stage := 'Creating Mass addition Lines';
       x_amort_flag := x_amortize_flag;



       BEGIN
          -- Inventorial Flag is taken from FA_CATEGOIRES
          -- if the asset line is associated with asset category
          -- else insert 'YES' inot inventorial column of fa_mass_additions

          SELECT inventorial
            INTO x_inventorial_flag
            FROM fa_categories
           WHERE category_id = x_asset_category_id;

          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              x_inventorial_flag := 'YES';
       END ;

       -- Get the mass_additions_id

       SELECT
	  fa_mass_additions_s.nextval
       INTO
	  x_mass_addition_id
       FROM
	  SYS.DUAL;

       /*If this is a new asset */
     IF x_add_to_asset_id is NULL THEN
                                         x_amort_flag := Null;
                                         l_amortization_start_date := NULL;
        /* If asset is in period of addition */
     ELSIF FA_ASSET_VAL_PVT.validate_period_of_addition
                                        (p_asset_id => x_add_to_asset_id,
                                         p_book => x_book_type_code,
                                         p_mode => 'ABSOLUTE',
                                         px_period_of_addition => x_period_of_addition) THEN
                        IF nvl(x_period_of_addition,'N') = 'Y' THEN
                                 x_amort_flag := Null;
                                 l_amortization_start_date := NULL;
                        END IF;
     ELSE
        /* populating Amort flag based on the following logic */
       l_amortization_start_date := NULL;
       IF nvl(x_amort_flag,'NO')='YES' THEN    /*changed x_amortize_flag to x_amort_flag -bug4349574*/
       BEGIN
       SELECT
          GREATEST(fdp.calendar_period_open_date,LEAST(sysdate,fdp.calendar_period_close_date))
       INTO
          l_amortization_start_date
       FROM
          fa_deprn_periods fdp
       WHERE
          fdp.book_type_code = x_book_type_code
          and fdp.period_close_date is null;
       EXCEPTION
          WHEN NO_DATA_FOUND THEN
          IF G_debug_mode  = 'Y' THEN
             pa_debug.debug('create_fa_mass_additions: ' || 'Current Deprn. Period not found for book = '||x_book_type_code);
          END IF;
          l_amortization_start_date:= NULL;
       END;
       END IF;

     END IF;  /* bug 4349574 -End*/

-- Added by tiwang for CRL Projects
/* Bug 3224283. Restructured the code because of the data corruption that
   might occur if the profile option is incorrectly set.
   The strategy is to insert the records into fa_mass_additions irrespective
   of whether the profile option PA: Licensed to Use CRL Projects is set or not.
   And if it is set, update the CRL specific columns in IPAFAXB.pls
   Refer 3224283 and 3224294  */
/* Commented the following code for the above reason and added it after the
   insert into fa_mass_additions statement
       if (PA_INSTALL.is_product_installed('IPA'))  then   --CRL Installed
          PA_CRL_FAXFACE.create_crl_fa_mass_additions
             (x_accounting_date                  ,
              x_add_to_asset_id                  ,
              x_amortize_flag                    ,
              x_asset_category_id                ,
                x_asset_key_ccid                ,
              x_asset_number                     ,
              x_asset_type                       ,
              x_assigned_to                      ,
              x_book_type_code                   ,
              x_create_batch_date                ,
              x_create_batch_id                  ,
              x_date_placed_in_service           ,
              x_depreciate_flag                  ,
              x_description           ,
              x_expense_code_combination_id      ,
              x_feeder_system_name               ,
              x_fixed_assets_cost                ,
              x_fixed_assets_units               ,
              x_location_id                      ,
              x_mass_addition_id             ,
              x_merged_code                      ,
              x_merge_prnt_mass_additions_id     ,
              x_new_master_flag                  ,
              x_parent_mass_addition_id          ,
              x_payables_code_combination_id     ,
              x_payables_cost                    ,
              x_payables_units                   ,
              x_posting_status                   ,
              x_project_asset_line_id            ,
              x_project_id                       ,
              x_queue_name                       ,
              x_split_code                       ,
              x_split_merged_code                ,
              x_split_prnt_mass_additions_id     ,
              x_task_id                          ,
              x_inventorial_flag                     ,
              x_invoice_number                   ,
              x_vendor_number                 ,
              x_po_vendor_id                  ,
              x_po_number                     ,
              x_invoice_date                  ,
              x_invoice_created_by            ,
              x_invoice_updated_by            ,
              x_invoice_id                    ,
              x_payables_batch_name           ,
              x_ap_dist_line_number         ,
              x_invoice_distribution_id       , -- R12 new
              x_err_stage                    ,
              x_err_code                     );

       else
     Commented code for bug#3224283 ends here */
       INSERT INTO FA_MASS_ADDITIONS(
          ACCOUNTING_DATE,
          ADD_TO_ASSET_ID,
          AMORTIZE_FLAG,
          AMORTIZATION_START_DATE,  /* added for bug # 2540723 */
          ASSET_CATEGORY_ID,
	  ASSET_KEY_CCID,
          ASSET_NUMBER,
          ASSET_TYPE,
          ASSIGNED_TO,
          BOOK_TYPE_CODE,
          CREATED_BY,
          CREATE_BATCH_DATE,
          CREATE_BATCH_ID,
          CREATION_DATE,
          DATE_PLACED_IN_SERVICE,
          DEPRECIATE_FLAG,
          DESCRIPTION,
          EXPENSE_CODE_COMBINATION_ID,
          FEEDER_SYSTEM_NAME,
          FIXED_ASSETS_COST,
          FIXED_ASSETS_UNITS,
          LAST_UPDATED_BY,
          LAST_UPDATE_DATE,
          LAST_UPDATE_LOGIN,
          LOCATION_ID,
          MASS_ADDITION_ID,
          MERGED_CODE,
          MERGE_PARENT_MASS_ADDITIONS_ID,
          NEW_MASTER_FLAG,
          PARENT_MASS_ADDITION_ID,
          PAYABLES_CODE_COMBINATION_ID,
          PAYABLES_COST,
          PAYABLES_UNITS,
          POSTING_STATUS,
          PROJECT_ASSET_LINE_ID,
          PROJECT_ID,
          QUEUE_NAME,
          SPLIT_CODE,
          SPLIT_MERGED_CODE,
          SPLIT_PARENT_MASS_ADDITIONS_ID,
          TASK_ID,
          INVENTORIAL,
          invoice_number,
          vendor_number,
          po_vendor_id,
          po_number,
          invoice_date,
          invoice_created_by,
          invoice_updated_by,
          invoice_id,
          payables_batch_name,
          ap_distribution_line_number,
	  invoice_line_number,
          invoice_distribution_id, -- R12 new
          parent_asset_id,
          manufacturer_name,
          model_number,
          serial_number,
          tag_number
       )
       SELECT
          x_accounting_date,
          x_add_to_asset_id,
  /*      x_amortize_flag,   */
          x_amort_flag,     /*bug 4349574*/
          l_amortization_start_date,  /* bug#2540723 */
          x_asset_category_id,
          x_asset_key_ccid,
          x_asset_number,
          x_asset_type,
          x_assigned_to,
          x_book_type_code,
          x_created_by,
          x_create_batch_date,
          x_create_batch_id,
          SYSDATE,
          x_date_placed_in_service,
          x_depreciate_flag,
          -- Commented for bug 5408702 substr(x_description,1,80),  Substr included for bug# 1607527
          rtrim(substrb(x_description,1,80)), -- rtrim and Substrb included for bug#  5408702
          x_expense_code_combination_id,
          x_feeder_system_name,
          x_fixed_assets_cost,
          x_fixed_assets_units,
          x_last_updated_by,
          SYSDATE,
          x_last_update_login,
          x_location_id,
          x_mass_addition_id,
          x_merged_code,
          x_merge_prnt_mass_additions_id,
          x_new_master_flag,
          x_parent_mass_addition_id,
          x_payables_code_combination_id,
          x_payables_cost,
          x_payables_units,
          x_posting_status,
          x_project_asset_line_id,
          x_project_id,
          x_queue_name,
          x_split_code,
          x_split_merged_code,
          x_split_prnt_mass_additions_id,
          x_task_id,
          x_inventorial_flag,
          x_invoice_number,
          x_vendor_number,
          x_po_vendor_id,
          x_po_number,
          x_invoice_date,
          x_invoice_created_by,
          x_invoice_updated_by,
          x_invoice_id,
          x_payables_batch_name,
          x_ap_dist_line_number,
          NULL,     -- invoice_line_number,
          x_invoice_distribution_id, -- R12 new
          x_parent_asset_id,
          x_manufacturer_name,
          x_model_number,
          x_serial_number,
          x_tag_number
       FROM SYS.DUAL;

    /* Bug#3224283. Added Call to pa_crl_faxface after inserting the
       record into fa_mass_additions */
       if (PA_INSTALL.is_product_installed('IPA'))  then   --CRL Installed
          PA_CRL_FAXFACE.create_crl_fa_mass_additions
             (x_accounting_date                  ,
              x_add_to_asset_id                  ,
     /*       x_amortize_flag                    ,  */
              x_amort_flag                       ,  /*bug 4349574 */
              x_asset_category_id                ,
                x_asset_key_ccid                ,
              x_asset_number                     ,
              x_asset_type                       ,
              x_assigned_to                      ,
              x_book_type_code                   ,
              x_create_batch_date                ,
              x_create_batch_id                  ,
              x_date_placed_in_service           ,
              x_depreciate_flag                  ,
              rtrim(substrb(x_description,1,80)) ,  /* Added for bug 5408702 */
              x_expense_code_combination_id      ,
              x_feeder_system_name               ,
              x_fixed_assets_cost                ,
              x_fixed_assets_units               ,
              x_location_id                      ,
              x_mass_addition_id             ,
              x_merged_code                      ,
              x_merge_prnt_mass_additions_id     ,
              x_new_master_flag                  ,
              x_parent_mass_addition_id          ,
              x_payables_code_combination_id     ,
              x_payables_cost                    ,
              x_payables_units                   ,
              x_posting_status                   ,
              x_project_asset_line_id            ,
              x_project_id                       ,
              x_queue_name                       ,
              x_split_code                       ,
              x_split_merged_code                ,
              x_split_prnt_mass_additions_id     ,
              x_task_id                          ,
              x_inventorial_flag                     ,
              x_invoice_number                   ,
              x_vendor_number                 ,
              x_po_vendor_id                  ,
              x_po_number                     ,
              x_invoice_date                  ,
              x_invoice_created_by            ,
              x_invoice_updated_by            ,
              x_invoice_id                    ,
              x_payables_batch_name           ,
              --x_ap_dist_line_number           , Send invoice_distribution_id instead.
              x_invoice_distribution_id       , -- R12 new.
              x_err_stage                    ,
              x_err_code                     );
       end if;  /* If CRL Installed */

       IF l_mrc_flag = 'Y' THEN
	       create_alc_fa_mass_additions (x_project_asset_line_id => x_project_asset_line_id,
					     x_mass_addition_id => x_mass_addition_id,
					     x_parent_mass_addition_id => x_parent_mass_addition_id,
					     x_fixed_assets_cost => x_fixed_assets_cost);
       END IF;

    EXCEPTION
       WHEN OTHERS THEN
       x_err_code := SQLCODE;
       RAISE;
   END create_fa_mass_additions;

   -- Procedure for transferring asset lines
   -- The paramater x_asset_type can have the following values:
   --         'N' -- New asset being transferred for the first time
   --         'O' -- An old asset for which lines were already sent to FA
   --                and send cost adjustment for these assets
   --	      'R' -- An asset being reversed

   --  x_reversed_line_flag is not required when x_asset_type = 'N'

   PROCEDURE interface_asset_lines
		( x_project_id              IN  NUMBER,
                  x_asset_type              IN  VARCHAR2,
		  x_in_service_date_through IN  DATE,
		  x_reversed_line_flag      IN  VARCHAR2,
		  x_err_stage            IN OUT NOCOPY VARCHAR2,
		  x_err_code             IN OUT NOCOPY NUMBER)
   IS
   CURSOR selassetlines IS
   SELECT
       ppa.project_id,
       ppa.project_asset_id,
       pal.cip_ccid,
       pal.asset_cost_ccid,
       ppa.asset_number,
       ppa.asset_name,
       ppa.asset_description,
       ppa.location_id,
       ppa.assigned_to_person_id,
       ppa.date_placed_in_service,
       ppa.asset_category_id,
       ppa.asset_key_ccid,
       ppa.book_type_code,
       ppa.asset_units,
       decode(ppa.depreciate_flag,'Y','YES','N','NO') depreciate_flag,
       ppa.depreciation_expense_ccid,
       decode(ppa.amortize_flag, 'Y','YES','N','NO') amortize_flag,
       ppa.amortize_flag single_char_amortize_flag,
       ppa.cost_adjustment_flag,
       ppa.capitalized_flag,
       ppa.reverse_flag,
       decode(nvl(ppa.new_master_flag,'N'),'Y','YES','N','NO') new_master_flag, -- Bug 5435551
       pal.project_asset_line_id,
       pal.project_asset_line_detail_id detail_id,
       pal.rev_proj_asset_line_id,
       pal.description,
       pal.task_id,
       pal.current_asset_cost,
       pal.gl_date,
       ppt.interface_complete_asset_flag,
       ppt.vendor_invoice_grouping_code,
       pal.invoice_number,
       pal.vendor_number,
       pal.po_vendor_id,
       pal.po_number,
       pal.invoice_date,
       pal.invoice_created_by,
       pal.invoice_updated_by,
       pal.invoice_id,
       pal.payables_batch_name,
       pal.ap_distribution_line_number,
       pal.invoice_distribution_id, -- R12 new
       ppa.parent_asset_id,
       ppa.manufacturer_name,
       ppa.model_number,
       ppa.serial_number,
       ppa.tag_number
   FROM
       pa_project_asset_lines pal,
       pa_project_assets ppa,
       pa_projects pp,
       pa_project_types ppt
   WHERE
       pal.project_asset_id = ppa.project_asset_id
   AND ppa.project_id = pp.project_id
   AND ppa.project_id = x_project_id
   AND pp.project_type = ppt.project_type
   AND pal.transfer_status_code = 'X'
   AND pal.line_type = 'C'
   ORDER BY                       --- These order by is very important
       DECODE(ppt.vendor_invoice_grouping_code,'N',ppa.project_asset_id||pal.ap_distribution_line_number,ppa.project_asset_id),
       pal.cip_ccid,
       pal.asset_cost_ccid;

   assetlinerec             selassetlines%ROWTYPE;
-- R12 changes. Table pa_gl_interface is obsolete. This check is left for
-- asset lines which are not yet interfaced to FA before uptake of R12.
CURSOR un_gl_xferred_cdls (x_detail_id IN NUMBER) IS
        select 'X'
        from pa_project_asset_line_details d,
                pa_cost_distribution_lines_all cdl
        where d.PROJECT_ASSET_LINE_DETAIL_ID = x_detail_id and
                d.expenditure_item_id = cdl.expenditure_item_id and
                d.line_num = cdl.line_num and
				(
                cdl.transfer_status_code in  ('P','R','X','T')
				/* -- R12 change..pa_gl_interface is obsolete.
				OR
				Exists ( Select 'X' From Pa_Gl_Interface GL
				          Where GL.Reference26 = cdl.batch_name
						    And Cdl.transfer_status_code = 'A'
					   )
			        */
			    );


  un_gl_rec		un_gl_xferred_cdls%ROWTYPE;

   --Table used by to cache the results of queries
   --against the pa_cost_distribution_line table.
   Type NumTabType IS
        Table of Number
        Index by binary_integer;

   detail_cdl_xfer_cache        NumTabType;

   x_rowcount               NUMBER;
   x_rows_rejected          NUMBER;
   l_asset_type             VARCHAR2(1);
   curr_project_asset_id    NUMBER;
   curr_asset_cost_ccid     NUMBER;
   curr_cip_ccid            NUMBER;
   curr_add_to_asset_id     NUMBER;
   curr_add_to_asset_flag   BOOLEAN;

   num_asset_found_in_fa    NUMBER;
   new_asset_flag           BOOLEAN;
   line_okay_for_interface  BOOLEAN;
   asset_okay_for_interface BOOLEAN;
   curr_new_master_flag     VARCHAR2(3);
   fa_install_status        VARCHAR2(1);
   fa_posted_count	    NUMBER;
   fa_date_placed_in_service	DATE;

   -- columns for FA_MASS_ADDITIONS

   mass_addition_id              NUMBER;
   parent_mass_addition_id       NUMBER;
   posting_status                fa_mass_additions.posting_status%TYPE;
   queue_name			 fa_mass_additions.queue_name%TYPE;
   create_merged_line            BOOLEAN;
   merge_code                    VARCHAR2(2);
   merged_cost                   pa_project_asset_lines.current_asset_cost%type;
   req_flag                      varchar2(1);
   keynumber                     fa_system_controls.asset_key_flex_structure%type;

   l_amortize_flag               varchar2(10); -- bug 4508689
   l_depreciation_expense_ccid   NUMBER;


       -- Fix for bug : 4878878
     -- PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');

   BEGIN

      begin
      Select ASSET_KEY_FLEX_STRUCTURE into keynumber
       from  FA_SYSTEM_CONTROLS;
       exception when no_data_found then
        null;
      end;
      req_flag := check_required_segment(keynumber);

     x_err_code  := 0;
     x_err_stage := 'Interfacing project asset lines';

     curr_project_asset_id := -1;


     FOR assetlinerec IN selassetlines LOOP

        /*  Automatic asset capitalization changes JPULTORAK 04-FEB-2003 */
        --Initialize this value to prepare for override of the ccid via client extension
        l_depreciation_expense_ccid := assetlinerec.depreciation_expense_ccid;
        /*  End of Automatic asset capitalization changes */

        /*dbms_output.put_line('Asset Id = ' ||
	  to_char(assetlinerec.project_asset_id) || ' Line Id = ' ||
        to_char(assetlinerec.project_asset_line_id)); */

	--this section of code checks that cip cost has been transferred
	--to GL for the asset line.  It is not in a separate procedure
	--because placing it there kept causing a signal 11 error.
	/************************************************************/
        BEGIN
	--this will raise a no_data_found exception if the
    	--detail id hasn't been checked and results cached before.
    	--The cache is most useful when lines have been split
    	IF detail_cdl_xfer_cache(assetlinerec.detail_id) = 1 THEN
       		line_okay_for_interface := TRUE;
    	ELSE
       		line_okay_for_interface := FALSE;
    	END IF;
  	EXCEPTION
  	WHEN no_data_found THEN
    	  open un_gl_xferred_cdls (assetlinerec.detail_id);
    	  fetch un_gl_xferred_cdls into un_gl_rec;
    	  IF un_gl_xferred_cdls%NOTFOUND THEN
        	line_okay_for_interface := TRUE;
        	detail_cdl_xfer_cache(assetlinerec.detail_id) := 1;
    	  ELSE
        	line_okay_for_interface := FALSE;
        	detail_cdl_xfer_cache(assetlinerec.detail_id) := 0;
    	  END IF;
    	  close un_gl_xferred_cdls;
	END;

	IF (line_okay_for_interface = FALSE) then
	  update_asset_lines
                (assetlinerec.project_asset_line_id,
                'CIP_NOT_XFERD_TO_GL',
                'R',
                NULL,
                x_err_stage,
                x_err_code);

	  goto next_line;
      	END IF;
	/*************************************************************/


           create_merged_line := TRUE;
	IF ( curr_project_asset_id <> assetlinerec.project_asset_id OR (assetlinerec.vendor_invoice_grouping_code = 'N' and assetlinerec.invoice_id is not null)) THEN

	   -- new project_asset_id
	   new_asset_flag := TRUE;
	   curr_project_asset_id  := assetlinerec.project_asset_id;

	ELSE
	   new_asset_flag := FALSE;
	END IF;
      IF (assetlinerec.vendor_invoice_grouping_code = 'N' and assetlinerec.invoice_id is not null) then
           create_merged_line := FALSE;
      end if;

   IF ( assetlinerec.capitalized_flag = 'N' AND assetlinerec.reverse_flag = 'N'
        AND TRUNC(assetlinerec.date_placed_in_service) <=
                 TRUNC(NVL(x_in_service_date_through,assetlinerec.date_placed_in_service))) THEN

        l_asset_type := 'N';

   ELSIF ( assetlinerec.capitalized_flag = 'Y' AND assetlinerec.reverse_flag = 'N'
             AND assetlinerec.rev_proj_asset_line_id is null
             AND TRUNC(assetlinerec.date_placed_in_service) <=
                 TRUNC(NVL(x_in_service_date_through,assetlinerec.date_placed_in_service))) THEN

        l_asset_type  := 'O';

   ELSIF (assetlinerec.capitalized_flag = 'Y' AND assetlinerec.rev_proj_asset_line_id is not null) THEN

        l_asset_type  := 'R';

   END IF;
---------------------------------------
   If (l_asset_type = 'O' and assetlinerec.vendor_invoice_grouping_code = 'N' and assetlinerec.invoice_id is not null) then
	l_asset_type := 'N';
   END IF;
----------------------------------------
	IF (l_asset_type = 'N') THEN

       /*  Automatic asset capitalization changes JPULTORAK 04-FEB-03 */

       -- Call procedure to derive/default Depreciation Expense CCID via Client Extension.
       -- This procedure is ONLY called if Book Type Code and Asset Category ID are populated.
       -- The procedure will either return the current depreciation expense ccid on assetlinerec,
       -- or it will return a new value if it has been successfully overridden by the client
       -- extension with a valid value.  The project asset is updated with the new CCID value
       -- when a successful override occurs.

       IF assetlinerec.book_type_code IS NOT NULL AND assetlinerec.asset_category_id IS NOT NULL THEN

           get_depreciation_expense(x_project_asset_id       => assetlinerec.project_asset_id,  /* 3368494 */
                                    x_book_type_code         => assetlinerec.book_type_code,
                                    x_asset_category_id      => assetlinerec.asset_category_id,
                                    x_date_placed_in_service => assetlinerec.date_placed_in_service,
                                    x_in_deprn_expense_ccid  => assetlinerec.depreciation_expense_ccid,
                                    x_out_deprn_expense_ccid => l_depreciation_expense_ccid,
                                    x_err_stage              => x_err_stage,
                                    x_err_code               => x_err_code);

           IF G_debug_mode  = 'Y' THEN
              pa_debug.debug('interface assets: ' || 'In CCID = '||assetlinerec.depreciation_expense_ccid ||
                                                     ' Out CCID = ' || l_depreciation_expense_ccid);
           END IF;

           --Downstream processing will now be based on l_depreciation_expense_ccid instead of
           --assetlinerec.depreciation_expense_ccid

       END IF;

       /*  End of Automatic asset capitalization changes */



	   -- Process the new asset lines

	   IF (new_asset_flag = TRUE) THEN

	      -- perform the check for complete asset information
	      asset_okay_for_interface := TRUE;

	      IF ( assetlinerec.book_type_code IS NULL
				   OR
		   assetlinerec.asset_category_id IS NULL
				   OR
		   assetlinerec.asset_units IS NULL
				   OR
		   assetlinerec.location_id IS NULL
				   OR
           assetlinerec.depreciate_flag IS NULL
				   OR
                   (assetlinerec.asset_key_ccid is null and req_flag='Y')
                                   OR
/*  Automatic asset capitalization changes JPULTORAK 04-FEB-03 */
-- replacing this line with l_depreciation_expense_ccid in order to process the override value
--           assetlinerec.depreciation_expense_ccid IS NULL)
		   l_depreciation_expense_ccid IS NULL)
/*  End of Automatic asset capitalization changes */
           THEN

		   posting_status := 'NEW';
		   queue_name := 'NEW';
		   IF (assetlinerec.interface_complete_asset_flag = 'Y') THEN
		   	asset_okay_for_interface := FALSE;
		   END IF;
 	       ELSE
                   posting_status := 'POST';
		   queue_name := 'POST';
	       END IF;

	      IF (asset_okay_for_interface) THEN
	        -- also update the assets status as capitalized
                update_asset_capitalized_flag
                   (curr_project_asset_id,
		    'Y',
                    x_err_stage,
                    x_err_code);

	        -- Send a header line for the asset
------saima
                  if create_merged_line = TRUE then
                          merged_cost := 0;
                          merge_code  := 'MP';
                  else
                          merged_cost := assetlinerec.current_asset_cost;
                          merge_code  := NULL;
                  end if;
------endsaima

                create_fa_mass_additions
                   (sysdate,                         --x_accounting_date,
                    NULL,                            --x_add_to_asset_id,
                    assetlinerec.amortize_flag,
                    assetlinerec.asset_category_id,
		    assetlinerec.asset_key_ccid,
                    assetlinerec.asset_number,
                    'CAPITALIZED',                   --x_asset_type,
                    assetlinerec.assigned_to_person_id,
                    assetlinerec.book_type_code,
                    NULL,                            --x_create_batch_date,
                    NULL,                            --x_create_batch_id,
                    assetlinerec.date_placed_in_service,
                    assetlinerec.depreciate_flag,
                    assetlinerec.asset_description,
                    /*  Automatic asset capitalization changes JPULTORAK 04-FEB-03 */
                    -- replacing this line with l_depreciation_expense_ccid in order to process the override value
                    --assetlinerec.depreciation_expense_ccid,
                    l_depreciation_expense_ccid,
                    /*  End of Automatic asset capitalization changes */
                    'ORACLE PROJECTS',     -- feeder_system_name
                    merged_cost,                     -- x_fixed_assets_cost,
                    assetlinerec.asset_units,        -- x_fixed_assets_units,
                    assetlinerec.location_id,
                    mass_addition_id,                -- x_mass_addition_id
                    merge_code,                      -- x_merged_code,
                    NULL,                            -- x_merge_prnt_mass_additions_id,
                    NULL,                            -- x_new_master_flag,
                    NULL,                            -- x_parent_mass_addition_id,
                    assetlinerec.cip_ccid,           -- payables_code_combination_id,
                    merged_cost,                     -- x_payables_cost Bug 1709239
                    assetlinerec.asset_units,        -- x_payables_units,
                    posting_status,                  -- x_posting_status,
                    assetlinerec.project_asset_line_id,
                    assetlinerec.project_id,
                    queue_name,                      -- x_queue_name,
                    NULL,                            -- x_split_code,
                    merge_code,                      -- x_split_merged_code,
                    NULL,                            -- x_split_prnt_mass_additions_id,
                    assetlinerec.task_id,
                    assetlinerec.invoice_number,
                    assetlinerec.vendor_number,
                    assetlinerec.po_vendor_id,
                    assetlinerec.po_number,
                    assetlinerec.invoice_date,
                    assetlinerec.invoice_created_by,
                    assetlinerec.invoice_updated_by,
                    assetlinerec.invoice_id,
                    assetlinerec.payables_batch_name,
                    assetlinerec.ap_distribution_line_number,
                    assetlinerec.invoice_distribution_id, -- R12 new
                    assetlinerec.parent_asset_id,
                    assetlinerec.manufacturer_name,
                    assetlinerec.model_number,
                    assetlinerec.serial_number,
                    assetlinerec.tag_number,
	            x_err_stage,
	            x_err_code);
		    parent_mass_addition_id := mass_addition_id;

		END IF;

	   END IF;

	   --create_fa_mass_addition for new line

	   IF(asset_okay_for_interface and create_merged_line = TRUE) THEN

              create_fa_mass_additions
                 (sysdate,                         --x_accounting_date,
                  NULL,                            --x_add_to_asset_id,
                  assetlinerec.amortize_flag,
                  assetlinerec.asset_category_id,
		  assetlinerec.asset_key_ccid,
                  NULL,				   --asset_number,
                  'CAPITALIZED',                   --x_asset_type,
                  assetlinerec.assigned_to_person_id,
                  assetlinerec.book_type_code,
                  NULL,                            --x_create_batch_date,
                  NULL,                            --x_create_batch_id,
                  assetlinerec.date_placed_in_service,
                  assetlinerec.depreciate_flag,
                  assetlinerec.description,
                  l_depreciation_expense_ccid,
                  'ORACLE PROJECTS',     -- feeder_system_name
                  assetlinerec.current_asset_cost, -- x_fixed_assets_cost,
                  assetlinerec.asset_units,        -- x_fixed_assets_units,
                  assetlinerec.location_id,
                  mass_addition_id,                -- x_mass_addition_id
                  'MC',                            -- x_merged_code,
                  parent_mass_addition_id,         -- x_merge_prnt_mass_additions_id,
                  NULL,                            -- x_new_master_flag,
                  parent_mass_addition_id,         -- x_parent_mass_addition_id,
                  assetlinerec.cip_ccid,           -- payables_code_combination_id,
                  assetlinerec.current_asset_cost, -- x_payables_cost,
                  0,                               -- x_payables_units,
                  'MERGED',                        -- x_posting_status,
                  assetlinerec.project_asset_line_id,
                  assetlinerec.project_id,
                  'NEW',                           -- x_queue_name,
                  NULL,                            -- x_split_code,
                  'MC',                            -- x_split_merged_code,
                  NULL,                            -- x_split_prnt_mass_additions_id,
                  assetlinerec.task_id,
                  assetlinerec.invoice_number,
                  assetlinerec.vendor_number,
                  assetlinerec.po_vendor_id,
                  assetlinerec.po_number,
                  assetlinerec.invoice_date,
                  assetlinerec.invoice_created_by,
                  assetlinerec.invoice_updated_by,
                  assetlinerec.invoice_id,
                  assetlinerec.payables_batch_name,
                  assetlinerec.ap_distribution_line_number,
                  assetlinerec.invoice_distribution_id, -- R12 new
                  assetlinerec.parent_asset_id,
                  assetlinerec.manufacturer_name,
                  assetlinerec.model_number,
                  assetlinerec.serial_number,
                  assetlinerec.tag_number,
                  /*  End of Automatic asset capitalization changes */
	          x_err_stage,
	          x_err_code);
            END IF;

	 -- complete information about the Asset could not be found in PA
	 -- reject the line
            IF (not(asset_okay_for_interface)) then
                 update_asset_lines
                        (assetlinerec.project_asset_line_id,
		         'ASSET_NOT_COMPLETE',
		         'R',
		         NULL,
                         x_err_stage,
		         x_err_code);

		  goto next_line;

	    END IF;

	ELSIF (l_asset_type IN ('O','R') OR x_asset_type = 'R') THEN

	   -- Process the adjustments
	   IF (new_asset_flag = TRUE) THEN

	      l_amortize_flag := assetlinerec.amortize_flag; -- bug 4508689
	      fa_date_placed_in_service := assetlinerec.date_placed_in_service;
     --obtain fa installation status
	      fa_install_status := pa_asset_utils.fa_implementation_status;
 	      IF fa_install_status = 'N' THEN
		 curr_add_to_asset_id := NULL;
		 BEGIN
		   SELECT '1'
		   INTO fa_posted_count
		   FROM DUAL
		   WHERE EXISTS (SELECT mass_addition_id
				FROM fa_mass_additions
				WHERE asset_number = assetlinerec.asset_number AND
		 		posting_status = 'POSTED');
		   asset_okay_for_interface := TRUE;
		 EXCEPTION
		   WHEN NO_DATA_FOUND THEN
		     asset_okay_for_interface := FALSE;
		 END;
	      ELSE
	         -- find out the asset_id in FA for the this asset_id
                 check_asset_id_in_FA
                    (curr_project_asset_id,
		    curr_add_to_asset_id,
		    num_asset_found_in_fa,
		    assetlinerec.book_type_code,
		    fa_date_placed_in_service,
                    x_err_stage,
		    x_err_code);

	         IF (num_asset_found_in_fa = 0 ) THEN
		    asset_okay_for_interface := FALSE;
	         ELSIF(num_asset_found_in_fa = 1) AND (fa_date_placed_in_service IS NULL) THEN /*Bug#1701857*/
		    asset_okay_for_interface := FALSE; /*Bug#1701857*/
                    ELSE
		    asset_okay_for_interface := TRUE;
	         END IF;
	       END IF;

	      IF ( asset_okay_for_interface ) THEN

		 -- By default the adjustments will be placed in the NEW queue

		 posting_status := 'NEW';
		 queue_name := 'NEW';

	         -- Also check if this asset is eligible for taking
	         -- cost adjustment
		 IF ( curr_add_to_asset_id IS NOT NULL ) THEN

		    IF(fa_mass_add_validate.can_add_to_asset
			     (curr_add_to_asset_id,assetlinerec.book_type_code) = 0 ) THEN

			asset_okay_for_interface := FALSE;
			curr_add_to_asset_flag   := FALSE;
		    ELSE
			curr_add_to_asset_flag   := TRUE;
			asset_okay_for_interface := TRUE;
			-- Put the adjustments in the COST ADJUSTMENT queue
		        posting_status           := 'POST';
			queue_name := 'ADD TO ASSET';
		    END IF;

                    /* Added code for Bug#3552809 -- Begin */
		    /* If asset in FA cannot be expensed and it allows amortization of adjustments
		       then set the amortize_flag to 'Y' even if the corresponding asset in
		       PA does not have 'amortize adjustments' checked. Else pass the value what
		       ever is set at the asset level in PA */
                    IF NOT FA_ASSET_VAL_PVT.validate_exp_after_amort(curr_add_to_asset_id,
		                                 assetlinerec.book_type_code) THEN
                     pa_debug.debug('Asset in FA cannot be expensed '||curr_add_to_asset_id);
                     assetlinerec.amortize_flag := 'YES';
		     l_amortize_flag := 'YES'; -- bug 4508689
                    END IF;
                    /* Added code for Bug#3552809 -- End */

		 END IF;

	      END IF;

	      curr_new_master_flag := 'YES';

	      IF (asset_okay_for_interface ) THEN

                 update_asset_adjustment_flag
                      (curr_project_asset_id,
		       'Y',
		       x_asset_type,
                       x_err_stage,
                       x_err_code);

	      END IF;

           /* Bug #4508689: Added the following ELSE and stamping the amortize flag on other lines
	      also even if the new_asset_flag is FALSE.
	      Derivation of the amortize flag is being done when new_asset_flag is TRUE as this needs
	      to be done only once for an asset. But we will have to stamp it on all the Cost Adjusting
	      Lines which are being interfaced for this Asset. */

	   ELSE

              /* Also check if this asset is eligible for taking cost adjustment */
	      IF ( curr_add_to_asset_id IS NOT NULL ) THEN
                 assetlinerec.amortize_flag := l_amortize_flag;
	      END IF;

	   END IF;

	   IF (asset_okay_for_interface) THEN

	      -- Send the new master flag only on one line per asset

	      IF (NOT(new_asset_flag AND assetlinerec.new_master_flag = 'YES'))
		THEN
		  curr_new_master_flag := 'NO';
	      END IF;

	      -- Send this project asset line to FA as an adjustment
              create_fa_mass_additions
                 (sysdate,                         --x_accounting_date,
                  curr_add_to_asset_id,            --x_add_to_asset_id,
                  assetlinerec.amortize_flag,
                  assetlinerec.asset_category_id,
		  assetlinerec.asset_key_ccid,
                  NULL,				  --assetlinerec.asset_number,
                  'CAPITALIZED',                   --x_asset_type,
                  assetlinerec.assigned_to_person_id,
                  assetlinerec.book_type_code,
                  NULL,                            --x_create_batch_date,
                  NULL,                            --x_create_batch_id,
                  fa_date_placed_in_service,
                  assetlinerec.depreciate_flag,
                  assetlinerec.description,
                  /*  Automatic asset capitalization changes JPULTORAK 04-FEB-03 */
                  -- replacing this line with l_depreciation_expense_ccid in order to process the override value
                  --assetlinerec.depreciation_expense_ccid,
                  l_depreciation_expense_ccid,
                  /*  End of Automatic asset capitalization changes */
                  'ORACLE PROJECTS',            -- feeder_system_name
                  assetlinerec.current_asset_cost, -- x_fixed_assets_cost,
                  assetlinerec.asset_units,        -- x_fixed_assets_units,
                  assetlinerec.location_id,
                  mass_addition_id,                -- x_mass_addition_id
                  NULL,                            -- x_merged_code,
                  NULL,                            -- x_merge_prnt_mass_additions_id,
                  curr_new_master_flag,            -- x_new_master_flag,
                  NULL,                            -- x_parent_mass_addition_id,
                  assetlinerec.cip_ccid,           -- payables_code_combination_id,
                  assetlinerec.current_asset_cost, -- x_payables_cost,
                  assetlinerec.asset_units,        -- x_payables_units,
                  posting_status,                  -- x_posting_status,
                  assetlinerec.project_asset_line_id,
                  assetlinerec.project_id,
                  queue_name,                      -- x_queue_name,
                  NULL,                            -- x_split_code,
                  NULL,                            -- x_split_merged_code,
                  NULL,                            -- x_split_prnt_mass_additions_id,
                  assetlinerec.task_id,
                  assetlinerec.invoice_number,
                  assetlinerec.vendor_number,
                  assetlinerec.po_vendor_id,
                  assetlinerec.po_number,
                  assetlinerec.invoice_date,
                  assetlinerec.invoice_created_by,
                  assetlinerec.invoice_updated_by,
                  assetlinerec.invoice_id,
                  assetlinerec.payables_batch_name,
                  assetlinerec.ap_distribution_line_number,
                  assetlinerec.invoice_distribution_id, -- R12 new
                  assetlinerec.parent_asset_id,
                  assetlinerec.manufacturer_name,
                  assetlinerec.model_number,
                  assetlinerec.serial_number,
                  assetlinerec.tag_number,
	          x_err_stage,
	          x_err_code);

	   ELSE

	      -- reject this line
	      IF (num_asset_found_in_fa = 0 ) THEN

		 -- Asset could not be found in FA for the asset in PA
                 update_asset_lines
                        (assetlinerec.project_asset_line_id,
		         'ASSET_NOT_POSTED',
		         'R',
		         NULL,
                         x_err_stage,
		         x_err_code);
/*For Bug# 1701857:To raise exception when fa_date_placed_in_service is NULL)*/
              ELSIF(num_asset_found_in_fa =1) AND (fa_date_placed_in_service IS NULL) THEN
                   update_asset_lines
                        (assetlinerec.project_asset_line_id,
		         'DEPRN_NOT_FOUND',
		         'R',
		         NULL,
                         x_err_stage,
		         x_err_code);
/*Changes over for Bug# 1701857*/
	         ELSIF (  NOT curr_add_to_asset_flag ) THEN
		 -- this asset can not be adjusted any more in FA
                 update_asset_lines
                        (assetlinerec.project_asset_line_id,
		         'ASSET_NOT_ADJUSTABLE',
		         'R',
		         NULL,
                         x_err_stage,
		         x_err_code);


	      END IF;

	      goto next_line;   -- skip to next line

	   END IF;

	END IF;

	--Put the code which is common for new and adjustment lines here

	--Update the line as transferred

        update_asset_lines
                 (assetlinerec.project_asset_line_id,
		  NULL,
		  'T',
		  assetlinerec.single_char_amortize_flag,
                  x_err_stage,
		  x_err_code);

	-- Update the asset capitalized_cost

        pa_faxface.update_asset_cost
                 (assetlinerec.project_asset_id,
		  0,                                --- grouped_cip_cost
		  assetlinerec.current_asset_cost,  --- capitalized_cost
                  x_err_stage,
                  x_err_code);

        <<next_line>>
	    NULL;
     END LOOP;


     EXCEPTION
       WHEN OTHERS THEN
	  x_err_code := SQLCODE;
	  RAISE;
   END interface_asset_lines;

  -- The procedure given below is used for submitting the concurrent
  -- request. most of the validation for the various parameters are done
  -- at the time the parameters are entered.

  --   project_num_from  : start project # : mandatory
  --   project_num_to    : end   project # : mandatory
  --   x_in_service_date_through :  optional
  --   x_common_tasks_flag : Y/N : mandatory

  PROCEDURE summarize_proj
                        ( errbuf                 IN OUT NOCOPY VARCHAR2,
			  retcode                IN OUT NOCOPY VARCHAR2,
			  x_project_num_from        IN  VARCHAR2,
			  x_project_num_to          IN  VARCHAR2,
			  x_in_service_date_through IN  DATE,
			  x_common_tasks_flag       IN  VARCHAR2,
           	  x_pa_date                 IN  DATE
              /*  Automatic asset capitalization changes JPULTORAK 04-FEB-03 */
              ,x_capital_event_id       IN  NUMBER DEFAULT NULL
              , x_debug_mode IN VARCHAR2  -- Fix for bug : 4878878
              /*  End of Automatic asset capitalization changes */
			)
  IS
	L_current_org_id NUMBER  :=  PA_MOAC_UTILS.get_current_org_id ;
    -- Declare cursor for Projects

    CURSOR selprjs IS
    SELECT
	 ppr.project_id,
	 ppr.segment1,
	 pt.capital_cost_type_code,
	 pt.cip_grouping_method_code,
         pt.OVERRIDE_ASSET_ASSIGNMENT_FLAG,
	 pt.VENDOR_INVOICE_GROUPING_CODE,
         NVL(pt.total_burden_flag, DECODE(pt.burden_amt_display_method,
	                                  'S','Y',
					  'D','N',
					  'Y')) total_burden_flag,
	 pt.Burden_amt_display_method
    FROM
	 pa_projects ppr,
	 pa_project_types pt
    WHERE
	 ppr.segment1 between x_project_num_from and x_project_num_to and
	 ppr.template_flag <> 'Y' and
         PA_PROJECT_UTILS.Check_prj_stus_action_allowed(ppr.project_status_code,
'CAPITALIZE') = 'Y' and
	 ppr.project_type = pt.project_type and
	 pt.project_type_class_code = 'CAPITAL'
       AND NOT EXISTS (SELECT 'X'					/* Modified the selprjs cursor for Bug 7128863 start */
                       FROM   PA_PROJECT_ASSET_ASSIGNMENTS PPAA1,
                              PA_PROJECT_ASSET_ASSIGNMENTS PPAA2
                       WHERE  PPAA1.PROJECT_ID = PPR.PROJECT_ID
                              AND PPAA1.PROJECT_ID = PPAA2.PROJECT_ID
                              AND ((PPAA1.PROJECT_ID <> 0
                                    AND PPAA1.TASK_ID = 0)
                                   AND (PPAA2.PROJECT_ID <> 0
                                        AND PPAA2.TASK_ID <> 0)));	/* Modified the selprjs cursor for Bug 7128863 end */


/* removed this logic from this cursor and added function is_project_eligible for this logic
   Change done for bug 1280252.
    and ( exists   (select 'x'           -- project has costed,uncapitalized expenditure items
                  from    pa_cost_distribution_lines_all pcdl,
                          pa_expenditure_items_all pei,
                          pa_tasks pat
                  where   pcdl.expenditure_item_id = pei.expenditure_item_id
                  and     pei.revenue_distributed_flag||'' = 'N'
                  and     pei.cost_distributed_flag ='Y'
                  and     pcdl.line_type = DECODE(pt.capital_cost_type_code,'R','R','B','D','R')
                  and     pcdl.billable_flag = 'Y'
                  and     pei.task_id  = pat.task_id
                  and     pat.project_id  = ppr.project_id)
    or exists    (select 'x'                              -- Untransferred asset lines exist
                  from    pa_project_asset_lines pal
                  where   pal.project_id  = ppr.project_id
                  and     pal.rev_proj_asset_line_id IS NULL   -- This line is not an adjustment
                  and     pal.transfer_status_code <> 'T')
    or exists    ( select 'x'                           -- project has assets to be reverse capitalized
                   from   pa_project_assets ppa
                   where  ppa.project_id+0 = ppr.project_id
                   and    ppa.reverse_flag = 'Y'));
*/

  projrec        selprjs%ROWTYPE;


/*  Automatic asset capitalization changes JPULTORAK 04-FEB-03 */

    CURSOR  unassigned_lines_cur(x_project_id  NUMBER) IS
  	SELECT	pal.project_asset_line_id,
			pal.capital_event_id,
			pal.project_id,
			pal.task_id,
            NVL(pal.line_type,'C') line_type,
            p.segment1 project_number,
            pce.capital_event_number,
            pce.event_name,
			NVL(pce.asset_allocation_method, NVL(p.asset_allocation_method,'N')) asset_allocation_method,
			pal.asset_category_id   /* Added for bug#3211946  */
	FROM	pa_project_asset_lines_all pal,
			pa_projects p,
			pa_capital_events pce
	WHERE	pal.project_id = p.project_id
    AND     p.project_id = x_project_id
    AND     pal.capital_event_id = NVL(x_capital_event_id, pal.capital_event_id)
	AND		pal.capital_event_id = pce.capital_event_id (+)
	AND		pal.project_asset_id = 0
	AND		NVL(pce.asset_allocation_method, NVL(p.asset_allocation_method,'N')) <> 'N'
    ORDER BY pal.project_id, pal.capital_event_id, pal.task_id; --This order by is critical for cache purposes

    unassigned_lines_rec        unassigned_lines_cur%ROWTYPE;


    v_return_status         VARCHAR2(1) := 'S';
    v_msg_count             NUMBER := 0;
    v_msg_data              VARCHAR2(2000):= NULL;
    v_asset_or_project_err  VARCHAR2(1);
    v_error_code            VARCHAR2(30);
    v_err_asset_id          NUMBER;
    v_ret_cost_tasks_exist  VARCHAR2(1) := 'N';

/*  End of Automatic asset capitalization changes */



  x_err_stage    VARCHAR2(120);
  x_err_code     NUMBER;
  x_capital_cost_type_code varchar2(1) ;
  x_projects_cnt number;
 --  PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N'); Fix for bug : 4878878

  l_ledger_id    number;

  BEGIN
     -- Validate Parameters
     x_err_code  := 0;
     x_err_stage := 'Generate Project Asset Lines';
     -- Fix for bug : 4878878
     G_debug_mode := nvl(x_debug_mode,'N');
      IF G_debug_mode = 'Y' THEN
      pa_debug.enable_debug;
      End if;
     -- End of fix for bug : 4878878

     IF (x_project_num_from IS NULL OR x_project_num_to IS NULL) THEN

	 errbuf  := 'Project Numbers must be entered';
	 retcode := 1;
	 return;
     END IF;

     -- assume the process does not return an error
     retcode :=0;


/*  Automatic asset capitalization changes JPULTORAK 04-FEB-03 */
    --Add logic to set the Capital Event ID to -1 for assets and EIs on projects
    --with a Capital Event Processing method of 'None'.  This logic is not executed
    --when run for a specific Event.
/*bug 5642019 - this piece of code moved inside projrec loop.In case when PA_CLIENT_EXTN_ASSET_CREATION
                 is used to create project assets procedure no_event_projects will fail to update
                 pa_project_assets table since the client code has not been fired at this point.
    IF x_capital_event_id IS NULL THEN

        PA_FAXFACE.NO_EVENT_PROJECTS
                ( x_project_num_from     => x_project_num_from,
		          x_project_num_to       => x_project_num_to,
                  x_in_service_date_through => x_in_service_date_through,
                  x_err_stage            => x_err_stage,
		          x_err_code             => x_err_code);

    END IF;
*/
    /*  End of Automatic asset capitalization changes */


    select set_of_books_id
      into l_ledger_id
      from pa_implementations;


     FOR projrec IN selprjs LOOP

        /*  Automatic asset capitalization changes JPULTORAK 04-FEB-03 */
        IF G_debug_mode  = 'Y' THEN
            pa_debug.debug('summarize_proj: ' || 'Calling CREATE_PROJECT_ASSETS Client Extension for project...'||projrec.project_id);
        END IF;

        PA_CLIENT_EXTN_ASSET_CREATION.create_project_assets
                    (p_project_id           => projrec.project_id,
                     p_asset_date_through   => x_in_service_date_through,
                     p_pa_date_through      => x_pa_date,
                     p_capital_event_id     => x_capital_event_id,
                     x_return_status        => v_return_status,
                     x_msg_data             => v_msg_data);


        IF v_return_status = 'E' THEN

            BEGIN
                IF G_debug_mode  = 'Y' THEN
                    pa_debug.debug('summarize_proj: ' || 'Error in CREATE_PROJECT_ASSETS Client Extension...'||v_return_status||' - '||v_msg_data);
                END IF;

	            INSERT INTO pa_capital_exceptions
                    (request_id,
                     module,
	                 record_type,
                     project_id,
                     error_code,
                     created_by,
                     creation_date)
                VALUES
                    (x_request_id,
                     'CAPITAL',
                     'E',
                     projrec.project_id,
                     'C', --Asset Creation Extension Error
                     x_created_by,
                     fnd_date.date_to_canonical(sysdate));

            EXCEPTION
                WHEN OTHERS THEN
                    errbuf :=  SQLERRM;
                    retcode := SQLCODE;
                    ROLLBACK WORK;
                    RAISE;
            END;

        ELSIF v_return_status = 'U' THEN

            IF G_debug_mode  = 'Y' THEN
                pa_debug.debug('summarize_proj: ' || 'Unexpected Error in CREATE_PROJECT_ASSETS Client Extension...'||v_return_status||' - '||v_msg_data);
            END IF;

            errbuf :=  v_msg_data;
            retcode := SQLCODE;
            ROLLBACK WORK;
            RETURN;
        END IF;

        /*  End of Automatic asset capitalization changes */

       /*bug5758490*/
        IF x_capital_event_id IS NULL THEN

        PA_FAXFACE.NO_EVENT_PROJECTS
                ( x_project_id            =>  projrec.project_id,
                  x_in_service_date_through => x_in_service_date_through,
                  x_err_stage            => x_err_stage,
                  x_err_code             => x_err_code);

         END IF;

     /* Added this if condition. Change done for bug 1280252 */
     IF (is_project_eligible(projrec.project_id
                            /*  Automatic asset capitalization changes JPULTORAK 04-FEB-03 */
                            ,x_capital_event_id
                            /*  End of Automatic asset capitalization changes*/
                            )) then


       BEGIN

           IF G_debug_mode  = 'Y' THEN
              pa_debug.debug('summarize_proj: ' || 'Processing project id...'||projrec.project_id);
           END IF;

	   -- Acquire a lock before modifying project data
	   IF G_debug_mode  = 'Y' THEN
          pa_debug.debug('summarize_proj: ' || 'Lock the project: '||to_char(projrec.project_id));
	   END IF;
	   If pa_debug.Acquire_user_lock( 'PA_CAP_'||to_char(projrec.project_id))<>0 then
   	      IF G_debug_mode  = 'Y' THEN
             pa_debug.debug('summarize_proj: ' || 'Could not lock the project: '||projrec.segment1);
	      END IF;
	   else

	      -- First reverse all the assets for this project
	      IF G_debug_mode  = 'Y' THEN
	         pa_debug.debug('summarize_proj: ' || '. Generating reversing lines');
	      END IF;
	      reverse_asset_lines
		(projrec.project_id,
                 x_capital_event_id,
                 x_err_stage,
		 x_err_code);

	      IF G_debug_mode  = 'Y' THEN
	         pa_debug.debug('summarize_proj: ' || '. Deleting untransferred lines');
	      END IF;
	      -- now delete all the asset lines which could be deleted
	      delete_asset_lines
		(projrec.project_id,
                 x_capital_event_id,
		x_err_stage,
		x_err_code);
	      commit ; -- Introducing commit for perf. reasons. -sesivara 868857
	      -- Now summarize the cdls and create asset lines
	      IF G_debug_mode  = 'Y' THEN
	         pa_debug.debug('summarize_proj: ' || '. Generating new asset lines');
	      END IF;
	      if (projrec.capital_cost_type_code = 'B' and
                  NVL(projrec.total_burden_flag,'N') = 'Y') THEN
	           	 x_capital_cost_type_code := 'D' ;
	      else
		         x_capital_cost_type_code := 'R' ;
	      end if ;

	      generate_proj_asset_lines
		(projrec.project_id,
		x_in_service_date_through,
		x_common_tasks_flag,
		x_pa_date,
		x_capital_cost_type_code,
		projrec.cip_grouping_method_code,
		projrec.OVERRIDE_ASSET_ASSIGNMENT_FLAG,
		projrec.VENDOR_INVOICE_GROUPING_CODE,
                x_capital_event_id,
                'C', --x_line_type for generating Capital lines
                l_ledger_id, -- R12 new
		x_err_stage,
		x_err_code);


	      -- Now mark reversed lines to interface cost adjustments
	      IF G_debug_mode  = 'Y' THEN
	         pa_debug.debug('summarize_proj: ' || 'Marking reversing lines');
	      END IF;
	      mark_reversing_lines(projrec.project_id,
                                   x_capital_event_id,
                                   'C', --x_line_type
		                   x_err_stage,
		                   x_err_code);

	      -- Now interface the cost adjustments for the reversed lines
	      IF G_debug_mode  = 'Y' THEN
	         pa_debug.debug('summarize_proj: ' || '. Interfacing reversing lines');
	      END IF;
	      interface_asset_lines
		( projrec.project_id,
		'R',                           -- Reversing lines
		x_in_service_date_through,
		'Y',
		x_err_stage,
		x_err_code);


    /*  Automatic asset capitalization changes JPULTORAK 04-FEB-03 */
     --This code will process Retirement Costs.  It will only be executed if the project has
     --at least one Retirement Cost task.

     -- Now summarize the cdls and create asset lines for Retirement Cost Adjustments
     IF G_debug_mode  = 'Y' THEN
         pa_debug.debug('summarize_proj: ' || '. Determine if Retirement Cost Tasks exist');
     END IF;

     v_ret_cost_tasks_exist := 'N';

     BEGIN
         SELECT 'Y'
         INTO   v_ret_cost_tasks_exist
         FROM   sys.dual
         WHERE EXISTS
            (SELECT task_id
            FROM   pa_tasks
            WHERE  project_id = projrec.project_id
            AND    retirement_cost_flag = 'Y');

     EXCEPTION
        WHEN NO_DATA_FOUND THEN
            NULL;
     END;


     IF v_ret_cost_tasks_exist = 'Y' THEN

        -- Now summarize the cdls and create asset lines for Retirement Cost Adjustments
        IF G_debug_mode  = 'Y' THEN
            pa_debug.debug('summarize_proj: ' || '. Generating new Retirement Cost Adjustment asset lines');
        END IF;

        GENERATE_PROJ_ASSET_LINES
		  (projrec.project_id,
		  x_in_service_date_through,
		  x_common_tasks_flag,
		  x_pa_date,
		  x_capital_cost_type_code,
		  projrec.cip_grouping_method_code,
		  projrec.OVERRIDE_ASSET_ASSIGNMENT_FLAG,
		  projrec.VENDOR_INVOICE_GROUPING_CODE,
            x_capital_event_id,
            'R', --x_line_type for generating Retirement Cost Adjustment lines
	          l_ledger_id, -- R12 new
		  x_err_stage,
		  x_err_code);


        -- Now mark reversed lines to interface cost adjustments
	    IF G_debug_mode  = 'Y' THEN
	       pa_debug.debug('summarize_proj: ' || 'Marking reversing retirement cost lines');
	    END IF;

        MARK_REVERSING_LINES
           (projrec.project_id,
           x_capital_event_id,
           'R', --x_line_type
           x_err_stage,
		   x_err_code);

        -- Now interface the cost adjustments for the reversed lines
        IF G_debug_mode  = 'Y' THEN
           pa_debug.debug('summarize_proj: ' || '. Interfacing reversing retirement cost lines');
        END IF;

	    INTERFACE_RET_ASSET_LINES
	       (projrec.project_id,
		   x_err_stage,
		   x_err_code);

     END IF; --Retirement Cost Tasks exist for project

    /*  End of Automatic asset capitalization changes */



    /*  Automatic asset capitalization changes JPULTORAK 04-FEB-03 */

    x_err_stage := 'Allocate Unassigned Project Asset Lines';
    IF G_debug_mode  = 'Y' THEN
	    pa_debug.debug('summarize_proj: ' || '. Allocate Unassigned Asset Lines');
	END IF;

    --Add logic to allocate any unassigned asset lines for the project being processed
    FOR unassigned_lines_rec IN unassigned_lines_cur(projrec.project_id) LOOP

        PA_ASSET_ALLOCATION_PVT.ALLOCATE_UNASSIGNED
	                       (p_project_asset_line_id   => unassigned_lines_rec.project_asset_line_id,
                           p_line_type                => unassigned_lines_rec.line_type,
                           p_capital_event_id         => unassigned_lines_rec.capital_event_id,
                           p_project_id               => unassigned_lines_rec.project_id,
                           p_task_id 	              => unassigned_lines_rec.task_id,
                           p_asset_allocation_method  => unassigned_lines_rec.asset_allocation_method,
			   p_asset_category_id        => unassigned_lines_rec.asset_category_id,   /* Added for bug#3211946  */
                           x_asset_or_project_err     => v_asset_or_project_err,
                           x_error_code               => v_error_code,
                           x_err_asset_id             => v_err_asset_id,
                           x_return_status            => v_return_status,
                           x_msg_count                => v_msg_count,
                           x_msg_data                 => v_msg_data);


        IF v_return_status = 'E' THEN

            BEGIN

                --Print warning message in control report
                INSERT INTO pa_reporting_exceptions
                    (request_id,
                    context,
                    sub_context,
                    module,
	                record_type,
                    org_id,
                    attribute1,  --project_id
                    attribute2,  --project_number
                    attribute3,  --task_id
                    attribute4,  --project_asset_line_id
                    attribute5,  --capital_event_id
                    attribute6,  --capital_event_number
                    attribute7,  --event_name
                    attribute8,  --asset_allocation_method
                    attribute9,  --asset_id
                    attribute10, --error_code
                    attribute20, --error message
                    user_id,
                    attribute_date1)
                VALUES
                    (x_request_id,
                    'PA_ASSET_ALLOCATION_PVT',
                    v_asset_or_project_err,
                    'ALLOCATE_UNASSIGNED',
                    v_return_status,
                    --NVL(TO_NUMBER(DECODE(SUBSTR(USERENV('CLIENT_INFO'),1,1), ' ',NULL,SUBSTR(USERENV('CLIENT_INFO'),1,10))),-99),
				L_current_org_id,
                    unassigned_lines_rec.project_id,
                    unassigned_lines_rec.project_number,
                    unassigned_lines_rec.task_id,
                    unassigned_lines_rec.project_asset_line_id,
                    unassigned_lines_rec.capital_event_id,
                    unassigned_lines_rec.capital_event_number,
                    unassigned_lines_rec.event_name,
                    unassigned_lines_rec.asset_allocation_method,
                    v_err_asset_id,
                    v_error_code,
                    v_msg_data,
                    x_created_by,
 --                   fnd_date.date_to_canonical(sysdate));
                    SYSDATE);

            EXCEPTION
                WHEN OTHERS THEN
                    errbuf :=  SQLERRM;
                    retcode := SQLCODE;
                    ROLLBACK WORK;
                    RAISE;
            END;

        ELSIF v_return_status = 'U' THEN


            IF G_debug_mode  = 'Y' THEN
                pa_debug.debug('summarize_proj: ' || 'Unexpected Error in ALLOCATE_UNASSIGNED procedure...'||v_return_status||' - '||v_msg_data);
            END IF;

            errbuf :=  v_msg_data;
            retcode := SQLCODE;
            ROLLBACK WORK;
            RETURN;
        END IF;

    END LOOP;

    x_err_stage := 'Asset Allocation Complete';

    /*  End of Automatic asset capitalization changes */




	      COMMIT;  -- we are done with this project now

	      -- Release the project lock
	      IF G_debug_mode  = 'Y' THEN
	         pa_debug.debug('summarize_proj: ' || 'Unlock the project: '||to_char(projrec.project_id));
	      END IF;
	      If pa_debug.Release_user_lock('PA_CAP_'||to_char(projrec.project_id)) < 0  then
		 errbuf := NVL(fnd_message.get_string('PA', 'PA_CAP_CANNOT_RELS_LOCK'),
		   'PA_CAP_CANNOT_RELS_LOCK');
		 retcode:=1;
		 return;
	      End if;

	      x_projects_cnt := x_projects_cnt +1 ;  -- number of projects processed
	      IF G_debug_mode  = 'Y' THEN
	         pa_debug.debug('summarize_proj: ' || 'Successfully processed project '||
		to_char(projrec.project_id));
	      END IF;
	   END if;    -- End if for locking project

       EXCEPTION
         WHEN OTHERS THEN
           x_err_code := SQLCODE;
           retcode := x_err_code;
           errbuf  := SQLERRM(SQLCODE);
           IF G_debug_mode  = 'Y' THEN
              pa_debug.debug('summarize_proj: ' || 'Exception Generated By Oracle Error:' || errbuf );
              pa_debug.debug('summarize_proj: ' || 'Skipping This project......');
           END IF;
           ROLLBACK WORK;
       END;
     END IF;
     END LOOP;


     return;

  EXCEPTION

   WHEN OTHERS THEN
     errbuf :=  SQLERRM(SQLCODE);
     retcode := SQLCODE;
     ROLLBACK WORK;
     return;
  END summarize_proj;

  PROCEDURE interface_assets
                        ( errbuf                 IN OUT NOCOPY VARCHAR2,
			  retcode                IN OUT NOCOPY VARCHAR2,
			  x_project_num_from        IN  VARCHAR2,
			  x_project_num_to          IN  VARCHAR2,
			  x_in_service_date_through IN  DATE
			)
  IS

    -- Declare cursor for Projects

    CURSOR selprjs IS
    SELECT distinct
      ppr.project_id,
      ppr.segment1
    FROM
	 pa_projects ppr,
   pa_project_types pt,
    pa_project_asset_lines pal
    WHERE
	 ppr.segment1 between x_project_num_from and x_project_num_to and
	 ppr.template_flag <> 'Y' and
         PA_PROJECT_UTILS.Check_prj_stus_action_allowed(ppr.project_status_code,
'CAPITALIZE') = 'Y' and
	 ppr.project_type = pt.project_type and
	 pt.project_type_class_code = 'CAPITAL' and
	 pt.interface_asset_cost_code = 'F' and
    ppr.project_id = pal.project_id and
    pal.transfer_status_code||'' IN ('P','R')
    and (exists
       (SELECT 'x'
        FROM
        pa_project_assets ppa
        WHERE ppa.project_id = ppr.project_id
        AND   ppa.reverse_flag||'' = 'N'
        AND   TRUNC(ppa.date_placed_in_service) <=
              TRUNC(NVL(x_in_service_date_through,ppa.date_placed_in_service))
        AND   ppa.capitalized_flag = 'N'
        AND   pal.project_asset_id =  ppa.project_asset_id
       )
       or exists
       (SELECT 'x'
        FROM
        pa_project_assets ppa
        WHERE ppa.project_id = ppr.project_id
        AND   ppa.reverse_flag||'' = 'N'
        AND   ppa.capitalized_flag  ='Y'
        AND   TRUNC(ppa.date_placed_in_service) <=
              TRUNC(NVL(x_in_service_date_through,ppa.date_placed_in_service))
        AND   pal.rev_proj_asset_line_id is null
        AND   pal.project_asset_id = ppa.project_asset_id
       )
       or exists
       (SELECT 'x'
        FROM
        pa_project_assets ppa
        WHERE ppa.project_id = ppr.project_id
        AND   ppa.capitalized_flag = 'Y'
        AND   pal.rev_proj_asset_line_id is not null
        AND   pal.project_asset_id = ppa.project_asset_id
        )
       );


  projrec        selprjs%ROWTYPE;
  x_err_stage    VARCHAR2(120);
  x_err_code     NUMBER;
  x_rowcount     NUMBER;
  x_projects_cnt number;

  /*  Automatic asset capitalization changes JPULTORAK 04-FEB-03 */
  x_ret_rowcount NUMBER;
  /*  End of Automatic asset capitalization changes */
-- Fix for bug : 4878878
--   PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');


  BEGIN

     -- Validate Parameters
     x_err_code  := 0;
     x_err_stage := 'Interface Project Asset Lines';

     IF (x_project_num_from IS NULL OR x_project_num_to IS NULL) THEN

	 errbuf  := 'Project Numbers must be entered';
	 retcode := 1;
	 return;
     END IF;

     -- assume the process does not return an error

     retcode :=0;

     FOR projrec IN selprjs LOOP

      BEGIN
	 -- Now interface the asset lines to FA

	   -- Acquire a lock before modifying project data
	   IF G_debug_mode  = 'Y' THEN
	      pa_debug.debug('interface_assets: ' || 'Lock the project: '||to_char(projrec.project_id));
	   END IF;
	   If pa_debug.Acquire_user_lock('PA_CAP_'||to_char(projrec.project_id))<>0 then
	      IF G_debug_mode  = 'Y' THEN
	         pa_debug.debug('interface_assets: ' || 'Could not lock the project: '||projrec.segment1);
	      END IF;
	   ELSE

	      mark_asset_lines_for_xfer
		( projrec.project_id,
		  x_in_service_date_through,
          /*  Automatic asset capitalization changes JPULTORAK 04-FEB-03 */
          'C', --x_line_type
          /*  End of Automatic asset capitalization changes */
		  x_rowcount,
		  x_err_stage,
		  x_err_code);

	      --dbms_output.put_line('mark count is '||to_char(x_rowcount));
	      IF ( x_rowcount = 0 ) THEN
             /*  Automatic asset capitalization changes JPULTORAK 04-FEB-03 */
             --Skip to processing Retirement Lines, instead of skipping to next project
             --goto  next_proj;             -- No asset lines are selected
             GOTO process_ret_lines;
	         /*  End of Automatic asset capitalization changes */
          END IF;

	      IF G_debug_mode  = 'Y' THEN
	         pa_debug.debug('interface_assets: ' || 'Lines Found = ' || to_char(x_rowcount));
	         pa_debug.debug('interface_assets: ' || 'Processing Project '||to_char(projrec.project_id));
	         pa_debug.debug('interface_assets: ' || 'Interfacing Lines');
	      END IF;

	      interface_asset_lines
		( projrec.project_id,
		NULL,
		x_in_service_date_through,
		NULL,
		x_err_stage,
		x_err_code);


          /*  Automatic asset capitalization changes JPULTORAK 04-FEB-03 */
          --Process Retirement Asset Lines
          <<process_ret_lines>>
          NULL;

	      mark_asset_lines_for_xfer
		      ( projrec.project_id,
		      x_in_service_date_through,
              'R', --x_line_type
		      x_ret_rowcount,
		      x_err_stage,
		      x_err_code);

          --dbms_output.put_line('mark count is '||to_char(x_rowcount));
	      IF ( x_rowcount = 0 ) AND (x_ret_rowcount = 0) THEN
             GOTO  next_proj;      -- No asset lines are selected for entire project
          ELSIF ( x_rowcount <> 0 ) AND (x_ret_rowcount = 0) THEN
             GOTO skip_ret_lines;  --No retirement asset lines are selected
          END IF;

	      IF G_debug_mode  = 'Y' THEN
	         pa_debug.debug('interface_assets: ' || 'Retirement Lines Found = ' || to_char(x_ret_rowcount));
	         pa_debug.debug('interface_assets: ' || 'Processing Project '||to_char(projrec.project_id));
	         pa_debug.debug('interface_assets: ' || 'Interfacing Retirement Lines');
	      END IF;

	      interface_ret_asset_lines
		      (projrec.project_id,
		      x_err_stage,
		      x_err_code);

          <<skip_ret_lines>>
          NULL;

        /*  End of Automatic asset capitalization changes */


	      COMMIT;  -- we are done with this project now
	      -- Release the project lock
	      IF G_debug_mode  = 'Y' THEN
	         pa_debug.debug('interface_assets: ' || 'Unlock the project: '||to_char(projrec.project_id));
	      END IF;
	      If pa_debug.Release_user_lock('PA_CAP_'||to_char(projrec.project_id)) < 0  then
		 errbuf := NVL(fnd_message.get_string('PA', 'PA_CAP_CANNOT_RELS_LOCK'),
		   'PA_CAP_CANNOT_RELS_LOCK');
		 retcode:=1;
		 return;
	      End if;

	      x_projects_cnt := x_projects_cnt +1 ;
	      IF G_debug_mode  = 'Y' THEN
	         pa_debug.debug('interface_assets: ' || 'Successfully processed project '||
			to_char(projrec.project_id));
	      END IF;
	   END IF;  -- End if for locking project
      EXCEPTION
         WHEN OTHERS THEN
           x_err_code := SQLCODE;
           retcode := x_err_code;
           errbuf  := SQLERRM(SQLCODE);
           IF G_debug_mode  = 'Y' THEN
              pa_debug.debug('interface_assets: ' || 'Exception Generated By Oracle Error:' || errbuf );
              pa_debug.debug('interface_assets: ' || 'Skipping This project......');
           END IF;
           ROLLBACK WORK;
       END;
       <<next_proj>>
       NULL;
     END LOOP;

     return;

  EXCEPTION

   WHEN OTHERS THEN
     errbuf :=  SQLERRM(SQLCODE);
     retcode := SQLCODE;
     ROLLBACK WORK;
     return;
  END interface_assets;

  -- process to summarize and interface

---  summarize_xface can be compiled, but will NOT WORK .
---  This procedure is NOT called in any 11.0 code and hence not modified
---  for performance improvements 10/16/97 lalmaula

  PROCEDURE summarize_xface
                        ( errbuf                 IN OUT NOCOPY VARCHAR2,
			  retcode                IN OUT NOCOPY VARCHAR2,
			  x_project_num_from        IN  VARCHAR2,
			  x_project_num_to          IN  VARCHAR2,
			  x_in_service_date_through IN  DATE ,
           		  x_pa_date                 IN  DATE
			)
  IS

    -- Declare cursor for Projects

    CURSOR selprjs IS
    SELECT
	 ppr.project_id
    FROM
	 pa_projects ppr,
	 pa_project_types pt
    WHERE
	 ppr.segment1 between x_project_num_from and x_project_num_to and
         ppr.template_flag <> 'Y' and
         PA_PROJECT_UTILS.Check_prj_stus_action_allowed(ppr.project_status_code,
'CAPITALIZE') = 'Y' and
         ppr.project_type = pt.project_type and
         pt.project_type_class_code = 'CAPITAL' and
         pt.interface_asset_cost_code = 'F';


  projrec        selprjs%ROWTYPE;
  x_err_stage    VARCHAR2(120);
  x_err_code     NUMBER;
 -- Fix for bug : 4878878
 --  PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');
  l_ledger_id    NUMBER;

  BEGIN

     -- Validate Parameters
     x_err_code  := 0;
     x_err_stage := 'Generate Project Asset Lines';

     IF (x_project_num_from IS NULL OR x_project_num_to IS NULL) THEN

	 errbuf  := 'Project Numbers must be entered';
	 retcode := 1;
	 return;
     END IF;

     -- assume the process does not return an error

     retcode :=0;

     select set_of_books_id
       into l_ledger_id
       from pa_implementations;

     FOR projrec IN selprjs LOOP

      BEGIN
	 -- First reverse all the assets for this project

	 reverse_asset_lines
		   (projrec.project_id,
            /*  Automatic asset capitalization changes JPULTORAK 04-FEB-03 */
            NULL, --x_capital_event_id, *This line added just to allow SUMMARIZE_XFACE to compile
           /*  End of Automatic asset capitalization changes */
		    x_err_stage,
		    x_err_code);

	 -- now delete all the asset lines which could be deleted

	 delete_asset_lines
		   (projrec.project_id,
           /*  Automatic asset capitalization changes JPULTORAK 04-FEB-03 */
            NULL, --x_capital_event_id, *This line added just to allow SUMMARIZE_XFACE to compile
           /*  End of Automatic asset capitalization changes */
		    x_err_stage,
		    x_err_code);

	 -- Now summarize the cdls and create asset lines

	 generate_proj_asset_lines
		   (projrec.project_id,
		    x_in_service_date_through,
		    'N',
               	    x_pa_date,
                    NULL,
                    NULL,
                    NULL,
                    NULL,
                    /*  Automatic asset capitalization changes JPULTORAK 04-FEB-03 */
                    NULL, --x_capital_event_id, *This line added just to allow SUMMARIZE_XFACE to compile
                    NULL, --x_line_type, *This line added just to allow SUMMARIZE_XFACE to compile
                    /*  End of Automatic asset capitalization changes */
		    l_ledger_id, -- R12 new
		    x_err_stage,
		    x_err_code);

	 -- Now interface the cost adjustments for the reversed lines

         interface_asset_lines
		( projrec.project_id,
		  'R',                           -- Reversed assets
		  x_in_service_date_through,
		  'Y',
		  x_err_stage,
		  x_err_code);

         COMMIT;  -- we are done with this project now

	 -- Now interface the new asset lines to FA

         interface_asset_lines
		( projrec.project_id,
		  'N',                           -- New assets
		  x_in_service_date_through,
		  NULL,
		  x_err_stage,
		  x_err_code);
	 COMMIT;

	 -- Now send the cost adjustments

         interface_asset_lines
		( projrec.project_id,
		  'O',                           -- Old assets
		  x_in_service_date_through,
		  'N',
		  x_err_stage,
		  x_err_code);

         COMMIT;  -- we are done with this project now
       EXCEPTION
	 WHEN OTHERS THEN
           x_err_code := SQLCODE;
           retcode := x_err_code;
           errbuf  := SQLERRM(SQLCODE);
	   IF G_debug_mode  = 'Y' THEN
	      pa_debug.debug('summarize_xface: ' || 'Exception Generated By Oracle Error:' || errbuf );
              pa_debug.debug('summarize_xface: ' || 'Skipping This project......');
           END IF;
           ROLLBACK WORK;
       END;
     END LOOP;

     return;

  EXCEPTION

   WHEN OTHERS THEN
     errbuf :=  SQLERRM(SQLCODE);
     retcode := SQLCODE;
     ROLLBACK WORK;
     return;
  END summarize_xface;

/* Function is_project_eligible added for Bug 1280252 */
FUNCTION is_project_eligible(p_project_id IN NUMBER
                            /*  Automatic asset capitalization changes JPULTORAK 04-FEB-03 */
                            , p_capital_event_id IN NUMBER
                            /*  End of Automatic asset capitalization changes */
                            ) RETURN BOOLEAN IS
  dummy  number;
  v_errbuf  varchar2(250);
 -- Fix for bug : 4878878
 -- PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');

  BEGIN

/*    ********
    Commented the Select statement for Bug#2540426 and
    split this statement into three separate selects

    SELECT 1 INTO dummy
    FROM dual
    WHERE EXISTS (SELECT 'x'    -- project has costed,uncapitalized expenditure items
                  FROM    pa_cost_distribution_lines_all pcdl,
                          pa_expenditure_items_all pei,
                          pa_tasks pat,
                          pa_projects pp,
                          pa_project_types pt
                  WHERE   pcdl.expenditure_item_id = pei.expenditure_item_id
                    AND   pp.project_id = p_project_id
                    AND   pp.project_type = pt.project_type
                    AND   pei.revenue_distributed_flag||'' = 'N'
                    AND   pei.cost_distributed_flag ='Y'
                    AND   pcdl.line_type = DECODE(pt.capital_cost_type_code,'R','R',
						'B',decode(pt.burden_amt_display_method,'S','D','R'),
						'R') -- * Added decode for bug 1309745*
                    AND   pcdl.billable_flag = 'Y'
                    AND   pei.task_id  = pat.task_id
                    AND   pat.project_id  = p_project_id)

       OR EXISTS  (SELECT 'x'  -- Untransferred assetlines exist
                   FROM   pa_project_asset_lines pal
                   WHERE  pal.project_id  = p_project_id
                     AND  pal.rev_proj_asset_line_id IS NULL  -- This line is not an adjustment
                     AND  pal.transfer_status_code <> 'T')
       OR EXISTS  (SELECT 'x'  -- project has assets to be reverse capitalized
                   FROM    pa_project_assets ppa
                   WHERE   ppa.project_id+0 = p_project_id
                     AND   ppa.reverse_flag = 'Y');
    RETURN TRUE;

 ****** Commented code for Bug2540426 Ends here */
/*
   Added Code for Bug#2540426 to replace the above commented code for this bug
   If fisrt statement raises no_data_found exception then let second statement
   execute. Similarly, if the second statement raises this exception, let the
   third statement get executed.
 */

    BEGIN

       SELECT 1 INTO dummy
       FROM DUAL
       WHERE EXISTS  (SELECT  'x'  -- project has assets to be reverse capitalized
                        FROM  pa_project_assets ppa
                       WHERE  ppa.project_id+0 = p_project_id
                         AND  ppa.reverse_flag = 'Y'
                         /*  Automatic asset capitalization changes JPULTORAK 04-FEB-03 */
                         AND  capital_event_id = NVL(p_capital_event_id, capital_event_id)
                         AND  capital_event_id IS NOT NULL
                         /*  End of Automatic asset capitalization changes */
                         );

       RETURN TRUE;

    EXCEPTION
       WHEN NO_DATA_FOUND THEN
         NULL;
    END;


    BEGIN

       SELECT 1 INTO dummy
       FROM DUAL
       WHERE EXISTS (SELECT  'x'  -- Untransferred assetlines exist
                       FROM  pa_project_asset_lines pal
                      WHERE  pal.project_id  = p_project_id
                        AND  pal.rev_proj_asset_line_id IS NULL  -- This line is not an adjustment
                        AND  pal.transfer_status_code <> 'T'
                        /*  Automatic asset capitalization changes JPULTORAK 04-FEB-03 */
                        AND  pal.capital_event_id = NVL(p_capital_event_id, pal.capital_event_id)
                        /*  End of Automatic asset capitalization changes */
                        );

       RETURN TRUE;

    EXCEPTION
       WHEN NO_DATA_FOUND THEN
         NULL;
    END;


/*  Automatic asset capitalization changes JPULTORAK 04-FEB-03 */
--Add Retirement Cost Processing check for costed, uncapitalized Retirement Cost Items

    BEGIN

       SELECT 1 INTO dummy
       FROM dual
       WHERE EXISTS (SELECT 'x'    -- project has costed,uncapitalized Retirement Cost expenditure items
                     FROM    pa_cost_distribution_lines_all pcdl,
                             pa_expenditure_items_all pei,
                             pa_tasks pat,
                             pa_projects pp,
                             pa_project_types pt
                     WHERE   pcdl.expenditure_item_id = pei.expenditure_item_id
                       AND   pp.project_id = p_project_id
                       AND   pp.project_type = pt.project_type
                       AND   pei.revenue_distributed_flag||'' = 'N'
                       AND   pei.cost_distributed_flag ='Y'
/* PA.L Code change to allow 'R' or 'I' line types in cases when previously only 'R' was used. JPULTORAK 20-MAY-2003 */
--In addition, PA.L allows 'D' lines to exist in all cases when Total Burden Flag is 'Y'
--The following section was changed into an OR condition to allow 'R' or 'I' lines as introduced by PA.L
                       --AND   pcdl.line_type = DECODE(pt.capital_cost_type_code,'R','R',
                       AND   (pcdl.line_type = DECODE(pt.capital_cost_type_code,'R','R',
                       /* Fix for Enable TBC Accounting Option JPULTORAK 14-FEB-2003 */
--                     We can only select 'D' CDLs when TBC Accounting is ENABLED and Burden Amt Display Method is 'S'
--                                                'B',decode(pt.burden_amt_display_method,'S','D','R'),
--                                                'B',DECODE(NVL(pt.total_burden_flag,'N'),'Y',decode(pt.burden_amt_display_method,'S','D','R'),'R'),
--                     The line above was commented out since PA.L allows 'D' lines in all cases where Total Burden Flag is 'Y'
                                                'B',DECODE(NVL(pt.total_burden_flag,'N'),'Y','D','R'),
                       /* End of Fix for Enable TBC Accounting Option */
                                                'R')  --Added decode for bug 1309745
                              OR
                              pcdl.line_type = DECODE(pt.capital_cost_type_code,'R','I',
                                                'B',DECODE(NVL(pt.total_burden_flag,'N'),'Y','D','I'),
                                                'I'))
/* End of PA.L code change section */
                       AND   pcdl.billable_flag = 'N'
                       AND   pei.task_id  = pat.task_id
                       AND   pat.project_id = pp.project_id --Bug 3057423 added to avoid merge join cartesian
                       AND   pat.project_id  = p_project_id
                       AND   pei.capital_event_id = NVL(p_capital_event_id, pei.capital_event_id)
                       AND   pei.capital_event_id IS NOT NULL
                       AND   pat.retirement_cost_flag = 'Y');

       RETURN TRUE;

    EXCEPTION
       WHEN NO_DATA_FOUND THEN
         NULL;
    END;

/*  End of Automatic asset capitalization changes */


    BEGIN

       SELECT 1 INTO dummy
       FROM dual
       WHERE EXISTS (SELECT 'x'    -- project has costed,uncapitalized expenditure items
                     FROM    pa_cost_distribution_lines_all pcdl,
                             pa_expenditure_items_all pei,
                             --pa_tasks pat, /* bug fix :2830211  task_id is not reqd */
                             pa_projects_all pp,
                             pa_project_types pt
                     WHERE   pcdl.expenditure_item_id = pei.expenditure_item_id
                       AND   pp.project_id = p_project_id
                       AND   pei.project_id = pp.project_id  /* added for bug fix :2830211  */
                       AND   pp.project_type = pt.project_type
                       AND   pei.revenue_distributed_flag||'' = 'N'
                       AND   pei.cost_distributed_flag ='Y'
/* PA.L Code change to allow 'R' or 'I' line types in cases when previously only 'R' was used. JPULTORAK 20-MAY-2003 */
--In addition, PA.L allows 'D' lines to exist in all cases when Total Burden Flag is 'Y'
--The following section was changed into an OR condition to allow 'R' or 'I' lines as introduced by PA.L
                       --AND   pcdl.line_type = DECODE(pt.capital_cost_type_code,'R','R',
                       AND   (pcdl.line_type = DECODE(pt.capital_cost_type_code,'R','R',
                       /* Fix for Enable TBC Accounting Option JPULTORAK 14-FEB-2003 */
--                     We can only select 'D' CDLs when TBC Accounting is ENABLED and Burden Amt Display Method is 'S'
--                                                'B',decode(pt.burden_amt_display_method,'S','D','R'),
--                                                'B',DECODE(NVL(pt.total_burden_flag,'N'),'Y',decode(pt.burden_amt_display_method,'S','D','R'),'R'),
--                     The line above was commented out since PA.L allows 'D' lines in all cases where Total Burden Flag is 'Y'
                                                'B',DECODE(NVL(pt.total_burden_flag,'N'),'Y','D','R'),
                       /* End of Fix for Enable TBC Accounting Option */
                                                'R')/* Added decode for bug 1309745*/
                              OR
                              pcdl.line_type = DECODE(pt.capital_cost_type_code,'R','I',
                                                'B',DECODE(NVL(pt.total_burden_flag,'N'),'Y','D','I'),
                                                'I'))
/* End of PA.L code change section */
                       AND   pcdl.billable_flag = 'Y'
                       /* bug fix :2830211  */
                          --AND   pei.task_id  = pat.task_id
                          --AND   pat.project_id  = p_project_id
                          --AND   pat.project_id = pp.project_id missing join causing cartesion
                       /* End of bug fix :2830211  */
                       /*  Automatic asset capitalization changes JPULTORAK 04-FEB-03 */
                       AND   pei.capital_event_id = NVL(p_capital_event_id, pei.capital_event_id)
                       AND   pei.capital_event_id IS NOT NULL
                       /*  End of Automatic asset capitalization changes */
                       );

       RETURN TRUE;

    EXCEPTION
       WHEN NO_DATA_FOUND THEN
         RETURN FALSE;  /* Return False only when there is no data for all the three selects */
    END;

 /* Added code for Bug2540426 Ends here */

  EXCEPTION
    WHEN OTHERS THEN
        v_errbuf  := substr(SQLERRM(SQLCODE),1.200);
        IF G_debug_mode  = 'Y' THEN
           pa_debug.debug('is_project_eligible: ' || 'Exception Generated By Oracle Error:' || v_errbuf );
           pa_debug.debug('is_project_eligible: ' || 'Skipping This project......');
        END IF;
        return FALSE;
 END is_project_eligible;


/*  Automatic asset capitalization changes JPULTORAK 04-FEB-03 */
  PROCEDURE get_depreciation_expense
              (x_project_asset_id       IN  NUMBER,
			  x_book_type_code          IN  VARCHAR2,
			  x_asset_category_id       IN  NUMBER,
              x_date_placed_in_service  IN  DATE,
              x_in_deprn_expense_ccid   IN  NUMBER,
              x_out_deprn_expense_ccid  IN OUT NOCOPY NUMBER,
       	      x_err_stage               IN OUT NOCOPY VARCHAR2,
    	      x_err_code                IN OUT NOCOPY NUMBER
			) IS


    l_new_deprn_expense_ccid      NUMBER := 0;

    /* Bug 3057423 Below cursor not used, instead see function Pa_Capital_Project_Utils.IsValidExpCCID
    --Used to determine if the Depreciation Expense CCID is valid for the current COA
    CURSOR  deprn_expense_cur IS
    SELECT  'Deprn Expense Acct code combination is valid'
    FROM    gl_code_combinations gcc,
            gl_sets_of_books gsob,
            pa_implementations pi
    WHERE   gcc.code_combination_id = l_new_deprn_expense_ccid
    AND     gcc.chart_of_accounts_id = gsob.chart_of_accounts_id
    AND     gsob.set_of_books_id = pi.set_of_books_id
    AND     gcc.account_type = 'E';

    deprn_expense_rec      deprn_expense_cur%ROWTYPE;
    */

  BEGIN

      x_err_stage := 'get_depreciation_expense';

      l_new_deprn_expense_ccid := PA_CLIENT_EXTN_DEPRN_EXP_OVR.DEPRN_EXPENSE_ACCT_OVERRIDE
                                        (p_project_asset_id        => x_project_asset_id,
                                         p_book_type_code          => x_book_type_code,
			                             p_asset_category_id       => x_asset_category_id,
                                         p_date_placed_in_service  => x_date_placed_in_service,
                                         p_deprn_expense_acct_ccid => x_in_deprn_expense_ccid);

      IF NVL(x_in_deprn_expense_ccid,-999) <> NVL(l_new_deprn_expense_ccid,-999) THEN

         --Return NULL if the client extension has returned a NULL CCID
         IF l_new_deprn_expense_ccid IS NULL THEN
            x_out_deprn_expense_ccid := NULL;
            RETURN;
         END IF;

         --Validate the new ccid against the current Set of Books

         /* Bug 3057423: Call cached function to check if CCID is valid expense account
         OPEN deprn_expense_cur;
         FETCH deprn_expense_cur INTO deprn_expense_rec;

	     IF deprn_expense_cur%NOTFOUND THEN
            --Value returned by client extension is invalid, return original CCID
            x_out_deprn_expense_ccid := x_in_deprn_expense_ccid;
         ELSE
            --Value is valid, return new CCID
            x_out_deprn_expense_ccid := l_new_deprn_expense_ccid;
         END IF;

         CLOSE deprn_expense_cur;
         */

         --Start Bug 3057423
         If Pa_Capital_Project_Utils.IsValidExpCCID(l_new_deprn_expense_ccid) = 'Y' Then
            --Value is valid, return new CCID
            x_out_deprn_expense_ccid := l_new_deprn_expense_ccid;
         Else
            --Value returned by client extension is invalid, return original CCID
            x_out_deprn_expense_ccid := x_in_deprn_expense_ccid;
         End If;
         --End Bug 3057423

         --If CCID value has changed, update Project Asset row
         IF NVL(x_out_deprn_expense_ccid,-999) <> NVL(x_in_deprn_expense_ccid,-999) THEN

            UPDATE  pa_project_assets
            SET     depreciation_expense_ccid = x_out_deprn_expense_ccid,
                    last_update_date = SYSDATE,
	                last_updated_by = x_last_updated_by,
	                last_update_login = x_last_update_login,
	                request_id = x_request_id,
	                program_application_id = x_program_application_id,
	                program_id = x_program_id,
	                program_update_date = SYSDATE
            WHERE   project_asset_id = x_project_asset_id;

         END IF; --Value has changed, perform update
      ELSE
         x_out_deprn_expense_ccid := x_in_deprn_expense_ccid;
      END IF;


  EXCEPTION
      WHEN OTHERS THEN
         x_err_code := SQLCODE;
         RAISE;
  END get_depreciation_expense;
 /*  End of Automatic asset capitalization changes */


 /*  Automatic asset capitalization changes JPULTORAK 04-FEB-03 */
  -- Procedure for transferring retirement cost asset lines

   PROCEDURE interface_ret_asset_lines
		( x_project_id              IN  NUMBER,
		  x_err_stage            IN OUT NOCOPY VARCHAR2,
		  x_err_code             IN OUT NOCOPY NUMBER) IS


   CURSOR selassetlines IS
   SELECT
       ppa.project_id,
       ppa.project_asset_id,
       pal.cip_ccid,
       ppa.asset_number,
       ppa.asset_name,
       ppa.asset_description,
       ppa.date_placed_in_service,
       ppa.book_type_code,
       ppa.ret_target_asset_id,
       decode(ppa.amortize_flag, 'Y','YES','N','NO') amortize_flag,
       ppa.amortize_flag single_char_amortize_flag,
       ppa.cost_adjustment_flag,
       ppa.capitalized_flag,
       ppa.reverse_flag,
       decode(nvl(ppa.new_master_flag,'N'),'Y','YES','N','NO') new_master_flag, -- Bug 5435551
       pal.project_asset_line_id,
       pal.project_asset_line_detail_id detail_id,
       pal.rev_proj_asset_line_id,
       pal.description,
       pal.task_id,
       pal.current_asset_cost,
       pal.gl_date
   FROM
       pa_project_asset_lines pal,
       pa_project_assets ppa,
       pa_projects pp,
       pa_project_types ppt
   WHERE
       pal.project_asset_id = ppa.project_asset_id
   AND ppa.project_id = pp.project_id
   AND ppa.project_id = x_project_id
   AND pp.project_type = ppt.project_type
   AND pal.transfer_status_code = 'X'
   AND pal.line_type = 'R'
   ORDER BY ppa.project_asset_id;

   assetlinerec             selassetlines%ROWTYPE;


-- R12 changes. Table pa_gl_interface is obsolete. This check is left for
-- asset lines which are not yet interfaced to FA before uptake of R12.
   CURSOR un_gl_xferred_cdls (x_detail_id IN NUMBER) IS
        select 'X'
        from pa_project_asset_line_details d,
                pa_cost_distribution_lines_all cdl
        where d.PROJECT_ASSET_LINE_DETAIL_ID = x_detail_id and
                d.expenditure_item_id = cdl.expenditure_item_id and
                d.line_num = cdl.line_num and
				(
                cdl.transfer_status_code in  ('P','R','X','T')
				/* -- R12 change..pa_gl_interface is obsolete.
				OR
				Exists ( Select 'X' From Pa_Gl_Interface GL
				          Where GL.Reference26 = cdl.batch_name
						    And Cdl.transfer_status_code = 'A'
					   )
                                */
				)
				;

   un_gl_rec		un_gl_xferred_cdls%ROWTYPE;


   --Used to determine if the book type code is valid for the current SOB
   CURSOR  book_type_code_cur (x_book_type_code  VARCHAR2) IS
   SELECT  fb.set_of_books_id
   FROM    fa_book_controls fb,
           pa_implementations pi
   WHERE   fb.set_of_books_id = pi.set_of_books_id
   AND     fb.book_type_code = x_book_type_code;

   book_type_code_rec      book_type_code_cur%ROWTYPE;


   --Used to determine if the Ret Target Asset ID is a valid GROUP asset in the book
   CURSOR  ret_target_cur (x_ret_target_asset_id  NUMBER,
                           x_book_type_code       VARCHAR2) IS
   SELECT  fa.asset_category_id
   FROM    fa_books fb,
           fa_additions fa
   WHERE   fa.asset_id = x_ret_target_asset_id
   AND     fa.asset_type = 'GROUP'
   AND     fa.asset_id = fb.asset_id
   AND     fb.book_type_code = x_book_type_code
   AND     fb.date_ineffective IS NULL;

   ret_target_rec      ret_target_cur%ROWTYPE;


   --Table used by to cache the results of queries
   --against the pa_cost_distribution_line table.
   Type NumTabType IS
        Table of Number
        Index by binary_integer;

   detail_cdl_xfer_cache        NumTabType;


   v_msg_data               VARCHAR2(2000) := NULL;
   line_okay_for_interface  BOOLEAN;




   BEGIN

     x_err_code  := 0;
     x_err_stage := 'Interfacing retirement cost asset lines';


     FOR assetlinerec IN selassetlines LOOP


        /*dbms_output.put_line('Asset Id = ' ||
	            to_char(assetlinerec.project_asset_id) || ' Line Id = ' ||
                to_char(assetlinerec.project_asset_line_id)); */

	    --this section of code checks that cip cost has been transferred
	    --to GL for the asset line.  It is not in a separate procedure
	    --because placing it there kept causing a signal 11 error.
	    /************************************************************/
        BEGIN
	       --this will raise a no_data_found exception if the
    	   --detail id hasn't been checked and results cached before.
    	   --The cache is most useful when lines have been split

    	   IF detail_cdl_xfer_cache(assetlinerec.detail_id) = 1 THEN
       	       line_okay_for_interface := TRUE;
    	   ELSE
       	       line_okay_for_interface := FALSE;
    	   END IF;

  	    EXCEPTION
  	       WHEN no_data_found THEN
    	       OPEN un_gl_xferred_cdls (assetlinerec.detail_id);
    	       FETCH un_gl_xferred_cdls into un_gl_rec;
    	       IF un_gl_xferred_cdls%NOTFOUND THEN
        	       line_okay_for_interface := TRUE;
        	       detail_cdl_xfer_cache(assetlinerec.detail_id) := 1;
    	       ELSE
        	       line_okay_for_interface := FALSE;
        	       detail_cdl_xfer_cache(assetlinerec.detail_id) := 0;
    	       END IF;
    	       CLOSE un_gl_xferred_cdls;
	    END;


	    IF (line_okay_for_interface = FALSE) THEN

            update_asset_lines
                (assetlinerec.project_asset_line_id,
                'CIP_NOT_XFERD_TO_GL',
                'R',
                NULL,
                x_err_stage,
                x_err_code);

	        GOTO next_line;
      	END IF;
	    /*************************************************************/



        IF assetlinerec.book_type_code IS NULL OR assetlinerec.ret_target_asset_id IS NULL THEN

            --Required information (Book Type Code, Retirement Target Asset ID) not found in PA
            update_asset_lines
                (assetlinerec.project_asset_line_id,
		         'TARGET_NOT_COMPLETE',
		         'R',
		         NULL,
                 x_err_stage,
		         x_err_code);

		    GOTO next_line;

        ELSE

            --Validate Book Type Code is valid for the current SOB
            OPEN book_type_code_cur(assetlinerec.book_type_code);
            FETCH book_type_code_cur INTO book_type_code_rec;
	        IF book_type_code_cur%NOTFOUND THEN

                CLOSE book_type_code_cur;
                -- The book_type_code is not valid. Return error
                update_asset_lines
                     (assetlinerec.project_asset_line_id,
		              'TARGET_NOT_COMPLETE',
		              'R',
		              NULL,
                      x_err_stage,
		              x_err_code);

                GOTO next_line;

            END IF;
            CLOSE book_type_code_cur;


            --Validate that Ret Target Asset ID is a valid Group Asset for the Book
            OPEN ret_target_cur(assetlinerec.ret_target_asset_id, assetlinerec.book_type_code);
            FETCH ret_target_cur INTO ret_target_rec;
            IF ret_target_cur%NOTFOUND THEN

                CLOSE ret_target_cur;
                -- The ret_target_asset_id is not valid. Reject Line with "Asset Not Adjustable" message
                update_asset_lines
                     (assetlinerec.project_asset_line_id,
		              'TARGET_NOT_ADJUSTABLE',
		              'R',
		              NULL,
                      x_err_stage,
		              x_err_code);

                GOTO next_line;

            END IF;
            CLOSE ret_target_cur;


            --Call procedure to execute the API call for Interface to Oracle Assets
            PA_FAXFACE_RET_PVT.INTERFACE_RET_COST_ADJ_LINE
	           (x_project_asset_line_id => assetlinerec.project_asset_line_id,
                x_msg_data              => v_msg_data,
                x_err_stage             => x_err_stage,
		        x_err_code              => x_err_code);


            IF x_err_code = 0 THEN

              /*bug 4401557*/
             -- Update the assets status as capitalized
                update_asset_capitalized_flag
                   (assetlinerec.project_asset_id,
                    'Y',
                    x_err_stage,
                    x_err_code);
            /*Bug 4401557*/

                --Update the line as transferred
                update_asset_lines
                    (assetlinerec.project_asset_line_id,
		             NULL,
		             'T',
		             assetlinerec.single_char_amortize_flag,
                     x_err_stage,
		             x_err_code);

	            -- Update the asset capitalized_cost
                pa_faxface.update_asset_cost
                    (assetlinerec.project_asset_id,
		             0,                                --- grouped_cip_cost
		             assetlinerec.current_asset_cost,  --- capitalized_cost
                     x_err_stage,
                     x_err_code);

            ELSE

                FND_FILE.PUT_LINE(FND_FILE.LOG,'Error in PA_FAXFACE_RET_PVT.interface_ret_cost_adj_line for asset line: '||assetlinerec.project_asset_line_id);
                FND_FILE.PUT_LINE(FND_FILE.LOG,'Error Code: '||x_err_code||' Error Stage:'||x_err_stage);
                FND_FILE.PUT_LINE(FND_FILE.LOG,'Message Data: '||v_msg_data);

                -- Reject Line with message returned by API
                update_asset_lines
                     (assetlinerec.project_asset_line_id,
		              'ERROR_IN_GROUP_RET_ADJ', --v_msg_data,
		              'R',
		              NULL,
                      x_err_stage,
		              x_err_code);
            END IF;
        END IF;

        <<next_line>>
        NULL;
      END LOOP;


   EXCEPTION
       WHEN OTHERS THEN
    	   x_err_code := SQLCODE;
	       RAISE;
   END interface_ret_asset_lines;


   PROCEDURE no_event_projects
                ( x_project_id      IN number,        /*bug5758490*/
                  x_in_service_date_through IN DATE,
                  x_err_stage            IN OUT  NOCOPY VARCHAR2,
                  x_err_code             IN OUT  NOCOPY NUMBER) IS

/* Commented for bug 5758490
    CURSOR no_event_proj_cur IS
    SELECT  p.project_id
    FROM	pa_projects p,
            pa_project_types pt
    WHERE	p.segment1
        BETWEEN x_project_num_from AND x_project_num_to
    AND	    p.template_flag <> 'Y'
    AND     PA_PROJECT_UTILS.Check_prj_stus_action_allowed(p.project_status_code,'CAPITALIZE') = 'Y'
    AND     p.project_type = pt.project_type
    AND     pt.project_type_class_code = 'CAPITAL'
    AND     NVL(p.capital_event_processing,'N') = 'N';

    no_event_proj_rec        no_event_proj_cur%ROWTYPE;*/

 -- Fix for bug : 4878878
 --    PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');
       is_no_event_proj     VARCHAR2(1) := 'N'; -- Added for bug 5758490
   BEGIN

       x_err_code  := 0;
       x_err_stage := 'Updating assets and events for No Event Processing projects';


       IF G_debug_mode  = 'Y' THEN
           pa_debug.debug('summarize_proj: ' || 'Set Capital Event ID = -1 for No Event Processing projects.');
       END IF;

       /* Commented for bug 5758490
       FOR no_event_proj_rec IN no_event_proj_cur LOOP */

    begin
     select 'Y' into is_no_event_proj
      from pa_projects_all p
      where p.project_id = x_project_id
      and NVL(p.capital_event_processing,'N') = 'N';
    exception   -- Added exception handling for bug 5909337
      when no_data_found then
       is_no_event_proj := 'N';
    end;

    IF  is_no_event_proj = 'Y' then

            --Update all project assets that have a DPIS (AS-BUILT or RETIREMENT_ADJUSTMENT)
            UPDATE  pa_project_assets_all
            SET     capital_event_id = -1,
                    last_update_date = SYSDATE,
	                last_updated_by = x_last_updated_by,
	                last_update_login = x_last_update_login,
	                request_id = x_request_id,
	                program_application_id = x_program_application_id,
	                program_id = x_program_id,
	                program_update_date = SYSDATE
            WHERE   project_id = x_project_id   /*Bug 5758490*/
            AND     project_asset_type IN ('AS-BUILT','RETIREMENT_ADJUSTMENT')
            AND     date_placed_in_service IS NOT NULL
            AND     date_placed_in_service <= x_in_service_date_through
            AND     capital_event_id IS NULL
            AND     capital_hold_flag = 'N';

            --Update all capital Expenditure Items
            UPDATE  pa_expenditure_items_all
            SET     capital_event_id = -1,
                    last_update_date = SYSDATE,
	                last_updated_by = x_last_updated_by,
	                last_update_login = x_last_update_login,
	                request_id = x_request_id,
	                program_application_id = x_program_application_id,
	                program_id = x_program_id,
	                program_update_date = SYSDATE
            WHERE   project_id = x_project_id   /*Bug 5758490*/
            AND     billable_flag||'' = 'Y'
            AND     capital_event_id IS NULL;

            --Update all retirement cost Expenditure Items
            UPDATE  pa_expenditure_items_all peia
            SET     capital_event_id = -1,
                    last_update_date = SYSDATE,
	                last_updated_by = x_last_updated_by,
	                last_update_login = x_last_update_login,
	                request_id = x_request_id,
	                program_application_id = x_program_application_id,
	                program_id = x_program_id,
	                program_update_date = SYSDATE
            WHERE   project_id = x_project_id  /*Bug 5758490*/
            AND     billable_flag||'' = 'N'
            AND     capital_event_id IS NULL
            AND     EXISTS
                    (SELECT t.task_id
                    FROM    pa_tasks t
                    WHERE   t.task_id = peia.task_id
                    AND     t.retirement_cost_flag = 'Y');

            COMMIT;
    END IF;  /*IF is_no_event_proj*/

/* END LOOP; bug 5758490*/


   EXCEPTION
   WHEN NO_DATA_FOUND THEN /* Added for bug:7319246*/
 	 NULL;
       WHEN OTHERS THEN
    	   x_err_code := SQLCODE;
	       RAISE;
   END no_event_projects;


   /*  End of Automatic asset capitalization changes */

----------------------------------------------------------------------------------------------------------

PROCEDURE create_alc_asset_line_details		(x_proj_asset_line_dtl_uniq_id	IN NUMBER,
						 x_expenditure_item_id		IN NUMBER,
						 x_line_num			IN NUMBER,
						 x_project_asset_line_detail_id IN NUMBER,
						 x_err_stage			IN OUT NOCOPY VARCHAR2,
						 x_err_code			IN OUT NOCOPY NUMBER)
IS

CURSOR c_alc_ledger IS
  SELECT gl.ledger_id, gl.currency_code, imp.set_of_books_id, imp.org_id, gld.sla_ledger_cash_basis_flag
  FROM   gl_alc_ledger_rships_v gl,
         pa_implementations imp,
	 gl_ledgers  gld
  WHERE  gl.source_ledger_id = imp.set_of_books_id
  AND    gl.application_id = 275
  AND    gl.org_id = imp.org_id
  AND	 gld.ledger_id = imp.set_of_books_id
  AND    gl.relationship_enabled_flag = 'Y';

l_exchange_rate_type      VARCHAR2(30);
l_exchange_rate           NUMBER :=0;
l_numerator_rate          NUMBER;
l_denominator_rate        NUMBER;
l_result_code             VARCHAR2(30);

l_line_type		VARCHAR2(1);
l_transfer_status_code	VARCHAR2(1);
l_acct_event_id		NUMBER;
l_denom_raw_cost	NUMBER;
l_acct_source_code	VARCHAR2(30);
l_transaction_source	VARCHAR2(30);
l_gl_date		DATE;
l_denom_currency_code	VARCHAR2(30);
l_predefined_flag	VARCHAR2(1);
l_cip_cost		NUMBER;
l_system_reference5	NUMBER;
l_document_distribution_id	NUMBER;
l_document_payment_id	NUMBER;
l_historical_flag	VARCHAR2(1);
l_capital_cost_type	VARCHAR2(1);
l_alc_exists		VARCHAR2(1);

begin

  x_err_code     := 0;
  x_err_stage    := 'Create ALC Project Asset Line details';

  SELECT cdl.line_type, cdl.transfer_status_code, cdl.acct_event_id, cdl.denom_raw_cost, cdl.acct_rate_type, cdl.acct_exchange_rate,
         pts.acct_source_code, pts.transaction_source, cdl.gl_date, cdl.denom_currency_code, nvl(ei.historical_flag, 'Y'),
	 nvl(pts.predefined_flag,'Y'), cdl.system_reference5, ei.document_distribution_id, ei.document_payment_id
  INTO   l_line_type, l_transfer_status_code, l_acct_event_id, l_denom_raw_cost, l_exchange_rate_type, l_exchange_rate,
         l_acct_source_code, l_transaction_source, l_gl_date, l_denom_currency_code, l_historical_flag,
	 l_predefined_flag  , l_system_reference5, l_document_distribution_id, l_document_payment_id
  FROM pa_expenditure_items_all ei,
       pa_cost_distribution_lines_all cdl,
       pa_transaction_sources pts
  WHERE cdl.expenditure_item_id = x_expenditure_item_id
  AND cdl.line_num = x_line_num
  AND cdl.expenditure_item_id = ei.expenditure_item_id
  AND ei.transaction_source = pts.transaction_source(+) ;


  FOR v_alc_ledger IN c_alc_ledger
  LOOP

  l_alc_exists := 'Y';

  /* Bug 5254487 */
  If l_transaction_source = 'AP ERV' Then
	l_cip_cost := 0;
  End If;

  IF (l_acct_event_id is not null and NVL(l_transaction_source,'NULL') <> 'AP ERV' ) or
	  (l_transaction_source is not null and l_transfer_status_code = 'V' and l_predefined_flag = 'Y'
	  and NVL(l_transaction_source,'NULL') <> 'AP ERV' and l_historical_flag ='N' )   THEN

		/* Transaction accounted in SLA by PA
		and Transaction accounted in SLA by Oracle Subledgers other than PA */



		begin

		x_err_stage    := 'Create ALC Project Asset Line details by PA SLA or by External SLA';

		select nvl(xdl.unrounded_accounted_dr, -1 * xdl.unrounded_accounted_cr)
		into l_cip_cost
		from xla_distribution_links xdl,
		     xla_ae_lines xal,
		     xla_ae_headers xah,
		     xla_acct_class_assgns xaca,
		     xla_assignment_defns_b xad,
		     xla_post_acct_progs_b xpap
		where xpap.program_code = 'PA_POSTACCOUNTING_DEBIT'
		and xpap.program_owner_code = 'S'
		and xpap.application_id = 275
		and xpap.program_owner_code  = xad.program_owner_code
		and xpap.program_code = xad.program_code
		and xad.enabled_flag = 'Y'
		and (xad.ledger_id IS NULL OR xad.ledger_id = v_alc_ledger.ledger_id)
		and xaca.assignment_owner_code = xad.assignment_owner_code
		and xaca.assignment_code = xad.assignment_code
		and xaca.program_owner_code = xad.program_owner_code
		and xaca.program_code = xad.program_code
		and xal.accounting_class_code = xaca.accounting_class_code
		and xal.ae_header_id =  xah.ae_header_id
		and xah.ledger_id = v_alc_ledger.ledger_id
		and xah.balance_type_code = 'A'
		and xah.accounting_entry_status_code = 'F'
		and xal.ae_header_id = xdl.ae_header_id
		and xal.ae_line_num = xdl.ae_line_num
		and decode ( xaca.accounting_class_code ,'DISCOUNT', decode (v_alc_ledger.sla_ledger_cash_basis_flag , 'Y',  2 , 1) , 1 ) = 1
		/*
		Bug 5039683 For Cash Basis : Hard coded acc class 'Discount'
		Restricted 'Discount' acc class code to be fetched from debit side of Post Acc Program
		'PA_POSTACCOUNITNG_DEBIT' for cash basis txns, as for cash basis txn, 'Discount' should
		be on credit side of Post Acc Programs.

		For R12+, this need be reverted out and create seperate post acc program
		for cash basis include 'Discount' in credit side and remove from Debit.
		*/
		and xdl.application_id  =  DECODE(l_transfer_status_code, 'V',
							decode( l_Acct_Source_Code,	'AP_INV', 200,
									'AP_PAY', 200,
									'AP_APP', 200,
									'INV',    707,
									'WIP',    707,
									'RCV',    707),
									 275)
		and   NVL(xdl.source_distribution_id_num_2, -99) = DECODE(l_transfer_status_code,
										  'V',nvl(xdl.source_distribution_id_num_2,-99),
										   x_line_num
									    )
		and xdl.source_distribution_id_num_1 = DECODE(l_transfer_status_code, 'V',
										DECODE(l_Acct_Source_Code, 'AP_INV',
												DECODE ( l_document_payment_id ,
												     NULL , l_document_distribution_id,
													    l_system_reference5
												    ) ,
										  'AP_PAY', l_System_Reference5,
										  'AP_APP', l_System_Reference5,
										  'INV', l_System_Reference5,
										  'WIP', l_System_Reference5,
										  'RCV', l_System_Reference5),
										  x_expenditure_item_id)
		and xdl.source_distribution_type = DECODE(l_transfer_status_code,
										  'V', DECODE (l_Acct_Source_Code,
										       'AP_PAY','AP_PMT_DIST',
										       'AP_INV',	DECODE ( l_document_payment_id ,
														   NULL ,  'AP_INV_DIST',
															   'AP_PMT_DIST'
													 ),
										       'AP_APP','AP_PREPAY',
										       'RCV','RCV_RECEIVING_SUB_LEDGER',
										       'INV','MTL_TRANSACTION_ACCOUNTS',
										       'WIP','WIP_TRANSACTION_ACCOUNTS')
										, l_line_type );


		exception
		 when NO_DATA_FOUND then

				SELECT 'N'
				into l_alc_exists
				from dual
				WHERE NOT EXISTS (
				SELECT gl.ledger_id
				FROM   gl_alc_ledger_rships_v gl
				WHERE  gl.source_ledger_id = v_alc_ledger.set_of_books_id
				AND    gl.application_id = decode( l_Acct_Source_Code,	'AP_INV', 200,
								'AP_PAY', 200,
								'AP_APP', 200,
								'INV',    707,
								'WIP',    707,
								'RCV',    707,
								 0)
				AND    gl.currency_code = v_alc_ledger.currency_code
				AND    gl.relationship_enabled_flag = 'Y') ;

	      end;


  Elsif (l_historical_flag = 'Y') Then

	SELECT p_type.capital_cost_type_code
	INTO l_capital_cost_type
	FROM pa_project_types_all p_type,
	pa_projects_all proj,
	pa_cost_distribution_lines_all pa_cdl
	WHERE p_type.project_type = proj.project_type
	AND proj.project_id = pa_cdl.project_id
	AND pa_cdl.expenditure_item_id = x_expenditure_item_id
	AND pa_cdl.line_num = x_line_num
	AND p_type.org_id = v_alc_ledger.org_id;

	BEGIN

	IF (l_capital_cost_type = 'B') THEN
		SELECT nvl(burdened_cost,amount),
		exchange_rate,
		conversion_date
		INTO l_cip_cost,
		l_exchange_rate,
		l_gl_date
		FROM PA_MC_COST_DIST_LINES_ALL
		WHERE set_of_books_id = v_alc_ledger.ledger_id
		AND expenditure_item_id = x_expenditure_item_id
		AND line_num = x_line_num;
	ELSE
		SELECT amount,
		exchange_rate,
		conversion_date
		INTO l_cip_cost,
		l_exchange_rate,
		l_gl_date
		FROM PA_MC_COST_DIST_LINES_ALL
		WHERE set_of_books_id = v_alc_ledger.ledger_id
		AND expenditure_item_id = x_expenditure_item_id
		AND line_num = x_line_num;
	END IF;


	exception
		when NO_DATA_FOUND then
		l_alc_exists := 'N';

	End;

  END IF;

  IF ((l_transaction_source is not null and l_predefined_flag = 'N' and l_transfer_status_code = 'V')
      OR (l_line_type = 'I')
      OR (l_acct_event_id is null and l_transfer_status_code = 'A' and l_historical_flag = 'N')
      OR (l_alc_exists = 'N')) THEN

	/* Externally accounted transactions from user defined sources
	   or 'I' cdls
	   or interface to GL implementation option is set to No
	   or the Oracle Subledger where the txn originated does not have this alc enabled */





	x_err_stage    := 'Create ALC Project Asset Line details by GL rate';

	gl_mc_currency_pkg.get_rate(
		p_primary_set_of_books_id     => v_alc_ledger.set_of_books_id,
		p_reporting_set_of_books_id   => v_alc_ledger.ledger_id,
		p_trans_date                  => l_gl_date,
		p_trans_currency_code         => l_denom_currency_code,
		p_trans_conversion_type       => l_exchange_rate_type,
		p_trans_conversion_date       => l_gl_date,
		p_trans_conversion_rate       => l_exchange_rate,
		p_application_id              => 275,
		p_org_id                      => v_alc_ledger.org_id,
		p_fa_book_type_code           => NULL,
		p_je_source_name              => NULL,
		p_je_category_name            => NULL,
		p_result_code                 => l_result_code,
		p_denominator_rate            => l_denominator_rate,
		p_numerator_rate              => l_numerator_rate);


	IF l_exchange_rate_type = 'User' THEN
		l_cip_cost := pa_mc_currency_pkg.CurrRound ((l_denom_raw_cost*l_exchange_rate), v_alc_ledger.currency_code);

	ELSE    l_cip_cost := pa_mc_currency_pkg.CurrRound (((l_denom_raw_cost/l_denominator_rate)*l_numerator_rate),
	                                                   v_alc_ledger.currency_code);
		l_exchange_rate := l_numerator_rate/l_denominator_rate;
	END IF;



    END IF;



           INSERT into PA_MC_PRJ_AST_LINE_DTLS
           (
            SET_OF_BOOKS_ID,
            PROJ_ASSET_LINE_DTL_UNIQ_ID,
            PROJECT_ASSET_LINE_DETAIL_ID,
            CIP_COST,
            CURRENCY_CODE,
            EXCHANGE_RATE,
            CONVERSION_DATE
            )
            VALUES
            (
            v_alc_ledger.ledger_id,
            x_proj_asset_line_dtl_uniq_id,
            x_project_asset_line_detail_id,
            l_cip_cost,
            v_alc_ledger.currency_code,
            l_exchange_rate,
            l_gl_date
            );

    END LOOP;

exception
	when others then
	x_err_code := SQLCODE;
	RAISE;

end create_alc_asset_line_details;

----------------------------------------------------------------------------------------------------------

PROCEDURE create_alc_proj_asset_lines      (x_project_asset_line_id		IN NUMBER,
					    x_project_asset_line_detail_id	IN NUMBER,
					    x_rev_proj_asset_line_id		IN NUMBER,
					    x_original_asset_cost		IN NUMBER,
					    x_current_asset_cost		IN NUMBER,
					    x_err_stage				IN OUT NOCOPY VARCHAR2,
					    x_err_code				IN OUT NOCOPY NUMBER)

IS

CURSOR c_alc_ledger IS
  SELECT gl.ledger_id, gl.currency_code
  FROM   gl_alc_ledger_rships_v gl,
         pa_implementations imp
  WHERE  gl.source_ledger_id = imp.set_of_books_id
  AND    gl.application_id = 275
  AND    gl.org_id = imp.org_id
  AND    gl.relationship_enabled_flag = 'Y';

 l_orig_asset_cost      NUMBER :=0;
 l_curr_asset_cost      NUMBER :=0;
 l_cost_ratio		NUMBER :=0;


begin

  x_err_code     := 0;
  x_err_stage    := 'Create ALC Project Asset Line details';

  FOR v_alc_ledger IN c_alc_ledger LOOP

	IF (x_rev_proj_asset_line_id IS NOT NULL) THEN

	x_err_stage    := 'Create ALC Project Asset Line details for rev line';

		SELECT original_asset_cost,
		       current_asset_cost
		INTO l_orig_asset_cost,
		     l_curr_asset_cost
		FROM PA_MC_PRJ_AST_LINES_ALL
		WHERE set_of_books_id = v_alc_ledger.ledger_id
		AND project_asset_line_id = x_rev_proj_asset_line_id;

	ELSIF  (x_original_asset_cost <> x_current_asset_cost) THEN

        l_cost_ratio := x_current_asset_cost/x_original_asset_cost;

	x_err_stage    := 'Create ALC Project Asset Line details for split line';

                  SELECT original_asset_cost,
		         sum(current_asset_cost)
                  INTO l_orig_asset_cost,
		       l_curr_asset_cost
                  FROM PA_MC_PRJ_AST_LINES_ALL
                  WHERE set_of_books_id = v_alc_ledger.ledger_id
                  AND project_asset_line_detail_id = x_project_asset_line_detail_id
                  GROUP BY original_asset_cost;

		  l_curr_asset_cost := pa_mc_currency_pkg.CurrRound((l_cost_ratio * l_orig_asset_cost),
		                                                    v_alc_ledger.currency_code);

	ELSE

	x_err_stage    := 'Create ALC Project Asset Line details for new line';

                 SELECT nvl(sum(cip_cost),0)
                 INTO l_orig_asset_cost
                 FROM PA_MC_PRJ_AST_LINE_DTLS
                 WHERE set_of_books_id = v_alc_ledger.ledger_id
                 AND project_asset_line_detail_id = x_project_asset_line_detail_id;

		 l_curr_asset_cost := l_orig_asset_cost;

	END IF;

	INSERT into PA_MC_PRJ_AST_LINES_ALL
	(
	SET_OF_BOOKS_ID,
	PROJECT_ASSET_LINE_ID,
	ORIGINAL_ASSET_COST,
	CURRENT_ASSET_COST,
	PROJECT_ASSET_LINE_DETAIL_ID
	)
	VALUES
	(
	v_alc_ledger.ledger_id,
	x_project_asset_line_id,
	l_orig_asset_cost,
	l_curr_asset_cost,
	x_project_asset_line_detail_id
	);

    END LOOP;

exception
	when others then
	x_err_code := SQLCODE;
	RAISE;

end create_alc_proj_asset_lines;

----------------------------------------------------------------------------------------------------------

PROCEDURE update_alc_proj_asset_lines      (x_project_asset_line_id	IN NUMBER,
					    x_original_asset_cost	IN NUMBER,
					    x_current_asset_cost	IN NUMBER)
IS

CURSOR c_alc_ledger IS
  SELECT gl.ledger_id, gl.currency_code
  FROM   gl_alc_ledger_rships_v gl,
         pa_implementations imp
  WHERE  gl.source_ledger_id = imp.set_of_books_id
  AND    gl.application_id = 275
  AND    gl.org_id = imp.org_id
  AND    gl.relationship_enabled_flag = 'Y';

 l_cost_ratio		NUMBER := x_current_asset_cost/x_original_asset_cost;

begin

  FOR v_alc_ledger IN c_alc_ledger LOOP

     UPDATE PA_MC_PRJ_AST_LINES_ALL
     SET    current_asset_cost = pa_mc_currency_pkg.CurrRound((l_cost_ratio*original_asset_cost),
								v_alc_ledger.currency_code)
     WHERE  project_asset_line_id = x_project_asset_line_id
     AND    set_of_books_id = v_alc_ledger.ledger_id;

  END LOOP;

exception
	when others then
	RAISE;

end update_alc_proj_asset_lines;

----------------------------------------------------------------------------------------------------------

PROCEDURE create_alc_fa_mass_additions (x_project_asset_line_id		IN NUMBER,
					x_mass_addition_id		IN NUMBER,
					x_parent_mass_addition_id	IN NUMBER,
					x_fixed_assets_cost		IN NUMBER)
IS

CURSOR c_alc_ledger IS
  SELECT gl.ledger_id, gl.currency_code
  FROM   gl_alc_ledger_rships_v gl,
         pa_implementations imp
  WHERE  gl.source_ledger_id = imp.set_of_books_id
  AND    gl.application_id = 275
  AND    gl.org_id = imp.org_id
  AND    gl.relationship_enabled_flag = 'Y';

l_fixed_assets_alc_cost	NUMBER;
l_exchange_rate		NUMBER;

begin

FOR v_alc_ledger IN c_alc_ledger LOOP

	IF x_fixed_assets_cost = 0 THEN   /* To handle the case when merge code is 'MP' */
		l_fixed_assets_alc_cost := 0;
		l_exchange_rate := 0;
	ELSE
		SELECT current_asset_cost
		INTO l_fixed_assets_alc_cost
		FROM PA_MC_PRJ_AST_LINES_ALL
		WHERE project_asset_line_id = x_project_asset_line_id
		AND set_of_books_id = v_alc_ledger.ledger_id;

		l_exchange_rate := l_fixed_assets_alc_cost/x_fixed_assets_cost;

	END IF;

	INSERT into FA_MC_MASS_RATES
	(
	SET_OF_BOOKS_ID,
	MASS_ADDITION_ID,
	PARENT_MASS_ADDITION_ID,
	FIXED_ASSETS_COST,
	EXCHANGE_RATE,
	CREATED_BY,
	CREATION_DATE,
	LAST_UPDATED_BY,
	LAST_UPDATE_DATE,
	LAST_UPDATE_LOGIN
	)
	VALUES
	(
	v_alc_ledger.ledger_id,
	x_mass_addition_id,
	x_parent_mass_addition_id,
	l_fixed_assets_alc_cost,
	l_exchange_rate,
	x_created_by,
	sysdate,
	x_created_by,
	sysdate,
	x_last_update_login
	);

END LOOP;

exception
	when others then
	RAISE;

end create_alc_fa_mass_additions;

----------------------------------------------------------------------------------------------------------

-- Added procedure for bug 5401326
PROCEDURE set_request_id(x_passed_request_id IN NUMBER) IS
  BEGIN
        x_request_id := x_passed_request_id;
  END set_request_id;

END PA_FAXFACE;

/
