--------------------------------------------------------
--  DDL for Package PA_PROGRESS_REPORT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_PROGRESS_REPORT_PUB" AUTHID CURRENT_USER as
/* $Header: PAPRRPPS.pls 120.1 2005/08/19 16:45:11 mwasowic noship $ */



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
  );

PROCEDURE Update_REPORT_REGION
(

 p_api_version                 IN     NUMBER :=  1.0,
 p_init_msg_list               IN     VARCHAR2 := fnd_api.g_true,
 p_commit                      IN     VARCHAR2 := FND_API.g_false,
 p_validate_only               IN     VARCHAR2 := FND_API.g_true,
 p_max_msg_count               IN     NUMBER := FND_API.g_miss_num,

 P_VERSION_ID in NUMBER :=NULL,
 P_REGION_SOURCE_TYPE in VARCHAR2 default 'STD' ,
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
  );

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
 );



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
   p_function_name               IN     VARCHAR2 := NULL,
   x_return_status               OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
   x_msg_count                   OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
   x_msg_data                    OUT    NOCOPY VARCHAR2    --File.Sql.39 bug 4440895
   );

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
   );


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
   );

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
   );

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
 ) ;

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
   );

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
);


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
   );

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
   );

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
			  ) ;

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
			  ) ;

END pa_progress_report_pub;


 

/
