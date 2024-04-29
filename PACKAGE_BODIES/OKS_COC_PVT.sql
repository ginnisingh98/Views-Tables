--------------------------------------------------------
--  DDL for Package Body OKS_COC_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKS_COC_PVT" AS
/* $Header: OKSRCOCB.pls 120.1 2005/10/05 03:58:18 jvorugan noship $ */
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
  -- FUNCTION get_rec for: OKS_K_ORDER_CONTACTS
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_coc_rec                      IN coc_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN coc_rec_type IS
    CURSOR oks_k_order_contacts_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            COD_ID,
            CRO_CODE,
            OBJECT1_ID1,
            OBJECT1_ID2,
            JTOT_OBJECT_CODE,
            OBJECT_VERSION_NUMBER,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE
      FROM Oks_K_Order_Contacts
     WHERE oks_k_order_contacts.id = p_id;
    l_oks_k_order_contacts_pk      oks_k_order_contacts_pk_csr%ROWTYPE;
    l_coc_rec                      coc_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN oks_k_order_contacts_pk_csr (p_coc_rec.id);
    FETCH oks_k_order_contacts_pk_csr INTO
              l_coc_rec.ID,
              l_coc_rec.COD_ID,
              l_coc_rec.CRO_CODE,
              l_coc_rec.OBJECT1_ID1,
              l_coc_rec.OBJECT1_ID2,
              l_coc_rec.JTOT_OBJECT_CODE,
              l_coc_rec.OBJECT_VERSION_NUMBER,
              l_coc_rec.CREATED_BY,
              l_coc_rec.CREATION_DATE,
              l_coc_rec.LAST_UPDATED_BY,
              l_coc_rec.LAST_UPDATE_DATE;
    x_no_data_found := oks_k_order_contacts_pk_csr%NOTFOUND;
    CLOSE oks_k_order_contacts_pk_csr;
    RETURN(l_coc_rec);
  END get_rec;

  FUNCTION get_rec (
    p_coc_rec                      IN coc_rec_type
  ) RETURN coc_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_coc_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKS_K_ORDER_CONTACTS_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_cocv_rec                     IN cocv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN cocv_rec_type IS
    CURSOR oks_kocv_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            COD_ID,
            CRO_CODE,
            JTOT_OBJECT_CODE,
            OBJECT1_ID1,
            OBJECT1_ID2,
            OBJECT_VERSION_NUMBER,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE
      FROM Oks_K_Order_Contacts_V
     WHERE oks_k_order_contacts_v.id = p_id;
    l_oks_kocv_pk                  oks_kocv_pk_csr%ROWTYPE;
    l_cocv_rec                     cocv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN oks_kocv_pk_csr (p_cocv_rec.id);
    FETCH oks_kocv_pk_csr INTO
              l_cocv_rec.ID,
              l_cocv_rec.COD_ID,
              l_cocv_rec.CRO_CODE,
              l_cocv_rec.JTOT_OBJECT_CODE,
              l_cocv_rec.OBJECT1_ID1,
              l_cocv_rec.OBJECT1_ID2,
              l_cocv_rec.OBJECT_VERSION_NUMBER,
              l_cocv_rec.CREATED_BY,
              l_cocv_rec.CREATION_DATE,
              l_cocv_rec.LAST_UPDATED_BY,
              l_cocv_rec.LAST_UPDATE_DATE;
    x_no_data_found := oks_kocv_pk_csr%NOTFOUND;
    CLOSE oks_kocv_pk_csr;
    RETURN(l_cocv_rec);
  END get_rec;

  FUNCTION get_rec (
    p_cocv_rec                     IN cocv_rec_type
  ) RETURN cocv_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_cocv_rec, l_row_notfound));
  END get_rec;

  ------------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKS_K_ORDER_CONTACTS_V --
  ------------------------------------------------------------
  FUNCTION null_out_defaults (
    p_cocv_rec	IN cocv_rec_type
  ) RETURN cocv_rec_type IS
    l_cocv_rec	cocv_rec_type := p_cocv_rec;
  BEGIN
    IF (l_cocv_rec.cod_id = OKC_API.G_MISS_NUM) THEN
      l_cocv_rec.cod_id := NULL;
    END IF;
    IF (l_cocv_rec.cro_code = OKC_API.G_MISS_CHAR) THEN
      l_cocv_rec.cro_code := NULL;
    END IF;
    IF (l_cocv_rec.jtot_object_code = OKC_API.G_MISS_CHAR) THEN
      l_cocv_rec.jtot_object_code := NULL;
    END IF;
    IF (l_cocv_rec.object1_id1 = OKC_API.G_MISS_CHAR) THEN
      l_cocv_rec.object1_id1 := NULL;
    END IF;
    IF (l_cocv_rec.object1_id2 = OKC_API.G_MISS_CHAR) THEN
      l_cocv_rec.object1_id2 := NULL;
    END IF;
    IF (l_cocv_rec.object_version_number = OKC_API.G_MISS_NUM) THEN
      l_cocv_rec.object_version_number := NULL;
    END IF;
    IF (l_cocv_rec.created_by = OKC_API.G_MISS_NUM) THEN
      l_cocv_rec.created_by := NULL;
    END IF;
    IF (l_cocv_rec.creation_date = OKC_API.G_MISS_DATE) THEN
      l_cocv_rec.creation_date := NULL;
    END IF;
    IF (l_cocv_rec.last_updated_by = OKC_API.G_MISS_NUM) THEN
      l_cocv_rec.last_updated_by := NULL;
    END IF;
    IF (l_cocv_rec.last_update_date = OKC_API.G_MISS_DATE) THEN
      l_cocv_rec.last_update_date := NULL;
    END IF;
    RETURN(l_cocv_rec);
  END null_out_defaults;
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Attributes
  ---------------------------------------------------------------------------
  ----------------------------------------------------
  -- Validate_Attributes for:OKS_K_ORDER_CONTACTS_V --
  ----------------------------------------------------
  -----------------------------------------------------
  -- Validate ID--
  -----------------------------------------------------
  PROCEDURE validate_id(x_return_status OUT NOCOPY varchar2,
				p_cocv_Rec   IN  COCV_REC_TYPE)
  Is
  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
  Begin

  x_return_status := OKC_API.G_RET_STS_SUCCESS;

  If p_cocv_Rec.id = OKC_API.G_MISS_NUM OR
       p_cocv_Rec.id IS NULL
  Then
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'id');
      l_return_status := OKC_API.G_RET_STS_ERROR;
  End If;

  Exception
  When  G_EXCEPTION_HALT_VALIDATION THEN
            x_return_status := l_return_status;
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

  -----------------------------------------------------
  -- Validate Object Version Number --
  -----------------------------------------------------
  PROCEDURE validate_objvernum(x_return_status OUT NOCOPY varchar2,
				p_cocv_Rec   IN  COCV_REC_TYPE)
  Is
  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
  Begin

  x_return_status := OKC_API.G_RET_STS_SUCCESS;

  If p_cocv_Rec.object_version_number = OKC_API.G_MISS_NUM OR
       p_cocv_Rec.object_version_number IS NULL
  Then
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'object_version_number');
      x_return_status := OKC_API.G_RET_STS_ERROR;
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
  -----------------------------------------------------
  -- Validate COD_ID
  -----------------------------------------------------
  PROCEDURE validate_Cod_Id(x_return_status OUT NOCOPY varchar2,
				p_cocv_Rec   IN  COCV_REC_TYPE)
  Is
  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
  l_Count	INTEGER;
  CURSOR Cod_Cur IS
  SELECT Count(1) FROM OKS_K_ORDER_DETAILS_V
  WHERE ID=p_cocv_Rec.Cod_Id;
  Begin
  If p_cocv_Rec.Cod_Id = OKC_API.G_MISS_NUM OR
       p_cocv_Rec.Cod_Id IS NULL
  Then
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'COD_ID');
      x_return_status := OKC_API.G_RET_STS_ERROR;
	RAISE G_EXCEPTION_HALT_VALIDATION;
  End If;

  OPEN Cod_Cur;
  FETCH Cod_Cur INTO l_Count;
  CLOSE Cod_Cur;
  IF NOT l_Count=1
  THEN
          OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'COD_ID');
        x_return_status := OKC_API.G_RET_STS_ERROR;
  RAISE G_EXCEPTION_HALT_VALIDATION;
  END IF;

  x_return_status := OKC_API.G_RET_STS_SUCCESS;

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

  END validate_Cod_Id;

  -----------------------------------------------------
  -- Validate CRO_CODE
  -----------------------------------------------------
  PROCEDURE validate_CRO_CODE(x_return_status OUT NOCOPY varchar2,
				p_cocv_Rec   IN  COCV_REC_TYPE)
  Is
  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
  l_Count	INTEGER;
  CURSOR cro_Cur IS
  SELECT count(1) FROM Okc_Contact_Sources_v ocs,
				   fnd_lookups fl
  WHERE ocs.CRO_CODE=p_cocv_Rec.Cro_Code
  and   ocs.buy_or_sell='S'
  and   fl.lookup_type='OKC_CONTACT_ROLE'
  and   ocs.jtot_object_code='OKX_PCONTACT'
  AND   ocs.Rle_code='CUSTOMER';
  Begin
  If p_cocv_Rec.Cro_code = OKC_API.G_MISS_CHAR OR
       p_cocv_Rec.Cro_Code IS NULL
  Then
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'CRO_CODE');
      x_return_status := OKC_API.G_RET_STS_ERROR;
	RAISE G_EXCEPTION_HALT_VALIDATION;
  End If;
  OPEN Cro_Cur;
  FETCH Cro_Cur INTO l_Count;
  CLOSE Cro_Cur;
  IF NOT l_Count>0
  THEN
      OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'CRO_CODE');
      x_return_status := OKC_API.G_RET_STS_ERROR;
	-- halt further validation of this column
	RAISE G_EXCEPTION_HALT_VALIDATION;
  End If;
  x_return_status := OKC_API.G_RET_STS_SUCCESS;

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
  END validate_CRO_CODE;
  -----------------------------------------------------
  -- Validate JTOT_OBJECT_CODE
  -----------------------------------------------------
