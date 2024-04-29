--------------------------------------------------------
--  DDL for Package Body INV_LOC_WMS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_LOC_WMS_PUB" AS
  /* $Header: INVLOCPB.pls 120.8.12010000.2 2009/05/15 10:44:59 ksivasa ship $*/

 /**
  * Table to pass DFF attributes to create_locator and update_locator apis
  **/
   TYPE char_tbl IS TABLE OF VARCHAR2(1500) INDEX BY BINARY_INTEGER;

  g_pkg_name CONSTANT VARCHAR2(30) := 'INV_LOC_WMS_PUB';

  PROCEDURE DEBUG(p_msg VARCHAR2) IS
     l_version VARCHAR2(240);
  BEGIN
     l_version := g_pkg_name||'$Revision: 120.8.12010000.2 $';

     inv_mobile_helper_functions.tracelog(
        p_err_msg => p_msg,
        p_module => l_version,
        p_level => 4
        );
  END;

   /* Private api to validate the attributes passed to create locator */
PROCEDURE validate_loc_attr_info(
    x_return_status          OUT    NOCOPY VARCHAR2
  , x_msg_count              OUT    NOCOPY NUMBER
  , x_msg_data               OUT    NOCOPY VARCHAR2
  , p_attribute_category     IN     VARCHAR2
  , p_attributes_tbl         IN     char_tbl
  , p_attributes_cnt         IN     NUMBER
) IS
    TYPE seg_name IS TABLE OF VARCHAR2(1000)
      INDEX BY BINARY_INTEGER;

    l_context          VARCHAR2(1000);
    l_context_r        fnd_dflex.context_r;
    l_contexts_dr      fnd_dflex.contexts_dr;
    l_dflex_r          fnd_dflex.dflex_r;
    l_segments_dr      fnd_dflex.segments_dr;
    l_enabled_seg_name seg_name;
    l_wms_all_segs_tbl seg_name;
    l_nsegments        BINARY_INTEGER;
    l_global_context   BINARY_INTEGER;
    v_index            NUMBER                := 1;
    v_index1           NUMBER                := 1;
    l_chk_flag         NUMBER                := 0;
    l_char_count       NUMBER;
    l_num_count        NUMBER;
    l_date_count       NUMBER;
    l_wms_attr_chk     NUMBER                := 1;
    l_return_status    VARCHAR2(1);
    l_msg_count        NUMBER;
    l_msg_data         VARCHAR2(1000);

    /* Variables used for Validate_desccols procedure */
    error_segment      VARCHAR2(30);
    errors_received    EXCEPTION;
    error_msg          VARCHAR2(5000);
    s                  NUMBER;
    e                  NUMBER;
    l_null_char_val    VARCHAR2(1000);
    l_null_num_val     NUMBER;
    l_null_date_val    DATE;
    l_global_nsegments NUMBER := 0;
    col NUMBER;
  BEGIN
    x_return_status  := fnd_api.g_ret_sts_success;
    SAVEPOINT get_lot_attr_information;

    /* Populate the flex field record */

      l_dflex_r.application_id  := 401;
      l_dflex_r.flexfield_name  := 'MTL_ITEM_LOCATIONS';
      /* Get all contexts */
      fnd_dflex.get_contexts(flexfield => l_dflex_r, contexts => l_contexts_dr);


        --DBMS_output.put_line('Found contexts for the Flexfield MTL_LOT_NUMBERS');


      /* From the l_contexts_dr, get the position of the global context */
      l_global_context          := l_contexts_dr.global_context;

      --DBMS_output.put_line('Found the position of the global context  ');


      /* Using the position get the segments in the global context which are enabled */
      l_context                 := l_contexts_dr.context_code(l_global_context);

      /* Prepare the context_r type for getting the segments associated with the global context */
      l_context_r.flexfield     := l_dflex_r;
      l_context_r.context_code  := l_context;
      fnd_dflex.get_segments(CONTEXT => l_context_r, segments => l_segments_dr, enabled_only => TRUE);


        --DBMS_output.put_line('After successfully getting all the enabled segmenst for the Global Context ');


      /* read through the segments */
      l_nsegments               := l_segments_dr.nsegments;
      l_global_nsegments := l_segments_dr.nsegments;

        --DBMS_output.put_line('The number of enabled segments for the Global Context are ' || l_nsegments);

        IF (p_attributes_cnt > l_nsegments) AND
           p_attribute_category IS NULL  THEN
           /* user passed more parameters than needed by global data elements,
            * even though context is passed as null. hence error out
            */
              --DBMS_output.put_line('more params passed than needed');
              fnd_message.set_name('FND', 'FLEX-INVALID CONTEXT');
              fnd_message.set_token('CONTEXT', 'NULL');
              fnd_message.set_token('ROUTINE','INV_LOC_WMS_PUB');
              fnd_msg_pub.ADD;
              RAISE fnd_api.g_exc_error;
        END IF;

      FOR i IN 1 .. l_nsegments LOOP
         l_enabled_seg_name(v_index)  := l_segments_dr.application_column_name(i);
        IF l_segments_dr.is_required(i) THEN
           col := SUBSTR(l_segments_dr.application_column_name(i)
                  , INSTR(l_segments_dr.application_column_name(i), 'ATTRIBUTE') + 9);
           --DBMS_output.put_line('col is ' || col);
         IF ((p_attributes_tbl.EXISTS(col) AND p_attributes_tbl(col) = fnd_api.g_miss_char) OR
            NOT p_attributes_tbl.EXISTS(col))
         THEN
            --DBMS_output.put_line('y r we here');
            fnd_message.set_name('INV', 'INV_REQ_SEG_MISS');
            fnd_message.set_token('SEGMENT', l_segments_dr.segment_name(i));
            fnd_msg_pub.ADD;
            RAISE fnd_api.g_exc_error;
         END IF;
        ELSE
           --DBMS_output.put_line('This segment is not required');
           NULL;
       END IF;

        IF p_attributes_tbl.EXISTS(SUBSTR(l_segments_dr.application_column_name(i)
             , INSTR(l_segments_dr.application_column_name(i), 'ATTRIBUTE') + 9)) THEN
            --DBMS_output.put_line('setting column values');
          fnd_flex_descval.set_column_value(
            l_segments_dr.application_column_name(i)
          , p_attributes_tbl(SUBSTR(l_segments_dr.application_column_name(i)
              , INSTR(l_segments_dr.application_column_name(i), 'ATTRIBUTE') + 9))
          );
        ELSE
          fnd_flex_descval.set_column_value(l_segments_dr.application_column_name(i), l_null_char_val);
        END IF;

        v_index                      := v_index + 1;
      END LOOP;

      IF l_enabled_seg_name.COUNT > 0 THEN
        FOR i IN l_enabled_seg_name.FIRST .. l_enabled_seg_name.LAST LOOP

            --DBMS_output.put_line('The enabled segment : ' || l_enabled_seg_name(i));
            NULL;
        END LOOP;
      END IF;

      /* Initialise the l_context_value to null */
      l_context                 := NULL;
      l_nsegments               := 0;

      /*Get the context for the item passed */
     IF p_attribute_category IS NOT NULL THEN
        l_context                 := p_attribute_category;
        /* Set flex context for validation of the value set */
        fnd_flex_descval.set_context_value(l_context);


          --DBMS_output.put_line('The value of INV context is ' || l_context);


        /* Prepare the context_r type */
        l_context_r.flexfield     := l_dflex_r;
        l_context_r.context_code  := l_context;
        fnd_dflex.get_segments(CONTEXT => l_context_r, segments => l_segments_dr, enabled_only => TRUE);
        /* read through the segments */
        l_nsegments               := l_segments_dr.nsegments;

          --DBMS_output.put_line('No of segments enabled for context ' || l_context || ' are ' || l_nsegments);
          --DBMS_output.put_line('v_index is ' || v_index);



        FOR i IN 1 .. l_nsegments LOOP
          l_enabled_seg_name(v_index)  := l_segments_dr.application_column_name(i);


             --DBMS_output.put_line('The segment is ' || l_segments_dr.segment_name(i));


          IF l_segments_dr.is_required(i) THEN
          col := SUBSTR(l_segments_dr.application_column_name(i)
                  , INSTR(l_segments_dr.application_column_name(i), 'ATTRIBUTE') + 9);
           --DBMS_output.put_line('col is ' || col);
            IF ((p_attributes_tbl.EXISTS(col) AND p_attributes_tbl(col) IS NULL) OR
            NOT p_attributes_tbl.EXISTS(col))
            THEN
              fnd_message.set_name('INV', 'INV_REQ_SEG_MISS');
              fnd_message.set_token('SEGMENT', l_segments_dr.segment_name(i));
              fnd_msg_pub.ADD;
              RAISE fnd_api.g_exc_error;
              --DBMS_output.put_line('Req segment is not populated');
          END IF;
          END IF;

          IF p_attributes_tbl.EXISTS(SUBSTR(l_segments_dr.application_column_name(i)
               , INSTR(l_segments_dr.application_column_name(i), 'ATTRIBUTE') + 9)) THEN
            fnd_flex_descval.set_column_value(
              l_segments_dr.application_column_name(i)
            , p_attributes_tbl(SUBSTR(l_segments_dr.application_column_name(i)
                , INSTR(l_segments_dr.application_column_name(i), 'ATTRIBUTE') + 9))
            );
          ELSE
            fnd_flex_descval.set_column_value(l_segments_dr.application_column_name(i), l_null_char_val);
          END IF;

          v_index                      := v_index + 1;
        END LOOP;

    END IF;
        /*Make a call to  FND_FLEX_DESCVAL.validate_desccols */
    IF (l_global_nsegments > 0 AND p_attribute_Category IS NULL ) THEN
        --DBMS_output.put_line('global segments > 0');
        l_context                 := l_contexts_dr.context_code(l_global_context);
        fnd_flex_descval.set_context_value(l_context);
    end if;
    IF( l_global_nsegments > 0 OR p_attribute_category IS NOT NULL )
    then
       --DBMS_output.put_line('global segments > 0 or attrib cat is not null');
        IF fnd_flex_descval.validate_desccols(appl_short_name => 'INV', desc_flex_name => 'MTL_ITEM_LOCATIONS', values_or_ids => 'I'
           , validation_date              => SYSDATE) THEN

            --DBMS_output.put_line('Value set validation successful');

           NULL;
        ELSE

            error_segment  := fnd_flex_descval.error_segment;
            --DBMS_output.put_line('Value set validation failed for segment ' || error_segment);
            RAISE errors_received;

        END IF;
    END IF;  /*If P attribute category is not null */
    --END IF;   /* p_attribute_category IS NOT NULL */

  EXCEPTION
    WHEN errors_received THEN
      x_return_status  := fnd_api.g_ret_sts_error;
      error_msg        := fnd_flex_descval.error_message;
      s                := 1;
      e                := 200;

      --DBMS_output.put_line('Here are the error messages: ');
      WHILE e < 5001
       AND SUBSTR(error_msg, s, e) IS NOT NULL LOOP
        fnd_message.set_name('INV', 'INV_FND_GENERIC_MSG');
        fnd_message.set_token('MSG', SUBSTR(error_msg, s, e));
        fnd_msg_pub.ADD;
        --DBMS_output.put_line(SUBSTR(error_msg, s, e));
        s  := s + 200;
        e  := e + 200;
      END LOOP;

      ROLLBACK TO get_lot_attr_information;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
    WHEN fnd_api.g_exc_error THEN
      x_return_status  := fnd_api.g_ret_sts_error;
      ROLLBACK TO get_lot_attr_information;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      ROLLBACK TO get_lot_attr_information;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      ROLLBACK TO get_lot_attr_information;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
      --DBMS_output.put_line('Error ' || SQLERRM);
  END validate_loc_attr_info;


  /*
  ** ---------------------------------------------------------------------------
  ** procedure  : create_locator
  ** description  : this procedure creates a new locator in a given organization
  **
  ** i/p    :
  ** p_organization_id
  **  identifier of organization in which locator is to
  **  be created.
  ** p_organization_code
  **  organization code of organziation in which locator
  **  is to be created. Either p_organization_id or
  **  p_organziation_code MUST be passed
  ** p_concatenated_segments
  **  concatenated segment string with separator
  **  of the locator to be created. Eg:A.1.1
  ** p_description
  **  locator description
  ** p_inventory_location_type
  **  type of locator.
  **  dock door(1) or staging lane(2) or storage locator(3)
  ** p_picking_order
  **  number that identifies relative position of locator
  **      for  travel optimization during picking and task dispatching.
  **      It has a a higher precedence over x,y,z coordinates.
  ** p_location_maximum_units
  **  Maxmimum units the locator can hold
  ** p_subinventory_code
  **  Subinventory to which locator belongs
  ** p_location_weight_uom_code
  **  UOM of locator's max weight capacity
  ** p_max_weight
  **  Max weight locator can hold
  ** p_volume_uom_code
  **  UOM of locator's max volume capacity
  ** p_max_cubic_area
  **  Max volume capacity of the locator
  ** p_x_coordinate
  **  X-position of the locator in space. Used
  **      for  travel optimization during picking and task dispatching.
  ** p_y_coordinate
  **  Y-position of the locator in space. Used
  **      for  travel optimization during picking and task dispatching.
  ** p_z_coordinate
  **  Z-position of the locator in space. Used
  **      for  travel optimization during picking and task dispatching.
  ** p_physical_location_id
  **      locators that are the same physically have the same
  **  inventory_location_id in this column
  ** p_pick_uom_code
  **  UOM in which material is picked from locator
  ** p_dimension_uom_code
  **  UOM in which locator dimensions are expressed
  ** p_length
  **  Length of the locator
  ** p_width
  **  Width of the locator
  ** p_height
  **  Height of the locator
  ** p_status_id
  **  Material Status that needs to be associated to locator
  ** p_dropping_order
  **      For ordering drop-off locators and also to order by putaway
  **      drop-off operations (bug 2681871)
  ** p_attribute_category Holds the Context of the Descriptive FlexField for the Locator
  ** p_attribute1 Holds the Descriptive FlexField attribute for the Locator
  ** p_attribute2 Holds the Descriptive FlexField attribute for the Locator
  ** p_attribute3 Holds the Descriptive FlexField attribute for the Locator
  ** p_attribute4 Holds the Descriptive FlexField attribute for the Locator
  ** p_attribute5 Holds the Descriptive FlexField attribute for the Locator
  ** p_attribute6 Holds the Descriptive FlexField attribute for the Locator
  ** p_attribute7 Holds the Descriptive FlexField attribute for the Locator
  ** p_attribute8 Holds the Descriptive FlexField attribute for the Locator
  ** p_attribute9 Holds the Descriptive FlexField attribute for the Locator
  ** p_attribute10 Holds the Descriptive FlexField attribute for the Locator
  ** p_attribute11 Holds the Descriptive FlexField attribute for the Locator
  ** p_attribute12 Holds the Descriptive FlexField attribute for the Locator
  ** p_attribute13 Holds the Descriptive FlexField attribute for the Locator
  ** p_attribute14 Holds the Descriptive FlexField attribute for the Locator
  ** p_attribute15 Holds the Descriptive FlexField attribute for the Locator
  **
  ** o/p:
  ** x_return_status
  **  return status indicating success, error, unexpected error
  ** x_msg_count
  **  number of messages in message list
  ** x_msg_data
  **  if the number of messages in message list is 1, contains
  **      message text
  ** x_inventory_location_id
  **  identifier of newly created locator or existing locator
  ** x_locator_exists
  **  Y - locator exists for given input
  **      N - locator created for given input
  **
  ** ---------------------------------------------------------------------------
  */
  PROCEDURE CREATE_LOCATOR (x_return_status		  OUT NOCOPY VARCHAR2,
			    x_msg_count 		  OUT NOCOPY NUMBER,
			    x_msg_data			  OUT NOCOPY VARCHAR2,
			    x_inventory_location_id 	  OUT NOCOPY NUMBER,
			    x_locator_exists		  OUT NOCOPY VARCHAR2,
			    p_organization_id             IN NUMBER ,
                            p_organization_code           IN VARCHAR2,
			    p_concatenated_segments       IN VARCHAR2,
                            p_description                 IN VARCHAR2,
			    p_inventory_location_type     IN NUMBER ,
                            p_picking_order               IN NUMBER ,
                            p_location_maximum_units      IN NUMBER ,
			    p_SUBINVENTORY_CODE           IN VARCHAR2,
			    p_LOCATION_WEIGHT_UOM_CODE    IN VARCHAR2,
			    p_mAX_WEIGHT                  IN NUMBER,
 			    p_vOLUME_UOM_CODE             IN VARCHAR2,
 			    p_mAX_CUBIC_AREA              IN NUMBER,
			    p_x_COORDINATE                IN NUMBER,
 			    p_Y_COORDINATE                IN NUMBER,
 			    p_Z_COORDINATE                IN NUMBER,
		   	    p_PHYSICAL_LOCATION_ID        IN NUMBER,
 			    p_PICK_UOM_CODE               IN VARCHAR2,
			    p_DIMENSION_UOM_CODE          IN VARCHAR2,
 			    p_LENGTH                      IN NUMBER,
 			    p_WIDTH                       IN NUMBER,
			    p_HEIGHT                      IN NUMBER,
 			    p_STATUS_ID                   IN NUMBER,
			    p_dropping_order              IN NUMBER,
             p_attribute_category          IN VARCHAR2 ,
             p_attribute1               IN VARCHAR2
  , p_attribute2               IN            VARCHAR2
  , p_attribute3               IN            VARCHAR2
  , p_attribute4               IN            VARCHAR2
  , p_attribute5               IN            VARCHAR2
  , p_attribute6               IN            VARCHAR2
  , p_attribute7               IN            VARCHAR2
  , p_attribute8               IN            VARCHAR2
  , p_attribute9               IN            VARCHAR2
  , p_attribute10              IN            VARCHAR2
  , p_attribute11              IN            VARCHAR2
  , p_attribute12              IN            VARCHAR2
  , p_attribute13              IN            VARCHAR2
  , p_attribute14              IN            VARCHAR2
  , p_attribute15              IN            VARCHAR2
  , p_alias                    IN            VARCHAR2
  ) IS
    l_organization_id   NUMBER;
    l_keystat_val       BOOLEAN;
    l_status_id         NUMBER;
    l_validity_check    VARCHAR2(10);
    l_wms_org           BOOLEAN;
    l_loc_type          NUMBER;
    l_return_status     VARCHAR2(10);
    l_msg_count         NUMBER;
    l_msg_data          VARCHAR2(20);
    l_subinventory_code VARCHAR2(10);
    l_chkflg            NUMBER;
    l_val               BOOLEAN;
    cnt                 number;
    -- Material Status Record type declaration
    l_status_rec        inv_material_status_pub.mtl_status_update_rec_type;
    --Table to hold locator DFF Attributes
    l_inv_attributes_tbl char_tbl;
    -- Bug# 4903036: Subinventory type, 1 = Storage, 2 = Receiving
    l_subinventory_type NUMBER;

    l_project_reference_enabled VARCHAR2(1);
    l_project_control_level     NUMBER;
    l_segment20                 VARCHAR2(40);
    l_segment19                 VARCHAR2(40); --Bug 8507747

    l_alias_enabled         VARCHAR2(1);
    l_org_alias_uniqueness  VARCHAR2(1);
    l_sub_alias_uniqueness  VARCHAR2(1);
    l_alias                 VARCHAR2(30);
    l_locator               VARCHAR2(2000);

    l_procedure_name        VARCHAR2(30);
    l_debug                 NUMBER;
    l_progress              VARCHAR2(30);

  BEGIN

    l_procedure_name := 'CREATE_LOCATOR';
    l_debug := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);

    l_validity_check  := 'PASSED';

    SAVEPOINT locator_insert;

    -- Initialize return status to success
    x_return_status   := fnd_api.g_ret_sts_success;

    IF l_debug = 1 THEN
       debug(l_procedure_name);
    END IF;

    l_progress := '$line$';

    /*
     * Validate Organization
     *
     * If organization id passed use it, else use
     * organization code
     */


    IF p_organization_id IS NOT NULL THEN

      l_progress := '$line$';

      l_organization_id  := p_organization_id;

      BEGIN
         SELECT enforce_locator_alis_unq_flag
         INTO   l_org_alias_uniqueness
         FROM   mtl_parameters
         WHERE  organization_id = l_organization_id;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            fnd_message.set_name('INV', 'INV_INT_ORGCODE');
            fnd_msg_pub.ADD;
            RAISE fnd_api.g_exc_error;
      END;

    ELSE -- p_organization_id is NULL

      IF p_organization_code IS NULL THEN

         fnd_message.set_name('INV', 'INV_ORG_REQUIRED');
         fnd_msg_pub.ADD;
         RAISE fnd_api.g_exc_error;

      ELSE -- p_organization_code is NULL

        BEGIN

          SELECT organization_id,
                 enforce_locator_alis_unq_flag
          INTO   l_organization_id,
                 l_org_alias_uniqueness
          FROM   mtl_parameters
          WHERE  organization_code = p_organization_code;

        EXCEPTION
           WHEN NO_DATA_FOUND THEN
              fnd_message.set_name('INV', 'INV_INT_ORGCODE');
              fnd_msg_pub.ADD;
              RAISE fnd_api.g_exc_error;
        END;

      END IF; -- p_organization_code is NULL

    END IF; -- p_organization_id is NULL



    /*
     *  Validate Subinvetory
     *
     *  Check if subinventory  code is null.
     *
     *  If not null, then check subinventory code entered
     *  is valid or not
     */
    IF p_subinventory_code IS NULL THEN

      fnd_message.set_name('INV', 'INV_ENTER_SUBINV');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;

    ELSE -- p_subinventory_code is NULL

      BEGIN
	 -- Bug# 4903036: Also retrieve the subinventory type
	 SELECT secondary_inventory_name,
                enable_locator_alias,
	        enforce_alias_uniqueness,
	        NVL(subinventory_type, 1)
	   INTO l_subinventory_code,
                l_alias_enabled,
	        l_sub_alias_uniqueness,
	        l_subinventory_type
	   FROM mtl_secondary_inventories
	   WHERE secondary_inventory_name = p_subinventory_code
           AND organization_id = l_organization_id;

      EXCEPTION

        WHEN NO_DATA_FOUND THEN
          fnd_message.set_name('INV', 'INVALID_SUB');
          fnd_msg_pub.ADD;
          RAISE fnd_api.g_exc_error;

      END;

    END IF; -- p_subinventory_code is NULL

    -- Bug# 4903036: Check that the sub type and locator type are compatible.
    -- If the sub is of type 'Storage', then the locator cannot be of type 'Receiving'.
    -- If the sub is of type 'Receiving', then the locator cannot be of type 'Storage'.
    IF ((l_subinventory_type = 1 AND NVL(p_inventory_location_type, 3) = 6) OR
        (l_subinventory_type = 1 AND NVL(p_inventory_location_type, 3) = 7) OR -- 4911279
	(l_subinventory_type = 2 AND NVL(p_inventory_location_type, 3) = 3)) THEN
       fnd_message.set_name('INV', 'INV_INVALID_LOCATOR_TYPE');
       fnd_msg_pub.ADD;
       RAISE fnd_api.g_exc_error;
    END IF;

    /*
     *  Valiate Loator alias
     *
     *  If subinventory is Alias enabled then Alias is a required
     *  parameter else it must be NULL
     *
     */
    l_alias := p_alias;

    IF l_alias_enabled = 'Y' AND l_alias IS NULL THEN

       fnd_message.set_name('INV', 'INV_ALIAS_REQUIRED');
       fnd_msg_pub.ADD;
       RAISE fnd_api.g_exc_error;

    END IF;

    IF NVL(l_alias_enabled, 'N') <> 'Y' THEN

       l_alias := NULL;

    END IF;


    IF l_alias_enabled = 'Y'  THEN

       IF l_org_alias_uniqueness = 'Y' THEN

          BEGIN
             SELECT concatenated_segments
             INTO   l_locator
             FROM   mtl_item_locations_kfv
             WHERE  organization_id = p_organization_id
             AND    alias = l_alias
             AND    NVL(physical_location_id,inventory_location_id) = inventory_location_id;

             fnd_message.set_name('INV', 'INV_ALIAS_IN_USE');
             fnd_message.set_token('LOCATOR', l_locator);
             fnd_msg_pub.ADD;
             RAISE fnd_api.g_exc_error;

          EXCEPTION
             WHEN NO_DATA_FOUND THEN
                NULL;
          END;

       ELSE -- l_org_alias_uniqueness

          IF l_sub_alias_uniqueness = 'Y' THEN

             BEGIN

                SELECT concatenated_segments
                INTO   l_locator
                FROM   mtl_item_locations_kfv
                WHERE  organization_id = p_organization_id
                AND    alias = l_alias
                AND    subinventory_code = p_subinventory_code
                AND    NVL(physical_location_id,inventory_location_id) = inventory_location_id;

                fnd_message.set_name('INV', 'INV_ALIAS_IN_USE');
                fnd_message.set_token('LOCATOR', l_locator);
                fnd_msg_pub.ADD;
                RAISE fnd_api.g_exc_error;

             EXCEPTION
                WHEN NO_DATA_FOUND THEN
                   NULL;
             END;

          END IF; -- l_sub_alias_uniqueness

       END IF; -- l_org_alias_uniqueness

    END IF; -- l_alias_enabled


    /*
     * Validating Locator
     */

    IF p_concatenated_segments IS NULL THEN

       fnd_message.set_name('INV', 'INV_INT_LOCSEGCODE');
       fnd_msg_pub.ADD;
       RAISE fnd_api.g_exc_error;

    END IF;

    /*
    BEGIN
            SELECT inventory_location_id
            INTO  x_inventory_location_id
            FROM  mtl_item_locations_kfv
            WHERE  organization_id       = l_organization_id
               AND subinventory_code     = p_subinventory_code
               AND concatenated_segments = p_concatenated_segments
               AND ROWNUM < 2;

               x_locator_exists:= 'Y';
               fnd_message.set_name('INV', 'INV_LOC_DISABLED');
               fnd_msg_pub.add;
               fnd_msg_pub.count_and_get
             ( p_encoded => FND_API.G_FALSE,
         p_count   => x_msg_count,
               p_data    => x_msg_data
               );
               return;
          EXCEPTION
            WHEN no_data_found THEN
     null;
    END;
      */

    BEGIN
      l_val  :=
        fnd_flex_keyval.validate_segs(
          operation                    => 'FIND_COMBINATION'
        , appl_short_name              => 'INV'
        , key_flex_code                => 'MTLL'
        , structure_number             => 101
        , concat_segments              => p_concatenated_segments
        , values_or_ids                => 'V'
        , data_set                     => l_organization_id
        );

      IF l_val = TRUE THEN
        x_locator_exists         := 'Y';
        x_inventory_location_id  := fnd_flex_keyval.combination_id;
        fnd_message.set_name('INV', 'INV_LOC_DISABLED');
        fnd_msg_pub.ADD;
        fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
        RETURN;
      END IF;
    END;

    /*
     * Validate Status id
     */

    IF p_status_id IS NOT NULL THEN
      BEGIN
        SELECT status_id
          INTO l_status_id
          FROM mtl_material_statuses_vl
         WHERE status_id = p_status_id
           AND enabled_flag = 1;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          fnd_message.set_name('WMS', 'WMS_CONT_INVALID_STATUS_ID');
          fnd_msg_pub.ADD;
          RAISE fnd_api.g_exc_error;
      END;
    END IF;

    IF (p_location_weight_uom_code IS NOT NULL) THEN
      BEGIN
        SELECT 1
          INTO l_chkflg
          FROM mtl_units_of_measure
         WHERE uom_code = p_location_weight_uom_code;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          fnd_message.set_name('INV', 'INV_IOI_WEIGHT_UOM_CODE');
          fnd_msg_pub.ADD;
          RAISE fnd_api.g_exc_error;
      END;
    END IF;

    /* Validate Location volume uom code */
     --DBMS_output.put_line('Before validating the volume uom ');

    IF (p_volume_uom_code IS NOT NULL) THEN
      BEGIN
        SELECT 1
          INTO l_chkflg
          FROM mtl_units_of_measure
         WHERE uom_code = p_volume_uom_code;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          fnd_message.set_name('INV', 'INV_IOI_VOLUME_UOM_CODE');
          fnd_msg_pub.ADD;
          RAISE fnd_api.g_exc_error;
      END;
    END IF;

    --DBMS_output.put_line('Before validating the pick uom ');
    IF (p_pick_uom_code IS NOT NULL) THEN
      BEGIN
        SELECT 1
          INTO l_chkflg
          FROM mtl_units_of_measure
         WHERE uom_code = p_pick_uom_code;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          fnd_message.set_name('INV', 'INV_IOI_PICK_UOM_CODE');
          fnd_msg_pub.ADD;
          RAISE fnd_api.g_exc_error;
      END;
    END IF;

    /* Validate Dimension uom code */
     --DBMS_output.put_line('Before validating the dim uom ');

    IF (p_dimension_uom_code IS NOT NULL) THEN
      BEGIN
        SELECT 1
          INTO l_chkflg
          FROM mtl_units_of_measure
         WHERE uom_code = p_dimension_uom_code;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          fnd_message.set_name('INV', 'INV_IOI_DIMENSION_UOM_CODE');
          fnd_msg_pub.ADD;
          RAISE fnd_api.g_exc_error;
      END;
    END IF;

    --DBMS_output.put_line('Before check whether locator exists ');

    ---  check if locator exists in another subinventory
    BEGIN
