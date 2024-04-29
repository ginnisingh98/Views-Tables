--------------------------------------------------------
--  DDL for Package GL_JE_BATCHES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_JE_BATCHES_PKG" AUTHID CURRENT_USER AS
/* $Header: glijebas.pls 120.11.12000000.2 2007/07/25 17:22:15 aktelang ship $ */
--
-- Package
--   gl_je_batches_pkg
-- Purpose
--   To contain validation and insertion routines for gl_je_batches
-- History
--   12-30-93  	D. J. Ogg	Created
  --
  -- Procedure
  --   check_unique
  -- Purpose
  --   Checks to make sure that the name of the batch
  --   is unique within the batch period for that ledger.
  -- History
  --   12-30-93  D. J. Ogg    Created
  -- Arguments
  --   batch_name 	The name of the batch
  --   period_name      The name of the batch period
  --   coa_id           The chart of accounts id of the batch
  --   cal_name         The calendar of the batch
  --   per_type         The period type of the batch
  --   row_id		The current rowid
  -- Example
  --   gl_je_batches_pkg.check_unique(2, 'Testing', 'JAN-90', 123,
  --                                  'Accounting', 'Month', 'ABD02334');
  -- Notes
  --
  PROCEDURE check_unique(batch_name VARCHAR2,
                         period_name VARCHAR2,
                         coa_id NUMBER,
                         cal_name VARCHAR2,
                         per_type VARCHAR2,
                         row_id VARCHAR2);

  --
  -- Procedure
  --   get_unique_id
  -- Purpose
  --   Gets a unique batch id
  -- History
  --   12-30-93  D. J. Ogg    Created
  -- Arguments
  --   none
  -- Example
  --   bid := gl_je_batches_pkg.get_unique_id;
  -- Notes
  --
  FUNCTION get_unique_id RETURN NUMBER;

  --
  -- Procedure
  --   needs_approval
  -- Purpose
  --   Returns true if the batch contains at least one journal that
  --   needs approval and false otherwise.
  -- History
  --   11=NOV-03  D. J. Ogg    Created
  -- Arguments
  --   batch_id		The id of the batch
  -- Example
  --   if (gl_je_batches_pkg.needs_approval(1002)) THEN
  -- Notes
  --
  FUNCTION needs_approval(batch_id NUMBER) RETURN BOOLEAN;

  --
  -- Procedure
  --   needs_tax
  -- Purpose
  --   Returns true if the batch contains at least one journal that
  --   needs tax and false otherwise.
  -- History
  --   14-APR-04  D. J. Ogg    Created
  -- Arguments
  --   batch_id		The id of the batch
  -- Example
  --   if (gl_je_batches_pkg.needs_tax(1002)) THEN
  -- Notes
  --
  FUNCTION needs_tax(batch_id NUMBER) RETURN BOOLEAN;

  --
  -- Procedure
  --   has_lines
  -- Purpose
  --   Returns true if the batch contains at least one line, and false
  --   otherwise.
  -- History
  --   01-11-94  D. J. Ogg    Created
  -- Arguments
  --   batch_id		The id of the batch
  -- Example
  --   if (gl_je_batches_pkg.has_lines(1002)) THEN
  -- Notes
  --
  FUNCTION has_lines(batch_id NUMBER) RETURN BOOLEAN;

  --
  -- Procedure
  --   all_stat_headers
  -- Purpose
  --   Returns TRUE if the batch contains only STAT journal entries,
  --   FALSE otherwise.
  -- History
  --   02-16-95	  R  Ng	   Created
  -- Arguments
  --   X_je_batch_id		ID of journal batch
  -- Example
  --   gl_je_batches_pkg.all_stat_headers(:BATCHES.je_batch_id)
  -- Notes
  --
  FUNCTION all_stat_headers( X_je_batch_id  NUMBER ) RETURN BOOLEAN;

  --
  -- Procedure
  --   bc_ledger
  -- Purpose
  --   Returns the ledger to be used for budgetary control purposes
  -- History
  --   03-23-04	 D J Ogg 	Created
  -- Arguments
  --   X_je_batch_id		ID of journal batch
  -- Example
  --   lgr_id := gl_je_batches_pkg.bc_ledger(:BATCHES.je_batch_id)
  -- Notes
  --
  FUNCTION bc_ledger( X_je_batch_id  NUMBER ) RETURN NUMBER;

  --
  -- Procedure
  --   populate_fields
  -- Purpose
  --   Gets all of the data necessary post-query
  -- History
  --   27-JAN-04  D. J. Ogg    Created
  -- Arguments
  --   x_je_batch_id     	Journal batch id
  --   x_je_source_name  	Source Name of journals in batch
  --   frozen_source_flag      Freeze flag for journals in batch
  --   one_of_ledgers_in_batch  Ledger id of one of ledgers in the batch
  --   reversal_flag            Indicated whether this is a reversing journal
  PROCEDURE populate_fields(x_je_batch_id				NUMBER,
			    x_je_source_name		IN OUT NOCOPY	VARCHAR2,
			    frozen_source_flag		IN OUT NOCOPY	VARCHAR2,
			    one_of_ledgers_in_batch	IN OUT NOCOPY	NUMBER,
			    reversal_flag		IN OUT NOCOPY   VARCHAR2);

  --
  -- Procedure
  --   Insert_Row
  -- Purpose
  --   Insert a row in gl_je_batches
  -- History
  --   10-MAR-95  D. J. Ogg    Created
  -- Notes
  --
  PROCEDURE Insert_Row(X_Rowid                   IN OUT NOCOPY VARCHAR2,
                       X_Je_Batch_Id             IN OUT NOCOPY NUMBER,
                       X_Name                     	VARCHAR2,
                       X_Chart_of_Accounts_ID		NUMBER,
		       X_Period_Set_Name		VARCHAR2,
		       X_Accounted_Period_Type		VARCHAR2,
                       X_Status                   	VARCHAR2,
                       X_Budgetary_Control_Status 	VARCHAR2,
                       X_Approval_Status_Code           VARCHAR2,
                       X_Status_Verified          	VARCHAR2,
                       X_Actual_Flag              	VARCHAR2,
	               X_Default_Period_Name      	VARCHAR2,
                       X_Default_Effective_Date   	DATE,
                       X_Posted_Date             	DATE,
                       X_Date_Created             	DATE,
		       X_Control_Total                  IN OUT NOCOPY NUMBER,
		       X_Running_Total_Dr	  	IN OUT NOCOPY NUMBER,
		       X_Running_Total_Cr	  	IN OUT NOCOPY NUMBER,
		       X_Running_Total_Accounted_Dr	NUMBER,
		       X_Running_Total_Accounted_Cr	NUMBER,
                       X_Average_Journal_Flag           VARCHAR2,
		       X_Org_Id				NUMBER,
		       X_Posting_Run_Id		  	NUMBER,
		       X_Request_Id		  	NUMBER,
                       X_Packet_Id                	NUMBER,
                       X_Unreservation_Packet_Id  	NUMBER,
		       X_Creation_Date		  	DATE,
		       X_Created_By		  	NUMBER,
		       X_Last_Update_Date	  	DATE,
		       X_Last_Updated_By	  	NUMBER,
		       X_Last_Update_Login	  	NUMBER);


  --
  -- Procedure
  --   Update_Row
  -- Purpose
  --   Update a row in gl_je_batches
  -- History
  --   10-MAR-95  D. J. Ogg    Created
  -- Notes
  --
  PROCEDURE Update_Row(X_Rowid                    VARCHAR2,
                       X_Je_Batch_Id              NUMBER,
                       X_Name                     VARCHAR2,
                       X_Chart_of_Accounts_ID	  NUMBER,
		       X_Period_Set_Name	  VARCHAR2,
		       X_Accounted_Period_Type	  VARCHAR2,
                       X_Status                   VARCHAR2,
                       X_Budgetary_Control_Status VARCHAR2,
                       X_Approval_Status_Code     IN OUT NOCOPY VARCHAR2,
                       X_Status_Verified          VARCHAR2,
                       X_Actual_Flag              VARCHAR2,
	               X_Default_Period_Name      VARCHAR2,
                       X_Default_Effective_Date   DATE,
                       X_Posted_Date              DATE,
                       X_Date_Created             DATE,
		       X_Control_Total            IN OUT NOCOPY NUMBER,
		       X_Running_Total_Dr	  IN OUT NOCOPY NUMBER,
		       X_Running_Total_Cr	  IN OUT NOCOPY NUMBER,
                       X_Average_Journal_Flag     VARCHAR2,
 		       X_Posting_Run_Id		  NUMBER,
		       X_Request_Id		  NUMBER,
                       X_Packet_Id                NUMBER,
                       X_Unreservation_Packet_Id  NUMBER,
		       X_Last_Update_Date	  DATE,
		       X_Last_Updated_By	  NUMBER,
		       X_Last_Update_Login	  NUMBER,
                       Update_Effective_Date_Flag VARCHAR2,
		       Update_Approval_Stat_Flag  VARCHAR2);


  --
  -- Procedure
  --   Lock_Row
  -- Purpose
  --   Locks a row in gl_je_batches
  -- History
  --   13-JUL-94  D. J. Ogg    Created
  -- Notes
  --
  PROCEDURE Lock_Row(X_Rowid                    VARCHAR2,
                     X_Je_Batch_Id              NUMBER,
                     X_Name                     VARCHAR2,
                     X_Chart_of_Accounts_ID	NUMBER,
		     X_Period_Set_Name		VARCHAR2,
		     X_Accounted_Period_Type	VARCHAR2,
                     X_Status                   VARCHAR2,
                     X_Budgetary_Control_Status VARCHAR2,
                     X_Approval_Status_Code     VARCHAR2,
                     X_Status_Verified          VARCHAR2,
                     X_Actual_Flag              VARCHAR2,
	             X_Default_Period_Name      VARCHAR2,
                     X_Default_Effective_Date   DATE,
                     X_Posted_Date              DATE,
                     X_Date_Created             DATE,
		     X_Control_Total            NUMBER,
		     X_Running_Total_Dr	  	NUMBER,
		     X_Running_Total_Cr	  	NUMBER,
                     X_Average_Journal_Flag     VARCHAR2,
  		     X_Posting_Run_Id		NUMBER,
		     X_Request_Id		NUMBER,
                     X_Packet_Id                NUMBER,
                     X_Unreservation_Packet_Id  NUMBER,
	             X_Verify_Request_Completed VARCHAR2);


