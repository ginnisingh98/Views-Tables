--------------------------------------------------------
--  DDL for Package Body GML_BATCH_WORKFLOW_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GML_BATCH_WORKFLOW_PKG" AS
/*  $Header: GMLBTWFB.pls 120.0 2005/05/25 16:47:05 appldev noship $  */
/* +=========================================================================+
 |                Copyright (c) 2002 Oracle Corporation                    |
 |                         All righTs reserved                             |
 +=========================================================================+
 | FILENAME                                                                |
 |    GMLBTWFB.pls                                                         |
 |                                                                         |
 | DESCRIPTION                                                             |
 |     This package contains Workflow procedures for GME-OM Integration    |
 |     reservation.                                                        |
 |                                                                         |
 | --  Init_wf()                                                           |
 | --  Check_event()							   |
 | --  Insert_gml_batch_so_workflow()			      	           |
 |                                                                         |
 | HISTORY                                                                 |
 |              10-Oct-2003  nchekuri        Created                       |
 |                                                                         |
 +=========================================================================+ */


PROCEDURE init_wf (
      	p_session_id	IN   NUMBER
      ,	p_approver   	IN   NUMBER
      , p_so_header_id  IN   NUMBER
      ,	p_so_line_id	IN   NUMBER
      ,	p_batch_id	IN   NUMBER
      , p_batch_line_id IN   NUMBER
      , p_whse_code     IN   VARCHAR2
      , p_lot_no	IN   VARCHAR2 DEFAULT NULL
      ,	p_action_code   IN   VARCHAR2 )IS

   l_itemtype		VARCHAR2(240) :=  'GMLBTRES';
   l_itemkey		VARCHAR2(240) := to_char(p_session_id)||'-'||to_char(sysdate,'dd-MON-yyyy HH24:mi:ss');
   l_run_wf_in_background  CONSTANT WF_ENGINE.THRESHOLD%TYPE := -1;
   l_WorkflowProcess 	VARCHAR2(30)  := 'GMLBTRES_PROCESS';
   l_count 		NUMBER;

   l_order_no		NUMBER;
   l_so_line_no		NUMBER;
   l_item_no 		VARCHAR2(40);
   l_order_type		VARCHAR2(30);
   l_batch_no		VARCHAR2(32);
   l_fpo_no		VARCHAR2(32);
   l_plant_code 	VARCHAR2(4);
   l_plan_complt_date   DATE;
   l_approver_name	VARCHAR2(20);

   /* Cusor Declarations */

   CURSOR  Get_user_name(p_user_id IN NUMBER) IS
      SELECT user_name
        FROM fnd_user
       WHERE user_id = p_user_id;

   CURSOR Get_order_info(p_so_line_id IN NUMBER) IS
      SELECT  ol.line_number, mtl.segment1,
              ot.transaction_type_code,
              oh.order_number
        FROM  oe_order_headers_all oh
             ,oe_order_lines_all ol
     	     ,oe_transaction_types_all ot
	     ,mtl_system_items mtl
       WHERE  ol.line_id = p_so_line_id
         and  ol.header_id = oh.header_id
	 and  oh.order_type_id = ot.transaction_type_id
         and  mtl.inventory_item_id = ol.inventory_item_id;

    CURSOR Get_batch_info(p_batch_id IN NUMBER) IS
       SELECT batch_no,plant_code,
              plan_cmplt_date
         FROM gme_batch_header
         WHERE batch_id = p_batch_id;


