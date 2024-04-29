--------------------------------------------------------
--  DDL for Package Body PO_WF_PO_RULE_ACC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_WF_PO_RULE_ACC" AS
/* $Header: POXRUACB.pls 120.1.12010000.7 2014/03/06 13:10:21 sbontala ship $*/

-- Read the profile option that enables/disables the debug log
g_po_wf_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('PO_SET_DEBUG_WORKFLOW_ON'),'N');

  l_segment_table   	t_segment_table;
  l_counter		NUMBER  := -1;

  --------------------------------------------------------------------
  -- Procedure get_default_requester_acc gets the requester's default
  -- charge account code_combination_id.
  --

PROCEDURE get_default_requester_acc (  	itemtype        in  varchar2,
                                 	itemkey         in  varchar2,
	                         	actid           in number,
                                 	funcmode        in  varchar2,
                                 	result          out NOCOPY varchar2  )
is
	x_progress              varchar2(100);
	x_requester_id		NUMBER;
	x_ccid			NUMBER;
--<Bug2711577 fix variable define START>
        x_bg_id_hr              NUMBER;
        x_bg_id_fsp             NUMBER;
--<Bug2711577 fix variable define END>

--< Shared Proc FPJ Start >
    l_expense_rules_org_id NUMBER;
--< Shared Proc FPJ End >

BEGIN




  x_progress := 'PO_WF_PO_RULE_ACC.get_default_requester_acc: 01';
  IF (g_po_wf_debug = 'Y') THEN
     PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;


  -- Do nothing in cancel or timeout mode
  --
  if (funcmode <> wf_engine.eng_run) then
      result := wf_engine.eng_null;
      return;

  end if;

  x_progress := 'PO_WF_PO_RULE_ACC.get_default_requester_acc: 02';
  x_requester_id := PO_WF_UTIL_PKG.GetItemAttrNumber(itemtype => itemtype,
                                   	       	itemkey  => itemkey,
                            	 	       	aname    => 'TO_PERSON_ID');

  /* Bug#11810952-Start: If there exists no "Deliver-To" person, consider
                         "Preparer" as Requester. */
  IF x_requester_id IS NULL THEN
    x_requester_id := PO_WF_UTIL_PKG.GetItemAttrNumber(itemtype => itemtype,
						  itemkey  => itemkey,
						  aname    => 'PREPARER_ID');
  END IF;
  /* Bug#11810952-End */

--< Shared Proc FPJ Start >

  -- The Expense Account Rules are called from the PO AG Workflow
  -- twice -- once for POU and then second time for DOU. Therefore,
  -- all the queries in this package that assume the ORG_ID from
  -- the org context, needs to join explicitly to the ORG_ID given
  -- in the attribute EXPENSE_RULES_ORG_ID.
  --     This attribute is populated in the WF, before calling the
  -- Expense Account rules to either POU or DOU's org ID depending
  -- on which OU's accounts are being generated.
  --     For Req AG Workflow, the attribute EXPENSE_RULES_ORG_ID
  -- would not be present. In that case,
  -- the PO_WF_UTIL_PKG.GetItemAttrNumber() would return NULL.
  -- Then, we would populate it with the ORG_ID in the org context.

  l_expense_rules_org_id := PO_WF_UTIL_PKG.GetItemAttrNumber(
                                    itemtype => itemtype,
                                   	itemkey  => itemkey,
                            	 	aname    => 'EXPENSE_RULES_ORG_ID');

  -- If it is NULL and the org context's org_id is not null, then copy
  -- org_context's org_id.
  IF  l_expense_rules_org_id IS NULL THEN


    l_expense_rules_org_id := po_moac_utils_pvt.get_current_org_id; --<R12 MOAC>


  END IF;
--< Shared Proc FPJ End >

--<Bug2711577 fix code change START>

--Replaced the previous piece of code to include foll. SQL.
-- SQL What: Querying for Code Combination ID for the employee
-- SQL Why: Need to build the Charge Account Values
-- SQL Join: employee_id and business_group_id

  -- bug 2744108
  -- The chart of accounts tied to the user can differ from that of the org.
  -- This check prevents an invalid attempt to copy values between the
  -- differing flex field structures at a later step in the workflow process.
   -- <re-opened due to bug 3589917>
   -- The check should be that the chart of accounts associated with the
   -- current org and the chart of accounts associated with the employee
   -- are consistent, instead of the set of books being identical.
   -- Different sets of books can share the same chart of accounts.

