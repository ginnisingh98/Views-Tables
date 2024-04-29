--------------------------------------------------------
--  DDL for Package Body HZ_FORMAT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_FORMAT_PUB" AS
/*$Header: ARHPFMTB.pls 120.24.12010000.2 2008/09/16 11:12:02 rgokavar ship $ */

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
/*
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
*/
/*=========================================================================+
 |
 | TYPE DEFINITION:	name_value_rec_type
 |
 | DESCRIPTION
 |
 |	An internal type definition that is for name/value pairs.
 |	This is used in the formatting signatures that have the name and
 |	address elements as individual parameters.  The parameter names and
 |	values are loaded into a PL/SQL table to be able to support dynamic
 |	formatting.
 |
 +=========================================================================*/

TYPE name_value_rec_type IS RECORD (
  parm_name		VARCHAR2(30),
  parm_value		VARCHAR2(240),
  parm_type		VARCHAR2(1)	-- V=Varchar, N=Numeric, D=Date
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

-- TYPE layout_tbl_type IS TABLE OF layout_rec_type
--  INDEX BY BINARY_INTEGER;

/*=========================================================================+
 |
 | TABLE DEFINITION:	name_value_tbl_type
 |
 | DESCRIPTION
 |
 |	A table of 'name_value_rec_type' records, to be able to create
 |	an internal pl/sql table of these data.
 |
 +=========================================================================*/

 TYPE name_value_tbl_type IS TABLE OF name_value_rec_type
  INDEX BY BINARY_INTEGER;

 -- remove 9i dependency
 -- performance bug  4079490
 --TYPE var_indexed_table IS TABLE OF VARCHAR2(400) INDEX BY VARCHAR2(400);
 --terr_short_name_tab            var_indexed_table;

/******************** PACKAGE GLOBAL VARIABLES ****************************/

g_pkg_name		VARCHAR2(30) := 'hz_format_pub';

g_caching			BOOLEAN := TRUE;
g_cache_style_format_code	hz_style_formats_b.style_format_code%TYPE;
g_cache_variation_number	NUMBER;

g_layout_tbl		layout_tbl_type;
g_layout_tbl_cnt	NUMBER;

g_parm_tbl		name_value_tbl_type;
g_parm_tbl_cnt		NUMBER;

g_pk_tbl		name_value_tbl_type;
g_pk_tbl_cnt		NUMBER;

g_context		context_rec_type;

-- performance bug  4079490
g_terr_code_exist NUMBER := 0;
g_territory_code	fnd_territories.territory_code%TYPE;

--
-- Constants
--

k_profile_ref_lang		CONSTANT VARCHAR2(30)  := 'HZ_REF_LANG';
k_profile_ref_territory		CONSTANT VARCHAR2(30)  := 'HZ_REF_TERRITORY';
k_profile_country_lang		CONSTANT VARCHAR2(30)  := 'HZ_LANG_FOR_COUNTRY_DISPLAY';
k_profile_def_addr_style	CONSTANT VARCHAR2(30)  := 'HZ_DEFAULT_ADDR_STYLE';
k_profile_def_name_style	CONSTANT VARCHAR2(30)  := 'HZ_DEFAULT_NAME_STYLE';

g_icx_territory                 CONSTANT VARCHAR2(30)  := FND_PROFILE.VALUE('ICX_TERRITORY');
g_profile_ref_lang		CONSTANT VARCHAR2(4)   := FND_PROFILE.VALUE('HZ_REF_LANG');
g_profile_ref_territory		CONSTANT VARCHAR2(2)   := FND_PROFILE.VALUE('HZ_REF_TERRITORY');
g_profile_country_lang		CONSTANT VARCHAR2(4)   := FND_PROFILE.VALUE('HZ_LANG_FOR_COUNTRY_DISPLAY');
g_profile_def_addr_style	CONSTANT VARCHAR2(30)  := FND_PROFILE.VALUE('HZ_DEFAULT_ADDR_STYLE');
g_profile_def_name_style	CONSTANT VARCHAR2(30)  := FND_PROFILE.VALUE('HZ_DEFAULT_NAME_STYLE');

k_addr_table_name		CONSTANT VARCHAR2(30)  := 'HZ_LOCATIONS';
k_addr_table_pk			CONSTANT VARCHAR2(30)  := 'LOCATION_ID';
k_name_table_name		CONSTANT VARCHAR2(30)  := 'HZ_PARTIES';
k_name_table_pk			CONSTANT VARCHAR2(30)  := 'PARTY_ID';

/************* PRIVATE PROCEDURE/FUNCTION DECLARATIONS ********************/


PROCEDURE get_default_style (
  p_object_name		IN hz_styles_b.database_object_name%TYPE,
  x_style_code		OUT NOCOPY hz_styles_b.style_code%TYPE
);

/*
PROCEDURE get_default_ref_territory (
  x_ref_territory_code	OUT NOCOPY fnd_territories.territory_code%TYPE
);
*/
PROCEDURE get_default_eloc_ref_territory (
  x_ref_territory_code	OUT NOCOPY fnd_territories.territory_code%TYPE
);

PROCEDURE get_default_ref_language (
  x_ref_language_code	OUT NOCOPY fnd_languages.language_code%TYPE
);

PROCEDURE get_country_name_lang (
  x_country_name_lang OUT NOCOPY fnd_languages.language_code%TYPE
);

PROCEDURE load_internal_format_table(
  p_style_format_code	IN	VARCHAR2,
  p_variation_num	IN	NUMBER DEFAULT NULL,
  x_layout_tbl		IN OUT	NOCOPY layout_tbl_type,
  x_loaded_rows_cnt	IN OUT NOCOPY	NUMBER
);

PROCEDURE add_parm_table_row(
  p_parm_name		IN	VARCHAR2,
  p_parm_value		IN	VARCHAR2,
  x_parm_tbl		IN OUT	NOCOPY name_value_tbl_type,
  x_loaded_rows_cnt	IN OUT NOCOPY	NUMBER,
  p_parm_type		IN	VARCHAR2 DEFAULT 'V'
);

PROCEDURE create_sql_string(
  p_table_name 		IN 	VARCHAR2,
  x_pk_tbl		IN OUT  NOCOPY name_value_tbl_type,
  p_pk_tbl_cnt		IN	NUMBER,
  x_layout_tbl 		IN OUT 	NOCOPY layout_tbl_type,
  p_layout_tbl_cnt	IN 	NUMBER,
  x_sql_string 		IN OUT	NOCOPY VARCHAR2
);

PROCEDURE execute_query(
  p_sql_string		IN	VARCHAR2,
  x_pk_tbl		IN OUT  NOCOPY name_value_tbl_type,
  p_pk_tbl_cnt		IN	NUMBER,
  p_layout_tbl_cnt	IN NUMBER,
  x_layout_tbl		IN OUT	NOCOPY layout_tbl_type
);

PROCEDURE format_results (
  p_space_replace	IN		VARCHAR2,
  p_layout_tbl_cnt	IN		NUMBER,
  x_layout_tbl		IN OUT NOCOPY	layout_tbl_type,
  x_formatted_lines_tbl	IN OUT NOCOPY	string_tbl_type,
  x_formatted_lines_cnt	IN OUT NOCOPY	NUMBER
);

PROCEDURE determine_variation (
  p_style_format_code	IN	VARCHAR2,
  p_object_name		IN	VARCHAR2,
  p_object_pk_name	IN	VARCHAR2,
  p_object_pk_value	IN	VARCHAR2,
  x_variation_num	OUT NOCOPY	NUMBER
);

PROCEDURE determine_variation (
  p_style_format_code	IN	VARCHAR2,
  p_parm_tbl_cnt	IN NUMBER,
  x_parm_tbl	IN OUT	NOCOPY name_value_tbl_type,
  x_variation_num	OUT NOCOPY	NUMBER
);

PROCEDURE copy_attribute_values (
  p_parm_tbl_cnt	IN 	NUMBER,
  x_parm_tbl		IN OUT	NOCOPY name_value_tbl_type,
  p_layout_tbl_cnt	IN 	NUMBER,
  x_layout_tbl 		IN OUT 	NOCOPY layout_tbl_type
);

PROCEDURE substitute_tokens (
  p_parm_tbl_cnt	IN 	NUMBER,
  x_parm_tbl		IN OUT	NOCOPY name_value_tbl_type,
  x_string		IN OUT NOCOPY VARCHAR2
);

PROCEDURE set_context (
  p_style_code		IN	hz_styles_b.style_code%TYPE,
  p_style_format_code	IN	hz_style_formats_b.style_format_code%TYPE,
  p_to_territory_code	IN	fnd_territories.territory_code%TYPE,
  p_to_language_code	IN	fnd_languages.language_code%TYPE,
  p_from_territory_code	IN	fnd_territories.territory_code%TYPE,
  p_from_language_code	IN	fnd_languages.language_code%TYPE,
  p_country_name_lang	IN	fnd_languages.language_code%TYPE
);


/********************* PUBLIC FORMATTING APIs *****************************/


/*=========================================================================+
 |
 | PROCEDURE:	format_address (signature #1)
 |
 | DESCRIPTION
 |
 |	This procedure will format an address of a location that is
 |	stored in HZ_LOCATIONS.
 |
 | SCOPE:	Public
 |
 | ARGUMENTS:	(see definition in specification)
 |
 +=========================================================================*/


PROCEDURE format_address (
  -- input parameters
  p_location_id			IN NUMBER,
  p_style_code			IN VARCHAR2,
  p_style_format_code		IN VARCHAR2,
  p_line_break			IN VARCHAR2,
  p_space_replace		IN VARCHAR2,
  -- optional context parameters
  p_to_language_code		IN VARCHAR2,
  p_country_name_lang		IN VARCHAR2,
  p_from_territory_code		IN VARCHAR2,
  -- output parameters
  x_return_status		OUT NOCOPY VARCHAR2,
  x_msg_count			OUT NOCOPY NUMBER,
  x_msg_data			OUT NOCOPY VARCHAR2,
  x_formatted_address		OUT NOCOPY VARCHAR2,
  x_formatted_lines_cnt		OUT NOCOPY NUMBER,
  x_formatted_address_tbl	OUT NOCOPY string_tbl_type
) IS

  l_api_name	VARCHAR2(30) := 'format_address(1)';
  l_sql_string	VARCHAR2(2000);

  l_style_code		hz_styles_b.style_code%TYPE;
  l_style_format_code	hz_style_formats_b.style_format_code%TYPE;

  l_variation_num	NUMBER;

  CURSOR c_location_territory(p_location_id IN NUMBER)
    IS SELECT country FROM HZ_LOCATIONS
    WHERE LOCATION_ID = p_location_id;

  -- Context Information

  l_to_territory_code		fnd_territories.territory_code%TYPE;
  l_to_language_code		fnd_languages.language_code%TYPE;
  l_from_territory_code		fnd_territories.territory_code%TYPE;
  l_from_language_code		fnd_languages.language_code%TYPE;
  l_country_name_lang		fnd_languages.language_code%TYPE;


BEGIN
  --
  --  Reset return status and messages
  --

  x_return_status := fnd_api.g_ret_sts_success;

  --
  --  Get the territory code of the location.
  --  for address formatting.
  --

  OPEN c_location_territory(p_location_id);
  FETCH c_location_territory INTO l_to_territory_code;
  IF c_location_territory%NOTFOUND THEN
    CLOSE c_location_territory;
    fnd_message.set_name('AR','HZ_FMT_INVALID_PK');
    fnd_message.set_token('OBJECT_CODE',k_addr_table_name);
    fnd_message.set_token('COLUMN_NAME',k_addr_table_pk);
    fnd_message.set_token('COLUMN_VALUE',to_char(p_location_id));
    fnd_msg_pub.add;
    RAISE fnd_api.g_exc_error;
  ELSE
    CLOSE c_location_territory;
  END IF;

  --
  --  Determine/Default the Context Information
  --

  -- "from" territory

  IF p_from_territory_code IS NOT NULL THEN
    l_from_territory_code := p_from_territory_code;
  ELSE
    get_default_ref_territory (
      x_ref_territory_code => l_from_territory_code
    );
  END IF;

  -- "from" language

    get_default_ref_language (
      x_ref_language_code => l_from_language_code
    );

  -- "to" territory was already assigned

  -- "to" language

  IF p_to_language_code IS NOT NULL THEN
    l_to_language_code := p_to_language_code;
  ELSE
    l_to_language_code := l_from_language_code;
  END IF;

  -- language for country line

  IF p_country_name_lang IS NOT NULL THEN
    l_country_name_lang := p_country_name_lang;
  ELSE
    get_country_name_lang (
      x_country_name_lang => l_country_name_lang
    );
  END IF;

  --
  --  Figure out NOCOPY which Style Format to use
  --

  IF p_style_format_code IS NOT NULL THEN
  -- bug 2656819 fix
  -- l_style_format_code := p_style_format_code;
    BEGIN
      select style_format_code into l_style_format_code
      from hz_style_formats_b
      where style_format_code = p_style_format_code;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        l_style_format_code := null;
    END;

  ELSE
    IF p_style_code IS NOT NULL THEN
      l_style_code := p_style_code;
    ELSE
      get_default_style (
        p_object_name  => k_addr_table_name,
        x_style_code   => l_style_code
      );

    END IF;
    IF l_style_code IS NOT NULL THEN
      get_style_format (
	  p_style_code		=>	l_style_code,
	  p_territory_code	=>	l_to_territory_code,
	  p_language_code	=>	l_to_language_code,
	  x_return_status	=>	x_return_status,
	  x_msg_count		=>	x_msg_count,
	  x_msg_data		=>	x_msg_data,
	  x_style_format_code	=>	l_style_format_code
      );
    END IF;
    IF x_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;
  END IF;

  IF l_style_format_code IS NULL THEN
    fnd_message.set_name('AR','HZ_FMT_CANNOT_GET_FORMAT');
    fnd_msg_pub.add;
    RAISE fnd_api.g_exc_error;
  END IF;

  --
  --  Make the context information available to external functions
  --  (which are dynamically invoked from the formatting routines)
  --  for the duration of the invocation of this function.
  --

  set_context (
    p_style_code		=> l_style_code,
    p_style_format_code		=> l_style_format_code,
    p_to_territory_code		=> l_to_territory_code,
    p_to_language_code		=> l_to_language_code,
    p_from_territory_code	=> l_from_territory_code,
    p_from_language_code	=> l_from_language_code,
    p_country_name_lang		=> l_country_name_lang
  );

  --
  --  Determine which format variation to use
  --

  determine_variation (
    p_style_format_code	=> l_style_format_code,
    p_object_name	=> k_addr_table_name,
    p_object_pk_name	=> k_addr_table_pk,
    p_object_pk_value	=> p_location_id,
    x_variation_num	=> l_variation_num
  );

  --
  --  Load the format layout database table into
  --  an internal pl/sql table.
  --

  load_internal_format_table(
    p_style_format_code	=> l_style_format_code,
    p_variation_num	=> l_variation_num,
    x_layout_tbl	=> g_layout_tbl,
    x_loaded_rows_cnt	=> g_layout_tbl_cnt
  );

  IF nvl(g_layout_tbl_cnt,0) = 0 THEN
    fnd_message.set_name('AR','HZ_FMT_NO_LAYOUT');
    fnd_msg_pub.add;
    RAISE fnd_api.g_exc_error;
  END IF;

  --
  --  Create a dynamic SQL query to get the address elements
  --

  g_pk_tbl_cnt := 1;
  g_pk_tbl(1).parm_name  := k_addr_table_pk;
  g_pk_tbl(1).parm_value := p_location_id;
  g_pk_tbl(1).parm_type  := 'N';  -- Numeric

  create_sql_string(
    p_table_name	=> k_addr_table_name,
    x_pk_tbl		=> g_pk_tbl,
    p_pk_tbl_cnt	=> g_pk_tbl_cnt,
    x_layout_tbl	=> g_layout_tbl,
    p_layout_tbl_cnt	=> g_layout_tbl_cnt,
    x_sql_string	=> l_sql_string
  );

  --
  --  Run the dynamic SQL query, and populate the internal table
  --  with the queried data.
  --

  execute_query(
    p_sql_string	=> l_sql_string,
    p_pk_tbl_cnt	=> g_pk_tbl_cnt,
    x_pk_tbl		=> g_pk_tbl,
    p_layout_tbl_cnt	=> g_layout_tbl_cnt,
    x_layout_tbl	=> g_layout_tbl
  );

  --
  --  Apply the "formatting rules" and format the results
  --

  format_results (
    p_space_replace		=> p_space_replace,
    p_layout_tbl_cnt		=> g_layout_tbl_cnt,
    x_layout_tbl		=> g_layout_tbl,
    x_formatted_lines_tbl	=> x_formatted_address_tbl,
    x_formatted_lines_cnt	=> x_formatted_lines_cnt
  );

  --
  -- Build the single formatting string from the table
  --

  IF x_formatted_lines_cnt > 0 THEN
    FOR i IN 1 .. x_formatted_lines_cnt
    LOOP
      IF i>1 THEN
        x_formatted_address := x_formatted_address || p_line_break || x_formatted_address_tbl(i);
      ELSE
        x_formatted_address := x_formatted_address_tbl(i);
      END IF;
    END LOOP;
  END IF;


EXCEPTION

  WHEN fnd_api.g_exc_error THEN
    x_return_status := fnd_api.g_ret_sts_error;
    fnd_msg_pub.count_and_get (
      p_encoded => fnd_api.g_false,
      p_count   => x_msg_count,
      p_data    => x_msg_data
    );

  WHEN OTHERS THEN
    x_return_status := fnd_api.g_ret_sts_unexp_error;
    IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
      fnd_msg_pub.add_exc_msg(
        g_pkg_name, l_api_name
      );
    END IF;
    fnd_msg_pub.count_and_get (
      p_encoded => fnd_api.g_false,
      p_count   => x_msg_count,
      p_data    => x_msg_data
    );

END format_address;


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
 | SCOPE:	Public
 |
 | ARGUMENTS:	(see definition in specification)
 |
 +=========================================================================*/

PROCEDURE format_address (
  -- input parameters
  p_style_code			IN VARCHAR2,
  p_style_format_code		IN VARCHAR2,
  p_line_break			IN VARCHAR2,
  p_space_replace		IN VARCHAR2,
  -- optional context parameters
  p_to_language_code		IN VARCHAR2,
  p_country_name_lang		IN VARCHAR2,
  p_from_territory_code		IN VARCHAR2,
  -- address components
  p_address_line_1		IN VARCHAR2,
  p_address_line_2		IN VARCHAR2,
  p_address_line_3		IN VARCHAR2,
  p_address_line_4		IN VARCHAR2,
  p_city			IN VARCHAR2,
  p_postal_code			IN VARCHAR2,
  p_state			IN VARCHAR2,
  p_province			IN VARCHAR2,
  p_county			IN VARCHAR2,
  p_country			IN VARCHAR2,
  p_address_lines_phonetic 	IN VARCHAR2,
  -- output parameters
  x_return_status		OUT NOCOPY VARCHAR2,
  x_msg_count			OUT NOCOPY NUMBER,
  x_msg_data			OUT NOCOPY VARCHAR2,
  x_formatted_address		OUT NOCOPY VARCHAR2,
  x_formatted_lines_cnt		OUT NOCOPY NUMBER,
  x_formatted_address_tbl	OUT NOCOPY string_tbl_type
) IS
  l_api_name	VARCHAR2(30) := 'format_address(2)';

  l_style_code		hz_styles_b.style_code%TYPE;
  l_style_format_code	hz_style_formats_b.style_format_code%TYPE;

  l_variation_num	NUMBER;

  -- Context Information

  l_to_territory_code		fnd_territories.territory_code%TYPE;
  l_to_language_code		fnd_languages.language_code%TYPE;
  l_from_territory_code		fnd_territories.territory_code%TYPE;
  l_from_language_code		fnd_languages.language_code%TYPE;
  l_country_name_lang		fnd_languages.language_code%TYPE;

BEGIN

  --
  --  Reset return status
  --

  x_return_status := fnd_api.g_ret_sts_success;


  --
  --  Determine/Default the Context Information
  --

  -- "from" territory

  IF p_from_territory_code IS NOT NULL THEN
    l_from_territory_code := substrb(p_from_territory_code,1,2);
  ELSE
    get_default_ref_territory (
      x_ref_territory_code => l_from_territory_code
    );
  END IF;

  -- "from" language

    get_default_ref_language (
      x_ref_language_code => l_from_language_code
    );

  -- "to" territory

  l_to_territory_code := substrb(p_country,1,2);

  -- "to" language

  IF p_to_language_code IS NOT NULL THEN
    l_to_language_code := p_to_language_code;
  ELSE
    l_to_language_code := l_from_language_code;
  END IF;

  -- language for country line

  IF p_country_name_lang IS NOT NULL THEN
    l_country_name_lang := p_country_name_lang;
  ELSE
    get_country_name_lang (
      x_country_name_lang => l_country_name_lang
    );
  END IF;


  --
  --  Figure out NOCOPY which Style Format to use
  --


  IF p_style_format_code IS NOT NULL THEN
  -- bug 2656819 fix
  -- l_style_format_code := p_style_format_code;
    BEGIN
      select style_format_code into l_style_format_code
      from hz_style_formats_b
      where style_format_code = p_style_format_code;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        l_style_format_code := null;
    END;

  ELSE
    IF p_style_code IS NOT NULL THEN
      l_style_code := p_style_code;
    ELSE
      get_default_style (
        p_object_name  => k_addr_table_name,
        x_style_code   => l_style_code
      );

    END IF;
    IF l_style_code IS NOT NULL THEN
      get_style_format (
	  p_style_code		=>	l_style_code,
	  p_territory_code	=>	l_to_territory_code,
	  p_language_code	=>	l_to_language_code,
	  x_return_status	=>	x_return_status,
	  x_msg_count		=>	x_msg_count,
	  x_msg_data		=>	x_msg_data,
	  x_style_format_code	=>	l_style_format_code
      );
    END IF;
    IF x_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;
  END IF;

  IF l_style_format_code IS NULL THEN
    fnd_message.set_name('AR','HZ_FMT_CANNOT_GET_FORMAT');
    fnd_msg_pub.add;
    RAISE fnd_api.g_exc_error;
  END IF;

  --
  --  Make the context information available to external functions
  --  (which are dynamically invoked from the formatting routines)
  --  for the duration of the invocation of this function.
  --

  set_context (
    p_style_code		=> l_style_code,
    p_style_format_code		=> l_style_format_code,
    p_to_territory_code		=> l_to_territory_code,
    p_to_language_code		=> l_to_language_code,
    p_from_territory_code	=> l_from_territory_code,
    p_from_language_code	=> l_from_language_code,
    p_country_name_lang		=> l_country_name_lang
  );

  --
  --  Load a PL/SQL mapping table so that we can access
  --  the parameter values dynamically
  --

  g_parm_tbl_cnt := 0;
  add_parm_table_row('ADDRESS1',	p_address_line_1, g_parm_tbl, g_parm_tbl_cnt);
  add_parm_table_row('ADDRESS2',	p_address_line_2, g_parm_tbl, g_parm_tbl_cnt);
  add_parm_table_row('ADDRESS3',	p_address_line_3, g_parm_tbl, g_parm_tbl_cnt);
  add_parm_table_row('ADDRESS4',	p_address_line_4, g_parm_tbl, g_parm_tbl_cnt);
  add_parm_table_row('CITY',		p_city, g_parm_tbl, g_parm_tbl_cnt);
  add_parm_table_row('POSTAL_CODE',	p_postal_code, g_parm_tbl, g_parm_tbl_cnt);
  add_parm_table_row('STATE',		p_state, g_parm_tbl, g_parm_tbl_cnt);
  add_parm_table_row('PROVINCE',	p_province, g_parm_tbl, g_parm_tbl_cnt);
  add_parm_table_row('COUNTY',		p_county, g_parm_tbl, g_parm_tbl_cnt);
  add_parm_table_row('COUNTRY',		p_country, g_parm_tbl, g_parm_tbl_cnt);
  add_parm_table_row('ADDRESS_LINES_PHONETIC',	p_address_lines_phonetic,
  	g_parm_tbl, g_parm_tbl_cnt);


  --
  --  Determine which format variation to use
  --

  determine_variation (
    p_style_format_code	=> l_style_format_code,
    p_parm_tbl_cnt	=> g_parm_tbl_cnt,
    x_parm_tbl		=> g_parm_tbl,
    x_variation_num	=> l_variation_num
  );

  --
  --  Load the format layout database table into
  --  an internal pl/sql table.
  --

  load_internal_format_table(
    p_style_format_code	=> l_style_format_code,
    p_variation_num	=> l_variation_num,
    x_layout_tbl	=> g_layout_tbl,
    x_loaded_rows_cnt	=> g_layout_tbl_cnt
  );

  IF nvl(g_layout_tbl_cnt,0) = 0 THEN
    fnd_message.set_name('AR','HZ_FMT_NO_LAYOUT');
    --fnd_message.set_token('STYLE_FORMAT',l_style_format_code);
    fnd_msg_pub.add;
    RAISE fnd_api.g_exc_error;
  END IF;

  --
  --  Copy attribute values from parameter table to layout table
  --

  copy_attribute_values (
    p_parm_tbl_cnt	=> g_parm_tbl_cnt,
    x_parm_tbl		=> g_parm_tbl,
    p_layout_tbl_cnt	=> g_layout_tbl_cnt,
    x_layout_tbl	=> g_layout_tbl
  );

  --
  --  Apply the "formatting rules" and format the results
  --

  format_results (
    p_space_replace		=> p_space_replace,
    p_layout_tbl_cnt		=> g_layout_tbl_cnt,
    x_layout_tbl		=> g_layout_tbl,
    x_formatted_lines_tbl	=> x_formatted_address_tbl,
    x_formatted_lines_cnt	=> x_formatted_lines_cnt
  );

  -- Build the single formatting string from the table

  IF x_formatted_lines_cnt > 0 THEN
    FOR i IN 1 .. x_formatted_lines_cnt
    LOOP
      IF i>1 THEN
        x_formatted_address := x_formatted_address || p_line_break || x_formatted_address_tbl(i);
      ELSE
        x_formatted_address := x_formatted_address_tbl(i);
      END IF;
    END LOOP;
  END IF;


EXCEPTION

  WHEN fnd_api.g_exc_error THEN
    x_return_status := fnd_api.g_ret_sts_error;
    fnd_msg_pub.count_and_get (
      p_encoded => fnd_api.g_false,
      p_count   => x_msg_count,
      p_data    => x_msg_data
    );

  WHEN OTHERS THEN
    x_return_status := fnd_api.g_ret_sts_unexp_error;
    IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
      fnd_msg_pub.add_exc_msg(
        g_pkg_name, l_api_name
      );
    END IF;
    fnd_msg_pub.count_and_get (
      p_encoded => fnd_api.g_false,
      p_count   => x_msg_count,
      p_data    => x_msg_data
    );

END format_address;

/*=========================================================================+
 |
 | PROCEDURE:	format_eloc_address
 |
 | DESCRIPTION
 |
 |	This procedure will format an address.  Parameters are supplied for
 |	various address elements, therefore this procedure can be used to
 |	format an address from any data source.
 |
 | SCOPE:	Public
 |
 | ARGUMENTS:	(see definition in specification)
 |
 +=========================================================================*/

PROCEDURE format_eloc_address (
  p_style_code			IN VARCHAR2,
  p_style_format_code		IN VARCHAR2,
  p_line_break			IN VARCHAR2,
  p_space_replace		IN VARCHAR2,
  p_to_language_code		IN VARCHAR2,
  p_country_name_lang		IN VARCHAR2,
  p_from_territory_code		IN VARCHAR2,
  p_address_line_1		IN VARCHAR2,
  p_address_line_2		IN VARCHAR2,
  p_address_line_3		IN VARCHAR2,
  p_address_line_4		IN VARCHAR2,
  p_city			IN VARCHAR2,
  p_postal_code			IN VARCHAR2,
  p_state			IN VARCHAR2,
  p_province			IN VARCHAR2,
  p_county			IN VARCHAR2,
  p_country			IN VARCHAR2,
  p_address_lines_phonetic 	IN VARCHAR2,
  x_return_status		OUT NOCOPY VARCHAR2,
  x_msg_count			OUT NOCOPY NUMBER,
  x_msg_data			OUT NOCOPY VARCHAR2,
  x_formatted_address		OUT NOCOPY VARCHAR2,
  x_formatted_lines_cnt		OUT NOCOPY NUMBER,
  x_formatted_address_tbl	OUT NOCOPY string_tbl_type
) IS
  l_api_name	VARCHAR2(30) := 'format_address(2)';

  l_style_code		hz_styles_b.style_code%TYPE;
  l_style_format_code	hz_style_formats_b.style_format_code%TYPE;

  l_variation_num	NUMBER;

  -- Context Information

  l_to_territory_code		fnd_territories.territory_code%TYPE;
  l_to_language_code		fnd_languages.language_code%TYPE;
  l_from_territory_code		fnd_territories.territory_code%TYPE;
  l_from_language_code		fnd_languages.language_code%TYPE;
  l_country_name_lang		fnd_languages.language_code%TYPE;

BEGIN

  --
  --  Reset return status
  --

  x_return_status := fnd_api.g_ret_sts_success;


  --
  --  Determine/Default the Context Information
  --

  -- "from" territory

  IF p_from_territory_code IS NOT NULL THEN
    l_from_territory_code := substrb(p_from_territory_code,1,2);
  ELSE
    get_default_eloc_ref_territory (
      x_ref_territory_code => l_from_territory_code
    );
  END IF;

  -- "from" language

    get_default_ref_language (
      x_ref_language_code => l_from_language_code
    );

  -- "to" territory

  l_to_territory_code := substrb(p_country,1,2);

  -- "to" language

  IF p_to_language_code IS NOT NULL THEN
    l_to_language_code := p_to_language_code;
  ELSE
    l_to_language_code := l_from_language_code;
  END IF;

  -- language for country line

  IF p_country_name_lang IS NOT NULL THEN
    l_country_name_lang := p_country_name_lang;
  ELSE
    get_country_name_lang (
      x_country_name_lang => l_country_name_lang
    );
  END IF;


  --
  --  Figure out NOCOPY which Style Format to use
  --


  IF p_style_format_code IS NOT NULL THEN
  -- bug 2656819 fix
  -- l_style_format_code := p_style_format_code;
    BEGIN
      select style_format_code into l_style_format_code
      from hz_style_formats_b
      where style_format_code = p_style_format_code;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        l_style_format_code := null;
    END;

  ELSE
    IF p_style_code IS NOT NULL THEN
      l_style_code := p_style_code;
    ELSE
      get_default_style (
        p_object_name  => k_addr_table_name,
        x_style_code   => l_style_code
      );

    END IF;
    IF l_style_code IS NOT NULL THEN
      get_style_format (
	  p_style_code		=>	l_style_code,
	  p_territory_code	=>	l_to_territory_code,
	  p_language_code	=>	l_to_language_code,
	  x_return_status	=>	x_return_status,
	  x_msg_count		=>	x_msg_count,
	  x_msg_data		=>	x_msg_data,
	  x_style_format_code	=>	l_style_format_code
      );
    END IF;
    IF x_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;
  END IF;

  IF l_style_format_code IS NULL THEN
    fnd_message.set_name('AR','HZ_FMT_CANNOT_GET_FORMAT');
    fnd_msg_pub.add;
    RAISE fnd_api.g_exc_error;
  END IF;

  --
  --  Make the context information available to external functions
  --  (which are dynamically invoked from the formatting routines)
  --  for the duration of the invocation of this function.
  --

  set_context (
    p_style_code		=> l_style_code,
    p_style_format_code		=> l_style_format_code,
    p_to_territory_code		=> l_to_territory_code,
    p_to_language_code		=> l_to_language_code,
    p_from_territory_code	=> l_from_territory_code,
    p_from_language_code	=> l_from_language_code,
    p_country_name_lang		=> l_country_name_lang
  );

  --
  --  Load a PL/SQL mapping table so that we can access
  --  the parameter values dynamically
  --

  g_parm_tbl_cnt := 0;
  add_parm_table_row('ADDRESS1',	p_address_line_1, g_parm_tbl, g_parm_tbl_cnt);
  add_parm_table_row('ADDRESS2',	p_address_line_2, g_parm_tbl, g_parm_tbl_cnt);
  add_parm_table_row('ADDRESS3',	p_address_line_3, g_parm_tbl, g_parm_tbl_cnt);
  add_parm_table_row('ADDRESS4',	p_address_line_4, g_parm_tbl, g_parm_tbl_cnt);
  add_parm_table_row('CITY',		p_city, g_parm_tbl, g_parm_tbl_cnt);
  add_parm_table_row('POSTAL_CODE',	p_postal_code, g_parm_tbl, g_parm_tbl_cnt);
  add_parm_table_row('STATE',		p_state, g_parm_tbl, g_parm_tbl_cnt);
  add_parm_table_row('PROVINCE',	p_province, g_parm_tbl, g_parm_tbl_cnt);
  add_parm_table_row('COUNTY',		p_county, g_parm_tbl, g_parm_tbl_cnt);
  add_parm_table_row('COUNTRY',		p_country, g_parm_tbl, g_parm_tbl_cnt);
  add_parm_table_row('ADDRESS_LINES_PHONETIC',	p_address_lines_phonetic,
  	g_parm_tbl, g_parm_tbl_cnt);


  --
  --  Determine which format variation to use
  --

  determine_variation (
    p_style_format_code	=> l_style_format_code,
    p_parm_tbl_cnt	=> g_parm_tbl_cnt,
    x_parm_tbl		=> g_parm_tbl,
    x_variation_num	=> l_variation_num
  );

  --
  --  Load the format layout database table into
  --  an internal pl/sql table.
  --

  load_internal_format_table(
    p_style_format_code	=> l_style_format_code,
    p_variation_num	=> l_variation_num,
    x_layout_tbl	=> g_layout_tbl,
    x_loaded_rows_cnt	=> g_layout_tbl_cnt
  );

  IF nvl(g_layout_tbl_cnt,0) = 0 THEN
    fnd_message.set_name('AR','HZ_FMT_NO_LAYOUT');
    --fnd_message.set_token('STYLE_FORMAT',l_style_format_code);
    fnd_msg_pub.add;
    RAISE fnd_api.g_exc_error;
  END IF;

  --
  --  Copy attribute values from parameter table to layout table
  --

  copy_attribute_values (
    p_parm_tbl_cnt	=> g_parm_tbl_cnt,
    x_parm_tbl		=> g_parm_tbl,
    p_layout_tbl_cnt	=> g_layout_tbl_cnt,
    x_layout_tbl	=> g_layout_tbl
  );

  --
  --  Apply the "formatting rules" and format the results
  --

  format_results (
    p_space_replace		=> p_space_replace,
    p_layout_tbl_cnt		=> g_layout_tbl_cnt,
    x_layout_tbl		=> g_layout_tbl,
    x_formatted_lines_tbl	=> x_formatted_address_tbl,
    x_formatted_lines_cnt	=> x_formatted_lines_cnt
  );

  -- Build the single formatting string from the table

  IF x_formatted_lines_cnt > 0 THEN
    FOR i IN 1 .. x_formatted_lines_cnt
    LOOP
      IF i>1 THEN
        x_formatted_address := x_formatted_address || p_line_break || x_formatted_address_tbl(i);
      ELSE
        x_formatted_address := x_formatted_address_tbl(i);
      END IF;
    END LOOP;
  END IF;


EXCEPTION

  WHEN fnd_api.g_exc_error THEN
    x_return_status := fnd_api.g_ret_sts_error;
    fnd_msg_pub.count_and_get (
      p_encoded => fnd_api.g_false,
      p_count   => x_msg_count,
      p_data    => x_msg_data
    );

  WHEN OTHERS THEN
    x_return_status := fnd_api.g_ret_sts_unexp_error;
    IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
      fnd_msg_pub.add_exc_msg(
        g_pkg_name, l_api_name
      );
    END IF;
    fnd_msg_pub.count_and_get (
      p_encoded => fnd_api.g_false,
      p_count   => x_msg_count,
      p_data    => x_msg_data
    );

END format_eloc_address;

/*=========================================================================+
 |
 | PROCEDURE:	format_address_layout (signature #1)
 |
 | DESCRIPTION
 |
 |	This procedure will format an address layout of a location that is
 |	stored in HZ_LOCATIONS.
 |
 | SCOPE:	Public
 |
 | ARGUMENTS:	(see definition in specification)
 |
 +=========================================================================*/


PROCEDURE format_address_layout (
  -- input parameters
  p_location_id			IN NUMBER,
  p_style_code			IN VARCHAR2,
  p_style_format_code		IN VARCHAR2,
  p_line_break			IN VARCHAR2,
  p_space_replace		IN VARCHAR2,
  -- optional context parameters
  p_to_language_code		IN VARCHAR2,
  p_country_name_lang		IN VARCHAR2,
  p_from_territory_code		IN VARCHAR2,
  -- output parameters
  x_return_status		OUT NOCOPY VARCHAR2,
  x_msg_count			OUT NOCOPY NUMBER,
  x_msg_data			OUT NOCOPY VARCHAR2,
  x_layout_tbl_cnt	        OUT NOCOPY NUMBER,
  x_layout_tbl		        OUT NOCOPY layout_tbl_type
) IS

  l_api_name	VARCHAR2(30) := 'format_address(1)';
  l_sql_string	VARCHAR2(2000);

  l_style_code		hz_styles_b.style_code%TYPE;
  l_style_format_code	hz_style_formats_b.style_format_code%TYPE;

  l_variation_num	NUMBER;

  CURSOR c_location_territory(p_location_id IN NUMBER)
    IS SELECT country FROM HZ_LOCATIONS
    WHERE LOCATION_ID = p_location_id;

  -- Context Information

  l_to_territory_code		fnd_territories.territory_code%TYPE;
  l_to_language_code		fnd_languages.language_code%TYPE;
  l_from_territory_code		fnd_territories.territory_code%TYPE;
  l_from_language_code		fnd_languages.language_code%TYPE;
  l_country_name_lang		fnd_languages.language_code%TYPE;


BEGIN
  --
  --  Reset return status and messages
  --

  x_return_status := fnd_api.g_ret_sts_success;

  --
  --  Get the territory code of the location.
  --  for address formatting.
  --

  OPEN c_location_territory(p_location_id);
  FETCH c_location_territory INTO l_to_territory_code;
  IF c_location_territory%NOTFOUND THEN
    CLOSE c_location_territory;
    fnd_message.set_name('AR','HZ_FMT_INVALID_PK');
    fnd_message.set_token('OBJECT_CODE',k_addr_table_name);
    fnd_message.set_token('COLUMN_NAME',k_addr_table_pk);
    fnd_message.set_token('COLUMN_VALUE',to_char(p_location_id));
    fnd_msg_pub.add;
    RAISE fnd_api.g_exc_error;
  ELSE
    CLOSE c_location_territory;
  END IF;

  --
  --  Determine/Default the Context Information
  --

  -- "from" territory

  IF p_from_territory_code IS NOT NULL THEN
    l_from_territory_code := p_from_territory_code;
  ELSE
    get_default_ref_territory (
      x_ref_territory_code => l_from_territory_code
    );
  END IF;

  -- "from" language

    get_default_ref_language (
      x_ref_language_code => l_from_language_code
    );

  -- "to" territory was already assigned

  -- "to" language

  IF p_to_language_code IS NOT NULL THEN
    l_to_language_code := p_to_language_code;
  ELSE
    l_to_language_code := l_from_language_code;
  END IF;

  -- language for country line

  IF p_country_name_lang IS NOT NULL THEN
    l_country_name_lang := p_country_name_lang;
  ELSE
    get_country_name_lang (
      x_country_name_lang => l_country_name_lang
    );
  END IF;

  --
  --  Figure out NOCOPY which Style Format to use
  --

  IF p_style_format_code IS NOT NULL THEN
  -- bug 2656819 fix
  -- l_style_format_code := p_style_format_code;
    BEGIN
      select style_format_code into l_style_format_code
      from hz_style_formats_b
      where style_format_code = p_style_format_code;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        l_style_format_code := null;
    END;

  ELSE
    IF p_style_code IS NOT NULL THEN
      l_style_code := p_style_code;
    ELSE
      get_default_style (
        p_object_name  => k_addr_table_name,
        x_style_code   => l_style_code
      );

    END IF;
    IF l_style_code IS NOT NULL THEN
      get_style_format (
	  p_style_code		=>	l_style_code,
	  p_territory_code	=>	l_to_territory_code,
	  p_language_code	=>	l_to_language_code,
	  x_return_status	=>	x_return_status,
	  x_msg_count		=>	x_msg_count,
	  x_msg_data		=>	x_msg_data,
	  x_style_format_code	=>	l_style_format_code
      );
    END IF;
    IF x_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;
  END IF;

  IF l_style_format_code IS NULL THEN
    fnd_message.set_name('AR','HZ_FMT_CANNOT_GET_FORMAT');
    fnd_msg_pub.add;
    RAISE fnd_api.g_exc_error;
  END IF;

  --
  --  Make the context information available to external functions
  --  (which are dynamically invoked from the formatting routines)
  --  for the duration of the invocation of this function.
  --

  set_context (
    p_style_code		=> l_style_code,
    p_style_format_code		=> l_style_format_code,
    p_to_territory_code		=> l_to_territory_code,
    p_to_language_code		=> l_to_language_code,
    p_from_territory_code	=> l_from_territory_code,
    p_from_language_code	=> l_from_language_code,
    p_country_name_lang		=> l_country_name_lang
  );

  --
  --  Determine which format variation to use
  --

  determine_variation (
    p_style_format_code	=> l_style_format_code,
    p_object_name	=> k_addr_table_name,
    p_object_pk_name	=> k_addr_table_pk,
    p_object_pk_value	=> p_location_id,
    x_variation_num	=> l_variation_num
  );

  --
  --  Load the format layout database table into
  --  an internal pl/sql table.
  --

  load_internal_format_table(
    p_style_format_code	=> l_style_format_code,
    p_variation_num	=> l_variation_num,
    x_layout_tbl	=> g_layout_tbl,
    x_loaded_rows_cnt	=> g_layout_tbl_cnt
  );

  IF nvl(g_layout_tbl_cnt,0) = 0 THEN
    fnd_message.set_name('AR','HZ_FMT_NO_LAYOUT');
    -- fnd_message.set_token('STYLE_FORMAT',l_style_format_code);
    fnd_msg_pub.add;
    RAISE fnd_api.g_exc_error;
  END IF;

  --
  --  Create a dynamic SQL query to get the address elements
  --

  g_pk_tbl_cnt := 1;
  g_pk_tbl(1).parm_name  := k_addr_table_pk;
  g_pk_tbl(1).parm_value := p_location_id;
  g_pk_tbl(1).parm_type  := 'N';  -- Numeric

  create_sql_string(
    p_table_name	=> k_addr_table_name,
    x_pk_tbl		=> g_pk_tbl,
    p_pk_tbl_cnt	=> g_pk_tbl_cnt,
    x_layout_tbl	=> g_layout_tbl,
    p_layout_tbl_cnt	=> g_layout_tbl_cnt,
    x_sql_string	=> l_sql_string
  );

  --
  --  Run the dynamic SQL query, and populate the internal table
  --  with the queried data.
  --

  execute_query(
    p_sql_string	=> l_sql_string,
    p_pk_tbl_cnt	=> g_pk_tbl_cnt,
    x_pk_tbl		=> g_pk_tbl,
    p_layout_tbl_cnt	=> g_layout_tbl_cnt,
    x_layout_tbl	=> g_layout_tbl
  );

  x_layout_tbl_cnt := g_layout_tbl_cnt;
  IF x_layout_tbl_cnt > 0 THEN
    FOR i IN 1 .. x_layout_tbl_cnt
    LOOP
      x_layout_tbl(i) := g_layout_tbl(i);
    END LOOP;
  END IF;

EXCEPTION

  WHEN fnd_api.g_exc_error THEN
    x_return_status := fnd_api.g_ret_sts_error;
    fnd_msg_pub.count_and_get (
      p_encoded => fnd_api.g_false,
      p_count   => x_msg_count,
      p_data    => x_msg_data
    );

  WHEN OTHERS THEN
    x_return_status := fnd_api.g_ret_sts_unexp_error;
    IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
      fnd_msg_pub.add_exc_msg(
        g_pkg_name, l_api_name
      );
    END IF;
    fnd_msg_pub.count_and_get (
      p_encoded => fnd_api.g_false,
      p_count   => x_msg_count,
      p_data    => x_msg_data
    );

END format_address_layout;

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
 | SCOPE:	Public
 |
 | ARGUMENTS:	(see definition in specification)
 |
 +=========================================================================*/

PROCEDURE format_address_layout (
  -- input parameters
  p_style_code			IN VARCHAR2,
  p_style_format_code		IN VARCHAR2,
  p_line_break			IN VARCHAR2,
  p_space_replace		IN VARCHAR2,
  -- optional context parameters
  p_to_language_code		IN VARCHAR2,
  p_country_name_lang		IN VARCHAR2,
  p_from_territory_code		IN VARCHAR2,
  -- address components
  p_address_line_1		IN VARCHAR2,
  p_address_line_2		IN VARCHAR2,
  p_address_line_3		IN VARCHAR2,
  p_address_line_4		IN VARCHAR2,
  p_city			IN VARCHAR2,
  p_postal_code			IN VARCHAR2,
  p_state			IN VARCHAR2,
  p_province			IN VARCHAR2,
  p_county			IN VARCHAR2,
  p_country			IN VARCHAR2,
  p_address_lines_phonetic 	IN VARCHAR2,
  -- output parameters
  x_return_status		OUT NOCOPY VARCHAR2,
  x_msg_count			OUT NOCOPY NUMBER,
  x_msg_data			OUT NOCOPY VARCHAR2,
  x_layout_tbl_cnt	        OUT NOCOPY NUMBER,
  x_layout_tbl		        OUT NOCOPY layout_tbl_type
) IS
  l_api_name	VARCHAR2(30) := 'format_address(2)';

  l_style_code		hz_styles_b.style_code%TYPE;
  l_style_format_code	hz_style_formats_b.style_format_code%TYPE;

  l_variation_num	NUMBER;

  -- Context Information

  l_to_territory_code		fnd_territories.territory_code%TYPE;
  l_to_language_code		fnd_languages.language_code%TYPE;
  l_from_territory_code		fnd_territories.territory_code%TYPE;
  l_from_language_code		fnd_languages.language_code%TYPE;
  l_country_name_lang		fnd_languages.language_code%TYPE;

  l_sql_string varchar2(200);
  l_var_counts number := 0;

BEGIN

  --
  --  Reset return status
  --

  x_return_status := fnd_api.g_ret_sts_success;


  --
  --  Determine/Default the Context Information
  --

  -- "from" territory

  IF p_from_territory_code IS NOT NULL THEN
    l_from_territory_code := substrb(p_from_territory_code,1,2);
  ELSE
    get_default_ref_territory (
      x_ref_territory_code => l_from_territory_code
    );
  END IF;

  -- "from" language

    get_default_ref_language (
      x_ref_language_code => l_from_language_code
    );

  -- "to" territory

  l_to_territory_code := substrb(p_country,1,2);

  -- "to" language

  IF p_to_language_code IS NOT NULL THEN
    l_to_language_code := p_to_language_code;
  ELSE
    l_to_language_code := l_from_language_code;
  END IF;

  -- language for country line

  IF p_country_name_lang IS NOT NULL THEN
    l_country_name_lang := p_country_name_lang;
  ELSE
    get_country_name_lang (
      x_country_name_lang => l_country_name_lang
    );
  END IF;


  --
  --  Figure out NOCOPY which Style Format to use
  --


  IF p_style_format_code IS NOT NULL THEN
  -- bug 2656819 fix
  -- l_style_format_code := p_style_format_code;
    BEGIN
      select style_format_code into l_style_format_code
      from hz_style_formats_b
      where style_format_code = p_style_format_code;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        l_style_format_code := null;
    END;

  ELSE
    IF p_style_code IS NOT NULL THEN
      l_style_code := p_style_code;
    ELSE
      get_default_style (
        p_object_name  => k_addr_table_name,
        x_style_code   => l_style_code
      );

    END IF;
    IF l_style_code IS NOT NULL THEN
      get_style_format (
	  p_style_code		=>	l_style_code,
	  p_territory_code	=>	l_to_territory_code,
	  p_language_code	=>	l_to_language_code,
	  x_return_status	=>	x_return_status,
	  x_msg_count		=>	x_msg_count,
	  x_msg_data		=>	x_msg_data,
	  x_style_format_code	=>	l_style_format_code
      );
    END IF;
    IF x_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;
  END IF;

  IF l_style_format_code IS NULL THEN
    fnd_message.set_name('AR','HZ_FMT_CANNOT_GET_FORMAT');
    fnd_msg_pub.add;
    RAISE fnd_api.g_exc_error;
  END IF;

  --
  --  Make the context information available to external functions
  --  (which are dynamically invoked from the formatting routines)
  --  for the duration of the invocation of this function.
  --

  set_context (
    p_style_code		=> l_style_code,
    p_style_format_code		=> l_style_format_code,
    p_to_territory_code		=> l_to_territory_code,
    p_to_language_code		=> l_to_language_code,
    p_from_territory_code	=> l_from_territory_code,
    p_from_language_code	=> l_from_language_code,
    p_country_name_lang		=> l_country_name_lang
  );

  --log the context
 if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'ar.hz.plsql','ADDRESS FORMAT:p_country:' || p_country);
  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'ar.hz.plsql','ADDRESS FORMAT:l_style_code:' || l_style_code);
  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'ar.hz.plsql','ADDRESS FORMAT:l_style_format_code:' || l_style_format_code);
  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'ar.hz.plsql','ADDRESS FORMAT:l_to_territory_code:' || l_to_territory_code);
  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'ar.hz.plsql','ADDRESS FORMAT:l_to_language_code:' || l_to_language_code);
  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'ar.hz.plsql','ADDRESS FORMAT:l_from_territory_code:' || l_from_territory_code);
  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'ar.hz.plsql','ADDRESS FORMAT:l_from_language_code:' || l_from_language_code);
  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'ar.hz.plsql','ADDRESS FORMAT:l_country_name_lang:' || l_country_name_lang);
 end if;
  --
  --  Load a PL/SQL mapping table so that we can access
  --  the parameter values dynamically
  --

  g_parm_tbl_cnt := 0;
  add_parm_table_row('ADDRESS1',	p_address_line_1, g_parm_tbl, g_parm_tbl_cnt);
  add_parm_table_row('ADDRESS2',	p_address_line_2, g_parm_tbl, g_parm_tbl_cnt);
  add_parm_table_row('ADDRESS3',	p_address_line_3, g_parm_tbl, g_parm_tbl_cnt);
  add_parm_table_row('ADDRESS4',	p_address_line_4, g_parm_tbl, g_parm_tbl_cnt);
  add_parm_table_row('CITY',		p_city, g_parm_tbl, g_parm_tbl_cnt);
  add_parm_table_row('POSTAL_CODE',	p_postal_code, g_parm_tbl, g_parm_tbl_cnt);
  add_parm_table_row('STATE',		p_state, g_parm_tbl, g_parm_tbl_cnt);
  add_parm_table_row('PROVINCE',	p_province, g_parm_tbl, g_parm_tbl_cnt);
  add_parm_table_row('COUNTY',		p_county, g_parm_tbl, g_parm_tbl_cnt);
  add_parm_table_row('COUNTRY',		p_country, g_parm_tbl, g_parm_tbl_cnt);
  add_parm_table_row('ADDRESS_LINES_PHONETIC',	p_address_lines_phonetic,
  	g_parm_tbl, g_parm_tbl_cnt);


  --
  --  Determine which format variation to use
  --

  determine_variation (
    p_style_format_code	=> l_style_format_code,
    p_parm_tbl_cnt	=> g_parm_tbl_cnt,
    x_parm_tbl		=> g_parm_tbl,
    x_variation_num	=> l_variation_num
  );

  -- bug 3636389, county field for US address create/update
  -- temp workaround of the design/data model issue
    -- log the variation number
 if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'ar.hz.plsql','ADDRESS FORMAT: returned l_variation_num: ' || l_variation_num);
 end if;

  if(p_country = 'US') then
        l_sql_string := 'select count(1) from HZ_STYLE_FMT_VARIATIONS ' ||
                        'where STYLE_FORMAT_CODE = :1 ' ||
                        'and VARIATION_NUMBER = 2 ' ||
                        'and (SYSDATE > start_date_active ' ||
                        'and SYSDATE <= NVL(end_date_active, SYSDATE))';

       BEGIN
           EXECUTE IMMEDIATE l_sql_string INTO l_var_counts USING l_style_format_code;
         EXCEPTION
         WHEN NO_DATA_FOUND THEN
          NULL;
         WHEN OTHERS THEN
          NULL;
       END;
     if (l_var_counts = 1) then
        l_variation_num := 2; --with county
     end if;
  end if;
  -- log the variation number
 if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
  FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'ar.hz.plsql','ADDRESS FORMAT: using l_variation_num: ' || l_variation_num);
 end if;
  --
  --  Load the format layout database table into
  --  an internal pl/sql table.
  --

  load_internal_format_table(
    p_style_format_code	=> l_style_format_code,
    p_variation_num	=> l_variation_num,
    x_layout_tbl	=> g_layout_tbl,
    x_loaded_rows_cnt	=> g_layout_tbl_cnt
  );

  IF nvl(g_layout_tbl_cnt,0) = 0 THEN
    fnd_message.set_name('AR','HZ_FMT_NO_LAYOUT');
    -- fnd_message.set_token('STYLE_FORMAT',l_style_format_code);
    fnd_msg_pub.add;
    RAISE fnd_api.g_exc_error;
  END IF;

  --
  --  Copy attribute values from parameter table to layout table
  --

  copy_attribute_values (
    p_parm_tbl_cnt	=> g_parm_tbl_cnt,
    x_parm_tbl		=> g_parm_tbl,
    p_layout_tbl_cnt	=> g_layout_tbl_cnt,
    x_layout_tbl	=> g_layout_tbl
  );

  x_layout_tbl_cnt := g_layout_tbl_cnt;
  IF x_layout_tbl_cnt > 0 THEN
    FOR i IN 1 .. x_layout_tbl_cnt
    LOOP
      x_layout_tbl(i) := g_layout_tbl(i);
    END LOOP;
  END IF;

