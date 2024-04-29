--------------------------------------------------------
--  DDL for Package Body PO_AUTOSOURCE_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_AUTOSOURCE_SV" AS
/* $Header: POXSRCDB.pls 120.24.12010000.23 2012/06/20 15:01:43 swagajul ship $*/

G_PKG_NAME  CONSTANT VARCHAR2(30) := 'PO_AUTOSOURCE_SV';

--<Shared Proc FPJ START>
g_log_head  CONSTANT VARCHAR2(50) := 'po.plsql.' || g_pkg_name || '.';

g_debug_stmt BOOLEAN := PO_DEBUG.is_debug_stmt_on;

g_debug_unexp BOOLEAN := PO_DEBUG.is_debug_unexp_on;
--<Shared Proc FPJ END>
g_root_invoking_module VARCHAR2(30); --<bug#4936992>
-------------------------------------------------------------------------------
--Start of Comments
--Name: AUTOSOURCE
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  This procedure performs automatic document sourcing based on item/item category,
--  supplier/supplier site, and profile option settings
--Parameters:
--IN:
--x_mode
--  Valid values 'VENDOR','INVENTORY', 'BOTH', 'DOCUMENT'
--x_destination_doc_type
--  The form from which the call to the API is made. Vaild values are
--  'PO', 'REQ', 'STANDARD PO', 'REQ_NONCATALOG' and NULL.
--  'REQ_NONCATALOG' is for requisition lines that are non-catalog requests (created
--  through iProcurement)  -- <Contract AutoSourcing FPJ >
--x_item_id
--  item_id to be matched to source document
--x_commodity_id
--  The same as category_id, used in category-based ASL sourcing
--x_dest_organization_id
--  Destination organization id
--x_dest_subinventory
--  Destination subinventory
--x_autosource_date
--  Date to be used for Sourcing date check
--x_item_rev
--  Item revision that needs to be compared to.
--x_currency_code
--  Currency code to be compared to get matching document
--IN OUT:
--x_vendor_id
--  Vendor id to be matched to source document or ASL
--x_vendor_site_id
--  This parameter is used as IN OUT parameter. For callers who do not want
--  to do vendor site sourcing will pass in a value and set vendor_site_sourcing_flag
--  = 'N'. When vendor_site_sourcing_flag = 'Y' then this parameter would contain
--  the site_id obtained by vendor site sourcing
--x_vendor_contact_id
--  If there is a unique contact id present then this returns that value
--x_source_organization_id,
--  Organization that owns the source document
--x_source_subinventory
--  Subinventory that associated with the source document
--x_document_header_id
--  The unique identifier of the document returned
--x_document_line_id
--  The unique identifier of the document line returned
--x_document_type_code
--  Valid values 'BLANKET', 'QUOTATION' and 'CONTRACT'
--x_document_line_num
--  The line number of the document returned
--x_buyer_id
--  The buyer mentioned on the document returned
--x_vendor_product_num
--  Supplier product_num associated with given Item
--x_purchasing_uom
--  Purchasing unit of measure
--x_asl_id
--  Unique identifier of the ASL associated with the source document
--Testing:
--  None
--End of Comments
-----------------------------------------------------------------------------*/
--<PKGCOMP R12 Start>
-- We need the value of the asl_id in the PO_AUTOSOURCE_SV.reqimport_sourcing. We
-- have to get it from the PO_AUTOSOURCE_SV.autosource. Added a new parameter
-- x_asl_id as IN OUT type so that we can pass this value back to the
-- calling procedure.
--<PKGCOMP R12 End>
PROCEDURE autosource(
		x_mode				IN	VARCHAR2,
		x_destination_doc_type		IN	VARCHAR2,
		x_item_id			IN	NUMBER,
		x_commodity_id			IN	NUMBER,
		x_dest_organization_id		IN	NUMBER,
		x_dest_subinventory		IN	VARCHAR2,
		x_autosource_date		IN	DATE,
		x_item_rev			IN	VARCHAR2,
		x_currency_code			IN	VARCHAR2,
		x_vendor_id			IN OUT NOCOPY  NUMBER,
		x_vendor_site_id		IN OUT NOCOPY  NUMBER,
		x_vendor_contact_id		IN OUT NOCOPY  NUMBER,
		x_source_organization_id	IN OUT	NOCOPY NUMBER,
		x_source_subinventory		IN OUT	NOCOPY VARCHAR2,
		x_document_header_id		IN OUT NOCOPY  NUMBER,
		x_document_line_id		IN OUT	NOCOPY NUMBER,
		x_document_type_code		IN OUT NOCOPY  VARCHAR2,
		x_document_line_num		IN OUT	NOCOPY NUMBER,
		x_buyer_id			IN OUT NOCOPY  NUMBER,
		x_vendor_product_num		IN OUT NOCOPY  VARCHAR2,
		x_purchasing_uom		IN OUT NOCOPY  VARCHAR2,
		x_asl_id 		        IN OUT NOCOPY NUMBER --<PKGCOMP R12>
                --<R12 STYLES PHASE II START>
               ,p_purchase_basis   IN VARCHAR2 DEFAULT NULL,
                p_line_type_id     IN VARCHAR2 DEFAULT NULL,
                p_destination_type IN VARCHAR2 DEFAULT NULL,
                p_style_id         IN NUMBER   DEFAULT NULL
                --<R12 STYLES PHASE II END>
) IS
    x_sourcing_rule_id	    NUMBER;
    -- Bug 2836530 Changed x_error_message from VARCHAR2(240) to %TYPE
    x_error_message	    FND_NEW_MESSAGES.message_text%TYPE := '';
    x_organization_id	    NUMBER;
    x_item_buyer_id         NUMBER;
    x_ga_flag               VARCHAR2(1) := '';
    x_owning_org_id         NUMBER;
    x_fsp_org_id            NUMBER;
    l_vendor_site_code      PO_VENDOR_SITES_ALL.vendor_site_code%TYPE; --<Shared Proc FPJ>
    l_return_code           BOOLEAN; --<Bug 3234201 mbhargav>
    l_buyer_ok              VARCHAR2(1); --<Shared Proc FPJ>
    l_progress              VARCHAR2(3) := '000'; -- Bug 2836530
    l_log_head     CONSTANT VARCHAR2(100) := g_log_head||'autosource';
BEGIN

    IF g_debug_stmt THEN
       PO_DEBUG.debug_begin(l_log_head);
       PO_DEBUG.debug_var(l_log_head,l_progress,'x_mode', x_mode);
       PO_DEBUG.debug_var(l_log_head,l_progress,'x_item_id', x_item_id);
       PO_DEBUG.debug_var(l_log_head,l_progress,'x_commodity_id', x_commodity_id);
       PO_DEBUG.debug_var(l_log_head,l_progress,'x_dest_organization_id', x_dest_organization_id);
       PO_DEBUG.debug_var(l_log_head,l_progress,'x_autosource_date', x_autosource_date);
    END IF;

    l_progress := '001';

/* AGARG Bug# 523766
   The following code has been duplicated in reqimport_sourcing procedure in order
   to avoid calling the MRP sourcing routines if the vendor and vendor site is already
   known. In that case we want to do every thing in this procedure for x_mode of VENDOR
   other than calling the mrp_sourcing_api_pk.mrp_sourcing.
   SO if any souring changes are made in this routine they should also be duplicated in
   reqimport_sourcing procedure.
   This has been done , since autosource is called from a lot of other places besides
   Req Import. and the above change is Req Import specific.
*/

    IF x_dest_organization_id IS NULL THEN

        -- Get organization_id from financials_system_parameters.
        SELECT   inventory_organization_id
        INTO     x_organization_id
        FROM     financials_system_parameters;

    ELSE
	    x_organization_id := x_dest_organization_id;
    END IF;

    l_progress := '010';

    -- Get buyer_id from item definition.  If we cannot get buyer_id from
    -- the item definition then we will try to get it from the source document.

    /*  Bug - 1135210 - Added the Exception NO_DATA_FOUND, if the sql returns
    **  no data. This is done to avoid the system from hanging when the item
    **  that has been entered is not valid in that destination org in the
    **  Enter Req form.
    **/

    IF (x_item_id IS NOT NULL) THEN

     BEGIN
       SELECT   msi.buyer_id
       INTO     x_buyer_id
       FROM	mtl_system_items msi
       WHERE    msi.inventory_item_id = x_item_id
       AND	msi.organization_id = x_organization_id;

      x_item_buyer_id := x_buyer_id;    -- FPI GA

      IF g_debug_stmt THEN
         PO_DEBUG.debug_var(l_log_head,l_progress,'x_item_buyer_id', x_item_buyer_id);
      END IF;

     EXCEPTION
         WHEN NO_DATA_FOUND THEN
            x_buyer_id := NULL;
            x_item_buyer_id := NULL;
     END;
--bug#3048965 if the buyer id in mtl_system_items table is null then
--we make an attempt to default it from the po_agents table
--if there is only one buyer defined for the category associated
--with the Purchasing category set of the concerned item.
     IF(x_buyer_id is null)THEN
	begin
	        select poa.agent_id into x_buyer_id
		from po_agents poa,mtl_item_categories mic
		where mic.inventory_item_id=x_item_id
		and mic.category_id=poa.category_id
		and mic.organization_id=x_organization_id
		and mic.category_set_id=(select category_set_id
	                        	 from   mtl_default_sets_view
                        		 where  functional_area_id = 2);
		 x_item_buyer_id := x_buyer_id;
	exception
		when others then
--bug#3048965 if more than one record is found or in case of
--other error we just make the buyer id null
			x_buyer_id:=null;
			x_item_buyer_id:=null;
	end;
--bug#3048965

     END IF;

    END IF;

    l_progress := '020';

    IF (x_mode IN ('VENDOR', 'INVENTORY', 'BOTH')) THEN

       l_progress := '030';
       IF g_debug_stmt THEN
          PO_DEBUG.debug_stmt(l_log_head,l_progress,'Calling MRP Sourcing API');
       END IF;

       --<Shared Proc FPJ START>
       --<Bug 3234201 mbhargav START>
       --Call the signature of mrp_sourcing_api which returns
       --vendor_site_code instead of vendor_site_id. This
       --vendor_site_code will be used to determine vendor_site_id
       --in document_sourcing procedure
       l_return_code := MRP_SOURCING_API_PK.mrp_sourcing(
               arg_mode		            =>x_mode,
               arg_item_id	            => x_item_id,
               arg_commodity_id		    => x_commodity_id,
               arg_dest_organization_id   =>x_organization_id,
               arg_dest_subinventory	    =>x_dest_subinventory,
               arg_autosource_date	    =>trunc(nvl(x_autosource_date, sysdate)),
               arg_vendor_id		        =>    x_vendor_id,
               arg_vendor_site_code	    =>l_vendor_site_code,
               arg_source_organization_id =>x_source_organization_id,
               arg_source_subinventory 	=>x_source_subinventory,
               arg_sourcing_rule_id 	    =>x_sourcing_rule_id,
               arg_error_message 	        =>x_error_message);
        --<Bug 3234201 mbhargav END>
	  if ( not l_return_code and trunc(x_autosource_date) <> trunc(sysdate)) then
                    l_return_code := MRP_SOURCING_API_PK.mrp_sourcing(
                   arg_mode                    =>x_mode,
                   arg_item_id                => x_item_id,
                   arg_commodity_id            => x_commodity_id,
                   arg_dest_organization_id   =>x_organization_id,
                  arg_dest_subinventory        =>x_dest_subinventory,
                   arg_autosource_date        =>trunc(sysdate),     -- bug6825123
                   arg_vendor_id                =>    x_vendor_id,
                   arg_vendor_site_code        =>l_vendor_site_code,
                   arg_source_organization_id =>x_source_organization_id,
                   arg_source_subinventory     =>x_source_subinventory,
                   arg_sourcing_rule_id         =>x_sourcing_rule_id,
                   arg_error_message             =>x_error_message);
           end if;
        --<Shared Proc FPJ END>

        l_progress := '040';
         IF g_debug_stmt THEN
            --PO_DEBUG.debug_var(l_log_head,l_progress,'MRP API return status', l_return_status);
            PO_DEBUG.debug_var(l_log_head,l_progress,'x_vendor_id', x_vendor_id);
            PO_DEBUG.debug_var(l_log_head,l_progress,'l_vendor_site_code', l_vendor_site_code);
            PO_DEBUG.debug_var(l_log_head,l_progress,'x_source_organization_id', x_source_organization_id);
            PO_DEBUG.debug_var(l_log_head,l_progress,'x_sourcing_rule_id', x_sourcing_rule_id);
            PO_DEBUG.debug_var(l_log_head,l_progress,'x_error_message', x_error_message);
        END IF;

        l_progress := '045';
        IF NOT l_return_code THEN
           x_error_message := FND_MESSAGE.get;
           IF g_debug_stmt THEN
              PO_DEBUG.debug_var(l_log_head,l_progress,'x_error_message', x_error_message);
           END IF;
        END IF;

            --<Contract AutoSourcing FPJ>: Removed 'x_item_id is not null' condition because
            --category-based ASL sourcing is enabled
	    IF (l_return_code
            AND x_mode IN ('VENDOR', 'BOTH')) THEN

               IF g_debug_stmt THEN
                  PO_DEBUG.debug_stmt(l_log_head,l_progress,'Calling Document Sourcing');
               END IF;

               --<Shared Proc FPJ START>
               --The document sourcing will also do vendor site_id sourcing
               --We set vendor_site_sourcing_flag to 'Y' and pass vendor_site_code
	       --<PKGCOMP R12 Start>
	       -- Replaced the hardcoded NULL with x_asl_id as we need to communicate it back
	       -- to reqimport_sourcing.
	       --<PKGCOMP R12 End>
               document_sourcing(
                    x_item_id			=>x_item_id,
               	    x_vendor_id		        =>x_vendor_id,
               	    x_destination_doc_type	=>x_destination_doc_type,
                    x_organization_id 		=>x_organization_id,
                    x_currency_code 		=>x_currency_code,
                    x_item_rev			=>x_item_rev,
                    x_autosource_date 		=>x_autosource_date,
                    x_vendor_site_id 		=>x_vendor_site_id,
                    x_document_header_id	=>x_document_header_id,
                    x_document_type_code 	=>x_document_type_code,
                    x_document_line_num	        =>x_document_line_num,
                    x_document_line_id		=>x_document_line_id,
                    x_vendor_contact_id		=>x_vendor_contact_id,
                    x_vendor_product_num 	=>x_vendor_product_num,
                    x_buyer_id 		        =>x_buyer_id,
                    x_purchasing_uom		=>x_purchasing_uom,
                    x_asl_id			=>x_asl_id, --<PKGCOMP R12>
                    x_multi_org		        =>'N',
                    p_vendor_site_sourcing_flag	=>'Y',
                    p_vendor_site_code		=>l_vendor_site_code,
                    p_category_id               =>x_commodity_id --<Contract AutoSourcing FPJ>
                    --<R12 STYLES PHASE II START>
                   ,p_purchase_basis   => p_purchase_basis,
                    p_line_type_id     => p_line_type_id,
                    p_destination_type => p_destination_type,
                    p_style_id         => p_style_id
                    --<R12 STYLES PHASE II END>
                );
                l_progress := '050';
                IF g_debug_stmt THEN
                   PO_DEBUG.debug_stmt(l_log_head,l_progress,'Document Sourcing Returned');
                   PO_DEBUG.debug_var(l_log_head,l_progress,'x_vendor_site_id', x_vendor_site_id);
                   PO_DEBUG.debug_var(l_log_head,l_progress,'x_document_header_id', x_document_header_id);
                   PO_DEBUG.debug_var(l_log_head,l_progress,'x_document_line_id', x_document_line_id);
                END IF;


                IF l_vendor_site_code is NOT NULL
                   AND x_vendor_site_id is NULL THEN

                   IF g_debug_stmt THEN
                      PO_DEBUG.debug_stmt(l_log_head,l_progress,
                           'No Source Doc found, getting site from current OU');
                   END IF;

                   BEGIN
                        SELECT vendor_site_id
                        INTO x_vendor_site_id
                        FROM po_vendor_sites_all pvs,
                             org_organization_definitions oog
                        WHERE pvs.vendor_site_code = l_vendor_site_code
                        AND   nvl(pvs.org_id,nvl(oog.operating_unit,-1)) =
                                                      nvl(oog.operating_unit,-1)
                        AND  oog.organization_id = x_organization_id
                        AND  pvs.vendor_id = x_vendor_id;
                    EXCEPTION
                        WHEN OTHERS THEN
                            x_vendor_site_id := NULL;
                            x_vendor_id := NULL;
                    END;
                END IF; --vendor_site_code check
                --<Shared Proc FPJ END>

	     END IF;
         l_progress := '060';
    ELSIF x_mode = 'DOCUMENT' THEN

        l_progress := '070';
        IF g_debug_stmt THEN
           PO_DEBUG.debug_stmt(l_log_head,l_progress,'Calling Document Sourcing');
        END IF;
       --<Shared Proc FPJ START>
       --In DOCUMENT mode we do not need to vendor site sourcing.
       --It is assumed that vendor_site_id is valid. The vendor_site_sourcing_flag is set to N

       --<PKGCOMP R12 Start>
       -- Replaced the hardcoded NULL with x_asl_id as we need to communicate it back
       -- to reqimport_sourcing.
       --<PKGCOMP R12 End>

       document_sourcing(
                	x_item_id		=>x_item_id,
               	        x_vendor_id		=>x_vendor_id,
               	        x_destination_doc_type	=>x_destination_doc_type,
                	x_organization_id 	=>x_organization_id,
                	x_currency_code 	=>x_currency_code,
                	x_item_rev		=>x_item_rev,
                	x_autosource_date 	=>x_autosource_date,
                	x_vendor_site_id 	=>x_vendor_site_id,
                	x_document_header_id	=>x_document_header_id,
                	x_document_type_code 	=>x_document_type_code,
                	x_document_line_num	=>x_document_line_num,
                	x_document_line_id	=>x_document_line_id,
                	x_vendor_contact_id	=>x_vendor_contact_id,
                	x_vendor_product_num 	=>x_vendor_product_num,
                	x_buyer_id 		=>x_buyer_id,
                	x_purchasing_uom	=>x_purchasing_uom,
                	x_asl_id		=>x_asl_id, --<PKGCOMP R12>
                	x_multi_org		=>'N',
                	p_vendor_site_sourcing_flag	=>'N',
                	p_vendor_site_code	=>NULL,
                        p_category_id           =>x_commodity_id --<Contract AutoSourcing FPJ >
                        --<R12 STYLES PHASE II START>
                       ,p_purchase_basis   => p_purchase_basis,
                        p_line_type_id     => p_line_type_id,
                        p_destination_type => p_destination_type,
                        p_style_id         => p_style_id
                        --<R12 STYLES PHASE II END>
                  	);
         IF g_debug_stmt THEN
            PO_DEBUG.debug_stmt(l_log_head,l_progress,'Document Sourcing Returned');
            PO_DEBUG.debug_var(l_log_head,l_progress,'x_vendor_site_id', x_vendor_site_id);
            PO_DEBUG.debug_var(l_log_head,l_progress,'x_document_header_id', x_document_header_id);
            PO_DEBUG.debug_var(l_log_head,l_progress,'x_document_line_id', x_document_line_id);
        END IF;
        --<Shared Proc FPJ END>

        l_progress := '080';

    END IF;

    l_progress := '090';

 /* FPI GA start */
 /* For a global agreement from another org do not get the buyer from the document */
  IF x_document_header_id is not null
     AND x_buyer_id is NOT NULL --<Shared Proc FPJ>
  THEN

     l_progress := '100';
     --<Shared Proc FPJ START>
     --The buyer on Source Document should be in the same business group as
     --the requesting operating unit(current OU) or the profile option HR: Cross
     --Business Group should be set to 'Y'. These two conditions are checked in
     --view definition of per_people_f
     BEGIN
          SELECT 'Y'
          INTO l_buyer_ok
          FROM per_people_f ppf
          WHERE x_buyer_id = ppf.person_id
           AND trunc(sysdate) between ppf.effective_start_date
                                     AND NVL(ppf.effective_end_date, sysdate +1);
     EXCEPTION WHEN OTHERS THEN
           x_buyer_id := x_item_buyer_id;
     END;
     --<Shared Proc FPJ END>
  END IF;
 /* FPI GA end */
  l_progress := '110';
  IF g_debug_stmt THEN
   PO_DEBUG.debug_end(l_log_head);
  END IF;
-- Bug 2836540 START
EXCEPTION
    WHEN OTHERS THEN
     IF g_debug_unexp THEN
      PO_DEBUG.debug_exc(l_log_head,l_progress);
     END IF;
	PO_MESSAGE_S.SQL_ERROR('AUTOSOURCE', l_progress, sqlcode);
-- Bug 2836540 END
END autosource;

--<PKGCOMP R12 Start>
-------------------------------------------------------------------------------
--Start of Comments
--Name: AUTOSOURCE
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
-- This is the overloaded procedure that will be called by all the routines,
-- which were already calling PO_AUTOSOURCE_SV.autosource without ASL_ID parameter.
-- This procedure in turn will call the autosource procedure, which has the
-- additional parameter x_asl_id with a NULL value.
--End of Comments
 -------------------------------------------------------------------------------
  PROCEDURE autosource(x_mode                   IN VARCHAR2,
                       x_destination_doc_type   IN VARCHAR2,
                       x_item_id                IN NUMBER,
                       x_commodity_id           IN NUMBER,
                       x_dest_organization_id   IN NUMBER,
                       x_dest_subinventory      IN VARCHAR2,
                       x_autosource_date        IN DATE,
                       x_item_rev               IN VARCHAR2,
                       x_currency_code          IN VARCHAR2,
                       x_vendor_id              IN OUT NOCOPY NUMBER,
                       x_vendor_site_id         IN OUT NOCOPY NUMBER,
                       x_vendor_contact_id      IN OUT NOCOPY NUMBER,
                       x_source_organization_id IN OUT NOCOPY NUMBER,
                       x_source_subinventory    IN OUT NOCOPY VARCHAR2,
                       x_document_header_id     IN OUT NOCOPY NUMBER,
                       x_document_line_id       IN OUT NOCOPY NUMBER,
                       x_document_type_code     IN OUT NOCOPY VARCHAR2,
                       x_document_line_num      IN OUT NOCOPY NUMBER,
                       x_buyer_id               IN OUT NOCOPY NUMBER,
                       x_vendor_product_num     IN OUT NOCOPY VARCHAR2,
                       x_purchasing_uom         IN OUT NOCOPY VARCHAR2
                       --<R12 STYLES PHASE II START>
                      ,p_purchase_basis   IN VARCHAR2 DEFAULT NULL,
                       p_line_type_id     IN VARCHAR2 DEFAULT NULL,
                       p_destination_type IN VARCHAR2 DEFAULT NULL,
                       p_style_id         IN NUMBER DEFAULT NULL
                       --<R12 STYLES PHASE II END>
		       ) IS

    l_asl_id PO_ASL_DOCUMENTS.ASL_ID%type;

  begin
    l_asl_id := NULL;
    autosource(x_mode                   => x_mode,
               x_destination_doc_type   => x_destination_doc_type,
               x_item_id                => x_item_id,
               x_commodity_id           => x_commodity_id,
               x_dest_organization_id   => x_dest_organization_id,
               x_dest_subinventory      => x_dest_subinventory,
               x_autosource_date        => x_autosource_date,
               x_item_rev               => x_item_rev,
               x_currency_code          => x_currency_code,
               x_vendor_id              => x_vendor_id,
               x_vendor_site_id         => x_vendor_site_id,
               x_vendor_contact_id      => x_vendor_contact_id,
               x_source_organization_id => x_source_organization_id,
               x_source_subinventory    => x_source_subinventory,
               x_document_header_id     => x_document_header_id,
               x_document_line_id       => x_document_line_id,
               x_document_type_code     => x_document_type_code,
               x_document_line_num      => x_document_line_num,
               x_buyer_id               => x_buyer_id,
               x_vendor_product_num     => x_vendor_product_num,
               x_purchasing_uom         => x_purchasing_uom,
               x_asl_id                 => l_asl_id
               --<R12 STYLES PHASE II START>
              ,p_purchase_basis   => p_purchase_basis,
               p_line_type_id     => p_line_type_id,
               p_destination_type => p_destination_type,
               p_style_id         => p_style_id
               --<R12 STYLES PHASE II END>
               );

  end autosource;
--<PKGCOMP R12 End>

/* CONSIGNED FPI START */

/*===========================================================================

  PROCEDURE NAME:       get_asl_info

  REQUIRED INPUTS:

  OPTIONAL INPUTS:

  OUTPUTS:

  ALGORITHM:		Returns the supplier item number and purchasing
			UOM from the ASL entry.

  NOTES    : Asl_id can also obtained from Get_All_Item_Asl procedure.
	     This is the same as x_asl_id but returns vendor_id also and
	     in an array. When any changes are made to get_asl_info
     	     need to consider Get_All_Item_Asl procedure also.

===========================================================================*/

PROCEDURE get_asl_info(
		x_item_id		IN 	NUMBER,
		x_vendor_id		IN 	NUMBER,
	        x_vendor_site_id	IN	NUMBER,
		x_using_organization_id	IN OUT	NOCOPY NUMBER,
		x_asl_id		IN OUT	NOCOPY NUMBER,
		x_vendor_product_num	IN OUT	NOCOPY VARCHAR2,
		x_purchasing_uom	IN OUT  NOCOPY VARCHAR2,
                p_category_id           IN      NUMBER --<Contract AutoSourcing FPJ>
)
IS

l_consigned_from_supplier_flag   VARCHAR2(1)  := NULL;
l_enable_vmi_flag                VARCHAR2(1)  := NULL;
l_last_billing_date              DATE         := NULL;
l_consigned_billing_cycle        NUMBER       := NULL;
l_vmi_min_qty                    NUMBER       := NULL;
l_vmi_max_qty                    NUMBER       := NULL;
l_vmi_auto_replenish_flag VARCHAR2(1)  := NULL;
l_vmi_replenishment_approval     VARCHAR2(30) := NULL;

BEGIN
  get_asl_info
    ( x_item_id                       => x_item_id
    , x_vendor_id                     => x_vendor_id
    , x_vendor_site_id                => x_vendor_site_id
    , x_using_organization_id         => x_using_organization_id
    , x_asl_id                        => x_asl_id
    , x_vendor_product_num            => x_vendor_product_num
    , x_purchasing_uom                => x_purchasing_uom
    , x_consigned_from_supplier_flag  => l_consigned_from_supplier_flag
    , x_enable_vmi_flag               => l_enable_vmi_flag
    , x_last_billing_date             => l_last_billing_date
    , x_consigned_billing_cycle       => l_consigned_billing_cycle
    , x_vmi_min_qty                   => l_vmi_min_qty
    , x_vmi_max_qty                   => l_vmi_max_qty
    , x_vmi_auto_replenish_flag       => l_vmi_auto_replenish_flag
    , x_vmi_replenishment_approval    => l_vmi_replenishment_approval
    , p_category_id                   => p_category_id --<Contract AutoSourcing FPJ>
    );
END;


/*===========================================================================

  PROCEDURE NAME:       get_asl_info

  REQUIRED INPUTS:

  OPTIONAL INPUTS:

  OUTPUTS:      x_using_organization_id	        - actual organization of
                                                  the ASL
		x_asl_id		        - ASL identifier
		x_vendor_product_num	        - supplier item number
		x_purchasing_uom	        - Purchasing Unit of Masure
		x_consigned_from_supplier_flag  - consigned enabled flag
i                x_enable_vmi_flag               - vmi enabled flag
		x_last_billing_date             - Last date when the consigned
		                                  consumption concurrent
						  program ran
		x_consigned_billing_cycle       - The number of days before
		                                  summarizing the consigned
						  POs received and transfer
						  the goods to regular stock
		x_vmi_min_qty                   - Min Quantity for VMI
		                                  replenishment
                x_vmi_max_qty                   - Max Quantity for VMI
		                                  replenishment
		x_vmi_auto_replenish_flag       - To allow/disallow automatic
		                                  replenishment function
		x_vmi_replenishment_approval    - ability to release
                                                  replenishment requests
                                                  automatically using
						  Collaborative Planning.
						  Valid values: None, Supplier
						  or Buyer, Buyer

  ALGORITHM:		Returns the supplier item number and purchasing
			UOM from the ASL entry, plus the Consigned From
			Supplier and VMI settings.

  NOTES    : Asl_id can also obtained from Get_All_Item_Asl procedure.
	     This is the same as x_asl_id but returns vendor_id also and
	     in an array. When any changes are made to get_asl_info
     	     need to consider Get_All_Item_Asl procedure also.

===========================================================================*/

PROCEDURE get_asl_info(
		x_item_id		        IN      NUMBER,
		x_vendor_id		        IN      NUMBER,
	        x_vendor_site_id	        IN      NUMBER,
		x_using_organization_id	        IN OUT  NOCOPY NUMBER,
		x_asl_id		        IN OUT  NOCOPY NUMBER,
		x_vendor_product_num	        IN OUT  NOCOPY VARCHAR2,
		x_purchasing_uom	        IN OUT  NOCOPY VARCHAR2,
		x_consigned_from_supplier_flag  OUT     NOCOPY VARCHAR2,
                x_enable_vmi_flag               OUT     NOCOPY VARCHAR2,
		x_last_billing_date             OUT     NOCOPY DATE,
		x_consigned_billing_cycle       OUT     NOCOPY NUMBER,
		x_vmi_min_qty                   OUT     NOCOPY NUMBER,
                x_vmi_max_qty                   OUT     NOCOPY NUMBER,
		x_vmi_auto_replenish_flag       OUT     NOCOPY VARCHAR2,
		x_vmi_replenishment_approval    OUT     NOCOPY VARCHAR2,
                p_category_id                   IN      NUMBER --<Contract AutoSourcing FPJ>
)

IS

	l_progress		VARCHAR2(3) := '010';

        --<Contract AutoSourcing FPJ>
	--If 'Y', look for item-based ASL; if 'N', look for category-based ASL
	l_item_based_asl        VARCHAR2(1):= 'Y';
	l_log_head   CONSTANT VARCHAR2(100):= g_log_head||'get_asl_info';

    --<Bug 3545698 mbhargav>
    -- Separated out cursor C into two cursors L_ITEM_CSR and L_CATEGORY_CSR.
    -- This was required for performance reasons. With this change the Optimizer
    -- will be able to use combination index on (vendor_id, item_id) or
    -- (vendor_id, category_id) as appropriate.

	-- Cursor l_item_csr finds the asl entries that matches the ITEM, vendor
	-- and vendor site.  It gets the local entry before the global.
	-- It also fetches the purchasing UOM for this ASL entry.  It
        -- fetches the UOM from the local attributes record before the
	-- the global.

/* Bug # 1671405. pchintal
Added the table PO_ASL_STATUS_RULES_V and corresponding where condition
to the below cursor so that it will not fetch those asl_id's whose
status has a control value of PREVENT and rule is SOURCING, so that
the ASL with status debarred will not be picked and sourcing will happen
properly.
*/

        --Note: If you make any change in this cursor then consider whether you
        --      need to make change to cursor L_CATEGORY_CSR as well
        CURSOR L_ITEM_CSR is
    	  SELECT   pasl.asl_id,
                   paa.using_organization_id,
		   pasl.primary_vendor_item,
	           paa.purchasing_unit_of_measure,
		   paa.consigned_from_supplier_flag,
		   paa.enable_vmi_flag,
		   paa.last_billing_date,
		   paa.consigned_billing_cycle,
		   paa.vmi_min_qty,
                   paa.vmi_max_qty,
		   paa.enable_vmi_auto_replenish_flag,
		   paa.vmi_replenishment_approval
    	  FROM     po_approved_supplier_lis_val_v pasl,
		   po_asl_attributes paa,
           po_asl_status_rules_v pasr
    	  WHERE    pasl.item_id = x_item_id  -- <Contract AutoSourcing FPJ>
    	  AND	   pasl.vendor_id = x_vendor_id
    	  AND	   (nvl(pasl.vendor_site_id, -1) = nvl(x_vendor_site_id, -1)
                   OR pasl.vendor_site_id IS NULL) --Bug #13743965
    	  AND	   pasl.using_organization_id IN (-1, x_using_organization_id)
	  AND	   pasl.asl_id = paa.asl_id
          AND      pasr.business_rule like '2_SOURCING'
          AND      pasr.allow_action_flag like 'Y'
          AND      pasr.status_id = pasl.asl_status_id
	  AND	   paa.using_organization_id =
			(SELECT  max(paa2.using_organization_id)
			 FROM	 po_asl_attributes paa2
			 WHERE   paa2.asl_id = pasl.asl_id
                         AND     paa2.using_organization_id IN (-1, x_using_organization_id))
	  ORDER BY pasl.using_organization_id DESC,
                   NVL(pasl.vendor_site_id,-1) DESC; --Bug #13743965

	-- Cursor l_category_csr finds the asl entries that matches the CATEGORY, vendor
	-- and vendor site.  It gets the local entry before the global.
	-- It also fetches the purchasing UOM for this ASL entry.  It
        -- fetches the UOM from the local attributes record before the
	-- the global.

        --Note: If you make any change in this cursor then consider whether you
        --      need to make change to cursor L_ITEM_CSR as well
        CURSOR L_CATEGORY_CSR is
    	  SELECT   pasl.asl_id,
                   paa.using_organization_id,
		   pasl.primary_vendor_item,
	           paa.purchasing_unit_of_measure,
		   paa.consigned_from_supplier_flag,
		   paa.enable_vmi_flag,
		   paa.last_billing_date,
		   paa.consigned_billing_cycle,
		   paa.vmi_min_qty,
                   paa.vmi_max_qty,
		   paa.enable_vmi_auto_replenish_flag,
		   paa.vmi_replenishment_approval
    	  FROM     po_approved_supplier_lis_val_v pasl,
		   po_asl_attributes paa,
                   po_asl_status_rules_v pasr
    	  WHERE    pasl.category_id = p_category_id  -- <Contract AutoSourcing FPJ>
    	  AND	   pasl.vendor_id = x_vendor_id
    	  AND	   (nvl(pasl.vendor_site_id, -1) = nvl(x_vendor_site_id, -1)
	 	   OR pasl.vendor_site_id is NULL) -- Bug #13743965
    	  AND	   pasl.using_organization_id IN (-1, x_using_organization_id)
	  AND	   pasl.asl_id = paa.asl_id
          AND      pasr.business_rule like '2_SOURCING'
          AND      pasr.allow_action_flag like 'Y'
          AND      pasr.status_id = pasl.asl_status_id
	  AND	   paa.using_organization_id =
			(SELECT  max(paa2.using_organization_id)
			 FROM	 po_asl_attributes paa2
			 WHERE   paa2.asl_id = pasl.asl_id
                         AND     paa2.using_organization_id IN (-1, x_using_organization_id))
	  ORDER BY pasl.using_organization_id DESC,
                   NVL(pasl.vendor_site_id,-1) DESC; --Bug #13743965

BEGIN

  --<Contract AutoSourcing FPJ Start>
  -- Get the item-based ASL if item_id exists
  IF g_debug_stmt THEN
     PO_DEBUG.debug_stmt(p_log_head => l_log_head,
                         p_token    => l_progress,
                         p_message  => 'Look for item-based ASL first...');
  END IF;

  IF x_item_id IS NOT NULL THEN
     OPEN L_ITEM_CSR; --<Bug 3545698>
     FETCH L_ITEM_CSR into x_asl_id,
                  x_using_organization_id,
		  x_vendor_product_num,
		  x_purchasing_uom,
		  x_consigned_from_supplier_flag,
		  x_enable_vmi_flag,
		  x_last_billing_date,
		  x_consigned_billing_cycle,
                  x_vmi_min_qty,
                  x_vmi_max_qty,
	  	  x_vmi_auto_replenish_flag,
	 	  x_vmi_replenishment_approval;

     CLOSE L_ITEM_CSR;
  END IF;

  l_progress := '020';
  IF g_debug_stmt THEN
     PO_DEBUG.debug_stmt(p_log_head => l_log_head,
                         p_token    => l_progress,
                         p_message  => 'Item-based asl id: '||x_asl_id);
  END IF;

  IF x_asl_id IS NOT NULL THEN
     return;
  ELSIF (x_asl_id IS NULL) OR (x_item_id IS NULL) THEN
     l_item_based_asl := 'N';

     l_progress := '025';
     IF g_debug_stmt THEN
        PO_DEBUG.debug_stmt(p_log_head => l_log_head,
                            p_token    => l_progress,
                            p_message  => 'Look for category-based asl');
     END IF;

     OPEN L_CATEGORY_CSR;  --<Bug 3545698>
     FETCH L_CATEGORY_CSR into x_asl_id,
                  x_using_organization_id,
		  x_vendor_product_num,
		  x_purchasing_uom,
		  x_consigned_from_supplier_flag,
		  x_enable_vmi_flag,
		  x_last_billing_date,
		  x_consigned_billing_cycle,
                  x_vmi_min_qty,
                  x_vmi_max_qty,
	  	  x_vmi_auto_replenish_flag,
	 	  x_vmi_replenishment_approval;

     CLOSE L_CATEGORY_CSR;
  END IF;

  l_progress := '030';
  IF g_debug_stmt THEN
     PO_DEBUG.debug_stmt(p_log_head => l_log_head,
                         p_token    => l_progress,
                         p_message  => 'Category-based asl_id: '||x_asl_id);
  END IF;
  --<Contract AutoSourcing FPJ End>

END;

/* CONSIGNED FPI END */

/* VMI FPH START */
/*===========================================================================

  PROCEDURE NAME:       vmi_enabled

  REQUIRED INPUTS:
                        x_item_id                 valid item_id
                        x_vendor_id               valid vendor_id
                        x_vendor_site_id          valid vendor_site_id
                        x_using_organization_id   valid using_organization_id

  OPTIONAL INPUTS:

  OUTPUTS:
                        'Y' if the ASL entry corresponding to the required input
                        is VMI enabled.

                        'N' if not VMI enabled, no ASL entry exists, or the
                        input data is incorrect

  ALGORITHM:
                        calls get_asl_info procedure
		        to determine the correct ASL entry. The enable_vmi_flag
                        then is queried for that ASL entry.

===========================================================================*/

