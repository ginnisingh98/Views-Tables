--------------------------------------------------------
--  DDL for Package Body HZ_DSS_UTIL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_DSS_UTIL_PUB" AS
/* $Header: ARHPDSUB.pls 120.13.12010000.4 2010/03/25 10:57:39 rgokavar ship $ */

--------------------------------------
-- declaration of private data types
--------------------------------------

TYPE t_number_tbl IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
TYPE t_varchar_30_tbl IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;

--------------------------------------
-- declaration of private functions and procedures
--------------------------------------

PROCEDURE  stamp_child_entities (
    p_entity_id                 IN     NUMBER,
    p_object_pk1                IN     VARCHAR2,
    p_object_pk2                IN     VARCHAR2,
    p_object_pk3                IN     VARCHAR2,
    p_object_pk4                IN     VARCHAR2,
    p_object_pk5                IN     VARCHAR2
);

FUNCTION check_created_by_module_cr (
    p_dss_group_code            IN     VARCHAR2,
    p_parent_party_id_tbl       IN     t_number_tbl,
    p_parent_party_type_tbl     IN     t_varchar_30_tbl
) RETURN VARCHAR2;

FUNCTION check_classifications (
    p_dss_group_code            IN     VARCHAR2,
    p_party_id                  IN     NUMBER
) RETURN VARCHAR2;

FUNCTION check_classification_cr (
    p_dss_group_code            IN     VARCHAR2,
    p_parent_party_id_tbl       IN     t_number_tbl,
    p_parent_party_type_tbl     IN     t_varchar_30_tbl
) RETURN VARCHAR2;

FUNCTION check_relationship_types (
    p_dss_group_code              IN     VARCHAR2,
    p_party_id                    IN     NUMBER
  -- ,p_relationship_id            IN     NUMBER  -- Bug 5687869 (Nishant)
) RETURN VARCHAR2;

FUNCTION check_relationship_type_cr (
    p_dss_group_code            IN     VARCHAR2,
    p_db_object_name            IN     VARCHAR2,
    p_object_pk1                IN     VARCHAR2 DEFAULT NULL,
    p_object_pk2                IN     VARCHAR2 DEFAULT NULL,
    p_object_pk3                IN     VARCHAR2 DEFAULT NULL,
    p_object_pk4                IN     VARCHAR2 DEFAULT NULL,
    p_object_pk5                IN     VARCHAR2 DEFAULT NULL,
    p_parent_party_id_tbl       IN     t_number_tbl,
    p_parent_party_type_tbl     IN     t_varchar_30_tbl
) RETURN VARCHAR2;

FUNCTION is_relationship_party (
    p_party_id                  IN     NUMBER,
    x_relationship_id           OUT    NOCOPY NUMBER
) RETURN VARCHAR2;

PROCEDURE get_parent_party_id (
    p_db_object_name            IN     VARCHAR2,
    p_object_pk1                IN     VARCHAR2 DEFAULT NULL,
    p_object_pk2                IN     VARCHAR2 DEFAULT NULL,
    p_object_pk3                IN     VARCHAR2 DEFAULT NULL,
    p_object_pk4                IN     VARCHAR2 DEFAULT NULL,
    p_object_pk5                IN     VARCHAR2 DEFAULT NULL,
    x_party_id_tbl              OUT    NOCOPY t_number_tbl,
    x_party_type_tbl            OUT    NOCOPY t_varchar_30_tbl
);

PROCEDURE print (
    p_str                       IN     VARCHAR2
);

--------------------------------------
-- public functions and procedures
--------------------------------------

/**
 * FUNCTION
 *          test_instance
 *
 * DESCRIPTION
 *          Given a user, an  operation , object name and primary key
 *          for the object, it returns  Trues or False for the access
 *
 *
 * SCOPE - PUBLIC
 *
 * EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS  : IN:
 *                 p_operation_code     VARCHAR2  e.g SELECT,INSERT etc.
 *                 p_db_object_name     VARCHAR2  Object_name in fnd_objects
 *                                                e.g.HZ_PARTIES
 *                 p_instance_pk1_value VARCHAR2  e.g Party_id = 1000
 *                 p_user               VARCHAR2  e.g JDOE
 *
 *              OUT: T/F
 *          IN/ OUT:
 *
 * RETURNS    : NONE
 *
 * NOTES
 *
 * MODIFICATION HISTORY -
 *                       Jyoti Pandey 08-07-2002 Created.
 *
 */

FUNCTION test_instance (
    p_operation_code            IN     VARCHAR2,
    p_db_object_name            IN     VARCHAR2,
    p_instance_pk1_value        IN     VARCHAR2,
    p_instance_pk2_value        IN     VARCHAR2 ,
    p_instance_pk3_value        IN     VARCHAR2 ,
    p_instance_pk4_value        IN     VARCHAR2 ,
    p_instance_pk5_value        IN     VARCHAR2 ,
    p_user_name                 IN     VARCHAR2 ,
    x_return_status             OUT    NOCOPY VARCHAR2,
    x_msg_count                 OUT    NOCOPY NUMBER,
    x_msg_data                  OUT    NOCOPY VARCHAR2,
    p_init_msg_list             IN     VARCHAR2
) RETURN VARCHAR2 IS

    CURSOR c_check_user IS
    SELECT '1'
    FROM   fnd_user
    WHERE  user_name = p_user_name
    AND    (start_date IS NULL OR start_date <= SYSDATE)
    AND    (end_date IS NULL OR end_date >= SYSDATE);

    CURSOR c_check_table IS
    SELECT '1'
    FROM   fnd_objects
    WHERE  database_object_name = p_db_object_name
    AND    ROWNUM = 1;

    CURSOR c_check_operation_code IS
    SELECT '1'
    FROM   ar_lookups lu
    WHERE  lu.lookup_type = 'HZ_DATA_OPERATIONS'
    AND    lu.lookup_code = p_operation_code;

    CURSOR get_functions_for_op IS
    SELECT dss.security_scheme_code , func.function_name
    FROM   hz_dss_scheme_functions dss,
           fnd_form_functions func
    WHERE  dss.data_operation_code = p_operation_code
    AND    dss.status = 'A'
    AND    dss.function_id = func.function_id;

    l_security_scheme_code      VARCHAR2(30);
    l_function_name             VARCHAR2(30);
    l_result                    VARCHAR2(1);
    l_exists                    VARCHAR2(1);

BEGIN

    ---initialize the message
    --
    -- Bug 3667238: initialize message stack based on the value
    -- of the parameter
    --
    IF p_init_msg_list IS NOT NULL AND
       FND_API.to_Boolean(p_init_msg_list)
    THEN
      FND_MSG_PUB.initialize;
    END IF;

    --- initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --Check if security is on
    IF NVL(FND_PROFILE.VALUE('HZ_DSS_ENABLED'), 'N')  = 'Y' THEN

      /* in R12, the fnd api won't accept user name.
         it will raise a runtime error user_name contains
         anything other than null or fnd_global.user_name

      ---check if the passed user is valid
      OPEN c_check_user;
      FETCH c_check_user INTO l_exists;
      IF c_check_user%NOTFOUND THEN
        CLOSE c_check_user;
        FND_MESSAGE.SET_NAME('AR', 'HZ_DSS_INVALID_USER');
        FND_MESSAGE.SET_TOKEN('USER_NAME', p_user_name);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      CLOSE c_check_user;
      */

      ---Check if the table name is valid
      OPEN c_check_table;
      FETCH c_check_table INTO l_exists;
      IF c_check_table%NOTFOUND THEN
        CLOSE c_check_table;
        FND_MESSAGE.SET_NAME('AR', 'HZ_DSS_INVALID_OBJECT');
        FND_MESSAGE.SET_TOKEN('OBJECT_NAME',p_db_object_name);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      CLOSE c_check_table;

      ----  Check if the passed operation code is valid ----
      OPEN c_check_operation_code;
      FETCH c_check_operation_code INTO l_exists;
      IF c_check_operation_code%NOTFOUND THEN
        CLOSE c_check_operation_code;
        FND_MESSAGE.SET_NAME('AR', 'HZ_DSS_INVALID_OPER');
        FND_MESSAGE.SET_TOKEN('OPER_NAME',p_operation_code);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      CLOSE c_check_operation_code;

      ----  Get all the security functions for the operation passed ----
      OPEN get_functions_for_op;
      LOOP
        FETCH get_functions_for_op INTO
          l_security_scheme_code, l_function_name;
        EXIT WHEN get_functions_for_op%NOTFOUND;

        ----  Call the AOL check function ----
        l_result := fnd_data_security.check_function (
                      1,
                      l_function_name,
                      p_db_object_name,
                      p_instance_pk1_value,
                      p_instance_pk2_value,
                      p_instance_pk3_value,
                      p_instance_pk4_value,
                      p_instance_pk5_value,
                      fnd_global.user_name -- p_user_name
                   );

        IF l_result = 'F' THEN
          EXIT;
        ELSIF l_result = 'U' THEN
          FND_MESSAGE.SET_NAME('AR', 'HZ_API_CALLING_ERROR');
          FND_MESSAGE.SET_TOKEN('PROC_NAME', 'FND_DATA_SECURITY.check_function');
          FND_MSG_PUB.ADD;
          RAISE FND_API.G_EXC_ERROR;
        END IF;
      END LOOP;
      CLOSE get_functions_for_op;

      RETURN l_result;

    ELSE
      --no security so return true
      RETURN FND_API.G_TRUE;
    END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;

    FND_MSG_PUB.COUNT_AND_GET(
      p_encoded                    => fnd_api.g_false,
      p_count                      => x_msg_count,
      p_data                       => x_msg_data
    );

    RETURN FND_API.G_FALSE;

  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
    FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
    FND_MSG_PUB.ADD;

    FND_MSG_PUB.COUNT_AND_GET(
      p_encoded                    => fnd_api.g_false,
      p_count                      => x_msg_count,
      p_data                       => x_msg_data
    );

    RETURN FND_API.G_FALSE;

END test_instance;


/**
 * PROCEDURE
 *          get_granted_groups
 *
 * DESCRIPTION
 *          For a given user ,operation code, gets all the data sharing groups
 *
 * SCOPE - PUBLIC
 *
 * EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS  : IN:
 *                p_user_name       VARCHAR2 e.g. JDOE
 *                p_operation_code  VARCHAR2 e.g. SELECT
 *
 *              OUT: x_granted_groups table of data dharing group , entity_id
 *          IN/ OUT:
 *
 * RETURNS    : NONE
 *
 * NOTES
 *
 * MODIFICATION HISTORY -
 *                       Jyoti Pandey 08-07-2002 Created.
 *
 */

