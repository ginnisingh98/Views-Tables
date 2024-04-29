--------------------------------------------------------
--  DDL for Package PSP_XMLGEN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSP_XMLGEN" AUTHID CURRENT_USER AS
/* $Header: PSPXMLGS.pls 120.4.12010000.1 2008/07/28 08:12:55 appldev ship $ */
FUNCTION generate_approver_header_xml (p_request_id IN NUMBER DEFAULT NULL) RETURN CLOB;
FUNCTION generate_approver_xml	(p_wf_item_key		IN	NUMBER,
				p_request_id		IN	NUMBER DEFAULT NULL) RETURN CLOB;
FUNCTION generate_person_xml	(p_person_id		IN	NUMBER,
				p_template_id		IN	NUMBER,
				p_effort_report_id	IN	NUMBER,
				p_request_id		IN	NUMBER,
				p_set_of_books_id	IN	NUMBER,
				p_full_name		IN	VARCHAR2,
				p_employee_number	IN	VARCHAR2,
				p_mailstop		IN	VARCHAR2,
				p_emp_primary_org_name	IN	VARCHAR2,
				p_emp_primary_org_id	IN	NUMBER,
				p_currency_code		IN	VARCHAR2 ) RETURN CLOB;

PROCEDURE store_pdf	(p_wf_item_key		IN		NUMBER,
                    	p_receiver_flag		IN		VARCHAR2,
			p_file_id		OUT NOCOPY	NUMBER,
			p_wf_Role_Name          IN              VARCHAR2);

PROCEDURE attach_pdf	(p_item_type_key	IN		VARCHAR2,
			content_type		IN		VARCHAR2,
			p_document		IN OUT	NOCOPY	BLOB,
			p_document_type		IN OUT	NOCOPY	VARCHAR2);

PROCEDURE	update_er_person_xml	(p_start_person		IN		NUMBER,
					p_end_person		IN		NUMBER,
					p_request_id		IN		NUMBER,
					p_retry_request_id	IN		NUMBER	DEFAULT NULL,
					p_return_status		OUT	NOCOPY	VARCHAR2);

PROCEDURE	update_er_person_xml	(p_request_id	IN		NUMBER,
					p_return_status	OUT	NOCOPY	VARCHAR2);

PROCEDURE	update_er_person_xml	(p_wf_item_key	IN		NUMBER,
					p_return_status	OUT	NOCOPY	VARCHAR2);

PROCEDURE	update_er_details	(p_start_person		IN		NUMBER,
					p_end_person		IN		NUMBER,
					p_request_id		IN		NUMBER,
					p_retry_request_id	IN		NUMBER	DEFAULT NULL,
					p_return_status		OUT	NOCOPY	VARCHAR2);
PROCEDURE COPY_PTAOE_FROM_GL_SEGMENTS (p_start_person		IN		NUMBER,
				p_end_person		IN		NUMBER,
				p_request_id		IN		NUMBER,
				p_retry_request_id	IN		NUMBER	DEFAULT NULL,
		                p_business_group_id IN          NUMBER,
				p_return_status		OUT	NOCOPY	VARCHAR2);
function convert_xml_controls(p_string varchar2) return varchar2; --- added for uva issues .. 4429787

PROCEDURE	update_er_error_details	(p_request_id		IN		NUMBER,
					p_retry_request_id	IN		NUMBER,
					p_return_status		OUT	NOCOPY	VARCHAR2);


/* Procedure Added for Hospital effort report */

PROCEDURE update_grouping_category (	p_start_person		IN		NUMBER,
					p_end_person		IN		NUMBER,
					p_request_id		IN		NUMBER,
					p_return_status		OUT	NOCOPY	VARCHAR2) ;
END PSP_XMLGEN;

/
