--------------------------------------------------------
--  DDL for Package Body ARP_CMREQ_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_CMREQ_WF" as
/* $Header: ARWCMWFB.pls 120.19.12010000.3 2010/04/08 12:45:00 naneja ship $ */
-- <describe the activity here>
--
-- IN
--   p_item_type  - type of the current item
--   p_item_key   - key of the current item
--   p_actid     - process activity instance id
--   p_funcmode  - function execution mode ('RUN', 'CANCEL', 'TIMEOUT', ...)
-- OUT NOCOPY
--   p_result
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




-- Constants definition
----------------------------------------------------------------------------
-- Max number of approver
   C_MAX_NUMBER_APPROVER CONSTANT NUMBER := 200;

   PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');


PROCEDURE CheckUserInHR(   p_employee_id      IN NUMBER,
                           p_count            OUT NOCOPY NUMBER);

   PROCEDURE CheckUserInTable(p_item_type        IN  VARCHAR2,
                           p_item_key         IN  VARCHAR2,
                           p_employee_id      IN NUMBER,
                           p_primary_flag     IN VARCHAR2,
                           p_count            OUT NOCOPY NUMBER);
-----------------------------------------------------------------------------


PROCEDURE callback_routine (
  p_item_type   IN VARCHAR2,
  p_item_key    IN VARCHAR2,
  p_activity_id IN NUMBER,
  p_command     IN VARCHAR2,
  p_result      IN OUT NOCOPY VARCHAR2) IS

  CURSOR org IS
    SELECT org_id
    FROM   ra_cm_requests_all
    WHERE  request_id = p_item_key;

  l_debug_mesg  VARCHAR2(240);
  l_org_id      ra_cm_requests_all.org_id%TYPE;

BEGIN

  OPEN org;
  FETCH org INTO l_org_id;
  CLOSE org;

  wf_engine.setitemattrnumber(
    p_item_type,
    p_item_key,
    'ORG_ID',
    l_org_id);

  l_debug_mesg := 'Org ID: ' || l_org_id;

  IF ( p_command = 'RUN' ) THEN

     -- executable statements for RUN mode
     -- resultout := 'CMREQ_APPROVAL';
     RETURN;
  END IF;

  IF ( p_command = 'SET_CTX' ) THEN

    -- executable statements for establishing context information
    mo_global.set_policy_context(
      p_access_mode => 'S',
      p_org_id      => l_org_id);


  END IF;

  IF ( p_command = 'TEST_CTX' ) THEN

    -- your executable statements for testing the validity of the current
    -- context information
    IF (NVL(mo_global.get_access_mode, '-9999') <> 'S') OR
       (NVL(mo_global.get_current_org_id, -9999) <> l_org_id) THEN
       p_result := 'FALSE';
    ELSE
       p_result := 'TRUE';
    END IF;
    RETURN;

  END IF;

  EXCEPTION
    WHEN OTHERS THEN

    wf_core.context(
      pkg_name  => 'ARP_CMREQ_WF',
      proc_name => 'CALLBACK_ROUTINE',
      arg1      => p_item_type,
      arg2      => p_item_key,
      arg3      => to_char(p_activity_id),
      arg4      => p_command,
      arg5      => l_debug_mesg);

    RAISE;

END callback_routine;


PROCEDURE FindTrx(p_item_type        IN  VARCHAR2,
                  p_item_key         IN  VARCHAR2,
                  p_actid            IN  NUMBER,
                  p_funcmode         IN  VARCHAR2,
                  p_result           OUT NOCOPY VARCHAR2) IS

l_debug_mesg               varchar2(240);
l_workflow_document_id     number;
l_customer_trx_id          number;
l_amount                   number;
l_tax_amount               number;
l_line_amount              number;
l_freight_amount           number;
l_original_line_amount     number;
l_original_tax_amount      number;
l_original_freight_amount  number;
l_original_total           number;
l_reason_code              varchar2(45);
l_reason_meaning           varchar2(80);
l_currency_code            varchar2(15);
l_requestor_id		   number;
l_requestor_user_name      varchar2(100);
l_requestor_display_name   varchar2(100);
/* Bug 3206020 Changed comments width from 240 to 1760. */
l_comments                 varchar2(1760);
l_orig_trx_number          ra_cm_requests_all.orig_trx_number%TYPE;
l_tax_ex_cert_num          ra_cm_requests_all.tax_ex_cert_num%TYPE;

/*7367350 storing internal comment and inserting notes*/
l_internal_comment                 VARCHAR2(1760) DEFAULT NULL;

cursor c1 is
          SELECT name, display_name
          FROM wf_users
          WHERE     orig_system = 'PER'
              AND   orig_system_id = l_requestor_id;


cursor c2 is
          SELECT name, display_name
          FROM wf_users
          WHERE     orig_system = 'FND_USR'
              AND   orig_system_id = l_requestor_id;


begin
  -- SetOrgContext (p_item_key);

  --
  -- RUN mode - normal process execution
  --
  if (p_funcmode = 'RUN') then

     ------------------------------------------------------------
     l_debug_mesg := 'Get the requested trx and request_id';
     ------------------------------------------------------------
        /*7367350 retrieve info */
     GetCustomerTrxInfo(p_item_type,
                        p_item_key,
                        l_workflow_document_id,
                        l_customer_trx_id,
                        l_amount,
                        l_line_amount,
                        l_tax_amount,
                        l_freight_amount,
                        l_reason_code,
			l_reason_meaning,
			l_requestor_id,
                        l_comments,
                        l_orig_trx_number,
                        l_tax_ex_cert_num,
			l_internal_comment);


     if l_customer_trx_id <> -1 then

        WF_ENGINE.SetItemAttrNumber(p_item_type,
                                 p_item_key,
                                 'WORKFLOW_DOCUMENT_ID',
                                 l_workflow_document_id);


        WF_ENGINE.SetItemAttrNumber(p_item_type,
                                 p_item_key,
                                 'CUSTOMER_TRX_ID',
                                 l_customer_trx_id);

        WF_ENGINE.SetItemAttrNumber(p_item_type,
                                 p_item_key,
                                 'TOTAL_CREDIT_TO_INVOICE',
                                 l_amount);

        WF_ENGINE.SetItemAttrNumber(p_item_type,
                                 p_item_key,
                                 'TOTAL_CREDIT_TO_LINES',
                                 l_line_amount);

        WF_ENGINE.SetItemAttrNumber(p_item_type,
                                 p_item_key,
                                 'TOTAL_CREDIT_TO_TAX',
                                 l_tax_amount);

        WF_ENGINE.SetItemAttrNumber(p_item_type,
                                 p_item_key,
                                 'TOTAL_CREDIT_TO_FREIGHT',
                                 l_freight_amount);

        WF_ENGINE.SetItemAttrText(p_item_type,
                                 p_item_key,
                                 'REASON',
                                 l_reason_code);

        WF_ENGINE.SetItemAttrText(p_item_type,
                                 p_item_key,
                                 'REASON_MEANING',
                                 l_reason_meaning);

  	WF_ENGINE.SetItemAttrText(p_item_type,
				 p_item_key,
				 'COMMENTS',
				 l_comments);


        WF_ENGINE.SetItemAttrNumber(p_item_type,
                                 p_item_key,
                                 'REQUESTOR_ID',
                                 l_requestor_id);

       WF_ENGINE.SetItemAttrText(p_item_type,
                                 p_item_key,
                                 'ORIG_TRX_NUMBER',
                                 l_orig_trx_number);

        WF_ENGINE.SetItemAttrText(p_item_type,
                                 p_item_key,
                                 'TAX_EX_CERT_NUM',
                                 l_tax_ex_cert_num);
/*7367350 set attribute*/
	wf_engine.SetItemAttrText(p_item_type,
	                          p_item_key,
	                        'INTERNAL_COMMENTS',
	                         l_internal_comment);

      -- set requestor name and display name
       if ( l_requestor_id <> -1)  then
          open c1;
	  fetch c1 into l_requestor_user_name, l_requestor_display_name;
          if c1%notfound then
             l_requestor_user_name := null;
	     l_requestor_display_name := null;
             open c2;
             fetch c2 into l_requestor_user_name, l_requestor_display_name;
             if c2%notfound then
                l_requestor_user_name := null;
                l_requestor_display_name := null;
                l_debug_mesg := 'could not find the requestor';
             end if;
          end if;
       end if;


  	WF_ENGINE.SetItemAttrText(p_item_type,
				 p_item_key,
				 'REQUESTOR_USER_NAME',
				 l_requestor_user_name);

  	WF_ENGINE.SetItemAttrText(p_item_type,
				 p_item_key,
				 'REQUESTOR_DISPLAY_NAME',
				 l_requestor_display_name);

      -- set amount for trx.

       GetTrxAmount(p_item_type,
                    p_item_key,
                    l_customer_trx_id,
                    l_original_line_amount,
                    l_original_tax_amount,
                    l_original_freight_amount,
                    l_original_total ,
		    l_currency_code);

       WF_ENGINE.SetItemAttrNumber(p_item_type,
                                 p_item_key,
                                 'ORIGINAL_LINE_AMOUNT',
                                 l_original_line_amount);

      WF_ENGINE.SetItemAttrNumber(p_item_type,
                                 p_item_key,
                                 'ORIGINAL_TAX_AMOUNT',
                                 l_original_tax_amount);


      WF_ENGINE.SetItemAttrNumber(p_item_type,
                                 p_item_key,
                                 'ORIGINAL_FREIGHT_AMOUNT',
                                 l_original_freight_amount);

      WF_ENGINE.SetItemAttrNumber(p_item_type,
                                 p_item_key,
                                 'ORIGINAL_TOTAL',
                                 l_original_total);

      WF_ENGINE.SetItemAttrText(p_item_type,
                                 p_item_key,
                                 'CURRENCY_CODE',
                                 l_currency_code);
       p_result := 'COMPLETE:T';
       return;
    else
       p_result := 'COMPLETE:F';
       return;
    end if;

  end if; -- end of run mode

  --
  -- CANCEL mode
  --
  -- This is an event point is called with the effect of the activity must
  -- be undone, for example when a process is reset to an earlier point
  -- due to a loop back.
  --
  if (p_funcmode = 'CANCEL') then

    -- no result needed
    p_result := 'COMPLETE:';
    return;
  end if;


  --
  -- Other execution modes may be created in the future.  Your
  -- activity will indicate that it does not implement a mode
  -- by returning null
  --
  p_result := '';
  return;

exception
  when others then
    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context('ARP_CMREQ_WF', 'FindTrx',
		    p_item_type, p_item_key, to_char(p_actid), p_funcmode, l_debug_mesg);
    raise;

end FindTrx;

/*7367350 added parameter to retrive internal comment*/
PROCEDURE GetCustomerTrxInfo(p_item_type             IN  VARCHAR2,
                             p_item_key              IN  VARCHAR2,
                             p_workflow_document_id  OUT NOCOPY NUMBER,
                             p_customer_trx_id       OUT NOCOPY NUMBER,
                             p_amount                OUT NOCOPY NUMBER,
                             p_line_amount           OUT NOCOPY NUMBER,
                             p_tax_amount            OUT NOCOPY NUMBER,
                             p_freight_amount        OUT NOCOPY NUMBER,
			     p_reason                OUT NOCOPY VARCHAR2,
			     p_reason_meaning	     OUT NOCOPY VARCHAR2,
			     p_requestor_id	     OUT NOCOPY NUMBER,
                             p_comments              OUT NOCOPY VARCHAR2,
			     p_orig_trx_number       OUT NOCOPY VARCHAR2,
                             p_tax_ex_cert_num       OUT NOCOPY VARCHAR2,
			     p_internal_comment              OUT NOCOPY VARCHAR2) IS

l_debug_mesg              varchar2(240);
l_workflow_document_id    number;
l_customer_trx_id         number;
l_amount                  number;
l_line_amount             number;
l_tax_amount              number;
l_freight_amount          number;
l_created_by              number;
l_line_credit_flag        varchar2(1);
l_tax_disclaimer          varchar2(250);
l_orig_trx_number         ra_cm_requests_all.orig_trx_number%TYPE;
l_tax_ex_cert_num         ra_cm_requests_all.tax_ex_cert_num%TYPE;



BEGIN
  -- SetOrgContext (p_item_key);

   ----------------------------------------------------------
   l_debug_mesg := 'Get the customer trx id from table';
   ----------------------------------------------------------
   select  r.request_id,
           r.customer_trx_id,
           r.total_amount,
           r.cm_reason_code,
           l.meaning,
           r.created_by,
           r.comments,
           r.line_credits_flag,
           r.line_amount,
           r.tax_amount,
           r.freight_amount,
           r.ORIG_TRX_NUMBER,
           r.TAX_EX_CERT_NUM,
	   r.internal_comment
   into    l_workflow_document_id,
           l_customer_trx_id,
           l_amount,
           p_reason,
           p_reason_meaning,
           l_created_by,
           p_comments,
           l_line_credit_flag,
           l_line_amount,
           l_tax_amount,
           l_freight_amount,
           l_orig_trx_number,
           l_tax_ex_cert_num,
	   p_internal_comment
   from   ar_lookups l,
          ra_cm_requests r
   where  r.request_id = p_item_key
   and    r.cm_reason_code = l.lookup_code
   and    l.lookup_type = 'CREDIT_MEMO_REASON';

   p_workflow_document_id := l_workflow_document_id;
   p_customer_trx_id      := l_customer_trx_id;
   p_amount               := l_amount;
   p_line_amount          := l_line_amount;
   p_tax_amount           := l_tax_amount;
   p_freight_amount       := l_freight_amount;
   p_orig_trx_number      := l_orig_trx_number;
   p_tax_ex_cert_num      := l_tax_ex_cert_num;


   IF l_line_credit_flag = 'Y' THEN
      p_line_amount := l_amount;
   END IF;

   select employee_id
   into p_requestor_id
   from fnd_user
   where user_id = l_created_by;


   IF (p_requestor_id IS NULL) THEN
       p_requestor_id := l_created_by;
   END IF;

   l_tax_disclaimer := NULL;

   if l_line_credit_flag = 'Y'
   then
        fnd_message.set_name('AR', 'ARW_INV_MSG10');
        l_tax_disclaimer := fnd_message.get;
   end if;

   WF_ENGINE.SetItemAttrText(p_item_type,
                               p_item_key,
                               'TAX_DISCLAIMER',
                               l_tax_disclaimer);

exception
  when others then
    p_workflow_document_id := -1;
    p_customer_trx_id      := -1;
    p_amount               := 0;
    p_tax_amount           := 0;
    p_line_amount          := 0;
    p_freight_amount       := 0;
    p_reason               := NULL;
    p_reason_meaning       := NULL;
    p_comments             := NULL;
    p_requestor_id         := -1;
    p_orig_trx_number      := NULL;
    p_tax_ex_cert_num      := NULL;

    wf_core.Context('ARP_CMREQ_WF', 'GetCustomerTrxInfo',
                      null, null, null, l_debug_mesg);
      raise;

END GetCustomerTrxInfo;

PROCEDURE GetTrxAmount(p_item_type                IN  VARCHAR2,
                       p_item_key                 IN  VARCHAR2,
                       p_customer_trx_id          IN  NUMBER,
                       p_original_line_amount     OUT NOCOPY NUMBER,
                       p_original_tax_amount      OUT NOCOPY NUMBER,
                       p_original_freight_amount  OUT NOCOPY NUMBER,
                       p_original_total           OUT NOCOPY NUMBER,
		       p_currency_code            OUT NOCOPY VARCHAR2) IS

l_debug_mesg               varchar2(240);
BEGIN
   -- SetOrgContext (p_item_key);
   ----------------------------------------------------------
   l_debug_mesg := 'Get the customer trx amount from table';
   ----------------------------------------------------------

   select sum(ps.amount_line_items_original), sum(ps.tax_original),
          sum(ps.freight_original),           sum(ps.amount_due_original),
          ps.invoice_currency_code
   into   p_original_line_amount ,       p_original_tax_amount,
          p_original_freight_amount,     p_original_total, p_currency_code
   from  ar_payment_schedules ps
   where ps.customer_trx_id = p_customer_trx_id
   group by ps.invoice_currency_code ;

exception
  when others then
    p_original_line_amount    := NULL;
    p_original_tax_amount     := NULL;
    p_original_freight_amount := NULL;
    p_original_total          := NULL;
    p_currency_code           := NULL;

    wf_core.Context('ARP_CMREQ_WF', 'GetTrxAmount',
                      null, null, null, l_debug_mesg);
      raise;

END GetTrxAmount;



PROCEDURE FindCustomer(p_item_type        IN  VARCHAR2,
                       p_item_key         IN  VARCHAR2,
                       p_actid            IN  NUMBER,
                       p_funcmode         IN  VARCHAR2,
                       p_result           OUT NOCOPY VARCHAR2) IS

