--------------------------------------------------------
--  DDL for Package PA_PROGRESS_REPORT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_PROGRESS_REPORT_PKG" AUTHID CURRENT_USER AS
--$Header: PAPRRPHS.pls 120.1 2005/08/19 16:45:03 mwasowic noship $
procedure INSERT_PROGRESS_REPORT_VER_ROW (

  P_OBJECT_ID in NUMBER,
  P_OBJECT_TYPE in VARCHAR2,
  P_PAGE_ID in NUMBER,
  P_PAGE_TYPE in VARCHAR2,
  P_PAGE_STATUS in VARCHAR2,

    p_report_start_date IN DATE,
    p_report_end_date IN DATE,
    p_reported_by in NUMBER,
    p_progress_status in VARCHAR2,
    p_overview in VARCHAR2,
    p_current_flag in VARCHAR2,
    p_published_date IN DATE,
    p_comments in VARCHAR2,
    p_canceled_date IN DATE,

  p_report_type_id              IN NUMBER,
  X_VERSION_ID                  out NOCOPY NUMBER, --File.Sql.39 bug 4440895
  x_return_status               OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  x_msg_count                   OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
  x_msg_data                    OUT    NOCOPY VARCHAR2			    --File.Sql.39 bug 4440895
);

procedure UPDATE_PROGRESS_REPORT_VER_ROW (
  P_VERSION_ID in NUMBER,
  P_OBJECT_ID in NUMBER,
  P_OBJECT_TYPE in VARCHAR2,
  P_PAGE_ID in NUMBER,
  P_PAGE_TYPE in VARCHAR2,
  P_PAGE_STATUS in VARCHAR2,

    p_report_start_date IN DATE,
    p_report_end_date IN DATE,
    p_reported_by in NUMBER,
    p_progress_status in VARCHAR2,
    p_overview in VARCHAR2,
    p_current_flag in VARCHAR2,
    p_published_date IN DATE,
    p_comments in VARCHAR2,
    p_canceled_date IN DATE,

  P_RECORD_VERSION_NUMBER in NUMBER,
  P_summary_VERSION_NUMBER in NUMBER,
  p_report_type_id              IN NUMBER,

  x_return_status               OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  x_msg_count                   OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
  x_msg_data                    OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);

procedure DELETE_PROGRESS_REPORT_VER_ROW (
  P_VERSION_ID in NUMBER,
  P_RECORD_VERSION_NUMBER in NUMBER,

  x_return_status               OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  x_msg_count                   OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
  x_msg_data                    OUT    NOCOPY VARCHAR2	       --File.Sql.39 bug 4440895
) ;

procedure INSERT_PROGRESS_REPORT_VAL_ROW (
  P_VERSION_ID in NUMBER,
  P_REGION_SOURCE_TYPE in VARCHAR2,
  P_REGION_CODE in VARCHAR2,
  P_RECORD_SEQUENCE in NUMBER,
  P_ATTRIBUTE1 in VARCHAR2,
  P_ATTRIBUTE2 in VARCHAR2,
  P_ATTRIBUTE3 in VARCHAR2,
  P_ATTRIBUTE4 in VARCHAR2,
  P_ATTRIBUTE5 in VARCHAR2,
  P_ATTRIBUTE6 in VARCHAR2,
  P_ATTRIBUTE7 in VARCHAR2,
  P_ATTRIBUTE8 in VARCHAR2,
  P_ATTRIBUTE9 in VARCHAR2,
  P_ATTRIBUTE10 in VARCHAR2,
  P_ATTRIBUTE11 in VARCHAR2,
  P_ATTRIBUTE12 in VARCHAR2,
  P_ATTRIBUTE13 in VARCHAR2,
  P_ATTRIBUTE14 in VARCHAR2,
  P_ATTRIBUTE15 in VARCHAR2,
  P_ATTRIBUTE16 in VARCHAR2,
  P_ATTRIBUTE17 in VARCHAR2,
  P_ATTRIBUTE18 in VARCHAR2,
  P_ATTRIBUTE19 in VARCHAR2,
  P_ATTRIBUTE20 in VARCHAR2,
  P_UDS_ATTRIBUTE_CATEGORY in VARCHAR2,
  P_UDS_ATTRIBUTE1 in VARCHAR2,
  P_UDS_ATTRIBUTE2 in VARCHAR2,
  P_UDS_ATTRIBUTE3 in VARCHAR2,
  P_UDS_ATTRIBUTE4 in VARCHAR2,
  P_UDS_ATTRIBUTE5 in VARCHAR2,
  P_UDS_ATTRIBUTE6 in VARCHAR2,
  P_UDS_ATTRIBUTE7 in VARCHAR2,
  P_UDS_ATTRIBUTE8 in VARCHAR2,
  P_UDS_ATTRIBUTE9 in VARCHAR2,
  P_UDS_ATTRIBUTE10 in VARCHAR2,
  P_UDS_ATTRIBUTE11 in VARCHAR2,
  P_UDS_ATTRIBUTE12 in VARCHAR2,
  P_UDS_ATTRIBUTE13 in VARCHAR2,
  P_UDS_ATTRIBUTE14 in VARCHAR2,
  P_UDS_ATTRIBUTE15 in VARCHAR2,
  P_UDS_ATTRIBUTE16 in VARCHAR2,
  P_UDS_ATTRIBUTE17 in VARCHAR2,
  P_UDS_ATTRIBUTE18 in VARCHAR2,
  P_UDS_ATTRIBUTE19 in VARCHAR2,
  P_UDS_ATTRIBUTE20 in VARCHAR2,
  x_return_status               OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  x_msg_count                   OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
  x_msg_data                    OUT    NOCOPY VARCHAR2				      --File.Sql.39 bug 4440895
);

