--------------------------------------------------------
--  DDL for Package Body OKL_DCT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_DCT_PVT" AS
/* $Header: OKLSDCTB.pls 120.3 2006/07/13 12:55:08 adagur noship $ */
G_NO_PARENT_RECORD    CONSTANT VARCHAR2(200) := 'OKC_NO_PARENT_RECORD';
G_UNEXPECTED_ERROR    CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UNEXPECTED_ERROR';
G_UPPER_CASE_REQUIRED CONSTANT VARCHAR2(200) := 'OKC_UPPER_CASE_REQUIRED';
--G_INVALID_END_DATE    CONSTANT VARCHAR2(200) := 'INVALID_END_DATE';
--G_INVALID_DATE_RANGE  CONSTANT VARCHAR2(200) := 'INVALID_DATE_RANGE';
G_SQLERRM_TOKEN       CONSTANT VARCHAR2(200) := 'SQLerrm';
G_SQLCODE_TOKEN       CONSTANT VARCHAR2(200) := 'SQLcode';
G_VIEW                CONSTANT VARCHAR2(200) := 'OKL_DF_CTGY_RMK_TMS';
G_EXCEPTION_HALT_VALIDATION exception;
g_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
------------------------------------
-- PROCEDURE validate_id--
------------------------------------
-- Function Name  : validate_id
-- Description     : To validate the id
-- Business Rules  :
-- Parameters      : Record
-- Version         : 1.0

    PROCEDURE validate_id(
      x_return_status OUT NOCOPY VARCHAR2,
      p_dctv_rec IN dctv_rec_type
    ) IS
    BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    IF p_dctv_rec.id = OKC_API.G_MISS_NUM OR
       p_dctv_rec.id IS NULL
    THEN
         OKC_API.SET_MESSAGE(p_app_name => g_app_name,
                             p_msg_name => g_required_value,
                             p_token1   => g_col_name_token,
                             p_token1_value => 'ID');

          x_return_status := OKC_API.G_RET_STS_ERROR;
          raise G_EXCEPTION_HALT_VALIDATION;
        else
          x_return_status := OKC_API.G_RET_STS_SUCCESS;
       end if;
      exception
       when G_EXCEPTION_HALT_VALIDATION then
          null;
       when OTHERS then
         OKC_API.SET_MESSAGE(p_app_name => g_app_name,
                             p_msg_name => g_required_value,
                             p_token1   => g_sqlcode_token,
                             p_token1_value => sqlcode,
                             p_token2       => g_sqlerrm_token,
                             p_token2_value => sqlerrm);
         x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
    END validate_id;
------------------------------------
-- PROCEDURE validate_object_version_number--
------------------------------------
-- Function Name  : validate_object_version_number
-- Description     : To validate the object Version Number
-- Business Rules  :
-- Parameters      : Record
-- Version         : 1.0

    PROCEDURE validate_object_version_number (
      x_return_status OUT NOCOPY VARCHAR2,
      p_dctv_rec IN dctv_rec_type
    ) IS
    BEGIN
     IF p_dctv_rec.object_version_number = OKC_API.G_MISS_NUM OR
          p_dctv_rec.object_version_number IS NULL
     THEN
         OKC_API.SET_MESSAGE(p_app_name => g_app_name,
                             p_msg_name => g_required_value,
                             p_token1   => g_col_name_token,
                             p_token1_value => 'ObjectVersionNumber');

          x_return_status := OKC_API.G_RET_STS_ERROR;
          raise G_EXCEPTION_HALT_VALIDATION;
     ELSE
          x_return_status := OKC_API.G_RET_STS_SUCCESS;
     END IF;
      exception
       when G_EXCEPTION_HALT_VALIDATION then
          null;
       when OTHERS then
         OKC_API.SET_MESSAGE(p_app_name => g_app_name,
                             p_msg_name => g_required_value,
                             p_token1   => g_sqlcode_token,
                             p_token1_value => sqlcode,
                             p_token2       => g_sqlerrm_token,
                             p_token2_value => sqlerrm);
         x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

    END validate_object_version_number;
------------------------------------
-- PROCEDURE validate_rmr_id--
------------------------------------
-- Function Name  : validate_qte_id
-- Description     : To validate the RMR Id
-- Business Rules  :
-- Parameters      : Record
-- Version         : 1.0

    PROCEDURE validate_rmr_id (
      x_return_status OUT NOCOPY VARCHAR2,
      p_dctv_rec IN dctv_rec_type
    ) IS
     -- select the ID of the parent record from the parent table
/*      CURSOR okl_rmrv_fk_csr IS
      SELECT  'x'
      FROM    OKX_REMARKET_TEAMS_V
      WHERE    ID = p_dctv_rec.rmr_id;
*/
    BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- data is required

    IF ((p_dctv_rec.rmr_id = OKC_API.G_MISS_NUM) OR
          (p_dctv_rec.rmr_id IS NULL))
    THEN

      OKL_API.set_message(p_app_name     => OKL_API.G_APP_NAME,
                          p_msg_name     => 'OKL_AM_REQ_FIELD_ERR',
                          p_token1       => 'PROMPT',
                          p_token1_value => OKL_AM_UTIL_PVT.get_ak_attribute('OKL_REMARKETER'));

/*
         OKC_API.SET_MESSAGE(p_app_name => g_app_name,
                             p_msg_name => g_required_value,
                             p_token1   => g_col_name_token,
                             p_token1_value => 'RmrId');
*/
          -- notify caller of an error
          x_return_status := OKC_API.G_RET_STS_ERROR;
          -- halt futher validation of this column
          raise G_EXCEPTION_HALT_VALIDATION;
    END IF;
    -- enforce foreign key
/*    OPEN okl_rmrv_fk_csr;
    FETCH okl_rmrv_fk_csr INTO l_dummy_var;
    CLOSE okl_rmrv_fk_csr;

    -- if l_dummy_var is still set to default, data was not found
    IF (l_dummy_var = '?') THEN
      OKC_API.set_message(p_app_name       => g_app_name,
                          p_msg_name       => g_no_parent_record,
                          p_token1         => g_col_name_token,
                          p_token1_value   => 'rmr_id',
                          p_token2         => g_child_table_token,
                          p_token2_value   => 'OKL_DF_CTGY_RMK_TMS_B',
                          p_token3         => g_parent_table_token,
                          p_token3_value   => 'OKX_REMARKET_TEAMS_V');

     -- notify caller of an error
     x_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
*/
    exception
       when G_EXCEPTION_HALT_VALIDATION then
          null;
       when OTHERS then
         OKC_API.SET_MESSAGE(p_app_name => g_app_name,
                             p_msg_name => g_required_value,
                             p_token1   => g_sqlcode_token,
                             p_token1_value => sqlcode,
                             p_token2       => g_sqlerrm_token,
                             p_token2_value => sqlerrm);
         x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
        -- verify that cursor was closed
/*          if okl_rmrv_fk_csr%ISOPEN then
            close okl_rmrv_fk_csr;
         end if;
*/
    END validate_rmr_id;
------------------------------------
-- PROCEDURE validate_ico_id--
------------------------------------
-- Function Name  : validate_ico_id
-- Description     : To validate the ICO Id
-- Business Rules  :
-- Parameters      : Record
-- Version         : 1.0

    PROCEDURE validate_ico_id (
      x_return_status OUT NOCOPY VARCHAR2,
      p_dctv_rec IN dctv_rec_type
    ) IS
     -- select the ID of the parent record from the parent table
