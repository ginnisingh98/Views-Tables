--------------------------------------------------------
--  DDL for Package Body PA_PROGRESS_REPORT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PROGRESS_REPORT_PUB" as
/* $Header: PAPRRPPB.pls 120.1 2005/08/19 16:45:07 mwasowic noship $ */

PROCEDURE Create_REPORT_REGION
(
 p_api_version                 IN     NUMBER :=  1.0,
 p_init_msg_list               IN     VARCHAR2 := fnd_api.g_true,
 p_commit                      IN     VARCHAR2 := FND_API.g_false,
 p_validate_only               IN     VARCHAR2 := FND_API.g_true,
 p_max_msg_count               IN     NUMBER := FND_API.g_miss_num,

 p_version_id                  IN NUMBER := NULL,

 P_REGION_SOURCE_TYPE in VARCHAR2 default 'STD',
 P_REGION_CODE in VARCHAR2 :=NULL,
 P_RECORD_SEQUENCE in NUMBER :=NULL,
 P_ATTRIBUTE1 in VARCHAR2 :=NULL,
 P_ATTRIBUTE2 in VARCHAR2 :=NULL,
 P_ATTRIBUTE3 in VARCHAR2 :=NULL,
 P_ATTRIBUTE4 in VARCHAR2 :=NULL,
 P_ATTRIBUTE5 in VARCHAR2 :=NULL,
 P_ATTRIBUTE6 in VARCHAR2 :=NULL,
 P_ATTRIBUTE7 in VARCHAR2 :=NULL,
 P_ATTRIBUTE8 in VARCHAR2 :=NULL,
 P_ATTRIBUTE9 in VARCHAR2 :=NULL,
 P_ATTRIBUTE10 in VARCHAR2 :=NULL,
 P_ATTRIBUTE11 in VARCHAR2 :=NULL,
 P_ATTRIBUTE12 in VARCHAR2 :=NULL,
 P_ATTRIBUTE13 in VARCHAR2 :=NULL,
 P_ATTRIBUTE14 in VARCHAR2 :=NULL,
 P_ATTRIBUTE15 in VARCHAR2 :=NULL,
 P_ATTRIBUTE16 in VARCHAR2 :=NULL,
 P_ATTRIBUTE17 in VARCHAR2 :=NULL,
 P_ATTRIBUTE18 in VARCHAR2 :=NULL,
 P_ATTRIBUTE19 in VARCHAR2 :=NULL,
 P_ATTRIBUTE20 in VARCHAR2 :=NULL,
 P_UDS_ATTRIBUTE_CATEGORY in VARCHAR2 default null,
 P_UDS_ATTRIBUTE1 in VARCHAR2 default null,
 P_UDS_ATTRIBUTE2 in VARCHAR2 default null,
 P_UDS_ATTRIBUTE3 in VARCHAR2 default null,
 P_UDS_ATTRIBUTE4 in VARCHAR2 default null,
 P_UDS_ATTRIBUTE5 in VARCHAR2 default null,
 P_UDS_ATTRIBUTE6 in VARCHAR2 default null,
 P_UDS_ATTRIBUTE7 in VARCHAR2 default null,
 P_UDS_ATTRIBUTE8 in VARCHAR2 default null,
 P_UDS_ATTRIBUTE9 in VARCHAR2 default null,
 P_UDS_ATTRIBUTE10 in VARCHAR2 default null,
 P_UDS_ATTRIBUTE11 in VARCHAR2 default null,
 P_UDS_ATTRIBUTE12 in VARCHAR2 default null,
 P_UDS_ATTRIBUTE13 in VARCHAR2 default null,
 P_UDS_ATTRIBUTE14 in VARCHAR2 default null,
 P_UDS_ATTRIBUTE15 in VARCHAR2 default null,
 P_UDS_ATTRIBUTE16 in VARCHAR2 default null,
 P_UDS_ATTRIBUTE17 in VARCHAR2 default null,
 P_UDS_ATTRIBUTE18 in VARCHAR2 default null,
 P_UDS_ATTRIBUTE19 in VARCHAR2 default null,
 P_UDS_ATTRIBUTE20 in VARCHAR2 default null,
 x_return_status               OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 x_msg_count                   OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
 x_msg_data                    OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ) IS

   l_msg_index_out        NUMBER;

