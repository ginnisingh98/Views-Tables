--------------------------------------------------------
--  DDL for Package Body OE_APPROVALS_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_APPROVALS_WF" AS
/* $Header: OEXWAPRB.pls 120.4.12010000.2 2008/10/21 06:01:08 smanian ship $ */

--  Start of Comments
--  API name    OE_APPROVALS_WF
--  Type        Public
--  Version     Current version = 1.0
--              Initial version = 1.0

/*=======================*/
/* Private procedures    */
/*=======================*/

g_defer_min CONSTANT NUMBER := 5; --bug7386039

/**********************
*      get_user_id    *
**********************/
function get_user_id
  return number
IS
BEGIN
 return NVL(FND_GLOBAL.USER_ID, -1);
END get_user_id;




/****************************
*     Initiate_Approval     *
****************************/
Procedure Initiate_Approval
       (itemtype  in varchar2,
        itemkey   in varchar2,
        actid     in number,
        funcmode  in varchar2,
        resultout in out NOCOPY /* file.sql.39 change */ varchar2)
IS

  l_transaction_id            NUMBER;
  l_role                      VARCHAR2(240);
  l_sales_document_type_code  VARCHAR2(30);

  l_attachment_location       VARCHAR2(240); --??
  l_msg_count                 NUMBER;
  l_msg_data                  VARCHAR2(240);
  l_return_status             VARCHAR2(30);

  l_sold_to_org_id        NUMBER;
  l_salesrep_id           NUMBER;
  l_salesrep              VARCHAR2(240);
  l_sold_to               VARCHAR2(240);
  --l_customer_number       NUMBER;
  l_customer_number       varchar2(30) ;-- bug4575846
  l_expiration_date       DATE;

  l_aname  wf_engine.nametabtyp;
  l_avaluetext wf_engine.texttabtyp;

  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
