--------------------------------------------------------
--  DDL for Package Body PO_APPROVAL_REMINDER_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_APPROVAL_REMINDER_SV" AS
/* $Header: POXWARMB.pls 120.12.12010000.7 2012/07/25 14:11:46 venuthot ship $*/

-- Read the profile option that enables/disables the debug log
g_po_wf_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('PO_SET_DEBUG_WORKFLOW_ON'),'N');
g_fnd_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

-- Item Type for the Reminder Workflow: <SVC_NOTIFICATIONS FPJ>
g_reminder_item_type CONSTANT VARCHAR2(20) := 'APVRMDER';
g_pkg_name           CONSTANT VARCHAR2(30) := 'PO_APPROVAL_REMINDER_SV';
g_module_prefix      CONSTANT VARCHAR2(40) := 'po.plsql.' || g_pkg_name || '.';

/*===========================================================================
  PROCEDURE NAME:       Select_Unapprove_docs

  DESCRIPTION:          This server procedure is defined as a concurrent
                        PL/SQL executable program and is scheduled to run
                        from the Concurrent Manager at a regular intervals
                        (e.g. every day).


  CHANGE HISTORY:       WLAU       7/15/1997     Created

===========================================================================*/

  PROCEDURE Select_Unapprove_docs  IS

   l_ItemType            VARCHAR2(100) := 'APVRMDER';
   l_itemkey             VARCHAR2(100) := NULL;
   l_progress            VARCHAR2(300) := NULL;

  BEGIN


     l_progress := 'PO_APPROVAL_REMINDER_SV.Select_Unapprove_docs: 01 - BEGIN ';
     IF (g_po_wf_debug = 'Y') THEN
        /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(l_itemtype,l_itemkey,l_progress);
     END IF;


      Process_unapprove_reqs;

      Process_unapprove_pos;

      Process_unapprove_releases;

      Process_po_acceptance;

      Process_rel_acceptance;

      Process_rfq_quote;

      process_po_temp_labor_lines; -- <SVC_NOTIFICATIONS FPJ>

     l_progress := 'PO_APPROVAL_REMINDER_SV.Select_Unapprove_docs: 900 - END ';
     IF (g_po_wf_debug = 'Y') THEN
        /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(l_itemtype,l_itemkey,l_progress);
     END IF;


    EXCEPTION

        WHEN OTHERS THEN

             wf_core.context ('PO_APPROVAL_REMINDER_SV','Select_Unapprove_docs ' || l_progress);
            l_progress := 'PO_APPROVAL_REMINDER_SV.Select_Unapprove_docs: 990 - ' ||
                          'EXCEPTION sql error: ' || sqlcode;
            IF (g_po_wf_debug = 'Y') THEN
               /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(l_itemtype,l_itemkey,l_progress);
            END IF;

    RAISE;


  END Select_Unapprove_docs;



/*===========================================================================
  PROCEDURE NAME:       Process_unapprove_reqs

  DESCRIPTION:
                        This procedure does the following:
                        - Open cursor PO_REQUISITION_HEADERS table to select
                          Incomplete or Requires_reapproval documents.

                        - For each unapprove document, initiate the
                          PO Approval Reminder workflow notification.



  CHANGE HISTORY:       WLAU       7/15/1997     Created
===========================================================================*/
 PROCEDURE Process_unapprove_reqs IS

   -- Define cursor for selecting unapprove document to start the Purchasing
   -- Approval Reminder workflow process.
   --

   CURSOR unapprove_req IS
           SELECT Requisition_Header_ID, Segment1, Type_Lookup_Code, Preparer_ID
            FROM  PO_REQUISITION_HEADERS prh
            WHERE NVL(authorization_status,'INCOMPLETE') IN
		     ('INCOMPLETE','REJECTED','REQUIRES REAPPROVAL', 'RETURNED')
              AND NVL(cancel_flag,'N') = 'N'
              AND NVL(closed_code,'OPEN') <> 'FINALLY CLOSED'
              -- Bug fix 14083505 - START: Cancelled lines and the lines which are already part of a PO can be ignored
	      AND EXISTS
              (
                 SELECT 1
                 FROM po_requisition_lines prl
                 WHERE
                   prl.REQUISITION_HEADER_ID = prh.REQUISITION_HEADER_ID
                   AND Nvl(prl.CANCEL_FLAG,'N') <>'Y'
		   AND NVL(prl.closed_code,'OPEN') <> 'FINALLY CLOSED'  --Bug 14363353 fix
                   AND prl.LINE_LOCATION_ID IS NULL
              );
              -- Bug fix 14083505 - END


  l_doc_header_id       NUMBER;
  l_agent_id            NUMBER;
  l_doc_type            VARCHAR2(25);
  l_doc_subtype         VARCHAR2(25);
  l_doc_number          VARCHAR2(20);
  l_release_num	        NUMBER := NULL;

  l_ItemType            VARCHAR2(100) := 'APVRMDER';
  l_itemkey             VARCHAR2(100) := NULL;

  l_item_exist          VARCHAR2(1);
  l_item_end_date	DATE;
  l_progress            VARCHAR2(300) := NULL;

  BEGIN


   l_progress := 'PO_APPROVAL_REMINDER_SV.Process_unapprove_reqs: 01 - BEGIN ';
   IF (g_po_wf_debug = 'Y') THEN
      /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(l_itemtype,l_itemkey,l_progress);
   END IF;


   l_itemkey         := ' ';

   -- Select unapproved requisition documents and initiate
   -- Approval reminder workflow

   OPEN unapprove_req ;

   LOOP

        FETCH Unapprove_req into l_doc_header_id,
       			    	 l_doc_number,
				 l_doc_subtype,
                                 l_agent_id;

         l_doc_type := 'REQUISITION';
         --bug#3709971 modified the structure of item key from
	 --doc_type||doc_subtype||doc_num||agent_id(old structure) to
	 --doc_type||'-'||doc_subtype||'-'||doc_num||'-'||agent_id
         l_itemkey := l_doc_type ||'-'||
			 l_doc_subtype ||'-'||
			 to_char(l_doc_header_id) ||'-'||
                         to_char(l_agent_id);


         IF Unapprove_req%FOUND THEN

	    PO_APPROVAL_REMINDER_SV.item_exist (l_ItemType,
						l_ItemKey,
						l_Item_exist,
						l_Item_end_date);


            IF l_item_exist = 'Y' AND
	       l_item_end_date is NULL THEN

               -- Workflow item exists and is still opened
               -- Bypass this one

               NULL;

	       l_progress := 'PO_APPROVAL_REMINDER_SV.Process_unapprove_reqs: 05 ' ||
			     'open WF item key exists ' ||l_itemkey;
	       -- /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(l_itemtype,l_itemkey,l_progress);

            ELSE


               IF l_item_exist = 'Y' AND
 		  l_item_end_date is NOT NULL THEN

                  -- Call workflow to remove the completed process

                  --<BUG 3351588>
                  --Force item purge even if an active child process exists.
                  WF_PURGE.ITEMS (itemtype => l_ItemType,
                                  itemkey  => l_Itemkey,
                                  enddate  => SYSDATE,
                                  docommit => true,  --<BUG 3351588>
                                  force    => true); --<BUG 3351588>

               END IF;

               --
               -- Invoke the Start_Approval_Reminder workflow
               -- for every unique workflow Item key.

               l_progress := 'PO_APPROVAL_REMINDER_SV.Process_unapprove_reqs: 10 ' ||
			     'Start WF item key =' ||l_itemkey;
 	       IF (g_po_wf_debug = 'Y') THEN
    	       /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(l_itemtype,l_itemkey,l_progress);
 	       END IF;

               PO_APPROVAL_REMINDER_SV.Start_Approval_Reminder (l_doc_header_id,
							  l_doc_number,
                                                          l_doc_type,
					                  l_doc_subtype,
						          l_release_num,
                                                          l_agent_id,
                                                          l_itemkey);


	       -- Commit the changes so that the notifications will be able
               -- to pickup the reminder notifications

               COMMIT;

             END IF;

         END IF;

   EXIT WHEN Unapprove_req%NOTFOUND;

   END LOOP;

   CLOSE Unapprove_req;


   l_progress := 'PO_APPROVAL_REMINDER_SV.Process unapprove_reqs: 900 - END ';
   IF (g_po_wf_debug = 'Y') THEN
      /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(l_itemtype,l_itemkey,l_progress);
   END IF;


    EXCEPTION
        WHEN NO_DATA_FOUND THEN
  	    wf_core.context ('PO_APPROVAL_REMINDER_SV','Process_Unapprove_reqs','No data found');
   	     l_progress := 'PO_APPROVAL_REMINDER_SV.Process unapprove_reqs: 901 - ' ||
 		           'EXCEPTION - no data found sql error: ' || sqlcode;
             IF (g_po_wf_debug = 'Y') THEN
                /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(l_itemtype,l_itemkey,l_progress);
             END IF;


        WHEN OTHERS THEN
  	     wf_core.context ('PO_APPROVAL_REMINDER_SV','Process_Unapprove_reqs','SQL error ' || sqlcode);
   	     l_progress := 'PO_APPROVAL_REMINDER_SV.Process unapprove_reqs: 990 - ' ||
 		           'EXCEPTION - sql error: ' || sqlcode;
             IF (g_po_wf_debug = 'Y') THEN
                /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(l_itemtype,l_itemkey,l_progress);
             END IF;

    RAISE;


 END Process_unapprove_reqs;



/*===========================================================================
  PROCEDURE NAME:       Process_unapprove_pos

  DESCRIPTION:
                        This procedure does the following:
                        - Open cursor PO_HEADERS table to select
                          Incomplete or Requires_reapproval documents.

                        - For each unapprove document, initiate the
                          PO Approval Reminder workflow notification.

  CHANGE HISTORY:       WLAU       7/15/1997     Created
===========================================================================*/

 PROCEDURE Process_unapprove_pos IS

   -- Define cursor for selecting unapprove document to start the Purchasing
   -- Approval Reminder workflow process.
   --

   CURSOR unapprove_PO IS
           SELECT PO_Header_ID, Segment1, Type_Lookup_Code, Agent_ID
            FROM  PO_HEADERS
            WHERE NVL(authorization_status,'INCOMPLETE') IN
		     ('INCOMPLETE','REJECTED','REQUIRES REAPPROVAL')
--              AND WF_ITEM_TYPE = NULL
--              AND WF_ITEM_KEY  = NULL
              AND type_lookup_code in ('STANDARD','PLANNED','BLANKET','CONTRACT')
              AND NVL(cancel_flag,'N') = 'N'
              AND NVL(closed_code,'OPEN') <> 'FINALLY CLOSED';


  l_doc_header_id       NUMBER;
  l_agent_id         	NUMBER;
  l_doc_type            VARCHAR2(25);
  l_doc_subtype         VARCHAR2(25);
  l_doc_number          VARCHAR2(20);
  l_release_num	        NUMBER := NULL;

  l_ItemType            VARCHAR2(100) := 'APVRMDER';
  l_itemkey          	VARCHAR2(100) := NULL;

  l_item_exist          VARCHAR2(1);
  l_item_end_date	DATE;
  l_progress            VARCHAR2(300) := NULL;

  BEGIN


   l_progress := 'PO_APPROVAL_REMINDER_SV.Process unapprove_pos: 01 - BEGIN ';
   IF (g_po_wf_debug = 'Y') THEN
      /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(l_itemtype,l_itemkey,l_progress);
   END IF;


   l_itemkey         := ' ';

   -- Select unapproved po documents and initiate
   -- Approval reminder workflow

   OPEN unapprove_PO ;

   LOOP

        FETCH Unapprove_PO into  l_doc_header_id,
       			    	 l_doc_number,
				 l_doc_subtype,
                                 l_agent_id;


         IF l_doc_subtype IN ('STANDARD','PLANNED') THEN
            l_doc_type := 'PO';
         ELSIF l_doc_subtype IN ('BLANKET','CONTRACT') THEN
            l_doc_type := 'PA';
         END IF;
         --bug#3709971 modified the structure of item key from
	 --doc_type||doc_subtype||doc_num||agent_id(old structure) to
	 --doc_type||'-'||doc_subtype||'-'||doc_num||'-'||agent_id

         l_itemkey := l_doc_type || '-'||
			 l_doc_subtype ||'-'||
			 to_char(l_doc_header_id) ||'-'||
                         to_char(l_agent_id);


         IF Unapprove_PO%FOUND THEN


	    PO_APPROVAL_REMINDER_SV.item_exist (l_ItemType,
						l_ItemKey,
						l_Item_exist,
						l_Item_end_date);


            IF l_item_exist = 'Y' AND
	       l_item_end_date is NULL THEN

               -- Workflow item exists and is still opened
               -- Bypass this one

               NULL;

	       l_progress := 'PO_APPROVAL_REMINDER_SV.Process_unapprove_pos: 05 ' ||
			     'open WF item key exists ' ||l_itemkey;
	       -- /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(l_itemtype,l_itemkey,l_progress);

            ELSE


               IF l_item_exist = 'Y' AND
 		  l_item_end_date is NOT NULL THEN

                  -- Call workflow to remove the completed process

                  --<BUG 3351588>
                  --Force item purge even if an active child process exists.
                  WF_PURGE.ITEMS (itemtype => l_ItemType,
                                  itemkey  => l_Itemkey,
                                  enddate  => SYSDATE,
                                  docommit => true,  --<BUG 3351588>
                                  force    => true); --<BUG 3351588>
               END IF;

               --
               -- Invoke the Start_Approval_Reminder workflow
               -- for every unique workflow Item key.

               l_progress := 'PO_APPROVAL_REMINDER_SV.Process_unapprove_pos: 10 ' ||
			     'Start WF item key =' ||l_itemkey;
 	       IF (g_po_wf_debug = 'Y') THEN
    	       /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(l_itemtype,l_itemkey,l_progress);
 	       END IF;

               PO_APPROVAL_REMINDER_SV.Start_Approval_Reminder (l_doc_header_id,
							  l_doc_number,
                                                          l_doc_type,
					                  l_doc_subtype,
						          l_release_num,
                                                          l_agent_id,
                                                          l_itemkey);



	       -- Commit the changes so that the notifications will be able
               -- to pickup the reminder notifications

               COMMIT;

             END IF;

         END IF;

   EXIT WHEN Unapprove_PO%NOTFOUND;

   END LOOP;

   CLOSE Unapprove_PO;


   l_progress := 'PO_APPROVAL_REMINDER_SV.Process unapprove_pos: 900 - END ';
   IF (g_po_wf_debug = 'Y') THEN
      /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(l_itemtype,l_itemkey,l_progress);
   END IF;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
             wf_core.context ('PO_APPROVAL_REMINDER_SV','Process_Unapprove_pos','No data found');

   	     l_progress := 'PO_APPROVAL_REMINDER_SV.Process unapprove_pos: 901 - ' ||
 		           'EXCEPTION - no data found sql error: ' || sqlcode;
             IF (g_po_wf_debug = 'Y') THEN
                /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(l_itemtype,l_itemkey,l_progress);
             END IF;

        WHEN OTHERS THEN
             wf_core.context ('PO_APPROVAL_REMINDER_SV','Process_Unapprove_pos','SQL error ' || sqlcode);

   	     l_progress := 'PO_APPROVAL_REMINDER_SV.Process unapprove_pos: 990 - ' ||
 		           'EXCEPTION - sql error: ' || sqlcode;
             IF (g_po_wf_debug = 'Y') THEN
                /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(l_itemtype,l_itemkey,l_progress);
             END IF;


    RAISE;


 END Process_unapprove_pos;


/*===========================================================================
  PROCEDURE NAME:       Process_unapprove_releases

  DESCRIPTION:
                        This procedure does the following:
                        - Open cursor PO_RELEASES table to select
                          Incomplete or Requires_reapproval documents.

                        - For each unapprove document, initiate the
                          PO Approval Reminder workflow notification.

  CHANGE HISTORY:       WLAU       7/15/1997     Created
===========================================================================*/

 PROCEDURE Process_unapprove_releases IS

   -- Define cursor for selecting unapprove document to start the Purchasing
   -- Approval Reminder workflow process.
   --


   CURSOR unapprove_REL IS
           SELECT PORH.PO_release_ID, POH.Segment1, PORH.release_num,
	          POH.Type_Lookup_Code, PORH.Agent_ID
            FROM  PO_RELEASES_ALL PORH,    -- <R12 MOAC>
	          PO_HEADERS POH
            WHERE NVL(PORH.authorization_status,'INCOMPLETE') IN
		     ('INCOMPLETE','REJECTED','REQUIRES REAPPROVAL')
