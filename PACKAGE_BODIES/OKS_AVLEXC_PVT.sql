--------------------------------------------------------
--  DDL for Package Body OKS_AVLEXC_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKS_AVLEXC_PVT" AS
/* $Header: OKSSEXCB.pls 120.0 2005/05/25 17:45:45 appldev noship $ */
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
  -- FUNCTION get_rec for: OKS_SERV_AVAIL_EXCEPTS
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_sax_rec                      IN sax_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN sax_rec_type IS
    CURSOR sax_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            SAV_ID,
            OBJECT1_ID1,
            OBJECT1_ID2,
            JTOT_OBJECT1_CODE,
            OBJECT_VERSION_NUMBER,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            MANUFACTURING_ORG_ID,
            REVISION_LOW,
            REVISION_HIGH,
            START_DATE_ACTIVE,
            END_DATE_ACTIVE,
            LAST_UPDATE_LOGIN,
            ATTRIBUTE_CATEGORY,
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
            ATTRIBUTE15
      FROM Oks_Serv_Avail_Excepts
     WHERE oks_serv_avail_excepts.id = p_id;
    l_sax_pk                       sax_pk_csr%ROWTYPE;
    l_sax_rec                      sax_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN sax_pk_csr (p_sax_rec.id);
    FETCH sax_pk_csr INTO
              l_sax_rec.ID,
              l_sax_rec.SAV_ID,
              l_sax_rec.OBJECT1_ID1,
              l_sax_rec.OBJECT1_ID2,
              l_sax_rec.JTOT_OBJECT1_CODE,
              l_sax_rec.OBJECT_VERSION_NUMBER,
              l_sax_rec.CREATED_BY,
              l_sax_rec.CREATION_DATE,
              l_sax_rec.LAST_UPDATED_BY,
              l_sax_rec.LAST_UPDATE_DATE,
              l_sax_rec.MANUFACTURING_ORG_ID,
              l_sax_rec.REVISION_LOW,
              l_sax_rec.REVISION_HIGH,
              l_sax_rec.START_DATE_ACTIVE,
              l_sax_rec.END_DATE_ACTIVE,
              l_sax_rec.LAST_UPDATE_LOGIN,
              l_sax_rec.ATTRIBUTE_CATEGORY,
              l_sax_rec.ATTRIBUTE1,
              l_sax_rec.ATTRIBUTE2,
              l_sax_rec.ATTRIBUTE3,
              l_sax_rec.ATTRIBUTE4,
              l_sax_rec.ATTRIBUTE5,
              l_sax_rec.ATTRIBUTE6,
              l_sax_rec.ATTRIBUTE7,
              l_sax_rec.ATTRIBUTE8,
              l_sax_rec.ATTRIBUTE9,
              l_sax_rec.ATTRIBUTE10,
              l_sax_rec.ATTRIBUTE11,
              l_sax_rec.ATTRIBUTE12,
              l_sax_rec.ATTRIBUTE13,
              l_sax_rec.ATTRIBUTE14,
              l_sax_rec.ATTRIBUTE15;
    x_no_data_found := sax_pk_csr%NOTFOUND;
    CLOSE sax_pk_csr;
    RETURN(l_sax_rec);
  END get_rec;

  FUNCTION get_rec (
    p_sax_rec                      IN sax_rec_type
  ) RETURN sax_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_sax_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKS_SERV_AVAIL_EXCEPTS_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_saxv_rec                     IN saxv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN saxv_rec_type IS
    CURSOR oks_saxv_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            SAV_ID,
            OBJECT1_ID1,
            OBJECT1_ID2,
            JTOT_OBJECT1_CODE,
            OBJECT_VERSION_NUMBER,
            MANUFACTURING_ORG_ID,
            REVISION_LOW,
            REVISION_HIGH,
            START_DATE_ACTIVE,
            END_DATE_ACTIVE,
            ATTRIBUTE_CATEGORY,
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
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
      FROM Oks_Serv_Avail_Excepts_V
     WHERE oks_serv_avail_excepts_v.id = p_id;
    l_oks_saxv_pk                  oks_saxv_pk_csr%ROWTYPE;
    l_saxv_rec                     saxv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN oks_saxv_pk_csr (p_saxv_rec.id);
    FETCH oks_saxv_pk_csr INTO
              l_saxv_rec.ID,
              l_saxv_rec.SAV_ID,
              l_saxv_rec.OBJECT1_ID1,
              l_saxv_rec.OBJECT1_ID2,
              l_saxv_rec.JTOT_OBJECT1_CODE,
              l_saxv_rec.OBJECT_VERSION_NUMBER,
              l_saxv_rec.MANUFACTURING_ORG_ID,
              l_saxv_rec.REVISION_LOW,
              l_saxv_rec.REVISION_HIGH,
              l_saxv_rec.START_DATE_ACTIVE,
              l_saxv_rec.END_DATE_ACTIVE,
              l_saxv_rec.ATTRIBUTE_CATEGORY,
              l_saxv_rec.ATTRIBUTE1,
              l_saxv_rec.ATTRIBUTE2,
              l_saxv_rec.ATTRIBUTE3,
              l_saxv_rec.ATTRIBUTE4,
              l_saxv_rec.ATTRIBUTE5,
              l_saxv_rec.ATTRIBUTE6,
              l_saxv_rec.ATTRIBUTE7,
              l_saxv_rec.ATTRIBUTE8,
              l_saxv_rec.ATTRIBUTE9,
              l_saxv_rec.ATTRIBUTE10,
              l_saxv_rec.ATTRIBUTE11,
              l_saxv_rec.ATTRIBUTE12,
              l_saxv_rec.ATTRIBUTE13,
              l_saxv_rec.ATTRIBUTE14,
              l_saxv_rec.ATTRIBUTE15,
              l_saxv_rec.CREATED_BY,
              l_saxv_rec.CREATION_DATE,
              l_saxv_rec.LAST_UPDATED_BY,
              l_saxv_rec.LAST_UPDATE_DATE,
              l_saxv_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := oks_saxv_pk_csr%NOTFOUND;
    CLOSE oks_saxv_pk_csr;
    RETURN(l_saxv_rec);
  END get_rec;

  FUNCTION get_rec (
    p_saxv_rec                     IN saxv_rec_type
  ) RETURN saxv_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_saxv_rec, l_row_notfound));
  END get_rec;

  --------------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKS_SERV_AVAIL_EXCEPTS_V --
  --------------------------------------------------------------
  FUNCTION null_out_defaults (
    p_saxv_rec	IN saxv_rec_type
  ) RETURN saxv_rec_type IS
    l_saxv_rec	saxv_rec_type := p_saxv_rec;
  BEGIN
    IF (l_saxv_rec.sav_id = OKC_API.G_MISS_NUM) THEN
      l_saxv_rec.sav_id := NULL;
    END IF;
    IF (l_saxv_rec.object1_id1 = OKC_API.G_MISS_CHAR) THEN
      l_saxv_rec.object1_id1 := NULL;
    END IF;
    IF (l_saxv_rec.object1_id2 = OKC_API.G_MISS_CHAR) THEN
      l_saxv_rec.object1_id2 := NULL;
    END IF;
    IF (l_saxv_rec.JTOT_OBJECT1_CODE = OKC_API.G_MISS_CHAR) THEN
      l_saxv_rec.JTOT_OBJECT1_CODE := NULL;
    END IF;
    IF (l_saxv_rec.object_version_number = OKC_API.G_MISS_NUM) THEN
      l_saxv_rec.object_version_number := NULL;
    END IF;
    IF (l_saxv_rec.manufacturing_org_id = OKC_API.G_MISS_NUM) THEN
      l_saxv_rec.manufacturing_org_id := NULL;
    END IF;
    IF (l_saxv_rec.revision_low = OKC_API.G_MISS_CHAR) THEN
      l_saxv_rec.revision_low := NULL;
    END IF;
    IF (l_saxv_rec.revision_high = OKC_API.G_MISS_CHAR) THEN
      l_saxv_rec.revision_high := NULL;
    END IF;
    IF (l_saxv_rec.start_date_active = OKC_API.G_MISS_DATE) THEN
      l_saxv_rec.start_date_active := NULL;
    END IF;
    IF (l_saxv_rec.end_date_active = OKC_API.G_MISS_DATE) THEN
      l_saxv_rec.end_date_active := NULL;
    END IF;
    IF (l_saxv_rec.attribute_category = OKC_API.G_MISS_CHAR) THEN
      l_saxv_rec.attribute_category := NULL;
    END IF;
    IF (l_saxv_rec.attribute1 = OKC_API.G_MISS_CHAR) THEN
      l_saxv_rec.attribute1 := NULL;
    END IF;
    IF (l_saxv_rec.attribute2 = OKC_API.G_MISS_CHAR) THEN
      l_saxv_rec.attribute2 := NULL;
    END IF;
    IF (l_saxv_rec.attribute3 = OKC_API.G_MISS_CHAR) THEN
      l_saxv_rec.attribute3 := NULL;
    END IF;
    IF (l_saxv_rec.attribute4 = OKC_API.G_MISS_CHAR) THEN
      l_saxv_rec.attribute4 := NULL;
    END IF;
    IF (l_saxv_rec.attribute5 = OKC_API.G_MISS_CHAR) THEN
      l_saxv_rec.attribute5 := NULL;
    END IF;
    IF (l_saxv_rec.attribute6 = OKC_API.G_MISS_CHAR) THEN
      l_saxv_rec.attribute6 := NULL;
    END IF;
    IF (l_saxv_rec.attribute7 = OKC_API.G_MISS_CHAR) THEN
      l_saxv_rec.attribute7 := NULL;
    END IF;
    IF (l_saxv_rec.attribute8 = OKC_API.G_MISS_CHAR) THEN
      l_saxv_rec.attribute8 := NULL;
    END IF;
    IF (l_saxv_rec.attribute9 = OKC_API.G_MISS_CHAR) THEN
      l_saxv_rec.attribute9 := NULL;
    END IF;
    IF (l_saxv_rec.attribute10 = OKC_API.G_MISS_CHAR) THEN
      l_saxv_rec.attribute10 := NULL;
    END IF;
    IF (l_saxv_rec.attribute11 = OKC_API.G_MISS_CHAR) THEN
      l_saxv_rec.attribute11 := NULL;
    END IF;
    IF (l_saxv_rec.attribute12 = OKC_API.G_MISS_CHAR) THEN
      l_saxv_rec.attribute12 := NULL;
    END IF;
    IF (l_saxv_rec.attribute13 = OKC_API.G_MISS_CHAR) THEN
      l_saxv_rec.attribute13 := NULL;
    END IF;
    IF (l_saxv_rec.attribute14 = OKC_API.G_MISS_CHAR) THEN
      l_saxv_rec.attribute14 := NULL;
    END IF;
    IF (l_saxv_rec.attribute15 = OKC_API.G_MISS_CHAR) THEN
      l_saxv_rec.attribute15 := NULL;
    END IF;
    IF (l_saxv_rec.created_by = OKC_API.G_MISS_NUM) THEN
      l_saxv_rec.created_by := NULL;
    END IF;
    IF (l_saxv_rec.creation_date = OKC_API.G_MISS_DATE) THEN
      l_saxv_rec.creation_date := NULL;
    END IF;
    IF (l_saxv_rec.last_updated_by = OKC_API.G_MISS_NUM) THEN
      l_saxv_rec.last_updated_by := NULL;
    END IF;
    IF (l_saxv_rec.last_update_date = OKC_API.G_MISS_DATE) THEN
      l_saxv_rec.last_update_date := NULL;
    END IF;
    IF (l_saxv_rec.last_update_login = OKC_API.G_MISS_NUM) THEN
      l_saxv_rec.last_update_login := NULL;
    END IF;
    RETURN(l_saxv_rec);
  END null_out_defaults;
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Attributes
  ---------------------------------------------------------------------------
