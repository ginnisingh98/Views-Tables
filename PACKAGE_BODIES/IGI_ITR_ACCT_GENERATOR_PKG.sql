--------------------------------------------------------
--  DDL for Package Body IGI_ITR_ACCT_GENERATOR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGI_ITR_ACCT_GENERATOR_PKG" AS
-- $Header: igiitrrb.pls 120.5.12000000.1 2007/09/12 10:32:32 mbremkum ship $
--



    l_debug_level number	:=	FND_LOG.G_CURRENT_RUNTIME_LEVEL;
    l_state_level number	:=	FND_LOG.LEVEL_STATEMENT;
    l_proc_level number    	:=	FND_LOG.LEVEL_PROCEDURE;
    l_event_level number	:=	FND_LOG.LEVEL_EVENT;
    l_excep_level number	:=	FND_LOG.LEVEL_EXCEPTION;
    l_error_level number	:=	FND_LOG.LEVEL_ERROR;
    l_unexp_level number	:=	FND_LOG.LEVEL_UNEXPECTED;
    l_path      VARCHAR2(50):= 'IGI.PLSQL.igiitrrb.IGI_ITR_ACCT_GENERATOR_PKG.';


-- ****************************************************************************
-- Private procedure: Display diagnostic message
-- ****************************************************************************
PROCEDURE diagn_msg ( p_level IN NUMBER, p_path IN VARCHAR2, p_mesg IN VARCHAR2 ) IS
BEGIN
        IF (p_level >=  l_debug_level ) THEN
           FND_LOG.STRING (p_level , l_path || p_path , p_mesg );
        END IF;
END;



-- ****************************************************************************
--     Start_Acct_Generator_Workflow
-- ****************************************************************************
FUNCTION start_acct_generator_workflow  (p_coa_id               NUMBER,
                                         p_sob_id               NUMBER,
                                         p_acct_type            VARCHAR2,
                                         p_charge_center_id     NUMBER,
                                         p_preparer_id          NUMBER,
                                         p_charge_service_id    NUMBER,
                                         p_cost_center_value    VARCHAR2,
                                         p_additional_seg_value VARCHAR2,
                                         x_return_ccid          IN OUT NOCOPY NUMBER,
                                         x_concat_segs          IN OUT NOCOPY VARCHAR2)
return boolean
IS



--	Local variables
	l_itemtype 		VARCHAR2(8) := 'ITRWKFAG';
	l_itemkey  		VARCHAR2(50) ;

        x_appl_short_name       varchar2(40);
        x_flex_field_code       varchar2(150);
        x_flex_field_struc_num  number;    -- p_coa_id

        result                  BOOLEAN;
--        x_return_ccid           number;
--        x_concat_segs           varchar2(2000);
        x_concat_ids            varchar2(2000);
        x_concat_descrs         varchar2(2000);
        x_errmsg                varchar2(2000);

        l_return_ccid           number;
        p_char_date               varchar2(27);

        l_return_ccid_old       number;
        l_concat_segs_old       varchar2(2000);

BEGIN

  diagn_msg(l_state_level,'start_acct_generator_workflow','**** Beginning ITR account generation ****');

  /* ssemwal for NOCOPY */
  /* added l_return_ccid_old, l_concat_segs_old */

  l_return_ccid_old := x_return_ccid;
  l_concat_segs_old := x_concat_segs;

  x_appl_short_name := 'SQLGL';
  x_flex_field_code := 'GL#';
  x_flex_field_struc_num := p_coa_id;

  diagn_msg(l_state_level,'start_acct_generator_workflow','Calling fnd_flex_workflow.initialize to create workflow process');

  --  The procedure fnd_flex_workflow.initialize will fetch an itemkey and
  --  create the workflow process. The process will be 'started' later

  l_itemkey := FND_FLEX_WORKFLOW.INITIALIZE (x_appl_short_name
                                            ,x_flex_field_code
                                            ,x_flex_field_struc_num
                                            ,l_itemtype);

  diagn_msg(l_state_level,'start_acct_generator_workflow','Item Key = '||l_itemkey);

  /* initialize the workflow item attributes */

	--  Set set of books id attribute
	wf_engine.SetItemAttrNumber( itemtype	=> l_itemtype,
			      	     itemkey  	=> l_itemkey,
  		 	      	     aname 	=> 'SOB_ID',
			      	     avalue 	=> p_sob_id );
--        diagn_msg(l_state_level,'start_acct_generator_workflow','Attribute SOB_ID set to' ||(p_sob_id));

	--  Set chart of accounts id attribute
	wf_engine.SetItemAttrNumber( itemtype	=> l_itemtype,
			      	     itemkey  	=> l_itemkey,
  		 	      	     aname 	=> 'COA_ID',
			      	     avalue 	=> p_coa_id );