BEGIN

  --
  -- RUN mode - normal process execution
  --
  if (funcmode = 'RUN') then

    l_transaction_id     := to_number(itemkey);

    OE_STANDARD_WF.Set_Msg_Context(actid);
        OE_MSG_PUB.set_msg_context(
           p_entity_code           => 'HEADER'
          ,p_entity_id                  => to_number(itemkey)
          ,p_header_id                    => to_number(itemkey));

    IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'Initiate_Approval ', 1) ;
    END IF;

    -- Delete any previous approval transaction data.
    DELETE
      FROM OE_APPROVER_TRANSACTIONS
     WHERE TRANSACTION_ID = l_transaction_id;

    IF itemtype = OE_GLOBALS.G_WFI_NGO THEN
      l_sales_document_type_code := wf_engine.GetItemAttrText(
                                OE_GLOBALS.G_WFI_NGO,
                                l_transaction_id,
                                'SALES_DOCUMENT_TYPE_CODE');
    END IF;

    -- CALL THE GET_NEXT_APPROVER to get the first approver
    l_role := Get_Next_Approver_internal(l_transaction_id,
                                         itemtype,
                                         l_sales_document_type_code);
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'Role->' || l_role, 1) ;
    END IF;


    if l_role is NULL then
       IF l_debug_level  > 0 THEN
         oe_debug_pub.add('Role is null. Set transaction to Not Eligible', 1 ) ;
       END IF;


     /*  OE_ORDER_WF_UTIL.Update_Flow_Status_Code
                 (p_item_type                 => itemtype,
                  p_header_id                 => l_transaction_id,
                  p_flow_status_code          => 'INTERNAL_APPROVED',
                  p_sales_document_type_code  => l_sales_document_type_code,
                  x_return_status             => l_return_status );

       IF l_debug_level  > 0 THEN
           oe_debug_pub.add('Initiate_approval STATUS FROM Update_Flow_Status_Code: '|| l_return_status );
       END IF;

       IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            OE_STANDARD_WF.Save_Messages;
            OE_STANDARD_WF.Clear_Msg_Context;
            app_exception.raise_exception;
       END IF;

      */

       resultout := 'COMPLETE:NOT_ELIGIBLE';
       OE_STANDARD_WF.Save_Messages;
       OE_STANDARD_WF.Clear_Msg_Context;
       return;

    else
       IF l_debug_level  > 0 THEN
         oe_debug_pub.add('Setting the role to->' || l_role, 1 ) ;
       END IF;

       wf_engine.SetItemAttrText(itemtype,
                              itemkey,
                              'NOTIFICATION_APPROVER',
                              l_role);

       IF l_debug_level  > 0 THEN
           oe_debug_pub.add('Before calling OE_CONTRACTS_UTIL.attachment_location.. ', 1);
       END IF;

       OE_CONTRACTS_UTIL.attachment_location
                       (p_api_version      => 1.0,
                        p_doc_type         => l_sales_document_type_code,
                        p_doc_id           => l_transaction_id,
                        x_workflow_string  => l_attachment_location,
                        x_return_status    => l_return_status,
                        x_msg_count        => l_msg_count,
                        x_msg_data         => l_msg_data );


       IF l_debug_level  > 0 THEN
           oe_debug_pub.add('l_attachment_location->' || l_attachment_location, 1);
           oe_debug_pub.add('l_return_status->' || l_return_status, 1);
           oe_debug_pub.add('l_msg_data->' || l_msg_data, 1);
       END IF;

       IF l_return_status = FND_API.G_RET_STS_ERROR THEN
                -- start data fix project
                -- OE_STANDARD_WF.Save_Messages;
                -- OE_STANDARD_WF.Clear_Msg_Context;
                -- end data fix project
                app_exception.raise_exception;
       ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                -- start data fix project
                -- OE_STANDARD_WF.Save_Messages;
                -- OE_STANDARD_WF.Clear_Msg_Context;
                -- end data fix project
                app_exception.raise_exception;
       END IF;

       IF l_attachment_location is NOT NULL THEN
          wf_engine.SetItemAttrText(itemtype,
                              itemkey,
                              'CONTRACT_ATTACHMENT',
                              l_attachment_location);
       END IF;


       --------------------------------------------------
       -- Set Header Attributes Values for Negotiation --

       IF itemtype = OE_GLOBALS.G_WFI_NGO THEN
         IF l_sales_document_type_code = 'O' THEN
           select sold_to_org_id, expiration_date, salesrep_id
           into l_sold_to_org_id, l_expiration_date, l_salesrep_id
           from oe_order_headers_all
           where header_id = to_number(itemkey);
         ELSE
           select obha.sold_to_org_id, obhe.end_date_active, obha.salesrep_id
           into l_sold_to_org_id, l_expiration_date, l_salesrep_id
           from oe_blanket_headers_all obha, oe_blanket_headers_ext obhe
           where obha.header_id = to_number(itemkey)
           and   obha.order_number = obhe.order_number;
         END IF;

         l_salesrep := OE_Id_To_Value.Salesrep(p_salesrep_id=>l_salesrep_id);
         OE_Id_To_Value.Sold_To_Org(p_sold_to_org_id  => l_sold_to_org_id,
                                  x_org             => l_sold_to,
                                  x_customer_number => l_customer_number);


         l_aname(1) := 'SALESPERSON';
         l_avaluetext(1) := l_salesrep;
         l_aname(2) := 'SOLD_TO';
         l_avaluetext(2) := l_sold_to;
         l_aname(3) := 'EXPIRATION_DATE';
         l_avaluetext(3) := l_expiration_date;

         wf_engine.SetItemAttrTextArray( itemtype
                                       , itemkey
                                       , l_aname
                                       , l_avaluetext
                                       );
         -- End setting Header Attributes
       END IF;
       -------itemtype = OE_GLOBALS.G_WFI_NGO-------

       OE_ORDER_WF_UTIL.Update_Flow_Status_Code
                 (p_item_type                 => itemtype,
                  p_header_id                 => l_transaction_id,
                  p_flow_status_code          => 'PENDING_INTERNAL_APPROVAL',
                  p_sales_document_type_code  => l_sales_document_type_code,
                  x_return_status             => l_return_status );

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add('Initiate_Approval STATUS FROM Update_Flow_Status_Code: '|| l_return_status );
        END IF;

        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                -- start data fix project
                -- OE_STANDARD_WF.Save_Messages;
                -- OE_STANDARD_WF.Clear_Msg_Context;
                -- end data fix project
                app_exception.raise_exception;
        END IF;


        resultout := 'COMPLETE:COMPLETE';
        OE_STANDARD_WF.Clear_Msg_Context;
        return;
    end if;
 end if; -- End for 'RUN' mode

  --
  -- CANCEL mode - activity 'compensation'
  --
  -- This is an event point is called with the effect of the activity must
  -- be undone, for example when a process is reset to an earlier point
  -- due to a loop back.
  --
  if (funcmode = 'CANCEL') then

    -- your cancel code goes here
    null;

    -- no result needed
    resultout := 'COMPLETE';
    return;
  end if;


  --
  -- Other execution modes may be created in the future.  Your
  -- activity will indicate that it does not implement a mode
  -- by returning null
  --
--  resultout := '';
--  return;

exception
  when others then
    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context('OE_APPROVALS_WF', 'Initiate_Approval',
                    itemtype, itemkey, to_char(actid), funcmode);
    -- start data fix project
    OE_STANDARD_WF.Add_Error_Activity_Msg(p_actid => actid,
                                          p_itemtype => itemtype,
                                          p_itemkey => itemkey);
    OE_STANDARD_WF.Save_Messages;
    OE_STANDARD_WF.Clear_Msg_Context;
    -- end data fix project
    raise;


END Initiate_Approval;


/**********************************
*       Get_Next_Approver         *
**********************************/
/*
   This procedure sets the NOTIFICATION_APPROVER item attribute based on
   the definition/setup in the OM Approver List form, insert/update
   the proper record in the OM Approval transaction table
   OE_APPROVAL_TRANSACTIONS. Checks the max(approver_sequence) from
   OE_APPROVAL_TRANSACTIONS given a transaction_id, and then fetches
   the role from the OE_APPROVER_LISTS with approver_sequence = max+1
   and insert the record in OE_APPROVER_TRANSACTIONS.
   Returns Y if it finds the next approver and returns N if there is no
   approver left. In the case there is no more approvers, it will update
   the status to APPROVED
*/
Procedure Get_Next_Approver
       (itemtype  in varchar2,
        itemkey   in varchar2,
        actid     in number,
        funcmode  in varchar2,
        resultout in out NOCOPY /* file.sql.39 change */ varchar2)