-- validate jtot_OBJECT_cODE AND SEGMENT_Id1,Id2
procedure validate_JTOT_OBJECT_CODE(x_return_status OUT	NOCOPY VARCHAR2,
                          p_cocv_rec	  IN	cocv_rec_TYPE) is
l_dummy_var                 varchar2(1) := '?';
--
cursor l_object_csr is
select '!'
from
	okc_CONTACT_SOURCES_V RS
where
	RS.rle_code IN ('VENDOR','CUSTOMER')
	and RS.jtot_object_code = p_cocv_rec.jtot_object_code
	and sysdate >= RS.start_date
	and (RS.end_date is NULL or RS.end_date>=sysdate)
	and RS.BUY_OR_SELL = 'S';
begin
  x_return_status := OKC_API.G_RET_STS_SUCCESS;
  if (p_cocv_rec.jtot_object_code = OKC_API.G_MISS_CHAR or p_cocv_rec.jtot_object_code is NULL) then
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'JTOT_OBJECT_CODE');
      x_return_status := OKC_API.G_RET_STS_ERROR;
	-- halt further validation of this column
	RAISE G_EXCEPTION_HALT_VALIDATION;
  end if;
--
  open l_object_csr;
  fetch l_object_csr into l_dummy_var;
  close l_object_csr;
  if (l_dummy_var = '?') then
    OKC_API.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'JTOT_OBJECT_CODE');
    x_return_status := OKC_API.G_RET_STS_ERROR;
  end if;
