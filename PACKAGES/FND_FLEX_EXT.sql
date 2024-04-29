--------------------------------------------------------
--  DDL for Package FND_FLEX_EXT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_FLEX_EXT" AUTHID CURRENT_USER AS
/* $Header: AFFFEXTS.pls 120.3.12010000.4 2014/08/12 14:45:03 hgeorgi ship $ */
/*#
* Key FlexField server side validation functions.
* @rep:scope public
* @rep:product FND
* @rep:displayname Key Flexfield Validation Public
* @rep:lifecycle active
* @rep:compatibility S
* @rep:category BUSINESS_ENTITY FND_FLEX_KFF
*/


  --------
  -- PUBLIC TYPES
  --

  TYPE SegmentArray IS TABLE OF VARCHAR2(4000) INDEX BY BINARY_INTEGER;


  --------
  -- PUBLIC CONSTANTS
  --

  MAX_SEG_SIZE          CONSTANT NUMBER := 4000;
  DATE_FORMAT           CONSTANT VARCHAR2(44) := 'YYYY/MM/DD HH24:MI:SS';

  --------
  -- PUBLIC FUNCTIONS
  --

/*#
* Gets the last error message in the current language of database.
* @return Returns the last error message in the current language of database.
* @rep:scope public
* @rep:displayname Get Error Message
* @rep:lifecycle active
* @rep:compatibility S
*/
  FUNCTION get_message RETURN VARCHAR2;

/*#
* Gets the last error message in the encoded format.
* @return Returns the last error message in the encoded format.
* @rep:scope public
* @rep:displayname Get Encoded Error Message
* @rep:lifecycle active
* @rep:compatibility S
*/
  FUNCTION get_encoded_message RETURN VARCHAR2;

/*#
* Concatenates segments from segment array to a string.
* Raises unhandled exception if any errors.
* @param n_segments Number of segments
* @param segments Input segment array
* @param delimiter Delimiter
* @return Returns the concatenated segment string.
* @rep:scope public
* @rep:displayname Get Concatenated Segment
* @rep:lifecycle active
* @rep:compatibility S
*/
  FUNCTION concatenate_segments(n_segments     IN  NUMBER,
                                segments       IN  SegmentArray,
                                delimiter      IN  VARCHAR2) RETURN VARCHAR2;

/*#
* Breaks up concatenated segments into segment array.
* Truncates segments longer than MAX_SEG_SIZE bytes.
* Raises unhandled exception if any errors.
* @param concatenated_segs Concatenated string
* @param delimiter Delimiter
* @param segments Segment array
* @return Returns the number of segments found.
* @rep:scope public
* @rep:displayname Breakup Segments
* @rep:lifecycle active
* @rep:compatibility S
*/
  FUNCTION breakup_segments(concatenated_segs  IN  VARCHAR2,
                            delimiter          IN  VARCHAR2,
                            segments           OUT nocopy SegmentArray) RETURN NUMBER;

/*#
* Gets the character used as the segment delimiter for the
* specified key flexfield structure.
* Returns NULL and sets error on the server if structure not found.
* @param application_short_name Application Short Name
* @param key_flex_code Key Flexfield Code
* @param structure_number Structure number
* @return Returns the delimiter for the key flexfield structure.
* @rep:scope public
* @rep:displayname Get Flexfield Structure Delimiter
* @rep:lifecycle active
* @rep:compatibility S
*/
  FUNCTION get_delimiter(application_short_name IN  VARCHAR2,
                         key_flex_code          IN  VARCHAR2,
                         structure_number       IN  NUMBER) RETURN VARCHAR2;