IS

  l_transaction_id NUMBER;
  l_role           VARCHAR2(240);
  l_sales_document_type_code VARCHAR2(30);

  l_return_status VARCHAR2(30);
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;

  l_sold_to_org_id        NUMBER;
  l_salesrep_id           NUMBER;
  l_salesrep              VARCHAR2(240);
  l_sold_to               VARCHAR2(240);
  --l_customer_number       NUMBER;
  l_customer_number       varchar2(30); --bug4575846
  l_expiration_date       DATE;

  l_aname  wf_engine.nametabtyp;
  l_avaluetext wf_engine.texttabtyp;

BEGIN

  --
  -- RUN mode - normal process execution
  --
  if (funcmode = 'RUN') then

    l_transaction_id     := to_number(itemkey);

    OE_STANDARD_WF.Set_Msg_Context(actid);
        OE_MSG_PUB.set_msg_context(
           p_entity_code           => 'HEADER'
          ,p_entity_id                  => to_number(itemkey)
          ,p_header_id                    => to_number(itemkey));

    IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'Get_Next_Approver ', 1 ) ;
    END IF;

    -- We need to set the status of the last approver to APPROVED here
    -- in the OE_APPROVER_TRANSACTIONS
     UPDATE OE_APPROVER_TRANSACTIONS
        SET APPROVAL_STATUS = 'APPROVED'
      WHERE TRANSACTION_ID = l_transaction_id
 --- ?? phase code = not really needed
        AND APPROVER_SEQUENCE = (select max(APPROVER_SEQUENCE)
                                   from OE_APPROVER_TRANSACTIONS
                                  WHERE TRANSACTION_ID = l_transaction_id);


    IF itemtype = OE_GLOBALS.G_WFI_NGO THEN
         l_sales_document_type_code := wf_engine.GetItemAttrText(
                                OE_GLOBALS.G_WFI_NGO,
                                l_transaction_id,
                                'SALES_DOCUMENT_TYPE_CODE');
    END IF;

    -- CALL THE Get_Next_Approver_internal
    l_role := Get_Next_Approver_internal(l_transaction_id,
                                         itemtype,
                                         l_sales_document_type_code);
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('Role-> ' || l_role, 1) ;
    END IF;



    if l_role is NULL then

       /*
       OE_ORDER_WF_UTIL.Update_Flow_Status_Code
                 (p_item_type                 => itemtype,
                  p_header_id                 => l_transaction_id,
                  p_flow_status_code          => 'APPROVED',
                  p_sales_document_type_code  => l_sales_document_type_code,
                  x_return_status             => l_return_status );

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add('Get_next_approval STATUS FROM Update_Flow_Status_Code: '|| l_return_status );
        END IF;

        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                OE_STANDARD_WF.Save_Messages;
                OE_STANDARD_WF.Clear_Msg_Context;
                app_exception.raise_exception;
        END IF;
        */

       resultout := 'COMPLETE:N';
       OE_STANDARD_WF.Save_Messages;
       OE_STANDARD_WF.Clear_Msg_Context;
       return;

    else
       wf_engine.SetItemAttrText(itemtype,
                              itemkey,
                              'NOTIFICATION_APPROVER',
                              l_role);




       -----------------------------------
       -- Set Header Attributes Values  --
       IF itemtype = OE_GLOBALS.G_WFI_NGO THEN
                           ----???? Join to the value table
         IF l_sales_document_type_code = 'O' THEN
           select sold_to_org_id, expiration_date, salesrep_id
             into l_sold_to_org_id, l_expiration_date, l_salesrep_id
             from oe_order_headers_all
            where header_id = l_transaction_id;
         ELSE

           select obha.sold_to_org_id, obhe.end_date_active, obha.salesrep_id
             into l_sold_to_org_id, l_expiration_date, l_salesrep_id
             from oe_blanket_headers_all obha,
                  oe_blanket_headers_ext obhe
            where obha.header_id = l_transaction_id
              and obha.order_number = obhe.order_number;

         END IF;

         l_salesrep := OE_Id_To_Value.Salesrep(p_salesrep_id=>l_salesrep_id);
         OE_Id_To_Value.Sold_To_Org(p_sold_to_org_id  => l_sold_to_org_id,
                                  x_org             => l_sold_to,
                                  x_customer_number => l_customer_number);


         l_aname(1) := 'SALESPERSON';
         l_avaluetext(1) := l_salesrep;
         l_aname(2) := 'SOLD_TO';
         l_avaluetext(2) := l_sold_to;
         l_aname(3) := 'EXPIRATION_DATE';
         l_avaluetext(3) := l_expiration_date;

         wf_engine.SetItemAttrTextArray( itemtype
                                       , itemkey
                                       , l_aname
                                       , l_avaluetext
                                       );
       END IF;
       -- End setting Header Attributes



       resultout := 'COMPLETE:Y';
       OE_STANDARD_WF.Save_Messages;
       OE_STANDARD_WF.Clear_Msg_Context;
       return;
    end if;

 end if; -- End for 'RUN' mode

  --
  -- CANCEL mode - activity 'compensation'
  --
  -- This is an event point is called with the effect of the activity must
  -- be undone, for example when a process is reset to an earlier point
  -- due to a loop back.
  --
  if (funcmode = 'CANCEL') then

    -- your cancel code goes here
    null;

    -- no result needed
    resultout := 'COMPLETE';
    return;
  end if;


  --
  -- Other execution modes may be created in the future.  Your
  -- activity will indicate that it does not implement a mode
  -- by returning null
  --
