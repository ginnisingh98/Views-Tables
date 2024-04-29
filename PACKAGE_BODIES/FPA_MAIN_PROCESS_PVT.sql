--------------------------------------------------------
--  DDL for Package Body FPA_MAIN_PROCESS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FPA_MAIN_PROCESS_PVT" AS
   /* $Header: FPAXWFMB.pls 120.6.12010000.1 2008/07/30 16:28:18 appldev ship $ */

-- Global variables defined for logic based on called from place parameter
-- Please update values assigned to this variables whenever any of these
-- procedure names are modified : GET_ALIST/GET_DLIST/GET_APPROVER/GET_ANALYST/GET_PC_MANAGERS

g_get_port_users        VARCHAR2(30)   := 'GET_ALIST';
g_get_pc_dlist          VARCHAR2(30)   := 'GET_DLIST';
g_get_port_apprv        VARCHAR2(30)   := 'GET_APPROVER';
g_get_port_analyst      VARCHAR2(30)   := 'GET_ANALYST';
g_get_pc_manager        VARCHAR2(30)   := 'GET_PC_MANAGERS';



TYPE PC_ATTRIBUTES_REC_TYPE is RECORD
    (portfolio_name         FPA_OBJECTS_TL.NAME%TYPE,
     pc_name                FPA_OBJECTS_TL.NAME%TYPE,
     portfolio_type         PA_CLASS_CODES.CLASS_CODE%TYPE,
     inv_class_category     PA_CLASS_CATEGORIES.CLASS_CATEGORY%TYPE,
     cost_fin_plan          PA_FIN_PLAN_TYPES_TL.NAME%TYPE,
     benefit_fin_plan       PA_FIN_PLAN_TYPES_TL.NAME%TYPE);



PROCEDURE GET_WF_ATTRIBUTES(
              p_pc_id               IN  NUMBER,
              x_pc_attributes_rec   OUT NOCOPY PC_ATTRIBUTES_REC_TYPE,
              x_return_status       OUT NOCOPY VARCHAR2,
              x_msg_count           OUT NOCOPY NUMBER,
              x_msg_data            OUT NOCOPY VARCHAR2)
IS

l_return_status VARCHAR2(1)    := null;
l_msg_count     NUMBER         := null;
l_msg_data      VARCHAR2(2000) := null;

l_pc_attributes_rec   PC_ATTRIBUTES_REC_TYPE;

CURSOR PC_ATTRIBUTES_CSR (C_PC_ID IN NUMBER) IS
    SELECT
    PRTL.NAME,
    PCTL.NAME,
    CC.CLASS_CODE,
    PCC.CLASS_CATEGORY
    FROM
         FPA_AW_PC_INFO_V PCS,
         FPA_AW_PORTF_HEADERS_V PRTF,
         FPA_OBJECTS_TL PRTL,
         FPA_OBJECTS_TL PCTL,
         PA_CLASS_CATEGORIES PCC,
         PA_CLASS_CODES CC
    WHERE
    PCTL.ID = PCS.PLANNING_CYCLE AND
    PCTL.OBJECT = 'PLANNING_CYCLE' AND
    PRTL.ID = PCS.PORTFOLIO AND
    PRTL.OBJECT = 'PORTFOLIO' AND
    PCS.PC_CATEGORY = PCC.CLASS_CATEGORY_ID AND
    PCS.PORTFOLIO   = PRTF.PORTFOLIO AND
    PRTF.PORTFOLIO_CLASS_CODE = CC.CLASS_CODE_ID AND
    PCS.PLANNING_CYCLE = C_PC_ID;

BEGIN

   IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
                     'fpa.sql.fpa_main_process_pvt.get_wf_attributes.begin',
                     'Entering fpa_main_process_pvt.get_wf_attributes');
   END IF;

   OPEN  PC_ATTRIBUTES_CSR(P_PC_ID);
   FETCH PC_ATTRIBUTES_CSR
   INTO  L_PC_ATTRIBUTES_REC.PORTFOLIO_NAME,
         L_PC_ATTRIBUTES_REC.PC_NAME,
         L_PC_ATTRIBUTES_REC.PORTFOLIO_TYPE,
         L_PC_ATTRIBUTES_REC.INV_CLASS_CATEGORY;
   CLOSE PC_ATTRIBUTES_CSR;


   BEGIN
     SELECT PLC.NAME, PLB.NAME
     INTO   L_PC_ATTRIBUTES_REC.COST_FIN_PLAN, L_PC_ATTRIBUTES_REC.BENEFIT_FIN_PLAN
     FROM   PA_FIN_PLAN_TYPES_TL PLC, PA_FIN_PLAN_TYPES_TL PLB
     WHERE
        FND_PROFILE.VALUE('PJP_FINANCIAL_PLAN_TYPE_COST') = PLC.FIN_PLAN_TYPE_ID AND
        FND_PROFILE.VALUE('PJP_FINANCIAL_PLAN_TYPE_BENEFIT') = PLB.FIN_PLAN_TYPE_ID;
   EXCEPTION
      WHEN OTHERS THEN
      NULL;
   END;

   x_pc_attributes_rec := l_pc_attributes_rec;

EXCEPTION
   WHEN OTHERS THEN
      IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
         fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
                        'fpa.sql.fpa_main_process_pvt.get_wf_attributes.end',
                        SQLERRM);
      END IF;
      wf_core.context('FPA_MAIN_PROCESS_PVT', 'GET_WF_ATTRIBUTES', null);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.count_and_get(p_count => x_msg_count,
                                p_data  => x_msg_data);
      RAISE;
END GET_WF_ATTRIBUTES;


-------------------------------------------------------------
--Start of Comments
--Name        : INITIATE_WORKFLOW
--
--Pre-reqs    : IN parameters need to be passed in with valid values
--
--Modifies    : None
--
--Locks       : None
--
--Function    : This procedure sets up all necessary workflow
--              attributes needed before starting the workflow
--              process.
--
--Parameter(s):
--
--IN          : p_pc_name               IN VARCHAR2,
--              p_pc_id                 IN NUMBER,
--              p_pc_description        IN VARCHAR2,
--              p_pc_date_initiated     IN DATE,
--              p_due_date              IN DATE
--
--IN OUT:     : None
--
--OUT         : x_return_status         OUT NOCOPY VARCHAR2,
--              x_msg_count             OUT NOCOPY NUMBER,
--              x_msg_data              OUT NOCOPY VARCHAR2
--
--Returns     : None
--
--Notes       : None
--
--Testing     : None
--
--End of Comments
-------------------------------------------------------------
PROCEDURE INITIATE_WORKFLOW(p_pc_name           IN         VARCHAR2,
                p_pc_id             IN         NUMBER,
                p_last_pc_id        IN         NUMBER,
                p_pc_description    IN         VARCHAR2,
                p_pc_date_initiated IN         DATE,
                p_due_date          IN         DATE,
                x_return_status     OUT NOCOPY VARCHAR2,
                x_msg_count         OUT NOCOPY NUMBER,
                x_msg_data          OUT NOCOPY VARCHAR2
               )
IS

l_itemtype      VARCHAR2(30)   := null;
l_itemkey       VARCHAR2(30)   := null;
l_return_status VARCHAR2(1)    := null;
l_msg_count     NUMBER         := null;
l_msg_data      VARCHAR2(2000) := null;
l_WFProcess     VARCHAR2(30)   := 'FPA_INITIATE_PLANNING_CYCLE';

l_pc_attributes_rec   PC_ATTRIBUTES_REC_TYPE;

BEGIN

   IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
                     'fpa.sql.fpa_main_process_pvt.initiate_workflow.begin',
                     'Entering fpa_main_process_pvt.initiate_workflow');
   END IF;

   l_itemtype := 'FPAPJP';

   l_itemkey := p_pc_id;

   IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
                     'fpa.sql.fpa_main_process_pvt.initiate_workflow',
                     'Starting the master workflow process');
   END IF;

   -- wf_purge.items(l_itemtype,l_itemkey,sysdate,false,true);

   -- Creates the workflow process
   wf_engine.CreateProcess(itemtype => l_itemtype,
                           itemkey  => l_itemkey,
                           process  => l_WFProcess);

   -- Sets the Planning Cycle ID
   wf_engine.SetItemAttrNumber(itemtype => l_itemtype,
                               itemkey  => l_itemkey,
                               aname    => 'FPA_PC_ID',
                               avalue   => p_pc_id);

   -- Sets the Last Planning Cycle ID
   wf_engine.SetItemAttrNumber(itemtype => l_itemtype,
                               itemkey  => l_itemkey,
                               aname    => 'FPA_LAST_PC_ID',
                               avalue   => p_last_pc_id);

   -- Sets the Due Date
   wf_engine.SetItemAttrDate(itemtype => l_itemtype,
                             itemkey  => l_itemkey,
                             aname    => 'FPA_DUE_DATE',
                             avalue   => p_due_date);


   -- get and set additional attributes
   GET_WF_ATTRIBUTES(
                 p_pc_id              => p_pc_id,
                 x_pc_attributes_rec  => l_pc_attributes_rec,
                 x_return_status      => l_return_status,
                 x_msg_count          => l_msg_count,
                 x_msg_data           => l_msg_data);


   -- Sets the attributes
   wf_engine.SetItemAttrText(itemtype => l_itemtype,
                             itemkey  => l_itemkey,
                             aname    => 'FPA_PORTFOLIO_NAME',
                             avalue   => l_pc_attributes_rec.portfolio_name);

   wf_engine.SetItemAttrText(itemtype => l_itemtype,
                             itemkey  => l_itemkey,
                             aname    => 'FPA_PC_NAME',
                             avalue   => l_pc_attributes_rec.pc_name);

wf_engine.SetItemAttrText(itemtype => l_itemtype,
                          itemkey  => l_itemkey,
                          aname    => 'FPA_PRTF_CLASS_CODE',
                          avalue   => l_pc_attributes_rec.portfolio_type);

wf_engine.SetItemAttrText(itemtype => l_itemtype,
                          itemkey  => l_itemkey,
                          aname    => 'FPA_INV_CLASS_CATEGORY',
                          avalue   => l_pc_attributes_rec.inv_class_category);

wf_engine.SetItemAttrText(itemtype => l_itemtype,
                          itemkey  => l_itemkey,
                          aname    => 'FPA_PRTF_SELECTION_CATEGORY',
                          avalue   => fnd_profile.value('PJP_PORTFOLIO_CLASS_CATEGORY'));

wf_engine.SetItemAttrText(itemtype => l_itemtype,
                          itemkey  => l_itemkey,
                          aname    => 'FPA_COST_FIN_PLAN_TYPE',
                          avalue   => l_pc_attributes_rec.cost_fin_plan);

wf_engine.SetItemAttrText(itemtype => l_itemtype,
                          itemkey  => l_itemkey,
                          aname    => 'FPA_BENEFIT_FIN_PLAN_TYPE',
                          avalue   => l_pc_attributes_rec.benefit_fin_plan);


   -- Starts the workflow process
   wf_engine.StartProcess(itemtype => l_itemtype,
                          itemkey  => l_itemkey);

   IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
                     'fpa.sql.fpa_main_process_pvt.initiate_workflow.end',
                     'Exiting fpa_main_process_pvt.initiate_workflow');
   END IF;