EXCEPTION

  WHEN fnd_api.g_exc_error THEN
    x_return_status := fnd_api.g_ret_sts_error;
    fnd_msg_pub.count_and_get (
      p_encoded => fnd_api.g_false,
      p_count   => x_msg_count,
      p_data    => x_msg_data
    );

  WHEN OTHERS THEN
    x_return_status := fnd_api.g_ret_sts_unexp_error;
    IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
      fnd_msg_pub.add_exc_msg(
        g_pkg_name, l_api_name
      );
    END IF;
    fnd_msg_pub.count_and_get (
      p_encoded => fnd_api.g_false,
      p_count   => x_msg_count,
      p_data    => x_msg_data
    );

END format_address_layout;


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
 | ARGUMENTS:	(see definition in specification)
 |
 +=========================================================================*/

PROCEDURE format_name (
	-- input parameters
	p_party_id		IN NUMBER,
	p_style_code		IN VARCHAR2,
	p_style_format_code	IN VARCHAR2,
	p_line_break		IN VARCHAR2,
	p_space_replace		IN VARCHAR2,
	-- optional context parameters
	p_ref_language_code	IN VARCHAR2,
	p_ref_territory_code	IN VARCHAR2,
	-- output parameters
	x_return_status		OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2,
	x_formatted_name	OUT NOCOPY VARCHAR2,
	x_formatted_lines_cnt	OUT NOCOPY NUMBER,
	x_formatted_name_tbl	OUT NOCOPY string_tbl_type
) IS
  l_api_name	VARCHAR2(30) := 'format_name(1)';
  l_sql_string	VARCHAR2(2000);

  l_style_code		hz_styles_b.style_code%TYPE;
  l_style_format_code	hz_style_formats_b.style_format_code%TYPE;
  l_territory_code	fnd_territories.territory_code%TYPE;
  l_language_code	fnd_languages.language_code%TYPE;

  l_variation_num	NUMBER;

