--------------------------------------------------------
--  DDL for Package Body OKL_PTM_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_PTM_PVT" AS
/* $Header: OKLSPTMB.pls 120.12 2007/08/08 12:48:53 arajagop noship $ */
  ---------------------------------------------------------------------------
  -- FUNCTION get_seq_id
  ---------------------------------------------------------------------------
  FUNCTION get_seq_id RETURN NUMBER IS
  BEGIN
    RETURN(Okc_P_Util.raw_to_number(sys_guid()));
  END get_seq_id;

  ---------------------------------------------------------------------------
  -- PROCEDURE qc
  ---------------------------------------------------------------------------
  PROCEDURE qc IS
  BEGIN
    NULL;
  END qc;

  ---------------------------------------------------------------------------
  -- PROCEDURE change_version
  ---------------------------------------------------------------------------
  PROCEDURE change_version IS
  BEGIN
    NULL;
  END change_version;

  ---------------------------------------------------------------------------
  -- PROCEDURE api_copy
  ---------------------------------------------------------------------------
  PROCEDURE api_copy IS
  BEGIN
    NULL;
  END api_copy;


  ---------------------------------------------------------------------------
  -- PROCEDURE validate_id
  ---------------------------------------------------------------------------
  PROCEDURE validate_id(p_ptmv_rec          IN  ptmv_rec_type,
                        x_return_status     OUT NOCOPY VARCHAR2) IS

  BEGIN

    x_return_status := OKL_API.G_RET_STS_SUCCESS;

    IF p_ptmv_rec.id = OKL_API.G_MISS_NUM OR p_ptmv_rec.id IS NULL THEN

      OKL_API.set_message(G_APP_NAME,
                          G_REQUIRED_VALUE,
                          G_COL_NAME_TOKEN,
                          'ID');
      x_return_status := OKL_API.G_RET_STS_ERROR;
      RETURN;

    END IF;

  EXCEPTION

    WHEN OTHERS THEN

      OKL_API.set_message(G_APP_NAME,
                          G_UNEXPECTED_ERROR,
                          G_SQLCODE_TOKEN,
                          SQLCODE,
                          G_SQLERRM_TOKEN,
                          SQLERRM);
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

  END validate_id;


  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_object_version_number
  ---------------------------------------------------------------------------
  PROCEDURE validate_object_version_number(p_ptmv_rec      IN ptmv_rec_type,
                                           x_return_status OUT NOCOPY VARCHAR2) IS

  BEGIN

    x_return_status := OKL_API.G_RET_STS_SUCCESS;

    IF p_ptmv_rec.object_version_number = OKL_API.G_MISS_NUM OR
       p_ptmv_rec.object_version_number IS NULL THEN

      OKL_API.set_message(G_APP_NAME,
                          G_REQUIRED_VALUE,
                          G_COL_NAME_TOKEN,
                          'OBJECT_VERSION_NUMBER');
      x_return_status := OKL_API.G_RET_STS_ERROR;
      RETURN;

    END IF;

  EXCEPTION

    WHEN OTHERS THEN

      OKL_API.set_message(G_APP_NAME,
                          G_UNEXPECTED_ERROR,
                          G_SQLCODE_TOKEN,
                          SQLCODE,
                          G_SQLERRM_TOKEN,
                          SQLERRM);
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

  END validate_object_version_number;


  ---------------------------------------------------------------------------
  -- PROCEDURE validate_org_id
  ---------------------------------------------------------------------------
  PROCEDURE validate_org_id(p_ptmv_rec        IN ptmv_rec_type,
                            x_return_status 	OUT NOCOPY VARCHAR2) IS

    l_dummy_var         NUMBER;
    l_org_id            NUMBER;
    l_org_id_original   NUMBER;

    CURSOR c_ptmv_org IS
      SELECT NVL(org_id, -99)
      FROM   okl_process_tmplts_b
      WHERE  id = p_ptmv_rec.id;

  BEGIN

    x_return_status := OKL_API.G_RET_STS_SUCCESS;

    OPEN  c_ptmv_org;
    FETCH c_ptmv_org INTO l_org_id_original;

    IF c_ptmv_org%FOUND THEN

      --fnd_profile.get('ORG_ID', l_org_id);
      l_org_id := mo_global.get_current_org_id();

      IF l_org_id_original <> NVL(l_org_id, -99) THEN


        OKL_API.set_message(p_app_name => G_APP_NAME,
                            p_msg_name => 'OKL_UPDATING_OTHER_ORG_RECORD');

        x_return_status := OKL_API.G_RET_STS_ERROR;

      END IF;

    END IF;

    CLOSE c_ptmv_org;

  EXCEPTION

    WHEN OTHERS THEN

      OKL_API.set_message(G_APP_NAME,
                          G_UNEXPECTED_ERROR,
                          G_SQLCODE_TOKEN,
                          SQLCODE,
                          G_SQLERRM_TOKEN,
                          SQLERRM);
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

  END validate_org_id;

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_ptm_code
  ---------------------------------------------------------------------------
  PROCEDURE validate_ptm_code(p_ptmv_rec        IN ptmv_rec_type,
                              x_return_status 	OUT NOCOPY VARCHAR2) IS

    l_dummy_var         VARCHAR2(1);

    CURSOR l_ptmv_csr IS
      SELECT 1
      FROM   fnd_lookups
      WHERE  lookup_code = p_ptmv_rec.ptm_code AND
             lookup_type = 'OKL_PROCESSES';

  BEGIN

    x_return_status := OKL_API.G_RET_STS_SUCCESS;

    IF p_ptmv_rec.ptm_code = OKL_API.G_MISS_CHAR OR p_ptmv_rec.ptm_code IS NULL THEN

      OKL_API.set_message(G_APP_NAME,
                          G_REQUIRED_VALUE,
                          G_COL_NAME_TOKEN,
                          'PTM_CODE');
      x_return_status := OKL_API.G_RET_STS_ERROR;
      RETURN;

    END IF;

    OPEN  l_ptmv_csr;
    FETCH l_ptmv_csr into l_dummy_var;

    IF l_ptmv_csr%NOTFOUND THEN
      OKL_API.set_message(p_app_name => G_APP_NAME,
                          p_msg_name => G_NO_PARENT_RECORD,
			              p_token1   => G_COL_NAME_TOKEN,
                          p_token1_value => 'PTM_CODE',
			  p_token2  => G_CHILD_TABLE_TOKEN,
			  p_token2_value => 'OKL_PROCESS_TMPLTS_V',
                          p_token3 => G_PARENT_TABLE_TOKEN,
			  p_token3_value => 'FND_LOOKUPS');
      x_return_status := OKL_API.G_RET_STS_ERROR;
    END IF;

    CLOSE l_ptmv_csr;

  EXCEPTION

    WHEN OTHERS THEN

      OKL_API.set_message(G_APP_NAME,
                          G_UNEXPECTED_ERROR,
                          G_SQLCODE_TOKEN,
                          SQLCODE,
                          G_SQLERRM_TOKEN,
                          SQLERRM);
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

  END validate_ptm_code;


  ---------------------------------------------------------------------------
  -- PROCEDURE validate_jtf_amv_item_id
  ---------------------------------------------------------------------------
  PROCEDURE validate_jtf_amv_item_id(p_ptmv_rec          IN ptmv_rec_type,
                                     x_return_status 	 OUT NOCOPY VARCHAR2) IS

    l_dummy_var         VARCHAR2(1);

  --As of now JTF Fulfillment only populates the status_code column.  Date columns not used.
    CURSOR  l_ptmv_csr IS
      SELECT 1
      FROM   jtf_amv_items_b
      WHERE  item_id = p_ptmv_rec.jtf_amv_item_id AND
             status_code = 'ACTIVE';

  BEGIN

    x_return_status := OKL_API.G_RET_STS_SUCCESS;

    IF p_ptmv_rec.jtf_amv_item_id = OKL_API.G_MISS_NUM OR p_ptmv_rec.jtf_amv_item_id IS NULL THEN

      OKL_API.set_message(G_APP_NAME,
                          G_REQUIRED_VALUE,
                          G_COL_NAME_TOKEN,
                          'JTF_AMV_ITEM_ID');
      x_return_status := OKL_API.G_RET_STS_ERROR;
      RETURN;

    END IF;

    OPEN  l_ptmv_csr;
    FETCH l_ptmv_csr INTO l_dummy_var;

    IF l_ptmv_csr%NOTFOUND THEN
      OKL_API.set_message(  p_app_name      => G_APP_NAME,
                            p_msg_name      => G_NO_PARENT_RECORD,
			                p_token1        => G_COL_NAME_TOKEN,
		                    p_token1_value  => 'template',
	                        p_token2        => G_CHILD_TABLE_TOKEN,
		                    p_token2_value  => 'OKL_PROCESS_TMPLTS_V',
                            p_token3        => G_PARENT_TABLE_TOKEN,
			                p_token3_value  => 'JTF_AMV_ITEMS_VL');
      x_return_status := OKL_API.G_RET_STS_ERROR;

    END IF;

    CLOSE l_ptmv_csr;


  EXCEPTION

    WHEN OTHERS THEN

      OKL_API.set_message(G_APP_NAME,
                          G_UNEXPECTED_ERROR,
                          G_SQLCODE_TOKEN,
                          SQLCODE,
                          G_SQLERRM_TOKEN,
                          SQLERRM);
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

 END validate_jtf_amv_item_id;

/*      13-OCT-2006      ANSETHUR
        BUILD  : R12 B
        Start Changes
*/

 ---------------------------------------------------------------------------
  -- PROCEDURE Validate_xml_tmplt_code
  ---------------------------------------------------------------------------
  PROCEDURE Validate_xml_tmplt_code(p_ptmv_rec          IN ptmv_rec_type,
                                     x_return_status 	 OUT NOCOPY VARCHAR2) IS

    l_dummy_var         VARCHAR2(1);

    CURSOR  l_ptmv_csr IS
      SELECT 1
      FROM   XDO_TEMPLATES_B
     WHERE  template_code = p_ptmv_rec.xml_tmplt_code;

  BEGIN

    x_return_status := OKL_API.G_RET_STS_SUCCESS;

    IF (p_ptmv_rec.xml_tmplt_code = OKL_API.G_MISS_CHAR OR p_ptmv_rec.xml_tmplt_code IS NULL) THEN
      OKL_API.set_message(G_APP_NAME,
                          G_REQUIRED_VALUE,
                          G_COL_NAME_TOKEN,
                          'XML_TMPLT_CODE');
      x_return_status := OKL_API.G_RET_STS_ERROR;

      RETURN;

    END IF;

    OPEN  l_ptmv_csr;
    FETCH l_ptmv_csr INTO l_dummy_var;

    IF l_ptmv_csr%NOTFOUND THEN
      OKL_API.set_message(p_app_name        => G_APP_NAME,
                          p_msg_name        => G_INVALID_VALUE,
                          p_token1          => G_COL_NAME_TOKEN,
                          p_token1_value    => 'XML_TMPLT_CODE');
      x_return_status := OKL_API.G_RET_STS_ERROR;
    END IF;

    CLOSE l_ptmv_csr;


  EXCEPTION

    WHEN OTHERS THEN

      OKL_API.set_message(G_APP_NAME,
                          G_UNEXPECTED_ERROR,
                          G_SQLCODE_TOKEN,
                          SQLCODE,
                          G_SQLERRM_TOKEN,
                          SQLERRM);
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

 END Validate_xml_tmplt_code;

 ---------------------------------------------------------------------------
  -- PROCEDURE Validate_recipient_type
  ---------------------------------------------------------------------------

  PROCEDURE validate_recipient_type_code(p_ptmv_rec        IN ptmv_rec_type,
                              x_return_status 	OUT NOCOPY VARCHAR2) IS

    l_dummy_var         VARCHAR2(1);

    CURSOR l_ptmv_csr IS
      SELECT 1
      FROM   fnd_lookups
      WHERE  lookup_code = p_ptmv_rec.recipient_type_code AND
             lookup_type = 'OKL_RECIPIENT_TYPE';

  BEGIN

    x_return_status := OKL_API.G_RET_STS_SUCCESS;

    IF p_ptmv_rec.recipient_type_code = OKL_API.G_MISS_CHAR OR p_ptmv_rec.recipient_type_code IS NULL THEN

      OKL_API.set_message(G_APP_NAME,
                          G_REQUIRED_VALUE,
                          G_COL_NAME_TOKEN,
                          'RECIPIENT_TYPE_CODE');
      x_return_status := OKL_API.G_RET_STS_ERROR;
      RETURN;

    END IF;

    OPEN  l_ptmv_csr;
    FETCH l_ptmv_csr into l_dummy_var;

    IF l_ptmv_csr%NOTFOUND THEN
      OKL_API.set_message(p_app_name        => G_APP_NAME,
                          p_msg_name        => G_INVALID_VALUE,
                          p_token1          => G_COL_NAME_TOKEN,
                          p_token1_value    => 'RECIPIENT_TYPE_CODE');

      x_return_status := OKL_API.G_RET_STS_ERROR;
    END IF;

    CLOSE l_ptmv_csr;

  EXCEPTION

    WHEN OTHERS THEN

      OKL_API.set_message(G_APP_NAME,
                          G_UNEXPECTED_ERROR,
                          G_SQLCODE_TOKEN,
                          SQLCODE,
                          G_SQLERRM_TOKEN,
                          SQLERRM);
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

  END validate_recipient_type_code;

