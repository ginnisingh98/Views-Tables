--------------------------------------------------------
--  DDL for Package Body FUN_INITIATOR_WF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FUN_INITIATOR_WF_PKG" AS
/* $Header: funwintb.pls 120.26.12010000.15 2010/04/23 12:41:09 srsampat ship $ */


  -- Set workflow item attributes for the process

/*-----------------------------------------------------|
| PROCEDURE SET_ATTRIBUTES                             |
|------------------------------------------------------|
|   Parameters       item_type      IN   Varchar2      |
|                    item_key       IN   Varchar2      |
|                    act_id         IN   NUMBER        |
|                    funcmode       IN   Varchar2      |
|                    resultout      IN   Varchar2      |
|                                                      |
|------------------------------------------------------|
|   Description                                        |
|           Set the attributes of the WF process       |
|                                                      |
|                                                      |
|                                                      |
|                                                      |
|                                                      |
|-----------------------------------------------------*/


   PROCEDURE SET_ATTRIBUTES   (itemtype           IN VARCHAR2,
                               itemkey            IN VARCHAR2,
                               actid              IN NUMBER,
                               funcmode           IN VARCHAR2,
                               resultout          OUT  NOCOPY VARCHAR2)

IS

l_batch_id NUMBER;
l_trx_id NUMBER;
l_initiator_id NUMBER;
l_recipient_id NUMBER;
l_batch_number Varchar2(20);
l_gl_date DATE;
l_batch_date DATE;
l_recipient_name Varchar2(360);
l_invoice_flag Varchar2(1);
l_event_name Varchar2(240);
l_status_code Varchar2(15);
l_role_name Varchar2(30);
l_event_key Varchar2(64);
l_trx_amt NUMBER;
l_currency Varchar2(15);

l_initiator_name    VARCHAR2(360);
l_trx_number        fun_trx_headers.trx_number%TYPE;
l_user_env_lang varchar2(5);

BEGIN
l_status_code :='Test';
 IF (funcmode = 'RUN') THEN

    -- Obtain the batch_id and trx_id

    -- Note the attributes BATCH_ID and TRX_ID are set
    --   by the receiving event

    l_batch_id :=   wf_engine.getitemattrnumber(itemtype,
                                                itemkey,
                                               'BATCH_ID');

    l_trx_id   :=   wf_engine.getitemattrnumber(itemtype,
                                                itemkey,
                                               'TRX_ID');
    l_user_env_lang := wf_engine.GetItemAttrText
                                    (itemtype => itemtype,
                                     itemkey => itemkey,
                                     aname => 'USER_LANG');



   -- obtain the attrubutes value from the database
BEGIN

    -- Changes for AME Uptake, 3671923. Bidisha S, 28 Jun 2004
    -- Modified the query below to retrieve the recipient org name
    -- and the transaction number
    SELECT ftb.batch_number,
           ftb.gl_date,
           ftb.batch_date,
           fth.initiator_id,
           fth.recipient_id,
           fth.invoice_flag,
          -- decode(fth.init_amount_cr,0, fth.init_amount_dr, NULL, fth.init_amount_dr, fth.init_amount_cr),
	  -- Bug No. 6854675 Changed the select statement to fetch a numeric value
           --ltrim(to_char(decode(nvl(ftb.running_total_cr,0),0,ftb.running_total_dr,ftb.running_total_cr),'999999999.99')),
	   decode(nvl(ftb.running_total_cr,0),0,ftb.running_total_dr,ftb.running_total_cr),
           ftb.currency_code,
           hzp.party_name  ,
           fth.trx_number,
           ini.party_name
    INTO   l_batch_number,
           l_gl_date,
           l_batch_date,
           l_initiator_id,
           l_recipient_id,
           l_invoice_flag,
           l_trx_amt,
           l_currency,
           l_recipient_name,
           l_trx_number,
           l_initiator_name
    FROM   fun_trx_batches ftb,
	   fun_trx_headers fth,
           hz_parties hzp,
           hz_parties ini
    WHERE  ftb.batch_id = l_batch_id
    AND    ftb.batch_id=fth.batch_id
    AND    fth.recipient_id=hzp.party_id
    AND    fth.initiator_id=ini.party_id
    AND    fth.trx_id=l_trx_id;
EXCEPTION
   WHEN NO_DATA_FOUND THEN
     NULL;

