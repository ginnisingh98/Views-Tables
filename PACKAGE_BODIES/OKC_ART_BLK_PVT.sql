--------------------------------------------------------
--  DDL for Package Body OKC_ART_BLK_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_ART_BLK_PVT" AS
/* $Header: OKCVARTBLKB.pls 120.0.12010000.2 2011/09/28 14:19:09 serukull ship $ */

G_APP_NAME			CONSTANT	VARCHAR2(3)   := OKC_API.G_APP_NAME;
G_PKG_NAME			CONSTANT	VARCHAR2(200) := 'OKC_ART_BLK_PVT';

G_MSG_ART_INACTIVE_VARIABLE CONSTANT	VARCHAR2(30)	:= 'OKC_CHECK_ART_INV_VAR';
G_MSG_ART_INVALID_VALUESET	CONSTANT	VARCHAR2(30)	:= 'OKC_CHECK_ART_INV_VAL';
G_MSG_ART_INVALID_SECTION	CONSTANT	VARCHAR2(30)	:= 'OKC_CHECK_ART_DEF_SEC';
G_MSG_ART_INVALID_TYPE		CONSTANT	VARCHAR2(30)	:= 'OKC_CHECK_ART_INV_TYP';
G_MSG_INVALID_STS_CHANGE	CONSTANT	VARCHAR2(30)	:= 'OKC_CHECK_ART_INV_STS';

G_CHK_ART_INACTIVE_VARIABLE CONSTANT	VARCHAR2(30)	:= 'CHECK_ART_INV_VAR';
G_CHK_ART_INVALID_VALUESET	CONSTANT	VARCHAR2(30)	:= 'CHECK_ART_INV_VAL';
G_CHK_ART_INVALID_SECTION	CONSTANT	VARCHAR2(30)	:= 'CHECK_ART_DEF_SEC';
G_CHK_ART_INVALID_TYPE		CONSTANT	VARCHAR2(30)	:= 'CHECK_ART_INV_TYP';
G_CHK_INVALID_STS_CHANGE    CONSTANT	VARCHAR2(30)	:= 'CHECK_ART_INV_STS';

G_MSG_ART_INV_CALLING_ORG	CONSTANT	VARCHAR2(30)	:= 'OKC_CHECK_ART_INV_CAL_ORG';
G_CHK_INVALID_ADOPTION		CONSTANT	VARCHAR2(30)	:= 'CHECK_ART_INV_ADP';
G_CHK_ADOPTION_UNEXP_ERROR	CONSTANT	VARCHAR2(30)	:= 'CHECK_ART_ADP_UNP_ERR';
G_OKC_MSG_INVALID_ARGUMENT  CONSTANT    VARCHAR2(200) := 'OKC_INVALID_ARGUMENT';
-- ARG_NAME ARG_VALUE is invalid.

G_GLOBAL_ORG_ID		    NUMBER;
G_USER_ID               NUMBER;
G_LOGIN_ID              NUMBER;

l_debug                 VARCHAR2(1);

---------- Internal Procedures BEGIN  ---------------------------

PROCEDURE get_version_details(
	p_org_id				IN	NUMBER ,
	p_art_ver_tbl			IN	num_tbl_type ,
	x_return_status			OUT	NOCOPY VARCHAR2,
    x_id                    OUT NOCOPY NUMBER ,
    x_adopt_asis_count      OUT NOCOPY NUMBER ,
    x_global_count          OUT NOCOPY NUMBER ,
    x_localized_count       OUT NOCOPY NUMBER);

PROCEDURE status_check_blk(
	p_id				    IN	NUMBER ,
	p_to_status				IN	VARCHAR2 ,
	x_return_status			OUT	NOCOPY VARCHAR2 ,
    x_qa_return_status      OUT NOCOPY VARCHAR2 ,
	px_validation_results	IN	OUT NOCOPY validation_tbl_type );

PROCEDURE variable_check_blk(
	p_id				    IN	NUMBER,
	x_return_status			OUT	NOCOPY VARCHAR2 ,
    x_qa_return_status      OUT NOCOPY VARCHAR2 ,
	px_validation_results	IN	OUT NOCOPY validation_tbl_type );

PROCEDURE section_type_check_blk(
	p_id				    IN	NUMBER,
	x_return_status			OUT	NOCOPY VARCHAR2 ,
    x_qa_return_status      OUT NOCOPY VARCHAR2 ,
	px_validation_results	IN	OUT NOCOPY validation_tbl_type );

PROCEDURE update_art_version_status_blk(
	p_id				    IN	NUMBER ,
	p_status				IN	VARCHAR2 ,
	x_return_status			OUT	NOCOPY VARCHAR2 );

PROCEDURE update_adp_status_type_blk(
	p_id				    IN	NUMBER ,
    p_local_org_id          IN  NUMBER,
	p_adoption_status		IN	VARCHAR2 ,
	p_adoption_type			IN	VARCHAR2 ,
    p_type                  IN  VARCHAR2,
	x_return_status			OUT	NOCOPY VARCHAR2 );

PROCEDURE update_prev_vers_enddate_blk(
	p_id				    IN	NUMBER ,
  	x_return_status			OUT	NOCOPY VARCHAR2 );

PROCEDURE adopt_relationships_blk(
	p_id        			IN	NUMBER,
	x_return_status			OUT	NOCOPY VARCHAR2	);

PROCEDURE delete_relationships_blk(
	p_id				    IN	NUMBER,
    p_org_id                IN  NUMBER,
	x_return_status			OUT	NOCOPY VARCHAR2 );

---------- Internal Procedures END  -----------------------------


--------------------------------------------------------------------------------------------
FUNCTION get_uniq_id RETURN NUMBER
IS

    l_api_name			CONSTANT VARCHAR2(30) := 'get_version_details';
    l_num               NUMBER;

    CURSOR c1 IS
        SELECT OKC_ART_BLK_TEMP_S1.NEXTVAL FROM DUAL;
BEGIN

    OPEN c1;
    FETCH c1 INTO l_num;
    CLOSE c1;

    RETURN l_num;

EXCEPTION
    WHEN OTHERS THEN

        IF (l_debug = 'Y') THEN
            okc_debug.log('201: Leaving get_uniq_id: Unknown error');
        END IF;

        IF (c1%ISOPEN) THEN
            CLOSE c1;
        END IF;

		IF 	fnd_msg_pub.check_msg_level(fnd_msg_pub.G_MSG_LVL_UNEXP_ERROR)
		THEN
			fnd_msg_pub.add_exc_msg(G_PKG_NAME ,l_api_name );
		END IF;
        RAISE;
END;

-----------------------------------------------------------------------------

PROCEDURE get_version_details(
	p_org_id				IN	NUMBER ,
	p_art_ver_tbl			IN	num_tbl_type ,
	x_return_status			OUT	NOCOPY VARCHAR2,
    x_id                    OUT NOCOPY NUMBER ,
    x_adopt_asis_count      OUT NOCOPY NUMBER ,
    x_global_count          OUT NOCOPY NUMBER ,
    x_localized_count       OUT NOCOPY NUMBER)
IS

    l_api_name			CONSTANT VARCHAR2(30) := 'get_version_details';
    l_total_count       NUMBER := 0;
    l_invalid           BOOLEAN := FALSE;

    CURSOR l_count_csr (cp_id IN NUMBER) IS
        SELECT sum(to_number(decode(adopt_asis_yn, 'Y', '1', '0'))) adopt_is_count,
            sum(to_number(decode(global_yn, 'Y', '1', '0'))) global_count,
            sum(to_number(decode(localized_yn, 'Y', '1', '0'))) localized_count,
            count(*) total_count
        FROM OKC_ART_BLK_TEMP
        WHERE id = cp_id;

BEGIN

    IF (l_debug = 'Y') THEN
        okc_debug.log('100: Entering get_version_details: p_org_id='||p_org_id);
    END IF;

	x_return_status := FND_API.G_RET_STS_SUCCESS;
	IF (p_art_ver_tbl IS NULL ) THEN
        l_invalid := TRUE;
    ELSIF (p_art_ver_tbl.COUNT < 1) THEN
        l_invalid := TRUE;
    END IF;
    IF (l_invalid)  THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MESSAGE.set_name(G_APP_NAME, G_OKC_MSG_INVALID_ARGUMENT);
        FND_MESSAGE.set_token('ARG_NAME', 'p_art_ver_tbl');
        FND_MESSAGE.set_token('ARG_VALUE', 'NULL');
        FND_MSG_PUB.add;
        RAISE fnd_api.g_exc_error;
    END IF;

    IF (p_org_id IS NULL) THEN
        FND_MESSAGE.set_name(G_APP_NAME, G_OKC_MSG_INVALID_ARGUMENT);
        FND_MESSAGE.set_token('ARG_NAME', 'p_org_id');
        FND_MESSAGE.set_token('ARG_VALUE', 'p_org_id');
        FND_MSG_PUB.add;
        RAISE fnd_api.g_exc_error;
    END IF;


    x_id            := get_uniq_id;

	IF ( p_org_id = G_GLOBAL_ORG_ID) THEN
		-- if we are in global org, store the list of articles with global_yn = Y

        FORALL i in p_art_ver_tbl.FIRST..p_art_ver_tbl.LAST
            INSERT INTO OKC_ART_BLK_TEMP
            (
                ID,
                ARTICLE_ID,
                ARTICLE_VERSION_ID,
                ORG_ID,
                ARTICLE_TITLE,
                DISPLAY_NAME,
                ARTICLE_TYPE,
                DEFAULT_SECTION,
                STATUS,
                START_DATE,
                ADOPT_ASIS_YN,
                GLOBAL_YN,
                LOCALIZED_YN
            )
            SELECT x_id, ART.article_id, VER.article_version_id, ART.org_id,
                ART.ARTICLE_TITLE, VER.DISPLAY_NAME, ART.ARTICLE_TYPE,
                nvl(VER.DEFAULT_SECTION, 'UNASSIGNED'), nvl(VER.ARTICLE_STATUS,'DRAFT'),
                VER.start_date, 'N', nvl(VER.GLOBAL_YN, 'N'), 'N'
            FROM OKC_ARTICLES_ALL ART, OKC_ARTICLE_VERSIONS VER
            WHERE VER.article_version_id = p_art_ver_tbl(i)
                AND ART.ARTICLE_ID = VER.ARTICLE_ID
                AND ART.ORG_ID = G_GLOBAL_ORG_ID;

	ELSE
		-- we are not in the global org,
        -- get the local/localized articles
        FORALL i in p_art_ver_tbl.FIRST..p_art_ver_tbl.LAST
            INSERT INTO OKC_ART_BLK_TEMP
            (
                ID,
                ARTICLE_ID,
                ARTICLE_VERSION_ID,
                ORG_ID,
                ARTICLE_TITLE,
                DISPLAY_NAME,
                ARTICLE_TYPE,
                DEFAULT_SECTION,
                STATUS,
                START_DATE,
                ADOPT_ASIS_YN,
                GLOBAL_YN,
                LOCALIZED_YN
            )
            SELECT x_id, ART.article_id, VER.article_version_id, ART.org_id,
                ART.ARTICLE_TITLE, VER.DISPLAY_NAME, ART.ARTICLE_TYPE,
                nvl(VER.DEFAULT_SECTION, 'UNASSIGNED'), nvl(VER.ARTICLE_STATUS,'DRAFT'),
                VER.start_date,'N', 'N', decode(VER.ADOPTION_TYPE, 'LOCALIZED', 'Y', 'N')
            FROM OKC_ARTICLES_ALL ART, OKC_ARTICLE_VERSIONS VER
            WHERE VER.article_version_id = p_art_ver_tbl(i)
                AND ART.ARTICLE_ID = VER.ARTICLE_ID
                AND ART.ORG_ID = p_org_id;

        -- get the adopt as is articles
        FORALL i in p_art_ver_tbl.FIRST..p_art_ver_tbl.LAST
            INSERT INTO OKC_ART_BLK_TEMP
            (
                ID,
                ARTICLE_ID,
                ARTICLE_VERSION_ID,
                ORG_ID,
                ARTICLE_TITLE,
                DISPLAY_NAME,
                ARTICLE_TYPE,
                DEFAULT_SECTION,
                STATUS,
                START_DATE,
                ADOPT_ASIS_YN,
                GLOBAL_YN,
                LOCALIZED_YN
            )
            SELECT x_id, ART.article_id, VER.article_version_id, ART.org_id,
                ART.ARTICLE_TITLE, VER.DISPLAY_NAME, ART.ARTICLE_TYPE,
                nvl(VER.DEFAULT_SECTION, 'UNASSIGNED'), nvl(ADP.ADOPTION_STATUS,'DRAFT'),
                VER.start_date,'Y', 'N', 'N'
            FROM OKC_ARTICLES_ALL ART, OKC_ARTICLE_VERSIONS VER, OKC_ARTICLE_ADOPTIONS ADP
            WHERE VER.article_version_id = p_art_ver_tbl(i)
                AND ART.ARTICLE_ID = VER.ARTICLE_ID
                AND ART.ORG_ID = G_GLOBAL_ORG_ID
                AND ADP.GLOBAL_ARTICLE_VERSION_ID = VER.ARTICLE_VERSION_ID
                AND ADP.LOCAL_ORG_ID = p_org_id;

    END IF; -- of IF/ELSE ( p_org_id = G_GLOBAL_ORG_ID)

    OPEN l_count_csr(x_id);
    FETCH l_count_csr INTO   x_adopt_asis_count, x_global_count, x_localized_count, l_total_count;
    CLOSE l_count_csr;

    IF (l_total_count <> p_art_ver_tbl.COUNT) THEN

        IF (l_debug = 'Y') THEN
            okc_debug.log('198: l_total_count='||l_total_count||' p_art_ver_tbl.COUNT='||p_art_ver_tbl.COUNT);
            okc_debug.log('199: This indicates that some article versions belonged to an org other than input org='||p_org_id);
        END IF;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MESSAGE.set_name(G_APP_NAME, G_OKC_MSG_INVALID_ARGUMENT);
        FND_MESSAGE.set_token('ARG_NAME', 'p_org_id');
        FND_MESSAGE.set_token('ARG_VALUE', p_org_id);
        FND_MSG_PUB.add;
        RAISE fnd_api.g_exc_error;
    END IF;

    IF (l_debug = 'Y') THEN
        okc_debug.log('200: Leaving get_version_details: Success, x_id='||x_id||'   x_adopt_asis_count='|| x_adopt_asis_count||' x_global_count='|| x_global_count|| ' x_localized_count='||x_localized_count);
    END IF;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
		x_return_status := FND_API.G_RET_STS_ERROR;
        IF (l_count_csr%ISOPEN) THEN
            CLOSE l_count_csr;
        END IF;

        IF (l_debug = 'Y') THEN
            okc_debug.log('201: Leaving get_version_details: Error');
        END IF;

	WHEN OTHERS THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (l_count_csr%ISOPEN) THEN
            CLOSE l_count_csr;
        END IF;

        IF (l_debug = 'Y') THEN
            okc_debug.log('202: Leaving get_version_details: Unknown error');
        END IF;

		IF 	fnd_msg_pub.check_msg_level(fnd_msg_pub.G_MSG_LVL_UNEXP_ERROR)
		THEN
			fnd_msg_pub.add_exc_msg(G_PKG_NAME ,l_api_name );
		END IF;

