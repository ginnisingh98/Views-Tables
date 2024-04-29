--------------------------------------------------------
--  DDL for Package FND_PLSQL_CACHE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_PLSQL_CACHE" AUTHID CURRENT_USER AS
/* $Header: AFUTPSCS.pls 120.1.12010000.1 2008/07/25 14:23:35 appldev ship $ */

-- ----------------------------------------------------------------------
-- PL/SQL Caching:
--
-- Basic caching idea in this package is a VALUE (One-to-One cache) or
--    0 or more VALUEs (One-to-Many cache) are cached for a KEY.
--
-- KEY's type is VARCHAR2(2000). In your application, if you have
--    composite key, you need to concatenate those composite keys and
--    pass in as a single varchar2 key. When you concatenate it is better
--    if a delimiter is used between keys.
--    Example : Consider following two different keys. Without delimiter
--    both keys appear to be same when concatenated.
--                                         Concatenated Key
--                                    w/o delimiter w/ delimiter
--                                   -------------- ------------
--       Key1 : 'AB', Key2 : 'CD'    'ABCD'         'AB.CD'
--       Key1 : 'A',  Key2 : 'BCD'   'ABCD'         'A.BCD'
--
-- VALUE can be the generic value defined in this package, or it can be
--    a custom RECORD defined in your package.
--
-- VALUEs is table of VALUE. It can be generic_values table defined in this
--    package, or a custom TABLE of RECORD defined in your package.
--
-- Type of VALUE:
--    Generic Cache: In this cache, the value type is generic_cache_value_type
--       which is a RECORD, and has 15 varchar2, 5 number, 3 date, and
--       3 boolean elements.
--
--    Custom Cache: In this cache, the value type is a custom RECORD defined
--       in your package.
--
-- Number of VALUEs per KEY:
--    One-to-One (1to1) Cache: In this cache, there is only one VALUE
--       for a KEY.
--
--    One-to-Many (1toM) Cache: In this cache, there may be 0 or more VALUEs
--       for a KEY.
--
-- Based on number of VALUEs and the type of VALUE, there are four different
--   caches provided in this package.
--
--        Generic         Custom
--        --------------- ---------------
--  1to1: generic_1to1_*  custom_1to1_*
--  1tom: generic_1tom_*  custom_1tom_*
--
-- Usage:
--    Please see procedure sample_package() in package body for usage examples.
--    The basic usage is
--    -- Initialize cache in your package initialization section.
--    -- Call GET function to get the VALUE for KEY
--    -- If KEY doesn't exist in cache, then get the VALUE from database
--          and PUT it in the cache. So that, in the next GET call, VALUE will
--          come from cache.
--

-- ----------------------------------------------------------------------
-- Return Codes.
--
CACHE_FOUND                   CONSTANT VARCHAR2(1) := '1';
CACHE_NOTFOUND                CONSTANT VARCHAR2(1) := '0';
CACHE_VALID                   CONSTANT VARCHAR2(1) := 'V';
CACHE_INVALID                 CONSTANT VARCHAR2(1) := 'I';

CACHE_PUT_IS_SUCCESSFUL       CONSTANT VARCHAR2(1) := 'P';
CACHE_IS_FULL                 CONSTANT VARCHAR2(1) := 'F';
CACHE_TOO_MANY_VALUES_PER_KEY CONSTANT VARCHAR2(1) := 'M';

-- ----------------------------------------------------------------------
-- Cache Debug Levels.
--
-- Only the cache summary is printed out
CDL_SUMMARY               CONSTANT VARCHAR2(30) := 'SUMMARY';

-- Cache summary, and keys are printed out
CDL_SUMMARY_KEYS          CONSTANT VARCHAR2(30) := 'SUMMARY_KEYS';

-- Cache summary, keys, and values (Generic) are printed out
CDL_SUMMARY_KEYS_VALUES   CONSTANT VARCHAR2(30) := 'SUMMARY_KEYS_VALUES';