BEGIN
  --
  --  Reset return status and messages
  --

  x_return_status := fnd_api.g_ret_sts_success;

  --
  --  Determine/Default the Context Information
  --

  -- territory

  IF p_ref_territory_code IS NOT NULL THEN
    l_territory_code := p_ref_territory_code;
  ELSE
    get_default_ref_territory (
      x_ref_territory_code => l_territory_code
    );
  END IF;

  -- language

  IF p_ref_language_code IS NOT NULL THEN
    l_language_code := p_ref_language_code;
  ELSE
    get_default_ref_language (
      x_ref_language_code => l_language_code
    );
  END IF;

  --
  --  Figure out NOCOPY which Style Format to use
  --

  IF p_style_format_code IS NOT NULL THEN
  -- bug 2656819 fix
  -- l_style_format_code := p_style_format_code;
    BEGIN
      select style_format_code into l_style_format_code
      from hz_style_formats_b
      where style_format_code = p_style_format_code;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        l_style_format_code := null;
    END;

  ELSE
    IF p_style_code IS NOT NULL THEN
      l_style_code := p_style_code;
    ELSE
      get_default_style (
        p_object_name  => k_name_table_name,
        x_style_code   => l_style_code
      );

    END IF;
    IF l_style_code IS NOT NULL THEN
      get_style_format (
	  p_style_code		=>	l_style_code,
	  p_territory_code	=>	l_territory_code,
	  p_language_code	=>	l_language_code,
	  x_return_status	=>	x_return_status,
	  x_msg_count		=>	x_msg_count,
	  x_msg_data		=>	x_msg_data,
	  x_style_format_code	=>	l_style_format_code
      );
    END IF;
    IF x_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;
  END IF;


  IF l_style_format_code IS NULL THEN
    fnd_message.set_name('AR','HZ_FMT_CANNOT_GET_FORMAT');
    fnd_msg_pub.add;
    RAISE fnd_api.g_exc_error;
  END IF;

  --
  --  Make the context information available to external functions
  --  (which are dynamically invoked from the formatting routines)
  --  for the duration of the invocation of this function.
  --

  set_context (
    p_style_code		=> l_style_code,
    p_style_format_code		=> l_style_format_code,
    p_to_territory_code		=> l_territory_code,
    p_to_language_code		=> l_language_code,
    p_from_territory_code	=> l_territory_code,
    p_from_language_code	=> l_language_code,
    p_country_name_lang		=> l_language_code
  );

  --
  --  Determine which format variation to use
  --

  determine_variation (
    p_style_format_code	=> l_style_format_code,
    p_object_name	=> k_name_table_name,
    p_object_pk_name	=> k_name_table_pk,
    p_object_pk_value	=> p_party_id,
    x_variation_num	=> l_variation_num
  );

  --
  --  Load the format layout database table into
  --  an internal pl/sql table.
  --

  load_internal_format_table(
    p_style_format_code	=> l_style_format_code,
    p_variation_num     => l_variation_num,
    x_layout_tbl	=> g_layout_tbl,
    x_loaded_rows_cnt	=> g_layout_tbl_cnt
  );

  IF nvl(g_layout_tbl_cnt,0) = 0 THEN
    fnd_message.set_name('AR','HZ_FMT_NO_LAYOUT');
    -- fnd_message.set_token('STYLE_FORMAT',l_style_format_code);
    fnd_msg_pub.add;
    RAISE fnd_api.g_exc_error;
  END IF;

  --
  --  Create a dynamic SQL query to get the name elements
  --

  g_pk_tbl_cnt := 1;
  g_pk_tbl(1).parm_name  := k_name_table_pk;
  g_pk_tbl(1).parm_value := p_party_id;
  g_pk_tbl(1).parm_type  := 'N';  -- Numeric

  create_sql_string(
    p_table_name	=> k_name_table_name,
    x_pk_tbl		=> g_pk_tbl,
    p_pk_tbl_cnt	=> g_pk_tbl_cnt,
    x_layout_tbl	=> g_layout_tbl,
    p_layout_tbl_cnt	=> g_layout_tbl_cnt,
    x_sql_string	=> l_sql_string
  );

  --
  --  Run the dynamic SQL query, and populate the internal table
  --  with the queried data.
  --

  execute_query(
    p_sql_string	=> l_sql_string,
    p_pk_tbl_cnt	=> g_pk_tbl_cnt,
    x_pk_tbl		=> g_pk_tbl,
    p_layout_tbl_cnt	=> g_layout_tbl_cnt,
    x_layout_tbl	=> g_layout_tbl
  );

  --
  --  Apply the "formatting rules" and format the results
  --

  format_results (
    p_space_replace		=> p_space_replace,
    p_layout_tbl_cnt		=> g_layout_tbl_cnt,
    x_layout_tbl		=> g_layout_tbl,
    x_formatted_lines_tbl	=> x_formatted_name_tbl,
    x_formatted_lines_cnt	=> x_formatted_lines_cnt
  );

  -- Build the single formatting string from the table

  IF x_formatted_lines_cnt > 0 THEN

    FOR i IN 1 .. x_formatted_lines_cnt
    LOOP
      IF i>1 THEN
        x_formatted_name := x_formatted_name || p_line_break || x_formatted_name_tbl(i);
      ELSE
        x_formatted_name := x_formatted_name_tbl(i);
      END IF;
    END LOOP;

  END IF;
