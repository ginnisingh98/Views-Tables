--------------------------------------------------------
--  DDL for Package Body PA_BUDGET_INTG_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_BUDGET_INTG_WF" AS
/* $Header: PAWFBUIB.pls 120.4 2007/02/06 10:12:21 dthakker ship $ */

-- FORWARD DECLARATIONS ------------------------------------------------

PROCEDURE Set_Nf_Error_Msg_Attr (p_item_type IN VARCHAR2,
			         p_item_key  IN VARCHAR2,
				 p_msg_count IN NUMBER,
				 p_msg_data  IN VARCHAR2
                                 ) ;

PROCEDURE Set_WF_Status_Code (p_draft_version_id IN   NUMBER
                             , p_wf_result_code  IN   VARCHAR2
                             , x_msg_count       OUT  NOCOPY NUMBER  --File.Sql.39 bug 4440895
                             , x_msg_data        OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                             , x_return_status   OUT  NOCOPY VARCHAR2                               --File.Sql.39 bug 4440895
                             );


-- ---------------------------------------------------------------------
-- ---------------------------------------------------------------------

--
--
--Name:        	Start_Budget_Intg_WF
--Type:         Procedure
--Description:  This procedure must return a "T" or "F" depending
--              on whether the workflow runs successfully (no Oracle system
--              errors) or fails with Oracle errors.
--
--
--
--Called Subprograms:	pa_budget_wf.start_budget_wf (Budget Approval workflow)
--                      pa_budget_utils.baseline_budget (wrapper Baseline procedure)
--
--
--Notes:
--     This procedure is called from the Budgets form for Submission and
--     Baseline Integration processing. Depending on various parameters, this
--     procedure either calls the Budget Approval workflow or the new
--     wrapper Baseline_Budget API.
--
--
--
--History:
--	07-MAY-01	jwhite		-Created
--
--
--      14-JUL-05       jwhite          -R12 MOAC Effort
--                                       Added call to the new Set_Prj_Policy_Context to enforce
--                                       a single project/OU context.
--

PROCEDURE Start_Budget_Intg_WF
          (p_draft_version_id         IN   NUMBER
          , p_project_id              IN   NUMBER
          , p_budget_type_code        IN   VARCHAR2
          , p_mark_as_original        IN   VARCHAR2
          , p_budget_wf_flag          IN   VARCHAR2
          , p_bgt_intg_flag           IN   VARCHAR2
          , p_fck_req_flag            IN   VARCHAR2
          , x_msg_count               OUT  NOCOPY NUMBER  --File.Sql.39 bug 4440895
          , x_msg_data                OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
          , x_return_status           OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
          )
 IS


-- Project Information
CURSOR l_projects_csr(p_project_id NUMBER)
IS
SELECT p.project_id project_id,
       p.name project_name,
       p.segment1 project_number,
       o.name project_organization
FROM pa_projects_all p,
     hr_all_organization_units o
WHERE p.project_id = p_project_id
AND   p.carrying_out_organization_id = o.organization_id;

-- Budget Information
CURSOR l_budget_type_csr( p_budget_type_code VARCHAR2 )
IS
SELECT	budget_type
FROM	pa_budget_types
WHERE	  budget_type_code = p_budget_type_code;


l_return_status           VARCHAR2(1);
l_error_message_code      VARCHAR2(30);
l_msg_count	          NUMBER ;
l_msg_index_out	          NUMBER ;
l_msg_data	          VARCHAR2(2000);
l_data                    VARCHAR2(2000);
l_err_code  		  NUMBER := 0;
l_err_stage 		  VARCHAR2(2000);
l_err_stack 		  VARCHAR2(2000);

l_itemkey                 VARCHAR2(30) := NULL;
l_responsibility_id       NUMBER;
l_resp_appl_id            NUMBER;
l_wf_started_date         DATE;
l_wf_started_by_id        NUMBER;
l_wf_started_by_username  VARCHAR2(100):= NULL;  /* Modified length from 30 to 100 for bug 2933743 */
l_wf_item_type		  VARCHAR2(30) := 'PAWFBUI';
l_save_threshold          NUMBER := NULL;

l_project_manager_person_id  NUMBER := NULL;
l_project_manager_name       VARCHAR2(200) := NULL;
l_project_manager_uname      VARCHAR2(200) := NULL;
l_project_party_id           NUMBER := NULL;
l_project_role_id            NUMBER := NULL;
l_project_role_name          VARCHAR2(80):= NULL;
l_budget_type                pa_budget_types.budget_type%TYPE;
l_mark_as_original           pa_budget_versions.original_flag%TYPE;


l_projects_rec l_projects_csr%ROWTYPE;


