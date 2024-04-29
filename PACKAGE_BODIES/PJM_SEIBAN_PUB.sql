--------------------------------------------------------
--  DDL for Package Body PJM_SEIBAN_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PJM_SEIBAN_PUB" AS
/* $Header: PJMPSBNB.pls 120.2 2006/02/20 17:54:08 yliou ship $ */

--
-- Global Declarations
--
G_PKG_NAME  CONSTANT VARCHAR2(30) :='PJM_SEIBAN_PUB';

--
-- Functions and Procedures
--
PROCEDURE Validate_Data
( P_seiban_number           IN            VARCHAR2
, P_seiban_name             IN            VARCHAR2
, P_operating_unit          IN            NUMBER
, P_planning_group          IN            VARCHAR2
, P_DFF                     IN            DescFlexRecType
, X_return_status           OUT NOCOPY    VARCHAR2
) IS

CURSOR v1 IS
  SELECT s.project_id
  FROM ( SELECT project_id , project_number FROM pjm_seiban_numbers
         UNION ALL
         SELECT project_id , segment1 FROM pa_projects_all ) s
  WHERE  s.project_number = P_seiban_number;

CURSOR v2 IS
  SELECT s.project_id
  FROM ( SELECT project_id , project_name FROM pjm_seiban_numbers
         UNION ALL
         SELECT project_id , name FROM pa_projects_all ) s
  WHERE  s.project_name = P_seiban_name;

CURSOR v3 IS
  SELECT meaning
  FROM   fnd_common_lookups
  WHERE  application_id = 704
  AND    lookup_type = 'PLANNING_GROUP'
  AND    lookup_code = P_planning_group
  AND    sysdate BETWEEN nvl( start_date_active , sysdate - 1)
                 AND     nvl( end_date_active , sysdate + 1)
  AND    nvl( enabled_flag , 'N' ) = 'Y';

CURSOR v4 IS
  select organization_id from HR_ORGANIZATION_INFORMATION
  where ORG_INFORMATION_CONTEXT||'' = 'CLASS'
  AND ORG_INFORMATION1 = 'OPERATING_UNIT'
  AND ORG_INFORMATION2 = 'Y'
  AND organization_id = P_operating_unit;

v1rec    v1%rowtype;
v2rec    v2%rowtype;
v3rec    v3%rowtype;
v4rec    v4%rowtype;

i        NUMBER;

BEGIN

  X_return_status := FND_API.G_RET_STS_SUCCESS;

  OPEN v1; FETCH v1 INTO v1rec; CLOSE v1;
  OPEN v2; FETCH v2 INTO v2rec; CLOSE v2;
  OPEN v3; FETCH v3 INTO v3rec; CLOSE v3;
  OPEN v4; FETCH v4 INTO v4rec; CLOSE v4;

  --
  -- Check for existing project / seiban with same number or name
  --
  IF ( v1rec.project_id = v2rec.project_id ) THEN

    FND_MESSAGE.set_name('PJM' , 'GEN-SEIBAN EXISTS');
    FND_MSG_PUB.add;
    X_return_status := FND_API.G_RET_STS_ERROR;

  ELSE

    IF ( v1rec.project_id is not null ) THEN
      FND_MESSAGE.set_name('PJM' , 'FORM-DUPLICATE PROJECT NUM');
      FND_MSG_PUB.add;
      X_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

    IF ( v2rec.project_id is not null ) THEN
      FND_MESSAGE.set_name('PJM' , 'FORM-DUPLICATE PROJECT NAME');
      FND_MSG_PUB.add;
      X_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

  END IF;

  --
  -- Make sure value for planning group is valid
  --
  IF ( P_planning_group is not null and v3rec.meaning is null ) THEN

    FND_MESSAGE.set_name('PJM' , 'GEN-INVALID VALUE');
    FND_MESSAGE.set_token('NAME' , 'TOKEN-PLANNING GROUP' , TRUE);
    FND_MESSAGE.set_token('VALUE' , P_planning_group);
    FND_MSG_PUB.add;
    X_return_status := FND_API.G_RET_STS_ERROR;

  END IF;

  --
  -- Make sure value for operating unit is valid
  --
  IF ( P_operating_unit is not null and v4rec.organization_id is null ) THEN

    FND_MESSAGE.set_name('PJM' , 'GEN-INVALID VALUE');
    FND_MESSAGE.set_token('NAME' , 'TOKEN-OPERATING UNIT' , TRUE);
    FND_MESSAGE.set_token('VALUE' , P_operating_unit);
    FND_MSG_PUB.add;
    X_return_status := FND_API.G_RET_STS_ERROR;

  END IF;

  --
  -- Validate Descriptive Flexfield data
  --
  FND_FLEX_DESCVAL.set_context_value(P_DFF.Category);

