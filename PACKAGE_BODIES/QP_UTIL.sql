--------------------------------------------------------
--  DDL for Package Body QP_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QP_UTIL" AS
/* $Header: QPXUTILB.pls 120.15.12010000.10 2016/06/17 17:21:18 smukka ship $ */
--===========================================================================
--     This script defines a procedure 'GEt_Context_Attribute.
--     Input to this procedure is attribute code as defined in
--     harcode list file and output will be context and attribute name.
--     In case of qualifiers , context will go in qualifier_context ,
--     attribute name will go in
--     qualifier attribute name .
--     In case of pricing attributes , context will go in pricing_context ,
--     attribute name will go in
--      pricing  attribute name .
--     All attribute code except method_type_code ,should be included in quotes.
--     Method_type_code should not be included in quotes , so that whatever
--     value store in
--     it ('AMNT', 'PERC') will go in as parameter, and depending on this value,
--     get_context_attribute
--    will return context as VOLUME or LINEAMT and corresponding attribute name
--===========================================================================

-- =======================================================================
-- Procedure  get_item_cat_info
--   procedure type   Public
--  DESCRIPTION
--    Returns the name and description for an item category ID, using the
--    QP_ITEM_CATEGORIES valueset and any PTE/Source System Code
--    restrictions.
-- =======================================================================

  PROCEDURE get_item_cat_info(p_item_id   IN NUMBER,
                              p_item_pte  IN VARCHAR2 DEFAULT NULL,
                              p_item_ss   IN VARCHAR2 DEFAULT NULL,
                              x_item_name OUT NOCOPY VARCHAR2,
                              x_item_desc OUT NOCOPY VARCHAR2,
                              x_is_valid  OUT NOCOPY BOOLEAN)
  IS
    l_vset_id NUMBER;
    l_select_stmt VARCHAR2(4000);
    l_order_by_idx NUMBER;
    l_attribute_id NUMBER;
  BEGIN

    -- Get select statment for ITEM_CATEGORY valueset
    QP_MASS_MAINTAIN_UTIL.get_valueset_select('ITEM',
                                              'ITEM_CATEGORY',
                                              l_select_stmt,
                                              'PRICING_ATTRIBUTE2',
                                              p_item_pte,
                                              p_item_ss);

    -- Add attribute ID where clause
    l_select_stmt := l_select_stmt || ' WHERE attribute_id = ' || p_item_id;

    -- Execute statement
    EXECUTE IMMEDIATE l_select_stmt INTO l_attribute_id, x_item_name, x_item_desc;
    x_is_valid := TRUE;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      x_is_valid := FALSE;
  END get_item_cat_info;

--Bug# 5523416 RAVI START
--==============================================================================
--FUNCTION    - Is_Valid_Category
--FUNC TYPE   - Public
--DESCRIPTION - Funtion returns true if the category is present in the Functional area
--              for the source system and pte in the profile options.
--==============================================================================
FUNCTION Is_Valid_Category(p_item_id IN NUMBER) RETURN VARCHAR2 IS
   l_item_name VARCHAR2(1000);
   l_item_desc VARCHAR2(5000);
   l_is_valid  BOOLEAN;
BEGIN
   QP_UTIL.get_item_cat_info(
      p_item_id,
      fnd_profile.value('QP_PRICING_TRANSACTION_ENTITY'),
      fnd_profile.value('QP_SOURCE_SYSTEM_CODE'),
      l_item_name,
      l_item_desc,
      l_is_valid
   );

   IF l_is_valid=TRUE THEN
      RETURN 'TRUE';
   ELSE
      RETURN 'FALSE';
   END IF;

EXCEPTION
   WHEN OTHERS THEN
      RETURN 'FALSE';
END Is_Valid_Category;

--Bug# 5523416 RAVI END

