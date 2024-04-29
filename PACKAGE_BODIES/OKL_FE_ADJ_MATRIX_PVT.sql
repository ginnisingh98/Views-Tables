--------------------------------------------------------
--  DDL for Package Body OKL_FE_ADJ_MATRIX_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_FE_ADJ_MATRIX_PVT" AS
/* $Header: OKLRPAMB.pls 120.9 2006/07/21 13:12:59 akrangan noship $ */

--------------------------------------------------------------------------------
--PACKAGE CONSTANTS
--------------------------------------------------------------------------------
G_DB_ERROR              CONSTANT VARCHAR2(12)  := 'OKL_DB_ERROR';
G_PROG_NAME_TOKEN       CONSTANT VARCHAR2(9)   := 'PROG_NAME';
G_NO_PARENT_RECORD      CONSTANT VARCHAR2(200) :='OKC_NO_PARENT_RECORD';
G_UNEXPECTED_ERROR      CONSTANT VARCHAR2(200) :='OKC_CONTRACTS_UNEXPECTED_ERROR';
G_SQLERRM_TOKEN         CONSTANT VARCHAR2(200) := 'SQLerrm';
G_SQLCODE_TOKEN         CONSTANT VARCHAR2(200) := 'SQLcode';

G_EXCEPTION_HALT_VALIDATION exception;
G_INVALID_ADJ_CAT_DATES     exception;
G_EXCEPTION_CANNOT_UPDATE   exception;
G_INVALID_START_DATE        exception;

rosetta_g_mistake_date date := to_date('01/01/+4713', 'MM/DD/SYYYY');
rosetta_g_mistake_date2 date := to_date('01/01/-4711', 'MM/DD/SYYYY');
rosetta_g_miss_date date := to_date('01/01/-4712', 'MM/DD/SYYYY');

-- this is to workaround the JDBC bug regarding IN DATE of value GMiss
function rosetta_g_miss_date_in_map(d date) return date as
begin
  if (d = rosetta_g_mistake_date or d=rosetta_g_mistake_date2) then return fnd_api.g_miss_date; end if;
  return d;
end;

-- to calculate the start date of the new version
PROCEDURE calc_start_date(
                        p_api_version   IN  NUMBER,
                        p_init_msg_list IN  VARCHAR2 DEFAULT okl_api.g_false,
                        x_return_status OUT NOCOPY VARCHAR2,
                        x_msg_count     OUT NOCOPY NUMBER,
                        x_msg_data      OUT NOCOPY VARCHAR2,
                        p_pal_rec       IN  okl_pal_rec,
                        x_cal_eff_from  OUT NOCOPY DATE) AS

TYPE l_start_date_type IS TABLE OF DATE INDEX BY BINARY_INTEGER;

l_api_name      VARCHAR2(40):='calc_start_date';
l_api_version   NUMBER      := 1.0;
l_pal_rec       okl_pal_rec := p_pal_rec;
l_eff_from      DATE;
l_eff_to        DATE;
l_return_status VARCHAR2(1):= OKL_API.G_RET_STS_SUCCESS;
l_start_date    l_start_date_type;
l_max_start_date DATE;
i               NUMBER;

-- cursor to fetch the maximum start date of lease quotes referencing Standard Rate Template
CURSOR srt_lq_csr(p_version_id IN NUMBER) IS
SELECT max(expected_start_date) start_date FROM okl_lease_quotes_b
WHERE rate_template_id IN
(SELECT  std_rate_tmpl_ver_id FROM okl_fe_std_rt_tmp_vers WHERE adj_mat_version_id=p_version_id);

-- cursor to fetch the maximum start date of quick quotes referencing Standard Rate Template
CURSOR srt_qq_csr(p_version_id IN NUMBER) IS
SELECT max(expected_start_date) start_date FROM okl_quick_quotes_b
WHERE rate_template_id in
(SELECT std_rate_tmpl_ver_id from okl_fe_std_rt_tmp_vers where adj_mat_version_id=p_version_id);

-- cursor to fetch the maximum start date of lease quotes referencing Lease Rate Sets
CURSOR lrs_lq_csr(p_version_id IN NUMBER) IS
SELECT max(expected_start_date) start_date FROM okl_lease_quotes_b
WHERE rate_card_id IN
(SELECT  rate_set_version_id FROM okl_fe_rate_set_versions WHERE adj_mat_version_id=p_version_id);

-- cursor to fetch the maximum start date of quick quotes referencing Lease Rate Sets
CURSOR lrs_qq_csr(p_version_id IN NUMBER) IS
SELECT max(expected_start_date) start_date FROM okl_quick_quotes_b
WHERE rate_card_id IN
(SELECT rate_set_version_id FROM okl_fe_rate_set_versions WHERE adj_mat_version_id=p_version_id);

-- cursor to fetch the start date and the end of the previous version
CURSOR prev_ver_csr(p_adj_mat_id IN NUMBER, p_ver_number IN VARCHAR2) IS
SELECT effective_from_date, effective_to_date FROM okl_fe_adj_mat_versions where adj_mat_id= p_adj_mat_id
and version_number= p_ver_number-1;

CURSOR get_elig_crit_start_date(p_version_id IN NUMBER) IS
SELECT max(effective_from_date)
FROM   okl_fe_criteria_set ech
      ,okl_fe_criteria ecl
WHERE  ecl.criteria_set_id = ech.criteria_set_id
AND ech.source_id = p_version_id AND source_object_code = 'PAM';

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

OPEN prev_ver_csr(l_pal_rec.adj_mat_id, l_pal_rec.version_number);
FETCH prev_ver_csr INTO l_eff_from, l_eff_to;

IF (prev_ver_csr%FOUND) THEN
    -- if the effective to date of the previous version is not null

    IF (l_eff_to IS NOT NULL) THEN
      l_max_start_date := l_eff_to + 1;
    ELSE
      l_max_start_date := l_eff_from + 1;
    END IF;
ELSE
     l_max_start_date:= okl_api.g_miss_date;
END IF;
CLOSE prev_ver_csr;

IF (l_eff_to IS NULL) THEN


OPEN srt_lq_csr(l_pal_rec.adj_mat_version_id);
FETCH srt_lq_csr INTO l_start_date(0);
CLOSE srt_lq_csr;

OPEN srt_qq_csr(l_pal_rec.adj_mat_version_id);
FETCH srt_qq_csr INTO l_start_date(1);
CLOSE srt_qq_csr;

OPEN lrs_lq_csr(l_pal_rec.adj_mat_version_id);
FETCH lrs_lq_csr INTO l_start_date(2);
CLOSE lrs_lq_csr;

OPEN lrs_qq_csr(l_pal_rec.adj_mat_version_id);
FETCH lrs_qq_csr INTO l_start_date(3);
CLOSE lrs_qq_csr;

OPEN get_elig_crit_start_date(l_pal_rec.adj_mat_version_id);
FETCH get_elig_crit_start_date INTO l_start_date(4);
CLOSE get_elig_crit_start_date;
-- calculate the maximum start date
FOR i IN l_start_date.FIRST .. l_start_date.LAST LOOP
  IF (l_start_date(i) IS NOT NULL AND (l_start_date(i)+1) > l_max_start_date) THEN
    l_max_start_date:= l_start_date(i)+1;
  END IF;
END LOOP;

END IF;

-- assign the max start date to the out parameter
x_cal_eff_from := l_max_start_date;

--end activity
OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
x_return_status := l_return_status;

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
        x_return_status := OKL_API.HANDLE_EXCEPTIONS
          (
              l_api_name,
              G_PKG_NAME,
              'OKL_API.G_RET_STS_UNEXP_ERROR',
              x_msg_count,
              x_msg_data,
              '_PVT'
          );

  WHEN OTHERS THEN
        x_return_status := OKL_API.HANDLE_EXCEPTIONS
          (
              l_api_name,
              G_PKG_NAME,
              'OTHERS',
              x_msg_count,
              x_msg_data,
              '_PVT'
         );
END calc_start_date;

-- procedure to validate the pricing adjustment matrix
PROCEDURE VALIDATE_ADJ_MAT(
                        p_api_version   IN  NUMBER,
                        p_init_msg_list IN  VARCHAR2 DEFAULT okl_api.g_false,
                        x_return_status OUT NOCOPY VARCHAR2,
                        x_msg_count     OUT NOCOPY NUMBER,
                        x_msg_data      OUT NOCOPY VARCHAR2,
                        p_pal_rec       IN  okl_pal_rec,
                        p_ech_rec       IN  okl_ech_rec,
                        p_ecl_tbl       IN  okl_ecl_tbl,
                        p_ecv_tbl       IN  okl_ecv_tbl) IS

l_api_name      VARCHAR2(40):='VALIDATE_ADJ_MAT';
l_api_version   NUMBER      := 1.0;
l_pal_rec       okl_pal_rec := p_pal_rec;
l_ecl_tbl       okl_ecl_tbl := p_ecl_tbl;
i               NUMBER;
l_crit_cat      VARCHAR2(40) := 'Adjustment Categories';
l_return_status VARCHAR2(1):= OKL_API.G_RET_STS_SUCCESS;

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


