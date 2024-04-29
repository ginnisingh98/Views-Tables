--------------------------------------------------------
--  DDL for Package HZ_FORMAT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_FORMAT_PUB" AUTHID CURRENT_USER AS
/*$Header: ARHPFMTS.pls 120.13 2006/08/17 10:18:42 idali noship $ */
/*#
 * This package contains the public APIs for Global Name and Address formatting. You can
 * use this package to format name and address data regardless of where it is stored.
 * @rep:scope public
 * @rep:product HZ
 * @rep:displayname  Name and Address Formatting
 * @rep:category BUSINESS_ENTITY HZ_ORGANIZATION
 * @rep:category BUSINESS_ENTITY HZ_PERSON
 * @rep:category BUSINESS_ENTITY HZ_ADDRESS
 * @rep:lifecycle active
 * @rep:doccd 120hztig.pdf Name and Address Formatting APIs,  Oracle Trading Community Architecture Technical Implementation Guide
 */

/******************** PUBLIC TYPE DECLARATIONS ****************************/

/*=========================================================================+
 |
 | TYPE DEFINITION:	string_tbl_type
 |
 | DESCRIPTION
 |
 |	A table or array of strings, that allow the formatting routines
 |	to return back multiple formatted lines.
 |
 +=========================================================================*/

TYPE string_tbl_type
  IS TABLE OF VARCHAR2(240)
  INDEX BY BINARY_INTEGER;

/*=========================================================================+
 |
 | TYPE DEFINITION:	layout_rec_type
 |
 | DESCRIPTION
 |
 |	An internal type definition that is used for a pl/sql representation
 |	of the columns in HZ_STYLE_FMT_LAYOUTS.  Numerous procedures in
 |	this package need access to this table, and having it cached
 |	in PL/SQL offers opportunity for performance improvements.
 |
 |	An additional field, attribute_value, is included.  This field
 |	will contain the actual value of the variable identified by
 |	attribute_code, for the particular record being formatted.
 |
 +=========================================================================*/

TYPE layout_rec_type IS RECORD (
  line_number		hz_style_fmt_layouts_b.line_number%TYPE,
  position		hz_style_fmt_layouts_b.position%TYPE,
  attribute_code	hz_style_fmt_layouts_b.attribute_code%TYPE,
  use_initial_flag	hz_style_fmt_layouts_b.use_initial_flag%TYPE,
  uppercase_flag	hz_style_fmt_layouts_b.uppercase_flag%TYPE,
  transform_function	hz_style_fmt_layouts_b.transform_function%TYPE,
  delimiter_before	hz_style_fmt_layouts_b.delimiter_before%TYPE,
  delimiter_after	hz_style_fmt_layouts_b.delimiter_after%TYPE,
  blank_lines_before    hz_style_fmt_layouts_b.blank_lines_before%TYPE,
  blank_lines_after     hz_style_fmt_layouts_b.blank_lines_after%TYPE,
  attribute_value	VARCHAR2(240)
);

/*=========================================================================+
 |
 | TABLE DEFINITION:	layout_tbl_type
 |
 | DESCRIPTION
 |
 |	A table of 'layout_rec_type' records, to be able to create an
 |	internal pl/sql table of these data.
 |
 +=========================================================================*/

 TYPE layout_tbl_type IS TABLE OF layout_rec_type
  INDEX BY BINARY_INTEGER;

/*=========================================================================+
 |
 | TYPE DEFINITION:	context_rec_type
 |
 | DESCRIPTION
 |
 |	An internal type definition that is used to keep track of the
 |	"context" in which a formatting function was called in.
 |
 |	It essentially contains the context related parameters passed from
 |	the caller (or the defaulted values).
 |
 |	It reason for existance is so that PL/SQL functions can be created
 |	to (e.g. for variation selection conditions or attribute transformation
 |	functions) and allow them to have acess to the context of which the
 |	formatting API was invoked.
 |
 +=========================================================================*/

TYPE context_rec_type IS RECORD (
  style_code		hz_styles_b.style_code%TYPE,
  style_format_code	hz_style_formats_b.style_format_code%TYPE,
  to_territory_code	fnd_territories.territory_code%TYPE,
  to_language_code	fnd_languages.language_code%TYPE,
  from_territory_code	fnd_territories.territory_code%TYPE,
  from_language_code	fnd_languages.language_code%TYPE,
  country_name_lang	fnd_languages.language_code%TYPE
);