/*      CURSOR okl_icov_fk_csr IS
      SELECT  'x'
      FROM    OKX_ITEM_CATALOGS_V
      WHERE    ID = p_dctv_rec.ico_id;
*/
    BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- data is required
    IF ((p_dctv_rec.ico_id = OKC_API.G_MISS_NUM) OR
          (p_dctv_rec.ico_id IS NULL))
    THEN

      OKL_API.set_message(p_app_name     => OKL_API.G_APP_NAME,
                          p_msg_name     => 'OKL_AM_REQ_FIELD_ERR',
                          p_token1       => 'PROMPT',
                          p_token1_value => OKL_AM_UTIL_PVT.get_ak_attribute('OKL_ITEM_CATALOG'));

/*
         OKC_API.SET_MESSAGE(p_app_name => g_app_name,
                             p_msg_name => g_required_value,
                             p_token1   => g_col_name_token,
                             p_token1_value => 'IcoId');
*/
          -- notify caller of an error
          x_return_status := OKC_API.G_RET_STS_ERROR;
          -- halt further validation of this column
          raise G_EXCEPTION_HALT_VALIDATION;
     END IF;
     -- enforce foreign key
/*     OPEN okl_icov_fk_csr;
     FETCH okl_icov_fk_csr INTO l_dummy_var;
     CLOSE okl_icov_fk_csr;

     -- if l_dummy_var is still set to default, data was not found
     IF (l_dummy_var = '?') THEN
        OKC_API.set_message(p_app_name       => g_app_name,
                            p_msg_name       => g_no_parent_record,
                            p_token1         => g_col_name_token,
                            p_token1_value   => 'ico_id',
                            p_token2         => g_child_table_token,
                            p_token2_value   => 'OKL_DF_CTGY_RMK_TMS_B',
                            p_token3         => g_parent_table_token,
                            p_token3_value   => 'OKX_ITEM_CATALOGS_V');

     -- notify caller of an error
     x_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
*/
      exception
       when G_EXCEPTION_HALT_VALIDATION then
          null;
       when OTHERS then
         OKC_API.SET_MESSAGE(p_app_name => g_app_name,
                             p_msg_name => g_required_value,
                             p_token1   => g_sqlcode_token,
                             p_token1_value => sqlcode,
                             p_token2       => g_sqlerrm_token,
                             p_token2_value => sqlerrm);
         x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
/*         -- verify that cursor was closed
         if okl_icov_fk_csr%ISOPEN then
            close okl_icov_fk_csr;
         end if;
*/
    END validate_ico_id;

------------------------------------
-- PROCEDURE validate_ILN_ID
------------------------------------
-- Function Name  : validate_ILN_ID
-- Description     : To validate the ILN_ID
-- Business Rules  :
-- Parameters      : Record
-- Version         : 1.0

    PROCEDURE validate_ILN_ID (
      x_return_status OUT NOCOPY VARCHAR2,
      p_dctv_rec IN dctv_rec_type) IS
      l_dummy_var           varchar2(1) := '?';
     -- select the ID of the parent record from the parent table
/*      CURSOR okl_ilnv_csr IS
      SELECT  'x'
      FROM    OKX_LOCATIONS_V
      WHERE    ID = p_dctv_rec.iln_id;
*/
    BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- data is required
    if (p_dctv_rec.iln_id is null) OR (p_dctv_rec.iln_id = OKC_API.G_MISS_NUM) then
       OKC_API.SET_MESSAGE(p_app_name	=> g_app_name,
                           p_msg_name   => g_required_value,
                           p_token1     => g_col_name_token,
                           p_token1_value => 'iln_id');

       -- notify caller of an error
       x_return_status := OKC_API.G_RET_STS_ERROR;

       -- halt further validation of this column
       raise G_EXCEPTION_HALT_VALIDATION;
     end if;

     -- enforce foreign key
/*
        OPEN okl_ilnv_fk_csr;
        FETCH okl_ilnv_fk_csr INTO l_dummy_var;
        CLOSE okl_ilnv_fk_csr;

        -- if l_dummy_var is still set to default, data was not found
        IF (l_dummy_var = '?') THEN
          OKC_API.set_message(p_app_name       => g_app_name,
                              p_msg_name       => g_no_parent_record,
                              p_token1         => g_col_name_token,
                              p_token1_value   => 'iln_id',
                              p_token2         => g_child_table_token,
                              p_token2_value   => 'OKL_DF_CTGY_RMK_TMS_B',
                              p_token3         => g_parent_table_token,
                              p_token3_value   => 'OKX_LOCATIONS_V');

         -- notify caller of an error

         x_return_status := OKC_API.G_RET_STS_ERROR;
        END IF;
*/
     exception
       when G_EXCEPTION_HALT_VALIDATION then
         null;

       when OTHERS then
         -- store SQL error on message stack for caller
         OKC_API.SET_MESSAGE(p_app_name => g_app_name,
                             p_msg_name => g_unexpected_error,
                             p_token1   => g_sqlcode_token,
                             p_token1_value => sqlcode,
                             p_token2       => g_sqlerrm_token,
                             p_token2_value => sqlerrm);

         -- notify caller of an UNEXPECTED error
         x_return_status  := OKC_API.G_RET_STS_UNEXP_ERROR;

/*         -- verify that cursor was closed
         if okl_ilnv_csr%ISOPEN then
            close okl_ilnv_csr;
         end if;
*/

    END validate_iln_ID;

------------------------------------
-- PROCEDURE validate_date_effective_from
------------------------------------
-- Function Name  : validate_date_effective_from
-- Description     : To validate the date effective from
-- Business Rules  :
-- Parameters      : Record
-- Version         : 1.0

    PROCEDURE validate_date_effective_from (
      x_return_status OUT NOCOPY VARCHAR2,
      p_dctv_rec IN dctv_rec_type
    ) IS
    BEGIN
     IF p_dctv_rec.date_effective_from = OKC_API.G_MISS_DATE OR
          p_dctv_rec.date_effective_from IS NULL
     THEN

      OKL_API.set_message(p_app_name     => OKL_API.G_APP_NAME,
                          p_msg_name     => 'OKL_AM_REQ_FIELD_ERR',
                          p_token1       => 'PROMPT',
                          p_token1_value => OKL_AM_UTIL_PVT.get_ak_attribute('OKL_EFFECTIVE_FROM'));

/*
         OKC_API.SET_MESSAGE(p_app_name => g_app_name,
                             p_msg_name => g_required_value,
                             p_token1   => g_col_name_token,
                             p_token1_value => 'date_effective_from');
*/
          x_return_status := OKC_API.G_RET_STS_ERROR;
          raise G_EXCEPTION_HALT_VALIDATION;
     ELSE
          x_return_status := OKC_API.G_RET_STS_SUCCESS;
     END IF;
      exception
       when G_EXCEPTION_HALT_VALIDATION then
          null;
       when OTHERS then
         OKC_API.SET_MESSAGE(p_app_name => g_app_name,
                             p_msg_name => g_required_value,
                             p_token1   => g_sqlcode_token,
                             p_token1_value => sqlcode,
                             p_token2       => g_sqlerrm_token,
                             p_token2_value => sqlerrm);
         x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

    END validate_date_effective_from;

  -- Start of comments
  --
  -- Procedure Name  : validate_effective_dates
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  PROCEDURE validate_effective_dates(p_dctv_rec IN dctv_rec_type
 					                ,x_return_status OUT NOCOPY VARCHAR2) IS

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    x_return_status := OKL_UTIL.check_from_to_date_range(
							 p_from_date 	=> p_dctv_rec.date_effective_from
							,p_to_date 		=> p_dctv_rec.date_effective_to);

    IF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
