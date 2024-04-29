--------------------------------------------------------
--  DDL for Package Body BEN_CWB_RSGN_EMP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_CWB_RSGN_EMP" as
/* $Header: bencwbre.pkb 120.3.12010000.2 2008/09/10 11:13:25 cakunuru ship $ */
/* ===========================================================================+
 * Name
 *   Compensation workbench reassign employee
 * Purpose
 *
 *
 *
 *
 *
 * Version   Date           Author     Comment
 * -------+-----------+---------+----------------------------------------------
 * 115.0    01-July-2002   aupadhya    created
 * 115.1    07-Aug -2002   aupadhya    Modified, Calling ben_manage_life_events.rebuild_heirarchy
 *				       procedure for each employee instead of proposed ws manager.
 * 115.2    08-Aug-2002    aupadhya    Removed to_char used with string values.
 * 115.3    08-Aug-2002    aupadhya    Changed for workflow attributes name change.
 * 115.4    27-Aug-2002    aupadhya    Removed unused method and Fixed Bug#2526333.
 * 115.5    12-Sep-2002    aupadhya    Added code to provide value to a work-flow attribute FROM_ROLE
 * 115.6    28-Oct-2002    aupadhya    Added code to send an notification when exception occurs in
 *                                     set_approval method.
 * 115.7    30-Oct-2002    aupadhya    replaced sqlerrm with fnd_message.get in set_approval's Exception
 *                                     block.
 * 115.8    16 Dec 2002    hnarayan    Added NOCOPY hint
 * 115.9    24-Dec-2002    aupadhya    Modified for CWB Itemization.
 * 115.10   20-Feb-2003    aupadhya    Modified For Bug#2786444.
 * 115.11   24-Mar-2003    aupadhya    Modified For Bug#2786444, commented
 *				       hr_utility.set_location for fnd_message.get string, because
 *                                     it is erroring out for korean;
 * ==========================================================================+
 * 115.12    01-Mar-2004    aupadhya    Global Budgeting Changes.
 * 115.13    15-Mar-2004    aupadhya    Added summary refresh call.
 * 115.14    08-Jun-2004    aupadhya    Modifed logic for approver_hrchy cursor.
 * 115.15    20-Sep-2004    aupadhya    Global Budgeting 11.5.10
 * 115.16    22-Feb-2005    aupadhya    Audit Changes.
 * 115.16    14-Jul-2006    aupadhya    Added support for customer defined workflow
 *					process using profile value.
 * 115.17     15-Jul-2006    aupadhya   Custom workflow code logic change.
 * 115.21    04-Sep-2006    steotia     4722976: Chgd date fmt from -MON-
 * 115.22    10-Sep-2008   cakunuru   7159487: Changed recCount in start_workflow
 *
 * ==========================================================================+
 */

g_package             varchar2(80) := 'ben_cwb_rsgn_emp';

FUNCTION get_for_period(p_group_per_in_ler_id IN NUMBER)
     RETURN VARCHAR2
   IS
      CURSOR c11
      IS
         SELECT nvl(dsgn.wthn_yr_start_dt,dsgn.yr_perd_start_dt)||' - '||
         nvl(dsgn.wthn_yr_end_dt,dsgn.yr_perd_end_dt) forPeriod
           FROM ben_per_in_ler pil,
                ben_cwb_pl_dsgn dsgn
          WHERE pil.per_in_ler_id = p_group_per_in_ler_id
            AND pil.group_pl_id = dsgn.group_pl_id
            AND pil.lf_evt_ocrd_dt = dsgn.lf_evt_ocrd_dt
            AND dsgn.oipl_id = -1
            AND dsgn.group_pl_id = dsgn.pl_id
            AND dsgn.group_oipl_id = dsgn.oipl_id;
        l_info   c11%ROWTYPE;
   BEGIN
       OPEN c11;
       FETCH c11 INTO l_info;
       CLOSE c11;

       RETURN l_info.forPeriod;
    END;


procedure check_approver (itemtype                         in varchar2
      , itemkey                          in varchar2
      , actid                            in number
      , funcmode                         in varchar2
      , result                       out nocopy    varchar2)
	IS
		l_approver_user varchar2(240);
		l_approver_name varchar2(240);
		l_approver_last_name varchar2(240);
		c_next_approver_out ame_util.approverRecord;
		c_all_approvers   ame_util.approversTable;
		l_recCount number;
		l_flag number;
		l_requestorId number;
		l_package varchar2(80) := g_package||'.check_approver';
		l_error varchar2(5000);
		--l_itemkey varchar2(40):=itemkey;
	        cursor get_curr_approver_name(c_approver_id in number) is
	 		 select users.user_name ,  ppf.first_name  , ppf.last_name
	 		 from 	fnd_user users
		 	   ,per_All_people_f ppf
	 		 where  users.employee_id=ppf.person_id
	 		    and users.employee_id=c_approver_id
	 		    and trunc(sysdate) between ppf.effective_start_date and ppf.effective_end_date;

	BEGIN
	       /* Added modify logic from here */

       	       --hr_utility.trace_on (null, 'ORACLE');

	       hr_utility.set_location('Entering '||l_package ,30);

	       l_requestorId:=wf_engine.GetItemAttrNumber(itemtype => itemtype,
	    						itemkey => itemkey,
	    						aname => 'REQUESTOR_ID');
  	       hr_utility.set_location('in Find approver : 2',20);

	       l_flag  :=wf_engine.GetItemAttrNumber(itemtype => itemtype,
	    						itemkey => itemkey,
	    						aname => 'REQUESTOR_FLAG');


	       hr_utility.set_location('flag '||l_flag ,90);

	       hr_utility.set_location('From workflow : ' ||	wf_engine.GetItemAttrNumber(itemtype => itemtype,
	    						itemkey => itemkey,
	    						aname => 'REQUESTOR_FLAG'),90);
	   --   if l_flag = 1 then

	   if (wf_engine.GetItemAttrNumber(itemtype => itemtype,
	    						itemkey => itemkey,
	    						aname => 'REQUESTOR_FLAG')) = 1 then
		hr_utility.set_location('true condition ' ,100);
	      	result:='COMPLETE:' ||'NOT FOUND';
	   else

       	   ame_api.getNextApprover(applicationIdIn => 805,
							transactionIdIn => itemkey,
							transactionTypeIn => 'PROPEMPRSGN',
							nextApproverOut => c_next_approver_out);
	   hr_utility.set_location('false condition ' ,100);

	   if(c_next_approver_out.person_id is not null) then
	   		wf_engine.SetItemAttrNumber(  itemtype => itemtype
				                          , itemkey  => itemkey
				                          , aname    => 'RECEIVER_USER_ID'
		                                 , avalue   => c_next_approver_out.person_id);
		    open get_curr_approver_name(c_next_approver_out.person_id);
		    fetch get_curr_approver_name into l_approver_user,l_approver_name , l_approver_last_name;
				If get_curr_approver_name%found Then
				    hr_utility.set_location('appr is'||l_approver_user || ' , ' || c_next_approver_out.person_id || ' , ' ||l_approver_name,100);

				Else
				    hr_utility.set_location ('No Data Found'||l_approver_user || ' , ' || c_next_approver_out.person_id || ' , ' ||l_approver_name,100);

				End If;
			wf_engine.SetItemAttrText(  itemtype => itemtype
				                          , itemkey  => itemkey
				                          , aname    => 'RECEIVER_USER_NAME'
		                                 , avalue   => l_approver_user);
	   		hr_utility.set_location('Approver name is: '|| l_approver_name,200);


            update ben_transaction set attribute12= l_approver_name , attribute13= l_approver_last_name
								where attribute2= itemkey
								and attribute1= 'EMP'
            	  						and transaction_type='CWBEMPRSGN';



			result:='COMPLETE:' ||'FOUND';

            close get_curr_approver_name;
		else
			result:='COMPLETE:' ||'NOT FOUND';

		end if;
            end if;



             hr_utility.set_location('Leaving '||l_package ,30);
	EXCEPTION
    		when others then
    		l_error:=sqlerrm;
    		hr_utility.set_location ('exception is'||l_error , 300);
    		Wf_Core.Context('BEN_CWB_RSGN_EMP' ,  'check_approver',l_error);
		raise;
