--------------------------------------------------------
--  DDL for Package PA_FP_EXCLUDED_ELEMENTS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_FP_EXCLUDED_ELEMENTS_PUB" AUTHID CURRENT_USER as
 /* $Header: PAFPXEPS.pls 120.1 2005/08/19 16:32:19 mwasowic noship $ */

PROCEDURE  Copy_Excluded_Elements
( p_from_proj_fp_options_id       IN  pa_proj_fp_options.proj_fp_options_id%TYPE
 ,p_from_element_type             IN  pa_fp_elements.element_type%TYPE
 ,p_to_proj_fp_options_id         IN  pa_proj_fp_options.proj_fp_options_id%TYPE
 ,p_to_element_type               IN  pa_fp_elements.element_type%TYPE
 ,x_return_status                 OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,x_msg_count                     OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_msg_data                      OUT NOCOPY VARCHAR2) ; --File.Sql.39 bug 4440895

PROCEDURE Synchronize_Excluded_Elements
   (  p_proj_fp_options_id    IN   pa_proj_fp_options.proj_fp_options_id%TYPE
     ,p_element_type          IN   pa_fp_elements.element_type%TYPE
     ,x_return_status         OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     ,x_msg_count             OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
     ,x_msg_data              OUT  NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

PROCEDURE Delete_Excluded_Elements
     ( p_proj_fp_options_id    IN   pa_fp_excluded_elements.proj_fp_options_id%TYPE
      ,p_element_type          IN   pa_fp_excluded_elements.element_type%TYPE
      ,p_task_id               IN   pa_fp_excluded_elements.task_id%TYPE
      ,x_return_status         OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
      ,x_msg_count             OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
      ,x_msg_data              OUT  NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

 END pa_fp_excluded_elements_pub;

 

/