-- Bug 11808891
 --Bug 12358011 Added x_requester_id condition and Exception block
		BEGIN

		     SELECT hcerv.default_code_comb_id,
					       hcerv.business_group_id,
					       fsp.business_group_id
		     INTO   x_ccid, x_bg_id_hr, x_bg_id_fsp
		     FROM   (SELECT p.person_id,
		               p.business_group_id,
		               a.default_code_comb_id,
		               a.set_of_books_id
		        FROM   per_people_f p,
		               per_all_assignments_f a,
		               per_periods_of_service ps
		        WHERE  a.person_id = p.person_id
		               AND a.person_id = ps.person_id
		               AND a.person_id = x_requester_id
		               AND a.assignment_type = 'E'
		               AND p.employee_number IS NOT NULL
                               AND a.primary_flag = 'Y' -- Added for Bug 16984978
		               AND a.period_of_service_id = ps.period_of_service_id
		               AND Trunc(SYSDATE) BETWEEN p.effective_start_date AND
		                                          p.effective_end_date
		               AND Trunc(SYSDATE) BETWEEN a.effective_start_date AND
		                                          a.effective_end_date
		               AND ( ps.actual_termination_date >= Trunc(SYSDATE)
		                      OR ps.actual_termination_date IS NULL )
		        UNION ALL
		        SELECT p.person_id,
		               p.business_group_id,
		               a.default_code_comb_id,
		               a.set_of_books_id
		        FROM   per_people_f p,
		               per_all_assignments_f a,
		               per_periods_of_placement pp
		        WHERE  a.person_id = p.person_id
		               AND a.person_id = pp.person_id
		               AND a.person_id = x_requester_id
		               AND a.assignment_type = 'C'
                               AND a.primary_flag = 'Y' -- Added for Bug 16984978
		               AND p.npw_number IS NOT NULL
		               AND a.period_of_placement_date_start = pp.date_start
		               AND Trunc(SYSDATE) BETWEEN p.effective_start_date AND
		                                          p.effective_end_date
		               AND Trunc(SYSDATE) BETWEEN a.effective_start_date AND
		                                          a.effective_end_date
		               AND ( pp.actual_termination_date >= Trunc(SYSDATE)
		                      OR pp.actual_termination_date IS NULL )) hcerv,
		       hr_operating_units hru,
		       financials_system_parameters fsp
		   WHERE fsp.org_id =    hru.organization_id
		   AND  hru.set_of_books_id = hcerv.set_of_books_id
		   AND ROWNUM=1;
		EXCEPTION
			WHEN OTHERS THEN
		     x_ccid := null;
		END;

   if x_ccid is null then


  SELECT        min(hrecv.default_code_combination_id),min(hrecv.business_group_id),
                min(fsp.business_group_id)
  INTO          x_ccid,x_bg_id_hr,x_bg_id_fsp
  FROM          per_workforce_current_x hrecv,    --R12 CWK Enhancement

              --< Shared Proc FPJ Start >
                --financials_system_parameters fsp
                financials_system_params_all fsp
              --< Shared Proc FPJ End >
   ,  GL_SETS_OF_BOOKS emp_sob
   ,  GL_SETS_OF_BOOKS org_sob

  WHERE         hrecv.person_id = x_requester_id
  AND           hrecv.business_group_id = fsp.business_group_id
   AND  org_sob.set_of_books_id = fsp.set_of_books_id
   AND  emp_sob.set_of_books_id = hrecv.set_of_books_id
   AND  emp_sob.chart_of_accounts_id = org_sob.chart_of_accounts_id

              --< Shared Proc FPJ Start >
              -- NVL is required for the single-org instance case.
AND           NVL(fsp.org_id, -99) = NVL(l_expense_rules_org_id, -99);
              --< Shared Proc FPJ End >


  x_progress := 'PO_WF_PO_RULE_ACC.get_default_requester_acc: 03';
  if x_ccid is not null  THEN


     PO_WF_UTIL_PKG.SetItemAttrNumber (itemtype => itemtype,
                                  itemkey  => itemkey,
                                  aname    => 'DEFAULT_ACCT_ID',
                                  avalue   => x_ccid );

--<Bug2711577 fix  code change END>

     result := 'COMPLETE:SUCCESS';
  else
     result := 'COMPLETE:FAILURE';
  end if;

  ELSE

     PO_WF_UTIL_PKG.SetItemAttrNumber (itemtype => itemtype,
                                  itemkey  => itemkey,
                                  aname    => 'DEFAULT_ACCT_ID',
                                  avalue   => x_ccid );

--<Bug2711577 fix  code change END>

     result := 'COMPLETE:SUCCESS';



  END IF;

  RETURN;

EXCEPTION
  WHEN OTHERS THEN

  	wf_core.context('PO_WF_PO_RULE_ACC','get_default_requester_acc',x_progress);
     	result := 'COMPLETE:FAILURE';
  	RETURN;

END get_default_requester_acc;


PROCEDURE get_favorite_charge_acc (
	itemtype        in  varchar2,
	itemkey         in  varchar2,
	actid           in number,
	funcmode        in  varchar2,
	result          out NOCOPY varchar2  )
is
  x_progress            varchar2(100);
  x_user_id		NUMBER;
  x_resp_id		NUMBER;
  x_ccid			NUMBER;

