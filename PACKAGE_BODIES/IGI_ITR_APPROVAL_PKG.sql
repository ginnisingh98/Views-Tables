--------------------------------------------------------
--  DDL for Package Body IGI_ITR_APPROVAL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGI_ITR_APPROVAL_PKG" AS
-- $Header: igiitrwb.pls 120.10.12000000.2 2007/09/17 16:35:44 smannava ship $
--

  l_debug_level number	:=	FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  l_state_level number	:=	FND_LOG.LEVEL_STATEMENT;
  l_proc_level number	:=	FND_LOG.LEVEL_PROCEDURE;
  l_event_level number	:=	FND_LOG.LEVEL_EVENT;
  l_excep_level number	:=	FND_LOG.LEVEL_EXCEPTION;
  l_error_level number	:=	FND_LOG.LEVEL_ERROR;
  l_unexp_level number	:=	FND_LOG.LEVEL_UNEXPECTED;
  l_path   VARCHAR2(50) :=  'IGI.PLSQL.igiitrwb.IGI_ITR_APPROVAL_PKG.';


-- ****************************************************************************
-- Private procedure: Display diagnostic message
-- ****************************************************************************
PROCEDURE diagn_msg (p_level IN NUMBER, p_path IN VARCHAR2, p_mesg IN VARCHAR2) IS
BEGIN
        IF (p_level >=  l_debug_level ) THEN
            FND_LOG.STRING (p_level , l_path || p_path , p_mesg );
        END IF;

END ;


-- ****************************************************************************
-- Private function: Get authorization limit
-- ****************************************************************************
FUNCTION get_authorization_limit (p_employee_id NUMBER,
                                  p_set_of_books_id NUMBER) RETURN NUMBER IS
 l_limit  NUMBER;
BEGIN

  SELECT nvl(authorization_limit, 0)
  INTO   l_limit
  FROM   GL_AUTHORIZATION_LIMITS
  WHERE  employee_id = p_employee_id
    AND  ledger_id = p_set_of_books_id;

  return (l_limit);

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    l_limit := 0;
    return (l_limit);
  WHEN OTHERS THEN
    Wf_Core.Context('IGI_ITR_APPROVAL_PKG', 'get_authorization_limit',
                     null, null, null );
    IF ( l_unexp_level >=  l_debug_level) THEN
               FND_MESSAGE.SET_NAME('IGI','IGI_LOGGING_UNEXP_ERROR');
               FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
               FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
               FND_LOG.MESSAGE (l_unexp_level,'igi.plsql.igiitrwb.IGI_ITR_APPROVAL_PKG.get_authorization_limit',TRUE);
    END IF;
    raise;
END get_authorization_limit;



-- ****************************************************************************
--     Start_Approval_Workflow
-- ****************************************************************************
PROCEDURE start_approval_workflow (p_cc_id                 IN NUMBER,
                                   p_cc_line_num           IN NUMBER,
                                   p_preparer_fnd_user_id  IN NUMBER,
                                   p_cc_name               IN VARCHAR2,
                                   p_prep_auth             IN VARCHAR2,
                                   p_sec_apprv_fnd_id      IN NUMBER) IS

--	Local variables
	l_itemtype 		VARCHAR2(10) := 'ITRAPPRV';
	l_itemkey  		VARCHAR2(50) ;
        l_approval_run_id       NUMBER;
	l_preparer_id		NUMBER;
	l_preparer_name		VARCHAR2(240);
	l_preparer_display_name VARCHAR2(240);
        l_sysadmin_id           NUMBER;
        l_sysadmin_name         VARCHAR2(240);
        l_sysadmin_display_name VARCHAR2(240);
        l_sec_approver_id          NUMBER;
        l_sec_approver_name     VARCHAR2(240);
        l_sec_approver_display_name VARCHAR2(240);
        l_userkey                   VARCHAR2(116);
	l_func_currency	       	VARCHAR2(15);
