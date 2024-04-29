--------------------------------------------------------
--  DDL for Package Body PER_IMAGES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_IMAGES_PKG" as
/* $Header: peimg01t.pkb 115.0 99/07/18 13:54:12 porting ship $ */
--
procedure check_unique(p_table_name VARCHAR2
                      ,p_parent_id  NUMBER) is
--
-- Ensure that only one combination of
-- table_name,parent_id can exist in the images table
--
cursor img_cur is
select 'Y'
from   per_images
where  table_name = p_table_name
and    parent_id = p_parent_id;
---
-- local variables
--
l_exists varchar2(1);
begin
   open img_cur;
   fetch img_cur into l_exists;
      if img_cur%FOUND  then
        FND_MESSAGE.SET_NAME('801','PER_7901_SYS_DUPLICATE_RECORDS');
        APP_EXCEPTION.RAISE_EXCEPTION;
     end if;
   close img_cur;
end check_unique;
--
procedure get_sequence_no(p_image_id IN OUT NUMBER) is
--
-- Return next sequence number for insert
-- of image.
--
cursor get_seq is
    select per_images_s.nextval
    from sys.dual;
begin
    open get_seq;
    fetch get_seq into p_image_id;
    close get_seq;
end get_sequence_no;
procedure insert_row (p_image_id IN OUT NUMBER
                     ,p_table_name VARCHAR2
                     ,p_parent_id NUMBER) is
--
-- Run Procedures required at insert.
--
begin
   per_images_pkg.check_unique(p_table_name =>p_table_name
                              ,p_parent_id =>p_parent_id);
   per_images_pkg.get_sequence_no(p_image_id => p_image_id);
end insert_row;
END PER_IMAGES_PKG;

/
