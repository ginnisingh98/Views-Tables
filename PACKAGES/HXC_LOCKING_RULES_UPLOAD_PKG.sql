--------------------------------------------------------
--  DDL for Package HXC_LOCKING_RULES_UPLOAD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_LOCKING_RULES_UPLOAD_PKG" AUTHID CURRENT_USER AS
/* $Header: hxclockrulesload.pkh 115.1 2004/05/13 02:18:40 dragarwa noship $ */

PROCEDURE load_locking_rules_row (
 	  p_owner_process_type	     IN VARCHAR2
        , p_owner_locker_type	     IN VARCHAR2
 	, p_requestor_process_type   IN VARCHAR2
        , p_requestor_locker_type    IN VARCHAR2
	, p_owner                    IN VARCHAR2
	, p_grant_lock		     IN VARCHAR2
	, p_custom_mode	     	     IN VARCHAR2 );
PROCEDURE load_locking_rules_row (
 	  p_owner_process_type	     IN VARCHAR2
        , p_owner_locker_type	     IN VARCHAR2
 	, p_requestor_process_type   IN VARCHAR2
        , p_requestor_locker_type    IN VARCHAR2
	, p_owner                    IN VARCHAR2
	, p_grant_lock		     IN VARCHAR2
	, p_custom_mode	     	     IN VARCHAR2
	,p_last_update_date         IN VARCHAR2);


END hxc_locking_rules_upload_pkg;

 

/