--  resultout := '';
--  return;

exception
  when others then
    -- The line below records this function call in the error system
    -- in the case of an exception.
    wf_core.context('OE_APPROVALS_WF', 'Get_Next_Approver',
                    itemtype, itemkey, to_char(actid), funcmode);
    -- start data fix project
    OE_STANDARD_WF.Add_Error_Activity_Msg(p_actid => actid,
                                          p_itemtype => itemtype,
                                          p_itemkey => itemkey);
    OE_STANDARD_WF.Save_Messages;
    OE_STANDARD_WF.Clear_Msg_Context;
    -- end data fix project
    raise;


END Get_Next_Approver;



/**********************************
*    Get_Next_Approver_InternaL   *
**********************************/
/*
   Gets called from Initiate_approval and Get_next_approval
*/
function Get_Next_Approver_internal (
                       p_transaction_id in NUMBER,
                       p_itemtype in VARCHAR2,
                       p_sales_document_type_code in VARCHAR2,
                       p_query_mode   in VARCHAR2 default 'N'
                              )
  RETURN VARCHAR2
IS

  l_role varchar2(320);
  l_approver_sequence number;
  l_curr_approver_sequence number;
  l_list_id           NUMBER;
  l_user_id           NUMBER;
  l_transaction_type_id      NUMBER;
  l_transaction_phase_code   VARCHAR2(30);

  l_check_default_list       VARCHAR2(1) := 'N';

  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;


  -- Get the next approver_sequence and its role
--   cursor c_get_next_approver (m_cur_seq number, m_list_id number) is
--   select ROLE, APPROVER_SEQUENCE
--     from OE_APPROVER_LIST_MEMBERS
--    where list_id = m_list_id
--      and APPROVER_SEQUENCE > m_cur_seq
--      and ACTIVE_FLAG = 'Y'
--     order by APPROVER_SEQUENCE;

   cursor c_get_next_approver is
   select ROLE, APPROVER_SEQUENCE
     from OE_APPROVER_LIST_MEMBERS
    where list_id = l_list_id
      and APPROVER_SEQUENCE > l_curr_approver_sequence
      and ACTIVE_FLAG = 'Y'
     order by APPROVER_SEQUENCE;


BEGIN
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add('Get_Next_Approver_internal', 1 ) ;
  END IF;

  -- Get the User ID
  l_user_id := OE_APPROVALS_WF.get_user_id;

  -- First get the transaction_type_id and the transaction_phase
  -- We need to hit different table to find that out

  IF l_debug_level  > 0 THEN
    oe_debug_pub.add('SaleDocumentTypeCode-> ' || p_sales_document_type_code, 1) ;
  END IF;

  -- If p_sales_document_type_code is not B, it is either a quote or order or line
  IF nvl(p_sales_document_type_code, 'XXXX') = 'B' THEN
      select ORDER_TYPE_ID, nvl(TRANSACTION_PHASE_CODE, 'F')
        into l_transaction_type_id, l_transaction_phase_code
        from oe_blanket_headers_all
       where header_id = p_transaction_id;
      IF l_debug_level  > 0 THEN
        oe_debug_pub.add('Transaction_type_id->' || l_transaction_type_id, 1) ;
        oe_debug_pub.add('TransactionPhase->' || l_transaction_phase_code, 1);
      END IF;

  ELSE
      select ORDER_TYPE_ID, nvl(TRANSACTION_PHASE_CODE, 'F')
        into l_transaction_type_id, l_transaction_phase_code
        from oe_order_headers_all
       where header_id = p_transaction_id;
      IF l_debug_level  > 0 THEN
        oe_debug_pub.add('Transaction_type_id->' || l_transaction_type_id, 1) ;
        oe_debug_pub.add('TransactionPhase->' || l_transaction_phase_code, 1);
      END IF;

  END IF;

  -- Get the approver list_id
  BEGIN
      select list_id
        into l_list_id
        from OE_APPROVER_LISTS
       where TRANSACTION_TYPE_ID = l_transaction_type_id
         and TRANSACTION_PHASE_CODE is not NULL
         and TRANSACTION_PHASE_CODE = l_transaction_phase_code
         and SYSDATE BETWEEN NVL(START_DATE_ACTIVE, SYSDATE )
                         AND NVL(END_DATE_ACTIVE, SYSDATE );
      IF l_debug_level  > 0 THEN
        oe_debug_pub.add('ListID-> ' || l_list_id, 1) ;
      END IF;

   EXCEPTION
        when NO_DATA_FOUND then
        IF l_debug_level  > 0 THEN
          oe_debug_pub.add('No ListID Found ', 1) ;
        END IF;
        l_check_default_list := 'Y';
   end;


   if l_check_default_list = 'Y' then

     BEGIN
         select list_id
           into l_list_id
           from OE_APPROVER_LISTS
          where TRANSACTION_TYPE_ID = l_transaction_type_id
            and TRANSACTION_PHASE_CODE is NULL
            and SYSDATE BETWEEN NVL(START_DATE_ACTIVE, SYSDATE )
                            AND NVL(END_DATE_ACTIVE, SYSDATE );
         IF l_debug_level  > 0 THEN
           oe_debug_pub.add('Default ListID-> ' || l_list_id, 1) ;
         END IF;

      EXCEPTION
           when NO_DATA_FOUND then
            IF l_debug_level  > 0 THEN
             oe_debug_pub.add('No Default ListID Found ', 1) ;
            END IF;
            l_role := NULL;
            return l_role;
      end;

   end if;


   -------------------------------------------
   -- Get the Max Current APPROVER_SEQUENCE --
   -------------------------------------------
   BEGIN
     select max(APPROVER_SEQUENCE)
       into l_curr_approver_sequence
       from OE_APPROVER_TRANSACTIONS
      where TRANSACTION_ID = p_transaction_id
        and TRANSACTION_TYPE_ID = l_transaction_type_id
        and TRANSACTION_PHASE_CODE   = l_transaction_phase_code;

     IF l_debug_level  > 0 THEN
         oe_debug_pub.add('Max Curr APPROVER_SEQUENCE-> ' || l_curr_approver_sequence, 1);
     END IF;
     IF l_curr_approver_sequence is null Then
         l_curr_approver_sequence := 0;
     END IF;

   EXCEPTION
     when NO_DATA_FOUND then
       IF l_debug_level  > 0 THEN
         oe_debug_pub.add('Max Curr APPROVER_SEQUENCE-> ' || l_curr_approver_sequence, 1);
       END IF;

       l_curr_approver_sequence := 0;
   END;

