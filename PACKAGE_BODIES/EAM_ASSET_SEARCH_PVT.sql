--------------------------------------------------------
--  DDL for Package Body EAM_ASSET_SEARCH_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EAM_ASSET_SEARCH_PVT" as
/* $Header: EAMVASEB.pls 115.7 2003/05/05 02:13:31 lllin ship $ */

   -- Start of comments
   -- API name : BUILD_SEARCH_SQL
   -- Type     : Private
   -- Function :
   -- Pre-reqs : None.
   -- Parameters  :
   -- IN       p_api_version      IN NUMBER   Required
   --          p_init_msg_list    IN VARCHAR2 Optional  Default = FND_API.G_FALSE
   --          p_commit           IN VARCHAR2 Optional  Default = FND_API.G_FALSE
   --          p_validation_level IN NUMBER   Optional  Default = FND_API.G_VALID_LEVEL_FULL
   --
   --          p_application_id   IN NUMBER   Optional  Default = 401 (INV)
   --          p_descr_flexfield_name IN VARCHAR2 Opt   Default = 'MTL_EAM_ASSET_ATTR_VALUES'
   --          p_search_set_id    IN NUMBER
   --          p_where_clause     IN VARCHAR2
   --          p_purge_option     IN VARCHAR2 Optional  Default = FND_API.G_FALSE
   -- OUT      x_return_status   OUT   VARCHAR2(1)
   --          x_msg_count       OUT   NUMBER
   --          x_msg_data        OUT   VARCHAR2(2000)
   --
   --          x_sql_stmt        OUT     VARCHAR2
   -- Version  Initial version    1.0
   --
   -- Notes    : This API Build the dynamic SQL to retrieve the Asset Numbers based on
   --            extensible attributes criteria as identified by the search_set_id in
   --            mtl_eam_asset_search_temp table.
   -- ****** Sample Output statement of the API ***********
   --
   -- SELECT MAEAV.INVENTORY_ITEM_ID, MAEAV.SERIAL_NUMBER, MAEAV.ORGANIZATION_ID
   -- FROM MTL_EAM_ASSET_ATTR_VALUES MAEAV
   -- WHERE  MAEAV.ATTRIBUTE_CATEGORY LIKE  'Crane Physical Attributes'
   -- AND  MAEAV.C_ATTRIBUTE1 LIKE  '%d%'
   -- AND  MAEAV.D_ATTRIBUTE1 <= to_date('17-JUL-02','DD-MON-RR')
   -- INTERSECT
   -- SELECT MAEAV.INVENTORY_ITEM_ID, MAEAV.SERIAL_NUMBER, MAEAV.ORGANIZATION_ID
   -- FROM MTL_EAM_ASSET_ATTR_VALUES MAEAV
   -- WHERE  MAEAV.ATTRIBUTE_CATEGORY LIKE  'Office Space'
   -- AND  MAEAV.N_ATTRIBUTE1 > 2
   --
   -- ******** End Sample output **************************
   --
   -- End of comments

   g_pkg_name    CONSTANT VARCHAR2(30):= 'EAM_ASSET_SEARCH_PVT';


PROCEDURE BUILD_SEARCH_SQL
    (
    p_api_version               IN      NUMBER,
    p_init_msg_list             IN      VARCHAR2 := fnd_api.g_false,
    p_commit                    IN      VARCHAR2 := fnd_api.g_false,
    p_validation_level          IN      NUMBER   := fnd_api.g_valid_level_full,
    p_application_id            IN      NUMBER   := 401,
    p_descr_flexfield_name      IN      VARCHAR2 := 'MTL_EAM_ASSET_ATTR_VALUES',
    p_search_set_id             IN      NUMBER,
    p_where_clause              IN      VARCHAR2 := NULL,
    p_purge_option              IN      VARCHAR2 := fnd_api.g_false,
    x_sql_stmt                  OUT NOCOPY     VARCHAR2,
    x_return_status             OUT NOCOPY     VARCHAR2,
    x_msg_count                 OUT NOCOPY     NUMBER,
    x_msg_data                  OUT NOCOPY     VARCHAR2
    ) AS
      l_api_name       CONSTANT VARCHAR2(30) := 'build_search_sql';
      l_api_version    CONSTANT NUMBER       := 1.0;
      l_full_name      CONSTANT VARCHAR2(60)   := g_pkg_name || '.' || l_api_name;
      l_stmt_num                NUMBER;
      l_sql_stmt                VARCHAR2(30000);
      l_counter                 NUMBER;
      l_context                 VARCHAR2(30);
      l_context_counter         NUMBER;
      l_line_type_counter       NUMBER;

      CURSOR    context_cur IS
      SELECT    DISTINCT meast.descriptive_flex_context_code AS DESCR_CONTEXT_CODE
      FROM      MTL_EAM_ASSET_SEARCH_TEMP meast
      WHERE     meast.SEARCH_SET_ID = p_search_set_id;

      CURSOR    attribute_cur (l_context_code VARCHAR2, l_line_type NUMBER) IS
      SELECT    meast.end_user_column_name      END_USER_COLUMN_NAME,
                meast.operator                  OPERATOR,
                meast.line_type                 LINE_TYPE,
                meast.attribute_varchar2_value  ATTRIBUTE_VARCHAR2_VALUE,
                meast.attribute_number_value    ATTRIBUTE_NUMBER_VALUE,
                meast.attribute_date_value      ATTRIBUTE_DATE_VALUE
      FROM      MTL_EAM_ASSET_SEARCH_TEMP       meast
      WHERE     meast.SEARCH_SET_ID                   = p_search_set_id
      AND       meast.DESCRIPTIVE_FLEX_CONTEXT_CODE   = l_context_code
      AND       meast.line_type                       = l_line_type;

   BEGIN
	null;
