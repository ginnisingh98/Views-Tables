--------------------------------------------------------
--  DDL for Package Body INV_SERIAL_NUMBER_ATTR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_SERIAL_NUMBER_ATTR" AS
/* $Header: INVSATRB.pls 120.2 2005/07/15 03:45:00 abshukla ship $ */

  G_PKG_NAME CONSTANT VARCHAR2(30) := 'INV_SERIAL_NUMBER_ATTR';

procedure print_debug(p_err_msg VARCHAR2)
IS
BEGIN
   IF (g_debug = 1) THEN
      inv_log_util.trace(p_err_msg, G_PKG_NAME, 9);
      --DBMS_OUTPUT.PUT_LINE(p_err_msg);
   END IF;
end print_debug;

procedure Update_Serial_number_attr(
   x_return_status              OUT  NOCOPY VARCHAR2,
   x_msg_count                  OUT  NOCOPY NUMBER,
   x_msg_data                   OUT  NOCOPY VARCHAR2,

   p_serial_number             IN   VARCHAR2,
   p_inventory_item_id         IN   NUMBER,
   p_attribute_category        IN   VARCHAR2  DEFAULT NULL,
   p_attributes_tbl            IN   inv_serial_number_attr.char_table) IS

    TYPE seg_name IS TABLE OF VARCHAR2(500)
      INDEX BY BINARY_INTEGER;

    l_tempvar            NUMBER;
    l_default_attr_category VARCHAR2(240);
    l_context            VARCHAR2(1000);
    l_context_r          fnd_dflex.context_r;
    l_contexts_dr        fnd_dflex.contexts_dr;
    l_dflex_r            fnd_dflex.dflex_r;
    l_segments_dr        fnd_dflex.segments_dr;
    l_enabled_seg_name   seg_name;
    l_inv_attributes_tbl seg_name;
    l_nsegments          BINARY_INTEGER;
    l_global_context     BINARY_INTEGER;
    v_index              NUMBER                := 1;
    v_index1             NUMBER                := 1;
    l_chk_flag           NUMBER                := 0;
    l_return_status      VARCHAR2(1);
    l_msg_count          NUMBER;
    l_msg_data           VARCHAR2(1000);
    l_attr_index         NUMBER;
    g_miss_char          CONSTANT VARCHAR2(1)  := CHR(0);

    /* Variables used for Validate_desccols procedure */
    error_segment      VARCHAR2(30);
    errors_received    EXCEPTION;
    serial_not_found   EXCEPTION;
    error_msg          VARCHAR2(5000);
    s                  NUMBER;
    e                  NUMBER;
    l_null_char_val    VARCHAR2(1000);
