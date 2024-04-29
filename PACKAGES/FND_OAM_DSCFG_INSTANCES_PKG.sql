--------------------------------------------------------
--  DDL for Package FND_OAM_DSCFG_INSTANCES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_OAM_DSCFG_INSTANCES_PKG" AUTHID CURRENT_USER as
/* $Header: AFOAMDSCINSTS.pls 120.1 2005/12/19 09:50 ilawler noship $ */

   ---------------
   -- Constants --
   ---------------
   -- Config Instance Types are stored in DSCFG_API_PKG

   ---------------------------------
   -- Public Procedures/Functions --
   ---------------------------------

   -- Accessor function, checks if internal state is initialized.
   -- Invariants:
   --   None
   -- Parameters:
   --   None
   -- Returns:
   --   Boolean where TRUE=Initialized
   -- Exceptions:
   --   None
   FUNCTION IS_INITIALIZED
      RETURN BOOLEAN;

   -- Accessor function, obtains the config_instance_id.
   -- Invariants:
   --   Only has a value during import after the configuration instance has been initialized.
   -- Parameters:
   --   None
   -- Returns:
   --   The config_instance_id stored in the package state from the last sucessful ADD_CONFIG_INSTANCE
   --   or SET_CURRENT_CONFIG_INSTANCE call.
   -- Exceptions:
   --   If the configuration instance state isn't initialized, a NO_DATA_FOUND exception is thrown.
   FUNCTION GET_CURRENT_ID
      RETURN NUMBER;

   -- Accessor function, obtains the config_instance_type.
   -- Invariants:
   --   Only has a value during import after the configuration instance has been initialized.
   -- Parameters:
   --   None
   -- Returns:
   --   The config_instance_type stored in the package state from the last sucessful ADD_CONFIG_INSTANCE
   --   or SET_CURRENT_CONFIG_INSTANCE call.
   -- Exceptions:
   --   If the configuration instance state isn't initialized, a NO_DATA_FOUND exception is thrown.
   FUNCTION GET_CURRENT_TYPE
      RETURN VARCHAR2;

   -- Accessor function, obtains the DBNAME of the original source database.  This column may be used along
   -- with the clone_key/policyset_id in custom import procedures to identify what steps need to be taken.
   -- Invariants:
   --   Only has a value during import after the configuration instance has been initialized.
   -- Parameters:
   --   None
   -- Returns:
   --   The source database's DBNAME or NULL if it wasn't provided or is irrelevant.
   -- Exceptions:
   --   If the configuration instance state isn't initialized, a NO_DATA_FOUND exception is thrown.
   FUNCTION GET_CURRENT_SOURCE_DBNAME
      RETURN VARCHAR2;

   -- Accessor function, obtains the clone key associated with currently importing configuration instance.
   -- Invariants:
   --   Only has a value during import after the configuration instance has been initialized.
   -- Parameters:
   --   None
   -- Returns:
   --   The clone key associated with the in-progress configuration instance, may be NULL
   --   if the configuration instance type is not CLONING.
   -- Exceptions:
   --   If the configuration instance state isn't initialized, a NO_DATA_FOUND exception is thrown.
   FUNCTION GET_CURRENT_CLONE_KEY
      RETURN VARCHAR2;

   -- Accessor function, obtains the policyset_id associated with currently importing configuration instance.
   -- Invariants:
   --   Only has a value during import after the configuration instance has been initialized.
   -- Parameters:
   --   None
   -- Returns:
   --   The numerical ID of the Policy Set associated with the in-progress configuration instance, may be NULL
   --   if there is no policyset_id associated with this instance.
   -- Exceptions:
   --   If the configuration instance state isn't initialized, a NO_DATA_FOUND exception is thrown.
   FUNCTION GET_CURRENT_POLICYSET_ID
      RETURN NUMBER;

   -- Setter/Getter for field LAST_IMPORTED of the current configuration instance.
   -- Invariants:
   --   Should only be called after the configuration instance has been initialized.
   -- Parameters:
   --   Self-exlanatory.
   -- Returns:
   --   None
   -- Exceptions:
   --   If the configuration instance state isn't initialized, a NO_DATA_FOUND exception is thrown.
   PROCEDURE SET_LAST_IMPORTED(p_last_imported  IN DATE);
   FUNCTION GET_LAST_IMPORTED
      RETURN DATE;

   -- Setter/Getter for field IMPORT_DURATION of the current configuration instance.
   -- Invariants:
   --   Should only be called after the configuration instance has been initialized.
   -- Parameters:
   --   Self-exlanatory.
   -- Returns:
   --   None
   -- Exceptions:
   --   If the configuration instance state isn't initialized, a NO_DATA_FOUND exception is thrown.
   PROCEDURE SET_IMPORT_DURATION(p_import_duration  IN NUMBER);
   FUNCTION GET_IMPORT_DURATION
      RETURN NUMBER;

   -- Setter/Getter for field LAST_COMPILED of the current configuration instance.
   -- Invariants:
   --   Should only be called after the configuration instance has been initialized.
   -- Parameters:
   --   Self-exlanatory.
   -- Returns:
   --   None
   -- Exceptions:
   --   If the configuration instance state isn't initialized, a NO_DATA_FOUND exception is thrown.
   PROCEDURE SET_LAST_COMPILED(p_last_compiled  IN DATE);
   FUNCTION GET_LAST_COMPILED
      RETURN DATE;

   -- Setter/Getter for field COMPILE_DURATION of the current configuration instance.
   -- Invariants:
   --   Should only be called after the configuration instance has been initialized.
   -- Parameters:
   --   Self-exlanatory.
   -- Returns:
   --   None
   -- Exceptions:
   --   If the configuration instance state isn't initialized, a NO_DATA_FOUND exception is thrown.
   PROCEDURE SET_COMPILE_DURATION(p_compile_duration  IN NUMBER);
   FUNCTION GET_COMPILE_DURATION
      RETURN NUMBER;

   -- This procedure checks to see if a configuration already exists for the provided type and associated state.
   -- Invariants:
   --   None
   -- Parameters:
   --   p_target_dbname         Name of the database for which this configuration instance is being created - may be
   --                           different from database where configuration is being done.
   --   p_config_instance_type  Configuration Instance Type, defined in API_PKG.G_INSTTYPE_*.
   --   p_clone_key             [OPTIONAL]Clone key associated with instance when p_type=G_ITYPE_CLONING.
   --   p_policyset_id          [OPTIONAL]Policy Set ID associated with configuration, may be NULL if unspecified or irrelevant.
   --
   --   x_config_instance_id:   The corresponding ID of the existing configuration instance, NULL if none found.
   -- Return Statuses:
   --   Swallows all errors, returns TRUE if x_config_instance_id holds a valid ID, FALSE otherwise.
   FUNCTION CONFIG_INSTANCE_EXISTS(p_target_dbname              IN VARCHAR2,
                                   p_config_instance_type       IN VARCHAR2,
                                   p_clone_key                  IN VARCHAR2     DEFAULT NULL,
                                   p_policyset_id               IN NUMBER       DEFAULT NULL,
                                   x_config_instance_id         OUT NOCOPY NUMBER)
      RETURN BOOLEAN;

   -- This procedure creates a new configuration instance.  This procedure makes sure the database is in a state
   -- where configuration changes can be made and initializes package state on success.
   -- Invariants:
   --   None
   -- Parameters:
   --   p_target_dbname         Name of the database for which this configuration instance is being created - may be
   --                           different from database where configuration is being done.
   --   p_config_instance_type  Configuration Instance Type, defined in API_PKG.G_INSTTYPE_*.
   --   p_name                  Name of the configuration instance.
   --   p_description           Description of the configuration instance.
   --   p_language              Language used for the name/description, defaults to USERENV('LANG') if null.
   --   p_clone_key             [OPTIONAL]Clone key associated with instance when p_type=G_ITYPE_CLONING.
   --   p_policyset_id          [OPTIONAL]Policy Set ID associated with configuration, may be NULL if unspecified or irrelevant.
   --
   --   x_config_instance_id:   The corresponding ID of the newly created configuration instance.
   -- Return Statuses:
   --   Throws PROGRAM_ERROR if scrambling configuration changes are not allowed.
   PROCEDURE ADD_CONFIG_INSTANCE(p_target_dbname        IN VARCHAR2,
                                 p_config_instance_type IN VARCHAR2,
                                 p_name                 IN VARCHAR2,
                                 p_description          IN VARCHAR2     DEFAULT NULL,
                                 p_language             IN VARCHAR2     DEFAULT NULL,
                                 p_source_dbname        IN VARCHAR2     DEFAULT NULL,
                                 p_clone_key            IN VARCHAR2     DEFAULT NULL,
                                 p_policyset_id         IN NUMBER       DEFAULT NULL,
                                 x_config_instance_id   OUT NOCOPY NUMBER);

   -- This procedure uses an existing configuration instance.  This procedure makes sure the database is in a state
   -- where configuration changes can be made and initializes package state on success.
   -- Invariants:
   --   Config Instance ID should be retrieved via a previous call to CONFIG_INSTANCE_EXISTS.
   -- Parameters:
   --   p_config_instance_id:   The configuration instance ID we want to use
   -- Return Statuses:
   --   Throws NO_DATA_FOUND if config instance does not exist or is invalid.
   --   Also, throws PROGRAM_ERROR if scrambling configuration is not allowed.
   PROCEDURE SET_CURRENT_CONFIG_INSTANCE(p_config_instance_id   IN NUMBER);

   -- This procedure deletes a configuration instance.
   -- Invariants:
   --   None
   -- Parameters:
   --   p_config_instance_id:   The configuration instance ID
   --   p_recurse               FND_API.G_TRUE/G_FALSE indicating whether to recurse and delete child objects/properties
   -- Return Statuses:
   --   Throws NO_DATA_FOUND if config instance does not exist.
   FUNCTION DELETE_CONFIG_INSTANCE(p_config_instance_id IN NUMBER,
                                   p_recurse_config     IN VARCHAR2 DEFAULT NULL,
                                   p_recurse_engine     IN VARCHAR2 DEFAULT NULL)
      RETURN BOOLEAN;

END FND_OAM_DSCFG_INSTANCES_PKG;

 

/
