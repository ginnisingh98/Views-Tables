--------------------------------------------------------
--  DDL for Package FA_RX_REPORTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_RX_REPORTS_PKG" AUTHID CURRENT_USER as
/* $Header: faxrxdms.pls 120.5.12010000.2 2009/07/19 13:12:31 glchen ship $ */

  PROCEDURE Insert_Row(X_Rowid                   IN OUT NOCOPY VARCHAR2,
		       X_Report_Id                      NUMBER   default null,
                       X_Application_Id                 NUMBER   default null,
                       X_Responsibility_Id              NUMBER   default null,
                       X_Concurrent_Program_Id          NUMBER   default null,
		       X_Concurrent_Program_Name	VARCHAR2 default null,
                       X_Interface_Table                VARCHAR2 default null,
                       X_Concurrent_Program_Flag	VARCHAR2 default null,
                       X_Select_Program_Name		VARCHAR2 default null,
                       X_Last_Update_Date               DATE     default null,
                       X_Last_Updated_By                NUMBER   default null,
                       X_Created_By                     NUMBER   default NULL,
                       X_Creation_Date                  DATE     default NULL,
                       X_Last_Update_Login              NUMBER   default NULL,
		       X_Where_Clause_API		VARCHAR2 default null,
                       X_Purge_API			VARCHAR2 default null,
                       X_Calling_Fn			VARCHAR2
                      );


PROCEDURE Lock_Row(X_Rowid			IN OUT NOCOPY  VARCHAR2,
                   X_Report_Id                          NUMBER   default null,
                   X_Application_Id                     NUMBER   default null,
		   X_Responsibility_Id			NUMBER   default null,
                   X_Concurrent_Program_Id              NUMBER   default null,
		   X_Concurrent_Program_Flag		VARCHAR2 default null,
		   X_Select_Program_Name		VARCHAR2 default null,
                   X_Interface_Table                    VARCHAR2 default null,
		   X_Where_Clause_API			VARCHAR2 default null,
                   X_Purge_API				VARCHAR2 default null,
	           X_Calling_Fn			        VARCHAR2
		  );

  PROCEDURE Update_Row(X_Rowid                          VARCHAR2,
	  	       X_Report_Id                      NUMBER   default null,
                       X_Application_Id                 NUMBER   default null,
                       X_Responsibility_Id		NUMBER   default null,
                       X_Concurrent_Program_Id          NUMBER   default null,
		       X_Concurrent_Program_Name	VARCHAR2 default null,
                       X_Interface_Table                VARCHAR2 default null,
                       X_Concurrent_Program_Flag	VARCHAR2 default null,
                       X_Select_Program_Name		VARCHAR2 default null,
                       X_Last_Update_Date               DATE     default null,
                       X_Last_Updated_By                NUMBER   default null,
                       X_Last_Update_Login              NUMBER   default null,
                       X_Where_Clause_API		VARCHAR2 default null,
                       X_Purge_API			VARCHAR2 default null,
		       X_Calling_Fn			VARCHAR2
                      );

  PROCEDURE Delete_Row(X_Rowid 				VARCHAR2 default null,
                       X_Report_Id			NUMBER,
                       X_Calling_Fn			VARCHAR2
                      );

--* overloaded procedure
--*
  PROCEDURE Load_Row(
                   X_Report_Id                          NUMBER   default null,
                   X_Application_Name                   VARCHAR2 default null,
		   X_Responsibility_Id			NUMBER   default null,
                   X_Concurrent_Program_Name            VARCHAR2 default null,
		   X_Concurrent_Program_Flag		VARCHAR2 default null,
		   X_Select_Program_Name		VARCHAR2 default null,
                   X_Interface_Table                    VARCHAR2 default null,
		   X_Where_Clause_API			VARCHAR2 default null,
                   X_Purge_API				VARCHAR2 default null,
		   X_Owner                              VARCHAR2 default 'SEED',
		   X_Last_Update_Date                   VARCHAR2,
		   X_CUSTOM_MODE in VARCHAR2
                     );

  PROCEDURE Load_Row(
                   X_Report_Id                          NUMBER   default null,
                   X_Application_Name                   VARCHAR2 default null,
		   X_Responsibility_Id			NUMBER   default null,
                   X_Concurrent_Program_Name            VARCHAR2 default null,
		   X_Concurrent_Program_Flag		VARCHAR2 default null,
		   X_Select_Program_Name		VARCHAR2 default null,
                   X_Interface_Table                    VARCHAR2 default null,
		   X_Where_Clause_API			VARCHAR2 default null,
                   X_Purge_API				VARCHAR2 default null,
		   X_Owner                              VARCHAR2 default 'SEED'
                     );

  FUNCTION validate_plsql_block(p_plsql VARCHAR2) return BOOLEAN ;

END FA_RX_REPORTS_PKG;

/
