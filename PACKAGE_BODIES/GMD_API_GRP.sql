--------------------------------------------------------
--  DDL for Package Body GMD_API_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMD_API_GRP" AS
/* $Header: GMDGAPIB.pls 120.32.12010000.4 2009/12/04 09:08:28 kannavar ship $ */


      l_package_name   CONSTANT VARCHAR2 (30)     := 'GMD_API_GRP';
      l_resp_id NUMBER := FND_PROFILE.VALUE('RESP_ID');
--Bug 3222090, NSRIVAST 20-FEB-2004, BEGIN
--Forward declaration.
   FUNCTION set_debug_flag RETURN VARCHAR2;
   l_debug VARCHAR2(1) := set_debug_flag;

   FUNCTION set_debug_flag RETURN VARCHAR2 IS
   l_debug VARCHAR2(1):= 'N';
   BEGIN
    IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
      l_debug := 'Y';
    END IF;
    RETURN l_debug;
   END set_debug_flag;
--Bug 3222090, NSRIVAST 20-FEB-2004, END

   /*======================================================================
   --  PROCEDURE :
   --   log_message
   --
   --  DESCRIPTION:
   --        This particular procedure is used to add messages to the stack.
   --  REQUIREMENTS
   --
   --  SYNOPSIS:
   --
   --===================================================================== */

   PROCEDURE log_message (
      p_message_code   IN   VARCHAR2
     ,p_token1_name    IN   VARCHAR2 := NULL
     ,p_token1_value   IN   VARCHAR2 := NULL
     ,p_token2_name    IN   VARCHAR2 := NULL
     ,p_token2_value   IN   VARCHAR2 := NULL
     ,p_token3_name    IN   VARCHAR2 := NULL
     ,p_token3_value   IN   VARCHAR2 := NULL) IS
   BEGIN
      fnd_message.set_name ('GMD', p_message_code);

      IF p_token1_name IS NOT NULL THEN
         fnd_message.set_token (p_token1_name, p_token1_value);

         IF p_token2_name IS NOT NULL THEN
            fnd_message.set_token (p_token2_name, p_token2_value);

            IF p_token3_name IS NOT NULL THEN
               fnd_message.set_token (p_token3_name, p_token3_value);
            END IF;
         END IF;
      END IF;

      fnd_msg_pub.ADD;
   EXCEPTION
      WHEN OTHERS THEN
         gmd_debug.put_line ('GMD_API_GRP.log_message: When others exception: '||SQLERRM);
   END log_message;

   /*======================================================================
   --  PROCEDURE :
   --   setup
   --
   --  DESCRIPTION:
   --        This particular procedure is used to set the global package
   --        variables.
   --  REQUIREMENTS
   --
   --  SYNOPSIS:
   --
   --===================================================================== */

   FUNCTION setup
      RETURN BOOLEAN IS
      missing_profile_option   EXCEPTION;
   BEGIN
      gmd_api_grp.login_id := TO_NUMBER (fnd_profile.VALUE ('LOGIN_ID'));
      gmd_api_grp.user_id := TO_NUMBER (fnd_profile.VALUE ('USER_ID'));
      gmd_api_grp.resp_id := TO_NUMBER (fnd_profile.VALUE ('RESP_ID'));

      IF NVL (gmd_api_grp.user_id, 0) = 0 THEN
         log_message (
            'GMD_API_INVALID_USER_ID'
           ,'USER_ID'
           ,gmd_api_grp.user_id);
         RAISE missing_profile_option;
      END IF;

      RETURN TRUE;
   EXCEPTION
      WHEN missing_profile_option THEN
         RETURN FALSE;
      WHEN NO_DATA_FOUND THEN
         log_message ('UNABLE_TO_LOAD_UOM');
         RETURN FALSE;
      WHEN OTHERS THEN
         fnd_msg_pub.add_exc_msg (l_package_name, 'SETUP');
         RETURN FALSE;
   END setup;

   /*======================================================================
   --  PROCEDURE :
   --   Validate Flex Field
   --
   --  DESCRIPTION:
   --        This particular procedure call validates the flex field data.
   --  REQUIREMENTS
   --
   --  SYNOPSIS:
   --    validate_flex_field ('GMD', 'FORM_DTL_FLEX', 'ATTRIBUTE1', '10',
   --                         x_field_value, x_return_status);
   --
   --===================================================================== */

   PROCEDURE validate_flex_field (
      p_application_short_name   IN       VARCHAR2
     ,p_flex_field_name          IN       VARCHAR2
     ,p_field_name               IN       VARCHAR2
     ,p_field_value              IN       VARCHAR2
     ,x_field_value              OUT NOCOPY      VARCHAR2
     ,x_return_status            OUT NOCOPY      VARCHAR2) IS
      l_display_value          VARCHAR2 (240);
      l_required_flag          VARCHAR2 (1);
      l_display_flag           VARCHAR2 (1);
      l_display                BOOLEAN;
      l_value_set_id           NUMBER;
      l_exists                 VARCHAR2 (1);

      CURSOR cur_get_appl_id IS
         SELECT application_id
         FROM   fnd_application
         WHERE  application_short_name = 'GMD';

      CURSOR cur_get_cont_name (
         v_flex_field_name   VARCHAR2
        ,v_application_id    NUMBER) IS
         SELECT context_column_name, context_required_flag
         FROM   fnd_descriptive_flexs
         WHERE  application_id = v_application_id AND
                descriptive_flexfield_name = v_flex_field_name;

      CURSOR cur_check_context (
         v_application_id    NUMBER
        ,v_flex_field_name   VARCHAR2
        ,v_field_value       VARCHAR2) IS
         SELECT 1
         FROM   sys.DUAL
         WHERE  EXISTS ( SELECT 1
                         FROM   fnd_descr_flex_contexts
                         WHERE  application_id = v_application_id AND
                                descriptive_flexfield_name =
                                                            v_flex_field_name AND
                                descriptive_flex_context_code = v_field_value);

      CURSOR cur_column_values (
         v_application_id    NUMBER
        ,v_flex_field_name   VARCHAR2
        ,v_field_name        VARCHAR2) IS
         SELECT required_flag, flex_value_set_id, display_flag
         FROM   fnd_descr_flex_column_usages
         WHERE  application_id = v_application_id AND
                descriptive_flexfield_name = v_flex_field_name AND
                application_column_name = v_field_name AND
                enabled_flag = 'Y';

      CURSOR cur_value_set (v_value_set_id NUMBER) IS
         SELECT flex_value_set_name, format_type, maximum_size
               ,number_precision, alphanumeric_allowed_flag
               ,uppercase_only_flag, minimum_value, maximum_value
         FROM   fnd_flex_value_sets
         WHERE  flex_value_set_id = v_value_set_id;

      l_value_rec              cur_value_set%ROWTYPE;
      flex_not_enabled         EXCEPTION;
      column_not_defined       EXCEPTION;
      field_value_required     EXCEPTION;
      validation_failure       EXCEPTION;
      context_value_required   EXCEPTION;
      context_not_existing     EXCEPTION;
   BEGIN
      /* Set return status to success initially */
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      /* Package variables have been introduced to avoid unnecessary open */
      /* of cursor and packages multiple times, as this pakage would be   */
      /* called in a loop in most of the scenarios                        */
      IF pkg_application_short_name <> p_application_short_name THEN
         OPEN cur_get_appl_id;
         FETCH cur_get_appl_id INTO pkg_application_id;
         CLOSE cur_get_appl_id;
         pkg_application_short_name := p_application_short_name;
      END IF;

      IF pkg_flex_field_name <> p_flex_field_name THEN
         /* Now let us set the global flag for checking the flex field */
         fnd_flex_apis.descr_setup_or_required (
            x_application_id => pkg_application_id
           ,x_desc_flex_name => p_flex_field_name
           ,enabled_flag => pkg_flex_enabled
           ,required_flag => l_required_flag);
         pkg_flex_field_name := p_flex_field_name;

         IF pkg_flex_enabled = 'Y' THEN
            /* Now we have to check wether the context_field is required */
            OPEN cur_get_cont_name (p_flex_field_name, pkg_application_id);
            FETCH cur_get_cont_name INTO pkg_context_column_name
                                        ,pkg_context_required;
            CLOSE cur_get_cont_name;
         END IF;
      END IF;

      /* If the flex field is not enabled then we should not allow any values in the attribute column */
      IF  (pkg_flex_enabled = 'N') AND
          (p_field_value IS NOT NULL) THEN
         RAISE flex_not_enabled;
      END IF;

      IF p_field_name = pkg_context_column_name THEN
         /* If the context field is required then we have to check wether a context */
         /* value has been passed                                                   */
         IF pkg_context_required = 'Y' THEN
            IF p_field_value IS NULL THEN
               RAISE context_value_required;
            ELSE
               /* Let us check now wether the value passed in as context is a valid value */
               OPEN cur_check_context (
                  pkg_application_id
                 ,p_flex_field_name
                 ,p_field_value);
               FETCH cur_check_context INTO l_exists;

               IF cur_check_context%NOTFOUND THEN
                  CLOSE cur_check_context;
                  RAISE context_not_existing;
               END IF;

               CLOSE cur_check_context;
            END IF;
         END IF;   /* IF pkg_context_required = 'Y' */

         x_field_value := p_field_value;
      ELSE
         /* Now let us fetch the column values */
         OPEN cur_column_values (
            pkg_application_id
           ,p_flex_field_name
           ,p_field_name);
         FETCH cur_column_values INTO l_required_flag
                                     ,l_value_set_id
                                     ,l_display_flag;

         IF cur_column_values%NOTFOUND THEN
            IF p_field_value IS NOT NULL THEN
               CLOSE cur_column_values;
               RAISE column_not_defined;
            END IF;
         ELSE
            /* Check the required property of the field */
            IF  (l_required_flag = 'Y') AND
                (p_field_value IS NULL) THEN
               RAISE field_value_required;
            END IF;

            x_field_value := p_field_value;

            IF p_field_value IS NULL THEN
               RETURN;
            END IF;

            /* Check for any value sets attached, if any then we have to validate against the value set */
            IF l_value_set_id IS NOT NULL THEN
               OPEN cur_value_set (l_value_set_id);
               FETCH cur_value_set INTO l_value_rec;

               IF cur_value_set%FOUND THEN
                  IF l_display_flag = 'Y' THEN
                     l_display := TRUE;
                  ELSE
                     l_display := FALSE;
                  END IF;

                  /* Now its time to validate the value against the value set attached */
                  IF NOT fnd_flex_val_util.is_value_valid (
                            p_value => p_field_value
                           ,p_is_displayed => l_display
                           ,p_vset_name => l_value_rec.flex_value_set_name
                           ,p_vset_format => l_value_rec.format_type
                           ,p_max_length => l_value_rec.maximum_size
                           ,p_precision => l_value_rec.number_precision
                           ,p_alpha_allowed => l_value_rec.alphanumeric_allowed_flag
                           ,p_uppercase_only => l_value_rec.uppercase_only_flag
                           ,p_min_value => l_value_rec.minimum_value
                           ,p_max_value => l_value_rec.maximum_value
                           ,x_storage_value => x_field_value
                           ,x_display_value => l_display_value) THEN
                     RAISE validation_failure;
                  END IF;
               END IF;   /* IF Cur_value_set%FOUND */

               CLOSE cur_value_set;
            END IF;
         END IF;   /* IF Cur_column_values%NOTFOUND */

         CLOSE cur_column_values;
      END IF;   /* IF p_field_name = pkg_context_column_name */
   EXCEPTION
      WHEN flex_not_enabled THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
         gmd_api_grp.log_message (
            'GMD_FLEX_NOT_ENABLED'
           ,'FLEX_NAME'
           ,p_flex_field_name);
      WHEN context_value_required THEN
         gmd_api_grp.log_message (
            'GMD_CONTEXT_VALUE_REQD'
           ,'CONTEXT_NAME'
           ,pkg_context_column_name);
         x_return_status := FND_API.G_RET_STS_ERROR;
      WHEN context_not_existing THEN
         gmd_api_grp.log_message (
            'GMD_NON_EXISTING_CONTEXT'
           ,'CONTEXT_VALUE'
           ,p_field_value);
         x_return_status := FND_API.G_RET_STS_ERROR;
      WHEN column_not_defined THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
         gmd_api_grp.log_message (
            'GMD_FLEX_COL_NOT_DEF'
           ,'FLEX_NAME'
           ,p_flex_field_name
           ,'COLUMN_NAME'
           ,p_field_name);
      WHEN field_value_required THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
         gmd_api_grp.log_message (
            'GMD_FIELD_VALUE_REQUIRED'
           ,'FIELD_NAME'
           ,p_field_name);
      WHEN validation_failure THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
   END validate_flex_field;

   /*************************************************************
   Procedure
     Validate Flex Field
   Type
     Private Procedure - to be called only by Proc. Validate_flex
   Description
     This particular procedure call validates the flex field data.
   *************************************************************/

   PROCEDURE validate_flex_field (
      p_table_name      IN            VARCHAR2           ,
      p_flex_record     IN            gmd_api_grp.flex,
      p_field_name      IN            VARCHAR2           ,
      x_flex_record     IN OUT NOCOPY gmd_api_grp.flex,
      x_return_status   OUT NOCOPY    VARCHAR2
   ) IS
      l_field_value       VARCHAR2 (240);
      l_storage_value     VARCHAR2 (240);
      l_flex_name         FND_DESCRIPTIVE_FLEXS.descriptive_flexfield_name%TYPE;
      l_appl_id           FND_APPLICATION.application_id%TYPE;
      l_appl_name         FND_APPLICATION.application_short_name%TYPE;

      /* Exception declaration */
      validation_failure             EXCEPTION;
      flexfield_not_found_exception  EXCEPTION;
      appl_name_not_found_exception  EXCEPTION;

      CURSOR get_desc_flex_name(vTable_Name VARCHAR2)  IS
        SELECT descriptive_flexfield_name, application_id
        FROM   fnd_descriptive_flexs
        WHERE  application_table_name = vTable_name;

      CURSOR get_appl_short_name(vAppl_id NUMBER)  IS
        SELECT application_short_name
        FROM   fnd_application
        WHERE  application_id = vAppl_id;

   BEGIN
      /* Set return status to success initially */
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      /* Let us fetch the field value first */
      SELECT DECODE (
                p_field_name,
                'ATTRIBUTE_CATEGORY', p_flex_record.attribute_category,
                'ATTRIBUTE1', p_flex_record.attribute1,
                'ATTRIBUTE2', p_flex_record.attribute2,
                'ATTRIBUTE3', p_flex_record.attribute3,
                'ATTRIBUTE4', p_flex_record.attribute4,
                'ATTRIBUTE5', p_flex_record.attribute5,
                'ATTRIBUTE6', p_flex_record.attribute6,
                'ATTRIBUTE7', p_flex_record.attribute7,
                'ATTRIBUTE8', p_flex_record.attribute8,
                'ATTRIBUTE9', p_flex_record.attribute9,
                'ATTRIBUTE10', p_flex_record.attribute10,
                'ATTRIBUTE11', p_flex_record.attribute11,
                'ATTRIBUTE12', p_flex_record.attribute12,
                'ATTRIBUTE13', p_flex_record.attribute13,
                'ATTRIBUTE14', p_flex_record.attribute14,
                'ATTRIBUTE15', p_flex_record.attribute15,
                'ATTRIBUTE16', p_flex_record.attribute16,
                'ATTRIBUTE17', p_flex_record.attribute17,
                'ATTRIBUTE18', p_flex_record.attribute18,
                'ATTRIBUTE19', p_flex_record.attribute19,
                'ATTRIBUTE20', p_flex_record.attribute20,
                'ATTRIBUTE21', p_flex_record.attribute21,
                'ATTRIBUTE22', p_flex_record.attribute22,
                'ATTRIBUTE23', p_flex_record.attribute23,
                'ATTRIBUTE24', p_flex_record.attribute24,
                'ATTRIBUTE25', p_flex_record.attribute25,
                'ATTRIBUTE26', p_flex_record.attribute26,
                'ATTRIBUTE27', p_flex_record.attribute27,
                'ATTRIBUTE28', p_flex_record.attribute28,
                'ATTRIBUTE29', p_flex_record.attribute29,
                'ATTRIBUTE30', p_flex_record.attribute30
             )
      INTO l_field_value
      FROM sys.DUAL;

      OPEN   get_desc_flex_name(UPPER(p_Table_name));
      FETCH  get_desc_flex_name INTO l_flex_name, l_appl_id;
        IF get_desc_flex_name%FOUND THEN
          OPEN  get_appl_short_name(l_appl_id);
          FETCH get_appl_short_name INTO l_appl_name;
            IF get_appl_short_name%NOTFOUND THEN
               CLOSE get_appl_short_name;
               RAISE appl_name_not_found_exception;
            END IF;
          CLOSE get_appl_short_name;
        ELSE
          CLOSE  get_desc_flex_name;
          RAISE  flexfield_not_found_exception;
        END IF;
      CLOSE  get_desc_flex_name;

      gmd_api_grp.validate_flex_field (
         p_application_short_name => l_appl_name,
         p_flex_field_name => l_flex_name,
         p_field_name => p_field_name,
         p_field_value => l_field_value,
         x_field_value => l_storage_value,
         x_return_status => x_return_status
      );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         RAISE validation_failure;
      END IF;

      IF ( l_debug IS NOT NULL ) THEN
        gmd_debug.put_line ('Flex:'|| p_field_name || ' Value:' || l_storage_value);
      END IF;

      /*Now let us copy back the storage value  */
      IF p_field_name = 'ATTRIBUTE1' THEN
         x_flex_record.attribute1 := l_storage_value;
      ELSIF p_field_name = 'ATTRIBUTE2' THEN
         x_flex_record.attribute2 := l_storage_value;
      ELSIF p_field_name = 'ATTRIBUTE3' THEN
         x_flex_record.attribute3 := l_storage_value;
      ELSIF p_field_name = 'ATTRIBUTE4' THEN
         x_flex_record.attribute4 := l_storage_value;
      ELSIF p_field_name = 'ATTRIBUTE5' THEN
         x_flex_record.attribute5 := l_storage_value;
      ELSIF p_field_name = 'ATTRIBUTE6' THEN
         x_flex_record.attribute6 := l_storage_value;
      ELSIF p_field_name = 'ATTRIBUTE7' THEN
         x_flex_record.attribute7 := l_storage_value;
      ELSIF p_field_name = 'ATTRIBUTE8' THEN
         x_flex_record.attribute8 := l_storage_value;
      ELSIF p_field_name = 'ATTRIBUTE9' THEN
         x_flex_record.attribute9 := l_storage_value;
      ELSIF p_field_name = 'ATTRIBUTE10' THEN
         x_flex_record.attribute10 := l_storage_value;
      ELSIF p_field_name = 'ATTRIBUTE11' THEN
         x_flex_record.attribute11 := l_storage_value;
      ELSIF p_field_name = 'ATTRIBUTE12' THEN
         x_flex_record.attribute12 := l_storage_value;
      ELSIF p_field_name = 'ATTRIBUTE13' THEN
         x_flex_record.attribute13 := l_storage_value;
      ELSIF p_field_name = 'ATTRIBUTE14' THEN
         x_flex_record.attribute14 := l_storage_value;
      ELSIF p_field_name = 'ATTRIBUTE15' THEN
         x_flex_record.attribute15 := l_storage_value;
      ELSIF p_field_name = 'ATTRIBUTE16' THEN
         x_flex_record.attribute16 := l_storage_value;
      ELSIF p_field_name = 'ATTRIBUTE17' THEN
         x_flex_record.attribute17 := l_storage_value;
      ELSIF p_field_name = 'ATTRIBUTE18' THEN
         x_flex_record.attribute18 := l_storage_value;
      ELSIF p_field_name = 'ATTRIBUTE19' THEN
         x_flex_record.attribute19 := l_storage_value;
      ELSIF p_field_name = 'ATTRIBUTE20' THEN
         x_flex_record.attribute20 := l_storage_value;
      ELSIF p_field_name = 'ATTRIBUTE21' THEN
         x_flex_record.attribute21 := l_storage_value;
      ELSIF p_field_name = 'ATTRIBUTE22' THEN
         x_flex_record.attribute22 := l_storage_value;
      ELSIF p_field_name = 'ATTRIBUTE23' THEN
         x_flex_record.attribute23 := l_storage_value;
      ELSIF p_field_name = 'ATTRIBUTE24' THEN
         x_flex_record.attribute24 := l_storage_value;
      ELSIF p_field_name = 'ATTRIBUTE25' THEN
         x_flex_record.attribute25 := l_storage_value;
      ELSIF p_field_name = 'ATTRIBUTE26' THEN
         x_flex_record.attribute26 := l_storage_value;
      ELSIF p_field_name = 'ATTRIBUTE27' THEN
         x_flex_record.attribute27 := l_storage_value;
      ELSIF p_field_name = 'ATTRIBUTE28' THEN
         x_flex_record.attribute28 := l_storage_value;
      ELSIF p_field_name = 'ATTRIBUTE29' THEN
         x_flex_record.attribute29 := l_storage_value;
      ELSIF p_field_name = 'ATTRIBUTE30' THEN
         x_flex_record.attribute30 := l_storage_value;
      ELSIF p_field_name = 'ATTRIBUTE_CATEGORY' THEN
         x_flex_record.attribute_category := l_storage_value;
      END IF;
   EXCEPTION
      WHEN flexfield_not_found_exception OR appl_name_not_found_exception THEN
         NULL;
      WHEN validation_failure THEN
         NULL;
   END validate_flex_field;


   /*************************************************************
   Procedure
     Validate Flex
   Description
     This particular procedure call validates the flex field data.
   *************************************************************/

   PROCEDURE validate_flex (
      p_table_name      IN              VARCHAR2           ,
      p_flex_record     IN              gmd_api_grp.flex,
      x_flex_record     IN OUT NOCOPY   gmd_api_grp.flex,
      x_return_status   OUT NOCOPY      VARCHAR2
   ) IS
      validation_failure   EXCEPTION;
   BEGIN
      /* Initialize the return status to success */
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      validate_flex_field (
         p_table_name  => p_table_name,
         p_flex_record => p_flex_record,
         p_field_name => 'ATTRIBUTE_CATEGORY',
         x_flex_record => x_flex_record,
         x_return_status => x_return_status
      );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         RAISE validation_failure;
      END IF;

      FOR i IN 1 .. 30
      LOOP
         validate_flex_field (
            p_table_name  => p_table_name,
            p_flex_record => p_flex_record,
            p_field_name => 'ATTRIBUTE' || TO_CHAR (i),
            x_flex_record => x_flex_record,
            x_return_status => x_return_status
         );

         IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            RAISE validation_failure;
         END IF;
      END LOOP;
   EXCEPTION
      WHEN validation_failure THEN
         NULL;
   END validate_flex;


    /* *********************************************************************** *
    * Function                                                                *
    *   Check_orgn_access                                                     *
    *   Parameter : Entity_id Number, Entity_name VARCHAR2                    *
    * Description                                                             *
    *  Checks if the user has access to the entity organization               *
    * *********************************************************************** */

    FUNCTION Check_orgn_access(Entity  VARCHAR2
                              ,Entity_id  NUMBER)
                               RETURN BOOLEAN IS
      l_owner_orgn_code   VARCHAR2(4);
      l_user_id           NUMBER := fnd_global.user_id;
      l_orgn_id           NUMBER;
      l_resp_name         VARCHAR2(240) := fnd_global.resp_name;
      l_dummy             NUMBER := 0;

    BEGIN
      IF (Entity = 'FORMULA') THEN
        SELECT    b.organization_code, b.organization_id
        INTO      l_owner_orgn_code, l_orgn_id
        FROM      fm_form_mst_b a, mtl_parameters b
        WHERE     a.formula_id = Entity_id
	          AND a.owner_organization_id = b.organization_id;

        /* Check if user has access to this formula orgn */
        IF NOT (gmd_api_grp.OrgnAccessible(l_orgn_id)) THEN
          FND_MESSAGE.SET_NAME('GMD','GMD_FORMULA_NOT_UPDATEABLE');
          FND_MESSAGE.SET_TOKEN('RESP_NAME',l_resp_name);
          FND_MESSAGE.SET_TOKEN('ORGN_CODE',l_Owner_orgn_code);
          FND_MSG_PUB.ADD;
          Return FALSE;
        END IF;

      ELSIF (Entity = 'RECIPE') THEN
        SELECT    b.organization_code, b.organization_id
        INTO      l_owner_orgn_code, l_orgn_id
        FROM      gmd_recipes_b a, mtl_parameters b
        WHERE     recipe_id = Entity_id
	          AND a.owner_organization_id = b.organization_id;

        /* Check if user has access to this Recipe orgn */
        IF NOT (gmd_api_grp.OrgnAccessible(l_orgn_id)) THEN
          FND_MESSAGE.SET_NAME('GMD','GMD_RECIPE_NOT_UPDATEABLE');
          FND_MESSAGE.SET_TOKEN('RESP_NAME',l_resp_name);
          FND_MESSAGE.SET_TOKEN('ORGN_CODE',l_Owner_orgn_code);
          FND_MSG_PUB.ADD;
          Return FALSE;
        END IF;

      ELSIF (Entity = 'VALIDITY') THEN
    SELECT  c.organization_code , a.owner_organization_id
    INTO      l_owner_orgn_code, l_orgn_id
    FROM gmd_recipes a , gmd_recipe_validity_rules b , mtl_parameters c
    WHERE b.recipe_validity_rule_id = Entity_id
    AND a.recipe_id = b.recipe_id
    AND a.owner_organization_id = c.organization_id ;

        -- Check if user has access to this Recipe orgn
        IF (l_owner_orgn_code IS NOT NULL) THEN
        /* Check if user resp has access to this VR orgn */
	IF NOT (gmd_api_grp.OrgnAccessible(l_orgn_id)) THEN
	  FND_MESSAGE.SET_NAME('GMD','GMD_RECIPE_NOT_UPDATEABLE');
          FND_MESSAGE.SET_TOKEN('RESP_NAME',l_resp_name);
          FND_MESSAGE.SET_TOKEN('ORGN_CODE',l_Owner_orgn_code);
          FND_MSG_PUB.ADD;
          Return FALSE;
        END IF;
        ELSE -- Global validity rule
          RETURN TRUE;
        END IF;

      ELSIF (Entity = 'ROUTING') THEN
        SELECT    b.organization_code, b.organization_id
        INTO      l_Owner_orgn_code, l_orgn_id
        FROM      gmd_routings_b a, mtl_parameters b
         WHERE    a.routing_id = Entity_id
	          AND a.owner_organization_id = b.organization_id;

        /* Check if user has access to this formula orgn */
        IF NOT (gmd_api_grp.OrgnAccessible(l_orgn_id)) THEN
          FND_MESSAGE.SET_NAME('GMD','GMD_ROUTING_NOT_UPDATEABLE');
          FND_MESSAGE.SET_TOKEN('RESP_NAME',l_resp_name);
          FND_MESSAGE.SET_TOKEN('ORGN_CODE',l_Owner_orgn_code);
          FND_MSG_PUB.ADD;
          Return FALSE;
        END IF;
      ELSIF (Entity = 'OPERATION') THEN
        SELECT    b.organization_code, b.organization_id
          INTO    l_Owner_orgn_code, l_orgn_id
          FROM    gmd_operations_b a, mtl_parameters b
         WHERE    a.oprn_id = Entity_id
	   AND    a.owner_organization_id = b.organization_id;

        /* Check if user has access to this formula orgn */
        IF NOT (gmd_api_grp.OrgnAccessible(l_orgn_id)) THEN
          FND_MESSAGE.SET_NAME('GMD','GMD_OPERATION_NOT_UPDATEABLE');
          FND_MESSAGE.SET_TOKEN('RESP_NAME',l_resp_name);
          FND_MESSAGE.SET_TOKEN('ORGN_CODE',l_Owner_orgn_code);
          FND_MSG_PUB.ADD;
          Return FALSE;
        END IF;
      END IF;

      RETURN TRUE;

    EXCEPTION
      WHEN OTHERS THEN
        fnd_msg_pub.add_exc_msg (l_package_name, 'CHECK_ORGN_ACCESS');
        RETURN FALSE;
    END Check_orgn_access;



    /* *********************************************************************** *
    * Function                                                                *
    *   OrgnAccessible()                                                *
    *   Parameter : powner_orgn_id IN NUMBER
    * Description                                                             *
    *  Checks if the user has access to the entity organization               *
    *  during the creation of a new instance                                  *
    * *********************************************************************** */

    FUNCTION OrgnAccessible(powner_orgn_id IN NUMBER) RETURN BOOLEAN IS
      /* Cursor Definitions. */
      /* =================== */
      CURSOR Cur_ownerorgn_id IS
      SELECT 1
      FROM   SYS.DUAL
      WHERE  EXISTS (SELECT 1
                     from org_access_view a, mtl_parameters b
                     where a.organization_id = b.organization_id
                       and b.organization_id = powner_orgn_id
                       and a.responsibility_id = l_resp_id
                       and b.process_enabled_flag = 'Y');

      CURSOR Cur_get_orgn (V_organization_id NUMBER) IS
        SELECT organization_code
        FROM   mtl_parameters
        WHERE  organization_id = V_organization_id;

      /* Local variables. */
      /* ================ */
      l_ret               NUMBER;
      l_resp_name         VARCHAR2(240) := fnd_global.resp_name;
      l_owner_org         VARCHAR2(3);

      Update_not_allowed_exp   EXCEPTION;
    BEGIN
      IF (powner_orgn_id IS NOT NULL) THEN
        OPEN Cur_ownerorgn_id;
        FETCH Cur_ownerorgn_id INTO l_ret;
        IF (Cur_ownerorgn_id%NOTFOUND) THEN
          CLOSE Cur_ownerorgn_id;
          RAISE Update_not_allowed_exp;
        END IF;
        CLOSE Cur_ownerorgn_id;
      END IF;

      RETURN TRUE;
    EXCEPTION
      WHEN Update_not_allowed_exp THEN
        /*Bug 4716697 - Thomas Daniel */
        /*Added code to fetch the organization code to set the message*/
        OPEN Cur_get_orgn (powner_orgn_id);
        FETCH Cur_get_orgn INTO l_owner_org;
        CLOSE Cur_get_orgn;
        FND_MESSAGE.SET_NAME('GMD', 'GMD_USER_ORG_NOT_UPDATE');
        FND_MESSAGE.SET_TOKEN('RESP_NAME',l_resp_name);
        FND_MESSAGE.SET_TOKEN('ORGN_CODE',l_owner_org);
        FND_MSG_PUB.ADD;
        RETURN FALSE;
      WHEN OTHERS THEN
        FND_MESSAGE.SET_NAME('GMD', 'GMD_INV_USER_ORGANIZATION');
        FND_MSG_PUB.ADD;
        RETURN FALSE;
    END OrgnAccessible;

    /* *********************************************************************** *
    * Function                                                                *
    *   get_object_status_type                                                *
    *   Parameter : Entity_id Number, Entity_name VARCHAR2                    *
    * Description                                                             *
    *  Checks if the user has access to the entity organization               *
    * *********************************************************************** */
    FUNCTION get_object_status_type
    (  pObject_Name VARCHAR2
     , pObject_Id   NUMBER)
    RETURN  GMD_STATUS_B.status_type%TYPE IS
      l_status_type  GMD_STATUS_B.status_type%TYPE;

      CURSOR Cur_get_fsttyp(pobject_id NUMBER) IS
        SELECT s.status_type
        FROM   fm_form_mst_b f,gmd_Status_b s
        WHERE  f.formula_id = pobject_id AND
               f.formula_status = s.status_code;

      CURSOR Cur_get_rsttyp(pobject_id NUMBER) IS
        SELECT s.status_type
        FROM   gmd_recipes_b r,gmd_Status_b s
        WHERE  r.recipe_id = pobject_id AND
               r.recipe_status = s.status_code;

      CURSOR Cur_get_osttyp(pobject_id NUMBER) IS
        SELECT s.status_type
        FROM  gmd_operations_b o,gmd_Status_b s
        WHERE o.oprn_id = pobject_id AND
              o.operation_status = s.status_code;

      CURSOR Cur_get_rtsttyp(pobject_id NUMBER) IS
        SELECT s.status_type
        FROM  gmd_routings_b r,gmd_Status_b s
        WHERE r.routing_id = pobject_id AND
              r.routing_status = s.status_code;

      CURSOR Cur_get_vrttyp(pobject_id NUMBER) IS
        SELECT s.status_type
        FROM  gmd_recipe_validity_rules v,gmd_Status_b s
        WHERE v.recipe_validity_rule_id = pobject_id AND
              v.validity_rule_status = s.status_code;
    BEGIN
      IF (pObject_id IS NOT NULL) THEN
        IF (Upper(pObject_Name) = 'FORMULA') THEN
          OPEN  Cur_get_fsttyp(pObject_id);
          FETCH Cur_get_fsttyp INTO l_Status_type;
          CLOSE Cur_get_fsttyp;
        ELSIF (Upper(pObject_Name) = 'RECIPE') THEN
          OPEN  Cur_get_rsttyp(pObject_id);
          FETCH Cur_get_rsttyp INTO l_Status_type;
          CLOSE Cur_get_rsttyp;
        ELSIF (Upper(pObject_Name) = 'ROUTING') THEN
          OPEN  Cur_get_rtsttyp(pObject_id);
          FETCH Cur_get_rtsttyp INTO l_Status_type;
          CLOSE Cur_get_rtsttyp;
        ELSIF (Upper(pObject_Name) = 'OPERATION') THEN
          OPEN  Cur_get_osttyp(pObject_id);
          FETCH Cur_get_osttyp INTO l_Status_type;
          CLOSE Cur_get_osttyp;
        ELSIF (Upper(pObject_Name) = 'VALIDITY') THEN
          OPEN  Cur_get_vrttyp(pObject_id);
          FETCH Cur_get_vrttyp INTO l_Status_type;
          CLOSE Cur_get_vrttyp;
        END IF;
      END IF;
      RETURN l_status_type ;
    EXCEPTION
       WHEN OTHERS THEN
        fnd_msg_pub.add_exc_msg (l_package_name, 'GET_OBJECT_STATUS_TYPE');
        RETURN Null;
    END get_object_status_type;

    /*======================================================================
    # NAME
    #    Validate_with_dep_entities
    # SYNOPSIS
    #    Proc Validate_with_dep_entities
    # DESCRIPTION
    ======================================================================*/
    PROCEDURE Validate_with_dep_entities(V_type      IN VARCHAR2,
                                         V_entity_id IN NUMBER,
                                         X_parent_check OUT NOCOPY BOOLEAN) IS
      X_status	VARCHAR2(5);
      CURSOR Cur_get_recp_sts(entity_id NUMBER) IS
        SELECT recipe_status
         FROM  gmd_recipes
        WHERE  recipe_id = entity_id
             AND ((recipe_status between 700 and 799
                   OR recipe_status between 400 and 499));


      CURSOR Cur_get_form_sts(entity_id NUMBER) IS
        SELECT formula_status
         FROM  fm_form_mst
        WHERE  formula_id = entity_id
             AND ((formula_status between 700 and 799
                   OR formula_status between 400 and 499));

      CURSOR Cur_get_rout_sts(entity_id NUMBER) IS
        SELECT routing_status
         FROM  fm_rout_hdr
        WHERE  routing_id = entity_id
           AND ((routing_status between 700 and 799
                OR routing_status between 400 and 499));

      CURSOR Cur_get_oprn_sts(entity_id NUMBER) IS
        SELECT operation_status
         FROM  gmd_operations
        WHERE  oprn_id = entity_id
             AND ((operation_status between 700 and 799
                  OR operation_status between 400 and 499));
     l_status gmd_status.status_code%TYPE;
     l_parent_check BOOLEAN := FALSE;
    BEGIN
      IF (V_entity_id IS NULL) THEN
        RETURN;
      END IF;

      IF (l_debug = 'Y') THEN
        gmd_debug.put_line('In GMD_API_GRP.validate_with_dep_entities - '||
                            'v_entity_id = '||v_entity_Id||' and entity type = '||v_type);
      END IF;

      IF (v_entity_id IS NOT NULL) THEN
        IF (V_type = 'RECIPE') THEN
          OPEN Cur_get_recp_sts(v_entity_id);
          FETCH Cur_get_recp_sts INTO l_status;
          IF (l_debug = 'Y') THEN
             gmd_debug.put_line('In GMD_API_GRP.validate_with_dep_entities - '||
                                 'About to check for Recipe - Vr dep status = '||l_status);
          END IF;
          IF (Cur_get_recp_sts%FOUND) THEN
            IF (NOT gmd_status_code.check_parent_status(v_type,v_entity_id)) THEN
              IF (l_debug = 'Y') THEN
                gmd_debug.put_line('In GMD_API_GRP.validate_with_dep_entities - '||
                                   ' There is VR dependency for this Recipe = '||v_entity_Id);
              END IF;

              l_parent_check := TRUE;
              FND_MESSAGE.SET_NAME('GMD','GMD_RECIPE_BATCH_DEP');
            END IF;
          END IF;
          CLOSE Cur_get_recp_sts;
        ELSIF(v_type = 'ROUTING') THEN
          OPEN Cur_get_rout_sts(v_entity_id);
          FETCH Cur_get_rout_sts INTO l_status;
          IF (Cur_get_rout_sts%FOUND) THEN
            IF (NOT gmd_status_code.check_parent_status(v_type,v_entity_id)) THEN
              l_parent_check := TRUE;
              FND_MESSAGE.SET_NAME('GMD','GMD_ROUTING_RECIPE_DEP');
            END IF;
          END IF;
          CLOSE Cur_get_rout_sts;
        ELSIF(V_type = 'FORMULA') THEN
          OPEN Cur_get_form_sts(v_entity_id);
          FETCH Cur_get_form_sts INTO l_status;
          IF (Cur_get_form_sts%FOUND) THEN
            IF (NOT gmd_status_code.check_parent_status(v_type,v_entity_id)) THEN
              l_parent_check := TRUE;
              FND_MESSAGE.SET_NAME('GMD','GMD_FORMULA_RECIPE_DEP');
            END IF;
          END IF;
          CLOSE Cur_get_form_sts;
        ELSIF(v_type = 'OPERATION') THEN
          OPEN Cur_get_oprn_sts(v_entity_id);
          FETCH Cur_get_oprn_sts INTO l_status;
          IF (Cur_get_oprn_sts%FOUND) THEN
            IF (NOT gmd_status_code.check_parent_status(v_type,v_entity_id)) THEN
              l_parent_check := TRUE;
              FND_MESSAGE.SET_NAME('GMD','GMD_OPERATION_ROUT_DEP');
            END IF;
          END IF;
          CLOSE Cur_get_oprn_sts;
        END IF;
     END IF;

     x_parent_check := l_parent_check;

   END Validate_with_dep_entities;


   /*======================================================================
     NAME
        get_object_name_version
     SYNOPSIS
        Proc get_object_name_version
     DESCRIPTION
     Function returns Object_no (e.g Recipe_no) when vType = 'NAME'
              returns Object_vers (e.g Recipe_version) when vType = 'VERSION'
              returns Object_no and version (e.g Recipe_no||' - '||version)
                                             when vType = 'NAME-VERSION'
    ======================================================================*/
    FUNCTION get_object_name_version(vEntity VARCHAR2
                                    ,vEntity_id NUMBER
                                    ,vtype VARCHAR2 DEFAULT 'NAME-VERSION')
                                    RETURN VARCHAR2 IS
      l_object_name              VARCHAR2(100);
      l_object_version           VARCHAR2(10);
      l_object_name_and_version  VARCHAR2(240);
    BEGIN
      IF (vEntity_id IS NOT NULL) THEN
        IF (vEntity = 'FORMULA') THEN
          Select formula_no, formula_vers, formula_no||' - '||formula_vers
          INTO   l_object_name, l_object_version, l_object_name_and_version
          FROM   fm_form_mst_b
          WHere  formula_id = vEntity_id;
        ELSIF (vEntity = 'ROUTING') THEN
          Select routing_no, routing_vers, routing_no||' - '||routing_vers
          INTO   l_object_name, l_object_version, l_object_name_and_version
          FROM   gmd_routings_b
          WHere  routing_id = vEntity_id;
        ELSIF (vEntity = 'OPERATION') THEN
          Select oprn_no, oprn_vers, oprn_no||' - '||oprn_vers
          INTO   l_object_name, l_object_version, l_object_name_and_version
          FROM   gmd_operations_b
          WHere  oprn_id = vEntity_id;
        ELSIF (vEntity = 'RECIPE') THEN
          Select recipe_no, recipe_version, recipe_no||' - '||recipe_version
          INTO   l_object_name, l_object_version, l_object_name_and_version
          FROM   gmd_recipes_b
          WHere  recipe_id = vEntity_id;
        ELSIF (vEntity = 'VALIDITY') THEN
          Select r.recipe_no, r.recipe_version, r.recipe_no||' - '||r.recipe_version
          INTO   l_object_name, l_object_version, l_object_name_and_version
          FROM   gmd_recipes_b r, gmd_recipe_validity_rules v
          WHere  v.recipe_id = vEntity_id
          AND    v.recipe_id = r.recipe_id;
        END IF;
      END IF;

      IF vType = 'NAME' THEN
        Return l_object_name;
      ELSIF vType = 'VERSION' THEN
        Return l_object_version;
      ELSE
        RETURN l_object_name_and_version;
      END IF;

    END get_object_name_version;

  /********************************************************************************
  * Name : get_formula_acces_type
  *
  * Description: Function returns the acces type level of the user for a given formula.
  *              Returns 'U', means user has updatable acces.
  *              Returns 'V', means user has view acces.
  *              Returns 'N', means no record setup - exceptional condition
  * Change History:
  * Who         When            What
  * TDANIEL     29-JUL-2005     Modified the code to handle NULL (-1) for formula id
  *                             and also modified for convergence changes.
  **********************************************************************************/

  FUNCTION get_formula_access_type(p_formula_id              IN PLS_INTEGER,
                                   p_owner_organization_id   IN PLS_INTEGER)
  RETURN VARCHAR2 IS

    /* Cursor Variables */

    CURSOR get_vpd_flag IS
      SELECT active_formula_ind
      FROM gmd_vpd_security;

    CURSOR Cur_check_orgn_access (V_default_user_id PLS_INTEGER) IS
      SELECT 1
      FROM   sys.dual
      WHERE EXISTS ( SELECT 1
                     FROM gmd_security_profiles sp
                     WHERE sp.access_type_ind = 'U'
                     AND nvl(responsibility_id, fnd_global.resp_id) = fnd_global.resp_id /* Bug No.9077438 */
                     AND ( responsibility_id IN ( SELECT rg.responsibility_id
                                                  FROM FND_USER_RESP_GROUPS rg
                                                  WHERE rg.user_id = fnd_global.user_id
                                                  AND SYSDATE BETWEEN rg.start_date
                                                  AND NVL(rg.end_date, SYSDATE)
                                                 )
                           OR ( sp.user_id = V_default_user_id
                                OR sp.user_id = fnd_global.user_id
                               )
                          )
                     AND organization_id = P_owner_organization_id
                     AND (other_organization_id IS NULL
                          OR EXISTS ( SELECT NULL
                                      FROM org_access a3
                                      WHERE a3.organization_id = sp.other_organization_id
                                      AND NVL(a3.disable_date, SYSDATE+1) >= SYSDATE
                                      AND a3.resp_application_id = fnd_global.resp_appl_id
                                      AND a3.responsibility_id = fnd_global.resp_id
                                     )
                          OR NOT EXISTS ( SELECT NULL
                                          FROM org_access a4
                                          WHERE a4.organization_id = sp.other_organization_id
                                          AND NVL(a4.disable_date, SYSDATE+1) >=SYSDATE
                                         )
                          )
                    );


    CURSOR Cur_check_formula_access (V_default_user_id PLS_INTEGER) IS
      SELECT sp.access_type_ind
      FROM gmd_security_profiles sp
      WHERE sp.assign_method_ind = 'A'
       AND NVL(responsibility_id, fnd_global.resp_id) = fnd_global.resp_id  /* Bug No.9077438 */
      AND (  ( sp.user_id =  V_default_user_id
               OR  sp.user_id = fnd_global.user_id
              )
             OR ( EXISTS ( SELECT rg.responsibility_id
                           FROM FND_USER_RESP_GROUPS rg
                           WHERE rg.user_id = fnd_global.user_id
                           AND sp.responsibility_id = rg.responsibility_id
                           AND SYSDATE BETWEEN rg.start_date AND NVL(rg.end_date, SYSDATE)
                          )
                 )
           )
      AND (  EXISTS ( SELECT NULL
                      FROM org_access a1
                      WHERE ( ( sp.organization_id = a1.organization_id
                                AND sp.other_organization_id IS NULL
                               )
                               OR sp.other_organization_id = a1.organization_id
                             )
                      AND NVL(a1.disable_date, SYSDATE+1) >= SYSDATE
                      AND a1.resp_application_id = fnd_global.resp_appl_id
                      AND a1.responsibility_id = fnd_global.resp_id
                     )
             OR
             NOT EXISTS ( SELECT NULL
                          FROM org_access a2
                          WHERE ( ( sp.organization_id = a2.organization_id
                                    AND sp.other_organization_id IS NULL
                                   )
                                  OR sp.other_organization_id = a2.organization_id
                                 )
                          AND NVL(a2.disable_date, SYSDATE+1) >=SYSDATE
                         )
           )
     AND sp.organization_id = P_owner_organization_id
     UNION
     SELECT fs.access_type_ind
     FROM   gmd_formula_security fs
     WHERE ( ( fs.user_id =  V_default_user_id
               OR  fs.user_id = fnd_global.user_id
              )
             OR ( EXISTS ( SELECT rg.responsibility_id
                           FROM FND_USER_RESP_GROUPS rg
                           WHERE rg.user_id = fnd_global.user_id
                           AND fs.responsibility_id = rg.responsibility_id
                           AND SYSDATE BETWEEN rg.start_date
                           AND NVL(rg.end_date, SYSDATE)
                          )
                 )
            )
     AND nvl(responsibility_id,fnd_global.resp_id) = fnd_global.resp_id /* Bug No.9077438 */
     AND   (EXISTS ( SELECT NULL
                     FROM org_access ou
                     WHERE ( ( fs.organization_id = ou.organization_id
                               AND fs.other_organization_id IS NULL
                              )
                              OR fs.other_organization_id = ou.organization_id
                            )
                     AND NVL(ou.disable_date, SYSDATE+1) >= SYSDATE
                     AND ou.resp_application_id = fnd_global.resp_appl_id
                     AND ou.responsibility_id = fnd_global.resp_id
                    )
            OR
            NOT EXISTS ( SELECT NULL
                         FROM org_access ou1
                         WHERE ( ( ou1.organization_id = fs.organization_id
                                   AND fs.other_organization_id IS NULL
                                  )
                                  OR ou1.organization_id = fs.other_organization_id
                                )
                         AND   NVL(ou1.disable_date, SYSDATE+1) >=SYSDATE
                        )
            )
     AND fs.formula_id = P_formula_id;


    /* Local Variables */

    l_vpd_flag            VARCHAR2(1) := 'N';
    l_access_type_ind     VARCHAR2(1);
    l_default_user_id     VARCHAR2(240) := fnd_profile.value('GMD_DEFAULT_USER');
    l_exists		  PLS_INTEGER;
  BEGIN
    /* First check if the VPD flag is set */
    OPEN get_vpd_flag;
    FETCH get_vpd_flag INTO l_vpd_flag;
    CLOSE get_vpd_flag;

    IF (l_vpd_flag = 'Y') THEN
      /* If there is no formula associated then we are checking if the user */
      /* has security to create or view formula for the organization passed */
      IF p_formula_id = -1 THEN
        OPEN Cur_check_orgn_access (l_default_user_id);
        FETCH Cur_check_orgn_access INTO l_exists;
        IF Cur_check_orgn_access%FOUND THEN
          l_access_type_ind := 'U';
        ELSE
          l_access_type_ind := 'V';
        END IF;
        CLOSE Cur_check_orgn_access;
      ELSE
        OPEN Cur_check_formula_access (l_default_user_id);
        FETCH Cur_check_formula_access INTO l_access_type_ind;
        IF Cur_check_formula_access%NOTFOUND THEN
          l_access_type_ind := 'N';
        END IF;
        CLOSE Cur_check_formula_access;
      END IF;
      RETURN l_access_type_ind;
    ELSE
      RETURN 'U';
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      fnd_msg_pub.add_exc_msg(l_package_name, 'GET_FORMULA_ACCESS_TYPE');
      RETURN 'N';
  END get_formula_access_type;


 ------------------------------------------------------------------
  --Created by  : Sriram.S
  --Date created: 20-JAN-2004
  --
  --Purpose: Returns description of the Status Code
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  --SRSRIRAN    20-FEB-2004     Created w.r.t. bug 3408799
  -------------------------------------------------------------------
  FUNCTION get_status_desc (V_entity_status IN VARCHAR2 ) RETURN VARCHAR2 IS
    CURSOR Cur_get_status_desc IS
    SELECT description
    FROM gmd_status
    WHERE status_code = V_entity_status;
    X_description      VARCHAR2(240);
  BEGIN
     IF (V_entity_status IS NOT NULL) THEN
        OPEN Cur_get_status_desc;
        FETCH Cur_get_status_desc INTO X_description;
        CLOSE Cur_get_status_desc;
        RETURN X_description;
     END IF;
     RETURN NULL;
  END get_status_desc;


 ------------------------------------------------------------------
  --Created by  : Sriram.S
  --Date created: 20-JAN-2004
  --
  --Purpose: Returns the default status of the entity.
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  --SRSRIRAN    20-FEB-2004     Created w.r.t. bug 3408799
  --kkiallms    01-DEC-2004     Modified w.r.t. 4004501
  -------------------------------------------------------------------
  PROCEDURE get_status_details (V_entity_type    IN         VARCHAR2,
                              V_orgn_id        IN         NUMBER,
                              X_entity_status  OUT NOCOPY GMD_API_GRP.status_rec_type) IS

    CURSOR cur_def_status(cp_orgn_id          NUMBER,
                      cp_parameter_name   gmd_parameters_dtl.parameter_name%TYPE)IS
        SELECT st.status_code
              ,st.description
              ,st.status_type
        FROM   gmd_parameters_hdr h
              ,gmd_parameters_dtl d
              ,gmd_status st
        WHERE (h.organization_id = cp_orgn_id OR h.organization_id IS NULL)
        AND    h.parameter_id = d.parameter_id
        AND    d.parameter_name = cp_parameter_name
        AND    st.status_code = parameter_value
        ORDER BY h.organization_id;


     CURSOR Cur_get_def_new_status IS
       SELECT b.status_code, b.description,b.status_type
       FROM   gmd_status b
       WHERE  b.status_code = 100;

  BEGIN
     IF (V_entity_type = 'ROUTING') THEN
         OPEN cur_def_status(V_orgn_id,'GMD_DEFAULT_ROUT_STATUS');
         FETCH cur_def_status INTO X_entity_status;
         CLOSE cur_def_status;
     ELSIF (V_entity_type = 'OPERATION') THEN
         OPEN cur_def_status(V_orgn_id,'GMD_DEFAULT_OPRN_STATUS');
         FETCH cur_def_status INTO X_entity_status;
         CLOSE cur_def_status;
     ELSIF (V_entity_type = 'RECIPE') THEN
         OPEN cur_def_status(V_orgn_id,'GMD_DEFAULT_RECP_STATUS');
         FETCH cur_def_status INTO X_entity_status;
         CLOSE cur_def_status;
     ELSIF (V_entity_type = 'FORMULA') THEN
         OPEN cur_def_status(V_orgn_id,'GMD_DEFAULT_FORM_STATUS');
         FETCH cur_def_status INTO X_entity_status;
         CLOSE cur_def_status;
     ELSIF (V_entity_type = 'VALIDITY') THEN
         OPEN cur_def_status(V_orgn_id,'GMD_DEFAULT_VALR_STATUS');
         FETCH cur_def_status INTO X_entity_status;
         CLOSE cur_def_status;
     ELSIF (V_entity_type = 'SUBSTITUTION') THEN --Bug 4479101
         OPEN cur_def_status(V_orgn_id,'GMD_DEFAULT_SUBS_STATUS');
         FETCH cur_def_status INTO X_entity_status;
         CLOSE cur_def_status;

     END IF;

     IF X_entity_status.entity_status IS NULL THEN
       OPEN CUR_get_def_new_status;
       FETCH Cur_get_def_new_status INTO X_entity_status;
       CLOSE Cur_get_def_new_status;
     END IF;

  END get_status_details;


  ------------------------------------------------------------------
  --Created by  : Sriram.S
  --Date created: 20-JAN-2004
  --
  --Purpose: Function returns the TRUE if V_entity_status status is
  --         valid for the given entity otherwise returns FALSE
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  --SRSRIRAN    20-FEB-2004     Created w.r.t. bug 3408799
  -------------------------------------------------------------------
  FUNCTION check_dependent_status(V_entity_type   IN VARCHAR2,
                                V_entity_id     IN NUMBER,
                                V_entity_status IN VARCHAR2) RETURN BOOLEAN IS

     CURSOR Cur_get_def_oprn_status IS
       SELECT operation_status
       FROM   gmd_operations
       WHERE  oprn_id = V_entity_id
       AND    operation_status >= V_entity_status;
     CURSOR Cur_get_def_formula_status IS
       SELECT formula_status FROM  fm_form_mst
       WHERE formula_id = V_entity_id
       AND   formula_status >= V_entity_status;
     CURSOR Cur_get_def_routing_status IS
       SELECT routing_status
       FROM  fm_rout_hdr
       WHERE routing_id = V_entity_id
       AND   routing_status >= V_entity_status;
     /* do we need this-not used*/
     l_operation_status gmd_operations.operation_status%TYPE;
     l_formula_status   fm_form_mst.formula_status%TYPE;
     l_routing_status   fm_rout_hdr.routing_status%TYPE;
  BEGIN
       /*Check all the operations inserted are of status APFLU or APFGU*/
        IF (V_entity_type = 'OPERATION') THEN
                OPEN Cur_get_def_oprn_status;
                FETCH Cur_get_def_oprn_status INTO l_operation_status;
                IF (Cur_get_def_oprn_status %NOTFOUND) THEN
                        CLOSE Cur_get_def_oprn_status;
                        RETURN TRUE;
                ELSE
                        CLOSE Cur_get_def_oprn_status;
                        RETURN FALSE;
                END IF;
                RETURN FALSE;
        END IF; --V_entity_type = 'OPERATION'

        IF (V_entity_type = 'FORMULA') THEN
                OPEN Cur_get_def_formula_status;
                FETCH Cur_get_def_formula_status INTO l_formula_status;
                IF (Cur_get_def_formula_status %NOTFOUND) THEN
                        CLOSE Cur_get_def_formula_status;
                        RETURN TRUE;
                ELSE
                        CLOSE Cur_get_def_formula_status;
                        RETURN FALSE;
                END IF;
                RETURN FALSE;
        END IF; --V_entity_type = 'FORMULA'

        IF (V_entity_type = 'ROUTING') THEN
                OPEN Cur_get_def_routing_status;
                FETCH Cur_get_def_routing_status INTO l_routing_status;
                IF (Cur_get_def_routing_status %NOTFOUND) THEN
                        CLOSE Cur_get_def_routing_status;
                        RETURN TRUE;
                ELSE
                        CLOSE Cur_get_def_routing_status;
                        RETURN FALSE;
                END IF; --Cur_get_def_routing_status %NOTFOUND
                RETURN FALSE;
        END IF; --V_entity_type = 'ROUTING'
  END check_dependent_status;

  /*======================================================================
  --  PROCEDURE :
  --   set_activity_sequence_num
  --
  --  DESCRIPTION:
  --        This particular procedure is used to set the sequencing of the
  --        activities within an operation.
  --  REQUIREMENTS
  --
  --  SYNOPSIS:
  --
  --===================================================================== */

  PROCEDURE set_activity_sequence_num(
    P_oprn_id       IN  NUMBER,
    P_user_id       IN  NUMBER,
    P_login_id      IN  NUMBER)
  IS
    /* this cursor selects the activities in the appropriate order, making the seq dep activity
    the first one the the others by offset then activity then the tie breaker of the surrogate
    key. The seq dep ind will hold the sequence numbers so we need to take those out of
    for validation purposes. The column seq_dep_order will make the seq dep activity first
    then all others will follow */

    CURSOR Cur_get_activities (V_oprn_id IN NUMBER) IS
      SELECT oprn_line_id, NVL(sequence_dependent_ind,-1) sequence_dependent_ind
      FROM   gmd_operation_activities
      WHERE  oprn_id = v_oprn_id
	AND  NVL(sequence_dependent_ind, 0) <> 1
      ORDER BY
       offset_interval,
       activity,
       oprn_line_id;

    X_oprn_line_id NUMBER;
    X_seq_num      NUMBER;
    X_seq_dep_ind  NUMBER;
  BEGIN
    /* the seq num will always start at 100 for the first activity after the
       seq dep activity. */
    X_seq_num := 100;

    OPEN Cur_get_activities (P_oprn_id);
    LOOP
      FETCH Cur_get_activities INTO X_oprn_line_id, X_seq_dep_ind;
      EXIT WHEN Cur_get_activities%NOTFOUND;

      /* If the activity has been previously numbered and is in the right order
         no need to update it */
      IF X_seq_dep_ind <> X_seq_num THEN
        UPDATE gmd_operation_activities
        SET    sequence_dependent_ind = X_seq_num,
               last_update_date = SYSDATE,
               last_updated_by = P_user_id,
               last_update_login = P_login_id
        WHERE  oprn_line_id = X_oprn_line_id;
      END IF;

      /* increment the seq num for each processed except the seq dep activity */
      X_seq_num := X_seq_num + 100;
    END LOOP;
    CLOSE Cur_get_activities;
  END set_activity_sequence_num;

  /*========================================================================+
** Name    : retrieve_vr
** Notes       : This procedure receives as input recipe record and
**               retrieves validity rules records.
**
**               If everything is fine then OUT parameter
**               x_return_status is set to 'S' else appropriate
**              error message is put on the stack and error
**               is returned.
**
** HISTORY
**  01-Mar-2004 B3604554  GK	Created.
**  21-May-2004 B3642937  GK	Called the procedure get_status_details and
**  				Assigned the default_status to the validity_status
**  24-May-2004 B3643405  GK	Added the statement orgn IS NULL to cursor c_get_recipe_info
**  25-May-2004 B3645706  GK	Removed the statement orgn IS NULL to cursor c_get_recipe_info
**				and created a new cursor c_get_global_info to accomodate for global and
**				so that the orgn code will pick up the correct configuration information
**  25-May-2004 B3653935 GK     Changed variables login_id, user_id to be assigned to FND_PROFILE.VALUE
**  25-May-2004 B        GK 	In the global records the start date and end date still referenced the local so changed this
**  01-dec-2004 kkillams        orgn_code is replaced with organization_id/owner_organization_id w.r.t. 4004501
**  10-Feb-2005 4004501  Krishna  Added Revision column, in the retrival information.
**  18-APR-2006 kmotupal      Added check for default status while retrieving recipe VR details
**+========================================================================*/


