--------------------------------------------------------
--  DDL for Package Body CAC_NOTES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CAC_NOTES_PVT" AS
/* $Header: cacvntb.pls 120.4 2006/06/15 10:07:24 sankgupt noship $ */

G_PKG_NAME CONSTANT VARCHAR2(30) := 'CAC_NOTES_PVT';

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

PROCEDURE Validate_note_type
------------------------------------------------------------------------------
--  Procedure    : Validate_note_type
------------------------------------------------------------------------------
( p_api_name        IN     VARCHAR2
, p_parameter_name  IN     VARCHAR2
, p_note_type       IN     VARCHAR2
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

PROCEDURE Validate_object
------------------------------------------------------------------------------
--  Procedure    : Validate_object
------------------------------------------------------------------------------
( p_api_name         IN VARCHAR2
, p_object_type_code IN VARCHAR2
, p_object_type_id   IN NUMBER
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



PROCEDURE Trunc_String_length
------------------------------------------------------------------------------
--  Procedure    : Trunc_String_Length
------------------------------------------------------------------------------
( p_api_name       IN     VARCHAR2
, p_parameter_name IN     VARCHAR2
, p_str            IN     VARCHAR2
, p_len            IN     NUMBER
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

PROCEDURE create_note
------------------------------------------------------------------------------
-- Create_note
--   Inserts a note record in the JTF_NOTES_B, JTF_NOTES_TL tables
------------------------------------------------------------------------------
( p_jtf_note_id        IN            NUMBER   := NULL
, p_source_object_id   IN            NUMBER
, p_source_object_code IN            VARCHAR2
, p_notes              IN            VARCHAR2
, p_notes_detail       IN            CLOB     := NULL
, p_note_status        IN            VARCHAR2 := NULL
, p_note_type          IN            VARCHAR2 := NULL
, p_attribute1         IN            VARCHAR2 := NULL
, p_attribute2         IN            VARCHAR2 := NULL
, p_attribute3         IN            VARCHAR2 := NULL
, p_attribute4         IN            VARCHAR2 := NULL
, p_attribute5         IN            VARCHAR2 := NULL
, p_attribute6         IN            VARCHAR2 := NULL
, p_attribute7         IN            VARCHAR2 := NULL
, p_attribute8         IN            VARCHAR2 := NULL
, p_attribute9         IN            VARCHAR2 := NULL
, p_attribute10        IN            VARCHAR2 := NULL
, p_attribute11        IN            VARCHAR2 := NULL
, p_attribute12        IN            VARCHAR2 := NULL
, p_attribute13        IN            VARCHAR2 := NULL
, p_attribute14        IN            VARCHAR2 := NULL
, p_attribute15        IN            VARCHAR2 := NULL
, p_parent_note_id     IN            NUMBER   := NULL
, p_entered_date       IN            DATE     := NULL
, p_entered_by         IN            NUMBER   := NULL
, p_creation_date      IN            DATE     := NULL
, p_created_by         IN            NUMBER   := NULL
, p_last_update_date   IN            DATE     := NULL
, p_last_updated_by    IN            NUMBER   := NULL
, p_last_update_login  IN            NUMBER   := NULL
, x_jtf_note_id           OUT NOCOPY NUMBER
, x_return_status         OUT NOCOPY VARCHAR2
, x_msg_count             OUT NOCOPY NUMBER
, x_msg_data              OUT NOCOPY VARCHAR2
)
IS
  l_api_name           CONSTANT VARCHAR2(30)    := 'Create_note';
  l_api_name_full      CONSTANT VARCHAR2(61)    := g_pkg_name || '.' || l_api_name;
  l_api_version        CONSTANT NUMBER          := 1.0;

  l_note_status                 VARCHAR2(1)     := p_note_status;
  l_jtf_note_id                 NUMBER          := p_jtf_note_id;
  l_return_status               VARCHAR2(1);

  l_notes                       VARCHAR2(32767) := p_notes;
  l_msg_count                   NUMBER ;
  l_msg_data                    VARCHAR2(2000);
  l_bind_data_id                NUMBER;


  -- Used for keeping track of errors
  l_missing_param               VARCHAR2(30)    := NULL;
  l_null_param                  VARCHAR2(30)    := NULL;

  l_current_date                DATE            := SYSDATE;
  l_debug                       VARCHAR2(2000) := '';


  -- Cursor for getting the note ID from the sequence
  CURSOR l_jtf_note_id_csr
  IS  SELECT JTF_NOTES_S.NEXTVAL
      FROM DUAL;

BEGIN
  -- API savepoint
  SAVEPOINT create_note_pvt;


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
    ( p_api_version             => l_api_version
    , x_msg_count               => x_msg_count
    , x_msg_data                => x_msg_data
    , p_source_object_id        => p_source_object_id
    , p_source_object_code      => p_source_object_code
    , p_notes                   => p_notes
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
    , p_note_type               => p_note_type
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
    ( p_api_version             => l_api_version
    , x_msg_count               => l_msg_count
    , x_msg_data                => l_msg_data
    , p_source_object_id        => p_source_object_id
    , p_source_object_code      => p_source_object_code
    , p_notes                   => p_notes
    , p_note_status             => p_note_status
    , p_entered_by              => p_entered_by
    , p_entered_date            => p_entered_date
    , x_jtf_note_id             => X_jtf_note_id
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
    , p_note_type               => p_note_type
    , x_return_status           => l_return_status
    );

    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS)
    THEN
      FND_MESSAGE.Set_Name('JTF', 'JTF_API_ERR_PRE_VERT_USR_HK');
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
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


  IF p_note_status IS NOT NULL
  THEN
     l_note_status := p_note_status;
  ELSE
     l_note_status := 'I'; -- Internal is the default
  END IF;


  --
  -- Get jtf_note_id from sequence
  --
  IF (l_jtf_note_id IS NULL)
  THEN
    OPEN l_jtf_note_id_csr;
    FETCH l_jtf_note_id_csr INTO l_jtf_note_id;
    CLOSE l_jtf_note_id_csr;
  END IF;

  insert into JTF_NOTES_B (
    SOURCE_OBJECT_CODE,
    NOTE_STATUS,
    ENTERED_BY,
    ENTERED_DATE,
    NOTE_TYPE,
    JTF_NOTE_ID,
    SOURCE_OBJECT_ID,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
	ATTRIBUTE1,
	ATTRIBUTE2,
	ATTRIBUTE3,
	ATTRIBUTE4,
	ATTRIBUTE5,
	ATTRIBUTE6,
	ATTRIBUTE7,
	ATTRIBUTE8,
	ATTRIBUTE9,
	ATTRIBUTE10,
	ATTRIBUTE11,
	ATTRIBUTE12,
	ATTRIBUTE13,
	ATTRIBUTE14,
	ATTRIBUTE15,
	PARENT_NOTE_ID
  ) values (
    p_SOURCE_OBJECT_CODE,
    L_NOTE_STATUS,
    NVL(p_entered_by,fnd_global.user_id),
    NVL(p_entered_date,l_current_date),
    P_NOTE_TYPE,
    L_JTF_NOTE_ID,
    P_SOURCE_OBJECT_ID,
    NVL(p_creation_date,l_current_date),
    NVL(p_created_by,fnd_global.user_id),
    NVL(p_last_update_date,l_current_date),
    NVL(p_last_updated_by,fnd_global.user_id),
    NVL(p_last_update_login,fnd_global.login_id),
	P_ATTRIBUTE1,
	P_ATTRIBUTE2,
	P_ATTRIBUTE3,
	P_ATTRIBUTE4,
	P_ATTRIBUTE5,
	P_ATTRIBUTE6,
	P_ATTRIBUTE7,
	P_ATTRIBUTE8,
	P_ATTRIBUTE9,
	P_ATTRIBUTE10,
	P_ATTRIBUTE11,
	P_ATTRIBUTE12,
	P_ATTRIBUTE13,
	P_ATTRIBUTE14,
	P_ATTRIBUTE15,
	P_PARENT_NOTE_ID
  );

  insert into JTF_NOTES_TL (
    JTF_NOTE_ID,
    NOTES,
    NOTES_DETAIL,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    L_JTF_NOTE_ID,
    L_NOTES,
    P_NOTES_DETAIL,
    NVL(p_creation_date,l_current_date),
    NVL(p_created_by,fnd_global.user_id),
    NVL(p_last_update_date,l_current_date),
    NVL(p_last_updated_by,fnd_global.user_id),
    NVL(p_last_update_login,fnd_global.login_id),
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B');

   INSERT INTO JTF_NOTE_CONTEXTS
    ( NOTE_CONTEXT_ID,
	 JTF_NOTE_ID,
	 NOTE_CONTEXT_TYPE_ID,
	 NOTE_CONTEXT_TYPE,
	 CREATION_DATE,
	 CREATED_BY,
	 LAST_UPDATE_DATE,
	 LAST_UPDATED_BY,
	 LAST_UPDATE_LOGIN)
  VALUES (
     jtf_notes_s.nextval,
	L_jtf_note_id,
	P_source_object_id,
	P_source_object_code,
    NVL(p_creation_date,l_current_date),
    NVL(p_created_by,fnd_global.user_id),
    NVL(p_last_update_date,l_current_date),
    NVL(p_last_updated_by,fnd_global.user_id),
    NVL(p_last_update_login,fnd_global.login_id)
	);

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
     ( p_api_version             => L_api_version
     , x_msg_count               => x_msg_count
     , x_msg_data                => x_msg_data
     , p_source_object_id        => p_source_object_id
     , p_source_object_code      => p_source_object_code
     , p_notes                   => P_notes
     , p_note_status             => l_note_status
     , p_entered_by              => FND_GLOBAL.USER_ID
     , p_entered_date            => l_current_date
     , x_jtf_note_id             => X_jtf_note_id
     , p_last_update_date        => l_current_date
     , p_last_updated_by         => FND_GLOBAL.USER_ID
     , p_creation_date           => l_current_date
     , p_created_by              => FND_GLOBAL.USER_ID
     , p_last_update_login       => FND_GLOBAL.LOGIN_ID
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
     , p_note_type               => p_note_type
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
     ( p_api_version             => l_api_version
     , x_msg_count               => x_msg_count
     , x_msg_data                => x_msg_data
     , p_source_object_id        => p_source_object_id
     , p_source_object_code      => p_source_object_code
     , p_notes                   => l_notes
     , p_note_status             => l_note_status
     , p_entered_by              => FND_GLOBAL.USER_ID
     , p_entered_date            => l_current_date
     , x_jtf_note_id             => X_jtf_note_id
     , p_last_update_date        => l_current_date
     , p_last_updated_by         => FND_GLOBAL.USER_ID
     , p_creation_date           => l_current_date
     , p_created_by              => FND_GLOBAL.USER_ID
     , p_last_update_login       => FND_GLOBAL.LOGIN_ID
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
     , p_note_type               => p_note_type
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
       ( p_api_version        => L_api_version
       , x_msg_count          => x_msg_count
       , x_msg_data           => x_msg_data
       , p_source_object_id   => p_source_object_id
       , p_source_object_code => p_source_object_code
       , p_notes              => p_notes
       , p_entered_by         => FND_GLOBAL.USER_ID
       , p_entered_date       => l_current_date
       , x_jtf_note_id        => X_jtf_note_id
       , p_last_update_date   => l_current_date
       , p_last_updated_by    => FND_GLOBAL.USER_ID
       , p_creation_date      => l_current_date
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
  ( p_NoteID            => p_jtf_note_id
  , p_SourceObjectCode  => p_source_object_code
  , p_SourceObjectID    => p_source_object_id
  );

  fnd_msg_pub.count_and_get( p_encoded => 'F'
                           , p_count   => x_msg_count
                           , p_data    => x_msg_data
                           );

   x_jtf_note_id := l_jtf_note_id;

EXCEPTION


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
    FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME
                           , l_api_name
                           , l_debug
                           );
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

END create_note;

PROCEDURE update_note
------------------------------------------------------------------------------
-- Update_note
--   Updates a note record in the JTF_NOTES_B, JTF_NOTES_TL tables
------------------------------------------------------------------------------
( p_jtf_note_id           IN            NUMBER
, p_notes                 IN            VARCHAR2 := NULL
, p_notes_detail          IN            CLOB     := NULL
, p_note_status           IN            VARCHAR2 := NULL
, p_note_type             IN            VARCHAR2 := NULL
, p_attribute1            IN            VARCHAR2 := NULL
, p_attribute2            IN            VARCHAR2 := NULL
, p_attribute3            IN            VARCHAR2 := NULL
, p_attribute4            IN            VARCHAR2 := NULL
, p_attribute5            IN            VARCHAR2 := NULL
, p_attribute6            IN            VARCHAR2 := NULL
, p_attribute7            IN            VARCHAR2 := NULL
, p_attribute8            IN            VARCHAR2 := NULL
, p_attribute9            IN            VARCHAR2 := NULL
, p_attribute10           IN            VARCHAR2 := NULL
, p_attribute11           IN            VARCHAR2 := NULL
, p_attribute12           IN            VARCHAR2 := NULL
, p_attribute13           IN            VARCHAR2 := NULL
, p_attribute14           IN            VARCHAR2 := NULL
, p_attribute15           IN            VARCHAR2 := NULL
, p_parent_note_id        IN            NUMBER   := NULL
, p_last_update_date      IN            DATE     := NULL
, p_last_updated_by       IN            NUMBER   := NULL
, p_last_update_login     IN            NUMBER   := NULL
, x_return_status            OUT NOCOPY VARCHAR2
, x_msg_count                OUT NOCOPY NUMBER
, x_msg_data                 OUT NOCOPY VARCHAR2
)
IS
  l_api_name           CONSTANT VARCHAR2(30)    := 'Update_note';
  l_api_name_full      CONSTANT VARCHAR2(61)    := g_pkg_name || '.' || l_api_name;
  l_api_version        CONSTANT NUMBER          := 1.0;
  l_notes                       VARCHAR2(32767) := p_notes;
  l_note_status                 VARCHAR2(2000)  := p_note_status;
  l_note_type                   VARCHAR2(2000)  := p_note_type;
  l_return_status               VARCHAR2(1);
  l_msg_count                   NUMBER ;
  l_msg_data                    VARCHAR2(2000);
  l_bind_data_id                NUMBER;
  l_current_date                DATE            := SYSDATE;
  l_debug                       VARCHAR2(2000) := '';
  l_source_object_code          VARCHAR2(240);
  l_source_object_id            NUMBER;

BEGIN

  -- API savepoint
  SAVEPOINT update_note_pvt;


  -- Initialize return status to SUCCESS
  x_return_status := fnd_api.g_ret_sts_success;

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
                  , p_entered_by      => FND_GLOBAL.USER_ID
                  , p_last_updated_by => p_last_updated_by
                  , p_notes           => p_notes
                  , p_note_status     => p_note_status
                  , p_note_type       => p_note_type
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
                  , p_entered_by      => FND_GLOBAL.USER_ID
                  , p_last_updated_by => p_last_updated_by
                  , p_notes           => p_notes
                  , p_note_status     => p_note_status
                  , p_note_type       => p_note_type
                  , x_return_status   => l_return_status
                  );

    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS)
    THEN
      FND_MESSAGE.Set_Name('JTF', 'JTF_API_ERR_PRE_CUST_USR_HK');
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
  END IF;

  IF (l_note_status = FND_API.G_MISS_CHAR)
  THEN
  	l_note_status := NULL;
  END IF;

  IF (l_note_type = FND_API.G_MISS_CHAR)
  THEN
  	l_note_type := NULL;
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

  --
  -- Perform the database operation.
  --
  UPDATE JTF_NOTES_B
  SET last_updated_by   = NVL(p_last_updated_by,fnd_global.user_id)
  ,   last_update_date  = NVL(p_last_update_date,l_current_date)
  ,   last_update_login = NVL(p_last_update_login,fnd_global.login_id)
  ,   note_status       = NVL(l_note_status,note_status)
  ,   note_type         = l_note_type
  ,   attribute1        = p_attribute1
  ,   attribute2        = p_attribute2
  ,   attribute3        = p_attribute3
  ,   attribute4        = p_attribute4
  ,   attribute5        = p_attribute5
  ,   attribute6        = p_attribute6
  ,   attribute7        = p_attribute7
  ,   attribute8        = p_attribute8
  ,   attribute9        = p_attribute9
  ,   attribute10       = p_attribute10
  ,   attribute11       = p_attribute11
  ,   attribute12       = p_attribute12
  ,   attribute13       = p_attribute13
  ,   attribute14       = p_attribute14
  ,   attribute15       = p_attribute15
  ,   parent_note_id    = p_parent_note_id
  WHERE jtf_note_id = p_jtf_note_id;

  IF (p_notes_detail IS NULL)
  THEN
  	  UPDATE JTF_NOTES_TL
  	  SET  NOTES             = NVL(l_notes,NOTES)
  	  ,    LAST_UPDATE_DATE  = NVL(p_last_update_date,l_current_date)
  	  ,    LAST_UPDATED_BY   = NVL(p_last_updated_by,fnd_global.user_id)
  	  ,    LAST_UPDATE_LOGIN = NVL(p_last_update_login,fnd_global.login_id)
  	  ,    SOURCE_LANG       = USERENV('LANG')
  	  WHERE JTF_NOTE_ID = p_jtf_note_id;
  ELSE
  	  UPDATE JTF_NOTES_TL
  	  SET  NOTES             = NVL(l_notes,NOTES)
  	  ,    NOTES_DETAIL      = p_notes_detail
  	  ,    LAST_UPDATE_DATE  = NVL(p_last_update_date,l_current_date)
  	  ,    LAST_UPDATED_BY   = NVL(p_last_updated_by,fnd_global.user_id)
  	  ,    LAST_UPDATE_LOGIN = NVL(p_last_update_login,fnd_global.login_id)
  	  ,    SOURCE_LANG       = USERENV('LANG')
  	  WHERE JTF_NOTE_ID = p_jtf_note_id;
  END IF;

  IF jtf_usr_hks.ok_to_execute( 'JTF_NOTES_PUB'
                              , 'Update Note'
                              , 'A'
                              , 'C'
                              )
  THEN
    jtf_notes_cuhk.update_note_post
    ( p_api_version     => l_api_version
    , x_msg_count       => l_msg_count
    , x_msg_data        => l_msg_data
    , p_jtf_note_id     => p_jtf_note_id
    , p_entered_by      => FND_GLOBAL.USER_ID
    , p_last_updated_by => p_last_updated_by
    , p_notes           => l_notes
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
    , p_entered_by      => FND_GLOBAL.USER_ID
    , p_last_updated_by => p_last_updated_by
    , p_notes           => l_notes
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
                     , p_entered_by      => FND_GLOBAL.USER_ID
                     , p_last_updated_by => p_last_updated_by
                     , p_notes           => l_notes
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

  --
  -- get the source onject information so we can pas it to the WF event
  --
  SELECT source_object_code
  ,      source_object_id
  INTO l_source_object_code
  ,    l_source_object_id
  FROM jtf_notes_b
  WHERE jtf_note_id = p_jtf_note_id;

  JTF_NOTES_EVENTS_PVT.RaiseUpdateNote
  ( p_NoteID            => p_jtf_note_id
  , p_SourceObjectCode  => l_source_object_code
  , p_SourceObjectID    => l_source_object_id
  );

  fnd_msg_pub.count_and_get( p_encoded => 'F'
                           , p_count   => x_msg_count
                           , p_data    => x_msg_data
                           );

EXCEPTION


   WHEN fnd_api.g_exc_error
   THEN
     ROLLBACK TO update_note_pvt;
     x_return_status := fnd_api.g_ret_sts_error;
     fnd_msg_pub.count_and_get( p_encoded => 'F'
                              , p_count   => x_msg_count
                              , p_data    => x_msg_data
                              );

   WHEN fnd_api.g_exc_unexpected_error
   THEN
      ROLLBACK TO update_note_pvt;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get( p_encoded => 'F'
                               , p_count   => x_msg_count
                               , p_data    => x_msg_data
                               );

   WHEN OTHERS
   THEN
     ROLLBACK TO update_note_pvt;
    FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME
                           , l_api_name
                           , l_debug
                           );
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
END update_note;

PROCEDURE delete_note
------------------------------------------------------------------------------
-- delete_note
--   deletes a note record in the JTF_NOTES_B, JTF_NOTES_TL tables
------------------------------------------------------------------------------
( p_jtf_note_id           IN            NUMBER
, x_return_status            OUT NOCOPY VARCHAR2
, x_msg_count                OUT NOCOPY NUMBER
, x_msg_data                 OUT NOCOPY VARCHAR2
)
IS
  l_api_name       CONSTANT VARCHAR2(30)    := 'delete_note';
  l_api_name_full  CONSTANT VARCHAR2(61)    := G_PKG_NAME||'.'||l_api_name;
  l_source_object_code      VARCHAR2(240);
  l_source_object_id        NUMBER;

BEGIN
  -- API savepoint
  SAVEPOINT delete_note_pvt;

  --
  -- Initialize API return status to success
  --
  x_return_status := FND_API.G_RET_STS_SUCCESS;

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

  --
  -- Standard call to get message count and if count is 1, get message info
  --
  FND_MSG_PUB.Count_And_Get( p_count => x_msg_count
                           , p_data  => x_msg_data
                           );

EXCEPTION
  WHEN OTHERS
  THEN
     ROLLBACK TO delete_note_pvt;
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
    -- Get error message from FND stack
    --
    x_msg_data      := FND_MESSAGE.GET;

    --
    -- Count the messages on the CRM stack
    --
    x_msg_count     := FND_MSG_PUB.COUNT_MSG;

END delete_note;

PROCEDURE create_note_context
------------------------------------------------------------------------------
-- create_note_context
--   creates a record in the JTF_NOTE_CONTEXTS table.
------------------------------------------------------------------------------
( p_note_context_id      IN            NUMBER
, p_jtf_note_id          IN            NUMBER
, p_note_context_type    IN            VARCHAR2
, p_note_context_type_id IN            NUMBER
, p_creation_date        IN            DATE     := NULL
, p_created_by           IN            NUMBER   := NULL
, p_last_update_date     IN            DATE     := NULL
, p_last_updated_by      IN            NUMBER   := NULL
, p_last_update_login    IN            NUMBER   := NULL
, x_note_context_id         OUT NOCOPY NUMBER
, x_return_status           OUT NOCOPY VARCHAR2
, x_msg_count               OUT NOCOPY NUMBER
, x_msg_data                OUT NOCOPY VARCHAR2
)
IS
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

  l_api_name      CONSTANT VARCHAR2(200) := 'create_note_context';
  l_api_name_full CONSTANT VARCHAR2(200)  := g_pkg_name || '.' || l_api_name;
  l_debug                  VARCHAR2(2000) := '';
  l_current_date           DATE := SYSDATE;

BEGIN

  -- API savepoint
  SAVEPOINT create_note_context_pvt;

  -- Initialize return status to SUCCESS
  x_return_status := fnd_api.g_ret_sts_success;

  -- Validate source object id and code
  Validate_object(   p_api_name         => l_api_name_full
                   , p_object_type_code => p_note_context_type
                   , p_object_type_id   => p_note_context_type_id
                   , x_return_status    => x_return_status
                 );

  IF (x_return_status <> fnd_api.g_ret_sts_success)
  THEN
    RAISE fnd_api.g_exc_error;
  END IF;

  -- we should only do the insert if the relation doesn't already exist
  OPEN c_duplicate( p_jtf_note_id
                  , p_note_context_type
                  , p_note_context_type_id
                  );

  FETCH c_duplicate INTO x_note_context_id;

  IF (c_duplicate%NOTFOUND)
  THEN
    INSERT INTO JTF_NOTE_CONTEXTS
    (
	 NOTE_CONTEXT_ID,
	 JTF_NOTE_ID,
	 NOTE_CONTEXT_TYPE_ID,
	 NOTE_CONTEXT_TYPE,
	 CREATION_DATE,
	 CREATED_BY,
	 LAST_UPDATE_DATE,
	 LAST_UPDATED_BY,
	 LAST_UPDATE_LOGIN
	)
    VALUES
	(
     NVL(p_note_context_id,jtf_notes_s.nextval),
	 p_jtf_note_id,
	 p_note_context_type_id,
	 p_note_context_type,
     NVL(p_creation_date,l_current_date),
     NVL(p_created_by,fnd_global.user_id),
     NVL(p_last_update_date,l_current_date),
     NVL(p_last_updated_by,fnd_global.user_id),
     NVL(p_last_update_login,fnd_global.login_id)
	)
    RETURNING note_context_id INTO x_note_context_id;

  ELSE
    -- pretend the insert was succesfull and return the ID for the (first)
    -- duplicate record
	NULL;
  END IF;

  CLOSE c_duplicate;

  fnd_msg_pub.count_and_get( p_encoded => 'F'
                           , p_count   => x_msg_count
                           , p_data    => x_msg_data
                           );

EXCEPTION

   WHEN fnd_api.g_exc_error
   THEN
     ROLLBACK TO create_note_context_pvt;
     x_return_status := fnd_api.g_ret_sts_error;
     fnd_msg_pub.count_and_get( p_encoded => 'F'
                              , p_count   => x_msg_count
                              , p_data    => x_msg_data
                              );

   WHEN fnd_api.g_exc_unexpected_error
   THEN
      ROLLBACK TO create_note_context_pvt;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get( p_encoded => 'F'
                               , p_count   => x_msg_count
                               , p_data    => x_msg_data
                               );

   WHEN OTHERS
   THEN
     ROLLBACK TO create_note_context_pvt;
     FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME
                           , l_api_name
                           , l_debug
                           );
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

END create_note_context;


PROCEDURE update_note_context
------------------------------------------------------------------------------
-- update_note_context
--   updates a record in the JTF_NOTE_CONTEXTS table.
------------------------------------------------------------------------------
( p_note_context_id       IN            NUMBER
, p_jtf_note_id           IN            NUMBER   := NULL
, p_note_context_type     IN            VARCHAR2 := NULL
, p_note_context_type_id  IN            NUMBER   := NULL
, p_last_update_date      IN            DATE     := NULL
, p_last_updated_by       IN            NUMBER   := NULL
, p_last_update_login     IN            NUMBER   := NULL
, x_return_status            OUT NOCOPY VARCHAR2
, x_msg_count                OUT NOCOPY NUMBER
, x_msg_data                 OUT NOCOPY VARCHAR2
)
IS
  l_api_name      CONSTANT VARCHAR2(200) := 'update_note_context';
  l_api_name_full CONSTANT VARCHAR2(200)  := g_pkg_name || '.' || l_api_name;
  l_debug                  VARCHAR2(2000) := '';

BEGIN

  -- API savepoint
  SAVEPOINT update_note_context_pvt;

  -- Initialize return status to SUCCESS
  x_return_status := fnd_api.g_ret_sts_success;

  -- Validate source object id and code
  Validate_object(   p_api_name         => l_api_name_full
                   , p_object_type_code => p_note_context_type
                   , p_object_type_id   => p_note_context_type_id
                   , x_return_status    => x_return_status
                 );

  IF (x_return_status <> fnd_api.g_ret_sts_success)
  THEN
    RAISE fnd_api.g_exc_error;
  END IF;

  UPDATE JTF_NOTE_CONTEXTS
  SET
	 JTF_NOTE_ID          = NVL(p_jtf_note_id,JTF_NOTE_ID),
	 NOTE_CONTEXT_TYPE_ID = NVL(p_note_context_type_id,NOTE_CONTEXT_TYPE_ID),
	 NOTE_CONTEXT_TYPE    = NVL(p_note_context_type,NOTE_CONTEXT_TYPE),
	 LAST_UPDATE_DATE     = NVL(p_last_update_date,SYSDATE),
	 LAST_UPDATED_BY      = NVL(p_last_updated_by,fnd_global.user_id),
	 LAST_UPDATE_LOGIN    = NVL(p_last_update_login,fnd_global.login_id)
  WHERE NOTE_CONTEXT_ID = p_note_context_id;

  fnd_msg_pub.count_and_get( p_encoded => 'F'
                           , p_count   => x_msg_count
                           , p_data    => x_msg_data
                           );

EXCEPTION

   WHEN fnd_api.g_exc_error
   THEN
     ROLLBACK TO update_note_context_pvt;
     x_return_status := fnd_api.g_ret_sts_error;
     fnd_msg_pub.count_and_get( p_encoded => 'F'
                              , p_count   => x_msg_count
                              , p_data    => x_msg_data
                              );

   WHEN fnd_api.g_exc_unexpected_error
   THEN
      ROLLBACK TO update_note_context_pvt;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get( p_encoded => 'F'
                               , p_count   => x_msg_count
                               , p_data    => x_msg_data
                               );

   WHEN OTHERS
   THEN
     ROLLBACK TO update_note_context_pvt;
     FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME
                           , l_api_name
                           , l_debug
                           );
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

END update_note_context;


PROCEDURE delete_note_context
------------------------------------------------------------------------------
-- delete_note_context
--   deletes a record in the JTF_NOTE_CONTEXTS table.
------------------------------------------------------------------------------
( p_note_context_id       IN            NUMBER
, x_return_status            OUT NOCOPY VARCHAR2
, x_msg_count                OUT NOCOPY NUMBER
, x_msg_data                 OUT NOCOPY VARCHAR2
)
IS
  l_api_name VARCHAR2(2000) := 'delete_note_context';
  l_debug    VARCHAR2(2000) := '';

BEGIN

  -- API savepoint
  SAVEPOINT delete_note_context_pvt;

  -- Initialize return status to SUCCESS
  x_return_status := fnd_api.g_ret_sts_success;

  DELETE FROM JTF_NOTE_CONTEXTS
  WHERE NOTE_CONTEXT_ID = p_note_context_id;

  fnd_msg_pub.count_and_get( p_encoded => 'F'
                           , p_count   => x_msg_count
                           , p_data    => x_msg_data
                           );

EXCEPTION

   WHEN OTHERS
   THEN
     ROLLBACK TO delete_note_context_pvt;
     FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME
                           , l_api_name
                           , l_debug
                           );
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

END delete_note_context;

FUNCTION GET_ENTERED_BY_NAME
/*******************************************************************************
** Given a USER_ID the function will return the username/partyname. This
** Function is used to display the CREATED_BY who column information on JTF
** transaction pages.
*******************************************************************************/
(p_user_id IN NUMBER
)RETURN VARCHAR2
IS
   CURSOR c_user
   /****************************************************************************
   ** Cursor used to fetch the foreign keys needed to access the source tables
   ****************************************************************************/
   (b_user_id IN NUMBER
   )IS SELECT employee_id
       ,      customer_id
       ,      supplier_id
       ,      user_name
       FROM fnd_user
       WHERE user_id = b_user_id;

   CURSOR c_employee
   /****************************************************************************
   ** Cursor used to fetch the employee name in case the foreign key is to an
   ** Employee
   ****************************************************************************/
   (b_employee_id IN NUMBER
   )IS SELECT full_name
       ,      employee_number
       FROM per_all_people_f
       WHERE person_id = b_employee_id;

   CURSOR c_party
   /****************************************************************************
   ** Cursor used to fetch the party name in case the foreign key is to a
   ** Customer or Supplier
   ****************************************************************************/
   (b_party_id IN NUMBER
   )IS SELECT party_name
       ,      party_number
       FROM hz_parties
       WHERE party_id = b_party_id;

    CURSOR c_supplier
   /****************************************************************************
   ** Cursor used to fetch the supplier name in case the foreign key is to a
   ** Supplier
   ****************************************************************************/
   ( b_supplier_id IN NUMBER
   ) IS SELECT LAST_NAME|| ',' || FIRST_NAME || MIDDLE_NAME full_name,
               VENDOR_CONTACT_ID
          FROM po_vendor_contacts
         WHERE VENDOR_CONTACT_ID = b_supplier_id ;
  l_employee_id     NUMBER;
   l_customer_id     NUMBER;
   l_supplier_id     NUMBER;
   l_user_name       VARCHAR2(360);

   l_number          VARCHAR2(30);
   l_name            VARCHAR2(240);
   l_display_info    VARCHAR2(500);


BEGIN
  /*****************************************************************************
  ** Get the foreigh keys to the user information
  *****************************************************************************/
  IF c_user%ISOPEN
  THEN
    CLOSE c_user;
  END IF;

  OPEN c_user(p_user_id);

  FETCH c_user INTO l_employee_id,l_customer_id,l_supplier_id,l_user_name;

  IF c_user%ISOPEN
  THEN
    CLOSE c_user;
  END IF;

  IF (l_employee_id IS NOT NULL)
  THEN
    -- get the employee information
    IF c_employee%ISOPEN
    THEN
      CLOSE c_employee;
    END IF;

    OPEN c_employee(l_employee_id);

    FETCH c_employee INTO l_name,l_number;

    IF c_employee%ISOPEN
    THEN
      CLOSE c_employee;
    END IF;

	--bug # 3178448, remove employee id
	l_number := NULL;

  ELSIF (l_customer_id IS NOT NULL)
  THEN
    -- get the customer information
    IF c_party%ISOPEN
    THEN
      CLOSE c_party;
    END IF;

    OPEN c_party(l_customer_id);

    FETCH c_party INTO l_name, l_number;

    IF c_party%ISOPEN
    THEN
      CLOSE c_party;
    END IF;

  ELSIF (l_supplier_id IS NOT NULL)
  THEN
    -- get the supplier information
    IF c_supplier%ISOPEN
    THEN
      CLOSE c_supplier;
    END IF;

    OPEN c_supplier(l_supplier_id);

    FETCH c_supplier INTO l_name, l_number;

    IF c_supplier%ISOPEN
    THEN
      CLOSE c_supplier;
    END IF;
  END IF;

  IF l_name IS NULL
  THEN
    RETURN l_user_name;
  ELSE
  	--bug # 3178448, remove employee id
	IF l_number IS NULL
	THEN
      RETURN l_name||'('||l_user_name||')';
	ELSE
      RETURN l_name||'('||l_user_name||','||l_number||')';
	END IF;
  END IF;

EXCEPTION
  WHEN OTHERS
  THEN
    IF c_employee%ISOPEN
    THEN
      CLOSE c_employee;
    END IF;

    IF c_party%ISOPEN
    THEN
      CLOSE c_party;
    END IF;
    RETURN 'Not Found';
END GET_ENTERED_BY_NAME;

END CAC_NOTES_PVT;

/