END get_version_details;

-----------------------------------------------------------------------------

PROCEDURE status_check_blk(
	p_id				    IN	NUMBER ,
	p_to_status				IN	VARCHAR2 ,
	x_return_status			OUT	NOCOPY VARCHAR2 ,
    x_qa_return_status      OUT NOCOPY VARCHAR2 ,
	px_validation_results	IN	OUT NOCOPY validation_tbl_type )
IS

    l_api_name			CONSTANT VARCHAR2(30) := 'status_check_blk';

    CURSOR l_pend_app_csr IS
        SELECT article_id, article_version_id, nvl(display_name, article_title),
        nvl(status, 'DRAFT')
        FROM OKC_ART_BLK_TEMP
        WHERE id = p_id AND
        status NOT IN ('DRAFT', 'REJECTED');

    CURSOR l_app_rej_csr IS
        SELECT article_id, article_version_id,  nvl(display_name, article_title),
        nvl(status, 'DRAFT')
        FROM OKC_ART_BLK_TEMP
        WHERE id = p_id AND
        status <> 'PENDING_APPROVAL';

    CURSOR l_status_csr is
        SELECT NVL(lookup_code, 'X'), NVL(meaning, 'UNDEFINED')
        FROM fnd_lookup_values_vl
        WHERE lookup_type = 'OKC_ARTICLE_STATUS';

    errnum					INTEGER := 0;
    initerrnum				INTEGER := 0;

    l_found					BOOLEAN := FALSE;

    l_art_id_tbl			num_tbl_type;
    l_art_ver_id_tbl		num_tbl_type;
    l_art_title_tbl			varchar_tbl_type;
    l_ver_from_status_tbl	varchar_tbl_type;

    l_status_code_tbl       varchar_tbl_type;
    l_status_meaning_tbl    varchar_tbl_type;

    l_to_status_meaning     FND_LOOKUP_VALUES_VL.MEANING%TYPE;
    l_from_status_meaning    FND_LOOKUP_VALUES_VL.MEANING%TYPE;

    FUNCTION get_status_meaning(p_status IN VARCHAR2) RETURN VARCHAR2
    IS
    BEGIN

        IF ((l_status_code_tbl IS NOT NULL) AND (l_status_meaning_tbl IS NOT NULL)) THEN

            FOR i IN l_status_code_tbl.FIRST..l_status_code_tbl.LAST LOOP

                IF (trim(l_status_code_tbl(i)) = trim(nvl(p_status,'Y'))) THEN
                    RETURN  l_status_meaning_tbl(i);
                END IF;

            END LOOP;
        END IF;

        -- if we reach here, then not able to find the status meaning, return status code as is.
        RETURN p_status;
    END get_status_meaning;


BEGIN

    IF (l_debug = 'Y') THEN
        okc_debug.log('100: Entering status_check_blk: p_id='||p_id||' p_to_status='||p_to_status);
    END IF;
	x_return_status := FND_API.G_RET_STS_SUCCESS;
	x_qa_return_status := FND_API.G_RET_STS_SUCCESS;

	errnum := px_validation_results.COUNT;
	initerrnum := errnum;

    IF (nvl(p_to_status,'X') = 'PENDING_APPROVAL') THEN

        OPEN l_pend_app_csr;
        FETCH l_pend_app_csr BULK COLLECT INTO l_art_id_tbl, l_art_ver_id_tbl,
            l_art_title_tbl, l_ver_from_status_tbl;

        IF (l_art_id_tbl.COUNT > 0) THEN
            l_found := TRUE;
	    END IF;
        CLOSE l_pend_app_csr;

    ELSIF (nvl(p_to_status,'X') IN ('APPROVED', 'REJECTED')) THEN

        OPEN l_app_rej_csr;
        FETCH l_app_rej_csr BULK COLLECT INTO l_art_id_tbl, l_art_ver_id_tbl,
            l_art_title_tbl, l_ver_from_status_tbl;

        IF (l_art_id_tbl.COUNT > 0) THEN
            l_found := TRUE;
	    END IF;
        CLOSE l_app_rej_csr;

    ELSE
        -- status change not recognized
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MESSAGE.set_name(G_APP_NAME, G_OKC_MSG_INVALID_ARGUMENT);
        FND_MESSAGE.set_token('ARG_NAME', 'p_to_status');
        FND_MESSAGE.set_token('ARG_VALUE', p_to_status);
        FND_MSG_PUB.add;
        RAISE FND_API.G_EXC_ERROR;

    END IF;

	IF (l_found) THEN

        OPEN l_status_csr;
        FETCH l_status_csr BULK COLLECT INTO l_status_code_tbl, l_status_meaning_tbl;
        CLOSE l_status_csr;

        l_to_status_meaning := get_status_meaning(p_to_status);

		FOR i IN  l_art_id_tbl.FIRST..l_art_id_tbl.LAST LOOP

            errnum := errnum + 1;
            px_validation_results(errnum).article_id			:= l_art_id_tbl(i);
            px_validation_results(errnum).article_version_id	:= l_art_ver_id_tbl(i);
            px_validation_results(errnum).article_title			:= l_art_title_tbl(i);
            px_validation_results(errnum).error_code			:= G_CHK_INVALID_STS_CHANGE;

            FND_MESSAGE.set_name(G_APP_NAME, G_MSG_INVALID_STS_CHANGE);
            FND_MESSAGE.set_token('ARTICLE_TITLE', l_art_title_tbl(i));
            FND_MESSAGE.set_token('FROM_STATUS', get_status_meaning(l_ver_from_status_tbl(i)));
            FND_MESSAGE.set_token('TO_STATUS', l_to_status_meaning);

            px_validation_results(errnum).error_message			:= FND_MESSAGE.get;

		END LOOP;

        l_status_code_tbl.DELETE;
        l_status_meaning_tbl.DELETE;

	END IF;

	l_art_id_tbl.DELETE;
	l_art_ver_id_tbl.DELETE;
	l_art_title_tbl.DELETE;
	l_ver_from_status_tbl.DELETE;



	IF (errnum > initerrnum) THEN
		x_qa_return_status := FND_API.G_RET_STS_ERROR;
	END IF;

    IF (l_debug = 'Y') THEN
        okc_debug.log('200: Leaving status_check_blk: Success, x_qa_return_status='||x_qa_return_status);
    END IF;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR ;
        IF (l_debug = 'Y') THEN
            okc_debug.log('201: Leaving status_check_blk: Error');
        END IF;
        IF (l_pend_app_csr%ISOPEN) THEN
            CLOSE l_pend_app_csr;
        END IF;
        IF (l_app_rej_csr%ISOPEN) THEN
            CLOSE l_app_rej_csr;
        END IF;
        IF (l_status_csr%ISOPEN) THEN
            CLOSE l_status_csr;
        END IF;

    WHEN OTHERS THEN

		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (l_debug = 'Y') THEN
            okc_debug.log('202: Leaving status_check_blk: Unknown Error');
        END IF;
        IF (l_pend_app_csr%ISOPEN) THEN
            CLOSE l_pend_app_csr;
        END IF;
        IF (l_app_rej_csr%ISOPEN) THEN
            CLOSE l_app_rej_csr;
        END IF;
        IF (l_status_csr%ISOPEN) THEN
            CLOSE l_status_csr;
        END IF;

        IF 	FND_MSG_PUB.check_msg_level(fnd_msg_pub.G_MSG_LVL_UNEXP_ERROR) THEN
			FND_MSG_PUB.add_exc_msg(G_PKG_NAME ,l_api_name );
		END IF;

END status_check_blk;

-----------------------------------------------------------------------------

PROCEDURE variable_check_blk(
	p_id				    IN	NUMBER,
	x_return_status			OUT	NOCOPY VARCHAR2 ,
    x_qa_return_status      OUT NOCOPY VARCHAR2 ,
	px_validation_results	IN	OUT NOCOPY validation_tbl_type )
IS
    l_api_name			CONSTANT VARCHAR2(30) := 'variable_check_blk';

    -- check for disabled variables
    CURSOR l_disabled_var_csr (cp_id IN NUMBER) IS
        SELECT TMP.article_id, TMP.article_version_id, nvl(TMP.display_name, TMP.article_title),
        BVT.variable_name
        FROM OKC_BUS_VARIABLES_TL BVT,
            OKC_BUS_VARIABLES_B BVB,
            OKC_ARTICLE_VARIABLES AAV,
            OKC_ART_BLK_TEMP TMP
        WHERE TMP.id = cp_id
            AND TMP.adopt_asis_yn = 'N' --check not done for adopt as is clauses
            AND AAV.article_version_id = TMP.article_version_id
            AND BVB.variable_code = AAV.variable_code
            AND nvl(BVB.disabled_yn,'N') = 'Y'
            AND BVT.language = userenv('LANG')
            AND BVT.variable_code = BVB.variable_code;

    -- check for user-defined variables with invalid value sets
    CURSOR l_invalid_valueset_csr (cp_id IN NUMBER) IS
        SELECT TMP.article_id, TMP.article_version_id, nvl(TMP.display_name, TMP.article_title),
        BVT.variable_name,
        nvl(FVS.flex_value_set_id, -99)
        FROM OKC_BUS_VARIABLES_TL BVT,
            FND_FLEX_VALUE_SETS FVS,
            OKC_BUS_VARIABLES_B BVB,
            OKC_ARTICLE_VARIABLES AAV,
            OKC_ART_BLK_TEMP TMP
        WHERE TMP.id = cp_id
            AND TMP.adopt_asis_yn = 'N' --check not done for adopt as is clauses
            AND AAV.article_version_id = TMP.article_version_id
            AND BVB.variable_code = AAV.variable_code
            AND BVB.variable_type = 'U'
            AND BVB.value_set_id = FVS.flex_value_set_id (+)
            AND BVT.language = userenv('LANG')
            AND nvl(BVB.MRV_FLAG,'N')='N'   -- Exempt MRV from validation
            AND BVT.variable_code = BVB.variable_code;

	l_art_id_tbl			num_tbl_type;
    l_art_ver_id_tbl		num_tbl_type;
    l_art_title_tbl			varchar_tbl_type;
    l_var_name_tbl			varchar_tbl_type;
    l_val_set_tbl			num_tbl_type;

    l_found					BOOLEAN := FALSE;
    errnum					INTEGER := 0;
    initerrnum				INTEGER := 0;