EXCEPTION

  WHEN fnd_api.g_exc_error THEN
    x_return_status := fnd_api.g_ret_sts_error;
    fnd_msg_pub.count_and_get (
      p_encoded => fnd_api.g_false,
      p_count   => x_msg_count,
      p_data    => x_msg_data
    );

  WHEN OTHERS THEN
    x_return_status := fnd_api.g_ret_sts_unexp_error;
    IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
      fnd_msg_pub.add_exc_msg(
        g_pkg_name, l_api_name
      );
    END IF;
    fnd_msg_pub.count_and_get (
      p_encoded => fnd_api.g_false,
      p_count   => x_msg_count,
      p_data    => x_msg_data
    );

END format_name;

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
 | ARGUMENTS:	(see definition in specification)
 |
 +=========================================================================*/

PROCEDURE format_name (
  -- input parameters
  p_style_code			IN VARCHAR2,
  p_style_format_code		IN VARCHAR2,
  p_line_break			IN VARCHAR2,
  p_space_replace		IN VARCHAR2,
  -- optional context parameters
  p_ref_language_code		IN VARCHAR2,
  p_ref_territory_code		IN VARCHAR2,
  -- person name components
  p_person_title		IN VARCHAR2,
  p_person_first_name		IN VARCHAR2,
  p_person_middle_name		IN VARCHAR2,
  p_person_last_name		IN VARCHAR2,
  p_person_name_suffix		IN VARCHAR2,
  p_person_known_as		IN VARCHAR2,
  p_first_name_phonetic		IN VARCHAR2,
  p_middle_name_phonetic	IN VARCHAR2,
  p_last_name_phonetic		IN VARCHAR2,
  -- output parameters
  x_return_status		OUT NOCOPY VARCHAR2,
  x_msg_count			OUT NOCOPY NUMBER,
  x_msg_data			OUT NOCOPY VARCHAR2,
  x_formatted_name		OUT NOCOPY VARCHAR2,
  x_formatted_lines_cnt		OUT NOCOPY NUMBER,
  x_formatted_name_tbl		OUT NOCOPY string_tbl_type
) IS
  l_api_name	VARCHAR2(30) := 'format_name(2)';

  l_style_code		hz_styles_b.style_code%TYPE;
  l_style_format_code	hz_style_formats_b.style_format_code%TYPE;
  l_territory_code	fnd_territories.territory_code%TYPE;
  l_language_code	fnd_languages.language_code%TYPE;
  l_variation_num	NUMBER;
