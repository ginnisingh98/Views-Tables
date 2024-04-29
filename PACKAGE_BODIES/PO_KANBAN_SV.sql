--------------------------------------------------------
--  DDL for Package Body PO_KANBAN_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_KANBAN_SV" AS
/* $Header: POXKBANB.pls 115.0 99/07/17 01:43:21 porting ship $*/


/*===========================================================================
  PROCEDURE NAME:       Update_Card_Status

  DESCRIPTION:


  CHANGE HISTORY:       WLAU       8/28/1997     Created

===========================================================================*/

  PROCEDURE Update_Card_Status   (p_card_status      IN VARCHAR2,
				  p_document_type    IN VARCHAR2,
				  p_document_id      IN NUMBER,
				  p_kanban_return_status OUT VARCHAR2)   IS

    -- Define cursor for getting release Kanban Card ID
    CURSOR Kanban_rel_dist IS
           SELECT PO_DISTRIBUTION_ID, KANBAN_CARD_ID
             FROM PO_DISTRIBUTIONS
            WHERE PO_RELEASE_ID = p_document_id
              AND KANBAN_CARD_ID is not NULL;

    -- Define cursor for getting PO Kanban Card ID
    CURSOR Kanban_PO_dist IS
           SELECT PO_DISTRIBUTION_ID, KANBAN_CARD_ID
             FROM PO_DISTRIBUTIONS
            WHERE PO_HEADER_ID = p_document_id
              AND KANBAN_CARD_ID is not NULL;

    -- Define cursor for getting PO Kanban Card ID
    CURSOR Kanban_req_line IS
           SELECT prl.REQUISITION_LINE_ID, prl.KANBAN_CARD_ID
             FROM PO_REQUISITION_HEADERS prh,
                  PO_REQUISITION_LINES prl
            WHERE prh.REQUISITION_HEADER_ID = p_document_id
              AND prh.REQUISITION_HEADER_ID = prl.REQUISITION_HEADER_ID
	      AND prh.TYPE_LOOKUP_CODE = 'INTERNAL'
              AND prl.KANBAN_CARD_ID is not NULL;


   l_distribution_id  		NUMBER := 0;
   l_req_line_id   		NUMBER := 0;
   l_kanban_card_id        	NUMBER := 0;

   l_progress                 	VARCHAR2(80) := NULL;


  BEGIN

    dbms_output.put_line ('Update_Card_Status');


    IF 	  p_document_type = 'PO' THEN

          -- Update PO distributions kanban card status

       	  OPEN Kanban_PO_dist;

          LOOP

             FETCH Kanban_PO_dist into   l_distribution_id,
				         l_kanban_card_id;

             EXIT WHEN Kanban_PO_dist%NOTFOUND;

             -- if Kanban Card Id exists in the distribution,
             -- Call INV API to update the Kanban Card Status to 'IN PROCESS'

             INV_Kanban_PVT.Update_Card_Supply_Status
				(p_kanban_return_status,
                      		 l_kanban_card_id,
			 	 INV_Kanban_PVT.G_Supply_Status_InProcess,
				 INV_Kanban_PVT.G_doc_type_PO,
				 p_document_id,
				 l_distribution_id);

          END LOOP;

          CLOSE Kanban_PO_dist;


    ELSIF p_document_type = 'RELEASE' THEN


          -- Update Release distributions kanban card status

       	  OPEN Kanban_rel_dist;

          LOOP

             FETCH Kanban_rel_dist into  l_distribution_id,
				         l_kanban_card_id;

             EXIT WHEN Kanban_rel_dist%NOTFOUND;

             -- if Kanban Card Id exists in the distribution,
             -- Call INV API to update the Kanban Card Status to 'IN PROCESS'

             INV_Kanban_PVT.Update_Card_Supply_Status
				(p_kanban_return_status,
                      		 l_kanban_card_id,
			 	 INV_Kanban_PVT.G_Supply_Status_InProcess,
				 INV_Kanban_PVT.G_doc_type_release,
				 p_document_id,
				 l_distribution_id);

          END LOOP;

          CLOSE Kanban_rel_dist;


    ELSIF p_document_type IN ('REQ', 'REQUISITION') THEN


          -- Update Internal requisition kanban card status

       	  OPEN Kanban_req_line;

          LOOP

             FETCH Kanban_req_line into  l_req_line_id,
				         l_kanban_card_id;

             EXIT WHEN Kanban_req_line%NOTFOUND;

             -- if Kanban Card Id exists in the internal requisition line,
             -- Call INV API to update the Kanban Card Status to 'IN PROCESS'

             INV_Kanban_PVT.Update_Card_Supply_Status
				(p_kanban_return_status,
                      		 l_kanban_card_id,
			 	 INV_Kanban_PVT.G_Supply_Status_InProcess,
				 INV_Kanban_PVT.G_doc_type_Internal_Req,
				 p_document_id,
				 l_req_line_id);

          END LOOP;

          CLOSE Kanban_req_line;


    ELSE
 	  dbms_output.put_line ('Invalid document type passed');

    END IF;


    dbms_output.put_line ('End Update_Card_Status');

    EXCEPTION

        WHEN OTHERS THEN
             NULL;


  END Update_Card_Status;


/*===========================================================================
  PROCEDURE NAME:       Update_Card_Status_Full

  DESCRIPTION:


  CHANGE HISTORY:       WLAU       8/28/1997     Created

===========================================================================*/

  PROCEDURE Update_Card_Status_Full   (p_kanban_card_ID    IN NUMBER,
				       p_kanban_return_status OUT VARCHAR2)  IS


   l_progress                 VARCHAR2(80) := NULL;


  BEGIN

    dbms_output.put_line ('Start Update_Card_Status_Full ');

     INV_KANBAN_PVT.UPDATE_CARD_SUPPLY_STATUS
                             (p_kanban_return_status,
			      p_kanban_card_ID,
                              INV_KANBAN_PVT.G_SUPPLY_STATUS_FULL);

    dbms_output.put_line ('End  Update_Card_Status_Full ');

    EXCEPTION

        WHEN OTHERS THEN
             NULL;


  END Update_Card_Status_Full;


END PO_KANBAN_SV;

/
