--------------------------------------------------------
--  DDL for Package Body OKL_CHECKLIST_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_CHECKLIST_PVT" AS
/* $Header: OKLRCKLB.pls 120.15 2006/07/11 09:43:04 dkagrawa noship $ */
----------------------------------------------------------------------------
-- Global Message Constants
----------------------------------------------------------------------------
      G_NEW_STS_CODE  VARCHAR2(10) := 'NEW';
      G_ACTIVE_STS_CODE  VARCHAR2(10) := 'ACTIVE';
-- start: 06-June-2005  cklee okl.h Lease App IA Authoring
 G_OKL_LEASE_APP        CONSTANT VARCHAR2(30) := 'OKL_LEASE_APP';
 G_CONTRACT             CONSTANT VARCHAR2(30) := 'CONTRACT';
 G_ACTIVE               CONSTANT VARCHAR2(30) := 'ACTIVE';
 -- end: 06-June-2005  cklee okl.h Lease App IA Authoring
  L_MODULE                   FND_LOG_MESSAGES.MODULE%TYPE;
  L_DEBUG_ENABLED            VARCHAR2(10);
  IS_DEBUG_PROCEDURE_ON      BOOLEAN;
  IS_DEBUG_STATEMENT_ON      BOOLEAN;
----------------------------------------------------------------------------
-- Procedures and Functions
----------------------------------------------------------------------------

-- start: Apr 25, 2005 cklee: Modification for okl.h lease app enhancement
  --------------------------------------------------------------------------
  ----- Validate Status Code
  --------------------------------------------------------------------------
  FUNCTION validate_status_code(
    p_clhv_rec     clhv_rec_type
    ,p_mode        VARCHAR2
  ) RETURN VARCHAR2
  IS
    l_return_status   VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_dummy  number;

    l_row_not_found boolean := false;

  CURSOR c_lookup (p_lookup_code VARCHAR2)
    IS
    SELECT 1
      FROM fnd_lookups lok
     WHERE lok.lookup_type = 'OKL_CHECKLIST_STATUS_CODE'
     AND lok.lookup_code = p_lookup_code
    ;

  BEGIN

  IF (p_mode = G_INSERT_MODE) THEN

    -- column is required:
    IF (p_clhv_rec.status_code IS NULL) OR
       (p_clhv_rec.status_code = OKL_API.G_MISS_CHAR)
    THEN
      OKL_API.Set_Message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_REQUIRED_VALUE,
                          p_token1       => G_COL_NAME_TOKEN,
                          p_token1_value => 'OKL_CHECKLIST.STATUS_CODE');
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

-- There is no need if user doesn't want to update this column
/*  ELSIF (p_mode = G_UPDATE_MODE) THEN

    -- column is required:
    IF (p_clhv_rec.status_code IS NULL)
    THEN
      OKL_API.Set_Message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_REQUIRED_VALUE,
                          p_token1       => G_COL_NAME_TOKEN,
                          p_token1_value => 'OKL_CHECKLIST.STATUS_CODE');
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
*/
  END IF;

  -- FK check
  -- check only if object exists
  IF (p_clhv_rec.status_code IS NOT NULL AND
      p_clhv_rec.status_code <> OKL_API.G_MISS_CHAR)
  THEN

    OPEN c_lookup(p_clhv_rec.status_code);
    FETCH c_lookup INTO l_dummy;
    l_row_not_found := c_lookup%NOTFOUND;
    CLOSE c_lookup;

    IF (l_row_not_found) THEN
      OKL_API.Set_Message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_INVALID_VALUE,
                          p_token1       => G_COL_NAME_TOKEN,
                          p_token1_value => 'OKL_CHECKLIST.STATUS_CODE');

      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
  END IF;


  RETURN l_return_status;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      l_return_status := OKL_API.G_RET_STS_ERROR;
      RETURN l_return_status;
    WHEN OTHERS THEN
      l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR ;
      OKL_API.Set_Message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_UNEXPECTED_ERROR,
                          p_token1        => G_SQLCODE_TOKEN,
                          p_token1_value  => SQLCODE,
                          p_token2        => G_SQLERRM_TOKEN,
                          p_token2_value  => SQLERRM);
      RETURN l_return_status;
  END;
  --------------------------------------------------------------------------
  ----- Validate Purpose code
  --------------------------------------------------------------------------
  FUNCTION validate_purpose_code(
    p_clhv_rec     clhv_rec_type
    ,p_mode        VARCHAR2
  ) RETURN VARCHAR2
  IS
    l_return_status   VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_dummy  varchar2(80);

    l_row_not_found boolean := false;
    l_org_purpose_code        okl_checklists.CHECKLIST_PURPOSE_CODE%type;
    l_org_status_code         okl_checklists_uv.STATUS_CODE%type;
    l_org_status_code_meaning okl_checklists_uv.STATUS_CODE_MEANING%type;

    l_cur_status_code_meaning okl_checklists_uv.STATUS_CODE_MEANING%type;


  CURSOR c_lookup (p_lookup_code VARCHAR2,
                   p_lookup_type VARCHAR2)
    IS
    SELECT lok.MEANING
      FROM fnd_lookups lok
     WHERE lok.lookup_type = p_lookup_type
     AND lok.lookup_code = p_lookup_code
    ;

  CURSOR c_org_purpose (p_clh_id number)
    IS
    SELECT clh.CHECKLIST_PURPOSE_CODE,
           clh.STATUS_CODE,
           clh.STATUS_CODE_MEANING
      FROM okl_checklists_uv clh
     WHERE clh.id = p_clh_id
    ;

  BEGIN

  IF (p_mode = G_INSERT_MODE) THEN

    -- column is required:
    IF (p_clhv_rec.CHECKLIST_PURPOSE_CODE IS NULL) OR
       (p_clhv_rec.CHECKLIST_PURPOSE_CODE = OKL_API.G_MISS_CHAR)
    THEN
      OKL_API.Set_Message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_REQUIRED_VALUE,
                          p_token1       => G_COL_NAME_TOKEN,
                          p_token1_value => 'OKL_CHECKLIST.CHECKLIST_PURPOSE_CODE');
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  ELSIF (p_mode = G_UPDATE_MODE) THEN

    ---------------------------------------------------------------
    -- User are not allowed to modify the purpose code
    ---------------------------------------------------------------
    OPEN c_org_purpose(p_clhv_rec.id);
    FETCH c_org_purpose INTO l_org_purpose_code,
                             l_org_status_code,
                             l_org_status_code_meaning;
    CLOSE c_org_purpose;

    IF (p_clhv_rec.CHECKLIST_PURPOSE_CODE IS NOT NULL AND
        p_clhv_rec.CHECKLIST_PURPOSE_CODE <> OKL_API.G_MISS_CHAR AND
        p_clhv_rec.CHECKLIST_PURPOSE_CODE <> l_org_purpose_code)
    THEN

      -- get the current status
      IF (p_clhv_rec.STATUS_CODE IS NOT NULL AND
          p_clhv_rec.STATUS_CODE <> OKL_API.G_MISS_CHAR AND
          p_clhv_rec.STATUS_CODE <> l_org_status_code)
      THEN

        OPEN c_lookup(p_clhv_rec.STATUS_CODE,'OKL_CHECKLIST_STATUS_CODE');
        FETCH c_lookup INTO l_cur_status_code_meaning;
        CLOSE c_lookup;

      ELSE
        l_cur_status_code_meaning := l_org_status_code_meaning;

      END IF;

      OKL_API.Set_Message(p_app_name     => G_APP_NAME,
                          p_msg_name     => 'OKL_CHK_READONLY_COLUMN',
                          p_token1       => 'COL_NAME',
                          p_token1_value => 'Purpose',
                          p_token2       => 'STATUS',
                          p_token2_value => l_cur_status_code_meaning);
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  END IF;

  -- FK check
  -- check only if object exists
  IF (p_clhv_rec.CHECKLIST_PURPOSE_CODE IS NOT NULL AND
      p_clhv_rec.CHECKLIST_PURPOSE_CODE <> OKL_API.G_MISS_CHAR)
  THEN

    OPEN c_lookup(p_clhv_rec.CHECKLIST_PURPOSE_CODE,
                  'OKL_CHECKLIST_PURPOSE_CODE');
    FETCH c_lookup INTO l_dummy;
    l_row_not_found := c_lookup%NOTFOUND;
    CLOSE c_lookup;

    IF (l_row_not_found) THEN
      OKL_API.Set_Message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_INVALID_VALUE,
                          p_token1       => G_COL_NAME_TOKEN,
                          p_token1_value => 'OKL_CHECKLIST.CHECKLIST_PURPOSE_CODE');

      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
  END IF;


  RETURN l_return_status;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      l_return_status := OKL_API.G_RET_STS_ERROR;
      RETURN l_return_status;
    WHEN OTHERS THEN
      l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR ;
      OKL_API.Set_Message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_UNEXPECTED_ERROR,
                          p_token1        => G_SQLCODE_TOKEN,
                          p_token1_value  => SQLCODE,
                          p_token2        => G_SQLERRM_TOKEN,
                          p_token2_value  => SQLERRM);
      RETURN l_return_status;
  END;
  --------------------------------------------------------------------------
  ----- Validate Obj ID
  --------------------------------------------------------------------------
  FUNCTION validate_obj_ID(
    p_clhv_rec     clhv_rec_type
    ,p_mode        VARCHAR2
  ) RETURN VARCHAR2
  IS
    l_return_status   VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_dummy  number;

    l_row_not_found boolean := false;
    l_purpose_code okl_checklists.CHECKLIST_PURPOSE_CODE%type;

cursor c_purpose(p_clh_id number) is
  select clh.CHECKLIST_PURPOSE_CODE
  from okl_checklists clh
  where clh.id = p_clh_id
  ;

  BEGIN

  OPEN c_purpose(p_clhv_rec.id);
  FETCH c_purpose INTO l_purpose_code;
  CLOSE c_purpose;

  IF (p_mode = G_INSERT_MODE) THEN

    -- column is required:
    IF l_purpose_code = 'CHECKLIST_INSTANCE' AND
       (p_clhv_rec.CHECKLIST_OBJ_ID IS NULL OR
        p_clhv_rec.CHECKLIST_OBJ_ID = OKL_API.G_MISS_NUM)
    THEN
      OKL_API.Set_Message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_REQUIRED_VALUE,
                          p_token1       => G_COL_NAME_TOKEN,
                          p_token1_value => 'OKL_CHECKLIST.CHECKLIST_OBJ_ID');
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

-- There is no need if user doesn't want to update this column
/*  ELSIF (p_mode = G_UPDATE_MODE) THEN

    -- column is required:
    IF l_purpose_code = 'CHECKLIST_INSTANCE' AND
       p_clhv_rec.CHECKLIST_OBJ_ID IS NULL
    THEN
      OKL_API.Set_Message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_REQUIRED_VALUE,
                          p_token1       => G_COL_NAME_TOKEN,
                          p_token1_value => 'OKL_CHECKLIST.CHECKLIST_OBJ_ID');
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
*/
  END IF;

  RETURN l_return_status;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      l_return_status := OKL_API.G_RET_STS_ERROR;
      RETURN l_return_status;
    WHEN OTHERS THEN
      l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR ;
      OKL_API.Set_Message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_UNEXPECTED_ERROR,
                          p_token1        => G_SQLCODE_TOKEN,
                          p_token1_value  => SQLCODE,
                          p_token2        => G_SQLERRM_TOKEN,
                          p_token2_value  => SQLERRM);
      RETURN l_return_status;
  END;

  --------------------------------------------------------------------------
  ----- Validate Obj type code
  --------------------------------------------------------------------------
  FUNCTION validate_obj_type_code(
    p_clhv_rec     clhv_rec_type
    ,p_mode        VARCHAR2
  ) RETURN VARCHAR2
  IS
    l_return_status   VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_dummy  number;

    l_row_not_found boolean := false;
    l_purpose_code okl_checklists.CHECKLIST_PURPOSE_CODE%type;

  CURSOR c_lookup (p_lookup_code VARCHAR2)
    IS
    SELECT 1
      FROM fnd_lookups lok
     WHERE lok.lookup_type = 'OKL_CHECKLIST_OBJ_TYPE_CODE'
     AND lok.lookup_code = p_lookup_code
    ;

 cursor c_purpose(p_clh_id number) is
  select clh.CHECKLIST_PURPOSE_CODE
  from okl_checklists clh
  where clh.id = p_clh_id
  ;

  BEGIN

  OPEN c_purpose(p_clhv_rec.id);
  FETCH c_purpose INTO l_purpose_code;
  CLOSE c_purpose;

  IF (p_mode = G_INSERT_MODE) THEN

    -- column is required:
    IF l_purpose_code = 'CHECKLIST_INSTANCE' AND
       (p_clhv_rec.CHECKLIST_OBJ_TYPE_CODE IS NULL OR
        p_clhv_rec.CHECKLIST_OBJ_TYPE_CODE = OKL_API.G_MISS_CHAR)
    THEN
      OKL_API.Set_Message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_REQUIRED_VALUE,
                          p_token1       => G_COL_NAME_TOKEN,
                          p_token1_value => 'OKL_CHECKLIST.CHECKLIST_OBJ_TYPE_CODE');
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

-- There is no need if user doesn't want to update this column
/*  ELSIF (p_mode = G_UPDATE_MODE) THEN

    -- column is required:
    IF l_purpose_code = 'CHECKLIST_INSTANCE' AND
       p_clhv_rec.CHECKLIST_OBJ_TYPE_CODE IS NULL
    THEN
      OKL_API.Set_Message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_REQUIRED_VALUE,
                          p_token1       => G_COL_NAME_TOKEN,
                          p_token1_value => 'OKL_CHECKLIST.CHECKLIST_OBJ_TYPE_CODE');
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
*/
  END IF;

  -- FK check
  -- check only if object exists
  IF (p_clhv_rec.CHECKLIST_OBJ_TYPE_CODE IS NOT NULL AND
      p_clhv_rec.CHECKLIST_OBJ_TYPE_CODE <> OKL_API.G_MISS_CHAR)
  THEN

    OPEN c_lookup(p_clhv_rec.CHECKLIST_OBJ_TYPE_CODE);
    FETCH c_lookup INTO l_dummy;
    l_row_not_found := c_lookup%NOTFOUND;
    CLOSE c_lookup;

    IF (l_row_not_found) THEN
      OKL_API.Set_Message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_INVALID_VALUE,
                          p_token1       => G_COL_NAME_TOKEN,
                          p_token1_value => 'OKL_CHECKLIST.CHECKLIST_OBJ_TYPE_CODE');

      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
  END IF;


  RETURN l_return_status;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      l_return_status := OKL_API.G_RET_STS_ERROR;
      RETURN l_return_status;
    WHEN OTHERS THEN
      l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR ;
      OKL_API.Set_Message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_UNEXPECTED_ERROR,
                          p_token1        => G_SQLCODE_TOKEN,
                          p_token1_value  => SQLCODE,
                          p_token2        => G_SQLERRM_TOKEN,
                          p_token2_value  => SQLERRM);
      RETURN l_return_status;
  END;
 --------------------------------------------------------------------------
  ----- Validate parent id
  --------------------------------------------------------------------------
  FUNCTION validate_ckl_id(
    p_clhv_rec     clhv_rec_type
    ,p_mode        VARCHAR2
  ) RETURN VARCHAR2
  IS
    l_return_status   VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_dummy  number;

    l_row_not_found boolean := false;

  CURSOR c_parent_id (p_id NUMBER)
    IS
    SELECT 1
      FROM okl_checklists ckl
     WHERE ckl.CHECKLIST_PURPOSE_CODE = 'CHECKLIST_TEMPLATE_GROUP'
--     AND ckl.STATUS_CODE = 'NEW'
     AND ckl.id = p_id
    ;

  BEGIN

  -- FK check
  -- check only if object exists
  IF (p_clhv_rec.CKL_ID IS NOT NULL AND
      p_clhv_rec.CKL_ID <> OKL_API.G_MISS_NUM)
  THEN

    OPEN c_parent_id(p_clhv_rec.CKL_ID);
    FETCH c_parent_id INTO l_dummy;
    l_row_not_found := c_parent_id%NOTFOUND;
    CLOSE c_parent_id;

    IF (l_row_not_found) THEN
      OKL_API.Set_Message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_INVALID_VALUE,
                          p_token1       => G_COL_NAME_TOKEN,
                          p_token1_value => 'OKL_CHECKLISTS.CKL_ID');

      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
  END IF;

  -- Parent checklist is allowed only if checklist purpose is 'Checklist Template'
  IF ((p_clhv_rec.CKL_ID IS NOT NULL AND
       p_clhv_rec.CKL_ID <> OKL_API.G_MISS_NUM) and
      (p_clhv_rec.CHECKLIST_PURPOSE_CODE <> 'CHECKLIST_TEMPLATE'))
  THEN
      OKL_API.Set_Message(p_app_name     => G_APP_NAME,
                          p_msg_name     => 'OKL_INVALID_PARENT_CHECKLIST');

      RAISE G_EXCEPTION_HALT_VALIDATION;
  END IF;


  RETURN l_return_status;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      l_return_status := OKL_API.G_RET_STS_ERROR;
      RETURN l_return_status;
    WHEN OTHERS THEN
      l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR ;
      OKL_API.Set_Message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_UNEXPECTED_ERROR,
                          p_token1        => G_SQLCODE_TOKEN,
                          p_token1_value  => SQLCODE,
                          p_token2        => G_SQLERRM_TOKEN,
                          p_token2_value  => SQLERRM);
      RETURN l_return_status;
  END;
-- end: Apr 25, 2005 cklee: Modification for okl.h lease app enhancement
  --------------------------------------------------------------------------
  ----- Validate Checklist Number
  --------------------------------------------------------------------------
  FUNCTION validate_clh_number(
    p_clhv_rec     clhv_rec_type
    ,p_mode        VARCHAR2
  ) RETURN VARCHAR2
  IS
    l_return_status   VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;

  BEGIN

  IF (p_mode = G_INSERT_MODE) THEN

    -- column is required:
    IF (p_clhv_rec.checklist_number IS NULL) OR
       (p_clhv_rec.checklist_number = OKL_API.G_MISS_CHAR)
    THEN
      OKL_API.Set_Message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_REQUIRED_VALUE,
                          p_token1       => G_COL_NAME_TOKEN,
                          p_token1_value => 'Checklist Name');
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

