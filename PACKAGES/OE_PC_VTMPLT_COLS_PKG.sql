--------------------------------------------------------
--  DDL for Package OE_PC_VTMPLT_COLS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_PC_VTMPLT_COLS_PKG" AUTHID CURRENT_USER AS
/* $Header: OEXPCVCS.pls 120.0 2005/06/01 00:55:10 appldev noship $ */

--  Start of Comments
--  API name    Insert_Row
--  Type        Private
--  Function
--
--  Pre-reqs
--
--  Parameters
--
--  Version     Current version = 1.0
--              Initial version = 1.0
--
--  Notes
--
--  End of Comments


   PROCEDURE Insert_Row(
      x_rowid    				in out NOCOPY /* file.sql.39 change */  varchar2
	 ,x_validation_tmplt_col_id   in out NOCOPY /* file.sql.39 change */  number
      ,x_validation_tmplt_id 		in      number
      ,x_column_name                in      varchar2
      ,x_validation_op              in      varchar2
      ,x_value_string          	in      varchar2
      ,x_created_by       	 	in      number
      ,x_creation_date       		in      date
      ,x_last_updated_by 	    	in      number
      ,x_last_update_date        	in      date
      ,x_last_update_login       	in      number
   );

   ---------------------------------------------------

--  Start of Comments
--  API name    Lock_Row
--  Type        Private
--  Function
--
--  Pre-reqs
--
--  Parameters
--
--  Version     Current version = 1.0
--              Initial version = 1.0
--
--  Notes
--
--  End of Comments


   PROCEDURE Lock_Row(
      x_rowid    				in      varchar2
	 ,x_validation_tmplt_col_id   in 	   number
      ,x_validation_tmplt_id 		in      number
      ,x_column_name                in      varchar2
      ,x_validation_op              in      varchar2
      ,x_value_string          	in      varchar2
      ,x_created_by       	 	in      number
      ,x_creation_date       		in      date
      ,x_last_updated_by 	    	in      number
      ,x_last_update_date        	in      date
      ,x_last_update_login       	in      number
   );

   ---------------------------------------------------
--  Start of Comments
--  API name    Update_Row
--  Type        Private
--  Function
--
--  Pre-reqs
--
--  Parameters
--
--  Version     Current version = 1.0
--              Initial version = 1.0
--
--  Notes
--
--  End of Comments


   PROCEDURE Update_Row(
      x_rowid    				in      varchar2
	 ,x_validation_tmplt_col_id   in 	   number
      ,x_validation_tmplt_id 		in      number
      ,x_column_name                in      varchar2
      ,x_validation_op              in      varchar2
      ,x_value_string          	in      varchar2
      ,x_created_by       	 	in      number
      ,x_creation_date       		in      date
      ,x_last_updated_by 	    	in      number
      ,x_last_update_date        	in      date
      ,x_last_update_login       	in      number
   );
   ---------------------------------------------------
--  Start of Comments
--  API name    Delete_Row
--  Type        Private
--  Function
--
--  Pre-reqs
--
--  Parameters
--
--  Version     Current version = 1.0
--              Initial version = 1.0
--
--  Notes
--
--  End of Comments


   PROCEDURE Delete_Row(
      x_rowid    			in      varchar2
   );

   ----------------------------------------------------
--  Start of Comments
--  API name    Check_Unique
--  Type        Private
--  Function
--
--  Pre-reqs
--
--  Parameters
--
--  Version     Current version = 1.0
--              Initial version = 1.0
--
--  Notes
--
--  End of Comments
--  Added 2 parameters to fix #2050546 to include column_name,validation_op and
--  value_string to check for the unique

   PROCEDURE Check_Unique(
       x_rowid					in     varchar2
      ,x_validation_tmplt_id			in     number
      ,x_column_name				in     varchar2
      ,x_validation_op                          in     varchar2
      ,x_value_string                           in     varchar2
   );

End OE_PC_VTMPLT_COLS_PKG;

 

/