EXCEPTION
   WHEN OTHERS THEN
      IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
         fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
                        'fpa.sql.fpa_main_process_pvt.initiate_workflow.end',
                        SQLERRM);
      END IF;
      wf_core.context('FPA_MAIN_PROCESS_PVT', 'INITIATE_WORKFLOW', null);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.count_and_get(p_count => x_msg_count,
                                p_data  => x_msg_data
                   );
      RAISE;
END INITIATE_WORKFLOW;



-- Cancels the main workflow process and starts an alternate process
PROCEDURE CANCEL_WORKFLOW(p_pc_name           IN         VARCHAR2,
              p_pc_id             IN         NUMBER,
              p_pc_description    IN         VARCHAR2,
              p_pc_date_initiated IN         DATE,
              p_due_date          IN         DATE,
              x_return_status     OUT NOCOPY VARCHAR2,
              x_msg_count         OUT NOCOPY NUMBER,
              x_msg_data          OUT NOCOPY VARCHAR2
             )
IS

l_itemtype      VARCHAR2(30)   := 'FPAPJP';
l_itemkey       VARCHAR2(30)   := p_pc_id;
l_return_status VARCHAR2(1)    := null;
l_msg_count     NUMBER         := null;
l_msg_data      VARCHAR2(2000) := null;
l_WFProcess     VARCHAR2(30)   := 'FPA_INITIATE_PLANNING_CYCLE';
l_process       VARCHAR2(30)   := 'FPA_USER_FORCE';
l_nextval       NUMBER         := null;

BEGIN

   IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
                     'fpa.sql.fpa_main_process_pvt.cancel_workflow.begin',
                     'Entering fpa_main_process_pvt.cancel_workflow');
   END IF;

   IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
                     'fpa.sql.fpa_main_process_pvt.cancel_workflow',
                     'Cancelling the master WF process;  Call wf_engine.AbortProcess');
   END IF;

   -- Cancels the main process
   wf_engine.AbortProcess(itemtype => l_itemtype,
                          itemkey  => l_itemkey,
                          process  => l_WFProcess);

   IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
                     'fpa.sql.fpa_main_process_pvt.cancel_workflow',
                     'Canceled the master WF process;  wf_engine.AbortProcess executed');
   END IF;

   -- Reassign a new item key to the new process
   l_itemkey := 'FPAF' || p_pc_id;

   IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
                     'fpa.sql.fpa_main_process_pvt.cancel_workflow',
                     'l_item_key = '||l_itemkey||'; l_itemtype = '||l_itemtype);
   END IF;

   IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
                     'fpa.sql.fpa_main_process_pvt.cancel_workflow',
                     'l_process = '||l_process||'; p_pc_id = '||p_pc_id);
   END IF;


   -- Creates the workflow process
   wf_engine.CreateProcess(itemtype => l_itemtype,
                           itemkey  => l_itemkey,
                           process  => l_process);

   IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
                     'fpa.sql.fpa_main_process_pvt.cancel_workflow',
                     'executed wf_engine.createProcess API');
   END IF;

   -- Sets the Planning Cycle ID
   wf_engine.SetItemAttrNumber(itemtype => l_itemtype,
                               itemkey  => l_itemkey,
                               aname    => 'FPA_PC_ID',
                               avalue   => p_pc_id);


   IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
                     'fpa.sql.fpa_main_process_pvt.cancel_workflow',
                     'executed wf_engine.SetItemAttrNumber API');
   END IF;

   -- Sets the Due Date
   wf_engine.SetItemAttrDate(itemtype => l_itemtype,
                             itemkey  => l_itemkey,
                             aname    => 'FPA_DUE_DATE',
                             avalue   => p_due_date);

   IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
                     'fpa.sql.fpa_main_process_pvt.cancel_workflow',
                     'executed wf_engine.SetItemAttrDate API');
   END IF;

   -- Starts the workflow process
   wf_engine.StartProcess(itemtype => l_itemtype,
                          itemkey  => l_itemkey);

   IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
                     'fpa.sql.fpa_main_process_pvt.cancel_workflow',
                     'executed wf_engine.StartProcess API');
   END IF;


   IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
                     'fpa.sql.fpa_main_process_pvt.cancel_workflow.end',
                     'Exiting fpa_main_process_pvt.cancel_workflow');
   END IF;

EXCEPTION
   WHEN OTHERS THEN
      IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
         fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
                        'fpa.sql.fpa_main_process_pvt.cancel_workflow.end',
                        SQLERRM);
      END IF;
      wf_core.context('FPA_MAIN_PROCESS_PVT', 'CANCEL_WORKFLOW', null);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.count_and_get(p_count => x_msg_count,
                                p_data  => x_msg_data
                   );
      RAISE;
END CANCEL_WORKFLOW;



-- Launch the main workflow process
PROCEDURE LAUNCH_PROCESS(p_itemtype  IN         VARCHAR2,
             p_itemkey   IN         VARCHAR2,
             p_actid     IN         NUMBER,
             p_funcmode  IN         VARCHAR2,
             x_resultout OUT NOCOPY VARCHAR2)
IS

l_itemtype    VARCHAR2(30) := 'FPAPJP';
l_itemkey     VARCHAR2(30) := null;
l_process     VARCHAR2(30) := 'FPA_MAIN_PROCESS';
l_pc_id       NUMBER       := null;
l_scenario_id NUMBER       := null;
l_due_date    DATE         := null;
l_nextval     NUMBER       := null;

l_return_status VARCHAR2(1)    := null;
l_msg_count     NUMBER         := null;
l_msg_data      VARCHAR2(2000) := null;

l_pc_attributes_rec   PC_ATTRIBUTES_REC_TYPE;

BEGIN

   IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
                     'fpa.sql.fpa_main_process_pvt.launch_process.begin',
                     'Entering fpa_main_process_pvt.launch_process');
   END IF;

   l_pc_id    := wf_engine.GetItemAttrNumber(itemtype => p_itemtype,
                                             itemkey  => p_itemkey,
                                             aname    => 'FPA_PC_ID');
   l_itemtype := 'FPAPJP';
   l_itemkey  := 'FPAL' ||l_pc_id;

   l_due_date := wf_engine.GetItemAttrDate(itemtype => p_itemtype,
                                           itemkey  => p_itemkey,
                                           aname    => 'FPA_DUE_DATE');

   l_scenario_id := wf_engine.GetItemAttrNumber(itemtype => p_itemtype,
                                                itemkey  => p_itemkey,
                                                aname    => 'FPA_SCENARIO_ID');

   IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
                     'fpa.sql.fpa_main_process_pvt.launch_process',
                     'Starting the main workflow process');
   END IF;

   -- Creates the workflow process
   wf_engine.CreateProcess(itemtype => l_itemtype,
                           itemkey  => l_itemkey,
                           process  => l_process);

   -- Sets the Planning Cycle ID
   wf_engine.SetItemAttrNumber(itemtype => l_itemtype,
                               itemkey  => l_itemkey,
                               aname    => 'FPA_PC_ID',
                               avalue   => l_pc_id);

   -- Sets the Scenario ID
   wf_engine.SetItemAttrNumber(itemtype => l_itemtype,
                               itemkey  => l_itemkey,
                               aname    => 'FPA_SCENARIO_ID',
                               avalue   => l_scenario_id);

   -- Sets the Due Date
   wf_engine.SetItemAttrDate(itemtype => l_itemtype,
                             itemkey  => l_itemkey,
                             aname    => 'FPA_DUE_DATE',
                             avalue   => l_due_date);

   -- get and set additional attributes
   GET_WF_ATTRIBUTES(
                 p_pc_id              => l_pc_id,
                 x_pc_attributes_rec  => l_pc_attributes_rec,
                 x_return_status      => l_return_status,
                 x_msg_count          => l_msg_count,
                 x_msg_data           => l_msg_data);


   -- Set the attributes

   wf_engine.SetItemAttrText(itemtype => l_itemtype,
                             itemkey  => l_itemkey,
                             aname    => 'FPA_PORTFOLIO_NAME',
                             avalue   => l_pc_attributes_rec.portfolio_name);

   wf_engine.SetItemAttrText(itemtype => l_itemtype,
                             itemkey  => l_itemkey,
                             aname    => 'FPA_PC_NAME',
                             avalue   => l_pc_attributes_rec.pc_name);


   -- Starts the workflow process
   wf_engine.StartProcess(itemtype => l_itemtype,
                          itemkey  => l_itemkey);

   IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
                     'fpa.sql.fpa_main_process_pvt.launch_process.end',
                     'Exiting fpa_main_process_pvt.launch_process');
   END IF;

EXCEPTION
   WHEN OTHERS THEN
      IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
         fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
                        'fpa.sql.fpa_main_process_pvt.launch_process.end',
                        SQLERRM);
      END IF;
      wf_core.context('FPA_MAIN_PROCESS_PVT', 'LAUNCH_PROCESS', null);
      RAISE;
END LAUNCH_PROCESS;

PROCEDURE RAISE_CLOSEPC_EVENT(p_pc_id             IN         NUMBER,
                  x_return_status     OUT NOCOPY VARCHAR2,
                  x_msg_count         OUT NOCOPY NUMBER,
                  x_msg_data          OUT NOCOPY VARCHAR2
                 ) IS

l_parameter_list wf_parameter_list_t;
l_itemkey        VARCHAR2(30);

CURSOR C_abort_activepcwf IS
SELECT item_type,item_key,root_activity
  FROM wf_items
 WHERE item_type = 'FPAPJP'
   AND (item_key  = 'FPAL'|| p_pc_id OR item_key  = 'FPAF'|| p_pc_id OR item_key = to_char(p_pc_id))
   AND end_date IS NULL;

BEGIN

   IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
                     'fpa.sql.fpa_main_process_pvt.raise_closepc_event.begin',
                     'Entering fpa_main_process_pvt.raise_closepc_event for p_pc_id'||p_pc_id);
   END IF;

   FOR c_rec IN C_abort_activepcwf LOOP

           IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                                         fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
                                                        'fpa.sql.fpa_main_process_pvt.raise_closepc_event',
                                                        'Aborting workflow process '||c_rec.item_key);
           END IF;

       -- Cancels all the workflow process associated with this Planning cycle
       wf_engine.AbortProcess(itemtype => c_rec.item_type,
                  itemkey  => c_rec.item_key,
                  process  => c_rec.root_activity);

   END LOOP;

   -- Code to start new workflow process for Closing Planning cycle
   l_itemkey  := 'FPAC'||p_pc_id;

   IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
          fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
                         'fpa.sql.fpa_main_process_pvt.raise_closepc_event',
                         'Calling  wf_event.AddParameterToList ');
   END IF;

   wf_event.AddParameterToList('FPA_PC_ID',p_pc_id,l_parameter_list);

   IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
          fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
                         'fpa.sql.fpa_main_process_pvt.raise_closepc_event',
                         'Raising event oracle.apps.fpa.event.planningcycle.closed');
   END IF;

   -- Raise Event
   wf_event.RAISE(p_event_name => 'oracle.apps.fpa.event.planningcycle.closed',
                   p_event_key  => l_itemkey,
                   p_parameters => l_parameter_list);

   l_parameter_list.DELETE;

   IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
                     'fpa.sql.fpa_main_process_pvt.raise_closepc_event.end',
                     'Entering fpa_main_process_pvt.raise_closepc_event');
   END IF;