-- The Effective Dates of the Adjusment Categories should be in the range of the Adjustment matrix

FOR i in l_ecl_tbl.FIRST..l_ecl_tbl.LAST LOOP
        IF (l_ecl_tbl(i).EFFECTIVE_FROM_DATE < l_pal_rec.EFFECTIVE_FROM_DATE) THEN
                RAISE G_INVALID_ADJ_CAT_DATES;
        END IF;
        IF (l_ecl_tbl(i).EFFECTIVE_TO_DATE is null or l_ecl_tbl(i).EFFECTIVE_TO_DATE = OKL_API.G_MISS_DATE) THEN
                IF (l_pal_rec.EFFECTIVE_TO_DATE is not null and l_pal_rec.EFFECTIVE_TO_DATE <> OKL_API.G_MISS_DATE) THEN
                        RAISE G_INVALID_ADJ_CAT_DATES;
                END IF;
        ELSIF (l_pal_rec.EFFECTIVE_TO_DATE is not null and l_pal_rec.EFFECTIVE_TO_DATE <> OKL_API.G_MISS_DATE) THEN
                IF (l_ecl_tbl(i).EFFECTIVE_TO_DATE > l_pal_rec.EFFECTIVE_TO_DATE) THEN
                        RAISE G_INVALID_ADJ_CAT_DATES;
                END IF;
        END IF;
END LOOP;

--end activity
OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
x_return_status := l_return_status;

EXCEPTION
  WHEN G_INVALID_ADJ_CAT_DATES THEN
        OKL_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                            p_msg_name     => 'OKL_CAT_INVALID_DATE_RANGE',
                            p_token1       => 'CRIT_CAT',
                            p_token1_value => l_crit_cat
                           );
        x_return_status := OKL_API.HANDLE_EXCEPTIONS
          (
              l_api_name,
              G_PKG_NAME,
              'OKL_API.G_RET_STS_ERROR',
              x_msg_count,
              x_msg_data,
              '_PVT'
          );


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
        x_return_status := OKL_API.HANDLE_EXCEPTIONS
          (
              l_api_name,
              G_PKG_NAME,
              'OKL_API.G_RET_STS_UNEXP_ERROR',
              x_msg_count,
              x_msg_data,
              '_PVT'
          );

  WHEN OTHERS THEN
        x_return_status := OKL_API.HANDLE_EXCEPTIONS
          (
              l_api_name,
              G_PKG_NAME,
              'OTHERS',
              x_msg_count,
              x_msg_data,
              '_PVT'
         );


END VALIDATE_ADJ_MAT;

PROCEDURE GET_ADJUSTMENT_CATEGORIES( p_api_version    IN  NUMBER,
                                p_init_msg_list  IN  VARCHAR2 DEFAULT okl_api.g_false,
                                x_return_status  OUT NOCOPY VARCHAR2,
                                x_msg_count      OUT NOCOPY NUMBER,
                                x_msg_data       OUT NOCOPY VARCHAR2,
                                source_id        IN  NUMBER,
                                x_ech_rec        OUT NOCOPY okl_ech_rec,
                                x_ecl_tbl        OUT NOCOPY okl_ecl_tbl,
                                x_ecv_tbl        OUT NOCOPY okl_ecv_tbl)IS

-- cursor to fetch the adjustment categories header record
CURSOR adj_cat_hdr(p_source_id IN NUMBER, p_source_object IN VARCHAR2) IS
SELECT  CRITERIA_SET_ID,
        OBJECT_VERSION_NUMBER,
        SOURCE_ID,
        SOURCE_OBJECT_CODE,
        MATCH_CRITERIA_CODE,
        VALIDATION_CODE,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_DATE,
        LAST_UPDATE_LOGIN
FROM OKL_FE_CRITERIA_SET WHERE SOURCE_ID= p_source_id AND SOURCE_OBJECT_CODE= p_source_object;

-- cursor to fetch the adjustment categories lines record
CURSOR adj_cat_lines(p_criteria_set_id IN NUMBER) IS
SELECT  CRITERIA_ID,
        OBJECT_VERSION_NUMBER,
        MATCH_CRITERIA_CODE,
        CRITERIA_SET_ID,
        CRIT_CAT_DEF_ID,
        Effective_From_DATE,
        Effective_To_DATE,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_DATE,
        LAST_UPDATE_LOGIN
FROM OKL_FE_CRITERIA WHERE CRITERIA_SET_ID= p_criteria_set_id;

-- cursor to fetch the adjustment categories values record
CURSOR adj_cat_values(p_criteria_id IN NUMBER) IS
SELECT  CRITERION_VALUE_ID,
        OBJECT_VERSION_NUMBER,
        CRITERIA_ID,
        OPERATOR_CODE,
        CRIT_CAT_VALUE1,
        CRIT_CAT_VALUE2,
        ADJUSTMENT_FACTOR,
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
FROM OKL_FE_CRITERION_VALUES WHERE CRITERIA_ID = p_criteria_id;

-- cursor to get the data type and the value type of a category
CURSOR crit_def(criteria_def_id IN NUMBER) IS
SELECT  DATA_TYPE_CODE,
        VALUE_TYPE_CODE
FROM OKL_FE_CRIT_CAT_DEF_V where CRIT_CAT_DEF_ID = criteria_def_id;

l_api_name VARCHAR2(40):= 'POPULATE_ADJUSTMENT_CATEGORIES';
l_api_version NUMBER:=1.0;
i       NUMBER :=1;
j       NUMBER :=1;
data_type VARCHAR2(30);
BEGIN
x_return_status := OKL_API.START_ACTIVITY(l_api_name,
                                        G_PKG_NAME,
                                        p_init_msg_list,
                                        l_api_version,
                                        p_api_version,
                                        '_PVT',
                                        x_return_status);


FOR cat_hdr_rec IN adj_cat_hdr(source_id, 'PAM')
LOOP
        x_ech_rec.CRITERIA_SET_ID       := cat_hdr_rec.CRITERIA_SET_ID;
        x_ech_rec.OBJECT_VERSION_NUMBER := cat_hdr_rec.OBJECT_VERSION_NUMBER;
        x_ech_rec.SOURCE_ID             := cat_hdr_rec.SOURCE_ID;
        x_ech_rec.SOURCE_OBJECT_CODE    := cat_hdr_rec.SOURCE_OBJECT_CODE;
        x_ech_rec.MATCH_CRITERIA_CODE   := cat_hdr_rec.MATCH_CRITERIA_CODE;
        x_ech_rec.VALIDATION_CODE       := cat_hdr_rec.VALIDATION_CODE;
        x_ech_rec.CREATED_BY            := cat_hdr_rec.CREATED_BY;
        x_ech_rec.CREATION_DATE         := cat_hdr_rec.CREATION_DATE;
        x_ech_rec.LAST_UPDATED_BY       := cat_hdr_rec.LAST_UPDATED_BY;
        x_ech_rec.LAST_UPDATE_DATE      := cat_hdr_rec.LAST_UPDATE_DATE;
        x_ech_rec.LAST_UPDATE_LOGIN     := cat_hdr_rec.LAST_UPDATE_LOGIN;
END LOOP;