-- There is no need if user doesn't want to update this column
/*  ELSIF (p_mode = G_UPDATE_MODE) THEN

    -- column is required:
    IF (p_clhv_rec.checklist_number IS NULL)
    THEN
      OKL_API.Set_Message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_REQUIRED_VALUE,
                          p_token1       => G_COL_NAME_TOKEN,
                          p_token1_value => 'Checklist Name');
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
*/
  END IF;

  RETURN l_return_status;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      l_return_status := OKL_API.G_RET_STS_ERROR;
      RETURN l_return_status;
    WHEN OTHERS THEN
      l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR ;
      OKL_API.Set_Message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_UNEXPECTED_ERROR,
                          p_token1        => G_SQLCODE_TOKEN,
                          p_token1_value  => SQLCODE,
                          p_token2        => G_SQLERRM_TOKEN,
                          p_token2_value  => SQLERRM);
      RETURN l_return_status;
  END;

  --------------------------------------------------------------------------
  ----- Validate Checklist Type
  --------------------------------------------------------------------------
  FUNCTION validate_clh_type(
    p_clhv_rec     clhv_rec_type
    ,p_mode        VARCHAR2
  ) RETURN VARCHAR2
  IS
    l_return_status   VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_dummy  varchar2(80);

    l_row_not_found boolean := false;

    l_org_checklist_type      okl_checklists.CHECKLIST_TYPE%type;
    l_org_status_code         okl_checklists_uv.STATUS_CODE%type;
    l_org_status_code_meaning okl_checklists_uv.STATUS_CODE_MEANING%type;

    l_cur_status_code_meaning okl_checklists_uv.STATUS_CODE_MEANING%type;


  CURSOR c_lookup (p_lookup_code VARCHAR2,
                   p_lookup_type VARCHAR2)
    IS
    SELECT lok.MEANING
      FROM fnd_lookups lok
     WHERE lok.lookup_type = p_lookup_type
     AND lok.lookup_code = p_lookup_code
     AND lok.enabled_flag = 'Y'
    ;

  CURSOR c_org_checklist_type (p_clh_id number)
    IS
    SELECT clh.CHECKLIST_TYPE,
           clh.STATUS_CODE,
           clh.STATUS_CODE_MEANING
      FROM okl_checklists_uv clh
     WHERE clh.id = p_clh_id
    ;


  BEGIN

  IF (p_mode = G_INSERT_MODE) THEN

    -- column is required:
    IF (p_clhv_rec.checklist_type IS NULL) OR
       (p_clhv_rec.checklist_type = OKL_API.G_MISS_CHAR)
    THEN
      OKL_API.Set_Message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_REQUIRED_VALUE,
                          p_token1       => G_COL_NAME_TOKEN,
                          p_token1_value => 'Checklist Type');
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    ---------------------------------------------------------------
    -- User are not allowed to modify the checklist type
    ---------------------------------------------------------------
    OPEN c_org_checklist_type(p_clhv_rec.id);
    FETCH c_org_checklist_type INTO l_org_checklist_type,
                             l_org_status_code,
                             l_org_status_code_meaning;
    CLOSE c_org_checklist_type;

    IF (p_clhv_rec.CHECKLIST_TYPE IS NOT NULL AND
        p_clhv_rec.CHECKLIST_TYPE <> OKL_API.G_MISS_CHAR AND
        p_clhv_rec.CHECKLIST_TYPE <> l_org_checklist_type)
    THEN

      -- get the current status
      IF (p_clhv_rec.STATUS_CODE IS NOT NULL AND
          p_clhv_rec.STATUS_CODE <> OKL_API.G_MISS_CHAR AND
          p_clhv_rec.STATUS_CODE <> l_org_status_code)
      THEN

        OPEN c_lookup(p_clhv_rec.STATUS_CODE,'OKL_CHECKLIST_STATUS_CODE');
        FETCH c_lookup INTO l_cur_status_code_meaning;
        CLOSE c_lookup;

      ELSE
        l_cur_status_code_meaning := l_org_status_code_meaning;

      END IF;

      OKL_API.Set_Message(p_app_name     => G_APP_NAME,
                          p_msg_name     => 'OKL_CHK_READONLY_COLUMN',
                          p_token1       => 'COL_NAME',
                          p_token1_value => 'Checklist Type',
                          p_token2       => 'STATUS',
                          p_token2_value => l_cur_status_code_meaning);
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  END IF;

  -- FK check
  -- check only if checklist type exists
  IF (p_clhv_rec.checklist_type IS NOT NULL AND
      p_clhv_rec.checklist_type <> OKL_API.G_MISS_CHAR)
  THEN

    OPEN c_lookup(p_clhv_rec.checklist_type, G_CHECKLIST_TYPE_LOOKUP_TYPE);
    FETCH c_lookup INTO l_dummy;
    l_row_not_found := c_lookup%NOTFOUND;
    CLOSE c_lookup;

    IF (l_row_not_found) THEN
      OKL_API.Set_Message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_INVALID_VALUE,
                          p_token1       => G_COL_NAME_TOKEN,
                          p_token1_value => 'Checklist Type');

      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
  END IF;

  RETURN l_return_status;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      l_return_status := OKL_API.G_RET_STS_ERROR;
      RETURN l_return_status;
    WHEN OTHERS THEN
      l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR ;
      OKL_API.Set_Message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_UNEXPECTED_ERROR,
                          p_token1        => G_SQLCODE_TOKEN,
                          p_token1_value  => SQLCODE,
                          p_token2        => G_SQLERRM_TOKEN,
                          p_token2_value  => SQLERRM);
      RETURN l_return_status;
  END;

  --------------------------------------------------------------------------
  ----- Validate Short Description
  --------------------------------------------------------------------------
  FUNCTION validate_short_desc(
    p_clhv_rec     clhv_rec_type
    ,p_mode        VARCHAR2
  ) RETURN VARCHAR2
  IS
    l_return_status   VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  BEGIN

    IF (p_clhv_rec.short_description IS NOT NULL AND
        p_clhv_rec.short_description <> OKL_API.G_MISS_CHAR)
    THEN

      IF (length(p_clhv_rec.short_description) > 600) THEN

        OKL_API.Set_Message(p_app_name     => G_APP_NAME,
                          p_msg_name     => 'OKL_LLA_EXCEED_MAXIMUM_LENGTH',
                          p_token1       => 'MAX_CHARS',
                          p_token1_value => '600',
                          p_token2       => 'COL_NAME',
                          p_token2_value => 'Short Description');

        RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;
    END IF;

    RETURN l_return_status;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      l_return_status := OKL_API.G_RET_STS_ERROR;
      RETURN l_return_status;
    WHEN OTHERS THEN
      l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR ;
      OKL_API.Set_Message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_UNEXPECTED_ERROR,
                          p_token1        => G_SQLCODE_TOKEN,
                          p_token1_value  => SQLCODE,
                          p_token2        => G_SQLERRM_TOKEN,
                          p_token2_value  => SQLERRM);
      RETURN l_return_status;
  END;

  --------------------------------------------------------------------------
  ----- Validate Description
  --------------------------------------------------------------------------
  FUNCTION validate_description(
    p_clhv_rec     clhv_rec_type
    ,p_mode        VARCHAR2
  ) RETURN VARCHAR2
  IS
    l_return_status   VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  BEGIN

    IF (p_clhv_rec.description IS NOT NULL AND
        p_clhv_rec.description <> OKL_API.G_MISS_CHAR)
    THEN

      IF (length(p_clhv_rec.description) > 1995) THEN

        OKL_API.Set_Message(p_app_name     => G_APP_NAME,
                          p_msg_name     => 'OKL_LLA_EXCEED_MAXIMUM_LENGTH',
                          p_token1       => 'MAX_CHARS',
                          p_token1_value => '1995',
                          p_token2       => 'COL_NAME',
                          p_token2_value => 'Description');

        RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;
    END IF;

    RETURN l_return_status;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      l_return_status := OKL_API.G_RET_STS_ERROR;
      RETURN l_return_status;
    WHEN OTHERS THEN
      l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR ;
      OKL_API.Set_Message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_UNEXPECTED_ERROR,
                          p_token1        => G_SQLCODE_TOKEN,
                          p_token1_value  => SQLCODE,
                          p_token2        => G_SQLERRM_TOKEN,
                          p_token2_value  => SQLERRM);
      RETURN l_return_status;
  END;

  --------------------------------------------------------------------------
  ----- Validate Effective To
  --------------------------------------------------------------------------
  FUNCTION validate_effective_to(
    p_clhv_rec     clhv_rec_type
    ,p_mode        VARCHAR2
  ) RETURN VARCHAR2
  IS
    l_return_status   VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_dummy  number;

  BEGIN

-- fixed 10/22/03
  IF (p_mode = G_INSERT_MODE) THEN

    -- column is required:
    IF (p_clhv_rec.end_date IS NULL) OR
       (p_clhv_rec.end_date = OKL_API.G_MISS_DATE)
    THEN
      OKL_API.Set_Message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_REQUIRED_VALUE,
                          p_token1       => G_COL_NAME_TOKEN,
                          p_token1_value => 'Effective To');
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

-- There is no need if user doesn't want to update this column
/*  ELSIF (p_mode = G_UPDATE_MODE) THEN

    -- column is required:
    IF (p_clhv_rec.end_date IS NULL)
    THEN
      OKL_API.Set_Message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_REQUIRED_VALUE,
                          p_token1       => G_COL_NAME_TOKEN,
                          p_token1_value => 'Effective To');
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
*/
  END IF;

  IF (p_clhv_rec.end_date IS NOT NULL) AND
       (p_clhv_rec.end_date <> OKL_API.G_MISS_DATE)
  THEN

    IF (trunc(p_clhv_rec.end_date) < trunc(sysdate))
    THEN
      OKL_API.Set_Message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_LLA_RANGE_CHECK,
                          p_token1       => 'COL_NAME1',
                          p_token1_value => 'Effective To',
                          p_token2       => 'COL_NAME2',
                          p_token2_value => 'today');

      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
  END IF;

  RETURN l_return_status;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      l_return_status := OKL_API.G_RET_STS_ERROR;
      RETURN l_return_status;
    WHEN OTHERS THEN
      l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR ;
      OKL_API.Set_Message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_UNEXPECTED_ERROR,
                          p_token1        => G_SQLCODE_TOKEN,
                          p_token1_value  => SQLCODE,
                          p_token2        => G_SQLERRM_TOKEN,
                          p_token2_value  => SQLERRM);
      RETURN l_return_status;
  END;

-- start: Apr 25, 2005 cklee: Modification for okl.h lease app enhancement
  --------------------------------------------------------------------------
  ----- Validate date overlapping within group
  --------------------------------------------------------------------------
  FUNCTION validate_dates_overlap(
    p_clhv_rec     clhv_rec_type
    ,p_mode        VARCHAR2
  ) RETURN VARCHAR2
  IS
    l_return_status   VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_dummy  number;

    l_row_not_found boolean := false;
    l_purpose_code okl_checklists.CHECKLIST_PURPOSE_CODE%type;

  CURSOR c_purpose (p_clh_id number)
    IS
    SELECT clh.CHECKLIST_PURPOSE_CODE
      FROM okl_checklists clh
     WHERE clh.id = p_clh_id
    ;

  -- get all rows by group id
  CURSOR c_grp_dates (p_clh_id number)
    IS
    SELECT grp.START_DATE grp_START_DATE,
           grp.END_DATE grp_END_DATE,
           cld.START_DATE cld_START_DATE,
           cld.END_DATE cld_END_DATE
      FROM okl_checklists grp,
           okl_checklists cld
     WHERE grp.id = cld.ckl_id
     AND   grp.id = p_clh_id
    ;

  -- get row by checklist id
  CURSOR c_checklist_dates (p_clh_id number)
    IS
    SELECT grp.START_DATE grp_START_DATE,
           grp.END_DATE grp_END_DATE,
           cld.START_DATE cld_START_DATE,
           cld.END_DATE cld_END_DATE
      FROM okl_checklists grp,
           okl_checklists cld
     WHERE grp.id = cld.ckl_id
     AND   cld.id = p_clh_id
    ;

  BEGIN

    -- Notice that end date is required for checklist template. Assume that
    -- system pass the end date check already.
    OPEN c_purpose(p_clhv_rec.id);
    FETCH c_purpose INTO l_purpose_code;
    CLOSE c_purpose;

--dbms_output.put_line('l_purpose_code :'|| l_purpose_code);

    ---------------------------------------------------------------------
    -- Group checklist
    ---------------------------------------------------------------------
    IF l_purpose_code = 'CHECKLIST_TEMPLATE_GROUP' THEN

      FOR r_this_row IN c_grp_dates (p_clhv_rec.id) LOOP

        IF r_this_row.grp_START_DATE IS NOT NULL THEN

          IF r_this_row.cld_START_DATE IS NOT NULL THEN

             -- check dates overlap between each other
             IF (r_this_row.cld_START_DATE > r_this_row.grp_END_DATE or
                     r_this_row.grp_START_DATE > r_this_row.cld_END_DATE) THEN

                OKL_API.Set_Message(p_app_name     => G_APP_NAME,
                                    p_msg_name     => 'OKL_CHK_CLIST_DATE_OVERLAPS');
--dbms_output.put_line('CHECKLIST_TEMPLATE_GROUP: case1');

             END IF;

          ELSE
             -- chlid end date < group start date
             IF r_this_row.cld_END_DATE < r_this_row.grp_START_DATE THEN
                OKL_API.Set_Message(p_app_name     => G_APP_NAME,
                                    p_msg_name     => 'OKL_CHK_CLIST_DATE_OVERLAPS');
--dbms_output.put_line('CHECKLIST_TEMPLATE_GROUP: case2');
             END IF;

          END IF;

        ELSE -- group start date is null

          IF r_this_row.cld_START_DATE IS NOT NULL THEN

             -- chlid start date > group end date
             IF r_this_row.cld_START_DATE > r_this_row.grp_END_DATE THEN
                OKL_API.Set_Message(p_app_name     => G_APP_NAME,
                                    p_msg_name     => 'OKL_CHK_CLIST_DATE_OVERLAPS');
--dbms_output.put_line('CHECKLIST_TEMPLATE_GROUP: case3');
             END IF;

          -- We don't need to check overlap if both sart dates are null
          END IF;

        END IF;

      END LOOP;

    ---------------------------------------------------------------------
    -- checklist
    ---------------------------------------------------------------------
    ELSIF l_purpose_code = 'CHECKLIST_TEMPLATE' THEN

      FOR r_this_row IN c_checklist_dates (p_clhv_rec.id) LOOP

       IF r_this_row.grp_START_DATE IS NOT NULL THEN

          IF r_this_row.cld_START_DATE IS NOT NULL THEN

             -- check dates overlap between each other
             IF (r_this_row.cld_START_DATE > r_this_row.grp_END_DATE or
                     r_this_row.grp_START_DATE > r_this_row.cld_END_DATE) THEN

                OKL_API.Set_Message(p_app_name     => G_APP_NAME,
                                    p_msg_name     => 'OKL_CHK_CLIST_DATE_OVERLAPS');
--dbms_output.put_line('CHECKLIST_TEMPLATE: case1');
             END IF;

          ELSE
             -- chlid end date < group start date
             IF r_this_row.cld_END_DATE < r_this_row.grp_START_DATE THEN
                OKL_API.Set_Message(p_app_name     => G_APP_NAME,
                                    p_msg_name     => 'OKL_CHK_CLIST_DATE_OVERLAPS');
--dbms_output.put_line('CHECKLIST_TEMPLATE: case2');
             END IF;

          END IF;

        ELSE -- group start date is null

          IF r_this_row.cld_START_DATE IS NOT NULL THEN

             -- chlid start date > group end date
             IF r_this_row.cld_START_DATE > r_this_row.grp_END_DATE THEN
                OKL_API.Set_Message(p_app_name     => G_APP_NAME,
                                    p_msg_name     => 'OKL_CHK_CLIST_DATE_OVERLAPS');
--dbms_output.put_line('CHECKLIST_TEMPLATE: case3');
             END IF;

          -- We don't need to check overlap if both sart dates are null
          END IF;

        END IF;

      END LOOP;

    END IF;

  RETURN l_return_status;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      l_return_status := OKL_API.G_RET_STS_ERROR;
      RETURN l_return_status;
    WHEN OTHERS THEN
      l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR ;
      OKL_API.Set_Message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_UNEXPECTED_ERROR,
                          p_token1        => G_SQLCODE_TOKEN,
                          p_token1_value  => SQLCODE,
                          p_token2        => G_SQLERRM_TOKEN,
                          p_token2_value  => SQLERRM);
      RETURN l_return_status;
  END;


-- end: Apr 25, 2005 cklee: Modification for okl.h lease app enhancement

  --------------------------------------------------------------------------
  ----- Validate Checklist Number uniqueness :after image
  --------------------------------------------------------------------------
  FUNCTION validate_unq_clh_number(
    p_clhv_rec     clhv_rec_type
    ,p_mode        VARCHAR2
  ) RETURN VARCHAR2
  IS
    l_return_status   VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_count  number := 0;
    l_row_found boolean := false;
    l_dummy number;

  CURSOR c_unq (p_checklist_number VARCHAR2, p_checklist_type VARCHAR2)
    IS
    SELECT count(1)
      FROM okl_checklists clh
     WHERE UPPER(clh.checklist_number) = UPPER(p_checklist_number)
     AND   clh.checklist_type = p_checklist_type
    ;

  BEGIN

    OPEN c_unq(p_clhv_rec.checklist_number, p_clhv_rec.checklist_type);
    FETCH c_unq INTO l_count;
    l_row_found := c_unq%FOUND;
    CLOSE c_unq;

    IF (l_count > 1) THEN
      OKL_API.Set_Message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_NOT_UNIQUE,
                          p_token1       => G_COL_NAME_TOKEN,
                          p_token1_value => 'The combinations of the Checklist Name and the Type');

      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  RETURN l_return_status;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      l_return_status := OKL_API.G_RET_STS_ERROR;
      RETURN l_return_status;
    WHEN OTHERS THEN
      l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR ;
      OKL_API.Set_Message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_UNEXPECTED_ERROR,
                          p_token1        => G_SQLCODE_TOKEN,
                          p_token1_value  => SQLCODE,
                          p_token2        => G_SQLERRM_TOKEN,
                          p_token2_value  => SQLERRM);
      RETURN l_return_status;
  END;

  --------------------------------------------------------------------------
  ----- Validate Effective from and Effective To: after image
  --------------------------------------------------------------------------
  FUNCTION validate_effective_date(
    p_clhv_rec     clhv_rec_type
    ,p_mode        VARCHAR2
  ) RETURN VARCHAR2
  IS
    l_return_status   VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_dummy  number;
    l_row_found boolean := false;

cursor c_date(p_id number)
  is select 1
from okl_checklists clh
where clh.start_date is not null
and trunc(clh.start_date) > trunc(clh.end_date)
and clh.id = p_id
;

  BEGIN

    open c_date(p_clhv_rec.id);
    fetch c_date into l_dummy;
    l_row_found := c_date%FOUND;
    close c_date;

    IF (l_row_found) THEN
      OKL_API.Set_Message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_LLA_RANGE_CHECK,
                          p_token1       => 'COL_NAME1',
                          p_token1_value => 'Effective To',
                          p_token2       => 'COL_NAME2',
                          p_token2_value => 'Effective From');

      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  RETURN l_return_status;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      l_return_status := OKL_API.G_RET_STS_ERROR;
      RETURN l_return_status;
    WHEN OTHERS THEN
      l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR ;
      OKL_API.Set_Message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_UNEXPECTED_ERROR,
                          p_token1        => G_SQLCODE_TOKEN,
                          p_token1_value  => SQLCODE,
                          p_token2        => G_SQLERRM_TOKEN,
                          p_token2_value  => SQLERRM);
      RETURN l_return_status;
  END;
