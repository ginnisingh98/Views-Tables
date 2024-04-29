--------------------------------------------------------
--  DDL for Package Body POREQ
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POREQ" as
--$Header: ICXPORQB.pls 115.1 99/07/17 03:20:22 porting ship $
--
--
/*------------------------------------------------------------------------
|                                                                         |
| PRIVATE FUNCTIONS                                                       |
|                                                                         |
--------------------------------------------------------------------------*/
--
--
function GetApproverDirect(p_requisition_header_id in number, p_employee_id in number,p_approval_path_id  in number ) return number;
--
--
function GetApproverHier ( p_employee_id in number , p_approval_path_id in number ) return number;
--
--
/*------------------------------------------------------------------------
|                                                                         |
| PRIVATE VARIABLES                                                       |
|                                                                         |
--------------------------------------------------------------------------*/
--
fsp financials_system_parameters%ROWTYPE;
--
--
Procedure GetReqInfo(	p_requisition_header_id	in   number,
			p_req_info		out  ReqInfoType ) is
--
begin
	--
	--
	SELECT	porh.preparer_id,
		'REQUISITION',
		porh.type_lookup_code,
		podt.forwarding_mode_code,
		nvl(podt.default_approval_path_id,0),
		nvl(can_preparer_approve_flag,'N')
	INTO	p_req_info
	FROM	po_requisition_headers porh,
		po_document_types podt
	WHERE	porh.requisition_header_id = p_requisition_header_id
	AND	podt.document_type_code	   = 'REQUISITION'
	AND	podt.document_subtype      = porh.type_lookup_code;
	--
	--
end GetReqInfo;
--
--
function GetCurrentOwner( p_requisition_header_id in number ) return number is
--
l_employee_id number;
--
begin
	--
	SELECT	nvl(poac.employee_id,porh.preparer_id)
	INTO	l_employee_id
	FROM	po_action_history poac,
		po_requisition_headers porh
	WHERE	porh.requisition_header_id = p_requisition_header_id
	AND	porh.requisition_header_id = poac.object_id(+)
	AND	poac.object_type_code(+)   = 'REQUISITION'
	AND	poac.action_code	   is null;
	--
	return(l_employee_id);
exception
	when NO_DATA_FOUND then
		return(null);
	--
end GetCurrentOwner;
--
--
function GetApprover(   p_requisition_header_id in number,
			p_employee_id 	   	in number,
			p_approval_path_id 	in number,
			p_forwarding_mode_code	in varchar2  ) return number is
--
l_approver_id number;
--
begin
	if ( p_forwarding_mode_code = 'DIRECT' ) then
		--
		l_approver_id := GetApproverDirect( p_requisition_header_id,p_employee_id, p_approval_path_id);
		--
	elsif ( p_forwarding_mode_code = 'HIERARCHY' ) then
		--
		l_approver_id := GetApproverHier(p_employee_id,p_approval_path_id);
		--
	end if;
	--
	return(l_approver_id);
	--
end GetApprover;
--
--
Function GetApproverDirect( 	p_requisition_header_id in number,
				p_employee_id 		in number,
				p_approval_path_id  	in number ) return number is
--
cursor GetApproverPos( b_employee_id number, b_approval_path_id number ) is
	--
	SELECT	poeh.superior_id forward_to_id
	FROM  	hr_employees_current_v hrec,
        	po_employee_hierarchies poeh
 	WHERE 	poeh.position_structure_id 	= b_approval_path_id
 	AND     poeh.employee_id 		= b_employee_id
 	AND   	hrec.employee_id 		= poeh.superior_id
 	AND    	poeh.superior_level 		> 0
 	ORDER
	BY 	poeh.superior_level, hrec.full_name;
	--
cursor GetApproverSup( b_employee_id number ) is
	--
	SELECT	pera.supervisor_id forward_to_id
 	FROM   	per_assignments_f pera
 	WHERE  	pera.business_group_id = fsp.business_group_id
 	AND    	TRUNC(sysdate) 	BETWEEN pera.effective_start_date
          			AND 	pera.effective_end_date
 	CONNECT
	BY 	pera.person_id = prior pera.supervisor_id
 	START
	WITH 	pera.person_id = b_employee_id;
	--
begin
	--
	if ( fsp.use_positions_flag = 'Y' ) then
		--
		for pos_rec in GetApproverPos(p_employee_id,p_approval_path_id) loop
			--
			if (VerifyAuthority(p_requisition_header_id,pos_rec.forward_to_id)) then
				--
				return(pos_rec.forward_to_id);
				--
			else
				null;
			end if;
			--
		end loop;
	else
		for sup_rec in GetApproverSup( p_employee_id ) loop
			--
			if (VerifyAuthority(p_requisition_header_id,sup_rec.forward_to_id) )then
				--
				return(sup_rec.forward_to_id);
				--
			else
				null;
			end if;
			--
		end loop;
	end if;
	--
	return(null);
	--
end GetApproverDirect;
--
function GetApproverHier ( p_employee_id in number , p_approval_path_id in number ) return number is
--
l_approver_id number;
--
cursor GetApproverPos( b_employee_id number, b_approval_path_id number ) is
	--
	SELECT	poeh.superior_id
	FROM   	po_employee_hierarchies poeh,
               	hr_employees_current_v hremp
      	WHERE  	poeh.employee_id 		= b_employee_id
        AND	poeh.position_structure_id 	= b_approval_path_id
        AND	poeh.superior_level 		= 1
        AND    	hremp.employee_id 		= poeh.superior_id
        ORDER
	BY 	hremp.full_name;
	--
