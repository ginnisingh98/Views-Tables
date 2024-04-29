--------------------------------------------------------
--  DDL for Package Body PO_REQS_INQ_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_REQS_INQ_SV" as
/* $Header: POXRQVRB.pls 115.9 2003/12/12 04:17:15 sbull ship $*/
/*=============================  PO_REQS_INQ_SV  ===============================*/


/*===========================================================================

  FUNCTION NAME:	get_po_number

===========================================================================*/
FUNCTION  get_po_number (X_po_header_id	IN NUMBER)
			 RETURN VARCHAR2 IS

X_progress                 VARCHAR2(3) := NULL;
X_po_number                PO_HEADERS.segment1%TYPE := NULL;

BEGIN

 X_progress := '005';

 IF X_po_header_id is NULL THEN
    return (NULL);
 ELSE

    SELECT POH.segment1
      INTO X_po_number
      FROM PO_HEADERS_ALL POH              -- FPI GA
     WHERE POH.PO_HEADER_ID = X_po_header_id;

  return(x_po_number);

 END IF;

EXCEPTION

   WHEN NO_DATA_FOUND THEN
    return(NULL);

   WHEN OTHERS THEN
      return(NULL);


END get_po_number;

/*===========================================================================

  FUNCTION NAME:	get_reserved_flag

===========================================================================*/
FUNCTION  get_reserved_flag (x_requisition_header_id	IN NUMBER)
							RETURN VARCHAR2 IS

X_progress                 VARCHAR2(3) := NULL;
X_reserved_flag            VARCHAR2(3);

BEGIN

 X_progress := '005';
 x_reserved_flag := NULL;

--<Encumbrance FPJ>
PO_CORE_S.should_display_reserved(
   p_doc_type => PO_CORE_S.g_doc_type_REQUISITION
,  p_doc_level => PO_CORE_S.g_doc_level_HEADER
,  p_doc_level_id => x_requisition_header_id
,  x_display_reserved_flag => x_reserved_flag
);

  return(x_reserved_flag);

EXCEPTION
WHEN OTHERS THEN
   return(NULL);

END get_reserved_flag;


/*===========================================================================

  FUNCTION NAME:	get_shipped_quantity

===========================================================================*/
--Bug# 1392077
--Toju George 08/31/2000
--Modified the procedure to replace req_num and line_num with ids.
/*FUNCTION  get_shipped_quantity (x_requisition_num	IN VARCHAR2,
                                x_line_num              IN VARCHAR2)
							RETURN NUMBER IS
*/
FUNCTION  get_shipped_quantity (x_requisition_header_id	IN VARCHAR2,
                                x_requisition_line_id   IN VARCHAR2)
							RETURN NUMBER IS
 X_progress                 VARCHAR2(3) := NULL;
 X_shipped_quantity         NUMBER := 0;
 X_order_source_id          NUMBER;

BEGIN

      /*
      ** Get shipped quantity based on internal sales order
      */
         X_progress := '005';
         X_shipped_quantity := 0;

         /* replacing the select statement with the new OE API. */
          select order_source_id
          into   x_order_source_id
          from   po_system_parameters;

--Bug# 1392077
--Toju George 08/31/2000
--Modified the call to procedure to replace req_num and line_num with ids.

/*         X_shipped_quantity := OE_ORDER_IMPORT_INTEROP_PUB.Get_Shipped_Qty(x_order_source_id,
                                                                           x_requisition_num,
                                                                        x_line_num);
 */
         X_shipped_quantity := OE_ORDER_IMPORT_INTEROP_PUB.Get_Shipped_Qty(x_order_source_id,
                                                                           x_requisition_header_id,
                                                                        x_requisition_line_id);

   /*    SELECT decode(SOL.shipped_quantity,NULL,0,SOL.shipped_quantity)
         INTO   X_shipped_quantity
         FROM   SO_LINES SOL, SO_HEADERS SOH,
                PO_SYSTEM_PARAMETERS POSP
         WHERE  SOH.original_system_reference = X_requisition_num
         AND    SOH.original_system_source_code =
                             to_char(POSP.order_source_id)
         AND    SOH.header_id = SOL.header_id
         AND    SOL.original_system_line_reference = X_line_num;
  */
  Return(X_shipped_quantity);

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    return(0);

  WHEN OTHERS THEN
      return(0);
      po_message_s.sql_error('get_shipped_quantity', X_progress, sqlcode);
   RAISE;

