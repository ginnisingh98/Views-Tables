--------------------------------------------------------
--  DDL for Package Body GMD_OUTBOUND_APIS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMD_OUTBOUND_APIS_PUB" AS
/*  $Header: GMDOAPIB.pls 120.14.12010000.2 2009/03/18 21:05:47 plowe ship $ */
--****************************************************************************************
--* FILE:      GMDOAPIB.pls                                                              *
--*                                                                                      *
--* CONTENTS:  Public level outbound GMD Quality API package                             *
--*                                                                                      *
--* AUTHOR:    Paul Schofield, OPM Development EMEA                                      *
--*                                                                                      *
--* DATE:      May 20th 2003                                                             *
--*                                                                                      *
--* VERSION    CHANGED BY         CHANGE                                                 *
--* =======    ==========         ======                                                 *
--* 20May03    P.J.Schofield      New file                                               *
--* 17Jun03    K.Y.Hunt           Merged in 3 new APIs                                   *
--* 03Jul03    P.J.Schofield      Added sampling groups API                              *
--* 04Jul03    P.J.Schofield      Added user_name parameters for logging                 *
--* 28Aug03    Chetan Nagar       Added mini-pack K specific features.                   *
--* 18Dec03    Brenda Stone       Bug 3124627 Fetch Sample Groups; Changed               *
--*                               EVENT_ID to SAMPLING_EVENT_ID in where clause          *
--* 18Dec03    Brenda Stone       Bug 3124643 Fetch Sample Groups; Changed               *
--*                               r.recipe_no to r.recipe_vers                         *
--* 26Dec03    Brenda Stone       Bug 3133163;  Default test method was not retrieved,   *
--*                               Added wildcard (+) since the default test methods's    *
--*                               user_id is not in FND_USERS table.                     *
--* 29Dec03    Brenda Stone       Bug 3124620; Fetch_Sample_Groups, Changed where clause *
--*                               to validate the orgn_code                              *                                        *
--* 29Dec03    Brenda Stone       Bug 3124643;  Fetch_Sample_Groups, Changed r.recipe_no*
--*                               to r.recipe_version                                   *
--* 31Dec03    Brenda Stone       Bug 3124653; Fetch_Sample_Groups. Added code to        *
--*                               retrieve Sample Groups by customer_ship_to_location &  *
--*                               customer_ship_to_location_id                           *
--* 15Jan04    Brenda Stone       Added mini-pack L specific features                    *
--* 24Feb04    Brenda Stone       Bug 3394055; Added L columns to results and            *
--*                               composite results                                      *
--* 05May04    SaiKiran           Bug 3704049; Added 'delayed_lot_entry' to the column   *
--*                               lists in 'FETCH_SPEC_VRS' procedure for WIP, Supplier  *
--*                               and Inventory VRs                                      *
--* 20Sep04    Brenda Stone       Bug 3704049; Added auto_sample_ind field for WIP,      *
--*                               Supplier and Inventory VRs                             *
--* 02May05  Saikiran Vankadari   Convergence changes done for fetch_spec_vrs() procedure.*
--*           Changed all references of OPM Inventory tables to Discrete inventory tables*
--* 20Jun05    S Feinstein        Convergence changes done for fetch samples and fetch   *
--*                               sample groups.
--* 26Aug05   Saikiran Vankadari  Convergence changes done for fetch test methods procedure*
--* 10Oct05   RLNAGARA            Bug # 4548546 - Added code to fetch records using revision*
--* 10Nov05   RLNAGARA            Bug # 4616835 - Changed all the references of TYPE     *
--*                               objects to SYSTEM schema.                              *
--* 12Jun06   PLOWE               Bug # 5346713                                          *
--* 22Jun06   PLOWE               Bug # 5284242 - add 'system.' for xdf tab_types        *
--* 26Jun06   PLOWE               Bug # 5335829 rework                                   *
--* 03Jul06   PLOWE               Bug # 5346713 rework                                   *
--* 03Jul06   PLOWE               Bug # 5346480 rework                                   *
--* 05May08   PLOWE               Bug # 7027149 support for LPN
--****************************************************************************************
--*                                                                                      *
--* COPYRIGHT (c) Oracle Corporation 2003                                                *
--*                                                                                      *
--****************************************************************************************




-- Small setup routine for the rest of the package called internally.

FUNCTION initialized_ok
( p_user_name     IN VARCHAR2)
RETURN BOOLEAN
IS
  l_user_id NUMBER;
BEGIN

  SELECT user_id INTO l_user_id
  FROM   fnd_user
  WHERE  user_name = UPPER(p_user_name)
  AND    SYSDATE BETWEEN start_date AND NVL(end_date,sysdate+1);

  FND_GLOBAL.apps_initialize(l_user_id, NULL, NULL, 0);
  --gme_debug.log_initialize('PAL_GMD_OUTBOUND_API');

  RETURN TRUE;

EXCEPTION
  WHEN NO_DATA_FOUND
  THEN
    gmd_api_pub.log_message('GMD_INVALID_USER_NAME', 'p_user_name', p_user_name);
    RETURN FALSE;
  WHEN OTHERS
  THEN
    gmd_api_pub.log_message('GMD_API_ERROR','Initialization failed', substr(SQLERRM,1,100));
    RETURN FALSE;
END initialized_ok;

PROCEDURE fetch_test_methods
( p_api_version            IN NUMBER
, p_init_msg_list          IN VARCHAR2 DEFAULT FND_API.G_FALSE
, p_user_name              IN VARCHAR2
, p_from_test_method_code  IN VARCHAR2 DEFAULT NULL
, p_to_test_method_code    IN VARCHAR2 DEFAULT NULL
, p_test_method_id         IN NUMBER   DEFAULT NULL
, p_test_kit_organization_id IN NUMBER DEFAULT NULL  --INVCONV
--, p_test_kit_item_no       IN VARCHAR2 DEFAULT NULL --INVCONV
--, p_test_kit_item_id       IN NUMBER   DEFAULT NULL --INVCONV
, p_test_kit_inv_item_id       IN NUMBER   DEFAULT NULL --INVCONV
, p_resource               IN VARCHAR2 DEFAULT NULL
, p_delete_mark            IN NUMBER   DEFAULT NULL
, p_from_last_update_date  IN DATE     DEFAULT NULL
, p_to_last_update_date    IN DATE     DEFAULT NULL
, x_test_methods_table     OUT NOCOPY system.gmd_test_methods_tab_type -- 5284242
, x_return_status          OUT NOCOPY VARCHAR2
, x_msg_count              OUT NOCOPY NUMBER
, x_msg_data               OUT NOCOPY VARCHAR2
)
IS
  sql_statement            VARCHAR2(2000);
  column_list              VARCHAR2(2000);
  table_list               VARCHAR2(2000);
  where_clause             VARCHAR2(2000);
  into_clause              VARCHAR2(2000);
  using_clause             VARCHAR2(2000);
  execution_string         VARCHAR2(5000);
  row_count                NUMBER;
  i                        NUMBER;
  l_api_name               VARCHAR2(100) := 'fetch_test_methods';
BEGIN


  IF NOT FND_API.Compatible_API_CALL
    (gmd_outbound_apis_pub.api_version, p_api_version, l_api_name,'GMD_OUTBOUND_APIS_PUB')
  OR NOT initialized_ok(p_user_name)
  THEN
    Raise FND_API.G_EXC_UNEXPECTED_ERROR;
  ELSE
    gme_debug.put_line('Starting FETCH_TESTS');

    /*  Initialize message list if p_int_msg_list is set TRUE.  */

    IF FND_API.to_boolean(p_init_msg_list)
    THEN
      FND_MSG_PUB.Initialize;
    END IF;

    -- Start construction the select.

    gme_debug.put_line('Constructing select statement');

    sql_statement := 'SELECT ';

    column_list := 'system.gmd_test_method_rec_type( gtm.test_method_id, gtm.test_method_code, ' -- 5284242
                   ||'gtm.test_method_desc, gtm.test_qty, gtm.test_qty_uom, gtm.delete_mark, '
                   ||'gtm.display_precision, gtm.test_duration, gtm.days, gtm.hours, '
                   ||'gtm.minutes, gtm.seconds, gtm.test_replicate, gtm.resources, '
                   ||'gtm.test_kit_organization_id, NULL, '  --INVCONV
                   ||'gtm.test_kit_inv_item_id, NULL, gtm.text_code, gtm.attribute1, '
                   ||'gtm.attribute2, gtm.attribute3, gtm.attribute4, gtm.attribute5, '
                   ||'gtm.attribute6, gtm.attribute7, gtm.attribute8, gtm.attribute9, '
                   ||'gtm.attribute10, gtm.attribute11, gtm.attribute12, gtm.attribute13, '
                   ||'gtm.attribute14, gtm.attribute15, gtm.attribute16, gtm.attribute17, '
                   ||'gtm.attribute18, gtm.attribute19, gtm.attribute20, gtm.attribute21, '
                   ||'gtm.attribute22, gtm.attribute23, gtm.attribute24, gtm.attribute25, '
                   ||'gtm.attribute26, gtm.attribute27, gtm.attribute28, gtm.attribute29, '
                   ||'gtm.attribute30, gtm.attribute_category, gtm.creation_date, '
                   ||'gtm.created_by, fu1.user_name, gtm.last_updated_by, fu2.user_name, '
                   ||'gtm.last_update_date, gtm.last_update_login) ';

    table_list :='FROM gmd_test_methods gtm, fnd_user fu1, fnd_user fu2 ';


    -- We now have the first three strings built. Here comes the good bit: building the where and using
    -- clauses and inserting the bind variables and values.


 -- Bug 3133163;  Default test method was not retrieved, Added wildcard (+)
 --               since the default test methods's user_id is not in FND_USERS
 --               table.
   where_clause := 'WHERE fu1.user_id (+) = gtm.created_by '||
             ' AND fu2.user_id (+) = gtm.last_updated_by  '||
             'AND 1=:dummy ';
    using_clause := 'USING 1 ';

    -- Work down the parameter list and append conditions, bind variables and bind values.

    IF p_from_test_method_code IS NOT NULL
    THEN
      gmd_outbound_apis_pub.g_from_test_method_code := p_from_test_method_code;
      where_clause := where_clause||'AND gtm.test_method_code >= :from_test_method_code ';
      using_clause := using_clause||', gmd_outbound_apis_pub.g_from_test_method_code ';
    END IF;

    IF p_to_test_method_code IS NOT NULL
    THEN
      gmd_outbound_apis_pub.g_to_test_method_code := p_to_test_method_code;
      where_clause := where_clause||'AND gtm.test_method_code <= :to_test_method_code ';
      using_clause := using_clause||', gmd_outbound_apis_pub.g_to_test_method_code ';
    END IF;

    IF p_test_method_id IS NOT NULL
    THEN
      gmd_outbound_apis_pub.g_test_method_id := p_test_method_id;
      where_clause := where_clause||'AND gtm.test_method_id = :test_method_id ';
      using_clause := using_clause||', gmd_outbound_apis_pub.g_test_method_id ';
    END IF;

    IF p_test_kit_organization_id IS NOT NULL --INVCONV
    THEN
      gmd_outbound_apis_pub.g_test_kit_organization_id := p_test_kit_organization_id;
      where_clause := where_clause||'AND gtm.test_kit_organization_id = :test_kit_organization_id ';
      using_clause := using_clause||', gmd_outbound_apis_pub.g_test_kit_organization_id ';
    END IF;

    IF p_test_kit_inv_item_id IS NOT NULL  --INVCONV
    THEN
      gmd_outbound_apis_pub.g_test_kit_inv_item_id := p_test_kit_inv_item_id;
      where_clause := where_clause||'AND gtm.test_kit_item_id = :test_kit_inv_item_id ';
      using_clause := using_clause||', gmd_outbound_apis_pub.g_test_kit_inv_item_id ';
    END IF;

    IF p_resource IS NOT NULL
    THEN
      gmd_outbound_apis_pub.g_resource := p_resource;
      where_clause := where_clause||'AND gtm.resources = :resources ';
      using_clause := using_clause||', gmd_outbound_apis_pub.g_resource ';
    END IF;

    IF p_delete_mark IS NOT NULL
    THEN
      gmd_outbound_apis_pub.g_delete_mark := p_delete_mark;
      where_clause := where_clause||'AND gtm.delete_mark = :delete_mark ';
      using_clause := using_clause||', gmd_outbound_apis_pub.g_delete_mark';
    END IF;

    IF p_from_last_update_date IS NOT NULL
    THEN
      gmd_outbound_apis_pub.g_from_last_update_date := p_from_last_update_date;
      where_clause := where_clause||'AND gtm.last_update_date >= :from_last_update_date ';
      using_clause := using_clause||', gmd_outbound_apis_pub.g_from_last_update_date ';
    END IF;

    IF p_to_last_update_date IS NOT NULL
    THEN
      gmd_outbound_apis_pub.g_to_last_update_date := p_to_last_update_date;
      where_clause := where_clause||'AND gtm.last_update_date <= :to_last_update_date';
      using_clause := using_clause||', gmd_outbound_apis_pub.g_to_last_update_date';
    END IF;

    -- That's more or less the job done. We just need to tell the system where to store the data

    into_clause := ' BULK COLLECT INTO gmd_outbound_apis_pub.g_test_methods_table ';

    execution_string := 'BEGIN EXECUTE IMMEDIATE '
                       ||''''
                       ||sql_statement||column_list||table_list||where_clause
                       ||''''
                       ||into_clause
                       ||using_clause
                       ||'; END;';

    /*gme_debug.put_line('The sql statement is:');
    i:= 1;
    LOOP
      gme_debug.put_line(substr(execution_string, i, 100));
      EXIT WHEN i> LENGTH(execution_string);
      i := i+100;
    END LOOP;
    gme_debug.put_line('Executing string'); */

    EXECUTE IMMEDIATE execution_string;

    -- Main retrieval done, now just fill in any blanks

    IF g_test_methods_table.count > 0
    THEN
      FOR i in 1.. g_test_methods_table.count
      LOOP

        IF g_test_methods_table(i).test_kit_organization_id IS NOT NULL THEN   --INVCONV
          gme_debug.put_line('Retrieving test kit organization for test kit organization id:'
                          ||to_char(g_test_methods_table(i).test_kit_organization_id));
          SELECT organization_code INTO g_test_methods_table(i).test_kit_organization_code
          FROM mtl_parameters
          WHERE organization_id = g_test_methods_table(i).test_kit_organization_id;
        END IF;

        IF g_test_methods_table(i).test_kit_inv_item_id IS NOT NULL THEN  --INVCONV
          gme_debug.put_line('Retrieving test kit item for test kit inv item id:'
                          ||to_char(g_test_methods_table(i).test_kit_inv_item_id));
          SELECT concatenated_segments INTO g_test_methods_table(i).test_kit_item_number
          FROM mtl_system_items_b_kfv
          WHERE organization_id = g_test_methods_table(i).test_kit_organization_id
          AND inventory_item_id = g_test_methods_table(i).test_kit_inv_item_id;
        END IF;

      END LOOP;
    END IF;

    --gme_debug.put_line('Returning table to caller');
    x_test_methods_table := gmd_outbound_apis_pub.g_test_methods_table;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

  END IF;

  FND_MSG_PUB.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  gme_debug.put_line('Finished');
EXCEPTION
  WHEN OTHERS
  THEN
    gme_debug.put_line('EXCEPTION : '||substr(SQLERRM,1,100));
    gmd_api_pub.log_message('GMD_API_ERROR','Fetch_Test_Methods', 'Exception',substr(SQLERRM,1,100));
    FND_MSG_PUB.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    x_return_status := FND_API.G_RET_STS_ERROR;

END fetch_test_methods;


PROCEDURE fetch_tests
( p_api_version            IN NUMBER
, p_init_msg_list          IN VARCHAR2 DEFAULT FND_API.G_FALSE
, p_user_name              IN VARCHAR2
, p_from_test_code         IN VARCHAR2 DEFAULT NULL
, p_to_test_code           IN VARCHAR2 DEFAULT NULL
, p_from_test_method_code  IN VARCHAR2 DEFAULT NULL
, p_to_test_method_code    IN VARCHAR2 DEFAULT NULL
, p_test_id                IN NUMBER   DEFAULT NULL
, p_test_method_id         IN NUMBER   DEFAULT NULL
, p_test_class             IN VARCHAR2 DEFAULT NULL
, p_test_type              IN VARCHAR2 DEFAULT NULL
, p_priority               IN VARCHAR2 DEFAULT NULL
, p_delete_mark            IN NUMBER   DEFAULT NULL
, p_from_last_update_date  IN DATE     DEFAULT NULL
, p_to_last_update_date    IN DATE     DEFAULT NULL
, x_tests_table            OUT NOCOPY system.gmd_qc_tests_tab_type
, x_return_status          OUT NOCOPY VARCHAR2
, x_msg_count              OUT NOCOPY NUMBER
, x_msg_data               OUT NOCOPY VARCHAR2
)
IS
  CURSOR test_values_cursor (p_test_id NUMBER) IS
  SELECT system.gmd_qc_test_value_rec_type
  ( gtv.test_value_id, gtv.min_num, gtv.max_num, gtv.display_label_numeric_range, gtv.test_value_desc
  , gtv.value_char, gtv.text_range_seq, gtv.expression_ref_test_id, gtv.text_code, gtv.attribute_category
  , gtv.attribute1, gtv.attribute2, gtv.attribute3, gtv.attribute4, gtv.attribute5, gtv.attribute6, gtv.attribute7
  , gtv.attribute8, gtv.attribute9, gtv.attribute10, gtv.attribute11, gtv.attribute12, gtv.attribute13, gtv.attribute14
  , gtv.attribute15, gtv.attribute16, gtv.attribute17, gtv.attribute18, gtv.attribute19, gtv.attribute20
  , gtv.attribute21, gtv.attribute22, gtv.attribute23, gtv.attribute24, gtv.attribute25, gtv.attribute26
  , gtv.attribute27, gtv.attribute28, gtv.attribute29, gtv.attribute30, gtv.creation_date, gtv.created_by
  , fu1.user_name, gtv.last_update_date, gtv.last_updated_by, fu2.user_name
  , gtv.last_update_login
  )
  FROM    gmd_qc_test_values gtv, fnd_user fu1, fnd_user fu2
  WHERE   gtv.test_id = p_test_id
  AND     fu1.user_id = gtv.created_by
  AND     fu2.user_id = gtv.last_updated_by;

  CURSOR customers_cursor (p_test_id NUMBER) IS
  SELECT system.gmd_customer_test_rec_type
  ( gct.cust_id, ocm.cust_no, gct.report_precision, gct.cust_test_display, gct.text_code
  , gct.creation_date, gct.created_by, fu1.user_name, gct.last_update_date
  , gct.last_updated_by, fu2.user_name, gct.last_update_login
  )
  FROM   gmd_customer_tests gct, op_cust_mst ocm, fnd_user fu1, fnd_user fu2
  WHERE  gct.test_id = p_test_id
  AND    gct.cust_id = ocm.cust_id
  AND    gct.created_by = fu1.user_id
  AND    gct.last_updated_by = fu2.user_id;

  sql_statement            VARCHAR2(4000);
  column_list              VARCHAR2(4000);
  table_list               VARCHAR2(4000);
  where_clause             VARCHAR2(4000);
  into_clause              VARCHAR2(4000);
  using_clause             VARCHAR2(4000);
  execution_string         VARCHAR2(9000);
  row_count                NUMBER;
  i                        NUMBER;
  l_api_name               VARCHAR2(100) := 'fetch_tests';
BEGIN

  IF NOT FND_API.Compatible_API_CALL
    (gmd_outbound_apis_pub.api_version, p_api_version, l_api_name,'GMD_OUTBOUND_APIS_PUB')
  OR NOT initialized_ok(p_user_name)
  THEN
    Raise FND_API.G_EXC_UNEXPECTED_ERROR;
  ELSE
    /*  Initialize message list if p_int_msg_list is set TRUE.  */
    IF FND_API.to_boolean(p_init_msg_list)
    THEN
      FND_MSG_PUB.Initialize;
    END IF;

    sql_statement := 'SELECT ';

    column_list := 'system.gmd_qc_test_rec_type('
                 ||'  gqt.test_id, gqt.test_code, gqt.test_desc, gqt.test_method_id, gtm.test_method_code'
                 ||', gqt.test_oprn_line_id, gqt.test_provider_code, gqt.test_class, gqt.test_type'
                 ||', gqt.test_unit, gqt.min_value_num, gqt.max_value_num, gqt.exp_error_type, gqt.below_spec_min'
                 ||', gqt.above_spec_min, gqt.below_spec_max, gqt.above_spec_max, gqt.below_min_action_code'
                 ||', gqt.above_min_action_code, gqt.below_max_action_code, gqt.above_max_action_code'
                 ||', gqt.expression, gqt.display_precision, gqt.report_precision, gqt.priority, gqt.test_oprn_id'
                 ||', gqt.delete_mark, gqt.text_code, gqt.attribute_category, gqt.attribute1, gqt.attribute2'
                 ||', gqt.attribute3, gqt.attribute4, gqt.attribute5, gqt.attribute6, gqt.attribute7, gqt.attribute8'
                 ||', gqt.attribute9, gqt.attribute10, gqt.attribute11, gqt.attribute12, gqt.attribute13, gqt.attribute14'
                 ||', gqt.attribute15, gqt.attribute16, gqt.attribute17, gqt.attribute18, gqt.attribute19, gqt.attribute20'
                 ||', gqt.attribute21, gqt.attribute22, gqt.attribute23, gqt.attribute24, gqt.attribute25, gqt.attribute26'
                 ||', gqt.attribute27, gqt.attribute28, gqt.attribute29, gqt.attribute30, gqt.creation_date'
                 ||', gqt.created_by, fu1.user_name, gqt.last_update_date, gqt.last_updated_by'
                 ||', fu2.user_name, gqt.last_update_login'
                 ||', system.gmd_qc_test_values_tab_type (NULL), system.gmd_customer_tests_tab_type(NULL)' -- 5284242
                 ||')';

    table_list := ' FROM gmd_qc_tests gqt, gmd_test_methods gtm, fnd_user fu1, fnd_user fu2';

    where_clause := ' WHERE gqt.test_method_id = gtm.test_method_id'
                  ||' AND fu1.user_id=gqt.created_by'
                  ||' AND fu2.user_id=gqt.last_updated_by'
                  ||' AND 1=:dummy ';

    using_clause := ' USING 1';

    IF p_from_test_method_code IS NOT NULL
    THEN
      gmd_outbound_apis_pub.g_from_test_method_code := p_from_test_method_code;
      where_clause := where_clause ||' AND gtm.test_method_code >= :from_test_method_code';
      using_clause := using_clause ||', gmd_outbound_apis_pub.g_from_test_method_code';
    END IF;

    IF p_to_test_method_code IS NOT NULL
    THEN
      gmd_outbound_apis_pub.g_to_test_method_code := p_to_test_method_code;
      where_clause := where_clause ||' AND gtm.test_method_code <= :to_test_method_code';
      using_clause := using_clause ||', gmd_outbound_apis_pub.g_to_test_method_code';
    END IF;

    IF p_from_test_code IS NOT NULL
    THEN
      gmd_outbound_apis_pub.g_from_test_code := p_from_test_code;
      where_clause := where_clause||' AND gqt.test_code >= :from_test_code';
      using_clause := using_clause||', gmd_outbound_apis_pub.g_from_test_code';
    END IF;

    IF p_to_test_code IS NOT NULL
    THEN
      gmd_outbound_apis_pub.g_to_test_code := p_to_test_code;
      where_clause := where_clause||' AND gqt.test_code <= :to_test_code';
      using_clause := using_clause||', gmd_outbound_apis_pub.g_to_test_code';
    END IF;


    IF p_test_method_id IS NOT NULL
    THEN
      gmd_outbound_apis_pub.g_test_method_id := p_test_method_id;
      where_clause := where_clause||' AND gqt.test_method_id = :test_method_id';
      using_clause := using_clause||', gmd_outbound_apis_pub.g_test_method_id';
    END IF;


    IF p_test_id IS NOT NULL
    THEN
      gmd_outbound_apis_pub.g_test_id := p_test_id;
      where_clause := where_clause||' AND gqt.test_id = :test_id';
      using_clause := using_clause||', gmd_outbound_apis_pub.g_test_id';
    END IF;


    IF p_test_class IS NOT NULL
    THEN
      gmd_outbound_apis_pub.g_test_class := p_test_class;
      where_clause := where_clause||' AND gqt.test_class = :test_class';
      using_clause := using_clause||', gmd_outbound_apis_pub.g_test_class';
    END IF;


    IF p_test_type IS NOT NULL
    THEN
      gmd_outbound_apis_pub.g_test_type := p_test_type;
      where_clause := where_clause||' AND gqt.test_type = :test_type';
      using_clause := using_clause||', gmd_outbound_apis_pub.g_test_type';
    END IF;


    IF p_priority IS NOT NULL
    THEN
      gmd_outbound_apis_pub.g_priority := p_priority;
      where_clause := where_clause||' AND gqt.test_type = :priority';
      using_clause := using_clause||', gmd_outbound_apis_pub.g_priority';
    END IF;


    IF p_delete_mark IS NOT NULL
    THEN
      gmd_outbound_apis_pub.g_delete_mark := p_delete_mark;
      where_clause := where_clause||' AND gqt.delete_mark = :delete_mark';
      using_clause := using_clause||', gmd_outbound_apis_pub.g_delete_mark';
    END IF;


    IF p_from_last_update_date IS NOT NULL
    THEN
      gmd_outbound_apis_pub.g_from_last_update_date := p_from_last_update_date;
      where_clause := where_clause||' AND gqt.last_update_date >= :from_last_update_date';
      using_clause := using_clause||', gmd_outbound_apis_pub.g_from_last_update_date';
    END IF;

    IF p_to_last_update_date IS NOT NULL
    THEN
      gmd_outbound_apis_pub.g_to_last_update_date := p_to_last_update_date;
      where_clause := where_clause||' AND gqt.last_update_date <= :to_last_update_date';
      using_clause := using_clause||', gmd_outbound_apis_pub.g_to_last_update_date';
    END IF;

 -- That's more or less the job done. We just need to tell the system where to store the data

    into_clause := ' BULK COLLECT INTO gmd_outbound_apis_pub.g_tests_table ';

    execution_string := 'BEGIN EXECUTE IMMEDIATE '
                       ||''''
                       ||sql_statement||column_list||table_list||where_clause
                       ||''''
                       ||into_clause
                       ||using_clause
                       ||'; END;';

    EXECUTE IMMEDIATE execution_string;

    IF g_tests_table.count <> 0
    THEN
      FOR i IN 1..g_tests_table.count
      LOOP
        OPEN test_values_cursor(g_tests_table(i).test_id);
        FETCH test_values_cursor BULK COLLECT INTO g_tests_table(i).test_values;
        CLOSE test_values_cursor;

        OPEN customers_cursor(g_tests_table(i).test_id);
        FETCH customers_cursor BULK COLLECT INTO g_tests_table(i).customer_tests;
        CLOSE customers_cursor;
      END LOOP;
    END IF;

    x_tests_table := gmd_outbound_apis_pub.g_tests_table;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
  END IF;

  FND_MSG_PUB.count_and_get(p_count => x_msg_count, p_data => x_msg_data);

EXCEPTION
  WHEN OTHERS
  THEN
    FND_MESSAGE.SET_NAME('GMD',SQLCODE);
    FND_MSG_PUB.Add;
    FND_MSG_PUB.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    x_return_status := FND_API.G_RET_STS_ERROR;

END fetch_tests;


PROCEDURE FETCH_SPEC_VRS
( p_api_version            IN NUMBER
, p_init_msg_list          IN VARCHAR2 DEFAULT FND_API.G_FALSE
, p_user_name              IN VARCHAR2

-- Parameters relating to specifications

, p_from_spec_name	   IN VARCHAR2 DEFAULT NULL
, p_to_spec_name    	   IN VARCHAR2 DEFAULT NULL
, p_spec_id		   IN NUMBER   DEFAULT NULL
, p_spec_version    	   IN NUMBER   DEFAULT NULL
, p_from_grade_code        IN VARCHAR2 DEFAULT NULL
, p_to_grade_code          IN VARCHAR2 DEFAULT NULL
, p_from_item_number       IN VARCHAR2 DEFAULT NULL
, p_to_item_number  	   IN VARCHAR2 DEFAULT NULL
, p_inventory_item_id      IN NUMBER   DEFAULT NULL
, p_from_revision          IN VARCHAR2 DEFAULT NULL  -- RLNAGARA Bug # 4548546
, p_to_revision            IN VARCHAR2 DEFAULT NULL  -- RLNAGARA Bug # 4548546
, p_from_spec_last_update  IN DATE     DEFAULT NULL
, p_to_spec_last_update    IN DATE     DEFAULT NULL
, p_spec_status            IN NUMBER   DEFAULT NULL
, p_owner_organization_code IN VARCHAR2 DEFAULT NULL
, p_spec_delete_mark       IN NUMBER   DEFAULT NULL

-- START B3124291 Incorporated Mini-Pack K Features to Outboud APIs
, p_overlay_ind            IN VARCHAR2 DEFAULT NULL
, p_spec_type              IN VARCHAR2 DEFAULT NULL
, p_base_spec_id           IN NUMBER   DEFAULT NULL
, p_base_spec_name         IN VARCHAR2 DEFAULT NULL
, p_base_spec_version      IN NUMBER   DEFAULT NULL
-- END B3124291 Incorporated Mini-Pack K Features to Outboud APIs

-- Parameters relating to spec tests

, p_test_code		   IN VARCHAR2 DEFAULT NULL
, p_test_id  		   IN NUMBER   DEFAULT NULL
, p_test_method_code	   IN VARCHAR2 DEFAULT NULL
, p_test_method_id	   IN NUMBER   DEFAULT NULL
, p_test_qty_uom		   IN VARCHAR2 DEFAULT NULL
, p_test_priority	   IN VARCHAR2 DEFAULT NULL
, p_from_test_last_update  IN DATE     DEFAULT NULL
, p_to_test_last_update	   IN DATE     DEFAULT NULL
, p_test_delete_mark       IN NUMBER   DEFAULT NULL
-- START B3124291 Incorporated Mini-Pack K Features to Outboud APIs
, p_from_base_ind          IN VARCHAR2 DEFAULT NULL
, p_exclude_ind            IN VARCHAR2 DEFAULT NULL
, p_modified_ind           IN VARCHAR2 DEFAULT NULL
, p_calc_uom_conv_ind      IN VARCHAR2 DEFAULT NULL
, p_to_qty_uom             IN VARCHAR2 DEFAULT NULL
-- END B3124291 Incorporated Mini-Pack K Features to Outboud APIs

-- Parameters relating to wip spec validity rules

, p_wip_vr_status	   IN NUMBER   DEFAULT NULL
, p_wip_vr_organization_code  IN VARCHAR2 DEFAULT NULL
, p_wip_vr_batch_orgn_code IN VARCHAR2 DEFAULT NULL
, p_wip_vr_batch_no        IN VARCHAR2 DEFAULT NULL
, p_wip_vr_batch_id        IN NUMBER   DEFAULT NULL
, p_wip_vr_recipe_no       IN VARCHAR2 DEFAULT NULL
, p_wip_vr_recipe_version  IN NUMBER   DEFAULT NULL
, p_wip_vr_recipe_id       IN NUMBER   DEFAULT NULL
, p_wip_vr_formula_no      IN VARCHAR2 DEFAULT NULL
, p_wip_vr_formula_version IN NUMBER   DEFAULT NULL
, p_wip_vr_formula_id      IN NUMBER   DEFAULT NULL
, p_wip_vr_formulaline_no  IN NUMBER   DEFAULT NULL
, p_wip_vr_formulaline_id  IN NUMBER   DEFAULT NULL
, p_wip_vr_line_type       IN NUMBER   DEFAULT NULL
, p_wip_vr_routing_no      IN VARCHAR2 DEFAULT NULL
, p_wip_vr_routing_version IN NUMBER   DEFAULT NULL
, p_wip_vr_routing_id      IN NUMBER   DEFAULT NULL
, p_wip_vr_step_no         IN NUMBER   DEFAULT NULL
, p_wip_vr_step_id         IN NUMBER   DEFAULT NULL
, p_wip_vr_operation_no    IN VARCHAR2 DEFAULT NULL
, p_wip_vr_operation_version IN NUMBER   DEFAULT NULL
, p_wip_vr_operation_id    IN NUMBER   DEFAULT NULL
, p_wip_vr_start_date	   IN DATE     DEFAULT NULL
, p_wip_vr_end_date	   IN DATE     DEFAULT NULL
, p_wip_vr_coa_type	   IN VARCHAR2 DEFAULT NULL
, p_wip_vr_sampling_plan   IN VARCHAR2 DEFAULT NULL
, p_wip_vr_sampling_plan_id IN NUMBER   DEFAULT NULL
, p_wip_vr_delete_mark	   IN NUMBER   DEFAULT NULL
, p_wip_vr_from_last_update IN DATE     DEFAULT NULL
, p_wip_vr_to_last_update	 IN DATE     DEFAULT NULL

-- Parameters relating to customer spec validity rules
, p_cust_vr_start_date     IN DATE     DEFAULT NULL
, p_cust_vr_end_date       IN DATE     DEFAULT NULL
, p_cust_vr_status         IN NUMBER   DEFAULT NULL
, p_cust_vr_organization_code IN VARCHAR2 DEFAULT NULL
, p_cust_vr_org_id         IN NUMBER   DEFAULT NULL
, p_cust_vr_coa_type       IN VARCHAR2 DEFAULT NULL
, p_cust_vr_customer       IN VARCHAR2 DEFAULT NULL
, p_cust_vr_customer_id	   IN NUMBER   DEFAULT NULL
, p_cust_vr_order_number   IN NUMBER   DEFAULT NULL
, p_cust_vr_order_id       IN NUMBER   DEFAULT NULL
, p_cust_vr_order_type     IN NUMBER   DEFAULT NULL
, p_cust_vr_order_line_no  IN NUMBER   DEFAULT NULL
, p_cust_vr_order_line_id  IN NUMBER   DEFAULT NULL
, p_cust_vr_ship_to_location IN VARCHAR2 DEFAULT NULL
, p_cust_vr_ship_to_site_id  IN NUMBER   DEFAULT NULL
, p_cust_vr_operating_unit IN VARCHAR
, p_cust_vr_delete_mark    IN NUMBER   DEFAULT NULL
, p_cust_vr_from_last_update IN DATE     DEFAULT NULL
, p_cust_vr_to_last_update IN DATE     DEFAULT NULL

-- Parameters relating to supplier spec validity rules
, p_supl_vr_start_date     IN DATE     DEFAULT NULL
, p_supl_vr_end_date       IN DATE     DEFAULT NULL
, p_supl_vr_status         IN NUMBER   DEFAULT NULL
, p_supl_vr_organization_code IN VARCHAR2 DEFAULT NULL
, p_supl_vr_org_id         IN NUMBER   DEFAULT NULL
, p_supl_vr_coa_type       IN VARCHAR2 DEFAULT NULL
, p_supl_vr_supplier       IN VARCHAR2 DEFAULT NULL
, p_supl_vr_supplier_id    IN NUMBER   DEFAULT NULL
, p_supl_vr_po_number      IN NUMBER   DEFAULT NULL
, p_supl_vr_po_id          IN NUMBER   DEFAULT NULL
, p_supl_vr_po_line_no     IN NUMBER   DEFAULT NULL
, p_supl_vr_po_line_id     IN NUMBER   DEFAULT NULL
, p_supl_vr_supplier_site  IN VARCHAR2 DEFAULT NULL
, p_supl_vr_supplier_site_id IN NUMBER   DEFAULT NULL
, p_supl_vr_operating_unit IN VARCHAR2 DEFAULT NULL
, p_supl_vr_delete_mark         IN NUMBER   DEFAULT NULL
, p_supl_vr_from_last_update    IN DATE     DEFAULT NULL
, p_supl_vr_to_last_update IN DATE     DEFAULT NULL

-- Parameters relating to inventory spec validity rules
, p_inv_vr_start_date     IN DATE     DEFAULT NULL
, p_inv_vr_end_date       IN DATE     DEFAULT NULL
, p_inv_vr_status         IN NUMBER   DEFAULT NULL
, p_inv_vr_organization_code IN VARCHAR2 DEFAULT NULL
, p_inv_vr_coa_type       IN VARCHAR2 DEFAULT NULL
, p_inv_vr_item_number    IN VARCHAR2 DEFAULT NULL
, p_inv_vr_inventory_item_id  IN NUMBER   DEFAULT NULL
, p_inv_vr_parent_lot_number  IN VARCHAR2 DEFAULT NULL
, p_inv_vr_lot_number      IN VARCHAR2 DEFAULT NULL
, p_inv_vr_subinventory      IN VARCHAR2 DEFAULT NULL
, p_inv_vr_locator    IN VARCHAR2   DEFAULT NULL
, p_inv_vr_locator_id    IN NUMBER   DEFAULT NULL
, p_inv_vr_sampling_plan  IN VARCHAR2 DEFAULT NULL
, p_inv_vr_sampling_plan_id IN NUMBER   DEFAULT NULL
, p_inv_vr_delete_mark         IN NUMBER   DEFAULT NULL
, p_inv_vr_from_last_update    IN DATE     DEFAULT NULL
, p_inv_vr_to_last_update IN DATE     DEFAULT NULL

-- START B3124291 Incorporated Mini-Pack K Features to Outboud APIs
-- Parameters relating to monitor spec
, p_mon_vr_status                IN NUMBER   DEFAULT NULL
, p_mon_vr_rule_type             IN VARCHAR2 DEFAULT NULL
, p_mon_vr_lct_organization_code IN VARCHAR2 DEFAULT NULL
, p_mon_vr_subinventory          IN VARCHAR2 DEFAULT NULL
, p_mon_vr_locator_id            IN NUMBER DEFAULT NULL
, p_mon_vr_locator               IN VARCHAR2 DEFAULT NULL
, p_mon_vr_rsr_organization_code IN VARCHAR2 DEFAULT NULL
, p_mon_vr_resources             IN VARCHAR2 DEFAULT NULL
, p_mon_vr_resource_instance_id  IN NUMBER   DEFAULT NULL
, p_mon_vr_sampling_plan         IN VARCHAR2 DEFAULT NULL
, p_mon_vr_sampling_plan_id      IN NUMBER   DEFAULT NULL
, p_mon_vr_start_date            IN DATE     DEFAULT NULL
, p_mon_vr_end_date              IN DATE     DEFAULT NULL
, p_mon_vr_from_last_update_date IN DATE     DEFAULT NULL
, p_mon_vr_to_last_update_date   IN DATE     DEFAULT NULL
, p_mon_vr_delete_mark           IN NUMBER   DEFAULT NULL
-- END B3124291 Incorporated Mini-Pack K Features to Outboud APIs

-- Return parameters

, x_specifications_tbl     OUT NOCOPY system.gmd_specifications_tab_type
, x_return_status     	   OUT NOCOPY VARCHAR2
, x_msg_count          	   OUT NOCOPY NUMBER
, x_msg_data               OUT NOCOPY VARCHAR2
)
IS
  sql_statement            VARCHAR2(32000);

  main_column_list         VARCHAR2(10000);
  spec_test_column_list    VARCHAR2(10000);
  cust_vr_column_list      VARCHAR2(10000);
  inv_vr_column_list       VARCHAR2(10000);
  supl_vr_column_list      VARCHAR2(10000);
  wip_vr_column_list       VARCHAR2(10000);
  mon_vr_column_list       VARCHAR2(10000);

  main_table_list          VARCHAR2(10000);
  spec_test_table_list     VARCHAR2(10000);
  cust_vr_table_list       VARCHAR2(10000);
  inv_vr_table_list        VARCHAR2(10000);
  supl_vr_table_list       VARCHAR2(10000);
  wip_vr_table_list        VARCHAR2(10000);
  mon_vr_table_list        VARCHAR2(10000);

  main_where_clause        VARCHAR2(20000);
  spec_test_where_clause   VARCHAR2(10000);
  cust_vr_where_clause     VARCHAR2(10000);
  inv_vr_where_clause      VARCHAR2(10000);
  supl_vr_where_clause     VARCHAR2(10000);
  wip_vr_where_clause      VARCHAR2(10000);
  mon_vr_where_clause      VARCHAR2(10000);

  main_using_clause        VARCHAR2(10000);
  spec_test_using_clause   VARCHAR2(10000);
  wip_vr_using_clause      VARCHAR2(10000);
  inv_vr_using_clause      VARCHAR2(10000);
  supl_vr_using_clause     VARCHAR2(10000);
  cust_vr_using_clause     VARCHAR2(10000);
  mon_vr_using_clause     VARCHAR2(10000);

  main_into_clause         VARCHAR2(10000);
  main_execution_string    VARCHAR2(30000);

  row_count                NUMBER;
  i                        NUMBER;
  j                        NUMBER;
  l_api_name               VARCHAR2(100) := 'fetch_spec_vrs';

