--------------------------------------------------------
--  DDL for Package PO_NEGOTIATIONS_SV2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_NEGOTIATIONS_SV2" AUTHID CURRENT_USER AS
/* $Header: POXNEG3S.pls 120.2.12010000.5 2012/06/29 09:15:35 spapana ship $ */


TYPE who_rec_type IS RECORD                                   -- <SERVICES FPJ>
(   created_by         PO_LINES_ALL.created_by%TYPE
,   creation_date      PO_LINES_ALL.creation_date%TYPE
,   last_update_login  PO_LINES_ALL.last_update_login%TYPE
,   last_updated_by    PO_LINES_ALL.last_updated_by%TYPE
,   last_update_date   PO_LINES_ALL.last_update_date%TYPE
);

/*******************************************************************
  PROCEDURE NAME: default_po_dist_interface()

  DESCRIPTION:    This API defaults the distribution in
		  po_distributions_interface table(for the interface lines
		  which are not backed by a req). This uses account
		  generator to build the accounts.
  Referenced by:  This is called from po_interface_s.setup_interface_tables.
		  from the file POXBWP1B.pls

  CHANGE History: Created      12-Feb-2002     Toju George
*******************************************************************/

PROCEDURE default_po_dist_interface(
			x_interface_header_id 		IN     NUMBER,
			x_interface_line_id 		IN     NUMBER,
			x_item_id 			IN     NUMBER,
			x_category_id 			IN     NUMBER,
			x_ship_to_organization_id 	IN     NUMBER,
			x_ship_to_location_id 		IN     NUMBER,
			x_deliver_to_person_id 		IN     NUMBER,
			x_def_sob_id 			IN     NUMBER,
			x_chart_of_accounts_id 		IN     NUMBER,
			x_line_type_id 			IN     NUMBER,
   x_quantity 			IN     number,
   x_amount                IN     NUMBER,            -- <SERVICES FPJ>
			x_rate 				IN     NUMBER,
			x_rate_date 			IN     DATE,
			x_vendor_id 			IN     NUMBER,
			x_vendor_site_id 		IN     NUMBER,
			x_agent_id 			IN     NUMBER,
			x_po_encumbrance_flag 		IN     VARCHAR2,
			x_ussgl_transaction_code 	IN     VARCHAR2,
			x_type_lookup_code 		IN     VARCHAR2,
			x_expenditure_organization_id 	IN     NUMBER,
			x_project_id 			IN     NUMBER,
			x_task_id 			IN     NUMBER,
			x_bom_resource_id 		IN     NUMBER,
			x_wip_entity_id 		IN     NUMBER,
			x_wip_line_id 			IN     NUMBER,
			x_wip_repetitive_schedule_id 	IN     NUMBER,
			x_gl_encumbered_date 		IN     DATE,
			x_gl_encumbered_period 		IN     VARCHAR2,
			x_destination_subinventory 	IN     VARCHAR2,
			x_expenditure_type 		IN     VARCHAR2,
			x_expenditure_item_date 	IN     DATE,
			x_wip_operation_seq_num 	IN     NUMBER,
			x_wip_resource_seq_num 		IN     NUMBER,
			x_project_accounting_context  	IN     VARCHAR2,
                        p_purchasing_ou_id              IN     NUMBER, --< Shared Proc FPJ >
                        p_unit_price                    IN     NUMBER  --<BUG 3407630>
			);


/*******************************************************************
  PROCEDURE NAME: handle_sourcing_attachments

  DESCRIPTION   : This is the main API which handles all the copying of
		  attachments from req as well as sourcing to po lines and
		  also the creation of new attachments dynamically from
		  different notes in Oracle sourcing.
  Referenced by : This is called from po_interface_s.create_line.
		  from the file POXBWP1B.pls
  parameters    :
		  x_column1             this parameter decides whether to copy
					attachments from only sourcing entities
					or also from requisition.
		  x_attch_suppress_flag this parameter decides whether to
					suppress attachments from negotiation
					due to grouping of two req lines to a
					single po line.
  CHANGE History: Created      12-Feb-2002     Toju George
*******************************************************************/
PROCEDURE handle_sourcing_attachments(
			x_auction_header_id   	IN     NUMBER,
			x_auction_line_number 	IN     NUMBER,
			x_bid_number   		IN     NUMBER,
			x_bid_line_number   	IN     NUMBER,
			x_requisition_header_id IN     NUMBER,
			x_requisition_line_id   IN     NUMBER,
			x_po_line_id   	    	IN     NUMBER,
			x_column1		IN     VARCHAR2,
			x_attch_suppress_flag	IN     VARCHAR2,
			X_created_by 		IN     NUMBER DEFAULT NULL,
			X_last_update_login 	IN     NUMBER DEFAULT NULL);