PROCEDURE retrieve_vr(p_formula_id IN NUMBER,
		      l_recipe_vr_tbl OUT NOCOPY GMD_RECIPE_DETAIL.recipe_vr,
		      l_vr_flex OUT NOCOPY GMD_RECIPE_DETAIL.flex,
		      x_return_status	OUT NOCOPY 	VARCHAR2,
		      p_recipe_use IN NUMBER) IS

  CURSOR c_get_vr_id IS
    SELECT gmd_recipe_validity_id_s.NEXTVAL
    FROM   FND_DUAL;

  CURSOR c_get_formula IS
    SELECT 	creation_date, formula_status, owner_organization_id
    FROM	fm_form_mst_b
    WHERE	formula_id = p_formula_id;
  LocalDateRecord		c_get_formula%ROWTYPE;

  CURSOR c_get_formula_item IS
    SELECT  inventory_item_id, revision, detail_uom, qty
    FROM    fm_matl_dtl
    WHERE   formula_id = p_formula_id
    AND     line_type = 1
    ORDER BY line_no;

  LocalFormRecord		c_get_formula_item%ROWTYPE;

  CURSOR c_get_recipe_info(l_orgn_id NUMBER) IS
    SELECT 	*
    FROM	gmd_recipe_generation
    WHERE 	(organization_id = l_orgn_id
	         OR organization_id IS NULL)
    ORDER BY organization_id;

  LocalInfoRecord		c_get_recipe_info%ROWTYPE;

  CURSOR Cur_get_max_pref (V_item_id NUMBER, V_organization_id NUMBER,
                           V_start_date DATE, V_end_date DATE, V_recipe_use NUMBER) IS
    SELECT MAX(preference)
    FROM   gmd_recipe_validity_rules
    WHERE  inventory_item_id = v_item_id
    AND    organization_id = v_organization_id
    AND    recipe_use = v_recipe_use
    AND    NVL(end_date, v_start_date) >= v_start_date
    AND    start_date <= NVL(v_end_date, start_date)
    AND    inv_max_qty >= 0
    AND    inv_min_qty <= 999999
    AND    validity_rule_status < 800
    AND    delete_mark = 0;

  l_vr_id		NUMBER := 0;
  l_item_id	NUMBER(15,0);
  l_revision  VARCHAR(3);  --Krishna, NPD convergence
  l_user_id	NUMBER;
  l_login_id	NUMBER;
  l_preference    NUMBER;
  l_recipe_use	NUMBER;

  l_orgn_id     NUMBER;
  l_end_status 	VARCHAR2(30);
  l_detail_uom	VARCHAR2(4);

  l_start_date	DATE;
  l_end_date	DATE;
  x_end_date	DATE;

