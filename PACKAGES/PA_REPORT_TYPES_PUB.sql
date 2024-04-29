--------------------------------------------------------
--  DDL for Package PA_REPORT_TYPES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_REPORT_TYPES_PUB" AUTHID CURRENT_USER as
/* $Header: PARTYPPS.pls 120.1 2005/08/19 17:02:35 mwasowic noship $ */

PROCEDURE CREATE_REPORT_TYPE
(
 p_api_version                 IN NUMBER :=  1.0,
 p_init_msg_list               IN VARCHAR2 := 'T',
 p_commit                      IN VARCHAR2 := 'F',
 p_validate_only               IN VARCHAR2 := 'F',
 p_max_msg_count               IN NUMBER := 100,
 P_NAME                        IN VARCHAR2,
 P_PAGE_ID                     IN NUMBER,
 P_PAGE_LAYOUT                 IN VARCHAR2 := '^',
 P_OVERRIDE_PAGE_LAYOUT        IN VARCHAR2 := 'N',
 P_DESCRIPTION                 IN VARCHAR2 := '',
 P_GENERATION_METHOD           IN VARCHAR2 :='',
 P_START_DATE_ACTIVE           IN DATE := trunc(sysdate),
 P_END_DATE_ACTIVE             IN DATE := to_date(null),

 x_report_type_id              OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
 x_return_status               OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 x_msg_count                   OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
 x_msg_data                    OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   );


PROCEDURE Update_Report_Type
(
 p_api_version                 IN     NUMBER :=  1.0,
 p_init_msg_list               IN     VARCHAR2 := 'T',
 p_commit                      IN     VARCHAR2 := 'F',
 p_validate_only               IN     VARCHAR2 := 'T',
 p_max_msg_count               IN     NUMBER := 100,
 P_REPORT_TYPE_ID              IN NUMBER,
 P_NAME                        IN VARCHAR2 := '^',
 P_PAGE_ID                     IN NUMBER   := -99,
 P_PAGE_LAYOUT                 IN VARCHAR2 := '^',
 P_OVERRIDE_PAGE_LAYOUT        IN VARCHAR2 := '^',
 P_DESCRIPTION                 IN VARCHAR2 := '^',
 P_GENERATION_METHOD           IN VARCHAR2 :='',
 P_START_DATE_ACTIVE           IN DATE     := to_date('01/01/4712','DD/MM/YYYY'),
 P_END_DATE_ACTIVE             IN DATE     := to_date('01/01/4712','DD/MM/YYYY'),
 P_RECORD_VERSION_NUMBER       IN NUMBER,

 x_return_status               OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 x_msg_count                   OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
 x_msg_data                    OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  );

PROCEDURE Delete_Report_Type
(
 p_api_version                 IN     NUMBER :=  1.0,
 p_init_msg_list               IN     VARCHAR2 := 'T',
 p_commit                      IN     VARCHAR2 := 'F',
 p_validate_only               IN     VARCHAR2 := 'T',
 p_max_msg_count               IN     NUMBER := 100,

 p_report_type_id              IN NUMBER,
 p_record_version_number       IN NUMBER ,

 x_return_status               OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 x_msg_count                   OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
 x_msg_data                    OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 );

END  PA_REPORT_TYPES_PUB;


 

/