--              AND WF_ITEM_TYPE = NULL
--              AND WF_ITEM_KEY  = NULL
              AND NVL(PORH.cancel_flag,'N') = 'N'
              AND NVL(PORH.closed_code,'OPEN') <> 'FINALLY CLOSED'
              AND POH.PO_HEADER_ID = PORH.PO_HEADER_ID;

  l_doc_header_id       NUMBER;
  l_agent_id         	NUMBER;
  l_doc_type            VARCHAR2(25);
  l_doc_subtype         VARCHAR2(25);
  l_doc_number          VARCHAR2(20);
  l_release_num	        NUMBER := NULL;

  l_ItemType            VARCHAR2(100) := 'APVRMDER';
  l_itemkey             VARCHAR2(100) := NULL;


  l_item_exist          VARCHAR2(1);
  l_item_end_date	DATE;
  l_progress            VARCHAR2(300) := NULL;

  BEGIN


   l_progress := 'PO_APPROVAL_REMINDER_SV.Process_unapprove_releases: 01 - BEGIN ';
   IF (g_po_wf_debug = 'Y') THEN
      /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(l_itemtype,l_itemkey,l_progress);
   END IF;

   l_itemkey         := ' ';

   -- Select unapproved release documents and initiate
   -- Approval reminder workflow

   OPEN unapprove_REL ;

   LOOP

        FETCH Unapprove_REL into l_doc_header_id,
       			    	 l_doc_number,
				 l_release_num,
				 l_doc_subtype,
                                 l_agent_id;

         l_doc_type := 'RELEASE';

         IF l_doc_subtype = 'PLANNED' THEN
            l_doc_subtype := 'SCHEDULED';
         END IF;
         --bug#3709971 modified the structure of item key from
	 --doc_type||doc_subtype||doc_num||agent_id(old structure) to
	 --doc_type||'-'||doc_subtype||'-'||doc_num||'-'||agent_id

         l_itemkey := l_doc_type || '-'||
			 l_doc_subtype ||'-'||
			 to_char(l_doc_header_id) ||'-'||
                         to_char(l_agent_id);


         IF Unapprove_REL%FOUND THEN


	    PO_APPROVAL_REMINDER_SV.item_exist (l_ItemType,
						l_ItemKey,
						l_Item_exist,
						l_Item_end_date);


            IF l_item_exist = 'Y' AND
	       l_item_end_date is NULL THEN

               -- Workflow item exists and is still opened
               -- Bypass this one

               NULL;

	       l_progress := 'PO_APPROVAL_REMINDER_SV.Process_unapprove_releases: 05 ' ||
			     'open WF item key exists ' ||l_itemkey;
	       -- /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(l_itemtype,l_itemkey,l_progress);


            ELSE

               IF l_item_exist = 'Y' AND
 		  l_item_end_date is NOT NULL THEN

                  -- Call workflow to remove the completed process

                  --<BUG 3351588>
                  --Force item purge even if an active child process exists.
                  WF_PURGE.ITEMS (itemtype => l_ItemType,
                                  itemkey  => l_Itemkey,
                                  enddate  => SYSDATE,
                                  docommit => true,  --<BUG 3351588>
                                  force    => true); --<BUG 3351588>

               END IF;


               --
               -- Invoke the Start_Approval_Reminder workflow
               -- for every unique workflow Item key.

               l_progress := 'PO_APPROVAL_REMINDER_SV.Process_unapprove_releases: 10 ' ||
			     'Start WF item key =' ||l_itemkey;
 	       IF (g_po_wf_debug = 'Y') THEN
    	       /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(l_itemtype,l_itemkey,l_progress);
 	       END IF;

               PO_APPROVAL_REMINDER_SV.Start_Approval_Reminder (l_doc_header_id,
							  l_doc_number,
                                                          l_doc_type,
					                  l_doc_subtype,
							  l_release_num,
                                                          l_agent_id,
                                                          l_itemkey);


	       -- Commit the changes so that the notifications will be able
               -- to pickup the reminder notifications

               COMMIT;

             END IF;

         END IF;

   EXIT WHEN Unapprove_REL%NOTFOUND;

   END LOOP;

   CLOSE Unapprove_REL;

    l_progress := 'PO_APPROVAL_REMINDER_SV.Process unapprove_releases: 900 - END ';
   IF (g_po_wf_debug = 'Y') THEN
      /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(l_itemtype,l_itemkey,l_progress);
   END IF;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
             wf_core.context ('PO_APPROVAL_REMINDER_SV','Process_Unapprove_releases','No data found');
   	     l_progress := 'PO_APPROVAL_REMINDER_SV.Process_Unapprove_releases: 901 - ' ||
 		           'EXCEPTION - no data found sql error: ' || sqlcode;
             IF (g_po_wf_debug = 'Y') THEN
                /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(l_itemtype,l_itemkey,l_progress);
             END IF;


        WHEN OTHERS THEN
             wf_core.context ('PO_APPROVAL_REMINDER_SV','Process_Unapprove_releases','SQL error ' || sqlcode);
   	     l_progress := 'PO_APPROVAL_REMINDER_SV.Process_Unapprove_releases: 990 - ' ||
 		           'EXCEPTION - sql error: ' || sqlcode;
             IF (g_po_wf_debug = 'Y') THEN
                /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(l_itemtype,l_itemkey,l_progress);
             END IF;

    RAISE;



 END Process_unapprove_releases;


/*===========================================================================
  PROCEDURE NAME:       Process_po_acceptance

  DESCRIPTION:
                        This procedure does the following:
                        - Search for Approved POs with acceptance required

                        - For each selected document, initiate the
                          PO Approval Reminder workflow notification

  CHANGE HISTORY:       WLAU       11/15/1997     Created
===========================================================================*/

 PROCEDURE Process_po_acceptance IS

   -- Define cursor for selecting approved POs with acceptance required

/* Bug# 1595348: kagarwal
** Desc: If the PO/Rel is accepted using Web Supplier Portal, the acceptance
** is registered in the PO Acceptances table. Hence we need to check the PO
** Acceptances table also.
*/
   -- Bug 5074128(forward fix4772820)
   -- poh.acceptance_required_flag can be Y or D
   CURSOR PO_acceptance IS
           SELECT poh.PO_Header_ID, poh.Segment1, poh.Type_Lookup_Code,
		  poh.Agent_ID, NVL(poh.Acceptance_Due_Date, SYSDATE)
            FROM  PO_HEADERS poh
            WHERE NVL(poh.authorization_status,'INCOMPLETE') = 'APPROVED'
	      AND NVL(poh.acceptance_required_flag,'N') in ('Y','D')
              AND poh.type_lookup_code in
                    ('STANDARD','PLANNED','BLANKET','CONTRACT')
              AND NVL(poh.cancel_flag,'N') = 'N'
              AND NVL(poh.closed_code,'OPEN') <> 'FINALLY CLOSED'
              AND not exists (
			SELECT poa.ACCEPTANCE_ID
			FROM PO_ACCEPTANCES poa
			WHERE NVL(poa.accepted_flag, 'N') = 'Y'
			AND poa.po_header_id = poh.po_header_id
			AND nvl(poa.revision_num,0) = nvl(poh.revision_num,0));


  l_doc_header_id       NUMBER;
  l_agent_id         	NUMBER;
  l_doc_type            VARCHAR2(25);
  l_doc_subtype         VARCHAR2(25);
  l_doc_number          VARCHAR2(20);
  l_release_num	        NUMBER := NULL;
  l_acceptance_due_date DATE;

  l_ItemType            VARCHAR2(100) := 'APVRMDER';
  l_itemkey             VARCHAR2(100) := NULL;


  l_item_exist          VARCHAR2(1);
  l_item_end_date	DATE;
  l_progress            VARCHAR2(300) := NULL;

   l_message_name            VARCHAR2(50)  := NULL;  --bug 3896181

  BEGIN


   l_progress := 'PO_APPROVAL_REMINDER_SV.Process_po_acceptance: 01 - BEGIN ';
   IF (g_po_wf_debug = 'Y') THEN
      /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(l_itemtype,l_itemkey,l_progress);
   END IF;


   l_itemkey         := '';

   -- Select POs required and initiate Approval reminder workflow

   OPEN PO_acceptance ;

   LOOP

        FETCH PO_acceptance into l_doc_header_id,
       			    	 l_doc_number,
				 l_doc_subtype,
	                         l_agent_id,
				 l_acceptance_due_date;

	 l_doc_type := 'PO_ACCEPTANCE';
         --bug#3709971 modified the structure of item key from
	 --doc_type||doc_subtype||doc_num(old structure) to
	 --doc_type||'-'||doc_subtype||'-'||doc_num

         l_itemkey := l_doc_type || '-'||
		      l_doc_subtype ||'-'||
		      to_char(l_doc_header_id);

 /* Bug 3896181 fixed.
            Revamped the code for acceptances part to take care of multiple scenarios now.
            After the fix, if a reminder notification already exists, then APVRMDER will not
            send new notifications.
            If the acceptance_due_date is passed and a reminder notification exists, then
            this old notification is closed and a new 'past-due' notification is sent.
            Also, if at any time, acceptance_due_date is changed to old/new dates, sending
            of notifications is taken care appropriately.
            THe below part fixes for PO acceptance notifications.
         */
         IF PO_acceptance%FOUND THEN


	    PO_APPROVAL_REMINDER_SV.item_exist (l_ItemType,
						l_ItemKey,
						l_Item_exist,
						l_Item_end_date);


            IF l_item_exist = 'Y' THEN

--               IF to_date(to_char(l_acceptance_due_date,'DD/MM/YYYY'),'DD-MON-YYYY') >
--		  to_date(to_char(SYSDATE,'DD-MON-YYYY'),'DD/MM/YYYY') THEN
-- bug: 1076985

-- bug 3896181 <start>
  l_progress := 'PO_APPROVAL_REMINDER_SV.Process_po_acceptance: 02 - item key exists ';
  IF (g_po_wf_debug = 'Y') THEN
 /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(l_itemtype,l_itemkey,l_progress);
 end if;
-- bug 3896181 <end>

	       IF trunc(l_acceptance_due_date) > trunc(sysdate) THEN

 -- bug 3896181 <start>
    l_progress := 'PO_APPROVAL_REMINDER_SV.Process_po_acceptance: 03 - acc_due_date > sysdate ';
    IF (g_po_wf_debug = 'Y') THEN
    /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(l_itemtype,l_itemkey,l_progress);
    END IF;
    IF l_Item_end_date is not null then
            l_progress := 'PO_APPROVAL_REMINDER_SV.Process_po_acceptance: 04 - end_date not null';
            IF (g_po_wf_debug = 'Y') THEN
            /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(l_itemtype,l_itemkey,l_progress);
            END IF;
  -- bug 3896181 <end>
                      PO_APPROVAL_REMINDER_SV.Cancel_Notif (l_doc_type,
						        l_doc_header_id,
						        NULL);
  -- bug 3896181 <start>

            WF_PURGE.ITEMS (l_ItemType,
                            l_itemkey,
                            SYSDATE,
                            true,
                            true);
                            PO_APPROVAL_REMINDER_SV.Start_Approval_Reminder (l_doc_header_id,
                            l_doc_number,
                            l_doc_type,
                            l_doc_subtype,
                            l_release_num,
                            l_agent_id,
                            l_itemkey);
            COMMIT;
            ELSE -- l_Item_end_date is not null
            l_progress := 'PO_APPROVAL_REMINDER_SV.Process_po_acceptance: 05 - end_date is null';
            IF (g_po_wf_debug = 'Y') THEN
            /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(l_itemtype,l_itemkey,l_progress);
  -- bug 3896181 <end>
 		  END IF;

-- bug 3896181 <start>
                       select wfn.MESSAGE_NAME
              into l_message_name
              from wf_item_activity_statuses wias, wf_notifications wfn
             where wias.notification_id = wfn.group_id
               and wias.item_type = 'APVRMDER'
               and wias.item_key = l_ItemKey ;
             IF l_message_name = 'PO_ACCEPTANCE_PAST_DUE' then
             l_progress := 'PO_APPROVAL_REMINDER_SV.Process_po_acceptance: 06 - PO_ACCEPTANCE_PAST_DUE';
  -- bug 3896181 <end>
              IF (g_po_wf_debug = 'Y') THEN
                    /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(l_itemtype,l_itemkey,l_progress);
                 END IF;
-- bug 3896181 <start>
                PO_APPROVAL_REMINDER_SV.Cancel_Notif (l_doc_type,
                                      l_doc_header_id,
                                      NULL);
 -- bug 3896181 <end>
                  --<BUG 3351588>
                  --Force item purge even if an active child process exists.

                  WF_PURGE.ITEMS (itemtype => l_ItemType,
                                  itemkey  => l_Itemkey,
                                  enddate  => SYSDATE,
                                  docommit => true,  --<BUG 3351588>
                                  force    => true); --<BUG 3351588>

 -- bug 3896181 <start>
                PO_APPROVAL_REMINDER_SV.Start_Approval_Reminder (l_doc_header_id,
                                                                l_doc_number,
                                                                   l_doc_type,
                                                                            l_doc_subtype,
                                                                l_release_num,
                                                                l_agent_id,
                                                                l_itemkey);
                COMMIT;
                END IF; --  l_message_name = 'PO_ACCEPTANCE_PAST_DUE'
             END IF; -- l_Item_end_date is not null
           ELSE  -- l_acceptance_due_date) > trunc(sysdate)
                l_progress := 'PO_APPROVAL_REMINDER_SV.Process_po_acceptance: 07 - acc_due_date < sysdate';
 -- bug 3896181 <end>
           IF (g_po_wf_debug = 'Y') THEN
    	          /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(l_itemtype,l_itemkey,l_progress);
 	          END IF;

 -- bug 3896181 <start>
            IF l_Item_end_date is not NULL THEN
                         l_progress := 'PO_APPROVAL_REMINDER_SV.Process_po_acceptance: 08 - end_date is not null';
            IF (g_po_wf_debug = 'Y') THEN
                 /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(l_itemtype,l_itemkey,l_progress);
            END IF;
               PO_APPROVAL_REMINDER_SV.Cancel_Notif (l_doc_type,
                                                 l_doc_header_id,
                                                 NULL);
                                   WF_PURGE.ITEMS (l_ItemType,
                               l_itemkey,
                                                   SYSDATE,
                                                   true,
                                                   true);
 -- bug 3896181 <end>

                  PO_APPROVAL_REMINDER_SV.Start_Approval_Reminder (l_doc_header_id,
							                                       l_doc_number,
                                                                   l_doc_type,
                                                                   l_doc_subtype,
                                                                   l_release_num,
                                                                   l_agent_id,
                                                                   l_itemkey);


	         -- Commit the changes so that the notifications will be able
                 -- to pickup the reminder notifications

                 COMMIT;
 	       -- bug 3896181 <start>
               ELSE -- l_Item_end_date is not NULL
                        l_progress := 'PO_APPROVAL_REMINDER_SV.Process_po_acceptance: 09 - end_date is null';
               IF (g_po_wf_debug = 'Y') THEN
                     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(l_itemtype,l_itemkey,l_progress);
 	       -- bug 3896181 <end>
               END IF;
 	       -- bug 3896181 <start>
	       /* FP bug 14019376
 		  in some customer's cases, when a user associated to a buyer become invalid,
		  the notification PO_ACCEPTANCE_PAST_DUE sent with error in previous run
  	          and no notification_id was generated.
		  In future run, below sql raises exception and prevent other POs
                  being processed. Add exception handling
		  to continue processing other POs in loop */
   	       BEGIN
               select wfn.MESSAGE_NAME
               into l_message_name
               from wf_item_activity_statuses wias, wf_notifications wfn
               where wias.notification_id = wfn.group_id
               and  wias.item_type = 'APVRMDER'
               and  wias.item_key = l_ItemKey ;
	       EXCEPTION
                 WHEN OTHERS THEN
                   l_message_name := null;
                   l_progress := 'This PO may have WFENG_NOTIFICATION_PERFORMER issue - please check wfstatus';
                   IF (g_po_wf_debug = 'Y') THEN
                     PO_WF_DEBUG_PKG.insert_debug(l_itemtype,l_itemkey,l_progress);
                   END IF;
               END; --End 14019376

               IF l_message_name = 'PO_ACCEPTANCE_REQUIRED' then
               l_progress := 'PO_APPROVAL_REMINDER_SV.Process_po_acceptance: 10 - PO_ACCEPTANCE_REQUIRED';
               		IF (g_po_wf_debug = 'Y') THEN
               		/* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(l_itemtype,l_itemkey,l_progress);
               		END IF;
               PO_APPROVAL_REMINDER_SV.Cancel_Notif (l_doc_type,
               l_doc_header_id,
               NULL);
               WF_PURGE.ITEMS (l_ItemType,
               l_itemkey,
               SYSDATE,
               true,
               true);
               -- bug 3896181 <end>

               PO_APPROVAL_REMINDER_SV.Start_Approval_Reminder (l_doc_header_id,
                                                                l_doc_number,
                                                                l_doc_type,
                                                                l_doc_subtype,
                                                                l_release_num,
                                                                l_agent_id,
                                                                l_itemkey);
-- bug 3896181 <start>
            COMMIT;
                      END IF; --  l_message_name = 'PO_ACCEPTANCE_REQUIRED'
                  END IF; --  l_Item_end_date is not NULL
               END IF; --   l_acceptance_due_date) > trunc(sysdate)
            ELSE  --  l_item_exist = 'Y'
                      l_progress := 'PO_APPROVAL_REMINDER_SV.Process_po_acceptance: 11 - l_item_exists is N';
 -- bug 3896181 <end>
  	       IF (g_po_wf_debug = 'Y') THEN
    	       /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(l_itemtype,l_itemkey,l_progress);
 	       END IF;
 -- bug 3896181 <start>
            PO_APPROVAL_REMINDER_SV.Start_Approval_Reminder (l_doc_header_id,
                                                            l_doc_number,
                                                            l_doc_type,
                                                            l_doc_subtype,
                                                            l_release_num,
                                                            l_agent_id,
                                                            l_itemkey);
-- bug 3896181 <end>

	       -- Commit the changes so that the notifications will be able
               -- to pickup the reminder notifications

               COMMIT;

             END IF; -- l_item_exist = 'Y'
         END IF;  -- PO_acceptance%FOUND

   EXIT WHEN PO_acceptance%NOTFOUND;

   END LOOP;

   CLOSE PO_acceptance;


    l_progress := 'PO_APPROVAL_REMINDER_SV.Process_po_acceptance: 900 - END ';
   IF (g_po_wf_debug = 'Y') THEN
      /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(l_itemtype,l_itemkey,l_progress);
   END IF;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
             wf_core.context ('PO_APPROVAL_REMINDER_SV','Process_po_acceptance','No data found');
   	     l_progress := 'PO_APPROVAL_REMINDER_SV.Process_po_acceptance: 901 - ' ||
 		           'EXCEPTION - no data found sql error: ' || sqlcode;
             IF (g_po_wf_debug = 'Y') THEN
                /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(l_itemtype,l_itemkey,l_progress);
             END IF;

        WHEN OTHERS THEN
             wf_core.context ('PO_APPROVAL_REMINDER_SV','Process_po_acceptance','SQL error ' || sqlcode);
   	     l_progress := 'PO_APPROVAL_REMINDER_SV.Process_po_acceptance: 990 - ' ||
 		           'EXCEPTION - sql error: ' || sqlcode;
             IF (g_po_wf_debug = 'Y') THEN
                /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(l_itemtype,l_itemkey,l_progress);
             END IF;

    RAISE;



 END Process_po_acceptance;


/*===========================================================================
  PROCEDURE NAME:       Process_rel_acceptance

  DESCRIPTION:
                        This procedure does the following:
                        - Search for Approved releases with acceptance required

                        - For each selected document, initiate the
                          PO Approval Reminder workflow notification

  CHANGE HISTORY:       WLAU       11/15/1997     Created
===========================================================================*/

 PROCEDURE Process_rel_acceptance IS

   -- Define cursor for selecting approved releases with acceptance required

