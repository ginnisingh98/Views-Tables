--------------------------------------------------------
--  DDL for Package Body EAM_ASSET_ATTR_IMPORT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EAM_ASSET_ATTR_IMPORT_PVT" AS
/* $Header: EAMVAAIB.pls 120.2 2005/08/30 02:53:53 kmurthy noship $*/
   -- Start of comments
   -- API name : import_asset_attr_values
   -- Type     : Private
   -- Function :
   -- Pre-reqs : None.
   -- Parameters  :
   -- IN       p_api_version      IN NUMBER   Required
   --          p_init_msg_list    IN VARCHAR2 Optional  Default = FND_API.G_FALSE
   --          p_commit           IN VARCHAR2 Optional  Default = FND_API.G_FALSE
   --          p_validation_level IN NUMBER   Optional  Default = FND_API.G_VALID_LEVEL_FULL
   --
   --          p_interface_header_id        IN      NUMBER Required,
   --          p_purge_option     IN VARCHAR2 Optional  Default = 'N'
   --
   -- OUT      x_return_status   OUT   VARCHAR2(1)
   --          x_msg_count       OUT   NUMBER
   --          x_msg_data        OUT   VARCHAR2(2000)
   --
   --          x_sql_stmt        OUT     VARCHAR2
   -- Version  Initial version    1.0     Anirban Dey
   --
   -- Notes    : This private API imports extensible asset attributes values into
   --            MTL_EAM_ASET_ATTR_VALUES
   --
   --
   -- End of comments

   g_pkg_name    CONSTANT VARCHAR2(30):= 'EAM_ASSET_ATTR_VALUES_PVT';

  -- global variable to turn on/off debug logging.


