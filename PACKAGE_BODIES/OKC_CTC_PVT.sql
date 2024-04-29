--------------------------------------------------------
--  DDL for Package Body OKC_CTC_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_CTC_PVT" AS
/* $Header: OKCSCTCB.pls 120.1.12010000.6 2011/03/10 18:11:25 harchand ship $ */

	l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');
/*+++++++++++++Start of hand code +++++++++++++++++*/
G_UNEXPECTED_ERROR           CONSTANT   varchar2(200) := 'OKC_UNEXPECTED_ERROR';
G_SQLCODE_TOKEN              CONSTANT   varchar2(200) := 'ERROR_CODE';
G_SQLERRM_TOKEN              CONSTANT   varchar2(200) := 'ERROR_MESSAGE';
g_return_status                         varchar2(1)   :=  OKC_API.G_RET_STS_SUCCESS;
G_EXCEPTION_HALT_VALIDATION  exception;
/*+++++++++++++End of hand code +++++++++++++++++++*/
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

-- PROCEDURE update_contact_stecode
/*bugfix for 6882512*/
 	   PROCEDURE update_contact_stecode(
 	       p_chr_id         IN NUMBER,
 	       x_return_status      OUT NOCOPY VARCHAR2) IS

 	       CURSOR c_get_contract_status(p_chr_id IN NUMBER) IS
 	         SELECT ste_code
 	         FROM okc_k_headers_all_b,okc_statuses_b
 	         WHERE id= p_chr_id AND  okc_statuses_b.code=okc_k_headers_all_b.sts_code;

 	         l_ste_code varchar2(30);

 	   BEGIN
 	      IF (l_debug = 'Y') THEN
 	        okc_debug.Set_Indentation('OKC_CTC_PVT');
 	        okc_debug.log('100: Entered update_contact_stecode', 2);
 	      END IF;

 	      x_return_status := OKC_API.G_RET_STS_SUCCESS;

 	      OPEN c_get_contract_status(p_chr_id);
 	      FETCH c_get_contract_status INTO l_ste_code;
 	      CLOSE c_get_contract_status;

 	      IF l_ste_code is null then
 	        RAISE OKC_API.G_EXCEPTION_ERROR;
 	      END IF;

 	      UPDATE OKC_CONTACTS SET dnz_ste_code=l_ste_code WHERE DNZ_CHR_ID=p_chr_id;

 	      IF (l_debug = 'Y') THEN
 	        okc_debug.Set_Indentation('OKC_CTC_PVT');
 	        okc_debug.log('110: Exiting update_contact_stecode', 2);
 	      END IF;

 	   EXCEPTION
 	      WHEN OKC_API.G_EXCEPTION_ERROR THEN

 	      IF (l_debug = 'Y') THEN
 	          okc_debug.log('120: Exiting update_contact_stecode:OKC_API.G_EXCEPTION_ERROR Exception', 2);
 	          okc_debug.Reset_Indentation;
 	      END IF;

 	      x_return_status := 'E';

 	      WHEN OTHERS THEN

 	      IF (l_debug = 'Y') THEN
 	          okc_debug.log('130: Exiting update_contact_stecode:OTHERS Exception', 2);
 	          okc_debug.Reset_Indentation;
 	       END IF;

 	   END update_contact_stecode;
           /*bugfix for 6882512*/


  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKC_CONTACTS
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_ctc_rec                      IN ctc_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN ctc_rec_type IS
    CURSOR ctc_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            CPL_ID,
            CRO_CODE,
            DNZ_CHR_ID,
            OBJECT1_ID1,
            OBJECT1_ID2,
            JTOT_OBJECT1_CODE,
            OBJECT_VERSION_NUMBER,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            CONTACT_SEQUENCE,
            LAST_UPDATE_LOGIN,
		  PRIMARY_YN,
		  RESOURCE_CLASS,
		  SALES_GROUP_ID,
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
            START_DATE,
            END_DATE
      FROM Okc_Contacts
     WHERE okc_contacts.id      = p_id;
    l_ctc_pk                       ctc_pk_csr%ROWTYPE;
    l_ctc_rec                      ctc_rec_type;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_CTC_PVT');
       okc_debug.log('500: Entered get_rec', 2);
    END IF;

    x_no_data_found := TRUE;
    -- Get current database values
    OPEN ctc_pk_csr (p_ctc_rec.id);
    FETCH ctc_pk_csr INTO
              l_ctc_rec.ID,
              l_ctc_rec.CPL_ID,
              l_ctc_rec.CRO_CODE,
              l_ctc_rec.DNZ_CHR_ID,
              l_ctc_rec.OBJECT1_ID1,
              l_ctc_rec.OBJECT1_ID2,
              l_ctc_rec.JTOT_OBJECT1_CODE,
              l_ctc_rec.OBJECT_VERSION_NUMBER,
              l_ctc_rec.CREATED_BY,
              l_ctc_rec.CREATION_DATE,
              l_ctc_rec.LAST_UPDATED_BY,
              l_ctc_rec.LAST_UPDATE_DATE,
              l_ctc_rec.CONTACT_SEQUENCE,
              l_ctc_rec.LAST_UPDATE_LOGIN,
		    l_ctc_rec.PRIMARY_YN,
		    l_ctc_rec.RESOURCE_CLASS,
		    l_ctc_rec.SALES_GROUP_ID,
              l_ctc_rec.ATTRIBUTE_CATEGORY,
              l_ctc_rec.ATTRIBUTE1,
              l_ctc_rec.ATTRIBUTE2,
              l_ctc_rec.ATTRIBUTE3,
              l_ctc_rec.ATTRIBUTE4,
              l_ctc_rec.ATTRIBUTE5,
              l_ctc_rec.ATTRIBUTE6,
              l_ctc_rec.ATTRIBUTE7,
              l_ctc_rec.ATTRIBUTE8,
              l_ctc_rec.ATTRIBUTE9,
              l_ctc_rec.ATTRIBUTE10,
              l_ctc_rec.ATTRIBUTE11,
              l_ctc_rec.ATTRIBUTE12,
              l_ctc_rec.ATTRIBUTE13,
              l_ctc_rec.ATTRIBUTE14,
              l_ctc_rec.ATTRIBUTE15,
              l_ctc_rec.START_DATE,
              l_ctc_rec.END_DATE;

    x_no_data_found := ctc_pk_csr%NOTFOUND;
    CLOSE ctc_pk_csr;

    IF (l_debug = 'Y') THEN
       okc_debug.log('550: Leaving Get_Rec ', 2);
       okc_debug.Reset_Indentation;
    END IF;

    RETURN(l_ctc_rec);

  END get_rec;

  FUNCTION get_rec (
    p_ctc_rec                      IN ctc_rec_type
  ) RETURN ctc_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN

    RETURN(get_rec(p_ctc_rec, l_row_notfound));

  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKC_CONTACTS_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_ctcv_rec                     IN ctcv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN ctcv_rec_type IS
    CURSOR okc_ctcv_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            OBJECT_VERSION_NUMBER,
            CPL_ID,
            CRO_CODE,
            DNZ_CHR_ID,
            CONTACT_SEQUENCE,
            OBJECT1_ID1,
            OBJECT1_ID2,
            JTOT_OBJECT1_CODE,
		  PRIMARY_YN,
		  RESOURCE_CLASS,
		  SALES_GROUP_ID,
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
            LAST_UPDATE_LOGIN,
            START_DATE,
            END_DATE
      FROM Okc_Contacts
     WHERE okc_contacts.id    = p_id;
    l_okc_ctcv_pk                  okc_ctcv_pk_csr%ROWTYPE;
    l_ctcv_rec                     ctcv_rec_type;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_CTC_PVT');
       okc_debug.log('700: Entered get_rec', 2);
    END IF;

    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okc_ctcv_pk_csr (p_ctcv_rec.id);
    FETCH okc_ctcv_pk_csr INTO
              l_ctcv_rec.ID,
              l_ctcv_rec.OBJECT_VERSION_NUMBER,
              l_ctcv_rec.CPL_ID,
              l_ctcv_rec.CRO_CODE,
              l_ctcv_rec.DNZ_CHR_ID,
              l_ctcv_rec.CONTACT_SEQUENCE,
              l_ctcv_rec.OBJECT1_ID1,
              l_ctcv_rec.OBJECT1_ID2,
              l_ctcv_rec.JTOT_OBJECT1_CODE,
		    l_ctcv_rec.PRIMARY_YN,
		    l_ctcv_rec.RESOURCE_CLASS,
		    l_ctcv_rec.SALES_GROUP_ID,
              l_ctcv_rec.ATTRIBUTE_CATEGORY,
              l_ctcv_rec.ATTRIBUTE1,
              l_ctcv_rec.ATTRIBUTE2,
              l_ctcv_rec.ATTRIBUTE3,
              l_ctcv_rec.ATTRIBUTE4,
              l_ctcv_rec.ATTRIBUTE5,
              l_ctcv_rec.ATTRIBUTE6,
              l_ctcv_rec.ATTRIBUTE7,
              l_ctcv_rec.ATTRIBUTE8,
              l_ctcv_rec.ATTRIBUTE9,
              l_ctcv_rec.ATTRIBUTE10,
              l_ctcv_rec.ATTRIBUTE11,
              l_ctcv_rec.ATTRIBUTE12,
              l_ctcv_rec.ATTRIBUTE13,
              l_ctcv_rec.ATTRIBUTE14,
              l_ctcv_rec.ATTRIBUTE15,
              l_ctcv_rec.CREATED_BY,
              l_ctcv_rec.CREATION_DATE,
              l_ctcv_rec.LAST_UPDATED_BY,
              l_ctcv_rec.LAST_UPDATE_DATE,
              l_ctcv_rec.LAST_UPDATE_LOGIN,
              l_ctcv_rec.START_DATE,
              l_ctcv_rec.END_DATE;
     x_no_data_found := okc_ctcv_pk_csr%NOTFOUND;
    CLOSE okc_ctcv_pk_csr;

    IF (l_debug = 'Y') THEN
       okc_debug.log('750: Leaving Get_Rec ', 2);
       okc_debug.Reset_Indentation;
    END IF;

    RETURN(l_ctcv_rec);

  END get_rec;

  FUNCTION get_rec (
    p_ctcv_rec                     IN ctcv_rec_type
  ) RETURN ctcv_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN

    RETURN(get_rec(p_ctcv_rec, l_row_notfound));

  END get_rec;

  ----------------------------------------------------
  -- FUNCTION null_out_defaults for: OKC_CONTACTS_V --
  ----------------------------------------------------
  FUNCTION null_out_defaults (
    p_ctcv_rec	IN ctcv_rec_type
  ) RETURN ctcv_rec_type IS
    l_ctcv_rec	ctcv_rec_type := p_ctcv_rec;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_CTC_PVT');
       okc_debug.log('900: Entered null_out_defaults', 2);
    END IF;

    IF (l_ctcv_rec.object_version_number = OKC_API.G_MISS_NUM) THEN
      l_ctcv_rec.object_version_number := NULL;
    END IF;
    IF (l_ctcv_rec.cpl_id = OKC_API.G_MISS_NUM) THEN
      l_ctcv_rec.cpl_id := NULL;
    END IF;
    IF (l_ctcv_rec.cro_code = OKC_API.G_MISS_CHAR) THEN
      l_ctcv_rec.cro_code := NULL;
    END IF;
    IF (l_ctcv_rec.dnz_chr_id = OKC_API.G_MISS_NUM) THEN
      l_ctcv_rec.dnz_chr_id := NULL;
    END IF;
    IF (l_ctcv_rec.contact_sequence = OKC_API.G_MISS_NUM) THEN
      l_ctcv_rec.contact_sequence := NULL;
    END IF;
    IF (l_ctcv_rec.object1_id1 = OKC_API.G_MISS_CHAR) THEN
      l_ctcv_rec.object1_id1 := NULL;
    END IF;
    IF (l_ctcv_rec.object1_id2 = OKC_API.G_MISS_CHAR) THEN
      l_ctcv_rec.object1_id2 := NULL;
    END IF;
    IF (l_ctcv_rec.jtot_object1_code = OKC_API.G_MISS_CHAR) THEN
      l_ctcv_rec.JTOT_OBJECT1_CODE := NULL;
    END IF;
    IF (l_ctcv_rec.primary_yn = OKC_API.G_MISS_CHAR) THEN
	 l_ctcv_rec.PRIMARY_YN :=NULL;
    END IF;
    IF (l_ctcv_rec.resource_class = OKC_API.G_MISS_CHAR) THEN
	   l_ctcv_rec.RESOURCE_CLASS :=NULL;
    END IF;
    IF (l_ctcv_rec.SALES_GROUP_ID = OKC_API.G_MISS_NUM) THEN
	   l_ctcv_rec.SALES_GROUP_ID :=NULL;
    END IF;
    IF (l_ctcv_rec.attribute_category = OKC_API.G_MISS_CHAR) THEN
      l_ctcv_rec.attribute_category := NULL;
    END IF;
    IF (l_ctcv_rec.attribute1 = OKC_API.G_MISS_CHAR) THEN
      l_ctcv_rec.attribute1 := NULL;
    END IF;
    IF (l_ctcv_rec.attribute2 = OKC_API.G_MISS_CHAR) THEN
      l_ctcv_rec.attribute2 := NULL;
    END IF;
    IF (l_ctcv_rec.attribute3 = OKC_API.G_MISS_CHAR) THEN
      l_ctcv_rec.attribute3 := NULL;
    END IF;
    IF (l_ctcv_rec.attribute4 = OKC_API.G_MISS_CHAR) THEN
      l_ctcv_rec.attribute4 := NULL;
    END IF;
    IF (l_ctcv_rec.attribute5 = OKC_API.G_MISS_CHAR) THEN
      l_ctcv_rec.attribute5 := NULL;
    END IF;
    IF (l_ctcv_rec.attribute6 = OKC_API.G_MISS_CHAR) THEN
      l_ctcv_rec.attribute6 := NULL;
    END IF;
    IF (l_ctcv_rec.attribute7 = OKC_API.G_MISS_CHAR) THEN
      l_ctcv_rec.attribute7 := NULL;
    END IF;
    IF (l_ctcv_rec.attribute8 = OKC_API.G_MISS_CHAR) THEN
      l_ctcv_rec.attribute8 := NULL;
    END IF;
    IF (l_ctcv_rec.attribute9 = OKC_API.G_MISS_CHAR) THEN
      l_ctcv_rec.attribute9 := NULL;
    END IF;
    IF (l_ctcv_rec.attribute10 = OKC_API.G_MISS_CHAR) THEN
      l_ctcv_rec.attribute10 := NULL;
    END IF;
    IF (l_ctcv_rec.attribute11 = OKC_API.G_MISS_CHAR) THEN
      l_ctcv_rec.attribute11 := NULL;
    END IF;
    IF (l_ctcv_rec.attribute12 = OKC_API.G_MISS_CHAR) THEN
      l_ctcv_rec.attribute12 := NULL;
    END IF;
    IF (l_ctcv_rec.attribute13 = OKC_API.G_MISS_CHAR) THEN
      l_ctcv_rec.attribute13 := NULL;
    END IF;
    IF (l_ctcv_rec.attribute14 = OKC_API.G_MISS_CHAR) THEN
      l_ctcv_rec.attribute14 := NULL;
    END IF;
    IF (l_ctcv_rec.attribute15 = OKC_API.G_MISS_CHAR) THEN
      l_ctcv_rec.attribute15 := NULL;
    END IF;
    IF (l_ctcv_rec.created_by = OKC_API.G_MISS_NUM) THEN
      l_ctcv_rec.created_by := NULL;
    END IF;
    IF (l_ctcv_rec.creation_date = OKC_API.G_MISS_DATE) THEN
      l_ctcv_rec.creation_date := NULL;
    END IF;
    IF (l_ctcv_rec.last_updated_by = OKC_API.G_MISS_NUM) THEN
      l_ctcv_rec.last_updated_by := NULL;
    END IF;
    IF (l_ctcv_rec.last_update_date = OKC_API.G_MISS_DATE) THEN
      l_ctcv_rec.last_update_date := NULL;
    END IF;
    IF (l_ctcv_rec.last_update_login = OKC_API.G_MISS_NUM) THEN
      l_ctcv_rec.last_update_login := NULL;
    END IF;
    IF (l_ctcv_rec.start_date = OKC_API.G_MISS_DATE) THEN
      l_ctcv_rec.start_date := NULL;
    END IF;
    IF (l_ctcv_rec.end_date = OKC_API.G_MISS_DATE) THEN
      l_ctcv_rec.end_date := NULL;
    END IF;

    IF (l_debug = 'Y') THEN
       okc_debug.log('950: Leaving null_out_defaults ', 2);
       okc_debug.Reset_Indentation;
    END IF;

    RETURN(l_ctcv_rec);

  END null_out_defaults;
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Attributes
  ---------------------------------------------------------------------------