/* Bug# 1595348: kagarwal
** Desc: If the PO/Rel is accepted using Web Supplier Portal, the acceptance
** is registered in the PO Acceptances table. Hence we need to check the PO
** Acceptances table also.
*/

/* Bug# 2633688: kagarwal
** Desc: When accepting releases from ISP, the po header id is
** left null in the po acceptances table (See Bug 2188005) hence
** removing the condition 'poa.po_header_id = poh.po_header_id'
*/


   CURSOR REL_acceptance IS
           SELECT PORH.PO_release_ID, POH.Segment1, PORH.release_num,
	          POH.Type_Lookup_Code, PORH.Agent_ID,
                  NVL(PORH.Acceptance_Due_Date, SYSDATE)
            FROM  PO_RELEASES_ALL PORH,   -- <R12 MOAC>
	          PO_HEADERS POH
            WHERE NVL(PORH.authorization_status,'INCOMPLETE') = 'APPROVED'
   		AND NVL(PORH.acceptance_required_flag,'N')= 'Y'
              AND NVL(PORH.cancel_flag,'N') = 'N'
              AND NVL(PORH.closed_code,'OPEN') <> 'FINALLY CLOSED'
              AND POH.PO_HEADER_ID = PORH.PO_HEADER_ID
	      AND not exists (
                        SELECT poa.ACCEPTANCE_ID
                        FROM PO_ACCEPTANCES poa
                        WHERE NVL(poa.accepted_flag, 'N') = 'Y'
                    /*    AND poa.po_header_id = poh.po_header_id */
                        AND porh.po_release_id = poa.po_release_id
                        AND nvl(poa.revision_num,0) = nvl(porh.revision_num,0));

  l_doc_header_id       NUMBER;
  l_agent_id         	NUMBER;
  l_doc_type            VARCHAR2(25);
  l_doc_subtype         VARCHAR2(25);
  l_doc_number          VARCHAR2(20);
  l_release_num	        NUMBER := NULL;
  l_acceptance_due_date DATE;

  l_ItemType            VARCHAR2(100) := 'APVRMDER';
  l_itemkey             VARCHAR2(100) := NULL;


  l_item_exist          VARCHAR2(1);
  l_item_end_date	DATE;
  l_progress            VARCHAR2(300) := NULL;

  l_message_name                VARCHAR2(300) := NULL; --bug 3896181
  BEGIN

    l_progress := 'PO_APPROVAL_REMINDER_SV.Process_rel_acceptance: 01 - BEGIN ';
   IF (g_po_wf_debug = 'Y') THEN
      /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(l_itemtype,l_itemkey,l_progress);
   END IF;

   l_itemkey         := '';

   -- Select releases with acceptance required and initiate
   -- Approval reminder workflow

   OPEN REL_acceptance ;

   LOOP

        FETCH REL_acceptance into l_doc_header_id,
       			    	 l_doc_number,
				 l_release_num,
				 l_doc_subtype,
                                 l_agent_id,
				 l_acceptance_due_date;

         l_doc_type := 'REL_ACCEPTANCE';

         IF l_doc_subtype = 'PLANNED' THEN
            l_doc_subtype := 'SCHEDULED';
         END IF;
         --bug#3709971 modified the structure of item key from
	 --doc_type||doc_subtype||doc_num(old structure) to
	 --doc_type||'-'||doc_subtype||'-'||doc_num

         l_itemkey := l_doc_type || '-'||
		      l_doc_subtype ||'-'||
		      to_char(l_doc_header_id);

   /* Bug 3896181 fixed.
            Revamped the code for acceptances part to take care of multiple scenarios now.
            After the fix, if a reminder notification already exists, then APVRMDER will not
            send new notifications.
            If the acceptance_due_date is passed and a reminder notification exists, then
            this old notification is closed and a new 'past-due' notification is sent.
            Also, if at any time, acceptance_due_date is changed to old/new dates, sending
            of notifications is taken care appropriately.
            The below part fixes for Release acceptance notifications.
         */

         IF REL_acceptance%FOUND THEN


            -- Call Workflow to check if the itemkey already exists
	    PO_APPROVAL_REMINDER_SV.item_exist (l_ItemType,
						l_ItemKey,
						l_Item_exist,
						l_Item_end_date);

            IF l_item_exist = 'Y' THEN

--bug 3896181 <start>
           l_progress := 'PO_APPROVAL_REMINDER_SV.Process_rel_acceptance: 02 - item key exists ';
              IF (g_po_wf_debug = 'Y') THEN
                         /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(l_itemtype,l_itemkey,l_progress);
              END IF;
              IF trunc(l_acceptance_due_date) > trunc(sysdate) THEN
               l_progress := 'PO_APPROVAL_REMINDER_SV.Process_rel_acceptance: 03 - acc_due_date > sysdate ';
                 IF (g_po_wf_debug = 'Y') THEN
                   /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(l_itemtype,l_itemkey,l_progress);
                     END IF;
                 IF l_Item_end_date is not null then
                       l_progress := 'PO_APPROVAL_REMINDER_SV.Process_rel_acceptance: 04 - end_date not null';
                    IF (g_po_wf_debug = 'Y') THEN
                     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(l_itemtype,l_itemkey,l_progress);
                     END IF;
--bug 3896181 <end>

                     PO_APPROVAL_REMINDER_SV.Cancel_Notif (l_doc_type,
						        l_doc_header_id,
						        NULL);
--bug 3896181 <start>
                WF_PURGE.ITEMS (l_ItemType,
                                         l_itemkey,
                                         SYSDATE,
                                         true,
                                         true);
                         PO_APPROVAL_REMINDER_SV.Start_Approval_Reminder (l_doc_header_id,
                                       l_doc_number,
                                       l_doc_type,
                                       l_doc_subtype,
                                       l_release_num,
                                       l_agent_id,
                                       l_itemkey);
                         COMMIT;
                     ELSE  -- l_Item_end_date is not null
                                   l_progress := 'PO_APPROVAL_REMINDER_SV.Process_rel_acceptance: 05 - end_date is null';
                         IF (g_po_wf_debug = 'Y') THEN
                           /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(l_itemtype,l_itemkey,l_progress);
--bug 3896181 <end>
  		END IF;

--bug 3896181 <start>
        begin
         select wfn.MESSAGE_NAME
         into l_message_name
         from wf_item_activity_statuses wias, wf_notifications wfn
         where wias.notification_id = wfn.group_id
         and   wias.item_type = 'APVRMDER'
         and   wias.item_key = l_ItemKey ;
        exception
          when others then
            NULL;
        end ;
        IF l_message_name = 'REL_ACCEPTANCE_PAST_DUE' then
           l_progress := 'PO_APPROVAL_REMINDER_SV.Process_rel_acceptance: 06 - REL_ACCEPTANCE_PAST_DUE';
   --bug 3896181 <end>
               IF (g_po_wf_debug = 'Y') THEN
                  /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(l_itemtype,l_itemkey,l_progress);
               END IF;
 --bug 3896181 <start>
                 PO_APPROVAL_REMINDER_SV.Cancel_Notif (l_doc_type,
                                                 l_doc_header_id,
                                                NULL);
  --bug 3896181 <end>

                --<BUG 3351588>
                --Force item purge even if an active child process exists.
                WF_PURGE.ITEMS (itemtype => l_ItemType,
                                itemkey  => l_Itemkey,
                                enddate  => SYSDATE,
                                docommit => true,  --<BUG 3351588>
                                force    => true); --<BUG 3351588>

 --bug 3896181 <start>
                   PO_APPROVAL_REMINDER_SV.Start_Approval_Reminder (l_doc_header_id,
                                                                    l_doc_number,
                                                                    l_doc_type,
                                                                    l_doc_subtype,
                                                                    l_release_num,
                                                                    l_agent_id,
                                                                    l_itemkey);
                                   COMMIT;
                                 END IF; --  l_message_name = 'REL_ACCEPTANCE_PAST_DUE'
                     END IF; -- l_Item_end_date is not null
              ELSE --  trunc(l_acceptance_due_date) > trunc(sysdate)
                    l_progress := 'PO_APPROVAL_REMINDER_SV.Process_rel_acceptance: 07 - acc_due_date < sysdate';
  --bug 3896181 <end>
 	          IF (g_po_wf_debug = 'Y') THEN
    	          /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(l_itemtype,l_itemkey,l_progress);
 	          END IF;

 --bug 3896181 <end>
          IF l_Item_end_date is not NULL THEN
                          l_progress := 'PO_APPROVAL_REMINDER_SV.Process_rel_acceptance: 08 - end_date is not null';
                           IF (g_po_wf_debug = 'Y') THEN
                                 /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(l_itemtype,l_itemkey,l_progress);
                           END IF;
                        PO_APPROVAL_REMINDER_SV.Cancel_Notif (l_doc_type,
                                                                l_doc_header_id,
                                                               NULL);
                        WF_PURGE.ITEMS (l_ItemType,
                                        l_itemkey,
                                        SYSDATE,
                                        true,
                                        true);

  --bug 3896181 <end>

                  PO_APPROVAL_REMINDER_SV.Start_Approval_Reminder (l_doc_header_id,
							  l_doc_number,
                                                          l_doc_type,
					                  l_doc_subtype,
							  l_release_num,
                                                          l_agent_id,
                                                          l_itemkey);

	         -- Commit the changes so that the notifications will be able
                 -- to pickup the reminder notifications

                 COMMIT;
--bug 3896181 <start>
             ELSE -- l_Item_end_date is not NULL
                         l_progress := 'PO_APPROVAL_REMINDER_SV.Process_rel_acceptance: 09 - end_date is null';
                           IF (g_po_wf_debug = 'Y') THEN
                                 /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(l_itemtype,l_itemkey,l_progress);
 --bug 3896181 <end>
               END IF;

 --bug 3896181 <start>
             begin
                    select wfn.MESSAGE_NAME
                      into   l_message_name
                      from wf_item_activity_statuses wias, wf_notifications wfn
                     where wias.notification_id = wfn.group_id
                          and   wias.item_type = 'APVRMDER'
                          and   wias.item_key = l_ItemKey ;
                    exception
                          when others then
                                  NULL;
                    end ;
                           If l_message_name = 'REL_ACCEPTANCE_REQUIRED' then
                                  l_progress := 'PO_APPROVAL_REMINDER_SV.Process_rel_acceptance: 10 - REL_ACCEPTANCE_REQUIRED';
                           IF (g_po_wf_debug = 'Y') THEN
                                 /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(l_itemtype,l_itemkey,l_progress);
                           END IF;
                           PO_APPROVAL_REMINDER_SV.Cancel_Notif (l_doc_type,
                                        l_doc_header_id,
                                        NULL);
                           WF_PURGE.ITEMS (l_ItemType,
                                          l_itemkey,
                          SYSDATE,
                          true,
                          true);
--bug 3896181 <end>
                PO_APPROVAL_REMINDER_SV.Start_Approval_Reminder (l_doc_header_id,
							  l_doc_number,
                                                          l_doc_type,
					                  l_doc_subtype,
							  l_release_num,
                                                          l_agent_id,
                                                          l_itemkey);
--bug 3896181 <start>
                 COMMIT;
                END IF; -- l_message_name = 'REL_ACCEPTANCE_REQUIRED'
              END IF; --  l_Item_end_date is not NULL
                END IF; -- trunc(l_acceptance_due_date) > trunc(sysdate)
             ELSE --  l_item_exist = 'Y'
                          l_progress := 'PO_APPROVAL_REMINDER_SV.Process_rel_acceptance: 11 - l_item_exists is N';
--bug 3896181 <end>
 	       IF (g_po_wf_debug = 'Y') THEN
    	       /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(l_itemtype,l_itemkey,l_progress);
 	       END IF;
--bug 3896181 <start>
    PO_APPROVAL_REMINDER_SV.Start_Approval_Reminder (l_doc_header_id,
                                                            l_doc_number,
                                                            l_doc_type,
                                                            l_doc_subtype,
                                                            l_release_num,
                                                            l_agent_id,
                                                            l_itemkey);

--bug 3896181 <end>
	       -- Commit the changes so that the notifications will be able
               -- to pickup the reminder notifications

               COMMIT;

             END IF;  --  l_item_exist = 'Y'

         END IF;   -- REL_acceptance%FOUND

   EXIT WHEN REL_acceptance%NOTFOUND;

   END LOOP;

   CLOSE REL_acceptance;

    l_progress := 'PO_APPROVAL_REMINDER_SV.Process_rel_acceptance: 900 - END ';
   IF (g_po_wf_debug = 'Y') THEN
      /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(l_itemtype,l_itemkey,l_progress);
   END IF;


    EXCEPTION
        WHEN NO_DATA_FOUND THEN
             wf_core.context ('PO_APPROVAL_REMINDER_SV','Process_rel_acceptance','No data found');
   	     l_progress := 'PO_APPROVAL_REMINDER_SV.Process_rel_acceptance: 901 - ' ||
 		           'EXCEPTION - no data found sql error: ' || sqlcode;
             IF (g_po_wf_debug = 'Y') THEN
                /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(l_itemtype,l_itemkey,l_progress);
             END IF;

        WHEN OTHERS THEN
             wf_core.context ('PO_APPROVAL_REMINDER_SV','Process_rel_acceptance','SQL error ' || sqlcode);
   	     l_progress := 'PO_APPROVAL_REMINDER_SV.Process_rel_acceptance: 990 - ' ||
 		           'EXCEPTION - sql error: ' || sqlcode;
             IF (g_po_wf_debug = 'Y') THEN
                /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(l_itemtype,l_itemkey,l_progress);
             END IF;


    RAISE;



 END Process_rel_acceptance;


/*===========================================================================
  PROCEDURE NAME:       Process_rfq_quote

  DESCRIPTION:
                        This procedure does the following:
                        - Open cursor PO_HEADERS table to select
                          RFQ and Quote documents.

                        - For each selected document, initiate the
                          PO Approval Reminder workflow notification.

  CHANGE HISTORY:       WLAU       11/15/1997     Created
===========================================================================*/

 PROCEDURE Process_rfq_quote IS

   -- Define cursor for selecting RFQ and Quote documents to start the Purchasing
   -- Approval Reminder workflow process.
   --
/* Bug# 1541123: kagarwal
** Desc: If the End_date for RFQ or Quotation is null
** then it means that the RFQ or Quote does not expire
** hence we need to change the nvl value of End_date
** to SYSDATE + 1.
**
** Also changing for Reply_date and RFQ_close_date
*/
/* Bug# 1764388: kagarwal
** Desc:  If the End_date for Quotation is null then it means that the Quote
** does not expire. In this case we should not consider the Quote_warning_delay
** in the CURSOR RFQ_QUOTE.
*/

   CURSOR RFQ_QUOTE IS
           SELECT PO_Header_ID,
		  Segment1,
		  Type_Lookup_Code,
		  Quote_type_lookup_code,
	          Agent_id,
	          Status_lookup_code,
	 	  NVL(Reply_date,SYSDATE + 1),
		  NVL(RFQ_close_date,SYSDATE + 1),
		  NVL(End_date,SYSDATE + 1),
		  decode(End_date, NULL, 0, NVL(Quote_warning_delay,0))
	          Quote_warning_delay
            FROM  PO_HEADERS
            WHERE NVL(Status_lookup_code,'I') IN ('I','A','P')
              AND type_lookup_code in ('RFQ','QUOTATION');
