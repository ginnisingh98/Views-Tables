--------------------------------------------------------
--  DDL for Package Body OKL_FE_STD_RATE_TMPL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_FE_STD_RATE_TMPL_PVT" AS
/* $Header: OKLRSRTB.pls 120.11 2006/07/21 13:15:15 akrangan noship $ */

  --------------------------------------------------------------------------------
  --PACKAGE CONSTANTS
  --------------------------------------------------------------------------------

  g_db_error           CONSTANT VARCHAR2(12)  := 'OKL_DB_ERROR';
  g_prog_name_token    CONSTANT VARCHAR2(9)   := 'PROG_NAME';
  g_no_parent_record   CONSTANT VARCHAR2(200) := 'OKC_NO_PARENT_RECORD';
  g_unexpected_error   CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UNEXPECTED_ERROR';
  g_sqlerrm_token      CONSTANT VARCHAR2(200) := 'SQLerrm';
  g_sqlcode_token      CONSTANT VARCHAR2(200) := 'SQLcode';
  g_exception_halt_validation EXCEPTION;
  g_invalid_adj_cat_dates     EXCEPTION;
  g_exception_cannot_update   EXCEPTION;
  g_invalid_start_date        EXCEPTION;
  rosetta_g_mistake_date       DATE := TO_DATE('01/01/-4711'
                                        ,'MM/DD/SYYYY');
  rosetta_g_miss_date          DATE := TO_DATE('01/01/-4712'
                                     ,'MM/DD/SYYYY');

  -- this is to workaround the JDBC bug regarding IN DATE of value GMiss

  FUNCTION rosetta_g_miss_date_in_map(d DATE) RETURN DATE AS

  BEGIN

    IF d = rosetta_g_mistake_date THEN
      RETURN fnd_api.g_miss_date;
    END IF;
    RETURN d;
  END;

  PROCEDURE get_std_rate_tmpl(p_api_version    IN            NUMBER
                             ,p_init_msg_list  IN            VARCHAR2     DEFAULT okl_api.g_false
                             ,x_return_status     OUT NOCOPY VARCHAR2
                             ,x_msg_count         OUT NOCOPY NUMBER
                             ,x_msg_data          OUT NOCOPY VARCHAR2
                             ,p_srt_id         IN            NUMBER
                             ,p_version_number IN            NUMBER
                             ,x_srtv_rec          OUT NOCOPY okl_srtv_rec
                             ,x_srv_rec           OUT NOCOPY okl_srv_rec) IS

    -- cursor to fetch the header record

    CURSOR srt_hdr_csr(p_srt_id IN NUMBER) IS
      SELECT std_rate_tmpl_id
            ,template_name
            ,template_desc
            ,object_version_number
            ,org_id
            ,currency_code
            ,rate_card_yn
            ,default_yn
            ,pricing_engine_code
            ,orig_std_rate_tmpl_id
            ,frequency_code
            ,rate_type_code
            ,index_id
            ,sts_code
            ,effective_from_date
            ,effective_to_date
            ,srt_rate
            ,attribute_category
            ,attribute1
            ,attribute2
            ,attribute3
            ,attribute4
            ,attribute5
            ,attribute6
            ,attribute7
            ,attribute8
            ,attribute9
            ,attribute10
            ,attribute11
            ,attribute12
            ,attribute13
            ,attribute14
            ,attribute15
            ,created_by
            ,creation_date
            ,last_updated_by
            ,last_update_date
            ,last_update_login
      FROM   okl_fe_std_rt_tmp_v
      WHERE  std_rate_tmpl_id = p_srt_id;

    -- cursor to fetch the versions record

    CURSOR srt_version_csr(p_srt_id         IN NUMBER
                          ,p_version_number IN VARCHAR2) IS
      SELECT std_rate_tmpl_ver_id
            ,version_number
            ,object_version_number
            ,std_rate_tmpl_id
            ,sts_code
            ,effective_from_date
            ,effective_to_date
            ,adj_mat_version_id
            ,srt_rate
            ,spread
            ,day_convention_code
            ,min_adj_rate
            ,max_adj_rate
            ,attribute_category
            ,attribute1
            ,attribute2
            ,attribute3
            ,attribute4
            ,attribute5
            ,attribute6
            ,attribute7
            ,attribute8
            ,attribute9
            ,attribute10
            ,attribute11
            ,attribute12
            ,attribute13
            ,attribute14
            ,attribute15
            ,created_by
            ,creation_date
            ,last_updated_by
            ,last_update_date
            ,last_update_login
      FROM   okl_fe_std_rt_tmp_vers
      WHERE  std_rate_tmpl_id = p_srt_id AND version_number = p_version_number;
    l_api_name                   VARCHAR2(40) := 'get_std_rate_tmpl';
    l_api_version                NUMBER       := 1.0;

  BEGIN
    x_return_status := okl_api.start_activity(l_api_name
                                             ,g_pkg_name
                                             ,p_init_msg_list
                                             ,l_api_version
                                             ,p_api_version
                                             ,'_PVT'
                                             ,x_return_status);

    -- populate the header record

    OPEN srt_hdr_csr(p_srt_id);
    FETCH srt_hdr_csr INTO x_srtv_rec ;
    CLOSE srt_hdr_csr;

    -- populate the header record

    OPEN srt_version_csr(p_srt_id
                        ,p_version_number);
    FETCH srt_version_csr INTO x_srv_rec ;
    CLOSE srt_version_csr;

    --end activity

    okl_api.end_activity(x_msg_count
                        ,x_msg_data);
    EXCEPTION
      WHEN OTHERS THEN
        x_return_status := okl_api.handle_exceptions(l_api_name
                                                    ,g_pkg_name
                                                    ,'OTHERS'
                                                    ,x_msg_count
                                                    ,x_msg_data
                                                    ,'_PVT');
  END get_std_rate_tmpl;

  PROCEDURE get_eligibility_criteria(p_api_version   IN            NUMBER
                                    ,p_init_msg_list IN            VARCHAR2    DEFAULT okl_api.g_false
                                    ,x_return_status    OUT NOCOPY VARCHAR2
                                    ,x_msg_count        OUT NOCOPY NUMBER
                                    ,x_msg_data         OUT NOCOPY VARCHAR2
                                    ,source_id       IN            NUMBER
                                    ,x_ech_rec          OUT NOCOPY okl_ech_rec
                                    ,x_ecl_tbl          OUT NOCOPY okl_ecl_tbl
                                    ,x_ecv_tbl          OUT NOCOPY okl_ecv_tbl) IS

    -- cursor to fetch the adjustment categories header record

    CURSOR elig_crit_hdr(p_source_id     IN NUMBER
                        ,p_source_object IN VARCHAR2) IS
      SELECT criteria_set_id
            ,object_version_number
            ,source_id
            ,source_object_code
            ,match_criteria_code
            ,validation_code
            ,created_by
            ,creation_date
            ,last_updated_by
            ,last_update_date
            ,last_update_login
      FROM   okl_fe_criteria_set
      WHERE  source_id = p_source_id AND source_object_code = p_source_object;

    -- cursor to fetch the adjustment categories lines record

    CURSOR elig_crit_lines(p_criteria_set_id IN NUMBER) IS
      SELECT criteria_id
            ,object_version_number
            ,match_criteria_code
            ,criteria_set_id
            ,crit_cat_def_id
            ,effective_from_date
            ,effective_to_date
            ,created_by
            ,creation_date
            ,last_updated_by
            ,last_update_date
            ,last_update_login
      FROM   okl_fe_criteria
      WHERE  criteria_set_id = p_criteria_set_id;

    -- cursor to fetch the adjustment categories values record

    CURSOR elig_crit_values(p_criteria_id IN NUMBER) IS
      SELECT criterion_value_id
            ,object_version_number
            ,criteria_id
            ,operator_code
            ,crit_cat_value1
            ,crit_cat_value2
            ,adjustment_factor
            ,attribute_category
            ,attribute1
            ,attribute2
            ,attribute3
            ,attribute4
            ,attribute5
            ,attribute6
            ,attribute7
            ,attribute8
            ,attribute9
            ,attribute10
            ,attribute11
            ,attribute12
            ,attribute13
            ,attribute14
            ,attribute15
            ,created_by
            ,creation_date
            ,last_updated_by
            ,last_update_date
            ,last_update_login
      FROM   okl_fe_criterion_values
      WHERE  criteria_id = p_criteria_id;

    -- cursor to get the data type and the value type of a category

    CURSOR crit_def(criteria_def_id IN NUMBER) IS
      SELECT data_type_code
            ,value_type_code
      FROM   okl_fe_crit_cat_def_v
      WHERE  crit_cat_def_id = criteria_def_id;
    l_api_name                   VARCHAR2(40) := 'get_eligibility_criteria';
    l_api_version                NUMBER       := 1.0;
    i                            NUMBER       := 1;
    j                            NUMBER       := 1;
    data_type                    VARCHAR2(30);

  BEGIN
    x_return_status := okl_api.start_activity(l_api_name
                                             ,g_pkg_name
                                             ,p_init_msg_list
                                             ,l_api_version
                                             ,p_api_version
                                             ,'_PVT'
                                             ,x_return_status);

    FOR cat_hdr_rec IN elig_crit_hdr(source_id
                                    ,'SRT') LOOP
      x_ech_rec.criteria_set_id := cat_hdr_rec.criteria_set_id;
      x_ech_rec.object_version_number := cat_hdr_rec.object_version_number;
      x_ech_rec.source_id := cat_hdr_rec.source_id;
      x_ech_rec.source_object_code := cat_hdr_rec.source_object_code;
      x_ech_rec.match_criteria_code := cat_hdr_rec.match_criteria_code;
      x_ech_rec.validation_code := cat_hdr_rec.validation_code;
      x_ech_rec.created_by := cat_hdr_rec.created_by;
      x_ech_rec.creation_date := cat_hdr_rec.creation_date;
      x_ech_rec.last_updated_by := cat_hdr_rec.last_updated_by;
      x_ech_rec.last_update_date := cat_hdr_rec.last_update_date;
      x_ech_rec.last_update_login := cat_hdr_rec.last_update_login;
    END LOOP;

    FOR cat_lines_rec IN elig_crit_lines(x_ech_rec.criteria_set_id) LOOP
      x_ecl_tbl(i).criteria_id := cat_lines_rec.criteria_id;
      x_ecl_tbl(i).crit_cat_def_id := cat_lines_rec.crit_cat_def_id;
      FOR type_code IN crit_def(cat_lines_rec.crit_cat_def_id) LOOP
        data_type := type_code.data_type_code;
      END LOOP;
      FOR cat_values_rec IN elig_crit_values(cat_lines_rec.criteria_id) LOOP
        x_ecv_tbl(j).criterion_value_id := cat_values_rec.criterion_value_id;
        x_ecv_tbl(j).object_version_number := cat_values_rec.object_version_number;
        x_ecv_tbl(j).criteria_id := cat_values_rec.criteria_id;
        x_ecv_tbl(j).operator_code := cat_values_rec.operator_code;

        IF (data_type = 'VARCHAR2') THEN
          x_ecv_tbl(j).crit_cat_value1 := cat_values_rec.crit_cat_value1;
          x_ecv_tbl(j).crit_cat_value2 := cat_values_rec.crit_cat_value2;
        ELSIF (data_type = 'NUMBER') THEN
          x_ecv_tbl(j).crit_cat_numval1 := TO_NUMBER(cat_values_rec.crit_cat_value1);
          x_ecv_tbl(j).crit_cat_numval2 := TO_NUMBER(cat_values_rec.crit_cat_value2);
        ELSIF (data_type = 'DATE') THEN
          x_ecv_tbl(j).crit_cat_dateval1 := fnd_date.canonical_to_date(cat_values_rec.crit_cat_value1);
          x_ecv_tbl(j).crit_cat_dateval2 := fnd_date.canonical_to_date(cat_values_rec.crit_cat_value2);
        END IF;
        x_ecv_tbl(j).adjustment_factor := cat_values_rec.adjustment_factor;
        x_ecv_tbl(j).attribute_category := cat_values_rec.attribute_category;
        x_ecv_tbl(j).attribute1 := cat_values_rec.attribute1;
        x_ecv_tbl(j).attribute2 := cat_values_rec.attribute2;
        x_ecv_tbl(j).attribute3 := cat_values_rec.attribute3;
        x_ecv_tbl(j).attribute4 := cat_values_rec.attribute4;
        x_ecv_tbl(j).attribute5 := cat_values_rec.attribute5;
        x_ecv_tbl(j).attribute6 := cat_values_rec.attribute6;
        x_ecv_tbl(j).attribute7 := cat_values_rec.attribute7;
        x_ecv_tbl(j).attribute8 := cat_values_rec.attribute8;
        x_ecv_tbl(j).attribute9 := cat_values_rec.attribute9;
        x_ecv_tbl(j).attribute10 := cat_values_rec.attribute10;
        x_ecv_tbl(j).attribute11 := cat_values_rec.attribute11;
        x_ecv_tbl(j).attribute12 := cat_values_rec.attribute12;
        x_ecv_tbl(j).attribute13 := cat_values_rec.attribute13;
        x_ecv_tbl(j).attribute14 := cat_values_rec.attribute14;
        x_ecv_tbl(j).attribute15 := cat_values_rec.attribute15;
        x_ecv_tbl(j).created_by := cat_values_rec.created_by;
        x_ecv_tbl(j).creation_date := cat_values_rec.creation_date;
        x_ecv_tbl(j).last_updated_by := cat_values_rec.last_updated_by;
        x_ecv_tbl(j).last_update_date := cat_values_rec.last_update_date;
        x_ecv_tbl(j).last_update_login := cat_values_rec.last_update_login;
        j := j + 1;
      END LOOP;
      x_ecl_tbl(i).object_version_number := cat_lines_rec.object_version_number;
      x_ecl_tbl(i).match_criteria_code := cat_lines_rec.match_criteria_code;
      x_ecl_tbl(i).criteria_set_id := cat_lines_rec.criteria_set_id;
      x_ecl_tbl(i).effective_from_date := cat_lines_rec.effective_from_date;
      x_ecl_tbl(i).effective_to_date := cat_lines_rec.effective_to_date;
      x_ecl_tbl(i).created_by := cat_lines_rec.created_by;
      x_ecl_tbl(i).creation_date := cat_lines_rec.creation_date;
      x_ecl_tbl(i).last_updated_by := cat_lines_rec.last_updated_by;
      x_ecl_tbl(i).last_update_date := cat_lines_rec.last_update_date;
      x_ecl_tbl(i).last_update_login := cat_lines_rec.last_update_login;
      x_ecl_tbl(i).is_new_flag := 'N';
      i := i + 1;
    END LOOP;

    --end activity

    okl_api.end_activity(x_msg_count
                        ,x_msg_data);
    EXCEPTION
      WHEN OTHERS THEN
        x_return_status := okl_api.handle_exceptions(l_api_name
                                                    ,g_pkg_name
                                                    ,'OTHERS'
                                                    ,x_msg_count
                                                    ,x_msg_data
                                                    ,'_PVT');
  END get_eligibility_criteria;

  -- procedure to give the details of the Standard Rate Template given the Standard
  -- Rate Template id and the version number

  PROCEDURE get_version(p_api_version    IN            NUMBER
                       ,p_init_msg_list  IN            VARCHAR2     DEFAULT okl_api.g_false
                       ,x_return_status     OUT NOCOPY VARCHAR2
                       ,x_msg_count         OUT NOCOPY NUMBER
                       ,x_msg_data          OUT NOCOPY VARCHAR2
                       ,p_srt_id         IN            NUMBER
                       ,p_version_number IN            NUMBER
                       ,x_srtv_rec          OUT NOCOPY okl_srtv_rec
                       ,x_srv_rec           OUT NOCOPY okl_srv_rec
                       ,x_ech_rec           OUT NOCOPY okl_ech_rec
                       ,x_ecl_tbl           OUT NOCOPY okl_ecl_tbl
                       ,x_ecv_tbl           OUT NOCOPY okl_ecv_tbl) IS
    l_api_name                   VARCHAR2(40) := 'get_version';
    l_api_version                NUMBER       := 1.0;
    l_return_status              VARCHAR2(1)  := okl_api.g_ret_sts_success;

  BEGIN
    l_return_status := okl_api.start_activity(l_api_name
                                             ,g_pkg_name
                                             ,p_init_msg_list
                                             ,l_api_version
                                             ,p_api_version
                                             ,'_PVT'
                                             ,x_return_status);

    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;
    get_std_rate_tmpl(p_api_version
                     ,p_init_msg_list
                     ,x_return_status
                     ,x_msg_count
                     ,x_msg_data
                     ,p_srt_id
                     ,p_version_number
                     ,x_srtv_rec
                     ,x_srv_rec);

    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;
    get_eligibility_criteria(p_api_version
                            ,p_init_msg_list
                            ,x_return_status
                            ,x_msg_count
                            ,x_msg_data
                            ,x_srv_rec.std_rate_tmpl_ver_id
                            ,x_ech_rec
                            ,x_ecl_tbl
                            ,x_ecv_tbl);

    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;

    --end activity

    okl_api.end_activity(x_msg_count
                        ,x_msg_data);
    x_return_status := l_return_status;
    EXCEPTION
      WHEN okl_api.g_exception_error THEN
        x_return_status := okl_api.handle_exceptions(l_api_name
                                                    ,g_pkg_name
                                                    ,'OKL_API.G_RET_STS_ERROR'
                                                    ,x_msg_count
                                                    ,x_msg_data
                                                    ,'_PVT');
      WHEN okl_api.g_exception_unexpected_error THEN
        x_return_status := okl_api.handle_exceptions(l_api_name
                                                    ,g_pkg_name
                                                    ,'OKL_API.G_RET_STS_UNEXP_ERROR'
                                                    ,x_msg_count
                                                    ,x_msg_data
                                                    ,'_PVT');
      WHEN OTHERS THEN
        x_return_status := okl_api.handle_exceptions(l_api_name
                                                    ,g_pkg_name
                                                    ,'OTHERS'
                                                    ,x_msg_count
                                                    ,x_msg_data
                                                    ,'_PVT');
  END get_version;

  -- procedure to give the details of the latest version of Standard Rate Template
  -- given the Standard Rate Template id

  PROCEDURE get_version(p_api_version   IN            NUMBER
                       ,p_init_msg_list IN            VARCHAR2     DEFAULT okl_api.g_false
                       ,x_return_status    OUT NOCOPY VARCHAR2
                       ,x_msg_count        OUT NOCOPY NUMBER
                       ,x_msg_data         OUT NOCOPY VARCHAR2
                       ,p_srt_id        IN            NUMBER
                       ,x_srtv_rec         OUT NOCOPY okl_srtv_rec
                       ,x_srv_rec          OUT NOCOPY okl_srv_rec
                       ,x_ech_rec          OUT NOCOPY okl_ech_rec
                       ,x_ecl_tbl          OUT NOCOPY okl_ecl_tbl
                       ,x_ecv_tbl          OUT NOCOPY okl_ecv_tbl) IS

    CURSOR get_version_number(p_srt_id IN NUMBER) IS
      SELECT MAX(version_number)
      FROM   okl_fe_std_rt_tmp_vers
      WHERE  std_rate_tmpl_id = p_srt_id;
    l_version_number             VARCHAR2(24);
    l_api_name                   VARCHAR2(40) := 'get_version';
    l_api_version                NUMBER       := 1.0;
    l_return_status              VARCHAR2(1)  := okl_api.g_ret_sts_success;

  BEGIN
    l_return_status := okl_api.start_activity(l_api_name
                                             ,g_pkg_name
                                             ,p_init_msg_list
                                             ,l_api_version
                                             ,p_api_version
                                             ,'_PVT'
                                             ,x_return_status);

    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;
    OPEN get_version_number(p_srt_id);
    FETCH get_version_number INTO l_version_number ;
    CLOSE get_version_number;
    get_std_rate_tmpl(p_api_version
                     ,p_init_msg_list
                     ,x_return_status
                     ,x_msg_count
                     ,x_msg_data
                     ,p_srt_id
                     ,l_version_number
                     ,x_srtv_rec
                     ,x_srv_rec);

    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;
    get_eligibility_criteria(p_api_version
                            ,p_init_msg_list
                            ,x_return_status
                            ,x_msg_count
                            ,x_msg_data
                            ,x_srv_rec.std_rate_tmpl_ver_id
                            ,x_ech_rec
                            ,x_ecl_tbl
                            ,x_ecv_tbl);

    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;

    --end activity

    okl_api.end_activity(x_msg_count
                        ,x_msg_data);
    x_return_status := l_return_status;
    EXCEPTION
      WHEN okl_api.g_exception_error THEN
        x_return_status := okl_api.handle_exceptions(l_api_name
                                                    ,g_pkg_name
                                                    ,'OKL_API.G_RET_STS_ERROR'
                                                    ,x_msg_count
                                                    ,x_msg_data
                                                    ,'_PVT');
      WHEN okl_api.g_exception_unexpected_error THEN
        x_return_status := okl_api.handle_exceptions(l_api_name
                                                    ,g_pkg_name
                                                    ,'OKL_API.G_RET_STS_UNEXP_ERROR'
                                                    ,x_msg_count
                                                    ,x_msg_data
                                                    ,'_PVT');
      WHEN OTHERS THEN
        x_return_status := okl_api.handle_exceptions(l_api_name
                                                    ,g_pkg_name
                                                    ,'OTHERS'
                                                    ,x_msg_count
                                                    ,x_msg_data
                                                    ,'_PVT');
  END get_version;

  --procedure to create a Standard Rate Template with the associated Eligibility Criteria

  PROCEDURE insert_srt(p_api_version   IN            NUMBER
                      ,p_init_msg_list IN            VARCHAR2     DEFAULT okl_api.g_false
                      ,x_return_status    OUT NOCOPY VARCHAR2
                      ,x_msg_count        OUT NOCOPY NUMBER
                      ,x_msg_data         OUT NOCOPY VARCHAR2
                      ,p_srtv_rec      IN            okl_srtv_rec
                      ,p_srv_rec       IN            okl_srv_rec
                      ,x_srtv_rec         OUT NOCOPY okl_srtv_rec
                      ,x_srv_rec          OUT NOCOPY okl_srv_rec) IS
    l_srtv_rec                   okl_srtv_rec := p_srtv_rec;
    l_srv_rec                    okl_srv_rec  := p_srv_rec;
    l_api_version                NUMBER       := 1.0;
    l_api_name                   VARCHAR2(40) := 'INSERT_SRT';
    l_init_msg_list              VARCHAR2(1)  := p_init_msg_list;
    l_return_status              VARCHAR2(1)  := okl_api.g_ret_sts_success;
    l_dummy_var     VARCHAR2(1):='?';

    CURSOR rate_csr(p_index_id IN NUMBER
                   ,p_eff_from IN DATE) IS
      SELECT val.value
      FROM   okl_indices ind
            ,okl_index_values val
      WHERE  ind.id = val.idx_id AND ind.id = p_index_id
         AND p_eff_from BETWEEN val.datetime_valid AND NVL(val.datetime_invalid, TO_DATE('01-01-9999', 'dd-mm-yyyy'));

    CURSOR srt_unique_chk(p_name  IN  varchar2) IS
      SELECT 'x'
      FROM   okl_fe_std_rt_tmp_v
      WHERE  template_name = UPPER(p_name);
  BEGIN
    l_return_status := okl_api.start_activity(l_api_name
                                             ,g_pkg_name
                                             ,p_init_msg_list
                                             ,l_api_version
                                             ,p_api_version
                                             ,'_PVT'
                                             ,x_return_status);

    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;

    OPEN srt_unique_chk(l_srtv_rec.template_name);
    FETCH srt_unique_chk INTO l_dummy_var ;
    CLOSE srt_unique_chk;

    -- if l_dummy_var is 'x' then name already exists

    IF (l_dummy_var = 'x') THEN
      okl_api.set_message(p_app_name     =>  g_app_name
                         ,p_msg_name     =>  'OKL_DUPLICATE_NAME'
                         ,p_token1       =>  'NAME'
                         ,p_token1_value =>  l_srtv_rec.template_name);
       RAISE okl_api.g_exception_error;

    END IF;
    -- fix for gmiss date

    l_srv_rec.effective_to_date := rosetta_g_miss_date_in_map(l_srv_rec.effective_to_date);

    IF (l_srtv_rec.rate_type_code = 'BASE_RATE' AND (l_srv_rec.srt_rate IS NULL
                                                     OR l_srv_rec.srt_rate = okl_api.g_miss_num)) THEN
      RAISE okl_api.g_exception_error;
    END IF;

    IF (l_srtv_rec.rate_type_code = 'INDEX_RATE') THEN
      l_srv_rec.srt_rate := null;
      OPEN rate_csr(l_srtv_rec.index_id
                   ,l_srv_rec.effective_from_date);
      FETCH rate_csr INTO l_srv_rec.srt_rate ;
      CLOSE rate_csr;

    -- if l_srv_rec.srt_rate is null, then set the error message

    IF (l_srv_rec.SRT_RATE is null) THEN
      okl_api.set_message(p_app_name       =>             g_app_name
                           ,p_msg_name     =>             'OKL_SRT_INDEX_RATE_NOT_AVAIL'
                           );
      RAISE okl_api.g_exception_error;
    END IF;
    ELSE
      l_srtv_rec.index_id:= null;

    END IF;

    -- setting the header attributes

    l_srtv_rec.template_name := UPPER(l_srtv_rec.template_name);
    l_srtv_rec.sts_code := 'NEW';
    l_srtv_rec.effective_from_date := l_srv_rec.effective_from_date;
    l_srtv_rec.effective_to_date := l_srtv_rec.effective_to_date;
    l_srtv_rec.srt_rate := l_srv_rec.srt_rate;
    l_srtv_rec.default_yn := 'N';

    -- insert the header record into the table

    okl_srt_pvt.insert_row(l_api_version
                          ,l_init_msg_list
                          ,l_return_status
                          ,x_msg_count
                          ,x_msg_data
                          ,l_srtv_rec
                          ,x_srtv_rec);

    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;

    -- setting the version attributes

    l_srv_rec.sts_code := 'NEW';
    l_srv_rec.version_number := 1.0;
    l_srv_rec.std_rate_tmpl_id := x_srtv_rec.std_rate_tmpl_id;

    -- insert the versions record

    okl_srv_pvt.insert_row(l_api_version
                          ,l_init_msg_list
                          ,l_return_status
                          ,x_msg_count
                          ,x_msg_data
                          ,l_srv_rec
                          ,x_srv_rec);

    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;

    --end activity

    okl_api.end_activity(x_msg_count
                        ,x_msg_data);
    x_return_status := l_return_status;
    EXCEPTION
      WHEN okl_api.g_exception_error THEN
        x_return_status := okl_api.handle_exceptions(l_api_name
                                                    ,g_pkg_name
                                                    ,'OKL_API.G_RET_STS_ERROR'
                                                    ,x_msg_count
                                                    ,x_msg_data
                                                    ,'_PVT');
      WHEN okl_api.g_exception_unexpected_error THEN
        x_return_status := okl_api.handle_exceptions(l_api_name
                                                    ,g_pkg_name
                                                    ,'OKL_API.G_RET_STS_UNEXP_ERROR'
                                                    ,x_msg_count
                                                    ,x_msg_data
                                                    ,'_PVT');
      WHEN OTHERS THEN
        x_return_status := okl_api.handle_exceptions(l_api_name
                                                    ,g_pkg_name
                                                    ,'OTHERS'
                                                    ,x_msg_count
                                                    ,x_msg_data
                                                    ,'_PVT');
  END insert_srt;

  -- procedure to update a particular version of the Standard Rate Template

  PROCEDURE update_srt(p_api_version   IN            NUMBER
                      ,p_init_msg_list IN            VARCHAR2    DEFAULT okl_api.g_false
                      ,x_return_status    OUT NOCOPY VARCHAR2
                      ,x_msg_count        OUT NOCOPY NUMBER
                      ,x_msg_data         OUT NOCOPY VARCHAR2
                      ,p_srv_rec       IN            okl_srv_rec
                      ,x_srv_rec          OUT NOCOPY okl_srv_rec) IS
    l_srtv_rec                   okl_srtv_rec;
    x_srtv_rec                   okl_srtv_rec;
    l_srv_rec                    okl_srv_rec        := p_srv_rec;
    l_api_version                NUMBER             := 1.0;
    l_api_name                   VARCHAR2(40)       := 'UPDATE_SRT';
    l_init_msg_list              VARCHAR2(1)        := p_init_msg_list;
    l_return_status              VARCHAR2(1)        := okl_api.g_ret_sts_success;
    l_eff_from                   DATE;
    l_eff_to                     DATE;
    l_max_date                   DATE;
    cal_eff_from                 DATE;
    lp_lrtv_tbl                  okl_lrs_id_tbl;
    x_obj_tbl                    invalid_object_tbl;

    -- cursor to fetch the previous version effective from and the previous version effective to

    CURSOR prev_ver_csr(l_srt_id         IN NUMBER
                       ,l_version_number IN VARCHAR2) IS
      SELECT effective_from_date
            ,effective_to_date
      FROM   okl_fe_std_rt_tmp_vers
      WHERE  std_rate_tmpl_id = l_srt_id
         AND version_number = l_version_number - 1;
    CURSOR get_elig_crit_start_date(p_version_id IN NUMBER) IS
     SELECT max(effective_from_date)
     FROM   okl_fe_criteria_set ech
           ,okl_fe_criteria ecl
     WHERE  ecl.criteria_set_id = ech.criteria_set_id
     AND ech.source_id = p_version_id AND source_object_code = 'SRT';

  BEGIN
    l_return_status := okl_api.start_activity(l_api_name
                                             ,g_pkg_name
                                             ,l_init_msg_list
                                             ,l_api_version
                                             ,p_api_version
                                             ,'_PVT'
                                             ,x_return_status);

    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;

    -- fix for gmiss date

    l_srv_rec.effective_to_date := rosetta_g_miss_date_in_map(l_srv_rec.effective_to_date);



    IF (l_srv_rec.version_number = 1 AND l_srv_rec.sts_code = 'NEW') THEN
      l_srtv_rec.std_rate_tmpl_id := l_srv_rec.std_rate_tmpl_id;
      l_srtv_rec.effective_from_date := l_srv_rec.effective_from_date;
      l_srtv_rec.effective_to_date := l_srv_rec.effective_to_date;
      l_srtv_rec.srt_rate := l_srv_rec.srt_rate;

      -- update the header record

      okl_srt_pvt.update_row(l_api_version
                            ,l_init_msg_list
                            ,l_return_status
                            ,x_msg_count
                            ,x_msg_data
                            ,l_srtv_rec
                            ,x_srtv_rec);
      IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
        RAISE okl_api.g_exception_unexpected_error;
      ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
        RAISE okl_api.g_exception_error;
      END IF;
    ELSIF (l_srv_rec.sts_code = 'ACTIVE') THEN
      l_srtv_rec.std_rate_tmpl_id := l_srv_rec.std_rate_tmpl_id;

      -- check if this end date is greater than the calculated end date
      -- check for the effective to date
      calc_start_date(l_api_version
                   ,l_init_msg_list
                   ,l_return_status
                   ,x_msg_count
                   ,x_msg_data
                   ,l_srv_rec
                   ,cal_eff_from);

      IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      OPEN get_elig_crit_start_date(l_srv_rec.std_rate_tmpl_ver_id);
      FETCH get_elig_crit_start_date INTO l_max_date;
      CLOSE get_elig_crit_start_date;

      -- viselvar Bug#4907469 modified
      IF(l_max_date IS NOT NULL AND l_max_date+1 > cal_eff_from) THEN
         cal_eff_from:= l_max_date +1;
      END IF;

      -- viselvar Bug#4907469 modified
      IF (cal_eff_from <> okl_api.g_miss_date AND l_srv_rec.effective_to_date < (cal_eff_from-1) and cal_eff_from<>okl_api.g_miss_date) THEN
           okl_api.set_message(
                   p_app_name     =>  g_app_name
                  ,p_msg_name     =>  'OKL_INVALID_EFFECTIVE_TO_DATE'
                  ,p_token1       =>  'DATE'
                  ,p_token1_value =>  cal_eff_from-1);
        RAISE okl_api.g_exception_error;
      END IF;

      l_srtv_rec.effective_to_date := l_srv_rec.effective_to_date;
      l_srtv_rec.srt_rate := l_srv_rec.srt_rate;

      -- update the header record

      okl_srt_pvt.update_row(l_api_version
                            ,l_init_msg_list
                            ,l_return_status
                            ,x_msg_count
                            ,x_msg_data
                            ,l_srtv_rec
                            ,x_srtv_rec);
      IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
        RAISE okl_api.g_exception_unexpected_error;
      ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
        RAISE okl_api.g_exception_error;
      END IF;
      IF (l_srv_rec.effective_to_date IS NOT NULL AND l_srv_rec.effective_to_date <> okl_api.g_miss_date) THEN

        -- put an end date to the previous version of the eligibility criteria

        okl_ecc_values_pvt.end_date_eligibility_criteria(p_api_version   =>            l_api_version
                                                        ,p_init_msg_list =>            p_init_msg_list
                                                        ,x_return_status =>            x_return_status
                                                        ,x_msg_count     =>            x_msg_count
                                                        ,x_msg_data      =>            x_msg_data
                                                        ,p_source_id     =>            l_srv_rec.std_rate_tmpl_ver_id
                                                        ,p_source_type   =>            'SRT'
                                                        ,p_end_date      =>            l_srv_rec.effective_to_date);

        -- end date the lease rate set versions

        invalid_objects(p_api_version
                       ,p_init_msg_list
                       ,x_return_status
                       ,x_msg_count
                       ,x_msg_data
                       ,l_srv_rec.std_rate_tmpl_ver_id
                       ,x_obj_tbl);
        IF (x_obj_tbl.COUNT > 0) THEN

          FOR j IN x_obj_tbl.FIRST..x_obj_tbl.LAST LOOP
            lp_lrtv_tbl(j) := x_obj_tbl(j).obj_id;
          END LOOP;
          okl_lease_rate_Sets_pvt.enddate_lease_rate_set(p_api_version
                                                        ,p_init_msg_list
                                                        ,x_return_status
                                                        ,x_msg_count
                                                        ,x_msg_data
                                                        ,lp_lrtv_tbl
                                                        ,l_srv_rec.effective_to_date);
        END IF;
      END IF;
    END IF;

    -- update the version record

    okl_srv_pvt.update_row(l_api_version
                          ,l_init_msg_list
                          ,l_return_status
                          ,x_msg_count
                          ,x_msg_data
                          ,l_srv_rec
                          ,x_srv_rec);

    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;

    --end activity

    okl_api.end_activity(x_msg_count
                        ,x_msg_data);
    x_return_status := l_return_status;
    EXCEPTION
      WHEN okl_api.g_exception_error THEN
        x_return_status := okl_api.handle_exceptions(l_api_name
                                                    ,g_pkg_name
                                                    ,'OKL_API.G_RET_STS_ERROR'
                                                    ,x_msg_count
                                                    ,x_msg_data
                                                    ,'_PVT');
      WHEN okl_api.g_exception_unexpected_error THEN
        x_return_status := okl_api.handle_exceptions(l_api_name
                                                    ,g_pkg_name
                                                    ,'OKL_API.G_RET_STS_UNEXP_ERROR'
                                                    ,x_msg_count
                                                    ,x_msg_data
                                                    ,'_PVT');
      WHEN OTHERS THEN
        x_return_status := okl_api.handle_exceptions(l_api_name
                                                    ,g_pkg_name
                                                    ,'OTHERS'
                                                    ,x_msg_count
                                                    ,x_msg_data
                                                    ,'_PVT');
  END update_srt;

  -- procedure to create a new version of the Standard Rate Template

  PROCEDURE create_version(p_api_version   IN            NUMBER
                          ,p_init_msg_list IN            VARCHAR2    DEFAULT okl_api.g_false
                          ,x_return_status    OUT NOCOPY VARCHAR2
                          ,x_msg_count        OUT NOCOPY NUMBER
                          ,x_msg_data         OUT NOCOPY VARCHAR2
                          ,p_srv_rec       IN            okl_srv_rec
                          ,x_srv_rec          OUT NOCOPY okl_srv_rec) IS

    l_srtv_rec                   okl_srtv_rec;
    x_srtv_rec                   okl_srtv_rec;
    l_srv_rec                    okl_srv_rec  := p_srv_rec;
    l_api_version                NUMBER       := 1.0;
    l_api_name                   VARCHAR2(40) := 'CREATE_VERSION';
    l_init_msg_list              VARCHAR2(1)  := p_init_msg_list;
    l_return_status              VARCHAR2(1)  := okl_api.g_ret_sts_success;
    cal_eff_from                 DATE;

  BEGIN
    l_return_status := okl_api.start_activity(l_api_name
                                             ,g_pkg_name
                                             ,l_init_msg_list
                                             ,l_api_version
                                             ,p_api_version
                                             ,'_PVT'
                                             ,x_return_status);

    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;

    -- fix for gmiss date

    l_srv_rec.effective_to_date := rosetta_g_miss_date_in_map(l_srv_rec.effective_to_date);

    -- change the header status as under revision

    l_srtv_rec.sts_code := 'UNDER_REVISION';
    l_srtv_rec.std_rate_tmpl_id := l_srv_rec.std_rate_tmpl_id;

    -- update the header record

    okl_srt_pvt.update_row(l_api_version
                          ,l_init_msg_list
                          ,l_return_status
                          ,x_msg_count
                          ,x_msg_data
                          ,l_srtv_rec
                          ,x_srtv_rec);

    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;

    -- Check if user entered start date > the calculated start date
    -- else raise an exception

    calc_start_date(l_api_version
                   ,l_init_msg_list
                   ,l_return_status
                   ,x_msg_count
                   ,x_msg_data
                   ,l_srv_rec
                   ,cal_eff_from);

    IF (l_srv_rec.effective_from_date < cal_eff_from) THEN
      -- viselvar modified Bug#4907469
      okl_api.set_message(p_app_name       =>             g_app_name
                           ,p_msg_name     =>             'OKL_INVALID_EFF_FROM'
                           ,p_token1       =>             'DATE'
                           ,p_token1_value =>             cal_eff_from);
      RAISE okl_api.g_exception_error;
    END IF;

    -- insert the version record into the table

    okl_srv_pvt.insert_row(l_api_version
                          ,l_init_msg_list
                          ,l_return_status
                          ,x_msg_count
                          ,x_msg_data
                          ,l_srv_rec
                          ,x_srv_rec);

    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;

    --end activity

    okl_api.end_activity(x_msg_count
                        ,x_msg_data);
    x_return_status := l_return_status;
    EXCEPTION
      WHEN okl_api.g_exception_error THEN
        x_return_status := okl_api.handle_exceptions(l_api_name
                                                    ,g_pkg_name
                                                    ,'OKL_API.G_RET_STS_ERROR'
                                                    ,x_msg_count
                                                    ,x_msg_data
                                                    ,'_PVT');
      WHEN okl_api.g_exception_unexpected_error THEN
        x_return_status := okl_api.handle_exceptions(l_api_name
                                                    ,g_pkg_name
                                                    ,'OKL_API.G_RET_STS_UNEXP_ERROR'
                                                    ,x_msg_count
                                                    ,x_msg_data
                                                    ,'_PVT');
      WHEN OTHERS THEN
        x_return_status := okl_api.handle_exceptions(l_api_name
                                                    ,g_pkg_name
                                                    ,'OTHERS'
                                                    ,x_msg_count
                                                    ,x_msg_data
                                                    ,'_PVT');
  END create_version;

  -- procedure to raise the workflow which submits the record and changes the status.

  PROCEDURE submit_srt(p_api_version   IN            NUMBER
                      ,p_init_msg_list IN            VARCHAR2 DEFAULT okl_api.g_false
                      ,x_return_status    OUT NOCOPY VARCHAR2
                      ,x_msg_count        OUT NOCOPY NUMBER
                      ,x_msg_data         OUT NOCOPY VARCHAR2
                      ,p_version_id    IN            NUMBER) IS
    l_srv_rec                    okl_srv_rec;
    x_srv_rec                    okl_srv_rec;
    l_api_version                NUMBER              := 1.0;
    l_api_name                   VARCHAR2(40)        := 'SUBMIT_SRT';
    l_init_msg_list              VARCHAR2(1)         := p_init_msg_list;
    l_return_status              VARCHAR2(1)         := okl_api.g_ret_sts_success;
    l_parameter_list             wf_parameter_list_t;
    p_event_name                 VARCHAR2(240)       := 'oracle.apps.okl.fe.srtapproval';
    l_profile_value              VARCHAR2(30);

  BEGIN
    l_return_status := okl_api.start_activity(l_api_name
                                             ,g_pkg_name
                                             ,l_init_msg_list
                                             ,l_api_version
                                             ,p_api_version
                                             ,'_PVT'
                                             ,x_return_status);

    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;
    l_srv_rec.std_rate_tmpl_ver_id := p_version_id;
    l_srv_rec.sts_code := 'SUBMITTED';
    okl_srv_pvt.update_row(l_api_version
                          ,p_init_msg_list
                          ,x_return_status
                          ,x_msg_count
                          ,x_msg_data
                          ,l_srv_rec
                          ,x_srv_rec);

    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;
    fnd_profile.get('OKL_PE_APPROVAL_PROCESS'
                   ,l_profile_value);

    IF (nvl(l_profile_value,'NONE') = 'NONE') THEN
      okl_fe_std_rate_tmpl_pvt.handle_approval(l_api_version
                                              ,p_init_msg_list
                                              ,x_return_status
                                              ,x_msg_count
                                              ,x_msg_data
                                              ,p_version_id);
    ELSE

      -- raise the business event passing the version id added to the parameter list

      wf_event.addparametertolist('VERSION_ID'
                                 ,p_version_id
                                 ,l_parameter_list);