BEGIN
  --
  --  Reset return status and messages
  --

  x_return_status := fnd_api.g_ret_sts_success;

  --
  --  Determine/Default the Context Information
  --

  -- territory

  IF p_ref_territory_code IS NOT NULL THEN
    l_territory_code := p_ref_territory_code;
  ELSE
    get_default_ref_territory (
      x_ref_territory_code => l_territory_code
    );
  END IF;

  -- language

  IF p_ref_language_code IS NOT NULL THEN
    l_language_code := p_ref_language_code;
  ELSE
    get_default_ref_language (
      x_ref_language_code => l_language_code
    );
  END IF;

  --
  --  Figure out NOCOPY which Style Format to use
  --

  IF p_style_format_code IS NOT NULL THEN
  -- bug 2656819 fix
  -- l_style_format_code := p_style_format_code;
    BEGIN
      select style_format_code into l_style_format_code
      from hz_style_formats_b
      where style_format_code = p_style_format_code;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        l_style_format_code := null;
    END;

  ELSE
    IF p_style_code IS NOT NULL THEN
      l_style_code := p_style_code;
    ELSE
      get_default_style (
        p_object_name  => k_name_table_name,
        x_style_code   => l_style_code
      );

    END IF;
    IF l_style_code IS NOT NULL THEN
      get_style_format (
	  p_style_code		=>	l_style_code,
	  p_territory_code	=>	l_territory_code,
	  p_language_code	=>	l_language_code,
	  x_return_status	=>	x_return_status,
	  x_msg_count		=>	x_msg_count,
	  x_msg_data		=>	x_msg_data,
	  x_style_format_code	=>	l_style_format_code
      );
    END IF;
    IF x_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;
  END IF;


  IF l_style_format_code IS NULL THEN
    fnd_message.set_name('AR','HZ_FMT_CANNOT_GET_FORMAT');
    fnd_msg_pub.add;
    RAISE fnd_api.g_exc_error;
  END IF;

  --
  --  Make the context information available to external functions
  --  (which are dynamically invoked from the formatting routines)
  --  for the duration of the invocation of this function.
  --

  set_context (
    p_style_code		=> l_style_code,
    p_style_format_code		=> l_style_format_code,
    p_to_territory_code		=> l_territory_code,
    p_to_language_code		=> l_language_code,
    p_from_territory_code	=> l_territory_code,
    p_from_language_code	=> l_language_code,
    p_country_name_lang		=> l_language_code
  );

  --
  --  Load a PL/SQL mapping table so that we can access
  --  the parameter values dynamically
  --

  g_parm_tbl_cnt := 0;
  add_parm_table_row('PERSON_TITLE',
  	p_person_title, g_parm_tbl, g_parm_tbl_cnt);
  add_parm_table_row('PERSON_FIRST_NAME',
  	p_person_first_name, g_parm_tbl, g_parm_tbl_cnt);
  add_parm_table_row('PERSON_MIDDLE_NAME',
  	p_person_middle_name, g_parm_tbl, g_parm_tbl_cnt);
  add_parm_table_row('PERSON_LAST_NAME',
  	p_person_last_name, g_parm_tbl, g_parm_tbl_cnt);
  add_parm_table_row('PERSON_NAME_SUFFIX',
  	p_person_name_suffix, g_parm_tbl, g_parm_tbl_cnt);
  add_parm_table_row('PERSON_KNOWN_AS',
  	p_person_known_as, g_parm_tbl, g_parm_tbl_cnt);
  add_parm_table_row('PERSON_FIRST_NAME_PHONETIC',
  	p_first_name_phonetic, g_parm_tbl, g_parm_tbl_cnt);
  add_parm_table_row('PERSON_LAST_NAME_PHONETIC',
  	p_last_name_phonetic, g_parm_tbl, g_parm_tbl_cnt);
  add_parm_table_row('PERSON_MIDDLE_NAME_PHONETIC',
  	p_middle_name_phonetic, g_parm_tbl, g_parm_tbl_cnt);

  --
  --  Determine which format variation to use
  --

  determine_variation (
    p_style_format_code	=> l_style_format_code,
    p_parm_tbl_cnt	=> g_parm_tbl_cnt,
    x_parm_tbl		=> g_parm_tbl,
    x_variation_num	=> l_variation_num
  );

  --
  --  Load the format layout database table into
  --  an internal pl/sql table.
  --

  load_internal_format_table(
    p_style_format_code	=> l_style_format_code,
    p_variation_num	=> l_variation_num,
    x_layout_tbl	=> g_layout_tbl,
    x_loaded_rows_cnt	=> g_layout_tbl_cnt
  );

  IF nvl(g_layout_tbl_cnt,0) = 0 THEN
    fnd_message.set_name('AR','HZ_FMT_NO_LAYOUT');
    -- fnd_message.set_token('STYLE_FORMAT',l_style_format_code);
    fnd_msg_pub.add;
    RAISE fnd_api.g_exc_error;
  END IF;

  --
  --  Copy attribute values from parameter table to layout table
  --

  copy_attribute_values (
    p_parm_tbl_cnt	=> g_parm_tbl_cnt,
    x_parm_tbl		=> g_parm_tbl,
    p_layout_tbl_cnt	=> g_layout_tbl_cnt,
    x_layout_tbl	=> g_layout_tbl
  );

  --
  --  Apply the "formatting rules" and format the results
  --

  format_results (
    p_space_replace		=> p_space_replace,
    p_layout_tbl_cnt		=> g_layout_tbl_cnt,
    x_layout_tbl		=> g_layout_tbl,
    x_formatted_lines_tbl	=> x_formatted_name_tbl,
    x_formatted_lines_cnt	=> x_formatted_lines_cnt
  );

  -- Build the single formatting string from the table

  IF x_formatted_lines_cnt > 0 THEN
    FOR i IN 1 .. x_formatted_lines_cnt
    LOOP
      IF i>1 THEN
        x_formatted_name := x_formatted_name || p_line_break || x_formatted_name_tbl(i);
      ELSE
        x_formatted_name := x_formatted_name_tbl(i);
      END IF;
    END LOOP;
  END IF;


EXCEPTION

  WHEN fnd_api.g_exc_error THEN
    x_return_status := fnd_api.g_ret_sts_error;
    fnd_msg_pub.count_and_get (
      p_encoded => fnd_api.g_false,
      p_count   => x_msg_count,
      p_data    => x_msg_data
    );

  WHEN OTHERS THEN
    x_return_status := fnd_api.g_ret_sts_unexp_error;
    IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
      fnd_msg_pub.add_exc_msg(
        g_pkg_name, l_api_name
      );
    END IF;
    fnd_msg_pub.count_and_get (
      p_encoded => fnd_api.g_false,
      p_count   => x_msg_count,
      p_data    => x_msg_data
    );

END format_name;

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
 | ARGUMENTS:	(see definition in specification)
 |
 +=========================================================================*/

PROCEDURE format_data (
  -- input parameters
  p_object_code			IN VARCHAR2,
  p_object_key_1		IN VARCHAR2,
  p_object_key_2		IN VARCHAR2,
  p_object_key_3		IN VARCHAR2,
  p_object_key_4		IN VARCHAR2,
  p_style_code			IN VARCHAR2,
  p_style_format_code		IN VARCHAR2,
  p_line_break			IN VARCHAR2,
  p_space_replace		IN VARCHAR2,
  -- optional context parameters
  p_ref_language_code		IN VARCHAR2,
  p_ref_territory_code		IN VARCHAR2,
  -- output parameters
  x_return_status		OUT NOCOPY VARCHAR2,
  x_msg_count			OUT NOCOPY NUMBER,
  x_msg_data			OUT NOCOPY VARCHAR2,
  x_formatted_data		OUT NOCOPY VARCHAR2,
  x_formatted_lines_cnt		OUT NOCOPY NUMBER,
  x_formatted_data_tbl		OUT NOCOPY string_tbl_type
) IS
  l_api_name	VARCHAR2(30) := 'format_data';

  l_style_code		hz_styles_b.style_code%TYPE;
  l_style_format_code	hz_style_formats_b.style_format_code%TYPE;
  l_territory_code	fnd_territories.territory_code%TYPE;
  l_language_code	fnd_languages.language_code%TYPE;
  l_variation_num	NUMBER;
  l_pk_column_count	NUMBER := 0;

  l_pk_name		VARCHAR2(30);
  l_pk_value		VARCHAR2(60);

  l_key_value		VARCHAR2(60);
  l_sql_string		VARCHAR2(2000);

  CURSOR c_primary_keys (p_table_name IN VARCHAR2) IS
  SELECT
    c.column_name,
    c.column_type,
    c.width
  FROM
    fnd_tables t,
    fnd_primary_keys pk,
    fnd_primary_key_columns pkc,
    fnd_columns c
  WHERE
          t.table_name     = p_table_name
    AND  pk.application_id =   t.application_id
    AND  pk.table_id       =   t.table_id
    AND pkc.application_id =  pk.application_id
    AND pkc.table_id       =  pk.table_id
    AND pkc.primary_key_id =  pk.primary_key_id
    AND   c.application_id = pkc.application_id
    AND   c.table_id       = pkc.table_id
    AND   c.column_id      = pkc.column_id
  ORDER BY
    pkc.primary_key_sequence;

  l_tab_count NUMBER;

BEGIN

  --
  --  Reset return status and messages
  --

  x_return_status := fnd_api.g_ret_sts_success;

  --
  --  Validate the object code
  --

  SELECT COUNT(TABLE_ID) INTO l_tab_count
  FROM FND_TABLES WHERE TABLE_NAME = p_object_code;
  IF l_tab_count = 0 THEN
    fnd_message.set_name('AR','HZ_INVALID_ENTITY_NAME');
    fnd_msg_pub.add;
    RAISE fnd_api.g_exc_error;
  END IF;

  --
  --  Determine/Default the Context Information
  --

  -- territory

  IF p_ref_territory_code IS NOT NULL THEN
    l_territory_code := p_ref_territory_code;
  ELSE
    get_default_ref_territory (
      x_ref_territory_code => l_territory_code
    );
  END IF;

  -- language

  IF p_ref_language_code IS NOT NULL THEN
    l_language_code := p_ref_language_code;
  ELSE
    get_default_ref_language (
      x_ref_language_code => l_language_code
    );
  END IF;

  --
  --  Figure out NOCOPY which Style Format to use
  --

  IF p_style_format_code IS NOT NULL THEN
  -- bug 2656819 fix
  -- l_style_format_code := p_style_format_code;
    BEGIN
      select style_format_code into l_style_format_code
      from hz_style_formats_b
      where style_format_code = p_style_format_code;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        l_style_format_code := null;
    END;

  ELSE
    IF p_style_code IS NOT NULL THEN
      l_style_code := p_style_code;
    ELSE
      get_default_style (
        p_object_name  => p_object_code,
        x_style_code   => l_style_code
      );

    END IF;
    IF l_style_code IS NOT NULL THEN
      get_style_format (
	  p_style_code		=>	l_style_code,
	  p_territory_code	=>	l_territory_code,
	  p_language_code	=>	l_language_code,
	  x_return_status	=>	x_return_status,
	  x_msg_count		=>	x_msg_count,
	  x_msg_data		=>	x_msg_data,
	  x_style_format_code	=>	l_style_format_code
      );
    END IF;
    IF x_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;
  END IF;


  IF l_style_format_code IS NULL THEN
    fnd_message.set_name('AR','HZ_FMT_CANNOT_GET_FORMAT');
    fnd_msg_pub.add;
    RAISE fnd_api.g_exc_error;
  END IF;

  --
  --  Make the context information available to external functions
  --  (which are dynamically invoked from the formatting routines)
  --  for the duration of the invocation of this function.
  --

  set_context (
    p_style_code		=> l_style_code,
    p_style_format_code		=> l_style_format_code,
    p_to_territory_code		=> l_territory_code,
    p_to_language_code		=> l_language_code,
    p_from_territory_code	=> l_territory_code,
    p_from_language_code	=> l_language_code,
    p_country_name_lang		=> l_language_code
  );

  --
  --  Determine the primary key.  In case of a multi-part primary key,
  --  construct a "where" clause.
  --

  g_pk_tbl_cnt := 0;
  FOR l_primary_key IN c_primary_keys (p_object_code)
  LOOP
    l_pk_column_count := l_pk_column_count + 1;

    IF l_pk_column_count = 1 THEN l_key_value := p_object_key_1;
    ELSIF l_pk_column_count = 2 THEN l_key_value := p_object_key_2;
    ELSIF l_pk_column_count = 3 THEN l_key_value := p_object_key_3;
    ELSIF l_pk_column_count = 4 THEN l_key_value := p_object_key_4;
    END IF;

    add_parm_table_row(l_primary_key.column_name, l_key_value,
    	g_pk_tbl, g_pk_tbl_cnt, l_primary_key.column_type);


    IF l_pk_column_count = 1 THEN
      l_pk_name  := l_primary_key.column_name;
      l_pk_value := l_key_value;
    END IF;

  END LOOP;

  --
  --  Determine which format variation to use
  --

  determine_variation (
    p_style_format_code	=> l_style_format_code,
    p_object_name	=> p_object_code,
    p_object_pk_name	=> l_pk_name,
    p_object_pk_value	=> l_pk_value,
    x_variation_num	=> l_variation_num
  );

  --
  --
  --  Load the format layout database table into
  --  an internal pl/sql table.
  --

  load_internal_format_table(
    p_style_format_code	=> l_style_format_code,
    p_variation_num     => l_variation_num,
    x_layout_tbl	=> g_layout_tbl,
    x_loaded_rows_cnt	=> g_layout_tbl_cnt
  );

  IF nvl(g_layout_tbl_cnt,0) = 0 THEN
    fnd_message.set_name('AR','HZ_FMT_NO_LAYOUT');
    fnd_msg_pub.add;
    RAISE fnd_api.g_exc_error;
  END IF;

  --
  --  Create a dynamic SQL query to get the name elements
  --

 create_sql_string(
    p_table_name	=> p_object_code,
    x_pk_tbl		=> g_pk_tbl,
    p_pk_tbl_cnt	=> g_pk_tbl_cnt,
    x_layout_tbl	=> g_layout_tbl,
    p_layout_tbl_cnt	=> g_layout_tbl_cnt,
    x_sql_string	=> l_sql_string
  );

  --
  --  Run the dynamic SQL query, and populate the internal table
  --  with the queried data.
  --

  execute_query(
    p_sql_string	=> l_sql_string,
    p_pk_tbl_cnt	=> g_pk_tbl_cnt,
    x_pk_tbl		=> g_pk_tbl,
    p_layout_tbl_cnt	=> g_layout_tbl_cnt,
    x_layout_tbl	=> g_layout_tbl
  );

  --
  --  Apply the "formatting rules" and format the results
  --

  format_results (
    p_space_replace		=> p_space_replace,
    p_layout_tbl_cnt		=> g_layout_tbl_cnt,
    x_layout_tbl		=> g_layout_tbl,
    x_formatted_lines_tbl	=> x_formatted_data_tbl,
    x_formatted_lines_cnt	=> x_formatted_lines_cnt
  );

  -- Build the single formatting string from the table

  IF x_formatted_lines_cnt > 0 THEN

    FOR i IN 1 .. x_formatted_lines_cnt
    LOOP
      IF i>1 THEN
        x_formatted_data := x_formatted_data || p_line_break || x_formatted_data_tbl(i);
      ELSE
        x_formatted_data := x_formatted_data_tbl(i);
      END IF;
    END LOOP;

  END IF;

EXCEPTION

  WHEN fnd_api.g_exc_error THEN
    x_return_status := fnd_api.g_ret_sts_error;
    fnd_msg_pub.count_and_get (
      p_encoded => fnd_api.g_false,
      p_count   => x_msg_count,
      p_data    => x_msg_data
    );

  WHEN OTHERS THEN
    x_return_status := fnd_api.g_ret_sts_unexp_error;
    IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
      fnd_msg_pub.add_exc_msg(
        g_pkg_name, l_api_name
      );
    END IF;
    fnd_msg_pub.count_and_get (
      p_encoded => fnd_api.g_false,
      p_count   => x_msg_count,
      p_data    => x_msg_data
    );
END format_data;


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
 +=========================================================================*/

FUNCTION format_address(
  p_location_id			IN NUMBER,
  p_style_code			IN VARCHAR2,
  p_style_format_code		IN VARCHAR2,
  p_line_break			IN VARCHAR2,
  p_space_replace		IN VARCHAR2,
  p_to_language_code		IN VARCHAR2,
  p_country_name_lang		IN VARCHAR2,
  p_from_territory_code		IN VARCHAR2
) RETURN VARCHAR2
IS
  l_return_status	VARCHAR2(1);
  l_msg_count		NUMBER;
-----Bug No.4145590
  l_msg_data		VARCHAR2(2000);
  l_formatted_address	VARCHAR2(360);

  l_tbl_cnt	NUMBER;
  l_tbl		string_tbl_type;
BEGIN
 -- fnd_msg_pub.initialize; /*Bug 3531172*/
  format_address (
	-- input parameters
	p_location_id		=> p_location_id,
	p_style_code		=> p_style_code,
	p_style_format_code	=> p_style_format_code,
	p_line_break		=> p_line_break,
	p_space_replace		=> p_space_replace,
	-- optional context
	p_to_language_code	=> p_to_language_code,
	p_country_name_lang	=> p_country_name_lang,
	p_from_territory_code	=> p_from_territory_code,
	-- output parameters
	x_return_status		=> l_return_status,
	x_msg_count		=> l_msg_count,
	x_msg_data		=> l_msg_data,
	x_formatted_address	=> l_formatted_address,
	x_formatted_lines_cnt	=> l_tbl_cnt,
	x_formatted_address_tbl	=> l_tbl
  );
-----Bug No.4145590
IF l_return_status <> fnd_api.g_ret_sts_success THEN
      return NULL;
END IF;

  RETURN l_formatted_address;

EXCEPTION
-----Bug No.4145590
  WHEN OTHERS THEN
  fnd_message.set_name('AR','HZ_API_OTHERS_EXCEP');
  fnd_message.set_token('ERROR',SQLERRM);
  fnd_msg_pub.add;
  return NULL;

END format_address;


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
) RETURN VARCHAR2
IS
  l_return_status	VARCHAR2(1);
  l_msg_count		NUMBER;
-----Bug No.4145590
  l_msg_data		VARCHAR2(2000);
  l_formatted_address	VARCHAR2(360);

  l_tbl_cnt	NUMBER;
  l_tbl		string_tbl_type;
BEGIN