/*
        OKC_API.SET_MESSAGE(p_app_name		=> G_APP_NAME,
      			            p_msg_name		=> G_INVALID_VALUE,
      			            p_token1		=> G_COL_NAME_TOKEN,
      			            p_token1_value	=> 'date_effective_to');
*/
        -- Date Effective To DATE_EFFECTIVE_TO cannot be less than Date Effective From DATE_EFFECTIVE_FROM.
        OKC_API.SET_MESSAGE(p_app_name		=> 'OKL',
      			            p_msg_name		=> 'OKL_AM_DATE_EFF_FROM_LESS_TO',
      			            p_token1		=> 'DATE_EFFECTIVE_TO',
      			            p_token1_value	=> p_dctv_rec.date_effective_to,
      			            p_token2		=> 'DATE_EFFECTIVE_FROM',
      			            p_token2_value	=> p_dctv_rec.date_effective_from);


      raise G_EXCEPTION_HALT_VALIDATION;

    ELSIF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN

      raise G_EXCEPTION_HALT_VALIDATION;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION then
      -- No action necessary. Validation can continue to next attribute/column
      null;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => sqlcode
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => sqlerrm);

      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  END validate_effective_dates;

  -- Start of comments
  --
  -- Procedure Name  : is_unique
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  PROCEDURE is_unique(p_dctv_rec        IN dctv_rec_type,
                      x_return_status   OUT NOCOPY VARCHAR2) IS
     -- Cursor to get the id if exists
     CURSOR okl_dctv_id_csr ( p_id  NUMBER := OKC_API.G_MISS_NUM) IS
     SELECT id
     FROM   OKL_DF_CTGY_RMK_TMS
     WHERE  id    = p_id;

     -- Cursor to get the db value of date_effective_to for Remarketer and
     -- Asset_Category to check for uniqueness when create of new rec
     CURSOR okl_dctv_cre_data_csr (
                           p_rmr_id               NUMBER := OKC_API.G_MISS_NUM,
                           p_ico_id               NUMBER := OKC_API.G_MISS_NUM) IS
     SELECT NVL(date_effective_to, OKL_API.G_MISS_DATE)
     FROM   OKL_DF_CTGY_RMK_TMS
     WHERE  rmr_id =  p_rmr_id
     AND    ico_id =  p_ico_id
     ORDER BY date_effective_from DESC;

     -- Cursor to get the db value of date_effective_to for Remarketer and
     -- Asset_Category to check for uniqueness when update of old rec
     CURSOR okl_dctv_upd_data_csr (
                           p_id                   NUMBER := OKC_API.G_MISS_NUM,
                           p_rmr_id               NUMBER := OKC_API.G_MISS_NUM,
                           p_ico_id               NUMBER := OKC_API.G_MISS_NUM) IS
     SELECT NVL(date_effective_to, OKL_API.G_MISS_DATE)
     FROM   OKL_DF_CTGY_RMK_TMS
     WHERE  rmr_id =  p_rmr_id
     AND    ico_id =  p_ico_id
     AND    id     <> p_id
     ORDER BY date_effective_from DESC;

    l_return_status     VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_date_effective_to DATE;
    l_found             BOOLEAN;
    l_id                NUMBER;
  BEGIN
    -- initialize return status
    l_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF (p_dctv_rec.id IS NOT NULL) THEN
      OPEN okl_dctv_id_csr(p_dctv_rec.id);
      FETCH okl_dctv_id_csr INTO l_id;
      -- If id exists then update mode
      IF okl_dctv_id_csr%FOUND THEN
        -- enforce uniqueness
        OPEN okl_dctv_upd_data_csr(p_dctv_rec.id,
                                   p_dctv_rec.rmr_id,
                                   p_dctv_rec.ico_id);
        FETCH okl_dctv_upd_data_csr INTO l_date_effective_to;
        IF okl_dctv_upd_data_csr%FOUND THEN
          -- Remarketer assignment for same Remarketer and Item Category exists with Date Effective To DATE_EFFECTIVE_TO more than Date Effective From DATE_EFFECTIVE_FROM entered,
          -- enter a Date Effective From greater than the existing Date Effective To.
          IF (l_date_effective_to > p_dctv_rec.date_effective_from) THEN
  	        OKC_API.SET_MESSAGE( p_app_name		=> 'OKL'
				    	  	    ,p_msg_name		=> 'OKL_AM_RMK_ASS_DATES_ERR'
					    	    ,p_token1		=> 'DATE_EFFECTIVE_TO'
					   	  	    ,p_token1_value	=> l_date_effective_to
					    	    ,p_token2		=> 'DATE_EFFECTIVE_FROM'
					    	    ,p_token2_value	=> p_dctv_rec.date_effective_from);
    	    -- notify caller of an error
	        l_return_status := OKC_API.G_RET_STS_ERROR;
          END IF;
        END IF;
        CLOSE okl_dctv_upd_data_csr;
      ELSE -- id does not exists, so create mode
        -- enforce uniqueness
        OPEN okl_dctv_cre_data_csr(p_dctv_rec.rmr_id,
                                   p_dctv_rec.ico_id);
        FETCH okl_dctv_cre_data_csr INTO l_date_effective_to;
        IF okl_dctv_cre_data_csr%FOUND THEN
          -- Error if the previous date_effective_to was null
          IF (l_date_effective_to = OKL_API.G_MISS_DATE)
          OR (l_date_effective_to IS NULL) THEN
            -- Remarketer assignment with same Remarketer and Item Category exists with open Date Effective To, so cannot create a new assignment
     	    OKC_API.SET_MESSAGE( p_app_name		=> 'OKL',
				    	  	     p_msg_name		=> 'OKL_AM_RMK_ASS_EXISTS');
	        -- notify caller of an error
    	    l_return_status := OKC_API.G_RET_STS_ERROR;
          -- Remarketer assignment for same Remarketer and Item Category exists with Date Effective To DATE_EFFECTIVE_TO more than Date Effective From DATE_EFFECTIVE_FROM entered,
          -- enter a Date Effective From greater than the existing Date Effective To.
          ELSIF (l_date_effective_to > p_dctv_rec.date_effective_from) THEN
  	        OKC_API.SET_MESSAGE( p_app_name		=> 'OKL'
				    	  	    ,p_msg_name		=> 'OKL_AM_RMK_ASS_DATES_ERR'
					    	    ,p_token1		=> 'DATE_EFFECTIVE_TO'
					   	  	    ,p_token1_value	=> l_date_effective_to
					    	    ,p_token2		=> 'DATE_EFFECTIVE_FROM'
					    	    ,p_token2_value	=> p_dctv_rec.date_effective_from);
    	    -- notify caller of an error
	        l_return_status := OKC_API.G_RET_STS_ERROR;
          END IF;
        END IF;
        CLOSE okl_dctv_cre_data_csr;
      END IF;
      CLOSE okl_dctv_id_csr;
    END IF;
    x_return_status := l_return_status;
    EXCEPTION
       WHEN OTHERS THEN
         OKC_API.SET_MESSAGE(p_app_name => g_app_name,
                             p_msg_name => g_required_value,
                             p_token1   => g_sqlcode_token,
                             p_token1_value => sqlcode,
                             p_token2       => g_sqlerrm_token,
                             p_token2_value => sqlerrm);
         -- verify that cursor was closed
         IF okl_dctv_id_csr%ISOPEN THEN
           CLOSE okl_dctv_id_csr;
         END IF;
         -- verify that cursor was closed
         IF okl_dctv_cre_data_csr%ISOPEN THEN
           CLOSE okl_dctv_cre_data_csr;
         END IF;
         -- verify that cursor was closed
         IF okl_dctv_upd_data_csr%ISOPEN THEN
           CLOSE okl_dctv_upd_data_csr;
         END IF;
         x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
    END is_unique;