-- ----------------------------------------------------------------------
-- Cache Types
--
CACHE_TYPE_GENERIC        CONSTANT VARCHAR2(30) := 'GENERIC';
CACHE_TYPE_CUSTOM         CONSTANT VARCHAR2(30) := 'CUSTOM';

-- ----------------------------------------------------------------------
-- Generic Cache Value. (like Object in Java, or void* in C.)
-- This is the value of (Key, Value) pair.
-- Used by generic_* functions.'
--
-- If you need more fields per value, please create a custom value type
-- and use custom_* functions.
--
TYPE generic_cache_value_type IS RECORD
  (varchar2_1  VARCHAR2(2000),  -- 15 varchar2 elements
   varchar2_2  VARCHAR2(2000),
   varchar2_3  VARCHAR2(2000),
   varchar2_4  VARCHAR2(2000),
   varchar2_5  VARCHAR2(2000),
   varchar2_6  VARCHAR2(2000),
   varchar2_7  VARCHAR2(2000),
   varchar2_8  VARCHAR2(2000),
   varchar2_9  VARCHAR2(2000),
   varchar2_10 VARCHAR2(2000),
   varchar2_11 VARCHAR2(2000),
   varchar2_12 VARCHAR2(2000),
   varchar2_13 VARCHAR2(2000),
   varchar2_14 VARCHAR2(2000),
   varchar2_15 VARCHAR2(2000),
   number_1    NUMBER,          -- 5 number elements
   number_2    NUMBER,
   number_3    NUMBER,
   number_4    NUMBER,
   number_5    NUMBER,
   date_1      DATE,            -- 3 date elements
   date_2      DATE,
   date_3      DATE,
   boolean_1   BOOLEAN,         -- 3 boolean elements
   boolean_2   BOOLEAN,
   boolean_3   BOOLEAN);

-- ----------------------------------------------------------------------
-- Array of generic cache values.
-- Used by generic_* functions.
--
TYPE generic_cache_values_type IS TABLE OF generic_cache_value_type
  INDEX BY BINARY_INTEGER;

-- ----------------------------------------------------------------------
-- Indexes of custom values.
-- Used by custom_* functions.
--
TYPE custom_cache_indexes_type IS TABLE OF BINARY_INTEGER
  INDEX BY BINARY_INTEGER;

-- ----------------------------------------------------------------------
-- Limits
--
-- CACHE_MAX_NUMOF_KEYS :
--    Keys are stored in a VARRAY(1024) of VARCHAR2(2048).
--    So the maximum number of keys is 1024.
--
-- CACHE_NUMOF_DIGITS_PER_INDEX :
--    Indexes are stored as base-10 numbers in a varchar2 variable.
--    Internally indexes are stored as concatenated. Each index occupies 4
--    chars of space. Absolute maximum is 9999. The practical max is 8000.
--    The concatenated string is stored in a varchar2(32000) variable.
--    Here is a sample concatenated indexes:
--    Concatenated : '1   2   30  40  500 600 700080009   '
--    Indexes      : '1,2,30,40,500,600,7000,8000,9'
--
-- CACHE_MAX_NUMOF_VALUES_PER_KEY :
--    Value indexes are stored in a VARRAY(1024) of VARCHAR2(2048).
--    So, for a given key we have 2048 bytes of storage for value indexes.
--    Each index takes 4 chars space, so we can have up to
--    2048/4=512 values per key.
--
-- CACHE_MAX_NUMOF_VALUES :
--    All available indexes are stored in a varchar2(32000) variable.
--    So the maximum number of indexes that can be stored in this variable
--    is 32000/4=8000. This is the maximum number of values that can be stored
--    in a 1tom cache.
--
CACHE_MAX_NUMOF_KEYS           CONSTANT NUMBER := 1024;
CACHE_NUMOF_DIGITS_PER_INDEX   CONSTANT NUMBER := 4;
CACHE_MAX_NUMOF_VALUES_PER_KEY CONSTANT NUMBER := 512;
CACHE_MAX_NUMOF_VALUES         CONSTANT NUMBER := 8000;

