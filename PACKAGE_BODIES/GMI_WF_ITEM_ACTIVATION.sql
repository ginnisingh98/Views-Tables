--------------------------------------------------------
--  DDL for Package Body GMI_WF_ITEM_ACTIVATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMI_WF_ITEM_ACTIVATION" as
/*  $Header: gmiitmwb.pls 120.1 2005/10/03 11:52:28 jsrivast noship $ */

	procedure init_wf
	(
		/* called via trigger on ic_item_mst */
		p_item_id in number,
		p_item_no in varchar2,
		p_item_um in varchar2,
		p_item_desc1 in varchar2,
		p_created_by in varchar2
	)
	is
		l_itemtype     varchar2(30) := 'GMWITACT';
		l_itemkey      varchar2(30) := to_char(p_item_id);
		l_WorkflowProcess varchar2(30) := 'ITEM_ACTIVATION_PROC';
		l_name         wf_users.name%type;
		l_display_name wf_users.display_name%type;
		l_errname      varchar2(30);
		l_errmsg       varchar2(2000);
		l_status       varchar2(2000);
		l_errstack     varchar2(32000);
                l_result       VARCHAR2 (30);
                wf_item_exists   EXCEPTION ;

esig_active              VARCHAR2(2);

	begin
          /*Check if the workflow data exists and remove the same for the itemtype and itemkey
                                                                                combination */



      BEGIN
         IF (FND_PROFILE.DEFINED('GMI_ERES_ACTIVE')) THEN
            esig_active :=  FND_PROFILE.VALUE('GMI_ERES_ACTIVE');
            IF (esig_active = '1') THEN
               return;      -- if eres active for item abort the workflow
            END IF;
         END IF;


         IF (wf_item.item_exist (l_itemtype, l_itemkey)) THEN
            /* Check the status of the root activity */
            wf_item_activity_status.root_status (l_itemtype, l_itemkey, l_status, l_result);
            /* If it is not completed then abort the process */
            IF (l_status = 'COMPLETE')THEN
            /* Purge the workflow data for workflow key */
               wf_purge.items(itemtype=> l_itemtype, itemkey=> l_itemkey, docommit=>FALSE);
            END IF;
         END IF;
          EXCEPTION
             WHEN OTHERS THEN
             WF_CORE.CONTEXT ('GMI_WF_ITEM_ACTIVATION', 'init_wf', l_itemtype, l_itemkey) ;
             WF_CORE.GET_ERROR (l_errname, l_errmsg, l_errstack);
             RAISE;
      END;
	BEGIN
                /*  create the process */
		wf_engine.createprocess (itemtype => l_itemtype,
					itemkey => l_itemkey,
					process => l_WorkflowProcess);
                EXCEPTION
                WHEN DUP_VAL_ON_INDEX THEN
                     RAISE wf_item_exists ;
        END ;

		/*  get the user name from fnd_user */
		select
			user_name
		into
			l_name
		from
			fnd_user
		where
			user_id = p_created_by;


            /*  the following is a hack to get the display_name */
		/*  it should be replaced by a proper API, and depends upon the */
		/*  fnd_user row containing the user's display_name in the */
		/*  description field */
                /* BEGIN BUG#2513365 Nayini Vikranth                        */
                /* Added the ROWNUM condition to avoid the ON-INSERT error. */
		select
			display_name
		into
			l_display_name
		from
			wf_users
		where
			name = l_name
                and
                        rownum =1;
                /* END BUG#2513365 */



		/*  set the item attributes */
		wf_engine.setitemattrnumber (itemtype => l_itemtype,
				itemkey => l_itemkey, aname => 'ITEM_ID',
				avalue => p_item_id);

               wf_engine.setitemattrtext(itemtype => l_itemtype,
				itemkey => l_itemkey, aname => 'ITEM_NO',
				avalue => p_item_no);

               wf_engine.setitemattrtext(itemtype => l_itemtype,
				itemkey => l_itemkey, aname => 'ITEM_UM',
				avalue => p_item_um);

               wf_engine.setitemattrtext(itemtype => l_itemtype,
				itemkey => l_itemkey, aname => 'ITEM_DESC1',
				avalue => p_item_desc1);

               wf_engine.setitemattrtext(itemtype => l_itemtype,
				itemkey => l_itemkey, aname => 'REQNAME',
				avalue => l_name);

               wf_engine.setitemattrtext(itemtype => l_itemtype,
				itemkey => l_itemkey,
				aname => 'REQDISP',
				avalue => l_display_name);

		wf_engine.startprocess (itemtype => l_itemtype,
				itemkey =>l_itemkey);

		/*  the inactive_ind on the inventory item */
		/*  is set in the trigger, not here! */

	exception
               WHEN wf_item_exists THEN
               null;
               when others then
			wf_core.context ('GMI_WF_ITEM_ACTIVATION',
					'INIT_WF',
					l_itemtype, l_itemkey,
					p_item_id, p_item_no);
			wf_core.get_error (l_errname, l_errmsg, l_errstack);
			if ((l_errname is null) and (sqlcode <> 0))
			then
				l_errname := to_char(sqlcode);
				l_errmsg  := sqlerrm(-sqlcode);
			end if;
		raise;
	end init_wf;

	procedure select_approver
	(
		p_itemtype in varchar2,
		p_itemkey in varchar2,
		p_actid in number,
		p_funcmode in varchar2,
		p_result out nocopy varchar2
	)
	is
		l_item_no varchar2(32) :=
			wf_engine.getitemattrtext (p_itemtype, p_itemkey,
				'ITEM_NO');
		l_requestor_name varchar2(100) :=
			wf_engine.getitemattrtext (p_itemtype, p_itemkey,
				'REQNAME');
		l_requestor_display_name varchar2(100) :=
			wf_engine.getitemattrtext (p_itemtype, p_itemkey,
				'REQDISP');
		l_approver_name varchar2(100);
		l_approver_display_name varchar2(100);

		l_sqlcode number;
		l_sqlerrm varchar2(512);
		l_errname varchar2(30);
		l_errmsg  varchar2(2000);
		l_errstack varchar2(32000);
                l_hierarchy_flag varchar2(20);
                l_item_desc      varchar2(72);

		selection_cancelled exception;
		selection_timeout  exception;
		pragma exception_init(selection_cancelled, -20101);
		pragma exception_init(selection_timeout,  -20102);
	begin
		if (p_funcmode = 'RUN')	then
                /* Added the code to fix bug 1102815 */
                       IF (FND_PROFILE.DEFINED ('IC$WF_ITEM_HIERARCHY')) THEN
         		       l_hierarchy_flag := FND_PROFILE.VALUE ('IC$WF_ITEM_HIERARCHY');
                               IF (l_hierarchy_flag is NULL) THEN
                                  p_result := 'COMPLETE:SELERR';
                                  return;
                               END IF;
                        END IF;
                        IF (l_hierarchy_flag = 'HRMS') THEN
			   select c.user_name,wu.display_name
			   into   l_approver_name,l_approver_display_name
			   from   per_assignments_f a, fnd_user b, fnd_user c,	wf_roles wu
			   where  a.person_id=b.employee_id
                                  and a.supervisor_id=c.employee_id
                                  and b.user_name = l_requestor_name
			          and wu.name = c.user_name
                           group by c.user_name,wu.display_name;
                        ELSIF (l_hierarchy_flag = 'OPM') THEN
                           SELECT supervisor_user_name, wu.display_name
                             into l_approver_name,l_approver_display_name
                             from ic_item_hierarchy , wf_roles wu
                            where creator_user_name = l_requestor_name
                              and rownum = 1
                              and supervisor_user_name=wu.name;
                         END IF;

                           Select ITEM_DESC1 into l_item_desc
                            from  IC_ITEM_MST
                            where ITEM_NO=l_ITEM_NO;

                        wf_engine.setitemattrtext(itemtype => p_itemtype,
		                                  itemkey => p_itemkey, aname => 'ITEM_DESC1',
				                  avalue => l_item_desc);

			wf_engine.setitemattrtext (itemtype => p_itemtype,
					itemkey => p_itemkey,
					aname => 'APPNM',
					avalue => l_approver_name);

			wf_engine.setitemattrtext (itemtype => p_itemtype,
					itemkey => p_itemkey,
					aname => '#FROM_ROLE',
					avalue => l_approver_name);

			wf_engine.setitemattrtext (itemtype => p_itemtype,
					itemkey => p_itemkey,
					aname => 'APPDISP',
					avalue => l_approver_display_name);
			p_result := 'COMPLETE:FOUND';
			return;
		end if;

		if (p_funcmode = 'CANCEL') then
                    raise selection_cancelled;
		end if;

		if (p_funcmode = 'TIMEOUT') then
                    raise selection_timeout;
		end if;

	exception
		when selection_cancelled then
			wf_engine.setitemattrtext (p_itemtype,
				p_itemkey, 'ERRMSG',
	'The workflow approver selection process was cancelled for item ' ||
					l_item_no || '.');
			p_result := 'COMPLETE:SELERR';
			return;
		when selection_timeout then
			wf_engine.setitemattrtext (p_itemtype,
				p_itemkey, 'ERRMSG',
		'The workflow approver selection process timed out for item ' ||
					l_item_no || '.');
			p_result := 'COMPLETE:SELERR';
			return;
		when no_data_found then
                  IF (FND_PROFILE.DEFINED ('IC$WF_DEFAULT_ITEM_APPROVER')) THEN
        		       l_approver_name := FND_PROFILE.VALUE ('IC$WF_DEFAULT_ITEM_APPROVER');
                      IF l_approver_name is NULL THEN
                         p_result := 'COMPLETE:SELERR';
                         return;
                      ELSE

                         select  display_name into l_approver_display_name
                         from wf_roles where name =l_approver_name;


                        	wf_engine.setitemattrtext (itemtype => p_itemtype,
					itemkey => p_itemkey,
					aname => 'APPNM',
					avalue => l_approver_name);

					wf_engine.setitemattrtext (itemtype => p_itemtype,
					itemkey => p_itemkey,
					aname => 'APPDISP',
					avalue => l_approver_display_name);
                              p_result := 'COMPLETE:FOUND';
                             return;

                       END IF;
                   ELSE
                          p_result := 'COMPLETE:SELERR';
                          return;
                   END IF;
     	when others then
			l_sqlcode := sqlcode;
			l_sqlerrm := sqlerrm (-l_sqlcode);
			wf_core.get_error (l_errname, l_errmsg, l_errstack);
			if ((l_errname is null) and (sqlcode <> 0))
			then
				l_errname := to_char(sqlcode);
				l_errmsg  := sqlerrm(-sqlcode);
			end if;
			wf_engine.setitemattrtext (p_itemtype,
				p_itemkey, 'ERRMSG',
				'A database error occurred in ' ||
				'the workflow approver selection ' ||
				'process for item ' || l_item_no ||
				'.  Message text: ' || l_errmsg);
			p_result := 'COMPLETE:SELERR';
			return;
	end select_approver;

	procedure activate_item
	(
		p_itemtype in varchar2,
		p_itemkey in varchar2,
		p_actid in number,
		p_funcmode in varchar2,
		p_result out nocopy varchar2
	)
	is
		l_item_id number :=
			wf_engine.getitemattrnumber (p_itemtype, p_itemkey,
				'ITEM_ID');
		l_item_no varchar2(32) :=
			wf_engine.getitemattrtext (p_itemtype, p_itemkey,
				'ITEM_NO');
		l_sqlcode number;
		l_sqlerrm varchar2(512);
		l_errname varchar2(30);
		l_errmsg  varchar2(2000);
		l_errstack varchar2(32000);

		activate_cancelled exception;
		activate_timeout  exception;
		pragma exception_init(activate_cancelled, -20103);
		pragma exception_init(activate_timeout,  -20104);
	begin
		if (p_funcmode = 'RUN')
		then
			update
				ic_item_mst
			set
				inactive_ind = 0, trans_cnt = -99
			where
				item_id = l_item_id;
			p_result := 'COMPLETE:ACTIVE';
			return;
		end if;

		if (p_funcmode = 'CANCEL')
		then
			p_result := 'COMPLETE:INACTIVE';
			return;
		end if;

		if (p_funcmode = 'TIMEOUT')
		then
			p_result := 'COMPLETE:INACTIVE';
			return;
		end if;

	exception
		when activate_cancelled then
			wf_engine.setitemattrtext (p_itemtype,
				p_itemkey, 'ERRMSG',
		'The workflow item activation process was cancelled for item '||
					l_item_no || '.');
			p_result := 'ERROR:';
			return;
		when activate_timeout then
			wf_engine.setitemattrtext (p_itemtype,
				p_itemkey, 'ERRMSG',
		'The workflow item activation process timed out for item ' ||
					l_item_no || '.');
			p_result := 'ERROR:';
			return;
		when no_data_found then
			p_result := 'ERROR:';
			return;
		when others then
			l_sqlcode := sqlcode;
			l_sqlerrm := sqlerrm (-l_sqlcode);
			wf_engine.setitemattrtext (p_itemtype,
				p_itemkey, 'ERRMSG',
				'A database error occurred in ' ||
				'the workflow item activation ' ||
				'process for item ' || l_item_no ||
				'.  Message text: ' || l_sqlerrm);
			p_result := 'ERROR:';
			return;
	end activate_item;


end gmi_wf_item_activation;

/