format_address (
  p_style_code			=> 'POSTAL_ADDR',
  p_line_break			=> ', ',
  p_space_replace		=> ' ',
  -- optional context parameters
 -- p_to_language_code		IN VARCHAR2 DEFAULT NULL,
 -- p_country_name_lang		IN VARCHAR2 DEFAULT NULL,
 -- p_from_territory_code		IN VARCHAR2 DEFAULT NULL,
  -- address components
  p_address_line_1		=> p_address_line_1,
  p_address_line_2		=> p_address_line_2,
  p_address_line_3		=> p_address_line_3,
  p_address_line_4		=> p_address_line_4,
  p_city			=> p_city,
  p_postal_code		=> p_postal_code,
  p_state			=> p_state,
  p_province		=> p_province,
  p_county			=> p_county,
  p_country			=> p_country,
  p_address_lines_phonetic 	=> p_address_lines_phonetic,
  	-- output parameters
	x_return_status		=> l_return_status,
	x_msg_count		=> l_msg_count,
	x_msg_data		=> l_msg_data,
	x_formatted_address	=> l_formatted_address,
	x_formatted_lines_cnt	=> l_tbl_cnt,
	x_formatted_address_tbl	=> l_tbl
);
-----Bug No.4145590
IF l_return_status <> fnd_api.g_ret_sts_success THEN
      return NULL;
END IF;
  RETURN l_formatted_address;

EXCEPTION
-----Bug No.4145590
  WHEN OTHERS THEN
  fnd_message.set_name('AR','HZ_API_OTHERS_EXCEP');
  fnd_message.set_token('ERROR',SQLERRM);
  fnd_msg_pub.add;
  return NULL;

END format_address_lov;


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
  p_style_code			IN VARCHAR2,
  p_style_format_code		IN VARCHAR2,
  p_line_break			IN VARCHAR2,
  p_space_replace		IN VARCHAR2,
  p_ref_language_code		IN VARCHAR2,
  p_ref_territory_code		IN VARCHAR2
) RETURN VARCHAR2
IS
  l_return_status	VARCHAR2(1);
  l_msg_count		NUMBER;
  l_msg_data		VARCHAR2(2000);
  l_formatted_name	VARCHAR2(360);
  l_formatted_lines_cnt	NUMBER;
  l_formatted_name_tbl	string_tbl_type;

BEGIN
--  fnd_msg_pub.initialize; /*Bug 3531172*/
  format_name (
	-- input parameters
	p_party_id		=> p_party_id,
	p_style_code		=> p_style_code,
	p_style_format_code	=> p_style_format_code,
	p_line_break		=> p_line_break,
	p_space_replace		=> p_space_replace,
	-- optional context
	p_ref_language_code	=> p_ref_language_code,
	p_ref_territory_code	=> p_ref_territory_code,
	-- output parameters
	x_return_status		=> l_return_status,
	x_msg_count		=> l_msg_count,
	x_msg_data		=> l_msg_data,
	x_formatted_name	=> l_formatted_name,
	x_formatted_lines_cnt	=> l_formatted_lines_cnt,
	x_formatted_name_tbl	=> l_formatted_name_tbl
  );

-----Bug No.4145590
IF l_return_status <> fnd_api.g_ret_sts_success THEN
     return NULL;
END IF;
  RETURN l_formatted_name;

EXCEPTION
-----Bug No.4145590
  WHEN OTHERS THEN
  fnd_message.set_name('AR','HZ_API_OTHERS_EXCEP');
  fnd_message.set_token('ERROR',SQLERRM);
  fnd_msg_pub.add;
  return NULL;

END format_name;

/******************** PUBLIC UTILITY PROCEDURES ***************************/


/*=========================================================================+
 |
 | PROCEDURE: get_context
 |
 | DESCRIPTION
 |
 |	Returns context information to caller.
 |	See SPECIFICATION for usage details.
 |
 | SCOPE:	Public (limited)
 |
 +=========================================================================*/

PROCEDURE get_context (
  x_context		OUT NOCOPY context_rec_type
) IS
BEGIN
  x_context := g_context;
END;

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
	p_style_code		IN	VARCHAR2,
	p_territory_code	IN	fnd_territories.territory_code%TYPE,
	p_language_code		IN	fnd_languages.language_code%TYPE,
	x_return_status		OUT NOCOPY	VARCHAR2,
	x_msg_count		OUT NOCOPY	VARCHAR2,
	x_msg_data		OUT NOCOPY	VARCHAR2,
	x_style_format_code	OUT NOCOPY	VARCHAR2
) IS

  l_api_name	VARCHAR2(30)	:= 'get_style_format';

  CURSOR c_style_formats (
  	p_style_code		IN	VARCHAR2,
  	p_territory_code	IN	VARCHAR2,
  	p_language_code		IN	VARCHAR2
  ) IS
  SELECT
  	hsf.style_format_code
  FROM
  	hz_style_fmt_locales hsfl,
  	hz_style_formats_b hsf
  WHERE
  	    nvl(hsfl.territory_code,'X') = nvl(p_territory_code,'X')
  	AND nvl(hsfl.language_code,'X')  = nvl(p_language_code,'X')
  	AND hsfl.style_format_code = hsf.style_format_code
  	AND hsf.style_code = p_style_code
        AND (SYSDATE BETWEEN hsfl.start_date_active
             AND NVL(hsfl.end_date_active, to_date('12/31/4712','MM/DD/YYYY')));



  CURSOR c_def_style_format (
  	p_style_code		IN	VARCHAR2
  ) IS
  SELECT
  	hsf.style_format_code
  FROM
  	hz_style_formats_b hsf
  WHERE
  	    hsf.default_flag = 'Y'
  	AND hsf.style_code = p_style_code;

  l_style_format_code	hz_style_formats_b.style_format_code%TYPE;

BEGIN

  --
  --  Reset return status and messages
  --

  x_return_status := fnd_api.g_ret_sts_success;


  --
  --  Look for a match on both
  --

  IF (p_territory_code IS NOT NULL) AND (p_language_code IS NOT NULL) THEN
    OPEN c_style_formats(
      p_style_code     => p_style_code,
      p_territory_code => p_territory_code,
      p_language_code  => p_language_code
    );
    FETCH c_style_formats INTO l_style_format_code;
    IF c_style_formats%NOTFOUND THEN
      CLOSE c_style_formats;
    ELSE
      CLOSE c_style_formats;
      x_style_format_code := l_style_format_code;
      RETURN;  -- match on both, exit procedure
    END IF;

  END IF;

  --
  --  Look for a match on territory (and ensure language is NULL)
  --

  IF (p_territory_code IS NOT NULL) THEN
    OPEN c_style_formats(
      p_style_code     => p_style_code,
      p_territory_code => p_territory_code,
      p_language_code  => NULL
    );
    FETCH c_style_formats INTO l_style_format_code;
    IF c_style_formats%NOTFOUND THEN
      CLOSE c_style_formats;
    ELSE
      CLOSE c_style_formats;
      x_style_format_code := l_style_format_code;
      RETURN;  -- match on TERRITORY exit procedure
    END IF;
  END IF;

  --
  --  Look for a match on language (and ensure territory is NULL)
  --

  IF (p_language_code IS NOT NULL) THEN
    OPEN c_style_formats(
      p_style_code     => p_style_code,
      p_territory_code => NULL,
      p_language_code  => p_language_code
    );
    FETCH c_style_formats INTO l_style_format_code;
    IF c_style_formats%NOTFOUND THEN
      CLOSE c_style_formats;
    ELSE
      CLOSE c_style_formats;
       x_style_format_code := l_style_format_code;
      RETURN;  -- match on LANGUAGE exit procedure
    END IF;
  END IF;

  --
  --  Obtain the default
  --

  OPEN c_def_style_format(
      p_style_code     => p_style_code
  );

  FETCH c_def_style_format INTO l_style_format_code;
  IF c_def_style_format%NOTFOUND THEN
    -- Error condition... could not determine Style Format whatsoever.
    x_return_status := fnd_api.g_ret_sts_error;
    fnd_message.set_name('AR','HZ_FMT_CANNOT_GET_FORMAT');
    fnd_msg_pub.add;
  END IF;
  CLOSE c_def_style_format;

  x_style_format_code := l_style_format_code;

  --
  --  Populate return message parameters with message information
  --

    fnd_msg_pub.count_and_get (
      p_encoded => fnd_api.g_false,
      p_count   => x_msg_count,
      p_data    => x_msg_data
    );

EXCEPTION

  WHEN OTHERS THEN
    x_return_status := fnd_api.g_ret_sts_unexp_error;
    IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
      fnd_msg_pub.add_exc_msg(
        g_pkg_name, l_api_name
      );
    END IF;
    fnd_msg_pub.count_and_get (
      p_encoded => fnd_api.g_false,
      p_count   => x_msg_count,
      p_data    => x_msg_data
    );

END get_style_format;

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
) RETURN VARCHAR2 -- boolean 'Y' or 'N'  (cannot use BOOLEAN for SQL functions)
IS
  l_context context_rec_type;
BEGIN

  --
  --  Get the current context information
  --

  get_context(
    x_context => l_context
  );

  --
  --  If the "from" country is the same as the "to" country, then
  --  don't need to check any further... same format
  --

  IF l_context.from_territory_code = p_territory_code THEN
    RETURN 'Y';
  END IF;

  --
  --  Determine the format that the "from" country uses.
  --

  DECLARE
    l_style_format_code	hz_style_formats_b.style_format_code%TYPE;
    l_return_status 	VARCHAR2(1);
    l_msg_count		NUMBER;
    l_msg_data		VARCHAR2(2000);

  BEGIN
      get_style_format (
	  p_style_code		=>	l_context.style_code,
	  p_territory_code	=>	l_context.from_territory_code,
	  p_language_code	=>	l_context.from_language_code,
	  x_return_status	=>	l_return_status,
	  x_msg_count		=>	l_msg_count,
	  x_msg_data		=>	l_msg_data,
	  x_style_format_code	=>	l_style_format_code
      );

      IF l_style_format_code = l_context.style_format_code THEN
        RETURN 'Y';
      END IF;
  END;

  RETURN 'N';

EXCEPTION
  WHEN OTHERS THEN
    RETURN 'N';  -- Do not wish to fail transaction.  Pick a "safe" answer.
END;

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
) RETURN VARCHAR2
IS
  l_neu_code VARCHAR2(4);
BEGIN

  -- Phase II of this project will remove the following hardcoding.
  -- Timeframes did not permit this from being accomodated in Phase I.  :-(

  IF p_territory_code    = 'AT' THEN l_neu_code := 'A';
  ELSIF p_territory_code = 'BE' THEN l_neu_code := 'B';
  ELSIF p_territory_code = 'DE' THEN l_neu_code := 'D';
  ELSIF p_territory_code = 'FI' THEN l_neu_code := 'FIN';
  ELSIF p_territory_code = 'FO' THEN l_neu_code := 'FR';
  ELSIF p_territory_code = 'FR' THEN l_neu_code := 'F';
  ELSIF p_territory_code = 'IT' THEN l_neu_code := 'I';
  ELSIF p_territory_code = 'LI' THEN l_neu_code := 'FL';
  ELSIF p_territory_code = 'LU' THEN l_neu_code := 'L';
  ELSIF p_territory_code = 'NO' THEN l_neu_code := 'N';
  ELSIF p_territory_code = 'PT' THEN l_neu_code := 'P';
  ELSIF p_territory_code = 'RO' THEN l_neu_code := 'R';
  ELSIF p_territory_code = 'SE' THEN l_neu_code := 'S';
  ELSIF p_territory_code = 'VA' THEN l_neu_code := 'I';
  ELSE
    l_neu_code := p_territory_code;
  END IF;

  RETURN l_neu_code;
END get_neu_country_code;


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
 ) RETURN VARCHAR2
 IS
   l_territory_name	fnd_territories_vl.territory_short_name%TYPE;
   l_language_code	fnd_languages.language_code%TYPE;

   CURSOR c_territory (
   	p_territory_code IN VARCHAR2,
   	p_language IN VARCHAR2
   ) IS
   SELECT territory_short_name
   FROM	  fnd_territories_tl
   WHERE  territory_code = p_territory_code
     AND  language=p_language;


 l_context context_rec_type;

BEGIN

  --
  --  Get context information so we know what language
  --  to translate the country name into
  --

  get_context(
    x_context => l_context
  );

  --
  --  If the address territory is the same as the reference territory,
  --  then suppress the territory name and return null.
  --

  IF l_context.from_territory_code = p_territory_code THEN
    RETURN NULL;
  END IF;

  OPEN c_territory(p_territory_code, l_context.country_name_lang);
  FETCH c_territory INTO l_territory_name;
  IF c_territory%NOTFOUND THEN
    CLOSE c_territory;
    RETURN p_territory_code;
  END IF;
  CLOSE c_territory;

  RETURN l_territory_name;

 EXCEPTION
   WHEN OTHERS THEN
     RETURN p_territory_code;

END get_tl_territory_name;


/****************** PRIVATE PROCEDURES/FUNCTIONS **************************/


/*=========================================================================+
 |
 | PROCEDURE:	get_default_style
 |
 | DESCRIPTION
 |
 |	This is a utility procedure that tries to determine the default
 |	style (if none is passed from the caller).
 |
 |	For names and addresses, a profile options are checked.
 |	If profile options are not set (or formatting data other than
 |	names and addresses) then HZ_STYLES_B is examined to see if there
 |	is one and only one style defined for the object, and that will
 |	be selected as the default.
 |
 | SCOPE:	Private
 |
 | ARGUMENTS:	(IN)
 |		p_object_name	The object for which you want to default style.
 |
 |		(OUT)
 |		x_style_code	Default Style.  NULL if cannot determine.
 |
 +=========================================================================*/

PROCEDURE get_default_style (
  p_object_name		IN hz_styles_b.database_object_name%TYPE,
  x_style_code		OUT NOCOPY hz_styles_b.style_code%TYPE
) IS
  l_style_code		hz_styles_b.style_code%TYPE;

  CURSOR c_styles(p_object_name IN VARCHAR2)
  IS SELECT rownum, style_code FROM hz_styles_b WHERE database_object_name = p_object_name;

BEGIN


  IF p_object_name = k_name_table_name THEN
/*  Fix perf bug 3669930, 4220460, use cached profile option value
    -- check profile option
    fnd_profile.get(
      name   => k_profile_def_name_style,
      val    => l_style_code
    );
*/
    l_style_code := g_profile_def_name_style;
  ELSIF p_object_name = k_addr_table_name THEN
/*  Fix perf bug 3669930, 4220460, use cached profile option value
    -- check profile option
    fnd_profile.get(
      name   => k_profile_def_addr_style,
      val    => l_style_code
    );
*/
    l_style_code := g_profile_def_addr_style;
  END IF;

  IF l_style_code IS NULL THEN

    -- Could not find the default style via profile options.
    -- Our only resort now is to examine if there is only one style.

    BEGIN
      SELECT style_code
        INTO l_style_code
        FROM hz_styles_b
       WHERE database_object_name = p_object_name;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        NULL; -- cannot default style code
      WHEN TOO_MANY_ROWS THEN
        NULL; -- cannot default style code
    END;
  END IF;

  x_style_code := l_style_code;

END get_default_style;

/*=========================================================================+
 |
 | PROCEDURE:	get_default_ref_territory
 |
 | DESCRIPTION
 |
 |	This is a utility procedure that determine's the user's reference
 |	territory for name and address format purposes.  This is required
 |	in case the caller to the name/address formatting routines do
 |	not pass in the territory where they are.
 |
 |	The reference territory is obtained as follows:
 |
 |        1.  Check for Profile Option HZ_REF_LANG
 |	  2.  If null, obtain the current session NLS territory setting
 |
 |
 | SCOPE:	Private
 |
 | ARGUMENTS:	(OUT)
 |		x_ref_territory_code	Default Reference Territory.
 |
 +=========================================================================*/

PROCEDURE get_default_ref_territory (
  x_ref_territory_code	OUT NOCOPY fnd_territories.territory_code%TYPE
) IS
  l_territory_code	fnd_territories.territory_code%TYPE;
  l_nls_territory       varchar(30);
BEGIN

---Bug No. 5110275. First check HZ_REF_TERRITORY profile option and then ICX_TERRITORY profile option

-- Bug No. 7139602. The profile value must be read at runtime. Cached value should not be used.
--l_territory_code := g_profile_ref_territory;
l_territory_code := FND_PROFILE.VALUE('HZ_REF_TERRITORY');

 -- Debug HZ_REF_TERRITORY

IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'HZ_FORMAT_PUB.get_default_ref_territory, ' ||
                                           'Profile option HZ_REF_TERRITORY = ' || l_territory_code,
                               p_prefix=>'',
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

--Now checking ICX_TERRITORY profile option