/*bug 9526568 Added Lookup code value P also to get for printed also*/

  l_doc_header_id       NUMBER;
  l_agent_id         	NUMBER;
  l_doc_type            VARCHAR2(25);
  l_doc_subtype         VARCHAR2(25);
  l_doc_number          VARCHAR2(25);
  l_release_num	        NUMBER := NULL;
  l_status_lookup_code  VARCHAR2(20);
  l_rfq_reply_date		DATE;
  l_rfq_close_date 		DATE;
  l_quote_end_date_active	DATE;
  l_quote_end_date_temp         DATE;
  l_quote_warning_delay		NUMBER;

  l_ItemType            VARCHAR2(100) := 'APVRMDER';
  l_itemkey             VARCHAR2(100) := NULL;

  l_item_exist          VARCHAR2(1);
  l_item_end_date	DATE;
  l_start_ntfn_wf_ok    VARCHAR2(1);

  l_progress            VARCHAR2(300) := NULL;

  BEGIN

   l_progress := 'PO_APPROVAL_REMINDER_SV.Process_rfq_quote: 01 - BEGIN ';
   IF (g_po_wf_debug = 'Y') THEN
      /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(l_itemtype,l_itemkey,l_progress);
   END IF;

   l_itemkey         := ' ';

   -- Select unapproved po documents and initiate
   -- Approval reminder workflow

   OPEN  RFQ_QUOTE;

   LOOP

        FETCH  RFQ_QUOTE into  l_doc_header_id,
       			       l_doc_number,
			       l_doc_type,
 			       l_doc_subtype,
			       l_agent_id,
			       l_status_lookup_code,
 			       l_rfq_reply_date,
		     	       l_rfq_close_date,
	  	     	       l_quote_end_date_active,
	       	               l_quote_warning_delay;


        -- Construct itemkey

         l_itemkey := l_doc_type ||
			 to_char(l_doc_header_id);


	-- Decide if a RFQ/Quotation notification workflow should be started

        l_start_ntfn_wf_ok := 'N';

 	IF l_status_lookup_code = 'I' THEN

           -- always start notification workflow if status is In_process
           l_start_ntfn_wf_ok := 'Y';

        ELSE

  	  IF l_doc_type = 'RFQ' THEN

	      -- check for RFQ date range
	      IF to_date(to_char(SYSDATE,'DD/MM/YYYY'),'DD/MM/YYYY') >=
	         to_date(to_char(l_rfq_reply_date,'DD/MM/YYYY'),'DD/MM/YYYY') AND
                 to_date(to_char(SYSDATE,'DD/MM/YYYY'),'DD/MM/YYYY') <=
                 to_date(to_char(l_RFQ_close_date,'DD/MM/YYYY'),'DD/MM/YYYY') THEN
                 l_start_ntfn_wf_ok := 'Y';

              END IF;



          ELSIF l_doc_type = 'QUOTATION' THEN


		l_quote_end_date_temp := l_quote_end_date_active - l_quote_warning_delay;


      		l_progress := 'PO_APPROVAL_REMINDER_SV.Process_rfq_quote: 02 - sysdate : '||
	  	    		to_char(SYSDATE,'DD/MM/YYYY');
      		--/* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(l_itemtype,l_itemkey,l_progress);


      		l_progress := 'PO_APPROVAL_REMINDER_SV.Process_rfq_quote: 02 - quote end date active : '||
	  			   to_char(l_quote_end_date_active,'DD/MM/YYYY');
      		--/* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(l_itemtype,l_itemkey,l_progress);

      		l_progress := 'PO_APPROVAL_REMINDER_SV.Process_rfq_quote: 02 - quote warning delay : '||
		   		l_quote_warning_delay;
      		--/* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(l_itemtype,l_itemkey,l_progress);


      		l_progress := 'PO_APPROVAL_REMINDER_SV.Process_rfq_quote: 02 - quote end date temp : '||
	  	   		to_char(l_quote_end_date_temp,'DD/MM/YYYY');
      		--/* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(l_itemtype,l_itemkey,l_progress);


	         -- check for Quotation date range
		IF to_date(to_char(SYSDATE,'DD/MM/YYYY'),'DD/MM/YYYY') <=
           	   to_date(to_char(l_quote_end_date_active,'DD/MM/YYYY'),'DD/MM/YYYY') AND
           	   to_date(to_char(SYSDATE,'DD/MM/YYYY'),'DD/MM/YYYY') >=
           	   to_date(to_char(l_quote_end_date_temp,'DD/MM/YYYY'),'DD/MM/YYYY') THEN

		   l_start_ntfn_wf_ok := 'Y';

      		   l_progress := 'PO_APPROVAL_REMINDER_SV.Process_rfq_quote: 02-set l_start_ntfn_wf_ok: '||
	  	                 l_start_ntfn_wf_ok;
      		   --/* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(l_itemtype,l_itemkey,l_progress);

 		END IF;

          ELSE

            l_start_ntfn_wf_ok := 'N';

          END IF;

       END IF;


      l_progress := 'PO_APPROVAL_REMINDER_SV.Process_rfq_quote: 03 - l_start_ntfn_wf_ok: '||
	  	   l_start_ntfn_wf_ok;
      IF (g_po_wf_debug = 'Y') THEN
         /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(l_itemtype,l_itemkey,l_progress);
      END IF;


      IF l_start_ntfn_wf_ok = 'Y' THEN

	 -- RFQ/Quotation notification workflow needs to be started

         IF  RFQ_QUOTE%FOUND THEN

            -- Call Workflow to check if the itemkey already exists
	    PO_APPROVAL_REMINDER_SV.item_exist (l_ItemType,
						l_ItemKey,
						l_Item_exist,
						l_Item_end_date);

            IF l_item_exist = 'Y' THEN

               -- Workflow item exists and is still opened
               -- Bypass this one

               NULL;

  	       l_progress := 'PO_APPROVAL_REMINDER_SV.Process_rfq_quote: 05 ' ||
			     'open WF item key exists ' ||l_itemkey;
	       -- /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(l_itemtype,l_itemkey,l_progress);

            ELSE
               -- Workflow item does not exist
               -- Invoke the Start_Approval_Reminder workflow
               -- for every unique workflow Item key.

  	       l_progress := 'PO_APPROVAL_REMINDER_SV.Process_rfq_quote: 10 ' ||
			       'Start WF item key =' ||l_itemkey;
	       IF (g_po_wf_debug = 'Y') THEN
   	       /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(l_itemtype,l_itemkey,l_progress);
	       END IF;

               PO_APPROVAL_REMINDER_SV.Start_Approval_Reminder (l_doc_header_id,
							  l_doc_number,
                                                          l_doc_type,
					                  l_doc_subtype,
						          l_release_num,
                                                          l_agent_id,
                                                          l_itemkey);


	       -- Commit the changes so that the notifications will be able
               -- to pickup the reminder notifications

               COMMIT;

             END IF;

         END IF;

       END IF;



   EXIT WHEN  RFQ_QUOTE%NOTFOUND;

   END LOOP;

   CLOSE  RFQ_QUOTE;


    l_progress := 'PO_APPROVAL_REMINDER_SV.Process_rfq_quote: 900 - END ';
   IF (g_po_wf_debug = 'Y') THEN
      /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(l_itemtype,l_itemkey,l_progress);
   END IF;


    EXCEPTION
        WHEN NO_DATA_FOUND THEN
             wf_core.context ('PO_APPROVAL_REMINDER_SV','Process_rfq_quote','No data found');
   	     l_progress := 'PO_APPROVAL_REMINDER_SV.Process_rfq_quote: 901 - ' ||
 		           'EXCEPTION - no data found sql error: ' || sqlcode;
             IF (g_po_wf_debug = 'Y') THEN
                /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(l_itemtype,l_itemkey,l_progress);
             END IF;

        WHEN OTHERS THEN
             wf_core.context ('PO_APPROVAL_REMINDER_SV','Process_rfq_quote','SQL error ' || sqlcode);
   	     l_progress := 'PO_APPROVAL_REMINDER_SV.Process_rfq_quote: 990 - ' ||
 		           'EXCEPTION - sql error: ' || sqlcode;
             IF (g_po_wf_debug = 'Y') THEN
                /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(l_itemtype,l_itemkey,l_progress);
             END IF;

    RAISE;



 END Process_rfq_quote;



/*===========================================================================
  PROCEDURE NAME:       Start_Approval_Reminder

  DESCRIPTION:          This procedure creates and starts the Approval Reminder
                        workflow process.

  CHANGE HISTORY:       WLAU       7/15/1997     Created
===========================================================================*/

  PROCEDURE Start_Approval_Reminder (p_doc_header_id            IN NUMBER,
				     p_doc_number 		IN VARCHAR2,
                                     p_doc_type                 IN VARCHAR2,
				     p_doc_subtype              IN VARCHAR2,
				     p_release_num	        IN NUMBER,
                                     p_agent_id                 IN NUMBER,
                                     p_WF_ItemKey               IN VARCHAR2) IS


  l_ItemType                    VARCHAR2(100) := 'APVRMDER';
  l_ItemKey                     VARCHAR2(100) := p_WF_ItemKey;

  l_agent_username              VARCHAR2(240);
  l_agent_disp_name             VARCHAR2(240);
  l_responsibility_id		NUMBER;
  l_application_id		NUMBER;
  l_progress            	VARCHAR2(300) := NULL;

  BEGIN

  	l_progress := 'PO_APPROVAL_REMINDER_SV.Start_Approval_Reminder: 01 ';
	IF (g_po_wf_debug = 'Y') THEN
   	/* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(l_itemtype,l_itemkey,l_progress);
	END IF;

	fnd_profile.get('RESP_ID', l_responsibility_id);
	fnd_profile.get('RESP_APPL_ID', l_application_id);
        wf_engine.createProcess     ( ItemType  => l_ItemType,
                                      ItemKey   => l_ItemKey,
                                      process   => 'PO_APPROVAL_REMINDER' );

	-- bug 852056:  Need to create RESP_ID and APPLICATION_ID
	wf_engine.AddItemAttr(	itemtype	=> l_itemtype,
				itemkey		=> l_itemkey,
				aname		=> 'RESP_ID');

	wf_engine.AddItemAttr(	itemtype	=> l_itemtype,
				itemkey		=> l_itemkey,
				aname		=> 'APPLICATION_ID');

        wf_engine.SetItemAttrNumber ( itemtype  => l_itemtype,
                                      itemkey   => l_itemkey,
                                      aname     => 'RESP_ID',
                                      avalue    => l_responsibility_id );

        wf_engine.SetItemAttrNumber ( itemtype  => l_itemtype,
                                      itemkey   => l_itemkey,
                                      aname     => 'APPLICATION_ID',
                                      avalue    => l_application_id );

        wf_engine.SetItemAttrNumber ( itemtype  => l_ItemType,
                                      itemkey   => l_itemkey,
                                      aname     => 'DOCUMENT_ID',
                                      avalue    => p_doc_header_id );

       wf_engine.SetItemAttrText   (  itemtype  => l_itemtype,
                                      itemkey   => l_itemkey,
                                      aname     => 'DOCUMENT_NUMBER',
                                      avalue    => p_doc_number );

       wf_engine.SetItemAttrText   (  itemtype  => l_itemtype,
                                      itemkey   => l_itemkey,
                                      aname     => 'DOCUMENT_TYPE',
                                      avalue    => p_doc_type );

       wf_engine.SetItemAttrText   (  itemtype  => l_itemtype,
                                      itemkey   => l_itemkey,
                                      aname     => 'DOCUMENT_SUBTYPE',
                                      avalue    => p_doc_subtype );

        wf_engine.SetItemAttrNumber ( itemtype  => l_ItemType,
                                      itemkey   => l_itemkey,
                                      aname     => 'RELEASE_REV_NUM',
                                      avalue    => p_release_num );


        wf_engine.SetItemAttrNumber ( itemtype  => l_ItemType,
                                      itemkey   => l_itemkey,
                                      aname     => 'AGENT_ID',
                                      avalue    => p_agent_id );


        /*** DEBUG
        wf_directory.GetUserName    ( p_orig_system    => 'PER',
                                      p_orig_system_id => p_agent_id,
                                      p_name           => l_agent_username,
                                      p_display_name   => l_agent_disp_name);
        ***/


       PO_REQAPPROVAL_INIT1.Get_User_Name (p_agent_id,
					  l_agent_username,
					  l_agent_disp_name);

        wf_engine.SetItemAttrText   ( itemtype  => l_itemtype,
                                      itemkey   => l_itemkey,
                                      aname     => 'AGENT_USER_NAME',
                                      avalue    => l_agent_username );

        wf_engine.SetItemAttrText   ( itemtype  => l_itemtype,
                                      itemkey   => l_itemkey,
                                      aname     => 'AGENT_DISP_NAME',
                                      avalue    => l_agent_disp_name );

       -- dbms_output.put_line ('Start_Approval_Reminder, agent username '|| l_agent_username);

       -- dbms_output.put_line ('Start_Approval_Reminder, agent dispname '|| l_agent_disp_name);
        wf_engine.StartProcess      ( ItemType  => l_ItemType,
                                      ItemKey   => l_ItemKey );

  	l_progress := 'PO_APPROVAL_REMINDER_SV.Start_Approval_Reminder: 900 ';
	IF (g_po_wf_debug = 'Y') THEN
   	/* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(l_itemtype,l_itemkey,l_progress);
	END IF;


    EXCEPTION

        WHEN OTHERS THEN
             wf_core.context ('PO_APPROVAL_REMINDER_SV','Start_Approval_Reminder','SQL error ' || sqlcode);
   	     l_progress := 'PO_APPROVAL_REMINDER_SV.Start_Approval_Reminder: 990 - ' ||
 		           'EXCEPTION - sql error: ' || sqlcode;
             IF (g_po_wf_debug = 'Y') THEN
                /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(l_itemtype,l_itemkey,l_progress);
             END IF;


    RAISE;



  END Start_Approval_Reminder;



/*===========================================================================
  PROCEDURE NAME:       Set Doc Type

  DESCRIPTION:


  CHANGE HISTORY:       WLAU       7/15/1997     Created
===========================================================================*/


  PROCEDURE Set_Doc_Type       (   itemtype        in varchar2,
                                   itemkey         in varchar2,
                                   actid           in number,
                                   funmode         in varchar2,
                                   result          out NOCOPY varchar2    ) IS


  l_doc_header_id       	NUMBER;
  l_doc_type                  	VARCHAR2(30);
  l_doc_type_temp               VARCHAR2(30);
  l_doc_subtype               	VARCHAR2(30);
  l_doc_type_lookup_code        VARCHAR2(30);
  l_doc_type_name		VARCHAR2(80);
  l_error_msg                   Varchar2(500);
  l_req_status		        Varchar2(25);

  l_can_change_forward_from_flag  VARCHAR2(25);
  l_can_change_forward_to_flag    VARCHAR2(25);
  l_can_change_approval_path      VARCHAR2(25);
  l_default_approval_path_id      NUMBER;
  l_can_preparer_approve_flag     VARCHAR2(25);
  l_can_approver_modify_flag      VARCHAR2(25);

  l_acceptance_past_due         VARCHAR2(25);
  l_acceptance_due_date    	DATE;
  l_rfq_reply_date		DATE;
  l_rfq_close_date 		DATE;
  l_quote_end_date_active	DATE;
  l_quote_warning_delay		NUMBER;
  l_status_lookup_code  	VARCHAR2(25);
  l_quote_lookup_code_type      VARCHAR2(25);
  l_quote_type_lookup_code      VARCHAR2(25);
  l_quote_type_disp		VARCHAR2(80);
  l_progress            	VARCHAR2(300) := NULL;

  BEGIN

    l_progress := 'PO_APPROVAL_REMINDER_SV.Set_Doc_Type: 01 ';
    IF (g_po_wf_debug = 'Y') THEN
       /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
    END IF;


    IF ( funmode = 'RUN'  ) THEN
        --
       -- dbms_output.put_line ('Set doc type ' ||ItemKey);


	l_doc_header_id :=
           wf_engine.GetItemAttrNumber ( itemtype  => ItemType,
                                         itemkey   => itemkey,
                                         aname     => 'DOCUMENT_ID');

        l_doc_type :=
           wf_engine.GetItemAttrText (  itemtype        => itemtype,
                                        itemkey         => itemkey,
                                        aname           => 'DOCUMENT_TYPE');
        l_doc_subtype :=
           wf_engine.GetItemAttrText (  itemtype        => itemtype,
                                        itemkey         => itemkey,
                                        aname           => 'DOCUMENT_SUBTYPE');


        -- Set l_doc_type_temp to be the same as l_doc_type
        -- DO NOT modify the l_doc_type

        l_doc_type_temp := l_doc_type;

        IF l_doc_type_temp = 'PO_ACCEPTANCE' THEN

            -- temporary set l_doc_type to 'PO','PA' for acceptance WF

            IF l_doc_subtype IN ('STANDARD','PLANNED') THEN
               l_doc_type_temp := 'PO';
            ELSIF l_doc_subtype IN ('BLANKET','CONTRACT') THEN
               l_doc_type_temp := 'PA';
            END IF;

        ELSIF l_doc_type_temp = 'REL_ACCEPTANCE' THEN

            l_doc_type_temp := 'RELEASE';

        END IF;

       -- Get doc type display name
       --
       l_doc_type_name := '';
       l_doc_type_lookup_code := '';

       PO_HEADERS_SV4.get_doc_type_lookup_code
		      (l_doc_type_temp,
                       l_doc_subtype,
		       l_doc_type_name,
                       l_doc_type_lookup_code);


        wf_engine.SetItemAttrText ( itemtype   => itemType,
                                 itemkey    => itemkey,
                                 aname      => 'DOC_TYPE_DISP' ,
                                 avalue     => l_doc_type_name);


       IF l_doc_type IN ('PO','PA','RELEASE','REQUISITION') THEN
	   -- Bug 6082842; Setting the NEVER_APPROVED_MSG attribute text to REQUIRES_APPROVAL_MSG text, since never approved msg is wrong.
	   -- Get has never been approved message
	   --fnd_message.set_name ('PO','PO_WF_NOTIF_NEVER_APPROVED');
           fnd_message.set_name ('PO','PO_WF_NOTIF_REQUIRES_APPROVAL');

           l_error_msg := fnd_message.get;

            wf_engine.SetItemAttrText ( itemtype   => itemType,
                                 itemkey    => itemkey,
                                 aname      => 'NEVER_APPROVED_MSG' ,
                                 avalue     => l_error_msg);


           -- Get requires approval message
           fnd_message.set_name ('PO','PO_WF_NOTIF_REQUIRES_APPROVAL');
           l_error_msg := fnd_message.get;

            wf_engine.SetItemAttrText ( itemtype   => itemType,
                                 itemkey    => itemkey,
                                 aname      => 'REQUIRES_APPROVAL_MSG' ,
                                 avalue     => l_error_msg);

	   -- Bug : 714491

	   If l_doc_type = 'REQUISITION' then

		select authorization_status into l_req_status
		from po_requisition_headers
		where requisition_header_id = l_doc_header_id;

		if NVL(l_req_status, 'INCOMPLETE') = 'RETURNED' then

           	    -- Get requisition returned approval message
           	    fnd_message.set_name ('PO','PO_WF_NOTIF_RETURNED');
           	    l_error_msg := fnd_message.get;

           	    wf_engine.SetItemAttrText ( itemtype   => itemType,
                                 	     itemkey    => itemkey,
                                 	     aname      => 'REQUISITION_RETURNED_MSG' ,
                                 	     avalue     => l_error_msg);

		elsif NVL(l_req_status, 'INCOMPLETE') = 'REJECTED' then

           	    -- Get requisition returned approval message
           	    fnd_message.set_name ('PO','PO_WF_NOTIF_REJECTED');
           	    l_error_msg := fnd_message.get;

           	    wf_engine.SetItemAttrText ( itemtype   => itemType,
                                 	     itemkey    => itemkey,
                                 	     aname      => 'REQUISITION_REJECTED_MSG' ,
                                 	     avalue     => l_error_msg);
		end if;


		-- Bug6082842
		-- Commenting out following piece of code. NEVER_APPROVED_MSG has been set
		-- with call to : PO_WF_PO_NOTIFICATION.GetDisplayValue above.
		-- And REQUIRES_APPROVAL_MSG is also taken care off above before we
                -- check if l_doc_type is REQUISITION.

		/*if NVL(l_req_status, 'INCOMPLETE') in ('RETURNED','REJECTED') then

            	    wf_engine.SetItemAttrText ( itemtype   => itemType,
                                 	        itemkey    => itemkey,
                                 	        aname      => 'NEVER_APPROVED_MSG' ,
                                 	        avalue     => '');

            	    wf_engine.SetItemAttrText ( itemtype   => itemType,
                                 	        itemkey    => itemkey,
                                 	        aname      => 'REQUIRES_APPROVAL_MSG' ,
                                 	        avalue     => '');
		end if;*/

	   end if;


           -- Set wrong forward to message to NULL until user enters
           -- an invalid forward to ID
           l_error_msg := '';

      	   wf_engine.SetItemAttrText ( itemtype   => itemType,
                                 itemkey    => itemkey,
                                 aname      => 'WRONG_FORWARD_TO_MSG' ,
                                 avalue     => '');

       END IF;


        IF l_doc_type IN ('PO_ACCEPTANCE','REL_ACCEPTANCE') THEN


           IF l_doc_type = 'PO_ACCEPTANCE' THEN

           	SELECT NVL(acceptance_due_date,SYSDATE)
             	INTO l_acceptance_due_date
             	FROM PO_HEADERS
            	WHERE po_header_id = l_doc_header_id;
           ELSE

           	SELECT NVL(acceptance_due_date, SYSDATE)
             	INTO l_acceptance_due_date
             	FROM PO_RELEASES
            	WHERE po_release_id = l_doc_header_id;
           END IF;

           IF l_acceptance_due_date is not NULL AND
              l_acceptance_due_date > SYSDATE THEN

              -- Acceptance is still active
              l_acceptance_past_due := 'N';

           ELSE

	      -- Acceptance is past due
  	      l_acceptance_past_due := 'Y';

	   END IF;

            wf_engine.SetItemAttrDate ( itemtype  => ItemType,
                                      itemkey   => itemkey,
                                      aname     => 'ACCEPTANCE_DUE_DATE',
                                      avalue    => l_acceptance_due_date );


            wf_engine.SetItemAttrText   (  itemtype  => itemtype,
                                      	itemkey   => itemkey,
                                      	aname     => 'ACCEPTANCE_PAST_DUE',
                                      	avalue    => l_acceptance_past_due );


        ELSIF l_doc_type IN ('RFQ','QUOTATION') THEN

     /* Bug 606396. Changed end_date_active to end_date */

   	      SELECT NVL(Reply_date,SYSDATE),
		     NVL(RFQ_close_date,SYSDATE),
		     NVL(End_date,SYSDATE),
		     NVL(Quote_warning_delay,0),
		     Status_lookup_code,
		     Quote_type_lookup_code
	        INTO l_rfq_reply_date,
		     l_rfq_close_date,
	  	     l_quote_end_date_active,
	       	     l_quote_warning_delay,
  		     l_status_lookup_code,
 		     l_quote_type_lookup_code
                FROM PO_HEADERS
               WHERE PO_HEADER_ID = l_doc_header_id;
            /*bug 9526568 if document printed then also we need to send notification */
               IF (NVL(l_status_lookup_code , 'I') = 'P') THEN
                 l_status_lookup_code := 'A';

               END IF;


	       l_quote_lookup_code_type := l_doc_type || ' SUBTYPE';
	       l_quote_type_disp  := '';

	       PO_HEADERS_SV4.get_lookup_code_dsp
			      (l_quote_lookup_code_type,
			       l_quote_type_lookup_code,
			       l_quote_type_disp);


        	wf_engine.SetItemAttrDate ( itemtype  => ItemType,
                                      itemkey   => itemkey,
                                      aname     => 'RFQ_REPLY_DATE',
                                      avalue    => l_rfq_reply_date );


        	wf_engine.SetItemAttrDate ( itemtype  => ItemType,
                                      itemkey   => itemkey,
                                      aname     => 'RFQ_CLOSE_DATE',
                                      avalue    => l_RFQ_close_date );


        	wf_engine.SetItemAttrDate ( itemtype  => ItemType,
                                      itemkey   => itemkey,
                                      aname     => 'QUOTE_END_DATE_ACTIVE',
                                      avalue    => l_quote_end_date_active );


        	wf_engine.SetItemAttrNumber ( itemtype  => ItemType,
                                      itemkey   => itemkey,
                                      aname     => 'QUOTE_WARNING_DELAY',
                                      avalue    => l_quote_warning_delay );

       	        wf_engine.SetItemAttrText   (  itemtype  => ItemType,
                                      itemkey   => Itemkey,
                                      aname     => 'RFQ_STATUS',
                                      avalue    => l_status_lookup_code );

       	        wf_engine.SetItemAttrText   (  itemtype  => ItemType,
                                      itemkey   => Itemkey,
                                      aname     => 'QUOTE_STATUS',
                                      avalue    => l_status_lookup_code );


       	        wf_engine.SetItemAttrText   (  itemtype  => ItemType,
                                      itemkey   => Itemkey,
                                      aname     => 'QUOTE_TYPE_DISP',
                                      avalue    => l_quote_type_disp );


        END IF;


        -- Set RESULT type

        RESULT := l_doc_type;

 	l_progress := 'PO_APPROVAL_REMINDER_SV.Set_Doc_Type: 05 RESULT ' ||
		      l_doc_type;
    	IF (g_po_wf_debug = 'Y') THEN
       	/* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
    	END IF;


   ELSIF ( funmode = 'CANCEL' ) THEN
        --
        null;
        --
   END IF;


    l_progress := 'PO_APPROVAL_REMINDER_SV.Set_Doc_Type: 900 ';
    IF (g_po_wf_debug = 'Y') THEN
       /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
    END IF;


    EXCEPTION
        WHEN NO_DATA_FOUND THEN
             wf_core.context ('PO_APPROVAL_REMINDER_SV','Set_Doc_Type','No data found');
   	     l_progress := 'PO_APPROVAL_REMINDER_SV.Set_Doc_Type: 901 - ' ||
 		           'EXCEPTION - no data found sql error: ' || sqlcode;
             IF (g_po_wf_debug = 'Y') THEN
                /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
             END IF;

        WHEN OTHERS THEN
             wf_core.context ('PO_APPROVAL_REMINDER_SV','Set_Doc_Type','SQL error ' || sqlcode);
   	     l_progress := 'PO_APPROVAL_REMINDER_SV.Set_Doc_Type: 990 - ' ||
 		           'EXCEPTION - sql error: ' || sqlcode;
             IF (g_po_wf_debug = 'Y') THEN
                /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
             END IF;


    RAISE;


  END Set_Doc_Type;


/*===========================================================================
  PROCEDURE NAME:       Start Document Approval Workflow

  DESCRIPTION:


  CHANGE HISTORY:       WLAU       7/15/1997     Created
===========================================================================*/


  PROCEDURE Start_Doc_Approval  (  itemtype        in varchar2,
                                   itemkey         in varchar2,
                                   actid           in number,
                                   funmode         in varchar2,
                                   result          out NOCOPY varchar2    ) IS


  l_ActionOriginatedFrom        VARCHAR2(30):= 'REMIND_NOTIF';
  l_PreparerID                  NUMBER;
  l_ResponsibilityID		NUMBER;
  l_ApplicationID		NUMBER;
  l_DocumentNumber	        VARCHAR2(60);
  l_DocumentID	                NUMBER;
  l_DocumentTypeCode            VARCHAR2(30);
  l_DocumentSubtype             VARCHAR2(60);
  l_DocumentStatus              VARCHAR2(60):= NULL;
  l_RequestorAction             VARCHAR2(60):= 'APPROVE';
  l_forwardToID                 NUMBER 	  := NULL;
  l_forwardFromID               NUMBER      := NULL;
  l_DefaultApprovalPathID       NUMBER      := NULL;
  l_Note			VARCHAR2(240);
  l_progress            	VARCHAR2(300) := NULL;

  BEGIN

    l_progress := 'PO_APPROVAL_REMINDER_SV.Start_Doc_Approval: 01 ';
    IF (g_po_wf_debug = 'Y') THEN
       /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
    END IF;


    IF ( funmode = 'RUN'  ) THEN
        --

       -- dbms_output.put_line ('Start Doc Approval ' ||ItemKey);

	-- bug 852056:  While responding to notification through the WEB
	-- user context is lost.  So need pass responsibility_id and
	-- application_id through workflow attributes.

	l_ResponsibilityID :=
	   wf_engine.GetItemAttrNumber (itemtype	=> itemtype,
					itemkey		=> itemkey,
					aname		=> 'RESP_ID');

	l_ApplicationID :=
	   wf_engine.GetItemAttrNumber (itemtype	=> itemtype,
					itemkey		=> itemkey,
					aname		=> 'APPLICATION_ID');

        l_DocumentTypeCode :=
           wf_engine.GetItemAttrText (  itemtype        => itemtype,
                                        itemkey         => itemkey,
                                        aname           => 'DOCUMENT_TYPE');

	l_DocumentSubtype :=
           wf_engine.GetItemAttrText (  itemtype        => itemtype,
                                        itemkey         => itemkey,
                                        aname           => 'DOCUMENT_SUBTYPE');
 	l_DocumentNumber :=
           wf_engine.GetItemAttrText (  itemtype        => itemtype,
                                        itemkey         => itemkey,
                                        aname           => 'DOCUMENT_NUMBER');
	l_DocumentID :=
           wf_engine.GetItemAttrNumber ( itemtype  => ItemType,
                                      itemkey   => itemkey,
                                      aname     => 'DOCUMENT_ID');


 	l_PreparerID :=
           wf_engine.GetItemAttrNumber ( itemtype  => ItemType,
                                      itemkey   => itemkey,
                                      aname     => 'AGENT_ID');


 	l_forwardToID :=
           wf_engine.GetItemAttrNumber ( itemtype  => ItemType,
                                      itemkey   => itemkey,
                                      aname     => 'FORWARD_TO_ID');

 	l_forwardFromID :=
           wf_engine.GetItemAttrNumber ( itemtype  => ItemType,
                                      itemkey   => itemkey,
                                      aname     => 'FORWARD_FROM_ID');


        l_Note :=
           wf_engine.GetItemAttrText (  itemtype        => itemtype,
                                        itemkey         => itemkey,
                                        aname           => 'NOTE');