-- start: Apr 25, 2005 cklee: Modification for okl.h lease app enhancement
  --------------------------------------------------------------------------
  ----- Validate duplicated type, item, and function across the checklist
  ----- templates in the same group
  --------------------------------------------------------------------------
  FUNCTION validate_duplicated_keys(
    p_cldv_rec     cldv_rec_type
    ,p_mode        VARCHAR2
  ) RETURN VARCHAR2
  IS
    l_return_status   VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_count  number := 0;
    l_row_found boolean := false;
    l_dummy number;

    l_ckl_id okl_checklist_details.ckl_id%type;

  CURSOR c_ckl_id(p_cld_id number) is
    select cld.ckl_id
      from okl_checklist_details cld
    where cld.id = p_cld_id
    ;

  CURSOR c_dup (p_clh_id number)
    IS
    SELECT 1
      FROM okl_checklist_details cld,
           okl_checklists clh
      where  clh.id = cld.ckl_id -- get clh.checklist_type
      and   clh.checklist_purpose_code = 'CHECKLIST_TEMPLATE'
      and   cld.ckl_id in (select lst.id
                           from   okl_checklists lst,
                                  okl_checklists prt
                           where  lst.ckl_id = prt.ckl_id
                           and    prt.id = p_clh_id)
      GROUP BY cld.todo_item_code, cld.FUNCTION_ID, clh.checklist_type
      HAVING count(1) > 1
    ;


  BEGIN

    OPEN c_ckl_id(p_cldv_rec.id);
    FETCH c_ckl_id INTO l_ckl_id;
    CLOSE c_ckl_id;

    OPEN c_dup(l_ckl_id);
    FETCH c_dup INTO l_dummy;
    l_row_found := c_dup%FOUND;
    CLOSE c_dup;

    IF (l_row_found) THEN
      OKL_API.Set_Message(p_app_name     => G_APP_NAME,
                          p_msg_name     => 'OKL_CHK_DUP_GRP_CLISTS');

      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  RETURN l_return_status;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      l_return_status := OKL_API.G_RET_STS_ERROR;
      RETURN l_return_status;
    WHEN OTHERS THEN
      l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR ;
      OKL_API.Set_Message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_UNEXPECTED_ERROR,
                          p_token1        => G_SQLCODE_TOKEN,
                          p_token1_value  => SQLCODE,
                          p_token2        => G_SQLERRM_TOKEN,
                          p_token2_value  => SQLERRM);
      RETURN l_return_status;
  END;
  --------------------------------------------------------------------------
  ----- Validate MANDATORY FLAG
  --------------------------------------------------------------------------
  FUNCTION validate_MANDATORY_FLAG(
    p_cldv_rec     cldv_rec_type
    ,p_mode        VARCHAR2
  ) RETURN VARCHAR2
  IS
    l_return_status   VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_dummy  number;

    l_row_not_found boolean := false;

  CURSOR c_lookup (p_lookup_code VARCHAR2)
    IS
    SELECT 1
      FROM fnd_lookups lok
     WHERE lok.lookup_type = 'OKL_YES_NO'
     AND lok.lookup_code = p_lookup_code
    ;

  BEGIN

  -- FK check
  -- check only if object exists
  IF (p_cldv_rec.MANDATORY_FLAG IS NOT NULL AND
      p_cldv_rec.MANDATORY_FLAG <> OKL_API.G_MISS_CHAR)
  THEN

    OPEN c_lookup(p_cldv_rec.MANDATORY_FLAG);
    FETCH c_lookup INTO l_dummy;
    l_row_not_found := c_lookup%NOTFOUND;
    CLOSE c_lookup;

    IF (l_row_not_found) THEN
      OKL_API.Set_Message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_INVALID_VALUE,
                          p_token1       => G_COL_NAME_TOKEN,
                          p_token1_value => 'OKL_CHECKLIST_DETAILS.MANDATORY_FLAG');

      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
  END IF;

  RETURN l_return_status;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      l_return_status := OKL_API.G_RET_STS_ERROR;
      RETURN l_return_status;
    WHEN OTHERS THEN
      l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR ;
      OKL_API.Set_Message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_UNEXPECTED_ERROR,
                          p_token1        => G_SQLCODE_TOKEN,
                          p_token1_value  => SQLCODE,
                          p_token2        => G_SQLERRM_TOKEN,
                          p_token2_value  => SQLERRM);
      RETURN l_return_status;
  END;
  --------------------------------------------------------------------------
  ----- Validate USER_COMPLETE_FLAG
  --------------------------------------------------------------------------
  FUNCTION validate_COMPLETE_FLAG(
    p_cldv_rec     cldv_rec_type
    ,p_mode        VARCHAR2
  ) RETURN VARCHAR2
  IS
    l_return_status   VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_dummy  number;

    l_row_not_found boolean := false;

  CURSOR c_lookup (p_lookup_code VARCHAR2)
    IS
    SELECT 1
      FROM fnd_lookups lok
     WHERE lok.lookup_type = 'OKL_YES_NO'
     AND lok.lookup_code = p_lookup_code
    ;

  BEGIN

  -- FK check
  -- check only if object exists
  IF (p_cldv_rec.USER_COMPLETE_FLAG IS NOT NULL AND
      p_cldv_rec.USER_COMPLETE_FLAG <> OKL_API.G_MISS_CHAR)
  THEN

    OPEN c_lookup(p_cldv_rec.USER_COMPLETE_FLAG);
    FETCH c_lookup INTO l_dummy;
    l_row_not_found := c_lookup%NOTFOUND;
    CLOSE c_lookup;

    IF (l_row_not_found) THEN
      OKL_API.Set_Message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_INVALID_VALUE,
                          p_token1       => G_COL_NAME_TOKEN,
                          p_token1_value => 'OKL_CHECKLIST_DETAILS.USER_COMPLETE_FLAG');

      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
  END IF;


  RETURN l_return_status;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      l_return_status := OKL_API.G_RET_STS_ERROR;
      RETURN l_return_status;
    WHEN OTHERS THEN
      l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR ;
      OKL_API.Set_Message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_UNEXPECTED_ERROR,
                          p_token1        => G_SQLCODE_TOKEN,
                          p_token1_value  => SQLCODE,
                          p_token2        => G_SQLERRM_TOKEN,
                          p_token2_value  => SQLERRM);
      RETURN l_return_status;
  END;
  --------------------------------------------------------------------------
  ----- Validate FUNCTION_VALIDATE_RSTS
  --------------------------------------------------------------------------
  FUNCTION validate_FUN_VALIDATE_RSTS(
    p_cldv_rec     cldv_rec_type
    ,p_mode        VARCHAR2
  ) RETURN VARCHAR2
  IS
    l_return_status   VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_dummy  number;

    l_row_not_found boolean := false;

  CURSOR c_lookup (p_lookup_code VARCHAR2)
    IS
    SELECT 1
      FROM fnd_lookups lok
     WHERE lok.lookup_type = 'OKL_FUN_VALIDATE_RSTS'
     AND lok.lookup_code = p_lookup_code
    ;

  BEGIN

  -- FK check
  -- check only if object exists
  IF (p_cldv_rec.FUNCTION_VALIDATE_RSTS IS NOT NULL AND
      p_cldv_rec.FUNCTION_VALIDATE_RSTS <> OKL_API.G_MISS_CHAR)
  THEN

    OPEN c_lookup(p_cldv_rec.FUNCTION_VALIDATE_RSTS);
    FETCH c_lookup INTO l_dummy;
    l_row_not_found := c_lookup%NOTFOUND;
    CLOSE c_lookup;

    IF (l_row_not_found) THEN
      OKL_API.Set_Message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_INVALID_VALUE,
                          p_token1       => G_COL_NAME_TOKEN,
                          p_token1_value => 'OKL_CHECKLIST_DETAILS.FUNCTION_VALIDATE_RSTS');

      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
  END IF;

  RETURN l_return_status;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      l_return_status := OKL_API.G_RET_STS_ERROR;
      RETURN l_return_status;
    WHEN OTHERS THEN
      l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR ;
      OKL_API.Set_Message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_UNEXPECTED_ERROR,
                          p_token1        => G_SQLCODE_TOKEN,
                          p_token1_value  => SQLCODE,
                          p_token2        => G_SQLERRM_TOKEN,
                          p_token2_value  => SQLERRM);
      RETURN l_return_status;
  END;
  --------------------------------------------------------------------------
  ----- Validate FUNCTION_ID
  --------------------------------------------------------------------------
  FUNCTION validate_FUNCTION_ID(
    p_cldv_rec     cldv_rec_type
    ,p_mode        VARCHAR2
  ) RETURN VARCHAR2
  IS
    l_return_status   VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_dummy  number;

    l_row_not_found boolean := false;

  CURSOR c_fun (p_id number)
    IS
    SELECT 1
      FROM OKL_DATA_SRC_FNCTNS_V fun
     WHERE fun.id = p_id
    ;

  BEGIN

  -- FK check
  -- check only if object exists
  IF (p_cldv_rec.FUNCTION_ID IS NOT NULL AND
      p_cldv_rec.FUNCTION_ID <> OKL_API.G_MISS_NUM)
  THEN

    OPEN c_fun(p_cldv_rec.FUNCTION_ID);
    FETCH c_fun INTO l_dummy;
    l_row_not_found := c_fun%NOTFOUND;
    CLOSE c_fun;

    IF (l_row_not_found) THEN
      OKL_API.Set_Message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_INVALID_VALUE,
                          p_token1       => G_COL_NAME_TOKEN,
                          p_token1_value => 'OKL_CHECKLIST_DETAILS.FUNCTION_ID');

      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
  END IF;

  RETURN l_return_status;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      l_return_status := OKL_API.G_RET_STS_ERROR;
      RETURN l_return_status;
    WHEN OTHERS THEN
      l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR ;
      OKL_API.Set_Message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_UNEXPECTED_ERROR,
                          p_token1        => G_SQLCODE_TOKEN,
                          p_token1_value  => SQLCODE,
                          p_token2        => G_SQLERRM_TOKEN,
                          p_token2_value  => SQLERRM);
      RETURN l_return_status;
  END;
  --------------------------------------------------------------------------
  ----- Validate Checklist purpose
  --------------------------------------------------------------------------
  FUNCTION validate_purpose_code(
    p_cldv_rec     cldv_rec_type
    ,p_mode        VARCHAR2
  ) RETURN VARCHAR2
  IS
    l_return_status   VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_count  number := 0;
    l_row_found boolean := false;
    l_dummy number;

  CURSOR c_grp_clist (p_cld_id okl_checklist_details.id%type)
    IS
    SELECT 1
      FROM okl_checklists clh,
           okl_checklist_details cld
    WHERE clh.id = cld.ckl_id
     AND  cld.id = p_cld_id
     AND  clh.CHECKLIST_PURPOSE_CODE = 'CHECKLIST_TEMPLATE_GROUP'
    ;

  BEGIN

    OPEN c_grp_clist(p_cldv_rec.id);
    FETCH c_grp_clist INTO l_dummy;
    l_row_found := c_grp_clist%FOUND;
    CLOSE c_grp_clist;

    IF (l_row_found) THEN
      OKL_API.Set_Message(p_app_name     => G_APP_NAME,
                          p_msg_name     => 'OKL_CHK_GRP_CLIST_ITEMS');

      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  RETURN l_return_status;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      l_return_status := OKL_API.G_RET_STS_ERROR;
      RETURN l_return_status;
    WHEN OTHERS THEN
      l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR ;
      OKL_API.Set_Message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_UNEXPECTED_ERROR,
                          p_token1        => G_SQLCODE_TOKEN,
                          p_token1_value  => SQLCODE,
                          p_token2        => G_SQLERRM_TOKEN,
                          p_token2_value  => SQLERRM);
      RETURN l_return_status;
  END;
  --------------------------------------------------------------------------
  ----- Validate inst Checklist Type
  --------------------------------------------------------------------------
  FUNCTION validate_inst_clh_type(
    p_cldv_rec     cldv_rec_type
    ,p_mode        VARCHAR2
  ) RETURN VARCHAR2
  IS
    l_return_status   VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_dummy  number;
    l_purpose okl_checklists.checklist_purpose_code%type;

    l_row_not_found boolean := false;

  CURSOR c_type (p_checklist_type VARCHAR2)
    IS
    SELECT 1
      FROM fnd_lookups lok
     WHERE lok.lookup_type = G_CHECKLIST_TYPE_LOOKUP_TYPE
     AND lok.lookup_code = p_checklist_type
    ;

  CURSOR c_purpose (p_cld_id number)
    IS
    SELECT clh.checklist_purpose_code
      FROM okl_checklists clh,
           okl_checklist_details cld
    WHERE clh.id = cld.ckl_id
    AND cld.id = p_cld_id
    ;

  BEGIN

  OPEN c_purpose(p_cldv_rec.id);
  FETCH c_purpose INTO l_purpose;
  CLOSE c_purpose;

  IF (p_mode = G_INSERT_MODE) THEN

    -- column is required:
    IF l_purpose = 'CHECKLIST_INSTANCE' AND
        (p_cldv_rec.inst_checklist_type IS NULL OR
         p_cldv_rec.inst_checklist_type = OKL_API.G_MISS_CHAR)
    THEN
      OKL_API.Set_Message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_REQUIRED_VALUE,
                          p_token1       => G_COL_NAME_TOKEN,
                          p_token1_value => 'Checklist Type');
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

--START| 19-Dec-2005  cklee -- Set INST_CHECKLIST_TYPE as a required column for     |
--|                       checklist instance record                            |
  ELSIF (p_mode = G_UPDATE_MODE) THEN

    -- column is required:
    IF (l_purpose = 'CHECKLIST_INSTANCE' AND p_cldv_rec.inst_checklist_type IS NULL)
    THEN
      OKL_API.Set_Message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_REQUIRED_VALUE,
                          p_token1       => G_COL_NAME_TOKEN,
                          p_token1_value => 'Checklist Type');
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

--END| 19-Dec-2005  cklee -- Set INST_CHECKLIST_TYPE as a required column for     |
--|                       checklist instance record                            |
  END IF;

  -- FK check
  -- check only if checklist type exists
  IF (p_cldv_rec.inst_checklist_type IS NOT NULL AND
      p_cldv_rec.inst_checklist_type <> OKL_API.G_MISS_CHAR)
  THEN

    OPEN c_type(p_cldv_rec.inst_checklist_type);
    FETCH c_type INTO l_dummy;
    l_row_not_found := c_type%NOTFOUND;
    CLOSE c_type;

    IF (l_row_not_found) THEN
      OKL_API.Set_Message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_INVALID_VALUE,
                          p_token1       => G_COL_NAME_TOKEN,
                          p_token1_value => 'Checklist Type');

      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
  END IF;

  RETURN l_return_status;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      l_return_status := OKL_API.G_RET_STS_ERROR;
      RETURN l_return_status;
    WHEN OTHERS THEN
      l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR ;
      OKL_API.Set_Message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_UNEXPECTED_ERROR,
                          p_token1        => G_SQLCODE_TOKEN,
                          p_token1_value  => SQLCODE,
                          p_token2        => G_SQLERRM_TOKEN,
                          p_token2_value  => SQLERRM);
      RETURN l_return_status;
  END;
  --------------------------------------------------------------------------
  ----- Validate to do item code
  --------------------------------------------------------------------------
  FUNCTION validate_todo_item_code(
    p_cldv_rec     cldv_rec_type
    ,p_mode        VARCHAR2
  ) RETURN VARCHAR2
  IS
    l_return_status   VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_dummy  number;

    l_row_not_found boolean := false;

  CURSOR c_todo (p_todo_item_code okl_checklist_details.todo_item_code%type)
    IS
    SELECT 1
      FROM fnd_lookups lok
     WHERE lok.lookup_type = 'OKL_TODO_ITEMS'
     AND   lok.lookup_code = p_todo_item_code
    ;

  BEGIN

  IF (p_mode = G_INSERT_MODE) THEN

    -- column is required:
    IF (p_cldv_rec.todo_item_code IS NULL) OR
       (p_cldv_rec.todo_item_code = OKL_API.G_MISS_CHAR)
    THEN
      OKL_API.Set_Message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_REQUIRED_VALUE,
                          p_token1       => G_COL_NAME_TOKEN,
                          p_token1_value => 'Item Code');
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

-- There is no need if user doesn't want to update this column
/*  ELSIF (p_mode = G_UPDATE_MODE) THEN

    -- column is required:
    IF (p_cldv_rec.todo_item_code IS NULL)
    THEN
      OKL_API.Set_Message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_REQUIRED_VALUE,
                          p_token1       => G_COL_NAME_TOKEN,
                          p_token1_value => 'Item Code');
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
*/
  END IF;

  -- FK check
  -- check only if column exists
  IF (p_cldv_rec.todo_item_code IS NOT NULL AND
      p_cldv_rec.todo_item_code <> OKL_API.G_MISS_CHAR)
  THEN

    OPEN c_todo (p_cldv_rec.todo_item_code);
    FETCH c_todo INTO l_dummy;
    l_row_not_found := c_todo%NOTFOUND;
    CLOSE c_todo;

    IF (l_row_not_found) THEN
      OKL_API.Set_Message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_INVALID_VALUE,
                          p_token1       => G_COL_NAME_TOKEN,
                          p_token1_value => 'Item Code');

      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  END IF;

  RETURN l_return_status;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      l_return_status := OKL_API.G_RET_STS_ERROR;
      RETURN l_return_status;
    WHEN OTHERS THEN
      l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR ;
      OKL_API.Set_Message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_UNEXPECTED_ERROR,
                          p_token1        => G_SQLCODE_TOKEN,
                          p_token1_value  => SQLCODE,
                          p_token2        => G_SQLERRM_TOKEN,
                          p_token2_value  => SQLERRM);
      RETURN l_return_status;
  END;