BEGIN
        diagn_msg(l_state_level,'start_approval_workflow','Executing Start_Approval_Workflow for ITR cross charge line
        '|| to_char(p_cc_id)||'*'||to_char(p_cc_line_num));


        -- Update the status of the service line to 'W'
        -- Awaiting creation approval
        UPDATE igi_itr_charge_lines
        SET    status_flag = 'W'
              ,submit_date = sysdate
        WHERE  it_header_id = p_cc_id
        AND    it_line_num  = p_cc_line_num;



        -- Get approval run id
        SELECT IGI_ITR_APPROVAL_SS_S.nextval
        INTO   l_approval_run_id
        FROM   SYS.DUAL;

        -- generate the item key
        l_itemkey := to_char(p_cc_id)|| '/' ||to_char(p_cc_line_num)|| '/' || to_char(l_approval_run_id);

        diagn_msg(l_state_level,'start_approval_workflow','Generated Item Key = ' ||l_itemkey);

        -- generate the user key
        l_userkey := p_cc_name||'/'||to_char(p_cc_line_num) ;

        diagn_msg(l_state_level,'start_approval_workflow','Generated User Key = ' ||l_userkey);


	--  Kick Off workflow process
	wf_engine.CreateProcess( itemtype => l_itemtype,
				 itemkey  => l_itemkey,
				 process  => 'ITR_APPROVAL_TOP_PROCESS' );
        diagn_msg(l_state_level,'start_approval_workflow','Process for ITR_APPROVAL_TOP_PROCESS created');

        -- Set item user key
        wf_engine.SetItemUserKey( itemtype => l_itemtype,
				  itemkey  => l_itemkey,
				  userkey  => l_userkey );

	--  Set cross charge id (IT_HEADER_ID)
	wf_engine.SetItemAttrNumber( itemtype	=> l_itemtype,
			      	     itemkey  	=> l_itemkey,
  		 	      	     aname 	=> 'CROSS_CHARGE_ID',
			      	     avalue 	=> p_cc_id );
        diagn_msg(l_state_level,'start_approval_workflow','Attribute CROSS_CHARGE_ID set to' ||to_char(p_cc_id));

	--  Set cross charge line num (IT_LINE_NUM)
	wf_engine.SetItemAttrNumber( itemtype	=> l_itemtype,
			      	     itemkey  	=> l_itemkey,
  		 	      	     aname 	=> 'CC_LINE_NUM',
			      	     avalue 	=> p_cc_line_num );

	-- Set cross charge name (CC_NAME)
	wf_engine.SetItemAttrText ( itemtype	=> l_itemtype,
			      	    itemkey  	=> l_itemkey,
  		 	      	    aname 	=> 'CC_NAME',
			      	    avalue 	=> p_cc_name );
        diagn_msg(l_state_level,'start_approval_workflow','Attribute CC_NAME set to ' ||p_cc_name);

        -- Set the unique item key
        wf_engine.SetItemAttrText( itemtype	=> l_itemtype,
			      	   itemkey  	=> l_itemkey,
  		 	      	   aname 	=> 'UNIQUE_ITEMKEY',
			      	   avalue 	=> l_itemkey );
        diagn_msg(l_state_level,'start_approval_workflow','Set the unique item key: '||l_itemkey);


	--  Get employee ID
	SELECT employee_id
	INTO   l_preparer_id
	FROM   fnd_user
	WHERE  user_id = p_preparer_fnd_user_id;

	--  Set PersonID attribute (HR personID from PER_PERSONS_F)
	wf_engine.SetItemAttrNumber( itemtype	=> l_itemtype,
			      	     itemkey  	=> l_itemkey,
  		 	      	     aname 	=> 'PREPARER_ID',
			      	     avalue 	=> l_preparer_id);
        diagn_msg(l_state_level,'start_approval_workflow','Attribute PREPARER_ID set to ' ||l_preparer_id );

	-- Set UserID attribute (AOL userID from FND_USER table).
	wf_engine.SetItemAttrNumber( itemtype 	=> l_itemtype,
				     itemkey   	=> l_itemkey,
			    	     aname     	=> 'PREPARER_FND_ID',
				     avalue	=> p_preparer_fnd_user_id);

	-- Retrieve preparer's User name (Login name for Apps) and displayed name
	wf_directory.GetUserName(p_orig_system    => 'PER',
				 p_orig_system_id => l_preparer_id,
				 p_name		  => l_preparer_name,
				 p_display_name	  => l_preparer_display_name );
        diagn_msg(l_state_level,'start_approval_workflow','Retrieved user name: '||l_preparer_name);

	-- Copy username to Workflow
	wf_engine.SetItemAttrText( itemtype	=> l_itemtype,
			      	   itemkey  	=> l_itemkey,
  		 	      	   aname 	=> 'PREPARER_NAME',
			      	   avalue 	=> l_preparer_name );
        diagn_msg(l_state_level,'start_approval_workflow','Attribute PREPARER_NAME set to' ||l_preparer_name);

	-- Copy displayed username to Workflow
	wf_engine.SetItemAttrText( itemtype	=> l_itemtype,
			      	   itemkey  	=> l_itemkey,
  		 	      	   aname 	=> 'PREPARER_DISPLAY_NAME',
			      	   avalue 	=> l_preparer_display_name );
        diagn_msg(l_state_level,'start_approval_workflow','Attribute PREPARER_DISPLAY_NAME set to '||l_preparer_display_name);

	-- Populate preparer authorised attribute
	wf_engine.SetItemAttrText( itemtype	=> l_itemtype,
			      	   itemkey  	=> l_itemkey,
  		 	      	   aname 	=> 'PREPARER_AUTH',
			      	   avalue 	=> p_prep_auth );
        diagn_msg(l_state_level,'start_approval_workflow','Attribute PREPARER_AUTH set to '||p_prep_auth);

        IF p_sec_apprv_fnd_id is NOT NULL THEN
        -- set secondary approver attributes

        	--  Get employee ID of secondary approver
        	SELECT employee_id
        	INTO   l_sec_approver_id
        	FROM   fnd_user
        	WHERE  user_id = p_sec_apprv_fnd_id;

         	--  Set PersonID attribute (HR personID from PER_PERSONS_F)
	        wf_engine.SetItemAttrNumber( itemtype	=> l_itemtype,
	               		      	     itemkey  	=> l_itemkey,
  		         	      	     aname 	=> 'SEC_APPROVER_ID',
			         	     avalue 	=> l_sec_approver_id);
                diagn_msg(l_state_level,'start_approval_workflow','Attribute SEC_APPROVER_ID set to ' ||l_sec_approver_id );

	     -- Set UserID attribute (AOL userID from FND_USER table).
	        wf_engine.SetItemAttrNumber( itemtype 	=> l_itemtype,
	         			     itemkey   	=> l_itemkey,
		         	    	     aname     	=> 'SEC_APPROVER_FND_ID',
			         	     avalue	=> p_sec_apprv_fnd_id);

        	-- Retrieve Secondary Approver's User name (Login name for Apps)
                --  and displayed name
        	wf_directory.GetUserName(p_orig_system    => 'PER',
         				 p_orig_system_id => l_sec_approver_id,
	         			 p_name		  => l_sec_approver_name,
		         		 p_display_name	  => l_sec_approver_display_name );
                diagn_msg(l_state_level,'start_approval_workflow','Retrieved user name: '||l_sec_approver_name);

         	-- Copy username to Workflow
	        wf_engine.SetItemAttrText( itemtype	=> l_itemtype,
	         		      	   itemkey  	=> l_itemkey,
  		         	      	   aname 	=> 'SEC_APPROVER_NAME',
		        	      	   avalue 	=> l_sec_approver_name );
                diagn_msg(l_state_level,'start_approval_workflow','Attribute SEC_APPROVER_NAME set to' ||l_sec_approver_name);

	        -- Copy displayed username to Workflow
	        wf_engine.SetItemAttrText( itemtype	=> l_itemtype,
	         		      	   itemkey  	=> l_itemkey,
  		        	      	   aname 	=> 'SEC_APPROVER_DISPLAY_NAME',
		        	      	   avalue 	=> l_sec_approver_display_name );
                diagn_msg(l_state_level,'start_approval_workflow','Attribute SEC_APPROVER_DISPLAY_NAME set to '||
                           l_sec_approver_display_name);

        END IF;

	-- Finally, start the process
	wf_engine.StartProcess( itemtype => l_itemtype,
				itemkey  => l_itemkey );

        diagn_msg(l_state_level,'start_approval_workflow','Process ITR_APPROVAL_PROCESS started');

        commit;

EXCEPTION
  WHEN OTHERS THEN
    Wf_Core.Context('IGI_ITR_APPROVAL_PKG', 'start_approval_workflow', l_itemtype, l_itemkey);
    IF ( l_unexp_level >=  l_debug_level) THEN
               FND_MESSAGE.SET_NAME('IGI','IGI_LOGGING_UNEXP_ERROR');
               FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
               FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
               FND_LOG.MESSAGE (l_unexp_level,'igi.plsql.igiitrwb.IGI_ITR_APPROVAL_PKG.start_approval_workflow',TRUE);
    END IF;
    raise;

END start_approval_workflow;


--
-- *****************************************************************************
--   Get_SOB_Attributes
-- *****************************************************************************
--

  --
  -- Procedure
  --   Get_SOB_Attributes
  -- Purpose
  --   Copy information about the SOB to worklow tables
  -- History
  --  27-SEP-2000   S Brewer    Created.
  -- Arguments
  --   itemtype   	   Workflow item type (ITR Approval)
  --   itemkey    	   ID of cross charge
  --   actid		   ID of activity, provided by workflow engine
  --			     (not used in this procedure)
  --   funcmode		   Function mode (RUN or CANCEL)
  --   result              Result code of the activity
  -- Example
  --   N/A (not user-callable)
  --
  -- Notes
  --   This procedure is called from the Oracle Workflow engine
  --   It retrieves data elements about the Set of Books (identified by the itemkey
  --   argument) and stores them in the workflow tables to make them available
  --   for messages and subsequent procedures.
  --
PROCEDURE get_sob_attributes  (	itemtype	IN VARCHAR2,
		     		itemkey		IN VARCHAR2,
                       		actid      	IN NUMBER,
                       		funcmode    	IN VARCHAR2,
                                result          OUT NOCOPY VARCHAR2 ) IS
l_func_currency       	    	VARCHAR2(15);
l_cross_charge_id  	  	NUMBER;
l_set_of_books_id        	NUMBER;
l_timeout_days                  NUMBER;
l_timeout_mins                  NUMBER;
--
BEGIN

  IF ( funcmode = 'RUN'  ) THEN
    -- Get Cross Charge ID
    l_cross_charge_id := wf_engine.GetItemAttrNumber(
		itemtype  => itemtype,
		itemkey   => itemkey,
		aname     => 'CROSS_CHARGE_ID');


    -- Get set of books id
    SELECT set_of_books_id
      INTO l_set_of_books_id
      FROM igi_itr_charge_headers
     WHERE it_header_id = l_cross_charge_id;

    -- Retrieve set of books attributes

    SELECT currency_Code
    INTO   l_func_currency
    FROM   gl_sets_of_books
    WHERE  set_of_books_id = l_set_of_books_id;

--  find the timeout value (automatic approval exceed days)
--  chosen for the set of books (default value should be 7 if
--  no value was chosen )

    SELECT nvl(auto_approve_exceed_days,7)
    INTO   l_timeout_days
    FROM   igi_itr_charge_setup
    WHERE  set_of_books_id = l_set_of_books_id;

    l_timeout_mins := l_timeout_days*24*60;

    diagn_msg(l_state_level,'get_sob_attributes','SOB Attributes retrieved from db');

    -- Set the corresponding attributes in workflow
    wf_engine.SetItemAttrText ( itemtype => itemtype,
			        itemkey  => itemkey,
  		 	        aname 	 => 'FUNC_CURRENCY',
			        avalue 	 => l_func_currency );
    diagn_msg(l_state_level,'get_sob_attributes','Get_SOB_Attributes: Func currency = '||l_func_currency);

    wf_engine.SetItemAttrNumber ( itemtype  => itemtype,
			      	  itemkey   => itemkey,
  		 	      	  aname     => 'SET_OF_BOOKS_ID',
			      	  avalue    => l_set_of_books_id );
    diagn_msg(l_state_level,'get_sob_attributes','Get_SOB_Attributes: Set of books id : ' ||to_char(l_set_of_books_id ));

    wf_engine.SetItemAttrNumber ( itemtype  => itemtype,
			      	  itemkey   => itemkey,
  		 	      	  aname     => 'TIMEOUT_DAYS',
			      	  avalue    => l_timeout_days );
    diagn_msg(l_state_level,'get_sob_attributes','Get_SOB_Attributes: timeout days: ' ||to_char(l_timeout_days));

    wf_engine.SetItemAttrNumber ( itemtype  => itemtype,
			      	  itemkey   => itemkey,
  		 	      	  aname     => 'TIMEOUT_MINS',
			      	  avalue    => l_timeout_mins );
    diagn_msg(l_state_level,'get_sob_attributes','Get_SOB_Attributes: timeout mins: ' ||to_char(l_timeout_mins));

  ELSIF ( funcmode = 'CANCEL' ) THEN
   null;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    Wf_Core.Context('IGI_ITR_APPROVAL_PKG', 'get_sob_attributes', itemtype, itemkey);
     IF ( l_unexp_level >=  l_debug_level) THEN
               FND_MESSAGE.SET_NAME('IGI','IGI_LOGGING_UNEXP_ERROR');
               FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
               FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
               FND_LOG.MESSAGE (l_unexp_level,'igi.plsql.igiitrwb.IGI_ITR_APPROVAL_PKG.get_sob_attributes',TRUE);
    END IF;
    raise;
END get_sob_attributes;


--
-- *****************************************************************************
--   Get_CC_Attributes
-- *****************************************************************************
--
PROCEDURE get_cc_attributes(itemtype	IN VARCHAR2,
			     itemkey  	IN VARCHAR2,
			     actid	IN NUMBER,
			     funcmode	IN VARCHAR2,
                             result     OUT NOCOPY VARCHAR2 ) IS
l_cross_charge_id 	NUMBER;
l_cc_line_num           NUMBER;
l_service_line_id       NUMBER;
l_cc_line_tot           NUMBER;
l_charge_center_name    VARCHAR2(30);
l_charge_service_name          VARCHAR2(30);

--
BEGIN

  IF ( funcmode = 'RUN'  ) THEN

      -- Get cross charge ID (primary key)
      l_cross_charge_id := wf_engine.GetItemAttrNumber(
		itemtype  => itemtype,
		itemkey   => itemkey,
		aname     => 'CROSS_CHARGE_ID');

      -- Get cross charge line num
      l_cc_line_num := wf_engine.GetItemAttrNumber(
		itemtype  => itemtype,
		itemkey   => itemkey,
		aname     => 'CC_LINE_NUM');

        diagn_msg(l_state_level,'get_cc_attributes','Executing Get_CC_Attributes for cross charge line '
                ||to_char(l_cross_charge_id)||'/'||to_char(l_cc_line_num));


      -- Get the amount of the cross charge line, the service line id
      -- and the charge center id of the receiving charge center
      -- and the name of the service

      --Bug 2885987. Sql modified to remove MJC.

      SELECT  abs(nvl(itrl.entered_dr, 0) - nvl(itrl.entered_cr, 0))
             ,itrl.it_service_line_id
             ,cc.name
             ,servi.name
       INTO   l_cc_line_tot
             ,l_service_line_id
             ,l_charge_center_name
             ,l_charge_service_name
      FROM    igi_itr_charge_lines itrl
             ,igi_itr_service servi
             ,igi_itr_charge_center cc
             ,igi_itr_charge_service serv
      WHERE  itrl.it_header_id = l_cross_charge_id
        AND  itrl.it_line_num = l_cc_line_num
        AND  cc.charge_center_id = itrl.charge_center_id
        AND  serv.charge_service_id = itrl.charge_service_id
        AND  itrl.service_id = servi.service_id
        AND  servi.service_id = serv.service_id
        AND  serv.charge_center_id = cc.charge_center_id;

        --
	diagn_msg(l_state_level,'get_cc_attributes','CC Attributes retrieved from db');
        --
	-- Copy cross charge total to corresponding item attribute in workflow
	wf_engine.SetItemAttrNumber ( itemtype	=> itemtype,
			      	      itemkey  	=> itemkey,
  		 	      	      aname 	=> 'CC_LINE_AMOUNT',
			      	      avalue 	=> l_cc_line_tot );
        diagn_msg(l_state_level,'get_cc_attributes','get_cc_attributes: Cross Charge Line Amount = ' ||to_char(l_cc_line_tot));


	-- Copy service line id to corresponding item attribute in workflow
	wf_engine.SetItemAttrNumber ( itemtype	=> itemtype,
			      	      itemkey  	=> itemkey,
  		 	      	      aname 	=> 'SERVICE_LINE_ID',
			      	      avalue 	=> l_service_line_id );
        diagn_msg(l_state_level,'get_cc_attributes','get_cc_attributes: Service Line Id = ' ||to_char(l_service_line_id));

	-- Copy charge center name to corresponding item attribute in workflow
	wf_engine.SetItemAttrText   ( itemtype	=> itemtype,
			      	      itemkey  	=> itemkey,
  		 	      	      aname 	=> 'RECV_CHARGE_CENTER',
			      	      avalue 	=> l_charge_center_name);
        diagn_msg(l_state_level,'get_cc_attributes','get_cc_attributes: Charge Center Name = ' ||l_charge_center_name);

	-- Copy charge service name to corresponding item attribute in workflow
	wf_engine.SetItemAttrText   ( itemtype	=> itemtype,
			      	      itemkey  	=> itemkey,
  		 	      	      aname 	=> 'CHARGE_SERVICE_NAME',
			      	      avalue 	=> l_charge_service_name);
        diagn_msg(l_state_level,'get_cc_attributes','get_cc_attributes: Charge Service Name = ' ||l_charge_service_name);

        diagn_msg(l_state_level,'get_cc_attributes','CC Attributes stored in WF tables');

  ELSIF ( funcmode = 'CANCEL' ) THEN
	null;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    Wf_Core.Context('IGI_ITR_APPROVAL_PKG', 'get_cc_attributes', itemtype, itemkey);
     IF ( l_unexp_level >=  l_debug_level) THEN
               FND_MESSAGE.SET_NAME('IGI','IGI_LOGGING_UNEXP_ERROR');
               FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
               FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
               FND_LOG.MESSAGE (l_unexp_level,'igi.plsql.igiitrwb.IGI_ITR_APPROVAL_PKG.get_cc_attributes',TRUE);
    END IF;
    raise;

END get_cc_attributes;


--
-- *****************************************************************************
--   Did_Preparer_Approve
-- *****************************************************************************
--
PROCEDURE did_preparer_approve (itemtype	IN VARCHAR2,
		                itemkey  	IN VARCHAR2,
		                actid   	IN NUMBER,
		                funcmode	IN VARCHAR2,
                                result     OUT NOCOPY VARCHAR2 ) IS
l_preparer_auth  VARCHAR2(1);
BEGIN
  IF ( funcmode = 'RUN') THEN
    l_preparer_auth := wf_engine.GetItemAttrText( itemtype  => itemtype,
			    			  itemkey   => itemkey,
			    			  aname     => 'PREPARER_AUTH');
    diagn_msg(l_state_level,'did_preparer_approve','Preparer authorised to approve =  '||l_preparer_auth);

    IF l_preparer_auth = 'Y' THEN
      result := 'COMPLETE:Y';
      return;
    ELSE
      result := 'COMPLETE:N';
      return;
    END IF;

  ELSIF ( funcmode = 'CANCEL' ) THEN
	null;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    Wf_Core.Context('IGI_ITR_APPROVAL_PKG', 'did_preparer_approve', itemtype, itemkey);
    IF ( l_unexp_level >=  l_debug_level) THEN
               FND_MESSAGE.SET_NAME('IGI','IGI_LOGGING_UNEXP_ERROR');
               FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
               FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
               FND_LOG.MESSAGE (l_unexp_level,'igi.plsql.igiitrwb.IGI_ITR_APPROVAL_PKG.did_preparer_approve',TRUE);
    END IF;
    raise;
END did_preparer_approve;



--
-- *****************************************************************************
--   Set_Approver_Name_to_Prep
-- *****************************************************************************
--
PROCEDURE set_approver_name_to_prep (itemtype	IN VARCHAR2,
		                     itemkey  	IN VARCHAR2,
		                     actid	IN NUMBER,
		                     funcmode	IN VARCHAR2,
                                     result     OUT NOCOPY VARCHAR2 ) IS
l_preparer_id	NUMBER;
l_preparer_name VARCHAR2(240);
l_preparer_display_name  VARCHAR2(240);
BEGIN
  IF ( funcmode = 'RUN') THEN
    l_preparer_id :=  wf_engine.GetItemAttrNumber( itemtype  => itemtype,
			    			   itemkey   => itemkey,
			    			   aname     => 'PREPARER_ID');
    l_preparer_name := wf_engine.GetItemAttrText( itemtype  => itemtype,
			    			  itemkey   => itemkey,
			    			  aname     => 'PREPARER_NAME');
    l_preparer_display_name := wf_engine.GetItemAttrText( itemtype  => itemtype,
			    			  itemkey   => itemkey,
			    			  aname     => 'PREPARER_DISPLAY_NAME');
    wf_engine.SetItemAttrNumber( itemtype  => itemtype,
			         itemkey   => itemkey,
  		 	      	 aname 	   => 'APPROVER_ID',
			      	 avalue    => l_preparer_id );
    wf_engine.SetItemAttrText( itemtype	 => itemtype,
			       itemkey   => itemkey,
  		 	       aname 	 => 'APPROVER_NAME',
			       avalue 	 => l_preparer_name );
    wf_engine.SetItemAttrText( itemtype	 => itemtype,
			       itemkey   => itemkey,
  		 	       aname 	 => 'APPROVER_DISPLAY_NAME',
			       avalue 	 => l_preparer_display_name );
    diagn_msg(l_state_level,'set_approver_name_to_prep','Approver name set for cross charge line ');
  ELSIF ( funcmode = 'CANCEL' ) THEN
	null;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    Wf_Core.Context('IGI_ITR_APPROVAL_PKG', 'set_approver_name_to_prep', itemtype, itemkey);
    IF ( l_unexp_level >=  l_debug_level) THEN
               FND_MESSAGE.SET_NAME('IGI','IGI_LOGGING_UNEXP_ERROR');
               FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
               FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
               FND_LOG.MESSAGE (l_unexp_level,'igi.plsql.igiitrwb.IGI_ITR_APPROVAL_PKG.set_approver_name_to_prep',TRUE);
    END IF;
    raise;
END set_approver_name_to_prep;



--
-- *****************************************************************************
--   Secondary_approver_selected
-- *****************************************************************************
--
PROCEDURE secondary_approver_selected(itemtype	IN VARCHAR2,
		                      itemkey  	IN VARCHAR2,
		                      actid   	IN NUMBER,
		                      funcmode	IN VARCHAR2,
                                      result     OUT NOCOPY VARCHAR2 ) IS
l_sec_approver_fnd_id  NUMBER;
BEGIN
  IF ( funcmode = 'RUN') THEN
    l_sec_approver_fnd_id := wf_engine.GetItemAttrText( itemtype  => itemtype,
			    			        itemkey   => itemkey,
			    			        aname     => 'SEC_APPROVER_FND_ID');

    IF l_sec_approver_fnd_id is not null THEN
      result := 'COMPLETE:Y';
      return;
    ELSE
      result := 'COMPLETE:N';
      return;
    END IF;

  ELSIF ( funcmode = 'CANCEL' ) THEN
	null;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    Wf_Core.Context('IGI_ITR_APPROVAL_PKG', 'secondary_approver_selected', itemtype, itemkey);
    IF ( l_unexp_level >=  l_debug_level) THEN
               FND_MESSAGE.SET_NAME('IGI','IGI_LOGGING_UNEXP_ERROR');
               FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
               FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
               FND_LOG.MESSAGE (l_unexp_level,'igi.plsql.igiitrwb.IGI_ITR_APPROVAL_PKG.secondary_approver_selected',TRUE);
    END IF;
    raise;
END secondary_approver_selected;



--
-- *****************************************************************************
--   Set_Approver_Name_to_Sec_App
-- *****************************************************************************
--
PROCEDURE set_approver_name_to_sec_app (itemtype	IN VARCHAR2,
		                        itemkey  	IN VARCHAR2,
		                        actid	        IN NUMBER,
		                        funcmode	IN VARCHAR2,
                                        result          OUT NOCOPY VARCHAR2 ) IS
l_sec_approver_id	NUMBER;
l_sec_approver_name VARCHAR2(240);
l_sec_approver_display_name  VARCHAR2(240);
BEGIN
  IF ( funcmode = 'RUN') THEN
    l_sec_approver_id :=  wf_engine.GetItemAttrNumber( itemtype  => itemtype,
			    			   itemkey   => itemkey,
			    			   aname     => 'SEC_APPROVER_ID');
    l_sec_approver_name := wf_engine.GetItemAttrText( itemtype  => itemtype,
			    			  itemkey   => itemkey,
			    			  aname     => 'SEC_APPROVER_NAME');
    l_sec_approver_display_name := wf_engine.GetItemAttrText( itemtype  => itemtype,
			    			  itemkey   => itemkey,
			    			  aname     => 'SEC_APPROVER_DISPLAY_NAME');
    wf_engine.SetItemAttrNumber( itemtype  => itemtype,
			         itemkey   => itemkey,
  		 	      	 aname 	   => 'APPROVER_ID',
			      	 avalue    => l_sec_approver_id );
    wf_engine.SetItemAttrText( itemtype	 => itemtype,
			       itemkey   => itemkey,
  		 	       aname 	 => 'APPROVER_NAME',
			       avalue 	 => l_sec_approver_name );
    wf_engine.SetItemAttrText( itemtype	 => itemtype,
			       itemkey   => itemkey,
  		 	       aname 	 => 'APPROVER_DISPLAY_NAME',
			       avalue 	 => l_sec_approver_display_name );
    diagn_msg(l_state_level,'set_approver_name_to_sec_app','Approver name set for cross charge line ');
  ELSIF ( funcmode = 'CANCEL' ) THEN
	null;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    Wf_Core.Context('IGI_ITR_APPROVAL_PKG', 'set_approver_name_to_sec_app', itemtype, itemkey);
    IF ( l_unexp_level >=  l_debug_level) THEN
               FND_MESSAGE.SET_NAME('IGI','IGI_LOGGING_UNEXP_ERROR');
               FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
               FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
               FND_LOG.MESSAGE (l_unexp_level,'igi.plsql.igiitrwb.IGI_ITR_APPROVAL_PKG.set_approver_name_to_sec_app',TRUE);
    END IF;
    raise;
END set_approver_name_to_sec_app;


--
-- ****************************************************************************
--  Procedure maintain_history
-- ****************************************************************************
--
PROCEDURE maintain_history (itemtype	   IN VARCHAR2,
		            itemkey        IN VARCHAR2,
		            actid	   IN NUMBER,
		            funcmode	   IN VARCHAR2,
                            result         OUT NOCOPY VARCHAR2) IS
  l_service_line_id        NUMBER;
  l_sequence_num           NUMBER;
  l_action_code            VARCHAR2(1);
  l_performer_id           NUMBER;
  l_user_id                NUMBER;
  l_login_id               NUMBER;
BEGIN
  IF funcmode = 'RUN' THEN
    diagn_msg(l_state_level,'maintain_history','Executing maintain_history');

    l_service_line_id :=  wf_engine.GetItemAttrNumber(
                                          itemtype  => itemtype,
			                  itemkey   => itemkey,
			    	          aname     => 'SERVICE_LINE_ID' );

    SELECT max(sequence_num) + 1
    INTO   l_sequence_num
    FROM   igi_itr_action_history
    WHERE  it_service_line_id = l_service_line_id;

    l_action_code := wf_engine.GetActivityAttrText(
                                      itemtype => itemtype,
                                      itemkey  => itemkey,
                                      actid    => actid,
                                      aname    => 'ACTION_CODE' );

    l_performer_id := wf_engine.GetActivityAttrText(
                                      itemtype => itemtype,
                                      itemkey  => itemkey,
                                      actid    => actid,
                                      aname    => 'PERFORMER_ID' );

    l_user_id := fnd_global.user_id;
    l_user_id := fnd_global.login_id;


    -- Call the table handler to update the ITR action history table
    -- with the action performed

    igi_itr_action_history_ss_pkg.insert_row(
                   X_Service_Line_Id   => l_service_line_id
                  ,X_Sequence_Num      => l_sequence_num
                  ,X_Action_Code       => l_action_code
                  ,X_Action_Date       => sysdate
                  ,X_Employee_Id       => l_performer_id
                  ,X_Use_Workflow_Flag => 'Y'
                  ,X_Note              => null
                  ,X_Created_By        => l_user_id
                  ,X_Creation_Date     => sysdate
                  ,X_Last_Update_Login => l_login_id
                  ,X_Last_Update_Date  => sysdate
                  ,X_Last_Updated_By   => l_user_id);


  ELSIF ( funcmode = 'CANCEL' ) THEN
    null;

  END IF;

EXCEPTION
  WHEN OTHERS THEN
    Wf_Core.Context('IGI_ITR_APPROVAL_PKG', 'maintain_history', itemtype, itemkey);
    IF ( l_unexp_level >=  l_debug_level) THEN
               FND_MESSAGE.SET_NAME('IGI','IGI_LOGGING_UNEXP_ERROR');
               FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
               FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
               FND_LOG.MESSAGE (l_unexp_level,'igi.plsql.igiitrwb.IGI_ITR_APPROVAL_PKG.maintain_history',TRUE);
    END IF;
    raise;
END maintain_history;




--
-- ****************************************************************************
--  Procedure submit_cc_line
-- ****************************************************************************
--
PROCEDURE submit_cc_line (itemtype	   IN VARCHAR2,
		          itemkey          IN VARCHAR2,
		          actid	           IN NUMBER,
		          funcmode	   IN VARCHAR2,
                          result           OUT NOCOPY VARCHAR2) IS
  l_cross_charge_id	NUMBER;
  l_cc_line_num           NUMBER;
BEGIN
  IF funcmode = 'RUN' THEN
    diagn_msg(l_state_level,'submit_cc_line','Executing Submit_CC_line');

    l_cross_charge_id :=  wf_engine.GetItemAttrNumber(
                                               itemtype  => itemtype,
			    		       itemkey   => itemkey,
			    		       aname     => 'CROSS_CHARGE_ID' );

    l_cc_line_num := wf_engine.GetItemAttrNumber( itemtype => itemtype,
                                                  itemkey => itemkey,
                                                  aname => 'CC_LINE_NUM');

    --
    -- Set status of Cross Charge Line to 'V' for 'Awaiting Receiver Approval'

    UPDATE IGI_ITR_CHARGE_LINES
    SET status_flag  = 'V'
    WHERE  it_header_id = l_cross_charge_id
    AND    it_line_num = l_cc_line_num;


    diagn_msg(l_state_level,'submit_cc_line','Cross Charge Line'||to_char(l_cross_charge_id)||'/'||to_char(l_cc_line_num)||' has been submitted');
        --
  ELSIF ( funcmode = 'CANCEL' ) THEN
    null;

  END IF;

EXCEPTION
  WHEN OTHERS THEN
    Wf_Core.Context('IGI_ITR_APPROVAL_PKG', 'submit_cc_line', itemtype, itemkey);
    IF ( l_unexp_level >=  l_debug_level) THEN
               FND_MESSAGE.SET_NAME('IGI','IGI_LOGGING_UNEXP_ERROR');
               FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
               FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
               FND_LOG.MESSAGE (l_unexp_level,'igi.plsql.igiitrwb.IGI_ITR_APPROVAL_PKG.submit_cc_line',TRUE);
    END IF;
    raise;
END submit_cc_line;



--
-- ****************************************************************************
--  Procedure no_submit_cc_line
-- ****************************************************************************
--
PROCEDURE no_submit_cc_line (itemtype	   IN VARCHAR2,
	                  itemkey          IN VARCHAR2,
		          actid	           IN NUMBER,
		          funcmode	   IN VARCHAR2,
                          result           OUT NOCOPY VARCHAR2) IS
l_cross_charge_id	NUMBER;
l_cc_line_num           NUMBER;
BEGIN
  IF funcmode = 'RUN' THEN
    diagn_msg(l_state_level,'no_submit_cc_line','Executing No_Submit_CC_line');

    l_cross_charge_id :=  wf_engine.GetItemAttrNumber(
                                               itemtype  => itemtype,
			    		       itemkey   => itemkey,
			    		       aname     => 'CROSS_CHARGE_ID' );

    l_cc_line_num := wf_engine.GetItemAttrNumber( itemtype => itemtype,
                                                  itemkey => itemkey,
                                                  aname => 'CC_LINE_NUM');

    --
    -- Set status of Cross Charge Line to 'J' for 'Rejected in Creation'

    UPDATE  IGI_ITR_CHARGE_LINES
    SET     status_flag  = 'J'
    WHERE   it_header_id = l_cross_charge_id
    AND     it_line_num = l_cc_line_num;

    diagn_msg(l_state_level,'no_submit_cc_line','Cross Charge Line'||to_char(l_cross_charge_id)||'/'||to_char(l_cc_line_num)||' has not been submitted');
        --
  ELSIF ( funcmode = 'CANCEL' ) THEN
    null;

  END IF;

EXCEPTION
  WHEN OTHERS THEN
    Wf_Core.Context('IGI_ITR_APPROVAL_PKG', 'no_submit_cc_line', itemtype, itemkey);
    IF ( l_unexp_level >=  l_debug_level) THEN
               FND_MESSAGE.SET_NAME('IGI','IGI_LOGGING_UNEXP_ERROR');
               FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
               FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
               FND_LOG.MESSAGE (l_unexp_level,'igi.plsql.igiitrwb.IGI_ITR_APPROVAL_PKG.no_submit_cc_line',TRUE);
    END IF;
    raise;
END no_submit_cc_line;





--
-- *****************************************************************************
--   find_cc_receiver
-- *****************************************************************************
--
PROCEDURE find_cc_receiver(itemtype	IN VARCHAR2,
		           itemkey  	IN VARCHAR2,
		           actid	IN NUMBER,
		           funcmode	IN VARCHAR2,
		           result	OUT NOCOPY VARCHAR2 ) IS

l_cross_charge_id               NUMBER;
l_cc_line_num                   NUMBER;
l_charge_range_id               NUMBER;
l_rec_fnd_user_id               NUMBER;
l_receiver_id                   NUMBER;
l_receiver_name                 VARCHAR2(240);
l_receiver_display_name         VARCHAR2(240);


BEGIN

  IF ( funcmode = 'RUN'  ) THEN

      -- Get cross charge ID (primary key)
      l_cross_charge_id := wf_engine.GetItemAttrNumber(
		itemtype  => itemtype,
		itemkey   => itemkey,
		aname     => 'CROSS_CHARGE_ID');

      -- Get cross charge line num
      l_cc_line_num := wf_engine.GetItemAttrNumber(
		itemtype  => itemtype,
		itemkey   => itemkey,
		aname     => 'CC_LINE_NUM');


   -- Get the receiver fnd user id for the service line
   -- This is found using the charge_range_id of the charge range
   -- which was valid at the time of charge entry.

      SELECT auth.authoriser_id
      INTO   l_rec_fnd_user_id
      FROM   igi_itr_charge_ranges auth
            ,igi_itr_charge_lines itrl
      WHERE  itrl.it_header_id = l_cross_charge_id
      AND    itrl.it_line_num = l_cc_line_num
      AND    itrl.charge_range_id = auth.charge_range_id;


	--  Set Receiver fnd user ID attribute (AOL user ID from FND_USER)
	wf_engine.SetItemAttrNumber( itemtype	=> itemtype,
			      	     itemkey  	=> itemkey,
  		 	      	     aname 	=> 'RECEIVER_FND_ID',
			      	     avalue 	=> l_rec_fnd_user_id);
        diagn_msg(l_state_level,'find_cc_receiver','Attribute RECEIVER_FND_ID set to ' ||l_rec_fnd_user_id );


	--  Get employee ID of receiver
	SELECT employee_id
	INTO   l_receiver_id
	FROM   fnd_user
	WHERE  user_id = l_rec_fnd_user_id;

	--  Set PersonID attribute (HR personID from PER_PERSONS_F)
	wf_engine.SetItemAttrNumber( itemtype	=> itemtype,
			      	     itemkey  	=> itemkey,
  		 	      	     aname 	=> 'RECEIVER_ID',
			      	     avalue 	=> l_receiver_id);
        diagn_msg(l_state_level,'find_cc_receiver','Attribute RECEIVER_ID set to ' ||l_receiver_id );


	-- Retrieve receiver's User name (Login name for Apps) and displayed name
	wf_directory.GetUserName(p_orig_system    => 'PER',
				 p_orig_system_id => l_receiver_id,
				 p_name		  => l_receiver_name,
				 p_display_name	  => l_receiver_display_name );
        diagn_msg(l_state_level,'find_cc_receiver','Retrieved user name: '||l_receiver_name);
        diagn_msg(l_state_level,'find_cc_receiver','Retrieved user display name: '||l_receiver_display_name);

	-- Copy username to Workflow
	wf_engine.SetItemAttrText( itemtype	=> itemtype,
			      	   itemkey  	=> itemkey,
  		 	      	   aname 	=> 'RECEIVER_NAME',
			      	   avalue 	=> l_receiver_name );
        diagn_msg(l_state_level,'find_cc_receiver','Attribute RECEIVER_NAME set to' ||l_receiver_name);

	-- Copy displayed username to Workflow
	wf_engine.SetItemAttrText( itemtype	=> itemtype,
			      	   itemkey  	=> itemkey,
  		 	      	   aname 	=> 'RECEIVER_DISPLAY_NAME',
			      	   avalue 	=> l_receiver_display_name );
        diagn_msg(l_state_level,'find_cc_receiver','Attribute RECEIVER_DISPLAY_NAME set to '||l_receiver_display_name);



    result := 'COMPLETE:Y';

  ELSIF (funcmode = 'CANCEL') THEN
    NULL;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    Wf_Core.Context('IGI_ITR_APPROVAL_PKG', 'find_cc_receiver', itemtype, itemkey);
    IF ( l_unexp_level >=  l_debug_level) THEN
               FND_MESSAGE.SET_NAME('IGI','IGI_LOGGING_UNEXP_ERROR');
               FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
               FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
               FND_LOG.MESSAGE (l_unexp_level,'igi.plsql.igiitrwb.IGI_ITR_APPROVAL_PKG.find_cc_receiver',TRUE);
    END IF;
    raise;
END find_cc_receiver;


--
-- *****************************************************************************
--   Set_Approver_Name_to_Rec
-- *****************************************************************************
--
PROCEDURE set_approver_name_to_rec (itemtype	IN VARCHAR2,
		                    itemkey  	IN VARCHAR2,
		                    actid	IN NUMBER,
		                    funcmode	IN VARCHAR2,
                                    result     OUT NOCOPY VARCHAR2 ) IS
l_receiver_id	NUMBER;
l_receiver_name VARCHAR2(240);
l_receiver_display_name  VARCHAR2(240);
BEGIN
  IF ( funcmode = 'RUN') THEN
    l_receiver_id :=  wf_engine.GetItemAttrNumber( itemtype  => itemtype,
			    			   itemkey   => itemkey,
			    			   aname     => 'RECEIVER_ID');
    l_receiver_name := wf_engine.GetItemAttrText( itemtype  => itemtype,
			    			  itemkey   => itemkey,
			    			  aname     => 'RECEIVER_NAME');
    l_receiver_display_name := wf_engine.GetItemAttrText( itemtype  => itemtype,
			    			  itemkey   => itemkey,
			    			  aname     => 'RECEIVER_DISPLAY_NAME');
    wf_engine.SetItemAttrNumber( itemtype  => itemtype,
			         itemkey   => itemkey,
  		 	      	 aname 	   => 'APPROVER_ID',
			      	 avalue    => l_receiver_id );
    wf_engine.SetItemAttrText( itemtype	 => itemtype,
			       itemkey   => itemkey,
  		 	       aname 	 => 'APPROVER_NAME',
			       avalue 	 => l_receiver_name );
    wf_engine.SetItemAttrText( itemtype	 => itemtype,
			       itemkey   => itemkey,
  		 	       aname 	 => 'APPROVER_DISPLAY_NAME',
			       avalue 	 => l_receiver_display_name );
    diagn_msg(l_state_level,'set_approver_name_to_rec','Approver name set for cross charge line ');
  ELSIF ( funcmode = 'CANCEL' ) THEN
	null;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    Wf_Core.Context('IGI_ITR_APPROVAL_PKG', 'set_approver_name_to_rec', itemtype, itemkey);
    IF ( l_unexp_level >=  l_debug_level) THEN
               FND_MESSAGE.SET_NAME('IGI','IGI_LOGGING_UNEXP_ERROR');
               FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
               FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
               FND_LOG.MESSAGE (l_unexp_level,'igi.plsql.igiitrwb.set_approver_name_to_rec',TRUE);
    END IF;
    raise;
END set_approver_name_to_rec;


--
-- *****************************************************************************
--   Procedure Double_Timeout
-- *****************************************************************************
--
PROCEDURE double_timeout (itemtype	IN VARCHAR2,
		          itemkey  	IN VARCHAR2,
		          actid   	IN NUMBER,
		          funcmode	IN VARCHAR2,
                          result     OUT NOCOPY VARCHAR2 ) IS

l_set_of_books_id    NUMBER;
l_use_double_timeout VARCHAR2(1);

BEGIN
  IF ( funcmode = 'RUN') THEN

    diagn_msg(l_state_level,'double_timeout','Double_Timeout');

    l_set_of_books_id := wf_engine.GetItemAttrNumber( itemtype  => itemtype,
			    		              itemkey   => itemkey,
			    			      aname     => 'SET_OF_BOOKS_ID');


    SELECT nvl(use_double_timeout_flag,'N')
    INTO   l_use_double_timeout
    FROM   igi_itr_charge_setup
    WHERE  set_of_books_id = l_set_of_books_id;

    IF (l_use_double_timeout = 'Y') THEN
      result := 'COMPLETE:Y';
      return;
    ELSE
      result := 'COMPLETE:N';
      return;
    END IF;

  ELSIF ( funcmode = 'CANCEL' ) THEN
	null;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    Wf_Core.Context('IGI_ITR_APPROVAL_PKG', 'double_timeout', itemtype, itemkey);
    IF ( l_unexp_level >=  l_debug_level) THEN
               FND_MESSAGE.SET_NAME('IGI','IGI_LOGGING_UNEXP_ERROR');
               FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
               FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
               FND_LOG.MESSAGE (l_unexp_level,'igi.plsql.igiitrwb.IGI_ITR_APPROVAL_PKG.double_timeout',TRUE);
    END IF;
    raise;
END double_timeout;



--
-- *****************************************************************************
--   Procedure Final_Approver
-- *****************************************************************************
--
PROCEDURE final_approver (itemtype	IN VARCHAR2,
		          itemkey  	IN VARCHAR2,
		          actid   	IN NUMBER,
		          funcmode	IN VARCHAR2,
                          result     OUT NOCOPY VARCHAR2 ) IS
l_approver_id NUMBER;
l_approval_amount NUMBER;
l_set_of_books_id NUMBER;
l_approval_limit  NUMBER;
BEGIN
  IF ( funcmode = 'RUN') THEN

    diagn_msg(l_state_level,'final_approver','Final_Approver');
    l_approver_id := wf_engine.GetItemAttrNumber( itemtype  => itemtype,
			    			  itemkey   => itemkey,
			    			  aname     => 'APPROVER_ID');
    l_approval_amount := wf_engine.GetItemAttrNumber( itemtype  => itemtype,
			    			      itemkey   => itemkey,
			    			      aname     => 'CC_LINE_AMOUNT');
    l_set_of_books_id := wf_engine.GetItemAttrNumber( itemtype  => itemtype,
			    			      itemkey   => itemkey,
			    			      aname     => 'SET_OF_BOOKS_ID');

    l_approval_limit := get_authorization_limit(l_approver_id,
                                                l_set_of_books_id);

    IF (l_approval_limit >= l_approval_amount) THEN
      result := 'COMPLETE:Y';
      return;
    ELSE
      result := 'COMPLETE:N';
      return;
    END IF;

  ELSIF ( funcmode = 'CANCEL' ) THEN
	null;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    Wf_Core.Context('IGI_ITR_APPROVAL_PKG', 'final_approver', itemtype, itemkey);
    IF ( l_unexp_level >=  l_debug_level) THEN
               FND_MESSAGE.SET_NAME('IGI','IGI_LOGGING_UNEXP_ERROR');
               FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
               FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
               FND_LOG.MESSAGE (l_unexp_level,'igi.plsql.igiitrwb.IGI_ITR_APPROVAL_PKG.final_approver',TRUE);
    END IF;
    raise;
END final_approver;


--
-- *****************************************************************************
--   Procedure Is_Receiver_Final_Approver
-- *****************************************************************************
--
PROCEDURE is_receiver_final_approver (itemtype	IN VARCHAR2,
		                      itemkey  	IN VARCHAR2,
		                      actid   	IN NUMBER,
		                      funcmode	IN VARCHAR2,
                                      result     OUT NOCOPY VARCHAR2 ) IS
l_approver_id NUMBER;
l_receiver_id NUMBER;
BEGIN
  IF ( funcmode = 'RUN') THEN

    diagn_msg(l_state_level,'is_receiver_final_approver','Is Receiver Final_Approver');
    l_approver_id := wf_engine.GetItemAttrNumber( itemtype  => itemtype,
			    			  itemkey   => itemkey,
			    			  aname     => 'APPROVER_ID');
    l_receiver_id := wf_engine.GetItemAttrNumber( itemtype  => itemtype,
			    			  itemkey   => itemkey,
			    			  aname     => 'RECEIVER_ID');

    IF (l_receiver_id = l_approver_id) THEN
      result := 'COMPLETE:Y';
      return;
    ELSE
      result := 'COMPLETE:N';
      return;
   END IF;

  ELSIF ( funcmode = 'CANCEL' ) THEN
	null;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    Wf_Core.Context('IGI_ITR_APPROVAL_PKG', 'is_receiver_final_approver', itemtype, itemkey);
    IF ( l_unexp_level >=  l_debug_level) THEN
               FND_MESSAGE.SET_NAME('IGI','IGI_LOGGING_UNEXP_ERROR');
               FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
               FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
               FND_LOG.MESSAGE (l_unexp_level,'igi.plsql.igiitrwb.IGI_ITR_APPROVAL_PKG.is_receiver_final_approver',TRUE);
    END IF;
    raise;
END is_receiver_final_approver;


--
-- ****************************************************************************
--  Procedure Verify_Authority
-- ****************************************************************************
--
PROCEDURE verify_authority( itemtype	IN VARCHAR2,
			    itemkey  	IN VARCHAR2,
			    actid	IN NUMBER,
			    funcmode	IN VARCHAR2,
			    result	OUT NOCOPY VARCHAR2 ) IS
l_approver_id 	   NUMBER;
l_approval_limit   NUMBER;
l_approval_amount  NUMBER;
l_set_of_books_id  NUMBER;
BEGIN
  IF funcmode = 'RUN' THEN

    diagn_msg(l_state_level,'verify_authority','Executing Verify_Authority');
    l_approver_id :=  wf_engine.GetItemAttrNumber( itemtype  => itemtype,
			    			   itemkey   => itemkey,
			    			   aname     => 'APPROVER_ID');
    l_approval_amount := wf_engine.GetItemAttrNumber( itemtype,
						      itemkey,
						      'CC_LINE_AMOUNT');
    l_set_of_books_id := wf_engine.GetItemAttrNumber(
                itemtype  => itemtype,
                itemkey   => itemkey,
                aname     => 'SET_OF_BOOKS_ID');

    l_approval_limit := get_authorization_limit(l_approver_id, l_set_of_books_id);

    IF (l_approval_limit >= l_approval_amount) THEN
      result := 'COMPLETE:PASS';
    ELSE
      result := 'COMPLETE:FAIL';
    END IF;

  ELSIF ( funcmode = 'CANCEL' ) THEN
    NULL;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    Wf_Core.Context('IGI_ITR_APPROVAL_PKG', 'verify_authority', itemtype, itemkey);
    IF ( l_unexp_level >=  l_debug_level) THEN
               FND_MESSAGE.SET_NAME('IGI','IGI_LOGGING_UNEXP_ERROR');
               FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
               FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
               FND_LOG.MESSAGE (l_unexp_level,'igi.plsql.igiitrwb.IGI_ITR_APPROVAL_PKG.verify_authority',TRUE);
    END IF;
    raise;
END verify_authority;


--
-- ****************************************************************************
--  Procedure approve_cc_line
-- ****************************************************************************
--
PROCEDURE approve_cc_line (itemtype	   IN VARCHAR2,
		           itemkey      IN VARCHAR2,
		           actid	   IN NUMBER,
		           funcmode	   IN VARCHAR2,
                           result       OUT NOCOPY VARCHAR2) IS
l_cross_charge_id	NUMBER;
l_cc_line_num           NUMBER;
BEGIN
  IF funcmode = 'RUN' THEN
    diagn_msg(l_state_level,'approve_cc_line','Executing Approve_CC_line');

    l_cross_charge_id :=  wf_engine.GetItemAttrNumber(
                                               itemtype  => itemtype,
			    		       itemkey   => itemkey,
			    		       aname     => 'CROSS_CHARGE_ID' );

    l_cc_line_num := wf_engine.GetItemAttrNumber( itemtype => itemtype,
                                                  itemkey => itemkey,
                                                  aname => 'CC_LINE_NUM');

    --
    -- Set status of Cross Charge Line to 'A' for 'Approved'

    UPDATE IGI_ITR_CHARGE_LINES
    SET    status_flag  = 'A'
    WHERE  it_header_id = l_cross_charge_id
    AND    it_line_num = l_cc_line_num;

    diagn_msg(l_state_level,'approve_cc_line','Cross Charge Line'||to_char(l_cross_charge_id)||'/'||to_char(l_cc_line_num)||' has been accepted');
        --
   --  Since this service line has been approved, need to check the
   --  cross charge to see if ALL the service lines have been either approved
   --  or cancelled, in which case the cross charge will be Complete
   --  Therefore, need to call the following procedure which will
   --  handle this checking.

   IGIGITCH.update_header_status(l_cross_charge_id);


  ELSIF ( funcmode = 'CANCEL' ) THEN
    null;

  END IF;

EXCEPTION
  WHEN OTHERS THEN
    Wf_Core.Context('IGI_ITR_APPROVAL_PKG', 'approve_cc_line', itemtype, itemkey);
    IF ( l_unexp_level >=  l_debug_level) THEN
               FND_MESSAGE.SET_NAME('IGI','IGI_LOGGING_UNEXP_ERROR');
               FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
               FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
               FND_LOG.MESSAGE (l_unexp_level,'igi.plsql.igiitrwb.IGI_ITR_APPROVAL_PKG.approve_cc_line',TRUE);
    END IF;
    raise;
END approve_cc_line;


--
-- ****************************************************************************
--  Procedure Reject_cc_line
-- ****************************************************************************
--
PROCEDURE reject_cc_line (itemtype	IN VARCHAR2,
		          itemkey  	IN VARCHAR2,
		          actid	        IN NUMBER,
		          funcmode	IN VARCHAR2,
                          result        OUT NOCOPY VARCHAR2 ) IS
l_cross_charge_id	NUMBER;
l_cc_line_num           NUMBER;
BEGIN
  IF ( funcmode = 'RUN') THEN
    l_cross_charge_id :=  wf_engine.GetItemAttrNumber(
			itemtype  => itemtype,
			itemkey   => itemkey,
			aname     => 'CROSS_CHARGE_ID');

    l_cc_line_num :=  wf_engine.GetItemAttrNumber(
			itemtype  => itemtype,
			itemkey   => itemkey,
			aname     => 'CC_LINE_NUM');

-- change status of cross charge line to 'R' for 'Rejected by Receiver'

    UPDATE IGI_ITR_CHARGE_LINES
    SET    status_flag  = 'R'
    WHERE  it_header_id = l_cross_charge_id
    AND    it_line_num = l_cc_line_num;

  ELSIF ( funcmode = 'CANCEL' ) THEN
    null;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    Wf_Core.Context('IGI_ITR_APPROVAL_PKG', 'reject_cc_line', itemtype, itemkey);
    IF ( l_unexp_level >=  l_debug_level) THEN
               FND_MESSAGE.SET_NAME('IGI','IGI_LOGGING_UNEXP_ERROR');
               FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
               FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
               FND_LOG.MESSAGE (l_unexp_level,'igi.plsql.igiitrwb.IGI_ITR_APPROVAL_PKG.reject_cc_line',TRUE);
    END IF;
    raise;
END reject_cc_line;


--
-- ****************************************************************************
--  Procedure getmanager
-- ****************************************************************************
--
PROCEDURE getmanager( employee_id 	IN NUMBER,
                      manager_id	OUT NOCOPY NUMBER) IS
others                   EXCEPTION;
l_employee_id            NUMBER := employee_id;
BEGIN

  diagn_msg(l_state_level,'getmanager','getmanager: employee_id =' ||to_char(employee_id));


  SELECT supervisor_id
  INTO   manager_id
  FROM   GL_HR_EMPLOYEES_CURRENT_V
  WHERE  employee_id =  l_employee_id;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
     manager_id := NULL;
  WHEN OTHERS THEN
    Wf_Core.Context('IGI_ITR_APPROVAL_PKG', 'getmanager',
                     null, null, null );
    IF ( l_unexp_level >=  l_debug_level) THEN
               FND_MESSAGE.SET_NAME('IGI','IGI_LOGGING_UNEXP_ERROR');
               FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
               FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
               FND_LOG.MESSAGE (l_unexp_level,'igi.plsql.igiitrwb.IGI_ITR_APPROVAL_PKG.getmanager',TRUE);
    END IF;
    raise;
END getmanager;



--
-- ****************************************************************************
--  Procedure setpersonas
-- ****************************************************************************
--
PROCEDURE setpersonas( manager_id 	IN NUMBER,
                       item_type	IN VARCHAR2,
		       item_key	        IN VARCHAR2,
		       manager_target	IN VARCHAR2) IS
  l_manager_name		VARCHAR2(240);
  l_manager_display_name	VARCHAR2(240);
BEGIN

  diagn_msg(l_state_level,'setpersonas','Executing the setpersonas activity..');

  WF_DIRECTORY.GetUserName('PER',
			    manager_id,
			    l_manager_name,
			    l_manager_display_name);

  diagn_msg(l_state_level,'setpersonas','setpersonas: manager_name = ' ||l_manager_name );
  diagn_msg(l_state_level,'setpersonas','setpersonas: manager_display_name = ' ||l_manager_display_name );

  IF ( manager_target = 'MANAGER') THEN

    WF_ENGINE.SetItemAttrText( item_type,
			       item_key,
			       'MANAGER_ID',
			       manager_id);

    WF_ENGINE.SetItemAttrText( item_type,
			       item_key,
			       'MANAGER_NAME',
			       l_manager_name);

    WF_ENGINE.SetItemAttrText( item_type,
			       item_key,
			       'MANAGER_DISPLAY_NAME',
			       l_manager_display_name);

  ELSE

    WF_ENGINE.SetItemAttrText( item_type,
			       item_key,
			       'APPROVER_ID',
			       manager_id);

    WF_ENGINE.SetItemAttrText( item_type,
			       item_key,
			       'APPROVER_NAME',
			       l_manager_name);

    WF_ENGINE.SetItemAttrText( item_type,
			       item_key,
			       'APPROVER_DISPLAY_NAME',
			       l_manager_display_name);

  END IF;

EXCEPTION
  WHEN OTHERS THEN
    Wf_Core.Context('IGI_ITR_APPROVAL_PKG', 'setpersonas',
                      item_type,  item_key, null );
    IF ( l_unexp_level >=  l_debug_level) THEN
               FND_MESSAGE.SET_NAME('IGI','IGI_LOGGING_UNEXP_ERROR');
               FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
               FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
               FND_LOG.MESSAGE (l_unexp_level,'igi.plsql.igiitrwb.IGI_ITR_APPROVAL_PKG.setpersonas',TRUE);
    END IF;
    raise;
END setpersonas;


--
-- ****************************************************************************
--  Procedure getfinalapprover
--  The parameter l_approver_id_out was added for bug 2709021
--  for the nocopy changes
-- ****************************************************************************
--
PROCEDURE getfinalapprover( p_employee_id		IN NUMBER,
                            p_set_of_books_id           IN NUMBER,
		      	    p_approval_amount		IN NUMBER,
			    p_item_type			IN VARCHAR2,
		      	    p_final_approver_id		OUT NOCOPY NUMBER) IS
  l_approver_id			NUMBER;
  l_approval_limit              NUMBER;
  l_approver_id_out		NUMBER;
BEGIN

  GetManager(p_employee_id,
             l_approver_id);

  IF (l_approver_id IS NULL) THEN
      p_final_approver_id := NULL;
      return;
  END IF;

  LOOP
    l_approval_limit := get_authorization_limit(l_approver_id, p_set_of_books_id);

    IF (l_approval_limit >= p_approval_amount) THEN
      p_final_approver_id := l_approver_id;
      return;
    END IF;

    GetManager(l_approver_id,
               l_approver_id_out);

    IF (l_approver_id_out IS NULL) THEN
      p_final_approver_id := NULL;
      return;
    END IF;

  END LOOP;

EXCEPTION
  WHEN OTHERS THEN
    Wf_Core.Context('IGI_ITR_APPROVAL_PKG', 'getfinalapprover',
                     p_item_type, null, null );
    IF ( l_unexp_level >=  l_debug_level) THEN
               FND_MESSAGE.SET_NAME('IGI','IGI_LOGGING_UNEXP_ERROR');
               FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
               FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
               FND_LOG.MESSAGE (l_unexp_level,'igi.plsql.igiitrwb.IGI_ITR_APPROVAL_PKG.getfinalapprover',TRUE);
    END IF;
    raise;
END getfinalapprover;



--
-- ****************************************************************************
--  Procedure getapprover
-- ****************************************************************************
--
PROCEDURE getapprover( employee_id		IN NUMBER,
		       approval_amount		IN NUMBER,
		       item_type		IN VARCHAR2,
                       item_key                 IN VARCHAR2,
		       curr_approver_id	        IN NUMBER,
                       find_approver_method	IN VARCHAR2,
		       next_approver_id	        IN OUT NOCOPY NUMBER ) IS
l_error_message        VARCHAR2(2000);
l_set_of_books_id      NUMBER;
l_next_approver_id_old NUMBER;

BEGIN

  l_next_approver_id_old := next_approver_id;

  -- Get set of books id
  l_set_of_books_id := wf_engine.GetItemAttrNumber(
                itemtype  => item_type,
                itemkey   => item_key,
                aname     => 'SET_OF_BOOKS_ID');

  IF ( find_approver_method = 'S') THEN

    IF ( next_approver_id IS NULL) THEN

      diagn_msg(l_state_level,'getapprover','Getapprover: Calling getmanager with method equal S ');

      IGI_ITR_APPROVAL_PKG.getmanager( curr_approver_id,
                 		        next_approver_id);

    END IF;

  ELSIF ( find_approver_method = 'D') THEN

    diagn_msg(l_state_level,'getapprover','Getapprover: Calling getfinalapprover with method equal D');

    IGI_ITR_APPROVAL_PKG.getfinalapprover( employee_id,
                                            l_set_of_books_id,
                     		            approval_amount,
				            item_type,
                     		            next_approver_id);


  ELSIF ( find_approver_method = 'L') THEN

    IF ( next_approver_id IS NULL) THEN

      diagn_msg(l_state_level,'getapprover','Getapprover: Calling getfinalapprover with method equal L');

      IGI_ITR_APPROVAL_PKG.getfinalapprover( curr_approver_id,
                                              l_set_of_books_id,
                       			      approval_amount,
					      item_type,
                       			      next_approver_id);
    END IF;
  ELSE
    FND_MESSAGE.Set_Name('SQLGL', 'GL_WF_INVALID_APPROVER_METHOD');
    l_error_message := FND_MESSAGE.Get;

        IF( l_error_level >=  l_debug_level) THEN
	    FND_LOG.MESSAGE(l_error_level,'igi.plsql.igiitrwb.IGI_ITR_APPROVAL_PKG.getapprover.msg1', FALSE);
	END IF;
    wf_engine.SetItemAttrText( item_type,
			       item_key,
			       'ERROR_MESSAGE',
			       l_error_message);
    return;

  END IF;

EXCEPTION
  WHEN OTHERS THEN
    next_approver_id := l_next_approver_id_old;
    Wf_Core.Context('IGI_ITR_APPROVAL_PKG', 'getapprover',
                     null, null, null );
    IF ( l_unexp_level >=  l_debug_level) THEN
               FND_MESSAGE.SET_NAME('IGI','IGI_LOGGING_UNEXP_ERROR');
               FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
               FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
               FND_LOG.MESSAGE (l_unexp_level,'igi.plsql.igiitrwb.IGI_ITR_APPROVAL_PKG.getapprover.msg2',TRUE);
    END IF;
    raise;
END getapprover;


--
-- ****************************************************************************
--  Procedure find_approver
-- ****************************************************************************
--
PROCEDURE find_approver( item_type	IN VARCHAR2,
		         item_key	IN VARCHAR2,
		         actid		IN NUMBER,
		         funmode	IN VARCHAR2,
		         result		OUT NOCOPY VARCHAR2) IS
  l_employee_id			NUMBER;
  l_approval_amount		NUMBER;
  l_sob_id                      NUMBER;
  l_curr_approver_id		NUMBER		:= NULL;
  l_next_approver_id		NUMBER		:= NULL;
  l_dir_manager_id		NUMBER		:= NULL;
  l_find_approver_method	VARCHAR2(240);
  l_defined                     BOOLEAN;
  l_find_approver_counter	NUMBER;
  l_error_message               VARCHAR2(2000);
BEGIN

  IF ( funmode = 'RUN') THEN
    diagn_msg(l_state_level,'find_approver','Entering Find_Approver activity');

    l_employee_id := wf_engine.GetItemAttrNumber( item_type,
						  item_key,
						  'EMPLOYEE_ID');

    l_approval_amount := wf_engine.GetItemAttrNumber( item_type,
						      item_key,
						      'CC_LINE_AMOUNT');


    l_curr_approver_id := wf_engine.GetItemAttrNumber( item_type,
					  	       item_key,
					  	       'APPROVER_ID');

    l_sob_id := wf_engine.GetItemAttrNumber( item_type,
			                     item_key,
					     'SET_OF_BOOKS_ID');


    -- Get the value for the find approver method
       SELECT find_approver_method
       INTO   l_find_approver_method
       FROM   igi_itr_charge_setup
       WHERE  set_of_books_id = l_sob_id;


    IF (l_find_approver_method IS NULL) THEN
      l_find_approver_method := 'S';
    END IF;

    l_find_approver_counter := wf_engine.GetItemAttrNumber(
                                        item_type,
			                item_key,
				        'FIND_APPROVER_COUNTER');

    IF (l_find_approver_counter = 0) THEN

      diagn_msg(l_state_level,'find_approver','Find_Approver activity is called for the first time. ');

      IGI_ITR_APPROVAL_PKG.getmanager(l_employee_id,
	       			       l_dir_manager_id);

      IGI_ITR_APPROVAL_PKG.setpersonas(l_dir_manager_id,
	        		        item_type,
	        		        item_key,
	        		        'MANAGER');

      IF (l_dir_manager_id IS NOT NULL) THEN
        l_next_approver_id := l_dir_manager_id;
      ELSE
        FND_MESSAGE.Set_Name('SQLGL', 'GL_WF_CANNOT_FIND_MANAGER');
        l_error_message := FND_MESSAGE.Get;
	IF( l_error_level >=  l_debug_level) THEN
	    FND_LOG.MESSAGE(l_error_level,'igi.plsql.igiitrwb.IGI_ITR_APPROVAL_PKG.getapprover.msg1', FALSE);
	END IF;
	wf_engine.SetItemAttrText( item_type,
				   item_key,
				   'ERROR_MESSAGE',
				   l_error_message);

        result := 'COMPLETE:N';
      END IF;


    END IF;

    IF ((l_curr_approver_id IS NOT NULL) OR
	(l_find_approver_method = 'D')) THEN

      diagn_msg(l_state_level,'find_approver','Find_Approver: Calling Get Approver ');

      GetApprover(l_employee_id,
		  l_approval_amount,
		  item_type,
                  item_key,
		  l_curr_approver_id,
       		  l_find_approver_method,
		  l_next_approver_id );

    END IF;

    IF (l_next_approver_id IS NULL) THEN
      FND_MESSAGE.Set_Name('SQLGL', 'GL_WF_CANNOT_FIND_APPROVER');
      l_error_message := FND_MESSAGE.Get;
        IF( l_error_level >=  l_debug_level) THEN
	    FND_LOG.MESSAGE(l_error_level,'igi.plsql.igiitrwb.IGI_ITR_APPROVAL_PKG.getapprover.msg2', FALSE);
	END IF;
      WF_ENGINE.SetItemAttrText( item_type,
				 item_key,
				'ERROR_MESSAGE',
				l_error_message);

      result := 'COMPLETE:N';

    ELSE

      IGI_ITR_APPROVAL_PKG.setpersonas(l_next_approver_id,
	      	  		      item_type,
	      	  		      item_key,
	      	  		      'APPROVER');

      WF_ENGINE.SetItemAttrNumber( item_type,
				   item_key,
				   'FIND_APPROVER_COUNTER',
				   l_find_approver_counter+1);

      result := 'COMPLETE:Y';

    END IF;

  ELSIF ( funmode = 'CANCEL') THEN
    NULL;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    result := NULL;
    Wf_Core.Context('IGI_ITR_APPROVAL_PKG', 'Find_Approver',
                      item_type,  item_key, null );
    IF ( l_unexp_level >=  l_debug_level) THEN
               FND_MESSAGE.SET_NAME('IGI','IGI_LOGGING_UNEXP_ERROR');
               FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
               FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
               FND_LOG.MESSAGE (l_unexp_level,'igi.plsql.igiitrwb.IGI_ITR_APPROVAL_PKG.find_approver',TRUE);
    END IF;
    raise;

END find_approver;


--
-- ****************************************************************************
--  Procedure record_forward_from_info
-- ****************************************************************************
--
PROCEDURE record_forward_from_info( p_item_type	    IN VARCHAR2,
		     	  	    p_item_key	    IN VARCHAR2,
		     	  	    p_actid	    IN NUMBER,
		     	  	    p_funmode       IN VARCHAR2,
		     	            p_result	    OUT NOCOPY VARCHAR2) IS
  l_approver_id			NUMBER;
  l_approver_name		VARCHAR2(240);
  l_approver_display_name  	VARCHAR2(240);
BEGIN

  IF (p_funmode = 'RUN') THEN

    l_approver_id := WF_ENGINE.GetItemAttrNumber(p_item_type,
					         p_item_key,
					         'APPROVER_ID');

    l_approver_name := WF_ENGINE.GetItemAttrText(p_item_type,
					        p_item_key,
					        'APPROVER_NAME');

    l_approver_display_name := WF_ENGINE.GetItemAttrText(p_item_type,
					        	 p_item_key,
					                 'APPROVER_DISPLAY_NAME');

    WF_ENGINE.SetItemAttrNumber(p_item_type,
			        p_item_key,
			        'FORWARD_FROM_ID',
			        l_approver_id);

    WF_ENGINE.SetItemAttrText(p_item_type,
			      p_item_key,
			      'FORWARD_FROM_NAME',
			      l_approver_name);

    WF_ENGINE.SetItemAttrText(p_item_type,
			      p_item_key,
			      'FORWARD_FROM_DISPLAY_NAME',
			      l_approver_display_name);

  ELSIF (p_funmode = 'CANCEL') THEN
    NULL;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    Wf_Core.Context('IGI_ITR_APPROVAL_PKG', 'record_forward_from_info',
                     p_item_type, p_item_key, to_char(p_actid) );
    IF ( l_unexp_level >=  l_debug_level) THEN
               FND_MESSAGE.SET_NAME('IGI','IGI_LOGGING_UNEXP_ERROR');
               FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
               FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
               FND_LOG.MESSAGE (l_unexp_level,'igi.plsql.igiitrwb.IGI_ITR_APPROVAL_PKG.record_forward_from_info',TRUE);
    END IF;
    raise;
END record_forward_from_info;



--
-- ****************************************************************************
--  PROCEDURE mgr_equalto_aprv
-- ****************************************************************************
--
PROCEDURE mgr_equalto_aprv(p_item_type		IN VARCHAR2,
		     	   p_item_key		IN VARCHAR2,
		     	   p_actid		IN NUMBER,
		     	   p_funmode		IN VARCHAR2,
		     	   p_result		OUT NOCOPY VARCHAR2) IS
  l_approver_id			NUMBER;
  l_manager_id			NUMBER;
BEGIN

  IF (p_funmode = 'RUN') THEN

    l_approver_id := WF_ENGINE.GetItemAttrNumber(p_item_type,
					         p_item_key,
					         'APPROVER_ID');

    l_manager_id := WF_ENGINE.GetItemAttrNumber(p_item_type,
					         p_item_key,
					         'MANAGER_ID');

    IF (l_approver_id <> l_manager_id) THEN
      p_result := 'COMPLETE:N';
    ELSE
      p_result := 'COMPLETE:Y';
    END IF;

  ELSIF (p_funmode = 'CANCEL') THEN
    NULL;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    p_result := NULL;
    Wf_Core.Context('IGI_ITR_APPROVAL_PKG', 'mgr_equalto_aprv',
                     p_item_type, p_item_key, to_char(p_actid));
    IF ( l_unexp_level >=  l_debug_level) THEN
               FND_MESSAGE.SET_NAME('IGI','IGI_LOGGING_UNEXP_ERROR');
               FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
               FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
               FND_LOG.MESSAGE (l_unexp_level,'igi.plsql.igiitrwb.IGI_ITR_APPROVAL_PKG.mgr_equalto_aprv',TRUE);
    END IF;
    raise;
END mgr_equalto_aprv;




--
-- *****************************************************************************
--   PROCEDURE First_Approver
-- *****************************************************************************
--
PROCEDURE first_approver(p_item_type	IN VARCHAR2,
		     	p_item_key	IN VARCHAR2,
		     	p_actid		IN NUMBER,
		     	p_funmode	IN VARCHAR2,
		     	p_result	OUT NOCOPY VARCHAR2) IS
  l_find_approver_counter		NUMBER;
BEGIN

  IF (p_funmode = 'RUN') THEN

    diagn_msg(l_state_level,'first_approver','First_Approver: Retrieving Find_Approver_Counter Item Attribute');

    l_find_approver_counter := WF_ENGINE.GetItemAttrNumber(p_item_type,
						         p_item_key,
						         'FIND_APPROVER_COUNTER');

    -- Set the approver comment attribute to null
    WF_ENGINE.SetItemAttrText(p_item_type,
			      p_item_key,
			      'APPROVER_COMMENT',
			      '');

    IF (l_find_approver_counter = 1) THEN
      p_result := 'COMPLETE:Y';
    ELSE
      p_result := 'COMPLETE:N';
    END IF;

  ELSIF (p_funmode = 'CANCEL') THEN
    NULL;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    p_result := NULL;
    Wf_Core.Context('IGI_ITR_APPROVAL_PKG', 'first_approver',
                     p_item_type, p_item_key, to_char(p_actid));
    IF ( l_unexp_level >=  l_debug_level) THEN
               FND_MESSAGE.SET_NAME('IGI','IGI_LOGGING_UNEXP_ERROR');
               FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
               FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
               FND_LOG.MESSAGE (l_unexp_level,'igi.plsql.igiitrwb.IGI_ITR_APPROVAL_PKG.first_approver',TRUE);
    END IF;
    raise;
END first_approver;


--
-- *****************************************************************************
--   Set_Employee_Name_to_Prep
-- *****************************************************************************
--
PROCEDURE set_employee_name_to_prep(itemtype	IN VARCHAR2,
		                    itemkey  	IN VARCHAR2,
		                    actid	IN NUMBER,
		                    funcmode	IN VARCHAR2,
                                    result     OUT NOCOPY VARCHAR2 ) IS
l_preparer_id	NUMBER;
l_preparer_name VARCHAR2(240);
l_preparer_display_name  VARCHAR2(240);
BEGIN
  IF ( funcmode = 'RUN') THEN
    l_preparer_id :=  wf_engine.GetItemAttrNumber( itemtype  => itemtype,
			    			   itemkey   => itemkey,
			    			   aname     => 'PREPARER_ID');
    l_preparer_name := wf_engine.GetItemAttrText( itemtype  => itemtype,
			    			  itemkey   => itemkey,
			    			  aname     => 'PREPARER_NAME');
    l_preparer_display_name := wf_engine.GetItemAttrText( itemtype  => itemtype,
			    			  itemkey   => itemkey,
			    			  aname     => 'PREPARER_DISPLAY_NAME');
    wf_engine.SetItemAttrNumber( itemtype  => itemtype,
			         itemkey   => itemkey,
  		 	      	 aname 	   => 'EMPLOYEE_ID',
			      	 avalue    => l_preparer_id );
    wf_engine.SetItemAttrText( itemtype	 => itemtype,
			       itemkey   => itemkey,
  		 	       aname 	 => 'EMPLOYEE_NAME',
			       avalue 	 => l_preparer_name );
    wf_engine.SetItemAttrText( itemtype	 => itemtype,
			       itemkey   => itemkey,
  		 	       aname 	 => 'EMPLOYEE_DISPLAY_NAME',
			       avalue 	 => l_preparer_display_name );
    diagn_msg(l_state_level,'set_employee_name_to_prep','Employee name set to preparer for cross charge line ');
  ELSIF ( funcmode = 'CANCEL' ) THEN
	null;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    Wf_Core.Context('IGI_ITR_APPROVAL_PKG', 'set_employee_name_to_prep', itemtype, itemkey);
    IF ( l_unexp_level >=  l_debug_level) THEN
               FND_MESSAGE.SET_NAME('IGI','IGI_LOGGING_UNEXP_ERROR');
               FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
               FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
               FND_LOG.MESSAGE (l_unexp_level,'igi.plsql.igiitrwb.IGI_ITR_APPROVAL_PKG.set_employee_name_to_prep',TRUE);
    END IF;
    raise;
END set_employee_name_to_prep;


--
-- *****************************************************************************
--   Set_Employee_Name_to_Rec
-- *****************************************************************************
--
PROCEDURE set_employee_name_to_rec (itemtype	IN VARCHAR2,
		                    itemkey  	IN VARCHAR2,
		                    actid	IN NUMBER,
		                    funcmode	IN VARCHAR2,
                                    result     OUT NOCOPY VARCHAR2 ) IS
l_receiver_id	NUMBER;
l_receiver_name VARCHAR2(240);
l_receiver_display_name  VARCHAR2(240);
BEGIN
  IF ( funcmode = 'RUN') THEN
    l_receiver_id :=  wf_engine.GetItemAttrNumber( itemtype  => itemtype,
			    			   itemkey   => itemkey,
			    			   aname     => 'RECEIVER_ID');
    l_receiver_name := wf_engine.GetItemAttrText( itemtype  => itemtype,
			    			  itemkey   => itemkey,
			    			  aname     => 'RECEIVER_NAME');
    l_receiver_display_name := wf_engine.GetItemAttrText( itemtype  => itemtype,
			    			  itemkey   => itemkey,
			    			  aname     => 'RECEIVER_DISPLAY_NAME');
    wf_engine.SetItemAttrNumber( itemtype  => itemtype,
			         itemkey   => itemkey,
  		 	      	 aname 	   => 'EMPLOYEE_ID',
			      	 avalue    => l_receiver_id );
    wf_engine.SetItemAttrText( itemtype	 => itemtype,
			       itemkey   => itemkey,
  		 	       aname 	 => 'EMPLOYEE_NAME',
			       avalue 	 => l_receiver_name );
    wf_engine.SetItemAttrText( itemtype	 => itemtype,
			       itemkey   => itemkey,
  		 	       aname 	 => 'EMPLOYEE_DISPLAY_NAME',
			       avalue 	 => l_receiver_display_name );
    diagn_msg(l_state_level,'set_employee_name_to_rec','Employee name set to receiver for cross charge line ');
  ELSIF ( funcmode = 'CANCEL' ) THEN
	null;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    Wf_Core.Context('IGI_ITR_APPROVAL_PKG', 'set_employee_name_to_rec', itemtype, itemkey);
    IF ( l_unexp_level >=  l_debug_level) THEN
               FND_MESSAGE.SET_NAME('IGI','IGI_LOGGING_UNEXP_ERROR');
               FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
               FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
               FND_LOG.MESSAGE (l_unexp_level,'igi.plsql.igiitrwb.IGI_ITR_APPROVAL_PKG.set_employee_name_to_rec',TRUE);
    END IF;
    raise;
END set_employee_name_to_rec;



--
-- *****************************************************************************
--   Reset_Approval_Attributes
-- *****************************************************************************
--
PROCEDURE reset_approval_attributes(itemtype	IN VARCHAR2,
		                    itemkey  	IN VARCHAR2,
		                    actid	IN NUMBER,
		                    funcmode	IN VARCHAR2,
                                    result     OUT NOCOPY VARCHAR2 ) IS
BEGIN
  IF ( funcmode = 'RUN') THEN
 -- setting manager attributes to null
    wf_engine.SetItemAttrNumber( itemtype  => itemtype,
			         itemkey   => itemkey,
  		 	      	 aname 	   => 'MANAGER_ID',
			      	 avalue    => '' );
    wf_engine.SetItemAttrText( itemtype	 => itemtype,
			       itemkey   => itemkey,
  		 	       aname 	 => 'MANAGER_NAME',
			       avalue 	 => '' );
    wf_engine.SetItemAttrText( itemtype	 => itemtype,
			       itemkey   => itemkey,
  		 	       aname 	 => 'MANAGER_DISPLAY_NAME',
			       avalue 	 => '' );


 -- setting forward_from attributes to null
    wf_engine.SetItemAttrNumber( itemtype  => itemtype,
			         itemkey   => itemkey,
  		 	      	 aname 	   => 'FORWARD_FROM_ID',
			      	 avalue    => '' );
    wf_engine.SetItemAttrText( itemtype	 => itemtype,
			       itemkey   => itemkey,
  		 	       aname 	 => 'FORWARD_FROM_NAME',
			       avalue 	 => '' );
    wf_engine.SetItemAttrText( itemtype	 => itemtype,
			       itemkey   => itemkey,
  		 	       aname 	 => 'FORWARD_FROM_DISPLAY_NAME',
			       avalue 	 => '' );


 -- setting approver attributes to null
    wf_engine.SetItemAttrNumber( itemtype  => itemtype,
			         itemkey   => itemkey,
  		 	      	 aname 	   => 'APPROVER_ID',
			      	 avalue    => '' );
    wf_engine.SetItemAttrText( itemtype	 => itemtype,
			       itemkey   => itemkey,
  		 	       aname 	 => 'APPROVER_NAME',
			       avalue 	 => '' );
    wf_engine.SetItemAttrText( itemtype	 => itemtype,
			       itemkey   => itemkey,
  		 	       aname 	 => 'APPROVER_DISPLAY_NAME',
			       avalue 	 => '' );

 -- setting find approver counter attribute to 0
    wf_engine.SetItemAttrNumber( itemtype  => itemtype,
			         itemkey   => itemkey,
  		 	      	 aname 	   => 'FIND_APPROVER_COUNTER',
			      	 avalue    => 0 );

    diagn_msg(l_state_level,'reset_approval_attributes','Reset manager, forward_from and approver attributes');
  ELSIF ( funcmode = 'CANCEL' ) THEN
	null;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    Wf_Core.Context('IGI_ITR_APPROVAL_PKG', 'reset_approval_attributes', itemtype, itemkey);
    IF ( l_unexp_level >=  l_debug_level) THEN
               FND_MESSAGE.SET_NAME('IGI','IGI_LOGGING_UNEXP_ERROR');
               FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
               FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
               FND_LOG.MESSAGE (l_unexp_level,'igi.plsql.igiitrwb.IGI_ITR_APPROVAL_PKG.reset_approval_attributes',TRUE);
    END IF;
    raise;
END reset_approval_attributes;



--

END IGI_ITR_APPROVAL_PKG;

/
