--------------------------------------------------------
--  DDL for Package Body OKL_CREDIT_CHECKLIST_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_CREDIT_CHECKLIST_PVT" AS
/* $Header: OKLRCLCB.pls 120.6 2005/09/23 12:18:27 varangan noship $ */
----------------------------------------------------------------------------
-- Global Message Constants
----------------------------------------------------------------------------
      G_STS_CODE  VARCHAR2(10) := 'NEW';
 G_CREDIT_CHKLST_TPL CONSTANT VARCHAR2(30) := 'LACCLH';
 G_CREDIT_CHKLST_TPL_RULE1 CONSTANT VARCHAR2(30) := 'LACCLT';
 G_CREDIT_CHKLST_TPL_RULE2 CONSTANT VARCHAR2(30) := 'LACCLD';
 G_CREDIT_CHKLST_TPL_RULE3 CONSTANT VARCHAR2(30) := 'LACLFD';
 G_CREDIT_CHKLST_TPL_RULE4 CONSTANT VARCHAR2(30) := 'LACLFM';
 G_RGP_TYPE CONSTANT VARCHAR2(30) := 'KRG';

 G_INSERT_MODE  VARCHAR2(10) := 'INSERT';
 G_UPDATE_MODE  VARCHAR2(10) := 'UPDATE';
 G_DELETE_MODE  VARCHAR2(10) := 'DELETE';

----------------------------------------------------------------------------
-- Procedures and Functions
----------------------------------------------------------------------------
--start:  May-10-2005  cklee okl.h Lease Application ER for Authoring
  --------------------------------------------------------------------------
  ----- Validate Function Id
  --------------------------------------------------------------------------
  FUNCTION validate_function_id(
   p_rulv_rec     rulv_rec_type,
   p_type         varchar2
  ) RETURN VARCHAR2
  IS
    l_return_status   VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_dummy  number;

    l_row_not_found boolean := false;
    l_function_id varchar2(100);

  CURSOR c_fun (p_id number)
    IS
    SELECT 1
      FROM OKL_DATA_SRC_FNCTNS_V fun
     WHERE fun.id = p_id
    ;

  BEGIN

  IF p_type is not null and p_type <> 'NONE' THEN

    IF p_type = 'ACTIVATION' THEN
      l_function_id := p_rulv_rec.RULE_INFORMATION9;
    ELSIF p_type = 'FUNDING' THEN
      l_function_id := p_rulv_rec.RULE_INFORMATION6;
    END IF;
    -- FK check
    -- check only if object exists
    IF (l_function_id IS NOT NULL AND
        l_function_id <> OKL_API.G_MISS_CHAR)
    THEN

      OPEN c_fun(l_function_id);
      FETCH c_fun INTO l_dummy;
      l_row_not_found := c_fun%NOTFOUND;
      CLOSE c_fun;

      IF (l_row_not_found) THEN
        OKL_API.Set_Message(p_app_name     => G_APP_NAME,
                            p_msg_name     => G_INVALID_VALUE,
                            p_token1       => G_COL_NAME_TOKEN,
                            p_token1_value => 'FUNCTION_ID');

        RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;
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
  ----- Validate Checklist Type
  --------------------------------------------------------------------------
  FUNCTION validate_checklist_type(
   p_rulv_rec     rulv_rec_type,
   p_type         varchar2,
   p_mode         varchar2
  ) RETURN VARCHAR2
  IS
    l_return_status   VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_dummy  number;

    l_row_not_found boolean := false;
    l_checklist_type varchar2(30);

  CURSOR c_lok (p_lookup_code varchar2, p_type varchar2)
    IS
    SELECT 1
      FROM fnd_lookups lok
     WHERE lookup_type = 'OKL_CHECKLIST_TYPE'
     and lok.enabled_flag = 'Y'
     and lok.lookup_code = p_type
     and lok.lookup_code = p_lookup_code
    ;

  BEGIN

  IF p_type is not null and p_type <> 'NONE' THEN

    IF p_type = 'ACTIVATION' THEN
      l_checklist_type := p_rulv_rec.RULE_INFORMATION10;
    ELSIF p_type = 'FUNDING' THEN
      l_checklist_type := p_rulv_rec.RULE_INFORMATION7;
    END IF;

    IF (p_mode = G_INSERT_MODE) THEN

      -- column is required:
      IF (l_checklist_type IS NULL) OR
         (l_checklist_type = OKL_API.G_MISS_CHAR)
      THEN
        OKL_API.Set_Message(p_app_name     => G_APP_NAME,
                            p_msg_name     => G_REQUIRED_VALUE,
                            p_token1       => G_COL_NAME_TOKEN,
                            p_token1_value => 'CHECKLIST_TYPE');
        RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;

    END IF;

    -- FK check
    -- check only if object exists
    IF (l_checklist_type IS NOT NULL AND
        l_checklist_type <> OKL_API.G_MISS_CHAR)
    THEN

      OPEN c_lok(l_checklist_type, p_type);
      FETCH c_lok INTO l_dummy;
      l_row_not_found := c_lok%NOTFOUND;
      CLOSE c_lok;

      IF (l_row_not_found) THEN
        OKL_API.Set_Message(p_app_name     => G_APP_NAME,
                            p_msg_name     => G_INVALID_VALUE,
                            p_token1       => G_COL_NAME_TOKEN,
                            p_token1_value => 'CHECKLIST_TYPE');

        RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;
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
  ----- Validate to-do item
  --------------------------------------------------------------------------
  FUNCTION validate_todo_item(
   p_rulv_rec     rulv_rec_type,
   p_type         varchar2,
   p_mode         varchar2
  ) RETURN VARCHAR2
  IS
    l_return_status   VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_dummy  number;

    l_row_not_found boolean := false;
    l_todo_item varchar2(30);

  CURSOR c_lok (p_lookup_code varchar2)
    IS
    SELECT 1
      FROM fnd_lookups lok
     WHERE lookup_type = 'OKL_TODO_ITEMS'
     and lok.enabled_flag = 'Y'
     and lok.lookup_code = p_lookup_code
    ;

  BEGIN

  IF p_type is not null and p_type <> 'NONE' THEN

    IF (p_mode = G_INSERT_MODE) THEN

      -- column is required:
      IF (p_rulv_rec.RULE_INFORMATION1 IS NULL) OR
         (p_rulv_rec.RULE_INFORMATION1 = OKL_API.G_MISS_CHAR)
      THEN
        OKL_API.Set_Message(p_app_name     => G_APP_NAME,
                            p_msg_name     => G_REQUIRED_VALUE,
                            p_token1       => G_COL_NAME_TOKEN,
                            p_token1_value => 'TODO_ITEM');
        RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;

    END IF;

    -- FK check
    -- check only if object exists
    IF (p_rulv_rec.RULE_INFORMATION1 IS NOT NULL AND
        p_rulv_rec.RULE_INFORMATION1 <> OKL_API.G_MISS_CHAR)
    THEN

      OPEN c_lok(p_rulv_rec.RULE_INFORMATION1);
      FETCH c_lok INTO l_dummy;
      l_row_not_found := c_lok%NOTFOUND;
      CLOSE c_lok;

      IF (l_row_not_found) THEN
        OKL_API.Set_Message(p_app_name     => G_APP_NAME,
                            p_msg_name     => G_INVALID_VALUE,
                            p_token1       => G_COL_NAME_TOKEN,
                            p_token1_value => 'TODO_ITEM');

        RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;
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
  ----- Validate duplicated to-do item, function_id
  --------------------------------------------------------------------------
  FUNCTION validate_dup_item(
   p_rulv_rec     rulv_rec_type,
   p_type         varchar2
  ) RETURN VARCHAR2
  IS
    l_return_status   VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_count  number := 0;
    l_row_found boolean := false;
    l_dummy number;
    l_item varchar2(30);
    l_function_id varchar2(100);
    l_chr_id number;


  CURSOR c_unq_crd (p_chr_id number)
    IS
    SELECT 1
      FROM okl_credit_checklists_uv lst
     WHERE lst.khr_id = p_chr_id
     group by lst.todo_item_code, lst.function_id
     having count(1) > 1
    ;

  CURSOR c_unq_fun (p_chr_id number)
    IS
    SELECT 1
      FROM okl_crd_fund_checklists_tpl_uv lst
     WHERE lst.khr_id = p_chr_id
     group by lst.todo_item_code, lst.function_id
     having count(1) > 1
    ;


  BEGIN

  IF p_type is not null and p_type <> 'NONE' AND
     p_rulv_rec.dnz_chr_id is not null and p_rulv_rec.dnz_chr_id <> OKL_API.G_MISS_NUM THEN

    l_chr_id := p_rulv_rec.dnz_chr_id;

    IF p_type = 'ACTIVATION' THEN
      OPEN c_unq_crd(l_chr_id);
      FETCH c_unq_crd INTO l_dummy;
      l_row_found := c_unq_crd%FOUND;
      CLOSE c_unq_crd;

    ELSIF p_type = 'FUNDING' THEN
      OPEN c_unq_fun(l_chr_id);
      FETCH c_unq_fun INTO l_dummy;
      l_row_found := c_unq_fun%FOUND;
      CLOSE c_unq_fun;

    END IF;

    IF (l_row_found) THEN
      OKL_API.Set_Message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_NOT_UNIQUE,
                          p_token1       => G_COL_NAME_TOKEN,
                          p_token1_value => 'The combinations of the Checklist Item and the Function');

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

