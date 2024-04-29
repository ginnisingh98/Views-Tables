--------------------------------------------------------
--  DDL for Package Body CLN_PO_CHANGE_RESPONSE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CLN_PO_CHANGE_RESPONSE_PKG" AS
/* $Header: CLNPOCHB.pls 115.6 2004/04/08 16:25:12 kkram noship $ */
   l_debug_level        NUMBER := to_number(nvl(fnd_profile.value('CLN_DEBUG_LEVEL'), '5'));

--  Package
--      CLN_RESPONSE_POCHANGE_PKG
--
--  Purpose
--      Body of package CLN_RESPONSE_POCHANGE_PKG.
--
--  History
--      June-17-2003  Rahul Krishan         Created



   -- Name
   --   SET_ATTRIBUTES_OF_WORKFLOW
   -- Purpose
   --   The main purpose ofthis API is to set different attributes based
   --   on the change request group id passed to it through workflow.
   -- Arguments
   --
   -- Notes
   --   No specific notes.

   PROCEDURE SET_ATTRIBUTES_OF_WORKFLOW(
        p_itemtype                      IN VARCHAR2,
        p_itemkey                       IN VARCHAR2,
        p_actid                         IN NUMBER,
        p_funcmode                      IN VARCHAR2,
        x_resultout                     IN OUT NOCOPY VARCHAR2 )
   IS
        l_so_number                     VARCHAR2(30);
        l_header_id                     NUMBER;
        l_revision_num                  NUMBER;
        l_release_id                    NUMBER;
        l_header_status                 VARCHAR2(30);
        l_consolidated_line_status      VARCHAR2(30);
        l_header_response_reason        VARCHAR2(30);
        l_document_num                  VARCHAR2(20);
        l_change_request_group_id       NUMBER;
        l_header_ack_code               NUMBER;
        l_debug_mode                    VARCHAR2(255);
        l_error_code                    NUMBER;
        l_error_msg                     VARCHAR2(1000);
        l_msg_data                      VARCHAR2(1000);
        l_party_id                      NUMBER;
        l_party_site_id                 NUMBER;
        l_xmlg_document_id              VARCHAR2(255);
        l_event_key                     NUMBER;


   BEGIN
        -- Sets the debug mode to FILE
        --l_debug_mode := cln_debug_pub.Set_Debug_Mode('FILE');

        IF (l_Debug_Level <= 2) THEN
                cln_debug_pub.Add('******************************************************',2);
                cln_debug_pub.Add('----- Entering SET_ATTRIBUTES_OF_WORKFLOW API ------- ',2);
                cln_debug_pub.Add('******************************************************',2);
        END IF;


        -- Initialize API return status to success
        l_msg_data := 'All the item attributes were defaulted Successfully';

        IF (l_Debug_Level <= 1) THEN
                cln_debug_pub.Add('Getting change request group ID from the workflow......',1);
        END IF;

        l_change_request_group_id := TO_NUMBER(wf_engine.GetActivityAttrText(p_itemtype, p_itemkey, p_actid, 'CHANGE_REQUEST_GP_ID'));
        IF (l_Debug_Level <= 1) THEN
                cln_debug_pub.Add('Change Request Group ID    : ' || l_change_request_group_id, 1);

                cln_debug_pub.Add('Querying the PO_CHANGE_REQUESTS table.....',1);
        END IF;

        BEGIN
                SELECT max(new_supplier_order_number), max(document_header_id),
                       max(document_revision_num), max(po_release_id),
                       max(decode(request_level,'HEADER',request_status,null)), min(request_status),
                       max(decode(request_level,'HEADER',response_reason,null)),max(document_num)
                INTO   l_so_number, l_header_id,
                       l_revision_num, l_release_id,
                       l_header_status, l_consolidated_line_status,
                       l_header_response_reason,l_document_num
                FROM   po_change_requests
                WHERE  change_request_group_id = l_change_request_group_id;

                -- Get the revision number
                IF l_release_id is not null and l_release_id > 0 THEN
                   select revision_num into l_revision_num from po_releases_all where po_release_id = l_release_id;
                ELSE
                   select revision_num into l_revision_num from po_headers_all where po_header_id = l_header_id;
                END IF;


        EXCEPTION
                WHEN NO_DATA_FOUND THEN
                   l_msg_data := 'No data found in the po_change_requests table for the specified Change_Request_Group_ID  ='||l_change_request_group_id;
                   IF (l_Debug_Level <= 1) THEN
                           cln_debug_pub.Add(l_msg_data,1);
                   END IF;

                   RAISE FND_API.G_EXC_ERROR;
        END;

        IF (l_Debug_Level <= 1) THEN
                cln_debug_pub.Add('=========== FROM THE PO_CHANGE_REQUESTS TABLE =================== ',1);
                cln_debug_pub.Add('Supplier Order Number              - '||l_so_number,1);
                cln_debug_pub.Add('PO Header ID                       - '||l_header_id,1);
                cln_debug_pub.Add('Revision Number                    - '||l_revision_num,1);
                cln_debug_pub.Add('Release ID                         - '||l_release_id,1);
                cln_debug_pub.Add('Header Status                      - '||l_header_status,1);
                cln_debug_pub.Add('Consolidated Line Status           - '||l_consolidated_line_status,1);
                cln_debug_pub.Add('Header Response Reason             - '||l_header_response_reason,1);
                cln_debug_pub.Add('Document Number                    - '||l_document_num,1);
                cln_debug_pub.Add('==================================================================',1);

                cln_debug_pub.Add('Querying the Vendor Details.....',1);
        END IF;

        BEGIN
                SELECT VENDOR_ID, VENDOR_SITE_ID
                INTO   l_party_id, l_party_site_id
                FROM   PO_HEADERS_ALL
                WHERE  PO_HEADER_ID = l_header_id;
        EXCEPTION
                WHEN NO_DATA_FOUND THEN
                   l_msg_data := 'Trading Partner Details not found for PO Header ID ='||l_header_id;
                   IF (l_Debug_Level <= 1) THEN
                           cln_debug_pub.Add(l_msg_data,1);
                   END IF;

                   RAISE FND_API.G_EXC_ERROR;
        END;

        IF (l_Debug_Level <= 1) THEN
                cln_debug_pub.Add('======== FROM THE PO_HEADERS_ALL TABLE ======== ',1);
                cln_debug_pub.Add('Trading Partner ID                 - '||l_party_id,1);
                cln_debug_pub.Add('Trading Partner site ID            - '||l_party_site_id,1);
                cln_debug_pub.Add('================================================ ',1);
        END IF;



        -- if no header exists, place the consolidated line status at header level
        l_header_status := NVL(l_header_status,l_consolidated_line_status);
        IF (l_Debug_Level <= 1) THEN
                cln_debug_pub.Add('Header Status                      - '||l_header_status,1);
        END IF;


        IF (l_Debug_Level <= 1) THEN
                cln_debug_pub.Add('Defaulting XMLG Document ID with a running sequence',1);
        END IF;

        SELECT  cln_generic_s.nextval INTO l_xmlg_document_id FROM dual;


        IF (l_Debug_Level <= 1) THEN
                cln_debug_pub.Add('Setting the value for ACKCODE at header level  - ',1);
        END IF;

        IF( l_header_status = 'ACCEPTED') THEN
            l_header_ack_code := 0;
        ELSIF (l_header_status = 'REJECTED') THEN
            l_header_ack_code := 2;
        ELSE
            IF (l_Debug_Level <= 1) THEN
                    cln_debug_pub.Add('Improper status value for the Header ',1);
            END IF;

            RAISE FND_API.G_EXC_ERROR;
        END IF;
        IF (l_Debug_Level <= 1) THEN
                cln_debug_pub.Add('ACKCODE at header level is '||l_header_ack_code,1);
        END IF;


        IF (l_Debug_Level <= 1) THEN
                cln_debug_pub.Add('Setting Event Key....',1);
        END IF;

        SELECT  cln_generic_s.nextval INTO l_event_key FROM dual;
        IF (l_Debug_Level <= 1) THEN
                cln_debug_pub.Add('Event Key  set as                   - '||l_event_key,1);
        END IF;


        g_change_request_group_id := l_change_request_group_id;

        IF (l_Debug_Level <= 1) THEN
                cln_debug_pub.Add('---------- SETTING WORKFLOW PARAMETERS---------', 1);
        END IF;

        wf_engine.SetItemAttrText(p_itemtype, p_itemkey, 'TRADING_PARTNER_TYPE', 'S');
        wf_engine.SetItemAttrText(p_itemtype, p_itemkey, 'TRADING_PARTNER_ID', l_party_id);
        wf_engine.SetItemAttrText(p_itemtype, p_itemkey, 'TRADING_PARTNER_SITE', l_party_site_id);

        wf_engine.SetItemAttrText(p_itemtype, p_itemkey, 'PO_HEADER_ID',l_header_id);
        wf_engine.SetItemAttrText(p_itemtype, p_itemkey, 'PO_RELEASE_ID',l_release_id);
        wf_engine.SetItemAttrText(p_itemtype, p_itemkey, 'PO_REVISION_NUM',l_revision_num);
        wf_engine.SetItemAttrText(p_itemtype, p_itemkey, 'SO_NUMBER',l_so_number);

        wf_engine.SetItemAttrText(p_itemtype, p_itemkey, 'DOCUMENT_NO',l_document_num );
        wf_engine.SetItemAttrText(p_itemtype, p_itemkey, 'XMLG_INTERNAL_TXN_TYPE','CLN');
        wf_engine.SetItemAttrText(p_itemtype, p_itemkey, 'XMLG_INTERNAL_TXN_SUBTYPE','CHANGE_PO_RESPONSE');
        wf_engine.SetItemAttrText(p_itemtype, p_itemkey, 'DOCUMENT_DIRECTION', 'OUT');
        wf_engine.SetItemAttrText(p_itemtype, p_itemkey, 'XMLG_DOCUMENT_ID',l_xmlg_document_id);
        wf_engine.SetItemAttrText(p_itemtype, p_itemkey, 'HEADER_ACKCODE', l_header_ack_code);
        wf_engine.SetItemAttrText(p_itemtype, p_itemkey, 'HEADER_RESPONSE_REASON', l_header_response_reason);
        wf_engine.SetItemAttrText(p_itemtype, p_itemkey, 'EVENT_KEY', l_event_key);

        x_resultout:='Yes';

        -- check the error message
        IF (l_Debug_Level <= 1) THEN
                cln_debug_pub.Add(l_msg_data,1);
        END IF;

        IF (l_Debug_Level <= 2) THEN
                cln_debug_pub.Add('******************************************************',2);
                cln_debug_pub.Add('------- Exiting SET_ATTRIBUTES_OF_WORKFLOW API ------ ',2);
                cln_debug_pub.Add('******************************************************',2);
        END IF;


 -- Exception Handling
 EXCEPTION

      WHEN FND_API.G_EXC_ERROR THEN
             IF (l_Debug_Level <= 5) THEN
                     cln_debug_pub.Add(l_msg_data,4);
                     cln_debug_pub.Add('------- Exiting SET_ATTRIBUTES_OF_WORKFLOW API --------- ',2);
             END IF;


        WHEN OTHERS THEN
             l_error_code       :=SQLCODE;
             l_error_msg        :=SQLERRM;
             FND_MESSAGE.SET_NAME('CLN','CLN_CH_UNEXPECTED_ERROR');
             FND_MESSAGE.SET_TOKEN('ERRORCODE',l_error_code);
             FND_MESSAGE.SET_TOKEN('ERRORMSG',l_error_msg);
             l_msg_data         :='Unexpected Error  -'||l_error_code||' : '||l_error_msg;
             IF (l_Debug_Level <= 5) THEN
                     cln_debug_pub.Add(l_msg_data,6);
                     cln_debug_pub.Add('------- Exiting SET_ATTRIBUTES_OF_WORKFLOW API --------- ',2);
             END IF;


 END SET_ATTRIBUTES_OF_WORKFLOW;


 -- Function
 --   GET_CHANGE_REQUEST_GROUP_ID
 -- Description
 --   Returns the value of Change Request Group ID which can be used in view at runtime.
 -- Return Value
 --   Returns the value of Change Request Group ID.


 FUNCTION GET_CHANGE_REQUEST_GROUP_ID
 RETURN NUMBER IS
 BEGIN
    RETURN g_change_request_group_id;
 END;


  -- Name
  --   SET_REQUEST_GRP_ID_AND_COLL_ID
  -- Description
  --   Sets the value of Change Request Group ID which can be used in view at runtime.
  -- Return Value
  --

  PROCEDURE SET_REQUEST_GRP_ID_AND_COLL_ID(
        p_itemtype                      IN VARCHAR2,
        p_itemkey                       IN VARCHAR2,
        p_actid                         IN NUMBER,
        p_funcmode                      IN VARCHAR2,
        x_resultout                     IN OUT NOCOPY VARCHAR2 )
  IS
        l_change_request_group_id       NUMBER;
        l_debug_mode                    VARCHAR2(255);
        l_coll_id                       NUMBER;
        l_po_header_id                  NUMBER;
        l_po_release_id                 NUMBER;
        l_xmlg_int_control_num          NUMBER;
        l_error_code                    NUMBER;
        l_error_msg                     VARCHAR2(1000);
        l_msg_data                      VARCHAR2(1000);

  BEGIN
        -- Sets the debug mode to FILE
        --l_debug_mode := cln_debug_pub.Set_Debug_Mode('FILE');

        IF (l_Debug_Level <= 2) THEN
                cln_debug_pub.Add('******************************************************',2);
                cln_debug_pub.Add('----- Entering SET_REQUEST_GRP_ID_AND_COLL_ID API ------- ',2);
                cln_debug_pub.Add('******************************************************',2);
        END IF;


        IF (l_Debug_Level <= 1) THEN
                cln_debug_pub.Add('Getting change request group ID from the workflow......',1);
        END IF;

        l_change_request_group_id := TO_NUMBER(wf_engine.GetActivityAttrText(p_itemtype, p_itemkey, p_actid, 'CHANGE_REQUEST_GP_ID'));

        IF (l_Debug_Level <= 1) THEN
                cln_debug_pub.Add('Change Request Group ID    : ' || l_change_request_group_id, 1);
        END IF;

        g_change_request_group_id := l_change_request_group_id;

        l_xmlg_int_control_num := null;
        BEGIN
           SELECT max(msg_cont_num)
           INTO l_xmlg_int_control_num
           FROM po_change_requests
           WHERE change_request_group_id = l_change_request_group_id;

           IF (l_Debug_Level <= 1) THEN
                cln_debug_pub.Add('Internal Control Number got as    : ' || l_xmlg_int_control_num);
           END IF;

           SELECT max(ch.collaboration_id)
           INTO l_coll_id
           FROM cln_coll_hist_hdr ch, cln_coll_hist_dtl cd
           WHERE ch.collaboration_id = cd.collaboration_id
             AND cd.xmlg_internal_control_number = l_xmlg_int_control_num
             AND ch.collaboration_type = 'SUPP_CHANGE_ORDER';

           IF (l_Debug_Level <= 1) THEN
                cln_debug_pub.Add('Collaboration ID got as    : ' || l_coll_id, 1);
           END IF;

           wf_engine.SetItemAttrText(p_itemtype, p_itemkey, 'COLLABORATION_ID',l_coll_id);


        EXCEPTION
          WHEN OTHERS THEN
             IF (l_Debug_Level <= 1) THEN
                cln_debug_pub.Add('Error: Went into when others while querying collaboration id',1);
            END IF;
        END;


        IF l_coll_id is null THEN
           x_resultout:='N';
        ELSE
           x_resultout:='Y';
        END IF;



        IF (l_Debug_Level <= 2) THEN
                cln_debug_pub.Add('******************************************************',2);
                cln_debug_pub.Add('----- Exiting SET_REQUEST_GRP_ID_AND_COLL_ID API ------- ',2);
                cln_debug_pub.Add('******************************************************',2);
        END IF;

  EXCEPTION
    WHEN OTHERS THEN
             x_resultout:='N';
             l_error_code       :=SQLCODE;
             l_error_msg        :=SQLERRM;
             l_msg_data         :='Unexpected Error  -'||l_error_code||' : '||l_error_msg;
             IF (l_Debug_Level <= 5) THEN
                     cln_debug_pub.Add(l_msg_data,6);
                     cln_debug_pub.Add('------- Exiting SET_REQUEST_GRP_ID_AND_COLL_ID API --------- ',2);
             END IF;


  END SET_REQUEST_GRP_ID_AND_COLL_ID;

  -- Name
  --   SET_ACKCODE_CONDITIONALLY
  -- Description
  --   return. x_ackcode based on the two reasons passed
  -- Return Value
  --
  PROCEDURE CALC_ACKCODE_CONDITIONALLY(
        p_reason                        IN VARCHAR2,
        p_cons_reason                   IN VARCHAR2,
        x_ackcode                       IN OUT NOCOPY VARCHAR2 )
  IS
        l_reason                        VARCHAR2(100);
        l_debug_mode                    VARCHAR2(255);
        BEGIN
        -- Sets the debug mode to FILE
        --l_debug_mode := cln_debug_pub.Set_Debug_Mode('FILE');

        IF (l_Debug_Level <= 2) THEN
                cln_debug_pub.Add('******************************************************',2);
                cln_debug_pub.Add('----- Entering CALC_ACKCODE_CONDITIONALLY API ------- ',2);
                cln_debug_pub.Add('******************************************************',2);
        END IF;

        IF (l_Debug_Level <= 1) THEN
                cln_debug_pub.Add('p_reason      : ' || p_reason,1);
                cln_debug_pub.Add('p_cons_reason : ' || p_cons_reason,1);
        END IF;

        l_reason := p_reason;
        IF (l_reason is null or l_reason ='') THEN
          l_reason := p_cons_reason;
          IF (l_Debug_Level <= 1) THEN
                  cln_debug_pub.Add('Condidering the CONS reason as l_reason is blank',1);
          END IF;

        END IF;

        x_ackcode := 2;
        IF (l_reason = 'ACCEPTED') THEN
          x_ackcode := 0;
        END IF;

        IF (l_Debug_Level <= 2) THEN
                cln_debug_pub.Add('******************************************************',2);
                cln_debug_pub.Add('----- Exiting CALC_ACKCODE_CONDITIONALLY API ------- ',2);
                cln_debug_pub.Add('******************************************************',2);
        END IF;


  END CALC_ACKCODE_CONDITIONALLY;


  -- Name
  --   GET_ADDITIONAL_DATA
  -- Description
  --   This procedure should be used to obtain data
  --   that is otherwise not possible to get from element mapping
  --   in a XML Gateway message map
  -- Return
  --   x_data1: Supplier Document Reference
  --   x_data2: For future use
  --   x_data3: For future use
  --   x_data4: For future use
  --   x_data5: For future use

  PROCEDURE GET_ADDITIONAL_DATA(
        P_CHANGE_REQUEST_GROUP_ID       IN VARCHAR2,
        X_DATA1                         IN OUT NOCOPY VARCHAR2,
        X_DATA2                         IN OUT NOCOPY VARCHAR2,
        X_DATA3                         IN OUT NOCOPY VARCHAR2,
        X_DATA4                         IN OUT NOCOPY VARCHAR2,
        X_DATA5                         IN OUT NOCOPY VARCHAR2)
  IS
        l_reason                        VARCHAR2(100);
        l_debug_mode                    VARCHAR2(255);
        l_error_code                    NUMBER;
        l_error_msg                     VARCHAR2(2000);
        l_error_status                  VARCHAR2(2100);
        BEGIN
        -- Sets the debug mode to FILE
        --l_debug_mode := cln_debug_pub.Set_Debug_Mode('FILE');

        IF (l_Debug_Level <= 2) THEN
                cln_debug_pub.Add('******************************************************',2);
                cln_debug_pub.Add('----- Entering GET_ADDITIONAL_DATA API ------- ',2);
                cln_debug_pub.Add('******************************************************',2);
        END IF;

        IF (l_Debug_Level <= 1) THEN
                cln_debug_pub.Add('P_CHANGE_REQUEST_GROUP_ID      : ' || P_CHANGE_REQUEST_GROUP_ID,1);
        END IF;

        BEGIN
           SELECT max(SUPPLIER_DOC_REF) -- to compile this code in 11.5.9 env use RESPONSE_REASON
           INTO   X_DATA1
           FROM   PO_CHANGE_REQUESTS
           WHERE  CHANGE_REQUEST_GROUP_ID = to_number(P_CHANGE_REQUEST_GROUP_ID);
        EXCEPTION
           WHEN OTHERS THEN
               l_error_code    := SQLCODE;
               l_error_msg     := SQLERRM;
               l_error_status  := l_error_code || ' : ' || l_error_msg;
               IF (l_Debug_Level <= 5) THEN
                  cln_debug_pub.Add('Exception raised:', 5);
                  cln_debug_pub.Add(l_error_status, 5);
               END IF;
           X_DATA1 := NULL;
        END;

        IF (l_Debug_Level <= 1) THEN
                cln_debug_pub.Add('X_DATA1 : ' || X_DATA1 ,1);
        END IF;

        IF (l_Debug_Level <= 2) THEN
                cln_debug_pub.Add('******************************************************',2);
                cln_debug_pub.Add('----- Exiting GET_ADDITIONAL_DATA API ------- ',2);
                cln_debug_pub.Add('******************************************************',2);
        END IF;
  END GET_ADDITIONAL_DATA;


END CLN_PO_CHANGE_RESPONSE_PKG;

/
