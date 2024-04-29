--------------------------------------------------------
--  DDL for Package PO_SOURCING_RULES_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_SOURCING_RULES_SV" AUTHID CURRENT_USER AS
/* $Header: POXPISRS.pls 120.0 2005/06/01 19:23:37 appldev noship $ */

/*==================================================================
  PROCEDURE NAME:  create_update_sourcing_rule()

  DESCRIPTION:    This API inserts row into mrp_sr_assignments,
		  mrp_sourcing_rules,mrp_sr_receipt_org,
		  mrp_sr_source_org depending on the create or update
		  flag from the approval flag.
		  Validations of start_date,end_date not being null and
		  the approved_status being approved are done here and
		  then create__sourcing_rule is called. If update flag
		  is checked in the approval window then
		  update__sourcing_rule is called.

  PARAMETERS: X_interface_header_id,X_interface_line_id - Sequence generated
		numbers to insert into po_interface_errors.
	      X_item_id,X_vendor_id,X_po_header_id,
	      X_po_line_id,X_document_type,X_approval_status -
		Values of the document for which the sourcing rule is created
		or updated.
	      X_rule_name - Sourcing rule name  that is to be created or updated
	      X_rule_name_prefix - Prefix that we get from the workflow attibute.
		When we create a new sourcing rule the name is
		X_rule_name_prefix_<SR Sequence number);
	      X_start_date,X_end_date -
		The effective_date and disable_date for the sourcing rule.
	      X_create_update_code -
		"CREATE" if create flag in the Approval Window is checked.
		"CREATE_UPDATE" if both create and update flag is checked.
	      X_return_value - Set to N in exception.
	      X_header_processable_flag - Value is N if there was any
		error encountered. Set in the procedure
		PO_INTERFACE_ERRORS_SV1.handle_interface_errors
		X_po_interface_error_code - This is the code used to populate interface_type
        field in po_interface_errors table.


=======================================================================*/
PROCEDURE create_update_sourcing_rule  (
                                     p_interface_header_id   IN NUMBER,
                                     p_interface_line_id     IN NUMBER,
                                     p_item_id               IN NUMBER,
                                     p_vendor_id             IN NUMBER,
                                     p_po_header_id          IN NUMBER,
                                     p_po_line_id            IN NUMBER,
                                     p_document_type         IN VARCHAR2,
                                     p_approval_status       IN VARCHAR2,
                                     p_rule_name             IN VARCHAR2,
				                     p_rule_name_prefix      IN VARCHAR2,
                                     p_start_date            IN DATE,
                                     p_end_date              IN DATE,
                				     p_create_update_code    IN VARCHAR2,
                				     p_organization_id       IN NUMBER,
                				     p_assignment_type_id    IN NUMBER,
                				     p_po_interface_error_code IN VARCHAR2,
                                     x_header_processable_flag IN OUT NOCOPY VARCHAR2,
                				     x_return_status	     OUT NOCOPY VARCHAR2,
----<LOCAL SR/ASL PROJECT 11i11 START>
                                     p_assignment_set_id  IN NUMBER DEFAULT NULL,
                                     p_vendor_site_id     IN NUMBER DEFAULT NULL
----<LOCAL SR/ASL PROJECT 11i11 END>

                                     );