--added by akrangan
    wf_event.AddParameterToList('ORG_ID',mo_global.get_current_org_id ,l_parameter_list);

      okl_wf_pvt.raise_event(p_api_version   =>            p_api_version
                            ,p_init_msg_list =>            p_init_msg_list
                            ,x_return_status =>            x_return_status
                            ,x_msg_count     =>            x_msg_count
                            ,x_msg_data      =>            x_msg_data
                            ,p_event_name    =>            p_event_name
                            ,p_parameters    =>            l_parameter_list);
    END IF;

    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;

    --end activity

    okl_api.end_activity(x_msg_count
                        ,x_msg_data);
    x_return_status := l_return_status;
    EXCEPTION
      WHEN okl_api.g_exception_error THEN
        x_return_status := okl_api.handle_exceptions(l_api_name
                                                    ,g_pkg_name
                                                    ,'OKL_API.G_RET_STS_ERROR'
                                                    ,x_msg_count
                                                    ,x_msg_data
                                                    ,'_PVT');
      WHEN okl_api.g_exception_unexpected_error THEN
        x_return_status := okl_api.handle_exceptions(l_api_name
                                                    ,g_pkg_name
                                                    ,'OKL_API.G_RET_STS_UNEXP_ERROR'
                                                    ,x_msg_count
                                                    ,x_msg_data
                                                    ,'_PVT');
      WHEN OTHERS THEN
        x_return_status := okl_api.handle_exceptions(l_api_name
                                                    ,g_pkg_name
                                                    ,'OTHERS'
                                                    ,x_msg_count
                                                    ,x_msg_data
                                                    ,'_PVT');
  END submit_srt;

  -- procedure to handle when the process is going through the process of approval

  PROCEDURE handle_approval(p_api_version   IN            NUMBER
                           ,p_init_msg_list IN            VARCHAR2 DEFAULT okl_api.g_false
                           ,x_return_status    OUT NOCOPY VARCHAR2
                           ,x_msg_count        OUT NOCOPY NUMBER
                           ,x_msg_data         OUT NOCOPY VARCHAR2
                           ,p_version_id    IN            NUMBER) IS

    CURSOR srt_version_csr(p_version_id IN NUMBER) IS
      SELECT std_rate_tmpl_id
            ,version_number
            ,effective_from_date
            ,effective_to_date
            ,srt_rate
      FROM   okl_fe_std_rt_tmp_vers
      WHERE  std_rate_tmpl_ver_id = p_version_id;

    CURSOR ver_eff_to_csr(p_srt_id         IN NUMBER
                         ,p_version_number IN NUMBER) IS
      SELECT std_rate_tmpl_ver_id
            ,effective_to_date
      FROM   okl_fe_std_rt_tmp_vers
      WHERE  std_rate_tmpl_id = p_srt_id AND version_number = p_version_number;

    CURSOR max_version_csr(p_srt_id IN NUMBER) IS
      SELECT MAX(version_number)
      FROM   okl_fe_std_rt_tmp_vers
      WHERE  std_rate_tmpl_id = p_srt_id;

    CURSOR cal_rate_csr(index_id       IN NUMBER
                       ,effective_from IN DATE) IS
      SELECT value
      FROM   okl_index_values_v
      WHERE  idx_id = index_id AND effective_from >= datetime_valid
         AND effective_from <= NVL(datetime_invalid, TO_DATE('01-01-9999', 'dd-mm-yyyy'));

    CURSOR index_id_csr(p_srt_id IN NUMBER) IS
      SELECT index_id
      FROM   okl_fe_std_rt_tmp_all_b
      WHERE  std_rate_tmpl_id = p_srt_id;
    l_srt_id                     NUMBER;
    l_srt_ver_id                 NUMBER;
    l_index_id                   NUMBER;
    l_rate                       NUMBER;
    l_version_number             NUMBER;
    l_srt_rate                   NUMBER;
    l_effective_from             DATE;
    l_effective_to               DATE;
    l_eff_prev_ver               DATE;
    l_srtv_rec                   okl_srtv_rec;
    x_srtv_rec                   okl_srtv_rec;
    l_srv_rec                    okl_srv_rec;
    x_srv_rec                    okl_srv_rec;
    lp_srv_rec                   okl_srv_rec;
    lp_lrtv_tbl                  okl_lrs_id_tbl;
    x_obj_tbl                    invalid_object_tbl;
    l_max_version                VARCHAR2(24);
    l_cal_end_date               DATE;
    l_api_version                NUMBER             := 1.0;
    l_api_name                   VARCHAR2(40)       := 'handle_approval';

  BEGIN
    x_return_status := okl_api.start_activity(l_api_name
                                             ,g_pkg_name
                                             ,p_init_msg_list
                                             ,l_api_version
                                             ,p_api_version
                                             ,'_PVT'
                                             ,x_return_status);

    IF (x_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (x_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;

    -- if it is the first version,
    -- change the header status and the end date of the header as the version end date
    -- change the version status to active
    -- if it had=s already some versions,
    -- then end_date the previous versions
    -- then end date the reference of the previous version

    OPEN srt_version_csr(p_version_id);
    FETCH srt_version_csr INTO l_srt_id
                              ,l_version_number
                              ,l_effective_from
                              ,l_effective_to
                              ,l_rate ;
    CLOSE srt_version_csr;
    OPEN max_version_csr(l_srt_id);
    FETCH max_version_csr INTO l_max_version ;
    CLOSE max_version_csr;

    lp_srv_rec.std_rate_tmpl_id := l_srt_id;
    lp_srv_rec.version_number:= l_version_number;
    lp_srv_rec.effective_from_date := l_effective_from;
    lp_srv_rec.effective_to_date := l_effective_to;

    IF (l_version_number = 1) THEN
      l_srtv_rec.std_rate_tmpl_id := l_srt_id;
      l_srtv_rec.sts_code := 'ACTIVE';
      IF (l_effective_to IS NOT NULL) THEN
        l_srtv_rec.effective_to_date := l_effective_to;
      ELSE
        l_srtv_rec.effective_to_date := okl_api.g_miss_date;
      END IF;

    ELSIF (l_version_number = l_max_version) THEN

      -- get the previous version Effective To

      OPEN ver_eff_to_csr(l_srt_id
                         ,l_version_number - 1);
      FETCH ver_eff_to_csr INTO l_srt_ver_id
                               ,l_eff_prev_ver ;
      CLOSE ver_eff_to_csr;

      -- get the referenced version maximum end_date

      lp_srv_rec.STD_RATE_TMPL_VER_ID:= l_srt_ver_id;
        calc_start_date(
                     p_api_version   ,
                     p_init_msg_list ,
                     x_return_status ,
                     x_msg_count     ,
                     x_msg_data      ,
                     lp_srv_rec       ,
                     l_cal_end_date );

       IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
         raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) then
         raise OKL_API.G_EXCEPTION_ERROR;
       END IF;

       IF (lp_srv_rec.effective_from_date < l_cal_end_date ) THEN
          RAISE okl_api.g_exception_error;
       END IF;
      l_cal_end_date:= lp_srv_rec.effective_from_date -1;

      l_srtv_rec.std_rate_tmpl_id := l_srt_id;
      l_srtv_rec.sts_code := 'ACTIVE';
      IF (l_effective_to IS NOT NULL) THEN
        l_srtv_rec.effective_to_date := l_effective_to;
      ELSE
        l_srtv_rec.effective_to_date := okl_api.g_miss_date;
      END IF;

      IF (l_cal_end_date IS NOT NULL) THEN

          -- end date the lease rate set versions

          invalid_objects(p_api_version
                         ,p_init_msg_list
                         ,x_return_status
                         ,x_msg_count
                         ,x_msg_data
                         ,l_srt_ver_id
                         ,x_obj_tbl);
          IF (x_obj_tbl.COUNT > 0) THEN

            FOR j IN x_obj_tbl.FIRST..x_obj_tbl.LAST LOOP
              lp_lrtv_tbl(j) := x_obj_tbl(j).obj_id;
            END LOOP;
            okl_lease_rate_Sets_pvt.enddate_lease_rate_set(p_api_version
                                                          ,p_init_msg_list
                                                          ,x_return_status
                                                          ,x_msg_count
                                                          ,x_msg_data
                                                          ,lp_lrtv_tbl
                                                          ,l_cal_end_date);
        END IF;
      END IF;
      -- update the previous version effective to

      IF (NVL(l_eff_prev_ver
             ,okl_api.g_miss_date) <> l_cal_end_date) THEN
        l_srv_rec.std_rate_tmpl_ver_id := l_srt_ver_id;
        l_srv_rec.effective_to_date := l_cal_end_date;
        okl_srv_pvt.update_row(l_api_version
                              ,p_init_msg_list
                              ,x_return_status
                              ,x_msg_count
                              ,x_msg_data
                              ,l_srv_rec
                              ,x_srv_rec);

        -- put an end date to the previous version of the eligibility criteria

        okl_ecc_values_pvt.end_date_eligibility_criteria(p_api_version   =>            l_api_version
                                                        ,p_init_msg_list =>            p_init_msg_list
                                                        ,x_return_status =>            x_return_status
                                                        ,x_msg_count     =>            x_msg_count
                                                        ,x_msg_data      =>            x_msg_data
                                                        ,p_source_id     =>            l_srt_ver_id
                                                        ,p_source_type   =>            'SRT'
                                                        ,p_end_date      =>            l_cal_end_date);
        END IF;
    END IF;

    --make the version status as active

    l_srv_rec.std_rate_tmpl_ver_id := p_version_id;
    l_srv_rec.sts_code := 'ACTIVE';
    l_srv_rec.effective_to_date := NULL;
    l_srtv_rec.srt_rate := l_rate;

    -- fetch the index id to get the value of the rate that has to be submitted

    OPEN index_id_csr(l_srt_id);
    FETCH index_id_csr INTO l_index_id ;
    CLOSE index_id_csr;

    IF (l_index_id IS NOT NULL AND l_index_id <> okl_api.g_miss_num) THEN
      OPEN cal_rate_csr(l_index_id
                       ,l_effective_from);
      FETCH cal_rate_csr INTO l_srt_rate ;
      CLOSE cal_rate_csr;
      IF (l_srt_rate IS NULL) THEN
        okl_api.set_message(p_app_name       =>             g_app_name
                           ,p_msg_name     =>             'OKL_SRT_INDEX_RATE_NOT_AVAIL'
                           );
        RAISE okl_api.g_exception_error;
      ELSE
        l_srv_rec.srt_rate := l_srt_rate;
        l_srtv_rec.srt_rate := l_rate;
      END IF;
    END IF;

    -- get if the rate type is index and populate the rate

    okl_srv_pvt.update_row(l_api_version
                          ,p_init_msg_list
                          ,x_return_status
                          ,x_msg_count
                          ,x_msg_data
                          ,l_srv_rec
                          ,x_srv_rec);

    IF (x_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (x_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;
    okl_srt_pvt.update_row(l_api_version
                          ,p_init_msg_list
                          ,x_return_status
                          ,x_msg_count
                          ,x_msg_data
                          ,l_srtv_rec
                          ,x_srtv_rec);

    IF (x_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (x_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;

    EXCEPTION
      WHEN okl_api.g_exception_error THEN
        x_return_status := okl_api.handle_exceptions(l_api_name
                                                    ,g_pkg_name
                                                    ,'OKL_API.G_RET_STS_ERROR'
                                                    ,x_msg_count
                                                    ,x_msg_data
                                                    ,'_PVT');
      WHEN okl_api.g_exception_unexpected_error THEN
        x_return_status := okl_api.handle_exceptions(l_api_name
                                                    ,g_pkg_name
                                                    ,'OKL_API.G_RET_STS_UNEXP_ERROR'
                                                    ,x_msg_count
                                                    ,x_msg_data
                                                    ,'_PVT');
      WHEN OTHERS THEN

        IF srt_version_csr%ISOPEN THEN
          CLOSE srt_version_csr;
        END IF;
        x_return_status := okl_api.handle_exceptions(l_api_name
                                                    ,g_pkg_name
                                                    ,'OTHERS'
                                                    ,x_msg_count
                                                    ,x_msg_data
                                                    ,'_PVT');
  END handle_approval;

  -- procedure to set the default Standard Rate Template

  PROCEDURE update_default(p_api_version   IN            NUMBER
                          ,p_init_msg_list IN            VARCHAR2 DEFAULT okl_api.g_false
                          ,x_return_status    OUT NOCOPY VARCHAR2
                          ,x_msg_count        OUT NOCOPY NUMBER
                          ,x_msg_data         OUT NOCOPY VARCHAR2
                          ,p_srt_id        IN            NUMBER) AS

    CURSOR default_yn_csr IS
      SELECT std_rate_tmpl_id
      FROM   okl_fe_std_rt_tmp_all_b
      WHERE  default_yn = 'Y';
    l_srtv_rec                   okl_srtv_rec;
    x_srtv_rec                   okl_srtv_rec;
    l_srt_id                     NUMBER;
    l_api_version                NUMBER       := 1.0;
    l_api_name                   VARCHAR2(40) := 'update_default';
    l_init_msg_list              VARCHAR2(1)  := p_init_msg_list;
    l_return_status              VARCHAR2(1)  := okl_api.g_ret_sts_success;

  BEGIN
    l_return_status := okl_api.start_activity(l_api_name
                                             ,g_pkg_name
                                             ,l_init_msg_list
                                             ,l_api_version
                                             ,p_api_version
                                             ,'_PVT'
                                             ,x_return_status);

    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;
    OPEN default_yn_csr;
    FETCH default_yn_csr INTO l_srt_id ;
    CLOSE default_yn_csr;

    -- change the default yn flag of this Standard Rate Template to N

    IF (l_srt_id IS NOT NULL) THEN
      l_srtv_rec.std_rate_tmpl_id := l_srt_id;
      l_srtv_rec.default_yn := 'N';

      -- update the record

      okl_srt_pvt.update_row(l_api_version
                            ,l_init_msg_list
                            ,l_return_status
                            ,x_msg_count
                            ,x_msg_data
                            ,l_srtv_rec
                            ,x_srtv_rec);
      IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
        RAISE okl_api.g_exception_unexpected_error;
      ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
        RAISE okl_api.g_exception_error;
      END IF;
    END IF;

    -- change the default yn flag to Y for the required one

    l_srtv_rec.std_rate_tmpl_id := p_srt_id;
    l_srtv_rec.default_yn := 'Y';

    -- update the record

    okl_srt_pvt.update_row(l_api_version
                          ,l_init_msg_list
                          ,l_return_status
                          ,x_msg_count
                          ,x_msg_data
                          ,l_srtv_rec
                          ,x_srtv_rec);

    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;

    --end activity

    okl_api.end_activity(x_msg_count
                        ,x_msg_data);
    x_return_status := l_return_status;
    EXCEPTION
      WHEN okl_api.g_exception_error THEN
        x_return_status := okl_api.handle_exceptions(l_api_name
                                                    ,g_pkg_name
                                                    ,'OKL_API.G_RET_STS_ERROR'
                                                    ,x_msg_count
                                                    ,x_msg_data
                                                    ,'_PVT');
      WHEN okl_api.g_exception_unexpected_error THEN
        x_return_status := okl_api.handle_exceptions(l_api_name
                                                    ,g_pkg_name
                                                    ,'OKL_API.G_RET_STS_UNEXP_ERROR'
                                                    ,x_msg_count
                                                    ,x_msg_data
                                                    ,'_PVT');
      WHEN OTHERS THEN
        x_return_status := okl_api.handle_exceptions(l_api_name
                                                    ,g_pkg_name
                                                    ,'OTHERS'
                                                    ,x_msg_count
                                                    ,x_msg_data
                                                    ,'_PVT');
  END update_default;

  -- to find the list of all the invalid object refernces

  PROCEDURE invalid_objects(p_api_version   IN            NUMBER
                           ,p_init_msg_list IN            VARCHAR2           DEFAULT okl_api.g_false
                           ,x_return_status    OUT NOCOPY VARCHAR2
                           ,x_msg_count        OUT NOCOPY NUMBER
                           ,x_msg_data         OUT NOCOPY VARCHAR2
                           ,p_version_id    IN            NUMBER
                           ,x_obj_tbl          OUT NOCOPY invalid_object_tbl) AS

    -- cursor to calculate the  LRS objects which are referncing this Standard Rate Template

    CURSOR lrs_invalids_csr(p_version_id IN NUMBER) IS
      SELECT vers.rate_set_version_id id
            ,hdr.name name
            ,vers.version_number version_number
      FROM   okl_fe_rate_set_versions vers
            ,okl_ls_rt_fctr_sets_v hdr
      WHERE  vers.rate_set_id = hdr.id
         AND vers.std_rate_tmpl_ver_id = p_version_id
         AND vers.sts_code = 'ACTIVE';
    l_version_id                 NUMBER       := p_version_id;
    i                            NUMBER       := 1;
    l_api_version                NUMBER       := 1.0;
    l_api_name                   VARCHAR2(40) := 'invalid_objects';
    l_return_status              VARCHAR2(1)  := okl_api.g_ret_sts_success;

  BEGIN
    x_return_status := okl_api.start_activity(l_api_name
                                             ,g_pkg_name
                                             ,p_init_msg_list
                                             ,l_api_version
                                             ,p_api_version
                                             ,'_PVT'
                                             ,x_return_status);

    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;

    FOR lrs_invalid_record IN lrs_invalids_csr(p_version_id) LOOP
      x_obj_tbl(i).obj_id := lrs_invalid_record.id;
      x_obj_tbl(i).obj_name := lrs_invalid_record.name;
      x_obj_tbl(i).obj_version := lrs_invalid_record.version_number;
      x_obj_tbl(i).obj_type := 'LRS';
      i := i + 1;
    END LOOP;

    --end activity

    okl_api.end_activity(x_msg_count
                        ,x_msg_data);
    x_return_status := l_return_status;
    EXCEPTION
      WHEN okl_api.g_exception_error THEN
        x_return_status := okl_api.handle_exceptions(l_api_name
                                                    ,g_pkg_name
                                                    ,'OKL_API.G_RET_STS_ERROR'
                                                    ,x_msg_count
                                                    ,x_msg_data
                                                    ,'_PVT');
      WHEN okl_api.g_exception_unexpected_error THEN
        x_return_status := okl_api.handle_exceptions(l_api_name
                                                    ,g_pkg_name
                                                    ,'OKL_API.G_RET_STS_UNEXP_ERROR'
                                                    ,x_msg_count
                                                    ,x_msg_data
                                                    ,'_PVT');
      WHEN OTHERS THEN
        x_return_status := okl_api.handle_exceptions(l_api_name
                                                    ,g_pkg_name
                                                    ,'OTHERS'
                                                    ,x_msg_count
                                                    ,x_msg_data
                                                    ,'_PVT');
  END invalid_objects;

  -- to calculate the start date of the new version

  PROCEDURE calc_start_date(p_api_version   IN            NUMBER
                           ,p_init_msg_list IN            VARCHAR2    DEFAULT okl_api.g_false
                           ,x_return_status    OUT NOCOPY VARCHAR2
                           ,x_msg_count        OUT NOCOPY NUMBER
                           ,x_msg_data         OUT NOCOPY VARCHAR2
                           ,p_srv_rec       IN            okl_srv_rec
                           ,x_cal_eff_from     OUT NOCOPY DATE) AS

    TYPE l_start_date_type IS TABLE OF DATE INDEX BY BINARY_INTEGER;
    l_api_name                   VARCHAR2(40)      := 'calc_start_date';
    l_api_version                NUMBER            := 1.0;
    l_srv_rec                    okl_srv_rec       := p_srv_rec;
    l_eff_from                   DATE;
    l_eff_to                     DATE;
    l_return_status              VARCHAR2(1)       := okl_api.g_ret_sts_success;
    l_start_date                 l_start_date_type;
    l_max_start_date             DATE;
    i                            NUMBER;

    -- cursor to fetch the maximum start date of lease quotes referencing Standard Rate Template

    CURSOR srt_lq_csr(p_version_id IN NUMBER) IS
      SELECT MAX(lq.expected_start_date) start_date
      FROM   okl_lease_quotes_b lq
            ,okl_fe_std_rt_tmp_vers srt
      WHERE  srt.std_rate_tmpl_ver_id = p_version_id
         AND lq.rate_template_id = srt.std_rate_tmpl_ver_id;

    -- cursor to fetch the maximum start date of quick quotes referencing Standard Rate Template

    CURSOR srt_qq_csr(p_version_id IN NUMBER) IS
      SELECT MAX(qq.expected_start_date) start_date
      FROM   okl_quick_quotes_b qq
            ,okl_fe_std_rt_tmp_vers srt
      WHERE  srt.std_rate_tmpl_ver_id = p_version_id
         AND qq.rate_template_id = srt.std_rate_tmpl_ver_id;

    -- cursor to fetch the maximum start date of lease quotes referencing Lease Rate Sets

    CURSOR lrs_lq_csr(p_version_id IN NUMBER) IS
      SELECT MAX(expected_start_date) start_date
      FROM   okl_lease_quotes_b
      WHERE  rate_card_id IN(SELECT rate_set_version_id
             FROM            okl_fe_rate_set_versions
             WHERE           std_rate_tmpl_ver_id = p_version_id);

    -- cursor to fetch the maximum start date of quick quotes referencing Lease Rate Sets

    CURSOR lrs_qq_csr(p_version_id IN NUMBER) IS
      SELECT MAX(expected_start_date) start_date
      FROM   okl_quick_quotes_b
      WHERE  rate_card_id IN(SELECT rate_set_version_id
             FROM            okl_fe_rate_set_versions
             WHERE           std_rate_tmpl_ver_id = p_version_id);

    -- cursor to fetch the start date and the end of the previous version

    CURSOR prev_ver_csr(p_srt_id     IN NUMBER
                       ,p_ver_number IN VARCHAR2) IS
      SELECT effective_from_date
            ,effective_to_date
      FROM   okl_fe_std_rt_tmp_vers
      WHERE  std_rate_tmpl_id = p_srt_id AND version_number = p_ver_number - 1;

    CURSOR get_elig_crit_start_date(p_version_id IN NUMBER) IS
     SELECT max(effective_from_date)
     FROM   okl_fe_criteria_set ech
           ,okl_fe_criteria ecl
     WHERE  ecl.criteria_set_id = ech.criteria_set_id
     AND ech.source_id = p_version_id AND source_object_code = 'SRT';
  BEGIN
    l_return_status := okl_api.start_activity(l_api_name
                                             ,g_pkg_name
                                             ,p_init_msg_list
                                             ,l_api_version
                                             ,p_api_version
                                             ,'_PVT'
                                             ,x_return_status);

    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;

    --fetch the data from the different cursors

    OPEN prev_ver_csr(l_srv_rec.std_rate_tmpl_id
                     ,l_srv_rec.version_number);
    FETCH prev_ver_csr INTO l_eff_from
                           ,l_eff_to ;
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

      -- calculate the maximum start date
      OPEN srt_lq_csr(l_srv_rec.std_rate_tmpl_ver_id);
      FETCH srt_lq_csr INTO l_start_date(0) ;
      CLOSE srt_lq_csr;

      OPEN srt_qq_csr(l_srv_rec.std_rate_tmpl_ver_id);
      FETCH srt_qq_csr INTO l_start_date(1) ;
      CLOSE srt_qq_csr;

      OPEN lrs_lq_csr(l_srv_rec.std_rate_tmpl_ver_id);
      FETCH lrs_lq_csr INTO l_start_date(2) ;
      CLOSE lrs_lq_csr;

      OPEN lrs_qq_csr(l_srv_rec.std_rate_tmpl_ver_id);
      FETCH lrs_qq_csr INTO l_start_date(3) ;
      CLOSE lrs_qq_csr;

      OPEN get_elig_crit_start_date(l_srv_rec.std_rate_tmpl_ver_id);
      FETCH get_elig_crit_start_date INTO l_start_date(4);
      CLOSE get_elig_crit_start_date;

      FOR i IN l_start_date.FIRST..l_start_date.LAST LOOP

        IF (l_start_date(i) IS NOT NULL AND (l_start_date(i)+1) > l_max_start_date) THEN
          l_max_start_date := l_start_date(i)+1;
        END IF;

      END LOOP;

    END IF;

    -- assign the max start date to the out parameter

    x_cal_eff_from := l_max_start_date;

    --end activity

    okl_api.end_activity(x_msg_count
                        ,x_msg_data);
    x_return_status := l_return_status;
    EXCEPTION
      WHEN okl_api.g_exception_error THEN
        x_return_status := okl_api.handle_exceptions(l_api_name
                                                    ,g_pkg_name
                                                    ,'OKL_API.G_RET_STS_ERROR'
                                                    ,x_msg_count
                                                    ,x_msg_data
                                                    ,'_PVT');
      WHEN okl_api.g_exception_unexpected_error THEN
        x_return_status := okl_api.handle_exceptions(l_api_name
                                                    ,g_pkg_name
                                                    ,'OKL_API.G_RET_STS_UNEXP_ERROR'
                                                    ,x_msg_count
                                                    ,x_msg_data
                                                    ,'_PVT');
      WHEN OTHERS THEN
        x_return_status := okl_api.handle_exceptions(l_api_name
                                                    ,g_pkg_name
                                                    ,'OTHERS'
                                                    ,x_msg_count
                                                    ,x_msg_data
                                                    ,'_PVT');
  END calc_start_date;

  --this api should be called to end date any ACTIVE srt version

  PROCEDURE enddate_std_rate_tmpl(p_api_version   IN            NUMBER
                                 ,p_init_msg_list IN            VARCHAR2         DEFAULT okl_api.g_false
                                 ,x_return_status    OUT NOCOPY VARCHAR2
                                 ,x_msg_count        OUT NOCOPY NUMBER
                                 ,x_msg_data         OUT NOCOPY VARCHAR2
                                 ,p_srv_id_tbl    IN            okl_number_table
                                 ,p_end_date      IN            DATE) IS

    CURSOR is_latest_version(p_srt_version_id IN NUMBER
                            ,p_srt_id         IN NUMBER) IS
      SELECT 'X'
      FROM   okl_fe_std_rt_tmp_vers
      WHERE  version_number =  (SELECT MAX(version_number)
              FROM   okl_fe_std_rt_tmp_vers
              WHERE  std_rate_tmpl_id = p_srt_id)
         AND std_rate_tmpl_ver_id = p_srt_version_id;

    CURSOR get_not_abn_versions(p_srt_version_id IN NUMBER
                               ,p_srt_id         IN NUMBER) IS
      SELECT 'X'
      FROM   okl_fe_std_rt_tmp_vers
      WHERE  std_rate_tmpl_id = p_srt_id
         AND std_rate_tmpl_ver_id <> p_srt_version_id
         AND sts_code <> 'ABANDONED';

    -- cursor to fetch the effective from and effective to date

    CURSOR get_effective_dates_csr(p_srt_version_id IN NUMBER) IS
      SELECT effective_from_date
            ,effective_to_date
            ,sts_code
            ,std_rate_tmpl_id
      FROM   okl_fe_std_rt_tmp_vers
      WHERE  std_rate_tmpl_ver_id = p_srt_version_id;

     -- cursor to calculate the  LRS objects which are referncing this Standard Rate Template

    CURSOR lrs_invalids_csr(p_version_id IN NUMBER) IS
      SELECT vers.rate_set_version_id id
            ,hdr.name name
            ,vers.version_number version_number
      FROM   okl_fe_rate_set_versions vers
            ,okl_ls_rt_fctr_sets_v hdr
      WHERE  vers.rate_set_id = hdr.id
         AND vers.std_rate_tmpl_ver_id = p_version_id
         AND vers.sts_code = 'ACTIVE';
    lp_srv_rec                    okl_srv_rec;
    lx_srv_rec                    okl_srv_rec;
    lp_srtv_rec                   okl_srtv_rec;
    lx_srtv_rec                   okl_srtv_rec;
    l_srt_id_list                 VARCHAR2(4000);
    l_no_data_found               BOOLEAN;
    l_update_header               BOOLEAN;
    l_update_version              BOOLEAN;
    l_effective_from              DATE;
    l_effective_to                DATE;
    l_sts_code                    VARCHAR2(30);
    l_srt_id                      NUMBER;
    l_api_name           CONSTANT VARCHAR2(30)   := 'enddate_std_rate_tmpl';
    l_api_version        CONSTANT NUMBER         := 1.0;
    l_return_status               VARCHAR2(1)    := okl_api.g_ret_sts_success;
    l_dummy                       VARCHAR2(1)    := '?';
    lp_lrtv_tbl                   okl_lrs_id_tbl;
    n                             NUMBER :=1;

  BEGIN

    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list

    l_return_status := okl_api.start_activity(l_api_name
                                             ,g_pkg_name
                                             ,p_init_msg_list
                                             ,l_api_version
                                             ,p_api_version
                                             ,'_PVT'
                                             ,x_return_status);

    -- check if activity started successfully

    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;

    FOR i IN p_srv_id_tbl.FIRST..p_srv_id_tbl.LAST LOOP
      OPEN get_effective_dates_csr(p_srv_id_tbl(i));
      FETCH get_effective_dates_csr INTO l_effective_from
                                        ,l_effective_to
                                        ,l_sts_code
                                        ,l_srt_id ;
      CLOSE get_effective_dates_csr;
      lp_srv_rec.effective_from_date := l_effective_from;
      lp_srv_rec.effective_to_date := l_effective_to;
      lp_srv_rec.sts_code := l_sts_code;
      lp_srv_rec.std_rate_tmpl_id := l_srt_id;
      lp_srv_rec.std_rate_tmpl_ver_id := p_srv_id_tbl(i);
      l_update_header := false;
      l_update_version := false;

      IF lp_srv_rec.effective_from_date <= p_end_date THEN
        IF lp_srv_rec.effective_to_date IS NULL THEN
          lp_srv_rec.effective_to_date := p_end_date;
          l_update_version := true;

          --if this is the latest version then put end date on header

          OPEN is_latest_version(p_srv_id_tbl(i)
                                ,lp_srv_rec.std_rate_tmpl_id);
          FETCH is_latest_version INTO l_dummy ;
          CLOSE is_latest_version;
          IF l_dummy <> '?' THEN
            lp_srtv_rec.effective_to_date := p_end_date;
            lp_srtv_rec.std_rate_tmpl_id := l_srt_id;
            l_update_header := true;
          END IF;
        END IF;
      ELSE
        lp_srv_rec.sts_code := 'ABANDONED';
        lp_srv_rec.std_rate_tmpl_ver_id := p_srv_id_tbl(i);
        l_update_version := true;

        --if all versions are abandoned then make header status as abandoned

        OPEN get_not_abn_versions(p_srv_id_tbl(i)
                                 ,lp_srv_rec.std_rate_tmpl_id);
        FETCH get_not_abn_versions INTO l_dummy ;
        CLOSE get_not_abn_versions;
        IF l_dummy = '?' THEN
          lp_srtv_rec.sts_code := 'ABANDONED';
          lp_srtv_rec.std_rate_tmpl_id := l_srt_id;
          l_update_header := true;
        END IF;

        --if this is the latest version then put end date on header and version

        OPEN is_latest_version(p_srv_id_tbl(i)
                              ,lp_srv_rec.std_rate_tmpl_id);
        FETCH is_latest_version INTO l_dummy ;
        CLOSE is_latest_version;
        IF l_dummy <> '?' THEN

          --put end date on version

          lp_srv_rec.effective_to_date := lp_srv_rec.effective_from_date;
          l_update_version := true;

          --put end date on header

          lp_srtv_rec.effective_to_date := lp_srv_rec.effective_from_date;
          l_update_header := true;
        END IF;
      END IF;
      -- end date the lease rate sets referencing this SRT

      FOR x_lrs_id_tbl IN lrs_invalids_csr(p_srv_id_tbl(i)) LOOP
              lp_lrtv_tbl(n) := x_lrs_id_tbl.id;
              n:=n+1;
      END LOOP;
      okl_lease_rate_Sets_pvt.enddate_lease_rate_set(p_api_version
                                                          ,p_init_msg_list
                                                          ,x_return_status
                                                          ,x_msg_count
                                                          ,x_msg_data
                                                          ,lp_lrtv_tbl
                                                          ,p_end_date);

      --update the version

      IF l_update_version THEN
        okl_srv_pvt.update_row(l_api_version
                              ,p_init_msg_list
                              ,l_return_status
                              ,x_msg_count
                              ,x_msg_data
                              ,lp_srv_rec
                              ,lx_srv_rec);
        IF l_return_status = okl_api.g_ret_sts_error THEN
          RAISE okl_api.g_exception_error;
        ELSIF l_return_status = okl_api.g_ret_sts_unexp_error THEN
          RAISE okl_api.g_exception_unexpected_error;
        END IF;
      END IF;

      --update the header

      IF l_update_header THEN
        okl_srt_pvt.update_row(p_api_version
                              ,p_init_msg_list
                              ,l_return_status
                              ,x_msg_count
                              ,x_msg_data
                              ,lp_srtv_rec
                              ,lx_srtv_rec);
        IF l_return_status = okl_api.g_ret_sts_error THEN
          RAISE okl_api.g_exception_error;
        ELSIF l_return_status = okl_api.g_ret_sts_unexp_error THEN
          RAISE okl_api.g_exception_unexpected_error;
        END IF;
      END IF;

    END LOOP;
    x_return_status := l_return_status;
    okl_api.end_activity(x_msg_count =>                x_msg_count
                        ,x_msg_data  =>                x_msg_data);
    EXCEPTION
      WHEN okl_api.g_exception_error THEN
        x_return_status := okl_api.handle_exceptions(l_api_name
                                                    ,g_pkg_name
                                                    ,'OKL_API.G_RET_STS_ERROR'
                                                    ,x_msg_count
                                                    ,x_msg_data
                                                    ,'_PVT');
      WHEN okl_api.g_exception_unexpected_error THEN
        x_return_status := okl_api.handle_exceptions(l_api_name
                                                    ,g_pkg_name
                                                    ,'OKL_API.G_RET_STS_UNEXP_ERROR'
                                                    ,x_msg_count
                                                    ,x_msg_data
                                                    ,'_PVT');
      WHEN OTHERS THEN
        x_return_status := okl_api.handle_exceptions(l_api_name
                                                    ,g_pkg_name
                                                    ,'OTHERS'
                                                    ,x_msg_count
                                                    ,x_msg_data
                                                    ,'_PVT');
  END enddate_std_rate_tmpl;

END okl_fe_std_rate_tmpl_pvt;

/