--   open c_get_next_approver (m_cur_seq => l_curr_approver_sequence,
--                             m_list_id => l_list_id);

   open c_get_next_approver;

   FETCH c_get_next_approver
    INTO l_role, l_approver_sequence;

   if c_get_next_approver%notfound then
       IF l_debug_level  > 0 THEN
          oe_debug_pub.add('No Role ', 1) ;
       END IF;

       l_role := NULL;
   CLOSE c_get_next_approver;
       return l_role;

   end if;

   CLOSE c_get_next_approver;
   oe_debug_pub.add('Role-> ' || l_role, 1) ;


   IF p_query_mode = 'N' THEN
    IF l_debug_level  > 0 THEN
       oe_debug_pub.add('Inserting into OE_APPROVER_TRANSACTIONS ', 1) ;
    END IF;
   -- insert this next approver in the OE_APPROVER_TRANSACTIONS
   INSERT INTO OE_APPROVER_TRANSACTIONS
         (
             TRANSACTION_ID
            ,TRANSACTION_TYPE_ID   --?? Do we need this. evalute
            ,TRANSACTION_PHASE_CODE
            ,ROLE
            ,APPROVER_SEQUENCE
            ,APPROVAL_STATUS
            ,CREATION_DATE
            ,CREATED_BY
            ,LAST_UPDATE_DATE
            ,LAST_UPDATED_BY
            ,LAST_UPDATE_LOGIN

         )
   VALUES
         (
             p_transaction_id
            ,l_transaction_type_id
            ,l_transaction_phase_code
            ,l_role
            ,l_approver_sequence
            ,NULL --APPROVAL_STATUS
            ,SYSDATE
            ,l_user_id
            ,SYSDATE
            ,l_user_id
            ,l_user_id
         );
  END IF;

  RETURN l_role;

END Get_Next_Approver_internal;

/**************************
*    Approve_Approval     *
**************************/
/*
     This procedure will update the OM Approval transaction table
     OE_APPROVER_TRANSACTIONS with proper results. Perform a status
     update to INTERNAL_APPROVED.
*/
Procedure Approve_Approval
       (itemtype  in varchar2,
        itemkey   in varchar2,
        actid     in number,
        funcmode  in varchar2,
        resultout in out NOCOPY /* file.sql.39 change */ varchar2)
IS

  l_transaction_id            NUMBER;
  l_sales_document_type_code  VARCHAR2(30);
  l_return_status             VARCHAR2(30);
  l_debug_level CONSTANT      NUMBER := oe_debug_pub.g_debug_level;