l_default_vr_status         GMD_API_GRP.status_rec_type;
BEGIN

  OPEN c_get_vr_id;
  FETCH c_get_vr_id INTO l_vr_id;
  CLOSE c_get_vr_id;

  OPEN c_get_formula;
  FETCH c_get_formula INTO LocalDateRecord;
    l_orgn_id := LocalDateRecord.owner_organization_id;
  CLOSE c_get_formula;

  OPEN c_get_recipe_info(l_orgn_id);
  FETCH c_get_recipe_info INTO LocalInfoRecord;
  IF c_get_recipe_info%FOUND THEN
    l_user_id := FND_PROFILE.VALUE('USER_ID');
    l_login_id := FND_PROFILE.VALUE ('LOGIN_ID');

    IF LocalInfoRecord.start_date_type = 0 THEN
      OPEN c_get_formula;
      FETCH c_get_formula INTO LocalDateRecord;
        l_start_date := TRUNC(LocalDateRecord.creation_date);
      CLOSE c_get_formula;
    ELSE
      l_start_date := LocalInfoRecord.start_date;
    END IF;

    IF LocalInfoRecord.end_date_type = 0 THEN
      GMD_RECIPE_GENERATE.calculate_date(l_start_date, LocalInfoRecord.Num_of_days, x_end_date);
      l_end_date := x_end_date;
    ELSE
      l_end_date := LocalInfoRecord.end_date;
    END IF;
    /*Bug 3735354 - Thomas Daniel */
    /*We need to reset the start date to be less than the end date for the setup */
    /*cases defined in the bug */
    IF l_end_date < l_start_date THEN
      l_start_date := TRUNC(l_end_date);
    END IF;

    OPEN c_get_formula_item;
    FETCH c_get_formula_item INTO LocalFormRecord;
      l_item_id := LocalFormRecord.inventory_item_id;
      l_revision := LocalFormRecord.revision;  --Krishna NPD Conv
      l_detail_uom := LocalFormRecord.detail_uom;
    CLOSE c_get_formula_item;

    l_recipe_vr_tbl.recipe_validity_rule_id := l_vr_id;
    l_recipe_vr_tbl.recipe_id := NULL;
    l_recipe_vr_tbl.recipe_no := NULL;
    l_recipe_vr_tbl.recipe_version := NULL;
    l_recipe_vr_tbl.user_id := l_user_id;
    l_recipe_vr_tbl.organization_id := l_orgn_id;
    l_recipe_vr_tbl.inventory_item_id := l_item_id;
    l_recipe_vr_tbl.revision := l_revision;--Krishna NPD Conv
    l_recipe_vr_tbl.item_no := NULL;
    IF p_recipe_use IS NULL THEN
      l_recipe_vr_tbl.recipe_use := LocalInfoRecord.recipe_use_prod||
                                    LocalInfoRecord.recipe_use_plan||
                                    LocalInfoRecord.recipe_use_cost||
                                    LocalInfoRecord.recipe_use_reg||
                                    LocalInfoRecord.recipe_use_tech;
    ELSE
      l_recipe_vr_tbl.recipe_use := p_recipe_use;
    END IF;

    l_recipe_vr_tbl.preference := l_preference;
    l_recipe_vr_tbl.start_date := l_start_date;
    l_recipe_vr_tbl.end_date := l_end_date;
    l_recipe_vr_tbl.min_qty := 0;
    l_recipe_vr_tbl.max_qty := 999999;
    l_recipe_vr_tbl.std_qty := LocalFormRecord.qty;
    l_recipe_vr_tbl.detail_uom := l_detail_uom;
    l_recipe_vr_tbl.inv_min_qty := 0;
    l_recipe_vr_tbl.inv_max_qty := 999999;
    l_recipe_vr_tbl.created_by := l_user_id;
    l_recipe_vr_tbl.creation_date := SYSDATE;
    l_recipe_vr_tbl.last_updated_by := l_user_id;
    l_recipe_vr_tbl.last_update_date := SYSDATE;
    l_recipe_vr_tbl.last_update_login := l_login_id;
    l_recipe_vr_tbl.delete_mark := 0;

  -- Bug# 4504631 kmotupal
  -- Added check for default status while retrieving recipe VR details
    get_status_details (V_entity_type   => 'VALIDITY',
                        V_orgn_id       => l_orgn_id,
                        X_entity_status => l_default_vr_status);

    l_recipe_vr_tbl.validity_rule_status := l_default_vr_status.entity_status;
    l_end_status := l_recipe_vr_tbl.validity_rule_status;

    IF LocalInfoRecord.managing_validity_rules = 0 THEN
      IF p_recipe_use IS NOT NULL THEN
        l_recipe_use := p_recipe_use;
      ELSIF LocalInfoRecord.recipe_use_prod = 1 THEN
        l_recipe_use := 0;
      ELSIF LocalInfoRecord.recipe_use_plan = 1 THEN
        l_recipe_use := 1;
      ELSIF LocalInfoRecord.recipe_use_cost = 1 THEN
        l_recipe_use := 2;
      ELSIF LocalInfoRecord.recipe_use_reg = 1 THEN
        l_recipe_use := 3;
      ELSIF LocalInfoRecord.recipe_use_tech = 1 THEN
        l_recipe_use := 4;
      END IF;

      OPEN Cur_get_max_pref (l_item_id, l_orgn_id,
                             l_start_date, l_end_date, l_recipe_use);
      FETCH Cur_get_max_pref INTO l_preference;
      CLOSE Cur_get_max_pref;
      l_preference := NVL(l_preference,0) + 1;
    ELSE
      l_preference := 1;
    END IF;
    l_recipe_vr_tbl.preference := l_preference;
  END IF;
  CLOSE c_get_recipe_info;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