END get_shipped_quantity;

/*===========================================================================

  PROCEDURE NAME:	po_req_header_inq_wrapper

===========================================================================*/
PROCEDURE po_req_header_inq_wrapper (x_req_num IN NUMBER,
				     x_preparer IN NUMBER,
	  			     x_req_header_amount OUT NOCOPY NUMBER,
				     x_reserved_flag OUT NOCOPY VARCHAR2,
				     x_preparer_name OUT NOCOPY VARCHAR2 ) IS
BEGIN

 IF x_preparer IS NOT NULL THEN
	x_preparer_name := PO_INQ_SV.GET_PERSON_NAME(x_preparer);
 END IF;

 IF x_req_num IS NOT NULL THEN
	x_reserved_flag := PO_REQS_INQ_SV.GET_RESERVED_FLAG (x_req_num);
	x_req_header_amount := PO_CORE_S.GET_TOTAL('E', x_req_num);
 END IF;


END po_req_header_inq_wrapper;

/*===========================================================================

  PROCEDURE NAME:	po_req_line_inq_wrapper

===========================================================================*/
PROCEDURE po_req_line_inq_wrapper (x_to_person_id 		IN NUMBER,
				x_suggested_buyer_id		IN NUMBER,
				x_item_id			IN NUMBER,
				x_wip_entity_id			IN NUMBER,
				x_wip_operation_seq_num		IN NUMBER,
				x_wip_resource_seq_num		IN NUMBER,
				x_destination_organization_id	IN NUMBER,
				x_wip_repetitive_schedule_id	IN NUMBER,
				x_quantity			IN NUMBER,
				x_purchasing_agent_id		IN NUMBER,
				x_preparer_id			IN NUMBER,
				x_blanket_po_header_id		IN NUMBER,
				x_source_type_code		IN VARCHAR2,
				x_line_location_id		IN NUMBER,
				x_segment1			IN VARCHAR2,
				x_line_num			IN NUMBER,
				x_requsition_line_id		IN NUMBER,

			 	v_requestor			OUT NOCOPY VARCHAR2,
				v_suggested_buyer		OUT NOCOPY VARCHAR2,
				v_assembly_quantity		OUT NOCOPY NUMBER,
				v_resource_quantity		OUT NOCOPY NUMBER,
				v_wip_operation_code		OUT NOCOPY VARCHAR2,
				v_bom_department_code		OUT NOCOPY VARCHAR2,
				v_purchasing_agent_name_dsp	OUT NOCOPY VARCHAR2,
				v_preparer_name			OUT NOCOPY VARCHAR2,
				v_blanket_po_num_dsp		OUT NOCOPY VARCHAR2,
				v_order_num			OUT NOCOPY VARCHAR2,
				v_req_line_amount		OUT NOCOPY NUMBER,
--Bug# 1392077
--Toju George 08/31/2000
				x_requisition_header_id IN  VARCHAR2) IS