--end:  May-10-2005  cklee okl.h Lease Application ER for Authoring

  --------------------------------------------------------------------------
  ----- Validate Short Description
  --------------------------------------------------------------------------
  FUNCTION validate_short_desc(
   p_rulv_rec     rulv_rec_type,
   p_type         varchar2
  ) RETURN VARCHAR2
  IS
    l_return_status   VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  BEGIN

  IF p_type is not null and p_type = 'NONE' THEN

    IF (p_rulv_rec.RULE_INFORMATION4 IS NOT NULL AND
        p_rulv_rec.RULE_INFORMATION4 <> OKL_API.G_MISS_CHAR)
    THEN

      IF (length(p_rulv_rec.RULE_INFORMATION4) > 450) THEN

        OKL_API.Set_Message(p_app_name     => G_APP_NAME,
                          p_msg_name     => 'OKL_LLA_EXCEED_MAXIMUM_LENGTH',
                          p_token1       => 'MAX_CHARS',
                          p_token1_value => '450',
                          p_token2       => 'COL_NAME',
                          p_token2_value => 'Short Description');

        RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;
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
  ----- Validate Effective From
  --------------------------------------------------------------------------
  FUNCTION validate_effective_from(
   p_rulv_rec     rulv_rec_type,
   p_type         varchar2
  ) RETURN VARCHAR2
  IS
    l_return_status   VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_dummy  number;
    l_effective_date   date;

  BEGIN

  IF p_type is not null and p_type = 'NONE' THEN

    IF (p_rulv_rec.RULE_INFORMATION1 IS NOT NULL AND
        p_rulv_rec.RULE_INFORMATION1 <> TO_CHAR(OKL_API.G_MISS_DATE))
    THEN

      -- check date format
      BEGIN
        l_effective_date := to_date(p_rulv_rec.rule_information1,G_UI_DATE_MASK);
      EXCEPTION
        WHEN OTHERS THEN
          OKL_API.Set_Message(p_app_name     => G_APP_NAME,
                              p_msg_name     => G_OKL_LLA_INVALID_DATE_FORMAT,
                              p_token1       => 'DATE_FORMAT',
                              p_token1_value => G_UI_DATE_MASK,
                              p_token2       => 'COL_NAME',
                              p_token2_value => 'Effective From');

          RAISE G_EXCEPTION_HALT_VALIDATION;
      END;
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
   p_rulv_rec     rulv_rec_type,
   p_type         varchar2
  ) RETURN VARCHAR2
  IS
    l_return_status   VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_dummy  number;
    l_effective_date   date;

  BEGIN

  IF p_type is not null and p_type = 'NONE' THEN

    --1. column is required:
    IF (p_rulv_rec.RULE_INFORMATION2 IS NULL OR
        p_rulv_rec.RULE_INFORMATION2 = TO_CHAR(OKL_API.G_MISS_DATE,G_UI_DATE_MASK))
    THEN

        OKL_API.Set_Message(p_app_name     => G_APP_NAME,
                            p_msg_name     => G_REQUIRED_VALUE,
                            p_token1       => G_COL_NAME_TOKEN,
                            p_token1_value => 'Effective To');
        RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;


    -- 2. check date format
    BEGIN
      l_effective_date := to_date(p_rulv_rec.rule_information2,G_UI_DATE_MASK);
    EXCEPTION
      WHEN OTHERS THEN
        OKL_API.Set_Message(p_app_name     => G_APP_NAME,
                            p_msg_name     => G_OKL_LLA_INVALID_DATE_FORMAT,
                            p_token1       => 'DATE_FORMAT',
                            p_token1_value => G_UI_DATE_MASK,
                            p_token2       => 'COL_NAME',
                            p_token2_value => 'Effective To');

        RAISE G_EXCEPTION_HALT_VALIDATION;
    END;

    -- 3. check vs sysdate
    IF (trunc(l_effective_date) < trunc(sysdate))
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

  --------------------------------------------------------------------------
  ----- Validate Effective from and Effective To: after image
  --------------------------------------------------------------------------
  FUNCTION validate_effective_date(
   p_rulv_rec     rulv_rec_type,
   p_type         varchar2
  ) RETURN VARCHAR2
  IS
    l_return_status   VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_dummy  number;
    l_row_found boolean := false;

