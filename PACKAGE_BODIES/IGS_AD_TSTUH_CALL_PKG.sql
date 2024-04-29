--------------------------------------------------------
--  DDL for Package Body IGS_AD_TSTUH_CALL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AD_TSTUH_CALL_PKG" AS
/* $Header: IGSADA6B.pls 115.8 2002/11/28 21:48:03 nsidana ship $ */

PROCEDURE call_user_hook( p_person_id		IN  NUMBER,
  p_session_id		OUT NOCOPY NUMBER
) IS

l_object_name     user_objects.object_name%TYPE DEFAULT 'IGS_AD_TST_UH_PKG';
INVALID_USER_HOOK	EXCEPTION;

CURSOR chk_uh_stat_cur IS
SELECT
	status
FROM
	user_objects
WHERE
	object_name = 'IGS_AD_TST_UH_PKG' AND
	object_type = 'PACKAGE BODY';

chk_uh_stat_rec chk_uh_stat_cur%ROWTYPE;

CURSOR session_id_cur IS
SELECT
	igs_ad_tstuh_s.NEXTVAL session_id
FROM
	sys.dual;

session_id_rec session_id_cur%ROWTYPE;

BEGIN
	SAVEPOINT beforeuk;
	--
	-- Check the status of the user hook package procedure
	--
	OPEN chk_uh_stat_cur;
	FETCH chk_uh_stat_cur INTO chk_uh_stat_rec;
	CLOSE chk_uh_stat_cur;

	--
	-- If the status is INVALID then raise appropriate message
	-- If the status is VALID then call the user hook procedure after generating
	-- the session ID
	--
	IF chk_uh_stat_rec.status = 'INVALID' THEN
		p_session_id := NULL;
		RAISE INVALID_USER_HOOK;
	ELSE
		--
		-- Set the savepoint and generate the session id
		--
		OPEN session_id_cur;
		FETCH session_id_cur INTO session_id_rec;
		CLOSE session_id_cur;
		p_session_id := session_id_rec.session_id;
		igs_ad_tst_uh_pkg.convert_test_scr_uk(
			p_person_id => p_person_id,
			p_session_id => p_session_id);
	END IF;
EXCEPTION
	WHEN INVALID_USER_HOOK THEN
		FND_MESSAGE.SET_NAME('IGS','IGS_AD_UH_INVALID');
		FND_MESSAGE.SET_TOKEN('NAME',l_object_name);
		igs_ge_msg_stack.add;
		APP_EXCEPTION.RAISE_EXCEPTION;
	WHEN OTHERS THEN
		p_session_id := NULL;
		ROLLBACK TO beforeuk;
		FND_MESSAGE.SET_NAME('IGS','IGS_AD_UH_UNHAND_EXCEPTION');
		FND_MESSAGE.SET_TOKEN('NAME','igs_ad_tstuh_call_pkg.call_user_hook');
		igs_ge_msg_stack.add;
		APP_EXCEPTION.RAISE_EXCEPTION;
END call_user_hook;
END IGS_AD_TSTUH_CALL_PKG;

/