-- ----------------------------------------------------------------------
-- Auxiliary varrays for cache controller.
--
TYPE cache_varchar2_varray_type IS VARRAY(1024) OF VARCHAR2(2048);
TYPE cache_number_varray_type   IS VARRAY(1024) OF NUMBER;

-- ----------------------------------------------------------------------
-- One-to-One Cache Controller :
--   Keeps track of information about cache, and keys.
--   This cache is a simple one-to-one hash table lookup.
--
--   Following example shows the caching process.
--
--   Start-up:
--   Init('Country Capitals')
--     name                    : 'Country Capitals'
--     max_numof_keys          : 1024
--
--   Put('USA', 'Washington DC')        {say hash key is 23}
--
--     keys(23)                : 'USA'
--     values(23)              : 'Washington DC'
--
--   Put('Turkey', 'Ankara')            {say hash key is 34}
--
--     keys(34)                : 'Turkey'
--     values(34)              : 'Ankara'
--
--   Put('France', 'Paris')             {say hash key is 23}
--              Note that 23 was already in use. New entry will overwrite
--              the old entry. i.e. 'USA' entry is dropped from the cache.
--
--     keys(23)                : 'France'
--     values(23)              : 'Paris'
--
TYPE cache_1to1_controller_type IS RECORD
  (name                    VARCHAR2(30),                -- identifier
   cache_type              VARCHAR2(30),                -- GENERIC, or CUSTOM
   max_numof_keys          NUMBER,                      -- max # of keys
   numof_keys              NUMBER,                      -- # of keys
   keys                    cache_varchar2_varray_type); -- keys

-- ----------------------------------------------------------------------
-- One-to-Many Cache Controller :
--   Keeps track of information about cache, keys, and corresponding
--   indexes in the value array for the values of a key.
--
--   This cache is designed so that any number of elements can be cached
--   for a given key. Basically result set of the SELECT statement is
--   cached (and SELECT can return 0, 1, or more rows.)
--
--   Following example shows the caching process.
--
--   Start-up:
--   Init('Courses for a given student.')
--     name                    : 'Courses for a given student.'
--     max_numof_keys          : 1024
--     available_indexes       : '1,2,3,4,5,6,7,8,9,10,...'
--
--   Put('Bill Gates', ['Math', 'C Prog', 'Chem'])       {say hash key is 23}
--
--     keys(23)                : 'Bill Gates'
--     numof_indexes(23)       : 3
--     value_indexes(23)       : '1,2,3,'
--     available_indexes       : '4,5,6,7,8,9,10,...'
--
--     values(1)               : 'Math'
--     values(2)               : 'C Prog'
--     values(3)               : 'Chem'
--
--   Put('Bill Clinton', ['Law', 'History','Economy'])   {say hash key is 34}
--
--     keys(34)                : 'Bill Clinton'
--     numof_indexes(34)       : 3
--     value_indexes(34)       : '4,5,6,'
--     available_indexes       : '7,8,9,10,...'
--
--     values(4)               : 'Law'
--     values(5)               : 'History'
--     values(6)               : 'Economy'
--
--   Put('Larry Ellison', ['Science'])                   {say hash key is 23}
--              Note that 23 was already in use. New entry will overwrite the
--              old entry. Old entry's indexes are returned to available list.
--              i.e. 'Bill Gates' entry is dropped from the cache.
--
--     keys(23)                : 'Larry Ellison'
--     numof_indexes(23)       : 1
--     value_indexes(23)       : '1,'
--     available_indexes       : '2,3,7,8,9,10,...'
--
--     values(1)               : 'Science'
--
TYPE cache_1tom_controller_type IS RECORD
  (name                    VARCHAR2(30),                -- identifier
   cache_type              VARCHAR2(30),                -- GENERIC, or CUSTOM
   max_numof_keys          NUMBER,                      -- max # of keys
   numof_keys              NUMBER,                      -- # of keys
   keys                    cache_varchar2_varray_type,  -- keys
   numof_values            NUMBER,                      -- # of values

   numof_indexes           cache_number_varray_type,    -- # of values per key
   value_indexes           cache_varchar2_varray_type,  -- value indexes
   numof_available_indexes NUMBER,                      -- remaining # of idxs
   maxof_available_indexes NUMBER,                      -- max of indexes
   available_indexes       VARCHAR2(32000));            -- free indexes.