BEGIN

        -- Initialize Workflow, Messaging and Apps Globals ---------------------------

--pa_fck_util.debug_msg('PAWFBUIB: BEGIN PA_BUDGET_INTG_WF.Start_Budget_Intg_WF');

	x_return_status := FND_API.G_RET_STS_SUCCESS;

	fnd_msg_pub.initialize;

	x_msg_count := 0;

        -- Reserve Unique Item Key to Launch WF
        SELECT pa_workflow_itemkey_s.nextval
        INTO l_itemkey
        FROM dual;


--pa_fck_util.debug_msg('PAWFBUIB: l_itemkey: '||l_itemkey);

        -- Setup Apps Environement
        l_wf_started_by_id       := FND_GLOBAL.user_id;
        l_responsibility_id      := FND_GLOBAL.resp_id;
        l_resp_appl_id           := FND_GLOBAL.resp_appl_id;
        l_wf_started_by_username := FND_GLOBAL.USER_NAME;

        FND_GLOBAL.Apps_Initialize ( user_id       => l_wf_started_by_id
                                    , resp_id      => l_responsibility_id
                                    , resp_appl_id => l_resp_appl_id
                                    );

        -- R12 MOAC, 14-JUL-05, jwhite -------------------
        -- Set Single Project/OU context

        PA_BUDGET_UTILS.Set_Prj_Policy_Context
          (p_project_id => p_project_id
           ,x_return_status => l_return_status
           ,x_msg_count     => l_msg_count
           ,x_msg_data      => l_msg_data
           ,x_err_code      => l_err_code
           );

        IF (l_err_code <> 0)
          THEN
            x_msg_count     := l_msg_count;
            x_msg_data      := l_msg_data;
            x_return_status := l_return_status;
           RETURN;
        END IF;

       -- -----------------------------------------------





       -- Find Required Information    ---------------------------------------
       -- Validation is unnecessary as calling module will have already done the validation.

        -- Mark-As-Original Flag Set From IN-Parameter
        l_mark_as_original := p_mark_as_original;

        -- Get Project Info
        OPEN l_projects_csr(p_project_id);
	FETCH l_projects_csr INTO l_projects_rec;
	CLOSE l_projects_csr;

        -- Get Budget Type
        OPEN l_budget_type_csr( p_budget_type_code );
        FETCH l_budget_type_csr INTO l_budget_type;
        CLOSE l_budget_type_csr;


        -- Get the project manager details
        -- It is OK, if a project manager is not found.
        pa_project_parties_utils.get_curr_proj_mgr_details
	 	(p_project_id => l_projects_rec.project_id
		,x_manager_person_id => l_project_manager_person_id
		,x_manager_name      => l_project_manager_name
 		,x_project_party_id  => l_project_party_id
                ,x_project_role_id   => l_project_role_id
                ,x_project_role_name => l_project_role_name
                ,x_return_status     => l_return_status
                ,x_error_message_code => l_error_message_code );


         -- Set Up Workflow Environment ----------------------------------------------



         -- Set Workflow Thresold for Deferred Processing
         l_save_threshold     := wf_engine.threshold ;
         wf_engine.threshold  := -1 ;


         -- Create Workflow!
         wf_engine.CreateProcess ( ItemType => l_wf_item_type
                                   , ItemKey  =>  l_itemkey
                                   , process  =>  'PA_BUDGET_INTG_MP'
                                 );



	 -- Pass Workflow IN-parameters
          wf_engine.SetItemAttrNumber
                                ( itemtype => l_wf_item_type
                                , itemkey => l_itemkey
                                , aname => 'PROJECT_ID'
                                , avalue => l_projects_rec.project_id
                                );

          wf_engine.SetItemAttrText
                               ( itemtype => l_wf_item_type
                               , itemkey => l_itemkey
                               , aname => 'PROJECT_NUMBER'
                               , avalue => l_projects_rec.project_number
                               );

           wf_engine.SetItemAttrText
                               ( itemtype => l_wf_item_type
                               , itemkey => l_itemkey
                               , aname => 'PROJECT_NAME'
                               , avalue => l_projects_rec.project_name
                               );

           wf_engine.SetItemAttrText
                               ( itemtype => l_wf_item_type
                               , itemkey => l_itemkey
                               , aname => 'PROJECT_ORGANIZATION'
                               , avalue => l_projects_rec.project_organization
                               );

           wf_engine.SetItemAttrText
			       ( itemtype => l_wf_item_type
                               , itemkey => l_itemkey
                               , aname => 'PROJECT_MANAGER_NAME'
                               , avalue => l_project_manager_name
                               );

	   wf_engine.SetItemAttrText
                                (itemtype	=> l_wf_item_type
	      			, itemkey  	=> l_itemkey
  	      			, aname 	=> 'DRAFT_VERSION_ID'
				, avalue	=>  p_draft_version_id
                                );

	   wf_engine.SetItemAttrText
                                (itemtype	=> l_wf_item_type
	      			, itemkey  	=> l_itemkey
  	      			, aname 	=> 'BUDGET_TYPE_CODE'
				, avalue	=>  p_budget_type_code
                                );

           wf_engine.SetItemAttrText
                                (itemtype	=> l_wf_item_type
	      			, itemkey  	=> l_itemkey
  	      			, aname 	=> 'BUDGET_TYPE'
				, avalue	=>  l_budget_type
                                );

            wf_engine.SetItemAttrText
                                (itemtype	=> l_wf_item_type
	      			, itemkey  	=> l_itemkey
  	      			, aname 	=> 'MARK_AS_ORIGINAL'
				, avalue	=>  l_mark_as_original
                                );

            wf_engine.SetItemAttrText (itemtype	=> l_wf_item_type
	      			   , itemkey  	=> l_itemkey
 	      			   , aname 	=> 'BUDGET_WF_FLAG'
				   , avalue	=> p_budget_wf_flag);


            wf_engine.SetItemAttrText (itemtype	=> l_wf_item_type
	      			   , itemkey  	=> l_itemkey
 	      			   , aname 	=> 'FCK_REQ_FLAG'
				   , avalue	=> p_fck_req_flag);

            wf_engine.SetItemAttrText (itemtype	=> l_wf_item_type
	      			   , itemkey  	=> l_itemkey
 	      			   , aname 	=> 'BGT_INTG_FLAG'
				   , avalue	=> p_bgt_intg_flag);

	    wf_engine.SetItemAttrText
                               ( itemtype => l_wf_item_type
                               , itemkey =>  l_itemkey
                               , aname => 'WORKFLOW_STARTED_BY_UNAME'
                               , avalue => l_wf_started_by_username
                               );

            wf_engine.SetItemAttrText
                               (itemtype   =>l_wf_item_type
                               , itemkey  => l_itemkey
                               , aname  => 'PROJECT_RESOURCE_ADMINISTRATOR'
                               , avalue  => 'PASYSADMIN'
                               );

            wf_engine.SetItemAttrNumber
                                ( itemtype => l_wf_item_type
                                , itemkey => l_itemkey
                                , aname => 'WORKFLOW_STARTED_BY_UID'
                                , avalue => l_wf_started_by_id
                                );

            wf_engine.SetItemAttrNumber
                                ( itemtype => l_wf_item_type
                                , itemkey => l_itemkey
                                , aname => 'WORKFLOW_STARTED_BY_RESP_ID'
                                , avalue => l_responsibility_id
                                );

            wf_engine.SetItemAttrNumber
                                ( itemtype => l_wf_item_type
                                , itemkey => l_itemkey
                                , aname => 'WORKFLOW_STARTED_BY_APPL_ID'
                                , avalue => l_resp_appl_id
                                );

