--------------------------------------------------------
--  DDL for Package Body GME_BATCH_WKFL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GME_BATCH_WKFL_PKG" AS
/*  $Header: GMEBTWFB.pls 120.1 2006/02/24 08:22:42 lgao noship $  */
/* +=========================================================================+
 |                Copyright (c) 2002 Oracle Corporation                    |
 |                         All righTs reserved                             |
 +=========================================================================+
 | FILENAME                                                                |
 |    GMEBTWFB.pls                                                         |
 |                                                                         |
 | DESCRIPTION                                                             |
 |     This package contains Workflow procedures for GME-OM Integration    |
 |     reservation.                                                        |
 |                                                                         |
 | --  Init_wf()                                                           |
 | --  Check_event()                                                       |
 | --  Insert_gml_batch_so_workflow()                                      |
 |                                                                         |
 | HISTORY                                                                 |
 |              10-Oct-2003  nchekuri        Created                       |
 |                                                                         |
 +=========================================================================+ */

G_PKG_NAME  CONSTANT  VARCHAR2(30):='GME_BATCH_WORKFLOW_PKG';
g_debug               VARCHAR2 (5)  := fnd_profile.VALUE ('AFLOG_LEVEL');

PROCEDURE init_wf (
        p_itemtype           IN VARCHAR2
      , p_itemkey            IN   NUMBER
      , p_approver           IN   NUMBER
      , p_so_header_id       IN   NUMBER
      , p_so_line_id         IN   NUMBER
      , p_batch_id           IN   NUMBER
      , p_batch_line_id      IN   NUMBER
      , p_fpo_id             IN   NUMBER
      , p_organization_id    IN   NUMBER
      , p_lot_no             IN   VARCHAR2 DEFAULT NULL
      , p_action_code        IN   VARCHAR2
 )IS

  l_api_name                 CONSTANT  VARCHAR2 (30)    := 'init_wf';
  l_itemtype                 VARCHAR2(240) :=  'GMEBTRES';
  --l_itemkey                  VARCHAR2(240) := to_char(p_session_id)||'-'||to_char(sysdate,'dd-MON-yyyy HH24:mi:ss');
  l_itemkey                  VARCHAR2(240) ;
  l_run_wf_in_background     CONSTANT WF_ENGINE.THRESHOLD%TYPE := -1;
  l_WorkflowProcess          VARCHAR2(30)  := 'GMEBTRES_PROCESS';
  l_count                    NUMBER;

  l_order_no             NUMBER;
  l_so_line_no           NUMBER;
  l_batch_line_no        NUMBER;
  l_item_no              VARCHAR2(40);
  l_order_type           VARCHAR2(30);
  l_batch_no             VARCHAR2(32);
  l_fpo_no               VARCHAR2(32);
  l_plant_code           VARCHAR2(4);
  l_plan_complt_date     DATE;
  l_approver_name        VARCHAR2(20);
  l_organization_code    VARCHAR2(20);

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

   CURSOR Get_batch_line_info(p_batch_line_id IN NUMBER) IS
      SELECT line_no
        FROM gme_material_details
        WHERE material_detail_id = p_batch_line_id;

    Cursor get_org_code (p_organization_id in NUMBER) is
       Select organization_code
       From mtl_parameters
       Where organization_id = p_organization_id;