BEGIN


  IF NOT FND_API.Compatible_API_CALL
    (gmd_outbound_apis_pub.api_version, p_api_version, l_api_name,'GMD_OUTBOUND_APIS_PUB')
  OR NOT initialized_ok(p_user_name)
  THEN

    Raise FND_API.G_EXC_UNEXPECTED_ERROR;
  ELSE

    /*  Initialize message list if p_int_msg_list is set TRUE.  */
    IF FND_API.to_boolean(p_init_msg_list)
    THEN
      FND_MSG_PUB.Initialize;
    END IF;

    -- Build the query to retrieve all base rows from gmd_specifications together with
    -- linked nested rowsets from all of the other tables..
    --
    -- The code looks worse than it is. All the next few sections do is build SQL
    -- clauses that are then glued together and executed dynamically with binds,
    -- depending on what has been specified in the parameters.
    --
    -- By doing one large BULK COLLECT using the constructed statement, almost everything
    -- is retrieved in a single hit, including all of the nested data. All that we need to
    -- do afterwards is fill in the gaps where a direct retrieval is not possible due to
    -- nullable columns where we cannot make outer joins.
    --
    -- The end result will resemble:

    /* SELECT gmd_specifications_rec_type
              ( <gmd_specification table columns>
              , CAST
                ( MULTISET
                  ( gmd_spec_test_rec_type
                    ( SELECT <gmd_spec_tests table columns>
                      FROM   <gmd_spec_tests table set>
                      WHERE  <gmd_spec_tests conditions with bind variables> ***
                  AS system.gmd_spec_tests_tab_type
                )
              , CAST
                ( MULTISET
                  ( gmd_cust_spec_vrs_rec_type
                    ( SELECT <gmd_cust_spec_vrs table columns>
                      FROM   <gmd_cust_spec_crs table set>
                      WHERE  <gmd_cust_spec_vrs conditions with bind variables> ***
                  AS system.gmd_cust_spec_vrs_tab_type
                )
              , CAST
                ( MULTISET
                  ( gmd_wip_spec_vrs_rec_type
                    ( SELECT <gmd_wip_spec_vrs table columns>
                      FROM   <gmd_wip_spec_crs table set>
                      WHERE  <gmd_wip_spec_vrs conditions with bind variables> ***
                  AS system.gmd_wip_spec_vrs_tab_type
                )
              , CAST
                ( MULTISET
                  ( gmd_supl_spec_vrs_rec_type
                    ( SELECT <gmd_supl_spec_vrs table columns>
                      FROM   <gmd_supl_spec_crs table set>
                      WHERE  <gmd_supl_spec_vrs conditions with bind variables> ***
                  AS system.gmd_supl_spec_vrs_tab_type
                )
              , CAST
                ( MULTISET
                  ( gmd_inv_spec_vrs_rec_type
                    ( SELECT <gmd_inv_spec_vrs table columns>
                      FROM   <gmd_inv_spec_crs table set>
                      WHERE  <gmd_inv_spec_vrs conditions with bind variables> ***
                  AS system.gmd_inv_spec_vrs_tab_type
                )
              )
       FROM
            <main table list>
       WHERE
              <specification constraining conditions with binds> ****
    */

    -- The lines marked *** are the slightly complicated ones to construct as the conditions
    -- have to have the appropriate bind variables embedded.

    -- The whole statement is then put into an EXECUTE IMMEDIATE statement to pass it
    -- to the database. Here goes......


    -- GMD_SPECIFICATIONS basic clauses

    main_column_list := '  gs.spec_id, gs.spec_name, gs.spec_vers, gs.spec_desc'
                      ||', gs.inventory_item_id, NULL, gs.grade_code, gs.revision, gs.spec_status, gstat.description'
                      ||', gs.owner_organization_id, gs.owner_id, fu3.user_name'
                      ||', gs.sample_inv_trans_ind'
                      -- START B3124291 Incorporated Mini-Pack K Features to Outboud APIs
                      ||', gs.overlay_ind, gs.spec_type, gs.base_spec_id'
                      -- END B3124291 Incorporated Mini-Pack K Features to Outboud APIs
                      ||', gs.delete_mark, gs.text_code'
                      ||', gs.attribute_category, gs.attribute1, gs.attribute2, gs.attribute3'
                      ||', gs.attribute4, gs.attribute5, gs.attribute6, gs.attribute7'
                      ||', gs.attribute8, gs.attribute9, gs.attribute10, gs.attribute11'
                      ||', gs.attribute12, gs.attribute13, gs.attribute14, gs.attribute15'
                      ||', gs.attribute16, gs.attribute17, gs.attribute18, gs.attribute19'
                      ||', gs.attribute20, gs.attribute21, gs.attribute22, gs.attribute23'
                      ||', gs.attribute24, gs.attribute25, gs.attribute26, gs.attribute27'
                      ||', gs.attribute28, gs.attribute29, gs.attribute30, gs.creation_date'
                      ||', gs.created_by, fu1.user_name, gs.last_update_date'
                      ||', gs.last_updated_by, fu2.user_name, gs.last_update_login';

    main_table_list := ' gmd_specifications gs, fnd_user fu1, fnd_user fu2, fnd_user fu3, gmd_status gstat';

    main_where_clause := ' gs.created_by = fu1.user_id'
                       ||' AND gs.last_updated_by = fu2.user_id'
                       ||' AND gs.owner_id = fu3.user_id'
                       ||' AND to_char(gs.spec_status) = gstat.status_code'
                       ||' AND 1=:dummy1 ';

    main_using_clause := '1';

    -- GMD_SPEC_TESTS basic clauses

    spec_test_column_list := '  system.gmd_spec_test_rec_type' -- 5284247
                           ||'( gst.test_id, gqt.test_code, gst.test_method_id, gtm.test_method_code'
                           ||', gst.seq'
                           ||', gst.test_qty, gst.test_qty_uom, gst.min_value_num, gst.target_value_num'
                           ||', gst.max_value_num, gst.min_value_char, gst.target_value_char'
                           ||', gst.max_value_char, gst.test_replicate, gst.check_result_interval'
                           ||', gst.print_on_coa_ind, gst.use_to_control_step, gst.out_of_spec_action'
                           ||', gst.exp_error_type, gst.below_spec_min, gst.above_spec_min, gst.below_spec_max'
                           ||', gst.above_spec_max, gst.below_min_action_code, gst.above_min_action_code'
                           ||', gst.optional_ind, gst.display_precision, gst.report_precision'
                           ||', gst.test_priority, gst.retest_lot_expiry_ind, gst.print_spec_ind'
                           ||', gst.print_result_ind, gst.below_max_action_code, gst.above_max_action_code'
                           ||', gst.test_display'
                           -- START B3124291 Incorporated Mini-Pack K Features to Outboud APIs
                           ||', gst.days, gst.hours, gst.minutes, gst.seconds, gst.from_base_ind'
                           ||', gst.exclude_ind, gst.modified_ind, gst.calc_uom_conv_ind, gst.to_qty_uom'
                           -- END B3124291 Incorporated Mini-Pack K Features to Outboud APIs
                           ||', gst.text_code'
                           ||', gst.attribute_category, gst.attribute1, gst.attribute2, gst.attribute3'
                           ||', gst.attribute4, gst.attribute5, gst.attribute6, gst.attribute7'
                           ||', gst.attribute8, gst.attribute9, gst.attribute10, gst.attribute11'
                           ||', gst.attribute12, gst.attribute13, gst.attribute14, gst.attribute15'
                           ||', gst.attribute16, gst.attribute17, gst.attribute18, gst.attribute19'
                           ||', gst.attribute20, gst.attribute21, gst.attribute22, gst.attribute23'
                           ||', gst.attribute24, gst.attribute25, gst.attribute26, gst.attribute27'
                           ||', gst.attribute28, gst.attribute29, gst.attribute30, gst.creation_date'
                           ||', gst.created_by, fu4.user_name, gst.last_update_date'
                           ||', gst.last_updated_by, fu5.user_name, gst.last_update_login'
                           ||')';

   spec_test_table_list := ' gmd_spec_tests gst, fnd_user fu4, fnd_user fu5, gmd_test_methods gtm, gmd_qc_tests gqt';

   spec_test_where_clause := ' gst.created_by = fu4.user_id AND gst.last_updated_by=fu5.user_id '
                           ||' AND   gst.test_id = gqt.test_id AND gst.test_method_id=gtm.test_method_id'
                           ||' AND   gst.spec_id = gs.spec_id AND 1=:dummy2 ';

   spec_test_using_clause := '1';

   -- GMD_CUSTOMER_SPEC_VRS basic clauses

   cust_vr_column_list := '  system.gmd_cust_spec_vr_rec_type' -- 5284247
                        ||'( cvr.spec_vr_id, cvr.organization_id, cvr.cust_id, NULL, cvr.order_id, NULL'
                        ||', cvr.order_line, cvr.order_line_id, cvr.ship_to_site_id, NULL, cvr.org_id'
                        ||', NULL, cvr.spec_vr_status, NULL, cvr.start_date, cvr.end_date, cvr.sampling_plan_id'
                        ||', NULL, cvr.sample_inv_trans_ind, cvr.lot_optional_on_sample, cvr.coa_type'
                        ||', cvr.coa_at_ship_ind, cvr.coa_at_invoice_ind, cvr.coa_req_from_supl_ind'
                        ||', cvr.delete_mark, cvr.text_code, cvr.attribute_category'
                        ||', cvr.attribute1, cvr.attribute2, cvr.attribute3, cvr.attribute4, cvr.attribute5'
                        ||', cvr.attribute6, cvr.attribute7, cvr.attribute8, cvr.attribute9, cvr.attribute10'
                        ||', cvr.attribute11, cvr.attribute12, cvr.attribute13, cvr.attribute14, cvr.attribute15'
                        ||', cvr.attribute16, cvr.attribute17, cvr.attribute18, cvr.attribute19, cvr.attribute20'
                        ||', cvr.attribute21, cvr.attribute22, cvr.attribute23, cvr.attribute24, cvr.attribute25'
                        ||', cvr.attribute26, cvr.attribute27, cvr.attribute28, cvr.attribute29, cvr.attribute30'
                        ||', cvr.creation_date, cvr.created_by, fu6.user_name, cvr.last_update_date'
                        ||', cvr.last_updated_by, fu7.user_name, cvr.last_update_login'
                        ||')';
   cust_vr_table_list := ' gmd_customer_spec_vrs cvr, fnd_user fu6, fnd_user fu7, oe_order_headers_all oeh';

   cust_vr_where_clause := ' cvr.created_by = fu6.user_id AND cvr.last_updated_by = fu7.user_id'
                         ||' AND cvr.spec_id = gs.spec_id AND cvr.order_id = oeh.header_id(+) AND 1=:dummy3';

   cust_vr_using_clause := '1';

   -- GMD_WIP_SPEC_VRS basic clauses
   --  Bug 3704090; Added fields delayed_lot_entry and auto_sample_ind

   wip_vr_column_list := ' system.gmd_wip_spec_vr_rec_type' --5284247
                       ||'( wvr.spec_vr_id, wvr.organization_id, wvr.batch_id, gbh.batch_no, wvr.recipe_id, wvr.recipe_no'
                       ||', wvr.recipe_version, wvr.formula_id, wvr.formula_no, wvr.formula_vers, wvr.routing_id'
                       ||', wvr.routing_no, wvr.routing_vers, wvr.step_id, wvr.step_no, wvr.oprn_id, wvr.oprn_no'
                       ||', wvr.oprn_vers, wvr.charge, wvr.spec_vr_status, NULL, wvr.start_date, wvr.end_date'
                       ||', wvr.sampling_plan_id, NULL, wvr.sample_inv_trans_ind, wvr.lot_optional_on_sample'
					   ||', wvr.delayed_lot_entry, wvr.auto_sample_ind'
                       ||', wvr.control_lot_attrib_ind, wvr.out_of_spec_lot_status_id, wvr.in_spec_lot_status_id'
                       ||', wvr.coa_type, wvr.control_batch_step_ind, wvr.coa_at_ship_ind, wvr.coa_at_invoice_ind'
                       ||', wvr.coa_req_from_supl_ind, wvr.delete_mark, wvr.text_code, wvr.attribute_category'
                       ||', wvr.attribute1, wvr.attribute2, wvr.attribute3, wvr.attribute4, wvr.attribute5'
                       ||', wvr.attribute6, wvr.attribute7, wvr.attribute8, wvr.attribute9, wvr.attribute10'
                       ||', wvr.attribute11, wvr.attribute12, wvr.attribute13, wvr.attribute14, wvr.attribute15'
                       ||', wvr.attribute16, wvr.attribute17, wvr.attribute18, wvr.attribute19, wvr.attribute20'
                       ||', wvr.attribute21, wvr.attribute22, wvr.attribute23, wvr.attribute24, wvr.attribute25'
                       ||', wvr.attribute26, wvr.attribute27, wvr.attribute28, wvr.attribute29, wvr.attribute30'
                       ||', wvr.creation_date, wvr.created_by, fu8.user_name, wvr.last_update_date'
                       ||', wvr.last_updated_by, fu9.user_name, wvr.last_update_login'
                       ||')';

   wip_vr_table_list := ' gmd_wip_spec_vrs wvr, fnd_user fu8, fnd_user fu9, gme_batch_header gbh';

   wip_vr_where_clause := ' wvr.created_by = fu8.user_id AND wvr.last_updated_by = fu9.user_id'
                        ||' AND wvr.batch_id= gbh.batch_id(+) and gbh.batch_type(+) = 0'
                        ||' AND wvr.spec_id = gs.spec_id and 1=:dummy4';

   wip_vr_using_clause := '1';

   -- GMD_SUPPLIER_SPEC_VRS basic clauses
   --  Bug 3704090; Added fields delayed_lot_entry and auto_sample_ind

   supl_vr_column_list := ' system.gmd_supl_spec_vr_rec_type' -- 5284247
                        ||'( svr.po_header_id, NULL, svr.spec_vr_id, svr.organization_id, svr.supplier_id'
                        ||', v.segment1, svr.supplier_site_id, NULL, svr.org_id, svr.po_line_id'
                        ||', NULL, svr.spec_vr_status, NULL, svr.start_date, svr.end_date'
                        ||', svr.sampling_plan_id, NULL, svr.sample_inv_trans_ind, svr.lot_optional_on_sample'
			||', svr.delayed_lot_entry, svr.auto_sample_ind'
                        ||', svr.coa_type, svr.coa_at_ship_ind, svr.coa_at_invoice_ind, svr.coa_req_from_supl_ind'
		       	||', svr.out_of_spec_lot_status_id, svr.in_spec_lot_status_id'
                        ||', svr.delete_mark, svr.text_code, svr.attribute_category, svr.attribute1'
                        ||', svr.attribute2, svr.attribute3, svr.attribute4, svr.attribute5, svr.attribute6'
                        ||', svr.attribute7, svr.attribute8, svr.attribute9, svr.attribute10, svr.attribute11'
                        ||', svr.attribute12, svr.attribute13, svr.attribute14, svr.attribute15, svr.attribute16'
                        ||', svr.attribute17, svr.attribute18, svr.attribute19, svr.attribute20, svr.attribute21'
                        ||', svr.attribute22, svr.attribute23, svr.attribute24, svr.attribute25, svr.attribute26'
                        ||', svr.attribute27, svr.attribute28, svr.attribute29, svr.attribute30, svr.creation_date'
                        ||', svr.created_by, fu10.user_name, svr.last_update_date, svr.last_updated_by'
                        ||', fu11.user_name, svr.last_update_login'
                        ||')';

   supl_vr_table_list := ' gmd_supplier_spec_vrs svr, fnd_user fu10, fnd_user fu11, po_vendors v';

   supl_vr_where_clause := ' svr.created_by = fu10.user_id AND svr.last_updated_by = fu11.user_id'
                         ||' AND svr.spec_id = gs.spec_id AND v.vendor_id = svr.supplier_id AND 1=:dummy5';
   supl_vr_using_clause := '1';

   -- GMD_INVENTORY_SPEC_VRS basic clauses
   --  Bug 3704090; Added fields delayed_lot_entry and auto_sample_ind

   inv_vr_column_list := ' system.gmd_inv_spec_vr_rec_type' -- 5284247
                       ||'( ivr.spec_vr_id, ivr.organization_id, ivr.parent_lot_number, ivr.lot_number'
                       ||', ivr.subinventory, ivr.locator_id, ivr.spec_vr_status, NULL, ivr.start_date'
                       ||', ivr.end_date, ivr.sampling_plan_id, NULL, ivr.sample_inv_trans_ind'
                       ||', ivr.control_lot_attrib_ind, ivr.lot_optional_on_sample'
                       ||', ivr.delayed_lot_entry, ivr.auto_sample_ind'
                       ||', ivr.in_spec_lot_status_id'
                       ||', ivr.out_of_spec_lot_status_id, ivr.control_batch_step_ind, ivr.coa_type'
                       ||', ivr.coa_at_ship_ind, ivr.coa_at_invoice_ind, ivr.coa_req_from_supl_ind'
                       ||', ivr.delete_mark, ivr.text_code, ivr.attribute_category, ivr.attribute1'
                       ||', ivr.attribute2, ivr.attribute3, ivr.attribute4, ivr.attribute5, ivr.attribute6'
                       ||', ivr.attribute7, ivr.attribute8, ivr.attribute9, ivr.attribute10, ivr.attribute11'
                       ||', ivr.attribute12, ivr.attribute13, ivr.attribute14, ivr.attribute15'
                       ||', ivr.attribute16, ivr.attribute17, ivr.attribute18, ivr.attribute19'
                       ||', ivr.attribute20, ivr.attribute21, ivr.attribute22, ivr.attribute23'
                       ||', ivr.attribute24, ivr.attribute25, ivr.attribute26, ivr.attribute27'
                       ||', ivr.attribute28, ivr.attribute29, ivr.attribute30, ivr.creation_date'
                       ||', ivr.created_by, fu12.user_name, ivr.last_update_date, ivr.last_updated_by'
                       ||', fu13.user_name, ivr.last_update_login'
                       ||')';
   inv_vr_table_list := ' gmd_inventory_spec_vrs ivr, fnd_user fu12, fnd_user fu13';

   inv_vr_where_clause := ' ivr.created_by = fu12.user_id AND ivr.last_updated_by = fu13.user_id'
                        ||' AND ivr.spec_id = gs.spec_id AND 1=:dummy6';
   inv_vr_using_clause := '1';

   -- START B3124291 Incorporated Mini-Pack K Features to Outboud APIs
   -- GMD_MONITORING_SPEC_VRS basic clauses

   mon_vr_column_list := ' system.gmd_mon_spec_vr_rec_type' -- 5284247
                       ||'( mvr.spec_vr_id, mvr.spec_id, mvr.rule_type, mvr.locator_organization_id, mvr.subinventory'
                       ||', mvr.locator_id, mvr.resources, mvr.resource_organization_id, mvr.resource_instance_id'
                       ||', mvr.spec_vr_status, NULL, mvr.start_date, mvr.end_date'
                       ||', mvr.sampling_plan_id, NULL, mvr.delete_mark, mvr.text_code'
                       ||', mvr.attribute_category, mvr.attribute1, mvr.attribute2, mvr.attribute3'
                       ||', mvr.attribute4, mvr.attribute5, mvr.attribute6, mvr.attribute7, mvr.attribute8'
                       ||', mvr.attribute9, mvr.attribute10, mvr.attribute11, mvr.attribute12, mvr.attribute13'
                       ||', mvr.attribute14, mvr.attribute15, mvr.attribute16, mvr.attribute17, mvr.attribute18'
                       ||', mvr.attribute19, mvr.attribute20, mvr.attribute21, mvr.attribute22, mvr.attribute23'
                       ||', mvr.attribute24, mvr.attribute25, mvr.attribute26, mvr.attribute27, mvr.attribute28'
                       ||', mvr.attribute29, mvr.attribute30, mvr.creation_date, mvr.created_by'
                       ||', mvr.last_updated_by, mvr.last_update_date, mvr.last_update_login'
                       ||')';
   mon_vr_table_list := ' gmd_monitoring_spec_vrs mvr, fnd_user fu14, fnd_user fu15';

   mon_vr_where_clause := ' mvr.created_by = fu14.user_id AND mvr.last_updated_by = fu15.user_id'
                        ||' AND mvr.spec_id = gs.spec_id AND 1=:dummy7';
   mon_vr_using_clause := '1';
   -- END B3124291 Incorporated Mini-Pack K Features to Outboud APIs


    -- Now comes the fun. We need to add conditions that restrict which rows are retrieved
    -- from each table by inspecting the parameters that are passed in and build a list of
    -- bind variable values as we go along.

    -- We start with the base table itself, GMD_SPECIFICATIONS

    IF p_from_spec_name IS NOT NULL
    THEN
      g_from_spec_name := p_from_spec_name;
      main_where_clause := main_where_clause||' AND gs.spec_name >= :from_spec_name';
      main_using_clause := main_using_clause||', gmd_outbound_apis_pub.g_from_spec_name';
    END IF;

    IF p_to_spec_name IS NOT NULL
    THEN
      g_to_spec_name := p_to_spec_name;
      main_where_clause := main_where_clause||' AND gs.spec_name <= :to_spec_name';
      main_using_clause := main_using_clause||', gmd_outbound_apis_pub.g_to_spec_name';
    END IF;

    IF p_spec_id IS NOT NULL
    THEN
      gmd_outbound_apis_pub.g_spec_id := p_spec_id;
      main_where_clause := main_where_clause||' AND gs.spec_id = :spec_id';
      main_using_clause := main_using_clause||', gmd_outbound_apis_pub.g_spec_id';
    END IF;

    IF p_spec_version IS NOT NULL
    THEN
      g_spec_version := p_spec_version;
      main_where_clause := main_where_clause||' AND gs.spec_vers = :spec_version';
      main_using_clause := main_using_clause||', gmd_outbound_apis_pub.g_spec_version';
    END IF;

    IF p_from_grade_code IS NOT NULL
    THEN
      g_from_grade_code := p_from_grade_code;
      main_where_clause := main_where_clause||' AND gs.grade_code >= :from_grade_code';
      main_using_clause := main_using_clause||', gmd_outbound_apis_pub.g_from_grade_code';
    END IF;

    IF p_to_grade_code IS NOT NULL
    THEN
      g_to_grade_code := p_to_grade_code;
      main_where_clause := main_where_clause||' AND gs.grade <= :to_grade_code';
      main_using_clause := main_using_clause||', gmd_outbound_apis_pub.g_to_grade_code';
    END IF;

    IF p_inventory_item_id IS NOT NULL
    THEN
      g_inventory_item_id := p_inventory_item_id;
      main_where_clause := main_where_clause|| ' AND gs.inventory_item_id = :inventory_item_id';
      main_using_clause := main_using_clause|| ', gmd_outbound_apis_pub.g_inventory_item_id';
    END if;

-- Start RLNAGARA Bug # 4548546
    IF p_from_revision IS NOT NULL
    THEN
      g_from_revision := p_from_revision;
      main_where_clause := main_where_clause||' AND gs.revision >= :from_revision';
      main_using_clause := main_using_clause||', gmd_outbound_apis_pub.g_from_revision';
    END IF;

    IF p_to_revision IS NOT NULL
    THEN
      g_to_revision := p_to_revision;
      main_where_clause := main_where_clause||' AND gs.revision <= :to_revision';
      main_using_clause := main_using_clause||', gmd_outbound_apis_pub.g_to_revision';
    END IF;
