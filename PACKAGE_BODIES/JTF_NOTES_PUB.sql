--------------------------------------------------------
--  DDL for Package Body JTF_NOTES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_NOTES_PUB" AS
/* $Header: jtfnoteb.pls 120.1 2005/07/02 00:50:14 appldev ship $ */

G_PKG_NAME CONSTANT VARCHAR2(30) := 'JTF_NOTES_PUB';

PROCEDURE Create_note
------------------------------------------------------------------------------
-- Create_note
--   Inserts a note record in the JTF_NOTES_B, JTF_NOTES_TL
--   and JTF_NOTE_CONTEXTS table
------------------------------------------------------------------------------
( p_parent_note_id        IN            NUMBER   DEFAULT 9.99E125
, p_jtf_note_id           IN            NUMBER   DEFAULT 9.99E125
, p_api_version           IN            NUMBER
, p_init_msg_list         IN            VARCHAR2 DEFAULT 'F'
, p_commit                IN            VARCHAR2 DEFAULT 'F'
, p_validation_level      IN            NUMBER   DEFAULT 100
, x_return_status            OUT NOCOPY VARCHAR2
, x_msg_count                OUT NOCOPY NUMBER
, x_msg_data                 OUT NOCOPY VARCHAR2
, p_org_id                IN            NUMBER   DEFAULT NULL
, p_source_object_id      IN            NUMBER   DEFAULT 9.99E125
, p_source_object_code    IN            VARCHAR2 DEFAULT CHR(0)
, p_notes                 IN            VARCHAR2 DEFAULT CHR(0)
, p_notes_detail          IN            VARCHAR2 DEFAULT NULL
, p_note_status           IN            VARCHAR2 DEFAULT 'I'
, p_entered_by            IN            NUMBER   DEFAULT FND_GLOBAL.USER_ID
, p_entered_date          IN            DATE     DEFAULT TO_DATE('1','j')
, x_jtf_note_id              OUT NOCOPY NUMBER
, p_last_update_date      IN            DATE     DEFAULT TO_DATE('1','j')
, p_last_updated_by       IN            NUMBER   DEFAULT FND_GLOBAL.USER_ID
, p_creation_date         IN            DATE     DEFAULT TO_DATE('1','j')
, p_created_by            IN            NUMBER   DEFAULT FND_GLOBAL.USER_ID
, p_last_update_login     IN            NUMBER   DEFAULT FND_GLOBAL.LOGIN_ID
, p_attribute1            IN            VARCHAR2 DEFAULT NULL
, p_attribute2            IN            VARCHAR2 DEFAULT NULL
, p_attribute3            IN            VARCHAR2 DEFAULT NULL
, p_attribute4            IN            VARCHAR2 DEFAULT NULL
, p_attribute5            IN            VARCHAR2 DEFAULT NULL
, p_attribute6            IN            VARCHAR2 DEFAULT NULL
, p_attribute7            IN            VARCHAR2 DEFAULT NULL
, p_attribute8            IN            VARCHAR2 DEFAULT NULL
, p_attribute9            IN            VARCHAR2 DEFAULT NULL
, p_attribute10           IN            VARCHAR2 DEFAULT NULL
, p_attribute11           IN            VARCHAR2 DEFAULT NULL
, p_attribute12           IN            VARCHAR2 DEFAULT NULL
, p_attribute13           IN            VARCHAR2 DEFAULT NULL
, p_attribute14           IN            VARCHAR2 DEFAULT NULL
, p_attribute15           IN            VARCHAR2 DEFAULT NULL
, p_context               IN            VARCHAR2 DEFAULT NULL
, p_note_type             IN            VARCHAR2 DEFAULT NULL
, p_jtf_note_contexts_tab IN            jtf_note_contexts_tbl_type
                                           DEFAULT jtf_note_contexts_tab_dflt
)
IS
  l_api_name           CONSTANT VARCHAR2(30)    := 'Create_note';
  l_api_name_full      CONSTANT VARCHAR2(61)    := g_pkg_name || '.' || l_api_name;
  l_api_version        CONSTANT NUMBER          := 1.0;

BEGIN
  -- API savepoint
  SAVEPOINT create_note_pub;

  -- Check version number
  IF NOT fnd_api.compatible_api_call
                ( l_api_version
                , p_api_version
                , l_api_name
                , g_pkg_name
                )
  THEN
    RAISE fnd_api.g_exc_unexpected_error;
  END IF;

  -- Initialize message list
  IF fnd_api.to_boolean( p_init_msg_list )
  THEN
    fnd_msg_pub.initialize;
  END IF;

  -- Initialize return status to SUCCESS
  x_return_status := fnd_api.g_ret_sts_success;


  -- Call the new Note API
  Secure_Create_note( p_parent_note_id        => p_parent_note_id
                    , p_jtf_note_id           => p_jtf_note_id
                    , p_api_version           => p_api_version
                    , p_init_msg_list         => p_init_msg_list
                    , p_commit                => fnd_api.g_false
                    , p_validation_level      => p_validation_level
                    , x_return_status         => x_return_status
                    , x_msg_count             => x_msg_count
                    , x_msg_data              => x_msg_data
                    , p_org_id                => p_org_id
                    , p_source_object_id      => p_source_object_id
                    , p_source_object_code    => p_source_object_code
                    , p_notes                 => p_notes
                    , p_notes_detail          => p_notes_detail
                    , p_note_status           => p_note_status
                    , p_entered_by            => p_entered_by
                    , p_entered_date          => p_entered_date
                    , x_jtf_note_id           => x_jtf_note_id
                    , p_last_update_date      => p_last_update_date
                    , p_last_updated_by       => p_last_updated_by
                    , p_creation_date         => p_creation_date
                    , p_created_by            => p_created_by
                    , p_last_update_login     => p_last_update_login
                    , p_attribute1            => p_attribute1
                    , p_attribute2            => p_attribute2
                    , p_attribute3            => p_attribute3
                    , p_attribute4            => p_attribute4
                    , p_attribute5            => p_attribute5
                    , p_attribute6            => p_attribute6
                    , p_attribute7            => p_attribute7
                    , p_attribute8            => p_attribute8
                    , p_attribute9            => p_attribute9
                    , p_attribute10           => p_attribute10
                    , p_attribute11           => p_attribute11
                    , p_attribute12           => p_attribute12
                    , p_attribute13           => p_attribute13
                    , p_attribute14           => p_attribute14
                    , p_attribute15           => p_attribute15
                    , p_context               => p_context
                    , p_note_type             => p_note_type
                    , p_jtf_note_contexts_tab => p_jtf_note_contexts_tab
                    , p_use_AOL_security      => 'F'
                    );

  IF fnd_api.to_boolean(p_commit)
  THEN
    COMMIT WORK;
  END IF;

  fnd_msg_pub.count_and_get( p_encoded => 'F'
                           , p_count   => x_msg_count
                           , p_data    => x_msg_data
                           );
EXCEPTION
   WHEN fnd_api.g_exc_error
   THEN
     ROLLBACK TO create_note_pub;
     x_return_status := fnd_api.g_ret_sts_error;
     fnd_msg_pub.count_and_get( p_encoded => 'F'
                              , p_count   => x_msg_count
                              , p_data    => x_msg_data
                              );

   WHEN fnd_api.g_exc_unexpected_error
   THEN
      ROLLBACK TO create_note_pub;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get( p_encoded => 'F'
                               , p_count   => x_msg_count
                               , p_data    => x_msg_data
                               );

   WHEN OTHERS
   THEN
     ROLLBACK TO create_note_pub;
     x_return_status := fnd_api.g_ret_sts_unexp_error;
     IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
     THEN
       fnd_msg_pub.add_exc_msg( g_pkg_name
                              , l_api_name
                              );
     END IF;
     fnd_msg_pub.count_and_get( p_encoded => 'F'
                              , p_count   => x_msg_count
                              , p_data    => x_msg_data
                              );
END Create_note;


PROCEDURE Update_note
------------------------------------------------------------------------------
-- Update_note
--   Updates a note record in the JTF_NOTES table
------------------------------------------------------------------------------
( p_api_version           IN            NUMBER
, p_init_msg_list         IN            VARCHAR2 DEFAULT 'F'
, p_commit                IN            VARCHAR2 DEFAULT 'F'
, p_validation_level      IN            NUMBER   DEFAULT 100
, x_return_status            OUT NOCOPY VARCHAR2
, x_msg_count                OUT NOCOPY NUMBER
, x_msg_data                 OUT NOCOPY VARCHAR2
, p_jtf_note_id           IN            NUMBER
, p_entered_by            IN            NUMBER   DEFAULT FND_GLOBAL.USER_ID
, p_last_updated_by       IN            NUMBER
, p_last_update_date      IN            DATE     DEFAULT SYSDATE
, p_last_update_login     IN            NUMBER   DEFAULT NULL
, p_notes                 IN            VARCHAR2 DEFAULT CHR(0)
, p_notes_detail          IN            VARCHAR2 DEFAULT CHR(0)
, p_append_flag           IN            VARCHAR2 DEFAULT CHR(0)
, p_note_status           IN            VARCHAR2 DEFAULT 'I'
, p_note_type             IN            VARCHAR2 DEFAULT CHR(0)
, p_jtf_note_contexts_tab IN            jtf_note_contexts_tbl_type
                                          DEFAULT jtf_note_contexts_tab_dflt
)
IS
  l_api_name        CONSTANT VARCHAR2(30)   := 'Update_note';
  l_api_version     CONSTANT NUMBER         := 1.0;
  l_api_name_full   CONSTANT VARCHAR2(61)   := g_pkg_name||'.'||l_api_name;

BEGIN
  --
  -- Standard start of API savepoint
  --
  SAVEPOINT update_note_pub;

  --
  -- Standard call to check for call compatibility
  --
  IF NOT fnd_api.compatible_api_call( l_api_version
                                    , p_api_version
                                    , l_api_name, g_pkg_name
                                    )
  THEN
    RAISE fnd_api.g_exc_unexpected_error;
  END IF;

  --
  -- Initialize message list if p_init_msg_list is set to TRUE
  --
  IF fnd_api.to_boolean(p_init_msg_list)
  THEN
     fnd_msg_pub.initialize;
  END IF;

  --
  -- Initialize API return status to success
  --
  x_return_status := fnd_api.g_ret_sts_success;


  -- Call the new API
  Secure_Update_note( p_api_version           => p_api_version
                    , p_init_msg_list         => p_init_msg_list
                    , p_commit                => fnd_api.g_false
                    , p_validation_level      => p_validation_level
                    , x_return_status         => x_return_status
                    , x_msg_count             => x_msg_count
                    , x_msg_data              => x_msg_data
                    , p_jtf_note_id           => p_jtf_note_id
                    , p_entered_by            => p_entered_by
                    , p_last_updated_by       => p_last_updated_by
                    , p_last_update_date      => p_last_update_date
                    , p_last_update_login     => p_last_update_login
                    , p_notes                 => p_notes
                    , p_notes_detail          => p_notes_detail
                    , p_append_flag           => p_append_flag
                    , p_note_status           => p_note_status
                    , p_note_type             => p_note_type
                    , p_jtf_note_contexts_tab => p_jtf_note_contexts_tab
                    , p_use_AOL_security      => 'F'
                    );

  -- Standard check of p_commit
  IF fnd_api.to_boolean(p_commit)
  THEN
    COMMIT WORK;
  END IF;

  -- Standard call to get message count and if count is 1, get message info
  fnd_msg_pub.count_and_get( p_encoded => 'F'
                           , p_count   => x_msg_count
                           , p_data    => x_msg_data
                           );

EXCEPTION
   WHEN fnd_api.g_exc_error
   THEN
     ROLLBACK TO update_note_pub;

     x_return_status := fnd_api.g_ret_sts_error;

     fnd_msg_pub.count_and_get( p_encoded => 'F'
                              , p_count   => x_msg_count
                              , p_data    => x_msg_data
                              );
   WHEN fnd_api.g_exc_unexpected_error
   THEN
     ROLLBACK TO update_note_pub;

     x_return_status := fnd_api.g_ret_sts_unexp_error;

     fnd_msg_pub.count_and_get( p_encoded => 'F'
                              , p_count   => x_msg_count
                              , p_data    => x_msg_data
                              );
   WHEN OTHERS
   THEN
     ROLLBACK TO update_note_pub;

     x_return_status := fnd_api.g_ret_sts_unexp_error;

     IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
     THEN
       fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
     END IF;

     fnd_msg_pub.count_and_get( p_encoded => 'F'
                              , p_count   => x_msg_count
                              , p_data    => x_msg_data
                              );
END Update_note;


PROCEDURE Validate_note_type
------------------------------------------------------------------------------
--  Procedure    : Validate_note_type
------------------------------------------------------------------------------
( p_api_name        IN            VARCHAR2
, p_parameter_name  IN            VARCHAR2
, p_note_type       IN            VARCHAR2
, x_return_status      OUT NOCOPY VARCHAR2
)
IS
  l_dummy     VARCHAR2(1);