EXCEPTION
   WHEN OTHERS THEN
      IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
         fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
                        'fpa.sql.fpa_main_process_pvt.raise_closepc_event.exception',
                        SQLERRM);
      END IF;
      RAISE;
END RAISE_CLOSEPC_EVENT;



PROCEDURE GET_USERS                (p_pcid         IN         VARCHAR2,
                                    p_notify_role  IN         VARCHAR2,
                    p_approver     IN         VARCHAR2,
                    p_analyst      IN         VARCHAR2,
                    p_pcdlist      IN         VARCHAR2,
                    p_projmg       IN         VARCHAR2,
                            p_user_exists  OUT NOCOPY VARCHAR2 )
IS

l_user           fnd_user.user_name%type := null;
l_user_org_id    NUMBER;
l_user_exists    varchar2(1) := 'N';

l_pjp_org_version_id   NUMBER;
l_portfolio_org_id     NUMBER;
l_flag                 VARCHAR2(1);

-- Select the list of users defined in the portfolio access list who has to be notified.
-- Also verify the user has an active assignment as of sysdate .

CURSOR c_get_port_users  IS
   SELECT DISTINCT u.user_name, prd.organization_id
     FROM pa_project_parties ppp,
          pa_project_role_types pprt,
          per_all_people_f pe,
          per_all_assignments_f prd,
          fnd_user u ,
      FPA_AW_PC_INFO_V pc
    WHERE ppp.resource_type_id = 101
      AND ppp.project_role_id = pprt.project_role_id
      AND ppp.resource_source_id = pe.person_id
      AND trunc(sysdate) BETWEEN trunc(ppp.start_date_active)   AND trunc(NVL(ppp.end_date_active,sysdate))
      AND trunc(sysdate) BETWEEN trunc(pe.effective_start_date)   AND trunc(pe.effective_end_date)
      AND ppp.resource_source_id = prd.person_id
      AND prd.primary_flag = 'Y'
      AND prd.assignment_type = 'E'
      AND trunc(sysdate) BETWEEN trunc(prd.effective_start_date)  AND trunc(prd.effective_end_date)
      AND u.employee_id = ppp.resource_source_id
      AND ppp.object_type = 'PJP_PORTFOLIO'
      AND ppp.object_id = pc.portfolio
      AND ((p_approver = 'Y' and p_analyst = 'Y' and pprt.project_role_type IN ('PORTFOLIO_APPROVER', 'PORTFOLIO_ANALYST')) OR
           (p_approver = 'Y' and p_analyst = 'N' and pprt.project_role_type = 'PORTFOLIO_APPROVER') OR
           (p_approver = 'N' and p_analyst = 'Y' and pprt.project_role_type = 'PORTFOLIO_ANALYST'))
      AND pc.planning_cycle = p_pcid;

Cursor c_get_dlist_users IS
   SELECT DISTINCT ppp.user_name, ppp.organization_id -- select to fetch persons attached to the role defined in the access list
     FROM pa_dist_list_items i,
          pa_project_parties_v ppp,
          pa_object_dist_lists podl
    WHERE i.recipient_type = 'PROJECT_ROLE'
      AND i.list_id = podl.list_id
      AND podl.object_id = p_pcid
      AND podl.object_type = 'PJP_PLANNING_CYCLE'
      AND ppp.resource_type_id = 101
      AND ppp.project_role_id = i.recipient_id
      and ppp.user_id IS NOT NULL -- To prevent invalid user name error during workflow
    UNION
   SELECT DISTINCT u.user_name, a.organization_id    -- select to fetch persons defined in the access list
   FROM pa_dist_list_items i,
        pa_object_dist_lists podl,
        hz_parties hzp,
        fnd_user u,
        per_all_assignments_f a, per_all_people_f p
   WHERE i.recipient_type = 'HZ_PARTY'
      AND i.list_id = podl.list_id
      AND podl.object_id = p_pcid
      AND podl.object_type = 'PJP_PLANNING_CYCLE'
      AND hzp.party_id =  i.recipient_id
      AND hzp.party_type = 'PERSON'
      AND u.person_party_id = hzp.party_id
      AND p.person_id = a.person_id
      AND hzp.party_id = p.party_id (+);


Cursor c_get_projmg_users IS
select distinct u.user_name
  from fpa_aw_sce_info_v sc,
       fpa_aw_proj_info_v proj,
       pa_project_players pp,
       fnd_user u
where proj.scenario = sc.scenario
  and sc.planning_cycle = p_pcid
  and sc.approved_flag = 1
  and pp.project_id = proj.project
  and pp.resource_type_id =101
  and pp.project_role_type = 'PROJECT MANAGER'
  and u.employee_id = pp.person_id
  AND trunc(sysdate) BETWEEN trunc(pp.start_date_active)   AND trunc(NVL(pp.end_date_active,sysdate));

CURSOR verify_user_org_csr(
            p_hier_version_id     IN NUMBER,
            p_portfolio_org_id    IN NUMBER,
            p_user_org_id         IN NUMBER) is
SELECT 'T' FROM (
    SELECT
      organization_id_child
    FROM
      per_org_structure_elements
    WHERE
      org_structure_version_id = p_hier_version_id
      CONNECT BY PRIOR organization_id_child = organization_id_parent
      AND PRIOR org_structure_version_id = p_hier_version_id
      START WITH organization_id_parent = p_portfolio_org_id  )
    WHERE organization_id_child = p_user_org_id;

BEGIN

   -- Get the list of users to be notified
   IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
                     'fpa.sql.fpa_main_process_pvt.GET_USERS.begin',
                     'Entering fpa_main_process_pvt.GET_USERS for p_pcid '||p_pcid);
   END IF;

   select
   org_structure_version_id into l_pjp_org_version_id
   from
       per_org_structure_versions
   where
       organization_structure_id = FND_PROFILE.VALUE('PJP_ORGANIZATION_HIERARCHY')
       and (trunc(sysdate) between trunc(date_from) and trunc(nvl(date_to,
       sysdate)));

   select
        portfolio_organization into l_portfolio_org_id
   from
        fpa_aw_pcs_v pcp, fpa_aw_portf_headers_v ph
   where
        pcp.portfolio = ph.portfolio
        and pcp.planning_cycle = p_pcid;

   IF p_approver = 'Y'  OR  p_analyst = 'Y' THEN

    IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
                     'fpa.sql.fpa_main_process_pvt.GET_USERS.begin',
                     'Fetching users associated with portfolio access list');
    END IF;

     OPEN  c_get_port_users;
      LOOP
     FETCH c_get_port_users INTO l_user, l_user_org_id;
         EXIT WHEN c_get_port_users%NOTFOUND;

     if(l_portfolio_org_id is not null and l_portfolio_org_id = l_user_org_id) then
         l_flag := FND_API.G_TRUE;
     elsif(l_portfolio_org_id is not null) then
         l_flag := null;
         open verify_user_org_csr(l_pjp_org_version_id,
                                  l_portfolio_org_id,
                                  l_user_org_id);
         fetch verify_user_org_csr into l_flag;
         close verify_user_org_csr;
     else
         l_flag := FND_API.G_TRUE;
     end if;

     if(l_flag = FND_API.G_TRUE) then
         -- Add users to the role.
         wf_directory.AddUsersToAdHocRole(role_name  => p_notify_role,
                                          role_users => l_user);
         IF l_user_exists ='N' then
            l_user_exists := 'Y';
         END If;

     end if;
   END LOOP;
   CLOSE c_get_port_users ;

   END IF;

   IF p_pcdlist = 'Y' THEN

    IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
                     'fpa.sql.fpa_main_process_pvt.GET_USERS.begin',
                     'Fetching users associated with planning cycle distribution list');
    END IF;

     OPEN  c_get_dlist_users;
      LOOP
     FETCH c_get_dlist_users INTO l_user, l_user_org_id;
         EXIT WHEN c_get_dlist_users%NOTFOUND;

     if(l_portfolio_org_id is not null and l_portfolio_org_id = l_user_org_id) then
         l_flag := FND_API.G_TRUE;
     elsif(l_portfolio_org_id is not null) then
         l_flag := null;
         open verify_user_org_csr(l_pjp_org_version_id,
                                  l_portfolio_org_id,
                                  l_user_org_id);
         fetch verify_user_org_csr into l_flag;
         close verify_user_org_csr;
     else
         l_flag := FND_API.G_TRUE;
     end if;
     if(l_flag = FND_API.G_TRUE) then
         -- Add users to the role.
         wf_directory.AddUsersToAdHocRole(role_name  => p_notify_role,
                                          role_users => l_user);
         IF l_user_exists ='N' then
            l_user_exists := 'Y';
         END If;
     end if;
   END LOOP;
   CLOSE c_get_dlist_users ;

   END IF;

   IF p_projmg = 'Y' THEN

    IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
                     'fpa.sql.fpa_main_process_pvt.GET_USERS.begin',
                     'Fetching users associated with project managers');
    END IF;

     OPEN  c_get_projmg_users;
      LOOP
     FETCH c_get_projmg_users INTO l_user;
         EXIT WHEN c_get_projmg_users%NOTFOUND;
         -- Add users to the role.
         wf_directory.AddUsersToAdHocRole(role_name  => p_notify_role,
                                          role_users => l_user);
         IF l_user_exists ='N' then
            l_user_exists := 'Y';
         END If;

      END LOOP;
     CLOSE c_get_projmg_users ;

   END IF;

   IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
                     'fpa.sql.fpa_main_process_pvt.GET_USERS.end',
                     'Exiting fpa_main_process_pvt.GET_USERS l_user_exists value '||l_user_exists);
   END IF;

p_user_exists := l_user_exists;

EXCEPTION
   WHEN OTHERS THEN
      IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
         fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
            'fpa.sql.fpa_main_process_pvt.GET_USERS.end',
            SQLERRM);
      END IF;

      IF c_get_port_users%ISOPEN THEN
         close c_get_port_users;
      END IF;

      IF c_get_dlist_users%ISOPEN THEN
         close c_get_dlist_users;
      END IF;

      IF c_get_projmg_users%ISOPEN THEN
         close c_get_projmg_users;
      END IF;

      p_user_exists := 'N';
      RAISE;
END  GET_USERS;

PROCEDURE CREATE_ROLE ( p_item_type   IN         VARCHAR2,
                p_item_key    IN         VARCHAR2,
            p_calledfrom  IN         VARCHAR2,
            p_user_exists OUT NOCOPY VARCHAR2) IS

l_pc_id            NUMBER        := null;
l_user_exists      VARCHAR2(1)   := 'N';
l_approver         VARCHAR2(1)   := 'N';
l_analyst          VARCHAR2(1)   := 'N';
l_pcdlist          VARCHAR2(1)   := 'N';
l_projmg           VARCHAR2(1)   := 'N';
l_notify_role      wf_roles.name%TYPE := NULL;

WF_API_EXCEPTION        exception;
pragma exception_init(WF_API_EXCEPTION, -20002);