-- ----------------------------------------------------------------------
-- New generic cache value.
-- ----------------------------------------------------------------------
PROCEDURE generic_cache_new_value
  (x_value       OUT nocopy generic_cache_value_type,
   p_varchar2_1  IN VARCHAR2 DEFAULT NULL,
   p_varchar2_2  IN VARCHAR2 DEFAULT NULL,
   p_varchar2_3  IN VARCHAR2 DEFAULT NULL,
   p_varchar2_4  IN VARCHAR2 DEFAULT NULL,
   p_varchar2_5  IN VARCHAR2 DEFAULT NULL,
   p_varchar2_6  IN VARCHAR2 DEFAULT NULL,
   p_varchar2_7  IN VARCHAR2 DEFAULT NULL,
   p_varchar2_8  IN VARCHAR2 DEFAULT NULL,
   p_varchar2_9  IN VARCHAR2 DEFAULT NULL,
   p_varchar2_10 IN VARCHAR2 DEFAULT NULL,
   p_varchar2_11 IN VARCHAR2 DEFAULT NULL,
   p_varchar2_12 IN VARCHAR2 DEFAULT NULL,
   p_varchar2_13 IN VARCHAR2 DEFAULT NULL,
   p_varchar2_14 IN VARCHAR2 DEFAULT NULL,
   p_varchar2_15 IN VARCHAR2 DEFAULT NULL,
   p_number_1    IN NUMBER DEFAULT NULL,
   p_number_2    IN NUMBER DEFAULT NULL,
   p_number_3    IN NUMBER DEFAULT NULL,
   p_number_4    IN NUMBER DEFAULT NULL,
   p_number_5    IN NUMBER DEFAULT NULL,
   p_date_1      IN DATE DEFAULT NULL,
   p_date_2      IN DATE DEFAULT NULL,
   p_date_3      IN DATE DEFAULT NULL,
   p_boolean_1   IN BOOLEAN DEFAULT NULL,
   p_boolean_2   IN BOOLEAN DEFAULT NULL,
   p_boolean_3   IN BOOLEAN DEFAULT NULL);

FUNCTION generic_cache_new_value
  (p_varchar2_1  IN VARCHAR2 DEFAULT NULL,
   p_varchar2_2  IN VARCHAR2 DEFAULT NULL,
   p_varchar2_3  IN VARCHAR2 DEFAULT NULL,
   p_varchar2_4  IN VARCHAR2 DEFAULT NULL,
   p_varchar2_5  IN VARCHAR2 DEFAULT NULL,
   p_varchar2_6  IN VARCHAR2 DEFAULT NULL,
   p_varchar2_7  IN VARCHAR2 DEFAULT NULL,
   p_varchar2_8  IN VARCHAR2 DEFAULT NULL,
   p_varchar2_9  IN VARCHAR2 DEFAULT NULL,
   p_varchar2_10 IN VARCHAR2 DEFAULT NULL,
   p_varchar2_11 IN VARCHAR2 DEFAULT NULL,
   p_varchar2_12 IN VARCHAR2 DEFAULT NULL,
   p_varchar2_13 IN VARCHAR2 DEFAULT NULL,
   p_varchar2_14 IN VARCHAR2 DEFAULT NULL,
   p_varchar2_15 IN VARCHAR2 DEFAULT NULL,
   p_number_1    IN NUMBER DEFAULT NULL,
   p_number_2    IN NUMBER DEFAULT NULL,
   p_number_3    IN NUMBER DEFAULT NULL,
   p_number_4    IN NUMBER DEFAULT NULL,
   p_number_5    IN NUMBER DEFAULT NULL,
   p_date_1      IN DATE DEFAULT NULL,
   p_date_2      IN DATE DEFAULT NULL,
   p_date_3      IN DATE DEFAULT NULL,
   p_boolean_1   IN BOOLEAN DEFAULT NULL,
   p_boolean_2   IN BOOLEAN DEFAULT NULL,
   p_boolean_3   IN BOOLEAN DEFAULT NULL)
  RETURN generic_cache_value_type;