-- End RLNAGARA Bug # 4548546

    IF p_from_item_number IS NOT NULL and p_to_item_number IS NOT NULL
    THEN
      g_from_item_number := p_from_item_number;
      g_to_item_number := p_to_item_number;
      main_where_clause := main_where_clause
                        ||' AND gs.inventory_item_id IN (SELECT inventory_item_id FROM mtl_system_items_b_kfv'
                        ||' WHERE concatenated_segments BETWEEN :from_item_number AND :to_item_number'
			||' AND organization_id = gs.owner_organization_id)';
      main_using_clause := main_using_clause||', gmd_outbound_apis_pub.g_from_item_number, gmd_outbound_apis_pub.g_to_item_number';
    ELSIF p_from_item_number IS NOT NULL
    THEN
      g_from_item_number := p_from_item_number;
      main_where_clause := main_where_clause
                        ||' AND gs.inventory_item_id IN (SELECT inventory_item_id FROM mtl_system_items_b_kfv'
                        ||' WHERE concatenated_segments >= :from_item_number'
			||' AND organization_id = gs.owner_organization_id)';
      main_using_clause := main_using_clause||', gmd_outbound_apis_pub.g_from_item_number';
    ELSIF p_to_item_number IS NOT NULL
    THEN
      g_to_item_number := p_to_item_number;
      main_where_clause := main_where_clause
                        ||' AND gs.inventory_item_id IN (SELECT inventory_item_id FROM mtl_system_items_b_kfv'
                        ||' WHERE concatenated_segments <= :to_item_number'
			||' AND organization_id = gs.owner_organization_id)';
      main_using_clause := main_using_clause||', gmd_outbound_apis_pub.g_to_item_number';
    END IF;

    IF p_owner_organization_code IS NOT NULL
    THEN
      g_owner_organization_code := p_owner_organization_code;
      main_where_clause := main_where_clause|| ' AND gs.owner_organization_id = (SELECT organization_id'
                                        || ' FROM mtl_organizations WHERE organization_code = :owner_organization_code)';
      main_using_clause := main_using_clause|| ', gmd_outbound_apis_pub.g_owner_organization_code';
    END IF;

    IF p_spec_status IS NOT NULL
    THEN
      g_spec_status := p_spec_status;
      main_where_clause := main_where_clause|| ' AND gs.spec_status = :spec_status';
      main_using_clause := main_using_clause|| ', gmd_outbound_apis_pub.g_spec_status';
    END IF;

    IF p_spec_delete_mark IS NOT NULL
    THEN
      g_spec_delete_mark := p_spec_delete_mark;
      main_where_clause := main_where_clause|| ' AND gs.delete_mark = :delete_mark';
      main_using_clause := main_using_clause|| ', gmd_outbound_apis_pub.g_spec_delete_mark';
    END IF;

    IF p_from_spec_last_update IS NOT NULL
    THEN
      gmd_outbound_apis_pub.g_from_spec_last_update := p_from_spec_last_update;
      main_where_clause := main_where_clause||' AND gs.last_update_date >= :from_spec_last_update';
      main_using_clause := main_using_clause||', gmd_outbound_apis_pub.g_from_spec_last_update';
    END IF;

    IF p_to_spec_last_update IS NOT NULL
    THEN
      gmd_outbound_apis_pub.g_to_spec_last_update := p_to_spec_last_update;
      main_where_clause := main_where_clause||' AND gs.last_update_date <= :to_spec_last_update';
      main_using_clause := main_using_clause||', gmd_outbound_apis_pub.g_to_spec_last_update';
    END IF;

    -- START B3124291 Incorporated Mini-Pack K Features to Outboud APIs
    IF p_overlay_ind IS NOT NULL
    THEN
      gmd_outbound_apis_pub.g_overlay_ind := p_overlay_ind;
      main_where_clause := main_where_clause||' AND gs.overlay_ind = :overlay_ind';
      main_using_clause := main_using_clause||', gmd_outbound_apis_pub.g_overlay_ind';
    END IF;

    IF p_spec_type IS NOT NULL
    THEN
      gmd_outbound_apis_pub.g_spec_type := p_spec_type;
      main_where_clause := main_where_clause||' AND gs.spec_type = :spec_type';
      main_using_clause := main_using_clause||', gmd_outbound_apis_pub.g_spec_type';
    END IF;

    IF p_base_spec_id IS NOT NULL
    THEN
      gmd_outbound_apis_pub.g_base_spec_id := p_base_spec_id;
      main_where_clause := main_where_clause||' AND gs.base_spec_id = :base_spec_id';
      main_using_clause := main_using_clause||', gmd_outbound_apis_pub.g_base_spec_id';
    END IF;

    IF p_base_spec_name IS NOT NULL OR p_base_spec_version IS NOT NULL
    THEN
      main_table_list := main_table_list || ', gmd_specifications_b gsp';
      main_where_clause := main_where_clause || ' AND gsp.spec_id = gs.base_spec_id';

      IF p_base_spec_name IS NOT NULL
      THEN
        gmd_outbound_apis_pub.g_base_spec_name := p_base_spec_name;
        main_where_clause := main_where_clause||' AND gsp.spec_name = :base_spec_name';
        main_using_clause := main_using_clause||', gmd_outbound_apis_pub.g_base_spec_name';
      END IF;

      IF p_base_spec_version IS NOT NULL
      THEN
        gmd_outbound_apis_pub.g_base_spec_name := p_base_spec_name;
        main_where_clause := main_where_clause||' AND gsp.spec_vers = :base_spec_version';
        main_using_clause := main_using_clause||', gmd_outbound_apis_pub.g_base_spec_version';
      END IF;

    END IF;
    -- END B3124291 Incorporated Mini-Pack K Features to Outboud APIs

    -- Now sort out retrieval from GMD_SPEC_TESTS

    IF p_test_code IS NOT NULL OR p_test_id IS NOT NULL OR p_test_method_code IS NOT NULL
    OR p_test_method_id IS NOT NULL OR p_test_qty_uom IS NOT NULL OR p_test_priority IS NOT NULL
    OR p_from_test_last_update IS NOT NULL OR p_to_test_last_update IS NOT NULL
    OR p_test_delete_mark IS NOT NULL
    -- START B3124291 Incorporated Mini-Pack K Features to Outboud APIs
    OR p_from_base_ind IS NOT NULL OR p_exclude_ind IS NOT NULL OR p_modified_ind IS NOT NULL
    OR p_calc_uom_conv_ind IS NOT NULL OR p_to_qty_uom IS NOT NULL
    -- END B3124291 Incorporated Mini-Pack K Features to Outboud APIs
    THEN

      -- Add the tables to the main list and join to it.

      main_where_clause := main_where_clause
                        ||' AND gs.spec_id IN '
                        ||' (SELECT mgst.spec_id FROM gmd_spec_tests mgst '
                        ||'  WHERE 1=1';

      -- Now work down the parameters that apply against this table and add to the
      -- main where clause and the spec_test where clause.

      IF p_test_code IS NOT NULL
      THEN
        gmd_outbound_apis_pub.g_test_code := p_test_code;
        main_table_list := main_table_list||', gmd_qc_tests_b gqtb';
        main_where_clause := main_where_clause||' AND gqtb.test_code = :p_test_code';
        main_where_clause := main_where_clause||' AND mgst.test_id = gqtb.test_id';
        main_using_clause := main_using_clause||', gmd_outbound_apis_pub.g_test_code';

        spec_test_where_clause := spec_test_where_clause||' AND gst.test_id=gqtb.test_id';
      END IF;

      IF p_test_id IS NOT NULL
      THEN
        gmd_outbound_apis_pub.g_test_id := p_test_id;
        main_where_clause := main_where_clause||' AND mgst.test_id = :p_test_id';
        main_using_clause := main_using_clause||', gmd_outbound_apis_pub.g_test_id';

        spec_test_where_clause := spec_test_where_clause||' AND gst.test_id = :p_test_id';
        spec_test_using_clause := spec_test_using_clause||', gmd_outbound_apis_pub.g_test_id';
      END IF;

      IF p_test_method_id IS NOT NULL
      THEN
        gmd_outbound_apis_pub.g_test_method_id := p_test_method_id;
        main_where_clause := main_where_clause||' AND gtm.test_method_id = :p_test_method_id';
        main_using_clause := main_using_clause||', gmd_outbound_apis_pub.g_test_method_id';

        spec_test_where_clause := spec_test_where_clause||' AND gtm.test_method_id = :p_test_method_id';
        spec_test_using_clause := spec_test_using_clause||', gmd_outbound_apis_pub.g_test_method_id';
      END IF;

      IF p_test_method_code IS NOT NULL
      THEN
        -- Need to link in the test methods table if the test method code parameter is passed

        main_table_list := main_table_list||', gmd_test_methods mgtm';

        gmd_outbound_apis_pub.g_test_method_code := p_test_method_code;
        main_where_clause := main_where_clause||' AND mgtm.test_method_code = :p_test_method_code'
                                              ||' AND mgtm.test_method_id = mgst.test_method_id';
        main_using_clause := main_using_clause||', gmd_outbound_apis_pub.g_test_method_code';

        spec_test_where_clause := spec_test_where_clause||' AND gtm.test_method_code = :p_test_method_code';
        spec_test_using_clause := spec_test_using_clause||', gmd_outbound_apis_pub.g_test_method_code';

      END IF;

      IF p_test_qty_uom IS NOT NULL
      THEN
        gmd_outbound_apis_pub.g_test_qty_uom := p_test_qty_uom;
        main_where_clause := main_where_clause||' AND mgst.test_qty_uom = :p_test_qty_uom';
        main_using_clause := main_using_clause||', gmd_outbound_apis_pub.g_test_qty_uom';

        spec_test_where_clause := spec_test_where_clause||' AND gst.test_qty_uom = :p_test_qty_uom';
        spec_test_using_clause := spec_test_using_clause||', gmd_outbound_apis_pub.g_test_qty_uom';
      END IF;

      IF p_test_priority IS NOT NULL
      THEN
        gmd_outbound_apis_pub.g_test_priority := p_test_priority;
        main_where_clause := main_where_clause||' AND mgst.test_priority = :p_test_priority';
        main_using_clause := main_using_clause||', gmd_outbound_apis_pub.g_test_priority';

        spec_test_where_clause := spec_test_where_clause||' AND gst.test_priority = :p_test_priority';
        spec_test_using_clause := spec_test_using_clause||', gmd_outbound_apis_pub.g_test_priority';
      END IF;

      IF p_from_test_last_update IS NOT NULL
      THEN
        gmd_outbound_apis_pub.g_from_test_last_update := p_from_test_last_update;
        main_where_clause := main_where_clause||' AND mgst.last_update_date >= :p_from_test_last_update';
        main_using_clause := main_using_clause||', gmd_outbound_apis_pub.g_from_test_last_update';

        spec_test_where_clause := spec_test_where_clause||' AND gst.last_update_date >= :p_from_test_last_update';
        spec_test_using_clause := spec_test_using_clause||', gmd_outbound_apis_pub.g_from_test_last_update';
      END IF;

      IF p_to_test_last_update IS NOT NULL
      THEN
        gmd_outbound_apis_pub.g_to_test_last_update := p_to_test_last_update;
        main_where_clause := main_where_clause||' AND mgst.to_update_date <= :p_to_test_last_update';
        main_using_clause := main_using_clause||', gmd_outbound_apis_pub.g_to_test_last_update';

        spec_test_where_clause := spec_test_where_clause||' AND gst.to_update_date <= :p_to_test_last_update';
        spec_test_using_clause := spec_test_using_clause||', gmd_outbound_apis_pub.g_to_test_last_update';
      END IF;

      IF p_test_delete_mark IS NOT NULL
      THEN
        gmd_outbound_apis_pub.g_test_delete_mark := p_test_delete_mark;
        main_where_clause := main_where_clause||' AND mgst.delete_mark = :p_test_delete_mark';
        main_using_clause := main_using_clause||', gmd_outbound_apis_pub.g_test_delete_mark';

        spec_test_where_clause := spec_test_where_clause||' AND gst.delete_mark = :p_test_delete_mark';
        spec_test_using_clause := spec_test_using_clause||', gmd_outbound_apis_pub.g_test_delete_mark';
      END IF;

      -- START B3124291 Incorporated Mini-Pack K Features to Outboud APIs
      IF p_from_base_ind IS NOT NULL
      THEN
        gmd_outbound_apis_pub.g_from_base_ind := p_from_base_ind;
        main_where_clause := main_where_clause||' AND mgst.from_base_ind = :p_from_base_ind';
        main_using_clause := main_using_clause||', gmd_outbound_apis_pub.g_from_base_ind';

        spec_test_where_clause := spec_test_where_clause||' AND gst.from_base_ind = :p_from_base_ind';
        spec_test_using_clause := spec_test_using_clause||', gmd_outbound_apis_pub.g_from_base_ind';
      END IF;

      IF p_exclude_ind IS NOT NULL
      THEN
        gmd_outbound_apis_pub.g_exclude_ind := p_exclude_ind;
        main_where_clause := main_where_clause||' AND mgst.exclude_ind = :p_exclude_ind';
        main_using_clause := main_using_clause||', gmd_outbound_apis_pub.g_exclude_ind';

        spec_test_where_clause := spec_test_where_clause||' AND gst.exclude_ind = :p_exclude_ind';
        spec_test_using_clause := spec_test_using_clause||', gmd_outbound_apis_pub.g_exclude_ind';
      END IF;

      IF p_modified_ind IS NOT NULL
      THEN
        gmd_outbound_apis_pub.g_modified_ind := p_modified_ind;
        main_where_clause := main_where_clause||' AND mgst.modified_ind = :p_modified_ind';
        main_using_clause := main_using_clause||', gmd_outbound_apis_pub.g_modified_ind';

        spec_test_where_clause := spec_test_where_clause||' AND gst.modified_ind = :p_modified_ind';
        spec_test_using_clause := spec_test_using_clause||', gmd_outbound_apis_pub.g_modified_ind';
      END IF;

      IF p_calc_uom_conv_ind IS NOT NULL
      THEN
        gmd_outbound_apis_pub.g_calc_uom_conv_ind := p_calc_uom_conv_ind;
        main_where_clause := main_where_clause||' AND mgst.calc_uom_conv_ind = :p_calc_uom_conv_ind';
        main_using_clause := main_using_clause||', gmd_outbound_apis_pub.g_calc_uom_conv_ind';

        spec_test_where_clause := spec_test_where_clause||' AND gst.calc_uom_conv_ind = :p_calc_uom_conv_ind';
        spec_test_using_clause := spec_test_using_clause||', gmd_outbound_apis_pub.g_calc_uom_conv_ind';
      END IF;

      IF p_to_qty_uom IS NOT NULL
      THEN
        gmd_outbound_apis_pub.g_to_qty_uom := p_to_qty_uom;
        main_where_clause := main_where_clause||' AND mgst.to_qty_uom = :p_to_qty_uom';
        main_using_clause := main_using_clause||', gmd_outbound_apis_pub.g_to_qty_uom';

        spec_test_where_clause := spec_test_where_clause||' AND gst.to_qty_uom = :p_to_qty_uom';
        spec_test_using_clause := spec_test_using_clause||', gmd_outbound_apis_pub.g_to_qty_uom';
      END IF;

      -- END B3124291 Incorporated Mini-Pack K Features to Outboud APIs

      main_where_clause := main_where_clause||' ) ';

    END IF;

    -- Now sort out the retrieval from GMD_WIP_SPEC_VRS


    IF p_wip_vr_status IS NOT NULL OR p_wip_vr_organization_code IS NOT NULL OR p_wip_vr_batch_orgn_code IS NOT NULL
    OR p_wip_vr_batch_no IS NOT NULL OR p_wip_vr_batch_id IS NOT NULL OR p_wip_vr_recipe_no IS NOT NULL
    OR p_wip_vr_recipe_version IS NOT NULL OR p_wip_vr_recipe_id IS NOT NULL OR p_wip_vr_formula_no IS NOT NULL
    OR p_wip_vr_formula_version IS NOT NULL OR p_wip_vr_formula_id IS NOT NULL OR p_wip_vr_formulaline_no IS NOT NULL
    OR p_wip_vr_formulaline_id IS NOT NULL OR p_wip_vr_line_type IS NOT NULL OR p_wip_vr_routing_no IS NOT NULL
    OR p_wip_vr_routing_version IS NOT NULL OR p_wip_vr_routing_id IS NOT NULL OR p_wip_vr_step_no IS NOT NULL
    OR p_wip_vr_step_id IS NOT NULL OR p_wip_vr_operation_no IS NOT NULL OR p_wip_vr_operation_version IS NOT NULL
    OR p_wip_vr_operation_id IS NOT NULL OR p_wip_vr_start_date	IS NOT NULL OR p_wip_vr_end_date IS NOT NULL
    OR p_wip_vr_coa_type IS NOT NULL OR p_wip_vr_sampling_plan IS NOT NULL OR p_wip_vr_sampling_plan_id IS NOT NULL
    OR p_wip_vr_delete_mark IS NOT NULL OR p_wip_vr_from_last_update IS NOT NULL OR p_wip_vr_to_last_update IS NOT NULL
    THEN
      -- Add the table to the main list and join to it.

      main_where_clause := main_where_clause
                        ||' AND gs.spec_id IN'
                        ||' (SELECT mwvr.spec_id'
                        ||'  FROM gmd_wip_spec_vrs mwvr'
                        ||'  WHERE 1=1';

      IF p_wip_vr_status IS NOT NULL
      THEN
        gmd_outbound_apis_pub.g_wip_vr_status := p_wip_vr_status;
        main_where_clause := main_where_clause||' AND mwvr.spec_vr_status = :wip_spec_vr_status';
        main_using_clause := main_using_clause||', gmd_outbound_apis_pub.g_wip_vr_status';

        wip_vr_where_clause := wip_vr_where_clause||' AND wvr.spec_vr_status = :wip_spec_vr_status';
        wip_vr_using_clause := wip_vr_using_clause||', gmd_outbound_apis_pub.g_wip_vr_status';

      END IF;

      IF p_wip_vr_organization_code IS NOT NULL
      THEN
        gmd_outbound_apis_pub.g_wip_vr_organization_code := p_wip_vr_organization_code;
        main_where_clause := main_where_clause||' AND mwvr.organization_id = (SELECT organization_id '
 	                            ||'FROM mtl_organizations WHERE organization_code = :wip_vr_organization_code)';
        main_using_clause := main_using_clause||', gmd_outbound_apis_pub.g_wip_vr_organization_code';

        wip_vr_where_clause := wip_vr_where_clause||' AND wvr.organization_id = (SELECT organization_id '
	                            ||'FROM mtl_organizations WHERE organization_code = :wip_vr_organization_code)';
        wip_vr_using_clause := wip_vr_using_clause||', gmd_outbound_apis_pub.g_wip_vr_organization_code';

      END IF;

      IF p_wip_vr_batch_orgn_code IS NOT NULL
      THEN
        gmd_outbound_apis_pub.g_wip_vr_batch_orgn_code := p_wip_vr_batch_orgn_code;
        main_where_clause := main_where_clause||' AND mwvr.batch_id IN'
                                              ||' (SELECT batch_id FROM gme_batch_header '
                                              ||'  WHERE organization_id = (SELECT organization_id FROM'
				   ||' mtl_parameters WHERE organization_code = :wip_vr_batch_orgn_code) )';
        main_using_clause := main_using_clause||', gmd_outbound_apis_pub.g_wip_vr_batch_orgn_code';

        wip_vr_where_clause := wip_vr_where_clause||' AND wvr.batch_id IN'
                                              ||' (SELECT batch_id FROM gme_batch_header '
                                              ||'  WHERE organization_id = (SELECT organization_id FROM'
			           ||' mtl_parameters WHERE organization_code = :wip_vr_batch_orgn_code) )';
        wip_vr_using_clause := wip_vr_using_clause||', gmd_outbound_apis_pub.g_wip_vr_batch_orgn_code';
      END IF;

      IF p_wip_vr_batch_no IS NOT NULL
      THEN
        gmd_outbound_apis_pub.g_wip_vr_batch_no := p_wip_vr_batch_no;
        main_where_clause := main_where_clause||' AND mwvr.batch_id IN'
                                              ||' (SELECT batch_id FROM gme_batch_header '
                                              ||'  WHERE batch_no = :wip_vr_batch_no '
                                              ||'  AND batch_type = 0)';
        main_using_clause := main_using_clause||', gmd_outbound_apis_pub.g_wip_vr_batch_no';

        wip_vr_where_clause := wip_vr_where_clause||' AND wvr.batch_id IN'
                                              ||' (SELECT batch_id FROM gme_batch_header '
                                              ||'  WHERE batch_no = :wip_vr_batch_no '
                                              ||'  AND batch_type = 0)';
        wip_vr_using_clause := wip_vr_using_clause||', gmd_outbound_apis_pub.g_wip_vr_batch_no';
      END IF;

      IF p_wip_vr_batch_id IS NOT NULL
      THEN
        gmd_outbound_apis_pub.g_wip_vr_batch_id := p_wip_vr_batch_id;
        main_where_clause := main_where_clause||' AND mwvr.batch_id = :wip_vr_batch_id';
        main_using_clause := main_using_clause||', gmd_outbound_apis_pub.g_wip_vr_batch_id';

        wip_vr_where_clause := wip_vr_where_clause||' AND wvr.batch_id = :wip_vr_batch_id';
        wip_vr_using_clause := wip_vr_using_clause||', gmd_outbound_apis_pub.g_wip_vr_batch_id';
      END IF;

      IF p_wip_vr_recipe_no IS NOT NULL
      THEN
        gmd_outbound_apis_pub.g_wip_vr_recipe_no := p_wip_vr_recipe_no;
        main_where_clause := main_where_clause||' AND mwvr.recipe_no = :wip_vr_recipe_no';
        main_using_clause := main_using_clause||', gmd_outbound_apis_pub.g_wip_vr_recipe_no';

        wip_vr_where_clause := wip_vr_where_clause||' AND wvr.recipe_no = :wip_vr_recipe_no';
        wip_vr_using_clause := wip_vr_using_clause||', gmd_outbound_apis_pub.g_wip_vr_recipe_no';
      END IF;

      IF p_wip_vr_recipe_version IS NOT NULL
      THEN
        gmd_outbound_apis_pub.g_wip_vr_recipe_version := p_wip_vr_recipe_version;
        main_where_clause := main_where_clause||' AND mwvr.recipe_version = :wip_vr_recipe_version';
        main_using_clause := main_using_clause||', gmd_outbound_apis_pub.g_wip_vr_recipe_version';

        wip_vr_where_clause := wip_vr_where_clause||' AND wvr.recipe_version = :wip_vr_recipe_version';
        wip_vr_using_clause := wip_vr_using_clause||', gmd_outbound_apis_pub.g_wip_vr_recipe_version';
      END IF;

      IF p_wip_vr_recipe_id IS NOT NULL
      THEN
        gmd_outbound_apis_pub.g_wip_vr_recipe_id := p_wip_vr_recipe_id;
        main_where_clause := main_where_clause||' AND mwvr.recipe_id = :wip_vr_recipe_id';
        main_using_clause := main_using_clause||', gmd_outbound_apis_pub.g_wip_vr_recipe_id';

        wip_vr_where_clause := wip_vr_where_clause||' AND wvr.recipe_id = :wip_vr_recipe_id';
        wip_vr_using_clause := wip_vr_using_clause||', gmd_outbound_apis_pub.g_wip_vr_recipe_id';
      END IF;

      IF p_wip_vr_formula_no IS NOT NULL
      THEN
        gmd_outbound_apis_pub.g_wip_vr_formula_no := p_wip_vr_formula_no;
        main_where_clause := main_where_clause||' AND mwvr.formula_no = :wip_vr_formula_no';
        main_using_clause := main_using_clause||', gmd_outbound_apis_pub.g_wip_vr_formula_no';

        wip_vr_where_clause := wip_vr_where_clause||' AND wvr.formula_no = :wip_vr_formula_no';
        wip_vr_using_clause := wip_vr_using_clause||', gmd_outbound_apis_pub.g_wip_vr_formula_no';
      END IF;

      IF p_wip_vr_formula_version IS NOT NULL
      THEN
        gmd_outbound_apis_pub.g_wip_vr_formula_version := p_wip_vr_formula_version;
        main_where_clause := main_where_clause||' AND mwvr.formula_vers = :wip_vr_formula_version';
        main_using_clause := main_using_clause||', gmd_outbound_apis_pub.g_wip_vr_formula_version';

        wip_vr_where_clause := wip_vr_where_clause||' AND wvr.formula_vers = :wip_vr_formula_version';
        wip_vr_using_clause := wip_vr_using_clause||', gmd_outbound_apis_pub.g_wip_vr_formula_version';
      END IF;

      IF p_wip_vr_formula_id IS NOT NULL
      THEN
        gmd_outbound_apis_pub.g_wip_vr_formula_id := p_wip_vr_formula_id;
        main_where_clause := main_where_clause||' AND mwvr.formula_id = :wip_vr_formula_id';
        main_using_clause := main_using_clause||', gmd_outbound_apis_pub.g_wip_vr_formula_id';

        wip_vr_where_clause := wip_vr_where_clause||' AND wvr.formula_id = :wip_vr_formula_id';
        wip_vr_using_clause := wip_vr_using_clause||', gmd_outbound_apis_pub.g_wip_vr_formula_id';
      END IF;

      IF p_wip_vr_formulaline_no IS NOT NULL
      THEN
        gmd_outbound_apis_pub.g_wip_vr_formulaline_no := p_wip_vr_formulaline_no;
        main_where_clause := main_where_clause||' AND mwvr.formulaline_no = :wip_vr_formulaline_no';
        main_using_clause := main_using_clause||', gmd_outbound_apis_pub.g_wip_vr_formulaline_no';

        wip_vr_where_clause := wip_vr_where_clause||' AND wvr.formulaline_no = :wip_vr_formulaline_no';
        wip_vr_using_clause := wip_vr_using_clause||', gmd_outbound_apis_pub.g_wip_vr_formulaline_no';
      END IF;

      IF p_wip_vr_formulaline_id IS NOT NULL
      THEN
        gmd_outbound_apis_pub.g_wip_vr_formulaline_id := p_wip_vr_formulaline_id;
        main_where_clause := main_where_clause||' AND mwvr.formulaline_id = :wip_vr_formulaline_id';
        main_using_clause := main_using_clause||', gmd_outbound_apis_pub.g_wip_vr_formulaline_id';

        wip_vr_where_clause := wip_vr_where_clause||' AND wvr.formulaline_id = :wip_vr_formulaline_id';
        wip_vr_using_clause := wip_vr_using_clause||', gmd_outbound_apis_pub.g_wip_vr_formulaline_id';
      END IF;

      IF p_wip_vr_routing_no IS NOT NULL
      THEN
        gmd_outbound_apis_pub.g_wip_vr_formula_no := p_wip_vr_routing_no;
        main_where_clause := main_where_clause||' AND mwvr.routing_no = :wip_vr_routing_no';
        main_using_clause := main_using_clause||', gmd_outbound_apis_pub.g_wip_vr_routing_no';

        wip_vr_where_clause := wip_vr_where_clause||' AND wvr.routing_no = :wip_vr_routing_no';
        wip_vr_using_clause := wip_vr_using_clause||', gmd_outbound_apis_pub.g_wip_vr_routing_no';
      END IF;

      IF p_wip_vr_routing_version IS NOT NULL
      THEN
        gmd_outbound_apis_pub.g_wip_vr_routing_version := p_wip_vr_routing_version;
        main_where_clause := main_where_clause||' AND mwvr.routing_vers = :wip_vr_routing_version';
        main_using_clause := main_using_clause||', gmd_outbound_apis_pub.g_wip_vr_routing_version';

        wip_vr_where_clause := wip_vr_where_clause||' AND wvr.routing_vers = :wip_vr_routing_version';
        wip_vr_using_clause := wip_vr_using_clause||', gmd_outbound_apis_pub.g_wip_vr_routing_version';
      END IF;

      IF p_wip_vr_routing_id IS NOT NULL
      THEN
        gmd_outbound_apis_pub.g_wip_vr_routing_id := p_wip_vr_routing_id;
        main_where_clause := main_where_clause||' AND mwvr.routing_id = :wip_vr_routing_id';
        main_using_clause := main_using_clause||', gmd_outbound_apis_pub.g_wip_vr_routing_id';

        wip_vr_where_clause := wip_vr_where_clause||' AND wvr.routing_id = :wip_vr_routing_id';
        wip_vr_using_clause := wip_vr_using_clause||', gmd_outbound_apis_pub.g_wip_vr_routing_id';
      END IF;

      IF p_wip_vr_step_no IS NOT NULL
      THEN
        gmd_outbound_apis_pub.g_wip_vr_step_no := p_wip_vr_step_no;
        main_where_clause := main_where_clause||' AND mwvr.step_no = :wip_vr_step_no';
        main_using_clause := main_using_clause||', gmd_outbound_apis_pub.g_wip_vr_step_no';

        wip_vr_where_clause := wip_vr_where_clause||' AND wvr.step_no = :wip_vr_step_no';
        wip_vr_using_clause := wip_vr_using_clause||', gmd_outbound_apis_pub.g_wip_vr_step_no';
      END IF;

      IF p_wip_vr_step_id IS NOT NULL
      THEN
        gmd_outbound_apis_pub.g_wip_vr_step_id := p_wip_vr_step_id;
        main_where_clause := main_where_clause||' AND mwvr.step_id = :wip_vr_step_id';
        main_using_clause := main_using_clause||', gmd_outbound_apis_pub.g_wip_vr_step_id';

        wip_vr_where_clause := wip_vr_where_clause||' AND wvr.step_id = :wip_vr_step_id';
        wip_vr_using_clause := wip_vr_using_clause||', gmd_outbound_apis_pub.g_wip_vr_step_id';
      END IF;

      IF p_wip_vr_operation_no IS NOT NULL
      THEN
        gmd_outbound_apis_pub.g_wip_vr_operation_no := p_wip_vr_operation_no;
        main_where_clause := main_where_clause||' AND mwvr.oprn_no = :wip_vr_operation_no';
        main_using_clause := main_using_clause||', gmd_outbound_apis_pub.g_wip_vr_operation_no';

        wip_vr_where_clause := wip_vr_where_clause||' AND wvr.oprn_no = :wip_vr_operation_no';
        wip_vr_using_clause := wip_vr_using_clause||', gmd_outbound_apis_pub.g_wip_vr_operation_no';
      END IF;

      IF p_wip_vr_operation_version IS NOT NULL
      THEN
        gmd_outbound_apis_pub.g_wip_vr_operation_version := p_wip_vr_operation_version;
        main_where_clause := main_where_clause||' AND mwvr.oprn_vers = :wip_vr_operation_version';
        main_using_clause := main_using_clause||', gmd_outbound_apis_pub.g_wip_vr_operation_version';

        wip_vr_where_clause := wip_vr_where_clause||' AND wvr.oprn_vers = :wip_vr_operation_version';
        wip_vr_using_clause := wip_vr_using_clause||', gmd_outbound_apis_pub.g_wip_vr_operation_version';
      END IF;

      IF p_wip_vr_operation_id IS NOT NULL
      THEN
        gmd_outbound_apis_pub.g_wip_vr_operation_id := p_wip_vr_operation_id;
        main_where_clause := main_where_clause||' AND mwvr.oprn_id = :wip_vr_operation_id';
        main_using_clause := main_using_clause||', gmd_outbound_apis_pub.g_wip_vr_operation_id';

        wip_vr_where_clause := wip_vr_where_clause||' AND wvr.oprn_id = :wip_vr_operation_id';
        wip_vr_using_clause := wip_vr_using_clause||', gmd_outbound_apis_pub.g_wip_vr_operation_id';
      END IF;

      IF p_wip_vr_start_date IS NOT NULL
      THEN
        gmd_outbound_apis_pub.g_wip_vr_start_date := p_wip_vr_start_date;
        main_where_clause := main_where_clause||' AND mwvr.start_date >= :wip_vr_start_date';
        main_using_clause := main_using_clause||', gmd_outbound_apis_pub.g_wip_vr_start_date';

        wip_vr_where_clause := wip_vr_where_clause||' AND wvr.start_date >= :wip_vr_start_date';
        wip_vr_using_clause := wip_vr_using_clause||', gmd_outbound_apis_pub.g_wip_vr_start_date';
      END IF;

      IF p_wip_vr_end_date IS NOT NULL
      THEN
        gmd_outbound_apis_pub.g_wip_vr_end_date := p_wip_vr_end_date;
        main_where_clause := main_where_clause||' AND mwvr.end_date <= :wip_vr_end_date';
        main_using_clause := main_using_clause||', gmd_outbound_apis_pub.g_wip_vr_end_date';

        wip_vr_where_clause := wip_vr_where_clause||' AND wvr.end_date <= :wip_vr_end_date';
        wip_vr_using_clause := wip_vr_using_clause||', gmd_outbound_apis_pub.g_wip_vr_end_date';
      END IF;

      IF p_wip_vr_coa_type IS NOT NULL
      THEN
        gmd_outbound_apis_pub.g_wip_vr_coa_type := p_wip_vr_coa_type;
        main_where_clause := main_where_clause||' AND mwvr.coa_type = :wip_vr_coa_type';
        main_using_clause := main_using_clause||', gmd_outbound_apis_pub.g_wip_vr_coa_type';

        wip_vr_where_clause := wip_vr_where_clause||' AND wvr.coa_type = :wip_vr_coa_type';
        wip_vr_using_clause := wip_vr_using_clause||', gmd_outbound_apis_pub.g_wip_vr_coa_type';
      END IF;

      IF p_wip_vr_sampling_plan_id IS NOT NULL
      THEN
        gmd_outbound_apis_pub.g_wip_vr_sampling_plan_id := p_wip_vr_sampling_plan_id;
        main_where_clause := main_where_clause||' AND mwvr.sampling_plan_id = :wip_vr_sampling_plan_id';
        main_using_clause := main_using_clause||', gmd_outbound_apis_pub.g_wip_vr_sampling_plan_id';

        wip_vr_where_clause := wip_vr_where_clause||' AND wvr.sampling_plan_id = :wip_vr_sampling_plan_id';
        wip_vr_using_clause := wip_vr_using_clause||', gmd_outbound_apis_pub.g_wip_vr_sampling_plan_id';
      END IF;

      IF p_wip_vr_delete_mark IS NOT NULL
      THEN
        gmd_outbound_apis_pub.g_wip_vr_delete_mark := p_wip_vr_delete_mark;
        main_where_clause := main_where_clause||' AND mwvr.delete_mark >= :wip_vr_delete_mark';
        main_using_clause := main_using_clause||', gmd_outbound_apis_pub.g_wip_vr_delete_mark';

        wip_vr_where_clause := wip_vr_where_clause||' AND wvr.delete_mark >= :wip_vr_delete_mark';
        wip_vr_using_clause := wip_vr_using_clause||', gmd_outbound_apis_pub.g_wip_vr_delete_mark';
      END IF;

      IF p_wip_vr_from_last_update IS NOT NULL
      THEN
        gmd_outbound_apis_pub.g_wip_vr_from_last_update := p_wip_vr_from_last_update;
        main_where_clause := main_where_clause||' AND mwvr.last_update_date >= :wip_vr_from_last_update';
        main_using_clause := main_using_clause||', gmd_outbound_apis_pub.g_wip_vr_from_last_update';

        wip_vr_where_clause := wip_vr_where_clause||' AND wvr.last_update_date >= :wip_vr_from_last_update';
        wip_vr_using_clause := wip_vr_using_clause||', gmd_outbound_apis_pub.g_wip_vr_from_last_update';
      END IF;

      IF p_wip_vr_to_last_update IS NOT NULL
      THEN
        gmd_outbound_apis_pub.g_wip_vr_to_last_update := p_wip_vr_to_last_update;
        main_where_clause := main_where_clause||' AND mwvr.last_update_date <= :wip_vr_to_last_update';
        main_using_clause := main_using_clause||', gmd_outbound_apis_pub.g_wip_vr_to_last_update';

        wip_vr_where_clause := wip_vr_where_clause||' AND wvr.last_update_date <= :wip_vr_to_last_update';
        wip_vr_using_clause := wip_vr_using_clause||', gmd_outbound_apis_pub.g_wip_vr_to_last_update';
      END IF;

      main_where_clause := main_where_clause||' ) ';

    END IF;

    -- Now sort out the retrieval from GMD_CUSTOMER_SPEC_VRS

    IF p_cust_vr_start_date IS NOT NULL OR p_cust_vr_end_date IS NOT NULL OR p_cust_vr_status IS NOT NULL
    OR p_cust_vr_organization_code IS NOT NULL OR p_cust_vr_org_id IS NOT NULL OR p_cust_vr_coa_type IS NOT NULL
    OR p_cust_vr_customer IS NOT NULL OR p_cust_vr_customer_id IS NOT NULL OR p_cust_vr_order_number IS NOT NULL
    OR p_cust_vr_order_id IS NOT NULL OR p_cust_vr_order_type IS NOT NULL OR p_cust_vr_order_line_no IS NOT NULL
    OR p_cust_vr_order_line_id IS NOT NULL OR p_cust_vr_ship_to_location IS NOT NULL
    OR p_cust_vr_ship_to_site_id IS NOT NULL OR p_cust_vr_operating_unit IS NOT NULL
    OR p_cust_vr_delete_mark    IS NOT NULL OR p_cust_vr_from_last_update IS NOT NULL
    OR p_cust_vr_to_last_update IS NOT NULL
    THEN
      -- Add the table to the list and join to it.


      main_where_clause := main_where_clause
                        ||' AND gs.spec_id IN'
                        ||' (SELECT mcvr.spec_id FROM gmd_customer_spec_vrs mcvr'
                        ||'  WHERE 1=1';

      IF p_cust_vr_start_date IS NOT NULL
      THEN
        g_cust_vr_start_date := p_cust_vr_start_date;
        main_where_clause := main_where_clause||' AND mcvr.start_date >= :cust_vr_start_date';
        main_using_clause := main_using_clause||', gmd_outbound_apis_pub.g_cust_vr_start_date';

        cust_vr_where_clause := cust_vr_where_clause||' AND cvr.start_date >= :cust_vr_start_date';
        cust_vr_using_clause := cust_vr_using_clause||', gmd_outbound_apis_pub.g_cust_vr_start_date';
      END IF;

      IF p_cust_vr_end_date IS NOT NULL
      THEN
        g_cust_vr_end_date := p_cust_vr_end_date;
        main_where_clause := main_where_clause||' AND mcvr.end_date <= :cust_vr_end_date';
        main_using_clause := main_using_clause||', gmd_outbound_apis_pub.g_cust_vr_end_date';

        cust_vr_where_clause := cust_vr_where_clause||' AND cvr.end_date <= :cust_vr_end_date';
        cust_vr_using_clause := cust_vr_using_clause||', gmd_outbound_apis_pub.g_cust_vr_end_date';
      END IF;

      IF p_cust_vr_status IS NOT NULL
      THEN
        g_cust_vr_status := p_cust_vr_status;
        main_where_clause := main_where_clause||' AND mcvr.spec_vr_status = :cust_vr_status';
        main_using_clause := main_using_clause||', gmd_outbound_apis_pub.g_cust_vr_status';

        cust_vr_where_clause := cust_vr_where_clause||' AND cvr.spec_vr_status = :cust_vr_status';
        cust_vr_using_clause := cust_vr_using_clause||', gmd_outbound_apis_pub.g_cust_vr_status';
      END IF;

      IF p_cust_vr_organization_code IS NOT NULL
      THEN
        g_cust_vr_organization_code := p_cust_vr_organization_code;
        main_where_clause := main_where_clause||' AND mcvr.organization_id = (SELECT organization_id '
	                          ||'FROM mtl_organizations WHERE organization_code = :cust_vr_organization_code)';
        main_using_clause := main_using_clause||', gmd_outbound_apis_pub.g_cust_vr_organization_code';

        cust_vr_where_clause := cust_vr_where_clause||' AND cvr.organization_id = (SELECT organization_id '
	                         ||'FROM mtl_organizations WHERE organization_code = :cust_vr_organization_code)';
        cust_vr_using_clause := cust_vr_using_clause||', gmd_outbound_apis_pub.g_cust_vr_organization_code';
      END IF;

      IF p_cust_vr_org_id IS NOT NULL
      THEN
        g_cust_vr_org_id := p_cust_vr_org_id;
        main_where_clause := main_where_clause||' AND mcvr.org_id = :cust_vr_org_id';
        main_using_clause := main_using_clause||', gmd_outbound_apis_pub.g_cust_vr_org_id';

        cust_vr_where_clause := cust_vr_where_clause||' AND cvr.org_id = :cust_vr_org_id';
        cust_vr_using_clause := cust_vr_using_clause||', gmd_outbound_apis_pub.g_cust_vr_org_id';
      END IF;

      IF p_cust_vr_coa_type IS NOT NULL
      THEN
        g_cust_vr_coa_type := p_cust_vr_coa_type;
        main_where_clause := main_where_clause||' AND mcvr.coa_type = :cust_vr_coa_type';
        main_using_clause := main_using_clause||', gmd_outbound_apis_pub.g_cust_vr_coa_type';

        cust_vr_where_clause := cust_vr_where_clause||' AND cvr.coa_type = :cust_vr_coa_type';
        cust_vr_using_clause := cust_vr_using_clause||', gmd_outbound_apis_pub.g_cust_vr_coa_type';
      END IF;

      IF p_cust_vr_customer_id IS NOT NULL
      THEN
        g_cust_vr_customer_id := p_cust_vr_customer_id;
        main_where_clause := main_where_clause||' AND mcvr.cust_id = :cust_vr_customer_id';
        main_using_clause := main_using_clause||', gmd_outbound_apis_pub.g_cust_vr_customer_id';

        cust_vr_where_clause := cust_vr_where_clause||' AND cvr.cust_id = :cust_vr_customer_id';
        cust_vr_using_clause := cust_vr_using_clause||', gmd_outbound_apis_pub.g_cust_vr_customer_id';
      END IF;

      IF p_cust_vr_customer IS NOT NULL
      THEN
        g_cust_vr_customer := p_cust_vr_customer;
        main_where_clause := main_where_clause||' AND mcvr.cust_id IN'
                                              ||' (SELECT hzca.cust_account_id'
                                              ||'  FROM hz_parties hzp, hz_cust_accounts_all hzca'
                                              ||'  WHERE hzp.party_id = hzca.party_id AND'
                                              ||'  UPPER(hzp.party_name)'
                                              ||'  LIKE UPPER(:cust_vr_customer)'
                                              ||' )';
        main_using_clause := main_using_clause||', gmd_outbound_apis_pub.g_cust_vr_customer';

        cust_vr_where_clause := cust_vr_where_clause||' AND cvr.cust_id IN'
                                                    ||' (SELECT hzca.cust_account_id'
                                                    ||'  FROM hz_parties hzp, hz_cust_accounts_all hzca'
                                                    ||'  WHERE hzp.party_id = hzca.party_id AND'
                                                    ||'  UPPER(hzp.party_name)'
                                                    ||'  LIKE UPPER(:cust_vr_customer)'
                                                    ||' )';
        cust_vr_using_clause := cust_vr_using_clause||', gmd_outbound_apis_pub.g_cust_vr_customer';
      END IF;

      IF p_cust_vr_order_id IS NOT NULL
      THEN
        g_cust_vr_order_id := p_cust_vr_order_id;
        main_where_clause := main_where_clause||' AND mcvr.order_id = :cust_vr_order_id';
        main_using_clause := main_using_clause||', gmd_outbound_apis_pub.g_cust_vr_order_id';

        cust_vr_where_clause := cust_vr_where_clause||' AND cvr.order_id = :cust_vr_order_id';
        cust_vr_using_clause := cust_vr_using_clause||', gmd_outbound_apis_pub.g_cust_vr_order_id';
      END IF;

      IF p_cust_vr_order_number IS NOT NULL
      THEN
        g_cust_vr_order_number := p_cust_vr_order_number;
        main_where_clause := main_where_clause||' AND mcvr.order_id = (select header_id '
                                              ||' from oe_order_headers_all'
                                              ||' where order_number = :cust_vr_order_number)';
        main_using_clause := main_using_clause||', gmd_outbound_apis_pub.g_cust_vr_order_number';

        cust_vr_where_clause := cust_vr_where_clause||' AND oeh.order_number = :cust_vr_order_number';
        cust_vr_using_clause := cust_vr_using_clause||', gmd_outbound_apis_pub.g_cust_vr_order_number';
      END IF;


      IF p_cust_vr_delete_mark IS NOT NULL
      THEN
        g_cust_vr_delete_mark := p_cust_vr_delete_mark;
        main_where_clause := main_where_clause||' AND mcvr.delete_mark = :cust_vr_delete_mark';
        main_using_clause := main_using_clause||', gmd_outbound_apis_pub.g_cust_vr_delete_mark';

        cust_vr_where_clause := cust_vr_where_clause||' AND cvr.delete_mark = :cust_vr_delete_mark';
        cust_vr_using_clause := cust_vr_using_clause||', gmd_outbound_apis_pub.g_cust_vr_delete_mark';
      END IF;

      IF p_cust_vr_from_last_update IS NOT NULL
      THEN
        g_cust_vr_from_last_update := p_cust_vr_from_last_update;
        main_where_clause := main_where_clause||' AND mcvr.last_update_date >= :cust_vr_from_last_update';
        main_using_clause := main_using_clause||', gmd_outbound_apis_pub.g_cust_vr_from_last_update';

        cust_vr_where_clause := cust_vr_where_clause||' AND cvr.last_update_date >= :cust_vr_from_last_update';
        cust_vr_using_clause := cust_vr_using_clause||', gmd_outbound_apis_pub.g_cust_vr_from_last_update';
      END IF;

      IF p_cust_vr_to_last_update IS NOT NULL
      THEN
        g_cust_vr_to_last_update := p_cust_vr_to_last_update;
        main_where_clause := main_where_clause||' AND mcvr.last_update_date <= :cust_vr_to_last_update';
        main_using_clause := main_using_clause||', gmd_outbound_apis_pub.g_cust_vr_to_last_update';

        cust_vr_where_clause := cust_vr_where_clause||' AND cvr.last_update_date <= :cust_vr_to_last_update';
        cust_vr_using_clause := cust_vr_using_clause||', gmd_outbound_apis_pub.g_cust_vr_to_last_update';
      END IF;

      IF p_cust_vr_order_line_id IS NOT NULL
      THEN
        g_cust_vr_order_line_id := p_cust_vr_order_line_id;
        main_where_clause := main_where_clause||' AND mcvr.order_line_id = :cust_vr_order_line_id';
        main_using_clause := main_using_clause||', gmd_outbound_apis_pub.g_cust_vr_order_line_id';

        cust_vr_where_clause := cust_vr_where_clause||' AND cvr.order_line_id = :cust_vr_order_line_id';
        cust_vr_using_clause := cust_vr_using_clause||', gmd_outbound_apis_pub.g_cust_vr_order_line_id';
      END IF;

      IF p_cust_vr_order_line_no IS NOT NULL
      THEN
        g_cust_vr_order_line_no := p_cust_vr_order_line_no;
        main_where_clause := main_where_clause||' AND mcvr.order_line = :cust_vr_order_line_no';
        main_using_clause := main_using_clause||', gmd_outbound_apis_pub.g_cust_vr_order_line_no';

        cust_vr_where_clause := cust_vr_where_clause||' AND cvr.order_line = :cust_vr_order_line_no';
        cust_vr_using_clause := cust_vr_using_clause||', gmd_outbound_apis_pub.g_cust_vr_order_line_no';
      END IF;

      IF p_cust_vr_order_type IS NOT NULL
      THEN
        g_cust_vr_order_type := p_cust_vr_order_type;
        main_where_clause := main_where_clause||' AND  mcvr.order_id IN (select header_id '
                                              ||' FROM oe_order_headers_all h, oe_transaction_types_all t'
                                              ||' WHERE h.order_type_id = t.transaction_type_id'
                                              ||' AND   t.transaction_type_code = :cust_vr_order_type)';
        main_using_clause := main_using_clause||', gmd_outbound_apis_pub.g_cust_vr_order_type';

        cust_vr_table_list := cust_vr_table_list||', oe_transaction_types_all tta';
        cust_vr_where_clause := cust_vr_where_clause||' AND oeh.order_type_id = tta.transaction_type_id'
                                                    ||' AND tta.transaction_type_code = :cust_vr_order_type';
        cust_vr_using_clause := cust_vr_using_clause||', gmd_outbound_apis_pub.g_cust_vr_order_type';
      END IF;

      IF p_cust_vr_ship_to_site_id IS NOT NULL
      THEN
        g_cust_vr_ship_to_site_id := p_cust_vr_ship_to_site_id;
        main_where_clause := main_where_clause||' AND mcvr.ship_to_site_id = :cust_vr_ship_to_site_id';
        main_using_clause := main_using_clause||', gmd_outbound_apis_pub.g_cust_vr_ship_to_site_id';

        cust_vr_where_clause := cust_vr_where_clause||' AND cvr.ship_to_site_id = :cust_vr_ship_to_site_id';
        cust_vr_using_clause := cust_vr_using_clause||', gmd_outbound_apis_pub.g_cust_vr_ship_to_site_id';
      END IF;

      IF p_cust_vr_ship_to_location IS NOT NULL
      THEN
        g_cust_vr_ship_to_location := p_cust_vr_ship_to_location;
        main_where_clause := main_where_clause||' AND mcvr.ship_to_site_use_id = '
                                              ||' (SELECT site_use_id'
                                              ||'  FROM   hz_cust_site_uses_all'
                                              ||'  WHERE  location = :cust_vr_ship_to_location)';
        main_using_clause := main_using_clause||', gmd_outbound_apis_pub.g_cust_vr_ship_to_location';

        cust_vr_where_clause := cust_vr_where_clause||' AND cvr.ship_to_site_use_id = '
                                                    ||'   (SELECT site_use_id'
                                                    ||'    FROM   hz_cust_site_uses_all'
                                                    ||'    WHERE  location = :cust_vr_ship_to_location)';
        cust_vr_using_clause := cust_vr_using_clause||', gmd_outbound_apis_pub.g_cust_vr_ship_to_location';
      END IF;

      IF p_cust_vr_operating_unit IS NOT NULL
      THEN
        g_cust_vr_operating_unit := p_cust_vr_operating_unit;
        main_where_clause := main_where_clause||' AND mcvr.org_id  = '
                                              ||' (SELECT organization_id'
                                              ||'  FROM   hr_operating_units'
                                              ||'  WHERE  name = :cust_vr_operating_unit)';
        main_using_clause := main_using_clause||', gmd_outbound_apis_pub.g_cust_vr_operating_unit';

        cust_vr_where_clause := cust_vr_where_clause||' AND cvr.org_id  = '
                                              ||' (SELECT organization_id'
                                              ||'  FROM   hr_operating_units'
                                              ||'  WHERE  name = :cust_vr_operating_unit)';
        cust_vr_using_clause := cust_vr_using_clause||', gmd_outbound_apis_pub.g_cust_vr_operating_unit';

      END IF;

      main_where_clause := main_where_clause||' ) ';

    END IF;

    -- Sort out the GMD_SUPPLIER_SPEC_VRS parameters

    IF p_supl_vr_start_date IS NOT NULL OR p_supl_vr_end_date IS NOT NULL OR p_supl_vr_status IS NOT NULL
    OR p_supl_vr_organization_code IS NOT NULL OR p_supl_vr_org_id IS NOT NULL OR p_supl_vr_coa_type IS NOT NULL
    OR p_supl_vr_supplier IS NOT NULL OR p_supl_vr_supplier_id IS NOT NULL OR p_supl_vr_po_number IS NOT NULL
    OR p_supl_vr_po_id IS NOT NULL OR p_supl_vr_po_line_no IS NOT NULL OR p_supl_vr_po_line_id IS NOT NULL
    OR p_supl_vr_supplier_site IS NOT NULL OR p_supl_vr_supplier_site_id IS NOT NULL
    OR p_supl_vr_operating_unit IS NOT NULL OR p_supl_vr_delete_mark IS NOT NULL
    OR p_supl_vr_from_last_update IS NOT NULL OR p_supl_vr_to_last_update IS NOT NULL
    THEN

      -- Include the table in the list, and join to it.


      main_where_clause := main_where_clause
                           ||' AND gs.spec_id IN'
                           ||' ( SELECT spec_id fROM gmd_supplier_spec_vrs msvr, po_vendors mpv'
                           ||'   WHERE  msvr.supplier_id = mpv.vendor_id';

      IF p_supl_vr_start_date IS NOT NULL
      THEN
        g_supl_vr_start_date := p_supl_vr_start_date;
        main_where_clause := main_where_clause||' AND msvr.start_date >= :supl_vr_start_date';
        main_using_clause := main_using_clause||', gmd_outbound_apis_pub.g_supl_vr_start_date';

        supl_vr_where_clause := supl_vr_where_clause||' AND svr.start_date >= :supl_vr_start_date';
        supl_vr_using_clause := supl_vr_using_clause||', gmd_outbound_apis_pub.g_supl_vr_start_date';
      END IF;

      IF p_supl_vr_end_date IS NOT NULL
      THEN
        g_supl_vr_end_date := p_supl_vr_end_date;
        main_where_clause := main_where_clause||' AND msvr.end_date <= :supl_vr_end_date';
        main_using_clause := main_using_clause||', gmd_outbound_apis_pub.g_supl_vr_end_date';

        supl_vr_where_clause := supl_vr_where_clause||' AND svr.end_date >= :supl_vr_end_date';
        supl_vr_using_clause := supl_vr_using_clause||', gmd_outbound_apis_pub.g_supl_vr_end_date';
      END IF;

      IF p_supl_vr_status IS NOT NULL
      THEN
        g_supl_vr_status := p_supl_vr_status;
        main_where_clause := main_where_clause||' AND msvr.spec_vr_status = :supl_vr_status';
        main_using_clause := main_using_clause||', gmd_outbound_apis_pub.g_supl_vr_status';

        supl_vr_where_clause := supl_vr_where_clause||' AND svr.status = :supl_vr_status';
        supl_vr_using_clause := supl_vr_using_clause||', gmd_outbound_apis_pub.g_supl_vr_status';
      END IF;

      IF p_supl_vr_organization_code IS NOT NULL
      THEN
        g_supl_vr_organization_code := p_supl_vr_organization_code;
        main_where_clause := main_where_clause||' AND msvr.organization_id = (SELECT organization_id '
	                     ||'FROM mtl_organizations WHERE organization_code = :supl_vr_organization_code)';
        main_using_clause := main_using_clause||', gmd_outbound_apis_pub.g_supl_vr_organization_code';

        supl_vr_where_clause := supl_vr_where_clause||' AND svr.organization_id = (SELECT organization_id '
	                     ||'FROM mtl_organizations WHERE organization_code = :supl_vr_organization_code)';
        supl_vr_using_clause := supl_vr_using_clause||', gmd_outbound_apis_pub.g_supl_vr_organization_code';
      END IF;

      IF p_supl_vr_org_id IS NOT NULL
      THEN
        g_supl_vr_org_id := p_supl_vr_org_id;
        main_where_clause := main_where_clause||' AND msvr.org_id = :supl_vr_org_id';
        main_using_clause := main_using_clause||', gmd_outbound_apis_pub.g_supl_vr_org_id';

        supl_vr_where_clause := supl_vr_where_clause||' AND svr.org_id = :supl_vr_org_id';
        supl_vr_using_clause := supl_vr_using_clause||', gmd_outbound_apis_pub.g_supl_vr_org_id';
      END IF;

      IF p_supl_vr_coa_type IS NOT NULL
      THEN
        g_supl_vr_coa_type := p_supl_vr_coa_type;
        main_where_clause := main_where_clause||' AND msvr.coa_type = :supl_vr_coa_type';
        main_using_clause := main_using_clause||', gmd_outbound_apis_pub.g_supl_vr_coa_type';

        supl_vr_where_clause := supl_vr_where_clause||' AND svr.coa_type = :supl_vr_coa_type';
        supl_vr_using_clause := supl_vr_using_clause||', gmd_outbound_apis_pub.g_supl_vr_coa_type';
      END IF;

      IF p_supl_vr_coa_type IS NOT NULL
      THEN
        g_supl_vr_coa_type := p_supl_vr_coa_type;
        main_where_clause := main_where_clause||' AND msvr.coa_type = :supl_vr_coa_type';
        main_using_clause := main_using_clause||', gmd_outbound_apis_pub.g_supl_vr_coa_type';

        supl_vr_where_clause := supl_vr_where_clause||' AND svr.coa_type = :supl_vr_coa_type';
        supl_vr_using_clause := supl_vr_using_clause||', gmd_outbound_apis_pub.g_supl_vr_coa_type';
      END IF;

      IF p_supl_vr_supplier_id IS NOT NULL
      THEN
        g_supl_vr_supplier_id := p_supl_vr_supplier_id;
        main_where_clause := main_where_clause||' AND msvr.supplier_id = :supl_vr_supplier_id';
        main_using_clause := main_using_clause||', gmd_outbound_apis_pub.g_supl_vr_supplier_id';

        supl_vr_where_clause := supl_vr_where_clause||' AND svr.supplier_id = :supl_vr_supplier_id';
        supl_vr_using_clause := supl_vr_using_clause||', gmd_outbound_apis_pub.g_supl_vr_supplier_id';
      END IF;

      IF p_supl_vr_supplier IS NOT NULL
      THEN
        g_supl_vr_supplier := p_supl_vr_supplier;
        main_where_clause := main_where_clause||' AND mpv.segment1 = :supl_vr_supplier';
        main_using_clause := main_using_clause||', gmd_outbound_apis_pub.g_supl_vr_supplier';

        supl_vr_where_clause := supl_vr_where_clause||' AND v.segment1 = :supl_vr_supplier';
        supl_vr_using_clause := supl_vr_using_clause||', gmd_outbound_apis_pub.g_supl_vr_supplier';
      END IF;

      IF p_supl_vr_po_number IS NOT NULL
      THEN
        g_supl_vr_po_number := p_supl_vr_po_number;
        main_where_clause := main_where_clause||' AND  msvr.po_line_id IN'
                                              ||' (SELECT pla.po_line_id FROM po_headers_all pha, po_lines_all pla'
                                              ||'  WHERE  pha.segment1 = :supl_vr_po_number'
                                              ||'  AND    pha.po_header_id = pla.po_header_id)';
        main_using_clause := main_using_clause||', gmd_outbound_apis_pub.g_supl_vr_po_number';

        supl_vr_where_clause := supl_vr_where_clause||' AND  svr.po_line_id IN'
                                              ||' (SELECT pla.po_line_id FROM po_headers_all pha, po_lines_all pla'
                                              ||'  WHERE  pha.segment1 = :supl_vr_po_number'
                                              ||'  AND    pha.po_header_id = pla.po_header_id)';
        supl_vr_using_clause := supl_vr_using_clause||', gmd_outbound_apis_pub.g_supl_vr_po_number';
      END IF;

      IF p_supl_vr_po_id IS NOT NULL
      THEN
        g_supl_vr_po_id := p_supl_vr_po_id;
        main_where_clause := main_where_clause||' AND  msvr.po_line_id IN'
                                              ||' (SELECT po_line_id FROM po_lines_all'
                                              ||'  WHERE  po_header_id = :supl_vr_po_id)';
        main_using_clause := main_using_clause||', gmd_outbound_apis_pub.g_supl_vr_po_id';

        supl_vr_where_clause := supl_vr_where_clause||' AND  svr.po_line_id IN'
                                              ||' (SELECT po_line_id FROM po_lines_all'
                                              ||'  WHERE  po_header_id = :supl_vr_po_id)';
        supl_vr_using_clause := supl_vr_using_clause||', gmd_outbound_apis_pub.g_supl_vr_po_id';
      END IF;

      IF p_supl_vr_po_line_no IS NOT NULL
      THEN
        g_supl_vr_po_line_no := p_supl_vr_po_line_no;
        main_where_clause := main_where_clause||' AND  msvr.po_line_id IN'
                                              ||' (SELECT po_line_id FROM po_lines_all'
                                              ||'  WHERE  line_num = :supl_vr_po_line_no)';
        main_using_clause := main_using_clause||', gmd_outbound_apis_pub.g_supl_vr_po_line_no';

        supl_vr_where_clause := supl_vr_where_clause||' AND  svr.po_line_id IN'
                                              ||' (SELECT po_line_id FROM po_lines_all'
                                              ||'  WHERE  line_num = :supl_vr_po_line_no)';
        supl_vr_using_clause := supl_vr_using_clause||', gmd_outbound_apis_pub.g_supl_vr_po_line_no';
      END IF;

      IF p_supl_vr_po_line_id IS NOT NULL
      THEN
        g_supl_vr_po_line_id := p_supl_vr_po_line_id;
        main_where_clause := main_where_clause||' AND  msvr.po_line_id =:supl_vr_po_line_id';
        main_using_clause := main_using_clause||', gmd_outbound_apis_pub.g_supl_vr_po_line_id';

        supl_vr_where_clause := supl_vr_where_clause||' AND  svr.po_line_id = :supl_vr_po_line_id';
        supl_vr_using_clause := supl_vr_using_clause||', gmd_outbound_apis_pub.g_supl_vr_po_line_id';
      END IF;

      IF p_supl_vr_supplier_site_id IS NOT NULL
      THEN
        g_supl_vr_supplier_site_id := p_supl_vr_supplier_site_id;
        main_where_clause := main_where_clause||' AND  msvr.supplier_site_id =:supl_vr_supplier_site_id';
        main_using_clause := main_using_clause||', gmd_outbound_apis_pub.g_supl_vr_supplier_site_id';

        supl_vr_where_clause := supl_vr_where_clause||' AND  svr.supplier_site_id = :supl_vr_supplier_site_id';
        supl_vr_using_clause := supl_vr_using_clause||', gmd_outbound_apis_pub.g_supl_vr_supplier_site_id';
      END IF;

      IF p_supl_vr_supplier_site IS NOT NULL
      THEN
        g_supl_vr_supplier_site := p_supl_vr_supplier_site;
        main_where_clause := main_where_clause||' AND  msvr.supplier_site_id = '
                                              ||' (SELECT vendor_site_id FROM po_vendor_sites_all'
                                              ||'  WHERE  vendor_site_code = :supl_vr_supplier_site';
        main_using_clause := main_using_clause||', gmd_outbound_apis_pub.g_supl_vr_supplier_site';

        supl_vr_where_clause := supl_vr_where_clause||' AND  svr.supplier_site_id = '
                                              ||' (SELECT vendor_site_id FROM po_vendor_sites_all'
                                              ||'  WHERE  vendor_site_code = :supl_vr_supplier_site';
        supl_vr_using_clause := supl_vr_using_clause||', gmd_outbound_apis_pub.g_supl_vr_supplier_site';
      END IF;

      IF p_supl_vr_operating_unit IS NOT NULL
      THEN
        g_supl_vr_operating_unit := p_supl_vr_operating_unit;
        main_where_clause := main_where_clause||' AND msvr.org_id  = '
                                              ||' (SELECT organization_id'
                                              ||'  FROM   hr_operating_units'
                                              ||'  WHERE  name = :supl_vr_operating_unit)';
        main_using_clause := main_using_clause||', gmd_outbound_apis_pub.g_supl_vr_operating_unit';

        supl_vr_where_clause := supl_vr_where_clause||' AND svr.org_id  = '
                                              ||' (SELECT organization_id'
                                              ||'  FROM   hr_operating_units'
                                              ||'  WHERE  name = :supl_vr_operating_unit)';
        supl_vr_using_clause := supl_vr_using_clause||', gmd_outbound_apis_pub.g_supl_vr_operating_unit';

      END IF;

      IF p_supl_vr_from_last_update IS NOT NULL
      THEN
        g_supl_vr_from_last_update := p_supl_vr_from_last_update;
        main_where_clause := main_where_clause||' AND msvr.last_update_date >= :supl_vr_from_last_update';
        main_using_clause := main_using_clause||', gmd_outbound_apis_pub.g_supl_vr_from_last_update';

        supl_vr_where_clause := supl_vr_where_clause||' AND svr.last_update_date >= :supl_vr_from_last_update';
        supl_vr_using_clause := supl_vr_using_clause||', gmd_outbound_apis_pub.g_supl_vr_from_last_update';
      END IF;

      IF p_supl_vr_to_last_update IS NOT NULL
      THEN
        g_supl_vr_to_last_update := p_supl_vr_to_last_update;
        main_where_clause := main_where_clause||' AND msvr.last_update_date <= :supl_vr_to_last_update';
        main_using_clause := main_using_clause||', gmd_outbound_apis_pub.g_supl_vr_to_last_update';

        supl_vr_where_clause := supl_vr_where_clause||' AND svr.last_update_date <= :supl_vr_to_last_update';
        supl_vr_using_clause := supl_vr_using_clause||', gmd_outbound_apis_pub.g_supl_vr_to_last_update';
      END IF;

      IF p_supl_vr_delete_mark IS NOT NULL
      THEN
        g_supl_vr_delete_mark := p_supl_vr_delete_mark;
        main_where_clause := main_where_clause||' AND  msvr.delete_mark =:supl_vr_delete_mark';
        main_using_clause := main_using_clause||', gmd_outbound_apis_pub.g_supl_vr_delete_mark';

        supl_vr_where_clause := supl_vr_where_clause||' AND  svr.delete_mark = :supl_vr_delete_mark';
        supl_vr_using_clause := supl_vr_using_clause||', gmd_outbound_apis_pub.g_supl_vr_delete_mark';
      END IF;

      main_where_clause := main_where_clause||' ) ';

    END IF;

    -- Sort out the GMD_INVENTORY_SPEC_VRS table's needs

    IF p_inv_vr_start_date IS NOT NULL OR p_inv_vr_end_date IS NOT NULL OR p_inv_vr_status IS NOT NULL
    OR p_inv_vr_organization_code IS NOT NULL OR p_inv_vr_coa_type IS NOT NULL
    OR p_inv_vr_item_number IS NOT NULL OR p_inv_vr_inventory_item_id IS NOT NULL OR p_inv_vr_parent_lot_number IS NOT NULL
    OR p_inv_vr_lot_number IS NOT NULL OR p_inv_vr_subinventory IS NOT NULL OR p_inv_vr_locator IS NOT NULL
    OR p_inv_vr_locator_id IS NOT NULL OR p_inv_vr_sampling_plan IS NOT NULL OR p_inv_vr_sampling_plan_id IS NOT NULL
    OR p_inv_vr_delete_mark IS NOT NULL OR p_inv_vr_from_last_update IS NOT NULL OR p_inv_vr_to_last_update IS NOT NULL
    THEN
      -- Include the table in the list, and join to it.

      main_where_clause := main_where_clause
                        ||' AND gs.spec_id IN'
                        ||' (SELECT mivr.spec_id FROM gmd_inventory_spec_vrs mivr'
                        ||'  WHERE 1=1';


      IF p_inv_vr_start_date IS NOT NULL
      THEN
        g_inv_vr_start_date := p_inv_vr_start_date;
        main_where_clause := main_where_clause||' AND mivr.start_date >= :inv_vr_start_date';
        main_using_clause := main_using_clause||', gmd_outbound_apis_pub.g_inv_vr_start_date';

        inv_vr_where_clause := inv_vr_where_clause||' AND ivr.start_date >= :inv_vr_start_date';
        inv_vr_using_clause := inv_vr_using_clause||', gmd_outbound_apis_pub.g_inv_vr_start_date';
      END IF;

      IF p_inv_vr_end_date IS NOT NULL
      THEN
        g_inv_vr_end_date := p_inv_vr_end_date;
        main_where_clause := main_where_clause||' AND mivr.end_date <= :inv_vr_end_date';
        main_using_clause := main_using_clause||', gmd_outbound_apis_pub.g_inv_vr_end_date';

        inv_vr_where_clause := inv_vr_where_clause||' AND ivr.end_date <= :inv_vr_end_date';
        inv_vr_using_clause := inv_vr_using_clause||', gmd_outbound_apis_pub.g_inv_vr_end_date';
      END IF;

      IF p_inv_vr_status IS NOT NULL
      THEN
        g_inv_vr_status := p_inv_vr_status;
        main_where_clause := main_where_clause||' AND mivr.spec_vr_status = :inv_vr_status';
        main_using_clause := main_using_clause||', gmd_outbound_apis_pub.g_inv_vr_status';

        inv_vr_where_clause := inv_vr_where_clause||' AND ivr.status = :inv_vr_status';
        inv_vr_using_clause := inv_vr_using_clause||', gmd_outbound_apis_pub.g_inv_vr_status';
      END IF;

      IF p_inv_vr_organization_code IS NOT NULL
      THEN
        g_inv_vr_organization_code := p_inv_vr_organization_code;
        main_where_clause := main_where_clause||' AND mivr.organization_id = (SELECT organization_id '
     	                ||'FROM mtl_organizations WHERE organization_code = :inv_vr_organization_code)';
        main_using_clause := main_using_clause||', gmd_outbound_apis_pub.g_inv_vr_organization_code';

        inv_vr_where_clause := inv_vr_where_clause||' AND ivr.organization_id = (SELECT organization_id '
     	                ||'FROM mtl_organizations WHERE organization_code = :inv_vr_organization_code)';
        inv_vr_using_clause := inv_vr_using_clause||', gmd_outbound_apis_pub.g_inv_vr_organization_code';
      END IF;

      IF p_inv_vr_inventory_item_id IS NOT NULL
      THEN
        g_inv_vr_inventory_item_id := p_inv_vr_inventory_item_id;
        main_where_clause := main_where_clause||' AND mivr.lot_number IN'
                                              ||' (SELECT lot_number FROM mtl_lot_numbers'
                                              ||'  WHERE inventory_item_id = :inv_vr_inventory_item_id)';
        main_using_clause := main_using_clause||', gmd_outbound_apis_pub.g_inv_vr_inventory_item_id';

        inv_vr_where_clause := inv_vr_where_clause||' AND ivr.lot_number IN'
                                              ||' (SELECT lot_number FROM mtl_lot_numbers'
                                              ||'  WHERE inventory_item_id = :inv_vr_inventory_item_id)';
        inv_vr_using_clause := inv_vr_using_clause||', gmd_outbound_apis_pub.g_inv_vr_inventory_item_id';
      END IF;

      IF p_inv_vr_item_number IS NOT NULL
      THEN
        g_inv_vr_item_number := p_inv_vr_item_number;
        main_where_clause := main_where_clause||' AND mivr.lot_number IN'
                                              ||' (SELECT l.lot_number FROM mtl_lot_numbers l'
                                              ||'  WHERE l.organization_id IN (SELECT organization_id FROM'
                                              ||'  mtl_system_items_b_kfv WHERE concatenated_segments = :inv_vr_item_number'
                                              ||'  AND inventory_item_id = l.inventory_item_id))';

        main_using_clause := main_using_clause||', gmd_outbound_apis_pub.g_inv_vr_item_number';

        inv_vr_where_clause := inv_vr_where_clause||' AND ivr.lot_number IN'
                                               ||' (SELECT l.lot_number FROM mtl_lot_numbers l'
                                              ||'  WHERE l.organization_id IN (SELECT organization_id FROM'
                                              ||'  mtl_system_items_b_kfv WHERE concatenated_segments = :inv_vr_item_number'
                                              ||'  AND inventory_item_id = l.inventory_item_id))';
        inv_vr_using_clause := inv_vr_using_clause||', gmd_outbound_apis_pub.g_inv_vr_item_number';
      END IF;

      IF p_inv_vr_parent_lot_number IS NOT NULL
      THEN
        g_inv_vr_parent_lot_number := p_inv_vr_parent_lot_number;
        main_where_clause := main_where_clause||' AND mivr.parent_lot_number = :inv_vr_parent_lot_number';
        main_using_clause := main_using_clause||', gmd_outbound_apis_pub.g_inv_vr_parent_lot_number';

        inv_vr_where_clause := inv_vr_where_clause||' AND ivr.parent_lot_number = :inv_vr_parent_lot_number';
        inv_vr_using_clause := inv_vr_using_clause||', gmd_outbound_apis_pub.g_inv_vr_parent_lot_number';
      END IF;

      IF p_inv_vr_lot_number IS NOT NULL
      THEN
        g_inv_vr_lot_number := p_inv_vr_lot_number;
        main_where_clause := main_where_clause||' AND mivr.lot_number = :inv_vr_lot_number';
        main_using_clause := main_using_clause||', gmd_outbound_apis_pub.g_inv_vr_lot_number';

        inv_vr_where_clause := inv_vr_where_clause||' AND ivr.lot_number = :inv_vr_lot_number';
        inv_vr_using_clause := inv_vr_using_clause||', gmd_outbound_apis_pub.g_inv_vr_lot_number';
      END IF;

      IF p_inv_vr_subinventory IS NOT NULL
      THEN
        g_inv_vr_subinventory := p_inv_vr_subinventory;
        main_where_clause := main_where_clause||' AND mivr.subinventory = :inv_vr_subinventory';
        main_using_clause := main_using_clause||', gmd_outbound_apis_pub.g_inv_vr_subinventory';

        inv_vr_where_clause := inv_vr_where_clause||' AND ivr.subinventory = :inv_vr_subinventory';
        inv_vr_using_clause := inv_vr_using_clause||', gmd_outbound_apis_pub.g_inv_vr_subinventory';
      END IF;

      IF p_inv_vr_locator IS NOT NULL
      THEN
        g_inv_vr_locator := p_inv_vr_locator;
        main_where_clause := main_where_clause||' AND mivr.locator_id = (SELECT inventory_location_id '
	                        ||'FROM mtl_item_locations_kfv WHERE concatenated_segments = :inv_vr_locator '
				||'AND organization_id = mivr.organization_id)';
        main_using_clause := main_using_clause||', gmd_outbound_apis_pub.g_inv_vr_locator';

        inv_vr_where_clause := inv_vr_where_clause||' AND ivr.locator_id = (SELECT inventory_location_id '
	                        ||'FROM mtl_item_locations_kfv WHERE concatenated_segments = :inv_vr_locator '
				||'AND organization_id = ivr.organization_id)';
        inv_vr_using_clause := inv_vr_using_clause||', gmd_outbound_apis_pub.g_inv_vr_locator';
      END IF;

      IF p_inv_vr_locator_id IS NOT NULL
      THEN
        g_inv_vr_locator_id := p_inv_vr_locator_id;
        main_where_clause := main_where_clause||' AND mivr.locator_id = :inv_vr_locator_id';
        main_using_clause := main_using_clause||', gmd_outbound_apis_pub.g_inv_vr_locator_id';

        inv_vr_where_clause := inv_vr_where_clause||' AND ivr.locator_id = :inv_vr_locator_id';
        inv_vr_using_clause := inv_vr_using_clause||', gmd_outbound_apis_pub.g_inv_vr_locator_id';
      END IF;

      IF p_inv_vr_sampling_plan_id IS NOT NULL
      THEN
        g_inv_vr_sampling_plan_id := p_inv_vr_sampling_plan_id;
        main_where_clause := main_where_clause||' AND mivr.sampling_plan_id = :inv_vr_sampling_plan_id';
        main_using_clause := main_using_clause||', gmd_outbound_apis_pub.g_inv_vr_sampling_plan_id';

        inv_vr_where_clause := inv_vr_where_clause||' AND ivr.sampling_plan_id = :inv_vr_sampling_plan_id';
        inv_vr_using_clause := inv_vr_using_clause||', gmd_outbound_apis_pub.g_inv_vr_sampling_plan_id';
      END IF;

      IF p_inv_vr_from_last_update IS NOT NULL
      THEN
        g_inv_vr_from_last_update := p_inv_vr_from_last_update;
        main_where_clause := main_where_clause||' AND mivr.last_update_date >= :inv_vr_from_last_update';
        main_using_clause := main_using_clause||', gmd_outbound_apis_pub.g_inv_vr_from_last_update';

        inv_vr_where_clause := inv_vr_where_clause||' AND ivr.last_update_date >= :inv_vr_from_last_update';
        inv_vr_using_clause := inv_vr_using_clause||', gmd_outbound_apis_pub.g_inv_vr_from_last_update';
      END IF;

      IF p_inv_vr_to_last_update IS NOT NULL
      THEN
        g_inv_vr_to_last_update := p_inv_vr_to_last_update;
        main_where_clause := main_where_clause||' AND mivr.last_update_date <= :inv_vr_to_last_update';
        main_using_clause := main_using_clause||', gmd_outbound_apis_pub.g_inv_vr_to_last_update';

        inv_vr_where_clause := inv_vr_where_clause||' AND ivr.last_update_date <= :inv_vr_to_last_update';
        inv_vr_using_clause := inv_vr_using_clause||', gmd_outbound_apis_pub.g_inv_vr_to_last_update';
      END IF;

      IF p_inv_vr_delete_mark IS NOT NULL
      THEN
        g_inv_vr_delete_mark := p_inv_vr_delete_mark;
        main_where_clause := main_where_clause||' AND  mivr.delete_mark =:inv_vr_delete_mark';
        main_using_clause := main_using_clause||', gmd_outbound_apis_pub.g_inv_vr_delete_mark';

        inv_vr_where_clause := inv_vr_where_clause||' AND  ivr.delete_mark = :inv_vr_delete_mark';
        inv_vr_using_clause := inv_vr_using_clause||', gmd_outbound_apis_pub.g_inv_vr_delete_mark';
      END IF;

      main_where_clause := main_where_clause||' ) ';

   END IF;

    -- START B3124291 Incorporated Mini-Pack K Features to Outboud APIs

    -- Sort out the GMD_MONITORING_SPEC_VRS table's needs

    IF p_mon_vr_status                IS NOT NULL OR
       p_mon_vr_rule_type             IS NOT NULL OR
       p_mon_vr_lct_organization_code IS NOT NULL OR
       p_mon_vr_subinventory          IS NOT NULL OR
       p_mon_vr_locator               IS NOT NULL OR
       p_mon_vr_locator_id            IS NOT NULL OR
       p_mon_vr_rsr_organization_code IS NOT NULL OR
       p_mon_vr_resources             IS NOT NULL OR
       p_mon_vr_resource_instance_id  IS NOT NULL OR
       p_mon_vr_sampling_plan_id      IS NOT NULL OR
       p_mon_vr_start_date            IS NOT NULL OR
       p_mon_vr_end_date              IS NOT NULL OR
       p_mon_vr_from_last_update_date IS NOT NULL OR
       p_mon_vr_to_last_update_date   IS NOT NULL OR
       p_mon_vr_delete_mark           IS NOT NULL
    THEN
      -- Include the table in the list, and join to it.

      main_where_clause := main_where_clause
                        ||' AND gs.spec_id IN'
                        ||' (SELECT mmvr.spec_id FROM gmd_monitoring_spec_vrs mmvr'
                        ||'  WHERE 1=1';


      IF p_mon_vr_start_date IS NOT NULL
      THEN
        g_mon_vr_start_date := p_mon_vr_start_date;
        main_where_clause := main_where_clause||' AND mmvr.start_date >= :mon_vr_start_date';
        main_using_clause := main_using_clause||', gmd_outbound_apis_pub.g_mon_vr_start_date';

        mon_vr_where_clause := mon_vr_where_clause||' AND mvr.start_date >= :mon_vr_start_date';
        mon_vr_using_clause := mon_vr_using_clause||', gmd_outbound_apis_pub.g_mon_vr_start_date';
      END IF;

      IF p_mon_vr_end_date IS NOT NULL
      THEN
        g_mon_vr_end_date := p_mon_vr_end_date;
        main_where_clause := main_where_clause||' AND mmvr.end_date <= :mon_vr_end_date';
        main_using_clause := main_using_clause||', gmd_outbound_apis_pub.g_mon_vr_end_date';

        mon_vr_where_clause := mon_vr_where_clause||' AND mvr.end_date <= :mon_vr_end_date';
        mon_vr_using_clause := mon_vr_using_clause||', gmd_outbound_apis_pub.g_mon_vr_end_date';
      END IF;

      IF p_mon_vr_status IS NOT NULL
      THEN
        g_mon_vr_status := p_mon_vr_status;
        main_where_clause := main_where_clause||' AND mmvr.spec_vr_status = :mon_vr_status';
        main_using_clause := main_using_clause||', gmd_outbound_apis_pub.g_mon_vr_status';

        mon_vr_where_clause := mon_vr_where_clause||' AND mvr.spec_vr_status = :mon_vr_status';
        mon_vr_using_clause := mon_vr_using_clause||', gmd_outbound_apis_pub.g_mon_vr_status';
      END IF;

      IF p_mon_vr_rule_type IS NOT NULL
      THEN
        g_mon_vr_rule_type := p_mon_vr_rule_type;
        main_where_clause := main_where_clause||' AND mmvr.rule_type = :mon_vr_rule_type';
        main_using_clause := main_using_clause||', gmd_outbound_apis_pub.g_mon_vr_rule_type';

        mon_vr_where_clause := mon_vr_where_clause||' AND mvr.rule_type = :mon_vr_rule_type';
        mon_vr_using_clause := mon_vr_using_clause||', gmd_outbound_apis_pub.g_mon_vr_rule_type';
      END IF;

      IF p_mon_vr_lct_organization_code IS NOT NULL
      THEN
        g_mon_vr_lct_organization_code := p_mon_vr_lct_organization_code;
        main_where_clause := main_where_clause||' AND mmvr.locator_organization_id = (SELECT organization_id'
                                 ||' FROM mtl_organizations WHERE organization_code = :mon_vr_lct_organization_code)';
        main_using_clause := main_using_clause||', gmd_outbound_apis_pub.g_mon_vr_lct_organization_code';

        mon_vr_where_clause := mon_vr_where_clause||' AND mvr.locator_organization_id = (SELECT organization_id'
                                 ||' FROM mtl_organizations WHERE organization_code = :mon_vr_lct_organization_code)';
        mon_vr_using_clause := mon_vr_using_clause||', gmd_outbound_apis_pub.g_mon_vr_lct_organization_code';
      END IF;

      IF p_mon_vr_subinventory IS NOT NULL
      THEN
        g_mon_vr_subinventory := p_mon_vr_subinventory;
        main_where_clause := main_where_clause||' AND mmvr.subinventory = :mon_vr_subinventory';
        main_using_clause := main_using_clause||', gmd_outbound_apis_pub.g_mon_vr_subinventory';

        mon_vr_where_clause := mon_vr_where_clause||' AND mvr.whse_code = :mon_vr_subinventory';
        mon_vr_using_clause := mon_vr_using_clause||', gmd_outbound_apis_pub.g_mon_vr_subinventory';
      END IF;

      IF p_mon_vr_locator_id IS NOT NULL
      THEN
        g_mon_vr_locator_id := p_mon_vr_locator_id;
        main_where_clause := main_where_clause||' AND mmvr.locator_id = :mon_vr_locator_id';
        main_using_clause := main_using_clause||', gmd_outbound_apis_pub.g_mon_vr_locator_id';

        mon_vr_where_clause := mon_vr_where_clause||' AND mvr.locator_id = :mon_vr_locator_id';
        mon_vr_using_clause := mon_vr_using_clause||', gmd_outbound_apis_pub.g_mon_vr_locator_id';
      END IF;

      IF p_mon_vr_locator IS NOT NULL
      THEN
        g_mon_vr_locator := p_mon_vr_locator;
        main_where_clause := main_where_clause||' AND mmvr.locator_id = (SELECT inventory_location_id'
                                              ||' FROM mtl_item_locations_kfv WHERE'
                                              ||' concatenated_segments = :mon_vr_locator'
                                              ||' AND organization_id = mmvr.locator_organization_id)';
        main_using_clause := main_using_clause||', gmd_outbound_apis_pub.g_mon_vr_locator';

        mon_vr_where_clause := mon_vr_where_clause||' AND mvr.locator_id = (SELECT inventory_location_id'
                                              ||' FROM mtl_item_locations_kfv WHERE'
                                              ||' concatenated_segments = :mon_vr_locator'
                                              ||' AND organization_id = mvr.locator_organization_id)';
        mon_vr_using_clause := mon_vr_using_clause||', gmd_outbound_apis_pub.g_mon_vr_locator';
      END IF;

      IF p_mon_vr_rsr_organization_code IS NOT NULL
      THEN
        g_mon_vr_rsr_organization_code := p_mon_vr_rsr_organization_code;
        main_where_clause := main_where_clause||' AND mmvr.resource_organization_id = (SELECT organization_id'
                                    ||' FROM mtl_organizations WHERE organization_code = :mon_vr_rsr_organization_code)';
        main_using_clause := main_using_clause||', gmd_outbound_apis_pub.g_mon_vr_rsr_organization_code';

        mon_vr_where_clause := mon_vr_where_clause||' AND mvr.resource_organization_id = (SELECT organization_id'
                                    ||' FROM mtl_organizations WHERE organization_code = :mon_vr_rsr_organization_code)';
        mon_vr_using_clause := mon_vr_using_clause||', gmd_outbound_apis_pub.g_mon_vr_rsr_organization_code';
      END IF;

      IF p_mon_vr_resources IS NOT NULL
      THEN
        g_mon_vr_resources := p_mon_vr_resources;
        main_where_clause := main_where_clause||' AND mmvr.resources = :mon_vr_resources';
        main_using_clause := main_using_clause||', gmd_outbound_apis_pub.g_mon_vr_resources';

        mon_vr_where_clause := mon_vr_where_clause||' AND mvr.resources = :mon_vr_resources';
        mon_vr_using_clause := mon_vr_using_clause||', gmd_outbound_apis_pub.g_mon_vr_resources';
      END IF;

      IF p_mon_vr_resource_instance_id IS NOT NULL
      THEN
        g_mon_vr_resource_instance_id := p_mon_vr_resource_instance_id;
        main_where_clause := main_where_clause||' AND mmvr.resource_instance_id = :mon_vr_resource_instance_id';
        main_using_clause := main_using_clause||', gmd_outbound_apis_pub.g_mon_vr_resource_instance_id';

        mon_vr_where_clause := mon_vr_where_clause||' AND mvr.resource_instance_id = :mon_vr_resource_instance_id';
        mon_vr_using_clause := mon_vr_using_clause||', gmd_outbound_apis_pub.g_mon_vr_resource_instance_id';
      END IF;

      IF p_mon_vr_sampling_plan_id IS NOT NULL
      THEN
        g_mon_vr_sampling_plan_id := p_mon_vr_sampling_plan_id;
        main_where_clause := main_where_clause||' AND mmvr.sampling_plan_id = :mon_vr_sampling_plan_id';
        main_using_clause := main_using_clause||', gmd_outbound_apis_pub.g_mon_vr_sampling_plan_id';

        mon_vr_where_clause := mon_vr_where_clause||' AND mvr.sampling_plan_id = :mon_vr_sampling_plan_id';
        mon_vr_using_clause := mon_vr_using_clause||', gmd_outbound_apis_pub.g_mon_vr_sampling_plan_id';
      END IF;

      IF p_mon_vr_from_last_update_date IS NOT NULL
      THEN
        g_mon_vr_from_last_update_date := p_mon_vr_from_last_update_date;
        main_where_clause := main_where_clause||' AND mmvr.last_update_date >= :mon_vr_from_last_update_date';
        main_using_clause := main_using_clause||', gmd_outbound_apis_pub.g_mon_vr_from_last_update_date';

        mon_vr_where_clause := mon_vr_where_clause||' AND mvr.last_update_date >= :mon_vr_from_last_update_date';
        mon_vr_using_clause := mon_vr_using_clause||', gmd_outbound_apis_pub.g_mon_vr_from_last_update_date';
      END IF;

      IF p_mon_vr_to_last_update_date IS NOT NULL
      THEN
        g_mon_vr_to_last_update_date := p_mon_vr_to_last_update_date;
        main_where_clause := main_where_clause||' AND mmvr.last_update_date <= :mon_vr_to_last_update_date';
        main_using_clause := main_using_clause||', gmd_outbound_apis_pub.g_mon_vr_to_last_update_date';

        mon_vr_where_clause := mon_vr_where_clause||' AND mvr.last_update_date <= :mon_vr_to_last_update_date';
        mon_vr_using_clause := mon_vr_using_clause||', gmd_outbound_apis_pub.g_mon_vr_to_last_update_date';
      END IF;

      IF p_mon_vr_delete_mark IS NOT NULL
      THEN
        g_mon_vr_delete_mark := p_mon_vr_delete_mark;
        main_where_clause := main_where_clause||' AND  mmvr.delete_mark =:mon_vr_delete_mark';
        main_using_clause := main_using_clause||', gmd_outbound_apis_pub.g_mon_vr_delete_mark';

        mon_vr_where_clause := mon_vr_where_clause||' AND  mvr.delete_mark = :mon_vr_delete_mark';
        mon_vr_using_clause := mon_vr_using_clause||', gmd_outbound_apis_pub.g_mon_vr_delete_mark';
      END IF;

      main_where_clause := main_where_clause||' ) ';

   END IF;
  -- END B3124291 Incorporated Mini-Pack K Features to Outboud APIs


   sql_statement := 'SELECT system.gmd_specification_rec_type'   -- 5284247
                  ||'('||main_column_list
                  ||', CAST'
                  ||'  ( MULTISET'
                  ||'    ( SELECT '  ||spec_test_column_list
                  ||'        FROM   '||spec_test_table_list
                  ||'        WHERE  '||spec_test_where_clause
                  ||'    ) AS system.gmd_spec_tests_tab_type' -- 5284242
                  ||'  )'
                  ||', CAST'
                  ||'  ( MULTISET'
                  ||'    ( SELECT '  ||cust_vr_column_list
                  ||'        FROM   '||cust_vr_table_list
                  ||'        WHERE  '||cust_vr_where_clause
                  ||'    ) AS system.gmd_cust_spec_vrs_tab_type' -- 5284242
                  ||'  )'
                  ||', CAST'
                  ||'  ( MULTISET'
                  ||'    ( SELECT '  ||wip_vr_column_list
                  ||'        FROM   '||wip_vr_table_list
                  ||'        WHERE  '||wip_vr_where_clause
                  ||'    ) AS system.gmd_wip_spec_vrs_tab_type' -- 5284242
                  ||'  )'
                  ||', CAST'
                  ||'  ( MULTISET'
                  ||'    ( SELECT '  ||supl_vr_column_list
                  ||'        FROM   '||supl_vr_table_list
                  ||'        WHERE  '||supl_vr_where_clause
                  ||'    ) AS system.gmd_supl_spec_vrs_tab_type' -- 5284242
                  ||'  )'
                  ||', CAST'
                  ||'  ( MULTISET'
                  ||'    ( SELECT '  ||inv_vr_column_list
                  ||'        FROM   '||inv_vr_table_list
                  ||'        WHERE  '||inv_vr_where_clause
                  ||'    ) AS system.gmd_inv_spec_vrs_tab_type' -- 5284242
                  ||'  )'
                  -- START B3124291 Incorporated Mini-Pack K Features to Outboud APIs
                  ||', CAST'
                  ||'  ( MULTISET'
                  ||'    ( SELECT '  ||mon_vr_column_list
                  ||'        FROM   '||mon_vr_table_list
                  ||'        WHERE  '||mon_vr_where_clause
                  ||'    ) AS system.gmd_mon_spec_vrs_tab_type'   -- 5284242
                  ||'  )'
                  -- END B3124291 Incorporated Mini-Pack K Features to Outboud APIs
                  ||')'
                  ||' FROM ' ||main_table_list
                  ||' WHERE '||main_where_clause;

    -- That's more or less the job done. We just need to tell the system where to store the data
    -- and assemble the USING clause. Note thatthe main_using_clause is last in the list as it
    -- appears last in the query.

    main_into_clause := ' BULK COLLECT INTO gmd_outbound_apis_pub.g_specifications_table ';

    main_using_clause := ' USING '||spec_test_using_clause
                       ||','||cust_vr_using_clause
                       ||','||wip_vr_using_clause
                       ||','||supl_vr_using_clause
                       ||','||inv_vr_using_clause
                       -- START B3124291 Incorporated Mini-Pack K Features to Outboud APIs
                       ||','||mon_vr_using_clause
                       -- END B3124291 Incorporated Mini-Pack K Features to Outboud APIs
                       ||','||main_using_clause;


    main_execution_string := 'BEGIN EXECUTE IMMEDIATE '
                       ||''''
                       ||sql_statement
                       ||''''
                       ||main_into_clause
                       ||main_using_clause
                       ||'; END;';


    gme_debug.put_line('The sql statement is:');
    i:= 1;
    LOOP
      gme_debug.put_line(substr(main_execution_string, i, 100));
      EXIT WHEN i> LENGTH(main_execution_string);
      i := i+100;
    END LOOP;
    gme_debug.put_line('Executing string');

     -- problem here
     -- check the s=rec type on d/b with the list here

    EXECUTE IMMEDIATE main_execution_string;
    gme_debug.put_line('SQL string execution comleted');
    -- Main retrieval done, now just fill in any blanks

    IF g_specifications_table.count > 0
    THEN
      FOR i in 1.. g_specifications_table.count
      LOOP
        IF g_specifications_table(i).owner_organization_id IS NOT NULL
        AND g_specifications_table(i).inventory_item_id IS NOT NULL THEN
          SELECT concatenated_segments INTO g_specifications_table(i).item_number
          FROM   mtl_system_items_b_kfv
          WHERE organization_id = g_specifications_table(i).owner_organization_id
          AND inventory_item_id = g_specifications_table(i).inventory_item_id;
        END IF;
      END LOOP;
    END IF;

    x_specifications_tbl := gmd_outbound_apis_pub.g_specifications_table;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

  END IF;
  FND_MSG_PUB.count_and_get(p_count => x_msg_count, p_data => x_msg_data);

