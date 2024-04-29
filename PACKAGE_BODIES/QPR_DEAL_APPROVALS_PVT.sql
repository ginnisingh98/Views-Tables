--------------------------------------------------------
--  DDL for Package Body QPR_DEAL_APPROVALS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QPR_DEAL_APPROVALS_PVT" AS
/* $Header: QPRPNAPB.pls 120.22 2008/05/28 12:02:28 amjha ship $ */

   type approval_record_type is record
      ( approver_id number,
	approver_name varchar2(320),
	approval_sequence number,
	approval_status varchar2(50),
	rule_id number,
	rule_description varchar2(100),
	notification_date date,
	response_date date,
	comments varchar2(2000),
	archive_flag varchar2(1),
	item_class varchar2(100),
	item_id varchar2(100));

   type approval_table_type is table of approval_record_type index by binary_integer;

   type id_list is table of number index by binary_integer;

   g_appl_id number := null;

   g_transaction_type_id varchar2(50) := 'oracle.apps.qpr';
   --g_transaction_type_id varchar2(50) := 'Deal-Approval';


   procedure clear_existing_approvals(p_response_header_id in number,
				      p_user_id in number);

   procedure synch_with_db(p_response_header_id in number,
			   x_approvals_tab in out nocopy approval_table_type);

   procedure get_ame_approvals(p_response_header_id in number,
			       x_approvals_tab out nocopy approval_table_type,
			       x_approvals_complete out nocopy varchar2);

   procedure mark_ame_notified(p_response_header_id in number,
			       x_notified_approvals_tab out nocopy approval_table_type);

   procedure update_ame_status(p_response_header_id in number,
			       p_user_id in number,
			       p_status in varchar2,
			       x_prior_approvals_tab out nocopy approval_table_type,
			       x_approvals_complete out nocopy varchar2);

   procedure insert_approval_records(p_response_header_id in number,
				     p_approvals_tab in approval_table_type);

   procedure insert_archive_record(p_response_header_id in number,
				   p_user_id in number,
				   p_action in varchar2,
				   p_comments in varchar2);

   procedure update_with_ame(p_response_header_id in number,
			     p_user_id in number,
			     p_action in varchar2);

   function get_approval_record(p_ame_record ame_util.approverRecord2)
      return approval_record_type;

   function is_approvals_changed(p_response_header_id in number,
				p_ame_approvals_tab in approval_table_type)
      return boolean;

   function get_approvals_records(p_response_header_id in number,
				  p_user_id in number)
      return approval_table_type;

   function get_approvals_records(p_response_header_id in number)
      return approval_table_type;

   function is_action_permitted(p_response_header_id in number,
				p_user_id in number,
				p_action_code in varchar2)
      return boolean;

   function get_application_id
   return number
   is
   begin
      if g_appl_id is null
      then
	 select application_id into g_appl_id
	 from fnd_application
	 where application_short_name = 'QPR';
      end if;
      return g_appl_id;
   end get_application_id;


   procedure clear_existing_approvals(p_response_header_id in number,
				      p_user_id in number)
   is
   begin
      delete from qpr_pn_response_approvals
	 where response_header_id = p_response_header_id
	 and archive_flag = 'N'
	 and approver_id <> p_user_id;
   end clear_existing_approvals;

   function get_approval_record(p_ame_record ame_util.approverRecord2)
   return approval_record_type
   is
      l_approver_rec approval_record_type;
      l_fnd_user_id number;

       cursor fnd_user(c_emp_id number) is
	  select user_id
	  from fnd_user
	  where employee_id = c_emp_id;
   begin

      --alosh: finding the fnd_user_id
      if(p_ame_record.orig_system = 'FND_USR')
      then
         l_fnd_user_id := p_ame_record.orig_system_id;
      elsif(p_ame_record.orig_system = 'PER')
      then
         open fnd_user(p_ame_record.orig_system_id);
	 fetch fnd_user into l_fnd_user_id;
	 close fnd_user;
      end if;

      l_approver_rec.approver_id := l_fnd_user_id;
      l_approver_rec.approver_name := p_ame_record.name;
      l_approver_rec.approval_sequence := p_ame_record.approver_order_number;
      l_approver_rec.approval_status := p_ame_record.approval_status;
      l_approver_rec.archive_flag := 'N';
      l_approver_rec.item_class := nvl(p_ame_record.item_class, 'NULL');
      l_approver_rec.item_id := nvl(p_ame_record.item_id, 'NULL');

      return l_approver_rec;
   end get_approval_record;

   procedure synch_with_db(p_response_header_id in number,
			   x_approvals_tab in out nocopy approval_table_type)
   is

      cursor get_db_records(c_response_header_id number)
      is
	 select approver_id,
	 approval_status,
	 rule_id,
	 notification_date,
	 response_date,
	 comments
	 from qpr_pn_response_approvals
	 where response_header_id = c_response_header_id;
   begin

      if x_approvals_tab.count = 0
      then
	 return;
      end if;

      for approval_rec in get_db_records(p_response_header_id)
      loop
	 for i in x_approvals_tab.first .. x_approvals_tab.last
	 loop
	    if(approval_rec.approver_id = x_approvals_tab(i).approver_id and approval_rec.rule_id = x_approvals_tab(i).rule_id)
	    then
	        x_approvals_tab(i).notification_date := approval_rec.notification_date;
		x_approvals_tab(i).response_date := approval_rec.response_date;
		x_approvals_tab(i).comments := approval_rec.comments;
		exit;
	     end if;
	  end loop;
       end loop;

    end synch_with_db;

    procedure rebuild_ame_status(p_response_header_id in number)
    is
       l_count number;
       l_notify_flag varchar2(1);
       l_approvals_complete varchar2(1);
       l_ame_next_approver_tab ame_util.approversTable2;
       l_approver_record ame_util.approverRecord2;

       cursor get_active_records(c_resp_id number)
       is
	  select approver_name, approval_status
	  from qpr_pn_response_approvals
	  where response_header_id = c_resp_id
	  and archive_flag = 'N';

    begin

       select count(*) into l_count
	  from qpr_pn_response_approvals
	  where response_header_id = p_response_header_id
	  and archive_flag = 'N'
	  and approval_status in ('NOTIFIED', 'APPROVE');

       if l_count > 0
       then
	  l_notify_flag := ame_util.booleanTrue;
	  ame_api2.getNextApprovers4(
				     applicationIdIn => get_application_id(),
				     transactionTypeIn => g_transaction_type_id,
				     transactionIdIn => p_response_header_id,
				     flagApproversAsNotifiedIn => l_notify_flag,
				     approvalProcessCompleteYNOut => l_approvals_complete,
				     nextApproversOut => l_ame_next_approver_tab
				     );

	  for rec in get_active_records(p_response_header_id)
	  loop

	     l_approver_record.name := rec.approver_name;
	     l_approver_record.approval_status := rec.approval_status;
	     ame_api2.updateApprovalStatus(
					   applicationIdIn => get_application_id(),
					   transactionTypeIn => g_transaction_type_id,
					   transactionIdIn => p_response_header_id,
					   approverIn => l_approver_record);

	  end loop;
       end if;
    end rebuild_ame_status;


   function is_action_permitted(p_response_header_id in number,
				p_user_id in number,
				p_action_code in varchar2)
      return boolean

   is
      l_status varchar2(50);

   begin

      if p_action_code = 'APPROVE' or p_action_code= 'REJECT'
      then
	 l_status := null;
	 select approval_status into l_status
	    from qpr_pn_response_approvals
	    where response_header_id = p_response_header_id
	    and approver_id = p_user_id
	    and archive_flag = 'N'
	    and approval_status = 'NOTIFIED';

	 if l_status = 'NOTIFIED'
	 then
	    return true;
	 else
	    return false;
	 end if;
      end if;

      return true;
   exception
      when others
      then
	 return false;
   end is_action_permitted;



   procedure get_ame_approvals(p_response_header_id in number,
			       x_approvals_tab out nocopy approval_table_type,
			       x_approvals_complete out nocopy varchar2)
   is
       l_transaction_id varchar2(50);
       l_notify_flag varchar2(1);
       l_ame_approver_table ame_util.approversTable2;
       l_ame_next_approver_tab ame_util.approversTable2;
       l_ame_item_indexes ame_util.idlist;
       l_ame_item_classes ame_util.stringlist;
       l_ame_item_ids ame_util.stringlist;
       l_ame_item_sources ame_util.longstringlist;
       l_ame_rule_indexes ame_util.idlist;
       l_ame_source_types ame_util.stringlist;
       l_ame_rule_ids ame_util.idlist;
       l_ame_rule_descs ame_util.stringlist;
       l_approval_rec approval_record_type;

    begin

       l_transaction_id := p_response_header_id;
       l_notify_flag := ame_util.booleanFalse;



       ame_api2.getAllApprovers6(
				 applicationIdIn => get_application_id(),
				 transactionTypeIn => g_transaction_type_id,
				 transactionIdIn => l_transaction_id,
				 approvalProcessCompleteYNOut => x_approvals_complete,
				 approversOut => l_ame_approver_table,
				 itemIndexesOut => l_ame_item_indexes,
				 itemClassesOut => l_ame_item_classes,
				 itemIdsOut => l_ame_item_ids,
				 itemSourcesOut => l_ame_item_sources,
				 ruleIndexesOut => l_ame_rule_indexes,
				 sourceTypesOut => l_ame_source_types,
				 ruleIdsOut => l_ame_rule_ids,
				 ruleDescriptionsOut => l_ame_rule_descs
				 );

       if(l_ame_approver_table.count > 0)
       then

	   for i in l_ame_approver_table.first .. l_ame_approver_table.last
	   loop

	      l_approval_rec := get_approval_record(l_ame_approver_table(i));
	      l_approval_rec.rule_id := l_ame_rule_ids(i);
	      l_approval_rec.rule_description := l_ame_rule_descs(i);
	      x_approvals_tab(i) := l_approval_rec;

	   end loop;
	end if;

       ame_api2.getNextApprovers4(
				 applicationIdIn => get_application_id(),
				 transactionTypeIn => g_transaction_type_id,
				 transactionIdIn => l_transaction_id,
				 flagApproversAsNotifiedIn => l_notify_flag,
				 approvalProcessCompleteYNOut => x_approvals_complete,
				 nextApproversOut => l_ame_next_approver_tab
				  );

       if(l_ame_next_approver_tab.count > 0)
       then

          for i in l_ame_next_approver_tab.first .. l_ame_next_approver_tab.last
	  loop

	     for j in x_approvals_tab.first .. x_approvals_tab.last
	     loop

		if l_ame_next_approver_tab(i).name = x_approvals_tab(j).approver_name
		then
		   if x_approvals_tab(j).approval_status is null
		   then
		      x_approvals_tab(j).approval_status := 'PENDING_APPROVAL';
		   end if;
		   exit;
		end if;

	     end loop;

	  end loop;

       end if;

       --alosh: update ame records with current status and date
       synch_with_db(p_response_header_id => p_response_header_id,
		     x_approvals_tab => x_approvals_tab);


     end get_ame_approvals;


     procedure mark_ame_notified(p_response_header_id in number,
				 x_notified_approvals_tab out nocopy approval_table_type)
     is
       l_transaction_id varchar2(50);
       l_notify_flag varchar2(1);
       l_approvals_complete varchar2(1);
       l_ame_approver_table ame_util.approversTable2;
       l_count number;

    begin

       l_transaction_id := p_response_header_id;
       l_notify_flag := ame_util.booleanFalse;

       ame_api2.getNextApprovers4(
				 applicationIdIn => get_application_id(),
				 transactionTypeIn => g_transaction_type_id,
				 transactionIdIn => l_transaction_id,
				 flagApproversAsNotifiedIn => l_notify_flag,
				 approvalProcessCompleteYNOut => l_approvals_complete,
				 nextApproversOut => l_ame_approver_table
				  );

       l_count := 0;

       if(l_ame_approver_table.count > 0)
       then

	   for i in l_ame_approver_table.first .. l_ame_approver_table.last
	   loop

	      if l_ame_approver_table(i).approval_status is null
	      then
		 x_notified_approvals_tab(l_count) := get_approval_record(l_ame_approver_table(i));
		 l_count := l_count + 1;
	      end if;

	   end loop;
	end if;

	l_notify_flag := ame_util.booleanTrue;
	ame_api2.getNextApprovers4(
				   applicationIdIn => get_application_id(),
				   transactionTypeIn => g_transaction_type_id,
				   transactionIdIn => l_transaction_id,
				   flagApproversAsNotifiedIn => l_notify_flag,
				   approvalProcessCompleteYNOut => l_approvals_complete,
				   nextApproversOut => l_ame_approver_table
				   );

     end mark_ame_notified;

     procedure update_ame_status(p_response_header_id in number,
				 p_user_id in number,
				 p_status in varchar2,
				 x_prior_approvals_tab out nocopy approval_table_type,
				 x_approvals_complete out nocopy varchar2)
     is
       l_ame_approver_table ame_util.approversTable2;
       l_ame_item_indexes ame_util.idlist;
       l_ame_item_classes ame_util.stringlist;
       l_ame_item_ids ame_util.stringlist;
       l_ame_item_sources ame_util.longstringlist;
       l_ame_rule_indexes ame_util.idlist;
       l_ame_source_types ame_util.stringlist;
       l_ame_rule_ids ame_util.idlist;
       l_ame_rule_descs ame_util.stringlist;
       l_approval_rec approval_record_type;
       l_approvals_tab approval_table_type;
       l_user_name varchar2(320);
       l_approver_record ame_util.approverRecord2;

       l_index number;
       l_rule_ids id_list;
       l_rule_count number;
       l_prior_approvals_index number;

     begin

	select distinct approver_name
	   into l_user_name
	   from qpr_pn_response_approvals
	   where response_header_id = p_response_header_id
	   and approver_id = p_user_id;

	l_approver_record.name := l_user_name;

	if p_status is not null
	then
	   l_approver_record.approval_status := 'NOTIFIED';
   	   ame_api2.updateApprovalStatus(
					 applicationIdIn => get_application_id(),
					 transactionTypeIn => g_transaction_type_id,
					 transactionIdIn => p_response_header_id,
					 approverIn => l_approver_record);
	end if;
	l_approver_record.approval_status := p_status;

	ame_api2.updateApprovalStatus(
				      applicationIdIn => get_application_id(),
				      transactionTypeIn => g_transaction_type_id,
				      transactionIdIn => p_response_header_id,
				      approverIn => l_approver_record);


	ame_api2.getAllApprovers6(
				  applicationIdIn => get_application_id(),
				  transactionTypeIn => g_transaction_type_id,
				  transactionIdIn => p_response_header_id,
				  approvalProcessCompleteYNOut => x_approvals_complete,
				  approversOut => l_ame_approver_table,
				  itemIndexesOut => l_ame_item_indexes,
				  itemClassesOut => l_ame_item_classes,
				  itemIdsOut => l_ame_item_ids,
				  itemSourcesOut => l_ame_item_sources,
				  ruleIndexesOut => l_ame_rule_indexes,
				 sourceTypesOut => l_ame_source_types,
				  ruleIdsOut => l_ame_rule_ids,
				  ruleDescriptionsOut => l_ame_rule_descs
				  );

       if(l_ame_approver_table.count > 0)
       then

          for i in l_ame_approver_table.first .. l_ame_approver_table.last
	  loop

	     l_approval_rec := get_approval_record(l_ame_approver_table(i));
	     l_approval_rec.rule_id := l_ame_rule_ids(i);
	     l_approval_rec.rule_description := l_ame_rule_descs(i);
	     l_approvals_tab(i) := l_approval_rec;

	  end loop;
       end if;


       l_index := l_approvals_tab.last;
       l_rule_count := 0;
       l_prior_approvals_index := 0;
       loop
	  if(not l_approvals_tab.exists(l_index))
	  then
	     exit;
	  end if;

	  if l_approvals_tab(l_index).approver_name = l_user_name
	  then
	     l_rule_ids(l_rule_count) := l_approvals_tab(l_index).rule_id;
	     l_rule_count := l_rule_count + 1;
	  elsif l_approvals_tab(l_index).approval_status = 'APPROVE'
	  then
	     if l_rule_ids is not null and l_rule_ids.count > 0
	     then
		for i in l_rule_ids.first .. l_rule_ids.last
		loop
		   if l_approvals_tab(l_index).rule_id = l_rule_ids(i)
		   then
		      x_prior_approvals_tab(l_prior_approvals_index) := l_approvals_tab(l_index);
		      l_prior_approvals_index := l_prior_approvals_index +1;
		      exit;
		   end if;
		end loop;
	     end if;
	  end if;
	  l_index := l_index - 1;
       end loop;

     end update_ame_status;



   procedure clear_ame_status(p_response_header_id in number,
			      p_user_id in number,
			      x_cleared_approvals_tab out nocopy approval_table_type)
   is
       l_ame_approver_table ame_util.approversTable2;
       l_ame_rec ame_util.approverRecord2;
       l_ame_item_indexes ame_util.idlist;
       l_ame_item_classes ame_util.stringlist;
       l_ame_item_ids ame_util.stringlist;
       l_ame_item_sources ame_util.longstringlist;
       l_ame_rule_indexes ame_util.idlist;
       l_ame_source_types ame_util.stringlist;
       l_ame_rule_ids ame_util.idlist;
       l_ame_rule_descs ame_util.stringlist;
       l_rule_id number;
       l_item_class varchar2(100);
       l_item_id varchar2(100);
       l_approvals_complete varchar2(1);
       l_user_name varchar2(320);
       l_count number;

    begin

       ame_api2.getAllApprovers6(
				 applicationIdIn => get_application_id(),
				 transactionTypeIn => g_transaction_type_id,
				 transactionIdIn => p_response_header_id,
				 approvalProcessCompleteYNOut => l_approvals_complete,
				 approversOut => l_ame_approver_table,
				 itemIndexesOut => l_ame_item_indexes,
				 itemClassesOut => l_ame_item_classes,
				 itemIdsOut => l_ame_item_ids,
				 itemSourcesOut => l_ame_item_sources,
				 ruleIndexesOut => l_ame_rule_indexes,
				 sourceTypesOut => l_ame_source_types,
				 ruleIdsOut => l_ame_rule_ids,
				 ruleDescriptionsOut => l_ame_rule_descs
				 );

       if(l_ame_approver_table.count > 0)
       then

	   l_count := 0;

	   for i in l_ame_approver_table.first .. l_ame_approver_table.last
	   loop

	      l_ame_rec := l_ame_approver_table(i);
	      l_ame_rec.approval_status := null;
	      x_cleared_approvals_tab(l_count) := get_approval_record(l_ame_rec);
	      l_count := l_count +1;

	      ame_api2.updateApprovalStatus(
					    applicationIdIn => get_application_id(),
					    transactionTypeIn => g_transaction_type_id,
					    transactionIdIn => p_response_header_id,
					    approverIn => l_ame_rec);
	   end loop;

	end if;
	ame_api2.clearAllApprovals(
				   applicationIdIn => get_application_id(),
				   transactionTypeIn => g_transaction_type_id,
				   transactionIdIn => p_response_header_id);


     end clear_ame_status;

     function is_approvals_changed(p_response_header_id in number,
				   p_ame_approvals_tab in approval_table_type)
	return boolean
     is
	l_approvals_changed boolean;
	l_db_records approval_table_type;
	l_count number;

     begin

	l_approvals_changed := false;
	l_db_records := get_approvals_records(p_response_header_id => p_response_header_id);

	if p_ame_approvals_tab.count <> l_db_records.count
	then
	   l_approvals_changed := true;
	   return l_approvals_changed;
	end if;


	if p_ame_approvals_tab.count > 0
	then

	   l_count := l_db_records.first;

	   for i in p_ame_approvals_tab.first .. p_ame_approvals_tab.last
	   loop

	      if p_ame_approvals_tab(i).approver_id <> l_db_records(l_count).approver_id or
		 p_ame_approvals_tab(i).approval_sequence <> l_db_records(l_count).approval_sequence or
		 p_ame_approvals_tab(i).approval_status <> l_db_records(l_count).approval_status or
		 p_ame_approvals_tab(i).rule_id <> l_db_records(l_count).rule_id or
		 p_ame_approvals_tab(i).item_class <> l_db_records(l_count).item_class or
		 p_ame_approvals_tab(i).item_id <> l_db_records(l_count).item_id
	      then

		 l_approvals_changed := true;
		return l_approvals_changed;
	     end if;

	     l_count := l_count +1;
	  end loop;

       end if;

       return l_approvals_changed;

    exception
       when others
       then
	  l_approvals_changed := true;
	  return l_approvals_changed;

    end is_approvals_changed;





     procedure insert_approval_records(p_response_header_id in number,
				       p_approvals_tab in approval_table_type)
     is
	l_current_date date;
	l_user_id number;
	l_login_id number;
	l_approver_record approval_record_type;
	l_approval_transaction_id number;

     begin

	l_current_date := sysdate;
	l_user_id := fnd_global.user_id;
	l_login_id := fnd_global.conc_login_id;

	if(p_approvals_tab.count >0)
	then
	   for i in p_approvals_tab.first .. p_approvals_tab.last
	   loop

	      l_approver_record := p_approvals_tab(i);
	      select qpr_pn_response_approvals_s.nextval into l_approval_transaction_id from dual;
	      insert into qpr_pn_response_approvals (
                                                     "APPROVAL_TRANSACTION_ID",
					             "RESPONSE_HEADER_ID",
					             "APPROVAL_SEQUENCE",
					             "APPROVER_ID",
						     "APPROVER_NAME",
					             "APPROVAL_STATUS",
						     "RULE_ID",
						     "RULE_DESCRIPTION",
						     "NOTIFICATION_DATE",
						     "RESPONSE_DATE",
						     "COMMENTS",
					             "ARCHIVE_FLAG",
						     "ITEM_CLASS",
						     "ITEM_ID",
					             "CREATION_DATE",
					             "CREATED_BY",
					             "LAST_UPDATE_DATE",
					             "LAST_UPDATED_BY",
					             "LAST_UPDATE_LOGIN")
		 values (
			 l_approval_transaction_id,
			 p_response_header_id,
			 l_approver_record.approval_sequence,
			 l_approver_record.approver_id,
			 l_approver_record.approver_name,
			 l_approver_record.approval_status,
			 l_approver_record.rule_id,
			 l_approver_record.rule_description,
			 l_approver_record.notification_date,
			 l_approver_record.response_date,
			 l_approver_record.comments,
			 l_approver_record.archive_flag,
			 l_approver_record.item_class,
			 l_approver_record.item_id,
			 l_current_date,
			 l_user_id,
			 l_current_date,
			 l_user_id,
			 l_login_id);
	   end loop;
	end if;

     end insert_approval_records;

     function get_approvals_records(p_response_header_id in number,
				    p_user_id in number)
	return approval_table_type
     is

	l_approval_tab approval_table_type;
	l_count number;

	cursor get_approvals_cursor(c_response_header_id number,
			     c_user_id number)
	is
	   select APPROVAL_SEQUENCE,
	   APPROVER_ID,
	   APPROVER_NAME,
	   APPROVAL_STATUS,
	   RULE_ID,
	   RULE_DESCRIPTION,
	   NOTIFICATION_DATE,
	   RESPONSE_DATE,
	   COMMENTS,
	   ARCHIVE_FLAG,
	   ITEM_CLASS,
	   ITEM_ID
	   from qpr_pn_response_approvals
	   where response_header_id = c_Response_header_id
	   and approver_id = c_user_id
	   and archive_flag = 'N';

     begin

	l_count := 0;
	for approval_rec in get_approvals_cursor(c_response_header_id => p_response_header_id,
					  c_user_id => p_user_id)
	loop
	   l_approval_tab(l_count).approval_sequence := approval_rec.approval_sequence;
	   l_approval_tab(l_count).approver_id := approval_rec.approver_id;
	   l_approval_tab(l_count).approver_name := approval_rec.approver_name;
	   l_approval_tab(l_count).approval_status := approval_rec.approval_status;
	   l_approval_tab(l_count).rule_id := approval_rec.rule_id;
	   l_approval_tab(l_count).rule_description := approval_rec.rule_description;
	   l_approval_tab(l_count).notification_date := approval_rec.notification_date;
	   l_approval_tab(l_count).response_date := approval_rec.response_date;
	   l_approval_tab(l_count).comments := approval_rec.comments;
	   l_approval_tab(l_count).archive_flag := approval_rec.archive_flag;
	   l_approval_tab(l_count).item_class := approval_rec.item_class;
	   l_approval_tab(l_count).item_id := approval_rec.item_id;

	   l_count := l_count+1;
	end loop;

	return l_approval_tab;
     exception
	when others
	then
	   return l_approval_tab;

     end get_approvals_records;


     function get_approvals_records(p_response_header_id in number)
	return approval_table_type
     is

	l_approval_tab approval_table_type;
	l_count number;

	cursor get_approvals_cursor(c_response_header_id number)
	is
	   select APPROVAL_SEQUENCE,
	   APPROVER_ID,
	   APPROVER_NAME,
	   APPROVAL_STATUS,
	   RULE_ID,
	   RULE_DESCRIPTION,
	   NOTIFICATION_DATE,
	   RESPONSE_DATE,
	   COMMENTS,
	   ARCHIVE_FLAG,
	   ITEM_CLASS,
	   ITEM_ID
	   from qpr_pn_response_approvals
	   where response_header_id = c_Response_header_id
	   and archive_flag = 'N'
	   order by approval_transaction_id;

     begin

	l_count := 0;
	for approval_rec in get_approvals_cursor(c_response_header_id => p_response_header_id)
	loop
	   l_approval_tab(l_count).approval_sequence := approval_rec.approval_sequence;
	   l_approval_tab(l_count).approver_id := approval_rec.approver_id;
	   l_approval_tab(l_count).approver_name := approval_rec.approver_name;
	   l_approval_tab(l_count).approval_status := approval_rec.approval_status;
	   l_approval_tab(l_count).rule_id := approval_rec.rule_id;
	   l_approval_tab(l_count).rule_description := approval_rec.rule_description;
	   l_approval_tab(l_count).notification_date := approval_rec.notification_date;
	   l_approval_tab(l_count).response_date := approval_rec.response_date;
	   l_approval_tab(l_count).comments := approval_rec.comments;
	   l_approval_tab(l_count).archive_flag := approval_rec.archive_flag;
	   l_approval_tab(l_count).item_class := approval_rec.item_class;
	   l_approval_tab(l_count).item_id := approval_rec.item_id;

	   l_count := l_count+1;
	end loop;

	return l_approval_tab;

     end get_approvals_records;


     procedure insert_archive_record(p_response_header_id in number,
				     p_user_id in number,
				     p_action in varchar2,
				     p_comments in varchar2)
     is
	l_approval_tab approval_table_type;
	l_approval_rec approval_record_type;
	l_archive_tab approval_table_type;

     begin

	l_approval_tab := get_approvals_records(p_response_header_id, p_user_id);
	if l_approval_tab.count > 0
	then
	   l_approval_rec := l_approval_tab(0);
        else
	   l_approval_rec.approver_id := p_user_id;
	   select user_name into l_approval_rec.approver_name
	      from fnd_user
	      where user_id = p_user_id;
	end if;
	l_approval_rec.approval_sequence := -1;
	l_approval_rec.approval_status := p_action;
	l_approval_rec.response_date := sysdate;
	l_approval_rec.archive_flag := 'Y';
	l_approval_rec.comments := p_comments;

	l_archive_tab(0) := l_approval_rec;

	insert_approval_records(p_response_header_id => p_response_header_id,
				p_approvals_tab => l_archive_tab);

     end insert_archive_record;

     procedure update_with_ame(p_response_header_id in number,
			       p_user_id in number,
			       p_action in varchar2)
     is
	l_ame_approver_table ame_util.approversTable2;
	l_ame_item_indexes ame_util.idlist;
	l_ame_item_classes ame_util.stringlist;
	l_ame_item_ids ame_util.stringlist;
	l_ame_item_sources ame_util.longstringlist;
	l_ame_rule_indexes ame_util.idlist;
	l_ame_source_types ame_util.stringlist;
	l_ame_rule_ids ame_util.idlist;
	l_ame_rule_descs ame_util.stringlist;
	l_approval_rec approval_record_type;
	l_approvals_tab approval_table_type;
	l_approvals_complete varchar2(1);

     begin

	ame_api2.getAllApprovers6(
				  applicationIdIn => get_application_id(),
				  transactionTypeIn => g_transaction_type_id,
				  transactionIdIn => p_response_header_id,
				  approvalProcessCompleteYNOut => l_approvals_complete,
				  approversOut => l_ame_approver_table,
				  itemIndexesOut => l_ame_item_indexes,
				  itemClassesOut => l_ame_item_classes,
				  itemIdsOut => l_ame_item_ids,
				  itemSourcesOut => l_ame_item_sources,
				  ruleIndexesOut => l_ame_rule_indexes,
				  sourceTypesOut => l_ame_source_types,
				  ruleIdsOut => l_ame_rule_ids,
				  ruleDescriptionsOut => l_ame_rule_descs
				  );
	if(l_ame_approver_table.count > 0)
	then

	    for i in l_ame_approver_table.first .. l_ame_approver_table.last
	    loop

	       l_approval_rec := get_approval_record(l_ame_approver_table(i));
	       l_approval_rec.rule_id := l_ame_rule_ids(i);
	       l_approval_rec.rule_description := l_ame_rule_descs(i);
	       l_approvals_tab(i) := l_approval_rec;

	    end loop;
	 end if;


	 if l_approvals_tab.count > 0
	 then

	    for i in l_approvals_tab.first .. l_approvals_tab.last
	    loop

	       update qpr_pn_response_approvals
		  set approval_status = l_approvals_tab(i).approval_status
		  where response_header_id = p_response_header_id
		  and approver_id = l_approvals_tab(i).approver_id
		  and rule_id = l_approvals_tab(i).rule_id
		  and item_class = l_approvals_tab(i).item_class
		  and item_id = l_approvals_tab(i).item_id
		  and archive_flag = 'N';
	    end loop;

	    update qpr_pn_response_approvals
	       set notification_date = sysdate
	       where response_header_id = p_response_header_id
	       and approval_status like 'NOTIFIED%'
	       and notification_date is null
	       and archive_flag = 'N';

	 end if;

	 if p_action = 'APPROVE' or p_action = 'REJECT'
	 then
	    update qpr_pn_response_approvals
	       set approval_status = p_action
	       where response_header_id = p_response_header_id
	       and approver_id = p_user_id
	       and nvl(approval_status, 'NULL') in ('NOTIFIED', 'NULL')
	       and archive_flag = 'N';
	 end if;


      end update_with_ame;




     PROCEDURE INIT_APPROVALS(
			      p_response_header_id IN NUMBER,
			      p_user_id in number,
			      x_approvals_complete OUT NOCOPY VARCHAR2,
			      x_return_status OUT NOCOPY VARCHAR2
			      )
     IS
	l_approvals_tab approval_table_type;
	l_user_present_flag boolean;
     BEGIN

	x_return_status := FND_API.G_RET_STS_SUCCESS;
	--alosh: rebuilding ame to counter cases where transactions get reset
	rebuild_ame_status(p_response_header_id => p_response_header_id);

	--alosh: invoking ame to get the approver list
	get_ame_approvals(p_response_header_id => p_response_header_id,
			  x_approvals_tab => l_approvals_tab,
			  x_approvals_complete => x_approvals_complete);

	if not is_approvals_changed(p_response_header_id => p_response_header_id,
				    p_ame_approvals_tab => l_approvals_tab)
	then
	   return;
        end if;

	l_user_present_flag := false;
	if l_approvals_tab is not null and l_approvals_tab.count > 0
	then
	   for i in l_approvals_tab.first .. l_approvals_tab.last
	   loop
	      if l_approvals_tab(i).approver_id = p_user_id
	      then
		 l_user_present_flag := true;
	      end if;
	   end loop;
	end if;


	--alosh: deleting existing active records
	if l_user_present_flag
	then
	   clear_existing_approvals(p_response_header_id => p_response_header_id,
				    p_user_id => -999);
	else
	   clear_existing_approvals(p_response_header_id => p_response_header_id,
				    p_user_id => p_user_id);
	end if;

	--alosh: inserting new set of active records
	insert_approval_records(p_response_header_id => p_response_header_id,
				p_approvals_tab => l_approvals_tab);

	--alosh: commit thru UI
	--commit;

    EXCEPTION
    WHEN OTHERS THEN

       --alosh: rollback thru UI
       --rollback;
       x_return_status := FND_API.G_RET_STS_ERROR;
       raise;
    END INIT_APPROVALS;

    procedure send_notifications(
				 p_response_header_id in number,
				 p_approvals_tab in approval_table_type,
				 p_notification_type in varchar2,
				 p_comments in varchar2)
    is
       l_retcode number;
       l_errbuf varchar2(2000);
       l_user_list qpr_wkfl_util.char_type;
       l_user_list_cancel qpr_wkfl_util.char_type;
       l_requestor varchar2(50);
       l_requestor_present_flag boolean;
       l_increment number;
       cursor get_requestor_cancel(p_respone_header_id number)
       is
	  select approver_name
	  from qpr_pn_response_approvals
	  where approval_status = 'NOTIFIED'
	  and archive_flag = 'N'
	  and response_header_id = p_response_header_id;

       cursor get_requestor(p_respone_header_id number)
       is
	  select approver_name
	  from qpr_pn_response_approvals
	  where approval_status = 'SUBMIT'
	  and archive_flag = 'Y'
	  and response_header_id = p_response_header_id
	  order by last_update_date desc;
    begin

       open get_requestor(p_response_header_id);
       fetch get_requestor into l_requestor;
       close get_requestor;

       l_requestor_present_flag := false;

       if p_approvals_tab is not null and p_approvals_tab.count > 0
       then

	  for i in p_approvals_tab.first .. p_approvals_tab.last
	  loop
	     l_user_list(i) := p_approvals_tab(i).approver_name;
	     if l_user_list(i) = l_requestor
	     then
		l_requestor_present_flag := true;
	     end if;
	  end loop;
       end if;


       if l_requestor_present_flag = false
       then
	  if p_notification_type = 'APPROVE' or p_notification_type = 'REJECT'
	  then
	     if l_user_list is not null and l_user_list.count > 0
	     then
		l_user_list(l_user_list.last+1) := l_requestor;
	     else
		l_user_list(0) := l_requestor;
	     end if;
	  end if;
       end if;

       if l_user_list is not null and l_user_list.count > 0
       then

	  if p_notification_type = 'SUBMIT'
	  then

	     for i in l_user_list.first .. l_user_list.last
	     loop
		qpr_wkfl_util.invoke_toapp_nfn_process(
						       p_response_id => p_response_header_id,
						       p_fwd_to_user => l_user_list(i),
						       retcode => l_retcode,
						       errbuf => l_errbuf);
	     end loop;

	  elsif p_notification_type = 'CANCEL'
	  then

	   l_increment := 0;
            for requestor_record in get_requestor_cancel(p_response_header_id)
             loop
                l_user_list_cancel(l_increment) := requestor_record.approver_name;
                l_increment := l_increment + 1;
             end loop;

            --pp_debug('amitl_increment = '||l_increment||'response_header_id =  '||p_response_header_id);


            qpr_wkfl_util.cancel_toapp_nfn_process(
							p_response_id => p_response_header_id,
							p_usr_list => l_user_list_cancel,
							retcode => l_retcode,
						   	errbuf => l_errbuf);


	     qpr_wkfl_util.invoke_cb_nfn_process(
						 p_response_id => p_response_header_id,
						 p_usr_list => l_user_list,
						 p_comments => p_comments,
						 retcode => l_retcode,
						 errbuf => l_errbuf);
	  else

	     qpr_wkfl_util.invoke_appstat_nfn_process(
						      p_response_id => p_response_header_id,
						      p_usr_list => l_user_list,
						      p_comments => p_comments,
						      p_status => p_notification_type,
						      retcode => l_retcode,
						      errbuf => l_errbuf);
	  end if;
       end if;

    end send_notifications;

    procedure process_user_action(p_response_header_id in number,
				  p_user_id in number,
				  p_action_code in varchar2,
				  p_comments in varchar2,
				  p_standalone_call in boolean default false,
				  x_approvals_complete out nocopy varchar2,
				  x_return_status out nocopy varchar2)
    is
       l_approval_tab approval_table_type;
       l_temp_approval_tab approval_table_type;

    begin

       x_return_status := fnd_api.g_ret_sts_success;

       if not is_action_permitted(p_response_header_id => p_response_header_id,
				  p_user_id => p_user_id,
				  p_action_code => p_action_code)
       then
	  return;
       end if;

       --alosh: update ame status
       if p_action_code = 'APPROVE' or p_action_code = 'REJECT'
       then
	  update_ame_status(p_response_header_id => p_response_header_id,
			    p_user_id => p_user_id,
			    p_status => p_action_code,
			    x_prior_approvals_tab => l_approval_tab,
			    x_approvals_complete => x_approvals_complete);

       elsif p_action_code = 'CANCEL'
       then
	  clear_ame_status(p_response_header_id => p_response_header_id,
			   p_user_id => p_user_id,
			   x_cleared_approvals_tab => l_approval_tab);
       end if;


       --alosh: process next approvers
       if p_action_code = 'SUBMIT' or p_action_code = 'APPROVE'
       then
	  --alosh: update ame as notified
	  mark_ame_notified(
			    p_response_header_id => p_response_header_id,
			    x_notified_approvals_tab => l_temp_approval_tab);

	  --alosh: send approval notifications
	  send_notifications(
			     p_response_header_id => p_response_header_id,
			     p_approvals_tab => l_temp_approval_tab,
			     p_notification_type => 'SUBMIT',
			     p_comments => null);
	elsif p_action_code = 'CANCEL'
	then
		send_notifications(
			     p_response_header_id => p_response_header_id,
			     p_approvals_tab => l_temp_approval_tab,
			     p_notification_type => 'CANCEL',
			     p_comments => null);

       end if;

       --alosh: send fyi notifications
       if p_action_code = 'APPROVE' or p_action_code = 'REJECT' or p_action_code = 'CANCEL'
       then
	  send_notifications(
			     p_response_header_id => p_response_header_id,
			     p_approvals_tab => l_approval_tab,
			     p_notification_type => p_action_code,
			     p_comments => p_comments);
       end if;

       --alosh: insert archive record
       insert_archive_record(p_response_header_id => p_response_header_id,
			     p_user_id => p_user_id,
			     p_action => p_action_code,
			     p_comments => p_comments);

       --alosh: update tables
       update_with_ame(p_response_header_id => p_response_header_id,
		       p_user_id => p_user_id,
		       p_action => p_action_code);

       if p_standalone_call
       then
	  if p_action_code = 'REJECT'
	  then
	     update qpr_pn_response_hdrs
		set response_status = 'REJECT'
		where response_header_id = p_response_header_id;
	  elsif p_action_code = 'APPROVE' and x_approvals_complete = 'Y'
	  then
	     update qpr_pn_response_hdrs
		set response_status = 'PEND_ACCEPT_APPROVE'
		where response_header_id = p_response_header_id;
	  end if;

	  commit;
       end if;
    exception
       when others
       then
	  if p_standalone_call
	  then
	     rollback;
          end if;
	  x_return_status := fnd_api.g_ret_sts_error;
	  raise;
    end process_user_action;



    procedure process_user_action(p_response_header_id in number,
				  p_user_name in varchar2,
				  p_action_code in varchar2,
				  p_comments in varchar2,
				  p_standalone_call in boolean default false,
				  x_approvals_complete out nocopy varchar2,
				  x_return_status out nocopy varchar2)
    is
       l_user_id number;
    begin

       --alosh: get user id
       select distinct approver_id
	  into l_user_id
	  from qpr_pn_response_approvals
	  where response_header_id = p_response_header_id
	  and approver_name = p_user_name
	  and archive_flag = 'N';

       --alosh: call process_user_action
       process_user_action(p_response_header_id => p_response_header_id,
			   p_user_id => l_user_id,
			   p_action_code=> p_action_code,
			   p_comments => p_comments,
			   p_standalone_call => p_standalone_call,
			   x_approvals_complete => x_approvals_complete,
			   x_return_status => x_return_status);
    exception
       when others then
	  x_return_status := fnd_api.g_ret_sts_error;
	  raise;
    end process_user_action;



    procedure synch_approvals(
			      p_original_response_id in number,
			      p_new_response_id in number,
			      x_return_status out nocopy varchar2
			      )
    is

       cursor get_all_approvals_cursor(c_response_header_id number)
       is
	  select APPROVAL_SEQUENCE,
	  APPROVER_ID,
	  APPROVER_NAME,
	  APPROVAL_STATUS,
	  RULE_ID,
	  RULE_DESCRIPTION,
	  NOTIFICATION_DATE,
	  RESPONSE_DATE,
	  COMMENTS,
	  ARCHIVE_FLAG,
	  ITEM_CLASS,
	  ITEM_ID
	  from qpr_pn_response_approvals
	  where response_header_id = c_Response_header_id
	  order by archive_flag,approval_transaction_id;

       l_approvals_complete varchar2(1);
       l_ame_rec ame_util.approverRecord2;
       l_approvals_tab approval_table_type;
       l_count number;

    begin

       x_return_status := FND_API.G_RET_STS_SUCCESS;

       get_ame_approvals(p_response_header_id => p_new_response_id,
			 x_approvals_tab => l_approvals_tab,
			 x_approvals_complete => l_approvals_complete);

       synch_with_db(p_response_header_id => p_original_response_id,
		     x_approvals_tab => l_approvals_tab);

       l_count := 0;
       if l_approvals_tab.count > 0
       then
	  l_count := l_approvals_tab.first;
       end if;

       for l_approver_record in get_all_approvals_cursor(p_original_response_id)
       loop

	  if(l_approver_record.archive_flag = 'N')
	  then

	     l_ame_rec.name := l_approver_record.approver_name;
	     l_ame_rec.approval_status := l_approver_record.approval_status;

	     ame_api2.updateApprovalStatus(
					   applicationIdIn => get_application_id(),
					   transactionTypeIn => g_transaction_type_id,
					   transactionIdIn => p_new_response_id,
					   approverIn => l_ame_rec);
	     l_approvals_tab(l_count).approval_status := l_approver_record.approval_status;

	  else

	     l_approvals_tab(l_count).approver_id := l_approver_record.approver_id;
	     l_approvals_tab(l_count).approver_name := l_approver_record.approver_name;
	     l_approvals_tab(l_count).approval_sequence := l_approver_record.approval_sequence;
	     l_approvals_tab(l_count).approval_status := l_approver_record.approval_status;
	     l_approvals_tab(l_count).rule_id := l_approver_record.rule_id;
	     l_approvals_tab(l_count).rule_description := l_approver_record.rule_description;
	     l_approvals_tab(l_count).notification_date := l_approver_record.notification_date;
	     l_approvals_tab(l_count).response_date := l_approver_record.response_date;
	     l_approvals_tab(l_count).comments := l_approver_record.comments;
	     l_approvals_tab(l_count).archive_flag := l_approver_record.archive_flag;
	     l_approvals_tab(l_count).item_class := l_approver_record.item_class;
	     --l_approvals_tab(l_count).item_id := l_approver_record.item_id;

	  end if;
	  l_count:=l_count+1;

       end loop;

       insert_approval_records(p_response_header_id => p_new_response_id,
			       p_approvals_tab => l_approvals_tab);

    exception
       when others
       then
	  x_return_status := FND_API.G_RET_STS_ERROR;
	  raise;

    end synch_approvals;


    procedure process_stuck_notifications(
					  p_response_header_id in number,
					  p_user_id in number,
					  p_action_code in varchar2,
					  x_return_status out nocopy varchar2)
    is
       l_user_name varchar2(100);
       l_retcode number;
       l_errbuf varchar2(2000);
       l_user_list qpr_wkfl_util.char_type;

    begin

       x_return_status := FND_API.G_RET_STS_SUCCESS;

       if p_action_code = 'APPROVE' or p_action_code = 'REJECT'
       then

	  select distinct approver_name into l_user_name
	     from qpr_pn_response_approvals
	     where response_header_id = p_response_header_id
	     and approver_id = p_user_id;

	  qpr_wkfl_util.complete_toapp_nfn_process(
						   p_response_id => p_response_header_id,
						   p_current_user => l_user_name,
						   p_status => p_action_code,
						   retcode => l_retcode,
						   errbuf => l_errbuf);

     end if;
   EXCEPTION
       WHEN OTHERS THEN
	  x_return_status := FND_API.G_RET_STS_ERROR;
   END process_stuck_notifications;


   procedure clear_action_history(
				  p_response_header_id in number,
				  p_user_id in number,
				  p_action_code in varchar2,
				  x_return_status out nocopy varchar2)
   is

   begin

      delete from qpr_pn_response_approvals
	 where approval_transaction_id = (
					  select max(approval_transaction_id)
					  from qpr_pn_response_approvals
					  where response_header_id = p_response_header_id
					  and approver_id = p_user_id
					  and approval_status = p_action_code
					  and archive_flag = 'Y');
   end clear_action_history;



   PROCEDURE CHECK_COMPLIANCE(
			    p_response_header_id IN NUMBER,
			    o_comply out nocopy varchar2,
			    o_rules_desc out nocopy varchar2,
			    x_return_status OUT NOCOPY VARCHAR2
			    )
   IS
       l_application_id number;
       l_transaction_id varchar2(50);
       l_approval_complete_flag varchar2(10);
       l_ame_approver_table ame_util.approversTable2;
       l_itemIndexesOut ame_util.idList;
       l_itemClassesOut ame_util.stringList;
       l_itemIdsOut ame_util.stringList;
       l_itemSourcesOut ame_util.longStringList;
       l_ruleIndexesOut ame_util.idList;
       l_sourceTypesOut ame_util.stringList;
       l_ruleDescriptionsOut ame_util.stringList;
       l_rules_desc varchar2(1000);
       l_count number;
   BEGIN
       x_return_status := FND_API.G_RET_STS_SUCCESS;
       l_application_id := 667;
       l_transaction_id := p_response_header_id;
       o_comply := 'N';

	ame_api2.getAllApprovers5(
		       l_application_id,
		       g_transaction_type_id,
		       l_transaction_id,
		       l_approval_complete_flag,
		       l_ame_approver_table,
		       l_itemIndexesOut,
		       l_itemClassesOut,
		       l_itemIdsOut,
		       l_itemSourcesOut,
		       l_ruleIndexesOut,
		       l_sourceTypesOut,
		       l_ruleDescriptionsOut);
			/*	applicationIdIn in number,
                             transactionTypeIn in varchar2,
                             transactionIdIn in varchar2,
                             approvalProcessCompleteYNOut out nocopy varchar2,
                             approversOut out nocopy ame_util.approversTable2,
                             itemIndexesOut out nocopy ame_util.idList,
                             itemClassesOut out nocopy ame_util.stringList,
                             itemIdsOut out nocopy ame_util.stringList,
                             itemSourcesOut out nocopy ame_util.longStringList,
                             ruleIndexesOut out nocopy ame_util.idList,
                             sourceTypesOut out nocopy ame_util.stringList,
                             ruleDescriptionsOut out nocopy ame_util.stringList)*/
	if(l_ame_approver_table.count > 0) then
       	   o_comply := 'N';
	   l_count := 0;
	   for i in l_ruleDescriptionsOut.first .. l_ruleDescriptionsOut.last loop
	      l_rules_desc := l_rules_desc || l_ruleDescriptionsOut(i);
	      l_count := l_count + 1;
	      if l_count>9 then
		exit;
	      else
		l_rules_desc := l_rules_desc|| ' , ';
	      end if;
	   end loop;
	   o_rules_desc := l_rules_desc;
	else
	   o_comply := 'Y';
	end if;
   EXCEPTION
       WHEN OTHERS THEN
	  x_return_status := FND_API.G_RET_STS_ERROR;
   END;

END QPR_DEAL_APPROVALS_PVT;

/