BEGIN

  v_requestor :=NULL;
  v_suggested_buyer:=NULL;
  v_purchasing_agent_name_dsp :=NULL;
  v_preparer_name  :=NULL;
  v_blanket_po_num_dsp :=NULL;
  v_assembly_quantity := 0;
  v_resource_quantity := 0;
  v_wip_operation_code := NULL;
  v_bom_department_code := NULL;


 IF x_to_person_id IS NOT NULL THEN
 	v_requestor := PO_INQ_SV.GET_PERSON_NAME(x_to_person_id);
 END IF;

 IF x_suggested_buyer_id IS NOT NULL THEN
	 v_suggested_buyer := PO_INQ_SV.GET_PERSON_NAME(x_suggested_buyer_id);
 END IF;

 IF  x_wip_entity_id IS NOT NULL THEN

  v_assembly_quantity := NVL(PO_INQ_SV.GET_ASSEMBLY_QUANTITY(x_item_id,
							    x_wip_entity_id,
							    x_wip_operation_seq_num,
							    x_wip_resource_seq_num,
							    x_destination_organization_id,
							    x_wip_repetitive_schedule_id,
							    x_quantity),0);

  v_resource_quantity := NVL(PO_INQ_SV.GET_RESOURCE_QUANTITY(x_item_id,
							    x_wip_entity_id,
							    x_wip_operation_seq_num,
							    x_wip_resource_seq_num,
							    x_destination_organization_id,
							    x_wip_repetitive_schedule_id,
							    x_quantity),0);

  v_wip_operation_code := PO_INQ_SV.GET_WIP_OPERATION_CODE(x_wip_entity_id,
							    x_wip_operation_seq_num,
							    x_destination_organization_id,
							    x_wip_repetitive_schedule_id);

  v_bom_department_code := PO_INQ_SV.GET_BOM_DEPARTMENT_CODE(x_wip_entity_id,
							    x_wip_operation_seq_num,
							    x_destination_organization_id,
							    x_wip_repetitive_schedule_id);

 END IF;

 IF x_purchasing_agent_id IS NOT NULL THEN
	 v_purchasing_agent_name_dsp := PO_INQ_SV.GET_PERSON_NAME(x_purchasing_agent_id);
 END IF;

 IF x_preparer_id IS NOT NULL THEN
	 v_preparer_name := PO_INQ_SV.GET_PERSON_NAME(x_preparer_id);
 END IF;

 IF x_blanket_po_header_id IS NOT NULL THEN
	 v_blanket_po_num_dsp := PO_REQS_INQ_SV.GET_PO_NUMBER(x_blanket_po_header_id);

 END IF;


 IF (x_source_type_code = 'VENDOR') THEN
   v_order_num := PO_INQ_SV.GET_PO_NUMBER(x_line_location_id);
 ELSE

--Bug# 1392077
--Toju George 08/31/2000
--Modified the call to procedure to replace req_num and line_num with ids.
  /* v_order_num := PO_INQ_SV.GET_SO_NUMBER(x_segment1,x_line_num);*/

     v_order_num := PO_INQ_SV.GET_SO_NUMBER(x_requisition_header_id,x_requsition_line_id);
 END IF;

     -- SERVICES FPJ
     -- Changed to the new function which handles both services and goods lines

     v_req_line_amount := PO_REQS_INQ_SV.get_req_amount('I',x_requsition_line_id);


END po_req_line_inq_wrapper;
/*===========================================================================

  PROCEDURE NAME:	po_req_dist_inq_wrapper

===========================================================================*/
PROCEDURE po_req_dist_inq_wrapper (x_to_person_id 	IN NUMBER,
				x_suggested_buyer_id		IN NUMBER,
				x_preparer_id			IN NUMBER,
				x_distribution_id		IN NUMBER,

			 	v_requestor			OUT NOCOPY VARCHAR2,
				v_suggested_buyer		OUT NOCOPY VARCHAR2,
				v_preparer_name			OUT NOCOPY VARCHAR2,
				v_req_distribution_amount	OUT NOCOPY NUMBER) IS

BEGIN

   IF x_to_person_id IS NOT NULL THEN
	   v_requestor := PO_INQ_SV.GET_PERSON_NAME(x_to_person_id);
   END IF;


   IF x_suggested_buyer_id IS NOT NULL THEN
	   v_suggested_buyer := PO_INQ_SV.GET_PERSON_NAME(x_suggested_buyer_id);
   END IF;


   IF x_preparer_id IS NOT NULL THEN
	   v_preparer_name := PO_INQ_SV.GET_PERSON_NAME(x_preparer_id);
   END IF;

   -- SERVICES FPJ
   -- Changed to the new function which handles both services and goods lines

   v_req_distribution_amount := PO_REQS_INQ_SV.get_req_amount ('J' , x_distribution_id);

