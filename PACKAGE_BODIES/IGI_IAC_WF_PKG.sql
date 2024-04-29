--------------------------------------------------------
--  DDL for Package Body IGI_IAC_WF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGI_IAC_WF_PKG" AS
/* $Header: igiiawfb.pls 120.5.12000000.1 2007/08/01 16:19:43 npandya ship $ */

  --===========================FND_LOG.START=====================================

  g_state_level NUMBER	     :=	FND_LOG.LEVEL_STATEMENT;
  g_proc_level  NUMBER	     :=	FND_LOG.LEVEL_PROCEDURE;
  g_event_level NUMBER	     :=	FND_LOG.LEVEL_EVENT;
  g_excep_level NUMBER	     :=	FND_LOG.LEVEL_EXCEPTION;
  g_error_level NUMBER	     :=	FND_LOG.LEVEL_ERROR;
  g_unexp_level NUMBER	     :=	FND_LOG.LEVEL_UNEXPECTED;
  g_path        VARCHAR2(100):= 'IGI.PLSQL.igiiawfb.igi_iac_wf_pkg.';

  --===========================FND_LOG.END=====================================

  FUNCTION START_PROCESS (X_flex_account_type  in varchar2,
		                X_book_type_code      in varchar2,
		                X_chart_of_accounts_id in number,
		                X_dist_ccid   in number,
		                X_acct_segval  in varchar2,
    	 	                X_default_ccid in number,
    	                   	X_account_ccid in number,
   		                X_distribution_id in number,
                        	X_Workflowprocess in varchar2,
                       	        X_return_ccid in out NOCOPY number)
    return boolean is
    ItemType	varchar2(30) :='IGIIACWF';
    ItemKey		varchar2(50);
    l_concat_segs   varchar2(2000);
    l_concat_ids    varchar2(2000);
    l_concat_descrs varchar2(2000);
    l_errmsg        varchar2(2000);
    l_encoded_msg   varchar2(2000);
    result 		boolean;
    l_result boolean;
    l_return_ccid   number;
    l_char_date	varchar2(27);
    l_account_type varchar2(2000);

    l_appl_short_name  varchar2(30);
    l_message_name    varchar2(30);
    l_num             number;
    l_string           varchar2(100);
    l_path_name VARCHAR2(150) := g_path||'start_process';

    l_new_acc        boolean;
    -- Default the item key to "IGIIACWF"
     BEGIN -- <<GEN_CCID>>
    --Initialize the fnd flex workflow
       --       fnd_flex_workflow.debug_on;
         itemkey := FND_FLEX_WORKFLOW.INITIALIZE
				('SQLGL',
				   'GL#',
				  X_chart_of_accounts_id,
				  'IGIIACWF'
				 );

  /* Initialize the workflow item attributes  */
    wf_engine.SetItemAttrText(itemtype => itemtype,
                                Itemkey  => itemkey,
                                aname    =>'IAC_BOOK_TYPE_CODE',
                                avalue   =>X_book_type_code);
    wf_engine.SetItemAttrText(itemtype => itemtype,
                              itemkey  => itemkey,
                              aname    =>'IAC_ACCOUNT_TYPE',
                              avalue   =>X_flex_account_type);
    wf_engine.SetItemAttrNumber(itemtype => itemtype,
                                itemkey  => itemkey,
                                aname    =>'IAC_CHART_OF_ACCOUNTS_ID',
                                avalue   =>X_chart_of_accounts_id);

    wf_engine.SetItemAttrNumber(itemtype => itemtype,
                                itemkey => itemkey,
                                aname   => 'IAC_DISTRIBUTION_CCID',
                                avalue  =>  X_dist_ccid );

     wf_engine.SetItemAttrText(itemtype => itemtype,
                               itemkey => itemkey,
                               aname   => 'IAC_ACCT_SEG_VAL',
                               avalue  =>  X_acct_segval);

     wf_engine.SetItemAttrNumber(itemtype => itemtype,
                                   itemkey => itemkey,
                                   aname   => 'IAC_DEFAULT_CCID',
                                   avalue  =>  X_default_ccid);


    wf_engine.SetItemAttrNumber(itemtype => itemtype,
                                   itemkey => itemkey,
                                   aname   => 'IAC_ACCOUNT_CCID',
                                   avalue  =>  X_account_ccid);

        wf_engine.SetItemAttrNumber(itemtype => itemtype,
                                   itemkey => itemkey,
                                   aname   => 'IAC_DISTRIBUTION_ID',
                                   avalue  =>  X_distribution_id);
    l_result := FND_FLEX_WORKFLOW.GENERATE(
                                   'IGIIACWF',
	                			    itemkey,
                      			    TRUE,
				                    l_return_ccid,
                				    l_concat_segs,
				                    l_concat_ids,
                				    l_concat_descrs,
				                    l_errmsg,
                                    l_new_acc);

     IF NOT l_result  THEN
        --	    ADD message  IGI_IAC_WF_FAILED_CCID to stack
        --    With  Tokens ACCOUNT_TYPE,DISTRIBUTION_ID,BOOK_TYPE_CODE.
            FND_MESSAGE.SET_NAME ('IGI', 'IGI_IAC_WF_FAILED_CCID');
            FND_MESSAGE.SET_TOKEN('ACCOUNT_TYPE',X_flex_Account_type, TRUE);
            --FND_MESSAGE.SET_TOKEN('BOOK_TYPE_CODE',X_book_type_code, TRUE);
            FND_MESSAGE.SET_TOKEN('DIST_ID',TO_CHAR(X_distribution_id), TRUE);
            FND_MESSAGE.SET_TOKEN('CONCAT_SEGS',l_concat_segs , TRUE);
  	    igi_iac_debug_pkg.debug_other_msg(p_level => g_error_level,
		  	p_full_path => l_path_name,
		  	p_remove_from_stack => FALSE);
            FND_MESSAGE.RAISE_ERROR;
	    RETURN FALSE;

     END IF;

      IF l_return_ccid > 1 Then
           X_return_ccid := l_return_ccid;
           return true;
     elsif
       l_return_ccid = -1  then  --use the function to get the value
            l_return_ccid := FND_FLEX_EXT.get_ccid(
    				 'SQLGL',
    				 'GL#',
    				  X_chart_of_accounts_id,
    				  l_char_date,
    		   		  l_concat_segs);
           X_return_ccid := l_return_ccid;
           return true;



      Else
    	    --ADD message  IGI_IAC_WF_FAILED_CCID to stack
            --With  Tokens ACCOUNT_TYPE,DISTRIBUTION_ID,BOOK_TYPE_CODE.
            FND_MESSAGE.SET_NAME ('IGI', 'IGI_IAC_WF_FAILED_CCID');
            FND_MESSAGE.SET_TOKEN('ACCOUNT_TYPE',X_flex_Account_type , TRUE);
           -- FND_MESSAGE.SET_TOKEN('BOOK_TYPE_CODE',X_book_type_code, TRUE);
            FND_MESSAGE.SET_TOKEN('DIST_ID',TO_CHAR(X_distribution_id), TRUE);
            FND_MESSAGE.SET_TOKEN('CONCAT_SEGS',l_concat_segs , TRUE);
  	    igi_iac_debug_pkg.debug_other_msg(p_level => g_error_level,
		  	p_full_path => l_path_name,
		  	p_remove_from_stack => FALSE);
            FND_MESSAGE.RAISE_ERROR;
   	   RETURN FALSE;
      END IF ;

      X_return_ccid := l_return_ccid;
      Return TRUE;
    EXCEPTION
    WHEN OTHERS THEN
  	 igi_iac_debug_pkg.debug_unexpected_msg(p_full_path => l_path_name);
         wf_core.context('IGI_IAC_WF_PKG',
                        'Start_Process',
                         X_book_type_code,
                         X_dist_ccid,
                         X_default_ccid,
                         'IGIIACWF');
        RAISE;
    END start_process;

    /* The check_account  function should return the group of the account based on the account type */

    PROCEDURE CHECK_ACCT(itemtype in varchar2,
	               	   itemkey	in varchar2,
        	    	   actid	in number,
                       funcmode     in varchar2,
            		   result       out NOCOPY varchar2)
    IS
    l_account_type varchar2(250);
    l_path_name VARCHAR2(150) := g_path||'check_acct';

    BEGIN <<    CHECK_ACCT>>

    --Based on the run mode return the values.
     IF (funcmode = 'RUN') THEN
        l_account_type :=  wf_engine.GetItemAttrText(itemtype,itemkey,'IAC_ACCOUNT_TYPE');
        result := 'COMPLETE:' || l_account_type;
        RETURN;
     ELSIF (funcmode = 'CANCEL') THEN
        result :=  'COMPLETE:';
        RETURN;
     ELSE
        result := '';
       RETURN;
     END IF;
    EXCEPTION
    WHEN OTHERS THEN
  		 igi_iac_debug_pkg.debug_unexpected_msg(p_full_path => l_path_name);
	         wf_core.context('IGI_IAC_WF_PKG',
                        'Check_Acct',
                         itemkey,
                         itemtype,
                         funcmode);
                         RAISE;

    END;  /* CHECK_ACCT */


    /* The check_group function should return the group of the account based on the account type */

    PROCEDURE CHECK_GROUP(itemtype in varchar2,
	    	              itemkey	in varchar2,
                     	  actid	in number,
		                  funcmode     in varchar2,
            		      result       out NOCOPY varchar2)
    IS
    l_account_type varchar2(250);
    l_path_name VARCHAR2(150) := g_path||'check_group';
    BEGIN <<CHECK_GROUP>>


     IF (funcmode = 'RUN') THEN
        /* determine the account group based on the account type passed */
        /* All accounts expect the DEPRN_EXP falls to category levelaccount*/
        /* Need to know which account falls into which account type */

          l_account_type := wf_engine.GetItemAttrText(itemtype,itemkey,'IAC_ACCOUNT_TYPE');
           IF (l_account_type in ( 'BACKLOG_DEPRN_RSV_ACCT',
                                	'OPERATING_EXPENSE_ACCT',
                                	'GENERAL_FUND_ACCT',
                                	'REVAL_RESERVE_ACCT',
                                	'REVAL_RESERVE_RETIRED_ACCT'))
           THEN
             result:= 'COMPLETE:' || 'CATE_LEVEL_ACCOUNT';
           ELSE
             result :=   'COMPLETE:';
           END IF;
    ELSIF (funcmode = 'CANCEL') THEN
            result :=  'COMPLETE:';
            RETURN;
    ELSE
            result := '';
           RETURN;
     END IF;
    EXCEPTION
    WHEN OTHERS THEN
  	 igi_iac_debug_pkg.debug_unexpected_msg(p_full_path => l_path_name);
         wf_core.context('IGI_IAC_WF_PKG',
                        'Check_Group',
                         itemkey,
                         itemtype,
                         funcmode);
                       RAISE;
    END;  /* CHECK_GROUP */
END; --end of package igi_iac_wf_pkg


/