BEGIN

    IF (l_debug = 'Y') THEN
        okc_debug.log('100: Entering variable_check_blk: p_id='||p_id);
    END IF;
	x_return_status := FND_API.G_RET_STS_SUCCESS;
	x_qa_return_status := FND_API.G_RET_STS_SUCCESS;

	errnum := px_validation_results.COUNT;
	initerrnum := errnum;

	OPEN l_disabled_var_csr(p_id);
	FETCH l_disabled_var_csr  BULK COLLECT INTO l_art_id_tbl, l_art_ver_id_tbl, l_art_title_tbl,
	l_var_name_tbl;
	IF ( l_art_id_tbl.COUNT > 0 ) THEN
		l_found := TRUE;
	END IF;
	CLOSE l_disabled_var_csr;

	IF (l_found) THEN
		FOR i IN  l_art_id_tbl.FIRST..l_art_id_tbl.LAST LOOP
			errnum := errnum + 1;
			px_validation_results(errnum).article_id				:= l_art_id_tbl(i);
			px_validation_results(errnum).article_version_id		:= l_art_ver_id_tbl(i);
			px_validation_results(errnum).article_title				:= l_art_title_tbl(i);
			px_validation_results(errnum).error_code := G_CHK_ART_INACTIVE_VARIABLE;
			FND_MESSAGE.set_name(G_APP_NAME, G_MSG_ART_INACTIVE_VARIABLE);
			FND_MESSAGE.set_token('ARTICLE_TITLE', l_art_title_tbl(i));
			FND_MESSAGE.set_token('VARIABLE_NAME', l_var_name_tbl(i));
			px_validation_results(errnum).error_message	:= fnd_message.get;
		END LOOP;
	END IF;
    l_found := FALSE;

    OPEN l_invalid_valueset_csr(p_id);
	FETCH l_invalid_valueset_csr  BULK COLLECT INTO l_art_id_tbl, l_art_ver_id_tbl, l_art_title_tbl, l_var_name_tbl, l_val_set_tbl;
	IF ( l_art_id_tbl.COUNT > 0 ) THEN
		l_found := TRUE;
	END IF;
	CLOSE l_invalid_valueset_csr;

	IF (l_found) THEN
		FOR i IN  l_art_id_tbl.FIRST..l_art_id_tbl.LAST LOOP

            IF (l_val_set_tbl(i) = -99) THEN
                errnum := errnum + 1;
                px_validation_results(errnum).article_id				:= l_art_id_tbl(i);
                px_validation_results(errnum).article_version_id		:= l_art_ver_id_tbl(i);
                px_validation_results(errnum).article_title				:= l_art_title_tbl(i);
                px_validation_results(errnum).error_code := G_CHK_ART_INVALID_VALUESET;
                FND_MESSAGE.set_name(G_APP_NAME, G_MSG_ART_INVALID_VALUESET);
                FND_MESSAGE.set_token('ARTICLE_TITLE', l_art_title_tbl(i));
                FND_MESSAGE.set_token('VARIABLE_NAME', l_var_name_tbl(i));
                px_validation_results(errnum).error_message	:= fnd_message.get;
            END IF;

		END LOOP;
	END IF;

    l_art_id_tbl.DELETE;
	l_art_ver_id_tbl.DELETE;
	l_art_title_tbl.DELETE;
	l_var_name_tbl.DELETE;
	l_val_set_tbl.DELETE;

	IF (errnum > initerrnum) THEN
		x_qa_return_status := FND_API.G_RET_STS_ERROR;
	END IF;

    IF (l_debug = 'Y') THEN
        okc_debug.log('200: Leaving variable_check_blk: Success, x_qa_return_status='||x_qa_return_status);
    END IF;

EXCEPTION

    WHEN OTHERS THEN

		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (l_debug = 'Y') THEN
            okc_debug.log('202: Leaving variable_check_blk: Unknown Error');
        END IF;
        IF (l_disabled_var_csr%ISOPEN) THEN
            CLOSE l_disabled_var_csr;
        END IF;
        IF (l_invalid_valueset_csr%ISOPEN) THEN
            CLOSE l_invalid_valueset_csr;
        END IF;

        IF 	FND_MSG_PUB.check_msg_level(fnd_msg_pub.G_MSG_LVL_UNEXP_ERROR) THEN
			FND_MSG_PUB.add_exc_msg(G_PKG_NAME ,l_api_name );
		END IF;

END variable_check_blk;

-----------------------------------------------------------------------------

PROCEDURE section_type_check_blk(
	p_id				    IN	NUMBER,
	x_return_status			OUT	NOCOPY VARCHAR2 ,
    x_qa_return_status      OUT NOCOPY VARCHAR2 ,
	px_validation_results	IN	OUT NOCOPY validation_tbl_type )
IS
    l_api_name			CONSTANT VARCHAR2(30) := 'section_type_check_blk';

    -- check for article_type
    CURSOR l_art_typ_csr (cp_id IN NUMBER, cp_date IN DATE) IS
        SELECT TMP.article_id, TMP.article_version_id, nvl(TMP.display_name, TMP.article_title),
        TMP.article_type
        FROM OKC_ART_BLK_TEMP TMP
        WHERE TMP.id = cp_id
            AND TMP.adopt_asis_yn = 'N' --check not done for adopt as is clauses
        	AND NOT EXISTS (
                SELECT '1' from FND_LOOKUPS F
                WHERE F.lookup_type = 'OKC_SUBJECT'
                AND	  F.lookup_code =  TMP.article_type
                AND trunc(cp_date) BETWEEN trunc(nvl(F.start_date_active, cp_date)) AND
                                nvl(F.end_date_active, cp_date));

    -- check for default_section
    CURSOR l_def_sec_csr (cp_id IN NUMBER, cp_date IN DATE) IS
        SELECT TMP.article_id, TMP.article_version_id, nvl(TMP.display_name, TMP.article_title),
        TMP.default_section
        FROM OKC_ART_BLK_TEMP TMP
        WHERE TMP.id = cp_id
            AND TMP.adopt_asis_yn = 'N' --check not done for adopt as is clauses
            AND TMP.default_section <> 'UNASSIGNED'
        	AND NOT EXISTS (
                SELECT '1' from FND_LOOKUPS F
                WHERE F.lookup_type = 'OKC_ARTICLE_SECTION'
                AND	  F.lookup_code =  TMP.default_section
                AND trunc(cp_date) BETWEEN trunc(nvl(F.start_date_active, cp_date)) AND
                            nvl(F.end_date_active, cp_date));


	l_art_id_tbl			num_tbl_type;
    l_art_ver_id_tbl		num_tbl_type;
    l_art_title_tbl			varchar_tbl_type;
    l_art_typ_tbl			varchar_tbl_type;
    l_def_sec_tbl			varchar_tbl_type;

    l_found					BOOLEAN := FALSE;
    errnum					INTEGER := 0;
    initerrnum				INTEGER := 0;
    l_date                  DATE := sysdate;

BEGIN

    IF (l_debug = 'Y') THEN
        okc_debug.log('100: Entering section_type_check_blk: p_id='||p_id);
    END IF;
	x_return_status := FND_API.G_RET_STS_SUCCESS;
	x_qa_return_status := FND_API.G_RET_STS_SUCCESS;

	errnum := px_validation_results.COUNT;
	initerrnum := errnum;

	OPEN l_art_typ_csr(p_id, l_date);
	FETCH l_art_typ_csr  BULK COLLECT INTO l_art_id_tbl, l_art_ver_id_tbl, l_art_title_tbl,
	l_art_typ_tbl;
	IF ( l_art_id_tbl.COUNT > 0 ) THEN
		l_found := TRUE;
	END IF;
	CLOSE l_art_typ_csr;

	IF (l_found) THEN
		FOR i IN  l_art_id_tbl.FIRST..l_art_id_tbl.LAST LOOP
			errnum := errnum + 1;
			px_validation_results(errnum).article_id				:= l_art_id_tbl(i);
			px_validation_results(errnum).article_version_id		:= l_art_ver_id_tbl(i);
			px_validation_results(errnum).article_title				:= l_art_title_tbl(i);
			px_validation_results(errnum).error_code := G_CHK_ART_INVALID_TYPE;
			FND_MESSAGE.set_name(G_APP_NAME, G_MSG_ART_INVALID_TYPE);
			FND_MESSAGE.set_token('ARTICLE_TITLE', l_art_title_tbl(i));
			FND_MESSAGE.set_token('ARTICLE_TYPE', l_art_typ_tbl(i));
			px_validation_results(errnum).error_message	:= fnd_message.get;
		END LOOP;
	END IF;
    l_found := FALSE;

    OPEN l_def_sec_csr(p_id, l_date);
	FETCH l_def_sec_csr  BULK COLLECT INTO l_art_id_tbl, l_art_ver_id_tbl, l_art_title_tbl, l_def_sec_tbl;
	IF ( l_art_id_tbl.COUNT > 0 ) THEN
		l_found := TRUE;
	END IF;
	CLOSE l_def_sec_csr;

	IF (l_found) THEN
		FOR i IN  l_art_id_tbl.FIRST..l_art_id_tbl.LAST LOOP
            errnum := errnum + 1;
            px_validation_results(errnum).article_id				:= l_art_id_tbl(i);
            px_validation_results(errnum).article_version_id		:= l_art_ver_id_tbl(i);
            px_validation_results(errnum).article_title				:= l_art_title_tbl(i);
            px_validation_results(errnum).error_code := G_CHK_ART_INVALID_SECTION;
            FND_MESSAGE.set_name(G_APP_NAME, G_MSG_ART_INVALID_SECTION);
            FND_MESSAGE.set_token('ARTICLE_TITLE', l_art_title_tbl(i));
            FND_MESSAGE.set_token('DEFAULT_SECTION', l_def_sec_tbl(i));
            px_validation_results(errnum).error_message	:= fnd_message.get;
		END LOOP;
	END IF;

    l_art_id_tbl.DELETE;
	l_art_ver_id_tbl.DELETE;
	l_art_title_tbl.DELETE;
	l_art_typ_tbl.DELETE;
	l_def_sec_tbl.DELETE;

	IF (errnum > initerrnum) THEN
		x_qa_return_status := FND_API.G_RET_STS_ERROR;
	END IF;

    IF (l_debug = 'Y') THEN
        okc_debug.log('200: Leaving section_type_check_blk: Success, x_qa_return_status='||x_qa_return_status);
    END IF;

EXCEPTION

    WHEN OTHERS THEN

		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (l_debug = 'Y') THEN
            okc_debug.log('201: Leaving section_type_check_blk: Unknown Error');
        END IF;
        IF (l_art_typ_csr%ISOPEN) THEN
            CLOSE l_art_typ_csr;
        END IF;
        IF (l_def_sec_csr%ISOPEN) THEN
            CLOSE l_def_sec_csr;
        END IF;

        IF 	FND_MSG_PUB.check_msg_level(fnd_msg_pub.G_MSG_LVL_UNEXP_ERROR) THEN
			FND_MSG_PUB.add_exc_msg(G_PKG_NAME ,l_api_name );
		END IF;

END section_type_check_blk;

-----------------------------------------------------------------------------

PROCEDURE update_art_version_status_blk(
	p_id				    IN	NUMBER ,
	p_status				IN	VARCHAR2 ,
	x_return_status			OUT	NOCOPY VARCHAR2 )
IS

    l_api_name			CONSTANT VARCHAR2(30) := 'update_art_version_status_blk';
    l_date              DATE := sysdate;

