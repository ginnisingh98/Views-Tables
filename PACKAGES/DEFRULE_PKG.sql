--------------------------------------------------------
--  DDL for Package DEFRULE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."DEFRULE_PKG" AUTHID CURRENT_USER AS
/* $Header: OEXVDRLS.pls 120.0 2005/05/31 22:31:43 appldev noship $ */

   PROCEDURE Insert_Row(
      p_rowid 		in out NOCOPY /* file.sql.39 change */  varchar2
     ,p_condition_id	in	  number
     ,p_attr_def_condition_id	in	NUMBER
     ,p_attr_def_rule_id	in  out NOCOPY /* file.sql.39 change */	NUMBER
     ,p_sequence_no	in	NUMBER
     ,p_database_object_name 	in	VARCHAR2
     ,p_attribute_code 	in	VARCHAR2
    ,p_src_type 	in	VARCHAR2
    ,p_src_api_pkg 	in	VARCHAR2
    ,p_src_api_fn 	in	VARCHAR2
    ,p_src_profile_option 	in	VARCHAR2
    ,p_src_constant_value 	in	VARCHAR2
    ,p_src_system_variable_expr 	in	VARCHAR2
    ,p_src_parameter_name 	in	VARCHAR2
    ,p_src_foreign_key_name 	in	VARCHAR2
    ,p_src_database_object_name 	in	VARCHAR2
    ,p_src_attribute_code 	in	VARCHAR2
    ,p_src_sequence_name        in	VARCHAR2
    ,p_system_flag	in	VARCHAR2
    ,p_permanent_flag 		in VARCHAR2
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
      p_rowid 		in out NOCOPY /* file.sql.39 change */  varchar2
     ,p_condition_id	in	  number
     ,p_attr_def_condition_id	in	NUMBER
     ,p_attr_def_rule_id	in	NUMBER
     ,p_sequence_no	in	NUMBER
     ,p_database_object_name 	in	VARCHAR2
     ,p_attribute_code 	in	VARCHAR2
    ,p_src_type 	in	VARCHAR2
    ,p_src_api_pkg 	in	VARCHAR2
    ,p_src_api_fn 	in	VARCHAR2
    ,p_src_profile_option 	in	VARCHAR2
    ,p_src_constant_value 	in	VARCHAR2
    ,p_src_system_variable_expr 	in	VARCHAR2
    ,p_src_parameter_name 	in	VARCHAR2
    ,p_src_foreign_key_name 	in	VARCHAR2
    ,p_src_database_object_name 	in	VARCHAR2
    ,p_src_attribute_code 	in	VARCHAR2
    ,p_src_sequence_name	in      VARCHAR2
    ,p_system_flag	        in	VARCHAR2
    ,p_permanent_flag 		in VARCHAR2
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

   PROCEDURE Lock_Row(
      p_rowid 		in out NOCOPY /* file.sql.39 change */  varchar2
     ,p_condition_id	in	  number
     ,p_attr_def_condition_id	in	NUMBER
     ,p_attr_def_rule_id	in	NUMBER
     ,p_sequence_no	in	NUMBER
     ,p_database_object_name 	in	VARCHAR2
     ,p_attribute_code 	in	VARCHAR2
    ,p_src_type 	in	VARCHAR2
    ,p_src_api_pkg 	in	VARCHAR2
    ,p_src_api_fn 	in	VARCHAR2
    ,p_src_profile_option 	in	VARCHAR2
    ,p_src_constant_value 	in	VARCHAR2
    ,p_src_system_variable_expr 	in	VARCHAR2
    ,p_src_parameter_name 	in	VARCHAR2
    ,p_src_foreign_key_name 	in	VARCHAR2
    ,p_src_database_object_name 	in	VARCHAR2
    ,p_src_attribute_code 	in	VARCHAR2
    ,p_src_sequence_name	in	VARCHAR2
    ,p_system_flag	in	VARCHAR2
    ,p_permanent_flag 		in VARCHAR2
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


   PROCEDURE Delete_Row(p_Rowid     IN VARCHAR2,
		     p_system_flag in varchar2,
		     p_permanent_flag in varchar2);


   Function check_Unique(p_attr_def_condition_id in NUMBER,
				    p_database_object_name in VARCHAR2,
				    p_attribute_code in VARCHAR2,
				    p_sequence_no in NUMBER) RETURN BOOLEAN;

END DEFRULE_pkg;

 

/