PROCEDURE validate_id(x_return_status OUT NOCOPY varchar2,
                      p_service_availability_id  IN  Number)
 Is
  l_return_status    VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
  Begin

  If p_service_availability_id   = OKC_API.G_MISS_NUM OR
     p_service_availability_id   IS NULL
  Then
     OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'service_availability_id ');
     l_return_status := OKC_API.G_RET_STS_ERROR;
  End If;

  Exception
  When  G_EXCEPTION_HALT_VALIDATION THEN
        NULL;
  When OTHERS THEN
  -- store SQL error message on message stack for caller
      OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => sqlcode,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => sqlerrm);

    -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  End validate_id;

PROCEDURE validate_sav_id(x_return_status OUT NOCOPY varchar2,
                          P_sav_id IN  Number)
Is
l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
l_dummy_var   VARCHAR2(1) := '?';
Cursor l_Srv_Csr Is
  	  select 'x'
	  from OKS_SERV_AVAILS_V
  	  where id = P_sav_id;

Begin
If p_sav_id  = OKC_API.G_MISS_NUM OR
      p_sav_id  IS NULL
Then
     OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'sav_id');

     l_return_status := OKC_API.G_RET_STS_ERROR;
     RAISE G_EXCEPTION_HALT_VALIDATION;
End If;

If (not p_sav_id = OKC_API.G_MISS_NUM and
  	   p_sav_id IS NOT NULL)
    Then
       Open l_srv_csr;
       Fetch l_srv_csr Into l_dummy_var;
       Close l_srv_csr;
       -- if l_dummy_var still set to default, data was not found
       If (l_dummy_var = '?') Then
  	          OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => sqlcode,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => 'Sav_id ');

	     -- notify caller of an error
          x_return_status := OKC_API.G_RET_STS_ERROR;
      End If;
    End If;
  -- call column length utility

/* OKC_UTIL.CHECK_LENGTH
 (
             p_view_name     => 'OKS_SERV_AVAIL_EXCEPTS_V'
            ,p_col_name      => 'sav_id'
            ,p_col_value     => p_sav_id
            ,x_return_status => l_return_status
  );


  -- verify that length is within allowed limits
  If (not l_return_status = OKC_API.G_RET_STS_SUCCESS) then
      OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => sqlcode,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => 'Sav_id Length');


-- notify caller of an error
       x_return_status := OKC_API.G_RET_STS_ERROR;
 -- halt further validation of this column
      RAISE G_EXCEPTION_HALT_VALIDATION;
 End If;
*/
 Exception
  When  G_EXCEPTION_HALT_VALIDATION Then
        NULL;
 When OTHERS Then
 -- store SQL error message on message stack for caller
       OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                           p_msg_name     => g_unexpected_error,
                           p_token1       => g_sqlcode_token,
                           p_token1_value => sqlcode,
                           p_token2       => g_sqlerrm_token,
                           p_token2_value => sqlerrm);

-- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
 END validate_sav_id;


PROCEDURE validate_JTOT_OBJECT1_CODE(x_return_status OUT NOCOPY varchar2,
                                    P_JTOT_OBJECT1_CODE  Varchar2)
  Is
  l_return_status   VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
  Begin

       x_return_status := OKC_API.G_RET_STS_SUCCESS;


       If P_JTOT_OBJECT1_CODE = OKC_API.G_MISS_CHAR OR
          P_JTOT_OBJECT1_CODE IS NULL
       Then
           OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'JTOT_OBJECT1_CODE' );
           x_return_status := OKC_API.G_RET_STS_ERROR;
           RAISE G_EXCEPTION_HALT_VALIDATION;
       End If;
  -- call column length utility
    /*   OKC_UTIL.CHECK_LENGTH
       (
         p_view_name     => 'OKS_SERV_AVAIL_EXCEPTS_V'
        ,p_col_name      => 'JTOT_OBJECT1_CODE'
        ,p_col_value     => P_JTOT_OBJECT1_CODE
        ,x_return_status => l_return_status
       );
  -- verify that length is within allowed limits
       If (not l_return_status = OKC_API.G_RET_STS_SUCCESS) then
           OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                               p_msg_name     => g_unexpected_error,
                               p_token1       => g_sqlcode_token,
                               p_token1_value => sqlcode,
                               p_token2       => g_sqlerrm_token,
                               p_token2_value => 'except_JTOT_OBJECT1_CODE length');
  -- notify caller of an error
           x_return_status := OKC_API.G_RET_STS_ERROR;
  -- halt further validation of this column
           RAISE G_EXCEPTION_HALT_VALIDATION;
       End If;
*/
  Exception
  When  G_EXCEPTION_HALT_VALIDATION Then
       NULL;
  When OTHERS Then
   -- store SQL error message on message stack for caller
      OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => sqlcode,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => sqlerrm);

   -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END validate_JTOT_OBJECT1_CODE;





PROCEDURE validate_objvernum(x_return_status OUT NOCOPY varchar2,
					 P_object_version_number IN  Number)
  Is
  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
  Begin

  If p_object_version_number = OKC_API.G_MISS_NUM OR
       p_object_version_number IS NULL
  Then
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'object_version_number');
      l_return_status := OKC_API.G_RET_STS_ERROR;

	RAISE G_EXCEPTION_HALT_VALIDATION;
  End If;

    -- call column length utility
  OKC_UTIL.CHECK_LENGTH
  (
		 p_view_name     => 'OKS_SERV_AVAIL_EXCEPTS_V'
            ,p_col_name      => 'object_version_number'
            ,p_col_value     => p_object_version_number
            ,x_return_status => l_return_status
   );

   -- verify that length is within allowed limits
   If (not l_return_status = OKC_API.G_RET_STS_SUCCESS) then
	OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => sqlcode,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => 'object version Length');


	-- notify caller of an error
	x_return_status := OKC_API.G_RET_STS_ERROR;
	-- halt further validation of this column
	RAISE G_EXCEPTION_HALT_VALIDATION;
  End If;

  Exception
  When  G_EXCEPTION_HALT_VALIDATION Then
		NULL;
  When OTHERS Then
	-- store SQL error message on message stack for caller
	OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => sqlcode,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => sqlerrm);

      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END validate_objvernum;

PROCEDURE validate_manufacturing_org_id(	x_return_status OUT NOCOPY varchar2,
							 P_manufacturing_org_id IN  NUMBER)
  Is
  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
  Begin

  If P_manufacturing_org_id = OKC_API.G_MISS_NUM OR
       P_manufacturing_org_id IS NULL
  Then
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'manufacturing_org_id' );
      l_return_status := OKC_API.G_RET_STS_ERROR;

	RAISE G_EXCEPTION_HALT_VALIDATION;
  End If;

    -- call column length utility
  OKC_UTIL.CHECK_LENGTH
  (
		 p_view_name     => 'OKS_SERV_AVAIL_EXCEPTS_V'
            ,p_col_name      => 'manufacturing_org_id'
            ,p_col_value     => P_manufacturing_org_id
            ,x_return_status => l_return_status
   );

   -- verify that length is within allowed limits
   If (not l_return_status = OKC_API.G_RET_STS_SUCCESS) then
	OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => sqlcode,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => 'manufacturing org_id Length');


	-- notify caller of an error
	x_return_status := OKC_API.G_RET_STS_ERROR;
	-- halt further validation of this column
	RAISE G_EXCEPTION_HALT_VALIDATION;
  End If;

  Exception
  When  G_EXCEPTION_HALT_VALIDATION Then
		NULL;
  When OTHERS Then
	-- store SQL error message on message stack for caller
	OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => sqlcode,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => sqlerrm);

      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END validate_manufacturing_org_id;


 PROCEDURE validate_revision_high(	x_return_status OUT NOCOPY varchar2,
							 P_revision_high IN  varchar2)
  Is
  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
  Begin

  /*If P_revision_high = OKC_API.G_MISS_CHAR OR
       P_revision_high IS NULL
  Then
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'revision_high');
      l_return_status := OKC_API.G_RET_STS_ERROR;

	RAISE G_EXCEPTION_HALT_VALIDATION;
  End If;*/

    -- call column length utility
  OKC_UTIL.CHECK_LENGTH
  (
		 p_view_name     => 'OKS_SERV_AVAIL_EXCEPTS_V'
            ,p_col_name      => 'revision_high'
            ,p_col_value     => P_revision_high
            ,x_return_status => l_return_status
   );

   -- verify that length is within allowed limits
   If (not l_return_status = OKC_API.G_RET_STS_SUCCESS) then
	OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => sqlcode,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => 'Revision High Length');


	-- notify caller of an error
	x_return_status := OKC_API.G_RET_STS_ERROR;
	-- halt further validation of this column
	RAISE G_EXCEPTION_HALT_VALIDATION;
  End If;

  Exception
  When  G_EXCEPTION_HALT_VALIDATION Then
		NULL;
  When OTHERS Then
	-- store SQL error message on message stack for caller
	OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => sqlcode,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => sqlerrm);

      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END validate_revision_high;


PROCEDURE validate_revision_low(	x_return_status OUT NOCOPY varchar2,
							 P_revision_low IN  varchar2)
  Is
  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
  Begin

   /* If P_revision_low = OKC_API.G_MISS_CHAR OR
       P_revision_low IS NULL
    Then
       OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'revision_low' );
       l_return_status := OKC_API.G_RET_STS_ERROR;

       RAISE G_EXCEPTION_HALT_VALIDATION;
    End If;

     -- call column length utility
  OKC_UTIL.CHECK_LENGTH
  (
		 p_view_name     => 'OKS_SERV_AVAIL_EXCEPTS_V'
            ,p_col_name      => 'revision_low'
            ,p_col_value     => P_revision_low
            ,x_return_status => l_return_status
   );

   -- verify that length is within allowed limits
   If (not l_return_status = OKC_API.G_RET_STS_SUCCESS) then
	OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => sqlcode,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => 'Revision Low Length');


	-- notify caller of an error
	x_return_status := OKC_API.G_RET_STS_ERROR;
	-- halt further validation of this column
	RAISE G_EXCEPTION_HALT_VALIDATION;
  End If;
*/
null;
  Exception
  When  G_EXCEPTION_HALT_VALIDATION Then
		NULL;
  When OTHERS Then
	-- store SQL error message on message stack for caller
	OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => sqlcode,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => sqlerrm);

      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END validate_revision_low;



PROCEDURE validate_object1_id1(	x_return_status OUT NOCOPY varchar2,
							 P_object1_id1 IN  varchar2)
  Is
  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
  Begin

  If P_object1_id1 = OKC_API.G_MISS_CHAR OR
       P_object1_id1 IS NULL
  Then
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'object1_id1' );
      l_return_status := OKC_API.G_RET_STS_ERROR;

	RAISE G_EXCEPTION_HALT_VALIDATION;
  End If;

    -- call column length utility
  OKC_UTIL.CHECK_LENGTH
  (
		 p_view_name     => 'OKS_SERV_AVAIL_EXCEPTS_V'
            ,p_col_name      => 'object1_id1'
            ,p_col_value     => P_object1_id1
            ,x_return_status => l_return_status
   );

   -- verify that length is within allowed limits
   If (not l_return_status = OKC_API.G_RET_STS_SUCCESS) then
	OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => sqlcode,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => 'object1_id1 Length');


	-- notify caller of an error
	x_return_status := OKC_API.G_RET_STS_ERROR;
	-- halt further validation of this column
	RAISE G_EXCEPTION_HALT_VALIDATION;
  End If;

  Exception
  When  G_EXCEPTION_HALT_VALIDATION Then
		NULL;
  When OTHERS Then
	-- store SQL error message on message stack for caller
	OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => sqlcode,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => sqlerrm);

      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END validate_object1_id1;




