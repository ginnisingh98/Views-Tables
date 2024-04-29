--------------------------------------------------------
--  DDL for Package OE_PC_RSETS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_PC_RSETS_PKG" AUTHID CURRENT_USER AS
/* $Header: OEXPCRDS.pls 120.0 2005/05/31 23:03:22 appldev noship $ */

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
      ,x_record_set_id 			in out NOCOPY /* file.sql.39 change */  number
      ,x_entity_id                  in      number
      ,x_record_set_short_name 	in      varchar2
      ,x_pk_record_set_flag       	in      varchar2
      ,x_record_set_display_name	in      varchar2
      ,x_record_set_description	in      varchar2
      ,x_system_flag	        	in      varchar2
      ,x_created_by       	 	in      number
      ,x_creation_date       		in      date
      ,x_last_updated_by 	    	in      number
      ,x_last_update_date        	in      date
      ,x_last_update_login       	in      number
      ,x_attribute_category       	in      varchar2
      ,x_attribute1	       	in      varchar2
      ,x_attribute2	       	in      varchar2
      ,x_attribute3	       	in      varchar2
      ,x_attribute4	       	in      varchar2
      ,x_attribute5	       	in      varchar2
      ,x_attribute6	       	in      varchar2
      ,x_attribute7	       	in      varchar2
      ,x_attribute8	       	in      varchar2
      ,x_attribute9	       	in      varchar2
      ,x_attribute10	       	in      varchar2
      ,x_attribute11	       	in      varchar2
      ,x_attribute12	       	in      varchar2
      ,x_attribute13	       	in      varchar2
      ,x_attribute14	       	in      varchar2
      ,x_attribute15	       	in      varchar2
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
      ,x_entity_id                  in      number
      ,x_record_set_short_name 	in      varchar2
      ,x_pk_record_set_flag       	in      varchar2
      ,x_record_set_display_name	in      varchar2
      ,x_record_set_description	in      varchar2
      ,x_system_flag	        	in      varchar2
      ,x_created_by       	 	in      number
      ,x_creation_date       		in      date
      ,x_last_updated_by 	    	in      number
      ,x_last_update_date        	in      date
      ,x_last_update_login       	in      number
      ,x_attribute_category       	in      varchar2
      ,x_attribute1	       	in      varchar2
      ,x_attribute2	       	in      varchar2
      ,x_attribute3	       	in      varchar2
      ,x_attribute4	       	in      varchar2
      ,x_attribute5	       	in      varchar2
      ,x_attribute6	       	in      varchar2
      ,x_attribute7	       	in      varchar2
      ,x_attribute8	       	in      varchar2
      ,x_attribute9	       	in      varchar2
      ,x_attribute10	       	in      varchar2
      ,x_attribute11	       	in      varchar2
      ,x_attribute12	       	in      varchar2
      ,x_attribute13	       	in      varchar2
      ,x_attribute14	       	in      varchar2
      ,x_attribute15	       	in      varchar2
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
      ,x_entity_id                  in      number
      ,x_record_set_short_name 	in      varchar2
      ,x_pk_record_set_flag       	in      varchar2
      ,x_record_set_display_name	in      varchar2
      ,x_record_set_description	in      varchar2
      ,x_system_flag	        	in      varchar2
      ,x_created_by       	 	in      number
      ,x_creation_date       		in      date
      ,x_last_updated_by 	    	in      number
      ,x_last_update_date        	in      date
      ,x_last_update_login       	in      number
      ,x_attribute_category       	in      varchar2
      ,x_attribute1	       	in      varchar2
      ,x_attribute2	       	in      varchar2
      ,x_attribute3	       	in      varchar2
      ,x_attribute4	       	in      varchar2
      ,x_attribute5	       	in      varchar2
      ,x_attribute6	       	in      varchar2
      ,x_attribute7	       	in      varchar2
      ,x_attribute8	       	in      varchar2
      ,x_attribute9	       	in      varchar2
      ,x_attribute10	       	in      varchar2
      ,x_attribute11	       	in      varchar2
      ,x_attribute12	       	in      varchar2
      ,x_attribute13	       	in      varchar2
      ,x_attribute14	       	in      varchar2
      ,x_attribute15	       	in      varchar2
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
      x_record_set_id   		in      number
   );

   ----------------------------------------------------
--  Start of Comments
--  API name    Add_Language
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

   PROCEDURE Add_Language;

   ----------------------------------------------------
--  Start of Comments
--  API name    Check_References
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

   PROCEDURE Check_References(
      x_record_set_id 			in      number
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

   PROCEDURE Check_Unique(
      x_rowid				in 	  varchar2
      ,x_entity_id			in      number
      ,x_record_set_display_name	in      varchar2
      ,x_record_set_short_name	in      varchar2
      ,x_pk_record_set_flag		in      varchar2
      ,x_validation_unit		in	  varchar2
   );

   PROCEDURE Translate_Row(
      x_record_set_id 			in	   varchar2
	 ,x_owner					in 	   varchar2
      ,x_record_set_display_name	in      varchar2
      ,x_record_set_description	in      varchar2
	 );

   PROCEDURE Load_Row(
       x_record_set_id 			in      varchar2
      ,x_owner					in	   varchar2
      ,x_record_set_display_name	in      varchar2
      ,x_record_set_description	in      varchar2
      ,x_entity_id                  in     varchar2
      ,x_record_set_short_name 	in      varchar2
      ,x_pk_record_set_flag       	in      varchar2
      ,x_system_flag	        	in      varchar2
      ,x_attribute_category       	in      varchar2
      ,x_attribute1	       	in      varchar2
      ,x_attribute2	       	in      varchar2
      ,x_attribute3	       	in      varchar2
      ,x_attribute4	       	in      varchar2
      ,x_attribute5	       	in      varchar2
      ,x_attribute6	       	in      varchar2
      ,x_attribute7	       	in      varchar2
      ,x_attribute8	       	in      varchar2
      ,x_attribute9	       	in      varchar2
      ,x_attribute10	       	in      varchar2
      ,x_attribute11	       	in      varchar2
      ,x_attribute12	       	in      varchar2
      ,x_attribute13	       	in      varchar2
      ,x_attribute14	       	in      varchar2
      ,x_attribute15	       	in      varchar2
   );

End OE_PC_RSETS_PKG;

 

/
