--------------------------------------------------------
--  DDL for Package EAM_JOBCLOSE_PRIV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EAM_JOBCLOSE_PRIV" AUTHID CURRENT_USER AS
/* $Header: EAMJCLPS.pls 120.0.12010000.2 2008/11/06 23:48:57 mashah ship $ */

/*************************************************************************
 *
 *			 procedure EAM_CLOSE_MGR
 *
 *************************************************************************
 * This procedure will be used to create an executable file that
 * will be called from Close Manager.
 *
 * PARAMETER:
 *
 * errbuf                 error messages
 * retcode                return status. 0 for success, 1 for warning and
 *                        2 for error.
 * p_organization_id      Organization Id.
 *
 * p_class_type           Accounting Class type - Standard Discrete,
 *                        Asset Non Standard , Expense non Std ,etc
 * p_from_class           To select a range of accounting classes ,a
 *                        a select From range of class   and
 * p_to_class             a select To range of class  is used.
 *
 * p_from_job ,p_to_job   To select a range of jobs for closure ,a
 *                        From job and To Job  is used.
 * p_from_release_date ,
 * p_to_release_date      To select a range of jobs for closure between the
 *                        specified job release dates .
 * p_from_start_date ,
 * p_to_start_date        To select a range of jobs for closure between the
 *                        specified job  start dates .
 * p_from_completion_date ,
 * p_to_completion_date   To select a range of jobs for closure between the
 *                        specified job  completion dates .
 * p_status               The various statuses of Jobs like RELEASED, COMPLETE
 *                        COMPLETE NO CHARGES , ON HOLD , FAILED CLOSE , etc
 * p_group_id             group_id in WIP_DJ_CLOSE_TEMP
 *
 * p_exclude_reserved_jobs 	Decides if we can select reserved jobs
 *
 * p_exclude_pending_txn_jobs  Decides if we can select jobs with pending
 *                             transactions
 * p_report_type          The various report types like SUMMARY , NO REPORT ,
 *                        DETAIL USING PLANNED START QUANTITY , etc
 * p_act_close_date    	  Actual close date of the Job.
 *
 *
 ***************************************************************************/


procedure EAM_CLOSE_MGR
(
      ERRBUF               OUT  NOCOPY VARCHAR2 ,
      RETCODE              OUT  NOCOPY VARCHAR2 ,
      p_organization_id     IN  NUMBER  ,
      p_class_type          IN  VARCHAR2 ,
      p_from_class          IN  VARCHAR2  ,
      p_to_class            IN  VARCHAR2  ,
      p_from_job            IN  VARCHAR2  ,
      p_to_job              IN  VARCHAR2  ,
      p_from_release_date   IN  VARCHAR2  ,
      p_to_release_date     IN  VARCHAR2  ,
      p_from_start_date     IN  VARCHAR2  ,
      p_to_start_date       IN  VARCHAR2  ,
      p_from_completion_date IN VARCHAR2  ,
      p_to_completion_date  IN  VARCHAR2  ,
      p_status              IN  VARCHAR2  ,
      p_group_id            IN  NUMBER  ,
      p_select_jobs         IN  NUMBER  ,
      p_exclude_reserved_jobs IN  VARCHAR2  ,
      p_uncompleted_jobs     IN VARCHAR2,
      p_exclude_pending_txn_jobs IN  VARCHAR2  ,
      p_report_type         IN  VARCHAR2 ,
      p_act_close_date      IN  VARCHAR2

);


PROCEDURE EAM_CLOSE_WO
(
   p_submission_date          IN    DATE,
   p_organization_id               IN    NUMBER,
   p_group_id                           IN    NUMBER,
   p_select_jobs                      IN    NUMBER,
   p_report_type                       IN     VARCHAR2,
   x_request_id                        OUT NOCOPY    NUMBER
   );


-- This procedure was added to the spec file for a WIP bug 6718091
PROCEDURE RAISE_WORKFLOW_STATUS_CHANGED
(p_wip_entity_id		        IN   NUMBER,
  p_wip_entity_name			IN   VARCHAR2,
  p_organization_id			IN    NUMBER,
  p_new_status				IN    NUMBER,
  p_old_system_status			IN   NUMBER,
  p_old_wo_status		        IN   NUMBER,
  p_workflow_type                       IN    NUMBER,
  x_return_status                       OUT   NOCOPY VARCHAR2
  );


END EAM_JOBCLOSE_PRIV;

/
