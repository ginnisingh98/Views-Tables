--------------------------------------------------------
--  DDL for Package Body PO_INQ_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_INQ_SV" as
/* $Header: POXPOVPB.pls 120.3.12010000.9 2012/05/03 11:17:21 vegajula ship $*/

--<HTML Agreement R12 Start>
G_PKG_NAME CONSTANT VARCHAR2(30) := 'PO_INQ_SV';
G_LOG_HEAD CONSTANT VARCHAR2(50) := 'po.plsql.'||G_PKG_NAME||'.';
G_DEBUG_STMT BOOLEAN := PO_DEBUG.is_debug_stmt_on;
G_DEBUG_UNEXP BOOLEAN := PO_DEBUG.is_debug_unexp_on;
--<HTML Agreement R12 End>

/*=============================  PO_INQ_SV  ===============================*/
/* Local procedure */
PROCEDURE get_lookup_dsp(p_lookup_type IN PO_LOOKUP_CODES.lookup_type%TYPE,
                           p_lookup_code IN PO_LOOKUP_CODES.lookup_code%TYPE,
                           x_displayed_field OUT NOCOPY PO_LOOKUP_CODES.displayed_field%TYPE);

/*===========================================================================

  PROCEDURE NAME:	get_action_history_values()

===========================================================================*/

PROCEDURE get_action_history_values (x_object_id        	IN NUMBER,
				     x_object_type_code 	IN VARCHAR2,
				     x_subtype_code    	 	IN OUT NOCOPY VARCHAR2,
				     x_type_name		OUT NOCOPY VARCHAR2,
				     x_document_number          OUT NOCOPY VARCHAR2,
				     x_preparer_id		OUT NOCOPY NUMBER,
				     x_security_level   	OUT NOCOPY VARCHAR2,
				     x_security_hierarchy_id    OUT NOCOPY NUMBER) is

x_progress 		VARCHAR2(3) := '';
l_org_id number; -- Bug 11782280
BEGIN
  x_progress := '010';

   -- Bug 11782280 start
 BEGIN

  if x_object_type_code = 'REQUISITION' then

      select org_id
   	into l_org_id
 	from PO_REQUISITION_HEADERS_ALL
    	where requisition_header_id = x_object_id;

/* bug 12654669 : BPA's and CPA's have object_code as PA. Adding same to below condition
   Regression due to bug 11782280*/
  elsif x_object_type_code in ('PO','PA') then

  -- Bug 11782280 start
    select org_id
   	into l_org_id
 	from po_headers_all
    	where po_header_id = x_object_id;

    elsif x_object_type_code in ('RELEASE') then


  select org_id
  into l_org_id
 	from po_releases_all
  where po_release_id = x_object_id;



end if;

exception

when no_data_found then
	null;
end;

       PO_MOAC_UTILS_PVT.set_org_context(l_org_id);

    	-- Bug 11782280 End

  /* Get the subtype and preparer  */

  SELECT subtype,
         preparer_id,
         type_name,
         document_number
  INTO   x_subtype_code,
         x_preparer_id,
         x_type_name,
	 x_document_number
  FROM   PO_DOCUMENT_HEADERS_VIEW
  WHERE  document_id = x_object_id
  AND    type_code   = x_object_type_code;


  x_progress := '020';


  /* Get the security_level */

    SELECT podt.security_level_code
    INTO   x_security_level
    FROM   po_document_types podt
    WHERE  podt.document_subtype   = x_subtype_code
    AND    podt.document_type_code = x_object_type_code;

  x_progress := '030';

  /* Get the security_hierarchy_id */


  SELECT psp.security_position_structure_id
  INTO   x_security_hierarchy_id
  FROM   po_system_parameters psp;



EXCEPTION
  WHEN OTHERS THEN
    -- dbms_output.put_line('In exception');
    po_message_s.sql_error('get_action_history_values', x_progress, sqlcode);
    raise;

END get_action_history_values;


/*===========================================================================

  PROCEDURE NAME:	get_po_doc_access_sec_level()

===========================================================================*/

PROCEDURE get_po_doc_access_sec_level(x_standard_security      OUT NOCOPY  VARCHAR2,
         			      x_blanket_security       OUT NOCOPY  VARCHAR2,
         			      x_contract_security      OUT NOCOPY  VARCHAR2,
         			      x_planned_security       OUT NOCOPY  VARCHAR2,
         			      x_blanket_rel_security   OUT NOCOPY  VARCHAR2,
         			      x_scheduled_rel_security OUT NOCOPY  VARCHAR2,
				      x_security_hierarchy_id  OUT NOCOPY  NUMBER)

									    is

/* Start  Bug 3336172 */
TYPE g_sec_level_tbl_type      IS TABLE OF po_document_types_b.security_level_code%TYPE;
TYPE g_doc_type_code_tbl_type  IS TABLE OF po_document_types_b.document_type_code%TYPE;
TYPE g_doc_subtype_tbl_type    IS TABLE OF po_document_types_b.document_subtype%TYPE;

l_sec_level_tbl        g_sec_level_tbl_type;
l_doc_type_code_tbl    g_doc_type_code_tbl_type;
l_doc_subtype_tbl      g_doc_subtype_tbl_type;

/* End Bug 3331672 */

x_progress VARCHAR2(3) := '';


BEGIN
  x_progress := '010';

  /* Get the access and security level codes for all the four types of
   * Purchase Orders
   */

  /* Start Bug 3336172 - Improving performance of the query below by:
   * A.  Removing the 6 way cartesian join all on the same table.
   *     Instead, use a PL-SQL table variable to store the data
   *     we need, and then loop through it.  This should avoid the
   *     massive join while also avoiding 6 PL/SQL to SQL context switches.
   * B.  Use the PO_DOCUMENT_TYPES_B base view instead of PO_DOCUMENT_TYPES
   *     There is no need for translation in this code, so the base view, which
   *     does not join with a translation table is a better choice.
   * Note: we use three PL-SQL tables, as in 8I DB, you cannot bulk collect
   *       into a table of records!  In 9I, that is allowed, but for now,
   *       the code must also be compatible with 8I.
   */

  SELECT security_level_code, document_type_code, document_subtype
  BULK COLLECT into l_sec_level_tbl, l_doc_type_code_tbl, l_doc_subtype_tbl
  FROM po_document_types_b
  WHERE (document_type_code = 'PO' and document_subtype = 'STANDARD')
     or (document_type_code = 'PA' and document_subtype = 'BLANKET')
     or (document_type_code = 'PA' and document_subtype = 'CONTRACT')
     or (document_type_code = 'PO' and document_subtype = 'PLANNED')
     or (document_type_code = 'RELEASE' and document_subtype = 'BLANKET')
     or (document_type_code = 'RELEASE' and document_subtype = 'SCHEDULED')
  ;

  FOR i IN 1..l_sec_level_tbl.COUNT
  LOOP
      IF (l_doc_type_code_tbl(i) = 'PO' and l_doc_subtype_tbl(i) = 'STANDARD')
         THEN x_standard_security := l_sec_level_tbl(i);
      ELSIF (l_doc_type_code_tbl(i) = 'PA' and l_doc_subtype_tbl(i) = 'BLANKET')
         THEN x_blanket_security := l_sec_level_tbl(i);
      ELSIF (l_doc_type_code_tbl(i) = 'PA' and l_doc_subtype_tbl(i) = 'CONTRACT')
         THEN x_contract_security := l_sec_level_tbl(i);
      ELSIF (l_doc_type_code_tbl(i) = 'PO' and l_doc_subtype_tbl(i) = 'PLANNED')
         THEN x_planned_security := l_sec_level_tbl(i);
      ELSIF (l_doc_type_code_tbl(i) = 'RELEASE' and l_doc_subtype_tbl(i) = 'BLANKET')
         THEN x_blanket_rel_security := l_sec_level_tbl(i);
      ELSIF (l_doc_type_code_tbl(i) = 'RELEASE' and l_doc_subtype_tbl(i) = 'SCHEDULED')
         THEN x_scheduled_rel_security := l_sec_level_tbl(i);
      END IF;
  END LOOP;

  /* End Bug 3336172 */


  x_progress := '020';

  /* Get the security_hierarchy_id */


  SELECT psp.security_position_structure_id
  INTO   x_security_hierarchy_id
  FROM   po_system_parameters psp;


EXCEPTION
  WHEN OTHERS THEN
    -- dbms_output.put_line('In exception');
    po_message_s.sql_error('get_po_doc_access_sec_level', x_progress, sqlcode);
    raise;

END get_po_doc_access_sec_level;



/*===========================================================================

  FUNCTION NAME:	get_active_enc_amount()

===========================================================================*/

FUNCTION  get_active_enc_amount(x_rate 			IN NUMBER,
				x_enc_amount    	IN NUMBER,
				x_shipment_type		IN VARCHAR2,
				x_po_distribution_id	IN NUMBER)
							RETURN NUMBER is

-- <Encumbrance FPJ START>
-- refactored entire procedure to remove duplicate logic
-- and call the new get_active_encumbrance_amount API instead

l_return_status         VARCHAR2(1);
l_doc_type              PO_DOCUMENT_TYPES.document_type_code%TYPE;
l_progress              VARCHAR2(3);
x_active_enc_amount	NUMBER;

BEGIN

l_progress := '000';

-- <Complex Work R12>: Add PREPAYMENT shipment type

IF (x_shipment_type IN ('STANDARD', 'PLANNED', 'PREPAYMENT')) THEN
   l_progress := '010';
   l_doc_type := PO_INTG_DOCUMENT_FUNDS_GRP.g_doc_type_PO;