BEGIN

   IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
                     'fpa.sql.fpa_main_process_pvt.create_role.begin',
                     'Entering fpa_main_process_pvt.create_role');
   END IF;

   -- Get the planning cycle ID
  l_pc_id := wf_engine.GetItemAttrNumber(itemtype => p_item_type,
                                          itemkey  => p_item_key,
                                          aname    => 'FPA_PC_ID');

  IF p_calledfrom = g_get_port_users THEN
     l_notify_role := 'FPA_APPR_ANALY_' || l_pc_id;
     l_approver    := 'Y';
     l_analyst     := 'Y';
  ELSIF p_calledfrom = g_get_pc_dlist THEN
     l_notify_role := 'FPA_PC_APPROVERS_' || l_pc_id;
     l_pcdlist     := 'Y';
  ELSIF p_calledfrom = g_get_port_apprv THEN
     l_notify_role := 'FPA_APPROVER_' || l_pc_id;
     l_approver    := 'Y';
  ELSIF p_calledfrom = g_get_port_analyst THEN
     l_notify_role := 'FPA_ANALYST_' || l_pc_id;
     l_analyst    := 'Y';
  ELSIF p_calledfrom = g_get_pc_manager THEN
     l_notify_role := 'FPA_PC_MANAGERS_' || l_pc_id;
     l_approver    := 'Y';
     l_analyst     := 'Y';
     l_projmg      := 'Y';
  END IF;

   IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
                     'fpa.sql.fpa_main_process_pvt.create_role.begin',
                     'value of l_notify_role='||l_notify_role||'l_approver='||l_approver||'l_analyst='||l_analyst||'l_pcdlist='||l_pcdlist||'l_projmg='||l_projmg);
   END IF;

   -- Create adhoc role. This will be used to send the notifications
   -- to members of this role.
   BEGIN
           wf_directory.CreateAdHocRole(role_name         => l_notify_role,
                                        role_display_name => l_notify_role,
                                        role_users        => null,
                                        email_address     => null);
   EXCEPTION
      WHEN WF_API_EXCEPTION THEN
      IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
         fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
            'fpa.sql.fpa_main_process_pvt.CREATE_ROLE.exception',
            SQLERRM);
      END IF;

   END;

   -- Delete the users if already existing from the above role :
   wf_directory.RemoveUsersFromAdhocRole(role_name => l_notify_role);

   -- Need to notify Project Managers
   wf_engine.SetItemAttrText(itemtype => p_item_type,
                             itemkey  => p_item_key,
                             aname    => 'FPA_PROJ_MANAGERS',
                             avalue   => l_notify_role);

   GET_USERS     (p_pcid         => l_pc_id,
                  p_notify_role  => l_notify_role,
              p_approver     => l_approver,
              p_analyst      => l_analyst,
          p_pcdlist      => l_pcdlist,
          p_projmg       => l_projmg,
                  p_user_exists  => l_user_exists ) ;

   p_user_exists := l_user_exists;

   IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
                     'fpa.sql.fpa_main_process_pvt.create_role.end',
                     'Entering fpa_main_process_pvt.create_role,value of  p_user_exists'||p_user_exists);
   END IF;

EXCEPTION
   WHEN OTHERS THEN
      IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
         fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
            'fpa.sql.fpa_main_process_pvt.CREATE_ROLE.end',
            SQLERRM);
      END IF;
      wf_core.context('FPA_MAIN_PROCESS_PVT', 'CREATE_ROLE', SQLERRM);
      RAISE;
END CREATE_ROLE;

-- Workflow Procedure to fetch all the users defined in the distribution list of the
-- planning cycle.

PROCEDURE GET_DLIST(p_itemtype  IN         VARCHAR2,
            p_itemkey   IN         VARCHAR2,
            p_actid     IN         NUMBER,
            p_funcmode  IN         VARCHAR2,
            x_resultout OUT NOCOPY VARCHAR2)
IS

l_user_exists     VARCHAR2(1) := 'N';

BEGIN

   /* Get the list of users having project manager role */
   IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
                     'fpa.sql.fpa_main_process_pvt.get_dlist.begin',
                     'Entering fpa_main_process_pvt.get_dlist');
   END IF;

   -- Do not perform anything in CANCEL or TIMEOUT mode
   IF (p_funcmode <> wf_engine.eng_run) THEN
      x_resultout := wf_engine.eng_null;
      RETURN;
   END IF;

   CREATE_ROLE ( p_item_type   => p_itemtype,
             p_item_key    => p_itemkey ,
         p_calledfrom  => g_get_pc_dlist,
         p_user_exists => l_user_exists);

   IF l_user_exists = 'Y' then
      x_resultout := wf_engine.eng_completed||':'||'T';
   ELSE
      x_resultout := wf_engine.eng_completed||':'||'F';
   END IF;


   IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
                     'fpa.sql.fpa_main_process_pvt.get_dlist.end',
                     'Exiting fpa_main_process_pvt.get_dlist');
   END IF;

EXCEPTION
   WHEN OTHERS THEN
      IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
         fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
            'fpa.sql.fpa_main_process_pvt.get_dlist.end',
            SQLERRM);
      END IF;
      wf_core.context('FPA_MAIN_PROCESS_PVT', g_get_pc_dlist, SQLERRM);
      RAISE;
END GET_DLIST;


-- Workflow Procedure to fetch all the users defined in the access list of the
-- portfolio.
PROCEDURE GET_ALIST(p_itemtype  IN         VARCHAR2,
            p_itemkey   IN         VARCHAR2,
            p_actid     IN         NUMBER,
            p_funcmode  IN         VARCHAR2,
            x_resultout OUT NOCOPY VARCHAR2)
IS

l_user_exists VARCHAR2(1) := 'N';

BEGIN

   -- Get the list of users to be notified
   IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
                     'fpa.sql.fpa_main_process_pvt.get_alist.begin',
                     'Entering fpa_main_process_pvt.get_alist');
   END IF;

   -- Do not perform anything in CANCEL or TIMEOUT mode
   IF (p_funcmode <> wf_engine.eng_run) THEN
      x_resultout := wf_engine.eng_null;
      RETURN;
   END IF;

   CREATE_ROLE ( p_item_type   => p_itemtype,
             p_item_key    => p_itemkey ,
         p_calledfrom  => g_get_port_users,
         p_user_exists => l_user_exists);

   IF l_user_exists = 'Y' then
      x_resultout := wf_engine.eng_completed||':'||'T';
   ELSE
      x_resultout := wf_engine.eng_completed||':'||'F';
   END IF;

   IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
                     'fpa.sql.fpa_main_process_pvt.get_alist.end',
                     'Exiting fpa_main_process_pvt.get_alist');
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
         fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
            'fpa.sql.fpa_main_process_pvt.get_alist.end',
            SQLERRM);
      END IF;
      wf_core.context('FPA_MAIN_PROCESS_PVT', g_get_port_users, SQLERRM);
      RAISE;
END GET_ALIST;

-- Workflow Procedure to fetch all the users defined as portfolio approvers

PROCEDURE GET_APPROVER(p_itemtype  IN         VARCHAR2,
               p_itemkey   IN         VARCHAR2,
               p_actid     IN         NUMBER,
               p_funcmode  IN         VARCHAR2,
               x_resultout OUT NOCOPY VARCHAR2)
IS

l_user_exists     VARCHAR2(1) := 'N';

BEGIN

   /* Get the list of users having project manager role */
   IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
                     'fpa.sql.fpa_main_process_pvt.get_approver.begin',
                     'Entering fpa_main_process_pvt.get_approver');
   END IF;

   -- Do not perform anything in CANCEL or TIMEOUT mode
   IF (p_funcmode <> wf_engine.eng_run) THEN
      x_resultout := wf_engine.eng_null;
      RETURN;
   END IF;

   CREATE_ROLE ( p_item_type   => p_itemtype,
             p_item_key    => p_itemkey ,
         p_calledfrom  => g_get_port_apprv,
         p_user_exists => l_user_exists);

   IF l_user_exists = 'Y' then
      x_resultout := wf_engine.eng_completed||':'||'T';
   ELSE
      x_resultout := wf_engine.eng_completed||':'||'F';
   END IF;


   IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
                     'fpa.sql.fpa_main_process_pvt.get_approver.end',
                     'Exiting fpa_main_process_pvt.get_approver');
   END IF;

EXCEPTION
   WHEN OTHERS THEN
      IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
         fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
            'fpa.sql.fpa_main_process_pvt.get_approver.end',
            SQLERRM);
      END IF;
      wf_core.context('FPA_MAIN_PROCESS_PVT', 'GET_DLIST', SQLERRM);
      RAISE;
END GET_APPROVER;


-- Workflow Procedure to fetch all the users defined as portfolio analyst
PROCEDURE GET_ANALYST(p_itemtype  IN         VARCHAR2,
               p_itemkey   IN         VARCHAR2,
               p_actid     IN         NUMBER,
               p_funcmode  IN         VARCHAR2,
               x_resultout OUT NOCOPY VARCHAR2)
IS

l_user_exists     VARCHAR2(1) := 'N';

BEGIN

   /* Get the list of users having project manager role */
   IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
                     'fpa.sql.fpa_main_process_pvt.get_analyst.begin',
                     'Entering fpa_main_process_pvt.get_analyst');
   END IF;

   -- Do not perform anything in CANCEL or TIMEOUT mode
   IF (p_funcmode <> wf_engine.eng_run) THEN
      x_resultout := wf_engine.eng_null;
      RETURN;
   END IF;

   CREATE_ROLE ( p_item_type   => p_itemtype,
             p_item_key    => p_itemkey ,
         p_calledfrom  => g_get_port_analyst,
         p_user_exists => l_user_exists);

   IF l_user_exists = 'Y' then
      x_resultout := wf_engine.eng_completed||':'||'T';
   ELSE
      x_resultout := wf_engine.eng_completed||':'||'F';
   END IF;


   IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
                     'fpa.sql.fpa_main_process_pvt.get_analyst.end',
                     'Exiting fpa_main_process_pvt.get_analyst');
   END IF;

EXCEPTION
   WHEN OTHERS THEN
      IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
         fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
            'fpa.sql.fpa_main_process_pvt.get_analyst.end',
            SQLERRM);
      END IF;
      wf_core.context('FPA_MAIN_PROCESS_PVT', g_get_port_analyst, SQLERRM);
      RAISE;
END GET_ANALYST;



-- Workflow Procedure to fetch all the users defined as portfolio analyst ,
-- portfolio approver and proget managers associated with projects within a approved scenario

PROCEDURE GET_PC_MANAGERS(p_itemtype  IN         VARCHAR2,
                  p_itemkey   IN         VARCHAR2,
                  p_actid     IN         NUMBER,
                      p_funcmode  IN         VARCHAR2,
                  x_resultout OUT NOCOPY VARCHAR2)
IS

l_user_exists     VARCHAR2(1) := 'N';

BEGIN

   /* Get the list of users having project manager role */
   IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
                     'fpa.sql.fpa_main_process_pvt.get_pc_managers.begin',
                     'Entering fpa_main_process_pvt.get_pc_managers');
   END IF;

   -- Do not perform anything in CANCEL or TIMEOUT mode
   IF (p_funcmode <> wf_engine.eng_run) THEN
      x_resultout := wf_engine.eng_null;
      RETURN;
   END IF;

   CREATE_ROLE ( p_item_type   => p_itemtype,
             p_item_key    => p_itemkey ,
         p_calledfrom  => g_get_pc_manager,
         p_user_exists => l_user_exists);

   IF l_user_exists = 'Y' then
      x_resultout := wf_engine.eng_completed||':'||'T';
   ELSE
      x_resultout := wf_engine.eng_completed||':'||'F';
   END IF;


   IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
                     'fpa.sql.fpa_main_process_pvt.get_pc_managers.end',
                     'Exiting fpa_main_process_pvt.get_pc_managers');
   END IF;