/*
commented out this function body to obsolete this function.
The code of this function has been moved to EAMFANDF.fmb.

      -- Standard Start of API savepoint
      l_stmt_num    := 10;
      SAVEPOINT build_search_sql_pvt;

      l_stmt_num    := 20;
      -- Standard call to check for call compatibility.
      IF NOT fnd_api.compatible_api_call(
            l_api_version
           ,p_api_version
           ,l_api_name
           ,g_pkg_name) THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      l_stmt_num    := 30;
      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF fnd_api.to_boolean(p_init_msg_list) THEN
         fnd_msg_pub.initialize;
      END IF;

      l_stmt_num    := 40;
      --  Initialize API return status to success
      x_return_status := fnd_api.g_ret_sts_success;
      x_sql_stmt := NULL;
      l_sql_stmt := NULL;

      l_stmt_num    := 50;
      -- API body

      l_stmt_num    := 60;
      IF (p_application_id IS NULL OR p_descr_flexfield_name IS NULL
            OR p_search_set_id <= 0  OR p_search_set_id IS NULL) THEN

          fnd_message.set_name('EAM', 'EAM_INPUT_PARAMS_NULL');
          fnd_message.set_token('EAM_DEBUG',l_full_name||'('||l_stmt_num||')');
          fnd_msg_pub.add;
          l_sql_stmt := NULL;
          RAISE fnd_api.g_exc_error;
      END IF;

      l_context_counter := 0;
      l_counter         := 0;

      FOR l_context_cur IN context_cur LOOP

        l_stmt_num    := 70;

        l_context := l_context_cur.descr_context_code;

        l_context_counter := l_context_counter + 1;

--        IF (l_context_counter > 1) THEN
--
--            l_stmt_num    := 80;
--            l_sql_stmt := l_sql_stmt || ' INTERSECT ';
--        END IF;

        l_stmt_num    := 90;

--      l_sql_stmt := l_sql_stmt || 'SELECT MAEAV.INVENTORY_ITEM_ID, MAEAV.SERIAL_NUMBER, MAEAV.ORGANIZATION_ID'
        l_sql_stmt := l_sql_stmt || ' AND EXISTS (SELECT * '
                                 || ' '
                                 || 'FROM MTL_EAM_ASSET_ATTR_VALUES MAEAV WHERE ';

        l_stmt_num    := 100;
        l_sql_stmt := l_sql_stmt || ' MAEAV.ATTRIBUTE_CATEGORY LIKE '
                                 || ' '''
                                 || l_context
                                 || ''' ';

        l_stmt_num    := 110;
        FOR l_line_type_counter IN 1..3 LOOP


            l_stmt_num    := 120;
            FOR l_attribute_cur IN attribute_cur(l_context, l_line_type_counter) LOOP


              l_stmt_num    := 130;
              l_sql_stmt := l_sql_stmt  ||' AND '
                                        || ' MAEAV.'
                                        || UPPER(EAM_ASSET_SEARCH_PVT.get_attribute_column_name
                                            (
                                                p_application_id,
                                                p_descr_flexfield_name,
                                                l_context,
                                                l_attribute_cur.end_user_column_name
                                            ))
                                        || ' '
                                        || NVL(l_attribute_cur.operator, 'LIKE')
                                        || ' ';


              l_stmt_num    := 140;
              IF(l_line_type_counter = 1) THEN
                  l_stmt_num    := 142;
                  l_sql_stmt := l_sql_stmt || ' '''
                                           || l_attribute_cur.attribute_varchar2_value
                                           || '''  ';
              ELSIF(l_line_type_counter = 2) THEN
                  l_stmt_num    := 144;
                  l_sql_stmt := l_sql_stmt || l_attribute_cur.attribute_number_value;
              ELSIF(l_line_type_counter = 3) THEN
                  l_stmt_num    := 146;
                  l_sql_stmt := l_sql_stmt || 'to_date('''
                                           || l_attribute_cur.attribute_date_value
                                           ||''',''DD-MON-RR'') ';
              END IF;

            END LOOP; -- end attribute Loop

         END LOOP; -- end line type loop

              l_sql_stmt := l_sql_stmt  ||' AND MAEAV.INVENTORY_ITEM_ID = mtl_eam_asset_numbers_all_v.INVENTORY_ITEM_ID ';
              l_sql_stmt := l_sql_stmt  ||' AND MAEAV.SERIAL_NUMBER = mtl_eam_asset_numbers_all_v.SERIAL_NUMBER ';
              l_sql_stmt := l_sql_stmt  ||' AND MAEAV.ORGANIZATION_ID = mtl_eam_asset_numbers_all_v.CURRENT_ORGANIZATION_ID ';
              l_sql_stmt := l_sql_stmt  ||' ) ';

       END LOOP; -- end context loop


      l_counter := 0;

      l_stmt_num    := 150;
      -- Purge Search Criteria from Temp table
      IF fnd_api.to_boolean(p_purge_option) THEN
         DELETE    MTL_EAM_ASSET_SEARCH_TEMP
         WHERE     SEARCH_SET_ID      = p_search_set_id;
      END IF;


     -- Debug purposes only
     --FOR l_counter IN 1..125  LOOP
     -- dbms_output.put_line (substr(l_sql_stmt, (240*(l_counter-1))+1, (240*(l_counter))));
     --END LOOP;


     l_stmt_num    := 160;
     x_sql_stmt := l_sql_stmt;


     l_stmt_num    := 998;

       -- End of API body.
      -- Standard check of p_commit.
      IF fnd_api.to_boolean(p_commit) THEN
         COMMIT WORK;
      END IF;

      l_stmt_num    := 999;
      -- Standard call to get message count and if count is 1, get message info.
      fnd_msg_pub.count_and_get(
         p_encoded => fnd_api.g_false
        ,p_count => x_msg_count
        ,p_data => x_msg_data);


   EXCEPTION
      WHEN fnd_api.g_exc_error THEN
         ROLLBACK TO build_search_sql_pvt;
         x_return_status := fnd_api.g_ret_sts_error;
         x_sql_stmt := l_sql_stmt;
         fnd_msg_pub.count_and_get(
            p_encoded => fnd_api.g_false
           ,p_count => x_msg_count
           ,p_data => x_msg_data);
      WHEN fnd_api.g_exc_unexpected_error THEN
         ROLLBACK TO build_search_sql_pvt;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         x_sql_stmt := l_sql_stmt;
         fnd_msg_pub.count_and_get(
            p_encoded => fnd_api.g_false
           ,p_count => x_msg_count
           ,p_data => x_msg_data);
      WHEN OTHERS THEN
         ROLLBACK TO build_search_sql_pvt;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         x_sql_stmt := l_sql_stmt;

         IF fnd_msg_pub.check_msg_level(
               fnd_msg_pub.g_msg_lvl_unexp_error) THEN
            fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name||'('||l_stmt_num||')');
         END IF;

         fnd_msg_pub.count_and_get(
            p_encoded => fnd_api.g_false
           ,p_count => x_msg_count
           ,p_data => x_msg_data);

*/
END build_search_sql;





   -- Start of comments
   -- API name :
   -- Type     : Private
   -- Function : GET_ATTRIBUTE_COLUMN_NAME
   -- Pre-reqs : None.
   -- Parameters  :
   -- IN
   --          p_application_id         IN NUMBER   Optional  Default = 401 (INV)
   --          p_descr_flexfield_name   IN VARCHAR2 Opt   Default = 'MTL_EAM_ASSET_ATTR_VALUES'
   --          p_descr_flex_context_code IN VARCHAR2 Required
   --          p_end_user_column_name   IN VARCHAR2 Required
   --
   -- RETURNS  VARCHAR2

   --
   -- Notes    : This function returns the column name where a specific attribute value
   --            is stored in table MTL_EAM_ASSET_ATTR_VALUES based on flexfield metadata
   --
   -- End of comments