ELSIF (x_shipment_type IN ('BLANKET', 'SCHEDULED')) THEN
   l_progress := '020';
   l_doc_type := PO_INTG_DOCUMENT_FUNDS_GRP.g_doc_type_RELEASE;
ELSE
   l_progress := '030';
   l_doc_type := PO_INTG_DOCUMENT_FUNDS_GRP.g_doc_type_PA;
END IF;

l_progress := '040';

PO_INTG_DOCUMENT_FUNDS_GRP.get_active_encumbrance_amount(
   p_api_version       => 1.0
,  p_init_msg_list     => FND_API.G_FALSE
,  p_validation_level  => FND_API.G_VALID_LEVEL_FULL
,  x_return_status     => l_return_status
,  p_doc_type          => l_doc_type
,  p_distribution_id   => x_po_distribution_id
,  x_active_enc_amount => x_active_enc_amount
);

l_progress := '050';

IF (l_return_status = FND_API.g_ret_sts_UNEXP_ERROR) THEN
   RAISE FND_API.g_EXC_UNEXPECTED_ERROR;
END IF;

--<ENCUMBRANCE FPJ END>

return(x_active_enc_amount);

EXCEPTION
  WHEN OTHERS THEN
    po_message_s.sql_error('get_active_enc_amount', l_progress, sqlcode);
    return (-1);

END get_active_enc_amount;


/*===========================================================================

  FUNCTION NAME:	get_dist_amount()

===========================================================================*/

/* Changed due to bug 601388
 Removed the IN parameter x_rate from the function and the parameters
 related usage  in the function
*/

FUNCTION  get_dist_amount
(
    p_quantity_ordered       IN     NUMBER
,   p_price_override	     IN     NUMBER
,   p_amount_ordered         IN     NUMBER                    -- <SERVICES FPJ>
,   p_po_line_loc_id         IN     NUMBER    -- <Complex Work R12>
,	p_po_distribution_id	 IN		NUMBER    -- Bug 13440718
)
RETURN NUMBER
IS
x_min_unit		NUMBER;
x_precision		NUMBER;
x_dist_amount		NUMBER;

l_value_basis      PO_LINE_LOCATIONS_ALL.value_basis%TYPE;  -- <Complex Work R12>
l_qty_cancelled    NUMBER  := 0;
l_amt_cancelled    NUMBER  := 0;

BEGIN

    -- <SERVICES FPJ START>
    -- <Complex Work R12 Start>

    -- Get Value Basis for the line location.
    --

    SELECT   poll.value_basis
    INTO     l_value_basis
    FROM     po_line_locations_all poll
    WHERE    poll.line_location_id = p_po_line_loc_id;

    -- <Complex Work R12 End>

    -- Determine if the Line is Amount or Quantity based
    -- and calculate the Distribution Amount accordingly.

	/*
	Bug 13440718: Getting the quantity cancelled/amount ccancelled and subtracted them from
	p_amount_ordered, p_quantity_ordered
	*/

	SELECT quantity_cancelled, amount_cancelled
	INTO	l_qty_cancelled, l_amt_cancelled
	FROM PO_DISTRIBUTIONS_ALL
	WHERE po_distribution_id = p_po_distribution_id;


    IF ( l_value_basis IN ('FIXED PRICE','RATE') )
    THEN
        x_dist_amount := p_amount_ordered-l_amt_cancelled;
    ELSE
        x_dist_amount := (p_quantity_ordered-l_qty_cancelled) * p_price_override;
    END IF;

    -- Round the Distribution Amount.
    --
    get_func_currency_attributes(x_min_unit, x_precision);

    x_dist_amount := round ( x_dist_amount
                           , nvl(x_min_unit, x_precision)
                           );

    -- <SERVICES FPJ END>

  return(x_dist_amount);

EXCEPTION
  WHEN OTHERS THEN
    return(-1);

END get_dist_amount;


/*===========================================================================

  PROCEDURE NAME:	get_func_currency_attributes;

===========================================================================*/
PROCEDURE  get_func_currency_attributes(x_min_unit   OUT NOCOPY NUMBER,
  				        x_precision  OUT NOCOPY NUMBER) is

BEGIN

  SELECT fc.minimum_accountable_unit,
	 fc.precision
  INTO   x_min_unit,
         x_precision
  FROM   fnd_currencies			fc,
	 gl_sets_of_books		sob,
	 financials_system_parameters   fsp
  WHERE  fsp.set_of_books_id = sob.set_of_books_id
  AND	 sob.currency_code   = fc.currency_code;

EXCEPTION
  WHEN OTHERS THEN
    /*dbms_output.put_line('In exception');
    po_message_s.sql_error('get_func_currency_attributes',x_progress, sqlcode);
    raise;*/
   null;

END get_func_currency_attributes;

/*===========================================================================

  FUNCTION NAME:	get_person_name()

===========================================================================*/
FUNCTION  get_person_name (x_person_id 	IN  NUMBER) RETURN VARCHAR2 is

x_person_name  VARCHAR2(240);

BEGIN

/* Bug 3223368. Replaced the old statement which was there in the cursor with
                the below statement to improve performance.

                Any time we will have one record in the per_all_people_f which
                will be valid in the sysdate and this will be the record with
                the maximum effective_start_date.

                Now with this fix, we will avoid the sort which was most expensive.
*/

   SELECT prf.full_name
   INTO   x_person_name
   FROM   per_all_people_f prf
   WHERE  prf.person_id = x_person_id
   AND    trunc(sysdate) between prf.effective_start_date and prf.effective_end_date;

   return(x_person_name);

EXCEPTION
  WHEN OTHERS THEN
    return('');

END get_person_name;

/*===========================================================================

  FUNCTION NAME:	get_wip_operation_code

===========================================================================*/
FUNCTION  get_wip_operation_code(x_wip_entity_id 	 IN  NUMBER,
				 x_wip_operation_seq_num IN  NUMBER,
				 x_destination_org_id    IN  NUMBER,
				 x_wip_rep_schedule_id   IN  NUMBER)
							RETURN VARCHAR2 IS

x_wip_operation_code  VARCHAR2(4);

BEGIN

  SELECT bso.operation_code
  INTO   x_wip_operation_code
  FROM   bom_standard_operations  bso,
         wip_operations           wop
  WHERE ( x_wip_rep_schedule_id IS NULL
          OR wop.repetitive_schedule_id
                                = x_wip_rep_schedule_id)
  AND wop.wip_entity_id         = x_wip_entity_id
  AND wop.organization_id       = x_destination_org_id
  AND wop.operation_seq_num     = x_wip_operation_seq_num
  AND wop.standard_operation_id = bso.standard_operation_id(+)
  AND NVL(bso.organization_id,x_destination_org_id)
        = x_destination_org_id;

  return(x_wip_operation_code);

EXCEPTION
  WHEN OTHERS THEN
    return('');

END get_wip_operation_code;


/*===========================================================================

  FUNCTION NAME:	get_bom_department_code

===========================================================================*/
FUNCTION  get_bom_department_code(x_wip_entity_id 	 IN  NUMBER,
				 x_wip_operation_seq_num IN  NUMBER,
				 x_destination_org_id    IN  NUMBER,
				 x_wip_rep_schedule_id   IN  NUMBER)
							RETURN VARCHAR2 IS

x_bom_department_code  VARCHAR2(10);

BEGIN

  SELECT bod.department_code
  INTO   x_bom_department_code
  FROM   bom_departments	  bod,
         wip_operations           wop
  WHERE ( x_wip_rep_schedule_id IS NULL
          OR wop.repetitive_schedule_id
                            = x_wip_rep_schedule_id)
  AND wop.wip_entity_id     = x_wip_entity_id
  AND wop.organization_id   = x_destination_org_id
  AND wop.operation_seq_num = x_wip_operation_seq_num
  AND wop.department_id     = bod.department_id
  AND bod.organization_id   = x_destination_org_id;

  return(x_bom_department_code);

EXCEPTION
  WHEN OTHERS THEN
    return('');

END get_bom_department_code;


/*===========================================================================

  FUNCTION NAME:	get_assembly_quantity

===========================================================================*/
FUNCTION  get_assembly_quantity(x_item_id  		IN NUMBER,
				x_wip_entity_id 	IN NUMBER,
				x_wip_operation_seq_num IN NUMBER,
				x_wip_resource_seq_num  IN NUMBER,
				x_destination_org_id 	IN NUMBER,
				x_wip_rep_schedule_id   IN NUMBER,
				x_quantity_ordered	IN NUMBER,
                                p_item_organization_id  IN NUMBER)  -- <HTMLAC>
							RETURN NUMBER IS

x_assembly_quantity  NUMBER;

l_item_organization_id NUMBER; -- <HTMLAC>

BEGIN

  -- <HTMLAC START>
  IF (p_item_organization_id IS NOT NULL) THEN
    l_item_organization_id := p_item_organization_id;
  ELSE
    -- use inv org id from current org if it is not specified
    SELECT inventory_organization_id
    INTO   l_item_organization_id
    FROM   financials_system_parameters;
  END IF;
  -- <HTMLAC END>

  SELECT decode(msi.outside_operation_uom_type,
              'ASSEMBLY',x_quantity_ordered,
              'RESOURCE',x_quantity_ordered /
                          decode(wor.usage_rate_or_amount,
                                   0,x_quantity_ordered,
                                     wor.usage_rate_or_amount)
              )
  INTO 	x_assembly_quantity
  FROM 	wip_operation_resources      wor,
        mtl_system_items             msi
  WHERE wor.wip_entity_id                  = x_wip_entity_id
  AND   nvl(wor.repetitive_schedule_id,-1) = nvl(x_wip_rep_schedule_id,-1)
  AND   wor.operation_seq_num              = x_wip_operation_seq_num
  AND   wor.resource_seq_num               = x_wip_resource_seq_num
  AND   wor.organization_id                = x_destination_org_id
  AND   msi.inventory_item_id	           = x_item_id
  AND   msi.organization_id		   = l_item_organization_id;  -- <HTMLAC>

  /* Bug 2899560. Need to round off the quantity */
  x_assembly_quantity  := round ( x_assembly_quantity,6);

  return(x_assembly_quantity);

