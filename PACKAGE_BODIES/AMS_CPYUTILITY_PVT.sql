--------------------------------------------------------
--  DDL for Package Body AMS_CPYUTILITY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_CPYUTILITY_PVT" AS
 /* $Header: amsvcpub.pls 120.1 2006/01/18 11:20:21 musman noship $ */

-- Start Of Comments
--
-- Name:
--   Ams_CPYUTILITY_PVT
--
-- Purpose:
--   This is the body for the utility packages in copy functionality in Oracle Marketing
--   from their ids.

-- GET_name functions
--   These functions will be called by marketing activities such as promotions,campaigns,
--   channels,events,etc and marketing elements such as products,scripts,resources etc while copying them
--   and will provide the names of the particular element if their is any error.
-- Function:
-- get_objective_name       (see below for specification
-- get_offer_name           (see below for specification)
-- get_script_name          (see below for specification)
-- get_reosurce_name        (see below for specification)-- get_product_name         (see below for specification)
-- get_cell_name            (see below for specification)
-- get_geo_area_name        (see below for specification)
-- get_attachment_name      (see below for specification)
-- get_deliverable_name     (see below for specification)
-- get_business_party_name  (see below for specification)
-- get_list_header_name     (see below for specification)
-- get_access_name          (see below for specification)
-- get_deliverable_header_name  (see below for specification)
-- get_event_header_name

-- Notes:
--
-- History:
-- 07//1999    Mumu Pande  Updated Comments
-- AMS_CPYUTILITY_PVT package.
-- 07/15/1999  Mumu Pande  Created (mpande@us.oracle.com)
-- 17-Feb-2001 ptendulk    Added autonomous transaction. in insert_log_message
-- 05-Apr-2001 choang      Added get_column_value
--
-- 29-Oct-2001 rrajesh     Added check_attrib_exists.
-- End Of Comments
-- PL/SQL table type Global Variable for writing the log messages
-- PL/SQL table type Global Variable for writing the log messages
   g_log_mesg_txt    log_mesg_txt_table;
   g_log_mesg_type   log_mesg_type_table;
   g_act_used_by     log_act_used_by_table;
   g_act_used_id     log_act_used_id_table;
   g_index           NUMBER;

   AMS_DEBUG_HIGH_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
AMS_DEBUG_LOW_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
AMS_DEBUG_MEDIUM_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);