BEGIN

  x_progress := 'PO_WF_PO_RULE_ACC.get_favorite_charge_acc: 01';

  IF (g_po_wf_debug = 'Y') THEN
	PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;

  if (funcmode <> wf_engine.eng_run) then
	result := wf_engine.eng_null;
	return;
  end if;

   -- Verify if the user has access to Favorite charge account function
  IF NOT FND_FUNCTION.TEST('POR_FAV_CHG_ACCT') THEN
    x_progress := 'PO_WF_PO_RULE_ACC.get_favorite_charge_acc: Favorite charge account functionality not provided';
    PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
    result := 'COMPLETE:FAILURE';  -- Bug 3626954 Return failure instead of success
    RETURN;
  END IF;

  x_progress := 'PO_WF_PO_RULE_ACC.get_favorite_charge_acc: 02';

  x_user_id := FND_GLOBAL.EMPLOYEE_ID;

  x_resp_id := FND_GLOBAL.RESP_ID;

  x_progress := 'PO_WF_PO_RULE_ACC. get_favorite_charge_acc: 03';

  Select CHARGE_ACCOUNT_ID
	 into x_ccid
  from 	 POR_FAV_CHARGE_ACCOUNTS
  where  EMPLOYEE_ID =  x_user_id and
	 RESPONSIBILITY_ID = x_resp_id and
	 DEFAULT_ACCOUNT = 'Y';

  x_progress := 'PO_WF_PO_RULE_ACC.get_favorite_charge_acc: 04';


  if x_ccid is not null  then
	PO_WF_UTIL_PKG.SetItemAttrNumber (itemtype => itemtype,
					  itemkey  => itemkey,
					  aname    => 'DEFAULT_ACCT_ID',
					  avalue   => x_ccid );
	result := 'COMPLETE:SUCCESS';
  else
	result := 'COMPLETE:FAILURE';
  end if;

RETURN;

EXCEPTION
WHEN OTHERS THEN
	wf_core.context('PO_WF_PO_RULE_ACC','get_favorite_charge_acc',x_progress);
	result := 'COMPLETE:FAILURE';
RETURN;

END get_favorite_charge_acc;


PROCEDURE if_enforce_expense_acc_rules(
	itemtype        in  varchar2,
	itemkey         in  varchar2,
	actid           in number,
	funcmode        in  varchar2,
	result          out NOCOPY varchar2  )
is
  l_progress		varchar2(100);
  l_options_value	VARCHAR2(30);

BEGIN
  l_progress := 'PO_WF_PO_RULE_ACC.if_enforce_expense_acc_rules: 01';

  fnd_profile.get('POR_REQ_ENFORCE_EXP_ACC_RULE', l_options_value);

  l_progress := 'PO_WF_PO_RULE_ACC.if_enforce_expense_acc_rules: 02';

  if l_options_value is not null then
  	result:='COMPLETE:'|| l_options_value;
  	return;
  else
  	result:='COMPLETE:'|| 'N';
  	return;
  end if;


EXCEPTION
 WHEN OTHERS THEN
    WF_CORE.context('PO_WF_PO_RULE_ACC','if_enforce_expense_acc_rules',  l_progress);
    result:='COMPLETE:'||'N';

END if_enforce_expense_acc_rules;


PROCEDURE if_rule_exist_for_all_segments (
	itemtype        in  varchar2,
	itemkey         in  varchar2,
	actid           in number,
	funcmode        in  varchar2,
	result          out NOCOPY varchar2    )

IS
  l_progress			varchar2(100);
  l_segments_number_sob		NUMBER :=0;
  l_get_result			varchar2(25) := NULL;
  l_segment_array     		FND_FLEX_EXT.SegmentArray;
  l_delimiter         		VARCHAR2(10);
  l_chart_of_accounts_id 	NUMBER;
  l_concat_segs       		VARCHAR2(2000);
  l_ccId 			NUMBER;

--< Shared Proc FPJ Start >
  l_expense_rules_org_id NUMBER;
--< Shared Proc FPJ End >

BEGIN

  l_progress := 'PO_WF_PO_RULE_ACC.IF_RULE_EXIST_FOR_ALL_SEGMENTS: 01';

  IF (g_po_wf_debug = 'Y') THEN
	PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
  END IF;

  if (funcmode <> wf_engine.eng_run) then
	result := wf_engine.eng_null;
	return;
  end if;

  l_progress := 'PO_WF_PO_RULE_ACC.IF_RULE_EXIST_FOR_ALL_SEGMENTS: 02';