END;
-- set the attribute

         -- batch number
       wf_engine.setitemattrtext(itemtype,
                                 itemkey,
                                 'BATCH_NUMBER',
                                 l_batch_number);

         -- gl_date
       wf_engine.setitemattrdate(itemtype,
                                 itemkey,
                                 'GL_DATE',
                                 l_gl_date);

         -- batch_date

       wf_engine.setitemattrdate(itemtype,
                                 itemkey,
                                 'BATCH_DATE',
                                 l_batch_date);

          -- initiator_id

       wf_engine.setitemattrnumber(itemtype,
                                   itemkey,
                                   'INITIATOR_ID',
                                   l_initiator_id);
          -- recipient_id

       wf_engine.setitemattrnumber(itemtype,
                                   itemkey,
                                   'RECIPIENT_ID',
                                   l_recipient_id);

          -- invoice_flag

       wf_engine.setitemattrtext(itemtype,
                                 itemkey,
                                 'INVOICE_FLAG',
                                 l_invoice_flag);

          -- transaction amount

       wf_engine.setitemattrnumber(itemtype,
                                   itemkey,
                                   'TRX_AMT',
                                   l_trx_amt);


         -- Currency

       wf_engine.setitemattrtext(itemtype,
                                 itemkey,
                                 'CURRENCY',
                                 l_currency);

        -- recipient name

       wf_engine.setitemattrtext(itemtype,
                                 itemkey,
                                 'RECIPIENT_NAME',
                                 l_recipient_name);



      /* Start of changes for AME Uptake, 3671923. Bidisha S, 29 Jun 2004    */

       wf_engine.setitemattrtext(itemtype,
                                 itemkey,
                                 'INITIATOR_NAME',
                                 l_initiator_name);

       wf_engine.setitemattrtext(itemtype,
                                 itemkey,
                                 'TRX_NUMBER',
                                 l_trx_number);
      -- Contact information
      --l_role_name :=FUN_WF_COMMON.get_contact_role(l_initiator_id);

      -- wf_engine.setitemattrtext(itemtype,
      --                           itemkey,
      --                           'CONTACT',
      --                           l_role_name);

      /* End of changes for AME Uptake, 3671923. Bidisha S, 29 Jun 2004    */


        -- Get the status code from the event name

     l_event_name :=   rtrim(ltrim(lower(wf_engine.getitemattrtext(itemtype,
                                                itemkey,
                                               'EVENT_NAME')), ' '), ' ');

        -- Case check
            if(INSTR(l_event_name,  'oracle.apps.fun.manualtrx.complete.receive')<>0) then
              l_status_code:='COMPLETE';
       elsif (INSTR(l_event_name, 'oracle.apps.fun.manualtrx.rejection.receive')<>0) then
              l_status_code :='REJECTED';
       elsif (INSTR(l_event_name, 'oracle.apps.fun.manualtrx.approval.receive')<>0) then
             l_status_code :='APPROVED';

               -- set the event key for the AR/GL transfer event
              l_event_key :=FUN_INITIATOR_WF_PKG.generate_key(p_batch_id =>l_batch_id,
                                                              p_trx_id => l_trx_id);

              wf_engine.setitemattrtext(itemtype,
                                        itemkey,
                                        'TRANSFER_KEY',
                                        l_event_key);

       elsif (INSTR(l_event_name,'oracle.apps.fun.manualtrx.reception.receive')<>0) then
              l_status_code :='RECEIVED';
       elsif (INSTR(l_event_name, 'oracle.apps.fun.manualtrx.error.receive')<>0) then
              l_status_code :='ERROR';
            else
              l_status_code :='UNEXPECTED';
            end if;

      -- set the status code

            wf_engine.setitemattrtext(itemtype,
                                 itemkey,
                                 'STATUS',
                                 l_status_code);

       wf_engine.setitemattrnumber(itemtype,
                                   itemkey,
                                   'BATCH_ID',
                                   l_batch_id);

       wf_engine.setitemattrnumber(itemtype,
                                   itemkey,
                                   'TRX_ID',
                                   l_trx_id);

       wf_engine.setitemattrnumber(itemtype,
                                   itemkey,
                                   'PARTY_ID',
                                   l_initiator_id);
       wf_engine.setitemattrtext(itemtype,
                                 itemkey,
                                 'USER_LANG',
                                 l_user_env_lang);

    -- no result needed
    resultout := 'COMPLETE';
    return;
  END IF;

EXCEPTION

WHEN OTHERS THEN

    -- Rcords this function call in the error system
    -- in the case of an exception.

    wf_core.context('FUN_INITIATOR_WF_PKG',  'SET_ATTRIBUTES',
		    itemtype, itemkey, to_char(actid), funcmode);

END  SET_ATTRIBUTES;




  -- Update Intercompany Transaction Status

/*-----------------------------------------------------|
| PROCEDURE UPDATE_STATUS                              |
|------------------------------------------------------|
|   Parameters       item_type      IN   Varchar2      |
|                    item_key       IN   Varchar2      |
|                    act_id         IN   NUMBER        |
|                    funcmode       IN   Varchar2      |
|                    resultout      IN   Varchar2      |
|                                                      |
|------------------------------------------------------|
|   Description                                        |
|           Update the intercompany transaction        |
|            status                                    |
|                                                      |
|                                                      |
|                                                      |
|                                                      |
|-----------------------------------------------------*/


     PROCEDURE UPDATE_STATUS ( itemtype in  varchar2,
                               itemkey  in  varchar2,
			       actid    in  number,
                               funcmode in  varchar2,
                               resultout out NOCOPY varchar2)

IS

-- Local variables

l_trx_id          NUMBER;
l_batch_id	  NUMBER;
l_status          VARCHAR2(15);
l_return_status   Varchar2(1);
l_message_count   NUMBER;
l_message_data    Varchar2(1000);

BEGIN

-- get the attribute values

l_trx_id := wf_engine.GetItemAttrNumber( itemtype
                                       , itemkey
                                       , 'TRX_ID'
                                        );

l_batch_id := wf_engine.GetItemAttrNumber( itemtype
                                       ,   itemkey
                                       ,  'BATCH_ID'
                                        );

l_status := wf_engine.GetItemAttrText( itemtype
                                       ,itemkey
                                       , 'STATUS'
                                        );


-- Note: This function will call Transaction API
--   to update the status of a transaction
   IF (funcmode = 'RUN') THEN

   FUN_TRX_PVT.update_trx_status(p_api_version   =>1.0,
                                 x_return_status =>l_return_status,
                                 x_msg_count     => l_message_count,
                                 x_msg_data      => l_message_data,
                                 p_trx_id        => l_trx_id,
                                 p_update_status_to => l_status);

      -- Handle the API call return

    IF l_return_status = FND_API.G_RET_STS_ERROR   THEN

            raise FND_API.G_EXC_ERROR;
      END IF;


    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR   THEN

            raise FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

    -- Assume the status update is successful


    if( l_status='APPROVED') then
            resultout := 'COMPLETE:APPROVED';
    elsif (l_status ='REJECTED' ) then
            resultout := 'COMPLETE:REJECTED';
    elsif (l_status ='ERROR') then
            resultout :='COMPLETE:ERROR';
     else
            resultout := 'COMPLETE:OTHERS';

     END IF;

  ELSE
    resultout := 'COMPLETE';
   END IF;

