--------------------------------------------------------
--  DDL for Package HZ_EMPLOYMENT_HISTORY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_EMPLOYMENT_HISTORY_PKG" AUTHID CURRENT_USER as
/* $Header: ARHEHITS.pls 115.7 2003/04/11 15:48:33 pchinnan ship $ */


PROCEDURE Insert_Row(
                  x_EMPLOYMENT_HISTORY_ID       IN  OUT NOCOPY   NUMBER,
                  x_BEGIN_DATE                  IN      DATE,
                  x_PARTY_ID                    IN      NUMBER,
                  x_EMPLOYED_AS_TITLE           IN      VARCHAR2,
                  x_EMPLOYED_BY_DIVISION_NAME   IN      VARCHAR2,
                  x_EMPLOYED_BY_NAME_COMPANY    IN      VARCHAR2,
                  x_END_DATE                    IN      DATE,
                  x_SUPERVISOR_NAME             IN      VARCHAR2,
                  x_BRANCH                      IN      VARCHAR2,
                  x_MILITARY_RANK               IN      VARCHAR2,
                  x_SERVED                      IN      VARCHAR2,
                  x_STATION                     IN      VARCHAR2,
                  x_RESPONSIBILITY              IN      VARCHAR2,
                  x_STATUS                      IN      VARCHAR2,
    		  x_OBJECT_VERSION_NUMBER       IN      NUMBER,
    		  x_CREATED_BY_MODULE           IN      VARCHAR2,
    		  x_APPLICATION_ID              IN      NUMBER,
    		  x_EMPLOYED_BY_PARTY_ID        IN      NUMBER,
    		  x_REASON_FOR_LEAVING          IN      VARCHAR2,
    		  x_FACULTY_POSITION_FLAG        IN      VARCHAR2,
    		  x_TENURE_CODE                 IN      VARCHAR2,
    		  x_FRACTION_OF_TENURE          IN      NUMBER,
    		  x_EMPLOYMENT_TYPE_CODE        IN      VARCHAR2,
    		  x_EMPLOYED_AS_TITLE_CODE      IN      VARCHAR2,
    		  x_WEEKLY_WORK_HOURS           IN      NUMBER,
    		  x_COMMENTS                    IN      VARCHAR2
		);

PROCEDURE Lock_Row(
                  x_Rowid                         IN       VARCHAR2,
                  x_EMPLOYMENT_HISTORY_ID         IN       NUMBER,
                  x_BEGIN_DATE                    IN       DATE,
                  x_PARTY_ID                      IN       NUMBER,
                  x_EMPLOYED_AS_TITLE             IN       VARCHAR2,
                  x_EMPLOYED_BY_DIVISION_NAME     IN       VARCHAR2,
                  x_EMPLOYED_BY_NAME_COMPANY      IN       VARCHAR2,
                  x_END_DATE                      IN       DATE,
                  x_SUPERVISOR_NAME               IN       VARCHAR2,
                  x_BRANCH                        IN       VARCHAR2,
                  x_MILITARY_RANK                 IN       VARCHAR2,
                  x_CREATED_BY                    IN       NUMBER,
                  x_CREATION_DATE                 IN       DATE,
                  x_SERVED                        IN       VARCHAR2,
                  x_LAST_UPDATE_LOGIN             IN       NUMBER,
                  x_STATION                       IN       VARCHAR2,
                  x_LAST_UPDATE_DATE              IN       DATE,
                  x_LAST_UPDATED_BY               IN       NUMBER,
                  x_REQUEST_ID                    IN       NUMBER,
                  x_PROGRAM_APPLICATION_ID        IN       NUMBER,
                  x_PROGRAM_ID                    IN       NUMBER,
                  x_PROGRAM_UPDATE_DATE           IN       DATE,
                  x_WH_UPDATE_DATE                IN       DATE,
                  x_RESPONSIBILITY                IN       VARCHAR2,
                  x_STATUS                        IN	   VARCHAR2,
    		  x_EMPLOYED_BY_PARTY_ID          IN       NUMBER,
    		  x_REASON_FOR_LEAVING            IN       VARCHAR2,
    		  x_FACULTY_POSITION_FLAG          IN       VARCHAR2,
    		  x_TENURE_CODE                   IN       VARCHAR2,
    		  x_FRACTION_OF_TENURE            IN       NUMBER,
    		  x_EMPLOYMENT_TYPE_CODE          IN       VARCHAR2,
    		  x_EMPLOYED_AS_TITLE_CODE        IN       VARCHAR2,
    		  x_WEEKLY_WORK_HOURS             IN       NUMBER,
    		  x_COMMENTS                      IN       VARCHAR2,
    		  x_APPLICATION_ID                IN       NUMBER

                  );

