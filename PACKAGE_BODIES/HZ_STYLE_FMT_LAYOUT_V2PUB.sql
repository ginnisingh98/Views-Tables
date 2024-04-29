--------------------------------------------------------
--  DDL for Package Body HZ_STYLE_FMT_LAYOUT_V2PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_STYLE_FMT_LAYOUT_V2PUB" AS
/*$Header: ARH2FLSB.pls 115.5 2003/12/22 14:11:05 rchanamo noship $ */

  --------------------------------------
  -- declaration of private global varibles
  --------------------------------------
  g_debug_count                     NUMBER := 0;
  --g_debug                           BOOLEAN := FALSE;

  --------------------------------------
  -- declaration of private procedures and functions
  --------------------------------------
  /*PROCEDURE enable_debug;

  PROCEDURE disable_debug;
  */

  PROCEDURE do_create_style_fmt_layout(
    p_style_fmt_layout_rec       IN OUT  NOCOPY style_fmt_layout_rec_type,
    x_return_status              IN OUT NOCOPY  VARCHAR2
  );

  PROCEDURE do_update_style_fmt_layout(
    p_style_fmt_layout_rec       IN OUT  NOCOPY style_fmt_layout_rec_type,
    p_object_version_number      IN OUT NOCOPY  NUMBER,
    x_return_status              IN OUT NOCOPY  VARCHAR2
  );

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


  /**
   * PRIVATE PROCEDURE do_create_style_fmt_layout
   *
   * DESCRIPTION
   *     create style fmt layout

   *   07-23-2001    Kate Shan      o Created.
   *
   */

  PROCEDURE do_create_style_fmt_layout(
    p_style_fmt_layout_rec       IN OUT  NOCOPY style_fmt_layout_rec_type,
    x_return_status              IN OUT NOCOPY  VARCHAR2
  ) IS
    l_rowid           ROWID := null;
    l_debug_prefix    VARCHAR2(30) := '';
  BEGIN

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'do_create_style_fmt_layout (+)',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- start_date_active default to sysdate
    IF p_style_fmt_layout_rec.start_date_active is null OR
       p_style_fmt_layout_rec.start_date_active = FND_API.G_MISS_DATE
    THEN
       p_style_fmt_layout_rec.start_date_active := sysdate;
    END IF;

    -- validate the input record
    HZ_NAME_ADDRESS_FMT_VALIDATE.validate_style_fmt_layout(
      'C',
      p_style_fmt_layout_rec,
      l_rowid,
      x_return_status
    );

    IF x_return_status = fnd_api.g_ret_sts_error THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'hz_style_fmt_layouts_pkg.insert_row (+)',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
    END IF;

    HZ_STYLE_FMT_LAYOUTS_PKG.insert_row (
      X_ROWID                    => l_rowid,
      X_STYLE_FMT_LAYOUT_ID      => p_style_fmt_layout_rec.style_fmt_layout_id,
      X_STYLE_FORMAT_CODE        => p_style_fmt_layout_rec.style_format_code,
      X_VARIATION_NUMBER         => p_style_fmt_layout_rec.variation_number,
      X_ATTRIBUTE_CODE           => p_style_fmt_layout_rec.attribute_code,
      X_ATTRIBUTE_APPLICATION_ID => p_style_fmt_layout_rec.attribute_application_id,
      X_LINE_NUMBER              => p_style_fmt_layout_rec.line_number,
      X_POSITION                 => p_style_fmt_layout_rec.position,
      X_MANDATORY_FLAG           => p_style_fmt_layout_rec.mandatory_flag,
      X_USE_INITIAL_FLAG         => p_style_fmt_layout_rec.use_initial_flag,
      X_UPPERCASE_FLAG           => p_style_fmt_layout_rec.uppercase_flag,
      X_TRANSFORM_FUNCTION       => p_style_fmt_layout_rec.transform_function,
      X_DELIMITER_BEFORE         => p_style_fmt_layout_rec.delimiter_before,
      X_DELIMITER_AFTER          => p_style_fmt_layout_rec.delimiter_after,
      X_BLANK_LINES_BEFORE       => p_style_fmt_layout_rec.blank_lines_before,
      X_BLANK_LINES_AFTER        => p_style_fmt_layout_rec.blank_lines_after,
      X_PROMPT                   => p_style_fmt_layout_rec.prompt,
      X_START_DATE_ACTIVE        => p_style_fmt_layout_rec.start_date_active,
      X_END_DATE_ACTIVE          => p_style_fmt_layout_rec.end_date_active,
      X_OBJECT_VERSION_NUMBER    => 1
    );

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'hz_style_fmt_layouts_pkg.insert_row (-) ' ||
                                 'p_style_fmt_layout_rec.style_fmt_layout_id = ' || p_style_fmt_layout_rec.style_fmt_layout_id,
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
        hz_utility_v2pub.debug(p_message=>'do_create_style_fmt_layout (-)',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
    END IF;

  END do_create_style_fmt_layout;

  /**
   * PRIVATE PROCEDURE do_update_style_fmt_layout
   *
   * DESCRIPTION
   *     update style format layout

   *   07-23-2001    Kate Shan      o Created.
   *
   */


  PROCEDURE do_update_style_fmt_layout(
    p_style_fmt_layout_rec           IN OUT  NOCOPY style_fmt_layout_rec_type,
    p_object_version_number      IN OUT NOCOPY  NUMBER,
    x_return_status              IN OUT NOCOPY  VARCHAR2
  ) IS
    l_object_version_number NUMBER;
    l_debug_prefix          VARCHAR2(30) := '';
    l_rowid                 ROWID;

  BEGIN

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'do_update_style_fmt_layout (+)',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- check whether record has been updated by another user
    BEGIN
        -- check last update date.
        SELECT object_version_number, rowid
        INTO l_object_version_number, l_rowid
        FROM HZ_STYLE_FMT_LAYOUTS_B
        WHERE style_fmt_layout_id = p_style_fmt_layout_rec.style_fmt_layout_id
        FOR UPDATE of  style_fmt_layout_id NOWAIT;

        IF NOT (
            ( p_object_version_number IS NULL AND l_object_version_number IS NULL ) OR
            ( p_object_version_number IS NOT NULL AND
              l_object_version_number IS NOT NULL AND
              p_object_version_number = l_object_version_number ) )
        THEN
            FND_MESSAGE.SET_NAME('AR', 'HZ_API_RECORD_CHANGED');
            FND_MESSAGE.SET_TOKEN('TABLE', 'hz_style_fmt_layouts');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
        END IF;

        p_object_version_number := nvl(l_object_version_number, 1) + 1;

    EXCEPTION WHEN NO_DATA_FOUND THEN
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_NO_RECORD');
        FND_MESSAGE.SET_TOKEN('RECORD', 'style format layout');
        FND_MESSAGE.SET_TOKEN('VALUE', NVL(to_char( p_style_fmt_layout_rec.style_fmt_layout_id), 'null'));
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END;

    -- validate style format layout record
    HZ_NAME_ADDRESS_FMT_VALIDATE.validate_style_fmt_layout(
        'U',
        p_style_fmt_layout_rec,
	l_rowid,
        x_return_status);

    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'HZ_STYLE_FMT_LAYOUTS_PKG.Update_Row (+)',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- call table handler to update a row
    HZ_STYLE_FMT_LAYOUTS_PKG.Update_Row (
      X_STYLE_FMT_LAYOUT_ID      => p_style_fmt_layout_rec.style_fmt_layout_id,
      X_STYLE_FORMAT_CODE        => p_style_fmt_layout_rec.style_format_code,
      X_VARIATION_NUMBER         => p_style_fmt_layout_rec.variation_number,
      X_ATTRIBUTE_CODE           => p_style_fmt_layout_rec.attribute_code,
      X_ATTRIBUTE_APPLICATION_ID => p_style_fmt_layout_rec.attribute_application_id,
      X_LINE_NUMBER              => p_style_fmt_layout_rec.line_number,
      X_POSITION                 => p_style_fmt_layout_rec.position,
      X_MANDATORY_FLAG           => p_style_fmt_layout_rec.mandatory_flag,
      X_USE_INITIAL_FLAG         => p_style_fmt_layout_rec.use_initial_flag,
      X_UPPERCASE_FLAG           => p_style_fmt_layout_rec.uppercase_flag,
      X_TRANSFORM_FUNCTION       => p_style_fmt_layout_rec.transform_function,
      X_DELIMITER_BEFORE         => p_style_fmt_layout_rec.delimiter_before,
      X_DELIMITER_AFTER          => p_style_fmt_layout_rec.delimiter_after,
      X_BLANK_LINES_BEFORE       => p_style_fmt_layout_rec.blank_lines_before,
      X_BLANK_LINES_AFTER        => p_style_fmt_layout_rec.blank_lines_after,
      X_PROMPT                   => p_style_fmt_layout_rec.prompt,
      X_START_DATE_ACTIVE        => p_style_fmt_layout_rec.start_date_active,
      X_END_DATE_ACTIVE          => p_style_fmt_layout_rec.end_date_active,
      X_OBJECT_VERSION_NUMBER    => p_object_version_number
    );

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'HZ_STYLE_FMT_LAYOUTS_PKG.Update_Row (-)',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'do_update_style_fmt_layout (-)',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
    END IF;

END do_update_style_fmt_layout;


--------------------------------------
-- declaration of public procedures and functions
--------------------------------------

/**
 * PROCEDURE create_style_fmt_layout
 *
 * DESCRIPTION
 *     Creates style_fmt_layout.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_style_fmt_layout_rec         Style format layout record.
 *   IN/OUT:
 *   OUT:
 *     p_style_fmt_layout_id          style_fmt_layout id
 *     x_return_status                Return status after the call. The status can
 *                                    be FND_API.G_RET_STS_SUCCESS (success),
 *                                    FND_API.G_RET_STS_ERROR (error),
 *                                    FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
 *     x_msg_count                    Number of messages in message stack.
 *     x_msg_data                     Message text if x_msg_count is 1.
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   17-Jul-2002    Kate Shan        o Created.
 *
 */

PROCEDURE create_style_fmt_layout (
    p_init_msg_list              IN      VARCHAR2 := FND_API.G_FALSE,
    p_style_fmt_layout_rec       IN      STYLE_FMT_LAYOUT_REC_TYPE,
    x_style_fmt_layout_id        OUT NOCOPY     NUMBER,
    x_return_status              OUT NOCOPY     VARCHAR2,
    x_msg_count                  OUT NOCOPY     NUMBER,
    x_msg_data                   OUT NOCOPY     VARCHAR2
)IS
    l_style_fmt_layout_rec        STYLE_FMT_LAYOUT_REC_TYPE := p_style_fmt_layout_rec;
    l_debug_prefix		  VARCHAR2(30) := '';

BEGIN

    -- standard start of API savepoint
    SAVEPOINT create_style_fmt_layout;

    -- Check if API is called in debug mode. If yes, enable debug.
    --enable_debug;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'create_style_fmt_layout (+)',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- call to business logic.
    do_create_style_fmt_layout(
                       l_style_fmt_layout_rec,
                       x_return_status);

    x_style_fmt_layout_id := l_style_fmt_layout_rec.style_fmt_layout_id;

    -- standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data);
    -- Debug info.
    IF fnd_log.level_exception>=fnd_log.g_current_runtime_level THEN
	 hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
	                       p_msg_data=>x_msg_data,
			       p_msg_type=>'WARNING',
			       p_msg_level=>fnd_log.level_exception);
    END IF;
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'create_style_fmt_layout (-)',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- Check if API is called in debug mode. If yes, disable debug.
    --disable_debug;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO create_style_fmt_layout;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
                        p_encoded => FND_API.G_FALSE,
                        p_count => x_msg_count,
                        p_data  => x_msg_data);

        -- Debug info.
	IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
		 hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
	                       p_msg_data=>x_msg_data,
			       p_msg_type=>'ERROR',
			       p_msg_level=>fnd_log.level_error);
        END IF;
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	    hz_utility_v2pub.debug(p_message=>'create_style_fmt_layout (-)',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
        END IF;

        -- Check if API is called in debug mode. If yes, disable debug.
        --disable_debug;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO create_style_fmt_layout;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
                        p_encoded => FND_API.G_FALSE,
                        p_count => x_msg_count,
                        p_data  => x_msg_data);

        -- Debug info.
	IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
            hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
	                       p_msg_data=>x_msg_data,
			       p_msg_type=>'UNEXPECTED ERROR',
			       p_msg_level=>fnd_log.level_error);
        END IF;
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	   hz_utility_v2pub.debug(p_message=>'create_style_fmt_layout (-)',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
        END IF;

        -- Check if API is called in debug mode. If yes, disable debug.
        --disable_debug;

    WHEN OTHERS THEN
        ROLLBACK TO create_style_fmt_layout;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
        FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
        FND_MSG_PUB.ADD;

        FND_MSG_PUB.Count_And_Get(
                        p_encoded => FND_API.G_FALSE,
                        p_count => x_msg_count,
                        p_data  => x_msg_data);

        -- Debug info.
	IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
             hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
	                       p_msg_data=>x_msg_data,
			       p_msg_type=>'SQL ERROR',
			       p_msg_level=>fnd_log.level_error);
        END IF;
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	    hz_utility_v2pub.debug(p_message=>'create_style_fmt_layout (-)',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
        END IF;

        -- Check if API is called in debug mode. If yes, disable debug.
        --disable_debug;


END create_style_fmt_layout;

/**
 * PROCEDURE update_style_fmt_layout
 *
 * DESCRIPTION
 *     Updates style_fmt_layout.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_style_fmt_layout_rec         Style format layout  record.
 *   IN/OUT:
 *     p_object_version_number        Used for locking the being updated record.
 *   OUT:
 *     x_return_status                Return status after the call. The status can
 *                                    be FND_API.G_RET_STS_SUCCESS (success),
 *                                    FND_API.G_RET_STS_ERROR (error),
 *                                    FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
 *     x_msg_count                    Number of messages in message stack.
 *     x_msg_data                     Message text if x_msg_count is 1.
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   17-Jul-2002    Kate Shan        o Created.
 *
 */

PROCEDURE update_style_fmt_layout  (
    p_init_msg_list              IN      VARCHAR2 :=FND_API.G_FALSE,
    p_style_fmt_layout_rec       IN      STYLE_FMT_LAYOUT_REC_TYPE,
    p_object_version_number      IN OUT NOCOPY  NUMBER,
    x_return_status              OUT NOCOPY     VARCHAR2,
    x_msg_count                  OUT NOCOPY     NUMBER,
    x_msg_data                   OUT NOCOPY     VARCHAR2
)IS

    l_style_fmt_layout_rec           STYLE_FMT_LAYOUT_REC_TYPE := p_style_fmt_layout_rec;
    l_old_style_fmt_layout_rec       STYLE_FMT_LAYOUT_REC_TYPE;
    l_debug_prefix		     VARCHAR2(30) := '';

BEGIN

    -- standard start of API savepoint
    SAVEPOINT update_style_fmt_layout;

    -- Check if API is called in debug mode. If yes, enable debug.
    --enable_debug;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'update_style_fmt_layout (+)',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- call to business logic.
    do_update_style_fmt_layout(
                       l_style_fmt_layout_rec,
                       p_object_version_number,
                       x_return_status);

    -- standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(
                              p_encoded => FND_API.G_FALSE,
                              p_count => x_msg_count,
                              p_data  => x_msg_data);

    -- Debug info.
    IF fnd_log.level_exception>=fnd_log.g_current_runtime_level THEN
	 hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
	                       p_msg_data=>x_msg_data,
			       p_msg_type=>'WARNING',
			       p_msg_level=>fnd_log.level_exception);
    END IF;
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'update_style_fmt_layout (-)',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- Check if API is called in debug mode. If yes, disable debug.
    --disable_debug;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO update_style_fmt_layout;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
                        p_encoded => FND_API.G_FALSE,
                        p_count => x_msg_count,
                        p_data  => x_msg_data);

        -- Debug info.
	IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
		 hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
	                       p_msg_data=>x_msg_data,
			       p_msg_type=>'ERROR',
			       p_msg_level=>fnd_log.level_error);
        END IF;
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	    hz_utility_v2pub.debug(p_message=>'update_style_fmt_layout (-)',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
        END IF;

        -- Check if API is called in debug mode. If yes, disable debug.
        --disable_debug;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO update_style_fmt_layout;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
                        p_encoded => FND_API.G_FALSE,
                        p_count => x_msg_count,
                        p_data  => x_msg_data);

        -- Debug info.
	IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
            hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
	                       p_msg_data=>x_msg_data,
			       p_msg_type=>'UNEXPECTED ERROR',
			       p_msg_level=>fnd_log.level_error);
        END IF;
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	   hz_utility_v2pub.debug(p_message=>'update_style_fmt_layout (-)',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
        END IF;

        -- Check if API is called in debug mode. If yes, disable debug.
        --disable_debug;

    WHEN OTHERS THEN
        ROLLBACK TO update_style_fmt_layout;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
        FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
        FND_MSG_PUB.ADD;

        FND_MSG_PUB.Count_And_Get(
                        p_encoded => FND_API.G_FALSE,
                        p_count => x_msg_count,
                        p_data  => x_msg_data);

        -- Debug info.
	IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
             hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
	                       p_msg_data=>x_msg_data,
			       p_msg_type=>'SQL ERROR',
			       p_msg_level=>fnd_log.level_error);
        END IF;
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	    hz_utility_v2pub.debug(p_message=>'update_style_fmt_layout (-)',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
        END IF;

        -- Check if API is called in debug mode. If yes, disable debug.
        --disable_debug;


END update_style_fmt_layout;



/**
 * PROCEDURE get_style_fmt_layout_rec
 *
 * DESCRIPTION
 *     Gets style_fmt_layout record.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_style_fmt_layout_code        Style format layout  Code.
 *   IN/OUT:
 *   OUT:
 *     x_style_fmt_layout_rec         Style format layout  record.
 *     x_return_status                Return status after the call. The status can
 *                                    be FND_API.G_RET_STS_SUCCESS (success),
 *                                    FND_API.G_RET_STS_ERROR (error),
 *                                    FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
 *     x_msg_count                    Number of messages in message stack.
 *     x_msg_data                     Message text if x_msg_count is 1.
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   17-Jul-2002    Kate Shan        o Created.
 *
 */

PROCEDURE get_style_fmt_layout_rec (
    p_init_msg_list            IN         VARCHAR2 := FND_API.G_FALSE,
    p_style_fmt_layout_id      IN         NUMBER,
    x_style_fmt_layout_rec     OUT NOCOPY STYLE_FMT_LAYOUT_REC_TYPE,
    x_return_status            OUT NOCOPY        VARCHAR2,
    x_msg_count                OUT NOCOPY        NUMBER,
    x_msg_data                 OUT NOCOPY        VARCHAR2
)IS
  l_debug_prefix		  VARCHAR2(30) := '';
  BEGIN
    -- Check if API is called in debug mode. If yes, enable debug.
    --enable_debug;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'get_style_fmt_layout_rec (+)',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
    END IF;

    -- Initialize API return status to success.
    x_return_status := fnd_api.g_ret_sts_success;

    -- Check whether primary key has been passed in.
    IF p_style_fmt_layout_id IS NULL OR
       p_style_fmt_layout_id = fnd_api.g_miss_num THEN
      fnd_message.set_name('AR', 'HZ_API_MISSING_COLUMN');
      fnd_message.set_token('COLUMN', 'style_fmt_layout_id');
      fnd_msg_pub.add;
      RAISE fnd_api.g_exc_error;
    END IF;

    x_style_fmt_layout_rec.style_fmt_layout_id := p_style_fmt_layout_id;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'hz_style_fmt_layouts_pkg.Select_Row (+)',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
    END IF;

    hz_style_fmt_layouts_pkg.select_row (
      X_STYLE_FMT_LAYOUT_ID      => x_style_fmt_layout_rec.style_fmt_layout_id,
      X_STYLE_FORMAT_CODE        => x_style_fmt_layout_rec.style_format_code,
      X_VARIATION_NUMBER         => x_style_fmt_layout_rec.variation_number,
      X_ATTRIBUTE_CODE           => x_style_fmt_layout_rec.attribute_code,
      X_ATTRIBUTE_APPLICATION_ID => x_style_fmt_layout_rec.attribute_application_id,
      X_LINE_NUMBER              => x_style_fmt_layout_rec.line_number,
      X_POSITION                 => x_style_fmt_layout_rec.position,
      X_MANDATORY_FLAG           => x_style_fmt_layout_rec.mandatory_flag,
      X_USE_INITIAL_FLAG         => x_style_fmt_layout_rec.use_initial_flag,
      X_UPPERCASE_FLAG           => x_style_fmt_layout_rec.uppercase_flag,
      X_TRANSFORM_FUNCTION       => x_style_fmt_layout_rec.transform_function,
      X_DELIMITER_BEFORE         => x_style_fmt_layout_rec.delimiter_before,
      X_DELIMITER_AFTER          => x_style_fmt_layout_rec.delimiter_after,
      X_BLANK_LINES_BEFORE       => x_style_fmt_layout_rec.blank_lines_before,
      X_BLANK_LINES_AFTER        => x_style_fmt_layout_rec.blank_lines_after,
      X_PROMPT                   => x_style_fmt_layout_rec.prompt,
      X_START_DATE_ACTIVE        => x_style_fmt_layout_rec.start_date_active,
      X_END_DATE_ACTIVE	         => x_style_fmt_layout_rec.end_date_active
    );

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'hz_style_fmt_layouts_pkg.select_row (-)',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
    END IF;

    --Standard call to get message count and if count is 1, get message info.
    fnd_msg_pub.count_and_get(
      p_encoded => fnd_api.g_false,
      p_count   => x_msg_count,
      p_data    => x_msg_data
    );

    -- Debug info.
    IF fnd_log.level_exception>=fnd_log.g_current_runtime_level THEN
	 hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
	                       p_msg_data=>x_msg_data,
			       p_msg_type=>'WARNING',
			       p_msg_level=>fnd_log.level_exception);
    END IF;
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'get_style_fmt_layout_rec (-)',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- Check if API is called in debug mode. If yes, disable debug.
    --disable_debug;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(
        p_encoded => fnd_api.g_false,
        p_count => x_msg_count,
        p_data  => x_msg_data
      );

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
		 hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
	                       p_msg_data=>x_msg_data,
			       p_msg_type=>'ERROR',
			       p_msg_level=>fnd_log.level_error);
        END IF;
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	    hz_utility_v2pub.debug(p_message=>'get_style_fmt_layout_rec (-)',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
        END IF;


      -- Check if API is called in debug mode. If yes, disable debug.
      --disable_debug;

    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_msg_pub.count_and_get(
        p_encoded => fnd_api.g_false,
        p_count => x_msg_count,
        p_data  => x_msg_data
      );

      -- Debug info.
      IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
            hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
	                       p_msg_data=>x_msg_data,
			       p_msg_type=>'UNEXPECTED ERROR',
			       p_msg_level=>fnd_log.level_error);
        END IF;
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	   hz_utility_v2pub.debug(p_message=>'get_style_fmt_layout_rec (-)',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
        END IF;

      -- Check if API is called in debug mode. If yes, disable debug.
      --disable_debug;

    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
      fnd_message.set_token('ERROR' ,SQLERRM);
      fnd_msg_pub.add;

      fnd_msg_pub.count_and_get(
        p_encoded => fnd_api.g_false,
        p_count => x_msg_count,
        p_data  => x_msg_data
      );

      -- Debug info.
       IF fnd_log.level_error>=fnd_log.g_current_runtime_level THEN
             hz_utility_v2pub.debug_return_messages(p_msg_count=>x_msg_count,
	                       p_msg_data=>x_msg_data,
			       p_msg_type=>'SQL ERROR',
			       p_msg_level=>fnd_log.level_error);
        END IF;
        IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	    hz_utility_v2pub.debug(p_message=>'get_style_fmt_layout_rec (-)',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
        END IF;

      -- Check if API is called in debug mode. If yes, disable debug.
      --disable_debug;

  END get_style_fmt_layout_rec;

END HZ_STYLE_FMT_LAYOUT_V2PUB;

/