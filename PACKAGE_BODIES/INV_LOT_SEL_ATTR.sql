--------------------------------------------------------
--  DDL for Package Body INV_LOT_SEL_ATTR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_LOT_SEL_ATTR" AS
/* $Header: INVLSDFB.pls 120.8.12010000.5 2009/06/24 16:14:09 mchemban ship $ */

/* Global constant holding package name */
g_pkg_name CONSTANT VARCHAR2(20) := 'INV_LOT_SEL_ATTR' ;

g_version_printed BOOLEAN := FALSE;

PROCEDURE debug(
             p_message IN VARCHAR2,
             p_module  IN VARCHAR2,
             p_level   IN NUMBER
             ) IS

      l_debug   NUMBER := NVL (fnd_profile.VALUE ('INV_DEBUG_TRACE'), 0);

   BEGIN

      IF NOT g_version_printed THEN
         IF (l_debug = 1 ) THEN /* Bug#5401181*/
           inv_log_util.TRACE ('$Header: INVLSDFB.pls 120.8.12010000.5 2009/06/24 16:14:09 mchemban ship $',
                               g_pkg_name,
                               9
                              );
         END IF;
         g_version_printed := TRUE;

      END IF;
      IF (l_debug = 1 ) THEN /* Bug#5401181*/
        inv_log_util.TRACE (
                            p_message,
                            g_pkg_name || '.' || p_module,
                            p_level
                           );
      END IF;

      --dbms_output.put_line(p_message);
   END debug;


/* ----------------------------------------------------------
 * Procedure to fetch descriptive flexfield context category
 * for a given item and organization
 *----------------------------------------------------------*/
PROCEDURE get_context_code(context_value  OUT NOCOPY VARCHAR2,
         org_id   IN NUMBER,
         item_id      IN NUMBER,
         flex_name  IN VARCHAR2,
            p_lot_serial_number IN  VARCHAR2 ) IS

   i NUMBER;
   l_context_column_name VARCHAR2(12);
   l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
   l_module_name        VARCHAR2(30) := 'GET_CONTEXT_CODE';
BEGIN
   context_value := NULL;
   l_context_column_name := 'ITEM';
   IF(p_lot_serial_number IS NOT NULL) THEN
      IF(flex_name = 'Lot Attributes') THEN
         SELECT lot_attribute_category
         INTO   context_value
         FROM   mtl_lot_numbers
         WHERE  lot_number = p_lot_serial_number
         AND    inventory_item_id = item_id
         AND    organization_id = org_id;
      ELSIF (flex_name = 'Serial Attributes') THEN
         SELECT serial_attribute_category
         INTO   context_value
         FROM   mtl_serial_numbers
         WHERE  serial_number = p_lot_serial_number
         AND    inventory_item_id = item_id
         AND    current_organization_id = org_id;
      END IF;
   ELSE
      BEGIN
         SELECT descriptive_flex_context_code
        INTO context_value
        FROM mtl_flex_context
        WHERE organization_id = -1
        AND context_column_name = l_context_column_name
        AND descriptive_flexfield_name = flex_name
        AND context_column_value_id = item_id;

      EXCEPTION
         WHEN NO_DATA_FOUND THEN
        NULL;
      END;

      IF context_value IS NULL THEN

         BEGIN

           SELECT descriptive_flex_context_code
           INTO  context_value
          FROM  mtl_flex_context
           WHERE organization_id = org_id
           AND   context_column_name = l_context_column_name
           AND   descriptive_flexfield_name = flex_name
           AND   context_column_value_id = item_id;

         EXCEPTION
            WHEN NO_DATA_FOUND THEN
           NULL;
         END;

      END IF;

      l_context_column_name := 'CATEGORY';

      IF context_value IS NULL THEN
         BEGIN
           SELECT descriptive_flex_context_code
           INTO context_value
           FROM  mtl_flex_context mfc,
                 mtl_item_categories mic
           WHERE mfc.organization_id = -1
           AND   mic.organization_id = org_id
           AND   mfc.category_set_id = mic.category_set_id
           AND   mfc.context_column_value_id = mic.category_id
           AND   mfc.descriptive_flexfield_name = flex_name
           AND   mic.inventory_item_id = item_id
           AND   mfc.context_column_name = l_context_column_name;

         EXCEPTION
           WHEN NO_DATA_FOUND THEN
              context_value := NULL;
         END;
      END IF;

      IF context_value IS NULL THEN
         BEGIN
            SELECT descriptive_flex_context_code
           INTO context_value
           FROM  mtl_flex_context mfc,
                 mtl_item_categories mic
           WHERE mfc.organization_id = org_id
           AND   mfc.organization_id = mic.organization_id
           AND   mfc.category_set_id = mic.category_set_id
           AND   mfc.context_column_value_id = mic.category_id
           AND   mfc.descriptive_flexfield_name = flex_name
           AND   mic.inventory_item_id = item_id
           AND   mfc.context_column_name = l_context_column_name;

         EXCEPTION
           WHEN NO_DATA_FOUND THEN
                context_value := NULL;
         END;
      END IF;
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      context_value := NULL;
      debug('Unexpected exception : '||SQLERRM,l_module_name, 0);
END get_context_code;

PROCEDURE get_context_code( context_value OUT NOCOPY VARCHAR2,
  org_id          IN  NUMBER,
  item_id         IN  NUMBER,
  flex_name       IN  VARCHAR2)
IS
BEGIN
  get_context_code(
    context_value => context_value
  ,   org_id    => org_id
  ,   item_id   => item_id
  ,   flex_name => flex_name
  ,   p_lot_serial_number => null);

END get_context_code;


/* ----------------------------------------------------------
 * Procedure to fetch descriptive flexfield context category
 * for a given item and organization -- 2756040
 *----------------------------------------------------------*/

PROCEDURE get_lot_serial_context(
          context_value OUT NOCOPY VARCHAR2,
          org_id        IN NUMBER,
          item_id       IN NUMBER,
          p_lot_serial  IN VARCHAR2,
          flex_name   IN VARCHAR2
          ) IS

   l_debug              NUMBER := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);

   l_module_name        VARCHAR2(30) := 'GET_LOT_SERIAL_CONTEXT';
   l_progress_indicator VARCHAR2(10) := '0';

   SERIAL_ATTRIBUTES    VARCHAR2(30) := 'Serial Attributes';
   LOT_ATTRIBUTES       VARCHAR2(30) := 'Lot Attributes';

   l_context_value      VARCHAR2(200);

BEGIN

   debug('In procedure : ', l_module_name, 0);

   IF (l_debug > 0) THEN

      debug('org_id => '||org_id,l_module_name,9);
      debug('itemid =>  '||item_id,l_module_name,9);
      debug('p_lot_serial =>  '||p_lot_serial,l_module_name,9);
      debug('flex_name => '||flex_name,l_module_name,9);

   END IF;

   l_progress_indicator := '10';

   IF (flex_name = SERIAL_ATTRIBUTES) THEN

      l_progress_indicator := '20';

      SELECT serial_attribute_category
      INTO   l_context_value
      FROM   mtl_serial_numbers
      WHERE  serial_number = p_lot_serial
      AND    inventory_item_id = item_id
      AND    current_organization_id = org_id;

   ELSIF (flex_name = LOT_ATTRIBUTES) THEN

      l_progress_indicator := '30';

      SELECT lot_attribute_category
      INTO   l_context_value
      FROM   mtl_lot_numbers
      WHERE  lot_number = p_lot_serial
      AND    inventory_item_id = item_id
      AND    organization_id = org_id;

   ELSE

      l_progress_indicator := '30';

      debug('Invalid value of parameter flex name :'||flex_name,
            l_module_name,
            0);

      RAISE NO_DATA_FOUND;

   END IF;

   IF (l_debug > 0) THEN

      debug(' context value => '||l_context_value, l_module_name, 9);

   END IF;

   context_value := l_context_value;

   debug('Call success ', l_module_name, 0);

EXCEPTION
   WHEN OTHERS THEN

      debug('Unexpected exception : '||SQLERRM||
            ' at '||l_progress_indicator, l_module_name, 0);

      context_value := NULL;

END get_lot_serial_context;


/*------------------------------------------------
 * Private procedure to obtain the column type
 * given table name and column name
 *------------------------------------------------*/
PROCEDURE get_column_type(
  p_table_name  IN  VARCHAR2
, p_column_name IN  VARCHAR2
, x_column_type OUT NOCOPY VARCHAR2) IS

/** Bug 2600351 -- selecting from all_Tab_columns causes performance issue.
    It takes about 171 second from 173 thousand rows and the only rows we need is
    only 10 rows **/

/** Instead of selecting from all_tab_columns, we will just use PL/SQL processing to
    find out the column type, anyway, it is only 3 return types **/

    l_retVarchar VARCHAR2(15) := 'VARCHAR2';
    l_retDate VARCHAR2(15) := 'DATE';
    l_retNumber VARcHAR2(15) := 'NUMBER';
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
    if( upper(p_table_name) = 'MTL_LOT_NUMBERS' ) then
  if( upper(p_column_name ) = 'VENDOR_ID') then
      x_column_type := l_retNumber;
        elsif( upper(p_column_name) = 'GRADE_CODE') then
      x_column_type := l_retVarchar;
        elsif( upper(p_column_name) = 'ORIGINATION_DATE') then
      x_column_type := l_retDate;
  elsif( upper(p_column_name) = 'DATE_CODE') then
      x_column_type := l_retVarchar;
  elsif( upper(p_column_name) = 'STATUS_ID') then
      x_column_type := l_retNumber;
  elsif( upper(p_column_name) = 'CHANGE_DATE') then
      x_column_type := l_retDate;
  elsif( upper(p_column_name) = 'AGE') then
      x_column_type := l_retNumber;
  elsif( upper(p_column_name) = 'RETEST_DATE') then
      x_column_type := l_retDate;
  elsif( upper(p_column_name) = 'MATURITY_DATE') then
      x_column_type := l_retDate;
  elsif( upper(p_column_name) = 'LOT_ATTRIBUTE_CATEGORY') then
      x_column_type := l_retVarchar;
  elsif( upper(p_column_name) = 'ITEM_SIZE') then
      x_column_type := l_retNumber;
  elsif( upper(p_column_name) = 'COLOR') then
      x_column_type := l_retVarchar;
  elsif( upper(p_column_name) = 'VOLUME') then
      x_column_type := l_retNumber;
  elsif( upper(p_column_name) = 'VOLUME_UOM') then
      x_column_type := l_retVarchar;
  elsif( upper(p_column_name) = 'PLACE_OF_ORIGIN') then
      x_column_type := l_retVarchar;
  elsif( upper(p_column_name) = 'BEST_BY_DATE') then
      x_column_type := l_retDate;
  elsif( upper(p_column_name) = 'LENGTH') then
      x_column_type := l_retNumber;
  elsif( upper(p_column_name) = 'LENGTH_UOM') then
      x_column_type := l_retVarchar;
  elsif( upper(p_column_name) = 'RECYCLED_CONTENT') then
      x_column_type := l_retNumber;
  elsif( upper(p_column_name) = 'THICKNESS') then
      x_column_type := l_retNumber;
  elsif( upper(p_column_name) = 'THICKNESS_UOM') then
      x_column_type := l_retVarchar;
  elsif( upper(p_column_name) = 'WIDTH') then
      x_column_type := l_retNumber;
  elsif( upper(p_column_name) = 'WIDTH_UOM') then
      x_column_type := l_retVarchar;
  elsif( upper(p_column_name) = 'CURL_WRINKLE_FOLD') then
      x_column_type := l_retVarchar;
  elsif( upper(p_column_name) = 'SUPPLIER_LOT_NUMBER') then
      x_column_type := l_retVarchar;
  elsif( upper(p_column_name) = 'TERRITORY_CODE') then
      x_column_type := l_retVarchar;
  elsif( upper(p_column_name) = 'VENDOR_NAME') then
      x_column_type := l_retVarchar;
  elsif( substr(upper(p_column_name), 1, 11) = 'C_ATTRIBUTE') then
      x_column_type := l_retVarchar;
        elsif( substr(upper(p_column_name), 1, 11) = 'N_ATTRIBUTE') then
      x_column_type := l_retNumber;
        elsif( substr(upper(p_column_name), 1, 11) = 'D_ATTRIBUTE') then
      x_column_type := l_retDate;
  else
      x_column_type := NULL;
  end if;
    elsif( upper(p_table_name) = 'MTL_SERIAL_NUMBERS' ) then
  if( upper(p_column_name) = 'SERIAL_ATTRIBUTE_CATEGORY' )then
      x_column_type := l_retVarchar;
  elsif( upper(p_column_name) = 'ORIGINATION_DATE') then
      x_column_type := l_retDate;
  elsif( substr(upper(p_column_name), 1, 11) = 'C_ATTRIBUTE') then
      x_column_type := l_retVarchar;
        elsif( substr(upper(p_column_name), 1, 11) = 'N_ATTRIBUTE') then
      x_column_type := l_retNumber;
        elsif( substr(upper(p_column_name), 1, 11) = 'D_ATTRIBUTE') then
      x_column_type := l_retDate;
        elsif( upper(p_column_name) = 'STATUS_ID') then
      x_column_type := l_retNumber;
        elsif( upper(p_column_name) = 'TERRITORY_CODE') then
      x_column_type := l_retVarchar;
  else
      x_column_type := NULL;
        end if;
    end if;