PROCEDURE validate_object1_id2(x_return_status OUT NOCOPY varchar2,
							 P_object1_id2 IN  varchar2)
  Is
  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
  Begin

  If P_object1_id2 = OKC_API.G_MISS_CHAR OR
       P_object1_id2 IS NULL
  Then
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'object1_id2' );
      l_return_status := OKC_API.G_RET_STS_ERROR;

	RAISE G_EXCEPTION_HALT_VALIDATION;
  End If;

    -- call column length utility
  OKC_UTIL.CHECK_LENGTH
  (
		 p_view_name     => 'OKS_SERV_AVAIL_EXCEPTS_V'
            ,p_col_name      => 'object1_id2'
            ,p_col_value     => P_object1_id2
            ,x_return_status => l_return_status
   );

   -- verify that length is within allowed limits
   If (not l_return_status = OKC_API.G_RET_STS_SUCCESS) then
	OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => sqlcode,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => 'object1_id2 Length');


	-- notify caller of an error
	x_return_status := OKC_API.G_RET_STS_ERROR;
	-- halt further validation of this column
	RAISE G_EXCEPTION_HALT_VALIDATION;
  End If;

  Exception
  When  G_EXCEPTION_HALT_VALIDATION Then
		NULL;
  When OTHERS Then
	-- store SQL error message on message stack for caller
	OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => sqlcode,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => sqlerrm);

      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END validate_object1_id2;


PROCEDURE validate_attribute_category(x_return_status OUT NOCOPY varchar2,
                                      P_attribute_category IN  varchar)
  Is
  l_return_status    VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
  Begin

  x_return_status := OKC_API.G_RET_STS_SUCCESS;


 -- call column length utility
  OKC_UTIL.CHECK_LENGTH
  (
		 p_view_name     => 'OKS_SERV_AVAIL_EXCEPTS_V'
            ,p_col_name      => 'attribute_category'
            ,p_col_value     => p_attribute_category
            ,x_return_status => l_return_status
   );

   -- verify that length is within allowed limits
   If (not l_return_status = OKC_API.G_RET_STS_SUCCESS) then
	OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => sqlcode,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => 'attribute category Length');


	-- notify caller of an error
	x_return_status := OKC_API.G_RET_STS_ERROR;
	-- halt further validation of this column
	RAISE G_EXCEPTION_HALT_VALIDATION;
  End If;


  Exception
  When  G_EXCEPTION_HALT_VALIDATION Then
		NULL;
  When OTHERS Then
	-- store SQL error message on message stack for caller
	OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => sqlcode,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => sqlerrm);

      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END validate_attribute_category;


PROCEDURE validate_attribute1(x_return_status OUT NOCOPY varchar2,
                              P_attribute1 IN  varchar2)
 Is
 l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
 Begin
      x_return_status := OKC_API.G_RET_STS_SUCCESS;
     -- call column length utility
     OKC_UTIL.CHECK_LENGTH
     (
       p_view_name     => 'OKS_SERV_AVAIL_EXCEPTS_V'
      ,p_col_name      => 'attribute1'
      ,p_col_value     => p_attribute1
      ,x_return_status => l_return_status
      );
  -- verify that length is within allowed limits
  If (not l_return_status = OKC_API.G_RET_STS_SUCCESS) then
     OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                         p_msg_name     => g_unexpected_error,
                         p_token1       => g_sqlcode_token,
                         p_token1_value => sqlcode,
                         p_token2       => g_sqlerrm_token,
                         p_token2_value => 'attribute 1 Length');
  -- notify caller of an error
     x_return_status := OKC_API.G_RET_STS_ERROR;
    -- halt further validation of this column
     RAISE G_EXCEPTION_HALT_VALIDATION;
  End If;

  Exception
  When  G_EXCEPTION_HALT_VALIDATION Then
       NULL;
  When OTHERS Then
 -- store SQL error message on message stack for caller
      OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => sqlcode,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => sqlerrm);

  -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
 END validate_attribute1;

PROCEDURE validate_attribute2(x_return_status OUT NOCOPY varchar2,
                               P_attribute2 IN  varchar2)
  Is
  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
  Begin

  x_return_status := OKC_API.G_RET_STS_SUCCESS;

  -- call column length utility
  OKC_UTIL.CHECK_LENGTH
  (
             p_view_name     => 'OKS_SERV_AVAIL_EXCEPTS_V'
            ,p_col_name      => 'attribute2'
            ,p_col_value     => p_attribute2
            ,x_return_status => l_return_status
   );

   -- verify that length is within allowed limits
   If (not l_return_status = OKC_API.G_RET_STS_SUCCESS) then
      OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => sqlcode,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => 'attribute 2 Length');

 -- notify caller of an error
     x_return_status := OKC_API.G_RET_STS_ERROR;
 -- halt further validation of this column
     RAISE G_EXCEPTION_HALT_VALIDATION;
  End If;

  Exception
  When  G_EXCEPTION_HALT_VALIDATION Then
        NULL;
  When OTHERS Then
   -- store SQL error message on message stack for caller
       OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                           p_msg_name     => g_unexpected_error,
                           p_token1       => g_sqlcode_token,
                           p_token1_value => sqlcode,
                           p_token2       => g_sqlerrm_token,
                           p_token2_value => sqlerrm);

    -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END validate_attribute2;


PROCEDURE validate_attribute3(x_return_status OUT NOCOPY varchar2,
                              P_attribute3 IN  varchar2)
Is
l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
Begin
  x_return_status := OKC_API.G_RET_STS_SUCCESS;
  -- call column length utility
  OKC_UTIL.CHECK_LENGTH
  (
    p_view_name     => 'OKS_SERV_AVAIL_EXCEPTS_V'
   ,p_col_name      => 'attribute3'
   ,p_col_value     => p_attribute3
   ,x_return_status => l_return_status
  );

  -- verify that length is within allowed limits
 If (not l_return_status = OKC_API.G_RET_STS_SUCCESS) then
    OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                        p_msg_name     => g_unexpected_error,
                        p_token1       => g_sqlcode_token,
                        p_token1_value => sqlcode,
                        p_token2       => g_sqlerrm_token,
                        p_token2_value => 'attribute 3 Length');
  -- notify caller of an error
    x_return_status := OKC_API.G_RET_STS_ERROR;
  -- halt further validation of this column
    RAISE G_EXCEPTION_HALT_VALIDATION;
 End If;

 Exception
 When  G_EXCEPTION_HALT_VALIDATION Then
      NULL;
 When OTHERS Then
   -- store SQL error message on message stack for caller
      OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => sqlcode,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => sqlerrm);
   -- notify caller of an UNEXPECTED error
     x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
 END validate_attribute3;

PROCEDURE validate_attribute4 (x_return_status OUT NOCOPY varchar2,
                               P_attribute4 IN  varchar2)
  Is
  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
  Begin

  x_return_status := OKC_API.G_RET_STS_SUCCESS;

 -- call column length utility
OKC_UTIL.CHECK_LENGTH
(
 p_view_name     => 'OKS_SERV_AVAIL_EXCEPTS_V'
 ,p_col_name      => 'attribute4'
 ,p_col_value     => p_attribute4
 ,x_return_status => l_return_status
);

-- verify that length is within allowed limits
If (not l_return_status = OKC_API.G_RET_STS_SUCCESS) then
    OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                        p_msg_name     => g_unexpected_error,
                        p_token1       => g_sqlcode_token,
                        p_token1_value => sqlcode,
                        p_token2       => g_sqlerrm_token,
                        p_token2_value => 'attribute 4 Length');
-- notify caller of an error
    x_return_status := OKC_API.G_RET_STS_ERROR;
 -- halt further validation of this column
    RAISE G_EXCEPTION_HALT_VALIDATION;
 End If;

Exception
When  G_EXCEPTION_HALT_VALIDATION Then
      NULL;
When OTHERS Then
-- store SQL error message on message stack for caller
    OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                        p_msg_name     => g_unexpected_error,
                        p_token1       => g_sqlcode_token,
                        p_token1_value => sqlcode,
                        p_token2       => g_sqlerrm_token,
                        p_token2_value => sqlerrm);

-- notify caller of an UNEXPECTED error
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
END validate_attribute4;


PROCEDURE validate_attribute5(x_return_status OUT NOCOPY varchar2,
                              P_attribute5 IN  varchar2)
  Is
  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
  Begin

 x_return_status := OKC_API.G_RET_STS_SUCCESS;
 -- call column length utility
 OKC_UTIL.CHECK_LENGTH
  (
   p_view_name     => 'OKS_SERV_AVAIL_EXCEPTS_V'
  ,p_col_name      => 'attribute5'
  ,p_col_value     => p_attribute5
  ,x_return_status => l_return_status
  );

  -- verify that length is within allowed limits
  If (not l_return_status = OKC_API.G_RET_STS_SUCCESS) then
      OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => sqlcode,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => 'attribute 5 Length');

 -- notify caller of an error
    x_return_status := OKC_API.G_RET_STS_ERROR;
-- halt further validation of this column
    RAISE G_EXCEPTION_HALT_VALIDATION;
End If;

Exception
When  G_EXCEPTION_HALT_VALIDATION Then
      NULL;
When OTHERS Then
-- store SQL error message on message stack for caller
   OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                       p_msg_name     => g_unexpected_error,
                       p_token1       => g_sqlcode_token,
                       p_token1_value => sqlcode,
                       p_token2       => g_sqlerrm_token,
                       p_token2_value => sqlerrm);

 -- notify caller of an UNEXPECTED error
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
END validate_attribute5;

PROCEDURE validate_attribute6(x_return_status OUT NOCOPY varchar2,
                              P_attribute6 IN  varchar2)
 Is
 l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
 Begin
      x_return_status := OKC_API.G_RET_STS_SUCCESS;
     -- call column length utility
     OKC_UTIL.CHECK_LENGTH
     (
       p_view_name     => 'OKS_SERV_AVAIL_EXCEPTS_V'
      ,p_col_name      => 'attribute6'
      ,p_col_value     => p_attribute6
      ,x_return_status => l_return_status
      );
  -- verify that length is within allowed limits
  If (not l_return_status = OKC_API.G_RET_STS_SUCCESS) then
     OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                         p_msg_name     => g_unexpected_error,
                         p_token1       => g_sqlcode_token,
                         p_token1_value => sqlcode,
                         p_token2       => g_sqlerrm_token,
                         p_token2_value => 'attribute 6 Length');
  -- notify caller of an error
     x_return_status := OKC_API.G_RET_STS_ERROR;
    -- halt further validation of this column
     RAISE G_EXCEPTION_HALT_VALIDATION;
  End If;

  Exception
  When  G_EXCEPTION_HALT_VALIDATION Then
       NULL;
  When OTHERS Then
 -- store SQL error message on message stack for caller
      OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => sqlcode,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => sqlerrm);

  -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
 END validate_attribute6;

PROCEDURE validate_attribute7(x_return_status OUT NOCOPY varchar2,
                              P_attribute7 IN  varchar2)
  Is
  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
  Begin

  x_return_status := OKC_API.G_RET_STS_SUCCESS;

  -- call column length utility
  OKC_UTIL.CHECK_LENGTH
  (
             p_view_name     => 'OKS_SERV_AVAIL_EXCEPTS_V'
            ,p_col_name      => 'attribute7'
            ,p_col_value     => p_attribute7
            ,x_return_status => l_return_status
   );

  -- verify that length is within allowed limits
   If (not l_return_status = OKC_API.G_RET_STS_SUCCESS) then
      OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => sqlcode,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => 'attribute 7 Length');

-- notify caller of an error
     x_return_status := OKC_API.G_RET_STS_ERROR;
 -- halt further validation of this column
     RAISE G_EXCEPTION_HALT_VALIDATION;
End If;