FUNCTION get_deliverable_name (p_deliverable_id IN NUMBER)
      RETURN VARCHAR2
   IS
        CURSOR c_deliv_name(p_deliverable_id IN NUMBER)    IS
        SELECT   deliverable_name
        FROM     ams_deliverables_vl
        WHERE  deliverable_id = p_deliverable_id;

      -- PL/SQL Block

      l_name   VARCHAR2 (240);

   BEGIN

      OPEN c_deliv_name(p_deliverable_id);
      FETCH c_deliv_name INTO l_name;
      CLOSE c_deliv_name;

       RETURN '"' || l_name || '"';
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN ' "' || p_deliverable_id || '"';
   END get_deliverable_name;

   FUNCTION get_event_header_name (p_event_header_id IN NUMBER)
      RETURN VARCHAR2
   IS

        CURSOR c_eveh_name(p_event_header_id IN NUMBER)    IS
          SELECT   event_header_name
          FROM     ams_event_headers_vl
          WHERE  event_header_id = p_event_header_id;

     -- PL/SQL Block

      l_name   VARCHAR2 (240);
   BEGIN

      OPEN c_eveh_name(p_event_header_id);
      FETCH c_eveh_name INTO l_name;
      CLOSE c_eveh_name;

      RETURN ' "' || l_name || '"';
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN '"' || p_event_header_id || '"';
   END get_event_header_name;

   FUNCTION get_offer_code (p_offer_id IN NUMBER)
      RETURN VARCHAR2

   IS
        CURSOR c_offer_code(p_offer_id IN NUMBER)    IS
          SELECT   offer_code
          FROM     ams_act_offers
          WHERE  activity_offer_id = p_offer_id;

      -- PL/SQL Block

      l_name   VARCHAR2 (240);
   BEGIN

      OPEN c_offer_code(p_offer_id);
      FETCH c_offer_code INTO l_name;
      CLOSE c_offer_code;

      RETURN ' "' || l_name || '"';

   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN ' "' || p_offer_id || '"';
   END get_offer_code;

   FUNCTION get_product_name (p_category_id IN NUMBER)
      RETURN VARCHAR2
   IS

    /* bug 4957294  fix musman 18-jan-06
        CURSOR c_product_name(p_category_id IN NUMBER)    IS
          SELECT DISTINCT   (category_name)
          FROM     ams_act_products_v
          WHERE  category_id = p_category_id;
    */
        CURSOR  c_product_name(p_category_id IN NUMBER)    IS
        SELECT  concatenated_segments
	  FROM  MTL_CATEGORIES_b_kfv
         WHERE  category_id = p_category_id;
      -- PL/SQL Block
      l_name   VARCHAR2 (240);

   BEGIN

      OPEN c_product_name(p_category_id);
      FETCH c_product_name INTO l_name;
      CLOSE c_product_name;


      RETURN ' "' ||l_name || '"';

   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN ' "' ||p_category_id||' "' ;

   END get_product_name;

   FUNCTION get_message_name (p_message_id IN NUMBER)
      RETURN VARCHAR2
   IS
        CURSOR c_message_name(p_message_id IN NUMBER)    IS
          SELECT   message_name
          FROM     ams_messages_vl
          WHERE  message_id = p_message_id;

      -- PL/SQL Block
      l_name   VARCHAR2 (240);
   BEGIN
      OPEN c_message_name(p_message_id);
      FETCH c_message_name INTO l_name;
      CLOSE c_message_name;

      RETURN ' "' || l_name || '"';
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN '"' || p_message_id || '"';
   END get_message_name;

   FUNCTION get_event_offer_name (p_event_offering_id IN NUMBER)
      RETURN VARCHAR2
   IS
      -- PL/SQL Block
      l_name   VARCHAR2 (240);

        CURSOR c_eveo_name(p_event_offering_id IN NUMBER)    IS
          SELECT   event_offer_name
          FROM     ams_event_offers_vl
          WHERE  event_offer_id = p_event_offering_id;

   BEGIN

      OPEN c_eveo_name(p_event_offering_id);
      FETCH c_eveo_name INTO l_name;
      CLOSE c_eveo_name;

      RETURN '"' || l_name || '"';
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN '"' ||   p_event_offering_id ||           '"';
   END get_event_offer_name;

   FUNCTION get_geo_area_name (
      p_geo_hierarchy_id   IN   NUMBER,
      p_geo_area_type      IN   VARCHAR2
      )
      RETURN VARCHAR2
   IS
        CURSOR c_geo_area_name( p_geo_hierarchy_id   IN   NUMBER,
                                p_geo_area_type      IN   VARCHAR2)    IS
       SELECT decode(lh.location_type_code, 'AREA1',
                     lh.area1_name, 'AREA2',
                     lh.area2_name, 'COUNTRY',
                     lh.country_name, 'CREGION',
                     lh.country_region_name, 'STATE',
                     lh.state_name, 'SREGION',
                     lh.state_region_name, 'CITY',
                     lh.city_name, 'POSTAL_CODE',
                     lh.postal_code_start||'-'||lh.postal_code_end) GEO_AREA_NAME
          FROM jtf_loc_hierarchies_vl lh
          WHERE  location_hierarchy_id = p_geo_hierarchy_id
             AND location_type_code = p_geo_area_type;
    /* dbiswas changed the following select clause and replaced with the decode select clause above
       for sql repository performance issue bug # 3631235
         SELECT   geo_area_name
          FROM     ams_act_geo_areas_v
          WHERE  geo_hierarchy_id = p_geo_hierarchy_id
             AND geo_type_code = p_geo_area_type;
    */
      -- PL/SQL Block
      l_name   VARCHAR2 (240);
   BEGIN

      OPEN c_geo_area_name( p_geo_hierarchy_id,p_geo_area_type );
      FETCH c_geo_area_name INTO l_name;
      CLOSE c_geo_area_name;

      RETURN '"' || l_name || '"';
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN '"' ||p_geo_hierarchy_id ||'"-"' ||p_geo_area_type ||'"';
   END get_geo_area_name;

   FUNCTION get_resource_name (p_resource_id IN NUMBER)
      RETURN VARCHAR2
   IS
      -- PL/SQL Block
      l_name   VARCHAR2 (240);

        CURSOR c_resource_name(p_resource_id IN NUMBER)    IS
          SELECT  full_name
          FROM    ams_jtf_rs_emp_v
          WHERE  resource_id = p_resource_id;

   BEGIN

      OPEN c_resource_name(p_resource_id);
      FETCH c_resource_name INTO l_name;
      CLOSE c_resource_name;

      RETURN ' "' ||l_name|| ' "' ;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN ' "' || p_resource_id||' "';
   END get_resource_name;


   FUNCTION get_segment_name (p_cell_id IN NUMBER)
      RETURN VARCHAR2
   IS
      -- PL/SQL Block
      l_name   VARCHAR2 (240);

        CURSOR c_segment_name(p_cell_id IN NUMBER)    IS
          SELECT   cell_name
          FROM     ams_cells_vl
          WHERE  cell_id = p_cell_id;

   BEGIN

      OPEN c_segment_name(p_cell_id);
      FETCH c_segment_name INTO l_name;
      CLOSE c_segment_name;


      RETURN ' "' ||l_name||' "';
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN ' "' || p_cell_id||' "' ;
   END get_segment_name;

   FUNCTION get_attachment_name (p_act_attachment_id IN NUMBER)
      RETURN VARCHAR2
   IS
      -- PL/SQL Block
      l_name   VARCHAR2 (240);

        CURSOR c_attch_name(p_act_attachment_id IN NUMBER)    IS
          SELECT DISTINCT   (file_name)
          FROM     jtf_amv_attachments
          WHERE  attachment_id = p_act_attachment_id;

   BEGIN

      OPEN c_attch_name(p_act_attachment_id);
      FETCH c_attch_name INTO l_name;
      CLOSE c_attch_name;

      RETURN ' "' ||l_name||' "' ;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN ' "' ||p_act_attachment_id||' "' ;
   END get_attachment_name;

   FUNCTION get_category_name (p_category_id IN NUMBER)
      RETURN VARCHAR2
   IS
      -- PL/SQL Block
      l_name   VARCHAR2 (256);
        CURSOR c_category_name(p_category_id IN NUMBER)    IS
        SELECT   category_name
          FROM     ams_categories_tl
          WHERE  category_id = p_category_id;

   BEGIN

      OPEN c_category_name(p_category_id);
      FETCH c_category_name INTO l_name;
      CLOSE c_category_name;

      RETURN '"' || l_name || '" ';
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN '"' || p_category_id || '"';
   END get_category_name;