FOR cat_lines_rec IN adj_cat_lines(x_ech_rec.CRITERIA_SET_ID)
LOOP
        x_ecl_tbl(i).CRITERIA_ID           := cat_lines_rec.CRITERIA_ID;
        x_ecl_tbl(i).CRIT_CAT_DEF_ID       := cat_lines_rec.CRIT_CAT_DEF_ID;
        FOR type_code IN crit_def(cat_lines_rec.CRIT_CAT_DEF_ID) LOOP
                data_type := type_code.DATA_TYPE_CODE;
        END LOOP;
        FOR cat_values_rec IN adj_cat_values(cat_lines_rec.CRITERIA_ID) LOOP
                x_ecv_tbl(j).CRITERION_VALUE_ID:= cat_values_rec.CRITERION_VALUE_ID;
                x_ecv_tbl(j).OBJECT_VERSION_NUMBER:= cat_values_rec.OBJECT_VERSION_NUMBER;
                x_ecv_tbl(j).CRITERIA_ID:= cat_values_rec.CRITERIA_ID;
                x_ecv_tbl(j).OPERATOR_CODE:= cat_values_rec.OPERATOR_CODE;
        IF (data_type = 'VARCHAR2') THEN
                x_ecv_tbl(j).CRIT_CAT_VALUE1:= cat_values_rec.CRIT_CAT_VALUE1;
                x_ecv_tbl(j).CRIT_CAT_VALUE2:= cat_values_rec.CRIT_CAT_VALUE2;
        ELSIF (data_type = 'NUMBER') THEN
                x_ecv_tbl(j).CRIT_CAT_NUMVAL1 :=to_number(cat_values_rec.CRIT_CAT_VALUE1);
                x_ecv_tbl(j).CRIT_CAT_NUMVAL2 :=to_number(cat_values_rec.CRIT_CAT_VALUE2);
        ELSIF (data_type = 'DATE') THEN
                x_ecv_tbl(j).CRIT_CAT_DATEVAL1 :=FND_DATE.canonical_to_date(cat_values_rec.CRIT_CAT_VALUE1);
                x_ecv_tbl(j).CRIT_CAT_DATEVAL2 :=FND_DATE.canonical_to_date(cat_values_rec.CRIT_CAT_VALUE2);
        END IF;
        x_ecv_tbl(j).ADJUSTMENT_FACTOR:= cat_values_rec.ADJUSTMENT_FACTOR;
        x_ecv_tbl(j).ATTRIBUTE_CATEGORY:= cat_values_rec.ATTRIBUTE_CATEGORY;
        x_ecv_tbl(j).ATTRIBUTE1:= cat_values_rec.ATTRIBUTE1;
        x_ecv_tbl(j).ATTRIBUTE2:= cat_values_rec.ATTRIBUTE2;
        x_ecv_tbl(j).ATTRIBUTE3:= cat_values_rec.ATTRIBUTE3;
        x_ecv_tbl(j).ATTRIBUTE4:= cat_values_rec.ATTRIBUTE4;
        x_ecv_tbl(j).ATTRIBUTE5:= cat_values_rec.ATTRIBUTE5;
        x_ecv_tbl(j).ATTRIBUTE6:= cat_values_rec.ATTRIBUTE6;
        x_ecv_tbl(j).ATTRIBUTE7:= cat_values_rec.ATTRIBUTE7;
        x_ecv_tbl(j).ATTRIBUTE8:= cat_values_rec.ATTRIBUTE8;
        x_ecv_tbl(j).ATTRIBUTE9:= cat_values_rec.ATTRIBUTE9;
        x_ecv_tbl(j).ATTRIBUTE10:= cat_values_rec.ATTRIBUTE10;
        x_ecv_tbl(j).ATTRIBUTE11:= cat_values_rec.ATTRIBUTE11;
        x_ecv_tbl(j).ATTRIBUTE12:= cat_values_rec.ATTRIBUTE12;
        x_ecv_tbl(j).ATTRIBUTE13:= cat_values_rec.ATTRIBUTE13;
        x_ecv_tbl(j).ATTRIBUTE14:= cat_values_rec.ATTRIBUTE14;
        x_ecv_tbl(j).ATTRIBUTE15:= cat_values_rec.ATTRIBUTE15;
        x_ecv_tbl(j).CREATED_BY:= cat_values_rec.CREATED_BY;
        x_ecv_tbl(j).CREATION_DATE:= cat_values_rec.CREATION_DATE;
        x_ecv_tbl(j).LAST_UPDATED_BY:= cat_values_rec.LAST_UPDATED_BY;
        x_ecv_tbl(j).LAST_UPDATE_DATE:= cat_values_rec.LAST_UPDATE_DATE;
        x_ecv_tbl(j).LAST_UPDATE_LOGIN:= cat_values_rec.LAST_UPDATE_LOGIN;

        j:=j+1;
END LOOP;
x_ecl_tbl(i).OBJECT_VERSION_NUMBER := cat_lines_rec.OBJECT_VERSION_NUMBER;
x_ecl_tbl(i).MATCH_CRITERIA_CODE   := cat_lines_rec.MATCH_CRITERIA_CODE;
x_ecl_tbl(i).CRITERIA_SET_ID       := cat_lines_rec.CRITERIA_SET_ID;
x_ecl_tbl(i).Effective_From_DATE   := cat_lines_rec.Effective_From_DATE;
x_ecl_tbl(i).Effective_To_DATE     := cat_lines_rec.Effective_To_DATE;
x_ecl_tbl(i).CREATED_BY            := cat_lines_rec.CREATED_BY;
x_ecl_tbl(i).CREATION_DATE         := cat_lines_rec.CREATION_DATE;
x_ecl_tbl(i).LAST_UPDATED_BY       := cat_lines_rec.LAST_UPDATED_BY;
x_ecl_tbl(i).LAST_UPDATE_DATE      := cat_lines_rec.LAST_UPDATE_DATE;
x_ecl_tbl(i).LAST_UPDATE_LOGIN     := cat_lines_rec.LAST_UPDATE_LOGIN;
x_ecl_tbl(i).IS_NEW_FLAG           := 'N';
i:=i+1;
END LOOP;
--end activity
OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);

EXCEPTION

WHEN others THEN
        x_return_status := OKL_API.HANDLE_EXCEPTIONS
          (
              l_api_name,
              G_PKG_NAME,
              'OTHERS',
              x_msg_count,
              x_msg_data,
              '_PVT'
         );

END GET_ADJUSTMENT_CATEGORIES;

PROCEDURE GET_ADJ_MATRIX(p_api_version      IN  NUMBER,
                                p_init_msg_list  IN  VARCHAR2 DEFAULT okl_api.g_false,
                                x_return_status  OUT NOCOPY VARCHAR2,
                                x_msg_count      OUT NOCOPY NUMBER,
                                x_msg_data       OUT NOCOPY VARCHAR2,
                                p_adj_mat_id     IN  NUMBER,
                                p_version_number IN  NUMBER,
                                x_pamv_rec       OUT NOCOPY okl_pamv_rec,
                                x_pal_rec        OUT NOCOPY okl_pal_rec
                                )IS
-- cursor to fetch the header record
CURSOR adj_mat_hdr(p_adj_mat_id IN NUMBER) IS
SELECT  ADJ_MAT_ID,
        ADJ_MAT_NAME,
        ADJ_MAT_DESC,
        OBJECT_VERSION_NUMBER,
        ORG_ID,
        CURRENCY_CODE,
        ADJ_MAT_TYPE_CODE,
        ORIG_ADJ_MAT_ID,
        STS_CODE,
        EFFECTIVE_FROM_DATE,
        EFFECTIVE_TO_DATE,
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
FROM OKL_FE_ADJ_MAT_V WHERE ADJ_MAT_ID= p_adj_mat_id;

-- cursor to fetch the versions record
CURSOR adj_mat_version(p_adj_mat_id IN NUMBER, p_version_number IN VARCHAR2) IS
SELECT  ADJ_MAT_VERSION_ID,
        VERSION_NUMBER,
        OBJECT_VERSION_NUMBER,
        ADJ_MAT_ID,
        STS_CODE,
        EFFECTIVE_FROM_DATE,
        EFFECTIVE_TO_DATE,
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
        LAST_UPDATE_LOGIN FROM OKL_FE_ADJ_MAT_VERSIONS
WHERE ADJ_MAT_ID=p_adj_mat_id and VERSION_NUMBER= p_version_number;

l_api_name  VARCHAR2(40) := 'populate_adj_matrix';
l_api_version NUMBER := 1.0;
BEGIN
x_return_status := OKL_API.START_ACTIVITY(l_api_name,
                                        G_PKG_NAME,
                                        p_init_msg_list,
                                        l_api_version,
                                        p_api_version,
                                        '_PVT',
                                        x_return_status);

-- populate the header record
FOR cat_hdr_rec IN adj_mat_hdr(p_adj_mat_id) LOOP
        x_pamv_rec.ADJ_MAT_ID := cat_hdr_rec.ADJ_MAT_ID;
        x_pamv_rec.ADJ_MAT_NAME := cat_hdr_rec.ADJ_MAT_NAME;
        x_pamv_rec.ADJ_MAT_DESC := cat_hdr_rec.ADJ_MAT_DESC;
        x_pamv_rec.OBJECT_VERSION_NUMBER := cat_hdr_rec.OBJECT_VERSION_NUMBER;
        x_pamv_rec.ORG_ID := cat_hdr_rec.ORG_ID;
        x_pamv_rec.CURRENCY_CODE := cat_hdr_rec.CURRENCY_CODE;
        x_pamv_rec.ADJ_MAT_TYPE_CODE := cat_hdr_rec.ADJ_MAT_TYPE_CODE;
        x_pamv_rec.ORIG_ADJ_MAT_ID := cat_hdr_rec.ORIG_ADJ_MAT_ID;
        x_pamv_rec.STS_CODE := cat_hdr_rec.STS_CODE;
        x_pamv_rec.EFFECTIVE_FROM_DATE := cat_hdr_rec.EFFECTIVE_FROM_DATE;
        x_pamv_rec.EFFECTIVE_TO_DATE   := cat_hdr_rec.EFFECTIVE_TO_DATE;
        x_pamv_rec.ATTRIBUTE_CATEGORY := cat_hdr_rec.ATTRIBUTE_CATEGORY;
        x_pamv_rec.ATTRIBUTE1 := cat_hdr_rec.ATTRIBUTE1;
        x_pamv_rec.ATTRIBUTE2 := cat_hdr_rec.ATTRIBUTE2;
        x_pamv_rec.ATTRIBUTE3 := cat_hdr_rec.ATTRIBUTE3;
        x_pamv_rec.ATTRIBUTE4 := cat_hdr_rec.ATTRIBUTE4;
        x_pamv_rec.ATTRIBUTE5 := cat_hdr_rec.ATTRIBUTE5;
        x_pamv_rec.ATTRIBUTE6 := cat_hdr_rec.ATTRIBUTE6;
        x_pamv_rec.ATTRIBUTE7 := cat_hdr_rec.ATTRIBUTE7;
        x_pamv_rec.ATTRIBUTE8 := cat_hdr_rec.ATTRIBUTE8;
        x_pamv_rec.ATTRIBUTE9 := cat_hdr_rec.ATTRIBUTE9;
        x_pamv_rec.ATTRIBUTE10 := cat_hdr_rec.ATTRIBUTE10;
        x_pamv_rec.ATTRIBUTE11 := cat_hdr_rec.ATTRIBUTE11;
        x_pamv_rec.ATTRIBUTE12 := cat_hdr_rec.ATTRIBUTE12;
        x_pamv_rec.ATTRIBUTE13 := cat_hdr_rec.ATTRIBUTE13;
        x_pamv_rec.ATTRIBUTE14 := cat_hdr_rec.ATTRIBUTE14;
        x_pamv_rec.ATTRIBUTE15 := cat_hdr_rec.ATTRIBUTE15;
        x_pamv_rec.CREATED_BY := cat_hdr_rec.CREATED_BY;
        x_pamv_rec.CREATION_DATE := cat_hdr_rec.CREATION_DATE;
        x_pamv_rec.LAST_UPDATED_BY := cat_hdr_rec.LAST_UPDATED_BY;
        x_pamv_rec.LAST_UPDATE_DATE := cat_hdr_rec.LAST_UPDATE_DATE;
        x_pamv_rec.LAST_UPDATE_LOGIN := cat_hdr_rec.LAST_UPDATE_LOGIN;
