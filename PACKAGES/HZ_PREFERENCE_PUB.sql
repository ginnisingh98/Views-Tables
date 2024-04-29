--------------------------------------------------------
--  DDL for Package HZ_PREFERENCE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_PREFERENCE_PUB" AUTHID CURRENT_USER AS
/*$Header: ARHPREFS.pls 120.2 2005/06/16 21:14:27 jhuang noship $ */

TYPE ref_cursor_typ IS REF CURSOR;


----------------------------------------------------------------
-- API name  : Contains_Preference
-- TYPE      : Public
-- FUNCTION  : Determines whether a particular preference
--             (not a particular value) has been set
--
-- Parameters:
--     IN    : p_party_id IN NUMBER (required)
--             Party on which the preference should be checked
--
--             p_category IN VARCHAR2(required)
--             Preference category for identifying a particular
--             preference
--
--             p_preference_code IN VARCHAR2 (required)
--             Preference to check
--
--     OUT  NOCOPY :
--             RETURNs 1 byte result code:
--                   'Y'  preference has been set.
--                   'N'  not exist.
--                   'E'  Error
--                   'U'  Unexpected Error
--
--                If 'E' or 'U' is returned, there will be an
--                error message on the FND_MESSAGE stack which
--                can be retrieved with FND_MESSAGE.GET_ENCODED()
--
-- Notes  : This just checks for presence of given preference
--          for any value.
--
---------------------------------------------------------------
FUNCTION Contains_Preference(
  p_party_id              NUMBER
, p_category              VARCHAR2
, p_preference_code       VARCHAR2
) RETURN VARCHAR2;


----------------------------------------------------------------
-- API name  : Contains_Value
-- TYPE      : Public
-- FUNCTION  : Determines whether a particular preference value
--             has been set
--
-- Parameters:
--     IN    : p_party_id IN  NUMBER (required)
--             Party on which the preference should be checked
--
--             p_category IN VARCHAR2(required)
--             Preference category for identifying a particular
--             preference
--
--             p_preference_code IN VARCHAR2 (required)
--             Preference code for identifying a particular
--             preference
--
--             p_value_varchar2 IN VARCHAR2 (optional)
--             value to be checked
--
--             p_value_number IN NUMBER (optional)
--             value to be checked
--
--             p_value_date IN DATE (optional)
--             value to be checked
--
--     OUT  NOCOPY :
--             RETURNs 1 byte result code:
--                   'Y'  preference value exists.
--                   'N'  not exist.
--                   'E'  Error
--                   'U'  Unexpected Error
--
--                If 'E' or 'U' is returned, there will be an
--                error message on the FND_MESSAGE stack which
--                can be retrieved with FND_MESSAGE.GET_ENCODED()
--
-- Notes  : One of the parameters: p_value_varchar2,
--          p_value_number, p_value_date must be passed
--
---------------------------------------------------------------
FUNCTION Contains_Value(
  p_party_id              NUMBER
, p_category              VARCHAR2
, p_preference_code       VARCHAR2
, p_value_varchar2        VARCHAR2 := FND_API.G_MISS_CHAR
, p_value_number          NUMBER   := FND_API.G_MISS_NUM
, p_value_date            DATE     := FND_API.G_MISS_DATE
) RETURN VARCHAR2;


