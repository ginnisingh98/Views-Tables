--------------------------------------------------------
--  DDL for Package Body OKL_FUNDING_CHECKLIST_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_FUNDING_CHECKLIST_PVT" AS
/* $Header: OKLRCLFB.pls 120.9 2007/03/06 09:44:44 nikshah ship $ */
 ----------------------------------------------------------------------------
 -- Data Structures
 ----------------------------------------------------------------------------
 subtype tapv_rec_type is okl_tap_pvt.tapv_rec_type;
 subtype tapv_tbl_type is okl_tap_pvt.tapv_tbl_type;
 subtype tplv_rec_type is okl_tpl_pvt.tplv_rec_type;
 subtype tplv_tbl_type is okl_tpl_pvt.tplv_tbl_type;

----------------------------------------------------------------------------
-- Global Message Constants
----------------------------------------------------------------------------
      G_STS_CODE  constant VARCHAR2(10) := 'NEW';
      G_APPROVE   constant VARCHAR2(30) := 'APPROVE';

 G_FUNDING_CHKLST_TPL CONSTANT VARCHAR2(30) := 'LAFCLH';
-- G_FUNDING_CHKLST_TPL_RULE1 CONSTANT VARCHAR2(30) := 'LAFCLT';
 G_FUNDING_CHKLST_TPL_RULE1 CONSTANT VARCHAR2(30) := 'LAFCLD';
 G_RGP_TYPE CONSTANT VARCHAR2(30) := 'KRG';

 G_INSERT_MODE  VARCHAR2(10) := 'INSERT';
 G_UPDATE_MODE  VARCHAR2(10) := 'UPDATE';
 G_DELETE_MODE  VARCHAR2(10) := 'DELETE';

----------------------------------------------------------------------------
-- Procedures and Functions
----------------------------------------------------------------------------
--start:  May-24-2005  cklee okl.h Lease Application ER for Authoring
  --------------------------------------------------------------------------
  ----- Validate Function Id
  --------------------------------------------------------------------------
  FUNCTION validate_function_id(
   p_rulv_rec     rulv_rec_type
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

    l_function_id := p_rulv_rec.RULE_INFORMATION9;
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
   p_mode         varchar2
  ) RETURN VARCHAR2
  IS
    l_return_status   VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_dummy  number;

    l_row_not_found boolean := false;
    l_checklist_type varchar2(30);

  CURSOR c_lok (p_lookup_code varchar2)
    IS
    SELECT 1
      FROM fnd_lookups lok
     WHERE lookup_type = 'OKL_CHECKLIST_TYPE'
     and lok.enabled_flag = 'Y'
     and lok.lookup_code = p_lookup_code
    ;

  BEGIN

    l_checklist_type := p_rulv_rec.RULE_INFORMATION10;

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

      OPEN c_lok(l_checklist_type);
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
   p_rulv_rec     rulv_rec_type
  ) RETURN VARCHAR2
  IS
    l_return_status   VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_count  number := 0;
    l_row_found boolean := false;
    l_dummy number;
    l_item varchar2(30);
    l_function_id varchar2(100);
    p_freq_id number;


  CURSOR c_unq_fun (p_freq_id number)
    IS
    SELECT 1
      FROM okl_funding_checklists_uv lst
     WHERE lst.FUND_REQ_ID = p_freq_id
     group by lst.todo_item_code, lst.function_id
     having count(1) > 1
    ;

  BEGIN

    -- Fix bug when invoked by okl_funding_pvt.update_checklist_function
    IF p_rulv_rec.object1_id1 is not null AND p_rulv_rec.object1_id1 <> OKL_API.G_MISS_CHAR THEN
      p_freq_id := p_rulv_rec.object1_id1;

      OPEN c_unq_fun(p_freq_id);
      FETCH c_unq_fun INTO l_dummy;
      l_row_found := c_unq_fun%FOUND;
      CLOSE c_unq_fun;

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

  --------------------------------------------------------------------------
  FUNCTION validate_header_attributes(
    p_rulv_rec     rulv_rec_type,
    p_mode         varchar2
  ) RETURN VARCHAR2
  IS
    l_return_status   VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    x_return_status   VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;

  BEGIN

    -- Do formal attribute validation:
    l_return_status := validate_function_id(p_rulv_rec => p_rulv_rec);
    --- Store the highest degree of error
    IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        x_return_status := l_return_status;
      END IF;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    l_return_status := validate_checklist_type(p_rulv_rec => p_rulv_rec,
                                               p_mode     => p_mode);
    --- Store the highest degree of error
    IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        x_return_status := l_return_status;
      END IF;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    l_return_status := validate_todo_item(p_rulv_rec => p_rulv_rec,
                                          p_mode     => p_mode);
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
  END validate_header_attributes;