/*==================================================================
  PROCEDURE NAME:  create_sourcing_rule()


  DESCRIPTION:    This API inserts row into mrp_sr_assignments,
		  mrp_sourcing_rules,mrp_sr_receipt_org,
		  mrp_sr_source_org when the create flag in the
		  Approval Window is true.

  PARAMETERS: X_interface_header_id,X_interface_line_id - Sequence generated
		numbers to insert into po_interface_errors.
	      X_item_id,X_vendor_id,X_po_header_id,
	      X_po_line_id,X_document_type,X_approval_status -
		Values of the document for which the sourcing rule is created
		or updated.
	      X_rule_name - Sourcing rule name  that is to be created or updated
	      X_rule_name_prefix - Prefix that we get from the workflow attibute.
	      X_organization_id - We create global sourcing rules as default. But
		if the workflow attribute is set with any org_id, then we use that
		to create a local sourcing rule.
	      X_assignment_tye - Default is item_level(3) but if this is given then
		we set the assignment type to this value
	      X_start_date,X_end_date -
		The effective_date and disable_date for the sourcing rule.
	      X_return_value - Set to N in exception.
	      X_header_processable_flag - Value is N if there was any
		error encountered. Set in the procedure
		PO_INTERFACE_ERRORS_SV1.handle_interface_errors


=======================================================================*/
PROCEDURE create_sourcing_rule  (X_interface_header_id   IN NUMBER,
                                     X_interface_line_id     IN NUMBER,
                                     X_item_id               IN NUMBER,
                                     X_vendor_id             IN NUMBER,
                                     X_po_header_id          IN NUMBER,
                                     X_po_line_id            IN NUMBER,
                                     X_document_type         IN VARCHAR2,
                                     X_rule_name             IN VARCHAR2,
				                     X_rule_name_prefix      IN VARCHAR2,
                                     X_start_date            IN DATE,
                                     X_end_date              IN DATE,
				                     X_organization_id       IN NUMBER,
                                     X_assignment_type_id    IN NUMBER,
                                     x_assignment_set_id     IN NUMBER,
                                     x_sourcing_rule_id      IN OUT NOCOPY NUMBER,
                                     x_temp_sourcing_rule_id IN OUT NOCOPY NUMBER,
                                     x_process_flag IN OUT NOCOPY VARCHAR2,
                                     x_running_status          IN OUT NOCOPY VARCHAR2,
                                     X_header_processable_flag IN OUT NOCOPY VARCHAR2,
----<LOCAL SR/ASL PROJECT 11i11 START>
                                     p_vendor_site_id     IN NUMBER DEFAULT NULL
----<LOCAL SR/ASL PROJECT 11i11 END>
                                     );

/*==================================================================
  PROCEDURE NAME:  update_sourcing_rule()

  DESCRIPTION:    This API inserts row into mrp_sr_assignments,
		  mrp_sourcing_rules,mrp_sr_receipt_org,
		  mrp_sr_source_org when the update flag is true
		  in the Approval Window.

  PARAMETERS: X_interface_header_id,X_interface_line_id - Sequence generated
		numbers to insert into po_interface_errors.
	      X_item_id,X_vendor_id,X_po_header_id,
	      X_po_line_id,X_document_type,X_approval_status -
		Values of the document for which the sourcing rule is created
		or updated.
	      x_sourcing_rule_id-Sourcing rule id from the create_sourcing_rule.
	      X_start_date,X_end_date -
		The effective_date and disable_date for the sourcing rule.
	      X_return_value - Set to N in exception.
	      X_header_processable_flag - Value is N if there was any
		error encountered. Set in the procedure
		PO_INTERFACE_ERRORS_SV1.handle_interface_errors


=======================================================================*/
PROCEDURE update_sourcing_rule  (X_interface_header_id   IN NUMBER,
                                     X_interface_line_id     IN NUMBER,
                                     X_item_id               IN NUMBER,
                                     X_vendor_id             IN NUMBER,
                                     X_po_header_id          IN NUMBER,
                                     X_po_line_id            IN NUMBER,
                                     X_document_type         IN VARCHAR2,
                                     x_sourcing_rule_id      IN NUMBER,
                                     x_temp_sourcing_rule_id IN NUMBER,
                                     X_start_date            IN DATE,
                                     X_end_date              IN DATE,
                                     X_organization_id	     IN NUMBER,
                                     X_assignment_type_id    IN NUMBER,
                                     x_assignment_set_id     IN NUMBER,
                                     x_running_status          IN  OUT NOCOPY VARCHAR2,
                                     X_header_processable_flag IN OUT NOCOPY VARCHAR2,
                                     X_po_interface_error_code IN VARCHAR2,
----<LOCAL SR/ASL PROJECT 11i11 START>
                                     p_vendor_site_id     IN NUMBER DEFAULT NULL
----<LOCAL SR/ASL PROJECT 11i11 END>

                                     );