PROCEDURE Insert_Row(X_Rowid                         IN OUT NOCOPY VARCHAR2,

                     X_Je_Batch_Id                   IN OUT NOCOPY NUMBER,
                     X_Last_Update_Date                     DATE,
                     X_Last_Updated_By                      NUMBER,
                     X_Name                                 VARCHAR2,
                     X_Chart_of_Accounts_ID		    NUMBER,
		     X_Period_Set_Name		            VARCHAR2,
		     X_Accounted_Period_Type		    VARCHAR2,
                     X_Status                               VARCHAR2,
                     X_Status_Verified                      VARCHAR2,
                     X_Actual_Flag                          VARCHAR2,
                     X_Default_Effective_Date               DATE,
                     X_Creation_Date                        DATE,
                     X_Created_By                           NUMBER,
                     X_Last_Update_Login                    NUMBER,
                     X_Status_Reset_Flag                    VARCHAR2,
                     X_Default_Period_Name                  VARCHAR2,
                     X_Unique_Date                          VARCHAR2,
                     X_Earliest_Postable_Date               DATE,
                     X_Posted_Date                          DATE,
                     X_Date_Created                         DATE,
                     X_Description                          VARCHAR2,
                     X_Control_Total                        NUMBER,
                     X_Running_Total_Dr                     NUMBER,
                     X_Running_Total_Cr                     NUMBER,
                     X_Running_Total_Accounted_Dr           NUMBER,
                     X_Running_Total_Accounted_Cr           NUMBER,
                     X_Average_Journal_Flag                 VARCHAR2,
		     X_Org_Id				    NUMBER,
                     X_Attribute1                           VARCHAR2,
                     X_Attribute2                           VARCHAR2,
                     X_Attribute3                           VARCHAR2,
                     X_Attribute4                           VARCHAR2,
                     X_Attribute5                           VARCHAR2,
                     X_Attribute6                           VARCHAR2,
                     X_Attribute7                           VARCHAR2,
                     X_Attribute8                           VARCHAR2,
                     X_Attribute9                           VARCHAR2,
                     X_Attribute10                          VARCHAR2,
                     X_Context                              VARCHAR2,
                     X_Budgetary_Control_Status             VARCHAR2,
                     X_Approval_Status_Code                 VARCHAR2,
                     X_Posting_Run_Id                       NUMBER,
		     X_Request_Id			    NUMBER,
                     X_Packet_Id                            NUMBER,
                     X_Ussgl_Transaction_Code               VARCHAR2,
                     X_Context2                             VARCHAR2,
                     X_Unreservation_Packet_Id              NUMBER,
                     X_Global_Attribute_Category           VARCHAR2,
                     X_Global_Attribute1                   VARCHAR2,
                     X_Global_Attribute2                   VARCHAR2,
                     X_Global_Attribute3                   VARCHAR2,
                     X_Global_Attribute4                   VARCHAR2,
                     X_Global_Attribute5                   VARCHAR2,
                     X_Global_Attribute6                   VARCHAR2,
                     X_Global_Attribute7                   VARCHAR2,
                     X_Global_Attribute8                   VARCHAR2,
                     X_Global_Attribute9                   VARCHAR2,
                     X_Global_Attribute10                  VARCHAR2,
                     X_Global_Attribute11                  VARCHAR2,
                     X_Global_Attribute12                  VARCHAR2,
                     X_Global_Attribute13                  VARCHAR2,
                     X_Global_Attribute14                  VARCHAR2,
                     X_Global_Attribute15                  VARCHAR2,
                     X_Global_Attribute16                  VARCHAR2,
                     X_Global_Attribute17                  VARCHAR2,
                     X_Global_Attribute18                  VARCHAR2,
                     X_Global_Attribute19                  VARCHAR2,
                     X_Global_Attribute20                  VARCHAR2
                     );