exception
  when OTHERS then
    if l_object_csr%ISOPEN then
      close l_object_csr;
    end if;
    OKC_API.set_message(p_app_name     => g_app_name,
                        p_msg_name     => g_unexpected_error,
                        p_token1       => g_sqlcode_token,
                        p_token1_value => sqlcode,
                        p_token2       => g_sqlerrm_token,
                        p_token2_value => sqlerrm);
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
end validate_JTOT_OBJECT_CODE;

-- Start of comments
--
-- Procedure Name  : validate_object1_id1_
-- Description     :  to be called from validate record
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

procedure validate_object1_id1(x_return_status OUT NOCOPY VARCHAR2,
                          p_cocv_rec	  IN	cocv_rec_TYPE) is
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
	OB.OBJECT_CODE = p_cocv_rec.jtot_object_code
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
begin
  x_return_status := OKC_API.G_RET_STS_SUCCESS;
  if (p_cocv_rec.object1_id1 = OKC_API.G_MISS_CHAR or p_cocv_rec.object1_id1 is NULL) then
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'OBJECT1_ID1');
      x_return_status := OKC_API.G_RET_STS_ERROR;
	-- halt further validation of this column
	RAISE G_EXCEPTION_HALT_VALIDATION;
  end if;
  if (p_cocv_rec.object1_id2 = OKC_API.G_MISS_CHAR or p_cocv_rec.object1_id2 is NULL) then
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'OBJECT2_ID2');
      x_return_status := OKC_API.G_RET_STS_ERROR;
	-- halt further validation of this column
	RAISE G_EXCEPTION_HALT_VALIDATION;
  end if;
  open l_object1_csr;
  fetch l_object1_csr into l_from_table, l_where_clause;
  close l_object1_csr;
  if (l_where_clause is not null) then
	l_where_clause := ' and '||l_where_clause;
  end if;
  EXECUTE IMMEDIATE 'select ''x'' from '||l_from_table||
	' where id1=:object1_id1 and id2=:object1_id2'||l_where_clause
	into l_dummy_var
	USING p_cocv_rec.object1_id1, p_cocv_rec.object1_id2;
