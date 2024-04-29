--------------------------------------------------------
--  DDL for Package Body HZ_NAME_ADDRESS_FMT_VALIDATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_NAME_ADDRESS_FMT_VALIDATE" AS
/*$Header: ARH2FMVB.pls 120.8 2006/05/10 08:34:30 ansingha noship $ */

  -----------------------------------------
  -- declaration of private global varibles
  -----------------------------------------

  --g_debug                                 BOOLEAN := FALSE;
  g_debug_count                           NUMBER := 0;


  ------------------------------------
  -- declaration of private procedures
  ------------------------------------

  /*PROCEDURE enable_debug;

  PROCEDURE disable_debug;
  */


  --------------------------------------
  -- private procedures and functions
  --------------------------------------

  /**
   * PRIVATE PROCEDURE enable_debug
   *
   * DESCRIPTION
   *     Turn on debug mode.
   *
   * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
   *     HZ_UTILITY_V2PUB.enable_debug
   *
   * MODIFICATION HISTORY
   *
   *   18-Jul-2001    Kate Shan      o Created.
   *
   */

  /*PROCEDURE enable_debug IS
  BEGIN
    g_debug_count := g_debug_count + 1;

    IF g_debug_count = 1 THEN
      IF fnd_profile.value('HZ_API_FILE_DEBUG_ON') = 'Y' OR
         fnd_profile.value('HZ_API_DBMS_DEBUG_ON') = 'Y'
      THEN
        hz_utility_v2pub.enable_debug;
        g_debug := TRUE;
      END IF;
    END IF;
  END enable_debug;
  */

  /**
   * PRIVATE PROCEDURE disable_debug
   *
   * DESCRIPTION
   *     Turn off debug mode.
   *
   * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
   *     HZ_UTILITY_V2PUB.disable_debug
   *
   * MODIFICATION HISTORY
   *
   *   18-Jul-2001    Kate Shan      o Created.
   *
   */

  /*PROCEDURE disable_debug IS
  BEGIN
    IF g_debug THEN
      g_debug_count := g_debug_count - 1;
      IF g_debug_count = 0 THEN
        hz_utility_v2pub.disable_debug;
        g_debug := FALSE;
      END IF;
    END IF;
  END disable_debug;
  */

PROCEDURE check_greater_than_zero (
    p_column                                IN     VARCHAR2,
    p_column_value                          IN     NUMBER,
    x_return_status                         IN OUT NOCOPY VARCHAR2
) IS

BEGIN
      IF p_column_value <= 0 THEN
        FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_GREATER_THAN_ZERO' );
        FND_MESSAGE.SET_TOKEN( 'COLUMN', p_column );
        FND_MSG_PUB.ADD;
        x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;

END check_greater_than_zero;

PROCEDURE get_updated_record (
    p_style_fmt_locale_id     IN         NUMBER,
    p_update_field_rec        IN         HZ_STYLE_FMT_LOCALE_V2PUB.STYLE_FMT_LOCALE_REC_TYPE,
    x_updated_rec             OUT NOCOPY        HZ_STYLE_FMT_LOCALE_V2PUB.STYLE_FMT_LOCALE_REC_TYPE
) IS
BEGIN
    SELECT
        style_fmt_locale_id,
        style_format_code,
        language_code,
        territory_code,
        DECODE ( p_update_field_rec.start_date_active, null, start_date_active, fnd_api.g_miss_date, null, p_update_field_rec.start_date_active),
        DECODE ( p_update_field_rec.end_date_active, null, end_date_active, fnd_api.g_miss_date, null, p_update_field_rec.end_date_active)
    INTO
        x_updated_rec.style_fmt_locale_id,
        x_updated_rec.style_format_code,
        x_updated_rec.language_code,
        x_updated_rec.territory_code,
        x_updated_rec.start_date_active,
        x_updated_rec.end_date_active
    FROM HZ_STYLE_FMT_LOCALES
    WHERE style_fmt_locale_id = p_style_fmt_locale_id;


END get_updated_record;

PROCEDURE get_updated_record (
    p_style_fmt_layout_id     IN         NUMBER,
    p_update_field_rec        IN         HZ_STYLE_FMT_LAYOUT_V2PUB.STYLE_FMT_LAYOUT_REC_TYPE,
    x_updated_rec             OUT NOCOPY        HZ_STYLE_FMT_LAYOUT_V2PUB.STYLE_FMT_LAYOUT_REC_TYPE
) IS
BEGIN

    SELECT
        b.style_fmt_layout_id,
        b.style_format_code,
        b.variation_number,
        b.attribute_code,
        b.attribute_application_id,
        DECODE ( p_update_field_rec.line_number, null, b.line_number, fnd_api.g_miss_num, null, p_update_field_rec.line_number),
        DECODE ( p_update_field_rec.position, null, b.position, fnd_api.g_miss_num, null, p_update_field_rec.position),
        DECODE ( p_update_field_rec.mandatory_flag, null, b.mandatory_flag, fnd_api.g_miss_char, null, p_update_field_rec.mandatory_flag),
        DECODE ( p_update_field_rec.use_initial_flag, null, b.use_initial_flag, fnd_api.g_miss_char, null, p_update_field_rec.use_initial_flag),
        DECODE ( p_update_field_rec.uppercase_flag, null, b.uppercase_flag, fnd_api.g_miss_char, null, p_update_field_rec.uppercase_flag),
        DECODE ( p_update_field_rec.transform_function, null, b.transform_function, fnd_api.g_miss_char, null, p_update_field_rec.transform_function),
        DECODE ( p_update_field_rec.delimiter_before, null, b.delimiter_before, fnd_api.g_miss_char, null, p_update_field_rec.delimiter_before),
        DECODE ( p_update_field_rec.delimiter_after, null, b.delimiter_after, fnd_api.g_miss_char, null, p_update_field_rec.delimiter_after),
        DECODE ( p_update_field_rec.blank_lines_before, null, b.blank_lines_before, fnd_api.g_miss_num, null, p_update_field_rec.blank_lines_before),
        DECODE ( p_update_field_rec.blank_lines_after, null, b.blank_lines_after, fnd_api.g_miss_num, null, p_update_field_rec.blank_lines_after),
        DECODE ( p_update_field_rec.prompt, null, t.prompt, fnd_api.g_miss_char, null, p_update_field_rec.prompt),
        DECODE ( p_update_field_rec.start_date_active, null, b.start_date_active, fnd_api.g_miss_date, null, p_update_field_rec.start_date_active),
        DECODE ( p_update_field_rec.end_date_active, null, b.end_date_active, fnd_api.g_miss_date, null, p_update_field_rec.end_date_active)
    INTO
        x_updated_rec.style_fmt_layout_id,
        x_updated_rec.style_format_code,
        x_updated_rec.variation_number,
        x_updated_rec.attribute_code,
        x_updated_rec.attribute_application_id,
        x_updated_rec.line_number,
        x_updated_rec.position,
        x_updated_rec.mandatory_flag,
        x_updated_rec.use_initial_flag,
        x_updated_rec.uppercase_flag,
        x_updated_rec.transform_function,
        x_updated_rec.delimiter_before,
        x_updated_rec.delimiter_after,
        x_updated_rec.blank_lines_before,
        x_updated_rec.blank_lines_after,
        x_updated_rec.prompt,
        x_updated_rec.start_date_active,
        x_updated_rec.end_date_active
    FROM HZ_STYLE_FMT_LAYOUTS_B b , HZ_STYLE_FMT_LAYOUTS_TL t
    WHERE b.style_fmt_layout_id =t.style_fmt_layout_id  AND
          t.style_fmt_layout_id = p_style_fmt_layout_id AND
          t.language=userenv('LANG'); ---Bug No. 5178007


