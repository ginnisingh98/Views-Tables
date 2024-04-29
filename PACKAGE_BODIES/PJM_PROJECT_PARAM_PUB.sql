--------------------------------------------------------
--  DDL for Package Body PJM_PROJECT_PARAM_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PJM_PROJECT_PARAM_PUB" AS
/* $Header: PJMPPJPB.pls 115.2 2004/03/29 22:08:35 elam noship $ */

--
-- Global Declarations
--
G_pkg_name          VARCHAR2(30) := 'PJM_PROJECT_PARAM_PUB';

G_ap_installed      BOOLEAN      := NULL;
G_pa_installed      BOOLEAN      := NULL;
G_project_id        NUMBER       := NULL;
G_seiban_flag       NUMBER       := NULL;
G_proj_start_date   DATE         := NULL;
G_proj_comp_date    DATE         := NULL;
G_planning_group    VARCHAR2(30) := NULL;
G_organization_id   NUMBER       := NULL;
G_proj_ctrl_level   NUMBER       := NULL;
G_cost_method       NUMBER       := NULL;
G_cost_group_id     NUMBER       := NULL;
G_eam_enabled       VARCHAR2(1)  := NULL;
G_transfer_ipv      VARCHAR2(1)  := NULL;
G_transfer_erv      VARCHAR2(1)  := NULL;
G_transfer_freight  VARCHAR2(1)  := NULL;
G_transfer_tax      VARCHAR2(1)  := NULL;
G_transfer_misc     VARCHAR2(1)  := NULL;
G_ipv_exp_type      VARCHAR2(30) := NULL;
G_erv_exp_type      VARCHAR2(30) := NULL;
G_freight_exp_type  VARCHAR2(30) := NULL;
G_tax_exp_type      VARCHAR2(30) := NULL;
G_misc_exp_type     VARCHAR2(30) := NULL;
G_ppv_exp_type      VARCHAR2(30) := NULL;
G_diritem_exp_type  VARCHAR2(30) := NULL;

--
-- Private Functions and Procedures
--
FUNCTION app_install
( P_appl_short_name         IN            VARCHAR2
) RETURN BOOLEAN IS

l_status            varchar2(1);
l_industry          varchar2(1);
l_ora_schema        varchar2(30);

BEGIN
  --
  -- Call FND routine to figure out installation status
  --
  -- If the license status is not 'I', Project Manufacturing is
  -- not installed.
  --
  IF NOT ( FND_INSTALLATION.get_app_info
           ( P_appl_short_name , l_status , l_industry , l_ora_schema ) ) THEN
    RETURN FALSE;
  END IF;

  IF ( l_status <> 'I' ) then
    RETURN FALSE;
  END IF;
  RETURN TRUE;

END app_install;


PROCEDURE default_values
( P_param_data              IN            ParamRecType
, X_param_data              OUT    NOCOPY ParamRecType
, X_return_status           OUT    NOCOPY VARCHAR2
) IS

CURSOR p ( X_project_id  NUMBER ) IS
  SELECT seiban_number_flag
  ,      start_date
  ,      completion_date
  FROM   pjm_projects_all_v
  WHERE  project_id = X_project_id;

CURSOR pg ( X_project_id  NUMBER ) IS
  SELECT planning_group
  FROM   pjm_project_parameters
  WHERE  project_id = X_project_id;

CURSOR o ( X_organization_id  NUMBER ) IS
  SELECT p.project_control_level
  ,      m.default_cost_group_id
  ,      m.primary_cost_method
  ,      m.eam_enabled_flag
  ,      p.transfer_ipv
  ,      p.transfer_erv
  ,      p.transfer_freight
  ,      p.transfer_tax
  ,      p.transfer_misc
  ,      p.ipv_expenditure_type
  ,      p.erv_expenditure_type
  ,      p.freight_expenditure_type
  ,      p.tax_expenditure_type
  ,      p.misc_expenditure_type
  ,      p.ppv_expenditure_type
  ,      p.dir_item_expenditure_type
  FROM   pjm_org_parameters p
  ,      mtl_parameters m
  WHERE  p.organization_id = X_organization_id
  AND    m.organization_id = p.organization_id;

CURSOR wac ( X_organization_id  NUMBER ) IS
  SELECT default_discrete_class
  FROM   wip_parameters wp
  WHERE  organization_id = X_organization_id
  AND NOT ( P_param_data.cost_group_id is not null
          AND NOT EXISTS (
            SELECT null
            FROM   cst_cg_wip_acct_classes
            WHERE  cost_group_id = P_param_data.cost_group_id
            AND    organization_id = wp.organization_id
            AND    class_code = wp.default_discrete_class
          )
  );

