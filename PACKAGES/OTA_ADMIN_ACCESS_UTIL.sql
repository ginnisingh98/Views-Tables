--------------------------------------------------------
--  DDL for Package OTA_ADMIN_ACCESS_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_ADMIN_ACCESS_UTIL" AUTHID CURRENT_USER as
/* $Header: otadminacc.pkh 120.0.12010000.9 2009/09/30 09:34:52 shwnayak noship $ */


 Cursor check_is_category_secured(category_id in number) IS
  Select user_group_id
  from ota_category_usages
  where category_usage_id=category_id;

  Cursor get_lo_id(tst_id in number) IS
  Select learning_object_id
  from ota_learning_objects
  where test_id=tst_id;
 function admin_can_access_object(p_object_type in varchar,
                                    p_object_id in number,
                                    p_module_name IN VARCHAR2 default 'ADMIN') return varchar2;

 function lp_has_access_to_course(p_lp_id in NUMBER,
                                  p_crs_id in NUMBER) return varchar2;


 function cert_has_access_to_course(p_cert_id in NUMBER,
                                     p_crs_id in NUMBER) return varchar2;

 function offering_has_access_to_lo(p_course_id in NUMBER,
                                        p_lo_id in NUMBER) return varchar2 ;


 function category_has_access_to_object(p_object_type in varchar2,
                                           p_object_id in NUMBER,
                                           p_category_id in NUMBER) return varchar2 ;

 function folder_has_access_to_object(p_object_type in varchar2,
                                           p_object_id in NUMBER,
                                           p_folder_id in NUMBER) return varchar2;

 function lo_has_access_to_object( p_object_type in varchar2,
                                  p_object_id in NUMBER,
                                 p_lo_id in NUMBER) return varchar2;

 function object_has_access_to_eval(p_object_type in varchar,
                                     p_object_id in NUMBER,
                                     p_test_id in NUMBER) return varchar2;


 function object_can_add_category(p_object_type in varchar,
                                     p_object_id in NUMBER,
                                     p_category_usage_id in NUMBER) return varchar2;

 function can_add_object_as_prereq(p_object_type in varchar,
                                  p_obj_id in NUMBER,
                                p_prereq_obj_id in NUMBER) return varchar2;

 function get_admin_group_id(p_object_type in varchar,
                                     p_object_id in number) return Number;
 function lo_has_access_to_offering(p_course_id in NUMBER,
                                       p_lo_id in NUMBER,
                                       p_category_id in NUMBER default NULL)return varchar2;

 function test_has_access_to_qbank(p_qbank_id in NUMBER,
                                       p_test_id in NUMBER)return varchar2 ;



 FUNCTION get_lo_offering_count (p_learning_object_id in number) RETURN varchar2;

 function admin_can_access_chat(p_chat_id in number) return varchar2;

 function admin_can_access_forum(p_forum_id in number) return varchar2;
 function disable_select(p_object_type in varchar2,
                                           p_object_id in NUMBER,
                                           p_dest_object_type in varchar2,
                                           p_dest_object_id in NUMBER,
                                           p_action in varchar2 default 'Copy' )return varchar2;
 function disable_content_obj_select(p_object_type in varchar2,
                                           p_object_id in NUMBER,
                                           p_dest_obj_type in varchar2,
                                           p_dest_obj_id in NUMBER
                                           ) return varchar2 ;
end ota_admin_access_util;



/