EXCEPTION
  WHEN OTHERS
  THEN

    FND_MESSAGE.SET_NAME('GMD',SQLCODE);
    FND_MSG_PUB.Add;
    FND_MSG_PUB.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    x_return_status := FND_API.G_RET_STS_ERROR;
END fetch_spec_vrs;


PROCEDURE fetch_results
( p_api_version                IN NUMBER
, p_init_msg_list              IN VARCHAR2 DEFAULT FND_API.G_FALSE
, p_user_name                  IN VARCHAR2
, p_orgn_code                  IN VARCHAR2 DEFAULT NULL
, p_from_sample_no             IN VARCHAR2 DEFAULT NULL
, p_to_sample_no               IN VARCHAR2 DEFAULT NULL
, p_sample_id                  IN NUMBER   DEFAULT NULL
, p_from_result_date           IN DATE     DEFAULT NULL
, p_to_result_date             IN DATE     DEFAULT NULL
, p_sample_disposition         IN VARCHAR2 DEFAULT NULL
, p_in_spec_ind                IN VARCHAR2 DEFAULT NULL
, p_qc_lab_orgn_code           IN VARCHAR2 DEFAULT NULL
, p_evaluation_ind             IN VARCHAR2 DEFAULT NULL
, p_tester                     IN VARCHAR2 DEFAULT NULL
, p_tester_id                  IN NUMBER   DEFAULT NULL
, p_test_provider_id           IN NUMBER   DEFAULT NULL
, p_delete_mark                IN NUMBER   DEFAULT NULL
, p_from_last_update_date      IN DATE     DEFAULT NULL
, p_to_last_update_date        IN DATE     DEFAULT NULL
, p_planned_resource           IN VARCHAR2 DEFAULT NULL
, p_planned_resource_instance  IN NUMBER   DEFAULT NULL
, p_actual_resource            IN VARCHAR2 DEFAULT NULL
, p_actual_resource_instance   IN NUMBER   DEFAULT NULL
, p_from_planned_result_date   IN DATE     DEFAULT NULL
, p_to_planned_result_date     IN DATE     DEFAULT NULL
, p_from_test_by_date          IN DATE     DEFAULT NULL
, p_to_test_by_date            IN DATE     DEFAULT NULL
, p_reserve_sample_id          IN NUMBER   DEFAULT NULL
, x_results_table              OUT NOCOPY system.gmd_results_tab_type
, x_return_status              OUT NOCOPY VARCHAR2
, x_msg_count                  OUT NOCOPY NUMBER
, x_msg_data                   OUT NOCOPY VARCHAR2
)
IS

  sql_statement            VARCHAR2(2000);
  column_list              VARCHAR2(2000);
  table_list               VARCHAR2(2000);
  where_clause             VARCHAR2(2000);
  into_clause              VARCHAR2(2000);
  using_clause             VARCHAR2(2000);
  execution_string         VARCHAR2(10000);
  row_count                NUMBER;
  i                        NUMBER;


  CURSOR item_cursor (cp_inventory_item_id NUMBER) IS
  SELECT concatenated_segments FROM mtl_system_items_kfv
  WHERE  inventory_item_id = cp_inventory_item_id;

  l_api_name               VARCHAR2(100) := 'fetch_results';

