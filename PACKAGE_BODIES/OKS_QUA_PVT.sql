--------------------------------------------------------
--  DDL for Package Body OKS_QUA_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKS_QUA_PVT" AS
/* $Header: OKSSQUAB.pls 120.0 2005/05/25 18:34:07 appldev noship $ */

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
  -- FUNCTION get_rec for: OKS_QUALIFIERS
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_qua_rec                      IN qua_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN qua_rec_type IS
    CURSOR qua_pk_csr (p_id                 IN NUMBER) IS
    SELECT
 	QUALIFIER_ID
 	,CREATION_DATE
 	,CREATED_BY
 	,LAST_UPDATE_DATE
 	,LAST_UPDATED_BY
 	,REQUEST_ID
 	,PROGRAM_APPLICATION_ID
 	,PROGRAM_ID
 	,PROGRAM_UPDATE_DATE
 	,LAST_UPDATE_LOGIN
 	,QUALIFIER_GROUPING_NO
 	,QUALIFIER_CONTEXT
 	,QUALIFIER_ATTRIBUTE
 	,QUALIFIER_ATTR_VALUE
 	,COMPARISON_OPERATOR_CODE
 	,EXCLUDER_FLAG
 	,QUALIFIER_RULE_ID
 	,START_DATE_ACTIVE
 	,END_DATE_ACTIVE
 	,CREATED_FROM_RULE_ID
 	,QUALIFIER_PRECEDENCE
 	,LIST_HEADER_ID
 	,LIST_LINE_ID
 	,QUALIFIER_DATATYPE
 	,QUALIFIER_ATTR_VALUE_TO
 	,CONTEXT
 	,ATTRIBUTE1
 	,ATTRIBUTE2
 	,ATTRIBUTE3
 	,ATTRIBUTE4
 	,ATTRIBUTE5
 	,ATTRIBUTE6
 	,ATTRIBUTE7
 	,ATTRIBUTE8
 	,ATTRIBUTE9
 	,ATTRIBUTE10
 	,ATTRIBUTE11
 	,ATTRIBUTE12
 	,ATTRIBUTE13
 	,ATTRIBUTE14
 	,ATTRIBUTE15
 	,ACTIVE_FLAG
 	,LIST_TYPE_CODE
 	,QUAL_ATTR_VALUE_FROM_NUMBER
 	,QUAL_ATTR_VALUE_TO_NUMBER
      FROM oks_qualifiers
     WHERE qualifier_id = p_id;
    l_qua_pk                       qua_pk_csr%ROWTYPE;
    l_qua_rec                      qua_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN qua_pk_csr (p_qua_rec.qualifier_id);
    FETCH qua_pk_csr INTO
 	l_qua_rec.QUALIFIER_ID
 	,l_qua_rec.CREATION_DATE
 	,l_qua_rec.CREATED_BY
 	,l_qua_rec.LAST_UPDATE_DATE
 	,l_qua_rec.LAST_UPDATED_BY
 	,l_qua_rec.REQUEST_ID
 	,l_qua_rec.PROGRAM_APPLICATION_ID
 	,l_qua_rec.PROGRAM_ID
 	,l_qua_rec.PROGRAM_UPDATE_DATE
 	,l_qua_rec.LAST_UPDATE_LOGIN
 	,l_qua_rec.QUALIFIER_GROUPING_NO
 	,l_qua_rec.QUALIFIER_CONTEXT
 	,l_qua_rec.QUALIFIER_ATTRIBUTE
 	,l_qua_rec.QUALIFIER_ATTR_VALUE
 	,l_qua_rec.COMPARISON_OPERATOR_CODE
 	,l_qua_rec.EXCLUDER_FLAG
 	,l_qua_rec.QUALIFIER_RULE_ID
 	,l_qua_rec.START_DATE_ACTIVE
 	,l_qua_rec.END_DATE_ACTIVE
 	,l_qua_rec.CREATED_FROM_RULE_ID
 	,l_qua_rec.QUALIFIER_PRECEDENCE
 	,l_qua_rec.LIST_HEADER_ID
 	,l_qua_rec.LIST_LINE_ID
 	,l_qua_rec.QUALIFIER_DATATYPE
 	,l_qua_rec.QUALIFIER_ATTR_VALUE_TO
 	,l_qua_rec.CONTEXT
 	,l_qua_rec.ATTRIBUTE1
 	,l_qua_rec.ATTRIBUTE2
 	,l_qua_rec.ATTRIBUTE3
 	,l_qua_rec.ATTRIBUTE4
 	,l_qua_rec.ATTRIBUTE5
 	,l_qua_rec.ATTRIBUTE6
 	,l_qua_rec.ATTRIBUTE7
 	,l_qua_rec.ATTRIBUTE8
 	,l_qua_rec.ATTRIBUTE9
 	,l_qua_rec.ATTRIBUTE10
 	,l_qua_rec.ATTRIBUTE11
 	,l_qua_rec.ATTRIBUTE12
 	,l_qua_rec.ATTRIBUTE13
 	,l_qua_rec.ATTRIBUTE14
 	,l_qua_rec.ATTRIBUTE15
 	,l_qua_rec.ACTIVE_FLAG
 	,l_qua_rec.LIST_TYPE_CODE
 	,l_qua_rec.QUAL_ATTR_VALUE_FROM_NUMBER
 	,l_qua_rec.QUAL_ATTR_VALUE_TO_NUMBER            ;

    x_no_data_found := qua_pk_csr%NOTFOUND;
    CLOSE qua_pk_csr;
    RETURN(l_qua_rec);
  END get_rec;

  FUNCTION get_rec (
    p_qua_rec                      IN qua_rec_type
  ) RETURN qua_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_qua_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKS_QUALIFIERS_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_quav_rec                     IN quav_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN quav_rec_type IS
    CURSOR oks_quav_pk_csr (p_id                 IN NUMBER) IS
    SELECT
 QUALIFIER_ID
 ,CREATION_DATE
 ,CREATED_BY
 ,LAST_UPDATE_DATE
 ,LAST_UPDATED_BY
 ,REQUEST_ID
 ,PROGRAM_APPLICATION_ID
 ,PROGRAM_ID
 ,PROGRAM_UPDATE_DATE
 ,LAST_UPDATE_LOGIN
 ,QUALIFIER_GROUPING_NO
 ,QUALIFIER_CONTEXT
 ,QUALIFIER_ATTRIBUTE
 ,QUALIFIER_ATTR_VALUE
 ,COMPARISON_OPERATOR_CODE
 ,EXCLUDER_FLAG
 ,QUALIFIER_RULE_ID
 ,START_DATE_ACTIVE
 ,END_DATE_ACTIVE
 ,CREATED_FROM_RULE_ID
 ,QUALIFIER_PRECEDENCE
 ,LIST_HEADER_ID
 ,LIST_LINE_ID
 ,QUALIFIER_DATATYPE
 ,QUALIFIER_ATTR_VALUE_TO
 ,CONTEXT
 ,ATTRIBUTE1
 ,ATTRIBUTE2
 ,ATTRIBUTE3
 ,ATTRIBUTE4
 ,ATTRIBUTE5
 ,ATTRIBUTE6
 ,ATTRIBUTE7
 ,ATTRIBUTE8
 ,ATTRIBUTE9
 ,ATTRIBUTE10
 ,ATTRIBUTE11
 ,ATTRIBUTE12
 ,ATTRIBUTE13
 ,ATTRIBUTE14
 ,ATTRIBUTE15
 ,ACTIVE_FLAG
 ,LIST_TYPE_CODE
 ,QUAL_ATTR_VALUE_FROM_NUMBER
 ,QUAL_ATTR_VALUE_TO_NUMBER
      FROM Oks_QUALIFIERS_V
     WHERE oks_qualifiers_v.qualifier_id = p_id;
    l_oks_quav_pk                  oks_quav_pk_csr%ROWTYPE;
    l_quav_rec                     quav_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN oks_quav_pk_csr (p_quav_rec.qualifier_id);
    FETCH oks_quav_pk_csr INTO
 l_quav_rec.QUALIFIER_ID
 ,l_quav_rec.CREATION_DATE
 ,l_quav_rec.CREATED_BY
 ,l_quav_rec.LAST_UPDATE_DATE
 ,l_quav_rec.LAST_UPDATED_BY
 ,l_quav_rec.REQUEST_ID
 ,l_quav_rec.PROGRAM_APPLICATION_ID
 ,l_quav_rec.PROGRAM_ID
 ,l_quav_rec.PROGRAM_UPDATE_DATE
 ,l_quav_rec.LAST_UPDATE_LOGIN
 ,l_quav_rec.QUALIFIER_GROUPING_NO
 ,l_quav_rec.QUALIFIER_CONTEXT
 ,l_quav_rec.QUALIFIER_ATTRIBUTE
 ,l_quav_rec.QUALIFIER_ATTR_VALUE
 ,l_quav_rec.COMPARISON_OPERATOR_CODE
 ,l_quav_rec.EXCLUDER_FLAG
 ,l_quav_rec.QUALIFIER_RULE_ID
 ,l_quav_rec.START_DATE_ACTIVE
 ,l_quav_rec.END_DATE_ACTIVE
 ,l_quav_rec.CREATED_FROM_RULE_ID
 ,l_quav_rec.QUALIFIER_PRECEDENCE
 ,l_quav_rec.LIST_HEADER_ID
 ,l_quav_rec.LIST_LINE_ID
 ,l_quav_rec.QUALIFIER_DATATYPE
 ,l_quav_rec.QUALIFIER_ATTR_VALUE_TO
 ,l_quav_rec.CONTEXT
 ,l_quav_rec.ATTRIBUTE1
 ,l_quav_rec.ATTRIBUTE2
 ,l_quav_rec.ATTRIBUTE3
 ,l_quav_rec.ATTRIBUTE4
 ,l_quav_rec.ATTRIBUTE5
 ,l_quav_rec.ATTRIBUTE6
 ,l_quav_rec.ATTRIBUTE7
 ,l_quav_rec.ATTRIBUTE8
 ,l_quav_rec.ATTRIBUTE9
 ,l_quav_rec.ATTRIBUTE10
 ,l_quav_rec.ATTRIBUTE11
 ,l_quav_rec.ATTRIBUTE12
 ,l_quav_rec.ATTRIBUTE13
 ,l_quav_rec.ATTRIBUTE14
 ,l_quav_rec.ATTRIBUTE15
 ,l_quav_rec.ACTIVE_FLAG
 ,l_quav_rec.LIST_TYPE_CODE
 ,l_quav_rec.QUAL_ATTR_VALUE_FROM_NUMBER
 ,l_quav_rec.QUAL_ATTR_VALUE_TO_NUMBER            ;


    x_no_data_found := oks_quav_pk_csr%NOTFOUND;
    CLOSE oks_quav_pk_csr;
    RETURN(l_quav_rec);
  END get_rec;

  FUNCTION get_rec (
    p_quav_rec                     IN quav_rec_type
  ) RETURN quav_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_quav_rec, l_row_notfound));
  END get_rec;

  ----------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKS_QUALIFIERS_V --
  ----------------------------------------------------------
  FUNCTION null_out_defaults (
    p_quav_rec	IN quav_rec_type
  ) RETURN quav_rec_type IS
    l_quav_rec	quav_rec_type := p_quav_rec;
  BEGIN
    IF (l_quav_rec.qualifier_id  = OKC_API.G_MISS_NUM) THEN
      l_quav_rec.qualifier_id := NULL;
    END IF;
    IF (l_quav_rec.CREATION_DATE  = OKC_API.G_MISS_DATE) THEN
      l_quav_rec.CREATION_DATE := NULL;
    END IF;
    IF (l_quav_rec.created_by  = OKC_API.G_MISS_NUM) THEN
      l_quav_rec.created_by := NULL;
    END IF;
    IF (l_quav_rec.last_update_date  = OKC_API.G_MISS_DATE) THEN
      l_quav_rec.last_update_date := NULL;
    END IF;
    IF (l_quav_rec.last_updated_by  = OKC_API.G_MISS_NUM) THEN
      l_quav_rec.last_updated_by := NULL;
    END IF;
    IF (l_quav_rec.qualifier_grouping_no  = OKC_API.G_MISS_NUM) THEN
      l_quav_rec.qualifier_grouping_no := NULL;
    END IF;
    IF (l_quav_rec.qualifier_context  = OKC_API.G_MISS_CHAR) THEN
      l_quav_rec.qualifier_context := NULL;
    END IF;
    IF (l_quav_rec.qualifier_attribute  = OKC_API.G_MISS_CHAR) THEN
      l_quav_rec.qualifier_attribute := NULL;
    END IF;
    IF (l_quav_rec.qualifier_attr_value  = OKC_API.G_MISS_CHAR) THEN
      l_quav_rec.qualifier_attr_value := NULL;
    END IF;
    IF (l_quav_rec.comparison_operator_code  = OKC_API.G_MISS_CHAR) THEN
      l_quav_rec.comparison_operator_code := NULL;
    END IF;
    IF (l_quav_rec.excluder_flag  = OKC_API.G_MISS_CHAR) THEN
      l_quav_rec.excluder_flag := NULL;
    END IF;
    IF (l_quav_rec.qualifier_rule_id  = OKC_API.G_MISS_NUM) THEN
      l_quav_rec.qualifier_rule_id := NULL;
    END IF;
    IF (l_quav_rec.start_date_Active  = OKC_API.G_MISS_DATE) THEN
      l_quav_rec.start_date_Active := NULL;
    END IF;
    IF (l_quav_rec.end_date_Active  = OKC_API.G_MISS_DATE) THEN
      l_quav_rec.end_date_Active := NULL;
    END IF;
    IF (l_quav_rec.created_from_rule_id  = OKC_API.G_MISS_NUM) THEN
      l_quav_rec.created_from_rule_id := NULL;
    END IF;
    IF (l_quav_rec.qualifier_precedence  = OKC_API.G_MISS_NUM) THEN
      l_quav_rec.qualifier_precedence := NULL;
    END IF;
    IF (l_quav_rec.list_header_id  = OKC_API.G_MISS_NUM) THEN
      l_quav_rec.list_header_id := NULL;
    END IF;
    IF (l_quav_rec.list_line_id  = OKC_API.G_MISS_NUM) THEN
      l_quav_rec.list_line_id := NULL;
    END IF;
    IF (l_quav_rec.qualifier_datatype  = OKC_API.G_MISS_CHAR) THEN
      l_quav_rec.qualifier_datatype := NULL;
    END IF;
    IF (l_quav_rec.qualifier_attr_value_to  = OKC_API.G_MISS_CHAR) THEN
      l_quav_rec.qualifier_attr_value_to := NULL;
    END IF;
    IF (l_quav_rec.context  = OKC_API.G_MISS_CHAR) THEN
      l_quav_rec.context := NULL;
    END IF;
    IF (l_quav_rec.attribute1  = OKC_API.G_MISS_CHAR) THEN
      l_quav_rec.attribute1 := NULL;
    END IF;
    IF (l_quav_rec.attribute2  = OKC_API.G_MISS_CHAR) THEN
      l_quav_rec.attribute2 := NULL;
    END IF;
    IF (l_quav_rec.attribute3  = OKC_API.G_MISS_CHAR) THEN
      l_quav_rec.attribute3 := NULL;
    END IF;
    IF (l_quav_rec.attribute4  = OKC_API.G_MISS_CHAR) THEN
      l_quav_rec.attribute4 := NULL;
    END IF;
    IF (l_quav_rec.attribute5  = OKC_API.G_MISS_CHAR) THEN
      l_quav_rec.attribute5 := NULL;
    END IF;
    IF (l_quav_rec.attribute6  = OKC_API.G_MISS_CHAR) THEN
      l_quav_rec.attribute6 := NULL;
    END IF;
    IF (l_quav_rec.attribute7  = OKC_API.G_MISS_CHAR) THEN
      l_quav_rec.attribute7 := NULL;
    END IF;
    IF (l_quav_rec.attribute8  = OKC_API.G_MISS_CHAR) THEN
      l_quav_rec.attribute8 := NULL;
    END IF;
    IF (l_quav_rec.attribute9  = OKC_API.G_MISS_CHAR) THEN
      l_quav_rec.attribute9 := NULL;
    END IF;
    IF (l_quav_rec.attribute10  = OKC_API.G_MISS_CHAR) THEN
      l_quav_rec.attribute10 := NULL;
    END IF;
    IF (l_quav_rec.attribute11  = OKC_API.G_MISS_CHAR) THEN
      l_quav_rec.attribute11 := NULL;
    END IF;
    IF (l_quav_rec.attribute12  = OKC_API.G_MISS_CHAR) THEN
      l_quav_rec.attribute12 := NULL;
    END IF;
    IF (l_quav_rec.attribute13  = OKC_API.G_MISS_CHAR) THEN
      l_quav_rec.attribute13 := NULL;
    END IF;
    IF (l_quav_rec.attribute14  = OKC_API.G_MISS_CHAR) THEN
      l_quav_rec.attribute14 := NULL;
    END IF;
    IF (l_quav_rec.attribute15  = OKC_API.G_MISS_CHAR) THEN
      l_quav_rec.attribute15 := NULL;
    END IF;
    IF (l_quav_rec.active_flag  = OKC_API.G_MISS_CHAR) THEN
      l_quav_rec.active_flag := NULL;
    END IF;
    IF (l_quav_rec.list_type_code  = OKC_API.G_MISS_CHAR) THEN
      l_quav_rec.list_type_code := NULL;
    END IF;
    IF (l_quav_rec.QUAL_ATTR_VALUE_FROM_NUMBER  = OKC_API.G_MISS_NUM) THEN
      l_quav_rec.QUAL_ATTR_VALUE_FROM_NUMBER := NULL;
    END IF;
    IF (l_quav_rec.QUAL_ATTR_VALUE_TO_NUMBER  = OKC_API.G_MISS_NUM) THEN
      l_quav_rec.QUAL_ATTR_VALUE_TO_NUMBER := NULL;
    END IF;


    RETURN(l_quav_rec);
  END null_out_defaults;
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Attributes
  ---------------------------------------------------------------------------
