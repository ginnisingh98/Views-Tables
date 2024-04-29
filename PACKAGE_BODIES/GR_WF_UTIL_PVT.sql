--------------------------------------------------------
--  DDL for Package Body GR_WF_UTIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GR_WF_UTIL_PVT" AS
/*  $Header: GRWFUPTB.pls 120.12 2008/01/15 21:41:33 plowe ship $    */
/*===========================================================================
--  PROCEDURE:
--    GetXMLTP
--
--  DESCRIPTION:
--      This procedure is used to set the Third Party Delivery details based
--      on Transaction Details.
--    	This procedure is called from 'GR Item Information Message' Workflow
--  PARAMETERS:
--    p_itemtype        VARCHAR2   -- type of the current item
--    p_itemkey         VARCHAR2   -- key of the current item
--    p_actid           NUMBER     -- process activity instance id
--    p_funcmode        VARCHAR2   -- function execution mode ('RUN', 'CANCEL', 'TIMEOUT', ...)
-- OUT
--    p_resultout       VARCHAR2
--       - COMPLETE[:<result>]
--           activity has completed with the indicated result
--       - WAITING
--           activity is waiting for additional transitions
--       - DEFERED
--           execution should be defered to background
--       - NOTIFIED[:<notification_id>:<assigned_user>]
--           activity has notified an external entity that this
--           step must be performed.  A call to wf_engine.CompleteActivty
--           will signal when this step is complete.  Optional
--           return of notification ID and assigned user.
--       - ERROR[:<error_code>]
--           function encountered an error.
--
--  SYNOPSIS:
--    GetXMLTP(p_itemtype, p_itemkey, p_actid, p_funcmode, l_resultout);
----
--  HISTORY
--    Mercy Thomas   31-Mar-2005  BUG 4276612 - Created.
--
--=========================================================================== */

PROCEDURE GetXMLTP(itemtype   in varchar2,
		           itemkey    in varchar2,
		           actid      in number,
		           funcmode   in varchar2,
	 	           resultout  in out NOCOPY varchar2)
is
  transaction_type     	VARCHAR2(240);
  transaction_subtype  	VARCHAR2(240);
  party_id	      	    varchar2(240);
  l_party_site_id	    varchar2(240);
  party_type            varchar2(240);
  document_id           varchar2(240);

  parameter1		varchar2(240);
  parameter2		varchar2(240);
  parameter3		varchar2(240);
  parameter4		varchar2(240);
  parameter5		varchar2(240);
  event_name		varchar2(240);
  event_key		    varchar2(240);
  i_event		    wf_event_t;
  trigger_id        number := 0;

  p_party_type          varchar2(240);
  p_ext_type            varchar2(240);
  p_ext_subtype         varchar2(240);
  p_source_code         varchar2(240);
  p_party_id            varchar2(240);
  p_party_site_id       varchar2(240);

  p_message_type        varchar2(240);
  p_message_standard	varchar2(240);
  p_destination_code    varchar2(240);
  p_destination_type    varchar2(240);
  p_destination_address varchar2(2000);
  p_username            ecx_tp_details.username%TYPE;
  p_password            ecx_tp_details.password%TYPE;
  p_map_code            varchar2(240);
  p_queue_name          varchar2(240);
  p_tp_header_id        pls_integer;

  i_to_agent_name       varchar2(240);
  i_to_system_name      varchar2(240);
  i_to_agent            wf_agent_t;
  ret_code      	    pls_integer :=0;
  errbuf        	    varchar2(2000);

 cursor c1  is
  select  ecx_trigger_id_s.NEXTVAL
  from    dual;

BEGIN
 -- gmi_reservation_util.println('PAL inside OUR GetXMLTP ');
 --  gmd_pl_log('PAL inside OUR GetXMLTP ');

/* Set Transaction Type,  Tx subtype. */
  transaction_type     	:= 'GR';
  transaction_subtype  	:= 'GRIIO';

/* Set Party site Id and Fetch   Party Id, Party Type */
 l_party_site_id := FND_PROFILE.VALUE('GR_3RD_PARTY_SITE_ID');

  IF l_party_site_id IS NULL THEN
	 RETURN;
  ELSE
     SELECT DISTINCT PARTY_ID, PARTY_TYPE
     INTO   party_id, party_type
     FROM   ECX_TP_HEADERS
     WHERE  PARTY_SITE_ID = l_party_site_id;

     IF SQL%NOTFOUND THEN
	    RETURN;
      END IF;
  END IF;

 /* Set The Trigger id  */
  open    c1;
  fetch   c1 into trigger_id;
  close   c1;

/* Get Third Party Delivery Details based on the Transaction , Party Details. */
   ecx_document.trigger_outbound(transaction_type, transaction_subtype,
                                 party_id, l_party_site_id, document_id,
                                 ret_code, errbuf, trigger_id, p_party_type,
                                 p_party_id, p_party_site_id, p_message_type,
                                 p_message_standard, p_ext_type, p_ext_subtype,
                                 p_source_code, p_destination_code,
                                 p_destination_type, p_destination_address,
                                 p_username, p_password, p_map_code,
                                 p_queue_name, p_tp_header_id);

  -- do outbound logging
  ecx_debug.setErrorInfo(0,10,'ECX_MESSAGE_CREATED');
  ecx_errorlog.outbound_engine (trigger_id,
                                ret_code,
                                errbuf,
      				            null,
                                null,
                                p_party_type
	      			);

  /* Fetch the Workflow Event Attribute */

  i_event  	:= Wf_Engine.GetItemAttrEvent(itemtype,
                                          itemkey,
                                          'ECX_EVENT_MESSAGE');

  i_to_agent_name := 'ECX_OUTBOUND';

   begin
     select name
     into   i_to_system_name
     from   wf_systems
     where  guid = wf_core.translate('WF_SYSTEM_GUID');
     i_to_agent := wf_agent_t(i_to_agent_name, i_to_system_name);
     i_event.setToAgent(i_to_agent);
     exception
        when others then
           raise;
   end;

  /* Initialize the data to the Local Event */
  i_event.addParameterToList('PARTY_TYPE', p_party_type);
  i_event.addParameterToList('PARTYID', p_party_id);
  i_event.addParameterToList('PARTY_SITE_ID', p_source_code);
  i_event.addParameterToList('MESSAGE_TYPE', p_message_type);
  i_event.addParameterToList('MESSAGE_STANDARD', p_message_standard);
  i_event.addParameterToList('TRANSACTION_TYPE', p_ext_type);
  i_event.addParameterToList('TRANSACTION_SUBTYPE', p_ext_subtype);
  i_event.addParameterToList('PROTOCOL_TYPE', p_destination_type);
  i_event.addParameterToList('PROTOCOL_ADDRESS', p_destination_address);
  i_event.addParameterToList('USERNAME', p_username);
  i_event.addParameterToList('PASSWORD', p_password);
  i_event.addParameterToList('ATTRIBUTE2', null);
  i_event.addParameterToList('ATTRIBUTE3', p_destination_code);
  i_event.addParameterToList('ATTRIBUTE4', null);
  i_event.addParameterToList('ATTRIBUTE5', null);
  i_event.addParameterToList('TRIGGER_ID', trigger_id);
  i_event.addParameterToList('ITEM_TYPE', itemtype);
  i_event.addParameterToList('ITEM_KEY', itemkey);

  -- set the event data back
  wf_engine.SetItemAttrEvent(itemtype, itemkey, 'ECX_EVENT_MESSAGE', i_event);

  resultout := 'COMPLETE:';