END po_req_dist_inq_wrapper;

/*===========================================================================

  PROCEDURE NAME:    get_reqln_pq_lookups
  Bug# 1934593
  This procedure fetches the lookup values removed from the view
  po_requisition_lines_inq_v as part of the performance fix

 ===========================================================================*/
PROCEDURE get_reqln_pq_lookups( x_auth_status_code           in   varchar2,
                                x_tran_reason_code           in   varchar2,
                                x_src_doc_type_code          in   varchar2,
                                x_dest_type_code             in   varchar2,
                                x_src_type_code              in   varchar2,
                                x_auth_status_dsp       in out NOCOPY  varchar2,
                                x_tran_reason_dsp       in out NOCOPY  varchar2,
                                x_src_doc_type_dsp      in out NOCOPY  varchar2,
                                x_dest_type_dsp         in out NOCOPY  varchar2,
                                x_src_type_dsp          in out NOCOPY  varchar2) is

  x_progress  varchar2(3) := '000';

  cursor c_lkp(x_lookup_type in varchar2,x_lookup_code in varchar2)  is
  select displayed_field
  from po_lookup_codes
  where lookup_type = x_lookup_type
  and lookup_code = x_lookup_code;

BEGIN

 x_progress  := '001';
 if x_auth_status_code is not null then
  open c_lkp('AUTHORIZATION STATUS',nvl(x_auth_status_code,'INCOMPLETE'));
   fetch c_lkp into x_auth_status_dsp;
   if c_lkp%NOTFOUND then
       x_auth_status_dsp := NULL;
   end if;
  close c_lkp;
 end if;

 x_progress  := '002';
 if x_tran_reason_code is not null then
  open c_lkp('TRANSACTION REASON', x_tran_reason_code);
   fetch c_lkp into  x_tran_reason_dsp;
   if c_lkp%notfound then
    x_tran_reason_dsp := NULL;
   end if;
  close c_lkp;
 end if;

 x_progress  := '003';
 if x_src_doc_type_code is not null then
  open c_lkp('SOURCE DOCUMENT TYPE',x_src_doc_type_code);
   fetch c_lkp into x_src_doc_type_dsp;
   if c_lkp%notfound then
    x_src_doc_type_dsp := NULL;
   end if;
  close c_lkp;
end if;

 x_progress  := '004';
 if x_dest_type_code is not null then
  open c_lkp('DESTINATION TYPE',x_dest_type_code);
   fetch c_lkp into x_dest_type_dsp;
   if c_lkp%notfound then
    x_dest_type_dsp := NULL;
   end if;
  close c_lkp;
 end if;

 x_progress  := '005';
 if x_src_type_code is not null then
  open c_lkp('REQUISITION SOURCE TYPE', x_src_type_code);
   fetch c_lkp into x_src_type_dsp;
   if c_lkp%notfound then
     x_src_type_dsp := NULL;
   end if;
  close c_lkp;
 end if;

EXCEPTION
  WHEN OTHERS THEN
    po_message_s.sql_error('po_reqs_inq_sv.get_reqln_pq_lookups', x_progress, sqlcode);
    raise;

END get_reqln_pq_lookups;

/*===========================================================================

  FUNCTION NAME:	get_ga_info

===========================================================================*/
PROCEDURE  get_ga_info   (X_po_header_id	IN NUMBER,
                          X_ga_flag             IN OUT NOCOPY VARCHAR2,
                          X_owning_org_name     IN OUT NOCOPY VARCHAR2 )  IS

X_progress                 VARCHAR2(3) := NULL;
X_owning_org_id            NUMBER;

