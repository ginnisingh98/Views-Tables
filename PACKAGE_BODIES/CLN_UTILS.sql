--------------------------------------------------------
--  DDL for Package Body CLN_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CLN_UTILS" AS
/* $Header: CLNUTLB.pls 120.0 2005/05/24 16:21:19 appldev noship $ */
   l_debug_level        NUMBER;
--  Package
--      CLN_UTILS
--
--  Purpose
--      Body of package CLN_UTILS.
--
--
--  History
--      Mar-26-2002     Kodanda Ram         Created
--      Apr-02-2002     Rahul Krishan       Modified
--      Jun-07-2004     Sangeetha           Modified
  -- Name
  --   GET_TRADING_PARTNER
  -- Purpose
  --   This procedure is called just before calling create collaboration to get the
  --   actual trading partner id, from XMLG trading partner id and the returned
  --   value will be passed to create collaboration API.
  -- Arguments
  --
  -- Notes
  --   No specific notes.
  PROCEDURE GET_TRADING_PARTNER(
    p_ecx_tp_id             IN  NUMBER,
    x_return_id             OUT NOCOPY NUMBER )
  IS
        l_error_code            NUMBER;
        l_error_msg             VARCHAR2(255);
        l_msg_data              VARCHAR2(255);
        l_debug_mode            VARCHAR2(255);
  BEGIN
        -- Sets the debug mode to be FILE
        --l_debug_mode :=cln_debug_pub.Set_Debug_Mode('FILE');
        IF (l_Debug_Level <= 2) THEN
                cln_debug_pub.Add('----- Entering CLN_GET_TRADING_PARTNER API -------- ',2);
        END IF;
        x_return_id := -1;
        -- getting the Trading Partner ID
        IF (l_Debug_Level <= 1) THEN
                cln_debug_pub.Add('Before SQL Query : Getting Party ID',1);
        END IF;
        SELECT party_id INTO x_return_id
        FROM ECX_TP_HEADERS
        WHERE tp_header_id = p_ecx_tp_id;
        IF (l_Debug_Level <= 1) THEN
                cln_debug_pub.Add('After SQL Query : Getting Party ID',1);
                cln_debug_pub.Add('------- Exiting CLN_GET_TRADING_PARTNER API ------ ',2);
        END IF;
        -- Exception Handling
        EXCEPTION
                WHEN FND_API.G_EXC_ERROR THEN
                l_error_code    :=SQLCODE;
                l_error_msg     :=SQLERRM;
                l_msg_data      :=l_error_code||' : '||l_error_msg;
                IF (l_Debug_Level <= 1) THEN
                        cln_debug_pub.Add(l_msg_data,4);
                END IF;
                IF (l_Debug_Level <= 2) THEN
                        cln_debug_pub.Add('------- Exiting CLN_GET_TRADING_PARTNER API ------ ',2);
                END IF;
                WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                l_error_code    :=SQLCODE;
                l_error_msg     :=SQLERRM;
                l_msg_data      :=l_error_code||' : '||l_error_msg;
                IF (l_Debug_Level <= 5) THEN
                        cln_debug_pub.Add(l_msg_data,6);
                        cln_debug_pub.Add('------- Exiting CLN_GET_TRADING_PARTNER API ------ ',2);
               END IF;
                WHEN NO_DATA_FOUND THEN
                l_msg_data      :='Invalid Party Id in GET_TRADING_PARTNER';
                IF (l_Debug_Level <= 5) THEN
                        cln_debug_pub.Add(l_msg_data,6);
                        cln_debug_pub.Add('------- Exiting CLN_GET_TRADING_PARTNER API ------ ',2);
                END IF;
                WHEN OTHERS THEN
                l_error_code    :=SQLCODE;
                l_error_msg     :=SQLERRM;
                l_msg_data      :=l_error_code||' : '||l_error_msg;
                IF (l_Debug_Level <= 5) THEN
                        cln_debug_pub.Add(l_msg_data,6);
                        cln_debug_pub.Add('------- Exiting CLN_GET_TRADING_PARTNER API ------ ',2);
                END IF;
  END GET_TRADING_PARTNER;

 PROCEDURE IsDeliveryRequired (p_itemtype       IN VARCHAR2,
                               p_itemkey        IN VARCHAR2,
                               p_actid          IN NUMBER,
                               p_funcmode       IN VARCHAR2,
                               x_resultout      IN OUT NOCOPY VARCHAR2) AS

 -- Start of comments
 --	API name 	: IsDeliveryRequired
 --	Purpose  	: Checks for the Trading Partner setup for the current transaction in the XML Gateway.
 --     Notes           : This API is called from the Outbound Generic workflow .
 -- End of comments

 -- declare local variables
   l_transaction_type    VARCHAR2(100);
   l_transaction_subtype VARCHAR2(100);
   l_party_id            NUMBER(10);
   l_party_site_id       NUMBER(10);
   l_party_type          VARCHAR2(10);
   l_result              BOOLEAN;
   l_return_code         PLS_INTEGER;
   l_errmsg              VARCHAR2(2000);
   l_error_code          VARCHAR2(30);

  BEGIN

   IF (l_Debug_Level <= 2) THEN
        cln_debug_pub.Add('Entering the procedure CLNUTILS.IsDeliveryRequired', 2);
   END IF;

  --  get the workflow activity attributes.

   l_transaction_type:=wf_engine.GetActivityAttrText(p_itemtype,p_itemkey,p_actid,'ECX_TRANSACTION_TYPE');
   IF (l_Debug_Level <= 1) THEN
        cln_debug_pub.Add('Transaction type:'|| l_transaction_type , 1);
   END IF;

   l_transaction_subtype:=wf_engine.GetActivityAttrText(p_itemtype,p_itemkey,p_actid,'ECX_TRANSACTION_SUBTYPE');
   IF (l_Debug_Level <= 1) THEN
        cln_debug_pub.Add('Transaction Subtype:'|| l_transaction_subtype , 1);
   END IF;

   l_party_id:=wf_engine.GetActivityAttrText(p_itemtype,p_itemkey,p_actid,'ECX_PARTY_ID');
   IF (l_Debug_Level <= 1) THEN
        cln_debug_pub.Add('Party ID:'|| l_party_id , 1);
   END IF;

   l_party_site_id:=wf_engine.GetActivityAttrText(p_itemtype,p_itemkey,p_actid,'ECX_PARTY_SITE_ID');
   IF (l_Debug_Level <= 1) THEN
        cln_debug_pub.Add('Party Site ID:'|| l_party_site_id , 1);
   END IF;

   l_party_type:=wf_engine.GetActivityAttrText(p_itemtype,p_itemkey,p_actid,'ECX_PARTY_TYPE');
   IF (l_Debug_Level <= 1) THEN
        cln_debug_pub.Add('Party Type:'|| l_party_type , 1);
   END IF;

  -- call the 'ecx_document.isDeliveryRequired' API which validates the Trading Partner setup.

   BEGIN
   ecx_document.isDeliveryRequired(transaction_type       => l_transaction_type,
	                           transaction_subtype    => l_transaction_subtype,
	                           party_id	          => l_party_id,
	                           party_type             => l_party_type,
	                           party_site_id	  => l_party_site_id,
	                           resultout	          => l_result,
	                           retcode		  => l_return_code,
	                           errmsg		  => l_errmsg);
   EXCEPTION
          WHEN OTHERS THEN
              l_error_code := SQLCODE;
              l_errmsg     := SQLERRM;

    	      IF (l_Debug_Level <= 5) THEN
	           cln_debug_pub.Add('Exception in CLNUTILS.IsDeliveryRequired' || ':'  || l_error_code || ':' ||                                l_errmsg,5);
              END IF;
          END;

   -- If the variable 'l_result' is 'TRUE' then , there exists a setup for this transaction's Trading
   -- Partner. Else there is no valid Trading Partner setup exists for this Transaction.

   IF (l_Debug_Level <= 1) THEN
         cln_debug_pub.Add('Result out:'|| l_errmsg , 1);
   END IF;

   IF (l_result = TRUE) THEN
        x_resultout:='Y';
        IF (l_Debug_Level <= 1) THEN
             cln_debug_pub.Add('Trading Partner Setup found' , 1);
        END IF;
   ELSE
        x_resultout:='N';
        IF (l_Debug_Level <= 1) THEN
             cln_debug_pub.Add('Trading Partner Setup NOT found' , 1);
        END IF;
   END IF;

   IF (l_Debug_Level <= 2) THEN
        cln_debug_pub.Add('Exititng the procedure CLN_UTILS.IsDeliveryRequired', 2);
   END IF;

 END IsDeliveryRequired;

 BEGIN
   l_debug_level := to_number(nvl(fnd_profile.value('CLN_DEBUG_LEVEL'), '5'));

END CLN_UTILS;


/