l_debug_mesg               varchar2(240);
l_customer_trx_id          number;
l_customer_id              number(15);
l_bill_to_site_use_id      number;
l_bill_to_customer_name    varchar2(50);
l_bill_to_customer_number  varchar2(30); /* Bug Fix 1882580 */
l_ship_to_customer_number  varchar2(30);
l_ship_to_customer_name    varchar2(50);
l_trx_number               varchar2(20);
l_request_url              ra_cm_requests.url%TYPE;
l_url                      ra_cm_requests.url%TYPE;
l_request_id               number;
l_trans_url                ra_cm_requests.transaction_url%TYPE;
l_act_url                  ra_cm_requests.activities_url%TYPE;
wf_flag			   varchar2(1) := 'Y';


begin
  -- SetOrgContext (p_item_key);

  --
  -- RUN mode - normal process execution
  --
  if (p_funcmode = 'RUN') then

     ------------------------------------------------------------
     l_debug_mesg := 'Get requested trx id ';
     ------------------------------------------------------------
     l_customer_trx_id  :=  WF_ENGINE.GetItemAttrNumber(
                                         p_item_type,
                                         p_item_key,
                                         'CUSTOMER_TRX_ID');

     ------------------------------------------------------------
     l_debug_mesg := 'Get Customer info based on requested trx ';
     ------------------------------------------------------------
IF PG_DEBUG in ('Y', 'C') THEN
   arp_util.debug('CheckUserInHR: ' || 'before getting cust info');
END IF;

     FindCustomerInfo(l_customer_trx_id,
                      l_bill_to_site_use_id,
                      l_customer_id,
                      l_bill_to_customer_name,
                      l_bill_to_customer_number,
                      l_ship_to_customer_number,
                      l_ship_to_customer_name,
                      l_trx_number );

IF PG_DEBUG in ('Y', 'C') THEN
   arp_util.debug('CheckUserInHR: ' || 'l_bill_to_customer_name ' || l_bill_to_customer_name);
END IF;

      if l_bill_to_customer_name is NULL then
         -- no customer has been found.
         p_result := 'COMPLETE:F';
         return;
      end if;



     ----------------------------------------------------------------------
     l_debug_mesg := 'Set value for customer_id(name)  in workflow process';
     -----------------------------------------------------------------------

     WF_ENGINE.SetItemAttrNumber(p_item_type,
                                 p_item_key,
                                 'CUSTOMER_ID',
                                 l_customer_id);


     WF_ENGINE.SetItemAttrText(p_item_type,
                               p_item_key,
                               'CUSTOMER_NAME',
                               l_bill_to_customer_name);

     -- set the bill to and ship to customer info.

     WF_ENGINE.SetItemAttrText(p_item_type,
                               p_item_key,
                               'BILL_TO_CUSTOMER_NAME',
                               l_bill_to_customer_name);

    /* Bug Fix 1882580. Since l_bill_to_customer_number is changed
       from number to varchar2, replaced the function in call to
       WF_ENGINE fom SetItemAttrNumber to SetItemAttrText
    */

     WF_ENGINE.SetItemAttrText(p_item_type,
                                 p_item_key,
                                 'BILL_TO_CUSTOMER_NUMBER',
                                 l_bill_to_customer_number);

    WF_ENGINE.SetItemAttrText(p_item_type,
                               p_item_key,
                               'SHIP_TO_CUSTOMER_NAME',
                               l_ship_to_customer_name);

    /* Bug Fix 1882580. Since l_bill_to_customer_number is changed
       from number to varchar2, replaced the function in call to
       WF_ENGINE fom SetItemAttrNumber to SetItemAttrText
    */
     WF_ENGINE.SetItemAttrText(p_item_type,
                                 p_item_key,
                                 'SHIP_TO_CUSTOMER_NUMBER',
                                 l_ship_to_customer_number);

     -- set the trx number

     WF_ENGINE.SetItemAttrText(p_item_type,
                                 p_item_key,
                                 'TRX_NUMBER',
                                 l_trx_number);



     ----------------------------------------------------------------------
     l_debug_mesg := 'Set value for bill_to_site_use_id  in workflow process';
     -----------------------------------------------------------------------
     WF_ENGINE.SetItemAttrNumber(p_item_type,
                                 p_item_key,
                                 'BILL_TO_SITE_USE_ID',
                                 l_bill_to_site_use_id);



     -- set the URL site

    l_request_id  := WF_ENGINE.GetItemAttrNumber(
                                    p_item_type,
                                    p_item_key,
				   'WORKFLOW_DOCUMENT_ID');

    select url
    into   l_url
    from   ra_cm_requests
    where  request_id = p_item_key;

    l_request_url :=  l_url;


     WF_ENGINE.SetItemAttrText(p_item_type,
                               p_item_key,
                               'REQUEST_URL',
                               l_request_url);


     -- set the transaction number URL site.

    select transaction_url
    into l_trans_url
    from  ra_cm_requests
    where request_id = p_item_key;


     WF_ENGINE.SetItemAttrText(p_item_type,
                               p_item_key,
                               'TRANSACTION_NUMBER_URL',
                               l_trans_url);


    select activities_url
    into l_act_url
    from ra_cm_requests
    where request_id =p_item_key;


     WF_ENGINE.SetItemAttrText(p_item_type,
                               p_item_key,
                               'TRANSACTION_ACTIVITY_URL',
                               l_act_url);

       p_result := 'COMPLETE:T';
       return;

  end if; -- end of run mode

  --
  -- CANCEL mode
  --
  --
  if (p_funcmode = 'CANCEL') then

    -- no result needed
    p_result := 'COMPLETE:';
    return;
  end if;


  --
  -- Other execution modes.
  --
  p_result := '';
  return;

exception
  when others then
    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context('ARP_CMREQ_WF', 'FindCustomer',
		    p_item_type, p_item_key, to_char(p_actid), p_funcmode);
    raise;

end FindCustomer;

PROCEDURE FindCustomerInfo(p_customer_trx_id          IN  NUMBER,
                           p_bill_to_site_use_id      OUT NOCOPY NUMBER,
                           p_customer_id              OUT NOCOPY NUMBER,
                           p_bill_to_customer_name    OUT NOCOPY VARCHAR2,
                           p_bill_to_customer_number  OUT NOCOPY VARCHAR2,
                           p_ship_to_customer_number  OUT NOCOPY VARCHAR2,
                           p_ship_to_customer_name    OUT NOCOPY VARCHAR2,
                           p_trx_number               OUT NOCOPY VARCHAR2 ) IS

l_debug_mesg        varchar2(240);

BEGIN

   ---------------------------------------------------------------------------
   l_debug_mesg := 'find customer id and name based on requested invoice';
   ---------------------------------------------------------------------------

   BEGIN
      select rct.bill_to_site_use_id,
             rct.bill_to_customer_id,
             substrb(party.party_name,1,50),
             bill_to_cust.account_number,
             rct.trx_number
      into   p_bill_to_site_use_id,     p_customer_id,
          p_bill_to_customer_name,   p_bill_to_customer_number,
          p_trx_number
      from   hz_cust_accounts bill_to_cust,
             hz_parties party,
             ra_customer_trx  rct
      where     rct.customer_trx_id       = p_customer_trx_id
            and rct.bill_to_customer_id   = bill_to_cust.cust_account_id
            and bill_to_cust.party_id = party.party_id ;

   EXCEPTION
     WHEN NO_DATA_FOUND THEN
        p_customer_id   :=  NULL ;
        p_bill_to_customer_name := NULL;
        p_bill_to_customer_number := NULL;

     WHEN OTHERS THEN
        wf_core.Context('ARP_CMREQ_WF', 'FindCustomerInfo',
                        null, null, null, l_debug_mesg);
        raise;
   END;

   --------------------------------------------------------------------------------
   l_debug_mesg := 'find ship to customer id and name based on requested invoice';
   --------------------------------------------------------------------------------
   BEGIN
     select substrb(party.party_name,1,50),
            ship_to_cust.account_number
     into   p_ship_to_customer_name,
            p_ship_to_customer_number
     from   hz_cust_accounts ship_to_cust,
            hz_parties  party,
            ra_customer_trx  rct
     where    rct.customer_trx_id       = p_customer_trx_id
         and  rct.ship_to_customer_id   = ship_to_cust.cust_account_id
         and  ship_to_cust.party_id = party.party_id;

   EXCEPTION
     WHEN NO_DATA_FOUND THEN
        p_ship_to_customer_name := NULL;
        p_ship_to_customer_number := NULL;

     WHEN OTHERS THEN
        wf_core.Context('ARP_CMREQ_WF', 'FindCustomerInfo',
                        null, null, null, l_debug_mesg);
        raise;
   END;


EXCEPTION

   WHEN OTHERS THEN
      wf_core.Context('ARP_CMREQ_WF', 'FindCustomerInfo',
                      null, null, null, l_debug_mesg);
      raise;


END FindCustomerInfo;


PROCEDURE FindCollector(p_item_type        IN  VARCHAR2,
                        p_item_key         IN  VARCHAR2,
                        p_actid            IN  NUMBER,
                        p_funcmode         IN  VARCHAR2,
                        p_result           OUT NOCOPY VARCHAR2) IS

l_debug_mesg varchar2(240);

 l_customer_trx_id          number(15);
 l_customer_id              number;
 l_bill_to_site_use_id      number(15);
 l_collector_employee_id    number(15);
 l_collector_id             number(15);
 l_collector_name           varchar2(30); -- name displayed in collector form.
 l_collector_user_name      varchar2(100);
 l_collector_display_name   varchar2(240); -- name for collector as employee

begin
  -- SetOrgContext (p_item_key);

  --
  -- RUN mode - normal process execution
  --
  if (p_funcmode = 'RUN') then

     -----------------------------------------------------------------
     l_debug_mesg := 'Get the value of customer_trx_id(customer id)';
     -----------------------------------------------------------------
     l_customer_trx_id :=  WF_ENGINE.GetItemAttrNumber(
                                         p_item_type,
                                         p_item_key,
                                         'CUSTOMER_TRX_ID');


     l_customer_id     :=  WF_ENGINE.GetItemAttrNumber(
                                         p_item_type,
                                         p_item_key,
                                         'CUSTOMER_ID');


     ----------------------------------------------------------------------
     l_debug_mesg := 'get value of bill_to_site_use_id from workflow process';
     -----------------------------------------------------------------------
     l_bill_to_site_use_id := WF_ENGINE.GetItemAttrNumber(
                                         p_item_type,
                                         p_item_key,
                                         'BILL_TO_SITE_USE_ID');

     -----------------------------------------------------------------------
     l_debug_mesg := 'Find Collector Info';
     -----------------------------------------------------------------------

    FindCollectorInfo(l_customer_id,
                      l_bill_to_site_use_id,
                      l_collector_employee_id,
                      l_collector_id,
                      l_collector_name);

      if l_collector_name is NULL then
         -- no collector has been found.
         p_result := 'COMPLETE:F';
         return;
      end if;

    ----------------------------------------------------------------
    l_debug_mesg := 'Set value for collector in workflow process';
    ----------------------------------------------------------------

    WF_ENGINE.SetItemAttrNumber(p_item_type,
                                p_item_key,
                                'COLLECTOR_EMPLOYEE_ID',
                                l_collector_employee_id);

    WF_ENGINE.SetItemAttrNumber(p_item_type,
                                p_item_key,
                                'COLLECTOR_ID',
                                l_collector_id);

    WF_ENGINE.SetItemAttrText(p_item_type,
                              p_item_key,
                              'COLLECTOR_NAME',
                              l_collector_name);

    -------------------------------------------------------------------
    l_debug_mesg := 'Set user name for the collector';
    ------------------------------------------------------------------
    WF_DIRECTORY.GetUserName('PER',
                             l_collector_employee_id,
                             l_collector_user_name,
                             l_collector_display_name);

    if l_collector_user_name is NULL then

       ----------------------------------------------------------------
       l_debug_mesg := 'The collector has not been defined in directory';
       -----------------------------------------------------------------
       p_result := 'COMPLETE:F';
       return;
    else
       WF_ENGINE.SetItemAttrText(p_item_type,
                              p_item_key,
                              'COLLECTOR_USER_NAME',
                              l_collector_user_name);

       WF_ENGINE.SetItemAttrText(p_item_type,
                              p_item_key,
                              'COLLECTOR_DISPLAY_NAME',
                              l_collector_display_name);
     end if;


   p_result := 'COMPLETE:T';
   return;

  end if; -- end of run mode

  --
  -- CANCEL mode
  --
  -- This is an event point is called with the effect of the activity must
  -- be undone, for example when a process is reset to an earlier point
  -- due to a loop back.
  --
  if (p_funcmode = 'CANCEL') then

    -- no result needed
    p_result := 'COMPLETE:';
    return;
  end if;


  --
  -- Other execution modes may be created in the future.  Your
  -- activity will indicate that it does not implement a mode
  -- by returning null
  --
  p_result := '';
  return;

exception
  when others then
    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context('ARP_CMREQ_WF', 'FindCollector',
		    p_item_type, p_item_key, to_char(p_actid), p_funcmode);
    raise;

end FindCollector;


PROCEDURE FindCollectorInfo(p_customer_id                 IN  NUMBER,
                            p_bill_to_site_use_id         IN  NUMBER,
                            p_collector_employee_id       OUT NOCOPY NUMBER,
                            p_collector_id                OUT NOCOPY NUMBER,
                            p_collector_name              OUT NOCOPY VARCHAR2) IS

l_debug_mesg        varchar2(240);

BEGIN
   ---------------------------------------------------------------------------
   l_debug_mesg := 'find collector id and name based on customer site id';
   ---------------------------------------------------------------------------
   select  col.employee_id, cp.collector_id,
           col.name
   into    p_collector_employee_id,   p_collector_id,
           p_collector_name
   from    ar_collectors col, hz_customer_profiles cp
   where cp.cust_account_id = p_customer_id
   and   cp.site_use_id     = p_bill_to_site_use_id
   and   cp.collector_id    = col.collector_id ;

EXCEPTION
   WHEN NO_DATA_FOUND THEN

      -- Bug 2609335 : when no collector defined at site level, go up to customer level
      BEGIN

        ---------------------------------------------------------------------------
        l_debug_mesg := 'find collector id and name based on customer id';
        ---------------------------------------------------------------------------
        select  col.employee_id,
                cp_cust.collector_id,
                col.name
        into    p_collector_employee_id,
                p_collector_id,
                p_collector_name
        from    ar_collectors col,
                hz_customer_profiles cp_cust
        where cp_cust.cust_account_id = p_customer_id
        and   cp_cust.site_use_id     IS NULL
        and   cp_cust.collector_id    = col.collector_id ;

      EXCEPTION
      WHEN NO_DATA_FOUND THEN

         p_collector_employee_id    :=  -9999 ;
         p_collector_id             :=  -9999 ;
         p_collector_name           :=  NULL  ;
      END;

   WHEN OTHERS THEN
      wf_core.Context('ARP_CMREQ_WF', 'FindCollectorInfo',
                      null, null, null, l_debug_mesg);
      raise;

END FindCollectorInfo;

PROCEDURE DefaultSendTo       (p_item_type        IN  VARCHAR2,
                               p_item_key         IN  VARCHAR2,
                               p_actid            IN  NUMBER,
                               p_funcmode         IN  VARCHAR2,
                               p_result           OUT NOCOPY VARCHAR2) IS

/* Bug 991922 : temp variables */
l_customer_trx_id        number;
l_invoicing_rule_id      number;
l_need_rule_mesg         varchar2(2000) DEFAULT
  'Please enter a revenue rule before approving this request because the disputed transaction has accounting rules.';
l_credit_accounting_rule varchar2(65);
/* Bug3195343 */
l_collector_employee_id  number;
l_collector_user_id      number;
l_debug_mesg             varchar2(240);
l_reason_code            varchar2(45);
l_currency_code      	 varchar2(30);
l_approver_id       	 number;
l_approver_user_name     varchar2(30);
l_employee_id		 number;
l_collector_user_name    varchar2(30);
l_collector_display_name varchar2(240);
/* Bug 3195343 */
 Cursor c1 is
         Select user_id
         From   fnd_user
	 Where  employee_id  = l_collector_employee_id;