/*
  OPEN c_column_type;
  FETCH c_column_type INTO x_column_type;
  CLOSE c_column_type;
*/
/*EXCEPTION
  WHEN NO_DATA_FOUND THEN
    x_column_type := NULL;*/
END;

/*---------------------------------------------------------------------
 * procedure definition for get lot number attributes defaults
 *---------------------------------------------------------------------*/
PROCEDURE get_default(
  x_attributes_default    OUT  NOCOPY lot_sel_attributes_tbl_type
, x_attributes_default_count  OUT  NOCOPY NUMBER
, x_return_status           OUT  NOCOPY VARCHAR2
,   x_msg_count           OUT NOCOPY NUMBER
,   x_msg_data                OUT  NOCOPY VARCHAR2
, p_table_name      IN  VARCHAR2
, p_attributes_name   IN  VARCHAR2
, p_inventory_item_id   IN  NUMBER
, p_organization_id   IN  NUMBER
, p_lot_serial_number   IN  VARCHAR2
, p_attributes      IN  lot_sel_attributes_tbl_type) IS

  c_api_name CONSTANT VARCHAR2(30) := 'get_default';
  v_flexfield   fnd_dflex.dflex_r;
  v_flexinfo  fnd_dflex.dflex_dr;
  v_contexts  fnd_dflex.contexts_dr;
  v_segments  fnd_dflex.segments_dr;

  v_attributes_category VARCHAR2(50) :=NULL;
  v_global_code VARCHAR2(50);
  i   BINARY_INTEGER;
  j   BINARY_INTEGER;
  k   BINARY_INTEGER;
  v_col_index BINARY_INTEGER;
  v_rec_index NUMBER;
  v_isAllNull BOOLEAN;
  v_enabled BOOLEAN;
  v_colName VARCHAR2(50);
  v_value   VARCHAR2(200);
  v_a_name  VARCHAR2(50);
   l_context_column_name     VARCHAR2(240); --bug 2474713
   l_context_prompt fnd_descriptive_flexs_vl.form_context_prompt%TYPE; --bug#2474713
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);

   TYPE t_genref is REF CURSOR;
   default_value_csr t_genref;
   l_default_date_value DATE;
   l_default_numeric_value NUMBER;
   l_default_char_value VARCHAR2(2000);
   l_count NUMBER;
BEGIN
    -- Get flexfield
    IF (l_debug = 1) THEN
       inv_log_util.trace('Get Flexfield ' || p_attributes_name, 'LOTSERATTR');
    END IF;
    fnd_dflex.get_flexfield('INV', p_attributes_name, v_flexfield, v_flexinfo);

  -- Get Contexts
    fnd_dflex.get_contexts(v_flexfield, v_contexts);
    IF (l_debug = 1) THEN
       inv_log_util.trace('Get context ' , 'LOTSERATTR');
    END IF;
   /*bug 2474713 retrieve the context_column_name and the context_prompt */
    l_context_column_name := v_flexinfo.context_column_name;
    l_context_prompt := v_flexinfo.form_context_prompt;
  -- Get attributes category
    get_context_code(
  context_value   => v_attributes_category
  , org_id    => p_organization_id
  , item_id   => p_inventory_item_id
  , flex_name   => p_attributes_name
   ,  p_lot_serial_number =>   p_lot_serial_number);

    /*-------------------------------------------------------
     * STEP 1: Check whether all the input columns are NULL
     *------------------------------------------------------*/

     v_isAllNull := TRUE;    /* set initial value to true */
     v_enabled   := FALSE;   /* set initially no segments is enabled */

     <<contextLoop>>
     FOR i IN 1..v_contexts.ncontexts LOOP
  IF(v_contexts.is_enabled(i) AND
     ((UPPER(v_contexts.context_code(i)) = UPPER(v_attributes_category)) OR
      v_contexts.is_global(i))) THEN

      -- Get segmentse
      IF (l_debug = 1) THEN
        inv_log_util.trace('get segment', 'LOTSERATTR');
      END IF;
      fnd_dflex.get_segments(fnd_dflex.make_context(
     v_flexfield, v_contexts.context_code(i)), v_segments, TRUE);

      <<segmentLoop>>
      FOR j IN 1..v_segments.nsegments LOOP
      IF v_segments.is_enabled(j) THEN
       v_enabled := TRUE;
       v_colName := v_segments.application_column_name(j);

       v_col_index := NULL;
       <<columnLoop>>
       FOR k IN 1..p_attributes.count() LOOP
           IF UPPER(v_colName) = UPPER(p_attributes(k).column_name) THEN
        v_col_index := k;
        EXIT columnLoop; -- found column
           END IF;
       END LOOP columnLoop;

       IF v_col_index IS NOT NULL THEN
          IF(p_attributes(v_col_index).column_value IS NOT NULL) THEN
             v_isAllNull := FALSE;
       EXIT contextLoop;
          END IF;
       END IF;
    END IF;
      END LOOP segmentLoop;
   END IF;
    END LOOP contextLoop;

    x_attributes_default_count := 0;
    IF(v_enabled) THEN
  /*-------------------------------------------------------------------
   * STEP 2. ASSIGN DEFAUL VALUE when there is/are segment(s) enabled
   *    If all the input values are null, return default values for
   *       all the segments of this context
   *    If there are not null input values, return default values for
   *       only required segments.
   *------------------------------------------------------------------*/

  IF (l_debug = 1) THEN
    inv_log_util.trace('assign default value ', 'LOTSERATTR');
  END IF;
  v_rec_index := 0;

  <<contextLoop1>>
  FOR i IN 1..v_contexts.ncontexts LOOP
      IF(v_contexts.is_enabled(i) AND
        ((UPPER(v_contexts.context_code(i)) = UPPER(v_attributes_category)) OR
         v_contexts.is_global(i))) THEN
               /*bug 2474713 populate x_attributes_default with the context_column_name.
                 All the other fields in the record are also populated */

               IF(NOT(v_contexts.is_global(i))) THEN
             v_rec_index := v_rec_index + 1;
                   x_attributes_default(v_rec_index).COLUMN_NAME := l_context_column_name;
             IF (l_debug = 1) THEN
               inv_log_util.trace('get_column_type', 'LOTSERATTR');
             END IF;
                   get_column_type(
          p_table_name    => p_table_name,
          p_column_name   => x_attributes_default(v_rec_index).COLUMN_NAME,
          x_column_type     => x_attributes_default(v_rec_index).COLUMN_TYPE);

                   x_attributes_default(v_rec_index).REQUIRED := 'TRUE';
             x_attributes_default(v_rec_index).PROMPT := l_context_prompt;
               END IF; /*bug2474713*/

    -- Get segments
    fnd_dflex.get_segments(fnd_dflex.make_context(v_flexfield,
      v_contexts.context_code(i)),
            v_segments, TRUE);
    <<segmentLoop1>>
    FOR j IN 1..v_segments.nsegments LOOP
        IF v_segments.is_enabled(j) THEN
        v_rec_index := v_rec_index +1 ;
      x_attributes_default(v_rec_index).COLUMN_NAME := v_segments.application_column_name(j);
      get_column_type(
        p_table_name,
        x_attributes_default(v_rec_index).COLUMN_NAME,
        x_attributes_default(v_rec_index).COLUMN_TYPE);
      IF(v_segments.is_required(j)) THEN
         x_attributes_default(v_rec_index).REQUIRED := 'TRUE';
      ELSE
         x_attributes_default(v_rec_index).REQUIRED := 'FALSE';
      END IF;

      /* Case 1:  all the input are null, give default values to all the columns*/
      IF(v_isAllNull) THEN
         if( l_debug = 1) then
                                inv_log_util.trace('is all null', 'LOTSERATTR');
                            end if;

                            if( v_segments.default_type(j) = 'S') then
                                open default_value_csr for v_segments.default_value(j);
                                l_count := 0;
                                LOOP
                                    if( x_attributes_default(v_rec_index).COLUMN_TYPE = 'DATE') THEN
                                        FETCH default_value_Csr into l_default_date_value;
                                        x_attributes_default(v_rec_index).COLUMN_VALUE :=
                                                fnd_date.date_to_canonical(l_default_date_value);
                                    elsif ( x_attributes_default(v_rec_index).COLUMN_TYPE = 'NUMBER') then
                                        FETCH default_value_csr into l_default_numeric_value;
                                        x_attributes_default(v_rec_index).COLUMN_VALUE :=
                                                        to_char(l_default_numeric_value);
                                    else
                                        FETCH default_value_csr into l_default_char_value;
                                        x_attributes_default(v_rec_index).COLUMN_VALUE := substr(l_default_char_value, 1, 150);
                                    end if;
                                    EXIT WHEN default_value_csr%NOTFOUND;
                                    l_count := l_count + 1;
                                end loop;
        if( l_count = 0 ) then
            FND_MESSAGE.SET_NAME('FND', 'FLEX-DFLT NO SQL ROWS');
            FND_MESSAGE.SET_TOKEN('SEGMENT_NAME', v_segments.segment_name(j));
            FND_MESSAGE.SET_TOKEN('APPLICATION_SHORT_NAME', 'INV');
            FND_MESSAGE.SET_TOKEN('FLEXFIELD_NAME', p_attributes_name);
            FND_MESSAGE.SET_TOKEN('SQL_STRING', v_segments.default_value(j));
            FND_MSG_PUB.ADD;
        elsif( l_count > 1 ) then
            FND_MESSAGE.SET_NAME('FND', 'FLEX-DFLT MULTIPLE SQL ROWS');
            FND_MESSAGE.SET_TOKEN('SQLSTR', v_segments.default_value(j));
        end if;
                            else
                                x_attributes_default(v_rec_index).COLUMN_VALUE := v_segments.default_value(j);
                            end if;
          x_attributes_default(v_rec_index).PROMPT := v_segments.row_prompt(j);
      ELSE
      /*  Case 2:  not all are null, set those required segments and not null inputs*/
         v_col_index := NULL;
         <<columnLoop1>>
         FOR k IN 1..p_attributes.count() LOOP
             IF UPPER(v_segments.application_column_name(j))=UPPER(p_attributes(k).column_name) THEN
              v_col_index := k;
              EXIT columnLoop1; -- found column
             END IF;
          END LOOP columnLoop1;

          IF((v_col_index IS NOT NULL) AND (p_attributes(v_col_index).COLUMN_VALUE IS NOT NULL))THEN
            x_attributes_default(v_rec_index).COLUMN_VALUE := p_attributes(v_col_index).COLUMN_VALUE;

          ELSIF(v_segments.is_required(j)) THEN
             if( v_segments.default_type(j) = 'S') then
                                    open default_value_csr for v_segments.default_value(j);
                                    l_count := 0;
                                    LOOP
                                        if( x_attributes_default(v_rec_index).COLUMN_TYPE = 'DATE') THEN
                                            FETCH default_value_Csr into l_default_date_value;
                                            x_attributes_default(v_rec_index).COLUMN_VALUE :=
                                                fnd_date.date_to_canonical(l_default_date_value);
                                        elsif ( x_attributes_default(v_rec_index).COLUMN_TYPE = 'NUMBER') then
                                            FETCH default_value_csr into l_default_numeric_value;
                                            x_attributes_default(v_rec_index).COLUMN_VALUE :=
                                                        to_char(l_default_numeric_value);
                                        else
                                            FETCH default_value_csr into l_default_char_value;
                                            x_attributes_default(v_rec_index).COLUMN_VALUE := substr(l_default_char_value, 1, 150);
                                        end if;
                                        EXIT WHEN default_value_csr%NOTFOUND;
                                        l_count := l_count + 1;
                                    end loop;
            if( l_count = 0 ) then
                FND_MESSAGE.SET_NAME('FND', 'FLEX-DFLT NO SQL ROWS');
                FND_MESSAGE.SET_TOKEN('SEGMENT_NAME', v_segments.segment_name(j));
                FND_MESSAGE.SET_TOKEN('APPLICATION_SHORT_NAME', 'INV');
                FND_MESSAGE.SET_TOKEN('FLEXFIELD_NAME', p_attributes_name);
                FND_MESSAGE.SET_TOKEN('SQL_STRING', v_segments.default_value(j));
                FND_MSG_PUB.ADD;
            elsif( l_count > 1 ) then
                FND_MESSAGE.SET_NAME('FND', 'FLEX-DFLT MULTIPLE SQL ROWS');
                FND_MESSAGE.SET_TOKEN('SQLSTR', v_segments.default_value(j));
            end if;
                                else
                                    x_attributes_default(v_rec_index).COLUMN_VALUE := v_segments.default_value(j);
                                end if;
          END IF;
          x_attributes_default(v_rec_index).PROMPT := v_segments.row_prompt(j);
      END IF;

      /* Check if segment is required, default value can not be NULL */
      IF (v_segments.is_required(j)) THEN
         IF(x_attributes_default(v_rec_index).COLUMN_VALUE IS NULL) THEN
              IF (l_debug = 1) THEN
                inv_log_util.trace('error inv_lot_sel_default_required', 'LOTSERATTR');
              END IF;
        fnd_message.set_name('INV', 'INV_LOT_SEL_DEFAULT_REQUIRED');
        fnd_message.set_token('ATTRNAME',p_attributes_name);
        fnd_message.set_token('CONTEXTCODE', v_contexts.context_code(i));
        fnd_message.set_token('SEGMENT', v_segments.application_column_name(j));
        fnd_msg_pub.add;
         END IF;
            END IF;
        END IF; -- segment is enabled
          END LOOP segmentLoop1;
      END IF; -- context is enabled
  END LOOP contextLoop1;

  x_attributes_default_count := v_rec_index;
  x_return_status := fnd_api.g_ret_sts_success ;

  --inv_debug.message('x_return_status is ' || x_return_status);
      ELSE    /* no segment is enabled */
        x_attributes_default_count := 0;
        x_return_status := fnd_api.g_ret_sts_success ;
      END IF;  /* v_enabled */