--< Shared Proc FPJ Start >

  -- The Expense Account Rules are called from the PO AG Workflow
  -- twice -- once for POU and then second time for DOU. Therefore,
  -- all the queries in this package that assume the ORG_ID from
  -- the org context, needs to join explicitly to the ORG_ID given
  -- in the attribute EXPENSE_RULES_ORG_ID.
  --     This attribute is populated in the WF, before calling the
  -- Expense Account rules to either POU or DOU's org ID depending
  -- on which OU's accounts are being generated.
  --     For Req AG Workflow, the attribute EXPENSE_RULES_ORG_ID
  -- would not be present. In that case,
  -- the PO_WF_UTIL_PKG.GetItemAttrNumber() would return NULL.
  -- Then, we would populate it with the ORG_ID in the org context.

  l_expense_rules_org_id := PO_WF_UTIL_PKG.GetItemAttrNumber(
                                    itemtype => itemtype,
                                   	itemkey  => itemkey,
                            	 	aname    => 'EXPENSE_RULES_ORG_ID');

  -- If it is NULL and the org context's org_id is not null, then copy
  -- org_context's org_id.
  IF  l_expense_rules_org_id IS NULL THEN
    l_expense_rules_org_id := po_moac_utils_pvt.get_current_org_id; --<R12 MOAC>
  END IF;

  IF (g_po_wf_debug = 'Y') THEN
	PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,
               'PO_WF_PO_RULE_ACC.if_rule_exist_for_all_segments '||
               'l_expense_rules_org_id='||l_expense_rules_org_id);
  END IF;

--< Shared Proc FPJ End >

  -- create table  l_segment_table for expense account rule
  get_segment_records(itemtype, itemkey, l_get_result);

  IF (g_po_wf_debug = 'Y') THEN
	PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,
               'PO_WF_PO_RULE_ACC.if_rule_exist_for_all_segments '||
               'get_segment_records->result='||l_get_result);
  END IF;


  l_progress := 'PO_WF_PO_RULE_ACC.IF_RULE_EXIST_FOR_ALL_SEGMENTS: 03';

  if (l_get_result = 'fail') then
	result := 'COMPLETE:'||'N';
	l_counter := -1;
	return;
  end if;

  l_progress := 'PO_WF_PO_RULE_ACC.IF_RULE_EXIST_FOR_ALL_SEGMENTS: 04';

  -- set l_segments_number_sob , the total number of account segments for
  -- the current set of books, by any query or api from GL, sent email to
  -- ask Gursat.Olgun for the query or api.

  select count(*)
  into   l_segments_number_sob
  from   FND_ID_FLEX_SEGMENTS fs,

       --< Shared Proc FPJ Start >
         --financials_system_parameters fsp,
         financials_system_params_all fsp,
       --< Shared Proc FPJ End >

         gl_sets_of_books gls
  where  fsp.set_of_books_id = gls.set_of_books_id and
         fs.id_flex_num = gls.chart_of_accounts_id and
         fs.id_flex_code = 'GL#' and
         fs.application_id = 101 AND

       --< Shared Proc FPJ Start >
       -- NVL is required for the single-org instance case.
         NVL(fsp.org_id, -99) = NVL(l_expense_rules_org_id, -99);
       --< Shared Proc FPJ End >

  if ( l_segment_table.count = l_segments_number_sob) THEN

      l_progress := 'PO_WF_PO_RULE_ACC.IF_RULE_EXIST_FOR_ALL_SEGMENTS: 05';

      -- get concatenated account segments
      FOR i IN 0..l_segment_table.count-1 LOOP
	    wf_engine.SetItemAttrText(itemtype, itemkey,
				      'FND_FLEX_SEGMENT' || TO_CHAR(i+1),
				      l_segment_table(i).segment_value);
	    l_segment_array(i+1) := l_segment_table(i).segment_value;
      END LOOP;

      l_progress := 'PO_WF_PO_RULE_ACC.IF_RULE_EXIST_FOR_ALL_SEGMENTS: 06';

      -- get chart_of_accounts_id

      select gls.chart_of_accounts_id
      into   l_chart_of_accounts_id

    --< Shared Proc FPJ Start >
      --from   financials_system_parameters fsp,
      FROM   financials_system_params_all fsp,
    --< Shared Proc FPJ End >

             gl_sets_of_books gls
      where  fsp.set_of_books_id = gls.set_of_books_id AND

           --< Shared Proc FPJ Start >
             -- NVL is required for the single-org instance case.
             NVL(fsp.org_id, -99) = NVL(l_expense_rules_org_id, -99);
           --< Shared Proc FPJ End >


      l_progress := 'PO_WF_PO_RULE_ACC.IF_RULE_EXIST_FOR_ALL_SEGMENTS: 07';

      --
      -- Use the FND_FLEX_EXT pacakge to concatenate the segments
      --
      l_delimiter := fnd_flex_ext.get_delimiter('SQLGL', 'GL#', l_chart_of_accounts_id);

      l_progress := 'PO_WF_PO_RULE_ACC.IF_RULE_EXIST_FOR_ALL_SEGMENTS: 08';

      IF (l_delimiter is not null) THEN

       	l_concat_segs := fnd_flex_ext.concatenate_segments(l_segment_table.count,l_segment_array, l_delimiter);

  	l_progress := 'PO_WF_PO_RULE_ACC.IF_RULE_EXIST_FOR_ALL_SEGMENTS: 09';

      	l_ccId := fnd_flex_ext.get_ccid('SQLGL','GL#',l_chart_of_accounts_id, to_char(sysdate, 'YYYY/MM/DD HH24:MI:SS'),l_concat_segs);

  	l_progress := 'PO_WF_PO_RULE_ACC.IF_RULE_EXIST_FOR_ALL_SEGMENTS: 10';

       	if l_ccId is not null  then
     		PO_WF_UTIL_PKG.SetItemAttrNumber (
				itemtype => itemtype,
                               	itemkey  => itemkey,
                                aname    => 'DEFAULT_ACCT_ID',
                                avalue   => l_ccId );

		result := 'COMPLETE:'||'Y';

     	else
		result := 'COMPLETE:'||'N';
	end if;

      ELSE
  	l_progress := 'PO_WF_PO_RULE_ACC.IF_RULE_EXIST_FOR_ALL_SEGMENTS: 11';

	result := 'COMPLETE:'||'N';
      END IF;

  else
      l_progress := 'PO_WF_PO_RULE_ACC.IF_RULE_EXIST_FOR_ALL_SEGMENTS: 12';

      result := 'COMPLETE:'||'N';

  end if;

  IF (g_po_wf_debug = 'Y') THEN
	PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,
               'PO_WF_PO_RULE_ACC.if_rule_exist_for_all_segments '||
               'result='||result);
  END IF;

  l_segment_table.DELETE;
  l_counter := -1;
  return;