--pa_fck_util.debug_msg('PAWFBUIB: Call wf_engine.StartProcess');


           -- Start Workflow!!!
    	   wf_engine.StartProcess ( itemtype => l_wf_item_type
                                  , itemkey => l_itemkey
                                  );

           -- -----------------------------------------------------------------


           -- Post-Processing Stage  ------------------------------------------
--pa_fck_util.debug_msg('PAWFBUIB: Restore Environment');

              wf_engine.threshold := l_save_threshold;
              x_msg_count := fnd_msg_pub.count_msg;

--pa_fck_util.debug_msg('PAWFBUIB: Log WF Process History');
           -- Archive the Workflow Key for Subsequent Reporting Purposes
       		PA_WORKFLOW_UTILS.Insert_WF_Processes
      		(p_wf_type_code        => 'BUDGET_INTEGRATION'
      		,p_item_type           => l_wf_item_type
      		,p_item_key            => l_itemkey
                ,p_entity_key1         => to_char(p_project_id)
      		,p_entity_key2         => to_char(p_draft_version_id)
      		,p_description         => NULL
      		,p_err_code            => l_err_code
      		,p_err_stage           => l_err_stage
      		,p_err_stack           => l_err_stack
      		);

--pa_fck_util.debug_msg('PAWFBUIB: END PA_BUDGET_INTG_WF.Start_Budget_Intg_WF');



EXCEPTION
 WHEN OTHERS THEN
     wf_engine.threshold := l_save_threshold;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Add_Exc_Msg
			(  p_pkg_name		=> 'PA_BUDGET_INTG_WF'
			,  p_procedure_name	=> 'START_BUDGET_INTG_WF'
			,  p_error_text		=> 'ORA-'||LPAD(substr(SQLCODE,2),5,'0')
                        );
     FND_MSG_PUB.Count_And_Get
                       (p_count		=>	x_msg_count
	               , p_data		=>	x_msg_data
                        );


 END  Start_Budget_Intg_WF;