-- END: Apr 25, 2005 cklee: Modification for okl.h lease app enhancement
/*
  --------------------------------------------------------------------------
  ----- Validate to do item code
  --------------------------------------------------------------------------
  FUNCTION validate_todo_item_code(
    p_cldv_rec     cldv_rec_type
    ,p_mode        VARCHAR2
  ) RETURN VARCHAR2
  IS
    l_return_status   VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_dummy  number;
    l_todo_start_date date;
    l_todo_end_date date;
    l_clh_start_date date;
    l_clh_end_date date;

    l_row_not_found boolean := false;

  CURSOR c_todo (p_todo_item_code okl_checklist_details.todo_item_code%type,
                 p_ckl_id okl_checklists.id%type)
    IS
    SELECT lok.START_DATE_ACTIVE,
           lok.END_DATE_ACTIVE,
           clh.START_DATE,
           clh.END_DATE
      FROM fnd_lookups lok,
           okl_checklists clh
-- START: Apr 25, 2005 cklee: Modification for okl.h lease app enhancement
--     WHERE  decode(clh.checklist_type, 'CREDITLINE', 'OKL_TODO_CREDIT_CHKLST'
--                                    , 'FUNDING_REQUEST', 'OKL_TODO_FUNDING_CHKLST')
--               = lok.lookup_type
-- END: Apr 25, 2005 cklee: Modification for okl.h lease app enhancement
     WHERE lok.lookup_type = 'OKL_TODO_ITEMS'
     AND   lok.lookup_code = p_todo_item_code
     AND   clh.id = p_ckl_id
    ;

  BEGIN

  IF (p_mode = G_INSERT_MODE) THEN

    -- column is required:
    IF (p_cldv_rec.todo_item_code IS NULL) OR
       (p_cldv_rec.todo_item_code = OKL_API.G_MISS_CHAR)
    THEN
      OKL_API.Set_Message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_REQUIRED_VALUE,
                          p_token1       => G_COL_NAME_TOKEN,
                          p_token1_value => 'Item Code');
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  ELSIF (p_mode = G_UPDATE_MODE) THEN

    -- column is required:
    IF (p_cldv_rec.todo_item_code IS NULL)
    THEN
      OKL_API.Set_Message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_REQUIRED_VALUE,
                          p_token1       => G_COL_NAME_TOKEN,
                          p_token1_value => 'Item Code');
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  END IF;

  -- FK check
  -- check only if column exists
  IF (p_cldv_rec.todo_item_code IS NOT NULL AND
      p_cldv_rec.todo_item_code <> OKL_API.G_MISS_CHAR)
  THEN

    OPEN c_todo (p_cldv_rec.todo_item_code, p_cldv_rec.ckl_id);
    FETCH c_todo INTO l_todo_start_date,
                      l_todo_end_date, -- can be null
                      l_clh_start_date, -- can be null
                      l_clh_end_date;
    l_row_not_found := c_todo%NOTFOUND;
    CLOSE c_todo;

    IF (l_row_not_found) THEN
      OKL_API.Set_Message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_INVALID_VALUE,
                          p_token1       => G_COL_NAME_TOKEN,
                          p_token1_value => 'Item Code');

      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

-- check vs header's start date, and end date
-- todo start date NOT between checklist start, and end date
-- 1. todo start date >= checklist's end date
-- 2. todo start date <= checklist's start date

-- 4. todo end date >= checklist start date

  END IF;

  RETURN l_return_status;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      l_return_status := OKL_API.G_RET_STS_ERROR;
      RETURN l_return_status;
    WHEN OTHERS THEN
      l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR ;
      OKL_API.Set_Message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_UNEXPECTED_ERROR,
                          p_token1        => G_SQLCODE_TOKEN,
                          p_token1_value  => SQLCODE,
                          p_token2        => G_SQLERRM_TOKEN,
                          p_token2_value  => SQLERRM);
      RETURN l_return_status;
  END;
*/
--START:| 23-Feb-2006  cklee -- Fixed bug#5018561                                    |
  --------------------------------------------------------------------------
  ----- Validate item code effective from vs header's effective dates
  --------------------------------------------------------------------------
  FUNCTION validate_item_effective_from(
    p_cldv_rec     cldv_rec_type
    ,p_mode        VARCHAR2
  ) RETURN VARCHAR2
  IS
    l_return_status   VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_dummy  number;

    l_row_found boolean := false;
    l_checklist_number okl_checklists.checklist_number%type;
    l_todo_item_code okl_checklist_details.todo_item_code%type;

-- Check if todo item effective from date within the checklist header's effective dates range
  CURSOR c_todo_tmp_chk (p_cld_id okl_checklist_details.id%type)
    IS
    SELECT clh.checklist_number, cld.todo_item_code
      FROM fnd_lookups lok,
           okl_checklist_details cld,
           okl_checklists clh
     WHERE lok.lookup_type = 'OKL_TODO_ITEMS'
     AND   cld.id          = p_cld_id
     AND   lok.lookup_code = cld.todo_item_code
     AND   cld.ckl_id      = clh.id
     AND   clh.checklist_purpose_code in ('CHECKLIST_TEMPLATE', 'CHECKLIST_INSTANCE')
     AND   NOT (TRUNC(NVL(lok.START_DATE_ACTIVE, SYSDATE))
                BETWEEN TRUNC(NVL(clh.START_DATE, lok.START_DATE_ACTIVE)) AND
                   NVL(TRUNC(clh.END_DATE),lok.START_DATE_ACTIVE))
    ;

-- Check if todo item effective from date within the checklist group header's effective dates range
  CURSOR c_todo_grp_chk (p_cld_id okl_checklist_details.id%type)
    IS
    SELECT clh_grp.checklist_number, cld.todo_item_code
      FROM fnd_lookups lok,
           okl_checklist_details cld,
           okl_checklists clh,
           okl_checklists clh_grp
     WHERE lok.lookup_type = 'OKL_TODO_ITEMS'
     AND   cld.id          = p_cld_id
     AND   lok.lookup_code = cld.todo_item_code
     AND   cld.ckl_id      = clh.id
     AND   clh.ckl_id      = clh_grp.id
     AND   clh_grp.checklist_purpose_code = 'CHECKLIST_TEMPLATE_GROUP'
     AND   NOT (TRUNC(NVL(lok.START_DATE_ACTIVE, SYSDATE))
                BETWEEN TRUNC(NVL(clh_grp.START_DATE, lok.START_DATE_ACTIVE)) AND
                   NVL(TRUNC(clh_grp.END_DATE),lok.START_DATE_ACTIVE))
    ;

  BEGIN

------------------------------------------------------------------------------
-- Check if todo itme effective from date within the checklist header's
-- effective dates range
------------------------------------------------------------------------------

    OPEN c_todo_tmp_chk  (p_cldv_rec.id);
    FETCH c_todo_tmp_chk  INTO l_checklist_number, l_todo_item_code;
    l_row_found := c_todo_tmp_chk%FOUND;
    CLOSE c_todo_tmp_chk ;

    IF (l_row_found) THEN
      OKL_API.Set_Message(p_app_name     => G_APP_NAME,
                          p_msg_name     => 'OKL_CHECKLIST_ITEM_DATE_CHECK',
                          p_token1       => 'ITEM',
                          p_token1_value => l_todo_item_code,
                          p_token2       => 'NAME',
                          p_token2_value => l_checklist_number);

      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

------------------------------------------------------------------------------
-- Check if todo itme effective from date within the checklist header's group
-- effective dates range
------------------------------------------------------------------------------

    OPEN c_todo_grp_chk (p_cldv_rec.id);
    FETCH c_todo_grp_chk  INTO l_checklist_number, l_todo_item_code;
    l_row_found := c_todo_grp_chk%FOUND;
    CLOSE c_todo_grp_chk ;

    IF (l_row_found) THEN
      OKL_API.Set_Message(p_app_name     => G_APP_NAME,
                          p_msg_name     => 'OKL_CHECKLIST_ITEM_DATE_CHECK2',
                          p_token1       => 'ITEM',
                          p_token1_value => l_todo_item_code,
                          p_token2       => 'NAME',
                          p_token2_value => l_checklist_number);

      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  RETURN l_return_status;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      l_return_status := OKL_API.G_RET_STS_ERROR;
      RETURN l_return_status;
    WHEN OTHERS THEN
      l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR ;
      OKL_API.Set_Message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_UNEXPECTED_ERROR,
                          p_token1        => G_SQLCODE_TOKEN,
                          p_token1_value  => SQLCODE,
                          p_token2        => G_SQLERRM_TOKEN,
                          p_token2_value  => SQLERRM);
      RETURN l_return_status;
  END;
--END:| 23-Feb-2006  cklee -- Fixed bug#5018561                                    |

--START:| 23-Feb-2006  cklee -- Fixed bug#5018561                                    |
  --------------------------------------------------------------------------
  ----- Validate Effective To vs item's date
  --------------------------------------------------------------------------
  FUNCTION validate_dates_w_item(
    p_clhv_rec     clhv_rec_type
    ,p_mode        VARCHAR2
  ) RETURN VARCHAR2
  IS
    l_return_status   VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_dummy  number;

    l_cldv_rec     cldv_rec_type;

-- existing checklist items for a checcklist or a grp checklist
  cursor c_item_date_range_chk (p_clh_id number) is
    select cld.id, cld.todo_item_code
    from   okl_checklist_details cld,
           okl_checklists clh
    where  cld.ckl_id = clh.id
    and    cld.ckl_id = p_clh_id
    and    clh.checklist_purpose_code in ('CHECKLIST_TEMPLATE', 'CHECKLIST_INSTANCE')
    union
    select cld.id, cld.todo_item_code
    from   okl_checklist_details cld,
           okl_checklists clh,
           okl_checklists clh_grp
    where  cld.ckl_id = clh.id
    and    clh.ckl_id = clh_grp.id
    and    clh_grp.id = p_clh_id
    and    clh_grp.checklist_purpose_code = 'CHECKLIST_TEMPLATE_GROUP'
    ;
  BEGIN

    FOR r_this_row IN c_item_date_range_chk (p_clhv_rec.id) LOOP

      l_cldv_rec.id := r_this_row.id;
      l_return_status := validate_item_effective_from(l_cldv_rec, G_UPDATE_MODE);
      --- Store the highest degree of error
      IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
        RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;
    END LOOP;

  RETURN l_return_status;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      l_return_status := OKL_API.G_RET_STS_ERROR;
      RETURN l_return_status;
    WHEN OTHERS THEN
      l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR ;
      OKL_API.Set_Message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_UNEXPECTED_ERROR,
                          p_token1        => G_SQLCODE_TOKEN,
                          p_token1_value  => SQLCODE,
                          p_token2        => G_SQLERRM_TOKEN,
                          p_token2_value  => SQLERRM);
      RETURN l_return_status;
  END;
--END:| 23-Feb-2006  cklee -- Fixed bug#5018561                                    |

  --------------------------------------------------------------------------
  ----- Validate Checklist to do item code uniqueness :after image
  --------------------------------------------------------------------------
  FUNCTION validate_unq_todo_item(
    p_cldv_rec     cldv_rec_type
    ,p_mode        VARCHAR2
  ) RETURN VARCHAR2
  IS
    l_return_status   VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_count  number := 0;
    l_row_found boolean := false;
    l_dummy number;

  CURSOR c_unq (p_ckl_id okl_checklists.id%type)
    IS
    SELECT 1
      FROM okl_checklist_details cld
    WHERE cld.ckl_id = p_ckl_id
-- START: 06-Jan-2006  cklee -- Fixed for instance checklist item duplication check  |
--      GROUP BY cld.todo_item_code, cld.function_id
      GROUP BY cld.todo_item_code, cld.function_id, cld.INST_CHECKLIST_TYPE
-- END: 06-Jan-2006  cklee -- Fixed for instance checklist item duplication check  |
      HAVING count(1) > 1
    ;

  BEGIN

    OPEN c_unq(p_cldv_rec.ckl_id);
    FETCH c_unq INTO l_dummy;
    l_row_found := c_unq%FOUND;
    CLOSE c_unq;

    IF (l_row_found) THEN
      OKL_API.Set_Message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_NOT_UNIQUE,
                          p_token1       => G_COL_NAME_TOKEN,
-- START: 06-Jan-2006  cklee -- Fixed for instance checklist item duplication check  |
--                          p_token1_value => 'Item Code and Function');
                          p_token1_value => 'Item Code, Function, and Type');
-- START: 06-Jan-2006  cklee -- Fixed for instance checklist item duplication check  |

      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  RETURN l_return_status;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      l_return_status := OKL_API.G_RET_STS_ERROR;
      RETURN l_return_status;
    WHEN OTHERS THEN
      l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR ;
      OKL_API.Set_Message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_UNEXPECTED_ERROR,
                          p_token1        => G_SQLCODE_TOKEN,
                          p_token1_value  => SQLCODE,
                          p_token2        => G_SQLERRM_TOKEN,
                          p_token2_value  => SQLERRM);
      RETURN l_return_status;
  END;
  --PAGARG: Bug 4872271: Added procedure to validate value of APPEAL_FLAG
  --------------------------------------------------------------------------
  -- Validate APPEAL FLAG
  --------------------------------------------------------------------------
  FUNCTION validate_appeal_flag(
    p_cldv_rec     cldv_rec_type
   ,p_mode        VARCHAR2
  ) RETURN VARCHAR2
  IS
    l_return_status VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_dummy         NUMBER;

    l_row_not_found BOOLEAN := FALSE;

    CURSOR c_lookup(p_lookup_code VARCHAR2)
    IS
      SELECT 1
      FROM fnd_lookups lok
      WHERE lok.lookup_type = 'OKL_YES_NO'
        AND lok.lookup_code = p_lookup_code;
  BEGIN
    -- check only if object exists
    IF (p_cldv_rec.APPEAL_FLAG IS NOT NULL AND
        p_cldv_rec.APPEAL_FLAG <> OKL_API.G_MISS_CHAR)
    THEN
      OPEN c_lookup(p_cldv_rec.APPEAL_FLAG);
      FETCH c_lookup INTO l_dummy;
      l_row_not_found := c_lookup%NOTFOUND;
      CLOSE c_lookup;
      IF (l_row_not_found)
      THEN
        OKL_API.Set_Message(p_app_name     => G_APP_NAME,
                            p_msg_name     => G_INVALID_VALUE,
                            p_token1       => G_COL_NAME_TOKEN,
                            p_token1_value => 'OKL_CHECKLIST_DETAILS.APPEAL_FLAG');
        RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;
    END IF;
    RETURN l_return_status;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      l_return_status := OKL_API.G_RET_STS_ERROR;
      RETURN l_return_status;
    WHEN OTHERS THEN
      l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR ;
      OKL_API.Set_Message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_UNEXPECTED_ERROR,
                          p_token1        => G_SQLCODE_TOKEN,
                          p_token1_value  => SQLCODE,
                          p_token2        => G_SQLERRM_TOKEN,
                          p_token2_value  => SQLERRM);
      RETURN l_return_status;
  END validate_appeal_flag;

  --------------------------------------------------------------------------
  FUNCTION validate_header_attributes(
    p_clhv_rec     clhv_rec_type
    ,p_mode        VARCHAR2
  ) RETURN VARCHAR2
  IS
    l_return_status   VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    x_return_status   VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;

  BEGIN

    -- Do formal attribute validation:

    l_return_status := validate_clh_number(p_clhv_rec, p_mode);
    --- Store the highest degree of error
    IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        x_return_status := l_return_status;
      END IF;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    l_return_status := validate_clh_type(p_clhv_rec, p_mode);
    --- Store the highest degree of error
    IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        x_return_status := l_return_status;
      END IF;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    l_return_status := validate_short_desc(p_clhv_rec, p_mode);
    --- Store the highest degree of error
    IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        x_return_status := l_return_status;
      END IF;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    l_return_status := validate_description(p_clhv_rec, p_mode);
    --- Store the highest degree of error
    IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        x_return_status := l_return_status;
      END IF;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    l_return_status := validate_effective_to(p_clhv_rec, p_mode);
    --- Store the highest degree of error
    IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        x_return_status := l_return_status;
      END IF;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
-- START: Apr 25, 2005 cklee: Modification for okl.h lease app enhancement

    l_return_status := validate_status_code(p_clhv_rec, p_mode);
    --- Store the highest degree of error
    IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        x_return_status := l_return_status;
      END IF;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    l_return_status := validate_purpose_code(p_clhv_rec, p_mode);
    --- Store the highest degree of error
    IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        x_return_status := l_return_status;
      END IF;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    l_return_status := validate_obj_ID(p_clhv_rec, p_mode);
    --- Store the highest degree of error
    IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        x_return_status := l_return_status;
      END IF;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    l_return_status := validate_obj_type_code(p_clhv_rec, p_mode);
    --- Store the highest degree of error
    IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        x_return_status := l_return_status;
      END IF;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    l_return_status := validate_ckl_id(p_clhv_rec, p_mode);
    --- Store the highest degree of error
    IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        x_return_status := l_return_status;
      END IF;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
-- END: Apr 25, 2005 cklee: Modification for okl.h lease app enhancement

    RETURN x_return_status;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      RETURN x_return_status;
    WHEN OTHERS THEN
      l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR ;
      OKL_API.Set_Message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_UNEXPECTED_ERROR,
                          p_token1        => G_SQLCODE_TOKEN,
                          p_token1_value  => SQLCODE,
                          p_token2        => G_SQLERRM_TOKEN,
                          p_token2_value  => SQLERRM);
      RETURN l_return_status;
  END validate_header_attributes;
-----------------------------------------------------------------------------
--- validate attrs after image-----------------------------------------------
-----------------------------------------------------------------------------
  FUNCTION validate_hdr_attr_aftimg(
    p_clhv_rec     clhv_rec_type
    ,p_mode        VARCHAR2
  ) RETURN VARCHAR2
  IS
    l_return_status   VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    x_return_status   VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;

  BEGIN

    -- Do formal attribute validation:
    l_return_status := validate_unq_clh_number(p_clhv_rec, p_mode);
    --- Store the highest degree of error
    IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        x_return_status := l_return_status;
      END IF;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    l_return_status := validate_effective_date(p_clhv_rec, p_mode);
    --- Store the highest degree of error
    IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        x_return_status := l_return_status;
      END IF;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

-- START: Apr 25, 2005 cklee: Modification for okl.h lease app enhancement
    l_return_status := validate_dates_overlap(p_clhv_rec, p_mode);
    --- Store the highest degree of error
    IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        x_return_status := l_return_status;
      END IF;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
-- END: Apr 25, 2005 cklee: Modification for okl.h lease app enhancement


--START:| 23-Feb-2006  cklee -- Fixed bug#5018561                                    |
    l_return_status := validate_dates_w_item(p_clhv_rec, p_mode);
    --- Store the highest degree of error
    IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        x_return_status := l_return_status;
      END IF;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
--END:| 23-Feb-2006  cklee -- Fixed bug#5018561                                    |

    RETURN x_return_status;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      RETURN x_return_status;
    WHEN OTHERS THEN
      l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR ;
      OKL_API.Set_Message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_UNEXPECTED_ERROR,
                          p_token1        => G_SQLCODE_TOKEN,
                          p_token1_value  => SQLCODE,
                          p_token2        => G_SQLERRM_TOKEN,
                          p_token2_value  => SQLERRM);
      RETURN l_return_status;
  END validate_hdr_attr_aftimg;

-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------

  FUNCTION validate_line_attributes(
    p_cldv_rec     cldv_rec_type
    ,p_mode        VARCHAR2
  ) RETURN VARCHAR2
  IS
    l_return_status   VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    x_return_status   VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;

  BEGIN

    -- Do formal attribute validation:
    l_return_status := validate_todo_item_code(p_cldv_rec, p_mode);
    --- Store the highest degree of error
    IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        x_return_status := l_return_status;
      END IF;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

-- START: Apr 25, 2005 cklee: Modification for okl.h lease app enhancement
    l_return_status := validate_MANDATORY_FLAG(p_cldv_rec, p_mode);
    --- Store the highest degree of error
    IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        x_return_status := l_return_status;
      END IF;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    l_return_status := validate_COMPLETE_FLAG(p_cldv_rec, p_mode);
    --- Store the highest degree of error
    IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        x_return_status := l_return_status;
      END IF;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    l_return_status := validate_FUN_VALIDATE_RSTS(p_cldv_rec, p_mode);
    --- Store the highest degree of error
    IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        x_return_status := l_return_status;
      END IF;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    l_return_status := validate_FUNCTION_ID(p_cldv_rec, p_mode);
    --- Store the highest degree of error
    IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        x_return_status := l_return_status;
      END IF;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    l_return_status := validate_inst_clh_type(p_cldv_rec, p_mode);
    --- Store the highest degree of error
    IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        x_return_status := l_return_status;
      END IF;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