BEGIN

  --
  -- RUN mode - normal process execution
  --
  if (funcmode = 'RUN') then

    l_transaction_id     := to_number(itemkey);

    IF itemtype = OE_GLOBALS.G_WFI_NGO THEN
      l_sales_document_type_code := wf_engine.GetItemAttrText(
                                OE_GLOBALS.G_WFI_NGO,
                                l_transaction_id,
                                'SALES_DOCUMENT_TYPE_CODE');
    END IF;

    OE_STANDARD_WF.Set_Msg_Context(actid);
        OE_MSG_PUB.set_msg_context(
           p_entity_code           => 'HEADER'
          ,p_entity_id                  => to_number(itemkey)
          ,p_header_id                    => to_number(itemkey));

    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('Approve_Approval.. ', 1) ;
    END IF;

    OE_ORDER_WF_UTIL.Update_Flow_Status_Code
                 (p_item_type                 => itemtype,
                  p_header_id                 => l_transaction_id,
                  p_flow_status_code          => 'INTERNAL_APPROVED',
                  p_sales_document_type_code  => l_sales_document_type_code,
                  x_return_status             => l_return_status );

    IF l_debug_level  > 0 THEN
           oe_debug_pub.add('Approve_Approval STATUS FROM Update_Flow_Status_Code: '|| l_return_status );
    END IF;

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            -- start data fix project
            -- OE_STANDARD_WF.Save_Messages;
            -- OE_STANDARD_WF.Clear_Msg_Context;
            -- end data fix project
            --app_exception.raise_exception;
	     --bug7386039

	     resultout := 'DEFERRED:'||to_char(sysdate+(TO_NUMBER(g_defer_min)/1440),wf_engine.date_format);
             return;

    END IF;

    resultout := 'COMPLETE';
    OE_STANDARD_WF.Save_Messages;
    OE_STANDARD_WF.Clear_Msg_Context;
    return;

  end if;


  --
  -- CANCEL mode - activity 'compensation'
  --
  -- This is an event point is called with the effect of the activity must
  -- be undone, for example when a process is reset to an earlier point
  -- due to a loop back.
  --
  if (funcmode = 'CANCEL') then

    -- your cancel code goes here
    null;

    -- no result needed
    resultout := 'COMPLETE';
    return;
  end if;


  --
  -- Other execution modes may be created in the future.  Your
  -- activity will indicate that it does not implement a mode
  -- by returning null
  --
  --  resultout := '';
  --  return;

exception
  when others then
    -- The line below records this function call in the error system
    -- in the case of an exception.
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('Exception in Reject_Approval.. ' ,1) ;
    END IF;
    wf_core.context('OE_APPROVALS_WF', 'Approve_Approval',
                    itemtype, itemkey, to_char(actid), funcmode);
    -- start data fix project
    OE_STANDARD_WF.Add_Error_Activity_Msg(p_actid => actid,
                                          p_itemtype => itemtype,
                                          p_itemkey => itemkey);
    OE_STANDARD_WF.Save_Messages;
    OE_STANDARD_WF.Clear_Msg_Context;
    -- end data fix project
    raise;


END Approve_Approval;


/*************************
*    Approval_Timeout    *
*************************/
/*
     This procedure will determine if to Cotinue or Reject the transaction
     in case the approver has timed out and not responded. It will read the
     system parameter value and determne if to continue or Reject

*/
Procedure Approval_Timeout
       (itemtype  in varchar2,
        itemkey   in varchar2,
        actid     in number,
        funcmode  in varchar2,
        resultout in out NOCOPY /* file.sql.39 change */ varchar2)
IS
  l_next_role                    varchar2(320);
  l_current_approver             varchar2(320);
  l_sales_document_type_code  VARCHAR2(30);
  l_transaction_id        NUMBER;
  l_return_status         VARCHAR2(30);
  l_debug_level CONSTANT  NUMBER := oe_debug_pub.g_debug_level;

BEGIN

  --
  -- RUN mode - normal process execution
  --
  if (funcmode = 'RUN') then

    l_transaction_id     := to_number(itemkey);

    OE_STANDARD_WF.Set_Msg_Context(actid);
        OE_MSG_PUB.set_msg_context(
           p_entity_code           => 'HEADER'
          ,p_entity_id                  => to_number(itemkey)
          ,p_header_id                    => to_number(itemkey));

    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('Approval_Timeout.. ', 1) ;
    END IF;


    IF nvl(OE_SYS_PARAMETERS.value('NO_RESPONSE_FROM_APPROVER'), 'CONTINUE') ='CONTINUE' THEN

       -- If the current approver is the last in the list, then still reject it.
       IF itemtype = OE_GLOBALS.G_WFI_NGO THEN
         l_sales_document_type_code := wf_engine.GetItemAttrText(
                                OE_GLOBALS.G_WFI_NGO,
                                l_transaction_id,
                                'SALES_DOCUMENT_TYPE_CODE');
       END IF;

       -- check_if_last_approver(l_transaction_id,l_sales_document_type_code);
       l_next_role := Get_Next_Approver_internal(
                                      l_transaction_id,
                                      itemtype,
                                      l_sales_document_type_code,
                                      'Y');

       if l_next_role is NULL THEN
          resultout := 'COMPLETE:REJECTED';
          OE_STANDARD_WF.Clear_Msg_Context;
          return;
       else
          resultout := 'COMPLETE:CONTINUE';
          OE_STANDARD_WF.Clear_Msg_Context;
          return;
       end if;

    ELSE
        resultout := 'COMPLETE:REJECTED';
        OE_STANDARD_WF.Clear_Msg_Context;
        return;

    END IF;


        resultout := 'COMPLETE';
        OE_STANDARD_WF.Clear_Msg_Context;
        return;
  end if; -- End for 'RUN' mode

  --
  -- CANCEL mode - activity 'compensation'
  --
  -- This is an event point is called with the effect of the activity must
  -- be undone, for example when a process is reset to an earlier point
  -- due to a loop back.
  --
  if (funcmode = 'CANCEL') then

    -- your cancel code goes here
    null;

    -- no result needed
    resultout := 'COMPLETE';
    return;
  end if;


  --
  -- Other execution modes may be created in the future.  Your
  -- activity will indicate that it does not implement a mode
  -- by returning null
  --
  --  resultout := '';
  --  return;


