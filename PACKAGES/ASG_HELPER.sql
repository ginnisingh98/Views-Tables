--------------------------------------------------------
--  DDL for Package ASG_HELPER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ASG_HELPER" AUTHID DEFINER AS
/*$Header: asghlps.pls 120.3 2006/09/20 17:04:31 rsripada noship $*/

-- DESCRIPTION
--  This package is used for miscellaneous chores
--
-- HISTORY
--   29-sep-2004 ssabesan   Removed method truncate_sdq
--   23-jun-2004 ssabesan   Fix bug 3713556
--   05-apr-2004 rsripada   Add enable_olite_privs
--   01-apr-2004 ssabesan   Added encrypt, decrypt, set_profile_to_null routines
--   13-jan-2004 ssabesan   Added method recreate_synonyms() for use during
--                          user creation.
--   30-dec-2003 rsripada   Added procedures for creating/dropping olite
--                          synonyms
--   22-oct-2003 ssabesan   Merge 115.7.1158.8 into mainline
--   01-oct-2003 ssabesan   Purge SDQ changes (bug 3170790)
--   12-jun-2003 rsripada   Added procedure to determine last synch device type
--   25-mar-2003 ssabesan   Added API for updating user_sertup_errors and
--                          synch_errors column in asg_user
--   12-feb-2003 ssabesan   Added API for updating hwm_tranid column in asg_user
--   10-jan-2003 ssabesan   Added a wrapper around check_is_log_enabled()
--			                for use from java program.
--   06-jan-2003 ssabesan   PL/SQL API changes. Added method for checking
--			                whether logging is enabled.
--   02-jan-2003 rsripada   Bug fix 2731476
--   19-nov-2002 rsripada   Added routines for disabling user synch
--   10-nov-2002 ssabesan   added routine for specifying a pub-item
--		                    to be completely refreshed
--   09-sep-2002 rsripada   Added routines to enable/disable synch
--   28-may-2002 rsripada   Created

  -- Invokes the callback to populate all the user's acc tables
  PROCEDURE populate_access(p_user_name IN VARCHAR2,
                            p_pub_name IN VARCHAR2);

  -- Invokes the callback to remove all acc table records
  PROCEDURE delete_access(p_user_name IN VARCHAR2,
                          p_pub_name IN VARCHAR2);

  -- Creates a sequence partitions
  PROCEDURE create_seq_partition(p_user_name IN VARCHAR2,
                                 p_seq_name  IN VARCHAR2,
                                 p_start_value IN VARCHAR2,
                                 p_next_value IN VARCHAR2);

  -- Drop the sequence partition
  PROCEDURE drop_seq_partition(p_user_name IN VARCHAR2,
                               p_seq_name IN VARCHAR2);

  -- insert pub responsibilities
  PROCEDURE insert_user_pub_resp(p_user_name IN VARCHAR2,
                                 p_pub_name IN VARCHAR2,
                                 p_resp_id IN NUMBER,
                                 p_app_id IN NUMBER);

  -- delete user-pub
  PROCEDURE delete_user_pub(p_user_name IN VARCHAR2,
                            p_pub_name IN VARCHAR2);

  -- delete pub responsibilites
  PROCEDURE delete_user_pub_resp(p_user_name IN VARCHAR2,
                                 p_pub_name IN VARCHAR2,
                                 p_resp_id IN NUMBER);

  -- wrapper on fnd_log
  PROCEDURE log(message IN VARCHAR2,
                module IN VARCHAR2 ,
                log_level IN NUMBER);


  -- Used to clean up metadata associated with an user
  PROCEDURE drop_user(p_user_name IN VARCHAR2);

  -- Used to update a parameter in asg_config
  PROCEDURE set_config_param(p_param_name IN VARCHAR2,
                             p_param_value IN VARCHAR2,
                             p_param_description IN VARCHAR2 := NULL);

  -- Returns the value column in asg_config table based on the
  -- specified parameter name
  FUNCTION get_param_value(p_param_name IN VARCHAR2)
           return VARCHAR2;

  -- Used to enable synch for all publications
  PROCEDURE enable_synch;

  -- Used to enable synch for the specified publication
  PROCEDURE enable_pub_synch(p_pub_name IN VARCHAR2);

  -- Used to disable synch for all publications
  PROCEDURE disable_synch;

  -- Used to disable synch for the specified publication
  PROCEDURE disable_pub_synch(p_pub_name IN VARCHAR2);

  -- Returns FND_API.G_TRUE if the user synch is enabled
  FUNCTION is_user_synch_enabled(p_user_name IN VARCHAR2,
           p_disabled_synch_message OUT NOCOPY VARCHAR2)
           return VARCHAR2;

  --routine for setting complete_refresh for a pub-item for all users
  --subscribed to that Pub-Item.
  PROCEDURE set_complete_refresh(p_pub_item VARCHAR2);

  -- Disables synch for specified user/publication
  PROCEDURE disable_user_pub_synch(p_user_id   IN NUMBER,
                                   p_pub_name  IN VARCHAR2);

  -- Enables synch for specified user/publication
  PROCEDURE enable_user_pub_synch(p_user_id   IN NUMBER,
                                  p_pub_name  IN VARCHAR2);


  -- Enables all users access to public group
  PROCEDURE set_group_access(p_group_name IN VARCHAR2);

  -- Check whether is logging is enabled
  FUNCTION  check_is_log_enabled (log_level IN NUMBER) RETURN BOOLEAN;

  --wrapper around check_is_log_enabled(log_level IN NUMBER) method
  FUNCTION check_log_enabled(log_level IN NUMBER) RETURN VARCHAR2;

  --API for updating hwm_tranid column in asg_user table
  PROCEDURE update_hwm_tranid(p_user_name IN VARCHAR2,p_tranid IN NUMBER);

  --API for autonomous update of USER_SETUP_ERRORS column in asg_user table
  PROCEDURE update_user_setup_errors(p_user_name IN VARCHAR2,
				     p_mesg IN VARCHAR2);

  --API for synching info between asg_user_pub_resps and asg_user tables
  --after adding/dropping subscription
  PROCEDURE update_user_resps(p_user_name IN VARCHAR2);

  --API for updating SYNCH_ERRORS column in asg_user table
  PROCEDURE update_synch_errors(p_user_name IN VARCHAR2,
				p_mesg IN VARCHAR2);

  --API for autonomous update of hwm_tranid and synch_errors.
  PROCEDURE set_synch_errmsg(p_user_name IN VARCHAR2, p_tranid IN NUMBER,
                             p_device_type IN VARCHAR2, p_mesg IN VARCHAR2);

  --Routine that sets the device type of last synch
  PROCEDURE set_last_synch_device_type;

  --Routine that sets up a user for complete refresh for a publication
  PROCEDURE set_first_synch(p_clientid in varchar2,p_pub in varchar2);

  -- Routine for setting the SSO login profile for each user
  PROCEDURE set_sso_profile(p_userId in VARCHAR2);

  -- Routine for creating olite synonyms
  PROCEDURE create_olite_synonyms;

  -- Routine for dropping olite synonyms
  PROCEDURE drop_olite_synonyms;

  PROCEDURE recreate_synonyms(p_dt IN DATE);

  function encrypt(p_input_string varchar2,p_key varchar2) return varchar2;

  function decrypt(p_input_string varchar2,p_key varchar2) return varchar2;

  --Sets a given profile value to null at all levels.
  procedure set_profile_to_null(p_profile_name varchar2);

  -- Grants necessary select, insert privileges to mobile table/views to
  -- Olite db schema
  PROCEDURE enable_olite_privs;

  --This procedure encrypts p_input_string using the key p_key.
  --It then updates the asg_config param p_param_name
  procedure encrypt_and_copy(p_param_name varchar2,p_input_string varchar2,
			    p_key varchar2,p_param_desc varchar2);

  --This function reads the value of the asg_config param p_param_name
  --The value is decrypted using p_key and the decrypted string is returned.
  function decrypt_and_return(p_param_name varchar2,p_key varchar2)
	   return varchar2;

  --Earlier versions that used asg_config
  procedure encrypt_old(p_param_name varchar2,p_input_string varchar2,
                p_key varchar2,p_param_desc varchar2);

  function decrypt_old(p_param_name varchar2,p_key varchar2)
       return varchar2;

  function get_key
       return varchar2;

END asg_helper;

 

/