EXCEPTION
      WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error ;

      WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error ;

      WHEN others THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error ;
        IF (fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, c_api_name);
        END IF;
END get_default;

/* Returns the delimiter for the given dff
   If flexfield is not found, then returns -1' */
FUNCTION get_delimiter(p_flex_name IN VARCHAR2,
                       p_application_short_name IN VARCHAR2) RETURN VARCHAR2 IS
   v_flexfield  fnd_dflex.dflex_r;
  v_flexinfo  fnd_dflex.dflex_dr;

BEGIN

   -- Get flexfield
  fnd_dflex.get_flexfield(p_application_short_name, p_flex_name, v_flexfield, v_flexinfo);
   return(v_flexinfo.segment_delimeter);
EXCEPTION
   WHEN OTHERS THEN
      RETURN('-1');
END get_delimiter;



/* 2949575 */
/* Checks whether the DFF has a required Context or Global segment value */
/* Returns 1 if its required, 0 otherwise */
FUNCTION is_dff_required(p_flex_name IN VARCHAR2,
                         p_application_short_name IN VARCHAR2,
                         p_organization_id IN NUMBER,
                         p_inventory_item_id IN NUMBER) RETURN NUMBER IS

   v_dflex_context_flag VARCHAR2(10);
   v_flexfield  fnd_dflex.dflex_r;
  v_flexinfo  fnd_dflex.dflex_dr;
  v_contexts  fnd_dflex.contexts_dr;
   v_segments fnd_dflex.segments_dr;
   v_attributes_category  VARCHAR2(50) :=NULL;
  i   BINARY_INTEGER;
  j   BINARY_INTEGER;

BEGIN


   SELECT   df.context_required_flag
    INTO    v_dflex_context_flag
    FROM    fnd_application_vl a, fnd_descriptive_flexs_vl df
    WHERE   a.application_short_name = p_application_short_name
    AND     df.application_id = a.application_id
    AND     df.descriptive_flexfield_name = p_flex_name
    AND     a.application_id = df.table_application_id;

   /* Check if it has a required context */
   IF(v_dflex_context_flag = 'Y') THEN
      /* Check if the context has a default value and whether the Default Value has any
         Required segments, or the Global segments are Required */
      IF(is_enabled(p_flex_name,p_organization_id,p_inventory_item_id) >= 2) THEN
          -- It has required segments
          RETURN(1);
      else
         RETURN(0);
      end if;
   else
      --return (0); -- Bug:3839336: Commented this line and added the following to complete the fix done in Bug 3802523
           --3 means that there are required and enabled segments in global context.
     IF(is_enabled(p_flex_name,p_organization_id,p_inventory_item_id) = 3) THEN
       return (1);
     ELSE
       return (0);
     END IF;

   end if;

EXCEPTION
   WHEN OTHERS
      THEN
      RETURN(0);
END  is_dff_required;
/*End of 2949575 */

/* Bug# 3418790
  Code that returns 1 if the Context_User_Override_Flag is Y, 0 otherwise */
FUNCTION is_context_displayed(p_flex_name IN VARCHAR2,
                              p_application_short_name IN VARCHAR2) RETURN NUMBER IS
   l_context_override_flag VARCHAR2(10);
BEGIN

   SELECT   df.context_user_override_flag
    INTO    l_context_override_flag
    FROM    fnd_application_vl a, fnd_descriptive_flexs_vl df
    WHERE   a.application_short_name = p_application_short_name
    AND     df.application_id = a.application_id
    AND     df.descriptive_flexfield_name = p_flex_name
    AND     a.application_id = df.table_application_id;

   IF(l_context_override_flag = 'Y') THEN
      RETURN(1);
   ELSE
      RETURN(0);
   END IF;

EXCEPTION
   WHEN OTHERS THEN
      RETURN(0);
END is_context_displayed;
/* End of 3418790 */


/*-------------------------------------------------
* Check whether a descriptive flexfield has enabled(required)
  segements. The return value can be:
  0 - no enabled segments
  1 - has enabled segments but are not required
  2 - had enabled and required segments
  -------------------------------------------------*/
FUNCTION is_enabled(p_flex_name IN VARCHAR2,
                    p_organization_id IN NUMBER,
                    p_inventory_item_id IN NUMBER) RETURN NUMBER IS

  c_api_name CONSTANT VARCHAR2(30) := 'is_enabled';
  v_flexfield   fnd_dflex.dflex_r;
  v_flexinfo  fnd_dflex.dflex_dr;
  v_contexts  fnd_dflex.contexts_dr;
  v_segments  fnd_dflex.segments_dr;

  v_attributes_category VARCHAR2(50) :=NULL;
  i   BINARY_INTEGER;
  j   BINARY_INTEGER;

  v_is_enabled  NUMBER := 0;
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

  v_is_enabled :=0;

  -- Get flexfield
  fnd_dflex.get_flexfield('INV', p_flex_name, v_flexfield, v_flexinfo);

  -- Get Contexts
  fnd_dflex.get_contexts(v_flexfield, v_contexts);

  -- Get attributes category
  get_context_code(
    context_value   => v_attributes_category
  , org_id    => p_organization_id
  , item_id   => p_inventory_item_id
  , flex_name   => p_flex_name
  ,   p_lot_serial_number => null);

  <<contextLoop>>
  FOR i IN 1..v_contexts.ncontexts LOOP
    IF(v_contexts.is_enabled(i) AND
       ((UPPER(v_contexts.context_code(i)) = UPPER(v_attributes_category)) OR
        v_contexts.is_global(i))
      ) THEN

      -- Get segments
      fnd_dflex.get_segments(fnd_dflex.make_context(v_flexfield,
              v_contexts.context_code(i)),
                    v_segments, TRUE);

      <<segmentLoop>>
      FOR j IN 1..v_segments.nsegments LOOP
          IF v_segments.is_enabled(j) THEN
            IF v_segments.is_required(j) THEN
              -- Found enabled and required segment, return
              v_is_enabled := 2;
              --Return 3 if the context is global
              IF v_contexts.is_global(i) THEN
                v_is_enabled := 3;
              END IF;
              EXIT contextLoop;
            ELSE
              v_is_enabled := 1;
            END IF;
            END IF;
      END LOOP segmentLoop;
    END IF;
  END LOOP contextLoop;
  RETURN v_is_enabled;
EXCEPTION
  WHEN others THEN
    v_is_enabled :=0;
    RETURN v_is_enabled;
END is_enabled;


FUNCTION is_enabled_segment(
                    p_flex_name IN VARCHAR2,
                    p_segment_name in VARCHAR2,
                    p_organization_id IN NUMBER,
                    p_inventory_item_id IN NUMBER) RETURN NUMBER IS

  c_api_name CONSTANT VARCHAR2(30) := 'is_enabled_segment';
  v_flexfield   fnd_dflex.dflex_r;
  v_flexinfo  fnd_dflex.dflex_dr;
  v_contexts  fnd_dflex.contexts_dr;
  v_segments  fnd_dflex.segments_dr;

  v_attributes_category VARCHAR2(50) :=NULL;
  i   BINARY_INTEGER;
  j   BINARY_INTEGER;

  v_is_enabled  NUMBER := 0;
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

  v_is_enabled :=0;

  -- Get flexfield
  fnd_dflex.get_flexfield('INV', p_flex_name, v_flexfield, v_flexinfo);

  -- Get Contexts
  fnd_dflex.get_contexts(v_flexfield, v_contexts);

  -- Get attributes category
  INV_LOT_SEL_ATTR.get_context_code(
    context_value   => v_attributes_category
  , org_id    => p_organization_id
  , item_id   => p_inventory_item_id
  , flex_name   => p_flex_name
  ,       p_lot_serial_number => null);

  <<contextLoop>>
  FOR i IN 1..v_contexts.ncontexts LOOP
    IF(v_contexts.is_enabled(i) AND
       ((UPPER(v_contexts.context_code(i)) = UPPER(v_attributes_category)) OR
        v_contexts.is_global(i))
      ) THEN

      -- Get segments
      fnd_dflex.get_segments(fnd_dflex.make_context(v_flexfield,
              v_contexts.context_code(i)),
                    v_segments, TRUE);

      <<segmentLoop>>
      FOR j IN 1..v_segments.nsegments LOOP
                        --dbms_output.put_line(v_segments.segment_name(j));
                        IF upper(v_segments.segment_name(j)) = upper(p_segment_name) THEN
          IF v_segments.is_enabled(j) THEN
            IF v_segments.is_required(j) THEN
              -- Found enabled and required segment, return
              v_is_enabled := 2;
              EXIT contextLoop;
            ELSE
              v_is_enabled := 1;
              EXIT segmentLoop;
            END IF;
            END IF;
                        END IF;
      END LOOP segmentLoop;
    END IF;
  END LOOP contextLoop;
  RETURN v_is_enabled;
