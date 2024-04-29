--------------------------------------------------------
--  DDL for Package PER_IMAGES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_IMAGES_PKG" AUTHID CURRENT_USER as
/* $Header: peimg01t.pkh 115.0 99/07/18 13:54:15 porting ship $ */
--
procedure check_unique(p_table_name VARCHAR2
							 ,p_parent_id  NUMBER);
procedure get_sequence_no(p_image_id IN OUT NUMBER);
procedure insert_row (p_image_id IN OUT NUMBER
							,p_table_name VARCHAR2
							,p_parent_id NUMBER);
END PER_IMAGES_PKG;

 

/
