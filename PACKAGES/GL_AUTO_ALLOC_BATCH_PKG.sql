--------------------------------------------------------
--  DDL for Package GL_AUTO_ALLOC_BATCH_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_AUTO_ALLOC_BATCH_PKG" AUTHID CURRENT_USER AS
/* $Header: glatalbs.pls 120.3 2005/05/05 02:02:15 kvora ship $ */

  --Procedure
  --   Insert_Allocation_batch
  -- Purpose
  -- Insert row in  GL_AUTO_ALLOC_BATCHES  Table
  -- Example
  --   gl_auto_alloc_batch_pkg.Insert_Allocation_batch
  -- Notes

Procedure Insert_Allocation_batch(
    l_Row_Id                      IN OUT NOCOPY VARCHAR2
  , l_ALLOCATION_SET_ID           IN NUMBER
  , l_BATCH_ID                    IN NUMBER
  , l_BATCH_TYPE_CODE             IN VARCHAR2
  , l_LAST_UPDATE_DATE            IN DATE
  , l_LAST_UPDATED_BY             IN NUMBER
  , l_LAST_UPDATE_LOGIN           IN NUMBER
  , l_CREATION_DATE               IN DATE
  , l_CREATED_BY                  IN NUMBER
  , l_STEP_NUMBER                 IN NUMBER
  , l_OWNER                       IN VARCHAR2
  , l_ALLOCATION_METHOD_CODE      IN VARCHAR2
  , l_ATTRIBUTE1                  IN VARCHAR2
  , l_ATTRIBUTE2                  IN VARCHAR2
  , l_ATTRIBUTE3                  IN VARCHAR2
  , l_ATTRIBUTE4                  IN VARCHAR2
  , l_ATTRIBUTE5                  IN VARCHAR2
  , l_ATTRIBUTE6                  IN VARCHAR2
  , l_ATTRIBUTE7                  IN VARCHAR2
  , l_ATTRIBUTE8                  IN VARCHAR2
  , l_ATTRIBUTE9                  IN VARCHAR2
  , l_ATTRIBUTE10                 IN VARCHAR2
  , l_ATTRIBUTE11                 IN VARCHAR2
  , l_ATTRIBUTE12                 IN VARCHAR2
  , l_ATTRIBUTE13                 IN VARCHAR2
  , l_ATTRIBUTE14                 IN VARCHAR2
  , l_ATTRIBUTE15                 IN VARCHAR2
  , l_CONTEXT                     IN VARCHAR2
 )  ;

  --Procedure
  --   Update_Allocation_batch
  -- Purpose
  -- Insert row in  GL_AUTO_ALLOC_BATCHES  Table
  -- Example
  --   gl_auto_alloc_batch_pkg.Update_Allocation_batch
  -- Notes

Procedure Update_Allocation_batch(
    l_Row_Id                      IN VARCHAR2
  , l_BATCH_ID                    IN NUMBER
  , l_BATCH_TYPE_CODE             IN VARCHAR2
  , l_LAST_UPDATE_DATE            IN DATE
  , l_LAST_UPDATED_BY             IN NUMBER
  , l_LAST_UPDATE_LOGIN           IN NUMBER
  , l_STEP_NUMBER                 IN NUMBER
  , l_OWNER                       IN VARCHAR2
  , l_ALLOCATION_METHOD_CODE      IN VARCHAR2
  , l_ATTRIBUTE1                  IN VARCHAR2
  , l_ATTRIBUTE2                  IN VARCHAR2
  , l_ATTRIBUTE3                  IN VARCHAR2
  , l_ATTRIBUTE4                  IN VARCHAR2
  , l_ATTRIBUTE5                  IN VARCHAR2
  , l_ATTRIBUTE6                  IN VARCHAR2
  , l_ATTRIBUTE7                  IN VARCHAR2
  , l_ATTRIBUTE8                  IN VARCHAR2
  , l_ATTRIBUTE9                  IN VARCHAR2
  , l_ATTRIBUTE10                 IN VARCHAR2
  , l_ATTRIBUTE11                 IN VARCHAR2
  , l_ATTRIBUTE12                 IN VARCHAR2
  , l_ATTRIBUTE13                 IN VARCHAR2
  , l_ATTRIBUTE14                 IN VARCHAR2
  , l_ATTRIBUTE15                 IN VARCHAR2
  , l_CONTEXT                     IN VARCHAR2
);


  --Procedure
  --   Delete_Allocation_batch
  -- Purpose
  -- delete row in  GL_AUTO_ALLOC_BATCHES  Table
  -- Example
  --   gl_auto_alloc_batch_pkg.Delete_Allocation_batch
  -- Notes