PROCEDURE get_granted_groups (
   p_user_name         IN    VARCHAR2,
   p_operation_code    IN    VARCHAR2,
   x_granted_groups    OUT NOCOPY   dss_group_tbl_type,
   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2
 ) IS


 l_menu_id NUMBER;
 l_function_id  NUMBER;
 l_exists VARCHAR2(1);
 l_security_scheme_code hz_dss_secured_entities.dss_group_code%type;
 l_object_instance_set_id hz_dss_secured_entities.dss_instance_set_id%type;

 i BINARY_INTEGER;

 cursor c_fn_menu_op(t_operation_code IN VARCHAR2) IS
 SELECT distinct menu_id ,dsf.security_scheme_code ,dsf.function_id
 FROM hz_dss_scheme_functions dsf, fnd_compiled_menu_functions cmf
 WHERE dsf.data_operation_code = t_operation_code
 AND   dsf.function_id = cmf.function_id
 AND   dsf.status = 'A';


 cursor c_inst_set_from_menu(t_menu_id IN NUMBER,
                 t_function_id IN NUMBER, t_user_name IN VARCHAR2) IS
 SELECT  instance_set_id
 FROM    fnd_grants grants
 WHERE grants.menu_id= t_menu_id      --grant for a menu
 AND   grants.start_date <= sysdate
 AND   ( grants.end_date IS NULL
    OR grants.end_date >= sysdate )
 AND  (    (    grants.grantee_type = 'USER'  --grantee a user
 AND grants.grantee_key = t_user_name)
      OR (    grants.grantee_type = 'GROUP'  --grantee a group
           AND grants.grantee_key in
               (select role_name
                from wf_user_roles
                where user_name  = t_user_name))
      OR (grants.grantee_type = 'GLOBAL'));


 cursor c_get_dss_groups(t_object_instance_set_id IN NUMBER) IS
 select dss_group_code, entity_id
 from hz_dss_secured_entities
 where dss_instance_set_id = t_object_instance_set_id
 and status = 'A';


BEGIN

  ---initialize the message
    FND_MSG_PUB.initialize;

  --- initialize API return status to success.
     x_return_status := FND_API.G_RET_STS_SUCCESS;

  ---Validate the input
  ---check if the passed user is valid
  ---Check if the passed operation code is valid
  begin

    select '1'
    into l_exists
    from fnd_user
    where user_name = p_user_name
    and  ( start_date IS NULL OR start_date <= SYSDATE)
    and  ( end_date is null or end_date >= sysdate );

   exception when no_data_found then
    FND_MESSAGE.SET_NAME('AR','HZ_DSS_INVALID_USER');
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  end;

  begin

    select '1'
    into l_exists
    from ar_lookups lu
    where lu.lookup_type = 'HZ_DATA_OPERATIONS'
    and   lu.lookup_code = p_operation_code;

  exception when no_data_found then
    FND_MESSAGE.SET_NAME('AR', 'HZ_DSS_INVALID_OPER');
    FND_MESSAGE.SET_TOKEN('OPER_NAME',p_operation_code);
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  end;

  i := 1;

  ---Get all the functions and menus for that operation
   open c_fn_menu_op(p_operation_code);
   loop
      fetch c_fn_menu_op into
            l_menu_id ,l_security_scheme_code, l_function_id;

      exit when c_fn_menu_op%NOTFOUND;

      ---get instance sets from the user and and menu
      ---from the grants , form functions table
      open c_inst_set_from_menu(l_menu_id, l_function_id ,p_user_name);
      loop
         fetch c_inst_set_from_menu into l_object_instance_set_id;
         exit when c_inst_set_from_menu%NOTFOUND;

         open c_get_dss_groups(l_object_instance_set_id);
         loop
            fetch c_get_dss_groups  into x_granted_groups(i).dss_group_code,
                                    x_granted_groups(i).entity_id;

            exit when c_get_dss_groups%NOTFOUND;

          i := i + 1;
         end loop;
         close c_get_dss_groups;

      end loop;
      close c_inst_set_from_menu;


  end loop;
  close c_fn_menu_op;

EXCEPTION
WHEN fnd_api.g_exc_error THEN
  x_return_status := FND_API.G_RET_STS_ERROR;
  FND_MSG_PUB.Count_And_Get( p_encoded => FND_API.G_FALSE,
                             p_count => x_msg_count,
                             p_data  => x_msg_data);


END get_granted_groups;

/**
 * FUNCTION
 *          determine_dss_group
 *
 * DESCRIPTION
 *          For a given object for a particular row, determine the data sharing
 *          group
 *
 * SCOPE - PUBLIC
 *
 * EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS  : IN:
 *                  p_db_object_name VARCHAR2  e.g HZ_PARTIES
 *                  p_object_pk1     VARCHAR2  e.g Party_id  1000
 *
 *              OUT: Data Sharing group VARCHAR2
 *          IN/ OUT:
 *
 * RETURNS    : NONE
 *
 * NOTES
 *
 * MODIFICATION HISTORY -
 *           Jyoti Pandey         08-07-2002 Created.
 */

FUNCTION determine_dss_group (
    p_db_object_name              IN     VARCHAR2,
    p_object_pk1                  IN     VARCHAR2,
    p_object_pk2                  IN     VARCHAR2,
    p_object_pk3                  IN     VARCHAR2,
    p_object_pk4                  IN     VARCHAR2,
    p_object_pk5                  IN     VARCHAR2,
    p_root_db_object_name         IN     VARCHAR2,
    p_root_object_pk1             IN     VARCHAR2,
    p_root_object_pk2             IN     VARCHAR2,
    p_root_object_pk3             IN     VARCHAR2,
    p_root_object_pk4             IN     VARCHAR2,
    p_root_object_pk5             IN     VARCHAR2
) RETURN VARCHAR2 IS

    CURSOR c_check_criteria (
      p_dss_group_code       VARCHAR2
    ) IS
    SELECT 1
    FROM   hz_dss_criteria
    WHERE  dss_group_code = p_dss_group_code
    AND    status = 'A'
    AND    ROWNUM = 1;

    CURSOR c_check_created_by_module (
      p_dss_group_code       VARCHAR2
    ) IS
    SELECT 1
    FROM   hz_dss_criteria
    WHERE  dss_group_code = p_dss_group_code
    AND    owner_table_name = 'AR_LOOKUPS'
    AND    owner_table_id1 = 'HZ_CREATED_BY_MODULES'
    AND    status = 'A'
    AND    ROWNUM = 1;

    CURSOR c_check_classification (
      p_dss_group_code       VARCHAR2
    ) IS
    SELECT 1
    FROM   hz_dss_criteria
    WHERE  dss_group_code = p_dss_group_code
    AND    owner_table_name = 'FND_LOOKUP_VALUES'
    AND    status = 'A'
    AND    ROWNUM = 1;

    CURSOR c_check_relationship_type (
      p_dss_group_code       VARCHAR2
    ) IS
    SELECT 1
    FROM   hz_dss_criteria
    WHERE  dss_group_code = p_dss_group_code
    AND    owner_table_name = 'HZ_RELATIONSHIP_TYPES'
    AND    status = 'A'
    AND    ROWNUM = 1;

    CURSOR c_get_dss_groups (
      p_db_object_name            VARCHAR2
    ) IS
    SELECT obj.object_id, obj.obj_name, null instance_set_id, null instance_set_name,
           obj.pk1_column_name, obj.pk2_column_name, null predicate,
           dsg.dss_group_code, dsg.rank
    FROM   hz_dss_entities dse,
           hz_dss_secured_entities se,
           hz_dss_groups_b dsg,
           fnd_objects obj
    WHERE  obj.database_object_name = p_db_object_name
    AND    dse.object_id IS NOT NULL
    AND    dse.object_id = obj.object_id
    AND    dse.entity_id = se.entity_id
    AND    se.dss_group_code = dsg.dss_group_code
    AND    se.status = 'A'
    AND    dsg.status = 'A'
    AND    dse.status = 'A'
    UNION ALL
    SELECT obj.object_id, obj.obj_name, ins.instance_set_id, ins.instance_set_name,
           obj.pk1_column_name, obj.pk2_column_name, ins.predicate,
           dsg.dss_group_code, dsg.rank
    FROM   hz_dss_entities dse,
           hz_dss_secured_entities se,
           hz_dss_groups_b dsg,
           fnd_objects obj,
           fnd_object_instance_sets ins
    WHERE  obj.database_object_name = p_db_object_name
    AND    dse.object_id IS NULL
    AND    dse.instance_set_id = ins.instance_set_id
    AND    ins.object_id = obj.object_id
    AND    dse.entity_id = se.entity_id
    AND    se.dss_group_code = dsg.dss_group_code
    AND    se.status = 'A'
    AND    dsg.status = 'A'
    AND    dse.status = 'A'
    ORDER BY rank;

    l_dummy                       NUMBER(1);
    l_db_object_name              VARCHAR2(30);
    l_object_pk1                  VARCHAR2(30);
    l_object_pk2                  VARCHAR2(30);
    l_object_pk3                  VARCHAR2(30);
    l_object_pk4                  VARCHAR2(30);
    l_object_pk5                  VARCHAR2(30);
    l_relationship_id             NUMBER;
    l_parent_party_id_tbl         t_number_tbl;
    l_parent_party_type_tbl       t_varchar_30_tbl;
    l_falling_into_the_group      VARCHAR2(2);
    l_failure_reason              VARCHAR2(100);
    l_object_id                   NUMBER;
    l_object_name                 VARCHAR2(30);
    l_instance_set_id             NUMBER;
    l_instance_set_name           VARCHAR2(30);
    l_pk1_column_name             VARCHAR2(30);
    l_pk2_column_name             VARCHAR2(30);
    l_predicate                   VARCHAR2(1000);
    l_dss_group_code              VARCHAR2(30);
    l_rank                        NUMBER;
    l_sql                         VARCHAR2(1000);
    l_pre_db_object_name          VARCHAR2(30);
    l_pre_dss_group_code          VARCHAR2(30);
    l_module_based_dsg            VARCHAR2(1);
    l_class_based_dsg             VARCHAR2(1);
    l_rel_based_dsg               VARCHAR2(1);
    l_returned_dss_group          VARCHAR2(30);

