--------------------------------------------------------
--  DDL for Package PO_AUTOSOURCE_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_AUTOSOURCE_SV" AUTHID CURRENT_USER AS
/* $Header: POXSRCDS.pls 120.6.12010000.2 2011/03/29 09:30:48 vlalwani ship $*/
--<PKGCOMP R12 Start>
-------------------------------------------------------------------------------
--Start of Comments
--Name: AUTOSOURCE
--Function:
-- This is the overloaded procedure that will be called by all the routines,
-- which were already calling PO_AUTOSOURCE_SV.autosource without ASL_ID parameter.
--
-- This procedure in turn will call the autosource procedure, which has the
-- additional parameter x_asl_id with a NULL value.
--
-- No changes are been made in the specification of the procedure
--End of Comments
 -------------------------------------------------------------------------------
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
		x_source_organization_id	IN OUT	NOCOPY NUMBER,  -- for inv
		x_source_subinventory		IN OUT	NOCOPY VARCHAR2, -- for inv
		x_document_header_id		IN OUT NOCOPY  NUMBER,
		x_document_line_id		IN OUT	NOCOPY NUMBER,
		x_document_type_code		IN OUT NOCOPY  VARCHAR2,
		x_document_line_num		IN OUT	NOCOPY NUMBER,
		x_buyer_id			IN OUT NOCOPY  NUMBER,
		x_vendor_product_num		IN OUT NOCOPY  VARCHAR2,
		x_purchasing_uom		IN OUT NOCOPY  VARCHAR2
                --<R12 STYLES PHASE II START>
                ,p_purchase_basis   IN VARCHAR2 DEFAULT NULL,
                 p_line_type_id     IN VARCHAR2 DEFAULT NULL,
                 p_destination_type IN VARCHAR2 DEFAULT NULL,
                 p_style_id         IN NUMBER DEFAULT NULL
                --<R12 STYLES PHASE II END>
);

-------------------------------------------------------------------------------
--Start of Comments
--Name: AUTOSOURCE
--Function:
--  This procedure performs automatic document sourcing based on item/item category,
--  supplier/supplier site, and profile option settings
--
--  We need the value of the asl_id in the PO_AUTOSOURCE_SV.reqimport_sourcing. We
--  have to get it from the PO_AUTOSOURCE_SV.autosource. Added a new parameter
--  x_asl_id as IN OUT type so that we can pass this value back to the
--  calling procedure.
--  So we have overloaded the existing procedure
--End of Comments
-----------------------------------------------------------------------------*/
PROCEDURE autosource(
		     x_mode			IN	VARCHAR2,
		     x_destination_doc_type	IN	VARCHAR2,
		     x_item_id			IN	NUMBER,
		     x_commodity_id		IN	NUMBER,
           	     x_dest_organization_id	IN	NUMBER,
		     x_dest_subinventory	IN	VARCHAR2,
		     x_autosource_date		IN	DATE,
		     x_item_rev			IN	VARCHAR2,
		     x_currency_code		IN	VARCHAR2,
		     x_vendor_id		IN OUT  NOCOPY  NUMBER,
		     x_vendor_site_id		IN OUT  NOCOPY  NUMBER,
		     x_vendor_contact_id	IN OUT  NOCOPY  NUMBER,
		     x_source_organization_id	IN OUT	NOCOPY NUMBER,
		     x_source_subinventory	IN OUT	NOCOPY VARCHAR2,
		     x_document_header_id	IN OUT  NOCOPY  NUMBER,
		     x_document_line_id		IN OUT	NOCOPY NUMBER,
		     x_document_type_code	IN OUT  NOCOPY  VARCHAR2,
		     x_document_line_num	IN OUT	NOCOPY NUMBER,
		     x_buyer_id			IN OUT  NOCOPY  NUMBER,
		     x_vendor_product_num	IN OUT  NOCOPY  VARCHAR2,
		     x_purchasing_uom		IN OUT  NOCOPY  VARCHAR2,
                     x_asl_id           IN OUT  NOCOPY NUMBER
                     --<R12 STYLES PHASE II START>
                    ,p_purchase_basis   IN VARCHAR2 DEFAULT NULL,
                     p_line_type_id     IN VARCHAR2 DEFAULT NULL,
                     p_destination_type IN VARCHAR2 DEFAULT NULL,
                     p_style_id         IN NUMBER DEFAULT NULL
                     --<R12 STYLES PHASE II END>
                    );