END check_approver;




procedure store_approval_details(itemtype    in varchar2
      , itemkey                          in varchar2
      , actid                            in number
      , funcmode                         in varchar2
      , result                       out nocopy    varchar2)
    is
    	l_approver_name varchar2(240);
    	l_approver_user varchar2(240);
    	l_approver_id number;
    	l_package varchar2(80) := g_package||'.store_approval_details';
    	l_error varchar2(5000);
    begin
    --hr_utility.trace_on (null, 'ORACLE');

     hr_utility.set_location('Entering '||l_package ,30);

    l_approver_id:= wf_engine.GetItemAttrNumber(itemtype => itemtype,
	    					itemkey => itemkey,
	    					aname => 'RECEIVER_USER_ID');
    l_approver_user := 	wf_engine.GetItemAttrText(itemtype => itemtype,
							   			itemkey => itemkey,
	    									aname => 'RECEIVER_USER_NAME');

    hr_utility.set_location('store approver details : Reveiver user id : '|| l_approver_id,10);

   wf_engine.SetItemAttrText(itemtype => itemtype
    			 		              , itemkey  => itemkey
    			 		              , aname    => 'FROM_ROLE'
             					      , avalue   =>
             						wf_engine.GetItemAttrText(itemtype => itemtype,
							   			itemkey => itemkey,
	    									aname => 'RECEIVER_USER_NAME')
             						);

            -- Need to catch notification id , it will used in approved/rejected
            -- notifications to show action history....
            -- Begin

            UPDATE ben_transaction
                SET attribute21 =
                        ( select notification_id
                           from wf_item_activity_statuses
                          where
                          item_key = itemkey
                          and item_type = itemtype
                          and assigned_user= l_approver_user
                           )
                        , attribute22 = l_approver_user
            WHERE attribute3=itemkey
	    	 and transaction_type='CWBEMPRSGN'
    		 and attribute1='APPR'
    		 and attribute21 is null;

            -- End..


    ame_api.updateApprovalStatus2(applicationIdIn =>805,
    						transactionIdIn => itemkey,
    						approvalStatusIn => ame_util.approvedStatus,
   						approverPersonIdIn=> l_approver_id,
    						transactionTypeIn=> 'PROPEMPRSGN' );

    hr_utility.set_location('Leaving '||l_package ,30);
    result:='COMPLETE:';

    EXCEPTION
    		when others then
    		l_error:=sqlerrm;
    		hr_utility.set_location ('exception is'||l_error , 300);
    		Wf_Core.Context('BEN_CWB_RSGN_EMP' ,  'store_emp_details',l_error);
		raise;


end store_approval_details;



procedure curr_ws_mgr_check(itemtype    in varchar2
      , itemkey                          in varchar2
      , actid                            in number
      , funcmode                         in varchar2
      , result                       out nocopy    varchar2)
    is
    	l_curr_manager_name varchar2(240);
    	l_requestor varchar2(240);
    	l_package varchar2(80) := g_package||'.curr_ws_mgr_check';
    	l_error varchar2(5000);
    begin
    	hr_utility.set_location('Entering '||l_package ,30);
    	l_curr_manager_name:= wf_engine.GetItemAttrText(itemtype => itemtype,
	    						itemkey => itemkey,
	    						aname => 'CURRENT_WS_MANAGER');
	l_requestor:= wf_engine.GetItemAttrText(itemtype => itemtype,
		    				itemkey => itemkey,
		    				aname => 'REQUESTOR');
	 if ( l_curr_manager_name  = l_requestor) then
	 		result:= 'COMPLETE:' ||'YES';
	 else
	 		result:= 'COMPLETE:' ||'NO';
	 end if;
	 hr_utility.set_location('Leaving '||l_package ,30);
    EXCEPTION
		when others then
		l_error:=sqlerrm;
		hr_utility.set_location ('exception is'||l_error , 300);
		Wf_Core.Context('BEN_CWB_RSGN_EMP' ,  'curr_ws_mgr_check',l_error);
		raise;

end curr_ws_mgr_check;



procedure prop_ws_mgr_check(itemtype    in varchar2
      , itemkey                          in varchar2
      , actid                            in number
      , funcmode                         in varchar2
      , result                       out nocopy    varchar2)
    is
    	l_prop_manager_name varchar2(240);
    	l_requestor varchar2(240);
    	l_package varchar2(80) := g_package||'.prop_ws_mgr_check';
    	l_error varchar2(5000);
    begin
    	hr_utility.set_location('Entering '||l_package ,30);
    	l_prop_manager_name:= wf_engine.GetItemAttrText(itemtype => itemtype,
	    						itemkey => itemkey,
	    						aname => 'PROPOSED_WS_MANAGER');
	l_requestor:= wf_engine.GetItemAttrText(itemtype => itemtype,
		    				itemkey => itemkey,
		    				aname => 'REQUESTOR');
	 if ( l_prop_manager_name  = l_requestor) then
	 		result:= 'COMPLETE:' ||'YES';
	 else
	 		result:= 'COMPLETE:' ||'NO';
	 end if;
	 hr_utility.set_location('Leaving '||l_package ,30);
    EXCEPTION
             		when others then
             		l_error:=sqlerrm;
             		hr_utility.set_location ('exception is'||l_error , 300);
             		--Wf_Core.Context('BEN_CWB_RSGN_EMP' ,  'prop_ws_mgr_check',l_error);
			raise;
end prop_ws_mgr_check;