--        diagn_msg('Attribute COA_ID set to' ||(p_coa_id));


	--  Set code combination level (header or line)
	wf_engine.SetItemAttrText( itemtype	=> l_itemtype,
			      	     itemkey  	=> l_itemkey,
  		 	      	     aname 	=> 'ACCT_TYPE',
			      	     avalue 	=> p_acct_type );
--        diagn_msg('Attribute ACCT_TYPE set to' ||(p_acct_type));


	--  Set charge_center_id (of preparer)
	wf_engine.SetItemAttrNumber( itemtype	=> l_itemtype,
			      	     itemkey  	=> l_itemkey,
  		 	      	     aname 	=> 'CHARGE_CENTER_ID',
			      	     avalue 	=> p_charge_center_id );
--        diagn_msg('Attribute CHARGE_CENTER_ID set to' ||to_char(p_charge_center_id));

	--  Set charge_service_id
	wf_engine.SetItemAttrNumber( itemtype	=> l_itemtype,
			      	     itemkey  	=> l_itemkey,
  		 	      	     aname 	=> 'CHARGE_SERVICE_ID',
			      	     avalue 	=> p_charge_service_id );
--        diagn_msg('Attribute CHARGE_SERVICE_ID set to' ||to_char(p_charge_service_id));

	--  Set cost_center_value (if chosen by preparer)
	wf_engine.SetItemAttrText ( itemtype	=> l_itemtype,
			      	     itemkey  	=> l_itemkey,
  		 	      	     aname 	=> 'COST_CENTER_VALUE',
			      	     avalue 	=> p_cost_center_value );
--        diagn_msg('Attribute COST_CENTER_VALUE set to' ||p_cost_center_value);

	--  Set additional_segment_value (if chosen by preparer)
	wf_engine.SetItemAttrText  ( itemtype	=> l_itemtype,
			      	     itemkey  	=> l_itemkey,
  		 	      	     aname 	=> 'ADDITIONAL_SEG_VALUE',
			      	     avalue 	=> p_additional_seg_value );
--        diagn_msg('Attribute ADDITIONAL_SEG_VALUE set to' ||p_additional_seg_value);

	--  Set preparer attribute
	wf_engine.SetItemAttrNumber( itemtype	=> l_itemtype,
			      	     itemkey  	=> l_itemkey,
  		 	      	     aname 	=> 'PREPARER_ID',
			      	     avalue 	=> p_preparer_id );
--        diagn_msg('Attribute PREPARER_ID set to' ||to_char(p_preparer_id));

       -- Once all the attributes have been set, call the AOL function to start        -- the workflow process and retrieve the results


        diagn_msg(l_state_level,'start_acct_generator_workflow','fnd_flex_workflow.generate called');

        result := FND_FLEX_WORKFLOW.generate('ITRWKFAG',
                                              l_itemkey,
                                              x_return_ccid,
                                              x_concat_segs,
                                              x_concat_ids,
                                              x_concat_descrs,
                                              x_errmsg);

        IF result THEN
        --  diagn_msg('Successful.  Ccid = '||to_char(x_return_ccid));
        --  diagn_msg('Concat Segs =   '||x_concat_segs);

          IF (x_return_ccid = -1) THEN
            select to_char(sysdate,'DD-MON-RRRR')
            into   p_char_date
            FROM   dual;

            l_return_ccid := FND_FLEX_EXT.get_ccid(
                                    'SQLGL',
                                    'GL#',
                                    p_coa_id,
                                    p_char_date,
                                    x_concat_segs);
             IF (l_return_ccid = 0) THEN
               diagn_msg(l_error_level,'start_acct_generator_workflow','No ccid found');
               return FALSE;
             ELSE
               x_return_ccid := l_return_ccid;
               diagn_msg(l_state_level,'start_acct_generator_workflow','return ccid = '||x_return_ccid);
             END IF;

           END IF;  /* if x_return_ccid = -1  */

          diagn_msg(l_state_level,'start_acct_generator_workflow','return ccid = '||x_return_ccid);
          RETURN result;
        ELSE
         diagn_msg(l_error_level,'start_acct_generator_workflow','Unsuccessful');
         RETURN result;
        END IF;