EXCEPTION
   WHEN OTHERS THEN
   WF_CORE.Context('FUN_INITIATOR_WF_PKG', 'UPDATE_STATUS',
                    itemtype, itemkey, actid, funcmode);
   RAISE;


END UPDATE_STATUS;



  -- Transfer the transaction to AR interface table
  --

/*-----------------------------------------------------|
| PROCEDURE TRANSFER_AR                                |
|------------------------------------------------------|
|   Parameters     itemtype         IN   Varchar2      |
|                  itemkey          IN   Varchar2      |
|                  actid            IN   NUMBER        |
|                  funcmode         IN   Varchar2      |
|                  resultout        IN   Varchar2      |
|                                                      |
|------------------------------------------------------|
|   Description                                        |
|           Transfer the intercompany transaction to   |
|           AR interface table: AR_INTERFACE_LINES_ALL |
|                                                      |
|                                                      |
|                                                      |
|                                                      |
|-----------------------------------------------------*/



  PROCEDURE TRANSFER_AR       (itemtype              IN VARCHAR2,
                               itemkey               IN VARCHAR2,
                               actid                 IN NUMBER,
                               funcmode              IN VARCHAR2,
                               resultout             OUT  NOCOPY VARCHAR2)

IS
  l_batch_id     NUMBER;
  l_trx_id       NUMBER;
  l_recipient_id NUMBER;
  l_trx_type_id  Number;
  l_line         AR_Interface_line;
  l_dist_line    AR_Interface_Dist_line;
  l_ou_id        Number;
  l_ledger_id    Number;
  l_le_id        Number;
  l_ap_ou_id     Number;
  l_ap_le_id     Number;
  l_initiator_id Number;
  l_success      boolean;
  l_return_status Varchar2(1);
  l_customer_id  Number;
  l_address_id   Number;
  l_site_use_id   Number;
  l_ar_trx_type_id Number;
  l_ar_memo_line_id Number;
  l_ar_trx_type_name RA_CUST_TRX_TYPES_ALL.name%TYPE;  -- <bug 3450031>
  l_ar_memo_line_name AR_MEMO_LINES_ALL_VL.name%TYPE;  -- <bug 3450031>
  l_default_term_id NUMBER;
  l_term_id  number;
  l_message_count   NUMBER;
  l_message_data    Varchar2(1000);
  l_count   Number:=0;
  x_msg_data varchar2(1000);-- for the message returned form get_customer
  l_parameter_list WF_PARAMETER_LIST_T :=wf_parameter_list_t();
  l_event_key    VARCHAR2(240);
  -- added for bug: 7271703
  l_batch_num        varchar2(20);

        -- Cursor to retrieve the line information
  CURSOR c_line (p_batch_id IN Number,
                 p_trx_id IN Number) IS
     SELECT decode(ftl.init_amount_cr,
                          0, ftl.init_amount_dr,
                          NULL, ftl.init_amount_dr,
                          ftl.init_amount_cr * (-1)),
                 ftl.line_id
     FROM        FUN_TRX_LINES ftl
     WHERE       p_trx_id = ftl.trx_id;

     -- cursor to retrieve the initiator and recipient party / LE ID
     -- Bug 7271703. also fetching batch number in cursor c_info

     cursor c_info(p_trx_id IN Number) IS
     SELECT      ftb.batch_number,
		 ftb.initiator_id,
                 ftb.from_le_id,
                 ftb.from_ledger_id,
                 fth.recipient_id,
                 fth.to_le_id,
                 ftb.trx_type_id,
                -- fth.ledger_id,
                 ftb.exchange_rate_type,
                 ftb.currency_code,
                 ftb.description,
                 ftb.gl_date,
                 ftb.batch_id,
                 fth.trx_id,
                 ftb.from_ledger_id,
                 ftb.batch_date
     FROM        FUN_TRX_BATCHES ftb,
                 FUN_TRX_HEADERS fth
     WHERE       fth.trx_id=p_trx_id
     AND         fth.batch_id=ftb.batch_id
     AND         fth.status='APPROVED';

     -- cursor to retrieve the distribution information

 CURSOR c_dist  (p_trx_id IN Number) IS
     SELECT
                 DECODE(FDL.dist_type_flag, 'L',
                                       decode(fdl.amount_cr,
                                              0, fdl.amount_dr * (-1),
                                              NULL, fdl.amount_dr * (-1),
                                              fdl.amount_cr),
                                       'R', NULL,
                                            NULL),  -- <bug 3450031>
                 DECODE(FDL.dist_type_flag, 'L', NULL,
                                       'R', 100,
                                            NULL),  -- <bug 3450031>
                 DECODE(FDL.dist_type_flag, 'R', 'REC',
                                            'L', 'REV',
                                            NULL),  -- <bug 3450031>
                 fdl.ccid,
                 fth.batch_id,
                 fth.trx_id,
                 ftl.line_id
     FROM        FUN_TRX_HEADERS fth,
                 FUN_TRX_LINES ftl,
                 FUN_DIST_LINES fdl
     WHERE       fth.trx_id=p_trx_id
     AND         ftl.trx_id=fth.trx_id
     AND         ftl.line_id=fdl.line_id
     AND         fdl.party_type_flag='I';

--Bug: 9052792. Cursor to get the term_id from site level.

CURSOR c_site_term(p_site_use_id NUMBER) IS
	select PAYMENT_TERM_ID
	from HZ_CUST_SITE_USES_ALL
	where site_use_code = 'BILL_TO'
	and site_use_id = p_site_use_id;

--Bug: 9052792. Cursor to get the term_id from customer account level.