-----------------------------------------------------------------------------
--- validate attrs after image-----------------------------------------------
-----------------------------------------------------------------------------
  FUNCTION validate_hdr_attr_aftimg(
    p_rulv_rec     rulv_rec_type
  ) RETURN VARCHAR2
  IS
    l_return_status   VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    x_return_status   VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;

  BEGIN

    l_return_status := validate_dup_item(p_rulv_rec => p_rulv_rec);
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
where rgd_code = G_FUNDING_CHKLST_TPL--'LAFCLH'
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
    p_rulv_migr_rec.rule_information2 := p_rulv_rec.rule_information2;
    p_rulv_migr_rec.rule_information3 := p_rulv_rec.rule_information3;

    p_rulv_migr_rec.rule_information4 := p_rulv_rec.rule_information4;
    p_rulv_migr_rec.rule_information5 := p_rulv_rec.rule_information5;
    p_rulv_migr_rec.rule_information6 := p_rulv_rec.rule_information6;

    p_rulv_migr_rec.rule_information7 := p_rulv_rec.rule_information7;

    p_rulv_migr_rec.rule_information8 := p_rulv_rec.rule_information8;
    p_rulv_migr_rec.rule_information9 := p_rulv_rec.rule_information9;
    p_rulv_migr_rec.rule_information10 := p_rulv_rec.rule_information10;

    IF p_mode = G_INSERT_MODE THEN
      OPEN c_rgp_id(p_rulv_rec.DNZ_CHR_ID);
      FETCH c_rgp_id into l_rgp_id;
      CLOSE c_rgp_id;

      p_rulv_migr_rec.RGP_ID := l_rgp_id;
      p_rulv_migr_rec.DNZ_CHR_ID := p_rulv_rec.DNZ_CHR_ID;
      p_rulv_migr_rec.OBJECT1_ID1 :=  p_rulv_rec.object1_id1;
      p_rulv_migr_rec.OBJECT1_ID2 :=  '#';
      p_rulv_migr_rec.RULE_INFORMATION_CATEGORY :=  G_FUNDING_CHKLST_TPL_RULE1;-- 'LAFCLD'

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

--end:  May-24-2005  cklee okl.h Lease Application ER for Authoring
/*
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
    p_rulv_rec                     IN  rulv_rec_type,
    p_rulv_migr_rec                OUT NOCOPY okl_rule_pub.rulv_rec_type)
is
begin

    p_rulv_migr_rec.id := p_rulv_rec.id;

--  start : 28-Feb-05 cklee -- fixed bug#4056212
    IF (p_rulv_rec.rule_information2 = 'Y' or p_rulv_rec.rule_information2 = 'N') THEN
      p_rulv_migr_rec.rule_information2 := p_rulv_rec.rule_information2;
    ELSE
      p_rulv_migr_rec.rule_information2 := 'N';
    END IF;

    IF (p_rulv_rec.rule_information3 = 'Y' or p_rulv_rec.rule_information3 = 'N') THEN
      p_rulv_migr_rec.rule_information3 := p_rulv_rec.rule_information3;
    ELSE
      p_rulv_migr_rec.rule_information3 := 'N';
    END IF;
--  end : 28-Feb-05 cklee -- fixed bug#4056212

    p_rulv_migr_rec.rule_information4 := p_rulv_rec.rule_information4;
    p_rulv_migr_rec.rule_information5 := p_rulv_rec.rule_information5;
    p_rulv_migr_rec.rule_information6 := p_rulv_rec.rule_information6;
    p_rulv_migr_rec.rule_information7 := p_rulv_rec.rule_information7;
    p_rulv_migr_rec.rule_information8 := p_rulv_rec.rule_information8;
    p_rulv_migr_rec.rule_information9 := p_rulv_rec.rule_information9;
    p_rulv_migr_rec.rule_information10 := p_rulv_rec.rule_information10;


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
    p_rulv_tbl                     IN  rulv_tbl_type,
    p_rulv_migr_tbl                OUT NOCOPY okl_rule_pub.rulv_tbl_type)
is
  i number;
begin

    IF (p_rulv_tbl.COUNT > 0) THEN
      i := p_rulv_tbl.FIRST;
      LOOP

        copy_rulv_rec(
          p_rulv_rec       => p_rulv_tbl(i),
          p_rulv_migr_rec  => p_rulv_migr_tbl(i)
        );

        EXIT WHEN (i = p_rulv_tbl.LAST);
        i := p_rulv_tbl.NEXT(i);
      END LOOP;
    END IF;

end;
*/
----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : create_funding_chklst
-- Description     : wrapper api for create funding checklists associated
--                   with credit line contract ID
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
 PROCEDURE create_funding_chklst(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_rulv_tbl                     IN  rulv_tbl_type
   ,x_rulv_tbl                     OUT NOCOPY rulv_tbl_type
 )