procedure which_message(itemtype    in varchar2
      , itemkey                          in varchar2
      , actid                            in number
      , funcmode                         in varchar2
      , result                       out nocopy    varchar2)
    is
    	l_message_type varchar2(40);
    	l_error_message varchar2(2000);
    	l_package varchar2(80) := g_package||'.which_message';
    	l_error varchar2(5000);
    begin
	 		hr_utility.set_location('Entering '||l_package ,30);
	 		l_message_type:= wf_engine.GetItemAttrText(itemtype => itemtype,
						itemkey => itemkey,
	    					aname => 'MESSAGE_TYPE');
            if( l_message_type='COMPLETED') then
                    l_error_message := wf_engine.GetItemAttrText(itemtype => itemtype,
					                        	itemkey => itemkey,
                    	    					aname => 'ERROR_MESSAGE');
                    UPDATE ben_transaction
                       SET attribute40 = l_error_message
                     WHERE attribute2=itemkey
	    	           and transaction_type='CWBEMPRSGN'
                	   and attribute1='EMP';

            end if;

			result:='COMPLETE:'||l_message_type;
			hr_utility.set_location('Leaving '||l_package ,30);

    EXCEPTION
         		when others then
         		l_error:=sqlerrm;
         		hr_utility.set_location ('exception is'||l_error , 300);
         		Wf_Core.Context('BEN_CWB_RSGN_EMP' ,  'store_emp_details',l_error);
			raise;
end which_message;




procedure set_rejection(itemtype    in varchar2
      , itemkey                          in varchar2
      , actid                            in number
      , funcmode                         in varchar2
      , result                       out nocopy    varchar2)
    is

    	l_requestor varchar2(40);
    	l_approver_user varchar2(240);
    	l_package varchar2(80) := g_package||'.set_rejection';
    	l_error varchar2(5000);
    begin
    			hr_utility.set_location('Entering '||l_package ,30);

                l_approver_user := 	wf_engine.GetItemAttrText(itemtype => itemtype,
							   			itemkey => itemkey,
	    									aname => 'RECEIVER_USER_NAME');

    			wf_engine.SetItemAttrText(itemtype => itemtype
					              , itemkey  => itemkey
			 		              , aname    => 'FROM_ROLE'
			       			      , avalue   =>
			             			wf_engine.GetItemAttrText(itemtype => itemtype,
							   			itemkey => itemkey,
				    						aname => 'RECEIVER_USER_NAME')
             						);


            -- Need to catch notification id , it will used in approved/rejected
            -- notifications to show action history....
            -- Begin

            UPDATE ben_transaction
                SET attribute21 =
                        ( select notification_id
                           from wf_item_activity_statuses
                          where
                          item_key = itemkey
                          and item_type = itemtype
                          and assigned_user= l_approver_user
                           )
                        , attribute22 = l_approver_user
            WHERE attribute3=itemkey
	    	 and transaction_type='CWBEMPRSGN'
    		 and attribute1='APPR'
    		 and attribute21 is null;

            -- End..

	 		wf_engine.SetItemAttrText(  itemtype => itemtype
					                               , itemkey  => itemkey
					                               , aname    => 'MESSAGE_TYPE'
		                               				, avalue   => 'REJECTED');
		        result:='COMPLETE:';
                        hr_utility.set_location('Leaving '||l_package ,30);
    EXCEPTION
     		when others then
     		l_error:=sqlerrm;

     		hr_utility.set_location ('exception is'||l_error , 300);

     		Wf_Core.Context('BEN_CWB_RSGN_EMP' ,  'set_rejection',l_error);
		raise;
end set_rejection;





procedure set_approval(itemtype    in varchar2
      , itemkey                          in varchar2
      , actid                            in number
      , funcmode                         in varchar2
      , result                       out nocopy    varchar2)
    is
    	l_requestor varchar2(240);
    	l_obj_ver_num number;
	l_ws_mgr_id_old number;
    	l_ws_mgr_id number;
    	l_ws_mgr_per_in_ler_id number;
    	l_prop_mgr_per_in_ler_id number;
    	l_per_in_ler_id number;
    	l_pl_id number;
    	l_ovr_id number;
    	l_error fnd_new_messages.message_text%type;
    	l_approval_cd varchar2(10);
    	l_flag number:=0;
    	l_curr_ws_mgr varchar2(240);
    	l_prop_ws_mgr varchar2(240);
    	l_message fnd_new_messages.message_text%type;
    	l_package varchar2(80) := g_package||'.set_approval';

    	-- For API call begin
    	l_procd_dt  date;
	l_strtd_dt  date;
	l_voidd_dt  date;
	-- For API call end

    	cursor getEmpToReassign is
    		select attribute3 , attribute10 , attribute8 ,attribute14 , attribute16 , attribute5 || ' ' || attribute18 , attribute7 || ' ' || attribute19 , attribute21 , attribute6
    			from ben_transaction
    			where attribute2=itemkey
    			and  attribute1='EMP'
    			and transaction_type = 'CWBEMPRSGN';

        cursor getObjVerNum(c_per_in_ler_id in number) is
        	select  object_version_number
			from ben_per_in_ler
			where  per_in_ler_id = c_per_in_ler_id;

	cursor get_approval_cd(c_per_in_ler_id in number, c_pl_id in number) is
  	 select approval_cd
         from  	ben_cwb_person_groups
    	 where  group_per_in_ler_id =c_per_in_ler_id
    	 	and  group_pl_id=c_pl_id
    	 	and  group_oipl_id=-1;

    begin

	 		 --hr_utility.trace_on (null, 'ORACLE');

    			 hr_utility.set_location('Entering '||l_package ,30);

	 		wf_engine.SetItemAttrText(  itemtype => itemtype
					            , itemkey  => itemkey
					            , aname    => 'MESSAGE_TYPE'
					  	, avalue   => 'APPROVED');
			open getEmpToReassign;

			 fetch    getEmpToReassign into   l_per_in_ler_id,l_ovr_id,l_ws_mgr_id,l_prop_mgr_per_in_ler_id ,l_ws_mgr_per_in_ler_id,l_curr_ws_mgr,l_prop_ws_mgr,l_pl_id , l_ws_mgr_id_old;

			close getEmpToReassign;

			hr_utility.set_location ('Current manager choice id '||l_ws_mgr_per_in_ler_id,200);
			hr_utility.set_location ('Proposed manager choice id '||l_prop_mgr_per_in_ler_id,200);

			open get_approval_cd(l_ws_mgr_per_in_ler_id,l_pl_id);
			fetch get_approval_cd into l_approval_cd;
			close get_approval_cd;


			hr_utility.set_location ('current manager status '||l_approval_cd,200);

			if (  ((l_approval_cd ='AP')or(l_approval_cd='PR'))) then
				l_flag:=1;
			        hr_utility.set_location('Current manager processed ',200);

			        fnd_message.set_name('BEN','BEN_93118_CWB_RSGN_COMPLETED');
				fnd_message.set_token('PERSON_NAME',l_curr_ws_mgr);
				l_message:=fnd_message.get;

			end if;



			open get_approval_cd(l_prop_mgr_per_in_ler_id,l_pl_id);
			fetch get_approval_cd into l_approval_cd;
			close get_approval_cd;


			hr_utility.set_location('Proposed manager status '||l_approval_cd,200);

			if (l_flag = 0 ) then

				if ( ((l_approval_cd ='AP')or(l_approval_cd ='PR'))) then
					l_flag:=1;
					hr_utility.set_location ('Proposed manager processed ',200);
					fnd_message.set_name('BEN','BEN_93118_CWB_RSGN_COMPLETED');
					fnd_message.set_token('PERSON_NAME',l_prop_ws_mgr);
					l_message:=fnd_message.get;
				end if;
			end if;

			if l_flag=0 then

			for i in getEmpToReassign loop

				hr_utility.set_location('set Approval',200);



				l_per_in_ler_id := i.attribute3;
				l_ovr_id := i.attribute10;
				l_ws_mgr_id := i.attribute8;
				l_ws_mgr_per_in_ler_id := i.attribute16;

				open getObjVerNum(l_per_in_ler_id);
				fetch getObjVerNum into l_obj_ver_num;
				close getObjVerNum;



						ben_Person_Life_Event_api.update_Person_Life_Event
						(
						 p_validate                   => false
						,p_per_in_ler_id     		=> l_per_in_ler_id
						,p_mgr_ovrid_dt 	          => sysdate
						,p_mgr_ovrid_person_id        => l_ovr_id
						,p_ws_mgr_id                  => l_ws_mgr_id
						,p_object_version_number      => l_obj_ver_num
						,p_effective_date             => sysdate
						,p_group_pl_id		      => l_pl_id
						,p_procd_dt 		         => l_procd_dt
						,p_strtd_dt 			 => l_strtd_dt
						,p_voidd_dt 			=> l_voidd_dt
						);

						BEN_MANAGE_CWB_LIFE_EVENTS.rebuild_heirarchy(p_group_per_in_ler_id  => l_per_in_ler_id);

		       ben_cwb_summary_pkg.delete_pl_sql_tab;

                       hr_utility.set_location ('Current manager for summary '||l_ws_mgr_per_in_ler_id,200);
		       hr_utility.set_location ('Proposed manager for summary '||l_prop_mgr_per_in_ler_id,200);


                       BEN_CWB_SUMMARY_PKG.update_summary_on_reassignment
                                    (p_old_mgr_per_in_ler_id => l_ws_mgr_per_in_ler_id
                                     ,p_new_mgr_per_in_ler_id => l_prop_mgr_per_in_ler_id
                                     ,p_emp_per_in_ler_id => l_per_in_ler_id
                                     );

			ben_cwb_summary_pkg.save_pl_sql_tab;


			ben_cwb_audit_api.update_per_record
			 (p_per_in_ler_id      => l_per_in_ler_id
			 ,p_old_val           => l_ws_mgr_id_old
			 ,p_audit_type_cd     => 'MG'
			 );


			end loop;
			--ben_manage_life_events.rebuild_heirarchy(p_elig_per_elctbl_chc_id => l_ws_mgr_chc_id);

			wf_engine.SetItemAttrText(  itemtype => itemtype
						, itemkey  => itemkey
					        , aname    => 'MESSAGE_TYPE'
					, avalue   => 'APPROVED');
			else
			wf_engine.SetItemAttrText(  itemtype => itemtype
						, itemkey  => itemkey
					        , aname    => 'MESSAGE_TYPE'
					, avalue   => 'COMPLETED');

			wf_engine.SetItemAttrText(  itemtype => itemtype
							, itemkey  => itemkey
						        , aname    => 'ERROR_MESSAGE'
							, avalue   => l_message);


			end if;
			result:='COMPLETE:';
			 hr_utility.set_location('Leaving '||l_package ,30);
		EXCEPTION
		when others then
		hr_utility.set_location('Leaving '||sqlerrm ,30);
		l_error:=fnd_message.get;
		wf_engine.SetItemAttrText(  itemtype => itemtype
						, itemkey  => itemkey
					        , aname    => 'MESSAGE_TYPE'
					, avalue   => 'COMPLETED');
		wf_engine.SetItemAttrText(  itemtype => itemtype
							, itemkey  => itemkey
						        , aname    => 'ERROR_MESSAGE'
							, avalue   => l_error);

