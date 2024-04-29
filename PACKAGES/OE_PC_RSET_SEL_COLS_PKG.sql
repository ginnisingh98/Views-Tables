--------------------------------------------------------
--  DDL for Package OE_PC_RSET_SEL_COLS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_PC_RSET_SEL_COLS_PKG" AUTHID CURRENT_USER AS
/* $Header: OEXPCRSS.pls 120.0 2005/06/01 01:36:39 appldev noship $ */

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
      ,x_record_set_id 			in      number
      ,x_column_name                in      varchar2
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
      ,x_record_set_id 			in      number
      ,x_column_name                in      varchar2
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
      ,x_record_set_id 			in      number
      ,x_column_name                in      varchar2
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
   ---------------------------------------------------
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

   PROCEDURE Check_Unique(
      x_rowid    			in      varchar2
      ,x_record_Set_id		in	  number
      ,x_column_name		in 	  varchar2
   );
   ----------------------------------------------------

End OE_PC_RSET_SEL_COLS_PKG;

 

/
