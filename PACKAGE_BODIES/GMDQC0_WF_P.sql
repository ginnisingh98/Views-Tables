--------------------------------------------------------
--  DDL for Package Body GMDQC0_WF_P
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMDQC0_WF_P" AS
/* $Header: GMDQC0B.pls 115.4 2002/04/18 14:58:20 pkm ship      $ */
   PROCEDURE init_wf (
      -- procedure to initialize and run Workflow
      -- called via trigger on IC_TRAN_CMP,IC_TRAN_PND

      p_trans_id      IN   VARCHAR2,
      p_orgn_code     IN   ic_tran_pnd.orgn_code%TYPE ,
      p_whse_code     IN   ic_tran_pnd.whse_code%TYPE ,
      p_item_id       IN   ic_tran_pnd.item_id%TYPE  ,
      p_doc_type      IN   ic_tran_pnd.doc_type%TYPE ,
      p_doc_id        IN   ic_tran_pnd.doc_id%TYPE,
      p_lot_id	    IN   ic_tran_pnd.lot_id%TYPE,
      p_trans_qty     IN   NUMBER

   )

   IS

      l_itemtype      WF_ITEMS.ITEM_TYPE%TYPE :=  'GMDQC0';
      l_itemkey       WF_ITEMS.ITEM_KEY%TYPE  :=  p_trans_id;

      /* make sure that process runs with background engine
       to prevent SAVEPOINT/ROLLBACK error (see Workflow FAQ)
       the value to use for this is -1 */

      l_run_wf_in_background CONSTANT WF_ENGINE.THRESHOLD%TYPE := -1;


      l_item_no      ic_item_mst.item_no%TYPE ;
      l_item_desc1   ic_item_mst.item_desc1%TYPE ;
      l_dualum_ind   ic_item_mst.dualum_ind%TYPE ;
      l_item_um      ic_item_mst.item_um%TYPE ;
      l_item_um2     ic_item_mst.item_um2%TYPE ;
      l_trans_qty    NUMBER;
      l_WorkflowProcess   VARCHAR2(30) := 'GMDQC0_PROCESS';
      l_count             NUMBER;
      BEGIN
         /* Check for Specifications */
        SELECT NVL(count(*),0) into l_count
          FROM QC_SPEC_MST
         WHERE item_id = p_item_id;

       IF l_count > 0 THEN
      	/* create the process */

      	WF_ENGINE.CREATEPROCESS (itemtype => l_itemtype, itemkey => l_itemkey, process => l_WorkflowProcess);

      	/* make sure that process runs with background engine */
      	WF_ENGINE.THRESHOLD := l_run_wf_in_background ;

      	/* set the item attributes */
      	WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,itemkey => l_itemkey,
         					  aname => 'TRANS_ID',
         	                          avalue => p_trans_id);

      	WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,itemkey => l_itemkey,
         					  aname => 'ORGN_CODE',
         					  avalue => p_orgn_code);

      	WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,itemkey => l_itemkey,
         				        aname => 'WHSE_CODE',
         	                          avalue => p_whse_code);
            WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,itemkey => l_itemkey,
         					  aname => 'ITEM_ID',
         	                          avalue => p_item_id);

      	WF_ENGINE.SETITEMATTRNUMBER (itemtype => l_itemtype,itemkey => l_itemkey,
         					     aname => 'LOT_ID',
         					     avalue => p_lot_id);

      	WF_ENGINE.SETITEMATTRTEXT (itemtype => l_itemtype,itemkey => l_itemkey,
         					   aname => 'DOC_TYPE',
         	                           avalue => p_doc_type);

      	WF_ENGINE.SETITEMATTRNUMBER (itemtype => l_itemtype,itemkey => l_itemkey,
         					     aname => 'DOC_ID',
         					     avalue => p_doc_id);

            WF_ENGINE.SETITEMATTRNUMBER (itemtype => l_itemtype,itemkey => l_itemkey,
         					     aname => 'TRANS_QTY',
         					     avalue => p_trans_qty);

      	/* start the Workflow process */

      	WF_ENGINE.STARTPROCESS (itemtype => l_itemtype,itemkey => l_itemkey);

       END IF;
  EXCEPTION
      WHEN OTHERS THEN
         WF_CORE.CONTEXT ('gmdqc0_wf_p','init_wf',l_itemtype,l_itemkey,p_trans_id );
         raise;
  END init_wf;