end set_approval;







/* To start workflow process
   When approval is required before reassignment
*/



procedure start_workflow(p_requestor_id in number,
			 p_curr_ws_manager_id number,
			 p_prop_ws_manager_id number,
			 p_plan_name varchar2,
			 p_message varchar2,
			 p_transaction_id number,
			 p_request_date  varchar2,
			 p_reccount number,
			 p_prop_ws_mgr_per_in_ler_id number,
			 p_plan_id number)
	  is
	     l_itemkey  number:=p_transaction_id;
	     l_itemtype varchar2(60) := 'BENCWBFY';
	     l_process_name varchar2(60) := 'RSGNP';
	     l_process_name_c varchar2(60);
	     l_package varchar2(80) := g_package||'.start_workflow';

	     cursor approver_name(c_approver_id in number) is
		 		 select users.user_name ,  ppf.first_name , ppf.last_name
		 		 from 	fnd_user users
		 		 	,per_all_people_f ppf
		 		 where
		 		  users.employee_id=ppf.person_id
		   		  and employee_id=c_approver_id
		   		  and trunc(sysdate) between ppf.effective_start_date and ppf.effective_end_date;

             cursor approver_hrchy(c_per_in_ler_id in number) is

			select  pil.person_id , pil.per_in_ler_id

			from   ben_cwb_group_hrchy hrchy,
			       ben_per_in_ler pil
			where  hrchy.emp_per_in_ler_id  = c_per_in_ler_id
				--and hrchy.mgr_per_in_ler_id    <> hrchy.emp_per_in_ler_id
 	  	                and hrchy.lvl_num <> 0
				and hrchy.mgr_per_in_ler_id  = pil.per_in_ler_id;


             cursor get_manager_id_from_pil(c_per_in_ler_id in number) is

	                  	  select  pil.person_id

	     		      	  from  ben_cwb_group_hrchy hrchy,
	     				ben_per_in_ler pil

	     			  where
	     			  	 hrchy.emp_per_in_ler_id =c_per_in_ler_id
	     			  	 and hrchy.mgr_per_in_ler_id <>hrchy.emp_per_in_ler_id
	     			  	 and hrchy.mgr_per_in_ler_id = pil.per_in_ler_id
			   	  	 and    LVL_NUM =1;


		cursor get_top_person_id(c_plan_id in number) is
			select distinct pil.person_id
			from ben_cwb_group_hrchy hrchy,
			ben_per_in_ler pil
			where
				pil.group_pl_id = c_plan_id
				and pil.per_in_ler_id= hrchy.mgr_per_in_ler_id
				and emp_per_in_ler_id=p_prop_ws_mgr_per_in_ler_id
				and hrchy.lvl_num = (select max(h1.lvl_num)
						      from ben_cwb_group_hrchy h1
							where   h1.emp_per_in_ler_id = p_prop_ws_mgr_per_in_ler_id
						  );

	     	 l_person_id number;
		 l_requestor_per_in_ler_id number;
		 l_requestor_person_id number;
		 l_requestor_name varchar2(240);
		 l_requestor_last_name varchar2(240);
		 l_requestor_user varchar2(240);
		 l_curr_ws_manager_name varchar2(240);
		 l_curr_ws_manager_last_name varchar2(240);
		 l_curr_ws_manager_user varchar2(240);
		 l_prop_ws_manager_name varchar2(240);
		 l_prop_ws_manager_last_name varchar2(240);
		 l_prop_ws_manager_user varchar2(240);
		 l_top_person_id number;
		 c_next_approver_out ame_util.approverRecord;
		 c_all_approvers   ame_util.approversTable;
		 l_recCount number:=0;
		 l_flag number;
		 l_requestor_flag number:=0;
		 l_transaction_id number;
		 l_error varchar2(5000);
		 l_for_period           VARCHAR2(30);
	  Begin

	     --select BEN_CWB_WF_NTF_S.NEXTVAL into l_itemkey from dual;

	         hr_utility.set_location('Entering '||l_package ,30);

	         hr_utility.set_location ('Seeded Rsgn Process Name'||l_process_name ,55);

    		 hr_utility.set_location ('Profile ::  '|| fnd_profile.value('BEN_CWB_EMP_RSGN_W_PROCESS') ,55);

	         l_process_name :=  nvl(fnd_profile.value('BEN_CWB_EMP_RSGN_W_PROCESS'),'RSGNP');

    		 hr_utility.set_location ('Rsgn Process Name After reading profile'||l_process_name ,55);

	         wf_engine.createProcess(    ItemType => l_itemtype,
	                                 ItemKey  => l_itemkey,
	                                 process  => l_process_name );

		 /*wf_engine.SetItemAttrText(  itemtype => l_itemtype
		                               , itemkey  => l_itemkey
		                               , aname    => 'MANAGER_NAME'
		                               , avalue   => 'TY');*/

        -- Changed for embedded region

        wf_engine.setitemattrtext (itemtype      => l_itemtype,
                                 itemkey       => l_itemkey,
                                 aname         => 'TRANSACTION_ID',
                                 avalue        => p_transaction_id
                                );

		 wf_engine.SetItemAttrText(  itemtype => l_itemtype
			 		                       , itemkey  => l_itemkey
			 		                       , aname    => 'PLAN_NAME'
			 		                       , avalue   =>  p_plan_name );
		 /*wf_engine.SetItemAttrText(  itemtype => l_itemtype
		 			 		              , itemkey  => l_itemkey
		 			 		              , aname    => 'COMMENTS_CURR_WS_MANAGER'
		 			 		              , avalue   =>  p_message ); */

		 open approver_name(p_curr_ws_manager_id);

		 fetch approver_name into l_curr_ws_manager_user , l_curr_ws_manager_name , l_curr_ws_manager_last_name ;
		 wf_engine.SetItemAttrText(  itemtype => l_itemtype
				             , itemkey  => l_itemkey
		 		             , aname    => 'CURRENT_WS_MANAGER'

		 , avalue   =>  l_curr_ws_manager_user );



		 close approver_name;
		 open approver_name(p_prop_ws_manager_id);
		 fetch approver_name into l_prop_ws_manager_user , l_prop_ws_manager_name , l_prop_ws_manager_last_name;
		 wf_engine.SetItemAttrText(  itemtype => l_itemtype
		 		                               , itemkey  => l_itemkey
		 	                               , aname    => 'PROPOSED_WS_MANAGER'

		 , avalue   =>  l_prop_ws_manager_user);



		 close approver_name;
		 open approver_name(p_requestor_id);
		 fetch approver_name into l_requestor_user , l_requestor_name , l_requestor_last_name  ;


		 wf_engine.SetItemAttrText(  itemtype => l_itemtype
		 	                               , itemkey  => l_itemkey
		 	                               , aname    => 'REQUESTOR_ID'
		                                      , avalue   => p_requestor_id);
		 wf_engine.SetItemAttrText(  itemtype => l_itemtype
		 		                               , itemkey  => l_itemkey
		 		                               , aname    => 'REQUESTOR_PERSON_NAME'
		 		                               , avalue   => l_requestor_name);
		 wf_engine.SetItemAttrText(  itemtype => l_itemtype
		 		 		                               , itemkey  => l_itemkey
		 		 		                               , aname    => 'REQUESTOR'
		 		 		                               , avalue   =>  l_requestor_user);

		 close approver_name;


	     	 wf_engine.SetItemAttrText(itemtype => l_itemtype
		              , itemkey  => l_itemkey
		              , aname    => 'FROM_ROLE'
           			, avalue   => l_requestor_user);