FUNCTION  vmi_enabled
  ( x_item_id                  IN   NUMBER
  , x_vendor_id                IN   NUMBER
  , x_vendor_site_id           IN   NUMBER
  , x_using_organization_id    IN   NUMBER
  )
RETURN VARCHAR2
IS

  l_asl_id                  NUMBER;
  l_using_organization_id   NUMBER;
  l_vendor_product_num      VARCHAR2(25);
  l_purchasing_uom          VARCHAR2(25);
  l_enable_vmi_flag         VARCHAR2(1);

BEGIN

  l_using_organization_id  := x_using_organization_id;


  BEGIN
    get_asl_info
      ( x_item_id
      , x_vendor_id
      , x_vendor_site_id
      , l_using_organization_id
      , l_asl_id
      , l_vendor_product_num
      , l_purchasing_uom
      );

    SELECT
      enable_vmi_flag
    INTO
      l_enable_vmi_flag
    FROM
      po_asl_attributes  asl
    WHERE
        asl.asl_id                 =  l_asl_id
    AND asl.using_organization_id  =  l_using_organization_id
    ;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      NULL;
    WHEN OTHERS THEN
      NULL;
  END;


  IF  l_enable_vmi_flag  =  'Y'  THEN
    RETURN 'Y';
  ELSE
    RETURN 'N';
  END IF;

END vmi_enabled;
/* VMI FPH END */




/*===========================================================================

  PROCEDURE NAME:       document_sourcing

  REQUIRED INPUTS:	item_id
			vendor_id
			destination_doc_type  ('PO','REQ','STANDARD PO','REQ_NONCATALOG')

  OPTIONAL INPUTS:	organization_id
			currency_code
			item_rev
			vendor_site_id (if provided then do not do vendor site sourcing)
			autosource_date
            p_cendor_site_sourcing_flag(Should be Y to do vendor site sourcing)
            p_vendor_site_code (Used in vendor site sourcing)
                        p_category_id

  OUTPUTS:  vendor_site_id
			document_header_id
			document_type_code
			document_line_num
			document_line_id
			vendor_contact_id
			vendor_product_num
			buyer_id

  ALGORITHM:		This procedure returns sourcing information from a
			source document as follows:

  			o If destination_document_type is 'PO', source only
			  from quotations.  If destination document type is 'REQ',
			  source from quotations and blankets.

		   	o Get sourcing info from blanket only if document is
	  		  approved and not finally closed or canceled

			o Get sourcing info from quotations only if
			  document does not require approval or has been
			  approved.

        	o If currency_code, item_revision have null values,
			  any value would apply.

			o Fetch the local asl entries that matches the item, vendor
			  and vendor site.  Fetch the highest ranked document in
			  in ASL entry that matches the currency code, item
			  revision, and the criteria stated above.  If no such
			  document exists in the local entry, check the global entry.
              --<Shared Proc FPJ>
   			o If vendor site is not specified as an input and vendor_site_sourcing_flag
              is Y then this procedure will try to determine vendor_site_id using the
              vendor_site_code provided. This can come back with Blankets (Local
              and Global), Quotations within same operating unit. It can also
              return Global Agreements from another operating unti.
              It uses ASLs and Global Agreement to do vendor site sourcing

            o Depending on the profile option 'PO: Automatic Document Sourcing',
              this procedure calls get_document_from_asl OR get_latest_document.

   <PKGCOMP R12 Start>
   * Modifying the parameter x_asl_id from IN to IN OUT parameter in order to
     communicate the ASL_ID back to PO_AUTOSOURCE_SV.autosourcing or
     PO_AUTOSOURCE_SV.reqimport_sourcing.

   * We need not make any changes to the existing code of this procedure,
     as we just make calls to Get_document_from_asl or Get_latest_document
     procedure depending on the value of 'PO: Automatic Document Sourcing'
     profile option.
   <PKGCOMP R12 End>
===========================================================================*/
PROCEDURE document_sourcing(
	x_item_id		IN 	NUMBER,
	x_vendor_id		IN 	NUMBER,
	x_destination_doc_type	IN	VARCHAR2,
	x_organization_id	IN	NUMBER,
	x_currency_code		IN	VARCHAR2,
        x_item_rev		IN	VARCHAR2,
	x_autosource_date	IN	DATE,
	x_vendor_site_id	IN OUT NOCOPY  NUMBER,
	x_document_header_id	IN OUT NOCOPY  NUMBER,
	x_document_type_code	IN OUT NOCOPY  VARCHAR2,
	x_document_line_num	IN OUT NOCOPY  NUMBER,
	x_document_line_id	IN OUT	NOCOPY NUMBER,
	x_vendor_contact_id	IN OUT NOCOPY  NUMBER,
	x_vendor_product_num	IN OUT	NOCOPY VARCHAR2,
	x_buyer_id		IN OUT NOCOPY  NUMBER,
	x_purchasing_uom	IN OUT NOCOPY  VARCHAR2,
	x_asl_id                IN OUT NOCOPY NUMBER, --<PKGCOMP R12> --cto FPH
        x_multi_org             IN      VARCHAR2 default 'N', --cto FPH
        p_vendor_site_sourcing_flag  IN VARCHAR2 default 'N', --<Shared Proc FPJ>
 	p_vendor_site_code   	 IN  	VARCHAR2 default NULL, --<Shared Proc FPJ>
        p_category_id            IN     NUMBER --<Contract AutoSourcing FPJ>
        --<R12 STYLES PHASE II START>
       ,p_purchase_basis   IN VARCHAR2 DEFAULT NULL,
        p_line_type_id     IN VARCHAR2 DEFAULT NULL,
        p_destination_type IN VARCHAR2 DEFAULT NULL,
        p_style_id         IN NUMBER   DEFAULT NULL
        --<R12 STYLES PHASE II END>
) IS
	x_local_asl_id		NUMBER; --cto FPH
	x_org_id		NUMBER; --cto FPH
	x_using_organization_id NUMBER;
	l_progress		VARCHAR2(3) := '000';
	x_sourcing_date		DATE := trunc(nvl(x_autosource_date, sysdate));
    x_auto_source_doc       VARCHAR2(1);
    x_asl_purchasing_uom    VARCHAR2(25);
    x_item_rev_control      NUMBER := 1;
    x_source_doc_not_found  VARCHAR2(1) := 'N';  -- Bug 2373004
    x_ga_flag               VARCHAR2(1) := 'N';    -- FPI GA
    x_owning_org_id         NUMBER;                -- FPI GA
    x_valid_flag            VARCHAR2(1) := 'N';
    --<Shared Proc FPJ START>
    x_vendor_contact_name  	PO_VENDOR_CONTACTS.last_name%TYPE;
    l_sequence_number  	PO_ASL_DOCUMENTS.sequence_num%TYPE;
    l_vendor_site_sourcing_flag VARCHAR2(1) := p_vendor_site_sourcing_flag;
    l_log_head     CONSTANT VARCHAR2(100) := g_log_head||'document_sourcing';
    --<Shared Proc FPJ END>

    --<Contract AutoSourcing FPJ Start >
    -- In general, contracts can be sourced too; if the destination doc is requisition,
    -- user-defined settings in document types form determines whether or not to
    -- source to contracts
    l_return_contract	VARCHAR2(1) := 'Y';
    l_return_status	VARCHAR2(1);
    --<Contract AutoSourcing FPJ End >

    l_vendor_contact_name varchar2(240); --<Bug 3692519>

BEGIN
    l_progress := '010';

    IF g_debug_stmt THEN
       PO_DEBUG.debug_begin(l_log_head);
       PO_DEBUG.debug_var(l_log_head,l_progress,'x_item_id', x_item_id);
       PO_DEBUG.debug_var(l_log_head,l_progress,'x_vendor_id', x_vendor_id);
       PO_DEBUG.debug_var(l_log_head,l_progress,'x_destination_doc_type', x_destination_doc_type);
       PO_DEBUG.debug_var(l_log_head,l_progress,'x_organization_id', x_organization_id);
       PO_DEBUG.debug_var(l_log_head,l_progress,'x_currency_code', x_currency_code);
       PO_DEBUG.debug_var(l_log_head,l_progress,'x_item_rev', x_item_rev);
       PO_DEBUG.debug_var(l_log_head,l_progress,'x_autosource_date', x_autosource_date);
       PO_DEBUG.debug_var(l_log_head,l_progress,'x_vendor_site_id', x_vendor_site_id);

       PO_DEBUG.debug_var(l_log_head,l_progress,'x_document_header_id', x_document_header_id);
       PO_DEBUG.debug_var(l_log_head,l_progress,'x_document_type_code', x_document_type_code);
       PO_DEBUG.debug_var(l_log_head,l_progress,'x_document_line_num', x_document_line_num);
       PO_DEBUG.debug_var(l_log_head,l_progress,'x_document_line_id', x_document_line_id);
       PO_DEBUG.debug_var(l_log_head,l_progress,'x_vendor_contact_id', x_vendor_contact_id);
       PO_DEBUG.debug_var(l_log_head,l_progress,'x_vendor_product_num', x_vendor_product_num);
       PO_DEBUG.debug_var(l_log_head,l_progress,'x_buyer_id', x_buyer_id);
       PO_DEBUG.debug_var(l_log_head,l_progress,'x_purchasing_uom', x_purchasing_uom);

       PO_DEBUG.debug_var(l_log_head,l_progress,'x_asl_id', x_asl_id);
       PO_DEBUG.debug_var(l_log_head,l_progress,'x_multi_org', x_multi_org);
       PO_DEBUG.debug_var(l_log_head,l_progress,'p_vendor_site_sourcing_flag', p_vendor_site_sourcing_flag);
       PO_DEBUG.debug_var(l_log_head,l_progress,'p_vendor_site_sourcing_flag', p_vendor_site_sourcing_flag);
       PO_DEBUG.debug_var(l_log_head,l_progress,'p_vendor_site_code', p_vendor_site_code);
       PO_DEBUG.debug_var(l_log_head,l_progress,'p_category_id', p_category_id);
       PO_DEBUG.debug_var(l_log_head,l_progress,'p_purchase_basis', p_purchase_basis);
       PO_DEBUG.debug_var(l_log_head,l_progress,'p_line_type_id', p_line_type_id);
       PO_DEBUG.debug_var(l_log_head,l_progress,'p_destination_type', p_destination_type);
       PO_DEBUG.debug_var(l_log_head,l_progress,'p_style_id', p_style_id);
    END IF;



    -- Check that x_item_id and x_vendor_id have values.
    --IF (x_item_id IS NULL OR x_vendor_id IS NULL) THEN

    -- <Contract AutoSourcing FPJ >
    -- Deleted the x_item_id IS NULL check. Enable sourcing without item_id if category_id exists;
    -- Also check if vendor_id has value
    IF (x_item_id IS NULL
          AND (p_category_id IS NULL OR x_destination_doc_type NOT IN ('REQ',
								    'REQ_NONCATALOG')))
       OR (x_vendor_id IS NULL) THEN
	return;

    END IF;

	/* Cto Changes FPH start */
        if (x_multi_org = 'Y') then
        	x_org_id := null;
	else
		select org_id
		into x_org_id
		from financials_system_parameters;
	end if;
        /* Cto Changes FPH end */

    IF x_organization_id IS NULL THEN

        -- Get organization_id from financials_system_parameters.

        SELECT   inventory_organization_id
        INTO     x_using_organization_id
        FROM     financials_system_parameters;

    ELSE
	x_using_organization_id := x_organization_id;
    END IF;

    l_progress := '020';

   /* bug 2315931 :   we now call autosource even if revision is null. null revision can
     be matched to a source document with a revision . For this - get the revision control
     code from the item table and pass it to the cursors C1,C_AUTO_SOURCE_DOC_WITH_UOM and
     C_AUTO_SOURCE_DOC_NO_UOM. These cursors will now tey to match the item revisions on the
     req line and the source document if both have values. If the item revision on the req
     line is not null and the item is not revision controlled the we match this line to the
     source doc line irrespective of its revision */
   begin

     SELECT   msi.revision_qty_control_code
     INTO     x_item_rev_control
     FROM     mtl_system_items msi
     WHERE    msi.inventory_item_id = x_item_id
     AND      msi.organization_id = x_using_organization_id;
  exception
   when no_data_found then
     x_item_rev_control := 1;
  end;

  l_progress := '030';
  IF l_vendor_site_sourcing_flag = 'Y' THEN
	--If requesting OU has encumbrance enabled or destination inv org is OPM enabled
	--then do not cross OU boundaries
    IF (PO_CORE_S.is_encumbrance_on
                      (p_doc_type => 'ANY',
                       p_org_id   => x_org_id))
       -- INVCONV START remove the opm restriction
       -- OR  PO_GML_DB_COMMON.check_process_org(x_using_organization_id) = 'Y')
       -- INVCONV END
    THEN
        l_progress := '040';
	    l_vendor_site_sourcing_flag := 'N';
	    --Do local document sourcing
	    IF p_vendor_site_code is NOT NULL
               AND x_vendor_site_id is NULL THEN

               IF g_debug_stmt THEN
                 PO_DEBUG.debug_stmt(l_log_head,l_progress,'Doing Local Doc Sourcing');
               END IF;

              BEGIN
               SELECT vendor_site_id
               INTO x_vendor_site_id
               FROM po_vendor_sites_all pvs,
                    org_organization_definitions oog
               WHERE pvs.vendor_site_code = p_vendor_site_code
               AND   pvs.vendor_id = x_vendor_id --<Bug 3634422>
               AND   nvl(pvs.org_id,nvl(oog.operating_unit,-1)) =
                                                      nvl(oog.operating_unit,-1)
               AND  oog.organization_id = x_using_organization_id;
              EXCEPTION
               WHEN OTHERS THEN
                   x_vendor_site_id := NULL;
              END;
	        END IF; --site code NULL check
    END IF; --encumbrance check
  END IF; --source flag check

  --<Contract AutoSourcing FPJ Start>
  -- Find out if contract agreements should be sourced to Requisition lines
  -- Currently, should_return_contract only supports Purchase Requisitions
  l_progress := '045';
  IF x_destination_doc_type IN ('REQ','REQ_NONCATALOG') THEN
     should_return_contract (
          p_destination_doc_type  => x_destination_doc_type,
          p_document_type_code	  => 'REQUISITION',
          p_document_subtype      => 'PURCHASE',
          x_return_contract       => l_return_contract,
          x_return_status         => l_return_status
     );
     IF l_return_status <> FND_API.g_ret_sts_success THEN
	RAISE FND_API.g_exc_unexpected_error;
     END IF;
  END IF;

  IF g_debug_stmt THEN
     PO_DEBUG.debug_stmt(p_log_head => l_log_head,
                         p_token    => l_progress,
                         p_message  => 'Return Contract? '||l_return_contract);
  END IF;
  --<Contract AutoSourcing FPJ End>

  l_progress := '050';
    --Do the check for the profile option 'PO: Automatic Document Sourcing'.
    --If set to 'Y' then get the latest document. If set to 'N' then get it from ASL.
    fnd_profile.get('PO_AUTO_SOURCE_DOC', x_auto_source_doc);
    IF nvl(x_auto_source_doc, 'N') = 'N' THEN
          l_progress := '060';
          IF g_debug_stmt THEN
            PO_DEBUG.debug_stmt(l_log_head,l_progress,'Looking at ASLs for Sourcing');
          END IF;

          Get_document_from_asl(
                x_item_id		            =>x_item_id,
                x_vendor_id		            =>x_vendor_id,
                x_destination_doc_type	    =>x_destination_doc_type,
                x_currency_code 	        =>x_currency_code,
                x_item_rev		            =>x_item_rev,
                x_autosource_date 	        =>x_autosource_date,
                x_vendor_site_id 	        =>x_vendor_site_id,
                x_document_header_id	    =>x_document_header_id,
                x_document_type_code 	    =>x_document_type_code,
                x_document_line_num	        =>x_document_line_num,
                x_document_line_id	        =>x_document_line_id,
                x_vendor_contact_id	        =>x_vendor_contact_id,
                x_vendor_product_num 	    =>x_vendor_product_num,
                x_buyer_id 		            =>x_buyer_id,
                x_purchasing_uom	        =>x_purchasing_uom,
                x_asl_id		            =>x_asl_id,
                x_multi_org		            =>x_multi_org,
                p_vendor_site_sourcing_flag	=>l_vendor_site_sourcing_flag,
                p_vendor_site_code	        =>p_vendor_site_code,
                p_org_id		            =>x_org_id,
                p_item_rev_control	        =>x_item_rev_control,
                p_using_organization_id     =>x_using_organization_id,
                p_category_id	          	=> p_category_id, --<Contract AutoSourcing FPJ>
	        p_return_contract		=> l_return_contract --<Contract AutoSourcing FPJ>
                --<R12 STYLES PHASE II START>
               ,p_purchase_basis   => p_purchase_basis,
                p_line_type_id     => p_line_type_id,
                p_destination_type => p_destination_type,
                p_style_id         => p_style_id
                --<R12 STYLES PHASE II END>
            );
            l_progress := '070';
     ELSE
           l_progress := '080';
           IF g_debug_stmt THEN
            PO_DEBUG.debug_stmt(l_log_head,l_progress,'Looking at Latest Documents for Sourcing');
           END IF;

           Get_latest_document(
                x_item_id		            =>x_item_id,
                x_vendor_id		            =>x_vendor_id,
                x_destination_doc_type	    =>x_destination_doc_type,
                x_currency_code 	        =>x_currency_code,
                x_item_rev		            =>x_item_rev,
                x_autosource_date 	        =>x_autosource_date,
                x_vendor_site_id 	        =>x_vendor_site_id,
                x_document_header_id	    =>x_document_header_id,
                x_document_type_code 	    =>x_document_type_code,
                x_document_line_num	        =>x_document_line_num,
                x_document_line_id	        =>x_document_line_id,
                x_vendor_contact_id	        =>x_vendor_contact_id,
                x_vendor_product_num 	    =>x_vendor_product_num,
                x_buyer_id 		            =>x_buyer_id,
                x_purchasing_uom	        =>x_purchasing_uom,
                x_asl_id		            =>x_asl_id,
                x_multi_org		            =>x_multi_org,
                p_vendor_site_sourcing_flag	=>l_vendor_site_sourcing_flag,
                p_vendor_site_code	        =>p_vendor_site_code,
                p_org_id		            =>x_org_id,
                p_item_rev_control	        =>x_item_rev_control,
                p_using_organization_id     =>x_using_organization_id,
                p_category_id	                => p_category_id, --<Contract AutoSourcing FPJ>
	        p_return_contract		=> l_return_contract --<Contract AutoSourcing FPJ>
                --<R12 STYLES PHASE II START>
               ,p_purchase_basis   => p_purchase_basis,
                p_line_type_id     => p_line_type_id,
                p_destination_type => p_destination_type,
                p_style_id         => p_style_id
                --<R12 STYLES PHASE II END>
          );
           l_progress := '090';
      END IF;
l_progress := '100';

      --<Bug 3564169, 3692519 mbhargav START>
      --Retain the vendor contact from Source Doc as long as
      --its valid otherwise redefault based on site
      IF x_vendor_site_id is NOT NULL THEN
           --If there is no vendor contact or contact is not valid
           --Then get the contact from site
           IF (x_vendor_contact_id is NULL OR
                     (NOT PO_VENDOR_CONTACTS_SV.val_vendor_contact(
                           p_vendor_contact_id => x_vendor_contact_id,
                           p_vendor_site_id => x_vendor_site_id))) THEN

                 PO_VENDOR_CONTACTS_SV.get_vendor_contact(
                        x_vendor_site_id => x_vendor_site_id,
                        x_vendor_contact_id => x_vendor_contact_id,
                        x_vendor_contact_name => l_vendor_contact_name);

           END IF;
      END IF;
      --<Bug 3564169, 3692519 mbhargav END>
l_progress := '110';

IF g_debug_stmt THEN
       PO_DEBUG.debug_end(l_log_head);
END IF;

EXCEPTION
    WHEN OTHERS THEN
         IF g_debug_unexp THEN
            PO_DEBUG.debug_exc(l_log_head,l_progress);
         END IF;

        PO_MESSAGE_S.SQL_ERROR('Document_sourcing', l_progress, sqlcode);
END document_sourcing;

--<Shared Proc FPJ START>
-------------------------------------------------------------------------------
--Start of Comments
--Name: GET_DOCUMENT_FROM_ASL
--Pre-reqs:
--  Assumes that ASL will be used for Document Sourcing
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  This procedure first identified an ASL to use and then gets the
--  document on ASL_DOCUMENTS which is suitable for use.
--Parameters:
--IN:
--x_item_id
--  item_id to be matched for ASL
--x_vendor_id
--  vendor_id to be matched for ASL
--x_destination_doc_type
--  The form from which the call to the API is made. Vaild values are
--  'PO', 'STANDARD PO', 'REQ', 'REQ_NONCATALOG' and NULL --<Contract AutoSourcing FPJ>
--x_curreny_code
--  Currency code to be compared to get matching document
--x_item_rev
--  Item revision that needs to be compared to.
--p_autosourcing_date
--  Date to be used for Sourcing date check
--p_item_rev_control
--  This parameter tells whether item revision control is ON for given p_item_id
--p_vendor_site_sourcing_flag
--  Parameter which tells whether site sourcing is done or not
--p_vendor_site_code
--  If vendor_site_sourcing_flag = 'Y' then this parameter contains the
--  site code for which the API needs to find appropriate site_id
--p_org_id
--  Operating Unit id
--x_multi_org
--  Parameter used by CTO
--IN OUT:
--x_vendor_product_num
--  Supplier product_num associated with given Item as defined on ASL
--x_purchasing_uom
--  Purchasing UOM provided by Supplier on ASL
--x_vendor_site_id
--  This parameter is used as IN OUT parameter. For callers who do not want
--  to do vendor site sourcing will pass in a value and set vendor_site_sourcing_flag
--  = 'N'. When vendor_site_sourcing_flag = 'Y' then this parameter would contain
--  the site_id obtained by vendor site sourcing
--x_document_header_id
--  The unique identifier of the document returned
--x_document_type_code
--  Valid values 'BLANKET'/'QUOTATION'
--x_document_line_num
--  The line number of the document returned
--x_document_line_id
--  The unique identifier of the document line returned
--x_vendor_contact_id
--  If there is a unique contact id present then this returns that value
--x_buyer_id
--  The buyer mentioned on the document returned
--x_asl_id
--  Parameter used by CTO and PKGCOMP R12 to pass asl_id so that no ASL sourcing is done
--Testing:
--  None
--End of Comments
-------------------------------------------------------------------------------
--<PKGCOMP R12 Start>
--* Modifying the parameter x_asl_id from IN to IN OUT parameter in order to
--  communicate the ASL_ID back to PO_AUTOSOURCE_SV.document_sourcing.

--* In the existing code of the procedure, we make a local copy of x_asl_id
--  (x_local_asl_id) and use it.

--* In order to minimize the impact of the type change of x_asl_id, we will
--  initialize the x_asl_id to value of x_local_asl_id just before exiting
--  the Get_document_from_asl procedure.
--<PKGCOMP R12 End>

Procedure get_document_from_asl(
                x_item_id             	  IN    NUMBER,
                x_vendor_id           	  IN	NUMBER,
                x_destination_doc_type 	  IN  	VARCHAR2,
                x_currency_code           IN    VARCHAR2,
                x_item_rev                IN	VARCHAR2,
                x_autosource_date         IN    DATE,
                x_vendor_site_id          IN OUT NOCOPY NUMBER,
                x_document_header_id      IN OUT NOCOPY NUMBER,
                x_document_type_code      IN OUT NOCOPY VARCHAR2,
                x_document_line_num       IN OUT NOCOPY NUMBER,
                x_document_line_id        IN OUT NOCOPY NUMBER,
                x_vendor_contact_id       IN OUT NOCOPY NUMBER,
                x_vendor_product_num      IN OUT NOCOPY VARCHAR2,
                x_buyer_id                IN OUT NOCOPY NUMBER,
                x_purchasing_uom          IN OUT NOCOPY VARCHAR2,
                x_asl_id                  IN OUT NOCOPY NUMBER,--<PKGCOMP R12>
                x_multi_org        	  IN    VARCHAR2,
	        p_vendor_site_sourcing_flag  IN VARCHAR2,
 	        p_vendor_site_code   	  IN  	VARCHAR2,
                p_org_id                  IN    NUMBER,
                p_item_rev_control        IN    NUMBER,
                p_using_organization_id   IN    NUMBER,
                p_category_id		  IN    NUMBER,  --<Contract AutoSourcing FPJ>
		p_return_contract	  IN	VARCHAR2 --<Contract AutoSourcing FPJ>
                --<R12 STYLES PHASE II START>
               ,p_purchase_basis   IN VARCHAR2 DEFAULT NULL,
                p_line_type_id     IN VARCHAR2 DEFAULT NULL,
                p_destination_type IN VARCHAR2 DEFAULT NULL,
                p_style_id         IN NUMBER DEFAULT NULL
                --<R12 STYLES PHASE II END>
) IS
    x_local_asl_id          	NUMBER; --cto FPH
    l_progress              	VARCHAR2(3) := '000';
    x_sourcing_date         	DATE := trunc(nvl(x_autosource_date, sysdate));
    x_auto_source_doc       	VARCHAR2(1);
    x_asl_purchasing_uom    	VARCHAR2(25);
    x_source_doc_not_found  	VARCHAR2(1) := 'N';  -- Bug 2373004
    l_sequence_number  		PO_ASL_DOCUMENTS.sequence_num%TYPE; --<Shared Proc FPJ>
    x_consigned_from_supplier_flag 	VARCHAR2(1);
    x_enable_vmi_flag 		    VARCHAR2(1);
    x_return_status			    VARCHAR2(1); --<Shared Proc FPJ>
    l_global_agreement_flag     PO_HEADERS_ALL.global_agreement_flag%type;
    l_document_org_id           PO_HEADERS_ALL.org_id%TYPE;
    l_using_organization_id     NUMBER;
    l_log_head     CONSTANT VARCHAR2(100) := g_log_head||'get_document_from_asl';

    -- Bug 3361128: this parameter stores the UOM on the source doc
    l_source_doc_purchasing_uom PO_LINES_ALL.unit_meas_lookup_code%TYPE;

    l_item_based_asl		VARCHAR2(1):= 'Y'; --<Contract AutoSourcing FPJ>
    l_item_id			NUMBER; --<Contract AutoSourcing FPJ>
    l_vendor_contact_name      PO_VENDOR_CONTACTS.last_name%TYPE; --Bug 3545698
    l_noncat_item BOOLEAN := FALSE; /* Bug#4263138 */


    --<R12 STYLES PHASE II START>
    l_eligible_doc_flag Boolean;
    l_return_status     VARCHAR2(1);
    l_msg_count         NUMBER;
    l_msg_data          VARCHAR2(2000);
    --<R12 STYLES PHASE II END>

    -- Cursor L_GET_DOCS_ON_ASL_CSR gets the documents in the asl entry that
    -- matches the currency code, item revision.
    -- If destination_doc_type = 'PO', it selects only from quotations.
    -- If destination_doc_type = 'REQ', it selects from both
    -- quotations and blankets.

  --Changed the name of cursor from C1 to L_GET_DOCS_ON_ASL_CSR
  --Changed the signature to take p_sequence_number as input parameter.
  --This parameter is used for specifying the sequence number of
  -- the document to look for on ASL documents
   /*Bug6982267    The end date of quotation lines were not considered while sourcing a document for a PO line
                   and when the source document was a quotation. Added code to consider the end date of
		   quotation line*/

       --bug10216412 The current line should be compared with the documents lines
       --to decide on raising the warning of an existing blanket and not header

  CURSOR L_GET_DOCS_ON_ASL_CSR(
 		p_sequence_number 	IN 	NUMBER) is
     SELECT   pad.document_header_id,
                       pad.document_line_id,
                       pol.line_num,
                       pad.document_type_code,
                       NVL (x_vendor_site_id, poh.vendor_site_id),
                       NVL (x_vendor_contact_id, poh.vendor_contact_id),
                       NVL (x_buyer_id, poh.agent_id),
         /* Bug 2348331 fixed. swapped the elements in the below
            nvl statement in order that the vendor_product_num at
            blanket line level takes precedence to that at ASL level.
         */
                        NVL (pol.vendor_product_num, x_vendor_product_num),
                        poh.global_agreement_flag,
                        poh.org_id,
                        -- Bug 3361128: also select the UOM on the doc
                        pol.unit_meas_lookup_code
    FROM po_asl_documents pad,
         po_approved_supplier_list pasl,
         po_headers_all poh, --CTO changes FPH
         po_lines_all pol --CTO changes FPH
   WHERE pasl.asl_id = x_local_asl_id
     AND pad.asl_id = pasl.asl_id
     AND pad.using_organization_id = l_using_organization_id --<Bug 3733077>
     AND pad.document_header_id = poh.po_header_id
     AND (x_document_line_id IS NULL OR x_document_line_id <> pol.po_line_id) -- Bug # 7454607 --bug10216412
     AND pol.po_line_id (+) = pad.document_line_id	-- <FPJ Advanced Price>
     AND (   x_destination_doc_type = 'REQ'
          OR x_destination_doc_type = 'REQ_NONCATALOG'  --<Contract AutoSourcing FPJ>
          OR x_destination_doc_type IS NULL
          --<Bug 2742147 mbhargav START>
          OR (x_destination_doc_type = 'STANDARD PO' and
                (poh.type_lookup_code = 'QUOTATION' OR
                (poh.type_lookup_code = 'BLANKET' AND nvl(poh.global_agreement_flag, 'N') = 'Y'))
             )
          --<Bug 2742147 mbhargav END>
          --for x_destination_doc_type = 'PO'
          OR poh.type_lookup_code = 'QUOTATION'
         )
      AND (   (    poh.type_lookup_code = 'QUOTATION'
              AND poh.status_lookup_code = 'A'
              AND (  NOT EXISTS (
                              SELECT 'no shipments exists'
                                FROM po_line_locations_all poll
                               WHERE poll.po_line_id = pol.po_line_id
			         ) --Bug7384016 added this condition to include quotations without price breaks

		    OR ( poh.approval_required_flag = 'N'
	              AND (EXISTS (SELECT  'valid'
		                   FROM po_line_locations_all poll
				   WHERE poll.po_line_id = pol.po_line_id
				   AND TRUNC (NVL (poll.end_date, x_sourcing_date)) >= --Bug6982267
                                           trunc(x_sourcing_date)
			           )
                           )
		      )
	    --Bug7384016 segregated the coditions for  approval_required_flag = Y/N
	           OR (poh.approval_required_flag = 'Y'
                       AND ( EXISTS (
                         SELECT 'quote is approved'
                           FROM po_quotation_approvals poqa,
                                po_line_locations_all poll --CTO changes FPH
                          WHERE poqa.approval_type IS NOT NULL
                            AND poqa.line_location_id = poll.line_location_id
                            AND poll.po_line_id = pol.po_line_id
			     AND TRUNC (NVL (poll.end_date, x_sourcing_date)) >= --Bug6982267
                                           trunc(x_sourcing_date)
			             )
		            )
			)


                )
            )
          OR (    poh.type_lookup_code = 'BLANKET'
              AND poh.approved_flag = 'Y'
              AND NVL (poh.closed_code, 'OPEN') NOT IN
                                                 ('FINALLY CLOSED', 'CLOSED')
              AND NVL (poh.cancel_flag, 'N') = 'N'
              AND NVL (poh.frozen_flag, 'N') = 'N'
              AND TRUNC (NVL (pol.expiration_date, x_sourcing_date)) >=
                                           trunc(x_sourcing_date) --Bug 2695699
	      --<BUG 5334351> following condition (1 line) was missed when it was rewritten in FPJ
	      AND NVL (pol.closed_code, 'OPEN') NOT IN ('FINALLY CLOSED', 'CLOSED')
              AND NVL (pol.cancel_flag, 'N') = 'N'
             )
        -- <FPJ Advanced Price START>
        OR ( poh.type_lookup_code = 'CONTRACT'
        	 AND (( NVL(FND_PROFILE.VALUE('ALLOW_REFERENCING_CPA_UNDER_AMENDMENT'),'N') =  'Y' --<R12 GCPA ER>
			 	and poh.approved_date is not null               --<FPJGCPA>
					)
			 		or nvl(poh.approved_flag,'N') = 'Y'
			 		)
            AND NVL(poh.cancel_flag,'N') = 'N'
            AND NVL(poh.frozen_flag,'N') = 'N'
            AND NVL(poh.closed_code, 'OPEN') = 'OPEN'
            AND p_return_contract = 'Y' --<Contract AutoSourcing FPJ>
           )
        -- <FPJ Advanced Price END>
         )
     AND (x_currency_code IS NULL OR poh.currency_code = x_currency_code)
     AND (p_sequence_number is NULL OR  --<Shared Proc FPJ>
               p_sequence_number = pad.sequence_num)
     AND x_sourcing_date >= NVL (poh.start_date, x_sourcing_date - 1)
     AND x_sourcing_date <= NVL (poh.end_date, x_sourcing_date + 1)
     -- <FPJ Advanced Price START>
     AND (poh.type_lookup_code = 'CONTRACT' OR
          (NVL(pol.item_revision, -1) = NVL(x_item_rev, -1) OR
           (NVL (p_item_rev_control, 1) = 1 AND x_item_rev IS NULL)))
     -- <FPJ Advanced Price END>
     --<Shared Proc FPJ START>
     --This clause returns rows if document is GA or
     --EITHER vendor_site_sourcing_flag  is N and site_ids match
     --OR vendor_site_sourcing_flag is Y and site codes match
     AND
         (
            (NVL (poh.global_agreement_flag, 'N') = 'Y')
          OR
            (    NVL (poh.global_agreement_flag, 'N') = 'N'
              AND (   (    p_vendor_site_sourcing_flag = 'N'
                       AND (x_vendor_site_id IS NULL OR
                            poh.vendor_site_id = x_vendor_site_id OR
			    poh.vendor_site_id IS NULL) --Bug #13743965
                      )
                   OR
                      (    p_vendor_site_sourcing_flag = 'Y'
                       AND (p_vendor_site_code IS NULL OR
                            poh.vendor_site_id =
                            	(select pvs.vendor_site_id
                              	 from po_vendor_sites pvs
                              	where pvs.vendor_site_code = p_vendor_site_code
                              	and   pvs.vendor_id = x_vendor_id))
                       )
                  )
             )
         )
     --<Shared Proc FPJ END>
     --If document is not a GA then the operating units should match
     --If document is GA and vendor site sourcing_flag is Y then
     --vendor_site_code for current org(as enabled org)  should match
     --If the document is GA and vendor site sourcing_flag is N then
     --current org should be enabled in GA
     --change is requird to do proper vendor sourcing
     AND (   (    NVL (poh.global_agreement_flag, 'N') = 'N'
              AND (x_multi_org = 'N')
              AND NVL (poh.org_id, -1) = NVL (p_org_id, -1)
             )
             --<Shared Proc FPJ START>
          OR ((       NVL (poh.global_agreement_flag, 'N') = 'Y'
                 AND (    p_vendor_site_sourcing_flag = 'Y'
                      AND (p_vendor_site_code IS NULL OR
                          EXISTS (
                             SELECT 'vendor site code matches'
                               FROM po_ga_org_assignments poga,
                                    po_vendor_sites_all pvsa
                              WHERE poh.po_header_id = poga.po_header_id
                                AND poga.organization_id = p_org_id
                                AND poga.vendor_site_id = decode( Nvl (poh.Enable_All_Sites,'N'),'N', pvsa.vendor_site_id ,poga.Vendor_Site_Id) -- <R12 GPCA>pvsa.vendor_site_id
                                AND pvsa.vendor_site_code = p_vendor_site_code
                                AND poga.enabled_flag = 'Y'
                                AND pvsa.vendor_id = x_vendor_id))
                     )
              )OR (    p_vendor_site_sourcing_flag = 'N'
                  --<Bug 3356349 mbhargav START>
                  AND EXISTS (
                             SELECT 'vendor site id matches'
                               FROM po_ga_org_assignments poga
                              WHERE poh.po_header_id = poga.po_header_id
                                AND poga.vendor_site_id = decode( Nvl (poh.Enable_All_Sites,'N'),'Y',poga.Vendor_Site_Id,x_vendor_site_id) --< R12 GCPA ER>
                                AND poga.enabled_flag = 'Y')
                  AND (x_destination_doc_type = 'STANDARD PO'
                       OR EXISTS (
                         SELECT 'enabled org exists'
                           FROM po_ga_org_assignments poga
                          WHERE poh.po_header_id = poga.po_header_id
                            AND poga.organization_id = p_org_id
                            AND poga.enabled_flag = 'Y'))
                  --<Bug 3356349 mbhargav END>
                 )
             )
             --<Shared Proc FPJ END>
          OR x_multi_org = 'Y'
         ) -- FPI GA
ORDER BY sequence_num ASC;