BEGIN
   x_return_status := fnd_api.g_ret_sts_success;

   SELECT 'x' INTO l_dummy
   FROM fnd_lookup_values
   WHERE lookup_code = p_note_type
   AND   lookup_type = 'JTF_NOTE_TYPE'
   AND   language    = USERENV('LANG');

EXCEPTION
   WHEN TOO_MANY_ROWS
   THEN
     NULL;
   WHEN NO_DATA_FOUND
   THEN
      x_return_status := fnd_api.g_ret_sts_error;
      add_invalid_argument_msg( p_api_name
                              , p_note_type
                              , p_parameter_name
                              );
   WHEN OTHERS
   THEN
      x_return_status := fnd_api.g_ret_sts_error;
      add_invalid_argument_msg( p_api_name
                              , p_note_type
                              , p_parameter_name
                              );


END Validate_note_type;

PROCEDURE Create_note_context
------------------------------------------------------------------------------
--  Procedure    : Create_note_context
------------------------------------------------------------------------------
( p_validation_level     IN            NUMBER   DEFAULT 100
, x_return_status           OUT NOCOPY VARCHAR2
, p_jtf_note_id          IN            NUMBER
, p_last_update_date     IN            DATE
, p_last_updated_by      IN            NUMBER
, p_creation_date        IN            DATE
, p_created_by           IN            NUMBER   DEFAULT FND_GLOBAL.USER_ID
, p_last_update_login    IN            NUMBER   DEFAULT FND_GLOBAL.LOGIN_ID
, p_note_context_type_id IN            NUMBER   DEFAULT 9.99E125
, p_note_context_type    IN            VARCHAR2 DEFAULT CHR(0)
, x_note_context_id         OUT NOCOPY NUMBER
)
IS
  l_api_name        CONSTANT VARCHAR2(30) := 'Create_note_context';
  l_api_name_full   CONSTANT VARCHAR2(61) := g_pkg_name || '.' || l_api_name;
  l_api_version     CONSTANT NUMBER       := 1.0;
  l_jtf_note_id              NUMBER       := NULL;
  l_note_context_id          NUMBER       := NULL;
  l_return_status            VARCHAR2(1);
  l_last_update_date         DATE;
  l_creation_date            DATE;
  l_dummy                    VARCHAR2(1);

  l_insert_failure  EXCEPTION;

  -- Cursor for retrieving from the table to verify insertion
  CURSOR c_inserted
  (b_note_context_id IN NUMBER
  )IS SELECT 'x'
      FROM jtf_note_contexts
      WHERE note_context_id = b_note_context_id;

  -- Cursor that will check for duplicates
  CURSOR c_duplicate
  ( b_jtf_note_id           IN  NUMBER
  , b_note_context_type     IN  VARCHAR2
  , b_note_context_type_id  IN  NUMBER
  )IS SELECT note_context_id
      FROM jtf_note_contexts
      WHERE jtf_note_id          = b_jtf_note_id
      AND   note_context_type    = b_note_context_type
      AND   note_context_type_id = b_note_context_type_id;

BEGIN

  -- Initialize return status to SUCCESS
  x_return_status := fnd_api.g_ret_sts_success;

  -- Defaulting
  IF p_last_update_date = fnd_api.g_miss_date
  THEN
    l_last_update_date := (SYSDATE);
  ELSE
    l_last_update_date := p_last_update_date;
  END IF;

  IF p_creation_date = fnd_api.g_miss_date
  THEN
    l_creation_date := (SYSDATE);
  ELSE
     l_creation_date := p_creation_date;
  END IF;

  -- Validation
  IF (p_validation_level > fnd_api.g_valid_level_none)
  THEN
    --Validate note_context_id based on the note_context_type
    IF (   p_note_context_type    IS NULL
       AND p_note_context_type_id IS NOT NULL
       )
       OR
       (   p_note_context_type_id IS NULL
       AND p_note_context_type    IS NOT NULL
       )
    THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    -- Validate source object id and code
    Validate_object( p_api_name         => l_api_name_full
                   , p_object_type_code => p_note_context_type
                   , p_object_type_id   => p_note_context_type_id
                   , x_return_status    => l_return_status
                   );

    IF (l_return_status <> fnd_api.g_ret_sts_success)
    THEN
      RAISE fnd_api.g_exc_error;
    END IF;
  END IF;

  -- we should only do the insert if the relation doesn't already exist
  OPEN c_duplicate( p_jtf_note_id
                  , p_note_context_type
                  , p_note_context_type_id
                  );

  FETCH c_duplicate INTO l_note_context_id;

  IF (c_duplicate%NOTFOUND)
  THEN
    INSERT INTO jtf_note_contexts
    ( note_context_id
    , jtf_note_id
    , note_context_type_id
    , note_context_type
    , last_update_date
    , last_updated_by
    , creation_date
    , created_by
    , last_update_login
    )
    VALUES
    ( jtf_notes_s.NEXTVAL
    , p_jtf_note_id
    , p_note_context_type_id
    , p_note_context_type
    , l_last_update_date
    , p_last_updated_by
    , l_creation_date
    , p_created_by
    , p_last_update_login
    )
    RETURNING note_context_id INTO l_note_context_id;

    -- Retrieve from the table to verify insertion
    OPEN c_inserted(l_note_context_id);

    FETCH c_inserted INTO l_dummy;

    IF (c_inserted%NOTFOUND)
    THEN
      -- Insert failed, raise error
      IF (c_inserted%ISOPEN)
      THEN
        CLOSE c_inserted;
      END IF;

      IF (c_duplicate%ISOPEN)
      THEN
        CLOSE c_duplicate;
      END IF;

      RAISE l_insert_failure;
    ELSE
      -- Insert was succesfull
      IF (c_inserted%ISOPEN)
      THEN
        CLOSE c_inserted;
      END IF;

      IF (c_duplicate%ISOPEN)
      THEN
        CLOSE c_duplicate;
      END IF;
      -- return the context_id
      x_note_context_id := l_note_context_id;
    END IF;
  ELSE
    -- pretend the insert was succesfull and return the ID for the (first)
    -- duplicate record
    IF (c_inserted%ISOPEN)
    THEN
      CLOSE c_inserted;
    END IF;

    IF (c_duplicate%ISOPEN)
    THEN
      CLOSE c_duplicate;
    END IF;

    x_note_context_id := l_note_context_id;

  END IF;

END Create_Note_Context;

PROCEDURE Update_note_context
------------------------------------------------------------------------------
--  Procedure    : Update_note_context
--
--  Updates a context record in the JTF_NOTE_CONTEXTS table
------------------------------------------------------------------------------
( p_validation_level     IN            NUMBER   DEFAULT fnd_api.g_valid_level_full
, x_return_status           OUT NOCOPY VARCHAR2
, p_note_context_id      IN            NUMBER
, p_jtf_note_id          IN            NUMBER
, p_note_context_type_id IN            NUMBER
, p_note_context_type    IN            VARCHAR2
, p_last_updated_by      IN            NUMBER
, p_last_update_date     IN            DATE     DEFAULT SYSDATE
, p_last_update_login    IN            NUMBER   DEFAULT NULL
)
IS
  l_api_name             CONSTANT VARCHAR2(30) := 'Update_Note_Context';
  l_api_name_full        CONSTANT VARCHAR2(61) := g_pkg_name || '.' || l_api_name;
  l_return_status                 VARCHAR2(1);
  l_note_context_type             VARCHAR2(240);
  l_note_context_type_id          NUMBER;

  CURSOR lrec_note_context
  IS SELECT *
     FROM JTF_NOTE_CONTEXTS
     WHERE note_context_id = p_note_context_id
     FOR UPDATE OF note_context_id;

  l_context_rec    lrec_note_context%ROWTYPE;

BEGIN
  -- Fetch and get the original values
  OPEN lrec_note_context;

  FETCH lrec_note_context INTO l_context_rec;

  IF (lrec_note_context%notfound)
  THEN
    add_invalid_argument_msg( l_api_name_full
                            , p_jtf_note_id
                            , 'p_jtf_note_id'
                            );

    IF (lrec_note_context%ISOPEN)
    THEN
      CLOSE lrec_note_context;
    END IF;

    RAISE fnd_api.g_exc_error;

  END IF;

  --
  -- For each column in the table, we have a corresponding local variable.
  -- These local variables are used in the actual UPDATE SQL statement. If a
  -- column is being updated, we initialize the corresponding local variable
  -- to the value of the parameter that is passed in; otherwise, the local
  -- variable is set to the original value in the database.
  --

  IF ( p_note_context_type IS NULL)
  THEN
    l_note_context_type := l_context_rec.note_context_type;
  ELSE
    l_note_context_type := p_note_context_type;
  END IF;

  IF ( p_note_context_type_id IS NULL)
  THEN
    l_note_context_type_id := l_context_rec.note_context_type_id;
  ELSE
    l_note_context_type_id := p_note_context_type_id;
  END IF;

  IF (p_validation_level > fnd_api.g_valid_level_none)
  THEN
    -- Validate source object id and code
    Validate_object( p_api_name        =>  l_api_name_full
                   , p_object_type_code  => p_note_context_type
                   , p_object_type_id   => p_note_context_type_id
                   , x_return_status    => l_return_status
                   );
    IF (l_return_status <> fnd_api.g_ret_sts_success)
    THEN
      RAISE fnd_api.g_exc_error;
    END IF;
  END IF;

  --
  -- Perform the database operation.
  --
  UPDATE JTF_NOTE_CONTEXTS
  SET last_updated_by      = p_last_updated_by
  ,   last_update_date     = p_last_update_date
  ,   last_update_login    = p_last_update_login
  ,   note_context_type_id = l_note_context_type_id
  ,   note_context_type    = l_note_context_type
  WHERE CURRENT OF lrec_note_context;

  IF (lrec_note_context%ISOPEN)
  THEN
    CLOSE lrec_note_context;
  END IF;

EXCEPTION
  WHEN OTHERS
  THEN
    IF (lrec_note_context%ISOPEN)
    THEN
      CLOSE lrec_note_context;
    END IF;

    RAISE fnd_api.g_exc_unexpected_error;

END Update_note_Context;

PROCEDURE Add_Invalid_Argument_Msg
------------------------------------------------------------------------------
--  Procedure    : Add_Invalid_Argument_Msg
------------------------------------------------------------------------------
( p_token_an   IN    VARCHAR2
, p_token_v    IN    VARCHAR2
, p_token_p    IN    VARCHAR2
)
IS
BEGIN
  IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error)
  THEN
    fnd_message.set_name('JTF', 'JTF_API_ALL_INVALID_ARGUMENT');
    fnd_message.set_token('API_NAME', p_token_an);
    fnd_message.set_token('VALUE', p_token_v);
    fnd_message.set_token('PARAMETER', p_token_p);
    fnd_msg_pub.add;
  END IF;
END Add_Invalid_Argument_Msg;


PROCEDURE Add_Null_Parameter_Msg
------------------------------------------------------------------------------
--  Procedure    : Add_Null_Parameter_Msg
------------------------------------------------------------------------------
( p_token_an    IN    VARCHAR2
, p_token_np    IN    VARCHAR2
)
IS
BEGIN
  IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error)
  THEN
    fnd_message.set_name('JTF', 'JTF_API_ALL_NULL_PARAMETER');
    fnd_message.set_token('API_NAME', p_token_an);
    fnd_message.set_token('NULL_PARAM', p_token_np);
    fnd_msg_pub.add;
  END IF;
END Add_Null_Parameter_Msg;

PROCEDURE Trunc_String_length
------------------------------------------------------------------------------
--  Procedure    : Trunc_String_Length
------------------------------------------------------------------------------
( p_api_name       IN            VARCHAR2
, p_parameter_name IN            VARCHAR2
, p_str            IN            VARCHAR2
, p_len            IN            NUMBER
, x_str               OUT NOCOPY VARCHAR2
)
IS
  l_len    NUMBER;

BEGIN
  l_len := LENGTHB(p_str);
  IF (l_len > p_len)
  THEN
    IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_success)
    THEN
      fnd_message.set_name('JTF', 'JTF_API_ALL_VALUE_TRUNCATED');
      fnd_message.set_token('API_NAME', p_api_name);
      fnd_message.set_token('TRUNCATED_PARAM', p_parameter_name);
      fnd_message.set_token('VAL_LEN', l_len);
      fnd_message.set_token('DB_LEN', p_len);
      fnd_msg_pub.add;
    END IF;
    x_str := substrb(p_str, 1, p_len);
  ELSE
    x_str := p_str;
  END IF;
END Trunc_String_Length;