/*
  PROCEDURE is_unique(p_dctv_rec        IN dctv_rec_type,
                      x_return_status   OUT NOCOPY VARCHAR2) IS
     CURSOR okl_dctv_csr ( p_date_effective_from  DATE  := OKC_API.G_MISS_DATE,
                           p_rmr_id               NUMBER := OKC_API.G_MISS_NUM,
                           p_ico_id               NUMBER := OKC_API.G_MISS_NUM,
                           p_iln_id               NUMBER := OKC_API.G_MISS_NUM)
     IS
     SELECT 'x'
     FROM OKL_DF_CTGY_RMK_TMS
     WHERE  date_effective_from = p_date_effective_from
     AND    rmr_id = p_rmr_id
     AND    ico_id = p_ico_id
     AND    iln_id = p_iln_id;

    l_return_status     VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_dummy             VARCHAR2(1);
    l_found             BOOLEAN;

  BEGIN
    -- initialize return status
    l_return_status := OKC_API.G_RET_STS_SUCCESS;

    IF (p_dctv_rec.id IS NOT NULL) THEN

      -- enforce uniqueness
      OPEN okl_dctv_csr(p_dctv_rec.date_effective_from,
                        p_dctv_rec.rmr_id,
                        p_dctv_rec.ico_id,
                        p_dctv_rec.iln_id);

      FETCH okl_dctv_csr INTO l_dummy;
      l_found := okl_dctv_csr%FOUND;
	  CLOSE okl_dctv_csr;

    END IF;

    IF (l_found) Then
  	  OKC_API.SET_MESSAGE(	 p_app_name		=> G_APP_NAME
				    	  	,p_msg_name		=> 'OKL_UNIQUE_KEY_EXISTS'
					    	,p_token1		=> 'UK_KEY_VALUE'
					   	 	,p_token1_value	=> p_dctv_rec.date_effective_from
					    	,p_token2		=> 'UK_KEY_VALUE'
					    	,p_token2_value	=> p_dctv_rec.rmr_id
					    	,p_token3		=> 'UK_KEY_VALUE'
					    	,p_token3_value	=> p_dctv_rec.ico_id
					    	,p_token4		=> 'UK_KEY_VALUE'
					    	,p_token4_value	=> p_dctv_rec.iln_id);
	  -- notify caller of an error
	  l_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;

    x_return_status := l_return_status;
    EXCEPTION
       WHEN OTHERS THEN
         OKC_API.SET_MESSAGE(p_app_name => g_app_name,
                             p_msg_name => g_required_value,
                             p_token1   => g_sqlcode_token,
                             p_token1_value => sqlcode,
                             p_token2       => g_sqlerrm_token,
                             p_token2_value => sqlerrm);

         -- verify that cursor was closed
         IF okl_dctv_csr%ISOPEN THEN
           CLOSE okl_dctv_csr;
         END IF;

         x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

    END is_unique;
*/
  ---------------------------------------------------------------------------
  -- FUNCTION get_seq_id
  ---------------------------------------------------------------------------
  FUNCTION get_seq_id RETURN NUMBER IS
  BEGIN
    RETURN(okc_p_util.raw_to_number(sys_guid()));
  END get_seq_id;

  ---------------------------------------------------------------------------
  -- PROCEDURE qc
  ---------------------------------------------------------------------------
  PROCEDURE qc IS
  BEGIN
    null;
  END qc;

  ---------------------------------------------------------------------------
  -- PROCEDURE change_version
  ---------------------------------------------------------------------------
  PROCEDURE change_version IS
  BEGIN
    null;
  END change_version;

  ---------------------------------------------------------------------------
  -- PROCEDURE api_copy
  ---------------------------------------------------------------------------
  PROCEDURE api_copy IS
  BEGIN
    null;
  END api_copy;

  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_DF_CTGY_RMK_TMS
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_dct_rec                      IN dct_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN dct_rec_type IS
    CURSOR okl_df_ctgy_rmk_tms_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            ORG_ID,
            RMR_ID,
            ICO_ID,
            ILN_ID,
            DATE_EFFECTIVE_FROM,
            OBJECT_VERSION_NUMBER,
            CREATED_BY,
            DATE_EFFECTIVE_TO,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
      FROM Okl_Df_Ctgy_Rmk_Tms
     WHERE okl_df_ctgy_rmk_tms.id = p_id;
    l_okl_df_ctgy_rmk_tms_pk       okl_df_ctgy_rmk_tms_pk_csr%ROWTYPE;
    l_dct_rec                      dct_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_df_ctgy_rmk_tms_pk_csr (p_dct_rec.id);
    FETCH okl_df_ctgy_rmk_tms_pk_csr INTO
              l_dct_rec.ID,
              l_dct_rec.ORG_ID,
              l_dct_rec.RMR_ID,
              l_dct_rec.ICO_ID,
              l_dct_rec.ILN_ID,
              l_dct_rec.DATE_EFFECTIVE_FROM,
              l_dct_rec.OBJECT_VERSION_NUMBER,
              l_dct_rec.CREATED_BY,
              l_dct_rec.DATE_EFFECTIVE_TO,
              l_dct_rec.CREATION_DATE,
              l_dct_rec.LAST_UPDATED_BY,
              l_dct_rec.LAST_UPDATE_DATE,
              l_dct_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okl_df_ctgy_rmk_tms_pk_csr%NOTFOUND;
    CLOSE okl_df_ctgy_rmk_tms_pk_csr;
    RETURN(l_dct_rec);
  END get_rec;

  FUNCTION get_rec (
    p_dct_rec                      IN dct_rec_type
  ) RETURN dct_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_dct_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_DF_CTGY_RMK_TMS_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_dctv_rec                     IN dctv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN dctv_rec_type IS
    CURSOR okl_dctv_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            OBJECT_VERSION_NUMBER,
            ORG_ID,
            RMR_ID,
            ICO_ID,
            ILN_ID,
            DATE_EFFECTIVE_FROM,
            DATE_EFFECTIVE_TO,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
      FROM OKL_DF_CTGY_RMK_TMS
     WHERE OKL_DF_CTGY_RMK_TMS.id = p_id;
    l_okl_dctv_pk                  okl_dctv_pk_csr%ROWTYPE;
    l_dctv_rec                     dctv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_dctv_pk_csr (p_dctv_rec.id);
    FETCH okl_dctv_pk_csr INTO
              l_dctv_rec.ID,
              l_dctv_rec.OBJECT_VERSION_NUMBER,
              l_dctv_rec.ORG_ID,
              l_dctv_rec.RMR_ID,
              l_dctv_rec.ICO_ID,
              l_dctv_rec.ILN_ID,
              l_dctv_rec.DATE_EFFECTIVE_FROM,
              l_dctv_rec.DATE_EFFECTIVE_TO,
              l_dctv_rec.CREATED_BY,
              l_dctv_rec.CREATION_DATE,
              l_dctv_rec.LAST_UPDATED_BY,
              l_dctv_rec.LAST_UPDATE_DATE,
              l_dctv_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okl_dctv_pk_csr%NOTFOUND;
    CLOSE okl_dctv_pk_csr;
    RETURN(l_dctv_rec);
  END get_rec;

  FUNCTION get_rec (
    p_dctv_rec                     IN dctv_rec_type
  ) RETURN dctv_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_dctv_rec, l_row_notfound));
  END get_rec;

  -----------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKL_DF_CTGY_RMK_TMS_V --
  -----------------------------------------------------------
  FUNCTION null_out_defaults (
    p_dctv_rec	IN dctv_rec_type
  ) RETURN dctv_rec_type IS
    l_dctv_rec	dctv_rec_type := p_dctv_rec;
  BEGIN
    IF (l_dctv_rec.object_version_number = OKC_API.G_MISS_NUM) THEN
      l_dctv_rec.object_version_number := NULL;
    END IF;
    IF (l_dctv_rec.org_id = OKC_API.G_MISS_NUM) THEN
      l_dctv_rec.org_id := NULL;
    END IF;
    IF (l_dctv_rec.rmr_id = OKC_API.G_MISS_NUM) THEN
      l_dctv_rec.rmr_id := NULL;
    END IF;
    IF (l_dctv_rec.ico_id = OKC_API.G_MISS_NUM) THEN
      l_dctv_rec.ico_id := NULL;
    END IF;
    IF (l_dctv_rec.iln_id = OKC_API.G_MISS_NUM) THEN
      l_dctv_rec.iln_id := NULL;
    END IF;
    IF (l_dctv_rec.date_effective_from = OKC_API.G_MISS_DATE) THEN
      l_dctv_rec.date_effective_from := NULL;
    END IF;
    IF (l_dctv_rec.date_effective_to = OKC_API.G_MISS_DATE) THEN
      l_dctv_rec.date_effective_to := NULL;
    END IF;
    IF (l_dctv_rec.created_by = OKC_API.G_MISS_NUM) THEN
      l_dctv_rec.created_by := NULL;
    END IF;
    IF (l_dctv_rec.creation_date = OKC_API.G_MISS_DATE) THEN
      l_dctv_rec.creation_date := NULL;
    END IF;
    IF (l_dctv_rec.last_updated_by = OKC_API.G_MISS_NUM) THEN
      l_dctv_rec.last_updated_by := NULL;
    END IF;
    IF (l_dctv_rec.last_update_date = OKC_API.G_MISS_DATE) THEN
      l_dctv_rec.last_update_date := NULL;
    END IF;
    IF (l_dctv_rec.last_update_login = OKC_API.G_MISS_NUM) THEN
      l_dctv_rec.last_update_login := NULL;
    END IF;
    RETURN(l_dctv_rec);
  END null_out_defaults;
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Attributes
  ---------------------------------------------------------------------------
  ---------------------------------------------------
  -- Validate_Attributes for:OKL_DF_CTGY_RMK_TMS_V --
  ---------------------------------------------------
  FUNCTION Validate_Attributes (
    p_dctv_rec IN  dctv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    x_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    validate_id(x_return_status => l_return_status,
                p_dctv_rec      => p_dctv_rec);

    if (l_return_status <> OKC_API.G_RET_STS_SUCCESS) then
       if (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) then
           x_return_status := l_return_status;
       end if;
    end if;

     validate_object_version_number(x_return_status => l_return_status,
                p_dctv_rec      => p_dctv_rec);

    if (l_return_status <> OKC_API.G_RET_STS_SUCCESS) then
       if (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) then
           x_return_status := l_return_status;
       end if;
    end if;

    validate_rmr_id(x_return_status => l_return_status,
                p_dctv_rec      => p_dctv_rec);

    if (l_return_status <> OKC_API.G_RET_STS_SUCCESS) then
       if (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) then
           x_return_status := l_return_status;
       end if;
    end if;

    validate_ico_id(x_return_status => l_return_status,
                p_dctv_rec      => p_dctv_rec);

    if (l_return_status <> OKC_API.G_RET_STS_SUCCESS) then
       if (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) then
           x_return_status := l_return_status;
       end if;
    end if;
/*
    validate_iln_id(x_return_status => l_return_status,
                p_dctv_rec      => p_dctv_rec);

    if (l_return_status <> OKC_API.G_RET_STS_SUCCESS) then
       if (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) then
           x_return_status := l_return_status;
       end if;
    end if;
*/
    validate_date_effective_from(x_return_status => l_return_status,
                                 p_dctv_rec      => p_dctv_rec);

    if (l_return_status <> OKC_API.G_RET_STS_SUCCESS) then
       if (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) then
           x_return_status := l_return_status;
       end if;
    end if;

/*    validate_fk_rmr_id(x_return_status => l_return_status,
                p_dctv_rec      => p_dctv_rec);

    if (l_return_status <> OKC_API.G_RET_STS_SUCCESS) then
       if (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) then
           x_return_status := l_return_status;
       end if;
    end if;

    validate_fk_ico_id(x_return_status => l_return_status,
                p_dctv_rec      => p_dctv_rec);

    if (l_return_status <> OKC_API.G_RET_STS_SUCCESS) then
       if (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) then
           x_return_status := l_return_status;
       end if;
    end if;


    validate_fk_iln_id(x_return_status => l_return_status,
                p_dctv_rec      => p_dctv_rec);

    if (l_return_status <> OKC_API.G_RET_STS_SUCCESS) then
       if (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) then
           x_return_status := l_return_status;
       end if;
    end if;
*/
    RETURN(x_return_status);
  EXCEPTION
    WHEN OTHERS THEN
      OKL_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      RETURN(x_return_status);
  END Validate_Attributes;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Record
  ---------------------------------------------------------------------------
  -----------------------------------------------
  -- Validate_Record for:OKL_DF_CTGY_RMK_TMS_V --
  -----------------------------------------------
  FUNCTION Validate_Record (
    p_dctv_rec IN dctv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    x_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN

    -- check uniqueness
    is_unique(p_dctv_rec,l_return_status);

    -- store the highest degree of error
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           x_return_status := l_return_status;
       END IF;
    END IF;

    --
    -- Date checks
    --
	validate_effective_dates(p_dctv_rec      => p_dctv_rec
 				            ,x_return_status => l_return_status);

    -- store the highest degree of error
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           x_return_status := l_return_status;
       END IF;
    END IF;

    RETURN (x_return_status);

    EXCEPTION
      WHEN OTHERS THEN
        -- store SQL error message on message stack for caller
        OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                            ,p_msg_name     => G_UNEXPECTED_ERROR
                            ,p_token1       => G_SQLCODE_TOKEN
                            ,p_token1_value => sqlcode
                            ,p_token2       => G_SQLERRM_TOKEN
                            ,p_token2_value => sqlerrm);

        --notify caller of an UNEXPECTED error
        x_return_status  := OKC_API.G_RET_STS_UNEXP_ERROR;

        --return status to caller
        RETURN x_return_status;

    END validate_record;

  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from	IN dctv_rec_type,
    p_to	IN OUT NOCOPY dct_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.org_id := p_from.org_id;
    p_to.rmr_id := p_from.rmr_id;
    p_to.ico_id := p_from.ico_id;
    p_to.iln_id := p_from.iln_id;
    p_to.date_effective_from := p_from.date_effective_from;
    p_to.object_version_number := p_from.object_version_number;
    p_to.created_by := p_from.created_by;
    p_to.date_effective_to := p_from.date_effective_to;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
  END migrate;
  PROCEDURE migrate (
    p_from	IN dct_rec_type,
    p_to	IN OUT NOCOPY dctv_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.org_id := p_from.org_id;
    p_to.rmr_id := p_from.rmr_id;
    p_to.ico_id := p_from.ico_id;
    p_to.iln_id := p_from.iln_id;
    p_to.date_effective_from := p_from.date_effective_from;
    p_to.object_version_number := p_from.object_version_number;
    p_to.created_by := p_from.created_by;
    p_to.date_effective_to := p_from.date_effective_to;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
  END migrate;

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_row
  ---------------------------------------------------------------------------
  --------------------------------------------
  -- validate_row for:OKL_DF_CTGY_RMK_TMS_V --
  --------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_dctv_rec                     IN dctv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_dctv_rec                     dctv_rec_type := p_dctv_rec;
    l_dct_rec                      dct_rec_type;
  BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_dctv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_dctv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END validate_row;
  ------------------------------------------
  -- PL/SQL TBL validate_row for:DCTV_TBL --
  ------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_dctv_tbl                     IN dctv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;

    -- Begin Post-Generation Change
    -- overall error status
    l_overall_status               VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    -- End Post-Generation Change
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_dctv_tbl.COUNT > 0) THEN
      i := p_dctv_tbl.FIRST;
      LOOP
        validate_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_dctv_rec                     => p_dctv_tbl(i));
        -- Begin Post-Generation Change
        -- store the highest degree of error
        IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
           IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
              l_overall_status := x_return_status;
           END IF;
        END IF;
        -- End Post-Generation Change
        EXIT WHEN (i = p_dctv_tbl.LAST);
        i := p_dctv_tbl.NEXT(i);
      END LOOP;
      -- Begin Post-Generation Change
      -- return overall status
      x_return_status := l_overall_status;
      -- End Post-Generation Change
    END IF;
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END validate_row;

  ---------------------------------------------------------------------------
  -- PROCEDURE insert_row
  ---------------------------------------------------------------------------
  ----------------------------------------
  -- insert_row for:OKL_DF_CTGY_RMK_TMS --
  ----------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_dct_rec                      IN dct_rec_type,
    x_dct_rec                      OUT NOCOPY dct_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TMS_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_dct_rec                      dct_rec_type := p_dct_rec;
    l_def_dct_rec                  dct_rec_type;
    --------------------------------------------
    -- Set_Attributes for:OKL_DF_CTGY_RMK_TMS --
    --------------------------------------------
    FUNCTION Set_Attributes (
      p_dct_rec IN  dct_rec_type,
      x_dct_rec OUT NOCOPY dct_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_dct_rec := p_dct_rec;
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      p_dct_rec,                         -- IN
      l_dct_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKL_DF_CTGY_RMK_TMS(
        id,
        org_id,
        rmr_id,
        ico_id,
        iln_id,
        date_effective_from,
        object_version_number,
        created_by,
        date_effective_to,
        creation_date,
        last_updated_by,
        last_update_date,
        last_update_login)
      VALUES (
        l_dct_rec.id,
        l_dct_rec.org_id,
        l_dct_rec.rmr_id,
        l_dct_rec.ico_id,
        l_dct_rec.iln_id,
        l_dct_rec.date_effective_from,
        l_dct_rec.object_version_number,
        l_dct_rec.created_by,
        l_dct_rec.date_effective_to,
        l_dct_rec.creation_date,
        l_dct_rec.last_updated_by,
        l_dct_rec.last_update_date,
        l_dct_rec.last_update_login);
    -- Set OUT values
    x_dct_rec := l_dct_rec;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END insert_row;
  ------------------------------------------
  -- insert_row for:OKL_DF_CTGY_RMK_TMS_V --
  ------------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_dctv_rec                     IN dctv_rec_type,
    x_dctv_rec                     OUT NOCOPY dctv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_dctv_rec                     dctv_rec_type;
    l_def_dctv_rec                 dctv_rec_type;
    l_dct_rec                      dct_rec_type;
    lx_dct_rec                     dct_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_dctv_rec	IN dctv_rec_type
    ) RETURN dctv_rec_type IS
      l_dctv_rec	dctv_rec_type := p_dctv_rec;
    BEGIN
      l_dctv_rec.CREATION_DATE := SYSDATE;
      l_dctv_rec.CREATED_BY := FND_GLOBAL.USER_ID;
      l_dctv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_dctv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_dctv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_dctv_rec);
    END fill_who_columns;
    ----------------------------------------------
    -- Set_Attributes for:OKL_DF_CTGY_RMK_TMS_V --
    ----------------------------------------------
    FUNCTION Set_Attributes (
      p_dctv_rec IN  dctv_rec_type,
      x_dctv_rec OUT NOCOPY dctv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_dctv_rec := p_dctv_rec;
      x_dctv_rec.OBJECT_VERSION_NUMBER := 1;
      -- Default the ORG ID if a value is not passed
      IF p_dctv_rec.org_id IS NULL
      OR p_dctv_rec.org_id = OKC_API.G_MISS_NUM THEN
        x_dctv_rec.org_id := MO_GLOBAL.GET_CURRENT_ORG_ID();
      END IF;
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_dctv_rec := null_out_defaults(p_dctv_rec);
    -- Set primary key value
    l_dctv_rec.ID := get_seq_id;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      l_dctv_rec,                        -- IN
      l_def_dctv_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_dctv_rec := fill_who_columns(l_def_dctv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_dctv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_dctv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_dctv_rec, l_dct_rec);
    --------------------------------------------
    -- Call the INSERT_ROW for each child record
    --------------------------------------------
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_dct_rec,
      lx_dct_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_dct_rec, l_def_dctv_rec);
    -- Set OUT values
    x_dctv_rec := l_def_dctv_rec;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END insert_row;
  ----------------------------------------
  -- PL/SQL TBL insert_row for:DCTV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_dctv_tbl                     IN dctv_tbl_type,
    x_dctv_tbl                     OUT NOCOPY dctv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;

    -- Begin Post-Generation Change
    -- overall error status
    l_overall_status               VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    -- End Post-Generation Change
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_dctv_tbl.COUNT > 0) THEN
      i := p_dctv_tbl.FIRST;
      LOOP
        insert_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_dctv_rec                     => p_dctv_tbl(i),
          x_dctv_rec                     => x_dctv_tbl(i));
        -- Begin Post-Generation Change
        -- store the highest degree of error
        IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
           IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
              l_overall_status := x_return_status;
           END IF;
        END IF;
        -- End Post-Generation Change
        EXIT WHEN (i = p_dctv_tbl.LAST);
        i := p_dctv_tbl.NEXT(i);
      END LOOP;
      -- Begin Post-Generation Change
      -- return overall status
      x_return_status := l_overall_status;
      -- End Post-Generation Change
    END IF;
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END insert_row;

  ---------------------------------------------------------------------------
  -- PROCEDURE lock_row
  ---------------------------------------------------------------------------
  --------------------------------------
  -- lock_row for:OKL_DF_CTGY_RMK_TMS --
  --------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_dct_rec                      IN dct_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_dct_rec IN dct_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_DF_CTGY_RMK_TMS
     WHERE ID = p_dct_rec.id
       AND OBJECT_VERSION_NUMBER = p_dct_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR  lchk_csr (p_dct_rec IN dct_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_DF_CTGY_RMK_TMS
    WHERE ID = p_dct_rec.id;
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TMS_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_object_version_number       OKL_DF_CTGY_RMK_TMS.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number      OKL_DF_CTGY_RMK_TMS.OBJECT_VERSION_NUMBER%TYPE;
    l_row_notfound                BOOLEAN := FALSE;
    lc_row_notfound               BOOLEAN := FALSE;
  BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    BEGIN
      OPEN lock_csr(p_dct_rec);
      FETCH lock_csr INTO l_object_version_number;
      l_row_notfound := lock_csr%NOTFOUND;
      CLOSE lock_csr;
    EXCEPTION
      WHEN E_Resource_Busy THEN
        IF (lock_csr%ISOPEN) THEN
          CLOSE lock_csr;
        END IF;
        OKC_API.set_message(G_FND_APP,G_FORM_UNABLE_TO_RESERVE_REC);
        RAISE APP_EXCEPTIONS.RECORD_LOCK_EXCEPTION;
    END;

    IF ( l_row_notfound ) THEN
      OPEN lchk_csr(p_dct_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_dct_rec.object_version_number THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_dct_rec.object_version_number THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number = -1 THEN
      OKC_API.set_message(G_APP_NAME,G_RECORD_LOGICALLY_DELETED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END lock_row;
  ----------------------------------------
  -- lock_row for:OKL_DF_CTGY_RMK_TMS_V --
  ----------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_dctv_rec                     IN dctv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_dct_rec                      dct_rec_type;
  BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(p_dctv_rec, l_dct_rec);
    --------------------------------------------
    -- Call the LOCK_ROW for each child record
    --------------------------------------------
    lock_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_dct_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END lock_row;
  --------------------------------------
  -- PL/SQL TBL lock_row for:DCTV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_dctv_tbl                     IN dctv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
    -- Begin Post-Generation Change
    -- overall error status
    l_overall_status               VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    -- End Post-Generation Change
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_dctv_tbl.COUNT > 0) THEN
      i := p_dctv_tbl.FIRST;
      LOOP
        lock_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_dctv_rec                     => p_dctv_tbl(i));
        -- Begin Post-Generation Change
        -- store the highest degree of error
        IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
           IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
              l_overall_status := x_return_status;
           END IF;
        END IF;
        -- End Post-Generation Change
        EXIT WHEN (i = p_dctv_tbl.LAST);
        i := p_dctv_tbl.NEXT(i);
      END LOOP;
      -- Begin Post-Generation Change
      -- return overall status
      x_return_status := l_overall_status;
      -- End Post-Generation Change
    END IF;
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END lock_row;

  ---------------------------------------------------------------------------
  -- PROCEDURE update_row
  ---------------------------------------------------------------------------
  ----------------------------------------
  -- update_row for:OKL_DF_CTGY_RMK_TMS --
  ----------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_dct_rec                      IN dct_rec_type,
    x_dct_rec                      OUT NOCOPY dct_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TMS_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_dct_rec                      dct_rec_type := p_dct_rec;
    l_def_dct_rec                  dct_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_dct_rec	IN dct_rec_type,
      x_dct_rec	OUT NOCOPY dct_rec_type
    ) RETURN VARCHAR2 IS
      l_dct_rec                      dct_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_dct_rec := p_dct_rec;
      -- Get current database values
      l_dct_rec := get_rec(p_dct_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_dct_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_dct_rec.id := l_dct_rec.id;
      END IF;
      IF (x_dct_rec.org_id = OKC_API.G_MISS_NUM)
      THEN
        x_dct_rec.org_id := l_dct_rec.org_id;
      END IF;
      IF (x_dct_rec.rmr_id = OKC_API.G_MISS_NUM)
      THEN
        x_dct_rec.rmr_id := l_dct_rec.rmr_id;
      END IF;
      IF (x_dct_rec.ico_id = OKC_API.G_MISS_NUM)
      THEN
        x_dct_rec.ico_id := l_dct_rec.ico_id;
      END IF;
      IF (x_dct_rec.iln_id = OKC_API.G_MISS_NUM)
      THEN
        x_dct_rec.iln_id := l_dct_rec.iln_id;
      END IF;
      IF (x_dct_rec.date_effective_from = OKC_API.G_MISS_DATE)
      THEN
        x_dct_rec.date_effective_from := l_dct_rec.date_effective_from;
      END IF;
      IF (x_dct_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_dct_rec.object_version_number := l_dct_rec.object_version_number;
      END IF;
      IF (x_dct_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_dct_rec.created_by := l_dct_rec.created_by;
      END IF;
      IF (x_dct_rec.date_effective_to = OKC_API.G_MISS_DATE)
      THEN
        x_dct_rec.date_effective_to := l_dct_rec.date_effective_to;
      END IF;
      IF (x_dct_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_dct_rec.creation_date := l_dct_rec.creation_date;
      END IF;
      IF (x_dct_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_dct_rec.last_updated_by := l_dct_rec.last_updated_by;
      END IF;
      IF (x_dct_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_dct_rec.last_update_date := l_dct_rec.last_update_date;
      END IF;
      IF (x_dct_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_dct_rec.last_update_login := l_dct_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    --------------------------------------------
    -- Set_Attributes for:OKL_DF_CTGY_RMK_TMS --
    --------------------------------------------
    FUNCTION Set_Attributes (
      p_dct_rec IN  dct_rec_type,
      x_dct_rec OUT NOCOPY dct_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_dct_rec := p_dct_rec;
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      p_dct_rec,                         -- IN
      l_dct_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_dct_rec, l_def_dct_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKL_DF_CTGY_RMK_TMS
    SET ORG_ID = l_def_dct_rec.org_id,
        RMR_ID = l_def_dct_rec.rmr_id,
        ICO_ID = l_def_dct_rec.ico_id,
        ILN_ID = l_def_dct_rec.iln_id,
        DATE_EFFECTIVE_FROM = l_def_dct_rec.date_effective_from,
        OBJECT_VERSION_NUMBER = l_def_dct_rec.object_version_number,
        CREATED_BY = l_def_dct_rec.created_by,
        DATE_EFFECTIVE_TO = l_def_dct_rec.date_effective_to,
        CREATION_DATE = l_def_dct_rec.creation_date,
        LAST_UPDATED_BY = l_def_dct_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_dct_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_dct_rec.last_update_login
    WHERE ID = l_def_dct_rec.id;

    x_dct_rec := l_def_dct_rec;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END update_row;
  ------------------------------------------
  -- update_row for:OKL_DF_CTGY_RMK_TMS_V --
  ------------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_dctv_rec                     IN dctv_rec_type,
    x_dctv_rec                     OUT NOCOPY dctv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_dctv_rec                     dctv_rec_type := p_dctv_rec;
    l_def_dctv_rec                 dctv_rec_type;
    l_dct_rec                      dct_rec_type;
    lx_dct_rec                     dct_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_dctv_rec	IN dctv_rec_type
    ) RETURN dctv_rec_type IS
      l_dctv_rec	dctv_rec_type := p_dctv_rec;
    BEGIN
      l_dctv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_dctv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_dctv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_dctv_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_dctv_rec	IN dctv_rec_type,
      x_dctv_rec	OUT NOCOPY dctv_rec_type
    ) RETURN VARCHAR2 IS
      l_dctv_rec                     dctv_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_dctv_rec := p_dctv_rec;
      -- Get current database values
      l_dctv_rec := get_rec(p_dctv_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_dctv_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_dctv_rec.id := l_dctv_rec.id;
      END IF;
      IF (x_dctv_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_dctv_rec.object_version_number := l_dctv_rec.object_version_number;
      END IF;
      IF (x_dctv_rec.org_id = OKC_API.G_MISS_NUM)
      THEN
        x_dctv_rec.org_id := l_dctv_rec.org_id;
      END IF;
      IF (x_dctv_rec.rmr_id = OKC_API.G_MISS_NUM)
      THEN
        x_dctv_rec.rmr_id := l_dctv_rec.rmr_id;
      END IF;
      IF (x_dctv_rec.ico_id = OKC_API.G_MISS_NUM)
      THEN
        x_dctv_rec.ico_id := l_dctv_rec.ico_id;
      END IF;
      IF (x_dctv_rec.iln_id = OKC_API.G_MISS_NUM)
      THEN
        x_dctv_rec.iln_id := l_dctv_rec.iln_id;
      END IF;
      IF (x_dctv_rec.date_effective_from = OKC_API.G_MISS_DATE)
      THEN
        x_dctv_rec.date_effective_from := l_dctv_rec.date_effective_from;
      END IF;
      IF (x_dctv_rec.date_effective_to = OKC_API.G_MISS_DATE)
      THEN
        x_dctv_rec.date_effective_to := l_dctv_rec.date_effective_to;
      END IF;
      IF (x_dctv_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_dctv_rec.created_by := l_dctv_rec.created_by;
      END IF;
      IF (x_dctv_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_dctv_rec.creation_date := l_dctv_rec.creation_date;
      END IF;
      IF (x_dctv_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_dctv_rec.last_updated_by := l_dctv_rec.last_updated_by;
      END IF;
      IF (x_dctv_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_dctv_rec.last_update_date := l_dctv_rec.last_update_date;
      END IF;
      IF (x_dctv_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_dctv_rec.last_update_login := l_dctv_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ----------------------------------------------
    -- Set_Attributes for:OKL_DF_CTGY_RMK_TMS_V --
    ----------------------------------------------
    FUNCTION Set_Attributes (
      p_dctv_rec IN  dctv_rec_type,
      x_dctv_rec OUT NOCOPY dctv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_dctv_rec := p_dctv_rec;
      x_dctv_rec.OBJECT_VERSION_NUMBER := NVL(x_dctv_rec.OBJECT_VERSION_NUMBER, 0) + 1;
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      p_dctv_rec,                        -- IN
      l_dctv_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_dctv_rec, l_def_dctv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_dctv_rec := fill_who_columns(l_def_dctv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_dctv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_dctv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_dctv_rec, l_dct_rec);
    --------------------------------------------
    -- Call the UPDATE_ROW for each child record
    --------------------------------------------
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_dct_rec,
      lx_dct_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_dct_rec, l_def_dctv_rec);
    x_dctv_rec := l_def_dctv_rec;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END update_row;
  ----------------------------------------
  -- PL/SQL TBL update_row for:DCTV_TBL --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_dctv_tbl                     IN dctv_tbl_type,
    x_dctv_tbl                     OUT NOCOPY dctv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
    -- Begin Post-Generation Change
    -- overall error status
    l_overall_status               VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    -- End Post-Generation Change
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_dctv_tbl.COUNT > 0) THEN
      i := p_dctv_tbl.FIRST;
      LOOP
        update_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_dctv_rec                     => p_dctv_tbl(i),
          x_dctv_rec                     => x_dctv_tbl(i));
        -- Begin Post-Generation Change
        -- store the highest degree of error
        IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
           IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
              l_overall_status := x_return_status;
           END IF;
        END IF;
        -- End Post-Generation Change
        EXIT WHEN (i = p_dctv_tbl.LAST);
        i := p_dctv_tbl.NEXT(i);
      END LOOP;
      -- Begin Post-Generation Change
      -- return overall status
      x_return_status := l_overall_status;
      -- End Post-Generation Change
    END IF;
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END update_row;

  ---------------------------------------------------------------------------
  -- PROCEDURE delete_row
  ---------------------------------------------------------------------------
  ----------------------------------------
  -- delete_row for:OKL_DF_CTGY_RMK_TMS --
  ----------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_dct_rec                      IN dct_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TMS_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_dct_rec                      dct_rec_type:= p_dct_rec;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    DELETE FROM OKL_DF_CTGY_RMK_TMS
     WHERE ID = l_dct_rec.id;

    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END delete_row;
  ------------------------------------------
  -- delete_row for:OKL_DF_CTGY_RMK_TMS_V --
  ------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_dctv_rec                     IN dctv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_dctv_rec                     dctv_rec_type := p_dctv_rec;
    l_dct_rec                      dct_rec_type;
  BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_dctv_rec, l_dct_rec);
    --------------------------------------------
    -- Call the DELETE_ROW for each child record
    --------------------------------------------
    delete_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_dct_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END delete_row;
  ----------------------------------------
  -- PL/SQL TBL delete_row for:DCTV_TBL --
  ----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_dctv_tbl                     IN dctv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
    -- Begin Post-Generation Change
    -- overall error status
    l_overall_status               VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    -- End Post-Generation Change
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_dctv_tbl.COUNT > 0) THEN
      i := p_dctv_tbl.FIRST;
      LOOP
        delete_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_dctv_rec                     => p_dctv_tbl(i));
        -- Begin Post-Generation Change
        -- store the highest degree of error
        IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
           IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
              l_overall_status := x_return_status;
           END IF;
        END IF;
        -- End Post-Generation Change
        EXIT WHEN (i = p_dctv_tbl.LAST);
        i := p_dctv_tbl.NEXT(i);
      END LOOP;
      -- Begin Post-Generation Change
      -- return overall status
      x_return_status := l_overall_status;
      -- End Post-Generation Change
    END IF;
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END delete_row;
END OKL_DCT_PVT;

/