BEGIN

    -- Initialize API return status to success
    x_return_status  := FND_API.G_RET_STS_SUCCESS;

    IF (g_debug = 1) THEN
        print_debug('item_id: '||p_inventory_item_id||', serial_number: '||p_serial_number||
                    ', attribute_category: '||p_attribute_category);

        l_attr_index  := p_attributes_tbl.FIRST;
        WHILE l_attr_index <= p_attributes_tbl.LAST LOOP
            print_debug('p_attributes_tbl'||l_attr_index||' = ' ||p_attributes_tbl(l_attr_index));
            l_attr_index  := p_attributes_tbl.NEXT(l_attr_index);
        END LOOP;
    END IF;

    BEGIN
      SELECT 1
         INTO l_tempvar
         FROM mtl_serial_numbers
         WHERE inventory_item_id = p_inventory_item_id
         AND   serial_number = p_serial_number
         AND   current_status in (1,3,4); --Bug4493227
    EXCEPTION
         WHEN no_data_found THEN
            IF (g_debug = 1) THEN
               print_debug('no data found for the serial');
            END IF;

            fnd_message.set_name('INV', 'INV_SER_NOTEXIST');
            fnd_message.set_token('TOKEN', p_serial_number);
            fnd_msg_pub.ADD;
            RAISE serial_not_found;
    END;

    -- Initialize savepoint
    SAVEPOINT get_serial_attr_information;

    IF p_attribute_category IS NULL THEN
       --Get default attribute_category context
       l_dflex_r.application_id  := 401;
       l_dflex_r.flexfield_name  := 'MTL_SERIAL_NUMBERS';
       /* Get all contexts */
       fnd_dflex.get_contexts(flexfield => l_dflex_r, contexts => l_contexts_dr);

       IF g_debug = 1 THEN
         print_debug('Found contexts for the Flexfield MTL_SERIAL_NUMBERS');
       END IF;

       /* From the l_contexts_dr, get the position of the global context */
       l_global_context          := l_contexts_dr.global_context;

       IF g_debug = 1 THEN
         print_debug('Found the position of the global context');
       END IF;

       /* Using the position get the segments in the global context which are enabled */
       l_default_attr_category                 := l_contexts_dr.context_code(l_global_context);
    ELSE
      l_default_attr_category := p_attribute_category;
    END IF;

    IF (g_debug = 1) THEN
       print_debug('l_default_attr_category: ' ||l_default_attr_category);
    END IF;

    /* Populate the flex field record */
    IF l_default_attr_category IS NOT NULL THEN
       --AND p_attributes_tbl.COUNT > 0 THEN
      l_dflex_r.application_id  := 401;
      l_dflex_r.flexfield_name  := 'MTL_SERIAL_NUMBERS';
      /* Get all contexts */
      fnd_dflex.get_contexts(flexfield => l_dflex_r, contexts => l_contexts_dr);

      IF g_debug = 1 THEN
        print_debug('Found contexts for the Flexfield MTL_SERIAL_NUMBERS');
      END IF;

      /* From the l_contexts_dr, get the position of the global context */
      l_global_context          := l_contexts_dr.global_context;

      IF g_debug = 1 THEN
        print_debug('Found the position of the global context');
      END IF;

      /* Using the position get the segments in the global context which are enabled */
      l_context                 := l_contexts_dr.context_code(l_global_context);

      IF g_debug = 1 THEN
        print_debug('l_context: ' ||l_context);
      END IF;

      /* Prepare the context_r type for getting the segments associated with the global context */
      l_context_r.flexfield     := l_dflex_r;
      l_context_r.context_code  := l_context;

      fnd_dflex.get_segments(CONTEXT => l_context_r, segments => l_segments_dr, enabled_only => TRUE);

      IF g_debug = 1 THEN
        print_debug('After successfully getting all the enabled segments for the Global Context ');
      END IF;

      /* read through the segments */
      l_nsegments               := l_segments_dr.nsegments;

      IF g_debug = 1 THEN
        print_debug('The number of enabled segments for the Global Context are ' || l_nsegments);
      END IF;

      FOR i IN 1 .. l_nsegments LOOP
        IF g_debug = 1 THEN
          print_debug('v_index is ' || v_index);
          print_debug('application_column_name is ' || l_segments_dr.application_column_name(i));
        END IF;

        l_enabled_seg_name(v_index)  := l_segments_dr.application_column_name(i);

        IF g_debug = 1 THEN
          print_debug('The segment is ' || l_segments_dr.segment_name(i));
          print_debug('p_attributes_tbl count ' ||p_attributes_tbl.count);
        END IF;

        IF l_segments_dr.is_required(i) THEN
          IF NOT p_attributes_tbl.EXISTS(SUBSTR(l_segments_dr.application_column_name(i)
                  , INSTR(l_segments_dr.application_column_name(i), 'ATTRIBUTE') + 9)) THEN
            fnd_message.set_name('INV', 'INV_REQ_SEG_MISS');
            fnd_message.set_token('SEGMENT', l_segments_dr.segment_name(i));
            fnd_msg_pub.ADD;

            IF g_debug = 1 THEN
              print_debug('Req segment is not populated');
            END IF;

            RAISE FND_API.G_EXC_ERROR;
          END IF;
        ELSE
          IF g_debug = 1 THEN
            print_debug('This segment is not required');
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

        --fnd_flex_descval.set_column_value(l_segments_dr.application_column_name(i),p_attributes_tbl(SUBSTR(l_segments_dr.application_column_name(i),INSTR(l_segments_dr.application_column_name(i),'ATTRIBUTE')+9)));
        v_index                      := v_index + 1;
      END LOOP;

      IF l_enabled_seg_name.COUNT > 0 THEN
        FOR i IN l_enabled_seg_name.FIRST .. l_enabled_seg_name.LAST LOOP
          IF g_debug = 1 THEN
            print_debug('The enabled segment : ' || l_enabled_seg_name(i));
          END IF;
        END LOOP;
      END IF;

      /* Initialise the l_context_value to null */
      l_context                 := NULL;
      l_nsegments               := 0;

     /*Get the context for the item passed */
      IF l_default_attr_category IS NOT NULL THEN
        l_context                 := l_default_attr_category;
        /* Set flex context for validation of the value set */
        fnd_flex_descval.set_context_value(l_context);

        IF g_debug = 1 THEN
          print_debug('The value of INV context is ' || l_context);
        END IF;

        /* Prepare the context_r type */
        l_context_r.flexfield     := l_dflex_r;
        l_context_r.context_code  := l_context;
        fnd_dflex.get_segments(CONTEXT => l_context_r, segments => l_segments_dr, enabled_only => TRUE);
        /* read through the segments */
        l_nsegments               := l_segments_dr.nsegments;
        IF g_debug = 1 THEN
          print_debug('No of segments enabled for context ' || l_context || ' are ' || l_nsegments);
        END IF;

        print_debug('v_index is ' || v_index);
        v_index := 1;
        FOR i IN 1 .. l_nsegments LOOP
          l_enabled_seg_name(v_index)  := l_segments_dr.application_column_name(i);

          print_debug('v_index is ' || v_index);
          print_debug('The segment is ' || l_segments_dr.segment_name(i));

          IF l_segments_dr.is_required(i) THEN
            IF NOT p_attributes_tbl.EXISTS(SUBSTR(l_segments_dr.application_column_name(i)
                    , INSTR(l_segments_dr.application_column_name(i), 'ATTRIBUTE') + 9)) THEN
              fnd_message.set_name('INV', 'INV_REQ_SEG_MISS');
              fnd_message.set_token('SEGMENT', l_segments_dr.segment_name(i));
              fnd_msg_pub.ADD;
              RAISE FND_API.G_EXC_ERROR;

              IF g_debug = 1 THEN
                print_debug('Req segment is not populated');
              END IF;
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

        --IF l_enabled_seg_name.count = P_ATTRIBUTES_TBL.count THEN
        /*v_index1                  := p_attributes_tbl.FIRST;

        print_debug('l_enabled_seg_name.count is ' || l_enabled_seg_name.COUNT);
        WHILE v_index1 <= p_attributes_tbl.LAST LOOP
          IF g_debug = 1 THEN
            print_debug('The value of segment is ' || v_index1);
          END IF;

          FOR i IN 1 .. l_enabled_seg_name.COUNT LOOP
            IF l_enabled_seg_name(i) = 'ATTRIBUTE' || v_index1 THEN
              print_debug('The value of segments have matched '||l_enabled_seg_name(i));
              l_chk_flag  := 1;
              EXIT;
            END IF;
          END LOOP;

          IF l_chk_flag = 0 AND p_attributes_tbl(v_index1) IS NOT NULL THEN
            fnd_message.set_name('INV', 'INV_WRONG_SEG_POPULATE');
            fnd_message.set_token('SEGMENT', 'ATTRIBUTE' || v_index1);
            fnd_message.set_token('CONTEXT', l_context);
            fnd_msg_pub.ADD;
            --print_debug('Error out. Correct segmenst are not populated ');
            RAISE FND_API.G_EXC_ERROR;
          END IF;

          v_index1    := p_attributes_tbl.NEXT(v_index1);
          l_chk_flag  := 0;
        END LOOP;*/

        /*Make a call to  FND_FLEX_DESCVAL.validate_desccols */
        IF fnd_flex_descval.validate_desccols(appl_short_name => 'INV', desc_flex_name => 'MTL_SERIAL_NUMBERS', values_or_ids => 'I', validation_date              => SYSDATE) THEN
          IF g_debug = 1 THEN
            print_debug('Value set validation successful');
          END IF;
        ELSE
          IF g_debug = 1 THEN
            error_segment  := fnd_flex_descval.error_segment;
            print_debug('Value set validation failed for segment ' || error_segment);
            RAISE errors_received;
          END IF;
        END IF;
      END IF;  /*If P attribute category is not null */

    END IF;   /* l_default_attr_category IS NOT NULL */

      IF p_attributes_tbl.COUNT > 0 THEN
        l_attr_index  := p_attributes_tbl.FIRST;

        WHILE l_attr_index <= p_attributes_tbl.LAST LOOP
          IF p_attributes_tbl(l_attr_index) = g_miss_char THEN
             l_inv_attributes_tbl(l_attr_index)      := g_miss_char;
          ELSE
             l_inv_attributes_tbl(l_attr_index)      := p_attributes_tbl(l_attr_index);
          END IF;

          l_attr_index  := p_attributes_tbl.NEXT(l_attr_index);
        END LOOP;

        -- Setting other attributes which are not passed to null
        l_attr_index  := 1;
        WHILE l_attr_index <= 15 LOOP
          IF NOT l_inv_attributes_tbl.EXISTS(l_attr_index) THEN
              l_inv_attributes_tbl(l_attr_index)      := null;
          END IF;
          l_attr_index  := l_attr_index + 1;
        END LOOP;
      END IF;

      IF g_debug = 1 THEN
         l_attr_index  := l_inv_attributes_tbl.FIRST;
         WHILE l_attr_index <= l_inv_attributes_tbl.LAST LOOP
            print_debug('l_inv_attributes_tbl'||l_attr_index||' = ' ||l_inv_attributes_tbl(l_attr_index));
            l_attr_index  := l_inv_attributes_tbl.NEXT(l_attr_index);
         END LOOP;
         print_debug('updating MSN with attributes');
         print_debug('item_id = ' ||p_inventory_item_id||', serial_number = ' ||p_serial_number);
      END IF;

      UPDATE mtl_serial_numbers
      SET
	  attribute_category = l_default_attr_category
        , attribute1  = DECODE(l_inv_attributes_tbl(1), g_miss_char, NULL, NULL, attribute1, l_inv_attributes_tbl(1))
        , attribute2  = DECODE(l_inv_attributes_tbl(2), g_miss_char, NULL, NULL, attribute2, l_inv_attributes_tbl(2))
        , attribute3  = DECODE(l_inv_attributes_tbl(3), g_miss_char, NULL, NULL, attribute3, l_inv_attributes_tbl(3))
        , attribute4  = DECODE(l_inv_attributes_tbl(4), g_miss_char, NULL, NULL, attribute4, l_inv_attributes_tbl(4))
        , attribute5  = DECODE(l_inv_attributes_tbl(5), g_miss_char, NULL, NULL, attribute5, l_inv_attributes_tbl(5))
        , attribute6  = DECODE(l_inv_attributes_tbl(6), g_miss_char, NULL, NULL, attribute6, l_inv_attributes_tbl(6))
        , attribute7  = DECODE(l_inv_attributes_tbl(7), g_miss_char, NULL, NULL, attribute7, l_inv_attributes_tbl(7))
        , attribute8  = DECODE(l_inv_attributes_tbl(8), g_miss_char, NULL, NULL, attribute8, l_inv_attributes_tbl(8))
        , attribute9  = DECODE(l_inv_attributes_tbl(9), g_miss_char, NULL, NULL, attribute9, l_inv_attributes_tbl(9))
        , attribute10 = DECODE(l_inv_attributes_tbl(10), g_miss_char, NULL, NULL, attribute10, l_inv_attributes_tbl(10))
        , attribute11 = DECODE(l_inv_attributes_tbl(11), g_miss_char, NULL, NULL, attribute11, l_inv_attributes_tbl(11))
        , attribute12 = DECODE(l_inv_attributes_tbl(12), g_miss_char, NULL, NULL, attribute12, l_inv_attributes_tbl(12))
        , attribute13 = DECODE(l_inv_attributes_tbl(13), g_miss_char, NULL, NULL, attribute13, l_inv_attributes_tbl(13))
        , attribute14 = DECODE(l_inv_attributes_tbl(14), g_miss_char, NULL, NULL, attribute14, l_inv_attributes_tbl(14))
        , attribute15 = DECODE(l_inv_attributes_tbl(15), g_miss_char, NULL, NULL, attribute15, l_inv_attributes_tbl(15))
      WHERE inventory_item_id = p_inventory_item_id
      AND   serial_number = p_serial_number
      AND   current_status in (1,3,4);  --Bug4493227

      IF SQL%FOUND THEN
        IF g_debug = 1 THEN
           print_debug('Upd Serial Attr: Update successfully completed');
        END IF;
      ELSE
        IF g_debug = 1 THEN
           print_debug('Serial not found for update');
        END IF;
      END IF;