BEGIN

  -- Initialize the Error Stack
  PA_DEBUG.init_err_stack('PA_PROGRESS_REPORT_PUB.Create_REPORT_REGION');

  -- Initialize the return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --Clear the global PL/SQL message table
  IF FND_API.TO_BOOLEAN( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;
  /** CAll the Create Region only if any of the attribute values is not null.
      Reason, it is creating empty records only with PK values populated  **/
  if ( p_attribute1 is not null OR
       p_attribute2 is not null OR
       p_attribute3 is not null OR
       p_attribute4 is not null OR
       p_attribute5 is not null OR
       p_attribute6 is not null OR
       p_attribute7 is not null OR
       p_attribute8 is not null OR
       p_attribute9 is not null OR
       p_attribute10 is not null OR
       p_attribute11 is not null OR
       p_attribute12 is not null OR
       p_attribute13 is not null OR
       p_attribute14 is not null OR
       p_attribute15 is not null OR
       p_attribute16 is not null OR
       p_attribute17 is not null OR
       p_attribute18 is not null OR
       p_attribute19 is not null OR
       p_attribute20 is not null OR
       p_uds_attribute1 is not null OR
       p_uds_attribute2 is not null OR
       p_uds_attribute3 is not null OR
       p_uds_attribute4 is not null OR
       p_uds_attribute5 is not null OR
       p_uds_attribute6 is not null OR
       p_uds_attribute7 is not null OR
       p_uds_attribute8 is not null OR
       p_uds_attribute9 is not null OR
       p_uds_attribute10 is not null OR
       p_uds_attribute11 is not null OR
       p_uds_attribute12 is not null OR
       p_uds_attribute13 is not null OR
       p_uds_attribute14 is not null OR
       p_uds_attribute15 is not null OR
       p_uds_attribute16 is not null OR
       p_uds_attribute17 is not null OR
       p_uds_attribute18 is not null OR
       p_uds_attribute19 is not null OR
       p_uds_attribute20 is not null ) then
  pa_progress_report_pvt.create_report_region
    (
     p_api_version        ,
     p_init_msg_list      ,
     p_commit             ,
     p_validate_only      ,
     p_max_msg_count      ,

     p_version_id         ,

     P_REGION_SOURCE_TYPE ,
     P_REGION_CODE        ,
     P_RECORD_SEQUENCE    ,
     P_ATTRIBUTE1 ,
     P_ATTRIBUTE2 ,
     P_ATTRIBUTE3 ,
     P_ATTRIBUTE4 ,
     P_ATTRIBUTE5 ,
    P_ATTRIBUTE6 ,
    P_ATTRIBUTE7 ,
    P_ATTRIBUTE8 ,
    P_ATTRIBUTE9 ,
    P_ATTRIBUTE10 ,
    P_ATTRIBUTE11 ,
    P_ATTRIBUTE12 ,
    P_ATTRIBUTE13 ,
    P_ATTRIBUTE14 ,
    P_ATTRIBUTE15 ,
    P_ATTRIBUTE16 ,
    P_ATTRIBUTE17 ,
    P_ATTRIBUTE18 ,
    P_ATTRIBUTE19 ,
    P_ATTRIBUTE20 ,
    P_UDS_ATTRIBUTE_CATEGORY ,
    P_UDS_ATTRIBUTE1 ,
    P_UDS_ATTRIBUTE2 ,
    P_UDS_ATTRIBUTE3 ,
    P_UDS_ATTRIBUTE4 ,
    P_UDS_ATTRIBUTE5 ,
    P_UDS_ATTRIBUTE6 ,
    P_UDS_ATTRIBUTE7 ,
    P_UDS_ATTRIBUTE8 ,
    P_UDS_ATTRIBUTE9 ,
    P_UDS_ATTRIBUTE10 ,
    P_UDS_ATTRIBUTE11 ,
    P_UDS_ATTRIBUTE12 ,
    P_UDS_ATTRIBUTE13 ,
    P_UDS_ATTRIBUTE14 ,
    P_UDS_ATTRIBUTE15 ,
    P_UDS_ATTRIBUTE16 ,
    P_UDS_ATTRIBUTE17 ,
    P_UDS_ATTRIBUTE18 ,
    P_UDS_ATTRIBUTE19 ,
    P_UDS_ATTRIBUTE20 ,
    x_return_status,
    x_msg_count    ,
    x_msg_data

     );
 end if;
--
  -- IF the number of messaages is 1 then fetch the message code from the stack
  -- and return its text
  --

  x_msg_count :=  FND_MSG_PUB.Count_Msg;
  IF x_msg_count = 1 THEN
    pa_interface_utils_pub.get_messages ( p_encoded       => FND_API.G_TRUE
                                         ,p_msg_index     => 1
                                         ,p_data          => x_msg_data
                                         ,p_msg_index_out => l_msg_index_out
                                        );
  END IF;

  -- Reset the error stack when returning to the calling program
  PA_DEBUG.Reset_Err_Stack;


-- Put any message text from message stack into the Message ARRAY
EXCEPTION
   WHEN OTHERS THEN
       rollback;

       -- Set the excetption Message and the stack
       FND_MSG_PUB.add_exc_msg ( p_pkg_name => 'PA_PROGRESS_REPORT_PUB.Create_REPORT_REGION'
                                ,p_procedure_name => PA_DEBUG.G_Err_Stack );
       --
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       RAISE;  -- This is optional depending on the needs

END Create_REPORT_REGION;

PROCEDURE Update_REPORT_REGION
(

 p_api_version                 IN     NUMBER :=  1.0,
 p_init_msg_list               IN     VARCHAR2 := fnd_api.g_true,
 p_commit                      IN     VARCHAR2 := FND_API.g_false,
 p_validate_only               IN     VARCHAR2 := FND_API.g_true,
 p_max_msg_count               IN     NUMBER := FND_API.g_miss_num,

 P_VERSION_ID in NUMBER :=NULL,
 P_REGION_SOURCE_TYPE in VARCHAR2 default 'STD',
 P_REGION_CODE in VARCHAR2 :=NULL,
 P_RECORD_SEQUENCE in NUMBER :=NULL,
 P_RECORD_VERSION_NUMBER in NUMBER :=NULL,
 P_ATTRIBUTE1 in VARCHAR2 :=NULL,
 P_ATTRIBUTE2 in VARCHAR2 :=NULL,
 P_ATTRIBUTE3 in VARCHAR2 :=NULL,
 P_ATTRIBUTE4 in VARCHAR2 :=NULL,
 P_ATTRIBUTE5 in VARCHAR2 :=NULL,
 P_ATTRIBUTE6 in VARCHAR2 :=NULL,
 P_ATTRIBUTE7 in VARCHAR2 :=NULL,
 P_ATTRIBUTE8 in VARCHAR2 :=NULL,
 P_ATTRIBUTE9 in VARCHAR2 :=NULL,
 P_ATTRIBUTE10 in VARCHAR2 :=NULL,
 P_ATTRIBUTE11 in VARCHAR2 :=NULL,
 P_ATTRIBUTE12 in VARCHAR2 :=NULL,
 P_ATTRIBUTE13 in VARCHAR2 :=NULL,
 P_ATTRIBUTE14 in VARCHAR2 :=NULL,
 P_ATTRIBUTE15 in VARCHAR2 :=NULL,
 P_ATTRIBUTE16 in VARCHAR2 :=NULL,
 P_ATTRIBUTE17 in VARCHAR2 :=NULL,
 P_ATTRIBUTE18 in VARCHAR2 :=NULL,
 P_ATTRIBUTE19 in VARCHAR2 :=NULL,
 P_ATTRIBUTE20 in VARCHAR2 :=NULL,
  P_UDS_ATTRIBUTE_CATEGORY in VARCHAR2 := NULL,
  P_UDS_ATTRIBUTE1 in VARCHAR2 := NULL,
  P_UDS_ATTRIBUTE2 in VARCHAR2 := NULL,
  P_UDS_ATTRIBUTE3 in VARCHAR2 := NULL,
  P_UDS_ATTRIBUTE4 in VARCHAR2 := NULL,
  P_UDS_ATTRIBUTE5 in VARCHAR2 := NULL,
  P_UDS_ATTRIBUTE6 in VARCHAR2 := NULL,
  P_UDS_ATTRIBUTE7 in VARCHAR2 := NULL,
  P_UDS_ATTRIBUTE8 in VARCHAR2 := NULL,
  P_UDS_ATTRIBUTE9 in VARCHAR2 := NULL,
  P_UDS_ATTRIBUTE10 in VARCHAR2 := NULL,
  P_UDS_ATTRIBUTE11 in VARCHAR2 := NULL,
  P_UDS_ATTRIBUTE12 in VARCHAR2 := NULL,
  P_UDS_ATTRIBUTE13 in VARCHAR2 := NULL,
  P_UDS_ATTRIBUTE14 in VARCHAR2 := NULL,
  P_UDS_ATTRIBUTE15 in VARCHAR2 := NULL,
  P_UDS_ATTRIBUTE16 in VARCHAR2 := NULL,
  P_UDS_ATTRIBUTE17 in VARCHAR2 := NULL,
  P_UDS_ATTRIBUTE18 in VARCHAR2 := NULL,
  P_UDS_ATTRIBUTE19 in VARCHAR2 := NULL,
  P_UDS_ATTRIBUTE20 in VARCHAR2 := NULL,

 x_return_status               OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 x_msg_count                   OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
 x_msg_data                    OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  )  IS
     l_msg_index_out        NUMBER;
BEGIN

      -- Initialize the Error Stack
  PA_DEBUG.init_err_stack('PA_PROGRESS_REPORT_PUB.Update_REPORT_REGION');

  -- Initialize the return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --Clear the global PL/SQL message table
  IF FND_API.TO_BOOLEAN( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;


  pa_progress_report_pvt.Update_REPORT_REGION
  (
   p_api_version   ,
   p_init_msg_list ,
   p_commit        ,
   p_validate_only ,
   p_max_msg_count   ,

   P_VERSION_ID ,
   P_REGION_SOURCE_TYPE ,
   P_REGION_CODE ,
   p_record_sequence,
   p_record_version_number,
   P_ATTRIBUTE1 ,
   P_ATTRIBUTE2 ,
   P_ATTRIBUTE3 ,
   P_ATTRIBUTE4 ,
   P_ATTRIBUTE5 ,
   P_ATTRIBUTE6 ,
   P_ATTRIBUTE7 ,
   P_ATTRIBUTE8 ,
   P_ATTRIBUTE9 ,
   p_attribute10,
   p_attribute11,
   p_attribute12,
   p_attribute13,
   p_attribute14,
   p_attribute15,
   p_attribute16,
   p_attribute17,
   P_ATTRIBUTE18 ,
   P_ATTRIBUTE19 ,
   P_ATTRIBUTE20 ,
 P_UDS_ATTRIBUTE_CATEGORY ,
  P_UDS_ATTRIBUTE1 ,
  P_UDS_ATTRIBUTE2 ,
  P_UDS_ATTRIBUTE3 ,
  P_UDS_ATTRIBUTE4 ,
  P_UDS_ATTRIBUTE5 ,
  P_UDS_ATTRIBUTE6 ,
  P_UDS_ATTRIBUTE7 ,
  P_UDS_ATTRIBUTE8 ,
  P_UDS_ATTRIBUTE9 ,
  P_UDS_ATTRIBUTE10 ,
  P_UDS_ATTRIBUTE11 ,
  P_UDS_ATTRIBUTE12 ,
  P_UDS_ATTRIBUTE13 ,
  P_UDS_ATTRIBUTE14 ,
  P_UDS_ATTRIBUTE15 ,
  P_UDS_ATTRIBUTE16 ,
  P_UDS_ATTRIBUTE17 ,
  P_UDS_ATTRIBUTE18 ,
  P_UDS_ATTRIBUTE19 ,
  P_UDS_ATTRIBUTE20 ,
   x_return_status   ,
   x_msg_count       ,
   x_msg_data
     );

  --
  -- IF the number of messaages is 1 then fetch the message code from the stack
  -- and return its text
  --

  x_msg_count :=  FND_MSG_PUB.Count_Msg;
  IF x_msg_count = 1 THEN
    pa_interface_utils_pub.get_messages ( p_encoded       => FND_API.G_TRUE
                                         ,p_msg_index     => 1
                                         ,p_data          => x_msg_data
                                         ,p_msg_index_out => l_msg_index_out
                                        );
  END IF;

  -- Reset the error stack when returning to the calling program
  PA_DEBUG.Reset_Err_Stack;


-- Put any message text from message stack into the Message ARRAY
EXCEPTION
   WHEN OTHERS THEN
       rollback;

       -- Set the excetption Message and the stack
       FND_MSG_PUB.add_exc_msg ( p_pkg_name => 'PA_PROGRESS_REPORT_PUB.Update_REPORT_REGION'
                                ,p_procedure_name => PA_DEBUG.G_Err_Stack );
       --
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       RAISE;  -- This is optional depending on the needs
END Update_REPORT_REGION;



PROCEDURE Delete_Report_Region
(
 p_api_version                 IN     NUMBER :=  1.0,
 p_init_msg_list               IN     VARCHAR2 := fnd_api.g_true,
 p_commit                      IN     VARCHAR2 := FND_API.g_false,
 p_validate_only               IN     VARCHAR2 := FND_API.g_true,
 p_max_msg_count               IN     NUMBER := FND_API.g_miss_num,

 p_version_id                  IN     NUMBER := NULL,
 P_REGION_SOURCE_TYPE          in VARCHAR2 := NULL,
 P_REGION_CODE                 in VARCHAR2 := NULL,
 P_RECORD_SEQUENCE             in NUMBER := NULL,
 p_record_version_number       IN NUMBER  := NULL,

 x_return_status               OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 x_msg_count                   OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
 x_msg_data                    OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ) IS
     l_msg_index_out        NUMBER;
BEGIN

      -- Initialize the Error Stack
  PA_DEBUG.init_err_stack('PA_PROGRESS_REPORT_PUB.Delete_Progress_Report');

  -- Initialize the return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --Clear the global PL/SQL message table
  IF FND_API.TO_BOOLEAN( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;


  pa_progress_report_pvt.delete_report_region
  (
   p_api_version   ,
   p_init_msg_list ,
   p_commit        ,
   p_validate_only ,
   p_max_msg_count   ,

   p_version_id         ,
   p_region_source_type      ,
   p_region_code      ,
   p_record_sequence ,
   p_record_version_number,

   x_return_status   ,
   x_msg_count       ,
   x_msg_data
     );

  --
  -- IF the number of messaages is 1 then fetch the message code from the stack
  -- and return its text
  --

  x_msg_count :=  FND_MSG_PUB.Count_Msg;
  IF x_msg_count = 1 THEN
    pa_interface_utils_pub.get_messages ( p_encoded       => FND_API.G_TRUE
                                         ,p_msg_index     => 1
                                         ,p_data          => x_msg_data
                                         ,p_msg_index_out => l_msg_index_out
                                        );
  END IF;

  -- Reset the error stack when returning to the calling program
  PA_DEBUG.Reset_Err_Stack;


-- Put any message text from message stack into the Message ARRAY
EXCEPTION
   WHEN OTHERS THEN
       rollback;

       -- Set the excetption Message and the stack
       FND_MSG_PUB.add_exc_msg ( p_pkg_name => 'PA_PROGRESS_REPORT_PUB.Delete_Progress_Report'
                                ,p_procedure_name => PA_DEBUG.G_Err_Stack );
       --
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       RAISE;  -- This is optional depending on the needs
END Delete_Report_Region;


PROCEDURE define_progress_report_setup
  (
   p_api_version                 IN     NUMBER :=  1.0,
   p_init_msg_list               IN     VARCHAR2 := fnd_api.g_true,
   p_commit                      IN     VARCHAR2 := FND_API.g_false,
   p_validate_only               IN     VARCHAR2 := FND_API.g_true,
   p_max_msg_count               IN     NUMBER := FND_API.g_miss_num,

   p_object_id                   IN     NUMBER := NULL,
   p_object_type                 IN     VARCHAR2 := NULL,
   p_page_type_code              IN     VARCHAR2 := 'PPR',
   p_page_id                     IN     NUMBER := NULL,
   p_page_name                   IN     VARCHAR2 := NULL,
   p_approval_required           IN     VARCHAR2 := NULL,
   --p_auto_publish                IN     VARCHAR2 := NULL,
   p_report_cycle_id             IN     NUMBER := NULL,
   p_report_offset_days          IN     NUMBER := NULL,
   p_next_reporting_date         IN     DATE := NULL,
   p_reminder_days              IN     NUMBER := NULL,
   p_reminder_days_type         IN     VARCHAR2 := NULL,
   p_initial_progress_status 	IN	VARCHAR2 := NULL,
   p_final_progress_status	IN	VARCHAR2 := NULL,
   p_rollup_progress_status	IN	VARCHAR2 := NULL,
   p_report_type_id              IN     NUMBER:= NULL,
   p_approver_source_id          IN     NUMBER:= NULL,
   p_approver_source_name        IN     VARCHAR2:= NULL,
   p_approver_source_type        IN     NUMBER:= NULL,
   p_effective_from              IN     DATE:= NULL,
   p_effective_to                IN     DATE:= NULL,
   p_object_page_layout_id       IN     NUMBER := NULL,
   p_action_set_id               IN     NUMBER := NULL,


   p_record_version_number       IN     NUMBER := NULL,

   p_function_name               IN     VARCHAR2,
   x_return_status               OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
   x_msg_count                   OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
   x_msg_data                    OUT    NOCOPY VARCHAR2    --File.Sql.39 bug 4440895
  ) IS
   l_msg_index_out        NUMBER;
BEGIN

  -- Initialize the Error Stack
  PA_DEBUG.init_err_stack('PA_PROGRESS_REPORT_PUB.define_progress_report_setup');

  -- Initialize the return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --Clear the global PL/SQL message table
  IF FND_API.TO_BOOLEAN( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;


  pa_progress_report_pvt.define_progress_report_setup
  (
   p_api_version   ,
   p_init_msg_list ,
   p_commit        ,
   p_validate_only ,
   p_max_msg_count   ,

   p_object_id                   ,
   p_object_type                 ,
   p_page_type_code              ,
   p_page_id                     ,
   p_page_name,
   p_approval_required           ,
   --p_auto_publish                ,
   p_report_cycle_id             ,
   p_report_offset_days          ,
   p_next_reporting_date         ,
   p_reminder_days              ,
   p_reminder_days_type         ,
   p_initial_progress_status	,
   p_final_progress_status	,
   p_rollup_progress_status	,
   p_report_type_id             ,
   p_approver_source_id         ,
   p_approver_source_name       ,
   p_approver_source_type       ,
   p_effective_from             ,
   p_effective_to               ,
   p_object_page_layout_id,
   p_action_set_id  ,


   p_record_version_number      ,
   p_function_name,
   x_return_status   ,
   x_msg_count       ,
   x_msg_data
     );

  --
  -- IF the number of messaages is 1 then fetch the message code from the stack
  -- and return its text
  --

  x_msg_count :=  FND_MSG_PUB.Count_Msg;
  IF x_msg_count = 1 THEN
    pa_interface_utils_pub.get_messages ( p_encoded       => FND_API.G_TRUE
                                         ,p_msg_index     => 1
                                         ,p_data          => x_msg_data
                                         ,p_msg_index_out => l_msg_index_out
                                        );
  END IF;

  -- Reset the error stack when returning to the calling program
  PA_DEBUG.Reset_Err_Stack;


-- Put any message text from message stack into the Message ARRAY
EXCEPTION
   WHEN OTHERS THEN
       rollback;

       -- Set the excetption Message and the stack
       FND_MSG_PUB.add_exc_msg ( p_pkg_name => 'PA_PROGRESS_REPORT_PUB.define_progress_report_setup'
                                ,p_procedure_name => PA_DEBUG.G_Err_Stack );
       --
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       RAISE;  -- This is optional depending on the needs
END define_progress_report_setup;


PROCEDURE create_report
  (
   p_api_version                 IN     NUMBER :=  1.0,
   p_init_msg_list               IN     VARCHAR2 := fnd_api.g_true,
   p_commit                      IN     VARCHAR2 := FND_API.g_false,
   p_validate_only               IN     VARCHAR2 := FND_API.g_true,
   p_max_msg_count               IN     NUMBER := FND_API.g_miss_num,

   p_object_id                   IN     NUMBER := NULL,
   p_object_type                 IN     VARCHAR2 := NULL,
   p_report_type_id              IN     NUMBER := NULL,

   x_return_status               OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
   x_msg_count                   OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
   x_msg_data                    OUT    NOCOPY VARCHAR2,    --File.Sql.39 bug 4440895
   x_version_id                  OUT    NOCOPY NUMBER --File.Sql.39 bug 4440895
   ) IS
 l_msg_index_out        NUMBER;
BEGIN

  -- Initialize the Error Stack
  PA_DEBUG.init_err_stack('PA_PROGRESS_REPORT_PUB.create_report');

  -- Initialize the return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --Clear the global PL/SQL message table
  IF FND_API.TO_BOOLEAN( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;


  pa_progress_report_pvt.create_report
  (
   p_api_version   ,
   p_init_msg_list ,
   p_commit        ,
   p_validate_only ,
   p_max_msg_count   ,

   p_object_id                   ,
   p_object_type                 ,
   p_report_type_id,

   x_return_status   ,
   x_msg_count       ,
   x_msg_data        ,
   x_version_id
     );

  --
  -- IF the number of messaages is 1 then fetch the message code from the stack
  -- and return its text
  --

  x_msg_count :=  FND_MSG_PUB.Count_Msg;
  IF x_msg_count = 1 THEN
    pa_interface_utils_pub.get_messages ( p_encoded       => FND_API.G_TRUE
                                         ,p_msg_index     => 1
                                         ,p_data          => x_msg_data
                                         ,p_msg_index_out => l_msg_index_out
                                        );
  END IF;

  -- Reset the error stack when returning to the calling program
  PA_DEBUG.Reset_Err_Stack;


-- Put any message text from message stack into the Message ARRAY
EXCEPTION
   WHEN OTHERS THEN
       rollback;

       -- Set the excetption Message and the stack
       FND_MSG_PUB.add_exc_msg ( p_pkg_name => 'PA_PROGRESS_REPORT_PUB.create_report'
                                ,p_procedure_name => PA_DEBUG.G_Err_Stack );
       --
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       RAISE;  -- This is optional depending on the needs

END create_report;


PROCEDURE change_report_status
  (
   p_api_version                 IN     NUMBER :=  1.0,
   p_init_msg_list               IN     VARCHAR2 := fnd_api.g_true,
   p_commit                      IN     VARCHAR2 := FND_API.g_false,
   p_validate_only               IN     VARCHAR2 := FND_API.g_true,
   p_max_msg_count               IN     NUMBER := FND_API.g_miss_num,

   p_version_id                  IN     NUMBER := NULL,
   p_action                      IN     VARCHAR2,
   p_record_version_number       IN     NUMBER := NULL,
   p_summary_version_number       IN     NUMBER := NULL,

   p_cancel_comments             IN     VARCHAR2 := NULL,

   x_return_status               OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
   x_msg_count                   OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
   x_msg_data                    OUT    NOCOPY VARCHAR2    --File.Sql.39 bug 4440895
   ) IS
 l_msg_index_out        NUMBER;
BEGIN

  -- Initialize the Error Stack
  PA_DEBUG.init_err_stack('PA_PROGRESS_REPORT_PUB.change_report_status');

  -- Initialize the return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --Clear the global PL/SQL message table
  IF FND_API.TO_BOOLEAN( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;

  IF (p_action = 'SUBMIT') THEN
     pa_progress_report_pvt.submit_report
       (
	p_api_version   ,
	p_init_msg_list ,
	p_commit        ,
	p_validate_only ,
	p_max_msg_count   ,

	p_version_id                  ,
	p_record_version_number       ,
	p_summary_version_number,

	x_return_status   ,
	x_msg_count       ,
	x_msg_data
	);
   ELSIF (p_action = 'PUBLISH') THEN
     pa_progress_report_pvt.publish_report
       (
	p_api_version   ,
	p_init_msg_list ,
	p_commit        ,
	p_validate_only ,
	p_max_msg_count   ,

	p_version_id                  ,
	p_record_version_number       ,
	p_summary_version_number       ,

	x_return_status   ,
	x_msg_count       ,
	x_msg_data
	);
   ELSIF (p_action = 'REWORK') THEN
     pa_progress_report_pvt.rework_report
       (
	p_api_version   ,
	p_init_msg_list ,
	p_commit        ,
	p_validate_only ,
	p_max_msg_count   ,

	p_version_id                  ,
	p_record_version_number       ,

	x_return_status   ,
	x_msg_count       ,
	x_msg_data
	);
   ELSIF (p_action = 'APPROVE') THEN
     pa_progress_report_pvt.approve_report
       (
	p_api_version   ,
	p_init_msg_list ,
	p_commit        ,
	p_validate_only ,
	p_max_msg_count   ,

	p_version_id                  ,
	p_record_version_number       ,

	x_return_status   ,
	x_msg_count       ,
	x_msg_data
	);
   ELSIF (p_action = 'REJECT') THEN
     pa_progress_report_pvt.reject_report
       (
	p_api_version   ,
	p_init_msg_list ,
	p_commit        ,
	p_validate_only ,
	p_max_msg_count   ,

	p_version_id                  ,
	p_record_version_number       ,

	x_return_status   ,
	x_msg_count       ,
	x_msg_data
	);
   ELSIF (p_action = 'CANCEL') THEN
     pa_progress_report_pvt.cancel_report
       (
	p_api_version   ,
	p_init_msg_list ,
	p_commit        ,
	p_validate_only ,
	p_max_msg_count   ,

	p_version_id                  ,
	p_record_version_number       ,
	p_cancel_comments,

	x_return_status   ,
	x_msg_count       ,
	x_msg_data
	);
  END IF;


  --
  -- IF the number of messaages is 1 then fetch the message code from the stack
  -- and return its text
  --

  x_msg_count :=  FND_MSG_PUB.Count_Msg;
  IF x_msg_count = 1 THEN
    pa_interface_utils_pub.get_messages ( p_encoded       => FND_API.G_TRUE
                                         ,p_msg_index     => 1
                                         ,p_data          => x_msg_data
                                         ,p_msg_index_out => l_msg_index_out
                                        );
  END IF;

  -- Reset the error stack when returning to the calling program
  PA_DEBUG.Reset_Err_Stack;


-- Put any message text from message stack into the Message ARRAY
EXCEPTION
   WHEN OTHERS THEN
       rollback;

       -- Set the excetption Message and the stack
       FND_MSG_PUB.add_exc_msg ( p_pkg_name => 'PA_PROGRESS_REPORT_PUB.change_report_status'
                                ,p_procedure_name => PA_DEBUG.G_Err_Stack );
       --
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       RAISE;  -- This is optional depending on the needs

END change_report_status;

PROCEDURE update_report_details
  (
   p_api_version                 IN     NUMBER :=  1.0,
   p_init_msg_list               IN     VARCHAR2 := fnd_api.g_true,
   p_commit                      IN     VARCHAR2 := FND_API.g_false,
   p_validate_only               IN     VARCHAR2 := FND_API.g_true,
   p_max_msg_count               IN     NUMBER := FND_API.g_miss_num,

   p_version_id                  IN     NUMBER := NULL,

   p_report_start_date           IN     DATE:= NULL,
   p_report_end_date             IN     DATE:= NULL,
   p_reported_by                 IN     NUMBER:= NULL,
   p_reported_by_name            IN     VARCHAR2:= NULL,
   p_progress_status             IN     VARCHAR2:= NULL,
   p_overview                    IN     VARCHAR2:= NULL,
   p_record_version_number       IN     NUMBER := NULL,

   x_return_status               OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
   x_msg_count                   OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
   x_msg_data                    OUT    NOCOPY VARCHAR2    --File.Sql.39 bug 4440895
   ) IS
 l_msg_index_out        NUMBER;
BEGIN

  -- Initialize the Error Stack
  PA_DEBUG.init_err_stack('PA_PROGRESS_REPORT_PUB.update_report_details');

  -- Initialize the return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --Clear the global PL/SQL message table
  IF FND_API.TO_BOOLEAN( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;


  pa_progress_report_pvt.update_report_details
  (
   p_api_version   ,
   p_init_msg_list ,
   p_commit        ,
   p_validate_only ,
   p_max_msg_count   ,

   p_version_id                  ,
   p_report_start_date      ,
   p_report_end_date        ,
   p_reported_by             ,
   p_reported_by_name             ,
   p_progress_status          ,
   p_overview                  ,
   p_record_version_number       ,

   x_return_status   ,
   x_msg_count       ,
   x_msg_data
     );

  --
  -- IF the number of messaages is 1 then fetch the message code from the stack
  -- and return its text
  --

  x_msg_count :=  FND_MSG_PUB.Count_Msg;
  IF x_msg_count = 1 THEN
    pa_interface_utils_pub.get_messages ( p_encoded       => FND_API.G_TRUE
                                         ,p_msg_index     => 1
                                         ,p_data          => x_msg_data
                                         ,p_msg_index_out => l_msg_index_out
                                        );
  END IF;

  -- Reset the error stack when returning to the calling program
  PA_DEBUG.Reset_Err_Stack;


-- Put any message text from message stack into the Message ARRAY
EXCEPTION
   WHEN OTHERS THEN
       rollback;

       -- Set the excetption Message and the stack
       FND_MSG_PUB.add_exc_msg ( p_pkg_name => 'PA_PROGRESS_REPORT_PUB.update_report_details'
                                ,p_procedure_name => PA_DEBUG.G_Err_Stack );
       --
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       RAISE;  -- This is optional depending on the needs

END update_report_details;

PROCEDURE delete_report
  (
   p_api_version                 IN     NUMBER :=  1.0,
   p_init_msg_list               IN     VARCHAR2 := fnd_api.g_true,
   p_commit                      IN     VARCHAR2 := FND_API.g_false,
   p_validate_only               IN     VARCHAR2 := FND_API.g_true,
   p_max_msg_count               IN     NUMBER := FND_API.g_miss_num,

   p_version_id                  IN     NUMBER :=NULL,
   p_record_version_number       IN     NUMBER := NULL,

   x_return_status               OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
   x_msg_count                   OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
   x_msg_data                    OUT    NOCOPY VARCHAR2    --File.Sql.39 bug 4440895
   ) IS

  l_msg_index_out        NUMBER;
BEGIN

  -- Initialize the Error Stack
  PA_DEBUG.init_err_stack('PA_PROGRESS_REPORT_PUB.delete_report');

  -- Initialize the return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --Clear the global PL/SQL message table
  IF FND_API.TO_BOOLEAN( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;


  pa_progress_report_pvt.delete_report
  (
   p_api_version   ,
   p_init_msg_list ,
   p_commit        ,
   p_validate_only ,
   p_max_msg_count   ,

   p_version_id                  ,
   p_record_version_number       ,

   x_return_status   ,
   x_msg_count       ,
   x_msg_data
     );

  --
  -- IF the number of messaages is 1 then fetch the message code from the stack
  -- and return its text
  --

  x_msg_count :=  FND_MSG_PUB.Count_Msg;
  IF x_msg_count = 1 THEN
    pa_interface_utils_pub.get_messages ( p_encoded       => FND_API.G_TRUE
                                         ,p_msg_index     => 1
                                         ,p_data          => x_msg_data
                                         ,p_msg_index_out => l_msg_index_out
                                        );
  END IF;

  -- Reset the error stack when returning to the calling program
  PA_DEBUG.Reset_Err_Stack;


-- Put any message text from message stack into the Message ARRAY
EXCEPTION
   WHEN OTHERS THEN
       rollback;

       -- Set the excetption Message and the stack
       FND_MSG_PUB.add_exc_msg ( p_pkg_name => 'PA_PROGRESS_REPORT_PUB.delete_report'
                                ,p_procedure_name => PA_DEBUG.G_Err_Stack );
       --
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       RAISE;  -- This is optional depending on the needs
END delete_report;



PROCEDURE submit_report
  (
   p_api_version                 IN     NUMBER :=  1.0,
   p_init_msg_list               IN     VARCHAR2 := fnd_api.g_true,
   p_commit                      IN     VARCHAR2 := FND_API.g_false,
   p_validate_only               IN     VARCHAR2 := FND_API.g_true,
   p_max_msg_count               IN     NUMBER := FND_API.g_miss_num,

   p_version_id                  IN     NUMBER := NULL,
   p_record_version_number       IN     NUMBER := NULL,
   p_summary_version_number       IN     NUMBER := NULL,

   x_return_status               OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
   x_msg_count                   OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
   x_msg_data                    OUT    NOCOPY VARCHAR2    --File.Sql.39 bug 4440895
   ) IS
  l_msg_index_out        NUMBER;
BEGIN

  -- Initialize the Error Stack
  PA_DEBUG.init_err_stack('PA_PROGRESS_REPORT_PUB.submit_report');

  -- Initialize the return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --Clear the global PL/SQL message table
  IF FND_API.TO_BOOLEAN( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;


  pa_progress_report_pvt.submit_report
  (
   p_api_version   ,
   p_init_msg_list ,
   p_commit        ,
   p_validate_only ,
   p_max_msg_count   ,

   p_version_id                  ,
   p_record_version_number       ,
   p_summary_version_number      ,
   x_return_status   ,
   x_msg_count       ,
   x_msg_data
     );

  --
  -- IF the number of messaages is 1 then fetch the message code from the stack
  -- and return its text
  --

  x_msg_count :=  FND_MSG_PUB.Count_Msg;
  IF x_msg_count = 1 THEN
    pa_interface_utils_pub.get_messages ( p_encoded       => FND_API.G_TRUE
                                         ,p_msg_index     => 1
                                         ,p_data          => x_msg_data
                                         ,p_msg_index_out => l_msg_index_out
                                        );
  END IF;

  -- Reset the error stack when returning to the calling program
  PA_DEBUG.Reset_Err_Stack;


-- Put any message text from message stack into the Message ARRAY
EXCEPTION
   WHEN OTHERS THEN
       rollback;

       -- Set the excetption Message and the stack
       FND_MSG_PUB.add_exc_msg ( p_pkg_name => 'PA_PROGRESS_REPORT_PUB.submit_report'
                                ,p_procedure_name => PA_DEBUG.G_Err_Stack );
       --
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       RAISE;  -- This is optional depending on the needs
END submit_report;


PROCEDURE cancel_report
(
   p_api_version                 IN     NUMBER :=  1.0,
   p_init_msg_list               IN     VARCHAR2 := fnd_api.g_true,
   p_commit                      IN     VARCHAR2 := FND_API.g_false,
   p_validate_only               IN     VARCHAR2 := FND_API.g_true,
   p_max_msg_count               IN     NUMBER := FND_API.g_miss_num,

   p_version_id                  IN     NUMBER :=NULL,
   p_record_version_number       IN     NUMBER := NULL,
   p_cancel_comments             IN     VARCHAR2 := NULL,

   x_return_status               OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
   x_msg_count                   OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
   x_msg_data                    OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ) IS
    l_msg_index_out        NUMBER;
BEGIN

  -- Initialize the Error Stack
  PA_DEBUG.init_err_stack('PA_PROGRESS_REPORT_PUB.cancel_report');

  -- Initialize the return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --Clear the global PL/SQL message table
  IF FND_API.TO_BOOLEAN( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;


  pa_progress_report_pvt.cancel_report
  (
   p_api_version   ,
   p_init_msg_list ,
   p_commit        ,
   p_validate_only ,
   p_max_msg_count   ,

   p_version_id                  ,
   p_record_version_number       ,
   p_cancel_comments             ,

   x_return_status   ,
   x_msg_count       ,
   x_msg_data
     );

  --
  -- IF the number of messaages is 1 then fetch the message code from the stack
  -- and return its text
  --

  x_msg_count :=  FND_MSG_PUB.Count_Msg;
  IF x_msg_count = 1 THEN
    pa_interface_utils_pub.get_messages ( p_encoded       => FND_API.G_TRUE
                                         ,p_msg_index     => 1
                                         ,p_data          => x_msg_data
                                         ,p_msg_index_out => l_msg_index_out
                                        );
  END IF;

  -- Reset the error stack when returning to the calling program
  PA_DEBUG.Reset_Err_Stack;


-- Put any message text from message stack into the Message ARRAY
EXCEPTION
   WHEN OTHERS THEN
       rollback;

       -- Set the excetption Message and the stack
       FND_MSG_PUB.add_exc_msg ( p_pkg_name => 'PA_PROGRESS_REPORT_PUB.cancel_report'
                                ,p_procedure_name => PA_DEBUG.G_Err_Stack );
       --
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       RAISE;  -- This is optional depending on the needs
END cancel_report;


PROCEDURE rework_report
  (
   p_api_version                 IN     NUMBER :=  1.0,
   p_init_msg_list               IN     VARCHAR2 := fnd_api.g_true,
   p_commit                      IN     VARCHAR2 := FND_API.g_false,
   p_validate_only               IN     VARCHAR2 := FND_API.g_true,
   p_max_msg_count               IN     NUMBER := FND_API.g_miss_num,

   p_version_id                  IN     NUMBER := NULL,
   p_record_version_number       IN     NUMBER := NULL,

   x_return_status               OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
   x_msg_count                   OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
   x_msg_data                    OUT    NOCOPY VARCHAR2    --File.Sql.39 bug 4440895
   ) IS
   l_msg_index_out        NUMBER;
BEGIN

  -- Initialize the Error Stack
  PA_DEBUG.init_err_stack('PA_PROGRESS_REPORT_PUB.rework_report');

  -- Initialize the return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --Clear the global PL/SQL message table
  IF FND_API.TO_BOOLEAN( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;


  pa_progress_report_pvt.rework_report
  (
   p_api_version   ,
   p_init_msg_list ,
   p_commit        ,
   p_validate_only ,
   p_max_msg_count   ,

   p_version_id                  ,
   p_record_version_number       ,

   x_return_status   ,
   x_msg_count       ,
   x_msg_data
     );

  --
  -- IF the number of messaages is 1 then fetch the message code from the stack
  -- and return its text
  --

  x_msg_count :=  FND_MSG_PUB.Count_Msg;
  IF x_msg_count = 1 THEN
    pa_interface_utils_pub.get_messages ( p_encoded       => FND_API.G_TRUE
                                         ,p_msg_index     => 1
                                         ,p_data          => x_msg_data
                                         ,p_msg_index_out => l_msg_index_out
                                        );
  END IF;

  -- Reset the error stack when returning to the calling program
  PA_DEBUG.Reset_Err_Stack;


-- Put any message text from message stack into the Message ARRAY
EXCEPTION
   WHEN OTHERS THEN
       rollback;

       -- Set the excetption Message and the stack
       FND_MSG_PUB.add_exc_msg ( p_pkg_name => 'PA_PROGRESS_REPORT_PUB.rework_report'
                                ,p_procedure_name => PA_DEBUG.G_Err_Stack );
       --
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       RAISE;  -- This is optional depending on the needs
END rework_report;


PROCEDURE publish_report (
 p_api_version                 IN     NUMBER :=  1.0,
 p_init_msg_list               IN     VARCHAR2 := fnd_api.g_true,
 p_commit                      IN     VARCHAR2 := FND_API.g_false,
 p_validate_only               IN     VARCHAR2 := FND_API.g_true,
 p_max_msg_count               IN     NUMBER := FND_API.g_miss_num,

  p_version_id IN NUMBER := null,
			  p_record_version_number       IN     NUMBER := NULL,
			  p_summary_version_number       IN     NUMBER := NULL,

  x_return_status               OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  x_msg_count                   OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
  x_msg_data                    OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
			  ) IS
   l_msg_index_out        NUMBER;
BEGIN

  -- Initialize the Error Stack
  PA_DEBUG.init_err_stack('PA_PROGRESS_REPORT_PUB.publish_report');

  -- Initialize the return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --Clear the global PL/SQL message table
  IF FND_API.TO_BOOLEAN( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;


  pa_progress_report_pvt.publish_report
  (
   p_api_version   ,
   p_init_msg_list ,
   p_commit        ,
   p_validate_only ,
   p_max_msg_count   ,

   p_version_id                  ,
   p_record_version_number       ,
   p_summary_version_number       ,

   x_return_status   ,
   x_msg_count       ,
   x_msg_data
     );

  --
  -- IF the number of messaages is 1 then fetch the message code from the stack
  -- and return its text
  --

  x_msg_count :=  FND_MSG_PUB.Count_Msg;
  IF x_msg_count = 1 THEN
    pa_interface_utils_pub.get_messages ( p_encoded       => FND_API.G_TRUE
                                         ,p_msg_index     => 1
                                         ,p_data          => x_msg_data
                                         ,p_msg_index_out => l_msg_index_out
                                        );
  END IF;

  -- Reset the error stack when returning to the calling program
  PA_DEBUG.Reset_Err_Stack;


-- Put any message text from message stack into the Message ARRAY
EXCEPTION
   WHEN OTHERS THEN
       rollback;

       -- Set the excetption Message and the stack
       FND_MSG_PUB.add_exc_msg ( p_pkg_name => 'PA_PROGRESS_REPORT_PUB.publish_report'
                                ,p_procedure_name => PA_DEBUG.G_Err_Stack );
       --
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       RAISE;  -- This is optional depending on the needs
END publish_report;

PROCEDURE approve_report (
 p_api_version                 IN     NUMBER :=  1.0,
 p_init_msg_list               IN     VARCHAR2 := fnd_api.g_true,
 p_commit                      IN     VARCHAR2 := FND_API.g_false,
 p_validate_only               IN     VARCHAR2 := FND_API.g_true,
 p_max_msg_count               IN     NUMBER := FND_API.g_miss_num,

  p_version_id IN NUMBER := null,
  p_record_version_number       IN     NUMBER := NULL,

  x_return_status               OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  x_msg_count                   OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
  x_msg_data                    OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
			  ) IS
   l_msg_index_out        NUMBER;
BEGIN

  -- Initialize the Error Stack
  PA_DEBUG.init_err_stack('PA_PROGRESS_REPORT_PUB.approve_report');

  -- Initialize the return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --Clear the global PL/SQL message table
  IF FND_API.TO_BOOLEAN( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;


  pa_progress_report_pvt.approve_report
  (
   p_api_version   ,
   p_init_msg_list ,
   p_commit        ,
   p_validate_only ,
   p_max_msg_count   ,

   p_version_id                  ,
   p_record_version_number       ,

   x_return_status   ,
   x_msg_count       ,
   x_msg_data
     );

  --
  -- IF the number of messaages is 1 then fetch the message code from the stack
  -- and return its text
  --

  x_msg_count :=  FND_MSG_PUB.Count_Msg;
  IF x_msg_count = 1 THEN
    pa_interface_utils_pub.get_messages ( p_encoded       => FND_API.G_TRUE
                                         ,p_msg_index     => 1
                                         ,p_data          => x_msg_data
                                         ,p_msg_index_out => l_msg_index_out
                                        );
  END IF;

  -- Reset the error stack when returning to the calling program
  PA_DEBUG.Reset_Err_Stack;


-- Put any message text from message stack into the Message ARRAY
EXCEPTION
   WHEN OTHERS THEN
       rollback;

       -- Set the excetption Message and the stack
       FND_MSG_PUB.add_exc_msg ( p_pkg_name => 'PA_PROGRESS_REPORT_PUB.approve_report'
                                ,p_procedure_name => PA_DEBUG.G_Err_Stack );
       --
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       RAISE;  -- This is optional depending on the needs
END approve_report;


PROCEDURE reject_report (
 p_api_version                 IN     NUMBER :=  1.0,
 p_init_msg_list               IN     VARCHAR2 := fnd_api.g_true,
 p_commit                      IN     VARCHAR2 := FND_API.g_false,
 p_validate_only               IN     VARCHAR2 := FND_API.g_true,
 p_max_msg_count               IN     NUMBER := FND_API.g_miss_num,

  p_version_id IN NUMBER := null,
  p_record_version_number       IN     NUMBER := NULL,

  x_return_status               OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  x_msg_count                   OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
  x_msg_data                    OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
			  ) IS
   l_msg_index_out        NUMBER;
BEGIN

  -- Initialize the Error Stack
  PA_DEBUG.init_err_stack('PA_PROGRESS_REPORT_PUB.reject_report');

  -- Initialize the return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --Clear the global PL/SQL message table
  IF FND_API.TO_BOOLEAN( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;


  pa_progress_report_pvt.reject_report
  (
   p_api_version   ,
   p_init_msg_list ,
   p_commit        ,
   p_validate_only ,
   p_max_msg_count   ,

   p_version_id                  ,
   p_record_version_number       ,

   x_return_status   ,
   x_msg_count       ,
   x_msg_data
     );

  --
  -- IF the number of messaages is 1 then fetch the message code from the stack
  -- and return its text
  --

  x_msg_count :=  FND_MSG_PUB.Count_Msg;
  IF x_msg_count = 1 THEN
    pa_interface_utils_pub.get_messages ( p_encoded       => FND_API.G_TRUE
                                         ,p_msg_index     => 1
                                         ,p_data          => x_msg_data
                                         ,p_msg_index_out => l_msg_index_out
                                        );
  END IF;

  -- Reset the error stack when returning to the calling program
  PA_DEBUG.Reset_Err_Stack;


-- Put any message text from message stack into the Message ARRAY
EXCEPTION
   WHEN OTHERS THEN
       rollback;

       -- Set the excetption Message and the stack
       FND_MSG_PUB.add_exc_msg ( p_pkg_name => 'PA_PROGRESS_REPORT_PUB.reject_report'
                                ,p_procedure_name => PA_DEBUG.G_Err_Stack );
       --
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       RAISE;  -- This is optional depending on the needs
END reject_report;


END pa_progress_report_pub;


/