EXCEPTION
  WHEN OTHERS THEN

    IF (g_po_wf_debug = 'Y') THEN
	  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,
               'PO_WF_PO_RULE_ACC.if_rule_exist_for_all_segments '||
               'EXCEPTION at '|| l_progress);
    END IF;

    wf_core.context('PO_WF_PO_RULE_ACC','IF_RULE_EXIST_FOR_ALL_SEGMENTS',
                    l_progress);
  	result := 'COMPLETE:'||'N';
  	RETURN;
END IF_RULE_EXIST_FOR_ALL_SEGMENTS;

PROCEDURE get_category_account_segment(	itemtype        in  varchar2,
                                      	itemkey         in  varchar2,
	                              	actid           in number,
                                      	funcmode        in  varchar2,
                                      	result          out NOCOPY varchar2    )
IS
	x_progress              varchar2(100);
	x_segment_name		varchar2(30);
	x_segment_value		varchar2(25);
	l_get_result		varchar2(25) := NULL;

BEGIN

  x_progress := 'PO_WF_PO_RULE_ACC.get_category_account_segment: 01';
  IF (g_po_wf_debug = 'Y') THEN
     PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  END IF;

  -- Do nothing in cancel or timeout mode
  --
  if (funcmode <> wf_engine.eng_run) then
      result := wf_engine.eng_null;
      return;
  end if;

  if (l_counter = -1) then
     get_segment_records(itemtype, itemkey, l_get_result);
     if (l_get_result = 'fail') then
        result := 'COMPLETE:FAILURE';
	return;
     end if;
  end if;

  if (l_counter >= l_segment_table.count) THEN
     result := 'COMPLETE:FAILURE';
     l_segment_table.DELETE;
     l_counter := -1;
     return;

  else
     x_segment_name  := l_segment_table(l_counter).segment_name;
     x_segment_value := l_segment_table(l_counter).segment_value;

     PO_WF_UTIL_PKG.SetItemAttrText ( itemtype => itemtype,
                               	 itemkey  => itemkey,
                               	 aname    => 'SEGMENT',
                                 avalue   => x_segment_name);

     PO_WF_UTIL_PKG.SetItemAttrText ( itemtype => itemtype,
                                 itemkey  => itemkey,
                                 aname    => 'VALUE',
                                 avalue   => x_segment_value);

     l_counter := l_counter + 1;
     result := 'COMPLETE:SUCCESS';
  end if;
  RETURN;

EXCEPTION
  WHEN OTHERS THEN
	wf_core.context('PO_WF_PO_RULE_ACC','get_category_account_segment',x_progress);
     	result := 'COMPLETE:FAILURE';
  	RETURN;

END get_category_account_segment;



PROCEDURE get_segment_records ( itemtype        in  	varchar2,
                                itemkey         in  	varchar2,
				resultout 	out NOCOPY 	varchar2)
is

  x_progress    	varchar2(100);
  l_index		NUMBER	:= 0;
  x_category_id  	NUMBER;

  type t_segment_Cursor is ref cursor return t_segment_record;
  c_seg t_segment_Cursor;

--< Shared Proc FPJ Start >
    l_expense_rules_org_id NUMBER;
--< Shared Proc FPJ End >