PROCEDURE Lock_Row(X_Rowid                                  VARCHAR2,
                   X_Je_Batch_Id                            NUMBER,
                   X_Name                                   VARCHAR2,
                   X_Chart_of_Accounts_ID		    NUMBER,
		   X_Period_Set_Name			    VARCHAR2,
		   X_Accounted_Period_Type		    VARCHAR2,
                   X_Status                                 VARCHAR2,
                   X_Status_Verified                        VARCHAR2,
                   X_Actual_Flag                            VARCHAR2,
                   X_Default_Effective_Date                 DATE,
                   X_Status_Reset_Flag                      VARCHAR2,
                   X_Default_Period_Name                    VARCHAR2,
                   X_Unique_Date                            VARCHAR2,
                   X_Earliest_Postable_Date                 DATE,
                   X_Posted_Date                            DATE,
                   X_Date_Created                           DATE,
                   X_Description                            VARCHAR2,
                   X_Control_Total                          NUMBER,
                   X_Running_Total_Dr                       NUMBER,
                   X_Running_Total_Cr                       NUMBER,
                   X_Running_Total_Accounted_Dr             NUMBER,
                   X_Running_Total_Accounted_Cr             NUMBER,
                   X_Average_Journal_Flag                   VARCHAR2,
                   X_Attribute1                             VARCHAR2,
                   X_Attribute2                             VARCHAR2,
                   X_Attribute3                             VARCHAR2,
                   X_Attribute4                             VARCHAR2,
                   X_Attribute5                             VARCHAR2,
                   X_Attribute6                             VARCHAR2,
                   X_Attribute7                             VARCHAR2,
                   X_Attribute8                             VARCHAR2,
                   X_Attribute9                             VARCHAR2,
                   X_Attribute10                            VARCHAR2,
                   X_Context                                VARCHAR2,
                   X_Budgetary_Control_Status               VARCHAR2,
                   X_Approval_Status_Code                   VARCHAR2,
                   X_Posting_Run_Id                         NUMBER,
		   X_Request_Id				    NUMBER,
                   X_Packet_Id                              NUMBER,
                   X_Ussgl_Transaction_Code                 VARCHAR2,
                   X_Context2                               VARCHAR2,
                   X_Unreservation_Packet_Id                NUMBER,
		   X_Verify_Request_Completed               VARCHAR2,
                   X_Global_Attribute_Category             VARCHAR2,
                   X_Global_Attribute1                     VARCHAR2,
                   X_Global_Attribute2                     VARCHAR2,
                   X_Global_Attribute3                     VARCHAR2,
                   X_Global_Attribute4                     VARCHAR2,
                   X_Global_Attribute5                     VARCHAR2,
                   X_Global_Attribute6                     VARCHAR2,
                   X_Global_Attribute7                     VARCHAR2,
                   X_Global_Attribute8                     VARCHAR2,
                   X_Global_Attribute9                     VARCHAR2,
                   X_Global_Attribute10                    VARCHAR2,
                   X_Global_Attribute11                    VARCHAR2,
                   X_Global_Attribute12                    VARCHAR2,
                   X_Global_Attribute13                    VARCHAR2,
                   X_Global_Attribute14                    VARCHAR2,
                   X_Global_Attribute15                    VARCHAR2,
                   X_Global_Attribute16                    VARCHAR2,
                   X_Global_Attribute17                    VARCHAR2,
                   X_Global_Attribute18                    VARCHAR2,
                   X_Global_Attribute19                    VARCHAR2,
                   X_Global_Attribute20                    VARCHAR2
                   );