EXCEPTION
when others then
	ecx_errorlog.outbound_trigger
                (
                trigger_id, transaction_type, transaction_subtype,
                p_party_id, p_party_site_id, p_party_type,
                document_id, ret_code, errbuf
                );

   	Wf_Core.Context('GR_WF_UTIL_PVT',
                    'getXMLTP',
                    itemtype,
                    itemkey,
                    to_char(actid),
                    funcmode);
    raise;
   --gmd_pl_log('PAL leaving OUR GetXMLTP ');
-- gmi_reservation_util.println('PAL leaving OUR GetXMLTP ');
end;



/*===========================================================================
--  PROCEDURE:
--    ITEMS_REQUESTED_INS
--
--  DESCRIPTION:
--    	This procedure will invoke the gr_xml_export_pub.EXPORT_DATA procedure
--      XML gateway cant pass CLOB arguments, so this procedure is used as
--      an interface between Item Request Inbound Message and
gr_xml_export_pub.EXPORT_DATA
--
--  PARAMETERS:
--   p_message_icn      IN	        NUMBER
--   p_orgn_id          IN	        NUMBER
--   p_from_item        IN	        VARCHAR2
--   p_to_item	        IN	        VARCHAR2
--
--  SYNOPSIS:
--   ITEMS_REQUESTED_INS(p_message_icn,p_orgn_id,p_from_item,p_to_item);
--
--  HISTORY
--    Krishna Prasad  22-APR-2005
--
--=========================================================================== */


PROCEDURE ITEMS_REQUESTED_INS(p_message_icn    IN   NUMBER,
                              p_orgn_id        IN   NUMBER,
                              p_from_item      IN   VARCHAR2,
                              p_to_item        IN   VARCHAR2)
IS

begin

      INSERT INTO gr_items_requested
                  (
                   MESSAGE_ICN,
                   ORGANIZATION,
                   FROM_ITEM,
                   TO_ITEM )
      VALUES
                  (
                   p_MESSAGE_ICN,
                   p_ORGN_ID,
                   p_FROM_ITEM,
                   p_TO_ITEM);
      COMMIT;

end;
/*===========================================================================
--  PROCEDURE:
--    GET_ITEM_DETAILS
--
--  DESCRIPTION:
--    	This procedure will retrieve the Item Details based on the Inventory Item Id.
--      It will be called from the Regulatory Workflow Utilities Public API.
--
--  PARAMETERS:
--    p_item_id       IN  VARCHAR2          - Item Id
--    p_item_code     IN  VARCHAR2           - Item Code
--    p_item_no       OUT NOCOPY  VARCHAR2  - Item Number of an Item
--    p_item_desc     OUT NOCOPY  VARCHAR2  - Item Description of an Item
--
--  SYNOPSIS:
--    GET_ITEM_DETAILS(p_item_id,l_item_no,l_item_desc);
--
--  HISTORY
--    Mercy Thomas   31-Mar-2005  BUG 4276612 - Created.
--
-- *  P Lowe         11-Nov-2007  BUG 6750439 - SALES ORDER OUTBOUND XML
--              MESSAGE (GRIOO) GETTING FIRED FOR NON-REGULATORY ITEM
--              set p_item_no value to NULL so passes check
--
--=========================================================================== */