BEGIN
     x_progress := 'PO_WF_PO_RULE_ACC.get_segment_records: 01';
     x_category_id := PO_WF_UTIL_PKG.GetItemAttrText ( itemtype => itemtype,
                                   	          itemkey  => itemkey,
                            	 	       	  aname    => 'CATEGORY_ID');

  --< Shared Proc FPJ Start >
  l_expense_rules_org_id := PO_WF_UTIL_PKG.GetItemAttrNumber(
                                    itemtype => itemtype,
                                   	itemkey  => itemkey,
                            	 	aname    => 'EXPENSE_RULES_ORG_ID');

  -- If it is NULL and the org context's org_id is not null, then copy
  -- org_context's org_id.
  IF  l_expense_rules_org_id IS NULL  THEN
    l_expense_rules_org_id := po_moac_utils_pvt.get_current_org_id; --<R12 MOAC>
  END IF;

  IF (g_po_wf_debug = 'Y') THEN
	PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,
               'PO_WF_PO_RULE_ACC.get_segment_records '||
               'l_expense_rules_org_id='||l_expense_rules_org_id);
  END IF;

  --< Shared Proc FPJ End >


     open c_seg for

  --< Shared Proc FPJ Start >
  	--SELECT	PREA.segment_name, PREA.segment_value, FFSV.segment_num
  	SELECT	FFSV.segment_name, PREA.segment_value, FFSV.segment_num
  	--FROM	PO_RULE_EXPENSE_ACCOUNTS_V PREA,
  	FROM	PO_RULE_EXPENSE_ACCOUNTS PREA,
  --< Shared Proc FPJ End >

		fnd_id_flex_segments_vl FFSV,

      --< Shared Proc FPJ Start >
        --financials_system_parameters fsp,
        financials_system_params_all fsp,
            MTL_CATEGORIES_KFV MCK,
            MTL_CATEGORY_SETS MCS,
            MTL_DEFAULT_CATEGORY_SETS MDCS,
            MTL_CATEGORIES MC,
      --< Shared Proc FPJ End >

       		gl_sets_of_books gls

  	WHERE	PREA.rule_type = 'ITEM CATEGORY'
  	AND	PREA.RULE_VALUE_ID = x_category_id

    --< Shared Proc FPJ Start >
	--AND	PREA.segment_name is NOT NULL
    AND	FFSV.segment_name is NOT NULL
    --< Shared Proc FPJ Start >

	AND	PREA.segment_value is NOT NULL
        AND     PREA.segment_num = FFSV.application_column_name
        AND     FFSV.application_id = 101
        and     FFSV.id_flex_code = 'GL#'
        and     FFSV.id_flex_num = gls.chart_of_accounts_id
        and     fsp.set_of_books_id = gls.set_of_books_id

      --< Shared Proc FPJ Start >
      -- NVL is required for the single-org instance case.
        AND     NVL(FSP.org_id, -99) = NVL(l_expense_rules_org_id, -99)
        AND     NVL(PREA.org_id, -99) = NVL(l_expense_rules_org_id, -99)

        AND MCK.ENABLED_FLAG = 'Y'
        AND SYSDATE BETWEEN NVL(MCK.START_DATE_ACTIVE,SYSDATE)
        AND NVL(MCK.END_DATE_ACTIVE,SYSDATE)
        AND MCS.CATEGORY_SET_id=mdcs.category_set_id
        AND MDCS.FUNCTIONAL_AREA_ID=2
        AND MCK.STRUCTURE_ID=MCS.STRUCTURE_ID
        AND NVL(mck.DISABLE_DATE,SYSDATE + 1) > SYSDATE
        AND (MCS.VALIDATE_FLAG='Y'
            AND mck.CATEGORY_ID IN
               (SELECT
                    MCSV.CATEGORY_ID
                FROM
                    MTL_CATEGORY_SET_VALID_CATS MCSV
                WHERE MCSV.CATEGORY_SET_ID=MCS.CATEGORY_SET_ID)
            OR MCS.VALIDATE_FLAG <> 'Y')
        AND MCK.CATEGORY_ID = MC.CATEGORY_ID
        AND PREA.RULE_VALUE_ID = MCK.CATEGORY_ID
      --< Shared Proc FPJ End >

	order by FFSV.segment_num asc;

  	loop
     		fetch c_seg into l_segment_table(l_index);
    		exit when c_seg%NOTFOUND;
    		l_index := l_index + 1;
  	end loop;
     close c_seg;

     if (l_index = 0) then
     	resultout := 'fail';
  	RETURN;
     else
        l_counter := 0;
     	resultout := 'ok';
    end if;

EXCEPTION
  WHEN OTHERS THEN
	wf_core.context('PO_WF_PO_RULE_ACC','get_segment_records',x_progress);
     	resultout := 'fail';
  	RETURN;

END get_segment_records;

--< Shared Proc FPJ Start >

---------------------------------------------------------------------------
--Start of Comments
--Name: set_expense_rules_org_as_POU
--Pre-reqs:
--  None.
--Modifies:
--  Item Attribute: EXPENSE_RULES_ORG_ID
--Locks:
--  None.
--Function:
--  Gets the value of PURCHASING_OU_ID and puts in EXPENSE_RULES_ORG_ID
--Parameters:
--IN:
--  Standard workflow function parameters
--OUT:
--  Standard workflow function result parameter
--Testing:
--End of Comments
---------------------------------------------------------------------------
PROCEDURE set_expense_rules_org_as_POU(itemtype IN  VARCHAR2,
                                       itemkey  IN  VARCHAR2,
                                       actid    IN NUMBER,
                                       funcmode IN  VARCHAR2,
                                       result   OUT NOCOPY VARCHAR2)