END LOOP;

-- populate the versions record
FOR cat_version_rec IN adj_mat_version(p_adj_mat_id, p_version_number) LOOP
        x_pal_rec.ADJ_MAT_VERSION_ID := cat_version_rec.ADJ_MAT_VERSION_ID;
        x_pal_rec.VERSION_NUMBER := cat_version_rec.VERSION_NUMBER;
        x_pal_rec.OBJECT_VERSION_NUMBER := cat_version_rec.OBJECT_VERSION_NUMBER;
        x_pal_rec.ADJ_MAT_ID := cat_version_rec.ADJ_MAT_ID;
        x_pal_rec.STS_CODE := cat_version_rec.STS_CODE;
        x_pal_rec.EFFECTIVE_FROM_DATE := cat_version_rec.EFFECTIVE_FROM_DATE;
        x_pal_rec.EFFECTIVE_TO_DATE := cat_version_rec.EFFECTIVE_TO_DATE;
        x_pal_rec.ATTRIBUTE_CATEGORY := cat_version_rec.ATTRIBUTE_CATEGORY;
        x_pal_rec.ATTRIBUTE1 := cat_version_rec.ATTRIBUTE1;
        x_pal_rec.ATTRIBUTE2 := cat_version_rec.ATTRIBUTE2;
        x_pal_rec.ATTRIBUTE3 := cat_version_rec.ATTRIBUTE3;
        x_pal_rec.ATTRIBUTE4 := cat_version_rec.ATTRIBUTE4;
        x_pal_rec.ATTRIBUTE5 := cat_version_rec.ATTRIBUTE5;
        x_pal_rec.ATTRIBUTE6 := cat_version_rec.ATTRIBUTE6;
        x_pal_rec.ATTRIBUTE7 := cat_version_rec.ATTRIBUTE7;
        x_pal_rec.ATTRIBUTE8 := cat_version_rec.ATTRIBUTE8;
        x_pal_rec.ATTRIBUTE9 := cat_version_rec.ATTRIBUTE9;
        x_pal_rec.ATTRIBUTE10 := cat_version_rec.ATTRIBUTE10;
        x_pal_rec.ATTRIBUTE11 := cat_version_rec.ATTRIBUTE11;
        x_pal_rec.ATTRIBUTE12 := cat_version_rec.ATTRIBUTE12;
        x_pal_rec.ATTRIBUTE13 := cat_version_rec.ATTRIBUTE13;
        x_pal_rec.ATTRIBUTE14 := cat_version_rec.ATTRIBUTE14;
        x_pal_rec.ATTRIBUTE15 := cat_version_rec.ATTRIBUTE15;
        x_pal_rec.CREATED_BY := cat_version_rec.CREATED_BY;
        x_pal_rec.CREATION_DATE := cat_version_rec.CREATION_DATE;
        x_pal_rec.LAST_UPDATED_BY := cat_version_rec.LAST_UPDATED_BY;
        x_pal_rec.LAST_UPDATE_DATE := cat_version_rec.LAST_UPDATE_DATE;
        x_pal_rec.LAST_UPDATE_LOGIN := cat_version_rec.LAST_UPDATE_LOGIN;
END LOOP;

--end activity
OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);

EXCEPTION

WHEN others THEN
        x_return_status := OKL_API.HANDLE_EXCEPTIONS
          (
              l_api_name,
              G_PKG_NAME,
              'OTHERS',
              x_msg_count,
              x_msg_data,
              '_PVT'
         );

END GET_ADJ_MATRIX;
-- procedure to give the details of the adjustment matrix given the Adjustment
-- matrix id and the version number
PROCEDURE GET_VERSION(
                        p_api_version    IN  NUMBER,
                        p_init_msg_list  IN  VARCHAR2 DEFAULT okl_api.g_false,
                        x_return_status  OUT NOCOPY VARCHAR2,
                        x_msg_count      OUT NOCOPY NUMBER,
                        x_msg_data       OUT NOCOPY VARCHAR2,
                        p_adj_mat_id     IN  NUMBER,
                        p_version_number IN  NUMBER,
                        x_pamv_rec       OUT NOCOPY okl_pamv_rec,
                        x_pal_rec        OUT NOCOPY okl_pal_rec,
                        x_ech_rec        OUT NOCOPY okl_ech_rec,
                        x_ecl_tbl        OUT NOCOPY okl_ecl_tbl,
                        x_ecv_tbl        OUT NOCOPY okl_ecv_tbl) IS
l_api_name      VARCHAR2(40):='get_version';
l_api_version   NUMBER:=1.0;
l_return_status VARCHAR2(1):= OKL_API.G_RET_STS_SUCCESS;
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

GET_ADJ_MATRIX(p_api_version ,
                    p_init_msg_list,
                    x_return_status,
                    x_msg_count,
                    x_msg_data,
                    p_adj_mat_id,
                    p_version_number,
                    x_pamv_rec,
                    x_pal_rec);

IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
END IF;

GET_ADJUSTMENT_CATEGORIES( p_api_version,
                                p_init_msg_list,
                                x_return_status,
                                x_msg_count,
                                x_msg_data,
                                x_pal_rec.ADJ_MAT_VERSION_ID,
                                x_ech_rec,
                                x_ecl_tbl,
                                x_ecv_tbl);

IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
END IF;

--end activity
OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
x_return_status := l_return_status;

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
        x_return_status := OKL_API.HANDLE_EXCEPTIONS
          (
              l_api_name,
              G_PKG_NAME,
              'OKL_API.G_RET_STS_UNEXP_ERROR',
              x_msg_count,
              x_msg_data,
              '_PVT'
          );

  WHEN OTHERS THEN
        x_return_status := OKL_API.HANDLE_EXCEPTIONS
          (
              l_api_name,
              G_PKG_NAME,
              'OTHERS',
              x_msg_count,
              x_msg_data,
              '_PVT'
         );

END GET_VERSION;
-- procedure to give the details of the latest versionadjustment matrix given the Adjustment
-- matrix id
PROCEDURE GET_VERSION(
                        p_api_version    IN  NUMBER,
                        p_init_msg_list  IN  VARCHAR2 DEFAULT okl_api.g_false,
                        x_return_status  OUT NOCOPY VARCHAR2,
                        x_msg_count      OUT NOCOPY NUMBER,
                        x_msg_data       OUT NOCOPY VARCHAR2,
                        p_adj_mat_id     IN  NUMBER,
                        x_pamv_rec       OUT NOCOPY okl_pamv_rec,
                        x_pal_rec        OUT NOCOPY okl_pal_rec,
                        x_ech_rec        OUT NOCOPY okl_ech_rec,
                        x_ecl_tbl        OUT NOCOPY okl_ecl_tbl,
                        x_ecv_tbl        OUT NOCOPY okl_ecv_tbl) IS

CURSOR get_version_number(p_adj_mat_id IN NUMBER) IS
SELECT max(version_number) FROM
OKL_FE_ADJ_MAT_VERSIONS WHERE ADJ_MAT_ID=p_adj_mat_id;

l_version_number VARCHAR2(24);
l_api_name       VARCHAR2(40):='get_version';
l_api_version    NUMBER:=1.0;
l_return_status  VARCHAR2(1):= OKL_API.G_RET_STS_SUCCESS;
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

OPEN get_version_number(p_adj_mat_id);
FETCH get_version_number into l_version_number;
CLOSE get_version_number;

GET_ADJ_MATRIX(p_api_version ,
                    p_init_msg_list,
                    x_return_status,
                    x_msg_count,
                    x_msg_data,
                    p_adj_mat_id,
                    l_version_number,
                    x_pamv_rec,
                    x_pal_rec);

IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
END IF;

