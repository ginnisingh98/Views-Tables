--------------------------------------------------------
--  DDL for Package Body FND_PROFILE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_PROFILE" AS
   /* $Header: AFPFPROB.pls 120.18.12010000.17 2016/12/06 15:27:32 rarmaly ship $ */

   TYPE val_tab_type IS TABLE OF VARCHAR2(255) INDEX BY BINARY_INTEGER;
   TYPE name_tab_type IS TABLE OF VARCHAR2(80) INDEX BY BINARY_INTEGER;

   /*
   ** define the internal table that will cache the profile values
   ** val_tab(x) is associated with name_tab(x) and dbflag(x)
   */
   val_tab    val_tab_type; /* the table of values for the Generic PUT cache */
   name_tab   name_tab_type; /* the table of names for the Generic PUT cache */
   table_size BINARY_INTEGER := 2147483646; /* the size of above tables*/
   /* change INSERTED to number to account for PUT deletes */
   inserted NUMBER := 0; /* count of PUT profiles stored */

   /*
   ** define the internal tables that will cache the profile values
   ** for the different levels.
   */
   user_val_tab    val_tab_type; /* the user-level cache table of values */
   user_name_tab   name_tab_type; /* the user-level cache table of names */
   resp_val_tab    val_tab_type; /* the resp-level cache table of values */
   resp_name_tab   name_tab_type; /* the resp-level cache table of names */
   appl_val_tab    val_tab_type; /* the appl-level cache table of values */
   appl_name_tab   name_tab_type; /* the appl-level cache table of names */
   site_val_tab    val_tab_type; /* the site-level cache table of values */
   site_name_tab   name_tab_type; /* the site-level cache table of names */
   server_val_tab  val_tab_type; /* the server-level cache table of values */
   server_name_tab name_tab_type; /* the server-level cache table of names */
   org_val_tab     val_tab_type; /* the appl-level cache table of values */
   org_name_tab    name_tab_type; /* the appl-level cache table of names */

   /*
   ** Define the current level context
   */
   profiles_user_id    NUMBER := -1;
   profiles_resp_id    NUMBER := -1;
   profiles_appl_id    NUMBER := -1;
   profiles_server_id  NUMBER := -1;
   profiles_org_id     NUMBER := -1;
   profiles_session_id NUMBER := -1;

   /*
   ** Constant string used to indicate that a cache entry is undefined.
   */
   fnd_undefined_value VARCHAR2(30) := '**FND_UNDEFINED_VALUE**';

   /*
   ** Constant string used to indicate a delete request in PUT cache.
   */
   fnd_delete_value VARCHAR2(30) := '**FND_DELETE_VALUE**';

   /*
   ** Save the enabled flags and hierarchy of the last fetched profile
   ** option.
   */
   profile_option_name VARCHAR2(80);
   profile_option_id   NUMBER;
   profile_aid         NUMBER;
   user_changeable     VARCHAR2(1) := 'N'; -- Bug 4257739
   user_enabled        VARCHAR2(1) := 'N';
   resp_enabled        VARCHAR2(1) := 'N';
   app_enabled         VARCHAR2(1) := 'N';
   site_enabled        VARCHAR2(1) := 'N';
   server_enabled      VARCHAR2(1) := 'N';
   org_enabled         VARCHAR2(1) := 'N';
   hierarchy           VARCHAR2(8) := 'SECURITY';

   /*
   ** Version number to be used to invalidate cache when a change in
   ** version is detected.
   */
   user_cache_version   NUMBER := 0;
   resp_cache_version   NUMBER := 0;
   appl_cache_version   NUMBER := 0;
   site_cache_version   NUMBER := 0;
   server_cache_version NUMBER := 0;
   org_cache_version    NUMBER := 0;

   /*
   ** Constant strings for the cache names being stored in
   ** FND_CACHE_VERSIONS.
   */
   user_cache   VARCHAR2(30) := 'USER_PROFILE_CACHE';
   resp_cache   VARCHAR2(30) := 'RESP_PROFILE_CACHE';
   appl_cache   VARCHAR2(30) := 'APPL_PROFILE_CACHE';
   site_cache   VARCHAR2(30) := 'SITE_PROFILE_CACHE';
   server_cache VARCHAR2(30) := 'SERVER_PROFILE_CACHE';
   org_cache    VARCHAR2(30) := 'ORG_PROFILE_CACHE';

   /*
   ** Declarations for Server/Resp Level.  These were intentionally kept
   ** separate from the other level declarations.
   */
   /* the server/resp-level table of values */
   servresp_val_tab val_tab_type;
   /* the server/resp-level table of names */
   servresp_name_tab      name_tab_type;
   servresp_enabled       VARCHAR2(1) := 'N';
   servresp_cache_version NUMBER := 0;
   servresp_cache         VARCHAR2(30) := 'SERVRESP_PROFILE_CACHE';

   /*
   ** Global variable used to identify if a profile option exists or not.
   ** This will determine whether the query for the profile_info cursor is
   ** to be executed.
   */
   profile_option_exists BOOLEAN := TRUE;

   /*
   ** Global variable used to indicate that the PUT cache was cleared during
   ** the current run of FND_PROFILE.INITIALIZE -- Bug 12875860 - PER Rewrite
   */
   put_cache_is_clear BOOLEAN;

   /*
   ** Global variable used to identify core logging is enabled or not.
   ** Added for Bug 5599946: APPSPERF:FND:LOGGING CALLS IN FND_PROFILE CAUSING
   ** PERFORMANCE REGRESSION
   */
   corelog_is_enabled BOOLEAN := fnd_core_log.is_enabled;

   /*
   ** Global variable that stores Applications Release Version
   */
   release_version NUMBER := fnd_release.major_version;

   /*
   ** CORELOG - wrapper to CORELOG with defaulting current profile context.
   */
   PROCEDURE corelog
   (
      log_profname          IN VARCHAR2,
      log_profval           IN VARCHAR2 DEFAULT NULL,
      current_api           IN VARCHAR2,
      log_user_id           IN NUMBER DEFAULT profiles_user_id,
      log_responsibility_id IN NUMBER DEFAULT profiles_resp_id,
      log_application_id    IN NUMBER DEFAULT profiles_appl_id,
      log_org_id            IN NUMBER DEFAULT profiles_org_id,
      log_server_id         IN NUMBER DEFAULT profiles_server_id
   ) IS
   BEGIN
      fnd_core_log.write_profile(log_profname,
                                 log_profval,
                                 current_api,
                                 log_user_id,
                                 log_responsibility_id,
                                 log_application_id,
                                 log_org_id,
                                 log_server_id);
   END corelog;

   /*
   ** CHECK_CACHE_VERSIONS
   **
   ** Bug 5477866: INCONSISTENT VALUES RETURNED BY FND_PROFILE.VALUE_SPECIFIC
   ** Broke this algorithm out of INITIALIZE so that VALUE_SPECIFIC can use
   ** the algorithm also.
   */
   PROCEDURE check_cache_versions IS
   BEGIN
      /*
      ** Bug 4864218: CU2: DATE FORMAT CHANGE IN PREFERENCES DOES NOT TAKE
      ** EFFECT IMMEDIATELY
      **
      ** Profile option value cache invalidation relies on cache versions
      ** to signal whether level caches should be purged.  Cache versions
      ** are stored in PL/SQL tables to utilize bulk loading for better
      ** performance.  Due to the performance enhancements made for bug
      ** 3901095, a cache refresh issue was introduced.  The PL/SQL tables
      ** used for cache versions were not being refreshed properly, so the
      ** profile option value cache invalidation was not performing properly.
      **
      ** The following call refreshes the cache version PL/SQL tables so that
      ** the version check, used to determine whether level caches are to be
      ** purged, are performed properly.
      **
      ** This change will introduce a slight performance hit but should not
      ** be as severe as the performance levels that bug 3901095 had.
      */
      fnd_cache_versions_pkg.get_values;

      /*
      ** Add cache(s) entries in FND_CACHE_VERSIONS if one does not exist.
      ** If a cache exists however, we will check to see if there has been any
      ** changes within that profile level to refresh it (delete it).
      */
      IF (fnd_cache_versions_pkg.check_version(user_cache,
                                               user_cache_version) = FALSE) THEN
         IF (user_cache_version = -1) THEN
            fnd_cache_versions_pkg.add_cache_name(user_cache);
            user_cache_version := 0;
         ELSE
            user_name_tab.delete();
            user_val_tab.delete();
         END IF;
      END IF;

      IF (fnd_cache_versions_pkg.check_version(resp_cache,
                                               resp_cache_version) = FALSE) THEN
         IF (resp_cache_version = -1) THEN
            fnd_cache_versions_pkg.add_cache_name(resp_cache);
            resp_cache_version := 0;
         ELSE
            resp_name_tab.delete();
            resp_val_tab.delete();
         END IF;
      END IF;

      IF (fnd_cache_versions_pkg.check_version(appl_cache,
                                               appl_cache_version) = FALSE) THEN
         IF (appl_cache_version = -1) THEN
            fnd_cache_versions_pkg.add_cache_name(appl_cache);
            appl_cache_version := 0;
         ELSE
            appl_name_tab.delete();
            appl_val_tab.delete();
         END IF;
      END IF;

      IF (fnd_cache_versions_pkg.check_version(org_cache, org_cache_version) =
         FALSE) THEN
         IF (org_cache_version = -1) THEN
            fnd_cache_versions_pkg.add_cache_name(org_cache);
            org_cache_version := 0;
         ELSE
            org_name_tab.delete();
            org_val_tab.delete();
         END IF;
      END IF;

      IF (fnd_cache_versions_pkg.check_version(server_cache,
                                               server_cache_version) =
         FALSE) THEN
         IF (server_cache_version = -1) THEN
            fnd_cache_versions_pkg.add_cache_name(server_cache);
            server_cache_version := 0;
         ELSE
            server_name_tab.delete();
            server_val_tab.delete();
         END IF;
      END IF;

      IF (fnd_cache_versions_pkg.check_version(servresp_cache,
                                               servresp_cache_version) =
         FALSE) THEN
         IF (servresp_cache_version = -1) THEN
            fnd_cache_versions_pkg.add_cache_name(servresp_cache);
            servresp_cache_version := 0;
         ELSE
            servresp_name_tab.delete();
            servresp_val_tab.delete();
         END IF;
      END IF;

      IF (fnd_cache_versions_pkg.check_version(site_cache,
                                               site_cache_version) = FALSE) THEN
         IF (site_cache_version = -1) THEN
            fnd_cache_versions_pkg.add_cache_name(site_cache);
            site_cache_version := 0;
         ELSE
            site_name_tab.delete();
            site_val_tab.delete();
         END IF;
      END IF;

   END check_cache_versions;

   /*
   ** FIND - find index of a profile option name in the given cache table
   **
   ** RETURNS
   **    table index if found, TABLE_SIZE if not found.
   */
   FUNCTION find
   (
      name_upper         IN VARCHAR2,
      nametable          IN name_tab_type,
      profile_hash_value IN BINARY_INTEGER
   ) RETURN BINARY_INTEGER IS

      tab_index  BINARY_INTEGER;
      FOUND      BOOLEAN;
      hash_value NUMBER;

      /* Bug 4271555: UPPER function is not to be called in FIND.  Instead, the
      ** API calling find passes UPPER(profile option name).
      ** NAME_UPPER varchar2(80);
      */
   BEGIN

      /* Bug 4271555: UPPER function is not to be called in FIND.  Instead, the
      ** API calling find passes UPPER(profile option name).
      ** NAME_UPPER := upper(NAME);
      */

      /* Bug 5603664: APPSPERF:FND:OPTIMIZE FND_PROFILE.VALUE
      ** This is a failsafe. PROFILE_HASH_VALUE should always be passed by the
      ** calling api.
      **
      ** TAB_INDEX := dbms_utility.get_hash_value(NAME_UPPER,1,TABLE_SIZE);
      */
      IF (profile_hash_value IS NULL) THEN
         tab_index := dbms_utility.get_hash_value(name_upper, 1, table_size);
      ELSE
         tab_index := profile_hash_value;
      END IF;

      IF (nametable.exists(tab_index)) THEN
         IF (nametable(tab_index) = name_upper) THEN
            RETURN tab_index;
         ELSE
            hash_value := tab_index;
            FOUND      := FALSE;

            WHILE (tab_index < table_size)
                  AND (NOT FOUND) LOOP
               IF (nametable.exists(tab_index)) THEN
                  IF nametable(tab_index) = name_upper THEN
                     FOUND := TRUE;
                  ELSE
                     tab_index := tab_index + 1;
                  END IF;
               ELSE
                  RETURN table_size + 1;
               END IF;
            END LOOP;

            IF (NOT FOUND) THEN
               -- Didn't find any till the end
               tab_index := 1; -- Start from the beginning
               WHILE (tab_index < hash_value)
                     AND (NOT FOUND) LOOP
                  IF (nametable.exists(tab_index)) THEN
                     IF nametable(tab_index) = name_upper THEN
                        FOUND := TRUE;
                     ELSE
                        tab_index := tab_index + 1;
                     END IF;
                  ELSE
                     RETURN table_size + 1;
                  END IF;
               END LOOP;
            END IF;

            IF (NOT FOUND) THEN
               RETURN table_size + 1; -- Return a higher value
            END IF;
         END IF;
      ELSE
         RETURN table_size + 1;
      END IF;

      RETURN tab_index;

   EXCEPTION
      WHEN OTHERS THEN
         -- The entry doesn't exist
         RETURN table_size + 1;
   END find;

   /*
   ** FIND - find index of a profile option name in the Generic PUT cache table
   ** NAME_TAB, not the level cache tables.
   **
   ** RETURNS
   **    table index if found, TABLE_SIZE if not found.
   */
   FUNCTION find(NAME IN VARCHAR2) RETURN BINARY_INTEGER IS

      -- bug 14773322 - index variable to check for deleted value
      tab_index BINARY_INTEGER;

   BEGIN
      /* Bug 5603664: APPSPERF:FND:OPTIMIZE FND_PROFILE.VALUE
      ** UPPER function call removed, calling API would have done UPPER before
      ** calling FIND
      ** return FIND(UPPER(NAME),NAME_TAB);
      */
      -- bug 14773322 - find index variable to check for deleted value
      tab_index := find(NAME,
                  name_tab,
                  dbms_utility.get_hash_value(NAME, 1, table_size));
      -- bug 14773322 - check for valid index of profile name with deleted value
      IF (tab_index < table_size AND
          val_tab(tab_index) = fnd_delete_value) THEN
         -- The entry doesn't exist
         RETURN table_size + 1;
      END IF;

      RETURN tab_index;

   EXCEPTION
      WHEN OTHERS THEN
         -- The entry doesn't exist
         RETURN table_size + 1;
   END find;

   /*
   ** PUT - Set or Insert a profile option value in cache
   */
   PROCEDURE put
   (
      NAME               IN VARCHAR2, -- should be passed UPPER value
      val                IN VARCHAR2,
      nametable          IN OUT NOCOPY name_tab_type,
      valuetable         IN OUT NOCOPY val_tab_type,
      profile_hash_value IN BINARY_INTEGER
   ) IS

      table_index BINARY_INTEGER;
      stored      BOOLEAN;
      hash_value  BINARY_INTEGER;

      -- bug 14773322 - remove dodelete procedure which deleted the name/value
      -- from the PUT cache and searched for existing Collisions to move them back up.
      -- Instead, to avoid the complexity of handling potential but rare collisions
      -- store the fnd_delete_value flag as the value and ignore it on find

   BEGIN
      /* Bug 5603664: APPSPERF:FND:OPTIMIZE FND_PROFILE.VALUE
      ** Assignment removed since calling API would have used UPPER and passed
      ** resulting value for NAME into PUT
      **
      ** NAME_UPPER := upper(NAME);
      */

      -- Log API entry
      IF corelog_is_enabled THEN
         corelog(NAME, val, 'Enter FP.P');
      END IF;

      /* Bug 5603664: APPSPERF:FND:OPTIMIZE FND_PROFILE.VALUE
      ** This is a failsafe. PROFILE_HASH_VALUE should always be passed by the
      ** calling api.
      */
      IF (profile_hash_value IS NULL) THEN
         table_index := dbms_utility.get_hash_value(NAME, 1, table_size);
      ELSE
         table_index := profile_hash_value;
      END IF;

      -- Search for the option name
      stored := FALSE;

      IF (nametable.exists(table_index)) THEN
         hash_value := table_index; -- Store the current spot
         IF (nametable(table_index) = NAME) THEN
            -- Found the profile indexed by the hash value
            -- bug 14773322 - remove call to dodelete procedure

            valuetable(table_index) := val; -- Store the new value
            stored := TRUE;

         ELSE
            -- Collision
            WHILE (table_index < table_size)
                  AND (NOT stored) LOOP
               IF (nametable.exists(table_index)) THEN
                  IF (nametable(table_index) = NAME) THEN
                     -- Found the profile indexed higher than hash
                     -- bug 14773322 - remove call to dodelete procedure

                     valuetable(table_index) := val; -- Store the new value
                     stored := TRUE;
                  ELSE
                     table_index := table_index + 1;
                  END IF;
               ELSE
                  -- Log API collision - bug 14773322
                  IF corelog_is_enabled THEN
                     corelog(NAME, val, 'Collision FP.P stored higher than hash');
                  END IF;
                   -- Store the value and profile for the first time
                  valuetable(table_index) := val;
                  nametable(table_index) := NAME;
                  stored := TRUE;
               END IF;
            END LOOP;

            IF (NOT stored) THEN
               -- Didn't find any free bucket till the end
               table_index := 1;
               WHILE (table_index < hash_value)
                     AND (NOT stored) LOOP
                  IF (nametable.exists(table_index)) THEN
                     IF (nametable(table_index) = NAME) THEN
                        -- Found the profile indexed lower than hash value
                        -- bug 14773322 - remove call to dodelete procedure

                        valuetable(table_index) := val; -- Store the new value
                        stored := TRUE;
                     ELSE
                        table_index := table_index + 1;
                     END IF;
                  ELSE
                     -- Log API collision - bug 14773322
                     IF corelog_is_enabled THEN
                        corelog(NAME, val, 'Collision FP.P stored lower than hash');
                     END IF;
                     -- Store the value and profile for the first time
                     valuetable(table_index) := val;
                     nametable(table_index) := NAME;
                     stored := TRUE;
                  END IF;
               END LOOP;
            END IF;
         END IF;
      ELSE
         -- Store the value and profile for the first time
         -- bug 14773322 - allow delete value flag to be stored

         nametable(table_index) := NAME; -- Enter the profile
         valuetable(table_index) := val; -- Store its value
         stored := TRUE;
      END IF;

      -- bug 16327915 removed this section of code
      -- the inserted PUT counter should only be tracking
      -- the profiles inserted into generic PUT cache
      --IF (stored)
      --   AND (val <> fnd_delete_value) THEN
      --   inserted := inserted + 1; /* Increment the PUT counter */
      --END IF;

      -- Log API exit
      IF corelog_is_enabled THEN
         corelog(NAME, val, 'Exit FP.P');
      END IF;

   EXCEPTION
      WHEN OTHERS THEN
        -- bug14773322 unnoticed exception ORA-01403: no data found
        -- add a corelog dump on exception
        IF corelog_is_enabled THEN
            fnd_core_log.put_line(NAME || ':' || val ||':' ||
                                  'PUT raised exception. SQLCODE:' || SQLCODE);
            -- output exception to corelog
            fnd_core_log.put_line(dbms_utility.format_error_stack);
            -- output call stack to corelog
            fnd_core_log.put_line(dbms_utility.format_call_stack);
         END IF;

   END put;

   /*
   ** PUT - Set or Insert a profile option value into the generic PUT cache
   */
   PROCEDURE put
   (
      NAME IN VARCHAR2,
      val  IN VARCHAR2
   ) IS
      /* Bug 5603664: APPSPERF:FND:OPTIMIZE FND_PROFILE.VALUE
      ** UPPER call is done early and value is passed on, which minimizes
      ** number of UPPER calls
      */
      table_index BINARY_INTEGER;  -- bug 16327915 manage PUT count
      name_upper VARCHAR2(80) := upper(NAME);
   BEGIN

      -- Log GENERIC PUT Entry
      IF corelog_is_enabled THEN
         corelog(name_upper, val, 'Enter Generic FP.P');
      END IF;

      -- bug 16327915 manage PUT count of Public PUT cache
      -- the inserted PUT counter should be tracking
      -- the actual number of true profile values in PUT cache
      -- not every call to insert any profile value
      -- Search for existing profile option in Public PUT cache
      table_index := find(name_upper);
      -- if the profile exists in the Public PUT cache
      IF (table_index < table_size) THEN
         -- if profile value is NOT NULL or being marked for delete
         IF ((val <> fnd_delete_value) AND
             (val IS NOT NULL)) THEN
            -- if existing profile value is marked deleted
            IF (val_tab(table_index) = fnd_delete_value) THEN
              -- we will be reviving the current deleted value
              -- increment the PUT counter
              inserted := inserted + 1;
            END IF;
         ELSE  -- we are marking this profile for delete
            -- if existing profile value is NOT marked deleted
            IF (val_tab(table_index) <> fnd_delete_value) THEN
               -- we will be removing the current value
               -- decrement PUT counter
               IF (inserted > 0) THEN
                 inserted := inserted - 1;
               END IF;
            END IF;
         END IF;
      ELSE -- profile value NOT existing in Public PUT cache
         -- if profile value is NOT NULL or being marked for delete
         IF ((val <> fnd_delete_value) AND
             (val IS NOT NULL)) THEN
            -- we are inserting a new value
            inserted := inserted + 1;
         END IF;
      END IF;
      /* Bug 5603664: APPSPERF:FND:OPTIMIZE FND_PROFILE.VALUE
      ** Call dbms_utility.get_hash_value and pass as an argument to PUT
      */
      -- Private PUT call
      put(name_upper,
          val,
          name_tab,
          val_tab,
          dbms_utility.get_hash_value(name_upper, 1, table_size));

      -- Log GENERIC PUT Exit
      IF corelog_is_enabled THEN
         corelog(name_upper, val, 'Exit Generic FP.P Count=' || inserted);
      END IF;

   END put;

   /*
   ** GET_SPECIFIC_LEVEL_WNPS -
   **   Get a profile value for a specific user/resp/appl level without
   **   changing package state.
   */
   PROCEDURE get_specific_level_wnps
   (
      name_z                    IN VARCHAR2, -- should be passed UPPER value
      level_id_z                IN NUMBER,
      level_value_z             IN NUMBER,
      level_value_application_z IN NUMBER,
      val_z                     OUT NOCOPY VARCHAR2,
      cached_z                  OUT NOCOPY BOOLEAN,
      level_value2_z            IN NUMBER DEFAULT NULL,
      profile_hash_value        IN BINARY_INTEGER
   ) IS

      tableindex         BINARY_INTEGER;
      contextlevelvalue  NUMBER;
      nametable          name_tab_type;
      valuetable         val_tab_type;
      contextlevelvalue2 NUMBER; -- Added for Server/Resp Hierarchy
      hashvalue          BINARY_INTEGER;

   BEGIN

      val_z    := NULL;
      cached_z := FALSE;

      /* Bug 3679441:  The collection assignments, i.e. assigning the entire
      ** collection SITE_NAME_TAB to nameTable, was causing a performance
      ** degradation and should be avoided.  The suggestions put forth in bug
      ** 3679441 by OM Product Team are being implemented as the solution.
      ** Specifically, instead of assigning the entire collection to local
      ** variables nameTable and valueTable, just pass the 'name' collection
      ** into FIND to determine the tableIndex and if applicable, use the
      ** 'value' collection to obtain the value using the tableIndex
      ** obtained. This fix was approved by the ATG Performance Team.
      */

      /* Bug 5603664: APPSPERF:FND:OPTIMIZE FND_PROFILE.VALUE
      ** This is a failsafe. PROFILE_HASH_VALUE should always be passed by the
      ** calling api.
      */
      IF profile_hash_value IS NULL THEN
         hashvalue := dbms_utility.get_hash_value(name_z, 1, table_size);
      ELSE
         hashvalue := profile_hash_value;
      END IF;

      /* Bug 5603664: APPSPERF:FND:OPTIMIZE FND_PROFILE.VALUE
      ** Removed all UPPER in FIND calls since calling API would have already
      ** used UPPER and passed in resulting name_z. This minimizes UPPER calls.
      */
      IF (level_id_z = 10001) THEN
         contextlevelvalue := 0;
         IF (contextlevelvalue = level_value_z) THEN
            tableindex := find(name_z, site_name_tab, hashvalue);
            IF (tableindex < table_size) THEN
               val_z    := site_val_tab(tableindex);
               cached_z := TRUE;
               RETURN;
            END IF;
         END IF;
      ELSIF (level_id_z = 10002) THEN
         contextlevelvalue := profiles_appl_id;
         IF (contextlevelvalue = level_value_z) THEN
            tableindex := find(name_z, appl_name_tab, hashvalue);
            IF (tableindex < table_size) THEN
               val_z    := appl_val_tab(tableindex);
               cached_z := TRUE;
               RETURN;
            END IF;
         END IF;
      ELSIF (level_id_z = 10003) THEN
         contextlevelvalue := profiles_resp_id;
         IF ((contextlevelvalue = level_value_z) AND
            -- Level-value application ID needs to be taken into account for
            -- Resp-level cache if level_id = 10003
            (profiles_appl_id = level_value_application_z)) THEN
            tableindex := find(name_z, resp_name_tab, hashvalue);
            IF (tableindex < table_size) THEN
               val_z    := resp_val_tab(tableindex);
               cached_z := TRUE;
               RETURN;
            END IF;
         END IF;
      ELSIF (level_id_z = 10004) THEN
         contextlevelvalue := profiles_user_id;
         IF (contextlevelvalue = level_value_z) THEN
            tableindex := find(name_z, user_name_tab, hashvalue);
            IF (tableindex < table_size) THEN
               val_z    := user_val_tab(tableindex);
               cached_z := TRUE;
               RETURN;
            END IF;
         END IF;
      ELSIF (level_id_z = 10005) THEN
         contextlevelvalue := profiles_server_id;
         IF (contextlevelvalue = level_value_z) THEN
            tableindex := find(name_z, server_name_tab, hashvalue);
            IF (tableindex < table_size) THEN
               val_z    := server_val_tab(tableindex);
               cached_z := TRUE;
               RETURN;
            END IF;
         END IF;
      ELSIF (level_id_z = 10006) THEN
         contextlevelvalue := profiles_org_id;
         IF (contextlevelvalue = level_value_z) THEN
            tableindex := find(name_z, org_name_tab, hashvalue);
            IF (tableindex < table_size) THEN
               val_z    := org_val_tab(tableindex);
               cached_z := TRUE;
               RETURN;
            END IF;
         END IF;
      ELSIF (level_id_z = 10007) THEN
         -- Added for Server/Resp Hierarchy
         contextlevelvalue  := profiles_resp_id;
         contextlevelvalue2 := profiles_server_id;
         IF ((contextlevelvalue = level_value_z) AND
            (contextlevelvalue2 = level_value2_z) AND
            -- Level-value application ID needs to be taken into account for
            -- ServResp-level cache if level_id = 10007
            (profiles_appl_id = level_value_application_z)) THEN
            tableindex := find(name_z, servresp_name_tab, hashvalue);
            IF (tableindex < table_size) THEN
               val_z    := servresp_val_tab(tableindex);
               cached_z := TRUE;
               RETURN;
            END IF;
         END IF;
      END IF;

   END get_specific_level_wnps;

   PROCEDURE get_specific_level_db
   (
      profile_id_z     IN NUMBER,
      application_id_z IN NUMBER DEFAULT NULL,
      level_id_z       IN NUMBER,
      level_value_z    IN NUMBER,
      level_value_aid  IN NUMBER DEFAULT NULL,
      val_z            OUT NOCOPY VARCHAR2,
      defined_z        OUT NOCOPY BOOLEAN,
      level_value2_z   IN NUMBER DEFAULT NULL
   ) IS

      --
      -- this cursor fetches profile option values for site, application,
      -- and user levels (10001/10002/10004)
      --
      CURSOR value_uas
      (
         pid  NUMBER,
         aid  NUMBER,
         lid  NUMBER,
         lval NUMBER
      ) IS
         SELECT profile_option_value
           FROM fnd_profile_option_values
          WHERE profile_option_id = pid
            AND application_id = aid
            AND level_id = lid
            AND level_value = lval
            AND profile_option_value IS NOT NULL;
      --
      -- this cursor fetches profile option values at the responsibility
      -- level (10003)
      --
      CURSOR value_resp
      (
         pid  NUMBER,
         aid  NUMBER,
         lval NUMBER,
         laid NUMBER
      ) IS
         SELECT profile_option_value
           FROM fnd_profile_option_values
          WHERE profile_option_id = pid
            AND application_id = aid
            AND level_id = 10003
            AND level_value = lval
            AND level_value_application_id = laid
            AND profile_option_value IS NOT NULL;
      --
      -- this cursor fetches profile option values at the server/resp
      -- level (10007)
      --
      CURSOR value_servresp
      (
         pid   NUMBER,
         aid   NUMBER,
         lval  NUMBER,
         laid  NUMBER,
         lval2 NUMBER
      ) IS
         SELECT profile_option_value
           FROM fnd_profile_option_values
          WHERE profile_option_id = pid
            AND application_id = aid
            AND level_id = 10007
            AND level_value = lval
            AND level_value_application_id = laid
            AND level_value2 = lval2
            AND profile_option_value IS NOT NULL;

   BEGIN
      -- Added for Server/Resp Hierarchy
      -- If the level_value_aid is not NULL, then check if the level is for
      -- RESP or for SERVRESP.
      IF (level_value_aid IS NOT NULL) THEN
         -- If SERVRESP level, use value_servresp cursor.
         IF (level_id_z = 10007) THEN

            OPEN value_servresp(profile_id_z,
                                application_id_z,
                                level_value_z,
                                level_value_aid,
                                level_value2_z);
            FETCH value_servresp
               INTO val_z;

            IF (value_servresp%NOTFOUND) THEN
               defined_z := FALSE;
               val_z     := NULL;
            ELSE
               defined_z := TRUE;
            END IF; -- Found

            CLOSE value_servresp;

         ELSE
            -- Use value_resp cursor instead.
            OPEN value_resp(profile_id_z,
                            application_id_z,
                            level_value_z,
                            level_value_aid);
            FETCH value_resp
               INTO val_z;

            IF (value_resp%NOTFOUND) THEN
               defined_z := FALSE;
               val_z     := NULL;
            ELSE
               defined_z := TRUE;
            END IF; -- Found

            CLOSE value_resp;

         END IF;
      ELSE
         -- level_value_aid is null, use value_uas cursor.
         OPEN value_uas(profile_id_z,
                        application_id_z,
                        level_id_z,
                        level_value_z);
         FETCH value_uas
            INTO val_z;

         IF (value_uas%NOTFOUND) THEN
            defined_z := FALSE;
            val_z     := NULL;
         ELSE
            defined_z := TRUE;
         END IF; -- Found

         CLOSE value_uas;

      END IF;

   END get_specific_level_db;

   PROCEDURE get_specific_db
   (
      name_z              IN VARCHAR2, -- UPPER value should be passed in
      user_id_z           IN NUMBER DEFAULT NULL,
      responsibility_id_z IN NUMBER DEFAULT NULL,
      application_id_z    IN NUMBER DEFAULT NULL,
      val_z               OUT NOCOPY VARCHAR2,
      defined_z           OUT NOCOPY BOOLEAN,
      org_id_z            IN NUMBER DEFAULT NULL,
      server_id_z         IN NUMBER DEFAULT NULL,
      level_id_z          IN NUMBER,
      profile_hash_value  IN BINARY_INTEGER
   ) IS

      --
      -- this cursor fetches profile information that will allow subsequent
      -- fetches to be more efficient
      --
      CURSOR profile_info IS
         SELECT profile_option_id,
                application_id,
                site_enabled_flag,
                app_enabled_flag,
                resp_enabled_flag,
                user_enabled_flag,
                org_enabled_flag,
                server_enabled_flag,
                serverresp_enabled_flag,
                hierarchy_type,
                user_changeable_flag -- Bug 4257739
           FROM fnd_profile_options
          WHERE profile_option_name = name_z --  Bug 5599946: Removed UPPER call
            AND start_date_active <= SYSDATE
            AND nvl(end_date_active, SYSDATE) >= SYSDATE;

      hashvalue BINARY_INTEGER;

   BEGIN

      -- Log API Entry
      IF corelog_is_enabled THEN
         corelog(name_z,
                 nvl(val_z, 'NOVAL'),
                 'Enter FP.GSD',
                 user_id_z,
                 responsibility_id_z,
                 application_id_z,
                 org_id_z,
                 server_id_z);
      END IF;

      /* Bug 5603664: APPSPERF:FND:OPTIMIZE FND_PROFILE.VALUE
      ** This is a failsafe. PROFILE_HASH_VALUE should always be passed by the
      ** calling api.
      */
      IF profile_hash_value IS NULL THEN
         hashvalue := dbms_utility.get_hash_value(name_z, 1, table_size);
      ELSE
         hashvalue := profile_hash_value;
      END IF;

      /* Check if the current profile option stored in PROFILE_OPTION_NAME is
      ** being evaluated.  If not, then open the cursor and store those values
      ** into the GLOBAL variables.
      */
      IF ((profile_option_name IS NULL) OR ((profile_option_name IS NOT NULL) AND
         (name_z <> profile_option_name))) THEN

         -- Get profile info from database
         OPEN profile_info;
         FETCH profile_info
            INTO profile_option_id,
                 profile_aid,
                 site_enabled,
                 app_enabled,
                 resp_enabled,
                 user_enabled,
                 org_enabled,
                 server_enabled,
                 servresp_enabled,
                 hierarchy,
                 user_changeable; -- Bug 4257739

         IF (profile_info%NOTFOUND) THEN
            val_z                 := NULL;
            defined_z             := FALSE;
            profile_option_exists := FALSE;
            CLOSE profile_info;

            -- Log cursor executed but no profile found
            IF corelog_is_enabled THEN
               corelog(name_z,
                       nvl(val_z, 'NOVAL'),
                       'CURSOR EXEC in FP.GSD, NOPROF',
                       user_id_z,
                       responsibility_id_z,
                       application_id_z,
                       org_id_z,
                       server_id_z);
            END IF;
            RETURN;
         END IF; -- profile_info%NOTFOUND

         -- Log cursor executed and profile found
         IF corelog_is_enabled THEN
            corelog(name_z,
                    nvl(val_z, 'NOVAL'),
                    'CURSOR EXEC in FP.GSD, PROF' || ':' || name_z || ':' ||
                    profile_option_name,
                    user_id_z,
                    responsibility_id_z,
                    application_id_z,
                    org_id_z,
                    server_id_z);
            -- Log profile definition
            fnd_core_log.put_line(name_z,
                                  profile_option_id || ':' || profile_aid || ':' ||
                                  site_enabled || ':' || app_enabled || ':' ||
                                  resp_enabled || ':' || user_enabled || ':' ||
                                  org_enabled || ':' || server_enabled || ':' ||
                                  servresp_enabled || ':' || hierarchy || ':' ||
                                  user_changeable);
         END IF;

         CLOSE profile_info;
         profile_option_name   := name_z;
         profile_option_exists := TRUE;

      ELSE

         /* Bug 5209533: FND_GLOBAL.INITIALIZE RAISES APP-FND-02500 EXECUTING
         ** RULE FUNCTIONS FOR WF EVENT
         ** Setting PROFILE_OPTION_EXISTS = TRUE explicitly IF the condition is
         ** not satisfied.  This guarantees that the profile gets evaluated if
         ** PROFILE_OPTION_EXISTS is not FALSE, e.g. NULL;
         */
         profile_option_exists := TRUE;

         -- Log cursor NOT executed and profile found
         IF corelog_is_enabled THEN
            corelog(name_z,
                    nvl(val_z, 'NOVAL'),
                    'CURSOR *NOEXEC* in FP.GSD, PROF',
                    user_id_z,
                    responsibility_id_z,
                    application_id_z,
                    org_id_z,
                    server_id_z);
         END IF;
      END IF; -- SAME profile option is being evaluated

      IF profile_option_exists THEN

         -- Go through each level, based on HIERARCHY
         -- User-level with Security hierarchy
         IF ((user_id_z <> -1) AND (hierarchy = 'SECURITY') AND
            ((user_enabled = 'Y') OR (user_changeable = 'Y')) AND -- Bug 4257739
            (level_id_z = 10004)) THEN

            IF corelog_is_enabled THEN
               fnd_core_log.put_line(name_z, 'UL Sec in FP.GSD');
            END IF;
            get_specific_level_db(profile_option_id,
                                  profile_aid,
                                  10004,
                                  user_id_z,
                                  NULL,
                                  val_z,
                                  defined_z);

            IF defined_z THEN
               -- Log value found at user-level and cached
               IF corelog_is_enabled THEN
                  corelog(name_z,
                          nvl(val_z, 'NOVAL'),
                          'GSLD VAL cached in USER_TABS FP.GSD, Exit FP.GSD',
                          user_id_z,
                          responsibility_id_z,
                          application_id_z,
                          org_id_z,
                          server_id_z);
               END IF;
               put(name_z, val_z, user_name_tab, user_val_tab, hashvalue);
               RETURN;
            END IF;
         END IF;

         -- Resp-level with Security hierarchy
         IF ((responsibility_id_z <> -1) AND
            (hierarchy = 'SECURITY' AND resp_enabled = 'Y') AND
            (level_id_z = 10003)) THEN

            IF corelog_is_enabled THEN
               fnd_core_log.put_line(name_z, 'RL Sec in FP.GSD');
            END IF;
            get_specific_level_db(profile_option_id,
                                  profile_aid,
                                  10003,
                                  nvl(responsibility_id_z, profiles_resp_id),
                                  nvl(application_id_z, profiles_appl_id),
                                  val_z,
                                  defined_z);

            IF defined_z THEN
               -- Log value found at resp-level and cached
               IF corelog_is_enabled THEN
                  corelog(name_z,
                          nvl(val_z, 'NOVAL'),
                          'GSLD VAL cached in RESP_TABS FP.GSD, Exit FP.GSD',
                          user_id_z,
                          responsibility_id_z,
                          application_id_z,
                          org_id_z,
                          server_id_z);
               END IF;
               put(name_z, val_z, resp_name_tab, resp_val_tab, hashvalue);
               RETURN;
            END IF;
         END IF;

         -- Appl-level with Security hierarchy
         IF ((application_id_z <> -1) AND
            (hierarchy = 'SECURITY' AND app_enabled = 'Y') AND
            (level_id_z = 10002)) THEN

            IF corelog_is_enabled THEN
               fnd_core_log.put_line(name_z, 'AL Sec in FP.GSD');
            END IF;
            get_specific_level_db(profile_option_id,
                                  profile_aid,
                                  10002,
                                  application_id_z,
                                  NULL,
                                  val_z,
                                  defined_z);

            IF defined_z THEN
               -- Log value found at appl-level and cached
               IF corelog_is_enabled THEN
                  corelog(name_z,
                          nvl(val_z, 'NOVAL'),
                          'GSLD VAL cached in APPL_TABS FP.GSD, Exit FP.GSD',
                          user_id_z,
                          responsibility_id_z,
                          application_id_z,
                          org_id_z,
                          server_id_z);
               END IF;
               put(name_z, val_z, appl_name_tab, appl_val_tab, hashvalue);
               RETURN;
            END IF;
         END IF;

         --
         -- If none of the context levels are set, i.e. user_id=-1, etc., then
         -- this is the only situation wherein we check the site-level value to
         -- ensure that context-level calls do not inadvertently return the
         -- site-level value.  This is only done for the SECURITY hierarchy.
         --
         -- Site-level with Security hierarchy --
         IF ((hierarchy = 'SECURITY') AND (site_enabled = 'Y') AND
            (level_id_z = 10001)) THEN

            IF corelog_is_enabled THEN
               fnd_core_log.put_line(name_z, 'SL Sec in FP.GSD');
            END IF;
            get_specific_level_db(profile_option_id,
                                  profile_aid,
                                  10001,
                                  0,
                                  NULL,
                                  val_z,
                                  defined_z);

            IF defined_z THEN
               /* Log value found at site-level and cached */
               IF corelog_is_enabled THEN
                  corelog(name_z,
                          nvl(val_z, 'NOVAL'),
                          'GSLD VAL cached in SITE_TABS FP.GSD, Exit FP.GSD',
                          user_id_z,
                          responsibility_id_z,
                          application_id_z,
                          org_id_z,
                          server_id_z);
               END IF;
               put(name_z, val_z, site_name_tab, site_val_tab, hashvalue);
               RETURN;
            END IF;
         END IF;

         -- User-level with Organization hierarchy
         IF ((user_id_z <> -1) AND (hierarchy = 'ORG') AND
            ((user_enabled = 'Y') OR (user_changeable = 'Y')) AND -- Bug 4257739
            (level_id_z = 10004)) THEN

            IF corelog_is_enabled THEN
               fnd_core_log.put_line(name_z, 'UL Org in FP.GSD');
            END IF;
            get_specific_level_db(profile_option_id,
                                  profile_aid,
                                  10004,
                                  user_id_z,
                                  NULL,
                                  val_z,
                                  defined_z);

            IF defined_z THEN
               -- Log value found at user-level and cached
               IF corelog_is_enabled THEN
                  corelog(name_z,
                          nvl(val_z, 'NOVAL'),
                          'GSLD VAL cached in USER_TABS FP.GSD, Exit FP.GSD',
                          user_id_z,
                          responsibility_id_z,
                          application_id_z,
                          org_id_z,
                          server_id_z);
               END IF;
               put(name_z, val_z, user_name_tab, user_val_tab, hashvalue);
               RETURN;
            END IF;
         END IF;

         -- Org-level with Organization hierarchy
         IF ((org_id_z <> -1) AND (hierarchy = 'ORG' AND org_enabled = 'Y') AND
            (level_id_z = 10006)) THEN

            IF corelog_is_enabled THEN
               fnd_core_log.put_line(name_z, 'OL Org in FP.GSD');
            END IF;
            get_specific_level_db(profile_option_id,
                                  profile_aid,
                                  10006,
                                  org_id_z,
                                  NULL,
                                  val_z,
                                  defined_z);

            IF defined_z THEN
               -- Log value found at org-level and cached
               IF corelog_is_enabled THEN
                  corelog(name_z,
                          nvl(val_z, 'NOVAL'),
                          'GSLD VAL cached in ORG_TABS FP.GSD, Exit FP.GSD',
                          user_id_z,
                          responsibility_id_z,
                          application_id_z,
                          org_id_z,
                          server_id_z);
               END IF;
               put(name_z, val_z, org_name_tab, org_val_tab, hashvalue);
               RETURN;
            END IF;
         END IF;

         -- Site-level with Organization hierarchy
         IF (hierarchy = 'ORG' AND site_enabled = 'Y' AND
            level_id_z = 10001) THEN

            IF corelog_is_enabled THEN
               fnd_core_log.put_line(name_z, 'SL Org in FP.GSD');
            END IF;
            get_specific_level_db(profile_option_id,
                                  profile_aid,
                                  10001,
                                  0,
                                  NULL,
                                  val_z,
                                  defined_z);

            IF defined_z THEN
               -- Log value found at site-level and cached
               IF corelog_is_enabled THEN
                  corelog(name_z,
                          nvl(val_z, 'NOVAL'),
                          'GSLD VAL cached in SITE_TABS FP.GSD, Exit FP.GSD',
                          user_id_z,
                          responsibility_id_z,
                          application_id_z,
                          org_id_z,
                          server_id_z);
               END IF;
               put(name_z, val_z, site_name_tab, site_val_tab, hashvalue);
               RETURN;
            END IF;
         END IF;

         -- User-level with Server hierarchy
         IF ((user_id_z <> -1) AND (hierarchy = 'SERVER') AND
            ((user_enabled = 'Y') OR (user_changeable = 'Y')) AND -- Bug 4257739
            (level_id_z = 10004)) THEN

            IF corelog_is_enabled THEN
               fnd_core_log.put_line(name_z, 'UL Server in FP.GSD');
            END IF;
            get_specific_level_db(profile_option_id,
                                  profile_aid,
                                  10004,
                                  user_id_z,
                                  NULL,
                                  val_z,
                                  defined_z);

            IF defined_z THEN
               -- Log value found at user-level and cached
               IF corelog_is_enabled THEN
                  corelog(name_z,
                          nvl(val_z, 'NOVAL'),
                          'GSLD VAL cached in USER_TABS FP.GSD, Exit FP.GSD',
                          user_id_z,
                          responsibility_id_z,
                          application_id_z,
                          org_id_z,
                          server_id_z);
               END IF;
               put(name_z, val_z, user_name_tab, user_val_tab, hashvalue);
               RETURN;
            END IF;

         END IF;

         -- Server-level with Server hierarchy
         IF ((server_id_z <> -1) AND
            (hierarchy = 'SERVER' AND server_enabled = 'Y') AND
            (level_id_z = 10005)) THEN

            IF corelog_is_enabled THEN
               fnd_core_log.put_line(name_z, 'SRVL Server in FP.GSD');
            END IF;
            get_specific_level_db(profile_option_id,
                                  profile_aid,
                                  10005,
                                  server_id_z,
                                  NULL,
                                  val_z,
                                  defined_z);

            IF defined_z THEN
               -- Log value found at server-level and cached
               IF corelog_is_enabled THEN
                  corelog(name_z,
                          nvl(val_z, 'NOVAL'),
                          'GSLD VAL cached in SERVER_TABS FP.GSD, Exit FP.GSD',
                          user_id_z,
                          responsibility_id_z,
                          application_id_z,
                          org_id_z,
                          server_id_z);
               END IF;
               put(name_z,
                   val_z,
                   server_name_tab,
                   server_val_tab,
                   hashvalue);
               RETURN;
            END IF;
         END IF;

         -- Site-level with Server hierarchy
         IF (hierarchy = 'SERVER' AND site_enabled = 'Y' AND
            level_id_z = 10001) THEN

            IF corelog_is_enabled THEN
               fnd_core_log.put_line(name_z, 'SL Server in FP.GSD');
            END IF;
            get_specific_level_db(profile_option_id,
                                  profile_aid,
                                  10001,
                                  0,
                                  NULL,
                                  val_z,
                                  defined_z);

            IF defined_z THEN
               -- Log value found at site-level and cached
               IF corelog_is_enabled THEN
                  corelog(name_z,
                          nvl(val_z, 'NOVAL'),
                          'GSLD VAL cached in SITE_TABS FP.GSD, Exit FP.GSD',
                          user_id_z,
                          responsibility_id_z,
                          application_id_z,
                          org_id_z,
                          server_id_z);
               END IF;
               put(name_z, val_z, site_name_tab, site_val_tab, hashvalue);
               RETURN;
            END IF;
         END IF;

         -- User-level with Server/Resp hierarchy
         IF ((user_id_z <> -1) AND (hierarchy = 'SERVRESP') AND
            ((user_enabled = 'Y') OR (user_changeable = 'Y')) AND -- Bug 4257739
            (level_id_z = 10004)) THEN

            IF corelog_is_enabled THEN
               fnd_core_log.put_line(name_z, 'UL ServResp in FP.GSD');
            END IF;
            get_specific_level_db(profile_option_id,
                                  profile_aid,
                                  10004,
                                  user_id_z,
                                  NULL,
                                  val_z,
                                  defined_z);

            IF defined_z THEN
               -- Log value found at user-level and cached
               IF corelog_is_enabled THEN
                  corelog(name_z,
                          nvl(val_z, 'NOVAL'),
                          'GSLD VAL cached in USER_TABS FP.GSD, Exit FP.GSD',
                          user_id_z,
                          responsibility_id_z,
                          application_id_z,
                          org_id_z,
                          server_id_z);
               END IF;
               put(name_z, val_z, user_name_tab, user_val_tab, hashvalue);
               RETURN;
            END IF;
         END IF;

         -- Server-level with Server/Resp hierarchy
         IF (hierarchy = 'SERVRESP' AND servresp_enabled = 'Y' AND
            level_id_z = 10007) THEN
            --
            -- This IF block may not really be required since the call to
            -- get_specific_level_db, as is, is likely able to handle all
            -- situations without the IF-ELSIF conditions.  That is:
            --   get_specific_level_db(PROFILE_OPTION_ID,PROFILE_AID,10007,
            --      responsibility_id_z,NULL,val_z,defined_z,server_id_z);
            -- should be able to return the correct value no matter what
            -- server_id_z and responsibility_id_z values are, even when value
            -- is -1 for any or both.
            --
            -- However, the IF block was placed to illustrate the order of
            -- precedence that the SERVRESP level has:
            --    Server/Responsibility > Responsibility > Server > Site
            --
            -- Accordingly, the calls to get_specific_level_db were
            -- deliberately coded depending on precedence.
            --

            IF corelog_is_enabled THEN
               fnd_core_log.put_line(name_z,
                                     'ServRespL ServResp in FP.GSD');
            END IF;

            -- Responsibility ID and Server ID
            IF (responsibility_id_z <> -1 AND server_id_z <> -1) THEN
               get_specific_level_db(profile_option_id,
                                     profile_aid,
                                     10007,
                                     responsibility_id_z,
                                     nvl(application_id_z, profiles_appl_id),
                                     val_z,
                                     defined_z,
                                     server_id_z);

               IF defined_z THEN
                  -- Log value found at servresp-level and cached
                  IF corelog_is_enabled THEN
                     corelog(name_z,
                             nvl(val_z, 'NOVAL'),
                             'GSLD VAL cached in SERVRESP_TABS FP.GSD, Exit FP.GSD',
                             user_id_z,
                             responsibility_id_z,
                             application_id_z,
                             org_id_z,
                             server_id_z);
                  END IF;
                  put(name_z,
                      val_z,
                      servresp_name_tab,
                      servresp_val_tab,
                      hashvalue);
                  RETURN;
               ELSE
                  -- Responsibility ID and -1 for Server
                  get_specific_level_db(profile_option_id,
                                        profile_aid,
                                        10007,
                                        responsibility_id_z,
                                        nvl(application_id_z,
                                            profiles_appl_id),
                                        val_z,
                                        defined_z,
                                        -1);

                  IF defined_z THEN
                     -- Log value found at servresp-level and cached
                     IF corelog_is_enabled THEN
                        corelog(name_z,
                                nvl(val_z, 'NOVAL'),
                                'GSLD VAL cached in SERVRESP_TABS FP.GSD,' ||
                                'Exit FP.GSD',
                                user_id_z,
                                responsibility_id_z,
                                application_id_z,
                                org_id_z,
                                server_id_z);
                     END IF;
                     put(name_z,
                         val_z,
                         servresp_name_tab,
                         servresp_val_tab,
                         hashvalue);
                     RETURN;
                  ELSE
                     -- -1 for Responsibility and Server ID
                     get_specific_level_db(profile_option_id,
                                           profile_aid,
                                           10007,
                                           -1,
                                           -1,
                                           val_z,
                                           defined_z,
                                           server_id_z);

                     IF defined_z THEN
                        -- Log value found at servresp-level and cached
                        IF corelog_is_enabled THEN
                           corelog(name_z,
                                   nvl(val_z, 'NOVAL'),
                                   'GSLD VAL cached in SERVRESP_TABS FP.GSD,' ||
                                   'Exit FP.GSD');
                        END IF;
                        put(name_z,
                            val_z,
                            servresp_name_tab,
                            servresp_val_tab,
                            hashvalue);
                        RETURN;
                     END IF; -- -1 for Responsibility and Server ID
                  END IF; -- Responsibility ID and -1 for Server
               END IF; -- Responsibility ID and Server ID

               -- Responsibility ID and -1 for Server
            ELSIF (responsibility_id_z <> -1 AND server_id_z = -1) THEN
               get_specific_level_db(profile_option_id,
                                     profile_aid,
                                     10007,
                                     responsibility_id_z,
                                     nvl(application_id_z, profiles_appl_id),
                                     val_z,
                                     defined_z,
                                     -1);

               IF defined_z THEN
                  -- Log value found at servresp-level and cached
                  IF corelog_is_enabled THEN
                     corelog(name_z,
                             nvl(val_z, 'NOVAL'),
                             'GSLD VAL cached in SERVRESP_TABS FP.GSD,' ||
                             'Exit FP.GSD',
                             user_id_z,
                             responsibility_id_z,
                             application_id_z,
                             org_id_z,
                             server_id_z);
                  END IF;
                  put(name_z,
                      val_z,
                      servresp_name_tab,
                      servresp_val_tab,
                      hashvalue);
                  RETURN;
               ELSE
                  -- -1 for Responsibility and Server ID
                  get_specific_level_db(profile_option_id,
                                        profile_aid,
                                        10007,
                                        -1,
                                        -1,
                                        val_z,
                                        defined_z,
                                        server_id_z);

                  IF defined_z THEN
                     -- Log value found at servresp-level and cached
                     IF corelog_is_enabled THEN
                        corelog(name_z,
                                nvl(val_z, 'NOVAL'),
                                'GSLD VAL cached in SERVRESP_TABS FP.GSD,' ||
                                'Exit FP.GSD',
                                user_id_z,
                                responsibility_id_z,
                                application_id_z,
                                org_id_z,
                                server_id_z);
                     END IF;
                     put(name_z,
                         val_z,
                         servresp_name_tab,
                         servresp_val_tab,
                         hashvalue);
                     RETURN;
                  END IF; -- -1 for Responsibility and Server ID
               END IF; -- Responsibility ID and -1 for Server

               -- -1 for Responsibility and Server ID
            ELSIF (server_id_z <> -1 AND responsibility_id_z = -1) THEN
               get_specific_level_db(profile_option_id,
                                     profile_aid,
                                     10007,
                                     -1,
                                     -1,
                                     val_z,
                                     defined_z,
                                     server_id_z);

               IF defined_z THEN
                  -- Log value found at servresp-level and cached
                  IF corelog_is_enabled THEN
                     corelog(name_z,
                             nvl(val_z, 'NOVAL'),
                             'GSLD VAL cached in SERVRESP_TABS FP.GSD,' ||
                             'Exit FP.GSD',
                             user_id_z,
                             responsibility_id_z,
                             application_id_z,
                             org_id_z,
                             server_id_z);
                  END IF;
                  put(name_z,
                      val_z,
                      servresp_name_tab,
                      servresp_val_tab,
                      hashvalue);
                  RETURN;
               END IF; -- -1 for Responsibility and Server ID
            END IF;
         END IF;

         -- Site-level with Server/Resp hierarchy --
         IF (hierarchy = 'SERVRESP' AND site_enabled = 'Y' AND
            level_id_z = 10001) THEN

            IF corelog_is_enabled THEN
               fnd_core_log.put_line(name_z, 'SL ServResp in FP.GSD');
            END IF;
            get_specific_level_db(profile_option_id,
                                  profile_aid,
                                  10001,
                                  0,
                                  NULL,
                                  val_z,
                                  defined_z);

            IF defined_z THEN
               -- Log value found at site-level and cached
               IF corelog_is_enabled THEN
                  corelog(name_z,
                          nvl(val_z, 'NOVAL'),
                          'GSLD VAL cached in SITE_TABS FP.GSD, Exit FP.GSD',
                          user_id_z,
                          responsibility_id_z,
                          application_id_z,
                          org_id_z,
                          server_id_z);
               END IF;
               put(name_z, val_z, site_name_tab, site_val_tab, hashvalue);
               RETURN;
            END IF;
         END IF;

      END IF; -- PROFILE_OPTION_EXISTS if-then block

      -- If the call gets here, then no value was found.
      val_z     := NULL;
      defined_z := FALSE;

      -- Log value not found at any level
      IF corelog_is_enabled THEN
         corelog(name_z,
                 nvl(val_z, 'NOVAL'),
                 'Exit FP.GSD',
                 user_id_z,
                 responsibility_id_z,
                 application_id_z,
                 org_id_z,
                 server_id_z);
      END IF;
   END get_specific_db;

   /*
   ** This procedure is needed to get around the WNPS pragma.
   */
   PROCEDURE get_specific_db_wnps
   (
      name_z              IN VARCHAR2,
      user_id_z           IN NUMBER DEFAULT NULL,
      responsibility_id_z IN NUMBER DEFAULT NULL,
      application_id_z    IN NUMBER DEFAULT NULL,
      val_z               OUT NOCOPY VARCHAR2,
      defined_z           OUT NOCOPY BOOLEAN,
      org_id_z            IN NUMBER DEFAULT NULL,
      server_id_z         IN NUMBER DEFAULT NULL,
      level_id_z          IN NUMBER
   ) IS

      --
      -- this cursor fetches profile information that will allow subsequent
      -- fetches to be more efficient
      --
      CURSOR profile_info IS
         SELECT profile_option_id,
                application_id,
                site_enabled_flag,
                app_enabled_flag,
                resp_enabled_flag,
                user_enabled_flag,
                org_enabled_flag,
                server_enabled_flag,
                serverresp_enabled_flag,
                hierarchy_type,
                user_changeable_flag -- Bug 4257739
           FROM fnd_profile_options
          WHERE profile_option_name = name_z
            AND start_date_active <= SYSDATE
            AND nvl(end_date_active, SYSDATE) >= SYSDATE;

      --
      -- this cursor fetches profile option values for site, application,
      -- and user levels (10001/10002/10004)
      --
      CURSOR value_uas
      (
         pid  NUMBER,
         aid  NUMBER,
         lid  NUMBER,
         lval NUMBER
      ) IS
         SELECT profile_option_value
           FROM fnd_profile_option_values
          WHERE profile_option_id = pid
            AND application_id = aid
            AND level_id = lid
            AND level_value = lval
            AND profile_option_value IS NOT NULL;
      --
      -- this cursor fetches profile option values at the responsibility
      -- level (10003)
      --
      CURSOR value_resp
      (
         pid  NUMBER,
         aid  NUMBER,
         lval NUMBER,
         laid NUMBER
      ) IS
         SELECT profile_option_value
           FROM fnd_profile_option_values
          WHERE profile_option_id = pid
            AND application_id = aid
            AND level_id = 10003
            AND level_value = lval
            AND level_value_application_id = laid
            AND profile_option_value IS NOT NULL;
      --
      -- this cursor fetches profile option values at the server+responsibility
      -- level (10007)
      --
      CURSOR value_servresp
      (
         pid   NUMBER,
         aid   NUMBER,
         lval  NUMBER,
         laid  NUMBER,
         lval2 NUMBER
      ) IS
         SELECT profile_option_value
           FROM fnd_profile_option_values
          WHERE profile_option_id = pid
            AND application_id = aid
            AND level_id = 10007
            AND level_value = lval
            AND level_value_application_id = laid
            AND level_value2 = lval2
            AND profile_option_value IS NOT NULL;

   BEGIN

      -- Log API Entry
      IF corelog_is_enabled THEN
         corelog(name_z,
                 nvl(val_z, 'NOVAL'),
                 'Enter FP.GSDW',
                 user_id_z,
                 responsibility_id_z,
                 application_id_z,
                 org_id_z,
                 server_id_z);
      END IF;

      val_z     := NULL;
      defined_z := FALSE;

      --
      -- Check if the same profile option is being evaluated.  If not, then
      -- open the cursor and store those values into the GLOBAL variables.
      --
      IF ((profile_option_name IS NULL) OR (name_z <> profile_option_name)) THEN

         -- Get profile info from database
         OPEN profile_info;
         FETCH profile_info
            INTO profile_option_id,
                 profile_aid,
                 site_enabled,
                 app_enabled,
                 resp_enabled,
                 user_enabled,
                 org_enabled,
                 server_enabled,
                 servresp_enabled,
                 hierarchy,
                 user_changeable; -- Bug 4257739

         IF (profile_info%NOTFOUND) THEN
            val_z                 := NULL;
            defined_z             := FALSE;
            profile_option_exists := FALSE;
            CLOSE profile_info;

            -- Log cursor executed but no profile
            IF corelog_is_enabled THEN
               corelog(name_z,
                       nvl(val_z, 'NOVAL'),
                       'CURSOR EXEC in FP.GSDW, NOPROF',
                       user_id_z,
                       responsibility_id_z,
                       application_id_z,
                       org_id_z,
                       server_id_z);
            END IF;

            RETURN;
         END IF; -- profile_info%NOTFOUND

         CLOSE profile_info;
         profile_option_name   := name_z;
         profile_option_exists := TRUE;

         -- Log cursor executed and profile found
         IF corelog_is_enabled THEN
            corelog(name_z,
                    nvl(val_z, 'NOVAL'),
                    'CURSOR EXEC in FP.GSDW, PROF',
                    user_id_z,
                    responsibility_id_z,
                    application_id_z,
                    org_id_z,
                    server_id_z);
            -- Log profile definition
            fnd_core_log.put_line(name_z,
                                  profile_option_id || ':' || profile_aid || ':' ||
                                  site_enabled || ':' || app_enabled || ':' ||
                                  resp_enabled || ':' || user_enabled || ':' ||
                                  org_enabled || ':' || server_enabled || ':' ||
                                  servresp_enabled || ':' || hierarchy || ':' ||
                                  user_changeable);
         END IF;
      ELSE

         /* Bug 5209533: FND_GLOBAL.INITIALIZE RAISES APP-FND-02500 EXECUTING
         ** RULE FUNCTIONS FOR WF EVENT
         ** Setting PROFILE_OPTION_EXISTS = TRUE explicitly IF the condition is
         ** not satisfied.  This guarantees that the profile gets evaluated if
         ** PROFILE_OPTION_EXISTS is not FALSE, e.g. NULL;
         */
         profile_option_exists := TRUE;

         -- Log cursor NOT executed and profile found
         IF corelog_is_enabled THEN
            corelog(name_z,
                    nvl(val_z, 'NOVAL'),
                    'CURSOR *NOEXEC* in FP.GSDW, PROF',
                    user_id_z,
                    responsibility_id_z,
                    application_id_z,
                    org_id_z,
                    server_id_z);
         END IF;

      END IF; -- SAME profile option is being evaluated
      --
      -- The conditions have been modelled after GET_SPECIFIC_DB to make
      -- behavior consistent between GET_SPECIFIC_DB and GET_SPECIFIC_DB_WNPS.
      --
      IF profile_option_exists THEN

         -- USER level with Security hierarchy
         IF ((user_id_z <> -1) AND (hierarchy = 'SECURITY') AND
            ((user_enabled = 'Y') OR (user_changeable = 'Y')) AND -- Bug 4257739
            (level_id_z = 10004)) THEN

            IF corelog_is_enabled THEN
               fnd_core_log.put_line(name_z, 'UL Sec in FP.GSDW');
            END IF;
            OPEN value_uas(profile_option_id,
                           profile_aid,
                           10004,
                           nvl(user_id_z, profiles_user_id));
            FETCH value_uas
               INTO val_z;
            IF (value_uas%NOTFOUND) THEN
               defined_z := FALSE;
               CLOSE value_uas;
            ELSE
               defined_z := TRUE;
               CLOSE value_uas;
               -- Log value found at user-level
               IF corelog_is_enabled THEN
                  corelog(name_z,
                          nvl(val_z, 'NOVAL'),
                          'UL VAL in GSDW',
                          user_id_z,
                          responsibility_id_z,
                          application_id_z,
                          org_id_z,
                          server_id_z);
               END IF;
               RETURN;
            END IF; -- value_uas%NOTFOUND

         END IF;

         -- RESP level with Security hierarchy
         IF ((responsibility_id_z <> -1) AND
            (hierarchy = 'SECURITY' AND resp_enabled = 'Y') AND
            (level_id_z = 10003)) THEN

            IF corelog_is_enabled THEN
               fnd_core_log.put_line(name_z, 'RL Sec in FP.GSDW');
            END IF;
            OPEN value_resp(profile_option_id,
                            profile_aid,
                            nvl(responsibility_id_z, profiles_resp_id),
                            nvl(application_id_z, profiles_appl_id));
            FETCH value_resp
               INTO val_z;
            IF (value_resp%NOTFOUND) THEN
               defined_z := FALSE;
               CLOSE value_resp;
            ELSE
               defined_z := TRUE;
               CLOSE value_resp;
               -- Log value found at resp-level
               IF corelog_is_enabled THEN
                  corelog(name_z,
                          nvl(val_z, 'NOVAL'),
                          'RL VAL in GSDW',
                          user_id_z,
                          responsibility_id_z,
                          application_id_z,
                          org_id_z,
                          server_id_z);
               END IF;
               RETURN;
            END IF; -- value_resp%NOTFOUND

         END IF;

         -- APPL level with Security hierarchy
         IF ((application_id_z <> -1) AND
            (hierarchy = 'SECURITY' AND app_enabled = 'Y') AND
            (level_id_z = 10002)) THEN

            IF corelog_is_enabled THEN
               fnd_core_log.put_line(name_z, 'AL Sec in FP.GSDW');
            END IF;
            OPEN value_uas(profile_option_id,
                           profile_aid,
                           10002,
                           nvl(application_id_z, profiles_appl_id));
            FETCH value_uas
               INTO val_z;
            IF (value_uas%NOTFOUND) THEN
               defined_z := FALSE;
               CLOSE value_uas;
            ELSE
               defined_z := TRUE;
               CLOSE value_uas;
               -- Log value found at appl-level
               IF corelog_is_enabled THEN
                  corelog(name_z,
                          nvl(val_z, 'NOVAL'),
                          'AL VAL in GSDW',
                          user_id_z,
                          responsibility_id_z,
                          application_id_z,
                          org_id_z,
                          server_id_z);
               END IF;
               RETURN;
            END IF; -- value_uas%NOTFOUND

         END IF;

         --
         -- If none of the context levels are set, i.e. user_id= -1, etc., then
         -- this is the only situation wherein we check the site-level value to
         -- ensure that context-level calls do not inadvertently return the
         -- site-level value.  This is only done for the SECURITY hierarchy.
         --
         -- Site level with Security hierarchy
         IF (hierarchy = 'SECURITY' AND site_enabled = 'Y' AND
            level_id_z = 10001) THEN

            IF corelog_is_enabled THEN
               fnd_core_log.put_line(name_z, 'SL Sec in FP.GSDW');
            END IF;
            OPEN value_uas(profile_option_id, profile_aid, 10001, 0);
            FETCH value_uas
               INTO val_z;
            IF (value_uas%NOTFOUND) THEN
               defined_z := FALSE;
               CLOSE value_uas;
            ELSE
               defined_z := TRUE;
               CLOSE value_uas;
               -- Log value found at site-level
               IF corelog_is_enabled THEN
                  corelog(name_z,
                          nvl(val_z, 'NOVAL'),
                          'SL VAL in GSDW',
                          user_id_z,
                          responsibility_id_z,
                          application_id_z,
                          org_id_z,
                          server_id_z);
               END IF;
               RETURN;
            END IF; -- value_uas%NOTFOUND
         END IF;

         -- USER level with Organization hierarchy
         IF ((user_id_z <> -1) AND (hierarchy = 'ORG') AND
            ((user_enabled = 'Y') OR (user_changeable = 'Y')) AND -- Bug 4257739
            (level_id_z = 10004)) THEN

            IF corelog_is_enabled THEN
               fnd_core_log.put_line(name_z, 'UL Org in FP.GSDW');
            END IF;
            OPEN value_uas(profile_option_id,
                           profile_aid,
                           10004,
                           nvl(user_id_z, profiles_user_id));
            FETCH value_uas
               INTO val_z;
            IF (value_uas%NOTFOUND) THEN
               defined_z := FALSE;
               CLOSE value_uas;
            ELSE
               defined_z := TRUE;
               CLOSE value_uas;
               -- Log value found at user-level
               IF corelog_is_enabled THEN
                  corelog(name_z,
                          nvl(val_z, 'NOVAL'),
                          'UL VAL in GSDW',
                          user_id_z,
                          responsibility_id_z,
                          application_id_z,
                          org_id_z,
                          server_id_z);
               END IF;
               RETURN;
            END IF; -- value_uas%NOTFOUND

         END IF;

         -- ORG level with Organization hierarchy
         IF ((org_id_z <> -1) AND (hierarchy = 'ORG' AND org_enabled = 'Y') AND
            (level_id_z = 10006)) THEN

            IF corelog_is_enabled THEN
               fnd_core_log.put_line(name_z, 'OL Org in FP.GSDW');
            END IF;
            OPEN value_uas(profile_option_id,
                           profile_aid,
                           10006,
                           nvl(org_id_z, profiles_org_id));
            FETCH value_uas
               INTO val_z;
            IF (value_uas%NOTFOUND) THEN
               CLOSE value_uas;
               defined_z := FALSE;
            ELSE
               defined_z := TRUE;
               CLOSE value_uas;
               -- Log value found at org-level
               IF corelog_is_enabled THEN
                  corelog(name_z,
                          nvl(val_z, 'NOVAL'),
                          'OL VAL in GSDW',
                          user_id_z,
                          responsibility_id_z,
                          application_id_z,
                          org_id_z,
                          server_id_z);
               END IF;
               RETURN;
            END IF; -- value_uas%NOTFOUND

         END IF;

         -- SITE level with Organization hierarchy
         IF (hierarchy = 'ORG' AND site_enabled = 'Y' AND
            level_id_z = 10001) THEN

            IF corelog_is_enabled THEN
               fnd_core_log.put_line(name_z, 'SL Org in FP.GSDW');
            END IF;
            OPEN value_uas(profile_option_id, profile_aid, 10001, 0);
            FETCH value_uas
               INTO val_z;
            IF (value_uas%NOTFOUND) THEN
               defined_z := FALSE;
               CLOSE value_uas;
            ELSE
               defined_z := TRUE;
               CLOSE value_uas;
               -- Log value found at site-level
               IF corelog_is_enabled THEN
                  corelog(name_z,
                          nvl(val_z, 'NOVAL'),
                          'SL VAL in GSDW',
                          user_id_z,
                          responsibility_id_z,
                          application_id_z,
                          org_id_z,
                          server_id_z);
               END IF;
               RETURN;
            END IF; -- value_uas%NOTFOUND

         END IF;

         -- USER level with Server hierarchy
         IF ((user_id_z <> -1) AND (hierarchy = 'SERVER') AND
            ((user_enabled = 'Y') OR (user_changeable = 'Y')) AND -- Bug 4257739
            (level_id_z = 10004)) THEN

            IF corelog_is_enabled THEN
               fnd_core_log.put_line(name_z, 'UL Server in FP.GSDW');
            END IF;
            OPEN value_uas(profile_option_id,
                           profile_aid,
                           10004,
                           nvl(user_id_z, profiles_user_id));
            FETCH value_uas
               INTO val_z;
            IF (value_uas%NOTFOUND) THEN
               defined_z := FALSE;
               CLOSE value_uas;
            ELSE
               defined_z := TRUE;
               CLOSE value_uas;
               -- Log value found at user-level
               IF corelog_is_enabled THEN
                  corelog(name_z,
                          nvl(val_z, 'NOVAL'),
                          'UL VAL in GSDW',
                          user_id_z,
                          responsibility_id_z,
                          application_id_z,
                          org_id_z,
                          server_id_z);
               END IF;
               RETURN;
            END IF; -- value_uas%NOTFOUND

         END IF;

         -- SERVER level with Server hierarchy
         IF ((server_id_z <> -1) AND
            (hierarchy = 'SERVER' AND server_enabled = 'Y') AND
            (level_id_z = 10005)) THEN

            IF corelog_is_enabled THEN
               fnd_core_log.put_line(name_z, 'SRVL Server in FP.GSDW');
            END IF;
            OPEN value_uas(profile_option_id,
                           profile_aid,
                           10005,
                           nvl(server_id_z, profiles_server_id));
            FETCH value_uas
               INTO val_z;
            IF (value_uas%NOTFOUND) THEN
               defined_z := FALSE;
               CLOSE value_uas;
            ELSE
               defined_z := TRUE;
               CLOSE value_uas;
               -- Log value found at server-level
               IF corelog_is_enabled THEN
                  corelog(name_z,
                          nvl(val_z, 'NOVAL'),
                          'SRVL VAL in GSDW',
                          user_id_z,
                          responsibility_id_z,
                          application_id_z,
                          org_id_z,
                          server_id_z);
               END IF;
               RETURN;
            END IF; -- value_uas%NOTFOUND

         END IF;

         -- SITE level with Server hierarchy
         IF (hierarchy = 'SERVER' AND site_enabled = 'Y' AND
            level_id_z = 10001) THEN

            IF corelog_is_enabled THEN
               fnd_core_log.put_line(name_z, 'SL Server in FP.GSDW');
            END IF;
            OPEN value_uas(profile_option_id, profile_aid, 10001, 0);
            FETCH value_uas
               INTO val_z;
            IF (value_uas%NOTFOUND) THEN
               defined_z := FALSE;
               CLOSE value_uas;
            ELSE
               defined_z := TRUE;
               CLOSE value_uas;
               -- Log value found at site-level
               IF corelog_is_enabled THEN
                  corelog(name_z,
                          nvl(val_z, 'NOVAL'),
                          'SL VAL in GSDW',
                          user_id_z,
                          responsibility_id_z,
                          application_id_z,
                          org_id_z,
                          server_id_z);
               END IF;
               RETURN;
            END IF; -- value_uas%NOTFOUND

         END IF;

         -- USER level with Server/Responsibility hierarchy
         IF ((user_id_z <> -1) AND (hierarchy = 'SERVRESP') AND
            ((user_enabled = 'Y') OR (user_changeable = 'Y')) AND -- Bug 4257739
            (level_id_z = 10004)) THEN

            IF corelog_is_enabled THEN
               fnd_core_log.put_line(name_z, 'UL ServResp in FP.GSDW');
            END IF;
            OPEN value_uas(profile_option_id,
                           profile_aid,
                           10004,
                           nvl(user_id_z, profiles_user_id));
            FETCH value_uas
               INTO val_z;
            IF (value_uas%NOTFOUND) THEN
               defined_z := FALSE;
               CLOSE value_uas;
            ELSE
               defined_z := TRUE;
               CLOSE value_uas;
               -- Log value found at user-level
               IF corelog_is_enabled THEN
                  corelog(name_z,
                          nvl(val_z, 'NOVAL'),
                          'UL VAL in GSDW',
                          user_id_z,
                          responsibility_id_z,
                          application_id_z,
                          org_id_z,
                          server_id_z);
               END IF;
               RETURN;
            END IF; -- value_uas%NOTFOUND

         END IF;

         -- SERVRESP level with Server/Responsibility hierarchy
         IF (hierarchy = 'SERVRESP' AND servresp_enabled = 'Y' AND
            level_id_z = 10007) THEN
            -- Responsibility and Server
            IF corelog_is_enabled THEN
               fnd_core_log.put_line(name_z,
                                     'ServRespL ServResp in FP.GSDW');
            END IF;
            IF (responsibility_id_z <> -1 AND server_id_z <> -1) THEN
               IF corelog_is_enabled THEN
                  fnd_core_log.put_line('ServRespL:R <> -1 and S <> -1');
               END IF;
               OPEN value_servresp(profile_option_id,
                                   profile_aid,
                                   nvl(responsibility_id_z,
                                       profiles_resp_id),
                                   nvl(application_id_z, profiles_appl_id),
                                   nvl(server_id_z, profiles_server_id));
               -- Bug 4017612
               FETCH value_servresp
                  INTO val_z;
               IF (value_servresp%NOTFOUND) THEN
                  defined_z := FALSE;
                  CLOSE value_servresp;
               ELSE
                  defined_z := TRUE;
                  CLOSE value_servresp;
                  -- Log value found at user-level
                  IF corelog_is_enabled THEN
                     corelog(name_z,
                             nvl(val_z, 'NOVAL'),
                             'ServRespL VAL in GSDW',
                             user_id_z,
                             responsibility_id_z,
                             application_id_z,
                             org_id_z,
                             server_id_z);
                  END IF;
                  RETURN;
               END IF; -- value_servresp%NOTFOUND
               -- Responsibility and -1 for Server
            ELSIF (responsibility_id_z <> -1 AND server_id_z = -1) THEN
               IF corelog_is_enabled THEN
                  fnd_core_log.put_line('ServRespL:R <> -1 and S = -1');
               END IF;
               OPEN value_servresp(profile_option_id,
                                   profile_aid,
                                   nvl(responsibility_id_z,
                                       profiles_resp_id),
                                   nvl(application_id_z, profiles_appl_id),
                                   -1);
               -- Bug 4017612
               FETCH value_servresp
                  INTO val_z;
               IF (value_servresp%NOTFOUND) THEN
                  defined_z := FALSE;
                  CLOSE value_servresp;
               ELSE
                  defined_z := TRUE;
                  CLOSE value_servresp;
                  -- Log value found at user-level
                  IF corelog_is_enabled THEN
                     corelog(name_z,
                             nvl(val_z, 'NOVAL'),
                             'ServRespL VAL in GSDW',
                             user_id_z,
                             responsibility_id_z,
                             application_id_z,
                             org_id_z,
                             server_id_z);
                  END IF;
                  RETURN;
               END IF; -- value_servresp%NOTFOUND
               -- Server and -1 for Responsibility
            ELSIF (server_id_z <> -1 AND responsibility_id_z = -1) THEN
               IF corelog_is_enabled THEN
                  fnd_core_log.put_line('ServRespL:R = -1 and S <> -1');
               END IF;
               OPEN value_servresp(profile_option_id,
                                   profile_aid,
                                   -1,
                                   -1,
                                   nvl(server_id_z, profiles_server_id));
               -- Bug 4017612
               FETCH value_servresp
                  INTO val_z;
               IF (value_servresp%NOTFOUND) THEN
                  defined_z := FALSE;
                  CLOSE value_servresp;
               ELSE
                  defined_z := TRUE;
                  CLOSE value_servresp;
                  -- Log value found at user-level
                  IF corelog_is_enabled THEN
                     corelog(name_z,
                             nvl(val_z, 'NOVAL'),
                             'ServRespL VAL in GSDW',
                             user_id_z,
                             responsibility_id_z,
                             application_id_z,
                             org_id_z,
                             server_id_z);
                  END IF;
                  RETURN;
               END IF; -- value_servresp%NOTFOUND
            ELSE
               -- Context does not fit into the 3 *valid* servresp-level
               -- contexts.
               defined_z := FALSE;
            END IF;
         END IF;

         -- SITE level with Server hierarchy
         IF (hierarchy = 'SERVRESP' AND site_enabled = 'Y' AND
            level_id_z = 10001) THEN
            IF corelog_is_enabled THEN
               fnd_core_log.put_line(name_z, 'SL ServResp in FP.GSDW');
            END IF;
            OPEN value_uas(profile_option_id, profile_aid, 10001, 0);
            FETCH value_uas
               INTO val_z;
            IF (value_uas%NOTFOUND) THEN
               defined_z := FALSE;
               CLOSE value_uas;
            ELSE
               defined_z := TRUE;
               CLOSE value_uas;

               -- Log value found at site-level
               IF corelog_is_enabled THEN
                  corelog(name_z,
                          nvl(val_z, 'NOVAL'),
                          'SL VAL in GSDW',
                          user_id_z,
                          responsibility_id_z,
                          application_id_z,
                          org_id_z,
                          server_id_z);
               END IF;
               RETURN;
            END IF; -- value_uas%NOTFOUND

         END IF;

      END IF; -- PROFILE_OPTION_EXISTS if-then block

      -- If the call gets here, then no value was found.
      val_z     := NULL;
      defined_z := FALSE;

      -- Log value not found at any level
      IF corelog_is_enabled THEN
         corelog(name_z,
                 nvl(val_z, 'NOVAL'),
                 'Exit FP.GSDW',
                 user_id_z,
                 responsibility_id_z,
                 application_id_z,
                 org_id_z,
                 server_id_z);
      END IF;

   END get_specific_db_wnps;

   /*
   ** GET_SPECIFIC_WNPS -
   **   Get the profile option value for a specific context (without changing
   **   package state).
   **
   **   Context arguments (user_id_z, responsibility_id_z, application_id_z,
   **   org_id_z, server_id_z) specify what context to use to determine the
   **   profile option value.  Context arguments are interpreted as follows:
   **
   **        NULL - use current session context value (default)
   **          -1 - override current context with "undefined" value
   **     <value> - override current context with specified value
   **
   **   Special Notes:
   **     - Context override values are only used for determining the profile
   **       option value in this function call, the user session context is not
   **       changed.
   **
   **     - An undefined context value (-1) causes that context level to be
   **       skipped during processing, meaning that any profile option values
   **       set at that context level are ignored.
   **
   **     - Regardless of which context levels are defined, the profile option
   **       HIERARCHY_TYPE and '%_ENABLED_FLAG' flags determine which context
   **       levels are searched to find the value.
   **
   **     - Dynamic profile option values (PUT()) are NOT considered in this
   **       function, we only search values that are stored in the database.
   **
   */
   PROCEDURE get_specific_wnps
   (
      name_z              IN VARCHAR2, -- calling api should pass UPPER value
      user_id_z           IN NUMBER DEFAULT NULL,
      responsibility_id_z IN NUMBER DEFAULT NULL,
      application_id_z    IN NUMBER DEFAULT NULL,
      val_z               OUT NOCOPY VARCHAR2,
      defined_z           OUT NOCOPY BOOLEAN,
      org_id_z            IN NUMBER DEFAULT NULL,
      server_id_z         IN NUMBER DEFAULT NULL
   ) IS

      VALUE             VARCHAR2(240);
      cached            BOOLEAN;
      hashvalue         BINARY_INTEGER;
      userlevelskip     BOOLEAN := FALSE;
      resplevelskip     BOOLEAN := FALSE;
      appllevelskip     BOOLEAN := FALSE;
      orglevelskip      BOOLEAN := FALSE;
      serverlevelskip   BOOLEAN := FALSE;
      servresplevelskip BOOLEAN := FALSE;

   BEGIN

      IF corelog_is_enabled THEN
         corelog(name_z,
                 nvl(val_z, 'NOVAL'),
                 'Enter FP.GSW',
                 user_id_z,
                 responsibility_id_z,
                 application_id_z,
                 org_id_z,
                 server_id_z);
      END IF;

      val_z     := NULL;
      defined_z := FALSE;

      /* Bug 5603664: APPSPERF:FND:OPTIMIZE FND_PROFILE.VALUE
      ** Generate hashValue and pass it on to FIND and PUT calls.
      */
      hashvalue := dbms_utility.get_hash_value(name_z, 1, table_size);

      -- Determine if any of the context parameters, passed in, is equal to -1.
      -- -1 means that the level will be skipped for evaluation. These boolean
      -- flags replace the context conditions that check whether the context is
      -- <> -1. These conditions do not work when the context value is NUsLL since
      -- the comparison condition NULL <> -1 will equal FALSE even when NULL is
      -- not equal to -1. NULL cannot be directly compared with a number.
      --
      -- Skip user level if user_id_z = -1
      IF user_id_z = -1 THEN
         userlevelskip := TRUE;
      END IF;

      -- Skip responsibility level if responsibility_id_z = -1 and
      -- application_id_z = -1
      IF (responsibility_id_z = -1 AND application_id_z = -1) THEN
         resplevelskip := TRUE;
      END IF;

      -- Skip application level if application_id_z = -1
      IF application_id_z = -1 THEN
         appllevelskip := TRUE;
      END IF;

      -- Skip organization level if org_id_z = -1
      IF org_id_z = -1 THEN
         orglevelskip := TRUE;
      END IF;

      -- Skip server level if server_id_z = -1
      IF server_id_z = -1 THEN
         serverlevelskip := TRUE;
      END IF;

      -- Skip servresp level if responsibility_id_z, application_id_z and
      -- server_id_z all equal to -1
      IF (responsibility_id_z = -1 AND application_id_z = -1)
         AND server_id_z = -1 THEN
         servresplevelskip := TRUE;
      END IF;

      --
      -- The algorithm checks the context-level caches before going to the DB.
      -- If no value was obtained from context-level cache, then it checks the
      -- DB to ensure that accurate values are returned.
      --
      -- User-level cache is initially evaluated. If there is no level cache
      -- value at the user-level, then a database fetch is done. If no DB value is
      -- found at the user-level AND the context passed in is EQUAL to the
      -- current context, then the string **FND_UNDEFINED_VALUE** is placed at the
      -- user-level cache. This does 2 things: it prevents another DB fetch for
      -- the level and it also says that the level applies to the profile without
      -- having the profile option's definition. The code then "drops" to the next
      -- level and performs the same algorithm.
      --
      -- The benefit of just "dropping" to the next level without knowing whether
      -- the level applies to the profile or not is that a DB fetch can be avoided
      -- IF the levels have values already cached. Again, if a level has a value
      -- cached, then the level probably applies to the profile. Otherwise, there
      -- would not be a value cached.
      --
      -- This is a similar algorithm used in GET_CACHED to return accurate values.
      --
      -- By design, PROFILE_OPTION_EXISTS is not being checked here so that the
      -- code allows the profile to be *initially* (at least once) evaluated
      -- in GET_SPECIFIC_DB_WNPS which determines whether the profile exists.
      --
      --
      -- Evaluate User-level starting with the level cache if the context passed
      -- in <> -1.
      IF userlevelskip THEN
         -- If user context = -1, then user level should not be evaluated.
         -- This GET_SPECIFIC_DB_WNPS call will allow the profile option's
         -- definition to be fetched and used by the other applicable levels.
         -- The db fetch will also set PROFILE_OPTION_EXISTS accordingly.
         --
         -- NOTE: Should a value be found with the database fetch, the value is
         -- likely from the site-level and may not accurately represent the return
         -- value given the context passed in. The variables that hold the return
         -- values are reset just to be safe.
         get_specific_db_wnps(name_z,
                              -1,
                              -1,
                              -1,
                              val_z,
                              defined_z,
                              -1,
                              -1,
                              10004);
         -- Logging that user_id = -1 and that values were reset
         IF corelog_is_enabled THEN
            corelog(name_z,
                    nvl(val_z, 'RESET'),
                    'user_id_z=-1 in FP.GSW',
                    user_id_z,
                    responsibility_id_z,
                    application_id_z,
                    org_id_z,
                    server_id_z);
         END IF;
         val_z     := NULL;
         defined_z := FALSE;
      ELSE
         -- Check the user-level cache for a value.
         get_specific_level_wnps(name_z,
                                 10004,
                                 nvl(user_id_z, profiles_user_id),
                                 0,
                                 VALUE,
                                 cached,
                                 NULL,
                                 hashvalue);
         IF (VALUE IS NOT NULL) THEN
            -- Profile exists because a value is cached.
            profile_option_exists := TRUE;
            -- Log value found in user-level cache
            IF corelog_is_enabled THEN
               corelog(name_z,
                       nvl(VALUE, 'NOVAL'),
                       'UL Cache not null in FP.GSW',
                       user_id_z,
                       responsibility_id_z,
                       application_id_z,
                       org_id_z,
                       server_id_z);
            END IF;

            IF (VALUE <> fnd_undefined_value) THEN
               val_z     := VALUE;
               defined_z := TRUE;
               -- Log value found in user-level cache
               IF corelog_is_enabled THEN
                  corelog(name_z,
                          nvl(val_z, 'NOVAL'),
                          'UL Cache VAL in FP.GSW',
                          user_id_z,
                          responsibility_id_z,
                          application_id_z,
                          org_id_z,
                          server_id_z);
               END IF;
               RETURN;
            END IF;
         ELSE
            -- If no value was found in cache, i.e. NULL was returned, then
            -- see if user-level context has a value in database.
            get_specific_db_wnps(name_z,
                                 nvl(user_id_z, profiles_user_id),
                                 -1,
                                 -1,
                                 val_z,
                                 defined_z,
                                 -1,
                                 -1,
                                 10004);
            IF defined_z THEN
               -- Value found at user-level
               -- Log value found
               IF corelog_is_enabled THEN
                  corelog(name_z,
                          nvl(val_z, 'NOVAL'),
                          'UL VAL via GSDW in FP.GSW',
                          user_id_z,
                          responsibility_id_z,
                          application_id_z,
                          org_id_z,
                          server_id_z);
               END IF;
               RETURN;
            ELSIF (user_id_z = profiles_user_id) THEN
               -- Cache '**FND_UNDEFINED_VALUE**' value for profile at user-level
               -- if context is the same, i.e. user_id_z = PROFILES_USER_ID.
               put(name_z,
                   fnd_undefined_value,
                   user_name_tab,
                   user_val_tab,
                   hashvalue);
            END IF;
         END IF;
      END IF;

      -- Evaluate Responsibility-level and see if the cache has a value.
      -- Bypass if responsibility_id_z and/or application_id_z = -1.
      IF profile_option_exists
         AND NOT resplevelskip THEN
         -- Check Responsibility-level cache
         get_specific_level_wnps(name_z,
                                 10003,
                                 nvl(responsibility_id_z, profiles_resp_id),
                                 nvl(application_id_z, profiles_appl_id),
                                 VALUE,
                                 cached,
                                 NULL,
                                 hashvalue);
         IF (VALUE IS NOT NULL) THEN
            -- Log value found in resp-level cache
            IF corelog_is_enabled THEN
               corelog(name_z,
                       nvl(VALUE, 'NOVAL'),
                       'RL Cache not null in FP.GSW',
                       user_id_z,
                       responsibility_id_z,
                       application_id_z,
                       org_id_z,
                       server_id_z);
            END IF;

            IF (VALUE <> fnd_undefined_value) THEN
               val_z     := VALUE;
               defined_z := TRUE;
               -- Log value found in resp-level cache
               IF corelog_is_enabled THEN
                  corelog(name_z,
                          nvl(VALUE, 'NOVAL'),
                          'RL Cache VAL in FP.GSW',
                          user_id_z,
                          responsibility_id_z,
                          application_id_z,
                          org_id_z,
                          server_id_z);
               END IF;
               RETURN;
            END IF;
         ELSE
            -- See if Responsibility-level context has a value in database.
            get_specific_db_wnps(name_z,
                                 -1,
                                 nvl(responsibility_id_z, profiles_resp_id),
                                 nvl(application_id_z, profiles_appl_id),
                                 val_z,
                                 defined_z,
                                 -1,
                                 -1,
                                 10003);
            IF defined_z THEN
               -- Value found at responsibility-level
               -- Log value found
               IF corelog_is_enabled THEN
                  corelog(name_z,
                          nvl(val_z, 'NOVAL'),
                          'RL VAL via GSDW in FP.GSW',
                          user_id_z,
                          responsibility_id_z,
                          application_id_z,
                          org_id_z,
                          server_id_z);
               END IF;
               RETURN;
            ELSIF ((responsibility_id_z = profiles_resp_id) AND
                  (application_id_z = profiles_appl_id)) THEN
               -- Cache '**FND_UNDEFINED_VALUE**' value for profile at
               -- resp-level if context is the same, i.e. responsibility_id_z =
               -- PROFILES_RESP_ID and application_id_z = PROFILES_APPL_ID.
               put(name_z,
                   fnd_undefined_value,
                   resp_name_tab,
                   resp_val_tab,
                   hashvalue);
            END IF;
         END IF;
      END IF;

      -- Evaluate the Application-level and see if the cache has a value.
      -- Bypass if application_id_z = -1.
      IF profile_option_exists
         AND NOT appllevelskip THEN
         -- Check Application-level cache
         get_specific_level_wnps(name_z,
                                 10002,
                                 nvl(application_id_z, profiles_appl_id),
                                 0,
                                 VALUE,
                                 cached,
                                 NULL,
                                 hashvalue);
         IF (VALUE IS NOT NULL) THEN
            -- Log value found in appl-level cache
            IF corelog_is_enabled THEN
               corelog(name_z,
                       nvl(VALUE, 'NOVAL'),
                       'AL Cache not null in FP.GSW',
                       user_id_z,
                       responsibility_id_z,
                       application_id_z,
                       org_id_z,
                       server_id_z);
            END IF;

            IF (VALUE <> fnd_undefined_value) THEN
               val_z     := VALUE;
               defined_z := TRUE;
               -- Log value found in appl-level cache
               IF corelog_is_enabled THEN
                  corelog(name_z,
                          nvl(VALUE, 'NOVAL'),
                          'AL Cache VAL in FP.GSW',
                          user_id_z,
                          responsibility_id_z,
                          application_id_z,
                          org_id_z,
                          server_id_z);
               END IF;
               RETURN;
            END IF;
         ELSE
            -- See if Application-level context has a value in DB
            get_specific_db_wnps(name_z,
                                 -1,
                                 -1,
                                 nvl(application_id_z, profiles_appl_id),
                                 val_z,
                                 defined_z,
                                 -1,
                                 -1,
                                 10002);
            IF defined_z THEN
               -- Value found at application-level
               -- Log value found
               IF corelog_is_enabled THEN
                  corelog(name_z,
                          nvl(val_z, 'NOVAL'),
                          'AL VAL via GSDW in FP.GSW',
                          user_id_z,
                          responsibility_id_z,
                          application_id_z,
                          org_id_z,
                          server_id_z);
               END IF;
               RETURN;
            ELSIF (application_id_z = profiles_appl_id) THEN
               -- Cache '**FND_UNDEFINED_VALUE**' value for profile at
               -- appl-level if context is the same, i.e. application_id_z =
               -- PROFILES_APPL_ID.
               put(name_z,
                   fnd_undefined_value,
                   appl_name_tab,
                   appl_val_tab,
                   hashvalue);
            END IF;
         END IF;
      END IF;

      -- Evaluate the Organization-level and see if the cache has a value.
      IF profile_option_exists
         AND NOT orglevelskip THEN
         -- Bug 7526805: get_specific_wnps MUST USE current context
         -- (PROFILES_ORG_ID) in the absence of a context passed in
         -- (org_id_z)
         IF (profiles_org_id IS NOT NULL)
            OR (org_id_z IS NOT NULL) THEN
            -- Check Organization-level cache
            get_specific_level_wnps(name_z,
                                    10006,
                                    nvl(org_id_z, profiles_org_id),
                                    0,
                                    VALUE,
                                    cached,
                                    NULL,
                                    hashvalue);
            IF (VALUE IS NOT NULL) THEN
               -- Log value found in org-level cache
               IF corelog_is_enabled THEN
                  corelog(name_z,
                          nvl(VALUE, 'NOVAL'),
                          'OL Cache not null in FP.GSW',
                          user_id_z,
                          responsibility_id_z,
                          application_id_z,
                          org_id_z,
                          server_id_z);
               END IF;

               IF (VALUE <> fnd_undefined_value) THEN
                  val_z     := VALUE;
                  defined_z := TRUE;
                  -- Log value found in org-level cache
                  IF corelog_is_enabled THEN
                     corelog(name_z,
                             nvl(VALUE, 'NOVAL'),
                             'OL Cache VAL in FP.GSW',
                             user_id_z,
                             responsibility_id_z,
                             application_id_z,
                             org_id_z,
                             server_id_z);
                  END IF;
                  RETURN;
               END IF;
            ELSE
               -- See if Organization-level context has a value in DB
               get_specific_db_wnps(name_z,
                                    -1,
                                    -1,
                                    -1,
                                    val_z,
                                    defined_z,
                                    nvl(org_id_z, profiles_org_id),
                                    -1,
                                    10006);
               IF defined_z THEN
                  -- Value found at organization-level
                  -- Log value found
                  IF corelog_is_enabled THEN
                     corelog(name_z,
                             nvl(val_z, 'NOVAL'),
                             'OL VAL via GSDW in FP.GSW',
                             user_id_z,
                             responsibility_id_z,
                             application_id_z,
                             org_id_z,
                             server_id_z);
                  END IF;
                  RETURN;
               ELSIF (org_id_z = profiles_org_id) THEN
                  -- Cache '**FND_UNDEFINED_VALUE**' value for profile at
                  -- org-level if context is the same, i.e.
                  -- org_id_z = PROFILES_ORG_ID.
                  put(name_z,
                      fnd_undefined_value,
                      org_name_tab,
                      org_val_tab,
                      hashvalue);
               END IF;
            END IF;
         END IF;
      END IF;

      -- Evaluate the Server-level and see if the cache has a value.
      IF profile_option_exists
         AND NOT serverlevelskip THEN
         -- Bug 7526805: get_specific_wnps MUST USE current context
         -- (PROFILES_SERVER_ID) in the absence of a context passed in
         -- (server_id_z).
         IF ((profiles_server_id IS NOT NULL) OR (server_id_z IS NOT NULL)) THEN
            -- Check Server-level cache
            get_specific_level_wnps(name_z,
                                    10005,
                                    nvl(server_id_z, profiles_server_id),
                                    0,
                                    VALUE,
                                    cached,
                                    NULL,
                                    hashvalue);
            IF (VALUE IS NOT NULL) THEN
               -- Log value found in server-level cache
               IF corelog_is_enabled THEN
                  corelog(name_z,
                          nvl(VALUE, 'NOVAL'),
                          'SRVL Cache not null in FP.GSW',
                          user_id_z,
                          responsibility_id_z,
                          application_id_z,
                          org_id_z,
                          server_id_z);
               END IF;

               IF (VALUE <> fnd_undefined_value) THEN
                  val_z     := VALUE;
                  defined_z := TRUE;
                  -- Log value found in server-level cache
                  IF corelog_is_enabled THEN
                     corelog(name_z,
                             nvl(VALUE, 'NOVAL'),
                             'SRVL Cache VAL in FP.GSW',
                             user_id_z,
                             responsibility_id_z,
                             application_id_z,
                             org_id_z,
                             server_id_z);
                  END IF;
                  RETURN;
               END IF;
            ELSE
               -- See if Server-level context has a value in DB
               get_specific_db_wnps(name_z,
                                    -1,
                                    -1,
                                    -1,
                                    val_z,
                                    defined_z,
                                    -1,
                                    nvl(server_id_z, profiles_server_id),
                                    10005);
               IF defined_z THEN
                  -- Value found at server-level
                  -- Log value found
                  IF corelog_is_enabled THEN
                     corelog(name_z,
                             nvl(val_z, 'NOVAL'),
                             'SRVL VAL via GSDW in FP.GSW',
                             user_id_z,
                             responsibility_id_z,
                             application_id_z,
                             org_id_z,
                             server_id_z);
                  END IF;
                  RETURN;
               ELSIF (server_id_z = profiles_server_id) THEN
                  -- Cache '**FND_UNDEFINED_VALUE**' value for profile at
                  -- server-level if context is the same,
                  -- i.e. server_id_z = PROFILES_SERVER_ID.
                  put(name_z,
                      fnd_undefined_value,
                      server_name_tab,
                      server_val_tab,
                      hashvalue);
               END IF;
            END IF;
         END IF;
      END IF;

      -- Evaluate the Servresp-level and see if the cache has a value.
      IF profile_option_exists
         AND NOT servresplevelskip THEN
         -- Check Servresp-level cache
         get_specific_level_wnps(name_z,
                                 10007,
                                 nvl(responsibility_id_z, profiles_resp_id),
                                 nvl(application_id_z, profiles_appl_id),
                                 VALUE,
                                 cached,
                                 nvl(server_id_z, profiles_server_id),
                                 hashvalue);
         IF (VALUE IS NOT NULL) THEN
            -- Log value found in server-level cache
            IF corelog_is_enabled THEN
               corelog(name_z,
                       nvl(VALUE, 'NOVAL'),
                       'ServRespL Cache not null in FP.GSW',
                       user_id_z,
                       responsibility_id_z,
                       application_id_z,
                       org_id_z,
                       server_id_z);
            END IF;

            IF (VALUE <> fnd_undefined_value) THEN
               val_z     := VALUE;
               defined_z := TRUE;
               -- Log value found in servresp-level cache
               IF corelog_is_enabled THEN
                  corelog(name_z,
                          nvl(VALUE, 'NOVAL'),
                          'ServRespL Cache VAL in FP.GSW',
                          user_id_z,
                          responsibility_id_z,
                          application_id_z,
                          org_id_z,
                          server_id_z);
               END IF;
               RETURN;
            END IF;
         ELSE
            -- See if Servresp-level context has a value in DB
            /* Bug 4021624: FND_RUN_FUNCTION.GET_JSP_AGENT calls
            ** FND_PROFILE.VALUE_SPECIFIC and site value is consistently
            ** returned, given a Resp ID and Server ID. GET_SPECIFIC_DB_WNPS
            ** was being called for the Resp ID + Server ID combination ONLY
            ** and was missing the values set for Resp ID + (Server ID = -1)
            ** and (Resp ID = -1) + Server ID combos. GET_SPECIFIC_DB_WNPS
            ** needs to be called for those combinations, as well.
            */
            -- Start with Resp ID + Server ID combination --
            get_specific_db_wnps(name_z,
                                 -1,
                                 nvl(responsibility_id_z, profiles_resp_id),
                                 nvl(application_id_z, profiles_appl_id),
                                 val_z,
                                 defined_z,
                                 -1,
                                 nvl(server_id_z, profiles_server_id),
                                 10007);
            IF defined_z THEN
               -- Value found at servresp-level
               -- Log value found in servresp-level cache
               IF corelog_is_enabled THEN
                  corelog(name_z,
                          nvl(val_z, 'NOVAL'),
                          'ServRespL R+S VAL via GSDW in FP.GSW',
                          user_id_z,
                          responsibility_id_z,
                          application_id_z,
                          org_id_z,
                          server_id_z);
               END IF;
               RETURN;
            ELSE
               /* Bug 4021624: SERVERLEVEL CONTEXT NOT INITALIZED BEFORE
               ** FND_RUN_FUNCTION IN ICX_PORTLET
               ** If Resp ID + Server ID combination yields no results, try
               ** Resp ID + (Server ID = -1) combination
               */
               get_specific_db_wnps(name_z,
                                    -1,
                                    nvl(responsibility_id_z,
                                        profiles_resp_id),
                                    nvl(application_id_z, profiles_appl_id),
                                    val_z,
                                    defined_z,
                                    -1,
                                    -1,
                                    10007);
               IF defined_z THEN
                  -- Value found at servresp-level
                  -- Log value found in servresp-level cache
                  IF corelog_is_enabled THEN
                     corelog(name_z,
                             nvl(val_z, 'NOVAL'),
                             'ServRespL R+-1 VAL via GSDW in FP.GSW',
                             user_id_z,
                             responsibility_id_z,
                             application_id_z,
                             org_id_z,
                             server_id_z);
                  END IF;
                  RETURN;
               ELSE
                  /* Bug 4021624: SERVERLEVEL CONTEXT NOT INITALIZED BEFORE
                  ** FND_RUN_FUNCTION IN ICX_PORTLET
                  ** If Resp ID + (Server ID = -1) combination yields no
                  ** results, try (Resp ID = -1) + Server ID combination
                  */
                  get_specific_db_wnps(name_z,
                                       -1,
                                       -1,
                                       -1,
                                       val_z,
                                       defined_z,
                                       -1,
                                       nvl(server_id_z, profiles_server_id),
                                       10007);
                  IF defined_z THEN
                     -- Value found at servresp-level */
                     -- Log value found in servresp-level cache */
                     IF corelog_is_enabled THEN
                        corelog(name_z,
                                nvl(val_z, 'NOVAL'),
                                'ServRespL S+-1 VAL via GSDW in FP.GSW',
                                user_id_z,
                                responsibility_id_z,
                                application_id_z,
                                org_id_z,
                                server_id_z);
                     END IF;
                     RETURN;
                  ELSIF ((responsibility_id_z = profiles_resp_id) AND
                        (server_id_z = profiles_server_id)) THEN
                     -- Cache '**FND_UNDEFINED_VALUE**' value for profile at
                     -- server-level. If context is the same,
                     -- i.e. server_id_z = PROFILES_SERVER_ID.
                     put(name_z,
                         fnd_undefined_value,
                         servresp_name_tab,
                         servresp_val_tab,
                         hashvalue);
                  END IF; -- servresp-level
               END IF;
            END IF;
         END IF;
      END IF;

      -- Evaluate site-level if none of the levels yield a value.
      IF profile_option_exists THEN
         -- Finally, check Site-level cache
         get_specific_level_wnps(name_z,
                                 10001,
                                 0,
                                 0,
                                 VALUE,
                                 cached,
                                 NULL,
                                 hashvalue);
         IF (VALUE IS NOT NULL) THEN
            -- Log value found in site-level cache
            IF corelog_is_enabled THEN
               corelog(name_z,
                       nvl(VALUE, 'NOVAL'),
                       'SL Cache not null in FP.GSW',
                       user_id_z,
                       responsibility_id_z,
                       application_id_z,
                       org_id_z,
                       server_id_z);
            END IF;

            IF (VALUE <> fnd_undefined_value) THEN
               val_z     := VALUE;
               defined_z := TRUE;
               -- Log value found in site-level cache
               IF corelog_is_enabled THEN
                  corelog(name_z,
                          nvl(VALUE, 'NOVAL'),
                          'SL Cache VAL in FP.GSW',
                          user_id_z,
                          responsibility_id_z,
                          application_id_z,
                          org_id_z,
                          server_id_z);
               END IF;
               RETURN;
            END IF;
         ELSE
            -- See if site-level has a value in DB
            get_specific_db_wnps(name_z,
                                 -1,
                                 -1,
                                 -1,
                                 val_z,
                                 defined_z,
                                 -1,
                                 -1,
                                 10001);
            IF defined_z THEN
               -- Value found at site-level
               -- Log value found
               IF corelog_is_enabled THEN
                  corelog(name_z,
                          nvl(val_z, 'NOVAL'),
                          'SL VAL via GSDW in FP.GSW',
                          user_id_z,
                          responsibility_id_z,
                          application_id_z,
                          org_id_z,
                          server_id_z);
               END IF;
               RETURN;
            ELSE
               -- Cache '**FND_UNDEFINED_VALUE**' value for profile at
               -- site-level
               put(name_z,
                   fnd_undefined_value,
                   site_name_tab,
                   site_val_tab,
                   hashvalue);
            END IF;
         END IF;
      END IF;
      --
      -- End of Cache calls
      -- If the call gets here, then no value was found in cache or in DB
      --
      val_z     := NULL;
      defined_z := FALSE;

      -- Log value not found at any level
      IF corelog_is_enabled THEN
         corelog(name_z,
                 nvl(val_z, 'NOVAL'),
                 'Exit FP.GSW',
                 user_id_z,
                 responsibility_id_z,
                 application_id_z,
                 org_id_z,
                 server_id_z);
      END IF;

   END get_specific_wnps;

   /*
   ** GET_CACHED -
   **   Get the profile value for the current user/resp/appl.
   **   This API will also save the profile value in its appropriate level
   **   cache.
   */
   PROCEDURE get_cached
   (
      name_z    IN VARCHAR2, -- should be passed UPPER value
      val_z     OUT NOCOPY VARCHAR2,
      defined_z OUT NOCOPY BOOLEAN
   ) IS

      VALUE     VARCHAR2(240);
      cached    BOOLEAN;
      hashvalue BINARY_INTEGER;

   BEGIN

      -- Log API Entry
      IF corelog_is_enabled THEN
         corelog(name_z, nvl(val_z, 'NOVAL'), 'Enter FP.GC');
      END IF;

      val_z     := NULL;
      defined_z := FALSE;

      /* Bug 5603664: APPSPERF:FND:OPTIMIZE FND_PROFILE.VALUE
      ** Generate hashValue and pass it on to FIND and PUT calls.
      */
      hashvalue := dbms_utility.get_hash_value(name_z, 1, table_size);

      --
      -- The algorithm is to check the cache first, if a profile option has
      -- been cached before, we will check if the tables were updated since it
      -- was last cached. If they were, then we need to refresh the cache, by
      -- deleting and repopulating via GET_SPECIFIC_DB. The algorithm also
      -- follows the profile hierarchy.  If the the profile option/value has
      -- never been cached, we will go to the DB after the cached calls.
      --

      /* Bug 3637977: FND_PROFILE:CONTEXT-LEVEL CHANGES NOT REFLECTED BY RETURN
      ** VALUES
      ** For each level, a call to GET_SPECIFIC_DB was added to
      ** ensure that a context-level value does not exist, if no value was
      ** found at context-level cache.  The GET_SPECIFIC_DB call done is
      ** context-level specific, i.e. if user-level is the value that needs to
      ** be obtained, only the user-id is passed.  The GET_SPECIFIC_DB call for
      ** the site-level is done with no context taken into account.
      **
      ** Bug 3714184 and 3733896: The suggestion by the ATG Performance Team is
      ** to cache null or '**FND_UNDEFINED_VALUE**' via a PUT() call for
      ** profiles that return no values or are undefined.  This will minimize
      ** the GET_SPECIFIC_DB calls.
      */

      --
      -- By design, PROFILE_OPTION_EXISTS is not being checked here so that the
      -- code allows the profile to be evaluated, at least once, in
      -- GET_SPECIFIC_DB which determines whether the profile exists.
      --

      -- Check User-level cache
      get_specific_level_wnps(name_z,
                              10004,
                              profiles_user_id,
                              0,
                              VALUE,
                              cached,
                              NULL,
                              hashvalue);
      IF (VALUE IS NOT NULL) THEN
         -- Profile exists because a value is cached.
         profile_option_exists := TRUE;
         -- Log value found in user-level cache
         IF corelog_is_enabled THEN
            corelog(name_z,
                    nvl(VALUE, 'NOVAL'),
                    'UL Cache not null in FP.GC');
         END IF;
         IF (VALUE <> fnd_undefined_value) THEN
            val_z     := VALUE;
            defined_z := TRUE;
            -- Log value found in user-level cache
            IF corelog_is_enabled THEN
               corelog(name_z,
                       nvl(val_z, 'NOVAL'),
                       'UL Cache VAL in FP.GC');
            END IF;
            RETURN;
         END IF;
      ELSE
         /* Bug 3637977, see if user-level context has a value in DB */
         get_specific_db(name_z,
                         profiles_user_id,
                         -1,
                         -1,
                         val_z,
                         defined_z,
                         -1,
                         -1,
                         10004,
                         hashvalue);
         IF defined_z THEN
            -- Value found at user-level
            -- Log value found
            IF corelog_is_enabled THEN
               corelog(name_z,
                       nvl(val_z, 'NOVAL'),
                       'UL VAL via GSD in FP.GC');
            END IF;
            RETURN;
         ELSE
            -- Cache '**FND_UNDEFINED_VALUE**' value for profile at user-level
            put(name_z,
                fnd_undefined_value,
                user_name_tab,
                user_val_tab,
                hashvalue);
         END IF;
      END IF;

      IF profile_option_exists THEN
         -- Check Responsibility-level cache
         get_specific_level_wnps(name_z,
                                 10003,
                                 profiles_resp_id,
                                 profiles_appl_id,
                                 VALUE,
                                 cached,
                                 NULL,
                                 hashvalue);
         IF (VALUE IS NOT NULL) THEN
            -- Log value found in resp-level cache
            IF corelog_is_enabled THEN
               corelog(name_z,
                       nvl(VALUE, 'NOVAL'),
                       'RL Cache not null in FP.GC');
            END IF;
            IF (VALUE <> fnd_undefined_value) THEN
               val_z     := VALUE;
               defined_z := TRUE;
               -- Log value found in resp-level cache
               IF corelog_is_enabled THEN
                  corelog(name_z,
                          nvl(val_z, 'NOVAL'),
                          'RL Cache VAL in FP.GC');
               END IF;
               RETURN;
            END IF;
         ELSE
            /* Bug 3637977, see if resp-level context has a value in DB */
            get_specific_db(name_z,
                            -1,
                            profiles_resp_id,
                            profiles_appl_id,
                            val_z,
                            defined_z,
                            -1,
                            -1,
                            10003,
                            hashvalue);
            IF defined_z THEN
               -- Value found at resp-level
               -- Log value found
               IF corelog_is_enabled THEN
                  corelog(name_z,
                          nvl(val_z, 'NOVAL'),
                          'RL VAL via GSD in FP.GC');
               END IF;
               RETURN;
            ELSE
               -- Cache '**FND_UNDEFINED_VALUE**' value for profile at
               -- resp-level
               put(name_z,
                   fnd_undefined_value,
                   resp_name_tab,
                   resp_val_tab,
                   hashvalue);
            END IF;
         END IF;
      END IF;

      IF profile_option_exists THEN
         -- Check Application-level cache --
         get_specific_level_wnps(name_z,
                                 10002,
                                 profiles_appl_id,
                                 0,
                                 VALUE,
                                 cached,
                                 NULL,
                                 hashvalue);
         IF (VALUE IS NOT NULL) THEN
            -- Log value found in appl-level cache
            IF corelog_is_enabled THEN
               corelog(name_z,
                       nvl(VALUE, 'NOVAL'),
                       'AL Cache not null in FP.GC');
            END IF;
            IF (VALUE <> fnd_undefined_value) THEN
               val_z     := VALUE;
               defined_z := TRUE;
               -- Log value found in appl-level cache
               IF corelog_is_enabled THEN
                  corelog(name_z,
                          nvl(val_z, 'NOVAL'),
                          'AL Cache VAL in FP.GC');
               END IF;
               RETURN;
            END IF;
         ELSE
            /* Bug 3637977, see if appl-level context has a value in DB */
            get_specific_db(name_z,
                            -1,
                            -1,
                            profiles_appl_id,
                            val_z,
                            defined_z,
                            -1,
                            -1,
                            10002,
                            hashvalue);
            IF defined_z THEN
               -- Value found at application-level
               -- Log value found
               IF corelog_is_enabled THEN
                  corelog(name_z,
                          nvl(val_z, 'NOVAL'),
                          'AL VAL via GSD in FP.GC');
               END IF;
               RETURN;
            ELSE
               -- Cache '**FND_UNDEFINED_VALUE**' value for profile at
               -- appl-level
               put(name_z,
                   fnd_undefined_value,
                   appl_name_tab,
                   appl_val_tab,
                   hashvalue);
            END IF;
         END IF;
      END IF;

      IF profile_option_exists THEN
         IF profiles_org_id IS NOT NULL THEN
            -- Check Organization-level cache
            get_specific_level_wnps(name_z,
                                    10006,
                                    profiles_org_id,
                                    0,
                                    VALUE,
                                    cached,
                                    NULL,
                                    hashvalue);
            IF (VALUE IS NOT NULL) THEN
               -- Log value found in org-level cache
               IF corelog_is_enabled THEN
                  corelog(name_z,
                          nvl(VALUE, 'NOVAL'),
                          'OL Cache not null in FP.GC');
               END IF;
               IF (VALUE <> fnd_undefined_value) THEN
                  val_z     := VALUE;
                  defined_z := TRUE;
                  -- Log value found in org-level cache
                  IF corelog_is_enabled THEN
                     corelog(name_z,
                             nvl(val_z, 'NOVAL'),
                             'OL Cache VAL in FP.GC');
                  END IF;
                  RETURN;
               END IF;
            ELSE
               /* Bug 3637977, see if org-level context has a value in DB */
               get_specific_db(name_z,
                               -1,
                               -1,
                               -1,
                               val_z,
                               defined_z,
                               profiles_org_id,
                               -1,
                               10006,
                               hashvalue);
               IF defined_z THEN
                  -- Value found at org-level
                  -- Log value found
                  IF corelog_is_enabled THEN
                     corelog(name_z,
                             nvl(val_z, 'NOVAL'),
                             'OL VAL via GSD in FP.GC');
                  END IF;
                  RETURN;
               ELSE
                  -- Cache '**FND_UNDEFINED_VALUE**' value for profile at
                  -- org-level
                  put(name_z,
                      fnd_undefined_value,
                      org_name_tab,
                      org_val_tab,
                      hashvalue);
               END IF;
            END IF;
         END IF;
      END IF;

      IF profile_option_exists THEN
         -- Check Server-level cache
         get_specific_level_wnps(name_z,
                                 10005,
                                 profiles_server_id,
                                 0,
                                 VALUE,
                                 cached,
                                 NULL,
                                 hashvalue);
         IF (VALUE IS NOT NULL) THEN
            -- Log value found in server-level cache
            IF corelog_is_enabled THEN
               corelog(name_z,
                       nvl(VALUE, 'NOVAL'),
                       'SRVL Cache not null in FP.GC');
            END IF;
            IF (VALUE <> fnd_undefined_value) THEN
               val_z     := VALUE;
               defined_z := TRUE;
               -- Log value found in server-level cache
               IF corelog_is_enabled THEN
                  corelog(name_z,
                          nvl(val_z, 'NOVAL'),
                          'SRVL Cache VAL in FP.GC');
               END IF;
               RETURN;
            END IF;
         ELSE
            /* Bug 3637977, see if server-level context has a value in DB */
            get_specific_db(name_z,
                            -1,
                            -1,
                            -1,
                            val_z,
                            defined_z,
                            -1,
                            profiles_server_id,
                            10005,
                            hashvalue);
            IF defined_z THEN
               -- Value found at server-level
               -- Log value found
               IF corelog_is_enabled THEN
                  corelog(name_z,
                          nvl(val_z, 'NOVAL'),
                          'SRVL VAL via GSD in FP.GC');
               END IF;
               RETURN;
            ELSE
               -- Cache '**FND_UNDEFINED_VALUE**' value for profile at
               -- server-level
               put(name_z,
                   fnd_undefined_value,
                   server_name_tab,
                   server_val_tab,
                   hashvalue);
            END IF;
         END IF;
      END IF;

      IF profile_option_exists THEN
         -- Check Server/Responsibility-level cache
         get_specific_level_wnps(name_z,
                                 10007,
                                 profiles_resp_id,
                                 profiles_appl_id,
                                 VALUE,
                                 cached,
                                 profiles_server_id,
                                 hashvalue);
         IF (VALUE IS NOT NULL) THEN
            -- Log value found in ServResp-level cache
            IF corelog_is_enabled THEN
               corelog(name_z,
                       nvl(VALUE, 'NOVAL'),
                       'ServRespL Cache not null in FP.GC');
            END IF;
            IF (VALUE <> fnd_undefined_value) THEN
               val_z     := VALUE;
               defined_z := TRUE;
               -- Log value found in ServResp-level cache
               IF corelog_is_enabled THEN
                  corelog(name_z,
                          nvl(val_z, 'NOVAL'),
                          'ServRespL Cache VAL in FP.GC');
               END IF;
               RETURN;
            END IF;
         ELSE
            -- See if servresp-level context has a value in DB
            get_specific_db(name_z,
                            -1,
                            profiles_resp_id,
                            profiles_appl_id,
                            val_z,
                            defined_z,
                            -1,
                            profiles_server_id,
                            10007,
                            hashvalue);
            IF defined_z THEN
               -- Value found at ServResp-level
               -- Log value found
               IF corelog_is_enabled THEN
                  corelog(name_z,
                          nvl(val_z, 'NOVAL'),
                          'ServRespL VAL via GSD in FP.GC');
               END IF;
               RETURN;
            ELSE
               -- Cache '**FND_UNDEFINED_VALUE**' value for profile at
               -- resp-level
               put(name_z,
                   fnd_undefined_value,
                   servresp_name_tab,
                   servresp_val_tab,
                   hashvalue);
            END IF;
         END IF;
      END IF;

      IF profile_option_exists THEN
         -- Check Site-level cache
         get_specific_level_wnps(name_z,
                                 10001,
                                 0,
                                 0,
                                 VALUE,
                                 cached,
                                 NULL,
                                 hashvalue);
         IF (VALUE IS NOT NULL) THEN
            -- Log value found in site-level cache
            IF corelog_is_enabled THEN
               corelog(name_z,
                       nvl(VALUE, 'NOVAL'),
                       'SL Cache not null in FP.GC');
            END IF;
            IF (VALUE <> fnd_undefined_value) THEN
               val_z     := VALUE;
               defined_z := TRUE;
               -- Log value found in site-level cache
               IF corelog_is_enabled THEN
                  corelog(name_z,
                          nvl(val_z, 'NOVAL'),
                          'SL Cache VAL in FP.GC');
               END IF;
               RETURN;
            END IF;
         ELSE
            /* Bug 3637977, see if site-level context has a value in DB */
            get_specific_db(name_z,
                            -1,
                            -1,
                            -1,
                            val_z,
                            defined_z,
                            -1,
                            -1,
                            10001,
                            hashvalue);
            IF defined_z THEN
               -- Value found at site-level
               -- Log value found
               IF corelog_is_enabled THEN
                  corelog(name_z,
                          nvl(val_z, 'NOVAL'),
                          'SL VAL via GSD in FP.GC');
               END IF;
               RETURN;
            ELSE
               -- Cache '**FND_UNDEFINED_VALUE**' value for profile at
               -- site-level
               put(name_z,
                   fnd_undefined_value,
                   site_name_tab,
                   site_val_tab,
                   hashvalue);
            END IF;
         END IF;
      END IF;
      -- End of Cache calls

      -- If it gets here, then there is no value for the profile option and it
      -- is not defined.
      val_z     := NULL;
      defined_z := FALSE;

      -- Log value not found at any level
      IF corelog_is_enabled THEN
         corelog(name_z, nvl(val_z, 'NOVAL'), 'Exit FP.GC');
      END IF;

   END get_cached;

   /*
   ** DEFINED - test if profile option is defined
   */
   FUNCTION defined(NAME IN VARCHAR2) RETURN BOOLEAN IS
      val VARCHAR2(255);
   BEGIN
      get(NAME, val);
      RETURN(val IS NOT NULL);
   END defined;

   /*
   ** GET - get the value of a profile option
   **
   ** NOTES
   **    If the option cannot be found, the out buffer is set to NULL
   **    Since a profile value can never be set to NULL,
   **    if this returns a NULL, then the profile doesn't exist.
   */
   PROCEDURE get
   (
      NAME IN VARCHAR2,
      val  OUT NOCOPY VARCHAR2
   ) IS
      table_index BINARY_INTEGER;
      defined     BOOLEAN;
      outval      VARCHAR2(255);
      name_upper  VARCHAR2(80) := upper(NAME);
   BEGIN

      -- Log API Entry
      IF corelog_is_enabled THEN
         corelog(name_upper, nvl(val, 'NOVAL'), 'Enter FP.G');
      END IF;

      -- Search for the profile option
      table_index := find(name_upper);

      IF table_index < table_size THEN
         val := val_tab(table_index);
         -- Log value found in Generic Put Cache, API Exit
         IF corelog_is_enabled THEN
            corelog(name_upper,
                    nvl(val, 'NOVAL'),
                    'VAL in GEN PUT, Exit FP.G');
         END IF;
      ELSE
         -- Can't find the value in the table; look in the database
         get_cached(name_upper, outval, defined);
         val := outval;
         -- Log API Exit
         IF corelog_is_enabled THEN
            corelog(name_upper,
                    nvl(val, 'NOVAL'),
                    'VAL in FP.GC, Exit FP.G');
         END IF;
      END IF;

   EXCEPTION
      WHEN OTHERS THEN
         NULL;
   END get;

   /*
   ** INVALIDATE_CACHE - Call WF_EVENT.RAISE to invalidate the cache entry
   **                    corresponding to the specified profile.
   */
   PROCEDURE invalidate_cache
   (
      x_level_name         IN VARCHAR2,
      x_level_value        IN VARCHAR2,
      x_level_value_app_id IN VARCHAR2,
      x_name               IN VARCHAR2,
      x_level_value2       IN VARCHAR2 DEFAULT NULL
   ) IS

      level_id            NUMBER;
      level_value         NUMBER;
      level_value_appl_id NUMBER;
      NAME                VARCHAR2(80) := upper(x_name);
      event_key           VARCHAR2(255);
      level_value2        NUMBER;

   BEGIN
      IF (x_level_name = 'SITE') THEN
         level_id            := 10001;
         level_value         := 0;
         level_value_appl_id := 0;
      ELSIF (x_level_name = 'APPL') THEN
         level_id            := 10002;
         level_value         := to_number(x_level_value);
         level_value_appl_id := 0;
      ELSIF (x_level_name = 'RESP') THEN
         level_id            := 10003;
         level_value         := to_number(x_level_value);
         level_value_appl_id := to_number(x_level_value_app_id);
      ELSIF (x_level_name = 'USER') THEN
         level_id            := 10004;
         level_value         := to_number(x_level_value);
         level_value_appl_id := 0;
      ELSIF (x_level_name = 'SERVER') THEN
         level_id            := 10005;
         level_value         := to_number(x_level_value);
         level_value_appl_id := 0;
      ELSIF (x_level_name = 'ORG') THEN
         level_id            := 10006;
         level_value         := to_number(x_level_value);
         level_value_appl_id := 0;
      ELSIF (x_level_name = 'SERVRESP') THEN
         -- Added for server/resp hierarchy
         level_id            := 10007;
         level_value         := to_number(x_level_value);
         level_value_appl_id := to_number(x_level_value_app_id);
         --
         -- level_value2 was added for the Server/Resp Hierarchy.
         -- The subscription that executes the FND_PROFILE.bumpCacheVersion_RF
         -- rule function uses the level_id.  For this subscription, the
         -- level_value2 value is irrelevant.  However, it may become relevant
         -- to other subscriptions subscribing to the
         -- oracle.apps.fnd.profile.value.update event.  At this time, the
         -- level_value2 value will be stored but not passed into the
         -- event_key.
         --
         --Added for server/resp hierarchy
         level_value2 := to_number(x_level_value2);
      ELSE
         RETURN;
      END IF;

      IF (level_id = 10007) THEN
         -- Event Key has level_value2
         event_key := level_id || ':' || level_value || ':' ||
                      level_value_appl_id || ':' || level_value2 || ':' || NAME;
      ELSE
         -- Original event_key format
         event_key := level_id || ':' || level_value || ':' ||
                      level_value_appl_id || ':' || NAME;
      END IF;

      --
      -- Modified this direct call to wf_event.raise to use the
      -- fnd_wf_engine.default_event_raise wrapper API
      --
      -- wf_event.raise(p_event_name=>'oracle.apps.fnd.profile.value.update',
      -- p_event_key=>event_key);
      --

      fnd_wf_engine.default_event_raise(p_event_name => 'oracle.apps.fnd.profile.value.update',
                                        p_event_key  => event_key);

   END invalidate_cache;

   /*
   ** SAVE_USER - Sets the value of a profile option permanently
   **             to the database, at the user level for the current user.
   **             Also saves in the profile cache for this database session.
   **             Note that this will not save in the profile caches
   **             for any other database sessions that may be up, so those
   **             could potentially be out of sync. This routine will not
   **             actually commit the changes; the caller must commit.
   **
   **  returns: TRUE if successful, FALSE if failure.
   **
   */
   FUNCTION save_user
   (
      x_name  IN VARCHAR2, /* Profile name you are setting */
      x_value IN VARCHAR2 /* Profile value you are setting */
   ) RETURN BOOLEAN IS

      RESULT BOOLEAN;

   BEGIN
      RESULT := SAVE(x_name, x_value, 'USER', profiles_user_id);
      RETURN RESULT;
   END save_user;

   /*
   ** SAVE - sets the value of a profile option permanently
   **        to the database, at any level.  This routine can be used
   **        at runtime or during patching.  This routine will not
   **        actually commit the changes; the caller must commit.
   **
   **        ('SITE', 'APPL', 'RESP', 'USER', 'SERVER', 'ORG', or 'SERVRESP').
   **
   **        Examples of use:
   **        FND_PROFILE.SAVE('P_NAME', 'P_VAL', 'SITE');
   **        FND_PROFILE.SAVE('P_NAME', 'P_VAL', 'APPL', 800);
   **        FND_PROFILE.SAVE('P_NAME', 'P_VAL', 'RESP', 345234, 800);
   **        FND_PROFILE.SAVE('P_NAME', 'P_VAL', 'USER', 123321);
   **        FND_PROFILE.SAVE('P_NAME', 'P_VAL', 'SERVER', 25);
   **        FND_PROFILE.SAVE('P_NAME', 'P_VAL', 'ORG', 204);
   **        FND_PROFILE.SAVE('P_NAME', 'P_VAL', 'SERVRESP', 345234, 800, 25);
   **        FND_PROFILE.SAVE('P_NAME', 'P_VAL', 'SERVRESP', 345234, 800, -1);
   **        FND_PROFILE.SAVE('P_NAME', 'P_VAL', 'SERVRESP', -1, -1, 25);
   **
   **  returns: TRUE if successful, FALSE if failure.
   */
   FUNCTION SAVE(x_name IN VARCHAR2,
                 -- Profile name you are setting
                 x_value IN VARCHAR2,
                 -- Profile value you are setting
                 x_level_name IN VARCHAR2,
                 -- Level that you're setting at: 'SITE','APPL','RESP','USER', etc.
                 x_level_value IN VARCHAR2 DEFAULT NULL,
                 -- Level value that you are setting at, e.g. user id for 'USER' level.
                 -- X_LEVEL_VALUE is not used at site level.
                 x_level_value_app_id IN VARCHAR2 DEFAULT NULL,
                 -- Used for 'RESP' and 'SERVRESP' level; Resp Application_Id.
                 x_level_value2 IN VARCHAR2 DEFAULT NULL
                 -- 2nd Level value that you are setting at.  This is for the
                 -- 'SERVRESP' hierarchy.
                 ) RETURN BOOLEAN IS

      x_level_id             NUMBER;
      x_level_value_actual   NUMBER;
      x_last_updated_by      NUMBER;
      x_last_update_login    NUMBER;
      x_last_update_date     DATE;
      x_application_id       NUMBER := NULL;
      x_profile_option_id    NUMBER := NULL;
      x_user_name            VARCHAR2(100); -- Bug 3203225
      x_level_value2_actual  NUMBER; -- Added for Server/Resp Hierarchy
      l_profile_option_value VARCHAR2(240); -- Bug 3958546
      l_defined              BOOLEAN; -- Bug 3958546

      x_user_changeable_flag         VARCHAR2(1);
      x_user_visible_flag            VARCHAR2(1);
      x_site_enabled_flag            VARCHAR2(1);
      x_site_update_allowed_flag     VARCHAR2(1);
      x_app_enabled_flag             VARCHAR2(1);
      x_app_update_allowed_flag      VARCHAR2(1);
      x_resp_enabled_flag            VARCHAR2(1);
      x_resp_update_allowed_flag     VARCHAR2(1);
      x_user_enabled_flag            VARCHAR2(1);
      x_user_update_allowed_flag     VARCHAR2(1);
      x_hierarchy_type               VARCHAR2(8);
      x_server_enabled_flag          VARCHAR2(1);
      x_org_enabled_flag             VARCHAR2(1);
      x_server_update_allowed_flag   VARCHAR2(1);
      x_org_update_allowed_flag      VARCHAR2(1);
      x_serverresp_enabled_flag      VARCHAR2(1);
      x_servresp_update_allowed_flag VARCHAR2(1);

      /* Bug 5603664: APPSPERF:FND:OPTIMIZE FND_PROFILE.VALUE */
      x_name_upper VARCHAR2(80) := upper(x_name);

      -- This cursor retrieves the profile option definition and uses it for
      -- validation to ensure that values are properly saved in the applicable
      -- levels only. That is, if an attempt to save a value in a non-applicable
      -- level is made, it should not be allowed. This cursor was already making
      -- a db trip to get the application_id and profile_option_id, given a
      -- profile option name. So, adding the other columns should not affect
      -- performance.
      CURSOR c1 IS
         SELECT application_id,
                profile_option_id,
                user_changeable_flag,
                user_visible_flag,
                site_enabled_flag,
                site_update_allowed_flag,
                app_enabled_flag,
                app_update_allowed_flag,
                resp_enabled_flag,
                resp_update_allowed_flag,
                user_enabled_flag,
                user_update_allowed_flag,
                hierarchy_type,
                server_enabled_flag,
                org_enabled_flag,
                server_update_allowed_flag,
                org_update_allowed_flag,
                serverresp_enabled_flag,
                serverresp_update_allowed_flag
           FROM fnd_profile_options po
          WHERE po.profile_option_name = x_name_upper

               /* Bug 5591340: FND_PROFILE.SAVE SHOULD NOT UPDATE VALUES FOR END_DATED
               ** PROFILE OPTIONS
               ** Added these date-sensitive conditions to prevent processing of
               ** end-dated profile options
               */
            AND po.start_date_active <= SYSDATE
            AND nvl(po.end_date_active, SYSDATE) >= SYSDATE;

      hashvalue BINARY_INTEGER;

   BEGIN

      IF corelog_is_enabled THEN
         fnd_core_log.write_profile_save(x_name_upper,
                                         nvl(x_value, 'NOVAL') || ':ENTER',
                                         x_level_name,
                                         x_level_value,
                                         x_level_value_app_id,
                                         x_level_value2);
      END IF;

      -- If profile option value being set is > 240 characters, then place the
      -- message FND_PROFILE_OPTION_VAL_TOO_LRG into the error stack and
      -- return FALSE.
      --
      -- The lengthb() function replaced the length() function to handle
      -- multibyte characters appropriately.
      IF lengthb(x_value) > 240 THEN
         fnd_message.set_name('FND', 'FND_PROFILE_OPTION_VAL_TOO_LRG');
         fnd_message.set_token('PROFILE_OPTION_NAME', x_name);
         fnd_message.set_token('PROFILE_OPTION_VALUE', x_value);
         RETURN FALSE;
      END IF;

      -- Get the profile definition for this Profile Name
      OPEN c1;
      FETCH c1
         INTO x_application_id,
              x_profile_option_id,
              x_user_changeable_flag,
              x_user_visible_flag,
              x_site_enabled_flag,
              x_site_update_allowed_flag,
              x_app_enabled_flag,
              x_app_update_allowed_flag,
              x_resp_enabled_flag,
              x_resp_update_allowed_flag,
              x_user_enabled_flag,
              x_user_update_allowed_flag,
              x_hierarchy_type,
              x_server_enabled_flag,
              x_org_enabled_flag,
              x_server_update_allowed_flag,
              x_org_update_allowed_flag,
              x_serverresp_enabled_flag,
              x_servresp_update_allowed_flag;
      IF (c1%NOTFOUND) THEN
         RETURN FALSE;
      END IF;
      CLOSE c1;

      -- The LEVEL_VALUE_APPLICATION_ID applies to the Resp and Server/Resp
      -- levels only.
      IF (x_level_value_app_id IS NOT NULL AND x_level_name <> 'RESP' AND
         x_level_name <> 'SERVRESP') THEN
         RETURN FALSE;
      END IF;

      -- The LEVEL_VALUE can only be null for SITE level.
      IF (x_level_value IS NULL) THEN
         x_level_value_actual := 0;
         IF (x_level_name <> 'SITE') THEN
            RETURN FALSE; -- Only allow X_LEVEL_VALUE NULL at SITE level
         END IF;

         -- The LEVEL_VALUE2 is required for SERVRESP level, -1 should be passed
         -- as a default.
      ELSIF ((x_level_name = 'SERVRESP') AND (x_level_value2 IS NULL)) THEN
         -- 'SERVRESP' requires a value for X_LEVEL_VALUE2 to save
         -- the profile option value properly.
         RETURN FALSE;
      ELSE
         x_level_value_actual := x_level_value;
         IF (x_level_name = 'SERVRESP')
            AND (x_level_value2 IS NOT NULL) THEN
            x_level_value2_actual := x_level_value2;
         END IF;
      END IF;

      /* Bug 5603664: APPSPERF:FND:OPTIMIZE FND_PROFILE.VALUE
      ** Generate hashValue and pass it on to FIND and PUT calls.
      */
      hashvalue := dbms_utility.get_hash_value(x_name_upper, 1, table_size);

      IF (x_level_name = 'SITE')
         AND (x_site_enabled_flag = 'Y') THEN

         x_level_id := 10001;

         IF ((x_level_id = 10001) AND (x_level_value_actual <> 0)) THEN
            RETURN FALSE; -- the only site-level allowed is zero.
         END IF;

         IF corelog_is_enabled THEN
            fnd_core_log.put_line(x_name_upper, 'GSD call FP.S, SL');
         END IF;

         /* Bug 3958546: FND_PROFILE.SAVE SHOULD NOT RAISE INVALIDATION EVENT
         ** IF NO CHANGE IS MADE
         */
         get_specific_db(name_z             => x_name_upper,
                         val_z              => l_profile_option_value,
                         defined_z          => l_defined,
                         level_id_z         => x_level_id,
                         profile_hash_value => hashvalue);

      ELSIF (x_level_name = 'APPL')
            AND (x_hierarchy_type = 'SECURITY')
            AND (x_app_enabled_flag = 'Y') THEN

         x_level_id := 10002;

         IF corelog_is_enabled THEN
            fnd_core_log.put_line(x_name_upper, 'GSD call FP.S, AL');
         END IF;

         /* Bug 3958546: FND_PROFILE.SAVE SHOULD NOT RAISE INVALIDATION EVENT
         ** IF NO CHANGE IS MADE
         */
         get_specific_db(name_z             => x_name_upper,
                         application_id_z   => x_level_value,
                         val_z              => l_profile_option_value,
                         defined_z          => l_defined,
                         level_id_z         => x_level_id,
                         profile_hash_value => hashvalue);

      ELSIF (x_level_name = 'RESP')
            AND (x_hierarchy_type = 'SECURITY')
            AND (x_resp_enabled_flag = 'Y') THEN

         x_level_id := 10003;

         IF corelog_is_enabled THEN
            fnd_core_log.put_line(x_name_upper, 'GSD call FP.S, RL');
         END IF;

         /* Bug 3958546: FND_PROFILE.SAVE SHOULD NOT RAISE INVALIDATION EVENT
         ** IF NO CHANGE IS MADE
         */
         get_specific_db(name_z              => x_name_upper,
                         responsibility_id_z => x_level_value,
                         application_id_z    => x_level_value_app_id,
                         val_z               => l_profile_option_value,
                         defined_z           => l_defined,
                         level_id_z          => x_level_id,
                         profile_hash_value  => hashvalue);

      ELSIF (x_level_name = 'USER')
            AND (x_user_enabled_flag = 'Y') THEN

         x_level_id := 10004;

         IF corelog_is_enabled THEN
            fnd_core_log.put_line(x_name_upper, 'GSD call FP.S, UL');
         END IF;

         /* Bug 3958546: FND_PROFILE.SAVE SHOULD NOT RAISE INVALIDATION EVENT
         ** IF NO CHANGE IS MADE
         */
         get_specific_db(name_z             => x_name_upper,
                         user_id_z          => x_level_value,
                         val_z              => l_profile_option_value,
                         defined_z          => l_defined,
                         level_id_z         => x_level_id,
                         profile_hash_value => hashvalue);

      ELSIF (x_level_name = 'SERVER')
            AND (x_hierarchy_type = 'SERVER')
            AND (x_server_enabled_flag = 'Y') THEN

         x_level_id := 10005;

         IF corelog_is_enabled THEN
            fnd_core_log.put_line(x_name_upper, 'GSD call FP.S, SRVL');
         END IF;

         /* Bug 3958546: FND_PROFILE.SAVE SHOULD NOT RAISE INVALIDATION EVENT
         ** IF NO CHANGE IS MADE
         */
         get_specific_db(name_z             => x_name_upper,
                         val_z              => l_profile_option_value,
                         defined_z          => l_defined,
                         server_id_z        => x_level_value,
                         level_id_z         => x_level_id,
                         profile_hash_value => hashvalue);

      ELSIF (x_level_name = 'ORG')
            AND (x_hierarchy_type = 'ORG')
            AND (x_org_enabled_flag = 'Y') THEN

         x_level_id := 10006;

         IF corelog_is_enabled THEN
            fnd_core_log.put_line(x_name_upper, 'GSD call FP.S, OL');
         END IF;

         /* Bug 3958546: FND_PROFILE.SAVE SHOULD NOT RAISE INVALIDATION EVENT
         ** IF NO CHANGE IS MADE
         */
         get_specific_db(name_z             => x_name_upper,
                         val_z              => l_profile_option_value,
                         defined_z          => l_defined,
                         org_id_z           => x_level_value,
                         level_id_z         => x_level_id,
                         profile_hash_value => hashvalue);

      ELSIF (x_level_name = 'SERVRESP')
            AND (x_hierarchy_type = 'SERVRESP')
            AND (x_serverresp_enabled_flag = 'Y') THEN
         --Added for Server/Resp Level

         x_level_id := 10007;

         IF corelog_is_enabled THEN
            fnd_core_log.put_line(x_name_upper,
                                  'GSDW call FP.S, ServRespL');
         END IF;

         /*
         ** Bug 4025399 :3958546:SERVRESP:FND_PROFILE.SAVE RETURNS TRUE BUT
         ** DOES NOT SAVE VALUE
         **
         ** Due to the unique nature of the SERVRESP hierarchy, GET_SPECIFIC_DB
         ** cannot be used to check the existing value of the profile option
         ** being evaluated since GET_SPECIFIC_DB looks at
         ** (RESP+SERVER) > (RESP+-1) > (-1+SERVER) for a value.  When saving
         ** values, the context passed in should be the only context evaluated.
         ** GET_SPECIFIC_DB_WNPS will be used instead.
         **
         ** GET_SPECIFIC_DB(
         **    name_z => X_NAME,
         **    responsibility_id_z => X_LEVEL_VALUE,
         **    application_id_z => X_LEVEL_VALUE_APP_ID,
         **    val_z => l_profile_option_value,
         **    defined_z => l_defined,
         **    server_id_z => X_LEVEL_VALUE2,
         **    level_id_z => x_level_id);
         */

         /* Bug 3958546: FND_PROFILE.SAVE SHOULD NOT RAISE INVALIDATION EVENT
         ** IF NO CHANGE IS MADE
         */
         get_specific_db_wnps(name_z              => x_name_upper,
                              responsibility_id_z => x_level_value,
                              application_id_z    => x_level_value_app_id,
                              val_z               => l_profile_option_value,
                              defined_z           => l_defined,
                              server_id_z         => x_level_value2,
                              level_id_z          => x_level_id);

      ELSE
         IF corelog_is_enabled THEN
            fnd_core_log.put_line('FP.S:' || x_level_name ||
                                  ' level does not apply to profile option ' ||
                                  x_name_upper);
         END IF;
         RETURN FALSE;
      END IF;

      -- If the profile option value being saved is the same as the value
      -- obtained from GET_SPECIFIC_DB, then there is no need to go further.
      -- Just return TRUE;
      IF ((l_profile_option_value = x_value) OR
         (l_profile_option_value IS NULL) AND (x_value IS NULL)) THEN
         IF corelog_is_enabled THEN
            fnd_core_log.write_profile_save(x_name,
                                            nvl(x_value, 'NOVAL') ||
                                            ':EXIT',
                                            x_level_name,
                                            x_level_value,
                                            x_level_value_app_id,
                                            x_level_value2);
         END IF;
         RETURN TRUE;
      END IF;

      -- If profile option value passed in is NULL, then clear accordingly.
      IF (x_value IS NULL) THEN
         -- If SERVRESP level, then take LEVEL_VALUE2 into consideration.
         IF (x_level_id = 10007) THEN
            -- D E L E T E --
            fnd_profile_option_values_pkg.delete_row(x_application_id,
                                                     x_profile_option_id,
                                                     x_level_id,
                                                     x_level_value_actual,
                                                     x_level_value_app_id,
                                                     x_level_value2_actual);
         ELSE
            -- D E L E T E --
            fnd_profile_option_values_pkg.delete_row(x_application_id,
                                                     x_profile_option_id,
                                                     x_level_id,
                                                     x_level_value_actual,
                                                     x_level_value_app_id);
         END IF;

      ELSE

         x_last_update_date := SYSDATE;
         x_last_updated_by  := fnd_profile.value('USER_ID');
         IF x_last_updated_by IS NULL THEN
            x_last_updated_by := -1;
         END IF;
         x_last_update_login := fnd_profile.value('LOGIN_ID');
         IF x_last_update_login IS NULL THEN
            x_last_update_login := -1;
         END IF;

         -- If profile option value passed in NOT NULL, then update
         -- accordingly. If SERVRESP level, then take LEVEL_VALUE2 into
         -- consideration.
         IF (x_level_id = 10007) THEN
            -- U P D A T E --
            fnd_profile_option_values_pkg.update_row(x_application_id,
                                                     x_profile_option_id,
                                                     x_level_id,
                                                     x_level_value_actual,
                                                     x_level_value_app_id,
                                                     x_level_value2_actual,
                                                     x_value,
                                                     x_last_update_date,
                                                     x_last_updated_by,
                                                     x_last_update_login);
         ELSE
            -- U P D A T E --
            fnd_profile_option_values_pkg.update_row(x_application_id,
                                                     x_profile_option_id,
                                                     x_level_id,
                                                     x_level_value_actual,
                                                     x_level_value_app_id,
                                                     x_value,
                                                     x_last_update_date,
                                                     x_last_updated_by,
                                                     x_last_update_login);
         END IF;

      END IF;

      /* Bug 5477866:INCONSISTENT VALUES RETURNED BY FND_PROFILE.VALUE_SPECIFIC
      ** This block of code was separated from the update/insert code block of
      ** SAVE() so that deleted values are properly reflected in level caches
      ** just like non-NULL values are cached when saved.
      ** Previously, only non-NULL values were being cached in level caches
      ** when a new non-NULL value was saved, such that when a value is
      ** deleted, the get apis would still return the previous cached value.
      */
      IF (x_level_id = 10007) THEN
         invalidate_cache(x_level_name,
                          x_level_value,
                          x_level_value_app_id,
                          x_name_upper,
                          x_level_value2);
      ELSE
         invalidate_cache(x_level_name,
                          x_level_value,
                          x_level_value_app_id,
                          x_name_upper);
      END IF;

      -- Cache the value in user-level table.
      IF (x_level_id = 10004 AND
         profiles_user_id = nvl(x_level_value, profiles_user_id)) THEN
         IF corelog_is_enabled THEN
            fnd_core_log.put_line(x_name_upper,
                                  'UL Val cached in USER_TABS');
         END IF;
         put(x_name_upper,
             nvl(x_value, fnd_undefined_value),
             user_name_tab,
             user_val_tab,
             hashvalue);
      END IF;

      -- Cache the value in resp-level table.
      IF (x_level_id = 10003 AND
         profiles_resp_id = nvl(x_level_value, profiles_resp_id) AND
         profiles_appl_id = nvl(x_level_value_app_id, profiles_appl_id)) THEN
         IF corelog_is_enabled THEN
            fnd_core_log.put_line(x_name_upper,
                                  'RL Val cached in RESP_TABS');
         END IF;
         put(x_name_upper,
             nvl(x_value, fnd_undefined_value),
             resp_name_tab,
             resp_val_tab,
             hashvalue);
      END IF;

      -- Cache the value in appl-level table.
      IF (x_level_id = 10002 AND
         profiles_appl_id = nvl(x_level_value, profiles_appl_id)) THEN
         IF corelog_is_enabled THEN
            fnd_core_log.put_line(x_name_upper,
                                  'AL Val cached in APPL_TABS');
         END IF;
         put(x_name_upper,
             nvl(x_value, fnd_undefined_value),
             appl_name_tab,
             appl_val_tab,
             hashvalue);
      END IF;

      -- Cache the value in server-level table.
      IF (x_level_id = 10005 AND
         profiles_server_id = nvl(x_level_value, profiles_server_id)) THEN
         IF corelog_is_enabled THEN
            fnd_core_log.put_line(x_name_upper,
                                  'SRVL Val cached in SERVER_TABS');
         END IF;
         put(x_name_upper,
             nvl(x_value, fnd_undefined_value),
             server_name_tab,
             server_val_tab,
             hashvalue);
      END IF;

      -- Cache the value in org-level table.
      IF (x_level_id = 10006) THEN
         IF (profiles_org_id = nvl(x_level_value, profiles_org_id)) THEN
            IF corelog_is_enabled THEN
               fnd_core_log.put_line(x_name_upper,
                                     'OL Val cached in ORG_TABS');
            END IF;
            put(x_name_upper,
                nvl(x_value, fnd_undefined_value),
                org_name_tab,
                org_val_tab,
                hashvalue);
         END IF;
      END IF;

      -- Cache the value in servresp-level table.
      IF (x_level_id = 10007 AND
         profiles_resp_id = nvl(x_level_value, profiles_resp_id) AND
         profiles_server_id = nvl(x_level_value2, profiles_server_id)) THEN
         IF corelog_is_enabled THEN
            fnd_core_log.put_line(x_name_upper,
                                  'ServRespL Val cached in SERVRESP_TABS');
         END IF;
         put(x_name_upper,
             nvl(x_value, fnd_undefined_value),
             servresp_name_tab,
             servresp_val_tab,
             hashvalue);
      END IF;

      -- Cache the value in site-level table.
      IF (x_level_id = 10001) THEN
         IF corelog_is_enabled THEN
            fnd_core_log.put_line(x_name_upper,
                                  'SL Val cached in SITE_TABS');
         END IF;
         put(x_name_upper,
             nvl(x_value, fnd_undefined_value),
             site_name_tab,
             site_val_tab,
             hashvalue);
      END IF;

      /* Bug 3203225: PREFERENCES NOT UPDATED ON FLY IN WF_ROLES VIEW
      ** needs to call FND_USER_PKG.User_Synch() whenever an update to
      ** ICX_LANGUAGE or ICX_TERRITORY is updated at the user level.
      */
      IF ((x_name_upper = 'ICX_LANGUAGE') OR
         (x_name_upper = 'ICX_TERRITORY')) THEN
         IF ((x_level_name = 'USER') AND (x_level_value IS NOT NULL)) THEN
            SELECT user_name
              INTO x_user_name
              FROM fnd_user
             WHERE user_id = to_number(x_level_value);

            fnd_user_pkg.user_synch(x_user_name);
         END IF;
      END IF;

      -- Log API exit
      IF corelog_is_enabled THEN
         fnd_core_log.write_profile_save(x_name,
                                         x_value || ':EXIT',
                                         x_level_name,
                                         x_level_value,
                                         x_level_value_app_id,
                                         x_level_value2);
      END IF;

      RETURN TRUE;

   END SAVE;

   /*
   ** GET_SPECIFIC - Get a profile value for a specific user/resp/appl combo.
   **                Default for user/resp/appl is the current login.
   */
   PROCEDURE get_specific
   (
      name_z              IN VARCHAR2,
      user_id_z           IN NUMBER DEFAULT NULL,
      responsibility_id_z IN NUMBER DEFAULT NULL,
      application_id_z    IN NUMBER DEFAULT NULL,
      val_z               OUT NOCOPY VARCHAR2,
      defined_z           OUT NOCOPY BOOLEAN,
      org_id_z            IN NUMBER DEFAULT NULL,
      server_id_z         IN NUMBER DEFAULT NULL
   ) IS

      /* Bug 5603664: APPSPERF:FND:OPTIMIZE FND_PROFILE.VALUE */
      name_upper VARCHAR2(80) := upper(name_z);

   BEGIN

      -- Log API entry
      IF corelog_is_enabled THEN
         corelog(name_upper,
                 nvl(val_z, 'NOVAL'),
                 'Enter FP.GS',
                 user_id_z,
                 responsibility_id_z,
                 application_id_z,
                 org_id_z,
                 server_id_z);
      END IF;

      /* Bug 5477866: INCONSISTENT VALUES RETURNED BY
      ** FND_PROFILE.VALUE_SPECIFIC
      ** Check if fnd_cache_versions was updated. This refreshes level caches
      ** in order for value_specific to return accurate values should a new
      ** profile value be saved in another session. This will introduce a
      ** performance degradation which has been deemed necessary for
      ** value_specific return values.
      */
      check_cache_versions();

      /* Bug 4438015: APPSPERF: TOO MANY EXECUTIONS OF CURSOR PROFILE_INFO
      ** If the context passed in is exactly the same as the current context,
      ** then redirect to GET instead.
      */
      IF (user_id_z = profiles_user_id)
         AND (responsibility_id_z = profiles_resp_id)
         AND (application_id_z = profiles_appl_id)
         AND (org_id_z = profiles_org_id)
         AND (server_id_z = profiles_server_id) THEN

         IF corelog_is_enabled THEN
            corelog(name_upper,
                    nvl(val_z, 'NOVAL'),
                    'No context change in FP.GS, Redirect to FP.G');
         END IF;

         get(name_upper, val_z);

         IF (val_z IS NOT NULL)
            AND (val_z <> fnd_undefined_value) THEN
            defined_z := TRUE;
         END IF;
         -- If NULLs were passed for the context levels, default to current
         -- context. This would normally happen when value_specific was called as
         -- such:
         --    fnd_profile.value_specific('PROFILE_OPTION_NAME');
         -- Note that there was no context passed in. Defaulting to current
         -- context effectively satisfies the IF condition above. Hence, redirect
         -- to GET also.
      ELSIF (user_id_z IS NULL)
            AND (responsibility_id_z IS NULL)
            AND (application_id_z IS NULL)
            AND (org_id_z IS NULL)
            AND (server_id_z IS NULL) THEN

         IF corelog_is_enabled THEN
            corelog(name_upper,
                    nvl(val_z, 'NOVAL'),
                    'No context passed in FP.GS, Redirect to FP.G');
         END IF;

         get(name_upper, val_z);

         IF (val_z IS NOT NULL)
            AND (val_z <> fnd_undefined_value) THEN
            defined_z := TRUE;
         END IF;
      ELSE
         -- If a specific level context is passed, then proceed the usual way.
         -- This will likely hit get_specific_db_wnps and make a database
         -- fetch.
         get_specific_wnps(name_upper,
                           user_id_z,
                           responsibility_id_z,
                           application_id_z,
                           val_z,
                           defined_z,
                           org_id_z,
                           server_id_z);
      END IF;

      -- Log API exit
      IF corelog_is_enabled THEN
         corelog(name_upper,
                 nvl(val_z, 'NOVAL'),
                 'Exit FP.GS',
                 user_id_z,
                 responsibility_id_z,
                 application_id_z,
                 org_id_z,
                 server_id_z);
      END IF;

   END get_specific;

   /*
   ** VALUE_SPECIFIC - Get profile value for a specific context
   **
   */
   FUNCTION value_specific
   (
      NAME              IN VARCHAR2,
      user_id           IN NUMBER DEFAULT NULL,
      responsibility_id IN NUMBER DEFAULT NULL,
      application_id    IN NUMBER DEFAULT NULL,
      org_id            IN NUMBER DEFAULT NULL,
      server_id         IN NUMBER DEFAULT NULL
   ) RETURN VARCHAR2 IS

      retvalue VARCHAR2(255);
      defined  BOOLEAN;

   BEGIN

      -- Log API entry
      IF corelog_is_enabled THEN
         corelog(NAME,
                 nvl(retvalue, 'NOVAL'),
                 'Enter FP.VS',
                 user_id,
                 responsibility_id,
                 application_id,
                 org_id,
                 server_id);
      END IF;

      -- Use GET_SPECIFIC() to obtain value
      get_specific(NAME,
                   user_id,
                   responsibility_id,
                   application_id,
                   retvalue,
                   defined,
                   org_id,
                   server_id);

      -- Log API exit
      IF corelog_is_enabled THEN
         corelog(NAME,
                 nvl(retvalue, 'NOVAL'),
                 'Exit FP.VS',
                 user_id,
                 responsibility_id,
                 application_id,
                 org_id,
                 server_id);
      END IF;

      IF (defined) THEN
         RETURN(retvalue);
      ELSE
         RETURN(NULL);
      END IF;

   END value_specific;

   /*
   ** VALUE - get profile value, return as function value
   */
   FUNCTION VALUE(NAME IN VARCHAR2) RETURN VARCHAR2 IS
      retvalue VARCHAR2(255);
   BEGIN

      -- Log API entry
      IF corelog_is_enabled THEN
         corelog(NAME, nvl(retvalue, 'NOVAL'), 'Enter FP.V');
      END IF;

      -- Use GET() to obtain value
      get(NAME, retvalue);

      -- Log API exit
      IF corelog_is_enabled THEN
         corelog(NAME, nvl(retvalue, 'NOVAL'), 'Exit FP.V');
      END IF;

      RETURN(retvalue);
   END VALUE;

   /*
   ** VALUE_WNPS
   **  returns the value of a profile option without caching it.
   **
   **  The main usage for this routine would be in a SELECT statement where
   **  VALUE() is not allowed since it writes package state.
   **
   **  This routine does the same thing as VALUE(); it returns a profile value
   **  from the profile cache, or from the database if it isn't already in the
   **  profile cache already.  The only difference between this and VALUE() is
   **  that this will not put the value into the cache if it is not already
   **  there, so repeated calls to this can be slower because it will have to
   **  hit the database each time for the profile value.
   **
   **  In most cases, however, you can and should use VALUE() instead of
   **  VALUE_WNPS(), because VALUE() will give better performance.
   */
   FUNCTION value_wnps(NAME IN VARCHAR2) RETURN VARCHAR2 IS
      table_index BINARY_INTEGER;
      defined     BOOLEAN;
      outval      VARCHAR2(255);
      name_upper  VARCHAR2(80) := upper(NAME);
   BEGIN

      -- Search for the profile option
      table_index := find(name_upper);

      IF table_index < table_size THEN
         outval := val_tab(table_index);
      ELSE
         -- Can't find the value in the table; look in the database
         get_specific_wnps(name_upper,
                           profiles_user_id,
                           profiles_resp_id,
                           profiles_appl_id,
                           outval,
                           defined,
                           profiles_org_id,
                           profiles_server_id);
         IF (NOT defined) THEN
            outval := NULL;
         END IF;
      END IF;

      RETURN outval;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END value_wnps;

   /*
   ** PUTMULTIPLE - puts multiple option pairs in the table
   **
   ** AOL INTERNAL USE ONLY
   **
   ** The name and val VARCHAR2s are of max size 2000, and hold the
   ** concatenations of the strings for each individual pair, with null
   ** terminators (CHR(0)) to seperate the values.  The number of pairs
   ** is passed in numval.  This setup is to avoid the overhead of
   ** calling the put routine multiple times.
   */
   PROCEDURE putmultiple
   (
      names IN VARCHAR2,
      vals  IN VARCHAR2,
      num   IN NUMBER
   ) IS
      pairnum   NUMBER;
      nstartloc NUMBER;
      nendloc   NUMBER;
      vstartloc NUMBER;
      vendloc   NUMBER;
      onename   VARCHAR2(81);
      oneval    VARCHAR2(256);

   BEGIN

      nstartloc := 1;
      vstartloc := 1;

      FOR pairnum IN 1 .. num LOOP
         nendloc   := instr(names, chr(0), nstartloc);
         onename   := substr(names, nstartloc, nendloc - nstartloc);
         nstartloc := nendloc + 1;

         vendloc   := instr(vals, chr(0), vstartloc);
         oneval    := substr(vals, vstartloc, vendloc - vstartloc);
         vstartloc := vendloc + 1;

         put(onename, oneval);
      END LOOP;

   EXCEPTION
      WHEN OTHERS THEN
         NULL;
   END putmultiple;

   /*
   ** FOR AOL INTERNAL USE ONLY - DO NOT CALL DIRECTLY,
   ** CALL VIA FND_GLOBAL.INITIALIZE('ORG_ID',org_id)
   ** FND_PROFILE.INITIALIZE also calls this API to initialize the org context.
   **
   ** initialize_org_context - Initializes the org context used by profiles.
   ** The org-level cache is cleared of all database (non-put) options first.
   ** Sets PROFILES_ORG_ID to the current value fnd_global.org_id
   */
   PROCEDURE initialize_org_context IS
   BEGIN
      -- Clear org-level cache, if applicable
      IF ((profiles_org_id IS NULL) OR
         (profiles_org_id <> fnd_global.org_id)) THEN
         org_name_tab.delete();
         org_val_tab.delete();
      END IF;

      -- Set profiles org context variable to fnd_global.org_id
      profiles_org_id := fnd_global.org_id;

      IF release_version < 12 THEN
         -- For releases less than R12, the ORG_ID profile is the source of the
         -- org context. FND_GLOBAL.ORG_ID = FND_PROFILE.VALUE('ORG_ID')
         put('ORG_ID', to_char(profiles_org_id));
      ELSE
         -- Bug 7423364: For R12, the profile option ORG_ID is not always an
         -- equivalent of FND_GLOBAL.ORG_ID, which is the org context. The
         -- global variable PROFILES_ORG_ID is the org context used for
         -- evaluating org-level profile option values and should be equal to
         -- FND_GLOBAL.ORG_ID. A value fetch on the profile option ORG_ID
         -- should return the profile option table value, not the org context.
         -- This behavior was confirmed with JMARY and SHNARAYA of the MO Team.
         -- CURRENT_ORG_CONTEXT is being introduced so that profiles code can
         -- provide similar functionality such that FND_GLOBAL.ORG_ID will be
         -- equivalent to FND_PROFILE.VALUE('CURRENT_ORG_CONTEXT').
         -- FND_PROFILE.VALUE('ORG_ID') will return a value obtained in the
         -- FND_PROFILE_OPTION_VALUES table.
         put('CURRENT_ORG_CONTEXT', to_char(profiles_org_id));
         -- Bug 16327915, ORG_ID is stored in Public PUT cache by Forms user exit.
         -- purge previous context cached value of ORG_ID
         -- so that the value for current context can be found.
         put('ORG_ID', fnd_delete_value);
      END IF;

      put('ORG_NAME', fnd_global.org_name);

   END initialize_org_context;

   /*
   ** FOR AOL INTERNAL USE ONLY - DO NOT CALL DIRECTLY,
   ** CALL VIA FND_GLOBAL.APPS_INITIALIZE
   ** initialize - Initialize the internal profile information
   ** The cache is cleared of all database (non-put) options first.
   ** Initializes the profiles for the level context information.
   **
   */
   PROCEDURE initialize
   (
      user_id_z           IN NUMBER DEFAULT NULL,
      responsibility_id_z IN NUMBER DEFAULT NULL,
      application_id_z    IN NUMBER DEFAULT NULL,
      site_id_z           IN NUMBER DEFAULT NULL
   ) IS

      NAME          VARCHAR2(256);
      session_id    NUMBER;
      -- bug 16327915 remove unused variables

   BEGIN

      -- Clear old db entries
      session_id := icx_sec.g_session_id;

      -- Check cache versions
      check_cache_versions();

      -- Bug 12875860, We initialize the put cache clear flag here since it
      -- should only be tested by FND_GLOBAL after a call to INITIALIZE
      put_cache_is_clear := FALSE;

      --
      -- Clear the "put" cache when session_id changes.
      -- NOTE: This needs to stay even when other caches are not
      -- cleared on session change.  Puts are always only good for
      -- the current session.
      --
      -- The only real condition for a Public PUT Cache purge is that the
      -- current ICX session ID is different from the new ICX session ID
      -- returned by ICX_SEC.G_SESSION_ID, and that the current ICX session ID
      -- or the new ICX session ID is not DEFAULT_CONTEXT, i.e. -1.
      IF ((profiles_session_id IS NULL) OR (session_id IS NULL) OR
         ((profiles_session_id <> session_id) AND
         (profiles_session_id <> -1) AND (session_id <> -1))) THEN
         name_tab.delete();
         val_tab.delete();
         profile_option_exists := TRUE;
         -- mskees 9/1/2011 this is a little used flag for FND_GLOBAL
         inserted := 0; -- reset PUT count
         -- Bug 12875860 set flag for FND_GLOBAL
         put_cache_is_clear := TRUE;
         IF corelog_is_enabled THEN
            fnd_core_log.put_line('Generic PUT Cache purged');
         END IF;
      END IF;

      --
      -- Clear the individual caches whose levels have changed.
      --
      IF ((profiles_user_id IS NULL) OR (user_id_z IS NULL) OR
         (profiles_user_id <> user_id_z)) THEN
         user_name_tab.delete();
         user_val_tab.delete();
      END IF;

      IF ((profiles_resp_id IS NULL) OR (responsibility_id_z IS NULL) OR
         (profiles_resp_id <> responsibility_id_z)) THEN
         resp_name_tab.delete();
         resp_val_tab.delete();
         -- A change in responsibility affects the SERVRESP hierarchy and the cache
         -- should be emptied if the responsibility changes.
         servresp_name_tab.delete();
         servresp_val_tab.delete();
      END IF;

      IF ((profiles_appl_id IS NULL) OR (application_id_z IS NULL) OR
         (profiles_appl_id <> application_id_z)) THEN
         appl_name_tab.delete();
         appl_val_tab.delete();
         /* Bug 4738009: RESP SWITCH DOES NOT FLUSH RESP-LEVEL CACHE IF SAME
         ** RESP_ID BUT DIFF APPL_ID
         ** It is possible for responsibility_ids to be the same between
         ** applications.  So, if there is a switch in context between
         ** applications having the same responsibility_id, the resp-level
         ** and servresp-level cache is flushed.
         */
         IF (profiles_resp_id = responsibility_id_z) THEN
            resp_name_tab.delete();
            resp_val_tab.delete();
            servresp_name_tab.delete();
            servresp_val_tab.delete();
         END IF;
      END IF;

      IF ((profiles_server_id IS NULL) OR
         (profiles_server_id <> fnd_global.server_id)) THEN
         server_name_tab.delete();
         server_val_tab.delete();
         -- A change in server affects the SERVRESP hierarchy and the cache
         -- should be emptied if the server changes.
         servresp_name_tab.delete();
         servresp_val_tab.delete();
      END IF;

      profiles_user_id    := user_id_z;
      profiles_resp_id    := responsibility_id_z;
      profiles_appl_id    := application_id_z;
      profiles_server_id  := fnd_global.server_id;
      profiles_session_id := session_id;

      -- Set login appl/resp/user specific security profiles
      IF (user_id_z IS NOT NULL) THEN
         put('USER_ID', to_char(user_id_z));

         IF (user_id_z = fnd_global.user_id) THEN
            -- Use global to avoid select if current user
            NAME := fnd_global.user_name;
         ELSIF (user_id_z = -1) THEN
            NAME := 'DEFAULT_USER';
         ELSE
            BEGIN
               SELECT user_name
                 INTO NAME
                 FROM fnd_user
                WHERE user_id = user_id_z;
            EXCEPTION
               WHEN OTHERS THEN
                  NAME := '';
            END;
         END IF;
         put('USERNAME', NAME);
      END IF;

      -- For FND_PROFILE.INITIALIZE(), the CORELOG
      -- LOG_PROFNAME argument will be the code phase. LOG_PROFVAL will be
      -- user_name.
      IF corelog_is_enabled THEN
         corelog('PROFILE_INIT',
                 NAME,
                 'FP.I',
                 user_id_z,
                 responsibility_id_z,
                 application_id_z,
                 fnd_global.org_id,
                 fnd_global.server_id);
      END IF;

      IF ((responsibility_id_z IS NOT NULL) AND
         (application_id_z IS NOT NULL)) THEN
         put('RESP_ID', to_char(responsibility_id_z));
         put('RESP_APPL_ID', to_char(application_id_z));
         IF ((responsibility_id_z = fnd_global.resp_id) AND
            (application_id_z = fnd_global.resp_appl_id)) THEN
            -- Use global to avoid select if current resp
            NAME := fnd_global.resp_name;
         ELSIF ((responsibility_id_z = -1) AND (application_id_z = -1)) THEN
            NAME := 'DEFAULT_RESP';
         ELSE
            BEGIN
               SELECT responsibility_name
                 INTO NAME
                 FROM fnd_responsibility_vl
                WHERE responsibility_id = responsibility_id_z
                  AND application_id = application_id_z;
            EXCEPTION
               WHEN OTHERS THEN
                  NAME := '';
            END;
         END IF;
         put('RESP_NAME', NAME);
      END IF;

      -- Set the Server profile
      put('SERVER_ID', to_char(profiles_server_id));
      BEGIN
         SELECT node_name
           INTO NAME
           FROM fnd_nodes
          WHERE node_id = profiles_server_id;
      EXCEPTION
         WHEN OTHERS THEN
            NAME := '';
      END;
      put('SERVER_NAME', NAME);

      -- Finally, initialize the org context
      initialize_org_context;

   END initialize;

   /*
   ** GET_TABLE_VALUE - get the value of a profile option from the table
   */
   FUNCTION get_table_value(NAME IN VARCHAR2) RETURN VARCHAR2 IS
      table_index BINARY_INTEGER;
      retval      VARCHAR2(255);
      name_upper  VARCHAR2(80) := upper(NAME);
   BEGIN

      table_index := find(name_upper);
      IF table_index < table_size THEN
         retval := val_tab(table_index);
      ELSE
         retval := NULL;
      END IF;
      RETURN retval;

   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;

   END get_table_value;

   /*
   ** GET_ALL_TABLE_VALUES - get all the values from the table
   */
   FUNCTION get_all_table_values(delim IN VARCHAR2) RETURN VARCHAR2 IS
      table_index BINARY_INTEGER;
      retval      VARCHAR2(32767);
      val         VARCHAR2(1000);
   BEGIN
      IF (inserted = 0) THEN
         RETURN NULL;
      END IF;

      table_index := 1;
      retval      := 'PUT CACHE: ';



      WHILE (table_index < table_size) LOOP

         IF (name_tab.exists(table_index) AND
             (val_tab(table_index) IS NOT NULL)) THEN
            val := name_tab(table_index) || delim || val_tab(table_index) ||
                   delim;

            IF corelog_is_enabled THEN
               fnd_core_log.put_line('FP.GATV: ' ||val);
            END IF;
            IF length(val) + length(retval) > 32767 THEN
               RETURN retval;
            END IF;
            retval := retval || val;
         END IF;

         table_index := table_index + 1;

      END LOOP;

      RETURN retval;

   EXCEPTION
      WHEN OTHERS THEN
         -- add a corelog dump on exception
         IF corelog_is_enabled THEN
            fnd_core_log.put_line('GET_ALL_TABLE_VALUES raised exception. SQLCODE:' || SQLCODE);
            -- output exception to corelog
            fnd_core_log.put_line(dbms_utility.format_error_stack);
            -- output call stack to corelog
            fnd_core_log.put_line(dbms_utility.format_call_stack);
         END IF;
         RETURN NULL;

   END get_all_table_values;

   /*
   * bumpCacheVersion_RF
   *      The rule function for FND's subscription on the
   *      oracle.apps.fnd.profile.value.update event.  This function calls
   *      FND_CACHE_VERSION_PKG.bump_version to increase the version of the
   *      appropriate profile level cache.
   */
   FUNCTION bumpcacheversion_rf
   (
      p_subscription_guid IN RAW,
      p_event             IN OUT NOCOPY wf_event_t
   ) RETURN VARCHAR2 IS

      l_event_key  VARCHAR2(255);
      l_level_id   NUMBER;
      l_cache_name VARCHAR2(30);

   BEGIN
      -- First thing to do is to get the event key.  The event key holds the
      -- information that is required to determine which profile level cache
      -- needs a version bump.  The event key is passed in this format:
      --    level_id||':'||level_value||':'||level_value_appl_id||':'||name
      l_event_key := p_event.geteventkey();

      -- Since all this function does is call
      -- FND_CACHE_VERSION_PKG.bump_version, the only information required from
      -- the event key is the level_id. This will indicate the profile level
      -- cache to be bumped.
      l_level_id := to_number(substr(l_event_key,
                                     1,
                                     instr(l_event_key, ':') - 1));

      -- Using the level_id, determine the profile level cache name.
      IF (l_level_id = 10001) THEN
         l_cache_name := site_cache;
      ELSIF (l_level_id = 10002) THEN
         l_cache_name := appl_cache;
      ELSIF (l_level_id = 10003) THEN
         l_cache_name := resp_cache;
      ELSIF (l_level_id = 10004) THEN
         l_cache_name := user_cache;
      ELSIF (l_level_id = 10005) THEN
         l_cache_name := server_cache;
      ELSIF (l_level_id = 10006) THEN
         l_cache_name := org_cache;
      ELSIF (l_level_id = 10007) THEN
         l_cache_name := servresp_cache;
      ELSE
         -- The level_id obtained is not valid.
         RETURN 'ERROR';
      END IF;

      -- Bump cache version using the appropriate cache name
      fnd_cache_versions_pkg.bump_version(l_cache_name);
      RETURN 'SUCCESS';

   EXCEPTION
      WHEN OTHERS THEN
         wf_core.context('FND_PROFILE',
                         'bumpCacheVersion_RF',
                         p_event.geteventname(),
                         p_subscription_guid);
         wf_event.seterrorinfo(p_event, 'ERROR');
         RETURN 'ERROR';
   END;

   /*
   ** DELETE - deletes the value of a profile option permanently from the
   **          database, at any level.  This routine serves as a wrapper to
   **          the SAVE routine which means that this routine can be used at
   **          runtime or during patching.  Like the SAVE routine, this
   **          routine will not actually commit the changes; the caller must
   **          commit.  This API was added for enhancement request 4430579.
   **
   **        ('SITE', 'APPL', 'RESP', 'USER', 'SERVER', 'ORG', or 'SERVRESP').
   **
   **        Examples of use:
   **        FND_PROFILE.DELETE('P_NAME', 'SITE');
   **        FND_PROFILE.DELETE('P_NAME', 'APPL', 321532);
   **        FND_PROFILE.DELETE('P_NAME', 'RESP', 321532, 345234);
   **        FND_PROFILE.DELETE('P_NAME', 'USER', 123321);
   **        FND_PROFILE.DELETE('P_NAME', 'SERVER', 25);
   **        FND_PROFILE.DELETE('P_NAME', 'ORG', 204);
   **        FND_PROFILE.DELETE('P_NAME', 'SERVRESP', 321532, 345234, 25);
   **        FND_PROFILE.DELETE('P_NAME', 'SERVRESP', 321532, 345234, -1);
   **        FND_PROFILE.DELETE('P_NAME', 'SERVRESP', -1, -1, 25);
   **
   **  returns: TRUE if successful, FALSE if failure.
   **
   */
   FUNCTION DELETE(x_name IN VARCHAR2,
                   -- Profile name you are setting
                   x_level_name IN VARCHAR2,
                   -- Level that you're setting at: 'SITE','APPL','RESP','USER', etc.
                   x_level_value IN VARCHAR2 DEFAULT NULL,
                   -- Level value that you are setting at, e.g. user id for 'USER' level.
                   -- X_LEVEL_VALUE is not used at site level.
                   x_level_value_app_id IN VARCHAR2 DEFAULT NULL,
                   -- Used for 'RESP' and 'SERVRESP' level; Resp Application_Id.
                   x_level_value2 IN VARCHAR2 DEFAULT NULL
                   -- 2nd Level value that you are setting at.  This is for the 'SERVRESP'
                   -- hierarchy only.
                   ) RETURN BOOLEAN IS

      l_deleted BOOLEAN;

   BEGIN

      -- Call SAVE routine and pass NULL for the profile option value.  This
      -- physically deletes the row from fnd_profile_option_values.
      l_deleted := SAVE(x_name,
                        NULL,
                        x_level_name,
                        x_level_value,
                        x_level_value_app_id,
                        x_level_value2);

      RETURN l_deleted;

   END DELETE;

   /*
   ** AOL INTERNAL USE ONLY
   **
   ** PUT_CACHE_CLEARED - returns true if the put cache was cleared.
   */
   FUNCTION put_cache_cleared RETURN BOOLEAN IS
   BEGIN
      RETURN(put_cache_is_clear);
   END put_cache_cleared;

BEGIN
   -- Initialization section
   -- this seems redundant, mskees 2011-09-07
   table_size := 2147483646;

END fnd_profile;

/

  GRANT EXECUTE ON "APPS"."FND_PROFILE" TO "EM_OAM_MONITOR_ROLE";