EXCEPTION
  when no_data_found then
    --Bug# 2000013 togeorge 09/18/2001
    --for eAM workorders there wouldn't be any resource info and the above
    --sql would raise no_data_found exception
    return(x_quantity_ordered);
  WHEN OTHERS THEN
    return(to_number(NULL));

END get_assembly_quantity;


/*===========================================================================

  FUNCTION NAME:	get_resource_quantity

===========================================================================*/
FUNCTION  get_resource_quantity(x_item_id  		IN NUMBER,
				x_wip_entity_id 	IN NUMBER,
				x_wip_operation_seq_num IN NUMBER,
				x_wip_resource_seq_num  IN NUMBER,
				x_destination_org_id 	IN NUMBER,
				x_wip_rep_schedule_id   IN NUMBER,
				x_quantity_ordered	IN NUMBER,
                                p_item_organization_id  IN NUMBER)  -- <HTMLAC>
							RETURN NUMBER IS

x_resource_quantity  NUMBER;

l_item_organization_id NUMBER; -- <HTMLAC>

BEGIN

  -- <HTMLAC START>
  IF (p_item_organization_id IS NOT NULL) THEN
    l_item_organization_id := p_item_organization_id;
  ELSE
    -- use inv org id from current org if it is not specified
    SELECT inventory_organization_id
    INTO   l_item_organization_id
    FROM   financials_system_parameters;
  END IF;
  -- <HTMLAC END>

  SELECT decode(msi.outside_operation_uom_type,
               'ASSEMBLY',x_quantity_ordered  * wor.usage_rate_or_amount,
               'RESOURCE',x_quantity_ordered)
  INTO 	x_resource_quantity
  FROM 	wip_operation_resources      wor,
        mtl_system_items             msi
  WHERE wor.wip_entity_id                  = x_wip_entity_id
  AND   nvl(wor.repetitive_schedule_id,-1) = nvl(x_wip_rep_schedule_id,-1)
  AND   wor.operation_seq_num              = x_wip_operation_seq_num
  AND   wor.resource_seq_num               = x_wip_resource_seq_num
  AND   wor.organization_id                = x_destination_org_id
  AND   msi.inventory_item_id	           = x_item_id
  AND   msi.organization_id		   = l_item_organization_id; -- <HTMLAC>

  return(x_resource_quantity);

EXCEPTION
  when no_data_found then
    --Bug# 2000013 togeorge 09/18/2001
    --for eAM workorders there wouldn't be any resource info and the above
    --sql would raise no_data_found exception
    return(x_quantity_ordered);
  WHEN OTHERS THEN
    return(to_number(NULL));

END get_resource_quantity;



/*===========================================================================

  FUNCTION NAME:	get_po_number

===========================================================================*/
FUNCTION  get_po_number (x_line_location_id  IN NUMBER) RETURN VARCHAR2 is

x_po_number  VARCHAR2(20);

BEGIN

/*
Performance Fix (bug 414200)
The following code is being replaced for performance reasons:
  SELECT po_num
  INTO   x_po_number
  FROM   po_line_locations_inq_v
  WHERE  x_line_location_id = line_location_id;
*/

  SELECT POH.segment1
  INTO	 x_po_number
  FROM 	 po_headers_all POH, po_line_locations_all PLL --<Shared Proc FPJ>
  WHERE  POH.po_header_id = PLL.po_header_id and
         PLL.line_location_id = x_line_location_id;


  return(x_po_number);

EXCEPTION
  WHEN OTHERS THEN
    return('');

END get_po_number;


/*===========================================================================

  FUNCTION NAME:	get_so_number()

===========================================================================*/
FUNCTION  get_so_number (x_requisition_header_id IN VARCHAR2,
			 x_requisition_line_id IN NUMBER) RETURN VARCHAR2 is

x_so_number  number;
x_order_source_id number;

BEGIN
  /* replacing the select statement with the new OE API. */
     select order_source_id
     into   x_order_source_id
     from   po_system_parameters;

--Bug# 1392077
--Toju George 08/31/2000
--Modified the call to procedure to replace req_num and line_num with ids.
/*     x_so_number := OE_ORDER_IMPORT_INTEROP_PUB.Get_Order_Number(x_order_source_id,
                                                                 x_segment1,
                                                                 to_char(x_line_num));
*/
     x_so_number := OE_ORDER_IMPORT_INTEROP_PUB.Get_Order_Number(x_order_source_id,
                                                                 x_requisition_header_id,
                                                                 to_char(x_requisition_line_id));

  /* SELECT distinct(soh.order_number)
  INTO   x_so_number
  FROM   so_lines sol,
         so_headers soh,
         po_system_parameters psp
  WHERE  sol.original_system_line_reference = to_char(x_line_num)
    AND  soh.original_system_reference      = x_segment1
    AND  sol.header_id                      = soh.header_id
    AND  soh.original_system_source_code    = psp.order_source_id;
  */
  return(to_char(x_so_number));

EXCEPTION
  WHEN OTHERS THEN
    return('');

END get_so_number;

/*===========================================================================

  FUNCTION NAME:	shipment_from_req

===========================================================================*/

FUNCTION shipment_from_req  (x_line_location_id	  IN  NUMBER)
	RETURN BOOLEAN
IS
	x_num_records 	NUMBER := 0;
BEGIN

    IF x_line_location_id IS NOT NULL THEN

	SELECT	count(*)
	INTO	x_num_records
	FROM	po_requisition_lines_all --<Shared Proc FPJ>
	WHERE	line_location_id = x_line_location_id;

	IF x_num_records > 0 THEN
	    return (TRUE);
	ELSE
	    return (FALSE);
	END IF;

    ELSE
	return (FALSE);
    END IF;

EXCEPTION
    WHEN OTHERS THEN
	return(FALSE);
END;

/*===========================================================================

  FUNCTION NAME:	get_po_total

===========================================================================*/

FUNCTION get_po_total (x_type_lookup_code  IN  VARCHAR2,
		       x_po_header_id	   IN  NUMBER,
		       x_po_release_id     IN  NUMBER)
	return NUMBER
IS
	x_total_level	VARCHAR2(2);                -- <GC FPJ>
	x_total		NUMBER;
BEGIN

  /*  Bug : 1056562 Reverting back to 10.7 status. We should be displaying
            Released amount not agreed amount.
  */

  if (x_type_lookup_code = 'STANDARD') then

    x_total_level := 'H';

  elsif (x_type_lookup_code = 'CONTRACT') then

    -- <GC FPJ>
    -- x_total_level should be 'GC' if it is global contract

    IF  (PO_GA_PVT.is_global_agreement(x_po_header_id)) THEN
        x_total_level := 'GC';
    ELSE
        x_total_level := 'C';
    END IF;

  elsif (x_type_lookup_code = 'BLANKET') then

  -- Bug 2954456 : The level needs to be set as 'G' for a global agreement to calculate the
  -- correct amount released

   -- <GC FPJ START>
   -- change x_total_level for global agreemnt from 'G' to 'GA'
   -- to make it consistent with GC. Also, x_total_level for Blanket should
   -- be 'B' instead of 'H' (although they mean the same in get_total)

   if PO_GA_PVT.is_global_agreement(x_po_header_id) then

      x_total_level := 'GA';
   else

      x_total_level := 'B';
   end if;

   -- <GC FPJ END>

  elsif (x_type_lookup_code = 'PLANNED') then

    x_total_level := 'H';

  end if;

  if (x_po_release_id is NOT NULL) then
    x_total_level := 'R';
    x_total := po_core_s.get_total(x_total_level, x_po_release_id);

  else
    x_total := po_core_s.get_total(x_total_level, x_po_header_id);

  end if;

  return x_total;

END;


/*===========================================================================

  PROCEDURE NAME:	get_post_query_info

===========================================================================*/

PROCEDURE get_post_query_info (
			x_cancelled_by	    	IN     NUMBER,
			x_closed_by	    	IN     NUMBER,
			x_agent_id		IN     NUMBER,
			x_type_lookup_code  	IN     VARCHAR2,
		        x_po_header_id	    	IN     NUMBER,
		        x_po_release_id     	IN     NUMBER,
			x_po_line_id		IN     NUMBER,
			x_line_location_id	IN     NUMBER,
			x_agent_name		IN OUT NOCOPY VARCHAR2,
			x_closed_by_name    	IN OUT NOCOPY VARCHAR2,
			x_cancelled_by_name 	IN OUT NOCOPY VARCHAR2,
			x_base_currency		IN OUT NOCOPY VARCHAR2,
			x_amount		IN OUT NOCOPY NUMBER

) IS

l_po_header_id          number;
l_quantity_released     number;
l_db_amount             po_lines_all.amount%type;
l_value_basis           po_line_types_b.order_type_lookup_code%type;

BEGIN

   IF x_agent_id IS NOT NULL THEN
       x_agent_name := get_person_name(x_agent_id);
   END IF;