/*#
* Finds combination_id for given set of key flexfield segment values.
* Segment values must be input in segments(1) - segments(n_segments)
* in the order displayed. Must explicitly assign segments(n) := NULL
* if a segment is null or this will generate a "no data found" error.
* Creates a new combination if it is valid and the flexfield allows
* dynamic inserts and the combination does not already exist.
* New valid combinations are committed within an autonomous transaction.
* Performs all checks on values including security and
* cross-validation. Value security rules will be checked for the
* current user identified in the FND_GLOBAL package. This will be
* set up automatically if the database session this package is called
* from underlies a concurrent program or a form.
* The validation date is used to determine if values have expired,
* and determines if cross-validation rules are still in effect.
* Generally pass in SYSDATE for validation date. If validation
* date is null, this function considers expired values valid
* and checks all cross-validation rules even if they are outdated.
* Returns TRUE if combination valid, or FALSE and sets error
* message using FND_MESSAGE utility on error or if invalid.
* If this function returns FALSE, use GET_MESSAGE to get the
* text of the error message in the language of the database, or
* GET_ENCODED_MESSAGE to get the error message in a language-
* independent encoded format.
* Combination_id output may be NULL if combination is invalid.
* @param application_short_name Application Short Name
* @param key_flex_code Key Flexfield Code
* @param structure_number Structure number
* @param validation_date Validation date
* @param n_segments Number of segments
* @param segments Segment array
* @param combination_id Code Combination Id
* @param data_set Data set number
* @return Returns TRUE if combination is valid, FALSE otherwise.
* @rep:scope public
* @rep:displayname Get Code Combination Id
* @rep:lifecycle active
* @rep:compatibility S
*/

  FUNCTION get_combination_id(application_short_name    IN  VARCHAR2,
                           key_flex_code        IN  VARCHAR2,
                           structure_number     IN  NUMBER,
                           validation_date      IN  DATE,
                           n_segments           IN  NUMBER,
                           segments             IN  SegmentArray,
                           combination_id       OUT nocopy NUMBER,
                           data_set             IN  NUMBER DEFAULT -1)
             RETURN BOOLEAN;

/*#
* Returns segment values for the given combination id in the key
* flexfield specified. Does not check value security rules.
* Returns TRUE if combination found and places displayed segment
* values in segments(1) through segments(n_segments) inclusive.
* Returns FALSE, sets n_segments = 0, and sets global error message
* using the FND_MESSAGE utility on error or if combination not found.
* If this function returns FALSE, use GET_MESSAGE to get the
* text of the error message in the language of the database, or
* GET_ENCODED_MESSAGE to get the error message in a language-
* independent encoded format.
* @param application_short_name Application Short Name
* @param key_flex_code Key Flexfield Code
* @param structure_number Structure number
* @param combination_id Code Combination Id
* @param n_segments Number of segments
* @param segments Segment array
* @param data_set Data set number
* @return Returns TRUE if combination is valid, FALSE otherwise.
* @rep:scope public
* @rep:displayname Get Segments
* @rep:lifecycle active
* @rep:compatibility S
*/

  FUNCTION get_segments(application_short_name  IN  VARCHAR2,
                        key_flex_code           IN  VARCHAR2,
                        structure_number        IN  NUMBER,
                        combination_id          IN  NUMBER,
                        n_segments              OUT nocopy NUMBER,
                        segments                OUT nocopy SegmentArray,
                        data_set                IN  NUMBER  DEFAULT -1)
                                                        RETURN BOOLEAN;

/*#
* Gets combination id for the specified key flexfield segments.
* Identical to get_combination_id() except this function takes
* segment values in a string concatenated by the segment
* delimiter for this flexfield, and returns a positive combination
* id if valid or 0 on error. Validation date must be passed in
* as a character string using the DATE_FORMAT format defined in
* this package.
* If this function returns 0, use GET_MESSAGE to get the
* text of the error message in the language of the database, or
* GET_ENCODED_MESSAGE to get the error message in a language-
* independent encoded format.
* @param application_short_name Application Short Name
* @param key_flex_code Key Flexfield Code
* @param structure_number Structure number
* @param validation_date Validation date
* @param concatenated_segments Concatenated segments
* @return Returns a positive combination id if valid or 0 on error.
* @rep:scope public
* @rep:displayname Get Code Combination Id
* @rep:lifecycle active
* @rep:compatibility S
*/

  FUNCTION get_ccid(application_short_name  IN  VARCHAR2,
                    key_flex_code           IN  VARCHAR2,
                    structure_number        IN  NUMBER,
                    validation_date         IN  VARCHAR2,
                    concatenated_segments   IN  VARCHAR2) RETURN NUMBER;