EXCEPTION
  WHEN OTHERS THEN
    x_return_ccid := l_return_ccid_old;
    x_concat_segs := l_concat_segs_old;
    Wf_Core.Context('IGI_ITR_ACCT_GENERATOR_PKG', 'start_acct_generator_workflow', l_itemtype, l_itemkey);
    IF ( l_unexp_level >=  l_debug_level) THEN
	       FND_MESSAGE.SET_NAME('IGI','IGI_LOGGING_UNEXP_ERROR');
               FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
               FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
	       FND_LOG.MESSAGE (l_unexp_level,'igi.plsql.igiitrrb.IGI_ITR_ACCT_GENERATOR_PKG.start_acct_generator_workflow',TRUE);
    END IF;
     raise;

END start_acct_generator_workflow;


--
--****************************************************************************
--   account_type
-- *****************************************************************************
--

  --
  -- Procedure
  --   account_type
  -- Purpose
  --   Retrieve the account type for which the code combination is required
  --   i.e. the creating charge center's account (Creation account)
  --   or the receiving charge center's account (Receiving account)
  --   This is important because creation and receiving combinations
  --   are generated using different rules.
  -- History
  --  03-NOV-2000   S Brewer    Created.
  -- Arguments
  --   itemtype   	   Workflow item type (ITR Account Generator)
  --   itemkey    	   fnd flex workflow item key
  --   actid		   ID of activity, provided by workflow engine
  --			     (not used in this procedure)
  --   funcmode		   Function mode (RUN or CANCEL)
  --   result              Result code of the activity
  -- Example
  --   N/A (not user-callable)
  --
  -- Notes
  --   This procedure is called from the Oracle Workflow engine
  --   It retrieves the account type for which the code combination
  --   is required, which is then used to determine which process the
  --   workflow should call next
  --
PROCEDURE account_type         (	itemtype	IN VARCHAR2,
		     	        	itemkey		IN VARCHAR2,
                       	         	actid      	IN NUMBER,
                         		funcmode    	IN VARCHAR2,
                                        result          OUT NOCOPY VARCHAR2 ) IS

l_acct_type VARCHAR2(1);

BEGIN

  IF ( funcmode = 'RUN'  ) THEN

    diagn_msg(l_state_level,'account_type','Procedure account type being executed');
    -- Get acct_type
    l_acct_type  := wf_engine.GetItemAttrText(
	            itemtype  => itemtype,
		    itemkey   => itemkey,
		    aname     => 'ACCT_TYPE');


    diagn_msg(l_state_level,'account_type','Account type retrieved : '||l_acct_type);
    IF l_acct_type = 'C' THEN
      result := 'COMPLETE:C';
      return;
    ELSIF l_acct_type = 'R' THEN
      result := 'COMPLETE:R';
      return;
   -- ELSE exception;
    END IF;

  ELSIF ( funcmode = 'CANCEL' ) THEN
   null;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    result := null;
    Wf_Core.Context('IGI_ITR_ACCT_GENERATOR_PKG','account_type', itemtype, itemkey);
    IF ( l_unexp_level >=  l_debug_level) THEN
               FND_MESSAGE.SET_NAME('IGI','IGI_LOGGING_UNEXP_ERROR');
               FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
               FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
               FND_LOG.MESSAGE (l_unexp_level,'igi.plsql.igiitrrb.IGI_ITR_ACCT_GENERATOR_PKG.account_type',TRUE);
    END IF;

  raise;
END account_type;


--
-- *****************************************************************************
--   Fetch_Creation_Account
-- *****************************************************************************
--
PROCEDURE fetch_creation_account(itemtype	IN VARCHAR2,
		                 itemkey  	IN VARCHAR2,
			         actid	        IN NUMBER,
			         funcmode	IN VARCHAR2,
                                 result         OUT NOCOPY VARCHAR2 ) IS


l_charge_center_id      NUMBER;
l_charge_service_id     NUMBER;
l_creation_ccid         NUMBER;