END retrieve_vr;


/*+==============================================================================================================================+
** Name    : retrieve_recipe
** Notes       : This procedure receives as input recipe record and
**               creates recipe records.                |
**
**               If everything is fine then OUT parameter
**               x_return_status is set to 'S' else appropriate
**               error message is put on the stack and error
**               is returned.
**
** HISTORY
**   05-Apr-2004 B3604554 GK  Created.
**   21-May-2004 B3642937 GK  Assigned the default_status to the recipe_status
**   24-May-2004 B3643405 GK  Added the statement orgn IS NULL to cursor c_get_recipe_info
**  25-May-2004 B3645706  GK  Removed the statement orgn IS NULL to cursor c_get_recipe_info
**					  and created a new cursor c_get_global_info to accomodate for global and
**					  so that the orgn code will pick up the correct configuration information
**  25-May-2004 B3653935 GK   Changed variables login_id, user_id to be assigned to FND_PROFILE.VALUE
**  01-dec-2004 kkillams      orgn_code is replaced with organization_id/owner_organization_id w.r.t. 4004501
**  18-APR-2006 kmotupal      Added check for default status while retrieving recipe details
**  30-MAY-2006 Kalyani	      Bug 5218106 Added code to default recipe_type from orgn parameters.
**  03-Jan-07   Kapil M       LCF-GMO ME : Bug#5458666. Added routing_id to retrieve_recipe
**  13-FEB-2008 Uday Phadtare Bug 6758122. Retrive formula_desc1 from fm_form_mst_tl when formula_desc1 in fm_form_mst_b is NULL.
**+==============================================================================================================================+*/