PROCEDURE GET_ITEM_DETAILS
    (p_orgn_id           IN         NUMBER,
     p_item_id           IN         NUMBER,
     p_item_no          OUT  NOCOPY VARCHAR2,
     p_item_desc        OUT  NOCOPY VARCHAR2
	) IS
    /*****************  Cursor  ****************/

    /* Used to get the item information */

    CURSOR get_item_details IS
      SELECT concatenated_segments, description
      FROM   mtl_system_items_kfv
      WHERE organization_id = p_orgn_id
      AND   inventory_item_id = p_item_id
      AND   hazardous_material_flag = 'Y';

    BEGIN
      /* Check to see if the item exists in Process Inventory and get the Item details*/

      -- gmi_reservation_util.println('PAL inside GET_ITEM_DETAILS ');
      -- gmd_pl_log('PAL inside GET_ITEM_DETAILS');

     -- gmi_reservation_util.println('p_orgn_id : '  || p_orgn_id ||


      OPEN get_item_details;
      FETCH get_item_details INTO p_item_no, p_item_desc;

      IF (get_item_details %NOTFOUND) THEN
          --gmi_reservation_util.println('PAL get_item_details  -  SQL%NOTFOUND ');
         --P_item_no   := ' '; -- 6750439
         P_item_desc := ' ';
         P_item_no   := NULL; -- 6750439


      END IF;
      CLOSE get_item_details;
     EXCEPTION
       WHEN OTHERS THEN
           --P_item_no   := ' '; -- 6750439
           P_item_no   := NULL; -- 6750439
           P_item_desc := ' ';



    END GET_ITEM_DETAILS;


/*===========================================================================
--  PROCEDURE:
--    GET_FORMULA_DETAILS
--
--  DESCRIPTION:
--    	This procedure will retrieve the Formula Details based on the Formula Id.
--      It will be called from the Regulatory Workflow Utilities Public API.
--
--  PARAMETERS:
--    p_formula_id       IN         VARCHAR2  - Formula Id of an Item
--    p_formula_no       OUT NOCOPY VARCHAR2  - Formula Number of an Item
--    p_formula_vers     OUT NOCOPY NUMBER  - Formula Vers of an Item
--
--  SYNOPSIS:
--    GET_FORMULA_DETAILS(p_formula_id,l_formula_no,l_formula_vers);
--
--  HISTORY
--    Mercy Thomas   31-Mar-2005  BUG 4276612 - Created.
--
--=========================================================================== */

PROCEDURE GET_FORMULA_DETAILS
    (p_formula_id       IN          NUMBER,
     p_formula_no       OUT  NOCOPY VARCHAR2,
     p_formula_vers     OUT  NOCOPY NUMBER
    ) IS
      /*****************  Cursor  ****************/
      /* Used to get the formula information */
      CURSOR get_formula_details IS
        SELECT formula_no, formula_vers
        FROM   fm_form_mst_b
        WHERE  formula_id = p_formula_id;
BEGIN
      /* Check to see if the formula exists in New Product Development and get the Formula details*/
      OPEN get_formula_details;
      FETCH get_formula_details INTO p_formula_no, p_formula_vers;
      IF (get_formula_details %NOTFOUND) THEN
         P_formula_no   := ' ';
         P_formula_vers := ' ';
      END IF;
      CLOSE get_formula_details;
     EXCEPTION
       WHEN OTHERS THEN
           P_formula_no   := ' ';
           P_formula_vers := ' ';
END GET_FORMULA_DETAILS;

/*===========================================================================
--  PROCEDURE:
--    WF_INIT
--
--  DESCRIPTION:
--    	This procedure will initiate the Document Rebuild Required Workflow
--      when called from the Regulatory Workflow Utilities Public API.
--
--  PARAMETERS:
--    p_item_no       IN  VARCHAR2  - Item Number of an Item
--    p_item_desc     IN  VARCHAR2  - Item Description of an Item
--    p_formula_no    IN  VARCHAR2  - Formula Number of an Item
--    p_formula_vers  IN  NUMBER  - Formula Description of an Item
--
--  SYNOPSIS:
--    WF_INIT(p_item_no,p_item_desc,p_formula_no,p_formula_vers);
--
--  HISTORY
--    Mercy Thomas   31-Mar-2005  BUG 4276612 - Created.
--
--=========================================================================== */

PROCEDURE WF_INIT
    (p_orgn_id           IN   NUMBER,
     p_item_id           IN   NUMBER,
     p_item_no           IN   VARCHAR2,
     p_item_desc         IN   VARCHAR2,
     p_formula_no        IN   VARCHAR2  DEFAULT NULL,
     p_formula_vers      IN   NUMBER    DEFAULT NULL,
     p_user              IN   NUMBER) IS
      /************* Local Variables *************/
      l_itemtype                WF_ITEMS.ITEM_TYPE%TYPE;
      l_itemkey                 WF_ITEMS.ITEM_KEY%TYPE;
      l_runform                 VARCHAR2(100);
      l_performer_name          FND_USER.USER_NAME%TYPE ;
      l_performer_display_name  FND_USER.DESCRIPTION%TYPE ;
      l_performer               FND_USER.USER_NAME%TYPE ;
      /* make sure that process runs with background engine
       to prevent SAVEPOINT/ROLLBACK error (see Workflow FAQ)
       the value to use for this is -1 */

      l_run_wf_in_background CONSTANT WF_ENGINE.THRESHOLD%TYPE := -1;
      l_WorkflowProcess   VARCHAR2(30);
      l_count             NUMBER;
      l_errname           VARCHAR2(200);
      l_errmsg            VARCHAR2(200);
      l_errstack          VARCHAR2(200);
      l_orgn_name         MTL_PARAMETERS.ORGANIZATION_CODE%TYPE;
BEGIN
      l_itemtype          :=  'GRDCRBLD';
      l_itemkey           :=  to_char(p_item_no)||'-'||to_char(sysdate,'dd-MON-yyyy HH24:mi:ss');
      l_WorkflowProcess   := 'GRDCRBLD_PROCESS';
      /* create the process */
      WF_ENGINE.CREATEPROCESS (itemtype => l_itemtype,
                               itemkey => l_itemkey,
                               process => l_WorkflowProcess) ;

      /* make sure that process runs with background engine */
      WF_ENGINE.THRESHOLD := l_run_wf_in_background ;

     /*Call the GR_DISPATCH_HISTORY_PVT.GET_ORGANIZATION_CODE to populate the ORGN_NAME */
      GR_DISPATCH_HISTORY_PVT.GET_ORGANIZATION_CODE(p_orgn_id, l_orgn_name);

      /* set the item attributes */
     WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,
     			        itemkey  => l_itemkey,
         	                aname    => 'TRNS_TYPE_GRRRO_GRIIO',
         	                avalue   => 'GRRRO');

      WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,
     			        itemkey  => l_itemkey,
         	                aname    => 'ORGANIZATION_ID',
         	                avalue   => p_orgn_id);

      WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,
     			        itemkey  => l_itemkey,
         	                aname    => 'ORGN_NAME',
         	                avalue   => l_orgn_name);

      WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,
     			        itemkey  => l_itemkey,
         	                aname    => 'ITEM_NO',
         	                avalue   => p_item_no);

      WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,
     	                        itemkey  => l_itemkey,
         	                aname    => 'ITEM_DESC',
         	                avalue   => p_item_desc);

      IF p_formula_no IS NOT NULL and p_formula_vers IS NOT NULL THEN

         WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,
                                   itemkey  => l_itemkey,
         	                   aname    => 'FORMULA_NO',
         	                   avalue   => p_formula_no);

         WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,
     	                           itemkey  => l_itemkey,
         	                   aname    => 'FORMULA_VERSION',
         	                   avalue   => to_char(p_formula_vers));

         WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,
     	                           itemkey  => l_itemkey,
         	                       aname    => 'FORMULA_FLAG',
         	                       avalue   => 'Y');
      END IF;

      SELECT USER_NAME
      INTO   l_performer
      FROM   FND_USER
      WHERE  USER_ID = p_user;

      WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,
                                itemkey  => l_itemkey,
                                aname    => '#FROM_ROLE',
                                avalue   => l_performer );
      -- get values to be stored into the workflow item
      l_performer_name := get_default_role('oracle.apps.gr.reg.documentmanager',p_item_id);

      IF l_performer_name IS NULL THEN
         l_performer_name := l_performer;
      END IF;
      WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,
                                itemkey  => l_itemkey,
                                aname    => 'REG_DOC_MGR',
                                avalue   => l_performer_name );

      /* start the Workflow process */
      WF_ENGINE.STARTPROCESS (itemtype => l_itemtype,
	                      itemkey  => l_itemkey);

      EXCEPTION
         WHEN OTHERS THEN
	        wf_core.context ('GR_REG_DOC_RBLD_WF',
                     	         'INIT_WF',
			         l_itemtype,
				 l_itemkey,
			         p_item_no);
	        wf_core.get_error (l_errname,
			           l_errmsg,
				   l_errstack);
	        if ((l_errname is null) and (sqlcode <> 0))
	        then
	           l_errname := to_char(sqlcode);
	           l_errmsg  := sqlerrm(-sqlcode);
	        end if;
	        raise;
END WF_INIT;

/*===========================================================================
--  PROCEDURE:
--    GET_DEFAULT_ROLE
--
--  DESCRIPTION:
--    This function will return the Default User set for in AME for the respective transaction.
--    This will be used by Document Rebuild Required Workflow to determine the user the
--    notification will be sent to.
--
--  PARAMETERS:
--    P_transaction       IN  VARCHAR2          - Transaction Type for an Item
--    P_transactionId     IN  VARCHAR2          - Transaction Type Id for an Item
--
--  SYNOPSIS:
--    GET_DEFAULT_ROLE(P_transaction,P_transactionId);
--
--  HISTORY
--    Mercy Thomas   31-Mar-2005  BUG 4276612 - Created.
--
--=========================================================================== */

FUNCTION GET_DEFAULT_ROLE
    (P_transaction              IN             VARCHAR2,
     P_transactionId            IN             VARCHAR2)
    RETURN VARCHAR2
    IS
      /************* Local Variables *************/
      l_application_id number;
      approvers ame_util.approversTable;
      l_user varchar2(4000);
BEGIN
      SELECT application_id
      INTO   l_application_id
      FROM   fnd_application
      WHERE  application_short_name='GR';

      ame_api.getAllApprovers(applicationIdIn      => l_application_id,
                              transactionIdIn      => p_transactionId,
                              transactionTypeIn    => P_transaction,
                              approversOut         => approvers);
      IF approvers.count >= 1 THEN
         if approvers(1).user_id is NULL then
            approvers(1).user_id :=ame_util.PERSONIDTOUSERID(approvers(1).person_id);
         end if;
         SELECT USER_NAME
         INTO   l_user
         FROM   FND_USER
         WHERE  USER_ID = approvers(1).user_id;
      ELSE
         l_user := NULL;
      END IF;
      return l_user;