/********************* PUBLIC FORMATTING APIs *****************************/
/*                                                                        */
/*  For detailed information, please refer to the HLD                     */
/*                                                                        */
/*  GENERAL COMMENTS-                                                     */
/*                                                                        */
/*  1.  format_name and format_address procedures have two signatures     */
/*      each.  The first requires an 'id' to be supplied (i.e. party_id   */
/*	or location_id) and the procedure will retrieve the data and      */
/*	format accordingly.  The second set of signatures have parameters */
/*	for the individual name and address components.  This set can be  */
/*	called to format name and address data regardless of where it is  */
/*	stored.                                                           */
/*                                                                        */
/*  2.  Function definitions are also available which allow the           */
/*      formatting routines to be used directly in SELECT statements.     */
/*                                                                        */
/*  STYLES-                                                               */
/*                                                                        */
/*  1.  Each entity might be able to be formatted in a number of styles   */
/*      providing sufficient formatting setup data has been defined.      */
/*      Typically, when calling these routines, you would identify the    */
/*      generic style (e.g. 'POSTAL_ADDR'), and the formatting routines   */
/*      will identify the specific format (e.g. 'POSTAL_ADDR_US') based   */
/*      on context information.                                           */
/*                                                                        */
/*  2.  If you do not identify the style, the formatting routine will     */
/*      attempt to pick a default, but may not always be successful.      */
/*                                                                        */
/*  3.  For flexibility, the formatting routines also allow you to        */
/*      optionally indicate the specific style format you wish to use     */
/*      in those cases where you want to override the defaulting          */
/*      behavior and don't want the formatting routines to pick one       */
/*      for you.                                                          */
/*                                                                        */
/*  CONTEXT-                                                              */
/*                                                                        */
/*  1.  The name and address formatting routines need to know the context */
/*      in which they are being run, because that could affect how the    */
/*      information is formatted.                                         */
/*                                                                        */
/*  2.  Name formatting requires a reference "locale" (language +         */
/*      territory) in order to pick an appropriate format.                */
/*                                                                        */
/*  3.  There is additional context information that MAY affect how       */
/*      addresses are formatted.  Context information for addresses are:  */
/*                                                                        */
/*      (a)  from country (i.e. where the sender is)                      */
/*      (b)  from language (i.e. where the sender is)                     */
/*      (c)  "to" country  (i.e. the country of the address)              */
/*      (d)  "to" language  (i.e. the language used at the address)       */
/*      (e)  language to display country name in (in some cases, this     */
/*           may be standardized (e.g. English) and may be different      */
/*           than the "from" language and the "to" language.              */
/*                                                                        */
/*  4.  Wherever possible, the APIs will default this context information */
/*      however, they are exposed as parameters so you can override.      */
/*                                                                        */
/*  RETURN STATUS-                                                        */
/*                                                                        */
/*  1.  The public APIs return back an x_return_status parameter, which   */
/*      will contain one of the following values:                         */
/*          FND_API.G_RET_STS_SUCCESS (success)                           */
/*          FND_API.G_RET_STS_ERROR (error detected by the API)           */
/*          FND_API.G_RET_STS_UNEXP_ERROR (unexpected error/exception)    */
/*                                                                        */
/**************************************************************************/


/*=========================================================================+
 |
 | PROCEDURE:	format_address (signature #1)
 |
 | DESCRIPTION
 |
 |	This procedure will format an address of a location that is
 |	stored in HZ_LOCATIONS.
 |
 |
 | SCOPE:	Public
 |
 | ARGUMENTS:
 |
 |    (IN)
 |
 |    p_location_id		Location ID identifying the row in
 |				    HZ_LOCATIONS for which you wish the
 |				    address formatted.
 |    p_style_code		The general style in which you wish the
 |				    address formatted.
 |    p_style_format_code	The specific format in which you wish the
 |    				    address formatted.
 |    p_line_break		Character(s) to use to indicate a line
 |				    break in x_formatted_address.
 |    p_space_replace		Characters(s) to substitute for "blanks"
 |    p_to_language_code	The language code of the destination.
 |    p_country_name_lang	Language that the country name should be
 |				    translated into.
 |    p_from_territory_code	Territory code from where something is sent.
 |
 |    (OUT)
 |
 |    x_return_status		Standard API return status.
 |    x_msg_count		Number of messages on the message stack.
 |    x_formatted_address	Single string formatted address (with line
 |				  breaks inserted).
 |    x_formatted_lines_cnt	Number of lines in the formatted address.
 |    x_formatted_address_tbl	The formatted address returned as multiple
 |				  strings, one for each line.
 +=========================================================================*/

/*#
 * Use this procedure to format the address of a location stored in the HZ_LOCATIONS table.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Format Address (known location ID)
 * @rep:doccd 120hztig.pdf Name and Address Formatting APIs,  Oracle Trading Community Architecture Technical Implementation Guide
 */
PROCEDURE format_address (
  -- input parameters
  p_location_id			IN NUMBER,
  p_style_code			IN VARCHAR2 DEFAULT NULL,
  p_style_format_code		IN VARCHAR2 DEFAULT NULL,
  p_line_break			IN VARCHAR2 DEFAULT NULL,
  p_space_replace		IN VARCHAR2 DEFAULT NULL,
  -- optional context parameters
  p_to_language_code		IN VARCHAR2 DEFAULT NULL,
  p_country_name_lang		IN VARCHAR2 DEFAULT NULL,
  p_from_territory_code		IN VARCHAR2 DEFAULT NULL,
  -- output parameters
  x_return_status		OUT NOCOPY VARCHAR2,
  x_msg_count			OUT NOCOPY NUMBER,
  x_msg_data			OUT NOCOPY VARCHAR2,
  x_formatted_address		OUT NOCOPY VARCHAR2,
  x_formatted_lines_cnt		OUT NOCOPY NUMBER,
  x_formatted_address_tbl	OUT NOCOPY string_tbl_type
);