--<PKGCOMP R12 End>
PROCEDURE get_asl_info(
		x_item_id		IN 	NUMBER,
		x_vendor_id		IN 	NUMBER,
	        x_vendor_site_id	IN	NUMBER,
		x_using_organization_id	IN OUT	NOCOPY NUMBER,
		x_asl_id		IN OUT	NOCOPY NUMBER,
		x_vendor_product_num	IN OUT	NOCOPY VARCHAR2,
		x_purchasing_uom	IN OUT  NOCOPY VARCHAR2,
                p_category_id		IN	NUMBER default NULL --<Contract AutoSourcing FPJ>
                );

/* CONSIGNED FPI */
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
                p_category_id                   IN      NUMBER default NULL --<Contract AutoSourcing FPJ>
                );

/* VMI FPH */
FUNCTION  vmi_enabled(
                x_item_id               IN      NUMBER,
                x_vendor_id             IN      NUMBER,
                x_vendor_site_id        IN      NUMBER,
                x_using_organization_id IN      NUMBER
) RETURN VARCHAR2;

--<PKGCOMP R12 Start>
-- Modifying the parameter type for x_asl_id from IN to IN OUT, in order to communicate the
-- ASL_ID back to PO_AUTOSOURCE_SV.autosource or PO_AUTOSOURCE_SV.reqimport_sourcing.
--<PKGCOMP R12 End>

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
                x_asl_id                IN OUT NOCOPY NUMBER, -- cto changes FPH
        x_multi_org             IN      VARCHAR2 default 'N',
        p_vendor_site_sourcing_flag IN  VARCHAR2 default 'N', --<Shared Proc FPJ>
        p_vendor_site_code      IN      VARCHAR2 default NULL, --<Shared proc FPJ>
        p_category_id           IN      NUMBER 	 default NULL --<Contract AutoSourcing FPJ>
                --<R12 STYLES PHASE II START>
               ,p_purchase_basis   IN VARCHAR2 DEFAULT NULL,
                p_line_type_id     IN VARCHAR2 DEFAULT NULL,
                p_destination_type IN VARCHAR2 DEFAULT NULL,
                p_style_id         IN NUMBER DEFAULT NULL
                --<R12 STYLES PHASE II END>
);

--<PKGCOMP R12 Start>
-- Added the parameter p_multi_dist_flag to get the Value of 'Multiple Distribution' provided
-- by the user during the requisition import request submission
--<PKGCOMP R12 End>
PROCEDURE reqimport_sourcing(
	x_mode			IN	VARCHAR2,
	x_request_id		IN	NUMBER,
	p_multi_dist_flag       IN      VARCHAR2);

TYPE vendor_details_rec IS RECORD(
                                  Vendor_id         number,
                                  Vendor_site_id   number,
                                  Asl_id               number,
                                  Vendor_product_num  varchar2(25),
                                  Purchasing_uom        varchar2(25));

TYPE vendor_record_details IS TABLE OF vendor_details_rec index by BINARY_INTEGER;

/*============================================================================
     Name: Get_All_item_Asl
     DESC:  Cto Changes FPH. For the given item id this procedure gives
	    all the valid vendor,vendor sites and Asl ids from the global Asl.
     input parameters :
	x_item_id: Item id for which we get the global asl values
        x_using_organization_id := -1 if we need for global or the organization
	id for which we need.
     output parameters :
	x_return_status,x_msg_count,x_msg_data - Error messages if any returned
	in the api.
	x_vendor_details - This is a array of records with the vendor details.
==============================================================================*/

Procedure Get_All_item_Asl(
                           x_item_id              IN   Mtl_system_items.inventory_item_id%type,
                           x_using_organization_id      IN    Number, --will be -1
                           x_vendor_details IN OUT NOCOPY PO_AUTOSOURCE_SV.vendor_record_details,
                           x_return_status  OUT NOCOPY varchar2,
                           x_msg_count     OUT NOCOPY Number,
                           x_msg_data       OUT NOCOPY Varchar2);