IF l_territory_code IS NULL THEN
-- Bug No. 7139602. The profile value must be read at runtime. Cached value should not be used.
--        l_nls_territory := g_icx_territory;
l_nls_territory := FND_PROFILE.VALUE('ICX_TERRITORY');

    -- Debug ICX_TERRITORY
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'HZ_FORMAT_PUB.get_default_ref_territory, ' ||
                                           'Profile option ICX_TERRITORY = ' || l_nls_territory,
                               p_prefix=>'',
                               p_msg_level=>fnd_log.level_procedure);
    END IF;

    if l_nls_territory is not null then
      select territory_code into l_territory_code
      from fnd_territories
      where nls_territory = l_nls_territory
            and OBSOLETE_FLAG = 'N'
            and rownum = 1;
    end if;

    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'HZ_FORMAT_PUB.get_default_ref_territory, ' ||
                                           'TERRITORY_CODE = ' || l_territory_code,
                               p_prefix=>'',
                               p_msg_level=>fnd_log.level_procedure);
    END IF;


    END IF;

    -- if not set, get current session NLS setting

    IF l_territory_code IS NULL THEN

      BEGIN
       if g_terr_code_exist = 0 then
        g_terr_code_exist :=1;
        SELECT fnd.territory_code
          INTO g_territory_code
          FROM nls_session_parameters nls,
               fnd_territories fnd
         WHERE nls.parameter = 'NLS_TERRITORY'
           AND fnd.nls_territory = nls.value;
        end if;
        if g_territory_code is not null then
           l_territory_code := g_territory_code;
        end if;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
    hz_utility_v2pub.debug(p_message=>'HZ_FORMAT_PUB.get_default_ref_territory,'||
                                'NO_DATA_FOUND Error from query',
                                 p_prefix=>'',
                                  p_msg_level=>fnd_log.level_procedure);
      END;
    END IF;

  --
  --  Set up return parameter
  --

  x_ref_territory_code := l_territory_code;

END get_default_ref_territory;
/*=========================================================================+
 |
 | PROCEDURE:	get_default_eloc_ref_territory
 |
 | DESCRIPTION
 |
 |	This is a utility procedure that determine's the user's reference
 |	territory for name and address format purposes.  This is required
 |	in case the caller to the name/address formatting routines do
 |	not pass in the territory where they are.
 |
 |	The reference territory is obtained as follows:
 |
 |        1.  Check for Profile Option HZ_REF_LANG
 |	  2.  If null, obtain the current session NLS territory setting
 |
 |
 | SCOPE:	Private
 |
 | ARGUMENTS:	(OUT)
 |		x_ref_territory_code	Default Reference Territory.
 |
 +=========================================================================*/

PROCEDURE get_default_eloc_ref_territory (
  x_ref_territory_code	OUT NOCOPY fnd_territories.territory_code%TYPE
) IS
  l_territory_code	fnd_territories.territory_code%TYPE;
  l_nls_territory       varchar(30);
BEGIN

----Bug No. 5110275. First check for HZ_REF_TERRITORY and then for ICX_TERRITORY PROFILE OPTION

-- Bug No. 7139602. The profile value must be read at runtime. Cached value should not be used.
--l_territory_code := g_profile_ref_territory;
l_territory_code := FND_PROFILE.VALUE('HZ_REF_TERRITORY');


IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN

 hz_utility_v2pub.debug(p_message=>'HZ_FORMAT_PUB.get_default_eloc_ref_territory, ' ||
                               'Profile option HZ_REF_TERRITORY = ' ||l_territory_code,
                                  p_prefix=>'',
                                  p_msg_level=>fnd_log.level_procedure);
     END IF;

 IF l_territory_code IS NULL THEN
-- Bug No. 7139602. The profile value must be read at runtime. Cached value should not be used.
--    l_nls_territory := g_icx_territory;
l_nls_territory := FND_PROFILE.VALUE('ICX_TERRITORY');

 -- Debug ICX_TERRITORY value
        --
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN

 hz_utility_v2pub.debug(p_message=>'HZ_FORMAT_PUB.get_default_eloc_ref_territory, ' ||
                                  'Profile option ICX_TERRITORY = ' || l_nls_territory,
                                   p_prefix=>'',
                                  p_msg_level=>fnd_log.level_procedure);
        END IF;


    if l_nls_territory is not null then
      select territory_code into l_territory_code
      from fnd_territories
      where nls_territory = l_nls_territory
            and OBSOLETE_FLAG = 'N'
            and rownum = 1;
    end if;
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
        hz_utility_v2pub.debug(p_message=>'HZ_FORMAT_PUB.get_default_eloc_ref_territory, ' ||
                                           'TERRITORY_CODE = ' || l_territory_code,
                               p_prefix=>'',
                               p_msg_level=>fnd_log.level_procedure);
    END IF;



    END IF;

    -- if not set, get current session NLS setting

    IF l_territory_code IS NULL THEN

      BEGIN
       if g_terr_code_exist = 0 then
        g_terr_code_exist :=1;
        SELECT fnd.territory_code
          INTO g_territory_code
          FROM nls_session_parameters nls,
               fnd_territories fnd
         WHERE nls.parameter = 'NLS_TERRITORY'
           AND fnd.nls_territory = nls.value;
        end if;
        if g_territory_code is not null then
           l_territory_code := g_territory_code;
        end if;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
hz_utility_v2pub.debug(p_message=>'HZ_FORMAT_PUB.get_default_eloc_ref_territory,'||
                                'NO_DATA_FOUND Error from query',
                                 p_prefix=>'',
                                  p_msg_level=>fnd_log.level_procedure);
      END;
    END IF;

  x_ref_territory_code := l_territory_code;

END get_default_eloc_ref_territory;
/*=========================================================================+
 |
 | PROCEDURE:	get_default_ref_language
 |
 | DESCRIPTION
 |
 |	This is a utility procedure that determine's the user's reference
 |	language for name and address format purposes.  This is required
 |	in case the caller to the name/address formatting routines do
 |	not pass in the language where they are.
 |
 |	The reference territory is obtained as follows:
 |
 |        1.  Check for Profile Option HZ_REF_LANG
 |	  2.  If null, obtain the current session NLS territory setting
 |
 |
 | SCOPE:	Private
 |
 | ARGUMENTS:	(OUT)
 |		x_ref_language_code	Default Reference Language.
 |
 +=========================================================================*/

PROCEDURE get_default_ref_language (
  x_ref_language_code	OUT NOCOPY fnd_languages.language_code%TYPE
) IS
  l_language_code	fnd_languages.language_code%TYPE;
BEGIN

/*  Fix perf bug 3669930, 4220460, use cached profile option value
    -- check profile option
    fnd_profile.get(
      name   => k_profile_ref_lang,
      val    => l_language_code
    );
*/
    l_language_code := g_profile_ref_lang;
    -- if not set, get current session NLS setting
    IF l_language_code IS NULL THEN
      BEGIN
        l_language_code := userenv('LANG');
      EXCEPTION
        WHEN NO_DATA_FOUND THEN NULL;  -- cannot determine language
      END;
    END IF;


  x_ref_language_code := l_language_code;

END get_default_ref_language;


/*=========================================================================+
 |
 | PROCEDURE:	get_country_name_lang
 |
 | DESCRIPTION
 |
 |	This is a utility procedure that determine's the language to display
 |      the country name in.
 |
 |      It is usually appropriate to display it in the language of the
 |      country from where an item is mailed (reference language).
 |
 |      However, in cases where this is not appropriate, a profile option
 |      is available to choose an appropriate language.
 |
 |	The "language for country line" is obtained as follows:
 |
 |        1.  Check for the profile option HZ_LANG_FOR_COUNTRY_DISPLAY
 |        2.  If null, use the Reference Language
 |        3.  If null, obtain the current session NLS language setting
 |
 |
 | SCOPE:	Public
 |
 | ARGUMENTS:	(OUT)
 |		x_country_name_lang	Language for country display.
 |
 +=========================================================================*/

PROCEDURE get_country_name_lang (
  x_country_name_lang	OUT NOCOPY fnd_languages.language_code%TYPE
) IS
  l_language_code	fnd_languages.language_code%TYPE;
BEGIN

  --
  --  Language
  --

/*  Fix perf bug 3669930, 4220460, use cached profile option value
  fnd_profile.get(
    name   => k_profile_country_lang,
    val    => l_language_code
  );
*/
  l_language_code := g_profile_country_lang;
  IF l_language_code IS NULL THEN
/*  Fix perf bug 3669930, 4220460, use cached profile option value
    fnd_profile.get(
      name   => k_profile_ref_lang,
      val    => l_language_code
    );
*/
    l_language_code := g_profile_ref_lang;
    IF l_language_code IS NULL THEN
      l_language_code := userenv('LANG');
    END IF;
  END IF;

  --
  --  Set up return parameters
  --

   x_country_name_lang  := l_language_code;

END get_country_name_lang;


/*=========================================================================+
 |
 | PROCEDURE:	load_internal_format_table
 |
 | DESCRIPTION
 |
 |	Loads table HZ_STYLE_FMT_LAYOUTS into an internal pl/sql table.
 |
 | SCOPE:	Private
 |
 | ARGUMENTS:  (IN)	p_style_format_code	Style Format Code for which
 |						  the layout is to be loaded.
 |			p_variation_num		Which variation to load?
 |
 |             (IN/OUT)	x_layout_tbl		PL/SQL table where the data
 |						  should be loaded.
 |			x_loaded_rows_cnt	Number of rows loaded.
 |
 |   !! THIS PROCEDURE CHECKS CACHE... ASSUMES GLOBAL TABLE IS USED !!!
 +=========================================================================*/

PROCEDURE load_internal_format_table(
  p_style_format_code	IN	VARCHAR2,
  p_variation_num	IN	NUMBER,
  x_layout_tbl		IN OUT	NOCOPY layout_tbl_type,
  x_loaded_rows_cnt	IN OUT NOCOPY	NUMBER
) IS
  i NUMBER := 0;

  CURSOR c_style_format_layouts(
    p_style_format_code	IN VARCHAR2,
    p_variation_number	IN NUMBER
  ) IS
  SELECT
    line_number,
    position,
    attribute_code,
    use_initial_flag,
    uppercase_flag,
    transform_function,
    delimiter_before,
    delimiter_after,
    blank_lines_before,
    blank_lines_after
  FROM hz_style_fmt_layouts_b
  WHERE
        style_format_code = p_style_format_code
    AND variation_number = p_variation_number
    AND (SYSDATE BETWEEN start_date_active
         AND NVL(end_date_active, to_date('12/31/4712','MM/DD/YYYY')))
    ORDER BY line_number, position;

BEGIN

  IF g_caching AND
     g_cache_style_format_code = p_style_format_code AND
     g_cache_variation_number  = p_variation_num
  THEN
    FOR i IN 1..x_loaded_rows_cnt
    LOOP
      x_layout_tbl(i).attribute_value := NULL;
    END LOOP;
  ELSE

    x_loaded_rows_cnt := 0;

    FOR l_layout_rec IN c_style_format_layouts(p_style_format_code, p_variation_num)
    LOOP
      i := i + 1;
      x_layout_tbl(i).line_number		:= l_layout_rec.line_number;
      x_layout_tbl(i).position			:= l_layout_rec.position;
      x_layout_tbl(i).attribute_code		:= l_layout_rec.attribute_code;
      x_layout_tbl(i).use_initial_flag		:= l_layout_rec.use_initial_flag;
      x_layout_tbl(i).uppercase_flag		:= l_layout_rec.uppercase_flag;
      x_layout_tbl(i).transform_function	:= l_layout_rec.transform_function;
      x_layout_tbl(i).delimiter_before		:= l_layout_rec.delimiter_before;
      x_layout_tbl(i).delimiter_after		:= l_layout_rec.delimiter_after;
      x_layout_tbl(i).blank_lines_before  	:= l_layout_rec.blank_lines_before;
      x_layout_tbl(i).blank_lines_after   	:= l_layout_rec.blank_lines_after;
      x_layout_tbl(i).attribute_value		:= NULL;
    END LOOP;

    x_loaded_rows_cnt := i;
    g_cache_style_format_code  := p_style_format_code;
    g_cache_variation_number   := p_variation_num;

  END IF;

END load_internal_format_table;

/*=========================================================================+
 |
 | PROCEDURE:	add_parm_table_row
 |
 | DESCRIPTION
 |
 |	Loads parameter names and values into a PL/SQL table.
 |
 | SCOPE:	Private
 |
 | ARGUMENTS:  (IN)
 |		p_parm_name	Name of the parameter
 |		p_parm_value	Value of the parameter
 |
 |             (IN/OUT)
 |		x_parm_tbl	PL/SQL table where the data
 |				  should be loaded.
 |		x_loaded_rows_cnt  Number of rows loaded.
 |
 +=========================================================================*/

PROCEDURE add_parm_table_row(
  p_parm_name		IN	VARCHAR2,
  p_parm_value		IN	VARCHAR2,
  x_parm_tbl		IN OUT	NOCOPY name_value_tbl_type,
  x_loaded_rows_cnt	IN OUT NOCOPY	NUMBER,
  p_parm_type		IN	VARCHAR2
) IS

BEGIN
  IF p_parm_value IS NOT NULL AND
     p_parm_value <> fnd_api.g_miss_char
  THEN
    x_loaded_rows_cnt := x_loaded_rows_cnt + 1;
    x_parm_tbl(x_loaded_rows_cnt).parm_name	:= p_parm_name;
    x_parm_tbl(x_loaded_rows_cnt).parm_value	:= p_parm_value;
    x_parm_tbl(x_loaded_rows_cnt).parm_type	:= p_parm_type;
  END IF;

END add_parm_table_row;

/*=========================================================================+
 |
 | PROCEDURE:	create_sql_string
 |
 | DESCRIPTION
 |
 |	Creates a SQL query string, based on the columns identifed in
 |	the internal layout table (based on HZ_STYLE_FMT_LAYOUTS).
 |
 | SCOPE:	Private
 |
 | ARGUMENTS:  (IN)	p_table_name	Name of the table to be queried.
 |			p_pk_name	Column name of the primary key
 |					  of the table.
 |			x_layout_tbl	Initialized internal layout table.
 |			p_layout_tbl_cnt  Number of rows in internal table.
 |
 |             (IN/OUT)	x_sql_string	The constructed SQL Query.
 |
 +=========================================================================*/

PROCEDURE create_sql_string(
  p_table_name 		IN 	VARCHAR2,
  x_pk_tbl		IN OUT  NOCOPY name_value_tbl_type,
  p_pk_tbl_cnt		IN	NUMBER,
  x_layout_tbl 		IN OUT 	NOCOPY layout_tbl_type,
  p_layout_tbl_cnt	IN 	NUMBER,
  x_sql_string 		IN OUT	NOCOPY VARCHAR2
) IS
  l_attribute   VARCHAR2(240);
BEGIN

  --
  -- Create a Dynamic SQL query based on the columns identified
  -- in the internal layout table.
  --

  x_sql_string := NULL;
  IF p_layout_tbl_cnt = 0 THEN
    RETURN;
  END IF;

  FOR i IN 1 .. p_layout_tbl_cnt
  LOOP
    IF x_sql_string IS NOT NULL THEN
      x_sql_string := x_sql_string || ', ';
    END IF;
    l_attribute := x_layout_tbl(i).attribute_code;

    -- apply transformation function
    IF x_layout_tbl(i).transform_function IS NOT NULL THEN
      l_attribute := x_layout_tbl(i).transform_function;
      	-- || '(' || l_attribute || ')';
    END IF;

    -- translate to upper case
    IF x_layout_tbl(i).uppercase_flag = 'Y' THEN
      l_attribute :=  'NLS_UPPER(' || l_attribute || ')';
    END IF;

    -- use initial flag
    IF x_layout_tbl(i).use_initial_flag = 'Y' THEN
      l_attribute :=  'SUBSTRB(' || l_attribute || ',1,1)';
    END IF;

    IF l_attribute <> x_layout_tbl(i).attribute_code THEN
      -- if functions applied, then use attribute name as the alias
      l_attribute := l_attribute || ' ' || x_layout_tbl(i).attribute_code;
    END IF;

    x_sql_string := x_sql_string || l_attribute;
  END LOOP;

  x_sql_string := 'SELECT ' || x_sql_string || ' FROM '
  	|| p_table_name;

  FOR i IN 1..p_pk_tbl_cnt
  LOOP
    IF i=1 THEN
      x_sql_string := x_sql_string || ' WHERE '
          || x_pk_tbl(i).parm_name || ' = :' || x_pk_tbl(i).parm_name;
    ELSE
      x_sql_string := x_sql_string || ' AND '
          || x_pk_tbl(i).parm_name || ' = :' || x_pk_tbl(i).parm_name;
    END IF;
  END LOOP;


END create_sql_string;