/*=========================================================================+
 |
 | PROCEDURE:	format_address (signature #2)
 |
 | DESCRIPTION
 |
 |	This procedure will format an address.  Parameters are supplied for
 |	various address elements, therefore this procedure can be used to
 |	format an address from any data source.
 |
 |
 | SCOPE:	Public
 |
 | ARGUMENTS:
 |
 |    (IN)
 |
 |    p_style_code		The general style in which you wish the
 |				    address formatted.
 |    p_style_format_code	The specific format in which you wish the
 |    				    address formatted.
 |    p_line_break		Character(s) to use to indicate a line
 |				    break in x_formatted_address.
 |    p_space_replace		Characters(s) to substitute for "blanks"
 |    p_to_language_code	The language code of the destination.
 |    p_country_name_lang	Language that the country name should be
 |				    translated into.
 |    p_from_territory_code	Territory code from where something is sent.
 |
 |    p_address_line_1		Line 1 of address
 |    p_address_line_2		Line 2 of address
 |    p_address_line_3		Line 3 of address
 |    p_address_line_4		Line 4 of address
 |    p_city			City/Town
 |    p_postal_code		Postal Code or ZIP
 |    p_state			State Code
 |    p_province		Province Code
 |    p_county			County
 |    p_country			Country (Territory Code)
 |    p_address_lines_phonetic	Phonetic representation of address
 |
 |    (OUT)
 |
 |    x_return_status		Standard API return status.
 |    x_msg_count		Number of messages on the message stack.
 |    x_formatted_address	Single string formatted address (with line
 |				  breaks inserted).
 |    x_formatted_lines_cnt	Number of lines in the formatted address.
 |    x_formatted_address_tbl	The formatted address returned as multiple
 |				  strings, one for each line.
 +=========================================================================*/

/*#
 * Use this procedure to format an address. Parameters are supplied for various
 * address elements. Therefore, you can use this procedure to format an address from any
 * data source.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Format Address (unknown location ID)
 * @rep:doccd 120hztig.pdf Name and Address Formatting APIs,  Oracle Trading Community Architecture Technical Implementation Guide
 */
 PROCEDURE format_address (
  -- input parameters
  p_style_code			IN VARCHAR2 DEFAULT NULL,
  p_style_format_code		IN VARCHAR2 DEFAULT NULL,
  p_line_break			IN VARCHAR2 DEFAULT NULL,
  p_space_replace		IN VARCHAR2 DEFAULT NULL,
  -- optional context parameters
  p_to_language_code		IN VARCHAR2 DEFAULT NULL,
  p_country_name_lang		IN VARCHAR2 DEFAULT NULL,
  p_from_territory_code		IN VARCHAR2 DEFAULT NULL,
  -- address components
  p_address_line_1		IN VARCHAR2 DEFAULT NULL,
  p_address_line_2		IN VARCHAR2 DEFAULT NULL,
  p_address_line_3		IN VARCHAR2 DEFAULT NULL,
  p_address_line_4		IN VARCHAR2 DEFAULT NULL,
  p_city			IN VARCHAR2 DEFAULT NULL,
  p_postal_code			IN VARCHAR2 DEFAULT NULL,
  p_state			IN VARCHAR2 DEFAULT NULL,
  p_province			IN VARCHAR2 DEFAULT NULL,
  p_county			IN VARCHAR2 DEFAULT NULL,
  p_country			IN VARCHAR2 DEFAULT NULL,
  p_address_lines_phonetic 	IN VARCHAR2 DEFAULT NULL,
  -- output parameters
  x_return_status		OUT NOCOPY VARCHAR2,
  x_msg_count			OUT NOCOPY NUMBER,
  x_msg_data			OUT NOCOPY VARCHAR2,
  x_formatted_address		OUT NOCOPY VARCHAR2,
  x_formatted_lines_cnt		OUT NOCOPY NUMBER,
  x_formatted_address_tbl	OUT NOCOPY string_tbl_type
);

/*=========================================================================+
 |
 | PROCEDURE:	format_eloc_address
 |
 | DESCRIPTION
 |
 |	This procedure will format an address for elocation program.
 |      Parameters are supplied for various address elements, therefore
 |      this procedure can be used to format an address from any data source.
 |
 |
 | SCOPE:	Public
 |
 | ARGUMENTS:
 |
 |    (IN)
 |
 |    p_style_code		The general style in which you wish the
 |				    address formatted.
 |    p_style_format_code	The specific format in which you wish the
 |    				    address formatted.
 |    p_line_break		Character(s) to use to indicate a line
 |				    break in x_formatted_address.
 |    p_space_replace		Characters(s) to substitute for "blanks"
 |    p_to_language_code	The language code of the destination.
 |    p_country_name_lang	Language that the country name should be
 |				    translated into.
 |    p_from_territory_code	Territory code from where something is sent.
 |
 |    p_address_line_1		Line 1 of address
 |    p_address_line_2		Line 2 of address
 |    p_address_line_3		Line 3 of address
 |    p_address_line_4		Line 4 of address
 |    p_city			City/Town
 |    p_postal_code		Postal Code or ZIP
 |    p_state			State Code
 |    p_province		Province Code
 |    p_county			County
 |    p_country			Country (Territory Code)
 |    p_address_lines_phonetic	Phonetic representation of address
 |
 |    (OUT)
 |
 |    x_return_status		Standard API return status.
 |    x_msg_count		Number of messages on the message stack.
 |    x_formatted_address	Single string formatted address (with line
 |				  breaks inserted).
 |    x_formatted_lines_cnt	Number of lines in the formatted address.
 |    x_formatted_address_tbl	The formatted address returned as multiple
 |				  strings, one for each line.
 +=========================================================================*/

 PROCEDURE format_eloc_address (
  p_style_code			IN VARCHAR2 DEFAULT NULL,
  p_style_format_code		IN VARCHAR2 DEFAULT NULL,
  p_line_break			IN VARCHAR2 DEFAULT NULL,
  p_space_replace		IN VARCHAR2 DEFAULT NULL,
  p_to_language_code		IN VARCHAR2 DEFAULT NULL,
  p_country_name_lang		IN VARCHAR2 DEFAULT NULL,
  p_from_territory_code		IN VARCHAR2 DEFAULT NULL,
  p_address_line_1		IN VARCHAR2 DEFAULT NULL,
  p_address_line_2		IN VARCHAR2 DEFAULT NULL,
  p_address_line_3		IN VARCHAR2 DEFAULT NULL,
  p_address_line_4		IN VARCHAR2 DEFAULT NULL,
  p_city			IN VARCHAR2 DEFAULT NULL,
  p_postal_code			IN VARCHAR2 DEFAULT NULL,
  p_state			IN VARCHAR2 DEFAULT NULL,
  p_province			IN VARCHAR2 DEFAULT NULL,
  p_county			IN VARCHAR2 DEFAULT NULL,
  p_country			IN VARCHAR2 DEFAULT NULL,
  p_address_lines_phonetic 	IN VARCHAR2 DEFAULT NULL,
  x_return_status		OUT NOCOPY VARCHAR2,
  x_msg_count			OUT NOCOPY NUMBER,
  x_msg_data			OUT NOCOPY VARCHAR2,
  x_formatted_address		OUT NOCOPY VARCHAR2,
  x_formatted_lines_cnt		OUT NOCOPY NUMBER,
  x_formatted_address_tbl	OUT NOCOPY string_tbl_type
);