-- ======================================================================
-- Generic 1to1 Cache:
--    One Value per Key. Value type is generic_cache_value_type.
--
-- In generic 1to1 cache, key is stored in the controller, and the
-- value is stored in the value storage array.
-- ======================================================================
-- ----------------------------------------------------------------------
-- Initialize the generic_1to1 cache.
--
-- This procedure should be called in package initialization section.
--
-- @param p_name - Name of the cache
-- @param px_controller - 1to1 controller for this cache
-- @param px_storage - Storage array for the values
-- @param p_max_numof_keys - Maximum number of keys. Must be power of 2.
--                         1 <= p_max_numof_keys <= CACHE_MAX_NUMOF_KEYS
--
-- For usage example, please see sample_package() procedure in the body.
-- ----------------------------------------------------------------------
PROCEDURE generic_1to1_init
  (p_name             IN VARCHAR2,
   px_controller      IN OUT nocopy cache_1to1_controller_type,
   px_storage         IN OUT nocopy generic_cache_values_type,
   p_max_numof_keys   IN NUMBER DEFAULT CACHE_MAX_NUMOF_KEYS);

-- ----------------------------------------------------------------------
-- Get value
--
-- For a given key, this procedure returns the value.
--
-- @param px_controller - 1to1 controller for this cache
-- @param px_storage - Storage array for the values
-- @param p_key - Key
-- @param x_value - Value
-- @param x_return_code - Return code. See CACHE_* constants above.
--
-- For usage example, please see sample_package() procedure in the body.
-- ----------------------------------------------------------------------
PROCEDURE generic_1to1_get_value
  (px_controller      IN OUT nocopy cache_1to1_controller_type,
   px_storage         IN OUT nocopy generic_cache_values_type,
   p_key              IN VARCHAR2,
   x_value            OUT nocopy generic_cache_value_type,
   x_return_code      OUT nocopy VARCHAR2);

-- ----------------------------------------------------------------------
-- Put value
--
-- For a given key, this procedure puts the value in cache.
--
-- @param px_controller - 1to1 controller for this cache
-- @param px_storage - Storage array for the values
-- @param p_key - Key
-- @param p_value - Value
--
-- For usage example, please see sample_package() procedure in the body.
-- ----------------------------------------------------------------------
PROCEDURE generic_1to1_put_value
  (px_controller      IN OUT nocopy cache_1to1_controller_type,
   px_storage         IN OUT nocopy generic_cache_values_type,
   p_key              IN VARCHAR2,
   p_value            IN generic_cache_value_type);

-- ----------------------------------------------------------------------
-- Remove key
--
-- For a given key, this procedure removes the key from the cache.
--
-- @param px_controller - 1to1 controller for this cache
-- @param p_key - Key
-- ----------------------------------------------------------------------
PROCEDURE generic_1to1_remove_key
  (px_controller      IN OUT nocopy cache_1to1_controller_type,
   p_key              IN VARCHAR2);

-- ----------------------------------------------------------------------
-- Clears the cache.
--
-- @param px_controller - 1to1 controller for this cache
-- @param px_storage - Storage array for the values
-- ----------------------------------------------------------------------
PROCEDURE generic_1to1_clear
  (px_controller      IN OUT nocopy cache_1to1_controller_type,
   px_storage         IN OUT nocopy generic_cache_values_type);

-- ----------------------------------------------------------------------
-- Debugs the cache.
--
-- @param px_controller - 1to1 controller for this cache
-- @param px_storage - Storage array for the values
-- @param p_debug_level - Debug level, see CDL_* constants above
-- ----------------------------------------------------------------------
PROCEDURE generic_1to1_debug
  (px_controller      IN cache_1to1_controller_type,
   px_storage         IN generic_cache_values_type,
   p_debug_level      IN VARCHAR2 DEFAULT CDL_SUMMARY_KEYS_VALUES);