--Name:               Process_Bgt_Intg
--Type:               Procedure
--Description:        The logic for this node is complex. Basically, this
--                    node peforms edits and calls for funds checking Integration budgets.
--
--                    If successful, the Resultout = 'T'. Other notification text varies,
--                    accordingly.
--
--                    Otherwise, the Resultout = 'F' and one or more
--                    error messages, up to five messages, is displayed on the
--                    notification. Other notification text varies,
--                    accordingly.
--
--
--Called subprograms:
--
--History:
--    14-MAY-01		jwhite		Created
--
--    13-JUN-01         jwhite          For the 31-MAY-01 fix, rewrote
--                                      code track when the Budget Approval
--                                      WF is actually fired.
--
--	08-APR-02	jwhite		Bug 2310429
--                                      Made changes to gracefully handle ORA
--                                      error conditions and alert the user via
--                                      notification:
--                                      1) For exception processing,
--                                         moved the WF_CORE code to end
--                                            of code.
--
--      14-JUL-05       jwhite          -R12 MOAC Effort
--                                       Added call to the new Set_Prj_Policy_Context to enforce
--                                       a single project/OU context.
--
--
--
PROCEDURE Process_Bgt_Intg(itemtype   IN  VARCHAR2
                          , itemkey   IN  VARCHAR2
                          , actid     IN  NUMBER
                          , funcmode  IN  VARCHAR2
                          , resultout OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                          )
IS

l_return_status           VARCHAR2(1)    := NULL;
l_msg_count	          NUMBER         := NULL;
l_msg_data	          VARCHAR2(2000) := NULL;
l_msg_index_out           NUMBER         := NULL;

l_err_code                NUMBER         := 0;   -- R12 MOAC: changed to 0 from NULL
l_err_stage               VARCHAR2(120)  := NULL;
l_err_stack               VARCHAR2(630)  := NULL;

l_project_id	          NUMBER         := NULL;
l_draft_version_id        NUMBER         := NULL;
l_budget_type_code        pa_budget_types.budget_type_code%TYPE  := NULL;
l_mark_as_original        pa_budget_versions.original_flag%TYPE  := NULL;
l_budget_wf_flag          VARCHAR2(1)    := NULL;
l_bgt_intg_flag           VARCHAR2(1)    := NULL;
l_fck_req_flag            VARCHAR2(1)    := NULL;
l_dual_bdgt_cntrl_flag    VARCHAR2(1)    := NULL;
l_cc_budget_version_id    NUMBER         := NULL;

l_wf_started_by_username  VARCHAR2(100)   := NULL; /* Modified length from 30 to 100 for bug 2933743 */
l_msg_subj_text           VARCHAR2(2000) := NULL;
l_msg_desc_text           VARCHAR2(2000) := NULL;

--Apps Environement Variables
l_wf_started_by_id        NUMBER;
l_wf_started_by_resp_id   NUMBER;
l_wf_started_by_appl_id   NUMBER;


l_bgt_appr_wf_fired       VARCHAR(2) := 'N';
l_msg_count2	          NUMBER         := NULL;
l_msg_data2	          VARCHAR2(2000) := NULL;
l_return_status2          VARCHAR2(1)    := NULL;


CURSOR ccbgtver_csr
IS
SELECT b.budget_version_id
FROM   PA_BUDGETARY_CONTROL_OPTIONS bc,
       PA_BUDGET_VERSIONS b
WHERE  bc.project_id = b.project_id
AND    bc.external_budget_code = 'CC'
AND    bc.budget_type_code = b.budget_type_code
AND    b.project_id = l_project_id
AND    b.budget_status_code = 'S';


BEGIN

           -- Return if WF Engine Not Running
  	   IF (funcmode <> wf_engine.eng_run) THEN
    	       resultout := wf_engine.eng_null;
    	       RETURN;
  	   END IF;