-- Sub-Program Unit Declarations
   /* Log an error. */
   PROCEDURE write_log_mesg (
      p_act_type       IN   VARCHAR2,
      p_act_id         IN   NUMBER,
      p_message_text   IN   VARCHAR2,
      p_message_type   IN   VARCHAR2
   )
   IS
   BEGIN

      BEGIN
         g_index := NVL (g_index, 0) + 1;
         g_log_mesg_txt (g_index) := p_message_text;
         g_log_mesg_type (g_index) := p_message_type;
         g_act_used_by (g_index) := p_act_type;
         g_act_used_id (g_index) := p_act_id;
      END;
   EXCEPTION
      WHEN OTHERS
      THEN
         RAISE;
   END write_log_mesg;

   /* Refresh the PL/SQL log table. */
   PROCEDURE refresh_log_mesg
   IS
   BEGIN
      g_index := 0;
      g_log_mesg_txt.delete;
      g_log_mesg_type.delete;
      g_act_used_by.delete;
      g_act_used_id.delete;
   EXCEPTION
      WHEN OTHERS
      THEN
         RAISE;
   END refresh_log_mesg;

   /* Write the log infomation from PL/SQL table into ams_activity_logs. */

   --   17-Feb-2001    ptendulk     Made the api Autonomous

   PROCEDURE insert_log_mesg (x_transaction_id OUT NOCOPY NUMBER)
   IS
   PRAGMA AUTONOMOUS_TRANSACTION;
   BEGIN
   SELECT ams_Act_logs_transaction_id_s.nextval
    into x_transaction_id
    FROM DUAL;
      IF g_index <> 0
      THEN
         FOR i IN 1 .. g_index
         LOOP
            INSERT INTO ams_act_logs
                        (
                                       activity_log_id,
                                       last_update_date,
                                       last_updated_by,
                                       creation_date,
                                       created_by,
                                       last_update_login,
                                       act_log_used_by_id,
                                       arc_act_log_used_by,
                                       log_transaction_id,
                                       log_message_text,
                                       log_message_type
                                    )
                 VALUES (
                    ams_act_logs_s.nextval,
                    SYSDATE,
                    fnd_global.user_id,
                    SYSDATE,
                    fnd_global.user_id,
                    fnd_global.conc_login_id,
                    g_act_used_id (i),
                    g_act_used_by (i),
                    x_transaction_id,
                    g_log_mesg_txt (i),
                    g_log_mesg_type (i)
                 );
         END LOOP;
      END IF;
      COMMIT ;
   EXCEPTION
      WHEN OTHERS
      THEN
         RAISE;
   END insert_log_mesg;


    FUNCTION get_dates(p_arc_act_code IN VARCHAR2,
                      p_activity_id  IN NUMBER,
                      x_return_status OUT NOCOPY VARCHAR2)
           RETURN NUMBER
    IS
    start_date        date;
    end_date          date;
    l_number          NUMBER;

    BEGIN

     x_return_status := fnd_api.g_ret_sts_success;
     l_number          := 0;
      IF p_arc_act_code = 'CAMP'  THEN
       SELECT actual_exec_end_date ,actual_exec_start_date
       INTO end_date,start_date
       FROM AMS_CAMPAIGNS_VL
       WHERE campaign_id = p_activity_id;

         l_number := (end_date - start_date);

      ELSIF p_arc_act_code = 'EVEO'  THEN
       SELECT event_end_date,event_start_date
       INTO end_date,start_date
       FROM AMS_EVENT_OFFERS_VL
       WHERE event_offer_id = p_activity_id;
         l_number := (end_date - start_date);

      ELSIF p_arc_act_code = 'EVEH'  THEN
       SELECT active_to_date,active_from_date
       INTO end_date,start_date
       FROM AMS_EVENT_HEADERS_VL
       WHERE event_header_id = p_activity_id;
           l_number := (end_date - start_date);
      END IF ;

     RETURN l_number;

   EXCEPTION
      WHEN OTHERS
      THEN
         x_return_status := fnd_api.g_ret_sts_error;