PROCEDURE Add_Missing_Param_Msg
------------------------------------------------------------------------------
--  Procedure    : Add_Missing_Param_Msg
------------------------------------------------------------------------------
( p_token_an    IN    VARCHAR2
, p_token_mp    IN    VARCHAR2
)
IS
BEGIN
  IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error)
  THEN
    fnd_message.set_name('JTF', 'JTF_API_ALL_MISSING_PARAM');
    fnd_message.set_token('API_NAME', p_token_an);
    fnd_message.set_token('MISSING_PARAM', p_token_mp);
    fnd_msg_pub.add;
  END IF;
END Add_MIssing_Param_Msg;

PROCEDURE Validate_object
------------------------------------------------------------------------------
--  Procedure    : Validate_object
------------------------------------------------------------------------------
( p_api_name         IN         VARCHAR2
, p_object_type_code IN         VARCHAR2
, p_object_type_id   IN         NUMBER
, x_return_status    OUT NOCOPY VARCHAR2
)
IS
  l_return_status    VARCHAR2(30);
  l_result           NUMBER := 0;
  l_select_id        VARCHAR2(200);
  l_tablename        VARCHAR2(200);
  l_where_clause     VARCHAR2(2000);
  v_cursor           NUMBER;
  v_create_string    VARCHAR2(32000);
  v_numrows          NUMBER;

  CURSOR cur_object
  IS SELECT select_id
     ,      from_table
     ,      where_clause
     FROM   jtf_objects_vl a
     ,      jtf_object_usages b
     WHERE  a.object_code = p_object_type_code
     AND    a.object_code = b.object_code
     AND    b.object_user_code = 'NOTES';

BEGIN
  OPEN cur_object;
  FETCH cur_object INTO l_select_id,l_tablename,l_where_clause ;
  CLOSE cur_object;

  IF l_where_clause IS NULL
  THEN
    v_create_string := 'SELECT COUNT(*)  FROM '||l_tablename||
                       ' WHERE '||l_select_id||' = :object_type_id ';
  ELSE
    v_create_string := 'SELECT COUNT(*)  FROM '||l_tablename||
                       ' WHERE '||l_where_clause||
                       ' AND '||l_select_id||' = :object_type_id ';
  END IF;

  EXECUTE IMMEDIATE v_create_string
  INTO l_result
  USING p_object_type_id;


  IF (l_result > 0)
  THEN
    x_return_status := fnd_api.g_ret_sts_success;
  ELSE
    add_invalid_argument_msg( p_api_name
                            , p_object_type_code
                            , 'Object Code'
                            );

    add_invalid_argument_msg( p_api_name
                            , p_object_type_id
                            , 'Object Id'
                            );
    x_return_status := fnd_api.g_ret_sts_error;
  END IF;

EXCEPTION
 WHEN OTHERS
 THEN
   IF (cur_object%ISOPEN)
   THEN
     CLOSE cur_object;
   END IF;
   x_return_status := fnd_api.g_ret_sts_error;
   add_invalid_argument_msg( p_api_name
                           , p_object_type_code
                           , 'Object Code'
                           );
   add_invalid_argument_msg( p_api_name
                           , p_object_type_id
                           , 'Object Id'
                           );
END Validate_Object;


PROCEDURE writeDatatoLob
------------------------------------------------------------------------------
--  Procedure    : writeDatatoLob
------------------------------------------------------------------------------
( x_jtf_note_id IN  NUMBER
, x_buffer      IN  VARCHAR2
)
IS

  Position   INTEGER := 1;

  CURSOR c1
  IS SELECT notes_detail
     FROM  jtf_notes_tl
     WHERE jtf_note_id = x_jtf_note_id
     FOR UPDATE;

BEGIN
  FOR i IN c1
  LOOP
    DBMS_LOB.WRITE(i.notes_detail,LENGTH(x_buffer),position,x_buffer);
  END LOOP;
END WriteDataToLob;


PROCEDURE writeLobToData
------------------------------------------------------------------------------
--  Procedure    : writeLobToData
------------------------------------------------------------------------------
( x_jtf_note_id               NUMBER
, x_buffer         OUT NOCOPY VARCHAR2
)
IS
  lob_loc   CLOB;
  Amount    BINARY_INTEGER := 32767;
  Position  INTEGER := 1;
  Buffer    VARCHAR2(32767);
  Chunksize INTEGER;

BEGIN

  SELECT notes_detail
  INTO lob_loc
  FROM jtf_notes_vl
  WHERE jtf_note_id = x_jtf_note_id;

  Chunksize := DBMS_LOB.GETCHUNKSIZE(lob_loc);

  IF Chunksize IS NOT NULL
  THEN
    IF chunksize < 32767
    THEN
      amount := (32767/chunksize) * chunksize;
    END IF;

    DBMS_LOB.READ(lob_loc,amount,position,buffer);

  END IF;

  x_buffer := buffer;

EXCEPTION
  WHEN NO_DATA_FOUND
  THEN
    x_buffer := NULL;
  WHEN TOO_MANY_ROWS
  THEN
    x_buffer := NULL;
END WriteLobtoData;


PROCEDURE validate_entered_by
------------------------------------------------------------------------------
--  Procedure    : writeDatatoLob
------------------------------------------------------------------------------
( p_entered_by     IN            NUMBER
, x_return_status     OUT NOCOPY VARCHAR2
, x_entered_by        OUT NOCOPY NUMBER
)
IS
   CURSOR c_entered_by
   IS SELECT user_id
      FROM fnd_user
      WHERE user_id = p_entered_by
      AND NVL (end_date, SYSDATE) >= SYSDATE
      AND NVL (start_date, SYSDATE) <= SYSDATE;

BEGIN
   x_return_status := fnd_api.g_ret_sts_success;

   IF p_entered_by  IS NOT NULL
   THEN
     OPEN c_entered_by;
     FETCH c_entered_by INTO x_entered_by;

     IF (c_entered_by%NOTFOUND)
     THEN
       fnd_message.set_name('JTF', 'JTF_API_ALL_INVALID_ARGUMENT');
       fnd_message.set_token('API_NAME', 'JTF_NOTES_PUB.CREATE_NOTE');
       fnd_message.set_token('PARAMETER', 'p_entered_by');
       fnd_message.set_token('VALUE', p_entered_by);
       fnd_msg_pub.ADD;
       x_return_status := fnd_api.g_ret_sts_unexp_error;

       IF (c_entered_by%ISOPEN)
       THEN
         CLOSE c_entered_by;
       END IF;

       RAISE fnd_api.g_exc_unexpected_error;
     END IF;

     IF (c_entered_by%ISOPEN)
     THEN
       CLOSE c_entered_by;
     END IF;
   END IF;
EXCEPTION
  WHEN OTHERS
  THEN
    IF (c_entered_by%ISOPEN)
    THEN
      CLOSE c_entered_by;
    END IF;

    RAISE fnd_api.g_exc_unexpected_error;

END validate_entered_by;

PROCEDURE Secure_Delete_note
-- --------------------------------------------------------------------------
-- Start of notes
--  API Name  : Delete_Note will only work when the user is granted the
--              JTF_NOTE_DELETE privilege through AOL security framework
--  Type      : Public
--  Usage     : Deletes a note record in the table JTF_NOTES_B/JTF_NOTES_TL
--              and JTF_NOTE_CONTEXTS
--  Pre-reqs  : None
--  Parameters  :
--    p_api_version           IN    NUMBER     Required
--    p_init_msg_list         IN    VARCHAR2   Optional Default = FND_API.G_FALSE
--    p_commit                IN    VARCHAR2   Optional Default = FND_API.G_FALSE
--    p_validation_level      IN    NUMBER     Optional Default = FND_API.G_VALID_LEVEL_FULL
--    x_return_status           OUT VARCHAR2   Required
--    x_msg_count               OUT NUMBER     Required
--    x_msg_data                OUT VARCHAR2   Required
--    p_jtf_note_id           IN    NUMBER     Required Primary key of the note record
--    p_use_AOL_security      IN    VARCHAR2   Optional Default FND_API.G_TRUE
--
--  Version	: Initial version	1.0
--
--
-- End of notes
-- --------------------------------------------------------------------------
( p_api_version           IN            NUMBER
, p_init_msg_list         IN            VARCHAR2 DEFAULT 'F'
, p_commit                IN            VARCHAR2 DEFAULT 'F'
, p_validation_level      IN            NUMBER   DEFAULT 100
, x_return_status            OUT NOCOPY VARCHAR2
, x_msg_count                OUT NOCOPY NUMBER
, x_msg_data                 OUT NOCOPY VARCHAR2
, p_jtf_note_id           IN            NUMBER
, p_use_AOL_security      IN            VARCHAR2 DEFAULT 'T'
)IS
  l_api_name       CONSTANT VARCHAR2(30)    := 'Delete_note';
  l_api_version    CONSTANT NUMBER          := 1.0;
  l_api_name_full  CONSTANT VARCHAR2(61)    := G_PKG_NAME||'.'||l_api_name;

  l_return_status           VARCHAR2(1);
  l_msg_count               NUMBER;
  l_msg_data                VARCHAR2(2000);
  l_note_delete             NUMBER;

  l_source_object_code      VARCHAR2(240);
  l_source_object_id        NUMBER;


BEGIN
  -- API savepoint
  SAVEPOINT delete_note_pub;

  --
  -- Standard call to check for call compatibility
  --
  IF NOT FND_API.Compatible_API_Call( l_api_version
                                    , p_api_version
                                    , l_api_name
                                    , G_PKG_NAME
                                    )
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  --
  -- Initialize message list if p_init_msg_list is set to TRUE
  --
  IF FND_API.To_Boolean(p_init_msg_list)
  THEN
    FND_MSG_PUB.Initialize;
  END IF;

  --
  -- Initialize API return status to success
  --
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --
  -- Security validations
  --
  IF (p_use_AOL_security = fnd_api.g_true)
  THEN
    --
    -- Check if the user is allowed to delete this note
    --
    JTF_NOTES_SECURITY_PVT.check_function
    ( p_api_version         => 1.0
    , p_init_msg_list       => FND_API.G_FALSE
    , p_function            => JTF_NOTES_SECURITY_PVT.G_FUNCTION_DELETE
    , p_object_name         => JTF_NOTES_SECURITY_PVT.G_OBJECT_NOTE
    , p_instance_pk1_value  => p_jtf_note_id
    , x_grant               => l_note_delete
    , x_return_status       => l_return_status
    , x_msg_count           => l_msg_count
    , x_msg_data            => l_msg_data
    );

    --
    -- If there's an error push it onto the stack
    --
    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS)
    THEN
      FND_MESSAGE.SET_NAME('JTF', 'JTF_UNABLE_TO_CHECK_FUNCTION');  -- Unable to verify whether Security &FUNCTION function was granted
      FND_MESSAGE.SET_TOKEN('FUNCTION', 'JTF_NOTE_DELETE');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    --
    -- If the create function was not granted throw an error
    --
    IF (l_note_delete = 0)
    THEN
      FND_MESSAGE.SET_NAME('JTF', 'JTF_FUNCTION_NOT_GRANTED');  -- Security &FUNCTION function was not granted
      FND_MESSAGE.SET_TOKEN('FUNCTION', 'JTF_NOTE_DELETE');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
  END IF; -- end of Security validations

  --
  -- get the source onject information so we can pas it to the WF event
  --
  SELECT source_object_code
  ,      source_object_id
  INTO l_source_object_code
  ,    l_source_object_id
  FROM jtf_notes_b
  WHERE jtf_note_id = p_jtf_note_id;

  --
  -- Delete the note and it's references
  --
  DELETE FROM jtf_note_contexts WHERE jtf_note_id = p_jtf_note_id;
  DELETE FROM jtf_notes_tl      WHERE jtf_note_id = p_jtf_note_id;
  DELETE FROM jtf_notes_b       WHERE jtf_note_id = p_jtf_note_id;

  JTF_NOTES_EVENTS_PVT.RaiseDeleteNote
  ( p_NoteID            => p_jtf_note_id
  , p_SourceObjectCode  => l_source_object_code
  , p_SourceObjectID    => l_source_object_id
  );

  -- Standard check of p_commit
  IF fnd_api.to_boolean(p_commit)
  THEN
    COMMIT WORK;
  END IF;

  --
  -- Standard call to get message count and if count is 1, get message info
  --
  FND_MSG_PUB.Count_And_Get( p_count => x_msg_count
                           , p_data  => x_msg_data
                           );

EXCEPTION
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR
  THEN
     ROLLBACK TO delete_note_pub;
    --
    -- Set status
    --
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    --
    -- Get error message from FND stack
    --
    l_msg_data      := FND_MESSAGE.GET;

    --
    -- Push message onto CRM stack
    --
    FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME
                           , l_api_name
                           , l_msg_data
                           );
    --
    -- Count the messages on the CRM stack
    --
    x_msg_count     := FND_MSG_PUB.COUNT_MSG;

  WHEN OTHERS
  THEN
     ROLLBACK TO delete_note_pub;
    --
    -- Set status
    --
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    --
    -- Push message onto CRM stack
    --
    FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME
                           , l_api_name
                           , SQLERRM
                           );
    --
    -- Count the messages on the CRM stack
    --
    x_msg_count     := FND_MSG_PUB.COUNT_MSG;