END GET_DEFAULT_ROLE;


/*===========================================================================
--  PROCEDURE:
--    CHECK_FOR_TECH_PARAM
--
--  DESCRIPTION:
--    This function will be called from the Regulatory Workflow Utilities Public API
--    to check if the Technical Parameter is used in Regulatory.
--
--  PARAMETERS:
--    P_tech_parm_name    IN  VARCHAR2  - Technical Parameter Name
--
--  SYNOPSIS:
--    l_check_for_tech_parm := CHECK_FOR_TECH_PARAM(p_tech_parm_name);
--
--  HISTORY
--    Mercy Thomas   31-Mar-2005  BUG 4276612 - Created.
--
--=========================================================================== */

FUNCTION CHECK_FOR_TECH_PARAM
    (p_tech_parm_name                 IN VARCHAR2)
    RETURN BOOLEAN
IS
    /*****************  Cursors  ****************/

    /* Used to get the Technical Parameter Information */

    CURSOR check_tech_parm IS
      SELECT b.label_code
      FROM   gr_labels_b b,
	     gr_labels_tl t
      WHERE  b.label_code        = t.label_code
      AND    t.label_description = p_tech_parm_name
      AND    b.tech_parm         = '1';

      l_label_code   GR_LABELS_B.label_code%TYPE;
BEGIN
   /* Check to see if the Technical Parameter is defined in Regulatory*/

   OPEN check_tech_parm;
   FETCH check_tech_parm INTO l_label_code;
   IF (check_tech_parm%NOTFOUND) THEN
      /* Return False */
      Return FALSE;
   ELSE
      /* Return True */
      Return TRUE;
   END IF;
   CLOSE check_tech_parm;

END CHECK_FOR_TECH_PARAM;

/*===========================================================================
--  PROCEDURE:
--    IS_IT_PROP_OR_FORMULA_CHANGE
--
--  DESCRIPTION:
--    This function will be called from the Document Rebuild Required Workflow
--    to check if the Formula ot Item Change notification must be initiated.
--
--  PARAMETERS:
--    p_itemtype        VARCHAR2   -- type of the current item
--    p_itemkey         VARCHAR2   -- key of the current item
--    p_actid           NUMBER     -- process activity instance id
--    p_funcmode        VARCHAR2   -- function execution mode ('RUN', 'CANCEL', 'TIMEOUT', ...)
-- OUT
--    p_resultout       VARCHAR2
--       - COMPLETE[:<result>]
--           activity has completed with the indicated result
--       - WAITING
--           activity is waiting for additional transitions
--       - DEFERED
--           execution should be defered to background
--       - NOTIFIED[:<notification_id>:<assigned_user>]
--           activity has notified an external entity that this
--           step must be performed.  A call to wf_engine.CompleteActivty
--           will signal when this step is complete.  Optional
--           return of notification ID and assigned user.
--       - ERROR[:<error_code>]
--           function encountered an error.
--
--  SYNOPSIS:
--    IS_IT_PROP_OR_FORMULA_CHANGE(p_itemtype, p_itemkey, p_actid, p_funcmode, l_resultout);
--
--  HISTORY
--    Mercy Thomas   31-Mar-2005  BUG 4276612 - Created.
--
--=========================================================================== */


PROCEDURE IS_IT_PROP_OR_FORMULA_CHANGE(
      p_itemtype   IN         VARCHAR2,
      p_itemkey    IN         VARCHAR2,
      p_actid      IN         NUMBER,
      p_funcmode   IN         VARCHAR2,
      p_resultout  OUT NOCOPY VARCHAR2
	  )
  IS

    formula_no  NUMBER;
    formula_version   VARCHAR2(240);

  BEGIN
    IF p_funcmode='RUN' THEN

   	   formula_no := wf_engine.GetItemAttrNumber(itemtype => p_itemtype,
	                                             itemkey  => p_itemkey,
			                             aname    => 'FORMULA_NO' );
	   formula_version := wf_engine.GetItemAttrText(itemtype => p_itemtype,
	                                                itemkey  => p_itemkey,
			                                aname    => 'FORMULA_VERSION' );

       IF formula_no is null and formula_version is null THEN
          p_resultout := 'COMPLETE:ITEM_PROPERTY_CHG';
       ELSE
          p_resultout := 'COMPLETE:FORMULA_CHG';
       END IF;
    END IF;
END IS_IT_PROP_OR_FORMULA_CHANGE;

