--------------------------------------------------------
--  DDL for Package ASG_DOWNLOAD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ASG_DOWNLOAD" AUTHID CURRENT_USER AS
/* $Header: asgdwlds.pls 120.1.12010000.2 2009/08/03 07:32:49 ravir ship $*/


  -- Type Declarations for External Use
  TYPE user_list           IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
  TYPE access_list         IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
  TYPE dml_list            IS TABLE OF CHAR(1) INDEX BY BINARY_INTEGER;
  TYPE qid_list            IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
  TYPE pk_list             IS TABLE OF VARCHAR2(200) INDEX BY BINARY_INTEGER;

  TYPE username_list	   IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;

  -- Constants
  OK                       CONSTANT BOOLEAN := TRUE;
  FAIL                     CONSTANT BOOLEAN := FALSE;
  INS                      CONSTANT CHAR    := 'I';
  UPD                      CONSTANT CHAR    := 'U';
  DEL                      CONSTANT CHAR    := 'D';
  ALL_USERS                CONSTANT NUMBER  := -999999;

  -- Exceptions
  PARAMETER_COUNT_MISMATCH EXCEPTION;

  -- Type Declarations for Internal Use
  TYPE PKTAB_LIST          IS TABLE OF VARCHAR(30) INDEX BY BINARY_INTEGER;
  TYPE PKDTYPE_LIST        IS TABLE OF VARCHAR(30) INDEX BY BINARY_INTEGER;
  TYPE session_id_list     IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
  TYPE c_purge_session     IS REF CURSOR;


  -- ** Functions/Procedures

  FUNCTION markDirty ( p_pub_item         IN VARCHAR2,
                       p_accessList       IN access_list,
                       p_resourceList     IN user_list,
                       p_dmlList          IN dml_list,
                       p_timestamp        IN DATE) RETURN BOOLEAN;

  FUNCTION markDirty ( p_pub_item         IN VARCHAR2,
                       p_accessList       IN access_list,
                       p_resourceList     IN user_list,
                       p_dml_type         IN CHAR,
                       p_timestamp        IN DATE) RETURN BOOLEAN;

  FUNCTION markDirty ( p_pub_item         IN VARCHAR2,
                       p_accessid         IN NUMBER,
                       p_resourceid       IN NUMBER,
                       p_dml              IN CHAR,
                       p_timestamp        IN DATE )
                     RETURN BOOLEAN;

  FUNCTION markDirty ( p_pub_item         IN VARCHAR2,
                       p_accessid         IN NUMBER,
                       p_resourceid       IN NUMBER,
                       p_dml              IN CHAR,
                       p_timestamp        IN DATE,
                       p_pkvalues         IN pk_list )
                     RETURN BOOLEAN;

  FUNCTION markDirty ( p_pub_item         IN VARCHAR2,
                       p_accessList       IN access_list,
                       p_resourceList     IN user_list,
                       p_dml_type         IN CHAR,
                       p_timestamp        IN DATE,
                       p_bulk_flag        IN BOOLEAN) RETURN BOOLEAN;

  FUNCTION markDirty ( p_pub_item         IN VARCHAR2,
                       p_user_name        IN VARCHAR2,
                       p_tran_id          IN NUMBER,
                       p_seq_no           IN NUMBER) RETURN BOOLEAN;


--mark_dirty API's that take user ID.

  FUNCTION mark_dirty ( p_pub_item         IN VARCHAR2,
                        p_accessList       IN access_list,
                        p_userid_list      IN user_list,
                        p_dmlList          IN dml_list,
                        p_timestamp        IN DATE) RETURN BOOLEAN;

  FUNCTION mark_dirty ( p_pub_item         IN VARCHAR2,
                        p_accessList       IN access_list,
                        p_userid_list      IN user_list,
                        p_dml_type         IN CHAR,
                        p_timestamp        IN DATE) RETURN BOOLEAN;

  FUNCTION mark_dirty ( p_pub_item         IN VARCHAR2,
                        p_accessid         IN NUMBER,
                        p_userid           IN NUMBER,
                        p_dml              IN CHAR,
                        p_timestamp        IN DATE )RETURN BOOLEAN;

  FUNCTION mark_dirty ( p_pub_item         IN VARCHAR2,
                        p_accessid         IN NUMBER,
                        p_userid           IN NUMBER,
                        p_dml              IN CHAR,
                        p_timestamp        IN DATE,
                        p_pkvalues         IN pk_list ) RETURN BOOLEAN;

  FUNCTION mark_dirty ( p_pub_item         IN VARCHAR2,
                        p_accessList       IN access_list,
                        p_userid_list      IN user_list,
                        p_dml_type         IN CHAR,
                        p_timestamp        IN DATE,
                        p_bulk_flag        IN BOOLEAN) RETURN BOOLEAN;



  FUNCTION getPrimaryKeys ( p_pub_item IN VARCHAR2,
                            x_pk_list  OUT NOCOPY VARCHAR2,
                            x_pk_cnt   OUT NOCOPY NUMBER) RETURN BOOLEAN;


  FUNCTION processSdq ( p_clientid    IN VARCHAR2,
                        p_last_tranid IN NUMBER,
                        p_curr_tranid IN NUMBER,
                        p_high_prty   IN VARCHAR2,
			x_ret_msg OUT NOCOPY VARCHAR2) RETURN BOOLEAN;


  FUNCTION storeDeletedPK ( p_pub_item    IN VARCHAR2,
                            p_accessList  IN access_list,
                            p_qidList     IN qid_list
                          ) RETURN BOOLEAN;

  FUNCTION storeDeletedPK ( p_pub_item    IN VARCHAR2,
                            p_qid         IN NUMBER,
                            p_pkvalList   IN pk_list
                          ) RETURN BOOLEAN;

  FUNCTION storeDeletedPK ( p_pub_item     IN VARCHAR2,
                            p_client_name  IN VARCHAR2,
                            p_tran_id      IN NUMBER,
                            p_seq_no       IN NUMBER,
                            p_qid          IN NUMBER
                          ) RETURN BOOLEAN;

  FUNCTION purgeSdq  RETURN BOOLEAN;

  FUNCTION purgeSdq(p_clientid VARCHAR2) RETURN BOOLEAN;

  PROCEDURE log (p_mesg VARCHAR2);

  FUNCTION isFirstSync RETURN BOOLEAN;

  PROCEDURE reset_all_globals;

  PROCEDURE delete_Sdq( P_Status OUT NOCOPY VARCHAR2,
			P_Message OUT NOCOPY VARCHAR2);

  --function to verify whether a record shd be inserted into SDQ or not
  FUNCTION insert_sdq(p_pub_item VARCHAR2,
                      p_user_name VARCHAR2) RETURN boolean;

  --checks whether the record exists in SDQ
  FUNCTION is_exists(p_clientid VARCHAR2,
                     p_pub_item varchar2,
                     p_access_id NUMBER,
                     p_dml_type CHAR)
		     RETURN boolean;

  FUNCTION get_listfrom_string(p_string1 IN VARCHAR2) RETURN pk_list;

  PROCEDURE delete_synch_history( P_Status OUT NOCOPY VARCHAR2,
				  P_Message OUT NOCOPY VARCHAR2);

  function get_pk(pi_name varchar2,p_qid number)
  return varchar2;

  procedure user_incompatibility_test(P_status OUT NOCOPY VARCHAR2,
                                      P_message OUT NOCOPY VARCHAR2);

END asg_download;

/
