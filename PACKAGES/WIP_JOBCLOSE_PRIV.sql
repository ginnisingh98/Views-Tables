--------------------------------------------------------
--  DDL for Package WIP_JOBCLOSE_PRIV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WIP_JOBCLOSE_PRIV" AUTHID CURRENT_USER AS
/* $Header: wipjclps.pls 120.0.12010000.1 2008/07/24 05:23:01 appldev ship $ */

/*************************************************************************
 *
 *			 procedure WIP_CLOSE_MGR
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


procedure WIP_CLOSE_MGR
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


/***************************************************************************
 *
 *			 procedure WIP_CLOSE
 *
 ***************************************************************************
 * This procedure is the new close job processor. This procedure is equivalent
 * to wicdcl.ppc. This procedure will be used to create an executable file that
 * will be called from Close Manager.
 *
 * PARAMETER:
 *
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

procedure WIP_CLOSE
(
      p_organization_id     IN  NUMBER    ,
      p_class_type          IN  VARCHAR2  ,
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
      p_uncompleted_jobs    IN VARCHAR2,
      p_exclude_pending_txn_jobs IN  VARCHAR2  ,
      p_report_type         IN  VARCHAR2 ,
      p_act_close_date      IN  VARCHAR2 ,
      x_warning             OUT NOCOPY NUMBER ,
      x_returnStatus	    OUT NOCOPY VARCHAR2
);

END wip_jobclose_priv;

/