/*+++++++++++++Start of hand code +++++++++++++++++*/

-- Start of comments
--
-- Procedure Name  : validate_cpl_id
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

procedure validate_cpl_id(x_return_status OUT NOCOPY VARCHAR2,
                          p_ctcv_rec	  IN	CTCV_REC_TYPE) is
l_dummy_var                 varchar2(1) := '?';
cursor l_cpl_csr is
  select 'x'
  from OKC_K_PARTY_ROLES_B
  where id = p_ctcv_rec.cpl_id;
begin

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_CTC_PVT');
       okc_debug.log('1000: Entered validate_cpl_id', 2);
    END IF;

  x_return_status := OKC_API.G_RET_STS_SUCCESS;
  if (p_ctcv_rec.cpl_id = OKC_API.G_MISS_NUM) then
	return;
  end if;
  if (p_ctcv_rec.cpl_id is NULL) then
    OKC_API.set_message(p_app_name     => g_app_name,
                        p_msg_name     => G_REQUIRED_VALUE,
                        p_token1       => G_COL_NAME_TOKEN,
                        p_token1_value => 'CPL_ID');
    raise G_EXCEPTION_HALT_VALIDATION;
  end if;
  open l_cpl_csr;
  fetch l_cpl_csr into l_dummy_var;
  close l_cpl_csr;
  if (l_dummy_var = '?') then
    OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'CPL_ID');
    raise G_EXCEPTION_HALT_VALIDATION;
  end if;

    IF (l_debug = 'Y') THEN
       okc_debug.log('1100: Leaving validate_cpl_id', 2);
       okc_debug.Reset_Indentation;
    END IF;