/* Bug 642604 - Getting cancelled by name using cancelled by id
   instead of agent id */
   IF x_cancelled_by IS NOT NULL THEN
	x_cancelled_by_name := get_person_name(x_cancelled_by);
   END IF;

/* Bug 1341727 Amitabh use closed by instead of agent_id */

   IF x_closed_by IS NOT NULL THEN
	x_closed_by_name := get_person_name(x_closed_by);
   END IF;

   x_base_currency := po_core_s2.get_base_currency;

   IF x_po_line_id IS NOT NULL THEN

   -- Bug 2954456 : The amount released has to be calculated in a different way for GA lines
   -- SERVICES FPJ : amount is derived from the db for service lines.

      Begin
        select pol.po_header_id ,
               pol.amount,
               plt.order_type_lookup_code
        into l_po_header_id,
             l_db_amount,          -- SERVICES FPJ
             l_value_basis         -- SERVICES FPJ
        from po_lines_all pol,
             po_line_types_b plt
        where pol.po_line_id = x_po_line_id
        and   pol.line_type_id = plt.line_type_id;
      Exception
        when others then
          l_po_header_id := null;
          l_db_amount := null;
          l_value_basis := null;
      end;

    IF l_value_basis in ('RATE' , 'FIXED PRICE') THEN             -- SERVICES FPJ

     x_amount := l_db_amount;                                     -- SERVICES FPJ

    ELSE

     if PO_GA_PVT.is_global_agreement(l_po_header_id) then
        PO_CORE_S.get_ga_line_amount_released( x_po_line_id,         -- IN
                                               l_po_header_id,       -- OUT
                                               l_quantity_released,  -- OUT
                                               x_amount          );  -- OUT
     else
       x_amount := PO_CORE_S.GET_TOTAL('L', x_po_line_id);
     end if;

   END IF;

   ELSIF x_line_location_id IS NOT NULL THEN
       x_amount := PO_CORE_S.GET_TOTAL('S', x_line_location_id);
   ELSIF x_po_release_id IS NOT NULL THEN
       x_amount := get_po_total(x_type_lookup_code, null, x_po_release_id);
   ELSIF x_po_header_id IS NOT NULL THEN
       x_amount := GET_PO_TOTAL(x_type_lookup_code, x_po_header_id, NULL);
   END IF;

END;

/*===========================================================================

  PROCEDURE NAME:	get_distribution_info

===========================================================================*/

PROCEDURE get_distribution_info (
			x_deliver_to_person_id  IN     NUMBER,
			x_closed_by	    	IN     NUMBER,
			x_agent_id		IN     NUMBER,
			x_item_id		IN     NUMBER,
			x_wip_entity_id		IN     NUMBER,
			x_wip_operation_seq_num IN     NUMBER,
			x_wip_resource_seq_num  IN     NUMBER,
			x_destination_org_id    IN     NUMBER,
			x_wip_rep_schedule_id   IN     NUMBER,
			x_quantity_ordered	IN     NUMBER,
			x_rate			IN     NUMBER,
			x_price_override	IN     NUMBER,
            x_amount_ordered    IN     NUMBER,                -- <SERVICES FPJ>
            x_po_line_id        IN     NUMBER,                -- <SERVICES FPJ>
			x_line_location_id	IN     NUMBER,
			x_encumbered_amount	IN     NUMBER,
			x_shipment_type		IN     VARCHAR2,
			x_po_distribution_id    IN     NUMBER,
			x_deliver_to_person	IN OUT NOCOPY VARCHAR2,
			x_agent_name		IN OUT NOCOPY VARCHAR2,
			x_closed_by_name    	IN OUT NOCOPY VARCHAR2,
			x_base_currency		IN OUT NOCOPY VARCHAR2,
			x_assembly_quantity	IN OUT NOCOPY NUMBER,
		        x_resource_quantity	IN OUT NOCOPY NUMBER,
			x_wip_operation_code    IN OUT NOCOPY VARCHAR2,
			x_bom_department_code   IN OUT NOCOPY VARCHAR2,
			x_active_encumb_amount   IN OUT NOCOPY NUMBER,
			x_distribution_amount	IN OUT NOCOPY NUMBER

) IS BEGIN

   IF x_agent_id IS NOT NULL THEN
       x_agent_name := get_person_name(x_agent_id);
   END IF;

   IF x_deliver_to_person_id IS NOT NULL THEN
	x_deliver_to_person := get_person_name(x_deliver_to_person_id);
   END IF;

   IF x_closed_by IS NOT NULL THEN
	x_closed_by_name := get_person_name(x_closed_by);
   END IF;

   x_base_currency := po_core_s2.get_base_currency;

   IF x_wip_entity_id IS NOT NULL THEN
       x_assembly_quantity := PO_INQ_SV.GET_ASSEMBLY_QUANTITY(
				x_item_id,
				x_wip_entity_id,
        			x_wip_operation_seq_num,
				x_wip_resource_seq_num,
        			x_destination_org_id,
				x_wip_rep_schedule_id,
				x_quantity_ordered);

       x_resource_quantity := PO_INQ_SV.GET_RESOURCE_QUANTITY(
				x_item_id,
				x_wip_entity_id,
        			x_wip_operation_seq_num,
				x_wip_resource_seq_num,
        			x_destination_org_id,
				x_wip_rep_schedule_id,
				x_quantity_ordered);


       x_wip_operation_code := PO_INQ_SV.GET_WIP_OPERATION_CODE(
				x_WIP_ENTITY_ID,
        			x_WIP_OPERATION_SEQ_NUM,
				x_DESTINATION_ORG_ID,
        			x_WIP_REP_SCHEDULE_ID) ;

       x_bom_department_code := PO_INQ_SV.GET_BOM_DEPARTMENT_CODE(
				x_WIP_ENTITY_ID,
        			x_WIP_OPERATION_SEQ_NUM,
				x_DESTINATION_ORG_ID,
        			x_WIP_REP_SCHEDULE_ID);

    END IF;

/* Changed due to bug 601388
Removed the IN parameter x_rate when calling the function
*/

    x_distribution_amount := PO_INQ_SV.GET_DIST_AMOUNT(
				x_QUANTITY_ORDERED,
       				x_PRICE_OVERRIDE,
                X_AMOUNT_ORDERED,                             -- <SERVICES FPJ>
				X_LINE_LOCATION_ID,                           -- <Complex Work R12>
				x_po_distribution_id);                        -- Bug 13440718


    x_active_encumb_amount := PO_INQ_SV.GET_ACTIVE_ENC_AMOUNT(
				x_RATE,
				x_ENCUMBERED_AMOUNT,
       				x_SHIPMENT_TYPE,
				x_PO_DISTRIBUTION_ID);

END;

/*===========================================================================

  PROCEDURE NAME:	get_org_info()

===========================================================================*/
 PROCEDURE get_org_info(x_destination_org_id  IN  number,
                        x_expenditure_org_id  IN  number,
                        x_ship_to_org_id      IN  number ,
                        x_dest_org_name       IN OUT NOCOPY  varchar2,
                        x_exp_org_name        IN OUT NOCOPY  varchar2,
                        x_ship_to_org_name    IN OUT NOCOPY  varchar2) is

x_progress  varchar2(3) := '000';

cursor c1(x_org_id IN number) is
  select hout.name
  from   hr_all_organization_units_tl hout,
         hr_org_units_no_join hrou
  where  hrou.organization_id  = x_org_id
  and    hrou.organization_id = hout.organization_id
  and    hout.language = userenv('lang');

BEGIN

     /* for deliver to org */
     x_progress  := '001';
    if x_destination_org_id is not null then
     OPEN c1(x_destination_org_id);
        FETCH c1 into x_dest_org_name  ;
        IF c1%NOTFOUND then
           x_dest_org_name  := NULL;
        END IF;
     CLOSE c1;
    end if;

     /* for expenditure org */
     x_progress  := '002';
    if x_expenditure_org_id is not null then
     OPEN c1(x_expenditure_org_id);
        FETCH c1 into x_exp_org_name  ;
        IF c1%NOTFOUND then
           x_exp_org_name  := NULL;
        END IF;
     CLOSE c1;
   end if;

     /* for ship to org */
     x_progress  := '003';
   if x_ship_to_org_id is not null then
     OPEN c1(x_ship_to_org_id);
        FETCH c1 into x_ship_to_org_name  ;
        IF c1%NOTFOUND then
           x_ship_to_org_name  := NULL;
        END IF;
     CLOSE c1;
   end if;

EXCEPTION
  WHEN OTHERS THEN
    po_message_s.sql_error('po_inq_sv.get_org_info', x_progress, sqlcode);
    raise;
END;

/*===========================================================================

  PROCEDURE NAME:	get_location_info()

===========================================================================*/
PROCEDURE get_location_info(x_deliver_to_loc_id   IN  number,
                           x_bill_to_loc_id      IN  number,
                           x_ship_to_loc_id      IN  number ,
                           x_dest_location_code  IN OUT NOCOPY  varchar2,
                           x_bill_to_loc_code    IN OUT NOCOPY  varchar2,
                           x_ship_to_loc_code    IN OUT NOCOPY  varchar2) is

x_progress  varchar2(3) := '000';

cursor c1(x_location_id IN number) is
   select location_code
   from hr_locations
   where location_id = x_location_id;