BEGIN

  gme_debug.put_line('Enter GMD_OUTBOUND_APIS_PUB.FETCH_RESULTS API');

  IF NOT FND_API.Compatible_API_CALL
    (gmd_outbound_apis_pub.api_version, p_api_version, l_api_name,'GMD_OUTBOUND_APIS_PUB')
  OR NOT initialized_ok(p_user_name)
  THEN
    Raise FND_API.G_EXC_UNEXPECTED_ERROR;
  ELSE
    gme_debug.put_line('Starting FETCH_RESULTS processing');
    /*  Initialize message list if p_int_msg_list is set TRUE.  */
    IF FND_API.to_boolean(p_init_msg_list)
    THEN
      FND_MSG_PUB.Initialize;
    END IF;

    -- Start construction the select.

    gme_debug.put_line('Begin constructing SELECT statement');
    sql_statement := 'SELECT ';


    column_list := 'system.gmd_results_rec_type( r.update_instance_id, r.result_id, '   -- 5346480 add system.
                   ||'r.sample_id, gs.sample_no, r.test_id, gt.test_code, '
                   ||'r.test_replicate_cnt, r.lab_organization_id, r.result_value_num, '
                   ||'r.result_date, r.test_kit_inv_item_id, NULL, '
                   ||'r.test_kit_lot_number , r.tester, r.tester_id, '
                   ||'r.test_provider_id, r.ad_hoc_print_on_coa_ind, r.seq, '
                   ||'r.result_value_char, r.test_provider_code, r.assay_retest, '
                   ||'gsr.in_spec_ind, gesd.disposition, gsr.evaluation_ind, '
                   ||'r.planned_resource, r.planned_resource_instance, '
                   ||'r.actual_resource, r.actual_resource_instance, '
                   ||'r.planned_result_date, r.test_by_date, '
                   ||'r.delete_mark, r.text_code, r.attribute_category, r.attribute1, '
                   ||'r.attribute2, r.attribute3, r.attribute4, r.attribute5, '
                   ||'r.attribute6, r.attribute7, r.attribute8, r.attribute9, '
                   ||'r.attribute10, r.attribute11, r.attribute12, r.attribute13, '
                   ||'r.attribute14, r.attribute15, r.attribute16, r.attribute17, '
                   ||'r.attribute18, r.attribute19, r.attribute20, r.attribute21, '
                   ||'r.attribute22, r.attribute23, r.attribute24, r.attribute25, '
                   ||'r.attribute26, r.attribute27, r.attribute28, r.attribute29, '
                   ||'r.attribute30,  r.creation_date, '
                   ||'r.created_by, fu1.user_name, r.last_updated_by, fu2.user_name, '
                   ||'r.last_update_date, r.last_update_login, '
                   ||'r.test_qty, r.test_qty_uom, '
                   ||'r.reserve_sample_id, r.consumed_qty, '
                   ||'r.parent_result_id, r.test_method_id )';


    table_list := 'FROM gmd_results r, gmd_samples gs, gmd_qc_tests_b gt,'
                  ||'gmd_spec_results gsr, gmd_event_spec_disp gesd,'
                  ||'fnd_user fu1, fnd_user fu2 ';


    -- We now have the first three strings built. Here comes the good bit: building the where and us
    -- clauses and inserting the bind variables and values.

    -- We will not make any attempt to guess what the user had in mind, so if (for example) they spe
    -- an item_id and an item_no and these two don't stack up, so be it. The query will simply fail
    -- return anything.

    where_clause := 'WHERE r.sample_id = gs.sample_id and r.test_id = gt.test_id '
                  ||'AND r.result_id = gsr.result_id '
                  ||'AND gsr.event_spec_disp_id = gesd.event_spec_disp_id '
                  ||'AND gesd.spec_used_for_lot_attrib_ind = ''''Y''''  '
                  ||'AND fu1.user_id = r.created_by AND fu2.user_id = r.last_updated_by and 1=:dummy ';

    using_clause := ' USING 1 ';

    -- Work down the parameter list and append conditions, bind variables and bind values.

    IF p_orgn_code IS NOT NULL     /*NSRIVAST, INVCONV*/
    THEN
      gmd_outbound_apis_pub.g_orgn_code := p_orgn_code;
      where_clause := where_clause||'AND gs.organization_id = (SELECT organization_id'
                                  || ' FROM mtl_organizations WHERE organization_code = :orgn_code)';
      using_clause := using_clause||', gmd_outbound_apis_pub.g_orgn_code ';
    END IF;

    IF p_from_sample_no IS NOT NULL
    THEN
      gmd_outbound_apis_pub.g_from_sample_no := p_from_sample_no;
      where_clause := where_clause||'AND gs.sample_no >= :sample_no ';
      using_clause := using_clause||', gmd_outbound_apis_pub.g_from_sample_no ';
    END IF;

    IF p_to_sample_no IS NOT NULL
    THEN
      gmd_outbound_apis_pub.g_to_sample_no := p_to_sample_no;
      where_clause := where_clause||'AND gs.sample_no <= :sample_no ';
	      using_clause := using_clause||', gmd_outbound_apis_pub.g_to_sample_no ';
	    END IF;

	    IF p_sample_id IS NOT NULL
	    THEN
	      gmd_outbound_apis_pub.g_sample_id := p_sample_id;
      where_clause := where_clause||'AND gs.sample_id = :sample_id ';
      using_clause := using_clause||', gmd_outbound_apis_pub.g_sample_id ';
    END IF;

    IF p_from_result_date IS NOT NULL
    THEN
      gmd_outbound_apis_pub.g_from_result_date := p_from_result_date ;
      where_clause := where_clause||'AND r.result_date >= :from_result_date ';
      using_clause := using_clause||', gmd_outbound_apis_pub.g_from_result_date ';
    END IF;

    IF p_to_result_date IS NOT NULL
    THEN
      gmd_outbound_apis_pub.g_to_result_date := p_to_result_date ;
      where_clause := where_clause||'AND r.result_date <= :to_result_date ';
      using_clause := using_clause||', gmd_outbound_apis_pub.g_to_result_date ';
    END IF;

    IF p_sample_disposition IS NOT NULL
    THEN
      gmd_outbound_apis_pub.g_sample_disposition := p_sample_disposition ;
      where_clause := where_clause||'AND gesd.disposition = :disposition ';
      using_clause := using_clause||', gmd_outbound_apis_pub.g_sample_disposition ';
    END IF;

    IF p_in_spec_ind IS NOT NULL
    THEN
      gmd_outbound_apis_pub.g_in_spec_ind := p_in_spec_ind;
      where_clause := where_clause||'AND gsr.in_spec_ind = :in_spec_ind ';
      using_clause := using_clause||', gmd_outbound_apis_pub.g_in_spec_ind ';
    END IF;

    IF p_qc_lab_orgn_code IS NOT NULL  /*NSRIVAST, INVCONV*/
    THEN
      gmd_outbound_apis_pub.g_qc_lab_orgn_code := p_qc_lab_orgn_code ;
      where_clause := where_clause||'AND r.lab_organization_id = (SELECT organization_id'
                                  || ' FROM mtl_organizations WHERE organization_code = :lab_orgn_code)';
      using_clause := using_clause||', gmd_outbound_apis_pub.g_qc_lab_orgn_code ';
    END IF;

    IF p_evaluation_ind IS NOT NULL
    THEN
      gmd_outbound_apis_pub.g_evaluation_ind := p_evaluation_ind ;
      where_clause := where_clause||'AND gsr.evaluation_ind = :evaluation_ind ';
      using_clause := using_clause||', gmd_outbound_apis_pub.g_evaluation_ind ';
    END IF;

    -- BUG 3078568 target fnd_user for tester
    IF p_tester IS NOT NULL
    THEN
      table_list := table_list ||', fnd_user fu3 ';
      where_clause := where_clause ||'AND r.tester_id = fu3.user_id ';

      gmd_outbound_apis_pub.g_tester := p_tester;
      where_clause := where_clause||'AND fu3.user_name = :tester ';
      using_clause := using_clause||', gmd_outbound_apis_pub.g_tester ';
    END IF;

    IF p_tester_id IS NOT NULL
    THEN
      gmd_outbound_apis_pub.g_tester_id := p_tester_id ;
      where_clause := where_clause||'AND r.tester_id = :tester_id ';
      using_clause := using_clause||', gmd_outbound_apis_pub.g_tester_id ';
    END IF;

    IF p_test_provider_id IS NOT NULL
    THEN
      gmd_outbound_apis_pub.g_test_provider_id := p_test_provider_id ;
      where_clause := where_clause||'AND r.test_provider_id = :test_provider_id ';
      using_clause := using_clause||', gmd_outbound_apis_pub.g_test_provider_id ';
    END IF;

    IF p_delete_mark IS NOT NULL
    THEN
      gmd_outbound_apis_pub.g_delete_mark := p_delete_mark ;
      where_clause := where_clause||'AND r.delete_mark = :delete_mark ';
      using_clause := using_clause||', gmd_outbound_apis_pub.g_delete_mark ';
    END IF;

    IF p_from_last_update_date IS NOT NULL
    THEN
      gmd_outbound_apis_pub.g_from_last_update_date := p_from_last_update_date;
      where_clause := where_clause||'AND r.last_update_date >= :from_last_update_date ';
      using_clause := using_clause||', gmd_outbound_apis_pub.g_from_last_update_date ';
    END IF;

    IF p_to_last_update_date IS NOT NULL
    THEN
      gmd_outbound_apis_pub.g_to_last_update_date := p_to_last_update_date;
      where_clause := where_clause||'AND r.last_update_date <= :to_last_update_date ';
      using_clause := using_clause||', gmd_outbound_apis_pub.g_to_last_update_date ';
    END IF;

    IF p_planned_resource IS NOT NULL
    THEN
      gmd_outbound_apis_pub.g_planned_resource := p_planned_resource;
      where_clause := where_clause||'AND gsr.planned_resource = :planned_resource ';
      using_clause := using_clause||', gmd_outbound_apis_pub.g_planned_resource ';
    END IF;

    IF p_planned_resource_instance IS NOT NULL
    THEN
      gmd_outbound_apis_pub.g_planned_resource_instance := p_planned_resource_instance;
      where_clause := where_clause||'AND gsr.planned_resource_instance = :planned_resource_instance ';
      using_clause := using_clause||', gmd_outbound_apis_pub.g_planned_resource_instance ';
    END IF;

    IF p_actual_resource IS NOT NULL
    THEN
      gmd_outbound_apis_pub.g_actual_resource := p_actual_resource;
      where_clause := where_clause||'AND gsr.actual_resource = :actual_resource ';
      using_clause := using_clause||', gmd_outbound_apis_pub.g_actual_resource ';
    END IF;

    IF p_actual_resource_instance IS NOT NULL
    THEN
      gmd_outbound_apis_pub.g_actual_resource_instance := p_actual_resource_instance;
      where_clause := where_clause||'AND gsr.actual_resource_instance = :actual_resource_instance ';
      using_clause := using_clause||', gmd_outbound_apis_pub.g_actual_resource_instance ';
    END IF;

    IF p_from_planned_result_date IS NOT NULL
    THEN
      gmd_outbound_apis_pub.g_from_planned_result_date := p_from_planned_result_date;
      where_clause := where_clause||'AND gsr.planned_result_date >= :from_planned_result_date ';
      using_clause := using_clause||', gmd_outbound_apis_pub.g_from_planned_result_date ';
    END IF;

    IF p_to_planned_result_date IS NOT NULL
    THEN
      gmd_outbound_apis_pub.g_to_planned_result_date := p_to_planned_result_date;
      where_clause := where_clause||'AND gsr.planned_result_date <= :to_planned_result_date ';
      using_clause := using_clause||', gmd_outbound_apis_pub.g_to_planned_result_date ';
    END IF;

    IF p_from_test_by_date IS NOT NULL
    THEN
      gmd_outbound_apis_pub.g_from_test_by_date := p_from_test_by_date;
      where_clause := where_clause||'AND gsr.test_by_date >= :from_test_by_date ';
      using_clause := using_clause||', gmd_outbound_apis_pub.g_from_test_by_date ';
    END IF;

    IF p_to_test_by_date IS NOT NULL
    THEN
      gmd_outbound_apis_pub.g_to_test_by_date := p_to_test_by_date;
      where_clause := where_clause||'AND gsr.test_by_date <= :to_test_by_date ';
      using_clause := using_clause||', gmd_outbound_apis_pub.g_to_test_by_date ';
    END IF;

    IF p_reserve_sample_id IS NOT NULL
    THEN
      gmd_outbound_apis_pub.g_reserve_sample_id := p_reserve_sample_id;
      where_clause := where_clause||'AND r.reserve_sample_id = :reserve_sample_id ';
      using_clause := using_clause||', gmd_outbound_apis_pub.g_reserve_sample_id ';
    END IF;

    -- That's more or less the job done. We just need to tell the system where to store the data

    into_clause := ' BULK COLLECT INTO gmd_outbound_apis_pub.g_results_table ';


    execution_string := 'BEGIN EXECUTE IMMEDIATE '
                       ||''''
                       ||sql_statement||column_list||table_list||where_clause
                       ||''''
                       ||into_clause
                       ||using_clause
                       ||'; END;';

    gme_debug.put_line('The sql statement is:');
    i:= 1;
    LOOP
      gme_debug.put_line(substr(execution_string, i, 100));
      EXIT WHEN i> LENGTH(execution_string);
      i := i+100;
    END LOOP;
    gme_debug.put_line('Executing string');

    EXECUTE IMMEDIATE execution_string;

    FOR i IN 1..g_results_table.COUNT
    LOOP

      IF g_results_table(i).test_kit_inv_item_id IS NOT NULL
      THEN
        gme_debug.put_line('select from mtl_system_items_kfv using inventory_item_id of '|| g_results_table(i).test_kit_inv_item_id);
        SELECT  concatenated_segments
	  INTO  g_results_table(i).test_kit_inv_item_number
          FROM  mtl_system_items_kfv
         WHERE  inventory_item_id = g_results_table(i).test_kit_inv_item_id
         and rownum = 1; -- 5346480 rework
      END IF;

      -- BUG 3078568 - populate tester from tester_id
      IF g_results_table(i).tester_id IS NOT NULL
      THEN
        gme_debug.put_line('select from fnd_user using user_id of '
                          || g_results_table(i).tester_id);
        SELECT user_name
	  INTO g_results_table(i).tester
          FROM fnd_user
         WHERE user_id = g_results_table(i).tester_id;
      END IF;

    END LOOP;


    gme_debug.put_line('Returning table to caller');
    x_results_table := gmd_outbound_apis_pub.g_results_table;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

  END IF;

  FND_MSG_PUB.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  gme_debug.put_line('Finished FETCH_RESULTS');

EXCEPTION
  WHEN OTHERS
  THEN
    FND_MESSAGE.SET_NAME('GMD',SQLCODE);
    FND_MSG_PUB.Add;
    FND_MSG_PUB.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    x_return_status := FND_API.G_RET_STS_ERROR;

END fetch_results;


PROCEDURE fetch_composite_results
( p_api_version                  IN NUMBER
, p_init_msg_list                IN VARCHAR2 DEFAULT FND_API.G_FALSE
, p_user_name                    IN VARCHAR2
, p_sampling_event_id            IN NUMBER   DEFAULT NULL
, p_composite_result_disposition IN VARCHAR2 DEFAULT NULL
, p_from_item_number             IN VARCHAR2 DEFAULT NULL /*NSRIVAST, INVCONV*/
, p_to_item_number               IN VARCHAR2 DEFAULT NULL /*NSRIVAST, INVCONV*/
, p_inventory_item_id            IN NUMBER   DEFAULT NULL /*NSRIVAST, INVCONV*/
, p_from_lot_number              IN VARCHAR2 DEFAULT NULL /*NSRIVAST, INVCONV*/
, p_to_lot_number                IN VARCHAR2 DEFAULT NULL /*NSRIVAST, INVCONV*/
, p_lot_number                   IN VARCHAR2 DEFAULT NULL /*NSRIVAST, INVCONV*/
, p_from_last_update_date        IN DATE     DEFAULT NULL
, p_to_last_update_date          IN DATE     DEFAULT NULL
, p_delete_mark                  IN NUMBER   DEFAULT NULL
, x_composite_results_table      OUT NOCOPY system.gmd_composite_results_tab_type
, x_return_status                OUT NOCOPY VARCHAR2
, x_msg_count                    OUT NOCOPY NUMBER
, x_msg_data                     OUT NOCOPY VARCHAR2
)
IS

  sql_statement            VARCHAR2(2000);
  column_list              VARCHAR2(2000);
  table_list               VARCHAR2(2000);
  where_clause             VARCHAR2(2000);
  into_clause              VARCHAR2(2000);
  using_clause             VARCHAR2(2000);
  execution_string         VARCHAR2(10000);
  row_count                NUMBER;
  i                        NUMBER;
  l_api_name               VARCHAR2(100) := 'fetch_composite_results';

BEGIN

  gme_debug.put_line('Enter GMD_OUTBOUND_APIS_PUB.FETCH_COMPOSITE_RESULTS API');

  IF NOT FND_API.Compatible_API_CALL
    (gmd_outbound_apis_pub.api_version, p_api_version, l_api_name,'GMD_OUTBOUND_APIS_PUB')
  OR NOT initialized_ok(p_user_name)
  THEN
    Raise FND_API.G_EXC_UNEXPECTED_ERROR;
  ELSE

    gme_debug.put_line('Starting FETCH_COMPOSITE_RESULTS processing');
    /*  Initialize message list if p_int_msg_list is set TRUE.  */
    IF FND_API.to_boolean(p_init_msg_list)
    THEN
      FND_MSG_PUB.Initialize;
    END IF;

    -- Start construction the select.

    gme_debug.put_line('Begin constructing SELECT statement');
    sql_statement := 'SELECT ';

    IF (p_from_item_number IS NOT NULL OR p_to_item_number IS NOT NULL or p_inventory_item_id is NOT NULL) AND
       (p_lot_number is NOT NULL)
    THEN
      column_list := 'system.gmd_composite_results_rec_type( gcr.composite_result_id, gcr.test_id, '
                   ||'gcr.mean, gcr.mode_num, gcr.mode_char, gcr.low_num, gcr.high_num , '
                   ||'gcr.range, gcr.standard_deviation, gcr.sample_total, '
                   ||'gcr.sample_cnt_used, gcr.non_validated_result, '
                   ||'gcr.high_char, gcr.low_char, gcr.median_char, gcr.median_num, '
                   ||'gcr.composite_spec_disp_id, gcr.in_spec_ind, gcr.wf_response, '
                   ||'gcr.value_in_report_precision, gcsd.disposition, '
                   ||'gse.inventory_item_id, msi.concatenated_segments, gse.lot_number,  '
                   ||'gcr.delete_mark, gcr.text_code, gcr.attribute_category, gcr.attribute1, '
                   ||'gcr.attribute2, gcr.attribute3, gcr.attribute4, gcr.attribute5, '
                   ||'gcr.attribute6, gcr.attribute7, gcr.attribute8, gcr.attribute9, '
                   ||'gcr.attribute10, gcr.attribute11, gcr.attribute12, gcr.attribute13, '
                   ||'gcr.attribute14, gcr.attribute15, gcr.attribute16, gcr.attribute17, '
                   ||'gcr.attribute18, gcr.attribute19, gcr.attribute20, gcr.attribute21, '
                   ||'gcr.attribute22, gcr.attribute23, gcr.attribute24, gcr.attribute25, '
                   ||'gcr.attribute26, gcr.attribute27, gcr.attribute28, gcr.attribute29, '
                   ||'gcr.attribute30,  gcr.creation_date, gcr.created_by, fu1.user_name, '
                   ||'gcr.last_update_date, gcr.last_updated_by, fu2.user_name, '
                   ||'gcr.last_update_login, gcr.PARENT_COMPOSITE_RESULT_ID) ';       -- 5346713

      table_list := 'FROM gmd_composite_results gcr, gmd_sampling_events gse, gmd_event_spec_disp gesd, '
                  ||'gmd_composite_spec_disp gcsd, mtl_system_items_kfv msi, '
                  ||'fnd_user fu1, fnd_user fu2 ';


      where_clause := 'WHERE gse.sampling_event_id = gesd.sampling_event_id '
                  ||'AND gesd.event_spec_disp_id = gcsd.event_spec_disp_id '
                  ||'AND gcsd.composite_spec_disp_id = gcr.composite_spec_disp_id '
                  ||'AND gse.inventory_item_id = msi.inventory_item_id '
                  ||'AND fu1.user_id = gcr.created_by AND fu2.user_id = gcr.last_updated_by and 1=:dummy ';

    ELSIF (p_from_item_number IS NOT NULL OR p_to_item_number IS NOT NULL or p_inventory_item_id is NOT NULL)
    THEN
      column_list := 'system.gmd_composite_results_rec_type( gcr.composite_result_id, gcr.test_id, '   -- 5284247
                   ||'gcr.mean, gcr.mode_num, gcr.mode_char, gcr.low_num, gcr.high_num , '
                   ||'gcr.range, gcr.standard_deviation, gcr.sample_total, '
                   ||'gcr.sample_cnt_used, gcr.non_validated_result, '
                   ||'gcr.high_char, gcr.low_char, gcr.median_char, gcr.median_num, '
                   ||'gcr.composite_spec_disp_id, gcr.in_spec_ind, gcr.wf_response, '
                   ||'gcr.value_in_report_precision, gcsd.disposition, '
                   ||'gse.inventory_item_id, msi.concatenated_segments,  gse.lot_number, '
                   ||'gcr.delete_mark, gcr.text_code, gcr.attribute_category, gcr.attribute1, '
                   ||'gcr.attribute2, gcr.attribute3, gcr.attribute4, gcr.attribute5, '
                   ||'gcr.attribute6, gcr.attribute7, gcr.attribute8, gcr.attribute9, '
                   ||'gcr.attribute10, gcr.attribute11, gcr.attribute12, gcr.attribute13, '
                   ||'gcr.attribute14, gcr.attribute15, gcr.attribute16, gcr.attribute17, '
                   ||'gcr.attribute18, gcr.attribute19, gcr.attribute20, gcr.attribute21, '
                   ||'gcr.attribute22, gcr.attribute23, gcr.attribute24, gcr.attribute25, '
                   ||'gcr.attribute26, gcr.attribute27, gcr.attribute28, gcr.attribute29, '
                   ||'gcr.attribute30,  gcr.creation_date, gcr.created_by, fu1.user_name, '
                   ||'gcr.last_update_date, gcr.last_updated_by, fu2.user_name, '
                   ||'gcr.last_update_login, gcr.PARENT_COMPOSITE_RESULT_ID) ';       -- 5346713

      table_list := 'FROM gmd_composite_results gcr, gmd_sampling_events gse, gmd_event_spec_disp gesd, '
                   ||'gmd_composite_spec_disp gcsd, mtl_system_items_kfv msi, '
                   ||'fnd_user fu1, fnd_user fu2 ';


      where_clause := 'WHERE gse.sampling_event_id = gesd.sampling_event_id '
                   ||'AND gesd.event_spec_disp_id = gcsd.event_spec_disp_id '
                   ||'AND gcsd.composite_spec_disp_id = gcr.composite_spec_disp_id '
                   ||'AND gse.inventory_item_id = msi.inventory_item_id '
                   ||'AND fu1.user_id = gcr.created_by AND fu2.user_id = gcr.last_updated_by and 1=:dummy ';

    ELSIF (p_lot_number is NOT NULL)
    THEN
      column_list := 'system.gmd_composite_results_rec_type( gcr.composite_result_id, gcr.test_id, ' -- 5284247
                   ||'gcr.mean, gcr.mode_num, gcr.mode_char, gcr.low_num, gcr.high_num , '
                   ||'gcr.range, gcr.standard_deviation, gcr.sample_total, '
                   ||'gcr.sample_cnt_used, gcr.non_validated_result, '
                   ||'gcr.high_char, gcr.low_char, gcr.median_char, gcr.median_num, '
                   ||'gcr.composite_spec_disp_id, gcr.in_spec_ind, gcr.wf_response, '
                   ||'gcr.value_in_report_precision, gcsd.disposition, '
                   ||'gse.inventory_item_id, NULL, gse.lot_number, '
                   ||'gcr.delete_mark, gcr.text_code, gcr.attribute_category, gcr.attribute1, '
                   ||'gcr.attribute2, gcr.attribute3, gcr.attribute4, gcr.attribute5, '
                   ||'gcr.attribute6, gcr.attribute7, gcr.attribute8, gcr.attribute9, '
                   ||'gcr.attribute10, gcr.attribute11, gcr.attribute12, gcr.attribute13, '
                   ||'gcr.attribute14, gcr.attribute15, gcr.attribute16, gcr.attribute17, '
                   ||'gcr.attribute18, gcr.attribute19, gcr.attribute20, gcr.attribute21, '
                   ||'gcr.attribute22, gcr.attribute23, gcr.attribute24, gcr.attribute25, '
                   ||'gcr.attribute26, gcr.attribute27, gcr.attribute28, gcr.attribute29, '
                   ||'gcr.attribute30,  gcr.creation_date, gcr.created_by, fu1.user_name, '
                   ||'gcr.last_update_date, gcr.last_updated_by, fu2.user_name, '
                   ||'gcr.last_update_login, gcr.PARENT_COMPOSITE_RESULT_ID) ';       -- 5347613

      table_list := 'FROM gmd_composite_results gcr, gmd_sampling_events gse, gmd_event_spec_disp gesd,'
                   ||'gmd_composite_spec_disp gcsd, mtl_system_items_kfv msi, '
                   ||'fnd_user fu1, fnd_user fu2 ';


      where_clause := 'WHERE gse.sampling_event_id = gesd.sampling_event_id '
                   ||'AND gesd.event_spec_disp_id = gcsd.event_spec_disp_id '
                   ||'AND gcsd.composite_spec_disp_id = gcr.composite_spec_disp_id '
                   ||'AND gse.inventory_item_id = msi.inventory_item_id ' -- 5346713 rework -  space missing from end of statement
                   ||'AND fu1.user_id = gcr.created_by AND fu2.user_id = gcr.last_updated_by and 1=:dummy ';


    ELSE
      column_list := 'system.gmd_composite_results_rec_type( gcr.composite_result_id, gcr.test_id, ' -- 5284247
                   ||'gcr.mean, gcr.mode_num, gcr.mode_char, gcr.low_num, gcr.high_num , '
                   ||'gcr.range, gcr.standard_deviation, gcr.sample_total, '
                   ||'gcr.sample_cnt_used, gcr.non_validated_result, '
                   ||'gcr.high_char, gcr.low_char, gcr.median_char, gcr.median_num, '
                   ||'gcr.composite_spec_disp_id, gcr.in_spec_ind, gcr.wf_response, '
                   ||'gcr.value_in_report_precision, gcsd.disposition, '
                   ||'gse.inventory_item_id, NULL, gse.lot_number, '
                   ||'gcr.delete_mark, gcr.text_code, gcr.attribute_category, gcr.attribute1, '
                   ||'gcr.attribute2, gcr.attribute3, gcr.attribute4, gcr.attribute5, '
                   ||'gcr.attribute6, gcr.attribute7, gcr.attribute8, gcr.attribute9, '
                   ||'gcr.attribute10, gcr.attribute11, gcr.attribute12, gcr.attribute13, '
                   ||'gcr.attribute14, gcr.attribute15, gcr.attribute16, gcr.attribute17, '
                   ||'gcr.attribute18, gcr.attribute19, gcr.attribute20, gcr.attribute21, '
                   ||'gcr.attribute22, gcr.attribute23, gcr.attribute24, gcr.attribute25, '
                   ||'gcr.attribute26, gcr.attribute27, gcr.attribute28, gcr.attribute29, '
                   ||'gcr.attribute30,  gcr.creation_date, gcr.created_by, fu1.user_name, '
                   ||'gcr.last_update_date, gcr.last_updated_by, fu2.user_name, '
                   ||'gcr.last_update_login, gcr.PARENT_COMPOSITE_RESULT_ID) ';       -- 5346713


      table_list := 'FROM gmd_composite_results gcr, gmd_sampling_events gse, gmd_event_spec_disp gesd, '
                  ||'gmd_composite_spec_disp gcsd, '
                  ||'fnd_user fu1, fnd_user fu2 ';


      where_clause := 'WHERE gse.sampling_event_id = gesd.sampling_event_id '
                  ||'AND gesd.event_spec_disp_id = gcsd.event_spec_disp_id '
                  ||'AND gcsd.composite_spec_disp_id = gcr.composite_spec_disp_id '
                  ||'AND fu1.user_id = gcr.created_by AND fu2.user_id = gcr.last_updated_by and 1=:dummy ';


    END IF;
    using_clause := ' USING 1 ';

    -- Work down the parameter list and append conditions, bind variables and bind values.

    IF p_sampling_event_id IS NOT NULL
    THEN
      gmd_outbound_apis_pub.g_sampling_event_id := p_sampling_event_id;
      where_clause := where_clause||'AND gse.sampling_event_id = :sampling_event_id ';
      using_clause := using_clause||', gmd_outbound_apis_pub.g_sampling_event_id ';
    END IF;

    IF p_composite_result_disposition IS NOT NULL
    THEN
      gmd_outbound_apis_pub.g_disposition := p_composite_result_disposition;
      where_clause := where_clause||'AND gcsd.disposition = :disposition ';
      using_clause := using_clause||', gmd_outbound_apis_pub.g_disposition ';
    END IF;
