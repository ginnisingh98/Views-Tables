--------------------------------------------------------
--  DDL for Package Body OKL_QPY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_QPY_PVT" AS
/* $Header: OKLSQPYB.pls 115.9 2002/12/18 13:06:27 kjinger noship $ */

  ----------------------------------------
  -- GLOBAL CONSTANTS
  -- Post-Generation Change
  -- By RMUNJULU on 30-MAY-2001
  ----------------------------------------
  G_NO_PARENT_RECORD    CONSTANT VARCHAR2(200) := 'OKC_NO_PARENT_RECORD';
  G_UNEXPECTED_ERROR    CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN       CONSTANT VARCHAR2(200) := 'SQLerrm';
  G_SQLCODE_TOKEN	    CONSTANT VARCHAR2(200) := 'SQLcode';
  G_EXCEPTION_HALT_VALIDATION	EXCEPTION;

  G_FYI					CONSTANT VARCHAR2(3) := 'FYI';
  G_REC					CONSTANT VARCHAR2(3) := 'REC';
  G_APP					CONSTANT VARCHAR2(3) := 'APP';

  ------------------------------------------------------------------------
  -- PROCEDURE validate_id
  -- Post-Generation Change
  -- By RMUNJULU on 30-MAY-2001
  ------------------------------------------------------------------------
  PROCEDURE validate_id(
	x_return_status OUT NOCOPY VARCHAR2,
	p_qpyv_rec		IN	qpyv_rec_type) IS

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- data is required
	IF (p_qpyv_rec.id = OKC_API.G_MISS_NUM OR p_qpyv_rec.id IS NULL) THEN
      OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_required_value,
                          p_token1       => g_col_name_token,
                          p_token1_value => 'id');

      -- notify caller of an error
      x_return_status := OKC_API.G_RET_STS_ERROR;

      -- halt further validation of this column
      RAISE G_EXCEPTION_HALT_VALIDATION;

    END IF;

  EXCEPTION
	WHEN G_EXCEPTION_HALT_VALIDATION THEN
      -- no processing necessary; validation can continue
      -- with the next column
      NULL;
    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => sqlcode,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => sqlerrm);

      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  END validate_id;

 ------------------------------------------------------------------------
  -- PROCEDURE validate_object_version_number
  -- Post-Generation Change
  -- By RMUNJULU on 31-MAY-2001
  ------------------------------------------------------------------------
  PROCEDURE validate_object_version_number(
	x_return_status OUT NOCOPY VARCHAR2,
	p_qpyv_rec		IN	qpyv_rec_type) IS

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- data is required
    IF (p_qpyv_rec.object_version_number IS NULL)
	OR (p_qpyv_rec.object_version_number = OKC_API.G_MISS_NUM) THEN
      OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_required_value,
                          p_token1       => g_col_name_token,
                          p_token1_value => 'object_version_number');

      -- notify caller of an error
      x_return_status := OKC_API.G_RET_STS_ERROR;

      -- halt further validation of this column
      RAISE G_EXCEPTION_HALT_VALIDATION;

    END IF;

  EXCEPTION
	WHEN G_EXCEPTION_HALT_VALIDATION THEN
      -- no processing necessary; validation can continue
      -- with the next column
      NULL;
    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => sqlcode,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => sqlerrm);

    -- notify caller of an UNEXPECTED error
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  END validate_object_version_number;

 ------------------------------------------------------------------------
  -- PROCEDURE validate_allocation_percentage
  -- Post-Generation Change
  -- By RDRAGUIL on 25-JUN-2002
  ------------------------------------------------------------------------
  PROCEDURE validate_allocation_percentage(
	x_return_status OUT NOCOPY VARCHAR2,
	p_qpyv_rec		IN	qpyv_rec_type) IS

  BEGIN

    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- data is limited to a range
    IF  (p_qpyv_rec.allocation_percentage IS NOT NULL)
    AND (p_qpyv_rec.allocation_percentage <> OKC_API.G_MISS_NUM) THEN

	    IF p_qpyv_rec.allocation_percentage < 0
	    OR p_qpyv_rec.allocation_percentage > 100 THEN

		OKC_API.SET_MESSAGE(
                          p_app_name     => g_app_name,
                          p_msg_name     => g_invalid_value,
                          p_token1       => g_col_name_token,
                          p_token1_value => 'object_version_number');

		-- notify caller of an error
		x_return_status := OKC_API.G_RET_STS_ERROR;

		-- halt further validation of this column
		RAISE G_EXCEPTION_HALT_VALIDATION;

	    END IF;

    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      -- no processing necessary; validation can continue
      -- with the next column
      NULL;
    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => sqlcode,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => sqlerrm);

      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  END validate_allocation_percentage;

  ------------------------------------------------------------------------
  -- PROCEDURE validate_qte_id	: Check Not Null + Enforce foreign key
  -- Post-Generation Change
  -- By RMUNJULU on 31-MAY-2001
  ------------------------------------------------------------------------
  PROCEDURE validate_qte_id(
	x_return_status OUT NOCOPY VARCHAR2,
	p_qpyv_rec		IN	qpyv_rec_type) IS

	CURSOR  l_qte_csr IS
      SELECT  'x'
      FROM   OKL_TRX_QUOTES_V
      WHERE  ID = p_qpyv_rec.qte_id;

     l_return_status             VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
     l_dummy_var                 VARCHAR2(1) := '?';

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- data is required
    IF (p_qpyv_rec.qte_id IS NULL)
	OR (p_qpyv_rec.qte_id = OKC_API.G_MISS_NUM) THEN
      OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_required_value,
                          p_token1       => g_col_name_token,
                          p_token1_value => 'qte_id');

      -- notify caller of an error
      x_return_status := OKC_API.G_RET_STS_ERROR;

      -- halt further validation of this column
      RAISE G_EXCEPTION_HALT_VALIDATION;

    END IF;

      -- enforce foreign key
      OPEN  l_qte_csr;
      FETCH l_qte_csr INTO l_dummy_var;
      CLOSE l_qte_csr;

      -- if l_dummy_var is still set to default, data was not found
      IF (l_dummy_var = '?') THEN
        OKC_API.SET_MESSAGE(p_app_name		=> G_APP_NAME,
      			            p_msg_name		=> G_NO_PARENT_RECORD,
      			            p_token1		=> G_COL_NAME_TOKEN,
      			            p_token1_value	=> 'qte_id',
      			            p_token2		=> G_CHILD_TABLE_TOKEN,
                            p_token2_value	=> 'OKL_QUOTE_PARTIES_V',
      			            p_token3		=> G_PARENT_TABLE_TOKEN,
      			            p_token3_value	=> 'OKL_TRX_QUOTES_V');

        -- notify caller of an error
        x_return_status := OKC_API.G_RET_STS_ERROR;
      END IF;

  EXCEPTION
    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => sqlcode,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => sqlerrm);

      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

	  -- verify that cursor was closed
      IF l_qte_csr%ISOPEN THEN
        CLOSE l_qte_csr;
      END IF;

  END validate_qte_id;

  ------------------------------------------------------------------------
  -- PROCEDURE validate_cpl_id	: Check Not Null + Enforce foreign key
  -- Post-Generation Change
  -- By RMUNJULU on 31-MAY-2001
  -- By RDRAGUIL on 25-JUN-2002 - Can be null
  ------------------------------------------------------------------------
  PROCEDURE validate_cpl_id(
	x_return_status OUT NOCOPY VARCHAR2,
	p_qpyv_rec		IN	qpyv_rec_type) IS

	CURSOR  l_cpl_csr IS
      SELECT  'x'
      FROM   OKC_K_PARTY_ROLES_V
      WHERE  ID = p_qpyv_rec.cpl_id;

     l_return_status             VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
     l_dummy_var                 VARCHAR2(1) := '?';

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