/*=========================================================================+
 |
 | PROCEDURE:	format_address_layout (signature #1)
 |
 | DESCRIPTION
 |
 |	This procedure will format an address layout of a location that is
 |	stored in HZ_LOCATIONS.
 |
 |
 | SCOPE:	Public
 |
 | ARGUMENTS:
 |
 |    (IN)
 |
 |    p_location_id		Location ID identifying the row in
 |				    HZ_LOCATIONS for which you wish the
 |				    address formatted.
 |    p_style_code		The general style in which you wish the
 |				    address formatted.
 |    p_style_format_code	The specific format in which you wish the
 |    				    address formatted.
 |    p_line_break		Character(s) to use to indicate a line
 |				    break in x_formatted_address.
 |    p_space_replace		Characters(s) to substitute for "blanks"
 |    p_to_language_code	The language code of the destination.
 |    p_country_name_lang	Language that the country name should be
 |				    translated into.
 |    p_from_territory_code	Territory code from where something is sent.
 |
 |    (OUT)
 |
 |    x_return_status		Standard API return status.
 |    x_msg_count		Number of messages on the message stack.
 |    x_layout_tbl_cnt   	Number of lines in the formatted address layout.
 |    x_layout_tbl	        The formatted address layout returned as multiple
 |				  strings, one for each line.
 +=========================================================================*/

PROCEDURE format_address_layout (
  -- input parameters
  p_location_id			IN NUMBER,
  p_style_code			IN VARCHAR2 DEFAULT NULL,
  p_style_format_code		IN VARCHAR2 DEFAULT NULL,
  p_line_break			IN VARCHAR2 DEFAULT NULL,
  p_space_replace		IN VARCHAR2 DEFAULT NULL,
  -- optional context parameters
  p_to_language_code		IN VARCHAR2 DEFAULT NULL,
  p_country_name_lang		IN VARCHAR2 DEFAULT NULL,
  p_from_territory_code		IN VARCHAR2 DEFAULT NULL,
  -- output parameters
  x_return_status		OUT NOCOPY VARCHAR2,
  x_msg_count			OUT NOCOPY NUMBER,
  x_msg_data			OUT NOCOPY VARCHAR2,
  x_layout_tbl_cnt	        OUT NOCOPY NUMBER,
  x_layout_tbl		        OUT NOCOPY layout_tbl_type
);

/*=========================================================================+
 |
 | PROCEDURE:	format_address_layout (signature #2)
 |
 | DESCRIPTION
 |
 |	This procedure will format an address layout.  Parameters are supplied for
 |	various address elements, therefore this procedure can be used to
 |	format an address layout from any data source.
 |
 |
 | SCOPE:	Public
 |
 | ARGUMENTS:
 |
 |    (IN)
 |
 |    p_style_code		The general style in which you wish the
 |				    address formatted.
 |    p_style_format_code	The specific format in which you wish the
 |    				    address formatted.
 |    p_line_break		Character(s) to use to indicate a line
 |				    break in x_formatted_address.
 |    p_space_replace		Characters(s) to substitute for "blanks"
 |    p_to_language_code	The language code of the destination.
 |    p_country_name_lang	Language that the country name should be
 |				    translated into.
 |    p_from_territory_code	Territory code from where something is sent.
 |
 |    p_address_line_1		Line 1 of address
 |    p_address_line_2		Line 2 of address
 |    p_address_line_3		Line 3 of address
 |    p_address_line_4		Line 4 of address
 |    p_city			City/Town
 |    p_postal_code		Postal Code or ZIP
 |    p_state			State Code
 |    p_province		Province Code
 |    p_county			County
 |    p_country			Country (Territory Code)
 |    p_address_lines_phonetic	Phonetic representation of address
 |
 |    (OUT)
 |
 |    x_return_status		Standard API return status.
 |    x_msg_count		Number of messages on the message stack.
 |    x_layout_tbl_cnt   	Number of lines in the formatted address layout.
 |    x_layout_tbl	        The formatted address layout returned as multiple
 |				  strings, one for each line.
 +=========================================================================*/