/* Bug#4263138 */
  /*
   * Non-Catalog items in this case refers to any item that does not have an
   * item_id reference - includes, iP Non-Catalog item, Punchout item, POs without
   * item reference. For all these cases, the autosourcing is always done only
   * to a Contract agreement. So the join to po_lines_all, check for blankets/quotes
   * are not needed in the sql. This makes the sql more optimized for these
   * onetime/non-catalog item.(Also  vendor_site_sourcing_flag is 'N')
   */

   --bug10216412 The condition is not needed here as we return only contracts in this
   --query and contracts have no lines

  CURSOR L_GET_DOCS_ON_ASL_NONCAT_CSR(
 		p_sequence_number 	IN 	NUMBER) is
     SELECT   pad.document_header_id,
                       pad.document_line_id,
                       NULL line_num, -- Only Contracts are returned
                       pad.document_type_code,
                       NVL (x_vendor_site_id, poh.vendor_site_id),
                       NVL (x_vendor_contact_id, poh.vendor_contact_id),
                       NVL (x_buyer_id, poh.agent_id),
                        x_vendor_product_num,
                        poh.global_agreement_flag,
                        poh.org_id,
                        NULL unit_meas_lookup_code
    FROM po_asl_documents pad,
         po_approved_supplier_list pasl,
         po_headers_all poh --CTO changes FPH
   WHERE pasl.asl_id = x_local_asl_id
     AND pad.asl_id = pasl.asl_id
     AND pad.using_organization_id = l_using_organization_id --<Bug 3733077>
     AND pad.document_header_id = poh.po_header_id
     AND (   x_destination_doc_type = 'REQ'
          OR x_destination_doc_type = 'REQ_NONCATALOG'  --<Contract AutoSourcing FPJ>
          OR x_destination_doc_type IS NULL
         )
     AND (
        -- <FPJ Advanced Price START>
            poh.type_lookup_code = 'CONTRACT'
        	 AND (( NVL(FND_PROFILE.VALUE('ALLOW_REFERENCING_CPA_UNDER_AMENDMENT'),'N') =  'Y' --<R12 GCPA ER>
			 		and poh.approved_date is not null)
			 		OR
			 		nvl(poh.approved_flag,'N') = 'Y'
			 		)
            AND NVL(poh.cancel_flag,'N') = 'N'
            AND NVL(poh.frozen_flag,'N') = 'N'
            AND NVL(poh.closed_code, 'OPEN') = 'OPEN'
            AND p_return_contract = 'Y' --<Contract AutoSourcing FPJ>
        -- <FPJ Advanced Price END>
         )
     AND (x_currency_code IS NULL OR poh.currency_code = x_currency_code)
     AND (p_sequence_number is NULL OR  --<Shared Proc FPJ>
               p_sequence_number = pad.sequence_num)
     AND x_sourcing_date >= NVL (poh.start_date, x_sourcing_date - 1)
     AND x_sourcing_date <= NVL (poh.end_date, x_sourcing_date + 1)
     -- <FPJ Advanced Price START>
     AND poh.type_lookup_code = 'CONTRACT'
     -- <FPJ Advanced Price END>
     --<Shared Proc FPJ START>
     --This clause returns rows if document is GA or
     --EITHER vendor_site_sourcing_flag  is N and site_ids match
     --OR vendor_site_sourcing_flag is Y and site codes match
     AND
         (
            (NVL (poh.global_agreement_flag, 'N') = 'Y')
          OR
            (    NVL (poh.global_agreement_flag, 'N') = 'N'
              AND (    p_vendor_site_sourcing_flag = 'N'
                       AND (x_vendor_site_id IS NULL OR
                            poh.vendor_site_id = x_vendor_site_id)
                   )
             )
         )
     --<Shared Proc FPJ END>
     --If document is not a GA then the operating units should match
     --If document is GA and vendor site sourcing_flag is Y then
     --vendor_site_code for current org(as enabled org)  should match
     --If the document is GA and vendor site sourcing_flag is N then
     --current org should be enabled in GA
     --change is requird to do proper vendor sourcing
     AND (   (    NVL (poh.global_agreement_flag, 'N') = 'N'
              AND (x_multi_org = 'N')
              AND NVL (poh.org_id, -1) = NVL (p_org_id, -1)
             )
             --<Shared Proc FPJ START>
          OR (  NVL (poh.global_agreement_flag, 'N') = 'Y'
            OR (    p_vendor_site_sourcing_flag = 'N'
                  --<Bug 3356349 mbhargav START>
                  AND
                  (
                    x_vendor_site_id is null
                    OR
                    EXISTS (
                             SELECT 'vendor site id matches'
                               FROM po_ga_org_assignments poga
                              WHERE poh.po_header_id = poga.po_header_id
                                AND poga.vendor_site_id = x_vendor_site_id
                                AND poga.enabled_flag = 'Y')
                  )
                  --<Bug 3356349 mbhargav END>
                 )
             )
             --<Shared Proc FPJ END>
          OR x_multi_org = 'Y'
         ) -- FPI GA
ORDER BY sequence_num ASC;

BEGIN

    l_progress := '010';
    l_using_organization_id  := p_using_organization_id;

      -- Fetch the local ASL entry if one exists; otherwise,
      -- fetch the global entry.

    /* CTO changes FPH. If x_asl_id is not null, then we could have obtained
     * from Get_All_Item_Asl procedure. This is the same as x_asl_id but returns
     * vendor_id also and in an array. When any changes are made to get_asl_info
     * need to consider Get_All_Item_Asl procedure also.
    */
    if (x_asl_id is null) then --cto FPH
	   IF p_vendor_site_sourcing_flag = 'N' THEN
            l_progress := '020';

            IF g_debug_stmt THEN
               PO_DEBUG.debug_stmt(l_log_head,l_progress,'Calling get_asl_info');
            END IF;
	     --This call does not require vendor site sourcing
            --so do existing call to get local_asl_id
            get_asl_info(x_item_id               => x_item_id,
                         x_vendor_id             => x_vendor_id,
	                 x_vendor_site_id        => x_vendor_site_id,
                         x_using_organization_id => l_using_organization_id,
                         x_asl_id                => x_local_asl_id,
                         x_vendor_product_num    => x_vendor_product_num,
                         x_purchasing_uom        => x_asl_purchasing_uom,
			 p_category_id           => p_category_id	--<Contract AutoSourcing FPJ>_item_id,
                         );

            IF g_debug_stmt THEN
               PO_DEBUG.debug_stmt(l_log_head,l_progress,'get_asl_info returned:');
               PO_DEBUG.debug_var(l_log_head,l_progress,'asl_id obtained', x_local_asl_id);
            END IF;

	   ELSE
            l_progress := '030';

            IF g_debug_stmt THEN
               PO_DEBUG.debug_stmt(l_log_head,l_progress,'Calling asl_sourcing');
            END IF;
            --This procedure does the sourcing of document based on ASL
            --This returns asl_id to use. Optionally it returns sequence_number
            --of GA to be used if the ASL is from different OU
            asl_sourcing(
                         p_item_id		=>x_item_id,
                         p_vendor_id		=>x_vendor_id,
	                 p_vendor_site_code	=>p_vendor_site_code,
                         p_item_rev		=>x_item_rev,
                         p_item_rev_control	=>p_item_rev_control,
                         p_sourcing_date	=>x_sourcing_date,
                         p_currency_code	=>x_currency_code,
                         p_org_id		=>p_org_id,
                         p_using_organization_id =>l_using_organization_id,
                         x_asl_id 		=>x_local_asl_id,
                         x_vendor_product_num 	=>x_vendor_product_num,
                         x_purchasing_uom 	=>x_asl_purchasing_uom,
 	                 x_consigned_from_supplier_flag =>x_consigned_from_supplier_flag,
 	                 x_enable_vmi_flag 	=>x_enable_vmi_flag,
                         x_sequence_num 	=>l_sequence_number,
                         p_category_id          => p_category_id --<Contract AutoSourcing FPJ>
                         );

              IF g_debug_stmt THEN
                 PO_DEBUG.debug_stmt(l_log_head,l_progress,'asl_sourcing returned:');
                 PO_DEBUG.debug_var(l_log_head,l_progress,'asl_id obtained', x_local_asl_id);
                 PO_DEBUG.debug_var(l_log_head,l_progress,'using organization is ', l_using_organization_id);
                 PO_DEBUG.debug_var(l_log_head,l_progress,'sequence num obtained', l_sequence_number);
              END IF;

              IF (x_local_asl_id IS NULL
                  AND trunc(x_sourcing_date) <> trunc(sysdate)) THEN

                  l_progress := '040';
                  IF g_debug_stmt THEN
                     PO_DEBUG.debug_stmt(l_log_head,l_progress,'Calling asl_sourcing with sysdate');
                  END IF;
                  --Call ASL_SOURCING again this time passing SYSDATE as SOURCING_DATE
                  x_sourcing_date := trunc(sysdate);
                  asl_sourcing(
                         p_item_id		=>x_item_id,
                         p_vendor_id		=>x_vendor_id,
	                 p_vendor_site_code	=>p_vendor_site_code,
                         p_item_rev		=>x_item_rev,
                         p_item_rev_control	=>p_item_rev_control,
                         p_sourcing_date	=>x_sourcing_date,
                         p_currency_code	=>x_currency_code,
                         p_org_id		=>p_org_id,
                         p_using_organization_id =>l_using_organization_id,
                         x_asl_id 		=>x_local_asl_id,
                         x_vendor_product_num 	=>x_vendor_product_num,
                         x_purchasing_uom 	=>x_asl_purchasing_uom,
 	                 x_consigned_from_supplier_flag =>x_consigned_from_supplier_flag,
 	                 x_enable_vmi_flag 	=>x_enable_vmi_flag,
                         x_sequence_num 	=>l_sequence_number,
                         p_category_id          => p_category_id --<Contract AutoSourcing FPJ>
                         );

                    IF g_debug_stmt THEN
                       PO_DEBUG.debug_stmt(l_log_head,l_progress,'asl_sourcing returned:');
                       PO_DEBUG.debug_var(l_log_head,l_progress,'asl_id obtained', x_local_asl_id);
                       PO_DEBUG.debug_var(l_log_head,l_progress,'using organization is ',
                                                                           l_using_organization_id);
                       PO_DEBUG.debug_var(l_log_head,l_progress,'sequence num obtained', l_sequence_number);
                    END IF;
               END IF;
       END IF;
    else
        x_local_asl_id := x_asl_id; --cto FPH
    end if; --cto FPH

    l_progress := '050';
    x_purchasing_uom := nvl(x_asl_purchasing_uom, x_purchasing_uom);

    IF x_local_asl_id IS NOT NULL THEN

       --<Contract AutoSourcing FPJ Start>
       BEGIN
         SELECT	item_id
         INTO	l_item_id
         FROM	po_approved_supplier_list
         WHERE	asl_id = x_local_asl_id;
       EXCEPTION
	 WHEN NO_DATA_FOUND THEN
           null;
       END;

       IF l_item_id IS NULL THEN
 	  l_item_based_asl := 'N';
       END IF;
       --<Contract AutoSourcing FPJ End>

       /* Bug#4263138 */
       if( (x_destination_doc_type = 'REQ' OR x_destination_doc_type = 'REQ_NONCATALOG')
             AND  x_item_id is null)
       then
         l_noncat_item := TRUE;
       else
         l_noncat_item := FALSE;
       end if;

       if (l_noncat_item) then
         OPEN L_GET_DOCS_ON_ASL_NONCAT_CSR(l_sequence_number);
       else
         OPEN L_GET_DOCS_ON_ASL_CSR(l_sequence_number);
       end if;

       -- Get the highest ranked document that matches the criteria.
       -- If document found, return.

       -- debug
       --dbms_output.put_line('destination doc ='|| x_destination_doc_type);
       --dbms_output.put_line('agent_id = '|| to_char(x_buyer_id));
       --dbms_output.put_line('currency_code = '|| x_currency_code);
       --dbms_output.put_line('item_rev = '|| x_item_rev);
       --dbms_output.put_line('sourcing_date = '|| to_char(x_sourcing_date));
       --dbms_output.put_line('org_id = '|| to_char(p_org_id));
       --dbms_output.put_line('item rev control = '|| to_char(p_item_rev_control));

       l_progress := '060';

       LOOP
         if (l_noncat_item) then
           FETCH L_GET_DOCS_ON_ASL_NONCAT_CSR into x_document_header_id,
                     x_document_line_id,
                     x_document_line_num,
                     x_document_type_code,
                     x_vendor_site_id,
                     x_vendor_contact_id,
                     x_buyer_id,
                     x_vendor_product_num,
                     l_global_agreement_flag,
                     l_document_org_id,
                     l_source_doc_purchasing_uom; -- Bug 3361128
            EXIT WHEN L_GET_DOCS_ON_ASL_NONCAT_CSR%NOTFOUND;
          else
           FETCH L_GET_DOCS_ON_ASL_CSR into x_document_header_id,
                     x_document_line_id,
                     x_document_line_num,
                     x_document_type_code,
                     x_vendor_site_id,
                     x_vendor_contact_id,
                     x_buyer_id,
                     x_vendor_product_num,
                     l_global_agreement_flag,
                     l_document_org_id,
                     l_source_doc_purchasing_uom; -- Bug 3361128
            EXIT WHEN L_GET_DOCS_ON_ASL_CSR%NOTFOUND;
          end if;


          /* FPI GA start */
          if x_document_header_id is not null then

          --<R12 STYLES PHASE II START>
          -- Validate whether the Sourced Docuemnt is Style Compatible
           IF g_debug_stmt THEN
              PO_DEBUG.debug_stmt(l_log_head,l_progress,'style validate source doc');
              PO_DEBUG.debug_var(l_log_head,l_progress,'x_destination_doc_type', x_destination_doc_type);
              PO_DEBUG.debug_var(l_log_head,l_progress,'x_document_type_code', x_document_type_code);
           END IF;

          l_eligible_doc_flag := TRUE;

	  --in case the sourcing is happening without passing any attributes as in pricing only mode
	  --check if all the attributes are NULL
	  --in such a case bypass the style validation checks
        if   p_line_type_id IS NULL
	     AND p_purchase_basis IS NULL
	     AND p_destination_type IS NULL
	     AND p_style_id IS NULL  then

              l_eligible_doc_flag := TRUE;
              IF g_debug_stmt THEN
                 PO_DEBUG.debug_stmt(l_log_head,l_progress,'bypass style validations');
              END IF;

       else --if attributes are passed then do style validation checks

               IF g_debug_stmt THEN
                 PO_DEBUG.debug_stmt(l_log_head,l_progress,'do style validations');
              END IF;

          if x_destination_doc_type IN ('REQ','REQ_NONCATALOG') then
            if (x_document_type_code IN ('BLANKET', 'CONTRACT')) then

                PO_DOC_STYLE_PVT.style_validate_req_attrs(p_api_version      => 1.0,
                                                          p_init_msg_list    => FND_API.G_TRUE,
                                                          x_return_status    => l_return_status,
                                                          x_msg_count        => l_msg_count,
                                                          x_msg_data         => l_msg_data,
                                                          p_doc_style_id     => null,
                                                          p_document_id      => x_document_header_id,
                                                          p_line_type_id     => p_line_type_id,
                                                          p_purchase_basis   => p_purchase_basis,
                                                          p_destination_type => p_destination_type,
                                                          p_source           => 'REQUISITION'
                                                          );

              if l_return_status <> FND_API.g_ret_sts_success THEN
                l_eligible_doc_flag := FALSE;
                 IF g_debug_stmt THEN
                    PO_DEBUG.debug_stmt(l_log_head,l_progress,'style validation failed');
                 END IF;
              end if;
            end if;

        else  -- x_destination_doc_type = 'STANDARD PO','PO' OR NULL

            If (p_style_id <>
               PO_DOC_STYLE_PVT.get_doc_style_id(x_document_header_id)) THEN
              l_eligible_doc_flag := FALSE;
            end if;

       end if; --if x_destination_doc_type IN ('REQ','REQ_NONCATALOG') then
     end if;  -- if   p_line_type_id IS NULL

       --<R12 STYLES PHASE II END>
       if l_eligible_doc_flag then   --<R12 STYLES PHASE II>
          IF g_debug_stmt THEN
             PO_DEBUG.debug_stmt(l_log_head,l_progress,'style validation passed 1');
          END IF;
             --<Contract AutoSourcing FPJ Start>
	     --For category-based ASL, the only valid document type is contract
	     IF l_item_based_asl = 'N' THEN
                IF x_document_type_code = 'CONTRACT' THEN
                   --<Bug 3545698 mbhargav START>
                   IF nvl(l_global_agreement_flag, 'N') = 'Y' THEN
                      IF p_vendor_site_sourcing_flag = 'Y' THEN
   	                     --Now get the supplier_site_id and vendor_contact_id
    	                 x_vendor_site_id :=
                               PO_GA_PVT.get_vendor_site_id(x_document_header_id);

   	                     IF x_vendor_contact_id is NULL then
    		                PO_VENDOR_CONTACTS_SV.get_vendor_contact(
                                          x_vendor_site_id 	=>x_vendor_site_id,
                                          x_vendor_contact_id 	=>x_vendor_contact_id,
                                          x_vendor_contact_name 	=>l_vendor_contact_name);
   	                     END IF;
                      END IF; --vendor_site_sourcing_flag check
                   END IF; --global flag check
                   IF g_debug_stmt THEN
                        PO_DEBUG.debug_stmt(l_log_head,l_progress,'Found a document from ASL:');
                        PO_DEBUG.debug_var(l_log_head,l_progress,'Total DOcuments looked at', L_GET_DOCS_ON_ASL_CSR%ROWCOUNT);
                        PO_DEBUG.debug_var(l_log_head,l_progress,'x_document_header_id', x_document_header_id);
                        PO_DEBUG.debug_var(l_log_head,l_progress,'x_document_line_id', x_document_line_id);
                        PO_DEBUG.debug_var(l_log_head,l_progress,'l_vendor_site_id', x_vendor_site_id);
                   END IF;
                   --<Bug 3545698 mbhargav END>
                   EXIT;
                END IF;	 --doc type checkc
	     ELSE

               GET_SITE_ID_IF_ITEM_ON_DOC_OK(
                   p_document_header_id        => x_document_header_id,
                   p_item_id                   => x_item_id,
                   p_vendor_site_sourcing_flag => p_vendor_site_sourcing_flag,
                   p_global_agreement_flag     => l_global_agreement_flag,
                   p_document_org_id           => l_document_org_id,
                   x_return_status             => x_return_status,
                   x_vendor_site_id            => x_vendor_site_id,
                   x_vendor_contact_id         => x_vendor_contact_id,
	           p_destination_doc_type      => x_destination_doc_type, --<Bug 3356349>
		   p_multi_org                 => x_multi_org --<CTO Bug 4222144>
					     );

              IF x_return_status = FND_API.G_RET_STS_SUCCESS then
                     l_progress := '070';
                     IF g_debug_stmt THEN
                        PO_DEBUG.debug_stmt(l_log_head,l_progress,'Found a document from ASL:');
                        PO_DEBUG.debug_var(l_log_head,l_progress,'Total DOcuments looked at', L_GET_DOCS_ON_ASL_CSR%ROWCOUNT);
                        PO_DEBUG.debug_var(l_log_head,l_progress,'x_document_header_id', x_document_header_id);
                        PO_DEBUG.debug_var(l_log_head,l_progress,'x_document_line_id', x_document_line_id);
                        PO_DEBUG.debug_var(l_log_head,l_progress,'l_vendor_site_id', x_vendor_site_id);
                     END IF;

                     exit;
               END IF;
             END IF; -- l_item_based_asl check

          end if; -- if l_eligible_doc_flag --<R12 STYLES PHASE II>

             /* Bug 2752091 : If the item is not valid in the current OU
                we null out the doc info that was already fetched so that
                it does not get returned to the form */
             x_document_header_id := null;
             x_document_line_id   := null;
             x_document_line_num  := null;
             x_document_type_code :=  null;
	     l_source_doc_purchasing_uom :=  null;   --<R12 STYLES PHASE II>

          else -- x_document_header_id is null
            exit;
          end if;-- x_document_header_id IS NOT NULL check
          --<Contract AutoSourcing FPJ End>

        END LOOP;
          /* FPI GA end */

       if (l_noncat_item) then
         CLOSE L_GET_DOCS_ON_ASL_NONCAT_CSR;
       else
         CLOSE L_GET_DOCS_ON_ASL_CSR;
       end if;


   /* bug 935944 : base - 918701 Cursor L_GET_DOCS_ON_ASL_CSR will return either one or no rows.
      If no rows were returned and x_sourcing_date is not equal to sysdate,
      then we will try again to fetch sourcing document info using sysdate */

        IF (x_document_header_id IS NULL AND trunc(x_sourcing_date) <> trunc(sysdate)) THEN

          x_sourcing_date := trunc(sysdate);
          l_progress := '080';

         /* Bug#4263138 */
         if (l_noncat_item) then
          OPEN L_GET_DOCS_ON_ASL_NONCAT_CSR(l_sequence_number);
         else
          OPEN L_GET_DOCS_ON_ASL_CSR(l_sequence_number);
         end if;

        LOOP
         if (l_noncat_item) then
          FETCH L_GET_DOCS_ON_ASL_NONCAT_CSR into x_document_header_id,
                        x_document_line_id,
                        x_document_line_num,
                        x_document_type_code,
                        x_vendor_site_id,
                        x_vendor_contact_id,
                        x_buyer_id,
                        x_vendor_product_num,
                        l_global_agreement_flag,
                        l_document_org_id,
                        l_source_doc_purchasing_uom; -- Bug 3361128
          EXIT WHEN L_GET_DOCS_ON_ASL_NONCAT_CSR%NOTFOUND;
         else
          FETCH L_GET_DOCS_ON_ASL_CSR into x_document_header_id,
                        x_document_line_id,
                        x_document_line_num,
                        x_document_type_code,
                        x_vendor_site_id,
                        x_vendor_contact_id,
                        x_buyer_id,
                        x_vendor_product_num,
                        l_global_agreement_flag,
                        l_document_org_id,
                        l_source_doc_purchasing_uom; -- Bug 3361128
          EXIT WHEN L_GET_DOCS_ON_ASL_CSR%NOTFOUND;
         end if;

          /* FPI GA start */
          if x_document_header_id is not null then

           --<R12 STYLES PHASE II START>
            -- Validate whether the Sourced Docuemnt is Style Compatible
           IF g_debug_stmt THEN
              PO_DEBUG.debug_stmt(l_log_head,l_progress,'style validate source doc');
              PO_DEBUG.debug_var(l_log_head,l_progress,'x_destination_doc_type', x_destination_doc_type);
              PO_DEBUG.debug_var(l_log_head,l_progress,'x_document_type_code', x_document_type_code);
           END IF;
            l_eligible_doc_flag := TRUE;

	  --in case the sourcing is happening without passing any attributes as in pricing only mode
	  --check if all the attributes are NULL
	  --in such a case bypass the style validation checks
        if   p_line_type_id IS NULL
	     AND p_purchase_basis IS NULL
	     AND p_destination_type IS NULL
	     AND p_style_id IS NULL  then

              l_eligible_doc_flag := TRUE;
              IF g_debug_stmt THEN
                 PO_DEBUG.debug_stmt(l_log_head,l_progress,'bypass style validations');
              END IF;

       else --if attributes are passed then do style validation checks

               IF g_debug_stmt THEN
                 PO_DEBUG.debug_stmt(l_log_head,l_progress,'do style validations');
              END IF;
         if x_destination_doc_type IN ('REQ','REQ_NONCATALOG') then
              if (x_document_type_code IN ('BLANKET', 'CONTRACT')) then
                PO_DOC_STYLE_PVT.style_validate_req_attrs(p_api_version      => 1.0,
                                                          p_init_msg_list    => FND_API.G_TRUE,
                                                          x_return_status    => l_return_status,
                                                          x_msg_count        => l_msg_count,
                                                          x_msg_data         => l_msg_data,
                                                          p_doc_style_id     => null,
                                                          p_document_id      => x_document_header_id,
                                                          p_line_type_id     => p_line_type_id,
                                                          p_purchase_basis   => p_purchase_basis,
                                                          p_destination_type => p_destination_type,
                                                          p_source           => 'REQUISITION'
                                                          );

                if l_return_status <> FND_API.g_ret_sts_success THEN
                   l_eligible_doc_flag := FALSE;
                   IF g_debug_stmt THEN
                      PO_DEBUG.debug_stmt(l_log_head,l_progress,'style validation failed');
                   END IF;
                end if;
              end if;

         else  -- x_destination_doc_type = 'STANDARD PO','PO' OR NULL

              If (p_style_id <>
                 PO_DOC_STYLE_PVT.get_doc_style_id(x_document_header_id)) THEN
                l_eligible_doc_flag := FALSE;
              end if;

         end if;
       end if;  -- if   p_line_type_id IS NULL
            --<R12 STYLES PHASE II END>

          if l_eligible_doc_flag then       --<R12 STYLES PHASE II>
             IF g_debug_stmt THEN
                PO_DEBUG.debug_stmt(l_log_head,l_progress,'style validation passed 2');
             END IF;
	     --<Contract AutoSourcing FPJ Start>
	     --For category-based ASL, the only valid document type is contract
	     IF l_item_based_asl = 'N' THEN
                IF x_document_type_code = 'CONTRACT' THEN
                   --<Bug 3545698 mbhargav START>
                   IF nvl(l_global_agreement_flag, 'N') = 'Y' THEN
                      IF p_vendor_site_sourcing_flag = 'Y' THEN
   	                     --Now get the supplier_site_id and vendor_contact_id
    	                 x_vendor_site_id :=
                               PO_GA_PVT.get_vendor_site_id(x_document_header_id);

   	                     IF x_vendor_contact_id is NULL then
    		                PO_VENDOR_CONTACTS_SV.get_vendor_contact(
                                          x_vendor_site_id 	=>x_vendor_site_id,
                                          x_vendor_contact_id 	=>x_vendor_contact_id,
                                          x_vendor_contact_name 	=>l_vendor_contact_name);
   	                     END IF;
                      END IF; --vendor_site_sourcing_flag check
                   END IF; --global flag check
                   IF g_debug_stmt THEN
                        PO_DEBUG.debug_stmt(l_log_head,l_progress,'Found a document from ASL:');
                        PO_DEBUG.debug_var(l_log_head,l_progress,'Total DOcuments looked at', L_GET_DOCS_ON_ASL_CSR%ROWCOUNT);
                        PO_DEBUG.debug_var(l_log_head,l_progress,'x_document_header_id', x_document_header_id);
                        PO_DEBUG.debug_var(l_log_head,l_progress,'x_document_line_id', x_document_line_id);
                        PO_DEBUG.debug_var(l_log_head,l_progress,'l_vendor_site_id', x_vendor_site_id);
                   END IF;
                   --<Bug 3545698 mbhargav END>
		           EXIT;
                END IF; --doc_type_code check
	     ELSE
               GET_SITE_ID_IF_ITEM_ON_DOC_OK(
                   p_document_header_id        => x_document_header_id,
                   p_item_id                   => x_item_id,
                   p_vendor_site_sourcing_flag => p_vendor_site_sourcing_flag,
                   p_global_agreement_flag     => l_global_agreement_flag,
                   p_document_org_id           => l_document_org_id,
                   x_return_status             => x_return_status,
                   x_vendor_site_id            => x_vendor_site_id,
                   x_vendor_contact_id         => x_vendor_contact_id,
	           p_destination_doc_type      => x_destination_doc_type, --<Bug 3356349>
		   p_multi_org                 => x_multi_org --<CTO Bug 4222144>
		);

               IF x_return_status = FND_API.G_RET_STS_SUCCESS then
                  l_progress := '090';
                  IF g_debug_stmt THEN
                     PO_DEBUG.debug_stmt(l_log_head,l_progress,'Found a document from ASL with sysdate:');
                     PO_DEBUG.debug_var(l_log_head,l_progress,'Total DOcuments looked at', L_GET_DOCS_ON_ASL_CSR%ROWCOUNT);
                     PO_DEBUG.debug_var(l_log_head,l_progress,'x_document_header_id', x_document_header_id);
                     PO_DEBUG.debug_var(l_log_head,l_progress,'x_document_line_id', x_document_line_id);
                     PO_DEBUG.debug_var(l_log_head,l_progress,'l_vendor_site_id', x_vendor_site_id);
                  END IF;
                  exit;
               END IF;
             END IF; -- l_item_based_asl check
            end if; -- if l_eligible_doc_flag --<R12 STYLES PHASE II>

             /* Bug 2752091 : If the item is not valid in the current OU
                we null out the doc info that was already fetched so that
                it does not get returned to the form */
             x_document_header_id := null;
             x_document_line_id   := null;
             x_document_line_num  := null;
             x_document_type_code :=  null;
	     l_source_doc_purchasing_uom :=  null;   --<R12 STYLES PHASE II>

          else -- x_document_header_id is null
            exit;
          end if; -- x_document_header_id IS NOT NULL check
          --<Contract AutoSourcing FPJ End>

        END LOOP;
        /* Bug#4263138 */
        if (l_noncat_item) then
          CLOSE L_GET_DOCS_ON_ASL_NONCAT_CSR;
        else
          CLOSE L_GET_DOCS_ON_ASL_CSR;
        end if;
        END IF;

      END IF;  --x_local_asl is NULL check

      -- Bug 3361128: pass back the UOM on the source doc (if any)
      x_purchasing_uom := nvl(l_source_doc_purchasing_uom, x_purchasing_uom);
      --<PKGCOMP R12 Start>
      -- Initialize the x_asl_id to value of x_local_asl_id just before exiting the
      -- Get_document_from_asl procedure.
        x_asl_id := x_local_asl_id;
      --<PKGCOMP R12 End>
             IF g_debug_stmt THEN
                 PO_DEBUG.debug_var(l_log_head,l_progress,'x_purchasing_uom', x_purchasing_uom);
             END IF;
      l_progress := '100';
EXCEPTION
    WHEN OTHERS THEN
        IF g_debug_unexp THEN
           PO_DEBUG.debug_exc(l_log_head,l_progress);
        END IF;

        PO_MESSAGE_S.SQL_ERROR('Get_Document_FROM_ASL', l_progress, sqlcode);
END get_document_from_asl;

--<Shared Proc FPJ START>
-------------------------------------------------------------------------------
--Start of Comments
--Name: GET_LATEST_DOCUMENT
--Pre-reqs:
--  Assumes that Profile PO: Automatic Document Sourcing profile is ON
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  This procedure gets the most recent document which can be used as Source
--  document fro given item, item_revision, destination inv org and need_by_date
--Parameters:
--IN:
--x_item_id
--  item_id to be matched for ASL
--x_vendor_id
--  vendor_id to be matched for ASL
--x_destination_doc_type
--  The form from which the call to the API is made. Vaild values are
--  'PO', 'STANDARD PO', 'REQ', 'REQ_NONCATALOG' and NULL --<Contract AutoSourcing FPJ>
--x_curreny_code
--  Currency code to be compared to get matching document
--x_item_rev
--  Item revision that needs to be compared to.
--p_autosourcing_date
--  Date to be used for Sourcing date check
--p_item_rev_control
--  This parameter tells whether item revision control is ON for given p_item_id
--p_vendor_site_sourcing_flag
--  Parameter which tells whether site sourcing is done or not
--p_vendor_site_code
--  If vendor_site_sourcing_flag = 'Y' then this parameter contains the
--  site code for which the API needs to find appropriate site_id
--p_org_id
--  Operating Unit id
--x_multi_org
--  Parameter used by CTO
--IN OUT:
--x_vendor_product_num
--  Supplier product_num associated with given Item as defined on ASL
--x_purchasing_uom
--  Purchasing UOM provided by Supplier on ASL
--x_vendor_site_id
--  This parameter is used as IN OUT parameter. For callers who do not want
--  to do vendor site sourcing will pass in a value and set vendor_site_sourcing_flag
--  = 'N'. When vendor_site_sourcing_flag = 'Y' then this parameter would contain
--  the site_id obtained by vendor site sourcing
--x_document_header_id
--  The unique identifier of the document returned
--x_document_type_code
--  Valid values 'BLANKET'/'QUOTATION'
--x_document_line_num
--  The line number of the document returned
--x_document_line_id
--  The unique identifier of the document line returned
--x_vendor_contact_id
--  If there is a unique contact id present then this returns that value
--x_buyer_id
--  The buyer mentioned on the document returned
--x_asl_id
--  Parameter used by CTO to pass asl_id so that no ASL sourcing is done
--Testing:
--  None
--End of Comments
-------------------------------------------------------------------------------
Procedure get_latest_document(
             x_item_id             	      IN    NUMBER,
             x_vendor_id           	      IN	NUMBER,
             x_destination_doc_type 	  IN  	VARCHAR2,
             x_currency_code              IN    VARCHAR2,
             x_item_rev                   IN	VARCHAR2,
             x_autosource_date            IN    DATE,
             x_vendor_site_id             IN OUT NOCOPY  NUMBER,
             x_document_header_id         IN OUT NOCOPY  NUMBER,
             x_document_type_code         IN OUT NOCOPY  VARCHAR2,
             x_document_line_num          IN OUT NOCOPY  NUMBER,
             x_document_line_id           IN OUT  NOCOPY NUMBER,
             x_vendor_contact_id          IN OUT NOCOPY  NUMBER,
             x_vendor_product_num         IN OUT  NOCOPY VARCHAR2,
             x_buyer_id                   IN OUT NOCOPY  NUMBER,
             x_purchasing_uom             IN OUT NOCOPY  VARCHAR2,
             x_asl_id                     IN OUT NOCOPY NUMBER,--<Bug#4936992>
             x_multi_org        	  IN    VARCHAR2,
             p_vendor_site_sourcing_flag  IN 	VARCHAR2,
 	     p_vendor_site_code   	  IN  	VARCHAR2 ,
             p_org_id                     IN    NUMBER,
             p_item_rev_control           IN    NUMBER,
             p_using_organization_id      IN    NUMBER,
             p_category_id		  IN    NUMBER,--<Contract AutoSourcing FPJ>
	     p_return_contract		  IN 	VARCHAR2 --<Contract AutoSourcing FPJ>
             --<R12 STYLES PHASE II START>
            ,p_purchase_basis   IN VARCHAR2 DEFAULT NULL,
             p_line_type_id     IN VARCHAR2 DEFAULT NULL,
             p_destination_type IN VARCHAR2 DEFAULT NULL,
             p_style_id         IN NUMBER DEFAULT NULL
             --<R12 STYLES PHASE II END>
) IS
        x_local_asl_id              NUMBER; --cto FPH
        l_progress                  VARCHAR2(3) := '000';
        x_sourcing_date             DATE := trunc(nvl(x_autosource_date, sysdate));
        x_auto_source_doc           VARCHAR2(1);
        x_asl_purchasing_uom        VARCHAR2(25);
        x_source_doc_not_found      VARCHAR2(1) := 'N';  -- Bug 2373004
        x_return_status	            VARCHAR2(1); --<Shared Proc FPJ>
        l_global_agreement_flag     PO_HEADERS_ALL.global_agreement_flag%TYPE;
        l_document_org_id           PO_HEADERS_ALL.org_id%TYPE;
        l_using_organization_id     NUMBER;
        l_log_head     CONSTANT VARCHAR2(100) := g_log_head||'get_latest_document';
        l_noncat_item BOOLEAN := FALSE; /* Bug#4263138 */

        -- Bug 3361128: this parameter stores the UOM on the source doc
        l_source_doc_purchasing_uom PO_LINES_ALL.unit_meas_lookup_code%TYPE;


    --<R12 STYLES PHASE II START>
    l_eligible_doc_flag Boolean;
    l_return_status     VARCHAR2(1);
    l_msg_count         NUMBER;
    l_msg_data          VARCHAR2(2000);
    --<R12 STYLES PHASE II END>

       --Bug5081434
       l_doc_type_fetch_order   NUMBER;
       l_uom_match  	        NUMBER;
       l_global_flag 	        VARCHAR2(1);
       l_creation_date          DATE;
	   l_expiration_date        DATE; --Bug141415177

       --Replaced two cursors AUTO_SOURCE_DOCS_WITH_UOM and
       --AUTO_SOURCE_DOCS_WITHOUT_UOM with L_GET_LATEST_DOCS_CSR
       --This is accomplished by taking purchasing_uom as input parameter.
       -- Bug 5074119
       -- Added an extra condition on type_lookup_code to improve the performance

       --bug10216412 The current line should be compared with the documents lines
       --to decide on raising the warning of an existing blanket and not header

     CURSOR L_GET_LATEST_DOCS_CSR(
 		       p_purchasing_uom 	IN 	VARCHAR2) is