/*        End  Changes         */
   ---------------------------------------------------------------------------
  -- PROCEDURE Validate_tmplt_record
  ---------------------------------------------------------------------------
 PROCEDURE Validate_tmplt_record(   p_ptmv_rec               IN ptmv_rec_type,
                                    x_return_status          OUT NOCOPY VARCHAR2) IS

                                    l_dummy_var              VARCHAR2(1);
                                --  l_return_status          VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
                                    l_dummy                  VARCHAR2(1);
                                    l_start_date             DATE;

    CURSOR c_check_dates IS
    SELECT start_date
    FROM   okl_process_tmplts_b
    WHERE  ptm_code = p_ptmv_rec.ptm_code
    AND    recipient_type_code = p_ptmv_rec.recipient_type_code
    AND    xml_tmplt_code = p_ptmv_rec.xml_tmplt_code
    AND    id <> p_ptmv_rec.id
    AND    TRUNC(start_date) > TRUNC(p_ptmv_rec.start_date)
    ORDER BY start_date asc;


    CURSOR c_ptmv_uk IS
      SELECT 1
      FROM   okl_process_tmplts_b
      WHERE  ptm_code = p_ptmv_rec.ptm_code AND
             recipient_type_code = p_ptmv_rec.recipient_type_code AND
             xml_tmplt_code = p_ptmv_rec.xml_tmplt_code   AND
             id <> p_ptmv_rec.id AND
             TRUNC(start_date)<= TRUNC(p_ptmv_rec.start_date) AND
            ( TRUNC(end_date) >= TRUNC(p_ptmv_rec.start_date) OR
              end_date IS NULL ) ;


  BEGIN

    IF TRUNC(p_ptmv_rec.end_date) < TRUNC(p_ptmv_rec.start_date) THEN

      OKL_API.set_message(p_app_name   => G_APP_NAME,
                          p_msg_name   => 'OKL_INVALID_TO_DATE');

      x_return_status := OKL_API.G_RET_STS_ERROR;
        RETURN ;

    END IF;


    OPEN c_check_dates;
    FETCH c_check_dates INTO l_start_date;
    IF c_check_dates%FOUND THEN
      IF ( nvl(TRUNC(p_ptmv_rec.end_date),l_start_date) >= l_start_date ) THEN
        OKL_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                            p_msg_name     => 'OKL_OVERLAP_END_DATE',
                            p_token1       => 'START_DATE',
                            p_token1_value => l_start_date,
                            p_token2       => 'END_DATE',
                            p_token2_value => l_start_date);
        x_return_status  := OKL_API.G_RET_STS_ERROR;
        CLOSE c_check_dates;
        RETURN ;
      END IF;
    END IF;
    CLOSE c_check_dates;


    OPEN c_ptmv_uk;
    FETCH c_ptmv_uk INTO l_dummy;

    IF c_ptmv_uk%FOUND THEN

      OKL_API.set_message(p_app_name     => G_APP_NAME,
                          p_msg_name     => 'OKL_TEMPLATE_EXISTS');

      x_return_status := OKL_API.G_RET_STS_ERROR;
      return;

    END IF;

    CLOSE c_ptmv_uk;

    RETURN ;

 EXCEPTION

      WHEN OTHERS THEN
        OKL_API.set_message(p_app_name    => g_app_name,
                           p_msg_name     => g_unexpected_error,
                           p_token1       => g_sqlcode_token,
                           p_token1_value => sqlcode,
                           p_token2       => g_sqlerrm_token,
                           p_token2_value => sqlerrm);
        x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

        RETURN;

  END Validate_tmplt_record;


  ---------------------------------------------------------------------------
  -- PROCEDURE validate_start_date
  ---------------------------------------------------------------------------
  PROCEDURE validate_start_date(p_ptmv_rec          IN ptmv_rec_type,
                                x_return_status     OUT NOCOPY VARCHAR2) IS

    CURSOR c_ptmv_sdate IS
      SELECT TRUNC(start_date)
      FROM   okl_process_tmplts_b
      WHERE  id = p_ptmv_rec.id;

    l_start_date  DATE;

  BEGIN

    x_return_status := OKL_API.G_RET_STS_SUCCESS;

    IF p_ptmv_rec.start_date = OKL_API.G_MISS_DATE OR p_ptmv_rec.start_date IS NULL THEN

      OKL_API.set_message(G_APP_NAME,
                          G_REQUIRED_VALUE,
                          G_COL_NAME_TOKEN,
                          'START_DATE');

      x_return_status := OKL_API.G_RET_STS_ERROR;
      RETURN;

    END IF;

    OPEN  c_ptmv_sdate;
    FETCH c_ptmv_sdate into l_start_date;

    --Changed the following condn and changed <= to < for
    -- the Start date.
    --This is to allow update of the process template
    --on the same day that it is created.
    --Changed by rvaduri as part of bug 3561848

    IF c_ptmv_sdate%FOUND AND
       l_start_date <> TRUNC(p_ptmv_rec.start_date) AND
       l_start_date < TRUNC(SYSDATE) THEN
      OKL_API.set_message(p_app_name => G_APP_NAME,
                          p_msg_name => 'OKL_ACTIVE_REC_EFF_FROM');

      x_return_status := OKL_API.G_RET_STS_ERROR;
      CLOSE c_ptmv_sdate;
      RETURN;

    ELSIF c_ptmv_sdate%NOTFOUND AND TRUNC(p_ptmv_rec.start_date) < TRUNC(SYSDATE) THEN
      OKL_API.set_message(p_app_name => G_APP_NAME,
                             p_msg_name => 'OKL_INVALID_EFF_FROM_DATE');
      x_return_status := OKL_API.G_RET_STS_ERROR;
      CLOSE c_ptmv_sdate;
      RETURN;

    END IF;

    IF c_ptmv_sdate%ISOPEN THEN
      CLOSE c_ptmv_sdate;
    END IF;

  EXCEPTION

    WHEN OTHERS THEN
      OKL_API.set_message(G_APP_NAME,
                          G_UNEXPECTED_ERROR,
                          G_SQLCODE_TOKEN,
                          SQLCODE,
                          G_SQLERRM_TOKEN,
                          SQLERRM);
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

  END validate_start_date;


  ---------------------------------------------------------------------------
  -- PROCEDURE validate_end_date
  ---------------------------------------------------------------------------
  PROCEDURE validate_end_date(p_ptmv_rec          IN ptmv_rec_type,
                              x_return_status     OUT NOCOPY VARCHAR2) IS

  BEGIN

    x_return_status := OKL_API.G_RET_STS_SUCCESS;

    IF TRUNC(p_ptmv_rec.end_date) < TRUNC(SYSDATE) THEN

      OKL_API.set_message(G_APP_NAME,
                          'OKL_INVALID_EFF_TO_DATE');

      x_return_status := OKL_API.G_RET_STS_ERROR;
      RETURN;

    END IF;

  EXCEPTION

    WHEN OTHERS THEN

      OKL_API.set_message(G_APP_NAME,
                          G_UNEXPECTED_ERROR,
                          G_SQLCODE_TOKEN,
                          SQLCODE,
                          G_SQLERRM_TOKEN,
                          SQLERRM);
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

  END validate_end_date;

  ---------------------------------------------------------------------------
  -- PROCEDURE add_language
  ---------------------------------------------------------------------------
  PROCEDURE add_language IS
  BEGIN
    DELETE FROM okl_process_tmplts_tl T
     WHERE NOT EXISTS (
        SELECT NULL
          FROM OKL_PROCESS_TMPLTS_ALL_B  B --Changed _tl to _b by rvaduri for MLS compliance
         WHERE B.ID = T.ID
        );

    UPDATE okl_process_tmplts_tl T SET (
        EMAIL_SUBJECT_LINE) = (SELECT
                                  B.EMAIL_SUBJECT_LINE
                                FROM okl_process_tmplts_tl B
                               WHERE B.ID = T.ID
                                 AND B.LANGUAGE = T.SOURCE_LANG)
      WHERE (
              T.ID,
              T.LANGUAGE)
          IN (SELECT
                  SUBT.ID,
                  SUBT.LANGUAGE
                FROM okl_process_tmplts_tl SUBB, okl_process_tmplts_tl SUBT
               WHERE SUBB.ID = SUBT.ID
                 AND SUBB.LANGUAGE = SUBT.SOURCE_LANG
                 AND (SUBB.EMAIL_SUBJECT_LINE <> SUBT.EMAIL_SUBJECT_LINE
                      OR (SUBB.EMAIL_SUBJECT_LINE IS NULL AND SUBT.EMAIL_SUBJECT_LINE IS NOT NULL)
                      OR (SUBB.EMAIL_SUBJECT_LINE IS NOT NULL AND SUBT.EMAIL_SUBJECT_LINE IS NULL)
              ));

    INSERT INTO okl_process_tmplts_tl (
        ID,
        LANGUAGE,
        SOURCE_LANG,
        SFWT_FLAG,
        EMAIL_SUBJECT_LINE,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_DATE,
        LAST_UPDATE_LOGIN)
      SELECT
            B.ID,
            L.LANGUAGE_CODE,
            B.SOURCE_LANG,
            B.SFWT_FLAG,
            B.EMAIL_SUBJECT_LINE,
            B.CREATED_BY,
            B.CREATION_DATE,
            B.LAST_UPDATED_BY,
            B.LAST_UPDATE_DATE,
            B.LAST_UPDATE_LOGIN
        FROM okl_process_tmplts_tl B, FND_LANGUAGES L
       WHERE L.INSTALLED_FLAG IN ('I', 'B')
         AND B.LANGUAGE = USERENV('LANG')
         AND NOT EXISTS(
                    SELECT NULL
                      FROM okl_process_tmplts_tl T
                     WHERE T.ID = B.ID
                       AND T.LANGUAGE = L.LANGUAGE_CODE
                    );

  END add_language;


  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: okl_process_tmplts_b
  ---------------------------------------------------------------------------
  FUNCTION get_rec (p_ptm_rec        IN ptm_rec_type,
                    x_no_data_found  OUT NOCOPY BOOLEAN) RETURN ptm_rec_type IS

    CURSOR okl_process_tmplts_b_pk_csr (p_id IN NUMBER) IS
    SELECT
            ID,
            ORG_ID,
            PTM_CODE,
            JTF_AMV_ITEM_ID,
            START_DATE,
            END_DATE,
            OBJECT_VERSION_NUMBER,
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
/*      13-OCT-2006  	ANSETHUR
        BUILD  : R12 B
        Start Changes
*/
            RECIPIENT_TYPE_CODE,
            XML_TMPLT_CODE