cursor c_date(p_id number)
  is select 1
FROM
  OKC_RULES_B rulh
where rulh.RULE_INFORMATION1 is not null
and trunc(FND_DATE.CANONICAL_TO_DATE(rulh.RULE_INFORMATION1)) > trunc(FND_DATE.CANONICAL_TO_DATE(rulh.RULE_INFORMATION2))
--and rulh.rule_information_category = 'LACLFM'
and rulh.id = p_id;

/*
from okl_crd_fund_chklst_tpl_hdr_uv fcl
where fcl.effective_from is not null
and trunc(fcl.effective_from) > trunc(fcl.effective_to)
and fcl.id = p_id
*/

  BEGIN

  IF p_type is not null and p_type = 'NONE' THEN

    open c_date(p_rulv_rec.id);
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
  FUNCTION validate_header_attributes(
    p_rulv_rec     rulv_rec_type,
    p_mode         varchar2,
    p_type         varchar2
  ) RETURN VARCHAR2
  IS
    l_return_status   VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    x_return_status   VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;

  BEGIN

    -- Do formal attribute validation:
    l_return_status := validate_short_desc(p_rulv_rec => p_rulv_rec,
                                           p_type     => p_type);
    --- Store the highest degree of error
    IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        x_return_status := l_return_status;
      END IF;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    l_return_status := validate_effective_from(p_rulv_rec => p_rulv_rec,
                                               p_type     => p_type);
    --- Store the highest degree of error
    IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        x_return_status := l_return_status;
      END IF;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    l_return_status := validate_effective_to(p_rulv_rec => p_rulv_rec,
                                             p_type     => p_type);
    --- Store the highest degree of error
    IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        x_return_status := l_return_status;
      END IF;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
--start:  May-10-2005  cklee okl.h Lease Application ER for Authoring
    l_return_status := validate_function_id(p_rulv_rec => p_rulv_rec,
                                            p_type     => p_type);
    --- Store the highest degree of error
    IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        x_return_status := l_return_status;
      END IF;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    l_return_status := validate_checklist_type(p_rulv_rec => p_rulv_rec,
                                               p_type     => p_type,
                                               p_mode     => p_mode);
    --- Store the highest degree of error
    IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        x_return_status := l_return_status;
      END IF;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    l_return_status := validate_todo_item(p_rulv_rec => p_rulv_rec,
                                          p_type     => p_type,
                                          p_mode     => p_mode);
    --- Store the highest degree of error
    IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        x_return_status := l_return_status;
      END IF;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

--end:  May-10-2005  cklee okl.h Lease Application ER for Authoring

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
    p_rulv_rec     rulv_rec_type,
    p_type         varchar2
  ) RETURN VARCHAR2
  IS
    l_return_status   VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    x_return_status   VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;

  BEGIN

    l_return_status := validate_effective_date(p_rulv_rec => p_rulv_rec,
                                               p_type     => p_type);
    --- Store the highest degree of error
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
  END validate_hdr_attr_aftimg;

----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : copy_rulv_rec
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
  PROCEDURE copy_rulv_rec(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_rulv_rec                     IN  rulv_rec_type
   ,p_rulv_migr_rec                OUT NOCOPY okl_rule_pub.rulv_rec_type
   ,p_type                         IN  varchar2
   ,p_mode                         IN  varchar2
)
 is
  l_api_name         CONSTANT VARCHAR2(30) := 'copy_rulv_rec';
  l_api_version      CONSTANT NUMBER       := 1.0;
  i                  NUMBER;
  l_return_status    VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  l_rgp_id number;
  l_object1_id1 varchar2(100);

cursor c_rgp_id (chr_id number)
is
select id
from okc_rule_groups_b
where rgd_code = G_CREDIT_CHKLST_TPL--'LACCLH'
and dnz_chr_id = chr_id;

cursor c_obj_id (chr_id number)
is
select id
from okc_rules_b
where RULE_INFORMATION_CATEGORY = G_CREDIT_CHKLST_TPL_RULE4--'LACLFM'
and dnz_chr_id = chr_id;


begin
  -- Set API savepoint
  SAVEPOINT copy_rulv_rec;

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

--
-- validate
--

    l_return_status := validate_header_attributes(p_rulv_rec => p_rulv_rec,
                                                  p_type     => p_type,
                                                  p_mode     => p_mode);
    --- Store the highest degree of error
    IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        x_return_status := l_return_status;
      END IF;
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;

    p_rulv_migr_rec.id := p_rulv_rec.id;

    p_rulv_migr_rec.rule_information1 := p_rulv_rec.rule_information1;

--  start : 28-Feb-05 cklee -- fixed bug#4056212
/*    IF (p_rulv_rec.rule_information2 = 'Y' or p_rulv_rec.rule_information2 = 'N') THEN
      p_rulv_migr_rec.rule_information2 := p_rulv_rec.rule_information2;
    ELSE
      p_rulv_migr_rec.rule_information2 := 'N';
    END IF;

    IF (p_rulv_rec.rule_information3 = 'Y' or p_rulv_rec.rule_information3 = 'N') THEN
      p_rulv_migr_rec.rule_information3 := p_rulv_rec.rule_information3;
    ELSE
      p_rulv_migr_rec.rule_information3 := 'N';
    END IF;
*/
--  end : 28-Feb-05 cklee -- fixed bug#4056212
    p_rulv_migr_rec.rule_information2 := p_rulv_rec.rule_information2;
    p_rulv_migr_rec.rule_information3 := p_rulv_rec.rule_information3;

