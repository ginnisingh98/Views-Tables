--------------------------------------------------------
--  DDL for Package Body PODUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PODUS" as
--$Header: ICXPODUB.pls 115.3 99/07/17 03:20:16 porting ship $
--
--
procedure podusauths ( 	p_requisition_header_id in number,
			p_new_status		in varchar2 ) is
--
begin
		--
		UPDATE	po_requisition_headers porh
		SET	porh.authorization_status	= p_new_status,
			porh.last_update_date		= sysdate,
			porh.last_updated_by		= fnd_global.user_id,
			porh.last_update_login		= fnd_global.login_id
		WHERE	porh.requisition_header_id	= p_requisition_header_id;
		--
end;
--
--
procedure podusipah (	p_requisition_header_id	in number,
			p_action 		in varchar2,
			p_fwd_to_id 		in number,
			p_note 			in varchar2  ) is
	l_sequence_number	number;
	l_revision_num 		number :=0;
	l_approval_path_id 	number;
	l_offline_code		varchar2(10);
begin
	select 	max(sequence_num) + 1
	into	l_sequence_number
	from	po_action_history
	where	object_type_code= 'REQUISITION'
	and	object_id	= p_requisition_header_id;
	--
	--
	INSERT into PO_ACTION_HISTORY
	     (object_id,
 	      object_type_code,
	      object_sub_type_code,
	      sequence_num,
	      last_update_date,
	      last_updated_by,
              creation_date,
              created_by,
              action_code,
              action_date,
              employee_id,
              note,
              object_revision_num,
              last_update_login,
              request_id,
              program_application_id,
              program_id,
              program_update_date,
              approval_path_id,
              offline_code)
             VALUES
             (p_requisition_header_id,
	      'REQUISITION',
              'PURCHASE',
              nvl(l_sequence_number,0),
              sysdate,
              fnd_global.user_id,
              sysdate,
              fnd_global.user_id,
              p_action,
              decode(p_action, '',to_date(''), sysdate),
              p_fwd_to_id,
              p_note,
              l_revision_num,
              fnd_global.login_id,
              0,
              0,
              0,
              '',
              l_approval_path_id,
              l_offline_code  );

end podusipah;
--
--
procedure podusupah ( 	p_requisition_header_id	in number,
		   	p_action		in varchar2,
		   	p_note			in varchar2 ) is
--
begin
	--
	UPDATE 	po_action_history
        SET	action_code		= p_action,
		action_date		= sysdate,
                note                	= p_note,
		last_updated_by     	= fnd_global.user_id,
                last_update_date    	= sysdate,
                object_revision_num 	= null,
		approval_path_id    	= null
	WHERE  	object_id           	= p_requisition_header_id
        AND    	object_type_code    	= 'REQUISITION'
        AND	action_code         	IS NULL;
	--
end podusupah;
--
--
procedure podufwd ( 	p_requisition_header_id in number,
			p_action 		in varchar2,
			p_fwd_to_id 		in number,
			p_note			in varchar2 ) is
begin
	--
	--
	podusipah (	p_requisition_header_id	=> p_requisition_header_id,
			p_action		=> to_char(null),
			p_fwd_to_id		=> p_fwd_to_id,
			p_note			=> p_note );

	--
	--
end;
--
--
procedure podustate (	p_requisition_header_id in number,
			p_action 		in varchar2,
			p_emp_id		in number,
			p_note			in varchar2,
			p_new_status    	in varchar2  ) is
--
l_old_status 	po_requisition_headers.authorization_status%TYPE;
--
begin
	select	porh.authorization_status
	into	l_old_status
	from	po_requisition_headers porh
	where	porh.requisition_header_id = p_requisition_header_id;
	--
	--
	if ( l_old_status in ( 'INCOMPLETE', 'RETURNED', 'REJECTED', 'REQUIRES REAPPROVAL') ) then
		--
		podusipah( 	p_requisition_header_id	=> p_requisition_header_id,
 				p_action		=> 'SUBMIT',
				p_fwd_to_id		=> p_emp_id,
				p_note			=> p_note   );
		--
		--
		if ( p_action <> 'SUBMIT' ) then
			--
			podusipah(	p_requisition_header_id => p_requisition_header_id,
					p_action		=> p_action,
					p_fwd_to_id		=> p_emp_id,
					p_note			=> p_note );
		end if;
		--

	elsif ( l_old_status in ('IN PROCESS','PRE-APPROVED') ) then
		--
		-- Update previous record with action being performed
		--
		podusupah(	p_requisition_header_id => p_requisition_header_id,
				p_action		=> p_action,
				p_note			=> p_note  );

	elsif ( l_old_status = 'APPROVED' ) then
		--
		null;  /* wf does not handle this yet */
		--
	end if;
	--
	if ( p_new_status is not null ) then
		--
		podusauths ( p_requisition_header_id 	=> p_requisition_header_id,
			     p_new_status		=> p_new_status );
		--
	end if;
	--
end podustate;
--
--
end podus;

/