CURSOR c_account_term(p_cust_acct_id NUMBER) IS
	select STANDARD_TERMS
	from HZ_CUSTOMER_PROFILES
	where cust_account_id = p_cust_acct_id;

BEGIN

    if(funcmode='RUN') then

-- get the batch_id from the item attributes

    l_batch_id :=   wf_engine.getitemattrnumber(itemtype,
                                                itemkey,
                                               'BATCH_ID');

    l_trx_id :=   wf_engine.getitemattrnumber(itemtype,
                                             itemkey,
                                             'TRX_ID');
  WF_EVENT.AddParameterToList(p_name=>'BATCH_ID',
                                            p_value=>to_char(l_batch_id),
                                            p_parameterlist =>l_parameter_list
                        );


 WF_EVENT.AddParameterToList(p_name=>'TRX_ID',
                                            p_value=>to_char(l_trx_id),
                                            p_parameterlist =>l_parameter_list
                        );


      wf_engine.setitemattrtext(itemtype,
                                 itemkey,
                                 'ERROR_MSG',
                        'Number of Lines' || l_count || 'Trx:' || l_trx_id || 'Test1');

-- set the generic variables

   open c_info(l_trx_id);
   LOOP
   fetch c_info INTO
    l_batch_num,
    l_initiator_id,
    l_le_id,
    l_ledger_id,
    l_recipient_id,
    l_ap_le_id,
    l_trx_type_id,
    l_line.conversion_type,
    l_line.currency_code,
    l_line.description,
    l_line.gl_date,
    l_line.interface_line_attribute1,
    l_line.interface_line_attribute2,
    l_line.set_of_books_id,
    l_line.trx_date;
   exit when c_info%NOTFOUND;
   END LOOP;
   CLOSE c_info;

     wf_engine.setitemattrtext(itemtype,
                                 itemkey,
                                 'ERROR_MSG',
                        'Number of Lines' || l_count || 'init:' || l_initiator_id || 'Test2');

   -- Obtain the OU id

   l_ou_id :=FUN_TCA_PKG.get_ou_id(l_initiator_id);
   l_ap_ou_id :=FUN_TCA_PKG.get_ou_id(l_recipient_id);

   if((l_ou_id is NULL) OR (l_ap_ou_id is NULL)) then
   raise FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;


-- Transfer to table RA_INTERFACE_LINES


    open c_line(l_batch_id, l_trx_id);


    LOOP

    -- Amounts Transferred to AR should be
    -- Init Trx Amount: 1000 Cr,  AR Amount: -1000
    -- Init Trx Amount: -1000 Cr, AR Amount: 1000
    -- Init Trx Amount: 1000 Dr,  AR Amount: 1000
    -- Init Trx Amount: -1000 Dr, AR Amount: -1000

    FETCH c_line INTO
    l_line.amount,
    l_line.interface_line_attribute3;

   EXIT WHEN c_line%NOTFOUND;
   l_line.org_id:=l_ou_id;
   --added this for gscc warning
-- Bug 9634573 fetched src name from the table

	SELECT name into l_line.BATCH_SOURCE_NAME FROM
	RA_BATCH_SOURCES_ALL WHERE  BATCH_SOURCE_ID =  22 AND org_id = l_ou_id;

--   l_line.BATCH_SOURCE_NAME:= 'Global Intercompany';
   l_line.INTERFACE_LINE_CONTEXT:='INTERNAL_ALLOCATIONS';
   l_line.LINE_TYPE:='LINE';
  -- l_line.UOM_NAME :='Each'; bug 8675533
   l_count:=l_count+1;
-- obtain the AR transaction type / memo_line

     -- ER:8288979. Passing l_trx_id.
    -- <bug 3450031>
    FUN_TRX_TYPES_PUB.get_trx_type_map (
	p_org_id           => l_ou_id,
	p_trx_type_id      => l_trx_type_id,
        p_trx_date         => l_line.trx_date,
	p_trx_id           => l_trx_id,
	x_memo_line_id     => l_ar_memo_line_id,
	x_memo_line_name   => l_ar_memo_line_name,
	x_ar_trx_type_id   => l_ar_trx_type_id,
	x_ar_trx_type_name => l_ar_trx_type_name,
        x_default_term_id  => l_default_term_id);


   IF ((l_ar_memo_line_name IS NULL)
       OR (l_ar_trx_type_name IS NULL)) THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
   -- <bug 3450031 end>

-- Obtain the customer_id and address_id

   -- <bug 3450031>
   -- Change the passin parameters
  l_success :=
        FUN_TRADING_RELATION.get_customer(
            p_source       => 'INTERCOMPANY',
            p_trans_le_id  => l_ap_le_id,
            p_tp_le_id     => l_le_id,
            p_trans_org_id => l_ap_ou_id,
            p_tp_org_id    => l_ou_id,
            p_trans_organization_id => l_recipient_id,
            p_tp_organization_id => l_initiator_id,
            x_msg_data     => x_msg_data,
            x_cust_acct_id => l_customer_id,
            x_cust_acct_site_id  => l_address_id,
            x_site_use_id  => l_site_use_id);

   if((l_success<>true) OR (l_customer_id is NULL)
       OR (l_address_id is NULL)) then
   raise FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