BEGIN
     print ('BEGIN determine_dss_group for :'||p_object_pk1);

    --
    -- set local variables
    --
    l_db_object_name := p_db_object_name;
    l_object_pk1 := p_object_pk1;
    l_object_pk2 := p_object_pk2;
    l_object_pk3 := p_object_pk3;
    l_object_pk4 := p_object_pk4;
    l_object_pk5 := p_object_pk5;

    --
    -- checking relationship party will be redirected to
    -- check relationship.
    --
    IF p_db_object_name = 'HZ_PARTIES' THEN
      IF is_relationship_party(TO_NUMBER(p_object_pk1), l_relationship_id) = 'Y' THEN
        l_db_object_name := 'HZ_RELATIONSHIPS';
        l_object_pk1 := l_relationship_id;
        l_object_pk2 := 'F';
      END IF;
    END IF;


    print (
      'l_db_object_name = '||l_db_object_name||' '||
      'l_object_pk1 = '||l_object_pk1||' '||
      'l_object_pk2 = '||l_object_pk2
    );

    --
    -- find all of groups that are applicable to this entity
    --
    OPEN c_get_dss_groups(l_db_object_name);
    LOOP

      << next_fetch>>

      l_falling_into_the_group := 'NA';
      l_failure_reason := 'INITIAL';

      FETCH c_get_dss_groups INTO
        l_object_id, l_object_name,
        l_instance_set_id, l_instance_set_name,
        l_pk1_column_name, l_pk2_column_name, l_predicate,
        l_dss_group_code, l_rank;
      EXIT WHEN c_get_dss_groups%NOTFOUND;

      --
      -- debug messages
      --

      print (
        'object_id = '||l_object_id||' '||
        'obj_name = '||l_object_name
		);
      print (
        'instance_set_id = '||l_instance_set_id||' '||
        'instance_set_name = '||l_instance_set_name
        );
      print (
        'pk1_column_name = '||l_pk1_column_name||' '||
        'pk2_column_name = '||l_pk2_column_name
        );
      print (
        'predicate = '||l_predicate||' '||
        'dss_group_code = '||l_dss_group_code||' '||
        'rank = '||l_rank
      );


      --
      -- check if the record can fall into the group if
      -- the group secure instance entities
      --

      IF l_predicate IS NOT NULL THEN
      BEGIN
        l_sql := 'SELECT 1 FROM '||l_db_object_name||' '||
                 'WHERE '||l_pk1_column_name||' = :1'||' '||
                 'AND '||l_predicate;

        IF l_pk2_column_name IS NULL THEN
          --
          -- debug messages
          --
           print(l_sql);

          EXECUTE IMMEDIATE l_sql into l_dummy USING l_object_pk1;
        ELSE
          l_sql := l_sql||' '||
                   'AND '||l_pk2_column_name||' = :2';

          --
          -- debug messages
          --
           print(l_sql);

          EXECUTE IMMEDIATE l_sql into l_dummy USING l_object_pk1, l_object_pk2;
        END IF;

      EXCEPTION
        WHEN OTHERS THEN
          print('EXCEPTION :'||SQLERRM);
          l_failure_reason := 'INSTANCE_CHECK';
          GOTO next_fetch;
      END;
      ELSE
        print('Predicate NULL');
        NULL;
      END IF;

      --
      -- check cache
      --
      IF l_pre_db_object_name = l_db_object_name AND
         l_failure_reason <> 'INSTANCE_CHECK' AND
         l_pre_dss_group_code = l_dss_group_code
      THEN
        print ('l_pre_db_object_name='||l_db_object_name||':l_failure_reason='||l_failure_reason
               ||'l_pre_dss_group_code='||l_pre_dss_group_code||':GOTO next_fetch');
        GOTO next_fetch;
      END IF;

      --
      -- check if there is any criteria defined in the dss group
      -- no criteria means the group securing all of records.
      -- return the group code directly.
      --
      OPEN c_check_criteria(l_dss_group_code);
      FETCH c_check_criteria INTO l_dummy;
      IF c_check_criteria%NOTFOUND THEN
        CLOSE c_check_criteria;
        print('c_check_criteria%NOTFOUND, EXIT Loop, return l_returned_dss_group='||l_dss_group_code);
        l_returned_dss_group :=  l_dss_group_code;
        EXIT;
      ELSE
        print('c_check_criteria%FOUND, continue');
        NULL;
      END IF;
      CLOSE c_check_criteria;

      --
      -- get parent party id and type
      --
      get_parent_party_id(
        p_db_object_name          => l_db_object_name,
        p_object_pk1              => l_object_pk1,
        p_object_pk2              => l_object_pk2,
        p_object_pk3              => l_object_pk3,
        p_object_pk4              => l_object_pk4,
        p_object_pk5              => l_object_pk5,
        x_party_id_tbl            => l_parent_party_id_tbl,
        x_party_type_tbl          => l_parent_party_type_tbl
      );

      --
      -- debug messages
      --
       print('Number of parent parties: '||l_parent_party_id_tbl.COUNT);

      FOR i IN 1..l_parent_party_id_tbl.COUNT LOOP
        print('party_id = '||l_parent_party_id_tbl(i)||' '||
              'party_type = '||l_parent_party_type_tbl(i));
      END LOOP;


      --
      -- check if it is created by module based
      --
      OPEN c_check_created_by_module(l_dss_group_code);
      FETCH c_check_created_by_module INTO l_dummy;
      IF c_check_created_by_module%NOTFOUND THEN
        l_module_based_dsg := 'N';
      ELSE
        l_module_based_dsg := 'Y';
      END IF;
      CLOSE c_check_created_by_module;

      --
      -- debug messages
      --
       print('module_based_dsg = '||l_module_based_dsg);

      IF l_module_based_dsg = 'Y' THEN
        l_falling_into_the_group :=
          check_created_by_module_cr (
            p_dss_group_code        => l_dss_group_code,
            p_parent_party_id_tbl   => l_parent_party_id_tbl,
            p_parent_party_type_tbl => l_parent_party_type_tbl
          );

        IF l_falling_into_the_group = 'N' THEN
          print('l_falling_into_the_group = N, l_failure_reason=CREATED_BY_MODULE, GOTO next_fetch');
          l_failure_reason := 'CREATED_BY_MODULE';
          GOTO next_fetch;
        ELSE
          print('l_falling_into_the_group = Y, continue');
          NULL;
        END IF;
      END IF;

      --
      -- check if it is classification based
      --
      OPEN c_check_classification(l_dss_group_code);
      FETCH c_check_classification INTO l_dummy;
      IF c_check_classification%NOTFOUND THEN
        l_class_based_dsg := 'N';
      ELSE
        l_class_based_dsg := 'Y';
      END IF;
      CLOSE c_check_classification;

      --
      -- debug messages
      --
       print('class_based_dsg = '||l_class_based_dsg);

      IF l_class_based_dsg = 'Y' THEN
        l_falling_into_the_group :=
          check_classification_cr (
            p_dss_group_code        => l_dss_group_code,
            p_parent_party_id_tbl   => l_parent_party_id_tbl,
            p_parent_party_type_tbl => l_parent_party_type_tbl
          );

        IF l_falling_into_the_group = 'N' THEN
          print('l_falling_into_the_group = N, l_failure_reason=CLASSIFICATION, GOTO next_fetch');
          l_failure_reason := 'CLASSIFICATION';
          GOTO next_fetch;
        ELSE
          print('l_falling_into_the_group = Y, continue');
          NULL;
        END IF;
      END IF;

      --
      -- check if it is relationship type based
      --
      OPEN c_check_relationship_type(l_dss_group_code);
      FETCH c_check_relationship_type INTO l_dummy;
      IF c_check_relationship_type%NOTFOUND THEN
        l_rel_based_dsg := 'N';
      ELSE
        l_rel_based_dsg := 'Y';
      END IF;
      CLOSE c_check_relationship_type;

      --
      -- debug messages
      --
      print('relationship_based_dsg = '||l_rel_based_dsg);

      IF l_rel_based_dsg = 'Y' THEN
        l_falling_into_the_group :=
          check_relationship_type_cr (
            p_dss_group_code        => l_dss_group_code,
            p_db_object_name        => l_db_object_name,
            p_object_pk1            => l_object_pk1,
            p_object_pk2            => l_object_pk2,
            p_object_pk3            => l_object_pk3,
            p_object_pk4            => l_object_pk4,
            p_object_pk5            => l_object_pk5,
            p_parent_party_id_tbl   => l_parent_party_id_tbl,
            p_parent_party_type_tbl => l_parent_party_type_tbl
          );

        IF l_falling_into_the_group = 'N' THEN
          l_failure_reason := 'RELATIONSHIP_TYPE';
          print('l_falling_into_the_group = N, l_failure_reason=RELATIONSHIP_TYPE, GOTO next_fetch');
          GOTO next_fetch;
        ELSE
          print('l_falling_into_the_group = Y, continue');
          NULL;
        END IF;
      END IF;

      IF l_falling_into_the_group = 'Y' THEN
        l_returned_dss_group := l_dss_group_code;
        print('l_falling_into_the_group = Y, Exit Loop l_returned_dss_group='||l_dss_group_code);
        EXIT;
      END IF;

      l_pre_db_object_name := l_db_object_name;
      l_pre_dss_group_code := l_dss_group_code;

      print('Finally: l_pre_db_object_name='||l_pre_db_object_name);
      print('Finally: l_pre_dss_group_code='||l_pre_dss_group_code);
    END LOOP;
    CLOSE c_get_dss_groups;

    IF l_returned_dss_group IS NULL THEN
      print('l_returned_dss_group is NULL, so get profile value for HZ_DEFAULT_DSS_GROUP');
      l_returned_dss_group := FND_PROFILE.VALUE('HZ_DEFAULT_DSS_GROUP');
    END IF;

     print('Finally Return Value l_returned_dss_group:'||l_returned_dss_group);
    RETURN l_returned_dss_group;

END determine_dss_group;


/*===========================================================================+
 | PROCEDURE
 |          assign_dss_group
 |
 | DESCRIPTION
 |          For a given row in a table ,assign the data sharing group
 |          Based on p_process_subentities_flag, it could be assigned to all
 |          the subentities as well
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |           p_db_object_name     VARCHAR2 e.g. HZ_PARTIES
 |           p_object_pk1         VARCHAR2 e.g. 1000
 |           p_object_pk2         VARCHAR2 (if any)
 |           p_object_pk3         VARCHAR2 (if any)
 |           p_object_pk4         VARCHAR2 (if any)
 |           p_object_pk5         VARCHAR2 (if any)
 |           p_root_db_object_name  VARCHAR2 name of the root entity(optional)
 |           p_root_object_pk1    VARCHAR2  Primary key value of root(optional)
 |           p_root_object_pk2    VARCHAR2  Primary key value of root(optional)
 |           p_root_object_pk3    VARCHAR2  Primary key value of root(optional)
 |           p_root_object_pk4    VARCHAR2  Primary key value of root(optional)
 |           p_root_object_pk5    VARCHAR2  Primary key value of root(optional)
 |           p_process_subentities_flag VARCHAR2 Y/N If all child entities need
 |                                               to be processed
 |
 |              OUT:
 |          IN/ OUT:
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY -
 |                       Jyoti Pandey 08-07-2002 Created.
 |
 +===========================================================================*/