/*============================================================================
     Name: blanket_document_sourcing
     DESC:  Cto Changes FPH. Wrapper for the procedure document_sourcing
	    to give only the blanket PO information. Returns  x_doc_Return as Y
            if there are any blankets.
     input parameters : Same as the document_sourcing. There are two extra
			parameters x_asl_id and x_multi_org
			x_asl_id - The asl_id for which we get the blankets.
			x_multi_org - If need to source across multi org then
					value is Y.
					Default value is N which sources for
					that particular operating unit
					where the apps is running.
     output parameters : Same as document sourcing.
			 x_return_status, x_msg_count, x_msg_date- returns
			any error messages in the api.
			x_doc_return: Returns Y if there is any blanket for
			for the asl_id.

==============================================================================*/
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
                                        x_purchasing_uom        IN OUT NOCOPY  VARCHAR2,
                                        x_return_status            OUT NOCOPY varchar2,
                                        x_msg_count                OUT NOCOPY Number,
                                        x_msg_data                 OUT NOCOPY Varchar2,
					x_doc_return		   OUT NOCOPY varchar2,
                                        x_asl_id                IN      NUMBER default null,
                                        x_multi_org             IN      VARCHAR2 default 'N'
					);

--<Shared Proc FPJ START>
PROCEDURE asl_sourcing (
   p_item_id                        	IN      NUMBER,
   p_vendor_id                      	IN      NUMBER,
   p_vendor_site_code               	IN      VARCHAR2,
   p_item_rev				            IN		VARCHAR2,
   p_item_rev_control			        IN		NUMBER,
   p_sourcing_date			            IN 		DATE,
   p_currency_code			            IN		VARCHAR2,
   p_org_id				                IN		NUMBER,
   p_using_organization_id          	IN  OUT NOCOPY    NUMBER,
   x_asl_id                         	OUT NOCOPY      NUMBER,
   x_vendor_product_num             	OUT NOCOPY      VARCHAR2,
   x_purchasing_uom                 	OUT NOCOPY      VARCHAR2,
   x_consigned_from_supplier_flag   	OUT NOCOPY      VARCHAR2,
   x_enable_vmi_flag                	OUT NOCOPY      VARCHAR2,
   x_sequence_num                   	OUT NOCOPY      NUMBER,
   p_category_id                        IN  NUMBER default NULL --<Contract AutoSourcing FPJ>
);