begin
  -- SetOrgContext (p_item_key);

  --
  -- RUN mode - normal process execution
  --
  if (p_funcmode = 'RUN') then

     ------------------------------------------------------------
     l_debug_mesg := 'Defaulting Send To to Primary Approver with lowest $ amount';
     ------------------------------------------------------------

     /* Bug 991922 : get additional information to determine if rule is required */

     l_customer_trx_id  :=  WF_ENGINE.GetItemAttrNumber(
                                         p_item_type,
                                         p_item_key,
                                         'CUSTOMER_TRX_ID');

     l_credit_accounting_rule     := WF_ENGINE.GetItemAttrText(
                                                  p_item_type,
                                                  p_item_key,
                                                  'CREDIT_ACCOUNTING_RULE');

     l_reason_code    := WF_ENGINE.GetItemAttrText(
                                            p_item_type,
                                            p_item_key,
                                            'REASON');

     l_currency_code   := WF_ENGINE.GetItemAttrText(
                                            p_item_type,
                                            p_item_key,
                                            'CURRENCY_CODE');

     SelectFirstPrimaryApproverId(l_reason_code,
                                  l_currency_code,
                                  l_approver_id);


      if l_approver_id = -1  then

         -----------------------------------------
         l_debug_mesg := 'No first approver found';
         ------------------------------------------

          WF_ENGINE.SetItemAttrText(p_item_type,
                                  p_item_key,
                                  'ROLE',
                                  '');


         p_result := 'COMPLETE:F';
         return;

      else

             GetEmployeeInfo(l_approver_id,
                         p_item_type,
                         p_item_key,
                         'Y');

  	     l_approver_user_name    := WF_ENGINE.GetItemAttrText(p_item_type,
                                                     p_item_key,
                                                     'APPROVER_USER_NAME');
	     IF l_approver_user_name IS NULL THEN
		p_result := 'COMPLETE:F';
         	return;
	     ELSE

	             WF_ENGINE.SetItemAttrText(p_item_type,
                                  p_item_key,
                                  'ROLE',
                                  l_approver_user_name);


  	             l_collector_user_name    := WF_ENGINE.GetItemAttrText(p_item_type,
                                                     p_item_key,
                                                     'COLLECTOR_USER_NAME');

	             WF_ENGINE.SetItemAttrText(p_item_type,
                                  p_item_key,
                                  'APPROVER_USER_NAME',
                                  l_collector_user_name);

            -- Bug 1331562 : set approver_display_name to collector's name, so that details
            -- inserted into Notes are accurate

            l_collector_display_name  := WF_ENGINE.GetItemAttrText(p_item_type,
                                                     p_item_key,
                                                     'COLLECTOR_DISPLAY_NAME');
            WF_ENGINE.SetItemAttrText(p_item_type,
                               p_item_key,
                               'APPROVER_DISPLAY_NAME',
                               l_collector_display_name);

           /* Bug 3195343 Getting the collector_employee_id , from which the
	      user_id is obtained .Set this user_id as the APPROVER_ID. */

	      l_collector_employee_id :=  WF_ENGINE.GetItemAttrText(p_item_type,
	                                                             p_item_key,
						         'COLLECTOR_EMPLOYEE_ID');
              Open c1;
	      Fetch c1 into l_collector_user_id ;
	      Close c1;

             WF_ENGINE.SetItemAttrText(p_item_type,
                                        p_item_key,
                                     'APPROVER_ID',
                              l_collector_user_id);

            /* Bug 991922 : check if message body needs to say rule is required */

            SELECT invoicing_rule_id
              INTO l_invoicing_rule_id
              FROM ra_customer_trx
            WHERE customer_trx_id = l_customer_trx_id;

            if l_invoicing_rule_id is not NULL then

               if nvl(l_credit_accounting_rule,'*') not in ('LIFO','PRORATE','UNIT') then

                  fnd_message.set_name('AR', 'ARW_NEED_RULE');
                  l_need_rule_mesg := fnd_message.get;

                  WF_ENGINE.SetItemAttrText(p_item_type,
                                            p_item_key,
                                            'INVALID_RULE_MESG',
                                            l_need_rule_mesg);
               end if;
            end if;

            p_result := 'COMPLETE:T';
            return;
         END IF;
      end if;

  end if; -- end of run mode

  --
  -- CANCEL mode
  --

  if (p_funcmode = 'CANCEL') then

    -- no result needed
    p_result := 'COMPLETE:';
    return;
  end if;


  --
  -- Other execution modes.
  --
  p_result := '';
  return;

exception
  when others then
    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context('ARP_CMREQ_WF', 'DefaultSendTo',
                    p_item_type, p_item_key, to_char(p_actid), p_funcmode);
    raise;

end DefaultSendTo;



PROCEDURE CheckPrimaryApprover(p_item_type        IN  VARCHAR2,
                               p_item_key         IN  VARCHAR2,
                               p_actid            IN  NUMBER,
                               p_funcmode         IN  VARCHAR2,
                               p_result           OUT NOCOPY VARCHAR2) IS


l_debug_mesg varchar2(240);

 l_approver_name      varchar2(50);
 l_approver_user_name varchar2(30);
 l_employee_id	      number;
 l_reason_code        varchar2(45);
 l_currency_code      varchar2(30);
 l_primary_flag	      varchar2(1);

begin
  -- SetOrgContext (p_item_key);

  --
  -- RUN mode - normal process execution
  --
  if (p_funcmode = 'RUN') then

     ------------------------------------------------------------
     l_debug_mesg := 'Get the user name of selected role';
     ------------------------------------------------------------

     l_approver_name    := WF_ENGINE.GetItemAttrText(p_item_type,
                                                     p_item_key,
                                                     'ROLE');

     IF l_approver_name IS NULL THEN
     	p_result := 'COMPLETE:N';
	RETURN;
     END IF;

     l_reason_code    := WF_ENGINE.GetItemAttrText(
                                            p_item_type,
                                            p_item_key,
                                            'REASON');

     l_currency_code   := WF_ENGINE.GetItemAttrText(
                                            p_item_type,
                                            p_item_key,
                                            'CURRENCY_CODE');

     SELECT user_id INTO l_employee_id
     FROM fnd_user
     WHERE user_name = l_approver_name;

     SELECT primary_flag INTO l_primary_flag
     FROM ar_approval_user_limits aul
     WHERE reason_code = l_reason_code
     AND currency_code = l_currency_code
     AND user_id   = l_employee_id;

     if l_primary_flag = 'Y' THEN
   	p_result := 'COMPLETE:T';
     else
        p_result := 'COMPLETE:F';
     end if;

   return;

  end if; -- end of run mode

  --
  -- CANCEL mode
  --
  -- This is an event point is called with the effect of the activity must
  -- be undone, for example when a process is reset to an earlier point
  -- due to a loop back.
  --
  if (p_funcmode = 'CANCEL') then

    -- no result needed
    p_result := 'COMPLETE:';
    return;
  end if;


  --
  -- Other execution modes may be created in the future.  Your
  -- activity will indicate that it does not implement a mode
  -- by returning null
  --
  p_result := '';
  return;

exception
  when no_data_found then
	p_result := 'COMPLETE:N';
	return;
  when others then
    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context('ARP_CMREQ_WF', 'CheckPrimaryApprover',
		    p_item_type, p_item_key, to_char(p_actid), p_funcmode);
    raise;

end CheckPrimaryApprover;

PROCEDURE FindPrimaryApprover(p_item_type        IN  VARCHAR2,
                              p_item_key         IN  VARCHAR2,
                              p_actid            IN  NUMBER,
                              p_funcmode         IN  VARCHAR2,
                              p_result           OUT NOCOPY VARCHAR2) IS

l_debug_mesg         varchar2(240);
l_approver_count     number;
l_reason_code        varchar2(45);
l_currency_code      varchar2(30);
l_first_approver_id  number;
l_approver_id        number;
l_count              number;

begin
  -- SetOrgContext (p_item_key);
  --
  -- RUN mode - normal process execution
  --
  if (p_funcmode = 'RUN') then

     l_reason_code    := WF_ENGINE.GetItemAttrText(
                                            p_item_type,
                                            p_item_key,
                                            'REASON');

     l_currency_code   := WF_ENGINE.GetItemAttrText(
                                            p_item_type,
                                            p_item_key,
                                            'CURRENCY_CODE');


     l_approver_count  := WF_ENGINE.GetItemAttrNumber(
                                            p_item_type,
                                            p_item_key,
                                            'FIND_APPROVER_COUNT');


    if l_approver_count = 0 then

       SelectFirstPrimaryApproverId(l_reason_code,
                                    l_currency_code,
                                    l_first_approver_id);

      if l_first_approver_id = -1  then

         -----------------------------------------
         l_debug_mesg := 'No first approver found';
         ------------------------------------------
         p_result := 'COMPLETE:F';
         return;

      else
         -- found the first approver
         l_count := 1;

         WF_ENGINE.SetItemAttrNumber(p_item_type,
                                p_item_key,
                                'FIND_APPROVER_COUNT',
                                l_count);


         -- set info for the first approver

         GetEmployeeInfo(l_first_approver_id,
                         p_item_type,
                         p_item_key,
                         'Y');

      end if; -- end of if l_first_approver_id = -1


    else

      -- Increase the Approver Counter
      l_approver_count := l_approver_count + 1 ;


      SelectPrimaryApproverId(l_reason_code,
                              l_currency_code,
                              l_approver_count,
                              l_approver_id);



       if l_approver_id = -1 then
          -----------------------------------------
         l_debug_mesg := 'No approver found';
         ------------------------------------------
         p_result := 'COMPLETE:F';
         return;
       else

         WF_ENGINE.SetItemAttrNumber(p_item_type,
                                p_item_key,
                                'FIND_APPROVER_COUNT',
                                l_approver_count);

          -- set info for the approver

         GetEmployeeInfo(l_approver_id,
                         p_item_type,
                         p_item_key,
                         'Y');


       end if; -- if l_approver_id = -1



    end if;  -- if l_approver_count = 0



   p_result := 'COMPLETE:T';
   return;

  end if; -- end of run mode

  --
  -- CANCEL mode
  --

  if (p_funcmode = 'CANCEL') then

    -- no result needed
    p_result := 'COMPLETE:';
    return;
  end if;


  --
  -- Other execution modes.
  --
  p_result := '';
  return;

exception
  when others then
    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context('ARP_CMREQ_WF', 'FindPrimaryApprover',
		    p_item_type, p_item_key, to_char(p_actid), p_funcmode);
    raise;

end FindPrimaryApprover;

PROCEDURE FindNonPrimaryApprover(p_item_type        IN  VARCHAR2,
                                 p_item_key         IN  VARCHAR2,
                                 p_actid            IN  NUMBER,
                                 p_funcmode         IN  VARCHAR2,
                                 p_result           OUT NOCOPY VARCHAR2) IS

 l_debug_mesg varchar2(240);
 l_approver_id        number;
 l_employee_id		number;
 l_approver_display_name            varchar2(50);
 l_approver_user_name       varchar2(30);
 l_count			number;


begin
  -- SetOrgContext (p_item_key);

  --
  -- RUN mode - normal process execution
  --
  if (p_funcmode = 'RUN') then

     ------------------------------------------------------------
     l_debug_mesg := 'Retreiving info for Non-Primary Approver';
     ------------------------------------------------------------

     l_approver_user_name    := WF_ENGINE.GetItemAttrText(p_item_type,
                                                     p_item_key,
                                                     'ROLE');

     select employee_id, user_id into l_employee_id, l_approver_id
     from fnd_user
     where user_name = l_approver_user_name;

 	l_count := 0;

	CheckUserInHR(l_employee_id,
		      l_count);

	if l_count =0 THEN
            p_result := 'COMPLETE:F';
	else
            p_result := 'COMPLETE:T';
	end if;

     if p_result = 'COMPLETE:T'THEN
	GetEmployeeInfo(l_approver_id,
			p_item_type,
			p_item_key,
			'N');
     end if;

   return;

  end if; -- end of run mode

  --
  -- CANCEL mode
  --
  -- This is an event point is called with the effect of the activity must
  -- be undone, for example when a process is reset to an earlier point
  -- due to a loop back.
  --
  if (p_funcmode = 'CANCEL') then

    -- no result needed
    p_result := 'COMPLETE:';
    return;
  end if;


  --
  -- Other execution modes may be created in the future.  Your
  -- activity will indicate that it does not implement a mode
  -- by returning null
  --
  p_result := '';
  return;

exception
  when others then
    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context('ARP_CMREQ_WF', 'FindNonPrimaryApprover',
                    p_item_type, p_item_key, to_char(p_actid), p_funcmode);
    raise;

end FindNonPrimaryApprover;

PROCEDURE FindNextNonPrimaryApprover  ( p_item_type        IN  VARCHAR2,
                        		p_item_key         IN  VARCHAR2,
                        		p_actid            IN  NUMBER,
                        		p_funcmode         IN  VARCHAR2,
                        		p_result           OUT NOCOPY VARCHAR2) IS

 l_debug_info                  VARCHAR2(200);
 l_approver_id                 number;
 l_approver_display_name            varchar2(50);
 l_approver_user_name       varchar2(30);
 l_count			number;

 l_employee_id                  number;
 l_supervisor_emp_id                  number;

begin
  -- SetOrgContext (p_item_key);
  --
  -- RUN mode - normal process execution
  --
  if (p_funcmode = 'RUN') then

     ------------------------------------------------------------
     l_debug_info := 'Retreiving info for Next Non-Primary Approver';
     ------------------------------------------------------------

    l_approver_id         := WF_ENGINE.GetItemAttrNumber(p_item_type,
                                                          p_item_key,
                                                          'APPROVER_ID');
    BEGIN
     select employee_id into l_employee_id
     from fnd_user
     where user_id = l_approver_id;
    EXCEPTION WHEN NO_DATA_FOUND THEN
      p_result := 'COMPLETE:NE';
      return;
    END;

    BEGIN
      SELECT hremp.supervisor_id
     INTO   l_supervisor_emp_id
     FROM   per_all_assignments_f hremp
     WHERE  hremp.person_id = l_employee_id
     AND primary_flag = 'Y'       -- get primary assgt
     AND assignment_type = 'E'    -- ensure emp assgt, not applicant assgt
     AND trunc(sysdate) BETWEEN hremp.effective_start_date AND
                                hremp.effective_end_date ;

    EXCEPTION WHEN NO_DATA_FOUND THEN
	p_result := 'COMPLETE:NH';
	RETURN;
    END;


    BEGIN
     select user_id into l_approver_id
     from fnd_user
     where employee_id = l_supervisor_emp_id;
    EXCEPTION WHEN NO_DATA_FOUND THEN
      p_result := 'COMPLETE:NU';
      return;
    END;


     CheckUserInTable(p_item_type,
		      p_item_key,
		      l_approver_id,
		      'N',
		      l_count);

     if l_count =0 THEN
        p_result := 'COMPLETE:NA';
     else
        p_result := 'COMPLETE:Y';
     end if;

     if p_result = 'COMPLETE:Y'THEN
	GetEmployeeInfo(l_approver_id,
			p_item_type,
			p_item_key,
			'N');
     end if;

   return;

  end if; -- end of run mode

  --
  -- CANCEL mode
  --
  -- This is an event point is called with the effect of the activity must
  -- be undone, for example when a process is reset to an earlier point
  -- due to a loop back.
  --
  if (p_funcmode = 'CANCEL') then

    -- no result needed
    p_result := 'COMPLETE:';
    return;
  end if;


  --
  -- Other execution modes may be created in the future.  Your
  -- activity will indicate that it does not implement a mode
  -- by returning null
  --
  p_result := '';
  return;

exception
  when others then
    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context('ARP_CMREQ_WF', 'FindNextNonPrimaryApprover',
                    p_item_type, p_item_key, to_char(p_actid), p_funcmode);
    raise;

end FindNextNonPrimaryApprover;

PROCEDURE CheckUserInHR(   p_employee_id      IN NUMBER,
                           p_count            OUT NOCOPY NUMBER) IS

 l_debug_mesg 	      varchar2(240);
 l_reason_code        varchar2(45);
 l_currency_code      varchar2(30);

  cursor c1 is
  select count(*)
  from per_all_people_f
  where person_id=p_employee_id;

begin

     ------------------------------------------------------------
     l_debug_mesg := 'Checking if User exists in HR Table';
     ------------------------------------------------------------

      open c1;
      fetch c1 into p_count;
      close c1;

      return;

exception
  when others then
    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context('ARP_CMREQ_WF', 'CheckUserInHR',
                    null, null, null, l_debug_mesg);
    raise;

end CheckUserInHR;



PROCEDURE CheckUserInTable(p_item_type        IN  VARCHAR2,
                           p_item_key         IN  VARCHAR2,
			   p_employee_id      IN NUMBER,
			   p_primary_flag     IN VARCHAR2,
			   p_count            OUT NOCOPY NUMBER) IS

 l_debug_mesg 	      varchar2(240);
 l_reason_code        varchar2(45);
 l_currency_code      varchar2(30);

  cursor c1 is
  select count(*)
  from ar_approval_user_limits aul
  where aul.reason_code   = l_reason_code
  and   aul.currency_code = l_currency_code
  and   aul.primary_flag  = p_primary_flag
  and   user_id = p_employee_id
  order by - aul.amount_from;

