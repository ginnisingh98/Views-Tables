--------------------------------------------------------
--  DDL for Package AMW_LOAD_AP_DATA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMW_LOAD_AP_DATA" AUTHID CURRENT_USER AS
/* $Header: amwaplds.pls 120.0 2005/05/31 22:21:46 appldev noship $ */

   PROCEDURE create_audit_procedures (
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

   ---
   ---03.01.2005 npanandi: add Audit Procedure Owner privilege here for data security
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
   ---03.01.2005 npanandi: function to check access privilege for this Audit Procedure
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
END amw_load_ap_data;

 

/