SELECT   poh.po_header_id,
         pol.po_line_id,
         pol.line_num,
         poh.type_lookup_code,
         NVL (x_vendor_site_id, poh.vendor_site_id),
         NVL (x_vendor_contact_id, poh.vendor_contact_id),
         NVL (x_buyer_id, poh.agent_id),
         /* Bug 2348331 fixed. swapped the elements in the below
            nvl statement in order that the vendor_product_num at
            blanket line level takes precedence to that at ASL level.
         */
         NVL (pol.vendor_product_num, x_vendor_product_num),
         poh.global_agreement_flag,
         poh.org_id,
         -- Bug 3361128: also select the UOM on the doc
         pol.unit_meas_lookup_code,
         decode(poh.type_lookup_code, 'BLANKET', 1, 'QUOTATION', 2) DocTypeFetchOrder,
         decode(pol.unit_meas_lookup_code, p_purchasing_uom, 1,2) MatchUom,
         NVL (poh.global_agreement_flag, 'N') global_flag,
         poh.creation_date creation_date,
		 pol.expiration_date expiration_date --Bug14145177
    FROM po_headers_all poh, --CTO changes FPH
         po_lines_all pol --CTO changes FPH
   WHERE pol.po_header_id = poh.po_header_id	-- <FPJ Advanced Price> Bug5081434 No Outer Join
     AND (x_document_line_id IS NULL OR x_document_line_id <> pol.po_line_id) -- Bug # 7454607 --bug10216412
     AND (   x_destination_doc_type = 'REQ'
          OR x_destination_doc_type = 'REQ_NONCATALOG' --<Contract AutoSourcing FPJ>
          OR x_destination_doc_type IS NULL
          --<Bug 2742147 mbhargav START>
          OR (x_destination_doc_type = 'STANDARD PO' and
                (poh.type_lookup_code = 'QUOTATION' OR
                (poh.type_lookup_code = 'BLANKET' AND nvl(poh.global_agreement_flag, 'N') = 'Y'))
             )
          --<Bug 2742147 mbhargav END>
          --for x_dest_doc_type = 'PO'
          OR poh.type_lookup_code = 'QUOTATION'
         )
     AND (   (    poh.type_lookup_code = 'BLANKET'
              AND poh.approved_flag = 'Y'
              AND NVL (poh.cancel_flag, 'N') = 'N'
              AND NVL (poh.frozen_flag, 'N') = 'N'
              AND TRUNC (NVL (pol.expiration_date, x_sourcing_date)) >=
                                          trunc(x_sourcing_date) -- Bug 2695699
              AND
                  NVL (poh.user_hold_flag, 'N') = 'N'
              AND NVL (poh.closed_code, 'OPEN') NOT IN
                                                 ('FINALLY CLOSED', 'CLOSED')
              --Bug5258984 (following condition was missed when they rewrote this code for FPJ)
              AND NVL (pol.closed_code, 'OPEN') NOT IN
                                                  ('FINALLY CLOSED', 'CLOSED')
              AND NVL (pol.cancel_flag, 'N') = 'N'
             )
           OR (    poh.type_lookup_code = 'QUOTATION'
              AND (poh.status_lookup_code = 'A')
              AND (  NOT EXISTS (
                              SELECT 'no shipments exists'
                                FROM po_line_locations_all poll
                               WHERE poll.po_line_id = pol.po_line_id
			         )--Bug7384016 added this condition to include quotations without price breaks
	        OR (
	             (poh.approval_required_flag = 'Y')
                      AND (   EXISTS (
                           SELECT *
                           FROM po_quotation_approvals poqa,
                                po_line_locations_all poll --CTO changes FPH
                          WHERE poqa.approval_type IS NOT NULL
                            AND poqa.line_location_id = poll.line_location_id
                            AND poll.po_line_id = pol.po_line_id
			     AND TRUNC (NVL (poll.end_date, x_sourcing_date)) >=
                                          trunc(x_sourcing_date)
				     ) --Bug6982267
		           )
                     )
          OR     (
	           (poh.approval_required_flag = 'N')
	            AND ( EXISTS (
		            SELECT 'valid'
	                    FROM po_line_locations_all poll
			    WHERE poll.po_line_id = pol.po_line_id
			    AND TRUNC (NVL (poll.end_date, x_sourcing_date)) >=
                                          trunc(x_sourcing_date)
			         ) --Bug6982267
		         )
		  )

              )
	     )
	  )
     AND poh.vendor_id = x_vendor_id
     AND poh.type_lookup_code IN ('BLANKET','QUOTATION')
     --<Shared Proc FPJ START>
     --This clause returns rows if document is GA or
     --EITHER vendor_site_sourcing_flag  is N and site_ids match
     --OR vendor_site_sourcing_flag is Y and site codes match
     AND
         (
            (NVL (poh.global_agreement_flag, 'N') = 'Y')
          OR
            (    NVL (poh.global_agreement_flag, 'N') = 'N'
              AND (   (    p_vendor_site_sourcing_flag = 'N'
                       AND (x_vendor_site_id IS NULL OR
                            poh.vendor_site_id = x_vendor_site_id)
                      )
                   OR
                      (    p_vendor_site_sourcing_flag = 'Y'
                       AND (p_vendor_site_code IS NULL OR
                            poh.vendor_site_id =
                            	(select pvs.vendor_site_id
                              	 from po_vendor_sites pvs
                              	where pvs.vendor_site_code = p_vendor_site_code
                              	and   pvs.vendor_id = x_vendor_id))
                       )
                  )
             )
         )
     --<Shared Proc FPJ END>
     AND (x_currency_code IS NULL OR poh.currency_code = x_currency_code)
     AND x_sourcing_date >= NVL (poh.start_date, x_sourcing_date - 1)
     AND x_sourcing_date <= NVL (poh.end_date, x_sourcing_date + 1)
     -- <FPJ Advanced Price START>
     AND pol.item_id = x_item_id AND
         (NVL(pol.item_revision, -1) = NVL(x_item_rev, -1) OR
         (NVL (p_item_rev_control, 1) = 1 AND x_item_rev IS NULL))
    -- <FPJ Advanced Price END>
             --If document is not a GA then the operating units should match
             --If document is GA and vendor site sourcing_flag is Y then
             --vendor_site_code for current org(as enabled org)  should match
             --If the document is GA and vendor site sourcing_flag is N then
              --current org should be enabled in GA
     AND (   (    NVL (poh.global_agreement_flag, 'N') = 'N'
              AND (x_multi_org = 'N')
              AND poh.org_id = p_org_id
             )
          --<Shared Proc FPJ START>
          OR (    NVL (poh.global_agreement_flag, 'N') = 'Y'
              AND (   (    p_vendor_site_sourcing_flag = 'Y'
                       AND EXISTS (
                              SELECT 'vendor site code matches'
                                FROM po_ga_org_assignments poga,
                                     po_vendor_sites_all pvsa
                               WHERE poh.po_header_id = poga.po_header_id
                                 AND poga.organization_id = p_org_id
                                 AND poga.vendor_site_id = pvsa.vendor_site_id
                                 AND pvsa.vendor_site_code =
                                                            p_vendor_site_code
                                 AND poga.enabled_flag = 'Y'
                                 AND pvsa.vendor_id = x_vendor_id)
                      )
                   OR (    p_vendor_site_sourcing_flag = 'N'
                           --<Bug 3356349 mbhargav START>
                           AND
                           (
                             x_vendor_site_id is null
                             OR
                             EXISTS (
                                 SELECT 'vendor site id matches'
                                 FROM po_ga_org_assignments poga
                                 WHERE poh.po_header_id = poga.po_header_id
                                 AND poga.vendor_site_id = x_vendor_site_id
                                 AND poga.enabled_flag = 'Y')
                           )
                           AND (x_destination_doc_type = 'STANDARD PO'
                               OR EXISTS (
                                   SELECT 'enabled org exists'
                                   FROM po_ga_org_assignments poga
                                   WHERE poh.po_header_id = poga.po_header_id
                                   AND poga.organization_id = p_org_id
                                   AND poga.enabled_flag = 'Y'))
                           --<Bug 3356349 mbhargav END>
                      )
                  )
             )
          --<Shared Proc FPJ END>
          OR x_multi_org = 'Y'
         ) -- FPI GA
UNION ALL
SELECT   poh.po_header_id,
         to_number(NULL),
         to_number(NULL),
         poh.type_lookup_code,
         NVL (x_vendor_site_id, poh.vendor_site_id),
         NVL (x_vendor_contact_id, poh.vendor_contact_id),
         NVL (x_buyer_id, poh.agent_id),
         /* Bug 2348331 fixed. swapped the elements in the below
            nvl statement in order that the vendor_product_num at
            blanket line level takes precedence to that at ASL level.
         */
         x_vendor_product_num, --Bug5081434
         poh.global_agreement_flag,
         poh.org_id,
         -- Bug 3361128: also select the UOM on the doc
         to_char(NULL),  --Bug5081434
         3 DocTypeFetchOrder,
         2 MatchUom,
         NVL (poh.global_agreement_flag, 'N') global_flag,
         poh.creation_date creation_date,
		 NULL expiration_date      --Bug14145177
    FROM po_headers_all poh
   WHERE (   x_destination_doc_type = 'REQ'
          OR x_destination_doc_type = 'REQ_NONCATALOG' --<Contract AutoSourcing FPJ>
	  OR x_destination_doc_type = 'STANDARD PO' -- Added for 12625661
          OR x_destination_doc_type IS NULL
         )
    	 AND (( NVL(FND_PROFILE.VALUE('ALLOW_REFERENCING_CPA_UNDER_AMENDMENT'),'N') =  'Y' --<R12 GCPA ER>
		 		and poh.approved_date is not null)
		 		OR
		 		nvl(poh.approved_flag,'N') = 'Y'
		 		)
     AND NVL(poh.cancel_flag,'N') = 'N'
     AND NVL(poh.frozen_flag,'N') = 'N'
     AND NVL(poh.closed_code, 'OPEN') = 'OPEN'
     AND p_return_contract = 'Y'
     AND poh.vendor_id = x_vendor_id
     AND poh.type_lookup_code = 'CONTRACT'
     AND
         (
            (NVL (poh.global_agreement_flag, 'N') = 'Y')
          OR
            (    NVL (poh.global_agreement_flag, 'N') = 'N'
              AND (   (    p_vendor_site_sourcing_flag = 'N'
                       AND (x_vendor_site_id IS NULL OR
                            poh.vendor_site_id = x_vendor_site_id)
                      )
                   OR
                      (    p_vendor_site_sourcing_flag = 'Y'
                       AND (p_vendor_site_code IS NULL OR
                            poh.vendor_site_id =
                            	(select pvs.vendor_site_id
                              	 from po_vendor_sites pvs
                              	where pvs.vendor_site_code = p_vendor_site_code
                              	and   pvs.vendor_id = x_vendor_id))
                       )
                  )
             )
         )
     --<Shared Proc FPJ END>
     AND (x_currency_code IS NULL OR poh.currency_code = x_currency_code)
     AND x_sourcing_date >= NVL (poh.start_date, x_sourcing_date - 1)
     AND x_sourcing_date <= NVL (poh.end_date, x_sourcing_date + 1)

     AND (   (    NVL (poh.global_agreement_flag, 'N') = 'N'
              AND (x_multi_org = 'N')
              AND poh.org_id = p_org_id
             )
          --<Shared Proc FPJ START>
          OR (    NVL (poh.global_agreement_flag, 'N') = 'Y'
              AND (   (    p_vendor_site_sourcing_flag = 'Y'
                       AND (p_vendor_site_code IS NULL OR
                           EXISTS (
                              SELECT 'vendor site code matches'
                                FROM po_ga_org_assignments poga,
                                     po_vendor_sites_all pvsa
                               WHERE poh.po_header_id = poga.po_header_id
                                 AND poga.organization_id = p_org_id
                                 AND poga.vendor_site_id = Decode( Nvl (poh.Enable_All_Sites,'N'),'N',pvsa.vendor_site_id,poga.Vendor_Site_Id) --<FPJGCPA> pvsa.vendor_site_id
                                 AND pvsa.vendor_site_code =
                                                            p_vendor_site_code
                                 AND poga.enabled_flag = 'Y'
                                 AND pvsa.vendor_id = x_vendor_id))
                      )
                   OR (    p_vendor_site_sourcing_flag = 'N'
                           --<Bug 3356349 mbhargav START>
                           AND
                           (
                             x_vendor_site_id is null
                             OR
                             EXISTS (
                                 SELECT 'vendor site id matches'
                                 FROM po_ga_org_assignments poga
                                 WHERE poh.po_header_id = poga.po_header_id
                                 AND poga.vendor_site_id = decode( Nvl (poh.Enable_All_Sites,'N'),'Y',poga.Vendor_Site_Id,x_vendor_site_id) --< R12 GCPA ER>
                                 AND poga.enabled_flag = 'Y')
                           )
                           AND (x_destination_doc_type = 'STANDARD PO'
                               OR EXISTS (
                                   SELECT 'enabled org exists'
                                   FROM po_ga_org_assignments poga
                                   WHERE poh.po_header_id = poga.po_header_id
                                   AND poga.organization_id = p_org_id
                                   AND poga.enabled_flag = 'Y'))
                           --<Bug 3356349 mbhargav END>
                      )
                  )
             )
          --<Shared Proc FPJ END>
          OR x_multi_org = 'Y'
         )  -- FPI GA
ORDER BY
         DocTypeFetchOrder Asc,
         MatchUom Asc,
         global_flag Asc,
         creation_date DESC,
		 expiration_date Asc;

/* Bug#4263138 */
    /*
     * Non-Catalog items in this case refers to any item that does not have an
     * item_id reference - includes, iP Non-Catalog item, Punchout item, POs without
     * item reference. For all these cases, the autosourcing is always done only
     * to a Contract agreement. So the join to po_lines_all, check for blankets/quotes
     * are not needed in the sql. This makes the sql more optimized for these
     * onetime/non-catalog item.(Also  vendor_site_sourcing_flag is 'N')
     */
     -- Bug 5074119
     -- Added an extra condition on type_lookup_code to improve the performance
     CURSOR L_GET_LATEST_DOCS_NONCAT_CSR(
 		       p_purchasing_uom 	IN 	VARCHAR2) is
     SELECT   poh.po_header_id,
         NULL po_line_id,
         NULL line_num, -- Only Contracts are returned
         poh.type_lookup_code,
         NVL (x_vendor_site_id, poh.vendor_site_id),
         NVL (x_vendor_contact_id, poh.vendor_contact_id),
         NVL (x_buyer_id, poh.agent_id),
         /* Bug 2348331 fixed. swapped the elements in the below
            nvl statement in order that the vendor_product_num at
            blanket line level takes precedence to that at ASL level.
         */
         x_vendor_product_num,
         poh.global_agreement_flag,
         poh.org_id,
         NULL unit_meas_lookup_code
    FROM po_headers_all poh --CTO changes FPH
   WHERE
     (   x_destination_doc_type = 'REQ'
          OR x_destination_doc_type = 'REQ_NONCATALOG' --<Contract AutoSourcing FPJ>
	  OR x_destination_doc_type = 'STANDARD PO' -- Added for 12625661
          OR x_destination_doc_type IS NULL
          --<Bug 2742147 mbhargav START>
     )
     AND (
            (    poh.type_lookup_code = 'CONTRACT'
        	 AND (( NVL(FND_PROFILE.VALUE('ALLOW_REFERENCING_CPA_UNDER_AMENDMENT'),'N') =  'Y' --<R12 GCPA ER>
			 		and poh.approved_date is not null)
			 		OR
			 		nvl(poh.approved_flag,'N') = 'Y'
			 		)
              AND NVL(poh.cancel_flag,'N') = 'N'
              AND NVL(poh.frozen_flag,'N') = 'N'
              AND NVL(poh.closed_code, 'OPEN') = 'OPEN'
              AND p_return_contract = 'Y'	--<Contract AutoSourcing FPJ>
             )
         )
     AND poh.vendor_id = x_vendor_id
     --<Shared Proc FPJ START>
     --This clause returns rows if document is GA or
     --EITHER vendor_site_sourcing_flag  is N and site_ids match
     --OR vendor_site_sourcing_flag is Y and site codes match
     AND
         (
            (NVL (poh.global_agreement_flag, 'N') = 'Y')
          OR
            (    NVL (poh.global_agreement_flag, 'N') = 'N'
              AND (   (    p_vendor_site_sourcing_flag = 'N'
                       AND (x_vendor_site_id IS NULL OR
                            poh.vendor_site_id = x_vendor_site_id)
                      )
                  )
             )
         )
     --<Shared Proc FPJ END>
     AND (x_currency_code IS NULL OR poh.currency_code = x_currency_code)
     AND x_sourcing_date >= NVL (poh.start_date, x_sourcing_date - 1)
     AND x_sourcing_date <= NVL (poh.end_date, x_sourcing_date + 1)
             --If document is not a GA then the operating units should match
             --If document is GA and vendor site sourcing_flag is Y then
             --vendor_site_code for current org(as enabled org)  should match
             --If the document is GA and vendor site sourcing_flag is N then
              --current org should be enabled in GA
     AND (   (    NVL (poh.global_agreement_flag, 'N') = 'N'
              AND (x_multi_org = 'N')
              AND NVL (poh.org_id, -1) = NVL (p_org_id, -1)
             )
          --<Shared Proc FPJ START>
          OR (    NVL (poh.global_agreement_flag, 'N') = 'Y'
              AND (
                   (    p_vendor_site_sourcing_flag = 'N'
                           --<Bug 3356349 mbhargav START>
                           AND
                           (
                             x_vendor_site_id is null
                             OR
                             EXISTS (
                                 SELECT 'vendor site id matches'
                                 FROM po_ga_org_assignments poga
                                 WHERE poh.po_header_id = poga.po_header_id
                                 AND poga.vendor_site_id = decode( Nvl (poh.Enable_All_Sites,'N'),'Y',poga.Vendor_Site_Id,x_vendor_site_id) --< R12 GCPA ER>
                                 AND poga.enabled_flag = 'Y')
                           )
                           --<Bug 3356349 mbhargav END>
                      )
                  )
             )
          --<Shared Proc FPJ END>
          OR x_multi_org = 'Y'
         ) -- FPI GA
ORDER BY
         -- <FPJ Advanced Price START>
         decode(poh.type_lookup_code, 'BLANKET', 1, 'QUOTATION', 2, 'CONTRACT', 3) ASC,
         -- <FPJ Advanced Price END>
         NVL (poh.global_agreement_flag, 'N') ASC,
         poh.creation_date DESC;           -- Bug# 1560250

  --<Bug#4936992 Start>
  --Created dummy variables so that when we call the asl_sourcing procedure, we can ignore the
  --values returned by the procedure. We are interested only in asl_id and do not want the
  --source document related info.
  l_dummy_cons_from_sup_flag    PO_ASL_ATTRIBUTES.consigned_from_supplier_flag%type := NULL;
  l_dummy_enable_vmi_flag       PO_ASL_ATTRIBUTES.enable_vmi_flag%type := NULL;
  l_dummy_sequence_number       PO_ASL_DOCUMENTS.sequence_num%type := NULL;
  l_dummy_vendor_product_num    PO_REQUISITIONS_INTERFACE_ALL.suggested_vendor_item_num%type := x_vendor_product_num;
  l_dummy_asl_purchasing_uom    PO_REQUISITIONS_INTERFACE_ALL.unit_of_measure%type := x_purchasing_uom;
  l_dummy_category_id           PO_REQUISITIONS_INTERFACE_ALL.category_id%type := p_category_id;
  l_dummy_using_organization_id FINANCIALS_SYSTEM_PARAMS_ALL.inventory_organization_id%type := p_using_organization_id;
  --<Bug#4936992 End>