begin
  -- SetOrgContext (p_item_key);

     ------------------------------------------------------------
     l_debug_mesg := 'Checking if User exists in Approval Limits Table';
     ------------------------------------------------------------

     l_reason_code    := WF_ENGINE.GetItemAttrText(
                                            p_item_type,
                                            p_item_key,
                                            'REASON');

     l_currency_code   := WF_ENGINE.GetItemAttrText(
                                            p_item_type,
                                            p_item_key,
                                            'CURRENCY_CODE');

      open c1;
      fetch c1 into p_count;
      close c1;

      return;

exception
  when others then
    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context('ARP_CMREQ_WF', 'CheckUserInTable',
                    p_item_type, p_item_key, null, l_debug_mesg);
    raise;

end CheckUserInTable;

PROCEDURE SelectFirstPrimaryApproverId(p_reason_code              IN  VARCHAR2,
                                       p_currency_code            IN  VARCHAR2,
                                       p_approver_employee_id     OUT NOCOPY NUMBER) IS


cursor c1 is
  select aul.user_id
  from ar_approval_user_limits aul
  where aul.reason_code   = p_reason_code
  and   aul.currency_code = p_currency_code
  and   aul.primary_flag  = 'Y'
  order by - aul.amount_from;

l_debug_mesg varchar2(240);

j            Number := 1;
approver_id  number;

BEGIN
 ----------------------------------------------------------------------------
 l_debug_mesg := 'Select first employee_id with lowest dollar value';
 ---------------------------------------------------------------------------

 -- Populate value from cursor
    open c1;
     loop
       fetch c1 into approver_id;

       IF c1%notfound THEN
	p_approver_employee_id := -1 ;
	EXIT;
       END IF;

         if j = 1 then
           p_approver_employee_id := approver_id ;
           exit;
         end if;

       j := j + 1;

      end loop;
    close c1;

null;

 EXCEPTION
   WHEN NO_DATA_FOUND then
     p_approver_employee_id := -1 ;
   WHEN OTHERS THEN
     Wf_Core.Context('AR_CMREQ_WF', 'SelectFirstPrimaryApproverId',
                      null, null, null, l_debug_mesg);
     raise;
 END SelectFirstPrimaryApproverId;


PROCEDURE SelectPrimaryApproverId(p_reason_code           IN  VARCHAR2,
                                  p_currency_code         IN  VARCHAR2,
                                  p_approver_count        IN  NUMBER,
                                  p_approver_employee_id  OUT NOCOPY NUMBER) IS

cursor c1 is
  select aul.user_id
  from ar_approval_user_limits aul
  where aul.reason_code   = p_reason_code
  and   aul.currency_code = p_currency_code
  and   aul.primary_flag  = 'Y'
  order by - aul.amount_from;


l_debug_mesg varchar2(240);
approver_id  number;
i            number;

BEGIN

-----------------------------------------------------------------------------
l_debug_mesg := 'Select employee_id with dollar value larger than previous one';
------------------------------------------------------------------------------
  -- initialize the number
  i := 1 ;

   -- find the approver id
    open c1;
     loop
       fetch c1 into approver_id;

       IF c1%notfound THEN
	p_approver_employee_id := -1 ;
	EXIT;
       END IF;

         if i = p_approver_count  then
           p_approver_employee_id := approver_id ;
           i := i + 1 ;
           exit;
         end if;

        i := i + 1;

      end loop;
    close c1;


  EXCEPTION
   WHEN NO_DATA_FOUND then
     p_approver_employee_id := -1 ;
   WHEN OTHERS THEN
     Wf_Core.Context('AR_CMREQ_WF', 'SelectPrimaryApproverId',
                      null, null, null, l_debug_mesg);
     raise;

 END SelectPrimaryApproverId;

PROCEDURE GetEmployeeInfo(
			   p_user_id		   in  number,
                           p_item_type             in  varchar2,
                           p_item_key              in  varchar2,
                           p_primary_approver_flag in  varchar2) IS

l_debug_mesg             varchar2(240);
l_approver_user_name     varchar2(100);
l_approver_display_name  varchar2(240);
l_manager_name           varchar2(100);
l_manager_display_name   varchar(240);


BEGIN

   -------------------------------------------------------------------
   l_debug_mesg := 'Trying to get employee information';
   -------------------------------------------------------------------

   -- set username and display name for a primary approver

   if ( p_primary_approver_flag = 'Y') then

       GetUserInfoFromTable(
			    p_user_id,
			    p_primary_approver_flag,
                            l_approver_user_name,
                            l_approver_display_name);

   IF l_approver_user_name IS NOT NULL THEN

        WF_ENGINE.SetItemAttrNumber(p_item_type,
                                    p_item_key,
                                    'APPROVER_ID',
                                    p_user_id);

        WF_ENGINE.SetItemAttrText(p_item_type,
                                  p_item_key,
                                  'APPROVER_USER_NAME',
                                  l_approver_user_name);

        WF_ENGINE.SetItemAttrText(p_item_type,
                                  p_item_key,
                                  'APPROVER_DISPLAY_NAME',
                                  l_approver_display_name);
   END IF;

    else

      -- set username and display name for a manager
      GetUserInfoFromTable(
			   p_user_id,
			   p_primary_approver_flag,
                           l_manager_name,
                           l_manager_display_name);

     IF l_manager_name IS NOT NULL THEN

      WF_ENGINE.SetItemAttrNumber(p_item_type,
                                  p_item_key,
                                  'MANAGER_ID',
                                  p_user_id);

      WF_ENGINE.SetItemAttrText(p_item_type,
                                p_item_key,
                                'MANAGER_USER_NAME',
                                l_manager_name);

      WF_ENGINE.SetItemAttrText(p_item_type,
                                p_item_key,
                                'MANAGER_DISPLAY_NAME',
                                l_manager_display_name);

      WF_ENGINE.SetItemAttrNumber(p_item_type,
                                  p_item_key,
                                  'APPROVER_ID',
                                  p_user_id);

      WF_ENGINE.SetItemAttrText(p_item_type,
                                p_item_key,
                                'APPROVER_USER_NAME',
                                l_manager_name);

      WF_ENGINE.SetItemAttrText(p_item_type,
                                p_item_key,
                                'APPROVER_DISPLAY_NAME',
                                l_manager_display_name);

   END IF;

    end if;

EXCEPTION
  WHEN OTHERS THEN
    Wf_Core.Context('ARP_CMREQ_WF', 'GetEmployeeInfo',
                     p_item_type, p_item_key, null, l_debug_mesg);
    raise;
END GetEmployeeInfo;


PROCEDURE GetUserInfoFromTable(p_user_id   IN  NUMBER,
         		       p_primary_approver_flag IN VARCHAR2,
                               p_user_name     OUT NOCOPY VARCHAR2,
                               p_display_name  OUT NOCOPY VARCHAR2) IS

 l_debug_mesg             varchar2(240);
 l_employee_id                number;
 l_user_name              varchar2(100);
 l_display_name           varchar2(240);

BEGIN

  ----------------------------------------------------------------
  l_debug_mesg := 'Get user info for an employee';
  ----------------------------------------------------------------

  -- can not use default WF_DIRECTORY.GetUserName to get user info
  -- because it can get user name which is not defined in limits
  -- table, the reason is multiply user names have been defined for
  -- such employee and the first one is returned by GetUserName.
  -- need to write a sql function to get user info.

  -- select user_id for a primary approver

SELECT employee_id
INTO l_employee_id
FROM fnd_user
WHERE user_id = p_user_id;


  select wu.name, wu.display_name
  into   p_user_name, p_display_name
  from wf_users wu, fnd_user fu
  where wu.orig_system    = 'PER'
  and   wu.orig_system_id = l_employee_id
  and   wu.orig_system_id = fu.employee_id
  and   fu.user_id = p_user_id
  and   fu.user_name = wu.name;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
     p_user_name := NULL ;
     p_display_name := NULL ;

   WHEN OTHERS THEN
      wf_core.Context('ARP_CMREQ_WF', 'GetUserInfoFromTable',
                           null, null, null, l_debug_mesg);
      raise;

END GetUserInfoFromTable;

PROCEDURE FindManager  (p_item_type        IN  VARCHAR2,
                        p_item_key         IN  VARCHAR2,
                        p_actid            IN  NUMBER,
                        p_funcmode         IN  VARCHAR2,
                        p_result           OUT NOCOPY VARCHAR2) IS

  l_debug_info                  VARCHAR2(200);
  l_employee_id                 number;
  l_manager_id			number;
  l_manager_user_name		varchar2(100);
  l_manager_display_name	varchar2(240);
  l_escalation_count		number;
  /* Bug 3195343 */
  l_approver_id                 number;
  l_manager_user_id             number;
  Cursor c1 is
    SELECT employee_id
    FROM   fnd_user
    WHERE  user_id = l_approver_id;
  Cursor c2 is
    Select user_id
    From   fnd_user
    Where  employee_id = l_manager_id ;
BEGIN
  -- SetOrgContext (p_item_key);
  --
  -- RUN mode - normal process execution
  --
  if (p_funcmode = 'RUN') then

  -------------------------------------------------------
  l_debug_info := 'Trying to retrieve employee manager';
  -------------------------------------------------------

 l_escalation_count  := WF_ENGINE.GetItemAttrNumber(
                                            p_item_type,
                                            p_item_key,
                                            'ESCALATION_COUNT');

 /* Bug 3195343 Changes l_employee_id to l_approver_id */
 IF l_escalation_count=0 THEN

  l_approver_id         := WF_ENGINE.GetItemAttrNumber(p_item_type,
                                                          p_item_key,
                                                          'APPROVER_ID');
 ELSE

  l_approver_id         := WF_ENGINE.GetItemAttrNumber(p_item_type,
                                                       p_item_key,
					        	'MANAGER_ID');

 END IF;

  /* Bug 3195343 Added the following query to get the employee_id
     for a particular user_id.*/
     Open c1;
     Fetch c1 into l_employee_id;
     Close c1;

  SELECT hremp.supervisor_id
  INTO   l_manager_id
  FROM   per_all_assignments_f  hremp
  WHERE  hremp.person_id = l_employee_id
  AND primary_flag = 'Y'          -- get primary assgt
  AND assignment_type = 'E'       -- ensure emp assgt, not applicant assgt
  AND trunc(sysdate) BETWEEN hremp.effective_start_date AND
                             hremp.effective_end_date;

  p_result := 'COMPLETE:T';

  l_escalation_count := l_escalation_count + 1;

  WF_ENGINE.SetItemAttrNumber(  p_item_type,
                                p_item_key,
                                'ESCALATION_COUNT',
                                l_escalation_count);

  /*Bug 3195343 Retrieving user_id to be stored in the attribute
                MANAGER_ID */
  Open c2;
  Fetch c2 into l_manager_user_id ;
  Close c2;

  WF_ENGINE.SetItemAttrNumber(p_item_type,
                                p_item_key,
                                 'MANAGER_ID',
                           l_manager_user_id);

  WF_DIRECTORY.GetUserName('PER',
			    to_char(l_manager_id),
			    l_manager_user_name,
			    l_manager_display_name);

  WF_ENGINE.SetItemAttrText(p_item_type,
                                 p_item_key,
                                 'MANAGER_USER_NAME',
                                 l_manager_user_name);

  WF_ENGINE.SetItemAttrText(p_item_type,
                                 p_item_key,
                                 'MANAGER_DISPLAY_NAME',
                                 l_manager_display_name);

  return;

  end if; -- end of run mode

  --
  -- CANCEL mode
  --
  -- This is an event point is called with the effect of the activity must
  -- be undone, for example when a process is reset to an earlier point
  -- due to a loop back.
  --
  if (p_funcmode = 'CANCEL') then

    -- no result needed
    p_result := 'COMPLETE:';
    return;
  end if;


  --
  -- Other execution modes may be created in the future.  Your
  -- activity will indicate that it does not implement a mode
  -- by returning null
  --
  p_result := '';
  return;


EXCEPTION
  WHEN NO_DATA_FOUND THEN
    l_manager_id := NULL;
    p_result := 'COMPLETE:F';
    return;
  WHEN OTHERS THEN
    Wf_Core.Context('ARP_CMREQ_WF', 'FindManager',
                     null, null, null, l_debug_info);
    raise;
END FindManager;

PROCEDURE RecordCollectorAsApprover(p_item_type        IN  VARCHAR2,
                                    p_item_key         IN  VARCHAR2,
                                    p_actid            IN  NUMBER,
                                    p_funcmode         IN  VARCHAR2,
                                    p_result           OUT NOCOPY VARCHAR2) IS

 l_debug_mesg                      varchar2(240);
 l_collector_employee_id           number;
 l_collector_display_name          varchar2(240);
 l_collector_user_name             varchar2(100);
 /* Bug 3195343 */
 l_collector_user_id               number;
 Cursor c1 is
  Select user_id
  From   fnd_user
  Where  employee_id  = l_collector_employee_id;

begin

  -- SetOrgContext (p_item_key);

  --
  -- RUN mode - normal process execution
  --
  if (p_funcmode = 'RUN') then

     ------------------------------------------------------------
     l_debug_mesg := 'Record collector as approver';
     ------------------------------------------------------------


     l_collector_employee_id   := WF_ENGINE.GetItemAttrNumber(
                                                      p_item_type,
                                                      p_item_key,
                                                      'COLLECTOR_EMPLOYEE_ID');

     /* Bug 3195343 Retrieving user_id from employee_id. */
        Open c1;
	Fetch c1 into l_collector_user_id;
	Close c1;

     WF_ENGINE.SetItemAttrNumber(p_item_type,
                                 p_item_key,
                                 'APPROVER_ID',
                                 l_collector_user_id);

     l_collector_user_name    := WF_ENGINE.GetItemAttrText(p_item_type,
                                                     p_item_key,
                                                     'COLLECTOR_USER_NAME');
     WF_ENGINE.SetItemAttrText(p_item_type,
                               p_item_key,
                              'APPROVER_USER_NAME',
                              l_collector_user_name);


     l_collector_display_name  := WF_ENGINE.GetItemAttrText(p_item_type,
                                                     p_item_key,
                                                     'COLLECTOR_DISPLAY_NAME');
     WF_ENGINE.SetItemAttrText(p_item_type,
                               p_item_key,
                               'APPROVER_DISPLAY_NAME',
                               l_collector_display_name);



   p_result := 'COMPLETE:T';
   return;

  end if; -- end of run mode

  --
  -- CANCEL mode
  --

  if (p_funcmode = 'CANCEL') then

    -- no result needed
    p_result := 'COMPLETE:';
    return;
  end if;


  --
  -- Other execution modes
  --
  p_result := '';
  return;

exception
  when others then
    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context('ARP_CMREQ_WF', 'RecordCollectorAsApprover',
		    p_item_type, p_item_key, to_char(p_actid), p_funcmode);
    raise;

end RecordCollectorAsApprover;



PROCEDURE RecordCollectorAsForwardFrom(p_item_type        IN  VARCHAR2,
                                       p_item_key         IN  VARCHAR2,
                                       p_actid            IN  NUMBER,
                                       p_funcmode         IN  VARCHAR2,
                                       p_result           OUT NOCOPY VARCHAR2) IS


 l_debug_mesg                      varchar2(240);
 l_collector_employee_id           number;
 l_collector_display_name          varchar2(240);
 l_collector_user_name             varchar2(100);
 l_notes                           varchar2(240);
 l_approver_notes                  varchar2(100);
 CRLF        			   varchar2(1);

begin

  -- SetOrgContext (p_item_key);

  -- Bug 2105483 : rather then calling arp_global at the start
  -- of the package, where it can error out NOCOPY since org_id is not yet set,
  -- do the call right before it is needed
  arp_global.init_global;
  CRLF := arp_global.CRLF;

  --
  -- RUN mode - normal process execution
  --
  if (p_funcmode = 'RUN') then

     ------------------------------------------------------------
     l_debug_mesg := 'Get the user name of collector';
     ------------------------------------------------------------


     l_collector_employee_id   := WF_ENGINE.GetItemAttrNumber(
                                                      p_item_type,
                                                      p_item_key,
                                                      'COLLECTOR_EMPLOYEE_ID');
     WF_ENGINE.SetItemAttrNumber(p_item_type,
                                 p_item_key,
                                 'FORWARD_FROM_ID',
                                 l_collector_employee_id);





     l_collector_user_name    := WF_ENGINE.GetItemAttrText(p_item_type,
                                                     p_item_key,
                                                     'COLLECTOR_USER_NAME');
     WF_ENGINE.SetItemAttrText(p_item_type,
                               p_item_key,
                              'FORWARD_FROM_USER_NAME',
                              l_collector_user_name);


     l_collector_display_name  := WF_ENGINE.GetItemAttrText(p_item_type,
                                                     p_item_key,
                                                     'COLLECTOR_DISPLAY_NAME');
     WF_ENGINE.SetItemAttrText(p_item_type,
                               p_item_key,
                               'FORWARD_FROM_DISPLAY_NAME',
                               l_collector_display_name);

     -- Add the collector user name in front of notes field.



     l_approver_notes          :=  WF_ENGINE.GetItemAttrText(p_item_type,
                                                      p_item_key,
                                                     'APPROVER_NOTES');

     l_notes                   := l_collector_user_name  ||
                                  ': ' || l_approver_notes  || CRLF;


     WF_ENGINE.SetItemAttrText(p_item_type,
                               p_item_key,
                               'NOTES',
                               l_notes);

     -- Initialize the approver_notes

    l_approver_notes          := NULL;

    WF_ENGINE.SetItemAttrText(p_item_type,
                               p_item_key,
                               'APPROVER_NOTES',
                               l_approver_notes);


   p_result := 'COMPLETE:T';
   return;

  end if; -- end of run mode

  --
  -- CANCEL mode
  --

  if (p_funcmode = 'CANCEL') then

    -- no result needed
    p_result := 'COMPLETE:';
    return;
  end if;


  --
  -- Other execution modes
  --
  p_result := '';
  return;