GET_ADJUSTMENT_CATEGORIES( p_api_version,
                                p_init_msg_list,
                                x_return_status,
                                x_msg_count,
                                x_msg_data,
                                x_pal_rec.ADJ_MAT_VERSION_ID,
                                x_ech_rec,
                                x_ecl_tbl,
                                x_ecv_tbl);

IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
END IF;

--end activity
OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
x_return_status := l_return_status;

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
        x_return_status := OKL_API.HANDLE_EXCEPTIONS
          (
              l_api_name,
              G_PKG_NAME,
              'OKL_API.G_RET_STS_UNEXP_ERROR',
              x_msg_count,
              x_msg_data,
              '_PVT'
          );

  WHEN OTHERS THEN
        x_return_status := OKL_API.HANDLE_EXCEPTIONS
          (
              l_api_name,
              G_PKG_NAME,
              'OTHERS',
              x_msg_count,
              x_msg_data,
              '_PVT'
         );

END GET_VERSION;


--procedure to create a Pricing Adjusment Matrix with the associated adjustment categories
PROCEDURE INSERT_ADJ_MAT(
                        p_api_version   IN  NUMBER,
                        p_init_msg_list IN  VARCHAR2 DEFAULT okl_api.g_false,
                        x_return_status OUT NOCOPY VARCHAR2,
                        x_msg_count     OUT NOCOPY NUMBER,
                        x_msg_data      OUT NOCOPY VARCHAR2,
                        p_pamv_rec      IN  okl_pamv_rec,
                        p_pal_rec       IN  okl_pal_rec,
                        x_pamv_rec      OUT NOCOPY okl_pamv_rec,
                        x_pal_rec       OUT NOCOPY okl_pal_rec
                        ) IS

l_pamv_rec      okl_pamv_rec := p_pamv_rec;
l_pal_rec       okl_pal_rec := p_pal_rec;
l_api_version   NUMBER := 1.0;
l_api_name      VARCHAR2(40):='INSERT_ADJ_MAT';
l_init_msg_list VARCHAR2(1):=p_init_msg_list;
l_return_status VARCHAR2(1):=OKL_API.G_RET_STS_SUCCESS;
l_dummy_var     VARCHAR2(1):='?';

CURSOR pam_unique_chk(p_name  IN  varchar2) IS
      SELECT 'x'
      FROM   okl_fe_adj_mat_v
      WHERE  adj_mat_name = p_name;

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

OPEN pam_unique_chk(l_pamv_rec.adj_mat_name);
FETCH pam_unique_chk INTO l_dummy_var ;
CLOSE pam_unique_chk;

-- if l_dummy_var is 'x' then name already exists

IF (l_dummy_var = 'x') THEN
   okl_api.set_message(p_app_name     =>  g_app_name
                         ,p_msg_name     =>  'OKL_DUPLICATE_NAME'
                         ,p_token1       =>  'NAME'
                         ,p_token1_value =>  l_pamv_rec.adj_mat_name);
    RAISE okl_api.g_exception_error;
END IF;
-- fix for gmiss date
l_pal_rec.effective_to_date := rosetta_g_miss_date_in_map(l_pal_rec.effective_to_date);
-- setting the header attributes
l_pamv_rec.STS_CODE := 'NEW';
l_pamv_rec.EFFECTIVE_FROM_DATE := l_pal_rec.EFFECTIVE_FROM_DATE;
l_pamv_rec.EFFECTIVE_TO_DATE := l_pal_rec.EFFECTIVE_TO_DATE;

-- insert the header record into the table
okl_pam_pvt.insert_row(   l_api_version
                         ,l_init_msg_list
                         ,l_return_status
                         ,x_msg_count
                         ,x_msg_data
                         ,l_pamv_rec
                         ,x_pamv_rec);

IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
END IF;

-- setting the version attributes
l_pal_rec.STS_CODE := 'NEW';
l_pal_rec.VERSION_NUMBER:=1.0;
l_pal_rec.ADJ_MAT_ID := x_pamv_rec.ADJ_MAT_ID;

-- insert the version record into the table
okl_pal_pvt.insert_row(   l_api_version
                         ,l_init_msg_list
                         ,l_return_status
                         ,x_msg_count
                         ,x_msg_data
                         ,l_pal_rec
                         ,x_pal_rec);

IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
END IF;

--end activity
OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
x_return_status := l_return_status;

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
        x_return_status := OKL_API.HANDLE_EXCEPTIONS
          (
              l_api_name,
              G_PKG_NAME,
              'OKL_API.G_RET_STS_UNEXP_ERROR',
              x_msg_count,
              x_msg_data,
              '_PVT'
          );

  WHEN OTHERS THEN
        x_return_status := OKL_API.HANDLE_EXCEPTIONS
          (
              l_api_name,
              G_PKG_NAME,
              'OTHERS',
              x_msg_count,
              x_msg_data,
              '_PVT'
         );
END INSERT_ADJ_MAT;

-- procedure to update a particular version of the Pricing Adjustment matrix
PROCEDURE UPDATE_ADJ_MAT(
                        p_api_version   IN  NUMBER,
                        p_init_msg_list IN  VARCHAR2 DEFAULT okl_api.g_false,
                        x_return_status OUT NOCOPY VARCHAR2,
                        x_msg_count     OUT NOCOPY NUMBER,
                        x_msg_data      OUT NOCOPY VARCHAR2,
                        p_pal_rec       IN  okl_pal_rec,
                        x_pal_rec       OUT NOCOPY okl_pal_rec
                        ) IS

l_pamv_rec      okl_pamv_rec;
x_pamv_rec      okl_pamv_rec;
l_pal_rec       okl_pal_rec := p_pal_rec;
l_api_version   NUMBER := 1.0;
l_api_name      VARCHAR2(40):='UPDATE_ADJ_MAT';
l_init_msg_list VARCHAR2(1):=p_init_msg_list;
l_return_status VARCHAR2(1):=OKL_API.G_RET_STS_SUCCESS;
l_eff_from      DATE;
l_eff_to        DATE;
l_max_date      DATE;
k               NUMBER :=1;
l               NUMBER :=1;
lp_lrtv_tbl     okl_lrs_id_tbl;
lp_srtv_tbl     okl_srt_id_tbl;
x_obj_tbl       invalid_object_tbl;
l_cal_end_date  DATE;

-- cursor to fetch the previous version effective from and the previous version effective to
CURSOR prev_ver_csr(l_adj_mat_id IN NUMBER, l_version_number IN VARCHAR2) IS
SELECT effective_from_date, effective_to_date
FROM okl_fe_adj_mat_versions
WHERE adj_mat_id= l_adj_mat_id AND version_number=l_version_number -1;

CURSOR get_elig_crit_start_date(p_version_id IN NUMBER) IS
SELECT max(effective_from_date)
FROM   okl_fe_criteria_set ech
      ,okl_fe_criteria ecl
WHERE  ecl.criteria_set_id = ech.criteria_set_id
AND ech.source_id = p_version_id AND source_object_code = 'PAM';
BEGIN
l_return_status := OKL_API.START_ACTIVITY(l_api_name,
                            G_PKG_NAME,
                            l_init_msg_list,
                            l_api_version,
                            p_api_version,
                            '_PVT',
                            x_return_status);

IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
END IF;

-- fix for gmiss date
l_pal_rec.effective_to_date := rosetta_g_miss_date_in_map(l_pal_rec.effective_to_date);

OPEN prev_ver_csr(l_pal_rec.adj_mat_id, l_pal_rec.version_number);
FETCH prev_ver_csr INTO l_eff_from, l_eff_to;
CLOSE prev_ver_csr;

IF (l_eff_to is not null AND l_pal_rec.effective_from_date < l_eff_to) THEN
    RAISE G_INVALID_ADJ_CAT_DATES;
END IF;
IF (l_pal_rec.effective_from_date<= l_eff_from) THEN
    RAISE G_INVALID_ADJ_CAT_DATES;
END IF;