PROCEDURE import_asset_attr_values
    (
    p_api_version               IN      NUMBER,
    p_init_msg_list             IN      VARCHAR2 := fnd_api.g_false,
    p_commit                    IN      VARCHAR2 := fnd_api.g_false,
    p_validation_level          IN      NUMBER   := fnd_api.g_valid_level_full,
    p_interface_header_id	IN	NUMBER,
    p_import_mode		IN	NUMBER,
    p_purge_option              IN      VARCHAR2 := fnd_api.g_false,
    x_return_status             OUT NOCOPY     VARCHAR2,
    x_msg_count                 OUT NOCOPY     NUMBER,
    x_msg_data                  OUT NOCOPY     VARCHAR2
    ) IS

      l_api_name       CONSTANT VARCHAR2(30) := 'import_asset_attr_values';
      l_api_version    CONSTANT NUMBER       := 1.0;
      --l_full_name      CONSTANT VARCHAR2(60) := g_pkg_name || '.' || l_api_name;
      l_stmt_generated          VARCHAR2(1);
      CUR                       INTEGER;
      RET                       INTEGER;
      l_sql_stmt1               VARCHAR2(2000);
      l_miss_attr_value         VARCHAR2(150);
      l_concatenated_segments   VARCHAR2(2000);
      l_temp_varchar2           VARCHAR2(2000);
      l_exists_count            NUMBER;

      l_application_id              CONSTANT    NUMBER       := 401;
      l_application_code            CONSTANT    VARCHAR2(3)  := 'INV';
      l_descriptive_flexfield_name  CONSTANT    VARCHAR2(30) := 'MTL_EAM_ASSET_ATTR_VALUES';

      l_init_msg_list                           VARCHAR2(1) := fnd_api.g_false;
      l_commit                                  VARCHAR2(1) := fnd_api.g_false;
      l_validation_level                        NUMBER   := fnd_api.g_valid_level_full;
      l_rowid                                   urowid;
      l_association_id                          number;
      l_inventory_item_id                       number;
      l_serial_number                           varchar2(30);
      l_organization_id                         number;
      l_object_id 				number;
      l_attribute_category                      varchar2(30);

      l_request_id                              number;
      l_program_application_id                  number;
      l_program_id                              number;
      l_program_update_date                     date;
      l_last_update_date                        date := sysdate;
      l_last_updated_by                         number := FND_GLOBAL.USER_ID;
      l_creation_date                           date := sysdate;
      l_created_by                              number := FND_GLOBAL.USER_ID;
      l_last_update_login                       number := FND_GLOBAL.LOGIN_ID;
      l_return_status                           varchar2(1);
      l_msg_count                               number;
      l_msg_data                                varchar2(240);
      l_instance_number				varchar2(30);
      l_instance_id				number;

      l_module           varchar2(200) ;
      l_log_level CONSTANT NUMBER := fnd_log.g_current_runtime_level;
      l_uLog CONSTANT BOOLEAN := fnd_log.level_unexpected >= l_log_level;
      l_exLog CONSTANT BOOLEAN := l_uLog AND fnd_log.level_exception >= l_log_level;
      l_pLog CONSTANT BOOLEAN := l_uLog AND fnd_log.level_procedure >= l_log_level;
      l_sLog CONSTANT BOOLEAN := l_pLog AND fnd_log.level_statement >= l_log_level;


      attr_import_failed                        EXCEPTION;

      TYPE varchar_table IS TABLE OF varchar2(150)
                        INDEX BY BINARY_INTEGER;
      TYPE number_table IS TABLE OF number
                        INDEX BY BINARY_INTEGER;
      TYPE date_table IS TABLE OF date
                        INDEX BY BINARY_INTEGER;
      TYPE CurTyp IS REF CURSOR;
      CUROBJ CurTyp;
      p_i               integer;
      p_ncols           integer;

      l_c_attribute     varchar_table;
      l_d_attribute     date_table;
      l_n_attribute     number_table;

      p_substr          varchar(2);
      p_substr1         varchar(1);
      p_num             integer := null;

    -- Cursor for the Asset Number in this processing group and  Header

      CURSOR  asset_numbers_cur IS
      SELECT  instance_number
      FROM    MTL_EAM_ASSET_NUM_INTERFACE meani
      WHERE   meani.interface_header_id = p_interface_header_id
      ;

    -- Cursor for all attribute Group in this processing group
      CURSOR  attr_group_cur IS
      SELECT  DISTINCT meavi.application_id,
              meavi.descriptive_flexfield_name,
              meavi.attribute_category,
              meavi.association_id
      FROM    MTL_EAM_ATTR_VAL_INTERFACE meavi
      WHERE   meavi.interface_header_id   = p_interface_header_id
        AND   meavi.process_status = 'P';

    -- Cursor for every attribute in this processing group
      CURSOR  attr_cur        (
                              l_application_id            NUMBER,
                              l_descr_flexfield_name      VARCHAR2,
                              l_descr_flex_context_code   VARCHAR2) IS
      SELECT  meavi.application_column_name,
              meavi.line_type,
              meavi.attribute_varchar2_value,
              meavi.attribute_number_value,
              meavi.attribute_date_value
      FROM    MTL_EAM_ATTR_VAL_INTERFACE meavi
      WHERE   meavi.interface_header_id   = p_interface_header_id
      AND     meavi.application_id        = l_application_id
      AND     meavi.descriptive_flexfield_name = l_descr_flexfield_name
      AND     meavi.attribute_category = l_descr_flex_context_code
      AND     meavi.process_status = 'P';

    -- Cursor for missing attribute values in the Interface Table
      CURSOR  missing_attr_cur
                              (
                              l_application_id            NUMBER,
                              l_descr_flexfield_name      VARCHAR2,
                              l_descr_flex_context_code   VARCHAR2) IS
      SELECT  fdfcu.application_column_name
      FROM    fnd_descr_flex_column_usages fdfcu
      WHERE   fdfcu.descriptive_flexfield_name = l_descr_flexfield_name
      AND     fdfcu.descriptive_flex_context_code = l_descr_flex_context_code
      AND     fdfcu.application_id = l_application_id
      AND     fdfcu.application_column_name
              NOT IN
                      (SELECT meavi.application_column_name
                      FROM    mtl_eam_attr_val_interface meavi
                      WHERE   meavi.interface_header_id   = p_interface_header_id
                      AND     meavi.application_id        = l_application_id
                      AND     meavi.descriptive_flexfield_name = l_descr_flexfield_name
                      AND     meavi.attribute_category = l_descr_flex_context_code
                      AND     meavi.process_status = 'P');

    BEGIN
      if(l_ulog) then
	      l_module := 'eam.plsql.'||g_pkg_name|| '.' || l_api_name;
      end if;
  	-- bug 2834438

      IF  (l_plog) THEN
          FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module, '===== Entering EAM_ASSET_ATTR_IMPORT_PVT.import_asset_attr_values =====');
      END IF;

      -- Standard Start of API savepoint
      SAVEPOINT import_asset_attr_values_pvt;

      -- Standard call to check for call compatibility.
      IF NOT fnd_api.compatible_api_call(
            l_api_version
           ,p_api_version
           ,l_api_name
           ,g_pkg_name) THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF fnd_api.to_boolean(p_init_msg_list) THEN
         fnd_msg_pub.initialize;
      END IF;

      --  Initialize API return status to success
      x_return_status := fnd_api.g_ret_sts_success;



      -- 2002-01-02: chrng: To fix bug 2167188, check that derived columns are NULL.
        UPDATE    MTL_EAM_ATTR_VAL_INTERFACE      meavi
        SET       meavi.error_number = 9999,
                  meavi.process_status = 'E',
                  meavi.error_message = 'Derived column APPLICATION_ID should be NULL'
        WHERE     meavi.interface_header_id = p_interface_header_id
        AND       meavi.process_status = 'P'
        AND       meavi.application_id IS NOT NULL;

        UPDATE    MTL_EAM_ATTR_VAL_INTERFACE      meavi
        SET       meavi.error_number = 9999,
                  meavi.process_status = 'E',
                  meavi.error_message = 'Derived column DESCRITIVE_FLEXFIELD_NAME should be NULL'
        WHERE     meavi.interface_header_id = p_interface_header_id
        AND       meavi.process_status = 'P'
        AND       meavi.descriptive_flexfield_name IS NOT NULL;

        UPDATE    MTL_EAM_ATTR_VAL_INTERFACE      meavi
        SET       meavi.error_number = 9999,
                  meavi.process_status = 'E',
                  meavi.error_message = 'Derived column APPLICATION_COLUMN_NAME should be NULL'
        WHERE     meavi.interface_header_id = p_interface_header_id
        AND       meavi.process_status = 'P'
        AND       meavi.application_column_name IS NOT NULL;

        UPDATE    MTL_EAM_ATTR_VAL_INTERFACE      meavi
        SET       meavi.error_number = 9999,
                  meavi.process_status = 'E',
                  meavi.error_message = 'Derived column ASSOCIATION_ID should be NULL'
        WHERE     meavi.interface_header_id = p_interface_header_id
        AND       meavi.process_status = 'P'
        AND       meavi.association_id IS NOT NULL;


      -- Update all rows for this set with proper application_id and Desc Flex Name

        UPDATE    MTL_EAM_ATTR_VAL_INTERFACE      meavi
        SET       meavi.application_id = l_application_id,
                  meavi.descriptive_flexfield_name = l_descriptive_flexfield_name
        WHERE     meavi.interface_header_id = p_interface_header_id
        AND       meavi.process_status = 'P';

      -- validate flexfield details from Desc FlexField Column Usages Table

        UPDATE    MTL_EAM_ATTR_VAL_INTERFACE      meavi
        SET       meavi.error_number = 9999,
                  meavi.process_status = 'E',
                  meavi.error_message = 'Decriptive Flexfield Details are Invalid'
        WHERE     meavi.interface_header_id = p_interface_header_id
        AND       meavi.process_status = 'P'
        AND       NOT EXISTS
                  (SELECT 'S'
                  FROM    FND_DESCR_FLEX_COLUMN_USAGES    mdfcu
                  WHERE   meavi.application_id =  mdfcu.application_id
                  AND     meavi.descriptive_flexfield_name = mdfcu.descriptive_flexfield_name
                  AND     meavi.attribute_category = mdfcu.descriptive_flex_context_code
                  AND     meavi.end_user_column_name  = mdfcu.end_user_column_name
                  AND     meavi.application_id = l_application_id
                  AND     meavi.descriptive_flexfield_name = l_descriptive_flexfield_name
                  AND     meavi.interface_header_id = p_interface_header_id);

     -- Obtain the application column name for each row in the interface table

        UPDATE    MTL_EAM_ATTR_VAL_INTERFACE      meavi
        SET       meavi.application_column_name = EAM_ASSET_SEARCH_PVT.GET_ATTRIBUTE_COLUMN_NAME
                                                 (meavi.application_id,
                                                  meavi.descriptive_flexfield_name,
                                                  meavi.attribute_category,
                                                  meavi.end_user_column_name
                                                 )
         WHERE    meavi.interface_header_id = p_interface_header_id
         AND      meavi.process_status = 'P';

      -- Mark rows as error is application column name is NULL

        UPDATE    MTL_EAM_ATTR_VAL_INTERFACE      meavi
        SET       meavi.error_number = 9999,
                  meavi.process_status = 'E',
                  meavi.error_message = 'Application Column Name not found'
        WHERE     meavi.interface_header_id = p_interface_header_id
        AND       meavi.process_status = 'P'
        AND       meavi.application_column_name IS NULL;

      -- Obtain associationId if available from asset atribute groups table

        UPDATE    MTL_EAM_ATTR_VAL_INTERFACE      meavi
        SET       (meavi.association_id) =
                  (SELECT  meaag.association_id
                   FROM    MTL_EAM_ASSET_ATTR_GROUPS meaag,
                           MTL_EAM_ASSET_NUM_INTERFACE meani
                   WHERE   meani.inventory_item_id            = meaag.inventory_item_id
                   AND     meani.interface_header_id          = meavi.interface_header_id
                   AND     meavi.application_id               = meaag.application_id
                   AND     meavi.descriptive_flexfield_name   = meaag.descriptive_flexfield_name
                   AND     meavi.attribute_category           = meaag.descriptive_flex_context_code
                   AND     UPPER(NVL(meaag.enabled_flag,'Y')) = 'Y')
        WHERE      meavi.interface_header_id = p_interface_header_id
        AND        meavi.process_status = 'P';

      -- 2001-12-28: chrng: To fix bug 2156429, flag rows without association_id
      --                    (Attribute Group not associated with Asset Group) as Error.
        UPDATE    MTL_EAM_ATTR_VAL_INTERFACE      meavi
        SET       meavi.error_number = 9999,
                  meavi.process_status = 'E',
                  meavi.error_message = 'Attribute Group not associated with Asset Group'
        WHERE     meavi.interface_header_id = p_interface_header_id
        AND       meavi.process_status = 'P'
        AND       meavi.association_id IS NULL;


      -- 2001-12-26: chrng: To fix bug 2156483, check line_type not out-of-range
      -- Validate line_type
      UPDATE      MTL_EAM_ATTR_VAL_INTERFACE      meavi
        SET       meavi.error_number = 9999,
                  meavi.process_status = 'E',
                  meavi.error_message = 'line_type must be 1 (VARCHAR2), 2 (NUMBER), or 3 (DATE)'
        WHERE     meavi.interface_header_id = p_interface_header_id
        AND       meavi.process_status = 'P'
        AND       meavi.line_type NOT IN (1, 2, 3);

      -- Open loop for all asset numbers in this processing group


      FOR asset IN asset_numbers_cur LOOP

        IF (l_slog) THEN
          -- bug 2834438
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module,'(asset_number_cur)asset.instance_number='||asset.instance_number);
        END IF;

        -- Open loop for all attribute groups for an Asset Number
          FOR attr_group IN  attr_group_cur
          LOOP

	    IF (l_slog) THEN
	         -- bug 2834438
                 FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module, '(attr_group_cur)attr_group.application_id=' || attr_group.application_id);
                 FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module, '(attr_group_cur)attr_group.descriptive_flexfield_name=' ||
							attr_group.descriptive_flexfield_name);
                 FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module, '(attr_group_cur)attr_group.attribute_category=' || attr_group.attribute_category);
		 FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module, '(attr_group_cur)attr_group.association_id=' || attr_group.association_id);

            END IF;

            l_stmt_generated := 'S';

            l_association_id := attr_group.association_id;
            l_instance_number := asset.instance_number;
            l_attribute_category := attr_group.attribute_category;

            select instance_id into l_instance_id from csi_item_instances where instance_number = l_instance_number;


            -- 2002-01-11: chrng: Fixed bug 2180770.
	    -- Check if Attribute has not existed (for Create Mode), or exists (for Update Mode)
            IF (p_import_mode = 0) THEN -- Create Mode

                -- before executing create, make sure that duplicate do not exists.
                SELECT  count(*)
                INTO    l_exists_count
                FROM    MTL_EAM_ASSET_ATTR_VALUES meaav
                WHERE   meaav.maintenance_object_type = 3
                AND	meaav.maintenance_object_id = l_instance_id
                AND     meaav.application_id        = attr_group.application_id
                AND     meaav.descriptive_flexfield_name = attr_group.descriptive_flexfield_name
                AND     meaav.attribute_category = attr_group.attribute_category;

                IF (l_exists_count >= 1 ) THEN

                    UPDATE  mtl_eam_attr_val_interface meavi
                    SET     meavi.process_status = 'E',
                            meavi.error_number = 9999,
                            meavi.error_message = 'Attribute Group Already exists'
                    WHERE   meavi.interface_header_id   = p_interface_header_id
                    AND     meavi.application_id        = attr_group.application_id
                    AND     meavi.descriptive_flexfield_name = attr_group.descriptive_flexfield_name
                    AND     meavi.attribute_category = attr_group.attribute_category
                    AND     meavi.process_status = 'P';

                    l_stmt_generated := 'E';

                END IF;

            ELSIF (p_import_mode = 1) THEN -- Update Mode

                BEGIN
                    SELECT  meaav.rowid
                    INTO    l_rowid
                    FROM    MTL_EAM_ASSET_ATTR_VALUES meaav
                    WHERE   meaav.maintenance_object_type = 3
                    AND	    meaav.maintenance_object_id = l_instance_id
                    AND     meaav.application_id        = attr_group.application_id
                    AND     meaav.descriptive_flexfield_name = attr_group.descriptive_flexfield_name
                    AND     meaav.attribute_category = attr_group.attribute_category;

                EXCEPTION
                    -- 2001-12-24: chrng: to fix bug 2157642
                    -- Error if Attribute Group does not exist
                    WHEN NO_DATA_FOUND
                    THEN

                      UPDATE  mtl_eam_attr_val_interface meavi
                      SET     meavi.process_status = 'E',
                              meavi.error_number = 9999,
                              meavi.error_message = 'Attribute Group does not exist'
                      WHERE   meavi.interface_header_id   = p_interface_header_id
                      AND     meavi.application_id        = attr_group.application_id
                      AND     meavi.descriptive_flexfield_name = attr_group.descriptive_flexfield_name
                      AND     meavi.attribute_category = attr_group.attribute_category
                      AND     meavi.process_status = 'P';

                      l_stmt_generated := 'E';

                END; -- BEGIN, EXCEPTION, END block

            ELSE
                -- Neither Import or Update Mode
                -- Should not occur, checked in EAMVANIB.pls
                NULL;
            END IF;

	-- bug 2834438
      -- Initialize
      p_ncols := 20;
        FOR p_i in 1..p_ncols LOOP
               l_c_attribute(p_i) := '';
        END LOOP;

      p_ncols := 10;
        FOR p_i in 1..p_ncols	LOOP
               l_d_attribute(p_i) := null;
               l_n_attribute(p_i) := null;
        END LOOP;

 /* Bug 3371507
        IF(p_import_mode = 1) THEN
               l_c_attribute(1)   := fnd_api.g_miss_char;
               l_c_attribute(2)   := fnd_api.g_miss_char;
               l_c_attribute(3)   := fnd_api.g_miss_char;
               l_c_attribute(4)   := fnd_api.g_miss_char;
               l_c_attribute(5)   := fnd_api.g_miss_char;
               l_c_attribute(6)   := fnd_api.g_miss_char;
               l_c_attribute(7)   := fnd_api.g_miss_char;
               l_c_attribute(8)   := fnd_api.g_miss_char;
               l_c_attribute(9)   := fnd_api.g_miss_char;
               l_c_attribute(10)  := fnd_api.g_miss_char;
               l_c_attribute(11)  := fnd_api.g_miss_char;
               l_c_attribute(12)  := fnd_api.g_miss_char;
               l_c_attribute(13)  := fnd_api.g_miss_char;
               l_c_attribute(14)  := fnd_api.g_miss_char;
               l_c_attribute(15)  := fnd_api.g_miss_char;
               l_c_attribute(16)  := fnd_api.g_miss_char;
               l_c_attribute(17)  := fnd_api.g_miss_char;
               l_c_attribute(18)  := fnd_api.g_miss_char;
               l_c_attribute(19)  := fnd_api.g_miss_char;
               l_c_attribute(20)  := fnd_api.g_miss_char;
               l_d_attribute(1)   := fnd_api.g_miss_date;
               l_d_attribute(2)   := fnd_api.g_miss_date;
               l_d_attribute(3)   := fnd_api.g_miss_date;
               l_d_attribute(4)   := fnd_api.g_miss_date;
               l_d_attribute(5)   := fnd_api.g_miss_date;
               l_d_attribute(6)   := fnd_api.g_miss_date;
               l_d_attribute(7)   := fnd_api.g_miss_date;
               l_d_attribute(8)   := fnd_api.g_miss_date;
               l_d_attribute(9)   := fnd_api.g_miss_date;
               l_d_attribute(10)  := fnd_api.g_miss_date;
               l_n_attribute(1)   := fnd_api.g_miss_num;
               l_n_attribute(2)   := fnd_api.g_miss_num;
               l_n_attribute(3)   := fnd_api.g_miss_num;
               l_n_attribute(4)   := fnd_api.g_miss_num;
               l_n_attribute(5)   := fnd_api.g_miss_num;
               l_n_attribute(6)   := fnd_api.g_miss_num;
               l_n_attribute(7)   := fnd_api.g_miss_num;
               l_n_attribute(8)   := fnd_api.g_miss_num;
               l_n_attribute(9)   := fnd_api.g_miss_num;
               l_n_attribute(10)  := fnd_api.g_miss_num;
      END IF;
*/

            -- Initialize the server side flex validation API with context value
              FND_FLEX_DESCVAL.set_context_value(attr_group.attribute_category);

              FOR num_v_attr_col IN 1..20
              LOOP
                fnd_flex_descval.set_column_value('C_ATTRIBUTE' || TO_CHAR(num_v_attr_col), '');
              END LOOP;
              FOR num_nd_attr_col IN 1..10
              LOOP
                fnd_flex_descval.set_column_value('N_ATTRIBUTE' || TO_CHAR(num_nd_attr_col), TO_NUMBER(NULL));
                fnd_flex_descval.set_column_value('D_ATTRIBUTE' || TO_CHAR(num_nd_attr_col), TO_DATE(NULL));
	      END LOOP;

            -- Open loop for all attributes for an attribute group of an asset number
              FOR attr IN attr_cur
                            (
                            attr_group.application_id,
                            attr_group.descriptive_flexfield_name,
                            attr_group.attribute_category
                            ) LOOP

  	        IF (l_slog) THEN
	          -- bug 2834438
                   FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module, '(attr_cur)attr.application_column_name=' || attr.application_column_name);
                   FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module, '(attr_cur)attr.line_type=' || attr.line_type);
                   FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module, '(attr_cur)attr.attribute_varchar2_value=' || attr.attribute_varchar2_value);
                   FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module, '(attr_cur)attr.attribute_number_value=' || attr.attribute_number_value);
	     	   FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module, '(attr_cur)attr.attribute_date_value=' || attr.attribute_date_value);
                END IF;


               p_substr := substr(attr.application_column_name,-1,1);
               p_substr1 := substr(attr.application_column_name,-2,1);

                IF ((p_substr1 = '1') OR (p_substr1 = '2')) THEN
                     p_substr := p_substr1 || p_substr;
               END IF;

               p_num := to_number(p_substr);

		IF (l_slog) THEN
	          -- bug 2834438
                   FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module, 'p_num=' || p_num);
                END IF;


                IF (attr.line_type = 1) THEN
                    l_c_attribute(p_num) := attr.attribute_varchar2_value;

                    fnd_flex_descval.set_column_value(attr.application_column_name,
                                                      attr.attribute_varchar2_value);
                ELSIF (attr.line_type = 2) THEN
                    l_n_attribute(p_num) := attr.attribute_number_value;
                    fnd_flex_descval.set_column_value(attr.application_column_name,
                                                      TO_NUMBER(attr.attribute_number_value));

                ELSIF (attr.line_type = 3) THEN
                   l_d_attribute(p_num)	:= attr.attribute_date_value;
		   -- Bug # 3373134
                   fnd_flex_descval.set_column_value(attr.application_column_name,
                                                     TO_DATE(TO_CHAR(attr.attribute_date_value, 'yyyy-mm-dd'),'yyyy-mm-dd'));
                END IF;

           END LOOP; -- End loop for attributes


           IF ( p_import_mode = 1) THEN -- Update Mode
                -- Populate flex validation API with segment values that are missing
                -- in the interface table from the base table mtl_eam_asset_attr_values

                FOR missing_attr IN missing_attr_cur
                            (
                            attr_group.application_id,
                            attr_group.descriptive_flexfield_name,
                            attr_group.attribute_category
                            ) LOOP



                    -- Bug: 2094907, added the following to remove DBMS_SQL
                    BEGIN
                          -- Bug # 3373134
			  IF (SUBSTR(missing_attr.application_column_name, 1, 1) = 'D') THEN
                            l_sql_stmt1 := 'SELECT to_char(meaav.'|| missing_attr.application_column_name ||', ''yyyy-mm-dd'')' ;
			  ELSE
		            l_sql_stmt1 := 'SELECT meaav.'|| missing_attr.application_column_name ;
                          END IF;
			  l_sql_stmt1 := l_sql_stmt1    || ' FROM MTL_EAM_ASSET_ATTR_VALUES meaav '
		                                        || ' WHERE meaav.maintenance_object_type =3 and maintenance_object_id =  :instance_id '
		                                        || ' AND meaav.application_id = :application_id '
		                                        || ' AND meaav.descriptive_flexfield_name = :descriptive_flexfield_name '
		                                        || ' AND meaav.attribute_category = :attribute' ;
		           --EXECUTE IMMEDIATE curobj USING asset.serial_number, asset.inventory_item_id,asset.organization_id, attr_group.application_id,attr_group.descriptive_flexfield_name, attr_group.attribute_category;

                           OPEN    curobj
                           FOR     l_sql_stmt1
                           USING   l_instance_id,
                                   attr_group.application_id,
                                   attr_group.descriptive_flexfield_name,
                                   attr_group.attribute_category;
		           -- Initialize the server side flex validation API with context value
		           LOOP
		                   FETCH curobj INTO l_miss_attr_value;
		                   EXIT WHEN curobj%NOTFOUND;

                                   -- 2002-01-11: chrng: Fixed bug 2181053.
                                   -- Have to rely on the naming of the column to determine its type
                                   IF (SUBSTR(missing_attr.application_column_name, 1, 1) = 'C') THEN
               		             fnd_flex_descval.set_column_value(missing_attr.application_column_name,
                                                                       l_miss_attr_value);
                                   ELSIF (SUBSTR(missing_attr.application_column_name, 1, 1) = 'N') THEN
               		             fnd_flex_descval.set_column_value(missing_attr.application_column_name,
                                                                       TO_NUMBER(l_miss_attr_value));
                                   -- Bug # 3373134
                                   ELSIF (SUBSTR(missing_attr.application_column_name, 1, 1) = 'D') THEN
               		             fnd_flex_descval.set_column_value(missing_attr.application_column_name,
                                                                       TO_DATE(l_miss_attr_value, 'yyyy-mm-dd'));
                                   END IF;

		           END LOOP;
		           CLOSE curobj;

                     END;

                END LOOP; -- Loop for missing flexfield attribute columns

           END IF; -- End if UPDATE mode

            -- Call to validate descriptive flex values using value sets
            IF (NOT FND_FLEX_DESCVAL.validate_desccols(l_application_code,
                                                       l_descriptive_flexfield_name,
                                                       'I',
                                                       SYSDATE)) THEN

                -- Value Set  validation failed, mark rows as error
                UPDATE  mtl_eam_attr_val_interface meavi
                SET     meavi.process_status = 'E',
                        meavi.error_number = 9999,
                        meavi.error_message = FND_FLEX_DESCVAL.error_message
                WHERE   meavi.interface_header_id   = p_interface_header_id
                AND     meavi.application_id        = attr_group.application_id
                AND     meavi.descriptive_flexfield_name = attr_group.descriptive_flexfield_name
                AND     meavi.attribute_category = attr_group.attribute_category
                AND     meavi.process_status = 'P';

                l_stmt_generated := 'E';