/*        End  Changes         */
      FROM okl_process_tmplts_b
     WHERE okl_process_tmplts_b.id = p_id;

    l_ptm_rec                        ptm_rec_type;

  BEGIN

    OPEN okl_process_tmplts_b_pk_csr (p_ptm_rec.id);
    FETCH okl_process_tmplts_b_pk_csr INTO
              l_ptm_rec.ID,
              l_ptm_rec.ORG_ID,
              l_ptm_rec.PTM_CODE,
              l_ptm_rec.JTF_AMV_ITEM_ID,
              l_ptm_rec.START_DATE,
              l_ptm_rec.END_DATE,
              l_ptm_rec.OBJECT_VERSION_NUMBER,
              l_ptm_rec.ATTRIBUTE_CATEGORY,
              l_ptm_rec.ATTRIBUTE1,
              l_ptm_rec.ATTRIBUTE2,
              l_ptm_rec.ATTRIBUTE3,
              l_ptm_rec.ATTRIBUTE4,
              l_ptm_rec.ATTRIBUTE5,
              l_ptm_rec.ATTRIBUTE6,
              l_ptm_rec.ATTRIBUTE7,
              l_ptm_rec.ATTRIBUTE8,
              l_ptm_rec.ATTRIBUTE9,
              l_ptm_rec.ATTRIBUTE10,
              l_ptm_rec.ATTRIBUTE11,
              l_ptm_rec.ATTRIBUTE12,
              l_ptm_rec.ATTRIBUTE13,
              l_ptm_rec.ATTRIBUTE14,
              l_ptm_rec.ATTRIBUTE15,
              l_ptm_rec.CREATED_BY,
              l_ptm_rec.CREATION_DATE,
              l_ptm_rec.LAST_UPDATED_BY,
              l_ptm_rec.LAST_UPDATE_DATE,
              l_ptm_rec.LAST_UPDATE_LOGIN,
/*      13-OCT-2006   ANSETHUR
        BUILD  : R12 B
        Start Changes
*/
              l_ptm_rec.recipient_type_code ,
              l_ptm_rec.xml_tmplt_code
              ;
/*        End  Changes         */
    x_no_data_found := okl_process_tmplts_b_pk_csr%NOTFOUND;

    CLOSE okl_process_tmplts_b_pk_csr;
    RETURN(l_ptm_rec);
  END get_rec;

  FUNCTION get_rec (p_ptm_rec IN ptm_rec_type) RETURN ptm_rec_type IS

    l_row_notfound  BOOLEAN;

  BEGIN
    RETURN(get_rec(p_ptm_rec, l_row_notfound));
  END get_rec;


  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: okl_process_tmplts_tl
  ---------------------------------------------------------------------------
  FUNCTION get_rec (p_okl_process_tmplts_tl_rec     IN okl_process_tmplts_tl_rec_type,
                    x_no_data_found                 OUT NOCOPY BOOLEAN) RETURN okl_process_tmplts_tl_rec_type IS

    CURSOR okl_process_tmplts_tl_pk_csr (p_id                 IN NUMBER,
                                         p_language           IN VARCHAR2) IS
      SELECT
            ID,
            LANGUAGE,
            SOURCE_LANG,
            SFWT_FLAG,
            EMAIL_SUBJECT_LINE,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
      FROM  okl_process_tmplts_tl
      WHERE okl_process_tmplts_tl.id = p_id
      AND okl_process_tmplts_tl.LANGUAGE = p_language;

    l_okl_process_tmplts_tl_rec    okl_process_tmplts_tl_rec_type;

  BEGIN

    OPEN okl_process_tmplts_tl_pk_csr (p_okl_process_tmplts_tl_rec.id,
                                       p_okl_process_tmplts_tl_rec.LANGUAGE);

    FETCH okl_process_tmplts_tl_pk_csr INTO
              l_okl_process_tmplts_tl_rec.ID,
              l_okl_process_tmplts_tl_rec.LANGUAGE,
              l_okl_process_tmplts_tl_rec.SOURCE_LANG,
              l_okl_process_tmplts_tl_rec.SFWT_FLAG,
              l_okl_process_tmplts_tl_rec.EMAIL_SUBJECT_LINE,
              l_okl_process_tmplts_tl_rec.CREATED_BY,
              l_okl_process_tmplts_tl_rec.CREATION_DATE,
              l_okl_process_tmplts_tl_rec.LAST_UPDATED_BY,
              l_okl_process_tmplts_tl_rec.LAST_UPDATE_DATE,
              l_okl_process_tmplts_tl_rec.LAST_UPDATE_LOGIN;

    x_no_data_found := okl_process_tmplts_tl_pk_csr%NOTFOUND;
    CLOSE okl_process_tmplts_tl_pk_csr;
    RETURN(l_okl_process_tmplts_tl_rec);

  END get_rec;

  FUNCTION get_rec (p_okl_process_tmplts_tl_rec    IN okl_process_tmplts_tl_rec_type)
                   RETURN okl_process_tmplts_tl_rec_type IS

    l_row_notfound                 BOOLEAN;

  BEGIN
    RETURN(get_rec(p_okl_process_tmplts_tl_rec, l_row_notfound));
  END get_rec;


  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: okl_process_tmplts_v
  ---------------------------------------------------------------------------
  FUNCTION get_rec (p_ptmv_rec         IN ptmv_rec_type,
                    x_no_data_found    OUT NOCOPY BOOLEAN) RETURN ptmv_rec_type IS

    CURSOR okl_ptmv_pk_csr (p_id IN NUMBER) IS
    SELECT
            ID,
            ORG_ID,
            PTM_CODE,
            JTF_AMV_ITEM_ID,
            SFWT_FLAG,
            EMAIL_SUBJECT_LINE,
            START_DATE,
            END_DATE,
            OBJECT_VERSION_NUMBER,
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

/*      13-OCT-2006  	ANSETHUR
        BUILD  : R12 B
        Start Changes
*/
            recipient_type_code ,
            xml_tmplt_code
/*        End  Changes         */
      FROM okl_process_tmplts_v
     WHERE okl_process_tmplts_v.id = p_id;

    l_ptmv_rec                     ptmv_rec_type;

  BEGIN

    OPEN okl_ptmv_pk_csr (p_ptmv_rec.id);
    FETCH okl_ptmv_pk_csr INTO
              l_ptmv_rec.ID,
              l_ptmv_rec.ORG_ID,
              l_ptmv_rec.PTM_CODE,
              l_ptmv_rec.JTF_AMV_ITEM_ID,
              l_ptmv_rec.SFWT_FLAG,
              l_ptmv_rec.EMAIL_SUBJECT_LINE,
              l_ptmv_rec.START_DATE,
              l_ptmv_rec.END_DATE,
              l_ptmv_rec.OBJECT_VERSION_NUMBER,
              l_ptmv_rec.ATTRIBUTE_CATEGORY,
              l_ptmv_rec.ATTRIBUTE1,
              l_ptmv_rec.ATTRIBUTE2,
              l_ptmv_rec.ATTRIBUTE3,
              l_ptmv_rec.ATTRIBUTE4,
              l_ptmv_rec.ATTRIBUTE5,
              l_ptmv_rec.ATTRIBUTE6,
              l_ptmv_rec.ATTRIBUTE7,
              l_ptmv_rec.ATTRIBUTE8,
              l_ptmv_rec.ATTRIBUTE9,
              l_ptmv_rec.ATTRIBUTE10,
              l_ptmv_rec.ATTRIBUTE11,
              l_ptmv_rec.ATTRIBUTE12,
              l_ptmv_rec.ATTRIBUTE13,
              l_ptmv_rec.ATTRIBUTE14,
              l_ptmv_rec.ATTRIBUTE15,
              l_ptmv_rec.CREATED_BY,
              l_ptmv_rec.CREATION_DATE,
              l_ptmv_rec.LAST_UPDATED_BY,
              l_ptmv_rec.LAST_UPDATE_DATE,
              l_ptmv_rec.LAST_UPDATE_LOGIN,
/*      13-OCT-2006  	ANSETHUR
        BUILD  : R12 B
        Start Changes
*/
              l_ptmv_rec.recipient_type_code ,
              l_ptmv_rec.xml_tmplt_code;

/*        End  Changes         */

    x_no_data_found := okl_ptmv_pk_csr%NOTFOUND;
    CLOSE okl_ptmv_pk_csr;
    RETURN(l_ptmv_rec);
  END get_rec;

  FUNCTION get_rec (p_ptmv_rec IN ptmv_rec_type) RETURN ptmv_rec_type IS
    l_row_notfound                 BOOLEAN;

  BEGIN
    RETURN(get_rec(p_ptmv_rec, l_row_notfound));
  END get_rec;

  ----------------------------------------------------------
  -- FUNCTION null_out_defaults for: okl_process_tmplts_v --
  ----------------------------------------------------------
  FUNCTION null_out_defaults (p_ptmv_rec IN ptmv_rec_type) RETURN ptmv_rec_type IS

    l_ptmv_rec	ptmv_rec_type := p_ptmv_rec;

  BEGIN
    IF (l_ptmv_rec.org_id = OKL_API.G_MISS_NUM) THEN
      l_ptmv_rec.org_id := NULL;
    END IF;
    IF (l_ptmv_rec.ptm_code = OKL_API.G_MISS_CHAR) THEN
      l_ptmv_rec.ptm_code := NULL;
    END IF;
/*      13-OCT-2006  	ANSETHUR
        BUILD  : R12 B
        Start Changes
*/
    IF (l_ptmv_rec.jtf_amv_item_id = OKL_API.G_MISS_NUM) THEN
--      l_ptmv_rec.jtf_amv_item_id := NULL;
      l_ptmv_rec.jtf_amv_item_id := -1;
    END IF;
