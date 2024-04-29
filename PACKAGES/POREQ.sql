--------------------------------------------------------
--  DDL for Package POREQ
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POREQ" AUTHID CURRENT_USER as
--$Header: ICXPORQS.pls 115.1 99/07/17 03:20:25 porting ship $
--
--
TYPE ReqInfoType IS RECORD
	( 	preparer_id			po_requisition_headers.preparer_id%TYPE,
		type				varchar2(30) := 'REQUISITION',
		sub_type			po_requisition_headers.type_lookup_code%TYPE,
		forwarding_mode_code 		po_document_types.forwarding_mode_code%TYPE,
		approval_path_id 		po_document_types.default_approval_path_id%TYPE,
		can_preparer_approve_flag 	po_document_types.can_preparer_approve_flag%TYPE
	);
--
--
functional_currency gl_sets_of_books.currency_code%TYPE;
--
--
Procedure GetReqInfo(	p_requisition_header_id in  number,
			p_req_info		out  ReqInfoType );
--
function GetCurrentOwner( p_requisition_header_id in number ) return number;
--
function GetApprover( 	p_requisition_header_id in number,
			p_employee_id 		in number,
			p_approval_path_id 	in number,
			p_forwarding_mode_code 	in varchar2 ) return number;
--
function VerifyAuthority ( 	p_requisition_header_id in number,
				p_employee_id 		in number ) return boolean;
--
end poreq;

 

/