----------------------------------------------------------------
-- API name  : Add
-- TYPE      : Public
-- FUNCTION  : Add a preference value for a party.
--             For a single value preference, add if the
--             preference has not been defined.
--             For a multiple value preference, add if the
--             preference value has not been defined.
--
-- Parameters:
--     IN    : p_party_id IN NUMBER (required)
--             Party on which the preference value will be added
--
--             p_category IN VARCHAR2(required)
--             Preference category for identifying a particular
--             preference
--
--             p_preference_code IN VARCHAR2 (required)
--             Preference code for identifying a particular
--             preference
--
--             p_value_varchar2 IN VARCHAR2 (optional)
--             Value to be addded
--
--             p_value_number IN NUMBER (optional)
--             Value to be added
--
--             p_value_date IN DATE (optional)
--             Value to be added
--
--             p_value_name IN VARCHAR2 (optional)
--             User-defined name for a preference value
--
--             p_additional_value[1-5] IN VARCHAR2 (optional)
--             Additional values for a particular preference value
--
--     OUT  NOCOPY :
--             x_return_status 1 byte result code:
--                'S'  Success
--                'E'  Error
--                'U'  Unexpected Error
--
--             x_msg_count
--             Number of messages in message stack
--                If 'E' or 'U' is returned, there will be an
--                error message on the FND_MESSAGE stack which
--                can be retrieved with FND_MESSAGE.GET_ENCODED()
--
--             x_msg_data
--             The first message in the FND_MESSAGE stack
--
--             x_object_version_number
--             Version number of the record created
--
-- Notes  :
--
--
---------------------------------------------------------------
PROCEDURE  Add(
  p_party_id              NUMBER
, p_category              VARCHAR2
, p_preference_code       VARCHAR2
, p_value_varchar2        VARCHAR2 := FND_API.G_MISS_CHAR
, p_value_number          NUMBER   := FND_API.G_MISS_NUM
, p_value_date            DATE     := FND_API.G_MISS_DATE
, p_value_name            VARCHAR2 := FND_API.G_MISS_CHAR
, p_module                VARCHAR2 := FND_API.G_MISS_CHAR
, p_additional_value1     VARCHAR2 := FND_API.G_MISS_CHAR
, p_additional_value2     VARCHAR2 := FND_API.G_MISS_CHAR
, p_additional_value3     VARCHAR2 := FND_API.G_MISS_CHAR
, p_additional_value4     VARCHAR2 := FND_API.G_MISS_CHAR
, p_additional_value5     VARCHAR2 := FND_API.G_MISS_CHAR
, x_return_status         OUT NOCOPY VARCHAR2
, x_msg_count             OUT NOCOPY NUMBER
, x_msg_data              OUT NOCOPY VARCHAR2
, x_object_version_number OUT NOCOPY NUMBER
);


----------------------------------------------------------------
-- API name  : Put
-- TYPE      : Public
-- FUNCTION  : Ensure a preference value set for a party.
--             For a single value preference, the value will
--             be added if the preference has not been set.
--             The existing value can be updated if
--             a preference already exists
--             For a multiple value preference, the value will
--             be added if the preference value does not exist.
--             The information related to the existing preference
--             value can be updated if a preference value
--             already exists
-- Parameters:
--     IN    : p_party_id IN NUMBER (required)
--             Party on which the preference value will be added
--
--             p_category IN VARCHAR2(required)
--             Preference category for identifying a particular
--             preference
--
--             p_preference_code IN VARCHAR2 (required)
--             Preference code for identifying a particular
--             preference
--
--             p_value_varchar2 IN VARCHAR2 (optional)
--             Value to be addded
--
--             p_value_number IN NUMBER (optional)
--             Value to be added
--
--             p_value_date IN DATE (optional)
--             Value to be added
--
--             p_value_name IN VARCHAR2 (optional)
--             User-defined name for a preference value
--
--             p_ additional_value[1-5] IN VARCHAR2 (optional)
--             Additional values for a particular preference value
--
--     OUT  NOCOPY :
--             x_return_status 1 byte result code:
--                'S'  Success
--                'E'  Error
--                'U'  Unexpected Error
--
--             x_msg_count
--             Number of messages in message stack
--                If 'E' or 'U' is returned, there will be an
--                error message on the FND_MESSAGE stack which
--                can be retrieved with FND_MESSAGE.GET_ENCODED()
--             x_msg_data
--             The first message in the FND_MESSAGE stack
--
--     IN OUT NOCOPY :
--             x_object_version_number
--               Needed for checking whether record has already
--               been updated by some other user during update.
--               The new version number is returned in case of
--               insert or update.
--
-- Notes  :
--
--
---------------------------------------------------------------
PROCEDURE Put(
  p_party_id              NUMBER
, p_category              VARCHAR2
, p_preference_code       VARCHAR2
, p_value_varchar2        VARCHAR2 := FND_API.G_MISS_CHAR
, p_value_number          NUMBER   := FND_API.G_MISS_NUM
, p_value_date            DATE     := FND_API.G_MISS_DATE
, p_value_name            VARCHAR2 := FND_API.G_MISS_CHAR
, p_module                VARCHAR2 := FND_API.G_MISS_CHAR
, p_additional_value1     VARCHAR2 := FND_API.G_MISS_CHAR
, p_additional_value2     VARCHAR2 := FND_API.G_MISS_CHAR
, p_additional_value3     VARCHAR2 := FND_API.G_MISS_CHAR
, p_additional_value4     VARCHAR2 := FND_API.G_MISS_CHAR
, p_additional_value5     VARCHAR2 := FND_API.G_MISS_CHAR
, p_object_version_number IN OUT NOCOPY NUMBER
, x_return_status            OUT NOCOPY VARCHAR2
, x_msg_count                OUT NOCOPY NUMBER
, x_msg_data                 OUT NOCOPY VARCHAR2
);