/*        End  Changes         */
    IF (l_ptmv_rec.sfwt_flag = OKL_API.G_MISS_CHAR) THEN
      l_ptmv_rec.sfwt_flag := NULL;
    END IF;
    IF (l_ptmv_rec.email_subject_line = OKL_API.G_MISS_CHAR) THEN
      l_ptmv_rec.email_subject_line := NULL;
    END IF;
    IF (l_ptmv_rec.start_date = OKL_API.G_MISS_DATE) THEN
      l_ptmv_rec.start_date := NULL;
    END IF;
    IF (l_ptmv_rec.end_date = OKL_API.G_MISS_DATE) THEN
      l_ptmv_rec.end_date := NULL;
    END IF;
    IF (l_ptmv_rec.object_version_number = OKL_API.G_MISS_NUM) THEN
      l_ptmv_rec.object_version_number := NULL;
    END IF;
    IF (l_ptmv_rec.attribute_category = OKL_API.G_MISS_CHAR) THEN
      l_ptmv_rec.attribute_category := NULL;
    END IF;
    IF (l_ptmv_rec.attribute1 = OKL_API.G_MISS_CHAR) THEN
      l_ptmv_rec.attribute1 := NULL;
    END IF;
    IF (l_ptmv_rec.attribute2 = OKL_API.G_MISS_CHAR) THEN
      l_ptmv_rec.attribute2 := NULL;
    END IF;
    IF (l_ptmv_rec.attribute3 = OKL_API.G_MISS_CHAR) THEN
      l_ptmv_rec.attribute3 := NULL;
    END IF;
    IF (l_ptmv_rec.attribute4 = OKL_API.G_MISS_CHAR) THEN
      l_ptmv_rec.attribute4 := NULL;
    END IF;
    IF (l_ptmv_rec.attribute5 = OKL_API.G_MISS_CHAR) THEN
      l_ptmv_rec.attribute5 := NULL;
    END IF;
    IF (l_ptmv_rec.attribute6 = OKL_API.G_MISS_CHAR) THEN
      l_ptmv_rec.attribute6 := NULL;
    END IF;
    IF (l_ptmv_rec.attribute7 = OKL_API.G_MISS_CHAR) THEN
      l_ptmv_rec.attribute7 := NULL;
    END IF;
    IF (l_ptmv_rec.attribute8 = OKL_API.G_MISS_CHAR) THEN
      l_ptmv_rec.attribute8 := NULL;
    END IF;
    IF (l_ptmv_rec.attribute9 = OKL_API.G_MISS_CHAR) THEN
      l_ptmv_rec.attribute9 := NULL;
    END IF;
    IF (l_ptmv_rec.attribute10 = OKL_API.G_MISS_CHAR) THEN
      l_ptmv_rec.attribute10 := NULL;
    END IF;
    IF (l_ptmv_rec.attribute11 = OKL_API.G_MISS_CHAR) THEN
      l_ptmv_rec.attribute11 := NULL;
    END IF;
    IF (l_ptmv_rec.attribute12 = OKL_API.G_MISS_CHAR) THEN
      l_ptmv_rec.attribute12 := NULL;
    END IF;
    IF (l_ptmv_rec.attribute13 = OKL_API.G_MISS_CHAR) THEN
      l_ptmv_rec.attribute13 := NULL;
    END IF;
    IF (l_ptmv_rec.attribute14 = OKL_API.G_MISS_CHAR) THEN
      l_ptmv_rec.attribute14 := NULL;
    END IF;
    IF (l_ptmv_rec.attribute15 = OKL_API.G_MISS_CHAR) THEN
      l_ptmv_rec.attribute15 := NULL;
    END IF;
    IF (l_ptmv_rec.created_by = OKL_API.G_MISS_NUM) THEN
      l_ptmv_rec.created_by := NULL;
    END IF;
    IF (l_ptmv_rec.creation_date = OKL_API.G_MISS_DATE) THEN
      l_ptmv_rec.creation_date := NULL;
    END IF;
    IF (l_ptmv_rec.last_updated_by = OKL_API.G_MISS_NUM) THEN
      l_ptmv_rec.last_updated_by := NULL;
    END IF;
    IF (l_ptmv_rec.last_update_date = OKL_API.G_MISS_DATE) THEN
      l_ptmv_rec.last_update_date := NULL;
    END IF;
    IF (l_ptmv_rec.last_update_login = OKL_API.G_MISS_NUM) THEN
      l_ptmv_rec.last_update_login := NULL;
    END IF;

/*      13-OCT-2006  	ANSETHUR
        BUILD  : R12 B
        Start Changes
*/
     IF (l_ptmv_rec.xml_tmplt_code = OKL_API.G_MISS_CHAR) THEN
      l_ptmv_rec.xml_tmplt_code:= NULL;
    END IF;
       IF (l_ptmv_rec.recipient_type_Code = OKL_API.G_MISS_CHAR) THEN
      l_ptmv_rec.recipient_type_Code:= NULL;
    END IF;
/*        End  Changes         */

    RETURN(l_ptmv_rec);
  END null_out_defaults;


  --------------------------------------------------
  -- Validate_Attributes for: okl_process_tmplts_v --
  --------------------------------------------------

  FUNCTION Validate_Attributes (p_ptmv_rec IN  ptmv_rec_type) RETURN VARCHAR2 IS

    l_return_status	VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;

  BEGIN

    validate_id(p_ptmv_rec, l_return_status);

      IF NOT l_return_status = OKL_API.G_RET_STS_SUCCESS THEN
        RETURN(l_return_status);
      END IF;

    validate_object_version_number(p_ptmv_rec, l_return_status);

      IF NOT l_return_status = OKL_API.G_RET_STS_SUCCESS THEN
        RETURN(l_return_status);
      END IF;

    validate_org_id(p_ptmv_rec, l_return_status);

      IF NOT l_return_status = OKL_API.G_RET_STS_SUCCESS THEN
        RETURN(l_return_status);
      END IF;

    validate_ptm_code(p_ptmv_rec, l_return_status);

      IF NOT l_return_status = OKL_API.G_RET_STS_SUCCESS THEN
        RETURN(l_return_status);
      END IF;
/*      13-OCT-2006      ANSETHUR
        BUILD  : R12 B
        Start Changes           */

/*    validate_jtf_amv_item_id(p_ptmv_rec, l_return_status);

      IF NOT l_return_status = OKL_API.G_RET_STS_SUCCESS THEN
        RETURN(l_return_status);
      END IF;*/


    Validate_xml_tmplt_code(p_ptmv_rec ,l_return_status );

      IF NOT l_return_status = OKL_API.G_RET_STS_SUCCESS THEN
        RETURN(l_return_status);
      END IF;

    Validate_recipient_type_code(p_ptmv_rec ,l_return_status );

      IF NOT l_return_status = OKL_API.G_RET_STS_SUCCESS THEN
        RETURN(l_return_status);
      END IF;

/*        End  Changes           */

    validate_start_date(p_ptmv_rec, l_return_status);

      IF NOT l_return_status = OKL_API.G_RET_STS_SUCCESS THEN
        RETURN(l_return_status);
      END IF;

    validate_end_date(p_ptmv_rec, l_return_status);

      IF NOT l_return_status = OKL_API.G_RET_STS_SUCCESS THEN
        RETURN(l_return_status);
      END IF;

    RETURN(l_return_status);

  EXCEPTION

    WHEN OTHERS THEN

      OKL_API.set_message(G_APP_NAME,
                          G_UNEXPECTED_ERROR,
                          G_SQLCODE_TOKEN,
                          SQLCODE,
                          G_SQLERRM_TOKEN,
                          SQLERRM);
      l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      RETURN(l_return_status);

  END Validate_Attributes;


  ----------------------------------------------
  -- Validate_Record for: okl_process_tmplts_v --
  ----------------------------------------------

FUNCTION Validate_Record (p_ptmv_rec IN ptmv_rec_type) RETURN VARCHAR2 IS

    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_dummy                        VARCHAR2(1);
 --varangan added the following code for bug#5094506
    l_start_date                    DATE;

    CURSOR c_check_dates IS
    SELECT start_date
    FROM   okl_process_tmplts_b
    WHERE  ptm_code = p_ptmv_rec.ptm_code
    AND    jtf_amv_item_id = p_ptmv_rec.jtf_amv_item_id
    AND    id <> p_ptmv_rec.id
    AND    TRUNC(start_date) > TRUNC(p_ptmv_rec.start_date)
    ORDER BY start_date asc;

  --end bug#5094506

--varangan modified the cursor for bug#5020750
--dkagrawa modified the cursor for bug#5083633
    CURSOR c_ptmv_uk IS
      SELECT 1
      FROM   okl_process_tmplts_b
      WHERE  ptm_code = p_ptmv_rec.ptm_code AND
             jtf_amv_item_id = p_ptmv_rec.jtf_amv_item_id AND
             id <> p_ptmv_rec.id AND
             TRUNC(start_date)<= TRUNC(p_ptmv_rec.start_date) AND
            ( TRUNC(end_date) >= TRUNC(p_ptmv_rec.start_date) OR
              end_date IS NULL ) ;


  BEGIN

    IF TRUNC(p_ptmv_rec.end_date) < TRUNC(p_ptmv_rec.start_date) THEN

      OKL_API.set_message(p_app_name   => G_APP_NAME,
                          p_msg_name   => 'OKL_INVALID_TO_DATE');

      l_return_status := OKL_API.G_RET_STS_ERROR;

      RETURN (l_return_status);


    END IF;

 --dkagrawa added the following code for bug#5094506
    OPEN c_check_dates;
    FETCH c_check_dates INTO l_start_date;
    IF c_check_dates%FOUND THEN
      IF ( nvl(TRUNC(p_ptmv_rec.end_date),l_start_date) >= l_start_date ) THEN

        OKL_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                            p_msg_name     => 'OKL_OVERLAP_END_DATE',
                            p_token1       => 'START_DATE',
                            p_token1_value => l_start_date,
                            p_token2       => 'END_DATE',
                            p_token2_value => l_start_date);
        l_return_status := OKL_API.G_RET_STS_ERROR;
        CLOSE c_check_dates;
        RETURN (l_return_status);
      END IF;
    END IF;
    CLOSE c_check_dates;
 --end bug#5094506

    OPEN c_ptmv_uk;
    FETCH c_ptmv_uk INTO l_dummy;

    IF c_ptmv_uk%FOUND THEN

      OKL_API.set_message(p_app_name     => G_APP_NAME,
                          p_msg_name     => 'OKL_DUPLICATE_PTMV_RECORD');


      l_return_status := OKL_API.G_RET_STS_ERROR;

    END IF;

    CLOSE c_ptmv_uk;

    RETURN (l_return_status);

 EXCEPTION

      WHEN OTHERS THEN
        OKL_API.set_message(p_app_name    => g_app_name,
                           p_msg_name     => g_unexpected_error,
                           p_token1       => g_sqlcode_token,
                           p_token1_value => sqlcode,
                           p_token2       => g_sqlerrm_token,
                           p_token2_value => sqlerrm);
        l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

        RETURN(l_return_status);

  END Validate_Record;

  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate (from V Record to B Record)
  ---------------------------------------------------------------------------
  PROCEDURE migrate (p_from IN ptmv_rec_type,
                     p_to   IN OUT NOCOPY ptm_rec_type) IS

  BEGIN

    p_to.id := p_from.id;
    p_to.org_id := p_from.org_id;
    p_to.ptm_code := p_from.ptm_code;
    p_to.jtf_amv_item_id := p_from.jtf_amv_item_id;
    p_to.start_date := p_from.start_date;
    p_to.end_date := p_from.end_date;
    p_to.object_version_number := p_from.object_version_number;
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
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
/*      13-OCT-2006  	ANSETHUR
        BUILD  : R12 B
        Start Changes
*/
    p_to.recipient_type_code:= p_from.recipient_type_code;
    p_to.xml_tmplt_code := p_from.xml_tmplt_code;