exception
  when others then
    -- The line below records this function call in the error system
    -- in the case of an exception.
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('Exception in Approval_Timeout.. ' ,1) ;
    END IF;
    wf_core.context('OE_APPROVALS_WF', 'Approval_Timeout',
                    itemtype, itemkey, to_char(actid), funcmode);
    -- start data fix project
    OE_STANDARD_WF.Add_Error_Activity_Msg(p_actid => actid,
                                          p_itemtype => itemtype,
                                          p_itemkey => itemkey);
    OE_STANDARD_WF.Save_Messages;
    OE_STANDARD_WF.Clear_Msg_Context;
    -- end data fix project
    raise;


END Approval_Timeout;




/*************************
*    Reject_Approval     *
*************************/
/*
     This procedure will update the OM Approval transaction table
     OE_APPROVER_TRANSACTIONS with proper results. Perform a status
     update to DRAFT_INTERNAL_REJECTED. And update the column
     DRAFT_SUBMITTED_FLAG to 'N' to the base table.
*/
Procedure Reject_Approval
       (itemtype  in varchar2,
        itemkey   in varchar2,
        actid     in number,
        funcmode  in varchar2,
        resultout in out NOCOPY /* file.sql.39 change */ varchar2)
IS

  l_transaction_id        NUMBER;
  l_return_status         VARCHAR2(30);
  l_debug_level CONSTANT  NUMBER := oe_debug_pub.g_debug_level;

BEGIN

  --
  -- RUN mode - normal process execution
  --
  if (funcmode = 'RUN') then

    l_transaction_id     := to_number(itemkey);

    OE_STANDARD_WF.Set_Msg_Context(actid);
        OE_MSG_PUB.set_msg_context(
           p_entity_code           => 'HEADER'
          ,p_entity_id                  => to_number(itemkey)
          ,p_header_id                    => to_number(itemkey));

    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('Reject_Approval.. ', 1) ;
    END IF;

    BEGIN
      UPDATE OE_APPROVER_TRANSACTIONS
         SET APPROVAL_STATUS = 'REJECTED'
       WHERE TRANSACTION_ID = to_number(itemkey)
         AND APPROVER_SEQUENCE = ( select max(APPROVER_SEQUENCE)
                                     from OE_APPROVER_TRANSACTIONS
                                    where TRANSACTION_ID = to_number(itemkey));
    EXCEPTION
       WHEN NO_DATA_FOUND THEN
           -- In case someone adds an additional approval notification after its approved
           -- and then that notifcations get rejected and transitions to Reject_apprroval
           null;
    END;

    IF itemtype = OE_GLOBALS.G_WFI_NGO THEN
       OE_ORDER_WF_UTIL.Update_Quote_Blanket(
                      p_item_type => OE_GLOBALS.G_WFI_NGO,
                      p_item_key => to_number(itemkey),
                      p_flow_status_code => 'DRAFT_INTERNAL_REJECTED',
                      p_draft_submitted_flag => 'N',
                      x_return_status => l_return_status);
    ELSE
       OE_ORDER_WF_UTIL.Update_flow_status_code(
                      p_item_type => itemtype,
                      p_header_id => to_number(itemkey),
                      p_flow_status_code => 'INTERNAL_REJECTED',
                      x_return_status => l_return_status);
    END IF;

    IF l_debug_level  > 0 THEN
         oe_debug_pub.add('Reject_Approval STATUS FROM Update_Flow_Status_Code: '|| l_return_status );
    END IF;

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            -- start data fix project
            -- OE_STANDARD_WF.Save_Messages;
            -- OE_STANDARD_WF.Clear_Msg_Context;
            -- end data fix project
            --app_exception.raise_exception;
	    --bug7386039
	    resultout := 'DEFERRED:'||to_char(sysdate+(TO_NUMBER(g_defer_min)/1440),wf_engine.date_format);
            return;

    END IF;



        resultout := 'COMPLETE';
        OE_STANDARD_WF.Clear_Msg_Context;
        return;
  end if; -- End for 'RUN' mode

  --
  -- CANCEL mode - activity 'compensation'
  --
  -- This is an event point is called with the effect of the activity must
  -- be undone, for example when a process is reset to an earlier point
  -- due to a loop back.
  --
  if (funcmode = 'CANCEL') then

    -- your cancel code goes here
    null;

    -- no result needed
    resultout := 'COMPLETE';
    return;
  end if;


  --
  -- Other execution modes may be created in the future.  Your
  -- activity will indicate that it does not implement a mode
  -- by returning null
  --
  --  resultout := '';
  --  return;

