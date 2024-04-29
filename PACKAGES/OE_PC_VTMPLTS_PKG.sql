--------------------------------------------------------
--  DDL for Package OE_PC_VTMPLTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_PC_VTMPLTS_PKG" AUTHID CURRENT_USER AS
/* $Header: OEXPCVTS.pls 115.5 2003/10/20 07:06:05 appldev ship $ */

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
      x_rowid    				in out nocopy varchar2
      ,x_validation_tmplt_id 		in out nocopy number
      ,x_entity_id                  in      number
      ,x_display_name			in      varchar2
      ,x_description  			in      varchar2
      ,x_validation_tmplt_short_name in     varchar2
      ,x_validation_type       	in      varchar2
      ,x_system_flag	        	in      varchar2
      ,x_created_by       	 	in      number
      ,x_creation_date       		in      date
      ,x_last_updated_by 	    	in      number
      ,x_last_update_date        	in      date
      ,x_last_update_login       	in      number
      ,x_wf_item_type                   in      varchar2
      ,x_activity_name			in      varchar2
      ,x_activity_status_code		in      varchar2
      ,x_activity_result_code		in      varchar2
      ,x_api_pkg				in      varchar2
      ,x_api_proc				in      varchar2
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
      ,x_validation_tmplt_id 		in      number
      ,x_entity_id                  in      number
      ,x_display_name 			in      varchar2
      ,x_description  			in      varchar2
      ,x_validation_tmplt_short_name in     varchar2
      ,x_validation_type       	in      varchar2
      ,x_system_flag	        	in      varchar2
      ,x_created_by       	 	in      number
      ,x_creation_date       		in      date
      ,x_last_updated_by 	    	in      number
      ,x_last_update_date        	in      date
      ,x_last_update_login       	in      number
      ,x_wf_item_type                   in      varchar2
      ,x_activity_name			in      varchar2
      ,x_activity_status_code		in      varchar2
      ,x_activity_result_code		in      varchar2
      ,x_api_pkg				in      varchar2
      ,x_api_proc				in      varchar2
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
      ,x_validation_tmplt_id 		in      number
      ,x_entity_id                  in      number
      ,x_display_name 			in   	  varchar2
      ,x_description  			in      varchar2
      ,x_validation_tmplt_short_name in     varchar2
      ,x_validation_type       	in      varchar2
      ,x_system_flag	        	in      varchar2
      ,x_created_by       	 	in      number
      ,x_creation_date       		in      date
      ,x_last_updated_by 	    	in      number
      ,x_last_update_date        	in      date
      ,x_last_update_login       	in      number
      ,x_wf_item_type                   in      varchar2
      ,x_activity_name			in      varchar2
      ,x_activity_status_code		in      varchar2
      ,x_activity_result_code		in      varchar2
      ,x_api_pkg				in      varchar2
      ,x_api_proc				in      varchar2
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
      x_validation_tmplt_id 		in      number
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
--  API name    Check_Reference
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
      x_validation_tmplt_id 		in      number
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
      x_rowid					in 	  varchar2
      ,x_entity_id				in      number
      ,x_display_name				in      varchar2
      ,x_validation_tmplt_short_name	in      varchar2
      ,x_validation_unit			in      varchar2
   );

   PROCEDURE Translate_Row(
      x_validation_tmplt_id 			in	   varchar2
	 ,x_owner					in 	   varchar2
      ,x_display_name	in      varchar2
      ,x_description	in      varchar2
	 );

   PROCEDURE Load_Row(
       x_validation_tmplt_id 			in      varchar2
      ,x_owner					in	   varchar2
      ,x_display_name	in      varchar2
      ,x_description	in      varchar2
      ,x_entity_id                  in     varchar2
      ,x_validation_tmplt_short_name 	in      varchar2
	 ,x_validation_type			in	   varchar2
	 ,x_activity_name		     in		varchar2
	 ,x_activity_status_code		in		varchar2
	 ,x_activity_result_code		in		varchar2
	 ,x_api_pkg				in		varchar2
	 ,x_api_proc				in		varchar2
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
      ,x_wf_item_type           in      varchar2
   );

End OE_PC_VTMPLTS_PKG;

 

/
