--------------------------------------------------------
--  DDL for Package Body PA_WF_FB_SAMPLE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_WF_FB_SAMPLE_PKG" 
/* $Header: PAXTMPFB.pls 120.3 2005/08/08 12:24:54 sbharath ship $ */
 AS

 PROCEDURE pa_wf_sample_sql_fn
	(	p_itemtype	IN  VARCHAR2,
		p_itemkey	IN  VARCHAR2,
		p_actid		IN  NUMBER,
		p_funcmode	IN  VARCHAR2,
		x_result	OUT NOCOPY VARCHAR2)
AS

l_project_type		pa_project_types_all.project_type%TYPE;
l_project_number	pa_projects_all.segment1%TYPE;
l_expenditure_org_id	hr_organization_units.organization_id%TYPE;
l_project_org_id	hr_organization_units.organization_id%TYPE;
l_acc_org_id		hr_organization_units.organization_id%TYPE;
l_org_map		pa_lookups.meaning%TYPE;
l_expenditure_type	pa_expenditure_types.expenditure_type%TYPE;
l_segment_value		gl_code_combinations.segment1%TYPE;

BEGIN

------------------------------------------------------------------------
-- This is a sample function that shows how the SQL statement of
-- autoaccounting can be implemented using Oracle Workflow. Assume
-- this mimicks a SQL statement in Autoaccounting which takes four
-- parameters: Project number, Expenditure Type, Expenditure
-- Organization id and Project Organization id
--
-- Assume that rules for obtaining the segment are as follows: If the
-- first two characters of the project number are 'AA' then the
-- project org should be used to get the segment otherwise the
-- expenditure org should be used to get the segment. Also assume that
-- the segment value is obtained from a lookup table, say PA_LOOKUPS
-- using the organization id and the expenditure type.
--
-- The equivalent SQL function in autoaccounting would have had the
-- Project number, Expenditure Organization Id, Project Organization
-- Id and Expenditure type as parameters. In the Workflow
-- implementation, these values have to be obtained from the
-- attributes of the Workflow item. After the values are obtained, the
-- required steps are performed to determine the final segment value.
-- An attribute in the Workflow item has to be defined to hold the
-- value of the final segment value. This function sets the value of
-- that attribute and the subsequent Workflow "Assign value to
-- segment" assigns the value of this attribute to the segment.
--
-- The return type of this function is "Flexfield Result" for which
-- the valid values are 'SUCCESS' and 'FAILURE'. The function must
-- return one of these values
--
------------------------------------------------------------------------

-------------------------------------------------------------
-- First retrieve the values of these attributes into local
-- variables.
-------------------------------------------------------------

  l_expenditure_org_id	:= wf_engine.GetItemAttrNumber
			( itemtype => p_itemtype,
			  itemkey  => p_itemkey,
			  aname	   => 'EXPENDITURE_ORGANIZATION_ID');

  l_project_org_id	:= wf_engine.GetItemAttrNumber
			( itemtype => p_itemtype,
			  itemkey  => p_itemkey,
			  aname	   => 'PROJECT_ORGANIZATION_ID');

  l_project_number	:= wf_engine.GetItemAttrText
			( itemtype => p_itemtype,
			  itemkey  => p_itemkey,
			  aname	   => 'PROJECT_NUMBER');

  l_expenditure_type	:= wf_engine.GetItemAttrText
			( itemtype => p_itemtype,
			  itemkey  => p_itemkey,
			  aname	   => 'EXPENDITURE_TYPE');

---------------------------------------------------
-- Now start determining the value of the segment
---------------------------------------------------

-- First determine which of the organization ids are to be used The assumption
-- is that if the first two characters of the project number are 'AA',
-- then the Project Organization Id is to be used for account
-- generation. Otherwise, the Expenditure Organization Id is used for
-- account generation.

  IF substr(l_project_number, 1, 2) = 'AA'
  THEN
	l_acc_org_id	:=	l_project_org_id;
  ELSE
	l_acc_org_id	:=	l_expenditure_org_id;
  END IF;

