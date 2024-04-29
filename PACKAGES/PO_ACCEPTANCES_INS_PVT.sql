--------------------------------------------------------
--  DDL for Package PO_ACCEPTANCES_INS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_ACCEPTANCES_INS_PVT" AUTHID CURRENT_USER AS
/* $Header: POXVIACS.pls 115.2 2003/08/22 00:14:14 rbairraj noship $*/
-- Bug 2850566
-- Modified the specs to accomodate new columns and defaulted the parameters to Null.
PROCEDURE insert_row(
            x_rowid		             IN OUT NOCOPY ROWID,
			x_acceptance_id			 IN OUT NOCOPY NUMBER,
            x_last_update_date       IN OUT NOCOPY  DATE,
            x_last_updated_by        IN OUT NOCOPY  NUMBER,
            x_last_update_login      IN OUT NOCOPY  NUMBER,
			p_creation_date			 IN DATE      DEFAULT NULL,
			p_created_by			 IN NUMBER    DEFAULT NULL,
			p_po_header_id			 IN NUMBER    DEFAULT NULL,
			p_po_release_id			 IN NUMBER    DEFAULT NULL,
			p_action			     IN VARCHAR2  DEFAULT NULL,
			p_action_date			 IN DATE      DEFAULT NULL,
			p_employee_id			 IN NUMBER    DEFAULT NULL,
			p_revision_num			 IN NUMBER    DEFAULT NULL,
			p_accepted_flag			 IN VARCHAR2    DEFAULT NULL,
			p_acceptance_lookup_code IN VARCHAR2    DEFAULT NULL,
			p_note				     IN LONG        DEFAULT NULL,
            p_accepting_party        IN VARCHAR2    DEFAULT NULL,
            p_signature_flag         IN VARCHAR2    DEFAULT NULL,
            p_erecord_id             IN NUMBER      DEFAULT NULL,
            p_role                   IN VARCHAR2    DEFAULT NULL,
			p_attribute_category	 IN VARCHAR2    DEFAULT NULL,
			p_attribute1			 IN VARCHAR2    DEFAULT NULL,
			p_attribute2			 IN VARCHAR2    DEFAULT NULL,
			p_attribute3			 IN VARCHAR2    DEFAULT NULL,
			p_attribute4			 IN VARCHAR2    DEFAULT NULL,
			p_attribute5			 IN VARCHAR2    DEFAULT NULL,
			p_attribute6			 IN VARCHAR2    DEFAULT NULL,
			p_attribute7			 IN VARCHAR2    DEFAULT NULL,
			p_attribute8			 IN VARCHAR2    DEFAULT NULL,
			p_attribute9			 IN VARCHAR2    DEFAULT NULL,
			p_attribute10			 IN VARCHAR2    DEFAULT NULL,
			p_attribute11			 IN VARCHAR2    DEFAULT NULL,
			p_attribute12			 IN VARCHAR2    DEFAULT NULL,
			p_attribute13			 IN VARCHAR2    DEFAULT NULL,
			p_attribute14			 IN VARCHAR2    DEFAULT NULL,
			p_attribute15			 IN VARCHAR2    DEFAULT NULL,
			p_request_id			 IN NUMBER      DEFAULT NULL,
			p_program_application_id IN NUMBER      DEFAULT NULL,
			p_program_id			 IN NUMBER      DEFAULT NULL,
			p_program_update_date	 IN DATE        DEFAULT NULL,
            p_po_line_location_id    IN NUMBER      DEFAULT NULL);

END PO_ACCEPTANCES_INS_PVT;

 

/