-- No longer is use
--	     wf_engine.SetItemAttrText(itemtype => l_itemtype,
--		 			        itemkey  => l_itemkey
--		 			 			        ,aname    => 'EMP_RSGN_SUMMARY'
--		 			 			        ,avalue   => 'PLSQL:BEN_CWB_RSGN_EMP.generate_detail_html/'||l_itemkey);
--		 wf_engine.SetItemAttrText(itemtype => l_itemtype,
--		 			 			         itemkey  => l_itemkey
--		 			 			        ,aname    => 'EMP_RSGN_EMP'
--			 			        ,avalue   => 'PLSQL:BEN_CWB_RSGN_EMP.generate_employee_table_html/'||l_itemkey);
--
--	     wf_engine.SetItemAttrText(itemtype => l_itemtype,
--		 			 			         itemkey  => l_itemkey
--		 			 			        ,aname    => 'EMP_RSGN_APPR'
--		 			 			        ,avalue   => 'PLSQL:BEN_CWB_RSGN_EMP.generate_approver_table_html/'||l_itemkey);
--
--    	 wf_engine.SetItemAttrText(itemtype => l_itemtype,
--			 			         itemkey  => l_itemkey
--			 			        ,aname    => 'EMP_RSGN_ERROR'
--			        ,avalue   => 'PLSQL:BEN_CWB_RSGN_EMP.generate_error_html/'||l_itemkey);
-- No longer is use


            l_for_period := get_for_period (p_prop_ws_mgr_per_in_ler_id);
            hr_utility.TRACE ('l_for_period ' || l_for_period);

             wf_engine.setitemattrtext (itemtype        => 'BENCWBFY',
                                       itemkey   => l_itemkey,
                                       aname     => 'FOR_PERIOD',
                                       avalue    => l_for_period
                                      );

	     	 /*wf_engine.StartProcess (  ItemType => l_itemtype,
	                               ItemKey  => l_itemkey );    */

		-- hr_utility.trace_on (null,'ORACLE');



	  -- Insert Approval information record , to fetch approver list in AME
	         open get_top_person_id(p_plan_id);
	         	fetch get_top_person_id into l_top_person_id;

	         close get_top_person_id;

	    	 select BEN_TRANSACTION_S.NEXTVAL into l_transaction_id from dual;

	    	 insert into ben_transaction(transaction_id,
	             			transaction_type,
	      				attribute1,
	      				attribute2,
	      				attribute3,
	      				attribute4,
	      				attribute5,
	      				attribute6,
	      				attribute7,
	      				attribute8,
	      				attribute9,
	      				attribute10,
	      				attribute40,
	      				attribute12,
	      				attribute13,
	      				attribute14,
	      				attribute15,
	      				attribute16)

	      			values (l_transaction_id,
	      				'CWBEMPRSGN',
	      				'APPR',
	      				p_prop_ws_manager_id,
	      				l_itemkey,
	      				p_plan_name,
	      				p_reccount,
	      				l_curr_ws_manager_name,
	      				l_prop_ws_manager_name,
	      				l_requestor_name,
	      				p_request_date,
	      				p_prop_ws_mgr_per_in_ler_id,
	      				p_message,
	      				l_top_person_id,
	      				p_prop_ws_manager_id,
	      				l_requestor_last_name,
	      				l_curr_ws_manager_last_name,
	      				l_prop_ws_manager_last_name
	      				);


  	  -- Approver change logic



	       hr_utility.set_location('in Find approver : 3.....',30);

	        -- To check whetehr requestor comes up in hrchy of proposed manager then
	        -- approver chain won't start from propsed manager but +1 'l_flag=1'
	        -- Start

	       open approver_hrchy(p_prop_ws_mgr_per_in_ler_id);
	       loop
	        fetch approver_hrchy into l_person_id,l_requestor_per_in_ler_id;
		exit when approver_hrchy%NOTFOUND;           -- bug: 7159487

		l_recCount:=l_recCount+1;				-- bug: 7159487

	       	   hr_utility.set_location(l_person_id , 50);
	           if(l_person_id = p_requestor_id ) then
		   	   l_flag:=1;
		   	   exit;
		   end if;


	       end loop;
	       close approver_hrchy;

	       if l_recCount=0 then
	       	l_requestor_flag:=1;
	       end if;


	       hr_utility.set_location('after looping'||l_itemkey,300);

		if l_flag=1 then

			 open get_manager_id_from_pil(l_requestor_per_in_ler_id);

			 fetch get_manager_id_from_pil into l_requestor_person_id;
			   if get_manager_id_from_pil%NOTFOUND then
			       l_requestor_flag:=1;
			   end if;

			   if l_requestor_person_id is null then
			       l_requestor_flag:=1;

			   end if;
			      hr_utility.set_location('flag'||l_requestor_flag,300);
			 close get_manager_id_from_pil;


		   if l_requestor_flag <> 1 then
			 update ben_transaction set attribute2=l_requestor_person_id
			 where attribute3=l_itemkey
			 and transaction_type='CWBEMPRSGN'
			 and attribute1='APPR';
	           end if;

     		end if;

     		-- End Approver change logic

     		-- Check if current and proposed worksheet manager both are same.
     		-- Start
     		if p_requestor_id=p_prop_ws_manager_id then

     		        hr_utility.set_location('Requestor and proposed ws manager same  .....',30);

     			--open get_popl_id_requestor(p_prop_ws_mgr_per_in_ler_id);
     			--fetch get_popl_id_requestor into l_requestor_popl_id;
     			--close get_popl_id_requestor;

     			l_requestor_per_in_ler_id := p_prop_ws_mgr_per_in_ler_id;
     			-- Same logic as above

     			open get_manager_id_from_pil(l_requestor_per_in_ler_id);

					 fetch get_manager_id_from_pil into l_requestor_person_id;
					   if get_manager_id_from_pil%NOTFOUND then
					       l_requestor_flag:=1;
					   end if;

					   if l_requestor_person_id is null then
					       l_requestor_flag:=1;

					   end if;
					      hr_utility.set_location('flag'||l_requestor_flag,300);
					 close get_manager_id_from_pil;

		     if l_requestor_flag <> 1 then
			 update ben_transaction set attribute2=l_requestor_person_id
			 where attribute3=l_itemkey
			 and transaction_type='CWBEMPRSGN'
			 and attribute1='APPR';
	             end if;

     		end if;

     		-- End Current and proposed ws manager check

  	  	wf_engine.SetItemAttrNumber(  itemtype => l_itemtype
	   	                          , itemkey  => l_itemkey
		                          , aname    => 'REQUESTOR_FLAG'
	                                  , avalue   => l_requestor_flag);


	        wf_engine.StartProcess (  ItemType => l_itemtype,
	                               ItemKey  => l_itemkey );

	        hr_utility.set_location('Leaving '||l_package ,30);

	EXCEPTION
		when others then
		l_error:=sqlerrm;

		hr_utility.set_location ('exception is'||l_error , 300);

		Wf_Core.Context('BEN_CWB_RSGN_EMP', 'start_workflow',l_error);
		raise;

 END start_workflow;




 /* To send FYI notifications
    when approval is not require
 */


 procedure send_fyi_notifications
 				(p_requestor_id in number,
				 p_curr_ws_manager_id number,
				 p_prop_ws_manager_id number,
				 p_plan_name varchar2,
				 p_message varchar2,
				 p_transaction_id number,
				 p_request_date varchar2,
				 p_reccount number,
                 p_prop_mgr_per_in_ler_id number)
    is

	    l_itemkey  number:=p_transaction_id;
	    l_itemtype varchar2(60) := 'BENCWBFY';
	    l_process_name varchar2(60) := 'RSGNNTFP';
	    l_package varchar2(80) := g_package||'.send_fyi_notifications';
	    l_error varchar2(5000);
	    l_for_period           VARCHAR2(30);

	    /*l_itemtype varchar2(60) := 'CWBREWF';
	    l_process_name varchar2(60) := 'CWBREP';*/

	    cursor approver_name(c_approver_id in number) is
		  select users.user_name ,  ppf.first_name  , ppf.last_name
		  from 	fnd_user users
		 	   ,per_all_people_f ppf
		  where
		  users.employee_id=ppf.person_id
  		  and users.employee_id=c_approver_id
  		  and trunc(sysdate) between ppf.effective_start_date and ppf.effective_end_date;

		l_requestor_name varchar2(240);
		l_requestor_last_name varchar2(240);
		l_requestor_user varchar2(240);
		l_curr_ws_manager_name varchar2(240);
		l_curr_ws_manager_last_name varchar2(240);
		l_curr_ws_manager_user varchar2(240);
		l_prop_ws_manager_name varchar2(240);
		l_prop_ws_manager_last_name varchar2(240);
		l_prop_ws_manager_user varchar2(240);
		l_transaction_id number;

	Begin
		     /*select BEN_CWB_WF_NTF_S.NEXTVAL into l_itemkey from dual;*/
			 hr_utility.set_location('Entering '||l_package ,30);
		         wf_engine.createProcess(    ItemType => l_itemtype,
		                                 ItemKey  => l_itemkey,

		                                 process  => l_process_name );
			 /*wf_engine.SetItemAttrText(  itemtype => l_itemtype
						 			 		                       , itemkey  => l_itemkey
						 			 		                       , aname    => 'HTML_TRY'
						 			 		                       , avalue   =>  l_html );
			 */


              -- Changed for embedded region

        wf_engine.setitemattrtext (itemtype      => l_itemtype,
                                 itemkey       => l_itemkey,
                                 aname         => 'TRANSACTION_ID',
                                 avalue        => p_transaction_id
                                );

			 wf_engine.SetItemAttrText(  itemtype => l_itemtype
								       , itemkey  => l_itemkey
								       , aname    => 'PLAN_NAME'
								       , avalue   =>  p_plan_name );
	 /*wf_engine.SetItemAttrText(  itemtype => l_itemtype
			 			 			 		              , itemkey  => l_itemkey
			 			 			 		              , aname    => 'COMMENTS_CURR_WS_MANAGER'
			 			 			 		              , avalue   =>  p_message ); */
			 open approver_name(p_curr_ws_manager_id);

			 fetch approver_name into l_curr_ws_manager_user , l_curr_ws_manager_name , l_curr_ws_manager_last_name  ;
			 wf_engine.SetItemAttrText(  itemtype => l_itemtype
			 		                               , itemkey  => l_itemkey
			 		                               , aname    => 'CURRENT_WS_MANAGER'
			 		                               , avalue   =>  l_curr_ws_manager_user );
		         close approver_name;
			 open approver_name(p_prop_ws_manager_id);
			 fetch approver_name into l_prop_ws_manager_user , l_prop_ws_manager_name , l_prop_ws_manager_last_name;
			 wf_engine.SetItemAttrText(  itemtype => l_itemtype
			 		                               , itemkey  => l_itemkey
			 		                               , aname    => 'PROPOSED_WS_MANAGER'
			 		                               , avalue   =>  l_prop_ws_manager_user);
			 close approver_name;

			 open approver_name(p_requestor_id);
			 fetch approver_name into l_requestor_user , l_requestor_name , l_requestor_last_name  ;
			 wf_engine.SetItemAttrText(  itemtype => l_itemtype
			 		 		                               , itemkey  => l_itemkey
			 		 		                               , aname    => 'REQUESTOR_PERSON_NAME'
			 		 		                               , avalue   => l_requestor_name);
			 wf_engine.SetItemAttrText(  itemtype => l_itemtype
		 		 		                               , itemkey  => l_itemkey
		 		 		                               , aname    => 'REQUESTOR'
		 		 		                               , avalue   =>  l_requestor_user);
			 close approver_name;

			 wf_engine.SetItemAttrText(itemtype => l_itemtype
			 		              , itemkey  => l_itemkey
			 		              , aname    => 'FROM_ROLE'
             						, avalue   => l_requestor_user);

			 wf_engine.SetItemAttrText(  itemtype => l_itemtype
								                               , itemkey  => l_itemkey
								                               , aname    => 'MESSAGE_TYPE'
					                               				, avalue   => 'FYI');