-- pal
    -- BUG 3078607 correct using variable
    IF p_from_item_number IS NOT NULL  /*NSRIVAST, INVCONV*/
    THEN
      gmd_outbound_apis_pub.g_from_item_no := p_from_item_number;
      where_clause := where_clause||'AND msi.inventory_item_id IN ( SELECT distinct inventory_item_id FROM mtl_system_items_kfv'
                                  ||' WHERE concatenated_segments >= :from_item_number'
                                  ||' AND organization_id = gse.organization_id)';    -- 5346713 rework added org id

      using_clause := using_clause||', gmd_outbound_apis_pub.g_from_item_no  ';
    END IF;

    IF p_to_item_number IS NOT NULL   /*NSRIVAST, INVCONV*/
    THEN
      gmd_outbound_apis_pub.g_to_item_no := p_to_item_number;
      where_clause := where_clause||'AND msi.inventory_item_id IN ( SELECT distinct inventory_item_id FROM mtl_system_items_kfv'
                                  ||' WHERE concatenated_segments <= :to_item_number'
                                  ||' AND organization_id = gse.organization_id)';   -- 5346713 rework added org id
      using_clause := using_clause||', gmd_outbound_apis_pub.g_to_item_no ';
    END IF;

    IF p_inventory_item_id IS NOT NULL  /*NSRIVAST, INVCONV*/
    THEN
      gmd_outbound_apis_pub.g_inventory_item_id := p_inventory_item_id;
      where_clause := where_clause||'AND msi.inventory_item_id = :inventory_item_id '
                                  ||' AND msi.organization_id = gse.organization_id';   -- 5346713 rework added org id
      using_clause := using_clause||', gmd_outbound_apis_pub.g_inventory_item_id ';
    END IF;

    IF p_from_lot_number IS NOT NULL   /*NSRIVAST, INVCONV*/
    THEN
      gmd_outbound_apis_pub.g_from_lot_number := p_from_lot_number;
      where_clause := where_clause||'AND gse.lot_number >= :from_lot_number ';
      using_clause := using_clause||', gmd_outbound_apis_pub.g_from_lot_number ';
    END IF;

    IF p_to_lot_number IS NOT NULL   /*NSRIVAST, INVCONV*/
    THEN
      gmd_outbound_apis_pub.g_to_lot_number := p_to_lot_number;
      where_clause := where_clause||'AND gse.lot_number <= :to_lot_number ';
      using_clause := using_clause||', gmd_outbound_apis_pub.g_to_lot_number ';
    END IF;

    -- BUG 3078607 lot_id from gse not ilm
    IF p_lot_number IS NOT NULL    /*NSRIVAST, INVCONV*/
    THEN
      gmd_outbound_apis_pub.g_lot_number := p_lot_number;
      where_clause := where_clause||'AND gse.lot_number = :lot_number ';
      using_clause := using_clause||', gmd_outbound_apis_pub.g_lot_number ';
    END IF;

    IF p_from_last_update_date IS NOT NULL
    THEN
      gmd_outbound_apis_pub.g_from_last_update_date := p_from_last_update_date;
      where_clause := where_clause||'AND gcr.last_update_date >= :from_last_update_date ';
      using_clause := using_clause||', gmd_outbound_apis_pub.g_from_last_update_date ';
    END IF;

    IF p_to_last_update_date IS NOT NULL
    THEN
      gmd_outbound_apis_pub.g_to_last_update_date := p_to_last_update_date;
      where_clause := where_clause||'AND gcr.last_update_date <= :to_last_update_date '; -- BUG 3078683
      using_clause := using_clause||', gmd_outbound_apis_pub.g_to_last_update_date ';
    END IF;

    IF p_delete_mark IS NOT NULL
    THEN
      gmd_outbound_apis_pub.g_delete_mark := p_delete_mark ;
      where_clause := where_clause||'AND gcr.delete_mark = :delete_mark ';
      using_clause := using_clause||', gmd_outbound_apis_pub.g_delete_mark ';
    END IF;

    -- That's more or less the job done. We just need to tell the system where to store the data

    into_clause := ' BULK COLLECT INTO gmd_outbound_apis_pub.g_composite_results_table ';

    execution_string := 'BEGIN EXECUTE IMMEDIATE '
                       ||''''
                       ||sql_statement||column_list||table_list||where_clause
                       ||''''
                       ||into_clause
                       ||using_clause
                       ||'; END;';

    gme_debug.put_line('The sql statement is:');
    i:= 1;
    LOOP
      gme_debug.put_line(substr(execution_string, i, 100));
      EXIT WHEN i> LENGTH(execution_string);
      i := i+100;
    END LOOP;
    gme_debug.put_line('Executing string');

    EXECUTE IMMEDIATE execution_string;
   -- gme_debug.put_line('here 1 ');
    FOR i IN 1..g_composite_results_table.count
    LOOP
      --gme_debug.put_line('inside internal loop  i = ' || i);
      IF g_composite_results_table(i).inventory_item_id IS NOT NULL AND g_composite_results_table(i).item_number IS NULL
      THEN
        gme_debug.put_line('select from mtl_system_items_kfv  using '|| g_composite_results_table(i).inventory_item_id);
        SELECT concatenated_segments INTO g_composite_results_table(i).item_number
        FROM   mtl_system_items_kfv msi
        WHERE  inventory_item_id = g_composite_results_table(i).inventory_item_id
        and rownum = 1 ; -- 5346713 rework
      END IF;

      /*IF g_composite_results_table(i).lot_number IS NOT NULL
      THEN
          gme_debug.put_line('select from mtl_lot_numbers using '|| g_composite_results_table(i).lot_number);
          SELECT lot_number INTO g_composite_results_table(i).lot_number
          FROM mtl_lot_numbers
          WHERE lot_number = g_composite_results_table(i).lot_number;
      END IF;*/


    END LOOP;


    gme_debug.put_line('Returning table to caller');
    x_composite_results_table := gmd_outbound_apis_pub.g_composite_results_table;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

  END IF;


  FND_MSG_PUB.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  gme_debug.put_line('Finished FETCH_COMPOSITE_RESULTS');

EXCEPTION
  WHEN OTHERS
  THEN
    FND_MESSAGE.SET_NAME('GMD',SQLCODE);
    FND_MSG_PUB.Add;
    FND_MSG_PUB.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    x_return_status := FND_API.G_RET_STS_ERROR;

END fetch_composite_results;


PROCEDURE fetch_samples
( p_api_version                  IN NUMBER
, p_init_msg_list                IN VARCHAR2 DEFAULT FND_API.G_FALSE
, p_user_name                    IN VARCHAR2
, p_organization_id              IN NUMBER   DEFAULT NULL
, p_from_sample_no               IN VARCHAR2 DEFAULT NULL
, p_to_sample_no                 IN VARCHAR2 DEFAULT NULL
, p_sample_id	                 IN NUMBER   DEFAULT NULL
, p_sampling_event_id            IN NUMBER   DEFAULT NULL
, p_from_item_number             IN VARCHAR2 DEFAULT NULL /*bug 4165704, INVCONV*/
, p_to_item_number               IN VARCHAR2 DEFAULT NULL /*bug 4165704, INVCONV*/
, p_inventory_item_id            IN NUMBER   DEFAULT NULL /*bug 4165704, INVCONV*/
, p_revision                     IN VARCHAR2 DEFAULT NULL /*bug 4165704, INVCONV*/
, p_from_lot_number              IN VARCHAR2 DEFAULT NULL /*bug 4165704, INVCONV*/
, p_to_lot_number                IN VARCHAR2 DEFAULT NULL /*bug 4165704, INVCONV*/
, p_parent_lot_number            IN VARCHAR2 DEFAULT NULL /*bug 4165704, INVCONV*/
--, p_lot_number                   IN VARCHAR2 DEFAULT NULL /*bug 4165704, INVCONV*/
, p_priority		      	 IN VARCHAR2 DEFAULT NULL
, p_spec_name		     	 IN VARCHAR2 DEFAULT NULL
, p_spec_vers		     	 IN VARCHAR2 DEFAULT NULL
, p_spec_id		         IN NUMBER   DEFAULT NULL
, p_source		         IN VARCHAR2 DEFAULT NULL
, p_from_date_drawn	    	 IN DATE     DEFAULT NULL
, p_to_date_drawn	      	 IN DATE     DEFAULT NULL
, p_from_expiration_date	 IN DATE     DEFAULT NULL
, p_to_expiration_date		 IN DATE     DEFAULT NULL
, p_from_date_received           IN DATE     DEFAULT NULL
, p_to_date_received             IN DATE     DEFAULT NULL
, p_from_date_required           IN DATE     DEFAULT NULL
, p_to_date_required             IN DATE     DEFAULT NULL
, p_resources                    IN VARCHAR2 DEFAULT NULL
, p_instance_id                  IN NUMBER   DEFAULT NULL
, p_from_retrieval_date          IN DATE     DEFAULT NULL
, p_to_retrieval_date            IN DATE     DEFAULT NULL
, p_sample_type                  IN VARCHAR2 DEFAULT NULL
, p_ss_id                        IN NUMBER   DEFAULT NULL
, p_ss_organization_id           IN VARCHAR2 DEFAULT NULL
, p_ss_no                        IN VARCHAR2 DEFAULT NULL
, p_variant_id                   IN NUMBER   DEFAULT NULL
, p_variant_no                   IN NUMBER   DEFAULT NULL
, p_time_point_id                IN NUMBER   DEFAULT NULL
, p_source_subinventory	       	 IN VARCHAR2 DEFAULT NULL
, p_source_locator_id	    	 IN NUMBER   DEFAULT NULL
, p_grade_code		         IN VARCHAR2 DEFAULT NULL
, p_sample_disposition		 IN VARCHAR2 DEFAULT NULL
, p_storage_subinventory       	 IN VARCHAR2 DEFAULT NULL
, p_storage_locator_id		 IN NUMBER   DEFAULT NULL
, p_lab_organization_id 	 IN VARCHAR2 DEFAULT NULL
, p_external_id			 IN VARCHAR2 DEFAULT NULL
, p_sampler			 IN VARCHAR2 DEFAULT NULL
, p_lot_retest_ind  		 IN VARCHAR2 DEFAULT NULL
, p_subinventory	     	 IN VARCHAR2 DEFAULT NULL
, p_locator_id               	 IN NUMBER   DEFAULT NULL
, p_wip_plant_code 		 IN VARCHAR2 DEFAULT NULL
, p_wip_batch_no		 IN VARCHAR2 DEFAULT NULL
, p_wip_batch_id		 IN NUMBER   DEFAULT NULL
, p_wip_recipe_no		 IN VARCHAR2 DEFAULT NULL
, p_wip_recipe_version		 IN NUMBER   DEFAULT NULL
, p_wip_recipe_id		 IN NUMBER   DEFAULT NULL
, p_wip_formula_no		 IN VARCHAR2 DEFAULT NULL
, p_wip_formula_version          IN NUMBER   DEFAULT NULL
, p_wip_formula_id	     	 IN NUMBER   DEFAULT NULL
, p_wip_formulaline	    	 IN NUMBER   DEFAULT NULL
, p_wip_formulaline_id		 IN NUMBER   DEFAULT NULL
, p_wip_line_type	      	 IN NUMBER   DEFAULT NULL
, p_wip_routing_no	     	 IN VARCHAR2 DEFAULT NULL
, p_wip_routing_vers  		 IN NUMBER   DEFAULT NULL
, p_wip_routing_id		 IN NUMBER   DEFAULT NULL
, p_wip_batchstep_no 		 IN NUMBER   DEFAULT NULL
, p_wip_batchstep_id		 IN NUMBER   DEFAULT NULL
, p_wip_oprn_no			 IN VARCHAR2 DEFAULT NULL
, p_wip_oprn_vers	      	 IN NUMBER   DEFAULT NULL
, p_wip_oprn_id		       	 IN NUMBER   DEFAULT NULL
, p_cust_name		     	 IN VARCHAR2 DEFAULT NULL
, p_cust_id		         IN NUMBER   DEFAULT NULL
, p_org_id		       	 IN NUMBER   DEFAULT NULL
, p_cust_ship_to_site_id	 IN NUMBER   DEFAULT NULL
, p_cust_order		    	 IN VARCHAR2 DEFAULT NULL
, p_cust_order_id	      	 IN NUMBER   DEFAULT NULL
, p_cust_order_type	    	 IN VARCHAR2 DEFAULT NULL
, p_cust_order_line	    	 IN NUMBER   DEFAULT NULL
, p_cust_order_line_id		 IN NUMBER   DEFAULT NULL
, p_supplier		      	 IN VARCHAR2 DEFAULT NULL
, p_supplier_id		       	 IN NUMBER   DEFAULT NULL
, p_supplier_site_id		 IN NUMBER   DEFAULT NULL
, p_supplier_po		         IN VARCHAR2 DEFAULT NULL
, p_supplier_po_id		     IN NUMBER   DEFAULT NULL
, p_supplier_po_line		 IN NUMBER   DEFAULT NULL
, p_supplier_po_line_id		 IN NUMBER   DEFAULT NULL
, p_from_last_update_date	     IN DATE     DEFAULT NULL
, p_to_last_update_date          IN DATE     DEFAULT NULL
, p_retain_as                    IN VARCHAR2 DEFAULT NULL
, p_delete_mark		        	 IN NUMBER   DEFAULT NULL
, p_lpn                      IN VARCHAR2 DEFAULT NULL  -- 7027149
, p_lpn_id 	      	         IN NUMBER   DEFAULT NULL-- 7027149
, x_samples_table                OUT NOCOPY system.gmd_samples_tab_type -- 5335829
, x_return_status                OUT NOCOPY VARCHAR2
, x_msg_count                    OUT NOCOPY NUMBER
, x_msg_data                     OUT NOCOPY VARCHAR2

)
IS
  -- BUG 3078013 increase size of variables
  sql_statement            VARCHAR2(2000);
  column_list              VARCHAR2(4000);
  table_list               VARCHAR2(2000);
  where_clause             VARCHAR2(4000);
  into_clause              VARCHAR2(4000);
  using_clause             VARCHAR2(4000);
  execution_string         VARCHAR2(12000);
  row_count                NUMBER;
  i                        NUMBER;

  l_api_name               VARCHAR2(100) := 'fetch_samples';

  l_ss_table_included      VARCHAR2(10);

  G_PKG_NAME           CONSTANT  VARCHAR2(30):='GMD_OUTBOUND_APIS_PUB';

BEGIN
gme_debug.put_line('Starting FETCH_SAMPLES');
--  dbms_output.put_line('Enter GMD_OUTBOUND_APIS_PUB.FETCH_SAMPLES API');
  -- (gmd_outbound_apis_pub.api_version, p_api_version, l_api_name,'GMD_OUTBOUND_APIS_PUB')
  IF NOT FND_API.Compatible_API_CALL
    (gmd_outbound_apis_pub.api_version, p_api_version , l_api_name , G_PKG_NAME)
  THEN

--    dbms_output.put_line('api version error');
    Raise FND_API.G_EXC_UNEXPECTED_ERROR;

  ELSIF NOT initialized_ok(p_user_name)

  THEN

--    dbms_output.put_line('user name error');
    Raise FND_API.G_EXC_UNEXPECTED_ERROR;
  ELSE

--    dbms_output.put_line('Starting FETCH_SAMPLES processing');
    gme_debug.put_line('Starting FETCH_SAMPLES processing');
    /*  Initialize message list if p_int_msg_list is set TRUE.  */
    IF FND_API.to_boolean(p_init_msg_list)
    THEN
      FND_MSG_PUB.Initialize;
    END IF;

    -- Start construction for the select.

--    dbms_output.put_line('Begin constructing SELECT statement');
    gme_debug.put_line('Begin constructing SELECT statement');
    sql_statement := 'SELECT ';

    -- BUG 3077905 Retrieve sample_disposition from gmd_sample_spec_disp not gmd_samples

    column_list := 'system.gmd_samples_rec_type( gs.sampling_event_id, gs.step_no, gs.step_id, ' -- 5335829
                   ||'gs.sample_id, gs.sample_no, gs.sample_desc, '
                   ||'gesd.spec_id, null, null , '
                   ||'gs.lab_organization_id, gs.inventory_item_id, gs.revision, null, '
                   ||'gs.locator_id, gs.expiration_date, '
                   ||'gs.lot_number, gs.parent_lot_number, '
                   ||'gs.batch_id, null, null, '
                   ||'gs.recipe_id, null, null, '
                   ||'gs.formula_id, null, null, gs.formulaline_id, null, null, '
                   ||'gs.routing_id, null, null, gs.oprn_id, null, null, null,null, gs.charge, '
                   ||'gs.cust_id, null, gs.order_id, null, null, gs.order_line_id, null, gs.org_id, null, '
                   ||'gs.supplier_id, null, gs.sample_qty, gs.sample_qty_uom, gs.source, '
                   ||'gs.sampler_id, null, gs.date_drawn, gs.source_comment, '
                   ||'gs.storage_subinventory, gs.storage_locator_id, gs.external_id, '
                   ||'gs.sample_approver_id, gs.inv_approver_id, '
                   ||'gs.priority, gs.sample_inv_trans_ind, '
                   ||'gs.supplier_site_id, null, gs.subinventory, gs.organization_id, '
                   ||'gs.po_header_id, null, gs.po_line_id, null, '
                   ||'gs.receipt_id, null, gs.receipt_line_id, null, '
                   ||'gssd.disposition, gs.ship_to_site_id, null, '
                   ||'gs.supplier_lot_no, gs.lot_retest_ind, gs.sample_instance, '
                   ||'gs.source_subinventory, gs.source_locator_id, '
                   ||'gs.date_received, gs.date_required, gs.resources, gs.instance_id, '
                   ||'gs.retrieval_date, gs.sample_type, gs.time_point_id, gs.variant_id, '
                   ||'gs.delete_mark, gs.text_code, gs.attribute_category, gs.attribute1, '
                   ||'gs.attribute2, gs.attribute3, gs.attribute4, gs.attribute5, '
                   ||'gs.attribute6, gs.attribute7, gs.attribute8, gs.attribute9, '
                   ||'gs.attribute10, gs.attribute11, gs.attribute12, gs.attribute13, '
                   ||'gs.attribute14, gs.attribute15, gs.attribute16, gs.attribute17, '
                   ||'gs.attribute18, gs.attribute19, gs.attribute20, gs.attribute21, '
                   ||'gs.attribute22, gs.attribute23, gs.attribute24, gs.attribute25, '
                   ||'gs.attribute26, gs.attribute27, gs.attribute28, gs.attribute29, '
                   ||'gs.attribute30,  gs.creation_date, gs.created_by, fu1.user_name, '
                   ||'gs.last_update_date, gs.last_updated_by, fu2.user_name, '
                   ||'gs.last_update_login, gs.retain_as, gs.remaining_qty, gs.lpn_id, null) ';  -- 7027149

    table_list := 'FROM gmd_samples gs, gmd_event_spec_disp gesd,gmd_sample_spec_disp gssd, '
                ||'fnd_user fu1, fnd_user fu2 ';


    -- BUG 3077905 Retrieve sample_disposition from gmd_sample_spec_disp not gmd_samples
    where_clause := 'WHERE gs.sampling_event_id = gesd.sampling_event_id and '
                  ||' gesd.event_spec_disp_id = gssd.event_spec_disp_id and '
                  ||' gs.sample_id = gssd.sample_id and '
                  ||' gesd.spec_used_for_lot_attrib_ind = ''''Y'''' and '
                  ||' fu1.user_id = gs.created_by AND fu2.user_id = gs.last_updated_by and 1=:dummy ';

    using_clause := ' USING 1 ';
--    dbms_output.put_line('Before test for organization id not null');

    -- Work down the parameter list and append conditions, bind variables and bind values.
    -- ===================================================================================

    IF p_organization_id IS NOT NULL
    THEN
      gmd_outbound_apis_pub.g_orgn_id := p_organization_id;
      where_clause := where_clause||'AND gs.organization_id = :organization_id ';
      using_clause := using_clause||', gmd_outbound_apis_pub.g_orgn_id ';
    END IF;
--    dbms_output.put_line('after organization id test for null');

    IF p_from_sample_no IS NOT NULL
    THEN
      gmd_outbound_apis_pub.g_from_sample_no := p_from_sample_no;
      where_clause := where_clause||'AND gs.sample_no >= :from_sample_no ';
      using_clause := using_clause||', gmd_outbound_apis_pub.g_from_sample_no ';
    END IF;

    IF p_to_sample_no IS NOT NULL
    THEN
      gmd_outbound_apis_pub.g_to_sample_no := p_to_sample_no;
      where_clause := where_clause||'AND gs.sample_no <= :to_sample_no ';
      using_clause := using_clause||', gmd_outbound_apis_pub.g_to_sample_no ';
    END IF;

    IF p_sample_id IS NOT NULL
    THEN
      gmd_outbound_apis_pub.g_sample_id := p_sample_id;
      where_clause := where_clause||'AND gs.sample_id = :sample_id ';
      using_clause := using_clause||', gmd_outbound_apis_pub.g_sample_id ';
    END IF;

    IF p_sampling_event_id IS NOT NULL
    THEN
      gmd_outbound_apis_pub.g_sampling_event_id := p_sampling_event_id;
      where_clause := where_clause||'AND gs.sampling_event_id = :sampling_event_id ';
      using_clause := using_clause||', gmd_outbound_apis_pub.g_sampling_event_id ';
    END IF;

-- 5335829 rework

   IF p_from_item_number IS NOT NULL and p_to_item_number IS NOT NULL
    THEN
      g_from_item_number := p_from_item_number;
      g_to_item_number := p_to_item_number;
      where_clause := where_clause
                        ||' AND gs.inventory_item_id IN (SELECT inventory_item_id FROM mtl_system_items_b_kfv'
                        ||' WHERE concatenated_segments BETWEEN :from_item_number AND :to_item_number'
			 	||' AND organization_id = gs.organization_id)';   -- 5335829 rework - owner_organization_id is not a valid column name
      using_clause := using_clause||', gmd_outbound_apis_pub.g_from_item_number, gmd_outbound_apis_pub.g_to_item_number';
    ELSIF p_from_item_number IS NOT NULL
    THEN
      g_from_item_number := p_from_item_number;
      where_clause := where_clause
                        ||' AND gs.inventory_item_id IN (SELECT inventory_item_id FROM mtl_system_items_b_kfv'
                        ||' WHERE concatenated_segments >= :from_item_number'
				 	||' AND organization_id = gs.organization_id)';   -- 5335829 rework - owner_organization_id is not a valid column name
      using_clause := using_clause||', gmd_outbound_apis_pub.g_from_item_number';
    ELSIF p_to_item_number IS NOT NULL
    THEN
      g_to_item_number := p_to_item_number;
      where_clause := where_clause
                        ||' AND gs.inventory_item_id IN (SELECT inventory_item_id FROM mtl_system_items_b_kfv'
                        ||' WHERE concatenated_segments <= :to_item_number'
			 	||' AND organization_id = gs.organization_id)';   -- 5335829 rework - owner_organization_id is not a valid column name
      using_clause := using_clause||', gmd_outbound_apis_pub.g_to_item_number';
    END IF; --  IF p_from_item_number IS NOT NULL and p_to_item_number IS NOT NULL
-- 5335829 end of rework
           -- Bug 4165704 invconv: this code should not be needed anymore
           --table_list := table_list ||', ic_item_mst iim ';
           --IF p_from_item_number IS NOT NULL THEN
           --where_clause := where_clause||'AND iim.item_number >= :from_item_number ';
           --END IF;
           --IF p_to_item_number IS NOT NULL THEN
           --where_clause := where_clause||'AND iim.item_number <= :to_item_number ';
           --END IF;
   --    dbms_output.put_line('after item_number');

    IF p_inventory_item_id IS NOT NULL
    THEN
      gmd_outbound_apis_pub.g_inventory_item_id := p_inventory_item_id;
      where_clause := where_clause||'AND gs.inventory_item_id = :inventory_item_id ';
      using_clause := using_clause||', gmd_outbound_apis_pub.g_inventory_item_id ';
    END IF;

    IF p_from_lot_number IS NOT NULL
    THEN
      gmd_outbound_apis_pub.g_from_lot_number := p_from_lot_number;
      where_clause := where_clause||'AND gs.lot_number >= :from_lot_number ';
      using_clause := using_clause||', gmd_outbound_apis_pub.g_from_lot_number ';
    END IF;

    IF p_to_lot_number IS NOT NULL
    THEN
      gmd_outbound_apis_pub.g_to_lot_number := p_to_lot_number;
      where_clause := where_clause||'AND gs.lot_number <= :to_lot_number ';
      using_clause := using_clause||', gmd_outbound_apis_pub.g_to_lot_number ';
    END IF;

    IF p_parent_lot_number IS NOT NULL
    THEN
      gmd_outbound_apis_pub.g_parent_lot_number := p_parent_lot_number;
      where_clause := where_clause||'AND gs.parent_lot_number = :parent_lot_number ';
      using_clause := using_clause||', gmd_outbound_apis_pub.g_parent_lot_number ';
    END IF;

    /* taken out for Bug 4165704
    IF p_lot_id IS NOT NULL
    THEN
      gmd_outbound_apis_pub.g_lot_id := p_lot_id;
      where_clause := where_clause||'AND gs.lot_id = :lot_id ';
      using_clause := using_clause||', gmd_outbound_apis_pub.g_lot_id ';
    END IF;
    */

    IF p_priority IS NOT NULL
    THEN
      gmd_outbound_apis_pub.g_priority := p_priority;
      where_clause := where_clause||'AND gs.priority = :priority ';
      using_clause := using_clause||', gmd_outbound_apis_pub.g_priority ';
    END IF;
--    dbms_output.put_line('after priority');

    IF (p_spec_name IS NOT NULL OR p_spec_vers IS NOT NULL or p_spec_id is NOT NULL or p_grade_code is NOT NULL)
    THEN
      table_list := table_list ||',  gmd_specifications gspec ';
      where_clause := where_clause ||'AND gesd.spec_id = gspec.spec_id ';

      IF p_spec_name IS NOT NULL
      THEN
        gmd_outbound_apis_pub.g_spec_name := p_spec_name;
        where_clause := where_clause||'AND gspec.spec_name = :spec_name ';
        using_clause := using_clause||', gmd_outbound_apis_pub.g_spec_name ';
      END IF;

      IF p_spec_vers IS NOT NULL
      THEN
        gmd_outbound_apis_pub.g_spec_vers := p_spec_vers;
        where_clause := where_clause||'AND gspec.spec_vers = :spec_vers ';
        using_clause := using_clause||', gmd_outbound_apis_pub.g_spec_vers ';
      END IF;

      IF p_spec_id IS NOT NULL
      THEN
        gmd_outbound_apis_pub.g_spec_id := p_spec_id;
        where_clause := where_clause||'AND gspec.spec_id = :spec_id ';
        using_clause := using_clause||', gmd_outbound_apis_pub.g_spec_id ';
      END IF;

      IF p_grade_code IS NOT NULL
      THEN
        gmd_outbound_apis_pub.g_grade := p_grade_code;
        where_clause := where_clause||'AND gspec.grade = :grade ';
        using_clause := using_clause||', gmd_outbound_apis_pub.g_grade ';
      END IF;
    END IF;

    IF p_source IS NOT NULL
    THEN
      gmd_outbound_apis_pub.g_source := p_source;
      where_clause := where_clause||'AND gs.source = :source ';
      using_clause := using_clause||', gmd_outbound_apis_pub.g_source ';
    END IF;

    IF p_from_date_drawn IS NOT NULL
    THEN
      gmd_outbound_apis_pub.g_from_date_drawn := p_from_date_drawn;
      where_clause := where_clause||'AND gs.date_drawn >= :from_date_drawn ';
      using_clause := using_clause||', gmd_outbound_apis_pub.g_from_date_drawn ';
    END IF;

    IF p_to_date_drawn IS NOT NULL
    THEN
      gmd_outbound_apis_pub.g_to_date_drawn := p_to_date_drawn;
      where_clause := where_clause||'AND gs.date_drawn <= :to_date_drawn ';
      using_clause := using_clause||', gmd_outbound_apis_pub.g_to_date_drawn ';
    END IF;

    IF p_from_expiration_date IS NOT NULL
    THEN
      gmd_outbound_apis_pub.g_from_expiration_date := p_from_expiration_date;
      where_clause := where_clause||'AND gs.expiration_date >= :from_expiration_date ';
      using_clause := using_clause||', gmd_outbound_apis_pub.g_from_expiration_date ';
    END IF;

    IF p_to_expiration_date IS NOT NULL
    THEN
      gmd_outbound_apis_pub.g_to_expiration_date := p_to_expiration_date;
      where_clause := where_clause||'AND gs.expiration_date <= :to_expiration_date ';
      using_clause := using_clause||', gmd_outbound_apis_pub.g_to_expiration_date ';
    END IF;

    IF p_source_subinventory IS NOT NULL
    THEN
      gmd_outbound_apis_pub.g_source_subinventory := p_source_subinventory;
      where_clause := where_clause||'AND gs.source_subinventory = :source_subinventory ';
      using_clause := using_clause||', gmd_outbound_apis_pub.g_source_subinventory ';
    END IF;

    IF p_source_locator_id IS NOT NULL
    THEN
      gmd_outbound_apis_pub.g_source_locator_id := p_source_locator_id;
      where_clause := where_clause||'AND gs.source_locator_id = :source_locator_id ';
      using_clause := using_clause||', gmd_outbound_apis_pub.g_source_locator_id ';
    END IF;

    IF p_sample_disposition IS NOT NULL
    THEN
      gmd_outbound_apis_pub.g_sample_disposition := p_sample_disposition;
      where_clause := where_clause||'AND gssd.disposition = :sample_disposition ';
      using_clause := using_clause||', gmd_outbound_apis_pub.g_sample_disposition ';
    END IF;