--start:cklee  May-10-2005  cklee okl.h Lease Application ER for Authoring
    p_rulv_migr_rec.rule_information4 := p_rulv_rec.rule_information4;
    p_rulv_migr_rec.rule_information5 := p_rulv_rec.rule_information5;
    p_rulv_migr_rec.rule_information6 := p_rulv_rec.rule_information6;

    -- set default
    IF p_type = 'ACTIVATION' and
        (p_rulv_rec.rule_information7 not in ('UNDETERMINED', 'PASSED', 'FAILED', 'ERROR') or
         p_rulv_rec.rule_information7 is null or
         p_rulv_rec.rule_information7 = OKL_API.G_MISS_CHAR) THEN
        p_rulv_migr_rec.rule_information7 := 'UNDETERMINED';
    else
        p_rulv_migr_rec.rule_information7 := p_rulv_rec.rule_information7;
    END IF;

    IF p_type = 'ACTIVATION' THEN
      p_rulv_migr_rec.rule_information8 := p_rulv_rec.rule_information8;
      p_rulv_migr_rec.rule_information9 := p_rulv_rec.rule_information9;
      p_rulv_migr_rec.rule_information10 := p_rulv_rec.rule_information10;
    END IF;

    IF p_mode = G_INSERT_MODE THEN
      OPEN c_rgp_id(p_rulv_rec.DNZ_CHR_ID);
      FETCH c_rgp_id into l_rgp_id;
      CLOSE c_rgp_id;

      p_rulv_migr_rec.DNZ_CHR_ID := p_rulv_rec.DNZ_CHR_ID;
      p_rulv_migr_rec.RGP_ID := l_rgp_id;
      IF p_type = 'ACTIVATION' THEN
        p_rulv_migr_rec.RULE_INFORMATION_CATEGORY :=  G_CREDIT_CHKLST_TPL_RULE2;-- 'LACCLD'
      ELSIF p_type = 'FUNDING' THEN

        OPEN c_obj_id(p_rulv_rec.DNZ_CHR_ID);
        FETCH c_obj_id into l_object1_id1;
        CLOSE c_obj_id;

        p_rulv_migr_rec.OBJECT1_ID1 :=  l_object1_id1;
        p_rulv_migr_rec.OBJECT1_ID2 :=  '#';

        p_rulv_migr_rec.RULE_INFORMATION_CATEGORY :=  G_CREDIT_CHKLST_TPL_RULE3;-- 'LACLFD'
      END IF;
      p_rulv_migr_rec.STD_TEMPLATE_YN := 'N';
      p_rulv_migr_rec.WARN_YN := 'N';

    END IF;
--end:cklee  May-10-2005  cklee okl.h Lease Application ER for Authoring


/*** End API body ******************************************************/

  -- Get message count and if count is 1, get message info
	FND_MSG_PUB.Count_And_Get
    (p_count          =>      x_msg_count,
     p_data           =>      x_msg_data);

EXCEPTION
  WHEN OKL_API.G_EXCEPTION_ERROR THEN
    ROLLBACK TO copy_rulv_rec;
    x_return_status := OKL_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    ROLLBACK TO copy_rulv_rec;
    x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OTHERS THEN
	ROLLBACK TO copy_rulv_rec;
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
end;
----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : copy_rulv_tbl
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
  PROCEDURE copy_rulv_tbl(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_rulv_tbl                     IN  rulv_tbl_type
   ,p_rulv_migr_tbl                OUT NOCOPY okl_rule_pub.rulv_tbl_type
   ,p_type                         IN  varchar2
   ,p_mode                         IN  varchar2)
is
  l_api_name         CONSTANT VARCHAR2(30) := 'copy_rulv_tbl';
  l_api_version      CONSTANT NUMBER       := 1.0;
  i                  NUMBER;
  l_return_status    VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;