PROCEDURE validate_qual_id(x_return_status OUT NOCOPY varchar2,
				p_id   IN  Number)
  Is
  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
  Begin

  x_return_status := OKC_API.G_RET_STS_SUCCESS;

  If p_id = OKC_API.G_MISS_NUM OR
       p_id IS NULL
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
  End validate_qual_id;

 PROCEDURE validate_creation_date(x_return_status OUT NOCOPY varchar2,
                                p_date   IN  Date)
  Is
  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
  Begin

  x_return_status := OKC_API.G_RET_STS_SUCCESS;

  If p_date = OKC_API.G_MISS_DATE OR
       p_date IS NULL
  Then
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'creation_date');
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
  End validate_creation_date;

 PROCEDURE validate_created_by(x_return_status OUT NOCOPY varchar2,
                                p_id   IN  Number)
  Is
  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
  Begin

  x_return_status := OKC_API.G_RET_STS_SUCCESS;

  If p_id = OKC_API.G_MISS_NUM OR
       p_id IS NULL
  Then
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'created_by');
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
  End validate_created_by;

 PROCEDURE validate_last_update_by(x_return_status OUT NOCOPY varchar2,
                                p_id   IN  Number)
  Is
  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
  Begin

  x_return_status := OKC_API.G_RET_STS_SUCCESS;

  If p_id = OKC_API.G_MISS_NUM OR
       p_id IS NULL
  Then
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'last_update_by');
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
  End validate_last_update_by;

 PROCEDURE validate_last_update_date(x_return_status OUT NOCOPY varchar2,
                                p_date   IN  DATE)
  Is
  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
  Begin

  x_return_status := OKC_API.G_RET_STS_SUCCESS;

  If p_date = OKC_API.G_MISS_DATE OR
       p_date IS NULL
  Then
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'last_update_date');
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
  End validate_last_update_date;

  PROCEDURE validate_qual_context(x_return_status OUT NOCOPY varchar2,
                                p_char   IN  varchar)
  Is
  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
  Begin

  x_return_status := OKC_API.G_RET_STS_SUCCESS;

  If p_char = OKC_API.G_MISS_CHAR OR
       p_char IS NULL
  Then
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'qualifier_context');
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
  End validate_qual_context;

   PROCEDURE validate_qual_attribute(x_return_status OUT NOCOPY varchar2,
                                p_char   IN  varchar)
  Is
  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
  Begin

  x_return_status := OKC_API.G_RET_STS_SUCCESS;

  If p_char = OKC_API.G_MISS_CHAR OR
       p_char IS NULL
  Then
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'qualifier_attribute');
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
  End validate_qual_attribute;

   PROCEDURE validate_comp_oper_code(x_return_status OUT NOCOPY varchar2,
                                p_char   IN  varchar)
  Is
  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
  Begin

  x_return_status := OKC_API.G_RET_STS_SUCCESS;

  If p_char = OKC_API.G_MISS_CHAR OR
       p_char IS NULL
  Then
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'qualifier_comparison_operator_code');
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
  End validate_comp_oper_code;

   PROCEDURE validate_excluder_flag(x_return_status OUT NOCOPY varchar2,
                                p_char   IN  varchar)
  Is
  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
  Begin

  x_return_status := OKC_API.G_RET_STS_SUCCESS;

  If p_char = OKC_API.G_MISS_CHAR OR
       p_char IS NULL
  Then
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'excluder_flag');
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
  End validate_excluder_flag;


  PROCEDURE validate_qual_group_no(x_return_status OUT NOCOPY varchar2,
                                p_id   IN  number)
  Is
  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
  Begin

  x_return_status := OKC_API.G_RET_STS_SUCCESS;

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
  End validate_qual_group_no;

   PROCEDURE validate_qual_rule_id(x_return_status OUT NOCOPY varchar2,
                                p_id   IN  number)
  Is
  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
  Begin

  x_return_status := OKC_API.G_RET_STS_SUCCESS;

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
  End validate_qual_rule_id;

   PROCEDURE validate_start_date_active(x_return_status OUT NOCOPY varchar2,
                                p_date   IN  DATE)
  Is
  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
  Begin

  x_return_status := OKC_API.G_RET_STS_SUCCESS;

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
  End validate_start_date_active;

   PROCEDURE validate_end_date_active(x_return_status OUT NOCOPY varchar2,
                                p_date   IN  DATE)
  Is
  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
  Begin

  x_return_status := OKC_API.G_RET_STS_SUCCESS;

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
  End validate_end_date_active;


  PROCEDURE validate_created_from_rule_id(x_return_status OUT NOCOPY varchar2,
                                         P_id IN  Number)
  Is
  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
  Begin
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
  END validate_created_from_rule_id;

 PROCEDURE validate_qual_precedence(x_return_status OUT NOCOPY varchar2,
                                         P_id IN  Number)
  Is
  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
  Begin
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
  END validate_qual_precedence;

   PROCEDURE validate_list_header_id(x_return_status OUT NOCOPY varchar2,
                                         P_id IN  Number)
  Is
  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
  Begin
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
  END validate_list_header_id;

   PROCEDURE validate_list_line_id(x_return_status OUT NOCOPY varchar2,
                                         P_id IN  Number)
  Is
  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
  Begin
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
  END validate_list_line_id;

   PROCEDURE validate_qual_datatype(x_return_status OUT NOCOPY varchar2,
                                         P_char IN  varchar)
  Is
  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
  Begin
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
  END validate_qual_datatype;

   PROCEDURE validate_qual_attr_value_to(x_return_status OUT NOCOPY varchar2,
                                         P_char IN  varchar)
  Is
  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
  Begin
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
  END validate_qual_attr_value_to;

   PROCEDURE validate_qual_attr_value(x_return_status OUT NOCOPY varchar2,
                                         P_char IN  varchar)
  Is
  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
  Begin
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
  END validate_qual_attr_value;

   PROCEDURE validate_context(x_return_status OUT NOCOPY varchar2,
                                         P_char IN  varchar)
  Is
  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
  Begin
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
  END validate_context;

  PROCEDURE validate_attribute1(x_return_status OUT NOCOPY varchar2,
                                         P_char IN  varchar)
  Is
  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
  Begin
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
  END validate_attribute1;

   PROCEDURE validate_attribute2(x_return_status OUT NOCOPY varchar2,
                                         P_char IN  varchar)
  Is
  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
  Begin
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
  END validate_attribute2;

   PROCEDURE validate_attribute3(x_return_status OUT NOCOPY varchar2,
                                         P_char IN  varchar)
  Is
  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
  Begin
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
  END validate_attribute3;

  PROCEDURE validate_attribute4(x_return_status OUT NOCOPY varchar2,
                                         P_char IN  varchar)
  Is
  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
  Begin
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
  END validate_attribute4;

   PROCEDURE validate_attribute5(x_return_status OUT NOCOPY varchar2,
                                         P_char IN  varchar)
  Is
  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
  Begin
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
  END validate_attribute5;

   PROCEDURE validate_attribute6(x_return_status OUT NOCOPY varchar2,
                                         P_char IN  varchar)
  Is
  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
  Begin
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
  END validate_attribute6;

   PROCEDURE validate_attribute7(x_return_status OUT NOCOPY varchar2,
                                         P_char IN  varchar)
  Is
  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
  Begin
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
  END validate_attribute7;

   PROCEDURE validate_attribute8(x_return_status OUT NOCOPY varchar2,
                                         P_char IN  varchar)
  Is
  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
  Begin
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
  END validate_attribute8;

   PROCEDURE validate_attribute9(x_return_status OUT NOCOPY varchar2,
                                         P_char IN  varchar)
  Is
  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
  Begin
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
  END validate_attribute9;

   PROCEDURE validate_attribute10(x_return_status OUT NOCOPY varchar2,
                                         P_char IN  varchar)
  Is
  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
  Begin
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
  END validate_attribute10;

   PROCEDURE validate_attribute11(x_return_status OUT NOCOPY varchar2,
                                         P_char IN  varchar)
  Is
  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
  Begin
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
  END validate_attribute11;

   PROCEDURE validate_attribute12(x_return_status OUT NOCOPY varchar2,
                                         P_char IN  varchar)
  Is
  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
  Begin
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
  END validate_attribute12;

   PROCEDURE validate_attribute13(x_return_status OUT NOCOPY varchar2,
                                         P_char IN  varchar)
  Is
  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
  Begin
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
  END validate_attribute13;

   PROCEDURE validate_attribute14(x_return_status OUT NOCOPY varchar2,
                                         P_char IN  varchar)
  Is
  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
  Begin
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
  END validate_attribute14;

   PROCEDURE validate_attribute15(x_return_status OUT NOCOPY varchar2,
                                         P_char IN  varchar)
  Is
  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
  Begin
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
  END validate_attribute15;

   PROCEDURE validate_active_flag(x_return_status OUT NOCOPY varchar2,
                                         P_char IN  varchar)
  Is
  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
  Begin
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
  END validate_active_flag;

  PROCEDURE validate_list_type_code(x_return_status OUT NOCOPY varchar2,
                                         P_char IN  varchar)
  Is
  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
  Begin
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
  END validate_list_type_code;

    PROCEDURE val_QUAL_ATT_VAL_FRM(x_return_status OUT NOCOPY varchar2,
                                         P_char IN  varchar)
  Is
  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
  Begin
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
  END val_QUAL_ATT_VAL_FRM;

   PROCEDURE val_QUAL_ATT_VAL_TO(x_return_status OUT NOCOPY varchar2,
                                         P_char IN  varchar)
  Is
  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
  Begin
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
  END val_QUAL_ATT_VAL_TO;




  --------------------------------------------------
  -- Validate_Attributes for:OKS_QUALIFIERS_V--
  --------------------------------------------------