PROCEDURE format_address_layout (
  -- input parameters
  p_style_code			IN VARCHAR2 DEFAULT NULL,
  p_style_format_code		IN VARCHAR2 DEFAULT NULL,
  p_line_break			IN VARCHAR2 DEFAULT NULL,
  p_space_replace		IN VARCHAR2 DEFAULT NULL,
  -- optional context parameters
  p_to_language_code		IN VARCHAR2 DEFAULT NULL,
  p_country_name_lang		IN VARCHAR2 DEFAULT NULL,
  p_from_territory_code		IN VARCHAR2 DEFAULT NULL,
  -- address components
  p_address_line_1		IN VARCHAR2 DEFAULT NULL,
  p_address_line_2		IN VARCHAR2 DEFAULT NULL,
  p_address_line_3		IN VARCHAR2 DEFAULT NULL,
  p_address_line_4		IN VARCHAR2 DEFAULT NULL,
  p_city			IN VARCHAR2 DEFAULT NULL,
  p_postal_code			IN VARCHAR2 DEFAULT NULL,
  p_state			IN VARCHAR2 DEFAULT NULL,
  p_province			IN VARCHAR2 DEFAULT NULL,
  p_county			IN VARCHAR2 DEFAULT NULL,
  p_country			IN VARCHAR2 DEFAULT NULL,
  p_address_lines_phonetic 	IN VARCHAR2 DEFAULT NULL,
  -- output parameters
  x_return_status		OUT NOCOPY VARCHAR2,
  x_msg_count			OUT NOCOPY NUMBER,
  x_msg_data			OUT NOCOPY VARCHAR2,
  x_layout_tbl_cnt	        OUT NOCOPY NUMBER,
  x_layout_tbl		        OUT NOCOPY layout_tbl_type
);


/*=========================================================================+
 |
 | PROCEDURE:	format_name (signature #1)
 |
 | DESCRIPTION
 |
 |	This procedure will format a name of a person party that is
 |	stored in HZ_PARTIES.
 |
 |
 | SCOPE:	Public
 |
 | ARGUMENTS:
 |
 |    (IN)
 |
 |    p_party_id		Party ID identifying the row in
 |				    HZ_PARTIES for which you wish the
 |				    name formatted.
 |    p_style_code		The general style in which you wish the
 |				    address formatted.
 |    p_style_format_code	The specific format in which you wish the
 |    				    address formatted.
 |    p_line_break		Character(s) to use to indicate a line
 |				    break in x_formatted_address.
 |    p_space_replace		Characters(s) to substitute for "blanks"
 |    p_ref_language_code	The "reference" language (context).
 |    p_ref_territory_code	The "refernece" territory (context).
 |
 |    (OUT)
 |
 |    x_return_status		Standard API return status.
 |    x_msg_count		Number of messages on the message stack.
 |    x_formatted_name		Single string formatted name (with line
 |				  breaks inserted).
 |    x_formatted_lines_cnt	Number of lines in the formatted name.
 |    x_formatted_name_tbl	The formatted name returned as multiple
 |				  strings, one for each line.
 +=========================================================================*/

/*#
 * Use the Name Formatting procedure to format the name of a person using a specific style
 * format. To use this procedure you must use the party_id of the name that you are
 * formatting. The procedure queries for the party and formats the name.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Format Name (known party ID)
 * @rep:doccd 120hztig.pdf Name and Address Formatting APIs,  Oracle Trading Community Architecture Technical Implementation Guide
 */
PROCEDURE format_name (
  -- input parameters
  p_party_id			IN NUMBER,
  p_style_code			IN VARCHAR2 DEFAULT NULL,
  p_style_format_code		IN VARCHAR2 DEFAULT NULL,
  p_line_break			IN VARCHAR2 DEFAULT NULL,
  p_space_replace		IN VARCHAR2 DEFAULT NULL,
  -- optional context parameters
  p_ref_language_code		IN VARCHAR2 DEFAULT NULL,
  p_ref_territory_code		IN VARCHAR2 DEFAULT NULL,
  -- output parameters
  x_return_status		OUT NOCOPY VARCHAR2,
  x_msg_count			OUT NOCOPY NUMBER,
  x_msg_data			OUT NOCOPY VARCHAR2,
  x_formatted_name		OUT NOCOPY VARCHAR2,
  x_formatted_lines_cnt		OUT NOCOPY NUMBER,
  x_formatted_name_tbl		OUT NOCOPY string_tbl_type
);

