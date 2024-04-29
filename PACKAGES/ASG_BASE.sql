--------------------------------------------------------
--  DDL for Package ASG_BASE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ASG_BASE" AUTHID DEFINER AS
/*$Header: asgbases.pls 120.4.12010000.2 2009/08/03 07:42:39 ravir ship $*/

-- DESCRIPTION
--  Contains functions to retrieve information during a synch session.
--
--
-- HISTORY
--   02-sep-2005 rsripada   Multiple Responsibility Support
--   12-aug-2004 ssabesan   Added device switch changes ( bug 3824280 )
--   02-jun-2004 rsripada   Add function to download attachments
--   27-may-2003 ssabesan   Merged the branch line with main line
--   31-mar-2003 rsripada   Modify init method to pass last_synch_date
--   11-feb-2003 rsripada   Added get_upload_tranid, set_upload_tranid
--   28-jun-2002 vekrishn   Over Loaded GET_CURRENT_TRANID Api for logging
--   25-jun-2002 rsripada   Added Olite schema name as global constant
--   25-apr-2002 rsripada   Added debug logging functions
--   18-apr-2002 rsripada   Added functions for online queries etc.
--   29-mar-2002 rsripada   Created

  g_user_name          VARCHAR2(30);
   -- Short code version ie., 'US' instead of 'American' etc.
  g_language           VARCHAR2(4);
  g_resource_id        NUMBER;
  g_user_id            NUMBER;
  g_resp_id            NUMBER;
  g_application_id     NUMBER;
  g_last_synch_date    DATE;
  g_download_tranid    NUMBER;
  g_upload_tranid      NUMBER;
  g_last_tranid        NUMBER;
  g_is_auto_sync       VARCHAR2(1);

  TYPE pub_item_rec_type IS RECORD
                            (name VARCHAR2(30),
                             comp_ref VARCHAR2(1),
                             rec_count NUMBER,
                             online_query VARCHAR2(1));

  TYPE pub_item_tbl_type IS TABLE OF pub_item_rec_type INDEX BY BINARY_INTEGER;

  g_pub_item_tbl       pub_item_tbl_type;
  g_empty_pub_item_tbl pub_item_tbl_type; -- Should always be empty!

  -- Constants for INS,UPD,DEL
  G_INS CONSTANT VARCHAR2(1) := 'I';
  G_UPD CONSTANT VARCHAR2(1) := 'U';
  G_DEL CONSTANT VARCHAR2(1) := 'D';

  -- Constant to specify complete refresh
  G_YES CONSTANT VARCHAR2(1) := 'Y';
  G_NO  CONSTANT VARCHAR2(1) := 'N';


  -- Constants to specify client wins or server wins
  G_CLIENT_WINS CONSTANT VARCHAR2(1) := 'C';
  G_SERVER_WINS CONSTANT VARCHAR2(1) := 'S';

  -- Corresponds to 01 JAN 4712 BC
  G_OLD_DATE CONSTANT DATE := to_date('1', 'J');

  -- Olite repository schema name
  G_OLITE_SCHEMA CONSTANT VARCHAR2(30) := 'mobileadmin';

  TYPE mobile_user_list_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

  -- Device Type parameters for get_mobile_users API
  G_ALL_DEVICES  NUMBER := 1;
  G_POCKETPC     NUMBER := 2;
  G_LAPTOP       NUMBER := 3;

  /* get user name for the specified resource_id */
  FUNCTION get_user_name(p_resource_id IN NUMBER) return VARCHAR2;

  /* get resource_id for user_name */
  FUNCTION get_resource_id(p_user_name IN VARCHAR2) return NUMBER;

  /* get user_id for user_name */
  FUNCTION get_user_id(p_user_name IN VARCHAR2) return NUMBER;

  /* get language for user */
  FUNCTION get_language(p_user_name IN VARCHAR2) return VARCHAR2;

  /* get application_id for user */
  FUNCTION get_application_id(p_user_name IN VARCHAR2) return NUMBER;

  /* get mobile responsibility associated with this user */
  FUNCTION get_resp_id(p_user_name IN VARCHAR2) return NUMBER;

  /* get resource_id */
  FUNCTION get_resource_id return NUMBER;

  /* get user_id */
  FUNCTION get_user_id return NUMBER;

  /* get language */
  FUNCTION get_language return VARCHAR2;

  /* get application_id */
  FUNCTION get_application_id return NUMBER;

  /* get mobile responsibility associated with this user */
  FUNCTION get_resp_id return NUMBER;

  /* get user name */
  FUNCTION get_user_name return VARCHAR2;

  /* get last successful synch date */
  FUNCTION get_last_synch_date return DATE;

  /* Checks if the passed in publication item wll be completely refreshed   */
  /* ands returns G_OLD_DATE. Otherwise, gets last successful synch date    */
  FUNCTION get_last_synch_date(p_pub_item_name IN VARCHAR2) return DATE;

  /* Get current download tran id */
  FUNCTION get_current_tranid return NUMBER;

  /* Get current download tran id - with logging Support*/
  FUNCTION get_current_tranid(p_pub_item_name IN VARCHAR2)return NUMBER;

  /* Get last download tran id */
  FUNCTION get_last_tranid return NUMBER;

  /* get dml type based on creation_date, update_date and */
  /* last_synch_date. Will return either G_INS or G_UPD   */
  FUNCTION get_dml_type(p_creation_date IN DATE) return VARCHAR2;

  /* get dml type based on update date and publication name */
  /* For publications that will be completely refreshed the */
  /* DML type will be insert (G_INS)                        */
  FUNCTION get_dml_type(p_pub_item_name IN VARCHAR2,
                        p_creation_date IN DATE) return VARCHAR2;

  /* Gets the upload tranid */
  FUNCTION get_upload_tranid return NUMBER;

  /* returns G_YES if the publication item will be completely */
  /* refreshed                                                */
  FUNCTION is_first_synch(p_pub_item_name IN VARCHAR2)
           return VARCHAR2;

  /* Initializes the global variables during synch session */
  PROCEDURE init(p_user_name IN VARCHAR2, p_last_tranid IN NUMBER,
                 p_curr_tranid IN NUMBER,
                 p_last_synch_date IN DATE,
                 p_pub_items IN pub_item_tbl_type);

  /* Initializes the global pubitem table with specified items */
  PROCEDURE set_pub_items(p_pub_items IN pub_item_tbl_type);

  /* Sets the specified pub item for complete refresh */
  PROCEDURE set_complete_refresh(p_pub_item_name IN VARCHAR2);

  /* Sets the upload tranid */
  PROCEDURE set_upload_tranid(p_upload_tranid IN NUMBER);

  /* Initializes the global variables with specified values.
     Use for debug only                                       */
  PROCEDURE init_debug(p_user_name IN VARCHAR2, p_language IN VARCHAR2,
                       p_resource_id IN NUMBER, p_user_id IN NUMBER,
                       p_resp_id IN NUMBER,
                       p_application_id IN NUMBER, p_last_synch_date IN DATE);

  /* Resets all global variables to null */
  PROCEDURE reset_all_globals;

  /* Useful for debugging */
  /* Logs all the session information */
  PROCEDURE print_all_globals;

  /*get the last synch date of a user*/
  FUNCTION get_last_synch_date(p_user_id IN NUMBER) RETURN DATE;

  /* Allow download of attachment based on size */
  FUNCTION allow_att_download(p_row_num IN NUMBER,
                              p_blob    IN BLOB)
  RETURN VARCHAR2;

  /* Allow download of attachment based on size */
  FUNCTION allow_attachment_download(p_row_num IN NUMBER,
                                     p_blob    IN BLOB)
  RETURN VARCHAR2;

  FUNCTION get_device_type RETURN NUMBER;

  FUNCTION get_device_type_name RETURN VARCHAR2;

  procedure detect_device_switch(p_user_name IN varchar2,
                                 p_device_type OUT NOCOPY VARCHAR2);

  -- Returns G_YES if the user is a valid MFS user
  FUNCTION is_mobile_user(p_user_id IN NUMBER)
  RETURN VARCHAR2;

  -- Returns a list of all valid mobile users
  FUNCTION get_mobile_users(p_device_type IN VARCHAR2)
  RETURN mobile_user_list_type;

  -- Returns the appid/respid used when creating this user
  PROCEDURE get_user_app_responsibility(p_user_id IN NUMBER,
                                        p_app_id  OUT NOCOPY NUMBER,
                                        p_resp_id OUT NOCOPY NUMBER);

  --Function to tell if it's a auto Sync
  FUNCTION is_auto_sync RETURN VARCHAR2;

  --Function to tell if it's a download only Sync
  FUNCTION is_download_only_sync (p_client_id IN VARCHAR2,
				  p_tran_id IN NUMBER ) RETURN VARCHAR2;
END asg_base;

/