/*
  FUNCTION Validate_Attributes (
    p_quav_rec IN  quav_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    IF p_quav_rec.id = OKC_API.G_MISS_NUM OR
       p_quav_rec.id IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'id');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_quav_rec.object_version_number = OKC_API.G_MISS_NUM OR
          p_quav_rec.object_version_number IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'object_version_number');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_quav_rec.cle_id = OKC_API.G_MISS_NUM OR
          p_quav_rec.cle_id IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'cle_id');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_quav_rec.date_billed_from = OKC_API.G_MISS_DATE OR
          p_quav_rec.date_billed_from IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'date_billed_from');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_quav_rec.date_billed_to = OKC_API.G_MISS_DATE OR
          p_quav_rec.date_billed_to IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'date_billed_to');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_return_status);
  END Validate_Attributes;
  */

FUNCTION Validate_Attributes (
    p_quav_rec IN  quav_rec_type
  )
  Return VARCHAR2 Is
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    x_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

  Begin
  -- call OKC_UTIL.ADD_VIEW to prepare the PL/SQL table to hold columns of view

    OKC_UTIL.ADD_VIEW('OKS_QUALIFIERS_V',x_return_status);

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
   validate_qual_id(x_return_status, p_quav_rec.qualifier_id);

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

    validate_creation_date(x_return_status, p_quav_rec.creation_date);

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

    validate_created_by(x_return_status, p_quav_rec.created_by);

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


    validate_last_update_date(x_return_status, p_quav_rec.last_update_date);

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

    validate_last_update_by(x_return_status, p_quav_rec.last_updated_by);

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

     validate_qual_group_no(x_return_status, p_quav_rec.qualifier_grouping_no);

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

    validate_qual_context(x_return_status, p_quav_rec.qualifier_context);

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


     validate_qual_attribute(x_return_status, p_quav_rec.qualifier_attribute);

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


     validate_qual_attr_value(x_return_status, p_quav_rec.qualifier_attr_value);

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

      validate_COMP_OPER_CODE(x_return_status, p_quav_rec.COMPARISON_OPERATOR_CODE);

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

    validate_excluder_Flag(x_return_status, p_quav_rec.excluder_Flag);

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

     validate_qual_rule_id(x_return_status, p_quav_rec.qualifier_rule_id);

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

     validate_start_date_active(x_return_status, p_quav_rec.start_date_active);

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

     validate_end_date_active(x_return_status, p_quav_rec.end_date_active);

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

     validate_created_from_rule_id(x_return_status, p_quav_rec.created_from_rule_id);

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

     validate_qual_precedence(x_return_status, p_quav_rec.qualifier_precedence);

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

     validate_list_header_id(x_return_status, p_quav_rec.list_header_id);

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


     validate_list_line_id(x_return_status, p_quav_rec.list_line_id);

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

     validate_qual_datatype(x_return_status, p_quav_rec.qualifier_datatype);

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

     validate_qual_attr_value_to(x_return_status, p_quav_rec.qualifier_attr_value_to);

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


     validate_context(x_return_status, p_quav_rec.context);

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

     validate_attribute1(x_return_status, p_quav_rec.attribute1);

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

     validate_attribute2(x_return_status, p_quav_rec.attribute2);

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

     validate_attribute3(x_return_status, p_quav_rec.attribute3);

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

     validate_attribute4(x_return_status, p_quav_rec.attribute4);

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

    validate_attribute5(x_return_status, p_quav_rec.attribute5);

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

     validate_attribute6(x_return_status, p_quav_rec.attribute6);

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

     validate_attribute7(x_return_status, p_quav_rec.attribute7);

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

     validate_attribute8(x_return_status, p_quav_rec.attribute8);

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

    validate_attribute9(x_return_status, p_quav_rec.attribute9);

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

     validate_attribute10(x_return_status, p_quav_rec.attribute10);

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


       validate_attribute11(x_return_status, p_quav_rec.attribute11);

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

     validate_attribute12(x_return_status, p_quav_rec.attribute12);

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

     validate_attribute13(x_return_status, p_quav_rec.attribute13);

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

     validate_attribute14(x_return_status, p_quav_rec.attribute14);

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

     validate_attribute15(x_return_status, p_quav_rec.attribute15);

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

      validate_active_flag(x_return_status, p_quav_rec.active_flag);

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


     validate_list_type_code(x_return_status, p_quav_rec.list_type_code);

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

      val_QUAL_ATT_VAL_FRM(x_return_status, p_quav_rec.QUAL_ATTR_VALUE_FROM_NUMBER);

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

      val_QUAL_ATT_VAL_TO(x_return_status, p_quav_rec.QUAL_ATTR_VALUE_TO_NUMBER);

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

        RAISE G_EXCEPTION_HALT_VALIDATION;
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

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Record
  ---------------------------------------------------------------------------
  ----------------------------------------------
  -- Validate_Record for:OKS_QUALIFIERS_V --
  ----------------------------------------------
  FUNCTION Validate_Record (
    p_quav_rec IN quav_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    ------------------------------------
    -- FUNCTION validate_foreign_keys --
    ------------------------------------
    FUNCTION validate_foreign_keys (
      p_quav_rec IN quav_rec_type
    ) RETURN VARCHAR2 IS
      item_not_found_error          EXCEPTION;
/*
      CURSOR okc_quav_pk_csr (p_id                 IN NUMBER) IS
      SELECT
 	QUALIFIER_RULE_ID  ,
 	CREATION_DATE      ,
 	CREATED_BY         ,
 	LAST_UPDATE_DATE       ,
 	LAST_UPDATED_BY        ,
 	PROGRAM_APPLICATION_ID ,
 	PROGRAM_ID             ,
 	PROGRAM_UPDATE_DATE    ,
 	REQUEST_ID             ,
 	LAST_UPDATE_LOGIN  ,
 	NAME               ,
 	DESCRIPTION        ,
 	CONTEXT            ,
 	ATTRIBUTE1         ,
 	ATTRIBUTE2         ,
 	ATTRIBUTE3         ,
 	ATTRIBUTE4         ,
 	ATTRIBUTE5         ,
 	ATTRIBUTE6         ,
 	ATTRIBUTE7         ,
 	ATTRIBUTE8         ,
 	ATTRIBUTE9         ,
 	ATTRIBUTE10        ,
 	ATTRIBUTE11        ,
 	ATTRIBUTE12        ,
 	ATTRIBUTE13        ,
 	ATTRIBUTE14        ,
 	ATTRIBUTE15
        FROM Oks_QUALIFIER_RULES_V
       WHERE OKS_QUALIFIER_RULES_V.qualifier_rule_id = p_id;
      l_okc_quav_pk                  okc_quav_pk_csr%ROWTYPE;
*/
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
      l_row_notfound                 BOOLEAN := TRUE;
    BEGIN
      l_return_status                 := OKC_API.G_RET_STS_SUCCESS;
/*
      IF (p_quav_rec.QUALIFIER_RULE_ID IS NOT NULL)
      THEN
        OPEN okc_quav_pk_csr(p_quav_rec.QUALIFIER_RULE_ID);
        FETCH okc_quav_pk_csr INTO l_okc_quav_pk;
        l_row_notfound := okc_quav_pk_csr%NOTFOUND;
        CLOSE okc_quav_pk_csr;
        IF (l_row_notfound) THEN
          OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'QUALIFIER_RULE_ID');
          RAISE item_not_found_error;
        END IF;
      END IF;
*/
      RETURN (l_return_status);
    EXCEPTION
      WHEN item_not_found_error THEN
        l_return_status := OKC_API.G_RET_STS_ERROR;
        RETURN (l_return_status);
    END validate_foreign_keys;
  BEGIN
    l_return_status := validate_foreign_keys (p_quav_rec);
    RETURN (l_return_status);
  END Validate_Record;

  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from	IN quav_rec_type,
    p_to	OUT NOCOPY qua_rec_type
  ) IS
  BEGIN

 p_to.QUALIFIER_ID      := p_from.QUALIFIER_ID    ;
 p_to.CREATION_DATE     := p_from.CREATION_DATE   ;
 p_to.CREATED_BY        := p_from.CREATED_BY      ;
 p_to.LAST_UPDATE_DATE  := p_from.LAST_UPDATE_DATE;
 p_to.LAST_UPDATED_BY   := p_from.LAST_UPDATED_BY ;
 p_to.REQUEST_ID        := p_from.REQUEST_ID      ;
 p_to.PROGRAM_APPLICATION_ID  := p_from.PROGRAM_APPLICATION_ID ;
 p_to.PROGRAM_ID              := p_from.PROGRAM_ID             ;
 p_to.PROGRAM_UPDATE_DATE     := p_from.PROGRAM_UPDATE_DATE    ;
 p_to.LAST_UPDATE_LOGIN       := p_from.LAST_UPDATE_LOGIN     ;
 p_to.QUALIFIER_GROUPING_NO   := p_from.QUALIFIER_GROUPING_NO;
 p_to.QUALIFIER_CONTEXT       := p_from.QUALIFIER_CONTEXT      ;
 p_to.QUALIFIER_ATTRIBUTE     := p_from.QUALIFIER_ATTRIBUTE    ;
 p_to.QUALIFIER_ATTR_VALUE    := p_from.QUALIFIER_ATTR_VALUE   ;
 p_to.COMPARISON_OPERATOR_CODE:= p_from.COMPARISON_OPERATOR_CODE;
 p_to.EXCLUDER_FLAG           := p_from.EXCLUDER_FLAG           ;
 p_to.QUALIFIER_RULE_ID       := p_from.QUALIFIER_RULE_ID       ;
 p_to.START_DATE_ACTIVE       := p_from.START_DATE_ACTIVE       ;
 p_to.END_DATE_ACTIVE         := p_from.END_DATE_ACTIVE         ;
 p_to.CREATED_FROM_RULE_ID    := p_from.CREATED_FROM_RULE_ID    ;
 p_to.QUALIFIER_PRECEDENCE := p_from.QUALIFIER_PRECEDENCE ;
 p_to.LIST_HEADER_ID       := p_from.LIST_HEADER_ID      ;
 p_to.LIST_LINE_ID         := p_from.LIST_LINE_ID         ;
 p_to.QUALIFIER_DATATYPE  := p_from.QUALIFIER_DATATYPE  ;
 p_to.QUALIFIER_ATTR_VALUE_TO  := p_from.QUALIFIER_ATTR_VALUE_TO  ;
 p_to.CONTEXT                  := p_from.CONTEXT                  ;
 p_to.ATTRIBUTE1               := p_from.ATTRIBUTE1               ;
 p_to.ATTRIBUTE2               := p_from.ATTRIBUTE2               ;
 p_to.ATTRIBUTE3               := p_from.ATTRIBUTE3               ;
 p_to.ATTRIBUTE4               := p_from.ATTRIBUTE4               ;
 p_to.ATTRIBUTE5               := p_from.ATTRIBUTE5               ;
 p_to.ATTRIBUTE6               := p_from.ATTRIBUTE6               ;
 p_to.ATTRIBUTE7               := p_from.ATTRIBUTE7               ;
 p_to.ATTRIBUTE8               := p_from.ATTRIBUTE8               ;
 p_to.ATTRIBUTE9               := p_from.ATTRIBUTE9               ;
 p_to.ATTRIBUTE10              := p_from.ATTRIBUTE10              ;
 p_to.ATTRIBUTE11              := p_from.ATTRIBUTE11              ;
 p_to.ATTRIBUTE12              := p_from.ATTRIBUTE12              ;
 p_to.ATTRIBUTE13              := p_from.ATTRIBUTE13              ;
 p_to.ATTRIBUTE14              := p_from.ATTRIBUTE14  ;
 p_to.ATTRIBUTE15             := p_from.ATTRIBUTE15 ;
 p_to.ACTIVE_FLAG            := p_from.ACTIVE_FLAG  ;
 p_to.LIST_TYPE_CODE        := p_from.LIST_TYPE_CODE;
 p_to.QUAL_ATTR_VALUE_FROM_NUMBER  := p_from.QUAL_ATTR_VALUE_FROM_NUMBER ;
 p_to.QUAL_ATTR_VALUE_TO_NUMBER    := p_from.QUAL_ATTR_VALUE_TO_NUMBER   ;


  END migrate;

  PROCEDURE migrate (
    p_from	IN qua_rec_type,
    p_to	OUT NOCOPY quav_rec_type
  ) IS
  BEGIN
 p_to.QUALIFIER_ID      := p_from.QUALIFIER_ID    ;
 p_to.CREATION_DATE     := p_from.CREATION_DATE   ;
 p_to.CREATED_BY        := p_from.CREATED_BY      ;
 p_to.LAST_UPDATE_DATE  := p_from.LAST_UPDATE_DATE;
 p_to.LAST_UPDATED_BY   := p_from.LAST_UPDATED_BY ;
 p_to.REQUEST_ID        := p_from.REQUEST_ID      ;
 p_to.PROGRAM_APPLICATION_ID  := p_from.PROGRAM_APPLICATION_ID ;
 p_to.PROGRAM_ID              := p_from.PROGRAM_ID             ;
 p_to.PROGRAM_UPDATE_DATE     := p_from.PROGRAM_UPDATE_DATE    ;
 p_to.LAST_UPDATE_LOGIN       := p_from.LAST_UPDATE_LOGIN     ;
 p_to.QUALIFIER_GROUPING_NO   := p_from.QUALIFIER_GROUPING_NO;
 p_to.QUALIFIER_CONTEXT       := p_from.QUALIFIER_CONTEXT      ;
 p_to.QUALIFIER_ATTRIBUTE     := p_from.QUALIFIER_ATTRIBUTE    ;
 p_to.QUALIFIER_ATTR_VALUE    := p_from.QUALIFIER_ATTR_VALUE   ;
 p_to.COMPARISON_OPERATOR_CODE:= p_from.COMPARISON_OPERATOR_CODE;
 p_to.EXCLUDER_FLAG           := p_from.EXCLUDER_FLAG           ;
 p_to.QUALIFIER_RULE_ID       := p_from.QUALIFIER_RULE_ID       ;
 p_to.START_DATE_ACTIVE       := p_from.START_DATE_ACTIVE       ;
 p_to.END_DATE_ACTIVE         := p_from.END_DATE_ACTIVE         ;
 p_to.CREATED_FROM_RULE_ID    := p_from.CREATED_FROM_RULE_ID    ;
 p_to.QUALIFIER_PRECEDENCE := p_from.QUALIFIER_PRECEDENCE ;
 p_to.LIST_HEADER_ID       := p_from.LIST_HEADER_ID      ;
 p_to.LIST_LINE_ID         := p_from.LIST_LINE_ID         ;
 p_to.QUALIFIER_DATATYPE  := p_from.QUALIFIER_DATATYPE  ;
 p_to.QUALIFIER_ATTR_VALUE_TO  := p_from.QUALIFIER_ATTR_VALUE_TO  ;
 p_to.CONTEXT                  := p_from.CONTEXT                  ;
 p_to.ATTRIBUTE1               := p_from.ATTRIBUTE1               ;
 p_to.ATTRIBUTE2               := p_from.ATTRIBUTE2               ;
 p_to.ATTRIBUTE3               := p_from.ATTRIBUTE3               ;
 p_to.ATTRIBUTE4               := p_from.ATTRIBUTE4               ;
 p_to.ATTRIBUTE5               := p_from.ATTRIBUTE5               ;
 p_to.ATTRIBUTE6               := p_from.ATTRIBUTE6               ;
 p_to.ATTRIBUTE7               := p_from.ATTRIBUTE7               ;
 p_to.ATTRIBUTE8               := p_from.ATTRIBUTE8               ;
 p_to.ATTRIBUTE9               := p_from.ATTRIBUTE9               ;
 p_to.ATTRIBUTE10              := p_from.ATTRIBUTE10              ;
 p_to.ATTRIBUTE11              := p_from.ATTRIBUTE11              ;
 p_to.ATTRIBUTE12              := p_from.ATTRIBUTE12              ;
 p_to.ATTRIBUTE13              := p_from.ATTRIBUTE13              ;
 p_to.ATTRIBUTE14              := p_from.ATTRIBUTE14  ;
 p_to.ATTRIBUTE15             := p_from.ATTRIBUTE15 ;
 p_to.ACTIVE_FLAG            := p_from.ACTIVE_FLAG  ;
 p_to.LIST_TYPE_CODE        := p_from.LIST_TYPE_CODE;
 p_to.QUAL_ATTR_VALUE_FROM_NUMBER  := p_from.QUAL_ATTR_VALUE_FROM_NUMBER ;
 p_to.QUAL_ATTR_VALUE_TO_NUMBER    := p_from.QUAL_ATTR_VALUE_TO_NUMBER   ;
  END migrate;

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_row
  ---------------------------------------------------------------------------
  -------------------------------------------
  -- validate_row for:OKS_QUALIFIERS_V --
  -------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_quav_rec                     IN quav_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_quav_rec                     quav_rec_type := p_quav_rec;
    l_qua_rec                      qua_rec_type;
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
    l_return_status := Validate_Attributes(l_quav_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_quav_rec);
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
  -- PL/SQL TBL validate_row for:BSLV_TBL --
  ------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_quav_tbl                     IN quav_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_quav_tbl.COUNT > 0) THEN
      i := p_quav_tbl.FIRST;
      LOOP
        validate_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_quav_rec                     => p_quav_tbl(i));
        EXIT WHEN (i = p_quav_tbl.LAST);
        i := p_quav_tbl.NEXT(i);
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
  ---------------------------------------
  -- insert_row for:OKS_QUALIFIERS --
  ---------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qua_rec                      IN qua_rec_type,
    x_qua_rec                      OUT NOCOPY qua_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'LINES_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_qua_rec                      qua_rec_type := p_qua_rec;
    l_def_qua_rec                  qua_rec_type;
    -------------------------------------------
    -- Set_Attributes for:OKS_QUALIFIER --
    -------------------------------------------
    FUNCTION Set_Attributes (
      p_qua_rec IN  qua_rec_type,
      x_qua_rec OUT NOCOPY qua_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_qua_rec := p_qua_rec;
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
      p_qua_rec,                         -- IN
      l_qua_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKS_QUALIFIERS(
 QUALIFIER_ID
 ,CREATION_DATE
 ,CREATED_BY
 ,LAST_UPDATE_DATE
 ,LAST_UPDATED_BY
 ,REQUEST_ID
 ,PROGRAM_APPLICATION_ID
 ,PROGRAM_ID
 ,PROGRAM_UPDATE_DATE
 ,LAST_UPDATE_LOGIN
 ,QUALIFIER_GROUPING_NO
 ,QUALIFIER_CONTEXT
 ,QUALIFIER_ATTRIBUTE
 ,QUALIFIER_ATTR_VALUE
 ,COMPARISON_OPERATOR_CODE
 ,EXCLUDER_FLAG
 ,QUALIFIER_RULE_ID
 ,START_DATE_ACTIVE
 ,END_DATE_ACTIVE
 ,CREATED_FROM_RULE_ID
 ,QUALIFIER_PRECEDENCE
 ,LIST_HEADER_ID
 ,LIST_LINE_ID
 ,QUALIFIER_DATATYPE
 ,QUALIFIER_ATTR_VALUE_TO
 ,CONTEXT
 ,ATTRIBUTE1
 ,ATTRIBUTE2
 ,ATTRIBUTE3
 ,ATTRIBUTE4
 ,ATTRIBUTE5
 ,ATTRIBUTE6
 ,ATTRIBUTE7
 ,ATTRIBUTE8
 ,ATTRIBUTE9
 ,ATTRIBUTE10
 ,ATTRIBUTE11
 ,ATTRIBUTE12
 ,ATTRIBUTE13
 ,ATTRIBUTE14
 ,ATTRIBUTE15
 ,ACTIVE_FLAG
 ,LIST_TYPE_CODE
 ,QUAL_ATTR_VALUE_FROM_NUMBER
 ,QUAL_ATTR_VALUE_TO_NUMBER            )
      VALUES (
 l_qua_rec.QUALIFIER_ID
 ,l_qua_rec.CREATION_DATE
 ,l_qua_rec.CREATED_BY
 ,l_qua_rec.LAST_UPDATE_DATE
 ,l_qua_rec.LAST_UPDATED_BY
 ,l_qua_rec.REQUEST_ID
 ,l_qua_rec.PROGRAM_APPLICATION_ID
 ,l_qua_rec.PROGRAM_ID
 ,l_qua_rec.PROGRAM_UPDATE_DATE
 ,l_qua_rec.LAST_UPDATE_LOGIN
 ,l_qua_rec.QUALIFIER_GROUPING_NO
 ,l_qua_rec.QUALIFIER_CONTEXT
 ,l_qua_rec.QUALIFIER_ATTRIBUTE
 ,l_qua_rec.QUALIFIER_ATTR_VALUE
 ,l_qua_rec.COMPARISON_OPERATOR_CODE
 ,l_qua_rec.EXCLUDER_FLAG
 ,l_qua_rec.QUALIFIER_RULE_ID
 ,l_qua_rec.START_DATE_ACTIVE
 ,l_qua_rec.END_DATE_ACTIVE
 ,l_qua_rec.CREATED_FROM_RULE_ID
 ,l_qua_rec.QUALIFIER_PRECEDENCE
 ,l_qua_rec.LIST_HEADER_ID
 ,l_qua_rec.LIST_LINE_ID
 ,l_qua_rec.QUALIFIER_DATATYPE
 ,l_qua_rec.QUALIFIER_ATTR_VALUE_TO
 ,l_qua_rec.CONTEXT
 ,l_qua_rec.ATTRIBUTE1
 ,l_qua_rec.ATTRIBUTE2
 ,l_qua_rec.ATTRIBUTE3
 ,l_qua_rec.ATTRIBUTE4
 ,l_qua_rec.ATTRIBUTE5
 ,l_qua_rec.ATTRIBUTE6
 ,l_qua_rec.ATTRIBUTE7
 ,l_qua_rec.ATTRIBUTE8
 ,l_qua_rec.ATTRIBUTE9
 ,l_qua_rec.ATTRIBUTE10
 ,l_qua_rec.ATTRIBUTE11
 ,l_qua_rec.ATTRIBUTE12
 ,l_qua_rec.ATTRIBUTE13
 ,l_qua_rec.ATTRIBUTE14
 ,l_qua_rec.ATTRIBUTE15
 ,l_qua_rec.ACTIVE_FLAG
 ,l_qua_rec.LIST_TYPE_CODE
 ,l_qua_rec.QUAL_ATTR_VALUE_FROM_NUMBER
 ,l_qua_rec.QUAL_ATTR_VALUE_TO_NUMBER            );
    -- Set OUT values
    x_qua_rec := l_qua_rec;
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
  -----------------------------------------
  -- insert_row for:OKS_QUALIFIERS_V --
  -----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_quav_rec                     IN quav_rec_type,
    x_quav_rec                     OUT NOCOPY quav_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_quav_rec                     quav_rec_type;
    l_def_quav_rec                 quav_rec_type;
    l_qua_rec                      qua_rec_type;
    lx_qua_rec                     qua_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_quav_rec	IN quav_rec_type
    ) RETURN quav_rec_type IS
      l_quav_rec	quav_rec_type := p_quav_rec;
    BEGIN
      l_quav_rec.CREATION_DATE := SYSDATE;
      l_quav_rec.CREATED_BY := FND_GLOBAL.USER_ID;
      l_quav_rec.LAST_UPDATE_DATE := SYSDATE;
      l_quav_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_quav_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_quav_rec);
    END fill_who_columns;
    ---------------------------------------------
    -- Set_Attributes for:OKS_QUALIFIERS_V -
    ---------------------------------------------
    FUNCTION Set_Attributes (
      p_quav_rec IN  quav_rec_type,
      x_quav_rec OUT NOCOPY quav_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_quav_rec := p_quav_rec;
      --x_quav_rec.OBJECT_VERSION_NUMBER := 1;
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
    l_quav_rec := null_out_defaults(p_quav_rec);
    -- Set primary key value
    l_quav_rec.qualifier_ID := get_seq_id;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      l_quav_rec,                        -- IN
      l_def_quav_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_quav_rec := fill_who_columns(l_def_quav_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_quav_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_quav_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_quav_rec, l_qua_rec);
    --------------------------------------------
    -- Call the INSERT_ROW for each child record
    --------------------------------------------
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_qua_rec,
      lx_qua_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_qua_rec, l_def_quav_rec);
    -- Set OUT values
    x_quav_rec := l_def_quav_rec;
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
  -- PL/SQL TBL insert_row for:BSLV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_quav_tbl                     IN quav_tbl_type,
    x_quav_tbl                     OUT NOCOPY quav_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_quav_tbl.COUNT > 0) THEN
      i := p_quav_tbl.FIRST;
      LOOP
        insert_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_quav_rec                     => p_quav_tbl(i),
          x_quav_rec                     => x_quav_tbl(i));
        EXIT WHEN (i = p_quav_tbl.LAST);
        i := p_quav_tbl.NEXT(i);
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
  -------------------------------------
  -- lock_row for:OKS_QUALIFIER --
  -------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qua_rec                      IN qua_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);

    CURSOR  lchk_csr (p_qua_rec IN qua_rec_type) IS
    SELECT qualifier_id
      FROM OKS_QUALIFIERS
    WHERE QUALIFIER_ID = p_qua_rec.qualifier_id;
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'LINES_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_qualifier_id       OKS_QUALIFIERS.qualifier_id%TYPE;
    lc_qualifier_id      OKS_QUALIFIERS.qualifier_id%TYPE;
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

      OPEN lchk_csr(p_qua_rec);
      FETCH lchk_csr INTO lc_qualifier_id;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    IF (lc_row_notfound) THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_qualifier_id <> p_qua_rec.qualifier_id THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_qualifier_id = -1 THEN
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
  ---------------------------------------
  -- lock_row for:OKS_QUALIFIERS_V --
  ---------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_quav_rec                     IN quav_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_qua_rec                      qua_rec_type;
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
    migrate(p_quav_rec, l_qua_rec);
    --------------------------------------------
    -- Call the LOCK_ROW for each child record
    --------------------------------------------
    lock_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_qua_rec
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
  -- PL/SQL TBL lock_row for:BSLV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_quav_tbl                     IN quav_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_quav_tbl.COUNT > 0) THEN
      i := p_quav_tbl.FIRST;
      LOOP
        lock_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_quav_rec                     => p_quav_tbl(i));
        EXIT WHEN (i = p_quav_tbl.LAST);
        i := p_quav_tbl.NEXT(i);
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
  ---------------------------------------
  -- update_row for:OKS_QUALIFIERS --
  ---------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qua_rec                      IN qua_rec_type,
    x_qua_rec                      OUT NOCOPY qua_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'LINES_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_qua_rec                      qua_rec_type := p_qua_rec;
    l_def_qua_rec                  qua_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_qua_rec	IN qua_rec_type,
      x_qua_rec	OUT NOCOPY qua_rec_type
    ) RETURN VARCHAR2 IS
      l_qua_rec                      qua_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_qua_rec := p_qua_rec;
      -- Get current database values
      l_qua_rec := get_rec(p_qua_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_qua_rec.qualifier_id = OKC_API.G_MISS_NUM)
        OR (x_qua_rec.qualifier_id IS NULL)
      THEN
        x_qua_rec.qualifier_id := l_qua_rec.qualifier_id;
      END IF;
      IF (x_qua_rec.creation_date = OKC_API.G_MISS_DATE)
        OR (x_qua_rec.creation_date IS NULL)
      THEN
        x_qua_rec.creation_date := l_qua_rec.creation_date;
      END IF;
      IF (x_qua_rec.created_by = OKC_API.G_MISS_NUM)
        OR (x_qua_rec.created_by IS NULL)
      THEN
        x_qua_rec.created_by := l_qua_rec.created_by;
      END IF;
      IF (x_qua_rec.last_update_date = OKC_API.G_MISS_DATE)
        OR (x_qua_rec.last_update_date IS NULL)
      THEN
        x_qua_rec.last_update_date := l_qua_rec.last_update_date;
      END IF;
      IF (x_qua_rec.last_updated_BY = OKC_API.G_MISS_NUM)
        OR (x_qua_rec.last_updated_by IS NULL)
      THEN
        x_qua_rec.last_updated_BY := l_qua_rec.last_updated_BY;
      END IF;
      IF (x_qua_rec.qualifier_grouping_no = OKC_API.G_MISS_NUM)
        OR (x_qua_rec.qualifier_grouping_no IS NULL)
      THEN
        x_qua_rec.qualifier_grouping_no := l_qua_rec.qualifier_grouping_no;
      END IF;
      IF (x_qua_rec.qualifier_context = OKC_API.G_MISS_CHAR)
        OR (x_qua_rec.qualifier_context IS NULL)
      THEN
        x_qua_rec.qualifier_context := l_qua_rec.qualifier_context;
      END IF;
      IF (x_qua_rec.qualifier_attribute = OKC_API.G_MISS_CHAR)
        OR (x_qua_rec.qualifier_attribute IS NULL)
      THEN
        x_qua_rec.qualifier_attribute := l_qua_rec.qualifier_attribute;
      END IF;
      IF (x_qua_rec.qualifier_attr_value = OKC_API.G_MISS_CHAR)
        OR (x_qua_rec.qualifier_attr_value IS NULL)
      THEN
        x_qua_rec.qualifier_attr_value := l_qua_rec.qualifier_attr_value;
      END IF;
      IF (x_qua_rec.COMPARISON_OPERATOR_CODE = OKC_API.G_MISS_CHAR)
        OR (x_qua_rec.COMPARISON_OPERATOR_CODE IS NULL)
      THEN
        x_qua_rec.COMPARISON_OPERATOR_CODE := l_qua_rec.COMPARISON_OPERATOR_CODE;
      END IF;
      IF (x_qua_rec.excluder_flag = OKC_API.G_MISS_CHAR)
        OR (x_qua_rec.excluder_flag IS NULL)
      THEN
        x_qua_rec.excluder_flag := l_qua_rec.excluder_flag;
      END IF;
      IF (x_qua_rec.qualifier_rule_id = OKC_API.G_MISS_NUM)
        OR (x_qua_rec.qualifier_rule_id IS NULL)
      THEN
        x_qua_rec.qualifier_rule_id := l_qua_rec.qualifier_rule_id;
      END IF;
      IF (x_qua_rec.start_date_active = OKC_API.G_MISS_DATE)
        OR (x_qua_rec.start_date_active IS NULL)
      THEN
        x_qua_rec.start_date_active := l_qua_rec.start_date_active;
      END IF;
      IF (x_qua_rec.end_date_active = OKC_API.G_MISS_DATE)
        OR (x_qua_rec.end_date_active IS NULL)
      THEN
        x_qua_rec.end_date_active := l_qua_rec.end_date_active;
      END IF;
      IF (x_qua_rec.created_from_rule_id = OKC_API.G_MISS_NUM)
        OR (x_qua_rec.created_from_rule_id IS NULL)
      THEN
        x_qua_rec.created_from_rule_id := l_qua_rec.created_from_rule_id;
      END IF;
      IF (x_qua_rec.qualifier_precedence = OKC_API.G_MISS_NUM)
        OR (x_qua_rec.qualifier_precedence IS NULL)
      THEN
        x_qua_rec.qualifier_precedence := l_qua_rec.qualifier_precedence;
      END IF;
      IF (x_qua_rec.list_header_id = OKC_API.G_MISS_NUM)
        OR (x_qua_rec.list_header_id IS NULL)
      THEN
        x_qua_rec.list_header_id := l_qua_rec.list_header_id;
      END IF;
      IF (x_qua_rec.list_line_id = OKC_API.G_MISS_NUM)
        OR (x_qua_rec.list_line_id IS NULL)
      THEN
        x_qua_rec.list_line_id := l_qua_rec.list_line_id;
      END IF;
      IF (x_qua_rec.qualifier_datatype = OKC_API.G_MISS_CHAR)
        OR (x_qua_rec.qualifier_datatype IS NULL)
      THEN
        x_qua_rec.qualifier_datatype := l_qua_rec.qualifier_datatype;
      END IF;
      IF (x_qua_rec.qualifier_attr_value_to = OKC_API.G_MISS_CHAR)
        OR (x_qua_rec.qualifier_attr_value_to IS NULL)
      THEN
        x_qua_rec.qualifier_attr_value_to := l_qua_rec.qualifier_attr_value_to;
      END IF;
      IF (x_qua_rec.context = OKC_API.G_MISS_CHAR)
        OR (x_qua_rec.context IS NULL)
      THEN
        x_qua_rec.context := l_qua_rec.context;
      END IF;
      IF (x_qua_rec.attribute1 = OKC_API.G_MISS_CHAR)
        OR (x_qua_rec.attribute1 IS NULL)
      THEN
        x_qua_rec.attribute1 := l_qua_rec.attribute1;
      END IF;
      IF (x_qua_rec.attribute2 = OKC_API.G_MISS_CHAR)
        OR (x_qua_rec.attribute2 IS NULL)
      THEN
        x_qua_rec.attribute2 := l_qua_rec.attribute2;
      END IF;
      IF (x_qua_rec.attribute3 = OKC_API.G_MISS_CHAR)
        OR (x_qua_rec.attribute3 IS NULL)
      THEN
        x_qua_rec.attribute3 := l_qua_rec.attribute3;
      END IF;
      IF (x_qua_rec.attribute4 = OKC_API.G_MISS_CHAR)
        OR (x_qua_rec.attribute4 IS NULL)
      THEN
        x_qua_rec.attribute4 := l_qua_rec.attribute4;
      END IF;
      IF (x_qua_rec.attribute5 = OKC_API.G_MISS_CHAR)
        OR (x_qua_rec.attribute5 IS NULL)
      THEN
        x_qua_rec.attribute5 := l_qua_rec.attribute5;
      END IF;
      IF (x_qua_rec.attribute6 = OKC_API.G_MISS_CHAR)
        OR (x_qua_rec.attribute6 IS NULL)
      THEN
        x_qua_rec.attribute6 := l_qua_rec.attribute6;
      END IF;
      IF (x_qua_rec.attribute7 = OKC_API.G_MISS_CHAR)
        OR (x_qua_rec.attribute7 IS NULL)
      THEN
        x_qua_rec.attribute7 := l_qua_rec.attribute7;
      END IF;
      IF (x_qua_rec.attribute8 = OKC_API.G_MISS_CHAR)
        OR (x_qua_rec.attribute8 IS NULL)
      THEN
        x_qua_rec.attribute8 := l_qua_rec.attribute8;
      END IF;
      IF (x_qua_rec.attribute9 = OKC_API.G_MISS_CHAR)
        OR (x_qua_rec.attribute9 IS NULL)
      THEN
        x_qua_rec.attribute9 := l_qua_rec.attribute9;
      END IF;
      IF (x_qua_rec.attribute10 = OKC_API.G_MISS_CHAR)
        OR (x_qua_rec.attribute10 IS NULL)
      THEN
        x_qua_rec.attribute10 := l_qua_rec.attribute10;
      END IF;
      IF (x_qua_rec.attribute11 = OKC_API.G_MISS_CHAR)
        OR (x_qua_rec.attribute11 IS NULL)
      THEN
        x_qua_rec.attribute11 := l_qua_rec.attribute11;
      END IF;
      IF (x_qua_rec.attribute12 = OKC_API.G_MISS_CHAR)
        OR (x_qua_rec.attribute12 IS NULL)
      THEN
        x_qua_rec.attribute12 := l_qua_rec.attribute12;
      END IF;
      IF (x_qua_rec.attribute13 = OKC_API.G_MISS_CHAR)
        OR (x_qua_rec.attribute13 IS NULL)
      THEN
        x_qua_rec.attribute13 := l_qua_rec.attribute13;
      END IF;
      IF (x_qua_rec.attribute14 = OKC_API.G_MISS_CHAR)
        OR (x_qua_rec.attribute14 IS NULL)
      THEN
        x_qua_rec.attribute14 := l_qua_rec.attribute14;
      END IF;
      IF (x_qua_rec.attribute15 = OKC_API.G_MISS_CHAR)
        OR (x_qua_rec.attribute15 IS NULL)
      THEN
        x_qua_rec.attribute15 := l_qua_rec.attribute15;
      END IF;
      IF (x_qua_rec.active_flag = OKC_API.G_MISS_CHAR)
        OR (x_qua_rec.active_flag IS NULL)
      THEN
        x_qua_rec.active_flag := l_qua_rec.active_flag;
      END IF;
      IF (x_qua_rec.list_type_code = OKC_API.G_MISS_CHAR)
        OR (x_qua_rec.list_type_code IS NULL)
      THEN
        x_qua_rec.list_type_code := l_qua_rec.list_type_code;
      END IF;
      IF (x_qua_rec.QUAL_ATTR_VALUE_FROM_NUMBER = OKC_API.G_MISS_NUM)
        OR (x_qua_rec.QUAL_ATTR_VALUE_FROM_NUMBER IS NULL)
      THEN
        x_qua_rec.QUAL_ATTR_VALUE_FROM_NUMBER := l_qua_rec.QUAL_ATTR_VALUE_FROM_NUMBER;
      END IF;
      IF (x_qua_rec.QUAL_ATTR_VALUE_TO_NUMBER = OKC_API.G_MISS_NUM)
        OR (x_qua_rec.QUAL_ATTR_VALUE_TO_NUMBER IS NULL)
      THEN
        x_qua_rec.QUAL_ATTR_VALUE_TO_NUMBER := l_qua_rec.QUAL_ATTR_VALUE_TO_NUMBER;
      END IF;


      RETURN(l_return_status);
    END populate_new_record;
    -------------------------------------------
    -- Set_Attributes for:OKS_QUALIFIERS --
    -------------------------------------------
    FUNCTION Set_Attributes (
      p_qua_rec IN  qua_rec_type,
      x_qua_rec OUT NOCOPY qua_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_qua_rec := p_qua_rec;
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
      p_qua_rec,                         -- IN
      l_qua_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_qua_rec, l_def_qua_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKS_QUALIFIERS
    SET
 QUALIFIER_ID =                   l_def_qua_rec.QUALIFIER_ID   ,
 CREATION_DATE      =            l_def_qua_rec.CREATION_DATE   ,
 CREATED_BY         = l_def_qua_rec.CREATED_BY       ,
 LAST_UPDATE_DATE   = l_def_qua_rec.LAST_UPDATE_DATE ,
 LAST_UPDATED_BY    = l_def_qua_rec.LAST_UPDATED_BY   ,
 REQUEST_ID                  = l_def_qua_rec.REQUEST_ID        ,
 PROGRAM_APPLICATION_ID      = l_def_qua_rec.PROGRAM_APPLICATION_ID ,
 PROGRAM_ID                 = l_def_qua_rec.PROGRAM_ID              ,
 PROGRAM_UPDATE_DATE       = l_def_qua_rec.PROGRAM_UPDATE_DATE     ,
 LAST_UPDATE_LOGIN         = l_def_qua_rec.LAST_UPDATE_LOGIN       ,
 QUALIFIER_GROUPING_NO     = l_def_qua_rec.QUALIFIER_GROUPING_NO   ,
 QUALIFIER_CONTEXT         = l_def_qua_rec.QUALIFIER_CONTEXT  ,
 QUALIFIER_ATTRIBUTE       = l_def_qua_rec.QUALIFIER_ATTRIBUTE,
 QUALIFIER_ATTR_VALUE      = l_def_qua_rec.QUALIFIER_ATTR_VALUE,
 COMPARISON_OPERATOR_CODE  = l_def_qua_rec.COMPARISON_OPERATOR_CODE  ,
 EXCLUDER_FLAG             = l_def_qua_rec.EXCLUDER_FLAG             ,
 QUALIFIER_RULE_ID         = l_def_qua_rec.QUALIFIER_RULE_ID  ,
 START_DATE_ACTIVE        =  l_def_qua_rec.START_DATE_ACTIVE       ,
 END_DATE_ACTIVE          = l_def_qua_rec.END_DATE_ACTIVE         ,
 CREATED_FROM_RULE_ID     = l_def_qua_rec.CREATED_FROM_RULE_ID   ,
 QUALIFIER_PRECEDENCE     = l_def_qua_rec.QUALIFIER_PRECEDENCE   ,
 LIST_HEADER_ID           = l_def_qua_rec.LIST_HEADER_ID         ,
 LIST_LINE_ID             = l_def_qua_rec.LIST_LINE_ID           ,
 QUALIFIER_DATATYPE       = l_def_qua_rec.QUALIFIER_DATATYPE     ,
 QUALIFIER_ATTR_VALUE_TO  = l_def_qua_rec.QUALIFIER_ATTR_VALUE_TO ,
 CONTEXT                  =  l_def_qua_rec.CONTEXT     ,
 ATTRIBUTE1               = l_def_qua_rec.ATTRIBUTE1   ,
 ATTRIBUTE2               = l_def_qua_rec.ATTRIBUTE2    ,
 ATTRIBUTE3               = l_def_qua_rec.ATTRIBUTE3    ,
 ATTRIBUTE4               = l_def_qua_rec.ATTRIBUTE4    ,
 ATTRIBUTE5               = l_def_qua_rec.ATTRIBUTE5    ,
 ATTRIBUTE6               = l_def_qua_rec.ATTRIBUTE6       ,
 ATTRIBUTE7               = l_def_qua_rec.ATTRIBUTE7           ,
 ATTRIBUTE8               = l_def_qua_rec.ATTRIBUTE8           ,
 ATTRIBUTE9               = l_def_qua_rec.ATTRIBUTE9            ,
 ATTRIBUTE10              = l_def_qua_rec.ATTRIBUTE10           ,
 ATTRIBUTE11              = l_def_qua_rec.ATTRIBUTE11          ,
 ATTRIBUTE12                     = l_def_qua_rec.ATTRIBUTE12          ,
 ATTRIBUTE13                     = l_def_qua_rec.ATTRIBUTE13          ,
 ATTRIBUTE14              = l_def_qua_rec.ATTRIBUTE14                 ,
 ATTRIBUTE15             = l_def_qua_rec.ATTRIBUTE15                ,
 ACTIVE_FLAG             = l_def_qua_rec.ACTIVE_FLAG               ,
 LIST_TYPE_CODE          = l_def_qua_rec.LIST_TYPE_CODE           ,
 QUAL_ATTR_VALUE_FROM_NUMBER           = l_def_qua_rec.QUAL_ATTR_VALUE_FROM_NUMBER          ,
 QUAL_ATTR_VALUE_TO_NUMBER             = l_def_qua_rec.QUAL_ATTR_VALUE_TO_NUMBER
 WHere qualifier_id = l_def_qua_rec.qualifier_id;

    x_qua_rec := l_def_qua_rec;
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
  -----------------------------------------
  -- update_row for:OKS_qualifier_v --
  -----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_quav_rec                     IN quav_rec_type,
    x_quav_rec                     OUT NOCOPY quav_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_quav_rec                     quav_rec_type := p_quav_rec;
    l_def_quav_rec                 quav_rec_type;
    l_qua_rec                      qua_rec_type;
    lx_qua_rec                     qua_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_quav_rec	IN quav_rec_type
    ) RETURN quav_rec_type IS
      l_quav_rec	quav_rec_type := p_quav_rec;
    BEGIN
      l_quav_rec.LAST_UPDATE_DATE := SYSDATE;
      l_quav_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_quav_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_quav_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_quav_rec	IN quav_rec_type,
      x_quav_rec	OUT NOCOPY quav_rec_type
    ) RETURN VARCHAR2 IS
      l_quav_rec                     quav_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_quav_rec := p_quav_rec;
      -- Get current database values
      l_quav_rec := get_rec(p_quav_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_quav_rec.qualifier_id = OKC_API.G_MISS_NUM)
        OR (x_quav_rec.qualifier_id IS NULL)
      THEN
        x_quav_rec.qualifier_id := l_quav_rec.qualifier_id;
      END IF;
       IF (x_quav_rec.created_by = OKC_API.G_MISS_NUM)
        OR (x_quav_rec.created_by IS NULL)
      THEN
        x_quav_rec.created_by := l_quav_rec.created_by;
      END IF;
      IF (x_quav_rec.creation_date = OKC_API.G_MISS_DATE)
        OR (x_quav_rec.creation_date IS NULL)
      THEN
        x_quav_rec.creation_date := l_quav_rec.creation_date;
      END IF;
      IF (x_quav_rec.last_updated_by = OKC_API.G_MISS_NUM)
        OR (x_quav_rec.last_updated_by IS NULL)
      THEN
        x_quav_rec.last_updated_by := l_quav_rec.last_updated_by;
      END IF;
      IF (x_quav_rec.last_update_date = OKC_API.G_MISS_DATE)
        OR (x_quav_rec.last_update_date IS NULL)
      THEN
        x_quav_rec.last_update_date := l_quav_rec.last_update_date;
      END IF;
        IF (x_quav_rec.attribute1 = OKC_API.G_MISS_CHAR)
        OR (x_quav_rec.attribute1 IS NULL)
      THEN
        x_quav_rec.attribute1 := l_quav_rec.attribute1;
      END IF;
      IF (x_quav_rec.attribute2 = OKC_API.G_MISS_CHAR)
        OR (x_quav_rec.attribute2 IS NULL)
      THEN
        x_quav_rec.attribute2 := l_quav_rec.attribute2;
      END IF;
      IF (x_quav_rec.attribute3 = OKC_API.G_MISS_CHAR)
        OR (x_quav_rec.attribute3 IS NULL)
      THEN
        x_quav_rec.attribute3 := l_quav_rec.attribute3;
      END IF;
      IF (x_quav_rec.attribute4 = OKC_API.G_MISS_CHAR)
        OR (x_quav_rec.attribute4 IS NULL)
      THEN
        x_quav_rec.attribute4 := l_quav_rec.attribute4;
      END IF;
      IF (x_quav_rec.attribute5 = OKC_API.G_MISS_CHAR)
        OR (x_quav_rec.attribute5 IS NULL)
      THEN
        x_quav_rec.attribute5 := l_quav_rec.attribute5;
      END IF;
      IF (x_quav_rec.attribute6 = OKC_API.G_MISS_CHAR)
        OR (x_quav_rec.attribute6 IS NULL)
      THEN
        x_quav_rec.attribute6 := l_quav_rec.attribute6;
      END IF;
      IF (x_quav_rec.attribute7 = OKC_API.G_MISS_CHAR)
        OR (x_quav_rec.attribute7 IS NULL)
      THEN
        x_quav_rec.attribute7 := l_quav_rec.attribute7;
      END IF;
      IF (x_quav_rec.attribute8 = OKC_API.G_MISS_CHAR)
        OR (x_quav_rec.attribute8 IS NULL)
      THEN
        x_quav_rec.attribute8 := l_quav_rec.attribute8;
      END IF;
        IF (x_quav_rec.attribute9 = OKC_API.G_MISS_CHAR)
        OR (x_quav_rec.attribute9 IS NULL)
      THEN
        x_quav_rec.attribute9 := l_quav_rec.attribute9;
      END IF;
      IF (x_quav_rec.attribute10 = OKC_API.G_MISS_CHAR)
        OR (x_quav_rec.attribute10 IS NULL)
      THEN
        x_quav_rec.attribute10 := l_quav_rec.attribute10;
      END IF;
      IF (x_quav_rec.attribute11 = OKC_API.G_MISS_CHAR)
        OR (x_quav_rec.attribute11 IS NULL)
      THEN
        x_quav_rec.attribute11 := l_quav_rec.attribute11;
      END IF;
      IF (x_quav_rec.attribute12 = OKC_API.G_MISS_CHAR)
        OR (x_quav_rec.attribute12 IS NULL)
      THEN
        x_quav_rec.attribute12 := l_quav_rec.attribute12;
      END IF;
      IF (x_quav_rec.attribute13 = OKC_API.G_MISS_CHAR)
        OR (x_quav_rec.attribute13 IS NULL)
      THEN
        x_quav_rec.attribute13 := l_quav_rec.attribute13;
      END IF;
      IF (x_quav_rec.attribute14 = OKC_API.G_MISS_CHAR)
        OR (x_quav_rec.attribute14 IS NULL)
      THEN
        x_quav_rec.attribute14 := l_quav_rec.attribute14;
      END IF;
      IF (x_quav_rec.attribute15 = OKC_API.G_MISS_CHAR)
        OR (x_quav_rec.attribute15 IS NULL)
      THEN
        x_quav_rec.attribute15 := l_quav_rec.attribute15;
      END IF;
      IF (x_quav_rec.qualifier_grouping_no = OKC_API.G_MISS_NUM)
        OR (x_quav_rec.qualifier_grouping_no IS NULL)
      THEN
        x_quav_rec.qualifier_grouping_no := l_quav_rec.qualifier_grouping_no;
      END IF;
      IF (x_quav_rec.qualifier_context = OKC_API.G_MISS_CHAR)
        OR (x_quav_rec.qualifier_context IS NULL)
      THEN
        x_quav_rec.qualifier_context := l_quav_rec.qualifier_context;
      END IF;
      IF (x_quav_rec.qualifier_attribute = OKC_API.G_MISS_CHAR)
        OR (x_quav_rec.qualifier_attribute IS NULL)
      THEN
        x_quav_rec.qualifier_attribute := l_quav_rec.qualifier_attribute;
      END IF;
      IF (x_quav_rec.COMPARISON_OPERATOR_CODE = OKC_API.G_MISS_CHAR)
        OR (x_quav_rec.COMPARISON_OPERATOR_CODE IS NULL)
      THEN
        x_quav_rec.COMPARISON_OPERATOR_CODE := l_quav_rec.COMPARISON_OPERATOR_CODE;
      END IF;
      IF (x_quav_rec.excluder_flag = OKC_API.G_MISS_CHAR)
        OR (x_quav_rec.excluder_flag IS NULL)
      THEN
        x_quav_rec.excluder_flag := l_quav_rec.excluder_flag;
      END IF;
      IF (x_quav_rec.QUALIFIER_RULE_ID = OKC_API.G_MISS_NUM)
        OR (x_quav_rec.qualifier_rule_id IS NULL)
      THEN
        x_quav_rec.qualifier_rule_id := l_quav_rec.qualifier_rule_id;
      END IF;
      IF (x_quav_rec.start_date_active = OKC_API.G_MISS_DATE)
        OR (x_quav_rec.start_date_active IS NULL)
      THEN
        x_quav_rec.start_date_active := l_quav_rec.start_date_active;
      END IF;
      IF (x_quav_rec.end_date_active = OKC_API.G_MISS_DATE)
        OR (x_quav_rec.end_date_active IS NULL)
      THEN
        x_quav_rec.end_date_active := l_quav_rec.end_date_active;
      END IF;
      IF (x_quav_rec.created_from_rule_id = OKC_API.G_MISS_NUM)
        OR (x_quav_rec.created_from_rule_id IS NULL)
      THEN
        x_quav_rec.created_from_rule_id := l_quav_rec.created_from_rule_id;
      END IF;
      IF (x_quav_rec.qualifier_precedence = OKC_API.G_MISS_NUM)
        OR (x_quav_rec.qualifier_precedence IS NULL)
      THEN
        x_quav_rec.qualifier_precedence := l_quav_rec.qualifier_precedence;
      END IF;
      IF (x_quav_rec.list_header_id = OKC_API.G_MISS_NUM)
        OR (x_quav_rec.list_header_id IS NULL)
      THEN
        x_quav_rec.list_header_id := l_quav_rec.list_header_id;
      END IF;
      IF (x_quav_rec.list_line_id = OKC_API.G_MISS_NUM)
        OR (x_quav_rec.list_line_id IS NULL)
      THEN
        x_quav_rec.list_line_id := l_quav_rec.list_line_id;
      END IF;
      IF (x_quav_rec.qualifier_datatype = OKC_API.G_MISS_CHAR)
        OR (x_quav_rec.qualifier_datatype IS NULL)
      THEN
        x_quav_rec.qualifier_datatype := l_quav_rec.qualifier_datatype;
      END IF;
      IF (x_quav_rec.qualifier_attr_value_to = OKC_API.G_MISS_CHAR)
        OR (x_quav_rec.qualifier_attr_value_to IS NULL)
      THEN
        x_quav_rec.qualifier_attr_value_to := l_quav_rec.qualifier_attr_value_to;
      END IF;
      IF (x_quav_rec.context = OKC_API.G_MISS_CHAR)
        OR (x_quav_rec.context IS NULL)
      THEN
        x_quav_rec.context := l_quav_rec.context;
      END IF;
      IF (x_quav_rec.QUAL_ATTR_VALUE_TO_NUMBER = OKC_API.G_MISS_NUM)
        OR (x_quav_rec.QUAL_ATTR_VALUE_TO_NUMBER IS NULL)
      THEN
        x_quav_rec.QUAL_ATTR_VALUE_TO_NUMBER := l_quav_rec.QUAL_ATTR_VALUE_TO_NUMBER;
      END IF;
      IF (x_quav_rec.active_flag = OKC_API.G_MISS_CHAR)
        OR (x_quav_rec.active_flag IS NULL)
      THEN
        x_quav_rec.active_flag := l_quav_rec.active_flag;
      END IF;
      IF (x_quav_rec.list_type_code = OKC_API.G_MISS_CHAR)
        OR (x_quav_rec.list_type_code IS NULL)
      THEN
        x_quav_rec.list_type_code := l_quav_rec.list_type_code;
      END IF;
      IF (x_quav_rec.QUAL_ATTR_VALUE_FROM_NUMBER = OKC_API.G_MISS_NUM)
        OR (x_quav_rec.QUAL_ATTR_VALUE_FROM_NUMBER IS NULL)
      THEN
        x_quav_rec.QUAL_ATTR_VALUE_FROM_NUMBER := l_quav_rec.QUAL_ATTR_VALUE_FROM_NUMBER;
      END IF;

      RETURN(l_return_status);
    END populate_new_record;
    ---------------------------------------------
    -- Set_Attributes for:OKS_QUALIFIERS_V --
    ---------------------------------------------
    FUNCTION Set_Attributes (
      p_quav_rec IN  quav_rec_type,
      x_quav_rec OUT NOCOPY quav_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_quav_rec := p_quav_rec;
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
      p_quav_rec,                        -- IN
      l_quav_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_quav_rec, l_def_quav_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_quav_rec := fill_who_columns(l_def_quav_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_quav_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_quav_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_quav_rec, l_qua_rec);
    --------------------------------------------
    -- Call the UPDATE_ROW for each child record
    --------------------------------------------
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_qua_rec,
      lx_qua_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_qua_rec, l_def_quav_rec);
    x_quav_rec := l_def_quav_rec;
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
  -- PL/SQL TBL update_row for:BSLV_TBL --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_quav_tbl                     IN quav_tbl_type,
    x_quav_tbl                     OUT NOCOPY quav_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_quav_tbl.COUNT > 0) THEN
      i := p_quav_tbl.FIRST;
      LOOP
        update_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_quav_rec                     => p_quav_tbl(i),
          x_quav_rec                     => x_quav_tbl(i));
        EXIT WHEN (i = p_quav_tbl.LAST);
        i := p_quav_tbl.NEXT(i);
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
  ---------------------------------------
  -- delete_row for:OKS_QUALIFIERS --
  ---------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qua_rec                      IN qua_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'LINES_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_qua_rec                      qua_rec_type:= p_qua_rec;
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
    DELETE FROM OKS_QUALIFIERS
     WHERE QUALIFIER_ID = l_qua_rec.qualifier_id;

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
  -----------------------------------------
  -- delete_row for:OKS_QUALIFIERS_V --
  -----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_quav_rec                     IN quav_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_quav_rec                     quav_rec_type := p_quav_rec;
    l_qua_rec                      qua_rec_type;
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
    migrate(l_quav_rec, l_qua_rec);
    --------------------------------------------
    -- Call the DELETE_ROW for each child record
    --------------------------------------------
    delete_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_qua_rec
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
  -- PL/SQL TBL delete_row for:BSLV_TBL --
  ----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_quav_tbl                     IN quav_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_quav_tbl.COUNT > 0) THEN
      i := p_quav_tbl.FIRST;
      LOOP
        delete_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_quav_rec                     => p_quav_tbl(i));
        EXIT WHEN (i = p_quav_tbl.LAST);
        i := p_quav_tbl.NEXT(i);
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
END OKS_QUA_PVT;

/
