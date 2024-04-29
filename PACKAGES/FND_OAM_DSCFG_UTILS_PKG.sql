--------------------------------------------------------
--  DDL for Package FND_OAM_DSCFG_UTILS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_OAM_DSCFG_UTILS_PKG" AUTHID CURRENT_USER as
/* $Header: AFOAMDSCUTILS.pls 120.1 2005/12/19 09:47 ilawler noship $ */

   ---------------
   -- Constants --
   ---------------

   ---------------------------------
   -- Public Procedures/Functions --
   ---------------------------------

   -- Converts booleans to their canonical representation
   -- Invariants:
   --   None
   -- Parameters:
   --   p_boolean               Input boolean
   -- Returns:
   --   FND_API.G_TRUE for TRUE, FND_API.G_FALSE for FALSE.
   -- Exceptions:
   --   None
   FUNCTION BOOLEAN_TO_CANONICAL(p_boolean              IN BOOLEAN)
      RETURN VARCHAR2;

   -- Converts the canonical representation of booleans to actual booleans
   -- Invariants:
   --   None
   -- Parameters:
   --   p_canonical_value               Input boolean in canonical format
   -- Returns:
   --   TRUE for FND_API.G_TRUE, FALSE for FND_API.G_FALSE, exception VALUE_ERROR otherwise
   -- Exceptions:
   --   VALUE_ERROR - when the input is unmatched
   FUNCTION CANONICAL_TO_BOOLEAN(p_canonical_value      IN VARCHAR2)
      RETURN BOOLEAN;

   -- Converts a number to its canonical representation.  Uses FND_NUMBER.
   -- Invariants:
   --   None
   -- Parameters:
   --   p_number                The number
   -- Returns:
   --   The canonical representation.
   -- Exceptions:
   --   None
   FUNCTION NUMBER_TO_CANONICAL(p_number                IN NUMBER)
      RETURN VARCHAR2;

   -- Converts the canonical representation of numbers to actual numbers.  Uses FND_NUMBER.
   -- Invariants:
   --   None
   -- Parameters:
   --   p_canonical_value               Input number in canonical format
   -- Returns:
   --   A number.
   -- Exceptions:
   --   VALUE_ERROR - when the input is not a number.
   FUNCTION CANONICAL_TO_NUMBER(p_canonical_value       IN VARCHAR2)
      RETURN NUMBER;

   -- Converts a date to its canonical representation.  Uses FND_DATE.
   -- Invariants:
   --   None
   -- Parameters:
   --   p_number                The date
   -- Returns:
   --   The canonical representation.
   -- Exceptions:
   --   None
   FUNCTION DATE_TO_CANONICAL(p_date            IN DATE)
      RETURN VARCHAR2;

   -- Converts the canonical representation of dates to actual dates.  Uses FND_DATE.
   -- Invariants:
   --   None
   -- Parameters:
   --   p_canonical_value               Input date in canonical format
   -- Returns:
   --   A number.
   -- Exceptions:
   --   VALUE_ERROR - when the input is not a date.
   FUNCTION CANONICAL_TO_DATE(p_canonical_value         IN VARCHAR2)
      RETURN DATE;

   -- Looks up the owner for a table_name with no table_owner.
   -- Invariants:
   --   None
   -- Parameters:
   --   p_table_name            Table Name
   -- Returns:
   --   The table's owner
   -- Exceptions:
   --   NO_DATA_FOUND -- no table with that name
   --   TOO_MANY_ROWS -- more than one owner
   FUNCTION GET_TABLE_OWNER(p_table_name                IN VARCHAR2)
      RETURN VARCHAR2;

   -- Computes the weight of a given table.  Currently this is done by fetching the "blocks" field from dba_tables.
   -- Invariants:
   --   None
   -- Parameters:
   --   p_table_owner           Table Owner
   --   p_table_name            Table Name
   -- Returns:
   --   The weight
   -- Exceptions:
   --   NO_DATA_FOUND -- no table with that owner/name
   FUNCTION GET_TABLE_WEIGHT(p_table_owner      IN VARCHAR2,
                             p_table_name       IN VARCHAR2)
      RETURN NUMBER;

END FND_OAM_DSCFG_UTILS_PKG;

 

/