BEGIN

    IF (l_debug = 'Y') THEN
        okc_debug.log('100: Entering update_art_version_status_blk: p_id='||p_id||' p_status='||p_status);
    END IF;

	x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF (p_status = 'APPROVED') THEN

        UPDATE OKC_ARTICLE_VERSIONS
		    SET
       			ARTICLE_STATUS              = p_status,
                -- date approved must also be updated
                DATE_APPROVED               = l_date,
                OBJECT_VERSION_NUMBER       = OBJECT_VERSION_NUMBER + 1,
                LAST_UPDATED_BY             = G_USER_ID,
                LAST_UPDATE_LOGIN           = G_LOGIN_ID,
                LAST_UPDATE_DATE            = l_date
            WHERE
                 ARTICLE_VERSION_ID IN
                    (SELECT article_version_id FROM OKC_ART_BLK_TEMP
                        WHERE id = p_id AND adopt_asis_yn = 'N');
    ELSE

       	UPDATE OKC_ARTICLE_VERSIONS
            SET
                ARTICLE_STATUS              = p_status,
                OBJECT_VERSION_NUMBER       = OBJECT_VERSION_NUMBER + 1,
                LAST_UPDATED_BY             = G_USER_ID,
                LAST_UPDATE_LOGIN           = G_LOGIN_ID,
                LAST_UPDATE_DATE            = l_date
            WHERE
                 ARTICLE_VERSION_ID IN
                    (SELECT article_version_id FROM OKC_ART_BLK_TEMP
                        WHERE id = p_id AND adopt_asis_yn = 'N');

    END IF;

    IF (l_debug = 'Y') THEN
        okc_debug.log('200: Leaving update_art_version_status_blk: Success');
    END IF;

EXCEPTION

	WHEN OTHERS THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (l_debug = 'Y') THEN
            okc_debug.log('201: Leaving update_art_version_status_blk: Unknown Error');
        END IF;

        IF 	FND_MSG_PUB.check_msg_level(fnd_msg_pub.G_MSG_LVL_UNEXP_ERROR) THEN
			FND_MSG_PUB.add_exc_msg(G_PKG_NAME ,l_api_name );
		END IF;

END update_art_version_status_blk;

-----------------------------------------------------------------------------

PROCEDURE update_adp_status_type_blk(
	p_id				    IN	NUMBER ,
    p_local_org_id          IN  NUMBER,
	p_adoption_status		IN	VARCHAR2 ,
	p_adoption_type			IN	VARCHAR2 ,
    p_type                  IN  VARCHAR2,
	x_return_status			OUT	NOCOPY VARCHAR2 )
IS

    l_api_name			CONSTANT VARCHAR2(30) := 'update_adp_status_type_blk';
    l_date              DATE := sysdate;

BEGIN

    IF (l_debug = 'Y') THEN
        okc_debug.log('100: Entering update_adp_status_type_blk: p_id='||p_id||' p_local_org_id='||p_local_org_id||' p_adoption_status='||p_adoption_status||' p_adoption_type='||p_adoption_type||' p_type='||p_type);
    END IF;

	x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF (p_type = 'ADOPTED') THEN

        UPDATE OKC_ARTICLE_ADOPTIONS
            SET
                ADOPTION_TYPE               = nvl(p_adoption_type, ADOPTION_TYPE),
                ADOPTION_STATUS             = nvl(p_adoption_status, ADOPTION_STATUS),
                OBJECT_VERSION_NUMBER       = OBJECT_VERSION_NUMBER + 1,
                LAST_UPDATED_BY             = G_USER_ID,
                LAST_UPDATE_LOGIN           = G_LOGIN_ID,
                LAST_UPDATE_DATE            = l_date
            WHERE
                GLOBAL_ARTICLE_VERSION_ID IN
                (SELECT article_version_id FROM OKC_ART_BLK_TEMP
                        WHERE id = p_id AND adopt_asis_yn = 'Y')
                AND LOCAL_ORG_ID = p_local_org_id;

	ELSIF (p_type = 'LOCALIZED') THEN

        UPDATE OKC_ARTICLE_ADOPTIONS
            SET
                ADOPTION_TYPE               = nvl(p_adoption_type, ADOPTION_TYPE),
                ADOPTION_STATUS             = nvl(p_adoption_status, ADOPTION_STATUS),
                OBJECT_VERSION_NUMBER       = OBJECT_VERSION_NUMBER + 1,
                LAST_UPDATED_BY             = G_USER_ID,
                LAST_UPDATE_LOGIN           = G_LOGIN_ID,
                LAST_UPDATE_DATE            = l_date
            WHERE
                LOCAL_ARTICLE_VERSION_ID IN
                (SELECT article_version_id FROM OKC_ART_BLK_TEMP
                        WHERE id = p_id AND adopt_asis_yn = 'N' AND localized_yn = 'Y')
                AND LOCAL_ORG_ID = p_local_org_id;

    ELSE
        -- p_type not recognized
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MESSAGE.set_name(G_APP_NAME, G_OKC_MSG_INVALID_ARGUMENT);
        FND_MESSAGE.set_token('ARG_NAME', 'p_type');
        FND_MESSAGE.set_token('ARG_VALUE', p_type);
        FND_MSG_PUB.add;
        RAISE FND_API.G_EXC_ERROR;

    END IF;

    IF (l_debug = 'Y') THEN
        okc_debug.log('200: Leaving update_adp_status_type_blk: Success');
    END IF;

EXCEPTION

	WHEN FND_API.G_EXC_ERROR THEN
		x_return_status := FND_API.G_RET_STS_ERROR;
        IF (l_debug = 'Y') THEN
            okc_debug.log('201: Leaving update_adp_status_type_blk: Error');
        END IF;

	WHEN OTHERS THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (l_debug = 'Y') THEN
            okc_debug.log('202: Leaving update_adp_status_type_blk: Unknown Error');
        END IF;

        IF 	FND_MSG_PUB.check_msg_level(fnd_msg_pub.G_MSG_LVL_UNEXP_ERROR) THEN
			FND_MSG_PUB.add_exc_msg(G_PKG_NAME ,l_api_name );
		END IF;

END update_adp_status_type_blk;

-----------------------------------------------------------------------------

PROCEDURE update_prev_vers_enddate_blk(
	p_id				    IN	NUMBER ,
  	x_return_status			OUT	NOCOPY VARCHAR2 )

IS
    l_api_name			CONSTANT VARCHAR2(30) := 'update_prev_vers_enddate_blk';

    --determine all previous versions that have a null end date
    CURSOR l_prev_ver_csr(cp_id IN NUMBER) IS
        SELECT PREV.article_version_id, TMP.start_date
        FROM OKC_ART_BLK_TEMP TMP,
            OKC_ARTICLE_VERSIONS PREV
        WHERE TMP.id = cp_id AND
            TMP.adopt_asis_yn = 'N' AND
            PREV.article_id = TMP.article_id AND
            PREV.article_version_id <> TMP.article_version_id AND
            PREV.start_date = (SELECT max(VER.start_date)
                                FROM OKC_ARTICLE_VERSIONS VER
                                WHERE VER.article_id = TMP.article_id AND
                                    VER.article_version_id <> TMP.article_version_id)
            AND PREV.end_date IS NULL;

    l_prev_ver_id_tbl		num_tbl_type;
    l_start_date_tbl        date_tbl_type;
    l_found				    BOOLEAN := FALSE;
    l_date                  DATE := sysdate;
    l_one_sec               NUMBER := 1/86400; -- expressed as a part of a day, 24*60*60

BEGIN

    IF (l_debug = 'Y') THEN
        okc_debug.log('100: Entering update_prev_vers_enddate_blk: p_id='||p_id);
    END IF;

	x_return_status := FND_API.G_RET_STS_SUCCESS;

	OPEN l_prev_ver_csr(p_id);
	FETCH l_prev_ver_csr BULK COLLECT INTO l_prev_ver_id_tbl, l_start_date_tbl;

	IF (l_prev_ver_id_tbl.COUNT > 0) THEN
		l_found := TRUE;
	END IF;
	CLOSE l_prev_ver_csr;

	IF l_found THEN
		FORALL i IN l_prev_ver_id_tbl.FIRST..l_prev_ver_id_tbl.LAST
			UPDATE OKC_ARTICLE_VERSIONS
			SET
				END_DATE = l_start_date_tbl(i) - l_one_sec,
				OBJECT_VERSION_NUMBER	= OBJECT_VERSION_NUMBER + 1,
				LAST_UPDATED_BY			= G_USER_ID,
				LAST_UPDATE_LOGIN		= G_LOGIN_ID,
				LAST_UPDATE_DATE		= l_date
			WHERE
				ARTICLE_VERSION_ID = l_prev_ver_id_tbl(i);
	END IF;

	l_prev_ver_id_tbl.DELETE;
	l_start_date_tbl.DELETE;

    IF (l_debug = 'Y') THEN
        okc_debug.log('200: Leaving update_prev_vers_enddate_blk: Success');
    END IF;

EXCEPTION

	WHEN OTHERS THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (l_prev_ver_csr%ISOPEN) THEN
            CLOSE l_prev_ver_csr;
        END IF;
        IF (l_debug = 'Y') THEN
            okc_debug.log('201: Leaving update_prev_vers_enddate_blk: Unknown Error');
        END IF;

        IF 	FND_MSG_PUB.check_msg_level(fnd_msg_pub.G_MSG_LVL_UNEXP_ERROR) THEN
			FND_MSG_PUB.add_exc_msg(G_PKG_NAME ,l_api_name );
		END IF;

END update_prev_vers_enddate_blk;

----------------------------------------------------------------------------

--
-- p_id     OKC_ART_BLK_TEMP table is populated with a number of rows containing
--          global article version ids, global article ids and the corresponding
--          local org ids for which the relationships need to be adopted.
--          p_id identifies these rows.
--
-- relationship will be adopted
--		1. from the relation ship table,
--			if src_article_id = input article_id, the target must be ADOPTED for the local org
--			if target_article_id = input article_id, the src must be ADOPTED for the local org
--		2. the relationship has not previously been adopted
--
PROCEDURE adopt_relationships_blk(
	p_id        			IN	NUMBER,
	x_return_status			OUT	NOCOPY VARCHAR2	)
IS

    l_api_name			CONSTANT VARCHAR2(30) := 'adopt_relationships_blk';
    l_date              DATE    := sysdate;

BEGIN

    IF (l_debug = 'Y') THEN
        okc_debug.log('100: Entering adopt_relationships_blk: p_id='||p_id);
    END IF;
   	x_return_status := FND_API.G_RET_STS_SUCCESS;

	INSERT INTO OKC_ARTICLE_RELATNS_ALL
    (
        SOURCE_ARTICLE_ID,
        TARGET_ARTICLE_ID,
        ORG_ID,
        RELATIONSHIP_TYPE,
        OBJECT_VERSION_NUMBER,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_LOGIN,
        LAST_UPDATE_DATE
    )
	SELECT REL.source_article_id,
        REL.target_article_id,
        TMP.org_id,
        REL.relationship_type,
        1.0,
        G_USER_ID,
        l_date,
        G_USER_ID,
        G_LOGIN_ID,
        l_date
		FROM OKC_ART_BLK_TEMP TMP, OKC_ARTICLE_RELATNS_ALL REL
		WHERE TMP.id = p_id AND
            REL.org_id = G_GLOBAL_ORG_ID AND
            REL.source_article_id = TMP.article_id AND
			EXISTS
				(SELECT 1 FROM OKC_ARTICLE_VERSIONS AV1, OKC_ARTICLE_ADOPTIONS ADP
					WHERE AV1.article_id = REL.target_article_id AND
					ADP.global_article_version_id = AV1.article_version_id AND
					ADP.local_org_id = TMP.org_id AND
					ADP.adoption_type = 'ADOPTED')
			AND NOT EXISTS
				(SELECT 1 FROM OKC_ARTICLE_RELATNS_ALL ARL1
                      WHERE REL.source_article_id = ARL1.source_article_id AND
                      REL.target_article_id = ARL1.target_article_id AND
                      REL.relationship_type = ARL1.relationship_type AND
                      ARL1.org_id = TMP.org_id);

	INSERT INTO OKC_ARTICLE_RELATNS_ALL
    (
        SOURCE_ARTICLE_ID,
        TARGET_ARTICLE_ID,
        ORG_ID,
        RELATIONSHIP_TYPE,
        OBJECT_VERSION_NUMBER,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_LOGIN,
        LAST_UPDATE_DATE
    )
	SELECT REL.source_article_id,
        REL.target_article_id,
        TMP.org_id,
        REL.relationship_type,
        1.0,
        G_USER_ID,
        l_date,
        G_USER_ID,
        G_LOGIN_ID,
        l_date
		FROM OKC_ART_BLK_TEMP TMP, OKC_ARTICLE_RELATNS_ALL REL
		WHERE TMP.id = p_id AND
            REL.org_id = G_GLOBAL_ORG_ID AND
            REL.target_article_id = TMP.article_id AND
			EXISTS
				(SELECT 1 FROM OKC_ARTICLE_VERSIONS AV1, OKC_ARTICLE_ADOPTIONS ADP
					WHERE AV1.article_id = REL.source_article_id AND
					ADP.global_article_version_id = AV1.article_version_id AND
					ADP.local_org_id = TMP.org_id AND
					ADP.adoption_type = 'ADOPTED')
			AND NOT EXISTS
				(SELECT 1 FROM OKC_ARTICLE_RELATNS_ALL ARL1
                      WHERE REL.source_article_id = ARL1.source_article_id AND
                      REL.target_article_id = ARL1.target_article_id AND
                      REL.relationship_type = ARL1.relationship_type AND
                      ARL1.org_id = TMP.org_id);


    IF (l_debug = 'Y') THEN
        okc_debug.log('200: Leaving adopt_relationships_blk: Success');
    END IF;