END Secure_Delete_Note;


PROCEDURE Secure_Create_note
------------------------------------------------------------------------------
-- Create_note
--   Inserts a note record in the JTF_NOTES_B, JTF_NOTES_TL
--   and JTF_NOTE_CONTEXTS table
------------------------------------------------------------------------------
( p_parent_note_id        IN             NUMBER   DEFAULT 9.99E125
, p_jtf_note_id           IN             NUMBER   DEFAULT 9.99E125
, p_api_version           IN             NUMBER
, p_init_msg_list         IN             VARCHAR2 DEFAULT 'F'
, p_commit                IN             VARCHAR2 DEFAULT 'F'
, p_validation_level      IN             NUMBER   DEFAULT 100
, x_return_status            OUT  NOCOPY VARCHAR2
, x_msg_count                OUT  NOCOPY NUMBER
, x_msg_data                 OUT  NOCOPY VARCHAR2
, p_org_id                IN             NUMBER   DEFAULT NULL
, p_source_object_id      IN             NUMBER   DEFAULT 9.99E125
, p_source_object_code    IN             VARCHAR2 DEFAULT CHR(0)
, p_notes                 IN             VARCHAR2 DEFAULT CHR(0)
, p_notes_detail          IN             VARCHAR2 DEFAULT NULL
, p_note_status           IN             VARCHAR2 DEFAULT 'I'
, p_entered_by            IN             NUMBER   DEFAULT fnd_global.user_id
, p_entered_date          IN             DATE     DEFAULT TO_DATE('1','j')
, x_jtf_note_id              OUT  NOCOPY NUMBER
, p_last_update_date      IN             DATE     DEFAULT TO_DATE('1','j')
, p_last_updated_by       IN             NUMBER   DEFAULT fnd_global.user_id
, p_creation_date         IN             DATE     DEFAULT TO_DATE('1','j')
, p_created_by            IN             NUMBER   DEFAULT fnd_global.user_id
, p_last_update_login     IN             NUMBER   DEFAULT fnd_global.login_id
, p_attribute1            IN             VARCHAR2 DEFAULT NULL
, p_attribute2            IN             VARCHAR2 DEFAULT NULL
, p_attribute3            IN             VARCHAR2 DEFAULT NULL
, p_attribute4            IN             VARCHAR2 DEFAULT NULL
, p_attribute5            IN             VARCHAR2 DEFAULT NULL
, p_attribute6            IN             VARCHAR2 DEFAULT NULL
, p_attribute7            IN             VARCHAR2 DEFAULT NULL
, p_attribute8            IN             VARCHAR2 DEFAULT NULL
, p_attribute9            IN             VARCHAR2 DEFAULT NULL
, p_attribute10           IN             VARCHAR2 DEFAULT NULL
, p_attribute11           IN             VARCHAR2 DEFAULT NULL
, p_attribute12           IN             VARCHAR2 DEFAULT NULL
, p_attribute13           IN             VARCHAR2 DEFAULT NULL
, p_attribute14           IN             VARCHAR2 DEFAULT NULL
, p_attribute15           IN             VARCHAR2 DEFAULT NULL
, p_context               IN             VARCHAR2 DEFAULT NULL
, p_note_type             IN             VARCHAR2 DEFAULT NULL
, p_jtf_note_contexts_tab IN             jtf_note_contexts_tbl_type
                                           DEFAULT jtf_note_contexts_tab_dflt
, p_use_AOL_security      IN             VARCHAR2 DEFAULT 'T'

)
IS
  l_api_name           CONSTANT VARCHAR2(30)    := 'Secure_Create_note';
  l_api_name_full      CONSTANT VARCHAR2(61)    := g_pkg_name || '.' || l_api_name;
  l_api_version        CONSTANT NUMBER          := 1.0;

  l_note_status                 VARCHAR2(1)     := p_note_status;
  l_jtf_note_id                 NUMBER          := p_jtf_note_id;
  l_note_context_id             NUMBER          := NULL;
  l_return_status               VARCHAR2(1);
  l_entered_by                  NUMBER          := p_entered_by;
  l_entered_date                DATE            := p_entered_date;
  l_last_update_date            DATE            := p_last_update_date;
  l_last_updated_by             NUMBER          := p_last_updated_by;
  l_creation_date               DATE;
  l_parent_note_id              NUMBER;

  l_dummy                       VARCHAR2(1);
  l_notes_detail                VARCHAR2(32767) := p_notes_detail;
  l_notes                       VARCHAR2(32767) := p_notes;
  l_rowid                       ROWID;
  l_msg_count                   NUMBER ;
  l_msg_data                    VARCHAR2(2000);
  l_source_object_id            NUMBER          := p_source_object_id;
  l_source_object_code          VARCHAR2(240)   := p_source_object_code;
  l_bind_data_id                NUMBER;

  l_grant_select                NUMBER          := 1;
  l_grant_select_type           NUMBER          := 1;

  -- Used for keeping track of errors
  l_missing_param               VARCHAR2(30)    := NULL;
  l_null_param                  VARCHAR2(30)    := NULL;



  -- Cursor for getting the note ID from the sequence
  CURSOR l_jtf_note_id_csr
  IS  SELECT JTF_NOTES_S.NEXTVAL
      FROM DUAL;

  -- Cursor for retrieving from the table to verify insertion
  CURSOR l_insert_check_csr
  IS  SELECT 'x'
      FROM JTF_NOTES_B
      WHERE jtf_note_id = l_jtf_note_id;


  -- Local exceptions
  l_missing_parameter     EXCEPTION;
  l_null_parameter        EXCEPTION;
  l_insert_failure        EXCEPTION;
  l_duplicate_note        EXCEPTION;

