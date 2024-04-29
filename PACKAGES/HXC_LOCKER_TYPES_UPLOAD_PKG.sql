--------------------------------------------------------
--  DDL for Package HXC_LOCKER_TYPES_UPLOAD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_LOCKER_TYPES_UPLOAD_PKG" AUTHID CURRENT_USER AS
/* $Header: hxclocktypesload.pkh 115.1 2004/05/13 02:18:46 dragarwa noship $ */

PROCEDURE load_locker_types_row (
	 p_process_type	     IN VARCHAR2
        , p_locker_type		     IN VARCHAR2
	, p_owner                    IN VARCHAR2
	, p_custom_mode	     	     IN VARCHAR2 );
PROCEDURE load_locker_types_row (
	 p_process_type	     IN VARCHAR2
        , p_locker_type		     IN VARCHAR2
	, p_owner                    IN VARCHAR2
	, p_custom_mode	     	     IN VARCHAR2
	,p_last_update_date         IN VARCHAR2);


END hxc_locker_types_upload_pkg;

 

/