/*=========================================================================+
 |
 | PROCEDURE:	format_name (signature #2)
 |
 | DESCRIPTION
 |
 |	This procedure will format a person name.  Parameters are supplied for
 |	various name elements, therefore this procedure can be used to
 |	format a person name from any data source.
 |
 | SCOPE:	Public
 |
 | ARGUMENTS:
 |
 |    (IN)
 |
 |    p_style_code		The general style in which you wish the
 |				    address formatted.
 |    p_style_format_code	The specific format in which you wish the
 |    				    address formatted.
 |    p_line_break		Character(s) to use to indicate a line
 |				    break in x_formatted_address.
 |    p_space_replace		Characters(s) to substitute for "blanks"
 |    p_ref_language_code	The "reference" language (context).
 |    p_ref_territory_code	The "refernece" territory (context).
 |
 |    p_person_title		Title of the person.
 |    p_person_first_name	First name of the person.
 |    p_person_middle_name	Middle name of the person.
 |    p_person_title		Title of the person.
 |    p_person_first_name	First name of the person.
 |    p_person_middle_name	Middle name of the person.
 |    p_person_last_name	Last name of the person.
 |    p_person_name_suffix	Suffix of the person name.
 |    p_person_known_as		"Known as" or a.k.a. or alias of the person.
 |    p_first_name_phonetic	Phonetic representation of first name.
 |    p_middle_name_phonetic	Phonetic representation of middle name.
 |    p_last_name_phonetic	Phonetic representation of last name.
 |
 |    (OUT)
 |
 |    x_return_status		Standard API return status.
 |    x_msg_count		Number of messages on the message stack.
 |    x_formatted_name		Single string formatted name (with line
 |				  breaks inserted).
 |    x_formatted_lines_cnt	Number of lines in the formatted name.
 |    x_formatted_name_tbl	The formatted name returned as multiple
 |				  strings, one for each line.
 +=========================================================================*/

/*#
 * Use the Name Formatting procedure to format the name of a person using a particular
 * style format. Use this procedure if you do not know the party_id of the name that you
 * are formatting. This procedure accepts the individual components of a person's name as
 * input.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Format Name (unknown party ID)
 * @rep:doccd 120hztig.pdf Name and Address Formatting APIs,  Oracle Trading Community Architecture Technical Implementation Guide
 */
 PROCEDURE format_name (
  -- input parameters
  p_style_code			IN VARCHAR2 DEFAULT NULL,
  p_style_format_code		IN VARCHAR2 DEFAULT NULL,
  p_line_break			IN VARCHAR2 DEFAULT NULL,
  p_space_replace		IN VARCHAR2 DEFAULT NULL,
  -- optional context parameters
  p_ref_language_code		IN VARCHAR2 DEFAULT NULL,
  p_ref_territory_code		IN VARCHAR2 DEFAULT NULL,
  -- person name components
  p_person_title		IN VARCHAR2 DEFAULT NULL,
  p_person_first_name		IN VARCHAR2 DEFAULT NULL,
  p_person_middle_name		IN VARCHAR2 DEFAULT NULL,
  p_person_last_name		IN VARCHAR2 DEFAULT NULL,
  p_person_name_suffix		IN VARCHAR2 DEFAULT NULL,
  p_person_known_as		IN VARCHAR2 DEFAULT NULL,
  p_first_name_phonetic		IN VARCHAR2 DEFAULT NULL,
  p_middle_name_phonetic	IN VARCHAR2 DEFAULT NULL,
  p_last_name_phonetic		IN VARCHAR2 DEFAULT NULL,
  -- output parameters
  x_return_status		OUT NOCOPY VARCHAR2,
  x_msg_count			OUT NOCOPY NUMBER,
  x_msg_data			OUT NOCOPY VARCHAR2,
  x_formatted_name		OUT NOCOPY VARCHAR2,
  x_formatted_lines_cnt		OUT NOCOPY NUMBER,
  x_formatted_name_tbl		OUT NOCOPY string_tbl_type
);

/*=========================================================================+
 |
 | PROCEDURE:	format_data
 |
 | DESCRIPTION
 |
 |	A generic API that will format entities other than names and addresses
 |	providing that the appropriate formatting metadata has been set up.
 |
 |
 | SCOPE:	Public
 |
 | ARGUMENTS:
 |
 |    (IN)
 |
 |    p_object_code		Object code (e.g. table name or view name)
 |				    for which you want the data formatted.
 |    p_object_key		Primary key of the object for which you
 |				    wish the data formatted.
 |    p_style_code		The general style in which you wish the
 |				    address formatted.
 |    p_style_format_code	The specific format in which you wish the
 |    				    address formatted.
 |    p_line_break		Character(s) to use to indicate a line
 |				    break in x_formatted_address.
 |    p_space_replace		Characters(s) to substitute for "blanks"
 |    p_ref_language_code	The "reference" language (context).
 |    p_ref_territory_code	The "refernece" territory (context).
 |
 |    (OUT)
 |
 |    x_return_status		Standard API return status.
 |    x_msg_count		Number of messages on the message stack.
 |    x_formatted_data		Single string formatted data (with line
 |				  breaks inserted).
 |    x_formatted_lines_cnt	Number of lines in the formatted data.
 |    x_formatted_data_tbl	The formatted data returned as multiple
 |				  strings, one for each line.
 +=========================================================================*/

/*#
 * Use the solutions provided for name and address formatting to format any type of
 * information from any data source. This generic formatting routine provides a method that
 * you can use to set up the Style Metadata for the data that you are formatting.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Format General Data
 * @rep:doccd 120hztig.pdf Name and Address Formatting APIs,  Oracle Trading Community Architecture Technical Implementation Guide
 */