/*** DEBUG
	l_DefaultApprovalPathID :=
           wf_engine.GetItemAttrNumber ( itemtype  => ItemType,
                                      itemkey   => itemkey,
                                      aname     => 'DEFAULT_APPROVAL_PATH_ID');
***/



        -- Submit the document for approval to the workflow, passing it the
        -- appropriate arguments.
        -- Note that there are different workflows for PO, Change Order, and
        -- Requisition. We call the appropriate one depending upon the document
        -- type.

        -- Setting up common parameters for the call to WF.

        -- ActionOriginatedFrom  := 'REMIND_NOTIF';


	/*** DEBUG for future only
        IF l_DocumentTypeCode = 'REQUISITION' THEN

                -- Setup Requisition approval request to WF.

        ELSIF l_DocumentTypeCode IN ('PO', 'PA') THEN

                -- Setup PO / CHANGE ORDER approval request to WF.

        ELSIF l_DocumentTypeCode = 'RELEASE' THEN

                -- Setup RELEASE approval request to WF.

        ELSE
                RESULT := 'FAILED';

        END IF;
	***/

        -- Submit to PO APPROVAL work flow.

          SetUpWorkFlow ( l_ActionOriginatedFrom,
                          l_DocumentID,
                          l_DocumentNumber,
                          l_PreparerID,
			  l_ResponsibilityID,
			  l_ApplicationID,
                          l_DocumentTypeCode,
                          l_DocumentSubtype,
                          l_RequestorAction,
                          l_ForwardToID,
                          l_ForwardFromID,
                          l_DefaultApprovalPathID,
                          l_DocumentStatus,
			  l_Note );


        --
   ELSIF ( funmode = 'CANCEL' ) THEN
        --
        null;
        --
   END IF;


    l_progress := 'PO_APPROVAL_REMINDER_SV.Start_Doc_Approval: 900 - END ';
    IF (g_po_wf_debug = 'Y') THEN
       /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
    END IF;


    EXCEPTION
        WHEN NO_DATA_FOUND THEN
             wf_core.context ('PO_APPROVAL_REMINDER_SV','Start_Doc_Approval','No data found');
  	     l_progress := 'PO_APPROVAL_REMINDER_SV.Start_Doc_Approval: 901 - ' ||
 		           'EXCEPTION - no data found sql error: ' || sqlcode;
             IF (g_po_wf_debug = 'Y') THEN
                /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
             END IF;


        WHEN OTHERS THEN
             wf_core.context ('PO_APPROVAL_REMINDER_SV','Start_Doc_Approval','SQL error ' || sqlcode);
  	     l_progress := 'PO_APPROVAL_REMINDER_SV.Start_Doc_Approval: 990 - ' ||
 		           'EXCEPTION - sql error: ' || sqlcode;
             IF (g_po_wf_debug = 'Y') THEN
                /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,l_progress);
             END IF;


    RAISE;


  END Start_Doc_Approval;


/*===========================================================================
  PROCEDURE NAME:       SetUpWorkFlow

  DESCRIPTION:


  CHANGE HISTORY:       WLAU       7/15/1997     Created
===========================================================================*/