--<PKGCOMP R12 Start>
-- Modifying the parameter type for x_asl_id from IN to IN OUT, in order to communicate
-- the ASL_ID back to PO_AUTOSOURCE_SV.document_sourcing.
--<PKGCOMP R12 End>
Procedure get_document_from_asl(
                x_item_id             	  	  IN    NUMBER,
                x_vendor_id           	      IN	NUMBER,
                x_destination_doc_type 	      IN  	VARCHAR2,
                x_currency_code         	  IN    VARCHAR2,
                x_item_rev              	  IN	VARCHAR2,
                x_autosource_date       	  IN    DATE,
                x_vendor_site_id        	  IN OUT NOCOPY  NUMBER,
                x_document_header_id    	  IN OUT NOCOPY  NUMBER,
                x_document_type_code     	  IN OUT NOCOPY  VARCHAR2,
                x_document_line_num     	  IN OUT NOCOPY  NUMBER,
                x_document_line_id      	  IN OUT  NOCOPY NUMBER,
                x_vendor_contact_id     	  IN OUT NOCOPY  NUMBER,
                x_vendor_product_num     	  IN OUT  NOCOPY VARCHAR2,
                x_buyer_id              	  IN OUT NOCOPY  NUMBER,
                x_purchasing_uom        	  IN OUT NOCOPY  VARCHAR2,
                x_asl_id                          IN OUT NOCOPY NUMBER,
                x_multi_org        		      IN    VARCHAR2,
	            p_vendor_site_sourcing_flag   IN 	VARCHAR2,
 	            p_vendor_site_code   	      IN  	VARCHAR2,
                p_org_id                      IN    NUMBER,
                p_item_rev_control            IN    NUMBER,
                p_using_organization_id       IN    NUMBER,
                p_category_id                 IN    NUMBER,  --<Contract AutoSourcing FPJ>
                p_return_contract             IN    VARCHAR2 --<Contract AutoSourcing FPJ>
                --<R12 STYLES PHASE II START>
               ,p_purchase_basis   IN VARCHAR2 DEFAULT NULL,
                p_line_type_id     IN VARCHAR2 DEFAULT NULL,
                p_destination_type IN VARCHAR2 DEFAULT NULL,
                p_style_id         IN NUMBER DEFAULT NULL
                --<R12 STYLES PHASE II END>
);
Procedure get_latest_document(
                x_item_id             	  	  IN    NUMBER,
                x_vendor_id           	          IN	NUMBER,
                x_destination_doc_type 	          IN  	VARCHAR2,
                x_currency_code         	  IN    VARCHAR2,
                x_item_rev              	  IN	VARCHAR2,
                x_autosource_date       	  IN      	DATE,
                x_vendor_site_id        	  IN OUT NOCOPY  NUMBER,
                x_document_header_id    	  IN OUT NOCOPY  NUMBER,
                x_document_type_code     	  IN OUT NOCOPY  VARCHAR2,
                x_document_line_num     	  IN OUT NOCOPY  NUMBER,
                x_document_line_id      	  IN OUT  NOCOPY NUMBER,
                x_vendor_contact_id     	  IN OUT NOCOPY  NUMBER,
                x_vendor_product_num     	  IN OUT  NOCOPY VARCHAR2,
                x_buyer_id              	  IN OUT NOCOPY  NUMBER,
                x_purchasing_uom        	  IN OUT NOCOPY  VARCHAR2,
                x_asl_id                      IN OUT NOCOPY  NUMBER,  --<Bug#4936992>
                x_multi_org        		      IN    VARCHAR2,
	        p_vendor_site_sourcing_flag       IN 	VARCHAR2,
 	        p_vendor_site_code   	          IN  	VARCHAR2,
                p_org_id                      IN    NUMBER,
                p_item_rev_control            IN    NUMBER,
                p_using_organization_id       IN    NUMBER,
                p_category_id                 IN    NUMBER default NULL, --<Contract AutoSourcing FPJ>
                p_return_contract             IN    VARCHAR2 default NULL --<Contract AutoSourcing FPJ>
                --<R12 STYLES PHASE II START>
               ,p_purchase_basis   IN VARCHAR2 DEFAULT NULL,
                p_line_type_id     IN VARCHAR2 DEFAULT NULL,
                p_destination_type IN VARCHAR2 DEFAULT NULL,
                p_style_id         IN NUMBER DEFAULT NULL
                --<R12 STYLES PHASE II END>
);

procedure get_site_id_if_item_on_doc_ok(p_document_header_id  IN NUMBER,
                                        p_item_id  IN NUMBER,
                                        p_vendor_site_sourcing_flag IN VARCHAR2,
                                        p_global_agreement_flag  IN VARCHAR2,
                                        p_document_org_id  IN NUMBER,
                                        x_return_status    OUT NOCOPY VARCHAR2,
                                        x_vendor_site_id  IN OUT  NOCOPY NUMBER,
                                        x_vendor_contact_id IN OUT NOCOPY NUMBER,
                                        p_destination_doc_type IN VARCHAR2, --<Bug 3356349>,
					p_multi_org IN VARCHAR2 --<CTO Bug 4222144>
);
--<Shared Proc FPJ END>

-- SERVICES FPJ Start
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
);

PROCEDURE get_line_amount(p_source_document_header_id IN NUMBER
	           ,  p_source_document_line_id	             IN NUMBER
	           ,  x_base_amount		             OUT NOCOPY NUMBER
	           ,  x_currency_amount	    	             OUT NOCOPY NUMBER
                   ,  x_currency_code                        OUT NOCOPY VARCHAR2
                   ,  x_rate_type                            OUT NOCOPY VARCHAR2
                   ,  x_rate_date                            OUT NOCOPY DATE
                   ,  x_rate                                 OUT NOCOPY NUMBER );

-- SERVICES FPJ End

PROCEDURE get_source_info                                     -- <SERVICES FPJ>
(   p_po_line_id               IN          NUMBER
,   x_from_header_id           OUT NOCOPY  NUMBER
,   x_from_line_id             OUT NOCOPY  NUMBER
,   x_from_line_location_id    OUT NOCOPY  NUMBER
);