/*        End  Changes         */
  END migrate;


  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate (from B Record to V Record)
  ---------------------------------------------------------------------------
  PROCEDURE migrate (p_from IN ptm_rec_type,
                     p_to   IN OUT NOCOPY ptmv_rec_type) IS

  BEGIN

    p_to.id := p_from.id;
    p_to.org_id := p_to.org_id;
    p_to.ptm_code := p_from.ptm_code;
    p_to.jtf_amv_item_id := p_from.jtf_amv_item_id;
    p_to.start_date := p_from.start_date;
    p_to.end_date := p_from.end_date;
    p_to.object_version_number := p_from.object_version_number;
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
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
/*      13-OCT-2006  	ANSETHUR
        BUILD  : R12 B
        Start Changes
*/
    p_to.recipient_type_code:= p_from.recipient_type_code;
    p_to.xml_tmplt_code:=    p_from.xml_tmplt_code;
/*        End  Changes         */
  END migrate;

  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate (from V Record to TL Record)
  ---------------------------------------------------------------------------
  PROCEDURE migrate (p_from     IN ptmv_rec_type,
                     p_to       IN OUT NOCOPY okl_process_tmplts_tl_rec_type) IS
  BEGIN

    p_to.id := p_from.id;
    p_to.sfwt_flag := p_from.sfwt_flag;
    p_to.email_subject_line := p_from.email_subject_line;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;

  END migrate;

  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate (from TL Record to V Record)
  ---------------------------------------------------------------------------
  PROCEDURE migrate (p_from IN okl_process_tmplts_tl_rec_type,
                     p_to   IN OUT NOCOPY ptmv_rec_type) IS

  BEGIN

    p_to.id := p_from.id;
    p_to.sfwt_flag := p_from.sfwt_flag;
    p_to.email_subject_line := p_from.email_subject_line;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;

  END migrate;

  -------------------------------------------
  -- validate_row for: okl_process_tmplts_v --
  -------------------------------------------

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ptmv_rec                     IN ptmv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_ptmv_rec                     ptmv_rec_type := p_ptmv_rec;

  BEGIN

    l_return_status := OKL_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);

    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    l_return_status := Validate_Attributes(l_ptmv_rec);
      IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

/*      13-OCT-2006  	ANSETHUR
        BUILD  : R12 B
        Start Changes
*/
 --   l_return_status := Validate_Record(l_ptmv_rec);
    Validate_tmplt_record(  l_ptmv_rec ,  l_return_status );
/*        End  Changes         */
      IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);

  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
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
  -- PL/SQL TBL validate_row for:PTMV_TBL --
  ------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ptmv_tbl                     IN ptmv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;

  BEGIN

    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_ptmv_tbl.COUNT > 0) THEN
      i := p_ptmv_tbl.FIRST;
      LOOP
        validate_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKL_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_ptmv_rec                     => p_ptmv_tbl(i));
        EXIT WHEN (i = p_ptmv_tbl.LAST);
        i := p_ptmv_tbl.NEXT(i);
      END LOOP;
    END IF;
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
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
  -- insert_row for:OKL_PROCESS_TMPLTS_B --
  -----------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ptm_rec                      IN ptm_rec_type,
    x_ptm_rec                      OUT NOCOPY ptm_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_insert_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_ptm_rec                      ptm_rec_type := p_ptm_rec;
    l_def_ptm_rec                  ptm_rec_type;
    ---------------------------------------------
    -- Set_Attributes for:OKL_PROCESS_TMPLTS --
    ---------------------------------------------
    FUNCTION Set_Attributes (
      p_ptm_rec IN  ptm_rec_type,
      x_ptm_rec OUT NOCOPY ptm_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_ptm_rec := p_ptm_rec;
      RETURN(l_return_status);
    END Set_Attributes;

  BEGIN

    l_return_status := OKL_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);

    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    l_return_status := Set_Attributes(p_ptm_rec, l_ptm_rec);

    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;



    INSERT INTO OKL_PROCESS_TMPLTS_B(
        id,
        org_id,
        ptm_code,
        jtf_amv_item_id,
        start_date,
        end_date,
        object_version_number,
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
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        last_update_login,
/*      13-OCT-2006  	ANSETHUR
        BUILD  : R12 B
        Start Changes
*/
        recipient_type_code,
        xml_tmplt_code)
/*        End  Changes         */
      VALUES (
        l_ptm_rec.id,
        l_ptm_rec.org_id,
        l_ptm_rec.ptm_code,
        l_ptm_rec.jtf_amv_item_id,
        l_ptm_rec.start_date,
        l_ptm_rec.end_date,
        l_ptm_rec.object_version_number,
        l_ptm_rec.attribute_category,
        l_ptm_rec.attribute1,
        l_ptm_rec.attribute2,
        l_ptm_rec.attribute3,
        l_ptm_rec.attribute4,
        l_ptm_rec.attribute5,
        l_ptm_rec.attribute6,
        l_ptm_rec.attribute7,
        l_ptm_rec.attribute8,
        l_ptm_rec.attribute9,
        l_ptm_rec.attribute10,
        l_ptm_rec.attribute11,
        l_ptm_rec.attribute12,
        l_ptm_rec.attribute13,
        l_ptm_rec.attribute14,
        l_ptm_rec.attribute15,
        l_ptm_rec.created_by,
        l_ptm_rec.creation_date,
        l_ptm_rec.last_updated_by,
        l_ptm_rec.last_update_date,
        l_ptm_rec.last_update_login,
/*      13-OCT-2006  	ANSETHUR
        BUILD  : R12 B
        Start Changes
*/
        l_ptm_rec.recipient_type_code ,
        l_ptm_rec.xml_tmplt_code);