EXCEPTION
  WHEN others THEN
    v_is_enabled :=0;
    RETURN v_is_enabled;
END is_enabled_segment;

/* Function that returns True in case the Lot Exists in MLN, False otherwise */
FUNCTION does_lot_exist(p_lot_number IN VARCHAR2, p_inventory_item_id IN NUMBER, p_org_id IN NUMBER) RETURN BOOLEAN IS
-- Increased lot size to 80 Char - Mercy Thomas - B4625329
   l_lot_number VARCHAR2(80);
BEGIN
   SELECT lot_number
     INTO l_lot_number
     FROM mtl_lot_numbers
    WHERE lot_number = p_lot_number
      AND inventory_item_id = p_inventory_item_id
      AND organization_id = p_org_id;
   RETURN TRUE;
EXCEPTION
   WHEN OTHERS THEN
      RETURN FALSE;
END does_lot_exist;


/* Added extra IN parameter p_issue_receipt to determine if the txn
 * is of type issue or receipt. For transaction_action_id = 12,
 * a value of 'IR' is passed, since for intransit receipt, though
 * it is a receipt txn, we need to display the serial attributes from
 * the source organization --bug 2756040
 */
 /* Bug 4328865: Added default value '@@@' for p_issue_receipt parameter*/


PROCEDURE get_attribute_values
(       x_lot_serial_attributes       OUT NOCOPY lot_sel_attributes_tbl_type
,       x_lot_serial_attributes_count OUT NOCOPY NUMBER
,       x_return_status               OUT NOCOPY VARCHAR2
,       x_msg_count                   OUT NOCOPY NUMBER
,       x_msg_data                    OUT NOCOPY VARCHAR2
,       p_table_name                  IN  VARCHAR2
,       p_attributes_name             IN  VARCHAR2
,       p_inventory_item_id           IN  NUMBER
,       p_organization_id             IN  NUMBER
,       p_lot_serial_number           IN  VARCHAR2
,       p_issue_receipt               IN  VARCHAR2 DEFAULT '@@@') IS

        l_sel_stmt       VARCHAR2(32067):= 'SELECT ' ;
        l_colnum         NUMBER         := 0;
        l_sql_p          INTEGER        :=  NULL;
        l_rows_processed INTEGER        :=  NULL;
        /* BUG 5334967 */
        l_precision      NUMBER         :=  0;
        l_index          NUMBER         :=  0;

        l_flexfield     fnd_dflex.dflex_r;
        l_flexinfo      fnd_dflex.dflex_dr;
        l_contexts_info fnd_dflex.contexts_dr;
        l_contexts      fnd_dflex.context_r;
        l_segments      fnd_dflex.segments_dr;
        l_attributes_category    VARCHAR2(50) :=NULL;
        l_global_code  VARCHAR2(50);
        l_rec_index BINARY_INTEGER := 0;

        l_count NUMBER;
        l_lot_serial_number VARCHAR2(240) := p_lot_serial_number;
        l_column_attributes INV_LOT_SEL_ATTR.LOT_SEL_ATTRIBUTES_TBL_TYPE;
        l_context_prompt fnd_descriptive_flexs_vl.form_context_prompt%TYPE; --bug 6636904
        l_context_column_name     VARCHAR2(240); --bug 2474713
        l_module_name VARCHAR2(25) := 'GET_ATTRIBUTE_VALUES';
        l_debug_level NUMBER := 9;
        l_status VARCHAR2(1);
        l_industry VARCHAR2(1);
        l_oracle_schema VARCHAR2(30);
        l_column_idx BINARY_INTEGER;
        l_default_format VARCHAR2(30) := 'YYYY/MM/DD HH24:MI:SS';
        l_date DATE;
        l_get_default BOOLEAN DEFAULT FALSE; -- true if we are to get the default values for the attributes
        l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
        l_ret boolean;

     cursor column_csr(p_table_name VARCHAR2, p_owner VARCHAR2) is
        select column_name, data_type, data_length
        from all_tab_columns
        where table_name = p_table_name
        and owner = p_owner
        order by column_id;