PROCEDURE Update_Row(X_Rowid                               VARCHAR2,
                     X_Je_Batch_Id                         NUMBER,
                     X_Last_Update_Date                    DATE,
                     X_Last_Updated_By                     NUMBER,
                     X_Name                                VARCHAR2,
                     X_Chart_of_Accounts_ID		   NUMBER,
		     X_Period_Set_Name			   VARCHAR2,
		     X_Accounted_Period_Type		   VARCHAR2,
                     X_Status                              VARCHAR2,
                     X_Status_Verified                     VARCHAR2,
                     X_Actual_Flag                         VARCHAR2,
                     X_Default_Effective_Date              DATE,
                     X_Last_Update_Login                   NUMBER,
                     X_Status_Reset_Flag                   VARCHAR2,
                     X_Default_Period_Name                 VARCHAR2,
                     X_Unique_Date                         VARCHAR2,
                     X_Earliest_Postable_Date              DATE,
                     X_Posted_Date                         DATE,
                     X_Date_Created                        DATE,
                     X_Description                         VARCHAR2,
                     X_Control_Total                       NUMBER,
                     X_Running_Total_Dr                    NUMBER,
                     X_Running_Total_Cr                    NUMBER,
                     X_Running_Total_Accounted_Dr          NUMBER,
                     X_Running_Total_Accounted_Cr          NUMBER,
                     X_Average_Journal_Flag                VARCHAR2,
                     X_Attribute1                          VARCHAR2,
                     X_Attribute2                          VARCHAR2,
                     X_Attribute3                          VARCHAR2,
                     X_Attribute4                          VARCHAR2,
                     X_Attribute5                          VARCHAR2,
                     X_Attribute6                          VARCHAR2,
                     X_Attribute7                          VARCHAR2,
                     X_Attribute8                          VARCHAR2,
                     X_Attribute9                          VARCHAR2,
                     X_Attribute10                         VARCHAR2,
                     X_Context                             VARCHAR2,
                     X_Budgetary_Control_Status            VARCHAR2,
                     X_Approval_Status_Code                IN OUT NOCOPY VARCHAR2,
                     X_Posting_Run_Id                      NUMBER,
		     X_Request_Id			   NUMBER,
                     X_Packet_Id                           NUMBER,
                     X_Ussgl_Transaction_Code              VARCHAR2,
                     X_Context2                            VARCHAR2,
                     X_Unreservation_Packet_Id             NUMBER,
                     Update_Effective_Date_Flag    	   VARCHAR2,
		     Update_Approval_Stat_Flag             VARCHAR2,
                     X_Global_Attribute_Category           VARCHAR2,
                     X_Global_Attribute1                   VARCHAR2,
                     X_Global_Attribute2                   VARCHAR2,
                     X_Global_Attribute3                   VARCHAR2,
                     X_Global_Attribute4                   VARCHAR2,
                     X_Global_Attribute5                   VARCHAR2,
                     X_Global_Attribute6                   VARCHAR2,
                     X_Global_Attribute7                   VARCHAR2,
                     X_Global_Attribute8                   VARCHAR2,
                     X_Global_Attribute9                   VARCHAR2,
                     X_Global_Attribute10                  VARCHAR2,
                     X_Global_Attribute11                  VARCHAR2,
                     X_Global_Attribute12                  VARCHAR2,
                     X_Global_Attribute13                  VARCHAR2,
                     X_Global_Attribute14                  VARCHAR2,
                     X_Global_Attribute15                  VARCHAR2,
                     X_Global_Attribute16                  VARCHAR2,
                     X_Global_Attribute17                  VARCHAR2,
                     X_Global_Attribute18                  VARCHAR2,
                     X_Global_Attribute19                  VARCHAR2,
                     X_Global_Attribute20                  VARCHAR2
                     );

-- This exception occurs when you try to delete
-- a batch for which funds are currently being
-- reserved.
GL_MJE_RESERVING_FUNDS   EXCEPTION;

-- This exception occurs when you try to delete
-- a batch for which funds have been reserved
GL_MJE_RESERVED_FUNDS   EXCEPTION;

-- This exception occurs when you try to delete
-- a batch that is currently being approved.
GL_MJE_APPROVING         EXCEPTION;

-- This exception occurs when you try to delete
-- a batch that has been posted.
GL_MJE_POSTED            EXCEPTION;

-- This exception occurs when you try to delete
-- a batch that is in the process of being
-- posted.
GL_MJE_POSTING           EXCEPTION;

PROCEDURE Delete_Row(X_Rowid VARCHAR2, Je_Batch_Id NUMBER);

END gl_je_batches_pkg;

 

/
