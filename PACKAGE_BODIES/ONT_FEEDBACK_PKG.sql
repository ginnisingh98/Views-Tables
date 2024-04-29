--------------------------------------------------------
--  DDL for Package Body ONT_FEEDBACK_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ONT_FEEDBACK_PKG" AS
/* $Header: ONTWFCB.pls 120.1 2006/04/26 18:07:13 chhung noship $*/

   PROCEDURE init_wf(p_recipient IN VARCHAR2,
                     p_name     IN VARCHAR2,
                     p_email    IN VARCHAR2,
                     p_comments IN VARCHAR2,
                     p_feedback IN VARCHAR2,
                     p_phone    IN VARCHAR2)    IS

      l_itemtype      WF_ITEMS.ITEM_TYPE%TYPE :=  'ONTCUSTF';
      l_itemkey       WF_ITEMS.ITEM_KEY%TYPE;
      l_WorkflowProcess   VARCHAR2(30) := 'ONT_CUST_FEEDBACK';
      l_display_name VARCHAR2(240);
      l_Email_address VARCHAR2(240);
      l_Notification_preference VARCHAR2(240);
      l_Language VARCHAR2(240);
      l_territory VARCHAR2(240);
      /* Save the Threshold Value*/
      l_save_threshold  CONSTANT WF_ENGINE.THRESHOLD%TYPE :=WF_ENGINE.THRESHOLD;
     BEGIN
            /* Get the Item Key from Sequence */
            SELECT OE_WF_FEEDBACK_S.nextval into l_itemkey from DUAL;

       	/* create the process */

      	WF_ENGINE.CREATEPROCESS (itemtype => l_itemtype,
                                     itemkey =>  l_itemkey,
                                     process =>  l_WorkflowProcess);

      	/* make sure that process runs in defer mode */
      	WF_ENGINE.THRESHOLD := -1;

      /*Set All Workflow Attributes with Parameter Values */

      WF_ENGINE.SETITEMATTRTEXT(  itemtype => l_itemtype,
                                  itemkey => l_itemkey,
         			  aname => 'CUSTF_RECIPIENT',
         	                      avalue => p_recipient);

      /* Get Notifier Name */
      WF_DIRECTORY.GetRoleInfo(p_recipient,
                               l_Display_name,
                               l_Email_address,
                               l_Notification_preference,
                               l_Language,
                               L_Territory);
      /* Set Workflow Attributes */

      WF_ENGINE.SETITEMATTRTEXT(  itemtype => l_itemtype,
                                  itemkey => l_itemkey,
         			          aname => 'CUSTF_RECIPIENT_NAME',
         	                      avalue => l_display_name);

      WF_ENGINE.SETITEMATTRTEXT(  itemtype => l_itemtype,
                                  itemkey => l_itemkey,
         			          aname => 'CUSTF_NAME',
         	                      avalue => p_name);

      WF_ENGINE.SETITEMATTRTEXT(  itemtype => l_itemtype,
                                  itemkey => l_itemkey,
         			          aname => 'CUSTF_EMAIL',
         	                      avalue => p_email);

      WF_ENGINE.SETITEMATTRTEXT(  itemtype => l_itemtype,
                                  itemkey => l_itemkey,
         			          aname => 'CUSTF_COMMENTS',
         	                      avalue => p_comments);


     	WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,
                                  itemkey => l_itemkey,
         			          aname => 'CUSTF_FEEDBACK',
         	                      avalue => p_feedback);

	WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,
                                  itemkey => l_itemkey,
         			          aname => 'CUSTF_PHONE',
         	                      avalue => p_phone);

      	/* start the Workflow process */

      	WF_ENGINE.STARTPROCESS (itemtype => l_itemtype,
                                itemkey => l_itemkey);

        /* Reset The Threshold Value */
        WF_ENGINE.THRESHOLD := l_save_threshold;


  EXCEPTION
      WHEN OTHERS THEN
          /* Reset The Threshold Value */
        WF_ENGINE.THRESHOLD := l_save_threshold;
         WF_CORE.CONTEXT ('ONT_FEEBBACK_PKG','INIT_WF',l_itemtype,l_itemkey,'Recipient-'||P_RECIPIENT,'Customer-'||P_NAME);
         raise;
  END init_wf;


   /* PROCEDURE: init_wf2
    * --------------------------------------
    * It is called in $ont/java/custservice/webui/ReportDefectFormCO.java
    * for starting workflow process DEFECTPROC to send out notification
    */

   PROCEDURE init_wf2(p_recipient IN VARCHAR2,
                     p_name     IN VARCHAR2,
                     p_email    IN VARCHAR2,
                     p_comments IN VARCHAR2,
                     p_phone    IN VARCHAR2,
                     p_ordernum IN VARCHAR2,
                     p_shipnum  IN VARCHAR2,
                     p_lot      IN VARCHAR2,
                     p_products IN VARCHAR2,
                     p_shipdate IN VARCHAR2)     IS

      l_itemtype      WF_ITEMS.ITEM_TYPE%TYPE :=  'ONTDEFCT';
      l_itemkey       WF_ITEMS.ITEM_KEY%TYPE;
      l_WorkflowProcess   VARCHAR2(30) := 'DEFECTPROC';
      l_display_name VARCHAR2(240);
      l_Email_address VARCHAR2(240);
      l_Notification_preference VARCHAR2(240);
      l_Language VARCHAR2(240);
      l_territory VARCHAR2(240);
      /* Save the Threshold Value*/
      l_save_threshold  CONSTANT WF_ENGINE.THRESHOLD%TYPE :=WF_ENGINE.THRESHOLD;
     BEGIN
            /* Get the Item Key from Sequence */
            SELECT OE_WF_FEEDBACK_S.nextval into l_itemkey from DUAL;

       	/* create the process */

      	WF_ENGINE.CREATEPROCESS (itemtype => l_itemtype,
                                     itemkey =>  l_itemkey,
                                     process =>  l_WorkflowProcess);

      	/* make sure that process runs in defer mode */
      	WF_ENGINE.THRESHOLD := -1;

      /*Set All Workflow Attributes with Parameter Values */

      WF_ENGINE.SETITEMATTRTEXT(  itemtype => l_itemtype,
                                  itemkey => l_itemkey,
         			  aname => 'NOTIFIER',
         	                      avalue => p_recipient);

      /* Get Notifier Name */
      WF_DIRECTORY.GetRoleInfo(p_recipient,
                               l_Display_name,
                               l_Email_address,
                               l_Notification_preference,
                               l_Language,
                               L_Territory);
      /* Set Workflow Attributes */


      WF_ENGINE.SETITEMATTRTEXT(  itemtype => l_itemtype,
                                  itemkey => l_itemkey,
         			          aname => 'NAME',
         	                      avalue => p_name);

      WF_ENGINE.SETITEMATTRTEXT(  itemtype => l_itemtype,
                                  itemkey => l_itemkey,
         			          aname => 'EMAIL',
         	                      avalue => p_email);

      WF_ENGINE.SETITEMATTRTEXT(  itemtype => l_itemtype,
                                  itemkey => l_itemkey,
         			          aname => 'COMMENTS',
         	                      avalue => p_comments);


	WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,
                                  itemkey => l_itemkey,
         			          aname => 'PHONE',
         	                      avalue => p_phone);

     	WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,
                                  itemkey => l_itemkey,
         			          aname => 'ORDERNUM',
         	                      avalue => p_ordernum);

     	WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,
                                  itemkey => l_itemkey,
         			          aname => 'SHIPNUM',
         	                      avalue => p_shipnum);

     	WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,
                                  itemkey => l_itemkey,
         			          aname => 'ITEM',
         	                      avalue => p_products);


     	WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,
                                  itemkey => l_itemkey,
         			          aname => 'LOTNUM',
         	                      avalue => p_lot);

     	WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,
                                  itemkey => l_itemkey,
         			          aname => 'SHIPDATE',
         	                      avalue => p_shipdate);


      	/* start the Workflow process */

      	WF_ENGINE.STARTPROCESS (itemtype => l_itemtype,
                                itemkey => l_itemkey);

        /* Reset The Threshold Value */
        WF_ENGINE.THRESHOLD := l_save_threshold;


  EXCEPTION
      WHEN OTHERS THEN
          /* Reset The Threshold Value */
        WF_ENGINE.THRESHOLD := l_save_threshold;
         WF_CORE.CONTEXT ('ONT_FEEBBACK_PKG','INIT_WF2',l_itemtype,l_itemkey,'Recipient-'||P_RECIPIENT,'Customer-'||P_NAME);
         raise;
  END init_wf2;


   /* PROCEDURE: init_wf3
    * -----------------------------------------
    * It is called in $ont/java/custservice/webui/FeedbackFormCO.java
    * for starting workflow process ONT_CUST_FEEDBACK to send out notification
    */

   PROCEDURE init_wf3(p_notifier IN VARCHAR2,
                     p_name     IN VARCHAR2,
                     p_email    IN VARCHAR2,
                     p_comments IN VARCHAR2,
                     p_ordernum IN VARCHAR2,
                     p_linenum  IN VARCHAR2,
                     p_quantity IN VARCHAR2,
                     p_products IN VARCHAR2,
                     p_phone    IN VARCHAR2)     IS

      l_itemtype      WF_ITEMS.ITEM_TYPE%TYPE :=  'ONTCUSTF';
      l_itemkey       WF_ITEMS.ITEM_KEY%TYPE;
      l_WorkflowProcess   VARCHAR2(30) := 'ONT_CUST_FEEDBACK';
      l_display_name VARCHAR2(240);
      l_Email_address VARCHAR2(240);
      l_Notification_preference VARCHAR2(240);
      l_Language VARCHAR2(240);
      l_territory VARCHAR2(240);
      /* Save the Threshold Value*/
      l_save_threshold  CONSTANT WF_ENGINE.THRESHOLD%TYPE :=WF_ENGINE.THRESHOLD;

     BEGIN
            /* Get the Item Key from Sequence */
            SELECT OE_WF_FEEDBACK_S.nextval into l_itemkey from DUAL;

       	/* create the process */

      	WF_ENGINE.CREATEPROCESS (itemtype => l_itemtype,
                                     itemkey =>  l_itemkey,
                                     process =>  l_WorkflowProcess);

      	/* make sure that process runs in defer mode */
      	WF_ENGINE.THRESHOLD := -1;

      /*Set All Workflow Attributes with Parameter Values */

      WF_ENGINE.SETITEMATTRTEXT(  itemtype => l_itemtype,
                                  itemkey => l_itemkey,
         			  aname => 'CUSTF_RECIPIENT',
         	                      avalue => p_notifier);

      /* Get Notifier Name */
      WF_DIRECTORY.GetRoleInfo(p_notifier,
                               l_Display_name,
                               l_Email_address,
                               l_Notification_preference,
                               l_Language,
                               L_Territory);
      /* Set Workflow Attributes */


      WF_ENGINE.SETITEMATTRTEXT(  itemtype => l_itemtype,
                                  itemkey => l_itemkey,
         			          aname => 'CUSTF_NAME',
         	                      avalue => p_name);

      WF_ENGINE.SETITEMATTRTEXT(  itemtype => l_itemtype,
                                  itemkey => l_itemkey,
         			          aname => 'CUSTF_EMAIL',
         	                      avalue => p_email);

      WF_ENGINE.SETITEMATTRTEXT(  itemtype => l_itemtype,
                                  itemkey => l_itemkey,
         			          aname => 'CUSTF_COMMENTS',
         	                      avalue => p_comments);


	WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,
                                  itemkey => l_itemkey,
         			          aname => 'CUSTF_PHONE',
         	                      avalue => p_phone);

     	WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,
                                  itemkey => l_itemkey,
         			          aname => 'CUSTF_ORDERNUM',
         	                      avalue => p_ordernum);

     	WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,
                                  itemkey => l_itemkey,
         			          aname => 'CUSTF_LINENUM',
         	                      avalue => p_linenum);

     	WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,
                                  itemkey => l_itemkey,
         			          aname => 'CUSTF_PRODUCT',
         	                      avalue => p_products);


     	WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,
                                  itemkey => l_itemkey,
         			          aname => 'CUSTF_QUANTITY',
         	                      avalue => p_quantity);



      	/* start the Workflow process */

      	WF_ENGINE.STARTPROCESS (itemtype => l_itemtype,
                                itemkey => l_itemkey);

        /* Reset The Threshold Value */
        WF_ENGINE.THRESHOLD := l_save_threshold;


  EXCEPTION
      WHEN OTHERS THEN
          /* Reset The Threshold Value */
        WF_ENGINE.THRESHOLD := l_save_threshold;
         WF_CORE.CONTEXT ('ONT_FEEBBACK_PKG','INIT_WF3',l_itemtype,l_itemkey,'Recipient-'||P_NOTIFIER,'Customer-'||P_NAME);
         raise;
  END init_wf3;


END ONT_FEEDBACK_PKG;

/