PROCEDURE  assign_dss_group(
   p_db_object_name      IN VARCHAR2,
   p_object_pk1          IN VARCHAR2,
   p_object_pk2          IN VARCHAR2,
   p_object_pk3          IN VARCHAR2,
   p_object_pk4          IN VARCHAR2,
   p_object_pk5          IN VARCHAR2,
   p_root_db_object_name IN VARCHAR2,
   p_root_object_pk1     IN VARCHAR2,
   p_root_object_pk2     IN VARCHAR2,
   p_root_object_pk3     IN VARCHAR2,
   p_root_object_pk4     IN VARCHAR2,
   p_root_object_pk5     IN VARCHAR2,
   p_process_subentities_flag IN VARCHAR2) IS

 l_dss_assignment_rec     HZ_DSS_GROUPS_PUB.dss_assignment_type;

 ----** get pk name, fk name ,assignment method for the object name passed**----
 CURSOR  get_grp_assign_level(t_object_name IN VARCHAR2) IS
 SELECT  dse.entity_id, fo.object_id,
         fo.pk1_column_name, fo.pk2_column_name ,
         dse.parent_fk_column1 , dse.parent_fk_column2,
         dse.group_assignment_level
 FROM  fnd_objects fo , hz_dss_entities dse
 WHERE  ( ( dse.object_id IN ( select object_id from fnd_objects
                          where database_object_name = t_object_name) )
      OR
       (dse.instance_set_id in ( select instance_set_id
                                 from fnd_object_instance_sets ois
                                 where ois.object_id IN
                                    (select object_id from fnd_objects
                                     where database_object_name = t_object_name)
                                 )
        )
      )
 AND fo.object_id = dse.object_id
 AND dse.status = 'A';

 l_entity_id              hz_dss_entities.entity_id%type;
 l_object_id              hz_dss_entities.object_id%type;
 l_pk1_column_name        fnd_objects.pk1_column_name%type;
 l_pk2_column_name        fnd_objects.pk2_column_name%type;
 l_parent_fk_column1      hz_dss_entities.parent_fk_column1%type;
 l_parent_fk_column2      hz_dss_entities.parent_fk_column2%type;
 l_group_assignment_level hz_dss_entities.group_assignment_level%type;
 l_dsg_code               hz_dss_secured_entities.dss_group_code%type;
 l_sql varchar2(2000);


  x_assignment_id NUMBER;
  x_return_status varchar2(1);
  x_msg_count number;
  x_msg_data varchar2(2000);

BEGIN

  --determine if the DSG should INHERIT DIRECT ASSIGN
  OPEN get_grp_assign_level(p_db_object_name);
  LOOP

     FETCH get_grp_assign_level INTO l_entity_id, l_object_id,
         l_pk1_column_name, l_pk2_column_name ,
         l_parent_fk_column1 , l_parent_fk_column2, l_group_assignment_level;

     EXIT WHEN get_grp_assign_level%NOTFOUND;

     if  l_group_assignment_level = 'INHERIT' then
         null;  ---don't do anything
         exit;
         close get_grp_assign_level;
     else
         ---Determine the DSG
         l_dsg_code := hz_dss_util_pub.determine_dss_group(
                            p_db_object_name,
                            p_object_pk1,
                            p_object_pk2,
                            p_object_pk3,
                            p_object_pk4,
                            p_object_pk5,
                            p_root_db_object_name,
                            p_root_object_pk1,
                            p_root_object_pk2,
                            p_root_object_pk3,
                            p_root_object_pk4,
                            p_root_object_pk5 );


      end if;   ---- l_group_assignment_level = 'INHERIT'

      if l_dsg_code is not null then

         ---make a callout to HZ_DSS_GROUPS_PUB.create_assignment
         l_dss_assignment_rec.dss_group_code := l_dsg_code;
         l_dss_assignment_rec.assignment_id := null;
         l_dss_assignment_rec.owner_table_name := p_db_object_name;
         l_dss_assignment_rec.owner_table_id1 := p_object_pk1;
         l_dss_assignment_rec.owner_table_id2 := p_object_pk2;
         l_dss_assignment_rec.owner_table_id3 := p_object_pk3;
         l_dss_assignment_rec.owner_table_id4 := p_object_pk4;
         l_dss_assignment_rec.owner_table_id5 := p_object_pk5;
         l_dss_assignment_rec.status          := null;

         if  l_group_assignment_level = 'ASSIGN' then
             HZ_DSS_GROUPS_PUB.create_assignment (
                'T',
                 l_dss_assignment_rec,
                 x_assignment_id        ,
                 x_return_status        ,
                 x_msg_count,
                 x_msg_data);

          elsif l_group_assignment_level = 'DIRECT' then

            begin
              l_sql :=  ' UPDATE ' || p_db_object_name ||
                        ' SET    ' || ' dss_group_code  '  || ' =  :dsg ' ||
                        ' WHERE  ' || l_pk1_column_name|| ' =  :pk ' ;
               EXECUTE IMMEDIATE l_sql USING l_dsg_code ,p_object_pk1;
             exception
              when others then
              raise;
             end ;

          end if;   ---group assignment level

      if  p_process_subentities_flag = 'Y' then

             stamp_child_entities(
             p_entity_id  =>l_entity_id,
             p_object_pk1 =>p_object_pk1,
             p_object_pk2 =>p_object_pk2,
             p_object_pk3 =>p_object_pk3,
             p_object_pk4 =>p_object_pk4,
             p_object_pk5 =>p_object_pk5) ;

      end if;

    end if; ---l_dsg_code
  end  loop;
  close get_grp_assign_level;

  END assign_dss_group;


 --Private Procedures
   PROCEDURE stamp_child_entities(p_entity_id IN NUMBER,
                              p_object_pk1          IN VARCHAR2,
                              p_object_pk2          IN VARCHAR2,
                              p_object_pk3          IN VARCHAR2,
                              p_object_pk4          IN VARCHAR2,
                              p_object_pk5          IN VARCHAR2) IS

  CURSOR get_child_entities(t_entity_id IN NUMBER) IS
  SELECT entity_id,
         fo.database_object_name,
         fo.pk1_column_name,
         fo.pk2_column_name ,
         dse.parent_entity_id , dse.parent_fk_column1 , dse.parent_fk_column2
  FROM  fnd_objects fo , hz_dss_entities dse
  WHERE parent_entity_id is not null
  AND (  dse.object_id is not null and
         fo.object_id = dse.object_id )
  OR    (dse.instance_set_id is not null and
        fo.object_id = ( select distinct object_id from fnd_object_instance_sets
                         where instance_set_id = dse.instance_set_id))
  AND dse.parent_entity_id = t_entity_id
  AND dse.status = 'A'
  order by dse.entity_id;

TYPE child_pk_typ IS REF CURSOR;
 child_pk child_pk_typ;

 l_child_entity_id  NUMBER;
 l_object_id NUMBER;
 l_database_object_name varchar2(55);
 l_pk1_column_name VARCHAR2(50);
 l_pk2_column_name VARCHAR2(50);
 l_parent_entity_id NUMBER;
 l_parent_fk_column1  VARCHAR2(50);
 l_parent_fk_column2 VARCHAR2(50);
 l_new_pk1_value varchar2(30);
 l_new_pk2_value varchar2(30);
 l_sql varchar2(2000);

begin

   OPEN  get_child_entities(p_entity_id);
   LOOP
     FETCH get_child_entities INTO l_child_entity_id,
           l_database_object_name,
           l_pk1_column_name,
           l_pk2_column_name ,
           l_parent_entity_id ,
           l_parent_fk_column1 ,
           l_parent_fk_column2;

           EXIT WHEN get_child_entities%notfound;

           if l_parent_fk_column2 is not null then
             begin
               OPEN child_pk FOR
                 'SELECT ' || l_pk1_column_name ||' , '||
                              nvl(l_pk2_column_name,-1) ||
                ' FROM ' || l_database_object_name||
                ' WHERE '|| l_parent_fk_column1 || '=  :id1 ' ||
                ' AND  ' || l_parent_fk_column2 || '=  :id2 ' USING p_object_pk1 , p_object_pk2;

                 LOOP
                  FETCH child_pk INTO l_new_pk1_value, l_new_pk2_value;

                  EXIT when child_pk%notfound;

                  if l_new_pk2_value = -1 then
                     l_new_pk2_value := null;
                  end if;


                   assign_dss_group(
                    p_db_object_name      => l_database_object_name,
                    p_object_pk1          => l_new_pk1_value,
                    p_object_pk2          => l_new_pk2_value,
                    p_object_pk3          => NULL,
                    p_object_pk4          => NULL,
                    p_object_pk5          => NULL,
                    p_root_db_object_name =>NULL,
                    p_root_object_pk1     =>NULL,
                    p_root_object_pk2     =>NULL,
                    p_root_object_pk3     =>NULL,
                    p_root_object_pk4     =>NULL,
                    p_root_object_pk5     =>NULL,
                    p_process_subentities_flag => 'Y' );

                END LOOP;
                CLOSE child_pk;

                exception when no_data_found then
                null;
             end;
            else
              begin
                OPEN child_pk FOR
                'SELECT ' || l_pk1_column_name || ',' ||
                              nvl(l_pk2_column_name ,-1) ||
                ' FROM ' || l_database_object_name||
                ' WHERE '|| l_parent_fk_column1 || '=  :id1 ' USING p_object_pk1;

                 LOOP
                  FETCH child_pk INTO l_new_pk1_value, l_new_pk2_value;

                  EXIT when child_pk%notfound;

                  assign_dss_group(
                    p_db_object_name      => l_database_object_name,
                    p_object_pk1          => l_new_pk1_value,
                    p_object_pk2          => l_new_pk2_value,
                    p_object_pk3          => NULL,
                    p_object_pk4          => NULL,
                    p_object_pk5          => NULL,
                    p_root_db_object_name =>NULL,
                    p_root_object_pk1     =>NULL,
                    p_root_object_pk2     =>NULL,
                    p_root_object_pk3     =>NULL,
                    p_root_object_pk4     =>NULL,
                    p_root_object_pk5     =>NULL,
                    p_process_subentities_flag => 'Y' );

                  if l_new_pk2_value = -1 then
                     l_new_pk2_value := null;
                  end if;

                 END LOOP;
                CLOSE child_pk;

                exception when no_data_found then
                null;
                end;

            end if;

     end loop;
     close get_child_entities;

  end stamp_child_entities;