/*        End  Changes         */

    x_ptm_rec := l_ptm_rec;

    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);

  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN

      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
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
  -- insert_row for: OKL_PROCESS_TMPLTS_TL --
  ------------------------------------------

  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_process_tmplts_tl_rec    IN okl_process_tmplts_tl_rec_type,
    x_okl_process_tmplts_tl_rec    OUT NOCOPY okl_process_tmplts_tl_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_insert_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_okl_process_tmplts_tl_rec    okl_process_tmplts_tl_rec_type := p_okl_process_tmplts_tl_rec;
    ldefoklprocesstmpltstlrec      okl_process_tmplts_tl_rec_type;

    CURSOR get_languages IS
      SELECT *
        FROM FND_LANGUAGES
       WHERE INSTALLED_FLAG IN ('I', 'B');

    ----------------------------------------------
    -- Set_Attributes for:OKL_PROCESS_TMPLTS_TL --
    ----------------------------------------------
    FUNCTION Set_Attributes (
      p_okl_process_tmplts_tl_rec IN  okl_process_tmplts_tl_rec_type,
      x_okl_process_tmplts_tl_rec OUT NOCOPY okl_process_tmplts_tl_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_okl_process_tmplts_tl_rec := p_okl_process_tmplts_tl_rec;
      x_okl_process_tmplts_tl_rec.LANGUAGE := USERENV('LANG');    -- Harmless but nonetheless incorrect
      x_okl_process_tmplts_tl_rec.SOURCE_LANG := USERENV('LANG');
      RETURN(l_return_status);
    END Set_Attributes;

  BEGIN

    l_return_status := OKL_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);

    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    l_return_status := Set_Attributes(p_okl_process_tmplts_tl_rec, l_okl_process_tmplts_tl_rec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    FOR l_lang_rec IN get_languages LOOP

      l_okl_process_tmplts_tl_rec.LANGUAGE := l_lang_rec.language_code;

      INSERT INTO OKL_PROCESS_TMPLTS_TL(
          id,
          LANGUAGE,
          source_lang,
          sfwt_flag,
          email_subject_line,
          created_by,
          creation_date,
          last_updated_by,
          last_update_date,
          last_update_login)
        VALUES (
          l_okl_process_tmplts_tl_rec.id,
          l_okl_process_tmplts_tl_rec.LANGUAGE,
          l_okl_process_tmplts_tl_rec.source_lang,
          l_okl_process_tmplts_tl_rec.sfwt_flag,
          l_okl_process_tmplts_tl_rec.email_subject_line,
          l_okl_process_tmplts_tl_rec.created_by,
          l_okl_process_tmplts_tl_rec.creation_date,
          l_okl_process_tmplts_tl_rec.last_updated_by,
          l_okl_process_tmplts_tl_rec.last_update_date,
          l_okl_process_tmplts_tl_rec.last_update_login);
      END LOOP;

    x_okl_process_tmplts_tl_rec := l_okl_process_tmplts_tl_rec;

    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);

  EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN

      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
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
  -- insert_row for: okl_process_tmplts_v --
  -----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ptmv_rec                     IN ptmv_rec_type,
    x_ptmv_rec                     OUT NOCOPY ptmv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_ptmv_rec                     ptmv_rec_type;
    l_def_ptmv_rec                 ptmv_rec_type;
    l_ptm_rec                      ptm_rec_type;
    lx_ptm_rec                     ptm_rec_type;
    l_okl_process_tmplts_tl_rec    okl_process_tmplts_tl_rec_type;
    lx_okl_process_tmplts_tl_rec   okl_process_tmplts_tl_rec_type;

    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (p_ptmv_rec IN ptmv_rec_type) RETURN ptmv_rec_type IS

      l_ptmv_rec	ptmv_rec_type := p_ptmv_rec;

    BEGIN


      l_ptmv_rec.CREATION_DATE     := SYSDATE;
      l_ptmv_rec.CREATED_BY        := Fnd_Global.User_Id;
      l_ptmv_rec.LAST_UPDATE_DATE  := SYSDATE;
      l_ptmv_rec.LAST_UPDATED_BY   := Fnd_Global.User_Id;
      l_ptmv_rec.LAST_UPDATE_LOGIN := Fnd_Global.LOGIN_ID;
      RETURN(l_ptmv_rec);

    END fill_who_columns;

    ---------------------------------------------
    -- Set_Attributes for:okl_process_tmplts_v --
    ---------------------------------------------
    FUNCTION Set_Attributes (p_ptmv_rec IN  ptmv_rec_type, x_ptmv_rec OUT NOCOPY ptmv_rec_type)
      RETURN VARCHAR2 IS

      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
      l_org_id                       hr_operating_units.organization_id%TYPE;

    BEGIN

      --fnd_profile.get('ORG_ID', l_org_id);
      l_org_id := mo_global.get_current_org_id();

      x_ptmv_rec := p_ptmv_rec;
      x_ptmv_rec.OBJECT_VERSION_NUMBER := 1;
      x_ptmv_rec.SFWT_FLAG := 'N';
      x_ptmv_rec.ORG_ID := l_org_id;
      RETURN(l_return_status);
    END Set_Attributes;

  BEGIN


    l_return_status := OKL_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);


    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    l_ptmv_rec := null_out_defaults(p_ptmv_rec);

    l_ptmv_rec.ID := get_seq_id;


    l_return_status := Set_Attributes(l_ptmv_rec, l_def_ptmv_rec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    l_def_ptmv_rec := fill_who_columns(l_def_ptmv_rec);

    l_return_status := Validate_Attributes(l_def_ptmv_rec);

    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;


/*      13-OCT-2006  	ANSETHUR
        BUILD  : R12 B
        Start Changes
*/
 --   l_return_status := Validate_Record(l_def_ptmv_rec);
    Validate_tmplt_record(  l_def_ptmv_rec ,  l_return_status );
/*        End  Changes         */

    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_ptmv_rec, l_ptm_rec);
    migrate(l_def_ptmv_rec, l_okl_process_tmplts_tl_rec);


    --------------------------------------------
    -- Call the INSERT_ROW for each child record
    --------------------------------------------
    insert_row(p_init_msg_list,
               x_return_status,
               x_msg_count,
               x_msg_data,
               l_ptm_rec,
               lx_ptm_rec);



    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    migrate(lx_ptm_rec, l_def_ptmv_rec);

    insert_row(p_init_msg_list,
               x_return_status,
               x_msg_count,
               x_msg_data,
               l_okl_process_tmplts_tl_rec,
               lx_okl_process_tmplts_tl_rec);



    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    migrate(lx_okl_process_tmplts_tl_rec, l_def_ptmv_rec);

    x_ptmv_rec := l_def_ptmv_rec;

    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);

  EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
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
  -- PL/SQL TBL insert_row for:PTMV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ptmv_tbl                     IN ptmv_tbl_type,
    x_ptmv_tbl                     OUT NOCOPY ptmv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN


    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_ptmv_tbl.COUNT > 0) THEN
      i := p_ptmv_tbl.FIRST;
      LOOP
        insert_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKL_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_ptmv_rec                     => p_ptmv_tbl(i),
          x_ptmv_rec                     => x_ptmv_tbl(i));
        EXIT WHEN (i = p_ptmv_tbl.LAST);
        i := p_ptmv_tbl.NEXT(i);
      END LOOP;
    END IF;
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
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
  -- lock_row for: OKL_PROCESS_TMPLTS_B --
  ---------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ptm_rec                      IN ptm_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_ptm_rec IN ptm_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_PROCESS_TMPLTS_B
     WHERE ID = p_ptm_rec.id
       AND OBJECT_VERSION_NUMBER = p_ptm_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR  lchk_csr (p_ptm_rec IN ptm_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM okl_process_tmplts_b
    WHERE ID = p_ptm_rec.id;
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_lock_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_object_version_number       okl_process_tmplts_b.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number      okl_process_tmplts_b.OBJECT_VERSION_NUMBER%TYPE;
    l_row_notfound                BOOLEAN := FALSE;
    lc_row_notfound               BOOLEAN := FALSE;
  BEGIN
    l_return_status := OKL_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    BEGIN
      OPEN lock_csr(p_ptm_rec);
      FETCH lock_csr INTO l_object_version_number;
      l_row_notfound := lock_csr%NOTFOUND;
      CLOSE lock_csr;
    EXCEPTION
      WHEN E_Resource_Busy THEN
        IF (lock_csr%ISOPEN) THEN
          CLOSE lock_csr;
        END IF;
        OKL_API.set_message(G_FND_APP,G_FORM_UNABLE_TO_RESERVE_REC);
        RAISE App_Exceptions.RECORD_LOCK_EXCEPTION;
    END;

    IF ( l_row_notfound ) THEN
      OPEN lchk_csr(p_ptm_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      OKL_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_ptm_rec.object_version_number THEN
      OKL_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_ptm_rec.object_version_number THEN
      OKL_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number = -1 THEN
      OKL_API.set_message(G_APP_NAME,G_RECORD_LOGICALLY_DELETED);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
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
  -- lock_row for:OKL_PROCESS_TMPLTS_TL --
  ----------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_process_tmplts_tl_rec    IN okl_process_tmplts_tl_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_okl_process_tmplts_tl_rec IN okl_process_tmplts_tl_rec_type) IS
    SELECT *
      FROM OKL_PROCESS_TMPLTS_TL
     WHERE ID = p_okl_process_tmplts_tl_rec.id
    FOR UPDATE NOWAIT;

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_lock_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_lock_var                    lock_csr%ROWTYPE;
    l_row_notfound                BOOLEAN := FALSE;
    lc_row_notfound               BOOLEAN := FALSE;
  BEGIN
    l_return_status := OKL_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    BEGIN
      OPEN lock_csr(p_okl_process_tmplts_tl_rec);
      FETCH lock_csr INTO l_lock_var;
      l_row_notfound := lock_csr%NOTFOUND;
      CLOSE lock_csr;
    EXCEPTION
      WHEN E_Resource_Busy THEN
        IF (lock_csr%ISOPEN) THEN
          CLOSE lock_csr;
        END IF;
        OKL_API.set_message(G_FND_APP,G_FORM_UNABLE_TO_RESERVE_REC);
        RAISE App_Exceptions.RECORD_LOCK_EXCEPTION;
    END;

    IF ( l_row_notfound ) THEN
      OKL_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
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
  -- lock_row for:OKL_PROCESS_TMPLTS_V --
  ---------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ptmv_rec                     IN ptmv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_ptm_rec                      ptm_rec_type;
    l_okl_process_tmplts_tl_rec    okl_process_tmplts_tl_rec_type;
  BEGIN
    l_return_status := OKL_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(p_ptmv_rec, l_ptm_rec);
    migrate(p_ptmv_rec, l_okl_process_tmplts_tl_rec);
    --------------------------------------------
    -- Call the LOCK_ROW for each child record
    --------------------------------------------
    lock_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_ptm_rec
    );
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    lock_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okl_process_tmplts_tl_rec
    );
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
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
  -- PL/SQL TBL lock_row for:PTMV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ptmv_tbl                     IN ptmv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_ptmv_tbl.COUNT > 0) THEN
      i := p_ptmv_tbl.FIRST;
      LOOP
        lock_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKL_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_ptmv_rec                     => p_ptmv_tbl(i));
        EXIT WHEN (i = p_ptmv_tbl.LAST);
        i := p_ptmv_tbl.NEXT(i);
      END LOOP;
    END IF;
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
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
  -- update_row for:OKL_PROCESS_TMPLTS_B --
  -----------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ptm_rec                      IN  ptm_rec_type,
    x_ptm_rec                      OUT NOCOPY ptm_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_update_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_ptm_rec                      ptm_rec_type := p_ptm_rec;
    l_def_ptm_rec                  ptm_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (p_ptm_rec IN ptm_rec_type,
                                  x_ptm_rec OUT NOCOPY ptm_rec_type) RETURN VARCHAR2 IS

      l_ptm_rec                      ptm_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;

    BEGIN

      x_ptm_rec := p_ptm_rec;
      -- Get current database values
      l_ptm_rec := get_rec(p_ptm_rec, l_row_notfound);

      IF (l_row_notfound) THEN
        l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
        RETURN(l_return_status);
      END IF;
      IF (x_ptm_rec.org_id = OKL_API.G_MISS_NUM)
      THEN
        x_ptm_rec.org_id := l_ptm_rec.org_id;
      END IF;
      IF (x_ptm_rec.ptm_code = OKL_API.G_MISS_CHAR)
      THEN
        x_ptm_rec.ptm_code := l_ptm_rec.ptm_code;
      END IF;
      IF (x_ptm_rec.jtf_amv_item_id = OKL_API.G_MISS_NUM)
      THEN
        x_ptm_rec.jtf_amv_item_id := l_ptm_rec.jtf_amv_item_id;
      END IF;
      IF (x_ptm_rec.start_date = OKL_API.G_MISS_DATE)
      THEN
        x_ptm_rec.start_date := l_ptm_rec.start_date;
      END IF;
      IF (x_ptm_rec.end_date = OKL_API.G_MISS_DATE)
      THEN
        x_ptm_rec.end_date := l_ptm_rec.end_date;
      END IF;
      IF (x_ptm_rec.object_version_number = OKL_API.G_MISS_NUM)
      THEN
        x_ptm_rec.object_version_number := l_ptm_rec.object_version_number;
      END IF;
      IF (x_ptm_rec.attribute_category = OKL_API.G_MISS_CHAR)
      THEN
        x_ptm_rec.attribute_category := l_ptm_rec.attribute_category;
      END IF;
      IF (x_ptm_rec.attribute1 = OKL_API.G_MISS_CHAR)
      THEN
        x_ptm_rec.attribute1 := l_ptm_rec.attribute1;
      END IF;
      IF (x_ptm_rec.attribute2 = OKL_API.G_MISS_CHAR)
      THEN
        x_ptm_rec.attribute2 := l_ptm_rec.attribute2;
      END IF;
      IF (x_ptm_rec.attribute3 = OKL_API.G_MISS_CHAR)
      THEN
        x_ptm_rec.attribute3 := l_ptm_rec.attribute3;
      END IF;
      IF (x_ptm_rec.attribute4 = OKL_API.G_MISS_CHAR)
      THEN
        x_ptm_rec.attribute4 := l_ptm_rec.attribute4;
      END IF;
      IF (x_ptm_rec.attribute5 = OKL_API.G_MISS_CHAR)
      THEN
        x_ptm_rec.attribute5 := l_ptm_rec.attribute5;
      END IF;
      IF (x_ptm_rec.attribute6 = OKL_API.G_MISS_CHAR)
      THEN
        x_ptm_rec.attribute6 := l_ptm_rec.attribute6;
      END IF;
      IF (x_ptm_rec.attribute7 = OKL_API.G_MISS_CHAR)
      THEN
        x_ptm_rec.attribute7 := l_ptm_rec.attribute7;
      END IF;
      IF (x_ptm_rec.attribute8 = OKL_API.G_MISS_CHAR)
      THEN
        x_ptm_rec.attribute8 := l_ptm_rec.attribute8;
      END IF;
      IF (x_ptm_rec.attribute9 = OKL_API.G_MISS_CHAR)
      THEN
        x_ptm_rec.attribute9 := l_ptm_rec.attribute9;
      END IF;
      IF (x_ptm_rec.attribute10 = OKL_API.G_MISS_CHAR)
      THEN
        x_ptm_rec.attribute10 := l_ptm_rec.attribute10;
      END IF;
      IF (x_ptm_rec.attribute11 = OKL_API.G_MISS_CHAR)
      THEN
        x_ptm_rec.attribute11 := l_ptm_rec.attribute11;
      END IF;
      IF (x_ptm_rec.attribute12 = OKL_API.G_MISS_CHAR)
      THEN
        x_ptm_rec.attribute12 := l_ptm_rec.attribute12;
      END IF;
      IF (x_ptm_rec.attribute13 = OKL_API.G_MISS_CHAR)
      THEN
        x_ptm_rec.attribute13 := l_ptm_rec.attribute13;
      END IF;
      IF (x_ptm_rec.attribute14 = OKL_API.G_MISS_CHAR)
      THEN
        x_ptm_rec.attribute14 := l_ptm_rec.attribute14;
      END IF;
      IF (x_ptm_rec.attribute15 = OKL_API.G_MISS_CHAR)
      THEN
        x_ptm_rec.attribute15 := l_ptm_rec.attribute15;
      END IF;
      IF (x_ptm_rec.created_by = OKL_API.G_MISS_NUM)
      THEN
        x_ptm_rec.created_by := l_ptm_rec.created_by;
      END IF;
      IF (x_ptm_rec.creation_date = OKL_API.G_MISS_DATE)
      THEN
        x_ptm_rec.creation_date := l_ptm_rec.creation_date;
      END IF;
      IF (x_ptm_rec.last_updated_by = OKL_API.G_MISS_NUM)
      THEN
        x_ptm_rec.last_updated_by := l_ptm_rec.last_updated_by;
      END IF;
      IF (x_ptm_rec.last_update_date = OKL_API.G_MISS_DATE)
      THEN
        x_ptm_rec.last_update_date := l_ptm_rec.last_update_date;
      END IF;
      IF (x_ptm_rec.last_update_login = OKL_API.G_MISS_NUM)
      THEN
        x_ptm_rec.last_update_login := l_ptm_rec.last_update_login;
      END IF;
/*      13-OCT-2006  	ANSETHUR
        BUILD  : R12 B
        Start Changes
*/
      IF (x_ptm_rec.xml_tmplt_code = OKL_API.G_MISS_CHAR)
      THEN
      x_ptm_rec.xml_tmplt_code:= l_ptm_rec.xml_tmplt_code;
      END IF;
      IF (x_ptm_rec.recipient_type_Code = OKL_API.G_MISS_CHAR)
      THEN
      x_ptm_rec.recipient_type_Code:= l_ptm_rec.recipient_type_Code;
      END IF;