BEGIN

    IF (l_debug = 1) THEN
      inv_trx_util_pub.trace('inputs to get_attribute_values: ','INV_LOT_SEL_ATTR',9);
      inv_trx_util_pub.trace('p_table_name '      || p_table_name,'INV_LOT_SEL_ATTR',9);
      inv_trx_util_pub.trace('p_attributes_name  '|| p_attributes_name,'INV_LOT_SEL_ATTR',9);
      inv_trx_util_pub.trace('p_inventory_item_id '||p_inventory_item_id,'INV_LOT_SEL_ATTR',9);
      inv_trx_util_pub.trace('p_organization_id   '||p_organization_id,'INV_LOT_SEL_ATTR',9);
      inv_trx_util_pub.trace('p_lot_serial_number '||p_lot_serial_number,'INV_LOT_SEL_ATTR',9);
      inv_trx_util_pub.trace('p_issue_receipt '||p_issue_receipt,'INV_LOT_SEL_ATTR',9);
    END IF;
    fnd_dflex.get_flexfield('INV', p_attributes_name, l_flexfield, l_flexinfo);
    -- Get Contexts
    fnd_dflex.get_contexts(l_flexfield, l_contexts_info);
    --Retrieve the context column name also --bug#2474713
    l_context_column_name := l_flexinfo.context_column_name;
    --Adding for bug 6636904
    l_context_prompt := l_flexinfo.form_context_prompt;

    -- Commented entire block for bug 8315483
    /* Bug# 3418790
    Check whether we need to get the default attribtues or not based on the attribute name and
    transaction type */
    --IF (p_attributes_name = 'Serial Attributes') THEN
    --   /* Serial Attributes */
    --   IF(p_issue_receipt = 'R') THEN
    --      /* Serial Receipt...Get the default Attributes */
    --      l_get_default := TRUE;
    --   ELSIF (p_issue_receipt = 'I') THEN
    --      /* Serial Issue..Dont get the default values for the attribtues */
    --      l_get_default := FALSE;
    --   END IF;
    --ELSIF (p_attributes_name = 'Lot Attributes') THEN
    --   /* Lot Attributes */
    --   IF((p_issue_receipt = 'R') AND (does_lot_exist(p_lot_serial_number
    --                                                  ,p_inventory_item_id
    --                                                  ,p_organization_id) = FALSE)) THEN
    --      /* Lot attributes for Receipt and the Lot Number is new */
    --      l_get_default := TRUE;
    --   ELSE
    --      l_get_default := FALSE;
    --   END IF;
    --END IF;
    /* End of Bug# 3418790 */

    /* BUG 2756040 Get attributes category from MSN if not Receipt txn (except Intransit
     * Receipt) and the attributes are Serial Attributes
     */
    IF( p_issue_receipt <> 'R'
          --AND p_attributes_name = 'Serial Attributes'
       ) THEN
        IF (l_debug = 1)  THEN
           inv_trx_util_pub.trace('is not Receipt. calling the code to fetch from MSN or MLN depending on flex types');
        END IF;
        get_lot_serial_context(context_value => l_attributes_category
        ,    org_id         => p_organization_id
        ,    item_id    => p_inventory_item_id
        ,    p_lot_serial => p_lot_serial_number
        ,    flex_name      => p_attributes_name);
        IF (l_debug = 1) THEN
            inv_trx_util_pub.trace('got the context value ' || l_attributes_category);
        END IF;
    ELSE
        get_context_code(
         context_value       => l_attributes_category
        ,org_id              => p_organization_id
        ,item_id             => p_inventory_item_id
        ,flex_name           => p_attributes_name
        ,p_lot_serial_number => null);
    END IF;
    IF (l_debug=1) THEN
        debug('No of Contexts ' ||l_contexts_info.ncontexts ,l_module_name,l_debug_level);
    END IF;
    FOR i IN 1..l_contexts_info.ncontexts
    LOOP
        IF(l_contexts_info.is_enabled(i) AND ((UPPER(l_contexts_info.context_code(i)) = UPPER(l_attributes_category)) OR
            l_contexts_info.is_global(i))) THEN
            /*bug #2474713 insert the context column.. This was added because the descriptive flexfield window
            expects the context_value also*/
            IF(NOT(l_contexts_info.is_global(i))) THEN
                l_rec_index := l_rec_index + 1;
                x_lot_serial_attributes(l_rec_index).COLUMN_NAME := l_context_column_name;
                get_column_type(
                   p_table_name    => p_table_name,
                   p_column_name   => x_lot_serial_attributes(l_rec_index).COLUMN_NAME,
                   x_column_type     => x_lot_serial_attributes(l_rec_index).COLUMN_TYPE);
                x_lot_serial_attributes(l_rec_index).REQUIRED := 'TRUE';
                --Adding for bug 6636904
                x_lot_serial_attributes(l_rec_index).PROMPT   := l_context_prompt;
            END IF;    /*bug #2474713 */

            --Get segments
            l_contexts := fnd_dflex.make_context(l_flexfield, l_contexts_info.context_code(i));
            fnd_dflex.get_segments(l_contexts, l_segments, TRUE);
            ---dbms_output.put_line('number of segment is ' || l_segments.nsegments);
            IF (l_debug=1) THEN
               debug('No of Segments ' ||l_segments.nsegments ,l_module_name,l_debug_level);
            END IF;


            FOR j IN 1..l_segments.nsegments LOOP
                IF l_segments.is_enabled(j) THEN
                    l_rec_index := l_rec_index +1 ;
                    x_lot_serial_attributes(l_rec_index).COLUMN_NAME := l_segments.application_column_name(j);
                    IF (l_debug=1) THEN
                       debug('value set id is '||l_segments.value_set(j),l_module_name,l_debug_level);
                    END IF;
                    get_column_type( p_table_name   => p_table_name,
                      p_column_name   => x_lot_serial_attributes(l_rec_index).COLUMN_NAME,
                      x_column_type   => x_lot_serial_attributes(l_rec_index).COLUMN_TYPE);

                    IF(l_segments.is_required(j)) THEN
                      x_lot_serial_attributes(l_rec_index).REQUIRED := 'TRUE';
                    ELSE
                      x_lot_serial_attributes(l_rec_index).REQUIRED := 'FALSE';
                    END IF;

                    /* Bug# 3418790
                    Get the default values for the segments */
                    IF (l_debug=1) THEN
                          debug('Column Type ' ||x_lot_serial_attributes(l_rec_index).COLUMN_TYPE ,l_module_name,l_debug_level);
                          debug('Column Name ' ||x_lot_serial_attributes(l_rec_index).COLUMN_NAME ,l_module_name,l_debug_level);
                    END IF;

                    -- Bug 8315483
                    --IF(l_get_default = TRUE) THEN
                    IF l_segments.default_type(j) IS NOT NULL THEN
                        IF(x_lot_serial_attributes(l_rec_index).COLUMN_TYPE = 'DATE') THEN
                           IF (l_debug=1) THEN
                              debug('Default Type is ' || l_segments.default_type(j),l_module_name,l_debug_level);
                           END IF;
                           IF(l_segments.default_type(j) = 'D') THEN
                           /* Get the Value of the Current Date */
                              SELECT SYSDATE
                              INTO l_date
                              FROM dual;
                           ELSIF(l_segments.default_type(j) = 'C') THEN
                           /* Constant Value is default */
                              --l_date := to_date(l_segments.default_value(j),L_default_format);
                              l_date := fnd_date.canonical_to_date(l_segments.default_value(j));
                           END IF;
                           x_lot_serial_attributes(l_rec_index).COLUMN_VALUE := fnd_date.date_to_displayDT(l_date);
                        ELSE
                           x_lot_serial_attributes(l_rec_index).COLUMN_VALUE := l_segments.default_value(j);
                        END IF;
                    END IF;

                    --Adding for bug 6636904
                    x_lot_serial_attributes(l_rec_index).PROMPT := l_segments.row_prompt(j);
                END IF;
            END LOOP;

            IF (l_debug=1) THEN
               debug('No of Records ' ||l_rec_index ,l_module_name,l_debug_level);
               FOR j IN 1..l_rec_index  LOOP
                    debug('Column Name ' || x_lot_serial_attributes(j).COLUMN_NAME,l_module_name,l_debug_level);
                    debug('Column Value ' || x_lot_serial_attributes(j).COLUMN_VALUE,l_module_name,l_debug_level);
                    debug('Column Type ' || x_lot_serial_attributes(j).COLUMN_TYPE,l_module_name,l_debug_level);
               END LOOP;
            END IF;

            IF l_rec_index > 0 THEN

                l_sel_stmt      := 'SELECT ' ;
                l_column_idx := 0;
                l_ret := fnd_installation.get_app_info('INV', l_status, l_industry, l_oracle_schema);

                OPEN    column_csr(upper(p_table_name), l_oracle_schema);
                LOOP

                    l_column_idx := l_column_idx + 1;

                    FETCH column_csr INTO l_column_attributes(l_column_idx).column_name,
                        l_column_attributes(l_column_idx).column_type,
                        l_column_attributes(l_column_idx).column_length;
                    EXIT WHEN column_csr%NOTFOUND;
                    /*dbms_output.put_line (' column_csr: ' ||  l_column_attributes(l_column_idx).column_name||':'||
                    l_column_attributes(l_column_idx).column_type);*/
                    IF l_column_idx = 1 then
                       l_sel_stmt := l_sel_stmt || l_column_attributes(l_column_idx).column_name ;
                       --dbms_output.put_line (' l_sel_stmt'||l_sel_stmt);
                    ELSE
                        -- dbms_output.put_line (' l_endcol'||l_endcol);
                           l_sel_stmt := l_sel_stmt || ', ' || l_column_attributes(l_column_idx).column_name ;
                    END IF;

                END LOOP;
                CLOSE column_csr;

                IF p_table_name = 'MTL_LOT_NUMBERS' THEN
                    l_sel_stmt := l_sel_stmt || '  '  ||
                                 'from mtl_lot_numbers ' ||
                                 'where lot_number      = :b_lot_number ' ||
                                 'and inventory_item_id = :b_item_id ' ||
                                 'and organization_id   = :b_org_id ' ;
                ELSIF p_table_name = 'MTL_SERIAL_NUMBERS' THEN
                    l_sel_stmt := l_sel_stmt || '  '  ||
                                 'from mtl_serial_numbers ' ||
                                 'where serial_number   = :b_serial_number ' ||
                                 'and inventory_item_id = :b_item_id ' ||
                                 'and CURRENT_organization_id   = :b_org_id ' ;
                END IF;

                l_sql_p := DBMS_SQL.OPEN_CURSOR;

                DBMS_SQL.PARSE( l_sql_p, l_sel_stmt , DBMS_SQL.NATIVE );

                DBMS_SQL.BIND_VARIABLE(l_sql_p, 'b_org_id',     p_organization_id);
                DBMS_SQL.BIND_VARIABLE(l_sql_p, 'b_item_id',    p_inventory_item_id);

                IF p_table_name = 'MTL_LOT_NUMBERS' THEN
                   DBMS_SQL.BIND_VARIABLE(l_sql_p, 'b_lot_number', p_lot_serial_number);
                ELSIF p_table_name = 'MTL_SERIAL_NUMBERS' THEN
                   DBMS_SQL.BIND_VARIABLE(l_sql_p, 'b_serial_number', p_lot_serial_number);
                END IF;

                l_colnum := 0;
                --dbms_output.put_line ('Count(): ' ||  l_column_attributes.count());
                --dbms_output.put_line ('Count: ' ||  l_column_attributes.count);
                FOR y in 1..l_column_idx - 1 --Bug#8232936
                LOOP
                    l_colnum := l_colnum + 1;

                    IF  UPPER(l_column_attributes(y).column_type) = ('DATE') THEN
                       l_column_attributes(y).column_length := 10;
                    ELSIF UPPER(l_column_attributes(y).column_type) = 'NUMBER' THEN
                       l_column_attributes(y).column_length := 38;
                    END IF;
                    DBMS_SQL.DEFINE_COLUMN(l_sql_p, l_colnum, l_column_attributes(y).column_value,
                                           l_column_attributes(y).column_length);
                END LOOP;

                l_rows_processed := DBMS_SQL.EXECUTE(l_sql_p);
                IF (l_debug=1) THEN
                   debug('l_rows_processes = ' || l_rows_processed, l_module_name, l_debug_level);
                END IF;

                --Unnecessary loop
                --LOOP
                    IF (DBMS_SQL.FETCH_ROWS(l_sql_p) > 0 ) THEN
                        l_colnum := 0;
                        FOR y in 1..l_column_idx -1  --8232936
                        LOOP
                            l_colnum := l_colnum + 1;
                            DBMS_SQL.COLUMN_VALUE(l_sql_p, l_colnum, l_column_attributes(y).column_value);
                        END LOOP;
                    ELSE
                        IF (l_debug=1) THEN
                            debug('in the else part of dbms_sql.fetch_rows ' , l_module_name, l_debug_level);
                        END IF;
                           --dbms_sql.close_cursor(l_sql_p);
                        --EXIT;
                           /* we do'nt care, if no record is found */
                    END IF;
                    --EXIT;
                --END LOOP;

                dbms_sql.close_cursor(l_sql_p);

            END IF; -- IF l_rec_index > 0 THEN

            -- Bug 8315483 commented if l_get_default condition
            -- and added another condition in IF( upper(l_column_attributes(y)..

            --IF(l_get_Default = FALSE) THEN
            FOR x in 1.. l_rec_index LOOP
                FOR y IN 1..l_column_idx-1 LOOP --8232936
                    IF( upper(l_column_attributes(y).column_name) = upper(x_lot_serial_attributes(x).column_name)
                        AND (x_lot_serial_attributes(x).column_value IS NULL
                             OR l_column_attributes(y).column_value IS NOT NULL)) then


                        IF (l_debug=1) THEN
                            debug('column_name = ' || l_column_attributes(y).column_name, l_module_name, l_debug_level);
                            debug('column_TYPE = ' || x_lot_serial_attributes(x).column_type, l_module_name, l_debug_level);
                            debug(x,l_module_name,l_debug_level);
                        END IF;
                        IF(x_lot_serial_attributes(x).column_type = 'DATE') THEN
                            x_lot_serial_attributes(x).column_value := fnd_date.date_to_displayDT(l_column_attributes(y).column_value);

                        /* BUG 5334967 added the ELSIF condition for checking if the column type is NUMBER*/
                        ELSIF (x_lot_serial_attributes(x).column_type = 'NUMBER') THEN
                            IF (l_debug=1) THEN
                              debug('in NUMBER', l_module_name, l_debug_level);
                            END IF;

                            x_lot_serial_attributes(x).column_value := l_column_attributes(y).column_value;

                            FOR i in 1..l_segments.nsegments LOOP
                                /* When you find that the application col name = sement column name, exit.
                                The index thus obtained will be used  for the value set in getting the precision */
                                IF l_segments.application_column_name(i) = l_column_attributes(y).column_name THEN
                                   l_index := i;
                                   EXIT;
                                END IF;
                            END LOOP;
                            IF (l_debug=1) THEN
                              debug('Index = ' || l_index, l_module_name, l_debug_level);
                              debug('col index = ' || l_segments.value_set(l_index), l_module_name, l_debug_level);
                            END IF;
                            /*getting the precision for segment value of type Number*/
                            SELECT number_precision INTO l_precision
                            FROM FND_FLEX_VALUE_SETS
                            WHERE flex_value_set_id = l_segments.value_set(l_index);

                            IF (l_debug=1) THEN
                              debug('PRECISION = ' || l_precision, l_module_name, l_debug_level);
                            END IF;
                            IF (l_precision >0) THEN
                              SELECT round(x_lot_serial_attributes(x).column_value, l_precision)
                              INTO x_lot_serial_attributes(x).column_value
                              FROM DUAL;
                            END IF;
                            IF (l_debug=1) THEN
                              debug('column_value1 = ' || x_lot_serial_attributes(x).column_value, l_module_name, l_debug_level);
                            END IF;
                        /* End of changes for BUG 5334967 */
                        ELSE
                            x_lot_serial_attributes(x).column_value := l_column_attributes(y).column_value;
                            IF (l_debug=1) THEN
                              debug('In ELSE ' ,l_module_name, l_debug_level);
                            END IF;
                        END IF;
                        EXIT;
                    END IF;
                END LOOP;
            END LOOP;
            --END IF; bug 8315483
        END IF;
    END LOOP;
    -- assign it to the out variable
    x_lot_serial_attributes_count := l_rec_index;
    x_return_status := fnd_api.g_ret_sts_success;

EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error ;

    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

    WHEN others THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error ;
      IF (fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, 'GET_ATTRIBUTE_VALUES');
      END IF;
END get_attribute_values;


PROCEDURE get_dflex_context(
  x_context   OUT NOCOPY t_genref,
  p_application_id IN NUMBER,
  p_flex_name IN VARCHAR2) IS

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
    OPEN x_context FOR
  SELECT descriptive_flex_context_code, descriptive_flex_context_name,
      global_flag, enabled_flag
  FROM  fnd_descr_flex_contexts_vl
  WHERE   application_id = p_application_id
  AND descriptive_flexfield_name = p_flex_name;

END get_dflex_context;

PROCEDURE get_dflex_segment(
  x_segment OUT NOCOPY t_genref,
  p_application_id IN NUMBER,
  p_flex_name  IN VARCHAR2,
  p_flex_context_code IN VARCHAR2) IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
    OPEN x_segment FOR
      SELECT  end_user_column_name, application_column_name, enabled_flag,
        required_flag, default_type, default_value
      FROM    fnd_descr_flex_col_usage_vl
      WHERE   application_id = p_application_id
      AND descriptive_flexfield_name = p_flex_name
      AND descriptive_flex_context_code = p_flex_context_code;

END get_dflex_segment;

---J Develop
/* New Procedure to get the Inventory Attributes */
procedure get_inv_lot_attributes( x_return_status   OUT NOCOPY VARCHAR2
                                                   ,x_msg_count          OUT NOCOPY NUMBER
                                                   ,x_msg_data           OUT NOCOPY VARCHAR2
                                                   ,x_inv_lot_attributes OUT NOCOPY inv_lot_sel_attr.lot_sel_attributes_tbl_type
                                                   ,P_inventory_item_id  IN  NUMBER
                                                   ,P_LOT_NUMBER         IN  VARCHAR2
                                                   ,p_organization_id    IN  NUMBER
                                                   ,p_attribute_category IN VARCHAR2
                                                    )

IS
  TYPE inv_lot_attr IS TABLE OF VARCHAR2(1000) INDEX BY BINARY_INTEGER;
  l_inv_lot_attr inv_lot_attr;

  CURSOR inv_attr IS
     SELECT attribute1
           ,attribute2
           ,attribute3
           ,attribute4
           ,attribute5
           ,attribute6
           ,attribute7
           ,attribute8
           ,attribute9
           ,attribute10
           ,attribute11
           ,attribute12
           ,attribute13
           ,attribute14
           ,attribute15
     FROM mtl_lot_numbers
     WHERE inventory_item_id    = p_inventory_item_id
           AND organization_id  = p_organization_id
           AND lot_number       = p_lot_number;

    l_inv_attr            inv_attr%ROWTYPE;
    l_context             VARCHAR2(1000);
    l_context_r           fnd_dflex.context_r;
    l_contexts_dr         fnd_dflex.contexts_dr;
    l_dflex_r             fnd_dflex.dflex_r;
    l_segments_dr         fnd_dflex.segments_dr;
    l_global_context      BINARY_INTEGER;
    l_nsegments           BINARY_INTEGER;

BEGIN

   OPEN inv_attr;
   FETCH inv_attr INTO l_inv_attr;

   /* Fill the lot data into l_inv_lot_attr table */
   l_inv_lot_attr(1) := l_inv_attr.attribute1;
   l_inv_lot_attr(2) := l_inv_attr.attribute2;
   l_inv_lot_attr(3) := l_inv_attr.attribute3;
   l_inv_lot_attr(4) := l_inv_attr.attribute4;
   l_inv_lot_attr(5) := l_inv_attr.attribute5;
   l_inv_lot_attr(6) := l_inv_attr.attribute6;
   l_inv_lot_attr(7) := l_inv_attr.attribute7;
   l_inv_lot_attr(8) := l_inv_attr.attribute8;
   l_inv_lot_attr(9) := l_inv_attr.attribute9;
   l_inv_lot_attr(10) := l_inv_attr.attribute10;
   l_inv_lot_attr(11) := l_inv_attr.attribute11;
   l_inv_lot_attr(12) := l_inv_attr.attribute12;
   l_inv_lot_attr(13) := l_inv_attr.attribute13;
   l_inv_lot_attr(14) := l_inv_attr.attribute14;
   l_inv_lot_attr(15) := l_inv_attr.attribute15;
   CLOSE inv_attr;

   x_return_status := 'S';
   l_dflex_r.application_id  := 401;
   l_dflex_r.flexfield_name  := 'MTL_LOT_NUMBERS';
   fnd_dflex.get_contexts(flexfield => l_dflex_r, contexts => l_contexts_dr);
   l_global_context          := l_contexts_dr.global_context;
    l_context                 := l_contexts_dr.context_code(l_global_context);

    /* Prepare the context_r type for getting the segments associated with the global context */
    l_context_r.flexfield     := l_dflex_r;
    l_context_r.context_code  := l_context;

    fnd_dflex.get_segments(CONTEXT => l_context_r, segments => l_segments_dr, enabled_only => TRUE);

    /* read through the segments */

    l_nsegments               := l_segments_dr.nsegments;
    FOR j IN 1..l_nsegments LOOP
       x_inv_lot_attributes(substr(l_segments_dr.application_column_name(j),instr(l_segments_dr.application_column_name(j),'ATTRIBUTE')+9)).column_name :=l_segments_dr.application_column_name(j);
       x_inv_lot_attributes(substr(l_segments_dr.application_column_name(j),instr(l_segments_dr.application_column_name(j),'ATTRIBUTE')+9)).column_type :='VARCHAR2';
       IF  l_segments_dr.is_required(j) THEN
          x_inv_lot_attributes(substr(l_segments_dr.application_column_name(j),instr(l_segments_dr.application_column_name(j),'ATTRIBUTE')+9)).required :='TRUE';
       ELSE
          x_inv_lot_attributes(substr(l_segments_dr.application_column_name(j),instr(l_segments_dr.application_column_name(j),'ATTRIBUTE')+9)).required :='FALSE';
       END IF;
       x_inv_lot_attributes(substr(l_segments_dr.application_column_name(j),instr(l_segments_dr.application_column_name(j),'ATTRIBUTE')+9)).column_length :=150;
       x_inv_lot_attributes(substr(l_segments_dr.application_column_name(j),instr(l_segments_dr.application_column_name(j),'ATTRIBUTE')+9)).column_value :=
              l_inv_lot_attr(substr(l_segments_dr.application_column_name(j),instr(l_segments_dr.application_column_name(j),'ATTRIBUTE')+9));
    END LOOP;
    l_context   := NULL;
    l_nsegments := NULL;

    IF p_attribute_category IS NOT NULL  THEN

       l_context := p_attribute_category;

       /* Prepare the context_r type for getting the segments associated with the input context */

       l_context_r.flexfield     := l_dflex_r;
       l_context_r.context_code  := l_context;

       fnd_dflex.get_segments(CONTEXT => l_context_r, segments => l_segments_dr, enabled_only => TRUE);
       l_nsegments               := l_segments_dr.nsegments;
       FOR i IN 1..l_nsegments LOOP

          x_inv_lot_attributes(substr(l_segments_dr.application_column_name(i),instr(l_segments_dr.application_column_name(i),'ATTRIBUTE')+9)).column_name :=l_segments_dr.application_column_name(i);
          x_inv_lot_attributes(substr(l_segments_dr.application_column_name(i),instr(l_segments_dr.application_column_name(i),'ATTRIBUTE')+9)).column_type :='VARCHAR2';
          IF  l_segments_dr.is_required(i) THEN
             x_inv_lot_attributes(substr(l_segments_dr.application_column_name(i),instr(l_segments_dr.application_column_name(i),'ATTRIBUTE')+9)).required :='TRUE';
          ELSE
             x_inv_lot_attributes(substr(l_segments_dr.application_column_name(i),instr(l_segments_dr.application_column_name(i),'ATTRIBUTE')+9)).required :='FALSE';
          END IF;
          x_inv_lot_attributes(substr(l_segments_dr.application_column_name(i),instr(l_segments_dr.application_column_name(i),'ATTRIBUTE')+9)).column_length :=150;
          x_inv_lot_attributes(substr(l_segments_dr.application_column_name(i),instr(l_segments_dr.application_column_name(i),'ATTRIBUTE')+9)).column_value :=
            l_inv_lot_attr(substr(l_segments_dr.application_column_name(i),instr(l_segments_dr.application_column_name(i),'ATTRIBUTE')+9));
       END LOOP;
    END IF;
END get_inv_lot_attributes;

procedure get_inv_serial_attributes( x_return_status         OUT NOCOPY VARCHAR2
                                    ,x_msg_count             OUT NOCOPY NUMBER
                                    ,x_msg_data              OUT NOCOPY VARCHAR2
                                    ,x_inv_serial_attributes OUT NOCOPY inv_lot_sel_attr.lot_sel_attributes_tbl_type
            ,x_concatenated_values   OUT NOCOPY VARCHAR2
                                    ,P_inventory_item_id     IN  NUMBER
                                    ,P_SERIAL_NUMBER         IN  VARCHAR2
                                    ,p_attribute_category    IN VARCHAR2
            ,p_transaction_temp_id   IN  NUMBER DEFAULT NULL
            ,p_transaction_source    IN  VARCHAR2 DEFAULT NULL
                                                    )

IS
  TYPE inv_serial_attr IS TABLE OF VARCHAR2(150) INDEX BY BINARY_INTEGER;
  l_inv_serial_attr inv_serial_attr;

  CURSOR inv_attr IS
     SELECT attribute1
           ,attribute2
           ,attribute3
           ,attribute4
           ,attribute5
           ,attribute6
           ,attribute7
           ,attribute8
           ,attribute9
           ,attribute10
           ,attribute11
           ,attribute12
           ,attribute13
           ,attribute14
           ,attribute15
     FROM mtl_SERIAL_numbers
     WHERE inventory_item_id    = p_inventory_item_id
           AND SERIAL_number       =  p_serial_number;
/*
    CURSOR inv_ship_attr IS
  SELECT nvl(msn.attribute1, msnt.attribute1) attribute1
        , nvl(msn.attribute2, msnt.attribute2) attribute2
        , nvl(msn.attribute3, msnt.attribute3) attribute3
        , nvl(msn.attribute4, msnt.attribute4) attribute4
        , nvl(msn.attribute5, msnt.attribute5) attribute5
        , nvl(msn.attribute6, msnt.attribute6) attribute6
        , nvl(msn.attribute7, msnt.attribute7) attribute7
        , nvl(msn.attribute8, msnt.attribute8) attribute8
        , nvl(msn.attribute9, msnt.attribute9) attribute9
        , nvl(msn.attribute10, msnt.attribute10) attribute10
        , nvl(msn.attribute11, msnt.attribute11) attribute11
        , nvl(msn.attribute12, msnt.attribute12) attribute12
        , nvl(msn.attribute13, msnt.attribute13) attribute13
        , nvl(msn.attribute14, msnt.attribute14) attribute14
        , nvl(msn.attribute15, msnt.attribute15) attribute15
  FROM mtl_serial_numbers msn, mtl_serial_numbers_temp msnt
  WHERE msn.inventory_item_id = p_inventory_item_id
  AND   msn.serial_number = p_serial_number
  AND   msnt.transaction_temp_id = p_transaction_temp_id
  AND   msnt.fm_serial_number  = p_serial_number
  AND   msn.serial_number = msnt.fm_serial_number;
*/
/* Commented the above cursor and the following cursor for Bug 3839336 */
   CURSOR inv_ship_attr IS
   SELECT msnt.attribute1 attribute1
         ,msnt.attribute2 attribute2
         ,msnt.attribute3 attribute3
         ,msnt.attribute4 attribute4
         ,msnt.attribute5 attribute5
         ,msnt.attribute6 attribute6
         ,msnt.attribute7 attribute7
         ,msnt.attribute8 attribute8
         ,msnt.attribute9 attribute9
         ,msnt.attribute10 attribute10
         ,msnt.attribute11 attribute11
         ,msnt.attribute12 attribute12
         ,msnt.attribute13 attribute13
         ,msnt.attribute14 attribute14
         ,msnt.attribute15 attribute15
   FROM mtl_serial_numbers msn, mtl_serial_numbers_temp msnt
   WHERE msn.inventory_item_id = p_inventory_item_id
   AND   msn.serial_number = p_serial_number
   AND   msnt.transaction_temp_id = p_transaction_temp_id
   AND   msnt.fm_serial_number  = p_serial_number
  AND   msn.serial_number = msnt.fm_serial_number;


    l_inv_attr            inv_attr%ROWTYPE;
    l_inv_ship_attr       inv_ship_attr%ROWTYPE;
    l_context             VARCHAR2(1000);
    l_context_r           fnd_dflex.context_r;
    l_contexts_dr         fnd_dflex.contexts_dr;
    l_dflex_r             fnd_dflex.dflex_r;
    l_segments_dr         fnd_dflex.segments_dr;
    l_global_context      BINARY_INTEGER;
    l_nsegments           BINARY_INTEGER;

BEGIN

   debug('Inside get_inv_serial_attributes', 'GET_INV_SERIAL_ATTR', 10);
   debug('p_transaction_source is ' || p_transaction_source, 'GET_INV_SERIAL_ATTR', 10);
   debug('p_serial_number is ' || p_serial_number, 'GET_INV_SERIAL_ATTR', 10);
   debug('p_inventory_item_id is '|| p_inventory_item_id, 'GET_INV_SERIAL_ATTR', 10);
   debug('p_transaction_temp_id is ' || p_transaction_temp_id, 'GET_INV_SERIAL_ATTR', 10);

   IF (nvl(p_transaction_source, 'INV') = 'WSH') THEN
     debug('OPEN inv_ship_attr', 'GET_INV_SERIAL_ATTR', 9);
    if( p_transaction_temp_id is null ) THEN
      BEGIN
       open inv_attr;
       FETCH inv_attr INTO l_inv_attr;
      EXCEPTION
        when no_data_found then
          l_inv_attr.attribute1 := null;
          l_inv_attr.attribute2 := null;
          l_inv_attr.attribute3 := null;
          l_inv_attr.attribute4 := null;
          l_inv_attr.attribute5 := null;
          l_inv_attr.attribute6 := null;
          l_inv_attr.attribute7 := null;
          l_inv_attr.attribute8 := null;
          l_inv_attr.attribute9 := null;
          l_inv_attr.attribute10 := null;
          l_inv_attr.attribute11 := null;
          l_inv_attr.attribute12 := null;
          l_inv_attr.attribute13 := null;
          l_inv_attr.attribute14 := null;
          l_inv_attr.attribute15 := null;
      END;
    else
      BEGIN
       OPEN inv_ship_attr;
       FETCH inv_ship_attr INTO l_inv_ship_attr;
      EXCEPTION
        WHEN no_data_found then
          l_inv_ship_attr.attribute1 := null;
          l_inv_ship_attr.attribute2 := null;
          l_inv_ship_attr.attribute3 := null;
          l_inv_ship_attr.attribute4 := null;
          l_inv_ship_attr.attribute5 := null;
          l_inv_ship_attr.attribute6 := null;
          l_inv_ship_attr.attribute7 := null;
          l_inv_ship_attr.attribute8 := null;
          l_inv_ship_attr.attribute9 := null;
          l_inv_ship_attr.attribute10 := null;
          l_inv_ship_attr.attribute11 := null;
          l_inv_ship_attr.attribute12 := null;
          l_inv_ship_attr.attribute13 := null;
          l_inv_ship_attr.attribute14 := null;
          l_inv_ship_attr.attribute15 := null;
      END;
    end if;
   ELSE
    --Bug #3765098 ( If txn temp id  has value , the retrive the attr from msnt
    -- or get the attr from msn)
    if( p_transaction_temp_id is null ) THEN
      BEGIN
        OPEN inv_attr;
        FETCH inv_attr INTO l_inv_attr;
      EXCEPTION
        when no_data_found then
          l_inv_attr.attribute1 := null;
          l_inv_attr.attribute2 := null;
          l_inv_attr.attribute3 := null;
          l_inv_attr.attribute4 := null;
          l_inv_attr.attribute5 := null;
          l_inv_attr.attribute6 := null;
          l_inv_attr.attribute7 := null;
          l_inv_attr.attribute8 := null;
          l_inv_attr.attribute9 := null;
          l_inv_attr.attribute10 := null;
          l_inv_attr.attribute11 := null;
          l_inv_attr.attribute12 := null;
          l_inv_attr.attribute13 := null;
          l_inv_attr.attribute14 := null;
          l_inv_attr.attribute15 := null;
        end;
    else
      BEGIN
        OPEN inv_ship_attr;
        FETCH inv_ship_attr INTO l_inv_ship_attr;
      EXCEPTION
        WHEN no_data_found then
          l_inv_ship_attr.attribute1 := null;
          l_inv_ship_attr.attribute2 := null;
          l_inv_ship_attr.attribute3 := null;
          l_inv_ship_attr.attribute4 := null;
          l_inv_ship_attr.attribute5 := null;
          l_inv_ship_attr.attribute6 := null;
          l_inv_ship_attr.attribute7 := null;
          l_inv_ship_attr.attribute8 := null;
          l_inv_ship_attr.attribute9 := null;
          l_inv_ship_attr.attribute10 := null;
          l_inv_ship_attr.attribute11 := null;
          l_inv_ship_attr.attribute12 := null;
          l_inv_ship_attr.attribute13 := null;
          l_inv_ship_attr.attribute14 := null;
          l_inv_ship_attr.attribute15 := null;
      END;
    end if;
   END IF;

   IF (nvl(p_transaction_source, 'INV') = 'WSH') THEN
     if( p_transaction_temp_id is not null ) then
       l_inv_serial_attr(1) := l_inv_ship_attr.attribute1;
       l_inv_serial_attr(2) := l_inv_ship_attr.attribute2;
       l_inv_serial_attr(3) := l_inv_ship_attr.attribute3;
       l_inv_serial_attr(4) := l_inv_ship_attr.attribute4;
       l_inv_serial_attr(5) := l_inv_ship_attr.attribute5;
       l_inv_serial_attr(6) := l_inv_ship_attr.attribute6;
       l_inv_serial_attr(7) := l_inv_ship_attr.attribute7;
       l_inv_serial_attr(8) := l_inv_ship_attr.attribute8;
       l_inv_serial_attr(9) := l_inv_ship_attr.attribute9;
       l_inv_serial_attr(10) := l_inv_ship_attr.attribute10;
       l_inv_serial_attr(11) := l_inv_ship_attr.attribute11;
       l_inv_serial_attr(12) := l_inv_ship_attr.attribute12;
       l_inv_serial_attr(13) := l_inv_ship_attr.attribute13;
       l_inv_serial_attr(14) := l_inv_ship_attr.attribute14;
       l_inv_serial_attr(15) := l_inv_ship_attr.attribute15;
       CLOSE inv_ship_attr;
     else
       l_inv_serial_attr(1) := l_inv_attr.attribute1;
       l_inv_serial_attr(2) := l_inv_attr.attribute2;
       l_inv_serial_attr(3) := l_inv_attr.attribute3;
       l_inv_serial_attr(4) := l_inv_attr.attribute4;
       l_inv_serial_attr(5) := l_inv_attr.attribute5;
       l_inv_serial_attr(6) := l_inv_attr.attribute6;
       l_inv_serial_attr(7) := l_inv_attr.attribute7;
       l_inv_serial_attr(8) := l_inv_attr.attribute8;
       l_inv_serial_attr(9) := l_inv_attr.attribute9;
       l_inv_serial_attr(10) := l_inv_attr.attribute10;
       l_inv_serial_attr(11) := l_inv_attr.attribute11;
       l_inv_serial_attr(12) := l_inv_attr.attribute12;
       l_inv_serial_attr(13) := l_inv_attr.attribute13;
       l_inv_serial_attr(14) := l_inv_attr.attribute14;
       l_inv_serial_attr(15) := l_inv_attr.attribute15;
       CLOSE inv_attr;
     end if;
   ELSE
    --Bug #3765098 ( If txn temp id  has value , the retrive the attr from msnt
    -- or get the attr from msn)
    if( p_transaction_temp_id is not null ) then
       l_inv_serial_attr(1)  := l_inv_ship_attr.attribute1;
       l_inv_serial_attr(2)  := l_inv_ship_attr.attribute2;
       l_inv_serial_attr(3)  := l_inv_ship_attr.attribute3;
       l_inv_serial_attr(4)  := l_inv_ship_attr.attribute4;
       l_inv_serial_attr(5)  := l_inv_ship_attr.attribute5;
       l_inv_serial_attr(6)  := l_inv_ship_attr.attribute6;
       l_inv_serial_attr(7)  := l_inv_ship_attr.attribute7;
       l_inv_serial_attr(8)  := l_inv_ship_attr.attribute8;
       l_inv_serial_attr(9)  := l_inv_ship_attr.attribute9;
       l_inv_serial_attr(10) := l_inv_ship_attr.attribute10;
       l_inv_serial_attr(11) := l_inv_ship_attr.attribute11;
       l_inv_serial_attr(12) := l_inv_ship_attr.attribute12;
       l_inv_serial_attr(13) := l_inv_ship_attr.attribute13;
       l_inv_serial_attr(14) := l_inv_ship_attr.attribute14;
       l_inv_serial_attr(15) := l_inv_ship_attr.attribute15;
       CLOSE inv_ship_attr;
     else
       l_inv_serial_attr(1)  := l_inv_attr.attribute1;
       l_inv_serial_attr(2)  := l_inv_attr.attribute2;
       l_inv_serial_attr(3)  := l_inv_attr.attribute3;
       l_inv_serial_attr(4)  := l_inv_attr.attribute4;
       l_inv_serial_attr(5)  := l_inv_attr.attribute5;
       l_inv_serial_attr(6)  := l_inv_attr.attribute6;
       l_inv_serial_attr(7)  := l_inv_attr.attribute7;
       l_inv_serial_attr(8)  := l_inv_attr.attribute8;
       l_inv_serial_attr(9)  := l_inv_attr.attribute9;
       l_inv_serial_attr(10) := l_inv_attr.attribute10;
       l_inv_serial_attr(11) := l_inv_attr.attribute11;
       l_inv_serial_attr(12) := l_inv_attr.attribute12;
       l_inv_serial_attr(13) := l_inv_attr.attribute13;
       l_inv_serial_attr(14) := l_inv_attr.attribute14;
       l_inv_serial_attr(15) := l_inv_attr.attribute15;
       CLOSE inv_attr;
     end if;
   END IF;

   x_return_status := 'S';
   l_dflex_r.application_id  := 401;
   l_dflex_r.flexfield_name  := 'MTL_SERIAL_NUMBERS';
   fnd_dflex.get_contexts(flexfield => l_dflex_r, contexts => l_contexts_dr);
   l_global_context          := l_contexts_dr.global_context;
   l_context                 := l_contexts_dr.context_code(l_global_context);

    /* Prepare the context_r type for getting the segments associated with the global context */
    l_context_r.flexfield     := l_dflex_r;
    l_context_r.context_code  := l_context;

    fnd_dflex.get_segments(CONTEXT => l_context_r, segments => l_segments_dr, enabled_only => TRUE);
    debug('after calling fnd_dflex.get_segments', 'GET_INV_SERIAL_ATTR', 9);

    /* read through the segments */

    l_nsegments               := l_segments_dr.nsegments;
    FOR j IN 1..l_nsegments LOOP
       debug('j = ' || j, 'GET_INV_SERIAL_ATTR', 9);
  debug('column application name is ' || l_segments_dr.application_column_name(j), 'GET_INV_SERIAL_ATTR', 9);
        debug(substr(l_segments_dr.application_column_name(j), instr(l_segments_dr.application_column_name(j), 'ATTRIBUTE')+9), 'GET_INV_SERIAL_ATTR', 9);

       x_inv_serial_attributes(
     substr(l_segments_dr.application_column_name(j),
       instr(l_segments_dr.application_column_name(j),'ATTRIBUTE')+9)).column_name :=
      l_segments_dr.application_column_name(j);
       x_inv_serial_attributes(substr(l_segments_dr.application_column_name(j),
           instr(l_segments_dr.application_column_name(j),'ATTRIBUTE')+9)).column_type :='VARCHAR2';
       IF  l_segments_dr.is_required(j) THEN
          x_inv_serial_attributes(substr(l_segments_dr.application_column_name(j),
      instr(l_segments_dr.application_column_name(j),'ATTRIBUTE')+9)).required :='TRUE';
       ELSE
          x_inv_serial_attributes(substr(l_segments_dr.application_column_name(j),
      instr(l_segments_dr.application_column_name(j),'ATTRIBUTE')+9)).required :='FALSE';
       END IF;
       x_inv_serial_attributes(substr(l_segments_dr.application_column_name(j),
      instr(l_segments_dr.application_column_name(j),'ATTRIBUTE')+9)).column_length :=150;
       x_inv_serial_attributes(substr(l_segments_dr.application_column_name(j),
    instr(l_segments_dr.application_column_name(j),'ATTRIBUTE')+9)).column_value :=
        l_inv_serial_attr(substr(l_segments_dr.application_column_name(j),
      instr(l_segments_dr.application_column_name(j),'ATTRIBUTE')+9));
  fnd_flex_descval.set_column_value(l_segments_dr.application_column_name(j),
    l_inv_serial_attr(substr(l_segments_dr.application_column_name(j),
      instr(l_segments_dr.application_column_name(j), 'ATTRIBUTE')+9)));
    END LOOP;
    l_context   := NULL;
    l_nsegments := NULL;

    IF p_attribute_category IS NOT NULL  THEN
        debug('getting context specific segments', 'GET_INV_SERIAL_ATTR', 9);
        l_context := p_attribute_category;
  debug('setting context value ' || l_context, 'GET_INV_SERIAL_ATTR', 9);
  fnd_flex_descval.set_context_value(l_context);

       /* Prepare the context_r type for getting the segments associated with the input context */

       l_context_r.flexfield     := l_dflex_r;
       l_context_r.context_code  := l_context;

       fnd_dflex.get_segments(CONTEXT => l_context_r, segments => l_segments_dr, enabled_only => TRUE);
       l_nsegments               := l_segments_dr.nsegments;
       FOR i IN 1..l_nsegments LOOP
          debug('application column name is ' || l_segments_dr.application_column_name(i), 'GET_INV_SERIAL_ATTR', 9);
          x_inv_serial_attributes(substr(l_segments_dr.application_column_name(i),
    instr(l_segments_dr.application_column_name(i),'ATTRIBUTE')+9)).column_name :=
      l_segments_dr.application_column_name(i);
          x_inv_serial_attributes(substr(l_segments_dr.application_column_name(i),
      instr(l_segments_dr.application_column_name(i),'ATTRIBUTE')+9)).column_type :='VARCHAR2';
          IF  l_segments_dr.is_required(i) THEN
             x_inv_serial_attributes(substr(l_segments_dr.application_column_name(i),
      instr(l_segments_dr.application_column_name(i),'ATTRIBUTE')+9)).required :='TRUE';
          ELSE
             x_inv_serial_attributes(substr(l_segments_dr.application_column_name(i),
      instr(l_segments_dr.application_column_name(i),'ATTRIBUTE')+9)).required :='FALSE';
          END IF;
          x_inv_serial_attributes(substr(l_segments_dr.application_column_name(i),
      instr(l_segments_dr.application_column_name(i),'ATTRIBUTE')+9)).column_length :=150;
          x_inv_serial_attributes(substr(l_segments_dr.application_column_name(i),
      instr(l_segments_dr.application_column_name(i),'ATTRIBUTE')+9)).column_value :=
        l_inv_serial_attr(substr(l_segments_dr.application_column_name(i),
          instr(l_segments_dr.application_column_name(i),'ATTRIBUTE')+9));
  fnd_flex_descval.set_column_value(l_segments_dr.application_column_name(i),
    l_inv_serial_attr(substr(l_segments_dr.application_column_name(i),
      instr(l_segments_dr.application_column_name(i), 'ATTRIBUTE')+9)));
       END LOOP;
    END IF;

    IF ( p_attribute_Category IS NULL ) then
  l_context := l_contexts_dr.context_code(l_global_context);
        fnd_flex_descval.set_context_value(l_context);
    end if;
    debug('calling fnd_flex_descval.concatenated_values', 'GET_INV_SERIAL_ATTR', 9);
    IF fnd_flex_descval.validate_desccols(appl_short_name => 'INV',
    desc_flex_name => 'MTL_SERIAL_NUMBERS', values_or_ids => 'I' , validation_date  => SYSDATE) THEN
        x_concatenated_values := fnd_flex_descval.concatenated_values;
    ELSE

  x_concatenated_values := null;
  FND_MESSAGE.SET_NAME('INV', 'INV_FND_GENERIC_MSG');
  FND_MESSAGE.SET_TOKEN('MSG', fnd_flex_descval.error_message);
        FND_MSG_PUB.ADD;
        raise fnd_api.g_exc_unexpected_error;
    END IF;
    debug('after getting x_concatenated_values ' || x_concatenated_values, 'GET_INV_SERIAL_ATTR', 9);