/*******************************************************************
  PROCEDURE NAME: copy_attachments

  DESCRIPTION   : This API copies attachments from one entity to another
  Referenced by : This is called from handle_sourcing_attachments.
  parameters    :
		  x_column1             this parameter decides whether to copy
					attachments from only sourcing entities
					or also from requisition.
  CHANGE History: Created      12-Feb-2002     Toju George
*******************************************************************/
PROCEDURE copy_attachments(X_from_entity_name 	 IN VARCHAR2,
			X_from_pk1_value 	 IN     VARCHAR2,
			X_from_pk2_value 	 IN     VARCHAR2 DEFAULT NULL,
			X_from_pk3_value 	 IN     VARCHAR2 DEFAULT NULL,
			X_from_pk4_value 	 IN     VARCHAR2 DEFAULT NULL,
			X_from_pk5_value 	 IN     VARCHAR2 DEFAULT NULL,
			X_to_entity_name 	 IN     VARCHAR2,
			X_to_pk1_value 	 	 IN     VARCHAR2,
			X_to_pk2_value 	 	 IN     VARCHAR2 DEFAULT NULL,
			X_to_pk3_value 	 	 IN     VARCHAR2 DEFAULT NULL,
			X_to_pk4_value   	 IN     VARCHAR2 DEFAULT NULL,
			X_to_pk5_value   	 IN     VARCHAR2 DEFAULT NULL,
			X_created_by     	 IN     NUMBER DEFAULT NULL,
			X_last_update_login 	 IN     NUMBER DEFAULT NULL,
			X_program_application_id IN     NUMBER DEFAULT NULL,
			X_program_id 		 IN     NUMBER DEFAULT NULL,
			X_request_id 		 IN     NUMBER DEFAULT NULL,
			X_column1 		 IN     VARCHAR2 DEFAULT NULL);

/*******************************************************************
  PROCEDURE NAME: add_attch_dynamic

  DESCRIPTION   : This API dynamically creates attachments from different
		  notes from the sourcing
  Referenced by : This is called from handle_sourcing_attachments.
  parameters    :
  CHANGE History: Created      12-Feb-2002     Toju George
*******************************************************************/
PROCEDURE add_attch_dynamic(
   X_from_entity_name 		      IN VARCHAR2
,  x_auction_header_id          IN NUMBER
,  x_auction_line_number        IN NUMBER
,  x_bid_number                 IN NUMBER
,  x_bid_line_number            IN NUMBER
,  X_to_entity_name             IN VARCHAR2
,  X_to_pk1_value               IN VARCHAR2
,  X_created_by                 IN NUMBER DEFAULT NULL
,  X_last_update_login          IN NUMBER DEFAULT NULL
,  X_program_application_id     IN NUMBER DEFAULT NULL
,  X_program_id                 IN NUMBER DEFAULT NULL
,  X_request_id                 IN NUMBER DEFAULT NULL
,  p_auction_payment_id         IN NUMBER DEFAULT NULL -- <Complex Work R12>
);

                                                              -- <SERVICES FPJ>
PROCEDURE convert_text_to_attachment ( p_long_text        IN  LONG
                                     , p_description      IN  VARCHAR2
                                     , p_category_id      IN  NUMBER
                                     , p_to_entity_name   IN  VARCHAR2
                                     , p_to_pk1_value     IN  VARCHAR2
                                     , p_who_rec          IN  who_rec_type
                                     );

PROCEDURE convert_text_to_attach_clob ( p_clob_text   IN  CLOB
, p_description      IN  VARCHAR2
, p_category_id      IN  NUMBER
, p_to_entity_name   IN  VARCHAR2
, p_from_entity_name IN  VARCHAR2
, p_to_pk1_value     IN  VARCHAR2
, p_who_rec          IN  who_rec_type
);

-- <Complex Work R12 Start>
PROCEDURE copy_sourcing_payitem_atts(
  p_line_location_id           IN NUMBER
, p_created_by                 IN NUMBER
, p_last_update_login          IN NUMBER
, p_auction_header_id          IN NUMBER
, p_auction_line_number        IN NUMBER
, p_bid_number                 IN NUMBER
, p_bid_line_number            IN NUMBER
);
-- <Complex Work R12 End>


END PO_NEGOTIATIONS_SV2;

/