PROCEDURE retrieve_recipe(p_formula_id IN NUMBER,
                          p_routing_id IN NUMBER DEFAULT NULL,
			  l_recipe_tbl OUT NOCOPY GMD_RECIPE_HEADER.recipe_hdr,
			  l_recipe_flex	OUT NOCOPY GMD_RECIPE_HEADER.flex,
			  x_return_status OUT NOCOPY 	VARCHAR2) IS

-- Cursors
  CURSOR c_get_formula_info IS
    SELECT 	formula_no, formula_vers, formula_desc1,
                owner_organization_id,  formula_status, owner_id
    FROM	fm_form_mst_b
    WHERE	formula_id = p_formula_id;
  LocalFormRecord		c_get_formula_info%ROWTYPE;

  -- Kapil LCF-GMO ME : Bug#5458666
  CURSOR c_get_routing_info IS
    SELECT routing_no , routing_vers
    FROM GMD_ROUTINGS_B
    WHERE routing_id = p_routing_id;
    LocalRoutRecord     c_get_routing_info%ROWTYPE;

  CURSOR c_get_recipe_id IS
    SELECT gmd_recipe_id_s.NEXTVAL
    FROM   FND_DUAL;

  CURSOR c_get_item_id IS
    SELECT  inventory_item_id
    FROM    fm_matl_dtl
    WHERE   formula_id = p_formula_id
    AND	    line_type = 1;

  CURSOR c_get_recipe_info(l_orgn_id NUMBER) IS
    SELECT 	recipe_naming_convention, created_by, last_update_login
    FROM	gmd_recipe_generation
    WHERE 	(organization_id  = l_orgn_id OR
                 organization_id IS NULL)
    ORDER BY organization_id;
  LocalInfoRecord		c_get_recipe_info%ROWTYPE;

CURSOR c_get_version(l_recipe_no VARCHAR2) IS
	SELECT	max(recipe_version)
	FROM	gmd_recipes_b
	WHERE	recipe_no = l_recipe_no;
LocalVersRecord		c_get_version%ROWTYPE;

CURSOR c_check_recipe(l_recipe_no VARCHAR2) IS
	SELECT	*
	FROM	gmd_recipes_b
	WHERE	recipe_no = l_recipe_no;
LocalCheckRecord	c_check_recipe%ROWTYPE;