EXCEPTION
    when no_data_found THEN
  null;
    when FND_API.G_EXC_UNEXPECTED_ERROR THEN
  x_return_status := 'U';
  fnd_msg_pub.count_and_get(p_encoded => FND_API.G_FALSE, p_count => x_msg_count, p_data => x_msg_data);
    when others then
  x_return_status := 'U';
  fnd_msg_pub.count_and_get(p_encoded => FND_API.G_FALSE, p_count => x_msg_count, p_data => x_msg_data);
END get_inv_serial_attributes;

  --  Bug 7350762 Code changes start

FUNCTION is_lot_attributes_required( p_flex_name IN VARCHAR2,
                               p_organization_id IN NUMBER,
                               p_inventory_item_id IN NUMBER,
                               p_lot_number IN VARCHAR2)  RETURN BOOLEAN IS

  c_api_name CONSTANT VARCHAR2(30) := 'is_lot_attributes_required';
  v_flexfield   fnd_dflex.dflex_r;
  v_flexinfo  fnd_dflex.dflex_dr;
  v_contexts  fnd_dflex.contexts_dr;
  v_segments  fnd_dflex.segments_dr;
  v_attributes_category VARCHAR2(50) := NULL;

  i   BINARY_INTEGER;
  j   BINARY_INTEGER;
  l_cursor_handle  NUMBER;
  l_rows_affected  NUMBER;
  l_lot_att_required           BOOLEAN := FALSE;
  l_where_clause          VARCHAR2(2000) := NULL;
  l_lot_exist             NUMBER         := 0;
  l_context_req_flag      VARCHAR2(1)    := 'N';
  l_attribute_category    VARCHAR2(255)  := NULL;