--
BEGIN

  IF ( funcmode = 'RUN'  ) THEN
  diagn_msg(l_state_level,'account_type','Procedure fetch_creation_account being executed');

      -- Get charge center ID for the creator
      l_charge_center_id := wf_engine.GetItemAttrNumber(
		itemtype  => itemtype,
		itemkey   => itemkey,
		aname     => 'CHARGE_CENTER_ID');

      -- Get service type ID chosen by the user
      l_charge_service_id := wf_engine.GetItemAttrNumber(
                  itemtype => itemtype,
                  itemkey  => itemkey,
                  aname    => 'CHARGE_SERVICE_ID');

   --  using the charge center and the charge service type chosen by the user
   --  retrieve the creation charge center's service type account
     SELECT creation_ccid
     INTO   l_creation_ccid
     FROM   igi_itr_charge_service serv
     WHERE  serv.charge_center_id = l_charge_center_id
     AND    serv.charge_service_id = l_charge_service_id
     AND    sysdate BETWEEN nvl(serv.start_date,sysdate)
                    AND nvl(serv.end_date,sysdate);


    diagn_msg(l_state_level,'account_type','Retrieved creation ccid: '||to_char(l_creation_ccid)||
       ' for charge center '||to_char(l_charge_center_id)||
       ' and charge_service_id '||to_char(l_charge_service_id));

   --  set workflow attribute
	wf_engine.SetItemAttrNumber ( itemtype	=> itemtype,
			      	      itemkey  	=> itemkey,
  		 	      	      aname 	=> 'CREATION_CCID',
			      	      avalue 	=> l_creation_ccid);

    IF l_creation_ccid is not null THEN
      result := 'COMPLETE:SUCCESS';
      return;
    ELSE
      result := 'COMPLETE:FAILURE';
      return;
    END IF;


  ELSIF ( funcmode = 'CANCEL' ) THEN
	null;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    result := null;
    Wf_Core.Context('IGI_ITR_ACCT_GENERATOR_PKG', 'fetch_creation_account', itemtype, itemkey);
    IF ( l_unexp_level >=  l_debug_level) THEN
               FND_MESSAGE.SET_NAME('IGI','IGI_LOGGING_UNEXP_ERROR');
               FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
               FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
               FND_LOG.MESSAGE (l_unexp_level,'igi.plsql.igiitrrb.IGI_ITR_ACCT_GENERATOR_PKG.fetch_creation_account',TRUE);
    END IF;

  raise;

END fetch_creation_account;



--
-- *****************************************************************************
--   Find_No_Of_Segs
-- *****************************************************************************
--
PROCEDURE find_no_of_segs ( itemtype	IN VARCHAR2,
		            itemkey  	IN VARCHAR2,
		            actid   	IN NUMBER,
		            funcmode	IN VARCHAR2,
                            result     OUT NOCOPY VARCHAR2 ) IS

l_coa_id NUMBER;
l_no_of_segs NUMBER;
l_loop_limit NUMBER;


BEGIN
  IF ( funcmode = 'RUN') THEN
--    diagn_msg('Procedure find_no_of_segs being executed');


   -- fetch the chart of accounts id to be used for finding the number of
   -- segments
    l_coa_id := wf_engine.GetItemAttrNumber( itemtype  => itemtype,
			          	     itemkey   => itemkey,
			    		     aname     => 'COA_ID');

--    diagn_msg('Chart of Accounts Id fetched '||to_char(l_coa_id));

    -- find the number of segments defined for this chart of accounts
      SELECT count(*)
      INTO   l_no_of_segs
      FROM   fnd_id_flex_segments
      WHERE  application_id = 101
      AND    id_flex_code = 'GL#'
      AND    id_flex_num = l_coa_id;


--    diagn_msg('Number of Segments Fetched :'||to_char(l_no_of_segs));

      -- set the number of segments  workflow attribute
      wf_engine.SetItemAttrNumber( itemtype    => itemtype,
                                   itemkey     => itemkey,
                                   aname       => 'NO_OF_SEGS',
                                   avalue      => l_no_of_segs);

        diagn_msg(l_state_level,'find_no_of_segs','Attribute NO_OF_SEGS set to' ||(l_no_of_segs));

     -- set the loop limit to (number of segments - 1)
     l_loop_limit := l_no_of_segs - 1;

     -- set the loop limit workflow attribute
      wf_engine.SetItemAttrNumber( itemtype    => itemtype,
                                   itemkey     => itemkey,
                                   aname       => 'LOOP_LIMIT',
                                   avalue      => l_loop_limit);

        diagn_msg(l_state_level,'find_no_of_segs','Attribute LOOP_LIMIT set to' ||(l_loop_limit));

  ELSIF ( funcmode = 'CANCEL' ) THEN
	null;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    result := null;
    Wf_Core.Context('IGI_ITR_ACCT_GENERATOR_PKG', 'find_no_of_segs', itemtype, itemkey);
  IF ( l_unexp_level >=  l_debug_level) THEN
               FND_MESSAGE.SET_NAME('IGI','IGI_LOGGING_UNEXP_ERROR');
               FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
               FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
               FND_LOG.MESSAGE (l_unexp_level,'igi.plsql.igiitrrb.IGI_ITR_ACCT_GENERATOR_PKG.find_no_of_segs',TRUE);
    END IF;
  raise;
END find_no_of_segs;