EXCEPTION
    WHEN serial_not_found THEN
      x_return_status  := FND_API.G_RET_STS_ERROR;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);

    WHEN errors_received THEN
      x_return_status  := FND_API.G_RET_STS_ERROR;
      error_msg        := fnd_flex_descval.error_message;
      s                := 1;
      e                := 200;

      print_debug('Here are the error messages: ');
      WHILE e < 5001
       AND SUBSTR(error_msg, s, e) IS NOT NULL LOOP
        fnd_message.set_name('INV', 'INV_FND_GENERIC_MSG');
        fnd_message.set_token('MSG', SUBSTR(error_msg, s, e));
        fnd_msg_pub.ADD;
        print_debug(SUBSTR(error_msg, s, e));
        s  := s + 200;
        e  := e + 200;
      END LOOP;

      ROLLBACK TO get_serial_attr_information;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status  := FND_API.G_RET_STS_ERROR;
      ROLLBACK TO get_serial_attr_information;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status  := FND_API.G_RET_STS_UNEXP_ERROR;
      ROLLBACK TO get_serial_attr_information;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      x_return_status  := FND_API.G_RET_STS_UNEXP_ERROR;
      ROLLBACK TO get_serial_attr_information;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false, p_count => x_msg_count, p_data => x_msg_data);
      print_debug('Error ' || SQLERRM);
END Update_Serial_number_attr;

END INV_SERIAL_NUMBER_ATTR;

/