BEGIN

 X_progress := '001';

 IF X_po_header_id is not NULL THEN

    SELECT POH.global_agreement_flag, POH.org_id
    INTO   X_ga_flag, X_owning_org_id
    FROM   PO_HEADERS_ALL POH
    WHERE  POH.PO_HEADER_ID = X_po_header_id;

    SELECT  name
    INTO    X_owning_org_name
    FROM    hr_organization_units
    WHERE   organization_id =  X_owning_org_id;

 END IF;

EXCEPTION

   WHEN NO_DATA_FOUND THEN
     X_ga_flag := 'N';
     X_owning_org_name := null;

   WHEN OTHERS THEN
     X_ga_flag := 'N';
     X_owning_org_name := null;


END get_ga_info;

---------------------------------------------------------------------------------------------
--Start of Comments
--SERVICES FPJ
--Name:         get_req_amount
--
--Pre-reqs:     None
--
--Modifies:     None
--
--Locks:        None
--
--Function:     This function gets the amount from the database for service lines and
--              calculates the amount from price and qty for other lines
--
--Parameters:
--IN:
--   p_mode
--      A value of 'I' or 'J' is passed depending on the calling level(I for line, J for
--      distribution
--   p_req_entity_id
--      Requisition line id or distribution id based on the calling level
--OUT:
--   Returns the req line or distribution amount
--
--Testing:  -
--End of Comments
-------------------------------------------------------------------------------------------------
FUNCTION   get_req_amount  (p_mode    	          IN  VARCHAR2,
                            p_req_entity_id       IN  NUMBER)
RETURN NUMBER IS

l_progress                 VARCHAR2(3) := NULL;
l_value_basis              PO_LINE_TYPES_B.order_type_lookup_code%TYPE;
l_req_amount               PO_REQUISITION_LINES_ALL.amount%TYPE;

BEGIN

 l_progress := '010';

 IF p_mode = 'I' THEN

    -- Sql What : Gets the line type corresponding to the req line id
    -- Sql Why : This is used to determine the amount

    l_progress := '020';

    Select plt.order_type_lookup_code
    Into   l_value_basis
    From   po_line_types_b plt,
           po_requisition_lines_all prl  --<Shared Proc FPJ>
    Where  plt.line_type_id = prl.line_type_id
    And    prl.requisition_line_id = p_req_entity_id;


 ELSE

    -- Sql What : Gets the line type corresponding to the req distribution id
    -- Sql Why : This is used to determine the amount

    l_progress := '030';

    Select plt.order_type_lookup_code
    Into   l_value_basis
    From   po_line_types_b plt,
           po_requisition_lines_all prl,  --<Shared Proc FPJ>
           po_req_distributions_all prd  --<Shared Proc FPJ>
    Where  plt.line_type_id = prl.line_type_id
    And    prl.requisition_line_id = prd.requisition_line_id
    And    prd.distribution_id = p_req_entity_id;

 END IF;

 IF l_value_basis in ('FIXED PRICE','RATE') THEN

    IF p_mode = 'I' THEN

         -- Sql What : Gets the amount on the req Line
         -- Sql Why : To return to the post-query procedure on the summary form

         l_progress := '040';

         Select prl.amount
         Into   l_req_amount
         From   po_requisition_lines_all prl  --<Shared Proc FPJ>
         Where  prl.requisition_line_id = p_req_entity_id;

    ELSE
         -- Sql What : Gets the amount on the req distribution
         -- Sql Why : To return to the post-query procedure on the summary form

         l_progress := '050';

         Select prd.req_line_amount
         Into   l_req_amount
         From   po_req_distributions_all prd  --<Shared Proc FPJ>
         Where  prd.distribution_id = p_req_entity_id;

    END IF;

 ELSE
     l_progress := '060';

     l_req_amount := PO_CORE_S.GET_TOTAL(p_mode,p_req_entity_id);

 END IF;

     Return l_req_amount;

EXCEPTION
  WHEN OTHERS THEN
    po_message_s.sql_error('po_reqs_inq_sv.get_req_amount', l_progress, sqlcode);
    raise;
END get_req_amount;

END PO_REQS_INQ_SV;

/