PROCEDURE Update_Row(
                  x_Rowid                       IN  OUT NOCOPY   VARCHAR2,
                  x_EMPLOYMENT_HISTORY_ID       IN  OUT NOCOPY   NUMBER,
                  x_BEGIN_DATE                  IN      DATE,
                  x_PARTY_ID                    IN      NUMBER,
                  x_EMPLOYED_AS_TITLE           IN      VARCHAR2,
                  x_EMPLOYED_BY_DIVISION_NAME   IN      VARCHAR2,
                  x_EMPLOYED_BY_NAME_COMPANY    IN      VARCHAR2,
                  x_END_DATE                    IN      DATE,
                  x_SUPERVISOR_NAME             IN      VARCHAR2,
                  x_BRANCH                      IN      VARCHAR2,
                  x_MILITARY_RANK               IN      VARCHAR2,
                  x_SERVED                      IN      VARCHAR2,
                  x_STATION                     IN      VARCHAR2,
                  x_RESPONSIBILITY              IN      VARCHAR2,
                  x_STATUS                      IN      VARCHAR2,
    		  x_OBJECT_VERSION_NUMBER       IN      NUMBER,
    		  x_CREATED_BY_MODULE           IN      VARCHAR2,
    		  x_APPLICATION_ID              IN      NUMBER,
    		  x_EMPLOYED_BY_PARTY_ID        IN      NUMBER,
    		  x_REASON_FOR_LEAVING          IN      VARCHAR2,
    		  x_FACULTY_POSITION_FLAG        IN      VARCHAR2,
    		  x_TENURE_CODE                 IN      VARCHAR2,
    		  x_FRACTION_OF_TENURE          IN      NUMBER,
    		  x_EMPLOYMENT_TYPE_CODE        IN      VARCHAR2,
    		  x_EMPLOYED_AS_TITLE_CODE      IN      VARCHAR2,
    		  x_WEEKLY_WORK_HOURS           IN      NUMBER,
    		  x_COMMENTS                    IN      VARCHAR2

		  );

PROCEDURE Select_Row (
		  x_employment_history_id         IN OUT NOCOPY NUMBER,
		  x_begin_date                    OUT    NOCOPY DATE,
		  x_party_id                      OUT    NOCOPY NUMBER,
		  x_employed_as_title             OUT    NOCOPY VARCHAR2,
		  x_employed_by_division_name     OUT    NOCOPY VARCHAR2,
		  x_employed_by_name_company      OUT    NOCOPY VARCHAR2,
		  x_end_date                      OUT    NOCOPY DATE,
		  x_supervisor_name               OUT    NOCOPY VARCHAR2,
		  x_branch                        OUT    NOCOPY VARCHAR2,
		  x_military_rank                 OUT    NOCOPY VARCHAR2,
		  x_served                        OUT    NOCOPY VARCHAR2,
		  x_station                       OUT    NOCOPY VARCHAR2,
		  x_responsibility                OUT    NOCOPY VARCHAR2,
		  x_status                        OUT    NOCOPY VARCHAR2,
		  x_application_id                OUT    NOCOPY NUMBER,
		  x_created_by_module             OUT    NOCOPY VARCHAR2,
		  x_reason_for_leaving            OUT    NOCOPY VARCHAR2,
		  x_faculty_position_flag         OUT    NOCOPY VARCHAR2,
		  x_tenure_code                   OUT    NOCOPY VARCHAR2,
		  x_fraction_of_tenure            OUT    NOCOPY NUMBER,
		  x_employment_type_code          OUT    NOCOPY VARCHAR2,
		  x_employed_as_title_code        OUT    NOCOPY VARCHAR2,
		  x_weekly_work_hours             OUT    NOCOPY NUMBER,
		  x_comments                      OUT    NOCOPY VARCHAR2
);


PROCEDURE Delete_Row(                  x_EMPLOYMENT_HISTORY_ID         NUMBER);

END HZ_EMPLOYMENT_HISTORY_PKG;

 

/