cursor GetApproverSup  (  b_employee_id number ) is
	--
	SELECT 	hremp.supervisor_id
	FROM	hr_employees_current_v hremp
	WHERE	hremp.employee_id = b_employee_id;
	--
begin
	--
	if ( fsp.use_positions_flag = 'Y' ) then
		--
		open GetApproverPos ( 	b_employee_id 		=> p_employee_id,
					b_approval_path_id	=> p_approval_path_id );
		--
		fetch 	GetApproverPos into l_approver_id;
		close   GetApproverPos;
		--
	else
		--
		open 	GetApproverSup ( b_employee_id => p_employee_id );
		fetch 	GetApproverSup into l_approver_id;
		close   GetApproverSup;
		--
	end if;
	--
	return(l_approver_id);
	--
end GetApproverHier;
--
--
function VerifyAuthority( p_requisition_header_id in number,
			  p_employee_id	   	  in number ) return boolean is
--
l_control_function_id 	number;
l_position_id		number;
l_job_id		number;
l_doc_approval_limit	number;
l_ReqInfo		ReqInfoType;
--
begin
	--
	GetReqInfo(p_requisition_header_id,l_ReqInfo);
	--
	SELECT  pocf.control_function_id
        INTO    l_control_function_id
        FROM    po_control_functions pocf
        WHERE   pocf.document_type_code = 'REQUISITION'
        AND     pocf.document_subtype 	=  l_reqinfo.sub_type
        AND     pocf.action_type_code 	= 'APPROVE'
        AND     pocf.enabled_flag 	= 'Y';
	--
	if ( fsp.use_positions_flag = 'Y' ) then
		--
		SELECT  nvl(PAF.position_id,0)
	    	INTO    l_position_id
 	    	FROM    per_assignments_f paf
	    	WHERE   paf.person_id 		= p_employee_id
            	AND     paf.assignment_type 	= 'E'
            	AND     paf.primary_flag 	= 'Y'
	    	AND     sysdate BETWEEN paf.effective_start_date AND paf.effective_end_date;
		--
		--
		if ( l_position_id = 0 ) then
			--
			return(FALSE);
		end if;
		--
		--
		SELECT 	Min(pocr.amount_limit)
		INTO	l_doc_approval_limit
		FROM    po_control_rules pocr,
			po_control_groups pocg,
			po_position_controls popc
		WHERE  	popc.position_id 			= l_position_id
		AND    	sysdate 				BETWEEN NVL(popc.start_date, sysdate	- 1 )
								AND 	NVL(popc.end_date,sysdate + 1 )
		AND	popc.control_function_id 		= l_control_function_id
		AND    	pocg.enabled_flag 			= 'Y'
		AND    	pocg.control_group_id 			= popc.control_group_id
		AND    	pocr.control_group_id 			= pocg.control_group_id
		AND    	pocr.object_code 			= 'DOCUMENT_TOTAL'
		AND    	NVL(pocr.inactive_date, sysdate+1) 	> sysdate;
		--
		--
	else	-- Not using positions
		--
		SELECT  nvl(paf.job_id, 0)
	    	INTO    l_job_id
 	    	FROM    per_assignments_f PAF
	    	WHERE   paf.person_id 		= p_employee_id
            	AND     paf.assignment_type 	= 'E'
            	AND     paf.primary_flag 	= 'Y'
	    	AND     sysdate BETWEEN paf.effective_start_date AND paf.effective_end_date;
		--
		if ( l_job_id = 0 ) then
			--
			return(FALSE);
			--
		end if;
		--
		SELECT 	Min(pocr.amount_limit)
		INTO	l_doc_approval_limit
		FROM    po_control_rules pocr,
			po_control_groups pocg,
			po_position_controls popc
		WHERE  	popc.job_id 				= l_job_id
		AND    	sysdate 				BETWEEN NVL(popc.start_date, sysdate - 1 )
								AND 	NVL(popc.end_date,sysdate + 1 )
		AND	popc.control_function_id 		= l_control_function_id
		AND    	pocg.enabled_flag 			= 'Y'
		AND    	pocg.control_group_id 			= popc.control_group_id
		AND    	pocr.control_group_id 			= pocg.control_group_id
		AND    	pocr.object_code 			= 'DOCUMENT_TOTAL'
		AND    	NVL(pocr.inactive_date, sysdate+1) 	> sysdate;
		--
		--
	end if;
	--
	if l_doc_approval_limit >= pogot_s.get_total('E',P_requisition_header_id,TRUE) then
		--
		return(TRUE);
		--
	else
		--
		return(FALSE);
		--
	end if;
	--
exception
	when NO_DATA_FOUND then
		return(FALSE);
	--
end VerifyAuthority;
--
begin -- initialize section
	--
	select 	*
	into	fsp
	from 	financials_system_parameters;
	--
	select 	currency_code
	into  	poreq.functional_currency
	from 	gl_sets_of_books
	where 	set_of_books_id = fsp.set_of_books_id;
	--
end poreq;

/