exception
  when others then
    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context('ARP_CMREQ_WF', 'RecordCollectorAsForwardFrom',
		    p_item_type, p_item_key, to_char(p_actid), p_funcmode);
    raise;

end RecordCollectorAsForwardFrom;


PROCEDURE RecordForwardToUserInfo(p_item_type        IN  VARCHAR2,
                                  p_item_key         IN  VARCHAR2,
                                  p_actid            IN  NUMBER,
                                  p_funcmode         IN  VARCHAR2,
                                  p_result           OUT NOCOPY VARCHAR2) IS


 l_debug_mesg                     varchar2(240);
 l_approver_id                    number;
 l_approver_display_name          varchar2(240);
 l_approver_user_name             varchar2(100);



begin
    -- SetOrgContext (p_item_key);

  --
  -- RUN mode - normal process execution
  --
  if (p_funcmode = 'RUN') then

     ------------------------------------------------------------
     l_debug_mesg := 'Get the user name of approver';
     ------------------------------------------------------------

     l_approver_id         := WF_ENGINE.GetItemAttrNumber(p_item_type,
                                                          p_item_key,
                                                          'APPROVER_ID');
     WF_ENGINE.SetItemAttrNumber(p_item_type,
                                 p_item_key,
                                 'FORWARD_TO_ID',
                                 l_approver_id);



     l_approver_user_name    := WF_ENGINE.GetItemAttrText(p_item_type,
                                                     p_item_key,
                                                     'APPROVER_USER_NAME');
     WF_ENGINE.SetItemAttrText(p_item_type,
                               p_item_key,
                              'FORWARD_TO_USER_NAME',
                              l_approver_user_name);


     l_approver_display_name    := WF_ENGINE.GetItemAttrText(p_item_type,
                                                     p_item_key,
                                                     'APPROVER_DISPLAY_NAME');
     WF_ENGINE.SetItemAttrText(p_item_type,
                               p_item_key,
                               'FORWARD_TO_DISPLAY_NAME',
                               l_approver_display_name);



   p_result := 'COMPLETE:T';
   return;

  end if; -- end of run mode

  --
  -- CANCEL mode
  --
  -- This is an event point is called with the effect of the activity must
  -- be undone, for example when a process is reset to an earlier point
  -- due to a loop back.
  --
  if (p_funcmode = 'CANCEL') then

    -- no result needed
    p_result := 'COMPLETE:';
    return;
  end if;


  --
  -- Other execution modes may be created in the future.  Your
  -- activity will indicate that it does not implement a mode
  -- by returning null
  --
  p_result := '';
  return;

exception
  when others then
    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context('ARP_CMREQ_WF', 'RecordForwardToUserInfo',
		    p_item_type, p_item_key, to_char(p_actid), p_funcmode);
    raise;

end RecordForwardToUserInfo;

PROCEDURE CheckForwardFromUser(p_item_type        IN  VARCHAR2,
                               p_item_key         IN  VARCHAR2,
                               p_actid            IN  NUMBER,
                               p_funcmode         IN  VARCHAR2,
                               p_result           OUT NOCOPY VARCHAR2) IS

 l_debug_mesg                     varchar2(240);
 l_forward_from_user_name             varchar2(100);



begin
   -- SetOrgContext (p_item_key);
  --
  -- RUN mode - normal process execution
  --
  if (p_funcmode = 'RUN') then

     ------------------------------------------------------------
     l_debug_mesg := 'Get the user name of forward from user';
     ------------------------------------------------------------

     l_forward_from_user_name    := WF_ENGINE.GetItemAttrText(
                                                     p_item_type,
                                                     p_item_key,
                                                     'FORWARD_FROM_USER_NAME');


     if  l_forward_from_user_name is not NULL then
       p_result := 'COMPLETE:T';
       return;
     else
       p_result := 'COMPLETE:F';
       return;
     end if;

  end if; -- end of run mode

  --
  -- CANCEL mode
  --
  --
  if (p_funcmode = 'CANCEL') then

    -- no result needed
    p_result := 'COMPLETE:';
    return;
  end if;


  --
  -- Other execution mode

  p_result := '';
  return;

exception
  when others then
    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context('ARP_CMREQ_WF', 'CheckForwardFromUser',
		    p_item_type, p_item_key, to_char(p_actid), p_funcmode);
    raise;

end CheckForwardFromUser;

PROCEDURE RecordApproverAsForwardFrom(p_item_type         IN  VARCHAR2,
                                       p_item_key         IN  VARCHAR2,
                                       p_actid            IN  NUMBER,
                                       p_funcmode         IN  VARCHAR2,
                                       p_result           OUT NOCOPY VARCHAR2) IS

 l_debug_mesg                varchar2(240);
 l_approver_id               number;
 l_approver_user_name        varchar2(100);
 l_approver_display_name     varchar2(240);
 l_notes                     varchar2(240);
 l_approver_notes            varchar2(100);
 CRLF    		     varchar2(1);

begin
     SetOrgContext (p_item_key);

    -- Bug 2105483 : rather then calling arp_global at the start
    -- of the package, where it can error out NOCOPY since org_id is not yet set,
    -- do the call right before it is needed
    arp_global.init_global;
    CRLF := arp_global.CRLF;

  --
  -- RUN mode - normal process execution
  --
  if (p_funcmode = 'RUN') then

     ------------------------------------------------------------
     l_debug_mesg := 'Get info for an approver';
     ------------------------------------------------------------



     l_approver_id         := WF_ENGINE.GetItemAttrNumber(p_item_type,
                                                          p_item_key,
                                                          'APPROVER_ID');
     WF_ENGINE.SetItemAttrNumber(p_item_type,
                                 p_item_key,
                                 'FORWARD_FROM_ID',
                                 l_approver_id);



     l_approver_user_name    := WF_ENGINE.GetItemAttrText(p_item_type,
                                                     p_item_key,
                                                     'APPROVER_USER_NAME');
     WF_ENGINE.SetItemAttrText(p_item_type,
                               p_item_key,
                              'FORWARD_FROM_USER_NAME',
                              l_approver_user_name);


     l_approver_display_name    := WF_ENGINE.GetItemAttrText(p_item_type,
                                                     p_item_key,
                                                     'APPROVER_DISPLAY_NAME');
     WF_ENGINE.SetItemAttrText(p_item_type,
                               p_item_key,
                               'FORWARD_FROM_DISPLAY_NAME',
                               l_approver_display_name);

      -- Add the approver user name in front of notes field.

     l_notes                   :=  WF_ENGINE.GetItemAttrText(p_item_type,
                                                     p_item_key,
                                                     'NOTES');

     l_approver_notes          :=  WF_ENGINE.GetItemAttrText(p_item_type,
                                                     p_item_key,
                                                     'APPROVER_NOTES');


     l_notes                   := l_notes ||  l_approver_user_name ||
                                  ': ' || l_approver_notes || CRLF;


     WF_ENGINE.SetItemAttrText(p_item_type,
                               p_item_key,
                               'NOTES',
                               l_notes);

    -- Initialize the approver_notes

    l_approver_notes          := NULL;

    WF_ENGINE.SetItemAttrText(p_item_type,
                               p_item_key,
                               'APPROVER_NOTES',
                               l_approver_notes);



   p_result := 'COMPLETE:T';
   return;

  end if; -- end of run mode

  --
  -- CANCEL mode
  --

  if (p_funcmode = 'CANCEL') then

    -- no result needed
    p_result := 'COMPLETE:';
    return;
  end if;


  --
  -- Other execution modes
  --
  p_result := '';
  return;

exception
  when others then
    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context('ARP_CMREQ_WF', 'RecordApproverAsForwardFrom',
		    p_item_type, p_item_key, to_char(p_actid), p_funcmode);
    raise;

end RecordApproverAsForwardFrom;

PROCEDURE FinalApprover(p_item_type        IN  VARCHAR2,
                        p_item_key         IN  VARCHAR2,
                        p_actid            IN  NUMBER,
                        p_funcmode         IN  VARCHAR2,
                        p_result           OUT NOCOPY VARCHAR2) IS


 l_debug_mesg                 varchar2(240);
 l_approver_id                number;
 l_reason_code                varchar2(45);
 l_currency_code              varchar2(15);
 l_total_credit_to_invoice    number;
 l_result_flag                varchar2(1);

begin
  --uncommented for bug 5410467
  SetOrgContext (p_item_key);
  ---------------------------------------------------------
  l_debug_mesg   := 'if approver is  a final approver';
  ---------------------------------------------------------


  --
  -- RUN mode - normal process execution
  --
  if (p_funcmode = 'RUN') then

    l_reason_code    := WF_ENGINE.GetItemAttrText(
                                            p_item_type,
                                            p_item_key,
                                            'REASON');

    l_currency_code   := WF_ENGINE.GetItemAttrText(
                                            p_item_type,
                                            p_item_key,
                                            'CURRENCY_CODE');

    l_total_credit_to_invoice:= WF_ENGINE.GetItemAttrNumber(
                                             p_item_type,
                                             p_item_key,
                                             'TOTAL_CREDIT_TO_INVOICE');



    l_approver_id      := WF_ENGINE.GetItemAttrNumber(p_item_type,
                                                      p_item_key,
                                                      'APPROVER_ID');
/* Bug 9464009 Un comment wrongly commented code.*/
    CheckFinalApprover(l_reason_code,
                       l_currency_code,
                       l_total_credit_to_invoice,
                       l_approver_id,
                       l_result_flag);



   if (l_result_flag = 'Y')  then

     -- it is a final aprrover
     p_result := 'COMPLETE:T';
     return;
   else
     p_result := 'COMPLETE:F';
     return;
   end if;

     --fix for 5410467
     p_result := 'COMPLETE:T';
     return;
     --fix for 5410467 ends here.
  end if; -- end of run mode

  --
  -- CANCEL mode
  --

  if (p_funcmode = 'CANCEL') then

    -- no result needed
    p_result := 'COMPLETE:';
    return;
  end if;


  --
  -- Other execution modes
  --
  p_result := '';
  return;

exception
  when others then
    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context('ARP_CMREQ_WF', 'FinalApprover',
		    p_item_type, p_item_key, to_char(p_actid), p_funcmode);
    raise;

end FinalApprover;

PROCEDURE CheckFinalApprover(p_reason_code                 IN  VARCHAR2,
                             p_currency_code               IN  VARCHAR2,
                             p_amount	 	           IN  VARCHAR2,
                             p_approver_id                 IN  NUMBER,
                             p_result_flag                 OUT NOCOPY VARCHAR2) IS

l_debug_mesg    varchar2(240);
l_amount_to     number;
l_amount_from   number;

 begin

   ---------------------------------------------------------------------------
   l_debug_mesg := 'Check if the selected approver is a final one';
   ---------------------------------------------------------------------------

   select aul.amount_to, aul.amount_from
   into   l_amount_to, l_amount_from
   from ar_approval_user_limits aul
   where aul.user_id   = p_approver_id
   and aul.reason_code     = p_reason_code
   and aul.currency_code   = p_currency_code ;


   if ( ( p_amount <   l_amount_to) and
        ( p_amount >=  l_amount_from)) then

      p_result_flag := 'Y';
   else

      p_result_flag := 'N';
   end if ;

   return;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
      p_result_flag := 'N';
      return;
   WHEN OTHERS THEN
      wf_core.Context('ARP_CMREQ_WF', 'CheckFinalApprover',
                      null, null, null, l_debug_mesg);
      raise;

END CheckFinalApprover;

PROCEDURE RemoveFromDispute     (p_item_type        IN  VARCHAR2,
                                 p_item_key         IN  VARCHAR2,
                                 p_actid            IN  NUMBER,
                                 p_funcmode         IN  VARCHAR2,
                                 p_result           OUT NOCOPY VARCHAR2) IS

 l_debug_mesg varchar2(240);
 l_approver_id                number;
 l_reason_code                varchar2(45);
 l_currency_code              varchar2(15);
 l_total_credit_to_invoice    number;
 l_result_flag                varchar2(1);
 l_customer_trx_id            number;

 /* bug 4478232 */
 l_request_id                 number;
 new_dispute_date             date;
 new_dispute_amt              number;
 remove_from_dispute_amt      number;

/*4220382 */

CURSOR ps_cur(p_customer_trx_id NUMBER) IS
      SELECT payment_schedule_id, due_date, amount_in_dispute, dispute_date
         FROM  ar_payment_schedules ps
         WHERE  ps.customer_trx_id = p_customer_trx_id;

begin
  SetOrgContext (p_item_key);
  ---------------------------------------------------------
  l_debug_mesg   := 'Remove Transaction from Dispute';
  ---------------------------------------------------------

  --
  -- RUN mode - normal process execution
  --
  if (p_funcmode = 'RUN') then

        l_customer_trx_id   := WF_ENGINE.GetItemAttrNumber(
                                             p_item_type,
                                             p_item_key,
                                             'CUSTOMER_TRX_ID');

        l_request_id  := WF_ENGINE.GetItemAttrNumber(
                                    p_item_type,
                                    p_item_key,
                                    'WORKFLOW_DOCUMENT_ID');

        -- the amount stored in ra_cm_requests is a negative credit amount, it needs to
        -- be negated to get the correct dispute amount
        SELECT total_amount  * -1
          into remove_from_dispute_amt
          from ra_cm_requests
        WHERE request_id = l_request_id;

     /*4220382 */
      BEGIN

         FOR ps_rec  IN ps_cur (l_customer_trx_id )
         LOOP

               new_dispute_amt := ps_rec.amount_in_dispute - remove_from_dispute_amt;

               if new_dispute_amt = 0 then
                  new_dispute_date := null;
               else
                  new_dispute_date := ps_rec.dispute_date;
               end if;

                arp_process_cutil.update_ps
                     (p_ps_id=> ps_rec.payment_schedule_id,
	              p_due_date=> ps_rec.due_date,
	              p_amount_in_dispute=> new_dispute_amt,
	              p_dispute_date=> new_dispute_date,
                      p_update_dff => 'N',
	              p_attribute_category=>NULL,
	              p_attribute1=>NULL,
	              p_attribute2=>NULL,
	              p_attribute3=>NULL,
	              p_attribute4=>NULL,
	              p_attribute5=>NULL,
	              p_attribute6=>NULL,
	              p_attribute7=>NULL,
	              p_attribute8=>NULL,
	              p_attribute9=>NULL,
	              p_attribute10=>NULL,
	              p_attribute11=>NULL,
	              p_attribute12=>NULL,
	              p_attribute13=>NULL,
	              p_attribute14=>NULL,
	              p_attribute15=>NULL );

         END LOOP;
      END;

    l_reason_code    := WF_ENGINE.GetItemAttrText(
                                            p_item_type,
                                            p_item_key,
                                            'REASON');

   l_currency_code   := WF_ENGINE.GetItemAttrText(
                                            p_item_type,
                                            p_item_key,
                                            'CURRENCY_CODE');

   l_total_credit_to_invoice
                      := WF_ENGINE.GetItemAttrNumber(
                                             p_item_type,
                                             p_item_key,
                                             'TOTAL_CREDIT_TO_INVOICE');



    l_approver_id      := WF_ENGINE.GetItemAttrNumber(p_item_type,
                                                      p_item_key,
                                                      'APPROVER_ID');

/* Bug 9464009 check for dispute removal as below and comment check for final approval check*/
/*

    CheckFinalApprover(l_reason_code,
                       l_currency_code,
                       l_total_credit_to_invoice,
                       l_approver_id,
                       l_result_flag);



   if (l_result_flag = 'Y')  then
*/
   if new_dispute_amt = 0 then
          -- it is a final aprrover
     p_result := 'COMPLETE:T';
     return;
   else
     p_result := 'COMPLETE:F';
     return;
   end if;

  end if; -- end of run mode

  --
  -- CANCEL mode
  --

  if (p_funcmode = 'CANCEL') then

    -- no result needed
    p_result := 'COMPLETE:';
    return;
  end if;


  --
  -- Other execution modes
  --
  p_result := '';
  return;