--pa_fck_util.debug_msg('PAWFBUIB: BEGIN PA_BUDGET_INTG_WF.Process_Bgt_Intg');

           -- Setup Environment ------------------------------------------------

           -- Assume Success
           resultout         := wf_engine.eng_completed||':'||'T';


           -- Get Starting Apps Environment and Initialize
           l_wf_started_by_id := wf_engine.GetItemAttrNumber
			   (  itemtype => itemtype
                           ,  itemkey =>  itemkey
                           ,  aname => 'WORKFLOW_STARTED_BY_UID'
                           );

           l_wf_started_by_resp_id := wf_engine.GetItemAttrNumber
			   (  itemtype => itemtype
                           ,  itemkey =>  itemkey
                           ,  aname => 'WORKFLOW_STARTED_BY_RESP_ID'
                           );

           l_wf_started_by_appl_id := wf_engine.GetItemAttrNumber
			   (  itemtype => itemtype
                           ,  itemkey =>  itemkey
                           ,  aname => 'WORKFLOW_STARTED_BY_APPL_ID'
                           );


           FND_GLOBAL.Apps_Initialize ( user_id    => l_wf_started_by_id
                                    , resp_id      => l_wf_started_by_resp_id
                                    , resp_appl_id => l_wf_started_by_appl_id
                                    );
           -- -----------------------------------------------------------------



           -- Get Required Runtime Parmeters from WF --------------------------

           l_project_id := wf_engine.GetItemAttrNumber
			   (  itemtype => itemtype
                           ,  itemkey =>  itemkey
                           ,  aname => 'PROJECT_ID'
                           );

           l_draft_version_id := wf_engine.GetItemAttrNumber
			   (  itemtype => itemtype
                           ,  itemkey =>  itemkey
                           ,  aname => 'DRAFT_VERSION_ID'
                           );

           l_budget_type_code := wf_engine.GetItemAttrText
			   (  itemtype => itemtype
                           ,  itemkey =>  itemkey
                           ,  aname => 'BUDGET_TYPE_CODE'
                           );

           l_mark_as_original := wf_engine.GetItemAttrText
			   (  itemtype => itemtype
                           ,  itemkey =>  itemkey
                           ,  aname => 'MARK_AS_ORIGINAL'
                           );

           l_budget_wf_flag := wf_engine.GetItemAttrText
			   (  itemtype => itemtype
                           ,  itemkey =>  itemkey
                           ,  aname => 'BUDGET_WF_FLAG'
                           );

           l_fck_req_flag := wf_engine.GetItemAttrText
			   (  itemtype => itemtype
                           ,  itemkey =>  itemkey
                           ,  aname => 'FCK_REQ_FLAG'
                           );

           l_bgt_intg_flag := wf_engine.GetItemAttrText
			   (  itemtype => itemtype
                           ,  itemkey =>  itemkey
                           ,  aname => 'BGT_INTG_FLAG'
                           );


        -- R12 MOAC, 14-JUL-05, jwhite -------------------
        -- Set Single Project/OU context

        PA_BUDGET_UTILS.Set_Prj_Policy_Context
          (p_project_id => l_project_id
           ,x_return_status => l_return_status
           ,x_msg_count     => l_msg_count
           ,x_msg_data      => l_msg_data
           ,x_err_code      => l_err_code
           );

        IF (l_err_code <> 0)
          THEN
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

       -- -----------------------------------------------





           -- Processing Logic -----------------------------------------------

           IF (nvl(l_budget_wf_flag,'N') = 'Y')
              THEN

                -- R12 SLA Effort
                -- CHECK_BASELINE functionality is no longer suppored

             /*
                -- Budget Approval Workflow ENABLED !!!
	        PA_Budget_Fund_Pkg.Check_Or_Reserve_Funds
		          (p_project_id			=> l_project_id
                          , p_budget_version_id		=> l_draft_version_id
                          , p_calling_mode		=> 'CHECK_BASELINE'
                          , x_dual_bdgt_cntrl_flag	=> l_dual_bdgt_cntrl_flag
                          , x_cc_budget_version_id	=> l_cc_budget_version_id
                          , x_return_status		=> l_return_status
                          , x_msg_data			=> l_msg_data
                          , x_msg_count			=> l_msg_count
                          );

                IF (nvl(l_msg_count,0) > 0)
                   THEN
                   -- Validations for Funds Check Failed.
                   -- Do Not Do Anything. Just Drop Down to Next Subsection of Code
                      NULL;
                ELSE
                -- R12 SLA Effort

              */
                   --  Call Budget Approval Workflow!!!

                   PA_BUDGET_WF.Start_Budget_WF
                   (p_draft_version_id	    => l_draft_version_id
                   , p_project_id           => l_project_id
                   , p_budget_type_code     => l_budget_type_code
                   , p_mark_as_original     => l_mark_as_original
                   , p_fck_req_flag         => l_fck_req_flag
                   , p_bgt_intg_flag        => l_bgt_intg_flag
                   , p_err_code             => l_err_code
                   , p_err_stage            => l_err_stage
                   , p_err_stack            => l_err_stack
                   );

                   -- Keep track of Budget Approval WF Fired for Subsequent Conditional
                   -- Processing.
                   l_bgt_appr_wf_fired := 'Y';

                  IF (l_err_code <> 0 )
                   THEN
                    -- Process ORA Error:
                    IF (l_err_code > 0)
                       THEN
	                IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
	                    THEN
		                FND_MESSAGE.SET_NAME('PA','PA_WF_CLIENT_EXTN');
                                FND_MESSAGE.SET_TOKEN('EXTNAME', 'PA_BUDGET_WF.START_BUDGET_WF');
            		        FND_MESSAGE.SET_TOKEN('ERRCODE',l_err_code);
		                FND_MESSAGE.SET_TOKEN('ERRMSG', l_err_stage);
		                FND_MSG_PUB.add;
	                END IF;
                        l_return_status := FND_API.G_RET_STS_ERROR;

                    ELSE
                     -- Process App Error
	                 IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	                     THEN
		               FND_MSG_PUB.add_exc_msg
			       (p_pkg_name		=> 'PA_BUDGET_WF'
			       ,  p_procedure_name	=> 'START_BUDGET_WF'
			       ,  p_error_text		=> 'ORA-'||LPAD(substr(l_err_code,2),5,'0') );
	                 END IF;
                         l_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                   END IF; --(l_err_code > 0)

                 END IF; --(l_err_code <> 0 )

                -- R12 SLA Effort
                -- END IF; --(nvl(l_msg_count,0) > 0)

           ELSE
              -- DISABLED: Budget Approval Workflow !!!
              -- Do NOT Call Workflow. Instead, Call WRAPPER Baseline_Budget API

