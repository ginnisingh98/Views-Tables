--------------------------------------------------------
--  DDL for Package PA_WORKPLAN_WORKFLOW
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_WORKPLAN_WORKFLOW" AUTHID CURRENT_USER as
/*$Header: PAXSTWWS.pls 120.1 2005/08/19 17:20:49 mwasowic noship $*/


  procedure START_WORKFLOW
  (
    p_item_type              IN  VARCHAR2
   ,p_process_name           IN  VARCHAR2
   ,p_structure_version_id   IN  NUMBER
   ,p_responsibility_id      IN  NUMBER
   ,p_user_id                IN  NUMBER
   ,x_item_key               OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   ,x_msg_count              OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
   ,x_msg_data               OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   ,x_return_status          OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  );

  procedure cancel_workflow
  (
    p_item_type              IN  VARCHAR2
   ,p_item_key               IN  VARCHAR2
   ,x_msg_count              OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
   ,x_msg_data               OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   ,x_return_status          OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  );

  procedure check_workplan_status
  (
    itemtype       IN   VARCHAR2
   ,itemkey        IN   VARCHAR2
   ,actid          IN   NUMBER
   ,funcmode       IN   VARCHAR2
   ,resultout      OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  );

  procedure change_status_working
  (
    itemtype     IN  VARCHAR2
   ,itemkey      IN  VARCHAR2
   ,actid        IN  NUMBER
   ,funcmode     IN  VARCHAR2
   ,resultout    OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  );

  procedure change_status_rejected
  (
    itemtype     IN  VARCHAR2
   ,itemkey      IN  VARCHAR2
   ,actid        IN  NUMBER
   ,funcmode     IN  VARCHAR2
   ,resultout    OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  );

  procedure change_status_approved
  (
    itemtype     IN  VARCHAR2
   ,itemkey      IN  VARCHAR2
   ,actid        IN  NUMBER
   ,funcmode     IN  VARCHAR2
   ,resultout    OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  );

  procedure SELECT_ERROR_RECEIVER
  (
    p_item_type          IN  VARCHAR2
   ,p_item_key           IN  VARCHAR2
   ,actid                IN  NUMBER
   ,funcmode             IN  VARCHAR2
   ,resultout            OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  );

  procedure SHOW_WORKPLAN_PUB_ERR
  (document_id IN VARCHAR2,
   display_type IN VARCHAR2,
   document IN OUT NOCOPY clob, --File.Sql.39 bug 4440895
   document_type IN OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

-- FP M : 3491609 : Project Execution Workflow
PROCEDURE START_PROJECT_EXECUTION_WF
  (
    p_project_id    IN  pa_projects_all.project_id%TYPE  --changed type from varchar to column type  3619185 Satish
   ,x_msg_count     OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
   ,x_msg_data      OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   ,x_return_status OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ) ;

PROCEDURE CANCEL_PROJECT_EXECUTION_WF
  (
    p_project_id    IN  pa_projects_all.project_id%TYPE  --changed type from varchar to column type 3619185  Satish
   ,x_msg_count     OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
   ,x_msg_data      OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   ,x_return_status OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  );

PROCEDURE START_TASK_EXECUTION_WF
     ( itemtype  in varchar2
      ,itemkey   in varchar2
      ,actid     in number
      ,funcmode  in varchar2
      ,resultout out NOCOPY varchar2  --File.Sql.39 bug 4440895
      ) ;

PROCEDURE CANCEL_TASK_EXECUTION_WF
  (
    p_task_id       IN  VARCHAR2
   ,x_msg_count     OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
   ,x_msg_data      OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   ,x_return_status OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  );

PROCEDURE RESTART_TASK_EXECUTION_WF
     ( p_task_id        IN NUMBER
      ,x_msg_count     OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
      ,x_msg_data      OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
      ,x_return_status OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
      ) ;

PROCEDURE IS_PROJECT_CLOSED
     ( itemtype  in varchar2
      ,itemkey   in varchar2
      ,actid     in number
      ,funcmode  in varchar2
      ,resultout out NOCOPY varchar2  --File.Sql.39 bug 4440895
      ) ;
-- FP M : 3491609 : Project Execution Workflow

end PA_WORKPLAN_WORKFLOW;

 

/