procedure UPDATE_PROGRESS_REPORT_VAL_ROW (
  P_VERSION_ID in NUMBER,
  P_REGION_SOURCE_TYPE in VARCHAR2,
  P_REGION_CODE in VARCHAR2,
  P_RECORD_SEQUENCE in NUMBER,
  P_RECORD_VERSION_NUMBER in NUMBER,
  P_ATTRIBUTE1 in VARCHAR2,
  P_ATTRIBUTE2 in VARCHAR2,
  P_ATTRIBUTE3 in VARCHAR2,
  P_ATTRIBUTE4 in VARCHAR2,
  P_ATTRIBUTE5 in VARCHAR2,
  P_ATTRIBUTE6 in VARCHAR2,
  P_ATTRIBUTE7 in VARCHAR2,
  P_ATTRIBUTE8 in VARCHAR2,
  P_ATTRIBUTE9 in VARCHAR2,
  P_ATTRIBUTE10 in VARCHAR2,
  P_ATTRIBUTE11 in VARCHAR2,
  P_ATTRIBUTE12 in VARCHAR2,
  P_ATTRIBUTE13 in VARCHAR2,
  P_ATTRIBUTE14 in VARCHAR2,
  P_ATTRIBUTE15 in VARCHAR2,
  P_ATTRIBUTE16 in VARCHAR2,
  P_ATTRIBUTE17 in VARCHAR2,
  P_ATTRIBUTE18 in VARCHAR2,
  P_ATTRIBUTE19 in VARCHAR2,
  P_ATTRIBUTE20 in VARCHAR2,
  P_UDS_ATTRIBUTE_CATEGORY in VARCHAR2,
  P_UDS_ATTRIBUTE1 in VARCHAR2,
  P_UDS_ATTRIBUTE2 in VARCHAR2,
  P_UDS_ATTRIBUTE3 in VARCHAR2,
  P_UDS_ATTRIBUTE4 in VARCHAR2,
  P_UDS_ATTRIBUTE5 in VARCHAR2,
  P_UDS_ATTRIBUTE6 in VARCHAR2,
  P_UDS_ATTRIBUTE7 in VARCHAR2,
  P_UDS_ATTRIBUTE8 in VARCHAR2,
  P_UDS_ATTRIBUTE9 in VARCHAR2,
  P_UDS_ATTRIBUTE10 in VARCHAR2,
  P_UDS_ATTRIBUTE11 in VARCHAR2,
  P_UDS_ATTRIBUTE12 in VARCHAR2,
  P_UDS_ATTRIBUTE13 in VARCHAR2,
  P_UDS_ATTRIBUTE14 in VARCHAR2,
  P_UDS_ATTRIBUTE15 in VARCHAR2,
  P_UDS_ATTRIBUTE16 in VARCHAR2,
  P_UDS_ATTRIBUTE17 in VARCHAR2,
  P_UDS_ATTRIBUTE18 in VARCHAR2,
  P_UDS_ATTRIBUTE19 in VARCHAR2,
  P_UDS_ATTRIBUTE20 in VARCHAR2,

  x_return_status               OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  x_msg_count                   OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
  x_msg_data                    OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);