BEGIN
  -- API savepoint
  SAVEPOINT create_note_pvt;

  -- Check version number
  IF NOT fnd_api.compatible_api_call
                ( l_api_version
                , p_api_version
                , l_api_name
                , g_pkg_name
                )
  THEN
    RAISE fnd_api.g_exc_unexpected_error;
  END IF;

  -- Initialize message list
  IF fnd_api.to_boolean( p_init_msg_list )
  THEN
    fnd_msg_pub.initialize;
  END IF;

  -- Initialize return status to SUCCESS
  x_return_status := fnd_api.g_ret_sts_success;

  --
  -- Make the preprocessing call to the user hooks
  --
  -- Pre call to the Customer Type User Hook
  --
  IF jtf_usr_hks.ok_to_execute('JTF_NOTES_PUB'
                              ,'Create_Note'
                              ,'B'
                              ,'C'
                              )
  THEN
    jtf_notes_cuhk.create_note_pre
    ( p_parent_note_id          => p_parent_note_id
    , p_api_version             => p_api_version
    , p_init_msg_list           => p_init_msg_list
    , p_commit                  => FND_API.G_FALSE
    , p_validation_level        => p_validation_level
    , x_msg_count               => x_msg_count
    , x_msg_data                => x_msg_data
    , p_org_id                  => p_org_id
    , p_source_object_id        => p_source_object_id
    , p_source_object_code      => p_source_object_code
    , p_notes                   => p_notes
    , p_notes_detail            => p_notes_detail
    , p_note_status             => p_note_status
    , p_entered_by              => p_entered_by
    , p_entered_date            => p_entered_date
    , x_jtf_note_id             => x_jtf_note_id
    , p_last_update_date        => p_last_update_date
    , p_last_updated_by         => p_last_updated_by
    , p_creation_date           => p_creation_date
    , p_created_by              => p_created_by
    , p_last_update_login       => p_last_update_login
    , p_attribute1              => p_attribute1
    , p_attribute2              => p_attribute2
    , p_attribute3              => p_attribute3
    , p_attribute4              => p_attribute4
    , p_attribute5              => p_attribute5
    , p_attribute6              => p_attribute6
    , p_attribute7              => p_attribute7
    , p_attribute8              => p_attribute8
    , p_attribute9              => p_attribute9
    , p_attribute10             => p_attribute10
    , p_attribute11             => p_attribute11
    , p_attribute12             => p_attribute12
    , p_attribute13             => p_attribute13
    , p_attribute14             => p_attribute14
    , p_attribute15             => p_attribute15
    , p_context                 => p_context
    , p_note_type               => p_note_type
    , p_jtf_note_contexts_tab   => p_jtf_note_contexts_tab
    , x_return_status           => l_return_status
    );

    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS)
    THEN
      FND_MESSAGE.Set_Name('JTF', 'JTF_API_ERR_PRE_CUST_USR_HK');
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
  END IF;

  -- Pre call to the Vertical Type User Hook
  --
  IF jtf_usr_hks.ok_to_execute('JTF_NOTES_PUB'
                              ,'Create_Note'
                              ,'B'
                              ,'V'
                              )
  THEN
    jtf_notes_vuhk.create_note_pre
    ( p_parent_note_id          => p_parent_note_id
    , p_api_version             => p_api_version
    , p_init_msg_list           => p_init_msg_list
    , p_commit                  => FND_API.G_FALSE
    , p_validation_level        => p_validation_level
    , x_msg_count               => l_msg_count
    , x_msg_data                => l_msg_data
    , p_org_id                  => p_org_id
    , p_source_object_id        => p_source_object_id
    , p_source_object_code      => p_source_object_code
    , p_notes                   => p_notes
    , p_notes_detail            => p_notes_detail
    , p_note_status             => p_note_status
    , p_entered_by              => p_entered_by
    , p_entered_date            => p_entered_date
    , x_jtf_note_id             => x_jtf_note_id
    , p_last_update_date        => p_last_update_date
    , p_last_updated_by         => p_last_updated_by
    , p_creation_date           => p_creation_date
    , p_created_by              => p_created_by
    , p_last_update_login       => p_last_update_login
    , p_attribute1              => p_attribute1
    , p_attribute2              => p_attribute2
    , p_attribute3              => p_attribute3
    , p_attribute4              => p_attribute4
    , p_attribute5              => p_attribute5
    , p_attribute6              => p_attribute6
    , p_attribute7              => p_attribute7
    , p_attribute8              => p_attribute8
    , p_attribute9              => p_attribute9
    , p_attribute10             => p_attribute10
    , p_attribute11             => p_attribute11
    , p_attribute12             => p_attribute12
    , p_attribute13             => p_attribute13
    , p_attribute14             => p_attribute14
    , p_attribute15             => p_attribute15
    , p_context                 => p_context
    , p_note_type               => p_note_type
    , p_jtf_note_contexts_tab   => p_jtf_note_contexts_tab
    , x_return_status           => l_return_status
    );

    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS)
    THEN
      FND_MESSAGE.Set_Name('JTF', 'JTF_API_ERR_PRE_VERT_USR_HK');
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
  END IF;


  -- Item level validation
  IF (p_validation_level > fnd_api.g_valid_level_none)
  THEN
    --
    -- Check if the note id passed is unique
    --
    BEGIN
      IF (  (l_jtf_note_id IS NOT NULL)
         OR (l_jtf_note_id <> FND_API.G_MISS_NUM)
         )
      THEN
        SELECT jtf_note_id
        INTO l_jtf_note_id
        FROM jtf_notes_b
        WHERE jtf_note_id = p_jtf_note_id;

        --Exit if another note exists and the calling page is Notes JSP
        IF (p_validation_level = 0.5)
        THEN
           x_jtf_note_id := l_jtf_note_id;
           RAISE l_duplicate_note;
        ELSE
           Add_Invalid_Argument_Msg( p_token_an =>  l_api_name_full
                                   , p_token_v  =>  p_jtf_note_id
                                   , p_token_p  =>  'p_jtf_note_id'
                                   );
           RAISE FND_API.G_EXC_ERROR;
        END IF;
      END IF;
    EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
        NULL;
      WHEN l_duplicate_note
      THEN
        RAISE l_duplicate_note;
      WHEN OTHERS
      THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END;

    -- If mobile passes ID they should never clash with the sequence
    IF (  (l_jtf_note_id IS NOT NULL)
       OR (l_jtf_note_id <> FND_API.G_MISS_NUM)
       )
       AND (p_validation_level <> 0.5) -- JSP pages will be able to override
                                       -- this check so we can avoid the refresh problem
       AND (NVL(FND_PROFILE.Value('APPS_MAINTENANCE_MODE'),'X') <> 'FUZZY')
                                       -- For HA, if the API is called in Replay mode
                                       -- then don't restrict jtf_note_id
    THEN
      IF (p_jtf_note_id  < 1e+12)
      THEN
        Add_Invalid_Argument_Msg( p_token_an =>  l_api_name_full
                                , p_token_v  =>  p_jtf_note_id
                                , p_token_p  =>  'p_jtf_note_id'
                                );
        RAISE FND_API.G_EXC_ERROR;
      END IF ;
    END IF;

    -- Validate source object id and code against object_type_code
    -- in jtf_object_types_b table
    Validate_object( p_api_name         => l_api_name_full
                   , p_object_type_code => p_source_object_code
                   , p_object_type_id   => p_source_object_id
                   , x_return_status    => l_return_status
                   );

    IF (l_return_status <> fnd_api.g_ret_sts_success)
    THEN
      add_invalid_argument_msg( l_api_name_full
                              , p_source_object_id
                              , 'p_source_object_id'
                              );
      RAISE fnd_api.g_exc_error;
    END IF;

    -- Validate note status
    IF (p_note_status <> fnd_api.g_miss_char)
    THEN
      IF (p_note_status NOT IN ('P', 'I','E'))
      THEN
        add_invalid_argument_msg( l_api_name_full
                                , p_note_status
                                , 'p_note_status'
                                );
        RAISE fnd_api.g_exc_error;
      END IF;
    END IF;

    -- Validate note length
    IF (p_notes IS NOT NULL)
    THEN
      trunc_string_length( l_api_name_full
                         , 'p_notes'
                         ,  p_notes
                         , 2000
                         , l_notes
                         );
      -- Message added in trunc_string_length, no exception..
    END IF;

    --Validate note_Type
    IF (p_note_type IS NOT NULL)
    THEN
      Validate_note_type( p_api_name       =>  l_api_name_full
                        , p_parameter_name =>  'p_note_type'
                        , p_note_type      =>  p_note_type
                        , x_return_status  =>  l_return_status
                        );
      IF (l_return_status <> fnd_api.g_ret_sts_success)
      THEN
          -- Message added in Validate_note_type
          RAISE fnd_api.g_exc_error;
      END IF;

    END IF;

    --Validate entered by
    IF p_entered_by IS NOT NULL
    THEN
      validate_entered_by( p_entered_by    => l_entered_by
                         , x_return_status => l_return_status
                         , x_entered_by    => l_entered_by
                         );
      IF (l_return_status <> fnd_api.g_ret_sts_success)
      THEN
        RAISE fnd_api.g_exc_error;
      END IF;
    END IF;
  END IF;

  -- Defaulting
  IF p_parent_note_id = fnd_api.g_miss_num
  THEN
    l_parent_note_id := NULL;
  ELSE
    l_parent_note_id := p_parent_note_id;
  END IF;
  IF p_entered_date = fnd_api.g_miss_date
  THEN
    l_entered_date := (SYSDATE);
  ELSE
    l_entered_date := p_entered_date;
  END IF;

  IF p_last_update_date = fnd_api.g_miss_date
  THEN
    l_last_update_date := (SYSDATE);
  ELSE
    l_last_update_date := p_last_update_date;
  END IF;

  IF p_creation_date = fnd_api.g_miss_date
  THEN
    l_creation_date := (SYSDATE);
  ELSE
    l_creation_date := p_creation_date;
  END IF;

  IF p_note_status IS NOT NULL
  THEN
     l_note_status := p_note_status;
  ELSE
     l_note_status := 'I'; -- Internal is the default
  END IF;

  --
  -- AOL Security validations
  --
  IF (p_use_AOL_security = fnd_api.g_true)
  THEN
    --
    -- Check if the user is allowed to create notes at all
    --
    JTF_NOTES_SECURITY_PVT.check_function
    ( p_api_version         => 1.0
    , p_init_msg_list       => FND_API.G_FALSE
    , p_function            => JTF_NOTES_SECURITY_PVT.G_FUNCTION_CREATE
    , p_object_name         => JTF_NOTES_SECURITY_PVT.G_OBJECT_NOTE
    , x_grant               => l_grant_select
    , x_return_status       => l_return_status
    , x_msg_count           => l_msg_count
    , x_msg_data            => l_msg_data
    );

    --
    -- If there's an error push it onto the stack
    --
    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS)
    THEN
      FND_MESSAGE.SET_NAME('JTF', 'JTF_UNABLE_TO_CHECK_FUNCTION');  -- Unable to verify whether Security &FUNCTION function was granted
      FND_MESSAGE.SET_TOKEN('FUNCTION', 'JTF_NOTE_CREATE');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    --
    -- If the create function was not granted throw an error
    --
    IF (l_grant_select = 0)
    THEN
      FND_MESSAGE.SET_NAME('JTF', 'JTF_FUNCTION_NOT_GRANTED');  -- Security &FUNCTION function was not granted
      FND_MESSAGE.SET_TOKEN('FUNCTION', 'JTF_NOTE_CREATE');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    --
    -- Function was granted now we'll verify whether user is allowed to create notes of the given type
    --
    JTF_NOTES_SECURITY_PVT.check_note_type
    ( p_api_version     => 1.0
    , p_init_msg_list   => FND_API.G_FALSE
    , p_note_type       => p_note_type
    , x_return_status   => l_return_status
    , x_grant           => l_grant_select_type
    , x_msg_count       => l_msg_count
    , x_msg_data        => l_msg_data
    );

    --
    -- If there's an error push it onto the stack
    --
    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS)
    THEN
      FND_MESSAGE.SET_NAME('JTF', 'JTF_UNABLE_TO_CHECK_FUNCTION');  -- Unable to verify whether Security &FUNCTION function was granted
      FND_MESSAGE.SET_TOKEN('FUNCTION', 'JTF_NOTE_CREATE');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    --
    -- user is not allowed to create notes of this type
    --
    IF (l_grant_select = 0)
    THEN
      FND_MESSAGE.SET_NAME('JTF', 'JTF_FUNCTION_NOT_GRANTED');  -- Security &FUNCTION function was not granted
      FND_MESSAGE.SET_TOKEN('FUNCTION', 'JTF_NOTE_TYPE_CREATE');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

  END IF; -- Security validations

  --
  -- Get jtf_note_id from sequence
  --
  IF (  (l_jtf_note_id IS NULL)
     OR (l_jtf_note_id = FND_API.G_MISS_NUM)
     )
  THEN
    OPEN l_jtf_note_id_csr;
    FETCH l_jtf_note_id_csr INTO l_jtf_note_id;
    CLOSE l_jtf_note_id_csr;
  END IF;

   JTF_NOTES_PKG.INSERT_ROW
   ( x_rowid              => l_rowid
   , x_jtf_note_id        => l_jtf_note_id
   , x_source_object_code => p_source_object_code
   , x_note_status        => l_note_status
   , x_entered_by         => p_entered_by
   , x_entered_date       => l_entered_date
   , x_note_type          => p_note_type
   , x_attribute1         => p_attribute1
   , x_attribute2         => p_attribute2
   , x_attribute3         => p_attribute3
   , x_attribute4         => p_attribute4
   , x_attribute5         => p_attribute5
   , x_attribute6         => p_attribute6
   , x_attribute7         => p_attribute7
   , x_attribute8         => p_attribute8
   , x_attribute9         => p_attribute9
   , x_attribute10        => p_attribute10
   , x_attribute11        => p_attribute11
   , x_attribute12        => p_attribute12
   , x_attribute13        => p_attribute13
   , x_attribute14        => p_attribute14
   , x_attribute15        => p_attribute15
   , x_context            => p_context
   , x_parent_note_id     => l_parent_note_id
   , x_source_object_id   => p_source_object_id
   , x_notes              => l_notes
   , x_notes_detail       => p_notes_detail
   , x_creation_date      => l_creation_date
   , x_created_by         => p_created_by
   , x_last_update_date   => l_last_update_date
   , x_last_updated_by    => p_last_updated_by
   , x_last_update_login  => p_last_update_login
   );

   -- Retrieve from the table to verify insertion
   OPEN l_insert_check_csr;
   FETCH l_insert_check_csr INTO l_dummy;
   IF (l_insert_check_csr%notfound)
   THEN
     CLOSE l_insert_check_csr;
     RAISE l_insert_failure;
   END IF;
   CLOSE l_insert_check_csr;

   -- Insert the contexts
   IF ( p_jtf_note_contexts_tab.COUNT > 0 )
   THEN
     FOR i IN 1..p_jtf_note_contexts_tab.COUNT
     LOOP
       create_note_context
       ( p_validation_level     => p_validation_level
       , x_return_status        => l_return_status
       , p_jtf_note_id          => l_jtf_note_id
       , p_last_update_date     => p_jtf_note_contexts_tab(i).last_update_date
       , p_last_updated_by      => p_jtf_note_contexts_tab(i).last_updated_by
       , p_creation_date        => p_jtf_note_contexts_tab(i).creation_date
       , p_created_by           => p_jtf_note_contexts_tab(i).created_by
       , p_last_update_login    => p_jtf_note_contexts_tab(i).last_update_login
       , p_note_context_type_id => p_jtf_note_contexts_tab(i).note_context_type_id
       , p_note_context_type    => p_jtf_note_contexts_tab(i).note_context_type
       , x_note_context_id      => l_note_context_id
       );
       IF (l_return_status <> fnd_api.g_ret_sts_success)
       THEN
         RAISE fnd_api.g_exc_error;
         EXIT;
       END IF;
     END LOOP;
   END IF;
   --
   -- Make the post processing call to the user hooks
   --
   -- Post call to the Customer Type User Hook
   --
   IF jtf_usr_hks.ok_to_execute( 'JTF_NOTES_PUB'
                               , 'Create_Note'
                               , 'A'
                               , 'C'
                               )
   THEN
     jtf_notes_cuhk.create_note_post
     ( p_parent_note_id          => l_parent_note_id
     , p_api_version             => p_api_version
     , p_init_msg_list           => p_init_msg_list
     , p_commit                  => FND_API.G_FALSE
     , p_validation_level        => p_validation_level
     , x_msg_count               => x_msg_count
     , x_msg_data                => x_msg_data
     , p_org_id                  => p_org_id
     , p_source_object_id        => p_source_object_id
     , p_source_object_code      => p_source_object_code
     , p_notes                   => l_notes
     , p_notes_detail            => p_notes_detail
     , p_note_status             => l_note_status
     , p_entered_by              => p_entered_by
     , p_entered_date            => p_entered_date
     , x_jtf_note_id             => x_jtf_note_id
     , p_last_update_date        => l_last_update_date
     , p_last_updated_by         => p_last_updated_by
     , p_creation_date           => l_creation_date
     , p_created_by              => p_created_by
     , p_last_update_login       => p_last_update_login
     , p_attribute1              => p_attribute1
     , p_attribute2              => p_attribute2
     , p_attribute3              => p_attribute3
     , p_attribute4              => p_attribute4
     , p_attribute5              => p_attribute5
     , p_attribute6              => p_attribute6
     , p_attribute7              => p_attribute7
     , p_attribute8              => p_attribute8
     , p_attribute9              => p_attribute9
     , p_attribute10             => p_attribute10
     , p_attribute11             => p_attribute11
     , p_attribute12             => p_attribute12
     , p_attribute13             => p_attribute13
     , p_attribute14             => p_attribute14
     , p_attribute15             => p_attribute15
     , p_context                 => p_context
     , p_note_type               => p_note_type
     , p_jtf_note_contexts_tab   => p_jtf_note_contexts_tab
     , x_return_status           => l_return_status
     , p_jtf_note_id             => l_jtf_note_id
     );

     IF (l_return_status <> FND_API.G_RET_STS_SUCCESS)
     THEN
       FND_MESSAGE.Set_Name('JTF', 'JTF_API_ERR_POST_CUST_USR_HK');
       FND_MSG_PUB.Add;
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;
   END IF;


   -- Post call to the Vertical Type User Hook
   --
   IF jtf_usr_hks.ok_to_execute('JTF_NOTES_PUB'
                               ,'Create_Note'
                               ,'A'
                               ,'V'
                               )
   THEN
     jtf_notes_vuhk.create_note_post
     ( p_parent_note_id          => l_parent_note_id
     , p_api_version             => p_api_version
     , p_init_msg_list           => p_init_msg_list
     , p_commit                  => FND_API.G_FALSE
     , p_validation_level        => p_validation_level
     , x_msg_count               => x_msg_count
     , x_msg_data                => x_msg_data
     , p_org_id                  => p_org_id
     , p_source_object_id        => p_source_object_id
     , p_source_object_code      => p_source_object_code
     , p_notes                   => l_notes
     , p_notes_detail            => p_notes_detail
     , p_note_status             => l_note_status
     , p_entered_by              => p_entered_by
     , p_entered_date            => p_entered_date
     , x_jtf_note_id             => x_jtf_note_id
     , p_last_update_date        => l_last_update_date
     , p_last_updated_by         => p_last_updated_by
     , p_creation_date           => l_creation_date
     , p_created_by              => p_created_by
     , p_last_update_login       => p_last_update_login
     , p_attribute1              => p_attribute1
     , p_attribute2              => p_attribute2
     , p_attribute3              => p_attribute3
     , p_attribute4              => p_attribute4
     , p_attribute5              => p_attribute5
     , p_attribute6              => p_attribute6
     , p_attribute7              => p_attribute7
     , p_attribute8              => p_attribute8
     , p_attribute9              => p_attribute9
     , p_attribute10             => p_attribute10
     , p_attribute11             => p_attribute11
     , p_attribute12             => p_attribute12
     , p_attribute13             => p_attribute13
     , p_attribute14             => p_attribute14
     , p_attribute15             => p_attribute15
     , p_context                 => p_context
     , p_note_type               => p_note_type
     , p_jtf_note_contexts_tab   => p_jtf_note_contexts_tab
     , x_return_status           => l_return_status
     , p_jtf_note_id             => l_jtf_note_id
     );

    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      FND_MESSAGE.Set_Name('JTF', 'JTF_ERR_POST_VERT_USR_HK');
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
  END IF;

  -- Standard call for message generation
  IF jtf_usr_hks.ok_to_execute( 'JTF_NOTES_PUB'
                              , 'Create_Note'
                              , 'M'
                              , 'M'
                              )
  THEN
    IF jtf_notes_cuhk.Ok_to_generate_msg
       ( p_parent_note_id     => p_parent_note_id
       , p_api_version        => p_api_version
       , x_msg_count          => x_msg_count
       , x_msg_data           => x_msg_data
       , p_source_object_id   => p_source_object_id
       , p_source_object_code => p_source_object_code
       , p_notes              => p_notes
       , p_entered_by         => p_entered_by
       , p_entered_date       => p_entered_date
       , x_jtf_note_id        => x_jtf_note_id
       , p_last_update_date   => p_last_update_date
       , p_last_updated_by    => p_last_updated_by
       , p_creation_date      => p_creation_date
       )
    THEN
      l_bind_data_id := JTF_USR_HKS.Get_bind_data_id;
      JTF_USR_HKS.Load_bind_data( l_bind_data_id
                                , 'jtf_note_id'
                                , l_jtf_note_id
                                , 'S'
                                , 'N'
                                );

      JTF_USR_HKS.generate_message( p_prod_code    => 'JTF'
                                  , p_bus_obj_code => 'NOTES'
                                  , p_action_code  => 'I'
                                  , p_bind_data_id => l_bind_data_id
                                  , x_return_code  => l_return_status
                                  );
      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS)
      THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
    END IF;
  END IF;


  JTF_NOTES_EVENTS_PVT.RaiseCreateNote
  ( p_NoteID            => l_jtf_note_id
  , p_SourceObjectCode  => p_source_object_code
  , p_SourceObjectID    => p_source_object_id
  );

  IF fnd_api.to_boolean(p_commit)
  THEN
    COMMIT WORK;
  END IF;

  fnd_msg_pub.count_and_get( p_encoded => 'F'
                           , p_count   => x_msg_count
                           , p_data    => x_msg_data
                           );

  x_jtf_note_id := l_jtf_note_id;