PROCEDURE SetUpWorkFlow ( p_ActionOriginatedFrom   IN varchar2,
                          p_DocumentID             IN number,
                          p_DocumentNumber         IN varchar2,
                          p_PreparerID             IN number,
			  p_ResponsibilityID	   IN number,
			  p_ApplicationID	   IN number,
                          p_DocumentTypeCode       IN varchar2,
                          p_DocumentSubtype        IN varchar2,
                          p_RequestorAction        IN varchar2,
                          p_ForwardToID            IN number ,
                          p_ForwardFromID          IN number,
                          p_DefaultApprovalPathID  IN number,
                          p_DocumentStatus         IN varchar2,
			  p_Note                   IN varchar2) IS

        l_seq			 VARCHAR2(25); --Bug14305923
        l_ItemType               VARCHAR2(8);
        l_ItemKey                VARCHAR2(240) := NULL;
        l_WorkflowProcess        VARCHAR2(80);
        l_orgid 	         NUMBER;
        l_user_id 	         NUMBER;
  	l_progress            	 VARCHAR2(300) := NULL;

	/* Bug 2780033 */
	l_document_num        po_headers_all.segment1%type;
	l_default_method      PO_VENDOR_SITES.SUPPLIER_NOTIF_METHOD%TYPE  := null;
	l_emailaddress     po_vendor_sites.email_Address%type := null;
	l_faxnum        varchar2(30) := null;   --Bug 5765243
	l_emailflag          varchar2(1) := 'N';
	l_faxflag          varchar2(1) := 'N';
	l_printflag          varchar2(1) := 'N';
	l_preparerid     po_headers.agent_id%type;

        Cursor get_user_id is
        select user_id
        from fnd_user
        where employee_id =  p_PreparerID;

/* RETROACTIVE FPI START */
l_can_change_forward_from_flag
                po_document_types.can_change_forward_from_flag%type;
l_can_change_forward_to_flag po_document_types.can_change_forward_to_flag%type;
l_can_change_approval_path po_document_types.can_change_approval_path_flag%type;
l_can_preparer_approve_flag po_document_types.can_preparer_approve_flag%type;
l_default_approval_path_id po_document_types.default_approval_path_id%type;
l_can_approver_modify_flag po_document_types.can_approver_modify_doc_flag%type;
l_forwarding_mode_code po_document_types.forwarding_mode_code%type;
l_type_name po_document_types.type_name%type;

/* RETROACTIVE FPI END */

BEGIN

       l_progress := 'PO_APPROVAL_REMINDER_SV.SetUpWorkFlow: 01 ' ||
                     p_DocumentTypeCode  || p_DocumentSubtype ||  p_DocumentNumber;
       IF (g_po_wf_debug = 'Y') THEN
          /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug('APVRMDER',NULL,l_progress);
       END IF;


        PO_REQAPPROVAL_INIT1.get_multiorg_context (p_DocumentTypeCode, p_DocumentID, l_orgid);

        IF l_orgid is NOT NULL THEN

           PO_MOAC_UTILS_PVT.set_org_context(l_orgid) ;       -- <R12 MOAC>

        END IF;


        select to_char(PO_WF_ITEMKEY_S.nextval) into l_seq from sys.dual;

        -- Bug 3240928 start
        -- The itemkey should be p_DocumentID  - l_seq. If we use the colon the
        -- approval notification functions fail when doing the substr
        l_ItemKey := to_char(p_DocumentID) || '-' || l_seq;
        -- Bug 3240928 end

/* Bug# 1691814: kagarwal
** Desc: Changed PO_DOCUMENT_TYPES_V to PO_DOCUMENT_TYPES to improve
** the perfomance of the SQL.
*/
	/* Bug 2780033.
	 * We need to get the default communication method and
	 * send it to start_wf_process. We do this when we approve the
	 * document from the approval window in the PO form. We need
	 * to do the same from here also. Now we will get email or
	 * document will get printed depending on the setup when we
	 * we approve the document from the Notification Summary screen.
	*/
       l_progress := 'PO_APPROVAL_REMINDER_SV.SetUpWorkFlow: 02 ' ||
                        p_DocumentTypeCode  || p_DocumentSubtype ||
			p_DocumentNumber;
             IF (g_po_wf_debug = 'Y') THEN
              PO_WF_DEBUG_PKG.insert_debug('POXWARMB',NULL,l_progress);
             END IF;

	PO_VENDOR_SITES_SV.Get_Transmission_Defaults(
                                        p_document_id => p_DocumentID,
                                        p_document_type => p_DocumentTypeCode,
                                        p_document_subtype => p_DocumentSubtype,
                                        p_preparer_id => l_PreparerID,
                                        x_default_method => l_default_method,
                                        x_email_address => l_emailaddress,
                                        x_fax_number => l_faxnum,
                                        x_document_num => l_document_num);

	If (l_default_method = 'EMAIL' ) and (l_emailaddress is not null) then
            l_emailflag := 'Y';
            l_faxnum := null;
        elsif  l_default_method  = 'FAX'  and (l_faxnum is not null) then
            l_emailaddress := null;

            l_faxflag := 'Y';
        elsif  l_default_method  = 'PRINT' then
            l_emailaddress := null;
            l_faxnum := null;

            l_printflag := 'Y';
        else
            l_emailaddress := null;
            l_faxnum := null;
        end if;
	/* Bug 2780033 End */


        /* RETROACTIVE FPI START.
	 * Deleted the sql query which selected wf_approval_itemtype and
	 * wf_approval_process from PO_DOCUMENT_TYPES. Instead call the
	 * new overloaded procedure po_approve_sv.get_document_types.
	 * We call this here even though this is called in start_wf_process
	 * since we need these values to set some workflow attributes
	 * before we call start_Wf_process.
	*/

	       l_progress := 'PO_APPROVAL_REMINDER_SV.SetUpWorkFlow: 03 ' ||
                        p_DocumentTypeCode  || p_DocumentSubtype ||
			p_DocumentNumber;
             IF (g_po_wf_debug = 'Y') THEN
              PO_WF_DEBUG_PKG.insert_debug('POXWARMB',NULL,l_progress);
             END IF;
	 po_approve_sv.get_document_types(
                p_document_type_code           => p_DocumentTypeCode,
                p_document_subtype             => p_DocumentSubtype,
                x_can_change_forward_from_flag =>l_can_change_forward_from_flag,
                x_can_change_forward_to_flag   => l_can_change_forward_to_flag,
                x_can_change_approval_path     => l_can_change_approval_path,
                x_default_approval_path_id     => l_default_approval_path_id,
                x_can_preparer_approve_flag    => l_can_preparer_approve_flag,
                x_can_approver_modify_flag     => l_can_approver_modify_flag,
                x_forwarding_mode_code         => l_forwarding_mode_code,
                x_wf_approval_itemtype         => l_itemtype,
                x_wf_approval_process          => l_workflowprocess,
                x_type_name                    => l_type_name);

		/* RETROACTIVE FPI END */



	/* Bug#2531926: kagarwal
	** Desc: The user id and not the prepaper id (employee id) should be
	** populated in the USER_ID attribute of Approval workflow and also for setting
	** apps context we should use the user id.
	**
	** The prepaper id (employee id) is not the same as user id.
	*/

		/* User Id should not be null */
		open get_user_id;
		fetch get_user_id into l_user_id;
		close get_user_id;

		-- bug 852056:  Need to create process here, and then set
		-- attributes: USER_ID, RESPONSIBILITY_ID, and APPLICATION_ID
		-- also need to initialize fnd_global
		wf_engine.CreateProcess	( ItemType	=> l_ItemType,
					  ItemKey	=> l_ItemKey,
					  process	=> l_WorkflowProcess);

		wf_engine.SetItemAttrNumber (	ItemType => l_ItemType,
						ItemKey  => l_ItemKey,
						aname	 => 'USER_ID',
						avalue   => l_user_id);

		wf_engine.SetItemAttrNumber (	ItemType => l_ItemType,
						ItemKey  => l_ItemKey,
						aname	 => 'RESPONSIBILITY_ID',
						avalue   => p_ResponsibilityID);

		wf_engine.SetItemAttrNumber (	ItemType => l_ItemType,
						ItemKey  => l_ItemKey,
						aname	 => 'APPLICATION_ID',
						avalue   => p_ApplicationID);

		-- Bug 4290541, replaced apps init call with set doc mgr context
		PO_REQAPPROVAL_INIT1.Set_doc_mgr_context(l_itemtype, l_itemkey);

		/* Bug 2780033.
		 * Add the communication flags to the call to
		 * start_wf_process below.
		*/
	       l_progress := 'PO_APPROVAL_REMINDER_SV.SetUpWorkFlow: 04 ' ||
                        p_DocumentTypeCode  || p_DocumentSubtype ||
			p_DocumentNumber;
               IF (g_po_wf_debug = 'Y') THEN
                 PO_WF_DEBUG_PKG.insert_debug('POXWARMB',NULL,l_progress);
               END IF;
		PO_REQAPPROVAL_INIT1.Start_WF_Process ( ItemType     => l_ItemType,
					       ItemKey               => l_ItemKey,
					       WorkflowProcess       => l_WorkflowProcess,
					       ActionOriginatedFrom  => p_ActionOriginatedFrom,
					       DocumentID            => p_DocumentID,
					       DocumentNumber        => p_DocumentNumber,
					       PreparerID            => p_PreparerID,
					       DocumentTypeCode      => p_DocumentTypeCode,
					       DocumentSubtype       => p_DocumentSubtype,
					       SubmitterAction       => p_RequestorAction,
					       forwardToID           => p_forwardToID,
					       forwardFromID         => p_forwardFromID,
					       DefaultApprovalPathID => p_DefaultApprovalPathID,
					       Note                  => p_Note,
					       PrintFlag => l_printflag,
					       FaxFlag => l_faxflag,
					       FaxNumber => l_faxnum,
					       EmailFlag => l_emailflag,
					       EmailAddress => l_emailaddress);


	       l_progress := 'PO_APPROVAL_REMINDER_SV.SetUpWorkFlow: 900 ' ||
			    p_DocumentTypeCode  || p_DocumentSubtype ||  p_DocumentNumber;
	       IF (g_po_wf_debug = 'Y') THEN
		  /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug('APVRMDER',l_itemkey,l_progress);
	       END IF;



	EXCEPTION

	  WHEN OTHERS THEN
		wf_core.context ('PO_APPROVAL_REMINDER_SV','SetUpWorkFlow','SQL error ' || sqlcode);
		     l_progress := 'PO_APPROVAL_REMINDER_SV.SetUpWorkFlow: 990 - ' ||
				   'EXCEPTION - sql error: ' || sqlcode;
		     IF (g_po_wf_debug = 'Y') THEN
			/* DEBUG */  PO_WF_DEBUG_PKG.insert_debug('APVRMDER',l_itemkey,l_progress);
		     END IF;

	  RAISE;


	END SetUpWorkFlow ;  -- PROCEDURE SetUpWorkFlow

	/*===========================================================================
	  PROCEDURE NAME:       Is_Forward_To_Valid

	  DESCRIPTION:


	  CHANGE HISTORY:       WLAU       8/20/1997     Created
	===========================================================================*/

	procedure Is_Forward_To_Valid(  itemtype        in varchar2,
					itemkey         in varchar2,
					actid           in number,
					funcmode        in varchar2,
					resultout       out NOCOPY varchar2    ) is

	x_user_id         number;
	l_approver_empid  number;
	l_forward_to_username_response varchar2(100);
	l_forward_to_username          varchar2(100);
	l_forward_to_username_disp     varchar2(240);
	l_forward_to_id                number;
	l_error_msg                    varchar2(500);
	x_progress  varchar2(300);


	BEGIN

	  x_progress := 'PO_APPROVAL_REMINDER_SV.Is_Forward_To_Valid: 01';
	  IF (g_po_wf_debug = 'Y') THEN
	     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
	  END IF;


	  -- Do nothing in cancel or timeout mode
	  --
	  if (funcmode <> wf_engine.eng_run) then

	      resultout := wf_engine.eng_null;
	      return;

	  end if;

	  /* Check that the value entered by responder as the FORWARD-TO user, is actually
	  ** a valid employee (has an employee id).
	  ** If valid, then set the FORWARD-FROM USERNAME and ID from the old FORWARD-TO.
	  ** Then set the Forward-To to the one the user entered in the response.
	  */
	  /* NOTE: We take the value entered by the user and set it to ALL CAPITAL LETTERS!!!
	  */
	  l_forward_to_username_response := wf_engine.GetItemAttrText (itemtype => itemtype,
						 itemkey  => itemkey,
						 aname    => 'FORWARD_TO_USERNAME_RESPONSE');

	  l_forward_to_username_response := UPPER(l_forward_to_username_response);

	  x_progress := 'PO_APPROVAL_REMINDER_SV.Is_Forward_To_Valid: 02';
	  x_progress := x_progress || ' Forward-To=' || l_forward_to_username_response;
	  IF (g_po_wf_debug = 'Y') THEN
	     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
	  END IF;

	  IF  l_forward_to_username_response is NULL THEN

	      -- NULL is a valid case in the remainder process
	      --
	      resultout := wf_engine.eng_completed || ':' ||  'Y';
	      --

	  ELSIF  PO_REQAPPROVAL_FINDAPPRV1.CheckForwardTo(l_forward_to_username_response,
						       x_user_id) = 'Y' THEN

	     /* The FORWARD-FROM is now the old FORWARD-TO and the NEW FORWARD-TO is set
	     ** to what the user entered in the response
	     */

	     l_forward_to_username:= wf_engine.GetItemAttrText (itemtype => itemtype,
						 itemkey  => itemkey,
						 aname    => 'FORWARD_TO_USERNAME');

	     l_forward_to_username_disp:= wf_engine.GetItemAttrText (itemtype => itemtype,
						 itemkey  => itemkey,
						 aname    => 'FORWARD_TO_DISPLAY_NAME');

	     l_forward_to_id:= wf_engine.GetItemAttrNumber (itemtype => itemtype,
						 itemkey  => itemkey,
						 aname    => 'FORWARD_TO_ID');
	     /* Set the FORWARD_FROM */
	     wf_engine.SetItemAttrNumber (     itemtype        => itemtype,
						itemkey         => itemkey,
						aname           => 'FORWARD_FROM_ID',
						avalue          =>  l_forward_to_id);

	     wf_engine.SetItemAttrText (     itemtype        => itemtype,
						itemkey         => itemkey,
						aname           => 'FORWARD_FROM_USER_NAME',
						avalue          =>  l_forward_to_username);

	     wf_engine.SetItemAttrText (     itemtype        => itemtype,
						itemkey         => itemkey,
						aname           => 'FORWARD_FROM_DISP_NAME',
						avalue          =>  l_forward_to_username_disp);

	     /* Set the FORWARD-TO */

	     wf_engine.SetItemAttrText (     itemtype        => itemtype,
						itemkey         => itemkey,
						aname           => 'FORWARD_TO_USERNAME',
						avalue          =>  l_forward_to_username_response);

	     wf_engine.SetItemAttrNumber ( itemtype   => itemType,
					   itemkey    => itemkey,
					   aname      => 'FORWARD_TO_ID',
					   avalue     => x_user_id);

	    /* Get the Display name for the user from the WF Directory  */
	    wf_engine.SetItemAttrText ( itemtype        => itemtype,
				itemkey         => itemkey,
				aname           => 'FORWARD_TO_DISPLAY_NAME',
				avalue          =>
				wf_directory.GetRoleDisplayName(l_forward_to_username_response));

	    /* Reset the FORWARD_TO_USERNAME_RESPONSE attribute */
	    wf_engine.SetItemAttrText (itemtype => itemtype,
						 itemkey  => itemkey,
						 aname    => 'FORWARD_TO_USERNAME_RESPONSE',
						 avalue   => NULL);



	     /* Set the Subject of the Approval notification to "requires your approval".
	     ** Since the user entered a valid forward-to, then set the
	     ** "Invalid Forward-to" message to NULL.
	     */
	     fnd_message.set_name ('PO','PO_WF_NOTIF_REQUIRES_APPROVAL');
	     l_error_msg := fnd_message.get;

	     wf_engine.SetItemAttrText ( itemtype   => itemType,
					 itemkey    => itemkey,
					 aname      => 'REQUIRES_APPROVAL_MSG' ,
					 avalue     => l_error_msg);


	     wf_engine.SetItemAttrText ( itemtype        => itemtype,
					 itemkey         => itemkey,
					 aname           => 'WRONG_FORWARD_TO_MSG',
					 avalue          =>  NULL);

	    --
	    resultout := wf_engine.eng_completed || ':' ||  'Y';
	    --

	  ELSE


	     /* Set the error message that will be shown to the user in the ERROR MESSAGE
	     ** Field in the Notification.
	     */

	     /* Set the Subject of the Approval notification to "Invalid forward-to"
	     ** Since the user entered an invalid forward-to, then set the
	     ** "requires your approval" message to NULL.
	     */
	     fnd_message.set_name ('PO','PO_WF_NOTIF_INVALID_FORWARD');
	     l_error_msg := fnd_message.get;

	     wf_engine.SetItemAttrText ( itemtype   => itemType,
					 itemkey    => itemkey,
					 aname      => 'REQUIRES_APPROVAL_MSG' ,
					 avalue     => '');

	     wf_engine.SetItemAttrText ( itemtype   => itemType,
					 itemkey    => itemkey,
					 aname      => 'WRONG_FORWARD_TO_MSG' ,
					 avalue     => l_error_msg);

	    --
	    resultout := wf_engine.eng_completed || ':' ||  'N';
	    --

	  END IF;


	  x_progress := 'PO_APPROVAL_REMINDER_SV.Is_Forward_To_Valid: 900';
	  IF (g_po_wf_debug = 'Y') THEN
	     /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
	  END IF;


	EXCEPTION

	  WHEN OTHERS THEN
		wf_core.context ('PO_APPROVAL_REMINDER_SV','Is_Forward_To_Valid','SQL error ' || sqlcode);
		x_progress := 'PO_APPROVAL_REMINDER_SV.Is_Forward_To_Valid: 990 - ' ||
			      'EXCEPTION - sql error: ' || sqlcode;
		IF (g_po_wf_debug = 'Y') THEN
		   /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(itemtype,itemkey,x_progress);
		END IF;


	  RAISE;


	END Is_Forward_To_Valid  ;

	/*===========================================================================
	  PROCEDURE NAME:       Cancel_Notif

	  DESCRIPTION:


	  CHANGE HISTORY:       HVADLAMU       8/20/1997     Created
	===========================================================================*/
	PROCEDURE  Cancel_Notif ( p_DocumentTypeCode       IN varchar2,
				  p_DocumentID		   IN number,
				  p_ReleaseFlag            IN varchar2 ) IS

	l_itemtype             VARCHAR2(100) := 'APVRMDER';
	l_itemkey              VARCHAR2(100);
	l_agent_id 	       NUMBER;
	l_notif_id             NUMBER;
	l_doc_type             VARCHAR2(25);
	l_doc_subtype          VARCHAR2(25);
	act_status             VARCHAR2(8);
	x_progress	       VARCHAR2(100) := '001';
	l_acceptance_due_date  DATE;

        --Bug 5500222
        --If the buyer on the PO is changed and then cancel_notif is called,
        --we want to make sure that the reminder notification with new item key
        --is aborted correctly.
	 Cursor  cand_active_wf(l_itemkey VARCHAR2) IS
	  select wias.activity_status_code, wias.item_key
            from wf_item_activity_statuses_v wias, wf_items_v wi
           where wias.item_type = 'APVRMDER'
             and wias.item_key like l_itemkey||'%'
             and wias.item_type     = wi.item_type
             and wias.item_key      = wi.item_key
             and wias.activity_name = wi.root_activity;

	BEGIN
	   l_doc_subtype := p_DocumentTypeCode;
	  if ((p_DocumentTypeCode = 'STANDARD') or (p_DocumentTypeCode = 'PLANNED')) then

	     x_progress := 'PO_APPROVAL_REMINDER_SV.cancel_notif-001';

	      l_doc_type  := 'PO';

	      select agent_id
	      into   l_agent_id
	      from   po_headers_all      /*Bug6632095: using base table instead of view */
	      where  po_header_id = p_DocumentID;
         --bug#3709971 modified the structure of item key from
	 --doc_type||doc_subtype||doc_num||agent_id(old structure) to
	 --doc_type||'-'||doc_subtype||'-'||doc_num||'-'||agent_id

         --Bug 5500222 : do not append the agent to the item key
	      l_itemkey :=    l_doc_type ||'-'||
				 l_doc_subtype ||'-'||
				 to_char(p_DocumentId) ||'-';

             For rec in cand_active_wf(l_itemkey) LOOP
	       if (po_approval_reminder_sv.is_active('APVRMDER',rec.item_key)) then
	         WF_Engine.AbortProcess('APVRMDER',rec.item_key);
	       end if;
	     End Loop;

	  elsif ((p_DocumentTypeCode = 'BLANKET') or (p_DocumentTypeCode = 'CONTRACT')) then


	   if (p_ReleaseFlag = 'Y') then  /* the doc_type must be RELEASE */

	     x_progress := 'PO_APPROVAL_REMINDER_SV.cancel_notif-002';

	      l_doc_type := 'RELEASE';

	      select agent_id
	      into   l_agent_id
	      from   po_releases_all     /*Bug6632095: using base table instead of view */
	      where  po_release_id = p_DocumentID;

         --bug#3709971 modified the structure of item key from
	 --doc_type||doc_subtype||doc_num||agent_id(old structure) to
	 --doc_type||'-'||doc_subtype||'-'||doc_num||'-'||agent_id

	      l_itemkey :=    l_doc_type ||'-'||
				 l_doc_subtype ||'-'||
				 to_char(p_DocumentId) ||'-'||
				 to_char(l_agent_id);
	    else

	      x_progress := 'PO_APPROVAL_REMINDER_SV.cancel_notif-003';

	      l_doc_type := 'PA';

	      select agent_id
	      into   l_agent_id
	      from   po_headers_all      /*Bug6632095: using base table instead of view */
	      where  po_header_id = p_DocumentID;
         --bug#3709971 modified the structure of item key from
	 --doc_type||doc_subtype||doc_num||agent_id(old structure) to
	 --doc_type||'-'||doc_subtype||'-'||doc_num||'-'||agent_id

	      l_itemkey :=    l_doc_type ||'-'||
				 l_doc_subtype ||'-'||
				 to_char(p_DocumentId) ||'-'||
				 to_char(l_agent_id);
	   end if;
	      if (po_approval_reminder_sv.is_active('APVRMDER',l_itemkey)) then
		     WF_Engine.AbortProcess('APVRMDER',l_itemkey);
	     end if;



	 elsif ((p_DocumentTypeCode = 'INTERNAL') or (p_DocumentTypeCode = 'PURCHASE')) then

	      x_progress := 'PO_APPROVAL_REMINDER_SV.cancel_notif-004';

	      l_doc_type := 'REQUISITION';

	      select preparer_id
	      into   l_agent_id
	      from   po_requisition_headers
	      where  requisition_header_id = p_DocumentID;
         --bug#3709971 modified the structure of item key from
	 --doc_type||doc_subtype||doc_num||agent_id(old structure) to
	 --doc_type||'-'||doc_subtype||'-'||doc_num||'-'||agent_id

	      l_itemkey :=    l_doc_type ||'-'||
				 l_doc_subtype ||'-'||
				 to_char(p_DocumentId) ||'-'||
				 to_char(l_agent_id);

		if (po_approval_reminder_sv.is_active('APVRMDER',l_itemkey)) then
		     WF_Engine.AbortProcess('APVRMDER',l_itemkey);
	     end if;

	elsif (p_DocumentTypeCode = 'SCHEDULED') then

	      x_progress := 'PO_APPROVAL_REMINDER_SV.cancel_notif-005';

	      l_doc_type := 'RELEASE';

	      select agent_id
	      into   l_agent_id
	      from   po_releases_all      /*Bug6632095: using base table instead of view */
	      where  po_release_id = p_DocumentID;
         --bug#3709971 modified the structure of item key from
	 --doc_type||doc_subtype||doc_num||agent_id(old structure) to
	 --doc_type||'-'||doc_subtype||'-'||doc_num||'-'||agent_id

	      l_itemkey :=    l_doc_type ||'-'||
				 l_doc_subtype ||'-'||
				 to_char(p_DocumentId) ||'-'||
				 to_char(l_agent_id);

		    if (po_approval_reminder_sv.is_active('APVRMDER',l_itemkey)) then
			  WF_Engine.AbortProcess('APVRMDER',l_itemkey);
		     end if;
	elsif  (p_DocumentTypeCode = 'PO_ACCEPTANCE') then

	      x_progress := 'PO_APPROVAL_REMINDER_SV.cancel_notif-006';

	      l_doc_type := 'PO_ACCEPTANCE';

	      select type_lookup_code
	      into   l_doc_subtype
	      from   po_headers_all      /*Bug6632095: using base table instead of view */
	      where  po_header_id = p_DocumentID;
         --bug#3709971 modified the structure of item key from
	 --doc_type||doc_subtype||doc_num(old structure) to
	 --doc_type||'-'||doc_subtype||'-'||doc_num

	     l_itemkey := l_doc_type || '-'||
			     l_doc_subtype ||'-'||
			     to_char(p_DocumentId);


	      if (po_approval_reminder_sv.is_active('APVRMDER',l_itemkey)) then
		   WF_Engine.AbortProcess('APVRMDER',l_itemkey);
	      end if;

               -- Bug 3593182: Removed the item exists condition before
               -- the purge as purge only purges existing items
               --<BUG 3351588>
               --Force item purge even if an active child process exists.
               WF_PURGE.ITEMS (itemtype => l_ItemType,
                               itemkey  => l_Itemkey,
                               enddate  => SYSDATE,
                               docommit => true,  --<BUG 3351588>
                               force    => true); --<BUG 3351588>

	elsif  (p_DocumentTypeCode = 'REL_ACCEPTANCE') then

	      x_progress := 'PO_APPROVAL_REMINDER_SV.cancel_notif-007';

	      l_doc_type := 'REL_ACCEPTANCE';

	      select poh.type_lookup_code
	      into   l_doc_subtype
	      from   po_headers_all poh,    -- <R12 MOAC>
	             po_releases_all por    /*Bug6632095: using base table instead of view */
	      where  por.po_header_id = poh.po_header_id and
		     por.po_release_id = p_DocumentId;

	     if (l_doc_subtype = 'PLANNED') then
		 l_doc_subtype := 'SCHEDULED';
	     end if;
         --bug#3709971 modified the structure of item key from
	 --doc_type||doc_subtype||doc_num(old structure) to
	 --doc_type||'-'||doc_subtype||'-'||doc_num

	     l_itemkey := l_doc_type || '-'||
			     l_doc_subtype ||'-'||
			     to_char(p_DocumentId);


	      if (po_approval_reminder_sv.is_active('APVRMDER',l_itemkey)) then
		   WF_Engine.AbortProcess('APVRMDER',l_itemkey);
	      end if;

             -- Bug 3593182: Removed the item exists condition before
             -- the purge as purge only purges existing items

                --<BUG 3351588>
                --Force item purge even if an active child process exists.
                WF_PURGE.ITEMS (itemtype => l_ItemType,
                                itemkey  => l_Itemkey,
                                enddate  => SYSDATE,
                                docommit => true,  --<BUG 3351588>
                                force    => true); --<BUG 3351588>

	 elsif (p_DocumentTypeCode = 'RFQ') then

	       x_progress := 'PO_APPROVAL_REMINDER_SV.cancel_notif-008';
	       l_doc_type := 'RFQ';

	       l_itemkey := l_doc_type ||
			       to_char(p_DocumentId);

               if (po_approval_reminder_sv.is_active('APVRMDER',l_itemkey)) then
		   WF_Engine.AbortProcess('APVRMDER',l_itemkey);
	       end if;


              -- Bug 3593182: Removed the item exists condition before
              -- the purge as purge only purges existing items
              --<BUG 3351588>
              --Force item purge even if an active child process exists.
                WF_PURGE.ITEMS (itemtype => l_ItemType,
                                itemkey  => l_Itemkey,
                                enddate  => SYSDATE,
                                docommit => true,  --<BUG 3351588>
                                force    => true); --<BUG 3351588>

	  elsif (p_DocumentTypeCode = 'QUOTATION') then

	       x_progress := 'PO_APPROVAL_REMINDER_SV.cancel_notif-009';
	       l_doc_type := 'QUOTATION';

	       l_itemkey := l_doc_type ||
			       to_char(p_DocumentId);

		if (po_approval_reminder_sv.is_active('APVRMDER',l_itemkey)) then
		   WF_Engine.AbortProcess('APVRMDER',l_itemkey);
		 end if;


               -- Bug 3593182: Removed the item exists condition before
               -- the purge as purge only purges existing items
               --<BUG 3351588>
               --Force item purge even if an active child process exists.
               WF_PURGE.ITEMS (itemtype => l_ItemType,
                               itemkey  => l_Itemkey,
                               enddate  => SYSDATE,
                               docommit => true,  --<BUG 3351588>
                               force    => true); --<BUG 3351588>

	  end if;

	 EXCEPTION
	       WHEN OTHERS THEN
		IF (g_po_wf_debug = 'Y') THEN
		   PO_WF_DEBUG_PKG.insert_debug(null,null,x_progress);
		END IF;
		wf_core.context ('PO_APPROVAL_REMINDER_SV','Process_Cancel_notification','SQL error ' || sqlcode);
		RAISE;

	 END Cancel_Notif;

	FUNCTION  is_active (x_item_type in varchar2,
			     x_item_key  in varchar2) RETURN BOOLEAN is

        -- Bug 3693990
	x_act_status WF_ITEM_ACTIVITY_STATUSES.ACTIVITY_STATUS%TYPE;
        x_result     varchar2(30);
        -- Bug 3693990

	x_progress   varchar2(100) := '001';

	BEGIN
	     x_progress := 'PO_APPROVAL_REMINDER_SV.is_active-001';