-- END: Apr 25, 2005 cklee: Modification for okl.h lease app enhancement
    --PAGARG: Bug 4872271: call procedure to validate value of APPEAL_FLAG
    l_return_status := validate_APPEAL_FLAG(p_cldv_rec, p_mode);
    -- Store the highest degree of error
    IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        x_return_status := l_return_status;
      END IF;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    RETURN x_return_status;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      RETURN x_return_status;
    WHEN OTHERS THEN
      l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR ;
      OKL_API.Set_Message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_UNEXPECTED_ERROR,
                          p_token1        => G_SQLCODE_TOKEN,
                          p_token1_value  => SQLCODE,
                          p_token2        => G_SQLERRM_TOKEN,
                          p_token2_value  => SQLERRM);
      RETURN l_return_status;
  END validate_line_attributes;

-----------------------------------------------------------------------------
--- validate attrs after image-----------------------------------------------
-----------------------------------------------------------------------------

  FUNCTION validate_line_attr_aftimg(
    p_cldv_rec     cldv_rec_type
    ,p_mode        VARCHAR2
  ) RETURN VARCHAR2
  IS
    l_return_status   VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    x_return_status   VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;

  BEGIN

    -- Do formal attribute validation:
    l_return_status := validate_unq_todo_item(p_cldv_rec, p_mode);
    --- Store the highest degree of error
    IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        x_return_status := l_return_status;
      END IF;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

-- START: Apr 25, 2005 cklee: Modification for okl.h lease app enhancement
    l_return_status := validate_purpose_code(p_cldv_rec, p_mode);
    --- Store the highest degree of error
    IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        x_return_status := l_return_status;
      END IF;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    l_return_status := validate_duplicated_keys(p_cldv_rec, p_mode);
    --- Store the highest degree of error
    IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        x_return_status := l_return_status;
      END IF;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
-- END: Apr 25, 2005 cklee: Modification for okl.h lease app enhancement

--START:| 23-Feb-2006  cklee -- Fixed bug#5018561                                    |
    l_return_status := validate_item_effective_from(p_cldv_rec, p_mode);
    --- Store the highest degree of error
    IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        x_return_status := l_return_status;
      END IF;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
--END:| 23-Feb-2006  cklee -- Fixed bug#5018561                                    |

    RETURN x_return_status;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      RETURN x_return_status;
    WHEN OTHERS THEN
      l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR ;
      OKL_API.Set_Message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_UNEXPECTED_ERROR,
                          p_token1        => G_SQLCODE_TOKEN,
                          p_token1_value  => SQLCODE,
                          p_token2        => G_SQLERRM_TOKEN,
                          p_token2_value  => SQLERRM);
      RETURN l_return_status;
  END validate_line_attr_aftimg;

----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : create_checklist_hdr
-- Description     : wrapper api for create checklist template header
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
 PROCEDURE create_checklist_hdr(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_clhv_rec                     IN  clhv_rec_type
   ,x_clhv_rec                     OUT NOCOPY clhv_rec_type
 )
is
  l_api_name         CONSTANT VARCHAR2(30) := 'create_checklist_hdr';
  l_api_version      CONSTANT NUMBER       := 1.0;
  i                  NUMBER;
  l_return_status    VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  lp_clhv_rec        clhv_rec_type := p_clhv_rec;
--  lx_clhv_rec        clhv_rec_type := x_clhv_rec;

begin
  -- Set API savepoint
  SAVEPOINT create_checklist_hdr;

  -- Check for call compatibility
  IF (NOT FND_API.Compatible_API_Call (l_api_version,
                                	   p_api_version,
                                	   l_api_name,
                                	   G_PKG_NAME ))
  THEN
    RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if requested
  IF (FND_API.to_Boolean(p_init_msg_list)) THEN
      FND_MSG_PUB.initialize;
	END IF;

  -- Initialize API status to success
  x_return_status := OKL_API.G_RET_STS_SUCCESS;


/*** Begin API body ****************************************************/

-- start: cklee: 4/26/2005 set default
    IF lp_clhv_rec.STATUS_CODE IS NULL or lp_clhv_rec.STATUS_CODE = OKL_API.G_MISS_CHAR THEN
      lp_clhv_rec.STATUS_CODE := G_NEW_STS_CODE;
    END IF;
    IF lp_clhv_rec.CHECKLIST_PURPOSE_CODE in ('CHECKLIST_TEMPLATE_GROUP', 'CHECKLIST_INSTANCE') THEN
      lp_clhv_rec.CHECKLIST_TYPE := 'NONE';
    END IF;
-- end: cklee: 4/26/2005 set default

    l_return_status := validate_header_attributes(lp_clhv_rec, G_INSERT_MODE);
    --- Store the highest degree of error
    IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        x_return_status := l_return_status;
      END IF;
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;

      okl_clh_pvt.insert_row(
          p_api_version    => p_api_version,
          p_init_msg_list  => p_init_msg_list,
          x_return_status  => x_return_status,
          x_msg_count      => x_msg_count,
          x_msg_data       => x_msg_data,
          p_clhv_rec       => lp_clhv_rec,
          x_clhv_rec       => x_clhv_rec);

      If (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
        raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      Elsif (x_return_status = OKC_API.G_RET_STS_ERROR) then
        raise OKC_API.G_EXCEPTION_ERROR;
      End If;

    lp_clhv_rec.id := x_clhv_rec.id;

    l_return_status := validate_hdr_attr_aftimg(lp_clhv_rec, G_INSERT_MODE);
    --- Store the highest degree of error
    IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        x_return_status := l_return_status;
      END IF;
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;

/*** End API body ******************************************************/

  -- Get message count and if count is 1, get message info
	FND_MSG_PUB.Count_And_Get
    (p_count          =>      x_msg_count,
     p_data           =>      x_msg_data);

EXCEPTION
  WHEN OKL_API.G_EXCEPTION_ERROR THEN
    ROLLBACK TO create_checklist_hdr;
    x_return_status := OKL_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    ROLLBACK TO create_checklist_hdr;
    x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OTHERS THEN
	ROLLBACK TO create_checklist_hdr;
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR ;
      OKL_API.Set_Message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_UNEXPECTED_ERROR,
                          p_token1        => G_SQLCODE_TOKEN,
                          p_token1_value  => SQLCODE,
                          p_token2        => G_SQLERRM_TOKEN,
                          p_token2_value  => SQLERRM);
      FND_MSG_PUB.Count_And_Get
        (p_count         =>      x_msg_count,
         p_data          =>      x_msg_data);

end create_checklist_hdr;

----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : update_checklist_hdr
-- Description     : wrapper api for update checklist template header
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
 PROCEDURE update_checklist_hdr(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_clhv_rec                     IN  clhv_rec_type
   ,x_clhv_rec                     OUT NOCOPY clhv_rec_type
 )
is
  l_api_name         CONSTANT VARCHAR2(30) := 'update_checklist_hdr';
  l_api_version      CONSTANT NUMBER       := 1.0;
  i                  NUMBER;
  l_return_status    VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  lp_clhv_rec        clhv_rec_type := p_clhv_rec;
--  lx_clhv_rec        clhv_rec_type := x_clhv_rec;

begin
  -- Set API savepoint
  SAVEPOINT update_checklist_hdr;

  -- Check for call compatibility
  IF (NOT FND_API.Compatible_API_Call (l_api_version,
                                	   p_api_version,
                                	   l_api_name,
                                	   G_PKG_NAME ))
  THEN
    RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if requested
  IF (FND_API.to_Boolean(p_init_msg_list)) THEN
      FND_MSG_PUB.initialize;
	END IF;

  -- Initialize API status to success
  x_return_status := OKL_API.G_RET_STS_SUCCESS;


/*** Begin API body ****************************************************/

    l_return_status := validate_header_attributes(lp_clhv_rec, G_UPDATE_MODE);
    --- Store the highest degree of error
    IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        x_return_status := l_return_status;
      END IF;
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;

      okl_clh_pvt.update_row(
          p_api_version    => p_api_version,
          p_init_msg_list  => p_init_msg_list,
          x_return_status  => x_return_status,
          x_msg_count      => x_msg_count,
          x_msg_data       => x_msg_data,
          p_clhv_rec       => lp_clhv_rec,
          x_clhv_rec       => x_clhv_rec);

      If (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
        raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      Elsif (x_return_status = OKC_API.G_RET_STS_ERROR) then
        raise OKC_API.G_EXCEPTION_ERROR;
      End If;

    l_return_status := validate_hdr_attr_aftimg(lp_clhv_rec, G_UPDATE_MODE);
    --- Store the highest degree of error
    IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        x_return_status := l_return_status;
      END IF;
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;


/*** End API body ******************************************************/

  -- Get message count and if count is 1, get message info
	FND_MSG_PUB.Count_And_Get
    (p_count          =>      x_msg_count,
     p_data           =>      x_msg_data);

EXCEPTION
  WHEN OKL_API.G_EXCEPTION_ERROR THEN
    ROLLBACK TO update_checklist_hdr;
    x_return_status := OKL_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    ROLLBACK TO update_checklist_hdr;
    x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OTHERS THEN
	ROLLBACK TO update_checklist_hdr;
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR ;
      OKL_API.Set_Message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_UNEXPECTED_ERROR,
                          p_token1        => G_SQLCODE_TOKEN,
                          p_token1_value  => SQLCODE,
                          p_token2        => G_SQLERRM_TOKEN,
                          p_token2_value  => SQLERRM);
      FND_MSG_PUB.Count_And_Get
        (p_count         =>      x_msg_count,
         p_data          =>      x_msg_data);

end update_checklist_hdr;

----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : delete_checklist_hdr
-- Description     : wrapper api for delete checklist template header
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
 PROCEDURE delete_checklist_hdr(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_clhv_rec                     IN  clhv_rec_type
 )
is
  l_api_name         CONSTANT VARCHAR2(30) := 'delete_checklist_hdr';
  l_api_version      CONSTANT NUMBER       := 1.0;
  i                  NUMBER;
  l_return_status    VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  lp_clhv_rec        clhv_rec_type := p_clhv_rec;
--  xp_clhv_rec        clhv_rec_type := x_clhv_rec;

begin
  -- Set API savepoint
  SAVEPOINT delete_checklist_hdr;

  -- Check for call compatibility
  IF (NOT FND_API.Compatible_API_Call (l_api_version,
                                	   p_api_version,
                                	   l_api_name,
                                	   G_PKG_NAME ))
  THEN
    RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if requested
  IF (FND_API.to_Boolean(p_init_msg_list)) THEN
      FND_MSG_PUB.initialize;
	END IF;

  -- Initialize API status to success
  x_return_status := OKL_API.G_RET_STS_SUCCESS;


/*** Begin API body ****************************************************/

      okl_clh_pvt.delete_row(
          p_api_version    => p_api_version,
          p_init_msg_list  => p_init_msg_list,
          x_return_status  => x_return_status,
          x_msg_count      => x_msg_count,
          x_msg_data       => x_msg_data,
          p_clhv_rec       => lp_clhv_rec);

      If (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
        raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      Elsif (x_return_status = OKC_API.G_RET_STS_ERROR) then
        raise OKC_API.G_EXCEPTION_ERROR;
      End If;

/*** End API body ******************************************************/

  -- Get message count and if count is 1, get message info
	FND_MSG_PUB.Count_And_Get
    (p_count          =>      x_msg_count,
     p_data           =>      x_msg_data);

EXCEPTION
  WHEN OKL_API.G_EXCEPTION_ERROR THEN
    ROLLBACK TO delete_checklist_hdr;
    x_return_status := OKL_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    ROLLBACK TO delete_checklist_hdr;
    x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OTHERS THEN
	ROLLBACK TO delete_checklist_hdr;
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR ;
      OKL_API.Set_Message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_UNEXPECTED_ERROR,
                          p_token1        => G_SQLCODE_TOKEN,
                          p_token1_value  => SQLCODE,
                          p_token2        => G_SQLERRM_TOKEN,
                          p_token2_value  => SQLERRM);
      FND_MSG_PUB.Count_And_Get
        (p_count         =>      x_msg_count,
         p_data          =>      x_msg_data);

end delete_checklist_hdr;

----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : create_checklist_dtl
-- Description     : wrapper api for create checklist template details
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
 PROCEDURE create_checklist_dtl(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_cldv_tbl                     IN  cldv_tbl_type
   ,x_cldv_tbl                     OUT NOCOPY cldv_tbl_type
 )
is
  l_api_name         CONSTANT VARCHAR2(30) := 'create_checklist_dtl';
  l_api_version      CONSTANT NUMBER       := 1.0;
  i                  NUMBER;
  l_return_status    VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  lp_cldv_tbl        cldv_tbl_type := p_cldv_tbl;
--  lx_cldv_tbl        cldv_tbl_type := x_cldv_tbl;

begin
  -- Set API savepoint
  SAVEPOINT create_checklist_dtl;

  -- Check for call compatibility
  IF (NOT FND_API.Compatible_API_Call (l_api_version,
                                	   p_api_version,
                                	   l_api_name,
                                	   G_PKG_NAME ))
  THEN
    RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if requested
  IF (FND_API.to_Boolean(p_init_msg_list)) THEN
      FND_MSG_PUB.initialize;
	END IF;

  -- Initialize API status to success
  x_return_status := OKL_API.G_RET_STS_SUCCESS;


/*** Begin API body ****************************************************/

    IF (lp_cldv_tbl.COUNT > 0) THEN
      i := lp_cldv_tbl.FIRST;
      LOOP

        l_return_status := validate_line_attributes(lp_cldv_tbl(i),G_INSERT_MODE);
        --- Store the highest degree of error
        IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
          IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
          END IF;
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        END IF;

        EXIT WHEN (i = lp_cldv_tbl.LAST);
        i := lp_cldv_tbl.NEXT(i);
      END LOOP;
    END IF;

      okl_cld_pvt.insert_row(
          p_api_version    => p_api_version,
          p_init_msg_list  => p_init_msg_list,
          x_return_status  => x_return_status,
          x_msg_count      => x_msg_count,
          x_msg_data       => x_msg_data,
          p_cldv_tbl       => lp_cldv_tbl,
          x_cldv_tbl       => x_cldv_tbl);

      If (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
        raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      Elsif (x_return_status = OKC_API.G_RET_STS_ERROR) then
        raise OKC_API.G_EXCEPTION_ERROR;
      End If;

    IF (lp_cldv_tbl.COUNT > 0) THEN
      i := lp_cldv_tbl.FIRST;
      LOOP

        lp_cldv_tbl(i).id := x_cldv_tbl(i).id;

        l_return_status := validate_line_attr_aftimg(lp_cldv_tbl(i),G_INSERT_MODE);
        --- Store the highest degree of error
        IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
          IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
          END IF;
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        END IF;

        EXIT WHEN (i = lp_cldv_tbl.LAST);
        i := lp_cldv_tbl.NEXT(i);
      END LOOP;
    END IF;

/*** End API body ******************************************************/

  -- Get message count and if count is 1, get message info
	FND_MSG_PUB.Count_And_Get
    (p_count          =>      x_msg_count,
     p_data           =>      x_msg_data);

EXCEPTION
  WHEN OKL_API.G_EXCEPTION_ERROR THEN
    ROLLBACK TO create_checklist_dtl;
    x_return_status := OKL_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    ROLLBACK TO create_checklist_dtl;
    x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OTHERS THEN
	ROLLBACK TO create_checklist_dtl;
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR ;
      OKL_API.Set_Message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_UNEXPECTED_ERROR,
                          p_token1        => G_SQLCODE_TOKEN,
                          p_token1_value  => SQLCODE,
                          p_token2        => G_SQLERRM_TOKEN,
                          p_token2_value  => SQLERRM);
      FND_MSG_PUB.Count_And_Get
        (p_count         =>      x_msg_count,
         p_data          =>      x_msg_data);

end create_checklist_dtl;

----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : update_checklist_dtl
-- Description     : wrapper api for update checklist template details
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
 PROCEDURE update_checklist_dtl(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_cldv_tbl                     IN  cldv_tbl_type
   ,x_cldv_tbl                     OUT NOCOPY cldv_tbl_type
 )
is
  l_api_name         CONSTANT VARCHAR2(30) := 'update_checklist_dtl';
  l_api_version      CONSTANT NUMBER       := 1.0;
  i                  NUMBER;
  l_return_status    VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  lp_cldv_tbl        cldv_tbl_type := p_cldv_tbl;
--  lx_cldv_tbl        cldv_tbl_type := x_cldv_tbl;

--START:| 21-Dec-2005  cklee -- Fixed bug#4880288 -- 4908242
  l_checklist_obj_id number;
cursor c_dnz_object_id (p_dtl_id number) is
  select h.CHECKLIST_OBJ_ID
  from okl_checklists h,
       okl_checklist_details d
  where h.id = d.ckl_id
  and   d.id = p_dtl_id;
--END:| 21-Dec-2005  cklee -- Fixed bug#4880288 -- 4908242

begin
  -- Set API savepoint
  SAVEPOINT update_checklist_dtl;

  -- Check for call compatibility
  IF (NOT FND_API.Compatible_API_Call (l_api_version,
                                	   p_api_version,
                                	   l_api_name,
                                	   G_PKG_NAME ))
  THEN
    RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if requested
  IF (FND_API.to_Boolean(p_init_msg_list)) THEN
      FND_MSG_PUB.initialize;
	END IF;

  -- Initialize API status to success
  x_return_status := OKL_API.G_RET_STS_SUCCESS;


/*** Begin API body ****************************************************/

    IF (lp_cldv_tbl.COUNT > 0) THEN

      i := lp_cldv_tbl.FIRST;

--START:| 21-Dec-2005  cklee -- Fixed bug#4880288 -- 4908242
      open c_dnz_object_id(lp_cldv_tbl(i).id);
      fetch c_dnz_object_id into l_checklist_obj_id;
      close c_dnz_object_id;
--END:| 21-Dec-2005  cklee -- Fixed bug#4880288 -- 4908242

      LOOP

--START:| 21-Dec-2005  cklee -- Fixed bug#4880288 -- 4908242
        -- always assign default in case the dnz_object_id is null
        IF l_checklist_obj_id IS NOT NULL THEN
          lp_cldv_tbl(i).dnz_checklist_obj_id := l_checklist_obj_id;
        END IF;