--    dbms_output.put_line('after sample_disp');

    IF p_storage_subinventory IS NOT NULL
    THEN
      gmd_outbound_apis_pub.g_storage_subinventory := p_storage_subinventory;
      where_clause := where_clause||'AND gs.storage_subinventory = :storage_subinventory ';
      using_clause := using_clause||', gmd_outbound_apis_pub.g_storage_subinventory ';
    END IF;

    IF p_storage_locator_id IS NOT NULL
    THEN
      gmd_outbound_apis_pub.g_storage_locator_id := p_storage_locator_id;
      where_clause := where_clause||'AND gs.storage_locator_id = :storage_locator_id ';
      using_clause := using_clause||', gmd_outbound_apis_pub.g_storage_locator_id ';
    END IF;

    IF p_lab_organization_id IS NOT NULL
    THEN
      gmd_outbound_apis_pub.g_lab_organization_id := p_lab_organization_id;
      where_clause := where_clause||'AND gs.lab_organization_id = :lab_organization_id ';
      using_clause := using_clause||', gmd_outbound_apis_pub.g_lab_organization_id ';
    END IF;

    IF p_external_id IS NOT NULL
    THEN
      gmd_outbound_apis_pub.g_external_id := p_external_id;
      where_clause := where_clause||'AND gs.external_id = :external_id ';
      using_clause := using_clause||', gmd_outbound_apis_pub.g_external_id ';
    END IF;

    IF p_sampler IS NOT NULL
    THEN
      table_list := table_list ||', fnd_user fu3 ';
      where_clause := where_clause ||'AND gs.sampler_id = fu3.user_id ';

      gmd_outbound_apis_pub.g_sampler := p_sampler;
      where_clause := where_clause||'AND fu3.user_name = :sampler ';
      using_clause := using_clause||', gmd_outbound_apis_pub.g_sampler ';
    END IF;

    IF p_lot_retest_ind IS NOT NULL
    THEN
      gmd_outbound_apis_pub.g_lot_retest_ind := p_lot_retest_ind;
      where_clause := where_clause||'AND gs.lot_retest_ind = :lot_retest_ind ';
      using_clause := using_clause||', gmd_outbound_apis_pub.g_lot_retest_ind ';
    END IF;

    IF p_subinventory IS NOT NULL
    THEN
      gmd_outbound_apis_pub.g_subinventory := p_subinventory;
      where_clause := where_clause||'AND gs.subinventory = :subinventory ';
      using_clause := using_clause||', gmd_outbound_apis_pub.g_subinventory ';
    END IF;

    IF p_locator_id IS NOT NULL
    THEN
      gmd_outbound_apis_pub.g_locator_id := p_locator_id;
      where_clause := where_clause||'AND gs.locator_id = :locator_id ';
      using_clause := using_clause||', gmd_outbound_apis_pub.g_locator_id ';
    END IF;

    /* Bug 4165704: taken out for inventory convergence
    IF p_location_id IS NOT NULL
    THEN
      table_list := table_list ||', ic_loct_mst ilm ';
      where_clause := where_clause ||'AND gs.location = ilm.location ';

      gmd_outbound_apis_pub.g_location_id := p_location_id;
      where_clause := where_clause||'AND ilm.inventory_location_id = :location_id ';
      using_clause := using_clause||', gmd_outbound_apis_pub.g_location_id ';
    END IF;
    */

    IF (p_wip_plant_code IS NOT NULL or p_wip_batch_no IS NOT NULL)
    THEN
      table_list := table_list ||', gme_batch_header gbh ';
      where_clause := where_clause ||'AND gs.batch_id = gbh.batch_id ';
      IF p_wip_plant_code IS NOT NULL
      THEN
        gmd_outbound_apis_pub.g_wip_plant_code := p_wip_plant_code;
        where_clause := where_clause||'AND gbh.plant_code = :wip_plant_code ';
        using_clause := using_clause||', gmd_outbound_apis_pub.g_wip_plant_code ';
      END IF;

      IF p_wip_batch_no IS NOT NULL
      THEN
        gmd_outbound_apis_pub.g_wip_batch_no := p_wip_batch_no;
        where_clause := where_clause||'AND gbh.batch_no = :wip_batch_no ';
        using_clause := using_clause||', gmd_outbound_apis_pub.g_wip_batch_no ';
      END IF;
    END IF;

    IF p_wip_batch_id IS NOT NULL
    THEN
      gmd_outbound_apis_pub.g_wip_batch_id := p_wip_batch_id;
      where_clause := where_clause||'AND gs.batch_id = :wip_batch_id ';
      using_clause := using_clause||', gmd_outbound_apis_pub.g_wip_batch_id ';
    END IF;

    IF (p_wip_recipe_no IS NOT NULL or p_wip_recipe_version IS NOT NULL)
    THEN
      table_list := table_list ||', gmd_recipes_b r ';
      where_clause := where_clause ||'AND gs.recipe_id = r.recipe_id ';

      IF p_wip_recipe_no IS NOT NULL
      THEN
        gmd_outbound_apis_pub.g_wip_recipe_no := p_wip_recipe_no;
        where_clause := where_clause||'AND r.recipe_no = :wip_recipe_no ';
        using_clause := using_clause||', gmd_outbound_apis_pub.g_wip_recipe_no ';
      END IF;

      IF p_wip_recipe_version IS NOT NULL
      THEN
        gmd_outbound_apis_pub.g_wip_recipe_version := p_wip_recipe_version;
        where_clause := where_clause||'AND r.recipe_version = :wip_recipe_version ';
        using_clause := using_clause||', gmd_outbound_apis_pub.g_wip_recipe_version ';
      END IF;
    END IF;

    IF p_wip_recipe_id IS NOT NULL
    THEN
      gmd_outbound_apis_pub.g_wip_recipe_id := p_wip_recipe_id;
      where_clause := where_clause||'AND r.recipe_id = :wip_recipe_id ';
      using_clause := using_clause||', gmd_outbound_apis_pub.g_wip_recipe_id ';
    END IF;

    -- BUG 3082684 - incorporate formula_vers
    IF p_wip_formula_no IS NOT NULL or p_wip_formula_version IS NOT NULL
    THEN
      table_list := table_list ||', fm_form_mst ffm ';
      where_clause := where_clause ||'AND gs.formula_id = ffm.formula_id ';

      IF p_wip_formula_no IS NOT NULL
      THEN
        gmd_outbound_apis_pub.g_wip_formula_no := p_wip_formula_no;
        where_clause := where_clause||'AND ffm.formula_no = :wip_formula_no ';
        using_clause := using_clause||', gmd_outbound_apis_pub.g_wip_formula_no ';
      END IF;

      IF p_wip_formula_version IS NOT NULL
      THEN
        gmd_outbound_apis_pub.g_wip_formula_vers := p_wip_formula_version;
        where_clause := where_clause||'AND ffm.formula_vers = :wip_formula_vers ';
        using_clause := using_clause||', gmd_outbound_apis_pub.g_wip_formula_vers ';
      END IF;
    END IF;

    IF p_wip_formula_id IS NOT NULL
    THEN
      gmd_outbound_apis_pub.g_wip_formula_id := p_wip_formula_id;
      where_clause := where_clause||'AND gs.formula_id = :wip_formula_id ';
      using_clause := using_clause||', gmd_outbound_apis_pub.g_wip_formula_id ';
    END IF;

    IF (p_wip_formulaline IS NOT NULL or p_wip_line_type IS NOT NULL)
    THEN
      table_list := table_list ||', fm_matl_dtl fmd ';
      where_clause := where_clause ||'AND gs.formulaline_id = fmd.formulaline_id ';

      IF p_wip_formulaline IS NOT NULL
      THEN
        gmd_outbound_apis_pub.g_wip_formulaline := p_wip_formulaline;
        where_clause := where_clause||'AND fmd.line_no = :wip_formulaline ';
        using_clause := using_clause||', gmd_outbound_apis_pub.g_wip_formulaline ';
      END IF;

      IF p_wip_line_type IS NOT NULL
      THEN
        gmd_outbound_apis_pub.g_wip_line_type := p_wip_line_type;
        where_clause := where_clause||'AND fmd.line_type = :wip_line_type ';
        using_clause := using_clause||', gmd_outbound_apis_pub.g_wip_line_type ';
      END IF;
    END IF;

    IF p_wip_formulaline_id IS NOT NULL
    THEN
      gmd_outbound_apis_pub.g_wip_formulaline_id := p_wip_formulaline_id;
      where_clause := where_clause||'AND gs.formulaline_id = :wip_formulaline_id ';
      using_clause := using_clause||', gmd_outbound_apis_pub.g_wip_formulaline_id ';
    END IF;

    IF (p_wip_routing_no IS NOT NULL or p_wip_routing_vers IS NOT NULL)
    THEN
      table_list := table_list ||', gmd_routings_b grout ';
      where_clause := where_clause ||'AND gs.routing_id = grout.routing_id ';

      IF p_wip_routing_no IS NOT NULL
      THEN
        gmd_outbound_apis_pub.g_wip_routing_no := p_wip_routing_no;
        where_clause := where_clause||'AND grout.routing_no = :wip_routing_no ';
        using_clause := using_clause||', gmd_outbound_apis_pub.g_wip_routing_no ';
      END IF;

      IF p_wip_routing_vers IS NOT NULL
      THEN
        gmd_outbound_apis_pub.g_wip_routing_vers := p_wip_routing_vers;
        where_clause := where_clause||'AND grout.routing_vers = :wip_routing_vers ';
        using_clause := using_clause||', gmd_outbound_apis_pub.g_wip_routing_vers ';
      END IF;
    END IF;

    IF p_wip_routing_id IS NOT NULL
    THEN
      gmd_outbound_apis_pub.g_wip_routing_id := p_wip_routing_id;
      where_clause := where_clause||'AND gs.routing_id = :wip_routing_id ';
      using_clause := using_clause||', gmd_outbound_apis_pub.g_wip_routing_id ';
    END IF;


    IF p_wip_batchstep_no IS NOT NULL
    THEN
      gmd_outbound_apis_pub.g_wip_batchstep_no := p_wip_batchstep_no;
      where_clause := where_clause||'AND gs.step_no = :wip_batchstep_no ';
      using_clause := using_clause||', gmd_outbound_apis_pub.g_wip_batchstep_no ';
    END IF;

    IF p_wip_batchstep_id IS NOT NULL
    THEN
      gmd_outbound_apis_pub.g_wip_batchstep_id := p_wip_batchstep_id;
      where_clause := where_clause||'AND gs.step_id = :wip_batchstep_id ';
      using_clause := using_clause||', gmd_outbound_apis_pub.g_wip_batchstep_id ';
    END IF;

    IF (p_wip_oprn_no IS NOT NULL or p_wip_oprn_vers IS NOT NULL )
    THEN
      table_list := table_list ||', gmd_operations go ';
      where_clause := where_clause ||'AND gs.oprn_id = go.oprn_id ';

      IF p_wip_oprn_no IS NOT NULL
      THEN
        gmd_outbound_apis_pub.g_wip_oprn_no := p_wip_oprn_no;
        where_clause := where_clause||'AND go.oprn_no = :wip_oprn_no ';
        using_clause := using_clause||', gmd_outbound_apis_pub.g_wip_oprn_no ';
      END IF;

      IF p_wip_oprn_vers IS NOT NULL
      THEN
        gmd_outbound_apis_pub.g_wip_oprn_vers := p_wip_oprn_vers;
        where_clause := where_clause||'AND go.oprn_vers = :wip_oprn_vers ';
        using_clause := using_clause||', gmd_outbound_apis_pub.g_wip_oprn_vers ';
      END IF;
    END IF;

    IF p_wip_oprn_id IS NOT NULL
    THEN
      gmd_outbound_apis_pub.g_wip_oprn_id := p_wip_oprn_id;
      where_clause := where_clause||'AND gs.oprn_id = :wip_oprn_id ';
      using_clause := using_clause||', gmd_outbound_apis_pub.g_wip_oprn_id ';
    END IF;

    IF p_cust_name IS NOT NULL
    THEN
      table_list := table_list ||', hz_cust_accounts_all hca, hz_parties hp ';
      where_clause := where_clause ||'AND gs.cust_id = hca.cust_account_id and hca.party_id = hp.party_id ';

      gmd_outbound_apis_pub.g_cust_name := p_cust_name;
      where_clause := where_clause||'AND hp.party_name = :cust_name ';
      using_clause := using_clause||', gmd_outbound_apis_pub.g_cust_name ';
    END IF;

    IF p_cust_id IS NOT NULL
    THEN
      gmd_outbound_apis_pub.g_cust_id := p_cust_id;
      where_clause := where_clause||'AND gs.cust_id = :cust_id ';
      using_clause := using_clause||', gmd_outbound_apis_pub.g_cust_id ';
    END IF;

    IF p_org_id IS NOT NULL
    THEN
      gmd_outbound_apis_pub.g_org_id := p_org_id;
      where_clause := where_clause||'AND gs.org_id = :org_id ';
      using_clause := using_clause||', gmd_outbound_apis_pub.g_org_id ';
    END IF;

    IF p_cust_ship_to_site_id IS NOT NULL
    THEN
      gmd_outbound_apis_pub.g_cust_ship_to_site_id := p_cust_ship_to_site_id;
      where_clause := where_clause||'AND gs.ship_to_site_id = :cust_ship_to_site_id ';
      using_clause := using_clause||', gmd_outbound_apis_pub.g_cust_ship_to_site_id ';
    END IF;
--    dbms_output.put_line('after shipto site id');

    IF p_cust_order is NOT NULL or p_cust_order_type is NOT NULL
    THEN
      table_list := table_list ||', oe_order_headers_all ooh ';
      where_clause := where_clause ||'AND gs.order_id = ooh.header_id ';

      IF p_cust_order IS NOT NULL
      THEN
        gmd_outbound_apis_pub.g_cust_order := p_cust_order;
        where_clause := where_clause||'AND ooh.order_number = :cust_order ';
        using_clause := using_clause||', gmd_outbound_apis_pub.g_cust_order ';
      END IF;

      IF p_cust_order_type IS NOT NULL
      THEN
        table_list := table_list ||', oe_transaction_types_all ott ';
        where_clause := where_clause ||'AND ooh.order_type_id = ott.transaction_type_id ';

        gmd_outbound_apis_pub.g_cust_order_type := p_cust_order_type;
        where_clause := where_clause||'AND ott.transaction_type_code = :cust_order_type ';
        using_clause := using_clause||', gmd_outbound_apis_pub.g_cust_order_type ';
      END IF;
    END IF;

    IF p_cust_order_id IS NOT NULL
    THEN
      gmd_outbound_apis_pub.g_cust_order_id := p_cust_order_id;
      where_clause := where_clause||'AND gs.order_id = :cust_order_id ';
      using_clause := using_clause||', gmd_outbound_apis_pub.g_cust_order_id ';
    END IF;

    IF p_cust_order_line IS NOT NULL
    THEN
      table_list := table_list ||', oe_order_lines_all ool ';
      where_clause := where_clause ||'AND gs.order_line_id = ool.line_id ';

      gmd_outbound_apis_pub.g_cust_order_line := p_cust_order_line;
      where_clause := where_clause||'AND ool.line_number = :cust_order_line ';
      using_clause := using_clause||', gmd_outbound_apis_pub.g_cust_order_line ';
    END IF;

    IF p_cust_order_line_id IS NOT NULL
    THEN
      gmd_outbound_apis_pub.g_cust_order_line_id := p_cust_order_line_id;
      where_clause := where_clause||'AND gs.order_line_id = :cust_order_line_id ';
      using_clause := using_clause||', gmd_outbound_apis_pub.g_cust_order_line_id ';
    END IF;

    IF p_supplier IS NOT NULL
    THEN
      table_list := table_list ||', po_vendors v ';
      where_clause := where_clause ||'AND gs.supplier_id = v.vendor_id ';

      gmd_outbound_apis_pub.g_supplier := p_supplier;
      where_clause := where_clause||'AND v.vendor_name = :supplier ';     -- 5335829 rework  - changed from segment1
      using_clause := using_clause||', gmd_outbound_apis_pub.g_supplier ';
    END IF;

    IF p_supplier_id IS NOT NULL
    THEN
      gmd_outbound_apis_pub.g_supplier_id := p_supplier_id;
      where_clause := where_clause||'AND gs.supplier_id = :supplier_id ';
      using_clause := using_clause||', gmd_outbound_apis_pub.g_supplier_id ';
    END IF;

    IF p_supplier_site_id IS NOT NULL
    THEN
      gmd_outbound_apis_pub.g_supplier_site_id := p_supplier_site_id;
      where_clause := where_clause||'AND gs.supplier_site_id = :supplier_site_id ';
      using_clause := using_clause||', gmd_outbound_apis_pub.g_supplier_site_id ';
    END IF;

    IF p_supplier_po IS NOT NULL
    THEN
      table_list := table_list ||', po_headers_all ph ';
      where_clause := where_clause ||'AND gs.po_header_id = ph.po_header_id ';

      gmd_outbound_apis_pub.g_supplier_po := p_supplier_po;
      where_clause := where_clause||'AND ph.segment1 = :supplier_po ';
      using_clause := using_clause||', gmd_outbound_apis_pub.g_supplier_po ';
    END IF;

    IF p_supplier_po_id IS NOT NULL
    THEN
      gmd_outbound_apis_pub.g_supplier_po_id := p_supplier_po_id;
      where_clause := where_clause||'AND gs.po_header_id = :supplier_po_id ';
      using_clause := using_clause||', gmd_outbound_apis_pub.g_supplier_po_id ';
    END IF;

    IF p_supplier_po_line IS NOT NULL
    THEN
      table_list := table_list ||', po_lines_all pl ';
      where_clause := where_clause ||'AND gs.po_line_id = pl.po_line_id ';

      gmd_outbound_apis_pub.g_supplier_po_line := p_supplier_po_line;
      where_clause := where_clause||'AND pl.line_num = :supplier_po_line ';
      using_clause := using_clause||', gmd_outbound_apis_pub.g_supplier_po_line ';
    END IF;

    IF p_supplier_po_line_id IS NOT NULL
    THEN
      gmd_outbound_apis_pub.g_supplier_po_line_id := p_supplier_po_line_id;
      where_clause := where_clause||'AND gs.po_line_id = :supplier_po_line_id ';
      using_clause := using_clause||', gmd_outbound_apis_pub.g_supplier_po_line_id ';
    END IF;

    IF p_from_last_update_date IS NOT NULL
    THEN
      gmd_outbound_apis_pub.g_from_last_update_date := p_from_last_update_date;
      where_clause := where_clause||'AND gs.last_update_date >= :from_last_update_date ';
      using_clause := using_clause||', gmd_outbound_apis_pub.g_from_last_update_date ';
    END IF;

    IF p_to_last_update_date IS NOT NULL
    THEN
      gmd_outbound_apis_pub.g_to_last_update_date := p_to_last_update_date;
      where_clause := where_clause||'AND gs.last_update_date <= :to_last_update_date ';
      using_clause := using_clause||', gmd_outbound_apis_pub.g_to_last_update_date ';
    END IF;

    IF p_delete_mark IS NOT NULL
    THEN
      gmd_outbound_apis_pub.g_delete_mark := p_delete_mark ;
      where_clause := where_clause||'AND gs.delete_mark = :delete_mark ';
      using_clause := using_clause||', gmd_outbound_apis_pub.g_delete_mark ';
    END IF;

    -- START B3124291 Incorporated Mini-Pack K Features to Outboud APIs
    IF p_from_date_received IS NOT NULL
    THEN
      gmd_outbound_apis_pub.g_from_date_received := p_from_date_received;
      where_clause := where_clause||'AND gs.date_received >= :from_date_received ';
      using_clause := using_clause||', gmd_outbound_apis_pub.g_from_date_received ';
    END IF;

    IF p_to_date_received IS NOT NULL
    THEN
      gmd_outbound_apis_pub.g_to_date_received := p_to_date_received;
      where_clause := where_clause||'AND gs.date_received <= :to_date_received ';
      using_clause := using_clause||', gmd_outbound_apis_pub.g_to_date_received ';
    END IF;

    IF p_from_date_required IS NOT NULL
    THEN
      gmd_outbound_apis_pub.g_from_date_required := p_from_date_required;
      where_clause := where_clause||'AND gs.date_required >= :from_date_required ';
      using_clause := using_clause||', gmd_outbound_apis_pub.g_from_date_required ';
    END IF;

    IF p_to_date_required IS NOT NULL
    THEN
      gmd_outbound_apis_pub.g_to_date_required := p_to_date_required;
      where_clause := where_clause||'AND gs.date_required <= :to_date_required ';
      using_clause := using_clause||', gmd_outbound_apis_pub.g_to_date_required ';
    END IF;

    IF p_resources IS NOT NULL
    THEN
      gmd_outbound_apis_pub.g_resources := p_resources;
      where_clause := where_clause||'AND gs.resources = :resources ';
      using_clause := using_clause||', gmd_outbound_apis_pub.g_resources ';
    END IF;

--    dbms_output.put_line('after resources');
    IF p_instance_id IS NOT NULL
    THEN
      gmd_outbound_apis_pub.g_instance_id := p_instance_id;
      where_clause := where_clause||'AND gs.instance_id = :instance_id ';
      using_clause := using_clause||', gmd_outbound_apis_pub.g_instance_id ';
    END IF;

    IF p_from_retrieval_date IS NOT NULL
    THEN
      gmd_outbound_apis_pub.g_from_retrieval_date := p_from_retrieval_date;
      where_clause := where_clause||'AND gs.retrieval_date >= :from_retrieval_date ';
      using_clause := using_clause||', gmd_outbound_apis_pub.g_from_retrieval_date ';
    END IF;

    IF p_to_retrieval_date IS NOT NULL
    THEN
      gmd_outbound_apis_pub.g_to_retrieval_date := p_to_retrieval_date;
      where_clause := where_clause||'AND gs.retrieval_date <= :to_retrieval_date ';
      using_clause := using_clause||', gmd_outbound_apis_pub.g_to_retrieval_date ';
    END IF;

    IF p_sample_type IS NOT NULL
    THEN
      gmd_outbound_apis_pub.g_sample_type := p_sample_type;
      where_clause := where_clause||'AND gs.sample_type = :sample_type ';
      using_clause := using_clause||', gmd_outbound_apis_pub.g_sample_type ';
    END IF;

    l_ss_table_included := 'FALSE';
    IF (p_ss_organization_id IS NOT NULL OR p_ss_no IS NOT NULL OR p_ss_id IS NOT NULL) THEN
      table_list := table_list ||', gmd_stability_studies_b ss, gmd_ss_variants ssv ';
      where_clause := where_clause ||'AND ss.ss_id = ssv.ss_id AND ssv.variant_id = gs.variant_id ';
      l_ss_table_included := 'TRUE';

      IF p_ss_id IS NOT NULL
      THEN
        gmd_outbound_apis_pub.g_ss_id := p_ss_id;
        where_clause := where_clause||'AND ss.ss_id = :ss_id ';
        using_clause := using_clause||', gmd_outbound_apis_pub.g_ss_id ';
      END IF;

      IF p_ss_organization_id IS NOT NULL
      THEN
        gmd_outbound_apis_pub.g_ss_organization_id := p_ss_organization_id;
        where_clause := where_clause||'AND ss.organization_id = :ss_organization_id ';
        using_clause := using_clause||', gmd_outbound_apis_pub.g_ss_organization_id ';
      END IF;

      IF p_ss_no IS NOT NULL
      THEN
        gmd_outbound_apis_pub.g_ss_no := p_ss_no;
        where_clause := where_clause||'AND ss.ss_no = :ss_no ';
        using_clause := using_clause||', gmd_outbound_apis_pub.g_ss_no ';
      END IF;

    END IF;

    IF p_variant_no IS NOT NULL
    THEN
      IF (l_ss_table_included = 'FALSE') THEN
        table_list := table_list ||', gmd_ss_variants ssv ';
        where_clause := where_clause ||'AND ssv.variant_id = gs.variant_id ';
      END IF;

      gmd_outbound_apis_pub.g_variant_no := p_variant_no;
      where_clause := where_clause||'AND ssv.variant_no = :variant_no ';
      using_clause := using_clause||', gmd_outbound_apis_pub.g_variant_no ';
    END IF;

    IF p_variant_id IS NOT NULL
    THEN
      gmd_outbound_apis_pub.g_variant_id := p_variant_id;
      where_clause := where_clause||'AND gs.variant_id = :variant_id ';
      using_clause := using_clause||', gmd_outbound_apis_pub.g_variant_id ';
    END IF;
--    dbms_output.put_line('after variant_id');

    IF p_time_point_id IS NOT NULL
    THEN
      gmd_outbound_apis_pub.g_time_point_id := p_time_point_id;
      where_clause := where_clause||'AND gs.time_point_id = :time_point_id ';
      using_clause := using_clause||', gmd_outbound_apis_pub.g_time_point_id ';
    END IF;

    -- END B3124291 Incorporated Mini-Pack K Features to Outboud APIs

    -- START Incorporated Mini-Pack L Features to Outboud APIs
    IF p_retain_as IS NOT NULL
    THEN
      gmd_outbound_apis_pub.g_retain_as := p_retain_as;
      where_clause := where_clause||'AND gs.retain_as = :retain_as ';
      using_clause := using_clause||', gmd_outbound_apis_pub.g_retain_as ';
    END IF;

    -- END Incorporated Mini-Pack L Features to Outboud APIs

-- 7027149

IF p_lpn_id IS NOT NULL
    THEN
      gmd_outbound_apis_pub.g_lpn_id := p_lpn_id;
      where_clause := where_clause||'AND gs.lpn_id = :lpn_id ';
      using_clause := using_clause||', gmd_outbound_apis_pub.g_lpn_id ';
   END IF;

IF p_lpn IS NOT NULL
    THEN
      table_list := table_list ||', wms_license_plate_numbers lpn ';
      where_clause := where_clause ||'AND gs.lpn_id = lpn.lpn_id ';

      gmd_outbound_apis_pub.g_lpn := p_lpn;
      where_clause := where_clause||'AND lpn.license_plate_number = :lpn ';
      using_clause := using_clause||', gmd_outbound_apis_pub.g_lpn ';
      gme_debug.put_line('in IF p_lpn IS NOT NULL ');


END IF;



    -- That's more or less the job done. We just need to tell the system where to store the data

    into_clause := ' BULK COLLECT INTO gmd_outbound_apis_pub.g_samples_table ';

    execution_string := 'BEGIN EXECUTE IMMEDIATE '
                       ||''''
                       ||sql_statement||column_list||table_list||where_clause
                       ||''''
                       ||into_clause
                       ||using_clause
                       ||'; END;';

  gme_debug.put_line('The sql statement is:');


--    dbms_output.put_line('The sql statement is:');
    i:= 1;
    LOOP
--      dbms_output.put_line(substr(execution_string, i, 100));
      gme_debug.put_line(substr(execution_string, i, 100));
      EXIT WHEN i> LENGTH(execution_string);
      i := i+100;
    END LOOP;

--    dbms_output.put_line('Executing stringxxx');
    gme_debug.put_line('Executing string');
    EXECUTE IMMEDIATE execution_string;
    gme_debug.put_line('out of executing string ');
    -- Now fill in any missing data

--    dbms_output.put_line('filling in missing data');
    FOR i IN 1..g_samples_table.count
    LOOP
        gme_debug.put_line('sample no=' || g_samples_table(i).sample_no);
      IF g_samples_table(i).spec_id is not NULL
       THEN
        gme_debug.put_line('select from gmd_specifications_b using spec_id of '
                          || g_samples_table(i).spec_id);
        select spec_name, spec_vers into g_samples_table(i).spec_name,g_samples_table(i).spec_vers
          from gmd_specifications_b
          where spec_id = g_samples_table(i).spec_id;
      END IF;

      IF g_samples_table(i).inventory_item_id is not NULL
      THEN
--        dbms_output.put_line('select from mtl_system_items using inventory_item_id of '|| g_samples_table(i).inventory_item_id);
--    dbms_output.put_line('filling in missing data');
        select concatenated_segments into g_samples_table(i).item_number
          from mtl_system_items_b_kfv
          where inventory_item_id = g_samples_table(i).inventory_item_id
            and organization_id  = g_samples_table(i).organization_id;
      END IF;

      IF g_samples_table(i).batch_id is not NULL
      THEN
--        dbms_output.put_line('select from gme_batch_header with batch_id of '|| g_samples_table(i).batch_id);
        select plant_code, batch_no into g_samples_table(i).plant_code,g_samples_table(i).batch_no
          from gme_batch_header
          where batch_id = g_samples_table(i).batch_id;
      END IF;

      IF g_samples_table(i).recipe_id is not NULL
      THEN
--        dbms_output.put_line('select from gmd_recipes_b with recipe_id of '|| g_samples_table(i).recipe_id);
        select recipe_no, recipe_version into g_samples_table(i).recipe_no,
                                              g_samples_table(i).recipe_version
          from gmd_recipes_b
          where recipe_id = g_samples_table(i).recipe_id;
      END IF;

      IF g_samples_table(i).formula_id is not NULL
      THEN
--        dbms_output.put_line('select from fm_form_mst with formula_id of '|| g_samples_table(i).formula_id);
        select formula_no, formula_vers into g_samples_table(i).formula_no,
                                             g_samples_table(i).formula_vers
          from fm_form_mst
          where formula_id = g_samples_table(i).formula_id;
      END IF;

      IF g_samples_table(i).formulaline_id is not NULL
      THEN
        --dbms_output.put_line('select from fm_matl_dtl with formulaline_id of '
        --                  || g_samples_table(i).formulaline_id);
        select line_no, line_type into g_samples_table(i).formulaline_no,
                                       g_samples_table(i).line_type
          from fm_matl_dtl
          where formulaline_id = g_samples_table(i).formulaline_id;
      END IF;

      IF g_samples_table(i).routing_id is not NULL
      THEN
        --dbms_output.put_line('select from gmd_routings_b with routing_id of '
        --                  || g_samples_table(i).routing_id);
        select routing_no, routing_vers into g_samples_table(i).routing_no,g_samples_table(i).routing_vers
          from gmd_routings_b
          where routing_id = g_samples_table(i).routing_id;
      END IF;

      IF g_samples_table(i).oprn_id is not NULL
      THEN
        --dbms_output.put_line('select from gmd_operations with oprn_id of '|| g_samples_table(i).oprn_id);
        select oprn_no, oprn_vers into g_samples_table(i).oprn_no,g_samples_table(i).oprn_vers
          from gmd_operations
          where oprn_id = g_samples_table(i).oprn_id;
      END IF;

      IF g_samples_table(i).cust_id is not NULL
      THEN
        --dbms_output.put_line('select from hz_cust_accounts_all with cust_id of '
        --                  || g_samples_table(i).cust_id);
        select hp.party_name into g_samples_table(i).cust_name
          from hz_cust_accounts_all hca,hz_parties hp
          where hca.cust_account_id = g_samples_table(i).cust_id
            and hca.party_id = hp.party_id;
      END IF;

      IF g_samples_table(i).order_id is not NULL
      THEN
        --dbms_output.put_line('select from oe_order_headers_all with header_id of '
        --                  || g_samples_table(i).order_id);
        select ooh.order_number, ott.transaction_type_code into
               g_samples_table(i).order_number, g_samples_table(i).order_type
          from oe_order_headers_all ooh, oe_transaction_types_all ott
          where ooh.header_id = g_samples_table(i).order_id and
                ooh.order_type_id = ott.transaction_type_id ;
      END IF;

      IF g_samples_table(i).order_line_id is not NULL
      THEN
        --dbms_output.put_line('select from oe_order_lines_all with line_id of '
        --                  || g_samples_table(i).order_line_id);
        select line_number into g_samples_table(i).order_line_number
          from oe_order_lines_all
          where line_id = g_samples_table(i).order_line_id;
      END IF;

      IF g_samples_table(i).org_id is not NULL
      THEN
        --dbms_output.put_line('select from hr_operating_units using org_id of '|| g_samples_table(i).org_id);
        select name into g_samples_table(i).org_name
          from hr_operating_units
          where organization_id = g_samples_table(i).org_id;
      END IF;

      IF g_samples_table(i).supplier_id is not NULL
      THEN
        --dbms_output.put_line('select from po_vendors using vendor_id of '|| g_samples_table(i).supplier_id);
        select segment1 into g_samples_table(i).supplier_no
          from po_vendors
          where vendor_id = g_samples_table(i).supplier_id;
      END IF;

      IF g_samples_table(i).sampler_id is not NULL
      THEN
        --dbms_output.put_line('select from fnd_user using user_id of '|| g_samples_table(i).sampler_id);
        select user_name into g_samples_table(i).sampler
          from fnd_user
          where user_id = g_samples_table(i).sampler_id;
      END IF;

      IF g_samples_table(i).po_header_id is not NULL
      THEN
        --dbms_output.put_line('select from po_headers_all with po_header_id of '
        --                  || g_samples_table(i).po_header_id);
        select segment1 into g_samples_table(i).po_number
          from po_headers_all
          where po_header_id = g_samples_table(i).po_header_id;
      END IF;

      IF g_samples_table(i).supplier_site_id is not NULL
      THEN
        --dbms_output.put_line('select from po_vendor_sites_all with supplier_site_id of '
        --                  || g_samples_table(i).supplier_site_id);
        select vendor_site_code into g_samples_table(i).supplier_site
          from po_vendor_sites_all
          where vendor_site_id = g_samples_table(i).supplier_site_id;
      END IF;

      IF g_samples_table(i).po_line_id is not NULL
      THEN
        --dbms_output.put_line('select from po_lines_all with po_line_id of '
        --                  || g_samples_table(i).po_line_id);
        select line_num into g_samples_table(i).po_line_number
          from po_lines_all
          where po_line_id = g_samples_table(i).po_line_id;
      END IF;

      IF g_samples_table(i).receipt_id is not NULL
      THEN
        --dbms_output.put_line('select from rcv_shipment_headers with shipment_header_id of '
        --                  || g_samples_table(i).receipt_id);
        select receipt_num into g_samples_table(i).receipt_no
          from rcv_shipment_headers
          where shipment_header_id = g_samples_table(i).receipt_id;
      END IF;

      IF g_samples_table(i).receipt_line_id is not NULL
      THEN
         -- Bug 3970893: receipt line id is changed from transaction if to shipment line id
        --dbms_output.put_line('select from rcv_shipment_lines with shipment_line_id of '
        --                  || g_samples_table(i).receipt_line_id);
        select rsl.line_num into g_samples_table(i).receipt_line
          from rcv_shipment_lines rsl
          where  rsl.shipment_line_id = g_samples_table(i).receipt_line_id;
      END IF;

      IF g_samples_table(i).ship_to_site_id is not NULL
      THEN
        --dbms_output.put_line('select from hz_cust_site_uses_all with site_use_id of '
        --                  || g_samples_table(i).ship_to_site_id);
          SELECT location into g_samples_table(i).ship_to_location
          FROM hz_cust_site_uses_all
          WHERE site_use_id = g_samples_table(i).ship_to_site_id;
      END IF;

      --7027149 Added sql to get LPN from id
      IF g_samples_table(i).lpn_id is not NULL
      THEN
          SELECT license_plate_number into g_samples_table(i).lpn
          FROM wms_license_plate_numbers
   				WHERE lpn_id = g_samples_table(i).lpn_id;
      END IF;





    END LOOP;

    x_samples_table := gmd_outbound_apis_pub.g_samples_table;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
--    dbms_output.put_line('Returning table to caller');

gme_debug.put_line('Returning table to caller');






  END IF;

  FND_MSG_PUB.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
--  dbms_output.put_line('Finished FETCH_SAMPLES');

EXCEPTION
  WHEN OTHERS
  THEN

    FND_MESSAGE.SET_NAME('GMD',SQLCODE);
    FND_MSG_PUB.Add;
    FND_MSG_PUB.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    gme_debug.put_line('exception sqlcode =  '
                          || SQLCODE );
    x_return_status := FND_API.G_RET_STS_ERROR;


END fetch_samples;