CURSOR	c_get_item(l_item_id NUMBER) IS
	SELECT	description item_desc1, concatenated_segments item_no
	FROM	mtl_system_items_kfv
	WHERE	inventory_item_id = l_item_id;
LocalItemRecord		c_get_item%ROWTYPE;

--Bug 6758122
CURSOR c_get_frmdesc IS
       SELECT formula_desc1
       FROM   fm_form_mst_tl
       WHERE  formula_id = p_formula_id
       AND    language   = USERENV('LANG');

-- Local Variables
l_recipe_id			NUMBER(15);
l_recipe_version		NUMBER(5) := 1;
l_delete_mark			NUMBER(5);
l_recipe_name			NUMBER(5);
i				BINARY_INTEGER := 2;
l_user_id       		FND_USER.user_id%TYPE; --NUMBER;
l_login_id      		NUMBER;
l_recipe_no			VARCHAR2(32);
l_orgn_ID 			NUMBER;
l_item_id			NUMBER;
l_recipe_description		VARCHAR2(70);
l_default_recipe_status 	gmd_api_grp.status_rec_type;

l_routing_no  VARCHAR2(32) := NULL;
l_routing_vers NUMBER := NULL;
-- Exceptions
create_recipe_err	EXCEPTION;

BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  OPEN c_get_recipe_id;
  FETCH c_get_recipe_id INTO l_recipe_id;
  CLOSE c_get_recipe_id;

  OPEN c_get_formula_info;
  FETCH c_get_formula_info INTO LocalFormRecord;
  IF c_get_formula_info%FOUND THEN
    l_orgn_id := LocalFormRecord.owner_organization_id;

    OPEN c_get_recipe_info(l_orgn_id);
    FETCH c_get_recipe_info INTO LocalInfoRecord;
    IF c_get_recipe_info%FOUND THEN
      l_recipe_name := LocalInfoRecord.recipe_naming_convention;
       l_user_id := FND_PROFILE.VALUE('USER_ID');
       l_login_id := FND_PROFILE.VALUE ('LOGIN_ID');
    END IF;
    CLOSE c_get_recipe_info;

    IF l_recipe_name = 0 THEN
      OPEN c_get_item_id;
      FETCH c_get_item_id INTO l_item_id;
      CLOSE c_get_item_id;

      OPEN c_get_item(l_item_id);
      FETCH c_get_item INTO LocalItemRecord;
      IF c_get_item%FOUND THEN
        l_recipe_no := LocalItemRecord.item_no;
        l_recipe_description := LocalItemRecord.item_desc1;
        OPEN c_check_recipe(l_recipe_no);
        FETCH c_check_recipe INTO LocalCheckRecord;
        IF c_check_recipe%FOUND THEN
          OPEN c_get_version(l_recipe_no);
          FETCH c_get_version INTO l_recipe_version;
            l_recipe_version := l_recipe_version + 1;
          CLOSE c_get_version;
        ELSIF (LocalFormRecord.formula_vers = 0) THEN
          -- If formula vers is 0, start recipe vers with 0
	  l_recipe_version := 0;
        ELSE
          -- Else start recipe vers with 1
	  l_recipe_version := 1;
        END IF;
        CLOSE c_check_recipe;
      END IF;
      CLOSE c_get_item;
    ELSE
      l_recipe_no := LocalFormRecord.formula_no;
      OPEN c_check_recipe(l_recipe_no);
      FETCH c_check_recipe INTO LocalCheckRecord;
      IF c_check_recipe%FOUND THEN
        OPEN c_get_version(l_recipe_no);
        FETCH c_get_version INTO l_recipe_version;
          l_recipe_version := l_recipe_version + 1;
        CLOSE c_get_version;
      ELSIF (LocalFormRecord.formula_vers = 0) THEN
	-- If formula vers is 0, start recipe vers with 0
	l_recipe_version := 0;
      ELSE
        -- Else start recipe vers with 1
	l_recipe_version := 1;
      END IF;
        l_recipe_description := LocalFormRecord.formula_desc1;
        --Bug 6758122
        IF l_recipe_description IS NULL THEN
           OPEN  c_get_frmdesc;
           FETCH c_get_frmdesc INTO l_recipe_description;
           CLOSE c_get_frmdesc;
        END IF;
    END IF;

    l_recipe_tbl.recipe_id := l_recipe_id;

    IF l_recipe_description IS NULL THEN
      l_recipe_description := l_recipe_no;
    END IF;
  -- Kapil LCF-GMO ME : Bug#5458666
  -- To get Routing details
    IF p_routing_id IS NOT NULL THEN
     OPEN c_get_routing_info;
     FETCH c_get_routing_info INTO LocalRoutRecord;
     l_routing_no := LocalRoutRecord.routing_no;
     l_routing_vers := LocalRoutRecord.routing_vers;
     CLOSE c_get_routing_info;
    END IF;

  -- Bug# 4504631 kmotupal
  -- Added check for default status while retrieving recipe details
    get_status_details (V_entity_type   => 'RECIPE',
                        V_orgn_id       => l_orgn_id,
                        X_entity_status => l_default_recipe_status);

    l_recipe_tbl.recipe_description := l_recipe_description;
    l_recipe_tbl.recipe_no := l_recipe_no;
    l_recipe_tbl.recipe_version := l_recipe_version;
    l_recipe_tbl.user_id := l_user_id;
    l_recipe_tbl.user_name := NULL;
    l_recipe_tbl.owner_organization_id := l_orgn_id;
    l_recipe_tbl.creation_organization_id := l_orgn_id;
    l_recipe_tbl.formula_id := p_formula_id;
    l_recipe_tbl.formula_no := LocalFormRecord.formula_no;
    l_recipe_tbl.formula_vers := LocalFormRecord.formula_vers;
  -- Kapil LCF-GMO ME : Bug#5458666 , Pass the routing details.
    l_recipe_tbl.routing_id := p_routing_id;
    l_recipe_tbl.routing_no := l_routing_no;
    l_recipe_tbl.routing_vers := l_routing_vers;
    l_recipe_tbl.project_id := NULL;
    l_recipe_tbl.recipe_status := l_default_recipe_status.entity_status;
    l_recipe_tbl.planned_process_loss := NULL;
    l_recipe_tbl.text_code := NULL;
    l_recipe_tbl.delete_mark := 0;
    l_recipe_tbl.creation_date := sysdate;
    l_recipe_tbl.created_by := l_user_id;
    l_recipe_tbl.last_updated_by := l_user_id;
    l_recipe_tbl.last_update_date := sysdate;
    l_recipe_tbl.last_update_login := l_login_id;
    l_recipe_tbl.owner_id := LocalFormRecord.owner_id;
    l_recipe_tbl.owner_organization_id := LocalFormRecord.owner_organization_id;
    l_recipe_tbl.owner_lab_type := NULL;
    l_recipe_tbl.calculate_step_quantity := 0;
    -- Bug 5218106
    l_recipe_tbl.recipe_type:=get_recipe_type(l_orgn_id);


  END IF;  --If c_get_formula_info%found

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  CLOSE c_get_formula_info;

END retrieve_recipe;

/*+========================================================================+
** Name    : check_orgn_status
** Created 18-OCT-2004
** Description
** Function to check the organization passed is process enabled.
**+========================================================================+*/

   FUNCTION check_orgn_status (V_organization_id  IN NUMBER) RETURN BOOLEAN IS
     CURSOR Check_orgn_exists IS
         SELECT 1
	 FROM   mtl_parameters
         WHERE  organization_id = V_organization_id
	 AND    process_enabled_flag = 'Y';

      l_temp	NUMBER;
    BEGIN
      IF (V_organization_id IS NOT NULL) THEN
         --Check the organization id passed is process enabled if not raise an error message
         OPEN check_orgn_exists;
         FETCH check_orgn_exists INTO l_temp;
         IF (check_orgn_exists%NOTFOUND) THEN
           CLOSE check_orgn_exists;
           RETURN FALSE;
	 END IF;
         CLOSE check_orgn_exists;
      END IF;
      RETURN TRUE;
    END check_orgn_status;