----------------------------------------------------------------
-- API name  : Remove
-- TYPE      : Public
-- FUNCTION  : Remove preference values defined for a party.
--             For a single value preference, the value will
--             be removed if you don't specify a value or
--             the value specified is the defined value.
--             For a multiple value preference, all value will
--             be removed if you don't specify a value.
--             A value will be removed if you specify the value
--             you want to remove.
-- Parameters:
--     IN    : p_party_id IN NUMBER (required)
--             Party on which the preference value will be added
--
--             p_category IN VARCHAR2(required)
--             Preference category for identifying a particular
--             preference
--
--             p_preference_code IN VARCHAR2 (required)
--             Preference code for identifying a particular
--             preference
--
--             p_value_varchar2 IN VARCHAR2 (optional)
--             Value to be addded
--
--             p_value_number IN NUMBER (optional)
--             Value to be added
--
--             p_value_date IN DATE (optional)
--             Value to be added
--
--             p_object_version_number
--             Version number used in case removing particular
--             preference value.
--
--     OUT  NOCOPY :
--             x_return_status 1 byte result code:
--                'S'  Success
--                'E'  Error
--                'U'  Unexpected Error
--
--             x_msg_count
--             Number of messages in message stack
--                If 'E' or 'U' is returned, there will be an
--                error message on the FND_MESSAGE stack which
--                can be retrieved with FND_MESSAGE.GET_ENCODED()
--             x_msg_data
--             The first message in the FND_MESSAGE stack
--
-- Notes  :    Version number cannot be used in case of removing
--             all the values since different records may have
--             different version numbers
--
--
---------------------------------------------------------------
PROCEDURE Remove(
  p_party_id              NUMBER
, p_category              VARCHAR2
, p_preference_code       VARCHAR2
, p_value_varchar2        VARCHAR2 := FND_API.G_MISS_CHAR
, p_value_number          NUMBER   := FND_API.G_MISS_NUM
, p_value_date            DATE     := FND_API.G_MISS_DATE
, p_object_version_number NUMBER
, x_return_status         OUT NOCOPY VARCHAR2
, x_msg_count             OUT NOCOPY NUMBER
, x_msg_data              OUT NOCOPY VARCHAR2
);


----------------------------------------------------------------
-- API name  : Retrieve
-- TYPE      : Public
-- FUNCTION  : Retrieve preference values defined for a party.
--             The values will be retrieved as a reference cursor
--             It is designed for the middle tier Java program
--             to retrieve data from server without resetting
--             the values into a local structure such as Vector
--             or Array.
--
-- Parameters:
--     IN    : p_party_id IN NUMBER (required)
--             Party on which the preference value will be added
--
--             p_category IN VARCHAR2(required)
--             Preference category for identifying a particular
--             preference
--
--             p_preference_code IN VARCHAR2 (required)
--             Preference code for identifying a particular
--             preference
--
--     OUT  NOCOPY :  x_preference_values
--             A reference cursor returns preference values of
--             a particular preference code for a party.
--
--             x_return_status 1 byte result code:
--                'S'  Success
--                'E'  Error
--                'U'  Unexpected Error
--
--             x_msg_count
--             Number of messages in message stack
--                If 'E' or 'U' is returned, there will be an
--                error message on the FND_MESSAGE stack which
--                can be retrieved with FND_MESSAGE.GET_ENCODED()
--             x_msg_data
--             The first message in the FND_MESSAGE stack
--
-- Notes  :
--
--
---------------------------------------------------------------
PROCEDURE Retrieve(
  p_party_id            NUMBER
, p_category            VARCHAR2
, p_preference_code     VARCHAR2
, x_preference_value    OUT NOCOPY ref_cursor_typ
, x_return_status       OUT NOCOPY VARCHAR2
, x_msg_count           OUT NOCOPY NUMBER
, x_msg_data            OUT NOCOPY VARCHAR2
);


----------------------------------------------------------------
-- API name  : Value_Varchar2
-- TYPE      : Public
-- FUNCTION  : Returns value_varchar2 value for a preference
--
-- Parameters:
--     IN    : p_party_id IN NUMBER (required)
--             Party on which the preference should be checked
--
--             p_category IN VARCHAR2(required)
--             Preference category for identifying a particular
--             preference
--
--             p_preference_code IN VARCHAR2 (required)
--             Preference to check
--
--     OUT  NOCOPY :
--             Returns VARCHAR2
--
--                If there is an error in input, there will be an
--                error message on the FND_MESSAGE stack which
--                can be retrieved with FND_MESSAGE.GET_ENCODED()
--
-- Notes  :   Returns null if there is no preference set
--
---------------------------------------------------------------
FUNCTION Value_Varchar2(
  p_party_id            NUMBER
, p_category            VARCHAR2
, p_preference_code     VARCHAR2
) RETURN VARCHAR2;