EXCEPTION

	WHEN OTHERS THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        IF (l_debug = 'Y') THEN
            okc_debug.log('201: Leaving adopt_relationships_blk: Unknown Error');
        END IF;

		IF 	fnd_msg_pub.check_msg_level(fnd_msg_pub.G_MSG_LVL_UNEXP_ERROR)
		THEN
			fnd_msg_pub.add_exc_msg(G_PKG_NAME ,l_api_name );
		END IF;
END adopt_relationships_blk;

-----------------------------------------------------------------------------

PROCEDURE delete_relationships_blk(
	p_id				    IN	NUMBER ,
    p_org_id                IN  NUMBER,
	x_return_status			OUT	NOCOPY VARCHAR2 )
IS

    l_api_name			CONSTANT VARCHAR2(30) := 'delete_relationships_blk';

    l_art_id_tbl		num_tbl_type;
    l_art_ver_id_tbl    num_tbl_type;
    l_found		        BOOLEAN := FALSE;

-- select only those article versions that are being adopted as is
CURSOR l_art_id_csr(cp_id IN NUMBER) IS
	SELECT article_id, article_version_id
    	FROM OKC_ART_BLK_TEMP TMP
	    WHERE	TMP.id = cp_id AND TMP.adopt_asis_yn = 'Y';

BEGIN

    IF (l_debug = 'Y') THEN
        okc_debug.log('100: Entering delete_relationships_blk: p_id='||p_id||' p_org_id='||p_org_id);
    END IF;

	x_return_status := FND_API.G_RET_STS_SUCCESS;

	-- get the article id's first, makes the NOT EXISTS clause in Delete below, less costly
	OPEN l_art_id_csr(p_id);
	FETCH l_art_id_csr BULK COLLECT INTO l_art_id_tbl,l_art_ver_id_tbl;

	IF (l_art_id_tbl.COUNT > 0) THEN
		l_found := TRUE;
	END IF;

	CLOSE l_art_id_csr;


	IF (NOT l_found) THEN
		RETURN;
	END IF;

	-- delete where source article has not been adopted
   	FORALL i IN l_art_id_tbl.FIRST..l_art_id_tbl.LAST
    	DELETE FROM OKC_ARTICLE_RELATNS_ALL
		WHERE	org_id = p_org_id
		AND source_article_id = l_art_id_tbl(i)
		AND NOT EXISTS
			( SELECT 1 FROM OKC_ARTICLE_ADOPTIONS ADP, OKC_ARTICLE_VERSIONS AV1
				WHERE AV1.article_id = l_art_id_tbl(i)
				AND AV1.article_version_id <> l_art_ver_id_tbl(i)
				AND ADP.adoption_type = 'ADOPTED'
				AND ADP.global_article_version_id = AV1.article_version_id
                AND ADP.local_org_id = p_org_id
			);

	-- delete where target article has not been adopted
	FORALL i IN l_art_id_tbl.FIRST..l_art_id_tbl.LAST
		DELETE FROM OKC_ARTICLE_RELATNS_ALL
		WHERE	org_id = p_org_id
		AND target_article_id = l_art_id_tbl(i)
		AND NOT EXISTS
			( SELECT 1 FROM OKC_ARTICLE_ADOPTIONS ADP, OKC_ARTICLE_VERSIONS AV2
				WHERE AV2.article_id = l_art_id_tbl(i)
				AND AV2.article_version_id <> l_art_ver_id_tbl(i)
				AND ADP.adoption_type = 'ADOPTED'
				AND ADP.global_article_version_id = AV2.article_version_id
                AND ADP.local_org_id = p_org_id
			);

	l_art_id_tbl.DELETE;
    l_art_ver_id_tbl.DELETE;

    IF (l_debug = 'Y') THEN
        okc_debug.log('200: Leaving delete_relationships_blk: Success');
    END IF;

EXCEPTION

	WHEN OTHERS THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		IF (l_art_id_csr%ISOPEN) THEN
			CLOSE l_art_id_csr;
		END IF;

        IF (l_debug = 'Y') THEN
            okc_debug.log('201: Leaving delete_relationships_blk: Unknown error');
        END IF;

		IF 	fnd_msg_pub.check_msg_level(fnd_msg_pub.G_MSG_LVL_UNEXP_ERROR) THEN
			fnd_msg_pub.add_exc_msg(G_PKG_NAME ,l_api_name );
		END IF;

END delete_relationships_blk;

---------------------------------------------------------------------

PROCEDURE validate_article_versions_blk(
	p_api_version			IN	NUMBER ,
  	p_init_msg_list			IN	VARCHAR2 ,
	p_commit				IN	VARCHAR2 ,
	p_validation_level		IN	NUMBER ,
	x_return_status			OUT	NOCOPY VARCHAR2 ,
	x_msg_count				OUT	NOCOPY NUMBER ,
	x_msg_data				OUT	NOCOPY VARCHAR2 ,

	p_org_id				IN	NUMBER ,
	p_art_ver_tbl			IN	num_tbl_type ,
    p_id                    IN  NUMBER,
    x_qa_return_status      OUT NOCOPY VARCHAR2,
	x_validation_results	OUT	NOCOPY validation_tbl_type )