EXCEPTION
   WHEN OTHERS THEN
      IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
         fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
            'fpa.sql.fpa_main_process_pvt.get_pc_managers.end',
            SQLERRM);
      END IF;
      wf_core.context('FPA_MAIN_PROCESS_PVT', g_get_pc_manager, SQLERRM);
      RAISE;
END GET_PC_MANAGERS;

/* Wrapper calls */
/* Project load */
-- calls Project Load api
PROCEDURE CALL_PROJ_LOAD(p_itemtype  IN         VARCHAR2,
             p_itemkey   IN         VARCHAR2,
             p_actid     IN         NUMBER,
             p_funcmode  IN         VARCHAR2,
             x_resultout OUT NOCOPY VARCHAR2)
IS

l_return_status VARCHAR2(1)    := null;
l_msg_count     NUMBER         := null;
l_msg_data      VARCHAR2(2000) := null;

BEGIN
   -- Not used anywhere
   x_resultout := null;

EXCEPTION
   WHEN OTHERS THEN
      IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
         fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
            'fpa.sql.fpa_main_process_pvt.call_proj_load.end',
            SQLERRM);
      END IF;
      wf_core.context('FPA_MAIN_PROCESS_PVT', 'CALL_PROJ_LOAD', SQLERRM);
      RAISE;
END CALL_PROJ_LOAD;



/* Create Initial Scenario */
-- calls Create Initial Scenario api
PROCEDURE CALL_CREATE_INITIAL_SCENARIO(p_itemtype  IN         VARCHAR2,
                       p_itemkey   IN         VARCHAR2,
                       p_actid     IN         NUMBER,
                       p_funcmode  IN         VARCHAR2,
                       x_resultout OUT NOCOPY VARCHAR2)
IS

l_pc_id          NUMBER                        := null;
l_scenario_id    NUMBER                        := null;
l_scenario_funds NUMBER                        := null;
l_discount_rate  NUMBER                        := null;
l_return_status  VARCHAR2(1)                   := null;
l_msg_count      NUMBER                        := null;
l_msg_data       VARCHAR2(2000)                := null;
l_scenario_name  fpa_lookups_v.meaning%TYPE    := null;
l_scenario_desc  fpa_lookups_v.meaning%TYPE    := null;

BEGIN

   IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
                     'fpa.sql.fpa_main_process_pvt.call_create_initial_scenario.begin',
                     'Entering fpa_main_process_pvt.call_create_initial_scenario');
   END IF;

   IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
                     'fpa.sql.fpa_main_process_pvt.call_create_initial_scenario.begin',
                     'Getting Planning Cycle ID.');
   END IF;


   -- Get the Planning Cycle ID
   l_pc_id := wf_engine.GetItemAttrNumber(itemtype => p_itemtype,
                                          itemkey  => p_itemkey,
                                          aname    => 'FPA_PC_ID');

   IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
                     'fpa.sql.fpa_main_process_pvt.call_create_initial_scenario.begin',
                     'Getting Initial scenario name.');
   END IF;

   -- Get the Initial Scenario name and description
   BEGIN
      SELECT meaning
        INTO l_scenario_name
        FROM fpa_lookups_v
       WHERE lookup_code = 'FPA_INITIAL_SCENARIO_NAME';
   EXCEPTION
      WHEN OTHERS THEN
         null;
   END;

   IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
                     'fpa.sql.fpa_main_process_pvt.call_create_initial_scenario.begin',
                     'Getting discount rate and funds available.');
   END IF;

   -- Get the discount rate and funds available
   -- We need to multiply the PC rate by 100 because the scenario discount rate
   -- assume the number is a whole number, however the PC is a decimal number
   BEGIN
      SELECT pc_discount_rate * 100,
             pc_funding
        INTO l_discount_rate,
             l_scenario_funds
        FROM fpa_aw_pc_disc_funds_v
       WHERE planning_cycle = l_pc_id;
   EXCEPTION
      WHEN OTHERS THEN
         null;
   END;

   -- Initial Scenario description is the same as name
   l_scenario_desc := l_scenario_name;

   IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
                     'fpa.sql.fpa_main_process_pvt.call_create_initial_scenario.begin',
                     'Calling fpa_scenario_pvt.create_scenario.');
   END IF;

   -- Create a scenario
   fpa_scenario_pvt.create_scenario(
      p_api_version   => 1.0,
      p_scenario_name => l_scenario_name,
      p_scenario_desc => l_scenario_desc,
      p_pc_id         => l_pc_id,
      x_scenario_id   => l_scenario_id,
      x_return_status => l_return_status,
      x_msg_count     => l_msg_count,
      x_msg_data      => l_msg_data);

   IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
                     'fpa.sql.fpa_main_process_pvt.call_create_initial_scenario.begin',
                     'Calling fpa_scenario_pvt.update_scenario_disc_rate.');
   END IF;

   -- Set the discount rate
   fpa_scenario_pvt.update_scenario_disc_rate(
      p_api_version   => 1.0,
      p_scenario_id   => l_scenario_id,
      p_discount_rate => l_discount_rate,
      x_return_status => l_return_status,
      x_msg_count     => l_msg_count,
      x_msg_data      => l_msg_data);

   IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
                     'fpa.sql.fpa_main_process_pvt.call_create_initial_scenario.',
                     'Calling fpa_scenario_pvt.update_scenario_funds_avail.');
   END IF;

   -- Set the funds available
   fpa_scenario_pvt.update_scenario_funds_avail(
      p_api_version    => 1.0,
      p_scenario_id    => l_scenario_id,
      p_scenario_funds => l_scenario_funds,
      x_return_status  => l_return_status,
      x_msg_count      => l_msg_count,
      x_msg_data       => l_msg_data);


   IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
                     'fpa.sql.fpa_main_process_pvt.call_create_initial_scenario.',
                     'Calling fpa_scenario_pvt.update_scenario_initial_flag.');
   END IF;

   -- Set scenario just created as the Initial Scenario
   fpa_scenario_pvt.update_scenario_initial_flag(
      p_api_version   => 1.0,
      p_scenario_id   => l_scenario_id,
      x_return_status => l_return_status,
      x_msg_count     => l_msg_count,
      x_msg_data      => l_msg_data);

   IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
                     'fpa.sql.fpa_main_process_pvt.call_create_initial_scenario.',
                     'Calling fpa_scenario_pvt.update_scenario_working_flag.');
   END IF;

   -- Set scenario just created as the Working Scenario.
   fpa_scenario_pvt.update_scenario_working_flag(
      p_api_version   => 1.0,
      p_scenario_id   => l_scenario_id,
      x_return_status => l_return_status,
      x_msg_count     => l_msg_count,
      x_msg_data      => l_msg_data);

   IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
                     'fpa.sql.fpa_main_process_pvt.call_create_initial_scenario.',
                     'Calling Fpa_Project_Pvt.Load_Project_Details_Aw.');
   END IF;

  Fpa_Project_Pvt.Load_Project_Details_Aw(
    p_api_version => 1.0,
    p_init_msg_list => FND_API.G_FALSE,
    p_type          => 'COLLECT',
    p_scenario_id => l_scenario_id,
    p_projects => null,
    x_return_status => l_return_status,
    x_msg_count => l_msg_count,
    x_msg_data => l_msg_data
   );

   IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
                     'fpa.sql.fpa_main_process_pvt.call_create_initial_scenario.',
                     'Calling fpa_scenario_pvt.calc_scenario_data.');
   END IF;

  fpa_scenario_pvt.calc_scenario_data
  (
    p_api_version => 1.0,
    p_scenario_id => l_scenario_id,
    p_project_id => null,
    p_class_code_id => null,
    p_data_to_calc => 'ALL',
    x_return_status => l_return_status,
    x_msg_count => l_msg_count,
    x_msg_data => l_msg_data
  );

   IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
                     'fpa.sql.fpa_main_process_pvt.call_create_initial_scenario.',
                     'Calling fpa_scorecard_pvt.calc_scenario_data.');
   END IF;

  fpa_scorecards_pvt.Calc_Scenario_Wscores_Aw
  (
    p_api_version => 1.0,
    p_init_msg_list => FND_API.G_FALSE,
    p_scenario_id => l_scenario_id,
    x_return_status => l_return_status,
    x_msg_count => l_msg_count,
    x_msg_data => l_msg_data
  );


   IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
                     'fpa.sql.fpa_main_process_pvt.call_create_initial_scenario.begin',
                     'Calling wf_engine.SetItemAttrNumber.');
   END IF;

   wf_engine.SetItemAttrNumber(itemtype => p_itemtype,
                               itemkey  => p_itemkey,
                               aname    => 'FPA_SCENARIO_ID',
                               avalue   => l_scenario_id);

   x_resultout := null;

EXCEPTION
   WHEN OTHERS THEN
      IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
         fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
            'fpa.sql.fpa_main_process_pvt.call_create_initial_scenario.end',
            SQLERRM);
      END IF;

      wf_core.context('FPA_MAIN_PROCESS_PVT',
                      'CALL_CREATE_INITIAL_SCENARIO',
                      SQLERRM);

      /*
      -- Detach AW Workspace
      fpa_utilities_pvt.detach_AW(p_api_version   => 1.0,
                                  x_return_status => l_return_status,
                                  x_msg_count     => l_msg_count,
                                  x_msg_data      => l_msg_data);
      */
      RAISE;
END CALL_CREATE_INITIAL_SCENARIO;



/* Set Status */
PROCEDURE CALL_SET_STATUS(p_itemtype  IN         VARCHAR2,
              p_itemkey   IN         VARCHAR2,
              p_actid     IN         NUMBER,
              p_funcmode  IN         VARCHAR2,
              x_resultout OUT NOCOPY VARCHAR2)
IS

l_return_status  VARCHAR2(1)                     := null;
l_msg_count      NUMBER                          := null;
l_msg_data       VARCHAR2(2000)                  := null;
l_pc_id          NUMBER                          := null;
l_pc_status      fpa_aw_pc_info_v.pc_status%TYPE := null;

BEGIN

   -- Get the Planning Cycle ID
   l_pc_id := wf_engine.GetItemAttrNumber(itemtype => p_itemtype,
                                          itemkey  => p_itemkey,
                                          aname    => 'FPA_PC_ID');

   l_pc_status := 'CREATED';

   -- Call the Set Status API to set the Planning Cycle
   fpa_planningcycle_pvt.set_pc_status(p_api_version    => 1.0,
                                       p_pc_id          => l_pc_id,
                                       p_pc_status_code => l_pc_status,
                                       x_return_status  => l_return_status,
                                       x_msg_count      => l_msg_count,
                                       x_msg_data       => l_msg_data);

   x_resultout := wf_engine.eng_null;

EXCEPTION
   WHEN OTHERS THEN
      IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
         fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
                        'fpa.sql.fpa_main_process_pvt.call_set_status.end',
                        SQLERRM);
      END IF;
      wf_core.context('FPA_MAIN_PROCESS_PVT', 'CALL_SET_STATUS', SQLERRM);
      RAISE;
END CALL_SET_STATUS;