-- bug 1929871, 19-SEP-2001, jwhite --------------------------
-- Add cursor to get commitment budget version id for subsequent update

              -- For subsequent Commitment Budget Budget Version Update, Get the
              -- commimtment budget version id, IF ANY.

                 OPEN ccbgtver_csr;
                 FETCH ccbgtver_csr INTO l_cc_budget_version_id;
                 IF ccbgtver_csr%NOTFOUND
                   THEN
                       l_cc_budget_version_id := NULL;
                 END IF;
                 CLOSE ccbgtver_csr;


-- ---------------------------------------------------------------

              -- Call WRAPPER Baseline Budget API
              -- Pass 'N' for p_verify_budget_rules because checking should have already been done
              -- in the Budgets form




                  PA_BUDGET_UTILS.Baseline_Budget
                   ( p_draft_version_id     => l_draft_version_id
                   ,p_project_id            => l_project_id
                   ,p_mark_as_original	    => l_mark_as_original
                   ,p_verify_budget_rules   => 'N'
                   ,p_fck_req_flag          => l_fck_req_flag
                   ,x_msg_count             => l_msg_count
                   ,x_msg_data              => l_msg_data
                   ,x_return_status         => l_return_status
                   );


          END IF; --(nvl(l_budget_wf_flag,'N') = 'Y')


          -- Notification Procesing ------------------------------------------------
  --pa_fck_util.debug_msg('PAWFBUIB: Notification Environment');
  --pa_fck_util.debug_msg('PAWFBUIB: -- l_return_status: '||l_return_status);
  --pa_fck_util.debug_msg('PAWFBUIB: -- l_msg_count: '||to_char(l_msg_count));
  --pa_fck_util.debug_msg('PAWFBUIB: -- l_msg_data: '||l_msg_data);


          -- IF Budget Approval WF   N-O-T   F-I-R-E-D,
          -- Conditionally Update the Budget Version WF Status Code

           IF (nvl(l_bgt_appr_wf_fired,'N') <> 'Y')
              THEN
             -- The following can only have ORA errors, which will
             -- cancel the workflow. ORA errors should be rare, however.

-- bug 1929871, 19-SEP-2001, jwhite --------------------------
-- Added code to update the commitment budget, IF ANY
             IF (l_return_status = FND_API.G_RET_STS_SUCCESS)
              THEN
              -- Success!

                        -- Update Draft Cost Budget Version Id
                        Set_wf_status_code (p_draft_version_id => l_draft_version_id
                               , p_wf_result_code   => 'SUCCESS'
                               , x_msg_count      => l_msg_count2
                               , x_msg_data       => l_msg_data2
                               , x_return_status  => l_return_status2
                               );

                        -- Update Draft Commitment Budget Version Id, IF ANY
                        IF ( nvl(l_CC_Budget_Version_id,0) > 0 )
                          THEN
                           Set_wf_status_code (p_draft_version_id => l_cc_budget_version_id
                               , p_wf_result_code   => 'SUCCESS'
                               , x_msg_count      => l_msg_count2
                               , x_msg_data       => l_msg_data2
                               , x_return_status  => l_return_status2
                               );
                        END IF;
             ELSE
              -- Failure!

                        -- Update Draft Cost Budget Version Id
                        Set_wf_status_code (p_draft_version_id => l_draft_version_id
                               , p_wf_result_code   => 'FAILURE'
                               , x_msg_count      => l_msg_count2
                               , x_msg_data       => l_msg_data2
                               , x_return_status  => l_return_status2
                               );

                        -- Update Draft Commitment Budget Version Id, IF ANY
                        IF ( nvl(l_CC_Budget_Version_id,0) > 0 )
                          THEN
                          Set_wf_status_code (p_draft_version_id => l_cc_budget_version_id
                               , p_wf_result_code   => 'FAILURE'
                               , x_msg_count      => l_msg_count2
                               , x_msg_data       => l_msg_data2
                               , x_return_status  => l_return_status2
                               );
                        END IF;

             END IF;