/*        End  Changes         */

      RETURN(l_return_status);
    END populate_new_record;
    ---------------------------------------------
    -- Set_Attributes for:OKL_PROCESS_TMPLTS --
    ---------------------------------------------
    FUNCTION Set_Attributes (p_ptm_rec IN  ptm_rec_type,
                             x_ptm_rec OUT NOCOPY ptm_rec_type) RETURN VARCHAR2 IS

      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;

    BEGIN
      x_ptm_rec := p_ptm_rec;
      RETURN(l_return_status);
    END Set_Attributes;

  BEGIN

    l_return_status := OKL_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);

    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    l_return_status := Set_Attributes(p_ptm_rec, l_ptm_rec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    l_return_status := populate_new_record(l_ptm_rec, l_def_ptm_rec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    UPDATE  OKL_PROCESS_TMPLTS_B
    SET ORG_ID = l_def_ptm_rec.org_id,
        PTM_CODE = l_def_ptm_rec.ptm_code,
        JTF_AMV_ITEM_ID = l_def_ptm_rec.jtf_amv_item_id,
        START_DATE = l_def_ptm_rec.start_date,
        END_DATE = l_def_ptm_rec.end_date,
        OBJECT_VERSION_NUMBER = l_def_ptm_rec.object_version_number,
        ATTRIBUTE_CATEGORY = l_def_ptm_rec.attribute_category,
        ATTRIBUTE1 = l_def_ptm_rec.attribute1,
        ATTRIBUTE2 = l_def_ptm_rec.attribute2,
        ATTRIBUTE3 = l_def_ptm_rec.attribute3,
        ATTRIBUTE4 = l_def_ptm_rec.attribute4,
        ATTRIBUTE5 = l_def_ptm_rec.attribute5,
        ATTRIBUTE6 = l_def_ptm_rec.attribute6,
        ATTRIBUTE7 = l_def_ptm_rec.attribute7,
        ATTRIBUTE8 = l_def_ptm_rec.attribute8,
        ATTRIBUTE9 = l_def_ptm_rec.attribute9,
        ATTRIBUTE10 = l_def_ptm_rec.attribute10,
        ATTRIBUTE11 = l_def_ptm_rec.attribute11,
        ATTRIBUTE12 = l_def_ptm_rec.attribute12,
        ATTRIBUTE13 = l_def_ptm_rec.attribute13,
        ATTRIBUTE14 = l_def_ptm_rec.attribute14,
        ATTRIBUTE15 = l_def_ptm_rec.attribute15,
        CREATED_BY = l_def_ptm_rec.created_by,
        CREATION_DATE = l_def_ptm_rec.creation_date,
        LAST_UPDATED_BY = l_def_ptm_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_ptm_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_ptm_rec.last_update_login,
/*      13-OCT-2006  	ANSETHUR
        BUILD  : R12 B
        Start Changes
*/
        XML_TMPLT_CODE =l_def_ptm_rec.XML_TMPLT_CODE,
        RECIPIENT_TYPE_CODE=l_def_ptm_rec.RECIPIENT_TYPE_CODE
/*        End  Changes         */

    WHERE ID = l_def_ptm_rec.id;

    x_ptm_rec := l_def_ptm_rec;

    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);

  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
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
  -- update_row for:OKL_PROCESS_TMPLTS_TL --
  ------------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_process_tmplts_tl_rec    IN okl_process_tmplts_tl_rec_type,
    x_okl_process_tmplts_tl_rec    OUT NOCOPY okl_process_tmplts_tl_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_update_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_okl_process_tmplts_tl_rec    okl_process_tmplts_tl_rec_type := p_okl_process_tmplts_tl_rec;
    ldefoklprocesstmpltstlrec      okl_process_tmplts_tl_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_okl_process_tmplts_tl_rec	IN okl_process_tmplts_tl_rec_type,
      x_okl_process_tmplts_tl_rec	OUT NOCOPY okl_process_tmplts_tl_rec_type
    ) RETURN VARCHAR2 IS
      l_okl_process_tmplts_tl_rec    okl_process_tmplts_tl_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_okl_process_tmplts_tl_rec := p_okl_process_tmplts_tl_rec;
      -- Get current database values
      l_okl_process_tmplts_tl_rec := get_rec(p_okl_process_tmplts_tl_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_okl_process_tmplts_tl_rec.id = OKL_API.G_MISS_NUM)
      THEN
        x_okl_process_tmplts_tl_rec.id := l_okl_process_tmplts_tl_rec.id;
      END IF;
      IF (x_okl_process_tmplts_tl_rec.LANGUAGE = OKL_API.G_MISS_CHAR)
      THEN
        x_okl_process_tmplts_tl_rec.LANGUAGE := l_okl_process_tmplts_tl_rec.LANGUAGE;
      END IF;
      IF (x_okl_process_tmplts_tl_rec.source_lang = OKL_API.G_MISS_CHAR)
      THEN
        x_okl_process_tmplts_tl_rec.source_lang := l_okl_process_tmplts_tl_rec.source_lang;
      END IF;
      IF (x_okl_process_tmplts_tl_rec.sfwt_flag = OKL_API.G_MISS_CHAR)
      THEN
        x_okl_process_tmplts_tl_rec.sfwt_flag := l_okl_process_tmplts_tl_rec.sfwt_flag;
      END IF;
      IF (x_okl_process_tmplts_tl_rec.email_subject_line = OKL_API.G_MISS_CHAR)
      THEN
        x_okl_process_tmplts_tl_rec.email_subject_line := l_okl_process_tmplts_tl_rec.email_subject_line;
      END IF;
      IF (x_okl_process_tmplts_tl_rec.created_by = OKL_API.G_MISS_NUM)
      THEN
        x_okl_process_tmplts_tl_rec.created_by := l_okl_process_tmplts_tl_rec.created_by;
      END IF;
      IF (x_okl_process_tmplts_tl_rec.creation_date = OKL_API.G_MISS_DATE)
      THEN
        x_okl_process_tmplts_tl_rec.creation_date := l_okl_process_tmplts_tl_rec.creation_date;
      END IF;
      IF (x_okl_process_tmplts_tl_rec.last_updated_by = OKL_API.G_MISS_NUM)
      THEN
        x_okl_process_tmplts_tl_rec.last_updated_by := l_okl_process_tmplts_tl_rec.last_updated_by;
      END IF;
      IF (x_okl_process_tmplts_tl_rec.last_update_date = OKL_API.G_MISS_DATE)
      THEN
        x_okl_process_tmplts_tl_rec.last_update_date := l_okl_process_tmplts_tl_rec.last_update_date;
      END IF;
      IF (x_okl_process_tmplts_tl_rec.last_update_login = OKL_API.G_MISS_NUM)
      THEN
        x_okl_process_tmplts_tl_rec.last_update_login := l_okl_process_tmplts_tl_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ----------------------------------------------
    -- Set_Attributes for:OKL_PROCESS_TMPLTS_TL --
    ----------------------------------------------
    FUNCTION Set_Attributes (
      p_okl_process_tmplts_tl_rec IN  okl_process_tmplts_tl_rec_type,
      x_okl_process_tmplts_tl_rec OUT NOCOPY okl_process_tmplts_tl_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_okl_process_tmplts_tl_rec := p_okl_process_tmplts_tl_rec;
      x_okl_process_tmplts_tl_rec.LANGUAGE := USERENV('LANG');
      x_okl_process_tmplts_tl_rec.SOURCE_LANG := USERENV('LANG');
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := OKL_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      p_okl_process_tmplts_tl_rec,       -- IN
      l_okl_process_tmplts_tl_rec);      -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_okl_process_tmplts_tl_rec, ldefoklprocesstmpltstlrec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKL_PROCESS_TMPLTS_TL
    SET EMAIL_SUBJECT_LINE = ldefoklprocesstmpltstlrec.email_subject_line,
        SOURCE_LANG = ldefoklprocesstmpltstlrec.source_lang,  --Fix for bug 3637102
        CREATED_BY = ldefoklprocesstmpltstlrec.created_by,
        CREATION_DATE = ldefoklprocesstmpltstlrec.creation_date,
        LAST_UPDATED_BY = ldefoklprocesstmpltstlrec.last_updated_by,
        LAST_UPDATE_DATE = ldefoklprocesstmpltstlrec.last_update_date,
        LAST_UPDATE_LOGIN = ldefoklprocesstmpltstlrec.last_update_login
    WHERE ID = ldefoklprocesstmpltstlrec.id
      AND USERENV('LANG') in (SOURCE_LANG,LANGUAGE);--Fix for bug 3637102
      --AND SOURCE_LANG = USERENV('LANG');

    UPDATE  OKL_PROCESS_TMPLTS_TL
    SET SFWT_FLAG = 'Y'
    WHERE ID = ldefoklprocesstmpltstlrec.id
      AND SOURCE_LANG <> USERENV('LANG');

    x_okl_process_tmplts_tl_rec := ldefoklprocesstmpltstlrec;
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);

  EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
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
  -- update_row for:okl_process_tmplts_v --
  -----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ptmv_rec                     IN ptmv_rec_type,
    x_ptmv_rec                     OUT NOCOPY ptmv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_ptmv_rec                     ptmv_rec_type := p_ptmv_rec;
    l_def_ptmv_rec                 ptmv_rec_type;
    l_okl_process_tmplts_tl_rec    okl_process_tmplts_tl_rec_type;
    lx_okl_process_tmplts_tl_rec   okl_process_tmplts_tl_rec_type;
    l_ptm_rec                      ptm_rec_type;
    lx_ptm_rec                     ptm_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_ptmv_rec	IN ptmv_rec_type
    ) RETURN ptmv_rec_type IS
      l_ptmv_rec	ptmv_rec_type := p_ptmv_rec;
    BEGIN
      l_ptmv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_ptmv_rec.LAST_UPDATED_BY := Fnd_Global.User_Id;
      l_ptmv_rec.LAST_UPDATE_LOGIN := Fnd_Global.LOGIN_ID;
      RETURN(l_ptmv_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_ptmv_rec	IN ptmv_rec_type,
      x_ptmv_rec	OUT NOCOPY ptmv_rec_type
    ) RETURN VARCHAR2 IS
      l_ptmv_rec                     ptmv_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;

    BEGIN

      x_ptmv_rec := p_ptmv_rec;
      -- Get current database values
      l_ptmv_rec := get_rec(p_ptmv_rec, l_row_notfound);

      IF (l_row_notfound) THEN
        l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
        RETURN(l_return_status);
      END IF;
      IF (x_ptmv_rec.org_id = OKL_API.G_MISS_NUM)
      THEN
        x_ptmv_rec.org_id := l_ptmv_rec.org_id;
      END IF;
      IF (x_ptmv_rec.ptm_code = OKL_API.G_MISS_CHAR)
      THEN
        x_ptmv_rec.ptm_code := l_ptmv_rec.ptm_code;
      END IF;
      IF (x_ptmv_rec.jtf_amv_item_id = OKL_API.G_MISS_NUM)
      THEN
        x_ptmv_rec.jtf_amv_item_id := l_ptmv_rec.jtf_amv_item_id;
      END IF;
      IF (x_ptmv_rec.sfwt_flag = OKL_API.G_MISS_CHAR)
      THEN
        x_ptmv_rec.sfwt_flag := l_ptmv_rec.sfwt_flag;
      END IF;
      IF (x_ptmv_rec.email_subject_line = OKL_API.G_MISS_CHAR)
      THEN
        x_ptmv_rec.email_subject_line := l_ptmv_rec.email_subject_line;
      END IF;
      IF (x_ptmv_rec.start_date = OKL_API.G_MISS_DATE)
      THEN
        x_ptmv_rec.start_date := l_ptmv_rec.start_date;
      END IF;
      IF (x_ptmv_rec.end_date = OKL_API.G_MISS_DATE)
      THEN
        x_ptmv_rec.end_date := l_ptmv_rec.end_date;
      END IF;
      IF (x_ptmv_rec.attribute_category = OKL_API.G_MISS_CHAR)
      THEN
        x_ptmv_rec.attribute_category := l_ptmv_rec.attribute_category;
      END IF;
      IF (x_ptmv_rec.attribute1 = OKL_API.G_MISS_CHAR)
      THEN
        x_ptmv_rec.attribute1 := l_ptmv_rec.attribute1;
      END IF;
      IF (x_ptmv_rec.attribute2 = OKL_API.G_MISS_CHAR)
      THEN
        x_ptmv_rec.attribute2 := l_ptmv_rec.attribute2;
      END IF;
      IF (x_ptmv_rec.attribute3 = OKL_API.G_MISS_CHAR)
      THEN
        x_ptmv_rec.attribute3 := l_ptmv_rec.attribute3;
      END IF;
      IF (x_ptmv_rec.attribute4 = OKL_API.G_MISS_CHAR)
      THEN
        x_ptmv_rec.attribute4 := l_ptmv_rec.attribute4;
      END IF;
      IF (x_ptmv_rec.attribute5 = OKL_API.G_MISS_CHAR)
      THEN
        x_ptmv_rec.attribute5 := l_ptmv_rec.attribute5;
      END IF;
      IF (x_ptmv_rec.attribute6 = OKL_API.G_MISS_CHAR)
      THEN
        x_ptmv_rec.attribute6 := l_ptmv_rec.attribute6;
      END IF;
      IF (x_ptmv_rec.attribute7 = OKL_API.G_MISS_CHAR)
      THEN
        x_ptmv_rec.attribute7 := l_ptmv_rec.attribute7;
      END IF;
      IF (x_ptmv_rec.attribute8 = OKL_API.G_MISS_CHAR)
      THEN
        x_ptmv_rec.attribute8 := l_ptmv_rec.attribute8;
      END IF;
      IF (x_ptmv_rec.attribute9 = OKL_API.G_MISS_CHAR)
      THEN
        x_ptmv_rec.attribute9 := l_ptmv_rec.attribute9;
      END IF;
      IF (x_ptmv_rec.attribute10 = OKL_API.G_MISS_CHAR)
      THEN
        x_ptmv_rec.attribute10 := l_ptmv_rec.attribute10;
      END IF;
      IF (x_ptmv_rec.attribute11 = OKL_API.G_MISS_CHAR)
      THEN
        x_ptmv_rec.attribute11 := l_ptmv_rec.attribute11;
      END IF;
      IF (x_ptmv_rec.attribute12 = OKL_API.G_MISS_CHAR)
      THEN
        x_ptmv_rec.attribute12 := l_ptmv_rec.attribute12;
      END IF;
      IF (x_ptmv_rec.attribute13 = OKL_API.G_MISS_CHAR)
      THEN
        x_ptmv_rec.attribute13 := l_ptmv_rec.attribute13;
      END IF;
      IF (x_ptmv_rec.attribute14 = OKL_API.G_MISS_CHAR)
      THEN
        x_ptmv_rec.attribute14 := l_ptmv_rec.attribute14;
      END IF;
      IF (x_ptmv_rec.attribute15 = OKL_API.G_MISS_CHAR)
      THEN
        x_ptmv_rec.attribute15 := l_ptmv_rec.attribute15;
      END IF;
      IF (x_ptmv_rec.created_by = OKL_API.G_MISS_NUM)
      THEN
        x_ptmv_rec.created_by := l_ptmv_rec.created_by;
      END IF;
      IF (x_ptmv_rec.creation_date = OKL_API.G_MISS_DATE)
      THEN
        x_ptmv_rec.creation_date := l_ptmv_rec.creation_date;
      END IF;
      IF (x_ptmv_rec.last_updated_by = OKL_API.G_MISS_NUM)
      THEN
        x_ptmv_rec.last_updated_by := l_ptmv_rec.last_updated_by;
      END IF;
      IF (x_ptmv_rec.last_update_date = OKL_API.G_MISS_DATE)
      THEN
        x_ptmv_rec.last_update_date := l_ptmv_rec.last_update_date;
      END IF;
      IF (x_ptmv_rec.last_update_login = OKL_API.G_MISS_NUM)
      THEN
        x_ptmv_rec.last_update_login := l_ptmv_rec.last_update_login;
      END IF;