/*===========================================================================
--  PROCEDURE:
--    SEND_OUTBOUND_DOCUMENT
--
--  DESCRIPTION:
--    This procedure will initiate the XML Outbound Message when called from the
--    Regulatory Workflow Utilities Public API.
--
--  PARAMETERS:
--    p_transaction_type       -- Transaction Type Ex : GR
      p_transaction_subtype    -- Transaction SubType
      p_document_id            -- Document Id
      p_parameter1             -- Parameter
      p_parameter2             -- Parameter
      p_parameter3             -- Parameter
      p_parameter4             -- Parameter
      p_parameter5             -- Parameter
--
--  SYNOPSIS:
--    SEND_OUTBOUND_DOCUMENT('GR','GRIIO','1381','AAAA','ZZZZ');
--
--  HISTORY
--    kprasad   22-Jun-2005  BUG 4425023 - Created.
--    P Lowe    13-Dec-2007  BUG 6689912 need to use profiles to get
--               values for new parameters
--
--=========================================================================== */

 PROCEDURE SEND_OUTBOUND_DOCUMENT
    ( p_transaction_type        IN         VARCHAR2,
      p_transaction_subtype     IN         VARCHAR2,
      p_document_id             IN         VARCHAR2,
      p_parameter1              IN         VARCHAR2 DEFAULT NULL,
      p_parameter2              IN         VARCHAR2 DEFAULT NULL,
      p_parameter3              IN         VARCHAR2 DEFAULT NULL,
      p_parameter4              IN         VARCHAR2 DEFAULT NULL,
      p_parameter5              IN         VARCHAR2 DEFAULT NULL) IS

      /************* Local Variables *************/

      l_parameter_list 	wf_parameter_list_t := wf_parameter_list_t();
      l_event_name	VARCHAR2(120);
      l_event_key 	VARCHAR2(120);
      l_item_code       VARCHAR2(30);
      p_event           wf_event_t;

      l_party_id        NUMBER;
      l_party_site_id   NUMBER;
      l_party_type      VARCHAR2(10);
       -- 6689912
      l_soap_profile         VARCHAR2(150) := nvl (FND_PROFILE.VALUE ('GR_SOAPACTION'),'http://ap6192rt.us.oracle.com/oracle/apps/fnd/XMLGateway/ReceiveDocument');
      l_ws_service_namespace_profile   VARCHAR2(150) := nvl (FND_PROFILE.VALUE ('GR_WS_SERVICE_NAMESPACE'),'http://ap6192rt.us.oracle.com/oracle/apps/fnd/XMLGateway/ReceiveDocument');


   BEGIN
         --gmi_reservation_util.println('PAL inside Gr_Wf_Util_PVT.SEND_OUTBOUND_DOCUMENT ');
         wf_event_t.initialize(p_event);

	 l_party_site_id := FND_PROFILE.VALUE('GR_3RD_PARTY_SITE_ID');

	 IF l_party_site_id IS NULL THEN
	    RETURN;
         ELSE
	    SELECT DISTINCT PARTY_ID, PARTY_TYPE
		INTO   l_party_id, l_party_type
		FROM   ECX_TP_HEADERS
		WHERE  PARTY_SITE_ID = l_party_site_id;

		IF SQL%NOTFOUND THEN
		 --gmi_reservation_util.println('PAL ECX_TP_HEADERS -  SQL%NOTFOUND ');


		   RETURN;
		END IF;

         END IF;

     wf_event.AddParameterToList(   p_name=>'ECX_TRANSACTION_TYPE',
                                    p_value=>p_transaction_type,
                                    p_parameterlist=>l_parameter_list);

     wf_event.AddParameterToList(   p_name=>'ECX_TRANSACTION_SUBTYPE',
                                    p_value=>p_transaction_subtype,
                                    p_parameterlist=>l_parameter_list);

     wf_event.AddParameterToList(   p_name=>'PARTY_TYPE',
                                    p_value=>l_party_type,
                                    p_parameterlist=>l_parameter_list);

     wf_event.AddParameterToList(   p_name=>'PARTY_ID',
                                    p_value=>l_party_id,
                                    p_parameterlist=>l_parameter_list);

     wf_event.AddParameterToList(   p_name=>'PARTY_SITE_ID',
                                    p_value=>l_party_site_id,
                                    p_parameterlist=>l_parameter_list);

     wf_event.AddParameterToList(   p_name=>'DOCUMENT_ID',
                                    p_value=>p_document_id,
                                    p_parameterlist=>l_parameter_list);

     wf_event.AddParameterToList(   p_name=>'SEND_MODE',
                                    p_value=>'Immediate',
                                    p_parameterlist=>l_parameter_list);

     wf_event.AddParameterToList(   p_name=>'ECX_MSGID_ATTR',
                                    p_value=>'ECX_MESSAGE_ID',
                                    p_parameterlist=>l_parameter_list);

     wf_event.AddParameterToList(   p_name=>'PARAMETER1',
                                    p_value=>p_parameter1,
                                    p_parameterlist=>l_parameter_list);

     wf_event.AddParameterToList(   p_name=>'PARAMETER2',
                                    p_value=>p_parameter2,
                                    p_parameterlist=>l_parameter_list);

     wf_event.AddParameterToList(   p_name=>'PARAMETER3',
                                    p_value=>p_parameter3,
                                    p_parameterlist=>l_parameter_list);

     wf_event.AddParameterToList(   p_name=>'PARAMETER4',
                                    p_value=>p_parameter4,
                                    p_parameterlist=>l_parameter_list);

     wf_event.AddParameterToList(   p_name=>'PARAMETER5',
                                    p_value=>p_parameter5,
                                    p_parameterlist=>l_parameter_list);

     -- 6689912 need to use profiles to get values for new parameters

         wf_event.AddParameterToList(   p_name=>'SOAPACTION',
                                    p_value=>l_soap_profile,
                                    --p_value=>'http://ap6192rt.us.oracle.com/oracle/apps/fnd/XMLGateway/ReceiveDocument',
                                    p_parameterlist=>l_parameter_list);

          -- gmi_reservation_util.println('PAL l_soap_profile = ' || l_soap_profile );
         wf_event.AddParameterToList(   p_name=>'WS_SERVICE_NAMESPACE',
                                    p_value=>l_ws_service_namespace_profile,
                                    --p_value=>'http://ap6192rt.us.oracle.com/oracle/apps/fnd/XMLGateway',
                                    p_parameterlist=>l_parameter_list);
  --gmi_reservation_util.println('PAL l_ws_service_namespace_profile = ' ||  l_ws_service_namespace_profile);
      SELECT  gr_item_information_seq.nextval
      INTO    l_event_key
      FROM    DUAL;
			IF SQL%NOTFOUND THEN
		     gmi_reservation_util.println('PAL DUAL -  SQL%NOTFOUND ');
		  	END IF;

     l_event_name := 'oracle.apps.gr.message.send';

      --gmi_reservation_util.println('PAL about to call wf_event.raise ');

     wf_event.raise( p_event_name => l_event_name,
                     p_event_key  => l_event_key,
                     p_parameters => l_parameter_list);

     l_parameter_list.DELETE;

END SEND_OUTBOUND_DOCUMENT;

/*===========================================================================
--  PROCEDURE:
--    SEND_DOC_RBLD_OUTBND
--
--  DESCRIPTION:
--    This procedure will initiate the XML Outbound Message when called from the
--    Regulatory Workflow Utilities Public API.
--
--  PARAMETERS:
--    p_item_code     IN  VARCHAR2          - Item Code
--
--  SYNOPSIS:
--    SEND_DOC_RBLD_OUTBND(p_item_code);
--
--  HISTORY
--    Mercy Thomas   31-Mar-2005  BUG 4276612 - Created.
--
--=========================================================================== */
PROCEDURE SEND_DOC_RBLD_OUTBND    ( p_itemtype   IN         VARCHAR2,
                                    p_itemkey    IN         VARCHAR2,
                                    p_actid      IN         NUMBER,
                                    p_funcmode   IN         VARCHAR2,
                                    p_resultout  OUT NOCOPY VARCHAR2)
IS
  l_orgn_id   VARCHAR2(10);
  l_item_code VARCHAR2(40);
  l_from_item VARCHAR2(40);
  l_to_item   VARCHAR2(40);
  l_trn_type  VARCHAR2(10);
BEGIN


   l_trn_type  :=      WF_ENGINE.GetItemAttrText(itemtype => p_itemtype,
     				 itemkey  => p_itemkey,
                                 aname    => 'TRNS_TYPE_GRRRO_GRIIO');
    IF l_trn_type = 'GRRRO' THEN
        l_item_code :=      WF_ENGINE.GetItemAttrText(itemtype => p_itemtype,
     				                      itemkey  => p_itemkey,
                                                      aname    => 'ITEM_NO');

        l_orgn_id   :=      WF_ENGINE.GetItemAttrText(itemtype => p_itemtype,
     				                      itemkey  => p_itemkey,
                                                      aname    => 'ORGANIZATION_ID');
	 GR_WF_UTIL_PVT.SEND_OUTBOUND_DOCUMENT(
	 p_transaction_type     => 'GR',
	 p_transaction_subtype  => l_trn_type,
	 p_document_id          => l_item_code,
         p_parameter1           => l_orgn_id);
    ELSIF l_trn_type = 'GRIIO' AND p_funcmode = 'RESPOND' THEN

        l_orgn_id   := WF_ENGINE.GetItemAttrText(itemtype => p_itemtype,
     				                      itemkey  => p_itemkey,
                                                      aname    => 'ORGANIZATION_ID');

        l_from_item :=      WF_ENGINE.GetItemAttrText(itemtype => p_itemtype,
     				                      itemkey  => p_itemkey,
                                                      aname    => 'FROM_ITEM');

        l_to_item   :=      WF_ENGINE.GetItemAttrText(itemtype => p_itemtype,
     				                      itemkey  => p_itemkey,
                                                      aname    => 'TO_ITEM');

	 GR_WF_UTIL_PVT.SEND_OUTBOUND_DOCUMENT(
	 p_transaction_type     => 'GR',
	 p_transaction_subtype  => l_trn_type,
	 p_document_id          => l_orgn_id,
     p_parameter1           => l_from_item,
	 p_parameter2           => l_to_item );
    END IF;