BEGIN


   /* Get the User Name */

   GMI_RESERVATION_UTIL.PrintLn('In GML_BATCH_WORKFLOW_PKG. Init_wf workflow procedure');

   GMI_RESERVATION_UTIL.PrintLn('In GML_BATCH_WORKFLOW_PKG. Init_wf: Input Parameters......');
   GMI_RESERVATION_UTIL.PrintLn('In GML_BATCH_WORKFLOW_PKG. Init_wf: P_so_header_id = '||p_so_header_id);
   GMI_RESERVATION_UTIL.PrintLn('In GML_BATCH_WORKFLOW_PKG. Init_wf: p_so_line_id   = '||p_so_line_id);
   GMI_RESERVATION_UTIL.PrintLn('In GML_BATCH_WORKFLOW_PKG. Init_wf: p_action_code  = '||p_action_code);
   GMI_RESERVATION_UTIL.PrintLn('In GML_BATCH_WORKFLOW_PKG. Init_wf: p_batch_id  = ' ||p_batch_id);
   GMI_RESERVATION_UTIL.PrintLn('In GML_BATCH_WORKFLOW_PKG. Init_wf: p_batch_line_id = '|| p_batch_line_id);
   GMI_RESERVATION_UTIL.PrintLn('In GML_BATCH_WORKFLOW_PKG. Init_wf: p_whse_code = '|| p_whse_code);
   GMI_RESERVATION_UTIL.PrintLn('In GML_BATCH_WORKFLOW_PKG. Init_wf: p_lot_no = '|| p_lot_no);

   OPEN Get_user_name(p_approver);
   FETCH Get_user_name INTO l_approver_name;
   IF(Get_user_name%NOTFOUND) THEN
     GMI_RESERVATION_UTIL.PrintLn('In GML_BATCH_WORKFLOW_PKG.init_wf Get_user_name%NOTFOUND');
     CLOSE Get_user_name;
     RETURN;
   END IF;

   CLOSE Get_user_name;

   GMI_RESERVATION_UTIL.PrintLn('In GML_BATCH_WORKFLOW_PKG. Init_wf after get_user_name');

   /* Get the Order and Line Information */

   OPEN Get_order_info(p_so_line_id);
   FETCH Get_order_info INTO l_so_line_no,l_item_no,
         l_order_type,l_order_no;
   IF(Get_order_info%NOTFOUND) THEN
     GMI_RESERVATION_UTIL.PrintLn('In GML_BATCH_WORKFLOW_PKG.init_wf Get_order_info%NOTFOUND');
     CLOSE Get_order_info;
     RETURN;
   END IF;

   CLOSE Get_order_info;

   GMI_RESERVATION_UTIL.PrintLn('In GML_BATCH_WORKFLOW_PKG. Init_wf; Order/Line Information......');
   GMI_RESERVATION_UTIL.PrintLn('In GML_BATCH_WORKFLOW_PKG. Init_wf; Order_type = '|| l_order_type);
   GMI_RESERVATION_UTIL.PrintLn('In GML_BATCH_WORKFLOW_PKG. Init_wf; Order_no   = '|| l_order_no);
   GMI_RESERVATION_UTIL.PrintLn('In GML_BATCH_WORKFLOW_PKG. Init_wf; Line_no    = '|| l_so_line_no);
   GMI_RESERVATION_UTIL.PrintLn('In GML_BATCH_WORKFLOW_PKG. Init_wf; Item_no    = '|| l_item_no);

   GMI_RESERVATION_UTIL.PrintLn('In GML_BATCH_WORKFLOW_PKG. Init_wf after get_order_info');

   /* Get the batch Information */

   OPEN Get_batch_info(p_batch_id);
   FETCH Get_batch_info INTO l_batch_no, l_plant_code,l_plan_complt_date;
   IF(Get_batch_info%NOTFOUND) THEN
     GMI_RESERVATION_UTIL.PrintLn('In GML_BATCH_WORKFLOW_PKG.init_wf Get_batch_info%NOTFOUND');
     CLOSE Get_batch_info;
     RETURN;
   END IF;
   CLOSE Get_batch_info;

   l_fpo_no := l_batch_no;

   GMI_RESERVATION_UTIL.PrintLn('In GML_BATCH_WORKFLOW_PKG. Init_wf; Batch  Information......');
   GMI_RESERVATION_UTIL.PrintLn('In GML_BATCH_WORKFLOW_PKG. Init_wf; Batch_no = '|| l_batch_no);
   GMI_RESERVATION_UTIL.PrintLn('In GML_BATCH_WORKFLOW_PKG. Init_wf; Plant_code   = '|| l_plant_code);
   GMI_RESERVATION_UTIL.PrintLn('In GML_BATCH_WORKFLOW_PKG. Init_wf; Planned Completion Date    = '|| l_plan_complt_date);

   GMI_RESERVATION_UTIL.PrintLn('In GML_BATCH_WORKFLOW_PKG. Init_wf after Get_batch_info');

   /* Increment the itemkey global variable */

   g_itemkey_num := g_itemkey_num+1;
   l_itemkey := l_itemkey||'-'||to_char(g_itemkey_num);

   /* create the process*/


   GMI_RESERVATION_UTIL.PrintLn('In GML_BATCH_WORKFLOW_PKG. Init_wf before CreateProcess');

   WF_ENGINE.CREATEPROCESS(
			  itemtype => l_itemtype
			, itemkey => l_itemkey
			, process => l_WorkflowProcess) ;

   /* make sure that process runs with background engine */

   GMI_RESERVATION_UTIL.PrintLn('In GML_BATCH_WORKFLOW_PKG. Init_wf after CreateProcess');