--bug#3693990 commented out the above sql because the view
--wf_item_activity_statuses_v is a view which is based on
--a union all between wf_item_activity_statuses and
--wf_item_activity_statuses_h(history). A new record
--gets inserted into history table when the wf process
--raises an error.
--WF Team has provided an api wf_engine.itemstatus to check the
--active status of any given activity. We need to call this
--instead of query the wf_item_activity_statuses_v view directly.
			BEGIN
			 wf_engine.itemstatus (itemtype      => x_item_type,
                                       itemkey       => x_item_key,
                                       status        => x_act_status,
                                       RESULT        => x_result
                                      );
		        EXCEPTION
			    WHEN OTHERS THEN
			       x_act_status:= NULL;
			END;


			if x_act_status not in ('COMPLETE', 'ERROR') then
			   return TRUE;
			else return FALSE;
			end if;
	EXCEPTION
	  WHEN NO_DATA_FOUND THEN
	     return FALSE;
	  WHEN OTHERS THEN
	     IF (g_po_wf_debug = 'Y') THEN
		PO_WF_DEBUG_PKG.insert_debug(null,null,x_progress);
	     END IF;
	     wf_core.context ('PO_APPROVAL_REMINDER_SV','Process_Check_Status','SQL error ' || sqlcode);
	     RAISE;
	     return FALSE;
	END;

	PROCEDURE stop_process( item_type in varchar2,
				item_key  in varchar2) is

	BEGIN

		if (po_approval_reminder_sv.is_active(item_type,item_key)) then
			     WF_Engine.AbortProcess(item_type,item_key, cascade=>true);
		 end if;

	END stop_process;


	PROCEDURE item_exist  ( p_ItemType 	IN  VARCHAR2,
				p_ItemKey  	IN  VARCHAR2,
				p_Item_exist 	OUT NOCOPY VARCHAR2,
				p_Item_end_date OUT NOCOPY DATE) is


	  l_progress            VARCHAR2(300) := NULL;

	BEGIN


	   l_progress := 'PO_APPROVAL_REMINDER_SV.Item_Exist: 01';
	   -- /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(p_itemtype,p_itemkey,l_progress);

	   -- initialize the return variables
	   p_item_exist := NULL;
	   p_item_end_date := NULL;

		SELECT		'Y', WI.end_date
		  INTO	        p_item_exist, p_item_end_date
		  FROM		WF_ITEMS_V WI
		 WHERE		WI.ITEM_TYPE = p_ItemType
		   AND          WI.ITEM_KEY  = p_ItemKey;


	    l_progress := 'PO_APPROVAL_REMINDER_SV.Item_Exist: 900 ';
	    -- /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(p_itemtype,p_itemkey,l_progress);


 EXCEPTION
  WHEN NO_DATA_FOUND THEN

	-- item key does not exist
	p_item_exist := 'N';
        p_item_end_date := NULL;

  WHEN OTHERS THEN

     wf_core.context ('PO_APPROVAL_REMINDER_SV','Item_exist','SQL error ' || sqlcode);
     l_progress := 'PO_APPROVAL_REMINDER_SV.Item_Exist: 990 - ' ||
 		           'EXCEPTION - sql error: ' || sqlcode;
     IF (g_po_wf_debug = 'Y') THEN
        /* DEBUG */  PO_WF_DEBUG_PKG.insert_debug(p_itemtype,p_itemkey,l_progress);
     END IF;

     RAISE;


END item_exist;

