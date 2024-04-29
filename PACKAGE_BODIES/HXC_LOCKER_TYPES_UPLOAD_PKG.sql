--------------------------------------------------------
--  DDL for Package Body HXC_LOCKER_TYPES_UPLOAD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_LOCKER_TYPES_UPLOAD_PKG" AS
/* $Header: hxclocktypesload.pkb 115.1 2004/05/13 02:18:43 dragarwa noship $ */

PROCEDURE load_locker_types_row (
	  p_process_type	     IN VARCHAR2
        , p_locker_type		     IN VARCHAR2
	, p_owner                    IN VARCHAR2
	, p_custom_mode	     	     IN VARCHAR2 ) IS

l_locker_type_id  		hxc_locker_types.locker_type_id%TYPE;
l_locker_type  			hxc_locker_types.locker_type%TYPE;
l_process_type  		hxc_locker_types.process_type%TYPE;
l_owner				VARCHAR2(4000);

BEGIN

BEGIN
	SELECT           locker_type_id
			, fnd_load_util.owner_name(NVL(last_updated_by,-1))
			, locker_type
			, process_type

	INTO	         l_locker_type_id
			,l_owner
			,l_locker_type
			,l_process_type

	FROM 		 hxc_locker_types lot
	WHERE   lot.process_type = p_process_type
	AND     lot.locker_type = p_locker_type;


	IF ( p_custom_mode = 'FORCE' OR l_owner = 'ORACLE' )
	THEN
		-- only update if the alias component mapping that has actually changed


		hxc_lck_upd.upd
		  (
		     p_locker_type_id		=>l_locker_type_id
		    ,p_locker_type              =>l_locker_type
		    ,p_process_type             => l_process_type
		  );

	END IF;
EXCEPTION WHEN NO_DATA_FOUND
THEN
		hxc_lck_ins.ins
		  (  p_locker_type              =>p_locker_type
		    ,p_process_type             => p_process_type
		    ,p_locker_type_id		=>l_locker_type_id
		  );
END;

END load_locker_types_row;
PROCEDURE load_locker_types_row (
	  p_process_type	     IN VARCHAR2
        , p_locker_type		     IN VARCHAR2
	, p_owner                    IN VARCHAR2
	, p_custom_mode	     	    IN VARCHAR2
	,p_last_update_date         IN VARCHAR2 ) IS
l_locker_type_id  		hxc_locker_types.locker_type_id%TYPE;
l_locker_type  			hxc_locker_types.locker_type%TYPE;
l_process_type  		hxc_locker_types.process_type%TYPE;

l_last_update_date_db              hxc_locker_types.last_update_date%TYPE;
l_last_updated_by_db               hxc_locker_types.last_updated_by%TYPE;
l_last_updated_by_f               hxc_locker_types.last_updated_by%TYPE;
l_last_update_date_f               hxc_locker_types.last_update_date%TYPE;
BEGIN

BEGIN
l_last_updated_by_f := fnd_load_util.owner_id(p_owner);
l_last_update_date_f := nvl(to_date(p_last_update_date, 'YYYY/MM/DD'), sysdate);
	SELECT           locker_type_id

			, locker_type
			, process_type
			,last_update_date
			,last_updated_by

	INTO	         l_locker_type_id

			,l_locker_type
			,l_process_type
			,l_last_update_date_db
                        ,l_last_updated_by_db

	FROM 		 hxc_locker_types lot
	WHERE   lot.process_type = p_process_type
	AND     lot.locker_type = p_locker_type;


	IF (fnd_load_util.upload_test(	l_last_updated_by_f,
					l_last_update_date_f,
	                        	 l_last_updated_by_db,
					l_last_update_date_db ,
					 p_custom_mode))
	THEN
		-- only update if the alias component mapping that has actually changed

		hxc_lck_upd.upd
		  (
		     p_locker_type_id		=>l_locker_type_id
		    ,p_locker_type              =>l_locker_type
		    ,p_process_type             => l_process_type
		  );

	END IF;
EXCEPTION WHEN NO_DATA_FOUND
THEN
		hxc_lck_ins.ins
		  (  p_locker_type              =>p_locker_type
		    ,p_process_type             => p_process_type
		    ,p_locker_type_id		=>l_locker_type_id
		  );
END;

END load_locker_types_row;

END hxc_locker_types_upload_pkg;

/