BEGIN

  X_return_status := FND_API.G_RET_STS_SUCCESS;

  X_param_data := P_param_data;

  IF ( G_ap_installed is null ) THEN
    G_ap_installed := app_install( 'SQLAP' );
  END IF;

  IF ( G_pa_installed is null ) THEN
    G_pa_installed := app_install( 'PA' );
  END IF;

  IF (  G_project_id is null
     OR G_project_id <> X_param_data.project_id ) THEN

    OPEN p ( X_param_data.project_id );
    FETCH p INTO G_seiban_flag
               , G_proj_start_date
               , G_proj_comp_date;
    CLOSE p;

    IF ( G_seiban_flag is not null ) THEN
      G_project_id := X_param_data.project_id;
      OPEN pg ( G_project_id );
      FETCH pg INTO G_planning_group;
      CLOSE pg;
    ELSE
      FND_MESSAGE.set_name('PJM' , 'GEN-PROJ ID INVALID');
      FND_MESSAGE.set_token('ID' , X_param_data.project_id);
      FND_MSG_PUB.add;
      X_return_status := FND_API.G_RET_STS_ERROR;
      return;
    END IF;

  END IF;

  IF (  G_organization_id is null
     OR G_organization_id <> X_param_data.organization_id ) THEN

    OPEN o ( X_param_data.organization_id );
    FETCH o INTO G_proj_ctrl_level
               , G_cost_group_id
               , G_cost_method
               , G_eam_enabled
               , G_transfer_ipv
               , G_transfer_erv
               , G_transfer_freight
               , G_transfer_tax
               , G_transfer_misc
               , G_ipv_exp_type
               , G_erv_exp_type
               , G_freight_exp_type
               , G_tax_exp_type
               , G_misc_exp_type
               , G_ppv_exp_type
               , G_diritem_exp_type
               ;
    CLOSE o;

    IF ( G_proj_ctrl_level is not null ) THEN
      G_organization_id := X_param_data.organization_id;
    ELSE
      FND_MESSAGE.set_name('PJM' , 'GEN-ORG ID INVALID');
      FND_MESSAGE.set_token('ID' , X_param_data.organization_id);
      FND_MSG_PUB.add;
      X_return_status := FND_API.G_RET_STS_ERROR;
      return;
    END IF;

  END IF;

  IF ( X_param_data.cost_group_id is null ) THEN
    X_param_data.cost_group_id := G_cost_group_id;
  END IF;

  IF ( X_param_data.wip_acct_class_code is null ) THEN
    OPEN wac ( G_organization_id );
    FETCH wac INTO X_param_data.wip_acct_class_code;
    CLOSE wac;
  END IF;

  IF ( X_param_data.eam_acct_class_code is not null
     AND G_eam_enabled = 'N' ) THEN
    X_param_data.eam_acct_class_code := NULL;
  END IF;

  IF ( G_ap_installed AND G_pa_installed AND G_seiban_flag = 2 ) THEN

    IF ( G_transfer_ipv = 'Y' ) THEN
      X_param_data.ipv_expenditure_type :=
        nvl( X_param_data.ipv_expenditure_type , G_ipv_exp_type );
    ELSE
      X_param_data.ipv_expenditure_type := NULL;
    END IF;

    IF ( G_transfer_erv = 'Y' ) THEN
      X_param_data.erv_expenditure_type :=
        nvl( X_param_data.erv_expenditure_type , G_erv_exp_type );
    ELSE
      X_param_data.erv_expenditure_type := NULL;
    END IF;

    IF ( G_transfer_freight = 'Y' ) THEN
      X_param_data.freight_expenditure_type :=
        nvl( X_param_data.freight_expenditure_type , G_freight_exp_type );
    ELSE
      X_param_data.freight_expenditure_type := NULL;
    END IF;

    IF ( G_transfer_tax = 'Y' ) THEN
      X_param_data.tax_expenditure_type :=
        nvl( X_param_data.tax_expenditure_type , G_tax_exp_type );
    ELSE
      X_param_data.tax_expenditure_type := NULL;
    END IF;

    IF ( G_transfer_misc = 'Y' ) THEN
      X_param_data.misc_expenditure_type :=
        nvl( X_param_data.misc_expenditure_type , G_misc_exp_type );
    ELSE
      X_param_data.misc_expenditure_type := NULL;
    END IF;

    IF ( G_cost_method = 1 ) THEN
      X_param_data.ppv_expenditure_type :=
        nvl( X_param_data.ppv_expenditure_type , G_ppv_exp_type );
    ELSE
      X_param_data.ppv_expenditure_type := NULL;
    END IF;

    IF ( G_eam_enabled = 'Y' ) THEN
      X_param_data.dir_item_expenditure_type :=
        nvl( X_param_data.dir_item_expenditure_type , G_diritem_exp_type );
    ELSE
      X_param_data.dir_item_expenditure_type := NULL;
    END IF;

  ELSE

    X_param_data.ipv_expenditure_type := NULL;
    X_param_data.erv_expenditure_type := NULL;
    X_param_data.freight_expenditure_type := NULL;
    X_param_data.tax_expenditure_type := NULL;
    X_param_data.misc_expenditure_type := NULL;
    X_param_data.ppv_expenditure_type := NULL;
    X_param_data.dir_item_expenditure_type := NULL;

  END IF;