BEGIN
   /* for deliver to location */
       x_progress  := '001';
   if x_deliver_to_loc_id is not null then
     OPEN c1(x_deliver_to_loc_id);
        FETCH c1 into x_dest_location_code;
        IF c1%NOTFOUND then
           x_dest_location_code := NULL;
        END IF;
      CLOSE c1;
   end if;

  /* for bill to location */
       x_progress  := '002';
   if x_bill_to_loc_id is not null then
     OPEN c1(x_bill_to_loc_id);
        FETCH c1 into x_bill_to_loc_code;
        IF c1%NOTFOUND then
           x_bill_to_loc_code := NULL;
        END IF;
     CLOSE c1;
   end if;

  /* for ship to location */
      x_progress  := '003';
   if x_ship_to_loc_id is not null then
     OPEN c1(x_ship_to_loc_id);
        FETCH c1 into x_ship_to_loc_code;
        IF c1%NOTFOUND then
           x_ship_to_loc_code := NULL;
        END IF;
     CLOSE c1;
   end if;

EXCEPTION
  WHEN OTHERS THEN
    po_message_s.sql_error('po_inq_sv.get_location_info', x_progress, sqlcode);
    raise;
END;

/*===========================================================================

  PROCEDURE NAME:	get_project_info()

===========================================================================*/
PROCEDURE get_project_info(x_project_id   IN number,
                           x_task_id      IN number,
                           x_project_num  IN OUT NOCOPY varchar2,
                           x_task_num     IN OUT NOCOPY varchar2) is

x_progress  varchar2(3) := '000';
--< Bug 3265539 Start >
l_return_status VARCHAR2(1);
--< Bug 3265539 End >

BEGIN

     x_progress  := '001';
    --< Bug 3265539 Start >
    -- Need to retrieve project info correctly using this utility procedure
    PO_PROJECT_DETAILS_SV.get_project_task_num
       (x_return_status => l_return_status,
        p_project_id    => x_project_id,
        p_task_id       => x_task_id,
        x_project_num   => x_project_num,
        x_task_num      => x_task_num);

    IF (l_return_status <> FND_API.g_ret_sts_success) THEN
        RAISE APP_EXCEPTION.application_exception;
    END IF;
    --< Bug 3265539 End >

EXCEPTION

  WHEN OTHERS THEN
    po_message_s.sql_error('po_inq_sv.get_project_info', x_progress, sqlcode);
    raise;
END;

/*===========================================================================

  PROCEDURE NAME:	get_wip_bom_info()

===========================================================================*/
PROCEDURE get_wip_bom_info(x_wip_entity_id      IN  number,
                           x_wip_line_id        IN  number ,
                           x_bom_resource_id    IN  number ,
                           x_destination_org_id IN  number,
                           x_wip_entity_name    IN  OUT NOCOPY  varchar2,
                           x_wip_line_code      IN  OUT NOCOPY  varchar2,
                           x_bom_resource_code  IN  OUT NOCOPY  varchar2,
                           x_bom_uom            IN  OUT NOCOPY  varchar2) is

x_progress  varchar2(3) := '000';

cursor c1 is
      select line_code
      from   wip_lines
      where  line_id = x_wip_line_id
      and organization_id = x_destination_org_id ;

cursor c2 is
      select wip_entity_name
      from   wip_entities
      where  wip_entity_id = x_wip_entity_id
      and    organization_id = x_destination_org_id ;

cursor c3 is
      select resource_code,
             unit_of_measure
      from   bom_resources
      where  resource_id =  x_bom_resource_id and
             organization_id = x_destination_org_id ;

BEGIN

     x_progress  := '001';
  if x_wip_line_id is not null then
    OPEN c1;
        FETCH c1 into x_wip_line_code ;
        IF c1%NOTFOUND then
             x_wip_line_code  := NULL;
        END IF;
    CLOSE c1;
  end if;

       x_progress  := '002';
   if x_wip_entity_id is not null then
     OPEN c2;
        FETCH c2 into  x_wip_entity_name;
        IF c2%NOTFOUND then
             x_wip_entity_name   := NULL;
        END IF;
     CLOSE c2;
  end if;

       x_progress  := '003';
  if x_bom_resource_id is not null then
     OPEN c3;
        FETCH c3 into x_bom_resource_code,
                      x_bom_uom  ;
        IF c3%NOTFOUND then
             x_bom_resource_code := NULL;
             x_bom_uom  := NULL;
        END IF;
     CLOSE c3;
 end if;


EXCEPTION
  WHEN OTHERS THEN
    po_message_s.sql_error('po_inq_sv.get_wip_bom_info', x_progress, sqlcode);
    raise;
END;

/*===========================================================================

  PROCEDURE NAME:	get_vendor_info()

===========================================================================*/
PROCEDURE  get_vendor_info(x_vendor_id        IN  number,
                           x_vendor_site_id   IN  number ,
                           x_vendor_name      IN OUT NOCOPY  varchar2,
                           x_vendor_site_code IN OUT NOCOPY  varchar2) is

x_progress  varchar2(3) := '000';
cursor c1 is
     select vendor_name
     from po_vendors
     where vendor_id = x_vendor_id ;

cursor c2 is
     select vendor_site_code
     from po_vendor_sites_all --<Shared Proc FPJ>
     where vendor_site_id = x_vendor_site_id;

BEGIN

    x_progress  := '001';
  if x_vendor_id is not null then
    OPEN c1;
        FETCH c1 into x_vendor_name;
        IF c1%NOTFOUND then
              x_vendor_name := NULL;
        END IF;
    CLOSE c1;
  end if;

      x_progress  := '002';
  if x_vendor_site_id is not null then
    OPEN c2;
        FETCH c2 into x_vendor_site_code;
        IF c2%NOTFOUND then
            x_vendor_site_code := NULL;
        END IF;
     CLOSE c2;
   end if;

EXCEPTION
  WHEN OTHERS THEN
    po_message_s.sql_error('po_inq_sv.get_vendor_info', x_progress, sqlcode);
    raise;
END;

/*===========================================================================

  PROCEDURE NAME:	get_ap_terms()

===========================================================================*/
PROCEDURE get_ap_terms(x_terms_id      IN number,
                       x_ap_terms_name IN OUT NOCOPY varchar2) is

x_progress  varchar2(3) := '000';
cursor c1 is
    select name
    from   ap_terms
    where  term_id = x_terms_id;

BEGIN

     OPEN c1;
        FETCH c1 into x_ap_terms_name;
        IF c1%NOTFOUND then
             x_ap_terms_name := NULL;
        END IF;
    CLOSE c1;

EXCEPTION
  WHEN OTHERS THEN
    po_message_s.sql_error('po_inq_sv.get_ap_terms', x_progress, sqlcode);
    raise;
END;

/*===========================================================================

  PROCEDURE NAME:	get_dist_info_pq()
  added for the performance fix in bug 1338674 to get the values
  removed from the view.

============================================================================*/
PROCEDURE get_dist_info_pq (x_po_header_id        IN  number,
                            x_po_line_location_id IN  number,
                            x_deliver_to_loc_id   IN  number,
                            x_bill_to_loc_id      IN  number,
                            x_destination_org_id  IN  number,
                            x_expenditure_org_id  IN  number,
                            x_vendor_id           IN  number,
                            x_vendor_site_id      IN  number,
                            x_project_id          IN  number,
                            x_task_id             IN  number,
                            x_bom_resource_id     IN  number,
                            x_wip_entity_id       IN  number,
                            x_wip_line_id         IN  number,
                            x_dest_location_code  IN OUT NOCOPY  varchar2,
                            x_bill_to_loc_code    IN OUT NOCOPY  varchar2,
                            x_ship_to_loc_code    IN OUT NOCOPY  varchar2,
                            x_dest_org_name       IN OUT NOCOPY  varchar2,
                            x_exp_org_name        IN OUT NOCOPY  varchar2,
                            x_ship_to_org_name    IN OUT NOCOPY  varchar2,
                            x_project_num         IN OUT NOCOPY  varchar2,
                            x_task_num            IN OUT NOCOPY  varchar2,
                            x_wip_entity_name     IN OUT NOCOPY  varchar2,
                            x_wip_line_code       IN OUT NOCOPY  varchar2,
                            x_bom_resource_code   IN OUT NOCOPY  varchar2,
                            x_bom_uom             IN OUT NOCOPY  varchar2,
                            x_ap_terms_name       IN OUT NOCOPY  varchar2,
                            x_vendor_name         IN OUT NOCOPY  varchar2,
                            x_vendor_site_code    IN OUT NOCOPY  varchar2,
                            --< Shared Proc FPJ Start >
                            x_purchasing_ou_coa_id   OUT NOCOPY NUMBER,
                            x_ship_to_ou_coa_id      OUT NOCOPY NUMBER,
                            --< Shared Proc FPJ End >
                            --< Bug 3266689 Start >
                            x_type_lookup_code   IN varchar2
                            --< Bug 3266689 End >
                            ) is

  cursor c1 is
         select ship_to_organization_id ,
                ship_to_location_id
         from po_line_locations_all --< Shared Proc FPJ >
         where line_location_id = x_po_line_location_id;

  cursor c2 is
         select terms_id
         from po_headers_all --< Shared Proc FPJ >
         where po_header_id = x_po_header_id;

  x_progress  varchar2(3) := '000';
  x_ship_to_org_id   number;
  x_ship_to_loc_id   number;
  x_terms_id         number;

  --< Shared Proc FPJ Start >
  l_ship_to_ou_id     HR_ALL_ORGANIZATION_UNITS.organization_id%TYPE;
  l_return_status     VARCHAR2(1); -- FND_API.g_ret_sts_success
  --< Shared Proc FPJ End >

