--------------------------------------------------------
--  DDL for Package Body JTS_CONFIG_VER_STATUS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTS_CONFIG_VER_STATUS_PVT" as
/* $Header: jtsvcvsb.pls 115.6 2002/04/10 18:10:23 pkm ship    $ */


-- --------------------------------------------------------------------
-- Package name     : JTS_CONFIG_VER_STATUS_PVT
-- Purpose          : Version's Replay Statuses, Dates, By, and Version
--			Statuses.
-- History          : 25-Feb-02  Sung Ha Huh  Created.
-- NOTE             :
-- --------------------------------------------------------------------


-- Checks if status is a Replay Status
FUNCTION IN_REPLAY_STATUS(p_api_version	IN  Number,
 			p_status		IN  Varchar2) RETURN BOOLEAN IS
   l_api_version   CONSTANT NUMBER        := 1.0;
   l_api_name      CONSTANT VARCHAR2 (30) := 'IN_REPLAY_STATUS';
   l_full_name     CONSTANT VARCHAR2 (60) := G_PKG_NAME || '.' || l_api_name;
BEGIN
   IF NOT fnd_api.compatible_api_call ( l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME
                                      )
   THEN
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;

   -- Replay Status column, could change depending on the business logic
   IF (  p_status IN (C_SUBMIT_REPLAY_STATUS, C_FAIL_REPLAY_STATUS, C_CANCEL_REPLAY_STATUS,
			     C_SUCCESS_REPLAY_STATUS, C_ERROR_REPLAY_STATUS,
			     C_NOSUBMIT_REPLAY_STATUS, C_RUNNING_REPLAY_STATUS)) THEN
         return TRUE;
   ELSE  return FALSE;
   END IF;

EXCEPTION
   WHEN OTHERS THEN
	APP_EXCEPTION.RAISE_EXCEPTION;
END IN_REPLAY_STATUS;

-- Checks if status is Version Status
FUNCTION IN_VERSION_STATUS(p_api_version	IN  Number,
   				p_status	IN  Varchar2) return BOOLEAN IS
   l_api_version   CONSTANT NUMBER        := 1.0;
   l_api_name      CONSTANT VARCHAR2 (30) := 'IN_VERSION_STATUS';
   l_full_name     CONSTANT VARCHAR2 (60) := G_PKG_NAME || '.' || l_api_name;
BEGIN
   IF NOT fnd_api.compatible_api_call ( l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME
                                      )
   THEN
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;

   -- Version Status column, could change depending on the business logic
   IF (p_status IN (C_INIT_VERSION_STATUS, C_PROCESS_VERSION_STATUS, C_COMPLETE_VERSION_STATUS)) THEN
   	return TRUE;
   ELSE return FALSE;
   END IF;

EXCEPTION
   WHEN OTHERS THEN
	APP_EXCEPTION.RAISE_EXCEPTION;
END IN_VERSION_STATUS;


-- Checks if status indicates that a version has not been replayed
-- Assumption: in_replay_status has already been called
PROCEDURE NOT_REPLAYED(p_api_version		IN  Number,
   			p_status		IN  Varchar2,
 			x_in_notreplayed	OUT boolean) IS
   l_api_version   CONSTANT NUMBER        := 1.0;
   l_api_name      CONSTANT VARCHAR2 (30) := 'NOT_REPLAYED';
   l_full_name     CONSTANT VARCHAR2 (60) := G_PKG_NAME || '.' || l_api_name;
BEGIN
   IF NOT fnd_api.compatible_api_call ( l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME
                                      )
   THEN
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;

   -- Replay has been cancelled or Replay was never submitted, could change depending on the business logic
   IF (p_status = C_NOSUBMIT_REPLAY_STATUS OR p_status = C_CANCEL_REPLAY_STATUS) THEN
       x_in_notreplayed := TRUE;
   ELSE
       x_in_notreplayed :=  FALSE;
   END IF;
EXCEPTION
   WHEN OTHERS THEN
	APP_EXCEPTION.RAISE_EXCEPTION;
END NOT_REPLAYED;

-- Checks if any version under a configuration has been replayed
PROCEDURE ANY_VERSION_REPLAYED(p_api_version	IN  Number,
   				p_config_id	IN  Number,
				x_replayed	OUT BOOLEAN) IS
   l_api_version   	CONSTANT NUMBER        := 1.0;
   l_api_name      	CONSTANT VARCHAR2 (30) := 'ANY_VERSION_REPLAYED';
   l_full_name     	CONSTANT VARCHAR2 (60) := G_PKG_NAME || '.' || l_api_name;
   l_versions_csr  	JTS_CONFIG_UTIL_PVT.Versions_Csr_Type;
   l_version_id	   	JTS_CONFIG_VERSIONS_B.version_id%TYPE;
   l_status_code   	JTS_CONFIG_VERSION_STATUSES.status_code%TYPE;
   l_replay_status   	FND_LOOKUP_VALUES.meaning%TYPE;
   l_version_status_code 	JTS_CONFIG_VERSION_STATUSES.status_code%TYPE;
   l_version_status 		FND_LOOKUP_VALUES.meaning%TYPE;
   l_replayed_date	JTS_CONFIG_VERSION_STATUSES.last_update_date%TYPE;
   l_replayed_by_name 	FND_USER.user_name%TYPE;
   l_not_replayed	BOOLEAN := TRUE;
   l_in_replay		BOOLEAN := FALSE;