BEGIN
  IF g_debug <= gme_debug.g_log_procedure THEN
     gme_debug.put_line ('Entering api ' || g_pkg_name || '.' || l_api_name);
     gme_debug.put_line(g_pkg_name||'.'||l_api_name|| ': Input Parameters......');
     gme_debug.put_line(g_pkg_name||'.'||l_api_name|| ': P_itemkey = '||p_itemkey);
     gme_debug.put_line(g_pkg_name||'.'||l_api_name|| ': P_itemtype = '||p_itemtype);
     gme_debug.put_line(g_pkg_name||'.'||l_api_name|| ': p_so_line_id   = '||p_so_line_id);
     gme_debug.put_line(g_pkg_name||'.'||l_api_name|| ': p_action_code  = '||p_action_code);
     gme_debug.put_line(g_pkg_name||'.'||l_api_name|| ': p_batch_id  = ' ||p_batch_id);
     gme_debug.put_line(g_pkg_name||'.'||l_api_name|| ': p_batch_line_id = '|| p_batch_line_id);
     gme_debug.put_line(g_pkg_name||'.'||l_api_name|| ': p_organization_id = '|| p_organization_id);
     gme_debug.put_line(g_pkg_name||'.'||l_api_name|| ': p_lot_no = '|| p_lot_no);

  END IF;
     wf_log_pkg.wf_debug_flag:=TRUE;

  Open get_org_code(p_organization_id);
  Fetch get_org_code Into l_organization_code;
  Close get_org_code;
  IF g_debug <= gme_debug.g_log_procedure THEN
     gme_debug.put_line(g_pkg_name||'.'||l_api_name|| ': l_organization_code = '|| l_organization_code);
  END IF;

  /* Get the User Name */
  OPEN Get_user_name(p_approver);
  FETCH Get_user_name INTO l_approver_name;
  IF(Get_user_name%NOTFOUND) THEN
     IF g_debug <= gme_debug.g_log_procedure THEN
        gme_debug.put_line(g_pkg_name||'.'||l_api_name|| ': Get_user_name%NOTFOUND');
     END IF;
    CLOSE Get_user_name;
    RETURN;
  END IF;
  CLOSE Get_user_name;
  IF g_debug <= gme_debug.g_log_procedure THEN
     gme_debug.put_line(g_pkg_name||'.'||l_api_name|| 'after get_user_name');
  END IF;

  /* Get the Order and Line Information */
  OPEN Get_order_info(p_so_line_id);
  FETCH Get_order_info INTO l_so_line_no,l_item_no,
        l_order_type,l_order_no;
  IF(Get_order_info%NOTFOUND) THEN
     IF g_debug <= gme_debug.g_log_procedure THEN
        gme_debug.put_line(g_pkg_name||'.'||l_api_name ||'Get_order_info%NOTFOUND');
     END IF;
    CLOSE Get_order_info;
    RETURN;
  END IF;

  CLOSE Get_order_info;

  IF g_debug <= gme_debug.g_log_procedure THEN
     gme_debug.put_line(g_pkg_name||'.'||l_api_name || '; Order/Line Information......');
     gme_debug.put_line(g_pkg_name||'.'||l_api_name || '; Order_type = '|| l_order_type);
     gme_debug.put_line(g_pkg_name||'.'||l_api_name || '; Order_no   = '|| l_order_no);
     gme_debug.put_line(g_pkg_name||'.'||l_api_name || '; Line_no    = '|| l_so_line_no);
     gme_debug.put_line(g_pkg_name||'.'||l_api_name || '; Item_no    = '|| l_item_no);
     gme_debug.put_line(g_pkg_name||'.'||l_api_name || 'after get_order_info');
  END IF;

  /* Get the batch Information */
  OPEN Get_batch_info(p_batch_id);
  FETCH Get_batch_info INTO l_batch_no, l_plant_code,l_plan_complt_date;
  IF(Get_batch_info%NOTFOUND) THEN
     IF g_debug <= gme_debug.g_log_procedure THEN
        gme_debug.put_line(g_pkg_name||'.'||l_api_name || 'Get_batch_info%NOTFOUND');
     END IF;
    CLOSE Get_batch_info;
    --RETURN;
  END IF;
  CLOSE Get_batch_info;
  l_fpo_no := l_batch_no;

  if p_batch_line_id is not null then
     OPEN Get_batch_line_info(p_batch_line_id);
     FETCH Get_batch_line_info INTO l_batch_line_no;
     IF(Get_batch_line_info%NOTFOUND) THEN
        IF g_debug <= gme_debug.g_log_procedure THEN
           gme_debug.put_line(g_pkg_name||'.'||l_api_name || 'Get_batch_line_info%NOTFOUND');
        END IF;
       CLOSE Get_batch_line_info;
       --RETURN;
     END IF;
     CLOSE Get_batch_line_info;
  end if;

  if p_fpo_id is not null then
    OPEN Get_batch_info(p_fpo_id);
    FETCH Get_batch_info INTO l_fpo_no, l_plant_code,l_plan_complt_date;
    IF(Get_batch_info%NOTFOUND) THEN
        IF g_debug <= gme_debug.g_log_procedure THEN
           gme_debug.put_line(g_pkg_name||'.'||l_api_name || 'Get_batch_info%NOTFOUND');
        END IF;
       CLOSE Get_batch_info;
       --RETURN;
    END IF;
    CLOSE Get_batch_info;
  end if;


  IF g_debug <= gme_debug.g_log_procedure THEN
     gme_debug.put_line(g_pkg_name||'.'||l_api_name || '; Batch  Information......');
     gme_debug.put_line(g_pkg_name||'.'||l_api_name || '; Batch_no = '|| l_batch_no);
     gme_debug.put_line(g_pkg_name||'.'||l_api_name || '; Batch_line_no = '|| l_batch_line_no);
     gme_debug.put_line(g_pkg_name||'.'||l_api_name || '; FPO_no = '|| l_FPO_no);
     gme_debug.put_line(g_pkg_name||'.'||l_api_name || '; Plant_code   = '|| l_plant_code);
     gme_debug.put_line(g_pkg_name||'.'||l_api_name || '; Planned Completion Date    = '|| l_plan_complt_date);
  END IF;
  /* Increment the itemkey global variable */
  g_itemkey_num := g_itemkey_num+1;
  l_itemkey := l_itemkey||'-'||to_char(g_itemkey_num);

  /* create the process*/
  /*IF g_debug <= gme_debug.g_log_procedure THEN
     gme_debug.put_line(g_pkg_name||'.'||l_api_name || 'Init_wf before CreateProcess');
  END IF;
  WF_ENGINE.CREATEPROCESS(
                           itemtype => l_itemtype
                         , itemkey => l_itemkey
                         , process => l_WorkflowProcess) ;
   */
  /* make sure that process runs with background engine */
  IF g_debug <= gme_debug.g_log_procedure THEN
     gme_debug.put_line(g_pkg_name||'.'||l_api_name || 'after CreateProcess');
  END IF;

 --  WF_ENGINE.THRESHOLD := l_run_wf_in_background ;
 --WF_ENGINE.THRESHOLD := -1 ;

  l_itemkey := p_itemkey;
  l_itemtype := p_itemtype;
  /* set the item attributes*/
  WF_ENGINE.SETITEMATTRTEXT(
                            itemtype => l_itemtype
                         , itemkey =>l_itemkey
                         , aname => 'APPROVER'
                         , avalue => l_approver_name);
  IF g_debug <= gme_debug.g_log_procedure THEN
     gme_debug.put_line(g_pkg_name||'.'||l_api_name || 'Set Approver Name');
  END IF;
  WF_ENGINE.SETITEMATTRTEXT(
                              itemtype => l_itemtype
                            , itemkey => l_itemkey
                            , aname => 'ACTION_CODE'
                            , avalue => p_action_code );

  IF g_debug <= gme_debug.g_log_procedure THEN
     gme_debug.put_line(g_pkg_name||'.'||l_api_name || 'Set Action Code ');
  END IF;
  WF_ENGINE.SETITEMATTRTEXT(
                              itemtype => l_itemtype
                            , itemkey => l_itemkey
                            , aname => 'ORDER_NO'
                            , avalue => to_char(l_order_no) );

  IF g_debug <= gme_debug.g_log_procedure THEN
     gme_debug.put_line(g_pkg_name||'.'||l_api_name || 'Set Order Number ');
  END IF;
  WF_ENGINE.SETITEMATTRTEXT(
                              itemtype => l_itemtype
                             , itemkey => l_itemkey
                             , aname => 'ORDER_TYPE'
                             , avalue => l_order_type );

  IF g_debug <= gme_debug.g_log_procedure THEN
     gme_debug.put_line(g_pkg_name||'.'||l_api_name || 'Set Order Type ');
  END IF;
  WF_ENGINE.SETITEMATTRTEXT(
                              itemtype => l_itemtype
                            , itemkey => l_itemkey
                            , aname => 'SO_LINE_NO'
                            , avalue => to_char(l_so_line_no) );

  IF g_debug <= gme_debug.g_log_procedure THEN
     gme_debug.put_line(g_pkg_name||'.'||l_api_name || 'Set so_line_no ');
  END IF;
  WF_ENGINE.SETITEMATTRTEXT(
                              itemtype => l_itemtype
                            , itemkey => l_itemkey
                            , aname => 'ITEM_NO'
                            , avalue => l_item_no );

  WF_ENGINE.SETITEMATTRTEXT(
                              itemtype => l_itemtype
                            , itemkey => l_itemkey
                            , aname => 'ORG_CODE'
                            , avalue => l_organization_code);
  IF g_debug <= gme_debug.g_log_procedure THEN
     gme_debug.put_line(g_pkg_name||'.'||l_api_name || 'Set Batch Number ');
  END IF;
  WF_ENGINE.SETITEMATTRTEXT(
                              itemtype => l_itemtype
                            , itemkey => l_itemkey
                            , aname => 'BATCH_NO'
                            , avalue => l_batch_no );

  IF g_debug <= gme_debug.g_log_procedure THEN
     gme_debug.put_line(g_pkg_name||'.'||l_api_name || 'Set Batch Line Number ');
  END IF;
  WF_ENGINE.SETITEMATTRTEXT(
                              itemtype => l_itemtype
                            , itemkey => l_itemkey
                            , aname => 'BATCH_LINE_NO'
                            , avalue => l_batch_line_no );

  IF (p_lot_no is NOT NULL) THEN
     IF g_debug <= gme_debug.g_log_procedure THEN
        gme_debug.put_line(g_pkg_name||'.'||l_api_name || 'Set lot_no ');
     END IF;
     WF_ENGINE.SETITEMATTRTEXT(
                              itemtype => l_itemtype
                            , itemkey  => l_itemkey
                            , aname    => 'LOT_NO'
                            , avalue   => p_lot_no );
  END IF;
  IF g_debug <= gme_debug.g_log_procedure THEN
     gme_debug.put_line(g_pkg_name||'.'||l_api_name || 'Set FPO Number ');
  END IF;
  WF_ENGINE.SETITEMATTRTEXT(
                              itemtype => l_itemtype
                            , itemkey => l_itemkey
                            , aname => 'FPO_NO'
                            , avalue => l_fpo_no );
  IF g_debug <= gme_debug.g_log_procedure THEN
     gme_debug.put_line(g_pkg_name||'.'||l_api_name || 'after Setting the Attributes');
     gme_debug.put_line(g_pkg_name||'.'||l_api_name || 'Before Start Process');
  END IF;
  /*WF_ENGINE.STARTPROCESS (
                            itemtype => l_itemtype
                         , itemkey => l_itemkey );
  */
  IF g_debug <= gme_debug.g_log_procedure THEN
     gme_debug.put_line(g_pkg_name||'.'||l_api_name || 'After Start Process');
  END IF;