/*===========================================================================+
 | PROCEDURE
 |          switch_context
 |
 | DESCRIPTION
 |          For a given user , populate the temporary table HZ_DSS_GROUP_CACHE
 |          with the Data Sharing Groups that the user has SELECT access to
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  :
 |
 |              OUT:
 |          IN/ OUT:
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY -
 |                       Jyoti Pandey 08-07-2002 Created.
 |
 +===========================================================================*/

 procedure switch_context (p_user_name IN VARCHAR2,
                           x_return_status    OUT NOCOPY VARCHAR2,
                           x_msg_count        OUT NOCOPY NUMBER,
                           x_msg_data         OUT NOCOPY VARCHAR2)IS

  x_granted_groups HZ_DSS_UTIL_PUB.dss_group_tbl_type;

  i number;
  l_user_name fnd_user.user_name%type;
  l_return_status VARCHAR2(1);
  l_msg_count NUMBER;
  l_msg_data  VARCHAR2(2000);

begin
  ---initialize the message
  FND_MSG_PUB.initialize;

  --- initialize API return status to success.
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  l_user_name := fnd_global.user_name;

 --clear the temporary table
 ---delete from HZ_DSS_GROUP_CACHE ;

 --determine the DSG's that the user has SELECT access to
  HZ_DSS_UTIL_PUB.get_granted_groups (
     l_user_name,
     'SELECT',
     x_granted_groups,
     l_return_status,
     l_msg_count,
     l_msg_data);


  IF  l_return_status =  FND_API.G_RET_STS_SUCCESS then

    FOR I IN x_granted_groups.first..x_granted_groups.last
    loop
    null;
  --     insert into HZ_DSS_GROUP_CACHE (entity_id , dss_group_code)
  --     values (x_granted_groups(i).entity_id ,
   --            x_granted_groups(i).dss_group_code);

    end loop;
  ELSE
  x_return_status := FND_API.G_RET_STS_ERROR;
  FND_MSG_PUB.Count_And_Get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => x_msg_data);
  END IF;

 exception when others then
 raise;

end switch_context;

/**
 * FUNCTION
 *          generate_predicate
 *
 * DESCRIPTION
 *
 *
 * SCOPE - PUBLIC
 *
 * EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS  : IN:
 *              OUT: T/F
 *          IN/ OUT:
 *
 * RETURNS    : NONE
 *
 * NOTES
 *
 * MODIFICATION HISTORY -
 *    Bug 2630164 changed signature to include msg_count msg data
 *    also included validation for Data sharing group and entity_id
 *
 */

PROCEDURE generate_predicate(
    p_dss_group_code              IN     VARCHAR2,
    p_entity_id                   IN     NUMBER,
    x_predicate                   OUT    NOCOPY VARCHAR2,
    x_return_status               OUT    NOCOPY VARCHAR2,
    x_msg_count                   OUT    NOCOPY NUMBER,
    x_msg_data                    OUT    NOCOPY VARCHAR2
) IS

    CURSOR c_find_objects IS
    SELECT obj.database_object_name ,
           decode(pk1_column_name , null,null,       pk1_column_name) ||
           decode(pk2_column_name , null,null, ','|| pk2_column_name) ||
           decode(pk3_column_name , null,null, ','|| pk3_column_name) ||
           decode(pk4_column_name , null,null, ','|| pk4_column_name) ||
           decode(pk5_column_name , null,null, ','|| pk5_column_name)
    FROM   fnd_objects obj,
           hz_dss_entities dse
    WHERE  dse.entity_id = p_entity_id
    AND    dse.status = 'A'
    AND    dse.object_id IS NOT NULL
    AND    dse.object_id = obj.object_id
    UNION ALL
    SELECT obj.database_object_name ,
           decode(pk1_column_name , null,null,       pk1_column_name) ||
           decode(pk2_column_name , null,null, ','|| pk2_column_name) ||
           decode(pk3_column_name , null,null, ','|| pk3_column_name) ||
           decode(pk4_column_name , null,null, ','|| pk4_column_name) ||
           decode(pk5_column_name , null,null, ','|| pk5_column_name)
    FROM   fnd_object_instance_sets ins,
           fnd_objects obj,
           hz_dss_entities dse
    WHERE  dse.entity_id = p_entity_id
    AND    dse.status = 'A'
    AND    dse.instance_set_id IS NOT NULL
    AND    dse.instance_set_id = ins.instance_set_id
    AND    ins.object_id = obj.object_id;

    l_string                      VARCHAR2(2000);
    l_object_name                 VARCHAR2(30);
    l_sql                         VARCHAR2(2000);

BEGIN

    ---initialize the message
    FND_MSG_PUB.initialize;

    --- initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --- validation passed in group code should be valid
    IF HZ_DSS_VALIDATE_PKG.exist_in_dss_groups_b(p_dss_group_code)= 'N' THEN
      FND_MESSAGE.SET_NAME('AR', 'HZ_DSS_GR_CODE_INVALID');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- entity id validation
    IF HZ_DSS_VALIDATE_PKG.exist_in_dss_entities(p_entity_id)  = 'N' THEN
      FND_MESSAGE.SET_NAME('AR', 'HZ_DSS_ENT_ID_INVALID');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    OPEN c_find_objects;
    FETCH c_find_objects INTO l_object_name, l_string;
    CLOSE c_find_objects;

    ---Determine the DSG
    l_sql := 'hz_dss_util_pub.determine_dss_group(' ||
                ''''||l_object_name||'''' || ',' ||
                l_string ||
             ') = ' || ''''||p_dss_group_code || '''';

    ------------------------------------------------------------------------
    ---HR's validation: check if the Data Sharing Group is HR_SHARED then it
    ---should pass HR's Created by module test also
    ---a similar check is performed in party_validate too
    ------------------------------------------------------------------------

    IF p_dss_group_code = 'HR_SHARED' THEN
      ---get the user's module
      l_sql := l_sql || ' AND '||
               'NVL(fnd_profile.value(''HZ_CREATED_BY_MODULE''), ''-222'')' ||
               ' = ''HR API'' ';
    END IF;

    -- Build and test the sql statement to make sure generated predicate
    -- is valid
    -- l_sql_to_test := ' select 1  from   ' ||l_object_name || ' where '|| l_sql ;
    -- c := dbms_sql.open_cursor;
    -- dbms_sql.parse(c, l_sql_to_test, dbms_sql.native);

    x_return_status := FND_API.G_RET_STS_SUCCESS;
    x_predicate := l_sql ;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;

    FND_MSG_PUB.COUNT_AND_GET(
      p_encoded                    => fnd_api.g_false,
      p_count                      => x_msg_count,
      p_data                       => x_msg_data
    );

  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
    FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
    FND_MSG_PUB.ADD;

    FND_MSG_PUB.COUNT_AND_GET(
      p_encoded                    => fnd_api.g_false,
      p_count                      => x_msg_count,
      p_data                       => x_msg_data
    );

END generate_predicate;

/**
 * PROCEDURE
 *         print
 *
 * DESCRIPTION
 *
 *
 * SCOPE - PRIVATE
 *
 * EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS  : IN:
 *              OUT: T/F
 *          IN/ OUT:
 *
 * RETURNS    : NONE
 *
 * NOTES
 *
 * MODIFICATION HISTORY -
 *
 */

PROCEDURE print (
    p_str                         IN     VARCHAR2
) IS

    j                             NUMBER;

BEGIN
    j := 1;

    FOR i IN 1..CEIL(length(p_str)/255) LOOP
      -- dbms_output.put_line( SUBSTR( p_str, j, 255 ) );
      j := j + 255;
    END LOOP;

     IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
 	         hz_utility_v2pub.debug(p_prefix=>'HZDSS',p_message=>SUBSTR( p_str, j, 255 ) ,
 	                                p_msg_level=>fnd_log.level_statement);
 	 END IF;

END print;


/**
 * FUNCTION
 *         check_created_by_module_cr
 *
 * DESCRIPTION
 *
 *
 * SCOPE - PRIVATE
 *
 * EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS  : IN:
 *              OUT: T/F
 *          IN/ OUT:
 *
 * RETURNS    : NONE
 *
 * NOTES
 *
 * MODIFICATION HISTORY -
 *
 */

FUNCTION check_created_by_module_cr (
    p_dss_group_code              IN     VARCHAR2,
    p_parent_party_id_tbl         IN     t_number_tbl,
    p_parent_party_type_tbl       IN     t_varchar_30_tbl
) RETURN VARCHAR2 IS

    CURSOR c_check_created_by_modules (
      p_party_id                  NUMBER,
      p_dss_group_code            VARCHAR2
    ) IS
    SELECT 1
    FROM   hz_parties p, hz_dss_criteria dc
    WHERE  p.party_id = p_party_id
    AND    p.created_by_module IN (
      SELECT owner_table_id2
      FROM   hz_dss_criteria
      WHERE  dss_group_code = p_dss_group_code
      AND    owner_table_name = 'AR_LOOKUPS'
      AND    owner_table_id1 = 'HZ_CREATED_BY_MODULES'
      AND    status = 'A');

    l_falling_into_the_group      VARCHAR2(2);
    l_found_non_rel_party         VARCHAR2(1);
    l_dummy                       NUMBER(1);

BEGIN

    l_falling_into_the_group := 'N';
    l_found_non_rel_party := 'N';

    FOR i IN 1..p_parent_party_id_tbl.COUNT LOOP
      IF p_parent_party_type_tbl(i) <> 'PARTY_RELATIONSHIP' THEN
        l_found_non_rel_party := 'Y';

        OPEN c_check_created_by_modules(p_parent_party_id_tbl(i), p_dss_group_code);
        FETCH c_check_created_by_modules INTO l_dummy;
        IF c_check_created_by_modules%FOUND THEN
          CLOSE c_check_created_by_modules;
          l_falling_into_the_group := 'Y';
          EXIT;
        END IF;
        CLOSE c_check_created_by_modules;
      ELSE -- added for better debugging
 	         print('check_created_by_module_cr:'||p_parent_party_id_tbl(i)||'-PARTY_RELATIONSHIP..skipped');
 	         NULL;
      END IF;
    END LOOP;

    IF l_found_non_rel_party = 'N' THEN
      l_falling_into_the_group := 'NA';
    END IF;

     print('check_created_by_module_cr - '||l_falling_into_the_group);

    RETURN l_falling_into_the_group;