--            ELSE
                -- commented the following by sraval as this statement raises exception
                -- l_concatenated_segments := FND_FLEX_DESCVAL.concatenated_ids;

            END IF; -- end value valid


            -- Check if any attribute has failed. Even if one has failed, don't insert/update row.
            DECLARE
               CURSOR failed_meavi_row_cur IS
                  SELECT meavi.interface_line_id
                  FROM   mtl_eam_attr_val_interface meavi
                  WHERE   meavi.interface_header_id = p_interface_header_id
                  AND     meavi.application_id        = attr_group.application_id
                  AND     meavi.descriptive_flexfield_name = attr_group.descriptive_flexfield_name
                  AND     meavi.attribute_category   = attr_group.attribute_category
                  AND     meavi.process_status = 'E'
                  AND     meavi.error_number IS NOT NULL;

               failed_meavi_row_rec failed_meavi_row_cur%ROWTYPE;

            BEGIN
               OPEN failed_meavi_row_cur;
               FETCH failed_meavi_row_cur INTO failed_meavi_row_rec;
               IF failed_meavi_row_cur%FOUND
               THEN
                  -- some row has failed, don't insert/update row
                  l_stmt_generated := 'E';
               END IF;

		-- To fix bug 2834438
		CLOSE failed_meavi_row_cur;

            EXCEPTION
               WHEN OTHERS
               THEN
                  IF failed_meavi_row_cur%ISOPEN
                  THEN
                     CLOSE failed_meavi_row_cur;
                  END IF;

		IF (l_exlog) THEN
	          -- bug 2834438
                   FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION, l_module, 'FETCH failed_meavi_row_cur failed. Raising Exception.');
                END IF;

                  RAISE;
            END;


		IF (l_slog) THEN
	          -- bug 2834438
                   FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module, 'l_stmt_generated=' || l_stmt_generated);
                END IF;


            IF (l_stmt_generated = 'S') THEN
                -- If none of the attr has failed, then validation passed, insert row.
                BEGIN

                  if(p_import_mode = 0) then
                     EAM_ASSET_ATTR_PVT.INSERT_ROW(
                          p_api_version                =>  l_api_version,
                          p_init_msg_list              =>  l_init_msg_list,
                          p_commit                     =>  l_commit ,
                          p_validation_level           =>  l_validation_level,
                          p_rowid                      =>  l_rowid ,
                          p_association_id             =>  l_association_id ,
                          p_application_id             =>  l_application_id,
                          p_descriptive_flexfield_name =>  l_descriptive_flexfield_name ,
                          p_inventory_item_id          =>  l_inventory_item_id,
                          p_serial_number              =>  l_serial_number   ,
                          p_organization_id            =>  l_organization_id,
                          p_attribute_category         =>  l_attribute_category ,
                          p_c_attribute1               =>  l_c_attribute(1  ),
                          p_c_attribute2               =>  l_c_attribute(2 ),
                          p_c_attribute3               =>  l_c_attribute(3),
                          p_c_attribute4               =>  l_c_attribute(4 ),
                          p_c_attribute5               =>  l_c_attribute(5   ),
                          p_c_attribute6               =>  l_c_attribute(6 ),
                          p_c_attribute7               =>  l_c_attribute(7   ),
                          p_c_attribute8               =>  l_c_attribute(8 ),
                          p_c_attribute9               =>  l_c_attribute(9),
                          p_c_attribute10              =>  l_c_attribute(10),
                          p_c_attribute11              =>  l_c_attribute(11),
                          p_c_attribute12              =>  l_c_attribute(12),
                          p_c_attribute13              =>  l_c_attribute(13 ),
                          p_c_attribute14              =>  l_c_attribute(14),
                          p_c_attribute15              =>  l_c_attribute(15 ),
                          p_c_attribute16              =>  l_c_attribute(16),
                          p_c_attribute17              =>  l_c_attribute(17),
                          p_c_attribute18              =>  l_c_attribute(18),
                          p_c_attribute19              =>  l_c_attribute(19 ),
                          p_c_attribute20              =>  l_c_attribute(20 ),
                          p_d_attribute1               =>  l_d_attribute(1),
                          p_d_attribute2               =>  l_d_attribute(2),
                          p_d_attribute3               =>  l_d_attribute(3),
                          p_d_attribute4               =>  l_d_attribute(4),
                          p_d_attribute5               =>  l_d_attribute(5  ),
                          p_d_attribute6               =>  l_d_attribute(6),
                          p_d_attribute7               =>  l_d_attribute(7),
                          p_d_attribute8               =>  l_d_attribute(8  ),
                          p_d_attribute9               =>  l_d_attribute(9),
                          p_d_attribute10              =>  l_d_attribute(10),
                          p_n_attribute1               =>  l_n_attribute(1),
                          p_n_attribute2               =>  l_n_attribute(2  ),
                          p_n_attribute3               =>  l_n_attribute(3),
                          p_n_attribute4               =>  l_n_attribute(4),
                          p_n_attribute5               =>  l_n_attribute(5),
                          p_n_attribute6               =>  l_n_attribute(6 ),
                          p_n_attribute7               =>  l_n_attribute(7),
                          p_n_attribute8               =>  l_n_attribute(8),
                          p_n_attribute9               =>  l_n_attribute(9  ),
                          p_n_attribute10              =>  l_n_attribute(10),
                          p_last_update_date           =>  l_last_update_date,
                          p_last_updated_by            =>  l_last_updated_by ,

			  p_maintenance_object_type    =>  3,
			  p_maintenance_object_id      =>  l_instance_id,
			  p_creation_organization_id   =>  l_organization_id,

                          p_creation_date              =>  l_creation_date,
                          p_created_by                 =>  l_created_by,
                          p_last_update_login          =>  l_last_update_login ,
                          x_return_status              =>  l_return_status,
                          x_msg_count                  =>  l_msg_count ,
                          x_msg_data                   =>  l_msg_data
                          );

		IF (l_slog) THEN
	          -- bug 2834438
                   FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module, 'EAM_ASSET_ATTR_PVT.Insert_Row return status=' || l_return_status);
                END IF;



                     IF NOT  l_return_status = fnd_api.g_ret_sts_success THEN
                          RAISE NO_DATA_FOUND;
                     END IF;

                  end if;

                  if(p_import_mode = 1) then
                     EAM_ASSET_ATTR_PVT.UPDATE_ROW(
                          p_api_version         =>       l_api_version,
                          p_init_msg_list      =>        l_init_msg_list,
                          p_commit             =>        l_commit,
                          p_validation_level   =>        l_validation_level,
                          p_rowid              =>     	 l_rowid,
                          p_c_attribute1       =>        l_c_attribute(1),
                          p_c_attribute2       =>        l_c_attribute(2),
                          p_c_attribute3       =>        l_c_attribute(3),
                          p_c_attribute4       =>        l_c_attribute(4),
                          p_c_attribute5       =>        l_c_attribute(5),
                          p_c_attribute6       =>        l_c_attribute(6),
                          p_c_attribute7       =>        l_c_attribute(7),
                          p_c_attribute8       =>        l_c_attribute(8),
                          p_c_attribute9       =>        l_c_attribute(9),
                          p_c_attribute10      =>        l_c_attribute(10),
                          p_c_attribute11      =>        l_c_attribute(11),
                          p_c_attribute12      =>        l_c_attribute(12),
                          p_c_attribute13      =>        l_c_attribute(13),
                          p_c_attribute14      =>        l_c_attribute(14),
                          p_c_attribute15      =>        l_c_attribute(15),
                          p_c_attribute16      =>        l_c_attribute(16),
                          p_c_attribute17      =>        l_c_attribute(17),
                          p_c_attribute18      =>        l_c_attribute(18),
                          p_c_attribute19      =>        l_c_attribute(19),
                          p_c_attribute20      =>        l_c_attribute(20),
                          p_d_attribute1       =>        l_d_attribute(1),
                          p_d_attribute2       =>        l_d_attribute(2),
                          p_d_attribute3       =>        l_d_attribute(3),
                          p_d_attribute4       =>        l_d_attribute(4),
                          p_d_attribute5       =>        l_d_attribute(5  ),
                          p_d_attribute6       =>        l_d_attribute(6),
                          p_d_attribute7       =>        l_d_attribute(7),
                          p_d_attribute8       =>        l_d_attribute(8  ),
                          p_d_attribute9       =>        l_d_attribute(9),
                          p_d_attribute10      =>        l_d_attribute(10),
                          p_n_attribute1       =>        l_n_attribute(1),
                          p_n_attribute2       =>        l_n_attribute(2  ),
                          p_n_attribute3       =>        l_n_attribute(3),
                          p_n_attribute4       =>        l_n_attribute(4),
                          p_n_attribute5       =>        l_n_attribute(5),
                          p_n_attribute6       =>        l_n_attribute(6 ),
                          p_n_attribute7       =>        l_n_attribute(7),
                          p_n_attribute8       =>        l_n_attribute(8),
                          p_n_attribute9       =>        l_n_attribute(9  ),
                          p_n_attribute10      =>        l_n_attribute(10),
                          p_maintenance_object_type    =>  3,
                          p_maintenance_object_id      =>  l_instance_id,
                          p_last_update_date   =>        l_last_update_date,
                          p_last_updated_by    =>        l_last_updated_by ,
                          p_last_update_login  =>        l_last_update_login ,
                          x_return_status      =>        l_return_status,
                          x_msg_count          =>        l_msg_count ,
                          x_msg_data           =>        l_msg_data
                          );

    		IF (l_slog) THEN
	          -- bug 2834438
                   FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module, 'EAM_ASSET_ATTR_PVT.Update_Row return status=' || l_return_status);
                END IF;


                     IF NOT l_return_status = fnd_api.g_ret_sts_success THEN
                             RAISE NO_DATA_FOUND;
                     END IF;

                END IF;

                UPDATE  mtl_eam_attr_val_interface meavi
                SET     meavi.process_status = 'S',
                        meavi.error_number = NULL,
                        meavi.error_message = 'Success'
                WHERE   meavi.interface_header_id   = p_interface_header_id
                AND     meavi.application_id        = attr_group.application_id
                AND     meavi.descriptive_flexfield_name = attr_group.descriptive_flexfield_name
                AND     meavi.attribute_category = attr_group.attribute_category
                AND     meavi.process_status = 'P';


                EXCEPTION WHEN OTHERS THEN

                   IF dbms_sql.is_open(cur) THEN
                       dbms_sql.close_cursor(cur);
                   END IF;

		IF (l_exlog) THEN
	          -- bug 2834438
                   FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION, l_module, 'Insert/Update call to EAM_ASSET_ATTR_PVT failed. Raising exception.');
                END IF;
                  Raise;

                END;

            END IF; -- l_stmt_generated = 'S'

        END LOOP; -- End loop for attribute Groups

      END LOOP; -- End Loop for Asset Numbers

	IF (l_slog) THEN
	      -- bug 2834438
              FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module, 'Out of loop for Asset Numbers');
         END IF;
      -- Check if any attribute associated with the interface_header_id has failed.
      -- Even if one has failed, fail the whole procedure.
      DECLARE
         CURSOR all_failed_meavi_row_cur IS
            SELECT meavi.interface_line_id
            FROM   mtl_eam_attr_val_interface meavi
            WHERE   meavi.interface_header_id = p_interface_header_id