exception
  when others then
    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context('ARP_CMREQ_WF', 'RemoveFromDispute',
                    p_item_type, p_item_key, to_char(p_actid), p_funcmode);
    raise;

end RemoveFromDispute;



PROCEDURE FindReceivableApprover(p_item_type        IN  VARCHAR2,
                                 p_item_key         IN  VARCHAR2,
                                 p_actid            IN  NUMBER,
                                 p_funcmode         IN  VARCHAR2,
                                 p_result           OUT NOCOPY VARCHAR2) IS

 l_debug_mesg varchar2(240);
 l_receivable_role   varchar2(240);
 l_role_display_name varchar2(240);
 l_role_id		number;

begin
   -- SetOrgContext (p_item_key);
  --
  -- RUN mode - normal process execution
  --
  if (p_funcmode = 'RUN') then

     -----------------------------------------------------------------
     l_debug_mesg := 'Check if Receivable Approver has been defined';
     -----------------------------------------------------------------

    l_receivable_role := WF_ENGINE.GetItemAttrText(p_item_type,
                             			   p_item_key,
                              			  'RECEIVABLE_ROLE');

    IF l_receivable_role IS NOT NULL THEN

        SELECT display_name,orig_system_id INTO l_role_display_name, l_role_id
        FROM wf_roles
        WHERE name = l_receivable_role;

         WF_ENGINE.SetItemAttrText(p_item_type,
                                      p_item_key,
                                      'APPROVER_USER_NAME',
                                      l_receivable_role);

	 WF_ENGINE.SetItemAttrText(p_item_type,
                                      p_item_key,
                                      'APPROVER_DISPLAY_NAME',
                                      l_role_display_name);

	WF_ENGINE.SetItemAttrNumber(p_item_type,
                                      p_item_key,
                                      'APPROVER_ID',
                                      l_role_id);

   	p_result := 'COMPLETE:T';
    ELSE
	p_result := 'COMPLETE:F';

    END IF;

    return;

  end if; -- end of run mode

  --
  -- CANCEL mode
  --
  -- This is an event point is called with the effect of the activity must
  -- be undone, for example when a process is reset to an earlier point
  -- due to a loop back.
  --
  if (p_funcmode = 'CANCEL') then

    -- no result needed
    p_result := 'COMPLETE:';
    return;
  end if;


  --
  -- Other execution modes may be created in the future.  Your
  -- activity will indicate that it does not implement a mode
  -- by returning null
  --
  p_result := '';
  return;

exception
  when others then
    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context('ARP_CMREQ_WF', 'FindReceivableApprover',
		    p_item_type, p_item_key, to_char(p_actid), p_funcmode);
    raise;

end FindReceivableApprover;


PROCEDURE FindResponder         (p_item_type        IN  VARCHAR2,
                                 p_item_key         IN  VARCHAR2,
                                 p_actid            IN  NUMBER,
                                 p_funcmode         IN  VARCHAR2,
                                 p_result           OUT NOCOPY VARCHAR2) IS

 l_debug_mesg varchar2(240);
 l_approver_id		number;
 l_approver_user_name   varchar2(100);
 l_approver_display_name varchar2(240);
 l_notification_id	number;

begin
  --uncommented for 5410467
  SetOrgContext (p_item_key);
  --
  -- RUN mode - normal process execution
  --
  if (p_funcmode = 'RESPOND') then

     -----------------------------------------------------------------
     l_debug_mesg := 'Find user in Receivable role who responded to
			the notification';
     -----------------------------------------------------------------

	l_notification_id :=    wf_engine.context_nid;
        l_approver_user_name := wf_engine.context_text;

        SELECT orig_system_id, display_name
	INTO l_approver_id, l_approver_display_name
        FROM wf_users
        WHERE orig_system = 'PER'
        AND   name = l_approver_user_name;

        WF_ENGINE.SetItemAttrText(p_item_type,
                                      p_item_key,
                                      'APPROVER_ID',
                                      l_approver_id);

         WF_ENGINE.SetItemAttrText(p_item_type,
                                      p_item_key,
                                      'APPROVER_USER_NAME',
                                      l_approver_user_name);

	 WF_ENGINE.SetItemAttrText(p_item_type,
                                      p_item_key,
                                      'APPROVER_DISPLAY_NAME',
                                      l_approver_display_name);

   	p_result := 'COMPLETE:T';
   	return;

  end if; -- end of run mode

  --
  -- CANCEL mode
  --
  -- This is an event point is called with the effect of the activity must
  -- be undone, for example when a process is reset to an earlier point
  -- due to a loop back.
  --
  if (p_funcmode = 'CANCEL') then

    -- no result needed
    p_result := 'COMPLETE:';
    return;
  end if;


  --
  -- Other execution modes may be created in the future.  Your
  -- activity will indicate that it does not implement a mode
  -- by returning null
  --
  p_result := '';
  return;

exception
  when others then
    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context('ARP_CMREQ_WF', 'FindResponder',
		    p_item_type, p_item_key, to_char(p_actid), p_funcmode);
    raise;

end FindResponder;


PROCEDURE InsertSubmissionNotes(p_item_type        IN  VARCHAR2,
                                p_item_key         IN  VARCHAR2,
                                p_actid            IN  NUMBER,
                                p_funcmode         IN  VARCHAR2,
                                p_result           OUT NOCOPY VARCHAR2) IS

 l_debug_mesg                 varchar2(240);

 l_document_id                number;
 l_requestor_user_name        varchar2(100);
 l_customer_trx_id            number;
 l_note_id                    number;
 l_reason_code                varchar2(45);
 l_total_credit_to_invoice    number;
 l_note_text                  ar_notes.text%type;
 /* Bug 3206020 Changed comments width from 240 to 1760 */
 l_comments                   varchar2(1760);
 l_reason_meaning             varchar2(100);

 /* Bug 7367350 inserting internal notes */
 l_internal_comment           VARCHAR2(1760) DEFAULT NULL;
 l_note_text1                  ar_notes.text%type;
 l_comment_type              VARCHAR2(20);

begin
  -- SetOrgContext (p_item_key);
-------------------------------------------------------------
  l_debug_mesg   := 'Insert WF submission notes';
  -----------------------------------------------------------

  --
  -- RUN mode - normal process execution
  --
  if (p_funcmode = 'RUN') then


    l_document_id    := WF_ENGINE.GetItemAttrNumber(
                                             p_item_type,
                                             p_item_key,
                                             'WORKFLOW_DOCUMENT_ID');

    l_requestor_user_name
                     := WF_ENGINE.GetItemAttrText(
                                            p_item_type,
                                            p_item_key,
                                            'REQUESTOR_USER_NAME');


    l_reason_code    := WF_ENGINE.GetItemAttrText(
                                            p_item_type,
                                            p_item_key,
                                            'REASON');


    l_total_credit_to_invoice
                      := WF_ENGINE.GetItemAttrNumber(
                                             p_item_type,
                                             p_item_key,
                                             'TOTAL_CREDIT_TO_INVOICE');


    l_customer_trx_id   := WF_ENGINE.GetItemAttrNumber(
                                             p_item_type,
                                             p_item_key,
                                             'CUSTOMER_TRX_ID');

    l_comments         := WF_ENGINE.GetItemAttrText(
                                            p_item_type,
                                            p_item_key,
                                            'COMMENTS');
    l_internal_comment     := wf_engine.GetItemAttrText(
                                            p_item_type,
                                            p_item_key,
                                            'INTERNAL_COMMENTS');

    -- bug fix 1202680 -- notes should reflect the reason meaning and not the code.
    begin
        select meaning into l_reason_meaning
        from ar_lookups
        where lookup_type = 'CREDIT_MEMO_REASON'
          and lookup_code = l_reason_code;
    exception
        when others then
            l_reason_meaning := l_reason_code;
    end;

    fnd_message.set_name('AR', 'AR_WF_SUBMISSION');
    fnd_message.set_token('REQUEST_ID', to_char(l_document_id));
    fnd_message.set_token('REQUESTOR',  l_requestor_user_name);
    fnd_message.set_token('AMOUNT',     to_char(l_total_credit_to_invoice));
    fnd_message.set_token('REASON',     l_reason_meaning);

    l_note_text := fnd_message.get;
    l_note_text1 := l_note_text;
    if l_comments is not NULL then
	select meaning into l_comment_type
 	  from ar_lookups
	  where  LOOKUP_TYPE='AR_COMMENT_CLASSIFICATION'
	  AND    LOOKUP_CODE='C';
      l_note_text := l_note_text || ' :' || l_comment_type || ':  "' || l_comments || '"';
    end if;
    IF  l_internal_comment  is NOT NULL then
	 select meaning into l_comment_type
 	  from ar_lookups
	  where  LOOKUP_TYPE='AR_COMMENT_CLASSIFICATION'
	  AND    LOOKUP_CODE='I';
  	  l_note_text1 := l_note_text1 || ' :' || l_comment_type || ':  "' || l_internal_comment || '"';

	  InsertTrxNotes(NULL,
                        NULL,
                        NULL,
                        l_customer_trx_id,
                        'MAINTAIN',
                        l_note_text1,
                        l_note_id);
    END IF;


         InsertTrxNotes(NULL,
                        NULL,
                        NULL,
                        l_customer_trx_id,
                        'MAINTAIN',
                        l_note_text,
                        l_note_id);


     p_result := 'COMPLETE:T';
     return;


  end if; -- end of run mode

  --
  -- CANCEL mode
  --

  if (p_funcmode = 'CANCEL') then

    -- no result needed
    p_result := 'COMPLETE:';
    return;
  end if;


  --
  -- Other execution modes
  --
  p_result := '';
  return;

exception
  when others then
    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context('ARP_CMREQ_WF', 'InsertSubmissionNotes',
		    p_item_type, p_item_key, to_char(p_actid), p_funcmode);
    raise;

end InsertSubmissionNotes;


PROCEDURE InsertApprovalReminderNotes(p_item_type        IN  VARCHAR2,
                                     p_item_key         IN  VARCHAR2,
                                     p_actid            IN  NUMBER,
                                     p_funcmode         IN  VARCHAR2,
                                     p_result           OUT NOCOPY VARCHAR2) IS

l_debug_mesg                 varchar2(240);

 l_document_id                number;
 l_customer_trx_id            number;
 l_approver_display_name         varchar2(100);
 l_note_id                    number;
 l_note_text                  ar_notes.text%type;
  l_notes                      wf_item_attribute_values.text_value%TYPE;  /*5119049 */

begin
  -- SetOrgContext (p_item_key);
  ---------------------------------------------------------------------
  l_debug_mesg   := 'Insert Request Approval Reminder notes';
  ---------------------------------------------------------------------

  --
  -- RUN mode - normal process execution
  --
  if (p_funcmode = 'RUN') then


    l_document_id    := WF_ENGINE.GetItemAttrNumber(
                                             p_item_type,
                                             p_item_key,
                                             'WORKFLOW_DOCUMENT_ID');

    l_customer_trx_id   := WF_ENGINE.GetItemAttrNumber(
                                             p_item_type,
                                             p_item_key,
                                             'CUSTOMER_TRX_ID');

    l_approver_display_name
                      := WF_ENGINE.GetItemAttrText(
                                             p_item_type,
                                             p_item_key,
                                             'APPROVER_DISPLAY_NAME');

    l_notes  := wf_engine.GetItemAttrText( p_item_type,  p_item_key,'NOTES'); /*5119049*/

    fnd_message.set_name('AR', 'AR_WF_APPROVAL_REMINDER');
    fnd_message.set_token('APPROVER',     l_approver_display_name);
 -- bug fix 1122477

    l_note_text := fnd_message.get;

    IF l_notes is NOT NULL then
       l_note_text := SUBSTRB(l_note_text || ' "' || l_notes || '"',1,2000) ;  /*5119049*/
    END IF;

         InsertTrxNotes(NULL,
                        NULL,
                        NULL,
                        l_customer_trx_id,
                        'MAINTAIN',
                        l_note_text,
                        l_note_id);

     /* Bug 3195343 Initialise the escalation_count attribute for the
             Primary approver. */

	     WF_ENGINE.SetItemAttrNumber(  p_item_type,
                                            p_item_key,
	                           'ESCALATION_COUNT',
                                                    0 ) ;
     p_result := 'COMPLETE:T';
     return;


  end if; -- end of run mode

  --
  -- CANCEL mode
  --

  if (p_funcmode = 'CANCEL') then

    -- no result needed
    p_result := 'COMPLETE:';
    return;
  end if;


  --
  -- Other execution modes
  --
  p_result := '';
  return;

exception
  when others then
    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context('ARP_CMREQ_WF', 'InsertApprovalReminderNotes',
		    p_item_type, p_item_key, to_char(p_actid), p_funcmode);
    raise;

end InsertApprovalReminderNotes;


PROCEDURE InsertEscalationNotes     (p_item_type        IN  VARCHAR2,
                                     p_item_key         IN  VARCHAR2,
                                     p_actid            IN  NUMBER,
                                     p_funcmode         IN  VARCHAR2,
                                     p_result           OUT NOCOPY VARCHAR2) IS

l_debug_mesg                 varchar2(240);

 l_document_id                number;
 l_customer_trx_id            number;
 l_manager_user_name         varchar2(100);
 l_note_id                    number;
 l_note_text                  ar_notes.text%type;
  l_notes                      wf_item_attribute_values.text_value%TYPE;  /*5119049 */

begin
  -- SetOrgContext (p_item_key);
  ---------------------------------------------------------------------
  l_debug_mesg   := 'Insert Escalation notes';
  ---------------------------------------------------------------------

  --
  -- RUN mode - normal process execution
  --
  if (p_funcmode = 'RUN') then


    l_document_id    := WF_ENGINE.GetItemAttrNumber(
                                             p_item_type,
                                             p_item_key,
                                             'WORKFLOW_DOCUMENT_ID');

    l_customer_trx_id   := WF_ENGINE.GetItemAttrNumber(
                                             p_item_type,
                                             p_item_key,
                                             'CUSTOMER_TRX_ID');

    l_manager_user_name
                      := WF_ENGINE.GetItemAttrText(
                                             p_item_type,
                                             p_item_key,
                                             'MANAGER_USER_NAME');

    l_notes  := wf_engine.GetItemAttrText( p_item_type,  p_item_key,'NOTES'); /*5119049*/

    fnd_message.set_name('AR', 'AR_WF_APPROVAL_ESCALATION');
    fnd_message.set_token('REQUEST_ID', to_char(l_document_id));
    fnd_message.set_token('APPROVER',     l_manager_user_name);

    l_note_text := fnd_message.get;

    IF l_notes is NOT NULL then
       l_note_text := SUBSTRB(l_note_text || ' "' || l_notes || '"',1,2000) ;  /*5119049*/
    END IF;

         InsertTrxNotes(NULL,
                        NULL,
                        NULL,
                        l_customer_trx_id,
                        'MAINTAIN',
                        l_note_text,
                        l_note_id);


     p_result := 'COMPLETE:T';
     return;


  end if; -- end of run mode

  --
  -- CANCEL mode
  --

  if (p_funcmode = 'CANCEL') then

    -- no result needed
    p_result := 'COMPLETE:';
    return;
  end if;


  --
  -- Other execution modes
  --
  p_result := '';
  return;

exception
  when others then
    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context('ARP_CMREQ_WF', 'InsertEscalationNotes',
		    p_item_type, p_item_key, to_char(p_actid), p_funcmode);
    raise;

end InsertEscalationNotes;


PROCEDURE InsertRequestManualNotes  (p_item_type        IN  VARCHAR2,
                                     p_item_key         IN  VARCHAR2,
                                     p_actid            IN  NUMBER,
                                     p_funcmode         IN  VARCHAR2,
                                     p_result           OUT NOCOPY VARCHAR2) IS

l_debug_mesg                 varchar2(240);

 l_document_id                number;
 l_customer_trx_id            number;
 l_receivable_role            varchar2(100);
 l_role_display_name	      varchar2(240);
 l_note_id                    number;
 l_note_text                  ar_notes.text%type;
  l_notes                      wf_item_attribute_values.text_value%TYPE;  /*5119049 */