-- Bug 5856723 Slight performance improvement for checking validity of locator
   /*   SELECT 'FAILED'
        INTO l_validity_check
        FROM DUAL
       WHERE EXISTS(   */

               SELECT subinventory_code
	       INTO l_subinventory_code
                 FROM mtl_item_locations_kfv
                WHERE concatenated_segments = p_concatenated_segments
                  AND p_subinventory_code <> subinventory_code
                  AND organization_id = l_organization_id
		  AND ROWNUM = 1 ;

		--  );
      l_validity_check := 'FAILED' ;
    --DBMS_output.put_line('validity check failed ');

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        --DBMS_output.put_line('In validity check in no data found ');
        NULL;
    END;

    /*  If the value of l_validity_check is PASSED, call FND API to
        create locator
     */
    IF l_validity_check = 'PASSED' THEN
      --DBMS_output.put_line('Org id:' || to_char(l_organization_id));
      --DBMS_output.put_line('Concat :' || p_concatenated_segments);

      l_keystat_val  :=
        fnd_flex_keyval.validate_segs(
          operation                    => 'CREATE_COMB_NO_AT'
        , appl_short_name              => 'INV'
        , key_flex_code                => 'MTLL'
        , structure_number             => 101
        , concat_segments              => p_concatenated_segments
        , values_or_ids                => 'V'
        , data_set                     => l_organization_id
        );

      /* Check the value of l_keystat_val .
               If this returns true,locator has been created successfully.
               If the value is false,creation of locator failed.
      */

      --DBMS_output.put_line('Validity check passed ');
      IF (l_keystat_val = FALSE) THEN
        --DBMS_output.put_line('validate segment failed ');
        fnd_message.set_name('INV', 'INV_LOC_CREATION_FAIL');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_unexpected_error;
      ELSE
        x_inventory_location_id  := fnd_flex_keyval.combination_id;

        IF fnd_flex_keyval.new_combination THEN
          x_locator_exists  := 'N';

          --DBMS_output.put_line('in new combination loop ');

          /* Get default material status if status_id is not passed */
          IF p_status_id IS NOT NULL THEN
            l_status_id  := p_status_id;
          ELSE
            SELECT NVL(default_loc_status_id, 1)
              INTO l_status_id
              FROM mtl_secondary_inventories
             WHERE organization_id = l_organization_id
               AND secondary_inventory_name = p_subinventory_code;
          --DBMS_output.put_line('After selecting the status_id ');
          END IF;

          l_wms_org         :=
            wms_install.check_install(
              x_return_status              => l_return_status
            , x_msg_count                  => l_msg_count
            , x_msg_data                   => l_msg_data
            , p_organization_id            => l_organization_id
            );

          -- Use appropriate locator type

          IF l_return_status = 'S' THEN
         /* Bug 4277516 : Locator type can be same as with WMS orgs for non-WMS orgs too */