EXCEPTION
   WHEN l_duplicate_note
   THEN
     -- User hit 'Refresh' button, pretend it never happend and all is well
     ROLLBACK TO create_note_pvt;
     x_return_status := fnd_api.g_ret_sts_success;

   WHEN l_missing_parameter
   THEN
      -- A required parameter is missing
      ROLLBACK TO create_note_pvt;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
      THEN
        fnd_message.set_name('JTF', 'JTF_API_ALL_MISSING_PARAM');
        fnd_message.set_token('API_NAME', g_pkg_name||'.'||l_api_name);
        fnd_message.set_token('MISSING_PARAM', l_missing_param);
        fnd_msg_pub.ADD;
      END IF;

      fnd_msg_pub.count_and_get( p_encoded => 'F' -- Not encoding so HTML can use the message
                               , p_count   => x_msg_count
                               , p_data    => x_msg_data
                               );

   WHEN l_null_parameter
   THEN
     -- A required field is NULL
     ROLLBACK TO create_note_pvt;
     x_return_status := fnd_api.g_ret_sts_unexp_error;
     IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
     THEN
       fnd_message.set_name('JTF', 'JTF_API_ALL_NULL_PARAMETER');
       fnd_message.set_token('API_NAME', g_pkg_name||'.'||l_api_name);
       fnd_message.set_token('NULL_PARAM', l_null_param);
       fnd_msg_pub.ADD;
     END IF;
     fnd_msg_pub.count_and_get( p_encoded => 'F'
                              , p_count   => x_msg_count
                              , p_data    => x_msg_data
                              );

   WHEN fnd_api.g_exc_error
   THEN
     ROLLBACK TO create_note_pvt;
     x_return_status := fnd_api.g_ret_sts_error;
     fnd_msg_pub.count_and_get( p_encoded => 'F'
                              , p_count   => x_msg_count
                              , p_data    => x_msg_data
                              );

   WHEN fnd_api.g_exc_unexpected_error
   THEN
      ROLLBACK TO create_note_pvt;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get( p_encoded => 'F'
                               , p_count   => x_msg_count
                               , p_data    => x_msg_data
                               );

   WHEN OTHERS
   THEN
     ROLLBACK TO create_note_pvt;
     x_return_status := fnd_api.g_ret_sts_unexp_error;
     IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
     THEN
       fnd_msg_pub.add_exc_msg( g_pkg_name
                              , l_api_name
                              );
     END IF;
     fnd_msg_pub.count_and_get( p_encoded => 'F'
                              , p_count   => x_msg_count
                              , p_data    => x_msg_data
                              );
END Secure_Create_note;


PROCEDURE Secure_Update_note
------------------------------------------------------------------------------
-- Update_note
--   Updates a note record in the JTF_NOTES table
------------------------------------------------------------------------------
( p_api_version           IN            NUMBER
, p_init_msg_list         IN            VARCHAR2 DEFAULT 'F'
, p_commit                IN            VARCHAR2 DEFAULT 'F'
, p_validation_level      IN            NUMBER   DEFAULT 100
, x_return_status            OUT NOCOPY VARCHAR2
, x_msg_count                OUT NOCOPY NUMBER
, x_msg_data                 OUT NOCOPY VARCHAR2
, p_jtf_note_id           IN            NUMBER
, p_entered_by            IN            NUMBER   DEFAULT fnd_global.user_id
, p_last_updated_by       IN            NUMBER
, p_last_update_date      IN            DATE     DEFAULT SYSDATE
, p_last_update_login     IN            NUMBER   DEFAULT NULL
, p_notes                 IN            VARCHAR2 DEFAULT CHR(0)
, p_notes_detail          IN            VARCHAR2 DEFAULT CHR(0)
, p_append_flag           IN            VARCHAR2 DEFAULT CHR(0)
, p_note_status           IN            VARCHAR2 DEFAULT 'I'
, p_note_type             IN            VARCHAR2 DEFAULT CHR(0)
, p_jtf_note_contexts_tab IN            jtf_note_contexts_tbl_type
                                          DEFAULT jtf_note_contexts_tab_dflt
, p_attribute1            IN            VARCHAR2 DEFAULT CHR(0)
, p_attribute2            IN            VARCHAR2 DEFAULT CHR(0)
, p_attribute3            IN            VARCHAR2 DEFAULT CHR(0)
, p_attribute4            IN            VARCHAR2 DEFAULT CHR(0)
, p_attribute5            IN            VARCHAR2 DEFAULT CHR(0)
, p_attribute6            IN            VARCHAR2 DEFAULT CHR(0)
, p_attribute7            IN            VARCHAR2 DEFAULT CHR(0)
, p_attribute8            IN            VARCHAR2 DEFAULT CHR(0)
, p_attribute9            IN            VARCHAR2 DEFAULT CHR(0)
, p_attribute10           IN            VARCHAR2 DEFAULT CHR(0)
, p_attribute11           IN            VARCHAR2 DEFAULT CHR(0)
, p_attribute12           IN            VARCHAR2 DEFAULT CHR(0)
, p_attribute13           IN            VARCHAR2 DEFAULT CHR(0)
, p_attribute14           IN            VARCHAR2 DEFAULT CHR(0)
, p_attribute15           IN            VARCHAR2 DEFAULT CHR(0)
, p_context               IN            VARCHAR2 DEFAULT CHR(0)
, p_use_AOL_security      IN            VARCHAR2 DEFAULT 'T'
)
IS
  l_api_name        CONSTANT VARCHAR2(30)   := 'Secure_Update_note';
  l_api_version     CONSTANT NUMBER         := 1.0;
  l_api_name_full   CONSTANT VARCHAR2(61)   := g_pkg_name||'.'||l_api_name;
  l_return_status            VARCHAR2(1);
--substrb added for bug 4227634 by abraina
  l_notes                    VARCHAR2(2000) := substrb(p_notes,1,2000);
  l_notes_detail             VARCHAR2(32767):= p_notes_detail;
  l_notes_detail_old         VARCHAR2(32767);
  l_note_status              VARCHAR2(1)    := p_note_status;
  l_note_type                VARCHAR2(30)   := p_note_type;
  l_msg_count                NUMBER;
  l_msg_data                 VARCHAR2(2000);
  l_last_updated_by          NUMBER;
  l_last_update_login        NUMBER;
  l_last_update_date         DATE;
  l_entered_by               NUMBER         := p_entered_by;
  l_bind_data_id             NUMBER;
  l_new_clob_length          NUMBER;
  l_old_clob_length          NUMBER;
  l_total_clob_length        NUMBER;
  l_notes_detail_truncated   VARCHAR2(32767);
  l_append_flag              VARCHAR2(1) := 'N';
  l_attribute1               VARCHAR2(150);
  l_attribute2               VARCHAR2(150);
  l_attribute3               VARCHAR2(150);
  l_attribute4               VARCHAR2(150);
  l_attribute5               VARCHAR2(150);
  l_attribute6               VARCHAR2(150);
  l_attribute7               VARCHAR2(150);
  l_attribute8               VARCHAR2(150);
  l_attribute9               VARCHAR2(150);
  l_attribute10              VARCHAR2(150);
  l_attribute11              VARCHAR2(150);
  l_attribute12              VARCHAR2(150);
  l_attribute13              VARCHAR2(150);
  l_attribute14              VARCHAR2(150);
  l_attribute15              VARCHAR2(150);
  l_context                  VARCHAR2(30);
  l_note_update_primary      NUMBER;
  l_note_update_secondary    NUMBER;
  l_note_select_type         NUMBER;

  CURSOR l_com_csr
  IS  SELECT *
      FROM JTF_NOTES_B
      WHERE jtf_note_id = p_jtf_note_id
      FOR UPDATE OF jtf_note_id NOWAIT;

  CURSOR l_tl_csr
  IS SELECT *
     FROM JTF_NOTES_TL
     WHERE JTF_NOTE_ID = p_JTF_NOTE_ID
     AND USERENV('LANG') = LANGUAGE;

  l_com_rec    l_com_csr%ROWTYPE;
  l_tl_rec     l_tl_csr%ROWTYPE;

  e_resource_busy EXCEPTION;
  PRAGMA EXCEPTION_INIT(e_resource_busy, -54);


BEGIN
  --
  -- Standard start of API savepoint
  --
  SAVEPOINT update_note_pvt;

  --
  -- Standard call to check for call compatibility
  --
  IF NOT fnd_api.compatible_api_call( l_api_version
                                    , p_api_version
                                    , l_api_name, g_pkg_name
                                    )
  THEN
    RAISE fnd_api.g_exc_unexpected_error;
  END IF;

  --
  -- Initialize message list if p_init_msg_list is set to TRUE
  --
  IF fnd_api.to_boolean(p_init_msg_list)
  THEN
     fnd_msg_pub.initialize;
  END IF;

  --
  -- Initialize API return status to success
  --
  x_return_status := fnd_api.g_ret_sts_success;

  --
  -- Fetch the original values for defaulting/comparison
  --
  OPEN l_com_csr; -- _B table

  FETCH l_com_csr INTO l_com_rec;

  IF (l_com_csr%NOTFOUND)
  THEN
    add_invalid_argument_msg( l_api_name_full
                            , p_jtf_note_id
                            , 'p_jtf_note_id'
                            );
    RAISE fnd_api.g_exc_error;
  END IF;

  OPEN l_tl_csr; -- _TL table

  FETCH l_tl_csr INTO l_tl_rec;

  IF (l_tl_csr%NOTFOUND)
  THEN
    add_invalid_argument_msg( l_api_name_full
                            , p_jtf_note_id
                            , 'p_jtf_note_id'
                            );
    RAISE fnd_api.g_exc_error;
  END IF;

  --
  -- Defaulting values that are missing
  --
  IF (p_notes = fnd_api.g_miss_char)
  THEN