/* Call Project Sets */
-- calls the Project Sets API
PROCEDURE CALL_PROJECT_SETS(p_itemtype  IN         VARCHAR2,
                p_itemkey   IN         VARCHAR2,
                p_actid     IN         NUMBER,
                p_funcmode  IN         VARCHAR2,
                x_resultout OUT NOCOPY VARCHAR2)
IS

l_return_status VARCHAR2(1)            := null;
l_msg_count     NUMBER                 := null;
l_msg_data      VARCHAR2(2000)         := null;
l_scen_id       NUMBER                 := null;

BEGIN

   IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
                     'fpa.sql.fpa_main_process_pvt.call_project_sets.begin',
                     'Entering fpa_main_process_pvt.call_project_sets');
   END IF;

   -- Gets the Scenario ID
   l_scen_id := wf_engine.GetItemAttrNumber(itemtype => p_itemtype,
                                            itemkey => p_itemkey,
                                            aname => 'FPA_SCENARIO_ID');


   -- Call the Project Sets API
   fpa_portfolio_project_sets_pvt.add_project_set_lines(
      p_api_version   => 1.0,
      p_scen_id       => l_scen_id,
      x_return_status => l_return_status,
      x_msg_data      => l_msg_data,
      x_msg_count     => l_msg_count);

   IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
                     'fpa.sql.fpa_main_process_pvt.call_project_sets.end',
                     'Exiting fpa_main_process_pvt.call_project_sets');
   END IF;

   x_resultout := wf_engine.eng_null;

EXCEPTION
   WHEN OTHERS THEN
      IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
         fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
                        'fpa.sql.fpa_main_process_pvt.call_project_sets.end',
                        SQLERRM);
      END IF;
      wf_core.context('FPA_MAIN_PROCESS_PVT', 'CALL_PROJECT_SETS', SQLERRM);

      /*
      -- Detach AW Workspace
      fpa_utilities_pvt.detach_AW(p_api_version   => 1.0,
                                  x_return_status => l_return_status,
                                  x_msg_count     => l_msg_count,
                                  x_msg_data      => l_msg_data);
      */
      RAISE;
END CALL_PROJECT_SETS;



/* Is Plan Approved */
-- Checks if the Plan is approved
PROCEDURE IS_PLAN_APPROVED(p_itemtype  IN         VARCHAR2,
               p_itemkey   IN         VARCHAR2,
               p_actid     IN         NUMBER,
               p_funcmode  IN         VARCHAR2,
               x_resultout OUT NOCOPY VARCHAR2)
IS

l_is_approved VARCHAR2(1) := 'N';

BEGIN

   l_is_approved := wf_engine.GetItemAttrText(itemtype => p_itemtype,
                                              itemkey  => p_itemkey,
                                              aname    => 'FPA_APPROVE_PC');

   IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
         fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
                        'fpa.sql.fpa_main_process_pvt.is_plan_approved.begin',
                        'value of  l_is_approved'|| l_is_approved||'p_itemkey '||p_itemkey||'p_funcmode '||p_funcmode);
   END IF;

   IF (l_is_approved = 'Y') THEN
      x_resultout := 'Y';
   ELSE
      x_resultout := 'N';
   END IF;

EXCEPTION
   WHEN OTHERS THEN
      IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
         fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
                        'fpa.sql.fpa_main_process_pvt.is_plan_approved.end',
                        SQLERRM);
      END IF;
      wf_core.context('FPA_MAIN_PROCESS_PVT', 'IS_PLAN_APPROVED', SQLERRM);
      RAISE;
END IS_PLAN_APPROVED;



-- Sets the Planning Cycle Status to ANALYSIS
PROCEDURE SET_STATUS_ANALYSIS(p_itemtype  IN         VARCHAR2,
                  p_itemkey   IN         VARCHAR2,
                  p_actid     IN         NUMBER,
                  p_funcmode  IN         VARCHAR2,
                  x_resultout OUT NOCOPY VARCHAR2)
IS

l_return_status VARCHAR2(1)                     := null;
l_msg_count     NUMBER                          := null;
l_msg_data      VARCHAR2(2000)                  := null;
l_pc_id         NUMBER                          := null;
l_pc_status     fpa_aw_pc_info_v.pc_status%TYPE := null;

BEGIN

   -- Get the Planning Cycle ID
   l_pc_id := wf_engine.GetItemAttrNumber(itemtype => p_itemtype,
                                          itemkey  => p_itemkey,
                                          aname    => 'FPA_PC_ID');

   l_pc_status := 'ANALYSIS';


   -- Call the Set Status API to set the Planning Cycle
   fpa_planningcycle_pvt.set_pc_status(p_api_version    => 1.0,
                                       p_pc_id          => l_pc_id,
                                       p_pc_status_code => l_pc_status,
                                       x_return_status  => l_return_status,
                                       x_msg_count      => l_msg_count,
                                       x_msg_data       => l_msg_data);

   x_resultout := wf_engine.eng_null;

EXCEPTION
   WHEN OTHERS THEN
      IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
         fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
                        'fpa.sql.fpa_main_process_pvt.set_status_analysis.end',
                        SQLERRM);
      END IF;
      wf_core.context('FPA_MAIN_PROCESS_PVT', 'SET_STATUS_ANALYSIS', SQLERRM);

      RAISE;
END SET_STATUS_ANALYSIS;

-- Sets the Planning Cycle Status to APPROVED
PROCEDURE SET_STATUS_APPROVED(p_itemtype  IN         VARCHAR2,
                  p_itemkey   IN         VARCHAR2,
                  p_actid     IN         NUMBER,
                  p_funcmode  IN         VARCHAR2,
                  x_resultout OUT NOCOPY VARCHAR2)
IS

l_return_status VARCHAR2(1)                      := null;
l_msg_count     NUMBER                           := null;
l_msg_data      VARCHAR2(2000)                   := null;
l_pc_id         NUMBER                           := null;
l_pc_status     fpa_aw_pc_info_v.pc_status%TYPE  := null;
l_pc_approve    VARCHAR2(1)                      := null;

BEGIN

   IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
                     'fpa.sql.fpa_main_process_pvt.set_status_approved.begin',
                     'Entering fpa_main_process_pvt.set_status_approved p_itemkey'||p_itemkey);
   END IF;

   -- Get the Planning Cycle ID
   l_pc_id := wf_engine.GetItemAttrNumber(itemtype => p_itemtype,
                                          itemkey  => p_itemkey,
                                          aname    => 'FPA_PC_ID');

   l_pc_approve :=  wf_engine.GetItemAttrText(itemtype  => p_itemtype,
                                 itemkey   => p_itemkey,
                             aname     => 'FPA_APPROVE_PC');

   IF l_pc_approve = 'Y' THEN
      l_pc_status := 'APPROVED';
   ELSE
      l_pc_status := 'ANALYSIS';
   END IF;


   IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
                     'fpa.sql.fpa_main_process_pvt.set_status_approved',
                     'Value of l_pc_id ='||l_pc_id||' Value of l_pc_status='||l_pc_status||' Value of l_pc_approve ='||l_pc_approve);
   END IF;


   -- Call the Set Status API to set the Planning Cycle
   fpa_planningcycle_pvt.set_pc_status(p_api_version    => 1.0,
                                       p_pc_id          => l_pc_id,
                                       p_pc_status_code => l_pc_status,
                                       x_return_status  => l_return_status,
                                       x_msg_count      => l_msg_count,
                                       x_msg_data       => l_msg_data);

   x_resultout := wf_engine.eng_null;

   IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
                     'fpa.sql.fpa_main_process_pvt.set_status_approved.end',
                     'Exiting fpa_main_process_pvt.set_status_approved');
   END IF;

EXCEPTION
   WHEN OTHERS THEN
      IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
         fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
                        'fpa.sql.fpa_main_process_pvt.set_status_approved.end',
                        SQLERRM);
      END IF;
      wf_core.context('FPA_MAIN_PROCESS_PVT', 'SET_STATUS_APPROVED', SQLERRM);

      RAISE;
END SET_STATUS_APPROVED;

-- Sets the Planning Cycle Status to CLOSED
PROCEDURE SET_STATUS_CLOSED(p_itemtype  IN         VARCHAR2,
                p_itemkey   IN         VARCHAR2,
                p_actid     IN         NUMBER,
                p_funcmode  IN         VARCHAR2,
                x_resultout OUT NOCOPY VARCHAR2)
IS

l_return_status VARCHAR2(1)                     := null;
l_msg_count     NUMBER                          := null;
l_msg_data      VARCHAR2(2000)                  := null;
l_pc_id         NUMBER                          := null;
l_pc_status     fpa_aw_pc_info_v.pc_status%TYPE := null;

BEGIN

   IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        FND_LOG.String
        ( FND_LOG.LEVEL_PROCEDURE,
          'fpa.sql.FPA_main_process_pvt.set_status_closed.begin',
          'Calling FPA_PlanningCycle_Pvt.set_pc_status'
        );
    END IF;

   -- Get the Planning Cycle ID
   l_pc_id := wf_engine.GetItemAttrNumber(itemtype => p_itemtype,
                                          itemkey  => p_itemkey,
                                          aname    => 'FPA_PC_ID');

   l_pc_status := 'CLOSED';

   -- Call the Set Status API to set the Planning Cycle
   fpa_planningcycle_pvt.set_pc_status(p_api_version    => 1.0,
                                       p_pc_id          => l_pc_id,
                                       p_pc_status_code => l_pc_status,
                                       x_return_status  => l_return_status,
                                       x_msg_count      => l_msg_count,
                                       x_msg_data       => l_msg_data);

  IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        FND_LOG.String
        ( FND_LOG.LEVEL_PROCEDURE,
          'FPA_main_process_pvt.set_status_closed',
          'Calling FPA_PlanningCycle_Pvt.Set_Pc_Approved_Flag.'
        );
    END IF;

  FPA_PlanningCycle_Pvt.Set_Pc_Last_Flag
  (
   p_api_version => 1.0,
   p_pc_id => l_pc_id,
   x_return_status  =>  l_return_status,
   x_msg_data  =>  l_msg_data,
   x_msg_count =>  l_msg_count
  );

   x_resultout := wf_engine.eng_null;

   IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        FND_LOG.String
        ( FND_LOG.LEVEL_PROCEDURE,
          'fpa.sql.FPA_main_process_pvt.set_status_closed.end',
          'FPA_main_process_pvt.set_status_closed.end'
        );
    END IF;

EXCEPTION
   WHEN OTHERS THEN
      IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
         fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
                        'fpa.sql.fpa_main_process_pvt.set_status_closed.end',
                        SQLERRM);
      END IF;
      wf_core.context('FPA_MAIN_PROCESS_PVT', 'SET_STATUS_CLOSED', SQLERRM);

      RAISE;
END SET_STATUS_CLOSED;



-- Sets the Planning Cycle Status to COLLECTING
PROCEDURE SET_STATUS_COLLECTING(p_itemtype  IN         VARCHAR2,
                p_itemkey   IN         VARCHAR2,
                p_actid     IN         NUMBER,
                p_funcmode  IN         VARCHAR2,
                x_resultout OUT NOCOPY VARCHAR2)
IS

l_return_status VARCHAR2(1)                     := null;
l_msg_count     NUMBER                          := null;
l_msg_data      VARCHAR2(2000)                  := null;
l_pc_id         NUMBER                          := null;
l_pc_status     fpa_aw_pc_info_v.pc_status%TYPE := null;

