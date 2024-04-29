--------------------------------------------------------
--  DDL for Package PA_CLIENT_EXTN_PM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_CLIENT_EXTN_PM" AUTHID CURRENT_USER as
/* $Header: PAPMGCES.pls 120.3 2006/07/24 11:52:52 dthakker noship $ */
/*#
 * This extension is used to substitute dates used by external systems for the standard Oracle Projects
 * project and task start and completion dates.
 * @rep:scope public
 * @rep:product PA
 * @rep:lifecycle active
 * @rep:displayname Project and Task Date Extension
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY PA_PROJECT
 * @rep:category BUSINESS_ENTITY PA_TASK
 * @rep:doccd 120pjapi.pdf See the Oracle Projects API's, Client Extensions, and Open Interfaces Reference
*/

/*#
 * This procedure is used to map a different set of dates for the project/ and task start dates.
 * @param p_pm_project_reference The rerference code that uniquely identifies the project in the external system
 * @param p_pm_task_reference The rerference code that uniquely identifies the task in the external system
 * @param p_project_id The rerference code that uniquely identifies the project in Oracle Projects
 * @param p_task_id The rerference code that uniquely identifies the task in Oracle Projects
 * @param p_pm_product_code The product code of the external system
 * @rep:paraminfo {@rep:required}
 * @param p_in_start_date The default start date
 * @rep:paraminfo {@rep:required}
 * @param p_in_completion_date The default completion date
 * @rep:paraminfo {@rep:required}
 * @param p_actual_start_date The actual start date
 * @param p_actual_finish_date The actual finish date
 * @param p_early_start_date The early start date
 * @param p_early_finish_date The early finish date
 * @param p_late_start_date The late start date
 * @param p_late_finish_date The late finish date
 * @param p_scheduled_start_date The scheduled start date
 * @param p_scheduled_finish_date The scheduled finish date
 * @param p_out_start_date The output start date
 * @rep:paraminfo {@rep:required}
 * @param p_out_completion_date The output completion date
 * @rep:paraminfo {@rep:required}
 * @param p_error_code API standard: error code
 * @rep:paraminfo {@rep:required}
 * @param p_error_message API standard: error message
 * @rep:paraminfo {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Customize Dates
 * @rep:compatibility S
*/
Procedure customize_dates (
  p_pm_project_reference     IN  VARCHAR2  := NULL,
  p_pm_task_reference        IN  VARCHAR2  := NULL,
  p_project_id               IN  NUMBER := NULL,
  p_task_id                  IN  NUMBER := NULL,
  p_pm_product_code          IN  VARCHAR2,
  p_in_start_date            IN  DATE,
  p_in_completion_date       IN  DATE,
  p_actual_start_date        IN  DATE   := NULL,
  p_actual_finish_date       IN  DATE   := NULL,
  p_early_start_date         IN DATE   := NULL,
  p_early_finish_date        IN DATE   := NULL,
  p_late_start_date          IN DATE   := NULL,
  p_late_finish_date         IN DATE   := NULL,
  p_scheduled_start_date     IN DATE   := NULL,
  p_scheduled_finish_date    IN DATE   := NULL,
  p_out_start_date          OUT NOCOPY DATE , --File.Sql.39 bug 4440895
  p_out_completion_date     OUT NOCOPY DATE , --File.Sql.39 bug 4440895
  p_error_code              OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
  p_error_message           OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895


end PA_Client_Extn_PM;

 

/