-- Assume that the organization id is mapped to another field from a lookup
-- table. PA_LOOKUPS has been used in this example. Any table could
-- function as a lookup. Please note that the LOOKUP_TYPE used here
-- may not actually exist and is just used for illustration

  BEGIN

    SELECT  meaning
      INTO  l_org_map
      FROM  pa_lookups
     WHERE  lookup_type = 'ORG_TO_ACC'
       AND  lookup_code = l_acc_org_id;

  EXCEPTION

    WHEN no_data_found
    THEN
    -- Set appropriate debugging information for workflow

        wf_core.context( pkg_name	=> 'PA_WF_FB_SAMPLE_PKG',
			 proc_name	=> 'PA_WF_SAMPLE_SQL_FN',
			 arg1		=>  l_project_number,
			 arg2		=>  l_project_org_id,
			 arg3		=>  l_expenditure_org_id,
			 arg4		=>  l_expenditure_type,
			 arg5		=>  null);

-- Error requires an error message to be set so that it can be
-- displayed on the form. The error message name is defined in
-- Applications and the name is set here. The form should read this
-- error message and decode it to get the original message text.

      wf_engine.SetItemAttrText
		( itemtype=> p_itemtype,
		  itemkey => p_itemkey,
		  aname	  => 'ERROR_MESSAGE',
		  avalue  => 'SUP_INV_ACC_ORG_ID_LOOKUP FAIL');

    -- Return a failure so that the abort generation End function is called

	x_result := 'COMPLETE:FAILURE';
	RETURN;
  END;

-- Assume that the final segment value is again derived from
-- PA_LOOKUPS and is a combination of the variable l_org_map
-- determined above and the Expenditure type

 BEGIN

    SELECT meaning
      INTO l_segment_value
      FROM pa_lookups
     WHERE lookup_type = 'ORG_EXP_TYPE'
       AND lookup_code = l_org_map || l_expenditure_type;

 EXCEPTION

   WHEN no_data_found
    THEN

    -- Set appropriate debugging information

        wf_core.context( pkg_name	=> 'PA_WF_FB_SAMPLE_PKG',
			 proc_name	=> 'PA_WF_SAMPLE_SQL_FN',
			 arg1		=>  l_project_number,
			 arg2		=>  l_project_org_id,
			 arg3		=>  l_expenditure_org_id,
			 arg4		=>  l_expenditure_type,
			 arg5		=>  null);

    -- Error requires an error message to be set so that it can be displayed
    -- on the form

      wf_engine.SetItemAttrText
		( itemtype=> p_itemtype,
		  itemkey=> p_itemkey,
		  aname	=> 'ERROR_MSG',
		  avalue=> 'Org and Expenditure type lookup failed ' ||
			   'during account generation');
    -- Return a failure so that the abort generation End function is called

	x_result := 'COMPLETE:FAILURE';
	RETURN;

 END;


-- If control passes to this point, the segment value has been
-- determined correctly. Use this newly determined value to set the
-- value of the corresponding attribute in Workflow so that it is
-- available to subsequent functions
-- For the purpose of the sample and to avoid defining an extra item
-- attribute that will not be used later, the item attribute used is
-- the same that is used in the lookup set value (LOOKUP_SET_VALUE).
-- It is desirable that you define and use your own item attributes
-- e.g. SAMPLE_SEGMENT_1.

      wf_engine.SetItemAttrText  ( itemtype	=> p_itemtype,
				   itemkey 	=> p_itemkey,
				   aname	=> 'LOOKUP_SET_VALUE',
				   avalue	=> l_segment_value);

-- Return a success since the segment value has been determined
-- correctly. 'SUCCESS' is the expected result since the result of the
-- process has been defined as Flexfield Result

  x_result := 'COMPLETE:SUCCESS';
  RETURN;

EXCEPTION

     WHEN OTHERS
       THEN

  -- Record error using generic error message routine for debugging and
  -- raise it

        wf_core.context( pkg_name	=> 'PA_WF_FB_SAMPLE_PKG',
			 proc_name	=> 'PA_WF_SAMPLE_SQL_FN',
			 arg1		=>  l_project_number,
			 arg2		=>  l_project_org_id,
			 arg3		=>  l_expenditure_org_id,
			 arg4		=>  l_expenditure_type,
			 arg5		=>  null);

        raise;

 END pa_wf_sample_sql_fn ;