END SEND_DOC_RBLD_OUTBND;

/*===========================================================================
--  PROCEDURE:
--    INIT_THRDPRTY_WF
--
--  DESCRIPTION:
--    	This procedure will initiate the Document Rebuild Required Workflow
--      when called from the Regulatory Workflow Utilities Public API.
--
--  PARAMETERS:
--    p_orgn_id          IN  NUMBER    - Organization ID of an Item
--    p_item_code        IN  VARCHAR2  - Item Code
--    p_property_name    IN  VARCHAR2  - XML element (Label and property ID combination)
--    p_property_value   IN  VARCHAR2  - Field Name Value
--
--  SYNOPSIS:
--    INIT_THRDPRTY_WF(p_orgn_id,p_item_code,p_property_name,p_property_value);
--
--  HISTORY
--    Mercy Thomas   31-Mar-2005  BUG 4276612 - Created.
--
--=========================================================================== */
PROCEDURE INIT_THRDPRTY_WF (P_message_icn NUMBER) IS
      /************* Local Variables *************/
      l_itemtype                WF_ITEMS.ITEM_TYPE%TYPE;
      l_itemkey                 WF_ITEMS.ITEM_KEY%TYPE;
      l_performer_name          FND_USER.USER_NAME%TYPE ;
      l_performer_display_name  FND_USER.DESCRIPTION%TYPE ;
      l_performer               FND_USER.USER_NAME%TYPE ;
      /* make sure that process runs with background engine
       to prevent SAVEPOINT/ROLLBACK error (see Workflow FAQ)
       the value to use for this is -1 */

      l_run_wf_in_background CONSTANT WF_ENGINE.THRESHOLD%TYPE := -1;
      l_WorkflowProcess   VARCHAR2(30);
      l_count             NUMBER;
      l_errname           VARCHAR2(2000);
	  l_errmsg            VARCHAR2(2000);
	  l_errstack          VARCHAR2(2000);
      l_property_name     VARCHAR2(2000);
      l_property_name_txt VARCHAR2(2000);
      l_field_name_code   VARCHAR2(100);
      l_property_id       VARCHAR2(200);
      l_property_value    VARCHAR2(200);
      l_prposed_prp_val   VARCHAR2(200);
      l_property_details  VARCHAR2(4000);
      l_prop_value        VARCHAR2(200);
      l_map_details       VARCHAR2(4000);
      l_unmap_details     VARCHAR2(4000);
      l_item_details      VARCHAR2(4000);
      l_details           VARCHAR2(4000);

      l_notify_txt        VARCHAR2(240);
      l_noti_non_reg_txt  VARCHAR2(240);
      l_orgn_id_txt       VARCHAR2(240);
      l_item_code_txt     VARCHAR2(240);
      l_item_name_txt     VARCHAR2(240);
      l_current_prop_txt  VARCHAR2(240);
      l_proposed_prop_txt VARCHAR2(240);
      l_item_code_seq     NUMBER;
      l_item_code         GR_ITEM_GENERAL.ITEM_CODE%TYPE;

        CURSOR get_property_value (V_orgn_id NUMBER, V_item_code VARCHAR2, V_element_name VARCHAR2) IS
     SELECT d.property_name, DECODE(b.property_type_indicator, 'A', a.alpha_value, 'D', a.date_value, 'N', a.number_value, 'F', a.alpha_value ) property_value,
            d.property_value  Proposed_value
     FROM   gr_inv_item_properties a, gr_properties_b b, gr_xml_properties_map c, gr_prop_chng_temp d
     WHERE  a.property_id       = b.property_id
     AND    a.property_id       = c.property_id
     AND    b.property_id       = c.property_id
     AND    a.label_code        = c.field_name_code
     AND    a.inventory_item_id = ( select inventory_item_id from mtl_system_items_kfv where organization_id =v_orgn_id and concatenated_segments =d.item_code )
     AND    a.organization_id   = d.orgn_id
     AND    c.xml_element       = d.property_name
     AND    d.item_code         = V_item_code
     AND    d.orgn_id           = V_orgn_id
     AND    c.xml_element       = V_element_name
     AND    d.message_icn       =  p_message_icn
    UNION ALL
     SELECT a.property_name, NULL property_value, a.property_value Proposed_value
     FROM   gr_prop_chng_temp a, gr_xml_properties_map b, mtl_system_items_kfv c
     WHERE  (c.inventory_item_id, c.organization_id, b.field_name_code, b.property_id ) NOT IN (select INVENTORY_ITEM_ID , ORGANIZATION_ID , label_code, property_id from
gr_inv_item_properties)
     AND    a.property_name    = b.xml_element
     AND    a.property_name    = V_element_name
     AND    a.item_code        = V_item_code
     AND    a.orgn_id          = V_orgn_id
     AND    a.item_code        = c.concatenated_segments
     AND    a.orgn_id          = c.organization_id
     AND    a.message_icn      = p_message_icn;


  CURSOR get_unmap_property_value (V_orgn_id NUMBER, V_item_code VARCHAR2, V_element_name VARCHAR2) IS
     SELECT property_name, NULL property_value, property_value Proposed_value
     FROM   gr_prop_chng_temp
     WHERE  property_name NOT IN (SELECT xml_element FROM gr_xml_properties_map)
     AND    property_name      = V_element_name
     AND    item_code          = V_item_code
     AND    orgn_id            = V_orgn_id
     AND    message_icn =  p_message_icn;

     CURSOR gr_prop_chng_temp IS
     SELECT a.orgn_id, nvl(c.organization_code, ' ') orgn_code, a.item_code, b.description item_name, a.property_name
     FROM   gr_prop_chng_temp a, mtl_system_items_kfv  b, mtl_parameters c
     WHERE  a.orgn_id         =  b.organization_id
     AND    a.orgn_id         =  c.organization_id
     AND    b.organization_id =  c.organization_id
     AND    a.item_code       =  b.concatenated_segments
     AND    a.message_icn     =  p_message_icn;

     l_item  VARCHAR2(32) := NULL;

    BEGIN
      l_itemtype   :=  'GRTPDCWF';
      SELECT  gr_item_information_seq.nextval
      INTO    l_item_code_seq
      FROM    DUAL;

      l_itemkey           :=  l_item_code_seq ||'-'||to_char(sysdate,'dd-MON-yyyy
HH24:mi:ss');
      l_WorkflowProcess   := 'GRTPDCHNG_PROCESS';

      /* create the process */
      WF_ENGINE.CREATEPROCESS (itemtype => l_itemtype,
                               itemkey  => l_itemkey,
                               process  => l_WorkflowProcess) ;

      /* make sure that process runs with background engine */
      WF_ENGINE.THRESHOLD := l_run_wf_in_background ;

      l_item := NULL;

      FOR c1 IN gr_prop_chng_temp LOOP

         IF l_item IS NULL OR l_item <> c1.item_code THEN
            FND_MESSAGE.SET_NAME('GR',
	                             'GR_NOTIFY_TXT');
            l_notify_txt := FND_MESSAGE.Get;

            FND_MESSAGE.SET_NAME('GR',
	                             'GR_ORGN_TXT');
	        l_orgn_id_txt := FND_MESSAGE.Get;

            FND_MESSAGE.SET_NAME('GR',
	                             'GR_ITEM_CODE_TXT');
	        l_item_code_txt := FND_MESSAGE.Get;

            FND_MESSAGE.SET_NAME('GR',
	                             'GR_ITEM_NAME_TXT');

            l_item_name_txt := FND_MESSAGE.Get;
            l_item_details := l_item_details ||
                           l_notify_txt    || fnd_global.local_chr(10) ||
                           l_orgn_id_txt   || ' ' || c1.orgn_code   || fnd_global.local_chr(10) ||
                           l_item_code_txt || ' ' || c1.item_code || fnd_global.local_chr(10) ||
                           l_item_name_txt || ' ' || c1.item_name || fnd_global.local_chr(10);

            l_item := c1.item_code;

          END IF;

           FOR c3 in get_property_value (c1.orgn_id, c1.item_code,c1.property_name) LOOP
              FND_MESSAGE.SET_NAME('GR',
                                   'GR_CURR_PROP_TXT');
	      l_current_prop_txt := FND_MESSAGE.Get;

              FND_MESSAGE.SET_NAME('GR',
                                   'GR_PROPOSED_PROP_TXT');
              l_proposed_prop_txt := FND_MESSAGE.Get;

              FND_MESSAGE.SET_NAME('GR',
                                   'GR_PROPERTY_NAME_TXT');
              l_property_name_txt := FND_MESSAGE.Get;

              l_map_details      := l_map_details || l_property_name_txt  || ' ' ||
c3.property_name  || fnd_global.local_chr(10) ||
                                    l_current_prop_txt  || ' ' ||  c3.property_value  ||
fnd_global.local_chr(10) ||
                                    l_proposed_prop_txt || ' ' ||  c3.proposed_value ||
fnd_global.local_chr(10);
           END LOOP;
           FOR c4 in get_unmap_property_value (c1.orgn_id, c1.item_code,c1.property_name) LOOP
              FND_MESSAGE.SET_NAME('GR',
                                   'GR_NOTIFY_NON_REG_TXT');
	      l_noti_non_reg_txt := FND_MESSAGE.Get;

              FND_MESSAGE.SET_NAME('GR',
                                   'GR_CURR_PROP_TXT');
	      l_current_prop_txt := FND_MESSAGE.Get;

              FND_MESSAGE.SET_NAME('GR',
                                   'GR_PROPOSED_PROP_TXT');
              l_proposed_prop_txt := FND_MESSAGE.Get;

              FND_MESSAGE.SET_NAME('GR',
                                   'GR_PROPERTY_NAME_TXT');
              l_property_name_txt := FND_MESSAGE.Get;

              l_unmap_details      := l_unmap_details || fnd_global.local_chr(10) ||
                                    l_noti_non_reg_txt || fnd_global.local_chr(10) ||
                                    l_property_name_txt  || ' ' || c4.property_name  || fnd_global.local_chr(10) ||
                                    l_current_prop_txt  || ' ' || c4.property_value  ||
fnd_global.local_chr(10) ||
                                    l_proposed_prop_txt || ' ' || c4.proposed_value ||
fnd_global.local_chr(10);
           END LOOP;


      END LOOP;

      If l_unmap_details IS NOT NULL THEN
         l_unmap_details := l_noti_non_reg_txt || fnd_global.local_chr(10) || l_unmap_details;
      END IF;

      l_property_details :=  l_item_details || fnd_global.local_chr(10) || l_map_details || l_unmap_details;


      /* set the item attributes */

      WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,
  			        itemkey  => l_itemkey,
         	                aname    => 'PROPERTY_DETAILS',
         	                avalue   => l_property_details);

      select item_code into l_item_code from gr_item_General_v where rownum=1;

      -- get values to be stored into the workflow item
      l_performer_name := get_default_role('oracle.apps.gr.reg.documentmanager',l_item_code);
      WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,
                                itemkey => l_itemkey,
                                aname => 'REG_DOC_MGR',
                                avalue => l_performer_name );

      /* start the Workflow process */
      WF_ENGINE.STARTPROCESS (itemtype => l_itemtype,itemkey => l_itemkey);
	  delete from gr_prop_chng_temp where message_icn = p_message_icn;
      EXCEPTION
         WHEN OTHERS THEN
	        wf_core.context ('GR_TRD_PRTY_WF',
                     	         'INIT_WF',
			         l_itemtype,
				 l_itemkey,
			         l_item_code);
	        wf_core.get_error (l_errname,
			           l_errmsg,
				   l_errstack);
	        if ((l_errname is null) and (sqlcode <> 0))
	        then
	           l_errname := to_char(sqlcode);
	           l_errmsg  := sqlerrm(-sqlcode);
	        end if;
	        raise;

	END INIT_THRDPRTY_WF;