-- No longer is use
--	    	 wf_engine.SetItemAttrText(itemtype => l_itemtype,
--			 			         itemkey  => l_itemkey
--			 			        ,aname    => 'EMP_RSGN_SUMMARY'
--			 			        ,avalue   => 'PLSQL:BEN_CWB_RSGN_EMP.generate_detail_html/'||l_itemkey);
--			 wf_engine.SetItemAttrText(itemtype => l_itemtype,
--			 			         itemkey  => l_itemkey
--			 			        ,aname    => 'EMP_RSGN_EMP'
--			 			        ,avalue   => 'PLSQL:BEN_CWB_RSGN_EMP.generate_employee_table_html/'||l_itemkey);
--
--			wf_engine.SetItemAttrText(itemtype => l_itemtype,
--			 			         itemkey  => l_itemkey
--			 			        ,aname    => 'EMP_RSGN_APPR'
--			 			        ,avalue   => 'PLSQL:BEN_CWB_RSGN_EMP.generate_approver_table_html/'||l_itemkey);
-- No longer is use


                l_for_period := get_for_period (p_prop_mgr_per_in_ler_id);
                hr_utility.TRACE ('l_for_period ' || l_for_period);

                wf_engine.setItemattrText (itemtype        => l_itemtype,
                                       itemkey   => l_itemkey ,
                                       aname     => 'FOR_PERIOD',
                                       avalue    => l_for_period
                                      );


	    		 -- Make entry to make notification header

	    		 select BEN_TRANSACTION_S.NEXTVAL into l_transaction_id from dual;

			 insert into ben_transaction(transaction_id,
			 	             			transaction_type,
			 	      				attribute1,
			 	      				attribute2,
			 	      				attribute3,
			 	      				attribute4,
			 	      				attribute5,
			 	      				attribute6,
			 	      				attribute7,
			 	      				attribute8,
			 	      				attribute9,
			 	      				attribute40,
			 	      				attribute14,
			 	      				attribute15,
			 	      				attribute16)

			 	      			values (l_transaction_id,
			 	      				'CWBEMPRSGN',
			 	      				'APPR',
			 	      				p_prop_ws_manager_id,
			 	      				l_itemkey,
			 	      				p_plan_name,
			 	      				p_reccount,
			 	      				l_curr_ws_manager_name,
			 	      				l_prop_ws_manager_name,
			 	      				l_requestor_name,
			 	      				fnd_date.canonical_to_date(sysdate), --p_request_date,
			 	      				p_message,
			 	      				l_requestor_last_name,
			 	      				l_curr_ws_manager_last_name,
			 	      				l_prop_ws_manager_last_name);


	    		 wf_engine.StartProcess (  ItemType => l_itemtype,
		                               ItemKey  => l_itemkey );


  			 hr_utility.set_location('Leaving '||l_package ,30);

  	 EXCEPTION
		when others then
		l_error:=sqlerrm;

		hr_utility.set_location ('exception is'||l_error , 300);

		Wf_Core.Context('BEN_CWB_RSGN_EMP' ,  'send_fyi_notifications',l_error);
		raise;
  end 	send_fyi_notifications;