--PA_TEST_AP_INV_ACCOUNT:
--
-- This procedure is used to test your workflow for the supplier
-- invoice charge account. After you design your workflow and save it
-- in the database, you can modify this procedure to test it.  Before
-- beginning testing, make sure that the Account Generator window
-- shows the correct process that you want to run for your account
-- generation for your set of books.
--
-- Log into SQL*Plus into the database where you want to test your
-- workflow. Make sure that the dbms_application_info.set_client_info
-- package is run to select the correct organization id. Modify this
-- procedure or a copy of it giving values for each of the parameters
-- that will be used in account generation. The Project Id parameter
-- is mandatory. Replace the values below with your values for Project
-- Id, Task Id, Expenditure Type, etc. for the transaction for which
-- you want to test account generation. Also remember to "set
-- serveroutput on" before testing as the results of the Workflow are
-- displayed using dbms_output statements.
--
-- A typical test would be as follows:
--
-- SQL> set serveroutput on
-- SQL> begin
-- 2     pa_wf_fb_sample_pkg.pa_test_ap_inv_account;
-- 3    end;
-- 4    /
--
-- Alternatively, you can modify this procedure so that the parameters
-- that are used to vary the account are input to the procedure so
-- that you can run the procedure by passing the parameters instead of
-- modifying and recompiling each time
--

 PROCEDURE pa_test_ap_inv_account
 IS
 p_return_ccid		NUMBER;
 p_concat_segs		VARCHAR2(300);
 p_concat_ids		VARCHAR2(300);
 p_concat_descrs	VARCHAR2(300);
 p_errmsg		VARCHAR2(1300);
 p_ret_value		BOOLEAN;
 x_ret_value_s		VARCHAR2(20);

 BEGIN

 -- Set the profile option so that data is not purged from
 -- the workflow tables

 fnd_profile.put('ACCOUNT_GENERATOR:PURGE_DATA','N');
 p_ret_value := pa_acc_gen_wf_pkg.ap_inv_generate_account (
 	p_project_id			=> 1000,
 	p_task_id			=> 1000,
 	p_expenditure_type		=> 'XXXXXX',
 	p_vendor_id 			=> 1000,
 	p_expenditure_organization_id	=> 1000,
 	p_expenditure_item_date 	=> to_date('01/01/1998','MM/DD/YYYY'),
 	p_billable_flag			=> 'Y',
 	p_chart_of_Accounts_id		=> 101,
        p_accounting_date               => to_date('01/01/1998','MM/DD/YYYY'),
 	p_attribute_category		=> null,
 	p_attribute1			=> null,
 	p_attribute2			=> null,
 	p_attribute3			=> null,
 	p_attribute4			=> null,
 	p_attribute5			=> null,
 	p_attribute6			=> null,
 	p_attribute7			=> null,
 	p_attribute8			=> null,
 	p_attribute9			=> null,
 	p_attribute10			=> null,
 	p_attribute11			=> null,
 	p_attribute12			=> null,
 	p_attribute13			=> null,
 	p_attribute14			=> null,
 	p_attribute15			=> null,
 	p_dist_attribute_category	=> null,
 	p_dist_attribute1		=> null,
 	p_dist_attribute2		=> null,
 	p_dist_attribute3		=> null,
 	p_dist_attribute4		=> null,
 	p_dist_attribute5		=> null,
 	p_dist_attribute6		=> null,
 	p_dist_attribute7		=> null,
 	p_dist_attribute8		=> null,
 	p_dist_attribute9		=> null,
 	p_dist_attribute10		=> null,
 	p_dist_attribute11		=> null,
 	p_dist_attribute12		=> null,
 	p_dist_attribute13		=> null,
 	p_dist_attribute14		=> null,
 	p_dist_attribute15		=> null,
 	x_return_ccid			=> p_return_ccid,
 	x_concat_segs 			=> p_concat_segs,
 	x_concat_ids		 	=> p_concat_ids,
 	x_concat_descrs	 		=> p_concat_descrs,
 	x_error_message		 	=> p_errmsg);

 -- Check the return value after calling

/*
   In actual environment, for debugging, please put set serveroutput on
   and uncomment the following dbms_output statements.
 */

 IF p_ret_value = True
 THEN
  	x_ret_value_s := 'True';
/* 	dbms_output.put_line('Function was successful'); */
 ELSE
  	x_ret_value_s := 'False';
/* 	dbms_output.put_line('Function was not successful'); */
 END IF;

/*  dbms_output.put_line('Return Value	=' || x_ret_value_s);   */
/*  dbms_output.put_line('Dervied CCID	=' || p_return_ccid);   */
/*  dbms_output.put_line('Segments		=' || p_concat_segs);   */
/*  dbms_output.put_line('Segment ids	=' || p_concat_ids);    */
/*  dbms_output.put_line('Description	=' || p_concat_descrs); */
/*  dbms_output.put_line ('Error message   =' || p_errmsg );   */

 END;

END pa_wf_fb_sample_pkg;

/