--END:| 21-Dec-2005  cklee -- Fixed bug#4880288 -- 4908242

        l_return_status := validate_line_attributes(lp_cldv_tbl(i),G_UPDATE_MODE);
        --- Store the highest degree of error
        IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
          IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
          END IF;
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        END IF;

        EXIT WHEN (i = lp_cldv_tbl.LAST);
        i := lp_cldv_tbl.NEXT(i);
      END LOOP;
    END IF;

      okl_cld_pvt.update_row(
          p_api_version    => p_api_version,
          p_init_msg_list  => p_init_msg_list,
          x_return_status  => x_return_status,
          x_msg_count      => x_msg_count,
          x_msg_data       => x_msg_data,
          p_cldv_tbl       => lp_cldv_tbl,
          x_cldv_tbl       => x_cldv_tbl);

      If (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
        raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      Elsif (x_return_status = OKC_API.G_RET_STS_ERROR) then
        raise OKC_API.G_EXCEPTION_ERROR;
      End If;

    IF (lp_cldv_tbl.COUNT > 0) THEN
      i := lp_cldv_tbl.FIRST;
      LOOP

        l_return_status := validate_line_attr_aftimg(lp_cldv_tbl(i),G_UPDATE_MODE);
        --- Store the highest degree of error
        IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
          IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            x_return_status := l_return_status;
          END IF;
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        END IF;

        EXIT WHEN (i = lp_cldv_tbl.LAST);
        i := lp_cldv_tbl.NEXT(i);
      END LOOP;
    END IF;

/*** End API body ******************************************************/

  -- Get message count and if count is 1, get message info
	FND_MSG_PUB.Count_And_Get
    (p_count          =>      x_msg_count,
     p_data           =>      x_msg_data);

EXCEPTION
  WHEN OKL_API.G_EXCEPTION_ERROR THEN
    ROLLBACK TO update_checklist_dtl;
    x_return_status := OKL_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    ROLLBACK TO update_checklist_dtl;
    x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OTHERS THEN
	ROLLBACK TO update_checklist_dtl;
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR ;
      OKL_API.Set_Message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_UNEXPECTED_ERROR,
                          p_token1        => G_SQLCODE_TOKEN,
                          p_token1_value  => SQLCODE,
                          p_token2        => G_SQLERRM_TOKEN,
                          p_token2_value  => SQLERRM);
      FND_MSG_PUB.Count_And_Get
        (p_count         =>      x_msg_count,
         p_data          =>      x_msg_data);

end update_checklist_dtl;

----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : delete_checklist_dtl
-- Description     : wrapper api for delete checklist template details
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
 PROCEDURE delete_checklist_dtl(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_cldv_tbl                     IN  cldv_tbl_type
 )
is
  l_api_name         CONSTANT VARCHAR2(30) := 'delete_checklist_dtl';
  l_api_version      CONSTANT NUMBER       := 1.0;
  i                  NUMBER;
  l_return_status    VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  lp_cldv_tbl        cldv_tbl_type := p_cldv_tbl;
--  xp_cldv_tbl        cldv_tbl_type := x_cldv_tbl;

begin
  -- Set API savepoint
  SAVEPOINT delete_checklist_dtl;

  -- Check for call compatibility
  IF (NOT FND_API.Compatible_API_Call (l_api_version,
                                	   p_api_version,
                                	   l_api_name,
                                	   G_PKG_NAME ))
  THEN
    RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if requested
  IF (FND_API.to_Boolean(p_init_msg_list)) THEN
      FND_MSG_PUB.initialize;
	END IF;

  -- Initialize API status to success
  x_return_status := OKL_API.G_RET_STS_SUCCESS;


/*** Begin API body ****************************************************/

      okl_cld_pvt.delete_row(
          p_api_version    => p_api_version,
          p_init_msg_list  => p_init_msg_list,
          x_return_status  => x_return_status,
          x_msg_count      => x_msg_count,
          x_msg_data       => x_msg_data,
          p_cldv_tbl       => lp_cldv_tbl);

      If (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
        raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      Elsif (x_return_status = OKC_API.G_RET_STS_ERROR) then
        raise OKC_API.G_EXCEPTION_ERROR;
      End If;

/*** End API body ******************************************************/

  -- Get message count and if count is 1, get message info
	FND_MSG_PUB.Count_And_Get
    (p_count          =>      x_msg_count,
     p_data           =>      x_msg_data);

EXCEPTION
  WHEN OKL_API.G_EXCEPTION_ERROR THEN
    ROLLBACK TO delete_checklist_dtl;
    x_return_status := OKL_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    ROLLBACK TO delete_checklist_dtl;
    x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OTHERS THEN
	ROLLBACK TO delete_checklist_dtl;
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR ;
      OKL_API.Set_Message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_UNEXPECTED_ERROR,
                          p_token1        => G_SQLCODE_TOKEN,
                          p_token1_value  => SQLCODE,
                          p_token2        => G_SQLERRM_TOKEN,
                          p_token2_value  => SQLERRM);
      FND_MSG_PUB.Count_And_Get
        (p_count         =>      x_msg_count,
         p_data          =>      x_msg_data);

end delete_checklist_dtl;

-- START: Apr 25, 2005 cklee: Modification for okl.h lease app enhancement
----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : submit_for_approval
-- Description     : Submit a checklst for approval
-- Business Rules  : 1. System will update status to 'Active' for object itself
--                      and all associate checklist if applicable.
-- Parameters      :
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
 PROCEDURE submit_for_approval(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,x_status_code                  OUT NOCOPY VARCHAR2
   ,p_clh_id                       IN  NUMBER
 )
is
  l_api_name         CONSTANT VARCHAR2(30) := 'submit_for_approval_pvt';
  l_api_version      CONSTANT NUMBER       := 1.0;
  i                  NUMBER;
  l_return_status    VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  lp_clhv_rec        clhv_rec_type;
  lx_clhv_rec        clhv_rec_type;
  l_org_status_code  okl_checklists.status_code%type;

cursor c_get_status (p_clh_id number) is
  select clh.status_code
  from okl_checklists clh
  where clh.id = p_clh_id;

cursor c_get_children (p_clh_id number) is
  select clh.id
  from okl_checklists clh
  where clh.ckl_id = p_clh_id;

begin
  -- Set API savepoint
  SAVEPOINT submit_for_approval_pvt;

  -- Check for call compatibility
  IF (NOT FND_API.Compatible_API_Call (l_api_version,
                                	   p_api_version,
                                	   l_api_name,
                                	   G_PKG_NAME ))
  THEN
    RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if requested
  IF (FND_API.to_Boolean(p_init_msg_list)) THEN
      FND_MSG_PUB.initialize;
	END IF;

  -- Initialize API status to success
  x_return_status := OKL_API.G_RET_STS_SUCCESS;