BEGIN

    l_lot_exist := 0;

    IF (UPPER(p_flex_name) = 'MTL_LOT_NUMBERS') THEN

        BEGIN
            SELECT 1
                 , attribute_category
            INTO   l_lot_exist
                 , l_attribute_category
            FROM mtl_lot_numbers
            WHERE organization_id = p_organization_id
            AND inventory_item_id = p_inventory_item_id
            AND lot_number = p_lot_number;
        EXCEPTION
            WHEN no_data_found THEN
                l_lot_exist  := 0;
        END;

    ELSIF (UPPER(p_flex_name) = 'LOT ATTRIBUTES') THEN

        BEGIN
            SELECT 1
                 , lot_attribute_category
            INTO   l_lot_exist
                 , l_attribute_category
            FROM mtl_lot_numbers
            WHERE organization_id = p_organization_id
            AND inventory_item_id = p_inventory_item_id
            AND lot_number = p_lot_number;
        EXCEPTION
            WHEN no_data_found THEN
                l_lot_exist  := 0;
        END;

    END IF;

    BEGIN
      SELECT  df.context_required_flag
      INTO    l_context_req_flag
      FROM    fnd_application_vl a, fnd_descriptive_flexs_vl df
      WHERE   a.application_short_name = 'INV'
      AND     df.application_id = a.application_id
      AND     df.descriptive_flexfield_name = p_flex_name
      AND     a.application_id = df.table_application_id;
    EXCEPTION
      WHEN no_data_found THEN
        l_context_req_flag  := 'N';
    END;


    IF ((l_lot_exist = 1 AND l_context_req_flag = 'Y' AND l_attribute_category IS NULL)  OR
        (l_lot_exist = 0 AND l_context_req_flag = 'Y')) THEN
        l_lot_att_required := TRUE;
    ELSE

        -- Get flexfield
        fnd_dflex.get_flexfield('INV', p_flex_name, v_flexfield, v_flexinfo);

        -- Get Contexts
        fnd_dflex.get_contexts(v_flexfield, v_contexts);

        -- Get attributes category
        get_context_code(
              context_value         => v_attributes_category
            , org_id                => p_organization_id
            , item_id               => p_inventory_item_id
            , flex_name             => p_flex_name
            , p_lot_serial_number   => null);

        <<contextLoop>>
        FOR i IN 1..v_contexts.ncontexts LOOP
            IF(v_contexts.is_enabled(i) AND
               ((UPPER(v_contexts.context_code(i)) = UPPER(v_attributes_category)) OR
                v_contexts.is_global(i))
              ) THEN

                -- Get segments
                fnd_dflex.get_segments(fnd_dflex.make_context(v_flexfield,
                      v_contexts.context_code(i)), v_segments, TRUE);

                <<segmentLoop>>
                FOR j IN 1..v_segments.nsegments LOOP
                    IF v_segments.is_enabled(j) THEN
                        IF v_segments.is_required(j) THEN
                            IF ( l_lot_exist = 1) THEN
                                l_where_clause := l_where_clause || ' AND ' ||
                                    v_segments.application_column_name(j) || ' IS NOT NULL ';
                            ELSE
                                l_lot_att_required := TRUE;
                                EXIT contextLoop;
                            END IF;
                        END IF;
                    END IF;
                END LOOP segmentLoop;
            END IF;
        END LOOP contextLoop;

        IF l_where_clause IS NOT NULL   THEN

            l_where_clause := 'SELECT 1 FROM mtl_lot_numbers ' ||
                              ' WHERE organization_id = :org_id ' ||
                              ' AND inventory_item_id = :item_id ' ||
                              ' AND lot_number = :lot ' || l_where_clause;

            l_cursor_handle := dbms_sql.open_cursor;
            dbms_sql.parse(l_cursor_handle, l_where_clause, dbms_sql.native);
            dbms_sql.bind_variable(l_cursor_handle, ':org_id', p_organization_id);
            dbms_sql.bind_variable(l_cursor_handle, ':item_id', p_inventory_item_id);
            dbms_sql.bind_variable(l_cursor_handle, ':lot', p_lot_number);

            l_rows_affected := dbms_sql.execute(l_cursor_handle);

            IF dbms_sql.fetch_rows(l_cursor_handle) <= 0 then
                l_lot_att_required := TRUE;
            END IF;

        END IF;

    END IF;

    RETURN l_lot_att_required;