BEGIN

       OPEN c1;
       FETCH c1 into x_ship_to_org_id,
                     x_ship_to_loc_id;

       if c1%NOTFOUND then
         x_ship_to_org_id := null;
         x_ship_to_loc_id := null;
       end if;
       CLOSE c1;

      /* gets the organization names and locations correcponding to the id's */

        x_progress  := '001';
        get_org_info(x_destination_org_id  ,
                     x_expenditure_org_id  ,
                     x_ship_to_org_id,
                     x_dest_org_name,
                     x_exp_org_name,
                     x_ship_to_org_name);

        --< Shared Proc FPJ Start >
        x_progress  := '01b';


        /* Bug 3266689: Added NOT NULL if condition on line_location_id */
        IF ((x_po_line_location_id is NOT NULL) or
           (x_type_lookup_code <> 'BLANKET'))
        THEN

           -- Get the Ship-to OU's Chart of Accounts ID
           PO_SHARED_PROC_PVT.get_ou_and_coa_from_inv_org(
             p_inv_org_id                 => x_ship_to_org_id,
             x_coa_id                     => x_ship_to_ou_coa_id,
             x_ou_id                      => l_ship_to_ou_id,
             x_return_status              => l_return_status);

           IF (l_return_status <> FND_API.g_ret_sts_success) THEN
             APP_EXCEPTION.raise_exception(
               exception_type => 'PO_INQ_SV.get_dist_info_pq',
               exception_code => 0,
               exception_text => 'Exception in PO_SHARED_PROC_PVT.' ||
                                 'get_ou_and_coa_from_inv_org() - '||
                                 'po_line_location_id='||x_po_line_location_id||
                                 ', ship_to_org_id='||x_ship_to_org_id);
           END IF;

           x_progress  := '01c';
           --SQL WHAT: Derive the COA tied to a Set of Books that, in turn, is
           --          tied to the Purchasing Operating Unit at the given
           --          PO Shipment.
           --SQL WHY:  To define the Account flexfield structure in PO Summary
           --          Form (Distributions Window)
           BEGIN
             SELECT gsb.chart_of_accounts_id
             INTO x_purchasing_ou_coa_id
             FROM gl_sets_of_books gsb,
                  financials_system_params_all fspa,
                  po_line_locations_all pll
             WHERE pll.line_location_id = x_po_line_location_id
               AND fspa.org_id = pll.org_id
               AND gsb.set_of_books_id = fspa.set_of_books_id;
           EXCEPTION
             WHEN OTHERS THEN
               APP_EXCEPTION.raise_exception(
                 exception_type => 'PO_INQ_SV.get_dist_info_pq',
                 exception_code => 0,
                 exception_text => 'Could not find Chart of Accounts for ' ||
                                   'Purchasing Operating Unit - '||
                                   'po_line_location_id='||x_po_line_location_id);
           END;
           --< Shared Proc FPJ End >

        END IF; /* if x_po_line_location_id IS NOT NULL... */

        x_progress  := '002';
        get_location_info( x_deliver_to_loc_id ,
                           x_bill_to_loc_id,
                           x_ship_to_loc_id,
                           x_dest_location_code,
                           x_bill_to_loc_code,
                           x_ship_to_loc_code );


        /* the following procedures get the values of project/task,wip,bom
           and ap related fields */

        x_progress := '003';
        get_project_info(x_project_id  ,
                         x_task_id ,
                         x_project_num,
                         x_task_num );

        x_progress   := '004';
        get_wip_bom_info( x_wip_entity_id,
                          x_wip_line_id    ,
                          x_bom_resource_id ,
                          x_destination_org_id  ,
                          x_wip_entity_name    ,
                          x_wip_line_code ,
                          x_bom_resource_code ,
                          x_bom_uom );

        OPEN c2;
        FETCH c2 into x_terms_id;
        if c2%FOUND then

        x_progress  := '005';
        get_ap_terms(x_terms_id,
                     x_ap_terms_name);
        end if;

        CLOSE c2;

        /* this procedure gets the vendor related info*/

        x_progress := '006';
        get_vendor_info(x_vendor_id ,
                        x_vendor_site_id,
                        x_vendor_name ,
                        x_vendor_site_code );

        x_progress  := '007';

EXCEPTION
  WHEN OTHERS THEN
    po_message_s.sql_error('po_inq_sv.get_dist_info_pq', x_progress, sqlcode);
    raise;
END;

/*===========================================================================
  togeorge 06/14/2001
  Bug# 1733951
  This procedure fetches the lookup values removed from the view
  po_line_locations_inq_v as part of the performance fix.

  PROCEDURE NAME:	get_shipments_pq_lookups

===========================================================================*/
PROCEDURE get_shipments_pq_lookups(x_enforce_ship_to_loc_code  IN varchar2,
       x_receipt_days_excpt_code   IN  	    varchar2,
       x_qty_rcv_excpt_code	   IN  	    varchar2,
       x_closed_code     	   IN  	    varchar2,
       x_shipment_type    	   IN  	    varchar2,
       x_authorization_status      IN  	    varchar2,
       x_fob_code	 	   IN  	    varchar2,
       x_freight_terms_code 	   IN  	    varchar2,
       x_enforce_ship_to_loc_dsp   IN  OUT NOCOPY  varchar2,
       x_receipt_days_excpt_dsp    IN  OUT NOCOPY  varchar2,
       x_qty_rcv_excpt_dsp	   IN  OUT NOCOPY  varchar2,
       x_closed_code_dsp     	   IN  OUT NOCOPY  varchar2,
       x_shipment_type_dsp    	   IN  OUT NOCOPY  varchar2,
       x_authorization_status_dsp  IN  OUT NOCOPY  varchar2,
       x_fob_code_dsp	 	   IN  OUT NOCOPY  varchar2,
       x_freight_terms_code_dsp    IN  OUT NOCOPY  varchar2,
       p_match_option              IN              VARCHAR2,--Bug 2947251
       x_match_option_dsp              OUT NOCOPY  VARCHAR2 --Bug 2947251
) is

x_progress  varchar2(3) := '000';

BEGIN

  -- Bug 3816901: added calls to get_lookup_dsp for the
  -- lookups instead of duplicating the select for each
  -- lookup type

  x_progress  := '001';
  if x_enforce_ship_to_loc_code is not null then
     get_lookup_dsp('RECEIVING CONTROL LEVEL',
                     x_enforce_ship_to_loc_code,
                     x_enforce_ship_to_loc_dsp);
  end if;

  x_progress  := '002';
  if x_receipt_days_excpt_code is not null then
    get_lookup_dsp('RECEIVING CONTROL LEVEL',
                     x_receipt_days_excpt_code,
                     x_receipt_days_excpt_dsp);
  end if;


  x_progress  := '003';
  if x_qty_rcv_excpt_code is not null then
    get_lookup_dsp('RECEIVING CONTROL LEVEL',
                     x_qty_rcv_excpt_code,
                     x_qty_rcv_excpt_dsp);
  end if;

  x_progress  := '004';
  if x_closed_code is not null then
    get_lookup_dsp('DOCUMENT STATE',
                     x_closed_code,
                     x_closed_code_dsp);
  end if;

  x_progress  := '005';
  if x_shipment_type is not null then
    get_lookup_dsp('SHIPMENT TYPE',
                     x_shipment_type,
                     x_shipment_type_dsp);
  end if;

  x_progress  := '006';
  if x_authorization_status is not null then
    get_lookup_dsp('AUTHORIZATION STATUS',
                     x_authorization_status,
                     x_authorization_status_dsp);
  end if;

  x_progress  := '008';
  if x_fob_code is not null then
    get_lookup_dsp('FOB',
                    x_fob_code,
                    x_fob_code_dsp);
  end if;

  x_progress  := '009';
  if x_freight_terms_code is not null then
    get_lookup_dsp('FREIGHT TERMS',
                    x_freight_terms_code,
                    x_freight_terms_code_dsp);
  end if;

  --Bug 2947251 START
  x_progress  := '010';
  IF p_match_option IS NOT NULL THEN
    get_lookup_dsp('PO INVOICE MATCH OPTION',
                     UPPER(p_match_option),
                     x_match_option_dsp);
  END IF;
  --Bug 2947251 END

EXCEPTION
  WHEN OTHERS THEN
    po_message_s.sql_error('po_inq_sv.get_shipments_pq_lookups', x_progress, sqlcode);
    raise;
END;

/*===========================================================================
  togeorge 08/27/2001
  Bug# 1870283
  This procedure fetches the lookup values removed from the view
  po_distributions_inq_v as part of the performance fix.

  PROCEDURE NAME:	get_dist_pq_lookups

===========================================================================*/
PROCEDURE get_dist_pq_lookups(
       x_destination_type_code	   IN  	    varchar2,
       x_authorization_status      IN  	    varchar2,
       x_shipment_type    	   IN  	    varchar2,
       x_closed_code     	   IN  	    varchar2,
       x_destination_type	   IN  OUT NOCOPY  varchar2,
       x_authorization_status_dsp  IN  OUT NOCOPY  varchar2,
       x_shipment_type_dsp    	   IN  OUT NOCOPY  varchar2,
       x_closed_code_dsp     	   IN  OUT NOCOPY  varchar2) is

x_progress  varchar2(3) := '000';