begin
  -- SetOrgContext (p_item_key);
  ---------------------------------------------------------------------
  l_debug_mesg   := 'Insert Request Manual Entry notes';
  ---------------------------------------------------------------------

  --
  -- RUN mode - normal process execution
  --
  if (p_funcmode = 'RUN') then


    l_document_id    := WF_ENGINE.GetItemAttrNumber(
                                             p_item_type,
                                             p_item_key,
                                             'WORKFLOW_DOCUMENT_ID');

    l_customer_trx_id   := WF_ENGINE.GetItemAttrNumber(
                                             p_item_type,
                                             p_item_key,
                                             'CUSTOMER_TRX_ID');

    l_receivable_role
                      := WF_ENGINE.GetItemAttrText(
                                             p_item_type,
                                             p_item_key,
                                             'RECEIVABLE_ROLE');
    l_notes  := wf_engine.GetItemAttrText( p_item_type,  p_item_key,'NOTES'); /*5119049*/
     SELECT display_name INTO l_role_display_name
     FROM wf_roles
     WHERE name = l_receivable_role;

    fnd_message.set_name('AR', 'AR_WF_REQUEST_MANUAL');
    fnd_message.set_token('REQUEST_ID', to_char(l_document_id));
    fnd_message.set_token('RECEIVABLE_ROLE',l_role_display_name);

    l_note_text := fnd_message.get;

    IF l_notes is NOT NULL then
       l_note_text := SUBSTRB(l_note_text || ' "' || l_notes || '"',1,2000) ;  /*5119049*/
    END IF;

         InsertTrxNotes(NULL,
                        NULL,
                        NULL,
                        l_customer_trx_id,
                        'MAINTAIN',
                        l_note_text,
                        l_note_id);


     p_result := 'COMPLETE:T';
     return;


  end if; -- end of run mode

  --
  -- CANCEL mode
  --

  if (p_funcmode = 'CANCEL') then

    -- no result needed
    p_result := 'COMPLETE:';
    return;
  end if;


  --
  -- Other execution modes
  --
  p_result := '';
  return;

exception
  when others then
    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context('ARP_CMREQ_WF', 'InsertRequestManualNotes',
		    p_item_type, p_item_key, to_char(p_actid), p_funcmode);
    raise;

end InsertRequestManualNotes;


PROCEDURE InsertCompletedManualNotes(p_item_type        IN  VARCHAR2,
                                     p_item_key         IN  VARCHAR2,
                                     p_actid            IN  NUMBER,
                                     p_funcmode         IN  VARCHAR2,
                                     p_result           OUT NOCOPY VARCHAR2) IS

 l_debug_mesg                 varchar2(240);
 l_document_id                number;
 l_customer_trx_id            number;
 l_receivable_role            varchar2(100);
 l_role_display_name	      varchar2(240);
 l_note_id                    number;
 l_note_text                  ar_notes.text%type;
  l_notes                      wf_item_attribute_values.text_value%TYPE;  /*5119049 */

 /* bug 1908252 */
 l_last_updated_by     number;
 l_last_update_login   number;

BEGIN
  -- SetOrgContext (p_item_key);

  -- Bug 2105483 : rather then calling arp_global at the start
  -- of the package, where it can error out NOCOPY since org_id is not yet set,
  -- do the call right before it is needed
  arp_global.init_global;

  /* Bug 1908252 */
  l_last_updated_by   := ARP_GLOBAL.user_id;
  l_last_update_login := ARP_GLOBAL.last_update_login ;

  ---------------------------------------------------------------------
  l_debug_mesg   := 'Insert Completed Manual Entry notes';
  ---------------------------------------------------------------------

  --
  -- RUN mode - normal process execution
  --
  if (p_funcmode = 'RUN') then


    l_document_id    := WF_ENGINE.GetItemAttrNumber(
                                             p_item_type,
                                             p_item_key,
                                             'WORKFLOW_DOCUMENT_ID');

    l_customer_trx_id   := WF_ENGINE.GetItemAttrNumber(
                                             p_item_type,
                                             p_item_key,
                                             'CUSTOMER_TRX_ID');

    l_receivable_role
                      := WF_ENGINE.GetItemAttrText(
                                             p_item_type,
                                             p_item_key,
                                             'RECEIVABLE_ROLE');
    l_notes  := wf_engine.GetItemAttrText( p_item_type,  p_item_key,'NOTES'); /*5119049*/

    SELECT display_name INTO l_role_display_name
    FROM wf_roles
    WHERE   name = l_receivable_role;



    fnd_message.set_name('AR', 'AR_WF_COMPLETED_MANUAL');
    fnd_message.set_token('REQUEST_ID', to_char(l_document_id));
    fnd_message.set_token('APPROVER',l_role_display_name);

    l_note_text := fnd_message.get;

    IF l_notes is NOT NULL then
       l_note_text := SUBSTRB(l_note_text || ' "' || l_notes || '"',1,2000) ;  /*5119049*/
    END IF;

    InsertTrxNotes(NULL,
                   NULL,
                   NULL,
                   l_customer_trx_id,
                   'MAINTAIN',
                   l_note_text,
                   l_note_id);

     /* Bug 1908252 : update last_update* fields */
     update ra_cm_requests
	set status = 'COMPLETE',
	    approval_date = SYSDATE,
            last_updated_by = l_last_updated_by,
            last_update_date = SYSDATE,
            last_update_login = l_last_update_login
	where request_id = p_item_key;

     p_result := 'COMPLETE:T';
     return;


  end if; -- end of run mode

  --
  -- CANCEL mode
  --

  if (p_funcmode = 'CANCEL') then

    -- no result needed
    p_result := 'COMPLETE:';
    return;
  end if;


  --
  -- Other execution modes
  --
  p_result := '';
  return;

exception
  when others then
    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context('ARP_CMREQ_WF', 'InsertCompletedManualNotes',
		    p_item_type, p_item_key, to_char(p_actid), p_funcmode);
    raise;

end InsertCompletedManualNotes;


PROCEDURE InsertRequestApprovalNotes(p_item_type        IN  VARCHAR2,
                                     p_item_key         IN  VARCHAR2,
                                     p_actid            IN  NUMBER,
                                     p_funcmode         IN  VARCHAR2,
                                     p_result           OUT NOCOPY VARCHAR2) IS

l_debug_mesg                 varchar2(240);

 l_document_id                number;
 l_customer_trx_id            number;
 l_approver_display_name         varchar2(100);
 l_note_id                    number;
 l_note_text                  ar_notes.text%type;
  l_notes                      wf_item_attribute_values.text_value%TYPE;  /*5119049 */

begin
  -- SetOrgContext (p_item_key);
  ---------------------------------------------------------------------
  l_debug_mesg   := 'Insert Request Approval notes';
  ---------------------------------------------------------------------

  --
  -- RUN mode - normal process execution
  --
  if (p_funcmode = 'RUN') then


    l_document_id    := WF_ENGINE.GetItemAttrNumber(
                                             p_item_type,
                                             p_item_key,
                                             'WORKFLOW_DOCUMENT_ID');

    l_customer_trx_id   := WF_ENGINE.GetItemAttrNumber(
                                             p_item_type,
                                             p_item_key,
                                             'CUSTOMER_TRX_ID');

    l_approver_display_name
                      := WF_ENGINE.GetItemAttrText(
                                             p_item_type,
                                             p_item_key,
                                             'APPROVER_DISPLAY_NAME');

    l_notes  := wf_engine.GetItemAttrText( p_item_type,  p_item_key,'NOTES'); /*5119049*/

    fnd_message.set_name('AR', 'AR_WF_REQUEST_APPROVAL');
    fnd_message.set_token('REQUEST_ID', to_char(l_document_id));
    fnd_message.set_token('APPROVER',     l_approver_display_name);
-- bug fix 1122477

    l_note_text := fnd_message.get;

    IF l_notes is NOT NULL then
       l_note_text := SUBSTRB(l_note_text || ' "' || l_notes || '"',1,2000) ;  /*5119049*/
    END IF;

         InsertTrxNotes(NULL,
                        NULL,
                        NULL,
                        l_customer_trx_id,
                        'MAINTAIN',
                        l_note_text,
                        l_note_id);

     p_result := 'COMPLETE:T';
     return;


  end if; -- end of run mode

  --
  -- CANCEL mode
  --

  if (p_funcmode = 'CANCEL') then

    -- no result needed
    p_result := 'COMPLETE:';
    return;
  end if;


  --
  -- Other execution modes
  --
  p_result := '';
  return;

exception
  when others then
    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context('ARP_CMREQ_WF', 'InsertRequestApprovalNotes',
		    p_item_type, p_item_key, to_char(p_actid), p_funcmode);
    raise;

end InsertRequestApprovalNotes;

PROCEDURE InsertApprovedResponseNotes(p_item_type        IN  VARCHAR2,
                                      p_item_key         IN  VARCHAR2,
                                      p_actid            IN  NUMBER,
                                      p_funcmode         IN  VARCHAR2,
                                      p_result           OUT NOCOPY VARCHAR2) IS

l_debug_mesg                 varchar2(240);

 l_document_id                number;
 l_customer_trx_id            number;
 l_approver_display_name         varchar2(100);
 l_note_id                    number;
 l_note_text                  ar_notes.text%type;
  l_notes                      wf_item_attribute_values.text_value%TYPE;  /*5119049 */

begin
  -- SetOrgContext (p_item_key);
  ---------------------------------------------------------------------
  l_debug_mesg   := 'Insert Approved Response notes';
  ---------------------------------------------------------------------

  --
  -- RUN mode - normal process execution
  --
  if (p_funcmode = 'RUN') then


    l_document_id    := WF_ENGINE.GetItemAttrNumber(
                                             p_item_type,
                                             p_item_key,
                                             'WORKFLOW_DOCUMENT_ID');

    l_customer_trx_id   := WF_ENGINE.GetItemAttrNumber(
                                             p_item_type,
                                             p_item_key,
                                             'CUSTOMER_TRX_ID');

    l_approver_display_name
                      := WF_ENGINE.GetItemAttrText(
                                             p_item_type,
                                             p_item_key,
                                             'APPROVER_DISPLAY_NAME');

    l_notes  := wf_engine.GetItemAttrText( p_item_type,  p_item_key,'NOTES'); /*5119049*/

    fnd_message.set_name('AR', 'AR_WF_APPROVED_RESPONSE');
    fnd_message.set_token('REQUEST_ID', to_char(l_document_id));
    fnd_message.set_token('APPROVER',     l_approver_display_name);
-- bug fix 1122477

    l_note_text := fnd_message.get;

    IF l_notes is NOT NULL then
       l_note_text := SUBSTRB(l_note_text || ' "' || l_notes || '"',1,2000) ;  /*5119049*/
    END IF;

         InsertTrxNotes(NULL,
                        NULL,
                        NULL,
                        l_customer_trx_id,
                        'MAINTAIN',
                        l_note_text,
                        l_note_id);


     p_result := 'COMPLETE:T';
     return;


  end if; -- end of run mode

  --
  -- CANCEL mode
  --

  if (p_funcmode = 'CANCEL') then

    -- no result needed
    p_result := 'COMPLETE:';
    return;
  end if;


  --
  -- Other execution modes
  --
  p_result := '';
  return;

exception
  when others then
    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context('ARP_CMREQ_WF', 'InsertApprovedResponseNotes',
		    p_item_type, p_item_key, to_char(p_actid), p_funcmode);
    raise;

end InsertApprovedResponseNotes;


PROCEDURE InsertRejectedResponseNotes(p_item_type        IN  VARCHAR2,
                                      p_item_key         IN  VARCHAR2,
                                      p_actid            IN  NUMBER,
                                      p_funcmode         IN  VARCHAR2,
                                      p_result           OUT NOCOPY VARCHAR2) IS

 l_debug_mesg                 varchar2(240);
 l_document_id                number;
 l_customer_trx_id            number;
 l_approver_display_name      varchar2(100);
 l_note_id                    number;
 l_note_text                  ar_notes.text%type;
  l_notes                      wf_item_attribute_values.text_value%TYPE;  /*5119049 */

 /* bug 1908252 */
 l_last_updated_by     number;
 l_last_update_login   number;

BEGIN
  -- SetOrgContext (p_item_key);

  -- Bug 2105483 : rather then calling arp_global at the start
  -- of the package, where it can error out NOCOPY since org_id is not yet set,
  -- do the call right before it is needed
  arp_global.init_global;

  /* Bug 1908252 */
  l_last_updated_by := ARP_GLOBAL.user_id;
  l_last_update_login := ARP_GLOBAL.last_update_login ;

  ---------------------------------------------------------------------
  l_debug_mesg   := 'Insert Rejected Response notes';
  ---------------------------------------------------------------------

  --
  -- RUN mode - normal process execution
  --
  if (p_funcmode = 'RUN') then


    l_document_id    := WF_ENGINE.GetItemAttrNumber(
                                             p_item_type,
                                             p_item_key,
                                             'WORKFLOW_DOCUMENT_ID');

    l_customer_trx_id   := WF_ENGINE.GetItemAttrNumber(
                                             p_item_type,
                                             p_item_key,
                                             'CUSTOMER_TRX_ID');

    l_approver_display_name
                      := WF_ENGINE.GetItemAttrText(
                                             p_item_type,
                                             p_item_key,
                                             'APPROVER_DISPLAY_NAME');
    l_notes  := wf_engine.GetItemAttrText( p_item_type,  p_item_key,'NOTES'); /*5119049*/


    fnd_message.set_name('AR', 'AR_WF_REJECTED_RESPONSE');
    fnd_message.set_token('REQUEST_ID', to_char(l_document_id));
    fnd_message.set_token('APPROVER',     l_approver_display_name);
-- bug fix 1122477

    l_note_text := fnd_message.get;

    IF l_notes is NOT NULL then
       l_note_text := SUBSTRB(l_note_text || ' "' || l_notes || '"',1,2000) ;  /*5119049*/
    END IF;

         InsertTrxNotes(NULL,
                        NULL,
                        NULL,
                        l_customer_trx_id,
                        'MAINTAIN',
                        l_note_text,
                        l_note_id);

     /* Bug 1908252 : update last_update* fields */

     UPDATE ra_cm_requests
     SET status = 'NOT_APPROVED',
         last_updated_by = l_last_updated_by,
         last_update_date = SYSDATE,
         last_update_login = l_last_update_login
     WHERE request_id = p_item_key;

     /*COMMIT;*/

     p_result := 'COMPLETE:T';
     return;


  end if; -- end of run mode

  --
  -- CANCEL mode
  --

  if (p_funcmode = 'CANCEL') then

    -- no result needed
    p_result := 'COMPLETE:';
    return;
  end if;


  --
  -- Other execution modes
  --
  p_result := '';
  return;

exception
  when others then
    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context('ARP_CMREQ_WF', 'InsertRejectedResponseNotes',
		    p_item_type, p_item_key, to_char(p_actid), p_funcmode);
    raise;


end InsertRejectedResponseNotes;


PROCEDURE InsertSuccessfulAPINotes(p_item_type        IN  VARCHAR2,
                                   p_item_key         IN  VARCHAR2,
                                   p_actid            IN  NUMBER,
                                   p_funcmode         IN  VARCHAR2,
                                   p_result           OUT NOCOPY VARCHAR2) IS

 l_debug_mesg                 varchar2(240);

 l_document_id                number;
 l_credit_memo_number            varchar2(20);
 l_customer_trx_id	      number;
 l_note_id                    number;
 l_note_text                  ar_notes.text%type;
  l_notes                      wf_item_attribute_values.text_value%TYPE;  /*5119049 */

begin
  SetOrgContext (p_item_key);
  ---------------------------------------------------------------------
  l_debug_mesg   := 'Insert Completed Successful API notes';
  ---------------------------------------------------------------------

  --
  -- RUN mode - normal process execution
  --
  if (p_funcmode = 'RUN') then


    l_document_id    := WF_ENGINE.GetItemAttrNumber(
                                             p_item_type,
                                             p_item_key,
                                             'WORKFLOW_DOCUMENT_ID');

    l_credit_memo_number   := WF_ENGINE.GetItemAttrText(
                                             p_item_type,
                                             p_item_key,
                                             'CREDIT_MEMO_NUMBER');

    l_customer_trx_id   := WF_ENGINE.GetItemAttrNumber(
                                             p_item_type,
                                             p_item_key,
                                             'CUSTOMER_TRX_ID');
    l_notes  := wf_engine.GetItemAttrText( p_item_type,  p_item_key,'NOTES'); /*5119049*/

 /* Get trx number for CM and the insert into note text */


    fnd_message.set_name('AR', 'AR_WF_COMPLETED_SUCCESSFUL');
    fnd_message.set_token('REQUEST_ID', to_char(l_document_id));
    fnd_message.set_token('TRXNUMBER', l_credit_memo_number);

    l_note_text := fnd_message.get;

    IF l_notes is NOT NULL then
       l_note_text := SUBSTRB(l_note_text || ' "' || l_notes || '"',1,2000) ;  /*5119049*/
    END IF;

         InsertTrxNotes(NULL,
                        NULL,
                        NULL,
                        l_customer_trx_id,
                        'MAINTAIN',
                        l_note_text,
                        l_note_id);


     p_result := 'COMPLETE:T';
     return;


  end if; -- end of run mode

  --
  -- CANCEL mode
  --

  if (p_funcmode = 'CANCEL') then

    -- no result needed
    p_result := 'COMPLETE:';
    return;
  end if;


  --
  -- Other execution modes
  --
  p_result := '';
  return;