Exception
When  G_EXCEPTION_HALT_VALIDATION Then
      NULL;
When OTHERS Then
-- store SQL error message on message stack for caller
     OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => sqlcode,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => sqlerrm);

-- notify caller of an UNEXPECTED error
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
END validate_attribute7;


PROCEDURE validate_attribute8(x_return_status OUT NOCOPY varchar2,
                              P_attribute8 IN  varchar2)
Is
l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
Begin
  x_return_status := OKC_API.G_RET_STS_SUCCESS;
  -- call column length utility
  OKC_UTIL.CHECK_LENGTH
  (
    p_view_name     => 'OKS_SERV_AVAIL_EXCEPTS_V'
   ,p_col_name      => 'attribute8'
   ,p_col_value     => p_attribute8
   ,x_return_status => l_return_status
  );

  -- verify that length is within allowed limits
 If (l_return_status <> OKC_API.G_RET_STS_SUCCESS) then
    OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                        p_msg_name     => g_unexpected_error,
                        p_token1       => g_sqlcode_token,
                        p_token1_value => sqlcode,
                        p_token2       => g_sqlerrm_token,
                        p_token2_value => 'attribute 8 Length');
  -- notify caller of an error
    x_return_status := OKC_API.G_RET_STS_ERROR;
  -- halt further validation of this column
    RAISE G_EXCEPTION_HALT_VALIDATION;
 End If;

 Exception
 When  G_EXCEPTION_HALT_VALIDATION Then
      NULL;
 When OTHERS Then
   -- store SQL error message on message stack for caller
      OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => sqlcode,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => sqlerrm);
   -- notify caller of an UNEXPECTED error
     x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
 END validate_attribute8;

PROCEDURE validate_attribute9 (x_return_status OUT NOCOPY varchar2,
                               P_attribute9 IN  varchar2)
  Is
  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
  Begin

  x_return_status := OKC_API.G_RET_STS_SUCCESS;

 -- call column length utility
OKC_UTIL.CHECK_LENGTH
(
 p_view_name     => 'OKS_SERV_AVAIL_EXCEPTS_V'
 ,p_col_name      => 'attribute9'
 ,p_col_value     => p_attribute9
 ,x_return_status => l_return_status
);

-- verify that length is within allowed limits
If (l_return_status <> OKC_API.G_RET_STS_SUCCESS) then
    OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                        p_msg_name     => g_unexpected_error,
                        p_token1       => g_sqlcode_token,
                        p_token1_value => sqlcode,
                        p_token2       => g_sqlerrm_token,
                        p_token2_value => 'attribute 9 Length');
-- notify caller of an error
    x_return_status := OKC_API.G_RET_STS_ERROR;
 -- halt further validation of this column
    RAISE G_EXCEPTION_HALT_VALIDATION;
 End If;

Exception
When  G_EXCEPTION_HALT_VALIDATION Then
      NULL;
When OTHERS Then
-- store SQL error message on message stack for caller
    OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                        p_msg_name     => g_unexpected_error,
                        p_token1       => g_sqlcode_token,
                        p_token1_value => sqlcode,
                        p_token2       => g_sqlerrm_token,
                        p_token2_value => sqlerrm);

-- notify caller of an UNEXPECTED error
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
END validate_attribute9;


PROCEDURE validate_attribute10(x_return_status OUT NOCOPY varchar2,
                              P_attribute10 IN  varchar2)
  Is
  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
  Begin

 x_return_status := OKC_API.G_RET_STS_SUCCESS;
 -- call column length utility
 OKC_UTIL.CHECK_LENGTH
  (
   p_view_name     => 'OKS_SERV_AVAIL_EXCEPTS_V'
  ,p_col_name      => 'attribute10'
  ,p_col_value     => p_attribute10
  ,x_return_status => l_return_status
  );

  -- verify that length is within allowed limits
  If (l_return_status <> OKC_API.G_RET_STS_SUCCESS) then
      OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => sqlcode,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => 'attribute 10 Length');

 -- notify caller of an error
    x_return_status := OKC_API.G_RET_STS_ERROR;
-- halt further validation of this column
    RAISE G_EXCEPTION_HALT_VALIDATION;
End If;

Exception
When  G_EXCEPTION_HALT_VALIDATION Then
      NULL;
When OTHERS Then
-- store SQL error message on message stack for caller
   OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                       p_msg_name     => g_unexpected_error,
                       p_token1       => g_sqlcode_token,
                       p_token1_value => sqlcode,
                       p_token2       => g_sqlerrm_token,
                       p_token2_value => sqlerrm);

 -- notify caller of an UNEXPECTED error
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
END validate_attribute10;

  PROCEDURE validate_attribute11(x_return_status OUT NOCOPY varchar2,
                                 P_attribute11 IN  varchar2)
 Is
 l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
 Begin
      x_return_status := OKC_API.G_RET_STS_SUCCESS;
     -- call column length utility
     OKC_UTIL.CHECK_LENGTH
     (
       p_view_name     => 'OKS_SERV_AVAIL_EXCEPTS_V'
      ,p_col_name      => 'attribute11'
      ,p_col_value     => p_attribute11
      ,x_return_status => l_return_status
      );
  -- verify that length is within allowed limits
  If (l_return_status <> OKC_API.G_RET_STS_SUCCESS) then
     OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                         p_msg_name     => g_unexpected_error,
                         p_token1       => g_sqlcode_token,
                         p_token1_value => sqlcode,
                         p_token2       => g_sqlerrm_token,
                         p_token2_value => 'attribute 11 Length');
  -- notify caller of an error
     x_return_status := OKC_API.G_RET_STS_ERROR;
    -- halt further validation of this column
     RAISE G_EXCEPTION_HALT_VALIDATION;
  End If;

  Exception
  When  G_EXCEPTION_HALT_VALIDATION Then
       NULL;
  When OTHERS Then
 -- store SQL error message on message stack for caller
      OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => sqlcode,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => sqlerrm);

  -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
 END validate_attribute11;

PROCEDURE validate_attribute12(x_return_status OUT NOCOPY varchar2,
                              P_attribute12 IN  varchar2)
Is
l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
Begin
  x_return_status := OKC_API.G_RET_STS_SUCCESS;
  -- call column length utility
  OKC_UTIL.CHECK_LENGTH
  (
    p_view_name     => 'OKS_SERV_AVAIL_EXCEPTS_V'
   ,p_col_name      => 'attribute12'
   ,p_col_value     => p_attribute12
   ,x_return_status => l_return_status
  );

  -- verify that length is within allowed limits
 If (l_return_status <> OKC_API.G_RET_STS_SUCCESS) then
    OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                        p_msg_name     => g_unexpected_error,
                        p_token1       => g_sqlcode_token,
                        p_token1_value => sqlcode,
                        p_token2       => g_sqlerrm_token,
                        p_token2_value => 'attribute 12 Length');
  -- notify caller of an error
    x_return_status := OKC_API.G_RET_STS_ERROR;
  -- halt further validation of this column
    RAISE G_EXCEPTION_HALT_VALIDATION;
 End If;

 Exception
 When  G_EXCEPTION_HALT_VALIDATION Then
      NULL;
 When OTHERS Then
   -- store SQL error message on message stack for caller
      OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => sqlcode,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => sqlerrm);
   -- notify caller of an UNEXPECTED error
     x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
 END validate_attribute12;



PROCEDURE validate_attribute13(x_return_status OUT NOCOPY varchar2,
                              P_attribute13 IN  varchar2)
Is
l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
Begin
  x_return_status := OKC_API.G_RET_STS_SUCCESS;
  -- call column length utility
  OKC_UTIL.CHECK_LENGTH
  (
    p_view_name     => 'OKS_SERV_AVAIL_EXCEPTS_V'
   ,p_col_name      => 'attribute13'
   ,p_col_value     => p_attribute13
   ,x_return_status => l_return_status
  );

  -- verify that length is within allowed limits
 If (l_return_status <> OKC_API.G_RET_STS_SUCCESS) then
    OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                        p_msg_name     => g_unexpected_error,
                        p_token1       => g_sqlcode_token,
                        p_token1_value => sqlcode,
                        p_token2       => g_sqlerrm_token,
                        p_token2_value => 'attribute 3 Length');
  -- notify caller of an error
    x_return_status := OKC_API.G_RET_STS_ERROR;
  -- halt further validation of this column
    RAISE G_EXCEPTION_HALT_VALIDATION;
 End If;

 Exception
 When  G_EXCEPTION_HALT_VALIDATION Then
      NULL;
 When OTHERS Then
   -- store SQL error message on message stack for caller
      OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => sqlcode,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => sqlerrm);
   -- notify caller of an UNEXPECTED error
     x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
 END validate_attribute13;

PROCEDURE validate_attribute14 (x_return_status OUT NOCOPY varchar2,
                               P_attribute14 IN  varchar2)
  Is
  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
  Begin

  x_return_status := OKC_API.G_RET_STS_SUCCESS;

 -- call column length utility
OKC_UTIL.CHECK_LENGTH
(
 p_view_name     => 'OKS_SERV_AVAIL_EXCEPTS_V'
 ,p_col_name      => 'attribute14'
 ,p_col_value     => p_attribute14
 ,x_return_status => l_return_status
);

-- verify that length is within allowed limits
If (l_return_status <> OKC_API.G_RET_STS_SUCCESS) then
    OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                        p_msg_name     => g_unexpected_error,
                        p_token1       => g_sqlcode_token,
                        p_token1_value => sqlcode,
                        p_token2       => g_sqlerrm_token,
                        p_token2_value => 'attribute 14 Length');
-- notify caller of an error
    x_return_status := OKC_API.G_RET_STS_ERROR;
 -- halt further validation of this column
    RAISE G_EXCEPTION_HALT_VALIDATION;
 End If;

Exception
When  G_EXCEPTION_HALT_VALIDATION Then
      NULL;
When OTHERS Then
-- store SQL error message on message stack for caller
    OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                        p_msg_name     => g_unexpected_error,
                        p_token1       => g_sqlcode_token,
                        p_token1_value => sqlcode,
                        p_token2       => g_sqlerrm_token,
                        p_token2_value => sqlerrm);

-- notify caller of an UNEXPECTED error
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
END validate_attribute14;


PROCEDURE validate_attribute15(x_return_status OUT NOCOPY varchar2,
                              P_attribute15 IN  varchar2)
  Is
  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
  Begin

 x_return_status := OKC_API.G_RET_STS_SUCCESS;
 -- call column length utility
 OKC_UTIL.CHECK_LENGTH
  (
   p_view_name     => 'OKS_SERV_AVAIL_EXCEPTS_V'
  ,p_col_name      => 'attribute15'
  ,p_col_value     => p_attribute15
  ,x_return_status => l_return_status
  );

  -- verify that length is within allowed limits
  If (l_return_status <> OKC_API.G_RET_STS_SUCCESS) then
      OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => sqlcode,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => 'attribute 15 Length');

 -- notify caller of an error
    x_return_status := OKC_API.G_RET_STS_ERROR;
-- halt further validation of this column
    RAISE G_EXCEPTION_HALT_VALIDATION;
End If;

Exception
When  G_EXCEPTION_HALT_VALIDATION Then
      NULL;
When OTHERS Then
-- store SQL error message on message stack for caller
   OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                       p_msg_name     => g_unexpected_error,
                       p_token1       => g_sqlcode_token,
                       p_token1_value => sqlcode,
                       p_token2       => g_sqlerrm_token,
                       p_token2_value => sqlerrm);

 -- notify caller of an UNEXPECTED error
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
END validate_attribute15;
  -------------------------------------------------------
  -- Validate_Attributes for:OKS_SERV_AVAIL_EXCEPTS_V --
  -------------------------------------------------------