/*###############################################################
  # NAME
  #	check_item_exists
  # SYNOPSIS
  #	proc check_item_exists
  # DESCRIPTION
  #      Procedure used to check if the organization has access to the items
  #     Kalyani 23-Jun-2006 B5350197 Serial control items not allowed.
  #     Raju 29-Jan-2008 B6772070 Added AND SERIAL_NUMBER_CONTROL_CODE in (1,6) in where clause.
  #                      TO allow serial control items at sales order issue.
  ###############################################################*/

  PROCEDURE check_item_exists (p_formula_id 		IN NUMBER,
                               x_return_status 		OUT NOCOPY VARCHAR2,
                               p_organization_id 	IN NUMBER DEFAULT NULL,
                               p_orgn_code 		IN VARCHAR2 DEFAULT NULL,
                               p_production_check	IN BOOLEAN DEFAULT FALSE,
                               p_costing_check		IN BOOLEAN DEFAULT FALSE) IS
    X_ret		NUMBER;
    X_item_no		VARCHAR2(2000);
    X_organization_id 	NUMBER;
    X_orgn_code		VARCHAR2(3);
    X_item_list		VARCHAR2(2000);
    X_item_revision	VARCHAR2(2000);
    X_item_rev_list	VARCHAR2(2000);

    CURSOR Cur_check_item (V_organization_id NUMBER) IS
      SELECT inventory_item_id
      FROM   fm_matl_dtl d
      WHERE  formula_id = p_formula_id
      AND    NOT EXISTS (SELECT 1
                         FROM   mtl_system_items_b
                         WHERE  inventory_item_id = d.inventory_item_id
                         AND    organization_id = V_organization_id
			 AND    recipe_enabled_flag = 'Y');
    CURSOR Cur_item IS
      SELECT inventory_item_id
      FROM   fm_matl_dtl
      WHERE  formula_id = p_formula_id;

    CURSOR Cur_check_item_revision (V_organization_id NUMBER) IS
      SELECT d.revision, b.concatenated_segments
      FROM   fm_matl_dtl d, mtl_system_items_kfv b
      WHERE  formula_id = p_formula_id
      AND    b.inventory_item_id = d.inventory_item_id
      AND    b.organization_id = V_organization_id
      AND    revision IS NOT NULL
      AND    NOT EXISTS (SELECT 1
                         FROM   mtl_item_revisions
                         WHERE  inventory_item_id = d.inventory_item_id
                         AND    organization_id = V_organization_id
                         AND    revision = d.revision);

    CURSOR Cur_check_item_prod_enabled (V_organization_id NUMBER) IS
      SELECT inventory_item_id
      FROM   fm_matl_dtl d
      WHERE  formula_id = p_formula_id
      AND    NOT EXISTS (SELECT 1
                         FROM   mtl_system_items_b
                         WHERE  inventory_item_id = d.inventory_item_id
                         AND    organization_id = V_organization_id
                         AND    process_execution_enabled_flag = 'Y');

    CURSOR Cur_check_item_cost_enabled (V_organization_id NUMBER) IS
      SELECT inventory_item_id
      FROM   fm_matl_dtl d
      WHERE  formula_id = p_formula_id
      AND    NOT EXISTS (SELECT 1
                         FROM   mtl_system_items_b
                         WHERE  inventory_item_id = d.inventory_item_id
                         AND    organization_id = V_organization_id
                         AND    process_costing_enabled_flag = 'Y');

    -- Bug 5350197
    CURSOR Cur_check_item_serial_enabled (V_organization_id NUMBER) IS
      SELECT inventory_item_id
      FROM   fm_matl_dtl d
      WHERE  formula_id = p_formula_id
      AND    NOT EXISTS (SELECT 1
                         FROM   mtl_system_items_b
                         WHERE  inventory_item_id = d.inventory_item_id
                         AND    organization_id = V_organization_id
			 AND    serial_number_control_code IN (1,6));


    CURSOR Cur_get_item_no (V_inventory_item_id NUMBER) IS
      SELECT concatenated_segments
      FROM   mtl_system_items_kfv
      WHERE  inventory_item_id = V_inventory_item_id;

    CURSOR Cur_get_org_id (V_org_code VARCHAR2) IS
      SELECT organization_id
      FROM   mtl_parameters
      WHERE  organization_code = V_org_code;

    CURSOR Cur_get_org_code (V_org_id NUMBER) IS
      SELECT organization_code
      FROM   mtl_parameters
      WHERE  organization_id = V_org_id;

    ORGN_MISSING	EXCEPTION;
    FORMULA_MISSING	EXCEPTION;
    ITEM_MISSING	EXCEPTION;

  BEGIN
    /* Initialize the return status */
    X_return_status := FND_API.g_ret_sts_success;
    IF p_formula_id IS NULL THEN
      RAISE formula_missing;
    END IF;

    IF p_organization_id IS NULL THEN
      IF p_orgn_code IS NULL THEN
        RAISE orgn_missing;
      END IF;

      OPEN Cur_get_org_id (P_orgn_code);
      FETCH Cur_get_org_id INTO X_organization_id;
      CLOSE Cur_get_org_id;
    ELSE
      X_organization_id := p_organization_id;
    END IF;

    X_item_list := NULL;
    X_item_rev_list := NULL;
    OPEN Cur_check_item (X_organization_id);
    LOOP
      FETCH Cur_check_item INTO X_ret;
      EXIT WHEN Cur_check_item%NOTFOUND;

      OPEN Cur_get_item_no (X_ret);
      FETCH Cur_get_item_no INTO X_item_no;
      CLOSE Cur_get_item_no;

      IF X_item_list IS NULL THEN
        X_item_list := X_item_list||X_item_no;
      ELSE
        X_item_list := X_item_list||','||X_item_no;
      END IF;
    END LOOP;
    CLOSE Cur_check_item;

    IF X_item_list IS NOT NULL THEN
      IF p_orgn_code IS NULL THEN
        OPEN Cur_get_org_code (X_organization_id);
        FETCH Cur_get_org_code INTO X_orgn_code;
        CLOSE Cur_get_org_code;
      ELSE
        X_orgn_code := p_orgn_code;
      END IF;

      FND_MESSAGE.SET_NAME('GMD', 'GMD_RCP_ITEMORG_NOT_FOUND');
      FND_MESSAGE.SET_TOKEN('ORGN',X_orgn_code);
      FND_MESSAGE.SET_TOKEN('ITEM',X_item_list);
      FND_MSG_PUB.ADD;
      X_return_status := FND_API.g_ret_sts_error;
      RAISE ITEM_MISSING;
    END IF;

    OPEN Cur_check_item_revision (X_organization_id);
    LOOP
      FETCH Cur_check_item_revision INTO X_item_revision, X_item_no;
      EXIT WHEN Cur_check_item_revision%NOTFOUND;

        IF X_item_rev_list IS NULL THEN
          X_item_rev_list := X_item_rev_list||X_item_no||','||X_item_revision;
        ELSE
          X_item_rev_list := X_item_rev_list||','||X_item_no||','||X_item_revision;
        END IF;
      END LOOP;
      CLOSE Cur_check_item_revision;

      IF X_item_rev_list IS NOT NULL THEN
        IF p_orgn_code IS NULL THEN
          OPEN Cur_get_org_code (X_organization_id);
          FETCH Cur_get_org_code INTO X_orgn_code;
          CLOSE Cur_get_org_code;
        ELSE
          X_orgn_code := p_orgn_code;
        END IF;

        FND_MESSAGE.SET_NAME('GMD', 'GMD_RCP_ITEMORG_REV_NOT_FOUND');
        FND_MESSAGE.SET_TOKEN('ORGN',X_orgn_code);
        FND_MESSAGE.SET_TOKEN('ITEM REVISION',X_item_rev_list);
        FND_MSG_PUB.ADD;
        X_return_status := FND_API.g_ret_sts_error;
        RAISE ITEM_MISSING;
     END IF;

     IF p_production_check THEN
      OPEN Cur_check_item_prod_enabled (X_organization_id);
      LOOP
        FETCH Cur_check_item_prod_enabled INTO X_ret;
        EXIT WHEN Cur_check_item_prod_enabled%NOTFOUND;

        OPEN Cur_get_item_no (X_ret);
        FETCH Cur_get_item_no INTO X_item_no;
        CLOSE Cur_get_item_no;

        IF X_item_list IS NULL THEN
          X_item_list := X_item_list||X_item_no;
        ELSE
          X_item_list := X_item_list||','||X_item_no;
        END IF;
      END LOOP;
      CLOSE Cur_check_item_prod_enabled;

      IF X_item_list IS NOT NULL THEN
        IF p_orgn_code IS NULL THEN
          OPEN Cur_get_org_code (X_organization_id);
          FETCH Cur_get_org_code INTO X_orgn_code;
          CLOSE Cur_get_org_code;
        ELSE
          X_orgn_code := p_orgn_code;
        END IF;

	FND_MESSAGE.SET_NAME('GMD', 'GMD_PROD_ITEMORG_NOT_FOUND');
        FND_MESSAGE.SET_TOKEN('ORGN',X_orgn_code);
        FND_MESSAGE.SET_TOKEN('ITEM',X_item_list);
        FND_MSG_PUB.ADD;
        X_return_status := FND_API.g_ret_sts_error;
        RAISE ITEM_MISSING;
      END IF;
    END IF;
    IF p_costing_check THEN
      OPEN Cur_check_item_cost_enabled (X_organization_id);
      LOOP
        FETCH Cur_check_item_cost_enabled INTO X_ret;
        EXIT WHEN Cur_check_item_cost_enabled%NOTFOUND;

        OPEN Cur_get_item_no (X_ret);
        FETCH Cur_get_item_no INTO X_item_no;
        CLOSE Cur_get_item_no;

        IF X_item_list IS NULL THEN
          X_item_list := X_item_list||X_item_no;
        ELSE
          X_item_list := X_item_list||','||X_item_no;
        END IF;
      END LOOP;
      CLOSE Cur_check_item_cost_enabled;

      IF X_item_list IS NOT NULL THEN
        IF p_orgn_code IS NULL THEN
          OPEN Cur_get_org_code (X_organization_id);
          FETCH Cur_get_org_code INTO X_orgn_code;
          CLOSE Cur_get_org_code;
        ELSE
          X_orgn_code := p_orgn_code;
        END IF;

	FND_MESSAGE.SET_NAME('GMD', 'GMD_COST_ITEMORG_NOT_FOUND');
        FND_MESSAGE.SET_TOKEN('ORGN',X_orgn_code);
        FND_MESSAGE.SET_TOKEN('ITEM',X_item_list);
        FND_MSG_PUB.ADD;
        X_return_status := FND_API.g_ret_sts_error;
        RAISE ITEM_MISSING;
      END IF;
    END IF;

     --Bug 5350197
     OPEN Cur_check_item_serial_enabled (X_organization_id);
      LOOP
        FETCH Cur_check_item_serial_enabled INTO X_ret;
        EXIT WHEN Cur_check_item_serial_enabled%NOTFOUND;

        OPEN Cur_get_item_no (X_ret);
        FETCH Cur_get_item_no INTO X_item_no;
        CLOSE Cur_get_item_no;

        IF X_item_list IS NULL THEN
          X_item_list := X_item_list||X_item_no;
        ELSE
          X_item_list := X_item_list||','||X_item_no;
        END IF;
      END LOOP;
      CLOSE Cur_check_item_serial_enabled;

      IF X_item_list IS NOT NULL THEN
        IF p_orgn_code IS NULL THEN
          OPEN Cur_get_org_code (X_organization_id);
          FETCH Cur_get_org_code INTO X_orgn_code;
          CLOSE Cur_get_org_code;
        ELSE
          X_orgn_code := p_orgn_code;
        END IF;

	FND_MESSAGE.SET_NAME('GMD', 'GMD_SERIAL_ITEMS_NOT_ALLOWED');
        FND_MESSAGE.SET_TOKEN('ORGN',X_orgn_code);
        FND_MESSAGE.SET_TOKEN('ITEM',X_item_list);
        FND_MSG_PUB.ADD;
        X_return_status := FND_API.g_ret_sts_error;
        RAISE ITEM_MISSING;
      END IF;

  EXCEPTION
    WHEN formula_missing THEN
      X_return_status := FND_API.g_ret_sts_error;
      gmd_api_grp.log_message('GMD_MISSING', 'FORMULA_ID');
    WHEN item_missing THEN
      X_return_status := FND_API.g_ret_sts_error;
    WHEN orgn_missing THEN
      X_return_status := FND_API.g_ret_sts_error;
      gmd_api_grp.log_message('GMD_MISSING', 'ORGN_CODE');
    WHEN OTHERS THEN
      X_return_status := FND_API.g_ret_sts_unexp_error;
      fnd_msg_pub.add_exc_msg (l_package_name, 'CHECK_ITEM_EXISTS');
  END check_item_exists;

  /* *********************************************************************** *
  * Function                                                                *
  *   Validate_um                                                           *
  *   Parameter : item_uom_code IN varchar2                                 *
  * Description                                                             *
  *  Checks if the uom_code passed is valid - Return True if it exists      *
  * *********************************************************************** */
  FUNCTION Validate_um(pItem_uom_code IN VARCHAR2) RETURN BOOLEAN IS
    Cursor Item_um_cur IS
      Select 1 from dual
      Where exists (Select 1 from mtl_units_of_measure
                    Where uom_code = pItem_uom_code);
    l_dummy_cnt NUMBER;
  BEGIN
    OPEN Item_um_cur;
    FETCH Item_um_cur into l_dummy_cnt;
    CLOSE Item_um_cur;
    Return (l_dummy_cnt IS NOT NULL);
  END Validate_um;


/*======================================================================
 --  PROCEDURE :
 --   FETCH_PARM_VALUES
 --
 --  DESCRIPTION:
 --        This procedure is used to fetch the parameter values for a
 --  particular orgn_id. If orgn_id is NULL return the Global orgn. parameters
 --
 --  HISTORY
 --        Sriram.S  05-NOV-2004  Created
 --===================================================================== */

PROCEDURE FETCH_PARM_VALUES (P_orgn_id       IN  NUMBER,
                             X_out_rec       OUT NOCOPY GMD_PARAMETERS_DTL_PKG.parameter_rec_type,
                             X_return_status OUT NOCOPY VARCHAR2) IS

CURSOR Cur_get_parameters IS
        SELECT parameter_name, parameter_value, parameter_type
        FROM   gmd_parameters_hdr h, gmd_parameters_dtl d
        WHERE  h.parameter_id = d.parameter_id
        AND    h.organization_id = P_orgn_id
        UNION
        SELECT parameter_name, parameter_value, parameter_type
        FROM   gmd_parameters_hdr h, gmd_parameters_dtl d
        WHERE  h.parameter_id = d.parameter_id
        AND    h.organization_id IS NULL
        AND  NOT EXISTS (SELECT 1
                         FROM  gmd_parameters_hdr h1, gmd_parameters_dtl d1
                         WHERE h1.parameter_id    = d1.parameter_id
                         AND   h1.organization_id = P_orgn_id
                         AND   d1.parameter_name  = d.parameter_name);


CURSOR Cur_get_lab_plant_ind IS
        SELECT plant_ind, lab_ind
        FROM gmd_parameters_hdr
        WHERE organization_id = P_orgn_id;

l_Cur_get_parameters_fetch BOOLEAN := FALSE;

PARM_NOT_FOUND EXCEPTION;

BEGIN

/* Set return status to success initially */
x_return_status := FND_API.G_RET_STS_SUCCESS;

OPEN Cur_get_lab_plant_ind;
FETCH Cur_get_lab_plant_ind INTO x_out_rec.plant_ind, x_out_rec.lab_ind;
IF P_orgn_id IS NOT NULL AND Cur_get_lab_plant_ind%NOTFOUND THEN
        -- If orgn id is NOT NULL and cursor fetched no record, raise exception
	RAISE PARM_NOT_FOUND;
END IF;
CLOSE Cur_get_lab_plant_ind;

FOR l_rec IN Cur_get_parameters LOOP
l_Cur_get_parameters_fetch := TRUE;

 IF l_rec.parameter_type = 1 THEN
        IF l_rec.parameter_name = 'GMD_FORMULA_VERSION_CONTROL'  THEN
                x_out_rec.gmd_formula_version_control := l_rec.parameter_value;
        ELSIF l_rec.parameter_name = 'GMD_BYPRODUCT_ACTIVE'  THEN
                x_out_rec.gmd_byproduct_active := l_rec.parameter_value;
        ELSIF l_rec.parameter_name = 'GMD_ZERO_INGREDIENT_QTY'  THEN
                x_out_rec.gmd_zero_ingredient_qty := l_rec.parameter_value;
        ELSIF l_rec.parameter_name = 'GMD_MASS_UM_TYPE'  THEN
                x_out_rec.gmd_mass_um_type := l_rec.parameter_value;
        ELSIF l_rec.parameter_name = 'GMD_VOLUME_UM_TYPE'  THEN
                x_out_rec.gmd_volume_um_type := l_rec.parameter_value;
        ELSIF l_rec.parameter_name = 'FM_YIELD_TYPE'  THEN
                x_out_rec.fm_yield_type := l_rec.parameter_value;
        ELSIF l_rec.parameter_name = 'GMD_DEFAULT_FORM_STATUS'  THEN
                x_out_rec.gmd_default_form_status := l_rec.parameter_value;
        ELSIF l_rec.parameter_name = 'GMI_LOTGENE_ENABLE_FMSEC'  THEN
                x_out_rec.gmi_lotgene_enable_fmsec := l_rec.parameter_value;
        ELSIF l_rec.parameter_name = 'FM$DEFAULT_RELEASE_TYPE'  THEN
                x_out_rec.fm$default_release_type := l_rec.parameter_value;
        END IF;
  ELSIF l_rec.parameter_type = 2 THEN
        IF l_rec.parameter_name = 'GMD_OPERATION_VERSION_CONTROL'  THEN
                x_out_rec.gmd_operation_version_control := l_rec.parameter_value;
        ELSIF l_rec.parameter_name = 'GMD_DEFAULT_OPRN_STATUS'  THEN
                x_out_rec.gmd_default_oprn_status := l_rec.parameter_value;
        END IF;
  ELSIF l_rec.parameter_type = 3 THEN
        IF l_rec.parameter_name = 'GMD_ROUTING_VERSION_CONTROL'  THEN
                x_out_rec.gmd_routing_version_control := l_rec.parameter_value;
        ELSIF l_rec.parameter_name = 'GMD_DEFAULT_ROUT_STATUS'  THEN
                x_out_rec.gmd_default_rout_status := l_rec.parameter_value;
        ELSIF l_rec.parameter_name = 'STEPRELEASE_TYPE'  THEN
                x_out_rec.steprelease_type := l_rec.parameter_value;
        ELSIF l_rec.parameter_name = 'GMD_ENFORCE_STEP_DEPENDENCY'  THEN
                x_out_rec.gmd_enforce_step_dependency := l_rec.parameter_value;
        END IF;
  ELSIF l_rec.parameter_type = 4 THEN
        IF l_rec.parameter_name = 'GMD_RECIPE_VERSION_CONTROL'  THEN
                x_out_rec.gmd_recipe_version_control := l_rec.parameter_value;
        ELSIF l_rec.parameter_name = 'GMD_PROC_INSTR_PARAGRAPH'  THEN
                x_out_rec.gmd_proc_instr_paragraph := l_rec.parameter_value;
        ELSIF l_rec.parameter_name = 'GMD_DEFAULT_RECP_STATUS'  THEN
                x_out_rec.gmd_default_recp_status := l_rec.parameter_value;
        ELSIF l_rec.parameter_name = 'GMD_DEFAULT_VALR_STATUS'  THEN
                x_out_rec.gmd_default_valr_status := l_rec.parameter_value;
        ELSIF l_rec.parameter_name = 'GMD_RECIPE_TYPE'  THEN
                x_out_rec.gmd_recipe_type := l_rec.parameter_value;
        END IF;
  ELSIF l_rec.parameter_type = 6 THEN
        IF l_rec.parameter_name = 'GMD_COST_SOURCE_ORGN'  THEN
                x_out_rec.gmd_cost_source_orgn := l_rec.parameter_value;
        ELSIF l_rec.parameter_name = 'GMD_DEFAULT_SPEC_STATUS'  THEN
                x_out_rec.gmd_default_spec_status := l_rec.parameter_value;
	END IF;
 END IF;
END LOOP;

IF NOT l_Cur_get_parameters_fetch THEN
        -- If Flag is not set, raise exception.
	RAISE PARM_NOT_FOUND;
END IF;

EXCEPTION
WHEN PARM_NOT_FOUND THEN
	fnd_message.set_name ('GMD', 'GMD_PARM_NOT_FOUND');
        fnd_msg_pub.add;
        x_return_status := FND_API.G_RET_STS_SUCCESS;