----------------------------------------------------------------
-- API name  : Value_Number
-- TYPE      : Public
-- FUNCTION  : Returns value_number value for a preference
--
-- Parameters:
--     IN    : p_party_id IN NUMBER (required)
--             Party on which the preference should be checked
--
--             p_category IN VARCHAR2(required)
--             Preference category for identifying a particular
--             preference
--
--             p_preference_code IN VARCHAR2 (required)
--             Preference to check
--
--     OUT  NOCOPY :
--             Returns NUMBER
--
--                If there is an error in input, there will be an
--                error message on the FND_MESSAGE stack which
--                can be retrieved with FND_MESSAGE.GET_ENCODED()
--
-- Notes  :   Returns null if there is no preference set
--
---------------------------------------------------------------
FUNCTION Value_Number(
  p_party_id            NUMBER
, p_category            VARCHAR2
, p_preference_code     VARCHAR2
) RETURN NUMBER;


----------------------------------------------------------------
-- API name  : Value_Date
-- TYPE      : Public
-- FUNCTION  : Returns value_date value for a preference
--
-- Parameters:
--     IN    : p_party_id IN NUMBER (required)
--             Party on which the preference should be checked
--
--             p_category IN VARCHAR2(required)
--             Preference category for identifying a particular
--             preference
--
--             p_preference_code IN VARCHAR2 (required)
--             Preference to check
--
--     OUT  NOCOPY :
--             Returns DATE
--
--                If there is an error in input, there will be an
--                error message on the FND_MESSAGE stack which
--                can be retrieved with FND_MESSAGE.GET_ENCODED()
--
-- Notes  :   Returns null if there is no preference set
--
---------------------------------------------------------------

FUNCTION Value_Date(
  p_party_id            NUMBER
, p_category            VARCHAR2
, p_preference_code     VARCHAR2
) RETURN DATE;


----------------------------------------------------------------
-- API name  : Contains_Value
-- TYPE      : Public
-- FUNCTION  : Determines whether a particular preference value
--             has been set
--
-- Parameters:
--     IN    : p_party_id IN  NUMBER (required)
--             Party on which the preference should be checked
--
--             p_category IN VARCHAR2(required)
--             Preference category for identifying a particular
--             preference
--
--             p_preference_code IN VARCHAR2 (required)
--             Preference code for identifying a particular
--             preference
--
--             p_value_number IN NUMBER (required)
--             value to be checked
--
--     OUT  NOCOPY :
--             RETURNs 1 byte result code:
--                   'Y'  preference value has been set.
--                   'N'  not exist.
--                   'E'  Error
--                   'U'  Unexpected Error
--
--                If 'E' or 'U' is returned, there will be an
--                error message on the FND_MESSAGE stack which
--                can be retrieved with FND_MESSAGE.GET_ENCODED()
--
-- Notes  : One of the parameters: p_value_varchar2,
--          p_value_number, p_value_date must be passed.
--          This function is overloaded.
--
---------------------------------------------------------------
FUNCTION Contains_Value(
  p_party_id            NUMBER
, p_category            VARCHAR2
, p_preference_code     VARCHAR2
, p_value_number        NUMBER
) RETURN VARCHAR2;


----------------------------------------------------------------
-- API name  : Contains_Value
-- TYPE      : Public
-- FUNCTION  : Determines whether a particular preference value
--             has been set
--
-- Parameters:
--     IN    : p_party_id IN  NUMBER (required)
--             Party on which the preference should be checked
--
--             p_category IN VARCHAR2(required)
--             Preference category for identifying a particular
--             preference
--
--             p_preference_code IN VARCHAR2 (required)
--             Preference code for identifying a particular
--             preference
--
--             p_value_date IN DATE (required)
--             value to be checked
--
--     OUT  NOCOPY :
--             RETURNs 1 byte result code:
--                   'Y'  preference value has been set.
--                   'N'  not exist.
--                   'E'  Error
--                   'U'  Unexpected Error
--
--                If 'E' or 'U' is returned, there will be an
--                error message on the FND_MESSAGE stack which
--                can be retrieved with FND_MESSAGE.GET_ENCODED()
--
-- Notes  : One of the parameters: p_value_varchar2,
--          p_value_number, p_value_date must be passed.
--         This function is overloaded.
--
---------------------------------------------------------------
FUNCTION Contains_Value(
  p_party_id            NUMBER
, p_category            VARCHAR2
, p_preference_code     VARCHAR2
, p_value_date          DATE
) RETURN VARCHAR2;


END HZ_PREFERENCE_PUB;

 

/