--  bug 4038998
  FND_FLEX_DESCVAL.set_column_value( 'ATTRIBUTE1' , P_DFF.Attr1 );
  FND_FLEX_DESCVAL.set_column_value( 'ATTRIBUTE2' , P_DFF.Attr2 );
  FND_FLEX_DESCVAL.set_column_value( 'ATTRIBUTE3' , P_DFF.Attr3 );
  FND_FLEX_DESCVAL.set_column_value( 'ATTRIBUTE4' , P_DFF.Attr4 );
  FND_FLEX_DESCVAL.set_column_value( 'ATTRIBUTE5' , P_DFF.Attr5 );
  FND_FLEX_DESCVAL.set_column_value( 'ATTRIBUTE6' , P_DFF.Attr6 );
  FND_FLEX_DESCVAL.set_column_value( 'ATTRIBUTE7' , P_DFF.Attr7 );
  FND_FLEX_DESCVAL.set_column_value( 'ATTRIBUTE8' , P_DFF.Attr8 );
  FND_FLEX_DESCVAL.set_column_value( 'ATTRIBUTE9' , P_DFF.Attr9 );
  FND_FLEX_DESCVAL.set_column_value( 'ATTRIBUTE10' , P_DFF.Attr10 );
  FND_FLEX_DESCVAL.set_column_value( 'ATTRIBUTE11' , P_DFF.Attr11 );
  FND_FLEX_DESCVAL.set_column_value( 'ATTRIBUTE12' , P_DFF.Attr12 );
  FND_FLEX_DESCVAL.set_column_value( 'ATTRIBUTE13' , P_DFF.Attr13 );
  FND_FLEX_DESCVAL.set_column_value( 'ATTRIBUTE14' , P_DFF.Attr14 );
  FND_FLEX_DESCVAL.set_column_value( 'ATTRIBUTE15' , P_DFF.Attr15 );


  IF NOT FND_FLEX_DESCVAL.validate_desccols
         ( appl_short_name => 'PJM'
         , desc_flex_name  => 'PJM_SEIBAN_NUMBERS'
         , values_or_ids   => 'I' ) THEN

    FND_MSG_PUB.add_exc_msg
               ( p_pkg_name        => G_PKG_NAME
               , p_procedure_name  => 'VALIDATE_DATA'
               , p_error_text      => FND_FLEX_DESCVAL.error_message );
    X_return_status := FND_API.G_RET_STS_ERROR;

  END IF;

EXCEPTION
  WHEN OTHERS THEN
    FND_MSG_PUB.add_exc_msg
               ( p_pkg_name        => G_PKG_NAME
               , p_procedure_name  => 'VALIDATE_DATA' );
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END Validate_Data;