--
-- *****************************************************************************
--   Increase_Counter
-- *****************************************************************************
--
PROCEDURE increase_counter( itemtype	IN VARCHAR2,
		            itemkey  	IN VARCHAR2,
		            actid   	IN NUMBER,
		            funcmode	IN VARCHAR2,
                            result     OUT NOCOPY VARCHAR2 ) IS

l_counter         NUMBER;
l_segmenti_number VARCHAR2(15);

BEGIN
  IF ( funcmode = 'RUN') THEN
--    diagn_msg('Procedure increase_counter being executed');

   -- fetch the counter value to be increased
    l_counter := wf_engine.GetItemAttrNumber( itemtype  => itemtype,
			    		      itemkey   => itemkey,
			    		      aname     => 'COUNTER');

--    diagn_msg('Counter fetched '||to_char(l_counter));

   -- increase counter value by 1
     l_counter := l_counter + 1;

     -- set the counter workflow attribute
      wf_engine.SetItemAttrNumber( itemtype    => itemtype,
                                   itemkey     => itemkey,
                                   aname       => 'COUNTER',
                                   avalue      => l_counter);

--        diagn_msg('Attribute COUNTER set to' ||(l_counter));

     -- set the segment number (application_column_name)
      l_segmenti_number := 'SEGMENT'||to_char(l_counter);

--      diagn_msg('segmenti number set to '||l_segmenti_number);

     -- set the segment number workflow attribute
      wf_engine.SetItemAttrText( itemtype    => itemtype,
                                 itemkey     => itemkey,
                                 aname       => 'SEGMENTI_NUMBER',
                                 avalue      => l_segmenti_number);

--        diagn_msg('Attribute SEGMENTI_NUMBER set to' ||(l_segmenti_number));

  ELSIF ( funcmode = 'CANCEL' ) THEN
	null;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    result := null;
    Wf_Core.Context('IGI_ITR_ACCT_GENERATOR_PKG', 'increase_counter', itemtype, itemkey);
  IF ( l_unexp_level >=  l_debug_level) THEN
               FND_MESSAGE.SET_NAME('IGI','IGI_LOGGING_UNEXP_ERROR');
               FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
               FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
               FND_LOG.MESSAGE (l_unexp_level,'igi.plsql.igiitrrb.IGI_ITR_ACCT_GENERATOR_PKG.increase_counter',TRUE);
    END IF;
  raise;
END increase_counter;


--
-- *****************************************************************************
--   Fetch_Segmenti_Value
-- *****************************************************************************
--
PROCEDURE fetch_segmenti_value( itemtype	IN VARCHAR2,
		                itemkey  	IN VARCHAR2,
		                actid   	IN NUMBER,
		                funcmode	IN VARCHAR2,
                                result     OUT NOCOPY VARCHAR2 ) IS

l_segmenti_number VARCHAR2(15);
l_segmenti_value  VARCHAR2(30);
l_preparer_id     NUMBER;
l_set_of_books_id NUMBER;

BEGIN
  IF ( funcmode = 'RUN') THEN
--    diagn_msg('Procedure fetch_segmenti_value being executed');

   -- get the segment number of the segment we want to find a value
   -- for (from the workflow attribute 'SEGMENTI_NUMBER')
    l_segmenti_number := wf_engine.GetItemAttrText( itemtype  => itemtype,
			    		            itemkey   => itemkey,
			    		            aname     => 'SEGMENTI_NUMBER');

--    diagn_msg('Segment i number fetched '||l_segmenti_number);

   -- get the id of the preparer
    l_preparer_id := wf_engine.GetItemAttrNumber( itemtype  => itemtype,
			    		          itemkey   => itemkey,
			    		          aname     => 'PREPARER_ID');

--    diagn_msg('Preparer Id fetched '||l_preparer_id);

   -- get the set of books id
    l_set_of_books_id := wf_engine.GetItemAttrNumber( itemtype  => itemtype,
			    		              itemkey   => itemkey,
			    		              aname     => 'SOB_ID');

--    diagn_msg('Set of Books Id fetched '||l_set_of_books_id);