EXCEPTION
  WHEN OTHERS THEN
    FND_MSG_PUB.add_exc_msg
               ( p_pkg_name        => G_pkg_name
               , p_procedure_name  => 'DEFAULT_VALUES' );
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END default_values;


PROCEDURE validate_data
( P_api_name                IN            VARCHAR2
, P_param_data              IN            ParamRecType
, X_return_status           OUT    NOCOPY VARCHAR2
) IS

CURSOR pp ( X_organization_id  NUMBER
          , X_project_id       NUMBER ) IS
  SELECT project_id
  FROM   pjm_project_parameters
  WHERE  organization_id = X_organization_id
  AND    project_id = X_project_id;

CURSOR cg ( X_organization_id  NUMBER
          , X_cost_group_id    NUMBER ) IS
  SELECT cost_group_id
  FROM   cst_cost_groups
  WHERE  organization_id = X_organization_id
  AND    cost_group_id = X_cost_group_id
  UNION ALL
  SELECT default_cost_group_id
  FROM   mtl_parameters
  WHERE  organization_id = X_organization_id
  AND    default_cost_group_id = X_cost_group_id;

CURSOR wac ( X_class_code       VARCHAR2
           , X_organization_id  NUMBER
           , X_cost_group_id    NUMBER
           , X_class_type       NUMBER ) IS
  SELECT class_code
  FROM   wip_accounting_classes wac
  WHERE  class_code = X_class_code
  AND    organization_id = X_organization_id
  AND    class_type = X_class_type
  AND NOT ( X_cost_group_id <> G_cost_group_id
          AND NOT EXISTS (
            SELECT null
            FROM   cst_cg_wip_acct_classes
            WHERE  cost_group_id = X_cost_group_id
            AND    organization_id = wac.organization_id
            AND    class_code = wac.class_code
          )
  );

CURSOR et ( X_expenditure_type  VARCHAR2
          , X_cost_element_id   NUMBER ) IS
  SELECT expenditure_type
  FROM   cst_proj_exp_types_val_v
  WHERE  expenditure_type = X_expenditure_type
  AND    cost_element_id = X_cost_element_id
  AND    trunc(sysdate)
         BETWEEN sys_link_start_date
         AND     nvl(sys_link_end_date , trunc(sysdate))
  AND    trunc(sysdate)
         BETWEEN exp_type_start_date
         AND     nvl(exp_type_end_date , trunc(sysdate));

pprec     pp%rowtype;
cgrec     cg%rowtype;
wacrec    wac%rowtype;
etrec     et%rowtype;