exception
  when e_source_not_exists then
    OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'JTOT_OBJECT_CODE');
    x_return_status := OKC_API.G_RET_STS_ERROR;
  when e_source_not_exists1 then
    OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'JTOT_OBJECT_CODE');
    x_return_status := OKC_API.G_RET_STS_ERROR;
  when e_column_not_exists then
    OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,l_from_table||'.ID1');
    x_return_status := OKC_API.G_RET_STS_ERROR;
  when e_no_data_found then
    OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'OBJECT1_ID1');
    x_return_status := OKC_API.G_RET_STS_ERROR;
  when e_too_many_rows then
    OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,l_from_table||'.ID1');
    x_return_status := OKC_API.G_RET_STS_ERROR;
  when OTHERS then
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
end validate_OBJECT1_id1;
  ---------------------------------------------------
  -- Validate_Attributes for:OKS_K_ORDER_CONTACTS_V --
  ---------------------------------------------------
 FUNCTION Validate_Attributes (
    p_cocv_rec IN  cocv_rec_type
  )
  Return VARCHAR2 Is
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    x_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

  Begin
  -- call OKC_UTIL.ADD_VIEW to prepare the PL/SQL table to hold columns of view

    OKC_UTIL.ADD_VIEW('OKS_K_ORDER_CONTACTS_V',x_return_status);

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
    validate_id(x_return_status, p_cocv_rec);

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
    validate_objvernum(x_return_status, p_cocv_rec);

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
    	--CRO_CODE
	 validate_CRO_CODE(x_return_status, p_cocv_rec);

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

	--Jtot_Object_Code
	 validate_Jtot_Object_Code(x_return_status, p_cocv_rec);

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

	--Object1_Id1