BEGIN

   -- Bug 3816901: added calls to get_lookup_dsp for the
  -- lookups instead of duplicating the select for each
  -- lookup type

  x_progress  := '001';
  if x_destination_type_code is not null then
    get_lookup_dsp('DESTINATION TYPE',
                     x_destination_type_code,
                     x_destination_type);
  end if;

  x_progress  := '002';
  if x_authorization_status is not null then
    get_lookup_dsp('AUTHORIZATION STATUS',
                     x_authorization_status,
                     x_authorization_status_dsp);
  end if;

  x_progress  := '003';
  if x_shipment_type is not null then
    get_lookup_dsp('SHIPMENT TYPE',
                    x_shipment_type,
                    x_shipment_type_dsp);
  end if;

  x_progress  := '004';
  if x_closed_code is not null then
    get_lookup_dsp('DOCUMENT STATE',
                     x_closed_code,
                     x_closed_code_dsp);
  end if;

EXCEPTION
  WHEN OTHERS THEN
    po_message_s.sql_error('po_inq_sv.get_dist_pq_lookups', x_progress, sqlcode);
    raise;
END get_dist_pq_lookups;

/*===========================================================================
  togeorge 08/31/2001
  Bug# 1926525
  This procedure fetches the lookup values removed from the view
  po_lines_inq_v as part of the performance fix.

  PROCEDURE NAME:	get_lines_pq_lookups

===========================================================================*/
PROCEDURE get_lines_pq_lookups(
       x_price_type_lookup_code    IN  	    varchar2,
       x_transaction_reason_code   IN  	    varchar2,
       x_price_break_lookup_code   IN  	    varchar2,
       x_closed_code     	   IN  	    varchar2,
       x_authorization_status      IN  	    varchar2,
       x_fob_code	 	   IN  	    varchar2,
       x_freight_terms_code 	   IN  	    varchar2,
       x_price_type   		   IN  OUT NOCOPY  varchar2,
       x_transaction_reason    	   IN  OUT NOCOPY  varchar2,
       x_price_break		   IN  OUT NOCOPY  varchar2,
       x_closed_code_dsp     	   IN  OUT NOCOPY  varchar2,
       x_authorization_status_dsp  IN  OUT NOCOPY  varchar2,
       x_fob_code_dsp	 	   IN  OUT NOCOPY  varchar2,
       x_freight_terms_code_dsp    IN  OUT NOCOPY  varchar2) is

x_progress  varchar2(3) := '000';

BEGIN

  -- Bug 3816901: added calls to get_lookup_dsp for the
  -- lookups instead of duplicating the select for each
  -- lookup type

  x_progress  := '001';
  if x_price_type_lookup_code is not null then
    get_lookup_dsp('PRICE TYPE',
                     x_price_type_lookup_code,
                     x_price_type);
  end if;

  x_progress  := '002';
  if x_transaction_reason_code is not null then
     get_lookup_dsp('TRANSACTION REASON',
                     x_transaction_reason_code,
                     x_transaction_reason);
  end if;

  x_progress  := '003';
  if x_price_break_lookup_code is not null then
    get_lookup_dsp('PRICE BREAK TYPE',
                     x_price_break_lookup_code,
                     x_price_break);
  end if;

  x_progress  := '004';
  if x_closed_code is not null then
    get_lookup_dsp('DOCUMENT STATE',
                     x_closed_code,
                     x_closed_code_dsp);
  end if;


  x_progress  := '005';
  if x_authorization_status is not null then
    get_lookup_dsp('AUTHORIZATION STATUS',
                     x_authorization_status,
                     x_authorization_status_dsp);
  end if;

  x_progress  := '006';
  if x_fob_code is not null then
    get_lookup_dsp('FOB',
                    x_fob_code,
                    x_fob_code_dsp);
  end if;

  x_progress  := '007';
  if x_freight_terms_code is not null then
    get_lookup_dsp('FREIGHT TERMS',
                    x_freight_terms_code,
                    x_freight_terms_code_dsp);
  end if;


EXCEPTION
  WHEN OTHERS THEN
    po_message_s.sql_error('po_inq_sv.get_lines_pq_lookups', x_progress, sqlcode);
    raise;
END;

/*===========================================================================
  togeorge 11/19/2001
  Bug# 2038811
  This procedure fetches the lookup values removed from the view
  po_headers_inq_v as part of the performance fix.

  PROCEDURE NAME:	get_headers_pq_lookups

===========================================================================*/
PROCEDURE get_headers_pq_lookups(
       x_authorization_status      IN  	    varchar2,
       x_fob_code	 	   IN  	    varchar2,
       x_freight_terms_code 	   IN  	    varchar2,
       x_closed_code     	   IN  	    varchar2,
       x_authorization_status_dsp  IN  OUT NOCOPY  varchar2,
       x_fob_code_dsp	 	   IN  OUT NOCOPY  varchar2,
       x_freight_terms_code_dsp    IN  OUT NOCOPY  varchar2,
       x_closed_code_dsp     	   IN  OUT NOCOPY  varchar2,
       p_shipping_control          IN              VARCHAR2,    -- <INBOUND LOGISTICS FPJ>
       x_shipping_control_dsp      IN  OUT NOCOPY  VARCHAR2     -- <INBOUND LOGISTICS FPJ>
       ) is

x_progress  varchar2(3) := '000';

BEGIN

  -- Bug 3816901: added calls to get_lookup_dsp for the
  -- lookups instead of duplicating the select for each
  -- lookup type

  x_progress  := '001';
  if x_closed_code is not null then
    get_lookup_dsp('DOCUMENT STATE',
                     x_closed_code,
                     x_closed_code_dsp);
  end if;


  x_progress  := '002';
  if x_authorization_status is not null then
    get_lookup_dsp('AUTHORIZATION STATUS',
                     x_authorization_status,
                     x_authorization_status_dsp);
  end if;

  x_progress  := '003';
  if x_fob_code is not null then
    get_lookup_dsp('FOB',
                    x_fob_code,
                    x_fob_code_dsp);
  end if;

  x_progress  := '004';
  if x_freight_terms_code is not null then
    get_lookup_dsp('FREIGHT TERMS',
                    x_freight_terms_code,
                    x_freight_terms_code_dsp);
  end if;

  -- <INBOUND LOGISTICS FPJ START>
  x_progress  := '005';
  IF p_shipping_control IS NOT NULL THEN
      get_lookup_dsp('SHIPPING CONTROL',
                    p_shipping_control,
                    x_shipping_control_dsp);
  END IF;
  -- <INBOUND LOGISTICS FPJ END>

EXCEPTION
  WHEN OTHERS THEN
    po_message_s.sql_error('po_inq_sv.get_headers_pq_lookups', x_progress, sqlcode);
    raise;
END;

/*===========================================================================

    PROCEDURE:   get_source_info                   <GA FPI>

    DESCRIPTION: Gets all source document-related information based on a
                 po_header_id.

===========================================================================*/
PROCEDURE get_source_info
(
    p_po_header_id              IN     PO_HEADERS_ALL.po_header_id%TYPE,
    x_segment1                  OUT NOCOPY    PO_HEADERS_ALL.segment1%TYPE,
    x_type_lookup_code          OUT NOCOPY    PO_HEADERS_ALL.type_lookup_code%TYPE,
    x_global_agreement_flag     OUT NOCOPY    PO_HEADERS_ALL.global_agreement_flag%TYPE,
    x_owning_org_id             OUT NOCOPY    PO_HEADERS_ALL.org_id%TYPE,
    x_quote_vendor_quote_number OUT NOCOPY    PO_HEADERS_ALL.quote_vendor_quote_number%TYPE
)
IS
BEGIN

    SELECT    segment1,
              type_lookup_code,
              global_agreement_flag,
              org_id,
              quote_vendor_quote_number
    INTO      x_segment1,
              x_type_lookup_code,
              x_global_agreement_flag,
              x_owning_org_id,
              x_quote_vendor_quote_number
    FROM      po_headers_all
    WHERE     po_header_id = p_po_header_id;

EXCEPTION
    WHEN OTHERS THEN
        po_message_s.sql_error('get_source_info','000',sqlcode);
        raise;

END get_source_info;


/*===========================================================================

    FUNCTION:    get_type_name                     <GA FPI>

    DESCRIPTION: Given the 'document_type_code' and 'document_subtype',
                 the function will return the 'document_type_name' from
                 PO_DOCUMENTS_TYPES_VL.

===========================================================================*/

FUNCTION get_type_name
(
    p_document_type_code    PO_DOCUMENT_TYPES_VL.document_type_code%TYPE	,
	p_document_subtype      PO_DOCUMENT_TYPES_VL.document_subtype%TYPE
)
RETURN PO_DOCUMENT_TYPES_VL.type_name%TYPE
IS
    x_type_name 	PO_DOCUMENT_TYPES_VL.type_name%TYPE;
BEGIN

    SELECT 	type_name
    INTO	x_type_name
    FROM	po_document_types_vl
    WHERE	document_type_code = p_document_type_code
    AND		document_subtype = p_document_subtype;

    return (x_type_name);

EXCEPTION

    WHEN OTHERS THEN
	return (NULL);

END get_type_name;

/* Get Conversion Rate Type
/*===========================================================================

  PROCEDURE NAME:        get_rate_type()

===========================================================================*/
PROCEDURE  get_rate_type (x_header_id  IN  NUMBER,
                          x_rate_type  OUT NOCOPY varchar2)  is
cursor c1 is
select  GLDC.USER_CONVERSION_TYPE from GL_DAILY_CONVERSION_TYPES GLDC
                                  where  GLDC.CONVERSION_TYPE = (select POH.RATE_TYPE
                                            from po_headers_all POH
                                            where poh.po_header_id = x_header_id);

BEGIN

  open c1;
     fetch c1 into x_rate_type;
  close c1;