BEGIN

  X_return_status := FND_API.G_RET_STS_SUCCESS;

  --
  -- Make sure record does not exist
  --
  IF ( P_api_name = 'CREATE_PROJECT_PARAMETER' ) THEN
    OPEN pp ( P_param_data.organization_id , P_param_data.project_id );
    FETCH pp INTO pprec;
    CLOSE pp;
    IF ( pprec.project_id is not null ) THEN
      FND_MESSAGE.set_name('PJM' , 'GEN-PARAM RECORD EXISTS');
      FND_MSG_PUB.add;
      X_return_status := FND_API.G_RET_STS_ERROR;
      return;
    END IF;
  END IF;

  --
  -- Make sure start / end dates are valid
  --
  IF ( P_param_data.start_date_active > G_proj_comp_date ) THEN
    FND_MESSAGE.set_name('PJM' , 'FORM-PARAM START DATE INVALID');
    FND_MESSAGE.set_token('DATE' , FND_DATE.date_to_displaydate(G_proj_comp_date));
    FND_MSG_PUB.add;
    X_return_status := FND_API.G_RET_STS_ERROR;
  END IF;

  IF ( P_param_data.end_date_active < G_proj_start_date ) THEN
    FND_MESSAGE.set_name('PJM' , 'FORM-PARAM END DATE INVALID');
    FND_MESSAGE.set_token('DATE' , FND_DATE.date_to_displaydate(G_proj_start_date));
    FND_MSG_PUB.add;
    X_return_status := FND_API.G_RET_STS_ERROR;
  END IF;

  IF ( P_param_data.start_date_active > P_param_data.end_date_active ) THEN
    FND_MESSAGE.set_name('PJM' , 'FORM-INVALID EFFDATE PAIR');
    FND_MSG_PUB.add;
    X_return_status := FND_API.G_RET_STS_ERROR;
  END IF;

  --
  -- Make sure the control level is not task if project is seiban
  --
  IF ( G_seiban_flag = 1 AND G_proj_ctrl_level = 2 ) THEN
    FND_MESSAGE.set_name('PJM' , 'GEN-TASK CONTROL NO SEIBAN');
    FND_MSG_PUB.add;
    X_return_status := FND_API.G_RET_STS_ERROR;
  END IF;

  --
  -- Make sure cost group is valid for the organization
  --
  IF ( P_param_data.cost_group_id is not null ) THEN
    OPEN cg ( P_param_data.organization_id , P_param_data.cost_group_id );
    FETCH cg INTO cgrec;
    CLOSE cg;
    IF ( cgrec.cost_group_id is null ) THEN
      FND_MESSAGE.set_name('PJM' , 'GEN-INVALID VALUE');
      FND_MESSAGE.set_token('NAME' , 'TOKEN-COST GROUP' , TRUE);
      FND_MESSAGE.set_token('VALUE' , P_param_data.cost_group_id);
      FND_MSG_PUB.add;
      X_return_status := FND_API.G_RET_STS_ERROR;
    END IF;
  END IF;

  --
  -- Make sure WIP accounting class is valid for the organization
  --
  IF ( P_param_data.wip_acct_class_code is not null ) THEN
    OPEN wac ( P_param_data.wip_acct_class_code
             , P_param_data.organization_id
             , P_param_data.cost_group_id
             , 1 );
    FETCH wac INTO wacrec;
    CLOSE wac;
    IF ( wacrec.class_code is null ) THEN
      FND_MESSAGE.set_name('PJM' , 'GEN-INVALID VALUE');
      FND_MESSAGE.set_token('NAME' , 'TOKEN-WIP ACCT CLASS' , TRUE);
      FND_MESSAGE.set_token('VALUE' , P_param_data.wip_acct_class_code);
      FND_MSG_PUB.add;
      X_return_status := FND_API.G_RET_STS_ERROR;
    END IF;
  END IF;

  --
  -- Make sure EAM accounting class is valid for the organization
  --
  IF ( P_param_data.eam_acct_class_code is not null ) THEN
    OPEN wac ( P_param_data.eam_acct_class_code
             , P_param_data.organization_id
             , P_param_data.cost_group_id
             , 6 );
    FETCH wac INTO wacrec;
    CLOSE wac;
    IF ( wacrec.class_code is null ) THEN
      FND_MESSAGE.set_name('PJM' , 'GEN-INVALID VALUE');
      FND_MESSAGE.set_token('NAME' , 'TOKEN-EAM ACCT CLASS' , TRUE);
      FND_MESSAGE.set_token('VALUE' , P_param_data.eam_acct_class_code);
      FND_MSG_PUB.add;
      X_return_status := FND_API.G_RET_STS_ERROR;
    END IF;
  END IF;

  --
  -- Make sure various expenditure types are valid
  --
  IF ( P_param_data.ipv_expenditure_type is not null ) THEN
    OPEN et ( P_param_data.ipv_expenditure_type , 1 );
    FETCH et INTO etrec;
    CLOSE et;
    IF ( etrec.expenditure_type is null ) THEN
      FND_MESSAGE.set_name('PJM' , 'GEN-INVALID VALUE');
      FND_MESSAGE.set_token('NAME' , 'TOKEN-IPV EXPENDITURE TYPE' , TRUE);
      FND_MESSAGE.set_token('VALUE' , P_param_data.ipv_expenditure_type);
      FND_MSG_PUB.add;
      X_return_status := FND_API.G_RET_STS_ERROR;
    END IF;
  END IF;

  IF ( P_param_data.erv_expenditure_type is not null ) THEN
    OPEN et ( P_param_data.erv_expenditure_type , 1 );
    FETCH et INTO etrec;
    CLOSE et;
    IF ( etrec.expenditure_type is null ) THEN
      FND_MESSAGE.set_name('PJM' , 'GEN-INVALID VALUE');
      FND_MESSAGE.set_token('NAME' , 'TOKEN-ERV EXPENDITURE TYPE' , TRUE);
      FND_MESSAGE.set_token('VALUE' , P_param_data.erv_expenditure_type);
      FND_MSG_PUB.add;
      X_return_status := FND_API.G_RET_STS_ERROR;
    END IF;
  END IF;

  IF ( P_param_data.freight_expenditure_type is not null ) THEN
    OPEN et ( P_param_data.freight_expenditure_type , 1 );
    FETCH et INTO etrec;
    CLOSE et;
    IF ( etrec.expenditure_type is null ) THEN
      FND_MESSAGE.set_name('PJM' , 'GEN-INVALID VALUE');
      FND_MESSAGE.set_token('NAME' , 'TOKEN-FREIGHT EXPENDITURE TYPE' , TRUE);
      FND_MESSAGE.set_token('VALUE' , P_param_data.freight_expenditure_type);
      FND_MSG_PUB.add;
      X_return_status := FND_API.G_RET_STS_ERROR;
    END IF;
  END IF;

  IF ( P_param_data.tax_expenditure_type is not null ) THEN
    OPEN et ( P_param_data.tax_expenditure_type , 1 );
    FETCH et INTO etrec;
    CLOSE et;
    IF ( etrec.expenditure_type is null ) THEN
      FND_MESSAGE.set_name('PJM' , 'GEN-INVALID VALUE');
      FND_MESSAGE.set_token('NAME' , 'TOKEN-TAX EXPENDITURE TYPE' , TRUE);
      FND_MESSAGE.set_token('VALUE' , P_param_data.tax_expenditure_type);
      FND_MSG_PUB.add;
      X_return_status := FND_API.G_RET_STS_ERROR;
    END IF;
  END IF;

  IF ( P_param_data.misc_expenditure_type is not null ) THEN
    OPEN et ( P_param_data.misc_expenditure_type , 1 );
    FETCH et INTO etrec;
    CLOSE et;
    IF ( etrec.expenditure_type is null ) THEN
      FND_MESSAGE.set_name('PJM' , 'GEN-INVALID VALUE');
      FND_MESSAGE.set_token('NAME' , 'TOKEN-MISC EXPENDITURE TYPE' , TRUE);
      FND_MESSAGE.set_token('VALUE' , P_param_data.misc_expenditure_type);
      FND_MSG_PUB.add;
      X_return_status := FND_API.G_RET_STS_ERROR;
    END IF;
  END IF;

  IF ( P_param_data.ppv_expenditure_type is not null ) THEN
    OPEN et ( P_param_data.ppv_expenditure_type , 1 );
    FETCH et INTO etrec;
    CLOSE et;
    IF ( etrec.expenditure_type is null ) THEN
      FND_MESSAGE.set_name('PJM' , 'GEN-INVALID VALUE');
      FND_MESSAGE.set_token('NAME' , 'TOKEN-PPV EXPENDITURE TYPE' , TRUE);
      FND_MESSAGE.set_token('VALUE' , P_param_data.ppv_expenditure_type);
      FND_MSG_PUB.add;
      X_return_status := FND_API.G_RET_STS_ERROR;
    END IF;
  END IF;

  IF ( P_param_data.dir_item_expenditure_type is not null ) THEN
    OPEN et ( P_param_data.dir_item_expenditure_type , 4 );
    FETCH et INTO etrec;
    CLOSE et;
    IF ( etrec.expenditure_type is null ) THEN
      FND_MESSAGE.set_name('PJM' , 'GEN-INVALID VALUE');
      FND_MESSAGE.set_token('NAME' , 'TOKEN-DIRITEM EXPENDITURE TYPE' , TRUE);
      FND_MESSAGE.set_token('VALUE' , P_param_data.dir_item_expenditure_type);
      FND_MSG_PUB.add;
      X_return_status := FND_API.G_RET_STS_ERROR;
    END IF;
  END IF;

  --
  -- Validate Descriptive Flexfield data
  --
  FND_FLEX_DESCVAL.set_context_value(P_param_data.attr_category);
  IF ( P_param_data.attr1 is not null ) THEN
    FND_FLEX_DESCVAL.set_column_value( 'ATTRIBUTE1' , P_param_data.attr1 );
  END IF;
  IF ( P_param_data.attr2 is not null ) THEN
    FND_FLEX_DESCVAL.set_column_value( 'ATTRIBUTE2' , P_param_data.attr2 );
  END IF;
  IF ( P_param_data.attr3 is not null ) THEN
    FND_FLEX_DESCVAL.set_column_value( 'ATTRIBUTE3' , P_param_data.attr3 );
  END IF;
  IF ( P_param_data.attr4 is not null ) THEN
    FND_FLEX_DESCVAL.set_column_value( 'ATTRIBUTE4' , P_param_data.attr4 );
  END IF;
  IF ( P_param_data.attr5 is not null ) THEN
    FND_FLEX_DESCVAL.set_column_value( 'ATTRIBUTE5' , P_param_data.attr5 );
  END IF;
  IF ( P_param_data.attr6 is not null ) THEN
    FND_FLEX_DESCVAL.set_column_value( 'ATTRIBUTE6' , P_param_data.attr6 );
  END IF;
  IF ( P_param_data.attr7 is not null ) THEN
    FND_FLEX_DESCVAL.set_column_value( 'ATTRIBUTE7' , P_param_data.attr7 );
  END IF;
  IF ( P_param_data.attr8 is not null ) THEN
    FND_FLEX_DESCVAL.set_column_value( 'ATTRIBUTE8' , P_param_data.attr8 );
  END IF;
  IF ( P_param_data.attr9 is not null ) THEN
    FND_FLEX_DESCVAL.set_column_value( 'ATTRIBUTE9' , P_param_data.attr9 );
  END IF;
  IF ( P_param_data.attr10 is not null ) THEN
    FND_FLEX_DESCVAL.set_column_value( 'ATTRIBUTE10' , P_param_data.attr10 );
  END IF;
  IF ( P_param_data.attr11 is not null ) THEN
    FND_FLEX_DESCVAL.set_column_value( 'ATTRIBUTE11' , P_param_data.attr11 );
  END IF;
  IF ( P_param_data.attr12 is not null ) THEN
    FND_FLEX_DESCVAL.set_column_value( 'ATTRIBUTE12' , P_param_data.attr12 );
  END IF;
  IF ( P_param_data.attr13 is not null ) THEN
    FND_FLEX_DESCVAL.set_column_value( 'ATTRIBUTE13' , P_param_data.attr13 );
  END IF;
  IF ( P_param_data.attr14 is not null ) THEN
    FND_FLEX_DESCVAL.set_column_value( 'ATTRIBUTE14' , P_param_data.attr14 );
  END IF;
  IF ( P_param_data.attr15 is not null ) THEN
    FND_FLEX_DESCVAL.set_column_value( 'ATTRIBUTE15' , P_param_data.attr15 );
  END IF;

  IF NOT FND_FLEX_DESCVAL.validate_desccols
         ( appl_short_name => 'PJM'
         , desc_flex_name  => 'PJM_PROJECT_PARAMETERS'
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
               ( p_pkg_name        => G_pkg_name
               , p_procedure_name  => 'VALIDATE_DATA' );
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END validate_data;


--
-- Public Functions and Procedures
--
PROCEDURE create_project_parameter
( P_api_version             IN            NUMBER
, P_init_msg_list           IN            VARCHAR2
, P_commit                  IN            VARCHAR2
, X_return_status           OUT NOCOPY    VARCHAR2
, X_msg_count               OUT NOCOPY    NUMBER
, X_msg_data                OUT NOCOPY    VARCHAR2
, P_param_data              IN            ParamRecType
) IS

l_api_name     CONSTANT VARCHAR2(30) := 'CREATE_PROJECT_PARAMETER';
l_api_version  CONSTANT NUMBER       := 1.0;

l_param_data   ParamRecType;
l_rowid        VARCHAR2(30);
l_user_id      NUMBER := FND_GLOBAL.user_id;
l_login_id     NUMBER := FND_GLOBAL.login_id;

BEGIN
  --
  -- Standard Start of API savepoint
  --
  SAVEPOINT create_project_param;

  --
  -- Check API incompatibility
  --
  IF NOT FND_API.compatible_api_call( l_api_version
                                    , P_api_version
                                    , l_api_name
                                    , G_pkg_name )
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
  -- Data Defaults
  --
  Default_Values( P_param_data    => P_param_data
                , X_param_data    => l_param_data
                , X_return_status => X_return_status );

  IF ( X_return_status = FND_API.G_RET_STS_ERROR ) THEN
    RAISE FND_API.G_EXC_ERROR;
  ELSIF ( X_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  --
  -- Data Validation
  --
  Validate_Data( P_api_name      => l_api_name
               , P_param_data    => l_param_data
               , X_return_status => X_return_status );

  IF ( X_return_status = FND_API.G_RET_STS_ERROR ) THEN
    RAISE FND_API.G_EXC_ERROR;
  ELSIF ( X_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  --
  -- Calling Table Handler for actual DML
  --
  PJM_PROJECT_PARAMS_PKG.insert_row
  ( X_rowid                        => l_rowid
  , X_project_id                   => l_param_data.project_id
  , X_organization_id              => l_param_data.organization_id
  , X_seiban_number_flag           => G_seiban_flag
  , X_costing_group_id             => l_param_data.cost_group_id
  , X_planning_group               => G_planning_group
  , X_wip_acct_class_code          => l_param_data.wip_acct_class_code
  , X_eam_acct_class_code          => l_param_data.eam_acct_class_code
  , X_start_date_active            => l_param_data.start_date_active
  , X_end_date_active              => l_param_data.end_date_active
  , X_ipv_expenditure_type         => l_param_data.ipv_expenditure_type
  , X_erv_expenditure_type         => l_param_data.erv_expenditure_type
  , X_freight_expenditure_type     => l_param_data.freight_expenditure_type
  , X_tax_expenditure_type         => l_param_data.tax_expenditure_type
  , X_misc_expenditure_type        => l_param_data.misc_expenditure_type
  , X_ppv_expenditure_type         => l_param_data.ppv_expenditure_type
  , X_dir_item_expenditure_type    => l_param_data.dir_item_expenditure_type
  , X_attribute_category           => l_param_data.attr_category
  , X_attribute1                   => l_param_data.attr1
  , X_attribute2                   => l_param_data.attr2
  , X_attribute3                   => l_param_data.attr3
  , X_attribute4                   => l_param_data.attr4
  , X_attribute5                   => l_param_data.attr5
  , X_attribute6                   => l_param_data.attr6
  , X_attribute7                   => l_param_data.attr7
  , X_attribute8                   => l_param_data.attr8
  , X_attribute9                   => l_param_data.attr9
  , X_attribute10                  => l_param_data.attr10
  , X_attribute11                  => l_param_data.attr11
  , X_attribute12                  => l_param_data.attr12
  , X_attribute13                  => l_param_data.attr13
  , X_attribute14                  => l_param_data.attr14
  , X_attribute15                  => l_param_data.attr15
  , X_creation_date                => sysdate
  , X_created_by                   => l_user_id
  , X_last_update_date             => sysdate
  , X_last_updated_by              => l_user_id
  , X_last_update_login            => l_login_id
  );

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
  FND_MSG_PUB.count_and_get( p_count => X_msg_count
                           , p_data  => X_msg_data );

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO create_project_param;
    X_Return_Status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.count_and_get( p_count => X_msg_count
                             , p_data  => X_msg_data );

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO create_project_param;
    X_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.count_and_get( p_count => X_msg_count
                             , p_data  => X_msg_data );

  WHEN OTHERS THEN
    ROLLBACK TO create_project_param;
    X_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.add_exc_msg( p_pkg_name        => G_pkg_name
                             , p_procedure_name  => l_api_name);
    END IF;
    FND_MSG_PUB.count_and_get( p_count => X_msg_count
                             , p_data  => X_msg_data );

END create_project_parameter;


PROCEDURE create_project_parameter
( P_api_version             IN            NUMBER
, P_init_msg_list           IN            VARCHAR2
, P_commit                  IN            VARCHAR2
, X_return_status           OUT NOCOPY    VARCHAR2
, X_msg_count               OUT NOCOPY    NUMBER
, X_msg_data                OUT NOCOPY    VARCHAR2
, P_param_data              IN            ParamTblType
) IS

l_api_name     CONSTANT VARCHAR2(30) := 'CREATE_PROJECT_PARAMETER';
l_api_version  CONSTANT NUMBER       := 1.0;

i                   NUMBER;

BEGIN
  --
  -- Standard Start of API savepoint
  --
  SAVEPOINT create_project_param;

  --
  -- Check API incompatibility
  --
  IF NOT FND_API.compatible_api_call( l_api_version
                                    , P_api_version
                                    , l_api_name
                                    , G_pkg_name )
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
  -- Loop through each record in the table and invoke the
  -- single record API
  --
  IF ( P_param_data.count > 0 ) THEN
    i := P_param_data.FIRST;
    LOOP
      Create_Project_Parameter
      ( P_api_version        => P_api_version
      , P_init_msg_list      => FND_API.G_FALSE
      , P_commit             => FND_API.G_FALSE
      , X_return_status      => X_return_status
      , X_msg_count          => X_msg_count
      , X_msg_data           => X_msg_data
      , P_param_data         => P_param_data(i) );
      EXIT WHEN i = P_param_data.LAST;
      i := P_param_data.NEXT(i);
    END LOOP;
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
  FND_MSG_PUB.count_and_get( p_count => X_msg_count
                           , p_data  => X_msg_data );

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO create_project_param;
    X_Return_Status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.count_and_get( p_count => X_msg_count
                             , p_data  => X_msg_data );

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO create_project_param;
    X_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.count_and_get( p_count => X_msg_count
                             , p_data  => X_msg_data );

  WHEN OTHERS THEN
    ROLLBACK TO create_project_param;
    X_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.add_exc_msg( p_pkg_name        => G_pkg_name
                             , p_procedure_name  => l_api_name);
    END IF;
    FND_MSG_PUB.count_and_get( p_count => X_msg_count
                             , p_data  => X_msg_data );

END create_project_parameter;


PROCEDURE update_planning_group
( P_api_version             IN            NUMBER
, P_init_msg_list           IN            VARCHAR2
, P_commit                  IN            VARCHAR2
, X_return_status           OUT NOCOPY    VARCHAR2
, X_msg_count               OUT NOCOPY    NUMBER
, X_msg_data                OUT NOCOPY    VARCHAR2
, P_project_id              IN            NUMBER
, P_planning_group          IN            VARCHAR2
) IS

l_api_name     CONSTANT VARCHAR2(30) := 'UPDATE_PLANNING_GROUP';
l_api_version  CONSTANT NUMBER       := 1.0;

CURSOR pg IS
  SELECT lookup_code
  FROM   fnd_common_lookups
  WHERE  application_id = 704
  AND    lookup_type = 'PLANNING_GROUP'
  AND    lookup_code = P_planning_group
  AND    sysdate BETWEEN nvl( start_date_active , sysdate - 1)
                 AND     nvl( end_date_active , sysdate + 1)
  AND    nvl( enabled_flag , 'N' ) = 'Y';

l_planning_group       VARCHAR2(30);

BEGIN
  --
  -- Standard Start of API savepoint
  --
  SAVEPOINT update_planning_group;

  --
  -- Check API incompatibility
  --
  IF NOT FND_API.compatible_api_call( l_api_version
                                    , P_api_version
                                    , l_api_name
                                    , G_pkg_name )
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
  -- Make sure planning group is valid
  --
  IF ( P_planning_group is not null ) THEN
    OPEN pg; FETCH pg INTO l_planning_group; CLOSE pg;
    IF ( l_planning_group is null ) THEN
      FND_MESSAGE.set_name('PJM' , 'GEN-INVALID VALUE');
      FND_MESSAGE.set_token('NAME' , 'TOKEN-PLANNING GROUP' , TRUE);
      FND_MESSAGE.set_token('VALUE' , P_planning_group);
      FND_MSG_PUB.add;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
  END IF;

  PJM_PROJECT_PARAMS_PKG.update_planning_group
  ( X_project_id         => P_project_id
  , X_planning_group     => P_planning_group );

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
  FND_MSG_PUB.count_and_get( p_count => X_msg_count
                           , p_data  => X_msg_data );

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO update_planning_group;
    X_Return_Status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.count_and_get( p_count => X_msg_count
                             , p_data  => X_msg_data );

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO update_planning_group;
    X_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.count_and_get( p_count => X_msg_count
                             , p_data  => X_msg_data );

  WHEN OTHERS THEN
    ROLLBACK TO update_planning_group;
    X_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.add_exc_msg( p_pkg_name        => G_pkg_name
                             , p_procedure_name  => l_api_name);
    END IF;
    FND_MSG_PUB.count_and_get( p_count => X_msg_count
                             , p_data  => X_msg_data );

END update_planning_group;

END PJM_PROJECT_PARAM_PUB;

/