-- fetch originator's value (if it exists) for this segment
-- will need to use native dynamic sql here since we do not know the column
-- we are selecting from

   EXECUTE immediate  'SELECT '||l_segmenti_number||
                     ' FROM    igi_itr_charge_orig orig'||
                            ' ,igi_itr_charge_center center'||
                     ' WHERE orig.originator_id = :preparer_id'||
                     ' AND   sysdate BETWEEN nvl(orig.start_date,sysdate)'||
                                   ' AND nvl(orig.end_date,sysdate) '||
                     ' AND   orig.charge_center_id = center.charge_center_id'||
                     ' AND   center.set_of_books_id = :set_of_books_id'||
                     ' AND   sysdate BETWEEN'||
                             ' nvl(center.start_date_active,sysdate)'||
                             ' AND nvl(center.end_date_active,sysdate)'
   INTO l_segmenti_value
   USING  l_preparer_id, l_set_of_books_id;

   IF   l_segmenti_value is not null THEN

	--  set segmenti_value workflow attribute
	wf_engine.SetItemAttrText ( itemtype	=> itemtype,
			      	     itemkey  	=> itemkey,
  		 	      	     aname 	=> 'SEGMENTI_VALUE',
			      	     avalue 	=> l_segmenti_value );
        diagn_msg(l_state_level,'fetch_segmenti_value','Attribute SEGMENTI_VALUE set to' ||l_segmenti_value||
                  'for segment '||l_segmenti_number);

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
    result := null;
    Wf_Core.Context('IGI_ITR_ACCT_GENERATOR_PKG', 'fetch_segmenti_value', itemtype, itemkey);
    IF ( l_unexp_level >=  l_debug_level) THEN
               FND_MESSAGE.SET_NAME('IGI','IGI_LOGGING_UNEXP_ERROR');
               FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
               FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
               FND_LOG.MESSAGE (l_unexp_level,'igi.plsql.igiitrrb.IGI_ITR_ACCT_GENERATOR_PKG.fetch_segmenti_value',TRUE);
    END IF;
    raise;
END fetch_segmenti_value;

--
-- *****************************************************************************
--   Fetch_Segmenti_Name
-- *****************************************************************************
--
PROCEDURE fetch_segmenti_name ( itemtype	IN VARCHAR2,
		                itemkey  	IN VARCHAR2,
		                actid   	IN NUMBER,
		                funcmode	IN VARCHAR2,
                                result          OUT NOCOPY VARCHAR2 ) IS


l_segmenti_number  VARCHAR2(15);
l_coa_id           NUMBER;
l_segmenti_name    VARCHAR2(30);

BEGIN
  IF ( funcmode = 'RUN') THEN
--    diagn_msg('Procedure fetch_segmenti_name being executed');

   -- get the segment number of the segment we want to find the segment name
   -- for (from the workflow attribute 'SEGMENTI_NUMBER')

    l_segmenti_number := wf_engine.GetItemAttrText( itemtype  => itemtype,
			    		            itemkey   => itemkey,
			    		            aname     => 'SEGMENTI_NUMBER');

--    diagn_msg('Segment i number fetched '||l_segmenti_number);

   --  get the chart of accounts id (from the workflow attribute)
    l_coa_id := wf_engine.GetItemAttrNumber( itemtype  => itemtype,
			    		     itemkey   => itemkey,
			    		     aname     => 'COA_ID');

--    diagn_msg('Chart of Accounts Id fetched '||l_coa_id);

   -- find the segment name for the segmenti
      SELECT segment_name
      INTO   l_segmenti_name
      FROM   fnd_id_flex_segments
      WHERE  application_id = 101
      AND    id_flex_code = 'GL#'
      AND    id_flex_num  = l_coa_id
      AND    application_column_name = l_segmenti_number;


--    diagn_msg('Segment name found =  '||l_segmenti_name);

   -- set the segmenti name workflow attribute
	wf_engine.SetItemAttrText ( itemtype	=> itemtype,
			      	     itemkey  	=> itemkey,
  		 	      	     aname 	=> 'SEGMENTI_NAME',
			      	     avalue 	=> l_segmenti_name );
        diagn_msg(l_state_level,'fetch_segmenti_name','Attribute SEGMENTI_NAME set to' ||l_segmenti_name);


  ELSIF ( funcmode = 'CANCEL' ) THEN
	null;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    result := null;
    Wf_Core.Context('IGI_ITR_ACCT_GENERATOR_PKG', 'fetch_segmenti_name', itemtype, itemkey);
  IF ( l_unexp_level >=  l_debug_level) THEN
               FND_MESSAGE.SET_NAME('IGI','IGI_LOGGING_UNEXP_ERROR');
               FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
               FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
               FND_LOG.MESSAGE (l_unexp_level,'igi.plsql.igiitrrb.IGI_ITR_ACCT_GENERATOR_PKG.fetch_segmenti_name',TRUE);
    END IF;
  raise;
END fetch_segmenti_name;



--
-- *****************************************************************************
--   Cost_Center_Value_Chosen
-- *****************************************************************************
--
PROCEDURE cost_center_value_chosen  (itemtype	IN VARCHAR2,
		                     itemkey  	IN VARCHAR2,
		                     actid	IN NUMBER,
		                     funcmode	IN VARCHAR2,
                                     result     OUT NOCOPY VARCHAR2 ) IS