-- If the status is active only the effective date can be updated.
IF (l_pal_rec.STS_CODE = 'ACTIVE') THEN

    l_pamv_rec.ADJ_MAT_ID := l_pal_rec.ADJ_MAT_ID;
    IF (l_pal_rec.EFFECTIVE_TO_DATE is not null) THEN
        l_pamv_rec.EFFECTIVE_TO_DATE := l_pal_rec.EFFECTIVE_TO_DATE;
    ELSE
        l_pamv_rec.EFFECTIVE_TO_DATE :=OKL_API.G_MISS_DATE;
    END IF;
    -- have to check if this effective to date > referenced end dates.
    -- update the header record
    okl_pam_pvt.update_row(l_api_version
                         ,l_init_msg_list
                         ,l_return_status
                         ,x_msg_count
                         ,x_msg_data
                         ,l_pamv_rec
                         ,x_pamv_rec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    IF (l_pal_rec.effective_to_date IS NOT NULL) THEN
               -- check whether the effective to date is greater than the maximum effective from that has been calculated.
               calc_start_date(
                  p_api_version   ,
                  p_init_msg_list ,
                  x_return_status ,
                  x_msg_count     ,
                  x_msg_data      ,
                  l_pal_rec       ,
                  l_cal_end_date );

               IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                 RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
               ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
                 RAISE OKL_API.G_EXCEPTION_ERROR;
               END IF;

               OPEN get_elig_crit_start_date(l_pal_rec.adj_mat_version_id);
               FETCH get_elig_crit_start_date INTO l_max_date;
               CLOSE get_elig_crit_start_date;

               IF(l_max_date > (l_cal_end_date-1)) THEN
                 l_cal_end_date:= l_max_date +1;
               END IF;
               IF (l_pal_rec.effective_to_date < (l_cal_end_date-1) ) THEN
                  okl_api.set_message(
                            p_app_name     =>  g_app_name
                           ,p_msg_name     =>  'OKL_INVALID_EFFECTIVE_TO_DATE'
                           ,p_token1       =>  'DATE'
                           ,p_token1_value =>  l_cal_end_date-1);
                  RAISE okl_api.g_exception_error;
               END IF;

                -- put an end date to the previous version of the eligibility criteria
               okl_ecc_values_pvt.end_date_eligibility_criteria(
                         p_api_version   => l_api_version,
                         p_init_msg_list => p_init_msg_list,
                         x_return_status => x_return_status,
                         x_msg_count     => x_msg_count,
                         x_msg_data      => x_msg_data,
                         p_source_id     => l_pal_rec.adj_mat_version_id,
                         p_source_type   => 'PAM',
                         p_end_date      =>  l_pal_rec.effective_to_date
                        );
              -- end date the lease rate set versions
              INVALID_OBJECTS(
                        p_api_version   ,
                        p_init_msg_list ,
                        x_return_status ,
                        x_msg_count     ,
                        x_msg_data      ,
                        l_pal_rec.adj_mat_version_id,
                        x_obj_tbl
                        );
            if (x_obj_tbl.count>0) then

                FOR j IN x_obj_tbl.FIRST..x_obj_tbl.LAST LOOP
                  IF (x_obj_tbl(j).OBJ_TYPE = 'LRS') THEN
                   lp_lrtv_tbl(k) := x_obj_tbl(j).obj_id;
                   k:=k+1;
                  ELSIF (x_obj_tbl(j).OBJ_TYPE = 'SRT') THEN
                   lp_srtv_tbl(l) := x_obj_tbl(j).obj_id;
                   l:=l+1;
                  END IF;
                END LOOP;

            IF (k>1) THEN
              okl_lease_rate_Sets_pvt.enddate_lease_rate_set(
               p_api_version
              ,p_init_msg_list
              ,x_return_status
              ,x_msg_count
              ,x_msg_data
              ,lp_lrtv_tbl
              ,l_pal_rec.effective_to_date
              );
              IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
              ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_ERROR;
              END IF;
            END IF;
            IF (l>1) THEN
              OKL_FE_STD_RATE_TMPL_PVT.enddate_std_rate_tmpl(
               p_api_version
              ,p_init_msg_list
              ,x_return_status
              ,x_msg_count
              ,x_msg_data
              ,lp_srtv_tbl
              ,l_pal_rec.effective_to_date
              );
              IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
              ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_ERROR;
              END IF;
            END IF;
          END IF;
         END IF;
    -- update the version record
    okl_pal_pvt.update_row(   l_api_version
                             ,l_init_msg_list
                             ,l_return_status
                             ,x_msg_count
                             ,x_msg_data
                             ,l_pal_rec
                             ,x_pal_rec);

    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

ELSE

    -- update the version record
    okl_pal_pvt.update_row(   l_api_version
                             ,l_init_msg_list
                             ,l_return_status
                             ,x_msg_count
                             ,x_msg_data
                             ,l_pal_rec
                             ,x_pal_rec);

    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;


END IF;



--end activity
OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
x_return_status := l_return_status;

EXCEPTION
  WHEN G_INVALID_ADJ_CAT_DATES THEN
        OKL_API.SET_MESSAGE( p_app_name     => g_app_name,
                            p_msg_name     => g_invalid_value,
                            p_token1       => g_col_name_token,
                            p_token1_value => 'effective_from ');
        x_return_status := OKL_API.HANDLE_EXCEPTIONS
          (
              l_api_name,
              G_PKG_NAME,
              'OKL_API.G_RET_STS_ERROR',
              x_msg_count,
              x_msg_data,
              '_PVT'
          );
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
        x_return_status := OKL_API.HANDLE_EXCEPTIONS
          (
              l_api_name,
              G_PKG_NAME,
              'OKL_API.G_RET_STS_UNEXP_ERROR',
              x_msg_count,
              x_msg_data,
              '_PVT'
          );

  WHEN OTHERS THEN
        x_return_status := OKL_API.HANDLE_EXCEPTIONS
          (
              l_api_name,
              G_PKG_NAME,
              'OTHERS',
              x_msg_count,
              x_msg_data,
              '_PVT'
         );

END UPDATE_ADJ_MAT;

-- procedure to create a new version of the Pricing Adjustment Matrix
PROCEDURE CREATE_VERSION(
                        p_api_version   IN  NUMBER,
                        p_init_msg_list IN  VARCHAR2 DEFAULT okl_api.g_false,
                        x_return_status OUT NOCOPY VARCHAR2,
                        x_msg_count     OUT NOCOPY NUMBER,
                        x_msg_data      OUT NOCOPY VARCHAR2,
                        p_pal_rec       IN  okl_pal_rec,
                        x_pal_rec       OUT NOCOPY okl_pal_rec
                        ) IS

l_pamv_rec      okl_pamv_rec;
x_pamv_rec      okl_pamv_rec;
l_pal_rec       okl_pal_rec := p_pal_rec;
l_api_version   NUMBER := 1.0;
l_api_name      VARCHAR2(40):='UPDATE_ADJ_MAT';
l_init_msg_list VARCHAR2(1):=p_init_msg_list;
l_return_status VARCHAR2(1):=OKL_API.G_RET_STS_SUCCESS;
cal_eff_from    DATE;

BEGIN
l_return_status := OKL_API.START_ACTIVITY(l_api_name,
                            G_PKG_NAME,
                            l_init_msg_list,
                            l_api_version,
                            p_api_version,
                            '_PVT',
                            x_return_status);

IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
END IF;

-- fix for gmiss date
l_pal_rec.effective_to_date := rosetta_g_miss_date_in_map(l_pal_rec.effective_to_date);

-- change the status of the header as under revision
l_pamv_rec.ADJ_MAT_ID := l_pal_rec.ADJ_MAT_ID;
l_pamv_rec.STS_CODE := 'UNDER_REVISION';

-- update the header record
okl_pam_pvt.update_row(l_api_version
                      ,l_init_msg_list
                      ,l_return_status
                      ,x_msg_count
                      ,x_msg_data
                      ,l_pamv_rec
                      ,x_pamv_rec);

-- logic to be added. Check if user entered start date > the calculated start date
-- else raise an exception
calc_start_date(  l_api_version
                 ,l_init_msg_list
                 ,l_return_status
                 ,x_msg_count
                 ,x_msg_data
                 ,l_pal_rec
                 ,cal_eff_from);

IF ( l_pal_rec.effective_from_date < cal_eff_from ) THEN
    RAISE G_INVALID_ADJ_CAT_DATES;
END IF;
-- insert the version record into the table
okl_pal_pvt.insert_row(   l_api_version
                         ,l_init_msg_list
                         ,l_return_status
                         ,x_msg_count
                         ,x_msg_data
                         ,l_pal_rec
                         ,x_pal_rec);
IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
END IF;


--end activity
OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
x_return_status := l_return_status;

EXCEPTION
  WHEN G_INVALID_ADJ_CAT_DATES THEN
        OKL_API.SET_MESSAGE( p_app_name     => g_app_name,
                            p_msg_name     => 'OKL_INVALID_EFF_FROM',
                            p_token1       => 'DATE',
                            p_token1_value => cal_eff_from);
        x_return_status := OKL_API.HANDLE_EXCEPTIONS
          (
              l_api_name,
              G_PKG_NAME,
              'OKL_API.G_RET_STS_ERROR',
              x_msg_count,
              x_msg_data,
              '_PVT'
          );
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
        x_return_status := OKL_API.HANDLE_EXCEPTIONS
          (
              l_api_name,
              G_PKG_NAME,
              'OKL_API.G_RET_STS_UNEXP_ERROR',
              x_msg_count,
              x_msg_data,
              '_PVT'
          );

  WHEN OTHERS THEN
        x_return_status := OKL_API.HANDLE_EXCEPTIONS
          (
              l_api_name,
              G_PKG_NAME,
              'OTHERS',
              x_msg_count,
              x_msg_data,
              '_PVT'
         );

END CREATE_VERSION;

-- procedure to raise the workflow which submits the record and changes the status.
PROCEDURE SUBMIT_ADJ_MAT(
                        p_api_version   IN  NUMBER,
                        p_init_msg_list IN  VARCHAR2 DEFAULT okl_api.g_false,
                        x_return_status OUT NOCOPY VARCHAR2,
                        x_msg_count     OUT NOCOPY NUMBER,
                        x_msg_data      OUT NOCOPY VARCHAR2,
                        p_version_id    IN  NUMBER
                        ) IS

l_pal_rec       okl_pal_rec;
x_pal_rec       okl_pal_rec;
l_api_version   NUMBER := 1.0;
l_api_name      VARCHAR2(40):='UPDATE_ADJ_MAT';
l_init_msg_list VARCHAR2(1):=p_init_msg_list;
l_return_status VARCHAR2(1):=OKL_API.G_RET_STS_SUCCESS;
l_parameter_list        wf_parameter_list_t;
p_event_name     varchar2(240):='oracle.apps.okl.fe.pamapproval';
l_profile_value  VARCHAR2(30);

BEGIN
l_return_status := OKL_API.START_ACTIVITY(l_api_name,
                            G_PKG_NAME,
                            l_init_msg_list,
                            l_api_version,
                            p_api_version,
                            '_PVT',
                            x_return_status);

IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
END IF;

l_pal_rec.ADJ_MAT_VERSION_ID := p_version_id;
l_pal_rec.STS_CODE := 'SUBMITTED';

okl_pal_pvt.update_row(   l_api_version
                          ,p_init_msg_list
                          ,l_return_status
                          ,x_msg_count
                          ,x_msg_data
                          ,l_pal_rec
                          ,x_pal_rec);

IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
END IF;
fnd_profile.get('OKL_PE_APPROVAL_PROCESS',l_profile_value);

 IF (nvl(l_profile_value,'NONE') = 'NONE') THEN

HANDLE_APPROVAL(
                p_api_version   => l_api_version,
                p_init_msg_list => p_init_msg_list,
                x_return_status => l_return_status,
                x_msg_count     => x_msg_count,
                x_msg_data      => x_msg_data,
                p_version_id    => p_version_id
                );

ELSE
-- raise the business event passing the version id added to the parameter list
wf_event.AddParameterToList('VERSION_ID',p_version_id,l_parameter_list);
--added by akrangan
wf_event.AddParameterToList('ORG_ID',mo_global.get_current_org_id ,l_parameter_list);

OKL_WF_PVT.raise_event (p_api_version    => p_api_version,
			    p_init_msg_list  => p_init_msg_list,
			    x_return_status  => x_return_status,
			    x_msg_count      => x_msg_count,
			    x_msg_data       => x_msg_data,
			    p_event_name     => p_event_name,
			    p_parameters     => l_parameter_list);


END IF;

--end activity
OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
x_return_status := l_return_status;

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
        x_return_status := OKL_API.HANDLE_EXCEPTIONS
          (
              l_api_name,
              G_PKG_NAME,
              'OKL_API.G_RET_STS_UNEXP_ERROR',
              x_msg_count,
              x_msg_data,
              '_PVT'
          );

  WHEN OTHERS THEN
        x_return_status := OKL_API.HANDLE_EXCEPTIONS
          (
              l_api_name,
              G_PKG_NAME,
              'OTHERS',
              x_msg_count,
              x_msg_data,
              '_PVT'
         );
END SUBMIT_ADJ_MAT ;


-- procedure to handle when the process is going through the process of approval
PROCEDURE HANDLE_APPROVAL(
                        p_api_version   IN  NUMBER,
                        p_init_msg_list IN  VARCHAR2 DEFAULT okl_api.g_false,
                        x_return_status OUT NOCOPY VARCHAR2,
                        x_msg_count     OUT NOCOPY NUMBER,
                        x_msg_data      OUT NOCOPY VARCHAR2,
                        p_version_id    IN  NUMBER
                        ) IS
CURSOR adj_mat_version_csr(p_version_id IN NUMBER)IS
SELECT ADJ_MAT_ID,
       VERSION_NUMBER,
       EFFECTIVE_FROM_DATE,
       EFFECTIVE_TO_DATE
       FROM okl_fe_adj_mat_versions
WHERE ADJ_MAT_VERSION_ID = p_version_id;

CURSOR ver_eff_to_csr(p_adj_mat_id IN NUMBER, p_version_number IN NUMBER)IS
SELECT  ADJ_MAT_VERSION_ID,
        EFFECTIVE_TO_DATE FROM okl_fe_adj_mat_versions
WHERE ADJ_MAT_ID=p_adj_mat_id and VERSION_NUMBER = p_version_number;

CURSOR max_version_csr(p_adj_mat_id IN NUMBER) IS
SELECT max(VERSION_NUMBER) FROM OKL_FE_ADJ_MAT_VERSIONS
WHERE ADJ_MAT_ID = p_adj_mat_id;


CURSOR cal_end_date(p_version_id IN NUMBER) IS
select max(effective_from_date) from okl_fe_std_rt_tmp_vers
where adj_mat_version_id=p_version_id;

l_adj_mat_id     NUMBER;
l_adj_mat_ver_id NUMBER;
l_version_number NUMBER;
l_effective_from DATE;
l_effective_to   DATE;
l_eff_prev_ver   DATE;
l_pamv_rec       okl_pamv_rec;
x_pamv_rec       okl_pamv_rec;
l_pal_rec        okl_pal_rec;
lp_pal_rec	 okl_pal_rec;
x_pal_rec        okl_pal_rec;
l_max_version   VARCHAR2(24);
l_cal_end_date  DATE;
l_end_date      DATE;
l_api_version   NUMBER := 1.0;
l_api_name      VARCHAR2(40):='handle_approval';
k               NUMBER :=1;
l               NUMBER :=1;
lp_lrtv_tbl     okl_lrs_id_tbl;
lp_srtv_tbl     okl_srt_id_tbl;
x_obj_tbl       invalid_object_tbl;
BEGIN
    x_return_status := OKL_API.START_ACTIVITY(l_api_name,
                            G_PKG_NAME,
                            p_init_msg_list,
                            l_api_version,
                            p_api_version,
                            '_PVT',
                            x_return_status);

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
 -- if it is the first version,
 -- change the header status and the end date of the header as the version end date
 -- change the version status to active
 -- if it has already some versions,
 -- then end_date the previous versions
 -- then end date the reference of the previous version
    OPEN adj_mat_version_csr(p_version_id);
    FETCH adj_mat_version_csr INTO l_adj_mat_id,l_version_number,l_effective_from,l_effective_to;
    CLOSE adj_mat_version_csr;

    OPEN max_version_csr(l_adj_mat_id);
    FETCH max_version_csr INTO l_max_version;
    CLOSE max_version_csr;

    -- set the properties of the versions record
    lp_pal_rec.STS_CODE:='ACTIVE';
    lp_pal_rec.ADJ_MAT_VERSION_ID:= p_version_id;
    lp_pal_rec.ADJ_MAT_ID:= l_adj_mat_id;
    lp_pal_rec.VERSION_NUMBER:= l_version_number;
    lp_pal_rec.EFFECTIVE_FROM_DATE:=l_effective_from;

    IF (l_version_number = 1) THEN
        l_pamv_rec.ADJ_MAT_ID:= l_adj_mat_id;
        l_pamv_rec.STS_CODE := 'ACTIVE';
        IF (l_effective_to IS NOT NULL) THEN
          l_pamv_rec.EFFECTIVE_TO_DATE :=l_effective_to;
        ELSE
          l_pamv_rec.EFFECTIVE_TO_DATE:= OKL_API.G_MISS_DATE;
        END IF;
    ELSIF (l_version_number < l_max_version) THEN
        -- only the last but one version can be updated in the case of Adjustment Matrix

        l_pamv_rec.ADJ_MAT_ID := l_adj_mat_id;
        IF (l_effective_to IS NOT NULL) THEN
          l_pamv_rec.EFFECTIVE_TO_DATE := l_effective_to;
        ELSE
          l_pamv_rec.EFFECTIVE_TO_DATE:= OKL_API.G_MISS_DATE;
        END IF;
        l_end_date:= l_effective_to;
    ELSIF (l_version_number = l_max_version) THEN

        -- get the previous version Effective To
        OPEN ver_eff_to_csr(l_adj_mat_id, l_version_number-1);
        FETCH ver_eff_to_csr INTO l_adj_mat_ver_id,l_eff_prev_ver;
        CLOSE ver_eff_to_csr;

        lp_pal_rec.ADJ_MAT_VERSION_ID:= l_adj_mat_ver_id;
        calc_start_date(
                     p_api_version   ,
                     p_init_msg_list ,
                     x_return_status ,
                     x_msg_count     ,
                     x_msg_data      ,
                     lp_pal_rec       ,
                     l_cal_end_date );

       IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
         raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) then
         raise OKL_API.G_EXCEPTION_ERROR;
       END IF;

       IF (lp_pal_rec.effective_from_date < l_cal_end_date ) THEN
          RAISE okl_api.g_exception_error;
       END IF;

       l_cal_end_date:= lp_pal_rec.effective_from_date -1;

        l_pamv_rec.ADJ_MAT_ID := l_adj_mat_id;
        l_pamv_rec.STS_CODE:= 'ACTIVE';
        IF (l_effective_to IS NOT NULL) THEN
          l_pamv_rec.EFFECTIVE_TO_DATE := l_effective_to;
        ELSE
          l_pamv_rec.EFFECTIVE_TO_DATE:= OKL_API.G_MISS_DATE;
        END IF;

        -- update the previous version effective to
        IF (nvl(l_eff_prev_ver,okl_api.g_miss_date) <> l_cal_end_date) THEN

            l_pal_rec.ADJ_MAT_VERSION_ID :=l_adj_mat_ver_id;
            l_pal_rec.EFFECTIVE_TO_DATE := l_cal_end_date;
            okl_pal_pvt.update_row(   l_api_version
                             ,p_init_msg_list
                             ,x_return_status
                             ,x_msg_count
                             ,x_msg_data
                             ,l_pal_rec
                             ,x_pal_rec);

            IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;
           -- put an end date to the previous version of the eligibility criteria
           okl_ecc_values_pvt.end_date_eligibility_criteria(
                         p_api_version   => l_api_version,
                         p_init_msg_list => p_init_msg_list,
                         x_return_status => x_return_status,
                         x_msg_count     => x_msg_count,
                         x_msg_data      => x_msg_data,
                         p_source_id     => l_adj_mat_ver_id,
                         p_source_type   => 'PAM',
                         p_end_date      =>  l_cal_end_date
                        );

        END IF;
         IF (l_cal_end_date IS NOT NULL) THEN
              -- end date the lease rate set versions
              INVALID_OBJECTS(
                        p_api_version   ,
                        p_init_msg_list ,
                        x_return_status ,
                        x_msg_count     ,
                        x_msg_data      ,
                        l_adj_mat_ver_id,
                        x_obj_tbl
                        );

            IF (x_obj_tbl.COUNT > 0) THEN
            -- populate the ids
                FOR j IN x_obj_tbl.FIRST..x_obj_tbl.LAST LOOP
                  IF (x_obj_tbl(j).OBJ_TYPE = 'LRS') THEN
                   lp_lrtv_tbl(k) := x_obj_tbl(j).obj_id;
                   k:=k+1;
                  ELSIF (x_obj_tbl(j).OBJ_TYPE = 'SRT') THEN
                   lp_srtv_tbl(l) := x_obj_tbl(j).obj_id;
                   l:=l+1;
                  END IF;
                END LOOP;
            IF (k>1) THEN
              -- end date the referenced lease rate set
              okl_lease_rate_Sets_pvt.enddate_lease_rate_set(
               p_api_version
              ,p_init_msg_list
              ,x_return_status
              ,x_msg_count
              ,x_msg_data
              ,lp_lrtv_tbl
              ,l_cal_end_date
              );
            ENd IF;
            IF (l>1) THEN
              -- end date the referenced Standard Rate Template
              OKL_FE_STD_RATE_TMPL_PVT.enddate_std_rate_tmpl(
               p_api_version
              ,p_init_msg_list
              ,x_return_status
              ,x_msg_count
              ,x_msg_data
              ,lp_srtv_tbl
              ,l_cal_end_date
              );
            END IF;
           END IF;
        END IF;

    END IF;
    --make the version status as active
    l_pal_rec.ADJ_MAT_VERSION_ID := p_version_id;
    l_pal_rec.STS_CODE           := 'ACTIVE';
    l_pal_rec.EFFECTIVE_TO_DATE:=null;
    okl_pal_pvt.update_row(   l_api_version
                             ,p_init_msg_list
                             ,x_return_status
                             ,x_msg_count
                             ,x_msg_data
                             ,l_pal_rec
                             ,x_pal_rec);


    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    okl_pam_pvt.update_row(   l_api_version
                             ,p_init_msg_list
                             ,x_return_status
                             ,x_msg_count
                             ,x_msg_data
                             ,l_pamv_rec
                             ,x_pamv_rec);

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;