is
  l_api_name         CONSTANT VARCHAR2(30) := 'create_funding_chklst';
  l_api_version      CONSTANT NUMBER       := 1.0;
  i                  NUMBER;
  l_return_status    VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
--  lp_rulv_tbl        rulv_tbl_type := p_rulv_tbl;
--  xp_rulv_tbl        rulv_tbl_type := x_rulv_tbl;
  lp_rulv_tbl        okl_rule_pub.rulv_tbl_type;
  lx_rulv_tbl        okl_rule_pub.rulv_tbl_type;

  --START: Fixed bug 5912358 by nikshah, 06-MAR-2007
  l_lease_app_found boolean := FALSE;
  l_lease_app_list_found boolean := FALSE;
  l_lease_app_found_str VARCHAR2(10);
  l_lease_app_list_found_str VARCHAR2(10);
  l_funding_checklist_tpl okc_rules_b.rule_information2%TYPE;
  l_chr_id           okc_k_headers_b.id%type := OKC_API.G_MISS_NUM;
  l_rgpv_id okc_rule_groups_b.id%type;
  l_grp_row_not_found   boolean;
  lp_rgpv_rec        okl_okc_migration_pvt.rgpv_rec_type;
  lx_rgpv_rec        okl_okc_migration_pvt.rgpv_rec_type;
  x_lease_app_id number;
  x_credit_id number;
---------------------------------------------------------------------------------------------------
-- Funded contract group
---------------------------------------------------------------------------------------------------
  cursor c_grp (p_chr_id number) is
    select rgp.id
  from okc_rule_groups_b rgp
  where rgp.dnz_chr_id = p_chr_id
  and rgp.RGD_CODE = G_FUNDING_CHKLST_TPL
  ;
  --END: Fixed bug 5912358 by nikshah, 06-MAR-2007

begin
  -- Set API savepoint
  SAVEPOINT create_funding_chklst;

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