procedure store_emp_details
  			(p_per_in_ler_id in number,
  			 p_transaction_id in number,
  			 p_emp_name in varchar2,
  			 p_emp_num in varchar2,
  			 p_curr_ws_mgr in varchar2,
  			 p_curr_ws_mgr_id in number,
  			 p_prop_ws_mgr in varchar2,
  			 p_prop_ws_mgr_id in number,
  			 p_requestor in varchar2,
  			 p_requestor_id in number,
  			 p_request_date in varchar2,
  			 p_prop_ws_mgr_per_in_ler_id in number,
  			 p_curr_ws_mgr_per_in_ler_id in number,
  			 p_group_pl_id in number,
  			 p_business_group in varchar2
  			 )
  is



  l_transaction_id number;
  l_emp_first_name varchar2(240);
  l_emp_last_name  varchar2(240);
  l_curr_mgr_first_name varchar2(240);
  l_curr_mgr_last_name  varchar2(240);
  l_prop_mgr_first_name varchar2(240);
  l_prop_mgr_last_name  varchar2(240);
  l_requestor_first_name varchar2(240);
  l_requestor_last_name varchar2(240);
  l_package varchar2(80) := g_package||'.store_emp_details';
  l_error varchar2(5000);
  cursor requestor_name(c_requestor_id in number) is
  	 select ppf.first_name  , ppf.last_name
  	 from 	fnd_user users
  		,per_all_people_f ppf
  	 where
  		  users.employee_id=ppf.person_id
  		  and users.employee_id=c_requestor_id
  		  and trunc(sysdate) between ppf.effective_start_date and ppf.effective_end_date;


  begin
  --hr_utility.trace_on (null, 'ORACLE');
   hr_utility.set_location('Entering '||l_package ,30);

  l_emp_first_name := substr(p_emp_name,0, instr(p_emp_name,' ')-1);
  l_emp_last_name := substr(p_emp_name, instr(p_emp_name,' ')+1);

  l_curr_mgr_first_name:= substr(p_curr_ws_mgr,0, instr(p_curr_ws_mgr,' ')-1);
  l_curr_mgr_last_name:= substr(p_curr_ws_mgr, instr(p_curr_ws_mgr,' ')+1);

  l_prop_mgr_first_name:= substr(p_prop_ws_mgr,0, instr(p_prop_ws_mgr,' ')-1);
  l_prop_mgr_last_name:= substr(p_prop_ws_mgr, instr(p_prop_ws_mgr,' ')+1);

  open requestor_name(p_requestor_id);
  fetch requestor_name into  l_requestor_first_name , l_requestor_last_name  ;
  close requestor_name;

  select BEN_TRANSACTION_S.NEXTVAL into l_transaction_id from dual;

  insert into ben_transaction(transaction_id,
  							transaction_type,
  							attribute1,
  							attribute2,
  							attribute3,
  							attribute4,
  							attribute5,
  							attribute6,
  							attribute7,
  							attribute8,
  							attribute9,
  							attribute10,
  							attribute11,
  							attribute14,
  							attribute15,
  							attribute16,
  							attribute17,
  							attribute18,
  							attribute19,
  							attribute20,
  							attribute21,
  							attribute22
  							)
  			 values		(l_transaction_id,
  			 			 'CWBEMPRSGN',
  			 			 'EMP',
  			 			 p_transaction_id,
  			 			 p_per_in_ler_id,
  			 			 p_emp_num,
  			 			 l_curr_mgr_first_name,
  			 			 p_curr_ws_mgr_id,
  			 			 l_prop_mgr_first_name,
  			 			 p_prop_ws_mgr_id,
  			 			 l_requestor_first_name,
  			 			 p_requestor_id,
  			 			 fnd_date.canonical_to_date(sysdate) , --p_request_date,
  			 			 p_prop_ws_mgr_per_in_ler_id,
  						 l_emp_first_name,
  						 p_curr_ws_mgr_per_in_ler_id,
  						 l_emp_last_name,
  						 l_curr_mgr_last_name,
  						 l_prop_mgr_last_name,
  						 l_requestor_last_name,
  						 p_group_pl_id,
  						 p_business_group
  						);

	 hr_utility.set_location('Leaving '||l_package ,30);

 	EXCEPTION
 		when others then
 		l_error:=sqlerrm;

 		hr_utility.set_location ('exception is'||l_error , 300);

 		Wf_Core.Context('BEN_CWB_RSGN_EMP' ,  'store_emp_details',l_error);
		raise;


 end store_emp_details;




 procedure remove_emp_details(itemtype    in varchar2
       , itemkey                          in varchar2
       , actid                            in number
       , funcmode                         in varchar2
       , result                       out nocopy    varchar2)
     is

     l_package varchar2(80) := g_package||'.remove_emp_details';
     l_error varchar2(5000);
   begin

      hr_utility.set_location('Entering '||l_package ,30);
       update ben_transaction  set status='DEL'
            	  where attribute1= 'EMP'
            	  and transaction_type='CWBEMPRSGN'
     	          and attribute2=to_number(itemkey);

      result:='COMPLETE:';
      hr_utility.set_location('Leaving '||l_package ,30);

    EXCEPTION
   		when others then
   		l_error:=sqlerrm;

   		hr_utility.set_location ('exception is'||l_error , 300);

   		Wf_Core.Context('BEN_CWB_RSGN_EMP' ,  'remove_emp_details',l_error);
		raise;
 end remove_emp_details;