--substrb added for bug 4227634 by abraina
    l_notes := substrb(l_tl_rec.notes,1,2000);
  ELSE
    l_notes := substrb(p_notes,1,2000);
  END IF;
  --
  IF (p_note_status = fnd_api.g_miss_char)
  THEN
    l_note_status := l_com_rec.note_status;
  ELSE
    l_note_status := p_note_status;
  END IF;
  --
  IF (p_note_type = fnd_api.g_miss_char)
  THEN
    l_note_type   := l_com_rec.note_type;
  ELSE
    l_note_type := p_note_type;
  END IF;
  --
  IF p_last_update_date = fnd_api.g_miss_date
  THEN
    l_last_update_date := SYSDATE;
  ELSE
    l_last_update_date := p_last_update_date;
  END IF;
  --
  IF p_last_updated_by = fnd_api.g_miss_num
  THEN
    l_last_updated_by := FND_GLOBAL.USER_ID;
  ELSE
    l_last_updated_by := p_last_updated_by;
  END IF;
  --
  IF p_last_update_login = fnd_api.g_miss_num
  THEN
    l_last_update_login := FND_GLOBAL.USER_ID;
  ELSE
    l_last_update_login := p_last_update_login;
  END IF;
  --
  IF (p_append_flag = 'Y')
  THEN
    l_append_flag := 'Y';
  ELSE
    l_append_flag := 'N';
  END IF;
  --
  IF (p_attribute1 = fnd_api.g_miss_char)
  THEN
    l_attribute1 := l_com_rec.attribute1;
  ELSE
    l_attribute1 := p_attribute1;
  END IF;
  --
  IF (p_attribute2 = fnd_api.g_miss_char)
  THEN
    l_attribute2 := l_com_rec.attribute2;
  ELSE
    l_attribute2 := p_attribute2;
  END IF;
  --
  IF (p_attribute3 = fnd_api.g_miss_char)
  THEN
    l_attribute3 := l_com_rec.attribute3;
  ELSE
    l_attribute3 := p_attribute3;
  END IF;
  --
  IF (p_attribute4 = fnd_api.g_miss_char)
  THEN
    l_attribute4 := l_com_rec.attribute4;
  ELSE
    l_attribute4 := p_attribute4;
  END IF;
  --
  IF (p_attribute5 = fnd_api.g_miss_char)
  THEN
    l_attribute5 := l_com_rec.attribute5;
  ELSE
    l_attribute5 := p_attribute5;
  END IF;
  --
  IF (p_attribute6 = fnd_api.g_miss_char)
  THEN
    l_attribute6 := l_com_rec.attribute6;
  ELSE
    l_attribute6 := p_attribute6;
  END IF;
  --
  IF (p_attribute7 = fnd_api.g_miss_char)
  THEN
    l_attribute7 := l_com_rec.attribute7;
  ELSE
    l_attribute7 := p_attribute7;
  END IF;
  --
  IF (p_attribute8 = fnd_api.g_miss_char)
  THEN
    l_attribute8 := l_com_rec.attribute8;
  ELSE
    l_attribute8 := p_attribute8;
  END IF;
  --
  IF (p_attribute9 = fnd_api.g_miss_char)
  THEN
    l_attribute9 := l_com_rec.attribute9;
  ELSE
    l_attribute9 := p_attribute9;
  END IF;
  --
  IF (p_attribute10 = fnd_api.g_miss_char)
  THEN
    l_attribute10 := l_com_rec.attribute10;
  ELSE
    l_attribute10 := p_attribute10;
  END IF;
  --
  IF (p_attribute11 = fnd_api.g_miss_char)
  THEN
    l_attribute11 := l_com_rec.attribute11;
  ELSE
    l_attribute11 := p_attribute11;
  END IF;
  --
  IF (p_attribute12 = fnd_api.g_miss_char)
  THEN
    l_attribute12 := l_com_rec.attribute12;
  ELSE
    l_attribute12 := p_attribute12;
  END IF;
  --
  IF (p_attribute13 = fnd_api.g_miss_char)
  THEN
    l_attribute13 := l_com_rec.attribute13;
  ELSE
    l_attribute13 := p_attribute13;
  END IF;
  --
  IF (p_attribute14 = fnd_api.g_miss_char)
  THEN
    l_attribute14 := l_com_rec.attribute14;
  ELSE
    l_attribute14 := p_attribute14;
  END IF;
  --
  IF (p_attribute15 = fnd_api.g_miss_char)
  THEN
    l_attribute15 := l_com_rec.attribute15;
  ELSE
    l_attribute15 := p_attribute15;
  END IF;
  --
  IF (p_context = fnd_api.g_miss_char)
  THEN
    l_context := l_com_rec.context;
  ELSE
    l_context := p_context;
  END IF;
  --
  -- Defaulting the Note and Note details
  --
  writelobtoData(l_tl_rec.jtf_note_id,l_notes_detail_old);   -- Copy the CLOB into a VARCHAR2 so we can use it
  --
  IF (p_notes_detail = fnd_api.g_miss_char)
  THEN
    -- use existing value, copy to local so we can append if nesecary
    l_notes_detail := l_notes_detail_old;
  ELSIF (p_notes_detail IS NULL )
  THEN
    l_notes_detail := NULL;
  ELSE
    l_notes_detail := p_notes_detail;
  END IF;
  --
  -- Append if needed..
  --
  IF ( l_append_flag = 'Y')
  THEN

    writelobtodata(p_jtf_note_id,l_notes_detail);

    l_old_clob_length   := LENGTHB(l_notes_detail);
    l_new_clob_length   := LENGTHB(p_notes_detail);
    l_total_clob_length := l_old_clob_length + l_new_clob_length;

    IF (l_total_clob_length > 32766) -- 32367 minus 1 since we'll append a space
    THEN
      -- we'll need to truncate before we append
      l_notes_detail_truncated := substrb( l_notes_detail
                                        , 1
                                        , (32766 - l_old_clob_length)
                                        );-- 32367

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_success)
      THEN
        fnd_message.set_name('JTF', 'JTF_API_ALL_VALUE_TRUNCATED');
        fnd_message.set_token('API_NAME', l_api_name);
        fnd_message.set_token('TRUNCATED_PARAM', 'p_notes_detail');
        fnd_message.set_token('VAL_LEN', l_total_clob_length);
        fnd_message.set_token('DB_LEN', 32767);
        fnd_msg_pub.add;
      END IF;

      IF l_notes_detail_truncated IS NOT NULL
      THEN

        l_notes_detail := l_notes_detail||' '||l_notes_detail_truncated;
      END IF;
    ELSE
      l_notes_detail := p_notes_detail||' '||l_notes_detail;
    END IF;
  END IF;

  --
  -- Customer User Hook pre update
  --
  IF jtf_usr_hks.ok_to_execute( 'JTF_NOTES_PUB'
                              , 'Update Note'
                              , 'B'
                              , 'C'
                              )
  THEN
    jtf_notes_cuhk.update_note_pre
                  ( p_api_version     => l_api_version
                  , x_msg_count       => l_msg_count
                  , x_msg_data        => l_msg_data
                  , p_jtf_note_id     => p_jtf_note_id
                  , p_entered_by      => l_entered_by
                  , p_last_updated_by => p_last_updated_by
                  , p_notes           => l_notes
                  , p_notes_detail    => l_notes_detail
                  , p_append_flag     => p_append_flag
                  , p_note_status     => l_note_status
                  , p_note_type       => l_note_type
                  , x_return_status   => l_return_status
                  );

    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS)
    THEN
      FND_MESSAGE.Set_Name('JTF', 'JTF_API_ERR_PRE_CUST_USR_HK');
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
  END IF;

  IF jtf_usr_hks.ok_to_execute( 'JTF_NOTES_PUB'
                              , 'Update Note'
                              , 'B'
                              , 'V'
                              )
  THEN
    jtf_notes_vuhk.update_note_pre
                  ( p_api_version     => l_api_version
                  , x_msg_count       => l_msg_count
                  , x_msg_data        => l_msg_data
                  , p_jtf_note_id     => p_jtf_note_id
                  , p_entered_by      => l_entered_by
                  , p_last_updated_by => p_last_updated_by
                  , p_notes           => l_notes
                  , p_notes_detail    => l_notes_detail
                  , p_append_flag     => p_append_flag
                  , p_note_status     => l_note_status
                  , p_note_type       => l_note_type
                  , x_return_status   => l_return_status
                  );

    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS)
    THEN
      FND_MESSAGE.Set_Name('JTF', 'JTF_API_ERR_PRE_CUST_USR_HK');
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
  END IF;

  IF (p_validation_level > fnd_api.g_valid_level_none)
  THEN
    -- Validate notes
    IF (p_notes IS NULL)
    THEN
      add_null_parameter_msg(l_api_name_full, 'p_notes');
      RAISE fnd_api.g_exc_error;
    END IF;

    -- Validate note status
    IF (p_note_status <> fnd_api.g_miss_char)
    THEN
      IF (p_note_status NOT IN ('P', 'I','E'))
      THEN
        add_invalid_argument_msg( l_api_name_full
                                , p_note_status
                                , 'p_note_status'
                                );
        RAISE fnd_api.g_exc_error;
      END IF;
    END IF;

    --Validate note_type
    IF l_note_type IS NOT NULL
    THEN
      Validate_note_type( p_api_name       =>  l_api_name_full
                        , p_parameter_name =>  'p_note_type'
                        , p_note_type      =>  l_note_type
                        , x_return_status  =>  l_return_status
                        );

      IF (l_return_status <> fnd_api.g_ret_sts_success)
      THEN
        RAISE fnd_api.g_exc_error;
      END IF;
    END IF;
  END IF;
  --
  -- AOL Security validations
  --
  IF (p_use_AOL_security = fnd_api.g_true)
  THEN
    --
    -- Check if the note is being updated
    --
    IF (l_notes        <> l_tl_rec.notes)
    THEN
      --
      -- Check if the user is allowed to update note text for this note
      --
      JTF_NOTES_SECURITY_PVT.check_function
      ( p_api_version         => 1.0
      , p_init_msg_list       => FND_API.G_FALSE
      , p_function            => JTF_NOTES_SECURITY_PVT.G_FUNCTION_UPDATE_NOTE
      , p_object_name         => JTF_NOTES_SECURITY_PVT.G_OBJECT_NOTE
      , p_instance_pk1_value  => p_jtf_note_id
      , x_grant               => l_note_update_primary
      , x_return_status       => l_return_status
      , x_msg_count           => l_msg_count
      , x_msg_data            => l_msg_data
      );

      --
      -- If there's an error push it onto the stack
      --
      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS)
      THEN
        FND_MESSAGE.SET_NAME('JTF', 'JTF_UNABLE_TO_CHECK_FUNCTION');  -- Unable to verify whether Security &FUNCTION function was granted
        FND_MESSAGE.SET_TOKEN('FUNCTION', 'JTF_NOTE_UPDATE_NOTE');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      --
      -- If the create function was not granted throw an error
      --
      IF (l_note_update_primary = 0)
      THEN
        FND_MESSAGE.SET_NAME('JTF', 'JTF_FUNCTION_NOT_GRANTED');  -- Security &FUNCTION function was not granted
        FND_MESSAGE.SET_TOKEN('FUNCTION', 'JTF_NOTE_UPDATE_NOTE');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
    END IF;

    --
    -- Check if the note detail is being updated
    --
    IF (l_notes_detail <> l_notes_detail_old)
    THEN
      --
      -- Check if the user is allowed to update note details for this note
      --
      JTF_NOTES_SECURITY_PVT.check_function
      ( p_api_version         => 1.0
      , p_init_msg_list       => FND_API.G_FALSE
      , p_function            => JTF_NOTES_SECURITY_PVT.G_FUNCTION_UPDATE_NOTE_DTLS
      , p_object_name         => JTF_NOTES_SECURITY_PVT.G_OBJECT_NOTE
      , p_instance_pk1_value  => p_jtf_note_id
      , x_grant               => l_note_update_primary
      , x_return_status       => l_return_status
      , x_msg_count           => l_msg_count
      , x_msg_data            => l_msg_data
      );

      --
      -- If there's an error push it onto the stack
      --
      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS)
      THEN
        FND_MESSAGE.SET_NAME('JTF', 'JTF_UNABLE_TO_CHECK_FUNCTION');  -- Unable to verify whether Security &FUNCTION function was granted
        FND_MESSAGE.SET_TOKEN('FUNCTION', 'JTF_NOTE_UPDATE_NOTE_DETAILS');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      --
      -- If the create function was not granted throw an error
      --
      IF (l_note_update_primary = 0)
      THEN
        FND_MESSAGE.SET_NAME('JTF', 'JTF_FUNCTION_NOT_GRANTED');  -- Security &FUNCTION function was not granted
        FND_MESSAGE.SET_TOKEN('FUNCTION', 'JTF_NOTE_UPDATE_NOTE_DETAILS');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
    END IF;

    --
    -- Check if any of the secondary attributes are beeing updated
    --
    IF  (  (l_note_status       <> l_com_rec.note_status)
        OR (l_note_type         <> l_com_rec.note_type)
        OR (l_entered_by        <> l_com_rec.entered_by)
        )
    THEN
      --
      -- Check if the user is allowed to update primary attributes for this note
      --
      JTF_NOTES_SECURITY_PVT.check_function
      ( p_api_version         => 1.0
      , p_init_msg_list       => FND_API.G_FALSE
      , p_function            => JTF_NOTES_SECURITY_PVT.G_FUNCTION_UPDATE_SEC
      , p_object_name         => JTF_NOTES_SECURITY_PVT.G_OBJECT_NOTE
      , p_instance_pk1_value  => p_jtf_note_id
      , x_grant               => l_note_update_secondary
      , x_return_status       => l_return_status
      , x_msg_count           => l_msg_count
      , x_msg_data            => l_msg_data
      );

      --
      -- If there's an error push it onto the stack
      --
      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS)
      THEN
        FND_MESSAGE.SET_NAME('JTF', 'JTF_UNABLE_TO_CHECK_FUNCTION');  -- Unable to verify whether Security &FUNCTION function was granted
        FND_MESSAGE.SET_TOKEN('FUNCTION', 'JTF_NOTE_UPDATE');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      --
      -- If the create function was not granted throw an error
      --
      IF (l_note_update_secondary = 0)
      THEN
        FND_MESSAGE.SET_NAME('JTF', 'JTF_FUNCTION_NOT_GRANTED');  -- Security &FUNCTION function was not granted
        FND_MESSAGE.SET_TOKEN('FUNCTION', 'JTF_NOTE_UPDATE_PRIMARY');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSE
        --
        -- Function was granted now we'll verify whether user is allowed to create notes of the given type
        --
        JTF_NOTES_SECURITY_PVT.check_note_type
        ( p_api_version     => 1.0
        , p_init_msg_list   => FND_API.G_FALSE
        , p_note_type       => p_note_type
        , x_return_status   => l_return_status
        , x_grant           => l_note_select_type
        , x_msg_count       => l_msg_count
        , x_msg_data        => l_msg_data
        );

        --
        -- If there's an error push it onto the stack
        --
        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS)
        THEN
          FND_MESSAGE.SET_NAME('JTF', 'JTF_UNABLE_TO_CHECK_FUNCTION');  -- Unable to verify whether Security &FUNCTION function was granted
          FND_MESSAGE.SET_TOKEN('FUNCTION', 'JTF_NOTE_UPDATE');
          FND_MSG_PUB.ADD;
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        --
        -- user is not allowed to create notes of this type
        --
        IF (l_note_select_type = 0)
        THEN
          FND_MESSAGE.SET_NAME('JTF', 'JTF_FUNCTION_NOT_GRANTED');  -- Security &FUNCTION function was not granted
          FND_MESSAGE.SET_TOKEN('FUNCTION', 'JTF_NOTE_TYPE_UPDATE');
          FND_MSG_PUB.ADD;
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
      END IF;
    END IF;
  END IF; -- end of Security validations

  --
  -- Perform the database operation.
  --
  UPDATE JTF_NOTES_B
  SET last_updated_by   = l_last_updated_by
  ,   last_update_date  = l_last_update_date
  ,   last_update_login = l_last_update_login
  ,   note_status       = l_note_status
  ,   note_type         = l_note_type
  ,   attribute1        = l_attribute1
  ,   attribute2        = l_attribute2
  ,   attribute3        = l_attribute3
  ,   attribute4        = l_attribute4
  ,   attribute5        = l_attribute5
  ,   attribute6        = l_attribute6
  ,   attribute7        = l_attribute7
  ,   attribute8        = l_attribute8
  ,   attribute9        = l_attribute9
  ,   attribute10       = l_attribute10
  ,   attribute11       = l_attribute11
  ,   attribute12       = l_attribute12
  ,   attribute13       = l_attribute13
  ,   attribute14       = l_attribute14
  ,   attribute15       = l_attribute15
  ,   context           = l_context
  WHERE CURRENT OF l_com_csr;

  --
  -- CLOB handling
  --
  IF (   l_notes_detail IS NULL
     AND l_append_flag = 'N'
     )
  THEN
    -- empty the clob..
    UPDATE JTF_NOTES_TL
    SET  NOTES             = l_notes
    ,    NOTES_DETAIL      = EMPTY_CLOB()
    ,    LAST_UPDATE_DATE  = l_last_update_date
    ,    LAST_UPDATED_BY   = l_last_updated_by
    ,    LAST_UPDATE_LOGIN = l_last_update_login
    ,    SOURCE_LANG       = USERENV('LANG')
    WHERE JTF_NOTE_ID = p_jtf_note_id;

  ELSIF (   l_notes_detail IS NULL
        AND l_append_flag = 'Y'
        )
  THEN
    -- don't do anything with clob
    UPDATE JTF_NOTES_TL
    SET  NOTES             = l_notes
    ,    LAST_UPDATE_DATE  = l_last_update_date
    ,    LAST_UPDATED_BY   = l_last_updated_by
    ,    LAST_UPDATE_LOGIN = l_last_update_login
    ,    SOURCE_LANG       = USERENV('LANG')
    WHERE JTF_NOTE_ID = p_jtf_note_id;

  ELSE
    UPDATE JTF_NOTES_TL
    SET  NOTES             = l_notes
    ,    NOTES_DETAIL      = EMPTY_CLOB()
    ,    LAST_UPDATE_DATE  = l_last_update_date
    ,    LAST_UPDATED_BY   = l_last_updated_by
    ,    LAST_UPDATE_LOGIN = l_last_update_login
    ,    SOURCE_LANG       = USERENV('LANG')
    WHERE JTF_NOTE_ID = p_jtf_note_id;

    -- Update the CLOB
    writeDatatoLob(p_jtf_note_id,l_notes_detail);
  END IF;

  --
  -- Update the Note Context records
  --
  IF ( p_jtf_note_contexts_tab.COUNT > 0 )
  THEN
    FOR i IN 1..p_jtf_note_contexts_tab.COUNT
    LOOP
      Update_note_context
      ( p_validation_level     => p_validation_level
      , x_return_status        => l_return_status
      , p_note_context_id      => p_jtf_note_contexts_tab(i).note_context_id
      , p_jtf_note_id          => p_jtf_note_id
      , p_note_context_type_id => p_jtf_note_contexts_tab(i).note_context_type_id
      , p_note_context_type    => p_jtf_note_contexts_tab(i).note_context_type
      , p_last_updated_by      => p_jtf_note_contexts_tab(i).last_updated_by
      , p_last_update_date     => p_jtf_note_contexts_tab(i).last_update_date
      , p_last_update_login    => p_jtf_note_contexts_tab(i).last_update_login
      );

      IF (l_return_status <> fnd_api.g_ret_sts_success)
      THEN
        RAISE fnd_api.g_exc_error;
      END IF;
    END LOOP;
  END IF;

  IF jtf_usr_hks.ok_to_execute( 'JTF_NOTES_PUB'
                              , 'Create_Note'
                              , 'A'
                              , 'C'
                              )
  THEN
    jtf_notes_cuhk.update_note_post
    ( p_api_version     => l_api_version
    , x_msg_count       => l_msg_count
    , x_msg_data        => l_msg_data
    , p_jtf_note_id     => p_jtf_note_id
    , p_entered_by      => l_entered_by
    , p_last_updated_by => p_last_updated_by
    , p_notes           => l_notes
    , p_notes_detail    => l_notes_detail
    , p_append_flag     => p_append_flag
    , p_note_status     => l_note_status
    , p_note_type       => l_note_type
    , x_return_status   => l_return_status
    );

    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS)
    THEN
      FND_MESSAGE.Set_Name('JTF', 'JTF_API_ERR_POST_CUST_USR_HK');
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
  END IF;

  IF jtf_usr_hks.ok_to_execute( 'JTF_NOTES_PUB'
                              , 'Update Note'
                              , 'A'
                              , 'V'
                              )
  THEN
    jtf_notes_vuhk.update_note_post
    ( p_api_version     => l_api_version
    , x_msg_count       => l_msg_count
    , x_msg_data        => l_msg_data
    , p_jtf_note_id     => p_jtf_note_id
    , p_entered_by      => l_entered_by
    , p_last_updated_by => p_last_updated_by
    , p_notes           => l_notes
    , p_notes_detail    => l_notes_detail
    , p_append_flag     => p_append_flag
    , p_note_status     => l_note_status
    , p_note_type       => l_note_type
    , x_return_status   => l_return_status
    );

    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS)
    THEN
      FND_MESSAGE.Set_Name('JTF', 'JTF_API_ERR_POST_VERT_USR_HK');
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
  END IF;

  -- Standard call for message generation
  IF jtf_usr_hks.ok_to_execute( 'JTF_NOTES_PUB'
                              , 'Create_Note'
                              , 'M'
                              , 'M'
                              )
  THEN
    IF jtf_notes_cuhk.ok_to_generate_msg
                     ( p_api_version     => l_api_version
                     , x_msg_count       => l_msg_count
                     , x_msg_data        => l_msg_data
                     , p_jtf_note_id     => p_jtf_note_id
                     , p_entered_by      => l_entered_by
                     , p_last_updated_by => p_last_updated_by
                     , p_notes           => l_notes
                     , p_notes_detail    => l_notes_detail
                     , p_append_flag     => p_append_flag
                     , p_note_status     => l_note_status
                     , p_note_type       => l_note_type
                     , x_return_status   => l_return_status
                     )
    THEN
      l_bind_data_id := JTF_USR_HKS.Get_bind_data_id;
      JTF_USR_HKS.Load_bind_data( l_bind_data_id
                                , 'jtf_note_id'
                                , p_jtf_note_id
                                , 'S'
                                , 'N'
                                );

      JTF_USR_HKS.generate_message( p_prod_code    => 'JTF'
                                  , p_bus_obj_code => 'NOTES'
                                  , p_action_code  => 'I'
                                  , p_bind_data_id => l_bind_data_id
                                  , x_return_code  => l_return_status
                                  );
      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS)
      THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
    END IF;
  END IF;


  JTF_NOTES_EVENTS_PVT.RaiseUpdateNote
  ( p_NoteID            => p_jtf_note_id
  , p_SourceObjectCode  => l_com_rec.source_object_code
  , p_SourceObjectID    => l_com_rec.source_object_id
  );

  -- Standard check of p_commit
  IF fnd_api.to_boolean(p_commit)
  THEN
    COMMIT WORK;
  END IF;


  -- Standard call to get message count and if count is 1, get message info
  fnd_msg_pub.count_and_get( p_encoded => 'F'
                           , p_count   => x_msg_count
                           , p_data    => x_msg_data
                           );