/*===========================================================================
--  PROCEDURE:
--    THRDPRTY_INS
--
--  DESCRIPTION:
--    	This procedure will insert the details into gr_prop_chng_temp the details from the
--      third party property change inbound message.
--
--  PARAMETERS:
--    p_orgn_id          IN  NUMBER    - Organization ID of an Item
--    p_item_code        IN  VARCHAR2  - Item Code
--    p_property_name    IN  VARCHAR2  - XML element (Label and property ID combination)
--    p_property_value   IN  VARCHAR2  - Field Name Value
--
--  SYNOPSIS:
--    THRDPRTY_INS(p_orgn_id,p_item_code,p_property_name,p_property_value, p_session_id);
--
--  HISTORY
--    Mercy Thomas   31-Mar-2005  BUG 4276612 - Created.
--
--=========================================================================== */

PROCEDURE THRDPRTY_INS (
    p_message_icn      IN  NUMBER,
    p_orgn_id          IN  NUMBER,
    p_item_code        IN  VARCHAR2,
    p_property_name    IN  VARCHAR2,
    p_property_value   IN  VARCHAR2)  IS
BEGIN
      INSERT INTO gr_prop_chng_temp
                  (
                   MESSAGE_ICN,
                   ORGN_ID,
                   ITEM_CODE,
                   PROPERTY_NAME,
                   PROPERTY_VALUE)
      VALUES
                  (
                   p_MESSAGE_ICN,
                   p_ORGN_ID,
                   p_ITEM_CODE,
                   p_PROPERTY_NAME,
                   p_PROPERTY_VALUE);
      COMMIT;
END THRDPRTY_INS;

/*===========================================================================
--  PROCEDURE:
--    LOG_MSG
--
--  DESCRIPTION:
--    This PL/SQL procedure is used to create debug log for the Regulatory
--    Workflow Utilities Public API.
--
--  PARAMETERS:
--    p_msg_txt       IN  VARCHAR2          - Message Text
--
--  SYNOPSIS:
--    LOG_MSG(p_msg_text);
--
--  HISTORY
--    Mercy Thomas   31-Mar-2005  BUG 4276612 - Created.
--
--=========================================================================== */