EXCEPTION
  WHEN OTHERS THEN
  x_rate_type := '';

END get_rate_type;

/* Bug 2788683 start */
/**
 * Public Procedure: get_vendor_name
 * Requires: None
 * Modifies: None
 * Effects: Get vendor real name based on log on name
 * Returns: x_vendor_name
 */
PROCEDURE get_vendor_name
(  l_user_name   IN         fnd_user.user_name%TYPE,
   x_vendor_name OUT NOCOPY hz_parties.party_name%TYPE
)
IS

BEGIN

   --SQL What: Query vendor name based on log on name
   --SQL Why:  Get vendor_name from hz_parties via hz_relationships starting
   --          from fnd_user.user_name
   /* Bug 12323666 Modified the query because the query based on old
      datamodel was not fetching any records*/
    SELECT ap.vendor_name
    INTO x_vendor_name
    FROM hz_relationships hzr,
             hz_parties hp,
             fnd_user fu,
             ap_suppliers ap,
             hz_party_usg_assignments hpua
    WHERE
          hzr.object_id  = ap.party_id
      AND hzr.subject_type = 'PERSON'
      AND hzr.object_type = 'ORGANIZATION'
      AND hzr.relationship_type = 'CONTACT'
      AND hzr.relationship_code = 'CONTACT_OF'
      AND hzr.status  = 'A'
       AND Nvl(hzr.end_date, SYSDATE) >= sysdate
      AND hzr.subject_id = hp.party_id
      AND hpua.party_id = hp.party_id
      AND hpua.status_flag = 'A'
      AND hpua.party_usage_code = 'SUPPLIER_CONTACT'
        AND Nvl(hpua.effective_end_date, SYSDATE) >= SYSDATE
       AND fu.person_party_id = hp.party_id
        AND Nvl(fu.end_date, SYSDATE) >= sysdate
         and   fu.user_name = l_user_name;

         /* Bug 12323666 end*/

EXCEPTION
   WHEN OTHERS THEN
      x_vendor_name := NULL;

END get_vendor_name;

/* Bug 2788683 end */

-- Bug 3816901: Created a procedure to get the displayed values for lookups
-- This will be called from the post query logic instead of having this code
-- multiple times for each lookup type
---------------------------------------------------------------------------
--Start of Comments
--Name: get_lookup_dsp
--Pre-reqs:
--  None.
--Modifies:
--  None
--Locks:
--  None.
--Function:
--  To get the displayed values for lookups
--Parameters:
--IN:
--p_lookup_type
--  The lookup type
--p_lookup_code
--  The lookup code for which we need he displayed value
--Returns:
--  The displayed value - translated value for the lookup code
--Testing:
--End of Comments
---------------------------------------------------------------------------
PROCEDURE get_lookup_dsp (p_lookup_type IN PO_LOOKUP_CODES.lookup_type%TYPE,
                          p_lookup_code IN PO_LOOKUP_CODES.lookup_code%TYPE,
                          x_displayed_field OUT NOCOPY PO_LOOKUP_CODES.displayed_field%TYPE)
IS

BEGIN

       SELECT polc.displayed_field
         INTO x_displayed_field
	 FROM po_lookup_codes polc
        WHERE lookup_type = p_lookup_type
	  AND lookup_code = p_lookup_code;

Exception
When others then
 x_displayed_field := null;

END get_lookup_dsp;

--<HTML Agreement R12 Start>
---------------------------------------------------------------------------
--Start of Comments
--Name: get_party_vendor_name
--Pre-reqs:
--  None.
--Modifies:
--  None
--Locks:
--  None.
--Function:
--  Retrieves the party name + vendor name for acceptance entries entered
--  by suppliers. The result is in the form of "party name(vendor name)",
--  e.g. "Maxwell Olden(Office Supplies, Inc.)".
--  This function is refactored from POXPOEAC.pld
--Parameters:
--IN:
--  p_user_id: user_id of the supplier party
--Returns:
--  "party name(vendor name)" of the given user_id
--Testing:
--End of Comments
---------------------------------------------------------------------------
FUNCTION get_party_vendor_name (p_user_id IN NUMBER)
RETURN VARCHAR2
IS
  l_user_name FND_USER.USER_NAME%TYPE;
  l_party_name HZ_PARTIES.PARTY_NAME%TYPE;
  l_vendor_name HZ_PARTIES.PARTY_NAME%TYPE;
  l_result VARCHAR2(800); --approx. length to hold "party name(vendor name)"
  l_progress VARCHAR2(3) := '000';
  l_log_head VARCHAR2(100) := g_log_head||'get_party_vendor_name';
BEGIN
  l_progress := '010';

  -- SQL What: Retrieve user_name and party_name based on user_id
  -- SQL Why: Need to construct output and to further retrieve vendor_name
  SELECT fu.user_name, hp.party_name
  INTO l_user_name, l_party_name
  FROM fnd_user fu,hz_parties hp
  WHERE hp.party_id = fu.customer_id
  AND fu.user_id = p_user_id;

  l_progress := '020';
  IF g_debug_stmt THEN
     PO_DEBUG.debug_stmt(p_log_head => l_log_head,
                         p_token    => l_progress,
                         p_message  => 'user name: '||l_user_name||' party name: '||l_party_name);
  END IF;

  get_vendor_name(l_user_name   => l_user_name,
                  x_vendor_name => l_vendor_name);

  l_progress := '030';

  -- 'party_name(vendor_name)' is defined to be a message
  -- such that the translation of ( ) will be taken care of
  FND_MESSAGE.set_name('PO', 'PO_PARTY_VENDOR_NAME');
  FND_MESSAGE.set_token('PARTY_NAME', l_party_name);
  FND_MESSAGE.set_token('VENDOR_NAME', l_vendor_name);

  l_result := FND_MESSAGE.get;

  IF g_debug_stmt THEN
     PO_DEBUG.debug_stmt(p_log_head => l_log_head,
                         p_token    => l_progress,
                         p_message  => 'l_result: '||l_result);
  END IF;
  RETURN l_result;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    l_result := '';
    IF g_debug_stmt THEN
       PO_DEBUG.debug_stmt(p_log_head => l_log_head,
                           p_token    => l_progress,
                           p_message  => 'l_result: '||l_result);
    END IF;
    RETURN l_result;
  WHEN OTHERS THEN
    FND_MSG_PUB.add_exc_msg(p_pkg_name       => g_pkg_name,
                            p_procedure_name => 'get_party_vendor_name',
                            p_error_text     => 'Progress: '||l_progress||' Error: '||SUBSTRB(SQLERRM,1,215));
    IF g_debug_unexp THEN
      PO_DEBUG.debug_exc(p_log_head => l_log_head ||'get_party_vendor_name',
                         p_progress => l_progress);
    END IF;
    RETURN NULL;
END get_party_vendor_name;

---------------------------------------------------------------------------
--Start of Comments
--Name: get_vendor_email
--Pre-reqs:
--  None.
--Modifies:
--  None
--Locks:
--  None.
--Function:
--  Retrieves the vendor party email address for acceptance entries entered
--  by suppliers.
--Parameters:
--IN:
--  p_user_id: user_id of the supplier party
--Returns:
--  email address stored in HZ_PARTIES; if that is not available, return
--  email address stored in FND_USER
--Testing:
--End of Comments
---------------------------------------------------------------------------
FUNCTION get_vendor_email (p_user_id IN NUMBER)
RETURN VARCHAR2
IS
  l_fu_email_address FND_USER.EMAIL_ADDRESS%TYPE; -- Varchar2(240)
  l_hp_email_address HZ_PARTIES.EMAIL_ADDRESS%TYPE;  -- Varchar2(2000)
  l_result HZ_PARTIES.EMAIL_ADDRESS%TYPE;
  l_progress VARCHAR2(3) := '000';
  l_log_head VARCHAR2(100) := g_log_head||'get_vendor_email';
BEGIN
  l_progress := '010';

  -- SQL What: Retrieve email_address based on user_id
  -- SQL Why: Need to return email_address
  SELECT fu.email_address, hp.email_address
  INTO l_fu_email_address, l_hp_email_address
  FROM fnd_user fu,hz_parties hp
  WHERE hp.party_id = fu.customer_id
  AND fu.user_id = p_user_id;

  l_progress := '020';
  IF g_debug_stmt THEN
     PO_DEBUG.debug_stmt(p_log_head => l_log_head,
                         p_token    => l_progress,
                         p_message  => 'l_fu_email_address: '||l_fu_email_address||' l_hp_email_address: '||l_hp_email_address);
  END IF;

  IF l_hp_email_address IS NOT NULL THEN
     l_result := l_hp_email_address;
  ELSE
     l_result := l_fu_email_address;
  END IF;

  RETURN l_result;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    IF g_debug_stmt THEN
       PO_DEBUG.debug_stmt(p_log_head => l_log_head,
                           p_token    => l_progress,
                           p_message  => 'No data found');
    END IF;
    RETURN NULL;
  WHEN OTHERS THEN
    FND_MSG_PUB.add_exc_msg(p_pkg_name       => g_pkg_name,
                            p_procedure_name => 'get_vendor_email',
                            p_error_text     => 'Progress: '||l_progress||' Error: '||SUBSTRB(SQLERRM,1,215));
    IF g_debug_unexp THEN
      PO_DEBUG.debug_exc(p_log_head => l_log_head ||'get_vendor_email',
                         p_progress => l_progress);
    END IF;
    RETURN NULL;
END get_vendor_email;
--<HTML Agreement R12 End>

END PO_INQ_SV;

/
