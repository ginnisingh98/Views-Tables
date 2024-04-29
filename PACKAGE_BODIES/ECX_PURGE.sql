--------------------------------------------------------
--  DDL for Package Body ECX_PURGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ECX_PURGE" as
/* $Header: ECXPRGB.pls 120.4.12010000.3 2008/10/08 21:12:12 cpeixoto ship $*/
-- procedure PURGE
--   Delete records from ecx_outbound_logs which don't have item_type, item_key
--	(To delete records which don't have an entry in ecx_doclogs)
-- IN:
--   transaction_type - transaction type to delete, or null for all transaction type
--   transaction_subtype - transaction subtype to delete, or null for all transaction subtype
--   party_id - party id to delete, or null for all party id
--   party_site_id - party site id to delete, or null for all party site id
--   fromdate - from Date or null to start from begining
--   todate - end Date or null to delete till latest record
--   commitFlag- Do not commit if set to false
--
procedure PURGE_OUTBOUND(transaction_type	in	varchar2,
		transaction_subtype	in	varchar2,
		party_id		in	varchar2,
		party_site_id		in	varchar2,
		fromDate		in	date,
		toDate			in	date,
		commitFlag		in boolean) IS

	TYPE t_trigger_id_tl is TABLE of ecx_outbound_logs.trigger_id%type;
	TYPE t_error_id_tl is TABLE of ecx_msg_logs.error_id%type;

	v_trigger_id_tl t_trigger_id_tl := t_trigger_id_tl();
	v_error_id_tl t_error_id_tl;

        l_CursorID             number;
        l_result        NUMBER;
        l_Select        VARCHAR2(2400);
        l_trigger_ID     ecx_outbound_logs.trigger_id%type;

	cursor get_out_error_id (p_trigger_id in ecx_outbound_logs.TRIGGER_ID%type) is
		select error_id from ecx_msg_logs where trigger_id = p_trigger_id;

	bulk_delete_cycles pls_integer;
	bulk_delete_first pls_integer;
	bulk_delete_last pls_integer;

	begin

                l_Select:= 'select trigger_id from ecx_outbound_logs where 1=1 ';


                if transaction_type is not null then
                   l_Select := l_Select || 'and transaction_type = :transaction_type ';
                end if;
                if transaction_subtype is not null then
                   l_Select := l_Select || 'and transaction_subtype = :transaction_subtype ';
                end if;
                if party_id is not null then
                   l_Select := l_Select || 'and party_id = :party_id ';
                end if;
                if party_site_id is not null then
                   l_Select := l_Select || 'and party_site_id = :party_site_id ';
                end if;
                if fromDate is not null then
                   l_Select := l_Select || 'and time_stamp >= :fromDate ';
                end if;
                if toDate is not null then
                   l_Select := l_Select || 'and time_stamp <= :toDate ';
                end if;

                l_Select := l_Select || ' for update nowait ';

                l_CursorID := DBMS_SQL.OPEN_CURSOR;
                DBMS_SQL.parse(l_CursorID, l_Select, DBMS_SQL.V7);

                DBMS_SQL.define_column(l_CursorID, 1, l_trigger_id );

               if transaction_type is not null then
                   DBMS_SQL.bind_variable(l_CursorID , ':transaction_type' , transaction_type);
                end if;
                if transaction_subtype is not null then
                   DBMS_SQL.bind_variable(l_CursorID , ':transaction_subtype' , transaction_subtype);
                end if;
                if party_id is not null then
                   DBMS_SQL.bind_variable(l_CursorID , ':party_id' , party_id);
                end if;
                if party_site_id is not null then
                  DBMS_SQL.bind_variable(l_CursorID , ':party_site_id' , party_site_id);
                end if;
                if fromDate is not null then
                   DBMS_SQL.bind_variable(l_CursorID , ':fromDate' , fromDate);
                end if;
                if toDate is not null then
                   DBMS_SQL.bind_variable(l_CursorID , ':toDate' , toDate);
                end if;

                l_result := DBMS_SQL.EXECUTE(l_CursorID);

                loop

                   if dbms_sql.fetch_rows( l_CursorID ) > 0 then

                      DBMS_SQL.column_value(l_CursorID,     1, l_trigger_id );

                      v_trigger_id_tl.extend;

                      v_trigger_id_tl( v_trigger_id_tl.last ) := l_trigger_id;
                  else
                     exit;
                  end if;
                end loop;

		for i IN 1..v_trigger_id_tl.count loop

                               open get_out_error_id(v_trigger_id_tl(i));
				fetch get_out_error_id bulk collect into v_error_id_tl ;
                                 close get_out_error_id;


		bulk_delete_cycles := round(v_error_id_tl.count/commit_frequency_ecx + 0.5);
--		dbms_output.put_line('commit_frequency = '|| to_char(commit_frequency_ecx));
		if(v_error_id_tl.count > 0) then
--			dbms_output.put_line('Purge_Outbound.v_error_id_tl.count = '|| to_char(v_error_id_tl.count));
			For i IN 1..bulk_delete_cycles loop
				bulk_delete_first := ((i-1) * commit_frequency_ecx) + 1;
				bulk_delete_last := bulk_delete_first  + commit_frequency_ecx;
				IF (bulk_delete_last > v_error_id_tl.count) THEN
					bulk_delete_last := v_error_id_tl.count;
				END IF;
				FORALL j IN bulk_delete_first..bulk_delete_last
					delete from ecx_error_msgs where error_id = v_error_id_tl(j);
				IF (commitFlag) THEN
--					dbms_output.put_line('v_error_id_tl.count Purge_Outbound commiting ecx_error_msgs i = '|| to_char(i));
					commit;
				END IF;
				FORALL j IN bulk_delete_first..bulk_delete_last
					delete from ecx_msg_logs where error_id = v_error_id_tl(j);
				IF (commitFlag) THEN
--					dbms_output.put_line('v_error_id_tl.count Purge_Outbound commiting ecx_msg_logs i = '|| to_char(i));
					commit;
				END IF;
			end loop;
		end if;

		if (v_trigger_id_tl.count > 0) then
			bulk_delete_cycles := round(v_trigger_id_tl.count/commit_frequency_ecx + 0.5);
			For i IN 1..bulk_delete_cycles loop
				bulk_delete_first := ((i-1) * commit_frequency_ecx) + 1;
				bulk_delete_last := bulk_delete_first  + commit_frequency_ecx;
				IF (bulk_delete_last > v_trigger_id_tl.count) THEN
					bulk_delete_last := v_trigger_id_tl.count;
				END IF;
				FORALL j IN bulk_delete_first..bulk_delete_last
					delete from ecx_outbound_logs WHERE trigger_id = v_trigger_id_tl(j);
				IF (commitFlag) THEN
					commit;
				END IF;
			end loop;
		end if;
  END LOOP;
	exception
	WHEN others THEN
	  Wf_Core.Context('ECX_Purge', 'Purge_Outbound', transaction_type, transaction_subtype,party_id,party_site_id,to_char(fromDate),to_char(toDate));
	   raise;
end PURGE_OUTBOUND;
--
-- procedure PURGE
--   Delete ecx log from given criteria.
-- IN:
--   itemtype - Item type to delete, or null for all itemtypes
--   itemkey - Item key to delete, or null for all itemkeys
--   transaction_type - transaction type to delete, or null for all transaction type
--   transaction_subtype - transaction subtype to delete, or null for all transaction subtype
--   party_id - party id to delete, or null for all party id
--   party_site_id - party site id to delete, or null for all party site id
--   fromdate - from Date or null to start from begining
--   todate - end Date or null to delete till latest record
--   docommit- Do not commit if set to false
--   runtimeonly - Delete data which is associated with workflow, if set to true
--
procedure PURGE(item_type		in	varchar2,
		item_key 		in 	varchar2,
		transaction_type	in	varchar2,
		transaction_subtype	in	varchar2,
		party_id		in	varchar2,
		party_site_id		in	varchar2,
		fromDate		in	date,
		toDate			in	date,
		commitFlag		in boolean,
		runtimeonly		in boolean) IS
        l_msgId                 RAW(16);
        l_item_type             ecx_doclogs.item_type%type;
        l_item_key              ecx_doclogs.item_key%type;
        l_errId                 number(16);
        delCounter              number(4);
        l_commitFlag             boolean := commitFlag;
        l_runtimeonly            boolean := runtimeonly;
        l_CursorID             number;
        l_result        NUMBER;
        l_Select        VARCHAR2(2400);



	cursor get_in_trigger_id (p_msgid in ecx_doclogs.msgid%type) is
		select trigger_id from ecx_inbound_logs where msgid is not null and msgid = hextoraw(p_msgid);
	cursor get_out_trigger_id (p_msgid in ecx_doclogs.msgid%type) is
		select trigger_id from ecx_outbound_logs where out_msgid is not null and out_msgid = hextoraw(p_msgid);
	cursor get_ext_log_error_id (p_msgid in ecx_doclogs.msgid%type) is
		select error_id from ecx_external_logs where out_msgid is not null and out_msgid = hextoraw(p_msgid);
	cursor get_ext_ret_error_id (p_msgid in ecx_doclogs.msgid%type) is
		select error_id from ecx_external_retry where msgid = p_msgid;
        cursor get_in_error_id (p_trigger_id in ecx_msg_logs.trigger_id%type) is
		select error_id from ecx_msg_logs where trigger_id = p_trigger_id;
	cursor get_out_error_id (p_trigger_id in ecx_msg_logs.ERROR_ID%type) is
		select error_id from ecx_msg_logs where trigger_id = p_trigger_id;

	TYPE t_message_id_tl is TABLE of ecx_doclogs.msgid%type;
	TYPE t_itemtype_id_tl is TABLE of ecx_doclogs.item_type%type;
	TYPE t_itemkey_id_tl is TABLE of ecx_doclogs.item_key%type;
	TYPE t_out_error_id_tl is TABLE of ecx_outbound_logs.error_id%type;
	TYPE t_ext_log_error_id_tl is TABLE of ecx_external_logs.error_id%type;
	TYPE t_ext_ret_error_id_tl is TABLE of ecx_external_retry.error_id%type;
	TYPE t_in_trigger_id_tl is TABLE of ecx_msg_logs.trigger_id%type;
	TYPE t_out_trigger_id_tl is TABLE of ecx_msg_logs.trigger_id%type;
	TYPE t_in_error_id_tl is TABLE of ecx_msg_logs.error_id%type;

	v_message_id_tl t_message_id_tl:= t_message_id_tl();
	v_itemtype_tl t_itemtype_id_tl := t_itemtype_id_tl();
	v_itemkey_tl t_itemkey_id_tl   := t_itemkey_id_tl();
	v_out_trigger_id_tl t_out_trigger_id_tl;
	v_out_error_id_tl t_out_error_id_tl;
	v_ext_log_error_id_tl t_ext_log_error_id_tl;
	v_ext_ret_error_id_tl t_ext_ret_error_id_tl;
        v_in_trigger_id_tl t_in_trigger_id_tl;
	v_in_error_id_tl t_in_error_id_tl;

	bulk_delete_first pls_integer;
	bulk_delete_last pls_integer;

	status varchar2(200);
	result varchar2(200);
	purgable boolean := true;
	is_bulk_delete_cycle boolean := false;
	begin
		IF (commitFlag is null) THEN
			l_commitFlag := false;
		END IF;
		IF (runtimeonly is null) THEN
			l_runtimeonly := false;
		END IF;


                l_Select:= 'select msgid, item_type, item_key from ecx_doclogs where 1 = 1 ' ;

                if item_type is not null then
                   l_Select := l_Select || 'and item_type = :item_type ';
                end if;
                if item_key is not null then
                   l_Select := l_Select || 'and item_key = :item_key ';
                end if;
                if transaction_type is not null then
                   l_Select := l_Select || 'and transaction_type = :transaction_type ';
                end if;
                if transaction_subtype is not null then
                   l_Select := l_Select || 'and transaction_subtype = :transaction_subtype ';
                end if;
                if party_id is not null then
                   l_Select := l_Select || 'and party_id = :party_id ';
                end if;
                if party_site_id is not null then
                   l_Select := l_Select || 'and party_site_id = :party_site_id ';
                end if;
                if fromDate is not null then
                   l_Select := l_Select || 'and time_stamp >= :fromDate ';
                end if;
                if toDate is not null then
                   l_Select := l_Select || 'and time_stamp <= :toDate ';
                end if;

                l_Select := l_Select || ' for update nowait ';

                l_CursorID := DBMS_SQL.OPEN_CURSOR;
                DBMS_SQL.parse(l_CursorID, l_Select, DBMS_SQL.V7);

                DBMS_SQL.define_column_raw(l_CursorID, 1, l_msgId  , 16);
                DBMS_SQL.define_column(l_CursorID,     2, l_item_type, 8);
                DBMS_SQL.define_column(l_CursorID,     3, l_item_key , 240);

                if item_type is not null then
                   DBMS_SQL.bind_variable(l_CursorID , ':item_type' , item_type);
                end if;
                if item_key is not null then
                   DBMS_SQL.bind_variable(l_CursorID , ':item_key' , item_key);
                end if;
                if transaction_type is not null then
                   DBMS_SQL.bind_variable(l_CursorID , ':transaction_type' , transaction_type);
                end if;
                if transaction_subtype is not null then
                   DBMS_SQL.bind_variable(l_CursorID , ':transaction_subtype' , transaction_subtype);
                end if;
                if party_id is not null then
                   DBMS_SQL.bind_variable(l_CursorID , ':party_id' , party_id);
                end if;
                if party_site_id is not null then
                   DBMS_SQL.bind_variable(l_CursorID , ':party_site_id' , party_site_id);
                end if;
                if fromDate is not null then
                   DBMS_SQL.bind_variable(l_CursorID , ':fromDate' , fromDate);
                end if;
                if toDate is not null then
                   DBMS_SQL.bind_variable(l_CursorID , ':toDate' , toDate);
                end if;

                l_result := DBMS_SQL.EXECUTE(l_CursorID);

                loop


                   if dbms_sql.fetch_rows( l_CursorID ) > 0 then

                      DBMS_SQL.column_value_raw(l_CursorID, 1, l_msgId   );
                      DBMS_SQL.column_value(l_CursorID,     2, l_item_type );
                      DBMS_SQL.column_value(l_CursorID,     3, l_item_key  );

                      v_message_id_tl.extend;
                      v_itemtype_tl.extend;
                      v_itemkey_tl.extend;


                     v_message_id_tl( v_message_id_tl.last ) := l_msgId;
                     v_itemtype_tl(   v_itemtype_tl.last ) := l_item_type;
                     v_itemkey_tl(    v_itemkey_tl.last ) := l_item_key;

                  else
                     exit;
                  end if;
                end loop;



		for i IN 1..v_message_id_tl.count loop
			purgable := true;
			status := '';
			if(purgable) then
			open get_in_trigger_id(v_message_id_tl(i));
			fetch get_in_trigger_id bulk collect into v_in_trigger_id_tl ;
				FOR i IN 1..v_in_trigger_id_tl.count
                                  LOOP
                                  open get_in_error_id (v_in_trigger_id_tl(i));
                                  fetch get_in_error_id bulk collect into v_in_error_id_tl ;
                                  FORALL i IN 1..v_in_error_id_tl.count
                                  delete from ecx_error_msgs where error_id =v_in_error_id_tl(i);
                                  FORALL i IN 1..v_in_error_id_tl.count
                                  delete from ecx_msg_logs where error_id =v_in_error_id_tl(i);
				  close get_in_error_id;
                                 END LOOP;
			close get_in_trigger_id;

				open get_out_trigger_id(v_message_id_tl(i));
				fetch get_out_trigger_id bulk collect into v_out_trigger_id_tl ;
				FOR i IN 1..v_out_trigger_id_tl.count
                                  LOOP
                                  open get_out_error_id (v_out_trigger_id_tl(i));
                                  fetch get_out_error_id bulk collect into v_out_error_id_tl ;
                                  FORALL i IN 1..v_out_error_id_tl.count
                                  delete from ecx_error_msgs where error_id =v_out_error_id_tl(i);
                                  FORALL i IN 1..v_out_error_id_tl.count
                                  delete from ecx_msg_logs where error_id =v_out_error_id_tl(i);
				  close get_out_error_id;
                                 END LOOP;
		       close get_out_trigger_id;


				open get_ext_log_error_id(v_message_id_tl(i));
				fetch get_ext_log_error_id bulk collect into v_ext_log_error_id_tl ;
				close get_ext_log_error_id;

				open get_ext_ret_error_id(v_message_id_tl(i));
				fetch get_ext_ret_error_id bulk collect into v_ext_ret_error_id_tl;
				close get_ext_ret_error_id;


				FORALL i IN 1..v_ext_log_error_id_tl.count
					delete from ecx_error_msgs where error_id = v_ext_log_error_id_tl(i);

				FORALL i IN 1..v_ext_log_error_id_tl.count
					delete from ecx_msg_logs where error_id = v_ext_log_error_id_tl(i);

				FORALL i IN 1..v_ext_ret_error_id_tl.count
					delete from ecx_error_msgs where error_id = v_ext_ret_error_id_tl(i);

				FORALL i IN 1..v_ext_ret_error_id_tl.count
					delete from ecx_msg_logs where error_id = v_ext_ret_error_id_tl(i);

				delete from ecx_external_retry WHERE msgid =v_message_id_tl(i);
				delete from ecx_inbound_logs WHERE msgid =v_message_id_tl(i);
				delete from ecx_outbound_logs WHERE out_msgid =v_message_id_tl(i);
				delete from ecx_external_logs WHERE out_msgid =v_message_id_tl(i);
				delete from ecx_oxta_logmsg WHERE receipt_message_id =v_message_id_tl(i)
                                             OR sender_message_id =v_message_id_tl(i);
				delete from ecx_doclogs WHERE msgid = hextoraw(v_message_id_tl(i));

	                         IF (l_commitFlag and (mod(i,commit_frequency_ecx) = 0 or  (i = v_message_id_tl.count))) THEN
--                                      dbms_output.put_line('COMMITING i = '|| to_char(i));
                                        commit;
                                END IF;

			end if;
		END LOOP ;

		IF NOT l_runtimeonly THEN
				PURGE_OUTBOUND(transaction_type, transaction_subtype, party_id, party_site_id, fromDate, toDate, l_commitFlag);
		END IF;
	exception
	WHEN others THEN
	   if(get_in_error_id%ISOPEN) then
		close get_in_error_id;
	   end if;
	   if(get_out_error_id%ISOPEN) then
		close get_out_error_id;
	   end if;
	   if(get_in_trigger_id%ISOPEN) then
		close get_in_trigger_id;
	   end if;
	   if(get_out_trigger_id%ISOPEN) then
		close get_out_trigger_id;
	   end if;
	   if(get_ext_log_error_id%ISOPEN) then
		close get_ext_log_error_id;
	   end if;
	   if(get_ext_ret_error_id%ISOPEN) then
		close get_ext_ret_error_id;
	   end if;
	    Wf_Core.Context('ECX_Purge', 'Purge', item_type, item_key,transaction_type, transaction_subtype,party_id,party_site_id,to_char(fromDate),to_char(toDate));
	   raise;
	end PURGE;

--
-- procedure Items
--   Delete items with end_time before argument.
-- IN:
--   itemtype - Item type to delete, or null for all itemtypes
--   itemkey - Item key to delete, or null for all itemkeys
--   enddate - Date to obsolete to
--   docommit- Do not commit if set to false
--   runtimeonly - Delete data which is associated with workflow, if set to true

procedure PURGE_ITEMS(itemType	in	varchar2,
	itemKey		in	varchar2,
	endDate		in	date,
	docommit	in	boolean,
	runtimeonly	in	boolean) IS

	l_msgId			RAW(16);
	l_errId			number(16);
	delCounter		number(4);
	l_commitFlag		 boolean :=true;
	l_runtimeonly		 boolean := false;

      /** l_int_trans_id ecx_transactions.transaction_id%type;
	l_ext_trans_type ecx_ext_processes.ext_type%type;
        l_ext_trans_subtype ecx_ext_processes.ext_subtype%type;

       cursor get_itrans is
           select transaction_id from ecx_transactions;

        cursor get_ext_trans(p_trans_id in ecx_transactions.transaction_id%type) is
           select ext_type, ext_subtype from   ecx_ext_processes ecxextpc where  ecxextpc.transaction_id = p_trans_id;

	TYPE t_int_trans_id_tl is TABLE of ecx_transactions.transaction_id%type;
        v_int_trans_id_tl t_int_trans_id_tl;**/


	/**TYPE t_msg_id_tl is TABLE of ecx_doclogs.msgid%type;
	v_msg_id_tl t_msg_id_tl;**/

	cursor get_in_trigger_id (p_msgid in ecx_doclogs.msgid%type) is
		select trigger_id from ecx_inbound_logs where msgid is not null and msgid = hextoraw(p_msgid);
	cursor get_out_trigger_id (p_msgid in ecx_doclogs.msgid%type) is
		select trigger_id from ecx_outbound_logs where out_msgid is not null and out_msgid = hextoraw(p_msgid);
	cursor get_ext_log_error_id (p_msgid in ecx_doclogs.msgid%type) is
		select error_id from ecx_external_logs where out_msgid is not null and out_msgid = hextoraw(p_msgid);
	cursor get_ext_ret_error_id (p_msgid in ecx_doclogs.msgid%type) is
		select error_id from ecx_external_retry where msgid = p_msgid;
        cursor get_in_error_id (p_trigger_id in ecx_msg_logs.trigger_id%type) is
		select error_id from ecx_msg_logs where trigger_id = p_trigger_id;
	cursor get_out_error_id (p_trigger_id in ecx_msg_logs.ERROR_ID%type) is
		select error_id from ecx_msg_logs where trigger_id = p_trigger_id;


        TYPE t_message_id_tl is TABLE of ecx_doclogs.msgid%type;
	TYPE t_itemtype_id_tl is TABLE of ecx_doclogs.item_type%type;
	TYPE t_itemkey_id_tl is TABLE of ecx_doclogs.item_key%type;
	TYPE t_out_error_id_tl is TABLE of ecx_outbound_logs.error_id%type;
	TYPE t_ext_log_error_id_tl is TABLE of ecx_external_logs.error_id%type;
	TYPE t_ext_ret_error_id_tl is TABLE of ecx_external_retry.error_id%type;
	TYPE t_in_trigger_id_tl is TABLE of ecx_msg_logs.trigger_id%type;
	TYPE t_out_trigger_id_tl is TABLE of ecx_msg_logs.trigger_id%type;
	TYPE t_in_error_id_tl is TABLE of ecx_msg_logs.error_id%type;

        v_msgid ecx_doclogs.msgid%type;
	v_message_id_tl t_message_id_tl;
	v_itemtype_tl t_itemtype_id_tl;
	v_itemkey_tl t_itemkey_id_tl;
	v_out_trigger_id_tl t_out_trigger_id_tl;
	v_out_error_id_tl t_out_error_id_tl;
	v_ext_log_error_id_tl t_ext_log_error_id_tl;
	v_ext_ret_error_id_tl t_ext_ret_error_id_tl;
        v_in_trigger_id_tl t_in_trigger_id_tl;
	v_in_error_id_tl t_in_error_id_tl;
	bulk_delete_first pls_integer;
	bulk_delete_last pls_integer;

	status varchar2(200);
	result varchar2(200);
	purgable boolean := true;
	is_bulk_delete_cycle boolean := false;
	begin
               /** open get_itrans;
                fetch get_itrans bulk collect into v_int_trans_id_tl;
                close get_itrans;

         for i in 1..v_int_trans_id_tl.count loop
              l_int_trans_id := v_int_trans_id_tl(i);
--            dbms_output.put_line('l_int_trans_id = '||to_char(l_int_trans_id));
                for ext_trans in get_ext_trans(l_int_trans_id) loop
                      l_ext_trans_type := ext_trans.ext_type;
                      l_ext_trans_subtype := ext_trans.ext_subtype;
--                    dbms_output.put_line('   ext trans type = '||l_ext_trans_type || ', ext trans subtype = '||l_ext_trans_subtype);
                        PURGE(item_type => itemType, item_key => itemKey,
                                        toDate => endDate, commitFlag => docommit, runtimeonly => runtimeonly,
                                        transaction_type => l_ext_trans_type, transaction_subtype => l_ext_trans_subtype);
                end loop;
        end loop; **/

        /* fix for bug 5852521 */
        if nvl(fnd_profile.value('ECX_PURGE_WF'),'Y') = 'N' then
           return;
        end if;

        FOR i in 1..WF_PURGE.l_itemtypeTAB.count loop

select msgid into v_msgid from ecx_doclogs where
 (item_type = WF_PURGE.l_itemtypeTAB(i)) and (item_key =WF_PURGE.l_itemkeyTAB(i) ) ;
                  purgable := true;
			status := '';
			if(purgable) then
			open get_in_trigger_id(v_msgid);
			fetch get_in_trigger_id bulk collect into v_in_trigger_id_tl ;
				FOR i IN 1..v_in_trigger_id_tl.count
                                  LOOP
                                  open get_in_error_id (v_in_trigger_id_tl(i));
                                  fetch get_in_error_id bulk collect into v_in_error_id_tl ;
                                  FORALL i IN 1..v_in_error_id_tl.count
                                  delete from ecx_error_msgs where error_id =v_in_error_id_tl(i);
                                  FORALL i IN 1..v_in_error_id_tl.count
                                  delete from ecx_msg_logs where error_id =v_in_error_id_tl(i);
				  close get_in_error_id;
                                 END LOOP;
			close get_in_trigger_id;

				open get_out_trigger_id(v_msgid);
				fetch get_out_trigger_id bulk collect into v_out_trigger_id_tl ;
				FOR i IN 1..v_out_trigger_id_tl.count
                                  LOOP
                                  open get_out_error_id (v_out_trigger_id_tl(i));
                                  fetch get_out_error_id bulk collect into v_out_error_id_tl ;
                                  FORALL i IN 1..v_out_error_id_tl.count
                                  delete from ecx_error_msgs where error_id =v_out_error_id_tl(i);
                                  FORALL i IN 1..v_out_error_id_tl.count
                                  delete from ecx_msg_logs where error_id =v_out_error_id_tl(i);
				  close get_out_error_id;
                                 END LOOP;
		       close get_out_trigger_id;


				open get_ext_log_error_id(v_msgid);
				fetch get_ext_log_error_id bulk collect into v_ext_log_error_id_tl ;
				close get_ext_log_error_id;

				open get_ext_ret_error_id(v_msgid);
				fetch get_ext_ret_error_id bulk collect into v_ext_ret_error_id_tl;
				close get_ext_ret_error_id;


				FORALL i IN 1..v_ext_log_error_id_tl.count
					delete from ecx_error_msgs where error_id = v_ext_log_error_id_tl(i);

				FORALL i IN 1..v_ext_log_error_id_tl.count
					delete from ecx_msg_logs where error_id = v_ext_log_error_id_tl(i);

				FORALL i IN 1..v_ext_ret_error_id_tl.count
					delete from ecx_error_msgs where error_id = v_ext_ret_error_id_tl(i);

				FORALL i IN 1..v_ext_ret_error_id_tl.count
					delete from ecx_msg_logs where error_id = v_ext_ret_error_id_tl(i);

				delete from ecx_external_retry WHERE msgid =v_msgid;
				delete from ecx_inbound_logs WHERE msgid =v_msgid;
				delete from ecx_outbound_logs WHERE out_msgid =v_msgid;
				delete from ecx_external_logs WHERE out_msgid =v_msgid;
				delete from ecx_oxta_logmsg WHERE receipt_message_id =v_msgid
                                             OR sender_message_id =v_msgid;
				delete from ecx_doclogs WHERE msgid = hextoraw(v_msgid);

/**	                         IF (l_commitFlag and (mod(i,commit_frequency_ecx) = 0 or  (i = v_msg_id_tl.count))) THEN
--                                      dbms_output.put_line('COMMITING i = '|| to_char(i));
                                        commit;
                                END IF;**/

			end if;

	END LOOP;
        commit;
	EXCEPTION
        WHEN others THEN
       /**    if(get_itrans%ISOPEN) then
                close get_itrans;
           end if;
           if(get_ext_trans%ISOPEN) then
                close get_ext_trans;
           end if;**/
	     if(get_in_error_id%ISOPEN) then
		close get_in_error_id;
	   end if;
	   if(get_out_error_id%ISOPEN) then
		close get_out_error_id;
	   end if;
	   if(get_in_trigger_id%ISOPEN) then
		close get_in_trigger_id;
	   end if;
	   if(get_out_trigger_id%ISOPEN) then
		close get_out_trigger_id;
	   end if;
	   if(get_ext_log_error_id%ISOPEN) then
		close get_ext_log_error_id;
	   end if;
	   if(get_ext_ret_error_id%ISOPEN) then
		close get_ext_ret_error_id;
	   end if;

          Wf_Core.Context('ECX_Purge', 'Purge_Items', itemType, itemKey, to_char(endDate));
--           raise;
END PURGE_ITEMS;
-- procedure Purge_Transactions
--This procedure has been incorporated to make the CP for purging obsolete ECX data.
--Delete log details wihin the stipulated date range.
-- IN:
-- transaction_type - Transaction type to delete, or null for all transaction types
-- transaction_subtype - Transaction subtype to delete, or null for all subtypes
-- fromdate - Date from which the data to delete.
-- todate  - Date upto which data has to delete.
-- docommit- Do not commit if set to false.
procedure PURGE_TRANSACTIONS(
        transaction_type in      varchar2 default null,
        transaction_subtype in varchar2 default null,
        fromdate in date default null,
        todate in date default null,
        docommit        in      boolean default true
) IS

        l_int_trans_id ecx_transactions.transaction_id%type;
        l_ext_trans_type ecx_ext_processes.ext_type%type;
        l_ext_trans_subtype ecx_ext_processes.ext_subtype%type;

        cursor get_itrans_ts(p_int_trans_type ecx_transactions.transaction_type%type,
          p_int_trans_subtype in ecx_transactions.transaction_subtype%type) is
         select transaction_id
          from ecx_transactions
        WHERE transaction_type = p_int_trans_type AND
              transaction_subtype = p_int_trans_subtype;
	 cursor get_itrans_t(p_int_trans_type ecx_transactions.transaction_type%type) is
         select transaction_id
          from ecx_transactions
        WHERE transaction_type = p_int_trans_type;
        cursor get_itrans_s(p_int_trans_subtype in ecx_transactions.transaction_subtype%type) is
          select transaction_id
	from ecx_transactions
        WHERE transaction_subtype = p_int_trans_subtype;
        Cursor get_itrans is
          select transaction_id from ecx_transactions;
        cursor get_ext_trans(p_trans_id in ecx_transactions.transaction_id%type) is
           select ext_type, ext_subtype from   ecx_ext_processes ecxextpc where  ecxextpc.transaction_id = p_trans_id;

        TYPE t_int_trans_id_tl is TABLE of ecx_transactions.transaction_id%type;
        v_int_trans_id_tl t_int_trans_id_tl;

        BEGIN
         if (transaction_type is not null and transaction_subtype is not null) then
                 open get_itrans_ts(transaction_type, transaction_subtype);
                 fetch get_itrans_ts bulk collect into v_int_trans_id_tl;
                 close get_itrans_ts;
         elsif (transaction_type is null and transaction_subtype is not null) then
                 open get_itrans_s(transaction_subtype);
                 fetch get_itrans_s bulk collect into v_int_trans_id_tl;
                 close get_itrans_s;
         elsif (transaction_type is not null and transaction_subtype is null) then
                 open get_itrans_t(transaction_type);
                 fetch get_itrans_t bulk collect into v_int_trans_id_tl;
                 close get_itrans_t;
         elsif (transaction_type is null and transaction_subtype is null) then
		open get_itrans;
                fetch get_itrans bulk collect into v_int_trans_id_tl;
                close get_itrans;
	end if;
        for i in 1..v_int_trans_id_tl.count loop
              l_int_trans_id := v_int_trans_id_tl(i);
--            dbms_output.put_line('l_int_trans_id = '||to_char(l_int_trans_id));
                for ext_trans in get_ext_trans(l_int_trans_id) loop
                      l_ext_trans_type := ext_trans.ext_type;
                      l_ext_trans_subtype := ext_trans.ext_subtype;
--                    dbms_output.put_line('   ext trans type = '||l_ext_trans_type || ', ext trans subtype = '||l_ext_trans_subtype);
                        PURGE(transaction_type => l_ext_trans_type, transaction_subtype => l_ext_trans_subtype,
				fromdate =>fromdate,todate => todate);
                end loop;
        end loop;
 EXCEPTION
        WHEN others THEN
           if(get_itrans%ISOPEN) then
                close get_itrans;
           end if;
	   if(get_itrans_ts%ISOPEN) then
                close get_itrans_ts;
           end if;
           if(get_itrans_t%ISOPEN) then
                close get_itrans_t;
           end if;
           if(get_itrans_s%ISOPEN) then
                close get_itrans_s;
           end if;
           if(get_ext_trans%ISOPEN) then
                close get_ext_trans;
           end if;
           Wf_Core.Context('ECX_Purge', 'Purge_Transactions', transaction_Type, transaction_subtype, to_char(toDate));
         raise;
END PURGE_TRANSACTIONS;
--

--Procedure  TotalConcurrent
--   This wil be called from CP to purge obsolete ECX data.
-- IN:
--   errbuf - CPM error message
--   retcode - CPM return code (0 = success, 1 = warning, 2 = error)
--   transactiontype - Transaction type to delete, or null for all transactiontype
--   transactionsubtype - Transaction subtype to delete, or null for all transaction subtype.
--  fromdate - Date from which the data to delete.
-- todate  - Date upto which data has to delete.
-- x_commit_frequency - The freq. at which commit will take place during deletion.
 procedure TotalConcurrent(
  errbuf out NOCOPY varchar2 ,
  retcode out NOCOPY varchar2,
  transaction_type in varchar2 default null,
 transaction_subtype in varchar2 default null,
 fromdate in date default null,
todate in date default null,
x_commit_frequency in  number )
is
  errname varchar2(30);
  errmsg varchar2(2000);
  errstack varchar2(2000);
  --l_transactiontype ecx_outbound_logs.transaction_type%type:=transactiontype;
 -- l_transactionsubtype ecx_outbound_logs.transaction_subtype%type:=transactionsubtype;
  l_fromdate date:=fromdate;
  l_todate date:=todate;
  docommit boolean := TRUE;
    l_sql varchar2(500);
   l_msg_inst varchar2(200);
begin

  ecx_purge.commit_frequency_ecx := x_commit_frequency;
 ecx_purge.purge_transactions(transaction_type=>transaction_type,
                      transaction_subtype=>transaction_subtype,
		      fromdate=>l_fromdate,
		      todate=>l_todate);

  -- Return 0 for successful completion.
  errbuf := '';
  retcode := '0';
--  wf_purge.persistence_type := 'TEMP';  -- reset to the default value
  --wf_purge.commit_frequency := 500; -- reset to the default value

exception
  when others then
    -- Retrieve error message into errbuf
    wf_core.get_error(errname, errmsg, errstack);
    if (errmsg is not null) then
      errbuf := errmsg;
    else
      errbuf := sqlerrm;
    end if;

    -- Return 2 for error.
    retcode := '2';

    -- Reset persistence type to the default value
  --  wf_purge.persistence_type := 'TEMP';
end TotalConcurrent;

--show errors package body ECX_PURGE
--select to_date('SQLERROR') from user_errors
--where type = 'PACKAGE BODY'
--and name = 'ECX_PURGE'
END ecx_purge;

/
