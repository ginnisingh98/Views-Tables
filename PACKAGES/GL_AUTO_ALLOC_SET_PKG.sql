--------------------------------------------------------
--  DDL for Package GL_AUTO_ALLOC_SET_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_AUTO_ALLOC_SET_PKG" AUTHID CURRENT_USER AS
/* $Header: glatalss.pls 120.5 2005/05/05 02:02:29 kvora ship $ */
  --
  -- Function
  --   get_unique_id
  -- Purpose
  --   Gets a unique allocation_set_id
  -- Arguments
  --   none
  -- Example
  --   abid := gl_auto_alloc_set_pkg.get_unique_id;
  -- Notes
  --
  FUNCTION Get_Unique_Set_Id RETURN NUMBER;

  -- Procedure
  --   Insert_Allocation_Set
  -- Purpose
  -- Inserts allocation set row into GL_AUTO_ALLOC_SET Table
  -- Example
  --   gl_auto_alloc_set_pkg.Insert_Allocation_Set
  -- Notes

Procedure Insert_Allocation_Set(
    l_Row_Id                      IN OUT NOCOPY VARCHAR2
  , l_ALLOCATION_SET_ID           IN NUMBER
  , l_ALLOCATION_SET_TYPE_CODE    IN VARCHAR2
  , l_ALLOCATION_SET_NAME         IN VARCHAR2
  , l_ALLOCATION_CODE             IN VARCHAR2
  , l_CHART_OF_ACCOUNTS_ID        IN NUMBER
  , l_PERIOD_SET_NAME             IN VARCHAR
  , l_ACCOUNTED_PERIOD_TYPE       IN VARCHAR
  , l_LAST_UPDATE_DATE            IN DATE
  , l_LAST_UPDATED_BY             IN NUMBER
  , l_LAST_UPDATE_LOGIN           IN NUMBER
  , l_CREATION_DATE               IN DATE
  , l_CREATED_BY                  IN NUMBER
  , l_ORG_ID                      IN NUMBER
  , l_DESCRIPTION                 IN VARCHAR2
  , l_OWNER                       IN VARCHAR2
  , l_SECURITY_FLAG               IN VARCHAR2
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

  -- Procedure
  --   Lock_Allocation_Set
  -- Purpose
  -- locks row in  GL_AUTO_ALLOC_SET Table
  -- Example
  --   gl_auto_alloc_set_pkg.Lock_Allocation_Set
  -- Notes

Procedure Lock_Allocation_Set(
    l_Row_Id                      IN VARCHAR2
  , l_ALLOCATION_SET_ID           IN NUMBER
  , l_ALLOCATION_SET_TYPE_CODE    IN VARCHAR2
  , l_ALLOCATION_SET_NAME         IN VARCHAR2
  , l_ALLOCATION_CODE             IN VARCHAR2
  , l_CHART_OF_ACCOUNTS_ID        IN NUMBER
  , l_PERIOD_SET_NAME             IN VARCHAR
  , l_ACCOUNTED_PERIOD_TYPE       IN VARCHAR
  , l_LAST_UPDATED_BY             IN NUMBER
  , l_LAST_UPDATE_LOGIN           IN NUMBER
  , l_CREATED_BY                  IN NUMBER
  , l_DESCRIPTION                 IN VARCHAR2
  , l_OWNER                       IN VARCHAR2
  , l_SECURITY_FLAG               IN VARCHAR2
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
  --   Update_Allocation_Set
  -- Purpose
  -- Update row in  GL_AUTO_ALLOC_SET Table
  -- Example
  --   gl_auto_alloc_set_pkg.Update_Allocation_Set
  -- Notes

Procedure Update_Allocation_Set(
    l_Row_Id                      IN VARCHAR2
  , l_ALLOCATION_SET_NAME         IN VARCHAR2
  , l_LAST_UPDATE_DATE            IN DATE
  , l_LAST_UPDATED_BY             IN NUMBER
  , l_LAST_UPDATE_LOGIN           IN NUMBER
  , l_DESCRIPTION                 IN VARCHAR2
  , l_OWNER                       IN VARCHAR2
  , l_SECURITY_FLAG               IN VARCHAR2
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
   --   Delete_Allocation_Set
   -- Purpose
   -- delete row in  GL_AUTO_ALLOC_SET Table
   -- Example
   --   gl_auto_alloc_set_pkg.Delete_Allocation_Set
   -- Notes
 Procedure Delete_Allocation_Set(
   l_allocation_set_id            IN NUMBER) ;


  -- Procedure
  --   Get_Set_Content
  -- Purpose
  --   Get summary level batch type and balance type info
  -- Access
  --   Called from the Parameters form
  --

PROCEDURE Get_Set_Content(
                     X_Allocation_Set_Id                NUMBER,
                     X_Contain_Actual       IN OUT NOCOPY      BOOLEAN,
                     X_Contain_Budget       IN OUT NOCOPY      BOOLEAN,
                     X_Contain_Encumbrance  IN OUT NOCOPY      BOOLEAN,
                     X_Contain_Recurring    IN OUT NOCOPY      BOOLEAN,
                     X_Contain_Project      IN OUT NOCOPY      BOOLEAN,
                     X_Batch_Count          IN OUT NOCOPY      NUMBER
                    );


  -- Procedure
  --   Get_SetHistory_Content
  -- Purpose
  --   To find out whether project is part of auto allocation set
  -- Access
  --   Called from the ViewAutoAllocation form
  --
PROCEDURE Get_SetHistory_Content(
                     X_Request_id           IN          NUMBER,
                     X_Contain_Actual       IN OUT NOCOPY      BOOLEAN,
                     X_Contain_Budget       IN OUT NOCOPY      BOOLEAN,
                     X_Contain_Encumbrance  IN OUT NOCOPY      BOOLEAN,
                     X_Contain_Recurring    IN OUT NOCOPY      BOOLEAN,
                     X_Contain_Project      IN OUT NOCOPY      BOOLEAN,
                     X_Batch_Count          IN OUT NOCOPY      NUMBER
                    );

  -- Function
  --   Set_Random_Ledger_Id
  -- Purpose
  --   To get the random ledger id of the AutoAllocation set,
  --   MassBudget batch, Recurring Batch, or Budget Formula.
  -- Access
  --   Called from the Generate AutoAllocation form
  -- Example
  --   lgr_id := gl_auto_alloc_set_random_ledger_id('RECUR',123);
  -- Notes
  --
  --

FUNCTION Set_Random_Ledger_Id(
                     X_Mode           IN          VARCHAR2,
                     X_Batch_Id       IN          NUMBER,
                     X_Ledger_Id      IN          NUMBER) RETURN NUMBER;



  -- Procedure
  --   Get_Alloc_Set_Name
  -- Purpose
  --   To find out the allocation set name or batch name
  -- Access
  --   Called from the Generate AutoAllocation form
  --
FUNCTION Get_Alloc_Set_Name(
                     X_Mode             IN          VARCHAR,
                     X_Alloc_Set_Id     IN          NUMBER) RETURN VARCHAR;

END gl_auto_alloc_set_pkg;

 

/