--Bug: 9052792.
      	    l_term_id := NULL;

	    OPEN c_site_term (l_site_use_id);
            FETCH c_site_term INTO l_term_id;
            IF c_site_term%NOTFOUND THEN
                NULL;
            END IF;
            CLOSE c_site_term;

	    IF l_term_id IS NULL THEN
		    OPEN c_account_term (l_customer_id);
		    FETCH c_account_term INTO l_term_id;
		    IF c_account_term%NOTFOUND THEN
			NULL;
		    END IF;
		    CLOSE c_account_term;
	    END IF;
	    --Bug: 9126518
	    IF (l_term_id IS NOT NULL AND l_default_term_id IS NOT NULL) THEN
		l_default_term_id := l_term_id;
	    END IF;

  l_line.orig_system_bill_customer_id:=l_customer_id;
  l_line.orig_system_bill_address_id :=l_address_id;

  -- insert the line into the AR interface table
     wf_engine.setitemattrtext(itemtype,
                                 itemkey,
                                 'ERROR_MSG',
                                  'SOURCE:' || l_line.batch_source_name
                                  || 'LINE TYPE: ' || l_line.line_type
                                  || 'DESCRIPTION:' || l_line.description
                                  || 'CURRENCY_CODE:' || l_line.currency_code
                                  || 'Set_of_Book:' || l_line.set_of_books_id
                                  || 'Conversion Type:' || l_line.conversion_type
                                  || 'Test2.5');


    -- Bug: 6788142 Added PRIMARY_SALESREP_ID field in the insert query.
    -- insert into AR Interface table
    -- Bug: 7271703 populating the INTERFACE_LINE_ATTRIBUTE4 column
    -- with the batch_number.
   INSERT INTO RA_INTERFACE_LINES_ALL
   (
     AMOUNT,
     BATCH_SOURCE_NAME,
     CONVERSION_TYPE,
     CURRENCY_CODE,
     CUST_TRX_TYPE_ID, -- <bug 3450031>
     CUST_TRX_TYPE_NAME, -- <bug 3450031>
     DESCRIPTION,
     GL_DATE,
     INTERFACE_LINE_ATTRIBUTE1,
     INTERFACE_LINE_ATTRIBUTE2,
     INTERFACE_LINE_ATTRIBUTE3,
     INTERFACE_LINE_ATTRIBUTE4,
     INTERFACE_LINE_CONTEXT,
     LINE_TYPE,
     MEMO_LINE_ID, -- <bug 3450031>
     MEMO_LINE_NAME, -- <bug 3450031>
     ORG_ID,
     ORIG_SYSTEM_BILL_ADDRESS_ID,
     ORIG_SYSTEM_BILL_CUSTOMER_ID,
     SET_OF_BOOKS_ID,
     TRX_DATE,
     TAXABLE_FLAG,
     TERM_ID,
     LEGAL_ENTITY_ID,
     SOURCE_EVENT_CLASS_CODE,
     PRIMARY_SALESREP_ID
      )
   VALUES
   (
     l_line.AMOUNT,
     l_line.BATCH_SOURCE_NAME,
     l_line.CONVERSION_TYPE,
     l_line.CURRENCY_CODE,
     l_ar_trx_type_id,
     l_ar_trx_type_name,  -- <bug 3450031>
     NVL(l_line.DESCRIPTION,
         'Transactions from Global Intercompany'), -- <bug 3450031>
     l_line.GL_DATE,
     l_line.INTERFACE_LINE_ATTRIBUTE1,
     l_line.INTERFACE_LINE_ATTRIBUTE2,
     l_line.INTERFACE_LINE_ATTRIBUTE3,
     l_batch_num,
     l_line.INTERFACE_LINE_CONTEXT,
     l_line.LINE_TYPE,
     l_ar_memo_line_id,
     l_ar_memo_line_name,  -- <bug 3450031>
     l_line.ORG_ID,
     l_line.ORIG_SYSTEM_BILL_ADDRESS_ID,
     l_line.ORIG_SYSTEM_BILL_CUSTOMER_ID,
     l_line.SET_OF_BOOKS_ID,
     l_line.TRX_DATE,
	 -- Bug 9285035: Changed the value from 'S' to 'Y'
	 'Y',
     --'S',
     l_default_term_id,
     l_le_id,
     'INTERCOMPANY_TRX',
     '-3'
    );

    -- Bug No. 6788142. Inserting into RA_INTERFACE_SALESCREDITS_ALL table

    INSERT INTO RA_INTERFACE_SALESCREDITS_ALL
    (
     INTERFACE_LINE_CONTEXT ,
     INTERFACE_LINE_ATTRIBUTE1 ,
     INTERFACE_LINE_ATTRIBUTE2 ,
     INTERFACE_LINE_ATTRIBUTE3 ,
     INTERFACE_LINE_ATTRIBUTE4 ,
     INTERFACE_LINE_ATTRIBUTE5 ,
     INTERFACE_LINE_ATTRIBUTE6 ,
     INTERFACE_LINE_ATTRIBUTE7 ,
     INTERFACE_LINE_ATTRIBUTE8 ,
     INTERFACE_LINE_ATTRIBUTE9 ,
     INTERFACE_LINE_ATTRIBUTE10 ,
     INTERFACE_LINE_ATTRIBUTE11 ,
     INTERFACE_LINE_ATTRIBUTE12 ,
     INTERFACE_LINE_ATTRIBUTE13 ,
     INTERFACE_LINE_ATTRIBUTE14 ,
     INTERFACE_LINE_ATTRIBUTE15,
     SALES_CREDIT_PERCENT_SPLIT,
     SALES_CREDIT_TYPE_ID,
     SALESREP_ID,
     ORG_ID
   )
   VALUES
   (
     l_line.INTERFACE_LINE_CONTEXT,
     l_line.INTERFACE_LINE_ATTRIBUTE1,
     l_line.INTERFACE_LINE_ATTRIBUTE2,
     l_line.INTERFACE_LINE_ATTRIBUTE3,
     NULL,
     NULL,
     NULL,
     NULL,
     NULL,
     NULL,
     NULL,
     NULL,
     NULL,
     NULL,
     NULL,
     NULL,
     '100',
     '1',
     '-3',
     l_line.ORG_ID
   );

    wf_engine.setitemattrtext(itemtype,
                                 itemkey,
                                 'ERROR_MSG',
                        'Number of Lines: After Insert' || l_count || 'ORG:' || l_line.org_id || 'Test2.75');

       END LOOP;

       close c_line;

     wf_engine.setitemattrtext(itemtype,
                                 itemkey,
                                 'ERROR_MSG',
                        'Number of Lines' || l_count || 'Test3');