EXCEPTION
   WHEN e_resource_busy
   THEN
     ROLLBACK TO update_note_pvt;
     /**********************************************************
	 ** Clean up cursors
	 **********************************************************/
     IF (l_com_csr%ISOPEN)
     THEN
       CLOSE l_com_csr;
     END IF;

     IF (l_tl_csr%ISOPEN)
     THEN
       CLOSE l_tl_csr;
     END IF;

     /**********************************************************
	 ** Set Status to error
	 **********************************************************/
     x_return_status := fnd_api.g_ret_sts_error;

     /**********************************************************
	 ** Set the error
	 **********************************************************/
	 fnd_message.set_name('FND', 'FND_LOCK_RECORD_ERROR');
     fnd_msg_pub.add;
     fnd_msg_pub.count_and_get( p_encoded => 'F'
                              , p_count   => x_msg_count
                              , p_data    => x_msg_data
                              );

   WHEN fnd_api.g_exc_error
   THEN
     ROLLBACK TO update_note_pvt;
     IF (l_com_csr%ISOPEN)
     THEN
       CLOSE l_com_csr;
     END IF;

     IF (l_tl_csr%ISOPEN)
     THEN
       CLOSE l_tl_csr;
     END IF;

     x_return_status := fnd_api.g_ret_sts_error;

     fnd_msg_pub.count_and_get( p_encoded => 'F'
                              , p_count   => x_msg_count
                              , p_data    => x_msg_data
                              );
   WHEN fnd_api.g_exc_unexpected_error
   THEN
     ROLLBACK TO update_note_pvt;
     IF (l_com_csr%ISOPEN)
     THEN
       CLOSE l_com_csr;
     END IF;

     IF (l_tl_csr%ISOPEN)
     THEN
       CLOSE l_tl_csr;
     END IF;

     x_return_status := fnd_api.g_ret_sts_unexp_error;

     fnd_msg_pub.count_and_get( p_encoded => 'F'
                              , p_count   => x_msg_count
                              , p_data    => x_msg_data
                              );
   WHEN OTHERS
   THEN
     ROLLBACK TO update_note_pvt;
     IF (l_com_csr%ISOPEN)
     THEN
       CLOSE l_com_csr;
     END IF;

     IF (l_tl_csr%ISOPEN)
     THEN
       CLOSE l_tl_csr;
     END IF;

     x_return_status := fnd_api.g_ret_sts_unexp_error;

     IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
     THEN
       fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
     END IF;

     fnd_msg_pub.count_and_get( p_encoded => 'F'
                              , p_count   => x_msg_count
                              , p_data    => x_msg_data
                              );
END Secure_Update_note;

END JTF_NOTES_PUB;

/
