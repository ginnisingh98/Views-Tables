--------------------------------------------------------
--  DDL for Package PA_MU_BATCHES_V_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_MU_BATCHES_V_PKG" AUTHID CURRENT_USER as
-- $Header: PAXBAUPS.pls 120.2 2005/08/17 03:18:58 avaithia noship $

  PROCEDURE Insert_Row(	X_Rowid                 IN OUT NOCOPY  VARCHAR2, -- 4537865
			X_Batch_ID		IN OUT NOCOPY	NUMBER,  -- 4537865
			X_Org_Id                IN NUMBER DEFAULT NULL, --R12 MOAC Changes:Bug 4363093
			X_Creation_Date			DATE,
			X_Created_By			NUMBER,
			X_Last_Updated_By		NUMBER,
			X_Last_Update_Date		DATE,
			X_Last_Update_Login		NUMBER,
			X_Batch_Name			VARCHAR2,
			X_Batch_status_Code		VARCHAR2,
			X_Description			VARCHAR2,
			X_Project_Attribute		VARCHAR2,
			X_Effective_Date		DATE,
			X_Attribute_Category		VARCHAR2,
			X_Attribute1			VARCHAR2,
			X_Attribute2			VARCHAR2,
			X_Attribute3			VARCHAR2,
			X_Attribute4			VARCHAR2,
			X_Attribute5			VARCHAR2,
			X_Attribute6			VARCHAR2,
			X_Attribute7			VARCHAR2,
			X_Attribute8			VARCHAR2,
			X_Attribute9			VARCHAR2,
			X_Attribute10			VARCHAR2,
			X_Attribute11			VARCHAR2,
			X_Attribute12			VARCHAR2,
			X_Attribute13			VARCHAR2,
			X_Attribute14			VARCHAR2,
			X_Attribute15			VARCHAR2 );


  PROCEDURE Update_Row(	X_Rowid                         VARCHAR2,
			X_Last_Updated_By		NUMBER,
			X_Last_Update_Date		DATE,
			X_Last_Update_Login		NUMBER,
			X_Batch_Name			VARCHAR2,
			X_Batch_status_Code		VARCHAR2,
			X_Rejection_Code		VARCHAR2,
			X_Description			VARCHAR2,
			X_Project_Attribute		VARCHAR2,
                        X_Effective_Date		DATE,
			X_Process_Run_By		NUMBER,
			X_Process_Run_Date		DATE,
			X_Attribute_Category		VARCHAR2,
			X_Attribute1			VARCHAR2,
			X_Attribute2			VARCHAR2,
			X_Attribute3			VARCHAR2,
			X_Attribute4			VARCHAR2,
			X_Attribute5			VARCHAR2,
			X_Attribute6			VARCHAR2,
			X_Attribute7			VARCHAR2,
			X_Attribute8			VARCHAR2,
			X_Attribute9			VARCHAR2,
			X_Attribute10			VARCHAR2,
			X_Attribute11			VARCHAR2,
			X_Attribute12			VARCHAR2,
			X_Attribute13			VARCHAR2,
			X_Attribute14			VARCHAR2,
			X_Attribute15			VARCHAR2 );


  PROCEDURE Lock_Row(	X_Rowid                         VARCHAR2,
			X_Batch_Name			VARCHAR2,
			X_Batch_status_Code		VARCHAR2,
			X_Description			VARCHAR2,
			X_Project_Attribute		VARCHAR2,
			X_Process_Run_By		NUMBER,
			X_Process_Run_Date		DATE,
			X_Effective_Date		DATE,
			X_Rejection_Code		VARCHAR2,
			X_Attribute_Category		VARCHAR2,
			X_Attribute1			VARCHAR2,
			X_Attribute2			VARCHAR2,
			X_Attribute3			VARCHAR2,
			X_Attribute4			VARCHAR2,
			X_Attribute5			VARCHAR2,
			X_Attribute6			VARCHAR2,
			X_Attribute7			VARCHAR2,
			X_Attribute8			VARCHAR2,
			X_Attribute9			VARCHAR2,
			X_Attribute10			VARCHAR2,
			X_Attribute11			VARCHAR2,
			X_Attribute12			VARCHAR2,
			X_Attribute13			VARCHAR2,
			X_Attribute14			VARCHAR2,
			X_Attribute15			VARCHAR2 );


  PROCEDURE Delete_Row(	X_Rowid VARCHAR2 );


  -- -----------------------------------------------------------------
  -- Proc_Conc
  --   Procedure to process mass update batches.  This procedure
  --   should be called from Reports
  --
  --   Parameters:
  --     ERRBUF - Standard concurrent program parameter
  --     RETCODE - Standard concurrent program parameter
  --     X_Batch_ID - Specify the batch to process
  --     X_Request_ID - return the concurrent request ID to the caller
  --
  --   Notes:
  --     If the batch ID is not passed in, all the batches with
  --     'Submitted' status whose effective date is before sysdate
  --     will be processed.
  -- -----------------------------------------------------------------

  PROCEDURE Proc_Conc(  ERRBUF		OUT NOCOPY	VARCHAR2, -- 4537865
		        RETCODE		OUT NOCOPY	VARCHAR2, -- 4537865
		        X_Batch_ID 	 IN	NUMBER   DEFAULT NULL,
			X_Request_ID    OUT  NOCOPY    NUMBER ); -- 4537865

  -- -----------------------------------------------------------------
  -- Process
  --   Procedure to process one single batch specified by the
  --   X_Batch_ID parameter.  This procedure is called by the
  --   Proc_Conc procedure and from the Mass Update Batches form.
  -- -----------------------------------------------------------------

  PROCEDURE Process(  ERRBUF		OUT NOCOPY	VARCHAR2, -- 4537865
		      RETCODE		OUT NOCOPY 	VARCHAR2, -- 4537865
		      X_Batch_ID 	 IN	NUMBER,
		      X_Concurrent	 IN	VARCHAR2 DEFAULT 'Y',
		      X_All_Batches	 IN 	VARCHAR2 DEFAULT 'N' );

END PA_MU_BATCHES_V_PKG;

 

/
