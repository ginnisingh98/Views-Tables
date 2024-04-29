--------------------------------------------------------
--  DDL for Package FND_OAM_DSCFG_OBJECTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_OAM_DSCFG_OBJECTS_PKG" AUTHID CURRENT_USER as
/* $Header: AFOAMDSCOBJS.pls 120.2 2006/01/17 11:33 ilawler noship $ */

   ---------------
   -- Constants --
   ---------------
   -- Object Types are stored in DSCFG_API_PKG.

   ---------------------------------
   -- Public Procedures/Functions --
   ---------------------------------

   -- This procedure adds a new configuration object.  The configuration_instance_id is pulled from the
   -- INSTANCES_PKG to force a call to CREATE/USE_CONFIG_INSTANCE.  The import_proc_id is pulled from the
   -- IMPORT_PROCS_PKG if possible.  This is not autonomous so we can package properties, mapped keys or other
   -- entities in the same commit.
   -- Invariants:
   --   Should only be called after a configuration instance has been created or set.
   -- Parameters:
   --   p_object_type           Corresponds to API_PKG.G_OTYPE_*, determines what properties to look for later.
   --   p_parent_object_id      DSCFG_OBJECTS.OBJECT_ID of parent object, typically used to link argument objects to their
   --                           parent DML-operation object.
   --   p_source_type           [OPTIONAL]A VARCHAR2(30) field used for declaring a type of the source object, for use
   --                           in import procedures/objects to identify a link to part of the original configuration source.
   --   p_source_id             [OPTIONAL]A corresponding Number ID for the source_type.  May refer to a mapped ID
   --                           obtained from FND_OAM_DSCFG_MAPPED_KEYS if the source requires a complex or varchar2 key.
   --   p_errors_found_flag     [OPTIONAL]FND_API.G_TRUE/G_FALSE boolean indicating if an error was encountered
   --                           for this object.
   --   p_message               [OPTIONAL]Field to store message explaining any warnings or errors encountered.
   --
   --   x_object_id:            The corresponding ID of the newly created object.
   -- Return Statuses:
   --   Throws NO_DATA_FOUND if the configuration instance isn't initialized.
   PROCEDURE ADD_OBJECT(p_object_type           IN VARCHAR2,
                        p_parent_object_id      IN NUMBER       DEFAULT NULL,
                        p_source_type           IN VARCHAR2     DEFAULT NULL,
                        p_source_id             IN NUMBER       DEFAULT NULL,
                        p_errors_found_flag     IN VARCHAR2     DEFAULT NULL,
                        p_message               IN VARCHAR2     DEFAULT NULL,
                        x_object_id             OUT NOCOPY NUMBER);

   -- This procedure obtains the object_id of any objects in the current configuration instance with
   -- a given object_type.  This allows an integrating procedure to store all its data using a given object_type
   -- and then have another procedure fetch it all using this procedure.
   -- Invariants:
   --   Should only be called after a configuration instance has been created or set.
   -- Parameters:
   --   p_object_type           Corresponds to API_PKG.G_OTYPE_* that we want to seach for.
   --
   --   x_object_ids:           The corresponding IDs of the stored objects with matching parameters.
   -- Return Statuses:
   --   Throws NO_DATA_FOUND if the configuration instance isn't initialized.
   PROCEDURE GET_OBJECTS_FOR_TYPE(p_object_type         IN VARCHAR2,
                                  x_object_ids          OUT NOCOPY DBMS_SQL.NUMBER_TABLE);

   -- This procedure obtains the object_id of any objects in the current configuration instance with
   -- a given object_type and errors_found_flag.  This allows an integrating procedure to store all its
   -- data using a given object_type and then have another procedure fetch objects with a given error_state later.
   -- Invariants:
   --   Should only be called after a configuration instance has been created or set.
   -- Parameters:
   --   p_object_type           Corresponds to API_PKG.G_OTYPE_* that we want to seach for.
   --   p_errors_found_flag     Limits the returned object_ids to only those with the specified errors_found_flag.
   --                           Value may be NULL.
   --
   --   x_object_ids:           The corresponding IDs of the stored objects with matching parameters.
   -- Return Statuses:
   --   Throws NO_DATA_FOUND if the configuration instance isn't initialized.
   PROCEDURE GET_OBJECTS_FOR_TYPE(p_object_type         IN VARCHAR2,
                                  p_errors_found_flag   IN VARCHAR2,
                                  x_object_ids          OUT NOCOPY DBMS_SQL.NUMBER_TABLE);

   -- This procedure deletes a config object
   -- Invariants:
   --   None
   -- Parameters:
   --   p_object_id:    The object ID
   --   p_recurse               FND_API.G_TRUE/G_FALSE indicating whether to recurse and delete child objects/properties
   -- Return Statuses:
   --   Throws NO_DATA_FOUND if config instance does not exist.
   FUNCTION DELETE_OBJECT(p_object_id   IN NUMBER,
                          p_recurse     IN VARCHAR2 DEFAULT NULL)
      RETURN BOOLEAN;

END FND_OAM_DSCFG_OBJECTS_PKG;

 

/