-- Insert into the AR distrubution table
    -- Amounts Transferred to AR should be
    -- Ini Dst Amount: 1000 Dr,  AR Amount: -1000
    -- Ini Dst Amount: -1000 Dr, AR Amount: 1000
    -- Ini Dst Amount: 1000 Cr,  AR Amount: 1000
    -- Ini Dst Amount: -1000 Cr, AR Amount: -1000

      open c_dist(l_trx_id);
      LOOP
      FETCH c_dist INTO
     l_dist_line.AMOUNT,
     l_dist_line.percent,  --<bug 3450031>
     l_dist_line.account_class,  -- <bug 3450031>
     l_dist_line.CODE_COMBINATION_ID,
     l_dist_line.INTERFACE_LINE_ATTRIBUTE1,
     l_dist_line.INTERFACE_LINE_ATTRIBUTE2,
     l_dist_line.INTERFACE_LINE_ATTRIBUTE3;

   exit when c_dist%NOTFOUND;
     l_dist_line.ORG_ID :=l_ou_id;
     l_dist_line.INTERFACE_LINE_CONTEXT:='INTERNAL_ALLOCATIONS';
   -- Insert the value into the distribution table


    INSERT INTO RA_INTERFACE_DISTRIBUTIONS_ALL  --<bug 3450031>
    (
     ACCOUNT_CLASS,
     AMOUNT,
     percent,  --<bug 3450031>
     CODE_COMBINATION_ID,
     INTERFACE_LINE_ATTRIBUTE1,
     INTERFACE_LINE_ATTRIBUTE2,
     INTERFACE_LINE_ATTRIBUTE3,
	 INTERFACE_LINE_ATTRIBUTE4,
     INTERFACE_LINE_CONTEXT,
     ORG_ID
     )
     VALUES
     (
     l_dist_line.ACCOUNT_CLASS,
     l_dist_line.AMOUNT,
     l_dist_line.percent,  --<bug 3450031>
     l_dist_line.CODE_COMBINATION_ID,
     l_dist_line.INTERFACE_LINE_ATTRIBUTE1,
     l_dist_line.INTERFACE_LINE_ATTRIBUTE2,
     l_dist_line.INTERFACE_LINE_ATTRIBUTE3,
	 l_batch_num,
     l_dist_line.INTERFACE_LINE_CONTEXT,
     l_dist_line.ORG_ID
     );

      END LOOP;
     CLOSE c_dist;

    -- <bug 3450031>
    -- uncomment update status logic
   -- Update the status

    FUN_TRX_PVT.update_trx_status(p_api_version   =>1.0,
                                  x_return_status =>l_return_status,
                                  x_msg_count     => l_message_count,
                                  x_msg_data      => l_message_data,
                                  p_trx_id        => l_trx_id,
                                  p_update_status_to => 'XFER_AR');

      -- Handle the API call return

    IF l_return_status = FND_API.G_RET_STS_ERROR   THEN

            raise FND_API.G_EXC_ERROR;
      END IF;


    IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR   THEN

            raise FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;



       -- Do we need commit? No
/*
       wf_engine.setitemattrtext(itemtype,
                                 itemkey,
                                 'ERROR_MSG',
                        'Number of Lines' || l_count || 'Trx:' || l_trx_id || 'Test');
*/


       COMMIT;
       resultout := 'COMPLETE';
       return;


    END IF; -- end of the run mode


-- Cancel mode

 IF (funcmode = 'CANCEL') THEN

    -- extra cancel code goes here

   null;

    -- no result needed
    resultout := 'COMPLETE';
    return;
  END IF;


EXCEPTION



WHEN OTHERS THEN
    -- Rcords this function call in the error system
    -- in the case of an exception.
    wf_core.context('FUN_INITIATOR_WF_PKG', 'TRANSFER_AR',
		    itemtype, itemkey, to_char(actid), funcmode);

END TRANSFER_AR;




/*-----------------------------------------------------|
| PROCEDURE CHECK_AR_SETUP                             |
|------------------------------------------------------|
|   Parameters       item_type      IN   Varchar2      |
|                    item_key       IN   Varchar2      |
|                    actid          IN   NUMBER        |
|                    funcmode       IN   Varchar2      |
|                    resultout      IN   Varchar2      |
|                                                      |
|------------------------------------------------------|
|   Description                                        |
|           Check the AR setup information             |
|                                                      |
|           Return true/false                          |
|                                                      |
|           It will call intercompany transaction API  |
|           to check AR related setup information      |
|-----------------------------------------------------*/


   PROCEDURE ChECK_AR_SETUP   (itemtype           IN VARCHAR2,
                               itemkey            IN VARCHAR2,
                               actid              IN NUMBER,
                               funcmode           IN VARCHAR2,
                               resultout          OUT  NOCOPY VARCHAR2)

IS

l_message_count  Number;
l_status Varchar2(1);
l_msg_data Varchar2(2000);
l_message  Varchar2(2000);
l_trx_amt Number;
l_trx_id  Number;
l_batch_id Number;

