--------------------------------------------------------
--  DDL for Package PA_PROJ_ELEM_VER_STRUCTURE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_PROJ_ELEM_VER_STRUCTURE_PKG" AUTHID CURRENT_USER as
/*$Header: PAXSVATS.pls 120.1 2005/08/19 17:21:18 mwasowic noship $*/

-- API name                      : insert_row
-- Type                          : Table Handlers
--
--  History
--
--  25-JUN-01   HSIU             -Created
--
--


  procedure insert_row
  (
     X_ROWID                                    IN OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   , X_PEV_STRUCTURE_ID                         IN OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
   , X_ELEMENT_VERSION_ID                       NUMBER
   , X_VERSION_NUMBER                           NUMBER
   , X_NAME                                     VARCHAR2
   , X_PROJECT_ID                               NUMBER
   , X_PROJ_ELEMENT_ID                          NUMBER
   , X_DESCRIPTION                              VARCHAR2
   , X_EFFECTIVE_DATE                           DATE
   , X_PUBLISHED_DATE                           DATE
   , X_PUBLISHED_BY                             NUMBER
   , X_CURRENT_BASELINE_DATE                    DATE
   , X_CURRENT_BASELINE_FLAG                    VARCHAR2
   , X_CURRENT_BASELINE_BY                      NUMBER
   , X_ORIGINAL_BASELINE_DATE                   DATE
   , X_ORIGINAL_BASELINE_FLAG                   VARCHAR2
   , X_ORIGINAL_BASELINE_BY                     NUMBER
   , X_LOCK_STATUS_CODE                         VARCHAR2
   , X_LOCKED_BY                                NUMBER
   , X_LOCKED_DATE                              DATE
   , X_STATUS_CODE                              VARCHAR2
   , X_WF_STATUS_CODE                           VARCHAR2
   , X_LATEST_EFF_PUBLISHED_FLAG                VARCHAR2
   , X_CHANGE_REASON_CODE                       VARCHAR2
   , X_RECORD_VERSION_NUMBER                    NUMBER
   , X_CURRENT_WORKING_FLAG                     VARCHAR2 := 'N'   --FPM changes bug 3301192
   , x_source_object_id      IN NUMBER:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM       --Bug No 3594635 SMukka
   , x_source_object_type    IN VARCHAR2:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR    --Bug No 3594635 SMukka
  );



-- API name                      : update_row
-- Type                          : Table Handler
--
--  History
--
--  25-JUN-01   HSIU             -Created
--
--


  procedure update_row
  (
     X_ROWID                                    VARCHAR2
   , X_PEV_STRUCTURE_ID                         NUMBER
   , X_ELEMENT_VERSION_ID                       NUMBER
   , X_VERSION_NUMBER                           NUMBER
   , X_NAME                                     VARCHAR2
   , X_PROJECT_ID                               NUMBER
   , X_PROJ_ELEMENT_ID                          NUMBER
   , X_DESCRIPTION                              VARCHAR2
   , X_EFFECTIVE_DATE                           DATE
   , X_PUBLISHED_DATE                           DATE
   , X_PUBLISHED_BY                             NUMBER
   , X_CURRENT_BASELINE_DATE                    DATE
   , X_CURRENT_BASELINE_FLAG                    VARCHAR2
   , X_CURRENT_BASELINE_BY                      NUMBER
   , X_ORIGINAL_BASELINE_DATE                   DATE
   , X_ORIGINAL_BASELINE_FLAG                   VARCHAR2
   , X_ORIGINAL_BASELINE_BY                     NUMBER
   , X_LOCK_STATUS_CODE                         VARCHAR2
   , X_LOCKED_BY                                NUMBER
   , X_LOCKED_DATE                              DATE
   , X_STATUS_CODE                              VARCHAR2
   , X_WF_STATUS_CODE                           VARCHAR2
   , X_LATEST_EFF_PUBLISHED_FLAG                VARCHAR2
   , X_CHANGE_REASON_CODE                       VARCHAR2
   , X_RECORD_VERSION_NUMBER                    NUMBER
   , X_CURRENT_WORKING_FLAG                     VARCHAR2 := 'N'   --FPM changes bug 3301192
  );


-- API name                      : delete_row
-- Type                          : Table Handler
--
--  History
--
--  25-JUN-01   HSIU             -Created
--
--


  procedure delete_row
  (
    X_ROWID                                    VARCHAR2
  );


end PA_PROJ_ELEM_VER_STRUCTURE_PKG;

 

/