-- ======================================================================
-- Generic 1toM Cache:
--    Many Values per Key. Value type is generic_cache_value_type.
--
-- In generic 1toM cache, key is stored in the controller, and the
-- values are stored in the value storage array.
-- ======================================================================
-- ----------------------------------------------------------------------
-- Initialize the generic_1tom cace.
--
-- This procedure should be called in package initialization section.
--
-- @param p_name - Name of the cache
-- @param px_controller - 1tom controller for this cache
-- @param px_storage - Storage array for the values
-- @param p_max_numof_keys - Maximum number of keys. Must be power of 2.
--                         1 <= p_max_numof_keys <= CACHE_MAX_NUMOF_KEYS
--
-- For usage example, please see sample_package() procedure in the body.
-- ----------------------------------------------------------------------
PROCEDURE generic_1tom_init
  (p_name             IN VARCHAR2,
   px_controller      IN OUT nocopy cache_1tom_controller_type,
   px_storage         IN OUT nocopy generic_cache_values_type,
   p_max_numof_keys   IN NUMBER DEFAULT CACHE_MAX_NUMOF_KEYS);

-- ----------------------------------------------------------------------
-- Get values
--
-- For a given key, this procedure returns the values.
--
-- @param px_controller - 1tom controller for this cache
-- @param px_storage - Storage array for the values
-- @param p_key - Key
-- @param x_numof_values - Number of values
--                       0 <= x_numof_values <= CACHE_MAX_NUMOF_VALUES_PER_KEY
-- @param x_values - Values
-- @param x_return_code - Return code. See CACHE_* constants above.
--
-- For usage example, please see sample_package() procedure in the body.
-- ----------------------------------------------------------------------
PROCEDURE generic_1tom_get_values
  (px_controller      IN OUT nocopy cache_1tom_controller_type,
   px_storage         IN OUT nocopy generic_cache_values_type,
   p_key              IN VARCHAR2,
   x_numof_values     OUT nocopy NUMBER,
   x_values           OUT nocopy generic_cache_values_type,
   x_return_code      OUT nocopy VARCHAR2);

-- ----------------------------------------------------------------------
-- Put values
--
-- For a given key, this procedure puts the values in cache.
--
-- @param px_controller - 1tom controller for this cache
-- @param px_storage - Storage array for the values
-- @param p_key - Key
-- @param p_numof_values - Number of values
--                       0 <= p_numof_values <= CACHE_MAX_NUMOF_VALUES_PER_KEY
-- @param p_values - Values
--
-- For usage example, please see sample_package() procedure in the body.
-- ----------------------------------------------------------------------
PROCEDURE generic_1tom_put_values
  (px_controller      IN OUT nocopy cache_1tom_controller_type,
   px_storage         IN OUT nocopy generic_cache_values_type,
   p_key              IN VARCHAR2,
   p_numof_values     IN NUMBER,
   p_values           IN generic_cache_values_type);

-- ----------------------------------------------------------------------
-- Remove key
--
-- For a given key, this function removes the key from the cache.
--
-- @param px_controller - 1tom controller for this cache
-- @param p_key - Key
-- ----------------------------------------------------------------------
PROCEDURE generic_1tom_remove_key
  (px_controller      IN OUT nocopy cache_1tom_controller_type,
   p_key              IN VARCHAR2);

-- ----------------------------------------------------------------------
-- Clears the cache.
--
-- @param px_controller - 1tom controller for this cache
-- @param px_storage - Storage array for the values
-- ----------------------------------------------------------------------
PROCEDURE generic_1tom_clear
  (px_controller      IN OUT nocopy cache_1tom_controller_type,
   px_storage         IN OUT nocopy generic_cache_values_type);

-- ----------------------------------------------------------------------
-- Debugs the cache.
--
-- @param px_controller - 1tom controller for this cache
-- @param px_storage - Storage array for the values
-- @param p_debug_level - Debug level, see CDL_* constants above
-- ----------------------------------------------------------------------
PROCEDURE generic_1tom_debug
  (px_controller      IN cache_1tom_controller_type,
   px_storage         IN generic_cache_values_type,
   p_debug_level      IN VARCHAR2 DEFAULT CDL_SUMMARY_KEYS_VALUES);