/*      13-OCT-2006  	ANSETHUR
        BUILD  : R12 B
        Start Changes
*/
      IF (x_ptmv_rec.xml_tmplt_code = OKL_API.G_MISS_CHAR)
      THEN
      x_ptmv_rec.xml_tmplt_code:= l_ptmv_rec.xml_tmplt_code;
      END IF;
      IF (x_ptmv_rec.recipient_type_Code = OKL_API.G_MISS_CHAR)
      THEN
      x_ptmv_rec.recipient_type_Code:= l_ptmv_rec.recipient_type_Code;
      END IF;
/*        End  Changes         */
      RETURN(l_return_status);
   END populate_new_record;
    ---------------------------------------------
    -- Set_Attributes for:okl_process_tmplts_v --
    ---------------------------------------------
    FUNCTION Set_Attributes (p_ptmv_rec IN  ptmv_rec_type,
                             x_ptmv_rec OUT NOCOPY ptmv_rec_type) RETURN VARCHAR2 IS

      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
      l_org_id                       hr_operating_units.organization_id%TYPE;

    BEGIN
      x_ptmv_rec := p_ptmv_rec;

      --fnd_profile.get('ORG_ID', l_org_id);
      l_org_id := mo_global.get_current_org_id();
      x_ptmv_rec.ORG_ID := l_org_id;

      -- NOTE: OVN must be sent from UI for this to work.  Server cannot make distinction between
      -- G_MISS_NUM and (G_MISS_NUM + 1)

      x_ptmv_rec.OBJECT_VERSION_NUMBER := NVL(x_ptmv_rec.OBJECT_VERSION_NUMBER, 0) + 1;
      RETURN(l_return_status);
    END Set_Attributes;

  BEGIN

    l_return_status := OKL_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);

    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    l_return_status := Set_Attributes(p_ptmv_rec, l_ptmv_rec);

    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    l_return_status := populate_new_record(l_ptmv_rec, l_def_ptmv_rec);

    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    l_def_ptmv_rec := fill_who_columns(l_def_ptmv_rec);

    l_return_status := Validate_Attributes(l_def_ptmv_rec);

    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

/*      13-OCT-2006  	ANSETHUR
        BUILD  : R12 B
        Start Changes
*/
 --   l_return_status := Validate_Record(l_def_ptmv_rec);
    Validate_tmplt_record(  l_def_ptmv_rec ,  l_return_status );
/*        End  Changes         */

    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_ptmv_rec, l_okl_process_tmplts_tl_rec);
    migrate(l_def_ptmv_rec, l_ptm_rec);
    --------------------------------------------
    -- Call the UPDATE_ROW for each child record
    --------------------------------------------
    update_row(p_init_msg_list,
               x_return_status,
               x_msg_count,
               x_msg_data,
               l_okl_process_tmplts_tl_rec,
               lx_okl_process_tmplts_tl_rec);

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    migrate(lx_okl_process_tmplts_tl_rec, l_def_ptmv_rec);

    update_row(p_init_msg_list,
               x_return_status,
               x_msg_count,
               x_msg_data,
               l_ptm_rec,
               lx_ptm_rec);

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    migrate(lx_ptm_rec, l_def_ptmv_rec);
    x_ptmv_rec := l_def_ptmv_rec;

    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);

  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
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
  -- PL/SQL TBL update_row for:PTMV_TBL --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ptmv_tbl                     IN ptmv_tbl_type,
    x_ptmv_tbl                     OUT NOCOPY ptmv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_ptmv_tbl.COUNT > 0) THEN
      i := p_ptmv_tbl.FIRST;
      LOOP
        update_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKL_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_ptmv_rec                     => p_ptmv_tbl(i),
          x_ptmv_rec                     => x_ptmv_tbl(i));


        EXIT WHEN (i = p_ptmv_tbl.LAST);
        i := p_ptmv_tbl.NEXT(i);
      END LOOP;
    END IF;
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
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
  -- delete_row for:OKL_PROCESS_TMPLTS_B --
  -----------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ptm_rec                      IN ptm_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_delete_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_ptm_rec                      ptm_rec_type:= p_ptm_rec;
    l_row_notfound                 BOOLEAN := TRUE;

  BEGIN

    l_return_status := OKL_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);

    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    DELETE FROM OKL_PROCESS_TMPLTS_B
     WHERE ID = l_ptm_rec.id;

    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);

  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
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
  -- delete_row for:OKL_PROCESS_TMPLTS_TL --
  ------------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_process_tmplts_tl_rec    IN okl_process_tmplts_tl_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_delete_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_okl_process_tmplts_tl_rec    okl_process_tmplts_tl_rec_type:= p_okl_process_tmplts_tl_rec;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------------------
    -- Set_Attributes for:OKL_PROCESS_TMPLTS_TL --
    ----------------------------------------------
    FUNCTION Set_Attributes (
      p_okl_process_tmplts_tl_rec IN  okl_process_tmplts_tl_rec_type,
      x_okl_process_tmplts_tl_rec OUT NOCOPY okl_process_tmplts_tl_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_okl_process_tmplts_tl_rec := p_okl_process_tmplts_tl_rec;
      x_okl_process_tmplts_tl_rec.LANGUAGE := USERENV('LANG');
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := OKL_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      p_okl_process_tmplts_tl_rec,       -- IN
      l_okl_process_tmplts_tl_rec);      -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    DELETE FROM OKL_PROCESS_TMPLTS_TL
     WHERE ID = l_okl_process_tmplts_tl_rec.id;

    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
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
  -- delete_row for:OKL_PROCESS_TMPLTS_V --
  -----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ptmv_rec                     IN ptmv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_ptmv_rec                     ptmv_rec_type := p_ptmv_rec;
    l_okl_process_tmplts_tl_rec    okl_process_tmplts_tl_rec_type;
    l_ptm_rec                      ptm_rec_type;
  BEGIN
    l_return_status := OKL_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_ptmv_rec, l_okl_process_tmplts_tl_rec);
    migrate(l_ptmv_rec, l_ptm_rec);
    --------------------------------------------
    -- Call the DELETE_ROW for each child record
    --------------------------------------------
    delete_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okl_process_tmplts_tl_rec
    );
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    delete_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_ptm_rec
    );
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
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
  -- PL/SQL TBL delete_row for:PTMV_TBL --
  ----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ptmv_tbl                     IN ptmv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_ptmv_tbl.COUNT > 0) THEN
      i := p_ptmv_tbl.FIRST;
      LOOP
        delete_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKL_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_ptmv_rec                     => p_ptmv_tbl(i));
        EXIT WHEN (i = p_ptmv_tbl.LAST);
        i := p_ptmv_tbl.NEXT(i);
      END LOOP;
    END IF;
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END delete_row;

END Okl_Ptm_Pvt;


/
