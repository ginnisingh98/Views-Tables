--------------------------------------------------------
--  DDL for Package PA_ASGMT_WFSTD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_ASGMT_WFSTD" AUTHID CURRENT_USER AS
--  $Header: PAWFAAPS.pls 120.1.12000000.2 2008/10/06 21:02:23 asahoo ship $
 g_rejector_uname VARCHAR2(30);
 g_approver_response VARCHAR2(2000);
 g_mass_approval VARCHAR2(10) := 'Mass';
 g_single_approval VARCHAR2(10) := 'Single';
 PROCEDURE Start_Workflow ( p_project_id           IN NUMBER DEFAULT NULL
                          , p_assignment_id        IN NUMBER
			  , p_status_code          IN VARCHAR2 DEFAULT NULL
                          , p_person_id            IN NUMBER DEFAULT NULL
                          , p_wf_item_type         IN VARCHAR2
                          , p_wf_process           IN VARCHAR2
			  , p_approver1_person_id  IN NUMBER DEFAULT NULL
			  , p_approver1_type       IN VARCHAR2 DEFAULT NULL
			  , p_approver2_person_id  IN NUMBER DEFAULT NULL
			  , p_approver2_type       IN VARCHAR2  DEFAULT NULL
			  , p_apprvl_item_type     IN VARCHAR2 DEFAULT NULL
			  , p_apprvl_item_key      IN VARCHAR2 DEFAULT NULL
                          , p_conflict_group_id    IN NUMBER DEFAULT NULL
 			  , x_msg_count	           OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
 			  , x_msg_data	           OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
			  , x_return_status        OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
			  , x_error_message_code   OUT NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895

  PROCEDURE  get_workflow_process_info
			  (p_status_code IN VARCHAR2
			   ,x_wf_item_type OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
			   ,x_wf_process	  OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
			   ,x_wf_type	  OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 			   ,x_msg_count	   OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
 			   ,x_msg_data	   OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
			   ,x_return_status  OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
			   ,x_error_message_code OUT NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895

  FUNCTION Is_approval_pending (p_assignment_id IN NUMBER) RETURN VARCHAR2;
  PRAGMA RESTRICT_REFERENCES (Is_approval_pending, WNPS,WNDS) ;


  PROCEDURE Generate_URL ( itemtype  IN VARCHAR2
                         , itemkey   IN VARCHAR2
                         , actid     IN NUMBER
                         , funcmode  IN VARCHAR2
                         , resultout OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                         );

  PROCEDURE Generate_URL_failure
			( itemtype  IN VARCHAR2
                         , itemkey   IN VARCHAR2
                         , actid     IN NUMBER
                         , funcmode  IN VARCHAR2
                         , resultout OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                         );

  PROCEDURE Start_New_WF  (itemtype IN VARCHAR2
                         , itemkey IN VARCHAR2
                         , actid IN NUMBER
                         , funcmode IN VARCHAR2
                         , resultout OUT NOCOPY VARCHAR2 ) ; --File.Sql.39 bug 4440895

  PROCEDURE Set_Success_Status  (itemtype IN VARCHAR2
                               , itemkey IN VARCHAR2
                               , actid IN NUMBER
                               , funcmode IN VARCHAR2
                               , resultout OUT NOCOPY VARCHAR2 ) ; --File.Sql.39 bug 4440895

  PROCEDURE Set_Failure_Status  (itemtype IN VARCHAR2
                               , itemkey IN VARCHAR2
                               , actid IN NUMBER
                               , funcmode IN VARCHAR2
                               , resultout OUT NOCOPY VARCHAR2 ) ; --File.Sql.39 bug 4440895

  PROCEDURE Generate_Approvers (itemtype IN VARCHAR2
                               , itemkey IN VARCHAR2
                               , actid IN NUMBER
                               , funcmode IN VARCHAR2
                               , resultout OUT NOCOPY VARCHAR2 ) ; --File.Sql.39 bug 4440895

  PROCEDURE Get_Approver       (itemtype IN VARCHAR2
                               , itemkey IN VARCHAR2
                               , actid IN NUMBER
                               , funcmode IN VARCHAR2
                               , resultout OUT NOCOPY VARCHAR2 ) ; --File.Sql.39 bug 4440895

  PROCEDURE Generate_apprvl_nf_recipients
			        (itemtype IN VARCHAR2
                               , itemkey IN VARCHAR2
                               , actid IN NUMBER
                               , funcmode IN VARCHAR2
                               , resultout OUT NOCOPY VARCHAR2 ) ; --File.Sql.39 bug 4440895

  PROCEDURE Get_Approval_NF_Recipient
                                (itemtype IN VARCHAR2
                               , itemkey IN VARCHAR2
                               , actid IN NUMBER
                               , funcmode IN VARCHAR2
                               , resultout OUT NOCOPY VARCHAR2 ) ; --File.Sql.39 bug 4440895

  PROCEDURE Generate_reject_nf_recipients
                                (itemtype IN VARCHAR2
                               , itemkey IN VARCHAR2
                               , actid IN NUMBER
                               , funcmode IN VARCHAR2
                               , resultout OUT NOCOPY VARCHAR2 ) ; --File.Sql.39 bug 4440895

  PROCEDURE Get_Reject_NF_Recipient
			        (itemtype IN VARCHAR2
                               , itemkey IN VARCHAR2
                               , actid IN NUMBER
                               , funcmode IN VARCHAR2
                               , resultout OUT NOCOPY VARCHAR2 ) ; --File.Sql.39 bug 4440895

  PROCEDURE Generate_cancel_nf_recipients
                                (itemtype IN VARCHAR2
                               , itemkey IN VARCHAR2
                               , actid IN NUMBER
                               , funcmode IN VARCHAR2
                               , resultout OUT NOCOPY VARCHAR2 ) ; --File.Sql.39 bug 4440895
  PROCEDURE Get_Cancel_NF_Recipient
			        (itemtype IN VARCHAR2
                               , itemkey IN VARCHAR2
                               , actid IN NUMBER
                               , funcmode IN VARCHAR2
                               , resultout OUT NOCOPY VARCHAR2 ) ; --File.Sql.39 bug 4440895


  PROCEDURE Check_Wf_Enabled    (itemtype IN VARCHAR2
                               , itemkey IN VARCHAR2
                               , actid IN NUMBER
                               , funcmode IN VARCHAR2
                               , resultout OUT NOCOPY VARCHAR2 ) ; --File.Sql.39 bug 4440895

  PROCEDURE Set_Forwarded_From  (itemtype IN VARCHAR2
                               , itemkey IN VARCHAR2
                               , actid IN NUMBER
                               , funcmode IN VARCHAR2
                               , resultout OUT NOCOPY VARCHAR2 ) ; --File.Sql.39 bug 4440895

  PROCEDURE Set_Approval_Reqd_Msg (itemtype IN VARCHAR2
                               , itemkey IN VARCHAR2
                               , actid IN NUMBER
                               , funcmode IN VARCHAR2
                               , resultout OUT NOCOPY VARCHAR2 ) ; --File.Sql.39 bug 4440895

  PROCEDURE Set_Approved_Msg   (itemtype IN VARCHAR2
                               , itemkey IN VARCHAR2
                               , actid IN NUMBER
                               , funcmode IN VARCHAR2
                               , resultout OUT NOCOPY VARCHAR2 ) ; --File.Sql.39 bug 4440895

  PROCEDURE Set_Rejected_Msg   (itemtype IN VARCHAR2
                               , itemkey IN VARCHAR2
                               , actid IN NUMBER
                               , funcmode IN VARCHAR2
                               , resultout OUT NOCOPY VARCHAR2 ) ; --File.Sql.39 bug 4440895

  PROCEDURE Set_Canceled_Msg   (itemtype IN VARCHAR2
                               , itemkey IN VARCHAR2
                               , actid IN NUMBER
                               , funcmode IN VARCHAR2
                               , resultout OUT NOCOPY VARCHAR2 ) ; --File.Sql.39 bug 4440895

  PROCEDURE Validate_Forwarded_User  (itemtype IN VARCHAR2
                               , itemkey IN VARCHAR2
                               , actid IN NUMBER
                               , funcmode IN VARCHAR2
                               , resultout OUT NOCOPY VARCHAR2 ) ; --File.Sql.39 bug 4440895

  PROCEDURE Set_Approval_Pending  (itemtype IN VARCHAR2
                               , itemkey IN VARCHAR2
                               , actid IN NUMBER
                               , funcmode IN VARCHAR2
                               , resultout OUT NOCOPY VARCHAR2 ) ; --File.Sql.39 bug 4440895

  PROCEDURE Maintain_wf_pending_flag (p_assignment_id  IN NUMBER,
				      p_mode  IN VARCHAR2 );
  PROCEDURE Set_Asgmt_wf_result_Status
     (p_assignment_id IN pa_project_assignments.assignment_id%TYPE,
      p_status_code IN pa_project_statuses.project_status_code%TYPE,
      p_result_type  IN VARCHAR2,
      p_item_type IN VARCHAR2,
      p_item_key  IN VARCHAR2 ,
      x_return_status OUT NOCOPY VARCHAR2 ) ; --File.Sql.39 bug 4440895

   PROCEDURE generate_sch_err_msg
                (document_id     IN      VARCHAR2,
                 display_type    IN      VARCHAR2,
                 document        IN OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                 document_type   IN OUT  NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

  PROCEDURE Capture_approver_comment  (itemtype IN VARCHAR2
                               , itemkey IN VARCHAR2
                               , actid IN NUMBER
                               , funcmode IN VARCHAR2
                               , resultout OUT NOCOPY VARCHAR2 ) ; --File.Sql.39 bug 4440895

  PROCEDURE Populate_approval_NF_comments  (itemtype IN VARCHAR2
                               , itemkey IN VARCHAR2
                               , actid IN NUMBER
                               , funcmode IN VARCHAR2
                               , resultout OUT NOCOPY VARCHAR2 ) ; --File.Sql.39 bug 4440895

  PROCEDURE Delete_Assignment_WF_Records (p_assignment_id  IN   pa_project_assignments.assignment_id%TYPE,
                                          p_project_id     IN   pa_project_assignments.project_id%TYPE);

  PROCEDURE Check_And_Get_Proj_Customer ( p_project_id IN NUMBER
				                         ,x_customer_id OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
				                         ,x_customer_name OUT NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895

  PROCEDURE start_mass_approval_flow
   ( p_project_id          IN   NUMBER              := FND_API.G_MISS_NUM
    ,p_mode                IN   VARCHAR2            := FND_API.G_MISS_CHAR
    ,p_note_to_approvers   IN   VARCHAR2            := FND_API.G_MISS_CHAR
    ,p_forwarded_from      IN   VARCHAR2
    ,p_performer_user_name IN   VARCHAR2            := FND_API.G_MISS_CHAR
    ,p_routing_order       IN   NUMBER              := FND_API.G_MISS_NUM
    ,p_group_id		   IN   NUMBER              := FND_API.G_MISS_NUM
    ,p_approver_group_id   IN   NUMBER              := FND_API.G_MISS_NUM
    ,p_submitter_user_name IN   VARCHAR2            := FND_API.G_MISS_CHAR
    ,p_update_info_doc     IN   VARCHAR2            := FND_API.G_MISS_CHAR
    ,p_project_name        IN   VARCHAR2
    ,p_project_number      IN   VARCHAR2
    ,p_project_manager     IN   VARCHAR2
    ,p_project_org         IN   VARCHAR2
    ,p_project_cus         IN   VARCHAR2
    ,p_conflict_group_id   IN   NUMBER              := FND_API.G_MISS_NUM
    ,x_return_status       OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
    ,x_msg_count           OUT  NOCOPY NUMBER         --File.Sql.39 bug 4440895
    ,x_msg_data            OUT  NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895

    PROCEDURE process_approval_result_wf
                  ( itemtype    IN      VARCHAR2
                   ,itemkey     IN      VARCHAR2
                   ,actid       IN      NUMBER
                   ,funcmode    IN      VARCHAR2
                   ,resultout   OUT     NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895

    PROCEDURE Check_Approval_Type
                  ( itemtype  IN VARCHAR2
                   ,itemkey   IN VARCHAR2
                   ,actid     IN NUMBER
                   ,funcmode  IN VARCHAR2
                   ,resultout OUT NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895

    PROCEDURE Check_Notification_Completed
              ( itemtype  IN VARCHAR2
               ,itemkey   IN VARCHAR2
               ,actid     IN NUMBER
               ,funcmode  IN VARCHAR2
               ,resultout OUT NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895

    PROCEDURE process_res_fyi_notification
        ( p_project_id           IN   NUMBER    := FND_API.G_MISS_NUM
         ,p_assignment_id        IN   NUMBER    := FND_API.G_MISS_NUM
         ,p_mode                 IN   VARCHAR2
         ,p_project_name         IN   VARCHAR2
         ,p_project_number       IN   VARCHAR2
         ,p_project_manager      IN   VARCHAR2
         ,p_project_org          IN   VARCHAR2
         ,p_project_cus          IN   VARCHAR2
         ,p_conflict_group_id    IN   NUMBER    := NULL
         ,x_return_status        OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
         ,x_msg_count            OUT  NOCOPY NUMBER         --File.Sql.39 bug 4440895
         ,x_msg_data             OUT  NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895

PROCEDURE process_submitter_notification
    ( p_project_id           IN   NUMBER    := FND_API.G_MISS_NUM
     ,p_mode                 IN  VARCHAR2
     ,p_group_id             IN   NUMBER    := FND_API.G_MISS_NUM
     ,p_update_info_doc      IN   VARCHAR2  := FND_API.G_MISS_CHAR
     ,p_num_apr_asgns        IN   NUMBER
     ,p_num_rej_asgns        IN   NUMBER
     ,p_project_name         IN   VARCHAR2
     ,p_project_number       IN   VARCHAR2
     ,p_project_manager      IN   VARCHAR2
     ,p_project_org          IN   VARCHAR2
     ,p_project_cus          IN   VARCHAR2
     ,p_submitter_user_name  IN   VARCHAR2
     ,p_assignment_id        IN   NUMBER := FND_API.G_MISS_NUM
     ,x_return_status        OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     ,x_msg_count            OUT  NOCOPY NUMBER         --File.Sql.39 bug 4440895
     ,x_msg_data             OUT  NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895

PROCEDURE Set_Submitter_User_Name
            (p_item_type     IN        VARCHAR2,
             p_item_key      IN        VARCHAR2,
             p_actid         IN        NUMBER,
             p_funcmode      IN        VARCHAR2,
             p_result        OUT       NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

PROCEDURE Abort_Remaining_Trx
            (p_item_type     IN        VARCHAR2,
             p_item_key      IN        VARCHAR2,
             p_actid         IN        NUMBER,
             p_funcmode      IN        VARCHAR2,
             p_result        OUT       NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

PROCEDURE process_mgr_fyi_notification
    ( p_assignment_id_tbl    IN   SYSTEM.pa_num_tbl_type
     ,p_project_id           IN   NUMBER    := FND_API.G_MISS_NUM
     ,p_group_id             IN   NUMBER    := FND_API.G_MISS_NUM
     ,p_mode                 IN   VARCHAR2
     ,p_update_info_doc      IN   VARCHAR2  := FND_API.G_MISS_CHAR
     ,p_num_apr_asgns        IN   NUMBER
     ,p_num_rej_asgns        IN   NUMBER
     ,p_project_name         IN   VARCHAR2
     ,p_project_number       IN   VARCHAR2
     ,p_project_manager      IN   VARCHAR2
     ,p_project_org          IN   VARCHAR2
     ,p_project_cus          IN   VARCHAR2
     ,p_submitter_user_name  IN   VARCHAR2
     ,p_conflict_group_id    IN   NUMBER    := FND_API.G_MISS_NUM
     ,x_return_status        OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     ,x_msg_count            OUT  NOCOPY NUMBER         --File.Sql.39 bug 4440895
     ,x_msg_data             OUT  NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895

END PA_ASGMT_WFSTD;
 

/

  GRANT EXECUTE ON "APPS"."PA_ASGMT_WFSTD" TO "EBSBI";