BEGIN

    l_progress := '010';
    l_using_organization_id  := p_using_organization_id;
    IF g_debug_stmt THEN
      PO_DEBUG.debug_var(l_log_head,l_progress,'g_root_invoking_module', g_root_invoking_module);
    END IF;

    IF p_vendor_site_sourcing_flag = 'N' THEN

            l_progress := '011';
            get_asl_info(
                         x_item_id 		=>x_item_id,
                         x_vendor_id		=>x_vendor_id,
	                  x_vendor_site_id 	=>x_vendor_site_id,
                         x_using_organization_id=>l_using_organization_id,
                         x_asl_id 		=>x_local_asl_id,
                         x_vendor_product_num 	=>x_vendor_product_num,
                         x_purchasing_uom   	=>x_asl_purchasing_uom,
                         p_category_id          =>p_category_id  --<Contract AutoSourcing FPJ>
            );

            l_progress := '012';
            IF g_debug_stmt THEN
               PO_DEBUG.debug_stmt(l_log_head,l_progress,'get_asl_info returned:');
               PO_DEBUG.debug_var(l_log_head,l_progress,'asl_id obtained', x_local_asl_id);
            END IF;

           --Changed the order here. Giving preference to UOM passed in
           --over the ASL UOM as the profile says not to look at ASLs

           -- Bug 3361128: the above comment is not correct. The ASL UOM
           -- (if there's any) has the precedence over the UOM passed in.
           -- Did not change the assignment here, because it will be used
           -- in the cursor below to order source docs. Assign the UOM
           -- value to be passed back later in the procedure
	   x_purchasing_uom := nvl(x_purchasing_uom, x_asl_purchasing_uom);

     --<Bug#4936992 Start>
     -- We need the asl_id even when the PO: Automatic Document Sourcing is set to Y
     -- only when we are calling the sourcing logic from Req Import. The reasoning
     -- behind the above rule is that irrespective of the above mentioned profile
     -- option, we want to get the Order Modifiers from the ASL.
    ELSIF g_root_invoking_module = 'REQIMPORT' THEN

           l_progress := '013';
           --This procedure does the sourcing of document based on ASL
           --This returns asl_id to use. But we ignore all the sourcing
           --document related info and just consider asl id.
           asl_sourcing(
                        p_item_id           => x_item_id,
                        p_vendor_id         => x_vendor_id,
                        p_vendor_site_code  => p_vendor_site_code,
                        p_item_rev          => x_item_rev,
                        p_item_rev_control  => p_item_rev_control,
                        p_sourcing_date     => x_sourcing_date,
                        p_currency_code     => x_currency_code,
                        p_org_id            => p_org_id,
                        p_using_organization_id => l_dummy_using_organization_id,
                        x_asl_id             =>  x_local_asl_id,
                        x_vendor_product_num => l_dummy_vendor_product_num,
                        x_purchasing_uom     => l_dummy_asl_purchasing_uom,
                        x_consigned_from_supplier_flag =>l_dummy_cons_from_sup_flag,
                        x_enable_vmi_flag      => l_dummy_enable_vmi_flag,
                        x_sequence_num         => l_dummy_sequence_number,
                        p_category_id          => l_dummy_category_id);

           l_progress := '014';
           IF g_debug_stmt THEN
              PO_DEBUG.debug_stmt(l_log_head,l_progress,'asl_sourcing returned:');
              PO_DEBUG.debug_var(l_log_head,l_progress,'asl_id obtained', x_local_asl_id);
           END IF;
           IF (x_local_asl_id IS NULL
               AND trunc(x_sourcing_date) <> trunc(sysdate)) THEN

               --Call ASL_SOURCING again this time passing SYSDATE as SOURCING_DATE
               l_progress := '015';
               x_sourcing_date := trunc(sysdate);
               asl_sourcing(
                            p_item_id           => x_item_id,
                            p_vendor_id         => x_vendor_id,
                            p_vendor_site_code  => p_vendor_site_code,
                            p_item_rev          => x_item_rev,
                            p_item_rev_control  => p_item_rev_control,
                            p_sourcing_date     => x_sourcing_date,
                            p_currency_code     => x_currency_code,
                            p_org_id            => p_org_id,
                            p_using_organization_id => l_dummy_using_organization_id,
                            x_asl_id             =>  x_local_asl_id,
                            x_vendor_product_num => l_dummy_vendor_product_num,
                            x_purchasing_uom     => l_dummy_asl_purchasing_uom,
                            x_consigned_from_supplier_flag =>l_dummy_cons_from_sup_flag,
                            x_enable_vmi_flag      => l_dummy_enable_vmi_flag,
                            x_sequence_num         => l_dummy_sequence_number,
                            p_category_id          => l_dummy_category_id);

               l_progress := '016';
               IF g_debug_stmt THEN
                 PO_DEBUG.debug_stmt(l_log_head,l_progress,'asl_sourcing with passing SYSDATE as SOURCING_DATE returned:');
                 PO_DEBUG.debug_var(l_log_head,l_progress,'asl_id obtained', x_local_asl_id);
               END IF;

            END IF;
    --<Bug#4936992 End>
    END IF;
    --<Bug#4936992 Start>
    l_progress := '017';
    IF g_root_invoking_module = 'REQIMPORT' THEN
      x_asl_id := x_local_asl_id;
    END IF;
    IF g_debug_stmt THEN
       PO_DEBUG.debug_var(l_log_head,l_progress,'asl_id being returned', x_asl_id);
    END IF;

    --<Bug#4936992 End>

        l_progress := '020';

      /* Bug#4263138 */
      if( (x_destination_doc_type = 'REQ' OR x_destination_doc_type = 'REQ_NONCATALOG')
            AND  x_item_id is null) then
        l_noncat_item := TRUE;
      else
        l_noncat_item := FALSE;
      end if;

      if (l_noncat_item) then
        OPEN  L_GET_LATEST_DOCS_NONCAT_CSR(x_purchasing_uom);
      else
        OPEN  L_GET_LATEST_DOCS_CSR(x_purchasing_uom);
      end if;

      LOOP
      if (l_noncat_item) then
       FETCH L_GET_LATEST_DOCS_NONCAT_CSR into x_document_header_id,
                                            x_document_line_id,
                                            x_document_line_num,
                                            x_document_type_code,
                                            x_vendor_site_id,
                                            x_vendor_contact_id,
                                            x_buyer_id,
                                            x_vendor_product_num,
                                            l_global_agreement_flag,
                                            l_document_org_id,
                                            l_source_doc_purchasing_uom; -- Bug 3361128
         EXIT WHEN L_GET_LATEST_DOCS_NONCAT_CSR%NOTFOUND;
      ELSE
       FETCH L_GET_LATEST_DOCS_CSR into x_document_header_id,
                                            x_document_line_id,
                                            x_document_line_num,
                                            x_document_type_code,
                                            x_vendor_site_id,
                                            x_vendor_contact_id,
                                            x_buyer_id,
                                            x_vendor_product_num,
                                            l_global_agreement_flag,
                                            l_document_org_id,
                                            l_source_doc_purchasing_uom, -- Bug 3361128
                                            l_doc_type_fetch_order, -- Bug 5081434
                                            l_uom_match,     -- Bug 5081434
                                            l_global_flag,   -- Bug 5081434
                                            l_creation_date, -- bug5081434
											l_expiration_date; --Bug14145177


         EXIT WHEN L_GET_LATEST_DOCS_CSR%NOTFOUND;
        END IF;

         l_progress := '030';

           /* FPI GA start */
           if x_document_header_id is not null then

       --<R12 STYLES PHASE II START>
        -- Validate whether the Sourced Docuemnt is Style Compatible
           IF g_debug_stmt THEN
              PO_DEBUG.debug_stmt(l_log_head,l_progress,'style validate source doc');
              PO_DEBUG.debug_var(l_log_head,l_progress,'x_destination_doc_type', x_destination_doc_type);
              PO_DEBUG.debug_var(l_log_head,l_progress,'x_document_type_code', x_document_type_code);
           END IF;
        l_eligible_doc_flag := TRUE;
	  --in case the sourcing is happening without passing any attributes as in pricing only mode
	  --check if all the attributes are NULL
	  --in such a case bypass the style validation checks
        IF    p_line_type_id IS NULL
	     AND p_purchase_basis IS NULL
	     AND p_destination_type IS NULL
	     AND p_style_id IS NULL  then

              l_eligible_doc_flag := TRUE;
              IF g_debug_stmt THEN
                 PO_DEBUG.debug_stmt(l_log_head,l_progress,'bypass style validations');
              END IF;

       else --if attributes are passed then do style validation checks

               IF g_debug_stmt THEN
                 PO_DEBUG.debug_stmt(l_log_head,l_progress,'do style validations');
              END IF;

        if x_destination_doc_type IN ('REQ','REQ_NONCATALOG') then
          if (x_document_type_code IN ('BLANKET', 'CONTRACT')) then

                PO_DOC_STYLE_PVT.style_validate_req_attrs(p_api_version      => 1.0,
                                                          p_init_msg_list    => FND_API.G_TRUE,
                                                          x_return_status    => l_return_status,
                                                          x_msg_count        => l_msg_count,
                                                          x_msg_data         => l_msg_data,
                                                          p_doc_style_id     => null,
                                                          p_document_id      => x_document_header_id,
                                                          p_line_type_id     => p_line_type_id,
                                                          p_purchase_basis   => p_purchase_basis,
                                                          p_destination_type => p_destination_type,
                                                          p_source           => 'REQUISITION'
                                                          );

             if l_return_status <> FND_API.g_ret_sts_success THEN
                l_eligible_doc_flag := FALSE;
             end if;
          end if;

        else  -- x_destination_doc_type = 'STANDARD PO','PO' OR NULL

          If (p_style_id <>
             PO_DOC_STYLE_PVT.get_doc_style_id(x_document_header_id)) THEN
             l_eligible_doc_flag := FALSE;
          end if;

        end if; -- x_destination_doc_type = 'STANDARD PO','PO' OR NULL
      end if;  -- if   p_line_type_id IS NULL

        --<R12 STYLES PHASE II END>


        if l_eligible_doc_flag then           --<R12 STYLES PHASE II>

              GET_SITE_ID_IF_ITEM_ON_DOC_OK(
                  p_document_header_id        => x_document_header_id,
                  p_item_id                   => x_item_id,
                  p_vendor_site_sourcing_flag => p_vendor_site_sourcing_flag,
                  p_global_agreement_flag     => l_global_agreement_flag,
                  p_document_org_id           => l_document_org_id,
                  x_return_status             => x_return_status,
                  x_vendor_site_id            => x_vendor_site_id,
                  x_vendor_contact_id         => x_vendor_contact_id,
	          p_destination_doc_type      => x_destination_doc_type, --<Bug 3356349>
		  p_multi_org                 => x_multi_org --<CTO Bug 4222144>
		);

              IF x_return_status = FND_API.G_RET_STS_SUCCESS then
                                   l_progress := '040';
                 IF g_debug_stmt THEN
                    PO_DEBUG.debug_stmt(l_log_head,l_progress,'Found a document:');
                    PO_DEBUG.debug_var(l_log_head,l_progress,'Total Documents looked at', L_GET_LATEST_DOCS_CSR%ROWCOUNT);
                    PO_DEBUG.debug_var(l_log_head,l_progress,'x_document_header_id', x_document_header_id);
                    PO_DEBUG.debug_var(l_log_head,l_progress,'x_document_line_id', x_document_line_id);
                    PO_DEBUG.debug_var(l_log_head,l_progress,'l_vendor_site_id', x_vendor_site_id);
                 END IF;
                                   exit;
              END IF;
         end if; -- if l_eligible_doc_flag --<R12 STYLES PHASE II>
                  l_progress := '050';

                  /* Bug 2752091 : If the item is not valid in the current OU
                     we null out the doc info that was already fetched so that
                     it does not get returned to the form */
                  x_document_header_id := null;
                  x_document_line_id   := null;
                  x_document_line_num  := null;
                  x_document_type_code :=  null;

            else
               exit;
            end if; --if x_document_header_id is not null then
          /* FPI GA end */

      END LOOP;
      if (l_noncat_item) then
        CLOSE L_GET_LATEST_DOCS_NONCAT_CSR;
      else
        CLOSE L_GET_LATEST_DOCS_CSR;
      end if;

      l_progress := '060';

/* Bug 2373004 {
   If there is no document which is valid on need-by-date then try to locate
   a document which is valid at least on current date.  For consistency with
   ASL-based sourcing, coding this behaviour in automatic sourcing as well. */

      IF ( x_document_header_id is NULL
         AND trunc(x_sourcing_date) <> trunc(sysdate)) THEN

          x_sourcing_date := trunc(sysdate);

          l_progress := '070';

      if (l_noncat_item) then
          OPEN  L_GET_LATEST_DOCS_NONCAT_CSR(x_purchasing_uom);
      else
          OPEN  L_GET_LATEST_DOCS_CSR(x_purchasing_uom);
      end if;
          LOOP
      if (l_noncat_item) then
           FETCH L_GET_LATEST_DOCS_NONCAT_CSR into x_document_header_id,
                                            x_document_line_id,
                                            x_document_line_num,
                                            x_document_type_code,
                                            x_vendor_site_id,
                                            x_vendor_contact_id,
                                            x_buyer_id,
                                            x_vendor_product_num,
                                            l_global_agreement_flag,
                                            l_document_org_id,
                                            l_source_doc_purchasing_uom; -- Bug 3361128
             EXIT WHEN L_GET_LATEST_DOCS_NONCAT_CSR%NOTFOUND;
      else
           FETCH L_GET_LATEST_DOCS_CSR into x_document_header_id,
                                            x_document_line_id,
                                            x_document_line_num,
                                            x_document_type_code,
                                            x_vendor_site_id,
                                            x_vendor_contact_id,
                                            x_buyer_id,
                                            x_vendor_product_num,
                                            l_global_agreement_flag,
                                            l_document_org_id,
                                            l_source_doc_purchasing_uom, -- Bug 3361128
                                            l_doc_type_fetch_order, -- Bug 5081434
                                            l_uom_match,     -- Bug 5081434
                                            l_global_flag,   -- Bug 5081434
                                            l_creation_date, -- bug5081434
											l_expiration_date; --Bug14145177

             EXIT WHEN L_GET_LATEST_DOCS_CSR%NOTFOUND;
      end if;


              /* FPI GA start */
              if x_document_header_id is not null then
         --<R12 STYLES PHASE II START>
          -- Validate whether the Sourced Docuemnt is Style Compatible
           IF g_debug_stmt THEN
              PO_DEBUG.debug_stmt(l_log_head,l_progress,'style validate source doc');
              PO_DEBUG.debug_var(l_log_head,l_progress,'x_destination_doc_type', x_destination_doc_type);
              PO_DEBUG.debug_var(l_log_head,l_progress,'x_document_type_code', x_document_type_code);
           END IF;
          l_eligible_doc_flag := TRUE;

	  --in case the sourcing is happening without passing any attributes as in pricing only mode
	  --check if all the attributes are NULL
	  --in such a case bypass the style validation checks
        if   p_line_type_id IS NULL
	     AND p_purchase_basis IS NULL
	     AND p_destination_type IS NULL
	     AND p_style_id IS NULL  then

              l_eligible_doc_flag := TRUE;
              IF g_debug_stmt THEN
                 PO_DEBUG.debug_stmt(l_log_head,l_progress,'bypass style validations');
              END IF;

       else --if attributes are passed then do style validation checks

               IF g_debug_stmt THEN
                 PO_DEBUG.debug_stmt(l_log_head,l_progress,'do style validations');
              END IF;

        if x_destination_doc_type IN ('REQ','REQ_NONCATALOG') then
            if (x_document_type_code IN ('BLANKET', 'CONTRACT')) then
                PO_DOC_STYLE_PVT.style_validate_req_attrs(p_api_version      => 1.0,
                                                          p_init_msg_list    => FND_API.G_TRUE,
                                                          x_return_status    => l_return_status,
                                                          x_msg_count        => l_msg_count,
                                                          x_msg_data         => l_msg_data,
                                                          p_doc_style_id     => null,
                                                          p_document_id      => x_document_header_id,
                                                          p_line_type_id     => p_line_type_id,
                                                          p_purchase_basis   => p_purchase_basis,
                                                          p_destination_type => p_destination_type,
                                                          p_source           => 'REQUISITION'
                                                          );

             if l_return_status <> FND_API.g_ret_sts_success THEN
                l_eligible_doc_flag := FALSE;
             end if;

            end if;

        else  -- x_destination_doc_type = 'STANDARD PO','PO' OR NULL

            If (p_style_id <>
               PO_DOC_STYLE_PVT.get_doc_style_id(x_document_header_id)) THEN
              l_eligible_doc_flag := FALSE;
            end if;

          end if; -- x_destination_doc_type = 'STANDARD PO','PO' OR NULL
        end if;  -- if   p_line_type_id IS NULL
          --<R12 STYLES PHASE II END>

          if l_eligible_doc_flag then       --<R12 STYLES PHASE II>


              GET_SITE_ID_IF_ITEM_ON_DOC_OK(
                  p_document_header_id        => x_document_header_id,
                  p_item_id                   => x_item_id,
                  p_vendor_site_sourcing_flag => p_vendor_site_sourcing_flag,
                  p_global_agreement_flag     => l_global_agreement_flag,
                  p_document_org_id           => l_document_org_id,
                  x_return_status             => x_return_status,
                  x_vendor_site_id            => x_vendor_site_id,
                  x_vendor_contact_id         => x_vendor_contact_id,
	          p_destination_doc_type      => x_destination_doc_type, --<Bug 3356349>
	          p_multi_org                 => x_multi_org --<CTO Bug 4222144>
		);

              IF x_return_status = FND_API.G_RET_STS_SUCCESS then
                             l_progress := '080';
                 IF g_debug_stmt THEN
                    PO_DEBUG.debug_stmt(l_log_head,l_progress,'Found a document with sysdate:');
                    PO_DEBUG.debug_var(l_log_head,l_progress,'Total Documents looked at', L_GET_LATEST_DOCS_CSR%ROWCOUNT);
                    PO_DEBUG.debug_var(l_log_head,l_progress,'x_document_header_id', x_document_header_id);
                    PO_DEBUG.debug_var(l_log_head,l_progress,'x_document_line_id', x_document_line_id);
                    PO_DEBUG.debug_var(l_log_head,l_progress,'l_vendor_site_id', x_vendor_site_id);
                 END IF;
                             exit;
               END IF;
          end if; -- if l_eligible_doc_flag --<R12 STYLES PHASE II>
                  l_progress := '090';

                  /* Bug 2752091 : If the item is not valid in the current OU
                     we null out the doc info that was already fetched so that
                     it does not get returned to the form */
                  x_document_header_id := null;
                  x_document_line_id   := null;
                  x_document_line_num  := null;
                  x_document_type_code :=  null;
                  l_source_doc_purchasing_uom :=  null;   --<R12 STYLES PHASE II>

            else
               exit;
            end if;
              /* FPI GA end */

         END LOOP;
      if (l_noncat_item) then
         CLOSE L_GET_LATEST_DOCS_NONCAT_CSR;
      else
         CLOSE L_GET_LATEST_DOCS_CSR;
      end if;

      END IF;

      -- Bug 3361128: pass back the UOM on the source doc (if any);
      -- also, the ASL UOM takes precedence over the UOM passed in
      x_purchasing_uom := nvl(nvl(l_source_doc_purchasing_uom, x_asl_purchasing_uom),
                              x_purchasing_uom);

      l_progress := '100';

EXCEPTION
    WHEN OTHERS THEN
         IF g_debug_unexp THEN
            PO_DEBUG.debug_exc(l_log_head,l_progress);
         END IF;

        PO_MESSAGE_S.SQL_ERROR('GET_LATEST_DOCUMENT', l_progress, sqlcode);
END get_latest_document;

--<Shared Proc FPJ START>
-------------------------------------------------------------------------------
--Start of Comments
--Name: GET_SITE_ID_IF_ITEM_ON_DOC_OK
--Pre-reqs:
--  None
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  This function does ITEM validation checks on GA OU, ROU and POU.
--  If item is valid and p_vendor_site_sourcing_flag = 'Y' then
--  this procedure returns the vendor_site_id
--Parameters:
--IN:
--p_document-header_id
--  The source doc unique identifier
--p_item_id
--  item_id of item on source doc
--p_vendor_site_sourcing_flag
--  Flag which determines if vendor_site_id needs to be derived
--p_global_agreement_flag
--  flag indicating if the document passed in is GA
--p_document_org_id
--  Operating Unit ID of the source document
--p_multi_org
--  Flag indicating if its CTO call
--IN OUT
--x_vendor_site_id
--  The site id derived from Source DOc
--x_vendor_contact_id
--  contact id is returned if there is unique contact defined
--OUT:
--x_return_status
--  Tells whether item is valid and the outcome of the call
--Testing:
--  None
--End of Comments
-------------------------------------------------------------------------------
procedure GET_SITE_ID_IF_ITEM_ON_DOC_OK(
                   p_document_header_id        IN NUMBER,
                   p_item_id                   IN NUMBER,
                   p_vendor_site_sourcing_flag IN VARCHAR2,
                   p_global_agreement_flag     IN VARCHAR2,
                   p_document_org_id           IN NUMBER,
                   x_return_status             OUT NOCOPY VARCHAR2,
                   x_vendor_site_id            IN OUT NOCOPY NUMBER,
                   x_vendor_contact_id         IN OUT NOCOPY NUMBER,
		   p_destination_doc_type      IN VARCHAR2, --<Bug 3356349>
                   p_multi_org                 IN VARCHAR2 --<CTO Bug 4222144>
					) IS

l_is_item_valid            BOOLEAN := FALSE;
l_is_org_valid  BOOLEAN := FALSE;
l_item_revision            PO_LINES_ALL.item_revision%TYPE;
x_vendor_contact_name      PO_VENDOR_CONTACTS.last_name%TYPE;
l_vendor_contact_name      VARCHAR2(240); --<Bug 11840623>
l_current_org_id           PO_HEADERS_ALL.org_id%TYPE;
l_purchasing_org_id        PO_HEADERS_ALL.org_id%TYPE; --<Bug 3356349>
l_progress                 VARCHAR2(3) := '000';
l_log_head     CONSTANT VARCHAR2(100) := g_log_head||'get_site_id_if_item_on_doc_ok';
BEGIN

     l_progress := '010';
     --<CTO Bug 4222144 START>
     --No need to do item validity checks for CTO call
     IF p_multi_org = 'Y' THEN
	x_return_status := FND_API.G_RET_STS_SUCCESS;
	RETURN;
     END IF;
     --<CTO Bug 4222144 END>

     IF p_global_agreement_flag = 'Y' THEN

        l_progress := '020';

        --<Bug 3356349 mbhargav START>
        IF p_destination_doc_type = 'STANDARD PO' AND
           p_vendor_site_sourcing_flag = 'N'
        THEN
           --Get purchasing org from site
           l_purchasing_org_id := PO_VENDOR_SITES_SV.get_org_id_from_vendor_site(
                      p_vendor_site_id => x_vendor_site_id);

           --Validate that the item is valid in GA org and POU
           PO_GA_PVT.validate_in_purchasing_org(
                  x_return_status     => x_return_status,
                  p_po_header_id      => p_document_header_id,
                  p_item_id           => p_item_id,
                  p_purchasing_org_id => l_purchasing_org_id,
                  --No Need to do Item Revision checks
                  --They are done in the cursor already
                  p_ga_item_revision  => NULL,
                  p_owning_org_id     => p_document_org_id,
                  x_is_pou_valid      => l_is_org_valid,
                  x_is_item_valid     => l_is_item_valid,
                  x_item_revision     => l_item_revision);
        ELSE
           l_current_org_id := PO_GA_PVT.get_current_org;
           --Validate that the item is valid in GA org, ROU and POU
           PO_GA_PVT.validate_in_requesting_org(
                  x_return_status     => x_return_status,
                  p_po_header_id      => p_document_header_id,
                  p_item_id           => p_item_id,
                  p_requesting_org_id => l_current_org_id,
                  --No Need to do Item Revision checks
                  --They are done in the cursor already
                  p_ga_item_revision  => NULL,
                  p_owning_org_id     => p_document_org_id,
                  x_is_rou_valid      => l_is_org_valid,
                  x_is_item_valid     => l_is_item_valid,
                  x_item_revision     => l_item_revision);
        END IF;
        --<Bug 3356349 mbhargav END>

        IF (x_return_status <> FND_API.g_ret_sts_success) THEN
            RETURN;
        END IF;

        IF l_is_org_valid and l_is_item_valid then
            l_progress := '030';
            IF p_vendor_site_sourcing_flag = 'Y' THEN
	              --Now get the supplier_site_id and vendor_contact_id
 	              x_vendor_site_id :=
                            PO_GA_PVT.get_vendor_site_id(p_document_header_id);

	              IF x_vendor_contact_id is NULL then
 		                PO_VENDOR_CONTACTS_SV.get_vendor_contact(
                                       x_vendor_site_id 	=>x_vendor_site_id,
                                       x_vendor_contact_id 	=>x_vendor_contact_id,
                                       x_vendor_contact_name 	=>l_vendor_contact_name);
	              END IF;
            END IF; --vendor_site_sourcing_flag check

             x_return_status := FND_API.G_RET_STS_SUCCESS;

        ELSE

             x_return_status := FND_API.G_RET_STS_ERROR;
        END IF; --l_valid_flag check

     ELSE
           l_progress := '040';
            IF p_vendor_site_sourcing_flag = 'Y' and x_vendor_site_id is NULL THEN

                x_vendor_site_id := PO_VENDOR_SITES_SV.get_vendor_site_id(
                                           p_po_header_id   => p_document_header_id);

 		        PO_VENDOR_CONTACTS_SV.get_vendor_contact(
                                       x_vendor_site_id 	=>x_vendor_site_id,
                                       x_vendor_contact_id 	=>x_vendor_contact_id,
                                       x_vendor_contact_name 	=>l_vendor_contact_name);
            END IF;
            x_return_status := FND_API.G_RET_STS_SUCCESS;
     END IF; --GA Check
     l_progress := '050';

END GET_SITE_ID_IF_ITEM_ON_DOC_OK;
--<Shared Proc FPJ END>

--<Shared Proc FPJ START>
-------------------------------------------------------------------------------
--Start of Comments
--Name: ASL_SOURCING
--Pre-reqs:
--  Assumes that ASL will be used for Document Sourcing
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Looks at ASLs and tries to find a document that
--  can be used as source document. Returns the asl_id of ASL
--  It can additionally return sequence_number of doc on ASL
--Parameters:
--IN:
--p_item_id
--  item_id to be matched for ASL
--p_vendor_id
--  vendor_id to be matched for ASL
--p_vendor_site_code
--  if provided, this parameter is used for finding a matching ASL
--p_item_rev
--  Revision number of Item p_item_id
--p_item_rev_control
--  This parameter tells whether item revision control is ON for given p_item_id
--p_sourcing_date
--  Date to be used for Sourcing date check
--p_currency_code
--  Currency Code to be used in Sourcing
--p_org_id
--  Operating Unit id
--p_using_organization_id
--  LOCAL/GLOBAL
--OUT:
--x_asl_id
--  The unique identifier of Asl returned
--x_vendor_product_num
--  Supplier product_num associated with given Item as defined on ASL
--x_purchasing_uom
--  Purchasing UOM provided by Supplier on ASL
--x_consigned_from_supplier_flag
--  Flag indicating whether this combination is consigned
--x_enable_vmi_flag
--  Flag indicating if the ASL is VMI enabled
--x_sequence_num
--  The document position in ASL Documents window. This will be returned
--   if during ASL determination, we have also determined the exact document to source
--Notes:
--  Logic: This is a 4 way match (item, vendor, vendor site code, destination inv org)
--              The picking order of ASLs is:
--          1. Look for local ASLs in current OU
--          2. Look for Global Agreements in local ASLs in other OUs.
--              Pick the latest created GA to break ties
--           3. Look for Global ASLs in current OU
--           4. Look for Global Agreements in Global ASLs in other OUs.
--              Pick the latest created GA to break ties
--Testing:
--  None
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE asl_sourcing (
   p_item_id                      IN        NUMBER,
   p_vendor_id                    IN        NUMBER,
   p_vendor_site_code             IN        VARCHAR2,
   p_item_rev		          IN 	    VARCHAR2,
   p_item_rev_control		  IN	    NUMBER,
   p_sourcing_date		  IN	    DATE,
   p_currency_code	          IN 	    VARCHAR2,
   p_org_id			  IN	    NUMBER,
   p_using_organization_id        IN OUT NOCOPY NUMBER,
   x_asl_id                       OUT NOCOPY NUMBER,
   x_vendor_product_num           OUT NOCOPY VARCHAR2,
   x_purchasing_uom               OUT NOCOPY VARCHAR2,
   x_consigned_from_supplier_flag OUT NOCOPY VARCHAR2,
   x_enable_vmi_flag              OUT NOCOPY VARCHAR2,
   x_sequence_num                 OUT NOCOPY NUMBER,
   p_category_id 		  IN 	    NUMBER --<Contract AutoSourcing FPJ>
)
IS
   l_progress     VARCHAR2(3) := '000';
   l_log_head     CONSTANT VARCHAR2(100) := g_log_head||'asl_sourcing';
   l_using_organization_id   po_asl_documents.using_organization_id%TYPE;

BEGIN

   l_progress := '010';

   --<Bug 3545698 mbhargav START>
   --Seperated out the asl_sourcing into two procedures item_based_asl_sourcing
   --and CATEGORY_BASED_ASL_SOURCING.
   -- This was required for performance reasons. With this change the Optimizer
   -- will be able to use combination index on (vendor_id, item_id) or
   -- (vendor_id, category_id) as appropriate.

   IF p_item_id IS NOT NULL THEN
     item_based_asl_sourcing(
            p_item_id		=>p_item_id,
            p_vendor_id		=>p_vendor_id,
	        p_vendor_site_code	=>p_vendor_site_code,
            p_item_rev		=>p_item_rev,
            p_item_rev_control	=>p_item_rev_control,
            p_sourcing_date	=>p_sourcing_date,
            p_currency_code	=>p_currency_code,
            p_org_id		=>p_org_id,
            p_using_organization_id =>p_using_organization_id,
            x_asl_id 		=>x_asl_id,
            x_vendor_product_num 	=>x_vendor_product_num,
            x_purchasing_uom 	=>x_purchasing_uom,
 	        x_consigned_from_supplier_flag =>x_consigned_from_supplier_flag,
 	        x_enable_vmi_flag 	=>x_enable_vmi_flag,
            x_sequence_num 	=>x_sequence_num,
            p_category_id          => p_category_id --<Contract AutoSourcing FPJ>
            );

     IF x_asl_id IS NOT NULL THEN
        IF g_debug_stmt THEN
            PO_DEBUG.debug_stmt(l_log_head,l_progress,'item_based_asl_sourcing returned:');
            PO_DEBUG.debug_var(l_log_head,l_progress,'asl_id obtained', x_asl_id);
            PO_DEBUG.debug_var(l_log_head,l_progress,'sequence num obtained', x_sequence_num);
        END IF;
        RETURN;
     END IF;
   END IF;

    l_progress := '020';

   IF p_category_id IS NOT NULL THEN
      category_based_asl_sourcing(
            p_item_id		=>p_item_id,
            p_vendor_id		=>p_vendor_id,
	        p_vendor_site_code	=>p_vendor_site_code,
            p_item_rev		=>p_item_rev,
            p_item_rev_control	=>p_item_rev_control,
            p_sourcing_date	=>p_sourcing_date,
            p_currency_code	=>p_currency_code,
            p_org_id		=>p_org_id,
            p_using_organization_id =>p_using_organization_id,
            x_asl_id 		=>x_asl_id,
            x_vendor_product_num 	=>x_vendor_product_num,
            x_purchasing_uom 	=>x_purchasing_uom,
 	        x_consigned_from_supplier_flag =>x_consigned_from_supplier_flag,
 	        x_enable_vmi_flag 	=>x_enable_vmi_flag,
            x_sequence_num 	=>x_sequence_num,
            p_category_id          => p_category_id --<Contract AutoSourcing FPJ>
            );

     IF x_asl_id IS NOT NULL THEN
        IF g_debug_stmt THEN
            PO_DEBUG.debug_stmt(l_log_head,l_progress,'category_based_asl_sourcing returned:');
            PO_DEBUG.debug_var(l_log_head,l_progress,'asl_id obtained', x_asl_id);
            PO_DEBUG.debug_var(l_log_head,l_progress,'sequence num obtained', x_sequence_num);
        END IF;
        RETURN;
     END IF;
   END IF; --category_id is NOT NULL
   --<Bug 3545698 mbhargav END>

   l_progress := '030';
   IF g_debug_stmt THEN
        PO_DEBUG.debug_stmt(l_log_head,l_progress,'No matching ASL not found');
   END IF;

EXCEPTION
    WHEN OTHERS THEN
         IF g_debug_unexp THEN
            PO_DEBUG.debug_exc(l_log_head,l_progress);
         END IF;

        PO_MESSAGE_S.SQL_ERROR('ASL_SOURCING', l_progress, sqlcode);
END ASL_SOURCING;
--<Shared Proc FPJ END>

-------------------------------------------------------------------------------
--Start of Comments
--Name: ITEM_BASED_ASL_SOURCING
--Pre-reqs:
--  Assumes that ASL will be used for Document Sourcing
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Looks at ASLs and tries to find a document that
--  can be used as source document for given ITEM_ID. Returns the asl_id of ASL
--  It can additionally return sequence_number of doc on ASL
--Parameters:
--IN:
--p_item_id
--  item_id to be matched for ASL
--p_vendor_id
--  vendor_id to be matched for ASL
--p_vendor_site_code
--  if provided, this parameter is used for finding a matching ASL
--p_item_rev
--  Revision number of Item p_item_id
--p_item_rev_control
--  This parameter tells whether item revision control is ON for given p_item_id
--p_sourcing_date
--  Date to be used for Sourcing date check
--p_currency_code
--  Currency Code to be used in Sourcing
--p_org_id
--  Operating Unit id
--p_using_organization_id
--  LOCAL/GLOBAL
--OUT:
--x_asl_id
--  The unique identifier of Asl returned
--x_vendor_product_num
--  Supplier product_num associated with given Item as defined on ASL
--x_purchasing_uom
--  Purchasing UOM provided by Supplier on ASL
--x_consigned_from_supplier_flag
--  Flag indicating whether this combination is consigned
--x_enable_vmi_flag
--  Flag indicating if the ASL is VMI enabled
--x_sequence_num
--  The document position in ASL Documents window. This will be returned
--   if during ASL determination, we have also determined the exact document to source
--Notes:
--  Logic: This is a 4 way match (item, vendor, vendor site code, destination inv org)
--              The picking order of ASLs is:
--          1. Look for local ASLs in current OU
--          2. Look for Global Agreements in local ASLs in other OUs.
--              Pick the latest created GA to break ties
--           3. Look for Global ASLs in current OU
--           4. Look for Global Agreements in Global ASLs in other OUs.
--              Pick the latest created GA to break ties
--Testing:
--  None
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE ITEM_BASED_ASL_SOURCING (
   p_item_id                      IN        NUMBER,
   p_vendor_id                    IN        NUMBER,
   p_vendor_site_code             IN        VARCHAR2,
   p_item_rev		          IN 	    VARCHAR2,
   p_item_rev_control		  IN	    NUMBER,
   p_sourcing_date		  IN	    DATE,
   p_currency_code	          IN 	    VARCHAR2,
   p_org_id			  IN	    NUMBER,
   p_using_organization_id        IN OUT NOCOPY NUMBER, --<Bug 3733077>
   x_asl_id                       OUT NOCOPY NUMBER,
   x_vendor_product_num           OUT NOCOPY VARCHAR2,
   x_purchasing_uom               OUT NOCOPY VARCHAR2,
   x_consigned_from_supplier_flag OUT NOCOPY VARCHAR2,
   x_enable_vmi_flag              OUT NOCOPY VARCHAR2,
   x_sequence_num                 OUT NOCOPY NUMBER,
   p_category_id 		  IN 	    NUMBER --<Contract AutoSourcing FPJ>
)
IS
   l_progress     VARCHAR2(3) := '000';
   l_log_head     CONSTANT VARCHAR2(100) := g_log_head||'item_based_asl_sourcing';
   l_using_organization_id   po_asl_documents.using_organization_id%TYPE;

  --This cursor is used to look for ITEM ASLs in current OU
  --Note: If you make any change in this cursor then consider whether you
  --      need to make change to cursor L_CATEGORY_ASL_IN_CUR_OU_CSR as well
  CURSOR L_ITEM_ASL_IN_CUR_OU_CSR (
      p_using_organization_id  IN   NUMBER
   )
   IS
      --SQL WHAT: Get the matching asl_id if one exists in current OU
      --SQL WHY: This information will be used to identify the document in ASL.
      --SQL JOIN: po_asl_attributes using asl_id, po_asl_status_rules_v using status_id
      --                     po_vendor_sites_all using vendor_site_id
      SELECT   pasl.asl_id, paa.using_organization_id,
               pasl.primary_vendor_item, paa.purchasing_unit_of_measure,
               paa.consigned_from_supplier_flag, paa.enable_vmi_flag
          FROM po_approved_supplier_lis_val_v pasl,
               po_asl_attributes paa,
               po_asl_status_rules_v pasr,
               po_vendor_sites_all pvs
         WHERE pasl.item_id = p_item_id  --<Contract AutoSourcing FPJ>
           AND pasl.vendor_id = p_vendor_id
           AND pasl.using_organization_id in (-1, p_using_organization_id) --<Bug 3733077>
           AND pasl.asl_id = paa.asl_id
           AND pasr.business_rule = '2_SOURCING'
           AND pasr.allow_action_flag ='Y'
           AND pasr.status_id = pasl.asl_status_id
           AND paa.using_organization_id = p_using_organization_id
           AND nvl(pvs.org_id,-99) = nvl(p_org_id, -99)
           AND pvs.vendor_id = p_vendor_id
           AND (   (pasl.vendor_site_id IS NULL AND p_vendor_site_code IS NULL)
                OR (    pasl.vendor_site_id = pvs.vendor_site_id
                    AND pvs.vendor_site_code = p_vendor_site_code
                   )
               )
      ORDER BY pasl.vendor_site_id ASC;

   --Look for ITEM ASLs in other Operating Units. This cursor also returns
   --the sequence number of the GA found. If the GA passes the item validity
   --check then this document is returned as source document
   --Note: If you make any change in this cursor then consider whether you
   --      need to make change to cursor L_CATEGORY_ASL_DOCUMENTS_CSR as well
   CURSOR L_ITEM_ASL_DOCUMENTS_CSR(
      p_using_organization_id   IN   NUMBER
   )
   IS
      --SQL WHAT: Get the matching asl_id, sequence_num of GA if one exists in other OU
      --SQL WHY: This information will be used to identify the document in ASL.
      --SQL JOIN: po_asl_attributes using asl_id, po_asl_status_rules_v using status_id
      --          po_asl_docuyment using asl_id, sequence_num, po_headers_all using
      --          po_header_id, po_lines_all using po_line_id
      SELECT   pasl.asl_id, paa.using_organization_id,
               pasl.primary_vendor_item, paa.purchasing_unit_of_measure,
               paa.consigned_from_supplier_flag, paa.enable_vmi_flag,
               pad.sequence_num
          FROM po_approved_supplier_lis_val_v pasl,
               po_asl_attributes paa,
               po_asl_status_rules_v pasr,
               po_asl_documents pad,
               po_headers_all poh,
               po_lines_all pol
         WHERE pasl.item_id = p_item_id    --<Contract AutoSourcing FPJ>
           AND pasl.vendor_id = p_vendor_id
           AND pasl.using_organization_id in (-1, p_using_organization_id) --<Bug 3733077>
           AND pasl.asl_id = paa.asl_id
           AND pasr.business_rule = '2_SOURCING'
           AND pasr.allow_action_flag = 'Y'
           AND pasr.status_id = pasl.asl_status_id
           AND paa.using_organization_id = p_using_organization_id
           AND pad.asl_id = pasl.asl_id
           AND pad.document_header_id = poh.po_header_id
           AND pol.po_line_id (+) = pad.document_line_id	-- <FPJ Advanced Price>
           AND ((    poh.type_lookup_code = 'BLANKET'
                 AND poh.approved_flag = 'Y'
                 AND NVL (poh.closed_code, 'OPEN') NOT IN
                                                  ('FINALLY CLOSED', 'CLOSED')
                 AND NVL (pol.closed_code, 'OPEN') NOT IN
                                                  ('FINALLY CLOSED', 'CLOSED')
                 AND NVL (poh.cancel_flag, 'N') = 'N'
                 AND NVL (poh.frozen_flag, 'N') = 'N'
                 AND TRUNC (NVL (pol.expiration_date, p_sourcing_date)) >=
                                                       p_sourcing_date
                 AND NVL (pol.cancel_flag, 'N') = 'N'
                )
            -- <FPJ Advanced Price START>
             OR (    poh.type_lookup_code = 'CONTRACT'
        	 	AND (( NVL(FND_PROFILE.VALUE('ALLOW_REFERENCING_CPA_UNDER_AMENDMENT'),'N') =  'Y' --<R12 GCPA ER>
			 			and poh.approved_date is not null)
			 			OR
			 			nvl(poh.approved_flag,'N') = 'Y'
			 			)
                 AND NVL(poh.cancel_flag,'N') = 'N'
                 AND NVL(poh.frozen_flag,'N') = 'N'
                 AND NVL(poh.closed_code, 'OPEN') = 'OPEN'
                )
               )
            -- <FPJ Advanced Price END>
           AND (p_currency_code IS NULL OR poh.currency_code = p_currency_code
               )
           AND p_sourcing_date >= NVL (poh.start_date, p_sourcing_date - 1)
           AND p_sourcing_date <= NVL (poh.end_date, p_sourcing_date + 1)
           -- <FPJ Advanced Price START>
           AND (poh.type_lookup_code = 'CONTRACT' OR
                (NVL(pol.item_revision, -1) = NVL(p_item_rev, -1) OR
	         (NVL (p_item_rev_control, 1) = 1 AND p_item_rev IS NULL)))
           -- <FPJ Advanced Price END>
           AND ((pasl.vendor_site_id IS NULL AND p_vendor_site_code IS NULL)
                OR EXISTS (
                       SELECT  'vendor site code matches ASL'
                       FROM  po_vendor_sites_all pvs
                       WHERE pasl.vendor_site_id = decode(nvl(poh.Enable_all_sites,'N'),'N',pvs.vendor_site_id,pasl.vendor_site_id)  --<R12GCPA ER>
                       AND pvs.vendor_site_code = p_vendor_site_code
                       AND pvs.vendor_id = p_vendor_id)
                )
           AND (    NVL (poh.global_agreement_flag, 'N') = 'Y'
                AND EXISTS (
                       SELECT 'vendor site code matches GA'
                         FROM po_ga_org_assignments poga,
                              po_vendor_sites_all pvs
                        WHERE poh.po_header_id = poga.po_header_id
                          AND poga.organization_id = p_org_id
                          AND poga.enabled_flag = 'Y'
                          AND pvs.vendor_site_id = decode( Nvl (poh.Enable_All_Sites,'N'),'N',poga.Vendor_Site_Id,pvs.vendor_site_id) --< R12 GCPA ER>
                          AND pvs.vendor_site_code = p_vendor_site_code
                          AND pvs.vendor_id = p_vendor_id)
               )
      ORDER BY poh.creation_date DESC;

BEGIN

   l_progress := '010';

   --<Contract AutoSourcing FPJ>
   --Look for item-based ASLs
     IF g_debug_stmt THEN
        --<Contract AutoSourcing FPJ>
       PO_DEBUG.debug_stmt(l_log_head,l_progress,'Look in Local item-based ASLs in current OU');
     END IF;

     --First look for local ASLs in current operating unit
     --Local ASL: p_using_organization_id = p_using_organization_id
     --Current Operating Unit: p_operating_unit =l_operating_unit
     --Will return rows if vendor_site is not provided on ASL and in input parameter OR
     -- the site on ASL is in current OU and site_code match
     OPEN L_ITEM_ASL_IN_CUR_OU_CSR (
                     p_using_organization_id =>p_using_organization_id);

     FETCH L_ITEM_ASL_IN_CUR_OU_CSR INTO x_asl_id,
      p_using_organization_id,
      x_vendor_product_num,
      x_purchasing_uom,
      x_consigned_from_supplier_flag,
      x_enable_vmi_flag;


     IF L_ITEM_ASL_IN_CUR_OU_CSR%FOUND
     THEN
        CLOSE L_ITEM_ASL_IN_CUR_OU_CSR;
        x_sequence_num := NULL;
        l_progress := '020';
        IF g_debug_stmt THEN
           PO_DEBUG.debug_stmt(l_log_head,l_progress,'Found:');
           PO_DEBUG.debug_var(l_log_head,l_progress,'x_asl_id', x_asl_id);
        END IF;
        RETURN;
     END IF;

     CLOSE L_ITEM_ASL_IN_CUR_OU_CSR;

     IF g_debug_stmt THEN
        --<Contract AutoSourcing FPJ>
        PO_DEBUG.debug_stmt(l_log_head,l_progress,'Look in Local item-based ASLs in other OUs');
     END IF;

     --Try to find local ASLs in other operating units
     --Local ASL: p_using_organization_id = p_using_organization_id
     --Other OUs: p_operating_unit = NULL
     --Will return rows if we can find a GA in other OUs which are listed in ASLs
     OPEN L_ITEM_ASL_DOCUMENTS_CSR(
              p_using_organization_id	=> p_using_organization_id);
     FETCH L_ITEM_ASL_DOCUMENTS_CSR INTO x_asl_id,
      p_using_organization_id,
      x_vendor_product_num,
      x_purchasing_uom,
      x_consigned_from_supplier_flag,
      x_enable_vmi_flag,
      x_sequence_num;

     IF L_ITEM_ASL_DOCUMENTS_CSR%FOUND
     THEN
        CLOSE L_ITEM_ASL_DOCUMENTS_CSR;
        l_progress := '030';
        IF g_debug_stmt THEN
           PO_DEBUG.debug_stmt(l_log_head,l_progress,'Found:');
           PO_DEBUG.debug_var(l_log_head,l_progress,'x_asl_id', x_asl_id);
           PO_DEBUG.debug_var(l_log_head,l_progress,'x_sequence_num', x_sequence_num);
        END IF;
        RETURN;
     END IF;

     CLOSE L_ITEM_ASL_DOCUMENTS_CSR;

     IF g_debug_stmt THEN
        --<Contract AutoSourcing FPJ>
        PO_DEBUG.debug_stmt(l_log_head,l_progress,'Look in Global item-based ASLs in current OU');
     END IF;

     --Now look for global ASLs in current operating unit
     --Global ASL: p_using_organization_id = -1
     --Current Operating Unit: p_operating_unit =l_operating_unit
     --Will return rows if vendor_site is not provided on ASL and in input parameter OR
     -- the site on ASL is in current OU and site_code match
     OPEN L_ITEM_ASL_IN_CUR_OU_CSR (
                     p_using_organization_id	=>-1);
     FETCH L_ITEM_ASL_IN_CUR_OU_CSR INTO x_asl_id,
      p_using_organization_id,
      x_vendor_product_num,
      x_purchasing_uom,
      x_consigned_from_supplier_flag,
      x_enable_vmi_flag;

     IF L_ITEM_ASL_IN_CUR_OU_CSR%FOUND
     THEN
        CLOSE L_ITEM_ASL_IN_CUR_OU_CSR;
        x_sequence_num := NULL;
        l_progress := '040';
        IF g_debug_stmt THEN
           PO_DEBUG.debug_stmt(l_log_head,l_progress,'Found:');
           PO_DEBUG.debug_var(l_log_head,l_progress,'x_asl_id', x_asl_id);
        END IF;
        RETURN;
     END IF;

     CLOSE L_ITEM_ASL_IN_CUR_OU_CSR;

     IF g_debug_stmt THEN
        --<Contract AutoSourcing FPJ>
        PO_DEBUG.debug_stmt(l_log_head,l_progress,'Look in Global item-based ASLs in other OUs');

     END IF;

     --Try to find Global ASLs in other operating units
     --Global ASL: p_using_organization_id = -1
     --Other OUs: p_operating_unit = NULL
     --Will return rows if we can find a GA in other OUs which are listed in ASLs
     OPEN L_ITEM_ASL_DOCUMENTS_CSR(
              P_using_organization_id	=> -1);
     FETCH L_ITEM_ASL_DOCUMENTS_CSR INTO x_asl_id,
      p_using_organization_id,
      x_vendor_product_num,
      x_purchasing_uom,
      x_consigned_from_supplier_flag,
      x_enable_vmi_flag,
      x_sequence_num;

     IF L_ITEM_ASL_DOCUMENTS_CSR %FOUND
     THEN
        CLOSE L_ITEM_ASL_DOCUMENTS_CSR;
        l_progress := '050';
        IF g_debug_stmt THEN
           PO_DEBUG.debug_stmt(l_log_head,l_progress,'Found:');
           PO_DEBUG.debug_var(l_log_head,l_progress,'x_asl_id', x_asl_id);
           PO_DEBUG.debug_var(l_log_head,l_progress,'x_sequence_num', x_sequence_num);
        END IF;
        RETURN;
     END IF;

     CLOSE L_ITEM_ASL_DOCUMENTS_CSR;

     x_vendor_product_num := NULL;
     x_purchasing_uom := NULL;
     x_consigned_from_supplier_flag := NULL;
     x_enable_vmi_flag := NULL;
     x_sequence_num := NULL;
     l_progress := '060';

     IF g_debug_stmt THEN
       --<Contract AutoSourcing FPJ>
       PO_DEBUG.debug_stmt(l_log_head,l_progress,'Matching Item-based ASL not found');
     END IF;

EXCEPTION
    WHEN OTHERS THEN
         IF g_debug_unexp THEN
            PO_DEBUG.debug_exc(l_log_head,l_progress);
         END IF;

        PO_MESSAGE_S.SQL_ERROR('ITEM_BASED_ASL_SOURCING', l_progress, sqlcode);
END ITEM_BASED_ASL_SOURCING;

-------------------------------------------------------------------------------
--Start of Comments
--Name: CATEGORY_BASED_ASL_SOURCING
--Pre-reqs:
--  Assumes that ASL will be used for Document Sourcing
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Looks at ASLs and tries to find a document that
--  can be used as source document for given CATEGORY_ID. Returns the asl_id of ASL
--  It can additionally return sequence_number of doc on ASL
--Parameters:
--IN:
--p_item_id
--  item_id to be matched for ASL
--p_vendor_id
--  vendor_id to be matched for ASL
--p_vendor_site_code
--  if provided, this parameter is used for finding a matching ASL
--p_item_rev
--  Revision number of Item p_item_id
--p_item_rev_control
--  This parameter tells whether item revision control is ON for given p_item_id
--p_sourcing_date
--  Date to be used for Sourcing date check
--p_currency_code
--  Currency Code to be used in Sourcing
--p_org_id
--  Operating Unit id
--p_using_organization_id
--  LOCAL/GLOBAL
--p_category_id
--  category_id to be matched for ASL
--OUT:
--x_asl_id
--  The unique identifier of Asl returned
--x_vendor_product_num
--  Supplier product_num associated with given Item as defined on ASL
--x_purchasing_uom
--  Purchasing UOM provided by Supplier on ASL
--x_consigned_from_supplier_flag
--  Flag indicating whether this combination is consigned
--x_enable_vmi_flag
--  Flag indicating if the ASL is VMI enabled
--x_sequence_num
--  The document position in ASL Documents window. This will be returned
--   if during ASL determination, we have also determined the exact document to source
--Notes:
--  Logic: This is a 4 way match (item, vendor, vendor site code, destination inv org)
--              The picking order of ASLs is:
--          1. Look for local ASLs in current OU
--          2. Look for Global Agreements in local ASLs in other OUs.
--              Pick the latest created GA to break ties
--           3. Look for Global ASLs in current OU
--           4. Look for Global Agreements in Global ASLs in other OUs.
--              Pick the latest created GA to break ties
--Testing:
--  None
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE CATEGORY_BASED_ASL_SOURCING (
   p_item_id                      IN        NUMBER,
   p_vendor_id                    IN        NUMBER,
   p_vendor_site_code             IN        VARCHAR2,
   p_item_rev		          IN 	    VARCHAR2,
   p_item_rev_control		  IN	    NUMBER,
   p_sourcing_date		  IN	    DATE,
   p_currency_code	          IN 	    VARCHAR2,
   p_org_id			  IN	    NUMBER,
   p_using_organization_id        IN OUT NOCOPY NUMBER, --<Bug 3733077>
   x_asl_id                       OUT NOCOPY NUMBER,
   x_vendor_product_num           OUT NOCOPY VARCHAR2,
   x_purchasing_uom               OUT NOCOPY VARCHAR2,
   x_consigned_from_supplier_flag OUT NOCOPY VARCHAR2,
   x_enable_vmi_flag              OUT NOCOPY VARCHAR2,
   x_sequence_num                 OUT NOCOPY NUMBER,
   p_category_id 		  IN 	    NUMBER --<Contract AutoSourcing FPJ>
)
IS
   l_progress     VARCHAR2(3) := '000';
   l_log_head     CONSTANT VARCHAR2(100) := g_log_head||'category_based_asl_sourcing';
   l_using_organization_id   po_asl_documents.using_organization_id%TYPE;

  --This cursor is used to look for CATEGORY based ASLs in current OU
  --Note: If you make any change in this cursor then consider whether you
  --      need to make change to cursor L_ITEM_ASL_IN_CUR_OU_CSR as well
  CURSOR L_CATEGORY_ASL_IN_CUR_OU_CSR (
      p_using_organization_id  IN   NUMBER
   )
   IS
      --SQL WHAT: Get the matching asl_id if one exists in current OU
      --SQL WHY: This information will be used to identify the document in ASL.
      --SQL JOIN: po_asl_attributes using asl_id, po_asl_status_rules_v using status_id
      --                     po_vendor_sites_all using vendor_site_id
      SELECT   pasl.asl_id, paa.using_organization_id,
               pasl.primary_vendor_item, paa.purchasing_unit_of_measure,
               paa.consigned_from_supplier_flag, paa.enable_vmi_flag
          FROM po_approved_supplier_lis_val_v pasl,
               po_asl_attributes paa,
               po_asl_status_rules_v pasr,
               po_vendor_sites_all pvs
         WHERE pasl.category_id = p_category_id  --<Contract AutoSourcing FPJ>
           AND pasl.vendor_id = p_vendor_id
           AND pasl.using_organization_id in (-1, p_using_organization_id) --<Bug 3733077>
           AND pasl.asl_id = paa.asl_id
           AND pasr.business_rule = '2_SOURCING'
           AND pasr.allow_action_flag ='Y'
           AND pasr.status_id = pasl.asl_status_id
           AND paa.using_organization_id = p_using_organization_id
           AND (   (pasl.vendor_site_id IS NULL AND p_vendor_site_code IS NULL)
                OR (    pasl.vendor_site_id = pvs.vendor_site_id
                    AND pvs.vendor_site_code = p_vendor_site_code
                    AND nvl(pvs.org_id,-99) = nvl(p_org_id, -99)
                    AND pvs.vendor_id = p_vendor_id
                   )
               )
      ORDER BY pasl.vendor_site_id ASC;

   --Look for CATEGORY based ASLs in other Operating Units. This cursor also returns
   --the sequence number of the GA found. If the GA passes the item validity
   --check then this document is returned as source document
   --Note: If you make any change in this cursor then consider whether you
   --      need to make change to cursor L_ITEM_ASL_DOCUMENTS_CSR as well
   CURSOR L_CATEGORY_ASL_DOCUMENTS_CSR(
      p_using_organization_id   IN   NUMBER
   )
   IS
      --SQL WHAT: Get the matching asl_id, sequence_num of GA if one exists in other OU
      --SQL WHY: This information will be used to identify the document in ASL.
      --SQL JOIN: po_asl_attributes using asl_id, po_asl_status_rules_v using status_id
      --                     po_asl_docuyment using asl_id, sequence_num, po_headers_all using
      --                     po_header_id, po_lines_all using po_line_id
      SELECT   pasl.asl_id, paa.using_organization_id,
               pasl.primary_vendor_item, paa.purchasing_unit_of_measure,
               paa.consigned_from_supplier_flag, paa.enable_vmi_flag,
               pad.sequence_num
          FROM po_approved_supplier_lis_val_v pasl,
               po_asl_attributes paa,
               po_asl_status_rules_v pasr,
               po_asl_documents pad,
               po_headers_all poh,
               po_lines_all pol
         WHERE pasl.category_id = p_category_id  --<Contract AutoSourcing FPJ>
           AND pasl.vendor_id = p_vendor_id
           AND pasl.using_organization_id in (-1, p_using_organization_id) --<Bug 3733077>
           AND pasl.asl_id = paa.asl_id
           AND pasr.business_rule = '2_SOURCING'
           AND pasr.allow_action_flag = 'Y'
           AND pasr.status_id = pasl.asl_status_id
           AND paa.using_organization_id = p_using_organization_id
           AND pad.asl_id = pasl.asl_id
           AND pad.document_header_id = poh.po_header_id
           AND pol.po_line_id (+) = pad.document_line_id	-- <FPJ Advanced Price>
           AND ((    poh.type_lookup_code = 'BLANKET'
                 AND poh.approved_flag = 'Y'
                 AND NVL (poh.closed_code, 'OPEN') NOT IN
                                                  ('FINALLY CLOSED', 'CLOSED')
                 AND NVL (pol.closed_code, 'OPEN') NOT IN
                                                  ('FINALLY CLOSED', 'CLOSED')
                 AND NVL (poh.cancel_flag, 'N') = 'N'
                 AND NVL (poh.frozen_flag, 'N') = 'N'
                 AND TRUNC (NVL (pol.expiration_date, p_sourcing_date)) >=
                                                       p_sourcing_date
                 AND NVL (pol.cancel_flag, 'N') = 'N'
                )
            -- <FPJ Advanced Price START>
             OR (    poh.type_lookup_code = 'CONTRACT'
	        	 AND (( NVL(FND_PROFILE.VALUE('ALLOW_REFERENCING_CPA_UNDER_AMENDMENT'),'N') =  'Y' --<R12 GCPA ER>
				 		and poh.approved_date is not null)
				 		OR
				 		nvl(poh.approved_flag,'N') = 'Y'
				 		)
                 AND NVL(poh.cancel_flag,'N') = 'N'
                 AND NVL(poh.frozen_flag,'N') = 'N'
                 AND NVL(poh.closed_code, 'OPEN') = 'OPEN'
                )
               )
            -- <FPJ Advanced Price END>
           AND (p_currency_code IS NULL OR poh.currency_code = p_currency_code
               )
           AND p_sourcing_date >= NVL (poh.start_date, p_sourcing_date - 1)
           AND p_sourcing_date <= NVL (poh.end_date, p_sourcing_date + 1)
           -- <FPJ Advanced Price START>
           AND (poh.type_lookup_code = 'CONTRACT' OR
                (NVL(pol.item_revision, -1) = NVL(p_item_rev, -1) OR
	         (NVL (p_item_rev_control, 1) = 1 AND p_item_rev IS NULL)))
           -- <FPJ Advanced Price END>
           AND ((pasl.vendor_site_id IS NULL AND p_vendor_site_code IS NULL)
                OR EXISTS (
                       SELECT  'vendor site code matches ASL'
                       FROM  po_vendor_sites_all pvs
                       WHERE pasl.vendor_site_id = decode(nvl(poh.Enable_All_Sites,'N'),'N',pvs.vendor_site_id,pasl.vendor_site_id)  --<R12GCPA ER>
                       AND pvs.vendor_site_code = p_vendor_site_code
                       AND pvs.vendor_id = p_vendor_id)
                )
           AND (    NVL (poh.global_agreement_flag, 'N') = 'Y'
                AND EXISTS (
                       SELECT 'vendor site code matches GA'
                         FROM po_ga_org_assignments poga,
                              po_vendor_sites_all pvs
                        WHERE poh.po_header_id = poga.po_header_id
                          AND poga.organization_id = p_org_id
                          AND poga.enabled_flag = 'Y'
                          AND pvs.vendor_site_id = decode( Nvl (poh.Enable_All_Sites,'N'),'Y',pvs.vendor_site_id, poga.Vendor_Site_Id) --< R12 GCPA ER>
                          AND pvs.vendor_site_code = p_vendor_site_code
                          AND pvs.vendor_id = p_vendor_id)
               )
      ORDER BY poh.creation_date DESC;

BEGIN

   l_progress := '010';

   --<Contract AutoSourcing FPJ>
   --Look for category-based ASLs

     IF g_debug_stmt THEN
        --<Contract AutoSourcing FPJ>
        PO_DEBUG.debug_stmt(l_log_head,l_progress,'Look in Local category-based ASLs in current OU');
     END IF;

     --First look for local ASLs in current operating unit
     --Local ASL: p_using_organization_id = p_using_organization_id
     --Current Operating Unit: p_operating_unit =l_operating_unit
     --Will return rows if vendor_site is not provided on ASL and in input parameter OR
     -- the site on ASL is in current OU and site_code match
     OPEN L_CATEGORY_ASL_IN_CUR_OU_CSR (
                     p_using_organization_id =>p_using_organization_id);

     FETCH L_CATEGORY_ASL_IN_CUR_OU_CSR INTO x_asl_id,
      p_using_organization_id,
      x_vendor_product_num,
      x_purchasing_uom,
      x_consigned_from_supplier_flag,
      x_enable_vmi_flag;


     IF L_CATEGORY_ASL_IN_CUR_OU_CSR%FOUND
     THEN
        CLOSE L_CATEGORY_ASL_IN_CUR_OU_CSR;
        x_sequence_num := NULL;
        l_progress := '020';
        IF g_debug_stmt THEN
           PO_DEBUG.debug_stmt(l_log_head,l_progress,'Found:');
           PO_DEBUG.debug_var(l_log_head,l_progress,'x_asl_id', x_asl_id);
        END IF;
        RETURN;
     END IF;

     CLOSE L_CATEGORY_ASL_IN_CUR_OU_CSR;

     IF g_debug_stmt THEN
        --<Contract AutoSourcing FPJ>
        PO_DEBUG.debug_stmt(l_log_head,l_progress,'Look in Local category-based ASLs in other OUs');
     END IF;

     --Try to find local ASLs in other operating units
     --Local ASL: p_using_organization_id = p_using_organization_id
     --Other OUs: p_operating_unit = NULL
     --Will return rows if we can find a GA in other OUs which are listed in ASLs
     OPEN L_CATEGORY_ASL_DOCUMENTS_CSR(
              p_using_organization_id	=> p_using_organization_id);
     FETCH L_CATEGORY_ASL_DOCUMENTS_CSR INTO x_asl_id,
      p_using_organization_id,
      x_vendor_product_num,
      x_purchasing_uom,
      x_consigned_from_supplier_flag,
      x_enable_vmi_flag,
      x_sequence_num;

     IF L_CATEGORY_ASL_DOCUMENTS_CSR%FOUND
     THEN
        CLOSE L_CATEGORY_ASL_DOCUMENTS_CSR;
        l_progress := '030';
        IF g_debug_stmt THEN
           PO_DEBUG.debug_stmt(l_log_head,l_progress,'Found:');
           PO_DEBUG.debug_var(l_log_head,l_progress,'x_asl_id', x_asl_id);
           PO_DEBUG.debug_var(l_log_head,l_progress,'x_sequence_num', x_sequence_num);
        END IF;
        RETURN;
     END IF;

     CLOSE L_CATEGORY_ASL_DOCUMENTS_CSR;

     IF g_debug_stmt THEN
        --<Contract AutoSourcing FPJ>
        PO_DEBUG.debug_stmt(l_log_head,l_progress,'Look in Global category-based ASLs in current OU');
     END IF;

     --Now look for global ASLs in current operating unit
     --Global ASL: p_using_organization_id = -1
     --Current Operating Unit: p_operating_unit =l_operating_unit
     --Will return rows if vendor_site is not provided on ASL and in input parameter OR
     -- the site on ASL is in current OU and site_code match
     OPEN L_CATEGORY_ASL_IN_CUR_OU_CSR (
                     p_using_organization_id	=>-1);
     FETCH L_CATEGORY_ASL_IN_CUR_OU_CSR INTO x_asl_id,
      p_using_organization_id,
      x_vendor_product_num,
      x_purchasing_uom,
      x_consigned_from_supplier_flag,
      x_enable_vmi_flag;

     IF L_CATEGORY_ASL_IN_CUR_OU_CSR%FOUND
     THEN
        CLOSE L_CATEGORY_ASL_IN_CUR_OU_CSR;
        x_sequence_num := NULL;
        l_progress := '040';
        IF g_debug_stmt THEN
           PO_DEBUG.debug_stmt(l_log_head,l_progress,'Found:');
           PO_DEBUG.debug_var(l_log_head,l_progress,'x_asl_id', x_asl_id);
        END IF;
        RETURN;
     END IF;

     CLOSE L_CATEGORY_ASL_IN_CUR_OU_CSR;

     IF g_debug_stmt THEN
        --<Contract AutoSourcing FPJ>
        PO_DEBUG.debug_stmt(l_log_head,l_progress,'Look in Global category-based ASLs in other OUs');
     END IF;

     --Try to find Global ASLs in other operating units
     --Global ASL: p_using_organization_id = -1
     --Other OUs: p_operating_unit = NULL
     --Will return rows if we can find a GA in other OUs which are listed in ASLs
     OPEN L_CATEGORY_ASL_DOCUMENTS_CSR(
              P_using_organization_id	=> -1);
     FETCH L_CATEGORY_ASL_DOCUMENTS_CSR INTO x_asl_id,
      p_using_organization_id,
      x_vendor_product_num,
      x_purchasing_uom,
      x_consigned_from_supplier_flag,
      x_enable_vmi_flag,
      x_sequence_num;

     IF L_CATEGORY_ASL_DOCUMENTS_CSR %FOUND
     THEN
        CLOSE L_CATEGORY_ASL_DOCUMENTS_CSR;
        l_progress := '050';
        IF g_debug_stmt THEN
           PO_DEBUG.debug_stmt(l_log_head,l_progress,'Found:');
           PO_DEBUG.debug_var(l_log_head,l_progress,'x_asl_id', x_asl_id);
           PO_DEBUG.debug_var(l_log_head,l_progress,'x_sequence_num', x_sequence_num);
        END IF;
        RETURN;
     END IF;

     CLOSE L_CATEGORY_ASL_DOCUMENTS_CSR;

     x_vendor_product_num := NULL;
     x_purchasing_uom := NULL;
     x_consigned_from_supplier_flag := NULL;
     x_enable_vmi_flag := NULL;
     x_sequence_num := NULL;
     l_progress := '060';

     IF g_debug_stmt THEN
        --<Contract AutoSourcing FPJ>
        PO_DEBUG.debug_stmt(l_log_head,l_progress,'Matching Category-based ASL not found');
     END IF;

EXCEPTION
    WHEN OTHERS THEN
         IF g_debug_unexp THEN
            PO_DEBUG.debug_exc(l_log_head,l_progress);
         END IF;

        PO_MESSAGE_S.SQL_ERROR('CATEGORY_BASED_ASL_SOURCING', l_progress, sqlcode);
END CATEGORY_BASED_ASL_SOURCING;

--<PKGCOMP R12 Start>
  -------------------------------------------------------------------------------
  --Start of Comments
  --Name: process_req_qty
  --Pre-reqs:
  --  None.
  --Modifies:
  --  PO_REQ_DIST_INTERFACE.
  --Locks:
  --  None.
  --Function:
  -- This procedure applies the order modifiers on the line level quantity
  -- and pro-rates the change in the line level quantity to the distributions.
  -- It converts the requisition quantity according the UOM conversion rate
  -- passed as the parameter.
  -- It also performs rounding operations on the line level quantity depending
  -- on the rounding factor, passed as an argument.
  --Parameters:
  --IN:
  --p_mode
  -- Valid values are 'INVENTORY' or 'VENDOR'. It determines the type of Requisition
  --  been processed
  --p_request_id
  -- The request_id to identify all the records to be processed during the
  -- concurrent request
  --p_multi_dist_flag
  -- 'Multiple Distribution' Value provided by the user during the concurrent
  -- request submission
  --p_req_dist_sequence_id
  -- It identifies the distributions for a given requisition
  --p_min_order_qty
  -- Order Modifier: Minimum Order Quantity
  --p_fixed_lot_multiple
  -- Order Modifier: Fixed Lot Multiple
   --p_uom_conversion_rate
  -- Conversion rate used for converting quantity from one uom to another
  --p_rounding factor
  -- Rounding factor used rounding the Requisition line level quantity
  --p_enforce_full_lot_qty
  -- PO System parameters: Enforce Full Lot Quantities. Valid values are
  -- NONE, ADVISORY and MANDATORY
  --IN OUT:
  --x_quantity
  -- Requisition line level quantity.
  --Testing:
  -- Refer the Technical Design for 'ReqImport Packaging Requirement Compliance'
  --End of Comments
/*-----------------------------------------------------------------------------
  ALGORITHM
 => If the quantity on the Req line is less than the Minimum Order Quantity then
      Change the requisition quantity to Minimum Order Quantity.

 => If the quantity  on the Req line is not an integral multiple of Fixed Lot Multiple
      Increase the requisition quantity so that it becomes an integral Multiple.

 => Any change in the quantity due to application of Order Modifiers should
    be prorated to the distribution.

 => If p_uom_conversion_rate is not null then
      quantity on Req line and its distribution should be converted

 =>If it is a Purchase Requisition and p_rounding_factor is not null
        Perform Rounding.
   else if it is a Internal Requisition and p_rounding_factor is not null
        Check p_enforce_full_lot_qty should not be NONE.
        If it is not NONE then
              Perform Rounding.

 =>If rounding results in change of quantity then
      reflect the quantity change in the distribution with the max distribution_number.
 Note: Quantities on the distribution are only modified when all the three condition
       are satisfied.

       if the p_multi_dist_flag = 'Y'
       if p_req_dist_sequence_id is not null
       if distribution quantity is not null
 --------------------------------------------------------------------------------*/
PROCEDURE process_req_qty(p_mode                  IN VARCHAR2,
                          p_request_id            IN NUMBER,
                          p_multi_dist_flag       IN VARCHAR2,
                          p_req_dist_sequence_id  IN NUMBER,
                          p_min_order_qty         IN NUMBER,
                          p_fixed_lot_multiple    IN NUMBER,
                          p_uom_conversion_rate   IN NUMBER,
                          p_rounding_factor       IN NUMBER,
                          p_enforce_full_lot_qty  IN VARCHAR2,
                          x_quantity              IN OUT NOCOPY NUMBER)
  IS
    l_temp_quantity PO_REQUISITIONS_INTERFACE.quantity%type;
    l_remainder      NUMBER;
    l_adjust         NUMBER;
    l_progress       VARCHAR2(3);
    l_log_head CONSTANT VARCHAR2(100) := g_log_head || 'PROCESS_REQ_QTY';

  BEGIN
    l_progress := '001';

    IF g_debug_stmt THEN
      PO_DEBUG.debug_begin(l_log_head);
      PO_DEBUG.debug_var(l_log_head,l_progress,'p_request_id',p_request_id);
      PO_DEBUG.debug_var(l_log_head,l_progress,'p_multi_dist_flag',p_multi_dist_flag);
      PO_DEBUG.debug_var(l_log_head,l_progress,'p_min_order_qty',p_min_order_qty);
      PO_DEBUG.debug_var(l_log_head,l_progress,'p_fixed_lot_multiple',p_fixed_lot_multiple);
      PO_DEBUG.debug_var(l_log_head,l_progress,'p_req_dist_sequence_id',p_req_dist_sequence_id);
      PO_DEBUG.debug_var(l_log_head,l_progress,'p_uom_conversion_rate',p_uom_conversion_rate);
      PO_DEBUG.debug_var(l_log_head,l_progress,'p_rounding_factor',p_rounding_factor);
      PO_DEBUG.debug_var(l_log_head, l_progress, 'x_quantity', x_quantity);
    END IF;

         --* Converting the Line level Quantity according to the change in the UOM
    --  using the p_uom_conversion_rate
    --we have already called nvl on   p_uom_conversion_rate before calling this function.

	-- Keep the conversion here as it's still unclear for ASL
	-- what's the unit of measure using for Fixed Lot Multiplier
	if(p_mode <>'INVENTORY') THEN
		x_quantity := round((x_quantity * p_uom_conversion_rate), 18);
	END if;

    	l_progress := '010';

    	IF g_debug_stmt THEN
     		 PO_DEBUG.debug_stmt(l_log_head,l_progress,'After UOM Conversion');
		 PO_DEBUG.debug_var(l_log_head, l_progress, 'x_quantity', x_quantity);
   	 END IF;

     -- Keeping the requisition quantity in a temporary variable
    -- to determine the change in the quantity due to application
    -- of order modifiers.

	  l_temp_quantity := x_quantity;

	  l_progress := '020';

    	IF g_debug_stmt THEN
     		 PO_DEBUG.debug_stmt(l_log_head,l_progress,'After storing the quantity to temporary variable');
   	 END IF;


	 -- Applying the 'Minimum Order Quantity' order Modifier. If the quantity on the req
    -- line is less than the Minimum Order Quantity, change the requisition quantity to
    -- Minimum Order Quantity.

    --bug9143616
    IF (p_min_order_qty is not null and x_quantity < p_min_order_qty and nvl(p_enforce_full_lot_qty,'NONE') <> 'NONE') THEN
      x_quantity := p_min_order_qty;
    END IF;

    l_progress := '030';

    IF g_debug_stmt THEN
     		 PO_DEBUG.debug_stmt(l_log_head,l_progress,'After applying the minimum Order quantity');
		  PO_DEBUG.debug_var(l_log_head, l_progress, 'x_quantity', x_quantity);
    END IF;

    -- Applying the 'Fixed Lot Multiple' order Modifier. If the quantity  on the req
    -- line is not an integral multiple of Fixed Lot Multiple increase the requisition
    -- quantity so that it becomes an integral Multiple.

      IF ((nvl(p_fixed_lot_multiple, 0) <> 0) AND (nvl(p_enforce_full_lot_qty,'NONE') <> 'NONE')) THEN
      x_quantity := ceil(x_quantity / p_fixed_lot_multiple) *
                    p_fixed_lot_multiple;
    END IF;

    l_progress := '040';

    IF g_debug_stmt THEN
      PO_DEBUG.debug_stmt(l_log_head,l_progress,'After Applying the Fixed Lot Multiple Order Modifiers');
      PO_DEBUG.debug_var(l_log_head, l_progress, 'x_quantity', x_quantity);
    END IF;

    --* Distribution table is only updated if Multi_dist_flag is 'Y'

    --* Pro-rating the change in the line level quantity to the distribution level quantity
    --  only if there is a change in the line level quantity.

    --* If the Purchasing UOM is different then we convert the distribution level quantity
    --  using the conversion rate.
    IF ((p_multi_dist_flag = 'Y')
         AND (p_req_dist_sequence_id IS NOT NULL)
         AND ((l_temp_quantity <> x_quantity) OR p_uom_conversion_rate IS NOT NULL)) THEN

      UPDATE PO_REQ_DIST_INTERFACE prdi
      SET    prdi.quantity = round((prdi.quantity *p_uom_conversion_rate)*
                                   (1 + (x_quantity - l_temp_quantity) / l_temp_quantity)
                                   , 18)
       WHERE prdi.dist_sequence_id = p_req_dist_sequence_id
       AND   prdi.quantity is not null
       AND   prdi.request_id = p_request_id;

    END IF;


	if(p_mode ='INVENTORY') THEN
      		x_quantity := round((x_quantity * p_uom_conversion_rate), 18);
 	END if;
    l_progress := '060';

     IF g_debug_stmt THEN
      PO_DEBUG.debug_stmt(l_log_head,l_progress,'After making the changed to distributions');
    END IF;

    -- Applying the rounding factor to the requisition line level quantity
    -- Rounding Factor for Internal Requisition is only applied if
    -- Enforce Full Lot Quantities is set to ADVISORY or MANDATORY
    IF ( p_rounding_factor IS NOT NULL
         AND( (p_mode = 'VENDOR')
              OR ( p_mode ='INVENTORY'
                   AND (nvl(p_enforce_full_lot_qty,'NONE') <> 'NONE')
                 )
             )
       ) THEN

      l_remainder := x_quantity - floor(x_quantity);

      IF l_remainder >= p_rounding_factor THEN
        x_quantity := ceil(x_quantity);
        l_adjust   := 1 - l_remainder;
      ELSE
        x_quantity := floor(x_quantity);
        l_adjust   := -l_remainder;
      END IF;

      IF g_debug_stmt THEN
        PO_DEBUG.debug_stmt(l_log_head,l_progress,'Before applying the change in quantity due to rounding');
        PO_DEBUG.debug_var(l_log_head, l_progress, 'l_adjust', l_adjust);
      END IF;

      --* If rounding results in change of quantity we reflect the quantity change in the
      --  distribution with the max distribution_number.
      IF (p_multi_dist_flag = 'Y'
	   AND (p_req_dist_sequence_id IS NOT NULL)
           AND (l_adjust is NOT NULL )) THEN

        UPDATE PO_REQ_DIST_INTERFACE prdi
        SET    prdi.quantity = round((prdi.quantity + l_adjust), 18)
        WHERE  prdi.request_id = p_request_id
        AND    prdi.quantity is not null
        AND    prdi.dist_sequence_id = p_req_dist_sequence_id
        AND    distribution_number =
                  (SELECT MAX(distribution_number)
                   FROM   PO_REQ_DIST_INTERFACE
                   WHERE  prdi.request_id = p_request_id
                   AND    prdi.dist_sequence_id = p_req_dist_sequence_id);

      END IF;
      l_progress := '070';
      IF g_debug_stmt THEN
        PO_DEBUG.debug_stmt(l_log_head,l_progress,'After applying the change in quantity due to rounding');
      END IF;

    END IF;
    l_progress := '080';

    IF g_debug_stmt THEN
      PO_DEBUG.debug_stmt(l_log_head,l_progress,'After quantity rounding');
      PO_DEBUG.debug_var(l_log_head, l_progress, 'x_quantity', x_quantity);
      PO_DEBUG.debug_end(l_log_head);
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
       FND_MSG_PUB.add_exc_msg (g_pkg_name,'process_req_qty');
       IF g_debug_unexp THEN
          PO_DEBUG.debug_exc (l_log_head ,l_progress);
       END IF;
       RAISE;
  END process_req_qty;
--<PKGCOMP R12 End>

--<PKGCOMP R12 Start>
-- Added the parameter to get the parameter 'Multiple Distribution' Value provided by
-- the user during the concurrent request submission.

PROCEDURE reqimport_sourcing(
	x_mode			IN	VARCHAR2,
	x_request_id		IN	NUMBER,
        p_multi_dist_flag       IN      VARCHAR2
) IS
--<PKGCOMP R12 End>
	x_rowid				VARCHAR2(250) := '';
	x_item_id			NUMBER := NULL;
	x_category_id			NUMBER := NULL;
	x_dest_organization_id		NUMBER := NULL;
	x_dest_subinventory		VARCHAR2(10) := '';
	x_need_by_date			DATE := NULL;
	x_item_revision			VARCHAR2(3) := '';
	x_currency_code			VARCHAR2(15) := '';
	x_vendor_id			NUMBER := NULL;
	x_vendor_name			PO_VENDORS.VENDOR_NAME%TYPE := NULL; --Bug# 1813740 / Bug 2823775
	x_vendor_site_id		NUMBER := NULL;
	x_vendor_contact_id		NUMBER := NULL;
	x_source_organization_id	NUMBER := NULL;
	x_source_subinventory		VARCHAR2(10) := '';
	x_document_header_id		NUMBER := NULL;
	x_document_line_id		NUMBER := NULL;
	x_document_type_code		VARCHAR2(25) := '';
	x_document_line_num		NUMBER := NULL;
	x_buyer_id			NUMBER := NULL;
	x_vendor_product_num		VARCHAR2(240) := '';
	x_quantity			NUMBER := NULL;
	x_rate_type			VARCHAR2(30) := '';
	x_base_price			NUMBER := NULL;
	x_currency_price		NUMBER := NULL;
	x_discount			NUMBER := NULL;
	x_rate_date			DATE := NULL;
	x_rate				NUMBER := NULL;
	x_return_code			BOOLEAN := NULL;
	x_commodity_id			NUMBER := NULL;
	x_purchasing_uom		po_asl_attributes.purchasing_unit_of_measure%type;
	x_uom_code			po_requisitions_interface.uom_code%type;
	x_unit_of_measure		po_requisitions_interface.unit_of_measure%type;
	x_autosource_flag		po_requisitions_interface.autosource_flag%type;
	x_organization_id		NUMBER := NULL;
	x_conversion_rate		NUMBER := 1;
        x_item_buyer_id                 NUMBER;
        x_ga_flag                       VARCHAR2(1) := '';
        x_owning_org_id                 NUMBER;
        x_fsp_org_id                    NUMBER;
    --<Shared Proc FPJ START>
    x_suggested_vendor_site_code PO_VENDOR_SITES_ALL.vendor_site_code%TYPE;
    l_buyer_ok                   VARCHAR2(1);
    --<Shared Proc FPJ END>

    l_negotiated_by_preparer_flag   PO_LINES_ALL.NEGOTIATED_BY_PREPARER_FLAG%TYPE;  -- PO DBI FPJ

    --<PKGCOMP R12 Start>
    l_asl_id               PO_ASL_DOCUMENTS.ASL_ID%type;
    l_req_dist_sequence_id PO_REQUISITIONS_INTERFACE.req_dist_sequence_id%type;
    l_primary_uom          MTL_SYSTEM_ITEMS.primary_unit_of_measure%type;
    l_unit_of_issue        MTL_SYSTEM_ITEMS.unit_of_issue%type;
    l_rounding_factor      MTL_SYSTEM_ITEMS.rounding_factor%type;
    l_min_ord_qty          PO_ASL_ATTRIBUTES.min_order_qty%type;
    l_fixed_lot_multiple   PO_ASL_ATTRIBUTES.fixed_lot_multiple%type;
    l_uom_conversion_rate  NUMBER;
    l_enforce_full_lot_qty PO_SYSTEM_PARAMETERS.enforce_full_lot_quantities%type;
    l_interface_source_code  PO_REQUISITIONS_INTERFACE.interface_source_code%type;
    l_asl_purchasing_uom   PO_ASL_ATTRIBUTES.purchasing_unit_of_measure%type; --<Bug#5137508>
    --<PKGCOMP R12 End>

    --<R12 STYLES PHASE II START>
    l_line_type_id     PO_REQUISITION_LINES_ALL.line_type_id%TYPE;
    l_destination_type PO_REQUISITION_LINES_ALL.destination_type_code%TYPE;
    --<R12 STYLES PHASE II END>

    --<Shared Proc FPJ>
    --Changed the name of cursor from C1 to L_GET_REQ_INFO_VENDOR_CSR

    --<PKGCOMP R12 Start>
    -- Retrieving the dist_sequence_id for getting the distributions for the requisition

    Cursor L_GET_REQ_INFO_VENDOR_CSR is
	SELECT  rowid,
		item_id,
		category_id,  -- Bug 5524728
		destination_organization_id,
		destination_subinventory,
		nvl(need_by_date, sysdate),
		item_revision,
		currency_code,
		quantity,
		rate_type,
                suggested_vendor_id,
                suggested_vendor_name, --Bug# 1813740
                suggested_vendor_site_id,
                suggested_vendor_site,
                suggested_vendor_item_num,
                autosource_flag,
		uom_code,
		unit_of_measure,
                req_dist_sequence_id,
                interface_source_code
                --<R12 STYLES PHASE II START>
               ,line_type_id
               ,destination_type_code
                --<R12 STYLES PHASE II END>
		FROM	po_requisitions_interface
	WHERE 	autosource_flag in ('Y', 'P')
	AND	source_type_code = 'VENDOR'
	AND	item_id IS NOT NULL
	AND	request_id = x_request_id;
    --<PKGCOMP R12 End>

    --<Shared Proc FPJ>
    --Changed the name of cursor from C2 to L_GET_REQ_INFO_INV_CSR

    --<PKGCOMP R12 Start>
    -- For Application Of Order Modifiers and UOM Conversion we need to retrieve
    -- quantity, unit_of_measure, and also the req_dist_sequence_id for getting the
    -- distributions for the requisition.

    CURSOR L_GET_REQ_INFO_INV_CSR IS
	SELECT  rowid,
		decode(item_id, NULL, category_id, NULL),
		item_id,
		destination_subinventory,
		destination_organization_id,
                source_organization_id,
                source_subinventory,
		nvl(need_by_date, sysdate),
		quantity,
		unit_of_measure,
		req_dist_sequence_id,
                interface_source_code
                --<R12 STYLES PHASE II START>
               ,line_type_id
               ,destination_type_code
                --<R12 STYLES PHASE II END>
	FROM	po_requisitions_interface
	WHERE	autosource_flag in ('Y', 'P')
	AND	source_type_code = 'INVENTORY'
	AND 	destination_organization_id IS NOT NULL
	AND	request_id = x_request_id;
    --<PKGCOMP R12 End>

BEGIN
  g_root_invoking_module := 'REQIMPORT'; --<Bug#4936992>
  IF (x_mode = 'VENDOR') THEN

    OPEN L_GET_REQ_INFO_VENDOR_CSR;
    LOOP

	FETCH L_GET_REQ_INFO_VENDOR_CSR into
		x_rowid,
		x_item_id,
		x_category_id,
		x_dest_organization_id,
		x_dest_subinventory,
		x_need_by_date,
		x_item_revision,
		x_currency_code,
		x_quantity,
		x_rate_type,
                x_vendor_id,
                x_vendor_name,    --Bug# 1813740
                x_vendor_site_id,
                x_suggested_vendor_site_code, --<Shared Proc FPJ>
                x_vendor_product_num,
                x_autosource_flag,
		x_uom_code,
		x_unit_of_measure,
                --<PKGCOMP R12 Start>
               l_req_dist_sequence_id
               ,l_interface_source_code
                --<PKGCOMP R12 End>
                --<R12 STYLES PHASE II START>
               ,l_line_type_id
               ,l_destination_type
                --<R12 STYLES PHASE II END>
                ;

    EXIT WHEN L_GET_REQ_INFO_VENDOR_CSR%NOTFOUND;

	-- reinitialize values
    IF (x_autosource_flag = 'Y' or ( x_autosource_flag = 'P' and x_vendor_id
 is null)) THEN
                x_vendor_id := NULL;
                x_vendor_name := NULL;  -- Bug# 1813740
                x_vendor_site_id := NULL;
                x_suggested_vendor_site_code := NULL; --<Shared Proc FPJ>
                x_vendor_product_num := NULL;
    END IF;

    -- DBI FPJ ** Begin
    IF x_document_type_code = 'BLANKET' THEN

        SELECT NEGOTIATED_BY_PREPARER_FLAG INTO l_negotiated_by_preparer_flag FROM PO_LINES_ALL
                WHERE
                PO_HEADER_ID = x_document_header_id AND LINE_NUM = x_document_line_num;

    ELSIF x_document_type_code = 'QUOTATION' THEN

        l_negotiated_by_preparer_flag := 'Y';

    ELSE

        l_negotiated_by_preparer_flag := 'N';

    END IF;
    -- DBI FPJ ** End

        x_document_header_id := NULL;
	x_document_line_id := NULL;
	x_document_type_code := NULL;
	x_document_line_num := NULL;
	x_vendor_contact_id := NULL;
--	x_vendor_product_num := NULL;
	x_purchasing_uom := NULL;
	x_buyer_id := NULL;

        --<PKGCOMP R12 Start>
        l_asl_id               := NULL;
        l_uom_conversion_rate  := 1;
        l_fixed_lot_multiple   := NULL;
        l_min_ord_qty          := NULL;
        l_primary_uom          := NULL;
        l_rounding_factor      := NULL;
        l_enforce_full_lot_qty := NULL;
        --<PKGCOMP R12 End>

/*      Bug # 1507557.
        The value of x_conversion_rate has to be initialised so that the
        conversion value of sourced record will not be carried to the
        next record.
*/
      x_conversion_rate := 1;

      IF x_dest_organization_id IS NULL THEN

       -- Get organization_id from financials_system_parameters.

            SELECT   inventory_organization_id
            INTO     x_organization_id
            FROM     financials_system_parameters;

      ELSE
           x_organization_id := x_dest_organization_id;
      END IF;

     IF (x_autosource_flag = 'Y' or ( x_autosource_flag = 'P' and x_vendor_id
 is null)) THEN
        --<PKGCOMP R12 Start>
        --Added the parameter to get the asl_id for the ASL so that we can retrieve
	-- the order modifiers later in the procedure.
        --<PKGCOMP R12 End>

	autosource(
		'VENDOR',
		'REQ',
		x_item_id,
		x_category_id,   -- Bug# 5524728,
		x_dest_organization_id,
		x_dest_subinventory,
		x_need_by_date,
		x_item_revision,
		x_currency_code,
		x_vendor_id,
		x_vendor_site_id,
		x_vendor_contact_id,
		x_source_organization_id,
		x_source_subinventory,
		x_document_header_id,
		x_document_line_id,
		x_document_type_code,
		x_document_line_num,
		x_buyer_id,
		x_vendor_product_num,
		x_purchasing_uom,
                l_asl_id  --<PKGCOMP R12>
                --<R12 STYLES PHASE II START>
               ,null,
                l_line_type_id,
                l_destination_type,
                null
                --<R12 STYLES PHASE II END>
                );
     ELSE


            -- Get buyer_id from item definition.  If we cannot get buyer_id from
            -- the item definition then we will try to get it from the source document.

            IF (x_item_id IS NOT NULL) THEN

               SELECT   msi.buyer_id
               INTO     x_buyer_id
               FROM     mtl_system_items msi
               WHERE    msi.inventory_item_id = x_item_id
               AND      msi.organization_id = x_organization_id;

               x_item_buyer_id := x_buyer_id;

            END IF;

            --<Shared Proc FPJ START>
            --To accommodate Planning calls: We do vendor site sourcing when
            --vendor site code is provided (vendor site_id is not provided)

            --<PKGCOMP R12 Start>
            -- Earlier hardcoded value of NULL was passed for asl_id in document_sourcing.
            -- But now we get back the value from document_sourcing procedure in l_asl_id.
            --<PKGCOMP R12 End>

	        IF (x_autosource_flag = 'P' and x_vendor_id is not null
                  and x_vendor_site_id is null
                  and x_suggested_vendor_site_code is not null) THEN

                  document_sourcing(
                	x_item_id             	 	=> x_item_id,
                	x_vendor_id           		=> x_vendor_id,
                	x_destination_doc_type	    => 'REQ',
                	x_organization_id     		=> x_organization_id,
                	x_currency_code       		=> x_currency_code,
                	x_item_rev              	=> x_item_revision,
                	x_autosource_date     		=> x_need_by_date,
                	x_vendor_site_id     		=> x_vendor_site_id,
                	x_document_header_id	    => x_document_header_id,
                	x_document_type_code	    => x_document_type_code,
                	x_document_line_num 	    => x_document_line_num,
                	x_document_line_id   		=> x_document_line_id,
                	x_vendor_contact_id  		=> x_vendor_contact_id,
                	x_vendor_product_num	    => x_vendor_product_num,
                	x_buyer_id          		=> x_buyer_id,
                	x_purchasing_uom    		=>  x_purchasing_uom,
                        x_asl_id                    => l_asl_id, --<PKGCOMP R12>
                	x_multi_org        	    	=> 'N',
	        	p_vendor_site_sourcing_flag =>  'Y',
 	        	p_vendor_site_code  		=> x_suggested_vendor_site_code,
			p_category_id                =>x_category_id -- Bug# 5524728
                        --<R12 STYLES PHASE II START>
                       ,p_line_type_id     => l_line_type_id,
                        p_purchase_basis   => NULL,
                        p_destination_type => l_destination_type,
                        p_style_id         => NULL
                        --<R12 STYLES PHASE II END>
                        );
	        ELSE
                   --Its not required to do vendor site sourcing
 	           document_sourcing(
                	x_item_id             	 	=> x_item_id,
                	x_vendor_id           		=> x_vendor_id,
                	x_destination_doc_type	    => 'REQ',
                	x_organization_id     		=> x_organization_id,
                	x_currency_code       		=> x_currency_code,
                	x_item_rev              	=> x_item_revision,
                	x_autosource_date     		=> x_need_by_date,
                	x_vendor_site_id     		=> x_vendor_site_id,
                	x_document_header_id	    => x_document_header_id,
                	x_document_type_code	    => x_document_type_code,
                	x_document_line_num 	    => x_document_line_num,
                	x_document_line_id   		=> x_document_line_id,
                	x_vendor_contact_id  		=> x_vendor_contact_id,
                	x_vendor_product_num	    => x_vendor_product_num,
                	x_buyer_id          		=> x_buyer_id,
                	x_purchasing_uom    		=>  x_purchasing_uom,
                        x_asl_id                    => l_asl_id, --<PKGCOMP R12>
                	x_multi_org        	    	=> 'N',
	        	p_vendor_site_sourcing_flag =>  'N',
 	        	p_vendor_site_code  		=> NULL,
			p_category_id                =>x_category_id -- Bug# 5524728
                        --<R12 STYLES PHASE II START>
                       ,p_line_type_id     => l_line_type_id,
                        p_purchase_basis   => NULL,
                        p_destination_type => l_destination_type,
                        p_style_id         => NULL
                        --<R12 STYLES PHASE II END>
                        );
             END IF;
             --<Shared Proc FPJ END>

              --<Shared Proc FPJ START>
              IF x_document_header_id is not null
                 AND x_buyer_id is NOT NULL
              THEN
                      --The buyer on Source Document should be in the same business group as
                     --the requesting operating unit(current OU) or the profile option HR: Cross
                     --Business Group should be set to 'Y'. These two conditions are checked in
                     --view definition of per_people_f
                     BEGIN
                             SELECT 'Y'
                             INTO l_buyer_ok
                             FROM per_people_f ppf
                             WHERE x_buyer_id = ppf.person_id
                             AND trunc(sysdate) between ppf.effective_start_date
                                     AND NVL(ppf.effective_end_date, sysdate +1);
                     EXCEPTION WHEN OTHERS THEN
                              x_buyer_id := NULL;
                     END;

              END IF;
              --<Shared Proc FPJ END>
        END IF;

        --<PKGCOMP R12 Start>

        --* Removing the code for bug 3810029 fix as we call the
        --  pocis_unit_of_measure for UOM defaulting before calling
        --  the sourcing procedure in reqimport code.

        -- We modify the quantity on the req line only if it is not null
        IF x_quantity IS NOT NULL THEN
            --* Retrieving the primary_unit_of_measure and rounding_factor
            -- from Item Masters

            BEGIN
              SELECT msi.primary_unit_of_measure, msi.rounding_factor
              INTO   l_primary_uom, l_rounding_factor
              FROM   mtl_system_items msi
              WHERE  msi.inventory_item_id = x_item_id
              AND    msi.organization_id = x_organization_id;
            EXCEPTION
              WHEN OTHERS THEN
                l_primary_uom     := NULL;
                l_rounding_factor := NULL;
            END;

        --* Retrieving the min_order_qty, fixed_lot_multiple from PO_ASL_ATTRIBUTES table,
        --  only if primary_uom of the item is same as the UOM mentioned on the requisition.

        --* This if condition is required as Order Modifiers will only be applied in case
        --  the above condition is true.

        --  <Bug#4025605 Start>
        --* We apply the order modifiers to requisitions generated from Inventory only
        --  (Interface source code = 'INV')


            IF (l_asl_id IS NOT NULL AND l_interface_source_code in ('INV','MRP') ) THEN
              BEGIN
                SELECT min_order_qty, fixed_lot_multiple, purchasing_unit_of_measure
                INTO   l_min_ord_qty, l_fixed_lot_multiple, l_asl_purchasing_uom
                FROM   PO_ASL_ATTRIBUTES
                WHERE  ASL_ID = l_asl_id;
              EXCEPTION
                WHEN OTHERS THEN
                  l_min_ord_qty := NULL;
                  l_fixed_lot_multiple := NULL;
              END;
              IF x_unit_of_measure IS NULL OR (x_unit_of_measure <> l_primary_uom) THEN
                  l_min_ord_qty := NULL;
                  l_fixed_lot_multiple := NULL;
              END IF;
              --<Bug#5137508 Start>
              --We will be applying the ASL Purchasing UOM if the Sourcing routine
              --does not fetch any Blanket Agreement. This is because Contract Agreement
              --wont have an UOM and we would pick the UOM from the
              IF  x_document_line_id IS NULL THEN
                x_purchasing_uom := l_asl_purchasing_uom;
              END IF;
              --<Bug#5137508 End>
            END IF;
        --  <Bug#4025605 End>
            --* Get the conversion rate between the Req's UOM and the Sourcing document's UOM
            --  if the source document exists else get the conversion rate between Req's UOM and
            --  ASL's Purchasing UOM if an ASL exists.

            --* Sourcing Document UOM is given preference over the ASL's Purchasing UOM.

            IF nvl(x_purchasing_uom, x_unit_of_measure) <> x_unit_of_measure THEN
              l_uom_conversion_rate := nvl(po_uom_s.po_uom_convert(x_unit_of_measure,
                                                                   x_purchasing_uom,
                                                                   x_item_id),1);
            END IF;
             begin
 	                   SELECT enforce_full_lot_quantities
 	                   INTO l_enforce_full_lot_qty
 	                   FROM po_system_parameters;
 	            exception when others then
 	              l_enforce_full_lot_qty := null;
 	            end;
            -- Calling the procedure for applying order modifier, quantity conversion and rounding
            PO_AUTOSOURCE_SV.process_req_qty(p_mode                 => x_mode,
                                             p_request_id           => x_request_id,
                                             p_multi_dist_flag      => p_multi_dist_flag,
                                             p_req_dist_sequence_id => l_req_dist_sequence_id,
                                             p_min_order_qty        => l_min_ord_qty,
                                             p_fixed_lot_multiple   => l_fixed_lot_multiple,
                                             p_uom_conversion_rate  => l_uom_conversion_rate,
                                             p_rounding_factor      => l_rounding_factor,
                                             p_enforce_full_lot_qty => l_enforce_full_lot_qty,
                                             x_quantity             => x_quantity);
        END IF;
        --<PKGCOMP R12 End>



   -- Bug 1813740 - When suggested vendor name was populated in the Interface
   -- table and if Sourcing takes place and brings in a new Vendor Id the
   -- Vendor Name was not changed to that of the new vendor Id. To avoid this
   -- we now NULL out the vendor name when autosource flag is 'Y'. The logic in
   -- pocis.opc takes care of populating the suggested_vendor_name if it
   -- is NULL.
   -- Bug 3669203: The vendorname should only be nulled out if autosourcing
   -- brought back a new vendor.
   -- Bug 3810029 : changed the uom update : see above

   --<PKGCOMP R12 Start>
      -- Update the po_requisitions_interface table with the calculated quantity returned
      -- by the above procedure instead of computing the new quantity in the update statement.

	UPDATE  po_requisitions_interface
	SET	suggested_vendor_id = nvl(x_vendor_id,suggested_vendor_id),
		suggested_vendor_name = decode(x_vendor_id, null , suggested_vendor_name, x_vendor_name),
		suggested_vendor_site_id = nvl(x_vendor_site_id,suggested_vendor_site_id),
		suggested_buyer_id = nvl(suggested_buyer_id, x_buyer_id),
		autosource_doc_header_id = x_document_header_id,
		autosource_doc_line_num	= x_document_line_num,
		document_type_code = x_document_type_code,
                -- Bug 4523369 START
                -- If autosourcing did not return a vendor site, keep the
                -- current vendor contact.
		suggested_vendor_contact_id =
                  decode(x_vendor_site_id,
                         null, suggested_vendor_contact_id,
                         x_vendor_contact_id),
                -- Bug 4523369 END
		suggested_vendor_item_num =
			nvl(suggested_vendor_item_num, x_vendor_product_num),
		unit_of_measure = nvl(x_purchasing_uom,nvl(x_unit_of_measure,unit_of_measure)),
		quantity = x_quantity, --<PKGCOMP R12>
                negotiated_by_preparer_flag = l_negotiated_by_preparer_flag   -- DBI FPJ
 	WHERE	rowid = x_rowid;

   --<PKGCOMP R12 End>
    END LOOP;
    CLOSE L_GET_REQ_INFO_VENDOR_CSR;

    /* 7234465 - Imported Requisitions were getting Reserved Even when the Source BPA is Encumbered. */
	/* This sql will set the Prevent Encumbrance Flag to Y, if BPA is Encumbered. */
	UPDATE po_Requisitions_InterFace po_Requisitions_InterFace
	SET    po_Requisitions_InterFace.Prevent_Encumbrance_Flag = 'Y'
	WHERE  po_Requisitions_InterFace.AutoSource_Doc_Header_Id IS NOT NULL
	AND    po_Requisitions_Interface.request_id = x_request_id
       AND EXISTS (SELECT 'BPA Encumbered'
                   FROM   po_Distributions_All d,
                          po_Headers_All h
                   WHERE  h.po_Header_Id = po_Requisitions_InterFace.AutoSource_Doc_Header_Id
                          AND h.po_Header_Id = d.po_Header_Id
                          AND h.Type_LookUp_Code = 'BLANKET'
                          AND d.Line_Location_Id IS NULL
                          AND d.po_Release_Id IS NULL
                          AND Nvl(d.Encumbered_Flag,'N') = 'Y');
	/*7234465 End*/

  ELSIF (x_mode = 'INVENTORY') THEN

    --<PKGCONS Start>
    --Fecthing the value of ENFORCE_FULL_LOT_QUANTITY for determining whether
    --UOM conversion and rounding operations are to be performed on the
    --Requisition.
    SELECT enforce_full_lot_quantities
    INTO l_enforce_full_lot_qty
    FROM po_system_parameters;
    --<PKGCONS End>

    OPEN L_GET_REQ_INFO_INV_CSR;
    LOOP


	x_buyer_id := NULL;
	x_source_organization_id := NULL;
	x_source_subinventory := NULL;
	x_document_header_id := NULL;
	x_document_line_id := NULL;
	x_document_type_code := NULL;
	x_document_line_num := NULL;
	x_vendor_product_num := NULL;
	x_purchasing_uom := NULL;
        --<PKGCOMP R12 Start>
        x_quantity             := NULL;
        x_unit_of_measure      := NULL;
        l_uom_conversion_rate  := 1;
        l_fixed_lot_multiple   := NULL;
        l_min_ord_qty          := NULL;
        l_unit_of_issue        := NULL;
        l_req_dist_sequence_id := NULL;
        l_rounding_factor      := NULL;
        l_asl_id               := NULL;
        --<PKGCOMP R12 End>


	FETCH L_GET_REQ_INFO_INV_CSR into
		x_rowid,
		x_commodity_id,
		x_item_id,
		x_dest_subinventory,
		x_dest_organization_id,
		x_source_organization_id,
		x_source_subinventory,
		x_need_by_date,
                --<PKGCOMP R12 Start>
                x_quantity,
                x_unit_of_measure,
                l_req_dist_sequence_id,
                l_interface_source_code
                --<PKGCOMP R12 End>
                --<R12 STYLES PHASE II START>
               ,l_line_type_id
               ,l_destination_type
                --<R12 STYLES PHASE II END>
                ;


	EXIT WHEN L_GET_REQ_INFO_INV_CSR%NOTFOUND;

        --<PKGCOMP R12 Start>
        -- Added the parameter to get the asl_id for the ASL so that we can retrieve the
        -- order modifiers later in the procedure.
        --<PKGCOMP R12 End>
	autosource(
		'INVENTORY',
		'REQ',
		x_item_id,
		x_commodity_id,
		x_dest_organization_id,
		x_dest_subinventory,
		x_need_by_date,
		x_item_revision,
		x_currency_code,
		x_vendor_id,
		x_vendor_site_id,
		x_vendor_contact_id,
		x_source_organization_id,
		x_source_subinventory,
		x_document_header_id,
		x_document_line_id,
		x_document_type_code,
		x_document_line_num,
		x_buyer_id,
		x_vendor_product_num,
		x_purchasing_uom,
		l_asl_id --<PKGCOMP R12>
                --<R12 STYLES PHASE II START>
               ,null,
                l_line_type_id,
                l_destination_type,
                null
                --<R12 STYLES PHASE II END>
                );

	--<PKGCOMP R12 Start>
        --Retrieving the primary_unit_of_measure and rounding_factor
        --from Item Masters of source organisation

	BEGIN
          SELECT msi.primary_unit_of_measure, msi.rounding_factor, msi.unit_of_issue
          INTO   l_primary_uom, l_rounding_factor, l_unit_of_issue
          FROM   mtl_system_items msi
          WHERE  msi.inventory_item_id = x_item_id
          AND    msi.organization_id = x_source_organization_id;
        EXCEPTION
          WHEN OTHERS THEN
            l_primary_uom     := NULL;
            l_rounding_factor := NULL;
            l_unit_of_issue   := NULL;
        END;

        -- We can apply the order modifiers or do any processing on the req quantity
        -- only if it is not null
        IF x_quantity IS NOT NULL THEN
            --* We retrieve and apply order modifiers <min_order_qty, fixed_lot_multiple >
            --  1. if primary_uom of  the item is same as the UOM mentioned on the requisition
            --  2. if  requisitions are generated from Inventory(Interface source code = 'INV') <Bug#4025605 Start>

            --* The values from MTL_ITEM_SUB_INVENTORIES take precedence over MTL_SYSTEM_ITEMS.

            IF (l_primary_uom = x_unit_of_measure
                 AND l_interface_source_code = 'INV')THEN

                IF x_source_subinventory IS NOT NULL THEN
                    BEGIN
                        SELECT mssi.fixed_lot_multiple, mssi.minimum_order_quantity
                        INTO   l_fixed_lot_multiple, l_min_ord_qty
                        FROM   MTL_ITEM_SUB_INVENTORIES mssi
                        WHERE  mssi.secondary_inventory = x_source_subinventory
                        AND    mssi.inventory_item_id = x_item_id
                        AND    mssi.organization_id = x_source_organization_id;
                    EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                           l_fixed_lot_multiple := null;
                           l_min_ord_qty        := null;
                    END;
                END IF; --x_source_subinventory IS NOT NULL

                IF ((l_fixed_lot_multiple is null) OR (l_min_ord_qty is null)) THEN
                    -- In the exception we are intentionally doing nothing because
                    -- we want to retain the data from the previous query even if this
                    -- query raises an exception.
                    BEGIN
                        SELECT nvl(l_fixed_lot_multiple,msi.fixed_lot_multiplier),
                               nvl(l_min_ord_qty, msi.minimum_order_quantity)
                        INTO   l_fixed_lot_multiple, l_min_ord_qty
                        FROM   MTL_SYSTEM_ITEMS msi
                        WHERE  msi.inventory_item_id = x_item_id
                        AND    msi.organization_id = x_source_organization_id;
                    EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                             NULL;
                    END;
                END IF; --(l_fixed_lot_multiple is null) OR (l_min_ord_qty is null)

            END IF; --_primary_uom = x_unit_of_measure

            --* Get the conversion rate between the Req's UOM and the unit of issue.
            --  only if enforce_full_lot_quantities is set to 'ADVISORY' or 'MANDATORY'
            IF ( (nvl(l_unit_of_issue, x_unit_of_measure) <> x_unit_of_measure)
                 AND (nvl(l_enforce_full_lot_qty,'NONE') <> 'NONE')
               ) THEN
                 l_uom_conversion_rate := nvl(po_uom_s.po_uom_convert(x_unit_of_measure,
                                                                      l_unit_of_issue,
                                                                      x_item_id),1);
            END IF;

            -- Calling the procedure for applying order modifier, quantity conversion and rounding
            PO_AUTOSOURCE_SV.process_req_qty(p_mode                 => x_mode,
                                             p_request_id           => x_request_id,
                                             p_multi_dist_flag      => p_multi_dist_flag,
                                             p_req_dist_sequence_id => l_req_dist_sequence_id,
                                             p_min_order_qty        => l_min_ord_qty,
                                             p_fixed_lot_multiple   => l_fixed_lot_multiple,
                                             p_uom_conversion_rate  => l_uom_conversion_rate,
                                             p_rounding_factor      => l_rounding_factor,
                                             p_enforce_full_lot_qty => l_enforce_full_lot_qty,
                                             x_quantity             => x_quantity);

        END IF;
        -- Updating the quantity and the unit_of_measure in the po_requisitions_interface
        -- after the quantity conversion.

        -- We need to put the l_enforce_full_lot_qty in the decode as there should be no
        -- UOM conversion if enforce_full_lot_quantities is set to 'NONE'
        UPDATE po_requisitions_interface
        SET source_organization_id = x_source_organization_id,
            source_subinventory    = x_source_subinventory,
            suggested_buyer_id     = nvl(suggested_buyer_id, x_buyer_id),
            quantity               = x_quantity,
            unit_of_measure        = decode(nvl(l_enforce_full_lot_qty, 'NONE'),
                                               'NONE',x_unit_of_measure,
                                               nvl(l_unit_of_issue,x_unit_of_measure))
        WHERE rowid = x_rowid;
        --<PKGCOMP R12 End>

    END LOOP;
    CLOSE L_GET_REQ_INFO_INV_CSR;

  END IF;
  g_root_invoking_module := NULL; --<Bug#4936992>
END reqimport_sourcing;


/* Cto Changes FPH. For the given item id this procedure gives all the valid vendor ,
 * vendor sites and Asl ids from the global Asl.
*/

Procedure Get_All_Item_Asl(
                        x_item_id                    IN   Mtl_system_items.inventory_item_id%type,
                        x_using_organization_id      IN    Number, --will be -1
                        X_vendor_details             IN OUT NOCOPY PO_AUTOSOURCE_SV.vendor_record_details,
			x_return_status              OUT NOCOPY varchar2,
			x_msg_count                  OUT NOCOPY Number,
			x_msg_data                   OUT NOCOPY Varchar2 ) is

CURSOR C is
SELECT   pasl.vendor_id,
         pasl.vendor_site_id,
         pasl.asl_id,
         pasl.primary_vendor_item,
         paa.purchasing_unit_of_measure
          FROM     po_approved_supplier_lis_val_v pasl,
                   po_asl_attributes paa,
           	   po_asl_status_rules_v pasr
          WHERE    pasl.item_id = x_item_id
          AND     (pasl.using_organization_id IN
                                        (-1, x_using_organization_id))
          AND      pasl.asl_id = paa.asl_id
     	  AND      pasr.business_rule like '2_SOURCING'
      	  AND      pasr.allow_action_flag like 'Y'
      	  AND      pasr.status_id = pasl.asl_status_id
          AND      paa.using_organization_id =
                        (SELECT  max(paa2.using_organization_id)
			 FROM    po_asl_attributes paa2
                         WHERE   paa2.asl_id = pasl.asl_id
                         AND     (pasl.using_organization_id IN
                                                (-1,x_using_organization_id)))
          ORDER BY pasl.using_organization_id DESC;
n number :=0;
begin
         x_msg_data := 'No error';
         x_msg_count := 0;
         x_return_status := FND_API.G_RET_STS_SUCCESS;
        x_vendor_details.DELETE;
        open c;
        loop
                n := n+1;
                fetch c into x_vendor_details(n);
                exit when c%notfound;
        end loop;
  exception
when others then
x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
FND_MSG_PUB.Count_And_Get
  	 (p_count => x_msg_count
   	 ,p_data  => x_msg_data
    	 );
end;

/* Cto Changes FPH. This is a wrapper for the procedure document_sourcing to give only
 * the Blanket PO information. Returns x_doc_Return as Y if it has any blankets.
 * The parameters x_destination_doc_type,x_currency_code,x_autosource_date can be null.
 * The parameter x_item_rev must be sent if you want the blanket info which has this
 * item revision. x_organization_id should be -1 if you want the global asls only.
*/

Procedure blanket_document_sourcing(
	 	x_item_id               IN      NUMBER,
                x_vendor_id             IN      NUMBER,
                x_destination_doc_type  IN      VARCHAR2,
                x_organization_id       IN      NUMBER,
                x_currency_code         IN      VARCHAR2,
                x_item_rev              IN      VARCHAR2,
                x_autosource_date       IN      DATE,
                x_vendor_site_id        IN OUT NOCOPY  NUMBER,
                x_document_header_id    IN OUT NOCOPY  NUMBER,
                x_document_type_code    IN OUT NOCOPY  VARCHAR2,
                x_document_line_num     IN OUT NOCOPY  NUMBER,
		x_document_line_id      IN OUT NOCOPY  NUMBER,
                x_vendor_contact_id     IN OUT NOCOPY  NUMBER,
                x_vendor_product_num    IN OUT NOCOPY  VARCHAR2,
                x_buyer_id              IN OUT NOCOPY  NUMBER,
                x_purchasing_uom        IN OUT NOCOPY  VARCHAR2, -- should be sent since if the value obtained from get_all_item_asl is null this is used.
                x_return_status 	   OUT NOCOPY varchar2,
                 x_msg_count     	   OUT NOCOPY Number,
                 x_msg_data      	   OUT NOCOPY Varchar2,
		 x_doc_return		   OUT NOCOPY Varchar2,
                x_asl_id 	       	IN     NUMBER default null,
                x_multi_org        	IN     VARCHAR2 default 'N') --cto sends Y  Cto Changes FPH
IS
x_type_lookup_code varchar2(25);

--<PKGCOMP R12 Start>
-- Added a variable for making local copy of x_asl_id It is required because now x_asl_id
-- would be a IN OUT parameter in document_sourcing procedure, which  return a value.
-- In order to maintain the existing flow we make a local copy and pass it to the document_sourcing.

l_local_asl_id PO_ASL_DOCUMENTS.asl_id%type;
--<PKGCOMP R12 End>
begin
	x_msg_data :='No error';
        x_msg_count := 0;
        x_return_status := FND_API.G_RET_STS_SUCCESS;
	x_doc_return := 'Y';
	--<PKGCOMP R12 Start>
	l_local_asl_id := x_asl_id;
	--<PKGCOMP R12 End>
    --<Shared Proc FPJ START>
    --We are doing only document sourcing so the p_vendor_site_sourcing_flag
    --is 'N'.
    document_sourcing(
                        x_item_id	           =>x_item_id,
               	        x_vendor_id		   =>x_vendor_id,
               	        x_destination_doc_type	   =>x_destination_doc_type,
                	x_organization_id 	   =>x_organization_id,
                	x_currency_code 	   =>x_currency_code,
                	x_item_rev	           =>x_item_rev,
                	x_autosource_date 	   =>x_autosource_date,
                	x_vendor_site_id 	   =>x_vendor_site_id,
                	x_document_header_id	   =>x_document_header_id,
                	x_document_type_code 	   =>x_document_type_code,
                	x_document_line_num	   =>x_document_line_num,
                	x_document_line_id	   =>x_document_line_id,
                	x_vendor_contact_id	   =>x_vendor_contact_id,
                	x_vendor_product_num 	   =>x_vendor_product_num,
                	x_buyer_id 		   =>x_buyer_id,
                	x_purchasing_uom	   =>x_purchasing_uom,
                	x_asl_id	           =>l_local_asl_id,--<PKGCOMP R12>
                	x_multi_org		   =>x_multi_org,
                	p_vendor_site_sourcing_flag =>'N',
                	p_vendor_site_code	   =>NULL);

    --<Shared Proc FPJ END>
	IF x_document_header_id is NOT NULL THEN --<Shared Proc FPJ>
	  select poh.type_lookup_code
	  into x_type_lookup_code
	  from po_headers_all poh
        where poh.po_header_id = x_document_header_id;

   	 /* If it is not blanket then return null */
     if (x_type_lookup_code <>  'BLANKET') THEN
		x_doc_return := 'N';
	 end if;
    ELSE
        x_doc_return := 'N'; --<Shared Proc FPJ>
    END IF;

exception
when others then
x_doc_return := 'N'; -- no rows were obtained from document_sourcing
x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
FND_MSG_PUB.Count_And_Get
  	 (p_count => x_msg_count
   	 ,p_data  => x_msg_data
    	 );
end blanket_document_sourcing;

--------------------------------------------------------------------------------
--Start of Comments
--Name        : is_dup_vendor_record
--Pre-reqs    : None
--Modifies    : None
--Locks       : None
--Function    : To determine if a given (vendor, vendor site) record is prent in
--              a given list of (vendor, vendor site) records.
--Parameter(s):
-- IN         : p_vendor_id - The Vendor id that needs to be checked in the list
--              p_vendor_site_id - The Vendor Site that needs to be checked.
--              p_vendor_id_list - The list of vendors where the check is
--                                 required to be done.
--              p_vendor_site_id_list - The list of vendors sites where the
--                                 check is required to be done.
--
-- IN OUT     : None
--Returns     : BOOLEAN
--                TRUE: If the (vendor, vendor site) record belongs to the given
--                      list of (vendor, vendor site) records.
--                FALSE: Otherwise
--Notes       : None
--Testing     : None
--End of Comments
--------------------------------------------------------------------------------
FUNCTION is_dup_vendor_record(p_vendor_id           IN NUMBER,
                              p_vendor_site_id      IN NUMBER,
                              p_vendor_id_list      IN po_tbl_number,
                              p_vendor_site_id_list IN po_tbl_number)
RETURN BOOLEAN
IS
BEGIN
  IF (p_vendor_id_list.FIRST IS NOT NULL) THEN
    FOR i IN p_vendor_id_list.FIRST..p_vendor_id_list.LAST LOOP
      IF (p_vendor_id_list(i) = p_vendor_id AND
          nvl(p_vendor_site_id_list(i), -1) = nvl(p_vendor_site_id, -1)) THEN
        RETURN TRUE;
      END IF;
    END LOOP;
  END IF;
  RETURN FALSE;
END is_dup_vendor_record;

--------------------------------------------------------------------------------
--Start of Comments
--Name        : is_vendor_site_outside_OU
--Pre-reqs    : None
--Modifies    : None
--Locks       : None
--Function    : To determine if a vendor site belongs to a given Operating Unit.
--Parameter(s):
-- IN         : p_vendor_site_id - The Vendor Site that needs to be checked.
--              p_ou_id - The ID of the Operating Unit where the check is
--                        required.
-- IN OUT     : None
--Returns     : BOOLEAN
--                TRUE: If the vendor site belongs to the given OU
--                FALSE: Otherwise
--Notes       : None
--Testing     : None
--End of Comments
--------------------------------------------------------------------------------
FUNCTION is_vendor_site_outside_OU(p_vendor_site_id IN NUMBER,
                                   p_ou_id          IN NUMBER)
RETURN BOOLEAN
IS
  l_vendor_site_status VARCHAR2(20);
BEGIN
  SELECT 'Site is within OU'
  INTO l_vendor_site_status
  FROM po_vendor_sites_all
  WHERE vendor_site_id = p_vendor_site_id
    AND org_id = p_ou_id;

  RETURN FALSE;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN TRUE;
  WHEN OTHERS THEN
    RAISE;
END is_vendor_site_outside_OU;

--------------------------------------------------------------------------------
--Start of Comments
--Name        : validate_vendor_sites
--Pre-reqs    : None
--Modifies    : None
--Locks       : None
--Function    : To validate that the vendor site is active and is a valid
--              purchasing or rfq_only site. If the vendor site is invalid, then
--              it is nulled out. We do not want to skip the whole (supplier,
--              supplier site) record if just the site is invalid.
--Parameter(s):
-- IN         : None
-- IN OUT     : px_vendor_site_id_list - The list of vendor sites found for the
--                                       given commodity. The site is nulled out
--                                       if found invalid.
--Returns     : None
--Notes       : None
--Testing     : None
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE validate_vendor_sites(px_vendor_site_id_list IN OUT NOCOPY po_tbl_number)
IS
 l_vendor_site_status VARCHAR2(20);
BEGIN
  IF (px_vendor_site_id_list.FIRST IS NULL) THEN
    RETURN;
  END IF;

  FOR i IN px_vendor_site_id_list.FIRST..px_vendor_site_id_list.LAST LOOP
    IF (px_vendor_site_id_list(i) IS NOT NULL) THEN
      BEGIN
        SELECT 'Valid supplier site'
        INTO   l_vendor_site_status
        FROM   po_vendor_sites_all
        WHERE  vendor_site_id = px_vendor_site_id_list(i)
          AND  (purchasing_site_flag = 'Y' OR rfq_only_site_flag = 'Y')
          AND  sysdate <= nvl(inactive_date, sysdate);
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          -- Invalid vendor site, null it out
          px_vendor_site_id_list(i) := NULL;
        WHEN OTHERS THEN
          RAISE;
      END;
    END IF;
  END LOOP;
END validate_vendor_sites;

---------------------------------------------------------------------------------------
--Start of Comments
--Name        : get_services_asl_list
--
--Pre-reqs    : None
--
--Modifies    : None
--
--Locks       : None
--
--Function    : This procedure will obtain a list of ASL, their associated purchasing
--              documents and pricing information.
--
--Parameter(s):
--
--IN          : p_job_id              : The job for which we need to retrieve the ASL Documents
--              p_category_id         : The category for which we need to retreive the ASL's
--              p_order_type_lookup_code : The value basis of Line type on the Document Line
--                p_start_date          : Assignment start date to determine pricing
--              p_deliver_to_loc_id   : Deliver to location to determine pricing
--              p_destination_org_id  : Destination organizations to determine pricing
--              p_api_version         : The value is 1.0
--              p_init_msg_list       : Standard API parameter: Initializes FND
--                                      message list if set to FND_API.G_TRUE.
--
--IN OUT:     : None
--
--
--Returns     : Vendor ID
--              Vendor Site ID
--              Vendor Contact ID
--              Document Header ID
--              Document Line ID
--              Document Line Num
--              Price break ID
--              Document Type
--              Base currency Price
--              Foreign currency Price
--              Document UOM
--              Document Currency
--              Price Override flag
--              Flag to indicate if price differentials exist
--
--     x_return_status - (a) FND_API.G_RET_STS_SUCCESS if validation successful
--                       (b) FND_API.G_RET_STS_ERROR if error during validation
--                       (c) FND_API.G_RET_STS_UNEXP_ERROR if unexpected error
--     x_msg_count     - Standard API parameter: The count of number of messages
--                       added to the message list in this call.
--     x_msg_data      - Standard API parameter: Contains error msg in case
--                       x_return_status is returned as FND_API.G_RET_STS_ERROR
--                       or FND_API.G_RET_STS_UNEXP_ERROR.
--Notes       : None
--
--Testing     : None
--
--End of Comments
-----------------------------------------------------------------------------------------
PROCEDURE get_services_asl_list
             (p_job_id                     IN         NUMBER,
              p_category_id                IN         NUMBER,
              p_line_type_id               IN         NUMBER,
              p_start_date                 IN         DATE,
              p_deliver_to_loc_id          IN         NUMBER,
              p_destination_org_id         IN         NUMBER,
              p_api_version                IN         NUMBER,
              -- Bug# 3404477: Follow the API standards
              p_init_msg_list              IN         VARCHAR2,
              x_vendor_id                  OUT NOCOPY po_tbl_number,
              x_vendor_site_id             OUT NOCOPY po_tbl_number,
              x_vendor_contact_id          OUT NOCOPY po_tbl_number,
              x_src_doc_header_id          OUT NOCOPY po_tbl_number,
              x_src_doc_line_id            OUT NOCOPY po_tbl_number,
              x_src_doc_line_num           OUT NOCOPY po_tbl_number,
              x_src_doc_type_code          OUT NOCOPY po_tbl_varchar30,
              x_base_price                 OUT NOCOPY po_tbl_number,
              x_currency_price             OUT NOCOPY po_tbl_number,
              x_currency_code              OUT NOCOPY po_tbl_varchar15,
              x_unit_of_measure            OUT NOCOPY po_tbl_varchar25,
              x_price_override_flag        OUT NOCOPY po_tbl_varchar1,
              x_not_to_exceed_price        OUT NOCOPY po_tbl_number,
              x_price_break_id             OUT NOCOPY po_tbl_number,
              x_price_differential_flag    OUT NOCOPY po_tbl_varchar1,
              x_rate_type                  OUT NOCOPY po_tbl_varchar30,
              x_rate_date                  OUT NOCOPY po_tbl_date,
              x_rate                       OUT NOCOPY po_tbl_number,
              x_return_status              OUT NOCOPY VARCHAR2,
              -- Bug# 3404477: Return msg count and data
              x_msg_count                  OUT NOCOPY NUMBER,
              x_msg_data                   OUT NOCOPY VARCHAR2
) IS

l_org_id NUMBER;
l_use_contract VARCHAR2(1) := 'N';	--<Contract AutoSourcing FPJ>


-- SQL What: Gets the vendor ID and the vendor site ID using category
--           ID and job ID as primary matching criteria.
-- SQL Why : To obtain all ASLs together with vendor information.
CURSOR l_get_asl_vendors_csr (p_dest_organization_id IN number) is
    SELECT pasl.vendor_id,
           pasl.vendor_site_id,
           pasl.asl_id
    FROM   po_approved_supplier_list pasl,
           po_asl_status_rules pasr,
           po_vendors pov
    WHERE  pasl.category_id = p_category_id
    AND    pasl.item_id IS NULL -- as part of Bug# 3379053: For commodity based ASL's,
                                -- the item MUST be NULL
           -- Bug# 3379053: Use destination inv org instead of the default inv org of the ROU.
    AND    (pasl.using_organization_id = p_dest_organization_id
            OR pasl.using_organization_id = -1)
    AND    pasr.status_id = pasl.asl_status_id
    AND    pasr.business_rule like '2_SOURCING'
    AND    pasr.allow_action_flag like 'Y'
    AND    nvl(pasl.disable_flag,'N') = 'N'
    -- Supplier validations (Bug# 3361784)
    AND    pov.vendor_id = pasl.vendor_id              -- Join
    AND    trunc(sysdate) >= trunc(nvl(pov.start_date_active, sysdate))
    AND    trunc(sysdate) <  trunc(nvl(pov.end_date_active, sysdate+1)) -- Bug# 3432045: Exclude end_date_active
    AND    pov.enabled_flag = 'Y'
    AND    nvl(pov.hold_flag, 'N') = 'N'
           -- Bug# 3379053: Supplier site validations moved later in the flow
 ORDER BY pasl.vendor_id ASC,              -- Bug# 3379053: To filter out duplicates, the supplier
          pasl.vendor_site_id ASC,         -- and supplier-sites must be grouped together.
          pasl.using_organization_id DESC; -- And Local ASL's must come above Global ASL's.

-- SQL What: Gets the document header ID, line ID, document type,
--           vendor ID, vendor site ID and vendor contact ID using
--           category ID and job ID as primary matching criteria.
-- SQL Why : To obtain all ASLs and their corresponding documents,
--           together with vendor information.

-- Bug# 3372867: This cursor is not being used anymore, but is not
-- being removed from the code for possible future references
/*
CURSOR l_get_docs_on_asl_csr (l_org_id         IN number,
                              l_vendor_site_id IN number,
                              l_asl_id         IN number
                              ) is
    SELECT poh.vendor_contact_id,
           pad.document_header_id,
           pad.document_line_id,
           pol.line_num,
           pad.document_type_code,
           nvl(pol.allow_price_override_flag,'N'),
           pol.not_to_exceed_price,
           pol.unit_meas_lookup_code
    FROM   po_asl_documents pad,
           po_headers_all poh,
           po_lines_all pol
    WHERE  pad.asl_id = l_asl_id
    AND    pad.document_header_id = poh.po_header_id
    -- <FPJ Advanced Price START>
    AND    pol.po_line_id (+) = pad.document_line_id
    AND    (poh.type_lookup_code = 'CONTRACT' OR
            (pol.job_id = p_job_id AND
             pol.category_id = p_category_id AND
             pol.line_type_id = p_line_type_id))
    -- <FPJ Advanced Price END>
    AND   ( (poh.type_lookup_code = 'CONTRACT'
           AND nvl(poh.global_agreement_flag,'N') = 'N')  -- Bug 3262136
           OR exists (select 'site in POU'
                       from po_ga_org_assignments poga,
                            po_vendor_sites_all povs
                       where  poh.po_header_id = poga.po_header_id
                       and povs.vendor_site_id = l_vendor_site_id
                       and povs.org_id = poga.purchasing_org_id
                       and poga.vendor_site_id = l_vendor_site_id
                       and poga.organization_id = l_org_id
                       and poga.enabled_flag = 'Y')  )
    AND    ((poh.type_lookup_code = 'BLANKET'
               AND poh.approved_flag    = 'Y'
               AND nvl(poh.closed_code, 'OPEN') NOT IN
                      ('FINALLY CLOSED','CLOSED')
               AND nvl(pol.closed_code, 'OPEN') NOT IN
                      ('FINALLY CLOSED','CLOSED')
               AND nvl(poh.cancel_flag,'N') = 'N'
               AND nvl(poh.frozen_flag,'N') = 'N'
               AND trunc(nvl(pol.expiration_date, sysdate))
                   >= trunc(sysdate)
               AND nvl(pol.cancel_flag,'N') = 'N')
           -- <FPJ Advanced Price START>
           OR (    poh.type_lookup_code = 'CONTRACT'
               AND poh.approved_flag = 'Y'
               AND NVL(poh.cancel_flag,'N') = 'N'
               AND NVL(poh.frozen_flag,'N') = 'N'
               AND NVL(poh.closed_code, 'OPEN') = 'OPEN'
              )
           )
           -- <FPJ Advanced Price END>
    AND    sysdate >= nvl(poh.start_date, sysdate)
    AND    sysdate <= nvl(poh.end_date, sysdate)
    AND    ( (poh.type_lookup_code = 'CONTRACT'
              AND nvl(poh.global_agreement_flag,'N') = 'N')  OR   -- Bug 3262136
            (nvl(poh.global_agreement_flag,'N') = 'Y'
             AND EXISTS (SELECT 'enabled orgs'
                   FROM   po_ga_org_assignments poga
                   WHERE  poh.po_header_id = poga.po_header_id
                   AND    poga.organization_id = l_org_id
                   AND    poga.enabled_flag = 'Y'
                  ) )
           )
 ORDER BY pad.sequence_num;
*/

-- SQL What: Gets the document header ID, line ID, document type,
--           vendor ID, vendor site ID and vendor contact ID using
--           category ID and job ID as primary matching criteria.
--           The sql also returns contracts available in the system
-- SQL Why : To obtain all ASLs and their corresponding documents,
--           together with vendor information.
-- Bug 5074119
-- Added an extra condition on type_lookup_code to improve the performance
CURSOR l_get_latest_docs_csr(l_org_id          IN number,
                              l_vendor_id      IN number,
                              l_vendor_site_id IN number) is
    SELECT poh.vendor_contact_id,
           poh.po_header_id,
           pol.po_line_id,
           pol.line_num,
           poh.type_lookup_code,
           nvl(pol.allow_price_override_flag,'N'),
           pol.not_to_exceed_price,
           pol.unit_meas_lookup_code
    FROM   po_headers_all poh,
           po_lines_all pol
    WHERE  poh.vendor_id = l_vendor_id
       AND poh.type_lookup_code IN ('BLANKET','CONTRACT')
    AND    (  ( poh.type_lookup_code = 'CONTRACT'
                AND nvl(poh.global_agreement_flag,'N') = 'N'     -- Bug 3262136
                -- As part of Bug# 3379053: Local Contract must belong to ROU
                AND poh.org_id = l_org_id
                -- As part of Bug# 3379053: Vendor Site on Local Contract must belong to ROU
                AND poh.vendor_site_id = l_vendor_site_id
                AND EXISTS  -- Bug# 3379053
                    (SELECT 'Site must be in ROU for local contracts'
                     FROM po_vendor_sites_all povs
                     WHERE povs.vendor_site_id = l_vendor_site_id
                       AND povs.org_id = l_org_id)
               )
            OR
            EXISTS (SELECT 'site in POU'
                       FROM po_ga_org_assignments poga,
                            po_vendor_sites_all povs
                       WHERE  poh.po_header_id = poga.po_header_id
                       AND povs.vendor_site_id = l_vendor_site_id
                       AND povs.org_id = poga.purchasing_org_id
                       AND poga.vendor_site_id = l_vendor_site_id
                       AND poga.organization_id = l_org_id
                       AND poga.enabled_flag = 'Y')  )
    -- <FPJ Advanced Price START>
    AND    pol.po_header_id (+) = poh.po_header_id
    AND    (poh.type_lookup_code = 'CONTRACT' OR
            (pol.job_id = p_job_id AND
             pol.category_id = p_category_id AND
             pol.line_type_id = p_line_type_id))
    -- <FPJ Advanced Price END>
    AND    ((poh.type_lookup_code = 'BLANKET'
               AND poh.approved_flag    = 'Y'
               AND nvl(poh.closed_code, 'OPEN') NOT IN
                      ('FINALLY CLOSED','CLOSED')
               AND nvl(pol.closed_code, 'OPEN') NOT IN
                      ('FINALLY CLOSED','CLOSED')
               AND nvl(poh.cancel_flag,'N') = 'N'
               AND nvl(poh.frozen_flag,'N') = 'N'
               AND trunc(nvl(pol.expiration_date, sysdate))
                   >= trunc(sysdate)
               AND nvl(pol.cancel_flag,'N') = 'N')
           -- <FPJ Advanced Price START>
           OR (    poh.type_lookup_code = 'CONTRACT'
	        	 AND (( NVL(FND_PROFILE.VALUE('ALLOW_REFERENCING_CPA_UNDER_AMENDMENT'),'N') =  'Y' --<R12 GCPA ER>
				 		and poh.approved_date is not null)
				 		OR
				 		nvl(poh.approved_flag,'N') = 'Y'
				 		)
               AND NVL(poh.cancel_flag,'N') = 'N'
               AND NVL(poh.frozen_flag,'N') = 'N'
               AND NVL(poh.closed_code, 'OPEN') = 'OPEN'
               AND l_use_contract = 'Y'		--<Contract AutoSourcing FPJ>
              )
           )
           -- <FPJ Advanced Price END>
    AND    sysdate >= nvl(poh.start_date, sysdate)
    AND    sysdate <= nvl(poh.end_date, sysdate)
    AND    ( (poh.type_lookup_code = 'CONTRACT'
              AND nvl(poh.global_agreement_flag,'N') = 'N')  OR     -- Bug 3262136
           (nvl(poh.global_agreement_flag,'N') = 'Y'
           AND EXISTS (SELECT 'enabled orgs'
                   FROM   po_ga_org_assignments poga
                   WHERE  poh.po_header_id = poga.po_header_id
                   AND    poga.organization_id = l_org_id
                   AND    poga.enabled_flag = 'Y'
                  ) )
           )
  ORDER BY  -- <FPJ Advanced Price START>
         decode(poh.type_lookup_code, 'BLANKET', 1, 'QUOTATION', 2, 'CONTRACT', 3) ASC,
         NVL (poh.global_agreement_flag, 'N') ASC,
         poh.creation_date DESC;
         -- <FPJ Advanced Price END>

l_discount		po_line_locations_all.price_discount%TYPE;
l_rate_type		po_headers_all.rate_type%TYPE;
l_rate_date		po_headers_all.rate_date%TYPE;
l_rate			po_headers_all.rate%TYPE;
l_base_unit_price	po_lines_all.base_unit_price%TYPE;	-- <FPJ Advanced Price>
l_base_price		po_lines_all.unit_price%TYPE;
l_currency_price	po_lines_all.unit_price%TYPE;
l_currency_amount	po_lines_all.unit_price%TYPE;
l_base_amount    	po_lines_all.unit_price%TYPE;
l_currency_code		po_headers_all.currency_code%TYPE;
l_price_break_id	po_line_locations_all.line_location_id%TYPE;
l_price_diff_src_id	po_price_differentials.entity_id%TYPE;
l_using_organization_id	po_approved_supplier_list.using_organization_id%TYPE;
l_entity_type		po_price_differentials.entity_type%TYPE;
l_vendor_contact_id     po_headers_all.vendor_contact_id%TYPE;
l_src_doc_header_id     po_headers_all.po_header_id%TYPE;
l_src_doc_line_id       po_lines_all.po_line_id%TYPE;
l_src_doc_line_num      po_lines_all.line_num%TYPE;
l_src_doc_type_code     po_headers_all.type_lookup_code%TYPE;
l_price_override_flag   po_lines_all.allow_price_override_flag%TYPE;
l_not_to_exceed_price   po_lines_all.not_to_exceed_price%TYPE;
l_unit_of_measure       po_lines_all.unit_meas_lookup_code%TYPE;
l_order_type_lookup_code po_line_types_b.order_type_lookup_code%TYPE;

l_api_version		NUMBER       := 1.0;
l_api_name		VARCHAR2(60) := 'get_services_asl_list';
l_log_head		CONSTANT varchar2(100) := g_log_head || l_api_name;
l_progress		VARCHAR2(3) := '000';

x_asl_id                po_tbl_number;
l_sysdate               DATE  := trunc(sysdate); --   Bug 3282423

  -- Bug# 3379053
  l_supplier_site_status VARCHAR2(20);
  l_vendor_id_list      po_tbl_number := po_tbl_number();
  l_vendor_site_id_list po_tbl_number := po_tbl_number();
  l_asl_id_list         po_tbl_number := po_tbl_number();
  l_count                  NUMBER;
  l_prev_vendor_id         NUMBER;
  l_prev_vendor_site_id    NUMBER;
  l_current_vendor_id      NUMBER;
  l_current_vendor_site_id NUMBER;
  l_found_dup_null_site    VARCHAR2(1);
BEGIN

  IF g_debug_stmt THEN
    PO_DEBUG.debug_begin(l_log_head);
    PO_DEBUG.debug_var(l_log_head,l_progress,'p_job_id',p_job_id);
    PO_DEBUG.debug_var(l_log_head,l_progress,'p_category_id',p_category_id);
    PO_DEBUG.debug_var(l_log_head,l_progress,'p_line_type_id',p_line_type_id);
    PO_DEBUG.debug_var(l_log_head,l_progress,'p_start_date',p_start_date);
    PO_DEBUG.debug_var(l_log_head,l_progress,'p_deliver_to_loc_id',p_deliver_to_loc_id);
    PO_DEBUG.debug_var(l_log_head,l_progress,'p_destination_org_id',p_destination_org_id);
    PO_DEBUG.debug_var(l_log_head,l_progress,'p_api_version',p_api_version);
  END IF;

    -- Initialize the out parameter tables
    x_vendor_id               := po_tbl_number(); -- Bug# 3379053: Initialize x_vendor_id and
    x_vendor_site_id          := po_tbl_number(); -- x_vendor_site_id collections
    x_base_price              := po_tbl_number();
    x_currency_price          := po_tbl_number();
    x_currency_code           := po_tbl_varchar15();
    x_price_break_id          := po_tbl_number();
    x_price_differential_flag := po_tbl_varchar1();
    x_rate_type               := po_tbl_varchar30();
    x_rate_date               := po_tbl_date();
    x_rate                    := po_tbl_number();
    x_vendor_contact_id       := po_tbl_number();
    x_src_doc_header_id       := po_tbl_number();
    x_src_doc_line_id         := po_tbl_number();
    x_src_doc_line_num        := po_tbl_number();
    x_src_doc_type_code       := po_tbl_varchar30();
    x_price_override_flag     := po_tbl_varchar1();
    x_not_to_exceed_price     := po_tbl_number();
    x_unit_of_measure         := po_tbl_varchar25();

    l_progress := '010';

    -- Initialize the return status
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    -- Bug# 3404477: Return msg count and data
    x_msg_count     := 0;
    x_msg_data      := NULL;

    -- Bug# 3404477: Follow the API standards
    IF FND_API.to_boolean(p_init_msg_list) THEN
      -- initialize message list
      FND_MSG_PUB.initialize;
    END IF;

    -- Check for the API version
    IF ( NOT FND_API.compatible_api_call(l_api_version,p_api_version,l_api_name,G_PKG_NAME) ) THEN
        l_progress := '020';
        -- As part of bug# 3404477: No need to proceed if the API is not
        -- compatible. Hence, raise exception.
        --x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Sql What: Gets the org id and default inv org from FSP
    -- Sql Why : To determine the current OU and the default FSP org
    BEGIN
        l_progress := '030';
        SELECT org_id,
               inventory_organization_id
        INTO   l_org_id,
               l_using_organization_id
        FROM   financials_system_parameters;
    EXCEPTION
        WHEN OTHERS THEN
            null;
    END;

    -- Sql What: get the order type lookup code for the line type id that is passed in
    -- Sql why : to distinguish between rate based and fixed price lines
    BEGIN
        l_progress := '035';
        SELECT order_type_lookup_code
        INTO   l_order_type_lookup_code
        FROM   po_line_types_b
        WHERE  line_type_id = p_line_type_id;
    EXCEPTION
        WHEN OTHERS THEN
            null;
    END;

    --<Contract AutoSourcing FPJ Start>
    -- Find out if contract agreements should be sourced to requisition lines
    -- Currently, should_return_contract only supports Purchase Requisitions
    l_progress := '040';
    should_return_contract(p_destination_doc_type => 'REQ',
                           p_document_type_code   => 'REQUISITION',
                           p_document_subtype     => 'PURCHASE',
                           x_return_contract      => l_use_contract,
                           x_return_status        => x_return_status);
    IF x_return_status <>  FND_API.g_ret_sts_success  THEN
      RAISE FND_API.g_exc_unexpected_error;
    END IF;
    --<Contract AutoSourcing FPJ End>

    -- Retrive all the ASL's for the category that is passed in
    OPEN l_get_asl_vendors_csr (--l_using_organization_id,
                                p_destination_org_id);      -- Bug# 3379053

    -- Retrieve data using the cursor into variables;
       FETCH l_get_asl_vendors_csr BULK COLLECT INTO
                   --x_vendor_id             ,
                   --x_vendor_site_id        ,
                   --x_asl_id                ;
                   -- Bug# 3379053 : Fetch into local collections so that duplicates can be removed
                   l_vendor_id_list        ,
                   l_vendor_site_id_list   ,
                   l_asl_id_list           ;

    CLOSE l_get_asl_vendors_csr;

    -- Bug# 3379053: If no supplier records found in the ASL, then just return.
    IF (l_vendor_id_list.FIRST IS NULL) THEN
      RETURN;
    END IF;

    -- Bug# 3379053: Validate supplier sites. Null out the site, if it is invalid
    validate_vendor_sites(l_vendor_site_id_list);

    -- For each ASL vendor get the source document and pricing information
    -- Bug# 3379053 : Loop through local collection to identify duplicate (suppl, suppl-sites)
    l_count := 0;
    FOR i IN l_vendor_id_list.FIRST..l_vendor_id_list.LAST LOOP

      -- Bug# 3379053: For a supplier/supplier-site combination, remove duplicates.
      IF (is_dup_vendor_record(l_vendor_id_list(i),
                               l_vendor_site_id_list(i),
                               x_vendor_id,
                               x_vendor_site_id)) THEN
        GOTO end_vendor_loop; -- skip record
      END IF;

     -- If vendor site is NULL, then Document SOurcing is not required.
     IF l_vendor_site_id_list(i) IS NULL THEN
       l_count := l_count + 1;
       -- Extend the out parameter table to create a new OUT record
       x_vendor_id.extend;
       x_vendor_site_id.extend;
       x_currency_price.extend;
       x_currency_code.extend;
       x_price_break_id.extend;
       x_price_differential_flag.extend;
       x_rate_type.extend;
       x_rate_date.extend;
       x_rate.extend;
       x_vendor_contact_id.extend;
       x_src_doc_header_id.extend;
       x_src_doc_line_id.extend;
       x_src_doc_line_num.extend;
       x_src_doc_type_code.extend;
       x_price_override_flag.extend;
       x_not_to_exceed_price.extend;
       x_unit_of_measure.extend;
       x_base_price.extend;

       x_vendor_id(l_count) := l_vendor_id_list(i);
       x_vendor_site_id(l_count) := NULL;

     ELSE -- IF l_current_vendor_site_id IS NOT NULL THEN

     -- Proceed with the document sourcing flow, only if the ASL has a site
     --IF x_vendor_site_id(i) is not null THEN
     --IF l_current_vendor_site_id IS NOT NULL THEN -- Bug# 3379053: Moved doc sourcing up

       l_current_vendor_id := l_vendor_id_list(i);
       l_current_vendor_site_id := l_vendor_site_id_list(i);

       -- Initialize the local variables
       l_vendor_contact_id   := null;
       l_src_doc_header_id   := null;
       l_src_doc_line_id     := null;
       l_src_doc_line_num    := null;
       l_src_doc_type_code   := null;
       l_price_override_flag := null;
       l_not_to_exceed_price := null;
       l_unit_of_measure     := null;

    -- Retreive the Automatic document sourcing Profile. Based on the profile we either
    -- use the document info from the ASL documents tables or the PO tables directly

      -- Bug# 3372867: Functional design changes to the Services Source API:
      -- Services Sourcing API will always source from the latest source doc/line
      -- matching the Job/Category.  The Profile Option "PO:Automatic Document
      -- Sourcing" will be ignored for temp labor lines and behaves as if it is
      -- set to Yes.
      -- This code section is not being deleted for possible future references.
      /*
      IF (nvl(fnd_profile.value('PO_AUTO_SOURCE_DOC'),'N') = 'N') THEN

        l_progress := '040';
        IF g_debug_stmt THEN
          PO_DEBUG.debug_stmt(l_log_head,l_progress,'Open Cursor l_get_docs_on_asl_csr');
        END IF;

        OPEN l_get_docs_on_asl_csr (l_org_id,
                                    x_vendor_site_id(i),
                                    x_asl_id(i));

        -- Retrieve data using the cursor into variables;

	    FETCH  l_get_docs_on_asl_csr INTO
                   l_vendor_contact_id     ,
                   l_src_doc_header_id     ,
                   l_src_doc_line_id       ,
                   l_src_doc_line_num      ,
                   l_src_doc_type_code     ,
                   l_price_override_flag   ,
                   l_not_to_exceed_price   ,
                   l_unit_of_measure       ;
        CLOSE l_get_docs_on_asl_csr;
    ELSE
    */

      l_progress := '050';
      IF g_debug_stmt THEN
        PO_DEBUG.debug_stmt(l_log_head,l_progress,'Open Cursor l_get_latest_docs_csr');
      END IF;

        OPEN l_get_latest_docs_csr (l_org_id,
                                    --x_vendor_id(i),
                                    --x_vendor_site_id(i)
                                    l_vendor_id_list(i),       -- Bug# 3379053: Using local collections
                                    l_vendor_site_id_list(i));

        l_progress := '060';
        -- Retrieve data using the cursor into variables

           FETCH  l_get_latest_docs_csr INTO
                   l_vendor_contact_id     ,
                   l_src_doc_header_id     ,
                   l_src_doc_line_id       ,
                   l_src_doc_line_num      ,
                   l_src_doc_type_code     ,
                   l_price_override_flag   ,
                   l_not_to_exceed_price   ,
                   l_unit_of_measure       ;
        CLOSE l_get_latest_docs_csr;

        l_progress := '070';

    --END IF;   -- end of profile check -- Bug# 3372867

    -- Bug# 3379053: If no source doc is found, then the Supplier Site MUST belong to ROU
    --               If it is outside ROU, then null out the supplier site.
    IF l_src_doc_header_id IS NULL THEN
      l_progress := '080';
      IF (is_vendor_site_outside_OU(l_current_vendor_site_id, l_org_id)) THEN
        l_current_vendor_site_id := NULL;

        l_progress := '090';
        -- Check for duplicate (Supplier, NULL) records in the filtered list.
        IF (is_dup_vendor_record(l_current_vendor_id,
                                 NULL, -- vendor_site_id
                                 x_vendor_id,
                                 x_vendor_site_id)) THEN
          GOTO end_vendor_loop; -- skip record
        END IF;
        l_progress := '110';
      END IF; -- IF is_vendor_site_outside_OU
    END IF; -- IF l_src_doc_header_id IS NULL THEN
    -- Bug# 3379053: End

      l_progress := '120';

      -- Count of the valid records that are filtered from the result rowset of
      -- the cursor 'l_get_asl_vendors_csr'
      l_count := l_count + 1;

       -- Extend the out parameter table
       x_vendor_id.extend;
       x_vendor_site_id.extend;

       x_vendor_id(l_count) := l_current_vendor_id;
       x_vendor_site_id(l_count) := l_current_vendor_site_id;

       -- Extend the out parameter table
       --x_base_price.extend(x_vendor_id.COUNT);
       x_base_price.extend; -- Bug# 3379053: Extend by 1 in one loop.
                            -- Remove the parameter (x_vendor_id.COUNT) from all collections below

       x_currency_price.extend;
       x_currency_code.extend;
       x_price_break_id.extend;
       x_price_differential_flag.extend;
       x_rate_type.extend;
       x_rate_date.extend;
       x_rate.extend;
       x_vendor_contact_id.extend;
       x_src_doc_header_id.extend;
       x_src_doc_line_id.extend;
       x_src_doc_line_num.extend;
       x_src_doc_type_code.extend;
       x_price_override_flag.extend;
       x_not_to_exceed_price.extend;
       x_unit_of_measure.extend;


    l_progress := '130';

    IF g_debug_stmt THEN
      PO_DEBUG.debug_var(l_log_head,l_progress,'x_vendor_id',x_vendor_id);
      PO_DEBUG.debug_var(l_log_head,l_progress,'x_vendor_site_id',x_vendor_site_id);
      PO_DEBUG.debug_var(l_log_head,l_progress,'x_vendor_contact_id',x_vendor_contact_id);
      PO_DEBUG.debug_var(l_log_head,l_progress,'x_src_doc_header_id',x_src_doc_header_id);
      PO_DEBUG.debug_var(l_log_head,l_progress,'x_src_doc_line_id',x_src_doc_line_id);
      PO_DEBUG.debug_var(l_log_head,l_progress,'x_src_doc_line_num',x_src_doc_line_num);
      PO_DEBUG.debug_var(l_log_head,l_progress,'x_src_doc_type_code',x_src_doc_type_code);
      PO_DEBUG.debug_var(l_log_head,l_progress,'x_price_override_flag',x_price_override_flag);
      PO_DEBUG.debug_var(l_log_head,l_progress,'x_not_to_exceed_price',x_not_to_exceed_price);
    END IF;

       l_progress := '140';

       -- Call the pricing API only for Blankets and not for contracts
       IF l_src_doc_type_code = 'BLANKET' and l_src_doc_header_id is not null THEN

         IF l_order_type_lookup_code = 'RATE' THEN

           l_progress := '150';

           IF g_debug_stmt THEN
             PO_DEBUG.debug_stmt(l_log_head,l_progress,'Call PO_PRICE_BREAK_GRP.get_price_break');
           END IF;

           -- Bug 3282423 -  Passing sysdate for p_need_by_date instead of start date

           PO_PRICE_BREAK_GRP.get_price_break
     	   (  p_source_document_header_id	=> l_src_doc_header_id
	   ,  p_source_document_line_num	=> l_src_doc_line_num
	   ,  p_in_quantity	        	=> null
	   ,  p_unit_of_measure		        => null
	   ,  p_deliver_to_location_id	        => p_deliver_to_loc_id
	   ,  p_required_currency		=> null
	   ,  p_required_rate_type	        => null
	   ,  p_need_by_date		        => l_sysdate
	   ,  p_destination_org_id	        => p_destination_org_id
	   ,  x_base_price		        => l_base_price
	   ,  x_currency_price		        => l_currency_price
	   ,  x_discount			=> l_discount
	   ,  x_currency_code		        => l_currency_code
	   ,  x_rate_type                       => l_rate_type
	   ,  x_rate_date                       => l_rate_date
	   ,  x_rate                            => l_rate
	   ,  x_price_break_id                  => l_price_break_id
	   );

           l_progress := '160';

           IF g_debug_stmt THEN
             PO_DEBUG.debug_stmt(l_log_head,l_progress,'After Call PO_PRICE_BREAK_GRP.get_price_break');
           END IF;

           -- Set the source of the pricing (line or price break)
           l_progress := '170';
           IF l_price_break_id is NULL THEN
              l_price_diff_src_id := l_src_doc_line_id;
              l_entity_type       := 'BLANKET LINE';
           ELSE
              l_price_diff_src_id := l_price_break_id;
              l_entity_type       := 'PRICE BREAK';
           END IF;

           -- Find out if the line or price break has any price differentials or not
           l_progress := '180';
           IF PO_PRICE_DIFFERENTIALS_PVT.has_price_differentials(p_entity_type => l_entity_type,
                                                                 p_entity_id   => l_price_diff_src_id) THEN
                --x_price_differential_flag(i) := 'Y';
                x_price_differential_flag(l_count) := 'Y'; -- Bug# 3379053
           ELSE
                --x_price_differential_flag(i) := 'N';
                x_price_differential_flag(l_count) := 'N'; -- Bug# 3379053
           END IF;

             -- Bug# 3379053: Change i to l_count for all of the following variables
             x_base_price(l_count)     := l_base_price;
	   x_currency_price(l_count) := l_currency_price;
	   x_currency_code(l_count)  := l_currency_code;
	   x_rate_type(l_count)      := l_rate_type;
	   x_rate_date(l_count)      := l_rate_date;
	   x_rate(l_count)           := l_rate;
	   x_price_break_id(l_count) := l_price_break_id;

         ELSE

           -- For fixed price lines there is no price and price breaks and hence no pricing
           -- call is made. Instead we return the amount in the functional and forein currencies

           l_progress := '190';

           get_line_amount(p_source_document_header_id => l_src_doc_header_id
	           ,  p_source_document_line_id	  => l_src_doc_line_id
	           ,  x_base_amount		  => l_base_amount
	           ,  x_currency_amount	    	  => l_currency_amount
                   ,  x_currency_code             => l_currency_code
                   ,  x_rate_type                 => l_rate_type
                   ,  x_rate_date                 => l_rate_date
                   ,  x_rate                      => l_rate            );

           -- For fixed price temp labor lines the amount is returned as the base and currency prices
             -- Bug# 3379053: Change i to l_count for all of the following variables
             x_base_price(l_count)      := l_base_amount;
	   x_currency_price(l_count)  := l_currency_amount;
	   x_currency_code(l_count)   := l_currency_code;
	   x_rate_type(l_count)       := l_rate_type;
	   x_rate_date(l_count)       := l_rate_date;
	   x_rate(l_count)            := l_rate;

         END IF; -- End of pricing for rate based lines

       END IF;    -- End of Pricing for blanket

          -- Bug# 3379053: Change i to l_count for all of the following variables
          x_vendor_contact_id(l_count)   := l_vendor_contact_id;
          x_src_doc_header_id(l_count)   := l_src_doc_header_id;
          x_src_doc_line_id(l_count)     := l_src_doc_line_id;
          x_src_doc_line_num(l_count)    := l_src_doc_line_num;
          x_src_doc_type_code(l_count)   := l_src_doc_type_code;
          x_price_override_flag(l_count) := l_price_override_flag;
          x_not_to_exceed_price(l_count) := l_not_to_exceed_price;
          x_unit_of_measure(l_count)     := l_unit_of_measure;

      END IF; -- end of null site check

      -- Bug# 3379053: To skip the loop for duplicate (supplier, suppl-site) combinations
      <<end_vendor_loop>>
      NULL;

    END LOOP;

  l_progress := '200';

  IF g_debug_stmt THEN
    PO_DEBUG.debug_end(l_log_head);
    PO_DEBUG.debug_var(l_log_head,l_progress,'x_return_status',x_return_status);
    PO_DEBUG.debug_var(l_log_head,l_progress,'x_vendor_id',x_vendor_id);
    PO_DEBUG.debug_var(l_log_head,l_progress,'x_vendor_site_id',x_vendor_site_id);
    PO_DEBUG.debug_var(l_log_head,l_progress,'x_vendor_contact_id',x_vendor_contact_id);
    PO_DEBUG.debug_var(l_log_head,l_progress,'x_src_doc_header_id',x_src_doc_header_id);
    PO_DEBUG.debug_var(l_log_head,l_progress,'x_src_doc_line_id',x_src_doc_line_id);
    PO_DEBUG.debug_var(l_log_head,l_progress,'x_src_doc_line_num',x_src_doc_line_num);
    PO_DEBUG.debug_var(l_log_head,l_progress,'x_src_doc_type_code',x_src_doc_type_code);
    PO_DEBUG.debug_var(l_log_head,l_progress,'x_base_price',x_base_price);
    PO_DEBUG.debug_var(l_log_head,l_progress,'x_currency_price',x_currency_price);
    PO_DEBUG.debug_var(l_log_head,l_progress,'x_price_override_flag',x_price_override_flag);
    PO_DEBUG.debug_var(l_log_head,l_progress,'x_not_to_exceed_price',x_not_to_exceed_price);
    PO_DEBUG.debug_var(l_log_head,l_progress,'x_price_break_id',x_price_break_id);
    PO_DEBUG.debug_var(l_log_head,l_progress,'x_price_differential_flag',x_price_differential_flag);
    PO_DEBUG.debug_var(l_log_head,l_progress,'x_rate_type',x_rate_type);
    PO_DEBUG.debug_var(l_log_head,l_progress,'x_rate_date',x_rate_date);
    PO_DEBUG.debug_var(l_log_head,l_progress,'x_rate',x_rate);
  END IF;
EXCEPTION
    -- Bug# 3404477: Return msg count and data
    WHEN FND_API.G_EXC_ERROR THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
       FND_MSG_PUB.count_and_get(p_count => x_msg_count
                               , p_data  => x_msg_data);
    WHEN OTHERS THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

       IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
         FND_MSG_PUB.add_exc_msg(p_pkg_name       => g_pkg_name
                               , p_procedure_name => l_api_name
                               , p_error_text     => 'Progress: '||l_progress||
                                           ' Error: '||SUBSTRB(SQLERRM,1,215));
       END IF;
       FND_MSG_PUB.count_and_get(p_count => x_msg_count
                               , p_data  => x_msg_data);

       --<Contract AutoSourcing FPJ>
       IF g_debug_unexp THEN
          PO_DEBUG.debug_exc(l_log_head,l_progress);
       END IF;
END get_services_asl_list;


-----------------------------------------------------------------<SERVICES FPJ>
-------------------------------------------------------------------------------
--Start of Comments
--Name: get_source_info
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Retrieves the source document information for a particular Line.
--Parameters:
--IN
--p_po_line_id
--  Unique ID of line on which to check source document reference.
--OUT
--x_from_header_id
--  Source Document Header ID on the line.
--x_from_line_id
--  Source Document Line ID on the line.
--x_from_line_location_id
--  Source Document Price Break ID on the line.
--Testing:
--  None.
--End of Comments
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
PROCEDURE get_source_info
(
    p_po_line_id               IN          NUMBER
,   x_from_header_id           OUT NOCOPY  NUMBER
,   x_from_line_id             OUT NOCOPY  NUMBER
,   x_from_line_location_id    OUT NOCOPY  NUMBER
)
IS
BEGIN

    SELECT from_header_id
    ,      from_line_id
    ,      from_line_location_id
    INTO   x_from_header_id
    ,      x_from_line_id
    ,      x_from_line_location_id
    FROM   po_lines_all
    WHERE  po_line_id = p_po_line_id;

EXCEPTION

    WHEN OTHERS THEN
        PO_MESSAGE_S.sql_error('PO_AUTOSOURCE_SV.get_source_info','000',sqlcode);
        RAISE;

END get_source_info;


-----------------------------------------------------------------<SERVICES FPJ>
-------------------------------------------------------------------------------
--Start of Comments
--Name: get_source_info
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Determines if the source document values passed in are the same as what
--  is in the database.
--Parameters:
--IN
--p_po_line_id
--  Unique ID of line on which to check source document reference.
--p_from_header_id
--  Source Document Header ID to check.
--p_from_line_id
--  Source Document Line ID to check.
--p_from_line_location_id
--  Source Document Price Break ID to check.
--Returns:
--  TRUE if all three parameters match their respective database values.
--  FALSE otherwise.
--Testing:
--  None.
--End of Comments
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
FUNCTION has_source_changed
(
    p_po_line_id               IN          NUMBER
,   p_from_header_id           IN          NUMBER
,   p_from_line_id             IN          NUMBER
,   p_from_line_location_id    IN          NUMBER
)
RETURN BOOLEAN
IS
    l_from_header_id_db        PO_LINES_ALL.from_header_id%TYPE;
    l_from_line_id_db          PO_LINES_ALL.from_line_id%TYPE;
    l_from_line_location_id_db PO_LINES_ALL.from_line_location_id%TYPE;

BEGIN

    PO_AUTOSOURCE_SV.get_source_info
    (   p_po_line_id            => p_po_line_id
    ,   x_from_header_id        => l_from_header_id_db
    ,   x_from_line_id          => l_from_line_id_db
    ,   x_from_line_location_id => l_from_line_location_id_db
    );

    IF  (
            (   ( l_from_header_id_db = p_from_header_id )
            OR  (   ( l_from_header_id_db IS NULL )
                AND ( p_from_header_id IS NULL ) ) )
        AND
            (   ( l_from_line_id_db = p_from_line_id )
            OR  (   ( l_from_line_id_db IS NULL )
                AND ( p_from_line_id IS NULL ) ) )
        AND
            (   ( l_from_line_location_id_db = p_from_line_location_id )
            OR  (   ( l_from_line_location_id_db IS NULL )
                AND ( p_from_line_location_id IS NULL ) ) )
        )
    THEN
        return (FALSE);
    ELSE
        return (TRUE);
    END IF;

EXCEPTION

    WHEN OTHERS THEN
        PO_MESSAGE_S.sql_error('PO_AUTOSOURCE_SV.has_source_changed','000',sqlcode);
        RAISE;

END has_source_changed;

-----------------------------------------------------------------<SERVICES FPJ>
-------------------------------------------------------------------------------
--Start of Comments
--Name: get_line_amt
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Retrieves the line amount and related currency infor for a fixed price
--  temp labor line
--Parameters:
--IN
--p_source_doc_line_id
--  Unique ID of line on which to get the amount
--OUT
--   Base currency Amount
--   Foreign currency Amount
--   Document Currency
--   Currency Rate type
--   Currency Rate date
--   Currency Rate
--Testing:
--  None.
--End of Comments
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
PROCEDURE get_line_amount(p_source_document_header_id IN NUMBER
	           ,  p_source_document_line_id	             IN NUMBER
	           ,  x_base_amount		             OUT NOCOPY NUMBER
	           ,  x_currency_amount	    	             OUT NOCOPY NUMBER
                   ,  x_currency_code                        OUT NOCOPY VARCHAR2
                   ,  x_rate_type                            OUT NOCOPY VARCHAR2
                   ,  x_rate_date                            OUT NOCOPY DATE
                   ,  x_rate                                 OUT NOCOPY NUMBER )
IS

l_rate_type		  po_headers_all.rate_type%TYPE;
l_rate_date		  po_headers_all.rate_date%TYPE;
l_rate			  po_headers_all.rate%TYPE;
l_base_amount		  po_lines_all.amount%TYPE;
l_currency_amount	  po_lines_all.amount%TYPE;
l_currency_code		  po_headers_all.currency_code%TYPE;
l_base_curr_ext_precision number;
l_sob_id                  number;

BEGIN
     -- SQL What : Gets the currency code and amount from the given source document
     -- SQL Why  : To Return the amount and converted base amount to IP

        SELECT poh.currency_code ,
               pol.amount
        INTO   l_currency_code ,
               l_currency_amount
        FROM   po_headers_all poh,
               po_lines_all pol
        WHERE  poh.po_header_id = pol.po_header_id
        AND    poh.po_header_id = p_source_document_header_id
        AND    pol.po_line_id = p_source_document_line_id;

     -- SQL What: Get the set of books id from system parameters
     -- SQL Why : To calculate the currency conversion rate

        SELECT set_of_books_id
        INTO   l_sob_id
        FROM   financials_system_parameters;

     -- SQL What: Get the default currency exchange rate type from system parameters
     -- SQL Why : To calculate the currency conversion rate

        SELECT default_rate_type
        INTO   l_rate_type
        FROM   po_system_parameters;

     -- SQL What: Get the currency precision from system parameters
     -- SQL Why : To round the calculated amount

        SELECT nvl(FND.extended_precision,5)
        INTO   l_base_curr_ext_precision
        FROM   FND_CURRENCIES FND,
               FINANCIALS_SYSTEM_PARAMETERS FSP,
               GL_SETS_OF_BOOKS GSB
        WHERE  FSP.set_of_books_id = GSB.set_of_books_id AND
               FND.currency_code = GSB.currency_code;

        x_rate := PO_CORE_S.get_conversion_rate( l_sob_id        ,
                                                 l_currency_code ,
                                                 sysdate         ,
                                                 l_rate_type     );

        x_rate_date := sysdate;
        x_rate_type := l_rate_type;
        x_currency_code := l_currency_code;
        x_currency_amount := l_currency_amount;
        x_base_amount := round(l_currency_amount * nvl(x_rate,1), l_base_curr_ext_precision);

EXCEPTION

    WHEN OTHERS THEN
        PO_MESSAGE_S.sql_error('PO_AUTOSOURCE_SV.get_line_amount','000',sqlcode);
        RAISE;
END get_line_amount;

--<Contract AutoSourcing FPJ Start >
-------------------------------------------------------------------------------
-- Start of Comments
-- Name: SHOULD_RETURN_CONTRACT
-- Pre-reqs:
-- None
-- Modifies:
-- None
-- Locks:
-- None
-- Function:
-- Determines whether or not contract agreements can be sourced to
-- Parameters:
-- IN:
-- p_destination_doc_type:
--   Valid values are 'PO','REQ','STANDARD PO','REQ_NONCATALOG'and NULL
-- p_document_type_code:
--   Valid value is 'REQUISITION'
-- p_document_subtype:
--   Valid value is 'PURCHASE'
-- OUT:
-- x_return_contract:
--   If 'Y', contracts can be returned as source documents; otherwise,
--   do not source to contracts
-- x_return_status:
--   FND_API.g_ret_sts_success: if the procedure completed successfully
--   FND_API.g_ret_sts_unexp_error: if unexpected error occurrred
-- Notes:
-- None
-- Testing:
-- None
-- End of Comments
-------------------------------------------------------------------------------
PROCEDURE should_return_contract (
  p_destination_doc_type		IN	VARCHAR2,
  p_document_type_code	       		IN	VARCHAR2,
  p_document_subtype	       		IN	VARCHAR2,
  x_return_contract		OUT	NOCOPY	VARCHAR2,
  x_return_status     		OUT 	NOCOPY 	VARCHAR2)
IS
  l_use_contract_for_sourcing
 	PO_DOCUMENT_TYPES_ALL_B.use_contract_for_sourcing_flag%TYPE;
  l_include_noncatalog_flag
 	PO_DOCUMENT_TYPES_ALL_B.include_noncatalog_flag%TYPE;
  l_progress		VARCHAR2(3) := '000';
  l_log_head   CONSTANT VARCHAR2(100) := g_log_head||'should_return_contract';

BEGIN
  l_progress := '010';

  IF (p_document_type_code IS NULL) OR (p_document_subtype IS NULL) THEN
     x_return_contract := 'N';
     return;
  END IF;

  x_return_status := FND_API.g_ret_sts_success;
  x_return_contract := 'N';

  IF g_debug_stmt THEN
     PO_DEBUG.debug_stmt (p_log_head => l_log_head,
                          p_token    => l_progress,
                          p_message  => 'Destination Doc Type: '||p_destination_doc_type ||
                                        ' Document Type Code: '||p_document_type_code ||
                                        ' Document Subtype: '||p_document_subtype
                          );
  END IF;

  SELECT	nvl (use_contract_for_sourcing_flag, 'N'),
 	     	nvl (include_noncatalog_flag, 'N')
  INTO	      	l_use_contract_for_sourcing,
 		l_include_noncatalog_flag
  FROM     	PO_DOCUMENT_TYPES_B
  WHERE  	document_type_code = p_document_type_code
  AND 	      	document_subtype = p_document_subtype
  AND           org_id = FND_GLOBAL.ORG_ID;

  /*
     Added the where clause as part of bug #8860581 to stripe the table by org_id.
     This we require incase of customer using Single Operating Unit Setup and not MOAC.
     This is because for the above table when we use MOAC a dynamic where clause will be
     appended using ORG_ID. But in case of non-moac the above clause is not getting appended
     due to which the above query is failing with Exact fetch Returns Multiple Rows Error
  */

  l_progress := '020';
  IF g_debug_stmt THEN
     PO_DEBUG.debug_stmt (p_log_head => l_log_head,
                          p_token    => l_progress,
                          p_message  => 'Use contract for sourcing? '||l_use_contract_for_sourcing||
                                        ' Include noncatalog request? '||l_include_noncatalog_flag);
  END IF;

  IF l_use_contract_for_sourcing = 'Y' AND
     (l_include_noncatalog_flag = 'Y' OR
     (l_include_noncatalog_flag = 'N' AND p_destination_doc_type <> 'REQ_NONCATALOG'))
  THEN
     x_return_contract := 'Y';
  END IF;

  l_progress := '030';
  IF g_debug_stmt THEN
     PO_DEBUG.debug_stmt (p_log_head => l_log_head,
                          p_token    => l_progress,
                          p_message  => 'Should return contract? '||x_return_contract);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.g_ret_sts_unexp_error;
    FND_MSG_PUB.add_exc_msg (p_pkg_name	=> g_pkg_name,
  			     p_procedure_name => 'should_return_contract',
    			     p_error_text => 'Progress: '||l_progress||' Error: '||SUBSTRB(SQLERRM,1,215));
    IF g_debug_unexp THEN
       PO_DEBUG.debug_exc (p_log_head => l_log_head ||'should_return_contract',
			   p_progress => l_progress);
    END IF;

END should_return_contract;
--<Contract AutoSourcing FPJ End >

--<Bug# 11778318>
--------------------------------------------------------------------------------------
-- Start of Comments
-- Name: get_VmiOrConsignEnabled_info
-- Function:: For the given item id ,this procedure gives
--           value of VMI enabled  and Consigned_From_Supplier flag value
--           available on the ASL,  which is either Local to the input org
--           or Global for the current OU.

-- Input parameters :
--          p_item_id : Org Item
--          p_organization_id :Inv Org

--  OUTPUTS:          x_VmiEnabled_flag= 'Y' if the ASL entry corresponding to the
--                    required input is VMI enabled.

--                    x_VmiEnabled_flag=  'N' if not VMI enabled, no ASL entry exists,
--                    or the input data is incorrect

--                    x_consignEnabled_flag= 'Y' if the ASL entry corresponding to the
--                     required input is Consigned_From_Supplier enabled.

--                    x_consignEnabled_flag=  'N' if not Consigned_From_Supplier enabled,
--                    no ASL entry exists, or the  input data is incorrect

-- End of Comments
-----------------------------------------------------------------------------------------
PROCEDURE get_VmiOrConsignEnabled_info
(
  p_item_id                   IN  NUMBER
, p_organization_id           IN  NUMBER
, x_VmiEnabled_flag           OUT  NOCOPY VARCHAR2
 ,x_consignEnabled_flag       OUT  NOCOPY VARCHAR2

)

IS
BEGIN

  SELECT
         Nvl(paa.consigned_from_supplier_flag,'N'),
         Nvl(paa.enable_vmi_flag,'N')
  INTO
         x_consignEnabled_flag,
         x_VmiEnabled_flag
  FROM   po_approved_supplier_list pasl,
         po_asl_attributes paa,
         po_asl_status_rules pasr,
         po_vendor_sites_all pvsl,
         org_organization_definitions currentorg_ou
  WHERE  pasl.item_id = p_item_id
         AND pasl.using_organization_id IN ( -1, p_organization_id )
         AND pasl.asl_id = paa.asl_id
         AND pasr.business_rule = '2_SOURCING'
         AND pasr.allow_action_flag = 'Y'
         AND pasr.status_id = pasl.asl_status_id
         AND ( disable_flag IS NULL
              OR disable_flag = 'N' )
         AND paa.using_organization_id = (SELECT MAX(paa2.using_organization_id)
                                          FROM   po_asl_attributes paa2
                                          WHERE  paa2.asl_id = pasl.asl_id
                                                 AND paa2.using_organization_id IN( -1,p_organization_id ))
         AND pvsl.vendor_id = pasl.vendor_id
         AND currentorg_ou.organization_id = p_organization_id
         AND pasl.vendor_site_id = pvsl.vendor_site_id
         AND currentorg_ou.operating_unit = (SELECT operating_unit
                                           FROM   org_organization_definitions
                                           WHERE  organization_id = pvsl.org_id);

EXCEPTION

   WHEN No_Data_Found THEN
         x_consignEnabled_flag:='N';
         x_VmiEnabled_flag  :='N';

    WHEN OTHERS THEN
        PO_MESSAGE_S.sql_error('PO_AUTOSOURCE_SV.Check_VmiOrConsign_Enabled','000',sqlcode);
        RAISE;

END get_VmiOrConsignEnabled_info;

END PO_AUTOSOURCE_SV;

/