BEGIN

 IF (funcmode = 'RUN') THEN


       l_status:=FND_API.G_RET_STS_SUCCESS;

       l_trx_id := wf_engine.GetItemAttrNumber(itemtype => itemtype,
                                           itemkey  => itemkey,
                                           aname    => 'TRX_ID');

       l_batch_id := wf_engine.GetItemAttrNumber(itemtype => itemtype,
                                                 itemkey  => itemkey,
                                                 aname    => 'BATCH_ID');

     -- call transaction API to check the ar setup
     fun_trx_pvt.ar_transfer_validate (
           p_api_version        => 1.0,
           p_init_msg_list      => FND_API.G_TRUE,
           p_validation_level   => FND_API.G_VALID_LEVEL_FULL,
           x_return_status      => l_status,
           x_msg_count          => l_message_count,
           x_msg_data           => l_msg_data,
           p_batch_id           => l_batch_id,
           p_trx_id             => l_trx_id);

	-- Bug: 7319371 Changing the query to make the l_trx_amt number reginal independent
	-- Also since the fun_trx_batches table is not used in the query removing a reference to the same

       --select ltrim(to_char(decode(nvl(h.reci_amount_cr,0),0,h.reci_amount_dr,h.reci_amount_cr),'999999999.99'))
       --into l_trx_amt
       --from fun_trx_headers h, fun_trx_batches b
       --where h.trx_id = l_trx_id
       --and b.batch_id = l_batch_id;

	SELECT LTRIM(TO_CHAR(DECODE(NVL(H.RECI_AMOUNT_CR,0),0,H.RECI_AMOUNT_DR,
                                                    H.RECI_AMOUNT_CR),
                     '999999999D99'))
	INTO   l_trx_amt
	FROM   FUN_TRX_HEADERS H
	WHERE  H.TRX_ID = l_trx_id;

	-- Bug: 7319371 END


       wf_engine.setitemattrnumber( itemtype => itemtype,
                                  itemkey  => itemkey,
                                  aname    => 'TRX_AMT',
                                  avalue   => l_trx_amt);

     -- Check the return status
   if(l_status <> FND_API.G_RET_STS_SUCCESS) THEN

     --  assembling the error message

     l_message :=FUN_WF_COMMON.concat_msg_stack(l_message_count);

     -- set the item attribute ERROR_MSG

     wf_engine.setitemattrtext(itemtype,
                               itemkey,
                               'ERROR_MSG',
                               l_message);
         -- return false
        resultout:='COMPLETE:F';
    ELSE
    -- AR setup is vcalid
    resultout := 'COMPLETE:T';
    return;
     END IF;
  END IF;

EXCEPTION

WHEN OTHERS THEN

    -- Rcords this function call in the error system
    -- in the case of an exception.

    wf_core.context('FUN_INITIATOR_WF_PKG', 'CHECK_AR_SETUP',
		    itemtype, itemkey, to_char(actid), funcmode);

    RAISE;

END  CHECK_AR_SETUP;




/*-----------------------------------------------------|
| PROCEDURE GET_INVOICE                                |
|------------------------------------------------------|
|   Parameters       p_subscription_guid IN RAW        |
|                    p_event             IN OUT        |
|                                        WF_EVENT_T    |
|                                                      |
|   Return           Varchar2                          |
|                                                      |
|------------------------------------------------------|
|   Description                                        |
|           This is the event subscription function    |
|           for AR Autoinvoice transfer event:         |
|            oracle.apps.ar.batch.AutoInvoice.run      |
|           to check AR related setup information      |
|                                                      |
|            It will retrieve AR invoice from AR table |
|           and then raise AR transfer complete event  |
|-----------------------------------------------------*/


   FUNCTION GET_INVOICE (p_subscription_guid IN RAW,
                         p_event             IN OUT NOCOPY WF_EVENT_T)
                         return Varchar2  IS

l_parameter_list        wf_parameter_list_t := wf_parameter_list_t();
l_parameter_list_out    wf_parameter_list_t := wf_parameter_list_t();
l_parameter_t           wf_parameter_t;
l_parameter_name        l_parameter_t.name%type;
l_parameter_value       l_parameter_t.value%type;

l_request_id      Number;
i                 PLS_Integer;
l_batch_source_id Number;
l_batch_id        Number;
l_trx_id          Number;
l_return_status   Varchar2(1);
l_message_count   NUMBER;
l_message_data    Varchar2(1000);
l_event_key       Varchar2(240);

-- cursor to retrieve all imported transactions
cursor c_trans(p_request_id IN NUMBER) IS

   SELECT        rct.trx_number invoice_number,
                 rct.interface_header_attribute1 batch_id,
                 rct.interface_header_attribute2 trx_id
   FROM          ra_customer_trx_all rct,
                 ra_batch_sources_all rbs
   WHERE         rct.request_id=p_request_id
   AND           rct.batch_source_id=rbs.batch_source_id
   AND           NVL(rct.org_id, -99) =NVL(rbs.org_id, -99)
   AND           rbs.name=(SELECT name FROM
			RA_BATCH_SOURCES_ALL WHERE  BATCH_SOURCE_ID =  22 AND org_id = rct.org_id);


BEGIN
  l_request_id := p_event.GetValueForParameter('REQUEST_ID');

  -- Retieve the transaction number from AR table (note we are working with
  --  ALL table now)

   -- We need raise individual event for each transaction
   -- (assume the import is successful)

   FOR l_trans IN c_trans(l_request_id)
   LOOP
       -- Update the AR invoice number

       UPDATE FUN_TRX_HEADERS
       SET    ar_invoice_number = l_trans.invoice_number
       WHERE  trx_id            = l_trans.trx_id
       AND    batch_id          = l_trans.batch_id
       AND    ar_invoice_number IS NULL;


       IF SQL%ROWCOUNT = 1
       THEN
           -- Raise the AR transfer complete event

           -- Initiate the parameter list
           l_parameter_list_out :=wf_parameter_list_t();

           WF_EVENT.AddParameterToList(p_name=>'BATCH_ID',
                                 p_value=>TO_CHAR(l_trans.batch_id),
                                 p_parameterlist=>l_parameter_list_out);

           WF_EVENT.AddParameterToList(p_name=>'TRX_ID',
                                 p_value=>TO_CHAR(l_trans.trx_id),
                                 p_parameterlist=>l_parameter_list_out);

           WF_EVENT.AddParameterToList(p_name=>'INVOICE_NUM',
                                 p_value=>TO_CHAR(l_trans.invoice_number),
                                 p_parameterlist=>l_parameter_list_out);

          -- generate the event key

           l_event_key := FUN_INITIATOR_WF_PKG.GENERATE_KEY
                                         (p_batch_id=>l_trans.batch_id,
                                          p_trx_id=>l_trans.trx_id);


          -- Raise the event

          WF_EVENT.RAISE(p_event_name =>'oracle.apps.fun.manualtrx.arcomplete.send',
                p_event_key  =>l_event_key,
                p_parameters =>l_parameter_list_out);

            l_parameter_list_out.delete();


      END IF;

      COMMIT;

   END LOOP;