exception
  when others then
    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context('ARP_CMREQ_WF', 'InsertSuccessfulAPINotes',
		    p_item_type, p_item_key, to_char(p_actid), p_funcmode);
    raise;

end InsertSuccessfulAPINotes;


PROCEDURE InsertNotes(p_item_type        IN  VARCHAR2,
                      p_item_key         IN  VARCHAR2,
                      p_actid            IN  NUMBER,
                      p_funcmode         IN  VARCHAR2,
                      p_result           OUT NOCOPY VARCHAR2) IS


 l_debug_mesg                 varchar2(240);

 l_customer_id                number;
 l_collector_id               number;
 l_customer_trx_id            number;
 l_bill_to_site_use_id        number;
 l_customer_call_id           number;
 l_customer_call_topic_id     number;
 l_action_id                  number;
 l_note_id                    number;

 l_reason_code                varchar2(45);
 l_currency_code              varchar2(15);
 l_entered_amount_display     number;
 l_result_flag                varchar2(1);

begin
  -- SetOrgContext (p_item_key);

  ---------------------------------------------------------
  l_debug_mesg   := 'Create a call record and insert a note';
  ---------------------------------------------------------


  --
  -- RUN mode - normal process execution
  --
  if (p_funcmode = 'RUN') then

    l_reason_code    := WF_ENGINE.GetItemAttrText(
                                            p_item_type,
                                            p_item_key,
                                            'REASON');

    l_currency_code   := WF_ENGINE.GetItemAttrText(
                                            p_item_type,
                                            p_item_key,
                                            'CURRENCY_CODE');

    l_entered_amount_display
                      := WF_ENGINE.GetItemAttrNumber(
                                             p_item_type,
                                             p_item_key,
                                             'ENTERED_AMOUNT_DISPLAY');

    l_customer_id     := WF_ENGINE.GetItemAttrNumber(
                                             p_item_type,
                                             p_item_key,
                                             'CUSTOMER_ID');

    l_collector_id     := WF_ENGINE.GetItemAttrNumber(
                                             p_item_type,
                                             p_item_key,
                                             'COLLECTOR_ID');


    l_customer_trx_id   := WF_ENGINE.GetItemAttrNumber(
                                             p_item_type,
                                             p_item_key,
                                             'CUSTOMER_TRX_ID');

    l_bill_to_site_use_id   := WF_ENGINE.GetItemAttrNumber(
                                             p_item_type,
                                             p_item_key,
                                             'BILL_TO_SITE_USE_ID');



         InsertTrxNotes(NULL,
                        NULL,
                        NULL,
                        l_customer_trx_id,
                        'MAINTAIN',
                        'Credit Memo request was approved by receivable role.',
                        l_note_id);


     p_result := 'COMPLETE:T';
     return;


  end if; -- end of run mode

  --
  -- CANCEL mode
  --

  if (p_funcmode = 'CANCEL') then

    -- no result needed
    p_result := 'COMPLETE:';
    return;
  end if;


  --
  -- Other execution modes
  --
  p_result := '';
  return;

exception
  when others then
    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context('ARP_CMREQ_WF', 'InsertNotes',
		    p_item_type, p_item_key, to_char(p_actid), p_funcmode);
    raise;

end InsertNotes;


PROCEDURE InsertTrxNotes(x_customer_call_id          IN  NUMBER,
                           x_customer_call_topic_id    IN  NUMBER,
                           x_action_id                 IN  NUMBER,
                           x_customer_trx_id           IN  NUMBER,
                           x_note_type                 IN  VARCHAR2,
                           x_text                      IN  VARCHAR2,
                           x_note_id                   OUT NOCOPY NUMBER) IS

l_debug_mesg          varchar2(240);
l_last_updated_by     number;
l_last_update_date    date;
l_last_update_login   number;
l_creation_date       date;
l_created_by          number;

BEGIN
   ---------------------------------------------------------------------------
   l_debug_mesg := 'Insert call topic notes';
   ---------------------------------------------------------------------------

   -- Bug 2105483 : rather then calling arp_global at the start
   -- of the package, where it can error out NOCOPY since org_id is not yet set,
   -- do the call right before it is needed
   arp_global.init_global;

   -- call a server side package

      /* Bug 1690118 : replace FND_GLOBAL with ARP_GLOBAL */

      l_created_by 	      := ARP_GLOBAL.USER_ID;
      l_creation_date         := sysdate;
      l_last_update_login     := ARP_GLOBAL.last_update_login ;
      l_last_update_date      := sysdate;
      l_last_updated_by       := ARP_GLOBAL.USER_ID;

   arp_notes_pkg.insert_cover(
        p_note_type              => x_note_type,
        p_text                   => x_text,
        p_customer_call_id       => null,
        p_customer_call_topic_id => null,
        p_call_action_id         => NULL,
        p_customer_trx_id        => x_customer_trx_id,
        p_note_id                => x_note_id,
        p_last_updated_by        => l_last_updated_by,
        p_last_update_date       => l_last_update_date,
        p_last_update_login      => l_last_update_login,
        p_created_by             => l_created_by,
        p_creation_date          => l_creation_date);


EXCEPTION
 WHEN OTHERS THEN
  x_note_id := -1;
      wf_core.Context('ARP_CMREQ_WF', 'InsertTrxNotes',
                      null, null, null, l_debug_mesg);
  RAISE;

END InsertTrxNotes;


PROCEDURE CallTrxApi(p_item_type        IN  VARCHAR2,
                     p_item_key         IN  VARCHAR2,
                     p_actid            IN  NUMBER,
                     p_funcmode         IN  VARCHAR2,
                     p_result           OUT NOCOPY VARCHAR2) IS


l_customer_trx_id     		number;
l_amount              		number;
l_request_id	      		number;
l_error_tab	      		arp_trx_validate.Message_Tbl_Type;
l_batch_source_name		varchar2(50);
l_credit_method_rules		varchar2(65);
l_credit_method_installments	varchar2(65);
l_cm_creation_error		varchar2(250);
l_credit_memo_number    	varchar2(20);
l_credit_memo_id    		number;
CRLF        			varchar2(1);
l_status		        varchar2(255);

/* bug 1908252 */
l_last_updated_by     number;
l_last_update_login   number;

BEGIN
   SetOrgContext (p_item_key);

  -- Bug 2105483 : rather then calling arp_global at the start
  -- of the package, where it can error out NOCOPY since org_id is not yet set,
  -- do the call right before it is needed
  arp_global.init_global;

  crlf := arp_global.CRLF;

  /* Bug 1908252 */
  l_last_updated_by := ARP_GLOBAL.user_id;
  l_last_update_login := ARP_GLOBAL.last_update_login ;

  --
  -- RUN mode - normal process execution
  --
  if (p_funcmode = 'RUN') then

  -- call transaction API here

   l_customer_trx_id   := WF_ENGINE.GetItemAttrNumber(
                                             p_item_type,
                                             p_item_key,
                                             'CUSTOMER_TRX_ID');

    l_amount           := WF_ENGINE.GetItemAttrNumber(
                                             p_item_type,
                                             p_item_key,
                                             'ORIGINAL_TOTAL');

   l_request_id  := WF_ENGINE.GetItemAttrNumber(
                                    p_item_type,
                                    p_item_key,
                                    'WORKFLOW_DOCUMENT_ID');

   l_batch_source_name := WF_ENGINE.GetItemAttrText(
                                                  p_item_type,
                                                  p_item_key,
                                                  'BATCH_SOURCE_NAME');


   l_credit_method_installments    := WF_ENGINE.GetItemAttrText(
                                                  p_item_type,
                                                  p_item_key,
                                                  'CREDIT_INSTALLMENT_RULE');

   l_credit_method_rules     := WF_ENGINE.GetItemAttrText(
                                                  p_item_type,
                                                  p_item_key,
                                                  'CREDIT_ACCOUNTING_RULE');

   l_cm_creation_error := NULL;

   IF l_batch_source_name IS NULL THEN

	fnd_message.set_name('AR', 'AR_WF_NO_BATCH');
	l_cm_creation_error := fnd_message.get;

	WF_ENGINE.SetItemAttrText(p_item_type,
                               p_item_key,
                               'CM_CREATION_ERROR',
                               l_cm_creation_error);


	p_result := 'COMPLETE:F';
        return;
   END IF;

   if (l_credit_method_installments = 'N')
   then
        l_credit_method_installments := NULL;
   end if;


   if (l_credit_method_rules = 'N')
   then
        l_credit_method_rules := NULL;
   end if;

   -- bug 2290738 : add p_status
    arw_cmreq_cover.ar_autocreate_cm(
	p_request_id			=> l_request_id,
	p_batch_source_name		=> l_batch_source_name,
	p_credit_method_rules		=> l_credit_method_rules,
	p_credit_method_installments    => l_credit_method_installments,
	p_error_tab			=> l_error_tab,
        p_status			=> l_status);
   l_cm_creation_error := NULL;


     begin
        select cm_customer_trx_id
        into l_credit_memo_id
        from ra_cm_requests
        where request_id = l_request_id;
     exception
        when others then
   	    p_result := 'COMPLETE:F';
	    l_cm_creation_error := 'Could not find the request';
            WF_ENGINE.SetItemAttrText(p_item_type,
                               p_item_key,
                               'CM_CREATION_ERROR',
                               l_cm_creation_error);
            return;
     end;



--   IF l_error_tab.count = 0  THEN
    IF (l_credit_memo_id is not null) THEN
   	p_result := 'COMPLETE:T';

        /* Bug 1908252 : update last_update* fields */
        update ra_cm_requests
        set status='COMPLETE',
            approval_date = SYSDATE,
            last_updated_by = l_last_updated_by,
            last_update_date = SYSDATE,
            last_update_login = l_last_update_login
        where request_id = p_item_key;

   	/*commit;*/

        begin
          select trx_number
          into l_credit_memo_number
	  from   ra_customer_trx
	  where  customer_trx_id = l_credit_memo_id;

           WF_ENGINE.SetItemAttrText(p_item_type,
                                 p_item_key,
                                 'CREDIT_MEMO_NUMBER',
                                 l_credit_memo_number);


        exception
            when others then
   	      p_result := 'COMPLETE:F';
	      l_cm_creation_error := 'Could not find the credit memo';
              WF_ENGINE.SetItemAttrText(p_item_type,
                               p_item_key,
                               'CM_CREATION_ERROR',
                               l_cm_creation_error);
            return;
        end;

   ELSE
	FOR i IN 1..l_error_tab.COUNT LOOP
	        l_cm_creation_error := l_cm_creation_error || l_error_tab(i).translated_message || CRLF;
        END LOOP;

        WF_ENGINE.SetItemAttrText(p_item_type,
                               p_item_key,
                               'CM_CREATION_ERROR',
                               l_cm_creation_error);

        /* Bug 1908252 : update last_update* fields */
        update ra_cm_requests
        set status='APPROVED_PEND_COMP',
            approval_date = SYSDATE,
            last_updated_by = l_last_updated_by,
            last_update_date = SYSDATE,
            last_update_login = l_last_update_login
        where request_id = p_item_key;

   	p_result := 'COMPLETE:F';
   END IF;

   return;

  end if; -- end of run mode

  --
  -- CANCEL mode
  --
  -- This is an event point is called with the effect of the activity must
  -- be undone, for example when a process is reset to an earlier point
  -- due to a loop back.
  --
  if (p_funcmode = 'CANCEL') then

    -- no result needed
    p_result := 'COMPLETE:';
    return;
  end if;


  --
  -- Other execution modes may be created in the future.  Your
  -- activity will indicate that it does not implement a mode
  -- by returning null
  --
  p_result := '';
  return;

exception
  when others then
    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context('ARP_CMREQ_WF', 'CallTrxApi',
		    p_item_type, p_item_key, to_char(p_actid), p_funcmode);
    raise;

end CallTrxApi;

PROCEDURE CheckCreditMethods(p_item_type        IN  VARCHAR2,
                             p_item_key         IN  VARCHAR2,
                             p_actid            IN  NUMBER,
                             p_funcmode         IN  VARCHAR2,
                             p_result           OUT NOCOPY VARCHAR2) IS

 l_debug_mesg varchar2(240);

 l_customer_trx_id		      number;
 l_credit_installment_rule            varchar2(65);
 l_credit_accounting_rule             varchar2(65);
 l_invalid_rule_value                 varchar2(80);
 l_invalid_rule_mesg                  varchar2(2000);
 l_count			      number;
 l_invoicing_rule_id		      number;

begin
   --uncommented for 5410467
   SetOrgContext (p_item_key);
  --
  -- RUN mode - normal process execution
  --
  if (p_funcmode = 'RUN') then

     ------------------------------------------------------------
     l_debug_mesg := 'Get the user value of rules';
     ------------------------------------------------------------

     l_customer_trx_id  :=  WF_ENGINE.GetItemAttrNumber(
                                         p_item_type,
                                         p_item_key,
                                         'CUSTOMER_TRX_ID');


     l_credit_installment_rule    := WF_ENGINE.GetItemAttrText(
                                                  p_item_type,
                                                  p_item_key,
                                                  'CREDIT_INSTALLMENT_RULE');

     l_credit_accounting_rule     := WF_ENGINE.GetItemAttrText(
                                                  p_item_type,
                                                  p_item_key,
                                                  'CREDIT_ACCOUNTING_RULE');

     l_invalid_rule_value         := WF_ENGINE.GetItemAttrText(
                                                  p_item_type,
                                                  p_item_key,
                                                  'INVALID_RULE_VALUE');

     l_invalid_rule_mesg          := WF_ENGINE.GetItemAttrText(
                                                  p_item_type,
                                                  p_item_key,
                                                  'INVALID_RULE_MESG');

     SELECT COUNT(*) INTO l_count
     FROM ra_terms_lines
     WHERE term_id = (SELECT term_id FROM ra_customer_trx
		      WHERE customer_trx_id = l_customer_trx_id);


-- the l_count will always be >= 1, and the credit installment_rule is
-- required for count > 1.

     if l_count > 1 then

       if l_credit_installment_rule  not in ('LIFO', 'FIFO', 'PRORATE') then
         -- invalid credit method
         WF_ENGINE.SetItemAttrText(p_item_type,
                               p_item_key,
                               'INVALID_RULE_MESG',
                               l_invalid_rule_value);
         p_result := 'COMPLETE:F';
         return;
       end if;
     end if;

     SELECT invoicing_rule_id INTO l_invoicing_rule_id
     FROM   ra_customer_trx
     WHERE  customer_trx_id = l_customer_trx_id;

     if l_invoicing_rule_id is not  NULL then

       if l_credit_accounting_rule   not in ('LIFO', 'PRORATE','UNIT') then
         -- invalid credit method
         WF_ENGINE.SetItemAttrText(p_item_type,
                               p_item_key,
                               'INVALID_RULE_MESG',
                               l_invalid_rule_value);
         p_result := 'COMPLETE:F';
         return;
       end if;
     end if;

     -- the credit methods are valid
     if l_invalid_rule_mesg is not NULL then
       l_invalid_rule_mesg := NULL;
       WF_ENGINE.SetItemAttrText(p_item_type,
                               p_item_key,
                               'INVALID_RULE_MESG',
                               l_invalid_rule_mesg);
     end if;




   p_result := 'COMPLETE:T';
   return;

  end if; -- end of run mode

  --
  -- CANCEL mode
  --

  if (p_funcmode = 'CANCEL') then

    -- no result needed
    p_result := 'COMPLETE:';
    return;
  end if;


  --
  -- Other execution modes
  --
  p_result := '';
  return;

exception
  when others then
    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context('ARP_CMREQ_WF', 'CheckCreditMethods',
		    p_item_type, p_item_key, to_char(p_actid), p_funcmode);
    raise;

end CheckCreditMethods;

-- Bug 1365263 Workflow does not set the org_id based on the user's profile.
-- When workflow connects to the database and executes a package, the default
-- org is set to what is  at the site level. Our selects from multi org views
-- fail due to this when the org is different from what is at the site level.
-- The org context has to be set to the org under the which the
-- the transaction was created.

PROCEDURE SetOrgContext (p_item_key IN VARCHAR2) IS

l_org_id number;
l_debug_mesg varchar2(240);

BEGIN

   select org_id into l_org_id
   from ra_cm_requests_all
   where request_id = p_item_key;
   ----------------------------------------------------------
   l_debug_mesg := 'Get the org_id for the credit memo request';
   ----------------------------------------------------------

   --commented code below for 5410467 instead introduced mo_global.set_policy_context
--   fnd_client_info.set_org_context (l_org_id);
   mo_global.set_policy_context('S', l_org_id);

exception
  when others then
   wf_core.Context('ARP_CMREQ_WF', 'SetContext',
                      null, null, null, l_debug_mesg);
      raise;

END SetOrgContext;

end  ARP_CMREQ_WF;

/
