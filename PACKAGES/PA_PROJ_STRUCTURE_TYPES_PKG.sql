--------------------------------------------------------
--  DDL for Package PA_PROJ_STRUCTURE_TYPES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_PROJ_STRUCTURE_TYPES_PKG" AUTHID CURRENT_USER as
/*$Header: PAXPSTTS.pls 120.1 2005/08/19 17:18:26 mwasowic noship $*/

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
     X_ROWID                                  IN OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
    , X_PROJ_STRUCTURE_TYPE_ID                   IN OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
    , X_PROJ_ELEMENT_ID                          NUMBER
    , X_STRUCTURE_TYPE_ID                        NUMBER
    , X_RECORD_VERSION_NUMBER                    NUMBER
    , X_ATTRIBUTE_CATEGORY                       VARCHAR2
    , X_ATTRIBUTE1                               VARCHAR2
    , X_ATTRIBUTE2                               VARCHAR2
    , X_ATTRIBUTE3                               VARCHAR2
    , X_ATTRIBUTE4                               VARCHAR2
    , X_ATTRIBUTE5                               VARCHAR2
    , X_ATTRIBUTE6                               VARCHAR2
    , X_ATTRIBUTE7                               VARCHAR2
    , X_ATTRIBUTE8                               VARCHAR2
    , X_ATTRIBUTE9                               VARCHAR2
    , X_ATTRIBUTE10                              VARCHAR2
    , X_ATTRIBUTE11                              VARCHAR2
    , X_ATTRIBUTE12                              VARCHAR2
    , X_ATTRIBUTE13                              VARCHAR2
    , X_ATTRIBUTE14                              VARCHAR2
    , X_ATTRIBUTE15                              VARCHAR2
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
     X_ROWID                                  VARCHAR2
    , X_PROJ_STRUCTURE_TYPE_ID                   NUMBER
    , X_PROJ_ELEMENT_ID                          NUMBER
    , X_STRUCTURE_TYPE_ID                        NUMBER
    , X_RECORD_VERSION_NUMBER                    NUMBER
    , X_ATTRIBUTE_CATEGORY                       VARCHAR2
    , X_ATTRIBUTE1                               VARCHAR2
    , X_ATTRIBUTE2                               VARCHAR2
    , X_ATTRIBUTE3                               VARCHAR2
    , X_ATTRIBUTE4                               VARCHAR2
    , X_ATTRIBUTE5                               VARCHAR2
    , X_ATTRIBUTE6                               VARCHAR2
    , X_ATTRIBUTE7                               VARCHAR2
    , X_ATTRIBUTE8                               VARCHAR2
    , X_ATTRIBUTE9                               VARCHAR2
    , X_ATTRIBUTE10                              VARCHAR2
    , X_ATTRIBUTE11                              VARCHAR2
    , X_ATTRIBUTE12                              VARCHAR2
    , X_ATTRIBUTE13                              VARCHAR2
    , X_ATTRIBUTE14                              VARCHAR2
    , X_ATTRIBUTE15                              VARCHAR2
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


end PA_PROJ_STRUCTURE_TYPES_PKG;

 

/