FUNCTION Validate_Attributes (
    p_saxv_rec IN  saxv_rec_type
  )
  Return VARCHAR2 Is
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    x_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

  Begin

  -- call OKC_UTIL.ADD_VIEW to prepare the PL/SQL table to hold columns of view
    OKC_UTIL.ADD_VIEW('OKS_SERV_AVAIL_EXCEPTS_V',x_return_status);

    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          -- need to leave
          l_return_status := x_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
       ELSE
          -- record that there is a error
          l_return_status := x_return_status;
       END IF;
    END IF;
    --Column Level Validation

    --ID
    validate_id(x_return_status, p_saxv_rec.id);


    -- store the highest degree of error
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
        IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
        ELSE
        -- record that there was an error
        l_return_status := x_return_status;
        END IF;
    END IF;
-- JTOT_OBJECT1_CODE
      validate_JTOT_OBJECT1_CODE(x_return_status, p_saxv_rec.JTOT_OBJECT1_CODE);


    -- store the highest degree of error
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
        IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
        ELSE
        -- record that there was an error
        l_return_status := x_return_status;
        END IF;
    END IF;

    --OBJECT_VERSION_NUMBER
    validate_objvernum(x_return_status, p_saxv_rec.object_version_number);

    -- store the highest degree of error
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
        IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
        ELSE
        -- record that there was an error
        l_return_status := x_return_status;
        END IF;
    END IF;

    --SAV_ID
	 validate_sav_id(x_return_status, p_saxv_rec.sav_id);

    -- store the highest degree of error
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
        IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
        ELSE
        -- record that there was an error
        l_return_status := x_return_status;
        END IF;
    END IF;


	--REVISION_HIGH
	 validate_revision_high(x_return_status, p_saxv_rec.revision_high);

    -- store the highest degree of error
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
        IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
        ELSE
        -- record that there was an error
        l_return_status := x_return_status;
        END IF;
    END IF;

	--REVISION_LOW
	 validate_revision_low(x_return_status, p_saxv_rec.revision_low);

    -- store the highest degree of error
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
        IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
        ELSE
        -- record that there was an error
        l_return_status := x_return_status;
        END IF;
    END IF;



	--MANUFACTURING_ORG_ID

 	validate_manufacturing_org_id(x_return_status, p_saxv_rec.manufacturing_org_id);

    -- store the highest degree of error
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
        IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
        ELSE
        -- record that there was an error
        l_return_status := x_return_status;
        END IF;
    END IF;


	--OBJECT1_ID1
		validate_object1_id1(x_return_status, p_saxv_rec.object1_id1);

    -- store the highest degree of error
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
        IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
        ELSE
        -- record that there was an error
        l_return_status := x_return_status;
        END IF;
    END IF;

	--OBJECT1_ID2
		validate_object1_id2(x_return_status, p_saxv_rec.object1_id2);

    -- store the highest degree of error
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
        IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
        ELSE
        -- record that there was an error
        l_return_status := x_return_status;
        END IF;
    END IF;



	--ATTRIBUTE_CATEGORY

		validate_attribute_category(x_return_status, p_saxv_rec.attribute_category);

    -- store the highest degree of error
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
        IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
        ELSE
        -- record that there was an error
        l_return_status := x_return_status;
        END IF;
    END IF;



	--ATTRIBUTE1

		validate_attribute1(x_return_status, p_saxv_rec.attribute1);

    -- store the highest degree of error
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
        IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
        ELSE
        -- record that there was an error
        l_return_status := x_return_status;
        END IF;
    END IF;

	--ATTRIBUTE2

		validate_attribute2(x_return_status, p_saxv_rec.attribute2);

    -- store the highest degree of error
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
        IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
        ELSE
        -- record that there was an error
        l_return_status := x_return_status;
        END IF;
    END IF;



--ATTRIBUTE3

		validate_attribute3(x_return_status, p_saxv_rec.attribute3);

    -- store the highest degree of error
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
        IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
        ELSE
        -- record that there was an error
        l_return_status := x_return_status;
        END IF;
    END IF;


--ATTRIBUTE4
		validate_attribute4(x_return_status, p_saxv_rec.attribute4);

    -- store the highest degree of error
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
        IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
        ELSE
        -- record that there was an error
        l_return_status := x_return_status;
        END IF;
    END IF;


	--ATTRIBUTE5
		validate_attribute5(x_return_status, p_saxv_rec.attribute5);

    -- store the highest degree of error
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
        IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
        ELSE
        -- record that there was an error
        l_return_status := x_return_status;
        END IF;
    END IF;


	--ATTRIBUTE6

		validate_attribute6(x_return_status, p_saxv_rec.attribute6);

    -- store the highest degree of error
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
        IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
        ELSE
        -- record that there was an error
        l_return_status := x_return_status;
        END IF;
    END IF;



	--ATTRIBUTE7

		validate_attribute7(x_return_status, p_saxv_rec.attribute7);

    -- store the highest degree of error
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
        IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
        ELSE
        -- record that there was an error
        l_return_status := x_return_status;
        END IF;
    END IF;


	--ATTRIBUTE8
		validate_attribute8(x_return_status, p_saxv_rec.attribute8);

    -- store the highest degree of error
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
        IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
        ELSE
        -- record that there was an error
        l_return_status := x_return_status;
        END IF;
    END IF;


	--ATTRIBUTE9
		validate_attribute9(x_return_status, p_saxv_rec.attribute9);

    -- store the highest degree of error
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
        IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
        ELSE
        -- record that there was an error
        l_return_status := x_return_status;
        END IF;
    END IF;



	--ATTRIBUTE10

		validate_attribute10(x_return_status, p_saxv_rec.attribute10);

    -- store the highest degree of error
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
        IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
        ELSE
        -- record that there was an error
        l_return_status := x_return_status;
        END IF;
    END IF;


	--ATTRIBUTE11

		validate_attribute11(x_return_status, p_saxv_rec.attribute11);

    -- store the highest degree of error
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
        IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
        ELSE
        -- record that there was an error
        l_return_status := x_return_status;
        END IF;
    END IF;



	--ATTRIBUTE12

		validate_attribute12(x_return_status, p_saxv_rec.attribute12);

    -- store the highest degree of error
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
        IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
        ELSE
        -- record that there was an error
        l_return_status := x_return_status;
        END IF;
    END IF;


	--ATTRIBUTE13
		validate_attribute13(x_return_status, p_saxv_rec.attribute13);

    -- store the highest degree of error
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
        IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
        ELSE
        -- record that there was an error
        l_return_status := x_return_status;
        END IF;
    END IF;


	--ATTRIBUTE14

		validate_attribute14(x_return_status, p_saxv_rec.attribute14);

    -- store the highest degree of error
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
        IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
        ELSE
        -- record that there was an error
        l_return_status := x_return_status;
        END IF;
    END IF;


	--ATTRIBUTE15

		validate_attribute15(x_return_status, p_saxv_rec.attribute15);

    -- store the highest degree of error
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN

        IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
        ELSE
        -- record that there was an error
        l_return_status := x_return_status;
        END IF;
    END IF;
 Raise G_EXCEPTION_HALT_VALIDATION;



  Exception

  When G_EXCEPTION_HALT_VALIDATION Then


       Return (l_return_status);

  When OTHERS Then
       -- store SQL error message on message stack for caller
       OKC_API.SET_MESSAGE(p_app_name         => g_app_name,
                           p_msg_name         => g_unexpected_error,
                           p_token1           => g_sqlcode_token,
                           p_token1_value     => sqlcode,
                           p_token2           => g_sqlerrm_token,
                           p_token2_value     => sqlerrm);

       -- notify caller of an UNEXPECTED error
       l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
       Return(l_return_status);

  END validate_attributes;

