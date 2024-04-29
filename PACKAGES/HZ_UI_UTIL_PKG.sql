--------------------------------------------------------
--  DDL for Package HZ_UI_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_UI_UTIL_PKG" AUTHID CURRENT_USER AS
/* $Header: ARHPUISS.pls 120.6 2006/04/13 22:25:48 vnama noship $ */

--------------------------------------
--------------------------------------
-- declaration of constants
--------------------------------------
--------------------------------------


--------------------------------------------------------------------------
-- declaration of user defined type
--------------------------------------------------------------------------

-- Use type definitions directly from HZ_MIXNM_UTILITY to save an extraneous copy.
-- Rosetta wrapper generator cannot handle foreign type refernences, so use the following
-- if need to re-generate the Rosetta wrappers.

--TYPE INDEXVARCHAR30List IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;
--TYPE INDEXVARCHAR1List IS TABLE OF VARCHAR2(1) INDEX BY BINARY_INTEGER;


--------------------------------------
--------------------------------------
-- Entity-Level Security Checks
--------------------------------------
--------------------------------------

-------------------------------------
-- CHECK_ENTITY_CREATION - Signature
-------------------------------------

PROCEDURE check_entity_creation (
   p_entity_name        IN VARCHAR2,               -- table name
   p_data_source        IN VARCHAR2 DEFAULT NULL,  -- if applicable
   p_party_id           IN NUMBER   DEFAULT NULL,  -- only pass if available
   p_parent_entity_name IN VARCHAR2 DEFAULT NULL,  -- if applicable
   p_parent_entity_pk1  IN VARCHAR2 DEFAULT NULL,  -- if applicable
   p_parent_entity_pk2  IN VARCHAR2 DEFAULT NULL,  -- if applicable
   p_function_name      IN VARCHAR2 DEFAULT NULL,  -- FND function name
   x_create_flag        OUT NOCOPY VARCHAR2        -- can we create?
);

-------------------------------------
-- GET_VIEW_PREDICATE - Signature
-------------------------------------

FUNCTION get_view_predicate (
  p_entity_name       IN VARCHAR2,               -- entity/table you wish to filter
  p_entity_alias      IN VARCHAR2 DEFAULT NULL,  -- alias for entity as used in SELECT
  p_function_name     IN VARCHAR2 DEFAULT NULL  -- FND function name
) RETURN VARCHAR2;


--------------------------------------
--------------------------------------
-- Row-Level Security Checks
--------------------------------------
--------------------------------------

/*
PROCEDURE check_row_access (
   p_entity_name      IN VARCHAR2,               -- table name
   p_data_source      IN VARCHAR2 DEFAULT NULL,  -- if applicable
   p_entity_pk1       IN VARCHAR2,               -- primary key
   p_entity_pk2       IN VARCHAR2 DEFAULT NULL,  -- primary key pt. 2
   p_party_id         IN NUMBER   DEFAULT NULL,  -- only pass if available
   x_viewable_flag    OUT NOCOPY VARCHAR2,       -- can we see it?
   x_updateable_flag  OUT NOCOPY VARCHAR2,       -- can we mess with it?
   x_deleteable_flag  OUT NOCOPY VARCHAR2        -- can we get rid of it?
);
*/

FUNCTION check_row_viewable (
   p_entity_name      IN VARCHAR2,               -- table name
   p_data_source      IN VARCHAR2 DEFAULT NULL,  -- if applicable
   p_entity_pk1       IN VARCHAR2,               -- primary key
   p_entity_pk2       IN VARCHAR2 DEFAULT NULL,  -- primary key pt. 2
   p_party_id         IN NUMBER   DEFAULT NULL,  -- only pass if available
   p_function_name    IN VARCHAR2 DEFAULT NULL   -- function name
) RETURN VARCHAR2;  -- "Y" or "N" if we can view the row

FUNCTION check_row_updateable (
   p_entity_name      IN VARCHAR2,               -- table name
   p_data_source      IN VARCHAR2 DEFAULT NULL,  -- if applicable
   p_entity_pk1       IN VARCHAR2,               -- primary key
   p_entity_pk2       IN VARCHAR2 DEFAULT NULL,  -- primary key pt. 2
   p_party_id         IN NUMBER   DEFAULT NULL,  -- only pass if available
   p_function_name    IN VARCHAR2 DEFAULT NULL   -- function name
) RETURN VARCHAR2;  -- "Y" or "N" if we can update the row

