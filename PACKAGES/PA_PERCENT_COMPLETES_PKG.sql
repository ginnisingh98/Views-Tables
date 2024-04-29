--------------------------------------------------------
--  DDL for Package PA_PERCENT_COMPLETES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_PERCENT_COMPLETES_PKG" AUTHID CURRENT_USER as
/* $Header: PAPCPKGS.pls 120.1 2005/08/05 03:38:41 lveerubh noship $*/

procedure INSERT_ROW( p_TASK_ID                 IN    NUMBER,
                      p_DATE_COMPUTED           IN    DATE,
                      p_LAST_UPDATE_DATE        IN    DATE,
                      p_LAST_UPDATED_BY         IN    NUMBER,
                      p_CREATION_DATE           IN    DATE,
                      p_CREATED_BY              IN    NUMBER,
                      p_LAST_UPDATE_LOGIN       IN    NUMBER,
                      p_COMPLETED_PERCENTAGE    IN    NUMBER,
                      p_DESCRIPTION             IN    VARCHAR2,
                      p_PROJECT_ID              IN    NUMBER,
                      p_PM_PRODUCT_CODE         IN    VARCHAR2,
                      p_CURRENT_FLAG            IN    VARCHAR2,
                      p_OBJECT_TYPE             IN    VARCHAR2,
                      p_OBJECT_ID               IN    NUMBER,
                      p_OBJECT_VERSION_ID       IN    NUMBER,
                      p_PROGRESS_STATUS_CODE    IN    VARCHAR2,
                      p_ACTUAL_START_DATE       IN    DATE,
                      p_ACTUAL_FINISH_DATE      IN    DATE,
                      p_ESTIMATED_START_DATE    IN    DATE,
                      p_ESTIMATED_FINISH_DATE   IN    DATE,
                      p_PUBLISHED_FLAG          IN    VARCHAR2,
                      p_PUBLISHED_BY_PARTY_ID   IN    NUMBER,
                      p_PROGRESS_COMMENT        IN    VARCHAR2,
                      p_HISTORY_FLAG            IN    VARCHAR2,
                      p_status_code             IN    VARCHAR2,
                      x_PERCENT_COMPLETE_ID     IN OUT NOCOPY  NUMBER
 ,p_ATTRIBUTE_CATEGORY              IN VARCHAR2
 ,p_ATTRIBUTE1                      IN VARCHAR2
 ,p_ATTRIBUTE2                      IN VARCHAR2
 ,p_ATTRIBUTE3                      IN VARCHAR2
 ,p_ATTRIBUTE4                      IN VARCHAR2
 ,p_ATTRIBUTE5                      IN VARCHAR2
 ,p_ATTRIBUTE6                      IN VARCHAR2
 ,p_ATTRIBUTE7                      IN VARCHAR2
 ,p_ATTRIBUTE8                      IN VARCHAR2
 ,p_ATTRIBUTE9                      IN VARCHAR2
 ,p_ATTRIBUTE10                     IN VARCHAR2
 ,p_ATTRIBUTE11                     IN VARCHAR2
 ,p_ATTRIBUTE12                     IN VARCHAR2
 ,p_ATTRIBUTE13                     IN VARCHAR2
 ,p_ATTRIBUTE14                     IN VARCHAR2
 ,p_ATTRIBUTE15                     IN VARCHAR2
 ,p_structure_type		    IN VARCHAR2
);

procedure UPDATE_ROW(
                      p_task_id                    IN    NUMBER,
                      p_DATE_COMPUTED           IN    DATE,
                      p_LAST_UPDATE_DATE        IN    DATE,
                      p_LAST_UPDATED_BY         IN    NUMBER,
                      p_LAST_UPDATE_LOGIN       IN    NUMBER,
                      p_COMPLETED_PERCENTAGE    IN    NUMBER,
                      p_DESCRIPTION             IN    VARCHAR2,
                      p_PM_PRODUCT_CODE         IN    VARCHAR2,
                      p_CURRENT_FLAG            IN    VARCHAR2,
                      p_PERCENT_COMPLETE_ID      IN    NUMBER,
                      p_project_id              IN     NUMBER,
                      p_OBJECT_TYPE             IN    VARCHAR2,
                      p_OBJECT_ID               IN    NUMBER,
                      p_OBJECT_VERSION_ID       IN    NUMBER,
                      p_PROGRESS_STATUS_CODE     IN    VARCHAR2,
                      p_ACTUAL_START_DATE        IN    DATE,
                      p_ACTUAL_FINISH_DATE       IN    DATE,
                      p_ESTIMATED_START_DATE     IN    DATE,
                      p_ESTIMATED_FINISH_DATE    IN    DATE,
                      p_PUBLISHED_FLAG           IN    VARCHAR2,
                      p_PUBLISHED_BY_PARTY_ID    IN    NUMBER,
                      p_PROGRESS_COMMENT         IN    VARCHAR2,
                      p_HISTORY_FLAG            IN    VARCHAR2,
                      p_status_code             IN    VARCHAR2,
                      p_RECORD_VERSION_NUMBER    IN    NUMBER
 ,p_ATTRIBUTE_CATEGORY              IN VARCHAR2
 ,p_ATTRIBUTE1                      IN VARCHAR2
 ,p_ATTRIBUTE2                      IN VARCHAR2
 ,p_ATTRIBUTE3                      IN VARCHAR2
 ,p_ATTRIBUTE4                      IN VARCHAR2
 ,p_ATTRIBUTE5                      IN VARCHAR2
 ,p_ATTRIBUTE6                      IN VARCHAR2
 ,p_ATTRIBUTE7                      IN VARCHAR2
 ,p_ATTRIBUTE8                      IN VARCHAR2
 ,p_ATTRIBUTE9                      IN VARCHAR2
 ,p_ATTRIBUTE10                     IN VARCHAR2
 ,p_ATTRIBUTE11                     IN VARCHAR2
 ,p_ATTRIBUTE12                     IN VARCHAR2
 ,p_ATTRIBUTE13                     IN VARCHAR2
 ,p_ATTRIBUTE14                     IN VARCHAR2
 ,p_ATTRIBUTE15                     IN VARCHAR2
 ,p_structure_type		    IN VARCHAR2
);

Procedure DELETE_ROW(
 p_row_id  VARCHAR2 );

end PA_PERCENT_COMPLETES_PKG;


 

/