/* -- Field is not reuired 25-JUN-02 RDRAGUIL

    -- data is required
    IF (p_qpyv_rec.cpl_id IS NULL)
	OR (p_qpyv_rec.cpl_id = OKC_API.G_MISS_NUM) THEN
      OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_required_value,
                          p_token1       => g_col_name_token,
                          p_token1_value => 'cpl_id');

      -- notify caller of an error
      x_return_status := OKC_API.G_RET_STS_ERROR;

      -- halt further validation of this column
      RAISE G_EXCEPTION_HALT_VALIDATION;

    END IF;
*/

    IF (p_qpyv_rec.cpl_id IS NOT NULL)
	AND (p_qpyv_rec.cpl_id <> OKC_API.G_MISS_NUM) THEN

      -- enforce foreign key
      OPEN  l_cpl_csr;
      FETCH l_cpl_csr INTO l_dummy_var;
      CLOSE l_cpl_csr;

      -- if l_dummy_var is still set to default, data was not found
      IF (l_dummy_var = '?') THEN
        OKC_API.SET_MESSAGE(p_app_name		=> G_APP_NAME,
      			            p_msg_name		=> G_NO_PARENT_RECORD,
      			            p_token1		=> G_COL_NAME_TOKEN,
      			            p_token1_value	=> 'cpl_id',
      			            p_token2		=> G_CHILD_TABLE_TOKEN,
                            p_token2_value	=> 'OKL_QUOTE_PARTIES_V',
      			            p_token3		=> G_PARENT_TABLE_TOKEN,
      			            p_token3_value	=> 'OKC_K_PARTY_ROLES_V');

        -- notify caller of an error
        x_return_status := OKC_API.G_RET_STS_ERROR;
      END IF;

    END IF;

    EXCEPTION
    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => sqlcode,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => sqlerrm);

      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

	  -- verify that cursor was closed
      IF l_cpl_csr%ISOPEN THEN
        CLOSE l_cpl_csr;
      END IF;

  END validate_cpl_id;

  ------------------------------------------------------------------------
  -- PROCEDURE validate_party_object1_code	: Enforce foreign key
  -- Post-Generation Change
  -- By RDRAGUIL on 25-JUN-2002
  ------------------------------------------------------------------------
  PROCEDURE validate_party_object1_code(
	x_return_status OUT NOCOPY VARCHAR2,
	p_qpyv_rec	IN	qpyv_rec_type) IS

	CURSOR  l_jtot_csr IS
      SELECT  'x'
      FROM   jtf_objects_vl OB
      WHERE  OB.OBJECT_CODE = p_qpyv_rec.party_jtot_object1_code;

     l_return_status             VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
     l_dummy_var                 VARCHAR2(1) := '?';

  BEGIN

    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    IF (p_qpyv_rec.party_jtot_object1_code IS NOT NULL)
	AND (p_qpyv_rec.party_jtot_object1_code <> OKC_API.G_MISS_CHAR) THEN

      -- enforce foreign key
      OPEN  l_jtot_csr;
      FETCH l_jtot_csr INTO l_dummy_var;
      CLOSE l_jtot_csr;

      -- if l_dummy_var is still set to default, data was not found
      IF (l_dummy_var = '?') THEN
        OKC_API.SET_MESSAGE(p_app_name	=> G_APP_NAME,
			p_msg_name	=> G_NO_PARENT_RECORD,
			p_token1	=> G_COL_NAME_TOKEN,
			p_token1_value	=> 'party_jtot_object1_code',
			p_token2	=> G_CHILD_TABLE_TOKEN,
			p_token2_value	=> 'OKL_QUOTE_PARTIES_V',
			p_token3	=> G_PARENT_TABLE_TOKEN,
			p_token3_value	=> 'JTF_OBJECTS_VL');

        -- notify caller of an error
        x_return_status := OKC_API.G_RET_STS_ERROR;
      END IF;

    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => sqlcode,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => sqlerrm);

      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

	  -- verify that cursor was closed
      IF l_jtot_csr%ISOPEN THEN
        CLOSE l_jtot_csr;
      END IF;

  END validate_party_object1_code;

  ------------------------------------------------------------------------
  -- PROCEDURE validate_party_object1_id1	: Enforce foreign key
  -- Post-Generation Change
  -- By RDRAGUIL on 25-JUN-2002
  ------------------------------------------------------------------------
  PROCEDURE validate_party_object1_id1 (
	x_return_status OUT NOCOPY VARCHAR2,
	p_qpyv_rec	IN	qpyv_rec_type) IS

	l_dummy_var	VARCHAR2(1) := '?';
	L_FROM_TABLE	VARCHAR2(200);
	L_WHERE_CLAUSE	VARCHAR2(2000);

	cursor l_object1_csr is
		select	from_table,
			trim(where_clause) where_clause
		from	jtf_objects_vl OB
		where	OB.OBJECT_CODE = p_qpyv_rec.party_jtot_object1_code;

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

  BEGIN

	x_return_status := OKC_API.G_RET_STS_SUCCESS;

	IF  p_qpyv_rec.party_jtot_object1_code <> OKC_API.G_MISS_CHAR
	AND p_qpyv_rec.party_jtot_object1_code IS NOT NULL
	AND p_qpyv_rec.party_object1_id1 <> OKC_API.G_MISS_CHAR
	AND p_qpyv_rec.party_object1_id1 IS NOT NULL THEN

		OPEN	l_object1_csr;
		FETCH	l_object1_csr INTO l_from_table, l_where_clause;
		CLOSE	l_object1_csr;

		IF l_where_clause IS NOT NULL THEN
			l_where_clause := ' and ' || l_where_clause;
		END IF;

		EXECUTE IMMEDIATE
			'select ''x'' from '||l_from_table||
			' where id1=:object1_id1 and id2=:object1_id2'||l_where_clause
		INTO	l_dummy_var
		USING	p_qpyv_rec.party_object1_id1, p_qpyv_rec.party_object1_id2;

	END IF;

  EXCEPTION

  when e_source_not_exists then
    OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'PARTY_JTOT_OBJECT1_CODE');
    x_return_status := OKC_API.G_RET_STS_ERROR;
  when e_source_not_exists1 then
    OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'PARTY_JTOT_OBJECT1_CODE');
    x_return_status := OKC_API.G_RET_STS_ERROR;
  when e_column_not_exists then
    OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,l_from_table||'.ID1');
    x_return_status := OKC_API.G_RET_STS_ERROR;
  when e_no_data_found then
    OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,l_from_table||'.ID1');
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

  END validate_party_object1_id1;

  ------------------------------------------------------------------------
  -- PROCEDURE validate_contact_object1_code	: Enforce foreign key
  -- Post-Generation Change
  -- By RDRAGUIL on 25-JUN-2002
  ------------------------------------------------------------------------
  PROCEDURE validate_contact_object1_code(
	x_return_status OUT NOCOPY VARCHAR2,
	p_qpyv_rec		IN	qpyv_rec_type) IS

	CURSOR  l_jtot_csr IS
      SELECT  'x'
      FROM   jtf_objects_vl OB
      WHERE  OB.OBJECT_CODE = p_qpyv_rec.contact_jtot_object1_code;

     l_return_status             VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
     l_dummy_var                 VARCHAR2(1) := '?';

  BEGIN

    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    IF (p_qpyv_rec.contact_jtot_object1_code IS NOT NULL)
	AND (p_qpyv_rec.contact_jtot_object1_code <> OKC_API.G_MISS_CHAR) THEN

      -- enforce foreign key
      OPEN  l_jtot_csr;
      FETCH l_jtot_csr INTO l_dummy_var;
      CLOSE l_jtot_csr;

      -- if l_dummy_var is still set to default, data was not found
      IF (l_dummy_var = '?') THEN
        OKC_API.SET_MESSAGE(p_app_name	=> G_APP_NAME,
			p_msg_name	=> G_NO_PARENT_RECORD,
			p_token1	=> G_COL_NAME_TOKEN,
			p_token1_value	=> 'contact_jtot_object1_code',
			p_token2	=> G_CHILD_TABLE_TOKEN,
			p_token2_value	=> 'OKL_QUOTE_PARTIES_V',
			p_token3	=> G_PARENT_TABLE_TOKEN,
			p_token3_value	=> 'JTF_OBJECTS_VL');

        -- notify caller of an error
        x_return_status := OKC_API.G_RET_STS_ERROR;
      END IF;

    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => sqlcode,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => sqlerrm);

      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

	  -- verify that cursor was closed
      IF l_jtot_csr%ISOPEN THEN
        CLOSE l_jtot_csr;
      END IF;

  END validate_contact_object1_code;

  ------------------------------------------------------------------------
  -- PROCEDURE validate_contact_object1_id1	: Enforce foreign key
  -- Post-Generation Change
  -- By RDRAGUIL on 25-JUN-2002
  ------------------------------------------------------------------------
  PROCEDURE validate_contact_object1_id1 (
	x_return_status OUT NOCOPY VARCHAR2,
	p_qpyv_rec	IN	qpyv_rec_type) IS

	l_dummy_var	VARCHAR2(1) := '?';
	L_FROM_TABLE	VARCHAR2(200);
	L_WHERE_CLAUSE	VARCHAR2(2000);

	cursor l_object1_csr is
		select	from_table,
			trim(where_clause) where_clause
		from	jtf_objects_vl OB
		where	OB.OBJECT_CODE = p_qpyv_rec.contact_jtot_object1_code;

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

  BEGIN

	x_return_status := OKC_API.G_RET_STS_SUCCESS;

	IF  p_qpyv_rec.contact_jtot_object1_code <> OKC_API.G_MISS_CHAR
	AND p_qpyv_rec.contact_jtot_object1_code IS NOT NULL
	AND p_qpyv_rec.contact_object1_id1 <> OKC_API.G_MISS_CHAR
	AND p_qpyv_rec.contact_object1_id1 IS NOT NULL THEN

		OPEN	l_object1_csr;
		FETCH	l_object1_csr INTO l_from_table, l_where_clause;
		CLOSE	l_object1_csr;

		IF l_where_clause IS NOT NULL THEN
			l_where_clause := ' and ' || l_where_clause;
		END IF;

		EXECUTE IMMEDIATE
			'select ''x'' from '||l_from_table||
			' where id1=:object1_id1 and id2=:object1_id2'||l_where_clause
		INTO	l_dummy_var
		USING	p_qpyv_rec.contact_object1_id1, p_qpyv_rec.contact_object1_id2;

	END IF;

  EXCEPTION

  when e_source_not_exists then
    OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'CONTACT_JTOT_OBJECT1_CODE');
    x_return_status := OKC_API.G_RET_STS_ERROR;
  when e_source_not_exists1 then
    OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'CONTACT_JTOT_OBJECT1_CODE');
    x_return_status := OKC_API.G_RET_STS_ERROR;
  when e_column_not_exists then
    OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,l_from_table||'.ID1');
    x_return_status := OKC_API.G_RET_STS_ERROR;
  when e_no_data_found then
    OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,l_from_table||'.ID1');
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

  END validate_contact_object1_id1;

  ------------------------------------------------------------------------
  -- PROCEDURE validate_qpt_code
  -- Post-Generation Change
  -- By RMUNJULU on 30-MAY-2001
  ------------------------------------------------------------------------
  PROCEDURE validate_qpt_code(
	x_return_status OUT NOCOPY VARCHAR2,
	p_qpyv_rec		IN	qpyv_rec_type) IS

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- data is required
    IF (p_qpyv_rec.qpt_code IS NULL)
	OR (p_qpyv_rec.qpt_code = OKC_API.G_MISS_NUM) THEN
      OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_required_value,
                          p_token1       => g_col_name_token,
                          p_token1_value => 'qpt_code');

      -- notify caller of an error
      x_return_status := OKC_API.G_RET_STS_ERROR;

      -- halt further validation of this column
      RAISE G_EXCEPTION_HALT_VALIDATION;

    END IF;

	-- Qpt_type value should be in the value in FND_LOOKUPS
    x_return_status := OKL_UTIL.check_lookup_code(
						 p_lookup_type 	=>	'OKL_QUOTE_PARTY_TYPE'
						,p_lookup_code 	=>	p_qpyv_rec.qpt_code);

    IF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        OKC_API.SET_MESSAGE(p_app_name		=> G_APP_NAME,
      			            p_msg_name		=> G_INVALID_VALUE,
      			            p_token1		=> G_COL_NAME_TOKEN,
      			            p_token1_value	=> 'qpt_code');

        raise G_EXCEPTION_HALT_VALIDATION;

     ELSIF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN

        raise G_EXCEPTION_HALT_VALIDATION;

     end if;

  EXCEPTION
	WHEN G_EXCEPTION_HALT_VALIDATION THEN
      -- no processing necessary; validation can continue
      -- with the next column
      NULL;
    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => sqlcode,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => sqlerrm);

      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  END validate_qpt_code;


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
  -- FUNCTION get_rec for: OKL_QUOTE_PARTIES
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_qpy_rec                      IN qpy_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN qpy_rec_type IS
    CURSOR okl_quote_parties_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            QTE_ID,
            CPL_ID,
            OBJECT_VERSION_NUMBER,
            DATE_SENT,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN,
            DELAY_DAYS,
            ALLOCATION_PERCENTAGE,
            EMAIL_ADDRESS,
            PARTY_JTOT_OBJECT1_CODE,
            PARTY_OBJECT1_ID1,
            PARTY_OBJECT1_ID2,
            CONTACT_JTOT_OBJECT1_CODE,
            CONTACT_OBJECT1_ID1,
            CONTACT_OBJECT1_ID2,
            QPT_CODE
      FROM Okl_Quote_Parties
     WHERE okl_quote_parties.id = p_id;
    l_okl_quote_parties_pk         okl_quote_parties_pk_csr%ROWTYPE;
    l_qpy_rec                      qpy_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_quote_parties_pk_csr (p_qpy_rec.id);
    FETCH okl_quote_parties_pk_csr INTO
              l_qpy_rec.ID,
              l_qpy_rec.QTE_ID,
              l_qpy_rec.CPL_ID,
              l_qpy_rec.OBJECT_VERSION_NUMBER,
              l_qpy_rec.DATE_SENT,
              l_qpy_rec.CREATED_BY,
              l_qpy_rec.CREATION_DATE,
              l_qpy_rec.LAST_UPDATED_BY,
              l_qpy_rec.LAST_UPDATE_DATE,
              l_qpy_rec.LAST_UPDATE_LOGIN,
              l_qpy_rec.DELAY_DAYS,
              l_qpy_rec.ALLOCATION_PERCENTAGE,
              l_qpy_rec.EMAIL_ADDRESS,
              l_qpy_rec.PARTY_JTOT_OBJECT1_CODE,
              l_qpy_rec.PARTY_OBJECT1_ID1,
              l_qpy_rec.PARTY_OBJECT1_ID2,
              l_qpy_rec.CONTACT_JTOT_OBJECT1_CODE,
              l_qpy_rec.CONTACT_OBJECT1_ID1,
              l_qpy_rec.CONTACT_OBJECT1_ID2,
              l_qpy_rec.QPT_CODE;
    x_no_data_found := okl_quote_parties_pk_csr%NOTFOUND;
    CLOSE okl_quote_parties_pk_csr;
    RETURN(l_qpy_rec);
  END get_rec;

  FUNCTION get_rec (
    p_qpy_rec                      IN qpy_rec_type
  ) RETURN qpy_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_qpy_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_QUOTE_PARTIES_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_qpyv_rec                     IN qpyv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN qpyv_rec_type IS
    CURSOR okl_qpyv_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            OBJECT_VERSION_NUMBER,
            QTE_ID,
            CPL_ID,
            DATE_SENT,
            DELAY_DAYS,
            ALLOCATION_PERCENTAGE,
            EMAIL_ADDRESS,
            PARTY_JTOT_OBJECT1_CODE,
            PARTY_OBJECT1_ID1,
            PARTY_OBJECT1_ID2,
            CONTACT_JTOT_OBJECT1_CODE,
            CONTACT_OBJECT1_ID1,
            CONTACT_OBJECT1_ID2,
            QPT_CODE,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
      FROM Okl_Quote_Parties_V
     WHERE okl_quote_parties_v.id = p_id;
    l_okl_qpyv_pk                  okl_qpyv_pk_csr%ROWTYPE;
    l_qpyv_rec                     qpyv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_qpyv_pk_csr (p_qpyv_rec.id);
    FETCH okl_qpyv_pk_csr INTO
              l_qpyv_rec.ID,
              l_qpyv_rec.OBJECT_VERSION_NUMBER,
              l_qpyv_rec.QTE_ID,
              l_qpyv_rec.CPL_ID,
              l_qpyv_rec.DATE_SENT,
              l_qpyv_rec.DELAY_DAYS,
              l_qpyv_rec.ALLOCATION_PERCENTAGE,
              l_qpyv_rec.EMAIL_ADDRESS,
              l_qpyv_rec.PARTY_JTOT_OBJECT1_CODE,
              l_qpyv_rec.PARTY_OBJECT1_ID1,
              l_qpyv_rec.PARTY_OBJECT1_ID2,
              l_qpyv_rec.CONTACT_JTOT_OBJECT1_CODE,
              l_qpyv_rec.CONTACT_OBJECT1_ID1,
              l_qpyv_rec.CONTACT_OBJECT1_ID2,
              l_qpyv_rec.QPT_CODE,
              l_qpyv_rec.CREATED_BY,
              l_qpyv_rec.CREATION_DATE,
              l_qpyv_rec.LAST_UPDATED_BY,
              l_qpyv_rec.LAST_UPDATE_DATE,
              l_qpyv_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okl_qpyv_pk_csr%NOTFOUND;
    CLOSE okl_qpyv_pk_csr;
    RETURN(l_qpyv_rec);
  END get_rec;

  FUNCTION get_rec (
    p_qpyv_rec                     IN qpyv_rec_type
  ) RETURN qpyv_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_qpyv_rec, l_row_notfound));
  END get_rec;

  ---------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKL_QUOTE_PARTIES_V --
  ---------------------------------------------------------
  FUNCTION null_out_defaults (
    p_qpyv_rec	IN qpyv_rec_type
  ) RETURN qpyv_rec_type IS
    l_qpyv_rec	qpyv_rec_type := p_qpyv_rec;
  BEGIN
    IF (l_qpyv_rec.object_version_number = OKC_API.G_MISS_NUM) THEN
      l_qpyv_rec.object_version_number := NULL;
    END IF;
    IF (l_qpyv_rec.qte_id = OKC_API.G_MISS_NUM) THEN
      l_qpyv_rec.qte_id := NULL;
    END IF;
    IF (l_qpyv_rec.cpl_id = OKC_API.G_MISS_NUM) THEN
      l_qpyv_rec.cpl_id := NULL;
    END IF;
    IF (l_qpyv_rec.date_sent = OKC_API.G_MISS_DATE) THEN
      l_qpyv_rec.date_sent := NULL;
    END IF;
    IF (l_qpyv_rec.qpt_code = OKC_API.G_MISS_CHAR) THEN
      l_qpyv_rec.qpt_code := NULL;
    END IF;
    IF (l_qpyv_rec.created_by = OKC_API.G_MISS_NUM) THEN
      l_qpyv_rec.created_by := NULL;
    END IF;
    IF (l_qpyv_rec.creation_date = OKC_API.G_MISS_DATE) THEN
      l_qpyv_rec.creation_date := NULL;
    END IF;
    IF (l_qpyv_rec.last_updated_by = OKC_API.G_MISS_NUM) THEN
      l_qpyv_rec.last_updated_by := NULL;
    END IF;
    IF (l_qpyv_rec.last_update_date = OKC_API.G_MISS_DATE) THEN
      l_qpyv_rec.last_update_date := NULL;
    END IF;
    IF (l_qpyv_rec.last_update_login = OKC_API.G_MISS_NUM) THEN
      l_qpyv_rec.last_update_login := NULL;
    END IF;
    IF (l_qpyv_rec.delay_days = OKC_API.G_MISS_NUM) THEN
      l_qpyv_rec.delay_days := NULL;
    END IF;
    IF (l_qpyv_rec.allocation_percentage = OKC_API.G_MISS_NUM) THEN
      l_qpyv_rec.allocation_percentage := NULL;
    END IF;
    IF (l_qpyv_rec.email_address = OKC_API.G_MISS_CHAR) THEN
      l_qpyv_rec.email_address := NULL;
    END IF;
    IF (l_qpyv_rec.party_jtot_object1_code = OKC_API.G_MISS_CHAR) THEN
      l_qpyv_rec.party_jtot_object1_code := NULL;
    END IF;
    IF (l_qpyv_rec.party_object1_id1 = OKC_API.G_MISS_CHAR) THEN
      l_qpyv_rec.party_object1_id1 := NULL;
    END IF;
    IF (l_qpyv_rec.party_object1_id2 = OKC_API.G_MISS_CHAR) THEN
      l_qpyv_rec.party_object1_id2 := NULL;
    END IF;
    IF (l_qpyv_rec.contact_jtot_object1_code = OKC_API.G_MISS_CHAR) THEN
      l_qpyv_rec.contact_jtot_object1_code := NULL;
    END IF;
    IF (l_qpyv_rec.contact_object1_id1 = OKC_API.G_MISS_CHAR) THEN
      l_qpyv_rec.contact_object1_id1 := NULL;
    END IF;
    IF (l_qpyv_rec.contact_object1_id2 = OKC_API.G_MISS_CHAR) THEN
      l_qpyv_rec.contact_object1_id2 := NULL;
    END IF;
    RETURN(l_qpyv_rec);
  END null_out_defaults;
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Attributes
  -- Post-Generation Change
  -- By RMUNJULU on 31-MAY-2001
  ---------------------------------------------------------------------------
  -------------------------------------------------
  -- Validate_Attributes for:OKL_QUOTE_PARTIES_V --
  -------------------------------------------------
  FUNCTION Validate_Attributes (
    p_qpyv_rec IN  qpyv_rec_type
  ) RETURN VARCHAR2 IS

    x_return_status  VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_return_status  VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

  BEGIN
    -- call column-level validation for 'id'
    validate_id(x_return_status => l_return_status,
                p_qpyv_rec      => p_qpyv_rec);

    -- store the highest degree of error
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        x_return_status := l_return_status;
      END IF;
    END IF;

    -- call column-level validation for 'object_version_number'
    validate_object_version_number(x_return_status => l_return_status,
                 				   p_qpyv_rec      => p_qpyv_rec);

    -- store the highest degree of error
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        x_return_status := l_return_status;
      END IF;
    END IF;

    -- call column-level validation for 'qte_id'
    validate_qte_id(x_return_status => l_return_status,
                 	p_qpyv_rec      => p_qpyv_rec);

    -- store the highest degree of error
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        x_return_status := l_return_status;
      END IF;
    END IF;

    -- call column-level validation for 'cpl_id'
    validate_cpl_id(x_return_status => l_return_status,
                 	p_qpyv_rec      => p_qpyv_rec);

    -- store the highest degree of error
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        x_return_status := l_return_status;
      END IF;
    END IF;

    -- call column-level validation for 'qpy_type'
    validate_qpt_code(x_return_status => l_return_status,
                 	  p_qpyv_rec      => p_qpyv_rec);

    -- store the highest degree of error
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        x_return_status := l_return_status;
      END IF;
    END IF;

    -- call column-level validation for 'allocation_percentage'
    validate_allocation_percentage(
		x_return_status => l_return_status,
		p_qpyv_rec      => p_qpyv_rec);

    -- store the highest degree of error
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        x_return_status := l_return_status;
      END IF;
    END IF;

    -- call column-level validation for 'allocation_percentage'
    validate_party_object1_code(
		x_return_status => l_return_status,
		p_qpyv_rec      => p_qpyv_rec);

    -- store the highest degree of error
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        x_return_status := l_return_status;
      END IF;
    END IF;

    -- call column-level validation for 'allocation_percentage'
    validate_party_object1_id1(
		x_return_status => l_return_status,
		p_qpyv_rec      => p_qpyv_rec);

    -- store the highest degree of error
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        x_return_status := l_return_status;
      END IF;
    END IF;

    -- call column-level validation for 'allocation_percentage'
    validate_contact_object1_code(
		x_return_status => l_return_status,
		p_qpyv_rec      => p_qpyv_rec);

    -- store the highest degree of error
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        x_return_status := l_return_status;
      END IF;
    END IF;

    -- call column-level validation for 'allocation_percentage'
    validate_contact_object1_id1(
		x_return_status => l_return_status,
		p_qpyv_rec      => p_qpyv_rec);

    -- store the highest degree of error
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        x_return_status := l_return_status;
      END IF;
    END IF;

    -- return status to caller
    RETURN x_return_status;

  EXCEPTION
    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                        p_msg_name     => g_unexpected_error,
                        p_token1       => g_sqlcode_token,
                        p_token1_value => sqlcode,
                        p_token2       => g_sqlerrm_token,
                        p_token2_value => sqlerrm);

      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

      -- return status to caller
      RETURN x_return_status;

  END validate_attributes;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Record
  ---------------------------------------------------------------------------
  ---------------------------------------------
  -- Validate_Record for:OKL_QUOTE_PARTIES_V --
  ---------------------------------------------
  FUNCTION Validate_Record (
    p_qpyv_rec IN qpyv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    ------------------------------------
    -- FUNCTION validate_foreign_keys --
    ------------------------------------
    FUNCTION validate_foreign_keys (
      p_qpyv_rec IN qpyv_rec_type
    ) RETURN VARCHAR2 IS
      item_not_found_error          EXCEPTION;
      CURSOR okc_cplv_pk_csr (p_id                 IN NUMBER) IS
      SELECT
              ID,
              OBJECT_VERSION_NUMBER,
              SFWT_FLAG,
              CHR_ID,
              CPL_ID,
              CLE_ID,
              RLE_CODE,
              DNZ_CHR_ID,
              OBJECT1_ID1,
              OBJECT1_ID2,
              JTOT_OBJECT1_CODE,
              COGNOMEN,
              CODE,
              FACILITY,
              MINORITY_GROUP_LOOKUP_CODE,
              SMALL_BUSINESS_FLAG,
              WOMEN_OWNED_FLAG,
              ALIAS,
              ROLE,
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
        FROM Okc_K_Party_Roles_V
       WHERE okc_k_party_roles_v.id = p_id;
      l_okc_cplv_pk                  okc_cplv_pk_csr%ROWTYPE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
      l_row_notfound                 BOOLEAN := TRUE;
    BEGIN
      IF (p_qpyv_rec.CPL_ID IS NOT NULL)
      THEN
        OPEN okc_cplv_pk_csr(p_qpyv_rec.CPL_ID);
        FETCH okc_cplv_pk_csr INTO l_okc_cplv_pk;
        l_row_notfound := okc_cplv_pk_csr%NOTFOUND;
        CLOSE okc_cplv_pk_csr;
        IF (l_row_notfound) THEN
          OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'CPL_ID');
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
    l_return_status := validate_foreign_keys (p_qpyv_rec);
    RETURN (l_return_status);
  END Validate_Record;

  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from	IN qpyv_rec_type,
    p_to	IN OUT NOCOPY qpy_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.qte_id := p_from.qte_id;
    p_to.cpl_id := p_from.cpl_id;
    p_to.object_version_number := p_from.object_version_number;
    p_to.date_sent := p_from.date_sent;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
    p_to.delay_days := p_from.delay_days;
    p_to.allocation_percentage := p_from.allocation_percentage;
    p_to.email_address := p_from.email_address;
    p_to.party_jtot_object1_code := p_from.party_jtot_object1_code;
    p_to.party_object1_id1 := p_from.party_object1_id1;
    p_to.party_object1_id2 := p_from.party_object1_id2;
    p_to.contact_jtot_object1_code := p_from.contact_jtot_object1_code;
    p_to.contact_object1_id1 := p_from.contact_object1_id1;
    p_to.contact_object1_id2 := p_from.contact_object1_id2;
    p_to.qpt_code := p_from.qpt_code;
  END migrate;
  PROCEDURE migrate (
    p_from	IN qpy_rec_type,
    p_to	IN OUT NOCOPY qpyv_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.qte_id := p_from.qte_id;
    p_to.cpl_id := p_from.cpl_id;
    p_to.object_version_number := p_from.object_version_number;
    p_to.date_sent := p_from.date_sent;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
    p_to.delay_days := p_from.delay_days;
    p_to.allocation_percentage := p_from.allocation_percentage;
    p_to.email_address := p_from.email_address;
    p_to.party_jtot_object1_code := p_from.party_jtot_object1_code;
    p_to.party_object1_id1 := p_from.party_object1_id1;
    p_to.party_object1_id2 := p_from.party_object1_id2;
    p_to.contact_jtot_object1_code := p_from.contact_jtot_object1_code;
    p_to.contact_object1_id1 := p_from.contact_object1_id1;
    p_to.contact_object1_id2 := p_from.contact_object1_id2;
    p_to.qpt_code := p_from.qpt_code;
  END migrate;

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_row
  ---------------------------------------------------------------------------
  ------------------------------------------
  -- validate_row for:OKL_QUOTE_PARTIES_V --
  ------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qpyv_rec                     IN qpyv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_qpyv_rec                     qpyv_rec_type := p_qpyv_rec;
    l_qpy_rec                      qpy_rec_type;
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
    l_return_status := Validate_Attributes(l_qpyv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_qpyv_rec);
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
  -- PL/SQL TBL validate_row for:QPYV_TBL --
  ------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qpyv_tbl                     IN qpyv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_qpyv_tbl.COUNT > 0) THEN
      i := p_qpyv_tbl.FIRST;
      LOOP
        validate_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_qpyv_rec                     => p_qpyv_tbl(i));
        EXIT WHEN (i = p_qpyv_tbl.LAST);
        i := p_qpyv_tbl.NEXT(i);
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
  --------------------------------------
  -- insert_row for:OKL_QUOTE_PARTIES --
  --------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qpy_rec                      IN qpy_rec_type,
    x_qpy_rec                      OUT NOCOPY qpy_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'PARTIES_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_qpy_rec                      qpy_rec_type := p_qpy_rec;
    l_def_qpy_rec                  qpy_rec_type;
    ------------------------------------------
    -- Set_Attributes for:OKL_QUOTE_PARTIES --
    ------------------------------------------
    FUNCTION Set_Attributes (
      p_qpy_rec IN  qpy_rec_type,
      x_qpy_rec OUT NOCOPY qpy_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_qpy_rec := p_qpy_rec;
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
      p_qpy_rec,                         -- IN
      l_qpy_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKL_QUOTE_PARTIES(
        id,
        qte_id,
        cpl_id,
        object_version_number,
        date_sent,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        last_update_login,
        delay_days,
        allocation_percentage,
        email_address,
        party_jtot_object1_code,
        party_object1_id1,
        party_object1_id2,
        contact_jtot_object1_code,
        contact_object1_id1,
        contact_object1_id2,
        qpt_code)
      VALUES (
        l_qpy_rec.id,
        l_qpy_rec.qte_id,
        l_qpy_rec.cpl_id,
        l_qpy_rec.object_version_number,
        l_qpy_rec.date_sent,
        l_qpy_rec.created_by,
        l_qpy_rec.creation_date,
        l_qpy_rec.last_updated_by,
        l_qpy_rec.last_update_date,
        l_qpy_rec.last_update_login,
        l_qpy_rec.delay_days,
        l_qpy_rec.allocation_percentage,
        l_qpy_rec.email_address,
        l_qpy_rec.party_jtot_object1_code,
        l_qpy_rec.party_object1_id1,
        l_qpy_rec.party_object1_id2,
        l_qpy_rec.contact_jtot_object1_code,
        l_qpy_rec.contact_object1_id1,
        l_qpy_rec.contact_object1_id2,
        l_qpy_rec.qpt_code);
    -- Set OUT values
    x_qpy_rec := l_qpy_rec;
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
  -- insert_row for:OKL_QUOTE_PARTIES_V --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qpyv_rec                     IN qpyv_rec_type,
    x_qpyv_rec                     OUT NOCOPY qpyv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_qpyv_rec                     qpyv_rec_type;
    l_def_qpyv_rec                 qpyv_rec_type;
    l_qpy_rec                      qpy_rec_type;
    lx_qpy_rec                     qpy_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_qpyv_rec	IN qpyv_rec_type
    ) RETURN qpyv_rec_type IS
      l_qpyv_rec	qpyv_rec_type := p_qpyv_rec;
    BEGIN
      l_qpyv_rec.CREATION_DATE := SYSDATE;
      l_qpyv_rec.CREATED_BY := FND_GLOBAL.USER_ID;
      l_qpyv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_qpyv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_qpyv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_qpyv_rec);
    END fill_who_columns;
    --------------------------------------------
    -- Set_Attributes for:OKL_QUOTE_PARTIES_V --
    --------------------------------------------
    FUNCTION Set_Attributes (
      p_qpyv_rec IN  qpyv_rec_type,
      x_qpyv_rec OUT NOCOPY qpyv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_qpyv_rec := p_qpyv_rec;
      x_qpyv_rec.OBJECT_VERSION_NUMBER := 1;
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
    l_qpyv_rec := null_out_defaults(p_qpyv_rec);
    -- Set primary key value
    l_qpyv_rec.ID := get_seq_id;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      l_qpyv_rec,                        -- IN
      l_def_qpyv_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_qpyv_rec := fill_who_columns(l_def_qpyv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
-- ravi
--    l_return_status := Validate_Attributes(l_def_qpyv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
-- ravi
--    l_return_status := Validate_Record(l_def_qpyv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_qpyv_rec, l_qpy_rec);
    --------------------------------------------
    -- Call the INSERT_ROW for each child record
    --------------------------------------------
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_qpy_rec,
      lx_qpy_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_qpy_rec, l_def_qpyv_rec);
    -- Set OUT values
    x_qpyv_rec := l_def_qpyv_rec;
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
  -- PL/SQL TBL insert_row for:QPYV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qpyv_tbl                     IN qpyv_tbl_type,
    x_qpyv_tbl                     OUT NOCOPY qpyv_tbl_type) IS

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
    IF (p_qpyv_tbl.COUNT > 0) THEN
      i := p_qpyv_tbl.FIRST;
      LOOP
        insert_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_qpyv_rec                     => p_qpyv_tbl(i),
          x_qpyv_rec                     => x_qpyv_tbl(i));
        -- Begin Post-Generation Change
        -- store the highest degree of error
        IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
           IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
              l_overall_status := x_return_status;
           END IF;
        END IF;
        -- End Post-Generation Change
        EXIT WHEN (i = p_qpyv_tbl.LAST);
        i := p_qpyv_tbl.NEXT(i);
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
  ------------------------------------
  -- lock_row for:OKL_QUOTE_PARTIES --
  ------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qpy_rec                      IN qpy_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_qpy_rec IN qpy_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_QUOTE_PARTIES
     WHERE ID = p_qpy_rec.id
       AND OBJECT_VERSION_NUMBER = p_qpy_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR  lchk_csr (p_qpy_rec IN qpy_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_QUOTE_PARTIES
    WHERE ID = p_qpy_rec.id;
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'PARTIES_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_object_version_number       OKL_QUOTE_PARTIES.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number      OKL_QUOTE_PARTIES.OBJECT_VERSION_NUMBER%TYPE;
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
      OPEN lock_csr(p_qpy_rec);
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
      OPEN lchk_csr(p_qpy_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_qpy_rec.object_version_number THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_qpy_rec.object_version_number THEN
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
  --------------------------------------
  -- lock_row for:OKL_QUOTE_PARTIES_V --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qpyv_rec                     IN qpyv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_qpy_rec                      qpy_rec_type;
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
    migrate(p_qpyv_rec, l_qpy_rec);
    --------------------------------------------
    -- Call the LOCK_ROW for each child record
    --------------------------------------------
    lock_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_qpy_rec
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
  -- PL/SQL TBL lock_row for:QPYV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qpyv_tbl                     IN qpyv_tbl_type) IS

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
    IF (p_qpyv_tbl.COUNT > 0) THEN
      i := p_qpyv_tbl.FIRST;
      LOOP
        lock_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_qpyv_rec                     => p_qpyv_tbl(i));
        -- Begin Post-Generation Change
        -- store the highest degree of error
        IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
           IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
              l_overall_status := x_return_status;
           END IF;
        END IF;
        -- End Post-Generation Change
        EXIT WHEN (i = p_qpyv_tbl.LAST);
        i := p_qpyv_tbl.NEXT(i);
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
  --------------------------------------
  -- update_row for:OKL_QUOTE_PARTIES --
  --------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qpy_rec                      IN qpy_rec_type,
    x_qpy_rec                      OUT NOCOPY qpy_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'PARTIES_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_qpy_rec                      qpy_rec_type := p_qpy_rec;
    l_def_qpy_rec                  qpy_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_qpy_rec	IN qpy_rec_type,
      x_qpy_rec	OUT NOCOPY qpy_rec_type
    ) RETURN VARCHAR2 IS
      l_qpy_rec                      qpy_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_qpy_rec := p_qpy_rec;
      -- Get current database values
      l_qpy_rec := get_rec(p_qpy_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_qpy_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_qpy_rec.id := l_qpy_rec.id;
      END IF;
      IF (x_qpy_rec.qte_id = OKC_API.G_MISS_NUM)
      THEN
        x_qpy_rec.qte_id := l_qpy_rec.qte_id;
      END IF;
      IF (x_qpy_rec.cpl_id = OKC_API.G_MISS_NUM)
      THEN
        x_qpy_rec.cpl_id := l_qpy_rec.cpl_id;
      END IF;
      IF (x_qpy_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_qpy_rec.object_version_number := l_qpy_rec.object_version_number;
      END IF;
      IF (x_qpy_rec.date_sent = OKC_API.G_MISS_DATE)
      THEN
        x_qpy_rec.date_sent := l_qpy_rec.date_sent;
      END IF;
      IF (x_qpy_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_qpy_rec.created_by := l_qpy_rec.created_by;
      END IF;
      IF (x_qpy_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_qpy_rec.creation_date := l_qpy_rec.creation_date;
      END IF;
      IF (x_qpy_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_qpy_rec.last_updated_by := l_qpy_rec.last_updated_by;
      END IF;
      IF (x_qpy_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_qpy_rec.last_update_date := l_qpy_rec.last_update_date;
      END IF;
      IF (x_qpy_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_qpy_rec.last_update_login := l_qpy_rec.last_update_login;
      END IF;
      IF (x_qpy_rec.qpt_code = OKC_API.G_MISS_CHAR)
      THEN
        x_qpy_rec.qpt_code := l_qpy_rec.qpt_code;
      END IF;
      IF (x_qpy_rec.delay_days = OKC_API.G_MISS_NUM)
      THEN
        x_qpy_rec.delay_days := l_qpy_rec.delay_days;
      END IF;
      IF (x_qpy_rec.allocation_percentage = OKC_API.G_MISS_NUM)
      THEN
        x_qpy_rec.allocation_percentage := l_qpy_rec.allocation_percentage;
      END IF;
      IF (x_qpy_rec.email_address = OKC_API.G_MISS_CHAR)
      THEN
        x_qpy_rec.email_address := l_qpy_rec.email_address;
      END IF;
      IF (x_qpy_rec.party_jtot_object1_code = OKC_API.G_MISS_CHAR)
      THEN
        x_qpy_rec.party_jtot_object1_code := l_qpy_rec.party_jtot_object1_code;
      END IF;
      IF (x_qpy_rec.party_object1_id1 = OKC_API.G_MISS_CHAR)
      THEN
        x_qpy_rec.party_object1_id1 := l_qpy_rec.party_object1_id1;
      END IF;
      IF (x_qpy_rec.party_object1_id2 = OKC_API.G_MISS_CHAR)
      THEN
        x_qpy_rec.party_object1_id2 := l_qpy_rec.party_object1_id2;
      END IF;
      IF (x_qpy_rec.contact_jtot_object1_code = OKC_API.G_MISS_CHAR)
      THEN
        x_qpy_rec.contact_jtot_object1_code := l_qpy_rec.contact_jtot_object1_code;
      END IF;
      IF (x_qpy_rec.contact_object1_id1 = OKC_API.G_MISS_CHAR)
      THEN
        x_qpy_rec.contact_object1_id1 := l_qpy_rec.contact_object1_id1;
      END IF;
      IF (x_qpy_rec.contact_object1_id2 = OKC_API.G_MISS_CHAR)
      THEN
        x_qpy_rec.contact_object1_id2 := l_qpy_rec.contact_object1_id2;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ------------------------------------------
    -- Set_Attributes for:OKL_QUOTE_PARTIES --
    ------------------------------------------
    FUNCTION Set_Attributes (
      p_qpy_rec IN  qpy_rec_type,
      x_qpy_rec OUT NOCOPY qpy_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_qpy_rec := p_qpy_rec;
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
      p_qpy_rec,                         -- IN
      l_qpy_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_qpy_rec, l_def_qpy_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKL_QUOTE_PARTIES
    SET QTE_ID = l_def_qpy_rec.qte_id,
        CPL_ID = l_def_qpy_rec.cpl_id,
        OBJECT_VERSION_NUMBER = l_def_qpy_rec.object_version_number,
        DATE_SENT = l_def_qpy_rec.date_sent,
        CREATED_BY = l_def_qpy_rec.created_by,
        CREATION_DATE = l_def_qpy_rec.creation_date,
        LAST_UPDATED_BY = l_def_qpy_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_qpy_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_qpy_rec.last_update_login,
        DELAY_DAYS = l_def_qpy_rec.delay_days,
        ALLOCATION_PERCENTAGE = l_def_qpy_rec.allocation_percentage,
        EMAIL_ADDRESS = l_def_qpy_rec.email_address,
        PARTY_JTOT_OBJECT1_CODE = l_def_qpy_rec.party_jtot_object1_code,
        PARTY_OBJECT1_ID1 = l_def_qpy_rec.party_object1_id1,
        PARTY_OBJECT1_ID2 = l_def_qpy_rec.party_object1_id2,
        CONTACT_JTOT_OBJECT1_CODE = l_def_qpy_rec.contact_jtot_object1_code,
        CONTACT_OBJECT1_ID1 = l_def_qpy_rec.contact_object1_id1,
        CONTACT_OBJECT1_ID2 = l_def_qpy_rec.contact_object1_id2,
        QPT_CODE = l_def_qpy_rec.qpt_code
    WHERE ID = l_def_qpy_rec.id;

    x_qpy_rec := l_def_qpy_rec;
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
  -- update_row for:OKL_QUOTE_PARTIES_V --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qpyv_rec                     IN qpyv_rec_type,
    x_qpyv_rec                     OUT NOCOPY qpyv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_qpyv_rec                     qpyv_rec_type := p_qpyv_rec;
    l_def_qpyv_rec                 qpyv_rec_type;
    l_qpy_rec                      qpy_rec_type;
    lx_qpy_rec                     qpy_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_qpyv_rec	IN qpyv_rec_type
    ) RETURN qpyv_rec_type IS
      l_qpyv_rec	qpyv_rec_type := p_qpyv_rec;
    BEGIN
      l_qpyv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_qpyv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_qpyv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_qpyv_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_qpyv_rec	IN qpyv_rec_type,
      x_qpyv_rec	OUT NOCOPY qpyv_rec_type
    ) RETURN VARCHAR2 IS
      l_qpyv_rec                     qpyv_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_qpyv_rec := p_qpyv_rec;
      -- Get current database values
      l_qpyv_rec := get_rec(p_qpyv_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_qpyv_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_qpyv_rec.id := l_qpyv_rec.id;
      END IF;
      IF (x_qpyv_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_qpyv_rec.object_version_number := l_qpyv_rec.object_version_number;
      END IF;
      IF (x_qpyv_rec.qte_id = OKC_API.G_MISS_NUM)
      THEN
        x_qpyv_rec.qte_id := l_qpyv_rec.qte_id;
      END IF;
      IF (x_qpyv_rec.cpl_id = OKC_API.G_MISS_NUM)
      THEN
        x_qpyv_rec.cpl_id := l_qpyv_rec.cpl_id;
      END IF;
      IF (x_qpyv_rec.date_sent = OKC_API.G_MISS_DATE)
      THEN
        x_qpyv_rec.date_sent := l_qpyv_rec.date_sent;
      END IF;
      IF (x_qpyv_rec.qpt_code = OKC_API.G_MISS_CHAR)
      THEN
        x_qpyv_rec.qpt_code := l_qpyv_rec.qpt_code;
      END IF;
      IF (x_qpyv_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_qpyv_rec.created_by := l_qpyv_rec.created_by;
      END IF;
      IF (x_qpyv_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_qpyv_rec.creation_date := l_qpyv_rec.creation_date;
      END IF;
      IF (x_qpyv_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_qpyv_rec.last_updated_by := l_qpyv_rec.last_updated_by;
      END IF;
      IF (x_qpyv_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_qpyv_rec.last_update_date := l_qpyv_rec.last_update_date;
      END IF;
      IF (x_qpyv_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_qpyv_rec.last_update_login := l_qpyv_rec.last_update_login;
      END IF;
      IF (x_qpyv_rec.delay_days = OKC_API.G_MISS_NUM)
      THEN
        x_qpyv_rec.delay_days := l_qpyv_rec.delay_days;
      END IF;
      IF (x_qpyv_rec.allocation_percentage = OKC_API.G_MISS_NUM)
      THEN
        x_qpyv_rec.allocation_percentage := l_qpyv_rec.allocation_percentage;
      END IF;
      IF (x_qpyv_rec.email_address = OKC_API.G_MISS_CHAR)
      THEN
        x_qpyv_rec.email_address := l_qpyv_rec.email_address;
      END IF;
      IF (x_qpyv_rec.party_jtot_object1_code = OKC_API.G_MISS_CHAR)
      THEN
        x_qpyv_rec.party_jtot_object1_code := l_qpyv_rec.party_jtot_object1_code;
      END IF;
      IF (x_qpyv_rec.party_object1_id1 = OKC_API.G_MISS_CHAR)
      THEN
        x_qpyv_rec.party_object1_id1 := l_qpyv_rec.party_object1_id1;
      END IF;
      IF (x_qpyv_rec.party_object1_id2 = OKC_API.G_MISS_CHAR)
      THEN
        x_qpyv_rec.party_object1_id2 := l_qpyv_rec.party_object1_id2;
      END IF;
      IF (x_qpyv_rec.contact_jtot_object1_code = OKC_API.G_MISS_CHAR)
      THEN
        x_qpyv_rec.contact_jtot_object1_code := l_qpyv_rec.contact_jtot_object1_code;
      END IF;
      IF (x_qpyv_rec.contact_object1_id1 = OKC_API.G_MISS_CHAR)
      THEN
        x_qpyv_rec.contact_object1_id1 := l_qpyv_rec.contact_object1_id1;
      END IF;
      IF (x_qpyv_rec.contact_object1_id2 = OKC_API.G_MISS_CHAR)
      THEN
        x_qpyv_rec.contact_object1_id2 := l_qpyv_rec.contact_object1_id2;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    --------------------------------------------
    -- Set_Attributes for:OKL_QUOTE_PARTIES_V --
    --------------------------------------------
    FUNCTION Set_Attributes (
      p_qpyv_rec IN  qpyv_rec_type,
      x_qpyv_rec OUT NOCOPY qpyv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_qpyv_rec := p_qpyv_rec;
      x_qpyv_rec.OBJECT_VERSION_NUMBER := NVL(x_qpyv_rec.OBJECT_VERSION_NUMBER, 0) + 1;
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
      p_qpyv_rec,                        -- IN
      l_qpyv_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_qpyv_rec, l_def_qpyv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_qpyv_rec := fill_who_columns(l_def_qpyv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_qpyv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_qpyv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_qpyv_rec, l_qpy_rec);
    --------------------------------------------
    -- Call the UPDATE_ROW for each child record
    --------------------------------------------
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_qpy_rec,
      lx_qpy_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_qpy_rec, l_def_qpyv_rec);
    x_qpyv_rec := l_def_qpyv_rec;
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
  -- PL/SQL TBL update_row for:QPYV_TBL --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qpyv_tbl                     IN qpyv_tbl_type,
    x_qpyv_tbl                     OUT NOCOPY qpyv_tbl_type) IS

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
    IF (p_qpyv_tbl.COUNT > 0) THEN
      i := p_qpyv_tbl.FIRST;
      LOOP
        update_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_qpyv_rec                     => p_qpyv_tbl(i),
          x_qpyv_rec                     => x_qpyv_tbl(i));
        -- Begin Post-Generation Change
        -- store the highest degree of error
        IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
           IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
              l_overall_status := x_return_status;
           END IF;
        END IF;
        -- End Post-Generation Change
        EXIT WHEN (i = p_qpyv_tbl.LAST);
        i := p_qpyv_tbl.NEXT(i);
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
  --------------------------------------
  -- delete_row for:OKL_QUOTE_PARTIES --
  --------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qpy_rec                      IN qpy_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'PARTIES_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_qpy_rec                      qpy_rec_type:= p_qpy_rec;
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
    DELETE FROM OKL_QUOTE_PARTIES
     WHERE ID = l_qpy_rec.id;

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
  -- delete_row for:OKL_QUOTE_PARTIES_V --
  ----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qpyv_rec                     IN qpyv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_qpyv_rec                     qpyv_rec_type := p_qpyv_rec;
    l_qpy_rec                      qpy_rec_type;
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
    migrate(l_qpyv_rec, l_qpy_rec);
    --------------------------------------------
    -- Call the DELETE_ROW for each child record
    --------------------------------------------
    delete_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_qpy_rec
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
  -- PL/SQL TBL delete_row for:QPYV_TBL --
  ----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qpyv_tbl                     IN qpyv_tbl_type) IS

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
    IF (p_qpyv_tbl.COUNT > 0) THEN
      i := p_qpyv_tbl.FIRST;
      LOOP
        delete_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_qpyv_rec                     => p_qpyv_tbl(i));
        -- Begin Post-Generation Change
        -- store the highest degree of error
        IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
           IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
              l_overall_status := x_return_status;
           END IF;
        END IF;
        -- End Post-Generation Change
        EXIT WHEN (i = p_qpyv_tbl.LAST);
        i := p_qpyv_tbl.NEXT(i);
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
END OKL_QPY_PVT;

/