-- Since the following fields can have errors
--            AND     meavi.application_id        = l_application_id
--            AND     meavi.descriptive_flexfield_name = l_descriptive_flexfield_name
            AND     meavi.process_status = 'E'
            AND     meavi.error_number IS NOT NULL;

         all_failed_meavi_row_rec all_failed_meavi_row_cur%ROWTYPE;

      BEGIN
         OPEN all_failed_meavi_row_cur;
         FETCH all_failed_meavi_row_cur INTO all_failed_meavi_row_rec;

         IF all_failed_meavi_row_cur%FOUND
         THEN
    		IF (l_slog) THEN
	          -- bug 2834438
                   FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module, 'all_failed_meavi_row_cur%FOUND. Raising exception attr_import_failed');
                END IF;
           -- some row has failed, so the while import procedure fails
            RAISE attr_import_failed;
         END IF;

	-- To fix bug 2834438
	CLOSE all_failed_meavi_row_cur;

      EXCEPTION
         WHEN OTHERS
         THEN
            IF all_failed_meavi_row_cur%ISOPEN
            THEN
               CLOSE all_failed_meavi_row_cur;
            END IF;

    	        IF (l_exlog) THEN
	          -- bug 2834438
                   FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION, l_module, 'FETCH all_failed_meavi_row_cur failed. Raising exception.');
                END IF;
            RAISE;
      END;

      -- Purge Search Criteria from Temp table
      IF p_purge_option = 'Y' THEN

         DELETE    MTL_EAM_ATTR_VAL_INTERFACE meavi
         WHERE     meavi.interface_header_id = p_interface_header_id
         AND       ERROR_NUMBER IS NULL
         AND       PROCESS_STATUS = 'S';
      END IF;


      -- End of API body.
      -- Standard check of p_commit.
      IF fnd_api.to_boolean(p_commit) THEN
         COMMIT WORK;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      fnd_msg_pub.count_and_get(
         p_encoded => fnd_api.g_false
        ,p_count => x_msg_count
        ,p_data => x_msg_data);

        IF (l_plog) THEN
	      -- bug 2834438
              FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, l_module, '===== Exiting EAM_ASSET_ATTR_IMPORT_PVT.import_asset_attr_values =====');
        END IF;
   EXCEPTION

      WHEN attr_import_failed THEN
         -- Update all records as error if one of the attributes rows have errored out
         -- within any attribute group of the asset
         UPDATE  mtl_eam_attr_val_interface meavi
         SET     meavi.process_status = 'E',
                 meavi.error_number = 9999,
                 meavi.error_message = 'Failed as another Attribute of this Asset Number has failed validation'
         WHERE   meavi.interface_header_id   = p_interface_header_id