FUNCTION check_row_deleteable (
   p_entity_name      IN VARCHAR2,               -- table name
   p_data_source      IN VARCHAR2 DEFAULT NULL,  -- if applicable
   p_entity_pk1       IN VARCHAR2,               -- primary key
   p_entity_pk2       IN VARCHAR2 DEFAULT NULL,  -- primary key pt. 2
   p_party_id         IN NUMBER   DEFAULT NULL,  -- only pass if available
   p_function_name    IN VARCHAR2 DEFAULT NULL   -- function name
) RETURN VARCHAR2;  -- "Y" or "N" if we can delete the row

--------------------------------------
--------------------------------------
-- Column-Level Security Checks
--------------------------------------
--------------------------------------

PROCEDURE check_columns(
  p_entity_name     IN VARCHAR2,              -- table name
  p_data_source     IN VARCHAR2 DEFAULT NULL, -- if applicable
  p_entity_pk1      IN VARCHAR2,              -- primary key
  p_entity_pk2      IN VARCHAR2 DEFAULT NULL, -- primary key pt. 2
  p_party_id        IN NUMBER   DEFAULT NULL, -- only pass if available
  p_function_name   IN VARCHAR2 DEFAULT NULL, -- function name
  p_attribute_list  IN          HZ_MIXNM_UTILITY.INDEXVARCHAR30List, -- pl/sql table of attribute names
  p_value_is_null_list IN       HZ_MIXNM_UTILITY.INDEXVARCHAR1List, -- pl/sql table of flags
  x_viewable_list   OUT NOCOPY  HZ_MIXNM_UTILITY.INDEXVARCHAR1List, -- pl/sql table of flags
  x_updateable_list OUT NOCOPY  HZ_MIXNM_UTILITY.INDEXVARCHAR1List  -- pl/sql table of flags
);


/**
 * PROCEDURE get_value
 *
 * DESCRIPTION
 *    used by common party UI .
 *    will return various value
 * ARGUMENTS
 *   IN:
 *     p_org_contact_id          org contact id. If passed in, will return
 *                               org contact roles.
 *     p_phone_country_code      phone country code
 *     p_phone_area_code         phone area_code
 *     p_phone_number            phone number. If passed in, will return
 *                               formatted phone number.
 *     p_phone_extension         phone extension.
 *     p_phone_line_type         phone_line_type
 *     p_location_id             location id. If passed in, will return
 *                               formatted address.
 *     p_cust_acct_id            Cust account ID, returns the formatted bill_to address
 *     p_cust_acct_site_id       Cust account site ID, returns the formatted bill_to address
 */

  PROCEDURE get_value (
      p_org_contact_id              IN     VARCHAR2,
      p_phone_country_code          IN     VARCHAR2,
      p_phone_area_code             IN     VARCHAR2,
      p_phone_number                IN     VARCHAR2,
      p_phone_extension             IN     VARCHAR2,
      p_phone_line_type             IN     VARCHAR2,
      p_location_id                 IN     VARCHAR2,
      x_org_contact_roles           OUT    NOCOPY VARCHAR2,
      x_formatted_phone             OUT    NOCOPY VARCHAR2,
      x_formatted_address           OUT    NOCOPY VARCHAR2,
      p_act_cont_role_id            IN     VARCHAR2,
      x_act_contact_roles           OUT    NOCOPY VARCHAR2,
      p_primary_phone_contact_pt_id IN     NUMBER,
      x_has_contact_restriction     OUT    NOCOPY VARCHAR2,
      p_relationship_type_id        IN     NUMBER,
      p_relationship_group_code     IN     VARCHAR2,
      x_is_in_relationship_group    OUT    NOCOPY VARCHAR2,
      p_cust_acct_id                IN     VARCHAR2,
      x_billto_address              OUT    NOCOPY VARCHAR2,
      p_cust_acct_site_id           IN     VARCHAR2
);


END HZ_UI_UTIL_PKG;

 

/