--START: Fixed Bug 5912358 by nikshah, 06-MAR-2007
  IF (p_rulv_tbl.COUNT > 0)THEN
    l_chr_id := p_rulv_tbl(p_rulv_tbl.FIRST).dnz_chr_id;
  END IF;
  OKL_FUNDING_PVT.get_checklist_source(
       p_api_version  =>  p_api_version,
       p_init_msg_list => p_init_msg_list,
       x_return_status => x_return_status,
       x_msg_count => x_msg_count,
       x_msg_data => x_msg_data,
       p_chr_id => l_chr_id,
       x_lease_app_found => l_lease_app_found_str,
       x_lease_app_list_found => l_lease_app_list_found_str,
       x_funding_checklist_tpl => l_funding_checklist_tpl,
       x_lease_app_id => x_lease_app_id,
       x_credit_id => x_credit_id);

    If (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
        raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (x_return_status = OKC_API.G_RET_STS_ERROR) then
        raise OKC_API.G_EXCEPTION_ERROR;
    End If;

  IF (l_lease_app_found_str = 'TRUE') THEN
    l_lease_app_found := TRUE;
  END IF;
  IF (l_lease_app_list_found_str = 'TRUE') THEN
    l_lease_app_list_found := TRUE;
  END IF;
  IF ( (NOT l_lease_app_found  AND l_funding_checklist_tpl IS NOT NULL) or
       (l_lease_app_found  AND l_lease_app_list_found)
     ) THEN

    open c_grp(l_chr_id);
    fetch c_grp into l_rgpv_id;

    l_grp_row_not_found := c_grp%NOTFOUND;
    close c_grp;

    IF (l_grp_row_not_found) THEN

      lp_rgpv_rec.DNZ_CHR_ID := l_chr_id;
      lp_rgpv_rec.CHR_ID := l_chr_id;
      lp_rgpv_rec.RGD_CODE := G_FUNDING_CHKLST_TPL;
      lp_rgpv_rec.RGP_TYPE := G_RGP_TYPE;

      okl_rule_pub.create_rule_group(
        p_api_version    => p_api_version,
        p_init_msg_list  => p_init_msg_list,
        x_return_status  => x_return_status,
        x_msg_count      => x_msg_count,
        x_msg_data       => x_msg_data,
        p_rgpv_rec       => lp_rgpv_rec,
        x_rgpv_rec       => lx_rgpv_rec);

      If (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
         raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      Elsif (x_return_status = OKC_API.G_RET_STS_ERROR) then
         raise OKC_API.G_EXCEPTION_ERROR;
      End If;

      l_rgpv_id := lx_rgpv_rec.id;
    END IF;

  END IF;

--END: Fixed Bug 5912358 by nikshah, 06-MAR-2007

      copy_rulv_tbl(
          p_api_version    => p_api_version,
          p_init_msg_list  => p_init_msg_list,
          x_return_status  => x_return_status,
          x_msg_count      => x_msg_count,
          x_msg_data       => x_msg_data,
          p_rulv_tbl       => p_rulv_tbl,
          p_rulv_migr_tbl  => lp_rulv_tbl,
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

    l_return_status := validate_hdr_attr_aftimg(p_rulv_rec => p_rulv_tbl(p_rulv_tbl.FIRST));
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
    ROLLBACK TO create_funding_chklst;
    x_return_status := OKL_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    ROLLBACK TO create_funding_chklst;
    x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OTHERS THEN
	ROLLBACK TO create_funding_chklst;
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

end create_funding_chklst;

----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : update_funding_chklst
-- Description     : wrapper api for update funding checklists associated
--                   with credit line contract ID
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
 PROCEDURE update_funding_chklst(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_rulv_tbl                     IN  rulv_tbl_type
   ,x_rulv_tbl                     OUT NOCOPY rulv_tbl_type
 )
is
  l_api_name         CONSTANT VARCHAR2(30) := 'update_funding_chklst';
  l_api_version      CONSTANT NUMBER       := 1.0;
  i                  NUMBER;
  l_return_status    VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
--  lp_rulv_tbl        rulv_tbl_type := p_rulv_tbl;
--  lx_rulv_tbl        rulv_tbl_type := x_rulv_tbl;
  lp_rulv_tbl        okl_rule_pub.rulv_tbl_type;
  lx_rulv_tbl        okl_rule_pub.rulv_tbl_type;

begin
  -- Set API savepoint
  SAVEPOINT update_funding_chklst;

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

    l_return_status := validate_hdr_attr_aftimg(p_rulv_rec => p_rulv_tbl(p_rulv_tbl.FIRST));
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
    ROLLBACK TO update_funding_chklst;
    x_return_status := OKL_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    ROLLBACK TO update_funding_chklst;
    x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OTHERS THEN
	ROLLBACK TO update_funding_chklst;
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

end update_funding_chklst;

----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : delete_funding_chklst
-- Description     : wrapper api for delete funding checklists associated
--                   with credit line contract ID
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
 PROCEDURE delete_funding_chklst(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_rulv_tbl                     IN  rulv_tbl_type
 )
is
  l_api_name         CONSTANT VARCHAR2(30) := 'delete_funding_chklst';
  l_api_version      CONSTANT NUMBER       := 1.0;
  i                  NUMBER;
  l_return_status    VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
--  lp_rulv_tbl        rulv_tbl_type := p_rulv_tbl;
--  xp_rulv_tbl        rulv_tbl_type := x_rulv_tbl;
  lp_rulv_tbl        okl_rule_pub.rulv_tbl_type;
  lx_rulv_tbl        okl_rule_pub.rulv_tbl_type;

begin
  -- Set API savepoint
  SAVEPOINT delete_funding_chklst;

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
    ROLLBACK TO delete_funding_chklst;
    x_return_status := OKL_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    ROLLBACK TO delete_funding_chklst;
    x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OTHERS THEN
	ROLLBACK TO delete_funding_chklst;
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

end delete_funding_chklst;

----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : approve_funding_request
-- Description     : wrapper api for update_funding_header with status = 'APPROVE'
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
 PROCEDURE approve_funding_request(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_fund_req_id                  IN  okl_trx_ap_invoices_b.id%TYPE
 )
is
  l_api_name         CONSTANT VARCHAR2(30) := 'approve_funding_request';
  l_api_version      CONSTANT NUMBER       := 1.0;
  i                  NUMBER;
  l_return_status    VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  lp_tapv_rec          tapv_rec_type;
  lx_tapv_rec          tapv_rec_type;

begin
  -- Set API savepoint
  SAVEPOINT approve_funding_request;

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

  lp_tapv_rec.id := p_fund_req_id;
  lp_tapv_rec.TRX_STATUS_CODE := G_APPROVE;
  lp_tapv_rec.DATE_FUNDING_APPROVED := sysdate;


  OKL_FUNDING_PVT.update_funding_header(
      p_api_version   => p_api_version,
      p_init_msg_list => p_init_msg_list,
      x_return_status => x_return_status,
      x_msg_count     => x_msg_count,
      x_msg_data      => x_msg_data,
      p_tapv_rec      => lp_tapv_rec,
      x_tapv_rec      => lx_tapv_rec);

  IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
    RAISE OKL_API.G_EXCEPTION_ERROR;
  END IF;

/*** End API body ******************************************************/

  -- Get message count and if count is 1, get message info
	FND_MSG_PUB.Count_And_Get
    (p_count          =>      x_msg_count,
     p_data           =>      x_msg_data);

EXCEPTION
  WHEN OKL_API.G_EXCEPTION_ERROR THEN
    ROLLBACK TO approve_funding_request;
    x_return_status := OKL_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    ROLLBACK TO approve_funding_request;
    x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OTHERS THEN
	ROLLBACK TO approve_funding_request;
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
-- Procedure Name  : approve_funding_chklst
-- Description     : set funding line checklist sttaus to "Active".
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
----------------------------------------------------------------------------------
 PROCEDURE approve_funding_chklst(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_rulv_rec                     IN  rulv_rec_type
 )
is
  l_api_name         CONSTANT VARCHAR2(30) := 'approve_funding_chklst';
  l_api_version      CONSTANT NUMBER       := 1.0;
  i                  NUMBER;
  l_return_status    VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;

  lp_rulv_tbl        okl_rule_pub.rulv_tbl_type;
  lx_rulv_tbl        okl_rule_pub.rulv_tbl_type;
  l_id               number;

cursor c_ids (p_chr_id okc_k_headers_b.id%TYPE, p_req_id number)
  is
select a.id
from okc_rules_b a
where a.dnz_chr_id = p_chr_id
-- Sep-26-2005 cklee -- Fixed ORA-01722: invalid number for                   |
--                      approve_funding_chklst function cursor issue          |
--and   a.object1_id1 = p_req_id
and   a.object1_id1 = TO_CHAR(p_req_id)
and   a.RULE_INFORMATION_CATEGORY =	G_FUNDING_CHKLST_TPL_RULE1--'LAFCLD'
;


begin
  -- Set API savepoint
  SAVEPOINT approve_funding_chklst;

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

  open c_ids(p_rulv_rec.dnz_chr_id, p_rulv_rec.object1_id1);
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
    ROLLBACK TO approve_funding_chklst;
    x_return_status := OKL_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    ROLLBACK TO approve_funding_chklst;
    x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OTHERS THEN
	ROLLBACK TO approve_funding_chklst;
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

end approve_funding_chklst;


END OKL_FUNDING_CHECKLIST_PVT;

/