END  get_dates;


   -- History
   -- 05-Apr-2001 choang   Created.
   PROCEDURE get_column_value (
      p_column_name     IN VARCHAR2,
      p_columns_table   IN copy_columns_table_type,
      x_column_value    OUT NOCOPY VARCHAR2
   )
   IS
   BEGIN
      -- if the column is not found, then
      -- return null
      FOR i IN 1..p_columns_table.COUNT LOOP
         IF p_column_name = p_columns_table(i).column_name THEN
            x_column_value := p_columns_table(i).column_value;
            RETURN;
         END IF;
      END LOOP;
   END get_column_value;

   -- History
   -- 05-Apr-2001 choang   Created.
   FUNCTION is_copy_attribute (
      p_attribute          IN VARCHAR2,
      p_attributes_table   IN copy_attributes_table_type
   ) RETURN VARCHAR2
   IS
   BEGIN
      FOR i IN 1..p_attributes_table.COUNT LOOP
         IF p_attribute = p_attributes_table(i) THEN
            RETURN FND_API.G_TRUE;
         END IF;
      END LOOP;
      RETURN FND_API.G_FALSE;
   END is_copy_attribute;

   -- History
   -- 29 OCT 2001   rrajesh   Created.
   FUNCTION check_attrib_exists (
      p_obj_type        IN VARCHAR2,
      p_obj_id          IN NUMBER,
      p_obj_attribute   IN VARCHAR2
   ) RETURN VARCHAR2
   IS
      CURSOR c_csch_exists(p_camp_id NUMBER) IS
        SELECT COUNT(1) from ams_campaign_schedules_vl
        WHERE campaign_id = p_camp_id;
      CURSOR c_mesg_exists(p_obj_id NUMBER, p_obj_type VARCHAR2) IS
        SELECT COUNT(1) from ams_act_messages
        WHERE message_used_by_id = p_obj_id
        AND message_used_by = p_obj_type;
      CURSOR c_delv_exists(p_obj_id NUMBER, p_obj_type VARCHAR2) IS
        SELECT COUNT(1)
        FROM ams_object_associations
        WHERE master_object_id = p_obj_id
        AND master_object_type = p_obj_type ;
      CURSOR c_prod_exists(p_obj_id NUMBER, p_obj_type VARCHAR2) IS
        SELECT COUNT(1)
        FROM ams_act_products
        WHERE act_product_used_by_id = p_obj_id
        AND arc_act_product_used_by = p_obj_type;
      CURSOR c_geos_exists(p_obj_id NUMBER, p_obj_type VARCHAR2) IS
        SELECT COUNT(1)
        FROM ams_act_geo_areas
        WHERE act_geo_area_used_by_id = p_obj_id
        AND arc_act_geo_area_used_by = p_obj_type;
      CURSOR c_atch_exists(p_obj_id NUMBER, p_obj_type VARCHAR2) IS
        SELECT COUNT(1)
        FROM fnd_attached_documents
        WHERE entity_name = p_obj_type
        AND   pk1_value = p_obj_id ;
      CURSOR c_cell_exists(p_obj_id NUMBER, p_obj_type VARCHAR2) IS
        SELECT COUNT(1)
        FROM ams_act_market_segments
        WHERE act_market_segment_used_by_id = p_obj_id
        AND arc_act_market_segment_used_by = p_obj_type;
      CURSOR c_ptnr_exists(p_obj_id NUMBER, p_obj_type VARCHAR2) IS
        SELECT COUNT(1)
        FROM  AMS_ACT_PARTNERS
        WHERE act_partner_used_by_id = p_obj_id
        AND arc_act_partner_used_by = p_obj_type;
      l_tmp NUMBER;
   BEGIN
         IF p_obj_attribute = 'CSCH' THEN
            OPEN c_csch_exists(p_obj_id);
            FETCH c_csch_exists INTO l_tmp;
            CLOSE c_csch_exists;
            IF l_tmp > 0 THEN
               RETURN FND_API.G_TRUE;
            ELSE
               RETURN FND_API.G_FALSE;
            END IF;
         END IF;
         IF p_obj_attribute = 'MESG' THEN
            OPEN c_mesg_exists(p_obj_id, p_obj_type);
            FETCH c_mesg_exists INTO l_tmp;
            CLOSE c_mesg_exists;
            IF l_tmp > 0 THEN
               RETURN FND_API.G_TRUE;
            ELSE
               RETURN FND_API.G_FALSE;
            END IF;
         END IF;
         IF p_obj_attribute = 'ATCH' THEN
            OPEN c_atch_exists(p_obj_id, p_obj_type);
            FETCH c_atch_exists INTO l_tmp;
            IF l_tmp > 0 THEN
               RETURN FND_API.G_TRUE;
            ELSE
               RETURN FND_API.G_FALSE;
            END IF;
         END IF;
         IF p_obj_attribute = 'GEOS' THEN
            OPEN c_geos_exists(p_obj_id, p_obj_type);
            FETCH c_geos_exists INTO l_tmp;
            IF l_tmp > 0 THEN
               RETURN FND_API.G_TRUE;
            ELSE
               RETURN FND_API.G_FALSE;
            END IF;
         END IF;
         IF p_obj_attribute = 'DELV' THEN
            OPEN c_delv_exists(p_obj_id, p_obj_type);
            FETCH c_delv_exists INTO l_tmp;
            IF l_tmp > 0 THEN
               RETURN FND_API.G_TRUE;
            ELSE
               RETURN FND_API.G_FALSE;
            END IF;
         END IF;
         IF p_obj_attribute = 'PROD' THEN
            OPEN c_prod_exists(p_obj_id, p_obj_type);
            FETCH c_prod_exists INTO l_tmp;
            IF l_tmp > 0 THEN
               RETURN FND_API.G_TRUE;
            ELSE
               RETURN FND_API.G_FALSE;
            END IF;
         END IF;
         IF p_obj_attribute = 'CELL' THEN
            OPEN c_cell_exists(p_obj_id, p_obj_type);
            FETCH c_cell_exists INTO l_tmp;
            IF l_tmp > 0 THEN
               RETURN FND_API.G_TRUE;
            ELSE
               RETURN FND_API.G_FALSE;
            END IF;
         END IF;
         IF p_obj_attribute = 'PTNR' THEN
            OPEN c_ptnr_exists(p_obj_id, p_obj_type);
            FETCH c_ptnr_exists INTO l_tmp;
            IF l_tmp > 0 THEN
               RETURN FND_API.G_TRUE;
            ELSE
               RETURN FND_API.G_FALSE;
            END IF;
         END IF;

   END check_attrib_exists;

END;

/