FUNCTION get_attribute_column_name
    (
    p_application_id            IN      NUMBER   := 401,
    p_descr_flexfield_name      IN      VARCHAR2 := 'MTL_EAM_ASSET_ATTR_VALUES',
    p_descr_flex_context_code   IN      VARCHAR2,
    p_end_user_column_name      IN      VARCHAR2
    )
RETURN VARCHAR2 IS
    l_application_column_name   VARCHAR2(30);
    l_stmt_num                  NUMBER;
    l_api_name                  VARCHAR2(30) := 'get_attribute_column_name';
BEGIN

    l_stmt_num := 10;
    l_application_column_name := NULL;

    BEGIN

        l_stmt_num := 20;

        SELECT  application_column_name
        INTO    l_application_column_name
        FROM    FND_DESCR_FLEX_COLUMN_USAGES fdfcu
        WHERE   fdfcu.APPLICATION_ID                = p_application_id
        AND     fdfcu.DESCRIPTIVE_FLEXFIELD_NAME    = p_descr_flexfield_name
        AND     fdfcu.DESCRIPTIVE_FLEX_CONTEXT_CODE = p_descr_flex_context_code
        AND     fdfcu.end_user_column_name          = p_end_user_column_name;
    EXCEPTION
        WHEN OTHERS THEN
            l_application_column_name := NULL;
            fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name||'('||l_stmt_num||')');
            RETURN l_application_column_name;
    END;

    RETURN l_application_column_name;

END get_attribute_column_name;


END EAM_ASSET_SEARCH_PVT;


/