PROCEDURE log_msg(p_msg_text IN VARCHAR2) IS
BEGIN

    FND_MESSAGE.SET_NAME('GR','GR_DEBUG_API');
    FND_MESSAGE.SET_TOKEN('MSG',p_msg_text);
    FND_MSG_PUB.Add;

END log_msg ;

/*===========================================================================
--  PROCEDURE:
--    WF_INIT_ITEM_INFO_REQ
--
--  DESCRIPTION:
--    	This procedure will initiate the Document Rebuild Required Workflow
--      when called from the Regulatory Workflow Utilities Public API.
--
--  PARAMETERS:
--    p_item_no       IN  VARCHAR2  - Item Number of an Item
--    p_item_desc     IN  VARCHAR2  - Item Description of an Item
--    p_formula_no    IN  VARCHAR2  - Formula Number of an Item
--    p_formula_vers  IN  NUMBER  - Formula Description of an Item
--
--  SYNOPSIS:
--    WF_INIT_ITEM_INFO_REQ(p_item_no,p_item_desc,p_formula_no,p_formula_vers);
--
--  HISTORY
--    Mercy Thomas   31-Mar-2005  BUG 4276612 - Created.
--
--=========================================================================== */

PROCEDURE WF_INIT_ITEM_INFO_REQ
    (p_message_icn       IN   NUMBER) IS
      /************* Local Variables *************/
      l_itemtype                WF_ITEMS.ITEM_TYPE%TYPE;
      l_itemkey                 WF_ITEMS.ITEM_KEY%TYPE;
      l_runform                 VARCHAR2(100);
      l_performer_name          FND_USER.USER_NAME%TYPE ;
      l_performer_display_name  FND_USER.DESCRIPTION%TYPE ;
      l_item_desc               IC_ITEM_MST_B.ITEM_DESC1%TYPE;
      l_performer               FND_USER.USER_NAME%TYPE ;
      l_user_id                 FND_USER.USER_ID%TYPE ;
      /* make sure that process runs with background engine
       to prevent SAVEPOINT/ROLLBACK error (see Workflow FAQ)
       the value to use for this is -1 */

      l_run_wf_in_background CONSTANT WF_ENGINE.THRESHOLD%TYPE := -1;
      l_WorkflowProcess   VARCHAR2(30);
      l_count             NUMBER;
      l_errname           VARCHAR2(200);
      l_errmsg            VARCHAR2(200);
      l_errstack          VARCHAR2(200);

      l_orgn_id           NUMBER;
      l_orgn_name         MTL_PARAMETERS.ORGANIZATION_CODE%TYPE;
      l_from_item         VARCHAR2(40);
      l_to_item           VARCHAR2(40);

      CURSOR cur_get_details IS
      SELECT organization, from_item, to_item
      FROM  gr_items_requested
      WHERE message_icn = p_message_icn;

BEGIN

      OPEN cur_get_details;
      FETCH cur_get_details INTO l_orgn_id, l_from_item, l_to_item;
      CLOSE cur_get_details;

      l_itemtype          :=  'GRREGIIO';
      l_itemkey           :=  to_char(l_from_item)||'-'||to_char(sysdate,'dd-MON-yyyy HH24:mi:ss');
      l_WorkflowProcess   := 'GRREGIIO_PROCESS';
      l_user_id           := FND_GLOBAL.USER_ID;
      /* create the process */
      WF_ENGINE.CREATEPROCESS (itemtype => l_itemtype,
                               itemkey => l_itemkey,
                               process => l_WorkflowProcess) ;

      /* make sure that process runs with background engine */
      WF_ENGINE.THRESHOLD := l_run_wf_in_background ;

     /*Call the GR_DISPATCH_HISTORY_PVT.GET_ORGANIZATION_CODE to populate the ORGN_NAME */
      GR_DISPATCH_HISTORY_PVT.GET_ORGANIZATION_CODE(l_orgn_id, l_orgn_name);

      /* set the item attributes */
      WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,
     			        itemkey  => l_itemkey,
         	                aname    => 'TRNS_TYPE_GRRRO_GRIIO',
         	                avalue   => 'GRIIO');

      WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,
     			        itemkey  => l_itemkey,
         	                aname    => 'ORGANIZATION_ID',
         	                avalue   => l_orgn_id);

      WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,
     			        itemkey  => l_itemkey,
         	                aname    => 'ORGN_NAME',
         	                avalue   => l_orgn_name);

      WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,
     			        itemkey  => l_itemkey,
         	                aname    => 'FROM_ITEM',
         	                avalue   => l_from_item);

      WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,
     			        itemkey  => l_itemkey,
         	                aname    => 'TO_ITEM',
         	                avalue   => l_to_item);

      SELECT USER_NAME
      INTO   l_performer
      FROM   FND_USER
      WHERE  USER_ID = l_user_id;

      WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,
                                itemkey  => l_itemkey,
                                aname    => '#FROM_ROLE',
                                avalue   => l_performer );

     select concatenated_segments into l_from_item from mtl_system_items_kfv where rownum=1;
      -- get values to be stored into the workflow item
      l_performer_name :=  get_default_role('oracle.apps.gr.reg.documentmanager',l_from_item);

      WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,
                                itemkey  => l_itemkey,
                                aname    => 'REG_DOC_MGR',
                                avalue   => l_performer_name );

      /* start the Workflow process */
      WF_ENGINE.STARTPROCESS (itemtype => l_itemtype,
	                      itemkey  => l_itemkey);
      delete from gr_items_requested where message_icn = p_message_icn;

      EXCEPTION
         WHEN OTHERS THEN
	        wf_core.context ('GR_REG_ITEM_REQ_WF',
                     	     'INIT_WF',
			                 l_itemtype,
				             l_itemkey,
			                 l_from_item);
	        wf_core.get_error (l_errname,
			                   l_errmsg,
				               l_errstack);
	        if ((l_errname is null) and (sqlcode <> 0))
	        then
	           l_errname := to_char(sqlcode);
	           l_errmsg  := sqlerrm(-sqlcode);
	        end if;
	        raise;
END WF_INIT_ITEM_INFO_REQ;


/*===========================================================================
--  PROCEDURE:
--    APPS_INITIALIZE
--
--  DESCRIPTION:
--    This PL/SQL procedure is used to initialize apps context from GRDDI.
--
--  PARAMETERS:
--    p_user_id       IN  NUMBER - User id
--
--  SYNOPSIS:
--    APPS_INITIALIZE(p_user_id);
--
--  HISTORY
--    Preetam Bamb   31-Mar-2005  Created.
--
--=========================================================================== */


PROCEDURE APPS_INITIALIZE( p_user_id IN NUMBER) IS

l_user_id NUMBER;
l_resp_id NUMBER;

BEGIN

   IF p_user_id is NULL THEN
      l_user_id := FND_GLOBAL.USER_ID;
   ELSE
      l_user_id := p_user_id;
   END IF;


   FND_GLOBAL.APPS_INITIALIZE(     l_user_id,
                                   25583,
                                   557);

END APPS_INITIALIZE;

END GR_WF_UTIL_PVT;

/