WHEN OTHERS THEN
	fnd_message.set_name ('GMD', 'GMD_PARM_NOT_FOUND');
        fnd_msg_pub.add;
        x_return_status := FND_API.G_RET_STS_ERROR;

END FETCH_PARM_VALUES;


 /*======================================================================
 --  PROCEDURE :
 --   FETCH_PARM_VALUES
 --
 --  DESCRIPTION:
 --        This procedure is used to fetch the parameter value of the profile name passed for a
 --  particular orgn_id. If orgn_id is NULL return the parameter value for Global orgn.
 --
 --  HISTORY
 --        Sriram.S  23-NOV-2004  Created
 --===================================================================== */

PROCEDURE FETCH_PARM_VALUES (P_orgn_id       IN  NUMBER,
                             P_parm_name     IN  VARCHAR2,
                             P_parm_value    OUT NOCOPY VARCHAR2,
                             X_return_status OUT NOCOPY VARCHAR2) IS

CURSOR Cur_get_parameter IS
        SELECT parameter_value
        FROM   gmd_parameters_hdr h, gmd_parameters_dtl d
        WHERE  h.parameter_id = d.parameter_id
        AND    h.organization_id = P_orgn_id
        AND    d.parameter_name = P_parm_name
        UNION
        SELECT parameter_value
        FROM   gmd_parameters_hdr h, gmd_parameters_dtl d
        WHERE  h.parameter_id = d.parameter_id
        AND    h.organization_id IS NULL
        AND    d.parameter_name = P_parm_name
        AND  NOT EXISTS (SELECT 1
                         FROM  gmd_parameters_hdr h1, gmd_parameters_dtl d1
                         WHERE h1.parameter_id    = d1.parameter_id
                         AND   h1.organization_id = P_orgn_id
                         AND   d1.parameter_name  = d.parameter_name);

PARM_NOT_FOUND EXCEPTION;

BEGIN

/* Set return status to success initially */
x_return_status := FND_API.G_RET_STS_SUCCESS;

OPEN Cur_get_parameter;
FETCH Cur_get_parameter INTO P_parm_value;
IF Cur_get_parameter%NOTFOUND THEN
	RAISE PARM_NOT_FOUND;
END IF;
CLOSE Cur_get_parameter;

EXCEPTION
WHEN PARM_NOT_FOUND THEN
   x_return_status := FND_API.G_RET_STS_SUCCESS;
WHEN OTHERS THEN
  fnd_msg_pub.add_exc_msg (l_package_name, 'FETCH_PARM_VALUES');
  x_return_status := FND_API.G_RET_STS_ERROR;
END FETCH_PARM_VALUES;

-- Bug number 4479101
FUNCTION derive_ingredent_end (P_substitution_id  IN NUMBER,
                               p_item_id          IN NUMBER,
                               p_exclude_context  IN VARCHAR2) RETURN DATE IS

l_count              NUMBER;
l_ingredent_end_date DATE;
l_item_id            NUMBER;

CURSOR cur_item_id IS
SELECT original_inventory_item_id FROM GMD_ITEM_SUBSTITUTION_HDR_B
                                  WHERE substitution_id = p_substitution_id;
CURSOR cur_count IS
SELECT count(1) FROM GMD_ITEM_SUBSTITUTION_HDR_B
                WHERE original_inventory_item_id = l_item_id
                AND ( (p_exclude_context = 'Y'  AND substitution_id <> p_substitution_id)
                       OR p_exclude_context = 'N'
                    );
CURSOR cur_s_sub_date IS
SELECT start_date FROM GMD_ITEM_SUBSTITUTION_HDR_B
                  WHERE original_inventory_item_id = l_item_id
                  AND ( (p_exclude_context = 'Y' AND substitution_id <> p_substitution_id)
                      OR p_exclude_context = 'N'
                      );
CURSOR cur_m_sub_date IS
SELECT start_date FROM GMD_ITEM_SUBSTITUTION_HDR_B
                  WHERE original_inventory_item_id = l_item_id
                  AND ( (p_exclude_context = 'Y'  AND substitution_id <> p_substitution_id)
                        OR p_exclude_context = 'N'
                      )
                  ORDER BY START_DATE;
BEGIN
  IF (p_substitution_id IS NULL AND p_item_id IS NULL) OR
     (p_substitution_id IS NOT NULL AND p_item_id IS NOT NULL) OR
     (p_exclude_context ='Y' AND p_substitution_id IS NULL)THEN
     RETURN NULL;
  END IF;

  IF p_item_id IS NOT NULL THEN
     l_item_id := p_item_id;
  ELSE
     OPEN cur_item_id;
     FETCH cur_item_id INTO l_item_id;
     CLOSE cur_item_id;
  END IF;

  OPEN cur_count;
  FETCH cur_count INTO l_count;
  CLOSE cur_count;

  IF l_count = 0 THEN
     RETURN NULL;
  ELSIF l_count = 1 THEN
     OPEN cur_s_sub_date;
     FETCH cur_s_sub_date INTO l_ingredent_end_date;
     CLOSE cur_s_sub_date;
     RETURN l_ingredent_end_date;
  ELSE
     OPEN cur_m_sub_date;
     FETCH cur_m_sub_date INTO l_ingredent_end_date;
     CLOSE cur_m_sub_date;
     RETURN l_ingredent_end_date;
  END IF;
END derive_ingredent_end;

/*+========================================================================+
** Name    : update_end_date
** Notes       : This procedure updates the material end dates based on
**               the substitution start date
**               If everything is fine then OUT parameter
**               x_return_status is set to 'S' else appropriate
**               error message is put on the stack and error
**               is returned.
**
** HISTORY
**   30-Apr-2005 B4479101 TDaniel  Created.
**   28-Nov-2006 B5640547 akaruppa Removed the organization_id check when
**                                 updating fm_matl_dtl with end date.
**+========================================================================+*/

PROCEDURE update_end_date (p_substitution_id IN NUMBER) IS

  CURSOR Cur_get_substitution IS
    SELECT i.original_inventory_item_id, i.start_date, i.substitution_status,
           f.formula_id, i.owner_organization_id
    FROM   gmd_item_substitution_hdr_b i, gmd_formula_substitution f
    WHERE  i.substitution_id = p_substitution_id
    AND    i.substitution_id = f.substitution_id;

  CURSOR Cur_check_substitute (V_formula_id NUMBER, V_item_id NUMBER, V_orgn_id NUMBER) IS
    SELECT MIN(i.start_date)
    FROM   gmd_item_substitution_hdr_b i, gmd_formula_substitution f
    WHERE  f.formula_id = V_formula_id
    AND    i.original_inventory_item_id = V_item_id
    AND    i.owner_organization_id = V_orgn_id
    AND    i.substitution_id <> p_substitution_id
    AND    i.substitution_id = f.substitution_id
    AND    i.substitution_status BETWEEN 700 AND 799;

  l_start_date DATE;

BEGIN
  FOR l_rec IN Cur_get_substitution LOOP
    /* Substitution is approved so lets update the formula line end date */
    IF l_rec.substitution_status BETWEEN 700 AND 799 THEN
      UPDATE fm_matl_dtl
      SET    ingredient_end_date = l_rec.start_date
      WHERE  formula_id = l_rec.formula_id
      AND    line_type = -1
      AND    inventory_item_id = l_rec.original_inventory_item_id
--      AND    organization_id   = l_rec.owner_organization_id
      AND    (ingredient_end_date IS NULL OR ingredient_end_date > l_rec.start_date);
    /* If the substitution is obsolete then we need to reset the end date if it was stamped */
    /* by the current list */
    ELSIF l_rec.substitution_status BETWEEN 1000 AND 1099 THEN
      OPEN Cur_check_substitute (l_rec.formula_id,
                                 l_rec.original_inventory_item_id,
                                 l_rec.owner_organization_id);
      FETCH Cur_check_substitute INTO l_start_date;
      CLOSE Cur_check_substitute;

      UPDATE fm_matl_dtl
      SET    ingredient_end_date = l_start_date
      WHERE  formula_id = l_rec.formula_id
      AND    line_type = -1
      AND    inventory_item_id = l_rec.original_inventory_item_id;
--      AND    organization_id   = l_rec.owner_organization_id

    END IF;
  END LOOP;
END update_end_date;

  /*+========================================================================+
  ** Name    : get_message()
  ** Notes   : This function return the top most message on the stack
  **
  ** HISTORY
  **   30-Aug-2005 shyam  Created.
  **+========================================================================+*/
  FUNCTION get_message RETURN Varchar2 IS
    l_msg_txt Varchar2(2000) := '';
    l_msg_index Number;
  Begin
    l_msg_txt := fnd_message.get;

    IF (l_msg_txt IS NULL) THEN
      FND_MSG_PUB.Get(
        p_msg_index => 1,
        p_data => l_msg_txt,
        p_encoded => FND_API.G_FALSE,
        p_msg_index_out => l_msg_index);
    END IF;

    Return l_msg_txt;
  End get_message;

/*+========================================================================+
** Name    : get_recipe_type
** Notes   : This procedure retrieves the recipe type for an organization.
**
** HISTORY
**   11-Nov-2005 B4479101 TDaniel  Created.
**+========================================================================+*/

FUNCTION get_recipe_type (p_organization_id IN NUMBER) RETURN NUMBER IS
  l_recipe_type PLS_INTEGER;
  l_return_status VARCHAR2(1);
  l_exists PLS_INTEGER;

  CURSOR Cur_get_master_org IS
    SELECT 1
    FROM   sys.dual
    WHERE  EXISTS (SELECT 1
                   FROM   mtl_parameters
                   WHERE  master_organization_id = p_organization_id);
BEGIN
  /* First lets check if there is a value setup at org parameters level */
  GMD_API_GRP.fetch_parm_values(p_orgn_id => p_organization_id
                               ,p_parm_name => 'GMD_RECIPE_TYPE'
                               ,p_parm_value => l_recipe_type
                               ,x_return_status => l_return_status);
  IF l_recipe_type IS NOT NULL THEN
    RETURN l_recipe_type;
  END IF;

  /* Lets check if the organization passed is a master organization */
  OPEN Cur_get_master_org;
  FETCH Cur_get_master_org INTO l_exists;
  IF Cur_get_master_org%FOUND THEN
    -- Sriram. Bug 4672941
    -- If orgn is a Master orgn, return 'General' as recipe type
    l_recipe_type := 0;
  ELSE
    l_recipe_type := 1;
  END IF;
  CLOSE Cur_get_master_org;
  RETURN l_recipe_type;
END get_recipe_type;

/*======================================================================
   --  Function :
   --   get_def_status_code
   --    KSHUKLA bug 5199586
   --  DESCRIPTION:
   --        Used to return the status code for an entity.
   --  REQUIREMENTS
   --
   --  SYNOPSIS:
   --
   --===================================================================== */
   FUNCTION get_def_status_code(p_entity_type varchar2,
                                 p_orgn_id  NUMBER)
                                 RETURN NUMBER is
        l_entity_status   gmd_api_grp.status_rec_type;
   BEGIN
         get_status_details(V_entity_type  => p_entity_type,
                              V_orgn_id  =>p_orgn_id,
                              X_entity_status => l_entity_status);
         return l_entity_status.entity_status;
   END get_def_status_code;


/*+========================================================================+
** Name    : validity_revision_check
** Notes   : This procedure checks if the passed in item has revision
**           associated with it in the given formula. It returns "Y" if
**           the item is defined as a product with revision in the formula.
**           Also, it returns the revision value, if there is a single
**           revision for the item in the formula.
** HISTORY
**   21-Jun-2006 B5309386 TDaniel  Created.
**+========================================================================+*/

PROCEDURE validity_revision_check (p_formula_id IN NUMBER,
                                   p_organization_id IN NUMBER,
                                   p_inventory_item_id IN NUMBER,
                                   x_enable_revision OUT NOCOPY VARCHAR2,
                                   x_revision OUT NOCOPY VARCHAR2) IS
  CURSOR Cur_get_prod_lines IS
    SELECT revision
    FROM   fm_matl_dtl
    WHERE  formula_id = p_formula_id
    AND    inventory_item_id = p_inventory_item_id
    AND    line_type = 1
    ORDER BY revision;

  CURSOR Cur_check_revision (V_revision VARCHAR2) IS
    SELECT 1
    FROM   sys.dual
    WHERE EXISTS (SELECT 1
                  FROM   mtl_item_revisions
                  WHERE  inventory_item_id = p_inventory_item_id
                  AND    organization_id = p_organization_id
                  AND    revision = V_revision);

  l_revision_found PLS_INTEGER := 0;
  l_exists         PLS_INTEGER;
BEGIN
  IF p_organization_id IS NOT NULL THEN
    /* Lets initialize enable revision to N as default */
    x_enable_revision := 'N';

    /* Lets get all the formula product lines for this item */
    FOR l_rec IN Cur_get_prod_lines LOOP
      /* If the line has a revision associated with it */
      IF l_rec.revision IS NOT NULL THEN
        /* Check if this revision has already been validated */
        IF NVL(x_revision, 'ZZZZ') <> l_rec.revision THEN
          /* Lets verify if this revision exists for this item */
          /* under the organization that has been passed in */
          OPEN Cur_check_revision (l_rec.revision);
          FETCH Cur_check_revision INTO l_exists;
          IF Cur_check_revision%FOUND THEN
            /* This revision exists for the organization so */
            /* lets set our variables properly */
            l_revision_found :=  l_revision_found + 1;
            x_revision := l_rec.revision;
          END IF;
          CLOSE Cur_check_revision;
        END IF; /* IF NVL(x_revision, 'ZZZZ') <> l_rec.revision */
      ELSE
        /* We have to increment this variable though the revison */
        /* is NULL to catch the case where the customer could set */
        /* a product with revision and without a revision in the formula */
        /* in this case we should not pass back a default revision */
        l_revision_found := l_revision_found + 1;
      END IF; /* IF l_rec.revision IS NOT NULL */

      /* if we find two records with different revision then we */
      /* need not continue */
      IF l_revision_found > 1 THEN
        /* Since there are multiple revisions for the line */
        /* there will be no default value populated */
        X_revision := NULL;
        x_enable_revision := 'Y'; -- Bug 5309386 rework
        EXIT;
      END IF;
    END LOOP;
  ELSE
    /* If the validity rule is a global one then it does */
    /* does not make sense to provide a revision */
    x_enable_revision := 'N';
  END IF;
END validity_revision_check;

END gmd_api_grp;

/
