--------------------------------------------------------
--  DDL for Package DEFCONDNRULE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."DEFCONDNRULE_PKG" AUTHID CURRENT_USER AS
/* $Header: OEXVDCRS.pls 120.0 2005/06/04 11:12:54 appldev noship $ */

   PROCEDURE Insert_Row(
       p_rowid    				in out NOCOPY /* file.sql.39 change */  varchar2
      ,p_attr_def_condition_id 			in out NOCOPY /* file.sql.39 change */  number
      ,p_condition_id 			in   number
      ,p_precedence 			in   number
      ,p_database_object_name		in      varchar2
      ,p_attribute_code	        	in      varchar2
      ,p_created_by       	 	in      number
      ,p_creation_date       		in      date
      ,p_last_updated_by 	    	in      number
      ,p_last_update_date        	in      date
      ,p_last_update_login       	in      number
      ,p_system_flag       	in      varchar2
      ,p_enabled_flag       	in      varchar2
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
      p_rowid    				in   varchar2
      ,p_attr_def_condition_id 			in   number
      ,p_condition_id 			in   number
      ,p_precedence 			in   number
      ,p_database_object_name		in      varchar2
      ,p_attribute_code	        	in      varchar2
      ,p_enabled_flag	        	in      varchar2
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
			     p_attr_def_condition_id NUMBER);

   PROCEDURE Lock_Row(
      p_rowid    				in out NOCOPY /* file.sql.39 change */  varchar2
      ,p_attr_def_condition_id 			in out NOCOPY /* file.sql.39 change */  number
      ,p_condition_id 			in   number
      ,p_precedence 			in   number
      ,p_database_object_name		in      varchar2
      ,p_attribute_code	        	in      varchar2
      ,p_enabled_flag	        	in      varchar2
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

	FUNCTION Check_References(p_attr_def_condition_id NUMBER) RETURN BOOLEAN;

	PROCEDURE Check_Unique(p_rowid VARCHAR2,
	        		p_database_object_name VARCHAR2,
			        p_attribute_code VARCHAR2,
				p_condition_id NUMBER);
END DEFCONDNRULE_pkg;

 

/