EXCEPTION
    WHEN others THEN
        l_lot_att_required := TRUE;
        debug('Unexpected exception : ' || SQLERRM, c_api_name, 0);
        RETURN l_lot_att_required;

END is_lot_attributes_required;
--  Bug 7350762 Code changes end

/* Added following function for bug 8428348 */

FUNCTION lock_lot_records( p_org_id               IN    NUMBER
                            , p_inventory_item_id IN    NUMBER
                            , p_lot_uniqueness    IN    NUMBER DEFAULT NULL
                            , p_lot_generation    IN    NUMBER DEFAULT NULL
                            , p_lot_prefix        IN    VARCHAR2
                            , x_return_status     OUT NOCOPY    VARCHAR2
                          ) RETURN BOOLEAN IS

    l_module_name        VARCHAR2(30) := 'lock_lot_records';
    l_already_locked     VARCHAR2(1)  := 'Y';

    TYPE loc_exists IS TABLE OF VARCHAR2(1) INDEX BY BINARY_INTEGER;
    loc_tab loc_exists;

    BEGIN

    SAVEPOINT lock_lot_records;

    x_return_status  := fnd_api.g_ret_sts_success;

    debug('Lot Generation =>  '|| p_lot_generation ,l_module_name, 9);
    debug('Lot Uniqueness =>  '|| p_lot_uniqueness ,l_module_name, 9);
    debug('Lot Prefix => '|| p_lot_prefix  ,l_module_name, 9);

    IF (p_lot_generation = 2 AND p_lot_uniqueness = 1) THEN

        SELECT 'N' BULK COLLECT
        INTO loc_tab
        FROM mtl_system_items_b
        WHERE  auto_lot_alpha_prefix = p_lot_prefix
        AND lot_control_code = 2
        FOR UPDATE NOWAIT;

        l_already_locked := 'N';

    ELSIF(p_lot_generation = 2 AND p_lot_uniqueness <> 1) THEN

        SELECT 'N'
        INTO l_already_locked
        FROM mtl_system_items_b
        WHERE  organization_id = p_org_id
        AND inventory_item_id = p_inventory_item_id
        FOR UPDATE NOWAIT;

    END IF;

    IF l_already_locked  = 'N' THEN  /* Got the lock */
        RETURN TRUE;
    ELSE
        x_return_status  := fnd_api.g_ret_sts_error;
        RETURN FALSE;
    END IF;

    EXCEPTION
        WHEN OTHERS THEN    /* could not lock row */
            ROLLBACK TO lock_lot_records;
            IF SQLCODE = -54 THEN
                -- item with same prefix / same item currently locked in MSI
                debug('Item with same prefix currently locked in Master or Organization items form',l_module_name,9);
                fnd_message.set_name('INV', 'INV_LOT_GEN_ERROR');
                fnd_msg_pub.ADD;
            END IF;
            x_return_status  := fnd_api.g_ret_sts_error;
            RETURN FALSE;
END lock_lot_records;

/* End of changes for bug 8428348 */


END INV_LOT_SEL_ATTR;

/