BEGIN
   IF NOT fnd_api.compatible_api_call ( l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME
                                      )
   THEN
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;

   JTS_CONFIG_UTIL_PVT.GET_VERSIONS_CURSOR(p_api_version,
					   p_config_id,
					   l_versions_csr);

   x_replayed := FALSE;
   LOOP
      FETCH l_versions_csr INTO l_version_id;
      EXIT WHEN l_versions_csr%NOTFOUND;
      GET_VERSION_STATUS_DATA(p_api_version,
			l_version_id,
			l_status_code,
			l_version_status_code,
			l_replay_status,
			l_version_status,
			l_replayed_date,
			l_replayed_by_name);
      IF (IN_REPLAY_STATUS(p_api_version, l_status_code)) THEN
	  NOT_REPLAYED(p_api_version, l_status_code, l_not_replayed);
	  If (NOT l_not_replayed) then
	   	x_replayed := TRUE;
		EXIT;  --exit out of the loop
	  END IF;
      END IF;
   END LOOP;
   CLOSE l_versions_csr;

EXCEPTION
   WHEN OTHERS THEN
	APP_EXCEPTION.RAISE_EXCEPTION;
END ANY_VERSION_REPLAYED;

-- Returns replay status, version status, replayed_date,
-- replayed_by for a version
PROCEDURE GET_VERSION_STATUS_DATA (
		p_api_version		IN  Number,
		p_version_id 		IN  NUMBER,
		x_replay_status_code 	OUT VARCHAR2,
		x_version_status_code	OUT VARCHAR2,
		x_replay_status 	OUT VARCHAR2,
		x_version_status	OUT VARCHAR2,
		x_replayed_date		OUT DATE,
		x_replayed_by_name	OUT VARCHAR2) IS
   l_api_version   CONSTANT NUMBER        := 1.0;
   l_api_name      	CONSTANT VARCHAR2 (30) := 'GET_VERSION_STATUS_DATA';
   l_full_name     	CONSTANT VARCHAR2 (60) := G_PKG_NAME || '.' || l_api_name;
   l_status	   	JTS_CONFIG_VERSION_STATUSES.status_code%TYPE;
   l_meaning	   	FND_LOOKUP_VALUES.meaning%TYPE;
   l_replayed_date 	JTS_CONFIG_VERSION_STATUSES.last_update_date%TYPE;
   l_replayed_by_name   FND_USER.user_name%TYPE;
   l_replay_done   	BOOLEAN := FALSE;
   l_version_done  	BOOLEAN := FALSE;

CURSOR Statuses_Csr IS
SELECT  vs.status_code, l.meaning, vs.creation_date, u.user_name
FROM    jts_config_version_statuses vs,
	fnd_lookup_values l,
	fnd_user u
WHERE	version_id = p_version_id
AND     l.lookup_type = C_STATUS_TYPE
AND     l.lookup_code = vs.status_code
AND	u.user_id (+) = vs.created_by
ORDER BY vs.creation_date DESC;

BEGIN
   IF NOT fnd_api.compatible_api_call ( l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME
                                      )
   THEN
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;

   x_replay_status_code := NULL;
   x_replay_status := NULL;
   x_replayed_date := NULL;
   x_replayed_by_name := NULL;
   x_version_status_code := C_INIT_VERSION_STATUS;
   --x_version_status := 'New';

   l_replay_done   := FALSE;
   l_version_done  := FALSE;
   OPEN Statuses_Csr;
   LOOP
      FETCH Statuses_Csr INTO l_status, l_meaning, l_replayed_date, l_replayed_by_name;
      --exist when both replay and version statuses are found or when we have reached
      --the end of the cursor
      EXIT WHEN (Statuses_Csr%NOTFOUND OR (l_replay_done AND l_version_done));

      --status is either a version or replay status
      IF ((NOT l_version_done) AND IN_VERSION_STATUS(p_api_version, l_status) ) THEN
	 x_version_status_code := l_status;
	 x_version_status := l_meaning;
	 l_version_done := TRUE;
      ELSIF ((NOT l_replay_done) AND IN_REPLAY_STATUS(p_api_version, l_status) ) THEN
	 x_replay_status_code := l_status;
 	 x_replay_status := l_meaning;
  	 x_replayed_date := l_replayed_date;
   	 x_replayed_by_name := l_replayed_by_name;
	 l_replay_done := TRUE;
      END IF;
   END LOOP;
   CLOSE Statuses_Csr;