END get_updated_record;

  --------------------------------------
  -- declaration of public procedures and functions
  --------------------------------------

  --
  -- PROCEDURE validate_style
  --
  -- DESCRIPTION
  --     Validates style record. Checks for
  --         uniqueness
  --         mandatory columns
  --         non-updateable fields
  --         foreign key validations
  --         other validations
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_create_update_flag     Create update flag. 'C' = create. 'U' = update.
  --     p_style_rec              Style record.
  --     p_rowid                  Rowid of the record (used only in update mode).
  --   IN/OUT:
  --     x_return_status          Return status after the call. The status can
  --                              be FND_API.G_RET_STS_SUCCESS (success),
  --                              FND_API.G_RET_STS_ERROR (error),
  --                              FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   18-JUL-2002    Kate Shan           o Created.
  --
  --

  PROCEDURE validate_style(
      p_create_update_flag             IN     VARCHAR2,
      p_style_rec                      IN     HZ_STYLE_V2PUB.STYLE_REC_TYPE,
      p_rowid                          IN     ROWID,
      x_return_status                  IN OUT NOCOPY VARCHAR2
  ) IS

      l_dummy                                 VARCHAR2(1);
      l_style_code			      HZ_STYLES_B.style_code%TYPE;
      l_style_name                            HZ_STYLES_TL.style_name%TYPE;
      l_database_object_name		      HZ_STYLES_B.database_object_name%TYPE;
      l_debug_prefix                          VARCHAR2(30) := '';

  BEGIN

      --enable_debug;

      -- Debug info.
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'validate_style (+)',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
      END IF;

      -- select columns needed to be checked from table during update

      IF (p_create_update_flag = 'U') THEN
          SELECT b.style_code, t.style_name,
	         b.database_object_name
          INTO   l_style_code,
	         l_style_name,
                 l_database_object_name
          FROM   HZ_STYLES_B b , HZ_STYLES_TL t
          WHERE  b.ROWID = p_rowid
   	  AND t.style_code = b.style_code
	  AND t.language =  userenv('LANG');

      END IF;

      -----------------------------
      -- validate style_code
      -----------------------------

      -- style_code is mandatory
      IF (p_create_update_flag = 'C') THEN
        HZ_UTILITY_V2PUB.validate_mandatory (
            p_create_update_flag                    => p_create_update_flag,
            p_column                                => 'style_code',
            p_column_value                          => p_style_rec.style_code,
            x_return_status                         => x_return_status);

	IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	   hz_utility_v2pub.debug(p_message=>'style_code is mandatory. ' ||
                                 'x_return_status = ' || x_return_status,
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
	END IF;
      END IF;

      -- style_code is non-updateable field
      IF p_create_update_flag = 'U' AND
         p_style_rec.style_code IS NOT NULL
      THEN
        HZ_UTILITY_V2PUB.validate_nonupdateable (
          p_column                 => 'style_code',
          p_column_value           => p_style_rec.style_code,
          p_old_column_value       => l_style_code,
          x_return_status          => x_return_status);

	IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	   hz_utility_v2pub.debug(p_message=>'style_code is non-updateable. ' ||
					     'x_return_status = ' || x_return_status,
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
        END IF;
      END IF;

      -- style_code is unique
      IF p_create_update_flag = 'C' AND
         p_style_rec.style_code IS NOT NULL
      THEN
        BEGIN
          select 'Y' into l_dummy
          from HZ_STYLES_B
          where style_code = p_style_rec.style_code;

          FND_MESSAGE.SET_NAME('AR', 'HZ_API_DUPLICATE_COLUMN');
          FND_MESSAGE.SET_TOKEN('COLUMN', 'style_code');
          FND_MSG_PUB.ADD;
          x_return_status := FND_API.G_RET_STS_ERROR;

        EXCEPTION
            WHEN NO_DATA_FOUND THEN
              NULL;
        END;

	IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	   hz_utility_v2pub.debug(p_message=>'style_code is unique during creation. ' ||
                'x_return_status = ' || x_return_status,
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
        END IF;
      END IF;

      --------------------------------------
      -- validate database_object_name
      --------------------------------------

      -- database_object_name is mandatory
      IF (p_create_update_flag = 'C') THEN
        HZ_UTILITY_V2PUB.validate_mandatory (
            p_create_update_flag                    => p_create_update_flag,
            p_column                                => 'database_object_name',
            p_column_value                          => p_style_rec.database_object_name,
            x_return_status                         => x_return_status);

	IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	   hz_utility_v2pub.debug(p_message=>'database_object_name is mandatory. ' ||
                                 'x_return_status = ' || x_return_status,
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
	END IF;
      END IF;

      -- database_object_name is non-updateable field
      IF p_create_update_flag = 'U' AND
         p_style_rec.database_object_name IS NOT NULL
      THEN
        HZ_UTILITY_V2PUB.validate_nonupdateable (
          p_column                 => 'database_object_name',
          p_column_value           => p_style_rec.database_object_name,
          p_old_column_value       => l_database_object_name,
          x_return_status          => x_return_status);

	IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	   hz_utility_v2pub.debug(p_message=>'database_object_name is non-updateable. ' ||
            'x_return_status = ' || x_return_status,
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
	END IF;
      END IF;

      -- database_object_name has foreign key fnd_tables.table_name
      IF p_style_rec.database_object_name IS NOT NULL
         AND
         p_style_rec.database_object_name <> fnd_api.g_miss_char
      THEN
          BEGIN

              SELECT 'Y'
              into   l_dummy
	      FROM   fnd_tables t
	      where  t.table_name = p_style_rec.database_object_name ;

          EXCEPTION
              WHEN NO_DATA_FOUND THEN
                  fnd_message.set_name('AR', 'HZ_API_INVALID_FK');
                  fnd_message.set_token('FK', 'database_object_name');
                  fnd_message.set_token('COLUMN', 'table_name');
                  fnd_message.set_token('TABLE', 'fnd_tables');
                  fnd_msg_pub.add;
                  x_return_status := fnd_api.g_ret_sts_error;
          END;

	  IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	     hz_utility_v2pub.debug(p_message=>'database_object_name has foreign key fnd_tables.table_name. ' ||
                  'x_return_status = ' || x_return_status,
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
	  END IF;
      END IF;

      -----------------------------
      -- validate style_name
      -----------------------------

      -- style_name is mandatory
      IF (p_create_update_flag = 'C') THEN
        HZ_UTILITY_V2PUB.validate_mandatory (
            p_create_update_flag                    => p_create_update_flag,
            p_column                                => 'style_name',
            p_column_value                          => p_style_rec.style_name,
            x_return_status                         => x_return_status);

	IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	    hz_utility_v2pub.debug(p_message=>'style_name is mandatory. ' ||
                                 'x_return_status = ' || x_return_status,
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
        END IF;
      END IF;

      -- style_name cannot be set to null during update
      IF p_create_update_flag = 'U' THEN
          HZ_UTILITY_V2PUB.validate_cannot_update_to_null (
              p_column                                => 'style_name',
              p_column_value                          => p_style_rec.style_name,
              x_return_status                         => x_return_status);

	  IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	     hz_utility_v2pub.debug(p_message=>'style_name cannot be set to null during update. ' ||
                  'x_return_status = ' || x_return_status,
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
	  END IF;

      END IF;

      -- style_name is unique within language
      IF p_create_update_flag = 'C' OR
         (p_create_update_flag = 'U' AND
	  p_style_rec.style_name is not null AND
	  p_style_rec.style_name <> l_style_name)
      THEN
        BEGIN
          select 'Y' into l_dummy
          from HZ_STYLES_TL
          where style_name = p_style_rec.style_name
	    and language = userenv('LANG');

          FND_MESSAGE.SET_NAME('AR', 'HZ_STYLE_NAME_DUP');
          FND_MSG_PUB.ADD;
          x_return_status := FND_API.G_RET_STS_ERROR;

        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                NULL;
        END;
	IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	   hz_utility_v2pub.debug(p_message=>'style_name is unique within language. ' ||
                'x_return_status = ' || x_return_status,
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
        END IF;
      END IF;
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'validate_style (-)',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
      END IF;

      --disable_debug;

END validate_style;


  --
  -- PROCEDURE validate_style_format
  --
  -- DESCRIPTION
  --     Validates style record. Checks for
  --         uniqueness
  --         mandatory columns
  --         non-updateable fields
  --         foreign key validations
  --         other validations
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_create_update_flag     Create update flag. 'C' = create. 'U' = update.
  --     p_style_format_rec       Style Format record.
  --     p_rowid                  Rowid of the record (used only in update mode).
  --   IN/OUT:
  --     x_return_status          Return status after the call. The status can
  --                              be FND_API.G_RET_STS_SUCCESS (success),
  --                              FND_API.G_RET_STS_ERROR (error),
  --                              FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   18-JUL-2002    Kate Shan           o Created.
  --
  --

  PROCEDURE validate_style_format(
      p_create_update_flag             IN     VARCHAR2,
      p_style_format_rec               IN     HZ_STYLE_FORMAT_V2PUB.STYLE_FORMAT_REC_TYPE,
      p_rowid                          IN     ROWID,
      x_return_status                  IN OUT NOCOPY VARCHAR2
  )IS
      l_dummy                                 VARCHAR2(1);
      l_style_format_code   	              HZ_STYLE_FORMATS_B.style_format_code%TYPE;
      l_style_code			      HZ_STYLE_FORMATS_B.style_code%TYPE;
      l_default_flag     		      HZ_STYLE_FORMATS_B.default_flag%TYPE;
      l_style_format_name                     HZ_STYLE_FORMATS_TL.style_format_name%TYPE;
      l_debug_prefix                          VARCHAR2(30) := '';

  BEGIN

       --enable_debug;

      -- Debug info.
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'validate_style_format (+)',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
      END IF;

      -- select columns needed to be checked from table during update

      IF (p_create_update_flag = 'U') THEN
          SELECT b.style_format_code,
	         b.style_code,
		 b.default_flag,
		 t.style_format_name
          INTO   l_style_format_code,
	         l_style_code,
                 l_default_flag,
                 l_style_format_name
          FROM   HZ_STYLE_FORMATS_B b , HZ_STYLE_FORMATS_TL t
          WHERE  b.ROWID = p_rowid
   	  AND t.style_format_code = b.style_format_code
	  AND t.language =  userenv('LANG');

      END IF;

      -----------------------------
      -- validate style_format_code
      -----------------------------

      -- style_format_code is mandatory
      IF (p_create_update_flag = 'C') THEN
        HZ_UTILITY_V2PUB.validate_mandatory (
            p_create_update_flag                    => p_create_update_flag,
            p_column                                => 'style_format_code',
            p_column_value                          => p_style_format_rec.style_format_code,
            x_return_status                         => x_return_status);

	IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	   hz_utility_v2pub.debug(p_message=>'style_format_code is mandatory. ' ||
                                 'x_return_status = ' || x_return_status,
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
        END IF;
      END IF;

      -- style_format_code is non-updateable field

      IF p_create_update_flag = 'U' AND
         p_style_format_rec.style_format_code IS NOT NULL
      THEN
        HZ_UTILITY_V2PUB.validate_nonupdateable (
          p_column                 => 'style_format_code',
          p_column_value           => p_style_format_rec.style_format_code,
          p_old_column_value       => l_style_format_code,
          x_return_status          => x_return_status);

	IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	   hz_utility_v2pub.debug(p_message=>'l_style_format_code is non-updateable. ' ||
					     'x_return_status = ' || x_return_status,
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
        END IF;
      END IF;

      -- l_style_format_code is unique
      IF p_create_update_flag = 'C' AND
         p_style_format_rec.style_format_code IS NOT NULL
      THEN
        BEGIN
          select 'Y' into l_dummy
          from HZ_STYLE_FORMATS_B
          where style_format_code = p_style_format_rec.style_format_code;

          FND_MESSAGE.SET_NAME('AR', 'HZ_API_DUPLICATE_COLUMN');
          FND_MESSAGE.SET_TOKEN('COLUMN', 'style_format_code');
          FND_MSG_PUB.ADD;
          x_return_status := FND_API.G_RET_STS_ERROR;

        EXCEPTION
            WHEN NO_DATA_FOUND THEN
              NULL;
        END;

	IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	   hz_utility_v2pub.debug(p_message=>'style_format_code is unique during creation. ' ||
                'x_return_status = ' || x_return_status,
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
        END IF;
      END IF;

      -----------------------------
      -- validate style_code
      -----------------------------

      -- style_code is mandatory
      IF (p_create_update_flag = 'C') THEN
        HZ_UTILITY_V2PUB.validate_mandatory (
            p_create_update_flag                    => p_create_update_flag,
            p_column                                => 'style_code',
            p_column_value                          => p_style_format_rec.style_code,
            x_return_status                         => x_return_status);

	IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	   hz_utility_v2pub.debug(p_message=>'style_code is mandatory. ' ||
                                 'x_return_status = ' || x_return_status,
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
        END IF;
      END IF;

      -- style_code is non-updateable field
      IF p_create_update_flag = 'U' AND
         p_style_format_rec.style_code IS NOT NULL
      THEN
        HZ_UTILITY_V2PUB.validate_nonupdateable (
          p_column                 => 'style_code',
          p_column_value           => p_style_format_rec.style_code,
          p_old_column_value       => l_style_code,
          x_return_status          => x_return_status);

	IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	   hz_utility_v2pub.debug(p_message=>'style_code is non-updateable. ' ||
					     'x_return_status = ' || x_return_status,
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
        END IF;
      END IF;

      -- style_code is foreign key of hz_styles_b
      -- Do not need to check during update because style_code is
      -- non-updateable.
      IF p_create_update_flag = 'C'
         AND
         p_style_format_rec.style_code IS NOT NULL
         AND
         p_style_format_rec.style_code <> fnd_api.g_miss_CHAR
      THEN
          BEGIN
              SELECT 'Y'
              INTO   l_dummy
              FROM   HZ_STYLES_B
              WHERE  style_code = p_style_format_rec.style_code;
          EXCEPTION
              WHEN NO_DATA_FOUND THEN
                  fnd_message.set_name('AR', 'HZ_API_INVALID_FK');
                  fnd_message.set_token('FK', 'style_code');
                  fnd_message.set_token('COLUMN', 'style_code');
                  fnd_message.set_token('TABLE', 'hz_styles_b');
                  fnd_msg_pub.add;
                  x_return_status := fnd_api.g_ret_sts_error;
          END;

	  IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	     hz_utility_v2pub.debug(p_message=>'style_code is foreign key of hz_styles_b. ' ||
                  'x_return_status = ' || x_return_status,
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
	  END IF;
      END IF;

      -----------------------------
      -- validate default_flag
      -----------------------------

      -- default_flag is mandatory
      IF (p_create_update_flag = 'C') THEN
        HZ_UTILITY_V2PUB.validate_mandatory (
            p_create_update_flag                    => p_create_update_flag,
            p_column                                => 'default_flag',
            p_column_value                          => p_style_format_rec.default_flag,
            x_return_status                         => x_return_status);


	IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	    hz_utility_v2pub.debug(p_message=>'default_flag is mandatory. ' ||
                                 'x_return_status = ' || x_return_status,
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
        END IF;
      END IF;

      -- default_flag is lookup code in lookup type YES/NO
      hz_utility_v2pub.validate_lookup (
          p_column                                => 'default_flag',
          p_lookup_type                           => 'YES/NO',
          p_column_value                          => p_style_format_rec.default_flag,
          x_return_status                         => x_return_status);

      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	   hz_utility_v2pub.debug(p_message=>'default_flag is lookup code in lookup type YES/NO. ' ||
              'x_return_status = ' || x_return_status,
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
      END IF;

      -- default_flag cannot be set to null during update
      IF p_create_update_flag = 'U' THEN
          HZ_UTILITY_V2PUB.validate_cannot_update_to_null (
              p_column                                => 'default_flag',
              p_column_value                          => p_style_format_rec.default_flag,
              x_return_status                         => x_return_status);

	  IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	     hz_utility_v2pub.debug(p_message=>'default_flag cannot be set to null during update. ' ||
                  'x_return_status = ' || x_return_status,
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
	  END IF;

      END IF;

      -- default_flag cannot be set from Yes to No
      IF p_create_update_flag = 'U' AND
         p_style_format_rec.default_flag = 'N' AND
         l_default_flag = 'Y'
      THEN
         fnd_message.set_name('AR', 'HZ_STL_FMT_FLAG_NOT_Y_TO_N');
         fnd_msg_pub.add;
         x_return_status := fnd_api.g_ret_sts_error;

	  IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	      hz_utility_v2pub.debug(p_message=>'default_flag cannot be set from Yes to No. ' ||
                  'x_return_status = ' || x_return_status,
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
	  END IF;

      END IF;
      -----------------------------
      -- validate style_format_name
      -----------------------------

      -- style_format_name is mandatory
      IF (p_create_update_flag = 'C') THEN
        HZ_UTILITY_V2PUB.validate_mandatory (
            p_create_update_flag                    => p_create_update_flag,
            p_column                                => 'style_format_name',
            p_column_value                          => p_style_format_rec.style_format_name,
            x_return_status                         => x_return_status);

	IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	    hz_utility_v2pub.debug(p_message=>'style_format_name is mandatory. ' ||
                                 'x_return_status = ' || x_return_status,
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
        END IF;
      END IF;

      -- style_format_name cannot be set to null during update
      IF p_create_update_flag = 'U' THEN
          HZ_UTILITY_V2PUB.validate_cannot_update_to_null (
              p_column                                => 'style_format_name',
              p_column_value                          => p_style_format_rec.style_format_name,
              x_return_status                         => x_return_status);

	  IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	     hz_utility_v2pub.debug(p_message=>'style_format_name cannot be set to null during update. ' ||
                  'x_return_status = ' || x_return_status,
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
          END IF;

      END IF;

      -- style_format_name is unique within language
      IF p_create_update_flag = 'C' OR
         (p_create_update_flag = 'U' AND
	  p_style_format_rec.style_format_name is not null AND
	  p_style_format_rec.style_format_name <> l_style_format_name)
      THEN
        BEGIN
          select 'Y' into l_dummy
          from HZ_STYLE_FORMATS_TL
          where style_format_name = p_style_format_rec.style_format_name
	    and language = userenv('LANG');

          FND_MESSAGE.SET_NAME('AR', 'HZ_STYLE_FMT_NAME_DUP');
	  FND_MSG_PUB.ADD;
          x_return_status := FND_API.G_RET_STS_ERROR;

        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                NULL;
        END;

	IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	   hz_utility_v2pub.debug(p_message=>'style_format_name is unique within language. ' ||
                'x_return_status = ' || x_return_status,
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
        END IF;
      END IF;

      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	 hz_utility_v2pub.debug(p_message=>'validate_style_format (-)',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
      END IF;

    --disable_debug;
  END validate_style_format;


  --
  -- PROCEDURE validate_style_fmt_locale
  --
  -- DESCRIPTION
  --     Validates style record. Checks for
  --         uniqueness
  --         mandatory columns
  --         non-updateable fields
  --         foreign key validations
  --         other validations
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_create_update_flag     Create update flag. 'C' = create. 'U' = update.
  --     p_style_fmt_locale_rec   Style Locale record.
  --     p_rowid                  Rowid of the record (used only in update mode).
  --   IN/OUT:
  --     x_return_status          Return status after the call. The status can
  --                              be FND_API.G_RET_STS_SUCCESS (success),
  --                              FND_API.G_RET_STS_ERROR (error),
  --                              FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   18-JUL-2002    Kate Shan           o Created.
  --
  --

  PROCEDURE validate_style_fmt_locale(
      p_create_update_flag             IN     VARCHAR2,
      p_style_fmt_locale_rec           IN     HZ_STYLE_FMT_LOCALE_V2PUB.STYLE_FMT_LOCALE_REC_TYPE,
      p_rowid                          IN     ROWID,
      x_return_status                  IN OUT NOCOPY VARCHAR2
  ) IS

      l_dummy                  VARCHAR2(1);
      l_style_fmt_locale_id    HZ_STYLE_FMT_LOCALES.style_fmt_locale_id%TYPE;
      l_style_format_code      HZ_STYLE_FMT_LOCALES.style_format_code%TYPE;
      l_language_code          HZ_STYLE_FMT_LOCALES.language_code%TYPE;
      l_territory_code         HZ_STYLE_FMT_LOCALES.territory_code%TYPE;
      l_start_date_active      date;
      l_end_date_active        date;
      l_debug_prefix           VARCHAR2(30) := '';
      l_dup_style_fmt_locale_id HZ_STYLE_FMT_LOCALES.style_fmt_locale_id%TYPE;
      l_updated_stl_fmt_rec    HZ_STYLE_FMT_LOCALE_V2PUB.STYLE_FMT_LOCALE_REC_TYPE;

      CURSOR c_dup (p_style_fmt_locale_id IN NUMBER) IS
        SELECT 'Y'
        FROM   hz_style_fmt_locales hsfl
        WHERE  hsfl.style_fmt_locale_id = p_style_fmt_locale_id;


  BEGIN
    --enable_debug;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'validate_style_fmt_locale (+)',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- select columns needed to be checked from table during update

    IF (p_create_update_flag = 'U') THEN
        SELECT style_fmt_locale_id,
          style_format_code,
          language_code,
          territory_code,
          start_date_active,
          end_date_active
        INTO
          l_style_fmt_locale_id,
          l_style_format_code,
          l_language_code,
          l_territory_code,
          l_start_date_active,
          l_end_date_active
        FROM   HZ_STYLE_FMT_LOCALES
        WHERE  ROWID = p_rowid;
     END IF;

    -------------------------------
    -- validate style_fmt_locale_id
    -------------------------------

    -- If primary key value is passed, check for uniqueness.
    -- If primary key value is not passed, it will be generated
    -- from sequence by table handler.

     IF p_create_update_flag = 'C' THEN
      IF p_style_fmt_locale_rec.style_fmt_locale_id IS NOT NULL AND
         p_style_fmt_locale_rec.style_fmt_locale_id <> fnd_api.g_miss_num
      THEN
        OPEN c_dup (p_style_fmt_locale_rec.style_fmt_locale_id);
        FETCH c_dup INTO l_dummy;
         -- key is not unique, push an error onto the stack.
        IF NVL(c_dup%FOUND, FALSE) THEN
          fnd_message.set_name('AR', 'HZ_API_DUPLICATE_COLUMN');
          fnd_message.set_token('COLUMN', 'style_fmt_locale_id');
          fnd_msg_pub.add;
          x_return_status := fnd_api.g_ret_sts_error;
        END IF;
        CLOSE c_dup;
	IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	   hz_utility_v2pub.debug(p_message=>'check that style_fmt_locale_id is unique during creation. ' ||
            ' x_return_status = ' || x_return_status,
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
        END IF;
      END IF;
    END IF;

    IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	   hz_utility_v2pub.debug(p_message=>'(+) after validate style_fmt_locale_id ... ' ||
						'x_return_status = ' || x_return_status,
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
    END IF;

    -----------------------------
    -- validate style_format_code
    -----------------------------

    -- style_format_code is mandatory

    IF (p_create_update_flag = 'C') THEN
      HZ_UTILITY_V2PUB.validate_mandatory (
          p_create_update_flag                    => p_create_update_flag,
          p_column                                => 'style_format_code',
          p_column_value                          => p_style_fmt_locale_rec.style_format_code,
          x_return_status                         => x_return_status);

      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	   hz_utility_v2pub.debug(p_message=>'style_format_code is mandatory. ' ||
                               'x_return_status = ' || x_return_status,
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
      END IF;
    END IF;

    -- style_format_code is non-updateable field
    IF p_create_update_flag = 'U' AND
       p_style_fmt_locale_rec.style_format_code IS NOT NULL
    THEN
      HZ_UTILITY_V2PUB.validate_nonupdateable (
        p_column                 => 'style_format_code',
        p_column_value           => p_style_fmt_locale_rec.style_format_code,
        p_old_column_value       => l_style_format_code,
        x_return_status          => x_return_status);

      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	   hz_utility_v2pub.debug(p_message=>'style_format_code is non-updateable. ' ||
						'x_return_status = ' || x_return_status,
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
      END IF;
    END IF;

    -- style_format_code is foreign key of hz_style_formats_b
    -- Do not need to check during update because style_format_code is
    -- non-updateable.

    IF p_create_update_flag = 'C'
       AND
       p_style_fmt_locale_rec.style_format_code IS NOT NULL
       AND
       p_style_fmt_locale_rec.style_format_code <> fnd_api.g_miss_CHAR
    THEN
        BEGIN
            SELECT 'Y'
            INTO   l_dummy
            FROM   HZ_STYLE_FORMATS_B
            WHERE  style_format_code = p_style_fmt_locale_rec.style_format_code;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                fnd_message.set_name('AR', 'HZ_API_INVALID_FK');
                fnd_message.set_token('FK', 'style_format_code');
                fnd_message.set_token('COLUMN', 'style_format_code');
                fnd_message.set_token('TABLE', 'hz_style_formats_b');
                fnd_msg_pub.add;
                x_return_status := fnd_api.g_ret_sts_error;
        END;
	IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	     hz_utility_v2pub.debug(p_message=>'style_format_code is foreign key of hz_style_formats_b. ' ||
				  'x_return_status = ' || x_return_status,
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
        END IF;
    END IF;

    -----------------------------
    -- validate language_code
    -----------------------------

      -- language_code is non-updateable field

      IF p_create_update_flag = 'U' AND
         p_style_fmt_locale_rec.language_code IS NOT NULL
      THEN
        HZ_UTILITY_V2PUB.validate_nonupdateable (
          p_column                 => 'language_code',
          p_column_value           => p_style_fmt_locale_rec.language_code,
          p_old_column_value       => l_language_code,
          x_return_status          => x_return_status);

	IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	   hz_utility_v2pub.debug(p_message=>'language_code is non-updateable. ' ||
				 'x_return_status = ' || x_return_status,
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
       END IF;
      END IF;

      -- language_code is foreign key of fnd_languages
      -- Do not need to check during update because fnd_languages is
      -- non-updateable.
      IF p_create_update_flag = 'C'
         AND
         p_style_fmt_locale_rec.language_code IS NOT NULL
         AND
         p_style_fmt_locale_rec.language_code <> fnd_api.g_miss_CHAR
      THEN
          BEGIN
              SELECT 'Y'
              INTO   l_dummy
              FROM   FND_LANGUAGES
              WHERE  language_code = p_style_fmt_locale_rec.language_code;
          EXCEPTION
              WHEN NO_DATA_FOUND THEN
                  fnd_message.set_name('AR', 'HZ_API_INVALID_FK');
                  fnd_message.set_token('FK', 'language_code');
                  fnd_message.set_token('COLUMN', 'language_code');
                  fnd_message.set_token('TABLE', 'fnd_languages');
                  fnd_msg_pub.add;
                  x_return_status := fnd_api.g_ret_sts_error;
          END;
	  IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	     hz_utility_v2pub.debug(p_message=>'language_code is foreign key of fnd_languages. ' ||
                  'x_return_status = ' || x_return_status,
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
          END IF;
      END IF;

    -----------------------------
    -- validate territory_code
    -----------------------------

      -- territory_code is non-updateable field

      IF p_create_update_flag = 'U' AND
         p_style_fmt_locale_rec.territory_code IS NOT NULL
      THEN
        HZ_UTILITY_V2PUB.validate_nonupdateable (
          p_column                 => 'territory_code',
          p_column_value           => p_style_fmt_locale_rec.territory_code,
          p_old_column_value       => l_territory_code,
          x_return_status          => x_return_status);

	IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	   hz_utility_v2pub.debug(p_message=>'territory_code is non-updateable. ' ||
            'x_return_status = ' || x_return_status,
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
	END IF;
      END IF;

      -- territory_code is foreign key of fnd_territories
      -- Do not need to check during update because fnd_territories is
      -- non-updateable.
      IF p_create_update_flag = 'C'
         AND
         p_style_fmt_locale_rec.territory_code IS NOT NULL
         AND
         p_style_fmt_locale_rec.territory_code <> fnd_api.g_miss_CHAR
      THEN
          BEGIN
              SELECT 'Y'
              INTO   l_dummy
              FROM   FND_TERRITORIES
              WHERE  territory_code = p_style_fmt_locale_rec.territory_code;
          EXCEPTION
              WHEN NO_DATA_FOUND THEN
                  fnd_message.set_name('AR', 'HZ_API_INVALID_FK');
                  fnd_message.set_token('FK', 'territory_code');
                  fnd_message.set_token('COLUMN', 'territory_code');
                  fnd_message.set_token('TABLE', 'fnd_territories');
                  fnd_msg_pub.add;
                  x_return_status := fnd_api.g_ret_sts_error;
          END;
	  IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	     hz_utility_v2pub.debug(p_message=>'territory_code is foreign key of fnd_territories. ' ||
                  'x_return_status = ' || x_return_status,
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
          END IF;
      END IF;

    -------------------------------------------------------------
    -- language_code, territory_code validation
    -------------------------------------------------------------

      -- Either language_code or territory_code must have a value
      IF p_create_update_flag = 'C' AND
	 not ((p_style_fmt_locale_rec.language_code IS NOT NULL AND
              (p_style_fmt_locale_rec.language_code <> fnd_api.g_miss_char) OR
	      (p_style_fmt_locale_rec.territory_code IS NOT NULL ) AND
  	       p_style_fmt_locale_rec.territory_code <> fnd_api.g_miss_char ) )
      THEN
          FND_MESSAGE.SET_NAME('AR', 'HZ_STL_FMT_LOC_MISSING_COLUMN');
          FND_MSG_PUB.ADD;
          x_return_status := FND_API.G_RET_STS_ERROR;

	IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	   hz_utility_v2pub.debug(p_message=>'Either language_code or territory_code must have a value. ' ||
                'x_return_status = ' || x_return_status,
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
        END IF;

      END IF;


    -----------------------------
    -- validate start_date_active
    -----------------------------

      -- start_date_active is mandatory
      IF (p_create_update_flag = 'C') THEN
        HZ_UTILITY_V2PUB.validate_mandatory (
            p_create_update_flag                    => p_create_update_flag,
            p_column                                => 'start_date_active',
            p_column_value                          => p_style_fmt_locale_rec.start_date_active,
            x_return_status                         => x_return_status);

	IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	   hz_utility_v2pub.debug(p_message=>'start_date_active is mandatory. ' ||
                                 'x_return_status = ' || x_return_status,
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
        END IF;
      END IF;

      -- start_date_active cannot be set to null during update
      IF p_create_update_flag = 'U' THEN
          HZ_UTILITY_V2PUB.validate_cannot_update_to_null (
              p_column                                => 'start_date_active',
              p_column_value                          => p_style_fmt_locale_rec.start_date_active,
              x_return_status                         => x_return_status);

	  IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	      hz_utility_v2pub.debug(p_message=>'start_date_active cannot be set to null during update. ' ||
						'x_return_status = ' || x_return_status,
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
          END IF;

      END IF;

    ----------------------------------
    -- start_date_active, end_date_active validation
    ----------------------------------

    -- end_date_active must be null or greater than start date
    IF (p_create_update_flag = 'C') THEN
      IF p_style_fmt_locale_rec.end_date_active IS NOT NULL AND
         p_style_fmt_locale_rec.end_date_active <> fnd_api.g_miss_date AND
         p_style_fmt_locale_rec.end_date_active < p_style_fmt_locale_rec.start_date_active
      THEN
        fnd_message.set_name('AR', 'HZ_API_START_DATE_GREATER');
        fnd_msg_pub.add;
        x_return_status := fnd_api.g_ret_sts_error;
      END IF;
    ELSIF (p_create_update_flag = 'U') THEN
      -- old start_date_active, end_date_active has been selected from table
      -- and put into l_start_date_active, l_end_date_active

      IF p_style_fmt_locale_rec.start_date_active <> fnd_api.g_miss_date
         AND p_style_fmt_locale_rec.start_date_active is not null
      THEN
        l_start_date_active := p_style_fmt_locale_rec.start_date_active;
      END IF;

      IF p_style_fmt_locale_rec.end_date_active = fnd_api.g_miss_date
      THEN
        l_end_date_active := null;
      ELSIF p_style_fmt_locale_rec.end_date_active IS NOT NULL THEN
        l_end_date_active := p_style_fmt_locale_rec.end_date_active;
      END IF;

      IF l_end_date_active IS NOT NULL
         AND l_end_date_active < l_start_date_active
      THEN
        fnd_message.set_name('AR', 'HZ_API_START_DATE_GREATER');
        fnd_msg_pub.add;
        x_return_status := fnd_api.g_ret_sts_error;
      END IF;
    END IF;
    IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	   hz_utility_v2pub.debug(p_message=>'end_date_active must be null or greater than start date. ' ||
					'x_return_status = ' || x_return_status,
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
    END IF;

    --------------------------------------------------------------------------------------------------
    -- style_format_code, language_code, territory_code validation, start_date_active, end_date_active
    --------------------------------------------------------------------------------------------------

      -- combination of style_format_code, language_code, territory_code is unique in time range of
      -- start_date_active, end_date_active

      IF p_create_update_flag = 'C' AND
         p_style_fmt_locale_rec.style_format_code IS NOT NULL AND
	 ( p_style_fmt_locale_rec.language_code IS NOT NULL OR
	   p_style_fmt_locale_rec.territory_code IS NOT NULL )
      THEN
        BEGIN
          select style_fmt_locale_id into l_dup_style_fmt_locale_id
          from HZ_STYLE_FMT_LOCALES
          where style_format_code = p_style_fmt_locale_rec.style_format_code AND
	        decode(language_code, null, fnd_api.g_miss_char, language_code) = NVL( p_style_fmt_locale_rec.language_code, fnd_api.g_miss_char) AND
	        decode(territory_code, null, fnd_api.g_miss_char, territory_code) = NVL(p_style_fmt_locale_rec.territory_code, fnd_api.g_miss_char) AND
		NOT ( ( p_style_fmt_locale_rec.end_date_active is not null and
		        p_style_fmt_locale_rec.end_date_active <> fnd_api.g_miss_date and
                        p_style_fmt_locale_rec.end_date_active < start_date_active ) OR
                      ( end_date_active is not null and
                        p_style_fmt_locale_rec.start_date_active > end_date_active )) AND
		rownum =1;

          FND_MESSAGE.SET_NAME('AR', 'HZ_STYLE_LOC_DUPLICATE_RECORD');
          FND_MSG_PUB.ADD;
          x_return_status := FND_API.G_RET_STS_ERROR;

        EXCEPTION
            WHEN NO_DATA_FOUND THEN
              NULL;
        END;

	IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	    hz_utility_v2pub.debug(p_message=>'Another record exist for this style format layout with an overlapping date ranger. Please input a unique combination of style_format_code, language_code, territory_code validation' ||
				'x_return_status = ' || x_return_status,
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
        END IF;

     ELSIF p_create_update_flag = 'U' AND
          (p_style_fmt_locale_rec.start_date_active is not null OR
	    p_style_fmt_locale_rec.end_date_active is not null )
     THEN
        get_updated_record (
            p_style_fmt_locale_id  => p_style_fmt_locale_rec.style_fmt_locale_id,
            p_update_field_rec     => p_style_fmt_locale_rec,
            x_updated_rec          => l_updated_stl_fmt_rec );

        BEGIN
          select style_fmt_locale_id into l_dup_style_fmt_locale_id
          from HZ_STYLE_FMT_LOCALES
          where style_fmt_locale_id <> l_updated_stl_fmt_rec.style_fmt_locale_id AND
	        style_format_code = l_updated_stl_fmt_rec.style_format_code AND
	        decode(language_code, null, fnd_api.g_miss_char, language_code) = NVL( l_updated_stl_fmt_rec.language_code, fnd_api.g_miss_char) AND
	        decode(territory_code, null, fnd_api.g_miss_char, territory_code) = NVL(l_updated_stl_fmt_rec.territory_code, fnd_api.g_miss_char) AND
		NOT ( ( l_updated_stl_fmt_rec.end_date_active is not null and
                        l_updated_stl_fmt_rec.end_date_active < start_date_active ) OR
                      ( end_date_active is not null and
                        l_updated_stl_fmt_rec.start_date_active > end_date_active )) AND
		rownum =1;

          FND_MESSAGE.SET_NAME('AR', 'HZ_STYLE_DUPLICATE_RECORD');
          FND_MESSAGE.SET_TOKEN( 'TYPE', 'style format locale' );
          FND_MESSAGE.SET_TOKEN( 'COLUMN', 'style_fmt_locale_id' );
          FND_MESSAGE.SET_TOKEN( 'ID', to_char(l_dup_style_fmt_locale_id) );
          FND_MESSAGE.SET_TOKEN( 'ALLCOLUMNS', 'style_format_code, language_code, territory_code validation' );

          FND_MSG_PUB.ADD;
          x_return_status := FND_API.G_RET_STS_ERROR;

        EXCEPTION
            WHEN NO_DATA_FOUND THEN
              NULL;
        END;

	IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	   hz_utility_v2pub.debug(p_message=>'Another record exist for this style format layout with an overlapping date ranger. Please input a unique combination of style_format_code, language_code, territory_code validation' ||
                'x_return_status = ' || x_return_status,
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
        END IF;


      END IF;

    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'validate_style_fmt_locale (-)',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
    END IF;

    --disable_debug;
END validate_style_fmt_locale;

  --
  -- PROCEDURE validate_style_fmt_variation
  --
  -- DESCRIPTION
  --     Validates style record. Checks for
  --         uniqueness
  --         mandatory columns
  --         non-updateable fields
  --         foreign key validations
  --         other validations
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_create_update_flag       Create update flag. 'C' = create. 'U' = update.
  --     p_style_fmt_variation_rec  Style Locale record.
  --     p_rowid                    Rowid of the record (used only in update mode).
  --   IN/OUT:
  --     x_return_status            Return status after the call. The status can
  --                                be FND_API.G_RET_STS_SUCCESS (success),
  --                                FND_API.G_RET_STS_ERROR (error),
  --                                FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   18-JUL-2002    Kate Shan           o Created.
  --
  --

  PROCEDURE validate_style_fmt_variation(
      p_create_update_flag             IN     VARCHAR2,
      p_style_fmt_variation_rec        IN     HZ_STYLE_FMT_VARIATION_V2PUB.STYLE_FMT_VARIATION_REC_TYPE,
      p_rowid                          IN     ROWID,
      x_return_status                  IN OUT NOCOPY VARCHAR2
  )IS
      l_style_format_code      HZ_STYLE_FMT_VARIATIONS.style_format_code%TYPE;
      l_variation_number       HZ_STYLE_FMT_VARIATIONS.variation_number%TYPE;
      l_variation_rank         HZ_STYLE_FMT_VARIATIONS.variation_rank%TYPE;
      l_start_date_active      HZ_STYLE_FMT_VARIATIONS.start_date_active%TYPE;
      l_end_date_active        HZ_STYLE_FMT_VARIATIONS.end_date_active%TYPE;
      l_dummy                  VARCHAR2(1);
      l_debug_prefix           VARCHAR2(30) := '';

  BEGIN

      --enable_debug;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'validate_style_fmt_variation (+)',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- select columns needed to be checked from table during update

    IF (p_create_update_flag = 'U') THEN
        SELECT
          style_format_code,
          variation_number,
          variation_rank,
          start_date_active,
          end_date_active
        INTO
          l_style_format_code,
          l_variation_number,
          l_variation_rank,
          l_start_date_active,
          l_end_date_active
        FROM   HZ_STYLE_FMT_VARIATIONS
        WHERE  ROWID = p_rowid;
     END IF;

      -----------------------------
      -- validate style_format_code
      -----------------------------

      -- style_format_code is mandatory
      IF (p_create_update_flag = 'C') THEN
        HZ_UTILITY_V2PUB.validate_mandatory (
            p_create_update_flag                    => p_create_update_flag,
            p_column                                => 'style_format_code',
            p_column_value                          => p_style_fmt_variation_rec.style_format_code,
            x_return_status                         => x_return_status);

	IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	   hz_utility_v2pub.debug(p_message=>'style_format_code is mandatory. ' ||
                                 'x_return_status = ' || x_return_status,
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
        END IF;
      END IF;

      -- style_format_code is non-updateable field

      IF p_create_update_flag = 'U' AND
         p_style_fmt_variation_rec.style_format_code IS NOT NULL
      THEN
        HZ_UTILITY_V2PUB.validate_nonupdateable (
          p_column                 => 'style_format_code',
          p_column_value           => p_style_fmt_variation_rec.style_format_code,
          p_old_column_value       => l_style_format_code,
          x_return_status          => x_return_status);

	IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	    hz_utility_v2pub.debug(p_message=>'l_style_format_code is non-updateable. ' ||
						'x_return_status = ' || x_return_status,
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
        END IF;
      END IF;

      -- style_format_code is foreign key of hz_style_formats_b
      -- Do not need to check during update because style_format_code is
      -- non-updateable.
      IF p_create_update_flag = 'C'
         AND
         p_style_fmt_variation_rec.style_format_code IS NOT NULL
         AND
         p_style_fmt_variation_rec.style_format_code <> fnd_api.g_miss_CHAR
      THEN
          BEGIN
              SELECT 'Y'
              INTO   l_dummy
              FROM   HZ_STYLE_FORMATS_B
              WHERE  style_format_code = p_style_fmt_variation_rec.style_format_code;
          EXCEPTION
              WHEN NO_DATA_FOUND THEN
                  fnd_message.set_name('AR', 'HZ_API_INVALID_FK');
                  fnd_message.set_token('FK', 'style_format_code');
                  fnd_message.set_token('COLUMN', 'style_format_code');
                  fnd_message.set_token('TABLE', 'hz_style_formats_b');
                  fnd_msg_pub.add;
                  x_return_status := fnd_api.g_ret_sts_error;
          END;
	  IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	      hz_utility_v2pub.debug(p_message=>'style_format_code is foreign key of hz_style_formats_b. ' ||
						 'x_return_status = ' || x_return_status,
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
	  END IF;
      END IF;

      -----------------------------
      -- validate variation_number
      -----------------------------

      -- variation_number is mandatory
      IF (p_create_update_flag = 'C') THEN
        HZ_UTILITY_V2PUB.validate_mandatory (
            p_create_update_flag                    => p_create_update_flag,
            p_column                                => 'variation_number',
            p_column_value                          => p_style_fmt_variation_rec.variation_number,
            x_return_status                         => x_return_status);

	IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	   hz_utility_v2pub.debug(p_message=>'variation_number is mandatory. ' ||
                                 'x_return_status = ' || x_return_status,
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
        END IF;
      END IF;

      -- variation_number is non-updateable field

      IF p_create_update_flag = 'U' AND
         p_style_fmt_variation_rec.variation_number IS NOT NULL
      THEN
        HZ_UTILITY_V2PUB.validate_nonupdateable (
          p_column                 => 'variation_number',
          p_column_value           => p_style_fmt_variation_rec.variation_number,
          p_old_column_value       => l_variation_number,
          x_return_status          => x_return_status);

	IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	   hz_utility_v2pub.debug(p_message=>'l_variation_number is non-updateable. ' ||
						 'x_return_status = ' || x_return_status,
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
        END IF;
      END IF;

      -- The combanition of variation_number style_format_code is unique
      IF p_create_update_flag = 'C'
      THEN
        BEGIN
          select 'Y' into l_dummy
          from HZ_STYLE_FMT_VARIATIONS
          where variation_number = p_style_fmt_variation_rec.variation_number
	    and style_format_code = p_style_fmt_variation_rec.style_format_code;

          FND_MESSAGE.SET_NAME('AR', 'HZ_VARIATION_NO_DUP');
          FND_MSG_PUB.ADD;
          x_return_status := FND_API.G_RET_STS_ERROR;

        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                NULL;
        END;

	IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	   hz_utility_v2pub.debug(p_message=>'The combanition of variation_number, style_format_code is unique. ' ||
						'x_return_status = ' || x_return_status,
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
        END IF;
      END IF;

      -- variation_number should be > 0
      IF p_create_update_flag = 'C' AND
         p_style_fmt_variation_rec.variation_number is not null
      THEN
          check_greater_than_zero (
              p_column             => 'variation_number',
              p_column_value       => p_style_fmt_variation_rec.variation_number,
              x_return_status      => x_return_status );

	   IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
		hz_utility_v2pub.debug(p_message=>'variation_number should be > 0.' ||'x_return_status = ' ||
							 x_return_status,
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
	   END IF;
      END IF;


    ------------------------------
    -- variation_rank validation
    ------------------------------

      -- variation_rank is mandatory
      IF (p_create_update_flag = 'C') THEN
        HZ_UTILITY_V2PUB.validate_mandatory (
            p_create_update_flag                    => p_create_update_flag,
            p_column                                => 'variation_rank',
            p_column_value                          => p_style_fmt_variation_rec.variation_rank,
            x_return_status                         => x_return_status);

	IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	   hz_utility_v2pub.debug(p_message=>'variation_rank is mandatory. ' ||
                                 'x_return_status = ' || x_return_status,
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
        END IF;
      END IF;

      -- variation_rank is unique within style_format_code
      IF p_create_update_flag = 'C' OR
         (p_create_update_flag = 'U' AND
	  p_style_fmt_variation_rec.variation_rank is not null AND
	  p_style_fmt_variation_rec.variation_rank <> l_variation_rank)
      THEN
        BEGIN
          select 'Y' into l_dummy
          from HZ_STYLE_FMT_VARIATIONS
          where variation_rank = p_style_fmt_variation_rec.variation_rank
	    and style_format_code = p_style_fmt_variation_rec.style_format_code;

          FND_MESSAGE.SET_NAME('AR', 'HZ_VARIATION_RANK_DUP');
          FND_MSG_PUB.ADD;
          x_return_status := FND_API.G_RET_STS_ERROR;

        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                NULL;
        END;

	IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	   hz_utility_v2pub.debug(p_message=>'variation_rank is unique within style_format_code. ' ||
						'x_return_status = ' || x_return_status,
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
        END IF;
      END IF;

      -- variation_rank cannot be set to null during update
      IF p_create_update_flag = 'U' THEN
          HZ_UTILITY_V2PUB.validate_cannot_update_to_null (
              p_column                                => 'variation_rank',
              p_column_value                          => p_style_fmt_variation_rec.variation_rank,
              x_return_status                         => x_return_status);

	  IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
		 hz_utility_v2pub.debug(p_message=>'variation_rank cannot be set to null during update. ' ||
						'x_return_status = ' || x_return_status,
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
	  END IF;

      END IF;

      -- variation_rank should be > 0
      IF (p_create_update_flag = 'C' AND
          p_style_fmt_variation_rec.variation_rank is not null ) OR
         (p_create_update_flag = 'U' AND
	  p_style_fmt_variation_rec.variation_rank is not null AND
	  p_style_fmt_variation_rec.variation_rank <> fnd_api.g_miss_num AND
	  p_style_fmt_variation_rec.variation_rank <> l_variation_rank)
      THEN
          check_greater_than_zero (
              p_column             => 'variation_rank',
              p_column_value       => p_style_fmt_variation_rec.variation_rank,
              x_return_status      => x_return_status );
	   IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
		hz_utility_v2pub.debug(p_message=>'variation_rank should be > 0.' ||'x_return_status = ' ||
						  x_return_status,
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
	   END IF;
      END IF;

    -----------------------------
    -- validate start_date_active
    -----------------------------

      -- start_date_active is mandatory
      IF (p_create_update_flag = 'C') THEN
        HZ_UTILITY_V2PUB.validate_mandatory (
            p_create_update_flag                    => p_create_update_flag,
            p_column                                => 'start_date_active',
            p_column_value                          => p_style_fmt_variation_rec.start_date_active,
            x_return_status                         => x_return_status);

	IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	   hz_utility_v2pub.debug(p_message=>'start_date_active is mandatory. ' ||
                                 'x_return_status = ' || x_return_status,
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
        END IF;
      END IF;

      -- start_date_active cannot be set to null during update
      IF p_create_update_flag = 'U' THEN
          HZ_UTILITY_V2PUB.validate_cannot_update_to_null (
              p_column                                => 'start_date_active',
              p_column_value                          => p_style_fmt_variation_rec.start_date_active,
              x_return_status                         => x_return_status);

	  IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	      hz_utility_v2pub.debug(p_message=>'start_date_active cannot be set to null during update. ' ||
                  'x_return_status = ' || x_return_status,
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
	  END IF;

      END IF;

    -------------------------------------------------
    -- start_date_active, end_date_active validation
    -------------------------------------------------

      -- end_date_active must be null or greater than start date
      IF (p_create_update_flag = 'C') THEN
        IF p_style_fmt_variation_rec.end_date_active IS NOT NULL AND
           p_style_fmt_variation_rec.end_date_active <> fnd_api.g_miss_date AND
           p_style_fmt_variation_rec.end_date_active < p_style_fmt_variation_rec.start_date_active
        THEN
          fnd_message.set_name('AR', 'HZ_API_START_DATE_GREATER');
          fnd_msg_pub.add;
          x_return_status := fnd_api.g_ret_sts_error;
        END IF;
      ELSIF (p_create_update_flag = 'U') THEN
        -- old start_date_active, end_date_active has been selected from table
        -- and put into l_start_date_active, l_end_date_active

        IF p_style_fmt_variation_rec.start_date_active <> fnd_api.g_miss_date
           AND p_style_fmt_variation_rec.start_date_active is not null
        THEN
          l_start_date_active := p_style_fmt_variation_rec.start_date_active;
        END IF;

        IF p_style_fmt_variation_rec.end_date_active = fnd_api.g_miss_date
        THEN
          l_end_date_active := null;
        ELSIF p_style_fmt_variation_rec.end_date_active IS NOT NULL THEN
          l_end_date_active := p_style_fmt_variation_rec.end_date_active;
        END IF;

        IF l_end_date_active IS NOT NULL
           AND l_end_date_active < l_start_date_active
        THEN
          fnd_message.set_name('AR', 'HZ_API_START_DATE_GREATER');
          fnd_msg_pub.add;
          x_return_status := fnd_api.g_ret_sts_error;
        END IF;
     END IF;

     IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	   hz_utility_v2pub.debug(p_message=>'end_date_active must be null or greater than start date. ' ||
						'x_return_status = ' || x_return_status,
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
    END IF;

     IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'validate_style_fmt_variation (+)',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
    END IF;

     --disable_debug;

  END validate_style_fmt_variation;

  --
  -- PROCEDURE validate_style_fmt_layout
  --
  -- DESCRIPTION
  --     Validates style record. Checks for
  --         uniqueness
  --         mandatory columns
  --         non-updateable fields
  --         foreign key validations
  --         other validations
  --
  -- EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
  --
  -- ARGUMENTS
  --   IN:
  --     p_create_update_flag       Create update flag. 'C' = create. 'U' = update.
  --     p_style_fmt_layout_rec     Style Locale record.
  --     p_rowid                    Rowid of the record (used only in update mode).
  --   IN/OUT:
  --     x_return_status            Return status after the call. The status can
  --                                be FND_API.G_RET_STS_SUCCESS (success),
  --                                FND_API.G_RET_STS_ERROR (error),
  --                                FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
  --
  -- NOTES
  --
  -- MODIFICATION HISTORY
  --
  --   18-JUL-2002    Kate Shan           o Created.
  --
  --

  PROCEDURE validate_style_fmt_layout(
      p_create_update_flag             IN     VARCHAR2,
      p_style_fmt_layout_rec           IN     HZ_STYLE_FMT_LAYOUT_V2PUB.STYLE_FMT_LAYOUT_REC_TYPE,
      p_rowid                          IN     ROWID,
      x_return_status                  IN OUT NOCOPY VARCHAR2
  )  IS

      l_dummy                    VARCHAR2(1);
      l_style_fmt_layout_id      HZ_STYLE_FMT_LAYOUTS_B.style_fmt_layout_id%TYPE;
      l_style_format_code        HZ_STYLE_FMT_LAYOUTS_B.style_format_code%TYPE;
      l_variation_number         HZ_STYLE_FMT_LAYOUTS_B.variation_number%TYPE;
      l_attribute_code           HZ_STYLE_FMT_LAYOUTS_B.attribute_code%TYPE;
      l_attribute_application_id HZ_STYLE_FMT_LAYOUTS_B.attribute_application_id%TYPE;
      l_line_number              HZ_STYLE_FMT_LAYOUTS_B.line_number%TYPE;
      l_position                 HZ_STYLE_FMT_LAYOUTS_B.position%TYPE;
      l_mandatory_flag           HZ_STYLE_FMT_LAYOUTS_B.mandatory_flag%TYPE;
      l_use_initial_flag         HZ_STYLE_FMT_LAYOUTS_B.use_initial_flag%TYPE;
      l_uppercase_flag           HZ_STYLE_FMT_LAYOUTS_B.uppercase_flag%TYPE;
      l_blank_lines_before       HZ_STYLE_FMT_LAYOUTS_B.blank_lines_before%TYPE;
      l_blank_lines_after        HZ_STYLE_FMT_LAYOUTS_B.blank_lines_after%TYPE;
      l_start_date_active        date;
      l_end_date_active          date;
      l_debug_prefix             VARCHAR2(30) := '';
      l_dup_style_fmt_layout_id  HZ_STYLE_FMT_LAYOUTS_B.style_fmt_layout_id%TYPE;
      l_updated_stl_fmt_layout_rec  HZ_STYLE_FMT_LAYOUT_V2PUB.STYLE_FMT_LAYOUT_REC_TYPE;
      l_max_line_number          NUMBER;
      l_min_line_number          NUMBER;
      l_database_object_name     VARCHAR2(30);

      CURSOR c_dup (p_style_fmt_layout_id IN NUMBER) IS
        SELECT 'Y'
        FROM   hz_style_fmt_layouts_b hsfl
        WHERE  hsfl.style_fmt_layout_id = p_style_fmt_layout_id;

  BEGIN
    --enable_debug;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'validate_style_fmt_layout (+)',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- select columns needed to be checked from table during update

    IF (p_create_update_flag = 'U') THEN
        SELECT
          style_fmt_layout_id,
          style_format_code,
          variation_number,
          attribute_code,
          attribute_application_id,
          line_number,
          position,
          mandatory_flag,
          use_initial_flag,
          uppercase_flag,
          blank_lines_before,
          blank_lines_after,
          start_date_active,
          end_date_active
        INTO
          l_style_fmt_layout_id,
          l_style_format_code,
          l_variation_number,
          l_attribute_code,
          l_attribute_application_id,
          l_line_number,
          l_position,
          l_mandatory_flag,
          l_use_initial_flag,
          l_uppercase_flag,
          l_blank_lines_before,
          l_blank_lines_after,
          l_start_date_active,
          l_end_date_active
        FROM   HZ_STYLE_FMT_LAYOUTS_B
        WHERE  ROWID = p_rowid;

        get_updated_record (
            p_style_fmt_layout_id  => p_style_fmt_layout_rec.style_fmt_layout_id,
            p_update_field_rec     => p_style_fmt_layout_rec,
            x_updated_rec          => l_updated_stl_fmt_layout_rec );

     END IF;

    -------------------------------
    -- validate style_fmt_layout_id
    -------------------------------

    -- If primary key value is passed, check for uniqueness.
    -- If primary key value is not passed, it will be generated
    -- from sequence by table handler.

     IF p_create_update_flag = 'C' THEN
      IF p_style_fmt_layout_rec.style_fmt_layout_id IS NOT NULL AND
         p_style_fmt_layout_rec.style_fmt_layout_id <> fnd_api.g_miss_num
      THEN
        OPEN c_dup (p_style_fmt_layout_rec.style_fmt_layout_id);
        FETCH c_dup INTO l_dummy;
         -- key is not unique, push an error onto the stack.
        IF NVL(c_dup%FOUND, FALSE) THEN
          fnd_message.set_name('AR', 'HZ_API_DUPLICATE_COLUMN');
          fnd_message.set_token('COLUMN', 'style_fmt_layout_id');
          fnd_msg_pub.add;
          x_return_status := fnd_api.g_ret_sts_error;
        END IF;
        CLOSE c_dup;
	IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	   hz_utility_v2pub.debug(p_message=>'check that style_fmt_layout_id is unique during creation. ' ||
            ' x_return_status = ' || x_return_status,
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
        END IF;
      END IF;
    END IF;

    IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	   hz_utility_v2pub.debug(p_message=>'(+) after validate style_fmt_layout_id ... ' ||
        'x_return_status = ' || x_return_status,
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
    END IF;

      -----------------------------
      -- validate style_format_code
      -----------------------------

      -- style_format_code is mandatory
      IF (p_create_update_flag = 'C') THEN
        HZ_UTILITY_V2PUB.validate_mandatory (
            p_create_update_flag                    => p_create_update_flag,
            p_column                                => 'style_format_code',
            p_column_value                          => p_style_fmt_layout_rec.style_format_code,
            x_return_status                         => x_return_status);

	IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	   hz_utility_v2pub.debug(p_message=>'style_format_code is mandatory. ' ||
                                 'x_return_status = ' || x_return_status,
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
	END IF;
      END IF;

      -- style_format_code is non-updateable field

      IF p_create_update_flag = 'U' AND
         p_style_fmt_layout_rec.style_format_code IS NOT NULL
      THEN
        HZ_UTILITY_V2PUB.validate_nonupdateable (
          p_column                 => 'style_format_code',
          p_column_value           => p_style_fmt_layout_rec.style_format_code,
          p_old_column_value       => l_style_format_code,
          x_return_status          => x_return_status);

	IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	   hz_utility_v2pub.debug(p_message=>'l_style_format_code is non-updateable. ' ||
            'x_return_status = ' || x_return_status,
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
	END IF;
      END IF;

      -----------------------------
      -- validate variation_number
      -----------------------------

      -- variation_number is mandatory
      IF (p_create_update_flag = 'C') THEN
        HZ_UTILITY_V2PUB.validate_mandatory (
            p_create_update_flag                    => p_create_update_flag,
            p_column                                => 'variation_number',
            p_column_value                          => p_style_fmt_layout_rec.variation_number,
            x_return_status                         => x_return_status);

	IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	   hz_utility_v2pub.debug(p_message=>'variation_number is mandatory. ' ||
                                 'x_return_status = ' || x_return_status,
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
	END IF;
      END IF;

      -- variation_number is non-updateable field

      IF p_create_update_flag = 'U' AND
         p_style_fmt_layout_rec.variation_number IS NOT NULL
      THEN
        HZ_UTILITY_V2PUB.validate_nonupdateable (
          p_column                 => 'variation_number',
          p_column_value           => p_style_fmt_layout_rec.variation_number,
          p_old_column_value       => l_variation_number,
          x_return_status          => x_return_status);

	IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	   hz_utility_v2pub.debug(p_message=>'l_variation_number is non-updateable. ' ||
            'x_return_status = ' || x_return_status,
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
	END IF;
      END IF;

      -- variation_number should be > 0
      IF p_create_update_flag = 'C' AND
         p_style_fmt_layout_rec.variation_number is not null
      THEN
          check_greater_than_zero (
              p_column             => 'variation_number',
              p_column_value       => p_style_fmt_layout_rec.variation_number,
              x_return_status      => x_return_status );

	   IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
		hz_utility_v2pub.debug(p_message=>'variation_number should be > 0.' ||'x_return_status = ' ||
						 x_return_status,
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
	  END IF;
      END IF;

      ---------------------------------------------------------------------
      -- style_format_code, variation_number validation
      ---------------------------------------------------------------------
      -- combination of style_format_code, variation_number is foreign key of hz_style_formats_b
      -- Do not need to check during update because style_format_code is
      -- non-updateable.
      IF p_create_update_flag = 'C'  AND
         p_style_fmt_layout_rec.style_format_code IS NOT NULL AND
         p_style_fmt_layout_rec.style_format_code <> fnd_api.g_miss_CHAR AND
         p_style_fmt_layout_rec.variation_number IS NOT NULL AND
         p_style_fmt_layout_rec.variation_number <> fnd_api.g_miss_num

      THEN
          BEGIN
              SELECT 'Y'
              INTO   l_dummy
              FROM   HZ_STYLE_FMT_VARIATIONS
              WHERE  style_format_code = p_style_fmt_layout_rec.style_format_code AND
	             variation_number = p_style_fmt_layout_rec.variation_number;

      -- Start date and end date should be within the time range of the corresponding style format variation
              BEGIN
                  SELECT 'Y'
                  INTO   l_dummy
                  FROM   HZ_STYLE_FMT_VARIATIONS
                  WHERE  style_format_code = p_style_fmt_layout_rec.style_format_code AND
                         variation_number = p_style_fmt_layout_rec.variation_number AND
    		         p_style_fmt_layout_rec.start_date_active
    		             BETWEEN start_date_active AND NVL(end_date_active, to_date('12/31/4712','MM/DD/YYYY')) AND
          		     (decode(p_style_fmt_layout_rec.end_date_active, null, to_date('12/31/4712','MM/DD/YYYY'),
    		              fnd_api.g_miss_date, to_date('12/31/4712','MM/DD/YYYY'), p_style_fmt_layout_rec.end_date_active)
    		             BETWEEN start_date_active
                             AND    NVL(end_date_active, to_date('12/31/4712','MM/DD/YYYY')));

              EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                      fnd_message.set_name('AR', 'HZ_LYT_INVALID_START_END_DATE');
                      fnd_msg_pub.add;
                      x_return_status := fnd_api.g_ret_sts_error;
              END;
	      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
		 hz_utility_v2pub.debug(p_message=>'Start date and end date should be within the time range of the corresponding style format variation.' ||
                      'x_return_status = ' || x_return_status,
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
	      END IF;

          EXCEPTION
              WHEN NO_DATA_FOUND THEN
                  fnd_message.set_name('AR', 'HZ_INVALID_FMT_CODE_VAR_NO');
                  fnd_message.set_token('VARNUM', p_style_fmt_layout_rec.variation_number);
                  fnd_msg_pub.add;
                  x_return_status := fnd_api.g_ret_sts_error;
          END;
	  IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
		 hz_utility_v2pub.debug(p_message=>'style_format_code and variation_number are foreign key of table hz_style_fmt_variations .' ||
                  'x_return_status = ' || x_return_status,
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
	  END IF;

      ELSIF  p_create_update_flag = 'U'  AND
             x_return_status = fnd_api.g_ret_sts_success
      THEN
          BEGIN
              SELECT 'Y'
              INTO   l_dummy
              FROM   HZ_STYLE_FMT_VARIATIONS
              WHERE  style_format_code = l_updated_stl_fmt_layout_rec.style_format_code AND
	             variation_number = l_updated_stl_fmt_layout_rec.variation_number AND
		     l_updated_stl_fmt_layout_rec.start_date_active BETWEEN start_date_active
                      AND    NVL(end_date_active, to_date('12/31/4712','MM/DD/YYYY')) AND
      		     (decode(l_updated_stl_fmt_layout_rec.end_date_active, null, to_date('12/31/4712','MM/DD/YYYY'),
		             fnd_api.g_miss_date, to_date('12/31/4712','MM/DD/YYYY'), l_updated_stl_fmt_layout_rec.end_date_active)
		      BETWEEN start_date_active
                      AND    NVL(end_date_active, to_date('12/31/4712','MM/DD/YYYY')));

          EXCEPTION
              WHEN NO_DATA_FOUND THEN
                  fnd_message.set_name('AR', 'HZ_LYT_INVALID_START_END_DATE');
                  fnd_msg_pub.add;
                  x_return_status := fnd_api.g_ret_sts_error;
          END;
	  IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
		hz_utility_v2pub.debug(p_message=>'Start date and end date should be within the time range of the corresponding style format variation.' ||
                  'x_return_status = ' || x_return_status,
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
	  END IF;

      END IF;


      -----------------------------
      -- validate attribute_code
      -----------------------------

      -- attribute_code is mandatory
      IF (p_create_update_flag = 'C') THEN
        HZ_UTILITY_V2PUB.validate_mandatory (
            p_create_update_flag                    => p_create_update_flag,
            p_column                                => 'attribute_code',
            p_column_value                          => p_style_fmt_layout_rec.attribute_code,
            x_return_status                         => x_return_status);
	IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	   hz_utility_v2pub.debug(p_message=>'attribute_code is mandatory. ' ||
                                 'x_return_status = ' || x_return_status,
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
	END IF;
      END IF;

      -- attribute_code is non-updateable field

      IF p_create_update_flag = 'U' AND
         p_style_fmt_layout_rec.attribute_code IS NOT NULL
      THEN
        HZ_UTILITY_V2PUB.validate_nonupdateable (
          p_column                 => 'attribute_code',
          p_column_value           => p_style_fmt_layout_rec.attribute_code,
          p_old_column_value       => l_attribute_code,
          x_return_status          => x_return_status);

	IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	   hz_utility_v2pub.debug(p_message=>'attribute_code is non-updateable. ' ||
            'x_return_status = ' || x_return_status,
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
	END IF;
      END IF;

      ------------------------------------
      -- validate attribute_application_id
      ------------------------------------

      -- attribute_application_id is mandatory
      IF (p_create_update_flag = 'C') THEN
        HZ_UTILITY_V2PUB.validate_mandatory (
            p_create_update_flag                    => p_create_update_flag,
            p_column                                => 'attribute_application_id',
            p_column_value                          => p_style_fmt_layout_rec.attribute_application_id,
            x_return_status                         => x_return_status);

	IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	   hz_utility_v2pub.debug(p_message=>'attribute_application_id is mandatory. ' ||
                                 'x_return_status = ' || x_return_status,
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
	END IF;
      END IF;

      -- attribute_application_id is non-updateable field

      IF p_create_update_flag = 'U' AND
         p_style_fmt_layout_rec.attribute_application_id IS NOT NULL
      THEN
        HZ_UTILITY_V2PUB.validate_nonupdateable (
          p_column                 => 'attribute_application_id',
          p_column_value           => p_style_fmt_layout_rec.attribute_application_id,
          p_old_column_value       => l_attribute_application_id,
          x_return_status          => x_return_status);
	IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	   hz_utility_v2pub.debug(p_message=>'attribute_application_id is non-updateable. ' ||
		'x_return_status = ' || x_return_status,
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
	END IF;
      END IF;

      -----------------------------------------------------
      -- validate  attribute_code, attribute_application_id
      -----------------------------------------------------
      -- combination of attribute_code, variation_number is foreign key of ak_attributes
      -- Do not need to check during update because attribute_code is
      -- non-updateable.
      IF x_return_status = fnd_api.g_ret_sts_success AND
         p_create_update_flag = 'C'  AND
         p_style_fmt_layout_rec.attribute_code IS NOT NULL AND
         p_style_fmt_layout_rec.attribute_code <> fnd_api.g_miss_CHAR
--         p_style_fmt_layout_rec.attribute_application_id IS NOT NULL AND
--         p_style_fmt_layout_rec.attribute_application_id <> fnd_api.g_miss_num
      THEN
          BEGIN
              SELECT database_object_name
              INTO   l_database_object_name
              FROM   hz_style_formats_b sf, hz_styles_b s
              WHERE  sf.style_format_code = p_style_fmt_layout_rec.style_format_code AND
	             s.style_code = sf.style_code;

              SELECT 'Y'
              into   l_dummy
	      FROM   fnd_columns c, fnd_tables t
	      where  t.table_name = l_database_object_name AND
                     t.table_id = c.table_id AND
                     c.application_id = t.application_id AND --Bug No.4942505. SQLID:14450634
		     c.column_name = p_style_fmt_layout_rec.attribute_code;

          EXCEPTION
              WHEN NO_DATA_FOUND THEN
                  fnd_message.set_name('AR', 'HZ_INVALID_ATTR_APPID');
		  fnd_message.SET_TOKEN('ATTRIBUTE_CODE',p_style_fmt_layout_rec.attribute_code);
		  fnd_message.SET_TOKEN('TABLE',l_database_object_name);
                  fnd_msg_pub.add;
                  x_return_status := fnd_api.g_ret_sts_error;
          END;
	  IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	     hz_utility_v2pub.debug(p_message=>'the ATTRIBUTE_CODE' || p_style_fmt_layout_rec.attribute_code ||
					  'does not exist in table specified in ' || l_database_object_name ||
					  ' x_return_status = ' || x_return_status,
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
	  END IF;
      END IF;

      -------------------------------------------------------------------------------------------
      -- style_format_code, variation_number, attribute_code, attribute_application_id validation
      -------------------------------------------------------------------------------------------

      -- The combanition of variation_number, style_format_code, attribute_code,
      -- attribute_application_id is unique in the time range of start_date_active and
      -- end_date_active

      IF p_create_update_flag = 'C' AND
         p_style_fmt_layout_rec.style_format_code IS NOT NULL AND
         p_style_fmt_layout_rec.variation_number IS NOT NULL AND
         p_style_fmt_layout_rec.attribute_code IS NOT NULL AND
         p_style_fmt_layout_rec.attribute_application_id IS NOT NULL
      THEN
        BEGIN
          select style_fmt_layout_id into l_dup_style_fmt_layout_id
          from HZ_STYLE_FMT_LAYOUTS_B
          where style_format_code = p_style_fmt_layout_rec.style_format_code AND
                variation_number = p_style_fmt_layout_rec.variation_number AND
                attribute_code = p_style_fmt_layout_rec.attribute_code AND
                attribute_application_id = p_style_fmt_layout_rec.attribute_application_id AND
		NOT ( ( p_style_fmt_layout_rec.end_date_active is not null and
		        p_style_fmt_layout_rec.end_date_active <> fnd_api.g_miss_date and
                        p_style_fmt_layout_rec.end_date_active < start_date_active ) OR
                      ( end_date_active is not null and
                        p_style_fmt_layout_rec.start_date_active > end_date_active )) AND
		rownum =1;

          FND_MESSAGE.SET_NAME('AR', 'HZ_LAYOUT_ATTR_APPID_DUP');
          FND_MSG_PUB.ADD;
          x_return_status := FND_API.G_RET_STS_ERROR;

        EXCEPTION
            WHEN NO_DATA_FOUND THEN
              NULL;
        END;

	IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	   hz_utility_v2pub.debug(p_message=>'Another record exist for this style format layout with an overlapping date ranger. Please input a unique combination of style_format_code, variation_number, attribute_code, attribute_application_id.' ||
						'x_return_status = ' || x_return_status,
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
	END IF;

     ELSIF p_create_update_flag = 'U' AND
          (p_style_fmt_layout_rec.start_date_active is not null OR
	    p_style_fmt_layout_rec.end_date_active is not null )
     THEN

        BEGIN
          select style_fmt_layout_id into l_dup_style_fmt_layout_id
          from HZ_STYLE_FMT_LAYOUTS_B
          where style_fmt_layout_id <> l_updated_stl_fmt_layout_rec.style_fmt_layout_id AND
	        style_format_code = l_updated_stl_fmt_layout_rec.style_format_code AND
	        variation_number = l_updated_stl_fmt_layout_rec.variation_number AND
	        attribute_code = l_updated_stl_fmt_layout_rec.attribute_code AND
	        attribute_application_id = l_updated_stl_fmt_layout_rec.attribute_application_id AND
		NOT ( ( l_updated_stl_fmt_layout_rec.end_date_active is not null and
                        l_updated_stl_fmt_layout_rec.end_date_active < start_date_active ) OR
                      ( end_date_active is not null and
                        l_updated_stl_fmt_layout_rec.start_date_active > end_date_active )) AND
		rownum =1;

          FND_MESSAGE.SET_NAME('AR', 'HZ_LAYOUT_ATTR_APPID_DUP');
          FND_MSG_PUB.ADD;
	  x_return_status := FND_API.G_RET_STS_ERROR;

        EXCEPTION
            WHEN NO_DATA_FOUND THEN
              NULL;
        END;
	IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	   hz_utility_v2pub.debug(p_message=>'Another record exist for this style format layout with an overlapping date ranger. Please input a unique combination of style_format_code, variation_number, attribute_code, attribute_application_id.' ||
						'x_return_status = ' || x_return_status,
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
	END IF;

      END IF;

      ------------------------------------
      -- validate line_number
      ------------------------------------

      -- line_number  is mandatory
      IF (p_create_update_flag = 'C') THEN
        HZ_UTILITY_V2PUB.validate_mandatory (
            p_create_update_flag                    => p_create_update_flag,
            p_column                                => 'line_number ',
            p_column_value                          => p_style_fmt_layout_rec.line_number ,
            x_return_status                         => x_return_status);

	IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	   hz_utility_v2pub.debug(p_message=>'line_number  is mandatory. ' ||
                                 'x_return_status = ' || x_return_status,
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
	END IF;
      END IF;

      -- line_number should be > 0
      IF p_style_fmt_layout_rec.line_number is not null AND
         p_style_fmt_layout_rec.line_number <> fnd_api.g_miss_num
      THEN
          check_greater_than_zero (
              p_column             => 'line_number',
              p_column_value       => p_style_fmt_layout_rec.line_number,
              x_return_status      => x_return_status );
	   IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
		 hz_utility_v2pub.debug(p_message=>'line_number should be > 0.' ||'x_return_status = ' ||
					 x_return_status,
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
	   END IF;
      END IF;

      -- line_number cannot be set to null during update
      IF p_create_update_flag = 'U' THEN
          HZ_UTILITY_V2PUB.validate_cannot_update_to_null (
              p_column                                => 'line_number',
              p_column_value                          => p_style_fmt_layout_rec.line_number,
              x_return_status                         => x_return_status);
	  IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
		hz_utility_v2pub.debug(p_message=>'line_number cannot be set to null during update. ' ||
						'x_return_status = ' || x_return_status,
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
	  END IF;

      END IF;

      ------------------------------------
      -- validate position
      ------------------------------------

      -- position   is mandatory
      IF (p_create_update_flag = 'C') THEN
        HZ_UTILITY_V2PUB.validate_mandatory (
            p_create_update_flag                    => p_create_update_flag,
            p_column                                => 'position ',
            p_column_value                          => p_style_fmt_layout_rec.position  ,
            x_return_status                         => x_return_status);
	IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	   hz_utility_v2pub.debug(p_message=>'position is mandatory. ' ||
                                 'x_return_status = ' || x_return_status,
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
        END IF;
      END IF;

      -- position should be > 0
      IF p_style_fmt_layout_rec.position is not null AND
         p_style_fmt_layout_rec.position <> fnd_api.g_miss_num
      THEN
          check_greater_than_zero (
              p_column             => 'position',
              p_column_value       => p_style_fmt_layout_rec.position,
              x_return_status      => x_return_status );
	   IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
		hz_utility_v2pub.debug(p_message=>'position should be > 0.' ||'x_return_status = ' ||
						  x_return_status,
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
	   END IF;
      END IF;

      -- position cannot be set to null during update
      IF p_create_update_flag = 'U' THEN
          HZ_UTILITY_V2PUB.validate_cannot_update_to_null (
              p_column                                => 'position',
              p_column_value                          => p_style_fmt_layout_rec.position,
              x_return_status                         => x_return_status);
	  IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
		hz_utility_v2pub.debug(p_message=>'position cannot be set to null during update. ' ||
				'x_return_status = ' || x_return_status,
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
	  END IF;

      END IF;

      -------------------------------------------------------------------------------------------
      -- style_format_code, variation_number, line_number, position validation
      -------------------------------------------------------------------------------------------

      -- The combanition of variation_number, style_format_code, line_number,
      -- position is unique in the time range of start_date_active and
      -- end_date_active

      IF p_create_update_flag = 'C' AND
         p_style_fmt_layout_rec.style_format_code IS NOT NULL AND
         p_style_fmt_layout_rec.variation_number IS NOT NULL AND
         p_style_fmt_layout_rec.line_number IS NOT NULL AND
         p_style_fmt_layout_rec.position IS NOT NULL
      THEN
        BEGIN
          select style_fmt_layout_id into l_dup_style_fmt_layout_id
          from HZ_STYLE_FMT_LAYOUTS_B
          where style_format_code = p_style_fmt_layout_rec.style_format_code AND
                variation_number = p_style_fmt_layout_rec.variation_number AND
                line_number = p_style_fmt_layout_rec.line_number AND
                position = p_style_fmt_layout_rec.position AND
		NOT ( ( p_style_fmt_layout_rec.end_date_active is not null and
		        p_style_fmt_layout_rec.end_date_active <> fnd_api.g_miss_date and
                        p_style_fmt_layout_rec.end_date_active < start_date_active ) OR
                      ( end_date_active is not null and
                        p_style_fmt_layout_rec.start_date_active > end_date_active )) AND
		rownum =1;

          FND_MESSAGE.SET_NAME('AR', 'HZ_LAYOUT_LINE_POSITION_DUP');
          FND_MSG_PUB.ADD;
          x_return_status := FND_API.G_RET_STS_ERROR;

        EXCEPTION
            WHEN NO_DATA_FOUND THEN
              NULL;
        END;

	IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	   hz_utility_v2pub.debug(p_message=>'Another record exist for this style format layout with an overlapping date ranger. Please input a unique combination of style_format_code, variation_number, line_number, position.' ||
                'x_return_status = ' || x_return_status,
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
        END IF;

     ELSIF p_create_update_flag = 'U' AND
          (p_style_fmt_layout_rec.start_date_active is not null OR
	    p_style_fmt_layout_rec.end_date_active is not null )
     THEN

        BEGIN
          select style_fmt_layout_id into l_dup_style_fmt_layout_id
          from HZ_STYLE_FMT_LAYOUTS_B
          where style_fmt_layout_id <> l_updated_stl_fmt_layout_rec.style_fmt_layout_id AND
	        style_format_code = l_updated_stl_fmt_layout_rec.style_format_code AND
	        variation_number = l_updated_stl_fmt_layout_rec.variation_number AND
	        line_number = l_updated_stl_fmt_layout_rec.line_number AND
	        position = l_updated_stl_fmt_layout_rec.position AND
		NOT ( ( l_updated_stl_fmt_layout_rec.end_date_active is not null and
                        l_updated_stl_fmt_layout_rec.end_date_active < start_date_active ) OR
                      ( end_date_active is not null and
                        l_updated_stl_fmt_layout_rec.start_date_active > end_date_active )) AND
		rownum =1;

          FND_MESSAGE.SET_NAME('AR', 'HZ_LAYOUT_LINE_POSITION_DUP');
          FND_MSG_PUB.ADD;
          x_return_status := FND_API.G_RET_STS_ERROR;

        EXCEPTION
            WHEN NO_DATA_FOUND THEN
              NULL;
        END;
	IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	   hz_utility_v2pub.debug(p_message=>'Another record exist for this style format layout with an overlapping date ranger. Please input a unique combination of style_format_code, variation_number, line_number, position.' ||
                'x_return_status = ' || x_return_status,
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
	END IF;

      END IF;

      ------------------------------------
      -- validate mandatory_flag
      ------------------------------------

      -- mandatory_flag is mandatory
      IF (p_create_update_flag = 'C') THEN
        HZ_UTILITY_V2PUB.validate_mandatory (
            p_create_update_flag                    => p_create_update_flag,
            p_column                                => 'mandatory_flag',
            p_column_value                          => p_style_fmt_layout_rec.mandatory_flag   ,
            x_return_status                         => x_return_status);

	IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	   hz_utility_v2pub.debug(p_message=>'mandatory_flag  is mandatory. ' ||
                                 'x_return_status = ' || x_return_status,
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
        END IF;
      END IF;

      -- mandatory_flag cannot be set to null during update
      IF p_create_update_flag = 'U' THEN
          HZ_UTILITY_V2PUB.validate_cannot_update_to_null (
              p_column                                => 'mandatory_flag',
              p_column_value                          => p_style_fmt_layout_rec.mandatory_flag,
              x_return_status                         => x_return_status);

	  IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	     hz_utility_v2pub.debug(p_message=>'mandatory_flag cannot be set to null during update. ' ||
				'x_return_status = ' || x_return_status,
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
	  END IF;

      END IF;


      -- mandatory_flag is lookup code in lookup type YES/NO
      hz_utility_v2pub.validate_lookup (
          p_column                                => 'mandatory_flag',
          p_lookup_type                           => 'YES/NO',
          p_column_value                          => p_style_fmt_layout_rec.mandatory_flag,
          x_return_status                         => x_return_status);

      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	   hz_utility_v2pub.debug(p_message=>'mandatory_flag is lookup code in lookup type YES/NO. ' ||
						'x_return_status = ' || x_return_status,
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
      END IF;

      ------------------------------------
      -- validate use_initial_flag
      ------------------------------------

      -- use_initial_flag is mandatory
      IF (p_create_update_flag = 'C') THEN
        HZ_UTILITY_V2PUB.validate_mandatory (
            p_create_update_flag                    => p_create_update_flag,
            p_column                                => 'use_initial_flag',
            p_column_value                          => p_style_fmt_layout_rec.use_initial_flag   ,
            x_return_status                         => x_return_status);
	IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	   hz_utility_v2pub.debug(p_message=>'use_initial_flag  is mandatory. ' ||
                                 'x_return_status = ' || x_return_status,
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
	END IF;
      END IF;

      -- use_initial_flag cannot be set to null during update
      IF p_create_update_flag = 'U' THEN
          HZ_UTILITY_V2PUB.validate_cannot_update_to_null (
              p_column                                => 'use_initial_flag',
              p_column_value                          => p_style_fmt_layout_rec.use_initial_flag,
              x_return_status                         => x_return_status);

	  IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	     hz_utility_v2pub.debug(p_message=>'use_initial_flag cannot be set to null during update. ' ||
					       'x_return_status = ' || x_return_status,
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
	  END IF;

      END IF;


      -- use_initial_flag is lookup code in lookup type YES/NO
      hz_utility_v2pub.validate_lookup (
          p_column                                => 'use_initial_flag',
          p_lookup_type                           => 'YES/NO',
          p_column_value                          => p_style_fmt_layout_rec.use_initial_flag,
          x_return_status                         => x_return_status);

      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	   hz_utility_v2pub.debug(p_message=>'use_initial_flag is lookup code in lookup type YES/NO. ' ||
              'x_return_status = ' || x_return_status,
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
     END IF;

      ------------------------------------
      -- validate uppercase_flag
      ------------------------------------

      -- uppercase_flag is mandatory
      IF (p_create_update_flag = 'C') THEN
        HZ_UTILITY_V2PUB.validate_mandatory (
            p_create_update_flag                    => p_create_update_flag,
            p_column                                => 'uppercase_flag',
            p_column_value                          => p_style_fmt_layout_rec.uppercase_flag   ,
            x_return_status                         => x_return_status);

	IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	   hz_utility_v2pub.debug(p_message=>'uppercase_flag  is mandatory. ' ||
                                 'x_return_status = ' || x_return_status,
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
	END IF;
      END IF;

      -- uppercase_flag cannot be set to null during update
      IF p_create_update_flag = 'U' THEN
          HZ_UTILITY_V2PUB.validate_cannot_update_to_null (
              p_column                                => 'uppercase_flag',
              p_column_value                          => p_style_fmt_layout_rec.uppercase_flag,
              x_return_status                         => x_return_status);

	  IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	     hz_utility_v2pub.debug(p_message=>'uppercase_flag cannot be set to null during update. ' ||
			 'x_return_status = ' || x_return_status,
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
	  END IF;

      END IF;


      -- uppercase_flag is lookup code in lookup type YES/NO
      hz_utility_v2pub.validate_lookup (
          p_column                                => 'uppercase_flag',
          p_lookup_type                           => 'YES/NO',
          p_column_value                          => p_style_fmt_layout_rec.uppercase_flag,
          x_return_status                         => x_return_status);

      IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	   hz_utility_v2pub.debug(p_message=>'uppercase_flag is lookup code in lookup type YES/NO. ' ||
              'x_return_status = ' || x_return_status,
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
      END IF;

      ------------------------------------
      -- validate blank_lines_before
      ------------------------------------

      IF p_style_fmt_layout_rec.blank_lines_after is not null AND
         p_style_fmt_layout_rec.blank_lines_after <> fnd_api.g_miss_num
      THEN
          check_greater_than_zero (
              p_column             => 'blank_lines_after',
              p_column_value       => p_style_fmt_layout_rec.blank_lines_after,
              x_return_status      => x_return_status );
	  IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
		hz_utility_v2pub.debug(p_message=>'blank_lines_after should be > 0.' ||'x_return_status = ' ||
						x_return_status,
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
	  END IF;
       END IF;

      ------------------------------------
      -- validate blank_lines_after
      ------------------------------------
      IF p_style_fmt_layout_rec.blank_lines_before is not null AND
         p_style_fmt_layout_rec.blank_lines_before <> fnd_api.g_miss_num
      THEN
             check_greater_than_zero (
             p_column             => 'blank_lines_before',
             p_column_value       => p_style_fmt_layout_rec.blank_lines_before,
             x_return_status      => x_return_status );

	     IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
		 hz_utility_v2pub.debug(p_message=>'blank_lines_before should be > 0.' ||'x_return_status = ' ||
							x_return_status,
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
	     END IF;
      END IF;

      -----------------------------
      -- validate start_date_active
      -----------------------------

      -- start_date_active is mandatory
      IF (p_create_update_flag = 'C') THEN
        HZ_UTILITY_V2PUB.validate_mandatory (
            p_create_update_flag                    => p_create_update_flag,
            p_column                                => 'start_date_active',
            p_column_value                          => p_style_fmt_layout_rec.start_date_active,
            x_return_status                         => x_return_status);

	IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	   hz_utility_v2pub.debug(p_message=>'start_date_active is mandatory. ' ||
                                 'x_return_status = ' || x_return_status,
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
	END IF;
      END IF;

      -- start_date_active cannot be set to null during update
      IF p_create_update_flag = 'U' THEN
          HZ_UTILITY_V2PUB.validate_cannot_update_to_null (
              p_column                                => 'start_date_active',
              p_column_value                          => p_style_fmt_layout_rec.start_date_active,
              x_return_status                         => x_return_status);

	  IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	     hz_utility_v2pub.debug(p_message=>'start_date_active cannot be set to null during update. ' ||
                  'x_return_status = ' || x_return_status,
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
	  END IF;

      END IF;

    -------------------------------------------------
    -- start_date_active, end_date_active validation
    -------------------------------------------------

      -- end_date_active must be null or greater than start date
      IF (p_create_update_flag = 'C') THEN
        IF p_style_fmt_layout_rec.end_date_active IS NOT NULL AND
           p_style_fmt_layout_rec.end_date_active <> fnd_api.g_miss_date AND
           p_style_fmt_layout_rec.end_date_active < p_style_fmt_layout_rec.start_date_active
        THEN
          fnd_message.set_name('AR', 'HZ_API_START_DATE_GREATER');
          fnd_msg_pub.add;
          x_return_status := fnd_api.g_ret_sts_error;
        END IF;
      ELSIF (p_create_update_flag = 'U') THEN
        -- old start_date_active, end_date_active has been selected from table
        -- and put into l_start_date_active, l_end_date_active

        IF p_style_fmt_layout_rec.start_date_active <> fnd_api.g_miss_date
           AND p_style_fmt_layout_rec.start_date_active is not null
        THEN
          l_start_date_active := p_style_fmt_layout_rec.start_date_active;
        END IF;

        IF p_style_fmt_layout_rec.end_date_active = fnd_api.g_miss_date
        THEN
          l_end_date_active := null;
        ELSIF p_style_fmt_layout_rec.end_date_active IS NOT NULL THEN
          l_end_date_active := p_style_fmt_layout_rec.end_date_active;
        END IF;

        IF l_end_date_active IS NOT NULL
           AND l_end_date_active < l_start_date_active
        THEN
          fnd_message.set_name('AR', 'HZ_API_START_DATE_GREATER');
          fnd_msg_pub.add;
          x_return_status := fnd_api.g_ret_sts_error;
        END IF;
     END IF;
     IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	   hz_utility_v2pub.debug(p_message=>'end_date_active must be null or greater than start date. ' ||
						'x_return_status = ' || x_return_status,
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
     END IF;

     IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'validate_style_fmt_layout (+)',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
    END IF;


      --disable_debug;

  END validate_style_fmt_layout;

END HZ_NAME_ADDRESS_FMT_VALIDATE;

/