--end activity
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
        x_return_status := OKL_API.HANDLE_EXCEPTIONS
          (
              l_api_name,
              G_PKG_NAME,
              'OKL_API.G_RET_STS_UNEXP_ERROR',
              x_msg_count,
              x_msg_data,
              '_PVT'
          );

  WHEN OTHERS THEN
        IF adj_mat_version_csr%ISOPEN THEN
            CLOSE adj_mat_version_csr;
        END IF;
        x_return_status := OKL_API.HANDLE_EXCEPTIONS
          (
              l_api_name,
              G_PKG_NAME,
              'OTHERS',
              x_msg_count,
              x_msg_data,
              '_PVT'
         );
END HANDLE_APPROVAL;


PROCEDURE INVALID_OBJECTS(
                        p_api_version   IN  NUMBER,
                        p_init_msg_list IN  VARCHAR2 DEFAULT okl_api.g_false,
                        x_return_status OUT NOCOPY VARCHAR2,
                        x_msg_count     OUT NOCOPY NUMBER,
                        x_msg_data      OUT NOCOPY VARCHAR2,
                        p_version_id    IN  NUMBER,
                        x_obj_tbl       OUT NOCOPY invalid_object_tbl
                        ) AS
l_version_id NUMBER :=p_version_id;
i            NUMBER:=1;
l_api_version   NUMBER := 1.0;
l_api_name      VARCHAR2(40):='invalid_objects';
l_return_status VARCHAR2(1):= OKL_API.G_RET_STS_SUCCESS;