-- ----------------------------------------------------

          END IF; --NOT FIRED, Budget Approval WF; Update WF Status Code


          -- Conditionally Process Notification Messages
          IF (l_return_status = FND_API.G_RET_STS_SUCCESS)
              THEN
              -- Success!

              FND_MESSAGE.SET_NAME ('PA','PA_NFSUBJ_BU_INTG_SUCCESS');
	      l_msg_subj_text := FND_MESSAGE.GET;

	      FND_MESSAGE.SET_NAME ('PA','PA_NFDESC_BU_INTG_SUCCESS');
	      l_msg_desc_text := FND_MESSAGE.GET;

              wf_engine.SetItemAttrText
			       ( itemtype => itemtype
                               , itemkey =>  itemkey
                               , aname =>    'MSG_SUBJECT_FYI'
                               , avalue =>   l_msg_subj_text
                               );

              wf_engine.SetItemAttrText
			       ( itemtype => itemtype
                               , itemkey =>  itemkey
                               , aname =>    'MSG_DESCRIPTION_FYI'
                               , avalue =>   l_msg_desc_text
                               );

           ELSE
           -- Errors! Note that the WF ONLY marked as FAILURE if ORA error

              FND_MESSAGE.SET_NAME ('PA','PA_NFSUBJ_BU_INTG_FAILURE');
	      l_msg_subj_text := FND_MESSAGE.GET;

	      FND_MESSAGE.SET_NAME ('PA','PA_NFDESC_BU_INTG_FAILURE');
	      l_msg_desc_text := FND_MESSAGE.GET;

              wf_engine.SetItemAttrText
			       ( itemtype => itemtype
                               , itemkey =>  itemkey
                               , aname =>    'MSG_SUBJECT_FYI'
                               , avalue =>   l_msg_subj_text
                               );

              wf_engine.SetItemAttrText
			       ( itemtype => itemtype
                               , itemkey =>  itemkey
                               , aname =>    'MSG_DESCRIPTION_FYI'
                               , avalue =>   l_msg_desc_text
                               );

                -- Populate Errors for Notification
               set_nf_error_msg_attr (p_item_type => itemtype,
			              p_item_key  => itemkey,
				      p_msg_count => l_msg_count,
				      p_msg_data  => l_msg_data
                                      );

              -- Hard ORA error. WF FAILURE! Notification will Route to Projects Sys Admin.
              IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR)
                 THEN

                   -- Set WF Status for FAILURE. Route to Sys Admin
                   resultout := wf_engine.eng_completed||':'||'F';

              END IF; -- Hard ORA error

           END IF; --Conditionally Populate NF MSG and Errors

 --pa_fck_util.debug_msg('PAWFBUIB: END PA_BUDGET_INTG_WF.Process_Bgt_Intg');

EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR	THEN  -- R12 MOAC: Added unexpected error exception
      WF_CORE.CONTEXT
		('PA_BUDGET_INTG_MP',
		 'Process_Bgt_Intg',
		  itemtype,
		  itemkey,
		  to_char(actid),
		  funcmode);
      RAISE;
    WHEN OTHERS THEN
      Set_wf_status_code (p_draft_version_id => l_draft_version_id
                         , p_wf_result_code   => 'FAILURE'
                         , x_msg_count      => l_msg_count2
                         , x_msg_data       => l_msg_data2
                         , x_return_status  => l_return_status2
                         );
      WF_CORE.CONTEXT
		('PA_BUDGET_INTG_MP',
		 'Process_Bgt_Intg',
		  itemtype,
		  itemkey,
		  to_char(actid),
		  funcmode);
      RAISE;


END Process_Bgt_Intg;