PROCEDURE fetch_sample_groups
( p_api_version                IN NUMBER
, p_init_msg_list              IN VARCHAR2 DEFAULT FND_API.G_FALSE
, p_user_name                  IN VARCHAR2
, p_organization_id            IN VARCHAR2 DEFAULT NULL
, p_from_sample_no             IN VARCHAR2 DEFAULT NULL
, p_to_sample_no               IN VARCHAR2 DEFAULT NULL
, p_sample_event_id            IN NUMBER   DEFAULT NULL
, p_from_item_number           IN VARCHAR2 DEFAULT NULL
, p_to_item_number             IN VARCHAR2 DEFAULT NULL
, p_inventory_item_id          IN NUMBER   DEFAULT NULL
, p_revision                   IN NUMBER   DEFAULT NULL
, p_from_lot_number            IN VARCHAR2 DEFAULT NULL
, p_to_lot_number              IN VARCHAR2 DEFAULT NULL
, p_from_parent_lot_number     IN VARCHAR2 DEFAULT NULL
, p_to_parent_lot_number       IN VARCHAR2 DEFAULT NULL
, p_disposition                IN VARCHAR2 DEFAULT NULL
, p_subinventory               IN VARCHAR2 DEFAULT NULL
, p_locator_id                 IN VARCHAR2 DEFAULT NULL
, p_wip_organization_id        IN VARCHAR2 DEFAULT NULL
, p_wip_batch_no               IN VARCHAR2 DEFAULT NULL
, p_wip_batch_id               IN NUMBER   DEFAULT NULL
, p_wip_recipe_no              IN VARCHAR2 DEFAULT NULL
, p_wip_recipe_vers            IN NUMBER   DEFAULT NULL
, p_wip_recipe_id              IN NUMBER   DEFAULT NULL
, p_wip_formula_no             IN VARCHAR2 DEFAULT NULL
, p_wip_formula_vers           IN NUMBER   DEFAULT NULL
, p_wip_formula_id             IN NUMBER   DEFAULT NULL
, p_wip_formulaline_no         IN NUMBER   DEFAULT NULL
, p_wip_formulaline_id         IN NUMBER   DEFAULT NULL
, p_wip_formulaline_type       IN NUMBER   DEFAULT NULL
, p_wip_routing_no             IN VARCHAR2 DEFAULT NULL
, p_wip_routing_vers           IN NUMBER   DEFAULT NULL
, p_wip_routing_id             IN NUMBER   DEFAULT NULL
, p_wip_step_no                IN NUMBER   DEFAULT NULL
, p_wip_step_id                IN NUMBER   DEFAULT NULL
, p_wip_oprn_no                IN VARCHAR2 DEFAULT NULL
, p_wip_oprn_vers              IN NUMBER   DEFAULT NULL
, p_wip_oprn_id                IN NUMBER   DEFAULT NULL
, p_customer                   IN NUMBER   DEFAULT NULL
, p_customer_id                IN VARCHAR2 DEFAULT NULL
, p_customer_org_id            IN NUMBER   DEFAULT NULL
, p_customer_ship_to_location  IN VARCHAR2 DEFAULT NULL
, p_customer_ship_to_location_id IN NUMBER   DEFAULT NULL
, p_customer_order_number      IN NUMBER   DEFAULT NULL
, p_customer_order_id          IN NUMBER   DEFAULT NULL
, p_customer_order_type        IN NUMBER   DEFAULT NULL
, p_customer_order_line        IN NUMBER   DEFAULT NULL
, p_customer_order_line_id     IN NUMBER   DEFAULT NULL
, p_supplier                   IN NUMBER   DEFAULT NULL
, p_supplier_id                IN NUMBER   DEFAULT NULL
, p_supplier_site              IN VARCHAR2 DEFAULT NULL
, p_supplier_po_number         IN VARCHAR2 DEFAULT NULL
, p_supplier_po_id             IN NUMBER   DEFAULT NULL
, p_supplier_po_line           IN NUMBER   DEFAULT NULL
, p_supplier_po_line_id        IN NUMBER   DEFAULT NULL
, p_delete_mark                IN NUMBER   DEFAULT NULL
, p_from_last_update_date      IN DATE     DEFAULT NULL
, p_to_last_update_date        IN DATE     DEFAULT NULL
-- START B3124291 Incorporated Mini-Pack K Features to Outboud APIs
, p_sg_organization_id         IN VARCHAR2 DEFAULT NULL
, p_resources                  IN VARCHAR2 DEFAULT NULL
, p_instance_id                IN NUMBER   DEFAULT NULL
, p_ss_id                      IN NUMBER   DEFAULT NULL
, p_ss_organization_id         IN VARCHAR2 DEFAULT NULL
, p_ss_no                      IN VARCHAR2 DEFAULT NULL
, p_variant_id                 IN NUMBER   DEFAULT NULL
, p_variant_no                 IN NUMBER   DEFAULT NULL
, p_time_point_id              IN NUMBER   DEFAULT NULL
-- END B3124291 Incorporated Mini-Pack K Features to Outboud APIs
, x_sample_groups_table        OUT NOCOPY system.gmd_sampling_events_tab_type
, x_return_status              OUT NOCOPY VARCHAR2
, x_msg_count                  OUT NOCOPY NUMBER
, x_msg_data                   OUT NOCOPY VARCHAR2
)
IS
  sql_statement            VARCHAR2(32000);

  main_column_list         VARCHAR2(10000);
  disp_column_list         VARCHAR2(10000);

  main_table_list          VARCHAR2(10000);
  disp_table_list          VARCHAR2(10000);

  main_where_clause        VARCHAR2(10000);
  disp_where_clause        VARCHAR2(10000);

  main_using_clause        VARCHAR2(10000);
  disp_using_clause        VARCHAR2(10000);

  main_into_clause         VARCHAR2(10000);
  main_execution_string    VARCHAR2(10000);

  row_count                NUMBER;
  l_api_name               VARCHAR2(240) := 'fetch_sample_groups';

  string_length            NUMBER;
  i                        NUMBER;

  l_ss_table_included      VARCHAR2(10);

BEGIN

  IF NOT FND_API.Compatible_API_CALL
    (gmd_outbound_apis_pub.api_version, p_api_version, l_api_name,'GMD_OUTBOUND_APIS_PUB')
  OR NOT initialized_ok(p_user_name)
  THEN
    Raise FND_API.G_EXC_UNEXPECTED_ERROR;
  ELSE
    --dbms_output.put_line('Starting Fetch_Sample_Groups');

    /*  Initialize message list if p_int_msg_list is set TRUE.  */
    IF FND_API.to_boolean(p_init_msg_list)
    THEN
      FND_MSG_PUB.Initialize;
    END IF;

    -- Start construction for the select.
    --dbms_output.put_line('Starting statement construction');

    sql_statement := 'SELECT ';

    -- Build the query to retrieve all base rows from gmd_sampling events together with
    -- linked nested rowsets from gmd_event_spec_disp
    --
    -- The code looks worse than it is. All the next few sections do is build SQL
    -- clauses that are then glued together and executed dynamically with binds,
    -- depending on what has been specified in the parameters.
    --
    -- By doing one large BULK COLLECT using the constructed statement, almost everything
    -- is retrieved in a single hit, including all of the nested data. All that we need to
    -- do afterwards is fill in the gaps where a direct retrieval is not possible due to
    -- nullable columns where we cannot make outer joins.
    --
    -- The end result will resemble:

    /* SELECT gmd_sampling_event_rec_type
              ( <gmd_sampling_events table columns>
              , CAST
                ( MULTISET
                  ( gmd_event_spec_disp_rec_type
                    ( SELECT <gmd_event_spec_disp table columns>
                      FROM   <gmd_event_spec_disp table set>
                      where  <GMD_EVENT_SPEC_DISP CONDITIONS WITH BIND VARIABLES> ***
                    )
                    AS gmd_event_spec_disps_tab_type
                  )
                )
              )
       FROM
            <main table list>
       WHERE
            <sampling events constraining conditions with binds> ****
    */

    -- Here goes.....

    main_column_list :='  se.RECEIPT_ID, rh.RECEIPT_NUM, se.PO_HEADER_ID , ph.SEGMENT1'
                     ||', se.SAMPLING_EVENT_ID, se.ORIGINAL_SPEC_VR_ID, se.DISPOSITION'
                     ||', se.SAMPLE_REQ_CNT, se.SAMPLE_TAKEN_CNT, se.SAMPLING_PLAN_ID'
                     ||', se.EVENT_TYPE_CODE, se.SAMPLING_EVENT_ID, se.inventory_item_id, im.concatenated_segments'
                     ||', se.lot_number, se.parent_lot_number, se.subinventory, se.locator_id'
                     ||', se.BATCH_ID, bh.BATCH_NO, se.RECIPE_ID, r.RECIPE_NO'
                     ||', r.RECIPE_VERSION, se.FORMULA_ID, fh.FORMULA_NO, fh.FORMULA_VERS'
                     ||', se.FORMULALINE_ID, fd.LINE_NO, se.ROUTING_ID, se.OPRN_ID'
                     ||', se.CHARGE, se.CUST_ID, NULL, se.ORDER_ID, oh.ORDER_NUMBER'
                     ||', se.ORDER_LINE_ID, ol.line_number, se.ORG_ID, mp.organization_code, se.SUPPLIER_ID'
                     ||', NULL, se.PO_LINE_ID, pl.LINE_NUM, se.RECEIPT_LINE_ID'
                     ||', NULL, se.SUPPLIER_LOT_NO, se.COMPLETE_IND'
                     ||', se.SAMPLE_ID_TO_EVALUATE, se.COMPOSITE_ID_TO_EVALUATE, se.TEXT_CODE'
                     ||', se.CREATION_DATE, se.CREATED_BY, fu1.USER_NAME, se.LAST_UPDATED_BY'
                     ||', fu2.USER_NAME, se.LAST_UPDATE_DATE, se.LAST_UPDATE_LOGIN'
                     ||', se.SUPPLIER_SITE_ID, NULL, se.SHIP_TO_SITE_ID, NULL'
                     ||', se.STEP_ID, se.STEP_NO, se.LOT_RETEST_IND, se.RECOMPOSITE_IND'
                     ||', se.SAMPLE_ACTIVE_CNT '
                     ||', se.organization_id, se.resources, se.instance_id, se.time_point_id '
                     ||', se.variant_id, se.archived_taken, se.reserved_taken ';

    main_table_list  :=' gmd_sampling_events se, rcv_shipment_headers rh, po_headers_all ph'
                     ||',gme_batch_header bh, fnd_user fu1, fnd_user fu2, gmd_recipes_b r'
                     ||',fm_form_mst_b fh, oe_order_headers_all oh, mtl_system_items_b im'
                     ||',po_lines_all pl, oe_order_lines_all ol, fm_matl_dtl fd'
                     ||',mtl_parameters mp';

    main_where_clause:=' 1=:dummy AND se.receipt_id = rh.shipment_header_id(+)'
                     ||' AND se.po_header_id = ph.po_header_id(+)'
                     ||' AND se.inventory_item_id = im.inventory_item_id(+)'
                     ||' AND se.batch_id = bh.batch_id(+)'
                     ||' AND se.recipe_id = r.recipe_id(+)'
                     ||' AND se.formula_id = fh.formula_id(+)'
                     ||' AND se.order_id = oh.header_id(+)'
                     ||' AND se.po_line_id = pl.po_line_id(+)'
                     ||' AND se.order_line_id = ol.line_id(+)'
                     ||' AND se.formulaline_id = fd.formulaline_id(+)'
                     ||' AND se.org_id = mp.organization_id(+)'
                     ||' AND se.created_by = fu1.user_id'
                     ||' AND se.last_updated_by = fu2.user_id';

    main_using_clause:='1';

    disp_column_list :=' sd.EVENT_SPEC_DISP_ID, sd.SPEC_ID, gs.SPEC_NAME, gs.SPEC_VERS'
                     ||',sd.SPEC_VR_ID, sd.DISPOSITION, sd.SPEC_USED_FOR_LOT_ATTRIB_IND'
                     ||',sd.DELETE_MARK, sd.CREATION_DATE, sd.CREATED_BY, fu3.USER_NAME'
                     ||',sd.LAST_UPDATE_DATE, sd.LAST_UPDATED_BY, fu4.USER_NAME, sd.LAST_UPDATE_LOGIN';

    disp_table_list  :=' gmd_event_spec_disp sd, gmd_specifications_b gs, fnd_user fu3, fnd_user fu4';

    disp_where_clause:=' sd.spec_id = gs.spec_id(+) AND sd.created_by = fu3.user_id'
                     ||' AND sd.last_updated_by = fu4.user_id'
                     ||' AND sd.sampling_event_id = se.sampling_event_id'
                     ||' AND 1=:dummy ';
    disp_using_clause:='1';

-- Bug 3124620; Changed where clause to validate the orgn_code
    IF p_organization_id IS NOT NULL
    THEN
      g_orgn_id := p_organization_id;
      main_where_clause := main_where_clause
                        ||' AND se.organization_id = :organization_id';
      main_using_clause := main_using_clause||', gmd_outbound_apis_pub.g_orgn_id';
    END IF;

    IF p_from_sample_no IS NOT NULL OR p_to_sample_no IS NOT NULL
    THEN
      main_table_list := main_table_list||', gmd_samples gsa';
      main_where_clause := main_where_clause||' AND se.sampling_event_id = gsa.sampling_event_id';

      IF p_from_sample_no IS NOT NULL
      THEN
        g_from_sample_no := p_from_sample_no;
        main_where_clause := main_where_clause||' AND gsa.sample_no >= :from_sample';
        main_using_clause := main_using_clause||', gmd_outbound_apis_pub.g_from_sample_no';
      END IF;

      IF p_to_sample_no IS NOT NULL
      THEN
        g_to_sample_no := p_to_sample_no;
        main_where_clause := main_where_clause||' AND gsa.sample_no <= :to_sample';
        main_using_clause := main_using_clause||', gmd_outbound_apis_pub.g_to_sample_no';
      END IF;
    END IF;

/*  Bug 3124627 - changed event_id to sampling_event_id                  */
    IF p_sample_event_id IS NOT NULL
    THEN
      g_sample_event_id := p_sample_event_id;
      main_where_clause := main_where_clause||
                            ' AND se.sampling_event_id = :sampling_event_id';
      main_using_clause := main_using_clause||
                            ', gmd_outbound_apis_pub.g_sample_event_id';
    END IF;

    IF (p_from_item_number IS NOT NULL OR p_to_item_number IS NOT NULL ) THEN
      g_from_item_number := p_from_item_number;
      g_to_item_number := p_to_item_number;
      main_where_clause := main_where_clause
                        ||' AND gs.inventory_item_id IN (SELECT inventory_item_id FROM mtl_system_items_b_kfv'
                        ||' WHERE concatenated_segments BETWEEN :from_item_number AND :to_item_number'
			||' AND organization_id = gs.owner_organization_id)';
      main_using_clause := main_using_clause||', gmd_outbound_apis_pub.g_from_item_number, gmd_outbound_apis_pub.g_to_item_number';
    END IF;     -- (p_from_item_number IS NOT NULL OR p_to_item_number IS NOT NULL )

          -- Bug 4165704 invconv: code replaced by above
          --IF p_from_item_number IS NOT NULL THEN
            --g_from_item_number := p_from_item_number;
            --main_where_clause := main_where_clause||' AND im.item_number >= :from_item';
            --main_using_clause := main_using_clause||', gmd_outbound_apis_pub.g_from_item_number';
            --END IF;
         --IF p_to_item_number IS NOT NULL THEN
           --g_to_item_number := p_to_item_number;
           --main_where_clause := main_where_clause||' AND im.item_number <= :to_item';
           --main_using_clause := main_using_clause||', gmd_outbound_apis_pub.g_to_item_number';
         --END IF;

    IF p_inventory_item_id IS NOT NULL
    THEN
      g_inventory_item_id := p_inventory_item_id;
      main_where_clause := main_where_clause||' AND se.inventory_item_id = :inventory_item_id';
      main_using_clause := main_using_clause||', gmd_outbound_apis_pub.g_inventory_item_id';
    END IF;

    IF p_from_lot_number IS NOT NULL
    THEN
      g_from_lot_number := p_from_lot_number;
      main_where_clause := main_where_clause||' AND se.lot_number >= :from_lot_number';
      main_using_clause := main_using_clause||', gmd_outbound_apis_pub.g_from_lot_number';
    END IF;

    IF p_to_lot_number IS NOT NULL
    THEN
      g_to_lot_number := p_to_lot_number;
      main_where_clause := main_where_clause||' AND se.lot_number <= :to_lot_number';
      main_using_clause := main_using_clause||', gmd_outbound_apis_pub.g_to_lot_number';
    END IF;

    IF p_from_parent_lot_number IS NOT NULL
    THEN
      g_from_parent_lot_number := p_from_parent_lot_number;
      main_where_clause := main_where_clause||' AND se.parent_lot_number >= :from_parent_lot_number';
      main_using_clause := main_using_clause||', gmd_outbound_apis_pub.g_from_parent_lot_number';
    END IF;

    IF p_to_parent_lot_number IS NOT NULL
    THEN
      g_to_parent_lot_number := p_to_parent_lot_number;
      main_where_clause := main_where_clause||' AND se.parent_lot_number <= :to_parent_lot_number';
      main_using_clause := main_using_clause||', gmd_outbound_apis_pub.g_to_parent_lot_number';
    END IF;

    /* taken out for bug 4165704
    IF p_lot_id IS NOT NULL
    THEN
      g_lot_id := p_lot_id;
      main_where_clause := main_where_clause||' AND se.lot_id = :lot_id';
      main_using_clause := main_using_clause||', gmd_outbound_apis_pub.g_lot_id';
    END IF;
    */

    IF p_subinventory IS NOT NULL
    THEN
      g_subinventory := p_subinventory;
      main_where_clause := main_where_clause||' AND se.subinventory = :subinventory';
      main_using_clause := main_using_clause||', gmd_outbound_apis_pub.g_subinventory';
    END IF;

    IF p_locator_id IS NOT NULL
    THEN
      g_locator_id := p_locator_id;
      main_where_clause := main_where_clause||' AND se.locator_id = :locator_id';
      main_using_clause := main_using_clause||', gmd_outbound_apis_pub.g_locator_id';
    END IF;

    /* taken out for invconv bug 4165704
    IF p_location_id IS NOT NULL
    THEN
      g_location_id := p_location_id;
      main_table_list := main_table_list||', ic_loct_mst lm';
      main_where_clause := main_where_clause||' AND se.location = il.location'
                                            ||' AND il.inventory_location_id = :location_id';
      main_using_clause := main_using_clause||', gmd_outbound_apis_pub.g_location_id';
    END IF;
    */

    IF p_wip_organization_id IS NOT NULL
    THEN
      g_wip_orgn_id := p_wip_organization_id;
      main_where_clause := main_where_clause||' AND bh.plant_code = :wip_organization_id';
      main_using_clause := main_using_clause||', gmd_outbound_apis_pub.g_wip_orgn_id';
    END IF;

    IF p_wip_batch_no IS NOT NULL
    THEN
      g_wip_batch_no := p_wip_batch_no;
      main_where_clause := main_where_clause||' AND bh.batch_no = :wip_batch_no';
      main_using_clause := main_using_clause||', gmd_outbound_apis_pub.g_wip_batch_no';
    END IF;

    IF p_wip_batch_id IS NOT NULL
    THEN
      g_wip_batch_id := p_wip_batch_id;
      main_where_clause := main_where_clause||' AND se.batch_id = :wip_batch_id';
      main_using_clause := main_using_clause||', gmd_outbound_apis_pub.g_wip_batch_id';
    END IF;

    IF p_wip_formula_no IS NOT NULL
    THEN
      g_wip_formula_no := p_wip_formula_no;
      main_where_clause := main_where_clause||' AND fh.formula_no = :wip_formula_no';
      main_using_clause := main_using_clause||', gmd_outbound_apis_pub.g_wip_formula_no';
    END IF;

    IF p_wip_formula_vers IS NOT NULL
    THEN
      g_wip_formula_vers := p_wip_formula_vers;
      main_where_clause := main_where_clause||' AND fh.formula_no = :wip_formula_vers';
      main_using_clause := main_using_clause||', gmd_outbound_apis_pub.g_wip_formula_vers';
    END IF;

    IF p_wip_formula_id IS NOT NULL
    THEN
      g_wip_formula_id := p_wip_formula_id;
      main_where_clause := main_where_clause||' AND se.formula_id = :wip_formula_id';
      main_using_clause := main_using_clause||', gmd_outbound_apis_pub.g_wip_formula_id';
    END IF;

    IF p_wip_recipe_no IS NOT NULL
    THEN
      g_wip_recipe_no := p_wip_recipe_no;
      main_where_clause := main_where_clause||' AND r.recipe_no = :wip_recipe_no';
      main_using_clause := main_using_clause||', gmd_outbound_apis_pub.g_wip_recipe_no';
    END IF;

 /*  Bug 3124643;  Changed r.recipe_no to r.recipe_version                  */
    IF p_wip_recipe_vers IS NOT NULL
    THEN
      g_wip_recipe_vers := p_wip_recipe_vers;
      main_where_clause := main_where_clause||' AND r.recipe_version = :wip_recipe_vers';
      main_using_clause := main_using_clause||', gmd_outbound_apis_pub.g_wip_recipe_vers';
    END IF;

    IF p_wip_recipe_id IS NOT NULL
    THEN
      g_wip_recipe_id := p_wip_recipe_id;
      main_where_clause := main_where_clause||' AND se.recipe_id = :wip_recipe_id';
      main_using_clause := main_using_clause||', gmd_outbound_apis_pub.g_wip_formula_id';
    END IF;

    IF p_wip_formulaline_id IS NOT NULL
    THEN
      g_wip_formulaline_id := p_wip_formulaline_id;
      main_where_clause := main_where_clause||' AND se.formulaline_id = :wip_formulaline_id';
      main_using_clause := main_using_clause||', gmd_outbound_apis_pub.g_wip_formulaline_id';
    END IF;

    IF p_wip_formulaline_no IS NOT NULL OR p_wip_formulaline_type IS NOT NULL
    THEN

      IF p_wip_formulaline_no IS NOT NULL
      THEN
        g_wip_formulaline_no := p_wip_formulaline_no;
        main_where_clause := main_where_clause||' AND fd.line_no = :wip_formulaline_no';
        main_using_clause := main_using_clause||', gmd_outbound_apis_pub.g_wip_formulaline_no';
      END IF;

      IF p_wip_formulaline_type IS NOT NULL
      THEN
        g_wip_formulaline_type := p_wip_formulaline_type;
        main_where_clause := main_where_clause||' AND fd.formulaline_type = :wip_formulaline_type';
        main_using_clause := main_using_clause||', gmd_outbound_apis_pub.g_wip_formulaline_type';
      END IF;
    END IF;

    IF p_wip_step_id IS NOT NULL
    THEN
      g_wip_step_id := p_wip_step_id;
      main_where_clause := main_where_clause||' AND se.step_id = :wip_step_id';
      main_using_clause := main_using_clause||', gmd_outbound_apis_pub.g_wip_step_id';
    END IF;

    IF p_wip_step_no IS NOT NULL
    THEN
      g_wip_step_no := p_wip_step_no;
      main_where_clause := main_where_clause||' AND se.step_no = :wip_step_no';
      main_using_clause := main_using_clause||', gmd_outbound_apis_pub.g_wip_step_no';
    END IF;

    IF p_wip_oprn_id IS NOT NULL
    THEN
      g_wip_oprn_id := p_wip_oprn_id;
      main_where_clause := main_where_clause||' AND se.oprn_id = :wip_oprn_id';
      main_using_clause := main_using_clause||', gmd_outbound_apis_pub.g_wip_oprn_id';
    END IF;

    IF p_wip_oprn_no IS NOT NULL OR p_wip_oprn_vers IS NOT NULL
    THEN
      main_table_list := main_table_list||', gmd_operations_b go';
      main_where_clause := main_where_clause||' AND se.oprn_id = go.oprn_id';

      IF p_wip_oprn_no IS NOT NULL
      THEN
        g_wip_oprn_no := p_wip_oprn_no;
        main_where_clause := main_where_clause||' AND go.oprn_no = :wip_oprn_no';
        main_using_clause := main_using_clause||', gmd_outbound_apis_pub.g_wip_oprn_no';
      END IF;

      IF p_wip_oprn_id IS NOT NULL
      THEN
        g_wip_oprn_id := p_wip_oprn_id;
        main_where_clause := main_where_clause||' AND go.oprn_vers = :wip_oprn_vers';
        main_using_clause := main_using_clause||', gmd_outbound_apis_pub.g_wip_oprn_vers';
      END IF;
    END IF;

    IF p_customer_order_id IS NOT NULL
    THEN
      g_customer_order_id := p_customer_order_id;
      main_where_clause := main_where_clause||' AND se.order_id = :customer_order_id';
      main_using_clause := main_using_clause||', gmd_outbound_apis_pub.g_customer_order_id';
    END IF;

    IF p_customer_order_number IS NOT NULL
    THEN
      g_customer_order_number := p_customer_order_number;
      main_where_clause := main_where_clause||' AND oh.order_number = :customer_order_number';
      main_using_clause := main_using_clause||', gmd_outbound_apis_pub.g_customer_order_number';
    END IF;

    IF p_customer IS NOT NULL
    THEN
      g_cust_name := p_customer;
      main_table_list := main_table_list ||', hz_cust_accounts_all hca, hz_parties hp ';
      main_where_clause := main_where_clause ||' AND se.cust_id = hca.cust_account_id'
                                             ||' AND hca.party_id = hp.party_id'
                                             ||' AND hp.party_name = :cust_name';
      main_using_clause := main_using_clause ||', gmd_outbound_apis_pub.g_cust_name ';
    END IF;

    IF p_customer_id IS NOT NULL
    THEN
      g_customer_id := p_customer_id;
      main_where_clause := main_where_clause||' AND se.cust_id = :customer_id';
      main_using_clause := main_using_clause||', gmd_outbound_apis_pub.g_customer_id';
    END IF;

     /*  Bug 3124653 Added code to retrieve sample groups by customer_ship_to_location &
                     customer_ship_to_location_id           */
    IF p_customer_ship_to_location IS NOT NULL
    THEN
      g_customer_ship_to_location := p_customer_ship_to_location;
      main_where_clause := main_where_clause||
                     ' AND se.ship_to_site_id IN '||
                     '    ( select site_use_id  '||
                     '      from hz_cust_site_uses_all '||
                     '      where location = :customer_ship_to_location)';
      main_using_clause := main_using_clause||
                     ', gmd_outbound_apis_pub.g_customer_ship_to_location';
    END IF;

    IF p_customer_ship_to_location_id IS NOT NULL
    THEN
      g_customer_ship_to_location_id := p_customer_ship_to_location_id;
      main_where_clause := main_where_clause||
                     ' AND se.ship_to_site_id = :customer_ship_to_location_id';
      main_using_clause := main_using_clause||
                     ', gmd_outbound_apis_pub.g_customer_ship_to_location_id';
    END IF;

    IF p_customer_order_type IS NOT NULL
    THEN
      g_customer_order_type := p_customer_order_type;
      main_table_list := main_table_list||', oe_transaction_types_all tt';
      main_where_clause := main_where_clause||' AND oh.order_type_id = tt.transaction_type_id'
                                            ||' AND tt.transaction_type_code = :customer_order_type';
      main_using_clause := main_using_clause||', gmd_outbound_apis_pub.g_customer_order_type';
    END IF;

    IF p_customer_order_line IS NOT NULL OR p_customer_order_line_id IS NOT NULL
    THEN
      main_where_clause := main_where_clause||' AND oh.header_id = ol.header_id';

      IF p_customer_order_line IS NOT NULL
      THEN
        g_customer_order_line := p_customer_order_line;
        main_where_clause := main_where_clause||' AND ol.line_number = :customer_order_line';
        main_using_clause := main_using_clause||', gmd_outbound_apis_pub.g_customer_order_line';
      END IF;

      IF p_customer_order_line_id IS NOT NULL
      THEN
        g_customer_order_line_id := g_customer_order_line_id;
        main_where_clause := main_where_clause||' AND ol.line_id = :customer_order_line_id';
        main_using_clause := main_using_clause||', gmd_outbound_apis_pub.g_customer_order_line_id';
      END IF;
    END IF;

    IF p_supplier_id IS NOT NULL
    THEN
      g_supplier_id := p_supplier_id;
      main_where_clause := main_where_clause||' AND se.supplier_id = :supplier_id';
      main_using_clause := main_using_clause||', gmd_outbound_apis_pub.g_supplier_id';
    END IF;

    IF p_supplier IS NOT NULL
    THEN
      g_supplier := p_supplier;
      main_table_list := main_table_list||', po_vendors v';
      main_where_clause := main_where_clause||' AND se.supplier_id = v.vendor_id'
                                            ||' AND v.segment1 = :supplier';
      main_using_clause := main_using_clause||', gmd_outbound_apis_pub.g_supplier';
    END IF;

    IF p_supplier_site IS NOT NULL
    THEN
      g_supplier_site := p_supplier_site;
      main_table_list := main_table_list||', po_vendor_sites_all  vsa';
      main_where_clause := main_where_clause||' AND  se.supplier_site_id = vsa.vendor_site_id'
                                            ||' AND  vsa.vendor_site_code = :supplier_site';
      main_using_clause := main_using_clause||', gmd_outbound_apis_pub.g_supplier_site';
    END IF;

    IF p_supplier_po_number IS NOT NULL
    THEN
      g_supplier_po_number := p_supplier_po_number;
      main_table_list := main_table_list||', po_headers_all pha';
      main_where_clause := main_where_clause||' AND se.po_header_id = pha.po_header_id'
                                            ||' AND pha.segment1 = :supplier_po_number';
      main_using_clause := main_using_clause||', gmd_outbound_apis_pub.g_supplier_po_number';
    END IF;

    IF p_supplier_po_id IS NOT NULL
    THEN
      g_supplier_po_id := p_supplier_po_id;
      main_where_clause := main_where_clause||' AND se.po_header_id = :supplier_po_id';
      main_using_clause := main_using_clause||', gmd_outbound_apis_pub.g_supplier_po_id';
    END IF;

    IF p_supplier_po_line IS NOT NULL
    THEN
      g_supplier_po_line := g_supplier_po_line;
      main_where_clause := main_where_clause||' AND pl.line_num = :supplier_po_line)';
      main_using_clause := main_using_clause||', gmd_outbound_apis_pub.g_supplier_po_line';
    END IF;

    IF p_supplier_po_line_id IS NOT NULL
    THEN
      g_supplier_po_line_id := p_supplier_po_line_id;
      main_where_clause := main_where_clause||' AND  se.po_line_id = :supplier_po_line_id';
      main_using_clause := main_using_clause||', gmd_outbound_apis_pub.g_supplier_po_line_id';
    END IF;

    IF p_disposition IS NOT NULL
    THEN
      g_disposition := p_disposition;
      main_where_clause := main_where_clause||' AND  se.disposition = :disposition';
      main_using_clause := main_using_clause||', gmd_outbound_apis_pub.g_disposition';

      disp_where_clause := disp_where_clause||' AND  sd.disposition = :disposition';
      disp_using_clause := disp_using_clause||', gmd_outbound_apis_pub.g_disposition';
    END IF;

    IF p_delete_mark IS NOT NULL
    THEN
      g_delete_mark := p_delete_mark;
      disp_where_clause := disp_where_clause||' AND  sd.delete_mark = :delete_mark';
      disp_using_clause := disp_using_clause||', gmd_outbound_apis_pub.g_delete_mark';
    END IF;


    IF p_from_last_update_date IS NOT NULL
    THEN
      gmd_outbound_apis_pub.g_from_last_update_date := p_from_last_update_date;
      main_where_clause := main_where_clause||'AND se.last_update_date >= :from_last_update_date ';
      main_using_clause := main_using_clause||', gmd_outbound_apis_pub.g_from_last_update_date ';

      disp_where_clause := disp_where_clause||'AND sd.last_update_date >= :from_last_update_date ';
      disp_using_clause := disp_using_clause||', gmd_outbound_apis_pub.g_from_last_update_date ';
    END IF;

    IF p_to_last_update_date IS NOT NULL
    THEN
      gmd_outbound_apis_pub.g_to_last_update_date := p_to_last_update_date;
      main_where_clause := main_where_clause||'AND se.last_update_date <= :to_last_update_date ';
      main_using_clause := main_using_clause||', gmd_outbound_apis_pub.g_to_last_update_date ';

      disp_where_clause := disp_where_clause||'AND sd.last_update_date <= :to_last_update_date ';
      disp_using_clause := disp_using_clause||', gmd_outbound_apis_pub.g_to_last_update_date ';
    END IF;

    -- START B3124291 Incorporated Mini-Pack K Features to Outboud APIs
    IF p_sg_organization_id IS NOT NULL
    THEN
      gmd_outbound_apis_pub.g_sg_organization_id := p_sg_organization_id;
      main_where_clause := main_where_clause||'AND se.organization_id = :sg_organization_id ';
      main_using_clause := main_using_clause||', gmd_outbound_apis_pub.g_sg_organization_id ';
    END IF;

    IF p_resources IS NOT NULL
    THEN
      gmd_outbound_apis_pub.g_resources := p_resources;
      main_where_clause := main_where_clause||'AND se.resources = :resources ';
      main_using_clause := main_using_clause||', gmd_outbound_apis_pub.g_resources ';
    END IF;

    IF p_instance_id IS NOT NULL
    THEN
      gmd_outbound_apis_pub.g_instance_id := p_instance_id;
      main_where_clause := main_where_clause||'AND se.instance_id = :instance_id ';
      main_using_clause := main_using_clause||', gmd_outbound_apis_pub.g_instance_id ';
    END IF;

    l_ss_table_included := 'FALSE';
    IF (p_ss_organization_id IS NOT NULL OR p_ss_no IS NOT NULL OR p_ss_id IS NOT NULL) THEN
      main_table_list := main_table_list ||', gmd_stability_studies_b ss, gmd_ss_variants ssv ';
      main_where_clause := main_where_clause ||'AND ss.ss_id = ssv.ss_id AND ssv.variant_id = se.variant_id ';
      l_ss_table_included := 'TRUE';

      IF p_ss_id IS NOT NULL
      THEN
        gmd_outbound_apis_pub.g_ss_id := p_ss_id;
        main_where_clause := main_where_clause||'AND ss.ss_id = :ss_id ';
        main_using_clause := main_using_clause||', gmd_outbound_apis_pub.g_ss_id ';
      END IF;

      IF p_ss_organization_id IS NOT NULL
      THEN
        gmd_outbound_apis_pub.g_ss_organization_id := p_ss_organization_id;
        main_where_clause := main_where_clause||'AND ss.organization_id = :ss_organization_id ';
        main_using_clause := main_using_clause||', gmd_outbound_apis_pub.g_ss_organization_id ';
      END IF;

      IF p_ss_no IS NOT NULL
      THEN
        gmd_outbound_apis_pub.g_ss_no := p_ss_no;
        main_where_clause := main_where_clause||'AND ss.ss_no = :ss_no ';
        main_using_clause := main_using_clause||', gmd_outbound_apis_pub.g_ss_no ';
      END IF;

    END IF;

    IF p_variant_no IS NOT NULL
    THEN
      IF (l_ss_table_included = 'FALSE') THEN
        main_table_list := main_table_list ||', gmd_ss_variants ssv ';
        main_where_clause := main_where_clause ||'AND ssv.variant_id = se.variant_id ';
      END IF;

      gmd_outbound_apis_pub.g_variant_no := p_variant_no;
      main_where_clause := main_where_clause||'AND ssv.variant_no = :variant_no ';
      main_using_clause := main_using_clause||', gmd_outbound_apis_pub.g_variant_no ';
    END IF;

    IF p_variant_id IS NOT NULL
    THEN
      gmd_outbound_apis_pub.g_variant_id := p_variant_id;
      main_where_clause := main_where_clause||'AND se.variant_id = :variant_id ';
      main_using_clause := main_using_clause||', gmd_outbound_apis_pub.g_variant_id ';
    END IF;

    IF p_time_point_id IS NOT NULL
    THEN
      gmd_outbound_apis_pub.g_time_point_id := p_time_point_id;
      main_where_clause := main_where_clause||'AND se.time_point_id = :time_point_id ';
      main_using_clause := main_using_clause||', gmd_outbound_apis_pub.g_time_point_id ';
    END IF;

    -- END B3124291 Incorporated Mini-Pack K Features to Outboud APIs



    sql_statement := 'SELECT system.gmd_sampling_event_rec_type' -- 5284247
                  ||'('||main_column_list
                  ||', CAST'
                  ||'  ( MULTISET'
                  ||'    ( SELECT '  ||disp_column_list
                  ||'        FROM   '||disp_table_list
                  ||'        WHERE  '||disp_where_clause
                  ||'    ) AS system.gmd_event_spec_disps_tab_type' -- 5284242
                  ||'  )'
                  ||')'
                  ||' FROM ' ||main_table_list
                  ||' WHERE '||main_where_clause;

    -- That's more or less the job done. We just need to tell the system where to store the data
    -- and assemble the USING clause. Note thatthe main_using_clause is last in the list as it
    -- appears last in the query.

    main_into_clause := ' BULK COLLECT INTO gmd_outbound_apis_pub.g_sample_groups_table ';
    main_using_clause := ' USING '||disp_using_clause
                       ||','||main_using_clause;

    main_execution_string := 'BEGIN EXECUTE IMMEDIATE '
                       ||''''
                       ||sql_statement
                       ||''''
                       ||main_into_clause
                       ||main_using_clause
                       ||'; END;';

    string_length := LENGTH(main_execution_string);


    EXECUTE IMMEDIATE main_execution_string;

    IF g_sample_groups_table.count > 0
    THEN
      FOR i in 1 .. g_sample_groups_table.count
      LOOP
        IF g_sample_groups_table(i).receipt_line_id IS NOT NULL
        THEN
             -- Bug 3970893: receipt line id is changed from transaction if to shipment line id
             --   select rsl.line_num into g_sample_groups_table(i).receipt_line_number
             --   from rcv_shipment_lines rsl, rcv_transactions rt
             --   where rt.transaction_id = g_sample_groups_table(i).receipt_line_id
          select rsl.line_num into g_sample_groups_table(i).receipt_line_number
          from rcv_shipment_lines rsl
          where rsl.shipment_line_id = g_sample_groups_table(i).receipt_line_id;
        END IF;

        IF g_sample_groups_table(i).supplier_id IS NOT NULL
        THEN
          select segment1 into g_sample_groups_table(i).supplier_name
          from po_vendors
          where vendor_id=g_sample_groups_table(i).supplier_id;
        END IF;

        IF g_sample_groups_table(i).ship_to_site_id IS NOT NULL
        THEN
          select location into g_sample_groups_table(i).ship_to_site_name
          from hz_cust_site_uses_all
          where site_use_id = g_sample_groups_table(i).ship_to_site_id;
        END IF;

        IF g_sample_groups_table(i).supplier_site_id IS NOT NULL
        THEN
          select vendor_site_code into g_sample_groups_table(i).supplier_site_name
          from po_vendor_sites_all
          where vendor_site_id = g_sample_groups_table(i).supplier_site_id;
        END IF;
      END LOOP;
    END IF;

  END IF;

  x_sample_groups_table := g_sample_groups_table;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  FND_MSG_PUB.count_and_get(p_count => x_msg_count, p_data => x_msg_data);

EXCEPTION
  WHEN OTHERS THEN

    FND_MESSAGE.SET_NAME('GMD',SQLCODE);
    FND_MSG_PUB.Add;
    FND_MSG_PUB.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    x_return_status := FND_API.G_RET_STS_ERROR;
END fetch_sample_groups;

end gmd_outbound_apis_pub;

/