END check_created_by_module_cr;


/**
 * FUNCTION
 *         check_classifications
 *
 * DESCRIPTION
 *
 *
 * SCOPE - PRIVATE
 *
 * EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS  : IN:
 *              OUT: T/F
 *          IN/ OUT:
 *
 * RETURNS    : NONE
 *
 * NOTES
 *
 * MODIFICATION HISTORY -
 * 17-SEP-2008  Sudhir Gokavarapu  Bug 7290836: Changed l_class_code_is_used check
 *                                 from N to Y for EXIT criteria.
 *                                 Added 'order by' to c_sub_class_codes cursor for
 *                                 performance reason. We do not want to travese
 *                                 all subcodes if parnet code is securing criteria
 *                                 and is assigned to the party.
 *
 */

FUNCTION check_classifications (
    p_dss_group_code              IN     VARCHAR2,
    p_party_id                    IN     NUMBER
) RETURN VARCHAR2 IS

    CURSOR c_check_classifications (
      p_party_id                  NUMBER,
      p_class_category            VARCHAR2,
      p_class_code                VARCHAR2
    ) IS
    SELECT 1
    FROM   hz_code_assignments
    WHERE  owner_table_name = 'HZ_PARTIES'
    AND    owner_table_id = p_party_id
    AND    class_category = p_class_category
    AND    class_code = p_class_code
    AND    SYSDATE BETWEEN
             NVL(start_date_active, SYSDATE) AND NVL(end_date_active, SYSDATE)
    AND    status = 'A';

    --
    -- Get the classification codes for the data sharing group
    --
    CURSOR c_class_codes_for_dsg (
      p_dss_group_code            VARCHAR2
    ) IS
    SELECT dsc.owner_table_id1 , dsc.owner_table_id2
    FROM   hz_dss_criteria dsc
    WHERE  dsc.dss_group_code = p_dss_group_code
    AND    owner_table_name = 'FND_LOOKUP_VALUES'
    AND    status = 'A';

    --
    -- get child class codes
    --
    CURSOR c_sub_class_codes (
      p_class_category            VARCHAR2,
      p_class_code                VARCHAR2
    ) IS
    SELECT class_code
    FROM   hz_class_code_denorm ccd
    WHERE  ccd.class_category = p_class_category
    AND    INSTRB('/'||concat_class_code||'/','/'||p_class_code||'/') > 0
    AND    LANGUAGE = userenv('LANG')
    ORDER BY concat_class_code; -- Bug 7290836(no need to fetch more rec if
 	                          -- parent class code was assigned to party)

    l_dummy                       NUMBER(1);
    l_class_code_is_used          VARCHAR2(1);
    l_class_category_tbl          t_varchar_30_tbl;
    l_class_code_tbl              t_varchar_30_tbl;
    l_sub_class_code_tbl          t_varchar_30_tbl;
    l_falling_into_the_group      VARCHAR2(2);

BEGIN

    l_falling_into_the_group := 'N';

    OPEN c_class_codes_for_dsg(p_dss_group_code);
    FETCH c_class_codes_for_dsg BULK COLLECT INTO
      l_class_category_tbl, l_class_code_tbl;
    CLOSE c_class_codes_for_dsg;

    --
    -- all class codes (or its sub class codes) in a dsg must
    -- be assigned to the party
    --
    FOR i IN 1..l_class_category_tbl.COUNT LOOP
      l_class_code_is_used := 'N';

      OPEN c_sub_class_codes(l_class_category_tbl(i), l_class_code_tbl(i));
      FETCH c_sub_class_codes BULK COLLECT INTO l_sub_class_code_tbl;
      CLOSE c_sub_class_codes;

      FOR j IN 1..l_sub_class_code_tbl.COUNT LOOP
        OPEN c_check_classifications(p_party_id, l_class_category_tbl(i), l_sub_class_code_tbl(j));
        FETCH c_check_classifications INTO l_dummy;

        IF c_check_classifications%FOUND THEN
          CLOSE c_check_classifications;
          l_class_code_is_used := 'Y';
          EXIT;
        END IF;
        CLOSE c_check_classifications;
      END LOOP;

--      IF l_class_code_is_used = 'N' THEN -- Bug 7290836(Should always exist if found a match)
      IF l_class_code_is_used = 'Y' THEN   -- Changed from N to Y
        EXIT;
      END IF;
    END LOOP;

    IF l_class_code_is_used = 'Y' THEN
      l_falling_into_the_group := 'Y';
    END IF;

     print('check_classifications - '||l_falling_into_the_group);

    RETURN l_falling_into_the_group;

END check_classifications;


/**
 * FUNCTION
 *         check_classification_cr
 *
 * DESCRIPTION
 *
 *
 * SCOPE - PRIVATE
 *
 * EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS  : IN:
 *              OUT: T/F
 *          IN/ OUT:
 *
 * RETURNS    : NONE
 *
 * NOTES
 *
 * MODIFICATION HISTORY -
 *
 */

FUNCTION check_classification_cr (
    p_dss_group_code              IN     VARCHAR2,
    p_parent_party_id_tbl         IN     t_number_tbl,
    p_parent_party_type_tbl       IN     t_varchar_30_tbl
) RETURN VARCHAR2 IS

    l_falling_into_the_group      VARCHAR2(2);
    l_found_non_rel_party         VARCHAR2(1);

BEGIN

    l_falling_into_the_group := 'N';
    l_found_non_rel_party := 'N';

    FOR i IN 1..p_parent_party_id_tbl.COUNT LOOP
      IF p_parent_party_type_tbl(i) <> 'PARTY_RELATIONSHIP' THEN
        l_found_non_rel_party := 'Y';

        l_falling_into_the_group :=
          check_classifications(p_dss_group_code, p_parent_party_id_tbl(i));

        IF l_falling_into_the_group = 'Y' THEN
          EXIT;
        END IF;
     ELSE -- added for better debugging
 	         print('check_classification_cr:'||p_parent_party_id_tbl(i)||'-PARTY_RELATIONSHIP..skipped');
 	         NULL;
      END IF;
    END LOOP;

    IF l_found_non_rel_party = 'N' THEN
      l_falling_into_the_group := 'NA';
    END IF;

     print('check_classification_cr - '||l_falling_into_the_group);

    RETURN l_falling_into_the_group;

END check_classification_cr;


/**
 * FUNCTION
 *         check_relationship_types
 *
 * DESCRIPTION
 *
 *
 * SCOPE - PRIVATE
 *
 * EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS  : IN:
 *              OUT: T/F
 *          IN/ OUT:
 *
 * RETURNS    : NONE
 *
 * NOTES
 *
 * MODIFICATION HISTORY -
   13-FEB-2007    Nishant Singhai  Bug 5687869
                  If same subject id and object id have 2 different relationships,
                  and only 1 of them is secured, then security rules get applied
				  either to both  or none (based on randomly which record gets
				  picked up first).
                  For example, if 1 is updateable while other is not,
                  without relationship id filter, behaviour is random and
				  either both becomes updateable or both becomes non-updateable.
   25-Mar-2010  Sudhir Gokavarapu  Bug#8837776 FP for Bug 8797990
 	                   Changes made for bug 5687869 is causing regression in other
 	                   entity checks (other than Relationship). If any 'Relationship
 	                   Role' criteria is met, all the entities which are marked to be
 	                   secured should be secured. Securing only 1 relationship and
 	                   leaving rest open is not the design of DSS.
 	                   Additionally, enhanced the support for securing entities
 	                                   hanging from Relationship Party (like Contact Point for Org Contacts)
 	                                   Since relationship party cannot have 'Relationship Criteria'
 	                                   attached to it. So, there is no way to secure them. In that case,
 	                                   check if parties forming the relationship meets the "Relationship
 	                                   Security Criteria".
 *
 */


FUNCTION check_relationship_types (
    p_dss_group_code              IN     VARCHAR2,
    p_party_id                    IN     NUMBER
    --,p_relationship_id            IN     NUMBER  -- Bug 5687869 (Nishant)
) RETURN VARCHAR2 IS

    CURSOR c_check_relationship_types_p (
      p_party_id                  NUMBER,
      p_relationship_type_id      NUMBER
      --,p_relationship_id          NUMBER  -- Bug 5687869 (Nishant)
    ) IS
--    SELECT 1
    /*SELECT rel.relationship_type -- changed so that it is easy to debug
    FROM   hz_relationships rel
    WHERE  rel.subject_id = p_party_id AND
           rel.subject_table_name = 'HZ_PARTIES'
    AND    rel.relationship_id = p_relationship_id  -- added for Bug 5687869
    AND    (rel.relationship_type, rel.relationship_code, rel.subject_type, rel.object_type) IN (
      SELECT relationship_type, forward_rel_code,
             subject_type, object_type
      FROM   hz_relationship_types rt
      WHERE  rt.relationship_type_id = p_relationship_type_id)
    AND    SYSDATE BETWEEN
             NVL(start_date, SYSDATE) AND NVL(end_date, SYSDATE)
    AND    status = 'A'
    AND    ROWNUM = 1;
 */
  	     --Changes for bug 8837776/8797990
 	     SELECT rel.relationship_code -- changed so that it is easy to debug
 	     FROM   hz_relationships rel
 	     WHERE  p_party_id IN (rel.subject_id, rel.object_id)
 	         AND    rel.subject_table_name = 'HZ_PARTIES'
 	         AND    rel.object_table_name = 'HZ_PARTIES'
 	         AND    rel.directional_flag = 'F'
 	     AND    (rel.relationship_type, rel.relationship_code, rel.subject_type, rel.object_type) IN (
 	             SELECT relationship_type, forward_rel_code,
 	                    subject_type, object_type
 	             FROM   hz_relationship_types rt
 	             WHERE  rt.relationship_type_id = p_relationship_type_id)
 	     AND    SYSDATE BETWEEN
 	              NVL(rel.start_date, SYSDATE) AND NVL(rel.end_date, SYSDATE)
 	     AND    rel.status = 'A'
 	     AND    ROWNUM = 1;

    CURSOR c_dss_relationship_types (
      p_dss_group_code            VARCHAR2
    ) IS
    SELECT owner_table_id1
    FROM   hz_dss_criteria dsc
    WHERE  dsc.owner_table_name = 'HZ_RELATIONSHIP_TYPES'
    AND    dsc.dss_group_code = p_dss_group_code
    AND    dsc.status = 'A';

    l_falling_into_the_group      VARCHAR2(2);
    l_dummy                       NUMBER(1);
    l_dummy_varchar               VARCHAR2(100);
    l_relationship_type_id_tbl    t_number_tbl;