--  WF_ENGINE.THRESHOLD := l_run_wf_in_background ;
 --WF_ENGINE.THRESHOLD := -1 ;

   /* set the item attributes*/
   /*
   WF_ENGINE.SETITEMATTRNUMBER(
			  itemtype => l_itemtype
			, itemkey => l_itemkey
        		, aname => 'SESSION_ID'
			, avalue => l_session_id );
   */

   WF_ENGINE.SETITEMATTRTEXT(
			  itemtype => l_itemtype
			, itemkey =>l_itemkey
			, aname => 'APPROVER'
			, avalue => l_approver_name);

   GMI_RESERVATION_UTIL.PrintLn('In GML_BATCH_WORKFLOW_PKG. Init_wf Set Approver Name');

   WF_ENGINE.SETITEMATTRTEXT(
			  itemtype => l_itemtype
			, itemkey => l_itemkey
        		, aname => 'ACTION_CODE'
			, avalue => p_action_code );

   GMI_RESERVATION_UTIL.PrintLn('In GML_BATCH_WORKFLOW_PKG. Init_wf Set action Code');

   WF_ENGINE.SETITEMATTRTEXT(
			  itemtype => l_itemtype
			, itemkey => l_itemkey
        		, aname => 'ORDER_NO'
			, avalue => to_char(l_order_no) );

   GMI_RESERVATION_UTIL.PrintLn('In GML_BATCH_WORKFLOW_PKG. Init_wf Set Order Number ');

   WF_ENGINE.SETITEMATTRTEXT(
			  itemtype => l_itemtype
			, itemkey => l_itemkey
        		, aname => 'ORDER_TYPE'
			, avalue => l_order_type );

   GMI_RESERVATION_UTIL.PrintLn('In GML_BATCH_WORKFLOW_PKG. Init_wf Set Order Type ');

   WF_ENGINE.SETITEMATTRTEXT(
			  itemtype => l_itemtype
			, itemkey => l_itemkey
        		, aname => 'SO_LINE_NO'
			, avalue => to_char(l_so_line_no) );

   GMI_RESERVATION_UTIL.PrintLn('In GML_BATCH_WORKFLOW_PKG. Init_wf Set so_line_no ');

   WF_ENGINE.SETITEMATTRTEXT(
			  itemtype => l_itemtype
			, itemkey => l_itemkey
        		, aname => 'ITEM_NO'
			, avalue => l_item_no );

   GMI_RESERVATION_UTIL.PrintLn('In GML_BATCH_WORKFLOW_PKG. Init_wf Set Item Number ');

   WF_ENGINE.SETITEMATTRTEXT(
			  itemtype => l_itemtype
			, itemkey => l_itemkey
        		, aname => 'PLANT_CODE'
			, avalue => l_plant_code );

   GMI_RESERVATION_UTIL.PrintLn('In GML_BATCH_WORKFLOW_PKG. Init_wf Set Plant Code ');

   WF_ENGINE.SETITEMATTRTEXT(
			  itemtype => l_itemtype
			, itemkey => l_itemkey
        		, aname => 'BATCH_NO'
			, avalue => l_batch_no );

   GMI_RESERVATION_UTIL.PrintLn('In GML_BATCH_WORKFLOW_PKG. Init_wf Set Whse Code ');

   WF_ENGINE.SETITEMATTRTEXT(
			  itemtype => l_itemtype
			, itemkey => l_itemkey
        		, aname => 'WHSE_CODE'
			, avalue => p_whse_code );

   IF (p_lot_no is NOT NULL) THEN
      GMI_RESERVATION_UTIL.PrintLn('In GML_BATCH_WORKFLOW_PKG. Init_wf Set Whse Code ');
      WF_ENGINE.SETITEMATTRTEXT(
			  itemtype => l_itemtype
			, itemkey  => l_itemkey
        		, aname    => 'LOT_NO'
			, avalue   => p_lot_no );
   END IF;

   GMI_RESERVATION_UTIL.PrintLn('In GML_BATCH_WORKFLOW_PKG. Init_wf Set Batch Number ');

   WF_ENGINE.SETITEMATTRTEXT(
			  itemtype => l_itemtype
			, itemkey => l_itemkey
        		, aname => 'FPO_NO'
			, avalue => l_fpo_no );

   GMI_RESERVATION_UTIL.PrintLn('In GML_BATCH_WORKFLOW_PKG. Init_wf Set FPO Number ');

  /*
   WF_ENGINE.SETITEMATTRTEXT(
			  itemtype => l_itemtype
			, itemkey => l_itemkey
        		, aname => 'PL_COMPL_DATE'
			, avalue => TO_CHAR(TO_DATE(l_plan_complt_date,'MON-DD-YYYY')) );
   */

  /* start the Workflow process */

   GMI_RESERVATION_UTIL.PrintLn('In GML_BATCH_WORKFLOW_PKG. Init_wf after Setting the Attributes');
   GMI_RESERVATION_UTIL.PrintLn('In GML_BATCH_WORKFLOW_PKG. Init_wf Before Start Process');

   WF_ENGINE.STARTPROCESS (
			  itemtype => l_itemtype
			, itemkey => l_itemkey );

   GMI_RESERVATION_UTIL.PrintLn('In GML_BATCH_WORKFLOW_PKG. Init_wf After Start Process');

   /* Insert the workflow/batch/so information into Gml_batch_so_workflow table for
      future reference. */

   GMI_RESERVATION_UTIL.PrintLn('In GML_BATCH_WORKFLOW_PKG. Init_wf Before Insert Record');

   INSERT_GML_BATCH_SO_WORKFLOW(
                         l_itemtype
                       , l_itemkey
		       , p_so_header_id
                       , p_so_line_id
                       , p_batch_id
		       , p_batch_line_id
		       , p_action_code);

   GMI_RESERVATION_UTIL.PrintLn('In GML_BATCH_WORKFLOW_PKG. Init_wf After  Insert Record');

   GMI_RESERVATION_UTIL.PrintLn('In GML_BATCH_WORKFLOW_PKG. Init_wf Exiting ....');