IS

    l_api_version			NUMBER := 1.0;
    l_api_name				VARCHAR2(30) := 'validate_article_versions_blk';

    l_id                    NUMBER;
    l_return_status         VARCHAR2(1);
    l_qa_return_status      VARCHAR2(1);


    l_adopt_asis_art_id_tbl		    num_tbl_type;
    l_adopt_asis_art_ver_id_tbl	    num_tbl_type;
    l_adopt_asis_art_title_tbl	    varchar_tbl_type;

    l_curr_msg_count			NUMBER;
    l_local_result_status		VARCHAR2(1);
    l_msg_count					NUMBER;
    l_msg_data					VARCHAR2(2000);
    l_earlier_local_version_id	VARCHAR2(250);

    l_err_num					NUMBER;
    i							NUMBER;

    l_adopt_asis_count          NUMBER := 0;
    l_global_count              NUMBER := 0;
    l_localized_count           NUMBER := 0;

    -- get some details about adopt as is articles for filling the x_validation_results table
    CURSOR l_adopt_as_is_csr(cp_id IN NUMBER) IS
        SELECT TMP.article_id,  TMP.article_version_id, nvl(TMP.display_name, TMP.article_title)
        FROM OKC_ART_BLK_TEMP TMP
        WHERE TMP.id = cp_id AND
            TMP.adopt_asis_yn = 'Y';


 BEGIN

    IF (l_debug = 'Y') THEN
        okc_debug.log('100: Entering validate_article_versions_blk: p_api_version='||p_api_version||' p_init_msg_list='||p_init_msg_list||' p_commit='||p_commit);

        okc_debug.log('101: In validate_article_versions_blk: p_validation_level='|| p_validation_level||' p_org_id='||p_org_id||' p_id='||p_id);

        IF (p_art_ver_tbl IS NOT NULL) THEN
            okc_debug.log('102: p_art_ver_tbl.COUNT='||p_art_ver_tbl.COUNT);
            FOR i in p_art_ver_tbl.FIRST..p_art_ver_tbl.LAST LOOP
                 okc_debug.log('103: p_art_ver_tbl['||i||']='||p_art_ver_tbl(i));
            END LOOP;
        END IF;
	END IF;

	-- standard initialization code
	SAVEPOINT val_article_versions_blk_PVT;
    G_GLOBAL_ORG_ID	    := NVL(FND_PROFILE.VALUE('OKC_GLOBAL_ORG_ID'),-99);
    l_debug             := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

	IF NOT fnd_api.compatible_api_call( l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;
	IF fnd_api.to_boolean( p_init_msg_list ) THEN
		fnd_msg_pub.initialize;
	END IF;
	x_return_status := FND_API.G_RET_STS_SUCCESS;
    x_qa_return_status := FND_API.G_RET_STS_SUCCESS;

    l_return_status := FND_API.G_RET_STS_SUCCESS;
    l_qa_return_status := FND_API.G_RET_STS_SUCCESS;

	IF (p_validation_level <> FND_API.G_VALID_LEVEL_FULL) THEN
		RETURN;
	END IF;

    IF (p_id IS NULL) THEN
        -- get the versions details only if p_id is not set
        get_version_details(
                            p_org_id				=> p_org_id,
                            p_art_ver_tbl			=> p_art_ver_tbl,
                            x_return_status			=> x_return_status,
                            x_id		            => l_id,
                            x_adopt_asis_count      => l_adopt_asis_count,
                            x_global_count          => l_global_count,
                            x_localized_count       => l_localized_count
                            );
        IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
            RAISE FND_API.G_EXC_ERROR ;
        ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
        END IF;
    ELSE
        l_id := p_id;
    END IF;

    variable_check_blk(
                p_id                    => l_id,
                x_return_status			=> x_return_status,
                x_qa_return_status		=> x_qa_return_status,
                px_validation_results	=> x_validation_results
                );
    IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
        RAISE FND_API.G_EXC_ERROR ;
    ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    END IF;

    section_type_check_blk(
                p_id                    => l_id,
                x_return_status			=> x_return_status,
                x_qa_return_status		=> x_qa_return_status,
                px_validation_results	=> x_validation_results
                );
    IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
        RAISE FND_API.G_EXC_ERROR ;
    ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    END IF;

    IF(p_org_id <> G_GLOBAL_ORG_ID) THEN

        l_adopt_asis_art_id_tbl		:= num_tbl_type();
        l_adopt_asis_art_ver_id_tbl := num_tbl_type();
        --l_adopt_asis_art_title_tbl	:= varchar_tbl_type();

        -- check adopt as is articles using existing code
        OPEN l_adopt_as_is_csr(l_id);
		FETCH l_adopt_as_is_csr BULK COLLECT INTO l_adopt_asis_art_id_tbl, l_adopt_asis_art_ver_id_tbl, l_adopt_asis_art_title_tbl;
		CLOSE l_adopt_as_is_csr;

		IF (l_adopt_asis_art_id_tbl.COUNT > 0) THEN

			-- check adopt_as_is articles for adoption details
			i := l_adopt_asis_art_id_tbl.FIRST;

			WHILE i is NOT NULL LOOP

				-- reset all loop variables
				-- get the current message count, only new messages should be fetched and
				-- put in the x_validation_results table;

				l_curr_msg_count := fnd_msg_pub.count_msg;
				l_local_result_status := FND_API.G_RET_STS_SUCCESS;
				l_msg_count := 0;
				l_msg_data  := 0;
				l_earlier_local_version_id := 0;

                IF (l_debug = 'Y') THEN
                    okc_debug.log('104: Calling OKC_ADOPTIONS_GRP.check_adoption_details p_global_article_version_id='||l_adopt_asis_art_ver_id_tbl(i)|| ' p_adoption_type=ADOPTED p_local_org_id='||p_org_id);
                END IF;

				OKC_ADOPTIONS_GRP.check_adoption_details(
						p_api_version                  => 1.0,
						p_init_msg_list                => FND_API.G_FALSE,
						p_validation_level             => FND_API.G_VALID_LEVEL_FULL,
						x_return_status                => l_local_result_status ,
						x_msg_count                    => l_msg_count,
						x_msg_data                     => l_msg_data,
						x_earlier_local_version_id     => l_earlier_local_version_id,
						p_global_article_version_id    => l_adopt_asis_art_ver_id_tbl(i),
						p_adoption_type                => 'ADOPTED',
						p_local_org_id                 => p_org_id
				);

                IF (l_debug = 'Y') THEN
                    okc_debug.log('105: After OKC_ADOPTIONS_GRP.check_adoption_details x_return_status='||l_local_result_status);
                END IF;

				IF (l_local_result_status = FND_API.G_RET_STS_ERROR) THEN -- the check failed
					x_qa_return_status := FND_API.G_RET_STS_ERROR;

					FOR j in 1..(l_msg_count - l_curr_msg_count) LOOP
						l_err_num := x_validation_results.COUNT +1;
						x_validation_results(l_err_num).article_id			:= l_adopt_asis_art_id_tbl(i);
						x_validation_results(l_err_num).article_version_id	:= l_adopt_asis_art_ver_id_tbl(i);
						x_validation_results(l_err_num).article_title		:= l_adopt_asis_art_title_tbl(i);
						x_validation_results(l_err_num).error_code			:= G_CHK_INVALID_ADOPTION;
						-- get the new messages
						x_validation_results(l_err_num).error_message		:= fnd_msg_pub.get(p_msg_index => l_curr_msg_count +j, p_encoded => 'F');
					END LOOP;

				ELSIF (l_local_result_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
					-- for unexpected error get the error messages, put a different code
                    -- and try to validate the next version

					x_qa_return_status := FND_API.G_RET_STS_ERROR;

					FOR j in 1..(l_msg_count - l_curr_msg_count) LOOP
						l_err_num := x_validation_results.COUNT +1;
						x_validation_results(l_err_num).article_id			:= l_adopt_asis_art_id_tbl(i);
						x_validation_results(l_err_num).article_version_id	:= l_adopt_asis_art_ver_id_tbl(i);
						x_validation_results(l_err_num).article_title		:= l_adopt_asis_art_title_tbl(i);
						x_validation_results(l_err_num).error_code			:= G_CHK_ADOPTION_UNEXP_ERROR;
						-- get the new messages
						x_validation_results(l_err_num).error_message		:= fnd_msg_pub.get(p_msg_index => l_curr_msg_count +j, p_encoded => 'F');
					END LOOP;

				END IF;

				i := l_adopt_asis_art_id_tbl.NEXT(i);

			END LOOP;

		END IF; -- of IF (l_adopt_asis_art_id_tbl.COUNT > 0) THEN

        l_adopt_asis_art_id_tbl.DELETE;
        l_adopt_asis_art_ver_id_tbl.DELETE;
	    l_adopt_asis_art_title_tbl.DELETE;

	END IF; --of IF(p_org_id <> G_GLOBAL_ORG_ID) THEN


	-- if any errors are found set the appropriate return status
	IF (x_validation_results.COUNT >0 ) THEN
		x_qa_return_status := FND_API.G_RET_STS_ERROR;
	END IF;

	fnd_msg_pub.count_and_get( p_count => x_msg_count , p_data 	=> x_msg_data);
	IF fnd_api.to_boolean( p_commit ) THEN
		COMMIT WORK;
	END IF;

    IF (l_debug = 'Y') THEN
        okc_debug.log('200: Leaving validate_article_versions_blk: Success');
    END IF;


EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        ROLLBACK TO val_article_versions_blk_PVT;
        x_return_status := FND_API.G_RET_STS_ERROR ;

        IF (l_debug = 'Y') THEN
            okc_debug.log('201: Leaving validate_article_versions_blk: Error');
        END IF;

        IF (l_adopt_as_is_csr%ISOPEN) THEN
			CLOSE l_adopt_as_is_csr;
		END IF;
		fnd_msg_pub.count_and_get( p_count => x_msg_count , p_data 	=> x_msg_data);

	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        ROLLBACK TO val_article_versions_blk_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF (l_debug = 'Y') THEN
            okc_debug.log('202: Leaving validate_article_versions_blk: Unexpected Error');
        END IF;

        IF (l_adopt_as_is_csr%ISOPEN) THEN
			CLOSE l_adopt_as_is_csr;
		END IF;
		fnd_msg_pub.count_and_get( p_count => x_msg_count , p_data 	=> x_msg_data);

	WHEN OTHERS THEN

        ROLLBACK TO val_article_versions_blk_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF (l_debug = 'Y') THEN
            okc_debug.log('203: Leaving validate_article_versions_blk: Unknown Error');
        END IF;

        IF (l_adopt_as_is_csr%ISOPEN) THEN
			CLOSE l_adopt_as_is_csr;
		END IF;

		IF 	fnd_msg_pub.check_msg_level(fnd_msg_pub.G_MSG_LVL_UNEXP_ERROR)
		THEN
			fnd_msg_pub.add_exc_msg(G_PKG_NAME ,l_api_name );
		END IF;
		fnd_msg_pub.count_and_get( p_count => x_msg_count , p_data 	=> x_msg_data);

END validate_article_versions_blk;

-----------------------------------------------------------------------------

PROCEDURE auto_adopt_articles_blk(
	p_api_version			IN	NUMBER ,
  	p_init_msg_list			IN	VARCHAR2 ,
	p_commit				IN	VARCHAR2 ,
	x_return_status			OUT	NOCOPY VARCHAR2 ,
	x_msg_count				OUT	NOCOPY NUMBER ,
	x_msg_data				OUT	NOCOPY VARCHAR2 ,

	p_id        			IN	NUMBER)

IS

    l_api_version			NUMBER := 1.0;
    l_api_name				VARCHAR2(30) := 'auto_adopt_articles_blk';
    l_date                  DATE := sysdate;

    CURSOR l_org_info_csr(cp_global_org_id IN NUMBER) IS
        SELECT ORG.organization_id, decode(ORG.org_information1, 'Y', 'ADOPTED', 'AVAILABLE')
        FROM HR_ORGANIZATION_INFORMATION ORG
        WHERE ORG.org_information_context = 'OKC_TERMS_LIBRARY_DETAILS' AND
            ORG.organization_id <> cp_global_org_id;

    CURSOR l_non_uniq_title_csr(cp_id IN NUMBER, cp_global_org_id IN NUMBER) IS
        -- check if article title is unique for the local org also
        -- if  title is not unique in the local org, set to 'AVAILABLE' and NULL
        SELECT TMP.article_version_id , ART.org_id
        FROM OKC_ART_BLK_TEMP TMP, OKC_ARTICLES_ALL ART
        WHERE TMP.id = cp_id AND
            TMP.global_yn = 'Y' AND
            ART.article_title = TMP.article_title AND
            ART.org_id <> cp_global_org_id ;

    l_org_id_tbl                num_tbl_type;
    l_adp_typ_tbl               varchar_tbl_type;
    l_non_uniq_art_ver_tbl		num_tbl_type;
    l_non_uniq_org_id_tbl		num_tbl_type;

    l_found			            BOOLEAN := FALSE;
    l_id                        NUMBER;

BEGIN

    IF (l_debug = 'Y') THEN
        okc_debug.log('100: Entering auto_adopt_articles_blk: p_api_version='||p_api_version||' p_init_msg_list='||p_init_msg_list||' p_commit='||p_commit||' p_id='||p_id);
	END IF;

	-- standard initialization code
	SAVEPOINT auto_adopt_articles_blk_PVT;
    G_GLOBAL_ORG_ID	    := NVL(FND_PROFILE.VALUE('OKC_GLOBAL_ORG_ID'),-99);
    G_USER_ID           := FND_GLOBAL.USER_ID;
    G_LOGIN_ID          := FND_GLOBAL.LOGIN_ID;
    l_debug             := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

	IF NOT fnd_api.compatible_api_call( l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;
	IF fnd_api.to_boolean( p_init_msg_list ) THEN
		fnd_msg_pub.initialize;
	END IF;
	x_return_status := FND_API.G_RET_STS_SUCCESS;

   	OPEN l_org_info_csr(G_GLOBAL_ORG_ID);
	FETCH l_org_info_csr BULK COLLECT INTO l_org_id_tbl, l_adp_typ_tbl;

	IF (l_org_id_tbl.COUNT > 0) THEN
		l_found := TRUE;
	END IF;
	CLOSE l_org_info_csr;

    IF NOT l_found THEN
        -- no local orgs found
        RETURN;
    END IF;

	-- first insert rows in adoptions table for each clause and local org
	FORALL i IN l_org_id_tbl.FIRST.. l_org_id_tbl.LAST
		INSERT INTO OKC_ARTICLE_ADOPTIONS
			(
			GLOBAL_ARTICLE_VERSION_ID,
			ADOPTION_TYPE,
			LOCAL_ORG_ID,
			ADOPTION_STATUS,
			LOCAL_ARTICLE_VERSION_ID,
			OBJECT_VERSION_NUMBER,
			CREATED_BY,
			CREATION_DATE,
			LAST_UPDATED_BY,
			LAST_UPDATE_LOGIN,
			LAST_UPDATE_DATE
			)
			SELECT TMP.article_version_id, l_adp_typ_tbl(i), l_org_id_tbl(i),
                decode(l_adp_typ_tbl(i), 'ADOPTED', 'APPROVED', NULL),
				NULL, 1, G_USER_ID, l_date,
				G_USER_ID, G_LOGIN_ID, l_date
			FROM OKC_ART_BLK_TEMP TMP
			WHERE TMP.id = p_id AND
                TMP.global_yn = 'Y';

	-- now for local orgs, check if any clauses
	-- with the same title existed
	OPEN l_non_uniq_title_csr(p_id, G_GLOBAL_ORG_ID);
	FETCH l_non_uniq_title_csr BULK COLLECT INTO l_non_uniq_art_ver_tbl, l_non_uniq_org_id_tbl;

    l_found := FALSE;
	IF (l_non_uniq_art_ver_tbl.COUNT > 0) THEN
		l_found := TRUE;
	END IF;
	CLOSE l_non_uniq_title_csr;

	IF (l_found) THEN
		-- need to update adoption type to 'AVAILABLE', status to NULL

		FORALL i IN l_non_uniq_art_ver_tbl.FIRST..l_non_uniq_art_ver_tbl.LAST
			UPDATE OKC_ARTICLE_ADOPTIONS
			SET
				ADOPTION_TYPE = 'AVAILABLE',
				ADOPTION_STATUS = NULL
			WHERE
			GLOBAL_ARTICLE_VERSION_ID = l_non_uniq_art_ver_tbl(i)
			AND LOCAL_ORG_ID =  l_non_uniq_org_id_tbl(i);

	END IF; -- end of if (l_found)


    -- now adopt relationship for those article versions/local orgs
	-- where adoption_type = 'ADOPTED'
    l_id := get_uniq_id;
    INSERT INTO OKC_ART_BLK_TEMP
        (
        ID,
        ARTICLE_ID,
        ARTICLE_VERSION_ID,
        ORG_ID
        )
        SELECT l_id, TMP.article_id, TMP.article_version_id, ADP.local_org_id
        FROM OKC_ART_BLK_TEMP TMP, OKC_ARTICLE_ADOPTIONS ADP
        WHERE TMP.id = p_id AND
            TMP.global_yn = 'Y' AND
            ADP.global_article_version_id = TMP.article_version_id AND
            ADP.adoption_type = 'ADOPTED';

    adopt_relationships_blk(
        p_id	        => l_id,
        x_return_status	=> x_return_status
        );
    IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
        RAISE FND_API.G_EXC_ERROR ;
    ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    END IF;

    l_non_uniq_art_ver_tbl.DELETE;
	l_non_uniq_org_id_tbl.DELETE;

	l_org_id_tbl.DELETE;
	l_adp_typ_tbl.DELETE;

	fnd_msg_pub.count_and_get( p_count => x_msg_count , p_data 	=> x_msg_data);
	IF fnd_api.to_boolean( p_commit ) THEN
		COMMIT;
	END IF;

    IF (l_debug = 'Y') THEN
        okc_debug.log('200: Leaving auto_adopt_articles_blk: Success');
	END IF;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
		ROLLBACK TO auto_adopt_articles_blk_PVT;
        x_return_status := FND_API.G_RET_STS_ERROR ;

        IF (l_debug = 'Y') THEN
            okc_debug.log('201: Leaving auto_adopt_articles_blk: Error');
	    END IF;
        IF (l_org_info_csr%ISOPEN) THEN
			CLOSE l_org_info_csr;
		END IF;
        IF (l_non_uniq_title_csr%ISOPEN) THEN
			CLOSE l_non_uniq_title_csr;
		END IF;
        fnd_msg_pub.count_and_get( p_count => x_msg_count , p_data 	=> x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		ROLLBACK TO auto_adopt_articles_blk_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF (l_debug = 'Y') THEN
            okc_debug.log('202: Leaving auto_adopt_articles_blk: Unexpected Error');
	    END IF;
        IF (l_org_info_csr%ISOPEN) THEN
			CLOSE l_org_info_csr;
		END IF;
        IF (l_non_uniq_title_csr%ISOPEN) THEN
			CLOSE l_non_uniq_title_csr;
		END IF;
        fnd_msg_pub.count_and_get( p_count => x_msg_count , p_data 	=> x_msg_data);

	WHEN OTHERS THEN
		ROLLBACK TO auto_adopt_articles_blk_PVT;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF (l_debug = 'Y') THEN
            okc_debug.log('203: Leaving auto_adopt_articles_blk: Unknown Error');
	    END IF;
        IF (l_org_info_csr%ISOPEN) THEN
			CLOSE l_org_info_csr;
		END IF;
        IF (l_non_uniq_title_csr%ISOPEN) THEN
			CLOSE l_non_uniq_title_csr;
		END IF;

        IF 	fnd_msg_pub.check_msg_level(fnd_msg_pub.G_MSG_LVL_UNEXP_ERROR)
		THEN
			fnd_msg_pub.add_exc_msg(G_PKG_NAME ,l_api_name );
		END IF;
		fnd_msg_pub.count_and_get( p_count => x_msg_count , p_data 	=> x_msg_data);

END auto_adopt_articles_blk;

-----------------------------------------------------------------------------


-- IF (p_validation_level = FND_API.G_VALID_LEVEL_FULL) THEN do validations

PROCEDURE pending_approval_blk(
	p_api_version			IN	NUMBER ,
  	p_init_msg_list			IN	VARCHAR2 ,
	p_commit				IN	VARCHAR2 ,
	p_validation_level		IN	NUMBER ,
	x_return_status			OUT	NOCOPY VARCHAR2 ,
	x_msg_count				OUT	NOCOPY NUMBER ,
	x_msg_data				OUT	NOCOPY VARCHAR2 ,

	p_org_id				IN	NUMBER ,
	p_art_ver_tbl			IN	num_tbl_type ,
	x_validation_results	OUT	NOCOPY validation_tbl_type )
IS

    l_api_version			    NUMBER := 1.0;
    l_api_name				    VARCHAR2(30) := 'pending_approval_blk';

    l_qa_return_status          VARCHAR2(1);
    l_id                        NUMBER := -1;
    l_rel_id                    NUMBER := -1;

    l_adopt_asis_count          NUMBER := 0;
    l_global_count              NUMBER := 0;
    l_localized_count           NUMBER := 0;

BEGIN

    IF (l_debug = 'Y') THEN
        okc_debug.log('100: Entering pending_approval_blk: p_api_version='||p_api_version||' p_init_msg_list='||p_init_msg_list||' p_commit='||p_commit);

        okc_debug.log('101: In pending_approval_blk: p_validation_level='|| p_validation_level||' p_org_id='||p_org_id);

        IF (p_art_ver_tbl IS NOT NULL) THEN
            okc_debug.log('102: p_art_ver_tbl.COUNT='||p_art_ver_tbl.COUNT);
            FOR i in p_art_ver_tbl.FIRST..p_art_ver_tbl.LAST LOOP
                 okc_debug.log('103: p_art_ver_tbl['||i||']='||p_art_ver_tbl(i));
            END LOOP;
        END IF;
	END IF;

	-- standard initialization code
	SAVEPOINT pending_approval_blk_PVT;
    G_GLOBAL_ORG_ID	    := NVL(FND_PROFILE.VALUE('OKC_GLOBAL_ORG_ID'),-99);
    G_USER_ID           := FND_GLOBAL.USER_ID;
    G_LOGIN_ID          := FND_GLOBAL.LOGIN_ID;
    l_debug             := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

	IF NOT fnd_api.compatible_api_call( l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;
	IF fnd_api.to_boolean( p_init_msg_list ) THEN
		fnd_msg_pub.initialize;
	END IF;
	x_return_status := FND_API.G_RET_STS_SUCCESS;


    -- first populate the the temp table with all the relevant details
    get_version_details(
        p_org_id				=> p_org_id,
        p_art_ver_tbl			=> p_art_ver_tbl,
        x_return_status			=> x_return_status,
        x_id                    => l_id,
        x_adopt_asis_count      => l_adopt_asis_count,
        x_global_count          => l_global_count,
        x_localized_count       => l_localized_count
        );
    IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
        RAISE FND_API.G_EXC_ERROR ;
    ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    END IF;

	-- check if all versions are in draft/rejected/null status first
	-- this is not part of normal qa, but a basic sanity check required
	-- for all status transitions
    status_check_blk(
        p_id				    => l_id,
        p_to_status				=> 'PENDING_APPROVAL',
        x_return_status			=> x_return_status,
        x_qa_return_status      => l_qa_return_status,
        px_validation_results	=> x_validation_results
        );
    IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
        RAISE FND_API.G_EXC_ERROR ;
    ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    ELSE
        -- status check failed
        IF (l_qa_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
            RAISE FND_API.G_EXC_ERROR ;
        END IF;
    END IF;

	IF (p_validation_level = FND_API.G_VALID_LEVEL_FULL) THEN

		validate_article_versions_blk(
			p_api_version			=> 1.0 ,
  			p_init_msg_list			=> FND_API.G_FALSE,
			p_commit				=> FND_API.G_FALSE,
			p_validation_level		=> FND_API.G_VALID_LEVEL_FULL,
			x_return_status			=> x_return_status,
			x_msg_count				=> x_msg_count,
			x_msg_data				=> x_msg_data,

			p_org_id				=> p_org_id,
            -- call with null p_art_ver_tbl so that validate_article_versions_blk
            -- does not have to get the article details again
			p_art_ver_tbl			=> NULL,
            p_id                    => l_id,
            x_qa_return_status      => l_qa_return_status,
			x_validation_results	=> x_validation_results
			);

		-- whenever call another api check for return status,
		-- no need  to check the return status for utility functions

		-- in case of ERROR, the calling program will look into x_validation_results
		-- and should display them to user for corrective action
		-- for UNEXPECTED ERROR, the calling program would set the status
		-- as G_RET_STS_UNEXP_ERROR and exit

		IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
			RAISE FND_API.G_EXC_ERROR ;
		ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
			RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
		ElSE
            -- validation executed successfully buth there where some
            -- validation errors. we should stop here
            IF (l_qa_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                x_return_status := FND_API.G_RET_STS_ERROR;
                RAISE FND_API.G_EXC_ERROR ;
            END IF;
        END IF;

	END IF; --p_validation_level = FND_API.G_VALID_LEVEL_FULL



    -- common for global/local/localized clauses, will do nothing for adopt as is clauses.
    update_art_version_status_blk(
        p_id    		=> l_id,
        p_status		=> 'PENDING_APPROVAL',
        x_return_status	=> x_return_status
        );
    IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
        RAISE FND_API.G_EXC_ERROR ;
    ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    END IF;


   	IF (p_org_id <> G_GLOBAL_ORG_ID) THEN
  	-- we are not in the global org

        -- for localized clauses only
        IF (l_localized_count > 0) THEN
            update_adp_status_type_blk(
                p_id			    => l_id,
                p_local_org_id		=> p_org_id,
                p_adoption_status	=> 'PENDING_APPROVAL',
                p_adoption_type		=> 'LOCALIZED',
                p_type              => 'LOCALIZED',
                x_return_status		=> x_return_status
                );
            IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
                RAISE FND_API.G_EXC_ERROR ;
            ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
            END IF;
        END IF;

		-- we are adopting some article versions as is.
        IF (l_adopt_asis_count > 0) THEN
	    	-- 1. Update Adoption Row
			-- 2. Insert Relationships if first version of any articles are being adopted.

            update_adp_status_type_blk(
                p_id			    => l_id,
                p_local_org_id		=> p_org_id,
                p_adoption_status	=> 'PENDING_APPROVAL',
                p_adoption_type		=> 'ADOPTED',
                p_type              => 'ADOPTED',
                x_return_status		=> x_return_status
                );
            IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
                RAISE FND_API.G_EXC_ERROR ;
            ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
            END IF;

            -- now adopt relationship for these articles
            -- first populate the temp table with whatever adopt_relationships_blk requires
            l_rel_id := get_uniq_id;
            INSERT INTO OKC_ART_BLK_TEMP
                (
                ID,
                ARTICLE_ID,
                ARTICLE_VERSION_ID,
                ORG_ID
                )
                SELECT l_rel_id, TMP.article_id, TMP.article_version_id, p_org_id
                FROM OKC_ART_BLK_TEMP TMP
                WHERE TMP.id = l_id AND
                    TMP.adopt_asis_yn = 'Y';

            adopt_relationships_blk(
                p_id	        => l_rel_id,
                x_return_status	=> x_return_status
                );
            IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
                RAISE FND_API.G_EXC_ERROR ;
            ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
            END IF;

		END IF;

	END IF; -- of IF (p_org_id <> G_GLOBAL_ORG_ID)

    -- delete rows created in the temp table
    DELETE FROM OKC_ART_BLK_TEMP
        WHERE id IN (l_id, l_rel_id);

    fnd_msg_pub.count_and_get( p_count => x_msg_count , p_data 	=> x_msg_data);
	IF(FND_API.to_boolean(p_commit)) THEN
		COMMIT;
    END IF;

    IF (l_debug = 'Y') THEN
        okc_debug.log('200: Leaving pending_approval_blk: Success');
    END IF;

EXCEPTION

	WHEN FND_API.G_EXC_ERROR THEN
		ROLLBACK TO pending_approval_blk_PVT;
		x_return_status := FND_API.G_RET_STS_ERROR ;

        IF (l_debug = 'Y') THEN
            okc_debug.log('201: Leaving pending_approval_blk: Error');
	    END IF;
		fnd_msg_pub.count_and_get( p_count => x_msg_count , p_data 	=> x_msg_data);

	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		ROLLBACK TO pending_approval_blk_PVT;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF (l_debug = 'Y') THEN
            okc_debug.log('202: Leaving pending_approval_blk: Unexpected Error');
	    END IF;

        fnd_msg_pub.count_and_get( p_count => x_msg_count , p_data 	=> x_msg_data);

	WHEN OTHERS THEN
		ROLLBACK TO pending_approval_blk_PVT;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF (l_debug = 'Y') THEN
            okc_debug.log('203: Leaving pending_approval_blk: Unknown Error');
	    END IF;

        IF 	fnd_msg_pub.check_msg_level(fnd_msg_pub.G_MSG_LVL_UNEXP_ERROR)
		THEN
			fnd_msg_pub.add_exc_msg(G_PKG_NAME ,l_api_name );
		END IF;
		fnd_msg_pub.count_and_get( p_count => x_msg_count , p_data 	=> x_msg_data);

END pending_approval_blk;

---------------------------------------------------------------------

PROCEDURE approve_blk(
	p_api_version			IN	NUMBER ,
  	p_init_msg_list			IN	VARCHAR2 ,
	p_commit				IN	VARCHAR2 ,
	x_return_status			OUT	NOCOPY VARCHAR2 ,
	x_msg_count				OUT	NOCOPY NUMBER ,
	x_msg_data				OUT	NOCOPY VARCHAR2 ,

	p_org_id				IN	NUMBER ,
	p_art_ver_tbl			IN	num_tbl_type,
	x_validation_results	OUT	NOCOPY validation_tbl_type )
IS

    l_api_version			NUMBER := 1.0;
    l_api_name				VARCHAR2(30) := 'approve_blk';

    l_qa_return_status          VARCHAR2(1);
    l_id                        NUMBER := -1;

    l_adopt_asis_count          NUMBER := 0;
    l_global_count              NUMBER := 0;
    l_localized_count           NUMBER := 0;

BEGIN

    IF (l_debug = 'Y') THEN
        okc_debug.log('100: Entering approve_blk: p_api_version='||p_api_version||' p_init_msg_list='||p_init_msg_list||' p_commit='||p_commit);

        okc_debug.log('101: In approve_blk: p_org_id='||p_org_id);

        IF (p_art_ver_tbl IS NOT NULL) THEN
            okc_debug.log('102: p_art_ver_tbl.COUNT='||p_art_ver_tbl.COUNT);
            FOR i in p_art_ver_tbl.FIRST..p_art_ver_tbl.LAST LOOP
                 okc_debug.log('103: p_art_ver_tbl['||i||']='||p_art_ver_tbl(i));
            END LOOP;
        END IF;
	END IF;

    -- standard initialization code
	SAVEPOINT approve_blk_PVT;
    G_GLOBAL_ORG_ID	    := NVL(FND_PROFILE.VALUE('OKC_GLOBAL_ORG_ID'),-99);
    G_USER_ID           := FND_GLOBAL.USER_ID;
    G_LOGIN_ID          := FND_GLOBAL.LOGIN_ID;
    l_debug             := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

	IF NOT fnd_api.compatible_api_call( l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;
	IF fnd_api.to_boolean( p_init_msg_list ) THEN
		fnd_msg_pub.initialize;
	END IF;
	x_return_status := FND_API.G_RET_STS_SUCCESS;


    -- first populate the the temp table with all the relevant details
    get_version_details(
        p_org_id				=> p_org_id,
        p_art_ver_tbl			=> p_art_ver_tbl,
        x_return_status			=> x_return_status,
        x_id                    => l_id,
        x_adopt_asis_count      => l_adopt_asis_count,
        x_global_count          => l_global_count,
        x_localized_count       => l_localized_count
        );
    IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
        RAISE FND_API.G_EXC_ERROR ;
    ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    END IF;

	-- check if all versions are in pending approval status first
	-- this is not part of normal qa, but a basic sanity check required
	-- for all status transitions
    status_check_blk(
        p_id				    => l_id,
        p_to_status				=> 'APPROVED',
        x_return_status			=> x_return_status,
        x_qa_return_status      => l_qa_return_status,
        px_validation_results	=> x_validation_results
        );
    IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
        RAISE FND_API.G_EXC_ERROR ;
    ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    ELSE
        -- status check failed
        IF (l_qa_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
            RAISE FND_API.G_EXC_ERROR ;
        END IF;
    END IF;


    -- common for global/local/localized clauses, will do nothing for adopt as is clauses.
    update_art_version_status_blk(
        p_id    		=> l_id,
        p_status		=> 'APPROVED',
        x_return_status	=> x_return_status
        );
    IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
        RAISE FND_API.G_EXC_ERROR ;
    ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    END IF;


    -- common for global/local/localized clauses, will do nothing for adopt as is clauses.
    update_prev_vers_enddate_blk(
	    p_id				    => l_id,
  	    x_return_status			=> x_return_status
        );
    IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
        RAISE FND_API.G_EXC_ERROR ;
    ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    END IF;


	IF (p_org_id = G_GLOBAL_ORG_ID) THEN

        IF (l_global_count > 0) THEN
	    -- kick off auto adoption

            auto_adopt_articles_blk(
                p_api_version	=> 1.0,
                p_init_msg_list	=> FND_API.G_FALSE,
                p_commit		=> FND_API.G_FALSE,
                x_return_status	=> x_return_status ,
                x_msg_count		=> x_msg_count ,
                x_msg_data		=> x_msg_data ,

                p_id        	=> l_id
                );
            IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
                RAISE FND_API.G_EXC_ERROR ;
            ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
            END IF;

	    END IF;

	ELSE
	-- we are not in the global org

		IF (l_adopt_asis_count > 0) THEN
		    -- we are adopting some article versions as is, so update Adoption Row

            update_adp_status_type_blk(
                p_id			    => l_id,
                p_local_org_id		=> p_org_id,
                p_adoption_status	=> 'APPROVED',
                p_adoption_type		=> 'ADOPTED',
                p_type              => 'ADOPTED',
                x_return_status		=> x_return_status
                );
            IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
                RAISE FND_API.G_EXC_ERROR ;
            ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
            END IF;

		END IF;

		IF (l_localized_count > 0) THEN
		    -- if some articles are localized update adoption row

            update_adp_status_type_blk(
                p_id			    => l_id,
                p_local_org_id		=> p_org_id,
                p_adoption_status	=> 'APPROVED',
                p_adoption_type		=> 'LOCALIZED',
                p_type              => 'LOCALIZED',
                x_return_status		=> x_return_status
                );
		    IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
                RAISE FND_API.G_EXC_ERROR ;
            ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
            END IF;

		END IF;

	END IF; -- of IF (p_org_id = G_GLOBAL_ORG_ID) THEN


    -- delete rows created in the temp table
    DELETE FROM OKC_ART_BLK_TEMP
        WHERE id = l_id;

    fnd_msg_pub.count_and_get( p_count => x_msg_count , p_data 	=> x_msg_data);
	IF(FND_API.to_boolean(p_commit)) THEN
		COMMIT;
    END IF;

    IF (l_debug = 'Y') THEN
        okc_debug.log('200: Leaving approve_blk: Success');
    END IF;


EXCEPTION

	WHEN FND_API.G_EXC_ERROR THEN
		ROLLBACK TO approve_blk_PVT;
		x_return_status := FND_API.G_RET_STS_ERROR ;

        IF (l_debug = 'Y') THEN
            okc_debug.log('201: Leaving approve_blk: Error');
	    END IF;
		fnd_msg_pub.count_and_get( p_count => x_msg_count , p_data 	=> x_msg_data);

	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		ROLLBACK TO approve_blk_PVT;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF (l_debug = 'Y') THEN
            okc_debug.log('202: Leaving approve_blk: Unexpected Error');
	    END IF;
        fnd_msg_pub.count_and_get( p_count => x_msg_count , p_data 	=> x_msg_data);

	WHEN OTHERS THEN
		ROLLBACK TO approve_blk_PVT;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF (l_debug = 'Y') THEN
            okc_debug.log('203: Leaving approve_blk: Unknown Error');
	    END IF;

        IF 	fnd_msg_pub.check_msg_level(fnd_msg_pub.G_MSG_LVL_UNEXP_ERROR)
		THEN
			fnd_msg_pub.add_exc_msg(G_PKG_NAME ,l_api_name );
		END IF;
		fnd_msg_pub.count_and_get( p_count => x_msg_count , p_data 	=> x_msg_data);

END approve_blk;

---------------------------------------------------------------------

PROCEDURE reject_blk(
	p_api_version			IN	NUMBER ,
  	p_init_msg_list			IN	VARCHAR2  ,
	p_commit				IN	VARCHAR2  ,
	x_return_status			OUT	NOCOPY VARCHAR2 ,
	x_msg_count				OUT	NOCOPY NUMBER ,
	x_msg_data				OUT	NOCOPY VARCHAR2 ,

	p_org_id				IN	NUMBER ,
	p_art_ver_tbl			IN	num_tbl_type ,
	x_validation_results	OUT	NOCOPY validation_tbl_type )
IS

    l_api_version			NUMBER := 1.0;
    l_api_name				VARCHAR2(30) := 'reject_blk';

    l_qa_return_status          VARCHAR2(1);
    l_id                        NUMBER := -1;

    l_adopt_asis_count          NUMBER := 0;
    l_global_count              NUMBER := 0;
    l_localized_count           NUMBER := 0;

BEGIN

    IF (l_debug = 'Y') THEN
        okc_debug.log('100: Entering reject_blk: p_api_version='||p_api_version||' p_init_msg_list='||p_init_msg_list||' p_commit='||p_commit);

        okc_debug.log('101: In reject_blk: p_org_id='||p_org_id);

        IF (p_art_ver_tbl IS NOT NULL) THEN
            okc_debug.log('102: p_art_ver_tbl.COUNT='||p_art_ver_tbl.COUNT);
            FOR i in p_art_ver_tbl.FIRST..p_art_ver_tbl.LAST LOOP
                 okc_debug.log('103: p_art_ver_tbl['||i||']='||p_art_ver_tbl(i));
            END LOOP;
        END IF;
	END IF;

	-- standard initialization code
	SAVEPOINT reject_blk_PVT;
    G_GLOBAL_ORG_ID	    := NVL(FND_PROFILE.VALUE('OKC_GLOBAL_ORG_ID'),-99);
    G_USER_ID           := FND_GLOBAL.USER_ID;
    G_LOGIN_ID          := FND_GLOBAL.LOGIN_ID;
    l_debug             := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

    IF NOT fnd_api.compatible_api_call( l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;
	IF fnd_api.to_boolean( p_init_msg_list ) THEN
		fnd_msg_pub.initialize;
	END IF;
	x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- first populate the the temp table with all the relevant details
    get_version_details(
        p_org_id				=> p_org_id,
        p_art_ver_tbl			=> p_art_ver_tbl,
        x_return_status			=> x_return_status,
        x_id                    => l_id,
        x_adopt_asis_count      => l_adopt_asis_count,
        x_global_count          => l_global_count,
        x_localized_count       => l_localized_count
        );
    IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
        RAISE FND_API.G_EXC_ERROR ;
    ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    END IF;

	-- check if all versions are in pending approval status first
	-- this is not part of normal qa, but a basic sanity check required
	-- for all status transitions
    status_check_blk(
        p_id				    => l_id,
        p_to_status				=> 'REJECTED',
        x_return_status			=> x_return_status,
        x_qa_return_status      => l_qa_return_status,
        px_validation_results	=> x_validation_results
        );
    IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
        RAISE FND_API.G_EXC_ERROR ;
    ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    ELSE
        -- status check failed
        IF (l_qa_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
            RAISE FND_API.G_EXC_ERROR ;
        END IF;
    END IF;


    -- common for global/local/localized clauses, will do nothing for adopt as is clauses.
    update_art_version_status_blk(
        p_id    		=> l_id,
        p_status		=> 'REJECTED',
        x_return_status	=> x_return_status
        );
    IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
        RAISE FND_API.G_EXC_ERROR ;
    ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    END IF;



	IF (p_org_id <> G_GLOBAL_ORG_ID) THEN
	-- we are not in the global org, article for adoption as is are being rejected

		IF (l_adopt_asis_count > 0) THEN
		    -- we are adopting some article versions as is.
			-- 1. Update Adoption Row
			-- 2. Delete relationship rows if the first version is being rejected

            update_adp_status_type_blk(
                p_id			    => l_id,
                p_local_org_id		=> p_org_id,
                p_adoption_status	=> 'REJECTED',
                p_adoption_type		=> 'AVAILABLE',
                p_type              => 'ADOPTED',
                x_return_status		=> x_return_status
                );
		    IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
                RAISE FND_API.G_EXC_ERROR ;
            ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
            END IF;

            delete_relationships_blk(
                p_id    			=> l_id,
                p_org_id            => p_org_id,
                x_return_status		=> x_return_status
                );
			IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
                RAISE FND_API.G_EXC_ERROR ;
            ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
            END IF;

        END IF;

		IF (l_localized_count > 0) THEN
		    -- update adoption row if localized

            update_adp_status_type_blk(
                p_id			    => l_id,
                p_local_org_id		=> p_org_id,
                p_adoption_status	=> 'REJECTED',
                p_adoption_type		=> 'LOCALIZED',
                p_type              => 'LOCALIZED',
                x_return_status		=> x_return_status
                );
		    IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
                RAISE FND_API.G_EXC_ERROR ;
            ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
            END IF;

		END IF;

	END IF; -- of IF (p_org_id <> G_GLOBAL_ORG_ID) THEN


    -- delete rows created in the temp table
    DELETE FROM OKC_ART_BLK_TEMP
        WHERE id = l_id;

    fnd_msg_pub.count_and_get( p_count => x_msg_count , p_data 	=> x_msg_data);
	IF(FND_API.to_boolean(p_commit)) THEN
		COMMIT;
    END IF;

    IF (l_debug = 'Y') THEN
        okc_debug.log('200: Leaving reject_blk: Success');
    END IF;


EXCEPTION

	WHEN FND_API.G_EXC_ERROR THEN
		ROLLBACK TO reject_blk_PVT;
		x_return_status := FND_API.G_RET_STS_ERROR ;

        IF (l_debug = 'Y') THEN
            okc_debug.log('201: Leaving reject_blk: Error');
	    END IF;

        fnd_msg_pub.count_and_get( p_count => x_msg_count , p_data 	=> x_msg_data);

	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		ROLLBACK TO reject_blk_PVT;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF (l_debug = 'Y') THEN
            okc_debug.log('202: Leaving reject_blk: Unexpected Error');
	    END IF;

        fnd_msg_pub.count_and_get( p_count => x_msg_count , p_data 	=> x_msg_data);

	WHEN OTHERS THEN
		ROLLBACK TO reject_blk_PVT;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF (l_debug = 'Y') THEN
            okc_debug.log('203: Leaving reject_blk: Unknown Error');
	    END IF;

        IF 	fnd_msg_pub.check_msg_level(fnd_msg_pub.G_MSG_LVL_UNEXP_ERROR)
		THEN
			fnd_msg_pub.add_exc_msg(G_PKG_NAME ,l_api_name );
		END IF;
		fnd_msg_pub.count_and_get( p_count => x_msg_count , p_data 	=> x_msg_data);

END reject_blk;

-----------------------------------------------------------------------------

END OKC_ART_BLK_PVT;



/
