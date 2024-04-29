--------------------------------------------------------
--  DDL for Package DEFCONDN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."DEFCONDN_PKG" AUTHID CURRENT_USER AS
/* $Header: OEXVDCDS.pls 120.0 2005/06/01 01:37:13 appldev noship $ */

   FUNCTION Check_References(p_condition_id in NUMBER) RETURN BOOLEAN;

   PROCEDURE Insert_Row(
      p_rowid    				in out NOCOPY /* file.sql.39 change */  varchar2
      ,p_condition_id 			in out NOCOPY /* file.sql.39 change */  number
      ,p_display_name			in      varchar2
      ,p_description			in      varchar2
      ,p_database_object_name		in      varchar2
      ,p_number_of_elements		in     number
      ,p_system_flag	        	in      varchar2
      ,p_created_by       	 	in      number
      ,p_creation_date       		in      date
      ,p_last_updated_by 	    	in      number
      ,p_last_update_date        	in      date
      ,p_last_update_login       	in      number
      ,p_attribute_category       	in      varchar2
      ,p_attribute1	       	in      varchar2
      ,p_attribute2	       	in      varchar2
      ,p_attribute3	       	in      varchar2
      ,p_attribute4	       	in      varchar2
      ,p_attribute5	       	in      varchar2
      ,p_attribute6	       	in      varchar2
      ,p_attribute7	       	in      varchar2
      ,p_attribute8	       	in      varchar2
      ,p_attribute9	       	in      varchar2
      ,p_attribute10	       	in      varchar2
      ,p_attribute11	       	in      varchar2
      ,p_attribute12	       	in      varchar2
      ,p_attribute13	       	in      varchar2
      ,p_attribute14	       	in      varchar2
      ,p_attribute15	       	in      varchar2
   );


   PROCEDURE Update_Row(
      p_rowid    				in      varchar2
      ,p_condition_id 			in   number
      ,p_display_name			in      varchar2
      ,p_description			in      varchar2
      ,p_database_object_name		in      varchar2
      ,p_number_of_elements		in     number
      ,p_system_flag	        	in      varchar2
      ,p_created_by       	 	in      number
      ,p_creation_date       		in      date
      ,p_last_updated_by 	    	in      number
      ,p_last_update_date        	in      date
      ,p_last_update_login       	in      number
      ,p_attribute_category       	in      varchar2
      ,p_attribute1	       	in      varchar2
      ,p_attribute2	       	in      varchar2
      ,p_attribute3	       	in      varchar2
      ,p_attribute4	       	in      varchar2
      ,p_attribute5	       	in      varchar2
      ,p_attribute6	       	in      varchar2
      ,p_attribute7	       	in      varchar2
      ,p_attribute8	       	in      varchar2
      ,p_attribute9	       	in      varchar2
      ,p_attribute10	       	in      varchar2
      ,p_attribute11	       	in      varchar2
      ,p_attribute12	       	in      varchar2
      ,p_attribute13	       	in      varchar2
      ,p_attribute14	       	in      varchar2
      ,p_attribute15	       	in      varchar2
   );

  PROCEDURE Delete_Row(p_Rowid	 IN VARCHAR2,
				p_system_flag in VARCHAR2);


   PROCEDURE Lock_Row(
      p_rowid    				in      varchar2
      ,p_condition_id 			in   number
      ,p_display_name			in      varchar2
      ,p_description			in      varchar2
      ,p_database_object_name		in      varchar2
      ,p_number_of_elements		in     number
      ,p_system_flag	        	in      varchar2
      ,p_created_by       	 	in      number
      ,p_creation_date       		in      date
      ,p_last_updated_by 	    	in      number
      ,p_last_update_date        	in      date
      ,p_last_update_login       	in      number
      ,p_attribute_category       	in      varchar2
      ,p_attribute1	       	in      varchar2
      ,p_attribute2	       	in      varchar2
      ,p_attribute3	       	in      varchar2
      ,p_attribute4	       	in      varchar2
      ,p_attribute5	       	in      varchar2
      ,p_attribute6	       	in      varchar2
      ,p_attribute7	       	in      varchar2
      ,p_attribute8	       	in      varchar2
      ,p_attribute9	       	in      varchar2
      ,p_attribute10	       	in      varchar2
      ,p_attribute11	       	in      varchar2
      ,p_attribute12	       	in      varchar2
      ,p_attribute13	       	in      varchar2
      ,p_attribute14	       	in      varchar2
      ,p_attribute15	       	in      varchar2
   );


	FUNCTION Check_Unique( p_rowid in varchar2,
				p_display_name IN VARCHAR2,
		       	        p_database_object_name IN VARCHAR2)
	  RETURN BOOLEAN;

	procedure TRANSLATE_ROW (
	 p_condition_id                 in      VARCHAR2,
	 p_database_object_name		  in		VARCHAR2,
	 p_owner					  in		VARCHAR2,
	 p_display_name                 in      VARCHAR2,
	 p_description                  in      VARCHAR2);

	procedure LOAD_ROW (
      p_condition_id 			in 	  varchar2
	 ,p_owner					  in		VARCHAR2
      ,p_display_name			in      varchar2
      ,p_description			in      varchar2
      ,p_database_object_name		in      varchar2
      ,p_number_of_elements		in      varchar2
      ,p_system_flag	        	in      varchar2
      ,p_attribute_category       	in      varchar2
      ,p_attribute1	       	in      varchar2
      ,p_attribute2	       	in      varchar2
      ,p_attribute3	       	in      varchar2
      ,p_attribute4	       	in      varchar2
      ,p_attribute5	       	in      varchar2
      ,p_attribute6	       	in      varchar2
      ,p_attribute7	       	in      varchar2
      ,p_attribute8	       	in      varchar2
      ,p_attribute9	       	in      varchar2
      ,p_attribute10	       	in      varchar2
      ,p_attribute11	       	in      varchar2
      ,p_attribute12	       	in      varchar2
      ,p_attribute13	       	in      varchar2
      ,p_attribute14	       	in      varchar2
      ,p_attribute15	       	in      varchar2);

	 procedure ADD_LANGUAGE;

END DEFCONDN_pkg;

 

/