/*=========================================================================+
 |
 | PROCEDURE:	execute_query
 |
 | DESCRIPTION
 |
 |	Dynamically executes a SQL query, based on the string passed
 |	in p_sql_string.
 |
 |	THE RESULTS ARE RETURNED in the internal layout table, with
 |	column values being placed in the field 'attribute_value'.
 |
 |	THIS PROCEDURE ASSUMES that the SQL query being passed requires
 |	a single BIND VARIABLE to be resolved, i.e. the primary key of
 |	the object being formatted.  The parameter p_pk_value contains
 |	the value to be substituted for this bind variable.
 |
 |	WHY IS DBMS_SQL being used instead of Native Dynamic SQL (NDS)?
 |	Wouldn't it be easier to use EXECUTE IMMEDIATE?  Well, the problem
 |	here is that our column list is dynamic.  NDS does not support
 |	this type of Dynamic SQL, and we must revert to using DBMS_SQL.
 |
 | SCOPE:	Private
 |
 | ARGUMENTS:  (IN)
 |		p_table_name	Name of the table to be queried.
 |		p_pk_value	Primary Key value that identifies the
 |				  data to be retrieved.
 |		p_layout_tbl_cnt	Number of rows in the internal table.
 |
 |             (IN/OUT)	x_layout_tbl	The internal layout table.
 |					  Only field 'attribute_value' is
 |					  populated by this procedure.
 |
 +=========================================================================*/

PROCEDURE execute_query(
  p_sql_string		IN	VARCHAR2,
  x_pk_tbl		IN OUT  NOCOPY name_value_tbl_type,
  p_pk_tbl_cnt		IN	NUMBER,
  p_layout_tbl_cnt	IN 	NUMBER,
  x_layout_tbl		IN OUT	NOCOPY layout_tbl_type
) IS
  l_cursor_name INTEGER;
  l_ret_value	INTEGER;

  l_key_value_number	NUMBER;
  l_key_value_date	DATE;
BEGIN

  l_cursor_name := DBMS_SQL.OPEN_CURSOR;

  DBMS_SQL.PARSE(l_cursor_name, p_sql_string, DBMS_SQL.NATIVE);

  FOR i IN 1 .. p_layout_tbl_cnt
  LOOP
    DBMS_SQL.DEFINE_COLUMN(l_cursor_name, i, x_layout_tbl(i).attribute_value, 240);
  END LOOP;

  --
  --  Bind Values to Variables
  --

  FOR i IN 1..p_pk_tbl_cnt
  LOOP
    IF x_pk_tbl(i).parm_type = 'N' THEN -- numeric
      l_key_value_number := x_pk_tbl(i).parm_value;
      DBMS_SQL.BIND_VARIABLE(l_cursor_name,
      	':'||x_pk_tbl(i).parm_name, l_key_value_number);
    ELSIF x_pk_tbl(i).parm_type = 'V' THEN -- Varchar2
      DBMS_SQL.BIND_VARIABLE(l_cursor_name,
      	':'||x_pk_tbl(i).parm_name, x_pk_tbl(i).parm_value);
    ELSIF x_pk_tbl(i).parm_type = 'D' THEN -- Date
      l_key_value_date := to_date(x_pk_tbl(i).parm_value,'YYYY/MM/DD');
      DBMS_SQL.BIND_VARIABLE(l_cursor_name,
      	':'||x_pk_tbl(i).parm_name, l_key_value_date);
    END IF;

  END LOOP;

  --DBMS_SQL.BIND_VARIABLE(l_cursor_name, ':'||p_pk_name, p_pk_value);

  l_ret_value := DBMS_SQL.EXECUTE_AND_FETCH(l_cursor_name);

  FOR i IN 1 .. p_layout_tbl_cnt
  LOOP
    DBMS_SQL.COLUMN_VALUE(l_cursor_name, i, x_layout_tbl(i).attribute_value);
  END LOOP;

  DBMS_SQL.CLOSE_CURSOR(l_cursor_name);

END execute_query;


/*=========================================================================+
 |
 | PROCEDURE:	format_results
 |
 | DESCRIPTION
 |
 |	Once the internal layout table is populated with the layout
 |	definitions AND the column values of the object being formatted,
 |	then this procedure can be called to apply the "layout rules"
 |	and format the data.
 |
 | SCOPE:	Private
 |
 | ARGUMENTS:
 |
 |             (IN)	p_layout_tbl_cnt	Number of rows in internal table.
 |             (IN/OUT)	x_layout_tbl		The internal layout table,
 |						  fully populated.
 |			x_formatted_lines_tbl	Formatted data, a table of
 |						  strings is returned.
 |			x_formatted_lines_cnt	Number of lines formatted.
 |
 +=========================================================================*/

PROCEDURE format_results (
  p_space_replace	IN		VARCHAR2,
  p_layout_tbl_cnt	IN		NUMBER,
  x_layout_tbl		IN OUT NOCOPY	layout_tbl_type,
  x_formatted_lines_tbl	IN OUT NOCOPY	string_tbl_type,
  x_formatted_lines_cnt	IN OUT NOCOPY	NUMBER
) IS
  l_current_line	NUMBER := 1;  -- this keeps track of line_number changes
  l_current_idx		NUMBER := 0;  -- this is used for output index
  l_current_text	VARCHAR2(240);
BEGIN

  FOR i IN 1..p_layout_tbl_cnt
  LOOP

    --
    -- Dump the previous line if we're onto the next line
    --

    IF x_layout_tbl(i).line_number > l_current_line THEN
      IF l_current_text IS NOT NULL THEN
        l_current_idx := l_current_idx + 1;
        x_formatted_lines_tbl(l_current_idx) := rtrim(l_current_text);
        l_current_text := NULL;
      END IF;
      IF nvl(x_layout_tbl(i).blank_lines_before,0) > 0 THEN
        FOR j IN 1..x_layout_tbl(i).blank_lines_before
        LOOP
          l_current_idx := l_current_idx + 1;
          IF p_space_replace IS NOT NULL THEN
            x_formatted_lines_tbl(l_current_idx) := p_space_replace;
          ELSE
            x_formatted_lines_tbl(l_current_idx) := ' ';
          END IF;
        END LOOP;
      END IF;
      l_current_line := x_layout_tbl(i).line_number;
    END IF;

    --
    -- Append the current attribute value onto the line,
    -- with delimeters.
    --

    IF x_layout_tbl(i).attribute_value IS NOT NULL THEN
      IF p_space_replace IS NOT NULL THEN
        l_current_text := l_current_text
        	|| replace(x_layout_tbl(i).delimiter_before,' ',p_space_replace)
        	|| x_layout_tbl(i).attribute_value
         	|| replace(x_layout_tbl(i).delimiter_after,' ',p_space_replace);
      ELSE
        l_current_text := l_current_text
        	|| x_layout_tbl(i).delimiter_before
        	|| x_layout_tbl(i).attribute_value
        	|| x_layout_tbl(i).delimiter_after;
      END IF;
    END IF;


  END LOOP;

  --
  -- Dump the last line
  --

  IF l_current_text IS NOT NULL THEN
    l_current_idx := l_current_idx + 1;
    x_formatted_lines_tbl(l_current_idx) := rtrim(l_current_text);
  END IF;

  x_formatted_lines_cnt := l_current_idx;

END format_results;

/*=========================================================================+
 |
 | PROCEDURE:	determine_variation
 |
 | DESCRIPTION
 |
 |	This procedure determines which format variation to use based
 |	on the conditions defined.
 |
 | SCOPE:	Private
 |
 | ARGUMENTS:	(IN)
 |		p_reset_territory	True if you want the overridden
 |					  reference territory to be reset.
 |		p_reset_language	True if you want the overridden
 |					  reference language to be reset.
 |					  the localized Style Format.
 |
 +=========================================================================*/

PROCEDURE determine_variation (
  p_style_format_code	IN	VARCHAR2,
  p_object_name		IN	VARCHAR2,
  p_object_pk_name	IN	VARCHAR2,
  p_object_pk_value	IN	VARCHAR2,
  x_variation_num	OUT NOCOPY	NUMBER
) IS

  CURSOR c_variations (p_style_format_code IN VARCHAR2) IS
  SELECT
     variation_number,
     selection_condition
  FROM
    hz_style_fmt_variations
  WHERE
    style_format_code = p_style_format_code
    AND (SYSDATE BETWEEN start_date_active
         AND NVL(end_date_active, to_date('12/31/4712','MM/DD/YYYY')))
  ORDER BY
    variation_rank;

  l_sql_string VARCHAR2(2000);

  l_result NUMBER;

BEGIN

  FOR l_variation IN c_variations (p_style_format_code)
  LOOP

    IF l_variation.selection_condition IS NULL THEN

      -- this is it.  no condition - have to take it.
      x_variation_num := l_variation.variation_number;
      RETURN;
    ELSE
      -- execute the condition.
      l_sql_string := 'SELECT 1 FROM ' || p_object_name
        || ' WHERE ' || p_object_pk_name || '=' || ' :1 '
        || ' AND ( ' || l_variation.selection_condition || ')';

      BEGIN
        EXECUTE IMMEDIATE l_sql_string INTO l_result USING p_object_pk_value;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          NULL; -- condition not true
       -- WHEN OTHERS THEN

      END;

      IF l_result = 1 THEN
        x_variation_num := l_variation.variation_number;
        RETURN;
      END IF;
    END IF;
  END LOOP;

END determine_variation;

/*=========================================================================+
 |
 | PROCEDURE:	determine_variation
 |
 | DESCRIPTION
 |
 |	This procedure determines which format variation to use based
 |	on the conditions defined.
 |
 | SCOPE:	Private
 |
 | ARGUMENTS:	(IN)
 |		p_reset_territory	True if you want the overridden
 |					  reference territory to be reset.
 |		p_reset_language	True if you want the overridden
 |					  reference language to be reset.
 |					  the localized Style Format.
 |
 +=========================================================================*/

PROCEDURE determine_variation (
  p_style_format_code	IN	VARCHAR2,
  p_parm_tbl_cnt	IN NUMBER,
  x_parm_tbl		IN OUT	NOCOPY name_value_tbl_type,
  x_variation_num	OUT NOCOPY	NUMBER
) IS

  CURSOR c_variations (p_style_format_code IN VARCHAR2) IS
  SELECT
     variation_number,
     selection_condition
  FROM
    hz_style_fmt_variations
  WHERE
    style_format_code = p_style_format_code
    AND (SYSDATE BETWEEN start_date_active
         AND NVL(end_date_active, to_date('12/31/4712','MM/DD/YYYY')))
  ORDER BY
    variation_rank;

  l_sql_string VARCHAR2(2000);
  l_result     NUMBER;
BEGIN
  FOR l_variation IN c_variations(p_style_format_code)
  LOOP

    IF l_variation.selection_condition IS NULL THEN
      -- this is it.  no condition - have to take it.
      x_variation_num := l_variation.variation_number;
      RETURN;
    END IF;

    l_sql_string := l_variation.selection_condition;

    substitute_tokens (
      p_parm_tbl_cnt => p_parm_tbl_cnt,
      x_parm_tbl     => x_parm_tbl,
      x_string       => l_sql_string
    );

    --
    -- Test if the condition is true
    --

    l_sql_string := 'SELECT 1 FROM DUAL WHERE ' || l_sql_string;
    BEGIN
      EXECUTE IMMEDIATE l_sql_string INTO l_result;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        NULL;  -- means the condition is false, so continue...

      -- bug fix 2905180
      WHEN OTHERS THEN
        NULL;

    END;
    IF l_result=1 THEN
      -- Condition is true
      x_variation_num := l_variation.variation_number;
      RETURN;
    END IF;

  END LOOP;

END determine_variation;

/*=========================================================================+
 |
 | PROCEDURE:	copy_attribute_values
 |
 | DESCRIPTION
 |
 |	This procedure copies the attribute values from the parameter table
 |	to the internal formatting table.
 |
 | SCOPE:	Private
 |
 +=========================================================================*/

PROCEDURE copy_attribute_values (
  p_parm_tbl_cnt	IN 	NUMBER,
  x_parm_tbl		IN OUT	NOCOPY name_value_tbl_type,
  p_layout_tbl_cnt	IN 	NUMBER,
  x_layout_tbl 		IN OUT 	NOCOPY layout_tbl_type
) IS
  l_sql_string  VARCHAR2(2000);
BEGIN
  FOR i IN 1..p_parm_tbl_cnt
  LOOP
    IF x_parm_tbl(i).parm_value IS NOT NULL THEN
      <<layout>>
      FOR j IN 1..p_layout_tbl_cnt
      LOOP
        IF x_parm_tbl(i).parm_name = x_layout_tbl(j).attribute_code THEN
          l_sql_string := NULL;

          IF x_layout_tbl(j).transform_function IS NOT NULL THEN
            l_sql_string := x_layout_tbl(j).transform_function;
            substitute_tokens(
              p_parm_tbl_cnt   => p_parm_tbl_cnt,
              x_parm_tbl       => x_parm_tbl,
              x_string         => l_sql_string
            );
          END IF;
          IF x_layout_tbl(j).uppercase_flag = 'Y' THEN
            IF x_layout_tbl(j).transform_function IS NOT NULL THEN
              l_sql_string := 'NLS_UPPER('||nvl(l_sql_string,''''||x_parm_tbl(i).parm_value||'''')||')';
            END IF;
          END IF;
          IF x_layout_tbl(j).use_initial_flag = 'Y' THEN
            l_sql_string := 'SUBSTRB('||nvl(l_sql_string,''''||x_parm_tbl(i).parm_value||'''')||',1,1)';
          END IF;

          IF l_sql_string IS NOT NULL THEN
            l_sql_string := 'SELECT ' || l_sql_string || 'FROM DUAL' ;
            EXECUTE IMMEDIATE l_sql_string INTO x_layout_tbl(j).attribute_value;
          ELSE
            IF x_layout_tbl(j).uppercase_flag = 'Y' THEN
              x_layout_tbl(j).attribute_value := upper(x_parm_tbl(i).parm_value);
            ELSE
              x_layout_tbl(j).attribute_value := x_parm_tbl(i).parm_value;
            END IF;
          END IF;

          EXIT layout;
        END IF;
      END LOOP;
    END IF;
  END LOOP;
END copy_attribute_values;


PROCEDURE substitute_tokens (
  p_parm_tbl_cnt	IN 	NUMBER,
  x_parm_tbl		IN OUT	NOCOPY name_value_tbl_type,
  x_string		IN OUT NOCOPY VARCHAR2
) IS
  l_sub_string	VARCHAR2(2000);
BEGIN

    l_sub_string := x_string;
    FOR i IN 1..p_parm_tbl_cnt LOOP

      IF instrb(l_sub_string, x_parm_tbl(i).parm_name) > 0 THEN
        IF x_parm_tbl(i).parm_value IS NULL THEN
          l_sub_string := replace(l_sub_string,x_parm_tbl(i).parm_name,'NULL');
        ELSE
        l_sub_string := replace(l_sub_string,x_parm_tbl(i).parm_name,
            ''''||x_parm_tbl(i).parm_value||'''');
        END IF;
      END IF;
    END LOOP;

    x_string := l_sub_string;
END substitute_tokens;




/*=========================================================================+
 |
 | PROCEDURE:	set_context
 |
 | DESCRIPTION
 |
 |	This procedure is called by the format_name, format_address and
 |	format_data public APIs.  It saves the "context" in which the
 |	APIs were called in, so that it can be made available to any
 |	routine that requires it later.
 |
 |	For example, the style metadata allows functions to be defined
 |	to "transform" an attribute (e.g. lookup country name from
 |	country code).  That translation function needs context information
 |	to know what language to display the country name in, and also
 |	whether to show or hide the country name.
 |
 | SCOPE:	Private
 |
 +=========================================================================*/

PROCEDURE set_context (
  p_style_code		  IN	hz_styles_b.style_code%TYPE,
  p_style_format_code	  IN	hz_style_formats_b.style_format_code%TYPE,
  p_to_territory_code	  IN	fnd_territories.territory_code%TYPE,
  p_to_language_code	  IN	fnd_languages.language_code%TYPE,
  p_from_territory_code	  IN	fnd_territories.territory_code%TYPE,
  p_from_language_code	  IN	fnd_languages.language_code%TYPE,
  p_country_name_lang	  IN	fnd_languages.language_code%TYPE
) IS
BEGIN

  -- Access the global context directly
  g_context.style_code			:= p_style_code;
  g_context.style_format_code		:= p_style_format_code;
  g_context.to_territory_code 		:= p_to_territory_code;
  g_context.to_language_code  		:= p_to_language_code;
  g_context.from_territory_code 	:= p_from_territory_code;
  g_context.from_language_code  	:= p_from_language_code;
  g_context.country_name_lang		:= p_country_name_lang;
END;

END hz_format_pub;

/