EXCEPTION

   WHEN OTHERS THEN
      NULL;
      GMI_RESERVATION_UTIL.PrintLn('WARNING! In GML_BATCH_WORKFLOW_PKG. Init_wf Others Exception');

      WF_CORE.CONTEXT ('GML_BATCH_WORKFLOW','init_wf'
			,l_itemtype,l_itemkey,'Initial' );

      RAISE;

END INIT_WF;

PROCEDURE check_event(
      p_itemtype      IN VARCHAR2,
      p_itemkey       IN VARCHAR2,
      p_actid         IN NUMBER,
      p_funcmode      IN VARCHAR2,
      p_resultout     OUT NOCOPY VARCHAR2) IS

   l_event_type VARCHAR2(240) := WF_ENGINE.GETITEMATTRTEXT(
                                                itemtype=>p_itemtype,
                                                itemkey=>P_itemkey,
                                                aname => 'ACTION_CODE');
BEGIN

   p_resultout := 'COMPLETE:'||l_event_type;

EXCEPTION

  WHEN OTHERS THEN
     NULL;

END check_event;


PROCEDURE INSERT_GML_BATCH_SO_WORKFLOW(
             p_itemtype     IN 	VARCHAR2
           , p_itemkey      IN	VARCHAR2
           , p_so_header_id IN	NUMBER
           , p_so_line_id   IN	NUMBER
           , p_batch_id	    IN	NUMBER
           , p_batch_line_id IN	NUMBER
           , p_action_code   IN	VARCHAR2) IS

   l_wf_item_id  NUMBER;

BEGIN

  GMI_RESERVATION_UTIL.PrintLn('In GML_BATCH_WORKFLOW_PKG. INSERT_GML_BATCH_SO_WORKFLOW..... ');

  SELECT GML_BATCH_SO_WORKFLOW_S.nextval
    INTO l_wf_item_id FROM DUAL;

  GMI_RESERVATION_UTIL.PrintLn('In  GML_BATCH_WORKFLOW_PKG. INSERT_GML_BATCH_SO_WORKFLOW Before Insert ');

  INSERT INTO Gml_batch_so_workflow (
		  WF_ITEM_ID
   		, WF_ITEM_TYPE
   		, WF_ITEM_KEY
   		, SO_HEADER_ID
   		, SO_LINE_ID
   		, BATCH_ID
   		, BATCH_LINE_ID
   		, ACTION_CODE
   		, CREATION_DATE
   		, CREATED_BY
   		, LAST_UPDATE_DATE
   		, LAST_UPDATED_BY ) VALUES

                ( l_wf_item_id
		, p_itemtype
                , p_itemkey
                , p_so_header_id
                , p_so_line_id
                , p_batch_id
                , p_batch_line_id
                , p_action_code
                , sysdate
                , fnd_global.user_id
                , sysdate
                , fnd_global.user_id);

  GMI_RESERVATION_UTIL.PrintLn('In  GML_BATCH_WORKFLOW_PKG. INSERT_GML_BATCH_SO_WORKFLOW After Insert ');

EXCEPTION

  WHEN OTHERS THEN
    GMI_RESERVATION_UTIL.PrintLn('WARNING!  GML_BATCH_WORKFLOW_PKG. INSERT_GML_BATCH_SO_WORKFLOW OTHERS Exception ');
    NULL;

END INSERT_GML_BATCH_SO_WORKFLOW;


END GML_BATCH_WORKFLOW_PKG;

/