IS
  x_progress WF_ITEM_ACTIVITY_STATUSES.error_stack%TYPE; -- VARCHAR2(4000)
  l_purchasing_ou_id NUMBER;
BEGIN
  -- Do nothing in cancel or timeout mode
  IF (funcmode <> WF_ENGINE.eng_run) THEN
    result := WF_ENGINE.eng_null;
    RETURN;
  END IF;

  l_purchasing_ou_id := PO_WF_UTIL_PKG.GetItemAttrNumber(
                                    itemtype => itemtype,
                                   	itemkey  => itemkey,
                            	 	aname    => 'PURCHASING_OU_ID');

  PO_WF_UTIL_PKG.SetItemAttrNumber( itemtype => itemtype,
                                    itemkey  => itemkey,
                                    aname    => 'EXPENSE_RULES_ORG_ID',
                                    avalue   => l_purchasing_ou_id);
EXCEPTION
  WHEN OTHERS THEN
    WF_CORE.context('PO_WF_PO_RULE_ACC',  'set_expense_rules_org_as_POU',
                    x_progress);
    RAISE;
END set_expense_rules_org_as_POU;

---------------------------------------------------------------------------
--Start of Comments
--Name: set_expense_rules_org_as_DOU
--Pre-reqs:
--  None.
--Modifies:
--  Item Attribute: EXPENSE_RULES_ORG_ID
--Locks:
--  None.
--Function:
--  Gets the value of SHIP_TO_OU_ID and puts in EXPENSE_RULES_ORG_ID
--Parameters:
--IN:
--  Standard workflow function parameters
--OUT:
--  Standard workflow function result parameter
--Testing:
--End of Comments
---------------------------------------------------------------------------
PROCEDURE set_expense_rules_org_as_DOU(itemtype IN  VARCHAR2,
                                       itemkey  IN  VARCHAR2,
                                       actid    IN NUMBER,
                                       funcmode IN  VARCHAR2,
                                       result   OUT NOCOPY VARCHAR2)
IS
  x_progress WF_ITEM_ACTIVITY_STATUSES.error_stack%TYPE; -- VARCHAR2(4000)
  l_destination_ou_id NUMBER;
BEGIN
  -- Do nothing in cancel or timeout mode
  IF (funcmode <> WF_ENGINE.eng_run) THEN
    result := WF_ENGINE.eng_null;
    RETURN;
  END IF;

  l_destination_ou_id := PO_WF_UTIL_PKG.GetItemAttrNumber(
                                    itemtype => itemtype,
                                   	itemkey  => itemkey,
                            	 	aname    => 'SHIP_TO_OU_ID');

  PO_WF_UTIL_PKG.SetItemAttrNumber( itemtype => itemtype,
                                    itemkey  => itemkey,
                                    aname    => 'EXPENSE_RULES_ORG_ID',
                                    avalue   => l_destination_ou_id);
EXCEPTION
  WHEN OTHERS THEN
    WF_CORE.context('PO_WF_PO_RULE_ACC',  'set_expense_rules_org_as_DOU',
                    x_progress);
    RAISE;
END set_expense_rules_org_as_DOU;

--< Shared Proc FPJ End >


PROCEDURE IS_OVERRIDE_CHARGE_ACCOUNT ( itemtype        in  varchar2,
                                               itemkey         in  varchar2,
                                               actid           in  NUMBER,
			                             funcmode		     in		varchar2,
                                               result          out NOCOPY VARCHAR2 )

IS
override_charge_account   varchar2(1);
x_progress          varchar2(100);

 BEGIN

  x_progress := 'PO_WF_PO_RULE_ACC.IS_OVERRIDE_CHARGE_ACCOUNT : 01';

    IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
   END IF;


  -- Do nothing in cancel or timeout mode
  --
  if (funcmode <> wf_engine.eng_run) then

      result := wf_engine.eng_null;
      return;

  end if;
  x_progress := 'PO_WF_PO_RULE_ACC.IS_OVERRIDE_CHARGE_ACCOUNT : 02';

  IF (g_po_wf_debug = 'Y') THEN
     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
   END IF;


  override_charge_account := FND_PROFILE.VALUE('POR_OVERRIDE_CHARGE_ACCOUNT');

  x_progress := 'PO_WF_PO_RULE_ACC.IS_OVERRIDE_CHARGE_ACCOUNT : 03 ' ;

  -- IF (g_po_wf_debug = 'Y') THEN
  --   /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
  --   /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,override_charge_account);
  -- END IF;



  if  override_charge_account = 'Y' then
  result := 'COMPLETE:Y';
  ELSE
  result := 'COMPLETE:N';
  end if;

  return;

  EXCEPTION
  WHEN OTHERS THEN
      wf_core.context('PO_WF_PO_RULE_ACC','IS_OVERRIDE_CHARGE_ACCOUNT',x_progress);
       raise;
  END IS_OVERRIDE_CHARGE_ACCOUNT ;

