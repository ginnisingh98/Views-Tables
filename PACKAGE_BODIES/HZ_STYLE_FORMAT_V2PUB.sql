--------------------------------------------------------
--  DDL for Package Body HZ_STYLE_FORMAT_V2PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_STYLE_FORMAT_V2PUB" AS
/*$Header: ARH2SFSB.pls 115.3 2003/12/22 14:33:23 rchanamo noship $ */

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

  PROCEDURE do_create_style_format(
    p_style_format_rec           IN OUT  NOCOPY style_format_rec_type,
    x_return_status              IN OUT NOCOPY  VARCHAR2
  );

  PROCEDURE do_update_style_format(
    p_style_format_rec           IN OUT  NOCOPY style_format_rec_type,
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
   * PRIVATE PROCEDURE do_create_style_format
   *
   * DESCRIPTION
   *     create style format

   *   07-23-2001    Kate Shan      o Created.
   *
   */

  PROCEDURE do_create_style_format(
    p_style_format_rec           IN OUT  NOCOPY style_format_rec_type,
    x_return_status              IN OUT NOCOPY  VARCHAR2
  ) IS
    l_rowid           ROWID := null;
    l_default_rowid   ROWID := null;
    l_debug_prefix    VARCHAR2(30) := '';
  BEGIN

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'do_create_style_format (+)',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- validate the input record
    HZ_NAME_ADDRESS_FMT_VALIDATE.validate_style_format(
      'C',
      p_style_format_rec,
      l_rowid,
      x_return_status
    );

    IF x_return_status = fnd_api.g_ret_sts_error THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    BEGIN
      -- find the original default style
      select rowid into l_default_rowid
      from HZ_STYLE_FORMATS_B
      where style_code = p_style_format_rec.style_code AND
            default_flag = 'Y';

      -- unset the original default record before create a new default record for a particular style_format_code
      IF p_style_format_rec.default_flag = 'Y' THEN
        update HZ_STYLE_FORMATS_B
	set default_flag = 'N'
	where rowid = l_default_rowid;
      END IF;

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
      -- if there is no default style, set the new record as default
      IF p_style_format_rec.default_flag = 'N' THEN
        p_style_format_rec.default_flag := 'Y';
      END IF;
    END;


    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'hz_style_formats_pkg.insert_row (+)',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
    END IF;

    HZ_STYLE_FORMATS_PKG.insert_row (
      X_ROWID                 => l_rowid,
      X_STYLE_FORMAT_CODE     => p_style_format_rec.style_format_code,
      X_STYLE_CODE            => p_style_format_rec.style_code,
      X_DEFAULT_FLAG          => p_style_format_rec.default_flag,
      X_STYLE_FORMAT_NAME     => p_style_format_rec.style_format_name,
      X_DESCRIPTION           => p_style_format_rec.description,
      x_object_version_number => 1
    );

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'hz_style_formats_pkg.insert_row (-) ' ||
                                 'p_style_format_rec.style_format_code = ' || p_style_format_rec.style_format_code,
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
	hz_utility_v2pub.debug(p_message=>'do_create_style_format (-)',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);

    END IF;
  END do_create_style_format;

  /**
   * PRIVATE PROCEDURE do_update_style_format
   *
   * DESCRIPTION
   *     update style format

   *   07-23-2001    Kate Shan      o Created.
   *
   */


  PROCEDURE do_update_style_format(
    p_style_format_rec           IN OUT  NOCOPY style_format_rec_type,
    p_object_version_number      IN OUT NOCOPY  NUMBER,
    x_return_status              IN OUT NOCOPY  VARCHAR2
  ) IS
    l_object_version_number NUMBER;
    l_debug_prefix          VARCHAR2(30) := '';
    l_rowid                 ROWID;
    l_default_rowid         ROWID := null;
    l_default_flag          HZ_STYLE_FORMATS_B.default_flag%TYPE;
    l_style_code	    HZ_STYLE_FORMATS_B.style_code%TYPE;
  BEGIN

    -- Debug info.

    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'do_update_style_format (+)',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- check whether record has been updated by another user
    BEGIN
        -- check last update date.
        SELECT object_version_number, default_flag, style_code, rowid
        INTO l_object_version_number, l_default_flag, l_style_code, l_rowid
        FROM HZ_STYLE_FORMATS_B
        WHERE style_format_code = p_style_format_rec.style_format_code
        FOR UPDATE of  style_format_code NOWAIT;

        IF NOT (
            ( p_object_version_number IS NULL AND l_object_version_number IS NULL ) OR
            ( p_object_version_number IS NOT NULL AND
              l_object_version_number IS NOT NULL AND
              p_object_version_number = l_object_version_number ) )
        THEN
            FND_MESSAGE.SET_NAME('AR', 'HZ_API_RECORD_CHANGED');
            FND_MESSAGE.SET_TOKEN('TABLE', 'hz_style_formats');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
        END IF;

        p_object_version_number := nvl(l_object_version_number, 1) + 1;

    EXCEPTION WHEN NO_DATA_FOUND THEN
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_NO_RECORD');
        FND_MESSAGE.SET_TOKEN('RECORD', 'style format');
        FND_MESSAGE.SET_TOKEN('VALUE', NVL(( p_style_format_rec.style_format_code), 'null'));
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END;

    -- validate style format record
    HZ_NAME_ADDRESS_FMT_VALIDATE.validate_style_format(
        'U',
        p_style_format_rec,
	l_rowid,
        x_return_status);

    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- default_flag cannot be set from 'Y' to 'N'
    IF p_style_format_rec.default_flag = 'Y' AND
       l_default_flag = 'N'
    THEN
      BEGIN
        -- find the default style record
        select rowid into l_default_rowid
        from HZ_STYLE_FORMATS_B
        where style_code = l_style_code AND
              default_flag = 'Y';

        -- unset the original default record before create a new default record for a particular style_format_code
        update HZ_STYLE_FORMATS_B
        set default_flag = 'N'
        where rowid = l_default_rowid;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
	  NULL;
      END;
    ELSE
      -- ignore the value of default flag if the flag
      -- has been set to 'N' or NULL or FND_API.G_MISS_CHAR.
      -- user can not unset a primary address flag by passing
      -- value 'N' or NULL. to unset a default flag, he/she
      -- needs to select another style format as primary. this
      -- style format will be unmarked automatically.

      p_style_format_rec.default_flag := NULL;

    END IF;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'HZ_STYLE_FORMATS_PKG.Update_Row (+)',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- call table handler to update a row
    HZ_STYLE_FORMATS_PKG.Update_Row (
      X_STYLE_FORMAT_CODE  => p_style_format_rec.style_format_code,
      X_STYLE_CODE         => p_style_format_rec.style_code,
      X_DEFAULT_FLAG       => p_style_format_rec.default_flag,
      X_STYLE_FORMAT_NAME  => p_style_format_rec.style_format_name,
      X_DESCRIPTION        => p_style_format_rec.description,
      X_OBJECT_VERSION_NUMBER => p_object_version_number
    );

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'HZ_STYLE_FORMATS_PKG.Update_Row (-)',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'do_update_style_format (-)',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
    END IF;

END do_update_style_format;

--------------------------------------
-- declaration of public procedures and functions
--------------------------------------

/**
 * PROCEDURE create_style_format
 *
 * DESCRIPTION
 *     Creates style_format.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_style_format_rec             Style format record.
 *   IN/OUT:
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

PROCEDURE create_style_format (
    p_init_msg_list                    IN      VARCHAR2 := FND_API.G_FALSE,
    p_style_format_rec                 IN      STYLE_FORMAT_REC_TYPE,
    x_return_status                    OUT NOCOPY     VARCHAR2,
    x_msg_count                        OUT NOCOPY     NUMBER,
    x_msg_data                         OUT NOCOPY     VARCHAR2
) IS
    l_style_format_rec        STYLE_FORMAT_REC_TYPE := p_style_format_rec;
    l_debug_prefix	      VARCHAR2(30) := '';

BEGIN

    -- standard start of API savepoint
    SAVEPOINT create_style_format;

    -- Check if API is called in debug mode. If yes, enable debug.
    --enable_debug;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'create_style_format (+)',
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
    do_create_style_format(
                       l_style_format_rec,
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
	hz_utility_v2pub.debug(p_message=>'create_style_format (-)',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- Check if API is called in debug mode. If yes, disable debug.
    --disable_debug;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO create_style_format;
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
	    hz_utility_v2pub.debug(p_message=>'create_style_format (-)',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
        END IF;

        -- Check if API is called in debug mode. If yes, disable debug.
        --disable_debug;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO create_style_format;
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
	   hz_utility_v2pub.debug(p_message=>'create_style_format (-)',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
        END IF;

        -- Check if API is called in debug mode. If yes, disable debug.
        --disable_debug;

    WHEN OTHERS THEN
        ROLLBACK TO create_style_format;
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
	    hz_utility_v2pub.debug(p_message=>'create_style_format (-)',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
        END IF;

        -- Check if API is called in debug mode. If yes, disable debug.
        --disable_debug;


END create_style_format;

/**
 * PROCEDURE update_style_format
 *
 * DESCRIPTION
 *     Updates style_format.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_style_format_rec                 Style record.
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

PROCEDURE update_style_format (
    p_init_msg_list         IN         VARCHAR2 :=FND_API.G_FALSE,
    p_style_format_rec      IN         STYLE_FORMAT_REC_TYPE,
    p_object_version_number IN OUT NOCOPY     NUMBER,
    x_return_status         OUT NOCOPY        VARCHAR2,
    x_msg_count             OUT NOCOPY        NUMBER,
    x_msg_data              OUT NOCOPY        VARCHAR2
)IS

    l_style_format_rec           STYLE_FORMAT_REC_TYPE := p_style_format_rec;
    l_old_style_format_rec       STYLE_FORMAT_REC_TYPE;
    l_debug_prefix	         VARCHAR2(30) := '';

BEGIN

    -- standard start of API savepoint
    SAVEPOINT update_style_format;

    -- Check if API is called in debug mode. If yes, enable debug.
    --enable_debug;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'update_style_format (+)',
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
    do_update_style_format(
                       l_style_format_rec,
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
	hz_utility_v2pub.debug(p_message=>'update_style_format (-)',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
    END IF;

    -- Check if API is called in debug mode. If yes, disable debug.
    --disable_debug;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO update_style_format;
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
	    hz_utility_v2pub.debug(p_message=>'update_style_format (-)',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
        END IF;

        -- Check if API is called in debug mode. If yes, disable debug.
        --disable_debug;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO update_style_format;
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
	   hz_utility_v2pub.debug(p_message=>'update_style_format (-)',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
        END IF;

        -- Check if API is called in debug mode. If yes, disable debug.
        --disable_debug;

    WHEN OTHERS THEN
        ROLLBACK TO update_style_format;
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
	    hz_utility_v2pub.debug(p_message=>'update_style_format (-)',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
        END IF;

        -- Check if API is called in debug mode. If yes, disable debug.
        --disable_debug;


END update_style_format;


/**
 * PROCEDURE get_style_format_rec
 *
 * DESCRIPTION
 *     Gets style_format record.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_style_format_code                   Style Code.
 *   IN/OUT:
 *   OUT:
 *     x_style_format_rec                 Style record.
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

 PROCEDURE get_style_format_rec (
    p_init_msg_list      IN          VARCHAR2 := FND_API.G_FALSE,
    p_style_format_code  IN          VARCHAR2,
    x_style_format_rec   OUT  NOCOPY STYLE_FORMAT_REC_TYPE,
    x_return_status      OUT NOCOPY         VARCHAR2,
    x_msg_count          OUT NOCOPY         NUMBER,
    x_msg_data           OUT NOCOPY         VARCHAR2
)IS
  l_debug_prefix	      VARCHAR2(30) := '';
  BEGIN
    -- Check if API is called in debug mode. If yes, enable debug.
    --enable_debug;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'get_style_format_rec (+)',
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
    IF p_style_format_code IS NULL OR
       p_style_format_code = fnd_api.g_miss_char THEN
      fnd_message.set_name('AR', 'HZ_API_MISSING_COLUMN');
      fnd_message.set_token('COLUMN', 'style_format_code');
      fnd_msg_pub.add;
      RAISE fnd_api.g_exc_error;
    END IF;

    x_style_format_rec.style_format_code := p_style_format_code;

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'hz_style_formats_pkg.Select_Row (+)',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
    END IF;

    hz_style_formats_pkg.select_row (
      X_STYLE_FORMAT_CODE   => x_style_format_rec.style_format_code,
      X_STYLE_CODE          => x_style_format_rec.style_code,
      X_DEFAULT_FLAG        => x_style_format_rec.default_flag,
      X_STYLE_FORMAT_NAME   => x_style_format_rec.style_format_name,
      X_DESCRIPTION         => x_style_format_rec.description
    );

    -- Debug info.
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'hz_style_formats_pkg.select_row (-)',
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
	hz_utility_v2pub.debug(p_message=>'get_style_format_rec (-)',
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
	    hz_utility_v2pub.debug(p_message=>'get_style_format_rec (-)',
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
	   hz_utility_v2pub.debug(p_message=>'get_style_format_rec (-)',
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
	    hz_utility_v2pub.debug(p_message=>'get_style_format_rec (-)',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
       END IF;

      -- Check if API is called in debug mode. If yes, disable debug.
      --disable_debug;

  END get_style_format_rec;


END HZ_STYLE_FORMAT_V2PUB;

/
