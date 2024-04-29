--------------------------------------------------------
--  DDL for Package AMW_LOAD_CTRL_DATA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMW_LOAD_CTRL_DATA" AUTHID CURRENT_USER AS
/* $Header: amwctrds.pls 120.0 2005/06/15 18:03:19 appldev noship $ */

   PROCEDURE create_controls (
      ERRBUF      OUT NOCOPY   VARCHAR2
     ,RETCODE     OUT NOCOPY   VARCHAR2
     ,p_batch_id       IN       NUMBER
     ,p_user_id        IN       NUMBER

   );

   PROCEDURE update_interface_with_error (
      p_err_msg        IN   VARCHAR2
     ,p_table_name     IN   VARCHAR2
     ,p_interface_id   IN   NUMBER
   );

   PROCEDURE control_objectives (
      p_ctrl_obj_flag	    IN VARCHAR2,
      p_lookup_tag	    IN VARCHAR2
     );
   PROCEDURE control_assertions (
      p_ctrl_assert_flag    IN VARCHAR2,
      p_lookup_tag	    IN VARCHAR2
     );
   PROCEDURE control_components (
   	  p_ctrl_comp_flag IN VARCHAR2,
	  p_lookup_tag IN VARCHAR2
	 );

   PROCEDURE control_PURPOSES (
      p_ctrl_PURPOSE_flag IN VARCHAR2
	 ,p_lookup_tag IN VARCHAR2);

   ---
   ---02.28.2005 npanandi: add Control Owner privilege here for data security
   ---
   procedure add_owner_privilege(
	  p_role_name          in varchar2
	 ,p_object_name        in varchar2
	 ,p_grantee_type       in varchar2
	 ,p_instance_set_id    in number     default null
	 ,p_instance_pk1_value in varchar2
	 ,p_instance_pk2_value in varchar2   default null
	 ,p_instance_pk3_value in varchar2   default null
	 ,p_instance_pk4_value in varchar2   default null
	 ,p_instance_pk5_value in varchar2   default null
	 ,p_user_id           in number
	 ,p_start_date         in date       default sysdate
	 ,p_end_date           in date       default null);

	  ---
      ---02.28.2005 npanandi: function to check access privilege for this Control
      ---
      function check_function(
         p_function           in varchar2
        ,p_object_name        in varchar2
        ,p_instance_pk1_value in number
        ,p_instance_pk2_value in number default null
        ,p_instance_pk3_value in number default null
        ,p_instance_pk4_value in number default null
        ,p_instance_pk5_value in number default null
        ,p_user_id            in number) return varchar2;

END amw_load_ctrl_data;

 

/