PROCEDURE format_data (
  -- input parameters
  p_object_code			IN VARCHAR2,
  p_object_key_1		IN VARCHAR2,
  p_object_key_2		IN VARCHAR2 DEFAULT NULL,
  p_object_key_3		IN VARCHAR2 DEFAULT NULL,
  p_object_key_4		IN VARCHAR2 DEFAULT NULL,
  p_style_code			IN VARCHAR2 DEFAULT NULL,
  p_style_format_code		IN VARCHAR2 DEFAULT NULL,
  p_line_break			IN VARCHAR2 DEFAULT NULL,
  p_space_replace		IN VARCHAR2 DEFAULT NULL,
  -- optional context parameters
  p_ref_language_code		IN VARCHAR2 DEFAULT NULL,
  p_ref_territory_code		IN VARCHAR2 DEFAULT NULL,
  -- output parameters
  x_return_status		OUT NOCOPY VARCHAR2,
  x_msg_count			OUT NOCOPY NUMBER,
  x_msg_data			OUT NOCOPY VARCHAR2,
  x_formatted_data		OUT NOCOPY VARCHAR2,
  x_formatted_lines_cnt		OUT NOCOPY NUMBER,
  x_formatted_data_tbl		OUT NOCOPY string_tbl_type
);

/********************** PUBLIC FUNCTION APIs ******************************/


/*=========================================================================+
 |
 | FUNCTION:	format_address
 |
 | DESCRIPTION
 |
 |	A function version of the format_address procedure that can be
 |	used in a SQL statement.  Returns back the address formatted into a
 |	single line, with line breaks inserted.
 |
 | SCOPE:	Public
 |
 | ARGUMENTS:
 |
 +=========================================================================*/

FUNCTION format_address(
  p_location_id			IN NUMBER,
  p_style_code			IN VARCHAR2 DEFAULT NULL,
  p_style_format_code		IN VARCHAR2 DEFAULT NULL,
  p_line_break			IN VARCHAR2 DEFAULT '/',
  p_space_replace		IN VARCHAR2 DEFAULT NULL,
  p_to_language_code		IN VARCHAR2 DEFAULT NULL,
  p_country_name_lang		IN VARCHAR2 DEFAULT NULL,
  p_from_territory_code		IN VARCHAR2 DEFAULT NULL
) RETURN VARCHAR2;


/*=========================================================================+
 |
 | FUNCTION:	format_address_lov
 |
 | DESCRIPTION
 |
 |	A function version of the format_address procedure that can be
 |	is meant to be used for Party LOVs.  This version accepts the
 |      individual address components and is useful since these data are
 |      denormalized onto HZ_PARTIES.
 |
 | SCOPE:	For TCA internal use only - signature can change
 |              without warning.
 |
 | ARGUMENTS:
 |
 +=========================================================================*/

 FUNCTION format_address_lov(
  p_address_line_1              IN VARCHAR2 DEFAULT NULL,
  p_address_line_2              IN VARCHAR2 DEFAULT NULL,
  p_address_line_3              IN VARCHAR2 DEFAULT NULL,
  p_address_line_4              IN VARCHAR2 DEFAULT NULL,
  p_city                        IN VARCHAR2 DEFAULT NULL,
  p_postal_code                 IN VARCHAR2 DEFAULT NULL,
  p_state                       IN VARCHAR2 DEFAULT NULL,
  p_province                    IN VARCHAR2 DEFAULT NULL,
  p_county                      IN VARCHAR2 DEFAULT NULL,
  p_country                     IN VARCHAR2 DEFAULT NULL,
  p_address_lines_phonetic      IN VARCHAR2 DEFAULT NULL
) RETURN VARCHAR2;


/*=========================================================================+
 |
 | FUNCTION:	format_name
 |
 | DESCRIPTION
 |
 |	A function version of the format_name procedure that can be
 |	used in a SQL statement.  Returns back the name formatted into a
 |	single line, with line breaks inserted.
 |
 | SCOPE:	Public
 |
 | ARGUMENTS:
 |
 +=========================================================================*/


FUNCTION format_name (
  p_party_id			IN NUMBER,
  p_style_code			IN VARCHAR2 DEFAULT NULL,
  p_style_format_code		IN VARCHAR2 DEFAULT NULL,
  p_line_break			IN VARCHAR2 DEFAULT '/',
  p_space_replace		IN VARCHAR2 DEFAULT NULL,
  p_ref_language_code		IN VARCHAR2 DEFAULT NULL,
  p_ref_territory_code		IN VARCHAR2 DEFAULT NULL
) RETURN VARCHAR2;

/*********************** PUBLIC UTILITY APIs ******************************/

/*=========================================================================+
 |
 | PROCEDURE: get_context
 |
 | DESCRIPTION
 |
 |	This procedure is invoked to obtain "context" information under
 |	which a format_name, format_address, or format_data public API
 |	was invoked.
 |
 |	It is available so that product teams or customer can
 |	develop their own attribute transformation or variation selection
 |	functions, and have access to the context information under which
 |	a format_xxxx procedure was invoked within.
 |
 |	!!! IMPORTANT !!!
 |
 |	This procedure is only meant to be called by those functions
 |	which are dynamically invoked by the formatting routines.
 |
 |	Specificially, this means the following:
 |
 |	  1.  Any functions defined for the "selection condition" of
 |	      a Style Format Layout Variation.
 |
 |	  2.  Any functions defined as "transformation functions" for
 |	      attributes defined in the Style Format Layouts.
 |
 |	This context information should not be invoked by any other code
 |	because the state of the context information is not guaranteed
 |	outside the invocation of a format_name, format_address, or
 |	format_data routine.
 |
 | SCOPE:	Public (limited)
 |
 +=========================================================================*/

PROCEDURE get_context (
  x_context		OUT NOCOPY context_rec_type
);

