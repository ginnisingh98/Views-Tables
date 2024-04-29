--------------------------------------------------------
--  DDL for Package AMW_LOAD_KEY_ACC_DATA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMW_LOAD_KEY_ACC_DATA" AUTHID CURRENT_USER AS
/* $Header: amwkaccs.pls 120.0.12000000.1 2007/01/16 20:38:56 appldev ship $ */

   PROCEDURE create_key_acc_assoc (
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

   PROCEDURE CREATE_AMW_KEY_ACC_ASSOC(
	  P_natural_account_id			   IN NUMBER
	 ,P_process_id 	  				   IN NUMBER
   );

   ---
   ---03.02.2005 npanandi: function to check access privilege for this
   ---Process to Key Account association
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

END amw_load_key_acc_data;

 

/