/*#
* Gets concatenated segment values for the specified key flexfield
* combination id.
* Identical to get_segments() except returns the concatenated
* segment values as a string or NULL if invalid or on error.
* Note that this function is incapable of distinguishing a valid
* combination with a single null segment from an error.
* Caller must provide VARCHAR2(2000) storage for the returned string.
* If this function returns NULL, use GET_MESSAGE to get the
* text of the error message in the language of the database, or
* GET_ENCODED_MESSAGE to get the error message in a language-
* independent encoded format.
* Note: NULL does not necessarily mean an error occured. May be it is
* a single segment keyflexfield with NULL value.
* @param application_short_name Application Short Name
* @param key_flex_code Key Flexfield Code
* @param structure_number Structure number
* @param combination_id Code Combination Id
* @return Returns concatenated segment value or NULL if invalid or on error.
* @rep:scope public
* @rep:displayname Get Concatenated Segment
* @rep:lifecycle active
* @rep:compatibility S
*/

  FUNCTION get_segs(application_short_name      IN  VARCHAR2,
                    key_flex_code               IN  VARCHAR2,
                    structure_number            IN  NUMBER,
                    combination_id              IN  NUMBER) RETURN VARCHAR2;

/*#
* Finds combination_id for given set of key flexfield segment values.
* Segment values must be input in segments(1) - segments(n_segments)
* in the order displayed. Must explicitly assign segments(n) := NULL
* if a segment is null or this will generate a "no data found" error.
* Creates a new combination if it is valid and the combination does not
* already exist, EVEN IF dynamic insert is not enabled. This is the only
* difference from the get_combination_id function.
* New valid combinations are committed within an autonomous transaction.
* Performs all checks on values including security and
* cross-validation. Value security rules will be checked for the
* current user identified in the FND_GLOBAL package. This will be
* set up automatically if the database session this package is called
* from underlies a concurrent program or a form.
* The validation date is used to determine if values have expired,
* and determines if cross-validation rules are still in effect.
* Generally pass in SYSDATE for validation date. If validation
* date is null, this function considers expired values valid
* and checks all cross-validation rules even if they are outdated.
* Returns TRUE if combination valid, or FALSE and sets error
* message using FND_MESSAGE utility on error or if invalid.
* If this function returns FALSE, use GET_MESSAGE to get the
* text of the error message in the language of the database, or
* GET_ENCODED_MESSAGE to get the error message in a language-
* independent encoded format.
* Combination_id output may be NULL if combination is invalid.
* @param application_short_name Application Short Name
* @param key_flex_code Key Flexfield Code
* @param structure_number Structure number
* @param validation_date Validation date
* @param n_segments Number of segments
* @param segments Segment array
* @param combination_id Code Combination Id
* @param data_set Data set number
* @return Returns TRUE if combination is valid, FALSE otherwise.
* @rep:scope public
* @rep:displayname Get Code Comb Id Allow Insert
* @rep:lifecycle active
* @rep:compatibility S
*/

  FUNCTION get_comb_id_allow_insert(application_short_name    IN  VARCHAR2,
                           key_flex_code        IN  VARCHAR2,
                           structure_number     IN  NUMBER,
                           validation_date      IN  DATE,
                           n_segments           IN  NUMBER,
                           segments             IN  SegmentArray,
                           combination_id       OUT nocopy NUMBER,
                           data_set             IN  NUMBER DEFAULT -1)
             RETURN BOOLEAN;



/* ------------------------------------------------------------------------ */

  PROCEDURE clear_ccid_cache;


  -- Bug 14250283 new procedure to override Right Justify Zero Fill
  -- as defined in ValueSet. This procedure should be called
  -- just before calling any of the validation procedures such as
  -- FND_FLEX_EXT.GET_CCID().
  PROCEDURE set_zero_fill(p_zero_fill IN VARCHAR2);


END fnd_flex_ext;

/