-- <SVC_NOTIFICATIONS FPJ START>
-------------------------------------------------------------------------------
--Start of Comments
--Name: process_po_temp_labor_lines
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Starts the Reminder workflow to send notifications for Temp Labor lines
--  that match the reminder criteria (Amount Billed Exceeds Budget,
--  Contractor Assignment Nearing Completion).
--Parameters:
--  None.
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE process_po_temp_labor_lines IS
  l_proc_name CONSTANT VARCHAR2(30) := 'process_po_temp_labor_lines';

  CURSOR l_temp_labor_lines_csr (
    p_amount_threshold     NUMBER,
    p_completion_threshold NUMBER
  ) IS
    -- SQL What: Retrieve the Temp Labor lines that match either of the
    --           reminder criteria (Amount Billed Exceeds Budget, Contractor
    --           Assignment Nearing Completion), ignoring those that
    --           already had a notification sent.
    --           We only consider Standard PO lines with approved, open,
    --           non-cancelled shipments.
    -- SQL Why:  To send notifications for these lines.
    --
    -- <Complex Work R12 START>: Re-architected query to select SUM of
    -- amount_billed accross all line locations, since Complex Work POs
    -- can have multiple pay items on fixed-price temp labor lines.
    SELECT POL2.po_line_id,
           POL2.svc_amount_notif_sent,
           POL2.amount,
           SUM_DATA.total_amount_billed amount_billed,
           POL2.svc_completion_notif_sent,
           POL2.expiration_date,
           POL2.contractor_first_name,
           POL2.contractor_last_name,
           PJ.name job_name
    FROM po_lines_all POL2,
         per_jobs_vl PJ,
         (  SELECT PLL.po_line_id
                 , SUM(PLL.amount_billed) total_amount_billed
            FROM   po_line_locations PLL
                 , po_lines_all POL
                 , po_headers_all poh
            WHERE  poh.type_lookup_code = 'STANDARD'
             AND   poh.po_header_id = POL.po_header_id
             AND   POL.purchase_basis = 'TEMP LABOR'
             AND   POL.po_line_id = PLL.po_line_id
             AND   NVL(PLL.approved_flag, 'N') = 'Y'
             AND   NVL(PLL.cancel_flag, 'N') = 'N'
             AND   NVL(PLL.closed_code, 'OPEN') <> 'FINALLY CLOSED'
             AND   (    PLL.payment_type IS NULL
                     OR PLL.payment_type NOT IN ('DELIVERY','ADVANCE')
                   )
             GROUP BY PLL.po_line_id
         ) SUM_DATA
    WHERE POL2.po_line_id = SUM_DATA.po_line_id
      AND PJ.job_id = POL2.job_id
      AND (    (     p_amount_threshold IS NOT NULL
                 AND SUM_DATA.total_amount_billed
                                      >= POL2.amount * p_amount_threshold / 100
               )
            OR (     p_completion_threshold IS NOT NULL
                 AND TRUNC(sysdate) >= TRUNC(POL2.expiration_date) - p_completion_threshold
               )
          );
    -- <Complex Work R12 END>

  l_tl_line_rec          l_temp_labor_lines_csr%ROWTYPE;
  l_amount_threshold     NUMBER;
  l_completion_threshold NUMBER;
  l_contractor_or_job    VARCHAR2(500);
  l_requester_id         PO_REQUISITION_LINES.to_person_id%TYPE;
  l_profile_name         FND_PROFILE_OPTIONS_VL.profile_option_name%TYPE;
  l_user_profile_name    FND_PROFILE_OPTIONS_VL.user_profile_option_name%TYPE;
BEGIN
  -- Retrieve the profile options for the Reminder thresholds.
  BEGIN
    l_profile_name := 'PO_SVC_AMOUNT_THRESHOLD';
    l_amount_threshold := TO_NUMBER(FND_PROFILE.value(l_profile_name));
    l_profile_name := 'PO_SVC_COMPLETION_THRESHOLD';
    l_completion_threshold := TO_NUMBER(FND_PROFILE.value(l_profile_name));
  EXCEPTION
    WHEN value_error THEN
      SELECT user_profile_option_name
      INTO l_user_profile_name
      FROM FND_PROFILE_OPTIONS_VL
      WHERE profile_option_name = l_profile_name;

      FND_MESSAGE.set_name ('PO', 'PO_PROFILE_OPTION_NUMERIC');
      FND_MESSAGE.set_token ( 'PROFILE_OPTION', l_user_profile_name );
      FND_FILE.put_line ( FND_FILE.OUTPUT, FND_MESSAGE.get );
      RAISE;
  END;

  IF (g_fnd_debug = 'Y') THEN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
      FND_LOG.string( log_level => FND_LOG.LEVEL_STATEMENT,
                    module => g_module_prefix || l_proc_name,
                    message => 'Amount threshold: ' || l_amount_threshold
                               || '; Completion threshold: '
                               || l_completion_threshold );
    END IF;
  END IF;

  -- We do not need to send any notifications if the reminder thresholds
  -- are not set.
  IF (l_amount_threshold IS NULL) AND (l_completion_threshold IS NULL) THEN
    RETURN;
  END IF;

  -- Loop through the Temp Labor lines that exceed either threshold.
  FOR l_tl_line_rec
    IN l_temp_labor_lines_csr (l_amount_threshold, l_completion_threshold) LOOP

    -- For the subject of the notification, use the concatenated contractor
    -- name, if available, or otherwise the job name.
    IF (l_tl_line_rec.contractor_first_name IS NOT NULL)
       OR (l_tl_line_rec.contractor_last_name IS NOT NULL) THEN
      l_contractor_or_job :=
        PO_POAPPROVAL_INIT1.get_formatted_full_name (
          l_tl_line_rec.contractor_first_name,
          l_tl_line_rec.contractor_last_name );
    ELSE
      l_contractor_or_job := l_tl_line_rec.job_name;
    END IF;

    -- Determine the requester for this Temp Labor PO line.
    PO_POAPPROVAL_INIT1.get_temp_labor_requester (
      p_po_line_id => l_tl_line_rec.po_line_id,
      x_requester_id => l_requester_id );

    -- If the Amount Billed on this line exceeds the tolerance of the
    -- Budget Amount, send a reminder notification to the requester.
    IF (l_amount_threshold IS NOT NULL)
       AND (l_tl_line_rec.svc_amount_notif_sent IS NULL)
       AND (l_tl_line_rec.amount_billed >=
            l_tl_line_rec.amount * l_amount_threshold / 100) THEN

      start_po_line_reminder_wf (
        p_po_line_id => l_tl_line_rec.po_line_id,
        p_line_reminder_type => 'SVC_AMOUNT',
        p_requester_id => l_requester_id,
        p_contractor_or_job => l_contractor_or_job,
        p_expiration_date => l_tl_line_rec.expiration_date
      );

      -- SQL What: Set the "Amount Billed notification sent" flag to Y.
      UPDATE po_lines_all
      SET svc_amount_notif_sent = 'Y',
          last_update_date = sysdate,
          last_updated_by = fnd_global.user_id
      WHERE po_line_id = l_tl_line_rec.po_line_id;

    END IF;

    -- If the current date exceeds the completion tolerance of the
    -- Assignment End Date, send a reminder notification to the requester.
    IF (l_completion_threshold is NOT NULL)
       AND (l_tl_line_rec.svc_completion_notif_sent IS NULL)
       AND (TRUNC(sysdate) >=
            TRUNC(l_tl_line_rec.expiration_date) - l_completion_threshold) THEN

      start_po_line_reminder_wf (
        p_po_line_id => l_tl_line_rec.po_line_id,
        p_line_reminder_type => 'SVC_COMPLETION',
        p_requester_id => l_requester_id,
        p_contractor_or_job => l_contractor_or_job,
        p_expiration_date => l_tl_line_rec.expiration_date
      );

      -- SQL What: Set the "Assignment Completion notification sent" flag to Y.
      UPDATE po_lines_all
      SET svc_completion_notif_sent = 'Y',
          last_update_date = sysdate,
          last_updated_by = fnd_global.user_id
      WHERE po_line_id = l_tl_line_rec.po_line_id;

    END IF;

  END LOOP; -- l_po_temp_labor_rec

  -- Issue a commit so that Workflow can pick up the reminder notifications.
  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    IF (g_fnd_debug = 'Y') THEN
      FND_MSG_PUB.Build_Exc_Msg ( p_pkg_name => g_pkg_name,
                                  p_procedure_name => l_proc_name );
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
        FND_LOG.string( log_level => FND_LOG.LEVEL_UNEXPECTED,
                      module => g_module_prefix || l_proc_name,
                      message => FND_MESSAGE.get );
      END IF;
    END IF;

    RAISE;
END process_po_temp_labor_lines;

-------------------------------------------------------------------------------
--Start of Comments
--Name: start_po_line_reminder_wf
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Starts the Reminder workflow for the given PO line and line reminder type.
--Parameters:
--IN:
--p_po_line_id
--  PO line for this reminder
--p_line_reminder_type
--  type of reminder - ex. SVC_AMOUNT (for Amount Approaching Budget)
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE start_po_line_reminder_wf (
  p_po_line_id         IN PO_LINES.po_line_id%TYPE,
  p_line_reminder_type IN VARCHAR2,
  p_requester_id       IN NUMBER,
  p_contractor_or_job  IN VARCHAR2,
  p_expiration_date    IN DATE
) IS
  l_proc_name CONSTANT VARCHAR2(30) := 'start_po_line_reminder_wf';

  l_item_key            WF_ITEMS.item_key%TYPE;
  l_item_exist          VARCHAR2(1);
  l_item_end_date       DATE;
  l_requester_user_name WF_USERS.name%TYPE;
  l_requester_disp_name WF_USERS.display_name%TYPE;
  l_po_header_id        PO_HEADERS_ALL.po_header_id%TYPE;
  l_req_header_id       PO_REQUISITION_HEADERS_ALL.requisition_header_id%TYPE;
  l_document_number     PO_HEADERS_ALL.segment1%TYPE;
BEGIN
  l_item_key := 'PO_LINE_REMINDER-' || p_line_reminder_type || '-'
                || p_po_line_id;

  PO_REQAPPROVAL_INIT1.get_user_name (
    p_employee_id => p_requester_id,
    x_username => l_requester_user_name,
    x_user_display_name => l_requester_disp_name );

  IF (g_fnd_debug = 'Y') THEN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_EVENT) THEN
      FND_LOG.string( log_level => FND_LOG.LEVEL_EVENT,
                    module => g_module_prefix || l_proc_name,
                    message => 'Launching the reminder workflow:'
                               || ' item key: ' || l_item_key
                               || ', requester ID: ' || p_requester_id
                               || ', user name: ' || l_requester_user_name
                               || ', contractor/job: ' || p_contractor_or_job
                               || ', expiration date: ' || p_expiration_date
                  );
    END IF;
  END IF;

  -- Cancel and purge any existing reminder process for this line.
  PO_APPROVAL_REMINDER_SV.item_exist (p_ItemType => 'APVRMDER',
                                      p_ItemKey => l_item_key,
                                      p_Item_exist => l_item_exist,
                                      p_Item_end_date => l_item_end_date);
  IF (l_item_exist = 'Y') THEN
    -- Abort the process if it is still active.
    IF (l_item_end_date IS NULL) THEN
      WF_ENGINE.AbortProcess(g_reminder_item_type, l_item_key );
    END IF;

    -- Purge the process so we can re-use the item key.
    --<BUG 3351588>
    --Force item purge even if an active child process exists.
    WF_PURGE.ITEMS (itemtype => g_reminder_item_type,
                    itemkey  => l_item_key,
                    enddate  => SYSDATE,
                    docommit => true,  --<BUG 3351588>
                    force    => true); --<BUG 3351588>

  END IF; -- l_item_exist

  -- Create a Reminder workflow process for this PO line.
  wf_engine.CreateProcess ( ItemType  => g_reminder_item_type,
                            ItemKey   => l_item_key,
                            Process   => 'PO_LINE_REMINDER' );

  -- Set some workflow item attributes.
  po_wf_util_pkg.SetItemAttrNumber ( ItemType => g_reminder_item_type,
                                     ItemKey  => l_item_key,
                                     aname    => 'PO_LINE_ID',
                                     avalue   => p_po_line_id );

  po_wf_util_pkg.SetItemAttrText ( ItemType => g_reminder_item_type,
                                   ItemKey  => l_item_key,
                                   aname    => 'PO_LINE_REMINDER_TYPE',
                                   avalue   => p_line_reminder_type );

  po_wf_util_pkg.SetItemAttrNumber ( ItemType => g_reminder_item_type,
                                     ItemKey  => l_item_key,
                                     aname    => 'REQUESTER_ID',
                                     avalue   => p_requester_id );

  po_wf_util_pkg.SetItemAttrText ( ItemType => g_reminder_item_type,
                                   ItemKey  => l_item_key,
                                   aname    => 'REQUESTER_USER_NAME',
                                   avalue   => l_requester_user_name );

  po_wf_util_pkg.SetItemAttrText ( ItemType => g_reminder_item_type,
                                   ItemKey  => l_item_key,
                                   aname    => 'CONTRACTOR_OR_JOB',
                                   avalue   => p_contractor_or_job );

  po_wf_util_pkg.SetItemAttrDate ( ItemType => g_reminder_item_type,
                                   ItemKey  => l_item_key,
                                   aname    => 'EXPIRATION_DATE',
                                   avalue   => p_expiration_date );

  -- Bug 3441007 START
  -- For BLAF Compliance, we are now showing the links in the Related
  -- Applications section, so we need to set the URL attributes.

  -- SQL What: Retrieve the PO_HEADER_ID and REQUISITION_HEADER_ID for the
  --           Temp Labor PO line.

  --Bug 5483192 Start:
  -- With Actual Complex work POs its possible to have more than one line locations
  -- But its possible to have only one line location to with a backing req, if any

select   POH.po_header_id,
         POH.segment1
 INTO    l_po_header_id,
         l_document_number
 FROM    po_lines  POL,
         po_headers_all POH
 WHERE   POL.po_line_id = p_po_line_id
 AND     POL.po_header_id = POH.po_header_id;

BEGIN

    select   PRL.requisition_header_id
    INTO    l_req_header_id
    FROM    po_lines  POL,
        po_line_locations_all PLL,
        po_requisition_lines_all PRL
   WHERE   POL.po_line_id = p_po_line_id
   AND   POL.po_line_id = PLL.po_line_id
   AND   PLL.line_location_id = PRL.line_location_id;

EXCEPTION
WHEN NO_DATA_FOUND THEN
     l_req_header_id := NULL;
END;
 --Bug 5483192 End:

  po_wf_util_pkg.SetItemAttrText ( ItemType => g_reminder_item_type,
                                   ItemKey  => l_item_key,
                                   aname    => 'DOCUMENT_NUMBER',
                                   avalue   => l_document_number );

  -- Show the 'View Purchase Order' link.
  po_wf_util_pkg.SetItemAttrText ( ItemType => g_reminder_item_type,
                                   ItemKey  => l_item_key,
                                   aname    => 'VIEW_PO_URL',
                                   avalue   =>
    'OA.jsp?OAFunc=POS_VIEW_ORDER&PoHeaderId='||l_po_header_id );

  -- Show the 'View Requisition' and 'Extend Assignment' links if there is a
  -- backing requisition.
  IF (l_req_header_id IS NOT NULL) THEN

    po_wf_util_pkg.SetItemAttrText ( ItemType => g_reminder_item_type,
                                     ItemKey  => l_item_key,
                                     aname    => 'VIEW_REQ_URL',
                                     avalue   =>
      'OA.jsp?OAFunc=ICX_POR_LAUNCH_IP&porMode=viewReq'
      ||'&porReqHeaderId='||l_req_header_id );

    -- Bug 3562721 Changed to use the new iP URL for change requests.
    po_wf_util_pkg.SetItemAttrText ( ItemType => g_reminder_item_type,
                                     ItemKey  => l_item_key,
                                     aname    => 'EXTEND_ASSIGNMENT_URL',
                                     avalue   =>
      'OA.jsp?OAFunc=ICX_POR_LAUNCH_IP&porMode=changeOrder'
      ||'&porReqHeaderId='||l_req_header_id );

  END IF; -- l_req_header_id
  -- Bug 3441007 END

  -- Start the Reminder workflow process for this PO line.
  wf_engine.StartProcess ( ItemType => g_reminder_item_type,
                           ItemKey => l_item_key );

EXCEPTION
  WHEN OTHERS THEN
    IF (g_fnd_debug = 'Y') THEN
      FND_MSG_PUB.Build_Exc_Msg ( p_pkg_name => g_pkg_name,
                                  p_procedure_name => l_proc_name );
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) THEN
        FND_LOG.string( log_level => FND_LOG.LEVEL_UNEXPECTED,
                      module => g_module_prefix || l_proc_name,
                      message => FND_MESSAGE.get );
      END IF;
    END IF;

    RAISE;
END start_po_line_reminder_wf;

-------------------------------------------------------------------------------
--Start of Comments
--Name: get_po_line_reminder_type
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Returns the value of the PO Line Reminder Type item attribute.
--Parameters:
--IN:
--itemtype
--  Workflow Item Type
--itemkey
--  Workflow Item Key
--actid
--  Identifies the Workflow activity that is calling this procedure.
--funcmode
--  Workflow mode that this procedure is being called in: Run, Cancel, etc.
--OUT:
--resultout
--  COMPLETED:<value of the Temp Labor Reminder Type item attribute>
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE get_po_line_reminder_type (
  itemtype  IN VARCHAR2,
  itemkey   IN VARCHAR2,
  actid     IN NUMBER,
  funcmode  IN VARCHAR2,
  resultout OUT NOCOPY VARCHAR2
) IS
  l_line_reminder_type VARCHAR2(20);
BEGIN
  -- Do nothing if the Workflow mode is Cancel or Timeout.
  if (funcmode <> wf_engine.eng_run) then
    resultout := wf_engine.eng_null;
    return;
  end if;

  l_line_reminder_type :=
    po_wf_util_pkg.GetItemAttrText (itemtype => itemtype,
                                    itemkey => itemkey,
                                    aname => 'PO_LINE_REMINDER_TYPE');
  resultout := wf_engine.eng_completed || ':' || l_line_reminder_type;

EXCEPTION
  WHEN OTHERS THEN
    wf_core.context( 'PO_APPROVAL_REMINDER_SV',
                     'GET_TEMP_LABOR_REMINDER_TYPE' );
    RAISE;
END get_po_line_reminder_type;

-- <SVC_NOTIFICATIONS FPJ END>

END PO_APPROVAL_REMINDER_SV;

/
