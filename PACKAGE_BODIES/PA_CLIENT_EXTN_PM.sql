--------------------------------------------------------
--  DDL for Package Body PA_CLIENT_EXTN_PM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_CLIENT_EXTN_PM" as
/* $Header: PAPMGCEB.pls 120.2 2005/08/23 22:32:26 avaithia noship $ */

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
  p_early_start_date         IN  DATE   := NULL,
  p_early_finish_date        IN  DATE   := NULL,
  p_late_start_date          IN  DATE   := NULL,
  p_late_finish_date         IN  DATE   := NULL,
  p_scheduled_start_date     IN  DATE   := NULL,
  p_scheduled_finish_date    IN  DATE   := NULL,
  p_out_start_date          OUT  NOCOPY DATE , --File.Sql.39 bug 4440895
  p_out_completion_date     OUT  NOCOPY DATE, --File.Sql.39 bug 4440895
  p_error_code	            OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
  p_error_message           OUT  NOCOPY VARCHAR2) --File.Sql.39 bug 4440895

IS

BEGIN
     p_error_code := 0;
     p_error_message := NULL;
     p_out_start_date := p_in_start_date;
     p_out_completion_date := p_in_completion_date;
EXCEPTION
    WHEN OTHERS THEN
         p_error_code := -1;

END customize_dates;

end PA_Client_Extn_PM;

/
