--------------------------------------------------------
--  DDL for Package Body HXC_LOCKING_RULES_UPLOAD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_LOCKING_RULES_UPLOAD_PKG" AS
/* $Header: hxclockrulesload.pkb 115.1 2004/05/13 02:18:37 dragarwa noship $ */

PROCEDURE load_locking_rules_row (
 	  p_owner_process_type	     IN VARCHAR2
        , p_owner_locker_type	     IN VARCHAR2
 	 , p_requestor_process_type   IN VARCHAR2
        , p_requestor_locker_type    IN VARCHAR2
	, p_owner                    IN VARCHAR2
	, p_grant_lock		     IN VARCHAR2
	, p_custom_mode	     	     IN VARCHAR2 ) IS

l_owner_id	 		hxc_locking_rules.locker_type_owner_id%TYPE;
l_requestor_id	 		hxc_locking_rules.locker_type_requestor_id%TYPE;
l_grant_lock			hxc_locking_rules.grant_lock%TYPE;

l_locker_type  			hxc_locker_types.locker_type%TYPE;
l_process_type  		hxc_locker_types.process_type%TYPE;
l_owner				VARCHAR2(4000);

FUNCTION find_locker_type_id ( p_process_type VARCHAR2,p_locker_type VARCHAR2 ) RETURN number IS
CURSOR	csr_get_locker_type_id IS
SELECT	locker_type_id
FROM	hxc_locker_types
WHERE	locker_type	 = p_locker_type
AND	 process_type    = p_process_type;

l_locker_type_id  		hxc_locker_types.locker_type_id%TYPE;

BEGIN

l_locker_type_id :=NULL;

OPEN  csr_get_locker_type_id;
FETCH csr_get_locker_type_id INTO l_locker_type_id;
CLOSE csr_get_locker_type_id;
RETURN l_locker_type_id;
END find_locker_type_id;

BEGIN

l_owner_id:=find_locker_type_id(p_owner_process_type,p_owner_locker_type);
l_requestor_id:=find_locker_type_id(p_requestor_process_type,p_requestor_locker_type);

  BEGIN
	SELECT           locker_type_owner_id
			,locker_type_requestor_id
			, fnd_load_util.owner_name(NVL(last_updated_by,-1))
			, grant_lock

	INTO	         l_owner_id
			,l_requestor_id
			,l_owner
			,l_grant_lock

	FROM 		 hxc_locking_rules lkr
	WHERE            lkr.locker_type_owner_id    = l_owner_id
	AND              lkr.locker_type_requestor_id = l_requestor_id;


	IF ( p_custom_mode = 'FORCE' OR l_owner = 'ORACLE' )
	THEN
		-- only update if the grant_lock  has actually changed


		hxc_lkr_upd.upd
		  ( p_locker_type_owner_id	=>l_owner_id
		   ,p_locker_type_requestor_id	=>l_requestor_id
		   ,p_grant_lock		=>p_grant_lock
		  );

	END IF;
  EXCEPTION WHEN NO_DATA_FOUND THEN

		hxc_lkr_ins.ins
		  ( p_grant_lock		 => p_grant_lock
		   ,p_locker_type_owner_id       => l_owner_id
		   ,p_locker_type_requestor_id   => l_requestor_id
		  );

  END;

END load_locking_rules_row;
PROCEDURE load_locking_rules_row (
 	  p_owner_process_type	     IN VARCHAR2
        , p_owner_locker_type	     IN VARCHAR2
 	 , p_requestor_process_type   IN VARCHAR2
        , p_requestor_locker_type    IN VARCHAR2
	, p_owner                    IN VARCHAR2
	, p_grant_lock		     IN VARCHAR2
	, p_custom_mode	     	     IN VARCHAR2
	,p_last_update_date         IN VARCHAR2 ) IS

l_owner_id	 		hxc_locking_rules.locker_type_owner_id%TYPE;
l_requestor_id	 		hxc_locking_rules.locker_type_requestor_id%TYPE;
l_grant_lock			hxc_locking_rules.grant_lock%TYPE;

l_locker_type  			hxc_locker_types.locker_type%TYPE;
l_process_type  		hxc_locker_types.process_type%TYPE;

l_last_update_date_db              hxc_locking_rules.last_update_date%TYPE;
l_last_updated_by_db               hxc_locking_rules.last_updated_by%TYPE;
l_last_updated_by_f               hxc_locking_rules.last_updated_by%TYPE;
l_last_update_date_f               hxc_locking_rules.last_update_date%TYPE;

FUNCTION find_locker_type_id ( p_process_type VARCHAR2,p_locker_type VARCHAR2 ) RETURN number IS
CURSOR	csr_get_locker_type_id IS
SELECT	locker_type_id
FROM	hxc_locker_types
WHERE	locker_type	 = p_locker_type
AND	 process_type    = p_process_type;

l_locker_type_id  		hxc_locker_types.locker_type_id%TYPE;

BEGIN

l_locker_type_id :=NULL;

OPEN  csr_get_locker_type_id;
FETCH csr_get_locker_type_id INTO l_locker_type_id;
CLOSE csr_get_locker_type_id;
RETURN l_locker_type_id;
END find_locker_type_id;

BEGIN

l_owner_id:=find_locker_type_id(p_owner_process_type,p_owner_locker_type);
l_requestor_id:=find_locker_type_id(p_requestor_process_type,p_requestor_locker_type);
l_last_updated_by_f := fnd_load_util.owner_id(p_owner);
l_last_update_date_f := nvl(to_date(p_last_update_date, 'YYYY/MM/DD'), sysdate);

  BEGIN
	SELECT           locker_type_owner_id
			,locker_type_requestor_id

			, grant_lock
			,last_update_date
			,last_updated_by

	INTO	         l_owner_id
			,l_requestor_id

			,l_grant_lock
			,l_last_update_date_db
                        ,l_last_updated_by_db

	FROM 		 hxc_locking_rules lkr
	WHERE            lkr.locker_type_owner_id    = l_owner_id
	AND              lkr.locker_type_requestor_id = l_requestor_id;


	IF (fnd_load_util.upload_test(	l_last_updated_by_f,
					l_last_update_date_f,
	                        	 l_last_updated_by_db,
					l_last_update_date_db ,
					 p_custom_mode))
	THEN
		-- only update if the grant_lock  has actually changed


		hxc_lkr_upd.upd
		  ( p_locker_type_owner_id	=>l_owner_id
		   ,p_locker_type_requestor_id	=>l_requestor_id
		   ,p_grant_lock		=>p_grant_lock
		  );

	END IF;
  EXCEPTION WHEN NO_DATA_FOUND THEN

		hxc_lkr_ins.ins
		  ( p_grant_lock		 => p_grant_lock
		   ,p_locker_type_owner_id       => l_owner_id
		   ,p_locker_type_requestor_id   => l_requestor_id
		  );

  END;

END load_locking_rules_row;


END hxc_locking_rules_upload_pkg;

/