l_cost_center_value     VARCHAR2(30);
BEGIN
  IF ( funcmode = 'RUN') THEN

    diagn_msg(l_state_level,'cost_center_value_chosen','Procedure cost_center_value_chosen being executed');
    l_cost_center_value := wf_engine.GetItemAttrText   ( itemtype  => itemtype,
		           			           itemkey   => itemkey,
			    			           aname     => 'COST_CENTER_VALUE');
    IF l_cost_center_value is not null THEN
      diagn_msg(l_state_level,'cost_center_value_chosen','Cost center value has been chosen ');
      diagn_msg(l_state_level,'cost_center_value_chosen','Cost center value :'||l_cost_center_value);
      result := 'COMPLETE:Y';
      return;
    ELSE
      diagn_msg(l_state_level,'cost_center_value_chosen','Cost center value has not been chosen');
      result := 'COMPLETE:N';
      return;
    END IF;

  ELSIF ( funcmode = 'CANCEL' ) THEN
	null;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    result := null;
    Wf_Core.Context('IGI_ITR_ACCOUNT_GENERATOR_PKG', 'cost_center_value_chosen', itemtype, itemkey);
   IF ( l_unexp_level >=  l_debug_level) THEN
               FND_MESSAGE.SET_NAME('IGI','IGI_LOGGING_UNEXP_ERROR');
               FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
               FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
               FND_LOG.MESSAGE (l_unexp_level,'igi.plsql.igiitrrb.IGI_ITR_ACCT_GENERATOR_PKG.cost_center_value_chosen',TRUE);
    END IF;

   raise;
END cost_center_value_chosen;



--
-- *****************************************************************************
--   Additional_Seg_Value_Chosen
-- *****************************************************************************
--
PROCEDURE Additional_Seg_Value_Chosen(itemtype	IN VARCHAR2,
		                      itemkey  	IN VARCHAR2,
		                      actid   	IN NUMBER,
		                      funcmode	IN VARCHAR2,
                                      result     OUT NOCOPY VARCHAR2 ) IS

l_additional_seg_value   VARCHAR2(30);
BEGIN

  IF ( funcmode = 'RUN') THEN
    diagn_msg(l_state_level,'Additional_Seg_Value_Chosen','Procedure additional_seg_value_chosen being executed');

    l_additional_seg_value := wf_engine.GetItemAttrText ( itemtype  => itemtype,
			    			           itemkey   => itemkey,
			    			            aname     => 'ADDITIONAL_SEG_VALUE');


    IF l_additional_seg_value is not null THEN
      diagn_msg(l_state_level,'Additional_Seg_Value_Chosen','Additional segment value has been chosen ');
      diagn_msg(l_state_level,'Additional_Seg_Value_Chosen','Additional segment value :'||l_additional_seg_value);
      result := 'COMPLETE:Y';
      return;
    ELSE
      diagn_msg(l_state_level,'Additional_Seg_Value_Chosen','Additional segment value has not been chosen');
      result := 'COMPLETE:N';
      return;
    END IF;


  ELSIF ( funcmode = 'CANCEL' ) THEN
	null;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    result := null;
    Wf_Core.Context('IGI_ITR_ACCT_GENERATOR_PKG', 'additional_seg_value_chosen', itemtype, itemkey);
    IF ( l_unexp_level >=  l_debug_level) THEN
               FND_MESSAGE.SET_NAME('IGI','IGI_LOGGING_UNEXP_ERROR');
               FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
               FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
               FND_LOG.MESSAGE (l_unexp_level,'igi.plsql.igiitrrb.IGI_ITR_ACCT_GENERATOR_PKG.additional_seg_value_chosen',TRUE);
    END IF;
    raise;
END additional_seg_value_chosen;

--
-- *****************************************************************************
--   Fetch_Additional_Seg_Name
-- *****************************************************************************
--
PROCEDURE Fetch_Additional_Seg_Name(itemtype	IN VARCHAR2,
	                            itemkey  	IN VARCHAR2,
	                            actid   	IN NUMBER,
	                            funcmode	IN VARCHAR2,
                                    result     OUT NOCOPY VARCHAR2 ) IS

l_additional_seg_name   VARCHAR2(30);
l_sob_id                NUMBER;