--Name:               set_nf_error_msg_attr
--Type:               Procedure
--Description:        This procedure populates the notificatin error message fields.
--
--Called subprograms: None.
--
--History:
--    26-MAR-01		jwhite		Cloned from PA_ASGMT_WFSTD package
--
--    11-JUL-01         jwhite          Bug 1877119.
--                                      For a FAILURE transition, rewrote
--                                      error processing code to treat
--                                      NULL or zero (0) msg_count as
--                                      msg_count = 1.
--
--                                      Also, replaced fnd_message.set_encoded
--                                      with set_message.
--
--	08-APR-02	jwhite		Bug 2310429
--                                      Made changes to gracefully handle ORA
--                                      error conditions and alert the user via
--                                      notification:
--                                      1) Converted exception RAISE to RETURN
--                                      2) Added "IF length(p_msg_data) < 31" condition
--                                         to handle ORA error messages.
--

PROCEDURE set_nf_error_msg_attr (p_item_type IN VARCHAR2,
			         p_item_key  IN VARCHAR2,
				 p_msg_count IN NUMBER,
				 p_msg_data IN VARCHAR2 ) IS

l_project_id       NUMBER := NULL;
l_msg_index_out	   NUMBER ;
l_msg_data	   VARCHAR2(2000) := NULL;
l_data	           VARCHAR2(2000) := NULL;
l_item_attr_name   VARCHAR2(30);
l_msg_err_text     VARCHAR2(100);

BEGIN



 	  IF ( (nvl(p_msg_count,0) = 0 )
                 OR (p_msg_count = 1)    )
            THEN
	     IF p_msg_data IS NOT NULL
               THEN

                IF length(p_msg_data) < 31
                   THEN

                      FND_MESSAGE.SET_NAME ('PA',p_msg_data);
                      l_data := FND_MESSAGE.GET;

                END IF;


                IF (l_data IS NULL)
                  THEN
                    l_data := p_msg_data;
                END IF;

                wf_engine.SetItemAttrText
			       ( itemtype => p_item_type
                               , itemkey =>  p_item_key
                               , aname => 'ERROR_COMMENTS_1'
                               , avalue => l_data
                               );
	     END IF;
             RETURN ;
          END IF;


     	  IF p_msg_count > 1 THEN
              FOR i in 1..p_msg_count
	    LOOP
	      IF i > 5 THEN
	  	 EXIT;
	      END IF;
	      pa_interface_utils_pub.get_messages
		(p_encoded        => FND_API.G_FALSE,
 		 p_msg_index      => i,
                 p_msg_count      => p_msg_count ,
                 p_msg_data       => p_msg_data ,
                 p_data           => l_data,
                 p_msg_index_out  => l_msg_index_out );

                 l_item_attr_name := 'ERROR_COMMENTS_'||i;

                 wf_engine.SetItemAttrText
			       ( itemtype => p_item_type
                               , itemkey =>  p_item_key
                               , aname => l_item_attr_name
                               , avalue => l_data
                               );
            END LOOP;
	  END IF;



EXCEPTION
	WHEN OTHERS THEN RETURN;

END set_nf_error_msg_attr;



--Name:               set_wf_status_code
--Type:               Procedure
--Description:        This procedure conditionally populates budget version
--                    wf_status_code.
--
--Called subprograms: None.
--
--Notes
--  Given the NOWAIT status, ORA errors are not expected and, therefore,
--  not explicitly handled.
--
--History:
--    23-MAY-01		jwhite		Created
--


PROCEDURE set_wf_status_code (p_draft_version_id IN   NUMBER
           , p_wf_result_code          IN   VARCHAR2
           , x_msg_count               OUT  NOCOPY NUMBER  --File.Sql.39 bug 4440895
           , x_msg_data                OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
           , x_return_status           OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
           ) IS


BEGIN

        -- Assume Success
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        -- Conditionally Populate wf_status_code
        IF (p_wf_result_code = 'SUCCESS')
           THEN
             UPDATE pa_budget_versions
	     SET budget_status_code = 'W', WF_status_code = NULL
             WHERE budget_version_id = p_draft_version_id;
        ELSE
             --FAILURE: Reject!
             UPDATE pa_budget_versions
	     SET budget_status_code = 'W', WF_status_code = 'REJECTED'
             WHERE budget_version_id = p_draft_version_id;
        END IF;

  EXCEPTION
    WHEN OTHERS
        THEN
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	  FND_MSG_PUB.Add_Exc_Msg
			(  p_pkg_name		=> 'PA_BUDGET_INTG_WF'
			,  p_procedure_name	=> 'SET_WF_STATUS_CODE'
			,  p_error_text		=> 'ORA-'||LPAD(substr(SQLCODE,2),5,'0')
                        );
	 FND_MSG_PUB.Count_And_Get
	 (p_count		=>	x_msg_count	,
	  p_data		=>	x_msg_data	);
         RETURN;



END  set_wf_status_code;
-- =================================================

END pa_budget_intg_wf;


/