EXCEPTION

   WHEN OTHERS THEN
      NULL;
      IF g_debug <= gme_debug.g_log_procedure THEN
         gme_debug.put_line(g_pkg_name||'.'||l_api_name || 'WARNING! In GME_BATCH_WORKFLOW_PKG. Init_wf Others Exception');
      END IF;

      WF_CORE.CONTEXT ('GME_BATCH_WORKFLOW','init_wf'
			,l_itemtype,l_itemkey,'Initial' );

      RAISE;

END INIT_WF;

PROCEDURE check_event(
      p_itemtype      IN VARCHAR2,
      p_itemkey       IN VARCHAR2,
      p_actid         IN NUMBER,
      p_funcmode      IN VARCHAR2,
      p_resultout     OUT NOCOPY VARCHAR2) IS

    l_event_type VARCHAR2(240) := WF_ENGINE.GETITEMATTRTEXT( itemtype=>p_itemtype, itemkey=>P_itemkey, aname => 'ACTION_CODE');
    --l_session_id         number := wf_engine.getitemattrtext(p_itemtype, p_itemkey,'SESSION_ID');
    l_approver           number := wf_engine.getitemattrtext(p_itemtype, p_itemkey,'APPROVER');
    l_so_header_id       number := wf_engine.getitemattrtext(p_itemtype, p_itemkey,'SO_HEADER_ID');
    l_so_line_id         number := wf_engine.getitemattrtext(p_itemtype, p_itemkey,'SO_LINE_ID');
    l_batch_id           number := wf_engine.getitemattrtext(p_itemtype, p_itemkey,'BATCH_ID');
    l_batch_line_id      number := wf_engine.getitemattrtext(p_itemtype, p_itemkey,'BATCH_LINE_ID');
    l_fpo_id             number := wf_engine.getitemattrtext(p_itemtype, p_itemkey,'FPO_ID');
    l_organization_id    number := wf_engine.getitemattrtext(p_itemtype, p_itemkey,'ORGANIZATION_ID');
    l_lot_no             varchar2(80) := wf_engine.getitemattrtext(p_itemtype, p_itemkey,'LOT_NO');
    l_action_code        varchar2(30) := wf_engine.getitemattrtext(p_itemtype, p_itemkey,'ACTION_CODE');
BEGIN

  wf_log_pkg.wf_debug_flag:=TRUE;
  IF g_debug <= gme_debug.g_log_procedure THEN
     gme_debug.put_line ('Entering check event ' );
  End if;
    init_wf (
        p_itemtype           => p_itemtype
      , p_itemkey            => p_itemkey
      , p_approver           => l_approver
      , p_so_header_id       => l_so_header_id
      , p_so_line_id         => l_so_line_id
      , p_batch_id           => l_batch_id
      , p_batch_line_id      => l_batch_line_id
      , p_fpo_id             => l_fpo_id
      , p_organization_id    => l_organization_id
      , p_lot_no             => l_lot_no
      , p_action_code        => l_action_code
      );

      p_resultout := 'COMPLETE:'||l_event_type;

EXCEPTION

  WHEN OTHERS THEN
     NULL;

END check_event;


END GME_BATCH_WKFL_PKG;

/