/*  ------------------------------------------------------
  -- Validate_Attributes for:OKS_SERV_AVAIL_EXCEPTS_V --
  ------------------------------------------------------
  FUNCTION Validate_Attributes (
    p_saxv_rec IN  saxv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    IF p_saxv_rec.id = OKC_API.G_MISS_NUM OR
       p_saxv_rec.id IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'id');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_saxv_rec.sav_id = OKC_API.G_MISS_NUM OR
          p_saxv_rec.sav_id IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'sav_id');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_saxv_rec.object_version_number = OKC_API.G_MISS_NUM OR
          p_saxv_rec.object_version_number IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'object_version_number');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_return_status);
  END Validate_Attributes;
  */

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Record
  ---------------------------------------------------------------------------
  --------------------------------------------------
  -- Validate_Record for:OKS_SERV_AVAIL_EXCEPTS_V --
  --------------------------------------------------
  FUNCTION Validate_Record (
    p_saxv_rec IN saxv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    ------------------------------------
    -- FUNCTION validate_foreign_keys --
    ------------------------------------
    FUNCTION validate_foreign_keys (
      p_saxv_rec IN saxv_rec_type
    ) RETURN VARCHAR2 IS
      item_not_found_error          EXCEPTION;
      CURSOR oks_savv_pk_csr (p_id                 IN NUMBER) IS
      SELECT
              ID,
              OBJECT1_ID1,
              OBJECT1_ID2,
              JTOT_OBJECT1_CODE,
              OBJECT_VERSION_NUMBER,
              CREATED_BY,
              CREATION_DATE,
              LAST_UPDATED_BY,
              LAST_UPDATE_DATE,
              GENERAL_YN,
              EXCEPT_OBJECT_TYPE,
              START_DATE_ACTIVE,
              END_DATE_ACTIVE,
              LAST_UPDATE_LOGIN,
              ATTRIBUTE_CATEGORY,
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
              ATTRIBUTE15
        FROM Oks_Serv_Avails_V
       WHERE oks_serv_avails_v.id = p_id;
      l_oks_savv_pk                  oks_savv_pk_csr%ROWTYPE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
      l_row_notfound                 BOOLEAN := TRUE;
    BEGIN
      IF (p_saxv_rec.SAV_ID IS NOT NULL)
      THEN
        OPEN oks_savv_pk_csr(p_saxv_rec.SAV_ID);
        FETCH oks_savv_pk_csr INTO l_oks_savv_pk;
        l_row_notfound := oks_savv_pk_csr%NOTFOUND;
        CLOSE oks_savv_pk_csr;
        IF (l_row_notfound) THEN
          OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'SAV_ID');
          RAISE item_not_found_error;
        END IF;
      END IF;
      RETURN (l_return_status);
    EXCEPTION
      WHEN item_not_found_error THEN
        l_return_status := OKC_API.G_RET_STS_ERROR;
        RETURN (l_return_status);
    END validate_foreign_keys;
  BEGIN
    l_return_status := validate_foreign_keys (p_saxv_rec);
    RETURN (l_return_status);
  END Validate_Record;

  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from	IN saxv_rec_type,
    p_to	OUT NOCOPY sax_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.sav_id := p_from.sav_id;
    p_to.object1_id1 := p_from.object1_id1;
    p_to.object1_id2 := p_from.object1_id2;
    p_to.JTOT_OBJECT1_CODE := p_from.JTOT_OBJECT1_CODE;
    p_to.object_version_number := p_from.object_version_number;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.manufacturing_org_id := p_from.manufacturing_org_id;
    p_to.revision_low := p_from.revision_low;
    p_to.revision_high := p_from.revision_high;
    p_to.start_date_active := p_from.start_date_active;
    p_to.end_date_active := p_from.end_date_active;
    p_to.last_update_login := p_from.last_update_login;
    p_to.attribute_category := p_from.attribute_category;
    p_to.attribute1 := p_from.attribute1;
    p_to.attribute2 := p_from.attribute2;
    p_to.attribute3 := p_from.attribute3;
    p_to.attribute4 := p_from.attribute4;
    p_to.attribute5 := p_from.attribute5;
    p_to.attribute6 := p_from.attribute6;
    p_to.attribute7 := p_from.attribute7;
    p_to.attribute8 := p_from.attribute8;
    p_to.attribute9 := p_from.attribute9;
    p_to.attribute10 := p_from.attribute10;
    p_to.attribute11 := p_from.attribute11;
    p_to.attribute12 := p_from.attribute12;
    p_to.attribute13 := p_from.attribute13;
    p_to.attribute14 := p_from.attribute14;
    p_to.attribute15 := p_from.attribute15;
  END migrate;
  PROCEDURE migrate (
    p_from	IN sax_rec_type,
    p_to	OUT NOCOPY saxv_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.sav_id := p_from.sav_id;
    p_to.object1_id1 := p_from.object1_id1;
    p_to.object1_id2 := p_from.object1_id2;
    p_to.JTOT_OBJECT1_CODE := p_from.JTOT_OBJECT1_CODE;
    p_to.object_version_number := p_from.object_version_number;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.manufacturing_org_id := p_from.manufacturing_org_id;
    p_to.revision_low := p_from.revision_low;
    p_to.revision_high := p_from.revision_high;
    p_to.start_date_active := p_from.start_date_active;
    p_to.end_date_active := p_from.end_date_active;
    p_to.last_update_login := p_from.last_update_login;
    p_to.attribute_category := p_from.attribute_category;
    p_to.attribute1 := p_from.attribute1;
    p_to.attribute2 := p_from.attribute2;
    p_to.attribute3 := p_from.attribute3;
    p_to.attribute4 := p_from.attribute4;
    p_to.attribute5 := p_from.attribute5;
    p_to.attribute6 := p_from.attribute6;
    p_to.attribute7 := p_from.attribute7;
    p_to.attribute8 := p_from.attribute8;
    p_to.attribute9 := p_from.attribute9;
    p_to.attribute10 := p_from.attribute10;
    p_to.attribute11 := p_from.attribute11;
    p_to.attribute12 := p_from.attribute12;
    p_to.attribute13 := p_from.attribute13;
    p_to.attribute14 := p_from.attribute14;
    p_to.attribute15 := p_from.attribute15;
  END migrate;

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_row
  ---------------------------------------------------------------------------
  -----------------------------------------------
  -- validate_row for:OKS_SERV_AVAIL_EXCEPTS_V --
  -----------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_saxv_rec                     IN saxv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_saxv_rec                     saxv_rec_type := p_saxv_rec;
    l_sax_rec                      sax_rec_type;
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
    l_return_status := Validate_Attributes(l_saxv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_saxv_rec);
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
  -- PL/SQL TBL validate_row for:SAXV_TBL --
  ------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_saxv_tbl                     IN saxv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_saxv_tbl.COUNT > 0) THEN
      i := p_saxv_tbl.FIRST;
      LOOP
        validate_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_saxv_rec                     => p_saxv_tbl(i));
        EXIT WHEN (i = p_saxv_tbl.LAST);
        i := p_saxv_tbl.NEXT(i);
      END LOOP;
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
  -------------------------------------------
  -- insert_row for:OKS_SERV_AVAIL_EXCEPTS --
  -------------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sax_rec                      IN sax_rec_type,
    x_sax_rec                      OUT NOCOPY sax_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'EXCEPTS_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_sax_rec                      sax_rec_type := p_sax_rec;
    l_def_sax_rec                  sax_rec_type;
    -----------------------------------------------
    -- Set_Attributes for:OKS_SERV_AVAIL_EXCEPTS --
    -----------------------------------------------
    FUNCTION Set_Attributes (
      p_sax_rec IN  sax_rec_type,
      x_sax_rec OUT NOCOPY sax_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_sax_rec := p_sax_rec;
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
      p_sax_rec,                         -- IN
      l_sax_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKS_SERV_AVAIL_EXCEPTS(
        id,
        sav_id,
        object1_id1,
        object1_id2,
        JTOT_OBJECT1_CODE,
        object_version_number,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        manufacturing_org_id,
        revision_low,
        revision_high,
        start_date_active,
        end_date_active,
        last_update_login,
        attribute_category,
        attribute1,
        attribute2,
        attribute3,
        attribute4,
        attribute5,
        attribute6,
        attribute7,
        attribute8,
        attribute9,
        attribute10,
        attribute11,
        attribute12,
        attribute13,
        attribute14,
        attribute15)
      VALUES (
        l_sax_rec.id,
        l_sax_rec.sav_id,
        l_sax_rec.object1_id1,
        l_sax_rec.object1_id2,
        l_sax_rec.JTOT_OBJECT1_CODE,
        l_sax_rec.object_version_number,
        l_sax_rec.created_by,
        l_sax_rec.creation_date,
        l_sax_rec.last_updated_by,
        l_sax_rec.last_update_date,
        l_sax_rec.manufacturing_org_id,
        l_sax_rec.revision_low,
        l_sax_rec.revision_high,
        l_sax_rec.start_date_active,
        l_sax_rec.end_date_active,
        l_sax_rec.last_update_login,
        l_sax_rec.attribute_category,
        l_sax_rec.attribute1,
        l_sax_rec.attribute2,
        l_sax_rec.attribute3,
        l_sax_rec.attribute4,
        l_sax_rec.attribute5,
        l_sax_rec.attribute6,
        l_sax_rec.attribute7,
        l_sax_rec.attribute8,
        l_sax_rec.attribute9,
        l_sax_rec.attribute10,
        l_sax_rec.attribute11,
        l_sax_rec.attribute12,
        l_sax_rec.attribute13,
        l_sax_rec.attribute14,
        l_sax_rec.attribute15);
    -- Set OUT values
    x_sax_rec := l_sax_rec;
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
  ---------------------------------------------
  -- insert_row for:OKS_SERV_AVAIL_EXCEPTS_V --
  ---------------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_saxv_rec                     IN saxv_rec_type,
    x_saxv_rec                     OUT NOCOPY saxv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_saxv_rec                     saxv_rec_type;
    l_def_saxv_rec                 saxv_rec_type;
    l_sax_rec                      sax_rec_type;
    lx_sax_rec                     sax_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_saxv_rec	IN saxv_rec_type
    ) RETURN saxv_rec_type IS
      l_saxv_rec	saxv_rec_type := p_saxv_rec;
    BEGIN
      l_saxv_rec.CREATION_DATE := SYSDATE;
      l_saxv_rec.CREATED_BY := FND_GLOBAL.USER_ID;
      l_saxv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_saxv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_saxv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_saxv_rec);
    END fill_who_columns;
    -------------------------------------------------
    -- Set_Attributes for:OKS_SERV_AVAIL_EXCEPTS_V --
    -------------------------------------------------
    FUNCTION Set_Attributes (
      p_saxv_rec IN  saxv_rec_type,
      x_saxv_rec OUT NOCOPY saxv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_saxv_rec := p_saxv_rec;
      x_saxv_rec.OBJECT_VERSION_NUMBER := 1;
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
    l_saxv_rec := null_out_defaults(p_saxv_rec);
    -- Set primary key value
    l_saxv_rec.ID := get_seq_id;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      l_saxv_rec,                        -- IN
      l_def_saxv_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_saxv_rec := fill_who_columns(l_def_saxv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_saxv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_saxv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_saxv_rec, l_sax_rec);
    --------------------------------------------
    -- Call the INSERT_ROW for each child record
    --------------------------------------------
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_sax_rec,
      lx_sax_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_sax_rec, l_def_saxv_rec);
    -- Set OUT values
    x_saxv_rec := l_def_saxv_rec;
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
  -- PL/SQL TBL insert_row for:SAXV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_saxv_tbl                     IN saxv_tbl_type,
    x_saxv_tbl                     OUT NOCOPY saxv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_saxv_tbl.COUNT > 0) THEN
      i := p_saxv_tbl.FIRST;
      LOOP
        insert_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_saxv_rec                     => p_saxv_tbl(i),
          x_saxv_rec                     => x_saxv_tbl(i));
        EXIT WHEN (i = p_saxv_tbl.LAST);
        i := p_saxv_tbl.NEXT(i);
      END LOOP;
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
  -----------------------------------------
  -- lock_row for:OKS_SERV_AVAIL_EXCEPTS --
  -----------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sax_rec                      IN sax_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_sax_rec IN sax_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKS_SERV_AVAIL_EXCEPTS
     WHERE ID = p_sax_rec.id
       AND OBJECT_VERSION_NUMBER = p_sax_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR  lchk_csr (p_sax_rec IN sax_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKS_SERV_AVAIL_EXCEPTS
    WHERE ID = p_sax_rec.id;
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'EXCEPTS_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_object_version_number       OKS_SERV_AVAIL_EXCEPTS.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number      OKS_SERV_AVAIL_EXCEPTS.OBJECT_VERSION_NUMBER%TYPE;
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
      OPEN lock_csr(p_sax_rec);
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
      OPEN lchk_csr(p_sax_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_sax_rec.object_version_number THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_sax_rec.object_version_number THEN
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
  -------------------------------------------
  -- lock_row for:OKS_SERV_AVAIL_EXCEPTS_V --
  -------------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_saxv_rec                     IN saxv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_sax_rec                      sax_rec_type;
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
    migrate(p_saxv_rec, l_sax_rec);
    --------------------------------------------
    -- Call the LOCK_ROW for each child record
    --------------------------------------------
    lock_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_sax_rec
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
  -- PL/SQL TBL lock_row for:SAXV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_saxv_tbl                     IN saxv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_saxv_tbl.COUNT > 0) THEN
      i := p_saxv_tbl.FIRST;
      LOOP
        lock_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_saxv_rec                     => p_saxv_tbl(i));
        EXIT WHEN (i = p_saxv_tbl.LAST);
        i := p_saxv_tbl.NEXT(i);
      END LOOP;
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
  -------------------------------------------
  -- update_row for:OKS_SERV_AVAIL_EXCEPTS --
  -------------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sax_rec                      IN sax_rec_type,
    x_sax_rec                      OUT NOCOPY sax_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'EXCEPTS_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_sax_rec                      sax_rec_type := p_sax_rec;
    l_def_sax_rec                  sax_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_sax_rec	IN sax_rec_type,
      x_sax_rec	OUT NOCOPY sax_rec_type
    ) RETURN VARCHAR2 IS
      l_sax_rec                      sax_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_sax_rec := p_sax_rec;
      -- Get current database values
      l_sax_rec := get_rec(p_sax_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_sax_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_sax_rec.id := l_sax_rec.id;
      END IF;
      IF (x_sax_rec.sav_id = OKC_API.G_MISS_NUM)
      THEN
        x_sax_rec.sav_id := l_sax_rec.sav_id;
      END IF;
      IF (x_sax_rec.object1_id1 = OKC_API.G_MISS_CHAR)
      THEN
        x_sax_rec.object1_id1 := l_sax_rec.object1_id1;
      END IF;
      IF (x_sax_rec.object1_id2 = OKC_API.G_MISS_CHAR)
      THEN
        x_sax_rec.object1_id2 := l_sax_rec.object1_id2;
      END IF;
      IF (x_sax_rec.JTOT_OBJECT1_CODE = OKC_API.G_MISS_CHAR)
      THEN
        x_sax_rec.JTOT_OBJECT1_CODE := l_sax_rec.JTOT_OBJECT1_CODE;
      END IF;
      IF (x_sax_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_sax_rec.object_version_number := l_sax_rec.object_version_number;
      END IF;
      IF (x_sax_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_sax_rec.created_by := l_sax_rec.created_by;
      END IF;
      IF (x_sax_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_sax_rec.creation_date := l_sax_rec.creation_date;
      END IF;
      IF (x_sax_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_sax_rec.last_updated_by := l_sax_rec.last_updated_by;
      END IF;
      IF (x_sax_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_sax_rec.last_update_date := l_sax_rec.last_update_date;
      END IF;
      IF (x_sax_rec.manufacturing_org_id = OKC_API.G_MISS_NUM)
      THEN
        x_sax_rec.manufacturing_org_id := l_sax_rec.manufacturing_org_id;
      END IF;
      IF (x_sax_rec.revision_low = OKC_API.G_MISS_CHAR)
      THEN
        x_sax_rec.revision_low := l_sax_rec.revision_low;
      END IF;
      IF (x_sax_rec.revision_high = OKC_API.G_MISS_CHAR)
      THEN
        x_sax_rec.revision_high := l_sax_rec.revision_high;
      END IF;
      IF (x_sax_rec.start_date_active = OKC_API.G_MISS_DATE)
      THEN
        x_sax_rec.start_date_active := l_sax_rec.start_date_active;
      END IF;
      IF (x_sax_rec.end_date_active = OKC_API.G_MISS_DATE)
      THEN
        x_sax_rec.end_date_active := l_sax_rec.end_date_active;
      END IF;
      IF (x_sax_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_sax_rec.last_update_login := l_sax_rec.last_update_login;
      END IF;
      IF (x_sax_rec.attribute_category = OKC_API.G_MISS_CHAR)
      THEN
        x_sax_rec.attribute_category := l_sax_rec.attribute_category;
      END IF;
      IF (x_sax_rec.attribute1 = OKC_API.G_MISS_CHAR)
      THEN
        x_sax_rec.attribute1 := l_sax_rec.attribute1;
      END IF;
      IF (x_sax_rec.attribute2 = OKC_API.G_MISS_CHAR)
      THEN
        x_sax_rec.attribute2 := l_sax_rec.attribute2;
      END IF;
      IF (x_sax_rec.attribute3 = OKC_API.G_MISS_CHAR)
      THEN
        x_sax_rec.attribute3 := l_sax_rec.attribute3;
      END IF;
      IF (x_sax_rec.attribute4 = OKC_API.G_MISS_CHAR)
      THEN
        x_sax_rec.attribute4 := l_sax_rec.attribute4;
      END IF;
      IF (x_sax_rec.attribute5 = OKC_API.G_MISS_CHAR)
      THEN
        x_sax_rec.attribute5 := l_sax_rec.attribute5;
      END IF;
      IF (x_sax_rec.attribute6 = OKC_API.G_MISS_CHAR)
      THEN
        x_sax_rec.attribute6 := l_sax_rec.attribute6;
      END IF;
      IF (x_sax_rec.attribute7 = OKC_API.G_MISS_CHAR)
      THEN
        x_sax_rec.attribute7 := l_sax_rec.attribute7;
      END IF;
      IF (x_sax_rec.attribute8 = OKC_API.G_MISS_CHAR)
      THEN
        x_sax_rec.attribute8 := l_sax_rec.attribute8;
      END IF;
      IF (x_sax_rec.attribute9 = OKC_API.G_MISS_CHAR)
      THEN
        x_sax_rec.attribute9 := l_sax_rec.attribute9;
      END IF;
      IF (x_sax_rec.attribute10 = OKC_API.G_MISS_CHAR)
      THEN
        x_sax_rec.attribute10 := l_sax_rec.attribute10;
      END IF;
      IF (x_sax_rec.attribute11 = OKC_API.G_MISS_CHAR)
      THEN
        x_sax_rec.attribute11 := l_sax_rec.attribute11;
      END IF;
      IF (x_sax_rec.attribute12 = OKC_API.G_MISS_CHAR)
      THEN
        x_sax_rec.attribute12 := l_sax_rec.attribute12;
      END IF;
      IF (x_sax_rec.attribute13 = OKC_API.G_MISS_CHAR)
      THEN
        x_sax_rec.attribute13 := l_sax_rec.attribute13;
      END IF;
      IF (x_sax_rec.attribute14 = OKC_API.G_MISS_CHAR)
      THEN
        x_sax_rec.attribute14 := l_sax_rec.attribute14;
      END IF;
      IF (x_sax_rec.attribute15 = OKC_API.G_MISS_CHAR)
      THEN
        x_sax_rec.attribute15 := l_sax_rec.attribute15;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    -----------------------------------------------
    -- Set_Attributes for:OKS_SERV_AVAIL_EXCEPTS --
    -----------------------------------------------
    FUNCTION Set_Attributes (
      p_sax_rec IN  sax_rec_type,
      x_sax_rec OUT NOCOPY sax_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_sax_rec := p_sax_rec;
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
      p_sax_rec,                         -- IN
      l_sax_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_sax_rec, l_def_sax_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKS_SERV_AVAIL_EXCEPTS
    SET SAV_ID = l_def_sax_rec.sav_id,
        OBJECT1_ID1 = l_def_sax_rec.object1_id1,
        OBJECT1_ID2 = l_def_sax_rec.object1_id2,
        JTOT_OBJECT1_CODE = l_def_sax_rec.JTOT_OBJECT1_CODE,
        OBJECT_VERSION_NUMBER = l_def_sax_rec.object_version_number,
        CREATED_BY = l_def_sax_rec.created_by,
        CREATION_DATE = l_def_sax_rec.creation_date,
        LAST_UPDATED_BY = l_def_sax_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_sax_rec.last_update_date,
        MANUFACTURING_ORG_ID = l_def_sax_rec.manufacturing_org_id,
        REVISION_LOW = l_def_sax_rec.revision_low,
        REVISION_HIGH = l_def_sax_rec.revision_high,
        START_DATE_ACTIVE = l_def_sax_rec.start_date_active,
        END_DATE_ACTIVE = l_def_sax_rec.end_date_active,
        LAST_UPDATE_LOGIN = l_def_sax_rec.last_update_login,
        ATTRIBUTE_CATEGORY = l_def_sax_rec.attribute_category,
        ATTRIBUTE1 = l_def_sax_rec.attribute1,
        ATTRIBUTE2 = l_def_sax_rec.attribute2,
        ATTRIBUTE3 = l_def_sax_rec.attribute3,
        ATTRIBUTE4 = l_def_sax_rec.attribute4,
        ATTRIBUTE5 = l_def_sax_rec.attribute5,
        ATTRIBUTE6 = l_def_sax_rec.attribute6,
        ATTRIBUTE7 = l_def_sax_rec.attribute7,
        ATTRIBUTE8 = l_def_sax_rec.attribute8,
        ATTRIBUTE9 = l_def_sax_rec.attribute9,
        ATTRIBUTE10 = l_def_sax_rec.attribute10,
        ATTRIBUTE11 = l_def_sax_rec.attribute11,
        ATTRIBUTE12 = l_def_sax_rec.attribute12,
        ATTRIBUTE13 = l_def_sax_rec.attribute13,
        ATTRIBUTE14 = l_def_sax_rec.attribute14,
        ATTRIBUTE15 = l_def_sax_rec.attribute15
    WHERE ID = l_def_sax_rec.id;

    x_sax_rec := l_def_sax_rec;
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
  ---------------------------------------------
  -- update_row for:OKS_SERV_AVAIL_EXCEPTS_V --
  ---------------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_saxv_rec                     IN saxv_rec_type,
    x_saxv_rec                     OUT NOCOPY saxv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_saxv_rec                     saxv_rec_type := p_saxv_rec;
    l_def_saxv_rec                 saxv_rec_type;
    l_sax_rec                      sax_rec_type;
    lx_sax_rec                     sax_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_saxv_rec	IN saxv_rec_type
    ) RETURN saxv_rec_type IS
      l_saxv_rec	saxv_rec_type := p_saxv_rec;
    BEGIN
      l_saxv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_saxv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_saxv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_saxv_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_saxv_rec	IN saxv_rec_type,
      x_saxv_rec	OUT NOCOPY saxv_rec_type
    ) RETURN VARCHAR2 IS
      l_saxv_rec                     saxv_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_saxv_rec := p_saxv_rec;
      -- Get current database values
      l_saxv_rec := get_rec(p_saxv_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_saxv_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_saxv_rec.id := l_saxv_rec.id;
      END IF;
      IF (x_saxv_rec.sav_id = OKC_API.G_MISS_NUM)
      THEN
        x_saxv_rec.sav_id := l_saxv_rec.sav_id;
      END IF;
      IF (x_saxv_rec.object1_id1 = OKC_API.G_MISS_CHAR)
      THEN
        x_saxv_rec.object1_id1 := l_saxv_rec.object1_id1;
      END IF;
      IF (x_saxv_rec.object1_id2 = OKC_API.G_MISS_CHAR)
      THEN
        x_saxv_rec.object1_id2 := l_saxv_rec.object1_id2;
      END IF;
      IF (x_saxv_rec.JTOT_OBJECT1_CODE = OKC_API.G_MISS_CHAR)
      THEN
        x_saxv_rec.JTOT_OBJECT1_CODE := l_saxv_rec.JTOT_OBJECT1_CODE;
      END IF;
      IF (x_saxv_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_saxv_rec.object_version_number := l_saxv_rec.object_version_number;
      END IF;
      IF (x_saxv_rec.manufacturing_org_id = OKC_API.G_MISS_NUM)
      THEN
        x_saxv_rec.manufacturing_org_id := l_saxv_rec.manufacturing_org_id;
      END IF;
      IF (x_saxv_rec.revision_low = OKC_API.G_MISS_CHAR)
      THEN
        x_saxv_rec.revision_low := l_saxv_rec.revision_low;
      END IF;
      IF (x_saxv_rec.revision_high = OKC_API.G_MISS_CHAR)
      THEN
        x_saxv_rec.revision_high := l_saxv_rec.revision_high;
      END IF;
      IF (x_saxv_rec.start_date_active = OKC_API.G_MISS_DATE)
      THEN
        x_saxv_rec.start_date_active := l_saxv_rec.start_date_active;
      END IF;
      IF (x_saxv_rec.end_date_active = OKC_API.G_MISS_DATE)
      THEN
        x_saxv_rec.end_date_active := l_saxv_rec.end_date_active;
      END IF;
      IF (x_saxv_rec.attribute_category = OKC_API.G_MISS_CHAR)
      THEN
        x_saxv_rec.attribute_category := l_saxv_rec.attribute_category;
      END IF;
      IF (x_saxv_rec.attribute1 = OKC_API.G_MISS_CHAR)
      THEN
        x_saxv_rec.attribute1 := l_saxv_rec.attribute1;
      END IF;
      IF (x_saxv_rec.attribute2 = OKC_API.G_MISS_CHAR)
      THEN
        x_saxv_rec.attribute2 := l_saxv_rec.attribute2;
      END IF;
      IF (x_saxv_rec.attribute3 = OKC_API.G_MISS_CHAR)
      THEN
        x_saxv_rec.attribute3 := l_saxv_rec.attribute3;
      END IF;
      IF (x_saxv_rec.attribute4 = OKC_API.G_MISS_CHAR)
      THEN
        x_saxv_rec.attribute4 := l_saxv_rec.attribute4;
      END IF;
      IF (x_saxv_rec.attribute5 = OKC_API.G_MISS_CHAR)
      THEN
        x_saxv_rec.attribute5 := l_saxv_rec.attribute5;
      END IF;
      IF (x_saxv_rec.attribute6 = OKC_API.G_MISS_CHAR)
      THEN
        x_saxv_rec.attribute6 := l_saxv_rec.attribute6;
      END IF;
      IF (x_saxv_rec.attribute7 = OKC_API.G_MISS_CHAR)
      THEN
        x_saxv_rec.attribute7 := l_saxv_rec.attribute7;
      END IF;
      IF (x_saxv_rec.attribute8 = OKC_API.G_MISS_CHAR)
      THEN
        x_saxv_rec.attribute8 := l_saxv_rec.attribute8;
      END IF;
      IF (x_saxv_rec.attribute9 = OKC_API.G_MISS_CHAR)
      THEN
        x_saxv_rec.attribute9 := l_saxv_rec.attribute9;
      END IF;
      IF (x_saxv_rec.attribute10 = OKC_API.G_MISS_CHAR)
      THEN
        x_saxv_rec.attribute10 := l_saxv_rec.attribute10;
      END IF;
      IF (x_saxv_rec.attribute11 = OKC_API.G_MISS_CHAR)
      THEN
        x_saxv_rec.attribute11 := l_saxv_rec.attribute11;
      END IF;
      IF (x_saxv_rec.attribute12 = OKC_API.G_MISS_CHAR)
      THEN
        x_saxv_rec.attribute12 := l_saxv_rec.attribute12;
      END IF;
      IF (x_saxv_rec.attribute13 = OKC_API.G_MISS_CHAR)
      THEN
        x_saxv_rec.attribute13 := l_saxv_rec.attribute13;
      END IF;
      IF (x_saxv_rec.attribute14 = OKC_API.G_MISS_CHAR)
      THEN
        x_saxv_rec.attribute14 := l_saxv_rec.attribute14;
      END IF;
      IF (x_saxv_rec.attribute15 = OKC_API.G_MISS_CHAR)
      THEN
        x_saxv_rec.attribute15 := l_saxv_rec.attribute15;
      END IF;
      IF (x_saxv_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_saxv_rec.created_by := l_saxv_rec.created_by;
      END IF;
      IF (x_saxv_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_saxv_rec.creation_date := l_saxv_rec.creation_date;
      END IF;
      IF (x_saxv_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_saxv_rec.last_updated_by := l_saxv_rec.last_updated_by;
      END IF;
      IF (x_saxv_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_saxv_rec.last_update_date := l_saxv_rec.last_update_date;
      END IF;
      IF (x_saxv_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_saxv_rec.last_update_login := l_saxv_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    -------------------------------------------------
    -- Set_Attributes for:OKS_SERV_AVAIL_EXCEPTS_V --
    -------------------------------------------------
    FUNCTION Set_Attributes (
      p_saxv_rec IN  saxv_rec_type,
      x_saxv_rec OUT NOCOPY saxv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_saxv_rec := p_saxv_rec;
      x_saxv_rec.OBJECT_VERSION_NUMBER := NVL(x_saxv_rec.OBJECT_VERSION_NUMBER, 0) + 1;
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
      p_saxv_rec,                        -- IN
      l_saxv_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_saxv_rec, l_def_saxv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_saxv_rec := fill_who_columns(l_def_saxv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_saxv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_saxv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_saxv_rec, l_sax_rec);
    --------------------------------------------
    -- Call the UPDATE_ROW for each child record
    --------------------------------------------
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_sax_rec,
      lx_sax_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_sax_rec, l_def_saxv_rec);
    x_saxv_rec := l_def_saxv_rec;
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
  -- PL/SQL TBL update_row for:SAXV_TBL --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_saxv_tbl                     IN saxv_tbl_type,
    x_saxv_tbl                     OUT NOCOPY saxv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_saxv_tbl.COUNT > 0) THEN
      i := p_saxv_tbl.FIRST;
      LOOP
        update_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_saxv_rec                     => p_saxv_tbl(i),
          x_saxv_rec                     => x_saxv_tbl(i));
        EXIT WHEN (i = p_saxv_tbl.LAST);
        i := p_saxv_tbl.NEXT(i);
      END LOOP;
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
  -------------------------------------------
  -- delete_row for:OKS_SERV_AVAIL_EXCEPTS --
  -------------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sax_rec                      IN sax_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'EXCEPTS_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_sax_rec                      sax_rec_type:= p_sax_rec;
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
    DELETE FROM OKS_SERV_AVAIL_EXCEPTS
     WHERE ID = l_sax_rec.id;

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
  ---------------------------------------------
  -- delete_row for:OKS_SERV_AVAIL_EXCEPTS_V --
  ---------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_saxv_rec                     IN saxv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_saxv_rec                     saxv_rec_type := p_saxv_rec;
    l_sax_rec                      sax_rec_type;
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
    migrate(l_saxv_rec, l_sax_rec);
    --------------------------------------------
    -- Call the DELETE_ROW for each child record
    --------------------------------------------
    delete_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_sax_rec
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
  -- PL/SQL TBL delete_row for:SAXV_TBL --
  ----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_saxv_tbl                     IN saxv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_saxv_tbl.COUNT > 0) THEN
      i := p_saxv_tbl.FIRST;
      LOOP
        delete_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_saxv_rec                     => p_saxv_tbl(i));
        EXIT WHEN (i = p_saxv_tbl.LAST);
        i := p_saxv_tbl.NEXT(i);
      END LOOP;
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
PROCEDURE INSERT_ROW_UPG(p_saxv_tbl saxv_tbl_type ) IS

TYPE Var45TabTyp IS TABLE OF Varchar2(45)
     INDEX BY BINARY_INTEGER;
  l_tabsize NUMBER := p_saxv_tbl.COUNT;
  l_source_lang VARCHAR2(12) := okc_util.get_userenv_lang;
TYPE Var720TabTyp IS TABLE OF Varchar2(720)
     INDEX BY BINARY_INTEGER;

  in_id                            OKC_DATATYPES.NumberTabTyp;
  in_sav_id                        OKC_DATATYPES.NumberTabTyp;
  in_object1_id1                   OKC_DATATYPES.Var40TabTyp;
  in_object1_id2                   OKC_DATATYPES.Var200TabTyp;
  in_jtot_object1_code             OKC_DATATYPES.Var30TabTyp;
  in_manufacturing_org_id          OKC_DATATYPES.NumberTabTyp;
  in_revision_low                  Var45TabTyp;
  in_revision_high                 Var45TabTyp;
  in_start_date_active             OKC_DATATYPES.DateTabTyp;
  in_end_date_active               OKC_DATATYPES.DateTabTyp;
  in_object_version_number         OKC_DATATYPES.NumberTabTyp;
  in_attribute_category            OKC_DATATYPES.Var90TabTyp;
  in_attribute1                    OKC_DATATYPES.Var450TabTyp;
  in_attribute2                    OKC_DATATYPES.Var450TabTyp;
  in_attribute3                    OKC_DATATYPES.Var450TabTyp;
  in_attribute4                    OKC_DATATYPES.Var450TabTyp;
  in_attribute5                    OKC_DATATYPES.Var450TabTyp;
  in_attribute6                    OKC_DATATYPES.Var450TabTyp;
  in_attribute7                    OKC_DATATYPES.Var450TabTyp;
  in_attribute8                    OKC_DATATYPES.Var450TabTyp;
  in_attribute9                    OKC_DATATYPES.Var450TabTyp;
  in_attribute10                   OKC_DATATYPES.Var450TabTyp;
  in_attribute11                   OKC_DATATYPES.Var450TabTyp;
  in_attribute12                   OKC_DATATYPES.Var450TabTyp;
  in_attribute13                   OKC_DATATYPES.Var450TabTyp;
  in_attribute14                   OKC_DATATYPES.Var450TabTyp;
  in_attribute15                   OKC_DATATYPES.Var450TabTyp;
  in_created_by                    OKC_DATATYPES.NumberTabTyp;
  in_creation_date                 OKC_DATATYPES.DateTabTyp;
  in_last_updated_by               OKC_DATATYPES.NumberTabTyp;
  in_last_update_date              OKC_DATATYPES.DateTabTyp;
  in_last_update_login             OKC_DATATYPES.NumberTabTyp;


  i number;
  j number;
BEGIN
  i := p_saxv_tbl.FIRST; j:=0;
  while i is not null
  LOOP
    j:=j+1;
    in_id                            (j) := p_saxv_tbl(i).id;
    in_sav_id                        (j) := p_saxv_tbl(i).sav_id;
    in_object1_id1                   (j) := p_saxv_tbl(i).object1_id1;
    in_object1_id2                   (j) := p_saxv_tbl(i).object1_id2;
    in_jtot_object1_code              (j) := p_saxv_tbl(i).jtot_object1_code;
    in_manufacturing_org_id          (j) := p_saxv_tbl(i).manufacturing_org_id;
    in_revision_low                  (j) := p_saxv_tbl(i).revision_low ;
    in_revision_high                 (j) := p_saxv_tbl(i).revision_high ;
    in_start_date_active             (j) := p_saxv_tbl(i).start_date_active;
    in_end_date_active               (j) := p_saxv_tbl(i).end_date_active;
    in_object_version_number         (j) := p_saxv_tbl(i).object_version_number;
    in_attribute_category            (j) := p_saxv_tbl(i).attribute_category;
    in_attribute1                    (j) := p_saxv_tbl(i).attribute1;
    in_attribute2                    (j) := p_saxv_tbl(i).attribute2;
    in_attribute3                    (j) := p_saxv_tbl(i).attribute3;
    in_attribute4                    (j) := p_saxv_tbl(i).attribute4;
    in_attribute5                    (j) := p_saxv_tbl(i).attribute5;
    in_attribute6                    (j) := p_saxv_tbl(i).attribute6;
    in_attribute7                    (j) := p_saxv_tbl(i).attribute7;
    in_attribute8                    (j) := p_saxv_tbl(i).attribute8;
    in_attribute9                    (j) := p_saxv_tbl(i).attribute9;
    in_attribute10                   (j) := p_saxv_tbl(i).attribute10;
    in_attribute11                   (j) := p_saxv_tbl(i).attribute11;
    in_attribute12                   (j) := p_saxv_tbl(i).attribute12;
    in_attribute13                   (j) := p_saxv_tbl(i).attribute13;
    in_attribute14                   (j) := p_saxv_tbl(i).attribute14;
    in_attribute15                   (j) := p_saxv_tbl(i).attribute15;
    in_created_by                    (j) := p_saxv_tbl(i).created_by;
    in_creation_date                 (j) := p_saxv_tbl(i).creation_date;
    in_last_updated_by               (j) := p_saxv_tbl(i).last_updated_by;
    in_last_update_date              (j) := p_saxv_tbl(i).last_update_date;
    in_last_update_login             (j) := p_saxv_tbl(i).last_update_login;



    i:=p_saxv_tbl.next(i);
  END LOOP;
                         FORALL i in 1..l_tabsize
              Insert into
              OKS_SERV_AVAIL_EXCEPTS
              (
                id
               , sav_id
               , object1_id1
               , object1_id2
               , jtot_object1_code
               , manufacturing_org_id
               , revision_low
               , revision_high
               , start_date_active
               , end_date_active
               , object_version_number
               , attribute_category
               , attribute1
               , attribute2
               , attribute3
               , attribute4
               , attribute5
               , attribute6
               , attribute7
               , attribute8
               , attribute9
               , attribute10
               , attribute11
               , attribute12
               , attribute13
               , attribute14
               , attribute15
               , created_by
               , creation_date
               , last_updated_by
               , last_update_date
               , last_update_login
              )
              Values
              (
                 in_id(i),
                 in_sav_id(i),
                 in_object1_id1(i),
                 in_object1_id2(i),
                 in_jtot_object1_code(i),
                 in_manufacturing_org_id(i),
                 in_revision_low(i),
                 in_revision_high(i),
                 in_start_date_active(i),
                 in_end_date_active(i),
                 in_object_version_number(i),
                 in_attribute_category(i),
                 in_attribute1(i),
                 in_attribute2(i),
                 in_attribute3(i),
                 in_attribute4(i),
                 in_attribute5(i),
                 in_attribute6(i),
                 in_attribute7(i),
                 in_attribute8(i),
                 in_attribute9(i),
                 in_attribute10(i),
                 in_attribute11(i),
                 in_attribute12(i),
                 in_attribute13(i),
                 in_attribute14(i),
                 in_attribute15(i),
                 in_created_by(i),
                 in_creation_date(i),
                 in_last_updated_by(i),
                 in_last_update_date(i),
                 in_last_update_login(i)
              );
EXCEPTION
  WHEN OTHERS THEN
    RAISE;
END INSERT_ROW_UPG;
END OKS_AVLEXC_PVT;

/
