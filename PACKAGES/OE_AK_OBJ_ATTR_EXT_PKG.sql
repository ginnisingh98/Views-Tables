--------------------------------------------------------
--  DDL for Package OE_AK_OBJ_ATTR_EXT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_AK_OBJ_ATTR_EXT_PKG" AUTHID CURRENT_USER AS
/* $Header: OEXVOATS.pls 120.0 2005/06/01 02:24:35 appldev noship $ */

   PROCEDURE Update_Row(
      p_rowid    				in      varchar2
     , p_database_object_name 		in   VARCHAR2
     , p_attribute_code  		in     VARCHAR2
     , p_defaulting_sequence 		in	NUMBER
     , p_defaulting_condn_ref_flag 		in	VARCHAR2
     , p_last_updated_by 	    	in      number
     , p_last_update_date        	in      date
     , p_last_update_login       	in      number
   );

PROCEDURE Lock_Row( p_rowid    	in      varchar2
      , p_database_object_name 		in   VARCHAR2
      , p_attribute_code  		in     VARCHAR2
     ,  p_defaulting_sequence 		in	NUMBER
      , p_defaulting_condn_ref_flag 		in	VARCHAR2
      , p_created_by       	 	in      number
      , p_creation_date       		in      date
      , p_last_updated_by 	    	in      number
      , p_last_update_date        	in      date
      , p_last_update_login       	in      number
      );


END OE_AK_OBJ_ATTR_EXT_PKG;

 

/