/*		validate_Object1_Id1(x_return_status, p_cocv_rec);
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
    END IF; */
     Return (l_return_status);
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

  FUNCTION Validate_Record (
    p_cocv_rec IN cocv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  CURSOR Get_Comb_Keys(P_COd_Id IN NUMBER,
			     P_Cro_Code IN Varchar2,
			     P_Object1_Id1 IN Varchar2) Is
  SELECT COUNT(1)
  FROM OKS_K_ORDER_CONTACTS_V
  WHERE COD_ID=P_COD_ID
  AND   CRO_CODE=P_Cro_Code
  AND   OBJECT1_Id1=P_Object1_Id1;
  l_Count NUMBER := Null;
  BEGIN
  OPEN  Get_Comb_Keys(p_cocv_rec.Cod_Id,
			    p_cocv_rec.Cro_code,
			    p_cocv_rec.object1_Id1);
  FETCH Get_Comb_Keys INTO l_Count;
  CLOSE Get_Comb_Keys;
  IF l_Count<>0
  THEN
       OKC_API.SET_MESSAGE(p_app_name         => g_app_name,
                           p_msg_name         => 'OKS_DUPLICATE_RECORD',
                           p_token1           => 'COD_ID',
                           p_token1_value     => P_COCV_REC.COD_ID,
                           p_token2           => 'CRO_CODE',
                           p_token2_value     => P_COCV_REC.CRO_CODE,
                           p_token3           => 'OBJECT1_ID1',
                           p_token3_value     => P_COCV_REC.Object1_Id1);
      l_return_status := OKC_API.G_RET_STS_ERROR;
	-- halt further validation of this column
	RAISE G_EXCEPTION_HALT_VALIDATION;
  END IF;
    RETURN (l_return_status);
  EXCEPTION
  WHEN G_EXCEPTION_HALT_VALIDATION
  THEN
  RETURN l_Return_Status;
  END Validate_Record;
  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from	IN cocv_rec_type,
    p_to	OUT NOCOPY coc_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.cod_id := p_from.cod_id;
    p_to.cro_code := p_from.cro_code;
    p_to.object1_id1 := p_from.object1_id1;
    p_to.object1_id2 := p_from.object1_id2;
    p_to.jtot_object_code := p_from.jtot_object_code;
    p_to.object_version_number := p_from.object_version_number;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
  END migrate;
  PROCEDURE migrate (
    p_from	IN coc_rec_type,
    p_to	OUT NOCOPY cocv_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.cod_id := p_from.cod_id;
    p_to.cro_code := p_from.cro_code;
    p_to.object1_id1 := p_from.object1_id1;
    p_to.object1_id2 := p_from.object1_id2;
    p_to.jtot_object_code := p_from.jtot_object_code;
    p_to.object_version_number := p_from.object_version_number;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
  END migrate;

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_row
  ---------------------------------------------------------------------------
  ---------------------------------------------
  -- validate_row for:OKS_K_ORDER_CONTACTS_V --
  ---------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cocv_rec                     IN cocv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_cocv_rec                     cocv_rec_type := p_cocv_rec;
    l_coc_rec                      coc_rec_type;
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
    l_return_status := Validate_Attributes(l_cocv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_cocv_rec);
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
  -- PL/SQL TBL validate_row for:COCV_TBL --
  ------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cocv_tbl                     IN cocv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_cocv_tbl.COUNT > 0) THEN
      i := p_cocv_tbl.FIRST;
      LOOP
        validate_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_cocv_rec                     => p_cocv_tbl(i));
        EXIT WHEN (i = p_cocv_tbl.LAST);
        i := p_cocv_tbl.NEXT(i);
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
  -----------------------------------------
  -- insert_row for:OKS_K_ORDER_CONTACTS --
  -----------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_coc_rec                      IN coc_rec_type,
    x_coc_rec                      OUT NOCOPY coc_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'CONTACTS_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_coc_rec                      coc_rec_type := p_coc_rec;
    l_def_coc_rec                  coc_rec_type;
    ---------------------------------------------
    -- Set_Attributes for:OKS_K_ORDER_CONTACTS --
    ---------------------------------------------
    FUNCTION Set_Attributes (
      p_coc_rec IN  coc_rec_type,
      x_coc_rec OUT NOCOPY coc_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_coc_rec := p_coc_rec;
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
      p_coc_rec,                         -- IN
      l_coc_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKS_K_ORDER_CONTACTS(
        id,
        cod_id,
        cro_code,
        object1_id1,
        object1_id2,
        jtot_object_code,
        object_version_number,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date)
       -- security_group_id)
      VALUES (
        l_coc_rec.id,
        l_coc_rec.cod_id,
        l_coc_rec.cro_code,
        l_coc_rec.object1_id1,
        l_coc_rec.object1_id2,
        l_coc_rec.jtot_object_code,
        l_coc_rec.object_version_number,
        l_coc_rec.created_by,
        l_coc_rec.creation_date,
        l_coc_rec.last_updated_by,
        l_coc_rec.last_update_date);
       -- l_coc_rec.security_group_id);
    -- Set OUT values
    x_coc_rec := l_coc_rec;
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
  -------------------------------------------
  -- insert_row for:OKS_K_ORDER_CONTACTS_V --
  -------------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cocv_rec                     IN cocv_rec_type,
    x_cocv_rec                     OUT NOCOPY cocv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_cocv_rec                     cocv_rec_type;
    l_def_cocv_rec                 cocv_rec_type;
    l_coc_rec                      coc_rec_type;
    lx_coc_rec                     coc_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_cocv_rec	IN cocv_rec_type
    ) RETURN cocv_rec_type IS
      l_cocv_rec	cocv_rec_type := p_cocv_rec;
    BEGIN
      l_cocv_rec.CREATION_DATE := SYSDATE;
      l_cocv_rec.CREATED_BY := FND_GLOBAL.USER_ID;
      l_cocv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_cocv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      RETURN(l_cocv_rec);
    END fill_who_columns;
    -----------------------------------------------
    -- Set_Attributes for:OKS_K_ORDER_CONTACTS_V --
    -----------------------------------------------
    FUNCTION Set_Attributes (
      p_cocv_rec IN  cocv_rec_type,
      x_cocv_rec OUT NOCOPY cocv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_cocv_rec := p_cocv_rec;
      x_cocv_rec.OBJECT_VERSION_NUMBER := 1;
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
    l_cocv_rec := null_out_defaults(p_cocv_rec);
    -- Set primary key value
    l_cocv_rec.ID := get_seq_id;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      l_cocv_rec,                        -- IN
      l_def_cocv_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_cocv_rec := fill_who_columns(l_def_cocv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_cocv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_cocv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_cocv_rec, l_coc_rec);
    --------------------------------------------
    -- Call the INSERT_ROW for each child record
    --------------------------------------------
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_coc_rec,
      lx_coc_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_coc_rec, l_def_cocv_rec);
    -- Set OUT values
    x_cocv_rec := l_def_cocv_rec;
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
  -- PL/SQL TBL insert_row for:COCV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cocv_tbl                     IN cocv_tbl_type,
    x_cocv_tbl                     OUT NOCOPY cocv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_cocv_tbl.COUNT > 0) THEN
      i := p_cocv_tbl.FIRST;
      LOOP
        insert_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_cocv_rec                     => p_cocv_tbl(i),
          x_cocv_rec                     => x_cocv_tbl(i));
        EXIT WHEN (i = p_cocv_tbl.LAST);
        i := p_cocv_tbl.NEXT(i);
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
  ---------------------------------------
  -- lock_row for:OKS_K_ORDER_CONTACTS --
  ---------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_coc_rec                      IN coc_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_coc_rec IN coc_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKS_K_ORDER_CONTACTS
     WHERE ID = p_coc_rec.id
       AND OBJECT_VERSION_NUMBER = p_coc_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR  lchk_csr (p_coc_rec IN coc_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKS_K_ORDER_CONTACTS
    WHERE ID = p_coc_rec.id;
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'CONTACTS_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_object_version_number       OKS_K_ORDER_CONTACTS.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number      OKS_K_ORDER_CONTACTS.OBJECT_VERSION_NUMBER%TYPE;
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
      OPEN lock_csr(p_coc_rec);
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
      OPEN lchk_csr(p_coc_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_coc_rec.object_version_number THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_coc_rec.object_version_number THEN
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
  -----------------------------------------
  -- lock_row for:OKS_K_ORDER_CONTACTS_V --
  -----------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cocv_rec                     IN cocv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_coc_rec                      coc_rec_type;
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
    migrate(p_cocv_rec, l_coc_rec);
    --------------------------------------------
    -- Call the LOCK_ROW for each child record
    --------------------------------------------
    lock_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_coc_rec
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
  -- PL/SQL TBL lock_row for:COCV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cocv_tbl                     IN cocv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_cocv_tbl.COUNT > 0) THEN
      i := p_cocv_tbl.FIRST;
      LOOP
        lock_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_cocv_rec                     => p_cocv_tbl(i));
        EXIT WHEN (i = p_cocv_tbl.LAST);
        i := p_cocv_tbl.NEXT(i);
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
  -----------------------------------------
  -- update_row for:OKS_K_ORDER_CONTACTS --
  -----------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_coc_rec                      IN coc_rec_type,
    x_coc_rec                      OUT NOCOPY coc_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'CONTACTS_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_coc_rec                      coc_rec_type := p_coc_rec;
    l_def_coc_rec                  coc_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_coc_rec	IN coc_rec_type,
      x_coc_rec	OUT NOCOPY coc_rec_type
    ) RETURN VARCHAR2 IS
      l_coc_rec                      coc_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_coc_rec := p_coc_rec;
      -- Get current database values
      l_coc_rec := get_rec(p_coc_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_coc_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_coc_rec.id := l_coc_rec.id;
      END IF;
      IF (x_coc_rec.cod_id = OKC_API.G_MISS_NUM)
      THEN
        x_coc_rec.cod_id := l_coc_rec.cod_id;
      END IF;
      IF (x_coc_rec.cro_code = OKC_API.G_MISS_CHAR)
      THEN
        x_coc_rec.cro_code := l_coc_rec.cro_code;
      END IF;
      IF (x_coc_rec.object1_id1 = OKC_API.G_MISS_CHAR)
      THEN
        x_coc_rec.object1_id1 := l_coc_rec.object1_id1;
      END IF;
      IF (x_coc_rec.object1_id2 = OKC_API.G_MISS_CHAR)
      THEN
        x_coc_rec.object1_id2 := l_coc_rec.object1_id2;
      END IF;
      IF (x_coc_rec.jtot_object_code = OKC_API.G_MISS_CHAR)
      THEN
        x_coc_rec.jtot_object_code := l_coc_rec.jtot_object_code;
      END IF;
      IF (x_coc_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_coc_rec.object_version_number := l_coc_rec.object_version_number;
      END IF;
      IF (x_coc_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_coc_rec.created_by := l_coc_rec.created_by;
      END IF;
      IF (x_coc_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_coc_rec.creation_date := l_coc_rec.creation_date;
      END IF;
      IF (x_coc_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_coc_rec.last_updated_by := l_coc_rec.last_updated_by;
      END IF;
      IF (x_coc_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_coc_rec.last_update_date := l_coc_rec.last_update_date;
      END IF;

/*
      IF (x_coc_rec.security_group_id = OKC_API.G_MISS_NUM)
      THEN
        x_coc_rec.security_group_id := l_coc_rec.security_group_id;
      END IF;
*/

      RETURN(l_return_status);
    END populate_new_record;
    ---------------------------------------------
    -- Set_Attributes for:OKS_K_ORDER_CONTACTS --
    ---------------------------------------------
    FUNCTION Set_Attributes (
      p_coc_rec IN  coc_rec_type,
      x_coc_rec OUT NOCOPY coc_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_coc_rec := p_coc_rec;
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
      p_coc_rec,                         -- IN
      l_coc_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_coc_rec, l_def_coc_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKS_K_ORDER_CONTACTS
    SET COD_ID = l_def_coc_rec.cod_id,
        CRO_CODE = l_def_coc_rec.cro_code,
        OBJECT1_ID1 = l_def_coc_rec.object1_id1,
        OBJECT1_ID2 = l_def_coc_rec.object1_id2,
        JTOT_OBJECT_CODE = l_def_coc_rec.jtot_object_code,
        OBJECT_VERSION_NUMBER = l_def_coc_rec.object_version_number,
        CREATED_BY = l_def_coc_rec.created_by,
        CREATION_DATE = l_def_coc_rec.creation_date,
        LAST_UPDATED_BY = l_def_coc_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_coc_rec.last_update_date
       -- SECURITY_GROUP_ID = l_def_coc_rec.security_group_id
    WHERE ID = l_def_coc_rec.id;

    x_coc_rec := l_def_coc_rec;
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
  -------------------------------------------
  -- update_row for:OKS_K_ORDER_CONTACTS_V --
  -------------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cocv_rec                     IN cocv_rec_type,
    x_cocv_rec                     OUT NOCOPY cocv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_cocv_rec                     cocv_rec_type := p_cocv_rec;
    l_def_cocv_rec                 cocv_rec_type;
    l_coc_rec                      coc_rec_type;
    lx_coc_rec                     coc_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_cocv_rec	IN cocv_rec_type
    ) RETURN cocv_rec_type IS
      l_cocv_rec	cocv_rec_type := p_cocv_rec;
    BEGIN
      l_cocv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_cocv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      RETURN(l_cocv_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_cocv_rec	IN cocv_rec_type,
      x_cocv_rec	OUT NOCOPY cocv_rec_type
    ) RETURN VARCHAR2 IS
      l_cocv_rec                     cocv_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_cocv_rec := p_cocv_rec;
      -- Get current database values
      l_cocv_rec := get_rec(p_cocv_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_cocv_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_cocv_rec.id := l_cocv_rec.id;
      END IF;
      IF (x_cocv_rec.cod_id = OKC_API.G_MISS_NUM)
      THEN
        x_cocv_rec.cod_id := l_cocv_rec.cod_id;
      END IF;
      IF (x_cocv_rec.cro_code = OKC_API.G_MISS_CHAR)
      THEN
        x_cocv_rec.cro_code := l_cocv_rec.cro_code;
      END IF;
      IF (x_cocv_rec.jtot_object_code = OKC_API.G_MISS_CHAR)
      THEN
        x_cocv_rec.jtot_object_code := l_cocv_rec.jtot_object_code;
      END IF;
      IF (x_cocv_rec.object1_id1 = OKC_API.G_MISS_CHAR)
      THEN
        x_cocv_rec.object1_id1 := l_cocv_rec.object1_id1;
      END IF;
      IF (x_cocv_rec.object1_id2 = OKC_API.G_MISS_CHAR)
      THEN
        x_cocv_rec.object1_id2 := l_cocv_rec.object1_id2;
      END IF;
      IF (x_cocv_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_cocv_rec.object_version_number := l_cocv_rec.object_version_number;
      END IF;
      IF (x_cocv_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_cocv_rec.created_by := l_cocv_rec.created_by;
      END IF;
      IF (x_cocv_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_cocv_rec.creation_date := l_cocv_rec.creation_date;
      END IF;
      IF (x_cocv_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_cocv_rec.last_updated_by := l_cocv_rec.last_updated_by;
      END IF;
      IF (x_cocv_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_cocv_rec.last_update_date := l_cocv_rec.last_update_date;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    -----------------------------------------------
    -- Set_Attributes for:OKS_K_ORDER_CONTACTS_V --
    -----------------------------------------------
    FUNCTION Set_Attributes (
      p_cocv_rec IN  cocv_rec_type,
      x_cocv_rec OUT NOCOPY cocv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_cocv_rec := p_cocv_rec;
      x_cocv_rec.OBJECT_VERSION_NUMBER := NVL(x_cocv_rec.OBJECT_VERSION_NUMBER, 0) + 1;
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
      p_cocv_rec,                        -- IN
      l_cocv_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_cocv_rec, l_def_cocv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_cocv_rec := fill_who_columns(l_def_cocv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_cocv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_cocv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_cocv_rec, l_coc_rec);
    --------------------------------------------
    -- Call the UPDATE_ROW for each child record
    --------------------------------------------
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_coc_rec,
      lx_coc_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_coc_rec, l_def_cocv_rec);
    x_cocv_rec := l_def_cocv_rec;
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
  -- PL/SQL TBL update_row for:COCV_TBL --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cocv_tbl                     IN cocv_tbl_type,
    x_cocv_tbl                     OUT NOCOPY cocv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_cocv_tbl.COUNT > 0) THEN
      i := p_cocv_tbl.FIRST;
      LOOP
        update_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_cocv_rec                     => p_cocv_tbl(i),
          x_cocv_rec                     => x_cocv_tbl(i));
        EXIT WHEN (i = p_cocv_tbl.LAST);
        i := p_cocv_tbl.NEXT(i);
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
  -----------------------------------------
  -- delete_row for:OKS_K_ORDER_CONTACTS --
  -----------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_coc_rec                      IN coc_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'CONTACTS_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_coc_rec                      coc_rec_type:= p_coc_rec;
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
    DELETE FROM OKS_K_ORDER_CONTACTS
     WHERE ID = l_coc_rec.id;

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
  -------------------------------------------
  -- delete_row for:OKS_K_ORDER_CONTACTS_V --
  -------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cocv_rec                     IN cocv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_cocv_rec                     cocv_rec_type := p_cocv_rec;
    l_coc_rec                      coc_rec_type;
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
    migrate(l_cocv_rec, l_coc_rec);
    --------------------------------------------
    -- Call the DELETE_ROW for each child record
    --------------------------------------------
    delete_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_coc_rec
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
  -- PL/SQL TBL delete_row for:COCV_TBL --
  ----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cocv_tbl                     IN cocv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_cocv_tbl.COUNT > 0) THEN
      i := p_cocv_tbl.FIRST;
      LOOP
        delete_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_cocv_rec                     => p_cocv_tbl(i));
        EXIT WHEN (i = p_cocv_tbl.LAST);
        i := p_cocv_tbl.NEXT(i);
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
END OKS_COC_PVT;

/