BEGIN

  IF ( funcmode = 'RUN') THEN

    diagn_msg(l_state_level,'Fetch_Additional_Seg_Name','Procedure fetch_additional_seg_name being executed');

    l_sob_id := wf_engine.GetItemAttrNumber( itemtype  => itemtype,
			         	     itemkey   => itemkey,
			    		     aname     => 'SOB_ID');




        -- Fetch segment name for additional segment
           SELECT segment_name
           INTO   l_additional_seg_name
           FROM   igi_itr_charge_setup
           WHERE  set_of_books_id = l_sob_id;

	--  Set additional_segment_name attribute
	wf_engine.SetItemAttrText ( itemtype	=> itemtype,
			      	     itemkey  	=> itemkey,
  		 	      	     aname 	=> 'ADDITIONAL_SEG_NAME',
			      	     avalue 	=> l_additional_seg_name );
        diagn_msg(l_state_level,'Fetch_Additional_Seg_Name','Attribute ADDITIONAL_SEG_NAME set to' ||l_additional_seg_name);


  ELSIF ( funcmode = 'CANCEL' ) THEN
	null;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    result := null;
    Wf_Core.Context('IGI_ITR_ACCT_GENERATOR_PKG', 'fetch_additional_seg_name', itemtype, itemkey);
    IF ( l_unexp_level >=  l_debug_level) THEN
               FND_MESSAGE.SET_NAME('IGI','IGI_LOGGING_UNEXP_ERROR');
               FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
               FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
               FND_LOG.MESSAGE (l_unexp_level,'igi.plsql.igiitrrb.IGI_ITR_ACCT_GENERATOR_PKG.fetch_additional_seg_name',TRUE);
    END IF;
    raise;
END fetch_additional_seg_name;



--
-- *****************************************************************************
--   Fetch_Service_Receiving_Acct
-- *****************************************************************************
--
PROCEDURE fetch_service_receiving_acct (itemtype	IN VARCHAR2,
		                        itemkey  	IN VARCHAR2,
		                        actid	        IN NUMBER,
		                        funcmode	IN VARCHAR2,
                                        result          OUT NOCOPY VARCHAR2 ) IS

l_charge_center_id NUMBER;
l_charge_service_id NUMBER;
l_service_receiving_ccid NUMBER;

BEGIN
  IF ( funcmode = 'RUN') THEN

  diagn_msg(l_state_level,'fetch_service_receiving_acct', 'Procedure fetch_service_receiving_acct being executed');

    l_charge_center_id := wf_engine.GetItemAttrNumber( itemtype  => itemtype,
			                 	       itemkey   => itemkey,
			    		               aname     => 'CHARGE_CENTER_ID');

    l_charge_service_id := wf_engine.GetItemAttrNumber( itemtype  => itemtype,
			                 	        itemkey   => itemkey,
			    		                aname     => 'CHARGE_SERVICE_ID');

        -- Fetch  receiving ccid for service type
           SELECT receiving_ccid
           INTO   l_service_receiving_ccid
           FROM   igi_itr_charge_service serv
           WHERE  serv.charge_service_id = l_charge_service_id
           AND    serv.charge_center_id = l_charge_center_id
           AND    sysdate BETWEEN nvl(serv.start_date,sysdate)
                          AND nvl(serv.end_date,sysdate);

	--  Set service_type_ccid attribute
	wf_engine.SetItemAttrNumber ( itemtype	=> itemtype,
			      	     itemkey  	=> itemkey,
  		 	      	     aname 	=> 'SERVICE_TYPE_RECEIVING_CCID',
			      	     avalue 	=> l_service_receiving_ccid );
        diagn_msg(l_state_level,'fetch_service_receiving_acct','Attribute SERVICE_TYPE_RECEIVING_CCID set to ' ||l_service_receiving_ccid);


    IF l_service_receiving_ccid is not null THEN
      result := 'COMPLETE:SUCCESS';
      return;
    ELSE
      result := 'COMPLETE:FAILURE';
      return;
    END IF;

  ELSIF ( funcmode = 'CANCEL' ) THEN
	null;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    result := null;
    Wf_Core.Context('IGI_ITR_ACCT_GENERATOR_PKG', 'fetch_service_receiving_acct', itemtype, itemkey);
    IF ( l_unexp_level >=  l_debug_level) THEN
               FND_MESSAGE.SET_NAME('IGI','IGI_LOGGING_UNEXP_ERROR');
               FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
               FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
               FND_LOG.MESSAGE (l_unexp_level,'igi.plsql.igiitrrb.IGI_ITR_ACCT_GENERATOR_PKG.fetch_service_receiving_acct',TRUE);
    END IF;
    raise;
END fetch_service_receiving_acct;


--

END IGI_ITR_ACCT_GENERATOR_PKG;

/
