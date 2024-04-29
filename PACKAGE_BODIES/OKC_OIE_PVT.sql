--------------------------------------------------------
--  DDL for Package Body OKC_OIE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_OIE_PVT" AS
/* $Header: OKCSOIEB.pls 120.1 2005/07/15 09:14:19 parkumar noship $ */

	l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

  /************************ HAND-CODED *********************************/
  FUNCTION Validate_Attributes ( p_oiev_rec IN oiev_rec_type) RETURN VARCHAR2;
  G_SQLERRM_TOKEN    CONSTANT VARCHAR2(200) := 'SQLerrm';
  G_SQLCODE_TOKEN    CONSTANT VARCHAR2(200) := 'SQLcode';
  G_NO_PARENT_RECORD CONSTANT VARCHAR2(200) := 'OKC_NO_PARENT_RECORD';
  G_UNEXPECTED_ERROR CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UNEXPECTED_ERROR';
  G_VIEW             CONSTANT VARCHAR2(200) := 'OKC_OPERATION_INSTANCES_V';
  G_EXCEPTION_HALT_VALIDATION exception;

  -- Start of comments
  --
  -- Procedure Name  : validate_cop_id
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  PROCEDURE validate_cop_id(x_return_status OUT NOCOPY   VARCHAR2,
                            p_oiev_rec      IN    oiev_rec_type) is
	 l_dummy_var   VARCHAR2(1) := '?';
      CURSOR l_copv_csr (p_cop_id IN NUMBER) IS
      SELECT 'x'
        FROM okc_class_operations
       WHERE id = p_cop_id;
  Begin

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_OIE_PVT');
       okc_debug.log('100: Entered validate_cop_id', 2);
    END IF;

    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- check that data exists
    If (p_oiev_rec.cop_id = OKC_API.G_MISS_NUM or
	   p_oiev_rec.cop_id IS NULL)
    Then
  	  OKC_API.SET_MESSAGE(p_app_name		=> g_app_name,
					  p_msg_name		=> g_required_value,
					  p_token1		=> g_col_name_token,
					  p_token1_value	=> 'Class Operation Id');
	   -- notify caller of an error
        x_return_status := OKC_API.G_RET_STS_ERROR;

	   -- halt validation
	   raise G_EXCEPTION_HALT_VALIDATION;
    End If;

    -- Check foreign key
    Open l_copv_csr(p_oiev_rec.cop_id);
    Fetch l_copv_csr into l_dummy_var;
    Close l_copv_csr;

    -- if l_dummy_var still set to default, data was not found
    If (l_dummy_var = '?') Then
    	  OKC_API.SET_MESSAGE(
				    p_app_name      => g_app_name,
				    p_msg_name      => g_no_parent_record,
				    p_token1        => g_col_name_token,
				    p_token1_value  => 'Class Operation Id',
				    p_token2        => g_child_table_token,
				    p_token2_value  => G_VIEW,
				    p_token3        => g_parent_table_token,
				    p_token3_value  => 'OKC_CLASS_OPERATIONS_V');
	  -- notify caller of an error
	  x_return_status := OKC_API.G_RET_STS_ERROR;
    End If;

 IF (l_debug = 'Y') THEN
    okc_debug.log('200: Exiting validate_cop_id', 2);
    okc_debug.Reset_Indentation;
 END IF;

  exception
    when G_EXCEPTION_HALT_VALIDATION then

    IF (l_debug = 'Y') THEN
       okc_debug.log('300: Exiting validate_cop_id:G_EXCEPTION_HALT_VALIDATION Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

      -- no processing necessary; validation can continue with next column
      null;

    when OTHERS then

    IF (l_debug = 'Y') THEN
       okc_debug.log('400: Exiting validate_cop_id:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

	  -- store SQL error message on message stack
  	  OKC_API.SET_MESSAGE(p_app_name		=> g_app_name,
					  p_msg_name		=> g_unexpected_error,
					  p_token1		=> g_sqlcode_token,
					  p_token1_value	=> sqlcode,
					  p_token2		=> g_sqlerrm_token,
					  p_token2_value	=> sqlerrm);
	   -- notify caller of an error as UNEXPETED error
        x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  End validate_cop_id;

  -- Start of comments
  --
  -- Procedure Name  : validate_target_chr_id
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  PROCEDURE validate_target_chr_id(x_return_status OUT NOCOPY   VARCHAR2,
                                   p_oiev_rec      IN    oiev_rec_type) is

    l_dummy_var   VARCHAR2(1) := '?';
    Cursor l_chrv_csr Is
  	  select 'x'
	  from OKC_K_HEADERS_B
  	  where id = p_oiev_rec.target_chr_id;

  Begin

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_OIE_PVT');
       okc_debug.log('500: Entered validate_target_chr_id', 2);
    END IF;

    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- enforce foreign key (target_chr_id is optional)
    If (p_oiev_rec.target_chr_id <> OKC_API.G_MISS_NUM and
  	   p_oiev_rec.target_chr_id IS NOT NULL)
    Then
       Open l_chrv_csr;
       Fetch l_chrv_csr Into l_dummy_var;
       Close l_chrv_csr;
       -- if l_dummy_var still set to default, data was not found
       If (l_dummy_var = '?') Then
  	     OKC_API.SET_MESSAGE(p_app_name		=> g_app_name,
				          p_msg_name		=> g_no_parent_record,
					     p_token1		=> g_col_name_token,
					     p_token1_value	=> 'Target Contract Id',
					     p_token2		=> g_child_table_token,
					     p_token2_value	=> G_VIEW,
					     p_token3		=> g_parent_table_token,
					     p_token3_value	=> 'OKC_K_HEADERS_V');
	     -- notify caller of an error
          x_return_status := OKC_API.G_RET_STS_ERROR;
      End If;
    End If;

  IF (l_debug = 'Y') THEN
     okc_debug.log('600: Exiting validate_target_chr_id', 2);
     okc_debug.Reset_Indentation;
  END IF;

  exception
    when OTHERS then

    IF (l_debug = 'Y') THEN
       okc_debug.log('700: Exiting validate_target_chr_id:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

	  -- store SQL error message on message stack
  	  OKC_API.SET_MESSAGE(p_app_name		=> g_app_name,
					  p_msg_name		=> g_unexpected_error,
					  p_token1		=> g_sqlcode_token,
					  p_token1_value	=> sqlcode,
					  p_token2		=> g_sqlerrm_token,
					  p_token2_value	=> sqlerrm);
	   -- notify caller of an error as UNEXPETED error
        x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

        -- verify that cursor was closed
        if l_chrv_csr%ISOPEN then
	      close l_chrv_csr;
        end if;
  End validate_target_chr_id;

  PROCEDURE validate_status_code(x_return_status OUT NOCOPY   VARCHAR2,
                                 p_oiev_rec      IN    oiev_rec_type) is
  Begin

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_OIE_PVT');
       okc_debug.log('800: Entered validate_status_code', 2);
    END IF;

    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- check that data exists
    If (p_oiev_rec.status_code = OKC_API.G_MISS_CHAR or
	   p_oiev_rec.status_code IS NULL)
    Then
  	  OKC_API.SET_MESSAGE(p_app_name		=> g_app_name,
					  p_msg_name		=> g_required_value,
					  p_token1		=> g_col_name_token,
					  p_token1_value	=> 'Status Code');
	   -- notify caller of an error
        x_return_status := OKC_API.G_RET_STS_ERROR;

	   -- halt validation
	   raise G_EXCEPTION_HALT_VALIDATION;
    End If;

    -- enforce foreign key
    -- check for OKS mass change operation status first
    -- if not found , check for OKC Status

    x_return_status := OKC_UTIL.check_lookup_code('OKS_OPERATION_STATUS',
										p_oiev_rec.status_code);

    If (x_return_status <> OKC_API.G_RET_STS_SUCCESS) Then
	    -- Check if the value is a valid code from lookup table
	    x_return_status := OKC_UTIL.check_lookup_code('OKC_STATUS_TYPE',
						                         p_oiev_rec.status_code);
	    If (x_return_status = OKC_API.G_RET_STS_ERROR) Then
			  --set error message in message stack
			  OKC_API.SET_MESSAGE(
				   p_app_name	=> G_APP_NAME,
				   p_msg_name	=> G_INVALID_VALUE,
				   p_token1		=> G_COL_NAME_TOKEN,
				   p_token1_value => 'Status Code');
			  raise G_EXCEPTION_HALT_VALIDATION;
		Elsif (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) Then
		       raise G_EXCEPTION_HALT_VALIDATION;
		End If;
    End If;

 IF (l_debug = 'Y') THEN
    okc_debug.log('900: Exiting validate_status_code', 2);
    okc_debug.Reset_Indentation;
 END IF;

  EXCEPTION
    when OTHERS then

    IF (l_debug = 'Y') THEN
       okc_debug.log('1000: Exiting validate_status_code:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

	  -- store SQL error message on message stack
  	  OKC_API.SET_MESSAGE(p_app_name		=> g_app_name,
					  p_msg_name		=> g_unexpected_error,
					  p_token1		=> g_sqlcode_token,
					  p_token1_value	=> sqlcode,
					  p_token2		=> g_sqlerrm_token,
					  p_token2_value	=> sqlerrm);
	   -- notify caller of an error as UNEXPETED error
        x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  End validate_status_code;


-- Start of comments
--
-- Procedure Name  : validate_jtot_object1_code
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

procedure validate_jtot_object1_code(x_return_status OUT NOCOPY        VARCHAR2,
                          p_oiev_rec      IN    oiev_rec_type) is
   l_dummy_var                 varchar2(1) := '?';
--
 CURSOR l_jtf_csr IS
   SELECT '!'
   FROM JTF_OBJECTS_B
   WHERE object_code = p_oiev_rec.jtot_object1_code
   AND sysdate between nvl(start_date_active,sysdate) and nvl(end_date_active,sysdate);

begin

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_OIE_PVT');
       okc_debug.log('1100: Entered validate_jtot_object1_code', 2);
    END IF;

  x_return_status := OKC_API.G_RET_STS_SUCCESS;
  if (p_oiev_rec.jtot_object1_code = OKC_API.G_MISS_CHAR or p_oiev_rec.jtot_object1_code is NULL) then
    return;
  end if;
--
  open l_jtf_csr;
  fetch l_jtf_csr into l_dummy_var;
  close l_jtf_csr;
  if (l_dummy_var = '?') then
    OKC_API.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'JTOT_OBJECT1_CODE');
    x_return_status := OKC_API.G_RET_STS_ERROR;
  end if;

 IF (l_debug = 'Y') THEN
    okc_debug.log('1200: Exiting validate_jtot_object1_code', 2);
    okc_debug.Reset_Indentation;
 END IF;

exception
  when OTHERS then

    IF (l_debug = 'Y') THEN
       okc_debug.log('1300: Exiting validate_jtot_object1_code:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

    if l_jtf_csr%ISOPEN then
      close l_jtf_csr;
    end if;
    OKC_API.set_message(p_app_name     => g_app_name,
                        p_msg_name     => g_unexpected_error,
                        p_token1       => g_sqlcode_token,
                        p_token1_value => sqlcode,
                        p_token2       => g_sqlerrm_token,
                        p_token2_value => sqlerrm);
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

end validate_jtot_object1_code;

-- Start of comments
--
-- Procedure Name  : validate_object1_id1
-- Description     :  to be called from validate record
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

procedure validate_object1_id1(x_return_status OUT NOCOPY      VARCHAR2,
                          p_oiev_rec      IN    oiev_rec_type) is
 l_dummy_var                 varchar2(1) := '?';
 L_FROM_TABLE                    VARCHAR2(200);
 L_WHERE_CLAUSE            VARCHAR2(2000);
 cursor l_object1_csr is
 select
        from_table
        ,trim(where_clause) where_clause
 from
        jtf_objects_vl OB
 where
        OB.OBJECT_CODE = p_oiev_rec.jtot_object1_code
 ;
 e_no_data_found EXCEPTION;
 PRAGMA EXCEPTION_INIT(e_no_data_found,100);
 e_too_many_rows EXCEPTION;
 PRAGMA EXCEPTION_INIT(e_too_many_rows,-1422);
 e_source_not_exists EXCEPTION;
 PRAGMA EXCEPTION_INIT(e_source_not_exists,-942);
 e_column_not_exists EXCEPTION;
 PRAGMA EXCEPTION_INIT(e_column_not_exists,-904);
begin

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_OIE_PVT');
       okc_debug.log('1400: Entered validate_object1_id1', 2);
    END IF;

  x_return_status := OKC_API.G_RET_STS_SUCCESS;
  if (p_oiev_rec.jtot_object1_code = OKC_API.G_MISS_CHAR or p_oiev_rec.jtot_object1_code is NULL) then
    return;
  end if;
  if (p_oiev_rec.object1_id1 = OKC_API.G_MISS_CHAR or p_oiev_rec.object1_id1 is NULL) then
        return;
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
        USING p_oiev_rec.object1_id1, p_oiev_rec.object1_id2;

IF (l_debug = 'Y') THEN
   okc_debug.log('1500: Exiting validate_object1_id1', 2);
   okc_debug.Reset_Indentation;
END IF;

exception
  when e_source_not_exists then

    IF (l_debug = 'Y') THEN
       okc_debug.log('1600: Exiting validate_object1_id1:e_source_not_exists Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

    OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'JTOT_OBJECT1_CODE');
    x_return_status := OKC_API.G_RET_STS_ERROR;
  when e_column_not_exists then

    IF (l_debug = 'Y') THEN
       okc_debug.log('1700: Exiting validate_object1_id1:e_column_not_exists Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

    OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,l_from_table||'.ID1');
    x_return_status := OKC_API.G_RET_STS_ERROR;
  when e_no_data_found then

    IF (l_debug = 'Y') THEN
       okc_debug.log('1800: Exiting validate_object1_id1:e_no_data_found Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

    OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'OBJECT1_ID1');
    x_return_status := OKC_API.G_RET_STS_ERROR;
  when e_too_many_rows then

    IF (l_debug = 'Y') THEN
       okc_debug.log('1900: Exiting validate_object1_id1:e_too_many_rows Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

    OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,l_from_table||'.ID1');
    x_return_status := OKC_API.G_RET_STS_ERROR;
  when OTHERS then

    IF (l_debug = 'Y') THEN
       okc_debug.log('2000: Exiting validate_object1_id1:OTHERS Exception', 2);
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

end validate_object1_id1;

  /*********************** END HAND-CODED ********************************/

  ---------------------------------------------------------------------------
  -- FUNCTION get_seq_id
  ---------------------------------------------------------------------------
  FUNCTION get_seq_id RETURN NUMBER IS
    Cursor c Is
    SELECT OKC_OPERATION_INSTANCES_S1.nextval
    FROM dual;

    l_seq NUMBER;
  BEGIN

    open c;
    fetch c into l_seq;
    close c;
    RETURN (l_seq);

    --RETURN(okc_p_util.raw_to_number(sys_guid()));

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
  -- FUNCTION get_rec for: OKC_OPERATION_INSTANCES
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_oie_rec                      IN oie_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN oie_rec_type IS
    CURSOR okc_operation_instances_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            COP_ID,
            STATUS_CODE,
            OBJECT_VERSION_NUMBER,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN,
            NAME,
            TARGET_CHR_ID,
		  REQUEST_ID,
		  PROGRAM_APPLICATION_ID,
		  PROGRAM_ID,
		  PROGRAM_UPDATE_DATE,
		  JTOT_OBJECT1_CODE,
                  OBJECT1_ID1,
                  OBJECT1_ID2,
-- R12 Data Model Changes 4485150 Start
            BATCH_ID
-- R12 Data Model Changes 4485150 End
      FROM Okc_Operation_Instances
     WHERE okc_operation_instances.id = p_id;
    l_okc_operation_instances_pk   okc_operation_instances_pk_csr%ROWTYPE;
    l_oie_rec                      oie_rec_type;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_OIE_PVT');
       okc_debug.log('2500: Entered get_rec', 2);
    END IF;

    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okc_operation_instances_pk_csr (p_oie_rec.id);
    FETCH okc_operation_instances_pk_csr INTO
              l_oie_rec.ID,
              l_oie_rec.COP_ID,
              l_oie_rec.STATUS_CODE,
              l_oie_rec.OBJECT_VERSION_NUMBER,
              l_oie_rec.CREATED_BY,
              l_oie_rec.CREATION_DATE,
              l_oie_rec.LAST_UPDATED_BY,
              l_oie_rec.LAST_UPDATE_DATE,
              l_oie_rec.LAST_UPDATE_LOGIN,
              l_oie_rec.NAME,
              l_oie_rec.TARGET_CHR_ID,
		    l_oie_rec.REQUEST_ID,
		    l_oie_rec.PROGRAM_APPLICATION_ID,
		    l_oie_rec.PROGRAM_ID,
		    l_oie_rec.PROGRAM_UPDATE_DATE,
		    l_oie_rec.JTOT_OBJECT1_CODE,
		    l_oie_rec.OBJECT1_ID1,
		    l_oie_rec.OBJECT1_ID2,
-- R12 Data Model Changes 4485150 Start
            l_oie_rec.batch_id;
-- R12 Data Model Changes 4485150 End


    x_no_data_found := okc_operation_instances_pk_csr%NOTFOUND;
    CLOSE okc_operation_instances_pk_csr;

IF (l_debug = 'Y') THEN
   okc_debug.log('2550: Leaving  Fn  Get_Rec ', 2);
   okc_debug.Reset_Indentation;
END IF;

    RETURN(l_oie_rec);

  END get_rec;

  FUNCTION get_rec (
    p_oie_rec                      IN oie_rec_type
  ) RETURN oie_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN

    RETURN(get_rec(p_oie_rec, l_row_notfound));

  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKC_OPERATION_INSTANCES_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_oiev_rec                      IN oiev_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN oiev_rec_type IS
    CURSOR oiev_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            NAME,
            COP_ID,
            STATUS_CODE,
            TARGET_CHR_ID,
            OBJECT_VERSION_NUMBER,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN,
            JTOT_OBJECT1_CODE,
            OBJECT1_ID1,
            OBJECT1_ID2
      FROM Okc_Operation_Instances_V
     WHERE okc_operation_instances_v.id = p_id;
    l_oiev_pk                       oiev_pk_csr%ROWTYPE;
    l_oiev_rec                      oiev_rec_type;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_OIE_PVT');
       okc_debug.log('2700: Entered get_rec', 2);
    END IF;

    x_no_data_found := TRUE;
    -- Get current database values
    OPEN oiev_pk_csr (p_oiev_rec.id);
    FETCH oiev_pk_csr INTO
              l_oiev_rec.ID,
              l_oiev_rec.NAME,
              l_oiev_rec.COP_ID,
              l_oiev_rec.STATUS_CODE,
              l_oiev_rec.TARGET_CHR_ID,
              l_oiev_rec.OBJECT_VERSION_NUMBER,
              l_oiev_rec.CREATED_BY,
              l_oiev_rec.CREATION_DATE,
              l_oiev_rec.LAST_UPDATED_BY,
              l_oiev_rec.LAST_UPDATE_DATE,
              l_oiev_rec.LAST_UPDATE_LOGIN,
              l_oiev_rec.JTOT_OBJECT1_CODE,
              l_oiev_rec.OBJECT1_ID1,
              l_oiev_rec.OBJECT1_ID2;
    x_no_data_found := oiev_pk_csr%NOTFOUND;
    CLOSE oiev_pk_csr;

IF (l_debug = 'Y') THEN
   okc_debug.log('2750: Leaving  Fn  Get_Rec ', 2);
   okc_debug.Reset_Indentation;
END IF;

    RETURN(l_oiev_rec);

  END get_rec;

  FUNCTION get_rec (
    p_oiev_rec                      IN oiev_rec_type
  ) RETURN oiev_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN

    RETURN(get_rec(p_oiev_rec, l_row_notfound));

  END get_rec;

  ---------------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKC_OPERATION_INSTANCES_V --
  ---------------------------------------------------------------
  FUNCTION null_out_defaults (
    p_oiev_rec	IN oiev_rec_type
  ) RETURN oiev_rec_type IS
    l_oiev_rec	oiev_rec_type := p_oiev_rec;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_OIE_PVT');
       okc_debug.log('2900: Entered null_out_defaults', 2);
    END IF;

    IF (l_oiev_rec.name = OKC_API.G_MISS_CHAR) THEN
      l_oiev_rec.name := NULL;
    END IF;
    IF (l_oiev_rec.cop_id = OKC_API.G_MISS_NUM) THEN
      l_oiev_rec.cop_id := NULL;
    END IF;
    IF (l_oiev_rec.status_code = OKC_API.G_MISS_CHAR) THEN
      l_oiev_rec.status_code := NULL;
    END IF;
    IF (l_oiev_rec.target_chr_id = OKC_API.G_MISS_NUM) THEN
      l_oiev_rec.target_chr_id := NULL;
    END IF;
    IF (l_oiev_rec.object_version_number = OKC_API.G_MISS_NUM) THEN
      l_oiev_rec.object_version_number := NULL;
    END IF;
    IF (l_oiev_rec.created_by = OKC_API.G_MISS_NUM) THEN
      l_oiev_rec.created_by := NULL;
    END IF;
    IF (l_oiev_rec.creation_date = OKC_API.G_MISS_DATE) THEN
      l_oiev_rec.creation_date := NULL;
    END IF;
    IF (l_oiev_rec.last_updated_by = OKC_API.G_MISS_NUM) THEN
      l_oiev_rec.last_updated_by := NULL;
    END IF;
    IF (l_oiev_rec.last_update_date = OKC_API.G_MISS_DATE) THEN
      l_oiev_rec.last_update_date := NULL;
    END IF;
    IF (l_oiev_rec.last_update_login = OKC_API.G_MISS_NUM) THEN
      l_oiev_rec.last_update_login := NULL;
    END IF;
    IF (l_oiev_rec.jtot_object1_code = OKC_API.G_MISS_CHAR) THEN
      l_oiev_rec.jtot_object1_code := NULL;
    END IF;
    IF (l_oiev_rec.object1_id1 = OKC_API.G_MISS_CHAR) THEN
      l_oiev_rec.object1_id1 := NULL;
    END IF;
    IF (l_oiev_rec.object1_id2 = OKC_API.G_MISS_CHAR) THEN
      l_oiev_rec.object1_id2 := NULL;
    END IF;

IF (l_debug = 'Y') THEN
   okc_debug.log('500: Leaving  null_out_defaults ', 2);
   okc_debug.Reset_Indentation;
END IF;

    RETURN(l_oiev_rec);

  END null_out_defaults;
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Attributes
  ---------------------------------------------------------------------------
  -------------------------------------------------------
  -- Validate_Attributes for:OKC_OPERATION_INSTANCES_V --
  -------------------------------------------------------
  FUNCTION Validate_Attributes (
    p_oiev_rec IN  oiev_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    x_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_OIE_PVT');
       okc_debug.log('3000: Entered Validate_Attributes', 2);
    END IF;

    /************************ HAND-CODED *********************************/
	  validate_cop_id(x_return_status => l_return_status,
				   p_oiev_rec      => p_oiev_rec);

	    -- store the highest degree of error
	    If l_return_status <> OKC_API.G_RET_STS_SUCCESS Then
		  If x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR Then
			x_return_status := l_return_status;
		  End If;
	    End If;

	  validate_target_chr_id(x_return_status => l_return_status,
				          p_oiev_rec      => p_oiev_rec);

	    -- store the highest degree of error
	    If l_return_status <> OKC_API.G_RET_STS_SUCCESS Then
		  If x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR Then
			x_return_status := l_return_status;
		  End If;
	    End If;

	  validate_status_code(x_return_status => l_return_status,
				        p_oiev_rec      => p_oiev_rec);

	    -- store the highest degree of error
	    If l_return_status <> OKC_API.G_RET_STS_SUCCESS Then
		  If x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR Then
			x_return_status := l_return_status;
		  End If;
	    End If;

	  validate_jtot_object1_code(x_return_status => l_return_status,
				        p_oiev_rec      => p_oiev_rec);

	    -- store the highest degree of error
	    If l_return_status <> OKC_API.G_RET_STS_SUCCESS Then
		  If x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR Then
			x_return_status := l_return_status;
		  End If;
	    End If;

	  validate_object1_id1(x_return_status => l_return_status,
				        p_oiev_rec      => p_oiev_rec);

	    -- store the highest degree of error
	    If l_return_status <> OKC_API.G_RET_STS_SUCCESS Then
		  If x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR Then
			x_return_status := l_return_status;
		  End If;
	    End If;

    IF (l_debug = 'Y') THEN
       okc_debug.log('3100: Exiting Validate_Attributes', 2);
       okc_debug.Reset_Indentation;
    END IF;

    RETURN(x_return_status);

  EXCEPTION
    when OTHERS then

    IF (l_debug = 'Y') THEN
       okc_debug.log('3200: Exiting Validate_Attributes:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

       -- store SQL error message on message stack
       OKC_API.SET_MESSAGE(p_app_name        => g_app_name,
                           p_msg_name        => g_unexpected_error,
                           p_token1          => g_sqlcode_token,
                           p_token1_value    => sqlcode,
                           p_token2          => g_sqlerrm_token,
                           p_token2_value    => sqlerrm);

        -- notify caller of an UNEXPETED error
        x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

        -- return status to caller
        RETURN(x_return_status);
    /*********************** END HAND-CODED ********************************/

  END Validate_Attributes;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Record
  ---------------------------------------------------------------------------
  ---------------------------------------------------
  -- Validate_Record for:OKC_OPERATION_INSTANCES_V --
  ---------------------------------------------------
  FUNCTION Validate_Record (
    p_oiev_rec IN oiev_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN

    RETURN (l_return_status);

  END Validate_Record;

  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from	IN oiev_rec_type,
    p_to	IN OUT NOCOPY oie_rec_type
  ) IS
  BEGIN

    p_to.id := p_from.id;
    p_to.cop_id := p_from.cop_id;
    p_to.status_code := p_from.status_code;
    p_to.object_version_number := p_from.object_version_number;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
    p_to.name := p_from.name;
    p_to.target_chr_id := p_from.target_chr_id;
    p_to.jtot_object1_code := p_from.jtot_object1_code;
    p_to.object1_id1       := p_from.object1_id1;
    p_to.object1_id2       := p_from.object1_id2;

  END migrate;

  PROCEDURE migrate (
    p_from	IN oie_rec_type,
    p_to	IN OUT NOCOPY oiev_rec_type
  ) IS
  BEGIN

    p_to.id := p_from.id;
    p_to.cop_id := p_from.cop_id;
    p_to.status_code := p_from.status_code;
    p_to.object_version_number := p_from.object_version_number;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
    p_to.name := p_from.name;
    p_to.target_chr_id := p_from.target_chr_id;
    p_to.jtot_object1_code := p_from.jtot_object1_code;
    p_to.object1_id1       := p_from.object1_id1;
    p_to.object1_id2       := p_from.object1_id2;

  END migrate;

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_row
  ---------------------------------------------------------------------------
  ------------------------------------------------
  -- validate_row for:OKC_OPERATION_INSTANCES_V --
  ------------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oiev_rec                      IN oiev_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_oiev_rec                      oiev_rec_type := p_oiev_rec;
    l_oie_rec                      oie_rec_type;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_OIE_PVT');
       okc_debug.log('3600: Entered validate_row', 2);
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
    l_return_status := Validate_Attributes(l_oiev_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_oiev_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);

    IF (l_debug = 'Y') THEN
       okc_debug.log('3700: Exiting validate_row', 2);
       okc_debug.Reset_Indentation;
    END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('3800: Exiting validate_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
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
       okc_debug.log('3900: Exiting validate_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
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
       okc_debug.log('4000: Exiting validate_row:OTHERS Exception', 2);
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
  -----------------------------------------
  -- PL/SQL TBL validate_row for:oiev_tbl --
  -----------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oiev_tbl                      IN oiev_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status               VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_OIE_PVT');
       okc_debug.log('4100: Entered validate_row', 2);
    END IF;

    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_oiev_tbl.COUNT > 0) THEN
      i := p_oiev_tbl.FIRST;
      LOOP
        validate_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_oiev_rec                      => p_oiev_tbl(i));

          -- store the highest degree of error
          If x_return_status <> OKC_API.G_RET_STS_SUCCESS Then
             If l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR Then
                l_overall_status := x_return_status;
             End If;
          End If;


        i := p_oiev_tbl.NEXT(i);
      END LOOP;
      -- return overall status
      x_return_status := l_overall_status;
    END IF;

    IF (l_debug = 'Y') THEN
       okc_debug.log('4200: Exiting validate_row', 2);
       okc_debug.Reset_Indentation;
    END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('4300: Exiting validate_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
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
       okc_debug.log('4400: Exiting validate_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
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
       okc_debug.log('4500: Exiting validate_row:OTHERS Exception', 2);
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
  --------------------------------------------
  -- insert_row for:OKC_OPERATION_INSTANCES --
  --------------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oie_rec                      IN oie_rec_type,
    x_oie_rec                      OUT NOCOPY oie_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'INSTANCES_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_oie_rec                      oie_rec_type := p_oie_rec;
    l_def_oie_rec                  oie_rec_type;
    ------------------------------------------------
    -- Set_Attributes for:OKC_OPERATION_INSTANCES --
    ------------------------------------------------
    FUNCTION Set_Attributes (
      p_oie_rec IN  oie_rec_type,
      x_oie_rec OUT NOCOPY oie_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN

      x_oie_rec := p_oie_rec;
      RETURN(l_return_status);

    END Set_Attributes;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_OIE_PVT');
       okc_debug.log('4700: Entered insert_row', 2);
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
      p_oie_rec,                         -- IN
      l_oie_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKC_OPERATION_INSTANCES(
        id,
        cop_id,
        status_code,
        object_version_number,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        last_update_login,
        name,
        target_chr_id,
	   request_id,
	   program_application_id,
	   program_id,
	   program_update_date,
           jtot_object1_code,
           object1_id1,
           object1_id2,
-- R12 Data Model Changes 4485150 Start
           batch_id
-- R12 Data Model Changes 4485150 End
)
      VALUES (
        l_oie_rec.id,
        l_oie_rec.cop_id,
        l_oie_rec.status_code,
        l_oie_rec.object_version_number,
        l_oie_rec.created_by,
        l_oie_rec.creation_date,
        l_oie_rec.last_updated_by,
        l_oie_rec.last_update_date,
        l_oie_rec.last_update_login,
        l_oie_rec.name,
        l_oie_rec.target_chr_id,
        decode(FND_GLOBAL.CONC_REQUEST_ID,-1,NULL,FND_GLOBAL.CONC_REQUEST_ID),
        decode(FND_GLOBAL.PROG_APPL_ID,-1,NULL,FND_GLOBAL.PROG_APPL_ID),
        decode(FND_GLOBAL.CONC_PROGRAM_ID,-1,NULL,FND_GLOBAL.CONC_PROGRAM_ID),
        decode(FND_GLOBAL.CONC_REQUEST_ID,-1,NULL,SYSDATE),
        l_oie_rec.jtot_object1_code,
        l_oie_rec.object1_id1,
        l_oie_rec.object1_id2,
-- R12 Data Model Changes 4485150 Start
        l_oie_rec.batch_id
-- R12 Data Model Changes 4485150 End
);

    -- Set OUT values
    x_oie_rec := l_oie_rec;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);

    IF (l_debug = 'Y') THEN
       okc_debug.log('4800: Exiting insert_row', 2);
       okc_debug.Reset_Indentation;
    END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('4900: Exiting insert_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
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
       okc_debug.log('5000: Exiting insert_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
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
       okc_debug.log('5100: Exiting insert_row:OTHERS Exception', 2);
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
  ----------------------------------------------
  -- insert_row for:OKC_OPERATION_INSTANCES_V --
  ----------------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oiev_rec                      IN oiev_rec_type,
    x_oiev_rec                      OUT NOCOPY oiev_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_oiev_rec                      oiev_rec_type;
    l_def_oiev_rec                  oiev_rec_type;
    l_oie_rec                      oie_rec_type;
    lx_oie_rec                     oie_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_oiev_rec	IN oiev_rec_type
    ) RETURN oiev_rec_type IS
      l_oiev_rec	oiev_rec_type := p_oiev_rec;
    BEGIN

      l_oiev_rec.CREATION_DATE := SYSDATE;
      l_oiev_rec.CREATED_BY := FND_GLOBAL.USER_ID;
      l_oiev_rec.LAST_UPDATE_DATE := l_oiev_rec.CREATION_DATE;
      l_oiev_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_oiev_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;

      RETURN(l_oiev_rec);

    END fill_who_columns;
    --------------------------------------------------
    -- Set_Attributes for:OKC_OPERATION_INSTANCES_V --
    --------------------------------------------------
    FUNCTION Set_Attributes (
      p_oiev_rec IN  oiev_rec_type,
      x_oiev_rec OUT NOCOPY oiev_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN

      x_oiev_rec := p_oiev_rec;
      x_oiev_rec.OBJECT_VERSION_NUMBER := 1;
      RETURN(l_return_status);

    END Set_Attributes;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_OIE_PVT');
       okc_debug.log('5400: Entered insert_row', 2);
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
    l_oiev_rec := null_out_defaults(p_oiev_rec);
    -- Set primary key value
    l_oiev_rec.ID := get_seq_id;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      l_oiev_rec,                         -- IN
      l_def_oiev_rec);                    -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_oiev_rec := fill_who_columns(l_def_oiev_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_oiev_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_oiev_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_oiev_rec, l_oie_rec);
    --------------------------------------------
    -- Call the INSERT_ROW for each child record
    --------------------------------------------
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_oie_rec,
      lx_oie_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_oie_rec, l_def_oiev_rec);
    -- Set OUT values
    x_oiev_rec := l_def_oiev_rec;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);

    IF (l_debug = 'Y') THEN
       okc_debug.log('5500: Exiting insert_row', 2);
       okc_debug.Reset_Indentation;
    END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('5600: Exiting insert_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
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
       okc_debug.log('5700: Exiting insert_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
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
       okc_debug.log('5800: Exiting insert_row:OTHERS Exception', 2);
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
  ---------------------------------------
  -- PL/SQL TBL insert_row for:oiev_tbl --
  ---------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oiev_tbl                      IN oiev_tbl_type,
    x_oiev_tbl                      OUT NOCOPY oiev_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status               VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_OIE_PVT');
       okc_debug.log('5900: Entered insert_row', 2);
    END IF;

    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_oiev_tbl.COUNT > 0) THEN
      i := p_oiev_tbl.FIRST;
      LOOP
        insert_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_oiev_rec                      => p_oiev_tbl(i),
          x_oiev_rec                      => x_oiev_tbl(i));

          -- store the highest degree of error
          If x_return_status <> OKC_API.G_RET_STS_SUCCESS Then
             If l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR Then
                l_overall_status := x_return_status;
             End If;
          End If;

        EXIT WHEN (i = p_oiev_tbl.LAST);
        i := p_oiev_tbl.NEXT(i);
      END LOOP;
      -- return overall status
      x_return_status := l_overall_status;
    END IF;

    IF (l_debug = 'Y') THEN
       okc_debug.log('6000: Exiting insert_row', 2);
       okc_debug.Reset_Indentation;
    END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('6100: Exiting insert_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
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
       okc_debug.log('6200: Exiting insert_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
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
       okc_debug.log('6300: Exiting insert_row:OTHERS Exception', 2);
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
  ------------------------------------------
  -- lock_row for:OKC_OPERATION_INSTANCES --
  ------------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oie_rec                      IN oie_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_oie_rec IN oie_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKC_OPERATION_INSTANCES
     WHERE ID = p_oie_rec.id
       AND OBJECT_VERSION_NUMBER = p_oie_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR  lchk_csr (p_oie_rec IN oie_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKC_OPERATION_INSTANCES
    WHERE ID = p_oie_rec.id;
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'INSTANCES_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_object_version_number       OKC_OPERATION_INSTANCES.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number      OKC_OPERATION_INSTANCES.OBJECT_VERSION_NUMBER%TYPE;
    l_row_notfound                BOOLEAN := FALSE;
    lc_row_notfound               BOOLEAN := FALSE;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_OIE_PVT');
       okc_debug.log('6400: Entered lock_row', 2);
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

      OPEN lock_csr(p_oie_rec);
      FETCH lock_csr INTO l_object_version_number;
      l_row_notfound := lock_csr%NOTFOUND;
      CLOSE lock_csr;

    EXCEPTION
      WHEN E_Resource_Busy THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('6700: Exiting lock_row:E_Resource_Busy Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

        IF (lock_csr%ISOPEN) THEN
          CLOSE lock_csr;
        END IF;
        OKC_API.set_message(G_FND_APP,G_FORM_UNABLE_TO_RESERVE_REC);
        RAISE APP_EXCEPTIONS.RECORD_LOCK_EXCEPTION;
    END;

    IF ( l_row_notfound ) THEN
      OPEN lchk_csr(p_oie_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_oie_rec.object_version_number THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_oie_rec.object_version_number THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number = -1 THEN
      OKC_API.set_message(G_APP_NAME,G_RECORD_LOGICALLY_DELETED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);

    IF (l_debug = 'Y') THEN
       okc_debug.log('6800: Exiting lock_row', 2);
       okc_debug.Reset_Indentation;
    END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('6900: Exiting lock_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
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
       okc_debug.log('7000: Exiting lock_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
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
       okc_debug.log('7100: Exiting lock_row:OTHERS Exception', 2);
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
  --------------------------------------------
  -- lock_row for:OKC_OPERATION_INSTANCES_V --
  --------------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oiev_rec                      IN oiev_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_oie_rec                      oie_rec_type;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_OIE_PVT');
       okc_debug.log('7200: Entered lock_row', 2);
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
    migrate(p_oiev_rec, l_oie_rec);
    --------------------------------------------
    -- Call the LOCK_ROW for each child record
    --------------------------------------------
    lock_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_oie_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);

    IF (l_debug = 'Y') THEN
       okc_debug.log('7300: Exiting lock_row', 2);
       okc_debug.Reset_Indentation;
    END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('7400: Exiting lock_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
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
       okc_debug.log('7500: Exiting lock_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
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
       okc_debug.log('7600: Exiting lock_row:OTHERS Exception', 2);
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
  -------------------------------------
  -- PL/SQL TBL lock_row for:oiev_tbl --
  -------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oiev_tbl                      IN oiev_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status               VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_OIE_PVT');
       okc_debug.log('7700: Entered lock_row', 2);
    END IF;

    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_oiev_tbl.COUNT > 0) THEN
      i := p_oiev_tbl.FIRST;
      LOOP
        lock_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_oiev_rec                      => p_oiev_tbl(i));

          -- store the highest degree of error
          If x_return_status <> OKC_API.G_RET_STS_SUCCESS Then
             If l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR Then
                l_overall_status := x_return_status;
             End If;
          End If;

        EXIT WHEN (i = p_oiev_tbl.LAST);
        i := p_oiev_tbl.NEXT(i);
      END LOOP;
      -- return overall status
      x_return_status := l_overall_status;
    END IF;

IF (l_debug = 'Y') THEN
   okc_debug.log('7800: Exiting lock_row', 2);
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

  ---------------------------------------------------------------------------
  -- PROCEDURE update_row
  ---------------------------------------------------------------------------
  --------------------------------------------
  -- update_row for:OKC_OPERATION_INSTANCES --
  --------------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oie_rec                      IN oie_rec_type,
    x_oie_rec                      OUT NOCOPY oie_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'INSTANCES_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_oie_rec                      oie_rec_type := p_oie_rec;
    l_def_oie_rec                  oie_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_oie_rec	IN oie_rec_type,
      x_oie_rec	OUT NOCOPY oie_rec_type
    ) RETURN VARCHAR2 IS
      l_oie_rec                      oie_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_OIE_PVT');
       okc_debug.log('8200: Entered populate_new_record', 2);
    END IF;

      x_oie_rec := p_oie_rec;
      -- Get current database values
      l_oie_rec := get_rec(p_oie_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_oie_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_oie_rec.id := l_oie_rec.id;
      END IF;
      IF (x_oie_rec.cop_id = OKC_API.G_MISS_NUM)
      THEN
        x_oie_rec.cop_id := l_oie_rec.cop_id;
      END IF;
      IF (x_oie_rec.status_code = OKC_API.G_MISS_CHAR)
      THEN
        x_oie_rec.status_code := l_oie_rec.status_code;
      END IF;
      IF (x_oie_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_oie_rec.object_version_number := l_oie_rec.object_version_number;
      END IF;
      IF (x_oie_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_oie_rec.created_by := l_oie_rec.created_by;
      END IF;
      IF (x_oie_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_oie_rec.creation_date := l_oie_rec.creation_date;
      END IF;
      IF (x_oie_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_oie_rec.last_updated_by := l_oie_rec.last_updated_by;
      END IF;
      IF (x_oie_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_oie_rec.last_update_date := l_oie_rec.last_update_date;
      END IF;
      IF (x_oie_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_oie_rec.last_update_login := l_oie_rec.last_update_login;
      END IF;
      IF (x_oie_rec.name = OKC_API.G_MISS_CHAR)
      THEN
        x_oie_rec.name := l_oie_rec.name;
      END IF;
      IF (x_oie_rec.target_chr_id = OKC_API.G_MISS_NUM)
      THEN
        x_oie_rec.target_chr_id := l_oie_rec.target_chr_id;
      END IF;
      IF (x_oie_rec.request_id = OKC_API.G_MISS_NUM)
      THEN
        x_oie_rec.request_id := l_oie_rec.request_id;
      END IF;
      IF (x_oie_rec.program_application_id = OKC_API.G_MISS_NUM)
      THEN
        x_oie_rec.program_application_id := l_oie_rec.program_application_id;
      END IF;
      IF (x_oie_rec.program_id = OKC_API.G_MISS_NUM)
      THEN
        x_oie_rec.program_id := l_oie_rec.program_id;
      END IF;
      IF (x_oie_rec.program_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_oie_rec.program_update_date := l_oie_rec.program_update_date;
      END IF;
      IF (x_oie_rec.jtot_object1_code =  OKC_API.G_MISS_CHAR)
      THEN
        x_oie_rec.jtot_object1_code := l_oie_rec.jtot_object1_code;
      END IF;
      IF (x_oie_rec.object1_id1 = OKC_API.G_MISS_CHAR)
      THEN
        x_oie_rec.object1_id1 := l_oie_rec.object1_id1;
      END IF;
      IF (x_oie_rec.object1_id2 = OKC_API.G_MISS_CHAR)
      THEN
        x_oie_rec.object1_id2 := l_oie_rec.object1_id2;
      END IF;

-- R12 Data Model Changes 4485150 Start
      IF (x_oie_rec.batch_id = OKC_API.G_MISS_NUM) /* mmadhavi 4485150 : it is G_MISS_NUM */
      THEN
        x_oie_rec.batch_id := l_oie_rec.batch_id;
      END IF;
-- R12 Data Model Changes 4485150 Start

IF (l_debug = 'Y') THEN
   okc_debug.log('8250: Leaving  populate_new_record ', 2);
   okc_debug.Reset_Indentation;
END IF;

      RETURN(l_return_status);
    END populate_new_record;
    ------------------------------------------------
    -- Set_Attributes for:OKC_OPERATION_INSTANCES --
    ------------------------------------------------
    FUNCTION Set_Attributes (
      p_oie_rec IN  oie_rec_type,
      x_oie_rec OUT NOCOPY oie_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN

      x_oie_rec := p_oie_rec;
      RETURN(l_return_status);

    END Set_Attributes;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_OIE_PVT');
       okc_debug.log('8400: Entered update_row', 2);
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
      p_oie_rec,                         -- IN
      l_oie_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_oie_rec, l_def_oie_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKC_OPERATION_INSTANCES
    SET COP_ID = l_def_oie_rec.cop_id,
        STATUS_CODE = l_def_oie_rec.status_code,
        OBJECT_VERSION_NUMBER = l_def_oie_rec.object_version_number,
        CREATED_BY = l_def_oie_rec.created_by,
        CREATION_DATE = l_def_oie_rec.creation_date,
        LAST_UPDATED_BY = l_def_oie_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_oie_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_oie_rec.last_update_login,
        NAME = l_def_oie_rec.name,
        TARGET_CHR_ID = l_def_oie_rec.target_chr_id,

        REQUEST_ID = NVL(decode(FND_GLOBAL.CONC_REQUEST_ID,-1,NULL,FND_GLOBAL.CONC_REQUEST_ID),l_def_oie_rec.request_id),
	   PROGRAM_APPLICATION_ID = NVL(decode(FND_GLOBAL.PROG_APPL_ID,-1,NULL,FND_GLOBAL.PROG_APPL_ID),l_def_oie_rec.program_application_id),
        PROGRAM_ID = NVL(decode(FND_GLOBAL.CONC_PROGRAM_ID,-1,NULL,FND_GLOBAL.CONC_PROGRAM_ID),l_def_oie_rec.program_id),
        PROGRAM_UPDATE_DATE = decode(decode(FND_GLOBAL.CONC_REQUEST_ID,-1,NULL,SYSDATE),NULL,l_def_oie_rec.program_update_date,SYSDATE),
        JTOT_OBJECT1_CODE = l_def_oie_rec.jtot_object1_code,
        OBJECT1_ID1 = l_def_oie_rec.object1_id1,
        OBJECT1_ID2 = l_def_oie_rec.object1_id2,
-- R12 Data Model Changes 4485150 Start
        BATCH_ID = l_def_oie_rec.batch_id
-- R12 Data Model Changes 4485150 End
    WHERE ID = l_def_oie_rec.id;

    x_oie_rec := l_def_oie_rec;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);

  IF (l_debug = 'Y') THEN
     okc_debug.log('8500: Exiting update_row', 2);
     okc_debug.Reset_Indentation;
  END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('8600: Exiting update_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
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
       okc_debug.log('8700: Exiting update_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
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
       okc_debug.log('8800: Exiting update_row:OTHERS Exception', 2);
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
  ----------------------------------------------
  -- update_row for:OKC_OPERATION_INSTANCES_V --
  ----------------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oiev_rec                      IN oiev_rec_type,
    x_oiev_rec                      OUT NOCOPY oiev_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_oiev_rec                      oiev_rec_type := p_oiev_rec;
    l_def_oiev_rec                  oiev_rec_type;
    l_oie_rec                      oie_rec_type;
    lx_oie_rec                     oie_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_oiev_rec	IN oiev_rec_type
    ) RETURN oiev_rec_type IS
      l_oiev_rec	oiev_rec_type := p_oiev_rec;
    BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_OIE_PVT');
       okc_debug.log('8900: Entered fill_who_columns', 2);
    END IF;

      l_oiev_rec.LAST_UPDATE_DATE := SYSDATE;
      l_oiev_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_oiev_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_oiev_rec);

    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_oiev_rec	IN oiev_rec_type,
      x_oiev_rec	OUT NOCOPY oiev_rec_type
    ) RETURN VARCHAR2 IS
      l_oiev_rec                      oiev_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_OIE_PVT');
       okc_debug.log('9000: Entered populate_new_record', 2);
    END IF;

      x_oiev_rec := p_oiev_rec;
      -- Get current database values
      l_oiev_rec := get_rec(p_oiev_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_oiev_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_oiev_rec.id := l_oiev_rec.id;
      END IF;
      IF (x_oiev_rec.name = OKC_API.G_MISS_CHAR)
      THEN
        x_oiev_rec.name := l_oiev_rec.name;
      END IF;
      IF (x_oiev_rec.cop_id = OKC_API.G_MISS_NUM)
      THEN
        x_oiev_rec.cop_id := l_oiev_rec.cop_id;
      END IF;
      IF (x_oiev_rec.status_code = OKC_API.G_MISS_CHAR)
      THEN
        x_oiev_rec.status_code := l_oiev_rec.status_code;
      END IF;
      IF (x_oiev_rec.target_chr_id = OKC_API.G_MISS_NUM)
      THEN
        x_oiev_rec.target_chr_id := l_oiev_rec.target_chr_id;
      END IF;
      IF (x_oiev_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_oiev_rec.object_version_number := l_oiev_rec.object_version_number;
      END IF;
      IF (x_oiev_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_oiev_rec.created_by := l_oiev_rec.created_by;
      END IF;
      IF (x_oiev_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_oiev_rec.creation_date := l_oiev_rec.creation_date;
      END IF;
      IF (x_oiev_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_oiev_rec.last_updated_by := l_oiev_rec.last_updated_by;
      END IF;
      IF (x_oiev_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_oiev_rec.last_update_date := l_oiev_rec.last_update_date;
      END IF;
      IF (x_oiev_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_oiev_rec.last_update_login := l_oiev_rec.last_update_login;
      END IF;
      IF (x_oiev_rec.jtot_object1_code = OKC_API.G_MISS_CHAR)
      THEN
        x_oiev_rec.jtot_object1_code := l_oiev_rec.jtot_object1_code;
      END IF;
      IF (x_oiev_rec.object1_id1 = OKC_API.G_MISS_CHAR)
      THEN
        x_oiev_rec.object1_id1 := l_oiev_rec.object1_id1;
      END IF;
      IF (x_oiev_rec.object1_id2 = OKC_API.G_MISS_CHAR)
      THEN
        x_oiev_rec.object1_id2 := l_oiev_rec.object1_id2;
      END IF;

IF (l_debug = 'Y') THEN
   okc_debug.log('11950: Leaving  populate_new_record ', 2);
   okc_debug.Reset_Indentation;
END IF;

      RETURN(l_return_status);

    END populate_new_record;
    --------------------------------------------------
    -- Set_Attributes for:OKC_OPERATION_INSTANCES_V --
    --------------------------------------------------
    FUNCTION Set_Attributes (
      p_oiev_rec IN  oiev_rec_type,
      x_oiev_rec OUT NOCOPY oiev_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN

      x_oiev_rec := p_oiev_rec;
      x_oiev_rec.OBJECT_VERSION_NUMBER := NVL(x_oiev_rec.OBJECT_VERSION_NUMBER, 0) + 1;
      RETURN(l_return_status);

    END Set_Attributes;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_OIE_PVT');
       okc_debug.log('9200: Entered update_row', 2);
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
      p_oiev_rec,                         -- IN
      l_oiev_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_oiev_rec, l_def_oiev_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_oiev_rec := fill_who_columns(l_def_oiev_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_oiev_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_oiev_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_oiev_rec, l_oie_rec);
    --------------------------------------------
    -- Call the UPDATE_ROW for each child record
    --------------------------------------------
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_oie_rec,
      lx_oie_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_oie_rec, l_def_oiev_rec);
    x_oiev_rec := l_def_oiev_rec;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);

 IF (l_debug = 'Y') THEN
    okc_debug.log('9300: Exiting update_row', 2);
    okc_debug.Reset_Indentation;
 END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('9400: Exiting update_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
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
       okc_debug.log('9500: Exiting update_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
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
       okc_debug.log('9600: Exiting update_row:OTHERS Exception', 2);
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
  ---------------------------------------
  -- PL/SQL TBL update_row for:oiev_tbl --
  ---------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oiev_tbl                      IN oiev_tbl_type,
    x_oiev_tbl                      OUT NOCOPY oiev_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status               VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_OIE_PVT');
       okc_debug.log('9700: Entered update_row', 2);
    END IF;

    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_oiev_tbl.COUNT > 0) THEN
      i := p_oiev_tbl.FIRST;
      LOOP
        update_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_oiev_rec                      => p_oiev_tbl(i),
          x_oiev_rec                      => x_oiev_tbl(i));

          -- store the highest degree of error
          If x_return_status <> OKC_API.G_RET_STS_SUCCESS Then
             If l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR Then
                l_overall_status := x_return_status;
             End If;
          End If;

        EXIT WHEN (i = p_oiev_tbl.LAST);
        i := p_oiev_tbl.NEXT(i);
      END LOOP;
      -- return overall status
      x_return_status := l_overall_status;
    END IF;

 IF (l_debug = 'Y') THEN
    okc_debug.log('9800: Exiting update_row', 2);
    okc_debug.Reset_Indentation;
 END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('9900: Exiting update_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
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
       okc_debug.log('10000: Exiting update_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
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
       okc_debug.log('10100: Exiting update_row:OTHERS Exception', 2);
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
  --------------------------------------------
  -- delete_row for:OKC_OPERATION_INSTANCES --
  --------------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oie_rec                      IN oie_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'INSTANCES_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_oie_rec                      oie_rec_type:= p_oie_rec;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_OIE_PVT');
       okc_debug.log('10200: Entered delete_row', 2);
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
    DELETE FROM OKC_OPERATION_INSTANCES
     WHERE ID = l_oie_rec.id;

    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);

    IF (l_debug = 'Y') THEN
       okc_debug.log('10300: Exiting delete_row', 2);
       okc_debug.Reset_Indentation;
    END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('10400: Exiting delete_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
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
       okc_debug.log('10500: Exiting delete_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
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
       okc_debug.log('10600: Exiting delete_row:OTHERS Exception', 2);
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
  ----------------------------------------------
  -- delete_row for:OKC_OPERATION_INSTANCES_V --
  ----------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oiev_rec                      IN oiev_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_oiev_rec                      oiev_rec_type := p_oiev_rec;
    l_oie_rec                      oie_rec_type;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_OIE_PVT');
       okc_debug.log('10700: Entered delete_row', 2);
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
    migrate(l_oiev_rec, l_oie_rec);
    --------------------------------------------
    -- Call the DELETE_ROW for each child record
    --------------------------------------------
    delete_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_oie_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);

    IF (l_debug = 'Y') THEN
       okc_debug.log('10800: Exiting delete_row', 2);
       okc_debug.Reset_Indentation;
    END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('10900: Exiting delete_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
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
       okc_debug.log('11000: Exiting delete_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
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
       okc_debug.log('11100: Exiting delete_row:OTHERS Exception', 2);
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
  ---------------------------------------
  -- PL/SQL TBL delete_row for:oiev_tbl --
  ---------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_oiev_tbl                      IN oiev_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status               VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_OIE_PVT');
       okc_debug.log('11200: Entered delete_row', 2);
    END IF;

    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_oiev_tbl.COUNT > 0) THEN
      i := p_oiev_tbl.FIRST;
      LOOP
        delete_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_oiev_rec                      => p_oiev_tbl(i));

          -- store the highest degree of error
          If x_return_status <> OKC_API.G_RET_STS_SUCCESS Then
             If l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR Then
                l_overall_status := x_return_status;
             End If;
          End If;

        EXIT WHEN (i = p_oiev_tbl.LAST);
        i := p_oiev_tbl.NEXT(i);
      END LOOP;
      -- return overall status
      x_return_status := l_overall_status;
    END IF;

    IF (l_debug = 'Y') THEN
       okc_debug.log('11300: Exiting delete_row', 2);
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

END OKC_OIE_PVT;

/