-- cursor to calculate the  SRT objects which are referncing this adjustment matrix

CURSOR srt_invalids_csr(p_version_id IN NUMBER) IS
SELECT vers.std_rate_tmpl_ver_id ID,hdr.template_name NAME ,vers.version_number VERSION_NUMBER
FROM okl_fe_std_rt_tmp_vers vers, okl_fe_std_rt_tmp_v hdr
WHERE vers.std_rate_tmpl_id = hdr.std_rate_tmpl_id AND vers.adj_mat_version_id=p_version_id
AND vers.STS_CODE='ACTIVE';

-- cursor to calculate the  LRS objects which are referncing this adjustment matrix

CURSOR lrs_invalids_csr(p_version_id IN NUMBER) IS
SELECT vers.RATE_SET_VERSION_ID ID,hdr.name NAME,vers.version_number VERSION_NUMBER
FROM OKL_FE_RATE_SET_VERSIONS vers, OKL_LS_RT_FCTR_SETS_V hdr
WHERE  vers.rate_set_id = hdr.id AND vers.adj_mat_version_id=p_version_id
AND vers.STS_CODE='ACTIVE';

-- cursor to calculate the LRS invalid for the invalid SRTs
CURSOR lrs_srt_invalids_csr(p_version_id IN NUMBER) IS
SELECT vers.rate_set_version_id id
      ,hdr.name name
      ,vers.version_number version_number
FROM   okl_fe_rate_set_versions vers
      ,okl_ls_rt_fctr_sets_v hdr
WHERE  vers.rate_set_id = hdr.id
AND vers.std_rate_tmpl_ver_id = p_version_id
AND vers.sts_code = 'ACTIVE';

BEGIN
x_return_status := OKL_API.START_ACTIVITY(l_api_name,
                            G_PKG_NAME,
                            p_init_msg_list,
                            l_api_version,
                            p_api_version,
                            '_PVT',
                            x_return_status);

FOR srt_invalid_record IN srt_invalids_csr(p_version_id) LOOP
    x_obj_tbl(i).obj_id:=srt_invalid_record.ID;
    x_obj_tbl(i).obj_name:=srt_invalid_record.NAME;
    x_obj_tbl(i).obj_version :=srt_invalid_record.VERSION_NUMBER;
    x_obj_tbl(i).obj_type:='SRT';
    i:=i+1;
    -- invalid LRS for this SRT
    FOR lrs_srt_invalid_record IN lrs_srt_invalids_csr(srt_invalid_record.ID) LOOP
      x_obj_tbl(i).obj_id:=lrs_srt_invalid_record.ID;
      x_obj_tbl(i).obj_name:=lrs_srt_invalid_record.NAME;
      x_obj_tbl(i).obj_version :=lrs_srt_invalid_record.VERSION_NUMBER;
      x_obj_tbl(i).obj_type:='LRS';
      i:=i+1;
    END LOOP;
END LOOP;

FOR lrs_invalid_record IN lrs_invalids_csr(p_version_id) LOOP
    x_obj_tbl(i).obj_id:=lrs_invalid_record.ID;
    x_obj_tbl(i).obj_name:=lrs_invalid_record.NAME;
    x_obj_tbl(i).obj_version :=lrs_invalid_record.VERSION_NUMBER;
    x_obj_tbl(i).obj_type:='LRS';
    i:=i+1;
END LOOP;

--end activity
OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
x_return_status := l_return_status;


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
        x_return_status := OKL_API.HANDLE_EXCEPTIONS
          (
              l_api_name,
              G_PKG_NAME,
              'OKL_API.G_RET_STS_UNEXP_ERROR',
              x_msg_count,
              x_msg_data,
              '_PVT'
          );

  WHEN OTHERS THEN
        x_return_status := OKL_API.HANDLE_EXCEPTIONS
          (
              l_api_name,
              G_PKG_NAME,
              'OTHERS',
              x_msg_count,
              x_msg_data,
              '_PVT'
         );
END INVALID_OBJECTS;

END OKL_FE_ADJ_MATRIX_PVT;

/