RETURN 'SUCCESS';

EXCEPTION

WHEN OTHERS THEN

    -- Rcords this function call in the error system
    -- in the case of an exception.

    wf_core.context('FUN_INITIATOR_WF_PKG', 'GET_INVOICE',
		    p_event.getEventName(), p_subscription_guid);
    WF_EVENT.setErrorInfo(p_event, 'ERROR');
    return 'ERROR';


END  GET_INVOICE;




/*-----------------------------------------------------|
| PROCEDURE GENERATE_KEY                               |
|------------------------------------------------------|
|   Parameters       p_trx_id            IN NUMBER     |
|                                                      |
|   Return           Varchar2                          |
|                                                      |
|------------------------------------------------------|
|   Description                                        |
|           Generate the key for events                |
|-----------------------------------------------------*/





      FUNCTION GENERATE_KEY(   p_batch_id in NUMBER,
                               p_trx_id in  NUMBER) return Varchar2
IS

BEGIN
   return to_char(p_batch_id) || '_' || to_char(p_trx_id) || '_' || SYS_GUID();

EXCEPTION

   WHEN OTHERS   THEN
          RAISE;


END GENERATE_KEY;

-------------------------------------------------------------------------------
--Start of Comments
--Function:
--  After transactions are interfaced to AR and invoices have been created,
--  FUN_TRX_HEADERS.ar_invoice_number will be updated with the corresonding
--  AR_CUSTOMER_TRX_ALL.trx_number

-- THIS PROCESS IS NOT USED ANYMORE
-- INSTEAD GET_INVOICE IS USED

--End of Comments
-------------------------------------------------------------------------------

PROCEDURE update_trx_headers(p_request_id IN NUMBER)
IS
    l_trx_header_type fun_trx_header_type;

BEGIN


   NULL;

   /* NOT USED ANYMORE

    -- Get AR invoice number given autoinvoice conc. request id
    SELECT TO_NUMBER(RCT.interface_header_attribute1),
           TO_NUMBER(RCT.interface_header_attribute2),
           RCT.trx_number
      BULK COLLECT INTO
           l_trx_header_type.attribute1,
           l_trx_header_type.attribute2,
           l_trx_header_type.invoice_number
      FROM RA_CUSTOMER_TRX_ALL RCT,
           RA_BATCH_SOURCES_ALL RBS
     WHERE RBS.name = (SELECT name FROM
			RA_BATCH_SOURCES_ALL WHERE  BATCH_SOURCE_ID =  22 AND org_id = rct.org_id)
       AND RBS.batch_source_id = RCT.batch_source_id
       AND RBS.org_id = RCT.org_id
       AND RCT.request_id = p_request_id;

    IF SQL%NOTFOUND THEN
        RETURN;
    END IF;

    -- update FUN_TRX_HEADERS with the corresponding invoice number
    FORALL i IN 1..l_trx_header_type.attribute1.COUNT
        UPDATE FUN_TRX_HEADERS
           SET ar_invoice_number = l_trx_header_type.invoice_number(i)
         WHERE batch_id = l_trx_header_type.attribute1(i)
           AND trx_id = l_trx_header_type.attribute2(i);

   */


EXCEPTION
    WHEN OTHERS THEN
        NULL;
END update_trx_headers;


---------------------------------------------------------------------------
--Start of Comments
--Function:
--  After transactions are interfaced to AR and invoices have been created,
--  it will get AR invoice number based on autoinvice conc. program
--  request_id, and then FUN_TRX_HEADERS.ar_invoice_number will be updated
--  with the corresonding AR invoice number

-- THIS PROCESS IS NOT USED ANYMORE
-- INSTEAD, GET_INVOICE IS CALLED FROM AR BUSINESS EVENT

--End of Comments
---------------------------------------------------------------------------


PROCEDURE post_ar_invoice(
    itemtype    IN varchar2,
    itemkey     IN varchar2,
    actid       IN number,
    funcmode    IN varchar2,
    resultout   IN OUT NOCOPY varchar2)
IS
    l_request_id    NUMBER;

BEGIN

    /*
    IF (funcmode = 'RUN') THEN
        fnd_msg_pub.initialize;

        l_request_id := wf_engine.GetItemAttrNumber(
                                  itemtype => itemtype,
                                  itemkey  => itemkey,
                                  aname    => 'REQUEST_ID');

        update_trx_headers(l_request_id);

        commit;
        resultout := wf_engine.eng_completed||':'||wf_engine.eng_null;

        RETURN;
    END IF;
    */

    resultout := wf_engine.eng_null;
    RETURN;

    EXCEPTION
        WHEN OTHERS THEN
            wf_core.context('FUN_INITIATOR_WF_PKG', 'post_ar_invoice',
                            itemtype, itemkey, TO_CHAR(actid), funcmode);

        RAISE;
END post_ar_invoice;


END FUN_INITIATOR_WF_PKG;


/