/*==================================================================
  PROCEDURE NAME:  validate_sourcing_rule()

  DESCRIPTION:    This API validates whether the start_date and end_date
		  have the correct value and whether there is a default
		  assignment set in the profile and whether the document
		  is Approved.


  PARAMETERS: X_interface_header_id,X_interface_line_id - Values from the
		po_headers_interface and po_lines_interface tables.
	      X_item_id,X_vendor_id,X_po_header_id,
	      X_approval_status - Approval status
	      X_rule_name - Sourcing rule name from the po_lines_interface.
	      X_start_date,X_end_date -
		The effective_date and disable_date for the sourcing rule.
	      X_process_flag - OUTparameter which is set to N if error occurs.
	      X_return_value - Set to N in exception.
	      X_header_processable_flag - Value is N if there was any
		error encountered. Set in the procedure
		PO_INTERFACE_ERRORS_SV1.handle_interface_errors


=======================================================================*/
PROCEDURE validate_sourcing_rule  (X_interface_header_id   IN NUMBER,
                                     X_interface_line_id     IN NUMBER,
				     X_approval_status       IN VARCHAR2,
                                     X_rule_name             IN VARCHAR2,
				     X_start_date            IN DATE,
                                     X_end_date              IN DATE,
				     x_assignment_type_id     IN NUMBER,
				     X_organization_id       IN NUMBER,
                                     x_assignment_set_id     IN OUT NOCOPY NUMBER,
				     X_process_flag          IN OUT NOCOPY VARCHAR2,
				     x_running_status          IN  OUT NOCOPY VARCHAR2,
                                     X_header_processable_flag IN OUT NOCOPY VARCHAR2,
				     X_po_interface_error_code IN VARCHAR2);


/*==================================================================
  PROCEDURE NAME:  validate_update_sourcing_rule()

  DESCRIPTION:    This API validates if there is any overlap for a given sourcing rule
			 	  before allowing update to continue.

  PARAMETERS:
		X_interface_header_id,X_interface_line_id - Values from the
        	po_headers_interface and po_lines_interface tables.
        X_start_date,X_end_date -
        	The effective_date and disable_date for the sourcing rule.
        X_process_flag - OUTparameter which is set to N if error occurs.i.e. logic conditions are not met
        X_return_value - Set to N in exception.
        X_header_processable_flag - Value is N if there are any error encountered.
		Set in the procedure PO_INTERFACE_ERRORS_SV1.handle_interface_errors
=======================================================================*/
PROCEDURE validate_update_sourcing_rule  (X_interface_header_id   IN NUMBER,
                                     X_interface_line_id     IN NUMBER,
                                     X_sourcing_rule_id      IN NUMBER,
                                     X_start_date            IN DATE,
                                     X_end_date              IN DATE,
                                     X_assignment_type_id    IN NUMBER,
                                     X_organization_id       IN NUMBER,
                                     x_assignment_set_id     IN OUT NOCOPY NUMBER,
                                     X_process_flag      IN OUT NOCOPY VARCHAR2,
                                     X_running_status      IN OUT NOCOPY VARCHAR2,
                                     X_header_processable_flag IN OUT NOCOPY VARCHAR2,
				     X_po_interface_error_code IN VARCHAR2);

--<Shared Proc FPJ>
PROCEDURE get_vendor_site_id (
   p_po_header_id     IN           NUMBER,
   x_vendor_site_id   OUT NOCOPY   NUMBER);

END PO_SOURCING_RULES_SV;

 

/