--            IF l_wms_org THEN
              l_loc_type  := NVL(p_inventory_location_type, 3);
--            ELSE
--              l_loc_type  := NULL;
--            END IF;
          ELSE
            --DBMS_output.put_line('Wms installed check failed ');
            fnd_message.set_name('WMS', 'WMS_INSTALL_CHK_ERROR');
            fnd_msg_pub.ADD;
            RAISE fnd_api.g_exc_unexpected_error;
          END IF;

          --Bug Number 5606275
          BEGIN

            SELECT project_reference_enabled  ,  project_control_level
            INTO   l_project_reference_enabled,  l_project_control_level
            FROM PJM_ORG_PARAMETERS_V
            WHERE organization_id= l_organization_id;

            --Bug 8520814 Creation of locator should not faile with error Task Required when Project
            --Passed is NULL
            SELECT segment19,segment20
            INTO   l_segment19,l_segment20
            FROM mtl_item_locations
            WHERE organization_id = l_organization_id
            AND inventory_location_id = x_inventory_location_id;

            IF(l_project_reference_enabled = 'Y') THEN
               IF( l_project_control_level =2 AND   l_segment20 IS NULL AND l_segment19 is NOT NULL) THEN

              fnd_message.set_name('INV', 'INV_TASK_NUM_INVALID');
              fnd_msg_pub.ADD;
              RAISE fnd_api.g_exc_error;
              END IF;
            END IF;

          EXCEPTION
           WHEN NO_DATA_FOUND THEN
              NULL;
              --Not a project enabled org so continue normally
           END;

          /* Validate the locator attributes passed by the user */
          cnt:=0;
          IF p_attribute1 IS NOT NULL THEN
             cnt:=cnt+1;
          END IF;
          IF p_attribute2 IS NOT NULL THEN
             cnt:=cnt+1;
          END IF;
          IF p_attribute3 IS NOT NULL THEN
             cnt:=cnt+1;
          END IF;
          IF p_attribute4 IS NOT NULL THEN
             cnt:=cnt+1;
          END IF;
          IF p_attribute5 IS NOT NULL THEN
             cnt:=cnt+1;
          END IF;
          IF p_attribute6 IS NOT NULL THEN
             cnt:=cnt+1;
          END IF;
          IF p_attribute7 IS NOT NULL THEN
             cnt:=cnt+1;
          END IF;
          IF p_attribute8 IS NOT NULL THEN
             cnt:=cnt+1;
          END IF;
          IF p_attribute9 IS NOT NULL THEN
             cnt:=cnt+1;
          END IF;
          IF p_attribute10 IS NOT NULL THEN
             cnt:=cnt+1;
          END IF;
          IF p_attribute11 IS NOT NULL THEN
             cnt:=cnt+1;
          END IF;
          IF p_attribute12 IS NOT NULL THEN
             cnt:=cnt+1;
          END IF;
          IF p_attribute13 IS NOT NULL THEN
             cnt:=cnt+1;
          END IF;
          IF p_attribute14 IS NOT NULL THEN
             cnt:=cnt+1;
          END IF;
          IF p_attribute15 IS NOT NULL THEN
             cnt:=cnt+1;
          END IF;

          --DBMS_output.put_line('no. of attributes passed ' || cnt);
         l_inv_attributes_tbl (1) := p_attribute1;
         l_inv_attributes_tbl (2) := p_attribute2;
         l_inv_attributes_tbl (3) := p_attribute3;
         l_inv_attributes_tbl (4) := p_attribute4;
         l_inv_attributes_tbl (5) := p_attribute5;
         l_inv_attributes_tbl (6) := p_attribute6;
         l_inv_attributes_tbl (7) := p_attribute7;
         l_inv_attributes_tbl (8) := p_attribute8;
         l_inv_attributes_tbl (9) := p_attribute9;
         l_inv_attributes_tbl (10) := p_attribute10;
         l_inv_attributes_tbl (11) := p_attribute11;
         l_inv_attributes_tbl (12) := p_attribute12;
         l_inv_attributes_tbl (13) := p_attribute13;
         l_inv_attributes_tbl (14) := p_attribute14;
         l_inv_attributes_tbl (15) := p_attribute15;

         validate_loc_attr_info(
          x_return_status    => l_return_status
        , x_msg_count        => l_msg_count
        , x_msg_data         => l_msg_data
        , p_attribute_category   => p_attribute_category
        , p_attributes_tbl       => l_inv_attributes_tbl
        , p_attributes_cnt     => cnt
        );

          IF l_return_status = 'E' THEN
             --DBMS_output.put_line('Error from validate_loc_attr_info');
             fnd_message.set_name('INV', 'INV_LOC_CREATION_FAIL');
             fnd_msg_pub.ADD;
             RAISE fnd_api.g_exc_error;
          ELSIF l_return_status = 'U' THEN
             --DBMS_output.put_line('Unexpected Error from validate_loc_attr_info');
             fnd_message.set_name('INV', 'INV_LOC_CREATION_FAIL');
             fnd_msg_pub.ADD;
             RAISE fnd_api.g_exc_unexpected_error;
          END IF;
          /* End locator DFF attributes validation */

          --DBMS_output.put_line('finished calling validate_loc_attr_info');
          --DBMS_output.put_line('updating MIL now ');

          UPDATE mtl_item_locations
             SET subinventory_code = NVL(p_subinventory_code, NULL)
               , status_id = NVL(l_status_id, NULL)
               , inventory_location_type = NVL(l_loc_type, NULL)
               , description = NVL(p_description, NULL)
               , picking_order = NVL(p_picking_order, NULL)
               , location_maximum_units = NVL(p_location_maximum_units, NULL)
               , location_weight_uom_code = NVL(p_location_weight_uom_code, NULL)
               , max_weight = NVL(p_max_weight, NULL)
               , volume_uom_code = NVL(p_volume_uom_code, NULL)
               , max_cubic_area = NVL(p_max_cubic_area, NULL)
               , x_coordinate = NVL(p_x_coordinate, NULL)
               , y_coordinate = NVL(p_y_coordinate, NULL)
               , z_coordinate = NVL(p_z_coordinate, NULL)
               , physical_location_id = NVL(p_physical_location_id, NULL)
               , pick_uom_code = NVL(p_pick_uom_code, NULL)
               , dimension_uom_code = NVL(p_dimension_uom_code, NULL)
               , LENGTH = NVL(p_length, NULL)
               , width = NVL(p_width, NULL)
               , height = NVL(p_height, NULL)
               , dropping_order = NVL(p_dropping_order, NULL)
               , creation_date = SYSDATE
               , created_by = fnd_global.user_id
               , last_updated_by = fnd_global.user_id
               , last_update_date = SYSDATE
               , attribute_category = p_attribute_category
               , attribute1 = p_attribute1
               , attribute2 = p_attribute2
               , attribute3 = p_attribute3
               , attribute4 = p_attribute4
               , attribute5 = p_attribute5
               , attribute6 = p_attribute6
               , attribute7 = p_attribute7
               , attribute8 = p_attribute8
               , attribute9 = p_attribute9
               , attribute10 =p_attribute10
               , attribute11 =p_attribute11
               , attribute12 =p_attribute12
               , attribute13 =p_attribute13
               , attribute14 =p_attribute14
               , attribute15 =p_attribute15
               , alias       = l_alias
             WHERE organization_id = l_organization_id
             AND inventory_location_id = x_inventory_location_id;
        END IF; -- IF FND_FLEX_KEYVAL.new_combination

        IF x_locator_exists = 'N' THEN
          -- Stamp material status history
          --DBMS_output.put_line('locator_exists = N, populating history');
          l_status_rec.organization_id        := l_organization_id;
          l_status_rec.inventory_item_id      := NULL;
          l_status_rec.lot_number             := NULL;
          l_status_rec.serial_number          := NULL;
          l_status_rec.update_method          := inv_material_status_pub.g_update_method_manual;
          l_status_rec.status_id              := l_status_id;
          l_status_rec.zone_code              := p_subinventory_code;
          l_status_rec.locator_id             := x_inventory_location_id;
          l_status_rec.creation_date          := SYSDATE;
          l_status_rec.created_by             := fnd_global.user_id;
          l_status_rec.last_update_date       := SYSDATE;
          l_status_rec.last_update_login      := fnd_global.user_id;
          l_status_rec.initial_status_flag    := 'Y';
          l_status_rec.from_mobile_apps_flag  := 'N';
          inv_material_status_pkg.insert_status_history(l_status_rec);
        END IF;
      END IF; -- (l_keystat_val = FALSE)
    ELSE
      fnd_message.set_name('INV', 'INV_LOC_BELONG_TO_OTH_SUB');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
    END IF; -- (l_validility = passed)

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status  := 'E';
      ROLLBACK TO locator_insert;
      debug(l_procedure_name ||' Expected Error ');
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status  := 'U';
      ROLLBACK TO locator_insert;
      debug(l_procedure_name ||' Unxpected Error ');
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      x_return_status  := 'U';
      --DBMS_output.put_line('In others '||sqlerrm);
      ROLLBACK TO locator_insert;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, l_procedure_name);
      END IF;
      debug(l_procedure_name ||' Others '||SQLERRM);
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
  END create_locator;

  /*
  ** ---------------------------------------------------------------------------
  ** procedure    : update_locator
  ** description  : this procedure updates an existing locator
  **
  ** i/p          :
  ** NOTE:
  **  if the default value of the input parameter is used, then
  **  that column retains its original value and is not changed
  **  during update.
  **      this can be achieved by not passing this parameter during the
  **  API call.
  **
  ** p_organization_id
  **      identifier of organization in which locator is to
  **      be updated.
  ** p_organization_code
  **      organization code of organziation in which locator
  **      is to be updated. Either p_organization_id or
  **      p_organziation_code MUST be passed
  ** p_inventory_location_id
  **  identifier of locator to be updated
  ** p_concatenated_segments
  **      concatenated segment string with separator
  **      of the locator to be updated. Eg:A.1.1
  **  either p_inventory_location_id or p_concatenated_segments
  **  MUST be passed.
  ** p_description
  **      locator description
  ** p_inventory_location_type
  **      type of locator.
  **      dock door(1) or staging lane(2) or storage locator(3)
  ** p_picking_order
  **      number that identifies physical position of locator
  **      for  travel optimization during picking and task dispatching.
  **      It has a a higher precedence over x,y,z coordinates.
  ** p_location_maximum_units
  **      Maxmimum units the locator can hold
  ** p_subinventory_code
  **      Subinventory to which locator belongs
  ** p_location_weight_uom_code
  **      UOM of locator's max weight capacity
  ** p_max_weight
  **      Max weight locator can hold
  ** p_volume_uom_code
  **      UOM of locator's max volume capacity
  ** p_max_cubic_area
  **      Max volume capacity of the locator
  ** p_x_coordinate
  **      X-position of the locator in space. Used
  **      for  travel optimization during picking and task dispatching.
  ** p_y_coordinate
  **      Y-position of the locator in space. Used
  **      for  travel optimization during picking and task dispatching.
  ** p_z_coordinate
  **      Z-position of the locator in space. Used
  **      for  travel optimization during picking and task dispatching.
  ** p_physical_location_id
  **      locators that are the same physically have the same
  **      inventory_location_id in this column
  ** p_pick_uom_code
  **      UOM in which material is picked from locator
  ** p_dimension_uom_code
  **      UOM in which locator dimensions are expressed
  ** p_length
  **      Length of the locator
  ** p_width
  **      Width of the locator
  ** p_height
  **      Height of the locator
  ** p_status_id
  **      Material Status that needs to be associated to locator
  ** p_dropping_order
  **      For ordering drop-off locators and also to order by putaway
  **      drop-off operations (bug 2681871)
  ** For the DFF attributes mentioned below, to update correctly use the following strategy
  **     To retain the value in the table, do not pass any value OR pass NULL as i/p
  **     To update the attribute with NULL, pass fnd_api.g_miss_char
  **     To update with any other value, pass the appropriate value
  ** p_attribute_category Holds the Context of the Descriptive FlexField for the Locator
  ** p_attribute1 Holds the Descriptive FlexField attribute for the Locator
  ** p_attribute2 Holds the Descriptive FlexField attribute for the Locator
  ** p_attribute3 Holds the Descriptive FlexField attribute for the Locator
  ** p_attribute4 Holds the Descriptive FlexField attribute for the Locator
  ** p_attribute5 Holds the Descriptive FlexField attribute for the Locator
  ** p_attribute6 Holds the Descriptive FlexField attribute for the Locator
  ** p_attribute7 Holds the Descriptive FlexField attribute for the Locator
  ** p_attribute8 Holds the Descriptive FlexField attribute for the Locator
  ** p_attribute9 Holds the Descriptive FlexField attribute for the Locator
  ** p_attribute10 Holds the Descriptive FlexField attribute for the Locator
  ** p_attribute11 Holds the Descriptive FlexField attribute for the Locator
  ** p_attribute12 Holds the Descriptive FlexField attribute for the Locator
  ** p_attribute13 Holds the Descriptive FlexField attribute for the Locator
  ** p_attribute14 Holds the Descriptive FlexField attribute for the Locator
  ** p_attribute15 Holds the Descriptive FlexField attribute for the Locator
  **
  ** o/p:
  ** x_return_status
  **      return status indicating success, error, unexpected error
  ** x_msg_count
  **      number of messages in message list
  ** x_msg_data
  **      if the number of messages in message list is 1, contains
  **      message text
  **
  ** ---------------------------------------------------------------------------
  */
  PROCEDURE UPDATE_LOCATOR (x_return_status               OUT NOCOPY VARCHAR2,
		    	  x_msg_count 		        OUT NOCOPY NUMBER,
			  x_msg_data			OUT NOCOPY VARCHAR2,
		          p_organization_id             IN NUMBER ,
                          p_organization_code 	        IN VARCHAR2,
                          p_inventory_location_id 	IN NUMBER,
                          p_concatenated_segments 	IN VARCHAR2,
                          p_description 		IN VARCHAR2 ,
                          p_disabled_date 		IN DATE ,
                          p_inventory_location_type 	IN NUMBER ,
                          p_picking_order 		IN NUMBER ,
                          p_location_maximum_units 	IN NUMBER ,
                          p_location_Weight_uom_code    IN VARCHAR2 ,
                          p_max_weight 		        IN NUMBER ,
                          p_volume_uom_code 		IN VARCHAR2 ,
                          p_max_cubic_area 		IN NUMBER ,
                          p_x_coordinate 		IN NUMBER ,
                          p_y_coordinate		IN NUMBER ,
                          p_z_coordinate 		IN NUMBER ,
                          p_physical_location_id 	IN NUMBER ,
                          p_pick_uom_code 		IN VARCHAR2 ,
                          p_dimension_uom_code 	        IN VARCHAR2 ,
                          p_length 			IN NUMBER ,
                          p_width 			IN NUMBER ,
                          p_height 			IN NUMBER ,
                          p_status_id 		        IN NUMBER ,
			                 p_dropping_order        IN NUMBER ,
                          p_attribute_category    IN VARCHAR2 ,
                          p_attribute1               IN   VARCHAR2
  , p_attribute2               IN            VARCHAR2
  , p_attribute3               IN            VARCHAR2
  , p_attribute4               IN            VARCHAR2
  , p_attribute5               IN            VARCHAR2
  , p_attribute6               IN            VARCHAR2
  , p_attribute7               IN            VARCHAR2
  , p_attribute8               IN            VARCHAR2
  , p_attribute9               IN            VARCHAR2
  , p_attribute10              IN            VARCHAR2
  , p_attribute11              IN            VARCHAR2
  , p_attribute12              IN            VARCHAR2
  , p_attribute13              IN            VARCHAR2
  , p_attribute14              IN            VARCHAR2
  , p_attribute15              IN            VARCHAR2
  , p_alias                    IN            VARCHAR2
  ) AS
    l_organization_id       NUMBER;
    l_inventory_location_id NUMBER;

    l_status_id             NUMBER;
    l_wms_org               BOOLEAN;
    l_msg_count             NUMBER;
    l_msg_data              VARCHAR2(20);
    l_chk_sub               VARCHAR2(20);
    l_chkflg                NUMBER;
    l_val                   BOOLEAN;
    L_RETURN_STATUS         VARCHAR2(1);
    -- Material Status Record type declaration
    l_status_rec            inv_material_status_pub.mtl_status_update_rec_type;
    --Table to hold locator DFF Attributes
    l_inv_attributes_tbl char_tbl;
    cnt                     number;
    -- Bug# 4903036: Subinventory type, 1 = Storage, 2 = Receiving
    l_subinventory_type     NUMBER;

    l_alias_enabled         VARCHAR2(1);
    l_org_alias_uniqueness  VARCHAR2(1);
    l_sub_alias_uniqueness  VARCHAR2(1);
    l_alias                 VARCHAR2(30);
    l_locator               VARCHAR2(2000);
    l_subinventory_code     VARCHAR2(10);

    l_procedure_name        VARCHAR2(30);
    l_debug                 NUMBER;


  BEGIN
    --  Declare a save point

    SAVEPOINT locator_update;
    --  Default the status to success

    l_procedure_name := 'UPDATE_LOCATOR';
    l_debug := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);


    x_return_status  := fnd_api.g_ret_sts_success;

    IF l_debug = 1 THEN
       debug(l_procedure_name);
    END IF;

    /*
     * Validate Organization
     */

    IF p_organization_id IS NOT NULL THEN

      l_organization_id  := p_organization_id;

      BEGIN
         SELECT enforce_locator_alis_unq_flag
         INTO   l_org_alias_uniqueness
         FROM   mtl_parameters
         WHERE  organization_id = l_organization_id;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            fnd_message.set_name('INV', 'INV_INT_ORGCODE');
            fnd_msg_pub.ADD;
            RAISE fnd_api.g_exc_error;
      END;

    ELSE -- p_organization_id IS NULL

      IF p_organization_code IS NULL THEN

        fnd_message.set_name('INV', 'INV_ORG_REQUIRED');
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_error;

      ELSE -- p_organization_code is NULL

        BEGIN
           SELECT organization_id,
                  enforce_locator_alis_unq_flag
           INTO   l_organization_id,
                  l_org_alias_uniqueness
           FROM   mtl_parameters
           WHERE  organization_code = p_organization_code;
        EXCEPTION
           WHEN NO_DATA_FOUND THEN
              fnd_message.set_name('INV', 'INV_INT_ORGCODE');
              fnd_msg_pub.ADD;
              RAISE fnd_api.g_exc_error;
        END;

      END IF; -- p_organization_code is NULL

    END IF; -- p_organization_id IS NULL


    /*
     *  Validate locator
     */

    IF (p_concatenated_segments IS NULL AND p_inventory_location_id IS NULL) THEN

      fnd_message.set_name('INV', 'INV_INT_LOCSEGCODE');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;

    ELSIF p_concatenated_segments IS NOT NULL AND p_inventory_location_id IS NULL THEN

      /*  BEGIN
          SELECT inventory_location_id
          INTO l_inventory_location_id
          FROM MTL_ITEM_LOCATIONS_KFV
          WHERE concatenated_segments = p_concatenated_segments
            and organization_id = l_organization_id;
        END;
             */
      BEGIN
        l_val  :=
          fnd_flex_keyval.validate_segs(
            operation                    => 'FIND_COMBINATION'
          , appl_short_name              => 'INV'
          , key_flex_code                => 'MTLL'
          , structure_number             => 101
          , concat_segments              => p_concatenated_segments
          , values_or_ids                => 'V'
          , data_set                     => l_organization_id
          );

        IF l_val = FALSE THEN
          fnd_message.set_name('INV', 'INV_INT_LOCSEGCODE');
          fnd_msg_pub.ADD;
          RAISE fnd_api.g_exc_error;
        ELSE
          l_inventory_location_id  := fnd_flex_keyval.combination_id;
        END IF;

      END;

    ELSE -- p_concatenated_segments

      l_inventory_location_id  := p_inventory_location_id;

    END IF; -- p_concatenated_segments


    /*
     *  Validate Inventory_Location_Type
     */

    IF (p_inventory_location_type <> fnd_api.g_miss_num AND
        p_inventory_location_type NOT IN(1, 2, 3, 4, 5, 6, 7)) THEN

      fnd_message.set_name('INV', 'INV_INVALID_LOCATOR_TYPE');
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;

    END IF;

    -- Bug# 4903036: Check that the sub type and locator type are compatible.
    -- Do this check only if the inventory location type is being updated for the locator.
    IF (p_inventory_location_type <> fnd_api.g_miss_num) THEN
       -- Retrieve the subinventory type for the sub that the locator is in.
       BEGIN
	  SELECT NVL(msi.subinventory_type, 1)
	    INTO l_subinventory_type
	    FROM mtl_item_locations mil, mtl_secondary_inventories msi
	    WHERE mil.inventory_location_id = l_inventory_location_id
	    AND mil.organization_id = l_organization_id
	    AND mil.subinventory_code = msi.secondary_inventory_name
	    AND msi.organization_id = l_organization_id;
       EXCEPTION
	  WHEN NO_DATA_FOUND THEN
	     fnd_message.set_name('INV', 'INVALID_SUB');
	     fnd_msg_pub.ADD;
	     RAISE fnd_api.g_exc_error;
       END;

       -- If the sub is of type 'Storage', then the locator cannot be of type 'Receiving'.
       -- If the sub is of type 'Receiving', then the locator cannot be of type 'Storage'.
       IF ((l_subinventory_type = 1 AND NVL(p_inventory_location_type, 3) = 6) OR
           (l_subinventory_type = 1 AND NVL(p_inventory_location_type, 3) = 7) OR --4911279
	   (l_subinventory_type = 2 AND NVL(p_inventory_location_type, 3) = 3)) THEN
	  fnd_message.set_name('INV', 'INV_INVALID_LOCATOR_TYPE');
	  fnd_msg_pub.ADD;
	  RAISE fnd_api.g_exc_error;
       END IF;
    END IF;


    /*
     * Get the Locator status
     */

    BEGIN

      SELECT status_id,
             subinventory_code
      INTO   l_status_id,
             l_subinventory_code
      FROM   mtl_item_locations
      WHERE  inventory_location_id = l_inventory_location_id
      AND    organization_id = l_organization_id;

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        NULL;
    END;

    SELECT enable_locator_alias,
           enforce_alias_uniqueness
    INTO   l_alias_enabled,
           l_sub_alias_uniqueness
    FROM   mtl_secondary_inventories
    WHERE  secondary_inventory_name = l_subinventory_code
    AND    organization_id = l_organization_id;

    /*
     * Validate locator Alias
     */
     l_alias := p_alias;

    IF l_alias_enabled = 'Y' AND l_alias IS NULL THEN

       fnd_message.set_name('INV', 'INV_ALIAS_REQUIRED');
       fnd_msg_pub.ADD;
       RAISE fnd_api.g_exc_error;

    END IF;

    IF NVL(l_alias_enabled, 'N') <> 'Y' THEN
       l_alias := NULL;
    END IF;

    IF l_alias_enabled = 'Y'  THEN

       IF l_org_alias_uniqueness = 'Y' THEN

          BEGIN
             SELECT concatenated_segments
             INTO   l_locator
             FROM   mtl_item_locations_kfv
             WHERE  organization_id = p_organization_id
             AND    alias = l_alias
             AND    NVL(physical_location_id,inventory_location_id) = inventory_location_id;

             fnd_message.set_name('INV', 'INV_ALIAS_IN_USE');
             fnd_message.set_token('LOCATOR', l_locator);
             fnd_msg_pub.ADD;
             RAISE fnd_api.g_exc_error;

          EXCEPTION
             WHEN NO_DATA_FOUND THEN
                NULL;
          END;

       ELSE -- l_org_alias_uniqueness

          IF l_sub_alias_uniqueness = 'Y' THEN

             BEGIN
                SELECT concatenated_segments
                INTO   l_locator
                FROM   mtl_item_locations_kfv
                WHERE  organization_id = p_organization_id
                AND    alias = l_alias
                AND    subinventory_code = l_subinventory_code
                AND    NVL(physical_location_id,inventory_location_id) = inventory_location_id;

                fnd_message.set_name('INV', 'INV_ALIAS_IN_USE');
                fnd_message.set_token('LOCATOR', l_locator);
                fnd_msg_pub.ADD;
                RAISE fnd_api.g_exc_error;

             EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  NULL;
             END;

          END IF; -- l_sub_alias_uniqueness

       END IF; -- l_org_alias_uniqueness

    END IF; -- l_alias_enabled


    /* Validate Location weight uom code */

    --DBMS_output.put_line('Before validating the weight uom ');
    IF (p_location_weight_uom_code <> fnd_api.g_miss_char
        AND p_location_weight_uom_code IS NOT NULL) THEN
      BEGIN
        SELECT 1
          INTO l_chkflg
          FROM mtl_units_of_measure
         WHERE uom_code = p_location_weight_uom_code;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          fnd_message.set_name('INV', 'INV_IOI_WEIGHT_UOM_CODE');
          fnd_msg_pub.ADD;
          RAISE fnd_api.g_exc_error;
      END;
    END IF;

    /* Validate Location volume uom code */
    --DBMS_output.put_line('Before validating the volume uom ');

    IF (p_volume_uom_code <> fnd_api.g_miss_char
        AND p_volume_uom_code IS NOT NULL) THEN
      BEGIN
        SELECT 1
          INTO l_chkflg
          FROM mtl_units_of_measure
         WHERE uom_code = p_volume_uom_code;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          fnd_message.set_name('INV', 'INV_IOI_WEIGHT_UOM_CODE');
          fnd_msg_pub.ADD;
          RAISE fnd_api.g_exc_error;
      END;
    END IF;

    /*  Validate Location Pick uom code */
    --DBMS_output.put_line('Before validating the pick uom ');
    IF (p_pick_uom_code <> fnd_api.g_miss_char
        AND p_pick_uom_code IS NOT NULL) THEN
      BEGIN
        SELECT 1
          INTO l_chkflg
          FROM mtl_units_of_measure
         WHERE uom_code = p_pick_uom_code;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          fnd_message.set_name('INV', 'INV_IOI_PICK_UOM_CODE ');
          fnd_msg_pub.ADD;
          RAISE fnd_api.g_exc_error;
      END;
    END IF;

    /* Validate Dimension uom code */
    --DBMS_output.put_line('Before validating the dim uom ');

    IF (p_dimension_uom_code <> fnd_api.g_miss_char
        AND p_dimension_uom_code IS NOT NULL) THEN
      BEGIN
        SELECT 1
          INTO l_chkflg
          FROM mtl_units_of_measure
         WHERE uom_code = p_dimension_uom_code;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          fnd_message.set_name('INV', 'INV_IOI_DIMENSION_UOM_CODE');
          fnd_msg_pub.ADD;
          RAISE fnd_api.g_exc_error;
      END;
    END IF;

    /* Validate Status code */
     -- --DBMS_output.put_line('Before validating the status  ');
    IF (p_status_id <> fnd_api.g_miss_num
        AND p_status_id IS NOT NULL) THEN
      BEGIN
        SELECT 1
          INTO l_chkflg
          FROM mtl_material_statuses_vl
         WHERE status_id = p_status_id
           AND enabled_flag = 1;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          fnd_message.set_name('WMS', 'WMS_CONT_INVALID_STATUS_ID');
          fnd_msg_pub.ADD;
          RAISE fnd_api.g_exc_error;
      END;
    END IF;
 --DBMS_output.put_line('setting attribs');
          /* Validate the locator attributes passed by the user */
          cnt:=0;
          IF p_attribute1 IS NOT NULL THEN
             cnt:=cnt+1;
          END IF;
          IF p_attribute2 IS NOT NULL THEN
             cnt:=cnt+1;
          END IF;
          IF p_attribute3 IS NOT NULL THEN
             cnt:=cnt+1;
          END IF;
          IF p_attribute4 IS NOT NULL THEN
             cnt:=cnt+1;
          END IF;
          IF p_attribute5 IS NOT NULL THEN
             cnt:=cnt+1;
          END IF;
          IF p_attribute6 IS NOT NULL THEN
             cnt:=cnt+1;
          END IF;
          IF p_attribute7 IS NOT NULL THEN
             cnt:=cnt+1;
          END IF;
          IF p_attribute8 IS NOT NULL THEN
             cnt:=cnt+1;
          END IF;
          IF p_attribute9 IS NOT NULL THEN
             cnt:=cnt+1;
          END IF;
          IF p_attribute10 IS NOT NULL THEN
             cnt:=cnt+1;
          END IF;
          IF p_attribute11 IS NOT NULL THEN
             cnt:=cnt+1;
          END IF;
          IF p_attribute12 IS NOT NULL THEN
             cnt:=cnt+1;
          END IF;
          IF p_attribute13 IS NOT NULL THEN
             cnt:=cnt+1;
          END IF;
          IF p_attribute14 IS NOT NULL THEN
             cnt:=cnt+1;
          END IF;
          IF p_attribute15 IS NOT NULL THEN
             cnt:=cnt+1;
          END IF;

          IF p_attribute1 = fnd_api.g_miss_char THEN
                l_inv_attributes_tbl (1) := NULL;
          ELSE
                l_inv_attributes_tbl (1) := p_attribute1;
          END IF;
          IF p_attribute2 = fnd_api.g_miss_char THEN
                l_inv_attributes_tbl (2) := NULL;
          ELSE
                l_inv_attributes_tbl (2) := p_attribute2;
          END IF;

          IF p_attribute3 = fnd_api.g_miss_char THEN
                l_inv_attributes_tbl (3) := NULL;
          ELSE
                l_inv_attributes_tbl (3) := p_attribute3;
          END IF;

          IF p_attribute4 = fnd_api.g_miss_char THEN
                l_inv_attributes_tbl (4) := NULL;
          ELSE
                l_inv_attributes_tbl (4) := p_attribute4;
          END IF;

          IF p_attribute5 = fnd_api.g_miss_char THEN
                l_inv_attributes_tbl (5) := NULL;
          ELSE
                l_inv_attributes_tbl (5) := p_attribute5;
          END IF;

          IF p_attribute6 = fnd_api.g_miss_char THEN
                l_inv_attributes_tbl (6) := NULL;
          ELSE
                l_inv_attributes_tbl (6) := p_attribute6;
          END IF;
          IF p_attribute7 = fnd_api.g_miss_char THEN
                l_inv_attributes_tbl (7) := NULL;
          ELSE
                l_inv_attributes_tbl (7) := p_attribute7;
          END IF;
          IF p_attribute8 = fnd_api.g_miss_char THEN
               l_inv_attributes_tbl (8) := NULL;
          ELSE
               l_inv_attributes_tbl (8) := p_attribute8;
          END IF;

          IF p_attribute9 = fnd_api.g_miss_char THEN
               l_inv_attributes_tbl (9) := NULL;
          ELSE
               l_inv_attributes_tbl (9) := p_attribute9;
          END IF;
          IF p_attribute10 = fnd_api.g_miss_char THEN
               l_inv_attributes_tbl (10) := NULL;
          ELSE
               l_inv_attributes_tbl (10) := p_attribute10;
          END IF;
          IF p_attribute11 = fnd_api.g_miss_char THEN
                l_inv_attributes_tbl (11) := NULL;
          ELSE
                l_inv_attributes_tbl (11) := p_attribute11;
          END IF;
          IF p_attribute12 = fnd_api.g_miss_char THEN
                l_inv_attributes_tbl (12) := NULL;
          ELSE
                l_inv_attributes_tbl (12) := p_attribute12;
          END IF;

          IF p_attribute13 = fnd_api.g_miss_char THEN
                l_inv_attributes_tbl (13) := NULL;
          ELSE
                l_inv_attributes_tbl (13) := p_attribute13;
          END IF;

          IF p_attribute14 = fnd_api.g_miss_char THEN
                l_inv_attributes_tbl (14) := NULL;
          ELSE
                l_inv_attributes_tbl (14) := p_attribute14;
          END IF;

          IF p_attribute15 = fnd_api.g_miss_char THEN
                l_inv_attributes_tbl (15) := NULL;
          ELSE
                l_inv_attributes_tbl (15) := p_attribute15;
          END IF;

          --DBMS_output.put_line('calling validate');
         validate_loc_attr_info(
          x_return_status    => l_return_status
        , x_msg_count        => l_msg_count
        , x_msg_data         => l_msg_data
        , p_attribute_category   => p_attribute_category
        , p_attributes_tbl       => l_inv_attributes_tbl
        , p_attributes_cnt     => cnt
        );

          IF l_return_status = 'E' THEN
             --DBMS_output.put_line('Error from validate_loc_attr_info');
             fnd_message.set_name('INV', 'INV_LOC_CREATION_FAIL');
             fnd_msg_pub.ADD;
             RAISE fnd_api.g_exc_error;
          ELSIF l_return_status = 'U' THEN
             --DBMS_output.put_line('Unexpected Error from validate_loc_attr_info');
             fnd_message.set_name('INV', 'INV_LOC_CREATION_FAIL');
             fnd_msg_pub.ADD;
             RAISE fnd_api.g_exc_unexpected_error;
          END IF;
          /* End locator DFF attributes validation */

    /* When the control is at this point, data supplied are valid.
      We will update the MTL_ITEM_LOCATIONS
          table with the information provided
    */

    --DBMS_output.put_line('Before update ');

    UPDATE mtl_item_locations
       SET description = DECODE(p_description, fnd_api.g_miss_char, description, p_description)
         , disable_date = DECODE(p_disabled_date, fnd_api.g_miss_date, disable_date, p_disabled_date)
         , inventory_location_type =
                                   DECODE(
                                     p_inventory_location_type
                                   , fnd_api.g_miss_num, inventory_location_type
                                   , p_inventory_location_type
                                   )
         , picking_order = DECODE(p_picking_order, fnd_api.g_miss_num, picking_order, p_picking_order)
         , location_maximum_units = DECODE(p_location_maximum_units, fnd_api.g_miss_num, location_maximum_units, p_location_maximum_units)
         , location_weight_uom_code =
                               DECODE(
                                 p_location_weight_uom_code
                               , fnd_api.g_miss_char, location_weight_uom_code
                               , p_location_weight_uom_code
                               )
         , max_weight = DECODE(p_max_weight, fnd_api.g_miss_num, max_weight, p_max_weight)
         , volume_uom_code = DECODE(p_volume_uom_code, fnd_api.g_miss_char, volume_uom_code, p_volume_uom_code)
         , max_cubic_area = DECODE(p_max_cubic_area, fnd_api.g_miss_num, max_cubic_area, p_max_cubic_area)
         , x_coordinate = DECODE(p_x_coordinate, fnd_api.g_miss_num, x_coordinate, p_x_coordinate)
         , y_coordinate = DECODE(p_y_coordinate, fnd_api.g_miss_num, y_coordinate, p_y_coordinate)
         , z_coordinate = DECODE(p_z_coordinate, fnd_api.g_miss_num, z_coordinate, p_z_coordinate)
         , pick_uom_code = DECODE(p_pick_uom_code, fnd_api.g_miss_char, pick_uom_code, p_pick_uom_code)
         , dimension_uom_code = DECODE(p_dimension_uom_code, fnd_api.g_miss_char, dimension_uom_code, p_dimension_uom_code)
         , LENGTH = DECODE(p_length, fnd_api.g_miss_num, LENGTH, p_length)
         , width = DECODE(p_width, fnd_api.g_miss_num, width, p_width)
         , height = DECODE(p_height, fnd_api.g_miss_num, height, p_height)
         , status_id = DECODE(p_status_id, fnd_api.g_miss_num, status_id, p_status_id)
         , dropping_order = DECODE(p_dropping_order, fnd_api.g_miss_num, dropping_order, p_dropping_order)
         , last_updated_by = fnd_global.user_id
         , last_update_date = SYSDATE
         , attribute_category = decode(p_attribute_category, NULL, attribute_category, fnd_api.g_miss_char, NULL, p_attribute_category)
         , attribute1 = decode(p_attribute1, NULL, attribute1, fnd_api.g_miss_char, NULL, p_attribute1)
         , attribute2 = decode(p_attribute2, NULL, attribute2, fnd_api.g_miss_char, NULL, p_attribute2)
         , attribute3 = decode(p_attribute3, NULL, attribute3, fnd_api.g_miss_char, NULL, p_attribute3)
         , attribute4 = decode(p_attribute4, NULL, attribute4, fnd_api.g_miss_char, NULL, p_attribute4)
         , attribute5 = decode(p_attribute5, NULL, attribute5, fnd_api.g_miss_char, NULL, p_attribute5)
         , attribute6 = decode(p_attribute6, NULL, attribute6, fnd_api.g_miss_char, NULL, p_attribute6)
         , attribute7 = decode(p_attribute7, NULL, attribute7, fnd_api.g_miss_char, NULL, p_attribute7)
         , attribute8 = decode(p_attribute8, NULL, attribute8, fnd_api.g_miss_char, NULL, p_attribute8)
         , attribute9 = decode(p_attribute9, NULL, attribute9, fnd_api.g_miss_char, NULL, p_attribute9)
         , attribute10 = decode(p_attribute10, NULL, attribute10, fnd_api.g_miss_char, NULL, p_attribute10)
         , attribute11 = decode(p_attribute11, NULL, attribute11, fnd_api.g_miss_char, NULL, p_attribute11)
         , attribute12 = decode(p_attribute12, NULL, attribute12, fnd_api.g_miss_char, NULL, p_attribute12)
         , attribute13 = decode(p_attribute13, NULL, attribute13, fnd_api.g_miss_char, NULL, p_attribute13)
         , attribute14 = decode(p_attribute14, NULL, attribute14, fnd_api.g_miss_char, NULL, p_attribute14)
         , attribute15 = decode(p_attribute15, NULL, attribute15, fnd_api.g_miss_char, NULL, p_attribute15)
         , alias = l_alias
         WHERE inventory_location_id = l_inventory_location_id
       AND organization_id = l_organization_id;

    /* If the p_status_id  is not null then,stamp the new status in the status history table  */
    IF (p_status_id IS NOT NULL
        AND p_status_id <> fnd_api.g_miss_num
        AND p_status_id <> l_status_id) THEN

      l_status_rec.organization_id        := l_organization_id;
      l_status_rec.inventory_item_id      := NULL;
      l_status_rec.lot_number             := NULL;
      l_status_rec.serial_number          := NULL;
      l_status_rec.update_method          := inv_material_status_pub.g_update_method_manual;
      l_status_rec.status_id              := p_status_id;
      l_status_rec.zone_code              := l_subinventory_code;
      l_status_rec.locator_id             := l_inventory_location_id;
      l_status_rec.creation_date          := SYSDATE;
      l_status_rec.created_by             := fnd_global.user_id;
      l_status_rec.last_update_date       := SYSDATE;
      l_status_rec.last_update_login      := fnd_global.user_id;
      l_status_rec.initial_status_flag    := 'N';
      l_status_rec.from_mobile_apps_flag  := 'N';
      --DBMS_output.put_line('Before updating staTUS');
      inv_material_status_pkg.insert_status_history(l_status_rec);
    END IF;
  --DBMS_output.put_line('End of procedure ');
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status  := 'E';
      ROLLBACK TO locator_update;
      debug(l_procedure_name ||' Expected Error ');
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status  := 'U';
      ROLLBACK TO locator_update;
      debug(l_procedure_name ||'Unexpected Error ');
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      x_return_status  := 'U';
      ROLLBACK TO locator_update;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, l_procedure_name);
      END IF;
      debug(l_procedure_name ||' Others '||SQLERRM);
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
  END update_locator;

  /*
  ** ---------------------------------------------------------------------------
  ** procedure    : create_loc_item_tie
  ** description  : For a given set of organization, subinventory, item and
  **                locator, this API ties the given item to the given locator.
  ** i/p          :

  ** p_inventory_item_id
  **    Identifier of item .
  ** p_item
  **     Concatenated segment string with separator of the item.
  **     Either P_inventory_item_id or the p_item MUST be passed
  ** p_organization_id
  **     Identifier of organization
  ** p_organization_code
  **     Organization code of organziation in which locator is to
  **     be updated. Either p_organization_id  or p_organziation_code
  **     MUST be passed
  ** p_subinventory_code
  **     The subinventory to which the locator need to be attached to .
  ** p_inventory_location_id
  **     Identifier of locator to be attached to the specified subinventory
  ** p_locator
  **     Concatenated segment string with separator of the locator to be
  **     updated. Eg:A.1.1 either p_inventory_location_id or
  **     p_concatenated_segments MUST be passed.
  ** p_status_id
  **     Identifier of status
  ** p_par_level
  **     PAR level for the item-locator. Valid only when the subinventory is PAR planned.
  **
  ** o/p:
  **
  ** x_return_status
  **      return status indicating success, error, unexpected error
  ** x_msg_count
  **      number of messages in message list
  ** x_msg_data
  **      if the number of messages in message list is 1, contains
  **      message text
  **
  ** ---------------------------------------------------------------------------
  */
  PROCEDURE create_loc_item_tie(
    x_return_status         OUT NOCOPY    VARCHAR2
  , x_msg_count             OUT NOCOPY    NUMBER
  , x_msg_data              OUT NOCOPY    VARCHAR2
  , p_inventory_item_id     IN            NUMBER
  , p_item                  IN            VARCHAR2
  , p_organization_id       IN            NUMBER
  , p_organization_code     IN            VARCHAR2
  , p_subinventory_code     IN            VARCHAR2
  , p_inventory_location_id IN            NUMBER
  , p_locator               IN            VARCHAR2
  , p_status_id             IN            NUMBER
  , p_par_level             IN            NUMBER DEFAULT NULL
  ) AS
    l_inventory_item_id NUMBER;
    l_organization_id   NUMBER;
    l_locator_id        NUMBER;
    l_locator_exists    VARCHAR2(1);
    l_subflag           VARCHAR2(10);
    l_status_chk        NUMBER;
    l_chkflg            VARCHAR2(10);
    l_item_sub          NUMBER;
    l_planning_level    NUMBER;
  BEGIN
    -- declare a savepoint

    SAVEPOINT location_item_restrict;
    x_return_status  := fnd_api.g_ret_sts_success;

    /* If organization id passed use it, else use organization code */
    IF p_organization_id IS NOT NULL THEN
      l_organization_id  := p_organization_id;
    ELSE
      IF p_organization_code IS NULL THEN
        fnd_message.set_name('INV', 'INV_ORG_REQUIRED');
        /* Organization is required */
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_error;
      ELSE
        BEGIN
          SELECT organization_id
            INTO l_organization_id
            FROM mtl_parameters
           WHERE organization_code = p_organization_code;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            fnd_message.set_name('INV', 'INV_INT_ORGCODE');
            /* The Organization Code provided is invalid */
            fnd_msg_pub.ADD;
            RAISE fnd_api.g_exc_error;
        END;
      END IF;
    END IF;

    /*  Validate item concatenated segment  */
    IF p_inventory_item_id IS NOT NULL THEN
      l_inventory_item_id  := p_inventory_item_id;
    ELSE
      IF p_item IS NULL THEN
        fnd_message.set_name('INV', 'INV_INT_ITMSEGCODE');
        /* Invalid item segments */
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_error;
      ELSE
        BEGIN
          SELECT inventory_item_id
            INTO l_inventory_item_id
            FROM mtl_system_items_kfv
           WHERE concatenated_segments = p_item
             AND organization_id = l_organization_id;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            fnd_message.set_name('INV', 'INV_INT_ITMCODE');
            /* The Item provided is invalid */
            fnd_msg_pub.ADD;
            RAISE fnd_api.g_exc_error;
        END;
      END IF;
    END IF;

    /*Validate the subinventory code */
    IF p_subinventory_code IS NULL THEN
      fnd_message.set_name('INV', 'INV_ENTER_SUBINV');
      /* Please enter a subinventory before proceeding */
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
    ELSE
      BEGIN
        SELECT NVL(planning_level, 2)
          INTO l_planning_level
          FROM mtl_secondary_inventories
         WHERE secondary_inventory_name = p_subinventory_code
           AND organization_id = l_organization_id;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          fnd_message.set_name('INV', 'INVALID_SUB');
          /* The subinventory provided is invalid */
          fnd_msg_pub.ADD;
          RAISE fnd_api.g_exc_error;
      END;
    END IF;

    /* Validate The locator */
    IF p_inventory_location_id IS NOT NULL THEN
      l_locator_id  := p_inventory_location_id;
    ELSE
      IF p_locator IS NULL THEN
        fnd_message.set_name('INV', 'INV_INT_LOCSEGCODE');
        /* Invalid locator segments */
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_error;
      ELSE
        BEGIN
          SELECT inventory_location_id
            INTO l_locator_id
            FROM mtl_item_locations_kfv
           WHERE concatenated_segments = p_locator
             AND organization_id = l_organization_id;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            fnd_message.set_name('INV', 'INV_INT_LOCCODE');
            /* The Locator provided is invalid */
            fnd_msg_pub.ADD;
            RAISE fnd_api.g_exc_error;
        END;
      END IF;
    END IF;

    /* Check if the locator and subinventory_code combination is valid */
    BEGIN
      SELECT 'VALID'
        INTO l_subflag
        FROM mtl_item_locations
       WHERE inventory_location_id = l_locator_id
         AND subinventory_code = p_subinventory_code
         AND organization_id = l_organization_id;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        fnd_message.set_name('INV', 'INV_INT_LOCSEGEXP');
        /* The Locator segments are invalid for the given subinventory, organization combination */
        RAISE fnd_api.g_exc_error;
    END;

    /* Check if this combination of Org, Item and Locator is present in MTL_SECONDARY_LOCATORS */
    BEGIN
      SELECT 'Y'
        INTO l_locator_exists
        FROM mtl_secondary_locators
       WHERE secondary_locator = l_locator_id
         AND organization_id = l_organization_id
         AND inventory_item_id = l_inventory_item_id;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        l_locator_exists  := 'N';
    END;

    IF p_status_id IS NOT NULL THEN
      BEGIN
        SELECT 1
          INTO l_status_chk
          FROM mtl_material_statuses_vl
         WHERE status_id = p_status_id
           AND enabled_flag = 1;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          fnd_message.set_name('WMS', 'WMS_CONT_INVALID_STATUS_ID');
          /* Invalid status ID. */
          fnd_msg_pub.ADD;
          RAISE fnd_api.g_exc_error;
      END;
    END IF;

    /* Check if an entry exists in MTL_ITEM_SUB_INVENTORIES table for the item passed */
    BEGIN
      SELECT 1
        INTO l_item_sub
        FROM mtl_item_sub_inventories
       WHERE inventory_item_id = l_inventory_item_id
         AND secondary_inventory = p_subinventory_code
         AND organization_id = l_organization_id;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        INSERT INTO mtl_item_sub_inventories
                    (
                     inventory_item_id
                   , organization_id
                   , secondary_inventory
                   , last_update_date
                   , last_updated_by
                   , creation_date
                   , created_by
                   , inventory_planning_code
                    )
             VALUES (
                     l_inventory_item_id
                   , l_organization_id
                   , p_subinventory_code
                   , SYSDATE
                   , fnd_global.user_id
                   , SYSDATE
                   , fnd_global.user_id
                   , 6
                    );
    END;

    /* If the l_locator_flag is N then insert a row into MTL_SECONDARY_LOCATORS */
    IF l_locator_exists = 'N' THEN
      IF (inv_control.g_current_release_level >= inv_release.g_j_release_level) THEN
        INSERT INTO mtl_secondary_locators
                    (
                     inventory_item_id
                   , organization_id
                   , secondary_locator
                   , last_update_date
                   , last_updated_by
                   , creation_date
                   , created_by
                   , subinventory_code
                   , status_id
                   , maximum_quantity
                    )
             VALUES (
                     l_inventory_item_id
                   , l_organization_id
                   , l_locator_id
                   , SYSDATE
                   , fnd_global.user_id
                   , SYSDATE
                   , fnd_global.user_id
                   , p_subinventory_code
                   , p_status_id
                   , DECODE(l_planning_level, 1, p_par_level, NULL)
                    );
      ELSE
        INSERT INTO mtl_secondary_locators
                    (
                     inventory_item_id
                   , organization_id
                   , secondary_locator
                   , last_update_date
                   , last_updated_by
                   , creation_date
                   , created_by
                   , subinventory_code
                   , status_id
                    )
             VALUES (
                     l_inventory_item_id
                   , l_organization_id
                   , l_locator_id
                   , SYSDATE
                   , fnd_global.user_id
                   , SYSDATE
                   , fnd_global.user_id
                   , p_subinventory_code
                   , p_status_id
                    );
      END IF;
    ELSE
      fnd_message.set_name('INV', 'INV_LOCATOR_ASSIGNED');
      /* Locator selected has already been assigned to this item and subinventory */
      fnd_msg_pub.ADD;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status  := 'E';
      ROLLBACK TO location_item_restrict;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status  := 'U';
      ROLLBACK TO location_item_restrict;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      x_return_status  := 'U';
      --DBMS_output.put_line('In others '||sqlerrm);
      ROLLBACK TO location_item_restrict;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg('INV_LOC_WMS_PUB', 'create_loc_item_tie');
      END IF;

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
  END create_loc_item_tie;

  /*
  **-----------------------------------------------------------------------------------
  **
  ** procedure   : delete_locator
  ** description : this procedure deletes a locator in a given organization.
  ** i/p
  ** p_inventory_location_id
  **     identifier of locator to be deleted
  ** p_concatenated_segments
  **     concatenated segment string with separator of the locator to be deleted. Eg:A.1.1
  ** p_organization_id
  **     identifier of organization in which locator is to be deleted.
  ** p_organization_code
  **     organization code of organziation in which locator is to be deleted.
  **     Either  p_organization_id  or   p_organziation_code MUST be passed
  ** p_validation_req_flag
  **     the flag which determines whether validation is required or not.
  **     If it is 'N',the locator is deleted without any further validation
  **     on its existence  in other tables.If it is'Y', the locator is deleted
  **     only if doesnot exist in other tables.
  **
  ** o/p
  ** x_return_status
  **     return status indicating success, error, unexpected error
  ** x_msg_count
  **     number of messages in message list
  ** x_msg_data   :
  **     if the number of messages in message list is 1,
  **     contains message text x_inventory_location_id
  **
  **-----------------------------------------------------------------------------------
  */
  PROCEDURE delete_locator(
    x_return_status         OUT NOCOPY    VARCHAR2
  , x_msg_count             OUT NOCOPY    NUMBER
  , x_msg_data              OUT NOCOPY    VARCHAR2
  , p_inventory_location_id IN            NUMBER
  , p_concatenated_segments IN            VARCHAR2
  , p_organization_id       IN            NUMBER
  , p_organization_code     IN            VARCHAR2
  , p_validation_req_flag   IN            VARCHAR2
  ) IS
    /* Locator details */
    l_inventory_location_id NUMBER;
    l_locator               VARCHAR2(30);
    /* Organisation details */
    l_organization_id       NUMBER;
    /* Others */
    l_chk_org               NUMBER;
    l_chk_loc               NUMBER;
    l_chk_flag              NUMBER;
    l_active_loc            NUMBER;
    l_physical_locator_id   NUMBER;
    l_val                   BOOLEAN;
  BEGIN
    SAVEPOINT del_loc_api;
    x_return_status  := fnd_api.g_ret_sts_success;

    /* Check if the organization_id passed,otherwise get the organisation_id corresponding to the
       Non null organisation_code passed */
    IF p_organization_id IS NOT NULL THEN
      SELECT 1
        INTO l_chk_org
        FROM DUAL
       WHERE EXISTS(SELECT 1
                      FROM mtl_parameters
                     WHERE organization_id = p_organization_id);

      l_organization_id  := p_organization_id;
    ELSE
      IF p_organization_code IS NULL THEN
        fnd_message.set_name('INV', 'INV_ORG_REQUIRED');
        /* Organisation is required */
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_error;
      ELSE
        SELECT organization_id
          INTO l_organization_id
          FROM mtl_parameters
         WHERE organization_code = p_organization_code;
      END IF;
    END IF;

    /* Check the validity of p_inventory_location_id is not null.
       Check if this inventory_location_id exists in MTL_ITEM_LOCATIONS.
       Validate if concatenated_segment passed is valid or not.
       If the concatenated segments is not null and If it is valid,fnd_flex_keyval.combination_id
       will return the inventory_location_id for the Concatenated_segment combination.
       Otherwise the concatenated_segment passed is not a valid one.
     */
    IF p_inventory_location_id IS NOT NULL THEN
      SELECT 1
        INTO l_chk_loc
        FROM DUAL
       WHERE EXISTS(SELECT 1
                      FROM mtl_item_locations
                     WHERE inventory_location_id = p_inventory_location_id
                       AND organization_id = l_organization_id);

      l_inventory_location_id  := p_inventory_location_id;
      l_locator                := p_inventory_location_id;
    ELSE
      IF p_concatenated_segments IS NOT NULL THEN
        l_val  :=
          fnd_flex_keyval.validate_segs(
            operation                    => 'FIND_COMBINATION'
          , appl_short_name              => 'INV'
          , key_flex_code                => 'MTLL'
          , structure_number             => 101
          , concat_segments              => p_concatenated_segments
          , values_or_ids                => 'V'
          , data_set                     => l_organization_id
          );
      END IF;

      IF l_val = FALSE
         OR p_concatenated_segments IS NULL THEN
        fnd_message.set_name('INV', 'INV_LOC_SEGCODE');
        fnd_message.set_token('LOCATOR', l_locator, TRUE);
        /* LOCATOR does not exist */
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_error;
      ELSE
        l_locator                := p_concatenated_segments;
        l_inventory_location_id  := fnd_flex_keyval.combination_id;
      END IF;
    END IF;

    /*
     *  Check if the l_inventory_location_id passed is a physical_location_id
     *  If the l_inventory_location_id is a physical_location_id for other
     *  locators, then error
     *  A locator is a physical locator if inventory_location_id = physical_
     *  location_id
    */
    BEGIN
      SELECT 1
        INTO l_physical_locator_id
        FROM DUAL
       WHERE EXISTS(SELECT 1
                      FROM mtl_item_locations
                     WHERE physical_location_id = l_inventory_location_id
                       AND organization_id = l_organization_id
		       AND inventory_location_id <> physical_location_id); --Bug :5036570

      fnd_message.set_name('INV', 'INV_LOC_PHY');
      fnd_message.set_token('LOCATOR', l_locator, TRUE);
      /*Locator LOCATOR cannot be deleted as it exists as a Physical Locator to Some other Locators*/
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        NULL;
    END;

    /* Check if the locator is active or is it disabled:
       Check in MTL_ITEM_LOCATIONS -DISABLE_DATE > SYSDATE. if true then error
     */

    /* Replaced disable_date with nvl(disable_date,sysdate+1)
       as part of bug 2004798 in the sql below
    */
    BEGIN
      SELECT 1
        INTO l_active_loc
        FROM mtl_item_locations
       WHERE inventory_location_id = l_inventory_location_id
         AND organization_id = l_organization_id
         AND NVL(disable_date, SYSDATE + 1) > SYSDATE;

      fnd_message.set_name('INV', 'INV_LOC_ACTIVE');
      fnd_message.set_token('LOCATOR', l_locator, TRUE);
      /*Locator locator cannot be deleted as  it is active */
      fnd_msg_pub.ADD;
      RAISE fnd_api.g_exc_error;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        NULL;
    END;

    /* Check the value of p_validation_req_flag
     If the value of p_validation_req_flag ='N' then
     delete the locator from MTL_ITEM_LOCATIONS table without validating further .
     Otherwise do the following steps */
    IF p_validation_req_flag = 'Y' THEN --If For Validation
      /* Check if the locator is present in  MTL_ONHAND_QUANTITIES_DETAIL
         If the locator_id exists then error out*/
      BEGIN
        SELECT 1
          INTO l_chk_flag
          FROM DUAL
         WHERE EXISTS(SELECT 1
                        FROM mtl_onhand_quantities_detail
                       WHERE locator_id = l_inventory_location_id
                         AND organization_id = l_organization_id);

        fnd_message.set_name('INV', 'INV_LOC_ONHANDQTY');
        fnd_message.set_token('LOCATOR', l_locator, TRUE);
        /*Locator locator cannot be deleted as items exist in it*/
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_error;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          NULL;
      END;

      /* Check if the locator is present in  MTL_RESERVATIONS
         If the locator_id exists then error out:
      */
      BEGIN
        SELECT 1
          INTO l_chk_flag
          FROM DUAL
         WHERE EXISTS(SELECT 1
                        FROM mtl_reservations
                       WHERE locator_id = l_inventory_location_id
                         AND organization_id = l_organization_id);

        fnd_message.set_name('INV', 'INV_LOC_RESERVE');
        fnd_message.set_token('LOCATOR', l_locator, TRUE);
        /*The locator locator cannot be deleted as reservations exist against it*/
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_error;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          NULL;
      END;

      /* Check if the locator is present in  WMS_LICENSE_PLATE_NUMBERS
         If the LOCATOR_ID exists then error out*/
      BEGIN
        SELECT 1
          INTO l_chk_flag
          FROM DUAL
         WHERE EXISTS(SELECT 1
                        FROM wms_license_plate_numbers
                       WHERE locator_id = l_inventory_location_id
                         AND organization_id = l_organization_id);

        fnd_message.set_name('INV', 'INV_LOC_LPNEXIST');
        fnd_message.set_token('LOCATOR', l_locator, TRUE);
        /*Locator locator cannot be deleted as LPNs reside in it*/
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_error;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          NULL;
      END;

      /*Check if the locator is present in  MTL_SECONDARY_LOCATORS
       If the SECONDARY_LOCATOR exists then error out*/
      BEGIN
        SELECT 1
          INTO l_chk_flag
          FROM DUAL
         WHERE EXISTS(SELECT 1
                        FROM mtl_secondary_locators
                       WHERE secondary_locator = l_inventory_location_id
                         AND organization_id = l_organization_id);

        fnd_message.set_name('INV', 'INV_LOC_ITEMTIE');
        fnd_message.set_token('LOCATOR', l_locator, TRUE);
        /*Locator locator cannot be deleted as it is tied to an item */
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_error;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          NULL;
      END;

      /*Check if the locator is present in  MTL_TRANSACTIONS_INTERFACE
      If the locator_id exists then error out*/
      BEGIN
        SELECT 1
          INTO l_chk_flag
          FROM DUAL
         WHERE EXISTS(SELECT 1
                        FROM mtl_transactions_interface
                       WHERE locator_id = l_inventory_location_id
                         AND organization_id = l_organization_id);

        fnd_message.set_name('INV', 'INV_LOC_PENDTXN');
        fnd_message.set_token('LOCATOR', l_locator, TRUE);
        /*Locator locator cannot be deleted as there are pending transactions against it*/
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_error;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          NULL;
      END;

      /* Check if the locator is present in  MTL_MATERIAL_TRANSACTIONS_TEMP
         If the LOCATOR_ID exists then error out*/
      /* Added the condition after OR clause in the following SQL to handle the case
         when a locator exists in the tranfer_to_location field of the MMTT record
         as a part of the Bug Fix:2004798*/
      BEGIN
        SELECT 1
          INTO l_chk_flag
          FROM DUAL
         WHERE EXISTS(
                 SELECT 1
                   FROM mtl_material_transactions_temp
                  WHERE (locator_id = l_inventory_location_id
                         AND organization_id = l_organization_id)
                     OR(transfer_to_location = l_inventory_location_id
                        AND NVL(transfer_organization, organization_id) = l_organization_id));

        fnd_message.set_name('INV', 'INV_LOC_PENDTXN');
        fnd_message.set_token('LOCATOR', l_locator, TRUE);
        /*Locator locator cannot be deleted as there are pending transactions against it*/
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_error;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          NULL;
      END;

      /* Check if the locator is existing in RCV_TRANSACTIONS_INTERFACE
       if the locator exists then error out*/
      BEGIN
        SELECT 1
          INTO l_chk_flag
          FROM DUAL
         WHERE EXISTS(SELECT 1
                        FROM rcv_transactions_interface
                       WHERE locator_id = l_inventory_location_id
                         AND to_organization_id = l_organization_id);

        fnd_message.set_name('INV', 'INV_LOC_PENDTXN');
        fnd_message.set_token('LOCATOR', l_locator, TRUE);
        /*Locator locator cannot be deleted as there are pending transactions against it*/
        fnd_msg_pub.ADD;
        RAISE fnd_api.g_exc_error;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          NULL;
      END;
    END IF; --End If For Validation

    /* If all the above steps  are success then delete the inventory_location_id
     from MTL_ITEM_LOCATIONS
     for the combination of inventory_location_id and organization_id*/
    DELETE      mtl_item_locations
          WHERE inventory_location_id = l_inventory_location_id
            AND organization_id = l_organization_id;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status  := fnd_api.g_ret_sts_error;
      ROLLBACK TO del_loc_api;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      ROLLBACK TO del_loc_api;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN NO_DATA_FOUND THEN
      ROLLBACK TO del_loc_api;
      x_return_status  := fnd_api.g_ret_sts_error;
    WHEN OTHERS THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      ROLLBACK TO del_loc_api;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg('inv_loc_wms_pub', 'delete_locator');
      END IF;

      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  END delete_locator;


END inv_loc_wms_pub;

/