exception
  when others then
    -- The line below records this function call in the error system
    -- in the case of an exception.
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('Exception in Reject_Approval.. ' ,1) ;
    END IF;
    wf_core.context('OE_APPROVALS_WF', 'Reject_Approval',
                    itemtype, itemkey, to_char(actid), funcmode);
    -- start data fix project
    OE_STANDARD_WF.Add_Error_Activity_Msg(p_actid => actid,
                                          p_itemtype => itemtype,
                                          p_itemkey => itemkey);
    OE_STANDARD_WF.Save_Messages;
    OE_STANDARD_WF.Clear_Msg_Context;
    -- end data fix project
    raise;


END Reject_Approval;



/*************************
*  Get_Current_Approver  *
*************************/
/*
   This API will hit the OE_APPROVER_TRANSACTIONS table to find the
   max(approver_sequence) approver for the given transaction_id and
   retrieve the proper name of the approver. NID will be passed in.
*/
Procedure Get_Current_Approver
        (document_id in varchar2,
         display_type in varchar2,
         document in out NOCOPY /* file.sql.39 change */ varchar2,
         document_type in out NOCOPY /* file.sql.39 change */ varchar2)
IS

 l_role varchar2(320);
 l_approver_sequence        NUMBER;
 l_transaction_id           NUMBER;

  l_list_id           NUMBER;
  l_user_id           NUMBER;
  l_transaction_type_id      NUMBER;
  l_transaction_phase_code   VARCHAR2(30);

 l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;

Begin
  IF l_debug_level  > 0 THEN
    oe_debug_pub.add('Get_Current_Approver.. ' ,1) ;
  END IF;


--  select to_number(ITEM_KEY)
--    into l_transaction_id
--   from wf_item_activity_statuses_v
--   where NOTIFICATION_ID = to_number(document_id);

  --Replaced with
  select to_number(ITEM_KEY)
    into l_transaction_id
   from WF_ITEM_ACTIVITY_STATUSES
   where NOTIFICATION_ID = to_number(document_id);

   l_role := Get_Current_Approver_internal (l_transaction_id);

   IF l_debug_level  > 0 THEN
     oe_debug_pub.add('ItemKey/Current Role' || l_transaction_id || '/'
                                            || l_role,1);
   END IF;


  document := l_role;

end Get_Current_Approver;


/**********************************
*  Get_Current_Approver_internal  *
**********************************/
/*
*/
function Get_Current_Approver_internal(p_transaction_id in NUMBER)
   return varchar2
IS
 l_role varchar2(320);

 l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;

BEGIN

  IF l_debug_level  > 0 THEN
     oe_debug_pub.add('In function Get_Current_Approver_internal....', 1);
  END IF;

  BEGIN
    select role
      into l_role
      from OE_APPROVER_TRANSACTIONS
     where TRANSACTION_ID = p_transaction_id
       and APPROVER_SEQUENCE = ( select max(APPROVER_SEQUENCE)
                                   from OE_APPROVER_TRANSACTIONS
                                  where TRANSACTION_ID = p_transaction_id);

   EXCEPTION
     WHEN NO_DATA_FOUND THEN
       IF l_debug_level  > 0 THEN
         oe_debug_pub.add('No OE_APPROVER_TRANSACTIONS for TransactionID:'
                             || p_transaction_id ,1);
		l_role := null;--	6615403
       END IF;


   END;
   IF l_debug_level  > 0 THEN
     oe_debug_pub.add('ItemKey/Current Role' || p_transaction_id || '/'
                                            || l_role,1);
   END IF;
   RETURN l_role;--	6615403

END Get_Current_Approver_internal;



/****************************
*  Get_Sales_Document_Type  *
****************************/
Procedure Get_Sales_Document_Type (document_id in varchar2,
                                   display_type in varchar2,
                                   document in out NOCOPY /* file.sql.39 change */ varchar2,
                                   document_type in out NOCOPY /* file.sql.39 change */ varchar2)
IS
  l_sales_document_type_code VARCHAR2(30);
  l_sales_document_type_desc VARCHAR2(80);
  l_transaction_id           NUMBER;

  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;

BEGIN
  IF l_debug_level  > 0 THEN
    oe_debug_pub.add('Get_Sales_Document_Type...',1);
  END IF;

--  select to_number(ITEM_KEY)
--    into l_transaction_id
--   from wf_item_activity_statuses_v
--   where NOTIFICATION_ID = to_number(document_id);

  --Replaced with
  select to_number(ITEM_KEY)
    into l_transaction_id
   from WF_ITEM_ACTIVITY_STATUSES
   where NOTIFICATION_ID = to_number(document_id);


  l_sales_document_type_code := wf_engine.GetItemAttrText(
                                 OE_GLOBALS.G_WFI_NGO,
                                  to_char(l_transaction_id),
                                  'SALES_DOCUMENT_TYPE_CODE');

    select meaning
      into l_sales_document_type_desc
      from oe_lookups
     where LOOKUP_TYPE = 'SALES_DOCUMENT_TYPE'
       and LOOKUP_CODE = l_sales_document_type_code;

  IF l_debug_level  > 0 THEN
    oe_debug_pub.add('Sales_Document_Type_Code:' || l_sales_document_type_code,1);
  END IF;

  document := l_sales_document_type_desc;
EXCEPTION
  when no_data_found then
    raise;    -- fill in the details
  when others then
    raise;    -- fill in the details
END Get_Sales_Document_Type;





END OE_APPROVALS_WF;

/