function is_in_comp_manager_role(p_person_id in number) return varchar2 is
		cursor c1(c_role_id in number) is
		          SELECT pei.person_id person_id, ppf.full_name person_name ,
		                 usr.user_name user_name, usr.user_id user_id
		          FROM   per_people_extra_info pei , per_all_people_f ppf ,
		                 fnd_user usr , pqh_roles rls
		          WHERE   information_type = 'PQH_ROLE_USERS' and pei.person_id = ppf.person_id
		                  and trunc(sysdate) between ppf.effective_start_date and ppf.effective_end_date
		                  and usr.employee_id = ppf.person_id
		                  and rls.role_id = to_number(pei.pei_information3)
		                  and nvl(pei.pei_information5,'Y')='Y'
		                  and rls.role_id = c_role_id;
		cursor c2 is select role_id,role_name
                  from pqh_roles
                  where role_type_cd ='CWB';

                l_package varchar2(80) := g_package||'.is_in_comp_manager_role';

		begin
			hr_utility.set_location('Entering '||l_package ,30);
			 for i in c2
			   loop
				for j in c1(i.role_id)
				loop
					if (j.person_id = p_person_id ) then
						return 'Y';
					end if;
				end loop;
		            end loop;
				  hr_utility.set_location('Leaving '||l_package ,30);
				return 'N';
		end;


PROCEDURE generate_detail_html
	(
	  document_id      IN      VARCHAR2,
		display_type     IN      VARCHAR2,
		document         IN OUT NOCOPY  VARCHAR2,
	  document_type    IN OUT NOCOPY  VARCHAR2
  )
  IS
  l_package varchar2(80) := g_package||'.generate_detail_html';
  BEGIN
  hr_utility.set_location('Entering '||l_package ,30);
  -- No longer is use
  hr_utility.set_location('Leaving '||l_package ,30);
  END;

 PROCEDURE generate_employee_table_html
 		(
 		  document_id      IN      VARCHAR2,
 			display_type     IN      VARCHAR2,
 			document         IN OUT NOCOPY  VARCHAR2,
 		  document_type    IN OUT NOCOPY  VARCHAR2
 	  )
 	  IS
 	  l_package varchar2(80) := g_package||'.generate_employee_table_html';
 	  BEGIN
 	   hr_utility.set_location('Entering '||l_package ,30);
    -- No longer is use
       hr_utility.set_location('Leaving '||l_package ,30);
  END;

 /*
  generate_approver_table_html
 */

PROCEDURE generate_approver_table_html
  	(
  	  document_id      IN      VARCHAR2,
  		display_type     IN      VARCHAR2,
  		document         IN OUT NOCOPY  VARCHAR2,
  	  document_type    IN OUT NOCOPY  VARCHAR2
    )
    IS
    l_package varchar2(80) := g_package||'.generate_approver_table_html';
    BEGIN
    hr_utility.set_location('Entering '||l_package ,30);
    -- No longer is use
    hr_utility.set_location('Leaving '||l_package ,30);
  END;

PROCEDURE generate_error_html
  	(
  	  document_id      IN      VARCHAR2,
  	  display_type     IN      VARCHAR2,
  		document         IN OUT NOCOPY  VARCHAR2,
  	  document_type    IN OUT NOCOPY  VARCHAR2
  	)
  IS
    l_package varchar2(80) := g_package||'.generate_error_html';
  BEGIN
    hr_utility.set_location('Entering '||l_package ,30);
    -- No longer is use
    hr_utility.set_location('Leaving '||l_package ,30);
  END;

END BEN_CWB_RSGN_EMP;

/