/* ######################################################################## */

   PROCEDURE select_role(
      /* procedure to set the required attributes and find the role associated.
       input/output parameters conform to WF standard (see WF FAQ) */
      p_itemtype      IN VARCHAR2,
      p_itemkey       IN VARCHAR2,
      p_actid         IN NUMBER,
      p_funcmode      IN VARCHAR2,
      p_resultout     OUT VARCHAR2
   )
   IS
      l_item_id    ic_item_mst.item_id%TYPE:=wf_engine.getitemattrtext (p_itemtype, p_itemkey,	'ITEM_ID');
      l_item_no    ic_item_mst.item_no%TYPE;
      l_whse_item_no Varchar2(32);
      l_whse_item_id ic_item_mst.item_id%TYPE;
      l_item_desc1 ic_item_mst.item_desc1%TYPE;
      l_item_um    ic_item_mst.item_um%TYPE;
      l_item_um2   ic_item_mst.item_um2%TYPE;
      l_lot_id     ic_lots_mst.lot_id%TYPE:=wf_engine.getitemattrtext (p_itemtype, p_itemkey,'LOT_ID');
      l_orgn_code  sy_orgn_mst.orgn_code%TYPE:=wf_engine.getitemattrtext (p_itemtype, p_itemkey,'ORGN_CODE');
      l_orgn_name  sy_orgn_mst.orgn_name%TYPE;
      l_whse_code  ic_whse_mst.whse_code%TYPE:=wf_engine.getitemattrtext (p_itemtype, p_itemkey,'WHSE_CODE');
      l_whse_name  ic_whse_mst.whse_name%TYPE;
      l_lot_no     ic_lots_mst.lot_no%TYPE ;
      l_sublot_no  ic_lots_mst.sublot_no%TYPE ;
      l_doc_type   sy_docs_mst.doc_type%TYPE:=wf_engine.getitemattrtext (p_itemtype, p_itemkey,'DOC_TYPE');
      l_doc_desc   sy_docs_mst.doc_desc%TYPE;
      l_role_name  wf_roles.name%TYPE;
      l_role_display_name wf_roles.display_name%TYPE;
      l_email_Address  varchar2(2000);
      l_notification_Preference varchar2(2000);
      l_language                varchar2(2000);
      l_territory               varchar2(2000);
      l_sample_form             VARCHAR2(100);
      l_datastring              VARCHAR2(2000);
      l_delimiter               VARCHAR2(1);
      NO_ROLE_ERROR             Exception;
    /* Declaring the Workflow Parameters to be passed to generic Role association */
      l_wf_item_type            VARCHAR2(8):='GMDQC0';
      l_process_name            VARCHAR2(80):='GMDQC0_PROCESS';
      l_activity_name           VARCHAR2(100):='SELECT_ROLE';
	   /* Begin Bug#2250274 Praveen Reddy */
      /* Added variables l_doc_id and l_doc_no*/
      l_doc_id     ic_tran_pnd.doc_id%TYPE:=wf_engine.getitemattrtext (p_itemtype, p_itemkey,'DOC_ID');
      l_doc_no                  VARCHAR2(40);
      /* End Bug#2250274*/
    BEGIN
       IF (p_funcmode = 'RUN') THEN

           /* Selecting item details for the item on which the transaction has occured */
           SELECT item_no,item_desc1,item_um,item_um2,whse_item_id
             INTO l_item_no,l_item_desc1,l_item_um,l_item_um2,l_whse_item_id
             FROM ic_item_mst
            WHERE item_id = l_item_id;

           /* Select warehouse item details for the given item */
           SELECT item_no
            INTO  l_whse_item_no
            FROM  ic_item_mst
            WHERE item_id = l_whse_item_id;

           /* Selecting lot details for the transaction occured */
        IF l_lot_id <> 0 THEN
             SELECT lot_no,sublot_no
                INTO l_lot_no,l_sublot_no
                FROM ic_lots_mst
            WHERE lot_id = l_lot_id;
        ELSE
            l_lot_no:=NULL;
            l_sublot_no:=NULL;
        END IF;
           /* Selecting Organization details from the organization mst */
           SELECT orgn_name
             INTO l_orgn_name
             FROM sy_orgn_mst
            WHERE orgn_code = l_orgn_code;

           /* Selecting Warehouse details from the Warehouse master mst */
           SELECT whse_name
             INTO l_whse_name
             FROM ic_whse_mst
            WHERE whse_code = l_whse_code;

           /* Selecting Document details from Document Master */
           SELECT doc_desc
             INTO l_doc_desc
             FROM sy_docs_mst
            WHERE doc_type = l_doc_type;

           /* Begin Bug#2250274 Praveen Reddy*/
           /* Added code to fetch the doc_no depending upon doc type and doc_id*/
           IF l_doc_type in ('PORC') THEN
             SELECT receipt_num
               INTO l_doc_no
               FROM rcv_shipment_headers
              WHERE shipment_header_id = l_doc_id;
           ELSIF l_doc_type in ('RECV') THEN
             SELECT recv_no
               INTO l_doc_no
               FROM po_recv_hdr
              WHERE recv_id = l_doc_id;
           ELSIF l_doc_type in ('PROD') THEN
             SELECT batch_no
               INTO l_doc_no
               FROM pm_btch_hdr
              WHERE batch_id = l_doc_id;
           ELSIF l_doc_type in ('PICY','PIPH','ADJI','ADJR','CREI','CRER','TRNI','TRNR') then
             SELECT journal_no
               INTO l_doc_no
               FROM ic_jrnl_mst
              WHERE journal_id = l_doc_id;
           END IF;
           /* End Bug#2250274*/

           /* Set the SAMPLE form to be entered */
          /* Bug fix B2314407 . Added PORC transaction to the if Condition */
             IF l_doc_type in ('PORD','RECV','PORC') THEN
                l_sample_form:='QCSMPED1_F:ITEM_NO="'||l_item_no||'" WF="YES"';
             ELSIF l_doc_type = 'PROD' THEN
                l_sample_form:='QCSMPED3_F:ITEM_NO="'||l_item_no||'" WF="YES"';
             ELSE
                l_sample_form:='QCSMPED2_F:ITEM_NO="'||
                                l_item_no||'" WHSE_CODE="'||l_whse_code||'" LOT_NO="'||
                                l_lot_no||'"  SUBLOT_NO="'||l_sublot_no||'" WF="YES"';
             END IF;

           /* Setting all the required attributes */
	      WF_ENGINE.SETITEMATTRTEXT(itemtype => p_itemtype,
      			              itemkey => p_itemkey,
         					  aname => 'SAMPLE_FORM',
                                      avalue => l_sample_form);

	      WF_ENGINE.SETITEMATTRTEXT(itemtype => p_itemtype,
      			              itemkey => p_itemkey,
         					  aname => 'ITEM_NO',
                                      avalue => l_item_no);

	      WF_ENGINE.SETITEMATTRTEXT(itemtype => p_itemtype,
      			              itemkey => p_itemkey,
         					  aname => 'ITEM_DESC1',
                                      avalue => l_item_desc1);

	      WF_ENGINE.SETITEMATTRTEXT(itemtype => p_itemtype,
      			              itemkey => p_itemkey,
         					  aname => 'ITEM_UM',
                                      avalue => l_item_um);

	      WF_ENGINE.SETITEMATTRTEXT(itemtype => p_itemtype,
      			              itemkey => p_itemkey,
         					  aname => 'ITEM_UM2',
                                      avalue => l_item_um2);
	      WF_ENGINE.SETITEMATTRTEXT(itemtype => p_itemtype,
      			              itemkey => p_itemkey,
         					  aname => 'LOT_NO',
                                      avalue => l_lot_no);

	      WF_ENGINE.SETITEMATTRTEXT(itemtype => p_itemtype,
      			              itemkey => p_itemkey,
         					  aname => 'SUBLOT_NO',
                                      avalue => l_sublot_no);
	      WF_ENGINE.SETITEMATTRTEXT(itemtype => p_itemtype,
      			              itemkey => p_itemkey,
         					  aname => 'ORGN_NAME',
                                      avalue => l_orgn_name);

	      WF_ENGINE.SETITEMATTRTEXT(itemtype => p_itemtype,
      			              itemkey => p_itemkey,
         					  aname => 'WHSE_NAME',
                                      avalue => l_whse_name);

	      WF_ENGINE.SETITEMATTRTEXT(itemtype => p_itemtype,
      			              itemkey => p_itemkey,
         					  aname => 'DOC_DESC',
                                      avalue => l_doc_desc);
         /* Begin Bug#2250274 Praveen Reddy*/
         /* Added call to set the doc_no value into the workflow tables */
         WF_ENGINE.SETITEMATTRTEXT(itemtype => p_itemtype,
                             itemkey => p_itemkey,
                          aname => 'DOC_NO',
                                      avalue => l_doc_no);
         /* End Bug#2250274 */

           BEGIN
           /* Get the Delimiter from the Profile Value */
             IF (FND_PROFILE.DEFINED ('SY$WF_DELIMITER')) THEN
                 l_delimiter := FND_PROFILE.VALUE ('SY$WF_DELIMITER');
             ELSE
                 RAISE NO_ROLE_ERROR;
             END IF;
             IF l_delimiter is NULL THEN
                RAISE NO_ROLE_ERROR;
             END IF;
           /* Constructing the Data String to Find the Values */
              l_datastring:='ORGN_CODE='||l_orgn_code||l_delimiter||
                            'WHSE_CODE='||l_whse_code||l_delimiter||
                            'WHSE_ITEM_NO='||l_whse_item_no||l_delimiter||
                            'ITEM_NO='  ||l_item_no;
           /* Getting the Role from generic Role Association Package */
                 gma_wfstd_p.get_role(l_wf_item_type,l_process_name,l_activity_name,l_datastring,l_role_name);
                 IF l_role_name in ('NOROLE','ERROR') THEN
                    RAISE NO_ROLE_ERROR;
                 ELSE
                    p_resultout := 'COMPLETE:ROLE_EXIST';
                 END IF;
           EXCEPTION
                 WHEN NO_ROLE_ERROR THEN
                         p_resultout := 'COMPLETE:SELERR';
                         return;
           END;

        WF_DIRECTORY.GETROLEINFO(l_role_name,l_role_display_name,l_email_Address,
                                     l_notification_Preference,l_language,l_territory);
       	WF_ENGINE.SETITEMATTRTEXT(itemtype => p_itemtype,
      			              itemkey => p_itemkey,
         	                          aname   => 'ROLE_NAME',
                                      avalue  => l_role_name);

        WF_ENGINE.SETITEMATTRTEXT(itemtype => p_itemtype,
      			                itemkey => p_itemkey,
         			                aname => 'ROLE_DISPLAY_NAME',
                                        avalue => l_role_display_name);
END IF;
EXCEPTION
      WHEN OTHERS THEN
         WF_CORE.CONTEXT ('gmdqc0_wf_p','select_role',p_itemtype,p_itemkey,l_role_name);
         raise;
END select_role;
END gmdqc0_wf_p;

/