PROCEDURE Create_Seiban
( P_api_version             IN            NUMBER
, P_init_msg_list           IN            VARCHAR2
, P_commit                  IN            VARCHAR2
, X_return_status           OUT NOCOPY    VARCHAR2
, X_msg_count               OUT NOCOPY    NUMBER
, X_msg_data                OUT NOCOPY    VARCHAR2
, P_seiban_number           IN            VARCHAR2
, P_seiban_name             IN            VARCHAR2
, P_operating_unit          IN            NUMBER
, P_planning_group          IN            VARCHAR2
, P_DFF                     IN            DescFlexRecType
, P_org_list                IN            OrgTblType
, X_project_id              OUT NOCOPY    NUMBER
) IS

l_api_name     CONSTANT VARCHAR2(30) := 'CREATE_SEIBAN';
l_api_version  CONSTANT NUMBER       := 1.0;

user_id             NUMBER;
login_id            NUMBER;
l_project_id        NUMBER;
l_cost_group_id     NUMBER; -- add for bug 4316660
l_param_data        PJM_PROJECT_PARAM_PUB.ParamRecType;
i                   NUMBER;

BEGIN
  --
  -- Standard Start of API savepoint
  --
  SAVEPOINT create_seiban;

  user_id := FND_GLOBAL.user_id;
  login_id := FND_GLOBAL.login_id;

  --
  -- Check API incompatibility
  --
  IF NOT FND_API.compatible_api_call( l_api_version
                                    , P_api_version
                                    , l_api_name
                                    , G_PKG_NAME )
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  --
  -- Initialize the message table if requested.
  --
  IF FND_API.to_boolean( P_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;

  --
  -- Set API return status to success
  --
  X_return_status := FND_API.G_RET_STS_SUCCESS;

  --
  -- Data Validation
  --
  Validate_Data
  ( P_seiban_number     => P_seiban_number
  , P_seiban_name       => P_seiban_name
  , P_operating_unit    => P_operating_unit
  , P_planning_group    => P_planning_group
  , P_DFF               => P_DFF
  , X_return_status     => X_return_status
  );

  --
  -- If anything happens, abort API
  --
  IF ( X_return_status = FND_API.G_RET_STS_ERROR ) THEN
    RAISE FND_API.G_EXC_ERROR;
  ELSIF ( X_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  SELECT pa_projects_s.nextval INTO l_project_id FROM dual;

  INSERT INTO pjm_seiban_numbers
  (      project_id
  ,      project_number
  ,      project_name
  ,      operating_unit
  ,      attribute_category
  ,      attribute1
  ,      attribute2
  ,      attribute3
  ,      attribute4
  ,      attribute5
  ,      attribute6
  ,      attribute7
  ,      attribute8
  ,      attribute9
  ,      attribute10
  ,      attribute11
  ,      attribute12
  ,      attribute13
  ,      attribute14
  ,      attribute15
  ,      last_update_date
  ,      last_updated_by
  ,      creation_date
  ,      created_by
  ,      last_update_login
  ) VALUES
  (      l_project_id
  ,      P_seiban_number
  ,      P_seiban_name
  ,      P_operating_unit
  ,      P_DFF.Category
  ,      P_DFF.Attr1
  ,      P_DFF.Attr2
  ,      P_DFF.Attr3
  ,      P_DFF.Attr4
  ,      P_DFF.Attr5
  ,      P_DFF.Attr6
  ,      P_DFF.Attr7
  ,      P_DFF.Attr8
  ,      P_DFF.Attr9
  ,      P_DFF.Attr10
  ,      P_DFF.Attr11
  ,      P_DFF.Attr12
  ,      P_DFF.Attr13
  ,      P_DFF.Attr14
  ,      P_DFF.Attr15
  ,      sysdate
  ,      login_id
  ,      sysdate
  ,      user_id
  ,      login_id
  );

  IF ( P_org_list.count > 0 ) THEN

    i := P_org_list.FIRST;

    LOOP
 -- bug fix 4316660
      SELECT nvl( P_org_list(i).cost_group_id , default_cost_group_id )
      INTO   l_cost_group_id
      FROM   mtl_parameters
      WHERE  organization_id = P_org_list(i).organization_id;
  -- end bug 4316660

      l_param_data.project_id          := l_project_id;
      l_param_data.organization_id     := P_org_list(i).organization_id;
      l_param_data.cost_group_id       := l_cost_group_id;   -- add for bug 4316660
      l_param_data.wip_acct_class_code := P_org_list(i).wip_acct_class_code;
      l_param_data.start_date_active   := P_org_list(i).start_date_active;
      l_param_data.end_date_active     := P_org_list(i).end_date_active;
      l_param_data.attr_category       := P_org_list(i).attr_category;
      l_param_data.attr1               := P_org_list(i).attr1;
      l_param_data.attr2               := P_org_list(i).attr2;
      l_param_data.attr3               := P_org_list(i).attr3;
      l_param_data.attr4               := P_org_list(i).attr4;
      l_param_data.attr5               := P_org_list(i).attr5;
      l_param_data.attr6               := P_org_list(i).attr6;
      l_param_data.attr7               := P_org_list(i).attr7;
      l_param_data.attr8               := P_org_list(i).attr8;
      l_param_data.attr9               := P_org_list(i).attr9;
      l_param_data.attr10              := P_org_list(i).attr10;
      l_param_data.attr11              := P_org_list(i).attr11;
      l_param_data.attr12              := P_org_list(i).attr12;
      l_param_data.attr13              := P_org_list(i).attr13;
      l_param_data.attr14              := P_org_list(i).attr14;
      l_param_data.attr15              := P_org_list(i).attr15;

      PJM_PROJECT_PARAM_PUB.create_project_parameter
      ( P_api_version        => P_api_version
      , P_init_msg_list      => FND_API.G_FALSE
      , P_commit             => FND_API.G_FALSE
      , X_return_status      => X_return_status
      , X_msg_count          => X_msg_count
      , X_msg_data           => X_msg_data
      , P_param_data         => l_param_data );

     IF ( X_return_status = FND_API.G_RET_STS_ERROR ) THEN
       RAISE FND_API.G_EXC_ERROR;
     ELSIF ( X_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;


      EXIT WHEN i = P_org_list.LAST;
      i := P_org_list.NEXT(i);
    END LOOP;

    PJM_PROJECT_PARAM_PUB.update_planning_group
    ( P_api_version        => P_api_version
    , P_init_msg_list      => FND_API.G_FALSE
    , P_commit             => FND_API.G_FALSE
    , X_return_status      => X_return_status
    , X_msg_count          => X_msg_count
    , X_msg_data           => X_msg_data
    , P_project_id         => l_project_id
    , P_planning_group     => P_planning_group );

    IF ( X_return_status = FND_API.G_RET_STS_ERROR ) THEN
      RAISE FND_API.G_EXC_ERROR;
    ELSIF ( X_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;


  END IF;

  --
  -- Stanard commit check
  --
  IF FND_API.to_boolean( p_commit ) THEN
    commit work;
  END IF;

  --
  -- Standard call to get message count and if count is 1, get message
  -- info
  --
  FND_MSG_PUB.count_and_get( p_count => X_Msg_Count
                           , p_data  => X_Msg_Data );

  X_project_id := l_project_id;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO create_seiban;
    X_Return_Status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.count_and_get( p_count => X_Msg_Count
                             , p_data  => X_Msg_Data );

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO create_seiban;
    X_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.count_and_get( p_count => X_Msg_Count
                             , p_data  => X_Msg_Data );

  WHEN OTHERS THEN
    ROLLBACK TO create_seiban;
    X_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.add_exc_msg( p_pkg_name        => G_PKG_NAME
                             , p_procedure_name  => l_api_name);
    END IF;
    FND_MSG_PUB.count_and_get( p_count => X_Msg_Count
                             , p_data  => X_Msg_Data );

END Create_Seiban;

END PJM_SEIBAN_PUB;

/