BEGIN

   -- Get the Planning Cycle ID
   l_pc_id := wf_engine.GetItemAttrNumber(itemtype => p_itemtype,
                                          itemkey  => p_itemkey,
                                          aname    => 'FPA_PC_ID');

   l_pc_status := 'COLLECTING';

   -- Call the Set Status API to set the Planning Cycle
   fpa_planningcycle_pvt.set_pc_status(p_api_version    => 1.0,
                                       p_pc_id          => l_pc_id,
                                       p_pc_status_code => l_pc_status,
                                       x_return_status  => l_return_status,
                                       x_msg_count      => l_msg_count,
                                       x_msg_data       => l_msg_data);

   x_resultout := wf_engine.eng_null;

EXCEPTION
   WHEN OTHERS THEN
      IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
         fnd_log.string(
            FND_LOG.LEVEL_PROCEDURE,
            'fpa.sql.fpa_main_process_pvt.set_status_collecting.end',
            SQLERRM);
      END IF;
      wf_core.context('FPA_MAIN_PROCESS_PVT',
                      'SET_STATUS_COLLECTING',
                      SQLERRM);

      RAISE;
END SET_STATUS_COLLECTING;



-- Sets the Planning Cycle Status to SUBMITTED
PROCEDURE SET_STATUS_SUBMITTED(p_itemtype  IN         VARCHAR2,
                   p_itemkey   IN         VARCHAR2,
                   p_actid     IN         NUMBER,
                   p_funcmode  IN         VARCHAR2,
                   x_resultout OUT NOCOPY VARCHAR2)
IS

l_return_status VARCHAR2(1)                     := null;
l_msg_count     NUMBER                          := null;
l_msg_data      VARCHAR2(2000)                  := null;
l_pc_id         NUMBER                          := null;
l_pc_status     fpa_aw_pc_info_v.pc_status%TYPE := null;

BEGIN

   -- Get the Planning Cycle ID
   l_pc_id := wf_engine.GetItemAttrNumber(itemtype => p_itemtype,
                                          itemkey  => p_itemkey,
                                          aname    => 'FPA_PC_ID');

   l_pc_status := 'SUBMITTED';


   -- Call the Set Status API to set the Planning Cycle
   fpa_planningcycle_pvt.set_pc_status(p_api_version    => 1.0,
                                       p_pc_id          => l_pc_id,
                                       p_pc_status_code => l_pc_status,
                                       x_return_status  => l_return_status,
                                       x_msg_count      => l_msg_count,
                                       x_msg_data       => l_msg_data);

   x_resultout := wf_engine.eng_null;

EXCEPTION
   WHEN OTHERS THEN
      IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
         fnd_log.string(
            FND_LOG.LEVEL_PROCEDURE,
            'fpa.sql.fpa_main_process_pvt.set_status_submitted.end',
            SQLERRM);
      END IF;
      wf_core.context('FPA_MAIN_PROCESS_PVT', 'SET_STATUS_SUBMITTED', SQLERRM);

      /*
      -- Detach AW Workspace
      fpa_utilities_pvt.detach_AW(p_api_version   => 1.0,
                                  x_return_status => l_return_status,
                                  x_msg_count     => l_msg_count,
                                  x_msg_data      => l_msg_data);
      */
      RAISE;
END SET_STATUS_SUBMITTED;


/* Workflow business events */
/* User force action */
-- pings the User Action business event
PROCEDURE FORCE_USER_ACTION(p_itemkey       IN         VARCHAR2,
                p_event_name    IN         VARCHAR2,
                x_return_status OUT NOCOPY VARCHAR2,
                x_msg_count     OUT NOCOPY NUMBER,
                x_msg_data      OUT NOCOPY VARCHAR2)
IS
BEGIN

   IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
                     'fpa.sql.fpa_main_process_pvt.force_user_action.begin',
                     'Entering fpa_main_process_pvt.force_user_action');
   END IF;

   -- Raise the user forced event
   wf_event.raise(p_event_name, p_itemkey, null, null);

   IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
                     'fpa.sql.fpa_main_process_pvt.force_user_action.end',
                     'Exiting fpa_main_process_pvt.force_user_action');
   END IF;

EXCEPTION
   WHEN OTHERS THEN
      IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
         fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
                        'fpa.sql.fpa_main_process_pvt.force_user_action.end',
                        SQLERRM);
      END IF;
      wf_core.context('FPA_MAIN_PROCESS_PVT', 'FORCE_USER_ACTION', SQLERRM);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.count_and_get(p_count => x_msg_count,
                                p_data  => x_msg_data
                   );
      RAISE;
END FORCE_USER_ACTION;



/* Workflow business events */
/* Submit plan */
-- pings the Submit Plan business event
PROCEDURE SUBMIT_PLAN(p_itemkey       IN         VARCHAR2,
              p_event_name    IN         VARCHAR2,
              x_return_status OUT NOCOPY VARCHAR2,
              x_msg_count     OUT NOCOPY NUMBER,
              x_msg_data      OUT NOCOPY VARCHAR2)
IS
l_eventkey       VARCHAR2(30)   := null;

l_return_status  VARCHAR2(1) ;
l_msg_count      NUMBER      ;
l_msg_data       VARCHAR2(2000);

BEGIN

   IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
                     'fpa.sql.fpa_main_process_pvt.submit_plan.begin',
                     'Entering fpa_main_process_pvt.submit_plan value of p_itemkey'||p_itemkey);
   END IF;

   l_eventkey  := 'FPAL' ||p_itemkey;

   -- Attach AW Workspace
   fpa_utilities_pvt.attach_AW(p_api_version   => 1.0,
                               p_attach_mode   => 'rw',
                               x_return_status => l_return_status,
                               x_msg_count     => l_msg_count,
                               x_msg_data      => l_msg_data);


   -- Raise the submit plan event
   wf_event.raise(p_event_name => 'oracle.apps.fpa.event.submit.submitplan',
                  p_event_key  => l_eventkey  );

   dbms_aw.execute('UPDATE');
   COMMIT;

   -- Detach AW Workspace
   fpa_utilities_pvt.detach_AW(p_api_version   => 1.0,
                               x_return_status => l_return_status,
                               x_msg_count     => l_msg_count,
                               x_msg_data      => l_msg_data);

--   COMMIT;

   IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
                     'fpa.sql.fpa_main_process_pvt.submit_plan.end',
                     'Exiting fpa_main_process_pvt.submit_plan');
   END IF;

EXCEPTION
   WHEN OTHERS THEN
      IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
         fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
                        'fpa.sql.fpa_main_process_pvt.submit_plan.end',
                        SQLERRM);
      END IF;
      wf_core.context('FPA_MAIN_PROCESS_PVT', 'SUBMIT_PLAN', SQLERRM);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.count_and_get(p_count => x_msg_count,
                                p_data  => x_msg_data
                   );
      RAISE;
END SUBMIT_PLAN;


/* Workflow business events */
/* Approve or Reject a plan */
-- pings the Approve Reject Plan business event
PROCEDURE APPROVE_REJECT_PLAN(p_itemkey       IN         VARCHAR2,
                      p_event_name    IN         VARCHAR2,
                  x_return_status OUT NOCOPY VARCHAR2,
                  x_msg_count     OUT NOCOPY NUMBER,
                  x_msg_data      OUT NOCOPY VARCHAR2)
IS
l_eventkey       VARCHAR2(30);
l_return_status  VARCHAR2(1) ;
l_msg_count      NUMBER      ;
l_msg_data       VARCHAR2(2000);
l_sce_id     number;

BEGIN

   IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
                     'fpa.sql.fpa_main_process_pvt.approve_reject_plan.begin',
                     'Entering fpa_main_process_pvt.approve_reject_plan ACTION : '||p_event_name);
   END IF;

   l_eventkey  := 'FPAL' ||p_itemkey;

   IF p_event_name = 'FPA_APPROVE_PLAN' THEN
      wf_engine.SetItemAttrText(itemtype  => 'FPAPJP',
                    itemkey   => l_eventkey ,
                aname     => 'FPA_APPROVE_PC',
                avalue    => 'Y');
   ELSIF  p_event_name = 'FPA_REJECT_PLAN' or p_event_name = 'FPA_WITHDRAW_PLAN' THEN
      wf_engine.SetItemAttrText(itemtype  => 'FPAPJP',
                    itemkey   => l_eventkey ,
                aname     => 'FPA_APPROVE_PC',
                avalue    => 'N');
   END IF;

   IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
                     'fpa.sql.fpa_main_process_pvt.approve_reject_plan.',
                     'Calling fpa_utilities_pvt.attach_AW');
   END IF;

   -- Attach AW Workspace
   fpa_utilities_pvt.attach_AW(p_api_version   => 1.0,
                               p_attach_mode   => 'rw',
                               x_return_status => l_return_status,
                               x_msg_count     => l_msg_count,
                               x_msg_data      => l_msg_data);


    IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
       FND_LOG.String
       ( FND_LOG.LEVEL_PROCEDURE,
         'FPA_Main_Process_Pvt.approve_reject_plan.',
         'Obtaining Approved Scenario Id for current Planning Cycle.'
       );
    END IF;

   -- For the passed planning cycle get the scenario approved
    select scenario
     into l_sce_id
     from fpa_aw_sce_info_v
    where approved_flag = 1
      and planning_cycle = p_itemkey;

    IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
       FND_LOG.String
       ( FND_LOG.LEVEL_PROCEDURE,
         'FPA_Main_Process_Pvt.approve_reject_plan.',
         'Approved Scenario Id '||l_sce_id
       );
    END IF;


   IF p_event_name = 'FPA_APPROVE_PLAN' THEN
    -- Call API to update approved Scores
    if l_sce_id is not null then

    IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
       FND_LOG.String
       ( FND_LOG.LEVEL_PROCEDURE,
         'FPA_Main_Process_Pvt.approve_reject_plan.',
         'Calling FPA_SCORECARDS_PVT.Update_Scenario_App_Scores.'
       );
    END IF;

     FPA_SCORECARDS_PVT.Update_Scenario_App_Scores
       (p_api_version  => 1.0,
        p_init_msg_list => FND_API.G_FALSE,
        p_scenario_id => l_sce_id,
        x_return_status => l_return_status,
        x_msg_count => l_msg_count,
        x_msg_data => l_msg_data
        );

    IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
       FND_LOG.String
       ( FND_LOG.LEVEL_PROCEDURE,
         'FPA_Main_Process_Pvt.approve_reject_plan.',
         'Calling FPA_Project_PVT.UPDATE_PROJ_FUNDING_STATUS.'
       );
    END IF;

    FPA_Project_PVT.UPDATE_PROJ_FUNDING_STATUS
    (
      p_api_version => 1.0,
      p_init_msg_list => FND_API.G_FALSE,
      p_commit => FND_API.G_FALSE,
      p_appr_scenario_id => l_sce_id,
      x_return_status => l_return_status,
      x_msg_count => l_msg_count,
      x_msg_data => l_msg_data);

    IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
       FND_LOG.String
       ( FND_LOG.LEVEL_PROCEDURE,
         'FPA_Main_Process_Pvt.approve_reject_plan.',
         'Calling FPA_Portfolio_Project_sets_Pvt.add_project_set_lines'
       );
    END IF;

    FPA_PORTFOLIO_PROJECT_SETS_PVT.ADD_PROJECT_SET_LINES
     (p_api_version   => 1.0,
      p_scen_id       => l_sce_id,
      x_return_status => l_return_status,
      x_msg_count     => l_msg_count,
      x_msg_data      => l_msg_data);

   end if;
   elsif p_event_name = 'FPA_REJECT_PLAN' or p_event_name = 'FPA_WITHDRAW_PLAN' THEN