-- ======================================================================
-- Custom One Cache:
--    One Value per Key. Value type is custom.
--
-- In custom_1to1 cache, key is stored in the controller,
-- and value is stored in a custom TABLE OF _RECORD_.
-- ======================================================================
-- ----------------------------------------------------------------------
-- Initialize the custom_1to1 cache.
--
-- This procedure should be called in package initialization section.
--
-- @param p_name - Name of the cache
-- @param px_controller - 1to1 controller for this cache
-- @param p_max_numof_keys - Maximum number of keys. Must be power of 2.
--                         1 <= p_max_numof_keys <= CACHE_MAX_NUMOF_KEYS
--
-- For usage example, please see sample_package() procedure in the body.
-- ----------------------------------------------------------------------
PROCEDURE custom_1to1_init
  (p_name             IN VARCHAR2,
   px_controller      IN OUT nocopy cache_1to1_controller_type,
   p_max_numof_keys   IN NUMBER DEFAULT CACHE_MAX_NUMOF_KEYS);

-- ----------------------------------------------------------------------
-- Getter for index used in get operation.
--
-- For a given key, this procedure returns the index to the VALUE. Then
--    the actual value should be get using this index.
--
-- @param px_controller - 1to1 controller for this cache
-- @param p_key - Key
-- @param x_index - Index to the value
-- @param x_return_code - Return code. See CACHE_* constants above.
--
-- For usage example, please see sample_package() procedure in the body.
-- ----------------------------------------------------------------------
PROCEDURE custom_1to1_get_get_index
  (px_controller      IN OUT nocopy cache_1to1_controller_type,
   p_key              IN VARCHAR2,
   x_index            OUT nocopy BINARY_INTEGER,
   x_return_code      OUT nocopy VARCHAR2);

-- ----------------------------------------------------------------------
-- Getter for index used in put operations.
--
-- For a given key, this procedure returns the index to the VALUE. Then
--    the actual value should be put using this index.
--
-- @param px_controller - 1to1 controller for this cache
-- @param p_key - Key
-- @param x_index - Index to the value
--
-- For usage example, please see sample_package() procedure in the body.
-- ----------------------------------------------------------------------
PROCEDURE custom_1to1_get_put_index
  (px_controller      IN OUT nocopy cache_1to1_controller_type,
   p_key              IN VARCHAR2,
   x_index            OUT nocopy BINARY_INTEGER);

-- ----------------------------------------------------------------------
-- Remove key
--
-- For a given key, this procedure removes the key from the cache.
--
-- @param px_controller - 1to1 controller for this cache
-- @param p_key - Key
-- ----------------------------------------------------------------------
PROCEDURE custom_1to1_remove_key
  (px_controller      IN OUT nocopy cache_1to1_controller_type,
   p_key              IN VARCHAR2);

-- ----------------------------------------------------------------------
-- Clears the cache.
--
-- @param px_controller - 1to1 controller for this cache
-- ----------------------------------------------------------------------
PROCEDURE custom_1to1_clear
  (px_controller      IN OUT nocopy cache_1to1_controller_type);

-- ----------------------------------------------------------------------
-- Debugs the cache.
--
-- @param px_controller - 1to1 controller for this cache
-- @param p_debug_level - Debug level, see CDL_* constants above
-- ----------------------------------------------------------------------
PROCEDURE custom_1to1_debug
  (px_controller      IN cache_1to1_controller_type,
   p_debug_level      IN VARCHAR2 DEFAULT CDL_SUMMARY_KEYS_VALUES);