/*** Begin API body ****************************************************/

     OPEN c_get_status(p_clh_id);
     FETCH c_get_status INTO l_org_status_code;
     CLOSE c_get_status;

  -- 1. check eligible for approval
      chk_eligible_for_approval(
          p_api_version    => p_api_version,
          p_init_msg_list  => p_init_msg_list,
          x_return_status  => x_return_status,
          x_msg_count      => x_msg_count,
          x_msg_data       => x_msg_data,
          p_clh_id         => p_clh_id);

      If (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
        raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      Elsif (x_return_status = OKC_API.G_RET_STS_ERROR) then
        raise OKC_API.G_EXCEPTION_ERROR;
      End If;

  -- 2. update status to Active
     lp_clhv_rec.ID := p_clh_id;
     lp_clhv_rec.STATUS_CODE := G_ACTIVE_STS_CODE;
     lp_clhv_rec.DECISION_DATE := sysdate;

      update_checklist_hdr(
          p_api_version    => p_api_version,
          p_init_msg_list  => p_init_msg_list,
          x_return_status  => x_return_status,
          x_msg_count      => x_msg_count,
          x_msg_data       => x_msg_data,
          p_clhv_rec       => lp_clhv_rec,
          x_clhv_rec       => lx_clhv_rec);

      If (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
        raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      Elsif (x_return_status = OKC_API.G_RET_STS_ERROR) then
        raise OKC_API.G_EXCEPTION_ERROR;
      End If;

  -- 3. Cascade to update all children's status if applicable
    FOR r_grp IN c_get_children (p_clh_id) LOOP

     lp_clhv_rec.ID := r_grp.id;
     lp_clhv_rec.STATUS_CODE := G_ACTIVE_STS_CODE;
     lp_clhv_rec.DECISION_DATE := sysdate;

      update_checklist_hdr(
          p_api_version    => p_api_version,
          p_init_msg_list  => p_init_msg_list,
          x_return_status  => x_return_status,
          x_msg_count      => x_msg_count,
          x_msg_data       => x_msg_data,
          p_clhv_rec       => lp_clhv_rec,
          x_clhv_rec       => lx_clhv_rec);

      If (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
        raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      Elsif (x_return_status = OKC_API.G_RET_STS_ERROR) then
        raise OKC_API.G_EXCEPTION_ERROR;
      End If;

    END LOOP;

    x_status_code := G_ACTIVE_STS_CODE;

/*** End API body ******************************************************/

  -- Get message count and if count is 1, get message info
	FND_MSG_PUB.Count_And_Get
    (p_count          =>      x_msg_count,
     p_data           =>      x_msg_data);

EXCEPTION
  WHEN OKL_API.G_EXCEPTION_ERROR THEN
    ROLLBACK TO submit_for_approval_pvt;
    x_return_status := OKL_API.G_RET_STS_ERROR;
    x_status_code := l_org_status_code;
    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    ROLLBACK TO submit_for_approval_pvt;
    x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
    x_status_code := l_org_status_code;
    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OTHERS THEN
	ROLLBACK TO submit_for_approval_pvt;
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR ;
      x_status_code := l_org_status_code;
      OKL_API.Set_Message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_UNEXPECTED_ERROR,
                          p_token1        => G_SQLCODE_TOKEN,
                          p_token1_value  => SQLCODE,
                          p_token2        => G_SQLERRM_TOKEN,
                          p_token2_value  => SQLERRM);
      FND_MSG_PUB.Count_And_Get
        (p_count         =>      x_msg_count,
         p_data          =>      x_msg_data);

end submit_for_approval;
----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : create_checklist_inst_hdr
-- Description     : wrapper api for create checklist instance header
-- Business Rules  :
--                   1. CHECKLIST_OBJ_ID and CHECKLIST_OBJ_TYPE_CODE are required
--                   2. CHECKLIST_OBJ_TYPE_CODE is referring from fnd_lookups type
--                      = 'CHECKLIST_OBJ_TYPE_CODE'
--                   3. CHECKLIST_TYPE will be defaulting to 'NONE'
--                   4. CHECKLIST_NUMBER will be defaulting to 'CHECKLIST_INSTANCE'
--                      appending system generated sequence number
--                   5. CHECKLIST_PURPOSE_CODE will be defaulting to 'CHECKLIST_INSTANCE'
-- Parameters      :
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
 PROCEDURE create_checklist_inst_hdr(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_clhv_rec                     IN  clhv_rec_type
   ,x_clhv_rec                     OUT NOCOPY clhv_rec_type
 )
is
  l_api_name         CONSTANT VARCHAR2(30) := 'create_checklist_inst_hdr';
  l_api_version      CONSTANT NUMBER       := 1.0;
  i                  NUMBER;
  l_return_status    VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  lp_clhv_rec        clhv_rec_type := p_clhv_rec;
--  lx_clhv_rec        clhv_rec_type := x_clhv_rec;
  l_seq              NUMBER;

cursor c_seq is
select okl_inst_checklist_num_s.nextval
from dual;

begin
  -- Set API savepoint
  SAVEPOINT create_checklist_inst_hdr;

  -- Check for call compatibility
  IF (NOT FND_API.Compatible_API_Call (l_api_version,
                                	   p_api_version,
                                	   l_api_name,
                                	   G_PKG_NAME ))
  THEN
    RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if requested
  IF (FND_API.to_Boolean(p_init_msg_list)) THEN
      FND_MSG_PUB.initialize;
	END IF;

  -- Initialize API status to success
  x_return_status := OKL_API.G_RET_STS_SUCCESS;


/*** Begin API body ****************************************************/

-- set default:
   lp_clhv_rec.CHECKLIST_TYPE := 'NONE';
   lp_clhv_rec.CHECKLIST_PURPOSE_CODE := 'CHECKLIST_INSTANCE';

   OPEN c_seq;
   FETCH c_seq INTO l_seq;
   CLOSE c_seq;
   lp_clhv_rec.CHECKLIST_NUMBER := 'CHECKLIST_INSTANCE' || TO_CHAR(l_seq);

      create_checklist_hdr(
          p_api_version    => p_api_version,
          p_init_msg_list  => p_init_msg_list,
          x_return_status  => x_return_status,
          x_msg_count      => x_msg_count,
          x_msg_data       => x_msg_data,
          p_clhv_rec       => lp_clhv_rec,
          x_clhv_rec       => x_clhv_rec);

      If (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
        raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      Elsif (x_return_status = OKC_API.G_RET_STS_ERROR) then
        raise OKC_API.G_EXCEPTION_ERROR;
      End If;

--dbms_output.put_line('create_checklist_inst_hdr->x_clhv_rec.id :'|| to_char(x_clhv_rec.ID));

/*** End API body ******************************************************/

  -- Get message count and if count is 1, get message info
	FND_MSG_PUB.Count_And_Get
    (p_count          =>      x_msg_count,
     p_data           =>      x_msg_data);

EXCEPTION
  WHEN OKL_API.G_EXCEPTION_ERROR THEN
    ROLLBACK TO create_checklist_inst_hdr;
    x_return_status := OKL_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    ROLLBACK TO create_checklist_inst_hdr;
    x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OTHERS THEN
	ROLLBACK TO create_checklist_inst_hdr;
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR ;
      OKL_API.Set_Message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_UNEXPECTED_ERROR,
                          p_token1        => G_SQLCODE_TOKEN,
                          p_token1_value  => SQLCODE,
                          p_token2        => G_SQLERRM_TOKEN,
                          p_token2_value  => SQLERRM);
      FND_MSG_PUB.Count_And_Get
        (p_count         =>      x_msg_count,
         p_data          =>      x_msg_data);

end create_checklist_inst_hdr;

----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : update_checklist_inst_hdr
-- Description     : wrapper api for update checklist instance header
-- Business Rules  :
--                   1. System allows to update the following columns
--                   SHORT_DESCRIPTION, DESCRIPTION, START_DATE, END_DATE, STATUS_CODE
--                   DECISION_DATE, CHECKLIST_OBJ_ID, CHECKLIST_OBJ_TYPE_CODE
--
-- Parameters      :
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
 PROCEDURE update_checklist_inst_hdr(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_clhv_rec                     IN  clhv_rec_type
   ,x_clhv_rec                     OUT NOCOPY clhv_rec_type
 )
is
  l_api_name         CONSTANT VARCHAR2(30) := 'update_checklist_inst_hdr';
  l_api_version      CONSTANT NUMBER       := 1.0;
  i                  NUMBER;
  l_return_status    VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  lp_clhv_rec        clhv_rec_type := p_clhv_rec;
--  lx_clhv_rec        clhv_rec_type := x_clhv_rec;

begin
  -- Set API savepoint
  SAVEPOINT update_checklist_inst_hdr;

  -- Check for call compatibility
  IF (NOT FND_API.Compatible_API_Call (l_api_version,
                                	   p_api_version,
                                	   l_api_name,
                                	   G_PKG_NAME ))
  THEN
    RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if requested
  IF (FND_API.to_Boolean(p_init_msg_list)) THEN
      FND_MSG_PUB.initialize;
	END IF;

  -- Initialize API status to success
  x_return_status := OKL_API.G_RET_STS_SUCCESS;


/*** Begin API body ****************************************************/

      update_checklist_hdr(
          p_api_version    => p_api_version,
          p_init_msg_list  => p_init_msg_list,
          x_return_status  => x_return_status,
          x_msg_count      => x_msg_count,
          x_msg_data       => x_msg_data,
          p_clhv_rec       => lp_clhv_rec,
          x_clhv_rec       => x_clhv_rec);

      If (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
        raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      Elsif (x_return_status = OKC_API.G_RET_STS_ERROR) then
        raise OKC_API.G_EXCEPTION_ERROR;
      End If;

/*** End API body ******************************************************/

  -- Get message count and if count is 1, get message info
	FND_MSG_PUB.Count_And_Get
    (p_count          =>      x_msg_count,
     p_data           =>      x_msg_data);

EXCEPTION
  WHEN OKL_API.G_EXCEPTION_ERROR THEN
    ROLLBACK TO update_checklist_inst_hdr;
    x_return_status := OKL_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    ROLLBACK TO update_checklist_inst_hdr;
    x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OTHERS THEN
	ROLLBACK TO update_checklist_inst_hdr;
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR ;
      OKL_API.Set_Message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_UNEXPECTED_ERROR,
                          p_token1        => G_SQLCODE_TOKEN,
                          p_token1_value  => SQLCODE,
                          p_token2        => G_SQLERRM_TOKEN,
                          p_token2_value  => SQLERRM);
      FND_MSG_PUB.Count_And_Get
        (p_count         =>      x_msg_count,
         p_data          =>      x_msg_data);

end update_checklist_inst_hdr;

----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : delete_checklist_inst_hdr
-- Description     : wrapper api for delete checklist instance header
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
 PROCEDURE delete_checklist_inst_hdr(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_clhv_rec                     IN  clhv_rec_type
 )
is
  l_api_name         CONSTANT VARCHAR2(30) := 'delete_checklist_inst_hdr';
  l_api_version      CONSTANT NUMBER       := 1.0;
  i                  NUMBER;
  l_return_status    VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  lp_clhv_rec        clhv_rec_type := p_clhv_rec;
--  lx_clhv_rec        clhv_rec_type := x_clhv_rec;

begin
  -- Set API savepoint
  SAVEPOINT delete_checklist_inst_hdr;

  -- Check for call compatibility
  IF (NOT FND_API.Compatible_API_Call (l_api_version,
                                	   p_api_version,
                                	   l_api_name,
                                	   G_PKG_NAME ))
  THEN
    RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if requested
  IF (FND_API.to_Boolean(p_init_msg_list)) THEN
      FND_MSG_PUB.initialize;
	END IF;

  -- Initialize API status to success
  x_return_status := OKL_API.G_RET_STS_SUCCESS;


/*** Begin API body ****************************************************/

      delete_checklist_hdr(
          p_api_version    => p_api_version,
          p_init_msg_list  => p_init_msg_list,
          x_return_status  => x_return_status,
          x_msg_count      => x_msg_count,
          x_msg_data       => x_msg_data,
          p_clhv_rec       => lp_clhv_rec);

      If (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
        raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      Elsif (x_return_status = OKC_API.G_RET_STS_ERROR) then
        raise OKC_API.G_EXCEPTION_ERROR;
      End If;

/*** End API body ******************************************************/

  -- Get message count and if count is 1, get message info
	FND_MSG_PUB.Count_And_Get
    (p_count          =>      x_msg_count,
     p_data           =>      x_msg_data);

EXCEPTION
  WHEN OKL_API.G_EXCEPTION_ERROR THEN
    ROLLBACK TO delete_checklist_inst_hdr;
    x_return_status := OKL_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    ROLLBACK TO delete_checklist_inst_hdr;
    x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OTHERS THEN
	ROLLBACK TO delete_checklist_inst_hdr;
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR ;
      OKL_API.Set_Message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_UNEXPECTED_ERROR,
                          p_token1        => G_SQLCODE_TOKEN,
                          p_token1_value  => SQLCODE,
                          p_token2        => G_SQLERRM_TOKEN,
                          p_token2_value  => SQLERRM);
      FND_MSG_PUB.Count_And_Get
        (p_count         =>      x_msg_count,
         p_data          =>      x_msg_data);

end delete_checklist_inst_hdr;

----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : create_checklist_inst_dtl
-- Description     : wrapper api for create checklist instance details
-- Business Rules  :
--                   1. CKL_ID, TODO_ITEM_CODE, and INST_CHECKLIST_TYPE are required
--                   2. CKL_ID is referring from okl_checklists.ID as FK
--                   3. TODO_ITEM_CODE is referring from fnd_lookups type
--                      = 'OKL_TODO_ITEMS'
--                   4. INST_CHECKLIST_TYPE is referring from fnd_lookups type
--                      = 'OKL_CHECKLIST_TYPE'
--                   5. The following columns are referring from fnd_lookups type
--                      = 'OKL_YES_NO'
--                        MANDATORY_FLAG
--                        USER_COMPLETE_FLAG
--                        APPEAL_FLAG
--                   6. FUNCTION_VALIDATE_RSTS is referring from fnd_lookups type
--                      = 'OKL_FUN_VALIDATE_RSTS'
--                   7. System will defaulting DNZ_CHECKLIST_OBJ_ID from the
--                      corresponding okl_chekclists.CHECKLIST_OBJ_ID
--                   8. FUNCTION_ID is referring from OKL_DATA_SRC_FNCTNS_V
--                   9. MANDATORY_FLAG, USER_COMPLETE_FLAG and APPEAL_FLAG will defult to 'N'
-- Parameters      :
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
 PROCEDURE create_checklist_inst_dtl(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_cldv_tbl                     IN  cldv_tbl_type
   ,x_cldv_tbl                     OUT NOCOPY cldv_tbl_type
 )
 is
  l_api_name         CONSTANT VARCHAR2(30) := 'create_checklist_inst_dtl';
  l_api_version      CONSTANT NUMBER       := 1.0;
  i                  NUMBER;
  l_return_status    VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  lp_cldv_tbl        cldv_tbl_type := p_cldv_tbl;
--  lx_cldv_tbl        cldv_tbl_type := x_cldv_tbl;
  l_obj_id           number;

cursor c_obj_id (p_clh_id number) is
  select clh.CHECKLIST_OBJ_ID
  from okl_checklists clh
  where clh.id = p_clh_id;

begin
  -- Set API savepoint
  SAVEPOINT create_checklist_inst_dtl;

  -- Check for call compatibility
  IF (NOT FND_API.Compatible_API_Call (l_api_version,
                                	   p_api_version,
                                	   l_api_name,
                                	   G_PKG_NAME ))
  THEN
    RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if requested
  IF (FND_API.to_Boolean(p_init_msg_list)) THEN
      FND_MSG_PUB.initialize;
	END IF;

  -- Initialize API status to success
  x_return_status := OKL_API.G_RET_STS_SUCCESS;


/*** Begin API body ****************************************************/

-- set default:
    OPEN c_obj_id (lp_cldv_tbl(lp_cldv_tbl.FIRST).ckl_id);
    FETCH c_obj_id INTO l_obj_id;
    CLOSE c_obj_id;

    IF (lp_cldv_tbl.COUNT > 0) THEN
      i := lp_cldv_tbl.FIRST;
      LOOP
        lp_cldv_tbl(i).DNZ_CHECKLIST_OBJ_ID := l_obj_id;

--START:| 05-Jan-2006  cklee -- Fixed bug#4930868                                    |
        IF (lp_cldv_tbl(i).MANDATORY_FLAG IS NULL or
            lp_cldv_tbl(i).MANDATORY_FLAG = OKL_API.G_MISS_CHAR) THEN
          -- set default for MANDATORY_FLAG
          lp_cldv_tbl(i).MANDATORY_FLAG := 'N';
        END IF;
--END:| 05-Jan-2006  cklee -- Fixed bug#4930868                                    |
        --PAGARG: Bug 4872271: Default the value of APPEAL_FLAG to N
        IF (lp_cldv_tbl(i).APPEAL_FLAG IS NULL OR
            lp_cldv_tbl(i).APPEAL_FLAG = OKL_API.G_MISS_CHAR) THEN
          -- set default for APPEAL_FLAG
          lp_cldv_tbl(i).APPEAL_FLAG := 'N';
        END IF;

        -- set default for FUNCTION_VALIDATE_RSTS
        IF lp_cldv_tbl(i).FUNCTION_ID IS NOT NULL THEN
          lp_cldv_tbl(i).FUNCTION_VALIDATE_RSTS := 'UNDETERMINED';
        END IF;

        -- set default for USER_COMPLETE_FLAG
        IF lp_cldv_tbl(i).FUNCTION_ID IS NULL THEN
          lp_cldv_tbl(i).USER_COMPLETE_FLAG := 'N';
        END IF;

        EXIT WHEN (i = lp_cldv_tbl.LAST);
        i := lp_cldv_tbl.NEXT(i);
      END LOOP;
    END IF;

      create_checklist_dtl(
          p_api_version    => p_api_version,
          p_init_msg_list  => p_init_msg_list,
          x_return_status  => x_return_status,
          x_msg_count      => x_msg_count,
          x_msg_data       => x_msg_data,
          p_cldv_tbl       => lp_cldv_tbl,
          x_cldv_tbl       => x_cldv_tbl);

      If (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
        raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      Elsif (x_return_status = OKC_API.G_RET_STS_ERROR) then
        raise OKC_API.G_EXCEPTION_ERROR;
      End If;

/*** End API body ******************************************************/

  -- Get message count and if count is 1, get message info
	FND_MSG_PUB.Count_And_Get
    (p_count          =>      x_msg_count,
     p_data           =>      x_msg_data);

EXCEPTION
  WHEN OKL_API.G_EXCEPTION_ERROR THEN
    ROLLBACK TO create_checklist_inst_dtl;
    x_return_status := OKL_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    ROLLBACK TO create_checklist_inst_dtl;
    x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OTHERS THEN
	ROLLBACK TO create_checklist_inst_dtl;
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR ;
      OKL_API.Set_Message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_UNEXPECTED_ERROR,
                          p_token1        => G_SQLCODE_TOKEN,
                          p_token1_value  => SQLCODE,
                          p_token2        => G_SQLERRM_TOKEN,
                          p_token2_value  => SQLERRM);
      FND_MSG_PUB.Count_And_Get
        (p_count         =>      x_msg_count,
         p_data          =>      x_msg_data);

end create_checklist_inst_dtl;

----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : update_checklist_inst_hdr
-- Description     : wrapper api for update checklist instance details
-- Business Rules  :
--                   1. System allows to update the following columns
--                   TODO_ITEM_CODE, MANDATORY_FLAG, USER_COMPLETE_FLAG
--                   ADMIN_NOTE, USER_NOTE, FUNCTION_ID, FUNCTION_VALIDATE_RSTS
--                   FUNCTION_VALIDATE_MSG, INST_CHECKLIST_TYPE and APPEAL_FLAG
--
-- Parameters      :
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
 PROCEDURE update_checklist_inst_dtl(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_cldv_tbl                     IN  cldv_tbl_type
   ,x_cldv_tbl                     OUT NOCOPY cldv_tbl_type
 )
 is
  l_api_name         CONSTANT VARCHAR2(30) := 'update_checklist_inst_dtl';
  l_api_version      CONSTANT NUMBER       := 1.0;
  i                  NUMBER;
  l_return_status    VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  lp_cldv_tbl        cldv_tbl_type := p_cldv_tbl;
--  lx_cldv_tbl        cldv_tbl_type := x_cldv_tbl;

begin
  -- Set API savepoint
  SAVEPOINT update_checklist_inst_dtl;

  -- Check for call compatibility
  IF (NOT FND_API.Compatible_API_Call (l_api_version,
                                	   p_api_version,
                                	   l_api_name,
                                	   G_PKG_NAME ))
  THEN
    RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if requested
  IF (FND_API.to_Boolean(p_init_msg_list)) THEN
      FND_MSG_PUB.initialize;
	END IF;

  -- Initialize API status to success
  x_return_status := OKL_API.G_RET_STS_SUCCESS;

/*** Begin API body ****************************************************/

      update_checklist_dtl(
          p_api_version    => p_api_version,
          p_init_msg_list  => p_init_msg_list,
          x_return_status  => x_return_status,
          x_msg_count      => x_msg_count,
          x_msg_data       => x_msg_data,
          p_cldv_tbl       => lp_cldv_tbl,
          x_cldv_tbl       => x_cldv_tbl);

      If (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
        raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      Elsif (x_return_status = OKC_API.G_RET_STS_ERROR) then
        raise OKC_API.G_EXCEPTION_ERROR;
      End If;

/*** End API body ******************************************************/

  -- Get message count and if count is 1, get message info
	FND_MSG_PUB.Count_And_Get
    (p_count          =>      x_msg_count,
     p_data           =>      x_msg_data);

EXCEPTION
  WHEN OKL_API.G_EXCEPTION_ERROR THEN
    ROLLBACK TO update_checklist_inst_dtl;
    x_return_status := OKL_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    ROLLBACK TO update_checklist_inst_dtl;
    x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OTHERS THEN
	ROLLBACK TO update_checklist_inst_dtl;
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR ;
      OKL_API.Set_Message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_UNEXPECTED_ERROR,
                          p_token1        => G_SQLCODE_TOKEN,
                          p_token1_value  => SQLCODE,
                          p_token2        => G_SQLERRM_TOKEN,
                          p_token2_value  => SQLERRM);
      FND_MSG_PUB.Count_And_Get
        (p_count         =>      x_msg_count,
         p_data          =>      x_msg_data);

end update_checklist_inst_dtl;


----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : delete_checklist_inst_dtl
-- Description     : wrapper api for delete checklist instance details
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
 PROCEDURE delete_checklist_inst_dtl(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_cldv_tbl                     IN  cldv_tbl_type
 )
 is
  l_api_name         CONSTANT VARCHAR2(30) := 'delete_checklist_inst_dtl';
  l_api_version      CONSTANT NUMBER       := 1.0;
  i                  NUMBER;
  l_return_status    VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  lp_cldv_tbl        cldv_tbl_type := p_cldv_tbl;
--  lx_cldv_tbl        cldv_tbl_type := x_cldv_tbl;

begin
  -- Set API savepoint
  SAVEPOINT delete_checklist_inst_dtl;

  -- Check for call compatibility
  IF (NOT FND_API.Compatible_API_Call (l_api_version,
                                	   p_api_version,
                                	   l_api_name,
                                	   G_PKG_NAME ))
  THEN
    RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if requested
  IF (FND_API.to_Boolean(p_init_msg_list)) THEN
      FND_MSG_PUB.initialize;
	END IF;

  -- Initialize API status to success
  x_return_status := OKL_API.G_RET_STS_SUCCESS;


/*** Begin API body ****************************************************/

      delete_checklist_dtl(
          p_api_version    => p_api_version,
          p_init_msg_list  => p_init_msg_list,
          x_return_status  => x_return_status,
          x_msg_count      => x_msg_count,
          x_msg_data       => x_msg_data,
          p_cldv_tbl       => lp_cldv_tbl);

      If (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
        raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      Elsif (x_return_status = OKC_API.G_RET_STS_ERROR) then
        raise OKC_API.G_EXCEPTION_ERROR;
      End If;

/*** End API body ******************************************************/

  -- Get message count and if count is 1, get message info
	FND_MSG_PUB.Count_And_Get
    (p_count          =>      x_msg_count,
     p_data           =>      x_msg_data);

EXCEPTION
  WHEN OKL_API.G_EXCEPTION_ERROR THEN
    ROLLBACK TO delete_checklist_inst_dtl;
    x_return_status := OKL_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    ROLLBACK TO delete_checklist_inst_dtl;
    x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OTHERS THEN
	ROLLBACK TO delete_checklist_inst_dtl;
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR ;
      OKL_API.Set_Message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_UNEXPECTED_ERROR,
                          p_token1        => G_SQLCODE_TOKEN,
                          p_token1_value  => SQLCODE,
                          p_token2        => G_SQLERRM_TOKEN,
                          p_token2_value  => SQLERRM);
      FND_MSG_PUB.Count_And_Get
        (p_count         =>      x_msg_count,
         p_data          =>      x_msg_data);

end delete_checklist_inst_dtl;

----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : chk_eligible_for_approval
-- Description     : Check if it's eligible for approval
-- Business Rules  :
-- The following scenarios are not eligible for approval
-- 1	Checklist template (either group or individual) status is Active.
-- 2	Group checklist template doesn't have child checklist assocaite with it.
-- 3 	Group checklist template does have child checklist associate with it,
--      but child checklist doesn't have items defined.
-- 4	Checklist template does have group checklist assocaite with it (Has parent checklist).
-- 5    Checklist template doesn't have items defined.
-- Parameters      :
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
 PROCEDURE chk_eligible_for_approval(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_clh_id                       IN  NUMBER
 )
 is
  l_api_name         CONSTANT VARCHAR2(30) := 'chk_eligible_for_approval';
  l_api_version      CONSTANT NUMBER       := 1.0;
  i                  NUMBER;
  l_return_status    VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  l_dummy  number;

  l_row_not_found boolean := false;

--START:| 23-Feb-2006  cklee -- Fixed bug#5018561                                    |
  l_clhv_rec     clhv_rec_type;
--END:| 23-Feb-2006  cklee -- Fixed bug#5018561                                    |

-- get checklist template attributes
cursor c_checklists (p_clh_id number) is
  select clh.status_code,
         clh.checklist_purpose_code,
         clh.ckl_id
  from   okl_checklists clh
  where  clh.id = p_clh_id
  ;

-- existing checklists for a group checklist
cursor c_checklist_grp (p_clh_id number) is
  select 1
  from   okl_checklists clh
  where  clh.ckl_id = p_clh_id
  ;

-- existing checklist items for a group checklist
cursor c_clist_ids_by_grp (p_clh_id number) is
  select clh.id
  from   okl_checklists clh
  where  clh.ckl_id = p_clh_id
  ;

cursor c_checklist_grp_items (p_clh_id number) is
  select 1
  from   okl_checklist_details cld
  where  cld.ckl_id = p_clh_id
  ;


-- existing checklist items for a checcklist
cursor c_checklist_items (p_clh_id number) is
  select 1
  from   okl_checklist_details cld
  where  cld.ckl_id = p_clh_id
  ;


begin
  -- Set API savepoint
  SAVEPOINT chk_eligible_for_approval;

  -- Check for call compatibility
  IF (NOT FND_API.Compatible_API_Call (l_api_version,
                                	   p_api_version,
                                	   l_api_name,
                                	   G_PKG_NAME ))
  THEN
    RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if requested
  IF (FND_API.to_Boolean(p_init_msg_list)) THEN
      FND_MSG_PUB.initialize;
	END IF;

  -- Initialize API status to success
  x_return_status := OKL_API.G_RET_STS_SUCCESS;


/*** Begin API body ****************************************************/
-- The following scenarios are not eligible for approval
-- 1	Checklist template (either group or individual) status is Active.
-- 2	Group checklist template doesn't have child checklist assocaite with it.
-- 3 	Group checklist template does have child checklist associate with it,
--      but child checklist doesn't have items defined.
-- 4	Checklist template does have group checklist assocaite with it (Has parent checklist).
-- 5    Checklist template doesn't have items defined.
-- 6.   Checklist item effetcive from date must with the checklist header's date range

    FOR r_this_row IN c_checklists (p_clh_id) LOOP

      -- 1	Checklist template (either group or individual) status is Active.
      IF r_this_row.status_code =  G_ACTIVE_STS_CODE THEN
          OKL_API.Set_Message(p_app_name     => G_APP_NAME,
                              p_msg_name     => 'OKL_CHK_STATUS_4_APPROVAL');

          RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;

      -------------------------------------------------------------
      -- Group checklist
      -------------------------------------------------------------
      IF r_this_row.checklist_purpose_code =  'CHECKLIST_TEMPLATE_GROUP' THEN

        -- 2	Group checklist template doesn't have child checklist assocaite with it.
        OPEN c_checklist_grp(p_clh_id);
        FETCH c_checklist_grp INTO l_dummy;
        l_row_not_found := c_checklist_grp%NOTFOUND;
        CLOSE c_checklist_grp;

        IF (l_row_not_found) THEN
          OKL_API.Set_Message(p_app_name     => G_APP_NAME,
                              p_msg_name     => 'OKL_CHK_CHILD_CLIST');

          RAISE G_EXCEPTION_HALT_VALIDATION;

        ELSE
          -- 3 	Group checklist template does have child checklist associate with it,
          --      but not all child checklists have items defined.
          FOR r_clist_row IN c_clist_ids_by_grp(p_clh_id) LOOP

            OPEN c_checklist_grp_items(r_clist_row.id);
            FETCH c_checklist_grp_items INTO l_dummy;
            l_row_not_found := c_checklist_grp_items%NOTFOUND;
            CLOSE c_checklist_grp_items;

            IF (l_row_not_found) THEN
              OKL_API.Set_Message(p_app_name     => G_APP_NAME,
                                  p_msg_name     => 'OKL_CHK_CHILD_CLIST_ITEMS');

              RAISE G_EXCEPTION_HALT_VALIDATION;
            END IF;

          END LOOP;

        END IF;

      -------------------------------------------------------------
      -- Checklist
      -------------------------------------------------------------
      ELSIF r_this_row.checklist_purpose_code =  'CHECKLIST_TEMPLATE' THEN

        -- 4	Checklist template does have group checklist assocaite with it (Has parent checklist).
        IF r_this_row.ckl_id IS NOT NULL THEN
            OKL_API.Set_Message(p_app_name     => G_APP_NAME,
                                p_msg_name     => 'OKL_CHK_PARENT_CLIST');

          RAISE G_EXCEPTION_HALT_VALIDATION;
        END IF;

        -- 5    Checklist template doesn't have items defined.
        OPEN c_checklist_items(p_clh_id);
        FETCH c_checklist_items INTO l_dummy;
        l_row_not_found := c_checklist_items%NOTFOUND;
        CLOSE c_checklist_items;

        IF (l_row_not_found) THEN
            OKL_API.Set_Message(p_app_name     => G_APP_NAME,
                                p_msg_name     => 'OKL_CHK_CLIST_ITEMS');

          RAISE G_EXCEPTION_HALT_VALIDATION;
        END IF;

      END IF;

    END LOOP;

--START:| 23-Feb-2006  cklee -- Fixed bug#5018561                                    |
-- 6.   Checklist item effetcive from date must within the checklist header's date range
   l_clhv_rec.id := p_clh_id;
   l_return_status := validate_dates_w_item(l_clhv_rec, G_UPDATE_MODE);
   --- Store the highest degree of error
   IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
     IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       x_return_status := l_return_status;
     END IF;
     RAISE G_EXCEPTION_HALT_VALIDATION;
   END IF;
--END:| 23-Feb-2006  cklee -- Fixed bug#5018561                                    |

/*** End API body ******************************************************/

  -- Get message count and if count is 1, get message info
	FND_MSG_PUB.Count_And_Get
    (p_count          =>      x_msg_count,
     p_data           =>      x_msg_data);

EXCEPTION
  WHEN OKL_API.G_EXCEPTION_ERROR THEN
    ROLLBACK TO chk_eligible_for_approval;
    x_return_status := OKL_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    ROLLBACK TO chk_eligible_for_approval;
    x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

--START: 06-Oct-2005  cklee -- Fixed dupliciated system error message               |
  WHEN G_EXCEPTION_HALT_VALIDATION THEN
    ROLLBACK TO chk_eligible_for_approval;
    x_return_status := OKL_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);
--END: 06-Oct-2005  cklee -- Fixed dupliciated system error message               |

  WHEN OTHERS THEN
	ROLLBACK TO chk_eligible_for_approval;
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR ;
      OKL_API.Set_Message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_UNEXPECTED_ERROR,
                          p_token1        => G_SQLCODE_TOKEN,
                          p_token1_value  => SQLCODE,
                          p_token2        => G_SQLERRM_TOKEN,
                          p_token2_value  => SQLERRM);
      FND_MSG_PUB.Count_And_Get
        (p_count         =>      x_msg_count,
         p_data          =>      x_msg_data);