FUNCTION has_source_changed                                   -- <SERVICES FPJ>
(   p_po_line_id               IN          NUMBER
,   p_from_header_id           IN          NUMBER
,   p_from_line_id             IN          NUMBER
,   p_from_line_location_id    IN          NUMBER
) RETURN BOOLEAN;

--<Contract AutoSourcing FPJ Start>
PROCEDURE should_return_contract(
  p_destination_doc_type       IN         VARCHAR2,
  p_document_type_code	       IN	  VARCHAR2,
  p_document_subtype	       IN	  VARCHAR2,
  x_return_contract            OUT NOCOPY VARCHAR2,
  x_return_status              OUT NOCOPY VARCHAR2
);
--<Contract AutoSourcing FPJ End>

--<Bug 3545698 mbhargav START>
PROCEDURE item_based_asl_sourcing (
   p_item_id                        	IN      NUMBER,
   p_vendor_id                      	IN      NUMBER,
   p_vendor_site_code               	IN      VARCHAR2,
   p_item_rev				            IN		VARCHAR2,
   p_item_rev_control			        IN		NUMBER,
   p_sourcing_date			            IN 		DATE,
   p_currency_code			            IN		VARCHAR2,
   p_org_id				                IN		NUMBER,
   p_using_organization_id          	IN  OUT NOCOPY  NUMBER,
   x_asl_id                         	OUT NOCOPY      NUMBER,
   x_vendor_product_num             	OUT NOCOPY      VARCHAR2,
   x_purchasing_uom                 	OUT NOCOPY      VARCHAR2,
   x_consigned_from_supplier_flag   	OUT NOCOPY      VARCHAR2,
   x_enable_vmi_flag                	OUT NOCOPY      VARCHAR2,
   x_sequence_num                   	OUT NOCOPY      NUMBER,
   p_category_id                        IN  NUMBER default NULL --<Contract AutoSourcing FPJ>
);

PROCEDURE category_based_asl_sourcing (
   p_item_id                        	IN      NUMBER,
   p_vendor_id                      	IN      NUMBER,
   p_vendor_site_code               	IN      VARCHAR2,
   p_item_rev				            IN		VARCHAR2,
   p_item_rev_control			        IN		NUMBER,
   p_sourcing_date			            IN 		DATE,
   p_currency_code			            IN		VARCHAR2,
   p_org_id				                IN		NUMBER,
   p_using_organization_id          	IN  OUT NOCOPY  NUMBER,
   x_asl_id                         	OUT NOCOPY      NUMBER,
   x_vendor_product_num             	OUT NOCOPY      VARCHAR2,
   x_purchasing_uom                 	OUT NOCOPY      VARCHAR2,
   x_consigned_from_supplier_flag   	OUT NOCOPY      VARCHAR2,
   x_enable_vmi_flag                	OUT NOCOPY      VARCHAR2,
   x_sequence_num                   	OUT NOCOPY      NUMBER,
   p_category_id                        IN  NUMBER default NULL --<Contract AutoSourcing FPJ>
);
--<Bug 3545698 mbhargav END>

--<PKGCOMP R12 Start>
-------------------------------------------------------------------------------
--Start of Comments
--Name: process_req_qty
--Function:
-- This procedure applies the order modifiers on the line level quantity
-- and pro-rates the change in the line level quantity to the distributions.
-- It converts the requisition quantity according the UOM conversion rate
-- passed as the parameter.
-- It also performs rounding operations on the line level quantity depending
-- on the rounding factor, passed as an argument.
--End of Comments
-----------------------------------------------------------------------------
PROCEDURE process_req_qty(p_mode                  IN VARCHAR2,
                          p_request_id            IN NUMBER,
                          p_multi_dist_flag       IN VARCHAR2,
                          p_req_dist_sequence_id  IN NUMBER,
                          p_min_order_qty         IN NUMBER,
                          p_fixed_lot_multiple    IN NUMBER,
                          p_uom_conversion_rate   IN NUMBER,
                          p_rounding_factor       IN NUMBER,
                          p_enforce_full_lot_qty  IN VARCHAR2,
                          x_quantity              IN OUT NOCOPY NUMBER);

-- <Bug # 11778318>
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
, x_consignEnabled_flag       OUT  NOCOPY VARCHAR2

) ;

END PO_AUTOSOURCE_SV;

/
