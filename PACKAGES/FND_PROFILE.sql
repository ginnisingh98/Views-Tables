--------------------------------------------------------
--  DDL for Package FND_PROFILE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_PROFILE" AUTHID CURRENT_USER AS
   /* $Header: AFPFPROS.pls 120.5.12010000.4 2012/02/03 03:46:55 rarmaly ship $ */
   /*#
   * APIs to manipulate values stored in client
   * and server user profile caches.Any changes you make to profile option
   * values using these routines affect only the run-time environment. The
   * effect of these settings end when the program ends, because the database
   * session (which holds the profile cache) is terminated.
   * @rep:scope public
   * @rep:product FND
   * @rep:displayname Profile Management APIs
   * @rep:category BUSINESS_ENTITY FND_PROFILE
   * @rep:compatibility S
   * @rep:lifecycle active
   * @rep:ihelp FND/@prof_plsql#prof_plsql See the related online help
   */
   /*
   ** PUT - sets a profile option to a value for this session,
   **       but doesn't save to the database
   */
   /*#
   * Puts a value to the specified user profile option. If the option
   * does not exist, you can also create it with PUT. A PUT on the server
   * affects only the server-side profile cache, and a PUT on the client
   * affects only the client-side cache. By using PUT, you destroy the
   * synchrony between server-side and client-side profile caches. As a
   * result, we do not recommend widespread use of PUT.
   * @param name Profile name
   * @param val Profile value
   * @rep:scope public
   * @rep:displayname Put Profile
   * @rep:compatibility S
   * @rep:lifecycle active
   * @rep:ihelp FND/@prof_plsql See related online help.
   */

   PROCEDURE put
   (
      NAME IN VARCHAR2,
      val  IN VARCHAR2
   );
   PRAGMA RESTRICT_REFERENCES(put, WNDS, RNDS, TRUST);

   /*
   ** DEFINED - returns TRUE if a profile option has been stored
   */
   FUNCTION defined(NAME IN VARCHAR2) RETURN BOOLEAN;
   PRAGMA RESTRICT_REFERENCES(defined, WNDS, TRUST);

   /*
   ** GET - gets the value of a profile option
   */
   /*#
   * Gets the current value of the specified user profile option, or
   * NULL if the profile does not exist. All GET operations are
   * satisfied locally. In other words, a GET on the server is satisfied
   * from the server-side cache, and a GET on the client is satisfied from
   * the client-side cache.
   * @param name Profile name
   * @param val  Profile value as set by PUT
   * @rep:scope public
   * @rep:displayname Get Profile
   * @rep:compatibility S
   * @rep:lifecycle active
   * @rep:ihelp FND/@prof_plsql See related online help.
   */

   PROCEDURE get
   (
      NAME IN VARCHAR2,
      val  OUT NOCOPY VARCHAR2
   );
   PRAGMA RESTRICT_REFERENCES(get, WNDS, TRUST);

   /*
   ** VALUE - returns the value of a profile options
   */
   /*#
   * Works exactly like GET, except it returns the value of the
   * specified profile option as a function result.
   * @param name Profile name
   * @return specified profile option value
   * @rep:scope public
   * @rep:displayname Get Profile Value
   * @rep:compatibility S
   * @rep:lifecycle active
   * @rep:ihelp FND/@prof_plsql See related online help.
   */
   FUNCTION VALUE(NAME IN VARCHAR2) RETURN VARCHAR2;
   PRAGMA RESTRICT_REFERENCES(VALUE, WNDS, TRUST);

   /*
   ** VALUE_WNPS - returns the value of a profile option without caching it.
   **
   **            The main usage for this routine would be in a SELECT
   **            statement where VALUE() is not allowed since it
   **            writes package state.
   **
   **            This routine does the same thing as VALUE(); it returns
   **            a profile value from the profile cache, or from the database
   **            if it isn't already in the profile cache already.  The only
   **            difference between this and VALUE() is that this will not
   **            put the value into the cache if it is not already there, so
   **            repeated calls to this can be slower because it will have
   **            to hit the database each time for the profile value.
   **
   **            In most cases, however, you can and should use VALUE()
   **            instead of VALUE_WNPS(), because VALUE() will give
   **            better performance.
   */
   FUNCTION value_wnps(NAME IN VARCHAR2) RETURN VARCHAR2;
   PRAGMA RESTRICT_REFERENCES(value_wnps, WNDS, WNPS, TRUST);

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
   ) RETURN BOOLEAN;

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
   **        FND_PROFILE.SAVE('P_NAME', 'P_VAL', 'APPL', 321532);
   **        FND_PROFILE.SAVE('P_NAME', 'P_VAL', 'RESP', 321532, 345234);
   **        FND_PROFILE.SAVE('P_NAME', 'P_VAL', 'USER', 123321);
   **        FND_PROFILE.SAVE('P_NAME', 'SERVER', 25);
   **        FND_PROFILE.SAVE('P_NAME', 'ORG', 204);
   **        FND_PROFILE.SAVE('P_NAME', 'SERVRESP', 321532, 345234, 25);
   **        FND_PROFILE.SAVE('P_NAME', 'SERVRESP', 321532, 345234, -1);
   **        FND_PROFILE.SAVE('P_NAME', 'SERVRESP', -1, -1, 25);
   **
   **  returns: TRUE if successful, FALSE if failure.
   **
   */
   FUNCTION SAVE(x_name IN VARCHAR2,
                 /* Profile name you are setting */
                 x_value IN VARCHAR2,
                 /* Profile value you are setting */
                 x_level_name IN VARCHAR2,
                 /* Level that you're setting at: 'SITE','APPL','RESP','USER', etc. */
                 x_level_value IN VARCHAR2 DEFAULT NULL,
                 /* Level value that you are setting at, e.g. user id for 'USER' level.
                                            X_LEVEL_VALUE is not used at site level. */
                 x_level_value_app_id IN VARCHAR2 DEFAULT NULL,
                 /* Used for 'RESP' and 'SERVRESP' level; Resp Application_Id. */
                 x_level_value2 IN VARCHAR2 DEFAULT NULL
                 /* 2nd Level value that you are setting at.  This is for the 'SERVRESP'
                                            hierarchy. */) RETURN BOOLEAN;

   /*
   ** GET_SPECIFIC - Get profile value for a specific user/resp/appl combo
   **   Default is user/resp/appl is current login.
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
   );

   PRAGMA RESTRICT_REFERENCES(get_specific, WNDS, WNPS, TRUST);

   /*
   ** VALUE_SPECIFIC - Get profile value for a specific user/resp/appl combo
   **   Default is user/resp/appl is current login.
   */
   FUNCTION value_specific
   (
      NAME              IN VARCHAR2,
      user_id           IN NUMBER DEFAULT NULL,
      responsibility_id IN NUMBER DEFAULT NULL,
      application_id    IN NUMBER DEFAULT NULL,
      org_id            IN NUMBER DEFAULT NULL,
      server_id         IN NUMBER DEFAULT NULL
   ) RETURN VARCHAR2;
   PRAGMA RESTRICT_REFERENCES(value_specific, WNDS, WNPS, TRUST);

   /*
   ** FOR AOL INTERNAL USE ONLY
   **
   ** initialize_org_context - Initializes the org context used by profiles.
   */
   PROCEDURE initialize_org_context;

   /*
   ** AOL INTERNAL USE ONLY
   */
   PROCEDURE initialize
   (
      user_id_z           IN NUMBER DEFAULT NULL,
      responsibility_id_z IN NUMBER DEFAULT NULL,
      application_id_z    IN NUMBER DEFAULT NULL,
      site_id_z           IN NUMBER DEFAULT NULL
   );
   --    pragma restrict_references(INITIALIZE, WNDS);

   PROCEDURE putmultiple
   (
      names IN VARCHAR2,
      vals  IN VARCHAR2,
      num   IN NUMBER
   );
   PRAGMA RESTRICT_REFERENCES(putmultiple, WNDS, RNDS, TRUST);

   /*
   ** GET_TABLE_VALUE - get the value of a profile option from the table
   **
   ** [NOTE: THIS FUNCTION IS FOR AOL INTERNAL USE ONLY.]
   */
   FUNCTION get_table_value(NAME IN VARCHAR2) RETURN VARCHAR2;
   PRAGMA RESTRICT_REFERENCES(get_table_value, WNDS, WNPS, RNDS, TRUST);

   /*
   ** GET_ALL_TABLE_VALUES - get all the values from the table
   **   The varchar2 returned can be up to 32767 characters long.
   **
   ** [NOTE: THIS FUNCTION IS FOR AOL INTERNAL USE ONLY.]
   */
   FUNCTION get_all_table_values(delim IN VARCHAR2) RETURN VARCHAR2;
   PRAGMA RESTRICT_REFERENCES(get_all_table_values,
                              WNDS,
                              WNPS,
                              RNDS,
                              TRUST);

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
   ) RETURN VARCHAR2;

   /*
   ** DELETE - deletes the value of a profile option permanently from the
   **          database, at any level.  This routine serves as a wrapper to
   **          the SAVE routine which means that this routine can be used at
   **          runtime or during patching.  Like the SAVE routine, this
   **          routine will not actually commit the changes; the caller must
   **          commit.
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
                   /* Profile name you are setting */
                   x_level_name IN VARCHAR2,
                   /* Level that you're setting at: 'SITE','APPL','RESP','USER', etc. */
                   x_level_value IN VARCHAR2 DEFAULT NULL,
                   /* Level value that you are setting at, e.g. user id for 'USER' level.
                                                       X_LEVEL_VALUE is not used at site level. */
                   x_level_value_app_id IN VARCHAR2 DEFAULT NULL,
                   /* Used for 'RESP' and 'SERVRESP' level; Resp Application_Id. */
                   x_level_value2 IN VARCHAR2 DEFAULT NULL
                   /* 2nd Level value that you are setting at.  This is for the 'SERVRESP'
                                                       hierarchy only. */)
      RETURN BOOLEAN;

   /*
   ** AOL INTERNAL USE ONLY
   **
   ** PUT_CACHE_CLEARED - returns true if the put cache was cleared.
   **
   ** Bug 12875860 - PER Rewrite - this function is ONLY for use by FND_GLOBAL
   ** after a call to FND_PROFILE.INITIALIZE == ONLY FND_GLOBAL should call
   ** INITIALIZE and this value ONLY has meaning between that call and the
   ** subsequent call to PER Initialization code.
   */
   FUNCTION put_cache_cleared RETURN BOOLEAN;

END fnd_profile;

/

  GRANT EXECUTE ON "APPS"."FND_PROFILE" TO "EM_OAM_MONITOR_ROLE";