end chk_eligible_for_approval;

----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : update_checklist_function
-- Description     : This API will execute function for each item and
--                   update the execution results for the function.
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
 PROCEDURE update_checklist_function(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_checklist_obj_id             IN  NUMBER
 ) is
  l_api_name         CONSTANT VARCHAR2(30) := 'update_checklist_function';
  l_api_version      CONSTANT NUMBER       := 1.0;
  i                  NUMBER;
  l_return_status    VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  l_dummy  number;

  l_row_not_found boolean := false;

  lp_cldv_rec        cldv_rec_type;
  lx_cldv_rec        cldv_rec_type;
  plsql_block        VARCHAR2(500);

  lp_return_status   okl_checklist_details.FUNCTION_VALIDATE_RSTS%type;
  lp_fund_rst        okl_checklist_details.FUNCTION_VALIDATE_RSTS%type;
  lp_msg_data        okl_checklist_details.FUNCTION_VALIDATE_MSG%type;

-- get checklist template attributes
cursor c_clist_funs (p_checklist_obj_id number) is
  select cld.FUNCTION_SOURCE,
         cld.ID
  from   okl_checklist_details_uv cld
--START:| 21-Dec-2005  cklee -- Fixed bug#4880288 -- 4908242
         ,okl_checklists hdr
--  where  cld.DNZ_CHECKLIST_OBJ_ID = p_checklist_obj_id
  where cld.ckl_id = hdr.id
  and  hdr.CHECKLIST_OBJ_ID = p_checklist_obj_id
--START:| 21-Dec-2005  cklee -- Fixed bug#4880288 -- 4908242
  and    cld.FUNCTION_ID IS NOT NULL
  ;

begin
  -- Set API savepoint
  SAVEPOINT update_checklist_function;

  -- Check for call compatibility
  IF (NOT FND_API.Compatible_API_Call (l_api_version,
                                	   p_api_version,
                                	   l_api_name,
                                	   G_PKG_NAME ))
  THEN
    RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if requested
  IF (FND_API.to_Boolean(p_init_msg_list)) THEN
      FND_MSG_PUB.initialize;
	END IF;

  -- Initialize API status to success
  x_return_status := OKL_API.G_RET_STS_SUCCESS;


/*** Begin API body ****************************************************/

    ------------------------------------------------------------------------
    -- execute function for each to do item and save the return to each row
    ------------------------------------------------------------------------
    FOR r_this_row IN c_clist_funs (p_checklist_obj_id) LOOP

      BEGIN

        plsql_block := 'BEGIN :l_rtn := '|| r_this_row.FUNCTION_SOURCE ||'(:p_obj_id); END;';
        EXECUTE IMMEDIATE plsql_block USING OUT lp_return_status, p_checklist_obj_id;

        IF lp_return_status = 'P' THEN
          lp_fund_rst := 'PASSED';
          lp_msg_data := 'Passed';
        ELSIF lp_return_status = 'F' THEN
          lp_fund_rst := 'FAILED';
          lp_msg_data := 'Failed';
        ELSE
          lp_fund_rst := 'ERROR';
          lp_msg_data := r_this_row.FUNCTION_SOURCE || ' returns: ' || lp_return_status;
        END IF;

      EXCEPTION
        WHEN OKL_API.G_EXCEPTION_ERROR THEN
          lp_fund_rst := 'ERROR';
          FND_MSG_PUB.Count_And_Get
            (p_count         =>      x_msg_count,
             p_data          =>      x_msg_data);
          lp_msg_data := substr('Application error: ' || x_msg_data, 2000);

        WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
          lp_fund_rst := 'ERROR';
          FND_MSG_PUB.Count_And_Get
            (p_count         =>      x_msg_count,
             p_data          =>      x_msg_data);
          lp_msg_data := substr('Unexpected application error: ' || x_msg_data, 2000);

        WHEN OTHERS THEN
          lp_fund_rst := 'ERROR';
          lp_msg_data := substr('Unexpected system error: ' || SQLERRM, 2000);

      END;

      lp_cldv_rec.ID := r_this_row.ID;
      lp_cldv_rec.FUNCTION_VALIDATE_RSTS := lp_fund_rst;
      lp_cldv_rec.FUNCTION_VALIDATE_MSG := lp_msg_data;

      okl_cld_pvt.update_row(
          p_api_version    => p_api_version,
          p_init_msg_list  => p_init_msg_list,
          x_return_status  => x_return_status,
          x_msg_count      => x_msg_count,
          x_msg_data       => x_msg_data,
          p_cldv_rec       => lp_cldv_rec,
          x_cldv_rec       => lx_cldv_rec);

      If (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
        raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      Elsif (x_return_status = OKC_API.G_RET_STS_ERROR) then
        raise OKC_API.G_EXCEPTION_ERROR;
      End If;

    END LOOP;

/*** End API body ******************************************************/

  -- Get message count and if count is 1, get message info
	FND_MSG_PUB.Count_And_Get
    (p_count          =>      x_msg_count,
     p_data           =>      x_msg_data);

EXCEPTION
  WHEN OKL_API.G_EXCEPTION_ERROR THEN
    ROLLBACK TO update_checklist_function;
    x_return_status := OKL_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    ROLLBACK TO update_checklist_function;
    x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OTHERS THEN

	ROLLBACK TO update_checklist_function;
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR ;
      OKL_API.Set_Message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_UNEXPECTED_ERROR,
                          p_token1        => G_SQLCODE_TOKEN,
                          p_token1_value  => SQLCODE,
                          p_token2        => G_SQLERRM_TOKEN,
                          p_token2_value  => SQLERRM);
      FND_MSG_PUB.Count_And_Get
        (p_count         =>      x_msg_count,
         p_data          =>      x_msg_data);

end update_checklist_function;
-- END: Apr 25, 2005 cklee: Modification for okl.h lease app enhancement

-- START: June 06, 2005 cklee: Modification for okl.h lease app enhancement
----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : create_contract_checklist
-- Description     : Wrapper API for creates a checklist instance header and detail,
--                   for which the checklists copy the corresponding lease application.
-- Business Rules  :
--                   1. Create an instance of the checklist header for the contract.
--                   2. Create the detail list items for the checklist header,
--                      for which the checklist copy corresponding lease application.
-- Parameters      :
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
 PROCEDURE create_contract_checklist(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_chr_id                       IN  NUMBER
 )
is
  l_api_name         CONSTANT VARCHAR2(30) := 'create_contract_checklist';
  l_api_version      CONSTANT NUMBER       := 1.0;
  i                  NUMBER;
  l_return_status    VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  lp_clhv_rec        clhv_rec_type;
  lx_clhv_rec        clhv_rec_type;
  lp_cldv_tbl        cldv_tbl_type;
  lx_cldv_tbl        cldv_tbl_type;

-- start: 06-June-2005  cklee okl.h Lease App IA Authoring
  l_dummy number;
  l_lease_app_id number;
  l_lease_app_found boolean;
  l_lease_app_list_found boolean;

---------------------------------------------------------------------------------------------------------
-- check if the contract was created from a lease application
---------------------------------------------------------------------------------------------------------
CURSOR c_lease_app (p_chr_id okc_k_headers_b.id%type)
IS
  select chr.ORIG_SYSTEM_ID1
from  okc_k_headers_b chr
where ORIG_SYSTEM_SOURCE_CODE = G_OKL_LEASE_APP
and   chr.id = p_chr_id
;

---------------------------------------------------------------------------------------------------
-- Activation checklist refer from a Lease application
---------------------------------------------------------------------------------------------------
cursor c_chk_lease_app (p_lease_app_id number) is
select
  chk.TODO_ITEM_CODE,
  NVL(chk.MANDATORY_FLAG, 'N') MANDATORY_FLAG,
  chk.USER_NOTE,
  chk.FUNCTION_ID,
  chk.INST_CHECKLIST_TYPE
from OKL_CHECKLIST_DETAILS chk
--START:| 21-Dec-2005  cklee -- Fixed bug#4880288 -- 4908242
     ,okl_checklists hdr
where chk.ckl_id = hdr.id
--where chk.DNZ_CHECKLIST_OBJ_ID = p_lease_app_id
and hdr.CHECKLIST_OBJ_ID = p_lease_app_id
--START:| 21-Dec-2005  cklee -- Fixed bug#4880288 -- 4908242
and chk.INST_CHECKLIST_TYPE = 'ACTIVATION'
;

cursor c_lease_app_list_exists (p_lease_app_id number) is
select 1
from OKL_CHECKLIST_DETAILS chk
--START:| 21-Dec-2005  cklee -- Fixed bug#4880288 -- 4908242
     ,okl_checklists hdr
where chk.ckl_id = hdr.id
--where chk.DNZ_CHECKLIST_OBJ_ID = p_lease_app_id
and hdr.CHECKLIST_OBJ_ID = p_lease_app_id
--END:| 21-Dec-2005  cklee -- Fixed bug#4880288 -- 4908242
and chk.INST_CHECKLIST_TYPE = 'ACTIVATION'
;
-- end: 06-June-2005  cklee okl.h Lease App IA Authoring

begin
  -- Set API savepoint
  SAVEPOINT create_contract_checklist;

  -- Check for call compatibility
  IF (NOT FND_API.Compatible_API_Call (l_api_version,
                                	   p_api_version,
                                	   l_api_name,
                                	   G_PKG_NAME ))
  THEN
    RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if requested
  IF (FND_API.to_Boolean(p_init_msg_list)) THEN
      FND_MSG_PUB.initialize;
	END IF;

  -- Initialize API status to success
  x_return_status := OKL_API.G_RET_STS_SUCCESS;

/*** Begin API body ****************************************************/
-- start: 06-June-2005  cklee okl.h Lease App IA Authoring
  --------------------------------------------------------------------
  -- Check to see if the contract was copy from a lease app
  --------------------------------------------------------------------
  OPEN c_lease_app(p_chr_id);
  FETCH c_lease_app INTO l_lease_app_id;
  l_lease_app_found := c_lease_app%FOUND;
  CLOSE c_lease_app;

  IF l_lease_app_id IS NOT NULL THEN
    --------------------------------------------------------------------
    -- Check to see if the lease app has checklist?
    --------------------------------------------------------------------
    OPEN c_lease_app_list_exists(l_lease_app_id);
    FETCH c_lease_app_list_exists INTO l_dummy;
    l_lease_app_list_found := c_lease_app_list_exists%FOUND;
    CLOSE c_lease_app_list_exists;

  END IF;

  IF l_lease_app_found  AND l_lease_app_list_found THEN
    --------------------------------------------------------------------
    -- Create Checkist header
    --------------------------------------------------------------------
    lp_clhv_rec.CHECKLIST_OBJ_ID := p_chr_id;
    lp_clhv_rec.CHECKLIST_OBJ_TYPE_CODE := G_CONTRACT;
    -- set to Active directly if the object was copy from a Lease Application
    lp_clhv_rec.END_DATE := sysdate + 36500; -- set a big end date
    lp_clhv_rec.STATUS_CODE := G_ACTIVE;

    create_checklist_inst_hdr(
          p_api_version    => p_api_version,
          p_init_msg_list  => p_init_msg_list,
          x_return_status  => x_return_status,
          x_msg_count      => x_msg_count,
          x_msg_data       => x_msg_data,
          p_clhv_rec       => lp_clhv_rec,
          x_clhv_rec       => lx_clhv_rec);

    If (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (x_return_status = OKC_API.G_RET_STS_ERROR) then
      raise OKC_API.G_EXCEPTION_ERROR;
    End If;

    --------------------------------------------------------------------
    -- Create Checkist details
    --------------------------------------------------------------------
    i := 0;
    FOR r_this_row IN c_chk_lease_app(l_lease_app_id) LOOP

      lp_cldv_tbl(i).CKL_ID := lx_clhv_rec.ID;
      lp_cldv_tbl(i).TODO_ITEM_CODE := r_this_row.todo_item_code;
      lp_cldv_tbl(i).MANDATORY_FLAG := r_this_row.mandatory_flag;
--      lp_clhv_tbl(i).ADMIN_NOTE := r_this_row.todo_item_code;
      lp_cldv_tbl(i).USER_NOTE := r_this_row.user_note;
--      lp_clhv_tbl(i).DNZ_CHECKLIST_OBJ_ID := p_chr_id;
      lp_cldv_tbl(i).FUNCTION_ID := r_this_row.function_id;
      lp_cldv_tbl(i).INST_CHECKLIST_TYPE := r_this_row.inst_checklist_type;
      i := i + 1;
    END LOOP;

    create_checklist_inst_dtl(
          p_api_version    => p_api_version,
          p_init_msg_list  => p_init_msg_list,
          x_return_status  => x_return_status,
          x_msg_count      => x_msg_count,
          x_msg_data       => x_msg_data,
          p_cldv_tbl       => lp_cldv_tbl,
          x_cldv_tbl       => lx_cldv_tbl);

    If (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (x_return_status = OKC_API.G_RET_STS_ERROR) then
      raise OKC_API.G_EXCEPTION_ERROR;
    End If;

  END IF;

/*** End API body ******************************************************/

  -- Get message count and if count is 1, get message info
	FND_MSG_PUB.Count_And_Get
    (p_count          =>      x_msg_count,
     p_data           =>      x_msg_data);

EXCEPTION
  WHEN OKL_API.G_EXCEPTION_ERROR THEN
    ROLLBACK TO create_contract_checklist;
    x_return_status := OKL_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    ROLLBACK TO create_contract_checklist;
    x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OTHERS THEN
	ROLLBACK TO create_contract_checklist;
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR ;
      OKL_API.Set_Message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_UNEXPECTED_ERROR,
                          p_token1        => G_SQLCODE_TOKEN,
                          p_token1_value  => SQLCODE,
                          p_token2        => G_SQLERRM_TOKEN,
                          p_token2_value  => SQLERRM);
      FND_MSG_PUB.Count_And_Get
        (p_count         =>      x_msg_count,
         p_data          =>      x_msg_data);

end create_contract_checklist;
-- END: June 06, 2005 cklee: Modification for okl.h lease app enhancement

  ------------------------------------------------------------------------------
  -- PROCEDURE upd_chklst_dtl_apl_flag
  ------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : upd_chklst_dtl_apl_flag
  -- Description     : This procedure updates the appeal flag for the given
  --                   table of checklist detail items
  -- Business Rules  : This procedure updates the appeal flag for the given
  --                   table of checklist detail itema
  -- Parameters      :
  -- Version         : 1.0
  -- History         : 03-Apr-2006 PAGARG created Bug 4872271
  --
  -- End of comments
  PROCEDURE upd_chklst_dtl_apl_flag(
            p_api_version        IN  NUMBER,
            p_init_msg_list      IN  VARCHAR2,
            p_cldv_tbl           IN  CLDV_TBL_TYPE,
            x_cldv_tbl           OUT NOCOPY CLDV_TBL_TYPE,
            x_return_status      OUT NOCOPY VARCHAR2,
            x_msg_count          OUT NOCOPY NUMBER,
            x_msg_data           OUT NOCOPY VARCHAR2)
  IS
    -- Variables Declarations
    l_api_version     CONSTANT NUMBER       DEFAULT 1.0;
    l_api_name        CONSTANT VARCHAR2(30) DEFAULT 'UPD_CHKLST_DTL_APL_FLAG';
    l_return_status            VARCHAR2(1);
    i                          NUMBER;
  BEGIN
    l_return_status := OKL_API.G_RET_STS_SUCCESS;
    L_MODULE := 'OKL.PLSQL.OKL_CHECKLIST_PVT.UPD_CHKLST_DTL_APL_FLAG';

    -- check for logging on PROCEDURE level
    L_DEBUG_ENABLED := NVL(OKL_DEBUG_PUB.CHECK_LOG_ENABLED, 'N');
    IS_DEBUG_PROCEDURE_ON := NVL(OKL_DEBUG_PUB.CHECK_LOG_ON(L_MODULE, FND_LOG.LEVEL_PROCEDURE), FALSE);
    -- check for logging on STATEMENT level
    IS_DEBUG_STATEMENT_ON := NVL(OKL_DEBUG_PUB.CHECK_LOG_ON(L_MODULE, FND_LOG.LEVEL_STATEMENT), FALSE);

    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := OKL_API.START_ACTIVITY(
                           p_api_name      => l_api_name
                          ,p_pkg_name      => G_PKG_NAME
                          ,p_init_msg_list => p_init_msg_list
                          ,l_api_version   => l_api_version
                          ,p_api_version   => p_api_version
                          ,p_api_type      => G_API_TYPE
                          ,x_return_status => l_return_status);

    -- check if activity started successfully
    IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    IF (p_cldv_tbl.COUNT > 0)
    THEN
      i := p_cldv_tbl.FIRST;
      LOOP
        l_return_status := validate_appeal_flag(p_cldv_tbl(i), G_UPDATE_MODE);
        --- Store the highest degree of error
        IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR)THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR)THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
        EXIT WHEN (i = p_cldv_tbl.LAST);
        i := p_cldv_tbl.NEXT(i);
      END LOOP;
    END IF;

    IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
    THEN
      OKL_DEBUG_PUB.LOG_DEBUG(
          FND_LOG.LEVEL_PROCEDURE
         ,L_MODULE
         ,'begin debug call OKL_CLD_PVT.UPDATE_ROW');
    END IF;

    OKL_CLD_PVT.UPDATE_ROW(
        p_api_version           => p_api_version
       ,p_init_msg_list         => OKL_API.G_FALSE
       ,x_return_status         => l_return_status
       ,x_msg_count             => x_msg_count
       ,x_msg_data              => x_msg_data
       ,p_cldv_tbl              => p_cldv_tbl
       ,x_cldv_tbl              => x_cldv_tbl);

	IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
    THEN
      OKL_DEBUG_PUB.LOG_DEBUG(
          FND_LOG.LEVEL_PROCEDURE
         ,L_MODULE
         ,'end debug call OKL_CLD_PVT.UPDATE_ROW');
    END IF;

    -- write to log
    IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_STATEMENT_ON) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(
          FND_LOG.LEVEL_STATEMENT
         ,L_MODULE || ' Result of OKL_CLD_PVT.UPDATE_ROW'
         ,'l_return_status ' || l_return_status);
    END IF; -- end of statement level debug

    IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR)THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR)THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    x_return_status := l_return_status;
    OKL_API.END_ACTIVITY(
         x_msg_count    => x_msg_count
        ,x_msg_data	    => x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => G_API_TYPE);

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => G_API_TYPE);
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OTHERS',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => G_API_TYPE);
  END upd_chklst_dtl_apl_flag;

END OKL_CHECKLIST_PVT;

/