/*=========================================================================+
 |
 | PROCEDURE:	get_style_format
 |
 | DESCRIPTION
 |
 |	Gets the appropriate localized Style Format Code for a given Style,
 |	based on Territory or Language, or a combination of both.
 |
 |	Styles (HZ_STYLES) can have multiple Style Formats (HZ_STYLE_FORMATS)
 |	depending on Territory and Location ("locales").  The locales for
 |	which a given Style Format is applicable is stored in table
 |	HZ_STYLE_FMT_LOCALES.
 |
 |	The following sequence occurs to find the matching Style Format:
 |
 |		1.  Check for a match on BOTH Territory and Language Code
 |		2.  If not found (or n/a) check for a match on Territory.
 |		3.  If not found (or n/a) check for a match on Language.
 |		4.  If not found then retrieve the DEFAULT Style Format
 |			for the Style.
 |
 |	For example, if Style Code 'POSTAL_ADDR' is passed, as well as
 |	Territory of 'FR' (France), then this procedure should find the
 |	matching Style Format of 'POSTAL_ADDR_N_EUR' (The Style Format
 |	Northern Europe).
 |
 | SCOPE:	Public
 |
 | ARGUMENTS:	(IN)
 |		p_style_code		Style for which to find
 |					  the localized Style Format.
 |		p_territory_code	Territory for which you wish
 |					  to determine Style Format.
 |		p_language_code		Language for which you wish
 |					  to determine Style Format.
 |
 |              (OUT)
 |		x_return_status		API Standard Return Status
 |		x_msg_count		API Standard Message Count
 |		x_msg_data		API Standard Message Data
 |		x_style_format_code	Style Format Code that was found.
 |
 +=========================================================================*/

PROCEDURE get_style_format (
  p_style_code		IN VARCHAR2,
  p_territory_code	IN fnd_territories.territory_code%TYPE	DEFAULT NULL,
  p_language_code	IN fnd_languages.language_code%TYPE	DEFAULT NULL,
  x_return_status	OUT NOCOPY VARCHAR2,
  x_msg_count		OUT NOCOPY VARCHAR2,
  x_msg_data		OUT NOCOPY VARCHAR2,
  x_style_format_code	OUT NOCOPY VARCHAR2
);

/***************** PUBLIC (SEEDED) CALLOUT FUNCTIONS **********************/
/*                                                                        */
/*  The following functions are used by the seeded "selection condition"  */
/*  definitions (for selecting a layout variation) and by the attribute   */
/*  transformation functions.  They are available for use in custom       */
/*  layouts.                                                              */
/*                                                                        */
/**************************************************************************/

/*=========================================================================+
 |
 | FUNCTION:  use_neu_country_code
 |
 | DESCRIPTION
 |
 |	This function determines if the "from country" (context information)
 |	as well as the "to country" both use the Northern European
 |	addressing format.  This determines which of the Northern European
 |	layout variations to use.
 |
 | SCOPE:	Public (limited)
 |		Intended to be used as a function for the "selection condition"
 |		of a layout variation.
 |
 | ARGUMENTS:	(IN)
 |		p_territory_code	Territory Code of the address ("to").
 +=========================================================================*/

FUNCTION use_neu_country_format (
  p_territory_code	IN VARCHAR2
) RETURN VARCHAR2;  -- boolean 'Y' or 'N'

/*=========================================================================+
 |
 | FUNCTION:  get_neu_country_code
 |
 | DESCRIPTION
 |
 |	This function will translate a Territory Code for Northern Europe
 |	into the code that is used to preceed the postal code in a
 |	formatted address.  The code often differs from the ISO code.
 |
 |	For example, France (FR) uses an "F" in front of the postal code
 |	when using the Northern European address format.
 |	Belgium (BE) uses "B", Germany (DE) uses "D", etc.
 |
 | SCOPE:	Public (limited)
 |		Intended to be used as a "transformation function" of an
 |		attribute.
 |
 | ARGUMENTS:	(IN)
 |		p_territory_code	Territory Code of the address ("to").
 +=========================================================================*/

FUNCTION get_neu_country_code (
  p_territory_code	IN VARCHAR2
) RETURN VARCHAR2;

/*=========================================================================+
 |
 | FUNCTION:  get_tl_territory_name
 |
 | DESCRIPTION
 |
 |	This function will translate a Territory Code (e.g. 'MX') into its
 |	name (e.g. 'Mexico').
 |
 |	The behavior of this function depends on the context in which
 |	it was invoked.
 |
 |	  a)  The Territory Name is retrieved in the language identified
 |	      by context attribute "country_name_lang".
 |
 |	  b)  If the Territory Code is the same as the context attribute
 |	      "from_territory_code", then NULL will be returned.
 |	      This controls the suppression of the country name if
 |	      the "from" and "to" countries are the same.
 |
 |
 | SCOPE:	Public (limited)
 |		Intended to be used as a "transformation function" of an
 |		attribute.
 |
 | ARGUMENTS:	(IN)
 |		p_territory_code	Territory Code of the address ("to").
 +=========================================================================*/

FUNCTION get_tl_territory_name (
  p_territory_code	IN VARCHAR2
) RETURN VARCHAR2;


PROCEDURE get_default_ref_territory (
  x_ref_territory_code	OUT NOCOPY fnd_territories.territory_code%TYPE
);

END hz_format_pub;

 

/
