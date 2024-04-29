--------------------------------------------------------
--  DDL for Package Body IBC_DATA_SECURITY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBC_DATA_SECURITY_PVT" AS
/* $Header: ibcdsecb.pls 120.2 2006/02/21 15:05:10 sharma noship $ */
  /*#
   * This is the private API for OCM Data Security. These methods are
   * exposed as Java APIs in DataSecurityManager.class
   * @rep:scope private
   * @rep:product IBC
   * @rep:displayname Oracle Content Manager Data Security Private API
   * @rep:category BUSINESS_ENTITY IBC_DATA_SECURITY
   */

   G_PKG_NAME      CONSTANT VARCHAR2(30) := 'IBC_DATA_SECURITY_PVT';
   G_FILE_NAME     CONSTANT VARCHAR2(12) := 'ibcdsecb.pls';

   TYPE t_user_id_tbl IS TABLE OF NUMBER
        INDEX BY BINARY_INTEGER;

  -- Cursor to fetch FND object info definition
  CURSOR c_object(p_object_id IN NUMBER) IS
    SELECT object_id,
           obj_name,
           database_object_name,
           pk1_column_name,
           pk2_column_name,
           pk3_column_name,
           pk4_column_name,
           pk5_column_name,
           pk1_column_type,
           pk2_column_type,
           pk3_column_type,
           pk4_column_type,
           pk5_column_type
      FROM fnd_objects
     WHERE object_id = p_object_id;

  -- ------------------------------------------------------------
  -- Internal Function to be used when building a SQL statement
  -- dynamically.
  -- ------------------------------------------------------------
  FUNCTION convert_to_name(p_name IN VARCHAR2,
                             p_type  IN VARCHAR2)
  RETURN VARCHAR2
  AS
  BEGIN
   IF p_type = 'NUMBER' THEN
      RETURN 'FND_NUMBER.CANONICAL_TO_NUMBER(' || p_name || ')';
   ELSIF p_type = 'DATE' THEN
      RETURN 'FND_DATE.CANONICAL_TO_DATE(' || p_name || ')';
   ELSE
      RETURN p_name;
   END IF;
  END convert_to_name;

  -- ------------------------------------------------------------
  -- Internal Function to be used when building a SQL statement
  -- dynamically.
  -- ------------------------------------------------------------
  FUNCTION convert_to_value(p_value IN VARCHAR2,
                            p_type  IN VARCHAR2)
  RETURN VARCHAR2
  AS
  BEGIN
   IF p_type = 'NUMBER' THEN
      RETURN 'FND_NUMBER.CANONICAL_TO_NUMBER(''' || p_value || ''')';
   ELSIF p_type = 'DATE' THEN
      RETURN 'FND_DATE.CANONICAL_TO_DATE(''' || p_value || ''')';
   ELSE
      RETURN '''' || p_value || '''';
   END IF;
  END convert_to_value;

  -- ------------------------------------------------------------
  -- Internal Function to be used when building a SQL statement
  -- dynamically.
  -- ------------------------------------------------------------
  FUNCTION convert_from_name(p_name IN VARCHAR2,
                             p_type  IN VARCHAR2)
  RETURN VARCHAR2
  AS
  BEGIN
   IF p_type = 'NUMBER' THEN
      RETURN 'FND_NUMBER.NUMBER_TO_CANONICAL(' || p_name || ')';
   ELSIF p_type = 'DATE' THEN
      RETURN 'FND_DATE.DATE_TO_CANONICAL(' || p_name || ')';
   ELSE
      RETURN p_name;
   END IF;
  END convert_from_name;

  -- ------------------------------------------------------------
  -- Internal Function to be used when building a SQL statement
  -- dynamically.
  -- ------------------------------------------------------------
  FUNCTION convert_from_value(p_value IN VARCHAR2,
                              p_type  IN VARCHAR2)
  RETURN VARCHAR2
  AS
  BEGIN
   IF p_type = 'NUMBER' THEN
      RETURN 'FND_NUMBER.NUMBER_TO_CANONICAL(''' || p_value || ''')';
   ELSIF p_type = 'DATE' THEN
      RETURN 'FND_DATE.DATE_TO_CANONICAL(''' || p_value || ''')';
   ELSE
      RETURN '''' || p_value || '''';
   END IF;
  END convert_from_value;

  -- ------------------------------------------------------------
  -- Internal Function to do conversions to canonical
  -- ------------------------------------------------------------
  FUNCTION canonical_from_value(p_value IN VARCHAR2,
                                p_type  IN VARCHAR2)
  RETURN VARCHAR2
  AS
  BEGIN
   IF p_type = 'NUMBER' THEN
      RETURN FND_NUMBER.NUMBER_TO_CANONICAL(TO_NUMBER(p_value));
   ELSIF p_type = 'DATE' THEN
      RETURN FND_DATE.DATE_TO_CANONICAL(TO_DATE(p_value, 'YYYYMMDD HH:MI:SS'));
   ELSE
      RETURN p_value;
   END IF;
  END canonical_from_value;

  -- ----------------------------------------------------
  -- FUNCTION: get_object_definition
  -- DESCRIPTION: Given an object id it returns object
  -- definition information.
  -- ----------------------------------------------------
  PROCEDURE get_object_definition(p_object_id   IN  NUMBER,
                                  x_nbr_pk_cols OUT NOCOPY NUMBER,
                                  x_fmt_col_lst OUT NOCOPY VARCHAR2,
                                  x_object_def  OUT NOCOPY c_object%ROWTYPE) AS
  BEGIN
    FOR r_object IN c_object(p_object_id) LOOP
      x_nbr_pk_cols := 1;
      IF r_object.pk2_column_name IS NOT NULL THEN
        IF r_object.pk3_column_name IS NULL THEN
          x_nbr_pk_cols := 2;
        ELSIF r_object.pk4_column_name IS NULL THEN
          x_nbr_pk_cols := 3;
        ELSIF r_object.pk5_column_name IS NULL THEN
          x_nbr_pk_cols := 4;
        ELSE
          x_nbr_pk_cols := 5;
        END IF;
      END IF;
      x_object_def := r_object;
      x_fmt_col_lst := r_object.pk1_column_name;
      IF r_object.pk2_column_name IS NOT NULL THEN
        x_fmt_col_lst := x_fmt_col_lst || ', ' || r_object.pk2_column_name;
        IF r_object.pk3_column_name IS NOT NULL THEN
          x_fmt_col_lst := x_fmt_col_lst || ', ' || r_object.pk3_column_name;
          IF r_object.pk4_column_name IS NOT NULL THEN
            x_fmt_col_lst := x_fmt_col_lst || ', ' || r_object.pk4_column_name;
            IF r_object.pk5_column_name IS NOT NULL THEN
              x_fmt_col_lst := x_fmt_col_lst || ', ' || r_object.pk5_column_name;
            END IF;
          END IF;
        END IF;
      END IF;
    END LOOP;
  -- Exception Handler Added for NOCOPY Change (11/08/2002) By ENUNEZ
  EXCEPTION
    WHEN OTHERS THEN
      RAISE;
  END get_object_definition;

  -- ----------------------------------------------------
  -- FUNCTION: get_object_grant_group_info
  -- DESCRIPTION: Given instance object id and primary
  -- key returns object's grant group information
  -- ----------------------------------------------------
  PROCEDURE get_object_grant_group_info(
    p_instance_object_id     IN  NUMBER
    ,p_instance_pk1_value    IN  VARCHAR2
    ,p_instance_pk2_value    IN  VARCHAR2
    ,p_instance_pk3_value    IN  VARCHAR2
    ,p_instance_pk4_value    IN  VARCHAR2
    ,p_instance_pk5_value    IN  VARCHAR2
    ,x_rowid                 OUT NOCOPY ROWID
    ,x_object_grant_group_id OUT NOCOPY NUMBER
    ,x_grant_group_id        OUT NOCOPY NUMBER
    ,x_inherited_flag        OUT NOCOPY VARCHAR2
    ,x_inherited_from        OUT NOCOPY VARCHAR2
    ,x_inheritance_type      OUT NOCOPY VARCHAR2
  ) AS
    TYPE cursorType IS    REF CURSOR;
    c_cursor              cursorType;
    l_statement           VARCHAR2(4096);
    -- Object Definition
    l_nbr_pk_cols         NUMBER;
    l_fmt_col_lst         VARCHAR2(4096);
    l_object_definition   c_object%ROWTYPE;
  BEGIN
    IF p_instance_object_id IS NULL OR
       p_instance_pk1_value IS NULL
    THEN
      RETURN;
    END IF;
    -- Get Object Definition
    Get_Object_Definition(
      p_object_id    => p_instance_object_id
      ,x_nbr_pk_cols => l_nbr_pk_cols
      ,x_fmt_col_lst => l_fmt_col_lst
      ,x_object_def  => l_object_definition
    );
    -- Prepare SQL statement to get Grant Bundle Id
    l_statement := 'SELECT rowid, object_grant_group_id, grant_group_id, ' ||
                   '       inherited_flag, inherited_from, inheritance_type  ' ||
              		   '  FROM ibc_object_grant_groups ' ||
              		   ' WHERE object_id = :p_instance_object_id ' ||
              		   '   AND instance_pk1_value = :p_instance_pk1_value ';
    IF l_nbr_pk_cols > 1 THEN
      l_statement := l_statement ||
                     '  AND instance_pk2_value = :p_instance_pk2_value ';
      IF l_nbr_pk_cols > 2 THEN
        l_statement := l_statement ||
                       '  AND instance_pk3_value = :p_instance_pk3_value ';
       	IF l_nbr_pk_cols > 3 THEN
          l_statement := l_statement ||
                         '  AND instance_pk4_value = :p_instance_pk4_value ';
       	  IF l_nbr_pk_cols > 4 THEN
            l_statement := l_statement ||
                           '  AND instance_pk5_value = :p_instance_pk5_value ';
       	  END IF;
       	END IF;
      END IF;
    END IF;
    FOR I IN (l_nbr_pk_cols + 1)..5 LOOP
      l_statement := l_statement ||
                     '  AND instance_pk' || I || '_VALUE IS NULL ';
    END LOOP;

    IF l_nbr_pk_cols = 5 THEN
      OPEN c_cursor FOR l_statement
      USING p_instance_object_id,
            canonical_from_value(p_instance_pk1_value, l_object_definition.pk1_column_type),
            canonical_from_value(p_instance_pk2_value, l_object_definition.pk2_column_type),
            canonical_from_value(p_instance_pk3_value, l_object_definition.pk3_column_type),
            canonical_from_value(p_instance_pk4_value, l_object_definition.pk4_column_type),
            canonical_from_value(p_instance_pk5_value, l_object_definition.pk5_column_type);
    ELSIF l_nbr_pk_cols = 4 THEN
      OPEN c_cursor FOR l_statement
      USING p_instance_object_id,
            canonical_from_value(p_instance_pk1_value, l_object_definition.pk1_column_type),
            canonical_from_value(p_instance_pk2_value, l_object_definition.pk2_column_type),
            canonical_from_value(p_instance_pk3_value, l_object_definition.pk3_column_type),
            canonical_from_value(p_instance_pk4_value, l_object_definition.pk4_column_type);
    ELSIF l_nbr_pk_cols = 3 THEN
      OPEN c_cursor FOR l_statement
      USING p_instance_object_id,
            canonical_from_value(p_instance_pk1_value, l_object_definition.pk1_column_type),
            canonical_from_value(p_instance_pk2_value, l_object_definition.pk2_column_type),
            canonical_from_value(p_instance_pk3_value, l_object_definition.pk3_column_type);
    ELSIF l_nbr_pk_cols = 2 THEN
      OPEN c_cursor FOR l_statement
      USING p_instance_object_id,
            canonical_from_value(p_instance_pk1_value, l_object_definition.pk1_column_type),
            canonical_from_value(p_instance_pk2_value, l_object_definition.pk2_column_type);
    ELSE
      OPEN c_cursor FOR l_statement
      USING p_instance_object_id,
            canonical_from_value(p_instance_pk1_value, l_object_definition.pk1_column_type);
	END IF;

    -- Fetching Info from IBC_object_grant_groups
    FETCH c_cursor INTO x_rowid, x_object_grant_group_id, x_grant_group_id,
                        x_inherited_flag, x_inherited_from, x_inheritance_type;

    IF c_cursor%NOTFOUND THEN
      x_object_grant_group_id := NULL;
      x_grant_group_id        := NULL;
      x_inherited_flag        := NULL;
      x_inherited_from        := NULL;
      x_inheritance_type      := NULL;
    END IF;

    CLOSE c_cursor;

  -- Exception Handler Added for NOCOPY Change (11/08/2002) By ENUNEZ
  EXCEPTION
    WHEN OTHERS THEN
      RAISE;

  END get_object_grant_group_info;

  /*#
   *  Given the object name it returns corrsponding object id
   *  from FND_OBJECTS
   *
   *  @param p_object_name Object Name in FND_OBJECTS
   *  @return Object Id
   *
   *  @rep:displayname get_object_id
   *
   */
  FUNCTION get_object_id(
    p_object_name        IN VARCHAR2
  ) RETURN NUMBER AS
    l_result             NUMBER;
    CURSOR c_object_id(p_object_name VARCHAR2) IS
      SELECT object_id
        FROM fnd_objects
       WHERE obj_name = p_object_name;
  BEGIN
    OPEN c_object_id(p_object_name);
    FETCH c_object_id INTO l_result;
    CLOSE c_object_id;
    RETURN l_result;
  END get_object_id;

  /*#
   *  Given an object id it returns the lookup type used
   *  to validate especific permissions for the object
   *  instances corresponding to such object id.
   *
   *  @param p_object_id Object Id
   *  @return permission's lookup type
   *
   *  @rep:displayname get_perms_lookup_type
   *
   */
  FUNCTION get_perms_lookup_type(
    p_object_id              IN NUMBER
  ) RETURN VARCHAR2 AS
    l_result                 VARCHAR2(30);
    CURSOR c_lookup_type(p_object_id NUMBER) IS
      SELECT permissions_lookup_type
        FROM ibc_object_permissions
       WHERE object_id = p_object_id;
  BEGIN
    OPEN c_lookup_type(p_object_id);
    FETCH c_lookup_type INTO l_result;
    CLOSE c_lookup_type;
    RETURN l_result;
  END get_perms_lookup_type;

  /*#
   *  It sets inheritance type of an instance already existing in data
   *  security inheritance tree.
   *
   *  @param p_instance_object_id  ID for object definition id found in FND_OBJECTS
   *                               for this particular instance
   *  @param p_instance_pk1_value  value 1 for instance's primary key
   *  @param p_instance_pk2_value  value 2 for instance's primary key
   *  @param p_instance_pk3_value  value 3 for instance's primary key
   *  @param p_instance_pk4_value  value 4 for instance's primary key
   *  @param p_instance_pk5_value  value 5 for instance's primary key
   *  @param p_inheritance_type    type of inheritance (FOLDER, HIDDEN-FOLDER,
   *                               WORKSPACE and WSFOLDER). Currently supported
   *                               in OCM only FOLDER and HIDDEN-FOLDER.
   *  @param p_commit              Indicates whether to commit or not at the end
   *                               of procedure
   *  @param p_api_version         standard parm - API Version
   *  @param p_init_msg_list       standard parm - Initialize message list
   *  @param x_return_status       standard parm - Return Status
   *  @param x_msg_count           standard parm - Message Count
   *  @param x_msg_data            standard parm - Message Data
   *
   *  @rep:displayname set_inheritance_type
   *
   */
  PROCEDURE set_inheritance_type(
    p_instance_object_id     IN  NUMBER
    ,p_instance_pk1_value    IN  VARCHAR2
    ,p_instance_pk2_value    IN  VARCHAR2
    ,p_instance_pk3_value    IN  VARCHAR2
    ,p_instance_pk4_value    IN  VARCHAR2
    ,p_instance_pk5_value    IN  VARCHAR2
    ,p_inheritance_type      IN  VARCHAR2
    ,p_commit                IN  VARCHAR2
    ,p_api_version           IN  NUMBER
    ,p_init_msg_list         IN  VARCHAR2
    ,x_return_status         OUT NOCOPY VARCHAR2
    ,x_msg_count             OUT NOCOPY NUMBER
    ,x_msg_data              OUT NOCOPY VARCHAR2
  ) AS
    l_rowid                       ROWID;
    --******** local variable for standards **********
    l_api_name                    CONSTANT VARCHAR2(30)   := 'set_inheritance_type';
    l_api_version                 CONSTANT NUMBER := 1.0;
    -- IBC_object_grant_groups
    l_object_grant_group_rowid    ROWID;
    l_object_grant_group_id       NUMBER;
    l_old_grant_group_id          NUMBER;
    l_grant_group_id              NUMBER;
    l_inherited_flag              VARCHAR2(2);
    l_inherited_from              NUMBER;
    l_inheritance_type            VARCHAR2(30);
    l_default_inheritance_type    VARCHAR2(30);
    -- IBC_object_grant_groups
    l_c_object_grant_group_rowid  ROWID;
    l_c_object_grant_group_id     NUMBER;
    l_c_grant_group_id            NUMBER;
    l_c_inherited_flag            VARCHAR2(2);
    l_c_inherited_from            NUMBER;
    l_c_inheritance_type          VARCHAR2(30);

    CURSOR c_ogg(p_object_grant_group_id NUMBER) IS
      SELECT object_id,
             instance_pk1_value,
             instance_pk2_value,
             instance_pk3_value,
             instance_pk4_value,
             instance_pk5_value
        FROM ibc_object_grant_groups
       WHERE object_grant_group_id = p_object_grant_group_id;
    r_ogg     c_ogg%ROWTYPE;

  BEGIN
    SAVEPOINT svpt_set_inheritance_type;

    -- ******* Standard Begins ********
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (
              l_api_version,
              p_api_version,
              l_api_name,
              G_PKG_NAME)
    THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;

    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Begin

    -- Fetch object's grant group Info
    get_object_grant_group_info(
      p_instance_object_id     => p_instance_object_id
      ,p_instance_pk1_value    => p_instance_pk1_value
      ,p_instance_pk2_value    => p_instance_pk2_value
      ,p_instance_pk3_value    => p_instance_pk3_value
      ,p_instance_pk4_value    => p_instance_pk4_value
      ,p_instance_pk5_value    => p_instance_pk5_value
      ,x_rowid                 => l_object_grant_group_rowid
      ,x_object_grant_group_id => l_object_grant_group_id
      ,x_grant_group_id        => l_grant_group_id
      ,x_inherited_flag        => l_inherited_flag
      ,x_inherited_from        => l_inherited_from
      ,x_inheritance_type      => l_inheritance_type
    );

    OPEN c_ogg(l_inherited_from);
    FETCH c_ogg INTO r_ogg;

    IF c_ogg%FOUND THEN
      CLOSE c_ogg;
      establish_inheritance(
        p_instance_object_id     => p_instance_object_id
        ,p_instance_pk1_value    => p_instance_pk1_value
        ,p_instance_pk2_value    => p_instance_pk2_value
        ,p_instance_pk3_value    => p_instance_pk3_value
        ,p_instance_pk4_value    => p_instance_pk4_value
        ,p_instance_pk5_value    => p_instance_pk5_value
        ,p_container_object_id   => r_ogg.object_id
        ,p_container_pk1_value   => r_ogg.instance_pk1_value
        ,p_container_pk2_value   => r_ogg.instance_pk2_value
        ,p_container_pk3_value   => r_ogg.instance_pk3_value
        ,p_container_pk4_value   => r_ogg.instance_pk4_value
        ,p_container_pk5_value   => r_ogg.instance_pk5_value
        ,p_inheritance_type      => p_inheritance_type
        ,p_commit                => p_commit
        ,p_api_version           => 1.0
        ,p_init_msg_list         => p_init_msg_list
        ,x_return_status         => x_return_status
        ,x_msg_count             => x_msg_count
        ,x_msg_data              => x_msg_data
      );
    ELSE
      CLOSE c_ogg;
    END IF;

    -- COMMIT?
    IF (p_commit = FND_API.g_true) THEN
        COMMIT;
    END IF;

    -- Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                p_data  => x_msg_data);
  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO svpt_set_inheritance_type;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                                p_data  => x_msg_data);
      IBC_UTILITIES_PVT.HANDLE_EXCEPTIONS(
          P_API_NAME => L_API_NAME
          ,P_PKG_NAME => G_PKG_NAME
          ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
          ,P_PACKAGE_TYPE => IBC_UTILITIES_PVT.G_PVT
          ,P_SQLCODE => SQLCODE
          ,P_SQLERRM => SQLERRM
          ,X_MSG_COUNT => X_MSG_COUNT
          ,X_MSG_DATA => X_MSG_DATA
          ,X_RETURN_STATUS => X_RETURN_STATUS
      );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO svpt_set_inheritance_type;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                                p_data  => x_msg_data);
      IBC_UTILITIES_PVT.HANDLE_EXCEPTIONS(
               P_API_NAME => L_API_NAME
               ,P_PKG_NAME => G_PKG_NAME
               ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
               ,P_PACKAGE_TYPE => IBC_UTILITIES_PVT.G_PVT
               ,P_SQLCODE => SQLCODE
               ,P_SQLERRM => SQLERRM
               ,X_MSG_COUNT => X_MSG_COUNT
               ,X_MSG_DATA => X_MSG_DATA
               ,X_RETURN_STATUS => X_RETURN_STATUS
           );
    WHEN OTHERS THEN
      ROLLBACK TO svpt_set_inheritance_type;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
        FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
      END IF;
      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                                p_data  => x_msg_data);
      IBC_UTILITIES_PVT.HANDLE_EXCEPTIONS(
               P_API_NAME => L_API_NAME
               ,P_PKG_NAME => G_PKG_NAME
               ,P_EXCEPTION_LEVEL => IBC_UTILITIES_PVT.G_EXC_OTHERS
               ,P_PACKAGE_TYPE => IBC_UTILITIES_PVT.G_PVT
               ,P_SQLCODE => SQLCODE
               ,P_SQLERRM => SQLERRM
               ,X_MSG_COUNT => X_MSG_COUNT
               ,X_MSG_DATA => X_MSG_DATA
               ,X_RETURN_STATUS => X_RETURN_STATUS
          );
  END set_inheritance_type;


  /*#
   *  It removes an instance from data security inheritance tree. This procedure
   *  should be called when the directory node gets removed from the system as well,
   *  to keep inheritance information accurate.
   *
   *  @param p_instance_object_id  ID for object definition id found in FND_OBJECTS
   *                               for this particular instance
   *  @param p_instance_pk1_value  value 1 for instance's primary key
   *  @param p_instance_pk2_value  value 2 for instance's primary key
   *  @param p_instance_pk3_value  value 3 for instance's primary key
   *  @param p_instance_pk4_value  value 4 for instance's primary key
   *  @param p_instance_pk5_value  value 5 for instance's primary key
   *  @param p_commit              Indicates whether to commit or not at the end
   *                               of procedure
   *  @param p_api_version         standard parm - API Version
   *  @param p_init_msg_list       standard parm - Initialize message list
   *  @param x_return_status       standard parm - Return Status
   *  @param x_msg_count           standard parm - Message Count
   *  @param x_msg_data            standard parm - Message Data
   *
   *  @rep:displayname Remove_Instance
   *
   */
  PROCEDURE Remove_Instance(
    p_instance_object_id     IN  NUMBER
    ,p_instance_pk1_value    IN  VARCHAR2
    ,p_instance_pk2_value    IN  VARCHAR2
    ,p_instance_pk3_value    IN  VARCHAR2
    ,p_instance_pk4_value    IN  VARCHAR2
    ,p_instance_pk5_value    IN  VARCHAR2
    ,p_commit                IN  VARCHAR2
    ,p_api_version           IN  NUMBER
    ,p_init_msg_list         IN  VARCHAR2
    ,x_return_status         OUT NOCOPY VARCHAR2
    ,x_msg_count             OUT NOCOPY NUMBER
    ,x_msg_data              OUT NOCOPY VARCHAR2
  ) AS
    l_rowid                       ROWID;
    --******** local variable for standards **********
    l_api_name                    CONSTANT VARCHAR2(30)   := 'Remove_Instance';
    l_api_version                 CONSTANT NUMBER := 1.0;
    -- IBC_object_grant_groups
    l_object_grant_group_rowid    ROWID;
    l_object_grant_group_id       NUMBER;
    l_old_grant_group_id          NUMBER;
    l_grant_group_id              NUMBER;
    l_inherited_flag              VARCHAR2(2);
    l_inherited_from              NUMBER;
    l_inheritance_type            VARCHAR2(30);
    l_default_inheritance_type    VARCHAR2(30);

    CURSOR c_child_ogg(p_ogg_id NUMBER) IS
      SELECT *
        FROM ibc_object_grant_groups
       WHERE inherited_from = p_ogg_id;

  BEGIN
    SAVEPOINT svpt_remove_instance;

    -- ******* Standard Begins ********
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (
              l_api_version,
              p_api_version,
              l_api_name,
              G_PKG_NAME)
    THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;

    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Begin

    -- Fetch object's grant group Info
    get_object_grant_group_info(
      p_instance_object_id     => p_instance_object_id
      ,p_instance_pk1_value    => p_instance_pk1_value
      ,p_instance_pk2_value    => p_instance_pk2_value
      ,p_instance_pk3_value    => p_instance_pk3_value
      ,p_instance_pk4_value    => p_instance_pk4_value
      ,p_instance_pk5_value    => p_instance_pk5_value
      ,x_rowid                 => l_object_grant_group_rowid
      ,x_object_grant_group_id => l_object_grant_group_id
      ,x_grant_group_id        => l_grant_group_id
      ,x_inherited_flag        => l_inherited_flag
      ,x_inherited_from        => l_inherited_from
      ,x_inheritance_type      => l_inheritance_type
    );

    IF l_object_grant_group_rowid IS NOT NULL THEN
      FOR r_child_ogg IN c_child_ogg(l_object_grant_group_id) LOOP
        Remove_Instance(
          p_instance_object_id     => r_child_ogg.object_id
          ,p_instance_pk1_value    => r_child_ogg.instance_pk1_value
          ,p_instance_pk2_value    => r_child_ogg.instance_pk2_value
          ,p_instance_pk3_value    => r_child_ogg.instance_pk3_value
          ,p_instance_pk4_value    => r_child_ogg.instance_pk4_value
          ,p_instance_pk5_value    => r_child_ogg.instance_pk5_value
          ,p_commit                => p_commit
          ,p_api_version           => p_api_version
          ,p_init_msg_list         => p_init_msg_list
          ,x_return_status         => x_return_status
          ,x_msg_count             => x_msg_count
          ,x_msg_data              => x_msg_data
        );
        EXIT WHEN x_return_status <> FND_API.G_RET_STS_SUCCESS;
      END LOOP;

      IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
        IF l_inherited_flag = 'N' THEN
          -- Removing grants and grant group if not inheriting
          DELETE FROM ibc_grants WHERE grant_group_id = l_grant_group_id;
          DELETE FROM ibc_grant_groups WHERE grant_group_id = l_grant_group_id;
        END IF;
        DELETE FROM ibc_object_grant_groups
              WHERE ROWID = l_object_grant_group_rowid;
      END IF;

    END IF;

    -- COMMIT?
    IF (p_commit = FND_API.g_true AND x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        COMMIT;
    END IF;

    -- Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                p_data  => x_msg_data);
  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO svpt_remove_instance;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                                p_data  => x_msg_data);
      IBC_UTILITIES_PVT.HANDLE_EXCEPTIONS(
          P_API_NAME => L_API_NAME
          ,P_PKG_NAME => G_PKG_NAME
          ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
          ,P_PACKAGE_TYPE => IBC_UTILITIES_PVT.G_PVT
          ,P_SQLCODE => SQLCODE
          ,P_SQLERRM => SQLERRM
          ,X_MSG_COUNT => X_MSG_COUNT
          ,X_MSG_DATA => X_MSG_DATA
          ,X_RETURN_STATUS => X_RETURN_STATUS
      );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO svpt_remove_instance;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                                p_data  => x_msg_data);
      IBC_UTILITIES_PVT.HANDLE_EXCEPTIONS(
               P_API_NAME => L_API_NAME
               ,P_PKG_NAME => G_PKG_NAME
               ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
               ,P_PACKAGE_TYPE => IBC_UTILITIES_PVT.G_PVT
               ,P_SQLCODE => SQLCODE
               ,P_SQLERRM => SQLERRM
               ,X_MSG_COUNT => X_MSG_COUNT
               ,X_MSG_DATA => X_MSG_DATA
               ,X_RETURN_STATUS => X_RETURN_STATUS
           );
    WHEN OTHERS THEN
      ROLLBACK TO svpt_remove_instance;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
        FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
      END IF;
      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                                p_data  => x_msg_data);
      IBC_UTILITIES_PVT.HANDLE_EXCEPTIONS(
               P_API_NAME => L_API_NAME
               ,P_PKG_NAME => G_PKG_NAME
               ,P_EXCEPTION_LEVEL => IBC_UTILITIES_PVT.G_EXC_OTHERS
               ,P_PACKAGE_TYPE => IBC_UTILITIES_PVT.G_PVT
               ,P_SQLCODE => SQLCODE
               ,P_SQLERRM => SQLERRM
               ,X_MSG_COUNT => X_MSG_COUNT
               ,X_MSG_DATA => X_MSG_DATA
               ,X_RETURN_STATUS => X_RETURN_STATUS
          );
  END Remove_Instance;


  /*#
   *  This procedure establishes inheritance hierarchy, it must be kept
   *  in sync with directory nodes hierarchy tree.  It creates an
   *  inheritance link between an instance (child) and its container (parent).
   *  This procedure must be called for each container (i.e. directory node)
   *  create to define a hierarchy of containment and inheritance
   *
   *  @param p_instance_object_id  ID for object definition id found in FND_OBJECTS
   *                               for this particular instance
   *  @param p_instance_pk1_value  value 1 for instance's primary key
   *  @param p_instance_pk2_value  value 2 for instance's primary key
   *  @param p_instance_pk3_value  value 3 for instance's primary key
   *  @param p_instance_pk4_value  value 4 for instance's primary key
   *  @param p_instance_pk5_value  value 5 for instance's primary key
   *  @param p_container_object_id ID for object definition id found in FND_OBJECTS
   *                               for the container
   *  @param p_container_pk1_value value 1 for container's primary key
   *  @param p_container_pk2_value value 2 for container's primary key
   *  @param p_container_pk3_value value 3 for container's primary key
   *  @param p_container_pk4_value value 4 for container's primary key
   *  @param p_container_pk5_value value 5 for container's primary key
   *  @param p_inheritance_type    type of inheritance (FOLDER, HIDDEN-FOLDER,
   *                               WORKSPACE and WSFOLDER). Currently supported
   *                               in OCM only FOLDER and HIDDEN-FOLDER.
   *  @param p_commit              Indicates whether to commit or not at the end
   *                               of procedure
   *  @param p_api_version         standard parm - API Version
   *  @param p_init_msg_list       standard parm - Initialize message list
   *  @param x_return_status       standard parm - Return Status
   *  @param x_msg_count           standard parm - Message Count
   *  @param x_msg_data            standard parm - Message Data
   *
   *  @rep:displayname establish_inheritance
   *
   */
  PROCEDURE establish_inheritance(
    p_instance_object_id     IN  NUMBER
    ,p_instance_pk1_value    IN  VARCHAR2
    ,p_instance_pk2_value    IN  VARCHAR2
    ,p_instance_pk3_value    IN  VARCHAR2
    ,p_instance_pk4_value    IN  VARCHAR2
    ,p_instance_pk5_value    IN  VARCHAR2
    ,p_container_object_id   IN  NUMBER
    ,p_container_pk1_value   IN  VARCHAR2
    ,p_container_pk2_value   IN  VARCHAR2
    ,p_container_pk3_value   IN  VARCHAR2
    ,p_container_pk4_value   IN  VARCHAR2
    ,p_container_pk5_value   IN  VARCHAR2
    ,p_inheritance_type      IN  VARCHAR2
    ,p_commit                IN  VARCHAR2
    ,p_api_version           IN  NUMBER
    ,p_init_msg_list         IN  VARCHAR2
    ,x_return_status         OUT NOCOPY VARCHAR2
    ,x_msg_count             OUT NOCOPY NUMBER
    ,x_msg_data              OUT NOCOPY VARCHAR2
  ) AS
    l_rowid                       ROWID;
    --******** local variable for standards **********
    l_api_name                    CONSTANT VARCHAR2(30)   := 'establish_inheritance';
    l_api_version                 CONSTANT NUMBER := 1.0;
    -- IBC_object_grant_groups
    l_object_grant_group_rowid    ROWID;
    l_object_grant_group_id       NUMBER;
    l_old_grant_group_id          NUMBER;
    l_grant_group_id              NUMBER;
    l_inherited_flag              VARCHAR2(2);
    l_inherited_from              NUMBER;
    l_inheritance_type            VARCHAR2(30);
    l_default_inheritance_type    VARCHAR2(30);
    -- IBC_object_grant_groups
    l_c_object_grant_group_rowid  ROWID;
    l_c_object_grant_group_id     NUMBER;
    l_c_grant_group_id            NUMBER;
    l_c_inherited_flag            VARCHAR2(2);
    l_c_inherited_from            NUMBER;
    l_c_inheritance_type          VARCHAR2(30);
    -- Cursor to get all ogg children objects
    CURSOR c_ogg_children(p_ogg_id IN NUMBER) IS
      SELECT *
        FROM ibc_object_grant_groups
       WHERE inherited_from = p_ogg_id;
  BEGIN
    SAVEPOINT svpt_establish_inheritance;

    -- ******* Standard Begins ********
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (
              l_api_version,
              p_api_version,
              l_api_name,
              G_PKG_NAME)
    THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;

    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Begin

    -- Fetch object's grant group Info
    get_object_grant_group_info(
      p_instance_object_id     => p_instance_object_id
      ,p_instance_pk1_value    => p_instance_pk1_value
      ,p_instance_pk2_value    => p_instance_pk2_value
      ,p_instance_pk3_value    => p_instance_pk3_value
      ,p_instance_pk4_value    => p_instance_pk4_value
      ,p_instance_pk5_value    => p_instance_pk5_value
      ,x_rowid                 => l_object_grant_group_rowid
      ,x_object_grant_group_id => l_object_grant_group_id
      ,x_grant_group_id        => l_grant_group_id
      ,x_inherited_flag        => l_inherited_flag
      ,x_inherited_from        => l_inherited_from
      ,x_inheritance_type      => l_inheritance_type
    );

    -- Fetch object's grant group info for Container
    get_object_grant_group_info(
      p_instance_object_id     => p_container_object_id
      ,p_instance_pk1_value    => p_container_pk1_value
      ,p_instance_pk2_value    => p_container_pk2_value
      ,p_instance_pk3_value    => p_container_pk3_value
      ,p_instance_pk4_value    => p_container_pk4_value
      ,p_instance_pk5_value    => p_container_pk5_value
      ,x_rowid                 => l_c_object_grant_group_rowid
      ,x_object_grant_group_id => l_c_object_grant_group_id
      ,x_grant_group_id        => l_c_grant_group_id
      ,x_inherited_flag        => l_c_inherited_flag
      ,x_inherited_from        => l_c_inherited_from
      ,x_inheritance_type      => l_c_inheritance_type
    );

    IF l_object_grant_group_rowid IS NULL AND
       l_c_object_grant_group_rowid IS NULL
    THEN
      -- No object's grant group (inheritance) defined for object
      -- And no object's grant group for container
      -- It will be treated as initial setup for root dir
      -- Create Row in IBC_grant_groups
      SELECT ibc_grant_groups_s1.nextval
        INTO l_grant_group_id
       	FROM dual;
      IBC_GRANT_GROUPS_PKG.insert_row(
        px_rowid                 => l_rowid
        ,p_grant_group_id        => l_grant_group_id
        ,p_object_version_number => 1
      );
      -- Create Row in IBC_object_grant_groups
      SELECT ibc_object_grant_groups_s1.nextval
        INTO l_object_grant_group_id
        FROM dual;
      IBC_OBJECT_GRANT_GROUPS_PKG.insert_row(
        px_rowid                 => l_rowid
        ,p_object_grant_group_id => l_object_grant_group_id
        ,p_object_version_number => 1
        ,p_grant_group_id        => l_grant_group_id
        ,p_object_id             => p_instance_object_id
        ,p_inherited_flag        => 'N'
        ,p_inherited_from        => NULL
        ,p_instance_pk1_value    => p_instance_pk1_value
        ,p_instance_pk2_value    => p_instance_pk2_value
        ,p_instance_pk3_value    => p_instance_pk3_value
        ,p_instance_pk4_value    => p_instance_pk4_value
        ,p_instance_pk5_value    => p_instance_pk5_value
        ,p_inheritance_type      => NVL(p_inheritance_type, 'FOLDER')
      );
    ELSIF l_object_grant_group_rowid IS NULL THEN
      -- No object's grant group (inheritance) defined for object
      -- but defined for container object.
      -- Regular inheritance row will be added to object_grant_group
      -- Create Row in IBC_object_grant_groups

      -- Validation of inheritance type
      IF (l_c_inheritance_type = 'WORKSPACE' AND
          p_inheritance_type <> 'WSFOLDER')
         OR
         (l_c_inheritance_type = 'HIDDEN-FOLDER' AND
          p_inheritance_type <> 'HIDDEN-FOLDER')
         OR
         (l_c_inheritance_type = 'FOLDER' AND
          p_inheritance_type NOT IN ('FOLDER', 'HIDDEN-FOLDER', 'WORKSPACE'))
         OR
         (l_c_inheritance_type = 'WSFOLDER' AND
          p_inheritance_type <> 'WSFOLDER')
      THEN
         -- Error Inheritance Type not compatible with containers
         FND_MESSAGE.Set_Name('IBC', 'IBC_INCOMPATIBLE_INHERITANCE_TYPE');
         FND_MSG_PUB.ADD;
         RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- Defaulting inheritance type based on container's inheritance type
      IF p_inheritance_type IS NULL THEN
        IF l_c_inheritance_type = 'WORKSPACE' THEN
          l_default_inheritance_type := 'WSFOLDER';
        ELSE
          l_default_inheritance_Type := l_c_inheritance_type;
        END IF;
      END IF;

      SELECT ibc_object_grant_groups_s1.nextval
        INTO l_object_grant_group_id
        FROM dual;
      IBC_OBJECT_GRANT_GROUPS_PKG.insert_row(
        px_rowid                 => l_rowid
        ,p_object_grant_group_id => l_object_grant_group_id
        ,p_object_version_number => 1
        ,p_grant_group_id        => l_c_grant_group_id
        ,p_object_id             => p_instance_object_id
        ,p_inherited_flag        => 'Y'
        ,p_inherited_from        => l_c_object_grant_group_id
        ,p_instance_pk1_value    => p_instance_pk1_value
        ,p_instance_pk2_value    => p_instance_pk2_value
        ,p_instance_pk3_value    => p_instance_pk3_value
        ,p_instance_pk4_value    => p_instance_pk4_value
        ,p_instance_pk5_value    => p_instance_pk5_value
        ,p_inheritance_type      => NVL(p_inheritance_type, l_default_inheritance_type)
      );
    ELSE
      -- object's grant group exists for object and container object
      -- it will be treated as an update.
      IF l_inherited_from = l_c_object_grant_group_id THEN
        -- No change in hierarchy tree, only update if inheritance type differs
        IF l_inheritance_type <> p_inheritance_type THEN


           -- Validation of inheritance type according to container
           IF (l_c_inheritance_type = 'WORKSPACE' AND
               p_inheritance_type <> 'WSFOLDER')
              OR
              (l_c_inheritance_type = 'HIDDEN-FOLDER' AND
               p_inheritance_type <> 'HIDDEN-FOLDER')
              OR
              (l_c_inheritance_type = 'FOLDER' AND
               p_inheritance_type NOT IN ('FOLDER', 'HIDDEN-FOLDER', 'WORKSPACE'))
              OR
              (l_c_inheritance_type = 'WSFOLDER' AND
               p_inheritance_type <> 'WSFOLDER')
          THEN
             -- Error Inheritance Type not compatible with containers
             FND_MESSAGE.Set_Name('IBC', 'IBC_INCOMPATIBLE_INHERITANCE_TYPE');
             FND_MSG_PUB.ADD;
             RAISE FND_API.G_EXC_ERROR;
          END IF;

          -- Actual UPDATE
          -- *****
          Ibc_Object_Grant_Groups_Pkg.UPDATE_ROW (
            P_OBJECT_GRANT_GROUP_ID     => l_object_grant_group_id,
            p_OBJECT_VERSION_NUMBER     => FND_API.G_MISS_NUM,
            P_GRANT_GROUP_ID            => l_grant_group_id,
            P_OBJECT_ID                 => p_instance_object_id,
            P_INHERITED_FLAG            => l_inherited_flag,
            P_INHERITED_FROM            => l_inherited_from,
            P_INSTANCE_PK1_VALUE        => p_instance_pk1_value,
            P_INSTANCE_PK2_VALUE        => p_instance_pk2_value,
            P_INSTANCE_PK3_VALUE        => p_instance_pk3_value,
            P_INSTANCE_PK4_VALUE        => p_instance_pk4_value,
            P_INSTANCE_PK5_VALUE        => p_instance_pk5_value,
            P_INHERITANCE_TYPE          => p_inheritance_type
          );

          IF p_inheritance_type = 'WSFOLDER' AND l_inherited_flag = FND_API.G_FALSE THEN
            -- Removing all permissions for grant group if it's WSFOLDER and it's not inheriting
            DELETE FROM ibc_grants
             WHERE grant_group_id = l_grant_group_id;
            -- Remove grant group
            DELETE FROM ibc_grant_groups
             WHERE grant_group_id = l_grant_group_id;
            -- update inheritance to all the the ones pointing to such grant group to
            -- point to the container's, and change inheritance type for all of them to
            -- WSFOLDER
            UPDATE ibc_object_grant_groups
               SET inherited_flag = 'Y',
                   grant_group_id = l_c_grant_group_id
             WHERE object_grant_group_id
                   IN ( SELECT object_grant_group_id
                          FROM ibc_object_grant_groups
                       CONNECT BY PRIOR object_grant_group_id = inherited_from
                         START WITH inherited_from = l_object_grant_group_id);
          END IF;

        END IF;

        FOR r_ogg IN c_ogg_children(l_object_grant_group_id) LOOP

          -- Defaulting inheritance type based on container's inheritance type
          IF p_inheritance_type = 'WORKSPACE' THEN
            l_default_inheritance_type := 'WSFOLDER';
          ELSE
            l_default_inheritance_Type := p_inheritance_type;
          END IF;

          -- **** PENDING.
          establish_inheritance(
            p_instance_object_id     => r_ogg.object_id
            ,p_instance_pk1_value    => r_ogg.instance_pk1_value
            ,p_instance_pk2_value    => r_ogg.instance_pk2_value
            ,p_instance_pk3_value    => r_ogg.instance_pk3_value
            ,p_instance_pk4_value    => r_ogg.instance_pk4_value
            ,p_instance_pk5_value    => r_ogg.instance_pk5_value
            ,p_container_object_id   => p_instance_object_id
            ,p_container_pk1_value   => p_instance_pk1_value
            ,p_container_pk2_value   => p_instance_pk2_value
            ,p_container_pk3_value   => p_instance_pk3_value
            ,p_container_pk4_value   => p_instance_pk4_value
            ,p_container_pk5_value   => p_instance_pk5_value
            ,p_inheritance_type      => l_default_inheritance_type
            ,p_commit                => FND_API.g_false
            ,p_api_version           => 1.0
            ,p_init_msg_list         => FND_API.g_false
            ,x_return_status         => x_return_status
            ,x_msg_count             => x_msg_count
            ,x_msg_data              => x_msg_data
          );

          IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
            RAISE FND_API.G_EXC_ERROR;
          END IF;

        END LOOP;
      ELSE
        -- Moving an instance to a
        -- Different container, by default all permissions will be gone.
        -- *** STILL PENDING: Not needed in this release ***
        NULL;
      END IF;
    END IF;

    -- COMMIT?
    IF (p_commit = FND_API.g_true) THEN
        COMMIT;
    END IF;

    -- Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                p_data  => x_msg_data);
  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO svpt_establish_inheritance;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                                p_data  => x_msg_data);
      IBC_UTILITIES_PVT.HANDLE_EXCEPTIONS(
          P_API_NAME => L_API_NAME
          ,P_PKG_NAME => G_PKG_NAME
          ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
          ,P_PACKAGE_TYPE => IBC_UTILITIES_PVT.G_PVT
          ,P_SQLCODE => SQLCODE
          ,P_SQLERRM => SQLERRM
          ,X_MSG_COUNT => X_MSG_COUNT
          ,X_MSG_DATA => X_MSG_DATA
          ,X_RETURN_STATUS => X_RETURN_STATUS
      );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO svpt_establish_inheritance;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                                p_data  => x_msg_data);
      IBC_UTILITIES_PVT.HANDLE_EXCEPTIONS(
               P_API_NAME => L_API_NAME
               ,P_PKG_NAME => G_PKG_NAME
               ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
               ,P_PACKAGE_TYPE => IBC_UTILITIES_PVT.G_PVT
               ,P_SQLCODE => SQLCODE
               ,P_SQLERRM => SQLERRM
               ,X_MSG_COUNT => X_MSG_COUNT
               ,X_MSG_DATA => X_MSG_DATA
               ,X_RETURN_STATUS => X_RETURN_STATUS
           );
    WHEN OTHERS THEN
      ROLLBACK TO svpt_establish_inheritance;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
        FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
      END IF;
      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                                p_data  => x_msg_data);
      IBC_UTILITIES_PVT.HANDLE_EXCEPTIONS(
               P_API_NAME => L_API_NAME
               ,P_PKG_NAME => G_PKG_NAME
               ,P_EXCEPTION_LEVEL => IBC_UTILITIES_PVT.G_EXC_OTHERS
               ,P_PACKAGE_TYPE => IBC_UTILITIES_PVT.G_PVT
               ,P_SQLCODE => SQLCODE
               ,P_SQLERRM => SQLERRM
               ,X_MSG_COUNT => X_MSG_COUNT
               ,X_MSG_DATA => X_MSG_DATA
               ,X_RETURN_STATUS => X_RETURN_STATUS
          );
  END establish_inheritance;


  /*#
   *  This procedure establishes inheritance hierarchy, it must be kept
   *  in sync with directory nodes hierarchy tree.  It creates an
   *  inheritance link between an instance (child) and its container (parent).
   *  This procedure must be called for each container (i.e. directory node)
   *  create to define a hierarchy of containment and inheritance.
   *  This is overloaded of establish_inheritance without inheritance type parm.
   *
   *  @param p_instance_object_id  ID for object definition id found in FND_OBJECTS
   *                               for this particular instance
   *  @param p_instance_pk1_value  value 1 for instance's primary key
   *  @param p_instance_pk2_value  value 2 for instance's primary key
   *  @param p_instance_pk3_value  value 3 for instance's primary key
   *  @param p_instance_pk4_value  value 4 for instance's primary key
   *  @param p_instance_pk5_value  value 5 for instance's primary key
   *  @param p_container_object_id ID for object definition id found in FND_OBJECTS
   *                               for the container
   *  @param p_container_pk1_value value 1 for container's primary key
   *  @param p_container_pk2_value value 2 for container's primary key
   *  @param p_container_pk3_value value 3 for container's primary key
   *  @param p_container_pk4_value value 4 for container's primary key
   *  @param p_container_pk5_value value 5 for container's primary key
   *  @param p_commit              Indicates whether to commit or not at the end
   *                               of procedure
   *  @param p_api_version         standard parm - API Version
   *  @param p_init_msg_list       standard parm - Initialize message list
   *  @param x_return_status       standard parm - Return Status
   *  @param x_msg_count           standard parm - Message Count
   *  @param x_msg_data            standard parm - Message Data
   *
   *  @rep:displayname establish_inheritance
   *
   */
  PROCEDURE establish_inheritance(
    p_instance_object_id     IN  NUMBER
    ,p_instance_pk1_value    IN  VARCHAR2
    ,p_instance_pk2_value    IN  VARCHAR2
    ,p_instance_pk3_value    IN  VARCHAR2
    ,p_instance_pk4_value    IN  VARCHAR2
    ,p_instance_pk5_value    IN  VARCHAR2
    ,p_container_object_id   IN  NUMBER
    ,p_container_pk1_value   IN  VARCHAR2
    ,p_container_pk2_value   IN  VARCHAR2
    ,p_container_pk3_value   IN  VARCHAR2
    ,p_container_pk4_value   IN  VARCHAR2
    ,p_container_pk5_value   IN  VARCHAR2
    ,p_commit                IN  VARCHAR2
    ,p_api_version           IN  NUMBER
    ,p_init_msg_list         IN  VARCHAR2
    ,x_return_status         OUT NOCOPY VARCHAR2
    ,x_msg_count             OUT NOCOPY NUMBER
    ,x_msg_data              OUT NOCOPY VARCHAR2
  ) AS
  BEGIN
    establish_inheritance(
      p_instance_object_id     => p_instance_object_id
      ,p_instance_pk1_value    => p_instance_pk1_value
      ,p_instance_pk2_value    => p_instance_pk2_value
      ,p_instance_pk3_value    => p_instance_pk3_value
      ,p_instance_pk4_value    => p_instance_pk4_value
      ,p_instance_pk5_value    => p_instance_pk5_value
      ,p_container_object_id   => p_container_object_id
      ,p_container_pk1_value   => p_container_pk1_value
      ,p_container_pk2_value   => p_container_pk2_value
      ,p_container_pk3_value   => p_container_pk3_value
      ,p_container_pk4_value   => p_container_pk4_value
      ,p_container_pk5_value   => p_container_pk5_value
      ,p_inheritance_type      => NULL
      ,p_commit                => p_commit
      ,p_api_version           => p_api_Version
      ,p_init_msg_list         => p_init_msg_list
      ,x_return_status         => x_return_status
      ,x_msg_count             => x_msg_count
      ,x_msg_data              => x_msg_data
    );
  EXCEPTION
    WHEN OTHERS THEN
      RAISE;
  END establish_inheritance;

  /*#
   *  It Resets all permissions, and makes the instance to inherit
   *  all permissions from parent. This procedure gets called when
   *  in the UI the user selects "Inherit"
   *
   *  @param p_instance_object_id  ID for object definition id found in FND_OBJECTS
   *                               for this particular instance
   *  @param p_instance_pk1_value  value 1 for instance's primary key
   *  @param p_instance_pk2_value  value 2 for instance's primary key
   *  @param p_instance_pk3_value  value 3 for instance's primary key
   *  @param p_instance_pk4_value  value 4 for instance's primary key
   *  @param p_instance_pk5_value  value 5 for instance's primary key
   *  @param p_commit              Indicates whether to commit or not at the end
   *                               of procedure
   *  @param p_api_version         standard parm - API Version
   *  @param p_init_msg_list       standard parm - Initialize message list
   *  @param x_return_status       standard parm - Return Status
   *  @param x_msg_count           standard parm - Message Count
   *  @param x_msg_data            standard parm - Message Data
   *
   *  @rep:displayname reset_permissions
   *
   */
  PROCEDURE reset_permissions(
    p_instance_object_id     IN NUMBER
    ,p_instance_pk1_value    IN VARCHAR2
    ,p_instance_pk2_value    IN VARCHAR2 DEFAULT NULL
    ,p_instance_pk3_value    IN VARCHAR2 DEFAULT NULL
    ,p_instance_pk4_value    IN VARCHAR2 DEFAULT NULL
    ,p_instance_pk5_value    IN VARCHAR2 DEFAULT NULL
    ,p_commit                IN  VARCHAR2 DEFAULT FND_API.g_false
    ,p_api_version           IN  NUMBER   DEFAULT 1.0
    ,p_init_msg_list         IN  VARCHAR2 DEFAULT fnd_api.g_false
    ,x_return_status         OUT NOCOPY VARCHAR2
    ,x_msg_count             OUT NOCOPY NUMBER
    ,x_msg_data              OUT NOCOPY VARCHAR2
  ) AS
    l_rowid                       ROWID;
    --******** local variable for standards **********
    l_api_name                    CONSTANT VARCHAR2(30)   := 'reset_permissions';
    l_api_version                 CONSTANT NUMBER := 1.0;
    -- IBC_object_grant_groups
    l_object_grant_group_rowid    ROWID;
    l_object_grant_group_id       NUMBER;
    l_old_grant_group_id          NUMBER;
    l_grant_group_id              NUMBER;
    l_inherited_flag              VARCHAR2(2);
    l_inherited_from              NUMBER;
    l_inheritance_type            VARCHAR2(30);
    l_default_inheritance_type    VARCHAR2(30);
  BEGIN
    SAVEPOINT svpt_reset_permissions;

    -- ******* Standard Begins ********
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (
              l_api_version,
              p_api_version,
              l_api_name,
              G_PKG_NAME)
    THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;

    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Begin

    IF IBC_DEBUG_PVT.debug_enabled THEN
      IBC_DEBUG_PVT.start_process(
         p_proc_type  => 'PROCEDURE',
         p_proc_name  => 'Reset_Permissions',
         p_parms      => IBC_DEBUG_PVT.make_parameter_list(
                           p_tag     => 'PARAMETERS',
                           p_parms   => JTF_VARCHAR2_TABLE_4000(
                                          'p_instance_object_id', p_instance_object_id,
                                          'p_instance_pk1_value', p_instance_pk1_value,
                                          'p_instance_pk2_value', p_instance_pk2_value,
                                          'p_instance_pk3_value', p_instance_pk3_value,
                                          'p_instance_pk4_value', p_instance_pk4_value,
                                          'p_instance_pk5_value', p_instance_pk5_value,
                                          'p_commit', p_commit,
                                          'p_api_version', p_api_version,
                                          'p_init_msg_list', p_init_msg_list
                                        )
                           )
      );
    END IF;


    -- Fetch object's grant group Info
    get_object_grant_group_info(
      p_instance_object_id     => p_instance_object_id
      ,p_instance_pk1_value    => p_instance_pk1_value
      ,p_instance_pk2_value    => p_instance_pk2_value
      ,p_instance_pk3_value    => p_instance_pk3_value
      ,p_instance_pk4_value    => p_instance_pk4_value
      ,p_instance_pk5_value    => p_instance_pk5_value
      ,x_rowid                 => l_object_grant_group_rowid
      ,x_object_grant_group_id => l_object_grant_group_id
      ,x_grant_group_id        => l_grant_group_id
      ,x_inherited_flag        => l_inherited_flag
      ,x_inherited_from        => l_inherited_from
      ,x_inheritance_type      => l_inheritance_type
    );

    -- Only update if not currently inheriting and it is inheriting from
    -- a container
    IF l_inherited_flag = 'N' and l_inherited_from IS NOT NULL THEN
      -- Removing all permissions for grant group
      DELETE FROM ibc_grants
       WHERE grant_group_id = l_grant_group_id;
      -- Remove grant group
      DELETE FROM ibc_grant_groups
       WHERE grant_group_id = l_grant_group_id;
      -- Sets inherited_flag to Y and points to grant group from container
      UPDATE ibc_object_grant_groups
         SET inherited_flag = 'Y',
             grant_group_id = (SELECT grant_group_id
                                 FROM ibc_object_grant_groups
                                WHERE object_grant_group_id = l_inherited_from)
       WHERE object_grant_group_id
             IN ( SELECT object_grant_group_id
                    FROM ibc_object_grant_groups
                   WHERE grant_group_id = l_grant_group_id);
    END IF;

    -- COMMIT?
    IF (p_commit = FND_API.g_true) THEN
        COMMIT;
    END IF;

    -- Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                p_data  => x_msg_data);

    IF IBC_DEBUG_PVT.debug_enabled THEN
      IBC_DEBUG_PVT.end_process(
        IBC_DEBUG_PVT.make_parameter_list(
          p_tag    => 'OUTPUT',
          p_parms  => JTF_VARCHAR2_TABLE_4000(
                        'x_return_status', x_return_status,
                        'x_msg_count', x_msg_count,
                        'x_msg_data', x_msg_data
                      )
        )
      );
    END IF;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO svpt_reset_permissions;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                                p_data  => x_msg_data);
      IBC_UTILITIES_PVT.HANDLE_EXCEPTIONS(
          P_API_NAME => L_API_NAME
          ,P_PKG_NAME => G_PKG_NAME
          ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
          ,P_PACKAGE_TYPE => IBC_UTILITIES_PVT.G_PVT
          ,P_SQLCODE => SQLCODE
          ,P_SQLERRM => SQLERRM
          ,X_MSG_COUNT => X_MSG_COUNT
          ,X_MSG_DATA => X_MSG_DATA
          ,X_RETURN_STATUS => X_RETURN_STATUS
      );
      IF IBC_DEBUG_PVT.debug_enabled THEN
        IBC_DEBUG_PVT.end_process(
          IBC_DEBUG_PVT.make_parameter_list(
            p_tag    => 'OUTPUT',
            p_parms  => JTF_VARCHAR2_TABLE_4000(
                          'x_return_status', x_return_status,
                          'x_msg_count', x_msg_count,
                          'x_msg_data', x_msg_data
                        )
          )
        );
      END IF;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO svpt_reset_permissions;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                                p_data  => x_msg_data);
      IBC_UTILITIES_PVT.HANDLE_EXCEPTIONS(
               P_API_NAME => L_API_NAME
               ,P_PKG_NAME => G_PKG_NAME
               ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
               ,P_PACKAGE_TYPE => IBC_UTILITIES_PVT.G_PVT
               ,P_SQLCODE => SQLCODE
               ,P_SQLERRM => SQLERRM
               ,X_MSG_COUNT => X_MSG_COUNT
               ,X_MSG_DATA => X_MSG_DATA
               ,X_RETURN_STATUS => X_RETURN_STATUS
           );
      IF IBC_DEBUG_PVT.debug_enabled THEN
        IBC_DEBUG_PVT.end_process(
          IBC_DEBUG_PVT.make_parameter_list(
            p_tag    => 'OUTPUT',
            p_parms  => JTF_VARCHAR2_TABLE_4000(
                          'x_return_status', x_return_status,
                          'x_msg_count', x_msg_count,
                          'x_msg_data', x_msg_data
                        )
          )
        );
      END IF;
    WHEN OTHERS THEN
      ROLLBACK TO svpt_reset_permissions;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
        FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
      END IF;
      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                                p_data  => x_msg_data);
      IBC_UTILITIES_PVT.HANDLE_EXCEPTIONS(
               P_API_NAME => L_API_NAME
               ,P_PKG_NAME => G_PKG_NAME
               ,P_EXCEPTION_LEVEL => IBC_UTILITIES_PVT.G_EXC_OTHERS
               ,P_PACKAGE_TYPE => IBC_UTILITIES_PVT.G_PVT
               ,P_SQLCODE => SQLCODE
               ,P_SQLERRM => SQLERRM
               ,X_MSG_COUNT => X_MSG_COUNT
               ,X_MSG_DATA => X_MSG_DATA
               ,X_RETURN_STATUS => X_RETURN_STATUS
          );
      IF IBC_DEBUG_PVT.debug_enabled THEN
        IBC_DEBUG_PVT.end_process(
          IBC_DEBUG_PVT.make_parameter_list(
            p_tag    => 'OUTPUT',
            p_parms  => JTF_VARCHAR2_TABLE_4000(
                          'x_return_status', x_return_status,
                          'x_msg_count', x_msg_count,
                          'x_msg_data', x_msg_data
                        )
          )
        );
      END IF;
  END reset_permissions;

  /*#
   *  It breaks inheritance of an instance form its parent, and copies
   *  all permissions from container with the intention of "isolating"
   *  instance's permissions from any modification to its container's
   *  permissions.  This procedure gets called from UI when User clicks
   *  on "Override", and it is useful so even though the user doesn't
   *  make any other modification, the inheritance is already broken
   *  and can be saved as such.
   *
   *  @param p_instance_object_id  ID for object definition id found in FND_OBJECTS
   *                               for this particular instance
   *  @param p_instance_pk1_value  value 1 for instance's primary key
   *  @param p_instance_pk2_value  value 2 for instance's primary key
   *  @param p_instance_pk3_value  value 3 for instance's primary key
   *  @param p_instance_pk4_value  value 4 for instance's primary key
   *  @param p_instance_pk5_value  value 5 for instance's primary key
   *  @param p_commit              Indicates whether to commit or not at the end
   *                               of procedure
   *  @param p_api_version         standard parm - API Version
   *  @param p_init_msg_list       standard parm - Initialize message list
   *  @param x_return_status       standard parm - Return Status
   *  @param x_msg_count           standard parm - Message Count
   *  @param x_msg_data            standard parm - Message Data
   *
   *  @rep:displayname override_permissions
   *
   */
  PROCEDURE override_permissions(
    p_instance_object_id     IN NUMBER
    ,p_instance_pk1_value    IN VARCHAR2
    ,p_instance_pk2_value    IN VARCHAR2 DEFAULT NULL
    ,p_instance_pk3_value    IN VARCHAR2 DEFAULT NULL
    ,p_instance_pk4_value    IN VARCHAR2 DEFAULT NULL
    ,p_instance_pk5_value    IN VARCHAR2 DEFAULT NULL
    ,p_commit                IN  VARCHAR2 DEFAULT FND_API.g_false
    ,p_api_version           IN  NUMBER   DEFAULT 1.0
    ,p_init_msg_list         IN  VARCHAR2 DEFAULT fnd_api.g_false
    ,x_return_status         OUT NOCOPY VARCHAR2
    ,x_msg_count             OUT NOCOPY NUMBER
    ,x_msg_data              OUT NOCOPY VARCHAR2
  ) AS
    l_rowid                       ROWID;
    --******** local variable for standards **********
    l_api_name                    CONSTANT VARCHAR2(30)   := 'override_permissions';
    l_api_version                 CONSTANT NUMBER := 1.0;
    -- IBC_object_grant_groups
    l_object_grant_group_rowid    ROWID;
    l_object_grant_group_id       NUMBER;
    l_grant_group_id              NUMBER;
    l_inherited_flag              VARCHAR2(2);
    l_inherited_from              NUMBER;
    l_inheritance_type            VARCHAR2(30);
    l_old_grant_group_id          NUMBER;
    -- IBC_object_grant_groups
    l_c_object_grant_group_rowid  ROWID;
    l_c_object_grant_group_id     NUMBER;
    l_c_grant_group_id            NUMBER;
    l_c_inherited_flag            VARCHAR2(2);
    l_c_inherited_from            NUMBER;
    l_c_inheritance_type          VARCHAR2(30);

    CURSOR c_ogg(p_object_grant_group_id NUMBER) IS
      SELECT object_id,
             instance_pk1_value,
             instance_pk2_value,
             instance_pk3_value,
             instance_pk4_value,
             instance_pk5_value
        FROM ibc_object_grant_groups
       WHERE object_grant_group_id = p_object_grant_group_id;

    -- Cursor to apply/propagate changes for ObjectGrantGroups with same old grant group id
    CURSOR c_ogg_tree_update (p_object_grant_group_id NUMBER,
                              p_grant_group_id NUMBER) IS
      SELECT ogg.*
        FROM ibc_object_grant_groups ogg
       WHERE grant_group_id = p_grant_group_id
         AND inherited_flag = 'Y'
     CONNECT BY PRIOR object_grant_group_id = inherited_from
       START WITH inherited_from = p_object_grant_group_id;

    r_ogg     c_ogg%ROWTYPE;

  BEGIN
    SAVEPOINT svpt_override_permissions;

    -- ******* Standard Begins ********
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (
              l_api_version,
              p_api_version,
              l_api_name,
              G_PKG_NAME)
    THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;

    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Begin

    IF IBC_DEBUG_PVT.debug_enabled THEN
      IBC_DEBUG_PVT.start_process(
         p_proc_type  => 'PROCEDURE',
         p_proc_name  => 'Override_Permissions',
         p_parms      => IBC_DEBUG_PVT.make_parameter_list(
                           p_tag     => 'PARAMETERS',
                           p_parms   => JTF_VARCHAR2_TABLE_4000(
                                          'p_instance_object_id', p_instance_object_id,
                                          'p_instance_pk1_value', p_instance_pk1_value,
                                          'p_instance_pk2_value', p_instance_pk2_value,
                                          'p_instance_pk3_value', p_instance_pk3_value,
                                          'p_instance_pk4_value', p_instance_pk4_value,
                                          'p_instance_pk5_value', p_instance_pk5_value,
                                          'p_commit', p_commit,
                                          'p_api_version', p_api_version,
                                          'p_init_msg_list', p_init_msg_list
                                        )
                           )
      );
    END IF;

    -- Fetch object's grant group Info
    get_object_grant_group_info(
      p_instance_object_id     => p_instance_object_id
      ,p_instance_pk1_value    => p_instance_pk1_value
      ,p_instance_pk2_value    => p_instance_pk2_value
      ,p_instance_pk3_value    => p_instance_pk3_value
      ,p_instance_pk4_value    => p_instance_pk4_value
      ,p_instance_pk5_value    => p_instance_pk5_value
      ,x_rowid                 => l_object_grant_group_rowid
      ,x_object_grant_group_id => l_object_grant_group_id
      ,x_grant_group_id        => l_grant_group_id
      ,x_inherited_flag        => l_inherited_flag
      ,x_inherited_from        => l_inherited_from
      ,x_inheritance_type      => l_inheritance_type
    );

    IF l_inheritance_type = 'FOLDER' AND
       l_inherited_flag = 'Y'
    THEN

      OPEN c_ogg(l_inherited_from);
      FETCH c_ogg INTO r_ogg;

      IF c_ogg%FOUND THEN

        l_old_grant_group_id := l_grant_group_id;

        -- Create Row in IBC_grant_groups
        SELECT ibc_grant_groups_s1.nextval
          INTO l_grant_group_id
          FROM dual;
        IBC_GRANT_GROUPS_PKG.insert_row(
          px_rowid                 => l_rowid
          ,p_grant_group_id        => l_grant_group_id
          ,p_object_version_number => 1
        );

        -- Update Row in IBC_object_grant_groups
        FOR r_data IN (SELECT object_grant_group_id,
                              object_version_number,
                              object_id,
                              inherited_from,
                              instance_pk1_value,
                              instance_pk2_value,
                              instance_pk3_value,
                              instance_pk4_value,
                              instance_pk5_value,
                              inheritance_type
                         FROM ibc_object_grant_groups
                        WHERE ROWID = l_object_grant_group_rowid)
        LOOP
          IBC_OBJECT_GRANT_GROUPS_PKG.update_row(
            p_object_grant_group_id   => r_data.object_grant_group_id
            ,p_object_version_number  => r_data.object_version_number
            ,p_grant_group_id         => l_grant_group_id
            ,p_object_id              => r_data.object_id
            ,p_inherited_flag         => 'N'
            ,p_inherited_from         => r_data.inherited_from
            ,p_instance_pk1_value     => r_data.instance_pk1_value
            ,p_instance_pk2_value     => r_data.instance_pk2_value
            ,p_instance_pk3_value     => r_data.instance_pk3_value
            ,p_instance_pk4_value     => r_data.instance_pk4_value
            ,p_instance_pk5_value     => r_data.instance_pk5_value
            ,p_inheritance_type       => r_data.inheritance_type
          );
        END LOOP;

        IBC_DEBUG_PVT.debug_message('** l_object_grant_group_id:' || l_object_grant_group_id ||
                                    ' l_old_grant_group_id: ' || l_old_grant_group_id);

        FOR r_tree_ogg IN c_ogg_tree_update (l_object_grant_group_id,
                                             l_old_grant_group_id)
        LOOP
          IBC_OBJECT_GRANT_GROUPS_PKG.update_row(
            p_object_grant_group_id   => r_tree_ogg.object_grant_group_id
            ,p_object_version_number  => r_tree_ogg.object_version_number
            ,p_grant_group_id         => l_grant_group_id
            ,p_object_id              => r_tree_ogg.object_id
            ,p_inherited_flag         => r_tree_ogg.inherited_flag
            ,p_inherited_from         => r_tree_ogg.inherited_from
            ,p_instance_pk1_value     => r_tree_ogg.instance_pk1_value
            ,p_instance_pk2_value     => r_tree_ogg.instance_pk2_value
            ,p_instance_pk3_value     => r_tree_ogg.instance_pk3_value
            ,p_instance_pk4_value     => r_tree_ogg.instance_pk4_value
            ,p_instance_pk5_value     => r_tree_ogg.instance_pk5_value
            ,p_inheritance_type       => r_tree_ogg.inheritance_type
          );
        END LOOP;

        -- Copy all rows From inherited from IBC_object_grant_groups
        FOR r_data IN (SELECT ibc_grants_s1.nextval grant_id,
                              object_id, permission_code, grantee_user_id,
                      	       grantee_resource_id, grantee_resource_type,
                              l_grant_group_id grant_group_id,
                              action, grant_level + 1 grant_level, cascade_flag
       	                 FROM ibc_grants
       	                WHERE grant_group_id = l_old_grant_group_id
       	                AND cascade_flag = IBC_UTILITIES_PVT.g_true)
        LOOP
          IBC_GRANTS_PKG.insert_row(
            PX_ROWID                   => l_rowid
            ,P_GRANT_ID                => r_data.grant_id
            ,P_PERMISSION_CODE         => r_data.permission_code
            ,P_GRANTEE_USER_ID         => r_data.grantee_user_id
            ,P_GRANTEE_RESOURCE_ID     => r_data.grantee_resource_id
            ,P_GRANTEE_RESOURCE_TYPE   => r_data.grantee_resource_type
            ,P_GRANT_GROUP_ID          => r_data.grant_group_id
            ,P_ACTION                  => r_data.action
            ,P_GRANT_LEVEL             => r_data.grant_level
            ,P_CASCADE_FLAG            => r_data.cascade_flag
            ,P_OBJECT_VERSION_NUMBER   => 1
            ,P_OBJECT_ID               => r_data.object_id
          );
        END LOOP;

      END IF;
      CLOSE c_ogg;

    END IF;

    -- COMMIT?
    IF (p_commit = FND_API.g_true) THEN
        COMMIT;
    END IF;

    -- Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                p_data  => x_msg_data);

    IF IBC_DEBUG_PVT.debug_enabled THEN
      IBC_DEBUG_PVT.end_process(
        IBC_DEBUG_PVT.make_parameter_list(
          p_tag    => 'OUTPUT',
          p_parms  => JTF_VARCHAR2_TABLE_4000(
                        'x_return_status', x_return_status,
                        'x_msg_count', x_msg_count,
                        'x_msg_data', x_msg_data
                      )
        )
      );
    END IF;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO svpt_override_permissions;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                                p_data  => x_msg_data);
      IBC_UTILITIES_PVT.HANDLE_EXCEPTIONS(
          P_API_NAME => L_API_NAME
          ,P_PKG_NAME => G_PKG_NAME
          ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
          ,P_PACKAGE_TYPE => IBC_UTILITIES_PVT.G_PVT
          ,P_SQLCODE => SQLCODE
          ,P_SQLERRM => SQLERRM
          ,X_MSG_COUNT => X_MSG_COUNT
          ,X_MSG_DATA => X_MSG_DATA
          ,X_RETURN_STATUS => X_RETURN_STATUS
      );
      IF IBC_DEBUG_PVT.debug_enabled THEN
        IBC_DEBUG_PVT.end_process(
          IBC_DEBUG_PVT.make_parameter_list(
            p_tag    => 'OUTPUT',
            p_parms  => JTF_VARCHAR2_TABLE_4000(
                          'x_return_status', x_return_status,
                          'x_msg_count', x_msg_count,
                          'x_msg_data', x_msg_data
                        )
          )
        );
      END IF;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO svpt_override_permissions;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                                p_data  => x_msg_data);
      IBC_UTILITIES_PVT.HANDLE_EXCEPTIONS(
               P_API_NAME => L_API_NAME
               ,P_PKG_NAME => G_PKG_NAME
               ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
               ,P_PACKAGE_TYPE => IBC_UTILITIES_PVT.G_PVT
               ,P_SQLCODE => SQLCODE
               ,P_SQLERRM => SQLERRM
               ,X_MSG_COUNT => X_MSG_COUNT
               ,X_MSG_DATA => X_MSG_DATA
               ,X_RETURN_STATUS => X_RETURN_STATUS
           );
      IF IBC_DEBUG_PVT.debug_enabled THEN
        IBC_DEBUG_PVT.end_process(
          IBC_DEBUG_PVT.make_parameter_list(
            p_tag    => 'OUTPUT',
            p_parms  => JTF_VARCHAR2_TABLE_4000(
                          'x_return_status', x_return_status,
                          'x_msg_count', x_msg_count,
                          'x_msg_data', x_msg_data
                        )
          )
        );
      END IF;
    WHEN OTHERS THEN
      ROLLBACK TO svpt_override_permissions;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
        FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
      END IF;
      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                                p_data  => x_msg_data);
      IBC_UTILITIES_PVT.HANDLE_EXCEPTIONS(
               P_API_NAME => L_API_NAME
               ,P_PKG_NAME => G_PKG_NAME
               ,P_EXCEPTION_LEVEL => IBC_UTILITIES_PVT.G_EXC_OTHERS
               ,P_PACKAGE_TYPE => IBC_UTILITIES_PVT.G_PVT
               ,P_SQLCODE => SQLCODE
               ,P_SQLERRM => SQLERRM
               ,X_MSG_COUNT => X_MSG_COUNT
               ,X_MSG_DATA => X_MSG_DATA
               ,X_RETURN_STATUS => X_RETURN_STATUS
          );
      IF IBC_DEBUG_PVT.debug_enabled THEN
        IBC_DEBUG_PVT.end_process(
          IBC_DEBUG_PVT.make_parameter_list(
            p_tag    => 'OUTPUT',
            p_parms  => JTF_VARCHAR2_TABLE_4000(
                          'x_return_status', x_return_status,
                          'x_msg_count', x_msg_count,
                          'x_msg_data', x_msg_data
                        )
          )
        );
      END IF;
  END override_permissions;

  /*#
   *  Grants a permission on a particular object instance (or contained objects)
   *  to a user.
   *
   *  @param p_instance_object_id  ID for object definition id found in FND_OBJECTS
   *                               for this particular instance
   *  @param p_instance_pk1_value  value 1 for instance's primary key
   *  @param p_instance_pk2_value  value 2 for instance's primary key
   *  @param p_instance_pk3_value  value 3 for instance's primary key
   *  @param p_instance_pk4_value  value 4 for instance's primary key
   *  @param p_instance_pk5_value  value 5 for instance's primary key
   *  @param p_action              either ALLOW(permissions) or
   *                               RESTRICT (exclusions)
   *  @param p_permission_object_id Object ID of object which permission is
   *                                being granted
   *  @param p_permission_code     Permission being granted
   *  @param p_grantee_user_id     User receiving permission, If not especified it
   *                               means ANYBODY
   *  @param p_grantee_resource_id Resource Id
   *  @param p_grantee_resource_type Resource Type. Resource receiving permission
   *                                 if not especified it means ANYBODY
   *  @param p_container_object_id ID for object definition id found in FND_OBJECTS
   *                               for the container
   *  @param p_container_pk1_value value 1 for container's primary key
   *  @param p_container_pk2_value value 2 for container's primary key
   *  @param p_container_pk3_value value 3 for container's primary key
   *  @param p_container_pk4_value value 4 for container's primary key
   *  @param p_container_pk5_value value 5 for container's primary key
   *  @param p_cascade_flag        Indicates if permission should be carried over
   *                               to contained objects
   *  @param p_commit              Indicates whether to commit or not at the end
   *                               of procedure
   *  @param p_api_version         standard parm - API Version
   *  @param p_init_msg_list       standard parm - Initialize message list
   *  @param x_return_status       standard parm - Return Status
   *  @param x_msg_count           standard parm - Message Count
   *  @param x_msg_data            standard parm - Message Data
   *
   *  @rep:displayname grant_permission
   *
   */
  PROCEDURE grant_permission(
    p_instance_object_id     IN  NUMBER
    ,p_instance_pk1_value    IN  VARCHAR2
    ,p_instance_pk2_value    IN  VARCHAR2
    ,p_instance_pk3_value    IN  VARCHAR2
    ,p_instance_pk4_value    IN  VARCHAR2
    ,p_instance_pk5_value    IN  VARCHAR2
    ,p_action                IN  VARCHAR2
    ,p_permission_object_id  IN  NUMBER
    ,p_permission_code       IN  VARCHAR2
    ,p_grantee_user_id       IN  NUMBER
    ,p_grantee_resource_id   IN  NUMBER
    ,p_grantee_resource_type IN  VARCHAR2
    ,p_container_object_id   IN  NUMBER
    ,p_container_pk1_value   IN  VARCHAR2
    ,p_container_pk2_value   IN  VARCHAR2
    ,p_container_pk3_value   IN  VARCHAR2
    ,p_container_pk4_value   IN  VARCHAR2
    ,p_container_pk5_value   IN  VARCHAR2
    ,p_cascade_flag          IN  VARCHAR2
    ,p_commit                IN  VARCHAR2
    ,p_api_version           IN  NUMBER
    ,p_init_msg_list         IN  VARCHAR2
    ,x_return_status         OUT NOCOPY VARCHAR2
    ,x_msg_count             OUT NOCOPY NUMBER
    ,x_msg_data              OUT NOCOPY VARCHAR2
  ) AS
    TYPE cursorType IS REF CURSOR;
    c_object_grant_group        cursorType;
    c_chk_data                  cursorType;
    l_statement                 VARCHAR2(4096);
    l_rowid                     ROWID;
    l_grant_id                  NUMBER;
    l_dummy                     VARCHAR2(30);
    --******** local variable for standards **********
    l_api_name                  CONSTANT VARCHAR2(30)   := 'establish_inheritance';
    l_api_version               CONSTANT NUMBER := 1.0;
    -- Object Definition
    l_nbr_pk_cols               NUMBER;
    l_fmt_col_lst               VARCHAR2(4096);
    l_object_definition         c_object%ROWTYPE;
    -- IBC_object_grant_groups
    l_object_grant_group_rowid  ROWID;
    l_object_grant_group_id     NUMBER;
    l_old_grant_group_id        NUMBER;
    l_grant_group_id            NUMBER;
    l_inherited_flag            VARCHAR2(2);
    l_inherited_from            NUMBER;
    l_inheritance_type          VARCHAR2(30);
    -- IBC_object_grant_groups
    l_c_object_grant_group_rowid ROWID;
    l_c_object_grant_group_id   NUMBER;
    l_c_grant_group_id          NUMBER;
    l_c_inherited_flag          VARCHAR2(2);
    l_c_inherited_from          NUMBER;
    l_c_inheritance_type        VARCHAR2(30);

    -- Cursor to apply/propagate changes
    CURSOR c_object_grant_group_tree (p_object_grant_group_id NUMBER) IS
      SELECT LEVEL - 1 grant_level, ogg.*
        FROM ibc_object_grant_groups ogg
     CONNECT BY PRIOR object_grant_group_id = inherited_from
                  AND p_cascade_flag = IBC_UTILITIES_PVT.g_true
       START WITH object_grant_group_id = p_object_grant_group_id;

    -- Cursor to apply/propagate changes for ObjectGrantGroups with same old grant group id
    CURSOR c_ogg_tree_update (p_object_grant_group_id NUMBER,
                              p_grant_group_id NUMBER) IS
      SELECT ogg.*
        FROM ibc_object_grant_groups ogg
       WHERE grant_group_id = p_grant_group_id
         AND inherited_flag = 'Y'
     CONNECT BY PRIOR object_grant_group_id = inherited_from
                  AND p_cascade_flag = IBC_UTILITIES_PVT.g_true
       START WITH inherited_from = p_object_grant_group_id;


    -- Cursor to check if permission code belongs to permission_object_id
    CURSOR c_chk_permission_code(p_lookup_type VARCHAR2,
                                 p_permission_code VARCHAR2) IS
      SELECT 'X'
        FROM fnd_lookup_values
       WHERE lookup_type = p_lookup_type
         AND lookup_code = p_permission_code
         AND enabled_flag = 'Y'
         AND language = USERENV('lang')
         AND SYSDATE BETWEEN NVL(start_date_active, SYSDATE)
                         AND NVL(end_date_active, SYSDATE);

  BEGIN
    SAVEPOINT svpt_grant_permission;
    -- ******* Standard Begins ********
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (
              l_api_version,
              p_api_version,
              l_api_name,
              G_PKG_NAME)
    THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;

    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Begin


    IF IBC_DEBUG_PVT.debug_enabled THEN
      IBC_DEBUG_PVT.start_process(
         p_proc_type  => 'PROCEDURE',
         p_proc_name  => 'Grant_Permission',
         p_parms      => IBC_DEBUG_PVT.make_parameter_list(
                           p_tag     => 'PARAMETERS',
                           p_parms   => JTF_VARCHAR2_TABLE_4000(
                                          'p_instance_object_id', p_instance_object_id,
                                          'p_instance_pk1_value', p_instance_pk1_value,
                                          'p_instance_pk2_value', p_instance_pk2_value,
                                          'p_instance_pk3_value', p_instance_pk3_value,
                                          'p_instance_pk4_value', p_instance_pk4_value,
                                          'p_instance_pk5_value', p_instance_pk5_value,
                                          'p_action', p_action,
                                          'p_permission_object_id', p_permission_object_id,
                                          'p_permission_code', p_permission_code,
                                          'p_grantee_user_id', p_grantee_user_id,
                                          'p_grantee_resource_id', p_grantee_resource_id,
                                          'p_grantee_resource_type', p_grantee_resource_type,
                                          'p_container_object_id', p_container_object_id,
                                          'p_container_pk1_value', p_container_pk1_value,
                                          'p_container_pk2_value', p_container_pk2_value,
                                          'p_container_pk3_value', p_container_pk3_value,
                                          'p_container_pk4_value', p_container_pk4_value,
                                          'p_container_pk5_value', p_container_pk5_value,
                                          'p_cascade_flag', p_cascade_flag,
                                          'p_commit', p_commit,
                                          'p_api_version', p_api_version,
                                          'p_init_msg_list', p_init_msg_list
                                        )
                           )
      );

    END IF;


    -- Validate action
    IF p_action NOT IN ('ALLOW', 'RESTRICT') THEN
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
        FND_MESSAGE.Set_Name('IBC', 'INVALID_PERMISSION_ACTION');
        FND_MSG_PUB.ADD;
      END IF;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- Validate permission code for a particular object
    OPEN c_chk_permission_code(get_perms_lookup_type(p_permission_object_id),
                               p_permission_code);
    FETCH c_chk_permission_code INTO l_dummy;
    IF c_chk_permission_code%NOTFOUND THEN
      CLOSE c_chk_permission_code;
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
        FND_MESSAGE.Set_Name('IBC', 'INVALID_PERMISSION_FOR_OBJECT');
        FND_MESSAGE.Set_token('PERMISSION_CODE', p_permission_code);
        FND_MESSAGE.Set_token('PERMISSION_OBJECT_ID', p_permission_object_id);
        FND_MSG_PUB.ADD;
      END IF;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    CLOSE c_chk_permission_code;

    -- Fetch object's grant group Info
    get_object_grant_group_info(
      p_instance_object_id     => p_instance_object_id
      ,p_instance_pk1_value    => p_instance_pk1_value
      ,p_instance_pk2_value    => p_instance_pk2_value
      ,p_instance_pk3_value    => p_instance_pk3_value
      ,p_instance_pk4_value    => p_instance_pk4_value
      ,p_instance_pk5_value    => p_instance_pk5_value
      ,x_rowid                 => l_object_grant_group_rowid
      ,x_object_grant_group_id => l_object_grant_group_id
      ,x_grant_group_id        => l_grant_group_id
      ,x_inherited_flag        => l_inherited_flag
      ,x_inherited_from        => l_inherited_from
      ,x_inheritance_type      => l_inheritance_type
    );

    -- IF inheritance type is WSFOLDER then a grant is not allowed for this object
    -- it needs to be done at the container WORKSPACE
    IF l_inheritance_type = 'WSFOLDER' THEN
      FND_MESSAGE.Set_Name('IBC', 'IBC_WSFOLDER_NO_GRANT_ALLOWED');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF l_object_grant_group_id IS NULL OR
       l_inherited_flag = 'Y'
    THEN
      l_old_grant_group_id := l_grant_group_id;
      -- Create Row in IBC_grant_groups
      SELECT ibc_grant_groups_s1.nextval
        INTO l_grant_group_id
       	FROM dual;
      IBC_GRANT_GROUPS_PKG.insert_row(
        px_rowid                 => l_rowid
        ,p_grant_group_id        => l_grant_group_id
        ,p_object_version_number => 1
      );
      IF l_object_grant_group_id IS NULL THEN
        SELECT ibc_object_grant_groups_s1.nextval
          INTO l_object_grant_group_id
  	       FROM dual;
        IF p_container_object_id IS NOT NULL THEN
          -- Fetch object's grant group info for Container
          get_object_grant_group_info(
            p_instance_object_id     => p_container_object_id
            ,p_instance_pk1_value    => p_container_pk1_value
            ,p_instance_pk2_value    => p_container_pk2_value
            ,p_instance_pk3_value    => p_container_pk3_value
            ,p_instance_pk4_value    => p_container_pk4_value
            ,p_instance_pk5_value    => p_container_pk5_value
            ,x_rowid                 => l_c_object_grant_group_rowid
            ,x_object_grant_group_id => l_c_object_grant_group_id
            ,x_grant_group_id        => l_c_grant_group_id
            ,x_inherited_flag        => l_c_inherited_flag
            ,x_inherited_from        => l_c_inherited_from
            ,x_inheritance_type      => l_c_inheritance_type
          );

          -- IF inheritance type is WSFOLDER then a grant is not allowed for this object
          -- it needs to be done at the container WORKSPACE
          IF l_c_inheritance_type IN ('WORKSPACE', 'WSFOLDER') THEN
            FND_MESSAGE.Set_Name('IBC', 'IBC_WSFOLDER_NO_GRANT_ALLOWED');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
          END IF;

          -- Copy all rows from container object
       	  -- It doesn't check for cascading at this point
          FOR r_data IN (SELECT ibc_grants_s1.nextval grant_id,
                                object_id, permission_code, grantee_user_id,
               	                grantee_resource_id, grantee_resource_type,
                                l_grant_group_id grant_group_id,
                      	         action, grant_level + 1 grant_level, cascade_flag
                      	    FROM ibc_grants
                      	   WHERE grant_group_id = l_c_grant_group_id)
          LOOP
            IBC_GRANTS_PKG.insert_row(
              PX_ROWID                   => l_rowid
              ,P_GRANT_ID                => r_data.grant_id
              ,P_PERMISSION_CODE         => r_data.permission_code
              ,P_GRANTEE_USER_ID         => r_data.grantee_user_id
              ,P_GRANTEE_RESOURCE_ID     => r_data.grantee_resource_id
              ,P_GRANTEE_RESOURCE_TYPE   => r_data.grantee_resource_type
              ,P_GRANT_GROUP_ID          => r_data.grant_group_id
              ,P_ACTION                  => r_data.action
              ,P_GRANT_LEVEL             => r_data.grant_level
              ,P_CASCADE_FLAG            => r_data.cascade_flag
              ,P_OBJECT_VERSION_NUMBER   => 1
              ,P_OBJECT_ID               => r_data.object_id
            );
          END LOOP;
       	END IF;
        -- Create Row in IBC_object_grant_groups
        IBC_OBJECT_GRANT_GROUPS_PKG.insert_row(
          px_rowid                 => l_rowid
          ,p_object_grant_group_id => l_object_grant_group_id
          ,p_object_version_number => 1
          ,p_grant_group_id        => l_grant_group_id
          ,p_object_id             => p_instance_object_id
          ,p_inherited_flag        => 'N'
          ,p_inherited_from        => l_c_object_grant_group_id
          ,p_instance_pk1_value    => p_instance_pk1_value
          ,p_instance_pk2_value    => p_instance_pk2_value
          ,p_instance_pk3_value    => p_instance_pk3_value
          ,p_instance_pk4_value    => p_instance_pk4_value
          ,p_instance_pk5_value    => p_instance_pk5_value
          ,p_inheritance_type      => l_c_inheritance_type
        );

      ELSE
        -- Update Row in IBC_object_grant_groups
        FOR r_data IN (SELECT object_grant_group_id,
                              object_version_number,
                              object_id,
                              inherited_from,
                              instance_pk1_value,
                              instance_pk2_value,
                              instance_pk3_value,
                              instance_pk4_value,
                              instance_pk5_value,
                              inheritance_type
                         FROM ibc_object_grant_groups
                        WHERE ROWID = l_object_grant_group_rowid)
        LOOP
          IBC_OBJECT_GRANT_GROUPS_PKG.update_row(
            p_object_grant_group_id   => r_data.object_grant_group_id
            ,p_object_version_number  => r_data.object_version_number
            ,p_grant_group_id         => l_grant_group_id
            ,p_object_id              => r_data.object_id
            ,p_inherited_flag         => 'N'
            ,p_inherited_from         => r_data.inherited_from
            ,p_instance_pk1_value     => r_data.instance_pk1_value
            ,p_instance_pk2_value     => r_data.instance_pk2_value
            ,p_instance_pk3_value     => r_data.instance_pk3_value
            ,p_instance_pk4_value     => r_data.instance_pk4_value
            ,p_instance_pk5_value     => r_data.instance_pk5_value
            ,p_inheritance_type       => r_data.inheritance_type
          );
        END LOOP;

        IBC_DEBUG_PVT.debug_message('** l_object_grant_group_id:' || l_object_grant_group_id ||
                                    ' l_old_grant_group_id: ' || l_old_grant_group_id);

        FOR r_ogg IN c_ogg_tree_update (l_object_grant_group_id,
                                        l_old_grant_group_id)
        LOOP
          IBC_OBJECT_GRANT_GROUPS_PKG.update_row(
            p_object_grant_group_id   => r_ogg.object_grant_group_id
            ,p_object_version_number  => r_ogg.object_version_number
            ,p_grant_group_id         => l_grant_group_id
            ,p_object_id              => r_ogg.object_id
            ,p_inherited_flag         => r_ogg.inherited_flag
            ,p_inherited_from         => r_ogg.inherited_from
            ,p_instance_pk1_value     => r_ogg.instance_pk1_value
            ,p_instance_pk2_value     => r_ogg.instance_pk2_value
            ,p_instance_pk3_value     => r_ogg.instance_pk3_value
            ,p_instance_pk4_value     => r_ogg.instance_pk4_value
            ,p_instance_pk5_value     => r_ogg.instance_pk5_value
            ,p_inheritance_type       => r_ogg.inheritance_type
          );
        END LOOP;

      END IF;
      IF l_inherited_flag = 'Y' THEN
        -- Copy all rows From inherited from IBC_object_grant_groups
        FOR r_data IN (SELECT ibc_grants_s1.nextval grant_id,
                              object_id, permission_code, grantee_user_id,
                      	       grantee_resource_id, grantee_resource_type,
                              l_grant_group_id grant_group_id,
                              action, grant_level + 1 grant_level, cascade_flag
       	                 FROM ibc_grants
       	                WHERE grant_group_id = l_old_grant_group_id
       	                AND cascade_flag = IBC_UTILITIES_PVT.g_true)
        LOOP
          IBC_GRANTS_PKG.insert_row(
            PX_ROWID                   => l_rowid
            ,P_GRANT_ID                => r_data.grant_id
            ,P_PERMISSION_CODE         => r_data.permission_code
            ,P_GRANTEE_USER_ID         => r_data.grantee_user_id
            ,P_GRANTEE_RESOURCE_ID     => r_data.grantee_resource_id
            ,P_GRANTEE_RESOURCE_TYPE   => r_data.grantee_resource_type
            ,P_GRANT_GROUP_ID          => r_data.grant_group_id
            ,P_ACTION                  => r_data.action
            ,P_GRANT_LEVEL             => r_data.grant_level
            ,P_CASCADE_FLAG            => r_data.cascade_flag
            ,P_OBJECT_VERSION_NUMBER   => 1
            ,P_OBJECT_ID               => r_data.object_id
          );
        END LOOP;
      END IF;
    END IF;

    -- Check if there is a row already with the same information at current level
    l_statement := '  SELECT ''X'' ' ||
                   '    FROM ibc_grants ' ||
                   '   WHERE object_id = :p_permission_object_id ' ||
                   '     AND permission_code = :p_permission_code ' ||
                   '     AND grant_group_id = :p_grant_group_id ' ||
                   '     AND action = :p_action ' ||
                   '     AND grant_level = 0 ';
    IF p_grantee_user_id IS NOT NULL THEN
      l_statement := l_statement ||
                     ' AND grantee_user_id = :p_grantee_user_id ' ||
                     ' AND grantee_resource_id IS NULL ' ||
                     ' AND grantee_resource_type IS NULL ';
      OPEN c_chk_data FOR l_statement
	  USING p_permission_object_id, p_permission_code,
	        l_grant_group_id, p_action, p_grantee_user_id;
    ELSIF p_grantee_resource_id IS NOT NULL THEN
      l_statement := l_statement ||
                     ' AND grantee_resource_id = :p_grantee_user_id ' ||
                     ' AND grantee_resource_type = :p_grantee_resource_type ' ||
                     ' AND grantee_user_id IS NULL ';
      OPEN c_chk_data FOR l_statement
	  USING p_permission_object_id, p_permission_code,
	        l_grant_group_id, p_action, p_grantee_resourcE_id, p_grantee_resource_type;
    ELSE
      l_statement := l_statement ||
                     ' AND grantee_resource_id IS NULL ' ||
                     ' AND grantee_resource_type IS NULL ' ||
                     ' AND grantee_user_id IS NULL';
      OPEN c_chk_data FOR l_statement
	  USING p_permission_object_id, p_permission_code,
	        l_grant_group_id, p_action;
    END IF;

    FETCH c_chk_data INTO l_dummy;

    IF c_chk_data%NOTFOUND THEN
      -- Create and Propagate Row in IBC_GRANTS.
      FOR r_object_grant_group IN c_object_grant_group_tree(l_object_grant_group_id) LOOP
        --DBMS_OUTPUT.put_line(' inherited_flag:[' || r_object_grant_group.inherited_flag || ']' ||
                            -- ' grant_level:['|| r_object_grant_group.grant_level || ']' ||
                            -- ' inheritance_type:[' || r_object_grant_group.inheritance_type || ']');
        IF r_object_grant_group.inherited_flag = 'N' AND
           (r_object_grant_group.grant_level = 0 OR
            r_object_grant_group.inheritance_type = 'FULL')
        THEN
          SELECT ibc_grants_s1.nextval
            INTO l_grant_id
            FROM DUAL;
          IBC_GRANTS_PKG.insert_row(
            PX_ROWID                   => l_rowid
            ,P_GRANT_ID                => l_grant_id
            ,P_PERMISSION_CODE         => p_permission_code
            ,P_GRANTEE_USER_ID         => p_grantee_user_id
            ,P_GRANTEE_RESOURCE_ID     => p_grantee_resource_id
            ,P_GRANTEE_RESOURCE_TYPE   => p_grantee_resource_type
            ,P_GRANT_GROUP_ID          => r_object_grant_group.grant_group_id
            ,P_ACTION                  => p_action
            ,P_GRANT_LEVEL             => r_object_grant_group.grant_level
            ,P_CASCADE_FLAG            => p_cascade_flag
            ,P_OBJECT_VERSION_NUMBER   => 1
            ,P_OBJECT_ID               => p_permission_object_id
          );
        END IF;
      END LOOP;
    END IF;

    CLOSE c_chk_data;

    -- COMMIT?
    IF (p_commit = FND_API.g_true) THEN
        COMMIT;
    END IF;

    -- Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                p_data  => x_msg_data);

    IF IBC_DEBUG_PVT.debug_enabled THEN
      IBC_DEBUG_PVT.end_process(
        IBC_DEBUG_PVT.make_parameter_list(
          p_tag    => 'OUTPUT',
          p_parms  => JTF_VARCHAR2_TABLE_4000(
                        'x_return_status', x_return_status,
                        'x_msg_count', x_msg_count,
                        'x_msg_data', x_msg_data
                      )
        )
      );
    END IF;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO svpt_grant_permission;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                                p_data  => x_msg_data);
      IBC_UTILITIES_PVT.HANDLE_EXCEPTIONS(
          P_API_NAME => L_API_NAME
          ,P_PKG_NAME => G_PKG_NAME
          ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
          ,P_PACKAGE_TYPE => IBC_UTILITIES_PVT.G_PVT
          ,P_SQLCODE => SQLCODE
          ,P_SQLERRM => SQLERRM
          ,X_MSG_COUNT => X_MSG_COUNT
          ,X_MSG_DATA => X_MSG_DATA
          ,X_RETURN_STATUS => X_RETURN_STATUS
      );
      IF IBC_DEBUG_PVT.debug_enabled THEN
        IBC_DEBUG_PVT.end_process(
          IBC_DEBUG_PVT.make_parameter_list(
            p_tag    => 'OUTPUT',
            p_parms  => JTF_VARCHAR2_TABLE_4000(
                          'x_return_status', x_return_status,
                          'x_msg_count', x_msg_count,
                          'x_msg_data', x_msg_data
                        )
          )
        );
      END IF;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO svpt_grant_permission;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                                p_data  => x_msg_data);
      IBC_UTILITIES_PVT.HANDLE_EXCEPTIONS(
               P_API_NAME => L_API_NAME
               ,P_PKG_NAME => G_PKG_NAME
               ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
               ,P_PACKAGE_TYPE => IBC_UTILITIES_PVT.G_PVT
               ,P_SQLCODE => SQLCODE
               ,P_SQLERRM => SQLERRM
               ,X_MSG_COUNT => X_MSG_COUNT
               ,X_MSG_DATA => X_MSG_DATA
               ,X_RETURN_STATUS => X_RETURN_STATUS
           );
      IF IBC_DEBUG_PVT.debug_enabled THEN
        IBC_DEBUG_PVT.end_process(
          IBC_DEBUG_PVT.make_parameter_list(
            p_tag    => 'OUTPUT',
            p_parms  => JTF_VARCHAR2_TABLE_4000(
                          'x_return_status', x_return_status,
                          'x_msg_count', x_msg_count,
                          'x_msg_data', x_msg_data
                        )
          )
        );
      END IF;
    WHEN OTHERS THEN
      ROLLBACK TO svpt_grant_permission;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
        FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
      END IF;
      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                                p_data  => x_msg_data);
      IBC_UTILITIES_PVT.HANDLE_EXCEPTIONS(
               P_API_NAME => L_API_NAME
               ,P_PKG_NAME => G_PKG_NAME
               ,P_EXCEPTION_LEVEL => IBC_UTILITIES_PVT.G_EXC_OTHERS
               ,P_PACKAGE_TYPE => IBC_UTILITIES_PVT.G_PVT
               ,P_SQLCODE => SQLCODE
               ,P_SQLERRM => SQLERRM
               ,X_MSG_COUNT => X_MSG_COUNT
               ,X_MSG_DATA => X_MSG_DATA
               ,X_RETURN_STATUS => X_RETURN_STATUS
          );
      IF IBC_DEBUG_PVT.debug_enabled THEN
        IBC_DEBUG_PVT.end_process(
          IBC_DEBUG_PVT.make_parameter_list(
            p_tag    => 'OUTPUT',
            p_parms  => JTF_VARCHAR2_TABLE_4000(
                          'x_return_status', x_return_status,
                          'x_msg_count', x_msg_count,
                          'x_msg_data', x_msg_data
                        )
          )
        );
      END IF;
  END grant_permission;

  /*#
   *  Grants a permission on a particular object instance (or contained objects)
   *  to a user.
   *
   *  @param p_instance_object_id  ID for object definition id found in FND_OBJECTS
   *                               for this particular instance
   *  @param p_instance_pk1_value  value 1 for instance's primary key
   *  @param p_instance_pk2_value  value 2 for instance's primary key
   *  @param p_instance_pk3_value  value 3 for instance's primary key
   *  @param p_instance_pk4_value  value 4 for instance's primary key
   *  @param p_instance_pk5_value  value 5 for instance's primary key
   *  @param p_action              either ALLOW(permissions) or
   *                               RESTRICT (exclusions)
   *  @param p_permission_object_id Object ID of object which permission is
   *                                being granted
   *  @param p_permission_code     Permission being granted
   *  @param p_grantee_user_id     User receiving permission, If not especified it
   *                               means ANYBODY
   *  @param p_container_object_id ID for object definition id found in FND_OBJECTS
   *                               for the container
   *  @param p_container_pk1_value value 1 for container's primary key
   *  @param p_container_pk2_value value 2 for container's primary key
   *  @param p_container_pk3_value value 3 for container's primary key
   *  @param p_container_pk4_value value 4 for container's primary key
   *  @param p_container_pk5_value value 5 for container's primary key
   *  @param p_cascade_flag        Indicates if permission should be carried over
   *                               to contained objects
   *  @param p_commit              Indicates whether to commit or not at the end
   *                               of procedure
   *  @param p_api_version         standard parm - API Version
   *  @param p_init_msg_list       standard parm - Initialize message list
   *  @param x_return_status       standard parm - Return Status
   *  @param x_msg_count           standard parm - Message Count
   *  @param x_msg_data            standard parm - Message Data
   *
   *  @rep:displayname grant_permission
   *
   */
  PROCEDURE grant_permission(
    p_instance_object_id     IN NUMBER
    ,p_instance_pk1_value    IN VARCHAR2
    ,p_instance_pk2_value    IN VARCHAR2
    ,p_instance_pk3_value    IN VARCHAR2
    ,p_instance_pk4_value    IN VARCHAR2
    ,p_instance_pk5_value    IN VARCHAR2
    ,p_action                IN VARCHAR2
    ,p_permission_object_id  IN NUMBER
    ,p_permission_code       IN VARCHAR2
    ,p_grantee_user_id       IN NUMBER
    ,p_container_object_id   IN NUMBER
    ,p_container_pk1_value   IN VARCHAR2
    ,p_container_pk2_value   IN VARCHAR2
    ,p_container_pk3_value   IN VARCHAR2
    ,p_container_pk4_value   IN VARCHAR2
    ,p_container_pk5_value   IN VARCHAR2
    ,p_cascade_flag          IN VARCHAR2
    ,p_commit                IN VARCHAR2
    ,p_api_version           IN NUMBER
    ,p_init_msg_list         IN VARCHAR2
    ,x_return_status         OUT NOCOPY VARCHAR2
    ,x_msg_count             OUT NOCOPY NUMBER
    ,x_msg_data              OUT NOCOPY VARCHAR2
  ) AS
  BEGIN
    grant_permission(
      p_instance_object_id     => p_instance_object_id
      ,p_instance_pk1_value    => p_instance_pk1_value
      ,p_instance_pk2_value    => p_instance_pk2_value
      ,p_instance_pk3_value    => p_instance_pk3_value
      ,p_instance_pk4_value    => p_instance_pk4_value
      ,p_instance_pk5_value    => p_instance_pk5_value
      ,p_action                => p_action
      ,p_permission_object_id  => p_permission_object_id
      ,p_permission_code       => p_permission_code
      ,p_grantee_user_id       => p_grantee_user_id
      ,p_grantee_resource_id   => NULL
      ,p_grantee_resource_type => NULL
      ,p_container_object_id   => p_container_object_id
      ,p_container_pk1_value   => p_container_pk1_value
      ,p_container_pk2_value   => p_container_pk2_value
      ,p_container_pk3_value   => p_container_pk3_value
      ,p_container_pk4_value   => p_container_pk4_value
      ,p_container_pk5_value   => p_container_pk5_value
      ,p_cascade_flag          => p_cascade_flag
      ,p_commit                => p_commit
      ,p_api_version           => p_api_version
      ,p_init_msg_list         => p_init_msg_list
      ,x_return_status         => x_return_status
      ,x_msg_count             => x_msg_count
      ,x_msg_data              => x_msg_data
      );
  -- Exception Handler Added for NOCOPY Change (11/08/2002) By ENUNEZ
  EXCEPTION
    WHEN OTHERS THEN
      RAISE;
  END grant_permission;

  /*#
   *  Grants a permission on a particular object instance
   *  (or contained objects) to ANYBODY (if p_grantee_resource_id and
   *  type are not passed) or a particular resource.
   *
   *  @param p_instance_object_id  ID for object definition id found in FND_OBJECTS
   *                               for this particular instance
   *  @param p_instance_pk1_value  value 1 for instance's primary key
   *  @param p_instance_pk2_value  value 2 for instance's primary key
   *  @param p_instance_pk3_value  value 3 for instance's primary key
   *  @param p_instance_pk4_value  value 4 for instance's primary key
   *  @param p_instance_pk5_value  value 5 for instance's primary key
   *  @param p_action              either ALLOW(permissions) or
   *                               RESTRICT (exclusions)
   *  @param p_permission_object_id Object ID of object which permission is
   *                                being granted
   *  @param p_permission_code     Permission being granted
   *  @param p_grantee_resource_id Resource Id
   *  @param p_grantee_resource_type Resource Type. Resource receiving permission
   *                                 if not especified it means ANYBODY
   *  @param p_container_object_id ID for object definition id found in FND_OBJECTS
   *                               for the container
   *  @param p_container_pk1_value value 1 for container's primary key
   *  @param p_container_pk2_value value 2 for container's primary key
   *  @param p_container_pk3_value value 3 for container's primary key
   *  @param p_container_pk4_value value 4 for container's primary key
   *  @param p_container_pk5_value value 5 for container's primary key
   *  @param p_cascade_flag        Indicates if permission should be carried over
   *                               to contained objects
   *  @param p_commit              Indicates whether to commit or not at the end
   *                               of procedure
   *  @param p_api_version         standard parm - API Version
   *  @param p_init_msg_list       standard parm - Initialize message list
   *  @param x_return_status       standard parm - Return Status
   *  @param x_msg_count           standard parm - Message Count
   *  @param x_msg_data            standard parm - Message Data
   *
   *  @rep:displayname grant_permission
   *
   */
  PROCEDURE grant_permission(
    p_instance_object_id     IN NUMBER
    ,p_instance_pk1_value    IN VARCHAR2
    ,p_instance_pk2_value    IN VARCHAR2
    ,p_instance_pk3_value    IN VARCHAR2
    ,p_instance_pk4_value    IN VARCHAR2
    ,p_instance_pk5_value    IN VARCHAR2
    ,p_action                IN VARCHAR2
    ,p_permission_object_id  IN NUMBER
    ,p_permission_code       IN VARCHAR2
    ,p_grantee_resource_id   IN NUMBER
    ,p_grantee_resource_type IN VARCHAR2
    ,p_container_object_id   IN NUMBER
    ,p_container_pk1_value   IN VARCHAR2
    ,p_container_pk2_value   IN VARCHAR2
    ,p_container_pk3_value   IN VARCHAR2
    ,p_container_pk4_value   IN VARCHAR2
    ,p_container_pk5_value   IN VARCHAR2
    ,p_cascade_flag          IN VARCHAR2
    ,p_commit                IN  VARCHAR2
    ,p_api_version           IN  NUMBER
    ,p_init_msg_list         IN  VARCHAR2
    ,x_return_status         OUT NOCOPY VARCHAR2
    ,x_msg_count             OUT NOCOPY NUMBER
    ,x_msg_data              OUT NOCOPY VARCHAR2
  ) AS
  BEGIN
    grant_permission(
      p_instance_object_id     => p_instance_object_id
      ,p_instance_pk1_value    => p_instance_pk1_value
      ,p_instance_pk2_value    => p_instance_pk2_value
      ,p_instance_pk3_value    => p_instance_pk3_value
      ,p_instance_pk4_value    => p_instance_pk4_value
      ,p_instance_pk5_value    => p_instance_pk5_value
      ,p_action                => p_action
      ,p_permission_object_id  => p_permission_object_id
      ,p_permission_code       => p_permission_code
      ,p_grantee_user_id       => NULL
      ,p_grantee_resource_id   => p_grantee_resource_id
      ,p_grantee_resource_type => p_grantee_resource_type
      ,p_container_object_id   => p_container_object_id
      ,p_container_pk1_value   => p_container_pk1_value
      ,p_container_pk2_value   => p_container_pk2_value
      ,p_container_pk3_value   => p_container_pk3_value
      ,p_container_pk4_value   => p_container_pk4_value
      ,p_container_pk5_value   => p_container_pk5_value
      ,p_cascade_flag          => p_cascade_flag
      ,p_commit                => p_commit
      ,p_api_version           => p_api_version
      ,p_init_msg_list         => p_init_msg_list
      ,x_return_status         => x_return_status
      ,x_msg_count             => x_msg_count
      ,x_msg_data              => x_msg_data
      );
  -- Exception Handler Added for NOCOPY Change (11/08/2002) By ENUNEZ
  EXCEPTION
    WHEN OTHERS THEN
      RAISE;
  END grant_permission;

  /*#
   *  Revokes a especific permission already given, do not confuse this
   *  with a grant to RESTRICT a permission.
   *
   *  @param p_instance_object_id  ID for object definition id found in FND_OBJECTS
   *                               for this particular instance
   *  @param p_instance_pk1_value  value 1 for instance's primary key
   *  @param p_instance_pk2_value  value 2 for instance's primary key
   *  @param p_instance_pk3_value  value 3 for instance's primary key
   *  @param p_instance_pk4_value  value 4 for instance's primary key
   *  @param p_instance_pk5_value  value 5 for instance's primary key
   *  @param p_action              either ALLOW(permissions) or
   *                               RESTRICT (exclusions)
   *  @param p_permission_object_id Object ID of object to which permission was granted
   *  @param p_permission_code     Permission code
   *  @param p_grantee_user_id     User to which permission was originally granted,
   *                               if not especified it means ANYBODY
   *  @param p_grantee_resource_id Resource to which permission was originally
   *                               granted, if not especified it means ANYBODY
   *  @param p_grantee_resource_type Resource Type
   *  @param p_commit              Indicates whether to commit or not at the end
   *                               of procedure
   *  @param p_api_version         standard parm - API Version
   *  @param p_init_msg_list       standard parm - Initialize message list
   *  @param x_return_status       standard parm - Return Status
   *  @param x_msg_count           standard parm - Message Count
   *  @param x_msg_data            standard parm - Message Data
   *
   *  @rep:displayname revoke_permission
   *
   */
  PROCEDURE revoke_permission(
    p_instance_object_id     IN NUMBER
    ,p_instance_pk1_value    IN VARCHAR2
    ,p_instance_pk2_value    IN VARCHAR2
    ,p_instance_pk3_value    IN VARCHAR2
    ,p_instance_pk4_value    IN VARCHAR2
    ,p_instance_pk5_value    IN VARCHAR2
    ,p_action                IN VARCHAR2
    ,p_permission_object_id  IN NUMBER
    ,p_permission_code       IN VARCHAR2
    ,p_grantee_user_id       IN NUMBER
    ,p_grantee_resource_id   IN NUMBER
    ,p_grantee_resource_type IN VARCHAR2
    ,p_commit                IN VARCHAR2
    ,p_api_version           IN NUMBER
    ,p_init_msg_list         IN VARCHAR2
    ,x_return_status         OUT NOCOPY VARCHAR2
    ,x_msg_count             OUT NOCOPY NUMBER
    ,x_msg_data              OUT NOCOPY VARCHAR2
  ) AS
    l_statement                 VARCHAR2(4096);
    l_curr_statement            VARCHAR2(4096);
    l_chk_statement             VARCHAR2(4096);
    l_dummy                     VARCHAR2(2);
    l_count                     NUMBER;
    l_rowid                     ROWID;
    TYPE cursorType IS REF CURSOR;
    l_cursor                    cursorType;
    l_grant_id                  NUMBER;
    -- IBC_object_grant_groups
    l_object_grant_group_rowid  ROWID;
    l_object_grant_group_id     NUMBER;
    l_grant_group_id            NUMBER;
    l_new_grant_group_id        NUMBER;
    l_inherited_flag            VARCHAR2(2);
    l_inherited_from            NUMBER;
    l_inheritance_type          VARCHAR2(30);
    --******** local variable for standards **********
    l_api_name                    CONSTANT VARCHAR2(30)   := 'revoke_permission';
    l_api_version                 CONSTANT NUMBER := 1.0;
    -- Cursor to apply/propagate changes
    CURSOR c_object_grant_group (p_object_grant_group_id NUMBER) IS
      SELECT LEVEL - 1 grant_level, ogg.*
        FROM ibc_object_grant_groups ogg
     CONNECT BY PRIOR object_grant_group_id = inherited_from
       START WITH object_grant_group_id = p_object_grant_group_id
       ORDER BY 1 asc;
    -- Cursor to fetch a specific object's grant group
    CURSOR c_object_grant_group_by_id(p_object_grant_group_id NUMBER) IS
      SELECT *
        FROM ibc_object_grant_groups
       WHERE object_grant_group_id = p_object_grant_group_id;
    r_object_grant_group_by_id         c_object_grant_group_by_id%ROWTYPE;
    -- Cursor to Check if object's grant group is still associated to a grant bundle id
    CURSOR c_object_grant_groups(p_grant_group_id NUMBER) IS
      SELECT 'X'
        FROM ibc_object_grant_groups
       WHERE grant_group_id = p_grant_group_id;
    -- Cursor for grants to check if there's need for branch of grants
    CURSOR c_grants(p_grant_group_id NUMBER, p_inheritance_type VARCHAR2) IS
      SELECT *
        FROM ibc_grants
       WHERE grant_group_id = p_grant_group_id
         AND (grant_level = 0 OR p_inheritance_type <> 'FULL');
    r_grant               c_grants%ROWTYPE;

  BEGIN
    SAVEPOINT svpt_revoke_permission;
    -- ******* Standard Begins ********
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (
              l_api_version,
              p_api_version,
              l_api_name,
              G_PKG_NAME)
    THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;

    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Begin


    IF IBC_DEBUG_PVT.debug_enabled THEN
      IBC_DEBUG_PVT.start_process(
         p_proc_type  => 'PROCEDURE',
         p_proc_name  => 'Revoke_Permission',
         p_parms      => IBC_DEBUG_PVT.make_parameter_list(
                           p_tag     => 'PARAMETERS',
                           p_parms   => JTF_VARCHAR2_TABLE_4000(
                                          'p_instance_object_id', p_instance_object_id,
                                          'p_instance_pk1_value', p_instance_pk1_value,
                                          'p_instance_pk2_value', p_instance_pk2_value,
                                          'p_instance_pk3_value', p_instance_pk3_value,
                                          'p_instance_pk4_value', p_instance_pk4_value,
                                          'p_instance_pk5_value', p_instance_pk5_value,
                                          'p_action', p_action,
                                          'p_permission_object_id', p_permission_object_id,
                                          'p_permission_code', p_permission_code,
                                          'p_grantee_user_id', p_grantee_user_id,
                                          'p_grantee_resource_id', p_grantee_resource_id,
                                          'p_grantee_resource_type', p_grantee_resource_type,
                                          'p_commit', p_commit,
                                          'p_api_version', p_api_version,
                                          'p_init_msg_list', p_init_msg_list
                                        )
                           )
      );
    END IF;

    -- Fetch object's grant group Info
    get_object_grant_group_info(
      p_instance_object_id     => p_instance_object_id
      ,p_instance_pk1_value    => p_instance_pk1_value
      ,p_instance_pk2_value    => p_instance_pk2_value
      ,p_instance_pk3_value    => p_instance_pk3_value
      ,p_instance_pk4_value    => p_instance_pk4_value
      ,p_instance_pk5_value    => p_instance_pk5_value
      ,x_rowid                 => l_object_grant_group_rowid
      ,x_object_grant_group_id => l_object_grant_group_id
      ,x_grant_group_id        => l_grant_group_id
      ,x_inherited_flag        => l_inherited_flag
      ,x_inherited_from        => l_inherited_from
      ,x_inheritance_type      => l_inheritance_type
    );
    IBC_DEBUG_PVT.debug_message('GRANT_GROUP_ROWID=' || l_object_grant_group_rowid);

    IF l_object_grant_group_rowid IS NOT NULL THEN


      l_statement := '  SELECT grant_id ' ||
                     '    FROM ibc_grants ' ||
                     '   WHERE object_id = :p_permission_object_id ' ||
                     '     AND permission_code = :p_permission_code ' ||
                     '     AND action = :p_action ';
      IF p_grantee_user_id IS NOT NULL THEN
        l_statement := l_statement ||
                       ' AND grantee_user_id = :p_grantee_user_id ' ||
                       ' AND grantee_resource_id IS NULL ' ||
                       ' AND grantee_resource_type IS NULL ';
      ELSIF p_grantee_resource_id IS NOT NULL THEN
        l_statement := l_statement ||
                       ' AND grantee_resource_id = :p_grantee_user_id ' ||
                       ' AND grantee_resource_type = :p_grantee_resource_type ' ||
                       ' AND grantee_user_id IS NULL ';
      ELSE
        l_statement := l_statement ||
                       ' AND grantee_resource_id IS NULL ' ||
                       ' AND grantee_resource_type IS NULL ' ||
                       ' AND grantee_user_id IS NULL ';
      END IF;

      -- If inheriting Copy permissions from parent
      IF l_inherited_flag = 'Y' THEN
        l_chk_statement := l_statement ||
                           ' AND grant_group_id = :p_grant_group_id ';

        IF p_grantee_user_id IS NOT NULL THEN
          OPEN l_cursor FOR l_chk_statement
		  USING p_permission_object_id, p_permission_code, p_action,
		        p_grantee_user_id, l_grant_group_id;
        ELSIF p_grantee_resource_id IS NOT NULL THEN
          OPEN l_cursor FOR l_chk_statement
		  USING p_permission_object_id, p_permission_code, p_action,
		        p_grantee_resource_id, p_grantee_resource_type,
				l_grant_group_id;
        ELSE
          OPEN l_cursor FOR l_chk_statement
		  USING p_permission_object_id, p_permission_code, p_action,
		        l_grant_group_id;
        END IF;

        FETCH l_cursor INTO l_grant_id;
        IF l_cursor%FOUND THEN

          -- Create Row in IBC_grant_groups
          SELECT ibc_grant_groups_s1.nextval
            INTO l_new_grant_group_id
           	FROM dual;
          IBC_GRANT_GROUPS_PKG.insert_row(
            px_rowid                 => l_rowid
            ,p_grant_group_id        => l_new_grant_group_id
            ,p_object_version_number => 1
          );

          -- Copy all rows From inherited from IBC_object_grant_groups
          FOR r_data IN (SELECT ibc_grants_s1.nextval grant_id,
                                object_id, permission_code, grantee_user_id,
                        	       grantee_resource_id, grantee_resource_type,
                                l_new_grant_group_id grant_group_id,
                                action, grant_level + 1 grant_level, cascade_flag
         	                 FROM ibc_grants
         	                WHERE grant_group_id = l_grant_group_id)
          LOOP
            IBC_GRANTS_PKG.insert_row(
              PX_ROWID                   => l_rowid
              ,P_GRANT_ID                => r_data.grant_id
              ,P_PERMISSION_CODE         => r_data.permission_code
              ,P_GRANTEE_USER_ID         => r_data.grantee_user_id
              ,P_GRANTEE_RESOURCE_ID     => r_data.grantee_resource_id
              ,P_GRANTEE_RESOURCE_TYPE   => r_data.grantee_resource_type
              ,P_GRANT_GROUP_ID          => r_data.grant_group_id
              ,P_ACTION                  => r_data.action
              ,P_GRANT_LEVEL             => r_data.grant_level
              ,P_CASCADE_FLAG            => r_data.cascade_flag
              ,P_OBJECT_VERSION_NUMBER   => 1
              ,P_OBJECT_ID               => r_data.object_id
            );
          END LOOP;

        -- Update Row in IBC_object_grant_groups
        FOR r_data IN (SELECT object_grant_group_id,
                              object_version_number,
                              object_id,
                              inherited_from,
                              instance_pk1_value,
                              instance_pk2_value,
                              instance_pk3_value,
                              instance_pk4_value,
                              instance_pk5_value,
                              inheritance_type
                         FROM ibc_object_grant_groups
                        WHERE ROWID = l_object_grant_group_rowid)

          LOOP
            IBC_OBJECT_GRANT_GROUPS_PKG.update_row(
              p_object_grant_group_id   => r_data.object_grant_group_id
              ,p_object_version_number  => r_data.object_version_number
              ,p_grant_group_id         => l_new_grant_group_id
              ,p_object_id              => r_data.object_id
              ,p_inherited_flag         => 'N'
              ,p_inherited_from         => r_data.inherited_from
              ,p_instance_pk1_value     => r_data.instance_pk1_value
              ,p_instance_pk2_value     => r_data.instance_pk2_value
              ,p_instance_pk3_value     => r_data.instance_pk3_value
              ,p_instance_pk4_value     => r_data.instance_pk4_value
              ,p_instance_pk5_value     => r_data.instance_pk5_value
              ,p_inheritance_type       => r_data.inheritance_type
            );
          END LOOP;

          l_inherited_flag := 'N';
          l_grant_group_id := l_new_grant_group_id;

        END IF;
        CLOSE l_cursor;
      END IF;
      -- Actual removal of grants
      FOR r_object_grant_group in c_object_grant_group(l_object_grant_group_id) LOOP

       	l_curr_statement := l_statement ||
       	                    '  AND grant_group_id = :p_grant_group_id ';
        IF r_object_grant_group.inheritance_type = 'FULL' THEN
         	l_curr_statement := l_statement ||
         			                  '  AND grant_level = :p_grant_level';
        ELSIF r_object_grant_group.grant_level > 0 THEN
          EXIT;
        END IF;
        IBC_DEBUG_PVT.debug_message(l_curr_statement);
        l_count := 0;

        IF p_grantee_user_id IS NOT NULL THEN
          IF r_object_grant_group.inheritance_type = 'FULL' THEN
            OPEN l_cursor FOR l_curr_statement
  		    USING p_permission_object_id, p_permission_code, p_action,
  		          p_grantee_user_id, r_object_grant_group.grant_group_id,
				  r_object_grant_group.grant_level;
  		  ELSE
            OPEN l_cursor FOR l_curr_statement
  		    USING p_permission_object_id, p_permission_code, p_action,
  		          p_grantee_user_id, r_object_grant_group.grant_group_id;
  		  END IF;
        ELSIF p_grantee_resource_id IS NOT NULL THEN
          IF r_object_grant_group.inheritance_type = 'FULL' THEN
            OPEN l_cursor FOR l_curr_statement
  		    USING p_permission_object_id, p_permission_code, p_action,
  		          p_grantee_resource_id, p_grantee_resource_type,
				  r_object_grant_group.grant_group_id,
				  r_object_grant_group.grant_level;
  		  ELSE
            OPEN l_cursor FOR l_curr_statement
  		    USING p_permission_object_id, p_permission_code, p_action,
  		          p_grantee_resource_id, p_grantee_resource_type,
				  r_object_grant_group.grant_group_id;
  		  END IF;
        ELSE
          IF r_object_grant_group.inheritance_type = 'FULL' THEN
            OPEN l_cursor FOR l_curr_statement
  		    USING p_permission_object_id, p_permission_code, p_action,
  		          r_object_grant_group.grant_group_id,
				  r_object_grant_group.grant_level;
  		  ELSE
            OPEN l_cursor FOR l_curr_statement
  		    USING p_permission_object_id, p_permission_code, p_action,
  		          r_object_grant_group.grant_group_id;
  		  END IF;
        END IF;

        LOOP
          IBC_DEBUG_PVT.debug_message('LOOP');
          FETCH l_cursor INTO l_grant_id;
          EXIT WHEN l_cursor%NOTFOUND;
          l_count := l_count + 1;
          IBC_GRANTS_PKG.delete_row(l_grant_id);
        END LOOP;
        CLOSE l_cursor;
       	IF l_count > 0 THEN
       	  OPEN c_grants(r_object_grant_group.grant_group_id, r_object_grant_group.inheritance_type);
       	  FETCH c_grants into r_grant;
       	  IF c_grants%NOTFOUND THEN
       	    -- Remove grants if not grants at this level in case of FULL inheritance type
            FOR r_data IN (SELECT grant_id
                             FROM ibc_grants
                            WHERE grant_group_id = r_object_grant_group.grant_group_id)
            LOOP
              IBC_GRANTS_PKG.delete_row(r_data.grant_id);
            END LOOP;
       	    -- Fetch Parent
       	    OPEN c_object_grant_group_by_id(r_object_grant_group.inherited_from);
       	    FETCH c_object_grant_group_by_id INTO r_object_grant_group_by_id;
      	     CLOSE c_object_grant_group_by_id;
       	    -- Remove grant object's grant group if parent object_id
       	    -- it's not the same as current object_id
       	    -- it means no danger to break the inheritance
       	    IF r_object_grant_group_by_id.object_id <> r_object_grant_group.object_id THEN
              IBC_OBJECT_GRANT_GROUPS_PKG.delete_row(r_object_grant_group.object_grant_group_id);
       	    ELSIF r_object_grant_group.inherited_from IS NOT NULL AND
                  r_object_grant_group.inheritance_type = 'FULL' -- Added to fix bug# 3392944
            THEN
	             -- Update grant object's grant group to inherit from container
              SELECT grant_group_id
                INTO l_grant_group_id
                FROM ibc_object_grant_groups
               WHERE object_grant_group_id = r_object_grant_group.inherited_from;
              IBC_OBJECT_GRANT_GROUPS_PKG.update_row(
                p_object_grant_group_id  => r_object_grant_group.object_grant_group_id
                ,p_object_version_number => r_object_grant_group.object_version_number
                ,p_grant_group_id        => l_grant_group_id
                ,p_object_id             => r_object_grant_group.object_id
                ,p_inherited_flag        => 'Y'
                ,p_inherited_from        => r_object_grant_group.inherited_from
                ,p_instance_pk1_value    => r_object_grant_group.instance_pk1_value
                ,p_instance_pk2_value    => r_object_grant_group.instance_pk2_value
                ,p_instance_pk3_value    => r_object_grant_group.instance_pk3_value
                ,p_instance_pk4_value    => r_object_grant_group.instance_pk4_value
                ,p_instance_pk5_value    => r_object_grant_group.instance_pk5_value
                ,p_inheritance_type      => r_object_grant_group.inheritance_type
              );
       	    END IF;
       	    -- Remove Grant Bundle if not in use anymore
       	    OPEN c_object_grant_groups(r_object_grant_group.grant_group_id);
       	    FETCH c_object_grant_groups INTO l_dummy;
      	     IF c_object_grant_groups%NOTFOUND THEN
              IBC_GRANT_GROUPS_PKG.delete_row(r_object_grant_group.grant_group_id);
       	    END IF;
       	    CLOSE c_object_grant_groups;
       	  END IF;
       	  CLOSE c_grants;
        END IF;
      END LOOP;
    END IF;
    -- COMMIT?
    IF (p_commit = FND_API.g_true) THEN
        COMMIT;
    END IF;

    -- Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                p_data  => x_msg_data);

    IF IBC_DEBUG_PVT.debug_enabled THEN
      IBC_DEBUG_PVT.end_process(
        IBC_DEBUG_PVT.make_parameter_list(
          p_tag    => 'OUTPUT',
          p_parms  => JTF_VARCHAR2_TABLE_4000(
                        'x_return_status', x_return_status,
                        'x_msg_count', x_msg_count,
                        'x_msg_data', x_msg_data
                      )
        )
      );
    END IF;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO svpt_revoke_permission;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                                p_data  => x_msg_data);
      IBC_UTILITIES_PVT.HANDLE_EXCEPTIONS(
          P_API_NAME => L_API_NAME
          ,P_PKG_NAME => G_PKG_NAME
          ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
          ,P_PACKAGE_TYPE => IBC_UTILITIES_PVT.G_PVT
          ,P_SQLCODE => SQLCODE
          ,P_SQLERRM => SQLERRM
          ,X_MSG_COUNT => X_MSG_COUNT
          ,X_MSG_DATA => X_MSG_DATA
          ,X_RETURN_STATUS => X_RETURN_STATUS
      );
      IF IBC_DEBUG_PVT.debug_enabled THEN
        IBC_DEBUG_PVT.end_process(
          IBC_DEBUG_PVT.make_parameter_list(
            p_tag    => 'OUTPUT',
            p_parms  => JTF_VARCHAR2_TABLE_4000(
                          'x_return_status', x_return_status,
                          'x_msg_count', x_msg_count,
                          'x_msg_data', x_msg_data
                        )
          )
        );
      END IF;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO svpt_revoke_permission;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                                p_data  => x_msg_data);
      IBC_UTILITIES_PVT.HANDLE_EXCEPTIONS(
               P_API_NAME => L_API_NAME
               ,P_PKG_NAME => G_PKG_NAME
               ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
               ,P_PACKAGE_TYPE => IBC_UTILITIES_PVT.G_PVT
               ,P_SQLCODE => SQLCODE
               ,P_SQLERRM => SQLERRM
               ,X_MSG_COUNT => X_MSG_COUNT
               ,X_MSG_DATA => X_MSG_DATA
               ,X_RETURN_STATUS => X_RETURN_STATUS
           );
      IF IBC_DEBUG_PVT.debug_enabled THEN
        IBC_DEBUG_PVT.end_process(
          IBC_DEBUG_PVT.make_parameter_list(
            p_tag    => 'OUTPUT',
            p_parms  => JTF_VARCHAR2_TABLE_4000(
                          'x_return_status', x_return_status,
                          'x_msg_count', x_msg_count,
                          'x_msg_data', x_msg_data
                        )
          )
        );
      END IF;
    WHEN OTHERS THEN
      ROLLBACK TO svpt_revoke_permission;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
        FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
      END IF;
      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                                p_data  => x_msg_data);
      IBC_UTILITIES_PVT.HANDLE_EXCEPTIONS(
               P_API_NAME => L_API_NAME
               ,P_PKG_NAME => G_PKG_NAME
               ,P_EXCEPTION_LEVEL => IBC_UTILITIES_PVT.G_EXC_OTHERS
               ,P_PACKAGE_TYPE => IBC_UTILITIES_PVT.G_PVT
               ,P_SQLCODE => SQLCODE
               ,P_SQLERRM => SQLERRM
               ,X_MSG_COUNT => X_MSG_COUNT
               ,X_MSG_DATA => X_MSG_DATA
               ,X_RETURN_STATUS => X_RETURN_STATUS
          );
      IF IBC_DEBUG_PVT.debug_enabled THEN
        IBC_DEBUG_PVT.end_process(
          IBC_DEBUG_PVT.make_parameter_list(
            p_tag    => 'OUTPUT',
            p_parms  => JTF_VARCHAR2_TABLE_4000(
                          'x_return_status', x_return_status,
                          'x_msg_count', x_msg_count,
                          'x_msg_data', x_msg_data
                        )
          )
        );
      END IF;
  END revoke_permission;

  /*#
   *  Revokes a especific permission already given, do not confuse this
   *  with a grant to RESTRICT a permission.
   *
   *  @param p_instance_object_id  ID for object definition id found in FND_OBJECTS
   *                               for this particular instance
   *  @param p_instance_pk1_value  value 1 for instance's primary key
   *  @param p_instance_pk2_value  value 2 for instance's primary key
   *  @param p_instance_pk3_value  value 3 for instance's primary key
   *  @param p_instance_pk4_value  value 4 for instance's primary key
   *  @param p_instance_pk5_value  value 5 for instance's primary key
   *  @param p_action              either ALLOW(permissions) or
   *                               RESTRICT (exclusions)
   *  @param p_permission_object_id Object ID of object to which permission was granted
   *  @param p_permission_code     Permission code
   *  @param p_grantee_user_id     User to which permission was originally granted,
   *                               if not especified it means ANYBODY
   *  @param p_commit              Indicates whether to commit or not at the end
   *                               of procedure
   *  @param p_api_version         standard parm - API Version
   *  @param p_init_msg_list       standard parm - Initialize message list
   *  @param x_return_status       standard parm - Return Status
   *  @param x_msg_count           standard parm - Message Count
   *  @param x_msg_data            standard parm - Message Data
   *
   *  @rep:displayname revoke_permission
   *
   */
  PROCEDURE revoke_permission(
    p_instance_object_id     IN NUMBER
    ,p_instance_pk1_value    IN VARCHAR2
    ,p_instance_pk2_value    IN VARCHAR2
    ,p_instance_pk3_value    IN VARCHAR2
    ,p_instance_pk4_value    IN VARCHAR2
    ,p_instance_pk5_value    IN VARCHAR2
    ,p_action                IN VARCHAR2
    ,p_permission_object_id  IN NUMBER
    ,p_permission_code       IN VARCHAR2
    ,p_grantee_user_id       IN NUMBER
    ,p_commit                IN VARCHAR2
    ,p_api_version           IN NUMBER
    ,p_init_msg_list         IN VARCHAR2
    ,x_return_status         OUT NOCOPY VARCHAR2
    ,x_msg_count             OUT NOCOPY NUMBER
    ,x_msg_data              OUT NOCOPY VARCHAR2
  ) AS
  BEGIN
    revoke_permission(
      p_instance_object_id     => p_instance_object_id
      ,p_instance_pk1_value    => p_instance_pk1_value
      ,p_instance_pk2_value    => p_instance_pk2_value
      ,p_instance_pk3_value    => p_instance_pk3_value
      ,p_instance_pk4_value    => p_instance_pk4_value
      ,p_instance_pk5_value    => p_instance_pk5_value
      ,p_action                => p_action
      ,p_permission_object_id  => p_permission_object_id
      ,p_permission_code       => p_permission_code
      ,p_grantee_user_id       => p_grantee_user_id
      ,p_grantee_resource_id   => NULL
      ,p_grantee_resource_type => NULL
      ,p_commit                => p_commit
      ,p_api_version           => p_api_version
      ,p_init_msg_list         => p_init_msg_list
      ,x_return_status         => x_return_status
      ,x_msg_count             => x_msg_count
      ,x_msg_data              => x_msg_data
    );
  -- Exception Handler Added for NOCOPY Change (11/08/2002) By ENUNEZ
  EXCEPTION
    WHEN OTHERS THEN
      RAISE;
  END revoke_permission;

  /*#
   *  Revokes a especific permission already given, do not confuse this
   *  with a grant to RESTRICT a permission.
   *
   *  @param p_instance_object_id  ID for object definition id found in FND_OBJECTS
   *                               for this particular instance
   *  @param p_instance_pk1_value  value 1 for instance's primary key
   *  @param p_instance_pk2_value  value 2 for instance's primary key
   *  @param p_instance_pk3_value  value 3 for instance's primary key
   *  @param p_instance_pk4_value  value 4 for instance's primary key
   *  @param p_instance_pk5_value  value 5 for instance's primary key
   *  @param p_action              either ALLOW(permissions) or
   *                               RESTRICT (exclusions)
   *  @param p_permission_object_id Object ID of object to which permission was granted
   *  @param p_permission_code     Permission code
   *  @param p_grantee_resource_id Resource to which permission was originally
   *                               granted, if not especified it means ANYBODY
   *  @param p_grantee_resource_type Resource Type
   *  @param p_commit              Indicates whether to commit or not at the end
   *                               of procedure
   *  @param p_api_version         standard parm - API Version
   *  @param p_init_msg_list       standard parm - Initialize message list
   *  @param x_return_status       standard parm - Return Status
   *  @param x_msg_count           standard parm - Message Count
   *  @param x_msg_data            standard parm - Message Data
   *
   *  @rep:displayname revoke_permission
   *
   */
  PROCEDURE revoke_permission(
    p_instance_object_id     IN NUMBER
    ,p_instance_pk1_value    IN VARCHAR2
    ,p_instance_pk2_value    IN VARCHAR2
    ,p_instance_pk3_value    IN VARCHAR2
    ,p_instance_pk4_value    IN VARCHAR2
    ,p_instance_pk5_value    IN VARCHAR2
    ,p_action                IN VARCHAR2
    ,p_permission_object_id  IN NUMBER
    ,p_permission_code       IN VARCHAR2
    ,p_grantee_resource_id   IN NUMBER
    ,p_grantee_resource_type IN VARCHAR2
    ,p_commit                IN  VARCHAR2
    ,p_api_version           IN  NUMBER
    ,p_init_msg_list         IN  VARCHAR2
    ,x_return_status         OUT NOCOPY VARCHAR2
    ,x_msg_count             OUT NOCOPY NUMBER
    ,x_msg_data              OUT NOCOPY VARCHAR2
  ) AS
  BEGIN
    revoke_permission(
      p_instance_object_id     => p_instance_object_id
      ,p_instance_pk1_value    => p_instance_pk1_value
      ,p_instance_pk2_value    => p_instance_pk2_value
      ,p_instance_pk3_value    => p_instance_pk3_value
      ,p_instance_pk4_value    => p_instance_pk4_value
      ,p_instance_pk5_value    => p_instance_pk5_value
      ,p_action                => p_action
      ,p_permission_object_id  => p_permission_object_id
      ,p_permission_code       => p_permission_code
      ,p_grantee_user_id       => NULL
      ,p_grantee_resource_id   => p_grantee_resource_id
      ,p_grantee_resource_type => p_grantee_resource_type
      ,p_commit                => p_commit
      ,p_api_version           => p_api_version
      ,p_init_msg_list         => p_init_msg_list
      ,x_return_status         => x_return_status
      ,x_msg_count             => x_msg_count
      ,x_msg_data              => x_msg_data
    );
  -- Exception Handler Added for NOCOPY Change (11/08/2002) By ENUNEZ
  EXCEPTION
    WHEN OTHERS THEN
      RAISE;
  END revoke_permission;

  /*#
   *  Checks whether an user has a particular permission on an
   *  object instance
   *
   *  @param p_instance_object_id  ID for object definition id found in FND_OBJECTS
   *                               for this particular instance
   *  @param p_instance_pk1_value  value 1 for instance's primary key
   *  @param p_instance_pk2_value  value 2 for instance's primary key
   *  @param p_instance_pk3_value  value 3 for instance's primary key
   *  @param p_instance_pk4_value  value 4 for instance's primary key
   *  @param p_instance_pk5_value  value 5 for instance's primary key
   *  @param p_permission_code     Permission Code
   *  @param p_container_pk1_value value 1 for container's primary key
   *  @param p_container_pk2_value value 2 for container's primary key
   *  @param p_container_pk3_value value 3 for container's primary key
   *  @param p_container_pk4_value value 4 for container's primary key
   *  @param p_container_pk5_value value 5 for container's primary key
   *  @param p_current_user_id     Current User Id
   *  @return Whether user has (FND_API.g_true) or not (FND_API.g_false) such
   *          permission
   *
   *  @rep:displayname has_permission
   *
   */
  FUNCTION has_permission(
    p_instance_object_id     IN NUMBER
    ,p_instance_pk1_value    IN VARCHAR2
    ,p_instance_pk2_value    IN VARCHAR2
    ,p_instance_pk3_value    IN VARCHAR2
    ,p_instance_pk4_value    IN VARCHAR2
    ,p_instance_pk5_value    IN VARCHAR2
    ,p_permission_code       IN VARCHAR2
    ,p_container_object_id   IN NUMBER
    ,p_container_pk1_value   IN VARCHAR2
    ,p_container_pk2_value   IN VARCHAR2
    ,p_container_pk3_value   IN VARCHAR2
    ,p_container_pk4_value   IN VARCHAR2
    ,p_container_pk5_value   IN VARCHAR2
    ,p_current_user_id       IN NUMBER
  ) RETURN VARCHAR2 AS
    l_result                    VARCHAR2(30);
    -- Permission variables
    l_action                    VARCHAR2(30);
    -- IBC_object_grant_groups
    l_object_grant_group_rowid  ROWID;
    l_object_grant_group_id     NUMBER;
    l_grant_group_id            NUMBER;
    l_inherited_flag            VARCHAR2(2);
    l_inherited_from            NUMBER;
    l_inheritance_type          VARCHAR2(30);
    -- Cursor for a specific permission
    CURSOR c_permission(p_grant_group_id NUMBER
                        ,p_inherited_flag VARCHAR2
                        ,p_inheritance_type VARCHAR2)
    IS
      SELECT action
        FROM ibc_grants
       WHERE object_id = p_instance_object_id
         AND permission_code = p_permission_code
       	 AND grant_group_id = p_grant_group_id
       	 AND (p_inherited_flag = 'N'
       	      OR cascade_flag = IBC_UTILITIES_PVT.g_true
       	     )
       	 AND ((grantee_user_id IS NULL AND grantee_resource_id IS NULL) OR
       	      (IBC_UTILITIES_PVT.Check_Current_User(grantee_user_id,
       	                   grantee_resource_id, grantee_resource_type,
                           p_current_user_id) = 'TRUE')
             )
       ORDER BY DECODE(p_inheritance_type, 'FOLDER', 0, 'HIDDEN-FOLDER', 0, grant_level) asc,
                DECODE(grantee_resource_type,
                       'RESPONSIBILITY', 2,
                       'RS_GROUP', 2,
                       'GROUP', 2,
                       DECODE(grantee_user_id, NULL, 3, 1)),
                action;

  BEGIN

    IF IBC_DEBUG_PVT.debug_enabled THEN
      IBC_DEBUG_PVT.start_process(
         p_proc_type  => 'PROCEDURE',
         p_proc_name  => 'has_permission',
         p_parms      => IBC_DEBUG_PVT.make_parameter_list(
                           p_tag     => 'PARAMETERS',
                           p_parms   => JTF_VARCHAR2_TABLE_4000(
                                          'p_instance_object_id', p_instance_object_id,
                                          'p_instance_pk1_value', p_instance_pk1_value,
                                          'p_instance_pk2_value', p_instance_pk2_value,
                                          'p_instance_pk3_value', p_instance_pk3_value,
                                          'p_instance_pk4_value', p_instance_pk4_value,
                                          'p_instance_pk5_value', p_instance_pk5_value,
                                          'p_permission_code', p_permission_code,
                                          'p_container_object_id', p_container_object_id,
                                          'p_container_pk1_value', p_container_pk1_value,
                                          'p_container_pk2_value', p_container_pk2_value,
                                          'p_container_pk3_value', p_container_pk3_value,
                                          'p_container_pk4_value', p_container_pk4_value,
                                          'p_container_pk5_value', p_container_pk5_value,
                                          'p_current_user_id', p_current_user_id
                                        )
                           )
      );
    END IF;


    IF Fnd_Profile.Value_specific('IBC_USE_ACCESS_CONTROL',-999,-999,-999) = 'Y' THEN
      l_result := FND_API.g_false;
      -- Fetch object's grant group Info
      get_object_grant_group_info(
        p_instance_object_id     => p_instance_object_id
        ,p_instance_pk1_value    => p_instance_pk1_value
        ,p_instance_pk2_value    => p_instance_pk2_value
        ,p_instance_pk3_value    => p_instance_pk3_value
        ,p_instance_pk4_value    => p_instance_pk4_value
        ,p_instance_pk5_value    => p_instance_pk5_value
        ,x_rowid                 => l_object_grant_group_rowid
        ,x_object_grant_group_id => l_object_grant_group_id
        ,x_grant_group_id        => l_grant_group_id
        ,x_inherited_flag        => l_inherited_flag
        ,x_inherited_from        => l_inherited_from
        ,x_inheritance_type      => l_inheritance_type
      );
      IF l_object_grant_group_rowid IS NULL AND
         NVL(l_inheritance_type, 'FOLDER') <> 'HIDDEN-FOLDER'
      THEN
        -- Fetch object's grant group Info for container object
        get_object_grant_group_info(
          p_instance_object_id     => p_container_object_id
          ,p_instance_pk1_value    => p_container_pk1_value
          ,p_instance_pk2_value    => p_container_pk2_value
          ,p_instance_pk3_value    => p_container_pk3_value
          ,p_instance_pk4_value    => p_container_pk4_value
          ,p_instance_pk5_value    => p_container_pk5_value
          ,x_rowid                 => l_object_grant_group_rowid
          ,x_object_grant_group_id => l_object_grant_group_id
          ,x_grant_group_id        => l_grant_group_id
          ,x_inherited_flag        => l_inherited_flag
          ,x_inherited_from        => l_inherited_from
          ,x_inheritance_type      => l_inheritance_type
        );
      END IF;
      IF l_inheritance_type = 'HIDDEN-FOLDER' THEN
        l_result := FND_API.g_true;
      ELSE
        IF l_object_grant_group_rowid IS NOT NULL THEN
          OPEN c_permission(l_grant_group_id, l_inherited_flag, l_inheritance_type);
          FETCH c_permission INTO l_action;
          IF c_permission%FOUND AND l_action = 'ALLOW' THEN
            l_result := FND_API.g_true;
          END IF;
          CLOSE c_permission;
        END IF;
      END IF;
    ELSE
      -- Returns TRUE because IBC_USE_ACCESS_CONTROL profile is either
      -- not set or not set to 'Y'
      l_result := FND_API.g_true;
    END IF;

    IF IBC_DEBUG_PVT.debug_enabled THEN
      IBC_DEBUG_PVT.end_process(
        IBC_DEBUG_PVT.make_parameter_list(
          p_tag    => 'OUTPUT',
          p_parms  => JTF_VARCHAR2_TABLE_4000(
                        'RESULT', l_result
                      )
        )
      );
    END IF;

    RETURN l_result;

  EXCEPTION
    WHEN OTHERS THEN
      l_result := FND_API.g_false;

      IF IBC_DEBUG_PVT.debug_enabled THEN
        IBC_DEBUG_PVT.end_process(
          IBC_DEBUG_PVT.make_parameter_list(
            p_tag    => 'OUTPUT',
            p_parms  => JTF_VARCHAR2_TABLE_4000(
                          'RESULT', l_result
                        )
          )
        );
      END IF;

      RETURN l_result;
  END has_permission;

  /*#
   *  Returns the list of permissions a user has on an object instance
   *  as a string (comma separated and bracket delimited)
   *
   *  @param p_instance_object_id  ID for object definition id found in FND_OBJECTS
   *                               for this particular instance
   *  @param p_instance_pk1_value  value 1 for instance's primary key
   *  @param p_instance_pk2_value  value 2 for instance's primary key
   *  @param p_instance_pk3_value  value 3 for instance's primary key
   *  @param p_instance_pk4_value  value 4 for instance's primary key
   *  @param p_instance_pk5_value  value 5 for instance's primary key
   *  @param p_container_object_id ID for container. Found in FND_OBJECTS
   *  @param p_container_pk1_value value 1 for container's primary key
   *  @param p_container_pk2_value value 2 for container's primary key
   *  @param p_container_pk3_value value 3 for container's primary key
   *  @param p_container_pk4_value value 4 for container's primary key
   *  @param p_container_pk5_value value 5 for container's primary key
   *  @param p_current_user_id     Current User Id
   *
   *  @rep:displayname get_permissions_as_string
   *
   */
  FUNCTION get_permissions_as_string(
    p_instance_object_id     IN NUMBER
    ,p_instance_pk1_value    IN VARCHAR2
    ,p_instance_pk2_value    IN VARCHAR2
    ,p_instance_pk3_value    IN VARCHAR2
    ,p_instance_pk4_value    IN VARCHAR2
    ,p_instance_pk5_value    IN VARCHAR2
    ,p_container_object_id   IN NUMBER
    ,p_container_pk1_value   IN VARCHAR2
    ,p_container_pk2_value   IN VARCHAR2
    ,p_container_pk3_value   IN VARCHAR2
    ,p_container_pk4_value   IN VARCHAR2
    ,p_container_pk5_value   IN VARCHAR2
    ,p_current_user_id       IN NUMBER
  ) RETURN VARCHAR2 AS
    l_result              VARCHAR2(4096);
    l_perms_lookup_type   VARCHAR2(30);
    -- Permission variables
    l_action              VARCHAR2(30);
    -- IBC_object_grant_groups
    l_object_grant_group_rowid    ROWID;
    l_object_grant_group_id       NUMBER;
    l_grant_group_id     NUMBER;
    l_inherited_flag      VARCHAR2(2);
    l_inherited_from      NUMBER;
    l_inheritance_type    VARCHAR2(30);
    -- Cursor for "ALLOW"'s permission
    CURSOR c_permission(p_grant_group_id NUMBER
                        ,p_inherited_flag VARCHAR2)
    IS
      SELECT permission_code
        FROM ibc_grants a0
       WHERE object_id = p_instance_object_id
       	 AND grant_group_id = p_grant_group_id
       	 AND ((grantee_user_id IS NULL AND grantee_resource_id IS NULL) OR
       	      (IBC_UTILITIES_PVT.Check_Current_User(grantee_user_id,
	                          grantee_resource_id, grantee_resource_type,
                           p_current_user_id) = 'TRUE')
             )
       	 AND action = 'ALLOW'
       	 AND (p_inherited_flag = 'N'
       	      OR cascade_flag = IBC_UTILITIES_PVT.g_true
       	     )
         AND NOT EXISTS (
                         SELECT 'x'
                           FROM ibc_grants a1
                          WHERE a1.grant_group_id = a0.grant_group_id
			                         AND a1.object_id = a0.object_id
                     			    AND a1.permission_code = a0.permission_code
                            AND a1.action = 'RESTRICT'
                            -- Precedence User:1 Resp/Group:2 Global:3
                            -- Lowest takes precedence
                            AND DECODE(a1.grantee_resource_type,
                                       'RESPONSIBILITY', 2,
                                       'RS_GROUP', 2,
                                       'GROUP', 2,
                                       DECODE(a1.grantee_user_id, NULL, 3, 1))
                                <
                                DECODE(a0.grantee_resource_type,
                                       'RESPONSIBILITY', 2,
                                       'RS_GROUP', 2,
                                       'GROUP', 2,
                                       DECODE(a0.grantee_user_id, NULL, 3, 1))
                           AND ((grantee_user_id IS NULL AND grantee_resource_id IS NULL) OR
       	                         (IBC_UTILITIES_PVT.Check_Current_User(grantee_user_id,
	                                             grantee_resource_id, grantee_resource_type,
                                              p_current_user_id) = 'TRUE')
                                )
                         )
       ORDER BY grant_level asc, grantee_resource_id asc;
  BEGIN

    IF IBC_DEBUG_PVT.debug_enabled THEN
      IBC_DEBUG_PVT.start_process(
         p_proc_type  => 'PROCEDURE',
         p_proc_name  => 'Get_Permissions_As_String',
         p_parms      => IBC_DEBUG_PVT.make_parameter_list(
                           p_tag     => 'PARAMETERS',
                           p_parms   => JTF_VARCHAR2_TABLE_4000(
                                          'p_instance_object_id', p_instance_object_id,
                                          'p_instance_pk1_value', p_instance_pk1_value,
                                          'p_instance_pk2_value', p_instance_pk2_value,
                                          'p_instance_pk3_value', p_instance_pk3_value,
                                          'p_instance_pk4_value', p_instance_pk4_value,
                                          'p_instance_pk5_value', p_instance_pk5_value,
                                          'p_container_object_id', p_container_object_id,
                                          'p_container_pk1_value', p_container_pk1_value,
                                          'p_container_pk2_value', p_container_pk2_value,
                                          'p_container_pk3_value', p_container_pk3_value,
                                          'p_container_pk4_value', p_container_pk4_value,
                                          'p_container_pk5_value', p_container_pk5_value,
                                          'p_current_user_id', p_current_user_id
                                        )
                           )
      );
    END IF;

    l_result := NULL;

    -- Fetch object's grant group Info
    get_object_grant_group_info(
      p_instance_object_id     => p_instance_object_id
      ,p_instance_pk1_value    => p_instance_pk1_value
      ,p_instance_pk2_value    => p_instance_pk2_value
      ,p_instance_pk3_value    => p_instance_pk3_value
      ,p_instance_pk4_value    => p_instance_pk4_value
      ,p_instance_pk5_value    => p_instance_pk5_value
      ,x_rowid                 => l_object_grant_group_rowid
      ,x_object_grant_group_id => l_object_grant_group_id
      ,x_grant_group_id        => l_grant_group_id
      ,x_inherited_flag        => l_inherited_flag
      ,x_inherited_from        => l_inherited_from
      ,x_inheritance_type      => l_inheritance_type
    );

    IF Fnd_Profile.Value_specific('IBC_USE_ACCESS_CONTROL',-999,-999,-999) = 'Y' AND
       NVL(l_inheritance_type, 'FOLDER') <> 'HIDDEN-FOLDER'
    THEN
      IF l_object_grant_group_rowid IS NULL THEN
        -- Fetch object's grant group Info for container object
        get_object_grant_group_info(
          p_instance_object_id     => p_container_object_id
          ,p_instance_pk1_value    => p_container_pk1_value
          ,p_instance_pk2_value    => p_container_pk2_value
          ,p_instance_pk3_value    => p_container_pk3_value
          ,p_instance_pk4_value    => p_container_pk4_value
          ,p_instance_pk5_value    => p_container_pk5_value
          ,x_rowid                 => l_object_grant_group_rowid
          ,x_object_grant_group_id => l_object_grant_group_id
          ,x_grant_group_id        => l_grant_group_id
          ,x_inherited_flag        => l_inherited_flag
          ,x_inherited_from        => l_inherited_from
          ,x_inheritance_type      => l_inheritance_type
        );
      END IF;
      IF l_object_grant_group_rowid IS NOT NULL THEN
        FOR r_permission IN c_permission(l_grant_group_id, l_inherited_flag) LOOP
          IF l_result IS NULL OR
         	   INSTR(l_result, '[' || r_permission.permission_code || ']') = 0
         	THEN
            l_result := l_result || '[' || r_permission.permission_code || ']';
         	END IF;
        END LOOP;
      END IF;
    ELSE
      -- No Profile set (or set to N) for Using Data security
      -- Returning the whole list of permissions for specific object
      l_perms_lookup_type := get_perms_lookup_type(p_instance_object_id);
      FOR r_permission IN (SELECT lookup_code
                             FROM fnd_lookup_values
                            WHERE lookup_type = l_perms_lookup_type
                              AND enabled_flag = 'Y'
                              AND language = USERENV('lang')
                              AND SYSDATE BETWEEN NVL(start_date_active, SYSDATE)
                              AND NVL(end_date_active, SYSDATE))
      LOOP
        IF l_result IS NULL OR
       	   INSTR(l_result, '[' || r_permission.lookup_code || ']') = 0
       	THEN
          l_result := l_result || '[' || r_permission.lookup_code || ']';
       	END IF;
      END LOOP;
    END IF;

    IF IBC_DEBUG_PVT.debug_enabled THEN
      IBC_DEBUG_PVT.end_process(
        IBC_DEBUG_PVT.make_parameter_list(
          p_tag    => 'OUTPUT',
          p_parms  => JTF_VARCHAR2_TABLE_4000(
                        'RESULT', l_result
                      )
        )
      );
    END IF;


    RETURN l_result;
  -- Exception Handler Added for NOCOPY Change (11/08/2002) By ENUNEZ
  EXCEPTION
    WHEN OTHERS THEN
      IF IBC_DEBUG_PVT.debug_enabled THEN
        IBC_DEBUG_PVT.end_process(
          IBC_DEBUG_PVT.make_parameter_list(
            p_tag    => 'OUTPUT',
            p_parms  => JTF_VARCHAR2_TABLE_4000(
                          'RESULT', l_result,
                          'EXCEPTION', '****EXCEPTION:' || SQLERRM
                        )
          )
        );
      END IF;
      RAISE;
  END get_permissions_as_string;

  /*#
   *  Returns the list of permissions a user has on an object instance
   *
   *  @param p_instance_object_id  ID for object definition id found in FND_OBJECTS
   *                               for this particular instance
   *  @param p_instance_pk1_value  value 1 for instance's primary key
   *  @param p_instance_pk2_value  value 2 for instance's primary key
   *  @param p_instance_pk3_value  value 3 for instance's primary key
   *  @param p_instance_pk4_value  value 4 for instance's primary key
   *  @param p_instance_pk5_value  value 5 for instance's primary key
   *  @param p_container_object_id ID for container. Found in FND_OBJECTS
   *  @param p_container_pk1_value value 1 for container's primary key
   *  @param p_container_pk2_value value 2 for container's primary key
   *  @param p_container_pk3_value value 3 for container's primary key
   *  @param p_container_pk4_value value 4 for container's primary key
   *  @param p_container_pk5_value value 5 for container's primary key
   *  @param p_current_user_id     Current User Id
   *  @param x_permission_tbl      Output pl/sql table containing all
   *                               different permission codes.
   *  @param p_api_version         standard parm - API Version
   *  @param p_init_msg_list       standard parm - Initialize message list
   *  @param x_return_status       standard parm - Return Status
   *  @param x_msg_count           standard parm - Message Count
   *  @param x_msg_data            standard parm - Message Data
   *
   *  @rep:displayname get_permissions
   *
   */
  PROCEDURE get_permissions(
    p_instance_object_id     IN NUMBER
    ,p_instance_pk1_value    IN VARCHAR2
    ,p_instance_pk2_value    IN VARCHAR2
    ,p_instance_pk3_value    IN VARCHAR2
    ,p_instance_pk4_value    IN VARCHAR2
    ,p_instance_pk5_value    IN VARCHAR2
    ,p_container_object_id   IN NUMBER
    ,p_container_pk1_value   IN VARCHAR2
    ,p_container_pk2_value   IN VARCHAR2
    ,p_container_pk3_value   IN VARCHAR2
    ,p_container_pk4_value   IN VARCHAR2
    ,p_container_pk5_value   IN VARCHAR2
    ,p_current_user_id       IN NUMBER
    ,x_permission_tbl        OUT NOCOPY jtf_varchar2_table_100
    ,p_api_version           IN  NUMBER
    ,p_init_msg_list         IN  VARCHAR2
    ,x_return_status         OUT NOCOPY VARCHAR2
    ,x_msg_count             OUT NOCOPY NUMBER
    ,x_msg_data              OUT NOCOPY VARCHAR2
  ) AS
    TYPE t_vc100_tbl IS TABLE OF VARCHAR2(100)
      INDEX BY BINARY_INTEGER;
    l_result              t_vc100_tbl;
    l_count               NUMBER;
    l_perms_lookup_type   VARCHAR2(30);
    --******** local variable for standards **********
    l_api_name                    CONSTANT VARCHAR2(30)   := 'get_permissions';
    l_api_version                 CONSTANT NUMBER := 1.0;
    -- Permission variables
    l_action              VARCHAR2(30);
    l_add                 BOOLEAN;
    -- IBC_object_grant_groups
    l_object_grant_group_rowid    ROWID;
    l_object_grant_group_id       NUMBER;
    l_grant_group_id     NUMBER;
    l_inherited_flag      VARCHAR2(2);
    l_inherited_from      NUMBER;
    l_inheritance_type    VARCHAR2(30);
    -- Cursor for "ALLOW"'s permission
    CURSOR c_permission(p_grant_group_id NUMBER
                        ,p_inherited_flag VARCHAR2)
    IS
      SELECT permission_code
        FROM ibc_grants a0
       WHERE object_id = p_instance_object_id
       	 AND grant_group_id = p_grant_group_id
       	 AND ((grantee_user_id IS NULL AND grantee_resource_id IS NULL) OR
       	      (IBC_UTILITIES_PVT.Check_Current_User(grantee_user_id,
	                          grantee_resource_id, grantee_resource_type,
                           p_current_user_id) = 'TRUE')
             )
       	 AND action = 'ALLOW'
       	 AND (p_inherited_flag = 'N'
       	      OR cascade_flag = IBC_UTILITIES_PVT.g_true
       	     )
         AND NOT EXISTS (
                         SELECT 'x'
                           FROM ibc_grants a1
                          WHERE a1.grant_group_id = a0.grant_group_id
			                         AND a1.object_id = a0.object_id
                     			    AND a1.permission_code = a0.permission_code
                            AND a1.action = 'RESTRICT'
                            -- Precedence User:1 Resp/Group:2 Global:3
                            -- Lowest takes precedence
                            AND DECODE(a1.grantee_resource_type,
                                       'RESPONSIBILITY', 2,
                                       'RS_GROUP', 2,
                                       'GROUP', 2,
                                       DECODE(a1.grantee_user_id, NULL, 3, 1))
                                <
                                DECODE(a0.grantee_resource_type,
                                       'RESPONSIBILITY', 2,
                                       'RS_GROUP', 2,
                                       'GROUP', 2,
                                       DECODE(a0.grantee_user_id, NULL, 3, 1))
                            AND ((grantee_user_id IS NULL AND grantee_resource_id IS NULL) OR
      	                         (IBC_UTILITIES_PVT.Check_Current_User(grantee_user_id,
	                                             grantee_resource_id, grantee_resource_type,
                                              p_current_user_id) = 'TRUE')
                                )
                         )
       ORDER BY grant_level asc, grantee_resource_id asc;
  BEGIN
    -- ******* Standard Begins ********

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (
              l_api_version,
              p_api_version,
              l_api_name,
              G_PKG_NAME)
    THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;

    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Begin

    l_count := 0;

    -- Fetch object's grant group Info
    get_object_grant_group_info(
      p_instance_object_id     => p_instance_object_id
      ,p_instance_pk1_value    => p_instance_pk1_value
      ,p_instance_pk2_value    => p_instance_pk2_value
      ,p_instance_pk3_value    => p_instance_pk3_value
      ,p_instance_pk4_value    => p_instance_pk4_value
      ,p_instance_pk5_value    => p_instance_pk5_value
      ,x_rowid                 => l_object_grant_group_rowid
      ,x_object_grant_group_id => l_object_grant_group_id
      ,x_grant_group_id        => l_grant_group_id
      ,x_inherited_flag        => l_inherited_flag
      ,x_inherited_from        => l_inherited_from
      ,x_inheritance_type      => l_inheritance_type
    );

    IF Fnd_Profile.Value_specific('IBC_USE_ACCESS_CONTROL',-999,-999,-999) = 'Y' AND
       NVL(l_inheritance_type, 'FOLDER') <> 'HIDDEN-FOLDER'
    THEN
      IF l_object_grant_group_rowid IS NULL THEN
        -- Fetch object's grant group Info for container object
        get_object_grant_group_info(
          p_instance_object_id     => p_container_object_id
          ,p_instance_pk1_value    => p_container_pk1_value
          ,p_instance_pk2_value    => p_container_pk2_value
          ,p_instance_pk3_value    => p_container_pk3_value
          ,p_instance_pk4_value    => p_container_pk4_value
          ,p_instance_pk5_value    => p_container_pk5_value
          ,x_rowid                 => l_object_grant_group_rowid
          ,x_object_grant_group_id => l_object_grant_group_id
          ,x_grant_group_id        => l_grant_group_id
          ,x_inherited_flag        => l_inherited_flag
          ,x_inherited_from        => l_inherited_from
          ,x_inheritance_type      => l_inheritance_type
        );
      END IF;
      IF l_object_grant_group_rowid IS NOT NULL THEN
        FOR r_permission IN c_permission(l_grant_group_id, l_inherited_flag) LOOP
          l_add := true;
          FOR ind IN 1..l_result.COUNT LOOP
            IF l_result(ind) = r_permission.permission_code THEN
              l_add := false;
              EXIT;
            END IF;
          END LOOP;
          IF l_add THEN
            l_count := l_count + 1;
            l_result(l_count) := r_permission.permission_code;
          END IF;
        END LOOP;
      END IF;
    ELSE
      -- No Profile set (or set to N) for Using Data security
      -- Returning the whole list of permissions for specific object
      l_perms_lookup_type := get_perms_lookup_type(p_instance_object_id);
      FOR r_permission IN (SELECT lookup_code
                             FROM fnd_lookup_values
                            WHERE lookup_type = l_perms_lookup_type
                              AND enabled_flag = 'Y'
                              AND language = USERENV('lang')
                              AND SYSDATE BETWEEN NVL(start_date_active, SYSDATE)
                              AND NVL(end_date_active, SYSDATE))
      LOOP
        l_count := l_count + 1;
        l_result(l_count) := r_permission.lookup_code;
      END LOOP;
    END IF;

    IF l_count > 0 THEN
      x_permission_tbl := JTF_VARCHAR2_TABLE_100();
      x_permission_tbl.extend(l_count);
      FOR I IN 1..l_count LOOP
        x_permission_tbl(I)   := l_result(I);
      END LOOP;
    END IF;

    -- Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                p_data  => x_msg_data);
  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                                p_data  => x_msg_data);
      IBC_UTILITIES_PVT.HANDLE_EXCEPTIONS(
          P_API_NAME => L_API_NAME
          ,P_PKG_NAME => G_PKG_NAME
          ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
          ,P_PACKAGE_TYPE => IBC_UTILITIES_PVT.G_PVT
          ,P_SQLCODE => SQLCODE
          ,P_SQLERRM => SQLERRM
          ,X_MSG_COUNT => X_MSG_COUNT
          ,X_MSG_DATA => X_MSG_DATA
          ,X_RETURN_STATUS => X_RETURN_STATUS
      );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                                p_data  => x_msg_data);
      IBC_UTILITIES_PVT.HANDLE_EXCEPTIONS(
               P_API_NAME => L_API_NAME
               ,P_PKG_NAME => G_PKG_NAME
               ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
               ,P_PACKAGE_TYPE => IBC_UTILITIES_PVT.G_PVT
               ,P_SQLCODE => SQLCODE
               ,P_SQLERRM => SQLERRM
               ,X_MSG_COUNT => X_MSG_COUNT
               ,X_MSG_DATA => X_MSG_DATA
               ,X_RETURN_STATUS => X_RETURN_STATUS
           );
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
        FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
      END IF;
      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                                p_data  => x_msg_data);
      IBC_UTILITIES_PVT.HANDLE_EXCEPTIONS(
               P_API_NAME => L_API_NAME
               ,P_PKG_NAME => G_PKG_NAME
               ,P_EXCEPTION_LEVEL => IBC_UTILITIES_PVT.G_EXC_OTHERS
               ,P_PACKAGE_TYPE => IBC_UTILITIES_PVT.G_PVT
               ,P_SQLCODE => SQLCODE
               ,P_SQLERRM => SQLERRM
               ,X_MSG_COUNT => X_MSG_COUNT
               ,X_MSG_DATA => X_MSG_DATA
               ,X_RETURN_STATUS => X_RETURN_STATUS
          );
  END get_permissions;

  -- Utility proc to add an entry in a user table
  -- ignoring duplicate entries.
  PROCEDURE Add_to_user_table(
    p_user_id        IN NUMBER
    ,p_user_id_tbl   IN OUT NOCOPY t_user_id_tbl
  ) IS
    l_add    BOOLEAN;
  BEGIN
    l_add := TRUE;
    FOR I IN 1..p_user_id_tbl.COUNT LOOP
      IF p_user_id_tbl(I) = p_user_id THEN
        l_add := FALSE;
        EXIT;
      END IF;
    END LOOP;
    IF l_add THEN
      p_user_id_tbl(p_user_id_tbl.COUNT + 1) := p_user_id;
    END IF;
  -- Exception Handler Added for NOCOPY Change (11/08/2002) By ENUNEZ
  EXCEPTION
    WHEN OTHERS THEN
      RAISE;
  END Add_to_user_table;

  -- Utility proc populate a user table with userids from
  -- a resource.
  PROCEDURE Create_User_Table(
    p_resource_id    IN NUMBER
    ,p_resource_type IN VARCHAR2
    ,p_user_id_tbl   IN OUT NOCOPY t_user_id_tbl
  ) IS

    l_resource_type    VARCHAR2(30);
    l_user_id          NUMBER;

    CURSOR c_resource(p_resource_id NUMBER) IS
      SELECT resource_type
        FROM jtf_rs_all_resources_vl
       WHERE resource_id = p_resource_id;

    CURSOR c_grp_members(p_resource_id NUMBER) IS
      SELECT  group_id  group_id,  resource_id  group_resource_id,  'INDIVIDUAL'  resource_type
        FROM jtf_rs_group_members
       WHERE group_id = p_resource_id
         AND delete_flag = 'N'
       UNION
      SELECT rgm.group_id  group_id,  rgr.group_id  group_resource_id,  'GROUP'   resource_type
        FROM jtf_rs_group_members rgm, jtf_rs_grp_relations rgr
       WHERE rgm.group_id = rgr.related_group_id
         AND rgm.group_id = p_resource_id
       	 AND rgm.delete_flag = 'N'
       	 AND rgr.delete_flag = 'N';

    CURSOR c_resp_users(p_resp_id IN NUMBER) IS
      SELECT user_id
        FROM fnd_user_resp_groups
       WHERE responsibility_id = p_resp_id;

    CURSOR c_user_id(p_resource_id IN NUMBER) IS
      SELECT user_id
        FROM jtf_rs_resource_extns
       WHERE resource_id = p_resource_id;

  BEGIN
    IF p_resource_type IS NULL THEN
      OPEN c_resource(p_resource_id);
      FETCH c_resource INTO l_resource_type;
      CLOSE c_resource;
    ELSE
      l_resource_type := RTRIM(p_resource_type);
    END IF;
    IF l_resource_type IN ('GROUP', 'RS_GROUP') THEN
      FOR rec_member IN c_grp_members(p_resource_id) LOOP
        Create_User_Table(p_resource_id   => rec_member.group_resource_id,
                          p_resource_type  => rec_member.resource_type,
                          p_user_id_tbl    => p_user_id_tbl);
      END LOOP;
    ELSIF l_resource_type = 'RESPONSIBILITY' THEN
      FOR r_resp_user IN c_resp_users(p_resource_id) LOOP
        Add_to_user_table(r_resp_user.user_id, p_user_id_tbl);
      END LOOP;
    ELSE
      OPEN c_user_id(p_resource_id);
      FETCH c_user_id INTO l_user_id;
      IF c_user_id%FOUND AND l_user_id IS NOT NULL THEN
        Add_to_user_table(l_user_id, p_user_id_tbl);
      END IF;
      CLOSE c_user_id;
    END IF;
  -- Exception Handler Added for NOCOPY Change (11/08/2002) By ENUNEZ
  EXCEPTION
    WHEN OTHERS THEN
      RAISE;
  END Create_User_Table;

  /*#
   *  Procedure to obtain a list of users which has a particular
   *  permission on a object's instance. The result is returned comma
   *  separated.
   *
   *  @param p_instance_object_id  ID for object definition id found in FND_OBJECTS
   *                               for this particular instance
   *  @param p_instance_pk1_value  value 1 for instance's primary key
   *  @param p_instance_pk2_value  value 2 for instance's primary key
   *  @param p_instance_pk3_value  value 3 for instance's primary key
   *  @param p_instance_pk4_value  value 4 for instance's primary key
   *  @param p_instance_pk5_value  value 5 for instance's primary key
   *  @param p_permission_code     Permission Code
   *  @param p_container_pk1_value value 1 for container's primary key
   *  @param p_container_pk2_value value 2 for container's primary key
   *  @param p_container_pk3_value value 3 for container's primary key
   *  @param p_container_pk4_value value 4 for container's primary key
   *  @param p_container_pk5_value value 5 for container's primary key
   *  @param p_include_global      whether to include "global" user in the list
   *  @param p_global_value        Value to be used as "global" user, by default
   *                               it is 'All'.
   *  @param x_usernames           Output string containing all users with
   *                               permission on object's instance
   *  @param p_api_version         standard parm - API Version
   *  @param p_init_msg_list       standard parm - Initialize message list
   *  @param x_return_status       standard parm - Return Status
   *  @param x_msg_count           standard parm - Message Count
   *  @param x_msg_data            standard parm - Message Data
   *
   *  @rep:displayname get_grantee_usernames
   *
   */
  PROCEDURE get_grantee_usernames(
    p_instance_object_id     IN NUMBER
    ,p_instance_pk1_value    IN VARCHAR2
    ,p_instance_pk2_value    IN VARCHAR2
    ,p_instance_pk3_value    IN VARCHAR2
    ,p_instance_pk4_value    IN VARCHAR2
    ,p_instance_pk5_value    IN VARCHAR2
    ,p_permission_code       IN VARCHAR2
    ,p_container_object_id   IN NUMBER
    ,p_container_pk1_value   IN VARCHAR2
    ,p_container_pk2_value   IN VARCHAR2
    ,p_container_pk3_value   IN VARCHAR2
    ,p_container_pk4_value   IN VARCHAR2
    ,p_container_pk5_value   IN VARCHAR2
    ,p_include_global        IN  VARCHAR2
    ,p_global_value          IN  VARCHAR2
    ,x_usernames             OUT NOCOPY VARCHAR2
    ,p_api_version           IN  NUMBER
    ,p_init_msg_list         IN  VARCHAR2
    ,x_return_status         OUT NOCOPY VARCHAR2
    ,x_msg_count             OUT NOCOPY NUMBER
    ,x_msg_data              OUT NOCOPY VARCHAR2
  ) IS

    l_user_id_tbl          t_user_id_tbl;

    l_user_name            VARCHAR2(30);

    l_result               VARCHAR2(4096);

    -- Variable to know if a grant ALLOW was given to everybody
    -- not used for the moment, but could be used in the future.
    l_granted_to_all       VARCHAR2(1) := FND_API.g_false;

    -- IBC_object_grant_groups
    l_object_grant_group_rowid ROWID;
    l_object_grant_group_id    NUMBER;
    l_grant_group_id           NUMBER;
    l_inherited_flag           VARCHAR2(2);
    l_inherited_from           NUMBER;
    l_inheritance_type         VARCHAR2(30);

    --******** local variable for standards **********
    l_api_name                    CONSTANT VARCHAR2(30)   := 'get_grantee_usernames';
    l_api_version                 CONSTANT NUMBER := 1.0;

    CURSOR c_user_name(p_user_id NUMBER)
    IS SELECT user_name
         FROM fnd_user
        WHERE user_id = p_user_id;

    CURSOR c_base_grants(p_object_id       NUMBER,
                         p_grant_group_id  NUMBER,
                         p_permission_code VARCHAR2)
    IS SELECT action,
              permission_code,
              grant_level,
              grant_group_id,
              grantee_user_id,
              grantee_resource_id,
              grantee_resource_type
         FROM ibc_grants a0
        WHERE object_id = p_object_id
        	 AND grant_group_id = p_grant_group_id
          AND permission_code = p_permission_code
          AND action = 'ALLOW'
        ORDER BY grant_level;


  BEGIN
    -- ******* Standard Begins ********

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (
              l_api_version,
              p_api_version,
              l_api_name,
              G_PKG_NAME)
    THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;

    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Begin

    IF IBC_DEBUG_PVT.debug_enabled THEN
      IBC_DEBUG_PVT.start_process(
         p_proc_type  => 'PROCEDURE',
         p_proc_name  => l_api_name,
         p_parms      => IBC_DEBUG_PVT.make_parameter_list(
                           p_tag     => 'PARAMETERS',
                           p_parms   => JTF_VARCHAR2_TABLE_4000(
                                          'p_instance_object_id', p_instance_object_id,
                                          'p_instance_pk1_value', p_instance_pk1_value,
                                          'p_instance_pk2_value', p_instance_pk2_value,
                                          'p_instance_pk3_value', p_instance_pk3_value,
                                          'p_instance_pk4_value', p_instance_pk4_value,
                                          'p_instance_pk5_value', p_instance_pk5_value,
                                          'p_permission_code',    p_permission_code,
                                          'p_container_object_id', p_container_object_id,
                                          'p_container_pk1_value', p_container_pk1_value,
                                          'p_container_pk2_value', p_container_pk2_value,
                                          'p_container_pk3_value', p_container_pk3_value,
                                          'p_container_pk4_value', p_container_pk4_value,
                                          'p_container_pk5_value', p_container_pk5_value
                                        )
                           )
      );
    END IF;


    l_result := NULL;
    l_granted_to_all := FND_API.g_false;

    get_object_grant_group_info(
      p_instance_object_id     => p_instance_object_id
      ,p_instance_pk1_value    => p_instance_pk1_value
      ,p_instance_pk2_value    => p_instance_pk2_value
      ,p_instance_pk3_value    => p_instance_pk3_value
      ,p_instance_pk4_value    => p_instance_pk4_value
      ,p_instance_pk5_value    => p_instance_pk5_value
      ,x_rowid                 => l_object_grant_group_rowid
      ,x_object_grant_group_id => l_object_grant_group_id
      ,x_grant_group_id        => l_grant_group_id
      ,x_inherited_flag        => l_inherited_flag
      ,x_inherited_from        => l_inherited_from
      ,x_inheritance_type      => l_inheritance_type
    );
    IF l_object_grant_group_rowid IS NULL THEN
      -- Fetch object's grant group Info for container object
      get_object_grant_group_info(
        p_instance_object_id     => p_container_object_id
        ,p_instance_pk1_value    => p_container_pk1_value
        ,p_instance_pk2_value    => p_container_pk2_value
        ,p_instance_pk3_value    => p_container_pk3_value
        ,p_instance_pk4_value    => p_container_pk4_value
        ,p_instance_pk5_value    => p_container_pk5_value
        ,x_rowid                 => l_object_grant_group_rowid
        ,x_object_grant_group_id => l_object_grant_group_id
        ,x_grant_group_id        => l_grant_group_id
        ,x_inherited_flag        => l_inherited_flag
        ,x_inherited_from        => l_inherited_from
        ,x_inheritance_type      => l_inheritance_type
      );
    END IF;

    FOR r_base_grants IN c_base_grants(p_instance_object_id, l_grant_group_id, p_permission_code) LOOP
      IF r_base_grants.grantee_user_id IS NULL AND
         r_base_grants.grantee_resource_id IS NOT NULL
      THEN
        Create_User_Table(p_resource_id      => r_base_grants.grantee_resource_id,
                          p_resource_type    => r_base_grants.grantee_resource_type,
                          p_user_id_tbl      => l_user_id_tbl);
      ELSIF r_base_grants.grantee_user_id IS NOT NULL THEN
        Add_to_user_table(r_base_grants.grantee_user_id, l_user_id_tbl);
      ELSIF r_base_grants.grantee_resource_id IS NULL THEN
        l_granted_to_all := FND_API.g_true;
      END IF;
    END LOOP;
    -- Set output result
    FOR I IN 1..l_user_id_tbl.COUNT LOOP
      -- Check permission under a specific user
      -- checking permission is commented out as now user list contains mix of all i.e. group,
      -- responsibility users and individual users, checking permission will filter out
      -- users coming via group and responsibility causing not notification received.
      -- so commenting if and end if for same
      /*
      IF IBC_DATA_SECURITY_PVT.has_permission(p_instance_object_id   => p_instance_object_id,
                                              p_instance_pk1_value   => p_instance_pk1_value,
                                              p_instance_pk2_value   => p_instance_pk2_value,
                                              p_instance_pk3_value   => p_instance_pk3_value,
                                              p_instance_pk4_value   => p_instance_pk4_value,
                                              p_instance_pk5_value   => p_instance_pk5_value,
                                              p_permission_code      => p_permission_code,
                                              p_container_object_id  => p_container_object_id,
                                              p_container_pk1_value  => p_container_pk1_value,
                                              p_container_pk2_value  => p_container_pk2_value,
                                              p_container_pk3_value  => p_container_pk3_value,
                                              p_container_pk4_value  => p_container_pk4_value,
                                              p_container_pk5_value  => p_container_pk5_value,
                                              p_current_user_id      => l_user_id_tbl(I)) = FND_API.g_true
      THEN
      */
        OPEN c_user_name(l_user_id_tbl(I));
        FETCH c_user_name INTO l_user_name;
        CLOSE c_user_name;
        IF l_result IS NULL THEN
          l_result := l_user_name;
        ELSE
          l_result := l_result || ',' || l_user_name;
        END IF;
      --END IF;
    END LOOP;

    IF l_granted_to_all = FND_API.g_true AND p_include_global = FND_API.g_true THEN
      IF l_result IS NULL THEN
        l_result := NVL(p_global_value, 'All');
      ELSE
        l_result := l_result || ',' || NVL(p_global_value, 'All');
      END IF;
    END IF;

    x_usernames := l_result;

    -- Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                p_data  => x_msg_data);

  IF IBC_DEBUG_PVT.debug_enabled THEN
    IBC_DEBUG_PVT.end_process(
      IBC_DEBUG_PVT.make_parameter_list(
        p_tag    => 'OUTPUT',
        p_parms  => JTF_VARCHAR2_TABLE_4000(
                      'x_usernames', x_usernames,
                      'x_return_status', x_return_status,
                      'x_msg_count', x_msg_count,
                      'x_msg_data', x_msg_data
                    )
      )
    );
  END IF;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                                p_data  => x_msg_data);
      IBC_UTILITIES_PVT.HANDLE_EXCEPTIONS(
          P_API_NAME => L_API_NAME
          ,P_PKG_NAME => G_PKG_NAME
          ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
          ,P_PACKAGE_TYPE => IBC_UTILITIES_PVT.G_PVT
          ,P_SQLCODE => SQLCODE
          ,P_SQLERRM => SQLERRM
          ,X_MSG_COUNT => X_MSG_COUNT
          ,X_MSG_DATA => X_MSG_DATA
          ,X_RETURN_STATUS => X_RETURN_STATUS
      );
      IF IBC_DEBUG_PVT.debug_enabled THEN
        IBC_DEBUG_PVT.end_process(
          IBC_DEBUG_PVT.make_parameter_list(
            p_tag    => 'OUTPUT',
            p_parms  => JTF_VARCHAR2_TABLE_4000(
                          'x_return_status', x_return_status,
                          'x_msg_count', x_msg_count,
                          'x_msg_data', x_msg_data
                        )
          )
        );
      END IF;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                                p_data  => x_msg_data);
      IBC_UTILITIES_PVT.HANDLE_EXCEPTIONS(
               P_API_NAME => L_API_NAME
               ,P_PKG_NAME => G_PKG_NAME
               ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
               ,P_PACKAGE_TYPE => IBC_UTILITIES_PVT.G_PVT
               ,P_SQLCODE => SQLCODE
               ,P_SQLERRM => SQLERRM
               ,X_MSG_COUNT => X_MSG_COUNT
               ,X_MSG_DATA => X_MSG_DATA
               ,X_RETURN_STATUS => X_RETURN_STATUS
           );
      IF IBC_DEBUG_PVT.debug_enabled THEN
        IBC_DEBUG_PVT.end_process(
          IBC_DEBUG_PVT.make_parameter_list(
            p_tag    => 'OUTPUT',
            p_parms  => JTF_VARCHAR2_TABLE_4000(
                          'x_return_status', x_return_status,
                          'x_msg_count', x_msg_count,
                          'x_msg_data', x_msg_data
                        )
          )
        );
      END IF;
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
        FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
      END IF;
      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                                p_data  => x_msg_data);
      IBC_UTILITIES_PVT.HANDLE_EXCEPTIONS(
               P_API_NAME => L_API_NAME
               ,P_PKG_NAME => G_PKG_NAME
               ,P_EXCEPTION_LEVEL => IBC_UTILITIES_PVT.G_EXC_OTHERS
               ,P_PACKAGE_TYPE => IBC_UTILITIES_PVT.G_PVT
               ,P_SQLCODE => SQLCODE
               ,P_SQLERRM => SQLERRM
               ,X_MSG_COUNT => X_MSG_COUNT
               ,X_MSG_DATA => X_MSG_DATA
               ,X_RETURN_STATUS => X_RETURN_STATUS
          );
      IF IBC_DEBUG_PVT.debug_enabled THEN
        IBC_DEBUG_PVT.end_process(
          IBC_DEBUG_PVT.make_parameter_list(
            p_tag    => 'OUTPUT',
            p_parms  => JTF_VARCHAR2_TABLE_4000(
                          'x_return_status', x_return_status,
                          'x_msg_count', x_msg_count,
                          'x_msg_data', x_msg_data,
                          'EXCEPTION', SQLERRM
                        )
          )
        );
      END IF;
  END get_grantee_usernames;

  /*#
   *  returns the list of grantee user ids who have a specific permission
   *  on a given object instance.  This doesn't include permissions given
   *  to everybody (no grantee in particular) nor "RESTRICT" grants.
   *
   *  @param p_instance_object_id  ID for object definition id found in FND_OBJECTS
   *                               for this particular instance
   *  @param p_instance_pk1_value  value 1 for instance's primary key
   *  @param p_instance_pk2_value  value 2 for instance's primary key
   *  @param p_instance_pk3_value  value 3 for instance's primary key
   *  @param p_instance_pk4_value  value 4 for instance's primary key
   *  @param p_instance_pk5_value  value 5 for instance's primary key
   *  @param p_permission_code     Permission Code
   *  @param p_container_pk1_value value 1 for container's primary key
   *  @param p_container_pk2_value value 2 for container's primary key
   *  @param p_container_pk3_value value 3 for container's primary key
   *  @param p_container_pk4_value value 4 for container's primary key
   *  @param p_container_pk5_value value 5 for container's primary key
   *  @param x_userids             Output table containing all users with
   *                               permission on object's instance
   *  @param p_api_version         standard parm - API Version
   *  @param p_init_msg_list        standard parm - Initialize message list
   *  @param x_return_status       standard parm - Return Status
   *  @param x_msg_count           standard parm - Message Count
   *  @param x_msg_data            standard parm - Message Data
   *
   *  @rep:displayname get_grantee_userids
   *
   */
  PROCEDURE get_grantee_userids(
    p_instance_object_id     IN NUMBER
    ,p_instance_pk1_value    IN VARCHAR2
    ,p_instance_pk2_value    IN VARCHAR2
    ,p_instance_pk3_value    IN VARCHAR2
    ,p_instance_pk4_value    IN VARCHAR2
    ,p_instance_pk5_value    IN VARCHAR2
    ,p_permission_code       IN VARCHAR2
    ,p_container_object_id   IN NUMBER
    ,p_container_pk1_value   IN VARCHAR2
    ,p_container_pk2_value   IN VARCHAR2
    ,p_container_pk3_value   IN VARCHAR2
    ,p_container_pk4_value   IN VARCHAR2
    ,p_container_pk5_value   IN VARCHAR2
    ,x_userids               OUT NOCOPY JTF_NUMBER_TABLE
    ,p_api_version           IN  NUMBER
    ,p_init_msg_list         IN  VARCHAR2
    ,x_return_status         OUT NOCOPY VARCHAR2
    ,x_msg_count             OUT NOCOPY NUMBER
    ,x_msg_data              OUT NOCOPY VARCHAR2
  ) IS

    l_user_id_tbl          t_user_id_tbl;

    l_user_name            VARCHAR2(30);

    l_count                NUMBER;
    l_result               t_user_id_tbl;

    -- Variable to know if a grant ALLOW was given to everybody
    -- not used for the moment, but could be used in the future.
    l_granted_to_all       VARCHAR2(1) := FND_API.g_false;

    -- IBC_object_grant_groups
    l_object_grant_group_rowid ROWID;
    l_object_grant_group_id    NUMBER;
    l_grant_group_id           NUMBER;
    l_inherited_flag           VARCHAR2(2);
    l_inherited_from           NUMBER;
    l_inheritance_type         VARCHAR2(30);

    --******** local variable for standards **********
    l_api_name                    CONSTANT VARCHAR2(30)   := 'get_grantee_usernames';
    l_api_version                 CONSTANT NUMBER := 1.0;

    CURSOR c_user_name(p_user_id NUMBER)
    IS SELECT user_name
         FROM fnd_user
        WHERE user_id = p_user_id;

    CURSOR c_base_grants(p_object_id       NUMBER,
                         p_grant_group_id  NUMBER,
                         p_permission_code VARCHAR2)
    IS SELECT action,
              permission_code,
              grant_level,
              grant_group_id,
              grantee_user_id,
              grantee_resource_id, grantee_resource_type
         FROM ibc_grants a0
        WHERE object_id = p_object_id
        	 AND grant_group_id = p_grant_group_id
          AND permission_code = p_permission_code
          AND action = 'ALLOW'
        ORDER BY grant_level;

  BEGIN
    -- ******* Standard Begins ********

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (
              l_api_version,
              p_api_version,
              l_api_name,
              G_PKG_NAME)
    THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;

    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Begin

    l_granted_to_all := FND_API.g_false;

    get_object_grant_group_info(
      p_instance_object_id     => p_instance_object_id
      ,p_instance_pk1_value    => p_instance_pk1_value
      ,p_instance_pk2_value    => p_instance_pk2_value
      ,p_instance_pk3_value    => p_instance_pk3_value
      ,p_instance_pk4_value    => p_instance_pk4_value
      ,p_instance_pk5_value    => p_instance_pk5_value
      ,x_rowid                 => l_object_grant_group_rowid
      ,x_object_grant_group_id => l_object_grant_group_id
      ,x_grant_group_id        => l_grant_group_id
      ,x_inherited_flag        => l_inherited_flag
      ,x_inherited_from        => l_inherited_from
      ,x_inheritance_type      => l_inheritance_type
    );
    IF l_object_grant_group_rowid IS NULL THEN
      -- Fetch object's grant group Info for container object
      get_object_grant_group_info(
        p_instance_object_id     => p_container_object_id
        ,p_instance_pk1_value    => p_container_pk1_value
        ,p_instance_pk2_value    => p_container_pk2_value
        ,p_instance_pk3_value    => p_container_pk3_value
        ,p_instance_pk4_value    => p_container_pk4_value
        ,p_instance_pk5_value    => p_container_pk5_value
        ,x_rowid                 => l_object_grant_group_rowid
        ,x_object_grant_group_id => l_object_grant_group_id
        ,x_grant_group_id        => l_grant_group_id
        ,x_inherited_flag        => l_inherited_flag
        ,x_inherited_from        => l_inherited_from
        ,x_inheritance_type      => l_inheritance_type
      );
    END IF;

    FOR r_base_grants IN c_base_grants(p_instance_object_id, l_grant_group_id, p_permission_code) LOOP
      IF r_base_grants.grantee_user_id IS NULL AND
         r_base_grants.grantee_resource_id IS NOT NULL
      THEN
        Create_User_Table(p_resource_id      => r_base_grants.grantee_resource_id,
                          p_resource_type    => r_base_grants.grantee_resource_type,
                          p_user_id_tbl      => l_user_id_tbl);
      ELSIF r_base_grants.grantee_user_id IS NOT NULL THEN
        Add_to_user_table(r_base_grants.grantee_user_id, l_user_id_tbl);
      ELSIF r_base_grants.grantee_resource_id IS NULL THEN
        l_granted_to_all := FND_API.g_true;
      END IF;
    END LOOP;
    -- Set output result
    l_count := 0;
    FOR I IN 1..l_user_id_tbl.COUNT LOOP
      -- Check permission under a specific user
      IF IBC_DATA_SECURITY_PVT.has_permission(p_instance_object_id   => p_instance_object_id,
                                              p_instance_pk1_value   => p_instance_pk1_value,
                                              p_instance_pk2_value   => p_instance_pk2_value,
                                              p_instance_pk3_value   => p_instance_pk3_value,
                                              p_instance_pk4_value   => p_instance_pk4_value,
                                              p_instance_pk5_value   => p_instance_pk5_value,
                                              p_permission_code      => p_permission_code,
                                              p_container_object_id  => p_container_object_id,
                                              p_container_pk1_value  => p_container_pk1_value,
                                              p_container_pk2_value  => p_container_pk2_value,
                                              p_container_pk3_value  => p_container_pk3_value,
                                              p_container_pk4_value  => p_container_pk4_value,
                                              p_container_pk5_value  => p_container_pk5_value,
                                              p_current_user_id      => l_user_id_tbl(I)) = FND_API.g_true
      THEN
        l_count := l_count + 1;
        l_result(l_count) := l_user_id_tbl(I);
      END IF;
    END LOOP;

    -- Set actual result table (JTF_NUMBER_TABLE)
    IF l_count > 0 THEN
      x_userids := JTF_NUMBER_TABLE();
      x_userids.extend(l_count);
      FOR I IN 1..l_result.COUNT LOOP
        x_userids(I) := l_result(I);
      END LOOP;
    END IF;

    -- Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                p_data  => x_msg_data);
  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                                p_data  => x_msg_data);
      IBC_UTILITIES_PVT.HANDLE_EXCEPTIONS(
          P_API_NAME => L_API_NAME
          ,P_PKG_NAME => G_PKG_NAME
          ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
          ,P_PACKAGE_TYPE => IBC_UTILITIES_PVT.G_PVT
          ,P_SQLCODE => SQLCODE
          ,P_SQLERRM => SQLERRM
          ,X_MSG_COUNT => X_MSG_COUNT
          ,X_MSG_DATA => X_MSG_DATA
          ,X_RETURN_STATUS => X_RETURN_STATUS
      );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                                p_data  => x_msg_data);
      IBC_UTILITIES_PVT.HANDLE_EXCEPTIONS(
               P_API_NAME => L_API_NAME
               ,P_PKG_NAME => G_PKG_NAME
               ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
               ,P_PACKAGE_TYPE => IBC_UTILITIES_PVT.G_PVT
               ,P_SQLCODE => SQLCODE
               ,P_SQLERRM => SQLERRM
               ,X_MSG_COUNT => X_MSG_COUNT
               ,X_MSG_DATA => X_MSG_DATA
               ,X_RETURN_STATUS => X_RETURN_STATUS
           );
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
        FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
      END IF;
      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                                p_data  => x_msg_data);
      IBC_UTILITIES_PVT.HANDLE_EXCEPTIONS(
               P_API_NAME => L_API_NAME
               ,P_PKG_NAME => G_PKG_NAME
               ,P_EXCEPTION_LEVEL => IBC_UTILITIES_PVT.G_EXC_OTHERS
               ,P_PACKAGE_TYPE => IBC_UTILITIES_PVT.G_PVT
               ,P_SQLCODE => SQLCODE
               ,P_SQLERRM => SQLERRM
               ,X_MSG_COUNT => X_MSG_COUNT
               ,X_MSG_DATA => X_MSG_DATA
               ,X_RETURN_STATUS => X_RETURN_STATUS
          );
  END get_grantee_userids;

  /*#
   *  Returns information about inheritance, particularly the type of
   *  inheritance, and if in fact this instance has its own permissions
   *  or is still inheriting from parent container.
   *
   *  @param p_instance_object_id  ID for object definition id found in FND_OBJECTS
   *                               for this particular instance
   *  @param p_instance_pk1_value  value 1 for instance's primary key
   *  @param p_instance_pk2_value  value 2 for instance's primary key
   *  @param p_instance_pk3_value  value 3 for instance's primary key
   *  @param p_instance_pk4_value  value 4 for instance's primary key
   *  @param p_instance_pk5_value  value 5 for instance's primary key
   *  @param p_container_object_id ID for container. Found in FND_OBJECTS
   *  @param p_container_pk1_value value 1 for container's primary key
   *  @param p_container_pk2_value value 2 for container's primary key
   *  @param p_container_pk3_value value 3 for container's primary key
   *  @param p_container_pk4_value value 4 for container's primary key
   *  @param p_container_pk5_value value 5 for container's primary key
   *  @param p_api_version         standard parm - API Version
   *  @param p_init_msg_list       standard parm - Initialize message list
   *  @param x_inherited_flag      Whether instance is inheriting (T) or Not (F)
   *  @param x_inheritance_type    Inheritance Type
   *  @param x_return_status       standard parm - Return Status
   *  @param x_msg_count           standard parm - Message Count
   *  @param x_msg_data            standard parm - Message Data
   *
   *  @rep:displayname get_inheritance_info
   *
   */
  PROCEDURE get_inheritance_info (
    p_instance_object_id     IN NUMBER
    ,p_instance_pk1_value    IN VARCHAR2
    ,p_instance_pk2_value    IN VARCHAR2
    ,p_instance_pk3_value    IN VARCHAR2
    ,p_instance_pk4_value    IN VARCHAR2
    ,p_instance_pk5_value    IN VARCHAR2
    ,p_container_object_id   IN NUMBER
    ,p_container_pk1_value   IN VARCHAR2
    ,p_container_pk2_value   IN VARCHAR2
    ,p_container_pk3_value   IN VARCHAR2
    ,p_container_pk4_value   IN VARCHAR2
    ,p_container_pk5_value   IN VARCHAR2
    ,p_api_version           IN  NUMBER
    ,p_init_msg_list         IN  VARCHAR2
    ,x_inherited_flag        OUT NOCOPY VARCHAR2
    ,x_inheritance_type      OUT NOCOPY VARCHAR2
    ,x_return_status         OUT NOCOPY VARCHAR2
    ,x_msg_count             OUT NOCOPY NUMBER
    ,x_msg_data              OUT NOCOPY VARCHAR2
  ) IS

    -- IBC_object_grant_groups
    l_object_grant_group_rowid ROWID;
    l_object_grant_group_id    NUMBER;
    l_grant_group_id           NUMBER;
    l_inherited_flag           VARCHAR2(2);
    l_inherited_from           NUMBER;
    l_inheritance_type         VARCHAR2(30);

    --******** local variable for standards **********
    l_api_name                    CONSTANT VARCHAR2(30)   := 'get_inheritance_info';
    l_api_version                 CONSTANT NUMBER := 1.0;

  BEGIN

    -- ******* Standard Begins ********

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (
              l_api_version,
              p_api_version,
              l_api_name,
              G_PKG_NAME)
    THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;

    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Begin

    get_object_grant_group_info(
      p_instance_object_id     => p_instance_object_id
      ,p_instance_pk1_value    => p_instance_pk1_value
      ,p_instance_pk2_value    => p_instance_pk2_value
      ,p_instance_pk3_value    => p_instance_pk3_value
      ,p_instance_pk4_value    => p_instance_pk4_value
      ,p_instance_pk5_value    => p_instance_pk5_value
      ,x_rowid                 => l_object_grant_group_rowid
      ,x_object_grant_group_id => l_object_grant_group_id
      ,x_grant_group_id        => l_grant_group_id
      ,x_inherited_flag        => l_inherited_flag
      ,x_inherited_from        => l_inherited_from
      ,x_inheritance_type      => l_inheritance_type
    );
    IF l_object_grant_group_rowid IS NULL THEN
      -- Fetch object's grant group Info for container object
      get_object_grant_group_info(
        p_instance_object_id     => p_container_object_id
        ,p_instance_pk1_value    => p_container_pk1_value
        ,p_instance_pk2_value    => p_container_pk2_value
        ,p_instance_pk3_value    => p_container_pk3_value
        ,p_instance_pk4_value    => p_container_pk4_value
        ,p_instance_pk5_value    => p_container_pk5_value
        ,x_rowid                 => l_object_grant_group_rowid
        ,x_object_grant_group_id => l_object_grant_group_id
        ,x_grant_group_id        => l_grant_group_id
        ,x_inherited_flag        => l_inherited_flag
        ,x_inherited_from        => l_inherited_from
        ,x_inheritance_type      => l_inheritance_type
      );
    END IF;

    -- Setting values for OUT parameters.
    x_inherited_flag := l_inherited_flag;
    x_inheritance_type := l_inheritance_type;

    -- Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                p_data  => x_msg_data);
  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                                p_data  => x_msg_data);
      IBC_UTILITIES_PVT.HANDLE_EXCEPTIONS(
          P_API_NAME => L_API_NAME
          ,P_PKG_NAME => G_PKG_NAME
          ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
          ,P_PACKAGE_TYPE => IBC_UTILITIES_PVT.G_PVT
          ,P_SQLCODE => SQLCODE
          ,P_SQLERRM => SQLERRM
          ,X_MSG_COUNT => X_MSG_COUNT
          ,X_MSG_DATA => X_MSG_DATA
          ,X_RETURN_STATUS => X_RETURN_STATUS
      );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                                p_data  => x_msg_data);
      IBC_UTILITIES_PVT.HANDLE_EXCEPTIONS(
               P_API_NAME => L_API_NAME
               ,P_PKG_NAME => G_PKG_NAME
               ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
               ,P_PACKAGE_TYPE => IBC_UTILITIES_PVT.G_PVT
               ,P_SQLCODE => SQLCODE
               ,P_SQLERRM => SQLERRM
               ,X_MSG_COUNT => X_MSG_COUNT
               ,X_MSG_DATA => X_MSG_DATA
               ,X_RETURN_STATUS => X_RETURN_STATUS
           );
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
        FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
      END IF;
      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                                p_data  => x_msg_data);
      IBC_UTILITIES_PVT.HANDLE_EXCEPTIONS(
               P_API_NAME => L_API_NAME
               ,P_PKG_NAME => G_PKG_NAME
               ,P_EXCEPTION_LEVEL => IBC_UTILITIES_PVT.G_EXC_OTHERS
               ,P_PACKAGE_TYPE => IBC_UTILITIES_PVT.G_PVT
               ,P_SQLCODE => SQLCODE
               ,P_SQLERRM => SQLERRM
               ,X_MSG_COUNT => X_MSG_COUNT
               ,X_MSG_DATA => X_MSG_DATA
               ,X_RETURN_STATUS => X_RETURN_STATUS
          );
  END get_inheritance_info;

END;

/
