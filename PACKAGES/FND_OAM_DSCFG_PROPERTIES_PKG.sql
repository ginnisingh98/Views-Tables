--------------------------------------------------------
--  DDL for Package FND_OAM_DSCFG_PROPERTIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_OAM_DSCFG_PROPERTIES_PKG" AUTHID CURRENT_USER as
/* $Header: AFOAMDSCPROPS.pls 120.2 2005/12/19 09:41 ilawler noship $ */

   ---------------
   -- Constants --
   ---------------
   -- Property Datatypes and Names are stored in DSCFG_API_PKG.

   ---------------------------------
   -- Public Procedures/Functions --
   ---------------------------------

   -- This procedure adds a new property for a given parent type/id.  The configuration instance is checked to make
   -- sure it's been initialized.  We don't check to see if the property already exists so we can have multi-valued properties
   -- that are compiled into lists (e.g. ADDITIONAL_DOMAIN property).  No autonomous commit to allow atomic commit
   -- with the parent.
   -- Invariants:
   --   Should only be called after a configuration instance has been created or set and an object has been created/queried.
   -- Parameters:
   --   p_parent_type           The type of object to which this property belongs. DSCFG_API_PKG.G_TYPE_*.
   --   p_parent_id             The id of the object to which this property belongs.
   --   p_property_name         Name in the Property Name-Value pair, has meaning in the context of the object type.
   --                           These names are defined as DSCFG_API_PKG.G_PROP_* constants.
   --   p_datatype              Data type of the property, based on DSCFG_API_PKG.G_DATATYPE_* constants.
   --   p_canonical_value       Canonical, VARCHAR2, representation of the value in the Property Name-Value pair.
   --
   --   x_property_id:          The corresponding ID of the newly property.
   -- Return Statuses:
   --   Throws NO_DATA_FOUND if the configuration instance isn't initialized.
   PROCEDURE ADD_PROPERTY(p_parent_type         IN VARCHAR2,
                          p_parent_id           IN NUMBER,
                          p_property_name       IN VARCHAR2,
                          p_datatype            IN VARCHAR2,
                          p_canonical_value     IN VARCHAR2,
                          x_property_id         OUT NOCOPY NUMBER);

   -- Convenience wrapper on generic ADD_PROPERTY for datatype VARCHAR2
   PROCEDURE ADD_PROPERTY(p_parent_type         IN VARCHAR2,
                          p_parent_id           IN NUMBER,
                          p_property_name       IN VARCHAR2,
                          p_varchar2_value      IN VARCHAR2,
                          x_property_id         OUT NOCOPY NUMBER);

   -- Convenience wrapper on generic ADD_PROPERTY for datatype NUMBER
   PROCEDURE ADD_PROPERTY(p_parent_type         IN VARCHAR2,
                          p_parent_id           IN NUMBER,
                          p_property_name       IN VARCHAR2,
                          p_number_value        IN NUMBER,
                          x_property_id         OUT NOCOPY NUMBER);

   -- Convenience wrapper on generic ADD_PROPERTY for datatype DATE
   PROCEDURE ADD_PROPERTY(p_parent_type         IN VARCHAR2,
                          p_parent_id           IN NUMBER,
                          p_property_name       IN VARCHAR2,
                          p_date_value          IN DATE,
                          x_property_id         OUT NOCOPY NUMBER);

   -- Convenience wrapper on generic ADD_PROPERTY for datatype BOOLEAN
   PROCEDURE ADD_PROPERTY(p_parent_type         IN VARCHAR2,
                          p_parent_id           IN NUMBER,
                          p_property_name       IN VARCHAR2,
                          p_boolean_value       IN BOOLEAN,
                          x_property_id         OUT NOCOPY NUMBER);

   -- Convenience wrapper on generic ADD_PROPERTY for datatype ROWID
   PROCEDURE ADD_PROPERTY_ROWID(p_parent_type           IN VARCHAR2,
                                p_parent_id             IN NUMBER,
                                p_property_name         IN VARCHAR2,
                                p_rowid_value           IN ROWID,
                                x_property_id           OUT NOCOPY NUMBER);

   -- Convenience wrapper on generic ADD_PROPERTY for datatype RAW
   PROCEDURE ADD_PROPERTY_RAW(p_parent_type             IN VARCHAR2,
                              p_parent_id               IN NUMBER,
                              p_property_name           IN VARCHAR2,
                              p_raw_value               IN RAW,
                              x_property_id             OUT NOCOPY NUMBER);

   -- This procedure obtains the value for a given parent/property name.
   -- Invariants:
   --   None
   -- Parameters:
   --   p_parent_type           The type of object to which this property belongs. DSCFG_API_PKG.G_TYPE_*.
   --   p_parent_id             The id of the object to which this property belongs.
   --   p_property_name         Name in the Property Name-Value pair, has meaning in the context of the object type.
   --                           These names are defined as DSCFG_API_PKG.G_PROP_* constants.
   --
   --   x_canonical_value:      The canonical_value of the corresponding property
   -- Return Statuses:
   --   NO_DATA_FOUND when property not found
   --   TOO_MANY_ROWS when the property has more than one value
   PROCEDURE GET_PROPERTY_CANONICAL_VALUE(p_parent_type         IN VARCHAR2,
                                          p_parent_id           IN NUMBER,
                                          p_property_name       IN VARCHAR2,
                                          x_canonical_value     OUT NOCOPY VARCHAR2);

   -- Convenience wrapper on generic GET_PROPERTY_CANONICAL_VALUE for datatype VARCHAR2
   PROCEDURE GET_PROPERTY_VALUE(p_parent_type           IN VARCHAR2,
                                p_parent_id             IN NUMBER,
                                p_property_name         IN VARCHAR2,
                                x_varchar2_value        OUT NOCOPY VARCHAR2);

   -- Convenience wrapper on generic GET_PROPERTY_CANONICAL_VALUE for datatype NUMBER
   PROCEDURE GET_PROPERTY_VALUE(p_parent_type           IN VARCHAR2,
                                p_parent_id             IN NUMBER,
                                p_property_name         IN VARCHAR2,
                                x_number_value          OUT NOCOPY NUMBER);

   -- Convenience wrapper on generic GET_PROPERTY_CANONICAL_VALUE for datatype DATE
   PROCEDURE GET_PROPERTY_VALUE(p_parent_type           IN VARCHAR2,
                                p_parent_id             IN NUMBER,
                                p_property_name         IN VARCHAR2,
                                x_date_value            OUT NOCOPY DATE);


   -- This procedure tries to update a property and failing that adds the property. The configuration instance is checked to make
   -- sure it's been initialized. No autonomous commit to allow atomic commit with the parent.
   -- Invariants:
   --   Should only be called after a configuration instance has been created or set and an object has been created/queried.
   -- Parameters:
   --   p_parent_type           The type of object to which this property belongs. DSCFG_API_PKG.G_TYPE_*.
   --   p_parent_id             The id of the object to which this property belongs.
   --   p_property_name         Name in the Property Name-Value pair, has meaning in the context of the object type.
   --                           These names are defined as DSCFG_API_PKG.G_PROP_* constants.
   --   p_datatype              Data type of the property, based on DSCFG_API_PKG.G_DATATYPE_* constants.
   --   p_canonical_value       Canonical, VARCHAR2, representation of the value in the Property Name-Value pair.
   --
   --   x_property_id:          The corresponding ID of the newly property.
   -- Return Statuses:
   --   Throws NO_DATA_FOUND if the configuration instance isn't initialized.
   PROCEDURE SET_OR_ADD_PROPERTY(p_parent_type          IN VARCHAR2,
                                 p_parent_id            IN NUMBER,
                                 p_property_name        IN VARCHAR2,
                                 p_datatype             IN VARCHAR2,
                                 p_canonical_value      IN VARCHAR2,
                                 x_property_id          OUT NOCOPY NUMBER);

   -- Convenience wrapper on generic SET_OR_ADD_PROPERTY for datatype VARCHAR2
   PROCEDURE SET_OR_ADD_PROPERTY(p_parent_type          IN VARCHAR2,
                                 p_parent_id            IN NUMBER,
                                 p_property_name        IN VARCHAR2,
                                 p_varchar2_value       IN VARCHAR2,
                                 x_property_id          OUT NOCOPY NUMBER);

   -- Convenience wrapper on generic SET_OR_ADD_PROPERTY for datatype NUMBER
   PROCEDURE SET_OR_ADD_PROPERTY(p_parent_type          IN VARCHAR2,
                                 p_parent_id            IN NUMBER,
                                 p_property_name        IN VARCHAR2,
                                 p_number_value         IN NUMBER,
                                 x_property_id          OUT NOCOPY NUMBER);

   -- Convenience wrapper on generic SET_OR_ADD_PROPERTY for datatype DATE
   PROCEDURE SET_OR_ADD_PROPERTY(p_parent_type          IN VARCHAR2,
                                 p_parent_id            IN NUMBER,
                                 p_property_name        IN VARCHAR2,
                                 p_date_value           IN DATE,
                                 x_property_id          OUT NOCOPY NUMBER);

   -- This procedure deletes all properties attached to a particular parent_type/id
   -- Invariants:
   --   None
   -- Parameters:
   --   p_parent_type:          The parent_type
   --   p_parent_id:            The parent_id
   -- Return Statuses:
   --   TRUE on success, FALSE on failure.
   FUNCTION DELETE_PROPERTIES(p_parent_type     IN VARCHAR2,
                              p_parent_id       IN NUMBER)
      RETURN BOOLEAN;

   -- This procedure deletes a property
   -- Invariants:
   --   None
   -- Parameters:
   --   p_property_id:          The property ID
   -- Return Statuses:
   --   TRUE on success, FALSE on failure.
   FUNCTION DELETE_PROPERTY(p_property_id       IN NUMBER)
      RETURN BOOLEAN;

END FND_OAM_DSCFG_PROPERTIES_PKG;

 

/