-- Bug 4324881
-- Reject Plan should reset the recommended and approved flags for all scenarios in the plan
-- A/w is already attached in R/w mode
-- As a quick fix, we are executing OLAP dml commands to reset the flags.
-- fpa_scenario_pvt will be updated with new procedures
-- that may be required to reset the recomm/appr flags for all scenarios

    IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
       FND_LOG.String
       ( FND_LOG.LEVEL_PROCEDURE,
         'FPA_Main_Process_Pvt.approve_reject_plan.',
         'Reject Plan: Approved Scenario Id '||l_sce_id
       );
    END IF;
--    dbms_aw.execute('ALLSTAT');
    dbms_aw.execute('LMT scenario_d to '|| l_sce_id );
-- get the PC
    dbms_aw.execute('LMT planning_cycle_d TO scenario_d' );
-- get all scenarios that belong to the PC
    dbms_aw.execute('LMT scenario_d to planning_cycle_d' );
-- reset flags to na for all scenarios
    dbms_aw.execute('scenario_approved_flag_m = na');
    dbms_aw.execute('scenario_recommended_flag_m = na');

   end if;


--   dbms_aw.execute('ALLSTAT');

   IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FND_LOG.String
      ( FND_LOG.LEVEL_PROCEDURE,
        'FPA_Main_Process_Pvt.approve_reject_plan.',
        'Approve/ Reject Plan procedure calls ');
   END IF;

   IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
                     'fpa.sql.fpa_main_process_pvt.approve_reject_plan.',
                     'Calling wf_event.raise');
   END IF;

   -- Raise the submit plan event
   wf_event.raise(p_event_name => 'oracle.apps.fpa.event.approve.approvepushdown',
                  p_event_key  => l_eventkey  );

   -- Update AW
   dbms_aw.execute('UPDATE');
   COMMIT;


   IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
                     'fpa.sql.fpa_main_process_pvt.approve_reject_plan.',
                     'Calling fpa_utilities_pvt.detach_AW');
   END IF;

   -- Detach AW Workspace
   fpa_utilities_pvt.detach_AW(p_api_version   => 1.0,
                               x_return_status => l_return_status,
                               x_msg_count     => l_msg_count,
                               x_msg_data      => l_msg_data);



   IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
                     'fpa.sql.fpa_main_process_pvt.approve_reject_plan.end',
                     'Exiting fpa_main_process_pvt.approve_reject_plan');
   END IF;

EXCEPTION
   WHEN OTHERS THEN
      IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
         fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
                        'fpa.sql.fpa_main_process_pvt.approve_reject_plan.end',
                        SQLERRM);
      END IF;
-- Bug 4331948 If Exception raised during Approve/Reject Plan, A/w should be detached
     -- Detach AW Workspace
       Fpa_Utilities_Pvt.detach_AW
                        (
                          p_api_version => 1.0,
                          x_return_status => x_return_status,
                          x_msg_count => x_msg_count,
                          x_msg_data => x_msg_data
                        );

      wf_core.context('FPA_MAIN_PROCESS_PVT', 'APPROVE_REJECT_PLAN', SQLERRM);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.count_and_get(p_count => x_msg_count,
                                p_data  => x_msg_data
                   );
      RAISE;
END APPROVE_REJECT_PLAN;

--Procedure to copy Projects from last planning cycle of current portfolio

PROCEDURE COPY_PROJ_FROM_PREV_PC(p_itemtype  IN         VARCHAR2,
                     p_itemkey   IN         VARCHAR2,
                     p_actid     IN         NUMBER,
                     p_funcmode  IN         VARCHAR2,
                     x_resultout OUT NOCOPY VARCHAR2)
IS

l_return_status  VARCHAR2(1);
l_msg_count      NUMBER ;
l_msg_data       VARCHAR2(2000);
l_last_pc_id     NUMBER;
l_count          NUMBER;
l_project_id_tbl SYSTEM.pa_num_tbl_type;

BEGIN

   IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
                     'fpa.sql.fpa_main_process_pvt.copy_proj_from_prev_pc.begin',
                     'Entering fpa_main_process_pvt.copy_proj_from_prev_pc ');
   END IF;

   -- Get the Planning Cycle ID
   l_last_pc_id := NULL;
   l_last_pc_id := wf_engine.GetItemAttrNumber(itemtype => p_itemtype,
                                               itemkey  => p_itemkey,
                                               aname    => 'FPA_LAST_PC_ID');

   IF NVL(l_last_pc_id,-1) <> -1 THEN  --Bug 4237493 : Introduced for scenario where there is no last PC

       IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
          fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
                 'fpa.sql.fpa_main_process_pvt.copy_proj_from_prev_pc.begin',
                 'Setting Last Planning cycle ID to the planning_cycle_d');
       END IF;

       dbms_aw.execute('PUSH planning_cycle_d');
       dbms_aw.execute('LMT planning_cycle_d TO ' || l_last_pc_id );

       SELECT proj.project BULK COLLECT
         INTO l_project_id_tbl
         From fpa_aw_projs_v proj
        WHERE proj.planning_cycle = l_last_pc_id;

       dbms_aw.execute('POP planning_cycle_d');

       l_count :=0;
       l_count := l_project_id_tbl.COUNT;

       IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
          fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
                 'fpa.sql.fpa_main_process_pvt.copy_proj_from_prev_pc.begin',
                 'NUmber of projects fetched from last PC '||l_count);
       END IF;

       FOR i in 1 .. l_count
        LOOP

          IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
            fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
                       'fpa.sql.fpa_main_process_pvt.copy_proj_from_prev_pc.begin',
                       'Looping for l_project_id_tbl(i) =  '||l_project_id_tbl(i));
          END IF;

           FPA_PROJECT_PVT.Submit_Project_Aw(
                  p_api_version        => 1.0,
                  p_init_msg_list      => FND_API.G_FALSE,
                  p_commit             => FND_API.G_FALSE,
                  p_project_id         => l_project_id_tbl(i),
                  x_return_status      => l_return_status,
                  x_msg_count          => l_msg_count,
                  x_msg_data           => l_msg_data);
        END LOOP;

    END IF;  --Bug 4237493

    x_resultout := wf_engine.eng_null;

    IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
                     'fpa.sql.fpa_main_process_pvt.copy_proj_from_prev_pc.end',
                     'Exiting fpa_main_process_pvt.copy_proj_from_prev_pc');
    END IF;


EXCEPTION
   WHEN OTHERS THEN
      IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
         fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
                        'fpa.sql.fpa_main_process_pvt.copy_proj_from_prev_pc.end',
                        SQLERRM);
      END IF;
      wf_core.context('FPA_MAIN_PROCESS_PVT', 'COPY_PROJ_FROM_PREV_PC', SQLERRM);
      RAISE;
END COPY_PROJ_FROM_PREV_PC;

--Procedure to attach AW for workflow

PROCEDURE WF_ATTACH_AW          (p_itemtype  IN         VARCHAR2,
                     p_itemkey   IN         VARCHAR2,
                     p_actid     IN         NUMBER,
                     p_funcmode  IN         VARCHAR2,
                     x_resultout OUT NOCOPY VARCHAR2) IS

l_return_status  VARCHAR2(1);
l_msg_count      NUMBER;
l_msg_data       VARCHAR2(2000);
l_wf_aw_attached VARCHAR2(1);

BEGIN

   IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
                     'fpa.sql.fpa_main_process_pvt.wf_attach_aw.begin',
                     'Entering fpa_main_process_pvt.wf_attach_aw ');
   END IF;

  Fpa_Utilities_Pvt.attach_AW
                        (
                          p_api_version => 1.0,
                          p_attach_mode => 'rw',
                          x_return_status => l_return_status,
                          x_msg_count => l_msg_count,
                          x_msg_data => l_msg_data
                        );

   l_wf_aw_attached := 'Y' ;

   -- Sets the Planning Cycle ID
   wf_engine.SetItemAttrtext(itemtype => p_itemtype,
                               itemkey  => p_itemkey,
                               aname    => 'FPA_WF_AW_ATTACHED',
                               avalue   => l_wf_aw_attached);

   x_resultout := wf_engine.eng_null;

   IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
                     'fpa.sql.fpa_main_process_pvt.wf_attach_aw.end',
                     'Entering fpa_main_process_pvt.wf_attach_aw');
   END IF;

EXCEPTION
 WHEN OTHERS THEN
      IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
         fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
                        'fpa.sql.fpa_main_process_pvt.wf_attach_aw.end',
                        SQLERRM);
      END IF;
      wf_core.context('FPA_MAIN_PROCESS_PVT', ' WF_ATTACH_AW', SQLERRM);
      RAISE;

END;

--Procedure to detach AW for workflow

PROCEDURE WF_DETACH_AW          (p_itemtype  IN         VARCHAR2,
                     p_itemkey   IN         VARCHAR2,
                     p_actid     IN         NUMBER,
                     p_funcmode  IN         VARCHAR2,
                     x_resultout OUT NOCOPY VARCHAR2) IS

l_return_status VARCHAR2(1);
l_msg_count     NUMBER;
l_msg_data      VARCHAR2(2000);
l_wf_aw_attached VARCHAR2(1);
BEGIN

   IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
                     'fpa.sql.fpa_main_process_pvt.wf_detach_aw.begin',
                     'Entering fpa_main_process_pvt.wf_detach_aw ');
   END IF;

-- Sets the Planning Cycle ID
   l_wf_aw_attached := 'N';
   l_wf_aw_attached := wf_engine.getItemAttrtext(itemtype => p_itemtype,
                                                  itemkey  => p_itemkey,
                                                  aname    => 'FPA_WF_AW_ATTACHED');

   IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
                     'fpa.sql.fpa_main_process_pvt.wf_detach_aw.begin',
                     'Value of l_wf_aw_attached '||l_wf_aw_attached);
   END IF;

   IF NVL(l_wf_aw_attached,'N') = 'Y' THEN

     -- Update AW
     dbms_aw.execute('UPDATE');
     COMMIT;

     Fpa_Utilities_Pvt.detach_AW
                        (
                          p_api_version => 1.0,
                          x_return_status => l_return_status,
                          x_msg_count =>l_msg_count,
                          x_msg_data => l_msg_data
                        );
   END IF;

   x_resultout := wf_engine.eng_null;

   IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
                     'fpa.sql.fpa_main_process_pvt.wf_detach_aw.end',
                     'Entering fpa_main_process_pvt.wf_detach_aw');
   END IF;

EXCEPTION
 WHEN OTHERS THEN
      IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
         fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
                        'fpa.sql.fpa_main_process_pvt.wf_detach_aw.end',
                        SQLERRM);
      END IF;
      wf_core.context('FPA_MAIN_PROCESS_PVT', ' WF_DETACH_AW', SQLERRM);
      RAISE;

END;

END FPA_MAIN_PROCESS_PVT;

/