BEGIN
     print('BEGIN check_relationship_types');
     print('p_dss_group_code='||p_dss_group_code||', p_party_id='||p_party_id);

    OPEN c_dss_relationship_types(p_dss_group_code);
    FETCH c_dss_relationship_types BULK COLLECT INTO l_relationship_type_id_tbl;
    CLOSE c_dss_relationship_types;

    l_falling_into_the_group := 'N'; --'Y';
    print('Set Initial l_falling_into_the_group=N');

    IF l_relationship_type_id_tbl.Count > 0 THEN
 	       print('Relationship role criteria is defined. Check further if party falls in this');
        FOR i IN 1..l_relationship_type_id_tbl.COUNT LOOP
          -- debug message
          --
          --
           print ('relationship_type_id = '||l_relationship_type_id_tbl(i));

            -- re-initialize the dummy variable
                  l_dummy_varchar := NULL;

          OPEN c_check_relationship_types_p(
               p_party_id, l_relationship_type_id_tbl(i)); -- Bug 8797990
            -- p_party_id, l_relationship_type_id_tbl(i),p_relationship_id); --(Bug 5687869)
          FETCH c_check_relationship_types_p INTO l_dummy_varchar; --l_dummy;
            print('Validated against relationship type :'||l_dummy_varchar);
            -- Continue the loop to check if any of the relationship roles are secured
            IF c_check_relationship_types_p%FOUND THEN
              l_falling_into_the_group := 'Y';
              print('c_check_relationship_types_p%FOUND..l_falling_into_the_group=Y.. exit');
              CLOSE c_check_relationship_types_p;
              EXIT;
            ELSE -- NOTFOUND
                    l_falling_into_the_group := 'N';
                    print('c_check_relationship_types_p%NOTFOUND..l_falling_into_the_group=N..continue loop');
          END IF;
          CLOSE c_check_relationship_types_p;
        END LOOP;
    ELSE      -- no relationship role criteria defined
 	       NULL;
 	       print('no relationship role criteria defined..');
    END IF;

      -- debug message
      --
      print('Finally l_falling_into_the_group='||l_falling_into_the_group);
      print('END check_relationship_types');

    RETURN l_falling_into_the_group;

END check_relationship_types;


/**
 * FUNCTION
 *         check_relationship_type_cr
 *
 * DESCRIPTION
 *
 *
 * SCOPE - PRIVATE
 *
 * EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS  : IN:
 *              OUT: T/F
 *          IN/ OUT:
 *
 * RETURNS    : NONE
 *
 * NOTES
 *
 * MODIFICATION HISTORY -
 * 25-Mar-2010    Sudhir Gokavarapu 8837776 FP for Bug 8797990
 *                details in check_relationship_types MOD History
 *
 */


FUNCTION check_relationship_type_cr (
    p_dss_group_code              IN     VARCHAR2,
    p_db_object_name              IN     VARCHAR2,
    p_object_pk1                  IN     VARCHAR2 DEFAULT NULL,
    p_object_pk2                  IN     VARCHAR2 DEFAULT NULL,
    p_object_pk3                  IN     VARCHAR2 DEFAULT NULL,
    p_object_pk4                  IN     VARCHAR2 DEFAULT NULL,
    p_object_pk5                  IN     VARCHAR2 DEFAULT NULL,
    p_parent_party_id_tbl         IN     t_number_tbl,
    p_parent_party_type_tbl       IN     t_varchar_30_tbl
) RETURN VARCHAR2 IS

    CURSOR c_get_subj_obj_id (
 	       p_party_id                  NUMBER
 	     )   IS
 	     -- since relationship_party cannot have additional relationships
 	     -- we do not anticipate multiple records to be present for relationship
 	     -- party_id
 	     SELECT subject_id, object_id
 	     FROM   hz_relationships rel
 	     WHERE  rel.party_id = p_party_id
 	     AND    rel.directional_flag = 'F'
 	     AND    SYSDATE BETWEEN
 	              NVL(rel.start_date, SYSDATE) AND NVL(rel.end_date, SYSDATE)
 	     AND    rel.status = 'A'
 	     AND    ROWNUM = 1;
    /*
    CURSOR c_check_relationship_types_o (
      p_party_id                  NUMBER,
      p_dss_group_code            VARCHAR2
    ) IS
    -- SELECT 1 (Bug 5687869)
    SELECT rel.relationship_type
    FROM   hz_relationships rel
    WHERE  rel.party_id = p_party_id
    AND    rel.relationship_id = p_object_pk1  --(Bug 5687869)
    AND    (rel.relationship_type, rel.relationship_code, rel.subject_type, rel.object_type) IN (
      SELECT relationship_type, forward_rel_code,
             subject_type, object_type
      FROM   hz_relationship_types rt, hz_dss_criteria dsc
      WHERE  dsc.owner_table_name = 'HZ_RELATIONSHIP_TYPES'
      AND    dsc.dss_group_code = p_dss_group_code
      AND    dsc.owner_table_id1 = rt.relationship_type_id
      AND    dsc.status = 'A' )
    AND    SYSDATE BETWEEN
             NVL(start_date, SYSDATE) AND NVL(end_date, SYSDATE)
    AND    status = 'A';

    */
    -- Get the subject_id and object_id of the relationship party
 	     -- Then check relationship security criteria on both the parties
 	     CURSOR c_check_relationship_types_o (
 	       p_subj_id                  NUMBER,
 	       p_obj_id                   NUMBER,
 	       p_dss_group_code           VARCHAR2
 	     ) IS
 	     SELECT rel.relationship_code -- changed so that it is easy to debug
 	     FROM   hz_relationships rel
 	     WHERE  p_subj_id IN (rel.subject_id, rel.object_id)
 	         AND    rel.subject_table_name = 'HZ_PARTIES'
 	         AND    rel.object_table_name = 'HZ_PARTIES'
 	         AND    rel.directional_flag = 'F'
 	     AND    (rel.relationship_type, rel.relationship_code, rel.subject_type, rel.object_type) IN (
 	             SELECT relationship_type, forward_rel_code,
 	                    subject_type, object_type
 	             FROM   hz_relationship_types rt, hz_dss_criteria dsc
 	             WHERE  dsc.owner_table_name = 'HZ_RELATIONSHIP_TYPES'
 	             AND    dsc.dss_group_code = p_dss_group_code
 	             AND    dsc.owner_table_id1 = rt.relationship_type_id
 	             AND    dsc.status = 'A')
 	     AND    SYSDATE BETWEEN
 	              NVL(rel.start_date, SYSDATE) AND NVL(rel.end_date, SYSDATE)
 	     AND    rel.status = 'A'
 	     AND    ROWNUM = 1
 	     UNION
 	     SELECT rel.relationship_code -- changed so that it is easy to debug
 	     FROM   hz_relationships rel
 	     WHERE  p_obj_id IN (rel.subject_id, rel.object_id)
 	         AND    rel.subject_table_name = 'HZ_PARTIES'
 	         AND    rel.object_table_name = 'HZ_PARTIES'
 	         AND    rel.directional_flag = 'F'
 	     AND    (rel.relationship_type, rel.relationship_code, rel.subject_type, rel.object_type) IN (
 	             SELECT relationship_type, forward_rel_code,
 	                    subject_type, object_type
 	             FROM   hz_relationship_types rt, hz_dss_criteria dsc
 	             WHERE  dsc.owner_table_name = 'HZ_RELATIONSHIP_TYPES'
 	             AND    dsc.dss_group_code = p_dss_group_code
 	             AND    dsc.owner_table_id1 = rt.relationship_type_id
 	             AND    dsc.status = 'A')
 	     AND    SYSDATE BETWEEN
 	              NVL(rel.start_date, SYSDATE) AND NVL(rel.end_date, SYSDATE)
 	     AND    rel.status = 'A'
 	     AND    ROWNUM = 1;

    l_falling_into_the_group      VARCHAR2(2);
    l_dummy_varchar               VARCHAR2(100);
    l_dummy                       NUMBER(1);
	l_subj_id                     NUMBER;
 	l_obj_id                      NUMBER;
BEGIN

    --
    -- debug message
    --

    print ('BEGIN check_relationship_type_cr ...');
    print ('p_db_object_name = '||p_db_object_name||' '||
           'p_object_pk1 = '||p_object_pk1);


    l_falling_into_the_group := 'N';

    FOR i IN 1..p_parent_party_id_tbl.COUNT LOOP
      IF p_parent_party_type_tbl(i) = 'PARTY_RELATIONSHIP' THEN
       -- debug messages
         print('PARTY_TYPE:PARTY_RELATIONSHIP..checking cursor c_check_relationship_types_o');
        print('CURSOR parameter p_party_id='||p_parent_party_id_tbl(i));
        print('CURSOR parameter p_dss_group_code='||p_dss_group_code);

        -- initialize
 	         l_subj_id := NULL;
 	         l_obj_id  := NULL;
 	         OPEN c_get_subj_obj_id(p_parent_party_id_tbl(i));
 	         FETCH c_get_subj_obj_id INTO l_subj_id, l_obj_id;

 	         print ('Subject_id ='||l_subj_id||' ,Object_id ='||l_obj_id||
 	                        ' FOR party_id='||p_parent_party_id_tbl(i));

 	         IF  c_get_subj_obj_id%FOUND THEN

 	           print('c_get_subj_obj_id FOUND..checking rel criteria for subject_id as well as object_id');
 	           l_dummy_varchar := NULL;


                OPEN c_check_relationship_types_o(
                  --p_parent_party_id_tbl(i), p_dss_group_code);
                   l_subj_id, l_obj_id, p_dss_group_code);
                FETCH c_check_relationship_types_o INTO l_dummy_varchar; --l_dummy;

                print('Validated against relationship code :'||l_dummy_varchar);

                IF c_check_relationship_types_o%FOUND THEN
                  print('c_check_relationship_types_o FOUND..l_falling_into_the_group=Y..exit ');
                 l_falling_into_the_group := 'Y';
                 CLOSE c_check_relationship_types_o;
                 EXIT;
                ELSE -- NOTFOUND.. Continue
                  print('c_check_relationship_types_o NOTFOUND..l_falling_into_the_group=N ');
                  NULL;
                END IF;
                CLOSE c_check_relationship_types_o;
                ELSE
                  NULL;
                  print('c_get_subj_obj_id: Rel Rec NOTFOUND..skipped relationship criteria check for party_id='||
                  p_parent_party_id_tbl(i));
 	          END IF;

 	    CLOSE c_get_subj_obj_id;

      ELSE  -- not relationship party
       -- debug messages
        print('PARTY_TYPE='||p_parent_party_type_tbl(i)||'..checking function check_relationship_types');
        print('CURSOR parameter p_party_id='||p_parent_party_id_tbl(i));
        print('CURSOR parameter p_dss_group_code='||p_dss_group_code);

        l_falling_into_the_group :=
          check_relationship_types(p_dss_group_code, p_parent_party_id_tbl(i)); -- Bug 8797990
           --check_relationship_types(p_dss_group_code, p_parent_party_id_tbl(i),p_object_pk1); --(Bug 5687869)

        IF l_falling_into_the_group = 'Y' THEN
          print('l_falling_into_the_group=Y..exit');
          EXIT;
        END IF;
      END IF;
    END LOOP;

    print('Finally check_relationship_type_cr - '||l_falling_into_the_group);
    print('END check_relationship_type_cr');

    RETURN l_falling_into_the_group;