Procedure Delete_Allocation_batch(
  l_Row_id                  IN VARCHAR2
 );

  --Procedure
  -- Lock_allocation_batch
  -- Purpose
  -- Locks row in  GL_AUTO_ALLOC_BATCHES  Table
  -- Example
  --   gl_auto_alloc_batch_pkg.Lock_allocation_batch
  -- Notes

Procedure Lock_allocation_batch
(
    l_Row_Id                      IN VARCHAR2
  , l_ALLOCATION_SET_ID           IN NUMBER
  , l_BATCH_ID                    IN NUMBER
  , l_BATCH_TYPE_CODE             IN VARCHAR2
  , l_LAST_UPDATED_BY             IN NUMBER
  , l_LAST_UPDATE_LOGIN           IN NUMBER
  , l_STEP_NUMBER                 IN NUMBER
  , l_OWNER                       IN VARCHAR2
  , l_ALLOCATION_METHOD_CODE      IN VARCHAR2
  , l_ATTRIBUTE1                  IN VARCHAR2
  , l_ATTRIBUTE2                  IN VARCHAR2
  , l_ATTRIBUTE3                  IN VARCHAR2
  , l_ATTRIBUTE4                  IN VARCHAR2
  , l_ATTRIBUTE5                  IN VARCHAR2
  , l_ATTRIBUTE6                  IN VARCHAR2
  , l_ATTRIBUTE7                  IN VARCHAR2
  , l_ATTRIBUTE8                  IN VARCHAR2
  , l_ATTRIBUTE9                  IN VARCHAR2
  , l_ATTRIBUTE10                 IN VARCHAR2
  , l_ATTRIBUTE11                 IN VARCHAR2
  , l_ATTRIBUTE12                 IN VARCHAR2
  , l_ATTRIBUTE13                 IN VARCHAR2
  , l_ATTRIBUTE14                 IN VARCHAR2
  , l_ATTRIBUTE15                 IN VARCHAR2
  , l_CONTEXT                     IN VARCHAR2
);


  --   Procedure
  --   Check_Unique_Step
  --   Purpose
  --   Check uniquenes of Allocation set
  --   Access
  --   Called from the AutoAllocation workbench form
  --

 PROCEDURE Check_Unique_Step( l_rowid              IN  VARCHAR2
                             ,l_step_number        IN  NUMBER
                             ,l_allocation_set_id  IN  NUMBER
                              ,l_step_label        IN  VARCHAR2 );


  --   Procedure
  --   Check_Unique_Batch
  --   Purpose
  --   Check uniquenes of of batch in the  Allocation set
  --

 PROCEDURE Check_Unique_Batch( l_rowid             IN  VARCHAR2
                             ,l_allocation_set_id  IN  NUMBER
                             ,l_Batch_Id           IN  NUMBER
                             ,l_Batch_Type_Code    IN  VARCHAR2
                             ,l_Return_Code        IN  OUT NOCOPY VARCHAR2 );




 -- Procedure
  --   get_step_status
  -- Purpose
  --   Get summary level batch type and balance type info
  -- Access
  --   Called from the View AutoAllocation status form
  --   Mode indicated whether its step-down or parallel

Procedure get_step_status (
                       p_request_Id      In  NUMBER
                       ,p_step_number    In  NUMBER
                       ,p_mode           In  VARCHAR2
                       ,p_status         Out NOCOPY VARCHAR2) ;

Procedure get_gl_step_status(
                          p_request_Id    In  NUMBER
                         ,p_step_number   In  NUMBER
                         ,p_mode          In  VARCHAR2
                         ,p_status        Out NOCOPY VARCHAR2);

END gl_auto_alloc_batch_pkg;

 

/