--         AND     meavi.application_id        = l_application_id
--         AND     meavi.descriptive_flexfield_name = l_descriptive_flexfield_name
--         AND     meavi.attribute_category = attr_group.attribute_category
         AND     meavi.process_status <> 'E'  -- could be 'S' or 'P'
--         AND     meavi.process_status = 'P'
         AND     meavi.error_number IS NULL
         AND     EXISTS(
                        SELECT  meavi.process_status
                        FROM    mtl_eam_attr_val_interface meavi
                        WHERE   meavi.interface_header_id = p_interface_header_id
                        AND     meavi.application_id        = l_application_id
                        AND     meavi.descriptive_flexfield_name = l_descriptive_flexfield_name
--                        AND     meavi.attribute_category   = attr_group.attribute_category
                        AND     meavi.process_status = 'E'
                        AND     meavi.error_number IS NOT NULL);

         x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get(
            p_encoded => fnd_api.g_false
           ,p_count => x_msg_count
           ,p_data => x_msg_data);

    	IF (l_exlog) THEN
	      -- bug 2834438
              FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION, l_module, 'EXEPTION attr_import_failed.');
        END IF;
      WHEN fnd_api.g_exc_error THEN
--         ROLLBACK TO import_asset_attr_values_pvt;
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get(
            p_encoded => fnd_api.g_false
           ,p_count => x_msg_count
           ,p_data => x_msg_data);

	IF (l_exlog) THEN
           -- bug 2834438
           FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION, l_module, 'EXEPTION fnd_api.g_exc_error.');
        END IF;

      WHEN fnd_api.g_exc_unexpected_error THEN
--         ROLLBACK TO import_asset_attr_values_pvt;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get(
           p_encoded => fnd_api.g_false
           ,p_count => x_msg_count
           ,p_data => x_msg_data);

	IF (l_exlog) THEN
	     -- bug 2834438
             FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION, l_module, 'EXEPTION fnd_api.g_exc_unexpected_error.');
        END IF;

      WHEN OTHERS THEN
--         ROLLBACK TO import_asset_attr_values_pvt;
         x_return_status := fnd_api.g_ret_sts_unexp_error;

         IF fnd_msg_pub.check_msg_level(
               fnd_msg_pub.g_msg_lvl_unexp_error) THEN
            fnd_msg_pub.add_exc_msg(G_PKG_NAME, l_api_name);
         END IF;

         fnd_msg_pub.count_and_get(
            p_encoded => fnd_api.g_false
           ,p_count => x_msg_count
           ,p_data => x_msg_data);

	IF (l_exlog) THEN
	          -- bug 2834438
                   FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION, l_module, 'EXEPTION OTHERS.');
        END IF;

  END import_asset_attr_values;


END EAM_ASSET_ATTR_IMPORT_PVT;

/
