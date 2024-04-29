--------------------------------------------------------
--  DDL for Package DEFELEMENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."DEFELEMENTS_PKG" AUTHID CURRENT_USER AS
/* $Header: OEXVDELS.pls 120.0 2005/06/01 00:49:34 appldev noship $ */

-------------------------------------------------------------------
   PROCEDURE Insert_Row(
-------------------------------------------------------------------
       p_condition_id 			in   number
      ,p_group_number 			in   number
      ,p_attribute_code	       	in      varchar2
      ,p_value_op	       	in      varchar2
      ,p_value_string	       	in      varchar2
      ,p_system_flag	       	in      varchar2
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
      ,p_condition_element_id      in      number
,x_rowid out nocopy varchar2

	 );


-------------------------------------------------------------------
PROCEDURE Update_Row(
-------------------------------------------------------------------
       p_rowid  in out NOCOPY /* file.sql.39 change */  varchar2
      ,p_condition_id 			in   number
      ,p_condition_element_id               in       number
      ,p_group_number 			in   number
      ,p_attribute_code	       	in      varchar2
      ,p_value_op	       	in      varchar2
      ,p_value_string	       	in      varchar2
      ,p_system_flag	       	in      varchar2
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

-------------------------------------------------------------------
PROCEDURE Delete_Row(
-------------------------------------------------------------------
			p_rowid				IN VARCHAR2,
		     p_condition_element_id 	IN NUMBER,
		     p_condition_id 		IN NUMBER
			);

-------------------------------------------------------------------
PROCEDURE Lock_Row(
-------------------------------------------------------------------
      	p_rowid  in out NOCOPY /* file.sql.39 change */  varchar2
      ,p_condition_id 			in   number
      ,p_condition_element_id               in out NOCOPY /* file.sql.39 change */      number
      ,p_group_number 			in   number
      ,p_attribute_code	       	in      varchar2
      ,p_value_op	       	in      varchar2
      ,p_value_string	       	in      varchar2
      ,p_system_flag	       	in      varchar2
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

END DEFELEMENTS_pkg;

 

/