procedure DELETE_PROGRESS_REPORT_VAL_ROW (
  P_VERSION_ID in NUMBER,
  P_REGION_SOURCE_TYPE in VARCHAR2,
  P_REGION_CODE in VARCHAR2,
  P_RECORD_SEQUENCE in NUMBER,
  P_RECORD_VERSION_NUMBER in NUMBER,

  x_return_status               OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  x_msg_count                   OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
  x_msg_data                    OUT    NOCOPY VARCHAR2			      --File.Sql.39 bug 4440895
);

procedure INSERT_OBJECT_PAGE_LAYOUT_ROW (

  P_OBJECT_ID in NUMBER,
  P_OBJECT_TYPE in VARCHAR2,
  P_PAGE_ID in NUMBER,
  P_PAGE_TYPE_CODE in VARCHAR2,

  P_APPROVAL_REQUIRED in VARCHAR2,
  --P_AUTO_PUBLISH in VARCHAR2,
  P_REPORTING_CYCLE_ID in NUMBER,
  P_REPORTING_OFFSET_DAYS in NUMBER,
  P_NEXT_REPORTING_DATE in DATE,
  P_REMINDER_DAYS in NUMBER,
  P_REMINDER_DAYS_TYPE in VARCHAR2,
  P_INITIAL_PROGRESS_STATUS in VARCHAR2,
  P_FINAL_PROGRESS_STATUS in VARCHAR2,
  P_ROLLUP_PROGRESS_STATUS in VARCHAR2,
  p_report_type_id              IN     NUMBER,
  p_approver_source_id          IN     NUMBER,
  p_approver_source_type        IN     NUMBER,
  p_effective_from              IN     DATE,
  p_effective_to                IN     DATE,
  p_function_name		IN     VARCHAR2 := NULL,
  x_object_page_layout_id       OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
  x_return_status               OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  x_msg_count                   OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
  x_msg_data                    OUT    NOCOPY VARCHAR2			    --File.Sql.39 bug 4440895
);

procedure UPDATE_OBJECT_PAGE_LAYOUT_ROW (
  P_OBJECT_ID in NUMBER,
  P_OBJECT_TYPE in VARCHAR2,
  P_PAGE_ID in NUMBER,
  P_PAGE_TYPE_CODE in VARCHAR2,

  P_APPROVAL_REQUIRED in VARCHAR2,
  --P_AUTO_PUBLISH in VARCHAR2,
  P_REPORTING_CYCLE_ID in NUMBER,
  P_REPORTING_OFFSET_DAYS in NUMBER,
  P_NEXT_REPORTING_DATE in DATE,
  P_REMINDER_DAYS in NUMBER,
  P_REMINDER_DAYS_TYPE in VARCHAR2,
  P_INITIAL_PROGRESS_STATUS in VARCHAR2,
  P_FINAL_PROGRESS_STATUS in VARCHAR2,
  P_ROLLUP_PROGRESS_STATUS in VARCHAR2,
  p_report_type_id              IN     NUMBER,
  p_approver_source_id          IN     NUMBER,
  p_approver_source_type        IN     NUMBER,
  p_effective_from              IN     DATE,
  p_effective_to                IN     DATE,
  p_object_page_layout_id       IN     NUMBER,
  p_record_version_number	IN     NUMBER,
  p_function_name		IN     VARCHAR2 := NULL,

  x_return_status               OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  x_msg_count                   OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
  x_msg_data                    OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
) ;

procedure DELETE_PROGRESS_REPORT_VALS (
  P_VERSION_ID in NUMBER,

  x_return_status               OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  x_msg_count                   OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
  x_msg_data                    OUT    NOCOPY VARCHAR2			      --File.Sql.39 bug 4440895
				       ) ;


procedure DELETE_PROGRESS_REPORT_REGION (
  P_VERSION_ID in NUMBER,
  p_region_source_type in VARCHAR2,
  p_region_code IN VARCHAR2,

  x_return_status               OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  x_msg_count                   OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
  x_msg_data                    OUT    NOCOPY VARCHAR2			      --File.Sql.39 bug 4440895
					 ) ;

procedure DELETE_OBJECT_PAGE_LAYOUTS (
  P_OBJECT_ID in NUMBER,
  P_OBJECT_TYPE in VARCHAR2,

  x_return_status               OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  x_msg_count                   OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
  x_msg_data                    OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
				      ) ;


END  PA_PROGRESS_REPORT_PKG;

 

/