--<<START: Bug#18040878>>
---------------------------------------------------------------------------
--Start of Comments
--Name: copy_from_combination
-- Procedure to copy values from the code combination id
-- generated from requestor account
-- This procedure will mimic the code
-- of FND_FLEX copy_from_combination
-- except the validation part.
--Pre-reqs:
--  None.
--Modifies:
--  Item Attribute: DEFAULT_ACCT_ID
--Locks:
--  None.
--Parameters:
--IN:
--  Standard workflow function parameters
--OUT:
--  Standard workflow function result parameter
--Testing:
--End of Comments
---------------------------------------------------------------------------
PROCEDURE copy_from_combination(itemtype  IN VARCHAR2,
                                itemkey   IN VARCHAR2,
                                actid     IN NUMBER,
                                funcmode  IN VARCHAR2,
                                result    OUT NOCOPY VARCHAR2)
IS

l_progress             wf_item_activity_statuses.error_stack%TYPE;
l_ccid                 po_distributions_all.code_combination_id%TYPE;
l_segments_number_sob  NUMBER :=0;
l_expense_rules_org_id NUMBER;
l_stmt                 VARCHAR2(4000);
l_segment_tbl         PO_TBL_VARCHAR30;
l_row_count           NUMBER;

BEGIN
  l_progress := 'PO_WF_PO_RULE_ACC.copy_from_combination: 01 ';

  IF (g_po_wf_debug = 'Y') THEN
    PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
  END IF;

  IF (funcmode <> wf_engine.eng_run) then
    result := wf_engine.eng_null;
    RETURN;
  END IF;

  l_progress := 'PO_WF_PO_RULE_ACC.copy_from_combination: 02 ';

  l_expense_rules_org_id := PO_WF_UTIL_PKG.GetItemAttrNumber(
                                         itemtype => itemtype,
                                  	 itemkey  => itemkey,
                           	 	  aname    => 'EXPENSE_RULES_ORG_ID');

  -- If it is NULL and the org context's org_id is not null, then copy
  -- org_context's org_id.
  IF l_expense_rules_org_id IS NULL THEN
    l_expense_rules_org_id := po_moac_utils_pvt.get_current_org_id; --<R12 MOAC>
  END IF;

  IF (g_po_wf_debug = 'Y') THEN
	PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress||
	  ' Expense Rule Org Id : '||l_expense_rules_org_id);
  END IF;

  l_progress := 'PO_WF_PO_RULE_ACC.copy_from_combination: 03 ';

  SELECT count(*)
  INTO   l_segments_number_sob
  FROM   FND_ID_FLEX_SEGMENTS fs,
         financials_system_params_all fsp,
         gl_sets_of_books gls
  WHERE  fsp.set_of_books_id = gls.set_of_books_id
    AND  fs.id_flex_num = gls.chart_of_accounts_id
    AND  fs.id_flex_code = 'GL#'
    AND  fs.application_id = 101
    AND  NVL(fsp.org_id, -99) = NVL(l_expense_rules_org_id, -99);

  IF (g_po_wf_debug = 'Y') THEN
	PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress||
	  ' l_segments_number_sob: '||l_segments_number_sob);
  END IF;

  l_progress := 'PO_WF_PO_RULE_ACC.copy_from_combination: 04 ';

  l_ccid := PO_WF_UTIL_PKG.GetItemAttrNumber(
                                  itemtype => itemtype,
                               	  itemkey  => itemkey,
                           	  aname    => 'DEFAULT_ACCT_ID');

  IF (g_po_wf_debug = 'Y') THEN
	PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress||
	  ' l_ccid: '||l_ccid);
  END IF;

  l_stmt := 'select segment_value from ( select decode(d.row_num';

  FOR i IN 1.. l_segments_number_sob
  LOOP
    l_stmt := l_stmt||','||i||',segment'||i;
  END LOOP;

  l_row_count := l_segments_number_sob +1;

  l_stmt := l_stmt||') segment_value from gl_code_combinations,'||
            '(select rownum row_num from gl_code_combinations where rownum < '||
	    l_row_count||') d '||'where code_combination_id ='||l_ccid||')';

  EXECUTE IMMEDIATE l_stmt BULK COLLECT INTO l_segment_tbl;

  l_progress := 'PO_WF_PO_RULE_ACC.copy_from_combination: 05 ';

  FOR i IN 1..l_segment_tbl.COUNT
  LOOP

    wf_engine.SetItemAttrText(itemtype, itemkey,
                              'FND_FLEX_SEGMENT' || TO_CHAR(i),
     		              l_segment_tbl(i));

    IF (g_po_wf_debug = 'Y') THEN
      PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress||
	'Setting the Value for segment '||TO_CHAR(i)||': '||l_segment_tbl(i));
    END IF;

  END LOOP;

  RETURN;

EXCEPTION
  WHEN OTHERS THEN
      wf_core.context('PO_WF_PO_RULE_ACC','copy_from_combination',l_progress);
       raise;
  END copy_from_combination;
--<<END: Bug#18040878>>

END PO_WF_PO_RULE_ACC;

/