-- ======================================================================
-- Custom 1toM Cache:
--    Many Values per Key. Value type is custom.
--
-- In custom_1tom cache, key is stored in the controller,
-- and values are stored in a custom TABLE OF _RECORD_.
-- ======================================================================
-- ----------------------------------------------------------------------
-- Initialize the custom 1toM cache.
--
-- This procedure should be called in package initialization section.
--
-- @param p_name - Name of the cache
-- @param px_controller - 1tom controller for this cache
-- @param p_max_numof_keys - Maximum number of keys. Must be power of 2.
--                         1 <= p_max_numof_keys <= CACHE_MAX_NUMOF_KEYS
--
-- For usage example, please see sample_package() procedure in the body.
-- ----------------------------------------------------------------------
PROCEDURE custom_1tom_init
  (p_name             IN VARCHAR2,
   px_controller      IN OUT nocopy cache_1tom_controller_type,
   p_max_numof_keys   IN NUMBER DEFAULT CACHE_MAX_NUMOF_KEYS);

-- ----------------------------------------------------------------------
-- Getter for indexes used in get operations.
--
-- For a given key, this procedure returns how many values are cached
--    {x_numof_indexes} and indexes {x_indexes} to those values in the
--    cache table. Then these values should be get using the indexes.
--
-- @param px_controller - 1tom controller for this cache
-- @param p_key - Key
-- @param x_numof_indexes - Number of indexes
--                        0 <= x_numof_indexes <= CACHE_MAX_NUMOF_VALUES_PER_KEY
-- @param x_indexes - Indexes to the values
-- @param x_return_code - Return code. See CACHE_* constants above.
--
-- For usage example, please see sample_package() procedure in the body.
-- ----------------------------------------------------------------------
PROCEDURE custom_1tom_get_get_indexes
  (px_controller      IN OUT nocopy cache_1tom_controller_type,
   p_key              IN VARCHAR2,
   x_numof_indexes    OUT nocopy NUMBER,
   x_indexes          OUT nocopy custom_cache_indexes_type,
   x_return_code      OUT nocopy VARCHAR2);

-- ----------------------------------------------------------------------
-- Getter for indexes used in put operations.
--
-- For a given key, this function takes how many values will be cached
--    {p_numof_indexes} and returns the indexes {x_indexes} that these values
--    should be put in the cache table. Then the actual values should be put
--    using these indexes.
--
-- @param px_controller - 1tom controller for this cache
-- @param p_key - Key
-- @param p_numof_indexes - Number of indexes
--                        0 <= p_numof_indexes <= CACHE_MAX_NUMOF_VALUES_PER_KEY
-- @param x_indexes - Indexes to the values
-- @param x_return_code - Return code. See CACHE_* constants above.
--
-- For usage example, please see sample_package() procedure in the body.
-- ----------------------------------------------------------------------
PROCEDURE custom_1tom_get_put_indexes
  (px_controller      IN OUT nocopy cache_1tom_controller_type,
   p_key              IN VARCHAR2,
   p_numof_indexes    IN NUMBER,
   x_indexes          OUT nocopy custom_cache_indexes_type,
   x_return_code      OUT nocopy VARCHAR2);

-- ----------------------------------------------------------------------
-- Remove key
--
-- For a given key, this function removes the key from the cache.
--
-- @param px_controller - 1tom controller for this cache
-- @param p_key - Key
-- ----------------------------------------------------------------------
PROCEDURE custom_1tom_remove_key
  (px_controller      IN OUT nocopy cache_1tom_controller_type,
   p_key              IN VARCHAR2);

-- ----------------------------------------------------------------------
-- Clears the cache.
--
-- @param px_controller - 1tom controller for this cache
-- ----------------------------------------------------------------------
PROCEDURE custom_1tom_clear
  (px_controller      IN OUT nocopy cache_1tom_controller_type);

-- ----------------------------------------------------------------------
-- Debugs the cache.
--
-- @param px_controller - 1tom controller for this cache
-- @param p_debug_level - Debug level, see CDL_* constants above
-- ----------------------------------------------------------------------
PROCEDURE custom_1tom_debug
  (px_controller      IN cache_1tom_controller_type,
   p_debug_level      IN VARCHAR2 DEFAULT CDL_SUMMARY_KEYS_VALUES);


-- ----------------------------------------------------------------------
-- Test the cache
-- ----------------------------------------------------------------------
PROCEDURE test;

END fnd_plsql_cache;

/