exception
  when G_EXCEPTION_HALT_VALIDATION then

    IF (l_debug = 'Y') THEN
       okc_debug.log('1200: Exiting validate_cpl_id:G_EXCEPTION_HALT_VALIDATION Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

    x_return_status := OKC_API.G_RET_STS_ERROR;
  when OTHERS then

    IF (l_debug = 'Y') THEN
       okc_debug.log('1300: Exiting validate_cpl_id:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

    if l_cpl_csr%ISOPEN then
      close l_cpl_csr;
    end if;
    OKC_API.set_message(p_app_name     => g_app_name,
                        p_msg_name     => g_unexpected_error,
                        p_token1       => g_sqlcode_token,
                        p_token1_value => sqlcode,
                        p_token2       => g_sqlerrm_token,
                        p_token2_value => sqlerrm);
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

end validate_cpl_id;

-- Start of comments
--
-- Procedure Name  : validate_cro_code
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

procedure validate_cro_code(x_return_status OUT NOCOPY VARCHAR2,
                          p_ctcv_rec	  IN	CTCV_REC_TYPE) is
l_dummy_var                 varchar2(1) := '?';
--
begin

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_CTC_PVT');
       okc_debug.log('1400: Entered validate_cro_code', 2);
    END IF;

  x_return_status := OKC_API.G_RET_STS_SUCCESS;
  if (p_ctcv_rec.cro_code = OKC_API.G_MISS_CHAR) then
    return;
  end if;
  if (p_ctcv_rec.cro_code is NULL) then
    OKC_API.set_message(p_app_name     => g_app_name,
                        p_msg_name     => G_REQUIRED_VALUE,
                        p_token1       => G_COL_NAME_TOKEN,
                        p_token1_value => 'CRO_CODE');
    raise G_EXCEPTION_HALT_VALIDATION;
  end if;

--
  x_return_status := OKC_UTIL.check_lookup_code('OKC_CONTACT_ROLE',p_ctcv_rec.cro_code);
  if (x_return_status <> OKC_API.G_RET_STS_SUCCESS) then
  OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'CRO_CODE');
  x_return_status := OKC_API.G_RET_STS_ERROR;
  end if;
    IF (l_debug = 'Y') THEN
       okc_debug.log('1500: Leaving validate_cro_code', 2);
       okc_debug.Reset_Indentation;
    END IF;

exception
  when G_EXCEPTION_HALT_VALIDATION then

    IF (l_debug = 'Y') THEN
       okc_debug.log('1600: Exiting validate_cro_code:G_EXCEPTION_HALT_VALIDATION Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

    x_return_status := OKC_API.G_RET_STS_ERROR;
  when OTHERS then

    IF (l_debug = 'Y') THEN
       okc_debug.log('1700: Exiting validate_cro_code:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

    OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                        p_msg_name     => g_unexpected_error,
                        p_token1       => g_sqlcode_token,
                        p_token1_value => sqlcode,
                        p_token2       => g_sqlerrm_token,
                        p_token2_value => sqlerrm);
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

end validate_cro_code;

-- Start of comments
--
-- Procedure Name  : validate_JTOT_OBJECT1_CODE
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

procedure validate_JTOT_OBJECT1_CODE(x_return_status OUT NOCOPY VARCHAR2,
                          p_ctcv_rec	  IN	ctcv_rec_TYPE) is
l_dummy_var                 varchar2(1) := '?';
--
cursor l_object1_csr is
select '!'
from
	okc_k_party_roles_b PR
	,okc_contact_sources CS
	,okc_k_headers_all_b KH -- Modified by Jvorugan for Bug:4645341 okc_k_headers_b KH
where
	PR.ID = p_ctcv_rec.CPL_ID
	and CS.CRO_CODE = p_ctcv_rec.CRO_CODE
	and CS.RLE_CODE = PR.RLE_CODE
	and CS.jtot_object_code = p_ctcv_rec.jtot_object1_code
	and sysdate >= CS.start_date
	and (CS.end_date is NULL or CS.end_date>=sysdate)
	and KH.ID = p_ctcv_rec.DNZ_CHR_ID
	and CS.BUY_OR_SELL = KH.BUY_OR_SELL
;
begin

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_CTC_PVT');
       okc_debug.log('1800: Entered validate_JTOT_OBJECT1_CODE', 2);
    END IF;

  x_return_status := OKC_API.G_RET_STS_SUCCESS;
  if (p_ctcv_rec.jtot_object1_code = OKC_API.G_MISS_CHAR or p_ctcv_rec.jtot_object1_code is NULL) then
    return;
  end if;
--
  open l_object1_csr;
  fetch l_object1_csr into l_dummy_var;
  close l_object1_csr;
  if (l_dummy_var = '?') then
    OKC_API.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'JTOT_OBJECT1_CODE');
    x_return_status := OKC_API.G_RET_STS_ERROR;
  end if;

    IF (l_debug = 'Y') THEN
       okc_debug.log('1900: Leaving validate_JTOT_OBJECT1_CODE', 2);
       okc_debug.Reset_Indentation;
    END IF;

exception
  when OTHERS then

    IF (l_debug = 'Y') THEN
       okc_debug.log('2000: Exiting validate_JTOT_OBJECT1_CODE:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

    if l_object1_csr%ISOPEN then
      close l_object1_csr;
    end if;
    OKC_API.set_message(p_app_name     => g_app_name,
                        p_msg_name     => g_unexpected_error,
                        p_token1       => g_sqlcode_token,
                        p_token1_value => sqlcode,
                        p_token2       => g_sqlerrm_token,
                        p_token2_value => sqlerrm);
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

end validate_JTOT_OBJECT1_CODE;

-- Start of comments
--
-- Procedure Name  : validate_object1_id1
-- Description     :  to be called from validate record
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

procedure validate_object1_id1(x_return_status OUT NOCOPY VARCHAR2,
                          p_ctcv_rec	  IN	ctcv_rec_TYPE) is
l_dummy_var                 varchar2(1) := '?';
L_FROM_TABLE    		VARCHAR2(200);
L_WHERE_CLAUSE            VARCHAR2(2000);
cursor l_object1_csr is
select
	from_table
	,trim(where_clause) where_clause
from
	jtf_objects_vl OB
where
	OB.OBJECT_CODE = p_ctcv_rec.JTOT_OBJECT1_CODE
;
l_party_id1 varchar2(40);
l_party_id2 varchar2(200);
l_buy_sell varchar2(3);
l_rle_code varchar2(30);
l_jtot_object1_code varchar2(30);
l_party_id varchar2(100);
l_scs_code varchar2(30);

cursor l2_object1_csr is
select
	CS.constrained_yn
	,PR.OBJECT1_ID1
	,PR.OBJECT1_ID2
        ,PR.JTOT_OBJECT1_CODE
        ,PR.RLE_CODE
        ,KH.BUY_OR_SELL
        ,KH.SCS_CODE
from
	okc_k_party_roles_b PR
	,okc_contact_sources CS
	,okc_k_headers_all_b KH -- Modified by Jvorugan for Bug:4645341 okc_k_headers_b KH
where
	PR.ID = p_ctcv_rec.CPL_ID
	and CS.CRO_CODE = p_ctcv_rec.CRO_CODE
	and CS.RLE_CODE = PR.RLE_CODE
	and CS.jtot_object_code = p_ctcv_rec.jtot_object1_code
	and sysdate >= CS.start_date
	and (CS.end_date is NULL or CS.end_date>=sysdate)
	and KH.ID = p_ctcv_rec.DNZ_CHR_ID
	and CS.BUY_OR_SELL = KH.BUY_OR_SELL
;
e_no_data_found EXCEPTION;
PRAGMA EXCEPTION_INIT(e_no_data_found,100);
e_too_many_rows EXCEPTION;
PRAGMA EXCEPTION_INIT(e_too_many_rows,-1422);
e_source_not_exists EXCEPTION;
PRAGMA EXCEPTION_INIT(e_source_not_exists,-942);
e_source_not_exists1 EXCEPTION;
PRAGMA EXCEPTION_INIT(e_source_not_exists1,-903);
e_column_not_exists EXCEPTION;
PRAGMA EXCEPTION_INIT(e_column_not_exists,-904);

/** this part of the code attempts to retrieve party_id from
    the parent party role **/

FUNCTION Retrieve_Party_ID (P_jtot_object_code IN   VARCHAR2,
			    P_object_id1       IN   VARCHAR2,
			    P_object_id2       IN   VARCHAR2) return VARCHAR2
IS

i		NUMBER;
l_sql_stmt 	VARCHAR2(1000);
v_cursorID		INTEGER;
v_party_id		VARCHAR2(100) := '00';
v_dummy			INTEGER;

FUNCTION COLUMN_EXISTS
  ( p_object_code VARCHAR2
  , p_column_name VARCHAR2
  ) RETURN BOOLEAN IS
    l_view_name varchar2(200);
    l_found NUMBER;
    i NUMBER;

    Cursor l_jtfv_csr Is
      SELECT from_table
      FROM jtf_objects_vl
      WHERE object_code = p_object_code
      AND sysdate between nvl(start_date_active , sysdate-1)
                  and     nvl(end_date_active , sysdate+1);

    Cursor l_jtf_source_csr Is
        SELECT 1 FROM USER_TAB_COLUMNS
        WHERE table_name = l_view_name
        AND column_name = p_column_name;

  BEGIN
    open l_jtfv_csr;
    fetch l_jtfv_csr into l_view_name;
    close l_jtfv_csr;

    -- Trim any space and character after that
    i := INSTR(l_view_name,' ');
    If (i > 0) Then
        l_view_name := substr(l_view_name,1,i - 1);
    End If;

    open l_jtf_source_csr;
    fetch l_jtf_source_csr into l_found;
    close l_jtf_source_csr;
    If (l_found = 1) Then
        return TRUE;
    Else
        return FALSE;
    End If;
  EXCEPTION
    when NO_DATA_FOUND Then
      If (l_jtfv_csr%ISOPEN) Then
    close l_jtfv_csr;
      End If;
      If (l_jtf_source_csr%ISOPEN) Then
    close l_jtf_source_csr;
      End If;
      return FALSE;

    when OTHERS then
      If (l_jtfv_csr%ISOPEN) Then
    close l_jtfv_csr;
      End If;
      If (l_jtf_source_csr%ISOPEN) Then
    close l_jtf_source_csr;
      End If;
      return FALSE;
  END;


BEGIN


	l_sql_stmt := OKC_UTIL.GET_SQL_FROM_JTFV(P_jtot_object_code);

	IF l_sql_stmt is null THEN
	  return '-1';
	END IF;

	IF (column_exists(p_jtot_object_code,'PARTY_ID')) THEN

        i := INSTR(l_sql_stmt,'WHERE');
        If (i > 0) Then
           l_sql_stmt := SUBSTR(l_sql_stmt,1, i + 5) ||
         ' ID1 = ' ||''''|| P_OBJECT_ID1 ||''''|| ' AND ' ||
	 ' ID2 = ' ||''''|| P_OBJECT_ID2 ||'''';
-- || ' AND ' ||
--          SUBSTR(l_sql_stmt,i + 5);
        Else
           -- no where clause. Add before ORDER BY if any
           i := INSTR(l_sql_stmt,'ORDER BY');
           If (i > 0) Then
            l_sql_stmt := SUBSTR(l_sql_stmt,1,i-1) ||
            ' WHERE ID1 = ' ||''''|| P_OBJECT_ID1 ||''''|| ' AND '||
	    ' ID2 = ' ||''''|| P_OBJECT_ID2 ||''''||
            ' ' || SUBSTR(l_sql_stmt,i);
           Else
        -- no where and no order by
        l_sql_stmt := l_sql_stmt || ' WHERE ID1 = '||''''|| P_OBJECT_ID1 ||''''
		|| ' AND '|| ' ID2 = '||'''' || P_OBJECT_ID2 ||'''';
           End If;
        End If;

	END IF;

	l_sql_stmt := 'SELECT PARTY_ID FROM '|| l_sql_stmt;

	v_cursorID := DBMS_SQL.OPEN_CURSOR;
	-- dbms_output.put_line(l_sql_stmt);
	DBMS_SQL.PARSE(v_cursorID,l_sql_stmt,dbms_sql.native);
	DBMS_SQL.DEFINE_COLUMN(v_cursorID,1,v_party_id,100);
	v_dummy := DBMS_SQL.EXECUTE(v_cursorID);
	IF DBMS_SQL.FETCH_ROWS(v_cursorID)= 0 THEN
	 RETURN '-1';
	END IF;
	DBMS_SQL.COLUMN_VALUE(v_cursorID,1,v_party_id);
	DBMS_SQL.CLOSE_CURSOR(v_cursorID);

	return v_party_id;

EXCEPTION
  WHEN OTHERS THEN
    RETURN '-1';

END;
begin

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_CTC_PVT');
       okc_debug.log('2100: Entered validate_object1_id1', 2);
    END IF;

  x_return_status := OKC_API.G_RET_STS_SUCCESS;
  if (p_ctcv_rec.jtot_object1_code = OKC_API.G_MISS_CHAR or p_ctcv_rec.JTOT_OBJECT1_CODE is NULL) then
    return;
  end if;
  if (p_ctcv_rec.object1_id1 = OKC_API.G_MISS_CHAR or p_ctcv_rec.object1_id1 is NULL) then
	return;
  end if;
  open l_object1_csr;
  fetch l_object1_csr into l_from_table, l_where_clause;
  close l_object1_csr;
  if (l_where_clause is not null) then
	l_where_clause := ' and '||l_where_clause;
  end if;
--
  l_dummy_var := 'N';
  open l2_object1_csr;
  fetch l2_object1_csr into l_dummy_var,l_party_id1,l_party_id2,l_jtot_object1_code,l_rle_code,l_buy_sell,l_scs_code;
  close l2_object1_csr;
  if (l_dummy_var = 'N') then
  begin

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_CTC_PVT');
       okc_debug.log('2200: Entered validate_object1_id1', 2);
    END IF;

    EXECUTE IMMEDIATE 'select ''x'' from '||l_from_table||
	' where id1=:object1_id1 and id2=:object1_id2'||l_where_clause
	into l_dummy_var
	USING p_ctcv_rec.object1_id1, p_ctcv_rec.object1_id2;

    IF (l_debug = 'Y') THEN
       okc_debug.log('2300: Leaving validate_object1_id1', 2);
       okc_debug.Reset_Indentation;
    END IF;

  exception
    when e_column_not_exists then

    IF (l_debug = 'Y') THEN
       okc_debug.log('2400: Exiting validate_object1_id1:e_column_not_exists Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

      OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,l_from_table||'.ID1, .ID2');
      x_return_status := OKC_API.G_RET_STS_ERROR;
      return;
    when e_too_many_rows then

    IF (l_debug = 'Y') THEN
       okc_debug.log('2500: Exiting validate_object1_id1:e_too_many_rows Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

      OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,l_from_table||'.ID1, .ID2');
      x_return_status := OKC_API.G_RET_STS_ERROR;
      return;
  end;
  else
  begin

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_CTC_PVT');
       okc_debug.log('2600: Entered validate_object1_id1', 2);
    END IF;


IF  l_scs_code='PROJECT' and (l_jtot_object1_code IN ( 'OKE_BILLTO','OKE_CUST_KADMIN','OKE_MARKFOR','OKE_SHIPTO','OKE_CUSTACCT','OKE_VENDSITE','OKX_CUSTACCT'))
THEN

l_party_id:= retrieve_party_id(l_jtot_object1_code,l_party_id1,l_party_id2);

EXECUTE IMMEDIATE 'select ''x'' from '||l_from_table||
	' where id1=:object1_id1 and id2=:object1_id2 and party_id=:l_party1_id1 '
	||l_where_clause into l_dummy_var
	USING p_ctcv_rec.object1_id1, p_ctcv_rec.object1_id2,l_party_id;

ELSE
EXECUTE IMMEDIATE 'select ''x'' from '||l_from_table||
	' where id1=:object1_id1 and id2=:object1_id2 and party_id=:l_party1_id1 and party_id2=:l_party1_id2'
	||l_where_clause into l_dummy_var
	USING p_ctcv_rec.object1_id1, p_ctcv_rec.object1_id2,l_party_id1,l_party_id2;
END IF;

    IF (l_debug = 'Y') THEN
       okc_debug.log('2700: Leaving validate_object1_id1', 2);
       okc_debug.Reset_Indentation;
    END IF;

  exception
    when e_column_not_exists then

    IF (l_debug = 'Y') THEN
       okc_debug.log('2800: Exiting validate_object1_id1:e_column_not_exists Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

      OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,l_from_table||'.ID1, .ID2, .PARTY_ID, .PARTY_ID2');
      x_return_status := OKC_API.G_RET_STS_ERROR;
      return;
    when e_too_many_rows then

    IF (l_debug = 'Y') THEN
       okc_debug.log('2900: Exiting validate_object1_id1:e_too_many_rows Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

      OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,l_from_table||'.ID1, .ID2, .PARTY_ID, .PARTY_ID2');
      x_return_status := OKC_API.G_RET_STS_ERROR;
      return;
  end;
  end if;
--
    IF (l_debug = 'Y') THEN
       okc_debug.log('3000: Exiting validate_object1_id1', 2);
       okc_debug.Reset_Indentation;
    END IF;

exception
  when e_source_not_exists then

    IF (l_debug = 'Y') THEN
       okc_debug.log('3100: Exiting validate_object1_id1:e_source_not_exists Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

    OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'JTOT_OBJECT1_CODE');
    x_return_status := OKC_API.G_RET_STS_ERROR;
  when e_source_not_exists1 then

    IF (l_debug = 'Y') THEN
       okc_debug.log('3200: Exiting validate_object1_id1:e_source_not_exists1 Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

    OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'JTOT_OBJECT1_CODE');
    x_return_status := OKC_API.G_RET_STS_ERROR;
    when e_no_data_found then

    IF (l_debug = 'Y') THEN
       okc_debug.log('3300: Exiting validate_object1_id1:e_no_data_found Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

      OKC_API.set_message(G_APP_NAME,'OKC_INVALID_CONTACT');
      x_return_status := OKC_API.G_RET_STS_ERROR;
  when OTHERS then

    IF (l_debug = 'Y') THEN
       okc_debug.log('3400: Exiting validate_object1_id1:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

    if l_object1_csr%ISOPEN then
      close l_object1_csr;
    end if;
    if l2_object1_csr%ISOPEN then
      close l2_object1_csr;
    end if;
    OKC_API.set_message(p_app_name     => g_app_name,
                        p_msg_name     => g_unexpected_error,
                        p_token1       => g_sqlcode_token,
                        p_token1_value => sqlcode,
                        p_token2       => g_sqlerrm_token,
                        p_token2_value => sqlerrm);
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

end validate_object1_id1;

-- Start of comments
--
-- Procedure Name  : validate_dnz_chr_id
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

procedure validate_dnz_chr_id(x_return_status OUT NOCOPY VARCHAR2,
                          p_ctcv_rec	  IN	CTCV_REC_TYPE) is
l_dummy varchar2(1) := '?';
cursor Kt_Hr_Mj_Vr is
    select '!'
    from okc_k_headers_all_b -- Modified by Jvorugan for Bug:4645341 okc_k_headers_b
    where id = p_ctcv_rec.dnz_chr_id;
begin

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_CTC_PVT');
       okc_debug.log('3500: Entered validate_dnz_chr_id', 2);
    END IF;

  x_return_status := OKC_API.G_RET_STS_SUCCESS;
  if (p_ctcv_rec.dnz_chr_id = OKC_API.G_MISS_NUM) then
    return;
  end if;
  if (p_ctcv_rec.dnz_chr_id is NULL) then
    OKC_API.set_message(p_app_name     => g_app_name,
                        p_msg_name     => G_REQUIRED_VALUE,
                        p_token1       => G_COL_NAME_TOKEN,
                        p_token1_value => 'DNZ_CHR_ID');
      x_return_status := OKC_API.G_RET_STS_ERROR;
	return;
  end if;
  open Kt_Hr_Mj_Vr;
  fetch Kt_Hr_Mj_Vr into l_dummy;
  close Kt_Hr_Mj_Vr;
  if (l_dummy='?') then
  	OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'DNZ_CHR_ID');
      x_return_status := OKC_API.G_RET_STS_ERROR;
	return;
  end if;

    IF (l_debug = 'Y') THEN
       okc_debug.log('3600: Leaving validate_dnz_chr_id', 2);
       okc_debug.Reset_Indentation;
    END IF;

exception
  when OTHERS then

    IF (l_debug = 'Y') THEN
       okc_debug.log('3700: Exiting validate_dnz_chr_id:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

    OKC_API.set_message(p_app_name     => g_app_name,
                        p_msg_name     => g_unexpected_error,
                        p_token1       => g_sqlcode_token,
                        p_token1_value => sqlcode,
                        p_token2       => g_sqlerrm_token,
                        p_token2_value => sqlerrm);
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

end validate_dnz_chr_id;

 -- Start of comments
 --
 -- Procedure Name  : validate_primary_yn
 -- Description     :
 -- Business Rules  :
 -- Parameters      :
 -- Version         : 1.0
 -- End of comments
 PROCEDURE validate_primary_yn(x_return_status OUT NOCOPY   VARCHAR2,
       p_ctcv_rec      IN    CTCV_REC_TYPE) IS

  l_dummy varchar2(1) := '?';

  CURSOR l_contacts_csr IS
  SELECT '!'
  FROM OKC_CONTACTS ctc
  WHERE id  <>  NVL(p_ctcv_rec.id,-99999)
  AND   cpl_id     = p_ctcv_rec.cpl_id
  AND   dnz_chr_id =  p_ctcv_rec.dnz_chr_id
  AND   primary_yn = 'Y'
  AND   cro_code   = p_ctcv_rec.cro_code
  AND   NVL(TO_DATE(p_ctcv_rec.start_date,'YYYY/MM/DD'),TRUNC(sysdate)) <=
	   NVL(ctc.end_date,to_date('01-01-4713','DD-MM-YYYY'))
  AND   NVL(TO_DATE(p_ctcv_rec.end_date,'YYYY/MM/DD'),TO_DATE('01-01-4713','DD-MM-YYYY')) >=
	   NVL(ctc.start_date,TRUNC(sysdate));

  Begin
  IF (l_debug = 'Y') THEN
     okc_debug.Set_Indentation('OKC_CPL_PVT');
     okc_debug.log('4150: Entered validate_primary_yn', 2);
  END IF;

    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- check that data exists
    IF (p_ctcv_rec.primary_yn IS NOT NULL AND
        p_ctcv_rec.primary_yn <> OKC_API.G_MISS_CHAR) THEN

        IF p_ctcv_rec.primary_yn NOT IN ('Y','N') Then
                 OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                                     p_msg_name     => g_invalid_value,
                                     p_token1       => g_col_name_token,
                                     p_token1_value => 'PRIMARY_YN');
                    -- notify caller of an error
           x_return_status := OKC_API.G_RET_STS_ERROR;
           -- halt validation
           raise G_EXCEPTION_HALT_VALIDATION;
        END IF;
    END IF;  -- end of (p_ctcv_rec.primary_yn <> OKC_API.G_MISS_CHAR OR ---

    IF (p_ctcv_rec.primary_yn = 'Y') THEN
	   --- (p_ctcv_rec.end_date  >= trunc(SYSDATE)) THEN ---Bug#2284573
        -----(SYSDATE between p_ctcv_rec.start_date AND p_ctcv_rec.end_date) THEN ---Bug#2284573
          OPEN  l_contacts_csr;
          FETCH l_contacts_csr INTO l_dummy;
          CLOSE l_contacts_csr;
          IF (l_dummy='!') THEN
             OKC_API.set_message(G_APP_NAME,'OKC_PRIMARY_CONTACT_ERROR');
             x_return_status := OKC_API.G_RET_STS_ERROR;
             IF (l_debug = 'Y') THEN
                okc_debug.Reset_Indentation;
             END IF;
             RETURN;
          END IF;
    END IF;    --end of (p_ctcv_rec.primary_yn = 'Y')
     IF (l_debug = 'Y') THEN
        okc_debug.log('4160: Leaving validate_primary_yn', 2);
        okc_debug.Reset_Indentation;
     END IF;

  exception
    when G_EXCEPTION_HALT_VALIDATION then
  IF (l_debug = 'Y') THEN
     okc_debug.log('4170: Exiting validate_primary_yn:G_EXCEPTION_HALT_VALIDATION Exception', 2);
     okc_debug.Reset_Indentation;
  END IF;

  -- no processing necessary; validation can continue with next column
  null;
    when OTHERS then
    IF (l_debug = 'Y') THEN
       okc_debug.log('4180: Exiting validate_primary_yn:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

	  -- store SQL error message on message stack
	  OKC_API.SET_MESSAGE(p_app_name        => g_app_name,
					  p_msg_name        => g_unexpected_error,
					  p_token1          => g_sqlcode_token,
					  p_token1_value    => sqlcode,
					  p_token2          => g_sqlerrm_token,
					  p_token2_value    => sqlerrm);

       -- notify caller of an error as UNEXPETED error
	  x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  End validate_primary_yn;



  -- Start of comments
  --
  -- Procedure Name  : validate_resource_class
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  PROCEDURE validate_resource_class(x_return_status OUT NOCOPY   VARCHAR2,
                                    p_ctcv_rec      IN    CTCV_REC_TYPE) IS
  Begin
  IF (l_debug = 'Y') THEN
	okc_debug.Set_Indentation('OKC_CPL_PVT');
	okc_debug.log('4250: Entered validate_resource_class', 2);
  END IF;

    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- check that data exists
    IF (p_ctcv_rec.resource_class IS NOT NULL AND
	   p_ctcv_rec.resource_class <> OKC_API.G_MISS_CHAR) THEN

        -- Check If the value is a valid code from lookup table
	   x_return_status := OKC_UTIL.check_lookup_code('OKS_RESOURCE_CLASS',
                                                       p_ctcv_rec.resource_class);

       If (x_return_status = OKC_API.G_RET_STS_ERROR) Then
       --set error message in message stack
	     OKC_API.SET_MESSAGE(
                p_app_name     => G_APP_NAME,
                p_msg_name     => G_INVALID_VALUE,
                p_token1       => G_COL_NAME_TOKEN,
                p_token1_value => 'RESOURCE_CLASS');

          RAISE G_EXCEPTION_HALT_VALIDATION;
      Elsif (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
		raise G_EXCEPTION_HALT_VALIDATION;
	 End If;
    End If;
    IF (l_debug = 'Y') THEN
	   okc_debug.log('4260: Exiting validate_resource_class', 2);
        okc_debug.Reset_Indentation;
    END IF;

  EXCEPTION
	 when OTHERS then

      IF (l_debug = 'Y') THEN
          okc_debug.log('4270: Exiting validate_resource_class:OTHERS Exception', 2);
		okc_debug.Reset_Indentation;
      END IF;

       -- store SQL error message on message stack
       OKC_API.SET_MESSAGE(p_app_name        => g_app_name,
                           p_msg_name        => g_unexpected_error,
					  p_token1          => g_sqlcode_token,
					  p_token2          => g_sqlerrm_token,
					  p_token2_value    => sqlerrm);

       -- notify caller of an error as UNEXPETED error
          x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

End validate_resource_class;

/*+++++++++++++End of hand code +++++++++++++++++++*/
  --------------------------------------------
  -- alidate_Attributes for:OKC_CONTACTS_V --
  --------------------------------------------
  FUNCTION Validate_Attributes (
    p_ctcv_rec IN  ctcv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

/*+++++++++++++Start of hand code +++++++++++++++++*/
  x_return_status  varchar2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_CTC_PVT');
       okc_debug.log('3800: Entered Validate_Attributes', 2);
    END IF;

    -- call each column-level validation
    validate_cpl_id(x_return_status => l_return_status,
                    p_ctcv_rec      => p_ctcv_rec);
    if (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
      return OKC_API.G_RET_STS_UNEXP_ERROR;
    end if;
    if (l_return_status = OKC_API.G_RET_STS_ERROR
        and x_return_status = OKC_API.G_RET_STS_SUCCESS) then
        x_return_status := OKC_API.G_RET_STS_ERROR;
    end if;
--
    validate_cro_code(x_return_status => l_return_status,
                    p_ctcv_rec      => p_ctcv_rec);
    if (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
      return OKC_API.G_RET_STS_UNEXP_ERROR;
    end if;
    if (l_return_status = OKC_API.G_RET_STS_ERROR
        and x_return_status = OKC_API.G_RET_STS_SUCCESS) then
        x_return_status := OKC_API.G_RET_STS_ERROR;
    end if;
--
    validate_dnz_chr_id(x_return_status => l_return_status,
                    p_ctcv_rec      => p_ctcv_rec);
    if (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
      return OKC_API.G_RET_STS_UNEXP_ERROR;
    end if;
    if (l_return_status = OKC_API.G_RET_STS_ERROR
        and x_return_status = OKC_API.G_RET_STS_SUCCESS) then
        x_return_status := OKC_API.G_RET_STS_ERROR;
    end if;
--
    validate_primary_yn(x_return_status => l_return_status,
				    p_ctcv_rec      => p_ctcv_rec);
    if (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
      return OKC_API.G_RET_STS_UNEXP_ERROR;
    end If;
    If (l_return_status = OKC_API.G_RET_STS_ERROR
	   and x_return_status = OKC_API.G_RET_STS_SUCCESS) then
	   x_return_status := OKC_API.G_RET_STS_ERROR;
    end If;
--
    validate_resource_class(x_return_status => l_return_status,
					   p_ctcv_rec      => p_ctcv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
	  RETURN OKC_API.G_RET_STS_UNEXP_ERROR;
    END IF;
    IF (l_return_status = OKC_API.G_RET_STS_ERROR
	   AND  x_return_status = OKC_API.G_RET_STS_SUCCESS) THEN
	   x_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
--
    return x_return_status;

    IF (l_debug = 'Y') THEN
       okc_debug.log('3900: Leaving Validate_Attributes', 2);
       okc_debug.Reset_Indentation;
    END IF;

  exception
    when OTHERS then

    IF (l_debug = 'Y') THEN
       okc_debug.log('4000: Exiting Validate_Attributes:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

      -- store SQL error message on message stack for caller
      OKC_API.set_message(p_app_name     => g_app_name,
                        p_msg_name     => g_unexpected_error,
                        p_token1       => g_sqlcode_token,
                        p_token1_value => sqlcode,
                        p_token2       => g_sqlerrm_token,
                        p_token2_value => sqlerrm);
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      return x_return_status;

  END Validate_Attributes;
/*+++++++++++++End of hand code +++++++++++++++++*/

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Record
  ---------------------------------------------------------------------------
  ----------------------------------------
  -- Validate_Record for:OKC_CONTACTS_V --
  ----------------------------------------
  FUNCTION Validate_Record (
    p_ctcv_rec IN ctcv_rec_type
  ) RETURN VARCHAR2 IS

  /*+++++++++++++Start of hand code +++++++++++++++++*/
  -- ------------------------------------------------------
  -- To check for any matching row, for unique check
  -- The cursor includes id check filter to handle updates
  -- for case K2 should not overwrite already existing K1
  -- There is an index OKC_CONTACTS_U2 on these five fields
  -- with three fields nullable. Hence NVL added around.
  -- ------------------------------------------------------
  -- Added for Bug 3177402,2900541 conditions to check for overlapping dates
  -- Start date has to be non-null ,end date can be Null
	CURSOR cur_ctcv IS
	SELECT 'x'
	FROM   okc_contacts
	WHERE  cpl_id                     = p_ctcv_rec.CPL_ID
	AND    cro_code                   = p_ctcv_rec.CRO_CODE
	AND    NVL(jtot_object1_code,'X') = NVL(p_ctcv_rec.JTOT_OBJECT1_CODE,'X')
	AND    NVL(object1_id1,'X')       = NVL(p_ctcv_rec.OBJECT1_ID1,'X')
	AND    NVL(object1_id2,'X')       = NVL(p_ctcv_rec.OBJECT1_ID2,'X')
	AND    id                        <> NVL(p_ctcv_rec.ID,-9999)
        AND (((p_ctcv_rec.START_DATE BETWEEN TRUNC(START_DATE) AND TRUNC(END_DATE))
        OR ((TRUNC(START_DATE) BETWEEN  p_ctcv_rec.START_DATE AND  p_ctcv_rec.END_DATE)
        OR  (TRUNC(END_DATE) BETWEEN  p_ctcv_rec.START_DATE   AND  p_ctcv_rec.END_DATE))
        OR  (p_ctcv_rec.END_DATE BETWEEN TRUNC(START_DATE) AND TRUNC(END_DATE)))
        OR ((END_DATE IS NULL AND (p_ctcv_rec.END_DATE  = START_DATE))
        OR (p_ctcv_rec.END_DATE IS NULL AND (p_ctcv_rec.START_DATE <=END_DATE))
        OR (p_ctcv_rec.END_DATE IS NULL AND END_DATE IS NULL)));


  x_return_status   VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  l_return_status   VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  l_row_found       BOOLEAN     := FALSE;
  l_dummy           VARCHAR2(1);
  -- indirection
  l_rle_code                  varchar2(30);
  l_buy_or_sell               varchar2(3);
  l_access_level              varchar2(1);

  Cursor c_buy_or_sell Is
   Select buy_or_sell
   From   okc_k_headers_all_b --Modified by Jvorugan for Bug:4645341 okc_k_headers_b
   Where  id = p_ctcv_rec.dnz_chr_id;

  Cursor c_rle_code Is
   Select rle_code
   From   okc_k_party_roles_b
   Where  dnz_chr_id = p_ctcv_rec.dnz_chr_id;

  Cursor c_access_level(p_rle_code varchar2, p_intent varchar2) Is
   Select access_level
   From   okc_contact_sources
   Where  rle_code = p_rle_code
     and  cro_code = p_ctcv_rec.cro_code
     and  buy_or_sell = p_intent;
  --

  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_CTC_PVT');
       okc_debug.log('4100: Entered Validate_Record', 2);
    END IF;

    -- indirection
    Open c_buy_or_sell;
    Fetch c_buy_or_sell Into l_buy_or_sell;
    Close c_buy_or_sell;

    Open c_rle_code;
    Fetch c_rle_code Into l_rle_code;
    Close c_rle_code;

    Open c_access_level(l_rle_code, l_buy_or_sell);
    Fetch c_access_level Into l_access_level;
    Close c_access_level;

    If l_access_level = 'U' Then -- if user defined
    --

      validate_JTOT_OBJECT1_CODE(x_return_status => l_return_status,
                                 p_ctcv_rec      => p_ctcv_rec);

      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR)
	 THEN
         IF (l_debug = 'Y') THEN
             okc_debug.log('4150: Exiting Validate_jtot_object1_code in validate_record:unexp err', 2);
             okc_debug.Reset_Indentation;
         END IF;
         RETURN OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;

      IF (    l_return_status = OKC_API.G_RET_STS_ERROR
          AND x_return_status = OKC_API.G_RET_STS_SUCCESS)
      THEN
          x_return_status := OKC_API.G_RET_STS_ERROR;
      END IF;

      -- -----------------------------------------------------
      validate_OBJECT1_ID1(x_return_status => l_return_status,
                           p_ctcv_rec      => p_ctcv_rec);

      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR)
	 THEN
         IF (l_debug = 'Y') THEN
             okc_debug.log('4170: Exiting Validate_object1_id1 in validate_record:unexp err', 2);
             okc_debug.Reset_Indentation;
         END IF;
         RETURN OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;

      IF (    l_return_status = OKC_API.G_RET_STS_ERROR
          AND x_return_status = OKC_API.G_RET_STS_SUCCESS)
      THEN
          x_return_status := OKC_API.G_RET_STS_ERROR;
      END IF;
    End If; -- if user defined
    -- ---------------------------------------------------------------------
    -- Bug 1636056 related changes - Shyam
    -- OKC_UTIL.check_comp_unique call is replaced with
    -- the explicit cursors above, for identical function to check
    -- uniqueness in OKC_CONTACTS table.
    -- ---------------------------------------------------------------------
       IF (       (p_ctcv_rec.CPL_ID IS NOT NULL)
	         AND (p_ctcv_rec.CPL_ID <> OKC_API.G_MISS_NUM)    )
		AND
	     (       (p_ctcv_rec.CRO_CODE IS NOT NULL)
		    AND (p_ctcv_rec.CRO_CODE <> OKC_API.G_MISS_CHAR) )
       THEN
		OPEN  cur_ctcv;
		FETCH cur_ctcv INTO l_dummy;
		l_row_found := cur_ctcv%FOUND;
		CLOSE cur_ctcv;

          IF (l_row_found)
	  THEN
		    -- Display the newly defined error message
		    OKC_API.set_message(G_APP_NAME,
		                        'OKC_DUP_CONTACT_PARTY_ID');
              x_return_status := OKC_API.G_RET_STS_ERROR;
          END IF;
       END IF;

    -- ---------------------------------------------------------------------
    -- Bug 1785323 related changes - jogeorge
    -- Validating End_date against Start_Date
    -- ---------------------------------------------------------------------

       IF p_ctcv_rec.START_DATE IS NOT NULL AND  p_ctcv_rec.END_DATE IS NOT NULL THEN
          IF p_ctcv_rec.END_DATE < p_ctcv_rec.START_DATE THEN
             OKC_API.set_message(G_APP_NAME,'OKC_INVALID_END_DATE');
             x_return_status := OKC_API.G_RET_STS_ERROR;
          END IF;
       END IF;
       RETURN x_return_status;

    IF (l_debug = 'Y') THEN
       okc_debug.log('4200: Leaving Validate_Record', 2);
       okc_debug.Reset_Indentation;
    END IF;

  EXCEPTION
      WHEN OTHERS THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('4300: Exiting Validate_Record:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

          -- store SQL error message on message stack for caller
          OKC_API.set_message(p_app_name     => g_app_name,
                              p_msg_name     => g_unexpected_error,
                              p_token1       => g_sqlcode_token,
                              p_token1_value => sqlcode,
                              p_token2       => g_sqlerrm_token,
                              p_token2_value => sqlerrm);

          x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

      RETURN x_return_status;

  END Validate_Record;

  /*+++++++++++++End of hand code +++++++++++++++++*/

  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from	IN ctcv_rec_type,
    p_to	IN OUT NOCOPY ctc_rec_type
  ) IS
  BEGIN

    p_to.id := p_from.id;
    p_to.cpl_id := p_from.cpl_id;
    p_to.cro_code := p_from.cro_code;
    p_to.dnz_chr_id := p_from.dnz_chr_id;
    p_to.object1_id1 := p_from.object1_id1;
    p_to.object1_id2 := p_from.object1_id2;
    p_to.JTOT_OBJECT1_CODE := p_from.JTOT_OBJECT1_CODE;
    p_to.object_version_number := p_from.object_version_number;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.contact_sequence := p_from.contact_sequence;
    p_to.last_update_login := p_from.last_update_login;
    p_to.primary_yn        := p_from.primary_yn;
    p_to.RESOURCE_CLASS    := p_from.RESOURCE_CLASS;
    p_to.SALES_GROUP_ID    := p_from.SALES_GROUP_ID;
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
    p_to.start_date := p_from.start_date;
    p_to.end_date := p_from.end_date;

  END migrate;

  PROCEDURE migrate (
    p_from	IN ctc_rec_type,
    p_to	IN OUT NOCOPY ctcv_rec_type
  ) IS
  BEGIN

    p_to.id := p_from.id;
    p_to.cpl_id := p_from.cpl_id;
    p_to.cro_code := p_from.cro_code;
    p_to.dnz_chr_id := p_from.dnz_chr_id;
    p_to.object1_id1 := p_from.object1_id1;
    p_to.object1_id2 := p_from.object1_id2;
    p_to.JTOT_OBJECT1_CODE := p_from.JTOT_OBJECT1_CODE;
    p_to.object_version_number := p_from.object_version_number;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.contact_sequence := p_from.contact_sequence;
    p_to.last_update_login := p_from.last_update_login;
    p_to.primary_yn        := p_from.primary_yn;
    p_to.RESOURCE_CLASS    := p_from.RESOURCE_CLASS;
    p_to.SALES_GROUP_ID    := p_from.SALES_GROUP_ID;
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
    p_to.start_date := p_from.start_date;
    p_to.end_date := p_from.end_date;

  END migrate;

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_row
  ---------------------------------------------------------------------------
  -------------------------------------
  -- validate_row for:OKC_CONTACTS_V --
  -------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ctcv_rec                     IN ctcv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_ctcv_rec                     ctcv_rec_type := p_ctcv_rec;
    l_ctc_rec                      ctc_rec_type;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_CTC_PVT');
       okc_debug.log('4600: Entered validate_row', 2);
    END IF;

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
    l_return_status := Validate_Attributes(l_ctcv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_ctcv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);

    IF (l_debug = 'Y') THEN
       okc_debug.log('4700: Leaving validate_row', 2);
       okc_debug.Reset_Indentation;
    END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('4800: Exiting validate_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('4900: Exiting validate_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('5000: Exiting validate_row:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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
  -- PL/SQL TBL validate_row for:CTCV_TBL --
  ------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ctcv_tbl                     IN ctcv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_CTC_PVT');
       okc_debug.log('5100: Entered validate_row', 2);
    END IF;

    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_ctcv_tbl.COUNT > 0) THEN
      i := p_ctcv_tbl.FIRST;
      LOOP
        validate_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_ctcv_rec                     => p_ctcv_tbl(i));
        EXIT WHEN (i = p_ctcv_tbl.LAST);
        i := p_ctcv_tbl.NEXT(i);
      END LOOP;
    END IF;

    IF (l_debug = 'Y') THEN
       okc_debug.log('5200: Leaving validate_row', 2);
       okc_debug.Reset_Indentation;
    END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('5300: Exiting validate_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('5400: Exiting validate_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('5500: Exiting validate_row:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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
  ---------------------------------
  -- insert_row for:OKC_CONTACTS --
  ---------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ctc_rec                      IN ctc_rec_type,
    x_ctc_rec                      OUT NOCOPY ctc_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'CONTACTS_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_ctc_rec                      ctc_rec_type := p_ctc_rec;
    l_def_ctc_rec                  ctc_rec_type;
    -------------------------------------
    -- Set_Attributes for:OKC_CONTACTS --
    -------------------------------------
    FUNCTION Set_Attributes (
      p_ctc_rec IN  ctc_rec_type,
      x_ctc_rec OUT NOCOPY ctc_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN

      x_ctc_rec := p_ctc_rec;
	 x_ctc_rec.primary_yn := UPPER(x_ctc_rec.PRIMARY_YN);

      RETURN(l_return_status);

    END Set_Attributes;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_CTC_PVT');
       okc_debug.log('5700: Entered insert_row', 2);
    END IF;

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
      p_ctc_rec,                         -- IN
      l_ctc_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKC_CONTACTS(
        id,
        cpl_id,
        cro_code,
        dnz_chr_id,
        object1_id1,
        object1_id2,
        JTOT_OBJECT1_CODE,
        object_version_number,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        contact_sequence,
        last_update_login,
	   primary_yn,
	   RESOURCE_CLASS,
	   SALES_GROUP_ID,
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
        attribute15,
        start_date,
        end_date)
      VALUES (
        l_ctc_rec.id,
        l_ctc_rec.cpl_id,
        l_ctc_rec.cro_code,
        l_ctc_rec.dnz_chr_id,
        l_ctc_rec.object1_id1,
        l_ctc_rec.object1_id2,
        l_ctc_rec.JTOT_OBJECT1_CODE,
        l_ctc_rec.object_version_number,
        l_ctc_rec.created_by,
        l_ctc_rec.creation_date,
        l_ctc_rec.last_updated_by,
        l_ctc_rec.last_update_date,
        l_ctc_rec.contact_sequence,
        l_ctc_rec.last_update_login,
	   l_ctc_rec.primary_yn,
	   l_ctc_rec.RESOURCE_CLASS,
	   l_ctc_rec.SALES_GROUP_ID,
        l_ctc_rec.attribute_category,
        l_ctc_rec.attribute1,
        l_ctc_rec.attribute2,
        l_ctc_rec.attribute3,
        l_ctc_rec.attribute4,
        l_ctc_rec.attribute5,
        l_ctc_rec.attribute6,
        l_ctc_rec.attribute7,
        l_ctc_rec.attribute8,
        l_ctc_rec.attribute9,
        l_ctc_rec.attribute10,
        l_ctc_rec.attribute11,
        l_ctc_rec.attribute12,
        l_ctc_rec.attribute13,
        l_ctc_rec.attribute14,
        l_ctc_rec.attribute15,
        l_ctc_rec.start_date,
        l_ctc_rec.end_date);
    -- Set OUT values
/* Bug fix for 6882512*/
 	     update_contact_stecode(p_chr_id => l_ctc_rec.dnz_chr_id,
 	                                x_return_status=>l_return_status);

 	     IF l_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
 	        RAISE OKC_API.G_EXCEPTION_ERROR;
 	     END IF;
     /* Bug fix for 6882512*/
    x_ctc_rec := l_ctc_rec;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);

    IF (l_debug = 'Y') THEN
       okc_debug.log('5800: Leaving insert_row', 2);
       okc_debug.Reset_Indentation;
    END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('5900: Exiting insert_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('6000: Exiting insert_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('6100: Exiting insert_row:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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
  -----------------------------------
  -- insert_row for:OKC_CONTACTS_V --
  -----------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ctcv_rec                     IN ctcv_rec_type,
    x_ctcv_rec                     OUT NOCOPY ctcv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_ctcv_rec                     ctcv_rec_type;
    l_def_ctcv_rec                 ctcv_rec_type;
    l_ctc_rec                      ctc_rec_type;
    lx_ctc_rec                     ctc_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_ctcv_rec	IN ctcv_rec_type
    ) RETURN ctcv_rec_type IS
      l_ctcv_rec	ctcv_rec_type := p_ctcv_rec;
    BEGIN

      l_ctcv_rec.CREATION_DATE := SYSDATE;
      l_ctcv_rec.CREATED_BY := FND_GLOBAL.USER_ID;
      l_ctcv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_ctcv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_ctcv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;

      RETURN(l_ctcv_rec);

    END fill_who_columns;
    ---------------------------------------
    -- Set_Attributes for:OKC_CONTACTS_V --
    ---------------------------------------
    FUNCTION Set_Attributes (
      p_ctcv_rec IN  ctcv_rec_type,
      x_ctcv_rec OUT NOCOPY ctcv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN

      x_ctcv_rec := p_ctcv_rec;
      x_ctcv_rec.OBJECT_VERSION_NUMBER := 1;

      RETURN(l_return_status);

    END Set_Attributes;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_CTC_PVT');
       okc_debug.log('6400: Entered insert_row', 2);
    END IF;

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
    l_ctcv_rec := null_out_defaults(p_ctcv_rec);
    -- Set primary key value
    l_ctcv_rec.ID := get_seq_id;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      l_ctcv_rec,                        -- IN
      l_def_ctcv_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_ctcv_rec := fill_who_columns(l_def_ctcv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_ctcv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_ctcv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_ctcv_rec, l_ctc_rec);
    --------------------------------------------
    -- Call the INSERT_ROW for each child record
    --------------------------------------------
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_ctc_rec,
      lx_ctc_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_ctc_rec, l_def_ctcv_rec);
    -- Set OUT values
    x_ctcv_rec := l_def_ctcv_rec;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);

    IF (l_debug = 'Y') THEN
       okc_debug.log('6500: Leaving insert_row', 2);
       okc_debug.Reset_Indentation;
    END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('6600: Exiting insert_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('6700: Exiting insert_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('6800: Exiting insert_row:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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
  -- PL/SQL TBL insert_row for:CTCV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ctcv_tbl                     IN ctcv_tbl_type,
    x_ctcv_tbl                     OUT NOCOPY ctcv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_CTC_PVT');
       okc_debug.log('6900: Entered insert_row', 2);
    END IF;

    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_ctcv_tbl.COUNT > 0) THEN
      i := p_ctcv_tbl.FIRST;
      LOOP
        insert_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_ctcv_rec                     => p_ctcv_tbl(i),
          x_ctcv_rec                     => x_ctcv_tbl(i));
        EXIT WHEN (i = p_ctcv_tbl.LAST);
        i := p_ctcv_tbl.NEXT(i);
      END LOOP;
    END IF;

    IF (l_debug = 'Y') THEN
       okc_debug.log('7000: Leaving insert_row', 2);
       okc_debug.Reset_Indentation;
    END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('7100: Exiting insert_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('7200: Exiting insert_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('7300: Exiting insert_row:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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
  -------------------------------
  -- lock_row for:OKC_CONTACTS --
  -------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ctc_rec                      IN ctc_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_ctc_rec IN ctc_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKC_CONTACTS
     WHERE ID = p_ctc_rec.id
       AND OBJECT_VERSION_NUMBER = p_ctc_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR  lchk_csr (p_ctc_rec IN ctc_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKC_CONTACTS
    WHERE ID = p_ctc_rec.id;
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'CONTACTS_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_object_version_number       OKC_CONTACTS.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number      OKC_CONTACTS.OBJECT_VERSION_NUMBER%TYPE;
    l_row_notfound                BOOLEAN := FALSE;
    lc_row_notfound               BOOLEAN := FALSE;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_CTC_PVT');
       okc_debug.log('7400: Entered lock_row', 2);
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_CTC_PVT');
       okc_debug.log('7500: Entered lock_row', 2);
    END IF;

      OPEN lock_csr(p_ctc_rec);
      FETCH lock_csr INTO l_object_version_number;
      l_row_notfound := lock_csr%NOTFOUND;
      CLOSE lock_csr;

    IF (l_debug = 'Y') THEN
       okc_debug.log('7600: Leaving lock_row', 2);
       okc_debug.Reset_Indentation;
    END IF;

    EXCEPTION
      WHEN E_Resource_Busy THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('7700: Exiting lock_row:E_Resource_Busy Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

        IF (lock_csr%ISOPEN) THEN
          CLOSE lock_csr;
        END IF;
        OKC_API.set_message(G_FND_APP,G_FORM_UNABLE_TO_RESERVE_REC);
        RAISE APP_EXCEPTIONS.RECORD_LOCK_EXCEPTION;
    END;

    IF ( l_row_notfound ) THEN
      OPEN lchk_csr(p_ctc_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_ctc_rec.object_version_number THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_ctc_rec.object_version_number THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number = -1 THEN
      OKC_API.set_message(G_APP_NAME,G_RECORD_LOGICALLY_DELETED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);

    IF (l_debug = 'Y') THEN
       okc_debug.log('7800: Leaving lock_row', 2);
       okc_debug.Reset_Indentation;
    END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('7900: Exiting lock_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('8000: Exiting lock_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('8100: Exiting lock_row:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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
  ---------------------------------
  -- lock_row for:OKC_CONTACTS_V --
  ---------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ctcv_rec                     IN ctcv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_ctc_rec                      ctc_rec_type;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_CTC_PVT');
       okc_debug.log('8200: Entered lock_row', 2);
    END IF;

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
    migrate(p_ctcv_rec, l_ctc_rec);
    --------------------------------------------
    -- Call the LOCK_ROW for each child record
    --------------------------------------------
    lock_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_ctc_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);

    IF (l_debug = 'Y') THEN
       okc_debug.log('8300: Leaving lock_row', 2);
       okc_debug.Reset_Indentation;
    END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('8400: Exiting lock_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('8500: Exiting lock_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('8600: Exiting lock_row:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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
  -- PL/SQL TBL lock_row for:CTCV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ctcv_tbl                     IN ctcv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_CTC_PVT');
       okc_debug.log('8700: Entered lock_row', 2);
    END IF;

    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_ctcv_tbl.COUNT > 0) THEN
      i := p_ctcv_tbl.FIRST;
      LOOP
        lock_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_ctcv_rec                     => p_ctcv_tbl(i));
        EXIT WHEN (i = p_ctcv_tbl.LAST);
        i := p_ctcv_tbl.NEXT(i);
      END LOOP;
    END IF;

    IF (l_debug = 'Y') THEN
       okc_debug.log('8800: Leaving lock_row', 2);
       okc_debug.Reset_Indentation;
    END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('8900: Exiting lock_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('9000: Exiting lock_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('9100: Exiting lock_row:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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
  ---------------------------------
  -- update_row for:OKC_CONTACTS --
  ---------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ctc_rec                      IN ctc_rec_type,
    x_ctc_rec                      OUT NOCOPY ctc_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'CONTACTS_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_ctc_rec                      ctc_rec_type := p_ctc_rec;
    l_def_ctc_rec                  ctc_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;

/*added for bug 6882512*/

     l_ste_code                     VARCHAR2(30);

 	     CURSOR get_k_status(p_chr_id IN NUMBER) IS
 	            SELECT ste_code
 	            FROM okc_k_headers_all_b KH,okc_statuses_b STB
 	            WHERE KH.sts_code = STB.code
 	        AND id= p_chr_id;

/*added for bug 6882512*/
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_ctc_rec	IN ctc_rec_type,
      x_ctc_rec	OUT NOCOPY ctc_rec_type
    ) RETURN VARCHAR2 IS
      l_ctc_rec                      ctc_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_CTC_PVT');
       okc_debug.log('9200: Entered populate_new_record', 2);
    END IF;

      x_ctc_rec := p_ctc_rec;
      -- Get current database values
      l_ctc_rec := get_rec(p_ctc_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_ctc_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_ctc_rec.id := l_ctc_rec.id;
      END IF;
      IF (x_ctc_rec.cpl_id = OKC_API.G_MISS_NUM)
      THEN
        x_ctc_rec.cpl_id := l_ctc_rec.cpl_id;
      END IF;
      IF (x_ctc_rec.cro_code = OKC_API.G_MISS_CHAR)
      THEN
        x_ctc_rec.cro_code := l_ctc_rec.cro_code;
      END IF;
      IF (x_ctc_rec.dnz_chr_id = OKC_API.G_MISS_NUM)
      THEN
        x_ctc_rec.dnz_chr_id := l_ctc_rec.dnz_chr_id;
      END IF;
      IF (x_ctc_rec.object1_id1 = OKC_API.G_MISS_CHAR)
      THEN
        x_ctc_rec.object1_id1 := l_ctc_rec.object1_id1;
      END IF;
      IF (x_ctc_rec.object1_id2 = OKC_API.G_MISS_CHAR)
      THEN
        x_ctc_rec.object1_id2 := l_ctc_rec.object1_id2;
      END IF;
      IF (x_ctc_rec.jtot_object1_code = OKC_API.G_MISS_CHAR)
      THEN
        x_ctc_rec.JTOT_OBJECT1_CODE := l_ctc_rec.JTOT_OBJECT1_CODE;
      END IF;
      IF (x_ctc_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_ctc_rec.object_version_number := l_ctc_rec.object_version_number;
      END IF;
      IF (x_ctc_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_ctc_rec.created_by := l_ctc_rec.created_by;
      END IF;
      IF (x_ctc_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_ctc_rec.creation_date := l_ctc_rec.creation_date;
      END IF;
      IF (x_ctc_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_ctc_rec.last_updated_by := l_ctc_rec.last_updated_by;
      END IF;
      IF (x_ctc_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_ctc_rec.last_update_date := l_ctc_rec.last_update_date;
      END IF;
      IF (x_ctc_rec.contact_sequence = OKC_API.G_MISS_NUM)
      THEN
        x_ctc_rec.contact_sequence := l_ctc_rec.contact_sequence;
      END IF;
      IF (x_ctc_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_ctc_rec.last_update_login := l_ctc_rec.last_update_login;
      END IF;
      IF (x_ctc_rec.primary_yn = OKC_API.G_MISS_CHAR)
	 THEN
	   x_ctc_rec.primary_yn := l_ctc_rec.primary_yn;
      END IF;
	 --
      IF (x_ctc_rec.resource_class = OKC_API.G_MISS_CHAR)
      THEN
	   x_ctc_rec.resource_class := l_ctc_rec.resource_class;
      END IF;
	 --
	 IF (x_ctc_rec.SALES_GROUP_ID = OKC_API.G_MISS_NUM)
	 THEN
	     x_ctc_rec.SALES_GROUP_ID :=l_ctc_rec.SALES_GROUP_ID;
      END IF;
	 --
      IF (x_ctc_rec.attribute_category = OKC_API.G_MISS_CHAR)
      THEN
        x_ctc_rec.attribute_category := l_ctc_rec.attribute_category;
      END IF;
      IF (x_ctc_rec.attribute1 = OKC_API.G_MISS_CHAR)
      THEN
        x_ctc_rec.attribute1 := l_ctc_rec.attribute1;
      END IF;
      IF (x_ctc_rec.attribute2 = OKC_API.G_MISS_CHAR)
      THEN
        x_ctc_rec.attribute2 := l_ctc_rec.attribute2;
      END IF;
      IF (x_ctc_rec.attribute3 = OKC_API.G_MISS_CHAR)
      THEN
        x_ctc_rec.attribute3 := l_ctc_rec.attribute3;
      END IF;
      IF (x_ctc_rec.attribute4 = OKC_API.G_MISS_CHAR)
      THEN
        x_ctc_rec.attribute4 := l_ctc_rec.attribute4;
      END IF;
      IF (x_ctc_rec.attribute5 = OKC_API.G_MISS_CHAR)
      THEN
        x_ctc_rec.attribute5 := l_ctc_rec.attribute5;
      END IF;
      IF (x_ctc_rec.attribute6 = OKC_API.G_MISS_CHAR)
      THEN
        x_ctc_rec.attribute6 := l_ctc_rec.attribute6;
      END IF;
      IF (x_ctc_rec.attribute7 = OKC_API.G_MISS_CHAR)
      THEN
        x_ctc_rec.attribute7 := l_ctc_rec.attribute7;
      END IF;
      IF (x_ctc_rec.attribute8 = OKC_API.G_MISS_CHAR)
      THEN
        x_ctc_rec.attribute8 := l_ctc_rec.attribute8;
      END IF;
      IF (x_ctc_rec.attribute9 = OKC_API.G_MISS_CHAR)
      THEN
        x_ctc_rec.attribute9 := l_ctc_rec.attribute9;
      END IF;
      IF (x_ctc_rec.attribute10 = OKC_API.G_MISS_CHAR)
      THEN
        x_ctc_rec.attribute10 := l_ctc_rec.attribute10;
      END IF;
      IF (x_ctc_rec.attribute11 = OKC_API.G_MISS_CHAR)
      THEN
        x_ctc_rec.attribute11 := l_ctc_rec.attribute11;
      END IF;
      IF (x_ctc_rec.attribute12 = OKC_API.G_MISS_CHAR)
      THEN
        x_ctc_rec.attribute12 := l_ctc_rec.attribute12;
      END IF;
      IF (x_ctc_rec.attribute13 = OKC_API.G_MISS_CHAR)
      THEN
        x_ctc_rec.attribute13 := l_ctc_rec.attribute13;
      END IF;
      IF (x_ctc_rec.attribute14 = OKC_API.G_MISS_CHAR)
      THEN
        x_ctc_rec.attribute14 := l_ctc_rec.attribute14;
      END IF;
      IF (x_ctc_rec.attribute15 = OKC_API.G_MISS_CHAR)
      THEN
        x_ctc_rec.attribute15 := l_ctc_rec.attribute15;
      END IF;

      IF (x_ctc_rec.start_date = OKC_API.G_MISS_DATE)
      THEN
        x_ctc_rec.start_date := l_ctc_rec.start_date;
      END IF;

         IF (x_ctc_rec.end_date = OKC_API.G_MISS_DATE)
      THEN
        x_ctc_rec.end_date := l_ctc_rec.end_date;
      END IF;

    IF (l_debug = 'Y') THEN
       okc_debug.log('9250: Leaving populate_new_record ', 2);
       okc_debug.Reset_Indentation;
    END IF;

      RETURN(l_return_status);

    END populate_new_record;
    -------------------------------------
    -- Set_Attributes for:OKC_CONTACTS --
    -------------------------------------
    FUNCTION Set_Attributes (
      p_ctc_rec IN  ctc_rec_type,
      x_ctc_rec OUT NOCOPY ctc_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN

      x_ctc_rec := p_ctc_rec;

      RETURN(l_return_status);

    END Set_Attributes;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_CTC_PVT');
       okc_debug.log('9400: Entered update_row', 2);
    END IF;

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
      p_ctc_rec,                         -- IN
      l_ctc_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_ctc_rec, l_def_ctc_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
/*bugfix for 6882512*/
 	     OPEN get_k_status(l_def_ctc_rec.dnz_chr_id);
 	     FETCH get_k_status INTO l_ste_code;
 	     CLOSE get_k_status;
/*bugfix for 6882512*/
    UPDATE  OKC_CONTACTS
    SET CPL_ID = l_def_ctc_rec.cpl_id,
        CRO_CODE = l_def_ctc_rec.cro_code,
        DNZ_CHR_ID = l_def_ctc_rec.dnz_chr_id,
        OBJECT1_ID1 = l_def_ctc_rec.object1_id1,
        OBJECT1_ID2 = l_def_ctc_rec.object1_id2,
        JTOT_OBJECT1_CODE = l_def_ctc_rec.JTOT_OBJECT1_CODE,
        OBJECT_VERSION_NUMBER = l_def_ctc_rec.object_version_number,
        CREATED_BY = l_def_ctc_rec.created_by,
        CREATION_DATE = l_def_ctc_rec.creation_date,
        LAST_UPDATED_BY = l_def_ctc_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_ctc_rec.last_update_date,
        CONTACT_SEQUENCE = l_def_ctc_rec.contact_sequence,
        LAST_UPDATE_LOGIN = l_def_ctc_rec.last_update_login,
        PRIMARY_YN        = l_def_ctc_rec.primary_yn,
	   RESOURCE_CLASS    = l_def_ctc_rec.RESOURCE_CLASS,
	   SALES_GROUP_ID    = l_def_ctc_rec.SALES_GROUP_ID,
        ATTRIBUTE_CATEGORY = l_def_ctc_rec.attribute_category,
        ATTRIBUTE1 = l_def_ctc_rec.attribute1,
        ATTRIBUTE2 = l_def_ctc_rec.attribute2,
        ATTRIBUTE3 = l_def_ctc_rec.attribute3,
        ATTRIBUTE4 = l_def_ctc_rec.attribute4,
        ATTRIBUTE5 = l_def_ctc_rec.attribute5,
        ATTRIBUTE6 = l_def_ctc_rec.attribute6,
        ATTRIBUTE7 = l_def_ctc_rec.attribute7,
        ATTRIBUTE8 = l_def_ctc_rec.attribute8,
        ATTRIBUTE9 = l_def_ctc_rec.attribute9,
        ATTRIBUTE10 = l_def_ctc_rec.attribute10,
        ATTRIBUTE11 = l_def_ctc_rec.attribute11,
        ATTRIBUTE12 = l_def_ctc_rec.attribute12,
        ATTRIBUTE13 = l_def_ctc_rec.attribute13,
        ATTRIBUTE14 = l_def_ctc_rec.attribute14,
        ATTRIBUTE15 = l_def_ctc_rec.attribute15,
        START_DATE = l_def_ctc_rec.start_date,
        END_DATE   = l_def_ctc_rec.end_date,
        DNZ_STE_CODE = l_ste_code
    WHERE ID = l_def_ctc_rec.id;

    x_ctc_rec := l_def_ctc_rec;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);

    IF (l_debug = 'Y') THEN
       okc_debug.log('9500: Leaving update_row', 2);
       okc_debug.Reset_Indentation;
    END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('9600: Exiting update_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('9700: Exiting update_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('9800: Exiting update_row:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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
  -----------------------------------
  -- update_row for:OKC_CONTACTS_V --
  -----------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ctcv_rec                     IN ctcv_rec_type,
    x_ctcv_rec                     OUT NOCOPY ctcv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_ctcv_rec                     ctcv_rec_type := p_ctcv_rec;
    l_def_ctcv_rec                 ctcv_rec_type;
    l_ctc_rec                      ctc_rec_type;
    lx_ctc_rec                     ctc_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_ctcv_rec	IN ctcv_rec_type
    ) RETURN ctcv_rec_type IS
      l_ctcv_rec	ctcv_rec_type := p_ctcv_rec;
    BEGIN

      l_ctcv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_ctcv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_ctcv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;

      RETURN(l_ctcv_rec);

    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_ctcv_rec	IN ctcv_rec_type,
      x_ctcv_rec	OUT NOCOPY ctcv_rec_type
    ) RETURN VARCHAR2 IS
      l_ctcv_rec                     ctcv_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_CTC_PVT');
       okc_debug.log('10000: Entered populate_new_record', 2);
    END IF;

      x_ctcv_rec := p_ctcv_rec;
      -- Get current database values
      l_ctcv_rec := get_rec(p_ctcv_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_ctcv_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_ctcv_rec.id := l_ctcv_rec.id;
      END IF;
      IF (x_ctcv_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_ctcv_rec.object_version_number := l_ctcv_rec.object_version_number;
      END IF;
      IF (x_ctcv_rec.cpl_id = OKC_API.G_MISS_NUM)
      THEN
        x_ctcv_rec.cpl_id := l_ctcv_rec.cpl_id;
      END IF;
      IF (x_ctcv_rec.cro_code = OKC_API.G_MISS_CHAR)
      THEN
        x_ctcv_rec.cro_code := l_ctcv_rec.cro_code;
      END IF;
      IF (x_ctcv_rec.dnz_chr_id = OKC_API.G_MISS_NUM)
      THEN
        x_ctcv_rec.dnz_chr_id := l_ctcv_rec.dnz_chr_id;
      END IF;
      IF (x_ctcv_rec.contact_sequence = OKC_API.G_MISS_NUM)
      THEN
        x_ctcv_rec.contact_sequence := l_ctcv_rec.contact_sequence;
      END IF;
      IF (x_ctcv_rec.object1_id1 = OKC_API.G_MISS_CHAR)
      THEN
        x_ctcv_rec.object1_id1 := l_ctcv_rec.object1_id1;
      END IF;
      IF (x_ctcv_rec.object1_id2 = OKC_API.G_MISS_CHAR)
      THEN
        x_ctcv_rec.object1_id2 := l_ctcv_rec.object1_id2;
      END IF;
      IF (x_ctcv_rec.jtot_object1_code = OKC_API.G_MISS_CHAR)
      THEN
        x_ctcv_rec.JTOT_OBJECT1_CODE := l_ctcv_rec.JTOT_OBJECT1_CODE;
      END IF;
      IF (x_ctcv_rec.primary_yn = OKC_API.G_MISS_CHAR)
      THEN
	   x_ctcv_rec.PRIMARY_YN := l_ctcv_rec.PRIMARY_YN;
      END IF;
      IF (x_ctcv_rec.RESOURCE_CLASS= OKC_API.G_MISS_CHAR)
      THEN
        x_ctcv_rec.RESOURCE_CLASS := l_ctcv_rec.RESOURCE_CLASS;
      END IF;
	 --
      IF (x_ctcv_rec.SALES_GROUP_ID =  OKC_API.G_MISS_NUM) THEN
          x_ctcv_rec.SALES_GROUP_ID := l_ctcv_rec.SALES_GROUP_ID;
      END IF;
      --
      IF (x_ctcv_rec.attribute_category = OKC_API.G_MISS_CHAR)
      THEN
        x_ctcv_rec.attribute_category := l_ctcv_rec.attribute_category;
      END IF;
      IF (x_ctcv_rec.attribute1 = OKC_API.G_MISS_CHAR)
      THEN
        x_ctcv_rec.attribute1 := l_ctcv_rec.attribute1;
      END IF;
      IF (x_ctcv_rec.attribute2 = OKC_API.G_MISS_CHAR)
      THEN
        x_ctcv_rec.attribute2 := l_ctcv_rec.attribute2;
      END IF;
      IF (x_ctcv_rec.attribute3 = OKC_API.G_MISS_CHAR)
      THEN
        x_ctcv_rec.attribute3 := l_ctcv_rec.attribute3;
      END IF;
      IF (x_ctcv_rec.attribute4 = OKC_API.G_MISS_CHAR)
      THEN
        x_ctcv_rec.attribute4 := l_ctcv_rec.attribute4;
      END IF;
      IF (x_ctcv_rec.attribute5 = OKC_API.G_MISS_CHAR)
      THEN
        x_ctcv_rec.attribute5 := l_ctcv_rec.attribute5;
      END IF;
      IF (x_ctcv_rec.attribute6 = OKC_API.G_MISS_CHAR)
      THEN
        x_ctcv_rec.attribute6 := l_ctcv_rec.attribute6;
      END IF;
      IF (x_ctcv_rec.attribute7 = OKC_API.G_MISS_CHAR)
      THEN
        x_ctcv_rec.attribute7 := l_ctcv_rec.attribute7;
      END IF;
      IF (x_ctcv_rec.attribute8 = OKC_API.G_MISS_CHAR)
      THEN
        x_ctcv_rec.attribute8 := l_ctcv_rec.attribute8;
      END IF;
      IF (x_ctcv_rec.attribute9 = OKC_API.G_MISS_CHAR)
      THEN
        x_ctcv_rec.attribute9 := l_ctcv_rec.attribute9;
      END IF;
      IF (x_ctcv_rec.attribute10 = OKC_API.G_MISS_CHAR)
      THEN
        x_ctcv_rec.attribute10 := l_ctcv_rec.attribute10;
      END IF;
      IF (x_ctcv_rec.attribute11 = OKC_API.G_MISS_CHAR)
      THEN
        x_ctcv_rec.attribute11 := l_ctcv_rec.attribute11;
      END IF;
      IF (x_ctcv_rec.attribute12 = OKC_API.G_MISS_CHAR)
      THEN
        x_ctcv_rec.attribute12 := l_ctcv_rec.attribute12;
      END IF;
      IF (x_ctcv_rec.attribute13 = OKC_API.G_MISS_CHAR)
      THEN
        x_ctcv_rec.attribute13 := l_ctcv_rec.attribute13;
      END IF;
      IF (x_ctcv_rec.attribute14 = OKC_API.G_MISS_CHAR)
      THEN
        x_ctcv_rec.attribute14 := l_ctcv_rec.attribute14;
      END IF;
      IF (x_ctcv_rec.attribute15 = OKC_API.G_MISS_CHAR)
      THEN
        x_ctcv_rec.attribute15 := l_ctcv_rec.attribute15;
      END IF;
      IF (x_ctcv_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_ctcv_rec.created_by := l_ctcv_rec.created_by;
      END IF;
      IF (x_ctcv_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_ctcv_rec.creation_date := l_ctcv_rec.creation_date;
      END IF;
      IF (x_ctcv_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_ctcv_rec.last_updated_by := l_ctcv_rec.last_updated_by;
      END IF;
      IF (x_ctcv_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_ctcv_rec.last_update_date := l_ctcv_rec.last_update_date;
      END IF;
      IF (x_ctcv_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_ctcv_rec.last_update_login := l_ctcv_rec.last_update_login;
      END IF;
      IF (x_ctcv_rec.start_date = OKC_API.G_MISS_DATE)
      THEN
        x_ctcv_rec.start_date := l_ctcv_rec.start_date;
      END IF;
      IF (x_ctcv_rec.end_date = OKC_API.G_MISS_DATE)
      THEN
        x_ctcv_rec.end_date := l_ctcv_rec.end_date;
      END IF;

    IF (l_debug = 'Y') THEN
       okc_debug.log('10050: Leaving populate_new_record ', 2);
       okc_debug.Reset_Indentation;
    END IF;

      RETURN(l_return_status);

    END populate_new_record;
    ---------------------------------------
    -- Set_Attributes for:OKC_CONTACTS_V --
    ---------------------------------------
    FUNCTION Set_Attributes (
      p_ctcv_rec IN  ctcv_rec_type,
      x_ctcv_rec OUT NOCOPY ctcv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN

      x_ctcv_rec := p_ctcv_rec;
      x_ctcv_rec.OBJECT_VERSION_NUMBER := NVL(x_ctcv_rec.OBJECT_VERSION_NUMBER, 0) + 1;

      RETURN(l_return_status);

    END Set_Attributes;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_CTC_PVT');
       okc_debug.log('10200: Entered update_row', 2);
    END IF;

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
      p_ctcv_rec,                        -- IN
      l_ctcv_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_ctcv_rec, l_def_ctcv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_ctcv_rec := fill_who_columns(l_def_ctcv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_ctcv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_ctcv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_ctcv_rec, l_ctc_rec);
    --------------------------------------------
    -- Call the UPDATE_ROW for each child record
    --------------------------------------------
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_ctc_rec,
      lx_ctc_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_ctc_rec, l_def_ctcv_rec);
    x_ctcv_rec := l_def_ctcv_rec;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);

    IF (l_debug = 'Y') THEN
       okc_debug.log('10300: Leaving update_row', 2);
       okc_debug.Reset_Indentation;
    END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('10400: Exiting update_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('10500: Exiting update_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('10600: Exiting update_row:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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
  -- PL/SQL TBL update_row for:CTCV_TBL --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ctcv_tbl                     IN ctcv_tbl_type,
    x_ctcv_tbl                     OUT NOCOPY ctcv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_CTC_PVT');
       okc_debug.log('10700: Entered update_row', 2);
    END IF;

    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_ctcv_tbl.COUNT > 0) THEN
      i := p_ctcv_tbl.FIRST;
      LOOP
        update_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_ctcv_rec                     => p_ctcv_tbl(i),
          x_ctcv_rec                     => x_ctcv_tbl(i));
        EXIT WHEN (i = p_ctcv_tbl.LAST);
        i := p_ctcv_tbl.NEXT(i);
      END LOOP;
    END IF;

    IF (l_debug = 'Y') THEN
       okc_debug.log('10800: Leaving update_row', 2);
       okc_debug.Reset_Indentation;
    END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('10900: Exiting update_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('11000: Exiting update_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('11100: Exiting update_row:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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
  ---------------------------------
  -- delete_row for:OKC_CONTACTS --
  ---------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ctc_rec                      IN ctc_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'CONTACTS_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_ctc_rec                      ctc_rec_type:= p_ctc_rec;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_CTC_PVT');
       okc_debug.log('11200: Entered delete_row', 2);
    END IF;

    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    DELETE FROM OKC_CONTACTS
     WHERE ID = l_ctc_rec.id;

    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);

    IF (l_debug = 'Y') THEN
       okc_debug.log('11300: Leaving delete_row', 2);
       okc_debug.Reset_Indentation;
    END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('11400: Exiting delete_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('11500: Exiting delete_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('11600: Exiting delete_row:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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
  -----------------------------------
  -- delete_row for:OKC_CONTACTS_V --
  -----------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ctcv_rec                     IN ctcv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_ctcv_rec                     ctcv_rec_type := p_ctcv_rec;
    l_ctc_rec                      ctc_rec_type;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_CTC_PVT');
       okc_debug.log('11700: Entered delete_row', 2);
    END IF;

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
    migrate(l_ctcv_rec, l_ctc_rec);
    --------------------------------------------
    -- Call the DELETE_ROW for each child record
    --------------------------------------------
    delete_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_ctc_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);

    IF (l_debug = 'Y') THEN
       okc_debug.log('11800: Leaving delete_row', 2);
       okc_debug.Reset_Indentation;
    END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('11900: Exiting delete_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('12000: Exiting delete_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('12100: Exiting delete_row:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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
  -- PL/SQL TBL delete_row for:CTCV_TBL --
  ----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ctcv_tbl                     IN ctcv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_CTC_PVT');
       okc_debug.log('12200: Entered delete_row', 2);
    END IF;

    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_ctcv_tbl.COUNT > 0) THEN
      i := p_ctcv_tbl.FIRST;
      LOOP
        delete_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_ctcv_rec                     => p_ctcv_tbl(i));
        EXIT WHEN (i = p_ctcv_tbl.LAST);
        i := p_ctcv_tbl.NEXT(i);
      END LOOP;
    END IF;

 IF (l_debug = 'Y') THEN
    okc_debug.log('12300: Exiting delete_row', 2);
    okc_debug.Reset_Indentation;
 END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('12400: Exiting delete_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('12500: Exiting delete_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('12600: Exiting delete_row:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

---------------------------------------------------------------
-- Procedure for mass insert in OKC_CONTACTS _B and TL tables
---------------------------------------------------------------
PROCEDURE INSERT_ROW_UPG(x_return_status OUT NOCOPY VARCHAR2,p_ctcv_tbl ctcv_tbl_type) IS
  l_tabsize NUMBER := p_ctcv_tbl.COUNT;
  l_source_lang VARCHAR2(12) := okc_util.get_userenv_lang;
  l_ste_code VARCHAR2(30);/*added for bug 6882512*/
  in_id                            OKC_DATATYPES.NumberTabTyp;
  in_object_version_number         OKC_DATATYPES.NumberTabTyp;
  in_cpl_id                        OKC_DATATYPES.NumberTabTyp;
  in_cro_code                      OKC_DATATYPES.Var30TabTyp;
  in_dnz_chr_id                    OKC_DATATYPES.NumberTabTyp;
  in_contact_sequence              OKC_DATATYPES.NumberTabTyp;
  in_object1_id1                   OKC_DATATYPES.Var40TabTyp;
  in_object1_id2                   OKC_DATATYPES.Var200TabTyp;
  in_jtot_object1_code             OKC_DATATYPES.Var30TabTyp;
  in_primary_yn                    OKC_DATATYPES.Var3TabTyp;
  in_resource_class                OKC_DATATYPES.Var30TabTyp;
  in_SALES_GROUP_ID                OKC_DATATYPES.NumberTabTyp;
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
  in_start_date                    OKC_DATATYPES.DateTabTyp;
  in_end_date                      OKC_DATATYPES.DateTabTyp;
  in_dnz_ste_code                  OKC_DATATYPES.Var30TabTyp;
  i number;
  j number;
/*added for bug 6882512*/
 CURSOR get_k_status(p_chr_id IN NUMBER) IS
 	         SELECT ste_code
 	         FROM okc_k_headers_all_b KH,okc_statuses_b STB
 	         WHERE KH.sts_code = STB.code
 	       AND id= p_chr_id;
/*added for bug 6882512*/

BEGIN
 -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_CTC_PVT');
       okc_debug.log('12700: Entered INSERT_ROW_UPG', 2);
    END IF;

  i := p_ctcv_tbl.FIRST; j:=0;
  while i is not null
  LOOP
    j:=j+1;
    in_id                       (j) := p_ctcv_tbl(i).id;
    in_object_version_number    (j) := p_ctcv_tbl(i).object_version_number;
    in_cpl_id                   (j) := p_ctcv_tbl(i).cpl_id;
    in_cro_code                 (j) := p_ctcv_tbl(i).cro_code;
    in_dnz_chr_id               (j) := p_ctcv_tbl(i).dnz_chr_id;
    in_contact_sequence         (j) := p_ctcv_tbl(i).contact_sequence;
    in_object1_id1              (j) := p_ctcv_tbl(i).object1_id1;
    in_object1_id2              (j) := p_ctcv_tbl(i).object1_id2;
    in_jtot_object1_code        (j) := p_ctcv_tbl(i).jtot_object1_code;
    in_primary_yn               (j) := p_ctcv_tbl(i).primary_yn;
    in_resource_class           (j) := p_ctcv_tbl(i).resource_class;
    in_SALES_GROUP_ID           (j) := p_ctcv_tbl(i).SALES_GROUP_ID;
    in_attribute_category       (j) := p_ctcv_tbl(i).attribute_category;
    in_attribute1               (j) := p_ctcv_tbl(i).attribute1;
    in_attribute2               (j) := p_ctcv_tbl(i).attribute2;
    in_attribute3               (j) := p_ctcv_tbl(i).attribute3;
    in_attribute4               (j) := p_ctcv_tbl(i).attribute4;
    in_attribute5               (j) := p_ctcv_tbl(i).attribute5;
    in_attribute6               (j) := p_ctcv_tbl(i).attribute6;
    in_attribute7               (j) := p_ctcv_tbl(i).attribute7;
    in_attribute8               (j) := p_ctcv_tbl(i).attribute8;
    in_attribute9               (j) := p_ctcv_tbl(i).attribute9;
    in_attribute10              (j) := p_ctcv_tbl(i).attribute10;
    in_attribute11              (j) := p_ctcv_tbl(i).attribute11;
    in_attribute12              (j) := p_ctcv_tbl(i).attribute12;
    in_attribute13              (j) := p_ctcv_tbl(i).attribute13;
    in_attribute14              (j) := p_ctcv_tbl(i).attribute14;
    in_attribute15              (j) := p_ctcv_tbl(i).attribute15;
    in_created_by               (j) := p_ctcv_tbl(i).created_by;
    in_creation_date            (j) := p_ctcv_tbl(i).creation_date;
    in_last_updated_by          (j) := p_ctcv_tbl(i).last_updated_by;
    in_last_update_date         (j) := p_ctcv_tbl(i).last_update_date;
    in_last_update_login        (j) := p_ctcv_tbl(i).last_update_login;
    in_start_date               (j) := p_ctcv_tbl(i).start_date;
    in_end_date                 (j) := p_ctcv_tbl(i).end_date;
/*Bugfix for 6882512*/
 	     /*Making sure that the previous ste_code doesnt get copied*/
 	     l_ste_code  := NULL;

 	     OPEN get_k_status(in_dnz_chr_id(j));
 	     FETCH get_k_status INTO l_ste_code;
 	     CLOSE get_k_status;
 	     in_dnz_ste_code             (j) := l_ste_code;

 /*Bugfix for 6882512*/
    i:=p_ctcv_tbl.next(i);
  END LOOP;

  FORALL i in 1..l_tabsize
    INSERT
      INTO OKC_CONTACTS
      (
        id,
        cpl_id,
        cro_code,
        dnz_chr_id,
        object1_id1,
        object1_id2,
        jtot_object1_code,
        object_version_number,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        contact_sequence,
        last_update_login,
	   primary_yn,
	   resource_class,
	   SALES_GROUP_ID,
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
        attribute15,
        start_date,
        end_date,
        dnz_ste_code

     )
     VALUES (
        in_id(i),
        in_cpl_id(i),
        in_cro_code(i),
        in_dnz_chr_id(i),
        in_object1_id1(i),
        in_object1_id2(i),
        in_jtot_object1_code(i),
        in_object_version_number(i),
        in_created_by(i),
        in_creation_date(i),
        in_last_updated_by(i),
        in_last_update_date(i),
        in_contact_sequence(i),
        in_last_update_login(i),
	   in_primary_yn(i),
	   in_resource_class(i),
	   in_SALES_GROUP_ID(i),
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
        in_start_date(i),
        in_end_date(i),
        in_dnz_ste_code(i)
     );

   IF (l_debug = 'Y') THEN
      okc_debug.log('12800: Leaving INSERT_ROW_UPG', 2);
      okc_debug.Reset_Indentation;
   END IF;

EXCEPTION
  WHEN OTHERS THEN
     -- store SQL error message on message stack
     OKC_API.SET_MESSAGE(
        p_app_name        => G_APP_NAME,
        p_msg_name        => G_UNEXPECTED_ERROR,
        p_token1          => G_SQLCODE_TOKEN,
        p_token1_value    => SQLCODE,
        p_token2          => G_SQLERRM_TOKEN,
        p_token2_value    => SQLERRM);
     -- notify caller of an error as UNEXPECTED error
        x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;


    /*okc_debug.log('12900: Exiting INSERT_ROW_UPG:OTHERS Exception', 2);
    IF (l_debug = 'Y') THEN
       okc_debug.Reset_Indentation;
    END IF;

    RAISE*/

END INSERT_ROW_UPG;


--This function is called from versioning API OKC_VERSION_PVT
--Old Location: OKCRVERB.pls
--New Location: Base Table API

FUNCTION create_version(
             p_chr_id         IN NUMBER,
             p_major_version  IN NUMBER
           ) RETURN VARCHAR2 IS

  l_return_status VARCHAR2(1):= OKC_API.G_RET_STS_SUCCESS;

BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_CTC_PVT');
       okc_debug.log('13000: Entered create_version', 2);
    END IF;

INSERT INTO okc_contacts_h
  (
      major_version,
      id,
      cpl_id,
      cro_code,
      dnz_chr_id,
      object1_id1,
      object1_id2,
      jtot_object1_code,
      object_version_number,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      contact_sequence,
      last_update_login,
	 primary_yn,
	 resource_class,
	 SALES_GROUP_ID,
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
      attribute15,
      start_date,
      end_date
)
  SELECT
      p_major_version,
      id,
      cpl_id,
      cro_code,
      dnz_chr_id,
      object1_id1,
      object1_id2,
      jtot_object1_code,
      object_version_number,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      contact_sequence,
      last_update_login,
	 primary_yn,
	 resource_class,
	 SALES_GROUP_ID,
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
      attribute15,
      start_date,
      end_date
  FROM okc_contacts
 WHERE dnz_chr_id = p_chr_id;

 IF (l_debug = 'Y') THEN
    okc_debug.log('13100: Exiting create_version', 2);
    okc_debug.Reset_Indentation;
 END IF;

RETURN l_return_status;

  EXCEPTION
       -- other appropriate handlers
    WHEN OTHERS THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('13200: Exiting create_version:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

       -- store SQL error message on message stack
             OKC_API.SET_MESSAGE(p_app_name     => okc_version_pvt.G_APP_NAME,
                                 p_msg_name     => okc_version_pvt.G_UNEXPECTED_ERROR,
                                 p_token1       => okc_version_pvt.G_SQLCODE_TOKEN,
                                 p_token1_value => sqlcode,
                                 p_token2       => okc_version_pvt.G_SQLERRM_TOKEN,
                                 p_token2_value => sqlerrm);

       -- notify  UNEXPECTED error
             l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
             return l_return_status;

END create_version;

--This Function is called from Versioning API OKC_VERSION_PVT
--Old Location:OKCRVERB.pls
--New Location:Base Table API

FUNCTION restore_version(
             p_chr_id         IN NUMBER,
             p_major_version  IN NUMBER
           ) RETURN VARCHAR2 IS

  l_return_status VARCHAR2(1):= OKC_API.G_RET_STS_SUCCESS;

BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_CTC_PVT');
       okc_debug.log('13300: Entered restore_version', 2);
    END IF;

INSERT INTO okc_contacts
  (
      id,
      cpl_id,
      cro_code,
      dnz_chr_id,
      object1_id1,
      object1_id2,
      jtot_object1_code,
      object_version_number,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      contact_sequence,
      last_update_login,
	 primary_yn,
	 resource_class,
	 SALES_GROUP_ID,
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
      attribute15,
      start_date,
      end_date
)
  SELECT
      id,
      cpl_id,
      cro_code,
      dnz_chr_id,
      object1_id1,
      object1_id2,
      jtot_object1_code,
      object_version_number,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      contact_sequence,
      last_update_login,
	 primary_yn,
	 resource_class,
	 SALES_GROUP_ID,
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
      attribute15,
      start_date,
      end_date
  FROM okc_contacts_h
WHERE dnz_chr_id = p_chr_id
  AND major_version = p_major_version;

/* Bug fix for 6882512*/
 	 OKC_CTC_PVT.update_contact_stecode(p_chr_id => p_chr_id,
 	                            x_return_status=>l_return_status);

 	 IF l_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
 	     RAISE OKC_API.G_EXCEPTION_ERROR;
 	 END IF;
/* Bug fix for 6882512*/

 IF (l_debug = 'Y') THEN
    okc_debug.log('13400: Exiting restore_version', 2);
    okc_debug.Reset_Indentation;
 END IF;

RETURN l_return_status;

  EXCEPTION
       -- other appropriate handlers
    WHEN OTHERS THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('13500: Exiting restore_version:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

       -- store SQL error message on message stack
             OKC_API.SET_MESSAGE(p_app_name     => okc_version_pvt.G_APP_NAME,
                                 p_msg_name     => okc_version_pvt.G_UNEXPECTED_ERROR,
                                 p_token1       => okc_version_pvt.G_SQLCODE_TOKEN,
                                 p_token1_value => sqlcode,
                                 p_token2       => okc_version_pvt.G_SQLERRM_TOKEN,
                                 p_token2_value => sqlerrm);

       -- notify  UNEXPECTED error
             l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
             return l_return_status;

END restore_version;

END OKC_CTC_PVT;

/