EXCEPTION
   WHEN OTHERS THEN
	APP_EXCEPTION.RAISE_EXCEPTION;
END GET_VERSION_STATUS_DATA;


-- Inserts a row into jts_config_version_statuses table with a
-- a certain version_id and status
PROCEDURE CREATE_VERSION_STATUS(p_api_version	IN  Number,
   				p_commit	IN  Varchar2,
   				p_version_id	IN  Number,
 				p_status	IN  Varchar2
) IS
   l_api_version   CONSTANT NUMBER        := 1.0;
   l_api_name      CONSTANT VARCHAR2 (30) := 'CREATE_VERSION_STATUS';
   l_full_name     CONSTANT VARCHAR2 (60) := G_PKG_NAME || '.' || l_api_name;
BEGIN
   IF NOT fnd_api.compatible_api_call ( l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME
                                      )
   THEN
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;

   INSERT INTO jts_config_version_statuses
   (
     VERSION_ID,
     STATUS_CODE,
     OBJECT_VERSION_NUMBER,
     CREATION_DATE,
     CREATED_BY,
     LAST_UPDATE_DATE,
     LAST_UPDATED_BY,
     LAST_UPDATE_LOGIN
   ) VALUES (
     p_version_id,
     nvl(p_status, C_INIT_VERSION_STATUS),
     1,
     sysdate,
     FND_GLOBAL.user_id,
     sysdate,
     FND_GLOBAL.user_id,
     FND_GLOBAL.user_id
   );

   IF (in_version_status(p_api_version, p_status)) THEN
      JTS_CONFIG_VERSION_PVT.update_version_stat(p_api_version,
						 p_version_id,
						 p_status);
   ELSIF (in_replay_status(p_api_version, p_status)) THEN
      JTS_CONFIG_VERSION_PVT.update_replay_data(p_api_version,
						 p_version_id,
						 p_status);
   END IF;

   IF (FND_API.to_boolean(p_commit)) THEN
      COMMIT;
   END IF;

EXCEPTION
   WHEN OTHERS THEN
	APP_EXCEPTION.RAISE_EXCEPTION;
END CREATE_VERSION_STATUS;

-- Deletes records from jts_config_version_statuses table
PROCEDURE DELETE_VERSION_STATUSES(p_api_version	IN  Number,
   				p_version_id	IN  Number) IS
   l_api_version   CONSTANT NUMBER        := 1.0;
   l_api_name      CONSTANT VARCHAR2 (30) := 'DELETE_VERSION_STATUSES';
   l_full_name     CONSTANT VARCHAR2 (60) := G_PKG_NAME || '.' || l_api_name;
BEGIN
   IF NOT fnd_api.compatible_api_call ( l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME
                                      )
   THEN
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;

   DELETE FROM jts_config_version_statuses
   WHERE  version_id = p_version_id;

EXCEPTION
   WHEN OTHERS THEN
	APP_EXCEPTION.RAISE_EXCEPTION;
END DELETE_VERSION_STATUSES;

-- Deletes records from jts_config_version_statuses table for all
-- versions with a certain configuration id
PROCEDURE DELETE_CONFIG_VER_STATUSES(p_api_version	IN  Number,
   				p_config_id	IN  Number) IS
   l_api_version   CONSTANT NUMBER        := 1.0;
   l_api_name      CONSTANT VARCHAR2 (30) := 'DELETE_CONFIG_VER_STATUSES';
   l_full_name     CONSTANT VARCHAR2 (60) := G_PKG_NAME || '.' || l_api_name;
   versions_csr    JTS_CONFIG_UTIL_PVT.Versions_Csr_Type;
   l_version_id	   JTS_CONFIG_VERSION_STATUSES.version_id%TYPE;
BEGIN
   IF NOT fnd_api.compatible_api_call ( l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME
                                      )
   THEN
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;

   JTS_CONFIG_UTIL_PVT.GET_VERSIONS_CURSOR(p_api_version,
					   p_config_id,
					   versions_csr);
   LOOP
     FETCH versions_csr INTO l_version_id;
     EXIT WHEN versions_csr%NOTFOUND;

     DELETE FROM jts_config_version_flows
     WHERE  version_id = l_version_id;
   END LOOP;

   CLOSE versions_csr;

EXCEPTION
   WHEN OTHERS THEN
	APP_EXCEPTION.RAISE_EXCEPTION;
END DELETE_CONFIG_VER_STATUSES;

END JTS_CONFIG_VER_STATUS_PVT;

/