begin
  -- Set API savepoint
  SAVEPOINT copy_rulv_tbl;

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

    IF (p_rulv_tbl.COUNT > 0) THEN
      i := p_rulv_tbl.FIRST;
      LOOP

        copy_rulv_rec(
          p_api_version    => p_api_version,
          p_init_msg_list  => p_init_msg_list,
          x_return_status  => x_return_status,
          x_msg_count      => x_msg_count,
          x_msg_data       => x_msg_data,
          p_rulv_rec       => p_rulv_tbl(i),
          p_rulv_migr_rec  => p_rulv_migr_tbl(i),
          p_type           => p_type,
          p_mode           => p_mode
        );

        If (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
          raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
        Elsif (x_return_status = OKC_API.G_RET_STS_ERROR) then
          raise OKC_API.G_EXCEPTION_ERROR;
        End If;

        EXIT WHEN (i = p_rulv_tbl.LAST);
        i := p_rulv_tbl.NEXT(i);
      END LOOP;
    END IF;

/*** End API body ******************************************************/

  -- Get message count and if count is 1, get message info
	FND_MSG_PUB.Count_And_Get
    (p_count          =>      x_msg_count,
     p_data           =>      x_msg_data);

EXCEPTION
  WHEN OKL_API.G_EXCEPTION_ERROR THEN
    ROLLBACK TO copy_rulv_tbl;
    x_return_status := OKL_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    ROLLBACK TO copy_rulv_tbl;
    x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OTHERS THEN
	ROLLBACK TO copy_rulv_tbl;
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
end;

----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : create_credit_chklst
-- Description     : wrapper api for create credit checklists associated
--                   with credit line contract ID
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
 PROCEDURE create_credit_chklst(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_rulv_tbl                     IN  rulv_tbl_type
   ,x_rulv_tbl                     OUT NOCOPY rulv_tbl_type
 )
is
  l_api_name         CONSTANT VARCHAR2(30) := 'create_credit_chklst';
  l_api_version      CONSTANT NUMBER       := 1.0;
  i                  NUMBER;
  l_return_status    VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
--  lp_rulv_tbl        rulv_tbl_type := p_rulv_tbl;
--  lx_rulv_tbl        rulv_tbl_type := x_rulv_tbl;
  lp_rulv_tbl        okl_rule_pub.rulv_tbl_type;
  lx_rulv_tbl        okl_rule_pub.rulv_tbl_type;

begin
  -- Set API savepoint
  SAVEPOINT create_credit_chklst;

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
--DBMS_OUTPUT.PUT_LINE('before copy_rulv_tbl');

      copy_rulv_tbl(
          p_api_version    => p_api_version,
          p_init_msg_list  => p_init_msg_list,
          x_return_status  => x_return_status,
          x_msg_count      => x_msg_count,
          x_msg_data       => x_msg_data,
          p_rulv_tbl       => p_rulv_tbl,
          p_rulv_migr_tbl  => lp_rulv_tbl,
          p_type           => 'ACTIVATION',
          p_mode           => G_INSERT_MODE
      );

      If (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
        raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      Elsif (x_return_status = OKC_API.G_RET_STS_ERROR) then
        raise OKC_API.G_EXCEPTION_ERROR;
      End If;

--DBMS_OUTPUT.PUT_LINE('after copy_rulv_tbl');
-- validation

      okl_rule_pub.create_rule(
          p_api_version    => p_api_version,
          p_init_msg_list  => p_init_msg_list,
          x_return_status  => x_return_status,
          x_msg_count      => x_msg_count,
          x_msg_data       => x_msg_data,
          p_rulv_tbl       => lp_rulv_tbl,
          x_rulv_tbl       => lx_rulv_tbl);

      If (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
        raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      Elsif (x_return_status = OKC_API.G_RET_STS_ERROR) then
        raise OKC_API.G_EXCEPTION_ERROR;
      End If;

--start:  May-10-2005  cklee okl.h Lease Application ER for Authoring
    l_return_status := validate_dup_item(p_rulv_rec => p_rulv_tbl(p_rulv_tbl.FIRST),
                                         p_type     => 'ACTIVATION');
    --- Store the highest degree of error
    IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        x_return_status := l_return_status;
      END IF;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
--end:  May-10-2005  cklee okl.h Lease Application ER for Authoring



/*** End API body ******************************************************/

  -- Get message count and if count is 1, get message info
	FND_MSG_PUB.Count_And_Get
    (p_count          =>      x_msg_count,
     p_data           =>      x_msg_data);

EXCEPTION
  WHEN OKL_API.G_EXCEPTION_ERROR THEN
    ROLLBACK TO create_credit_chklst;
    x_return_status := OKL_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    ROLLBACK TO create_credit_chklst;
    x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OTHERS THEN
	ROLLBACK TO create_credit_chklst;
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

end create_credit_chklst;

----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : update_credit_chklst
-- Description     : wrapper api for update credit checklists associated
--                   with credit line contract ID
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
 PROCEDURE update_credit_chklst(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_rulv_tbl                     IN  rulv_tbl_type
   ,x_rulv_tbl                     OUT NOCOPY rulv_tbl_type
 )
is
  l_api_name         CONSTANT VARCHAR2(30) := 'update_credit_chklst';
  l_api_version      CONSTANT NUMBER       := 1.0;
  i                  NUMBER;
  l_return_status    VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
--  lp_rulv_tbl        rulv_tbl_type := p_rulv_tbl;
--  lx_rulv_tbl        rulv_tbl_type := x_rulv_tbl;
  lp_rulv_tbl        okl_rule_pub.rulv_tbl_type;
  lx_rulv_tbl        okl_rule_pub.rulv_tbl_type;

begin
  -- Set API savepoint
  SAVEPOINT update_credit_chklst;

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

--DBMS_OUTPUT.PUT_LINE('before copy_rulv_tbl');

      copy_rulv_tbl(
          p_api_version    => p_api_version,
          p_init_msg_list  => p_init_msg_list,
          x_return_status  => x_return_status,
          x_msg_count      => x_msg_count,
          x_msg_data       => x_msg_data,
          p_rulv_tbl       => p_rulv_tbl,
          p_rulv_migr_tbl  => lp_rulv_tbl,
          p_type           => 'ACTIVATION',
          p_mode           => G_UPDATE_MODE
      );

      If (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
        raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      Elsif (x_return_status = OKC_API.G_RET_STS_ERROR) then
        raise OKC_API.G_EXCEPTION_ERROR;
      End If;

--DBMS_OUTPUT.PUT_LINE('after copy_rulv_tbl');
-- validation

      okl_rule_pub.update_rule(
          p_api_version    => p_api_version,
          p_init_msg_list  => p_init_msg_list,
          x_return_status  => x_return_status,
          x_msg_count      => x_msg_count,
          x_msg_data       => x_msg_data,
          p_rulv_tbl       => lp_rulv_tbl,
          x_rulv_tbl       => lx_rulv_tbl);

      If (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
        raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      Elsif (x_return_status = OKC_API.G_RET_STS_ERROR) then
        raise OKC_API.G_EXCEPTION_ERROR;
      End If;

--start:  May-10-2005  cklee okl.h Lease Application ER for Authoring
    l_return_status := validate_dup_item(p_rulv_rec => p_rulv_tbl(p_rulv_tbl.FIRST),
                                         p_type     => 'ACTIVATION');
    --- Store the highest degree of error
    IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        x_return_status := l_return_status;
      END IF;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
--end:  May-10-2005  cklee okl.h Lease Application ER for Authoring



/*** End API body ******************************************************/

  -- Get message count and if count is 1, get message info
	FND_MSG_PUB.Count_And_Get
    (p_count          =>      x_msg_count,
     p_data           =>      x_msg_data);

EXCEPTION
  WHEN OKL_API.G_EXCEPTION_ERROR THEN
    ROLLBACK TO update_credit_chklst;
    x_return_status := OKL_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    ROLLBACK TO update_credit_chklst;
    x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OTHERS THEN
	ROLLBACK TO update_credit_chklst;
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

end update_credit_chklst;

----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : delete_credit_chklst
-- Description     : wrapper api for delete credit checklists associated
--                   with credit line contract ID
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
 PROCEDURE delete_credit_chklst(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_rulv_tbl                     IN  rulv_tbl_type
 )
is
  l_api_name         CONSTANT VARCHAR2(30) := 'delete_credit_chklst';
  l_api_version      CONSTANT NUMBER       := 1.0;
  i                  NUMBER;
  l_return_status    VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
--  lp_rulv_tbl        rulv_tbl_type := p_rulv_tbl;
--  lx_rulv_tbl        rulv_tbl_type := x_rulv_tbl;
  lp_rulv_tbl        okl_rule_pub.rulv_tbl_type;
  lx_rulv_tbl        okl_rule_pub.rulv_tbl_type;

begin
  -- Set API savepoint
  SAVEPOINT delete_credit_chklst;

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
--DBMS_OUTPUT.PUT_LINE('before copy_rulv_tbl');

      copy_rulv_tbl(
          p_api_version    => p_api_version,
          p_init_msg_list  => p_init_msg_list,
          x_return_status  => x_return_status,
          x_msg_count      => x_msg_count,
          x_msg_data       => x_msg_data,
          p_rulv_tbl       => p_rulv_tbl,
          p_rulv_migr_tbl  => lp_rulv_tbl,
          p_type           => null,
          p_mode           => G_DELETE_MODE
      );

      If (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
        raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      Elsif (x_return_status = OKC_API.G_RET_STS_ERROR) then
        raise OKC_API.G_EXCEPTION_ERROR;
      End If;

--DBMS_OUTPUT.PUT_LINE('after copy_rulv_tbl');

      okl_rule_pub.delete_rule(
          p_api_version    => p_api_version,
          p_init_msg_list  => p_init_msg_list,
          x_return_status  => x_return_status,
          x_msg_count      => x_msg_count,
          x_msg_data       => x_msg_data,
          p_rulv_tbl       => lp_rulv_tbl);

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
    ROLLBACK TO delete_credit_chklst;
    x_return_status := OKL_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    ROLLBACK TO delete_credit_chklst;
    x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OTHERS THEN
	ROLLBACK TO delete_credit_chklst;
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

end delete_credit_chklst;

----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : approve_credit_chklst
-- Description     : set credit line checklist sttaus to "Active".
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
 PROCEDURE approve_credit_chklst(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_rulv_rec                     IN  rulv_rec_type
 )
is
  l_api_name         CONSTANT VARCHAR2(30) := 'approve_credit_chklst';
  l_api_version      CONSTANT NUMBER       := 1.0;
  i                  NUMBER;
  l_return_status    VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;

  lp_rulv_tbl        okl_rule_pub.rulv_tbl_type;
  lx_rulv_tbl        okl_rule_pub.rulv_tbl_type;
  l_id               number;

cursor c_ids (p_chr_id okc_k_headers_b.id%TYPE)
  is
select a.id
from okc_rules_b a
where a.dnz_chr_id = p_chr_id
and   a.RULE_INFORMATION_CATEGORY =	G_CREDIT_CHKLST_TPL_RULE2--'LACCLD'
;


begin
  -- Set API savepoint
  SAVEPOINT approve_credit_chklst;

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

  open c_ids(p_rulv_rec.dnz_chr_id);
  i := 0;
  loop

    fetch c_ids into l_id;
    exit when c_ids%NOTFOUND;

    lp_rulv_tbl(i).ID := l_id;
    lp_rulv_tbl(i).RULE_INFORMATION5 := 'ACTIVE';

    i := i+1;
  end loop;

-- validation

      okl_rule_pub.update_rule(
          p_api_version    => p_api_version,
          p_init_msg_list  => p_init_msg_list,
          x_return_status  => x_return_status,
          x_msg_count      => x_msg_count,
          x_msg_data       => x_msg_data,
          p_rulv_tbl       => lp_rulv_tbl,
          x_rulv_tbl       => lx_rulv_tbl);

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
    ROLLBACK TO approve_credit_chklst;
    x_return_status := OKL_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    ROLLBACK TO approve_credit_chklst;
    x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OTHERS THEN
	ROLLBACK TO approve_credit_chklst;
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

end approve_credit_chklst;
----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : update_fund_chklst_tpl_hdr
-- Description     : wrapper api for update funding checklists template header associated
--                   with credit line contract ID
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
 PROCEDURE update_fund_chklst_tpl_hdr(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_rulv_tbl                     IN  rulv_tbl_type
   ,x_rulv_tbl                     OUT NOCOPY rulv_tbl_type
 )
is
  l_api_name         CONSTANT VARCHAR2(30) := 'update_fund_chklst_tpl_hdr_pvt';
  l_api_version      CONSTANT NUMBER       := 1.0;
  i                  NUMBER;
  l_return_status    VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
--  lp_rulv_tbl        rulv_tbl_type := p_rulv_tbl;
--  lx_rulv_tbl        rulv_tbl_type := x_rulv_tbl;
  lp_rulv_tbl        okl_rule_pub.rulv_tbl_type;
  lx_rulv_tbl        okl_rule_pub.rulv_tbl_type;

begin
  -- Set API savepoint
  SAVEPOINT update_fund_chklst_tpl_hdr;

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
/*** End API body ******************************************************/

  -- Get message count and if count is 1, get message info
	FND_MSG_PUB.Count_And_Get
    (p_count          =>      x_msg_count,
     p_data           =>      x_msg_data);

EXCEPTION
  WHEN OKL_API.G_EXCEPTION_ERROR THEN
    ROLLBACK TO update_fund_chklst_tpl_hdr;
    x_return_status := OKL_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    ROLLBACK TO update_fund_chklst_tpl_hdr;
    x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OTHERS THEN
	ROLLBACK TO update_fund_chklst_tpl_hdr;
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

end update_fund_chklst_tpl_hdr;

----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : update_fund_chklst_tpl_hdr
-- Description     : wrapper api for update funding checklists template header associated
--                   with credit line contract ID
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
 PROCEDURE update_fund_chklst_tpl_hdr(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_rulv_rec                     IN  rulv_rec_type
   ,x_rulv_rec                     OUT NOCOPY rulv_rec_type
 )
is
  l_api_name         CONSTANT VARCHAR2(30) := 'update_fund_chklst_tpl_hdr_pvt';
  l_api_version      CONSTANT NUMBER       := 1.0;
  i                  NUMBER;
  l_return_status    VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
--  lp_rulv_tbl        rulv_tbl_type := p_rulv_tbl;
--  lx_rulv_tbl        rulv_tbl_type := x_rulv_tbl;
  lp_rulv_rec        okl_rule_pub.rulv_rec_type;
  lx_rulv_rec        okl_rule_pub.rulv_rec_type;

begin
  -- Set API savepoint
  SAVEPOINT update_fund_chklst_tpl_hdr;

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

--
-- 1. validate
--
    l_return_status := validate_header_attributes(p_rulv_rec => p_rulv_rec,
                                                  p_type     => 'NONE',
                                                  p_mode     => G_UPDATE_MODE); -- funding checklist header
    --- Store the highest degree of error
    IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        x_return_status := l_return_status;
      END IF;
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;

--
-- copy from local record to rule record
--
    lp_rulv_rec.id := p_rulv_rec.id;

    -- effective from
    IF (p_rulv_rec.rule_information1 IS NOT NULL AND
        p_rulv_rec.rule_information1 <> TO_CHAR(OKC_API.G_MISS_DATE,G_UI_DATE_MASK) ) THEN
      lp_rulv_rec.rule_information1 := FND_DATE.date_to_canonical(to_date(p_rulv_rec.rule_information1,G_UI_DATE_MASK));
    END IF;

    -- effective to
    IF (p_rulv_rec.rule_information2 IS NOT NULL AND
        p_rulv_rec.rule_information2 <> TO_CHAR(OKC_API.G_MISS_DATE,G_UI_DATE_MASK) ) THEN
      lp_rulv_rec.rule_information2 := FND_DATE.date_to_canonical(to_date(p_rulv_rec.rule_information2,G_UI_DATE_MASK));
    END IF;

    -- status
    IF (p_rulv_rec.rule_information3 IS NOT NULL AND
        p_rulv_rec.rule_information3 <> OKC_API.G_MISS_CHAR ) THEN
      lp_rulv_rec.rule_information3 := p_rulv_rec.rule_information3;
    END IF;

    lp_rulv_rec.rule_information4 := p_rulv_rec.rule_information4; -- description

--
-- call rule api
--
      okl_rule_pub.update_rule(
          p_api_version    => p_api_version,
          p_init_msg_list  => p_init_msg_list,
          x_return_status  => x_return_status,
          x_msg_count      => x_msg_count,
          x_msg_data       => x_msg_data,
          p_rulv_rec       => lp_rulv_rec,
          x_rulv_rec       => lx_rulv_rec);

      If (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
        raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      Elsif (x_return_status = OKC_API.G_RET_STS_ERROR) then
        raise OKC_API.G_EXCEPTION_ERROR;
      End If;

--
-- validate after image
--
    l_return_status := validate_hdr_attr_aftimg(p_rulv_rec => p_rulv_rec,
                                                p_type     => 'NONE');
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
    ROLLBACK TO update_fund_chklst_tpl_hdr;
    x_return_status := OKL_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    ROLLBACK TO update_fund_chklst_tpl_hdr;
    x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OTHERS THEN
	ROLLBACK TO update_fund_chklst_tpl_hdr;
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

end update_fund_chklst_tpl_hdr;

----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : update_funding_chklst_tpl
-- Description     : wrapper api for update funding checklists template associated
--                   with credit line contract ID
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
 PROCEDURE update_funding_chklst_tpl(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_rulv_tbl                     IN  rulv_tbl_type
   ,x_rulv_tbl                     OUT NOCOPY rulv_tbl_type
 )
is
  l_api_name         CONSTANT VARCHAR2(30) := 'update_funding_chklst_tpl';
  l_api_version      CONSTANT NUMBER       := 1.0;
  i                  NUMBER;
  l_return_status    VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
--  lp_rulv_tbl        rulv_tbl_type := p_rulv_tbl;
--  lx_rulv_tbl        rulv_tbl_type := x_rulv_tbl;
  lp_rulv_tbl        okl_rule_pub.rulv_tbl_type;
  lx_rulv_tbl        okl_rule_pub.rulv_tbl_type;

begin
  -- Set API savepoint
  SAVEPOINT update_funding_chklst_tpl;

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

--DBMS_OUTPUT.PUT_LINE('before copy_rulv_tbl');

    copy_rulv_tbl(
          p_api_version    => p_api_version,
          p_init_msg_list  => p_init_msg_list,
          x_return_status  => x_return_status,
          x_msg_count      => x_msg_count,
          x_msg_data       => x_msg_data,
          p_rulv_tbl       => p_rulv_tbl,
          p_rulv_migr_tbl  => lp_rulv_tbl,
          p_type           => 'FUNDING',
          p_mode           => G_UPDATE_MODE
    );

      If (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
        raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      Elsif (x_return_status = OKC_API.G_RET_STS_ERROR) then
        raise OKC_API.G_EXCEPTION_ERROR;
      End If;

--DBMS_OUTPUT.PUT_LINE('after copy_rulv_tbl');
-- validation

      okl_rule_pub.update_rule(
          p_api_version    => p_api_version,
          p_init_msg_list  => p_init_msg_list,
          x_return_status  => x_return_status,
          x_msg_count      => x_msg_count,
          x_msg_data       => x_msg_data,
          p_rulv_tbl       => lp_rulv_tbl,
          x_rulv_tbl       => lx_rulv_tbl);

      If (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
        raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      Elsif (x_return_status = OKC_API.G_RET_STS_ERROR) then
        raise OKC_API.G_EXCEPTION_ERROR;
      End If;

--start:  May-10-2005  cklee okl.h Lease Application ER for Authoring
    l_return_status := validate_dup_item(p_rulv_rec => p_rulv_tbl(p_rulv_tbl.FIRST),
                                         p_type     => 'FUNDING');
    --- Store the highest degree of error
    IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        x_return_status := l_return_status;
      END IF;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
--end:  May-10-2005  cklee okl.h Lease Application ER for Authoring



/*** End API body ******************************************************/

  -- Get message count and if count is 1, get message info
	FND_MSG_PUB.Count_And_Get
    (p_count          =>      x_msg_count,
     p_data           =>      x_msg_data);

EXCEPTION
  WHEN OKL_API.G_EXCEPTION_ERROR THEN
    ROLLBACK TO update_funding_chklst_tpl;
    x_return_status := OKL_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    ROLLBACK TO update_funding_chklst_tpl;
    x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OTHERS THEN
	ROLLBACK TO update_funding_chklst_tpl;
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

end update_funding_chklst_tpl;


----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : approve_funding_chklst_tpl
-- Description     : set funding checklists template status to "Active"
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
 PROCEDURE approve_funding_chklst_tpl(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_rulv_rec                     IN  rulv_rec_type
 )
is
  l_api_name         CONSTANT VARCHAR2(30) := 'approve_funding_chklst_tpl';
  l_api_version      CONSTANT NUMBER       := 1.0;
  i                  NUMBER;
  l_return_status    VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;

  lp_rulv_rec        okl_rule_pub.rulv_rec_type;
  lx_rulv_rec        okl_rule_pub.rulv_rec_type;

  l_id               number;

cursor c_tpl_hdr (p_chr_id okc_k_headers_b.id%TYPE)
  is
select a.id
from okc_rules_b a
where a.dnz_chr_id = p_chr_id
and   a.RULE_INFORMATION_CATEGORY =	G_CREDIT_CHKLST_TPL_RULE4--'LACLFM'
;

begin
  -- Set API savepoint
  SAVEPOINT approve_credit_chklst;

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

-- update template header
  open c_tpl_hdr(p_rulv_rec.dnz_chr_id);
  fetch c_tpl_hdr into l_id;
  close c_tpl_hdr;

  lp_rulv_rec.ID := l_id;
  lp_rulv_rec.RULE_INFORMATION3 := 'ACTIVE'; -- status

  okl_rule_pub.update_rule(
          p_api_version    => p_api_version,
          p_init_msg_list  => p_init_msg_list,
          x_return_status  => x_return_status,
          x_msg_count      => x_msg_count,
          x_msg_data       => x_msg_data,
          p_rulv_rec       => lp_rulv_rec,
          x_rulv_rec       => lx_rulv_rec);

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
    ROLLBACK TO approve_funding_chklst_tpl;
    x_return_status := OKL_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    ROLLBACK TO approve_funding_chklst_tpl;
    x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OTHERS THEN
	ROLLBACK TO approve_funding_chklst_tpl;
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

end approve_funding_chklst_tpl;

-- start: Apr 25, 2005 cklee: Modification for okl.h lease app enhancement for Authoring - Checklist
----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : create_funding_chklst_tpl
-- Description     : wrapper api for create funding checklists template associated
--                   with credit line contract ID
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
 PROCEDURE create_funding_chklst_tpl(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_rulv_tbl                     IN  rulv_tbl_type
   ,x_rulv_tbl                     OUT NOCOPY rulv_tbl_type
 )
is
  l_api_name         CONSTANT VARCHAR2(30) := 'create_funding_chklst_tpl';
  l_api_version      CONSTANT NUMBER       := 1.0;
  i                  NUMBER;
  l_return_status    VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
--  lp_rulv_tbl        rulv_tbl_type := p_rulv_tbl;
--  lx_rulv_tbl        rulv_tbl_type := x_rulv_tbl;
  lp_rulv_tbl        okl_rule_pub.rulv_tbl_type;
  lx_rulv_tbl        okl_rule_pub.rulv_tbl_type;

begin
  -- Set API savepoint
  SAVEPOINT create_funding_chklst_tpl;

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

--DBMS_OUTPUT.PUT_LINE('before copy_rulv_tbl');

    copy_rulv_tbl(
          p_api_version    => p_api_version,
          p_init_msg_list  => p_init_msg_list,
          x_return_status  => x_return_status,
          x_msg_count      => x_msg_count,
          x_msg_data       => x_msg_data,
          p_rulv_tbl       => p_rulv_tbl,
          p_rulv_migr_tbl  => lp_rulv_tbl,
          p_type           => 'FUNDING',
          p_mode           => G_INSERT_MODE
    );

      If (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
        raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      Elsif (x_return_status = OKC_API.G_RET_STS_ERROR) then
        raise OKC_API.G_EXCEPTION_ERROR;
      End If;

--DBMS_OUTPUT.PUT_LINE('after copy_rulv_tbl');
-- validation

      okl_rule_pub.create_rule(
          p_api_version    => p_api_version,
          p_init_msg_list  => p_init_msg_list,
          x_return_status  => x_return_status,
          x_msg_count      => x_msg_count,
          x_msg_data       => x_msg_data,
          p_rulv_tbl       => lp_rulv_tbl,
          x_rulv_tbl       => lx_rulv_tbl);

      If (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
        raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      Elsif (x_return_status = OKC_API.G_RET_STS_ERROR) then
        raise OKC_API.G_EXCEPTION_ERROR;
      End If;

--start:  May-10-2005  cklee okl.h Lease Application ER for Authoring
    l_return_status := validate_dup_item(p_rulv_rec => p_rulv_tbl(p_rulv_tbl.FIRST),
                                         p_type     => 'FUNDING');
    --- Store the highest degree of error
    IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        x_return_status := l_return_status;
      END IF;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
--end:  May-10-2005  cklee okl.h Lease Application ER for Authoring


/*** End API body ******************************************************/

  -- Get message count and if count is 1, get message info
	FND_MSG_PUB.Count_And_Get
    (p_count          =>      x_msg_count,
     p_data           =>      x_msg_data);

EXCEPTION
  WHEN OKL_API.G_EXCEPTION_ERROR THEN
    ROLLBACK TO create_funding_chklst_tpl;
    x_return_status := OKL_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    ROLLBACK TO create_funding_chklst_tpl;
    x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OTHERS THEN
	ROLLBACK TO create_funding_chklst_tpl;
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

end create_funding_chklst_tpl;

---------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : delete_credit_funding_chklst
-- Description     : wrapper api for delete credit funding checklists associated
--                   with credit line contract ID
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
 PROCEDURE delete_funding_chklst_tpl(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_rulv_tbl                     IN  rulv_tbl_type
 )
is
  l_api_name         CONSTANT VARCHAR2(30) := 'delete_funding_chklst_tpl';
  l_api_version      CONSTANT NUMBER       := 1.0;
  i                  NUMBER;
  l_return_status    VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
--  lp_rulv_tbl        rulv_tbl_type := p_rulv_tbl;
--  lx_rulv_tbl        rulv_tbl_type := x_rulv_tbl;
  lp_rulv_tbl        okl_rule_pub.rulv_tbl_type;
  lx_rulv_tbl        okl_rule_pub.rulv_tbl_type;

begin
  -- Set API savepoint
  SAVEPOINT delete_funding_chklst_tpl;

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
--DBMS_OUTPUT.PUT_LINE('before copy_rulv_tbl');

      copy_rulv_tbl(
          p_api_version    => p_api_version,
          p_init_msg_list  => p_init_msg_list,
          x_return_status  => x_return_status,
          x_msg_count      => x_msg_count,
          x_msg_data       => x_msg_data,
          p_rulv_tbl       => p_rulv_tbl,
          p_rulv_migr_tbl  => lp_rulv_tbl,
          p_type           => null,
          p_mode           => G_DELETE_MODE
      );

      If (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
        raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      Elsif (x_return_status = OKC_API.G_RET_STS_ERROR) then
        raise OKC_API.G_EXCEPTION_ERROR;
      End If;

--DBMS_OUTPUT.PUT_LINE('after copy_rulv_tbl');
      okl_rule_pub.delete_rule(
          p_api_version    => p_api_version,
          p_init_msg_list  => p_init_msg_list,
          x_return_status  => x_return_status,
          x_msg_count      => x_msg_count,
          x_msg_data       => x_msg_data,
          p_rulv_tbl       => lp_rulv_tbl);

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
    ROLLBACK TO delete_funding_chklst_tpl;
    x_return_status := OKL_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    ROLLBACK TO delete_funding_chklst_tpl;
    x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OTHERS THEN
	ROLLBACK TO delete_funding_chklst_tpl;
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

end delete_funding_chklst_tpl;
-- end: Apr 25, 2005 cklee: Modification for okl.h lease app enhancement for Authoring - Checklist

END OKL_CREDIT_CHECKLIST_PVT;

/