-- =======================================================================
-- Function  get_fnarea_where_clause
--   function type   Private
--   Returns  VARCHAR2
--  DESCRIPTION
--    Returns the additional where clause for functional areas based on
--    PTE and Source System Codes.
-- =======================================================================


  FUNCTION get_fnarea_where_clause(p_pte_code    IN   VARCHAR2,
                                   p_ss_code     IN   VARCHAR2,
                                   p_table_alias IN   VARCHAR2)  RETURN VARCHAR2 IS
  l_table_alias   VARCHAR2(50) := p_table_alias;
  l_where_clause  VARCHAR2(240);
  BEGIN
    -- Set table Alias
    IF l_table_alias IS NOT NULL THEN
      l_table_alias := l_table_alias || '.';
    END IF;

    IF p_pte_code IS NULL THEN  -- No PTE/SS: No restriction

      l_where_clause := NULL;

    ELSE  -- Restriction based on PTE
      l_where_clause := ' ' || l_table_alias || 'functional_area_id IN (';
      l_where_clause := l_where_clause || 'select /*+ full(utilmap.map) use_hash(utilmap.map)*/ distinct utilmap.functional_area_id ';
      l_where_clause := l_where_clause || 'from qp_fass_v utilmap ';
      l_where_clause := l_where_clause || 'where utilmap.pte_code = ''' || p_pte_code || ''' ';

      IF p_ss_code IS NOT NULL THEN -- and SS

        l_where_clause := l_where_clause || 'and utilmap.application_short_name = ''' || p_ss_code || ''' ';

      END IF;

      l_where_clause := l_where_clause || '  and utilmap.enabled_flag = ''Y'' ';

      l_where_clause := l_where_clause || ') ';

    END IF;

    RETURN l_where_clause;

  END get_fnarea_where_clause;


-- =======================================================================
-- Function  merge_fnarea_where_clause
--   funtion type   Public
--   Returns  VARCHAR2
--  DESCRIPTION
--    Returns the merged where clause for functional areas based on
--    PTE and Source System Codes merged with a where clause string param.
-- =======================================================================


  FUNCTION merge_fnarea_where_clause(p_where_clause IN   VARCHAR2,
                                     p_pte_code     IN   VARCHAR2,
                                     p_ss_code      IN   VARCHAR2,
                                     p_table_alias  IN   VARCHAR2)  RETURN VARCHAR2 IS
  l_where_clause VARCHAR2(2000);
  l_fnarea_where_clause VARCHAR2(240);
  l_order_idx NUMBER;
  BEGIN
    -- Get fnarea where clause
    l_fnarea_where_clause := get_fnarea_where_clause(p_pte_code, p_ss_code, p_table_alias);

    -- If fnarea where clause is null, return param where clause
    IF l_fnarea_where_clause IS NULL THEN
      l_where_clause := p_where_clause;
    ELSE
      -- Otherwise, we add the fnarea clause before the ORDER BY clause
      l_order_idx := instr(p_where_clause, 'ORDER BY');
      l_where_clause := substr(p_where_clause, 1, l_order_idx - 1);
      l_where_clause := l_where_clause || 'AND ' || l_fnarea_where_clause || ' ';
      l_where_clause := l_where_clause || substr(p_where_clause, l_order_idx);
    END IF;

    RETURN l_where_clause;

  END merge_fnarea_where_clause;

--==============================================================================
--FUNCTION    - Is_Used
--FUNC TYPE   - Public
--DESCRIPTION - Is Used function returns 'Y' if the corresponding context-Attribute
--              pair is used by any pricing setup(pricelist,modifiers..etc),'N' otherwise.
--==============================================================================
FUNCTION Is_Used (p_context_type   IN VARCHAR2,
                  p_context_code   IN VARCHAR2,
                  p_attribute_code IN VARCHAR2)
RETURN VARCHAR2
IS

x_is_used    varchar2(1) := 'N';
l_check_active_flag  VARCHAR2(1);

BEGIN

l_check_active_flag := nvl(fnd_profile.value('QP_BUILD_ATTRIBUTES_MAPPING_OPTIONS'),'N');

IF l_check_active_flag = 'N' THEN
   IF p_context_type='QUALIFIER' THEN
   BEGIN
     SELECT 'Y'    INTO   x_is_used    FROM   qp_qualifiers
     WHERE  qualifier_context = p_context_code
     AND    qualifier_attribute = p_attribute_code    AND    rownum < 2;
     EXCEPTION
     WHEN no_data_found THEN
     BEGIN
        SELECT 'Y'  INTO   x_is_used  FROM   qp_limits
        WHERE  ((multival_attr1_context = p_context_code
        AND    multival_attribute1 = p_attribute_code)
        OR     (multival_attr2_context = p_context_code
        AND    multival_attribute2 = p_attribute_code)) AND    rownum < 2;
        EXCEPTION
        WHEN no_data_found THEN
        BEGIN
          SELECT 'Y' INTO   x_is_used   FROM   qp_limit_attributes
          WHERE  limit_attribute_context = p_context_code
          AND    limit_attribute = p_attribute_code AND    rownum < 2;
          EXCEPTiON
          WHEN no_data_found THEN
            x_is_used := 'N';
        END;
     END;
   END;
   ELSIF p_context_type='PRICING_ATTRIBUTE' THEN
   BEGIN
       SELECT 'Y'
       INTO   x_is_used     FROM   qp_pricing_attributes
       WHERE  pricing_attribute_context = p_context_code
       AND    pricing_attribute = p_attribute_code     AND    rownum < 2;
       EXCEPTION
       WHEN no_data_found THEN
       BEGIN
         SELECT 'Y'
       	 INTO     x_is_used
  	 FROM       qp_price_formula_lines a, qp_list_lines b
  	 WHERE   a.pricing_attribute_context = p_context_code
   	 AND          a.pricing_attribute = p_attribute_code
    	 AND          a.price_formula_id = b.price_by_formula_id
    	 AND          rownum < 2;
       EXCEPTION
       WHEN no_data_found THEN
          BEGIN
             		 SELECT 'Y'
   			 INTO     x_is_used
    			 FROM       qp_price_formula_lines a, qp_currency_details  b
   			 WHERE   a.pricing_attribute_context = p_context_code
   			 AND          a.pricing_attribute = p_attribute_code
    			 AND          (a.price_formula_id = b.price_formula_id
                         OR            a.price_formula_id = b.markup_formula_id)
   			 AND          rownum < 2;
          EXCEPTION
          WHEN no_data_found THEN
            x_is_used:= 'N';
          END;
       END;
   END;
   ELSIF p_context_type='PRODUCT' THEN
   BEGIN
     SELECT 'Y' INTO   x_is_used    FROM   dual
     where  exists(SELECT 'Y'
     FROM   qp_pricing_attributes
     WHERE  product_attribute_context = p_context_code
     AND    product_attribute = p_attribute_code);
     EXCEPTION
     WHEN no_data_found THEN
     BEGIN
       SELECT 'Y'  INTO   x_is_used  FROM   qp_limits
       WHERE  ((multival_attr1_context = p_context_code
       AND    multival_attribute1 = p_attribute_code)
       OR     (multival_attr2_context = p_context_code
       AND    multival_attribute2 = p_attribute_code)) AND    rownum < 2;
       EXCEPTION
       WHEN no_data_found THEN
       BEGIN
         SELECT 'Y' INTO   x_is_used   FROM   qp_limit_attributes
         WHERE  limit_attribute_context = p_context_code
         AND    limit_attribute = p_attribute_code AND    rownum < 2;
         EXCEPTiON
         WHEN no_data_found THEN
           x_is_used := 'N';
       END;
     END;
   END;
   END IF;
ELSIF l_check_active_flag = 'Y' THEN
   IF p_context_type='QUALIFIER' THEN
   BEGIN
     SELECT 'Y' INTO   x_is_used       FROM   qp_qualifiers
     WHERE  qualifier_context = p_context_code
     AND    qualifier_attribute = p_attribute_code
     AND    active_flag = 'Y'    AND    rownum < 2;
     EXCEPTION
     WHEN no_data_found THEN
     BEGIN
       SELECT 'Y' INTO  x_is_used  FROM   qp_limits a, qp_list_headers_b b
       WHERE  ((a.multival_attr1_context = p_context_code
       AND a.multival_attribute1 = p_attribute_code)
       OR (a.multival_attr2_context = p_context_code
       AND    a.multival_attribute2 = p_attribute_code))
       AND    a.list_header_id = b.list_header_id  AND  b.active_flag = 'Y'
       AND    rownum < 2;
       EXCEPTION
       WHEN no_data_found THEN
       BEGIN
         SELECT 'Y' INTO   x_is_used
         FROM   qp_limit_attributes a, qp_limits b, qp_list_headers_b c
         WHERE  a.limit_attribute_context = p_context_code
         AND a.limit_attribute = p_attribute_code AND a.limit_id = b.limit_id
         AND b.list_header_id = c.list_header_id  AND c.active_flag = 'Y'
         AND    rownum < 2;
         EXCEPTION
         WHEN no_data_found THEN
           x_is_used := 'N';
       END;
     END;
   END;
   ELSIF p_context_type='PRICING_ATTRIBUTE' THEN
   BEGIN
     --modified query to improve performance.
     SELECT 'Y'  INTO   x_is_used   FROM   dual
     where  exists(SELECT 'Y'  FROM   qp_pricing_attributes qpa, qp_list_headers_b qph
     WHERE  qpa.pricing_attribute_context = p_context_code
     AND    qpa.pricing_attribute = p_attribute_code
     AND    qpa.list_header_id = qph.list_header_id
     AND    qph.active_flag = 'Y'
     );
     EXCEPTION
     WHEN no_data_found THEN
     BEGIN
      SELECT 'Y'
	INTO x_is_used
 	FROM   qp_price_formula_lines a, qp_list_lines b, qp_list_headers_b c
 	WHERE  a.pricing_attribute_context = p_context_code
  	AND    a.pricing_attribute = p_attribute_code
    	AND    a.price_formula_id = b.price_by_formula_id
    	AND    b.list_header_id = c.list_header_id
    	AND    c.active_flag = 'Y'
    	AND    rownum < 2;
     EXCEPTION
     WHEN no_data_found THEN
      BEGIN
        SELECT 'Y'
  	 INTO     x_is_used
    	 FROM       qp_price_formula_lines a, qp_currency_details  b
   	 WHERE   a.pricing_attribute_context = p_context_code
   	 AND          a.pricing_attribute = p_attribute_code
    	 AND          (a.price_formula_id = b.price_formula_id
         OR            a.price_formula_id = b.markup_formula_id)
   	 AND          rownum < 2;
       EXCEPTION
       WHEN no_data_found THEN
          x_is_used := 'N';
      END;
     END;
   END;
   ELSIF p_context_type='PRODUCT' THEN
   BEGIN
     SELECT 'Y'
     INTO   x_is_used   FROM   dual
     WHERE  exists (SELECT  'Y'
     FROM   qp_pricing_attributes a
     WHERE  product_attribute_context = p_context_code
     AND    product_attribute = p_attribute_code
     AND    exists (select 'x' from qp_list_headers_b b
     where active_flag = 'Y' and  a.list_header_id = b.list_header_id));
     EXCEPTION
     WHEN no_data_found THEN
     BEGIN
       SELECT 'Y'  INTO   x_is_used  FROM   qp_limits a, qp_list_headers_b b
       WHERE  ((a.multival_attr1_context = p_context_code
       AND a.multival_attribute1 = p_attribute_code)
       OR (a.multival_attr2_context = p_context_code
       AND    a.multival_attribute2 = p_attribute_code))
       AND    a.list_header_id = b.list_header_id  AND  b.active_flag = 'Y'
       AND    rownum < 2;
       EXCEPTION
       WHEN no_data_found THEN
       BEGIN
         SELECT 'Y' INTO   x_is_used
         FROM   qp_limit_attributes a, qp_limits b, qp_list_headers_b c
         WHERE  a.limit_attribute_context = p_context_code
         AND a.limit_attribute = p_attribute_code AND a.limit_id = b.limit_id
         AND b.list_header_id = c.list_header_id  AND c.active_flag = 'Y'
         AND    rownum < 2;
         EXCEPTION
         WHEN no_data_found THEN
         x_is_used := 'N';
       END;
     END;
   END;
   END IF;
END IF;

RETURN x_is_used;
END Is_Used;


--==============================================================================
--FUNCTION    - Get_Schema
--FUNC TYPE   - Public
--DESCRIPTION - Utility Function that returns the schema.
--=============================================================================
FUNCTION Get_Schema
RETURN VARCHAR2
IS
l_qp_schema            VARCHAR2(30);
l_status               VARCHAR2(30);
l_industry             VARCHAR2(30);

BEGIN

  IF (FND_INSTALLATION.GET_APP_INFO('QP', l_status, l_industry, l_qp_schema)) THEN
	NULL;
  END IF;

  RETURN l_qp_schema;

END Get_Schema;



--==============================================================================
--FUNCTION    - Attrmgr_Installed
--FUNC TYPE   - Public
--DESCRIPTION - Utility Function that returns TRUE if Attribute Manager
--              is installed. (Will be allways true from Patchset H onwards).
--=============================================================================
FUNCTION Attrmgr_Installed
RETURN VARCHAR2
IS
l_attrmgr_installed  VARCHAR2(30);

BEGIN

  l_attrmgr_installed := QP_AM_UTIL.Attrmgr_Installed;

  RETURN l_attrmgr_installed;

END Attrmgr_Installed;


--==============================================================================
--PROCEDURE   - Get_Sourcing_Info
--FUNC TYPE   - Public
--DESCRIPTION - Utility Procedure that returns the Sourcing_Enabled,
--              Sourcing_Status and Sourcing_Method for an attribute
--OUT PARAMETER - x_sourcing_enabled can be 'Y' or 'N'
--                x_sourcing_status  can be 'Y' or 'N'
--                x_sourcing_method  can be 'ATTRIBUTE MAPPING',
--                                          'CUSTOM SOURCED' or
--                                          'USER ENTERED'
--=============================================================================
PROCEDURE Get_Sourcing_Info(p_context_type     IN  VARCHAR2,
                            p_context          IN  VARCHAR2,
                            p_attribute        IN  VARCHAR2,
                            x_sourcing_enabled OUT NOCOPY VARCHAR2,
                            x_sourcing_status  OUT NOCOPY VARCHAR2,
                            x_sourcing_method  OUT NOCOPY VARCHAR2)
IS

l_pte_code         VARCHAR2(30);

CURSOR sourcing_enabled_cur(a_context_type VARCHAR2, a_context VARCHAR2,
                            a_attribute VARCHAR2, a_pte_code VARCHAR2)
IS
  SELECT a.sourcing_enabled, a.sourcing_status,
         nvl(a.user_sourcing_method, a.seeded_sourcing_method)
  FROM   qp_pte_segments a, qp_prc_contexts_b b,
         qp_segments_b c
  WHERE  b.prc_context_code = a_context
  AND    b.prc_context_type = a_context_type
  AND    c.prc_context_id = b.prc_context_id
  AND    c.segment_mapping_column = a_attribute
  AND    a.segment_id = c.segment_id
  AND    a.pte_code = a_pte_code;

BEGIN

  FND_PROFILE.GET('QP_PRICING_TRANSACTION_ENTITY', l_pte_code);

  IF l_pte_code IS NULL THEN
      l_pte_code := 'ORDFUL';
  END IF;

  OPEN  sourcing_enabled_cur(p_context_type,p_context,p_attribute,l_pte_code);

  FETCH sourcing_enabled_cur
  INTO  x_sourcing_enabled, x_sourcing_status, x_sourcing_method;

  CLOSE sourcing_enabled_cur;

END Get_Sourcing_Info;


--==============================================================================
--FUNCTION get_context
--PROC TYPE Public
--DESCRIPTION - Utility Function for Reports. Has the same function as
--              the Get_Context function in QPXQPPLQ.pld
--=============================================================================
FUNCTION Get_Context(p_flexfield_name   IN  VARCHAR2,
                     p_context          IN  VARCHAR2)
RETURN VARCHAR2
IS

Flexfield FND_DFLEX.dflex_r;
Flexinfo  FND_DFLEX.dflex_dr;
Contexts  FND_DFLEX.contexts_dr;

x_context_name        VARCHAR2(240);

l_context_type        VARCHAR2(30);
l_error_code          NUMBER;
l_enabled_flag        VARCHAR2(1);

CURSOR contexts_cur(a_context_code VARCHAR2, a_context_type VARCHAR2)
IS
  SELECT nvl(t.user_prc_context_name, t.seeded_prc_context_name), b.enabled_flag
  FROM   qp_prc_contexts_b b, qp_prc_contexts_tl t
  WHERE  b.prc_context_id = t.prc_context_id
  AND    t.language = userenv('LANG')
  AND    b.prc_context_code = a_context_code
  AND    b.prc_context_type = a_context_type;

BEGIN

  IF Attrmgr_Installed = 'Y' THEN

    QP_UTIL.Get_Context_Type(p_flexfield_name, p_context,
                             l_context_type, l_error_code);

    IF l_error_code = 0 THEN --success

      OPEN  contexts_cur(p_context, l_context_type);
      FETCH contexts_cur INTO x_context_name, l_enabled_flag;
      CLOSE contexts_cur;

    END IF; --If l_error_code = 0

  ELSE

    -- Call Flexapi to get contexts

    FND_DFLEX.get_flexfield('QP',p_FlexField_Name,Flexfield,Flexinfo);
    FND_DFLEX.get_contexts(Flexfield,Contexts);


    FOR i IN 1..Contexts.ncontexts LOOP

--    If(Contexts.is_enabled(i) AND (NOT (Contexts.is_global(i)))) Then
      IF (Contexts.is_enabled(i)) THEN

        IF p_context = Contexts.context_code(i) THEN
          x_context_name :=Contexts.context_name(i);
          EXIT;
        END IF;

      END IF;

    END LOOP;

  END IF;--If Attrmgr_Installed = 'Y'

  RETURN x_context_name;

END Get_Context;




--==============================================================================
--PROCEDURE get_context_type
--PROC TYPE Public
--DESCRIPTION - Utility Function to determine context_type for a context_code
--OUT PARAMETER - x_error_code can have one of the following values
--                0 - Success
--                1 - Failure
--=============================================================================
PROCEDURE Get_Context_Type(p_flexfield_name IN  VARCHAR2,
                           p_context_name   IN  VARCHAR2,
                           x_context_type   OUT NOCOPY VARCHAR2,
                           x_error_code     OUT NOCOPY VARCHAR2)
IS
BEGIN

  x_error_code := 0; --Initialize x_error_code to success

  IF p_flexfield_name = 'QP_ATTR_DEFNS_QUALIFIER' THEN

    x_context_type := 'QUALIFIER';

  ELSIF p_flexfield_name = 'QP_ATTR_DEFNS_PRICING' THEN

    IF p_context_name IN ('ITEM', 'PRODUCT') THEN
      x_context_type := 'PRODUCT';
    ELSE
      x_context_type := 'PRICING_ATTRIBUTE';
    END IF;

  ELSE
    x_error_code := 1; --Failure
  END IF;

END Get_Context_Type;



-- =======================================================================
-- Function  validate_num_date
--   funtion type   public
--   Returns  number
--   out parameters :
--  DESCRIPTION
--
--
-- =======================================================================

 function validate_num_date(p_datatype in varchar2
					   ,p_value in varchar2
					   )return number IS

x_error_code    NUMBER:= 0;

l_date       DATE;
l_number     NUMBER;



BEGIN
     IF p_datatype = 'N' THEN

	    l_number := qp_number.canonical_to_number(p_value);

	 ELSIF p_datatype IN ('X', 'Y')  THEN

	    --l_date   := fnd_date.canonical_to_date(p_value);
	    l_date   := to_date(p_value,'FXYYYY/MM/DD HH24:MI:SS');
      END IF;


	 RETURN x_error_code;

EXCEPTION

      WHEN OTHERS THEN

		x_error_code := 9;

		RETURN x_error_code;

END validate_num_date;


-- =======================================================================


PROCEDURE Get_Context_Attribute( p_attribute_code IN VARCHAR2,
    			         x_context OUT NOCOPY VARCHAR2,
			         x_attribute_name OUT NOCOPY VARCHAR2
                                ) IS
CURSOR context_attr_cur(a_attribute_code VARCHAR2)
IS
  SELECT a.prc_context_code, b.segment_mapping_column
  FROM   qp_prc_contexts_b a, qp_segments_b b
  WHERE  a.prc_context_id = b.prc_context_id
  AND    b.segment_code = UPPER(a_attribute_code);

BEGIN

     IF  UPPER(p_attribute_code) = 'CUSTOMER_CLASS_CODE' THEN

-------Qualifiers

       x_context := 'CUSTOMER' ;
	  x_attribute_name := 'QUALIFIER_ATTRIBUTE1' ;

     ELSIF  UPPER(p_attribute_code) = 'SOLD_TO_ORG_ID' THEN

       x_context := 'CUSTOMER';
	  x_attribute_name := 'QUALIFIER_ATTRIBUTE2' ;

     ELSIF UPPER(p_attribute_code) = 'CUSTOMER_ID' THEN

       x_context := 'CUSTOMER' ;
	  --changed for so to qp upgrade
	  --x_attribute_name := 'QUALIFIER_ATTRIBUTE3' ;
	  x_attribute_name := 'QUALIFIER_ATTRIBUTE2' ;

     ELSIF  UPPER(p_attribute_code) = 'SITE_USE_ID' THEN

       x_context := 'CUSTOMER';
	  --changed for so to qp upgrade
	  --x_attribute_name := 'QUALIFIER_ATTRIBUTE4';
	  x_attribute_name := 'QUALIFIER_ATTRIBUTE5';

     ELSIF  UPPER(p_attribute_code) = 'SITE_ORG_ID' THEN

       x_context := 'CUSTOMER';
	  x_attribute_name := 'QUALIFIER_ATTRIBUTE5';

     -- Discount
    ELSIF  UPPER(p_attribute_code) = 'DISCOUNT_ID' THEN
       x_context := 'MODLIST';
	  x_attribute_name := 'QUALIFIER_ATTRIBUTE6';


     --Agreement Name 1006
     ELSIF   UPPER(p_attribute_code) IN ('1006','1467') THEN
       x_context := 'CUSTOMER';
	  x_attribute_name := 'QUALIFIER_ATTRIBUTE7';

     --Agreement Type
     ELSIF  UPPER(p_attribute_code) IN('1005','1468') THEN
       x_context := 'CUSTOMER';
	  x_attribute_name := 'QUALIFIER_ATTRIBUTE8';

     -- Order Type
     ELSIF  UPPER(p_attribute_code)  IN ('1007','1325') THEN
       x_context := 'ORDER';
	  x_attribute_name := 'QUALIFIER_ATTRIBUTE9';



    --Price List
    ELSIF UPPER(p_attribute_code) = 'PRICE_LIST_ID' THEN
       --changed from order to modlist for so to qp upgrade
       x_context := 'MODLIST';
	  x_attribute_name := 'QUALIFIER_ATTRIBUTE4';

    --GSA Qualifier
    ELSIF UPPER(p_attribute_code) = 'GSA_CUSTOMER' THEN
       --changed from order to modlist for so to qp upgrade
       x_context := 'CUSTOMER';
	  x_attribute_name := 'QUALIFIER_ATTRIBUTE15';

    --Customer PO
    ELSIF UPPER(p_attribute_code) IN ( '1004','1053') THEN
       x_context := 'ORDER';
	  x_attribute_name := 'QUALIFIER_ATTRIBUTE12';


-------Pricing Attributes
     -- Item Number
     ELSIF UPPER(p_attribute_code) IN ('1001','1208') THEN

       x_context := 'ITEM' ;
	  x_attribute_name := 'PRICING_ATTRIBUTE1';

     -- Item Category
     ELSIF  UPPER(p_attribute_code) = '1045' THEN

       x_context := 'ITEM';
	  x_attribute_name := 'PRICING_ATTRIBUTE2';

	-- ALL
     ELSIF  UPPER(p_attribute_code) = 'ALL' THEN

       x_context := 'ITEM';
	  x_attribute_name := 'PRICING_ATTRIBUTE3';

	-- Segment_1
     ELSIF  UPPER(p_attribute_code) IN ('SEGMENT1','1020') THEN

       x_context := 'ITEM';
	  x_attribute_name := 'PRICING_ATTRIBUTE4';

	-- Segment_2
     ELSIF  UPPER(p_attribute_code)  IN ('SEGMENT2','1021') THEN


       x_context := 'ITEM';
	  x_attribute_name := 'PRICING_ATTRIBUTE5';

	-- Segment_3
     ELSIF  UPPER(p_attribute_code) IN ('SEGMENT3','1022') THEN

       x_context := 'ITEM';
	  x_attribute_name := 'PRICING_ATTRIBUTE6';

	-- Segment_4
     ELSIF  UPPER(p_attribute_code)  IN ('SEGMENT4', '1023') THEN

       x_context := 'ITEM';
	  x_attribute_name := 'PRICING_ATTRIBUTE7';

	-- Segment_5
     ELSIF  UPPER(p_attribute_code) IN ('SEGMENT5','1024') THEN

       x_context := 'ITEM';
	  x_attribute_name := 'PRICING_ATTRIBUTE8';

	-- Segment_6
     ELSIF  UPPER(p_attribute_code) IN  ('SEGMENT6' ,'1025') THEN

       x_context := 'ITEM';
	  x_attribute_name := 'PRICING_ATTRIBUTE9';

	-- Segment_7
     ELSIF  UPPER(p_attribute_code) IN ('SEGMENT7', '1026') THEN

       x_context := 'ITEM';
	  x_attribute_name := 'PRICING_ATTRIBUTE10';

	-- Segment_8
     ELSIF  UPPER(p_attribute_code) IN ('SEGMENT8','1027') THEN

       x_context := 'ITEM';
	  x_attribute_name := 'PRICING_ATTRIBUTE11';

	-- Segment_9
     ELSIF  UPPER(p_attribute_code) IN ('SEGMENT9','1028') THEN

       x_context := 'ITEM';
	  x_attribute_name := 'PRICING_ATTRIBUTE12';

	-- Segment_10
     ELSIF  UPPER(p_attribute_code)  IN ('SEGMENT10', '1029') THEN

       x_context := 'ITEM';
	  x_attribute_name := 'PRICING_ATTRIBUTE13';

	-- Segment_11
     ELSIF  UPPER(p_attribute_code) IN ('SEGMENT11', '1030') THEN

       x_context := 'ITEM';
	  x_attribute_name := 'PRICING_ATTRIBUTE14';

	-- Segment_12
     ELSIF  UPPER(p_attribute_code) IN ('SEGMENT12','1031') THEN

       x_context := 'ITEM';
	  x_attribute_name := 'PRICING_ATTRIBUTE15';

	-- Segment_13
     ELSIF  UPPER(p_attribute_code) IN ('SEGMENT13', '1032') THEN

       x_context := 'ITEM';
	  x_attribute_name := 'PRICING_ATTRIBUTE16';

	-- Segment_14
     ELSIF  UPPER(p_attribute_code) IN ('SEGMENT14','1033') THEN

       x_context := 'ITEM';
	  x_attribute_name := 'PRICING_ATTRIBUTE17';

	-- Segment_15
     ELSIF  UPPER(p_attribute_code) IN ('SEGMENT15','1034') THEN

       x_context := 'ITEM';
	  x_attribute_name := 'PRICING_ATTRIBUTE18';

	-- Segment_16
     ELSIF  UPPER(p_attribute_code) IN  ('SEGMENT16','1035') THEN

       x_context := 'ITEM';
	  x_attribute_name := 'PRICING_ATTRIBUTE19';

	-- Segment_17
     ELSIF  UPPER(p_attribute_code) IN ('SEGMENT17', '1036') THEN

       x_context := 'ITEM';
	  x_attribute_name := 'PRICING_ATTRIBUTE20';

	-- Segment_18
     ELSIF  UPPER(p_attribute_code) IN ('SEGMENT18' ,'1037') THEN

       x_context := 'ITEM';
	  x_attribute_name := 'PRICING_ATTRIBUTE21';

	-- Segment_19
     ELSIF  UPPER(p_attribute_code) IN  ('SEGMENT19' ,'1038') THEN

       x_context := 'ITEM';
	  x_attribute_name := 'PRICING_ATTRIBUTE22';

	-- Segment_20
     ELSIF  UPPER(p_attribute_code) IN ('SEGMENT20', '1039') THEN

       x_context := 'ITEM';
	  x_attribute_name := 'PRICING_ATTRIBUTE23';


----commenting out pricing attribute 1 to 15 as they are no more required for the upgrade.
---on 30 th march as per rtata.
/*
	-- Pricing_attribute1
     ELSIF  UPPER(p_attribute_code) IN ('PRICING_ATTRIBUTE1' ,'1010') THEN

       x_context := 'PRICING ATTRIBUTE';
	  x_attribute_name := 'PRICING_ATTRIBUTE18';

	-- Pricing_attribute2
     ELSIF  UPPER(p_attribute_code) IN ('PRICING_ATTRIBUTE2','1011') THEN

       x_context := 'PRICING ATTRIBUTE';
	  x_attribute_name := 'PRICING_ATTRIBUTE19';

	-- Pricing_attribute3
     ELSIF  UPPER(p_attribute_code) IN ('PRICING_ATTRIBUTE3' ,'1012') THEN

       x_context := 'PRICING ATTRIBUTE';
	  x_attribute_name := 'PRICING_ATTRIBUTE20';

	-- Pricing_attribute4
     ELSIF  UPPER(p_attribute_code) IN ('PRICING_ATTRIBUTE4' ,'1013') THEN

       x_context := 'PRICING ATTRIBUTE';
	  x_attribute_name := 'PRICING_ATTRIBUTE21';

	-- Pricing_attribute5
     ELSIF  UPPER(p_attribute_code) IN ('PRICING_ATTRIBUTE5','1014') THEN

       x_context := 'PRICING ATTRIBUTE';
	  x_attribute_name := 'PRICING_ATTRIBUTE22';

	-- Pricing_attribute6
     ELSIF  UPPER(p_attribute_code) IN ('PRICING_ATTRIBUTE6' ,'1015') THEN

       x_context := 'PRICING ATTRIBUTE';
	  x_attribute_name := 'PRICING_ATTRIBUTE23';

	-- Pricing_attribute7
     ELSIF  UPPER(p_attribute_code) IN ('PRICING_ATTRIBUTE7' ,'1016') THEN

       x_context := 'PRICING ATTRIBUTE';
	  x_attribute_name := 'PRICING_ATTRIBUTE24';

	-- Pricing_attribute8
     ELSIF  UPPER(p_attribute_code) IN ('PRICING_ATTRIBUTE8' ,'1017') THEN

       x_context := 'PRICING ATTRIBUTE';
	  x_attribute_name := 'PRICING_ATTRIBUTE25';

	-- Pricing_attribute9
     ELSIF  UPPER(p_attribute_code) IN ('PRICING_ATTRIBUTE9','1018') THEN

       x_context := 'PRICING ATTRIBUTE';
	  x_attribute_name := 'PRICING_ATTRIBUTE26';

	-- Pricing_attribute10
     ELSIF  UPPER(p_attribute_code) IN ('PRICING_ATTRIBUTE10' ,'1019') THEN

       x_context := 'PRICING ATTRIBUTE';
	  x_attribute_name := 'PRICING_ATTRIBUTE27';

	-- Pricing_attribute11
     ELSIF  UPPER(p_attribute_code) IN ('PRICING_ATTRIBUTE11' ,'1040') THEN

       x_context := 'PRICING ATTRIBUTE';
	  x_attribute_name := 'PRICING_ATTRIBUTE28';

	-- Pricing_attribute12
     ELSIF  UPPER(p_attribute_code) IN ('PRICING_ATTRIBUTE12' ,'1041') THEN

       x_context := 'PRICING ATTRIBUTE';
	  x_attribute_name := 'PRICING_ATTRIBUTE29';

	-- Pricing_attribute13
     ELSIF  UPPER(p_attribute_code) IN ('PRICING_ATTRIBUTE13','1042') THEN

       x_context := 'PRICING ATTRIBUTE';
	  x_attribute_name := 'PRICING_ATTRIBUTE30';

	-- Pricing_attribute14
     ELSIF  UPPER(p_attribute_code) IN ('PRICING_ATTRIBUTE14','1043') THEN

       x_context := 'PRICING ATTRIBUTE';
	  x_attribute_name := 'PRICING_ATTRIBUTE31';

	-- Pricing_attribute15
     ELSIF  UPPER(p_attribute_code) IN ('PRICING_ATTRIBUTE15' ,'1044') THEN

       x_context := 'PRICING ATTRIBUTE';
	  x_attribute_name := 'PRICING_ATTRIBUTE32';
*/

    --Customer Item
    ELSIF UPPER(p_attribute_code) = 'CUSTOMER_ITEM_ID' THEN
       --changed for SO to QP upgrade
       --x_context := 'ITEM';
       x_context := 'CUSTOMER_ITEM';
	  x_attribute_name := 'PRICING_ATTRIBUTE3';

     -- Units
     ELSIF  UPPER(p_attribute_code) = 'UNITS' THEN

	  x_context := 'VOLUME';
       --changed for so to qp upgrade
	  --x_attribute_name := 'PRICING_ATTRIBUTE3';
	  x_attribute_name := 'PRICING_ATTRIBUTE10';

     -- Amount
     ELSIF UPPER(p_attribute_code) = 'DOLLARS' THEN
      --changed for so to qp upgrade
      -- x_context := 'LINEAMT';
         x_context := 'VOLUME';
	  x_attribute_name := 'PRICING_ATTRIBUTE12';

     -- invalid code passed no context and attribute available
     ELSE

       IF Attrmgr_Installed = 'Y' THEN

         OPEN  context_attr_cur(p_attribute_code);

         FETCH context_attr_cur INTO  x_context, x_attribute_name;

         IF context_attr_cur%NOTFOUND THEN
           x_context := 'INVALID';
           x_attribute_name := 'INVALID';
         END IF;

         CLOSE context_attr_cur;

       ELSE
         x_context := 'INVALID';
	 x_attribute_name := 'INVALID';

       END IF; --If Attrmgr_Installed = 'Y'

     END IF;

END Get_Context_Attribute;


--===========================================================================
--  Function 'IS_Qualifier' returns 'T' if passed parameter is qualifier
--  otheriwise returns 'F'.
-- Parameter to this procedure is attribute-code from the harcode list.
--===========================================================================

FUNCTION Is_qualifier( p_attribute_code IN VARCHAR2)
  RETURN VARCHAR2
IS
CURSOR context_cur(a_attribute_code VARCHAR2)
IS
  SELECT a.prc_context_id
  FROM   qp_prc_contexts_b a, qp_segments_b b
  WHERE  a.prc_context_id = b.prc_context_id
  AND    b.segment_code = a_attribute_code
  AND    a.prc_context_type = 'QUALIFIER';

x_return VARCHAR2(1)   := FND_API.G_FALSE;
l_context_id         NUMBER;

BEGIN

  IF Attrmgr_Installed = 'Y' THEN

    OPEN  context_cur(p_attribute_code);

    FETCH context_cur INTO l_context_id;

    IF context_cur%FOUND THEN
      x_return := FND_API.G_TRUE;
    END IF;

    CLOSE context_cur;

  ELSE

    IF  UPPER(p_attribute_code) IN

      ('CUSTOMER_CLASS_CODE',
	   'SOLD_TO_ORG_ID',
	   'CUSTOMER_ID',
        'SITE_USE_ID',
        'SITE_ORG_ID',
        'PRICE_LIST_ID',
         '1006', --Agreement name
         '1467', -- new Agreement name
         '1005',-- agreement Type
         '1468',-- agreement Type
         '1007',--Order Type
         '1325',-- new Order Type
	    '1004', --customer PO
	    '1053', -- new customer PO
         'DISCOUNT_ID') THEN

       x_return := FND_API.G_TRUE;

    END IF;

  END IF; --If Attrmgr_Installed = 'Y'

  RETURN x_return;

END Is_Qualifier;

--===========================================================================
--  Function 'IS_PricingAttr' returns 'T' if passed parameter is Pricing
--  attribute otheriwise returns 'F'.
-- Parameter to this procedure is attribute-code from the harcode list.
--===========================================================================

FUNCTION Is_PricingAttr( p_attribute_code IN VARCHAR2) RETURN VARCHAR2
IS
CURSOR context_cur(a_attribute_code VARCHAR2)
IS
  SELECT a.prc_context_id
  FROM   qp_prc_contexts_b a, qp_segments_b b
  WHERE  a.prc_context_id = b.prc_context_id
  AND    b.segment_code = a_attribute_code
  AND    a.prc_context_type = 'PRICING';

x_return VARCHAR2(1) := FND_API.G_FALSE;
l_context_id         NUMBER;

BEGIN

  IF Attrmgr_Installed = 'Y' THEN

    OPEN  context_cur(p_attribute_code);

    FETCH context_cur INTO l_context_id;

    IF context_cur%FOUND THEN
      x_return := FND_API.G_TRUE;
    END IF;

    CLOSE context_cur;

  ELSE

     IF  UPPER(p_attribute_code) IN
      	 ( '1001',--item
      	  '1208',-- new item
             '1045', --item category
             'CUSTOMER_ITEM_ID',
             'UNITS',
             'DOLLARS'
		  ) THEN

      x_return := FND_API.G_TRUE;

     END IF;

  END IF; --Attrmgr_Installed = 'Y'

  RETURN x_return;

END Is_PricingAttr;


 FUNCTION Get_cust_context  RETURN VARCHAR2 IS
 x_return VARCHAR2(30);

 BEGIN

      x_return := 'CUSTOMER';

	 return x_return;

 END Get_cust_context;


 FUNCTION Get_sold_to_attrib  RETURN VARCHAR2 IS
 x_return VARCHAR2(30);

 BEGIN

      x_return := 'QUALIFIER_ATTRIBUTE2';

	 return x_return;

 END Get_sold_to_attrib;

 FUNCTION Get_cust_class_attrib  RETURN VARCHAR2  IS

 x_return VARCHAR2(30);

 BEGIN

      x_return := 'QUALIFIER_ATTRIBUTE1';

	 return x_return;

 END Get_cust_class_attrib;

FUNCTION Get_site_use_attrib  RETURN VARCHAR2  IS

 x_return VARCHAR2(30);

 BEGIN

      x_return := 'QUALIFIER_ATTRIBUTE5';

	 return x_return;

 END Get_site_use_attrib;


-- =======================================================================
-- Function Get_Entity_Value
-- =======================================================================
 FUNCTION Get_EntityValue(p_attribute_code IN VARCHAR2)
 RETURN NUMBER IS
   l_attribute_code VARCHAR2(30);
 BEGIN
   l_attribute_code := UPPER(p_attribute_code);
   IF l_attribute_code = 'PRICING_ATTRIBUTE1' THEN
      RETURN 1001;
   ELSIF l_attribute_code = 'PRICING_ATTRIBUTE2' THEN
      RETURN 1045;
   ELSIF l_attribute_code = 'QUALIFIER_ATTRIBUTE7' THEN
      RETURN 1006;
   ELSIF l_attribute_code = 'QUALIFIER_ATTRIBUTE8' THEN
      RETURN 1005;
   ELSIF l_attribute_code = 'QUALIFIER_ATTRIBUTE9' THEN
      RETURN 1007;
   ELSIF l_attribute_code = 'QUALIFIER_ATTRIBUTE12' THEN
      RETURN 1004;
   END IF;
 END;

FUNCTION Get_entityname(p_entity_id IN NUMBER)
 RETURN VARCHAR2 IS

   l_entity_code VARCHAR2(50);

 BEGIN
      IF p_entity_id IS NOT NULL THEN
         select a1.attribute_label_long into l_entity_code
	    from ak_object_attributes_tl a1,
		  oe_ak_obj_attr_ext a2
         where a2.attribute_id = p_entity_id
	    and   a1.language= userenv('lang')
	    and   a2.pricing_rule_enabled_flag= 'Y'
		and  a2.attribute_code=a1.attribute_code
		and  a2.database_object_name= a1.database_object_name
		and  a2.attribute_application_id=a1.attribute_application_id;
       end if;
    return l_entity_code;
END get_entityname;

FUNCTION Get_QP_Status RETURN VARCHAR2 IS

  l_status      VARCHAR2(1);
  l_industry    VARCHAR2(1);
  l_application_id       NUMBER := 661;
  l_retval      BOOLEAN;
  BEGIN


  IF G_PRODUCT_STATUS = FND_API.G_MISS_CHAR THEN

   l_retval := fnd_installation.get(l_application_id,l_application_id,
      						 l_status,l_industry);

        -- if l_status = 'I', QP is fully installed. Advanced pricing functionalities
	   -- should be available.
        --if  l_status = 'S', QP is shared ie Basic QP is Installed.Only basic
        --pricing functionality should be available.
	   --if l_status = 'N', -- QP not installled

   G_PRODUCT_STATUS := l_status;

  END IF;

   return G_PRODUCT_STATUS;

 END Get_QP_Status;

-- =======================================================================
-- Function  context_exists
--   funtion type   Private
--   Returns  BOOLEAN
--   out parameters : p_context_r
--  DESCRIPTION
--    Searches for context code if it exists in the context list populated by
--    get_contexts call.
-- =======================================================================


  FUNCTION context_exists(p_context        VARCHAR2,
                          p_context_dr     fnd_dflex.contexts_dr,
                          p_context_r  OUT NOCOPY fnd_dflex.context_r   )  RETURN BOOLEAN IS
  BEGIN
    IF (p_context_dr.ncontexts > 0) THEN
      FOR i IN 1..p_context_dr.ncontexts LOOP
        IF (p_context = p_context_dr.context_code(i)
           AND p_context_dr.is_enabled(i) = TRUE) THEN
          p_context_r.context_code := p_context_dr.context_code(i);
          RETURN TRUE;
        END IF;
      END LOOP;
      RETURN FALSE;
    ELSE
      RETURN FALSE;
    END IF;
 END Context_exists;


--*****************************************************************************
-- Function AM_Context_Exists
--   Function Type   Private
--   Returns  BOOLEAN
--
--  DESCRIPTION
--    New function introduced in Attributes Manager that is equivalent to
--    existing Context_Exists function but instead of checking for the existence--    of the context in flexfield tables, checks in the QP_PRC_CONTEXTS_B table.
--
--*****************************************************************************

FUNCTION AM_Context_Exists(p_context_type IN VARCHAR2,
                           p_context_code IN VARCHAR2)
RETURN BOOLEAN
IS

CURSOR context_code_cur(a_context_type VARCHAR2, a_context_code VARCHAR2)
IS
  SELECT prc_context_code
  FROM   qp_prc_contexts_b
  WHERE  prc_context_type = a_context_type
  AND    prc_context_code = a_context_code
  AND    enabled_flag = 'Y';

l_context_code VARCHAR2(30);

BEGIN

  OPEN  context_code_cur(p_context_type, p_context_code);

  FETCH context_code_cur
  INTO  l_context_code;

  IF context_code_cur%NOTFOUND THEN
     CLOSE context_code_cur;
     RETURN FALSE;
  END IF;

  CLOSE context_code_cur;
  RETURN TRUE;

END AM_Context_Exists;


-- =======================================================================
-- Function  segment_exists
--   funtion type   Private
--   Returns  BOOLEAN
--   out parameters : p_value_set_id,p_precedence
--  DESCRIPTION
--    Searches for segment name if it exists in the segment list populated by
--    get_segments call.
-- =======================================================================


  FUNCTION segment_exists(p_segment_name    IN   VARCHAR2,
                          p_segments_dr     IN   fnd_dflex.segments_dr,
		          p_check_enabled   IN   BOOLEAN := TRUE,
                          p_value_set_id    OUT  NOCOPY NUMBER,
                          p_precedence      OUT  NOCOPY NUMBER)  RETURN BOOLEAN IS
  BEGIN
    IF (p_segments_dr.nsegments > 0) THEN
      FOR i IN 1..p_segments_dr.nsegments LOOP
        IF p_check_enabled  then
            IF (p_segments_dr.application_column_name(i) = p_segment_name) and
		        p_segments_dr.is_enabled(i) THEN  ---added bu svdeshmu as per renga/jay's request.
                  p_value_set_id := p_segments_dr.value_set(i);
                  p_precedence := p_segments_dr.sequence(i);
                  RETURN TRUE;
            END IF;
        ELSE
            IF p_segments_dr.application_column_name(i) = p_segment_name  THEN
                  p_value_set_id := p_segments_dr.value_set(i);
                  p_precedence := p_segments_dr.sequence(i);
                  RETURN TRUE;
            END IF;
        END IF;

      END LOOP;
      RETURN FALSE;
    ELSE
      RETURN FALSE;
    END IF;
 END segment_exists;


--*****************************************************************************
-- Function AM_Segment_Exists
--   Function Type   Private
--   Returns  BOOLEAN
--
--  DESCRIPTION
--    New function introduced in Attributes Manager that is equivalent to
--    existing Segment_Exists function but instead of checking for the
--    existence of the segment in flexfield tables, checks in the QP_SEGMENTS_B
--    table.
--
--*****************************************************************************

FUNCTION AM_Segment_Exists(p_context_type IN VARCHAR2,
                           p_context_code IN VARCHAR2,
                           p_segment_mapping_column IN VARCHAR2,
                           p_check_enabled          IN BOOLEAN := TRUE,
                           x_valueset_id  OUT NOCOPY NUMBER,
                           x_precedence   OUT NOCOPY NUMBER)
RETURN BOOLEAN
IS

CURSOR context_id_cur(a_context_type VARCHAR2, a_context_code VARCHAR2)
IS
  SELECT prc_context_id
  FROM   qp_prc_contexts_b
  WHERE  prc_context_type = a_context_type
  AND    prc_context_code = a_context_code;

CURSOR enabled_segments_cur(a_context_id NUMBER,
                            a_segment_mapping_column VARCHAR2,
                            a_pte_code   VARCHAR2)
IS
  SELECT nvl(user_valueset_id, seeded_valueset_id),
         nvl(user_precedence, seeded_precedence)
  FROM   qp_segments_b a, qp_pte_segments b
  WHERE  a.prc_context_id = a_context_id
  AND    a.segment_mapping_column = a_segment_mapping_column
  AND    b.pte_code = a_pte_code
  AND    a.segment_id = b.segment_id
  AND    b.lov_enabled = 'Y';

CURSOR all_segments_cur(a_context_id NUMBER,
                        a_segment_mapping_column VARCHAR2,
                        a_pte_code   VARCHAR2)
IS
  SELECT nvl(user_valueset_id, seeded_valueset_id),
         nvl(user_precedence, seeded_precedence)
  FROM   qp_segments_b a, qp_pte_segments b
  WHERE  a.prc_context_id = a_context_id
  AND    a.segment_mapping_column = a_segment_mapping_column
  AND    b.pte_code = a_pte_code
  AND    a.segment_id = b.segment_id;

l_context_id NUMBER;
l_pte_code   VARCHAR2(30);

BEGIN

  --Get the PTE code for the instance.
  FND_PROFILE.GET('QP_PRICING_TRANSACTION_ENTITY', l_pte_code);

  IF l_pte_code IS NULL THEN
      l_pte_code := 'ORDFUL';
  END IF;

  --Get the context_id
  OPEN  context_id_cur(p_context_type, p_context_code);

  FETCH context_id_cur
  INTO  l_context_id;

  IF context_id_cur%NOTFOUND THEN
    CLOSE context_id_cur;
  --  RAISE Context Not Found Exception;
  END IF;

  CLOSE context_id_cur;

  --Depending on the value passed in parameter p_check_enabled,
  --check the existence of the segment.
  IF p_check_enabled THEN --Check against only enabled segments
    OPEN  enabled_segments_cur(l_context_id, p_segment_mapping_column,
                               l_pte_code);
    FETCH enabled_segments_cur
    INTO x_valueset_id, x_precedence;

    IF enabled_segments_cur%NOTFOUND THEN
      CLOSE enabled_segments_cur;
      RETURN FALSE;
    END IF;

    CLOSE enabled_segments_cur;

  ELSE --check against all segments if p_check_enabled is FALSE.
    OPEN  all_segments_cur(l_context_id, p_segment_mapping_column,
                           l_pte_code);
    FETCH all_segments_cur
    INTO x_valueset_id, x_precedence;

    IF all_segments_cur%NOTFOUND THEN
      CLOSE all_segments_cur;
      RETURN FALSE;
    END IF;

    CLOSE all_segments_cur;

  END IF; --p_check_enabled

  RETURN TRUE;

END AM_Segment_Exists;



-- =======================================================================
-- Function  value_exists
--   funtion type   Private
--   Returns  BOOLEAN
--   out parameters : None
--  DESCRIPTION
--    Searches for value if it exists in the value set list populated by
--    get_valueset call.
-- =======================================================================


 FUNCTION  value_exists(p_vsid IN NUMBER,p_value IN VARCHAR2)  RETURN BOOLEAN IS
   v_vset    fnd_vset.valueset_r;
   v_fmt     fnd_vset.valueset_dr;
   v_found  BOOLEAN;
   v_row    NUMBER;
   v_value  fnd_vset.value_dr;
 BEGIN
   fnd_vset.get_valueset(p_vsid, v_vset, v_fmt);
   fnd_vset.get_value_init(v_vset, TRUE);
   fnd_vset.get_value(v_vset, v_row, v_found, v_value);

   WHILE(v_found) LOOP
      IF (v_value.value = p_value) THEN
        fnd_vset.get_value_end(v_vset);
        RETURN TRUE;
      END IF;
      fnd_vset.get_value(v_vset, v_row, v_found, v_value);
   END LOOP;
   fnd_vset.get_value_end(v_vset);
   RETURN FALSE;
 END value_exists;

-- ==========================================================================
-- Function  value_exists_in_table
--   funtion type   Private
--   Returns  BOOLEAN
--   out parameters : None
--  DESCRIPTION
--    Searches for value if it exist by building dynamic query stmt when when valueset validation type is F
--    the list populated by  get_valueset call.
-- ===========================================================================


  FUNCTION value_exists_in_table(p_table_r  fnd_vset.table_r,
                                 p_value    VARCHAR2,
						   x_id    OUT NOCOPY VARCHAR2,
						   x_value OUT NOCOPY VARCHAR2) RETURN BOOLEAN IS
    v_selectstmt   VARCHAR2(2000) ; --dhgupta changed length from 500 to 2000 for bug # 1888160
    v_cursor_id    INTEGER;
    v_value        VARCHAR2(150);
    /* julin - unused variable */
    -- v_meaning	    VARCHAR2(240);
    v_id           VARCHAR2(150);
    v_retval       INTEGER;
    v_where_clause VARCHAR2(2000);  -- bug#13844692
    v_cols	    VARCHAR2(1000);
l_order_by                    VARCHAR2(1000);
l_pos1		number;
l_where_length  number;

/* Added for 3210264 */
type refcur is ref cursor;
v_cursor refcur;

type valueset_cur_type is RECORD (
valueset_value varchar2(150),
valueset_id  varchar2(150)
);
valueset_cur valueset_cur_type;

  BEGIN
     v_cursor_id := DBMS_SQL.OPEN_CURSOR;
--Commented out for 2621644
--IF (p_table_r.id_column_name IS NOT NULL) THEN -- Bug 1982009

 --8923075 No validation can be done if there is a bind variable
         --attached in the value set where clause.
         --1. When using forms, validation is done at client side only.
         --2. If there is a API call, validation has to be done before calling
         --   this function
         IF(p_table_r.where_clause IS NOT NULL
            AND INSTR(p_table_r.where_clause,':')>0) THEN
              oe_debug_pub.add('Found bind variable in where clause');
              oe_debug_pub.add('where clause:' || p_table_r.where_clause);
              RETURN true;
         END if;
         --end 8923075

       /* Added for 2492020 */

         IF instr(UPPER(p_table_r.where_clause), 'ORDER BY') > 0 THEN
               l_order_by := substr(p_table_r.where_clause, instr(UPPER(p_table_r.where_clause), 'ORDER BY'));
               v_where_clause := replace(p_table_r.where_clause, l_order_by ,'');
         ELSE
	       v_where_clause := p_table_r.where_clause;
         END IF;


--	if instr(upper(p_table_r.where_clause),'WHERE ') > 0 then  --Commented out for 2492020
        IF instr(upper(v_where_clause),'WHERE') > 0 then --3839853 removed space in 'WHERE '
	--to include the id column name in the query

       		v_where_clause:= rtrim(ltrim(v_where_clause));
		l_pos1 := instr(upper(v_where_clause),'WHERE');
		l_where_length := LENGTHB('WHERE');
		v_where_clause:= substr(v_where_clause,l_pos1+l_where_length);

	   IF (p_table_r.id_column_name IS NOT NULL) THEN
		--included extra quotes for comparing varchar and num values in select
/* Commented out for 2492020
	     v_where_clause := replace(UPPER(p_table_r.where_clause)
			,'WHERE '
			,'WHERE '||p_table_r.id_column_name||' = '''||p_value||''' AND ');
*/
     --      v_where_clause := 'WHERE '||p_table_r.id_column_name||' = '''||p_value||''' AND '||v_where_clause;  -- 2492020

           v_where_clause := 'WHERE '||p_table_r.id_column_name||' = :p_val AND '||v_where_clause;--3210264
	   ELSE
/* Commented out for 2492020
	     v_where_clause := replace(UPPER(p_table_r.where_clause)
			,'WHERE '
			,'WHERE '||p_table_r.value_column_name||' = '''||p_value||''' AND ');
*/
           --v_where_clause := 'WHERE '||p_table_r.value_column_name||' = '''||p_value||''' AND '||v_where_clause;--2492020

           v_where_clause := 'WHERE '||p_table_r.value_column_name||' = :p_val AND '||v_where_clause;--3210264

	   END IF;
	ELSE



	   IF v_where_clause IS NOT NULL THEN -- FP 115.88.1159.7
	   	IF (p_table_r.id_column_name IS NOT NULL) THEN
/* Commented out for 2492020
		v_where_clause := 'WHERE '||p_table_r.id_column_name||' = '''||p_value||''' '||UPPER(p_table_r.where_clause);
*/
		--Added for 2492020
                --v_where_clause := 'WHERE '||p_table_r.id_column_name||' = '''||p_value||''' '||v_where_clause;

                v_where_clause := 'WHERE '||p_table_r.id_column_name||' = :p_val AND '||v_where_clause;--3210264  bug#13585536
	   	ELSE
/* Commented out for 2492020
		v_where_clause := 'WHERE '||p_table_r.value_column_name||' = '''||p_value||''' '||UPPER(p_table_r.where_clause);
*/
		--Added for 2492020
                --v_where_clause := 'WHERE '||p_table_r.value_column_name||' = '''||p_value||''' '||v_where_clause;

                v_where_clause := 'WHERE '||p_table_r.value_column_name||' = :p_val AND '||v_where_clause;--3210264 bug#13585536
	   	END IF;
-- begin FP 115.88.1159.7
		 /* added ELSE block for 3839853 */
     	    ELSE
	    	IF (p_table_r.id_column_name IS NOT NULL) THEN
                v_where_clause := 'WHERE '||p_table_r.id_column_name||' = :p_val '||v_where_clause;
	    	ELSE
                v_where_clause := 'WHERE '||p_table_r.value_column_name||' = :p_val '||v_where_clause;
          	END IF;
-- end FP 115.88.1159.7
	    END IF;

end if;

	IF l_order_by IS NOT NULL THEN
		v_where_clause := v_where_clause||' '||l_order_by;
	END IF;

/* Commented out for 2621644

ELSE
     v_where_clause := p_table_r.where_clause;
END IF;
*/
	v_cols := p_table_r.value_column_name;
-------------------
--changes made by spgopal for performance problem
--added out parameters to pass back id and value for given valueset id
-------------------

   IF (p_table_r.id_column_name IS NOT NULL) THEN

--
-- to_char() conversion function is defined only for
-- DATE and NUMBER datatypes.
--
	IF (p_table_r.id_column_type IN ('D', 'N')) THEN
																		v_cols := v_cols || ' , To_char(' || p_table_r.id_column_name || ')';
	ELSE
		v_cols := v_cols || ' , ' || p_table_r.id_column_name;
	END IF;
   ELSE
	v_cols := v_cols || ', NULL ';
   END IF;



       v_selectstmt := 'SELECT  '||v_cols||' FROM  '||p_table_r.table_name||' '||v_where_clause;

	  oe_debug_pub.add('select stmt1'||v_selectstmt);
------------------

/*
	IF p_table_r.id_column_name is not null then

       v_selectstmt := 'SELECT  '||p_table_r.id_column_name||' FROM  '||p_table_r.table_name||' '||v_where_clause;

    ELSE

     v_selectstmt := 'SELECT  '||p_table_r.value_column_name||' FROM  '||p_table_r.table_name||' '||p_table_r.where_clause;

    END IF;


/* Added for 3210264 */

open v_cursor for v_selectstmt using p_value;
fetch v_cursor into valueset_cur;
IF v_Cursor%NOTFOUND THEN
        CLOSE v_cursor;
    DBMS_SQL.CLOSE_CURSOR(v_cursor_id);
        RETURN FALSE;
END IF;
x_id := valueset_cur.valueset_id;
x_value := valueset_cur.valueset_value;
CLOSE v_cursor;
    DBMS_SQL.CLOSE_CURSOR(v_cursor_id);
RETURN TRUE;


/*
    -- parse the query

     DBMS_SQL.PARSE(v_cursor_id,v_selectstmt,DBMS_SQL.V7);
	    oe_debug_pub.add('after parse1');
     -- Bind the input variables
     DBMS_SQL.DEFINE_COLUMN(v_cursor_id,1,v_value,150);
     DBMS_SQL.DEFINE_COLUMN(v_cursor_id,2,v_id,150);
     v_retval := DBMS_SQL.EXECUTE(v_cursor_id);
     LOOP
       -- Fetch rows in to buffer and check the exit condition from  the loop
       IF( DBMS_SQL.FETCH_ROWS(v_cursor_id) = 0) THEN
          EXIT;
       END IF;
       -- Retrieve the rows from buffer into PLSQL variables
       DBMS_SQL.COLUMN_VALUE(v_cursor_id,1,v_value);
       DBMS_SQL.COLUMN_VALUE(v_cursor_id,2,v_id);

       IF v_id IS NULL AND (p_value = v_value) THEN
	    oe_debug_pub.add('id null, passing value'||p_value||','||v_value);
         DBMS_SQL.CLOSE_CURSOR(v_cursor_id);
	    x_id := v_id;
	    x_value := v_value;
         RETURN TRUE;
	  ELSIF (p_value = v_id) THEN
	    oe_debug_pub.add('id exists, passing id'||p_value||','||v_id);
         DBMS_SQL.CLOSE_CURSOR(v_cursor_id);
	    x_id := v_id;
	    x_value := v_value;
         RETURN TRUE;
	  ELSE
		Null;
	    oe_debug_pub.add('value does notmatch, continue search'||p_value||','||v_id);
       END IF;
    END LOOP;
    DBMS_SQL.CLOSE_CURSOR(v_cursor_id);
    RETURN FALSE;
*/
 EXCEPTION
   WHEN OTHERS THEN
	    oe_debug_pub.add('value_exists_in_table exception');
     DBMS_SQL.CLOSE_CURSOR(v_cursor_id);
     RETURN FALSE;
 END value_exists_in_table;

-- =============================================================================
--  PROCEDURE validate_qp_flexfield
--  procedure type  PUBLIC
--   out parameters : context_flag,attribute_flag,context_flag,attribute_flag,value_flag,datatype,precedence,error_code
--   Meaning for error codes
--   errorcode        = 0    Successful
--                    = 1    flexfield_name is not passed.
--                    = 2    context value is not passed
--                    = 3    attribute value is not passed.
--                    = 4    value is not passed
--                    = 5    application short name is not passed

--                    = 6    Invalid application short name.
--	              = 7    Invalid context passed
--                    = 8    Invalid segment passed
--                    = 9    Value passed is not a valid value of value set or
--                             Value set query is wrongly defined..
--                    = 10   Flexfield name is invalid.
--  DESCRIPTION
--  Checks the validity of flexfield,context code,segments and values  passed to the procedure.
--==============================================================================

PROCEDURE validate_qp_flexfield(flexfield_name         IN     VARCHAR2,
                                context                IN     VARCHAR2,
                                attribute              IN     VARCHAR2,
                                value                  IN     VARCHAR2,
                                application_short_name IN     VARCHAR2,
                                context_flag           OUT    NOCOPY VARCHAR2,
                                attribute_flag         OUT    NOCOPY VARCHAR2,
                                value_flag             OUT    NOCOPY VARCHAR2,
                                datatype               OUT    NOCOPY VARCHAR2,
                                precedence   	       OUT    NOCOPY VARCHAR2,
                                error_code    	       OUT    NOCOPY NUMBER ,
			        check_enabled          IN     BOOLEAN := TRUE)
IS

CURSOR Cur_get_application_id(app_short_name VARCHAR2)
IS
  SELECT application_id
  FROM   fnd_application
  WHERE  application_short_name = app_short_name;

v_context_dr     fnd_dflex.contexts_dr;
v_dflex_r        fnd_dflex.dflex_r;
v_context_r      fnd_dflex.context_r;
v_segments_dr    fnd_dflex.segments_dr;
v_value_set_id   NUMBER;
v_precedence     NUMBER;
v_valueset_r     fnd_vset.valueset_r;
v_format_dr      fnd_vset.valueset_dr;
v_valueset_dr    fnd_vset.valueset_dr;
v_dflex_dr       fnd_dflex.dflex_dr;
v_flexfield_val_ind NUMBER DEFAULT 0;
--l_value 	VARCHAR2(150);
l_value 	VARCHAR2(240);--fix for 19770132
l_id 		VARCHAR2(150);

l_attrmgr_installed VARCHAR2(30);
l_context_type  VARCHAR2(30);
l_error_code    NUMBER;
l_application_id    NUMBER;

BEGIN
  --Initialize flags and error_code.
  context_flag  := 'N';
  attribute_flag := 'N';
  value_flag     := 'N';
  error_code     := 0;

  IF (flexfield_name IS NULL) THEN
    error_code := 1;  -- flexfield_name is not passed.
    RETURN;
  END IF;

  IF (context IS NULL) THEN
    error_code := 2;
    RETURN; -- context is not passed
  END IF;

  IF (attribute IS NULL) THEN
     error_code := 3;
     RETURN;  -- attribute is not passed.
  END IF;

  IF (value IS NULL) THEN
    error_code := 4;  -- value is not passed
    RETURN;
  END IF;

  IF (application_short_name IS NULL) THEN
    error_code := 5;  -- application short name is not passed
    RETURN;
  END IF;

  --Get Attrmgr_Installed status
  l_attrmgr_installed := Attrmgr_Installed;

  -- Get the application_id

  OPEN Cur_get_application_id(application_short_name);

  IF l_attrmgr_installed = 'Y' THEN
    FETCH Cur_get_application_id INTO l_application_id;
  ELSE
    FETCH Cur_get_application_id INTO v_dflex_r.application_id;
  END IF;

  IF (Cur_get_application_id%NOTFOUND) THEN
    CLOSE Cur_get_application_id;
    error_code := 6;  -- Invalid application short name.
    RETURN;
  END IF;

  CLOSE Cur_get_application_id;

  -- check if flexfield name passed is a valid one or not.

  IF l_attrmgr_installed = 'Y' THEN

    IF flexfield_name NOT IN ('QP_ATTR_DEFNS_PRICING',
                              'QP_ATTR_DEFNS_QUALIFIER')
    THEN
      error_code := 10; --Invalid Flexfield Name
      RETURN;
    END IF;

    Get_Context_Type(flexfield_name, context,
                     l_context_type, l_error_code);

    IF l_error_code = 0 THEN

      IF AM_Context_Exists(l_context_type, context)
      THEN
        context_flag := 'Y';
      ELSE
        error_code := 7;  -- Invalid context passed
        RETURN;
      END IF;

      IF AM_Segment_Exists(l_context_type, context, attribute,
                           check_enabled, v_value_set_id, v_precedence)
      THEN
        precedence := v_precedence;
        attribute_flag := 'Y';
      ELSE
        error_code := 8;  -- Invalid Attribute passed
        RETURN;
      END IF;

    END IF; --If l_error_code = 0

  ELSE

    BEGIN
      v_flexfield_val_ind:= 1;
      fnd_dflex.get_flexfield(application_short_name,flexfield_name,v_dflex_r,v_dflex_dr);

      -- Get the context listing for the flexfield
      fnd_dflex.get_contexts(v_dflex_r,v_context_dr);

      IF (context_exists(context,v_context_dr,v_context_r) = TRUE) THEN
        context_flag := 'Y';
      ELSE
        context_flag := 'N';
        error_code := 7;  -- Invalid context passed
        RETURN;
      END IF;

      v_context_r.flexfield := v_dflex_r;

      -- Get the enabled segments for the context selected.

      --fnd_dflex.get_segments(v_context_r,v_segments_dr,TRUE);
      fnd_dflex.get_segments(v_context_r,v_segments_dr,FALSE);

      IF (segment_exists(attribute,v_segments_dr,check_enabled,v_value_set_id,v_precedence) = TRUE) THEN
        IF (v_precedence IS NOT NULL) THEN
          precedence := v_precedence;
        END IF;
        attribute_flag := 'Y';
        IF (v_value_set_id IS NULL) THEN
          datatype := 'C';
          value_flag := 'Y';  -- If there is no valueset attached then just pass the validation.
          error_code := 0;
          RETURN;
        END IF;
      ELSE
        attribute_flag :='N';
        error_code := 8;   -- Invalid segment passed
        RETURN;
      END IF;

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        IF (v_flexfield_val_ind = 1) THEN
          error_code := 10;
          RETURN;
        END IF;
    END;

  END IF; --If l_attrmgr_installed = 'Y'

  --Validation of the Value against a Value Set is common to both code paths,
  --i.e., with or without Attributes Manager Installed.

  -- If there is no valueset attached then just pass the validation.
  IF (v_value_set_id IS NULL) THEN
    datatype := 'C';
    value_flag := 'Y';
    error_code := 0;
    RETURN;
  END IF;

  -- Get value set information and validate the value passed.
  fnd_vset.get_valueset(v_value_set_id,v_valueset_r,v_valueset_dr);

  datatype := v_valueset_dr.format_type;

  -- check if there is any value set attached to the segment
  IF (v_value_set_id IS NULL or not g_validate_flag)
  THEN
    value_flag := 'Y';
    RETURN;
  END IF;

  IF (v_valueset_r.validation_type = 'I') THEN --Validation type is independent

    IF value_exists(v_value_set_id,value) THEN
      value_flag := 'Y';
    ELSE
      error_code := 9;  -- Value does not exist.
    END IF;

  ELSIF (v_valueset_r.validation_type = 'F') THEN --Validation type is table

    IF value_exists_in_table(v_valueset_r.table_info,value,l_id,l_value) THEN
      value_flag := 'Y';
    ELSE
      error_code := 9;  -- Value does not exist.
    END IF;

  ELSIF (v_valueset_r.validation_type = 'N') or datatype in( 'N','X','Y') THEN
         ---added for proper handling of dates/number in multilingual envs.
     error_code := validate_num_date(datatype,value);

     IF error_code = 0 then
       value_flag := 'Y';
     ELSE
       value_flag := 'N';
     END IF;

  END IF;

END  validate_qp_flexfield;


-- =============================================================================
--  PROCEDURE validate_context_code
--  procedure type  PUBLIC
--   out parameters : p_error_code
--   Meaning for error codes
--   errorcode        = 0    Successfull
--                    = 1    flexfield_name is not passed.
--                    = 2    context name is not passed
--                    = 3    application short name value is not passed.
--                    = 4    invalid application short name
--                    = 5    invalid flexfield name
--                    = 6    Invalid context.
--  DESCRIPTION
--  Validates the context passed to the procedure.
--==============================================================================

PROCEDURE validate_context_code(p_flexfield_name          IN  VARCHAR2,
	                        p_application_short_name  IN  VARCHAR2,
  		 	        p_context_name            IN  VARCHAR2,
  		 	        p_error_code              OUT NOCOPY NUMBER)
IS
CURSOR Cur_get_application_id(app_short_name VARCHAR2)
IS
  SELECT application_id
  FROM   fnd_application
  WHERE  application_short_name = app_short_name;

v_flexfield_name    NUMBER DEFAULT 1;
v_dflex_r           fnd_dflex.dflex_r;
v_context_r         fnd_dflex.context_r;
v_context_dr        fnd_dflex.contexts_dr;
v_dflex_dr          fnd_dflex.dflex_dr;
v_flexfield_val_ind NUMBER;

l_attrmgr_installed VARCHAR2(30);
l_application_id    NUMBER;
l_context_type      VARCHAR2(30);

BEGIN
  IF (p_flexfield_name IS NULL) THEN
    p_error_code := 1;  -- flexfield_name is not passed.
    RETURN;
  END IF;

  IF (p_context_name IS NULL) THEN
    p_error_code := 2;
    RETURN; -- context value is not passed
  END IF;

  IF (p_application_short_name IS NULL) THEN
    p_error_code := 3;  -- application short name is not passed
    RETURN;
  END IF;

  --Get Attrmgr_Installed status
  l_attrmgr_installed := Attrmgr_Installed;

  -- Fetch application id for application short name passed.
  OPEN Cur_get_application_id(p_application_short_name);

  IF l_attrmgr_installed = 'Y' THEN
    FETCH Cur_get_application_id INTO l_application_id;
  ELSE
    FETCH Cur_get_application_id INTO v_dflex_r.application_id;
  END IF;

  IF (Cur_get_application_id%NOTFOUND) THEN
    CLOSE Cur_get_application_id;
    p_error_code := 4;  -- Invalid application short name.
    RETURN;
  END IF;

  CLOSE Cur_get_application_id;

  -- check if flexfield name passed is a valid one or not.

  IF l_attrmgr_installed = 'Y' THEN

    IF p_flexfield_name NOT IN ('QP_ATTR_DEFNS_PRICING',
                                'QP_ATTR_DEFNS_QUALIFIER')
    THEN
      p_error_code := 5; --Invalid Flexfield Name
      RETURN;
    END IF;

    Get_Context_Type(p_flexfield_name,p_context_name,
                     l_context_type, p_error_code);

    IF p_error_code = 0 THEN

      IF AM_Context_Exists(l_context_type, p_context_name)
      THEN
        p_error_code := 0;  -- valid context name.
      ELSE
        p_error_code := 6;  -- Invalid context passed
        RETURN;
      END IF;

    END IF; --If p_error_code = 0

  ELSE

    BEGIN
      v_flexfield_val_ind:= 1;
      fnd_dflex.get_flexfield(p_application_short_name,p_flexfield_name,
                              v_dflex_r,v_dflex_dr);

      -- Get the context listing for the flexfield
      fnd_dflex.get_contexts(v_dflex_r,v_context_dr);

      IF (context_exists(p_context_name,v_context_dr,v_context_r) = TRUE)
      THEN
        p_error_code := 0;  -- valid context name.
      ELSE
        p_error_code := 6;  -- Invalid context passed
        RETURN;
      END IF;

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        IF (v_flexfield_val_ind = 1) THEN
          p_error_code := 5;
          RETURN;
        END IF;
    END;

  END IF; --If l_attrmgr_installed = 'Y'

END validate_context_code;

-- =============================================================================
--  PROCEDURE validate_attribute_name
--  procedure type  PUBLIC
--   out parameters : p_error_code
--   Meaning for error codes
--   errorcode        = 0    Successfull
--                    = 1    flexfield_name is not passed.
--                    = 2    context name is not passed
--                    = 3    application short name value is not passed.
--                    = 4    invalid application short name
--                    = 5    invalid flexfield name
--                    = 6    Invalid context.
--                    = 7    No Attribute Passes.
--                    = 8   Invalid Attribute.
--  DESCRIPTION
--  Validates the attribute passed to the procedure.
--==============================================================================

 PROCEDURE validate_attribute_name(p_application_short_name IN VARCHAR2,
                                   p_flexfield_name         IN VARCHAR2,
                                   p_context_name           IN VARCHAR2,
                                   p_attribute_name         IN VARCHAR2,
                                   p_error_code             OUT NOCOPY NUMBER)
IS
CURSOR Cur_get_application_id(app_short_name VARCHAR2) IS
  SELECT application_id
  FROM   fnd_application
  WHERE  application_short_name = app_short_name;

v_error_code   NUMBER DEFAULT 0;
v_dflex_r      fnd_dflex.dflex_r;
v_segments_dr  fnd_dflex.segments_dr;
v_precedence   NUMBER;
v_value_set_id NUMBER;
v_context_r    fnd_dflex.context_r;

l_application_id    NUMBER;
l_context_type      VARCHAR2(30);

BEGIN

  Validate_Context_Code(p_flexfield_name,p_application_short_name,
                        p_context_name,v_error_code);

  IF (v_error_code = 0) THEN

    IF (p_attribute_name IS NULL) THEN
      p_error_code := 7; -- No attribute passed
      RETURN;
    END IF;

    IF Attrmgr_Installed = 'Y' THEN

      Get_Context_Type(p_flexfield_name, p_context_name,
                       l_context_type, p_error_code);

      IF p_error_code = 0 THEN

        IF AM_Segment_Exists(l_context_type, p_context_name, p_attribute_name,
                             FALSE, v_value_set_id, v_precedence)
        THEN
          p_error_code := 0;  -- Successful
        ELSE
          p_error_code := 8;  -- Invalid Attribute passed
          RETURN;
        END IF;

      END IF; --If p_error_code is 0

    ELSE

      -- Just get the application  id no validation required.

      OPEN Cur_get_application_id(p_application_short_name);
      FETCH Cur_get_application_id INTO v_dflex_r.application_id;
      CLOSE Cur_get_application_id;

      v_dflex_r.flexfield_name := p_flexfield_name;
      v_context_r.flexfield := v_dflex_R;
      v_context_r.context_code := p_context_name;

      -- Get the enabled segments for the context selected.

      --FND_DFLEX.GET_SEGMENTS(V_CONTEXT_R,V_SEGMENTS_DR,TRUE);
      FND_DFLEX.GET_SEGMENTS(V_CONTEXT_R,V_SEGMENTS_DR,FALSE);

      IF (segment_exists(p_attribute_name,v_segments_dr,true,v_value_set_id,
                         v_precedence) = TRUE)
      THEN
         p_error_code := 0;
         RETURN;
      ELSE
        p_error_code := 8;  -- INVALID ATTRIBUTE PASSED
        RETURN;
      END IF;

    END IF; --If Attrmgr_Installed = 'Y'

  ELSE

    p_error_code := v_error_code;
    RETURN;

  END IF; --If v_error_code = 0

END Validate_Attribute_Name;



PROCEDURE Get_Valueset_Id(p_flexfield_name  IN  VARCHAR2,
			  p_context         IN  VARCHAR2 ,
                          p_seg             IN  VARCHAR2 ,
	      		  x_vsid            OUT NOCOPY NUMBER,
			  x_format_type     OUT NOCOPY VARCHAR2,
                          x_validation_type OUT NOCOPY VARCHAR2)
IS

flexfield        fnd_dflex.dflex_r;
flexinfo         fnd_dflex.dflex_dr;
test_rec         fnd_vset.valueset_r;
x_valuesetid     NUMBER := null;
test_frec        fnd_vset.valueset_dr;
contexts         fnd_dflex.contexts_dr;
i                BINARY_INTEGER;
j                BINARY_INTEGER;
segments         fnd_dflex.segments_dr;

l_context_type      VARCHAR2(30);
l_error_code        NUMBER;

CURSOR valueset_id_cur(a_context_type VARCHAR2, a_context_code VARCHAR2,
                       a_segment_code VARCHAR2)
IS
  SELECT nvl(a.user_valueset_id, a.seeded_valueset_id)
  FROM   qp_segments_b a, qp_prc_contexts_b b
  WHERE  a.prc_context_id = b.prc_context_id
  AND    b.prc_context_type = a_context_type
  AND    b.prc_context_code = a_context_code
  AND    a.segment_code = a_segment_code;


BEGIN

  IF Attrmgr_Installed = 'Y' THEN

    QP_UTIL.Get_Context_Type(p_flexfield_name, p_context,
                             l_context_type, l_error_code);

    IF l_error_code = 0 THEN

      OPEN  valueset_id_cur(l_context_type, p_context, p_seg);
      FETCH valueset_id_cur INTO x_valuesetid;
      CLOSE valueset_id_cur;

    END IF; --If l_error_code = 0

  ELSE

    fnd_dflex.get_flexfield('QP',p_flexfield_name,flexfield,flexinfo);
    fnd_dflex.get_contexts(flexfield,contexts);
    fnd_dflex.get_segments(fnd_dflex.make_context(flexfield,p_context),segments,true);
    FOR j IN 1..segments.nsegments LOOP

      IF segments.segment_name(j) = p_seg THEN
        x_valuesetid := segments.value_set(j);
      END IF;

    END LOOP;

  END IF; --if Attrmgr_Installed = 'Y'

  IF x_valuesetid IS NOT NULL THEN
    fnd_vset.get_valueset(x_valuesetid,test_rec,test_frec);
    x_vsid :=x_valuesetid;
    x_format_type :=test_frec.format_type;
    x_validation_type :=test_rec.validation_type;
  ELSE
    x_vsid := NULL;
    x_format_type :='C';
    x_validation_type :=NULL;

  END IF;

END GET_VALUESET_ID;


PROCEDURE GET_PROD_FLEX_PROPERTIES( PRIC_ATTRIBUTE_CONTEXT  IN VARCHAR2,
                                 				  PRIC_ATTRIBUTE          IN VARCHAR2,
                                 				  PRIC_ATTR_VALUE   	 IN VARCHAR2,
						   				  X_DATATYPE             OUT NOCOPY VARCHAR2,
						   				  X_PRECEDENCE           OUT NOCOPY NUMBER,
						   				  X_ERROR_CODE           OUT NOCOPY NUMBER)
IS

L_CONTEXT_FLAG                VARCHAR2(1);
L_ATTRIBUTE_FLAG              VARCHAR2(1);
L_VALUE_FLAG                  VARCHAR2(1);
L_DATATYPE                    VARCHAR2(1);
L_PRECEDENCE                  NUMBER;
L_ERROR_CODE                  NUMBER := 0;

BEGIN

    QP_UTIL.VALIDATE_QP_FLEXFIELD(FLEXFIELD_NAME         =>'QP_ATTR_DEFNS_PRICING'
			 ,CONTEXT                        =>PRIC_ATTRIBUTE_CONTEXT
			 ,ATTRIBUTE                      =>PRIC_ATTRIBUTE
			 ,VALUE                          =>PRIC_ATTR_VALUE
                ,APPLICATION_SHORT_NAME         => 'QP'
			 ,CHECK_ENABLED			   =>FALSE
			 ,CONTEXT_FLAG                   =>L_CONTEXT_FLAG
			 ,ATTRIBUTE_FLAG                 =>L_ATTRIBUTE_FLAG
			 ,VALUE_FLAG                     =>L_VALUE_FLAG
			 ,DATATYPE                       =>L_DATATYPE
			 ,PRECEDENCE                      =>L_PRECEDENCE
			 ,ERROR_CODE                     =>L_ERROR_CODE
			 );

		X_DATATYPE := NVL(L_DATATYPE,'C');
		X_PRECEDENCE := NVL(L_PRECEDENCE,5000);

END GET_PROD_FLEX_PROPERTIES;


PROCEDURE GET_QUAL_FLEX_PROPERTIES( QUAL_ATTRIBUTE_CONTEXT  IN VARCHAR2,
                                 				  QUAL_ATTRIBUTE          IN VARCHAR2,
                                 				  QUAL_ATTR_VALUE   	 IN VARCHAR2,
						   				  X_DATATYPE             OUT NOCOPY VARCHAR2,
						   				  X_PRECEDENCE           OUT NOCOPY NUMBER,
						   				  X_ERROR_CODE           OUT NOCOPY NUMBER)
IS

L_CONTEXT_FLAG                VARCHAR2(1);
L_ATTRIBUTE_FLAG              VARCHAR2(1);
L_VALUE_FLAG                  VARCHAR2(1);
L_DATATYPE                    VARCHAR2(1);
L_PRECEDENCE                  NUMBER;
L_ERROR_CODE                  NUMBER := 0;

BEGIN

    QP_UTIL.VALIDATE_QP_FLEXFIELD(FLEXFIELD_NAME         =>'QP_ATTR_DEFNS_QUALIFIER'
			 ,CONTEXT                        =>QUAL_ATTRIBUTE_CONTEXT
			 ,ATTRIBUTE                      =>QUAL_ATTRIBUTE
			 ,VALUE                          =>QUAL_ATTR_VALUE
                ,APPLICATION_SHORT_NAME         => 'QP'
			 ,CHECK_ENABLED			   =>FALSE
			 ,CONTEXT_FLAG                   =>L_CONTEXT_FLAG
			 ,ATTRIBUTE_FLAG                 =>L_ATTRIBUTE_FLAG
			 ,VALUE_FLAG                     =>L_VALUE_FLAG
			 ,DATATYPE                       =>L_DATATYPE
			 ,PRECEDENCE                      =>L_PRECEDENCE
			 ,ERROR_CODE                     =>L_ERROR_CODE
			 );

		X_DATATYPE := NVL(L_DATATYPE,'C');
		X_PRECEDENCE := NVL(L_PRECEDENCE,5000);

END GET_QUAL_FLEX_PROPERTIES;


-- =======================================================================
-- FUNCTION  Get_Attribute_Name
-- FUNTION TYPE   Public
-- RETURNS  APPLICATION_COLUMN_NAME
-- DESCRIPTION
--  searches for segment name and returns coressponding application column name.
-- =======================================================================


FUNCTION Get_Attribute_Name(p_application_short_name IN  VARCHAR2,
                            p_flexfield_name         IN  VARCHAR2,
                            p_context_name           IN  VARCHAR2,
                            p_attribute_name         IN  VARCHAR2)
RETURN VARCHAR2
IS

CURSOR cur_get_application_id(app_short_name VARCHAR2)
IS
  SELECT application_id
  FROM   fnd_application
  WHERE  application_short_name = app_short_name;

v_dflex_r      fnd_dflex.dflex_r;
v_segments_dr  fnd_dflex.segments_dr;
v_context_r    fnd_dflex.context_r;

CURSOR  pricing_attribute_name_cur(a_context_code VARCHAR2, a_segment_name VARCHAR2)
IS
  SELECT a.segment_mapping_column
  FROM   qp_segments_v a, qp_prc_contexts_b b
  WHERE  b.prc_context_id = a.prc_context_id
  AND    b.prc_context_code = a_context_code
  AND    a.segment_code = a_segment_name
  AND    a.segment_mapping_column like 'PRICING%';--deliberately matching a_segment_name
                                         --with segment_code to be consistent
                                         --with old logic/naming convention.

CURSOR  qual_attribute_name_cur(a_context_code VARCHAR2, a_segment_name VARCHAR2)
IS
  SELECT a.segment_mapping_column
  FROM   qp_segments_v a, qp_prc_contexts_b b
  WHERE  b.prc_context_id = a.prc_context_id
  AND    b.prc_context_code = a_context_code
  AND    a.segment_code = a_segment_name
  AND    a.segment_mapping_column like 'QUALIFIER%';--deliberately matching a_segment_name
                                         --with segment_code to be consistent
                                         --with old logic/naming convention.

l_attribute_col_name  VARCHAR2(30);

BEGIN

  IF Attrmgr_Installed = 'Y' THEN

    IF p_flexfield_name = 'QP_ATTR_DEFNS_PRICING' THEN

       OPEN  pricing_attribute_name_cur(p_context_name, p_attribute_name);
       FETCH pricing_attribute_name_cur INTO l_attribute_col_name;
       IF pricing_attribute_name_cur%FOUND THEN
          CLOSE pricing_attribute_name_cur;
          RETURN l_attribute_col_name;
       END IF;

       CLOSE pricing_attribute_name_cur;

    ELSE

       OPEN  qual_attribute_name_cur(p_context_name, p_attribute_name);
       FETCH qual_attribute_name_cur INTO l_attribute_col_name;
       IF qual_attribute_name_cur%FOUND THEN
          CLOSE qual_attribute_name_cur;
          RETURN l_attribute_col_name;
       END IF;

       CLOSE qual_attribute_name_cur;

    END IF;

  ELSE

    OPEN  cur_get_application_id(p_application_short_name);
    FETCH cur_get_application_id INTO v_dflex_r.application_id;
    CLOSE cur_get_application_id;

    v_dflex_r.flexfield_name := p_flexfield_name;
    v_context_r.flexfield := v_dflex_r;
    v_context_r.context_code := p_context_name;

    -- get the enabled segments for the context selected.
    fnd_dflex.get_segments(v_context_r,v_segments_dr,TRUE);

    IF (v_segments_dr.nsegments > 0) THEN

      FOR i IN 1..v_segments_dr.nsegments LOOP

        IF (v_segments_dr.segment_name(I) = p_attribute_name) THEN

          RETURN (v_segments_dr.application_column_name(i));

        END IF;

      END LOOP;

    ELSE

      RETURN('0');

    END IF;

  END IF; --if Attrmgr_Installed = 'Y'

  RETURN NULL;

END Get_Attribute_Name;



FUNCTION check_context_existance(  p_application_id             IN fnd_application.application_id%TYPE,
	                              p_descriptive_flexfield_name IN VARCHAR2,
					          p_descr_flex_context_code    IN VARCHAR2)
RETURN BOOLEAN

IS

 dummy NUMBER(1);
 x_context_exists BOOLEAN := TRUE;

BEGIN
 SELECT NULL INTO dummy
 FROM fnd_descr_flex_contexts
 WHERE application_id = p_application_id
 AND descriptive_flexfield_name = p_descriptive_flexfield_name
 AND descriptive_flex_context_code = p_descr_flex_context_code;

 --dbms_output.put_line ('Context Check Successful');
 return x_context_exists;

EXCEPTION
 WHEN no_data_found THEN
  x_context_exists := FALSE;
  return x_context_exists;
 WHEN OTHERS THEN
  NULL;
  --dbms_output.put_line ('Error in Context Check');
END;

FUNCTION check_segment_existance( p_application_id NUMBER,
						    p_context_code VARCHAR2,
					         p_flexfield_name VARCHAR2,
					         p_application_column_name VARCHAR2)
RETURN BOOLEAN
IS

 dummy NUMBER(1);
 x_seg_exists BOOLEAN := TRUE;

BEGIN
 select NULL INTO dummy
 from FND_DESCR_FLEX_COLUMN_USAGES
 where APPLICATION_ID = p_application_id
 and DESCRIPTIVE_FLEX_CONTEXT_CODE = p_context_code
 and DESCRIPTIVE_FLEXFIELD_NAME = p_flexfield_name
 and APPLICATION_COLUMN_NAME = p_application_column_name;

 --dbms_output.put_line ('Segment Check Successful');
 return x_seg_exists ;

EXCEPTION
 WHEN no_data_found THEN
  x_seg_exists := FALSE;
  return x_seg_exists;
 WHEN OTHERS THEN
  NULL;
  --dbms_output.put_line ('Error in Segment Check');
END;

FUNCTION check_segment_name_existance( p_application_id NUMBER,
						         p_context_code VARCHAR2,
					              p_flexfield_name VARCHAR2,
					              p_segment_name VARCHAR2)
RETURN BOOLEAN
IS

 dummy NUMBER(1);
 x_seg_exists BOOLEAN := TRUE;

BEGIN
 select NULL INTO dummy
 from FND_DESCR_FLEX_COLUMN_USAGES
 where APPLICATION_ID = p_application_id
 and DESCRIPTIVE_FLEX_CONTEXT_CODE = p_context_code
 and DESCRIPTIVE_FLEXFIELD_NAME = p_flexfield_name
 and END_USER_COLUMN_NAME = p_segment_name;

 --dbms_output.put_line ('Segment Name Check Successful');
 return x_seg_exists ;

EXCEPTION
 WHEN no_data_found THEN
  x_seg_exists := FALSE;
  return x_seg_exists;
 WHEN OTHERS THEN
  NULL;
  --dbms_output.put_line ('Error in Segment Name Check');
END;

PROCEDURE QP_UPGRADE_CONTEXT(   P_PRODUCT            IN VARCHAR2
						, P_NEW_PRODUCT        IN VARCHAR2
						, P_FLEXFIELD_NAME     IN VARCHAR2
						, P_NEW_FLEXFIELD_NAME IN VARCHAR2)
IS
	   P_FLEXFIELD FND_DFLEX.DFLEX_R;
	   P_FLEXINFO  FND_DFLEX.DFLEX_DR;
	   L_CONTEXTS FND_DFLEX.CONTEXTS_DR;
	   GDE_CONTEXTS FND_DFLEX.CONTEXTS_DR;
	   L_SEGMENTS FND_DFLEX.SEGMENTS_DR;
	   GDE_SEGMENTS FND_DFLEX.SEGMENTS_DR;
	   NEW_GDE_SEGMENTS FND_DFLEX.SEGMENTS_DR;
	   L_REQUIRED VARCHAR2(5);
	   L_SECURITY_ENABLED VARCHAR2(5);

	   L_VALUE_SET_ID NUMBER := 0;
	   L_VALUE_SET VARCHAR2(100) := NULL;
	   L_SEGMENT_COUNT NUMBER;
	   p_segment_name  VARCHAR2(240);
	   NEW_GDE_CONTEXT_CODE CONSTANT VARCHAR2(30) := 'Upgrade Context';
	   OLD_GDE_CONTEXT_CODE CONSTANT VARCHAR2(30) := 'Global Data Elements';
	   G_QP_ATTR_DEFNS_PRICING CONSTANT VARCHAR2(30) := 'QP_ATTR_DEFNS_PRICING';
	   QP_APPLICATION_ID    CONSTANT fnd_application.application_id%TYPE := 661;
	   p_context_name  VARCHAR2(240);
	   p_application_column_name  VARCHAR2(240);
	   p_application_id	VARCHAR2(30);
BEGIN

      FND_FLEX_DSC_API.SET_SESSION_MODE('customer_data');

      FND_PROFILE.PUT('RESP_APPL_ID','0');
      FND_PROFILE.PUT('RESP_ID','20419');
      FND_PROFILE.PUT('USER_ID','1001');

     -- Delete all the segments under the New Global Data Elements Context(if any)

	 --dbms_output.put_line ('Before even starting the process');
  IF ( FND_FLEX_DSC_API.FLEXFIELD_EXISTS( P_NEW_PRODUCT,
								  P_NEW_FLEXFIELD_NAME )) THEN
	 --dbms_output.put_line ('Entered the Processing');
   IF (P_NEW_FLEXFIELD_NAME = G_QP_ATTR_DEFNS_PRICING) THEN
     -- Get the New Global Data Elements Context and Its Segments
	FND_DFLEX.GET_FLEXFIELD( P_NEW_PRODUCT
					, P_NEW_FLEXFIELD_NAME
					, P_FLEXFIELD
					, P_FLEXINFO );

     -- Get all contexts for the flexfield
	FND_DFLEX.GET_CONTEXTS( P_FLEXFIELD, L_CONTEXTS );

	-- Get the Context Code for New Global Data Elements Context (if any)
	FOR I IN 1..L_CONTEXTS.NCONTEXTS LOOP
	 --dbms_output.put_line ('Found the Old GDE Context');
	 IF (L_CONTEXTS.CONTEXT_CODE(I) = OLD_GDE_CONTEXT_CODE) THEN
       FND_DFLEX.GET_SEGMENTS ( FND_DFLEX.MAKE_CONTEXT( P_FLEXFIELD , OLD_GDE_CONTEXT_CODE)
				          ,NEW_GDE_SEGMENTS
				          , FALSE ) ;
	 END IF;
	 EXIT;
     END LOOP;

    IF (NEW_GDE_SEGMENTS.NSEGMENTS > 0) THEN
	--dbms_output.put_line('New GDE has segments');
     FOR I IN 1..NEW_GDE_SEGMENTS.NSEGMENTS LOOP
	 --dbms_output.put_line('Trying to delete segments under old context');
      FND_FLEX_DSC_API.DELETE_SEGMENT( P_NEW_PRODUCT
							 ,P_NEW_FLEXFIELD_NAME
							 ,OLD_GDE_CONTEXT_CODE -- Global Data Elements
							 ,NEW_GDE_SEGMENTS.SEGMENT_NAME(I));
     END LOOP;
    ELSE
	NULL;
	--dbms_output.put_line('New GDE has no segments');
    END IF; -- NEW_GDE_SEGMENTS.NSEGMENTS > 0
   END IF;
  END IF;

	--dbms_output.put_line('Starting the actual Migration');
    -- Now start the migration of contexts and segments
    FND_DFLEX.GET_FLEXFIELD(
					  P_PRODUCT
					, P_FLEXFIELD_NAME
					, P_FLEXFIELD
					, P_FLEXINFO );

    FND_DFLEX.GET_CONTEXTS( P_FLEXFIELD, L_CONTEXTS );

    -- Store all the old contexts
    GDE_CONTEXTS := L_CONTEXTS;

  -- Check To See If New Flex Structure Exists
  IF ( FND_FLEX_DSC_API.FLEXFIELD_EXISTS( P_NEW_PRODUCT,
								  P_NEW_FLEXFIELD_NAME )) THEN
     FOR I IN 1..L_CONTEXTS.NCONTEXTS LOOP
	 --dbms_output.put_line ( ' Global Code : ' || L_CONTEXTS.CONTEXT_CODE(I));
	 IF (L_CONTEXTS.CONTEXT_CODE(I) = OLD_GDE_CONTEXT_CODE AND P_NEW_FLEXFIELD_NAME = G_QP_ATTR_DEFNS_PRICING) THEN
	     --dbms_output.put_line('There are contexts for migration');
		IF (check_context_existance(QP_APPLICATION_ID,P_NEW_FLEXFIELD_NAME,NEW_GDE_CONTEXT_CODE) = FALSE) THEN
		 --dbms_output.put_line ('Creating the Upgrade Context');
            FND_FLEX_DSC_API.CREATE_CONTEXT ( P_NEW_PRODUCT
								   , P_NEW_FLEXFIELD_NAME
								   , NEW_GDE_CONTEXT_CODE
								   , NEW_GDE_CONTEXT_CODE
								   , NEW_GDE_CONTEXT_CODE
								   , 'Y'
								   , 'N') ;
		 --dbms_output.put_line ('Created the Upgrade Context');
		ELSE
		 NULL;
		 --dbms_output.put_line ('Upgrade Context Already Exists');
		END IF;

	     FND_FLEX_DSC_API.ENABLE_CONTEXT (P_NEW_PRODUCT
								,  P_NEW_FLEXFIELD_NAME
								,  NEW_GDE_CONTEXT_CODE
								,  TRUE );

		FND_FLEX_DSC_API.ENABLE_COLUMNS( P_NEW_PRODUCT
								,  P_NEW_FLEXFIELD_NAME
								, 'ATTRIBUTE[0-9]+');

		FND_DFLEX.GET_SEGMENTS ( FND_DFLEX.MAKE_CONTEXT( P_FLEXFIELD , L_CONTEXTS.CONTEXT_CODE(I))
					          ,L_SEGMENTS
					          , FALSE ) ;


	     -- Store all the old global data elements' segments
		GDE_SEGMENTS := L_SEGMENTS;

          --dbms_output.put_line ( 'Old GDE Segments Count##: ' || nvl(GDE_SEGMENTS.NSEGMENTS,0));

		FOR J IN 1..L_SEGMENTS.NSEGMENTS LOOP
		   L_VALUE_SET_ID := L_SEGMENTS.VALUE_SET(J);
		 BEGIN
		  IF L_VALUE_SET_ID <> 0 THEN
			SELECT FLEX_VALUE_SET_NAME INTO
			L_VALUE_SET
			FROM FND_FLEX_VALUE_SETS
			WHERE FLEX_VALUE_SET_ID = L_VALUE_SET_ID;
		  ELSE
			L_VALUE_SET := NULL;
		  END IF;
		 EXCEPTION
			WHEN NO_DATA_FOUND THEN
			   L_VALUE_SET := NULL;
			WHEN TOO_MANY_ROWS THEN
			  NULL;
		 END;

		 IF (L_SEGMENTS.IS_REQUIRED(J) ) THEN
			L_REQUIRED := 'Y';
	      ELSE
			L_REQUIRED := 'N';
	      END IF;

		 IF (L_SEGMENTS.IS_ENABLED(J) ) THEN
			L_SECURITY_ENABLED := 'Y';
	      ELSE
			L_SECURITY_ENABLED := 'N';
	      END IF;


		 IF (check_segment_existance(QP_APPLICATION_ID,
							    NEW_GDE_CONTEXT_CODE,
						         P_NEW_FLEXFIELD_NAME,
						         L_SEGMENTS.APPLICATION_COLUMN_NAME(J)) = FALSE ) THEN
		  IF (check_segment_name_existance(QP_APPLICATION_ID,
							    NEW_GDE_CONTEXT_CODE,
						         P_NEW_FLEXFIELD_NAME,
						         L_SEGMENTS.SEGMENT_NAME(J)) = FALSE ) THEN
			p_segment_name := L_SEGMENTS.SEGMENT_NAME(J);
		  ELSE
			p_segment_name := 'QP: ' || L_SEGMENTS.SEGMENT_NAME(J); -- Create new name
		  END IF;

		   -- Storing the values for error handling
             p_context_name := NEW_GDE_CONTEXT_CODE;
		   p_application_column_name := L_SEGMENTS.APPLICATION_COLUMN_NAME(J);
		   p_application_id := QP_APPLICATION_ID;

		   --dbms_output.put_line ('Creating the Upgrade Context Segments');
		   BEGIN
		    FND_FLEX_DSC_API.CREATE_SEGMENT (
		       APPL_SHORT_NAME => P_NEW_PRODUCT
		   ,   FLEXFIELD_NAME => P_NEW_FLEXFIELD_NAME
	        ,   CONTEXT_NAME   => NEW_GDE_CONTEXT_CODE
	        ,   NAME 		  => p_segment_name
		   ,   COLUMN         => L_SEGMENTS.APPLICATION_COLUMN_NAME(J)
		   ,   DESCRIPTION    => L_SEGMENTS.DESCRIPTION(J)
		   ,   SEQUENCE_NUMBER => J
		   ,   ENABLED		  => 'Y'
		   ,   DISPLAYED      => 'Y'
		   ,   VALUE_SET 	  => L_VALUE_SET
		   ,   DEFAULT_TYPE	  => NULL
		   ,   DEFAULT_VALUE  => NULL
		   ,   REQUIRED       =>  'Y'
		   ,   SECURITY_ENABLED => 'N'
		   ,   DISPLAY_SIZE    => L_SEGMENTS.DISPLAY_SIZE(J)
		   ,   DESCRIPTION_SIZE => L_SEGMENTS.DISPLAY_SIZE(J)
		   ,   CONCATENATED_DESCRIPTION_SIZE => L_SEGMENTS.DISPLAY_SIZE(J)
		   ,   LIST_OF_VALUES_PROMPT => L_SEGMENTS.COLUMN_PROMPT(J)
		   ,   WINDOW_PROMPT   => L_SEGMENTS.ROW_PROMPT(J)
		   ,   RANGE 		   =>  NULL
		   ,   SRW_PARAMETER   => NULL) ;
		   EXCEPTION
		    WHEN NO_DATA_FOUND THEN
			rollback;
               Log_Error(p_id1 => -9999,
		               p_error_type => 'ERROR IN CREATING SEGMENT',
		               p_error_desc => ' Application Id : '     || p_application_id ||
						           ' Old Flexfield Name : ' || P_FLEXFIELD_NAME ||
						           ' New Flexfield Name : ' || P_NEW_FLEXFIELD_NAME ||
						           ' Context Name : '       || p_context_name ||
						           ' Application Column Name : ' || p_application_column_name ||
						           ' Application Segment Name : ' || p_segment_name ,
		               p_error_module => 'QP_Upgrade_Context');
			raise;
		   END;
		 END IF;
	     END LOOP; -- L_SEGMENTS
	     --EXIT;
      END IF; -- Global Data Elements
	END LOOP; -- L_CONTEXTS

       --dbms_output.put_line('Total Context Count: ' || L_CONTEXTS.NCONTEXTS);
    -- Process other contexts(other than Global Data Elements)
    FOR I IN 1..L_CONTEXTS.NCONTEXTS LOOP
	 IF ((L_CONTEXTS.CONTEXT_CODE(I) <>  OLD_GDE_CONTEXT_CODE AND P_NEW_FLEXFIELD_NAME = G_QP_ATTR_DEFNS_PRICING)
		 OR (P_NEW_FLEXFIELD_NAME <> G_QP_ATTR_DEFNS_PRICING)) THEN
		  --dbms_output.put_line ('Before Other Context Existance Check');
		  --dbms_output.put_line ('Context Code : ' || L_CONTEXTS.CONTEXT_CODE(I));
	    IF (check_context_existance(QP_APPLICATION_ID,P_NEW_FLEXFIELD_NAME,L_CONTEXTS.CONTEXT_CODE(I)) = FALSE) THEN
		  --dbms_output.put_line ('Creating Other Contexts');
            FND_FLEX_DSC_API.CREATE_CONTEXT ( P_NEW_PRODUCT
								   , P_NEW_FLEXFIELD_NAME
								   , L_CONTEXTS.CONTEXT_CODE(I)
								   , L_CONTEXTS.CONTEXT_NAME(I)
								   , L_CONTEXTS.CONTEXT_DESCRIPTION(I)
								   , 'Y'
								   , 'N') ;

		END IF;

	     FND_FLEX_DSC_API.ENABLE_CONTEXT ( P_NEW_PRODUCT
						, P_NEW_FLEXFIELD_NAME
						, L_CONTEXTS.CONTEXT_CODE(I)         --2847218 changed to CONTEXT_CODE
						, TRUE );

		FND_FLEX_DSC_API.ENABLE_COLUMNS(P_NEW_PRODUCT
								, P_NEW_FLEXFIELD_NAME
								, 'ATTRIBUTE[0-9]+');

		FND_DFLEX.GET_SEGMENTS ( FND_DFLEX.MAKE_CONTEXT( P_FLEXFIELD , L_CONTEXTS.CONTEXT_CODE(I))
					          ,L_SEGMENTS
					          , FALSE ) ;

          L_SEGMENT_COUNT := L_SEGMENTS.NSEGMENTS;
		--dbms_output.put_line ('Other Context Segment Count : ' || L_SEGMENT_COUNT);

		FOR J IN 1..L_SEGMENTS.NSEGMENTS LOOP
		  L_VALUE_SET_ID := L_SEGMENTS.VALUE_SET(J);
		 BEGIN
		  IF L_VALUE_SET_ID <> 0 THEN
			SELECT FLEX_VALUE_SET_NAME INTO
			L_VALUE_SET
			FROM FND_FLEX_VALUE_SETS
			WHERE FLEX_VALUE_SET_ID = L_VALUE_SET_ID;
		  ELSE
			L_VALUE_SET := NULL;
		  END IF;
		 EXCEPTION
			WHEN NO_DATA_FOUND THEN
			   L_VALUE_SET := NULL;
			WHEN TOO_MANY_ROWS THEN
			  NULL;
		 END;

		 IF (L_SEGMENTS.IS_REQUIRED(J) ) THEN
			L_REQUIRED := 'Y';
	      ELSE
			L_REQUIRED := 'N';
	      END IF;

		 IF (L_SEGMENTS.IS_ENABLED(J) ) THEN
			L_SECURITY_ENABLED := 'Y';
	      ELSE
			L_SECURITY_ENABLED := 'N';
	      END IF;

		--dbms_output.put_line ('Before Other Context Segment Existance Check');
		--dbms_output.put_line ('Before Segment Existance Check for Old Gde Segments');
		--dbms_output.put_line ('Flexfield Name : ' || P_NEW_FLEXFIELD_NAME);
		--dbms_output.put_line ('Context Code : ' || L_CONTEXTS.CONTEXT_CODE(I));
		--dbms_output.put_line ('Application Column Name : ' || L_SEGMENTS.APPLICATION_COLUMN_NAME(J));
		 IF (check_segment_existance(QP_APPLICATION_ID,
							    L_CONTEXTS.CONTEXT_CODE(I),
						         P_NEW_FLEXFIELD_NAME,
						         L_SEGMENTS.APPLICATION_COLUMN_NAME(J)) = FALSE ) THEN
		  --dbms_output.put_line ('Segment check false');
		  IF (check_segment_name_existance(QP_APPLICATION_ID,
							    NEW_GDE_CONTEXT_CODE,
						         P_NEW_FLEXFIELD_NAME,
						         L_SEGMENTS.SEGMENT_NAME(J)) = FALSE ) THEN
		     --dbms_output.put_line ('Segment name check false');
			p_segment_name := L_SEGMENTS.SEGMENT_NAME(J);
		  ELSE
			p_segment_name := 'QP: ' || L_SEGMENTS.SEGMENT_NAME(J);
		  END IF;

		   -- Storing the values for error handling
             p_context_name := L_CONTEXTS.CONTEXT_CODE(I);
		   p_application_column_name := L_SEGMENTS.APPLICATION_COLUMN_NAME(J);
		   p_application_id := QP_APPLICATION_ID;

		   --dbms_output.put_line ('Creating Other Contexts Segments ');
		   BEGIN
		    FND_FLEX_DSC_API.CREATE_SEGMENT (
		      APPL_SHORT_NAME => P_NEW_PRODUCT
		  ,   FLEXFIELD_NAME => P_NEW_FLEXFIELD_NAME
	       ,   CONTEXT_NAME   => L_CONTEXTS.CONTEXT_CODE(I)		--2847218 changed to CONTEXT_CODE
	       ,   NAME 		 => p_segment_name
		  ,   COLUMN         => L_SEGMENTS.APPLICATION_COLUMN_NAME(J)
		  ,   DESCRIPTION    => L_SEGMENTS.DESCRIPTION(J)
		  ,   SEQUENCE_NUMBER => J
		  ,   ENABLED		=> 'Y'
		  ,   DISPLAYED     => 'Y'
		  ,   VALUE_SET 	=> L_VALUE_SET
		  ,   DEFAULT_TYPE	=> NULL
		  ,   DEFAULT_VALUE => NULL
		  ,   REQUIRED      =>  'Y'
		  ,   SECURITY_ENABLED => 'N'
		  ,   DISPLAY_SIZE    => L_SEGMENTS.DISPLAY_SIZE(J)
		  ,   DESCRIPTION_SIZE => L_SEGMENTS.DISPLAY_SIZE(J)
		  ,   CONCATENATED_DESCRIPTION_SIZE => L_SEGMENTS.DISPLAY_SIZE(J)
		  ,   LIST_OF_VALUES_PROMPT => L_SEGMENTS.COLUMN_PROMPT(J)
		  ,   WINDOW_PROMPT => L_SEGMENTS.ROW_PROMPT(J)
		  ,   RANGE 		=>  NULL
		  ,   SRW_PARAMETER	=> NULL) ;
		   EXCEPTION
		    WHEN NO_DATA_FOUND THEN
			rollback;
               Log_Error(p_id1 => -9999,
		               p_error_type => 'ERROR IN CREATING SEGMENT',
		               p_error_desc => ' Application Id : '     || p_application_id ||
						           ' Old Flexfield Name : ' || P_FLEXFIELD_NAME ||
						           ' New Flexfield Name : ' || P_NEW_FLEXFIELD_NAME ||
						           ' Context Name : '       || p_context_name ||
						           ' Application Column Name : ' || p_application_column_name ||
						           ' Application Segment Name : ' || p_segment_name ,
		               p_error_module => 'QP_Upgrade_Context');
			raise;
		   END ;
		END IF;
         END LOOP; -- L_SEGMENTS

	     -- Append all the global data segments into other contexts
		--dbms_output.put_line ('Old GDE SEGMENTS Count : ' || nvl(GDE_SEGMENTS.NSEGMENTS,0));
	    IF (nvl(GDE_SEGMENTS.NSEGMENTS,0) > 0) THEN
		FOR K IN 1..GDE_SEGMENTS.NSEGMENTS LOOP
		 L_VALUE_SET_ID := GDE_SEGMENTS.VALUE_SET(K);
		BEGIN
		 IF L_VALUE_SET_ID <> 0 THEN
			SELECT FLEX_VALUE_SET_NAME INTO
			L_VALUE_SET
			FROM FND_FLEX_VALUE_SETS
			WHERE FLEX_VALUE_SET_ID = L_VALUE_SET_ID;
		 ELSE
			L_VALUE_SET := NULL;
		 END IF;
		EXCEPTION
			WHEN NO_DATA_FOUND THEN
			   L_VALUE_SET := NULL;
			WHEN TOO_MANY_ROWS THEN
			  NULL;
		END;

		--dbms_output.put_line ('GDE SEGMENTS Loop 1');
		IF (GDE_SEGMENTS.IS_REQUIRED(K) ) THEN
			L_REQUIRED := 'Y';
	     ELSE
			L_REQUIRED := 'N';
	     END IF;

		IF (GDE_SEGMENTS.IS_ENABLED(K) ) THEN
			L_SECURITY_ENABLED := 'Y';
	     ELSE
			L_SECURITY_ENABLED := 'N';
	     END IF;

		--dbms_output.put_line ('Before Segment Existance Check for Old Gde Segments');
		--dbms_output.put_line ('Flexfield Name : ' || P_NEW_FLEXFIELD_NAME);
		--dbms_output.put_line ('Context Code : ' || L_CONTEXTS.CONTEXT_CODE(I));
		--dbms_output.put_line ('Application Column Name : ' || GDE_SEGMENTS.APPLICATION_COLUMN_NAME(K));
		 IF (check_segment_existance(QP_APPLICATION_ID,
							    L_CONTEXTS.CONTEXT_CODE(I),
						         P_NEW_FLEXFIELD_NAME,
						         GDE_SEGMENTS.APPLICATION_COLUMN_NAME(K)) = FALSE ) THEN
		  --dbms_output.put_line ('Segment check false');
		  IF (check_segment_name_existance(QP_APPLICATION_ID,
							    L_CONTEXTS.CONTEXT_CODE(I),
						         P_NEW_FLEXFIELD_NAME,
						         GDE_SEGMENTS.SEGMENT_NAME(K)) = FALSE ) THEN
		     --dbms_output.put_line ('Segment name check false');
			p_segment_name := GDE_SEGMENTS.SEGMENT_NAME(K);
		  ELSE
			p_segment_name := 'QP: ' || GDE_SEGMENTS.SEGMENT_NAME(K);
		  END IF;

		   -- Storing the values for error handling
             p_context_name := L_CONTEXTS.CONTEXT_CODE(I);
		   p_application_column_name := GDE_SEGMENTS.APPLICATION_COLUMN_NAME(K);
		   p_application_id := QP_APPLICATION_ID;

		   --dbms_output.put_line ('Creating the OLD Gde segments to all contexts');
		   BEGIN
		    FND_FLEX_DSC_API.CREATE_SEGMENT (
		    APPL_SHORT_NAME => P_NEW_PRODUCT
		  ,   FLEXFIELD_NAME =>P_NEW_FLEXFIELD_NAME
	       ,   CONTEXT_NAME  => L_CONTEXTS.CONTEXT_CODE(I)		--2847218 changed to CONTEXT_CODE
	       ,   NAME 	     => p_segment_name
		  ,   COLUMN        => GDE_SEGMENTS.APPLICATION_COLUMN_NAME(K)
		  ,   DESCRIPTION   => GDE_SEGMENTS.DESCRIPTION(K)
		  ,   SEQUENCE_NUMBER => L_SEGMENT_COUNT + K
		  ,   ENABLED		=> 'Y'
		  ,   DISPLAYED     => 'Y'
		  ,   VALUE_SET 	=> L_VALUE_SET
		  ,   DEFAULT_TYPE	=> NULL
		  ,   DEFAULT_VALUE => NULL
		  ,   REQUIRED      =>  'Y'
		  ,   SECURITY_ENABLED => 'N'
		  ,   DISPLAY_SIZE    => GDE_SEGMENTS.DISPLAY_SIZE(K)
		  ,   DESCRIPTION_SIZE => GDE_SEGMENTS.DISPLAY_SIZE(K)
		  ,   CONCATENATED_DESCRIPTION_SIZE => GDE_SEGMENTS.DISPLAY_SIZE(K)
		  ,   LIST_OF_VALUES_PROMPT => GDE_SEGMENTS.COLUMN_PROMPT(K)
		  ,   WINDOW_PROMPT => GDE_SEGMENTS.ROW_PROMPT(K)
		  ,   RANGE 		=>  NULL
		  ,   SRW_PARAMETER	=> NULL) ;
		   EXCEPTION
		    WHEN NO_DATA_FOUND THEN
			rollback;
               Log_Error(p_id1 => -9999,
		               p_error_type => 'ERROR IN CREATING SEGMENT',
		               p_error_desc => ' Application Id : '     || p_application_id ||
						           ' Old Flexfield Name : ' || P_FLEXFIELD_NAME ||
						           ' New Flexfield Name : ' || P_NEW_FLEXFIELD_NAME ||
						           ' Context Name : '       || p_context_name ||
						           ' Application Column Name : ' || p_application_column_name ||
						           ' Application Segment Name : ' || p_segment_name ,
		               p_error_module => 'QP_Upgrade_Context');
			raise;
		   END ;
		END IF;
	    END LOOP; -- GDE_SEGMENTS
        END IF; -- GDE_SEGMENTS.NSEGMENTS > 0
	 END IF;   -- Global Data Elements
    END LOOP;   -- CONTEXTS
 END IF;  /* CHECK FOR NEW FLEX FIELD STRUCTURE EXISTS */
EXCEPTION
	WHEN OTHERS THEN
	  --dbms_output.put_line(fnd_flex_dsc_api.message);
       rollback;
       Log_Error(p_id1 => -6501,
		    p_error_type => 'FLEXFIELD UPGRADE',
		    p_error_desc => fnd_flex_dsc_api.message,
		    p_error_module => 'QP_Upgrade_Context');
    raise;
END QP_UPGRADE_CONTEXT;

PROCEDURE LOG_ERROR( P_ID1            VARCHAR2,
				   P_ID2			VARCHAR2  :=NULL,
				   P_ID3			VARCHAR2  :=NULL,
				   P_ID4			VARCHAR2  :=NULL,
				   P_ID5			VARCHAR2  :=NULL,
				   P_ID6			VARCHAR2  :=NULL,
				   P_ID7			VARCHAR2  :=NULL,
				   P_ID8			VARCHAR2  :=NULL,
				   P_ERROR_TYPE	VARCHAR2,
				   P_ERROR_DESC	VARCHAR2,
				   P_ERROR_MODULE	VARCHAR2) AS

  PRAGMA  AUTONOMOUS_TRANSACTION;

  BEGIN

    INSERT INTO QP_UPGRADE_ERRORS(ERROR_ID,UPG_SESSION_ID,ID1,ID2,ID3,ID4,ID5,ID6,ID7,ID8,ERROR_TYPE,
						    ERROR_DESC,ERROR_MODULE,CREATION_DATE,CREATED_BY,LAST_UPDATE_DATE,
						    LAST_UPDATED_BY,LAST_UPDATE_LOGIN) VALUES
						    (QP_UPGRADE_ERRORS_S.NEXTVAL,USERENV('SESSIONID'),
						    P_ID1,P_ID2,P_ID3,P_ID4,P_ID5,P_ID6,P_ID7,P_ID8,
						    P_ERROR_TYPE, SUBSTR(P_ERROR_DESC,1,240),P_ERROR_MODULE,SYSDATE,
						    FND_GLOBAL.USER_ID,SYSDATE,FND_GLOBAL.USER_ID,FND_GLOBAL.LOGIN_ID);
    COMMIT;

  END;


 PROCEDURE get_segs_for_flex(    flexfield_name         IN     VARCHAR2,
                                 application_short_name IN     VARCHAR2,
	                         x_segs_upg_t OUT  NOCOPY v_segs_upg_tab,
                                 error_code   OUT  NOCOPY number) IS

    CURSOR Cur_get_application_id(app_short_name VARCHAR2) IS
      SELECT application_id
      FROM   fnd_application
      WHERE  application_short_name = app_short_name;

    v_context_dr     fnd_dflex.contexts_dr;
    v_dflex_r        fnd_dflex.dflex_r;
    v_context_r      fnd_dflex.context_r;
    v_segments_dr    fnd_dflex.segments_dr;
    v_value_set_id   NUMBER;
    v_precedence     NUMBER;
    v_valueset_r     fnd_vset.valueset_r;
    v_format_dr      fnd_vset.valueset_dr;
    v_valueset_dr    fnd_vset.valueset_dr;
    v_dflex_dr       fnd_dflex.dflex_dr;
    v_flexfield_val_ind NUMBER DEFAULT 0;
    J NUMBER := 0;

  BEGIN

    error_code := 0;

    IF (flexfield_name IS NULL) THEN
      error_code := 1;  -- flexfield_name is not passed.
      RETURN;
    END IF;

    IF (application_short_name IS NULL) THEN
      error_code := 5;  -- application short name is not passed
      RETURN;
    END IF;

    -- Get the application_id

    OPEN Cur_get_application_id(application_short_name);
    FETCH Cur_get_application_id INTO v_dflex_r.application_id;
    IF (Cur_get_application_id%NOTFOUND) THEN
      CLOSE Cur_get_application_id;
      error_code := 6;  -- Invalid application short name.
      RETURN;
    END IF;
    CLOSE Cur_get_application_id;

     -- check if flexfield name passed is a valid one or not.
     v_flexfield_val_ind:= 1;
     fnd_dflex.get_flexfield(application_short_name,flexfield_name,v_dflex_r,v_dflex_dr);

     -- Get the context listing for the flexfield
     fnd_dflex.get_contexts(v_dflex_r,v_context_dr);

  For i in 1..v_context_dr.ncontexts LOOP

   --dbms_output.put_line('context code -1 is : ' || v_context_dr.context_code(i));

     v_context_r.context_code := v_context_dr.context_code(i);
     v_context_r.flexfield := v_dflex_r;



     fnd_dflex.get_segments(v_context_r,v_segments_dr);

     FOR K IN 1..v_segments_dr.nsegments LOOP

        J := J + 1;

        x_segs_upg_t(J).context_code := v_context_dr.context_code(i);
        x_segs_upg_t(J).segment_name := v_segments_dr.application_column_name(K);

    -- Get value set information and validate the value passed.


     IF v_segments_dr.value_set(K) is null then

       x_segs_upg_t(J).datatype := 'C';

     ELSE

       fnd_vset.get_valueset(v_segments_dr.value_set(K),v_valueset_r,v_valueset_dr);
        x_segs_upg_t(J).datatype := v_valueset_dr.format_type;

     END IF;

        x_segs_upg_t(J).sequence := v_segments_dr.sequence(K);


     END LOOP;

  End Loop;

  error_code := 0;

  EXCEPTION

    WHEN NO_DATA_FOUND THEN
      IF (v_flexfield_val_ind = 1) THEN
        error_code := 10;
        RETURN;
      END IF;

END get_segs_for_flex;

PROCEDURE get_segs_flex_precedence(p_segs_upg_t  IN  v_segs_upg_tab,
                                   p_context     IN  VARCHAR2,
                                   p_attribute   IN  VARCHAR2,
                                   x_precedence  OUT NOCOPY NUMBER,
                                   x_datatype    OUT NOCOPY VARCHAR2)
IS


 v_segs_upg_ind number := 0;

BEGIN

  x_datatype := 'C';
  x_precedence := 5000;
  v_segs_upg_ind := p_segs_upg_t.FIRST;

  while v_segs_upg_ind is not null loop

     IF (    ( p_segs_upg_t(v_segs_upg_ind).context_code = p_context   )
         AND ( p_segs_upg_t(v_segs_upg_ind).segment_name = p_attribute )
        ) THEN

       x_precedence := p_segs_upg_t(v_segs_upg_ind).sequence;
       x_datatype := p_segs_upg_t(v_segs_upg_ind).datatype;
       RETURN;

     END IF;

     v_segs_upg_ind := p_segs_upg_t.NEXT(v_segs_upg_ind);

  end loop;

END get_segs_flex_precedence;

FUNCTION GET_NUM_DATE_FROM_CANONICAL(p_datatype IN VARCHAR2
					  ,p_value  IN VARCHAR2
                          )RETURN VARCHAR2 IS

l_varchar_out varchar2(2000);
INVALID_DATA_TYPE EXCEPTION;

 BEGIN

        IF p_datatype  = 'N' THEN

            l_varchar_out := to_char(qp_number.canonical_to_number(p_value));
        Elsif p_datatype = 'X' THEN
	       l_varchar_out :=
		  fnd_date.canonical_to_date(p_value);
        Elsif p_datatype = 'Y' THEN
	       l_varchar_out :=
		  fnd_date.canonical_to_date(p_value);
        Elsif p_datatype = 'C' THEN
	       l_varchar_out := p_value;
        ELse
	       l_varchar_out := p_value;

        END IF;

        RETURN l_varchar_out;

EXCEPTION
        When Others Then
	       l_varchar_out := p_value;
	       RETURN l_varchar_out;--smbalara 17230830

END GET_NUM_DATE_FROM_CANONICAL;

PROCEDURE GET_VALUESET_ID_R(P_FLEXFIELD_NAME IN VARCHAR2,
						P_CONTEXT IN  VARCHAR2 ,
                           P_SEG  IN  VARCHAR2 ,
	      				X_VSID  OUT NOCOPY NUMBER,
						X_FORMAT_TYPE  OUT NOCOPY VARCHAR2,
                           X_VALIDATION_TYPE OUT NOCOPY VARCHAR2
									 )IS

L_Valueset_R FND_VSET.VALUESET_R;
X_VALUESETID NUMBER;
L_valueset_dr FND_VSET.VALUESET_DR;

    CURSOR Cur_get_application_id(app_short_name VARCHAR2) IS
      SELECT application_id
      FROM   fnd_application
      WHERE  application_short_name = app_short_name;

   v_dflex_r      fnd_dflex.dflex_r;
   v_segments_dr  fnd_dflex.segments_dr;
   v_context_r    fnd_dflex.context_r;
  BEGIN
    OPEN Cur_get_application_id('QP');
    FETCH Cur_get_application_id INTO v_dflex_r.application_id;
    CLOSE Cur_get_application_id;
    v_dflex_r.flexfield_name := p_flexfield_name;
    v_context_r.flexfield := v_dflex_r;
    v_context_r.context_code := p_context;
     -- Get the enabled segments for the context selected.

    fnd_dflex.get_segments(v_context_r,v_segments_dr,TRUE);
   -- IF (v_segments_dr.nsegments > 0) THEN

FOR i IN 1..v_segments_dr.nsegments LOOP
        IF (v_segments_dr.application_column_name(i) = p_seg) THEN
    		X_VALUESETID := v_SEGMENTS_dr.VALUE_SET(i);
                exit;
	 END IF;
      END LOOP;

 IF X_VALUESETID IS NOT NULL THEN
	FND_VSET.GET_VALUESET(X_VALUESETID,l_valueset_r,l_valueset_dr);
 	X_VSID :=X_VALUESETID;
	X_FORMAT_TYPE :=l_valueset_dr.FORMAT_TYPE;
	X_VALIDATION_TYPE :=l_valueset_r.VALIDATION_TYPE;
 ELSE
	X_VSID :=NULL;
	X_FORMAT_TYPE :='C';
	X_VALIDATION_TYPE :=NULL;

 END IF;
end GET_VALUESET_ID_R;

FUNCTION Get_Attribute_Value_Meaning(p_FlexField_Name           IN VARCHAR2
                            ,p_Context_Name             IN VARCHAR2
			    ,p_segment_name             IN VARCHAR2
			    ,p_attr_value               IN VARCHAR2
			    ,p_comparison_operator_code IN VARCHAR2 := NULL
			  ) RETURN VARCHAR2 IS

  Vset  FND_VSET.valueset_r;
  Fmt   FND_VSET.valueset_dr;

  Found BOOLEAN;
  Row   NUMBER;
  Value FND_VSET.value_dr;



  x_Format_Type Varchar2(1);
  x_Validation_Type Varchar2(1);
  x_Vsid  NUMBER;


  x_attr_value_code     VARCHAR2(240);
  x_attr_meaning        VARCHAR2(1000);
  l_attr_value     VARCHAR2(2000);


  Value_Valid_In_Valueset BOOLEAN := FALSE;

  l_id	VARCHAR2(240);
  l_value VARCHAR2(240);
  l_meaning VARCHAR2(1000);

  BEGIN


	    qp_util.get_valueset_id(p_FlexField_Name,p_Context_Name,
	                             p_Segment_Name,x_Vsid,
                                 x_Format_Type, x_Validation_Type);


         l_attr_value := get_num_date_from_canonical(x_format_type,p_attr_value);

         -- if comparison operator is other than  then no need to get the
         -- meaning as the value itself will be stored in qualifier_attr_value

--change made by spgopal. added parameter called p_comparison_operator_code
--to generalise the code for all forms and packages

         If  p_comparison_operator_code <>  'BETWEEN'  THEN

             IF x_Validation_Type In('F' ,'I')  AND x_Vsid  IS NOT NULL THEN
                --dbms_output.put_line('valueset found');


				IF x_Validation_Type = 'I' THEN
                --dbms_output.put_line('validation type = I');

               		FND_VSET.get_valueset(x_Vsid,Vset,Fmt);
               		FND_VSET.get_value_init(Vset,TRUE);
               		FND_VSET.get_value(Vset,Row,Found,Value);


               		IF Fmt.Has_Id Then    --id is defined.Hence compare for id
                     		While(Found) Loop
                --dbms_output.put_line('ID is defined');


                        			If  l_attr_value  = Value.id  Then

	                       			x_attr_value_code  := Value.value;
                                                --dbms_output.put_line('1 x_attr_value_code = ' || x_attr_value_code);
                                                x_attr_meaning      := Value.meaning;
                                                --dbms_output.put_line('1 x_attr_meaning = ' || x_attr_meaning);
                            			Value_Valid_In_Valueset := TRUE;
                            			EXIT;
                        			End If;
                        			FND_VSET.get_value(Vset,Row,Found,Value);

                     		End Loop;

                		Else                 -- id not defined.Hence compare for value

                     		While(Found) Loop
                --dbms_output.put_line('ID is not defined');

                        			If  l_attr_value  = Value.value  Then

	                       			x_attr_value_code  := l_attr_value;
                                                --dbms_output.put_line('2 x_attr_value_code = ' || x_attr_value_code);
                                                x_attr_meaning      := Value.meaning;
                                                --dbms_output.put_line('2 x_attr_meaning = ' || x_attr_meaning);
                            			Value_Valid_In_Valueset := TRUE;
                            			EXIT;
                        			End If;
                        			FND_VSET.get_value(Vset,Row,Found,Value);

                     		End Loop;

                		End If; ---end of Fmt.Has_Id

                		FND_VSET.get_value_end(Vset);

				ELSIF X_Validation_type = 'F' THEN
                --dbms_output.put_line('validation type = F');

               		FND_VSET.get_valueset(x_Vsid,Vset,Fmt);

			   		IF (QP_UTIL.value_exists_in_table(Vset.table_info,l_attr_value,l_id,l_value,l_meaning)) THEN


               				IF Fmt.Has_Id Then    --id is defined.Hence compare for id
                --dbms_output.put_line('ID is defined');
                        				If  l_attr_value  = l_id  Then

	                       				x_attr_value_code  := l_value;
                                                        --dbms_output.put_line('3 x_attr_value_code = ' || x_attr_value_code);
                                                        x_attr_meaning      := l_meaning;
                                                        --dbms_output.put_line('3 x_attr_meaning = ' || x_attr_meaning);
                            				Value_Valid_In_Valueset := TRUE;
                        				End If;
                				Else                 -- id not defined.Hence compare for value
                --dbms_output.put_line('ID is not defined');
                        				If  l_attr_value  = l_value  Then

	                       				x_attr_value_code  := l_attr_value;
                                                        --dbms_output.put_line('4 x_attr_value_code = ' || x_attr_value_code);
                                                        x_attr_meaning      := l_meaning;
                                                        --dbms_output.put_line('4 x_attr_meaning = ' || x_attr_meaning);
                            				Value_Valid_In_Valueset := TRUE;
                        				End If;
							End if;          -- End of Fmt.Has_ID

			  		ELSE
			    				Value_Valid_In_Valueset := FALSE;
			  		END IF;

				END IF;   --X_Validation_Type


             ELSE -- if validation type is not F or I or valueset id is null (not defined)
             --dbms_output.put_line('Value set ID is not found');

               x_attr_value_code := l_attr_value;
               --dbms_output.put_line('5 x_attr_value_code = ' || x_attr_value_code);
               x_attr_meaning := l_attr_value;
               --dbms_output.put_line('5 x_attr_meaning = ' || x_attr_meaning);

             END IF;
         ELSE  -- if comparison operator is 'between'

            x_attr_value_code  := l_attr_value;
            --dbms_output.put_line('6 x_attr_value_code = ' || x_attr_value_code);
            x_attr_meaning := l_attr_value;
            --dbms_output.put_line('6 x_attr_meaning = ' || x_attr_meaning);

         END IF;


         RETURN x_attr_meaning;

END Get_Attribute_Value_Meaning;

FUNCTION Get_Attribute_Value(p_FlexField_Name           IN VARCHAR2
                            ,p_Context_Name             IN VARCHAR2
			    ,p_segment_name             IN VARCHAR2
			    ,p_attr_value               IN VARCHAR2
			    ,p_comparison_operator_code IN VARCHAR2 := NULL
			  ) RETURN VARCHAR2 IS

  Vset  FND_VSET.valueset_r;
  Fmt   FND_VSET.valueset_dr;

  Found BOOLEAN;
  Row   NUMBER;
  Value FND_VSET.value_dr;



  x_Format_Type Varchar2(1);
  x_Validation_Type Varchar2(1);
  x_Vsid  NUMBER;


  x_attr_value_code     VARCHAR2(240);
  l_attribute_code     VARCHAR2(240);
  l_segment_name     VARCHAR2(240);
  l_attr_value     VARCHAR2(2000);


  Value_Valid_In_Valueset BOOLEAN := FALSE;

  l_id	VARCHAR2(240);
  l_value VARCHAR2(240);

  BEGIN
   -- bug 3531203 - POST: QUALIFIER DESCRIPTION ON PRICE LIST MAINTENANCE PAGE SHOWS INTERNAL IDS
   -- call api qp_util.get_valueset_id as qp_util.get_valueset_id_r does not look into attribute management schema

	    /*qp_util.get_valueset_id_r(p_FlexField_Name,p_Context_Name,
	                             p_Segment_Name,x_Vsid,
                                 x_Format_Type, x_Validation_Type);*/

            Get_Attribute_Code(p_FlexField_Name,p_Context_Name, p_Segment_Name,
                              l_attribute_code,
                              l_segment_name);

	    qp_util.get_valueset_id(p_FlexField_Name,p_Context_Name,
	                             l_Segment_Name,x_Vsid,
                                 x_Format_Type, x_Validation_Type);

         l_attr_value := get_num_date_from_canonical(x_format_type,p_attr_value);

         -- if comparison operator is other than  then no need to get the
         -- meaning as the value itself will be stored in qualifier_attr_value

--change made by spgopal. added parameter called p_comparison_operator_code
--to generalise the code for all forms and packages

         If  p_comparison_operator_code <>  'BETWEEN'  THEN

             IF x_Validation_Type In('F' ,'I')  AND x_Vsid  IS NOT NULL THEN


				IF x_Validation_Type = 'I' THEN

               		FND_VSET.get_valueset(x_Vsid,Vset,Fmt);
               		FND_VSET.get_value_init(Vset,TRUE);
               		FND_VSET.get_value(Vset,Row,Found,Value);


               		IF Fmt.Has_Id Then    --id is defined.Hence compare for id
                     		While(Found) Loop


                        			If  l_attr_value  = Value.id  Then

	                       			x_attr_value_code  := Value.value;
                            			Value_Valid_In_Valueset := TRUE;
                            			EXIT;
                        			End If;
                        			FND_VSET.get_value(Vset,Row,Found,Value);

                     		End Loop;

                		Else                 -- id not defined.Hence compare for value

                     		While(Found) Loop

                        			If  l_attr_value  = Value.value  Then

	                       			x_attr_value_code  := l_attr_value;
                            			Value_Valid_In_Valueset := TRUE;
                            			EXIT;
                        			End If;
                        			FND_VSET.get_value(Vset,Row,Found,Value);

                     		End Loop;

                		End If; ---end of Fmt.Has_Id

                		FND_VSET.get_value_end(Vset);

				ELSIF X_Validation_type = 'F' THEN

               		FND_VSET.get_valueset(x_Vsid,Vset,Fmt);

			   		IF (QP_UTIL.value_exists_in_table(Vset.table_info,l_attr_value,l_id,l_value)) THEN


               				IF Fmt.Has_Id Then    --id is defined.Hence compare for id
                        				If  l_attr_value  = l_id  Then

	                       				x_attr_value_code  := l_value;
                            				Value_Valid_In_Valueset := TRUE;
                        				End If;
                				Else                 -- id not defined.Hence compare for value
                        				If  l_attr_value  = l_value  Then

	                       				x_attr_value_code  := l_attr_value;
                            				Value_Valid_In_Valueset := TRUE;
                        				End If;
							End if;          -- End of Fmt.Has_ID

			  		ELSE
			    				Value_Valid_In_Valueset := FALSE;
			  		END IF;

				END IF;   --X_Validation_Type


             ELSE -- if validation type is not F or I or valueset id is null (not defined)

               x_attr_value_code := l_attr_value;

             END IF;
         ELSE  -- if comparison operator is 'between'

            x_attr_value_code  := l_attr_value;

         END IF;


         RETURN x_attr_value_code;

END Get_Attribute_Value;

FUNCTION Get_Salesrep(p_salesrep_id  IN  NUMBER)
RETURN VARCHAR2
IS

l_name VARCHAR2(240);

CURSOR salesrep_cur(a_salesrep_id NUMBER)
IS
 select name
   from ra_salesreps r
  where r.salesrep_id = a_salesrep_id;

BEGIN
  OPEN salesrep_cur(p_salesrep_id);
  FETCH salesrep_cur
  INTO l_name;
  CLOSE salesrep_cur;

  RETURN l_name;

EXCEPTION
  WHEN OTHERS THEN
    CLOSE salesrep_cur;

END Get_Salesrep;

FUNCTION Get_Term(p_term_id  IN  NUMBER)
RETURN VARCHAR2
IS

l_name VARCHAR2(240);

CURSOR term_cur(a_term_id NUMBER)
IS
 select t.name
   from ra_terms_b b ,ra_terms_tl t
  where b.term_id = a_term_id and
        b.term_id = t.term_id and
        t.language = userenv('LANG');

BEGIN
  OPEN term_cur(p_term_id);
  FETCH term_cur
  INTO l_name;
  CLOSE term_cur;

  RETURN l_name;

EXCEPTION
  WHEN OTHERS THEN
    CLOSE term_cur;

END Get_Term;


/***************************************************************************/


-- ==========================================================================
-- Function  value_exists_in_table overloaded
--   funtion type   Private
--   Returns  BOOLEAN
--   out parameters : None
--  DESCRIPTION
--    Searches for value if it exist by building dynamic query stmt when when valueset validation type is F
--    the list populated by  get_valueset call.
-- ===========================================================================


  FUNCTION value_exists_in_table(p_table_r  fnd_vset.table_r,
                                 p_value    VARCHAR2,
						   x_id    OUT NOCOPY VARCHAR2,
						   x_value OUT NOCOPY VARCHAR2,
						   x_meaning OUT NOCOPY VARCHAR2) RETURN BOOLEAN IS
    v_selectstmt   VARCHAR2(2000) ; --dhgupta changed length from 500 to 2000 for bug # 1888160
    v_cursor_id    INTEGER;
    v_value        VARCHAR2(150);
    /* julin (2271729) - increased size for UTF8 */
    v_meaning	    VARCHAR2(1000);
    v_id           VARCHAR2(150);
    v_retval       INTEGER;
    v_where_clause VARCHAR2(2000);  -- bug#13844692
    v_cols	    VARCHAR2(1000);
l_order_by                    VARCHAR2(1000);
l_pos1          number;
l_where_length  number;

/* Added for 3210264 */
type refcur is ref cursor;
v_cursor refcur;

type valueset_cur_type is RECORD (
valueset_value varchar2(150),
valueset_id  varchar2(150),
valueset_meaning  varchar2(1000)
);
valueset_cur valueset_cur_type;


  BEGIN
     v_cursor_id := DBMS_SQL.OPEN_CURSOR;

--Commented out for 2621644
--IF (p_table_r.id_column_name IS NOT NULL) THEN -- Bug 1982009

       /* Added for 2492020 */

         IF instr(UPPER(p_table_r.where_clause), 'ORDER BY') > 0 THEN
               l_order_by := substr(p_table_r.where_clause, instr(UPPER(p_table_r.where_clause), 'ORDER BY'));
               v_where_clause := replace(p_table_r.where_clause, l_order_by ,'');
         ELSE
               v_where_clause := p_table_r.where_clause;
         END IF;

         --8923075 removing the where clause if there is a bind variable
         --attached in where clause as this will be added in sql statement.
         --Further this will be exectued to get value_meaning
         IF(p_table_r.where_clause IS NOT NULL
            AND INSTR(p_table_r.where_clause,':')>0) THEN
              oe_debug_pub.add('Found bind variable in where clause,so truncating the where clause');
              oe_debug_pub.add('where clause:' || p_table_r.where_clause);
              v_where_clause := '';
         END if;

--	if instr(upper(p_table_r.where_clause),'WHERE ') > 0 then  --Commented out for 2492020
        IF instr(upper(v_where_clause),'WHERE') > 0 then --3839853 removed space in 'WHERE '
	--to include the id column name in the query

                v_where_clause:= rtrim(ltrim(v_where_clause));
                l_pos1 := instr(upper(v_where_clause),'WHERE');
		l_where_length :=LENGTHB('WHERE');
                v_where_clause:= substr(v_where_clause,l_pos1+l_where_length);


	   IF (p_table_r.id_column_name IS NOT NULL) THEN
		--included extra quotes for comparing varchar and num values in select
/* Commented out for 2492020
	     v_where_clause := replace(UPPER(p_table_r.where_clause)
			,'WHERE '
			,'WHERE '||p_table_r.id_column_name||' = '''||p_value||''' AND ');
*/
             --v_where_clause := 'WHERE '||p_table_r.id_column_name||' = '''||p_value||''' AND '||v_where_clause;--2492020

             v_where_clause := 'WHERE '||p_table_r.id_column_name||' = :p_val AND '||v_where_clause;--3210264
	   ELSE
/* Commented out for 2492020
	     v_where_clause := replace(UPPER(p_table_r.where_clause)
			,'WHERE '
			,'WHERE '||p_table_r.value_column_name||' = '''||p_value||''' AND ');
*/
            --v_where_clause := 'WHERE '||p_table_r.value_column_name||' = '''||p_value||''' AND '||v_where_clause;--2492020

            v_where_clause := 'WHERE '||p_table_r.value_column_name||' = :p_val AND '||v_where_clause;--3210264
	   END IF;

	else
	IF v_where_clause IS NOT NULL THEN -- FP 115.88.1159.7
	   IF (p_table_r.id_column_name IS NOT NULL) THEN
/* Commented out for 2492020
		v_where_clause := 'WHERE '||p_table_r.id_column_name||' = '''||p_value||''' '||UPPER(p_table_r.where_clause);
*/
                --Added for 2492020
                --v_where_clause := 'WHERE '||p_table_r.id_column_name||' = '''||p_value||''' '||v_where_clause;

                v_where_clause := 'WHERE '||p_table_r.id_column_name||' = :p_val AND '||v_where_clause;--3210264  --13703332
	   ELSE
/* Commented out for 2492020
		v_where_clause := 'WHERE '||p_table_r.value_column_name||' = '''||p_value||''' '||UPPER(p_table_r.where_clause);
*/
                --Added for 2492020
                --v_where_clause := 'WHERE '||p_table_r.value_column_name||' = '''||p_value||''' '||v_where_clause;

                v_where_clause := 'WHERE '||p_table_r.value_column_name||' = :p_val AND '||v_where_clause;--3210264  --13703332
	   END IF;

     /* added ELSE block for 3839853 */
          ELSE

	   IF (p_table_r.id_column_name IS NOT NULL) THEN
                v_where_clause := 'WHERE '||p_table_r.id_column_name||' = :p_val '||v_where_clause;
	   ELSE
                v_where_clause := 'WHERE '||p_table_r.value_column_name||' = :p_val '||v_where_clause;
          END IF;

      END IF;
    end if;
/* Commented out for 2621644
ELSE
       v_where_clause := p_table_r.where_clause;
END IF;
*/

		v_cols :=p_table_r.value_column_name;

-------------------
--changes made by spgopal for performance problem
--added out parameters to pass back id and value for given valueset id
-------------------

   IF (p_table_r.id_column_name IS NOT NULL) THEN

--
-- to_char() conversion function is defined only for
-- DATE and NUMBER datatypes.
--
	IF (p_table_r.id_column_type IN ('D', 'N')) THEN
																		v_cols := v_cols || ' , To_char(' || p_table_r.id_column_name || ')';
	ELSE
		v_cols := v_cols || ' , ' || p_table_r.id_column_name;
	END IF;
   ELSE
	v_cols := v_cols || ', NULL ';
   END IF;


	if p_table_r.meaning_column_name is not null then
		v_cols := v_cols||','||p_table_r.meaning_column_name;
	else
		null;
            v_cols := v_cols || ', NULL ';  --Added for 3210264
	end if;

       v_selectstmt := 'SELECT  '||v_cols||' FROM  '||p_table_r.table_name||' '||v_where_clause;

	  oe_debug_pub.add('select stmt2'||v_selectstmt);

------------------

/*
	IF p_table_r.id_column_name is not null then

       v_selectstmt := 'SELECT  '||p_table_r.id_column_name||' FROM  '||p_table_r.table_name||' '||v_where_clause;

    ELSE

     v_selectstmt := 'SELECT  '||p_table_r.value_column_name||' FROM  '||p_table_r.table_name||' '||p_table_r.where_clause;

    END IF;
*/


/* Added for 3210264 */

open v_cursor for v_selectstmt using p_value;
fetch v_cursor into valueset_cur;
IF v_Cursor%NOTFOUND THEN
        CLOSE v_cursor;
    DBMS_SQL.CLOSE_CURSOR(v_cursor_id);
        RETURN FALSE;
END IF;
x_id := valueset_cur.valueset_id;
x_value := valueset_cur.valueset_value;
If valueset_cur.valueset_meaning is NOT NULL THEN
	x_meaning:= valueset_cur.valueset_meaning;
Else
	x_meaning:= valueset_cur.valueset_value;
End If;
CLOSE v_cursor;
    DBMS_SQL.CLOSE_CURSOR(v_cursor_id);
RETURN TRUE;

/*
    -- parse the query

     DBMS_SQL.PARSE(v_cursor_id,v_selectstmt,DBMS_SQL.V7);
	    oe_debug_pub.add('after parse2');
     -- Bind the input variables
     DBMS_SQL.DEFINE_COLUMN(v_cursor_id,1,v_value,150);
     DBMS_SQL.DEFINE_COLUMN(v_cursor_id,2,v_id,150);
	if p_table_r.meaning_column_name IS NOT NULL THEN
     -- julin (2271729) - increased size for UTF8
     DBMS_SQL.DEFINE_COLUMN(v_cursor_id,3,v_meaning,1000);
	end if;
     v_retval := DBMS_SQL.EXECUTE(v_cursor_id);
     LOOP
       -- Fetch rows in to buffer and check the exit condition from  the loop
       IF( DBMS_SQL.FETCH_ROWS(v_cursor_id) = 0) THEN
          EXIT;
       END IF;
       -- Retrieve the rows from buffer into PLSQL variables
       DBMS_SQL.COLUMN_VALUE(v_cursor_id,1,v_value);
       DBMS_SQL.COLUMN_VALUE(v_cursor_id,2,v_id);
	if p_table_r.meaning_column_name IS NOT NULL THEN
       DBMS_SQL.COLUMN_VALUE(v_cursor_id,3,v_meaning);
	end if;


       IF v_id IS NULL AND (p_value = v_value) THEN
	    oe_debug_pub.add('id null, passing value'||p_value||','||v_value||' '||v_meaning);
         DBMS_SQL.CLOSE_CURSOR(v_cursor_id);
	    x_id := v_id;
	    x_value := v_value;
	    --added this to return meaning
	    x_meaning := v_meaning;
         RETURN TRUE;
	  ELSIF (p_value = v_id) THEN
	    oe_debug_pub.add('id exists, passing id'||p_value||','||v_id||' '||v_meaning);
         DBMS_SQL.CLOSE_CURSOR(v_cursor_id);
	    x_id := v_id;
	    x_value := v_value;
	    --added this to return meaning
	    if v_meaning is not null then
	    x_meaning := v_meaning;
	    else --if meaning not defined in vset, return value
	    x_meaning := v_value;
	    end if;
         RETURN TRUE;
	  ELSE
		Null;
	    oe_debug_pub.add('value does notmatch, continue search'||p_value||','||v_id);
       END IF;
    END LOOP;
    DBMS_SQL.CLOSE_CURSOR(v_cursor_id);
    RETURN FALSE;
*/
 EXCEPTION
   WHEN OTHERS THEN
	    oe_debug_pub.add('value_exists_in_table exception');
     DBMS_SQL.CLOSE_CURSOR(v_cursor_id);
     RETURN FALSE;
 END value_exists_in_table;

 PROCEDURE CORRECT_ACTIVE_DATES(p_active_date_first_type   IN OUT  NOCOPY VARCHAR2,
                                p_start_date_active_first  IN OUT NOCOPY DATE,
                                p_end_date_active_first    IN OUT  NOCOPY DATE,
                                p_active_date_second_type  IN OUT  NOCOPY VARCHAR2,
                                p_start_date_active_second IN OUT  NOCOPY DATE,
                                p_end_date_active_second   IN OUT NOCOPY DATE)
 is
   l_active_date_type_temp   VARCHAR2(30);
   l_start_date_active_temp  DATE;
   l_end_date_active_temp    DATE;
 BEGIN

   IF (p_active_date_first_type = 'ORD'
       AND p_active_date_second_type = 'ORD') THEN
     -- Make the second value NULL
          p_active_date_second_type := NULL;
          p_start_date_active_second := NULL;
          p_end_date_active_second := NULL;

   ELSIF (p_active_date_first_type is NULL
          AND p_active_date_second_type = 'ORD') THEN
     -- Assign the second value to first and make the second NULL
             p_active_date_first_type := p_active_date_second_type;
             p_start_date_active_first := p_start_date_active_second;
             p_end_date_active_first := p_end_date_active_second;

             p_active_date_second_type := NULL;
             p_start_date_active_second := NULL;
             p_end_date_active_second :=  NULL;

   ELSIF p_active_date_first_type = 'SHIP' THEN
           IF p_active_date_second_type = 'ORD' THEN
          -- Swap the values of first and second
              l_active_date_type_temp := p_active_date_first_type;
              l_start_date_active_temp := p_start_date_active_first;
              l_end_date_active_temp := p_end_date_active_first;

              p_active_date_first_type := p_active_date_second_type;
              p_start_date_active_first := p_start_date_active_second;
              p_end_date_active_first := p_end_date_active_second;

              p_active_date_second_type := l_active_date_type_temp;
              p_start_date_active_second := l_start_date_active_temp;
              p_end_date_active_second :=  l_end_date_active_temp;

           ELSIF  p_active_date_second_type is NULL THEN
             -- Assign the first value to second and make the first NULL
              p_active_date_second_type := p_active_date_first_type;
              p_start_date_active_second := p_start_date_active_first;
              p_end_date_active_second := p_end_date_active_first;

              p_active_date_first_type := NULL;
              p_start_date_active_first := NULL;
              p_end_date_active_first :=  NULL;

           ELSIF  p_active_date_second_type = 'SHIP' THEN
            -- Make the first NULL
              p_active_date_first_type := NULL;
              p_start_date_active_first := NULL;
              p_end_date_active_first :=  NULL;
           END IF;
   END IF;

 END CORRECT_ACTIVE_DATES;

  -- mkarya for bug 1728764, Prevent update of Trade Management Data in QP
  -- mkarya for bug 2442212, Prevent update of modifier if PTE does not match with Profile value
  -- New procedure created
 PROCEDURE Check_Source_System_Code
 ( p_list_header_id      IN     qp_list_headers_b.list_header_id%type
 , p_list_line_id        IN     qp_list_lines.list_line_id%type
 , x_return_status       OUT    NOCOPY VARCHAR2
 )
 is
  l_source_system_code              qp_list_headers_b.source_system_code%type;
  l_list_type_code                  qp_list_headers_b.list_type_code%type;
  l_profile_source_system_code      qp_list_headers_b.source_system_code%type;
  l_profile_pte_code                qp_list_headers_b.pte_code%type;
  l_pte_code                        qp_list_headers_b.pte_code%type;
 BEGIN
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      if p_list_header_id is NOT NULL then
         select source_system_code
               , list_type_code
               , pte_code
           into l_source_system_code
               , l_list_type_code
               , l_pte_code
           from qp_list_headers_b
          where list_header_id = p_list_header_id;
      else
         select lh.source_system_code
               , lh.list_type_code
               , lh.pte_code
           into l_source_system_code
               , l_list_type_code
               , l_pte_code
           from qp_list_headers_b lh,
                qp_list_lines ll
          where ll.list_line_id = p_list_line_id
            and lh.list_header_id = ll.list_header_id;
      end if;

      fnd_profile.get('QP_SOURCE_SYSTEM_CODE', l_profile_source_system_code);

      IF qp_util.attrmgr_installed = 'Y' then
        fnd_profile.get('QP_PRICING_TRANSACTION_ENTITY', l_profile_pte_code);
        if (((l_pte_code <> l_profile_pte_code) or
             (l_source_system_code <> l_profile_source_system_code)
            )
            AND (l_list_type_code NOT IN ('AGR', 'PML', 'PRL'))
           ) then

          x_return_status := FND_API.G_RET_STS_ERROR;

          IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
          THEN

              FND_MESSAGE.SET_NAME('QP','QP_CANNOT_CHANGE_MODIFIER_PTE');
              FND_MESSAGE.SET_TOKEN('SOURCE_SYSTEM', l_source_system_code);
              FND_MESSAGE.SET_TOKEN('PTE_CODE', l_pte_code);
              OE_MSG_PUB.Add;

          END IF;
        end if;
      else -- attribute manager not installed
        if ((l_source_system_code <> l_profile_source_system_code)
            AND (l_list_type_code NOT IN ('AGR', 'PML', 'PRL'))) then

          x_return_status := FND_API.G_RET_STS_ERROR;

          IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
          THEN

              FND_MESSAGE.SET_NAME('QP','QP_CANNOT_CHANGE_MODIFIER');
              FND_MESSAGE.SET_TOKEN('SOURCE_SYSTEM', l_source_system_code);
              OE_MSG_PUB.Add;

          END IF;
        end if;

      end if; -- check if attribute manager installed
 EXCEPTION
      when no_data_found then
         -- if the header/line record is yet to be created
         NULL;
 END Check_Source_System_Code;

--------------------------------------------------------------------------------
-- This procedure is used in  the post query to get attribute name for the
-- corresponding pricing/product/qualifier_attribute. qualifier_attribute
-- stores the  'column' corresponding to the flexfield segment.
-- (For e.g the column for the segment 'agreement_name' is
-- 'qualifier_attribute7'. What is shown on the screen is the window prompt
-- for the segment. For e.g  The context 'CUSTOMER' has segments like
-- agreement_name,GSA,agreement_type etc. The window prompt for
-- the segment agreement_name is 'Agreement Name'(UI Value) and the database
-- value for this segement(value stored in qualifier_attribute) is the column
-- name, which is QUALIFIER_ATTRIBUTE7 ,in this case.
--------------------------------------------------------------------------------
PROCEDURE Get_Attribute_Code(p_FlexField_Name      IN  VARCHAR2,
                             p_Context_Name        IN  VARCHAR2,
                             p_attribute           IN  VARCHAR2,
                             x_attribute_code      OUT NOCOPY VARCHAR2,
                             x_segment_name        OUT NOCOPY VARCHAR2)
IS

Flexfield FND_DFLEX.dflex_r;
Flexinfo  FND_DFLEX.dflex_dr;
Contexts  FND_DFLEX.contexts_dr;
segments  FND_DFLEX.segments_dr;
i BINARY_INTEGER;

VALID_ATTRIBUTE BOOLEAN := FALSE;

l_pte_code            VARCHAR2(30);
l_context_type        VARCHAR2(30);
l_error_code          NUMBER;

CURSOR attribute_cur(a_context_type VARCHAR2, a_context_code VARCHAR2,
                     a_pte_code VARCHAR2, a_attribute VARCHAR2)
IS
  SELECT nvl(a.user_segment_name, a.seeded_segment_name),
         b.segment_code
  FROM   qp_segments_tl a, qp_segments_b b,
         qp_prc_contexts_b c, qp_pte_segments d
  WHERE  c.prc_context_type = a_context_type
  AND    c.prc_context_code = a_context_code
  AND    c.prc_context_id = b.prc_context_id
  AND    b.segment_mapping_column = a_attribute
  AND    b.segment_id = a.segment_id
  AND    a.language = userenv('LANG')
  AND    b.segment_id = d.segment_id
  AND    d.pte_code = a_pte_code;


BEGIN

  IF Attrmgr_Installed = 'Y' THEN

    FND_PROFILE.GET('QP_PRICING_TRANSACTION_ENTITY', l_pte_code);

    IF l_pte_code IS NULL THEN
      l_pte_code := 'ORDFUL';
    END IF;

    QP_UTIL.Get_Context_Type(p_flexfield_name, p_context_name,
                             l_context_type, l_error_code);
    IF l_error_code = 0 THEN

      OPEN  attribute_cur(l_context_type, p_context_name,
                          l_pte_code, p_attribute);

      --Deliberately interchanged the output parameters to be consistent with
      --existing code(Before Attributes Manager)
      FETCH attribute_cur INTO x_attribute_code, x_segment_name;

      IF attribute_cur%NOTFOUND then
         x_segment_name := p_attribute;
         x_attribute_code := p_attribute;
      END IF;
      CLOSE attribute_cur;

    END IF; --If l_error_code = 0

  ELSE
/* Added for 2332139 */
   BEGIN
    select form_left_prompt,end_user_column_name
    INTO x_attribute_code,x_segment_name
    from FND_DESCR_FLEX_COL_USAGE_VL
    where APPLICATION_ID = 661 and
    DESCRIPTIVE_FLEXFIELD_NAME = p_FlexField_Name and
    DESCRIPTIVE_FLEX_CONTEXT_CODE = p_Context_Name and
    application_column_name = p_attribute and
    enabled_flag='Y';

   EXCEPTION
    WHEN OTHERS THEN
    x_attribute_code := p_attribute;
    x_segment_name := NULL;
   END;

/* Commented out for 2332139 */

/*

    FND_DFLEX.get_flexfield('QP',p_FlexField_Name,Flexfield,Flexinfo);

    --removing  the check for the  enabled segments as well as per the upgrade
    --requirement. While upgrading ,there may be some segments which were
    --enabled in the past but disabled now. In such cases ,we still need to
    --show the data in the post query.

    FND_DFLEX.get_segments(FND_DFLEX.make_context(Flexfield,p_Context_Name),
                        segments,FALSE);

    FOR i IN 1..segments.nsegments LOOP

      --removing  the check for the  enabled segments as well as per the upgrade
      --requirement. While upgrading ,there may be some segments which were
      --enabled in the past but disabled now. In such cases ,we still need to
      --show the data in the post query.
      IF segments.is_enabled(i)  THEN

	IF segments.application_column_name(i) = p_attribute THEN
	  x_attribute_code := segments.row_prompt(i);
	  x_segment_name   := segments.segment_name(i);
	  EXIT;
        END IF;

      END IF;

    END LOOP;
*/
  END IF; --Attrmgr_Installed = 'Y'

END Get_Attribute_Code;

 FUNCTION Get_Segment_Level(p_list_header_id           IN NUMBER
                           ,p_Context                 IN VARCHAR2
                           ,p_attribute               IN VARCHAR2
                           )
 RETURN VARCHAR2
 is
  l_segment_level         VARCHAR2(30);

 BEGIN

    select c.segment_level
      into l_segment_level
      from qp_prc_contexts_b a,
           qp_segments_b b,
           qp_pte_segments c,
           qp_list_headers_b d
     where a.prc_context_id = b.prc_context_id
       and b.segment_id = c.segment_id
       and c.pte_code = d.pte_code
       and d.list_header_id = p_list_header_id
       and a.prc_context_code = p_context
       and b.SEGMENT_MAPPING_COLUMN = p_attribute;

    return(l_segment_level);

 EXCEPTION
    WHEN OTHERS THEN
       return(NULL);

 END Get_Segment_Level;
-- ===========================================================================

/****************************************************************************

 PROCEDURE Web_Create_Context_Lov
 --------- ----------------------
 Procedure for non-Forms(html) based UI's. This Procedure is similar to
 Create_Context_Lov except that the Contexts(context code and context_name)
 to be displayed in an LOV are returned in a pl/sql table of records.

 Input Parameters:
 -----------------
 p_field_context - 'FACTOR', 'PRODUCT', 'GSA', etc. Pass NULL if irrelevant.
 p_context_type  - Can be 'PRODUCT', 'PRICING_ATTRIBUTE', 'QUALIFIER' or NULL.
                   If Attributes Manager is installed, NULL will cause contexts
                   of types 'PRODUCT', 'QUALIFIER' and 'PRICING_ATTRIBUTE' to
                   be returned. If Attributes Manager is not installed, then
                   NULL causes contexts of types 'PRODUCT' and
                   'PRICING_ATTRIBUTE' to be returned.
 p_check_enabled - Default is 'Y'. If 'Y', only enabled contexts will be
                   returned. If 'N', all contexts will be returned.
 p_limits        - Default is 'N'. If 'Y', limits-enabled contexts will be
                   returned. If 'N', all contexts will be returned.
 p_list_line_type_code - Examples, 'FREIGHT_CHARGE', etc. Although the default
                  is NULL, the actual/correct value must be passed to get the
                  correct list of contexts returned.

 Output Parameters:
 ------------------
 x_return_status   - Indicates Success, Expected_error or Unexpected Error -
                     values can be either FND_API.G_RET_STS_SUCCESS or
                     FND_API.G_RET_STS_ERROR.
 x_context_out_tbl - Table of records where each record has 2 columns,
                     context_code and context_name

****************************************************************************/

PROCEDURE Web_Create_Context_Lov(
                        p_field_context       IN   VARCHAR2,
                        p_context_type        IN   VARCHAR2,
                        p_check_enabled       IN   VARCHAR2,
                        p_limits              IN   VARCHAR2,
                        p_list_line_type_code IN   VARCHAR2,
                        x_return_status       OUT  NOCOPY VARCHAR2,
                        x_context_out_tbl     OUT  NOCOPY CREATE_CONTEXT_OUT_TBL)

IS

Flexfield FND_DFLEX.dflex_r;
Flexinfo  FND_DFLEX.dflex_dr;
Contexts  FND_DFLEX.contexts_dr;

J Binary_Integer      := 1;

l_pte_code          VARCHAR2(30);

CURSOR context_cur(a_pte_code VARCHAR2, a_qp_status VARCHAR2,
                   a_limits VARCHAR2, a_list_line_type_code VARCHAR2)
IS
  SELECT a.prc_context_code,
         nvl(b.user_prc_context_name, b.seeded_prc_context_name)
         prc_context_name,
         a.enabled_flag, a.prc_context_type
  FROM   qp_prc_contexts_b a, qp_prc_contexts_tl b
  WHERE  a.prc_context_id = b.prc_context_id
  AND    b.language = userenv('LANG')
  AND    EXISTS (SELECT 'x'
                 FROM   qp_segments_b c, qp_pte_segments d
                 WHERE  d.pte_code = a_pte_code
                 AND    c.segment_id = d.segment_id
                 AND    c.prc_context_id = a.prc_context_id
                 AND    d.lov_enabled = 'Y'
                 AND    (a_limits = 'Y' AND d.limits_enabled = 'Y'
                         OR
                         a_limits <> 'Y')
                 AND    (a_qp_status = 'S' AND
                            (c.availability_in_basic = 'Y' OR
                             c.availability_in_basic = 'F' AND
                             a_list_line_type_code = 'FREIGHT_CHARGE')
                         OR
                         a_qp_status <> 'S')
                 );

l_flexfield_name    VARCHAR2(30);
l_qp_status         VARCHAR2(1);
l_add_flag          BOOLEAN;

BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF Attrmgr_Installed = 'Y' THEN

    --Get the PTE code
    FND_PROFILE.GET('QP_PRICING_TRANSACTION_ENTITY', l_pte_code);

    IF l_pte_code IS NULL THEN
      l_pte_code := 'ORDFUL';
    END IF;

    --Get QP Install Status
    l_qp_status := QP_UTIL.Get_QP_Status;

    FOR l_rec IN context_cur(l_pte_code, l_qp_status, p_limits,
                             p_list_line_type_code)
    LOOP

      l_add_flag := FALSE; --initialize for each iteration of loop

      IF  (p_check_enabled = 'Y' AND
           l_rec.enabled_flag = 'Y'
           )
           OR
           p_check_enabled = 'N'
      THEN

        IF (p_context_type IS NOT NULL AND
            l_rec.prc_context_type = p_context_type
            )
            OR
            p_context_type IS NULL
        THEN

          IF p_field_context = 'PRODUCT'  THEN

            IF l_rec.prc_context_code = 'ITEM' THEN
              l_add_flag := TRUE;
            END IF;

          ELSIF p_field_context = 'PRICING_ATTR' THEN

            IF l_rec.prc_context_code <> 'VOLUME' THEN
              l_add_flag := TRUE;
            END IF;

          ELSIF p_field_context = 'BASIC' THEN

            IF l_rec.prc_context_code IN ('MODLIST', 'CUSTOMER') THEN
              l_add_flag := TRUE;
            END IF;

          ELSIF p_field_context = 'LINE_BASIC' THEN

            IF l_rec.prc_context_code IN ('ORDER', 'CUSTOMER') THEN
              l_add_flag := TRUE;
            END IF;

          ELSIF p_field_context = 'GSA' THEN

            IF l_rec.prc_context_code IN ('MODLIST', 'CUSTOMER') THEN
              l_add_flag := TRUE;
            END IF;

          ELSIF p_field_context = 'FACTOR' THEN

            IF l_rec.prc_context_type IN ('PRODUCT', 'PRICING_ATTRIBUTE') THEN
              l_add_flag := TRUE;
            END IF;

          ELSE

            l_add_flag := TRUE;

          END IF;

        END IF;

      END IF;

      IF l_add_flag THEN
        x_context_out_tbl(j).context_code := l_rec.prc_context_code;
        x_context_out_tbl(j).context_name := l_rec.prc_context_name;
        j:= j+1;
      END IF; --l_add_flag = TRUE

    END LOOP; --End FOR Loop

  ELSE

    IF p_context_type IN ('PRODUCT', 'PRICING_ATTRIBUTE') OR
       p_context_type IS NULL
    THEN
      l_flexfield_name := 'QP_ATTR_DEFNS_PRICING';
    ELSIF p_context_type = 'QUALIFIER' THEN
      l_flexfield_name := 'QP_ATTR_DEFNS_QUALIFIER';
    END IF;

    -- Call Flexapi to get contexts
    FND_DFLEX.get_flexfield('QP',l_flexfield_name,Flexfield,Flexinfo);
    FND_DFLEX.get_contexts(Flexfield,Contexts);

    FOR i IN 1..Contexts.ncontexts LOOP

--    If (Contexts.is_enabled(i)) Then
      IF(Contexts.is_enabled(i) AND (NOT (Contexts.is_global(i)))) THEN

      	IF (p_field_context = 'PRODUCT' ) THEN

	  IF  (Contexts.context_code(i) = 'ITEM') THEN
            x_context_out_tbl(j).context_code := Contexts.context_code(i);
            x_context_out_tbl(j).context_name := Contexts.context_name(i);
            j:= j+1;
          END IF;

    	ELSIF (p_field_context = 'PRICING_ATTR' ) THEN

	  IF (Contexts.context_code(i) = 'ITEM') OR
	     (Contexts.context_code(i) = 'VOLUME') THEN
            NULL;
          ELSE
            x_context_out_tbl(j).context_code := Contexts.context_code(i);
            x_context_out_tbl(j).context_name := Contexts.context_name(i);
            j:= j+1;
	  END IF;

    	ELSIF (p_field_context = 'BASIC' ) THEN

	  IF (Contexts.context_code(i) IN ('CUSTOMER', 'MODLIST')) THEN
            x_context_out_tbl(j).context_code := Contexts.context_code(i);
            x_context_out_tbl(j).context_name := Contexts.context_name(i);
            j:= j+1;
	  END IF;

    	ELSIF (p_field_context = 'LINE_BASIC' ) THEN

	  IF (Contexts.context_code(i) IN ('CUSTOMER', 'ORDER')) THEN
            x_context_out_tbl(j).context_code := Contexts.context_code(i);
            x_context_out_tbl(j).context_name := Contexts.context_name(i);
            j:= j+1;
	  END IF;

    	ELSIF (p_field_context = 'GSA' ) THEN

	  IF (Contexts.context_code(i) IN ('CUSTOMER', 'MODLIST')) THEN
            x_context_out_tbl(j).context_code := Contexts.context_code(i);
            x_context_out_tbl(j).context_name := Contexts.context_name(i);
            j:= j+1;
	  END IF;

	ELSE

          x_context_out_tbl(j).context_code := Contexts.context_code(i);
          x_context_out_tbl(j).context_name := Contexts.context_name(i);
          j:= j+1;

        END IF;

      END IF;

    END LOOP;

  END IF; --If Attrmgr_Installed = 'Y'

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MESSAGE.SET_NAME('QP','QP_ERR_IN_VALUESET_DEF');
    OE_MSG_PUB.Add;

END Web_Create_Context_Lov;


/****************************************************************************
 PROCEDURE Web_Create_Attribute_Lov
 --------- ------------------------
 Procedure for non-Forms(html) based UI's. This Procedure is similar to
 Create_Attribute_Lov except that the Attributes to be displayed in an LOV are
 returned in a pl/sql table of records.

 Input Parameters:
 -----------------
 p_context_code  - The context_code whose Attributes are to be returned. Ex,
 p_context_type  - Must be  one of the following - 'PRODUCT',
                   'PRICING_ATTRIBUTE' or 'QUALIFIER' and must correspond
                   correctly to the correct  the p_context_code being passed.
 p_check_enabled - Default is 'Y'. If 'Y', only enabled contexts will be
                   returned. If 'N', all contexts will be returned.
 p_limits        - Default is 'N'. If 'Y', limits-enabled contexts will be
                   returned. If 'N', all contexts will be returned.
 p_list_line_type_code - Examples, 'FREIGHT_CHARGE', etc. Although the default
                  is NULL, the actual/correct value must be passed to get the
                  correct list of contexts returned.
 p_segment_level - can have the following possible values:

     Value - Meaning
     -----   -------
       1     ORDER (Segments having segment_level equal to this)
       2     LINE  (Segments having segment_level equal to this)
       3     BOTH  (Segments having segment_level equal to this)
       4     ORDER or BOTH (Segments having segment_level equal to this)
       5     LINE  or BOTH (Segments having segment_level equal to this)
       6     ORDER or LINE or BOTH (Segments having segment_level equal to this)

 p_field_context - 'BASIC', 'LINE_BASIC', 'GSA', 'S','I','N' etc. In most cases,
                   some value must be passed. For example, for PriceLists,
                   Formulas related forms, pass 'S' if basic pricing , 'I' for
                   advanced_pricing installed.  Pass NULL if irrelevant(rare).

 Output Parameters:
 ------------------
 x_return_status     - Indicates Success, Expected_error or Unexpected Error -
                       values can be either FND_API.G_RET_STS_SUCCESS or
                       FND_API.G_RET_STS_ERROR.
 x_attribute_out_tbl - Table of records where each record has 5 columns -
                       segment_mapping_column, segment_name,
                       segment_code, precedence and valueset_id

****************************************************************************/

PROCEDURE Web_Create_Attribute_Lov(
                    p_context_code         IN  VARCHAR2,
                    p_context_type         IN  VARCHAR2,
                    p_check_enabled        IN  VARCHAR2,
                    p_limits               IN  VARCHAR2,
                    p_list_line_type_code  IN  VARCHAR2,
                    p_segment_level        IN  NUMBER,
                    p_field_context        IN  VARCHAR2,
                    x_return_status        OUT NOCOPY VARCHAR2,
                    x_attribute_out_tbl    OUT NOCOPY CREATE_ATTRIBUTE_OUT_TBL)
IS

Flexfield FND_DFLEX.dflex_r;
Flexinfo  FND_DFLEX.dflex_dr;
Contexts  FND_DFLEX.contexts_dr;
segments  FND_DFLEX.segments_dr;
i BINARY_INTEGER;

j Binary_Integer     := 1;

QP_NO_SEGMENT EXCEPTION;

l_pte_code            VARCHAR2(30);

CURSOR attribute_cur(a_context_type VARCHAR2, a_context_code VARCHAR2,
                     a_pte_code VARCHAR2)
IS
  SELECT a.segment_mapping_column,
         nvl(b.user_segment_name, b.seeded_segment_name) segment_name,
         a.segment_code, nvl(a.user_precedence, a.seeded_precedence) precedence,
         d.prc_context_code, d.prc_context_type, c.lov_enabled,
         a.availability_in_basic, c.limits_enabled, c.segment_level,
         nvl(a.user_valueset_id, a.seeded_valueset_id) valueset_id
  FROM   qp_segments_b a, qp_segments_tl b,
         qp_pte_segments c, qp_prc_contexts_b d
  WHERE  d.prc_context_type = a_context_type
  AND    d.prc_context_code = a_context_code
  AND    a.prc_context_id = d.prc_context_id
  AND    a.segment_id = b.segment_id
  AND    b.language = userenv('LANG')
  AND    c.pte_code = a_pte_code
  AND    c.segment_id = b.segment_id;

l_add_flag        BOOLEAN;
l_qp_status       VARCHAR2(1);
l_flexfield_name  VARCHAR2(30);

NO_SEGMENT_FOUND  BOOLEAN := TRUE;

BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF Attrmgr_Installed = 'Y' THEN

    --Get PTE code from profile
    FND_PROFILE.GET('QP_PRICING_TRANSACTION_ENTITY',l_pte_code);

    IF l_pte_code IS NULL THEN
      l_pte_code := 'ORDFUL';
    END IF;

    --Get QP Install Status
    l_qp_status := QP_UTIL.Get_QP_Status;

    FOR l_rec IN attribute_cur(p_context_type,
                               p_context_code, l_pte_code)
    LOOP

      IF attribute_cur%rowcount = 1 THEN
        NO_SEGMENT_FOUND := FALSE;
      END IF;

      l_add_flag := FALSE; --initialize for each iteration of loop

      IF  (p_check_enabled = 'Y' AND
           l_rec.lov_enabled = 'Y'
           )
          OR
          p_check_enabled = 'N'
      THEN

        IF   (l_qp_status = 'S' AND
              (l_rec.availability_in_basic = 'Y' OR
               l_rec.availability_in_basic = 'F' AND
               p_list_line_type_code = 'FREIGHT_CHARGE'
               )
              )
             OR
             l_qp_status <> 'S'
        THEN

          IF (p_limits = 'Y' AND
              l_rec.limits_enabled = 'Y'
              )
             OR
             p_limits <> 'Y'
          THEN

            IF (p_segment_level = 1 AND
                l_rec.segment_level = 'ORDER'
                )
               OR
               (p_segment_level = 2 AND
                l_rec.segment_level = 'LINE'
                )
               OR
               (p_segment_level = 3 AND
                l_rec.segment_level = 'BOTH'
                )
               OR
               (p_segment_level = 4 AND
                l_rec.segment_level IN ('ORDER', 'BOTH')
                )
               OR
               (p_segment_level = 5 AND
                l_rec.segment_level IN ('LINE', 'BOTH')
                )
               OR
               (p_segment_level = 6 AND
                l_rec.segment_level IN ('ORDER', 'LINE', 'BOTH')
                )
            THEN

              IF (p_list_line_type_code = 'OID' AND
                  p_field_context = 'PRICING_ATTR_GET'
                  )
                 OR
                 p_field_context = 'GSA'
              THEN

                IF l_rec.prc_context_code = 'ITEM' AND
                   l_rec.segment_mapping_column = 'PRICING_ATTRIBUTE1'
                THEN
                  l_add_flag := TRUE;
                END IF;

              ELSIF p_field_context = 'BASIC' THEN

                IF (l_rec.prc_context_code = 'CUSTOMER' AND
                    l_rec.segment_mapping_column IN ('QUALIFIER_ATTRIBUTE1',
                                                     'QUALIFIER_ATTRIBUTE2',
                                                     'QUALIFIER_ATTRIBUTE5')
                   )
                   OR
                   (l_rec.prc_context_code = 'MODLIST' AND
                    l_rec.segment_mapping_column = 'QUALIFIER_ATTRIBUTE4'
                    )
                THEN
                  l_add_flag := TRUE;
                END IF;

              ELSIF p_field_context = 'GSA_QUALIFIER' THEN

                IF (l_rec.prc_context_code = 'CUSTOMER' AND
                    l_rec.segment_mapping_column IN ('QUALIFIER_ATTRIBUTE2',
                                                     'QUALIFIER_ATTRIBUTE5')
                   )
                   OR
                   (l_rec.prc_context_code = 'MODLIST' AND
                    l_rec.segment_mapping_column = 'QUALIFIER_ATTRIBUTE4'
                    )
                THEN
                  l_add_flag := TRUE;
                END IF;

              ELSIF p_field_context = 'LINE_BASIC' THEN

                IF (l_rec.prc_context_code = 'CUSTOMER' AND
                    l_rec.segment_mapping_column IN ('QUALIFIER_ATTRIBUTE7',
                                                     'QUALIFIER_ATTRIBUTE8')
                   )
                   OR
                   (l_rec.prc_context_code = 'ORDER' AND
                    l_rec.segment_mapping_column IN ('QUALIFIER_ATTRIBUTE9',
                                                     'QUALIFIER_ATTRIBUTE12')
                    )
                   OR
                   (l_rec.prc_context_code = 'VOLUME' AND
                    l_rec.segment_mapping_column IN ('PRICING_ATTRIBUTE10',
                                                     'PRICING_ATTRIBUTE12')
                    )
                THEN
                  l_add_flag := TRUE;
                END IF;

              ELSIF p_field_context IN ('S','I','N') THEN
                           -- These are possible values, that the Price Lists
                           -- module can assign to the field_context parameter.
                IF NOT (l_rec.prc_context_code = 'MODLIST' AND
                        l_rec.segment_mapping_column = 'QUALIFIER_ATTRIBUTE4'
                        )
                   AND
                   NOT (l_rec.prc_context_code = 'VOLUME' AND
                        l_rec.segment_mapping_column = 'PRICING_ATTRIBUTE12'
                        )
                   AND
                   NOT (l_rec.prc_context_code = 'VOLUME' AND
                        l_rec.segment_mapping_column = 'QUALIFIER_ATTRIBUTE10'
                        )
                THEN
                  l_add_flag := TRUE;
                END IF;

              ELSE

                l_add_flag := TRUE;

              END IF;

            END IF; --If p_segment_level...

          END IF; --If l_form_function...

        END IF; --If l_qp_status...

      END IF; --If p_check_enabled...

      IF l_add_flag THEN
        x_attribute_out_tbl(j).segment_mapping_column :=
                                      l_rec.segment_mapping_column;
        x_attribute_out_tbl(j).segment_name := l_rec.segment_name;
        x_attribute_out_tbl(j).segment_code := l_rec.segment_code;
        x_attribute_out_tbl(j).precedence := l_rec.precedence;
        x_attribute_out_tbl(j).valueset_id := l_rec.valueset_id;
        j:= j+1;
      END IF; --l_add_flag = TRUE

    END LOOP; --End FOR Loop

    IF NO_SEGMENT_FOUND THEN
      RAISE QP_NO_SEGMENT;
    END IF;

  ELSE

    IF p_context_type IN ('PRODUCT', 'PRICING_ATTRIBUTE') THEN
      l_flexfield_name := 'QP_ATTR_DEFNS_PRICING';
    ELSIF p_context_type = 'QUALIFIER' THEN
      l_flexfield_name := 'QP_ATTR_DEFNS_QUALIFIER';
    END IF;

    FND_DFLEX.get_flexfield('QP',l_flexfield_name,Flexfield,Flexinfo);
    FND_DFLEX.get_segments(FND_DFLEX.make_context(Flexfield,p_Context_Code),
                           segments,TRUE);

    IF segments.nsegments  <>  0  THEN

      FOR i IN 1..segments.nsegments LOOP

        IF segments.is_enabled(i)  THEN
          --fnd_message.debug(p_Context_Name);

          NO_SEGMENT_FOUND := FALSE;

          IF (p_list_line_type_code = 'OID' and
              p_field_context = 'PRICING_ATTR_GET')
          THEN

            IF p_context_code = 'ITEM' AND /* Item Number */
	       segments.application_column_name(i) = 'PRICING_ATTRIBUTE1'
            THEN
              x_attribute_out_tbl(j).segment_mapping_column :=
                                      segments.application_column_name(i);
              x_attribute_out_tbl(j).segment_name := segments.row_prompt(i);
              x_attribute_out_tbl(j).segment_code := segments.segment_name(i);
              x_attribute_out_tbl(j).precedence := segments.sequence(i);
              x_attribute_out_tbl(j).valueset_id := segments.value_set(i);
              j:= j+1;
            END IF;

          ELSIF p_field_context = 'GSA' THEN

	    IF p_context_code = 'ITEM' AND
               segments.application_column_name(i) = 'PRICING_ATTRIBUTE1'
            THEN
              x_attribute_out_tbl(j).segment_mapping_column :=
                                      segments.application_column_name(i);
              x_attribute_out_tbl(j).segment_name := segments.row_prompt(i);
              x_attribute_out_tbl(j).segment_code := segments.segment_name(i);
              x_attribute_out_tbl(j).precedence := segments.sequence(i);
              x_attribute_out_tbl(j).valueset_id := segments.value_set(i);
              j:= j+1;
            END IF;

          ELSIF p_field_context = 'BASIC' THEN

            IF (p_context_code = 'CUSTOMER' AND
	        segments.application_column_name(i) IN ('QUALIFIER_ATTRIBUTE1',
                                                        'QUALIFIER_ATTRIBUTE2',
                                                        'QUALIFIER_ATTRIBUTE5'))
               OR
	       (p_context_code = 'MODLIST' AND
	        segments.application_column_name(i) = 'QUALIFIER_ATTRIBUTE4')
            THEN
              x_attribute_out_tbl(j).segment_mapping_column :=
                                      segments.application_column_name(i);
              x_attribute_out_tbl(j).segment_name := segments.row_prompt(i);
              x_attribute_out_tbl(j).segment_code := segments.segment_name(i);
              x_attribute_out_tbl(j).precedence := segments.sequence(i);
              x_attribute_out_tbl(j).valueset_id := segments.value_set(i);
              j:= j+1;
            END IF;

          ELSIF p_field_context = 'GSA_QUALIFIER' THEN

            IF (p_context_code = 'CUSTOMER' AND
	        segments.application_column_name(i) IN ('QUALIFIER_ATTRIBUTE2',
	  					        'QUALIFIER_ATTRIBUTE5'))
               OR
	       (p_context_code = 'MODLIST' AND
	        segments.application_column_name(i) = 'QUALIFIER_ATTRIBUTE4')
            THEN
              x_attribute_out_tbl(j).segment_mapping_column :=
                                      segments.application_column_name(i);
              x_attribute_out_tbl(j).segment_name := segments.row_prompt(i);
              x_attribute_out_tbl(j).segment_code := segments.segment_name(i);
              x_attribute_out_tbl(j).precedence := segments.sequence(i);
              x_attribute_out_tbl(j).valueset_id := segments.value_set(i);
              j:= j+1;
            END IF;

          ELSIF p_field_context = 'LINE_BASIC' THEN

            IF (p_context_code = 'CUSTOMER' AND
	        segments.application_column_name(i) IN
	  	 ('QUALIFIER_ATTRIBUTE7', 'QUALIFIER_ATTRIBUTE8'))
               OR
	       (p_context_code = 'ORDER' and
	       segments.application_column_name(i) IN ('QUALIFIER_ATTRIBUTE9',
                                                       'QUALIFIER_ATTRIBUTE12'))
            THEN
              x_attribute_out_tbl(j).segment_mapping_column :=
                                      segments.application_column_name(i);
              x_attribute_out_tbl(j).segment_name := segments.row_prompt(i);
              x_attribute_out_tbl(j).segment_code := segments.segment_name(i);
              x_attribute_out_tbl(j).precedence := segments.sequence(i);
              x_attribute_out_tbl(j).valueset_id := segments.value_set(i);
              j:= j+1;
            ELSIF (p_context_code = 'VOLUME' AND
  		   segments.application_column_name(i) IN
		   ('PRICING_ATTRIBUTE10', 'PRICING_ATTRIBUTE12')) THEN
              x_attribute_out_tbl(j).segment_mapping_column :=
                                      segments.application_column_name(i);
              x_attribute_out_tbl(j).segment_name := segments.row_prompt(i);
              x_attribute_out_tbl(j).segment_code := segments.segment_name(i);
              x_attribute_out_tbl(j).precedence := segments.sequence(i);
              x_attribute_out_tbl(j).valueset_id := segments.value_set(i);
              j:= j+1;
            END IF;

          ELSIF p_field_context IN ('S', 'I', 'N') THEN
	      -- These are possible values, that the
	      -- Price Lists module can assign to the basic_advanced paramter.
            IF NOT (p_context_code = 'MODLIST' AND
  		  segments.application_column_name(i) = 'QUALIFIER_ATTRIBUTE4')
            AND NOT (p_context_code = 'VOLUME' AND
		   segments.application_column_name(i) = 'PRICING_ATTRIBUTE12')
	    AND NOT (p_context_code = 'VOLUME' AND
	  	 segments.application_column_name(i) = 'QUALIFIER_ATTRIBUTE10')
	    THEN
              -- Don't display qual attr 'Price List' in Price Lists form,
	      -- don't display qual attr 'Order Amount'(also under 'Volume')
              -- and don't display Pricing Attr 'Item Amount' under 'Volume'
	      -- Context(in the Price Breaks block of Price List form).
              x_attribute_out_tbl(j).segment_mapping_column :=
                                      segments.application_column_name(i);
              x_attribute_out_tbl(j).segment_name := segments.row_prompt(i);
              x_attribute_out_tbl(j).segment_code := segments.segment_name(i);
              x_attribute_out_tbl(j).precedence := segments.sequence(i);
              x_attribute_out_tbl(j).valueset_id := segments.value_set(i);
              j:= j+1;
	    END IF;

          ELSE --Covers all the 'else' conditions for Modifiers module
            --fnd_message.debug(segments.row_prompt(i));

            x_attribute_out_tbl(j).segment_mapping_column :=
                                      segments.application_column_name(i);
            x_attribute_out_tbl(j).segment_name := segments.row_prompt(i);
            x_attribute_out_tbl(j).segment_code := segments.segment_name(i);
            x_attribute_out_tbl(j).precedence := segments.sequence(i);
            x_attribute_out_tbl(j).valueset_id := segments.value_set(i);
	    j:= j+1;

          END IF;

        END IF;

      END LOOP;

      IF NO_SEGMENT_FOUND THEN
        RAISE QP_NO_SEGMENT;
      END IF;

    ELSE  --- segments.nsegments = 0 ie no segments defined for the context.

      RAISE QP_NO_SEGMENT;

    END IF;          ----  if segments.nsegments <> 0

  END IF; --If Attrmgr_Installed = 'Y'

EXCEPTION
  WHEN QP_NO_SEGMENT   THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MESSAGE.SET_NAME('QP','QP_NO_SEGMENTS_AVAILABLE');
    OE_MSG_PUB.Add;

END Web_Create_Attribute_Lov;


 FUNCTION Get_Item_Validation_Org RETURN NUMBER IS
     l_application_id       NUMBER;
     l_inv_org_id           NUMBER;
   BEGIN
     oe_debug_pub.add('Start G_ORGANIZATION_ID = '||G_ORGANIZATION_ID);
/*
commenting this code R12 per ER 4756750 to move the profile-based
approach for all calling app and come up with a pricing parameter
for the item validation Org per the ER
       l_application_id := fnd_global.resp_appl_id;

       oe_debug_pub.add('l_application_id = '||l_application_id);
       if l_application_id in (201, 178) then -- oracle purchasing/iProcurement
         SELECT inventory_organization_id
           INTO l_inv_org_id
           --fix for bug 4776045 for MOAC
           --FROM financials_system_parameters;
           FROM FINANCIALS_SYSTEM_PARAMS_ALL
           where org_id = get_org_id;

         oe_debug_pub.add('inv_org_id from financials_system_parameters = '||l_inv_org_id);
         G_ORGANIZATION_ID := l_inv_org_id;
       end if;--application_id
       if G_ORGANIZATION_ID is null then --above query did not return a value
       --because MO Default OU was not set or FSP is not set revert to QP profile
*/
 --    if G_ORGANIZATION_ID is null then
         l_inv_org_id := FND_PROFILE.Value('QP_ORGANIZATION_ID');

         oe_debug_pub.add('inv_org_id from profile QP_ORGANIZATION_ID = '||l_inv_org_id);
         IF G_ORGANIZATION_ID IS NULL THEN
            G_ORGANIZATION_ID := l_inv_org_id;
--       end if;
         end if; --if G_ORGANIZATION_ID is null

     oe_debug_pub.add('End G_ORGANIZATION_ID = '||G_ORGANIZATION_ID);

     return l_inv_org_id;
 EXCEPTION
   when no_data_found then
      oe_debug_pub.add('no data found exception in qp_util.Get_Item_Validation_Org');
      --fix for bug 4776045
--      G_ORGANIZATION_ID := FND_PROFILE.Value('QP_ORGANIZATION_ID');
--      return G_ORGANIZATION_ID;
        return null;

   when others then
      oe_debug_pub.add('others exception in qp_util.Get_Item_Validation_Org, error is ' || SQLERRM);
      --fix for bug 4776045
--      G_ORGANIZATION_ID := FND_PROFILE.Value('QP_ORGANIZATION_ID');
--      return G_ORGANIZATION_ID;
        return null;

 END Get_Item_Validation_Org;

--[prarasto] added for MOAC. Used by the engine to get the org id.
FUNCTION get_org_id		--[prarasto] changed function signature
RETURN NUMBER IS
l_context_org_id NUMBER;
BEGIN
 l_context_org_id := MO_GLOBAL.get_current_org_id;
-- IF (FND_GLOBAL.USER_ID IS NOT NULL) AND (FND_GLOBAL.RESP_ID IS NOT NULL) AND (FND_GLOBAL.RESP_APPL_ID IS NOT NULL)  THEN
   IF l_context_org_id IS NOT NULL THEN
   --check if org context is set
    RETURN l_context_org_id; --MO_GLOBAL.get_current_org_id;
 ELSE
    RETURN MO_UTILS.get_default_org_id; --[prarasto] modified to get the default org id from MO_UTILS
 END IF;
Exception
When OTHERS Then
  return null;
END get_org_id;


--[prarasto] added for MOAC. Used by the engine for validating the org id
FUNCTION validate_org_id (p_org_id NUMBER)
RETURN VARCHAR2 IS
	l_dummy VARCHAR2(1);
BEGIN
/*
	SELECT 'X'
	INTO l_dummy
	FROM hr_operating_units hr
	WHERE hr.organization_id = p_org_id
	  AND MO_GLOBAL.check_access(hr.organization_id) = 'Y';
*/
l_dummy := MO_GLOBAL.check_access(p_org_id);

/*
        IF l_dummy = 'X' THEN
	     RETURN 'Y';
        ELSE
             RETURN 'N';
        END IF;
*/
RETURN l_dummy;
EXCEPTION
When OTHERS Then
  return 'N';
END validate_org_id;

--added for moac used by PL/ML VOs to query OU
FUNCTION Get_OU_Name(p_org_id IN NUMBER) RETURN VARCHAR2 IS
l_operating_unit VARCHAR2(240);
BEGIN
  IF p_org_id IS NOT NULL THEN
    select name
           into l_operating_unit
    from hr_operating_units
    where organization_id = p_org_id;
  END IF;
  return l_operating_unit;
EXCEPTION
When OTHERS Then
  return null;
END Get_OU_Name;

--[prarasto] added for MOAC. Used by the engine for validating the org id

PROCEDURE get_pte_and_ss (p_list_header_id IN NUMBER,
                          x_pte_code OUT NOCOPY VARCHAR2,
                          x_source_system_code OUT NOCOPY VARCHAR2)
IS
BEGIN
        SELECT pte_code, source_system_code
        INTO x_pte_code, x_source_system_code
        FROM qp_list_headers_b
        WHERE list_header_id = p_list_header_id;
EXCEPTION
When OTHERS Then
     null;
END get_pte_and_ss;


-- =======================================================================
-- FUNCTION  is_seed_user
--   Function type   Public
--  DESCRIPTION
--    Returns a boolean corresponding to whether the current user is
--    the DATAMERGE user
-- =======================================================================
FUNCTION is_seed_user RETURN BOOLEAN
IS
  l_db_name VARCHAR2(9);
  l_dm_user_id NUMBER;
BEGIN
  BEGIN
    -- Get database name
    /* SELECT name
    INTO l_db_name
    FROM v$database; */

    SELECT sys_context('USERENV','DB_NAME')
    INTO l_db_name
    FROM dual;

    -- Get DATAMERGE User ID
    SELECT user_id
    INTO l_dm_user_id
    FROM fnd_user
    WHERE user_name = 'DATAMERGE';

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN FALSE;
  END;

  -- If the database is a seed DB and the user is DATAMERGE, return TRUE
  IF l_db_name LIKE 'SEED%' AND l_dm_user_id = fnd_global.user_id THEN
    RETURN TRUE;
  ELSE
    RETURN FALSE;
  END IF;

END is_seed_user;


FUNCTION Validate_Item(p_product_context IN VARCHAR2,
                        p_product_attribute IN VARCHAR2,
                        p_product_attr_val IN VARCHAR2) RETURN VARCHAR2 IS
l_appl_id NUMBER := FND_GLOBAL.RESP_APPL_ID;
l_dummy VARCHAR2(30);
l_return_status               VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
BEGIN

if (p_product_context = 'ITEM')
and (p_product_attribute = 'PRICING_ATTRIBUTE1') THEN
  begin
    SELECT 'VALID' INTO l_dummy
    FROM mtl_system_items_b
    where inventory_item_id = p_product_attr_val
    AND ((l_appl_id not in (178,201) and customer_order_flag = 'Y')
    or (l_appl_id in (178, 201) and NVL(PURCHASING_ENABLED_FLAG, 'N') ='Y'))
    and organization_id = Get_Item_Validation_Org;
  exception
    WHEN NO_DATA_FOUND THEN
      IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR) THEN
        FND_MESSAGE.SET_NAME('QP','QP_ITEM_NOT_VALID');
        FND_MESSAGE.SET_TOKEN('ITEM_ID', p_product_attr_val);
        OE_MSG_PUB.Add;
        RETURN FND_API.G_RET_STS_ERROR;
      END IF;
      RAISE FND_API.G_EXC_ERROR;
    WHEN OTHERS THEN
      null;
      RETURN FND_API.G_RET_STS_ERROR;
    end;
end if;--(p_product_context =

RETURN l_return_status;

EXCEPTION
WHEN OTHERS THEN
  null;
END Validate_Item;

END QP_UTIL;

/