END check_relationship_type_cr;


/**
 * FUNCTION
 *         is_relationship_party
 *
 * DESCRIPTION
 *
 *
 * SCOPE - PRIVATE
 *
 * EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS  : IN:
 *              OUT: T/F
 *          IN/ OUT:
 *
 * RETURNS    : NONE
 *
 * NOTES
 *
 * MODIFICATION HISTORY -
 *
 */

FUNCTION is_relationship_party (
    p_party_id                    IN     NUMBER,
    x_relationship_id             OUT    NOCOPY NUMBER
) RETURN VARCHAR2 IS

    CURSOR c_party (
      p_party_id                  NUMBER
    ) IS
    SELECT party_type
    FROM   hz_parties
    WHERE  party_id = p_party_id;

    CURSOR c_relationship_party (
      p_party_id                  NUMBER
    ) IS
    SELECT relationship_id
    FROM   hz_relationships
    WHERE  party_id = p_party_id
    AND    directional_flag = 'F';

    l_party_type                  VARCHAR2(30);
    l_is_relationship_party       VARCHAR2(1);

BEGIN

    l_is_relationship_party := 'N';

    OPEN c_party(p_party_id);
    FETCH c_party INTO l_party_type;
    CLOSE c_party;

    IF l_party_type IS NOT NULL THEN
      IF l_party_type <> 'PARTY_RELATIONSHIP' THEN
        l_is_relationship_party := 'N';
      ELSE
        l_is_relationship_party := 'Y';

        OPEN c_relationship_party(p_party_id);
        FETCH c_relationship_party INTO x_relationship_id;
        CLOSE c_relationship_party;
      END IF;
    END IF;

    RETURN l_is_relationship_party;

END is_relationship_party;


/**
 * PROCEDURE
 *         get_parent_party_id
 *
 * DESCRIPTION
 *
 *
 * SCOPE - PRIVATE
 *
 * EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS  : IN:
 *              OUT: T/F
 *          IN/ OUT:
 *
 * RETURNS    : NONE
 *
 * NOTES
 *
 * MODIFICATION HISTORY -
 *
 */

PROCEDURE get_parent_party_id (
    p_db_object_name              IN     VARCHAR2,
    p_object_pk1                  IN     VARCHAR2 DEFAULT NULL,
    p_object_pk2                  IN     VARCHAR2 DEFAULT NULL,
    p_object_pk3                  IN     VARCHAR2 DEFAULT NULL,
    p_object_pk4                  IN     VARCHAR2 DEFAULT NULL,
    p_object_pk5                  IN     VARCHAR2 DEFAULT NULL,
    x_party_id_tbl                OUT    NOCOPY t_number_tbl,
    x_party_type_tbl              OUT    NOCOPY t_varchar_30_tbl
) IS

    CURSOR c_party (
      p_party_id                  NUMBER
    ) IS
    SELECT party_id, party_type
    FROM   hz_parties
    WHERE  party_id = p_party_id;

    CURSOR c_party_site (
      p_party_site_id             NUMBER
    ) IS
    SELECT p.party_id, p.party_type
    FROM   hz_party_sites ps, hz_parties p
    WHERE  party_site_id = p_party_site_id
    AND    ps.party_id = p.party_id;

    CURSOR c_location (
      p_location_id               NUMBER
    ) IS
    SELECT p.party_id, p.party_type
    FROM   hz_locations loc, hz_party_sites ps, hz_parties p
    WHERE  loc.location_id = p_location_id
    AND    loc.location_id = ps.location_id
    AND    ps.party_id = p.party_id;

    CURSOR c_code_assignment (
      p_code_assignment_id         NUMBER
    ) IS
    SELECT p.party_id, p.party_type
    FROM   hz_code_assignments, hz_parties p
    WHERE  code_assignment_id = p_code_assignment_id
    AND    owner_table_name = 'HZ_PARTIES'
    AND    owner_table_id = p.party_id;

    CURSOR c_relationship (
      p_relationship_id           NUMBER,
      p_directional_flag          VARCHAR2
    ) IS
    SELECT subject_id, subject_table_name, subject_type,
           object_id, object_table_name, object_type
    FROM   hz_relationships
    WHERE  relationship_id = p_relationship_id
    AND    directional_flag = p_directional_flag
    AND    (subject_table_name = 'HZ_PARTIES' OR
            object_table_name = 'HZ_PARTIES');

    CURSOR c_contact_point (
      p_contact_point_id          NUMBER
    ) IS
    SELECT p.party_id, p.party_type
    FROM   hz_contact_points, hz_parties p
    WHERE  contact_point_id = p_contact_point_id
    AND    owner_table_name = 'HZ_PARTIES'
    AND    owner_table_id = p.party_id;

    CURSOR c_contact_point_ps (
      p_contact_point_id          NUMBER
    ) IS
    SELECT p.party_id, p.party_type
    FROM   hz_contact_points cp, hz_party_sites ps, hz_parties p
    WHERE  contact_point_id = p_contact_point_id
    AND    owner_table_name = 'HZ_PARTY_SITES'
    AND    owner_table_id = ps.party_site_id
    AND    ps.party_id = p.party_id;

    i                             NUMBER;
    l_subject_id                  NUMBER;
    l_subject_table_name          VARCHAR2(30);
    l_subject_type                VARCHAR2(30);
    l_object_id                   NUMBER;
    l_object_table_name           VARCHAR2(30);
    l_object_type                 VARCHAR2(30);

BEGIN

    IF p_db_object_name = 'HZ_PARTIES' THEN
      OPEN c_party(TO_NUMBER(p_object_pk1));
      FETCH c_party BULK COLLECT INTO x_party_id_tbl, x_party_type_tbl;
      CLOSE c_party;

    ELSIF p_db_object_name = 'HZ_PARTY_SITES' THEN
      OPEN c_party_site(TO_NUMBER(p_object_pk1));
      FETCH c_party_site BULK COLLECT INTO x_party_id_tbl, x_party_type_tbl;
      CLOSE c_party_site;

    ELSIF p_db_object_name = 'HZ_LOCATIONS' THEN
      OPEN c_location(TO_NUMBER(p_object_pk1));
      FETCH c_location BULK COLLECT INTO x_party_id_tbl, x_party_type_tbl;
      CLOSE c_location;

    ELSIF p_db_object_name = 'HZ_CODE_ASSIGNMENTS' THEN
      OPEN c_code_assignment(TO_NUMBER(p_object_pk1));
      FETCH c_code_assignment BULK COLLECT INTO x_party_id_tbl, x_party_type_tbl;
      CLOSE c_code_assignment;

    ELSIF p_db_object_name = 'HZ_RELATIONSHIPS' THEN
      OPEN c_relationship(TO_NUMBER(p_object_pk1), p_object_pk2);
      FETCH c_relationship INTO
        l_subject_id, l_subject_table_name, l_subject_type,
        l_object_id, l_object_table_name, l_object_type;
      CLOSE c_relationship;

      i := 1;
      IF l_subject_table_name = 'HZ_PARTIES' THEN
        x_party_id_tbl(i) := l_subject_id;
        x_party_type_tbl(i) := l_subject_type;
        i := i+1;
      END IF;
      IF l_object_table_name = 'HZ_PARTIES' THEN
        x_party_id_tbl(i) := l_object_id;
        x_party_type_tbl(i) := l_object_type;
        i := i+1;
      END IF;

      IF i = 3 AND l_subject_id = l_object_id THEN
        x_party_id_tbl.DELETE(2);
        x_party_type_tbl.DELETE(2);
      END IF;

    ELSIF p_db_object_name = 'HZ_CONTACT_POINTS' THEN
      OPEN c_contact_point(TO_NUMBER(p_object_pk1));
      FETCH c_contact_point BULK COLLECT INTO x_party_id_tbl, x_party_type_tbl;
      CLOSE c_contact_point;

      IF x_party_id_tbl.COUNT = 0 THEN
        OPEN c_contact_point_ps(TO_NUMBER(p_object_pk1));
        FETCH c_contact_point_ps BULK COLLECT INTO x_party_id_tbl, x_party_type_tbl;
        CLOSE c_contact_point_ps;
      END IF;

    END IF;

END get_parent_party_id;


/**
 * FUNCTION
 *          get_display_name
 *
 * DESCRIPTION
 *          return the display name of an object or an object instance set.
 *
 *
 * SCOPE - PUBLIC
 *
 * EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS  : IN:
 *                 p_object_name           object name
 *                 p_object_instance_name  object instance name
 *
 * RETURNS    : NONE
 *
 * NOTES
 *
 * MODIFICATION HISTORY -
 *
 */

FUNCTION get_display_name (
    p_object_name                 IN     VARCHAR2,
    p_object_instance_name        IN     VARCHAR2
) RETURN VARCHAR2 IS

    CURSOR c_objects IS
    SELECT display_name
    FROM   fnd_objects_vl
    WHERE  obj_name = p_object_name;

    CURSOR c_object_instance_sets IS
    SELECT display_name
    FROM   fnd_object_instance_sets_vl
    WHERE  instance_set_name = p_object_instance_name;

    l_return                      VARCHAR2(300);

BEGIN

    IF p_object_instance_name IS NOT NULL THEN
      OPEN c_object_instance_sets;
      FETCH c_object_instance_sets INTO l_return;
      IF c_object_instance_sets%NOTFOUND THEN
        l_return := NULL;
      END IF;
      CLOSE c_object_instance_sets;
    ELSIF p_object_name IS NOT NULL THEN
      OPEN c_objects;
      FETCH c_objects INTO l_return;
      IF c_objects%NOTFOUND THEN
        l_return := NULL;
      END IF;
      CLOSE c_objects;
    END IF;

    RETURN l_return;

END get_display_name;

END HZ_DSS_UTIL_PUB;

/
