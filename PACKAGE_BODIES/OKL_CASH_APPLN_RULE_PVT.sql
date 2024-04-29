--------------------------------------------------------
--  DDL for Package Body OKL_CASH_APPLN_RULE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_CASH_APPLN_RULE_PVT" AS
/* $Header: OKLRCSLB.pls 120.6.12010000.2 2010/02/19 11:11:05 nikshah ship $ */

  ---------------------------------------------------------------------------
  -- Procedures and Functions
  ---------------------------------------------------------------------------
  PROCEDURE manipulate_rule(
     p_api_version              IN NUMBER,
     p_init_msg_list            IN VARCHAR2 DEFAULT okl_api.G_FALSE,
     p_catv_rec                 IN catv_rec_type,
     x_catv_rec                 OUT NOCOPY catv_rec_type,
     x_return_status            OUT NOCOPY VARCHAR2,
     x_msg_count                OUT NOCOPY NUMBER,
     x_msg_data                 OUT NOCOPY VARCHAR2) IS

     l_api_name                 CONSTANT VARCHAR2(30) := 'manipulate_rule';
     l_return_status            VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;

     date_invalid_err         CONSTANT VARCHAR2(30) := 'INVALID';
     date_gap_err             CONSTANT VARCHAR2(30) := 'GAP';
     date_overlap_err         CONSTANT VARCHAR2(30) := 'OVERLAP';
     date_enddate_err         CONSTANT VARCHAR2(30) := 'ENDDATE';

     lx_date_err              VARCHAR2(30) := NULL;

     l_catv_rec                 catv_rec_type;
     lx_catv_rec                catv_rec_type;

     l_prev_catv_rec            catv_rec_type;
     lx_prev_catv_rec           catv_rec_type;

     l_cauv_rec                 cauv_rec_type;
     lx_cauv_rec                cauv_rec_type;

     l_default_cau_id           OKL_CASH_ALLCTN_RLS.cau_id%type := NULL;
     l_end_date                 OKL_CASH_ALLCTN_RLS.end_date%type := NULL;
     l_rule_name                OKL_CASH_ALLCTN_RLS.name%type := NULL;
     l_req_field_miss           BOOLEAN := FALSE;

     --Bug 8633025 - NIKSHAH
     l_def_catv_tbl catv_tbl_type;
     x_def_catv_tbl catv_tbl_type;
     l_counter      NUMBER;

     CURSOR l_cau_obj_ver_csr(cp_id IN l_cauv_rec.id%TYPE) IS
     SELECT object_version_number
     , name
     FROM OKL_CSH_ALLCTN_RL_HDR
     WHERE id = cp_id;

     CURSOR l_cau_name_csr(cp_name IN l_cauv_rec.name%TYPE) IS
     SELECT name
     FROM OKL_CSH_ALLCTN_RL_HDR
     WHERE name = cp_name;


     CURSOR l_end_date_csr(cp_id IN OKL_CASH_ALLCTN_RLS.id%TYPE) IS
     SELECT end_date
     FROM OKL_CASH_ALLCTN_RLS
     WHERE id = cp_id;

     CURSOR l_prev_line_csr(cp_cau_id IN OKL_CASH_ALLCTN_RLS.cau_id%TYPE) IS
     SELECT id
     , object_version_number
     , start_date
     , end_date
     FROM OKL_CASH_ALLCTN_RLS
     WHERE cau_id = cp_cau_id
     ORDER BY id DESC;

     --Added below cursor for getting default rules of an active date
     --Bug 8633025 - NIKSHAH
     CURSOR l_def_rule_csr IS
     SELECT id
     FROM   OKL_CASH_ALLCTN_RLS
     WHERE  DEFAULT_RULE = 'YES'
       AND  TRUNC(NVL(END_DATE, SYSDATE)) >= TRUNC(SYSDATE);

     --Validate start and end dates
     FUNCTION validate_dates(p_catv_rec IN catv_rec_type
                            ,x_err_type OUT NOCOPY VARCHAR2) RETURN VARCHAR2 IS
       l_catv_rec catv_rec_type := p_catv_rec;
       l_return_status            VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;

       /*TYPE date_range_type IS RECORD (start_date  DATE := NULL
                                      ,end_date    DATE := NULL);

       TYPE date_range_tbl_type IS TABLE OF date_range_type
       INDEX BY BINARY_INTEGER;

       date_tab date_range_tbl_type;*/

       --check for overlap in dates
       CURSOR l_date_overlap_csr(cp_id IN NUMBER
                                ,cp_cau_id IN NUMBER
                                ,cp_start_date IN DATE
                                ,cp_end_date IN DATE) IS
       SELECT start_date, end_date
       FROM OKL_CASH_ALLCTN_RLS
       WHERE cau_id = nvl(cp_cau_id, -99)
       AND id <> nvl(cp_id, -99)
       AND (trunc(cp_start_date) between trunc(start_date) and trunc(nvl(end_date, cp_start_date))
            OR trunc(nvl(cp_end_date, cp_start_date)) between trunc(start_date) and trunc(end_date));

       --check for gaps in date ranges
       CURSOR l_date_bef_gap_csr(cp_id IN NUMBER
                                ,cp_cau_id IN NUMBER
                                ,cp_start_date IN DATE
                                ,cp_end_date IN DATE) IS
       SELECT start_date, end_date
       FROM OKL_CASH_ALLCTN_RLS
       WHERE cau_id = nvl(cp_cau_id, -99)
       AND id <> nvl(cp_id, -99)
       AND (trunc(end_date) < trunc(cp_start_date))
             --OR (nvl(cp_end_date, cp_start_date) < start_date))
       ORDER BY start_date desc;


       CURSOR l_date_aft_gap_csr(cp_id IN NUMBER
                                ,cp_cau_id IN NUMBER
                                ,cp_start_date IN DATE
                                ,cp_end_date IN DATE) IS
       SELECT start_date, end_date
       FROM OKL_CASH_ALLCTN_RLS
       WHERE cau_id = nvl(cp_cau_id, -99)
       AND id <> nvl(cp_id, -99)
       AND (trunc(nvl(cp_end_date, cp_start_date)) < trunc(start_date))
       ORDER BY start_date asc;
     BEGIN
       --pgomes 01/13/2003 commented out code
       --check for mandatory end date is removed
       /*
       IF(nvl(l_catv_rec.default_rule, okl_api.g_miss_char) = okl_api.g_miss_char) THEN
         IF(NVL(l_catv_rec.end_date, okl_api.g_miss_date) =  okl_api.g_miss_date) THEN
           --dbms_output.put_line('end date null');
           x_err_type := date_enddate_err;
           l_return_status := Okl_Api.G_RET_STS_ERROR;
         END IF;
       END IF;
       */

       IF (l_return_status = Okl_Api.G_RET_STS_SUCCESS) THEN
         IF(l_catv_rec.start_date > NVL(l_catv_rec.end_date, l_catv_rec.start_date)) THEN
           --dbms_output.put_line('start date > end date');
           x_err_type := date_invalid_err;
           l_return_status := Okl_Api.G_RET_STS_ERROR;
         END IF;
       END IF;

       --check for overlaps
       IF (l_return_status = Okl_Api.G_RET_STS_SUCCESS) THEN
         FOR cur IN l_date_overlap_csr(l_catv_rec.id, l_catv_rec.cau_id, l_catv_rec.start_date, l_catv_rec.end_date) LOOP
           --dbms_output.put_line('overlap  in dates');
           x_err_type := date_overlap_err;
           l_return_status := Okl_Api.G_RET_STS_ERROR;
         END LOOP;
       END IF;

       --check for gaps in start date
       IF (l_return_status = Okl_Api.G_RET_STS_SUCCESS) THEN
         FOR cur IN l_date_bef_gap_csr(l_catv_rec.id, l_catv_rec.cau_id, l_catv_rec.start_date, l_catv_rec.end_date) LOOP
           IF ((trunc(l_catv_rec.start_date) - trunc(cur.end_date)) > 1) THEN
             --dbms_output.put_line('gap  between dates : before');
             x_err_type := date_gap_err;
             l_return_status := Okl_Api.G_RET_STS_ERROR;
           END IF;
           EXIT;
         END LOOP;
       END IF;

       --check for gaps in end date
       IF (l_return_status = Okl_Api.G_RET_STS_SUCCESS) THEN
         FOR cur IN l_date_aft_gap_csr(l_catv_rec.id, l_catv_rec.cau_id, l_catv_rec.start_date, l_catv_rec.end_date) LOOP
           IF ((trunc(cur.start_date) - trunc(nvl(l_catv_rec.end_date, l_catv_rec.start_date))) > 1) THEN
             --dbms_output.put_line('gap  between dates : after');
             x_err_type := date_gap_err;
             l_return_status := Okl_Api.G_RET_STS_ERROR;
           END IF;
           EXIT;
         END LOOP;
       END IF;

       IF(x_err_type = date_enddate_err) THEN
         OKL_API.SET_MESSAGE(p_app_name => G_APP_NAME,
                            p_msg_name => 'OKL_BPD_CASH_APPLN_DATE_END');
       ELSIF(x_err_type = date_invalid_err) THEN
         OKL_API.SET_MESSAGE(p_app_name => G_APP_NAME,
                            p_msg_name => 'OKL_BPD_CASH_APPLN_DATE_ERROR');
       ELSIF(x_err_type = date_overlap_err) THEN
         OKL_API.SET_MESSAGE(p_app_name => G_APP_NAME,
                            p_msg_name => 'OKL_BPD_CASH_APPLN_DATE_OVER');
       ELSIF(x_err_type = date_gap_err) THEN
         OKL_API.SET_MESSAGE(p_app_name => G_APP_NAME,
                            p_msg_name => 'OKL_BPD_CASH_APPLN_DATE_GAP');
       END IF;

       RETURN l_return_status;
     END validate_dates;

    --Validate default rule
    --if a default rule exists, cau_id of the default rule is returned
    --Commented by NIKSHAH, bug 8633025
    /*
    FUNCTION validate_default_rule(p_catv_rec IN catv_rec_type) RETURN NUMBER IS
       l_catv_rec catv_rec_type := p_catv_rec;
       l_default_cau_id       OKL_CASH_ALLCTN_RLS.cau_id%type := NULL;

       CURSOR l_def_csr(cp_cau_id IN NUMBER) IS
       SELECT cau_id
       FROM OKL_CASH_ALLCTN_RLS
       WHERE ((NVL(l_catv_rec.cau_id, okl_api.g_miss_num)  = okl_api.g_miss_num) OR
              (l_catv_rec.cau_id IS NOT NULL AND cau_id = cp_cau_id))
       AND default_rule = 'YES';
    BEGIN
       FOR cur IN l_def_csr(l_catv_rec.cau_id) LOOP
         --dbms_output.put_line('default rule');
         l_default_cau_id := cur.cau_id;
         EXIT;
       END LOOP;
       RETURN l_default_cau_id;
    END validate_default_rule;
    */

  BEGIN
    l_catv_rec := p_catv_rec;

    --check for required fields
    IF (l_catv_rec.name = Okl_Api.G_MISS_CHAR or l_catv_rec.name IS NULL) THEN
      l_req_field_miss := TRUE;
    END IF;

    IF (l_catv_rec.description = Okl_Api.G_MISS_CHAR or l_catv_rec.description IS NULL) THEN
      l_req_field_miss := TRUE;
    END IF;

    IF (l_catv_rec.start_date = Okl_Api.G_MISS_DATE or l_catv_rec.start_date  IS NULL) THEN
      l_req_field_miss := TRUE;
    END IF;

    /*IF (l_catv_rec.end_date = Okl_Api.G_MISS_DATE or l_catv_rec.end_date IS NULL) THEN
      l_req_field_miss := TRUE;
    END IF;*/

    IF (l_catv_rec.amount_tolerance_percent = Okl_Api.G_MISS_NUM or l_catv_rec.amount_tolerance_percent  IS NULL) THEN
      l_req_field_miss := TRUE;
    END IF;

    IF (l_catv_rec.days_past_quote_valid_toleranc = Okl_Api.G_MISS_NUM or l_catv_rec.days_past_quote_valid_toleranc IS NULL) THEN
      l_req_field_miss := TRUE;
    END IF;
    -- sjalasut. removed validation as part of user defined streams build.
    /*IF (l_catv_rec.months_to_bill_ahead = Okl_Api.G_MISS_NUM or l_catv_rec.months_to_bill_ahead  IS NULL) THEN
      l_req_field_miss := TRUE;
    END IF;*/

    IF(l_req_field_miss) THEN
       OKC_API.set_message( p_app_name    => G_APP_NAME,
                           p_msg_name    =>'OKL_BPD_MISSING_FIELDS');

       l_return_status := OKC_API.G_RET_STS_ERROR;
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;


    l_cauv_rec.id := l_catv_rec.cau_id;
    l_cauv_rec.name := l_catv_rec.name;
    l_cauv_rec.description := l_catv_rec.description;

    IF ((l_catv_rec.id IS NULL or l_catv_rec.id = okl_api.g_miss_num)
       and (l_catv_rec.cau_id IS NULL or l_catv_rec.cau_id = okl_api.g_miss_num)) THEN
    --CREATE HDR AND LINE

      --check for unique rule name
      FOR cur IN l_cau_name_csr(l_cauv_rec.name) LOOP
        OKL_API.SET_MESSAGE(p_app_name => G_APP_NAME,
                            p_msg_name => 'OKL_BPD_CASH_APPLN_NAME_ERROR',
                            p_token1       => 'RULE_NAME',
                            p_token1_value => cur.name);
        l_return_status := okl_api.G_RET_STS_ERROR;
        raise G_EXCEPTION_HALT_VALIDATION;
      END LOOP;

      --check if line is a default line
      --Modified as part of bug 8633025 by NIKSHAH
      /*l_default_cau_id := validate_default_rule(l_catv_rec);
      IF (l_default_cau_id IS NULL) THEN
        l_catv_rec.default_rule := 'YES';
        l_catv_rec.end_date := null;
      END IF; */

      --If default rule checkbox was checked then make other rules as
      --non default
      IF l_catv_rec.default_rule = 'YES' THEN
        l_counter := 1;
        FOR l_def_rec IN l_def_rule_csr
        LOOP
          l_def_catv_tbl(l_counter).id := l_def_rec.id;
          l_def_catv_tbl(l_counter).default_rule := 'NO';
          l_counter := l_counter + 1;
        END LOOP;

        IF l_counter > 1 THEN
          Okl_Cash_Allctn_Rls_Pub.update_cash_allctn_rls
            (p_api_version => p_api_version
            ,p_init_msg_list => p_init_msg_list
            ,x_return_status => l_return_status
            ,x_msg_count => x_msg_count
            ,x_msg_data => x_msg_data
            ,p_catv_tbl => l_def_catv_tbl
            ,x_catv_tbl => x_def_catv_tbl);

          IF(l_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
            OKL_API.SET_MESSAGE(p_app_name => G_APP_NAME,
                                p_msg_name => 'OKL_BPD_CASH_APPLN_LN_ERROR');
            raise okl_api.G_EXCEPTION_ERROR;
          END IF;
        END IF;
      END IF;

      IF((trunc(l_catv_rec.start_date) < trunc(sysdate)) OR
         --(l_catv_rec.end_date = okl_api.g_miss_date) OR
         (nvl(l_catv_rec.end_date, l_catv_rec.start_date) < trunc(sysdate))
         ) THEN
        OKL_API.SET_MESSAGE(p_app_name => G_APP_NAME,
                            p_msg_name => 'OKL_BPD_CASH_APPLN_DATE_PAST');

        l_return_status := Okl_Api.G_RET_STS_ERROR;
        raise G_EXCEPTION_HALT_VALIDATION;
      END IF;

      --Validate dates
      l_return_status := validate_dates(l_catv_rec, lx_date_err);
      IF(l_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
        /*OKL_API.SET_MESSAGE(p_app_name => G_APP_NAME,
                            p_msg_name => 'OKL_BPD_CASH_APPLN_DATE_ERROR');*/
        raise G_EXCEPTION_HALT_VALIDATION;
      END IF;

      --create rule hdr and line
      IF (l_return_status = Okl_Api.G_RET_STS_SUCCESS) THEN
        --create rule hdr
        okl_csh_allctn_rl_hdr_pub.insert_csh_allctn_rl_hdr(
           p_api_version => p_api_version
          ,p_init_msg_list => p_init_msg_list
          ,x_return_status => l_return_status
          ,x_msg_count => x_msg_count
          ,x_msg_data => x_msg_data
          ,p_cauv_rec => l_cauv_rec
          ,x_cauv_rec => lx_cauv_rec);

        IF(l_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
          OKL_API.SET_MESSAGE(p_app_name => G_APP_NAME,
                              p_msg_name => 'OKL_BPD_CASH_APPLN_HDR_ERROR');
          raise okl_api.G_EXCEPTION_ERROR;
        END IF;

        l_catv_rec.cau_id := lx_cauv_rec.id;
        IF (l_catv_rec.under_payment_allocation_code IS NULL or l_catv_rec.under_payment_allocation_code = okl_api.g_miss_char) THEN
          l_catv_rec.under_payment_allocation_code := 'T';
        END IF;

        IF (l_catv_rec.over_payment_allocation_code IS NULL or l_catv_rec.over_payment_allocation_code = okl_api.g_miss_char) THEN
          l_catv_rec.over_payment_allocation_code := 'M';
        END IF;

        IF (l_catv_rec.receipt_msmtch_allocation_code IS NULL or l_catv_rec.receipt_msmtch_allocation_code = okl_api.g_miss_char) THEN
          l_catv_rec.receipt_msmtch_allocation_code := 'A';
        END IF;

        --create rule line
        Okl_Cash_Allctn_Rls_Pub.insert_cash_allctn_rls(
           p_api_version => p_api_version
          ,p_init_msg_list => p_init_msg_list
          ,x_return_status => l_return_status
          ,x_msg_count => x_msg_count
          ,x_msg_data => x_msg_data
          ,p_catv_rec => l_catv_rec
          ,x_catv_rec => lx_catv_rec);

        IF(l_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
          OKL_API.SET_MESSAGE(p_app_name => G_APP_NAME,
                              p_msg_name => 'OKL_BPD_CASH_APPLN_LN_ERROR');
          raise okl_api.G_EXCEPTION_ERROR;
        END IF;
      END IF;
    ELSIF ((l_catv_rec.id IS NOT NULL) and (l_catv_rec.id <> okl_api.g_miss_num)
           and l_catv_rec.cau_id IS NOT NULL) THEN
    --UPDATE HDR AND LINE

      --check if line is a default line
      --If default rule checkbox was checked then make other rules as
      --non default

      /* l_default_cau_id := validate_default_rule(l_catv_rec);
      IF (l_catv_rec.cau_id = l_default_cau_id) THEN
        l_catv_rec.default_rule := 'YES';

        --check if the line had an end date
        --if it did not, then update the end date to null
        l_end_date := null;
        FOR cur IN l_end_date_csr(l_catv_rec.id) LOOP
          l_end_date := cur.end_date;
        END LOOP;
        l_catv_rec.end_date := l_end_date;
      END IF; */
      IF l_catv_rec.default_rule = 'YES' THEN
        l_counter := 1;
        FOR l_def_rec IN l_def_rule_csr
        LOOP
          l_def_catv_tbl(l_counter).id := l_def_rec.id;
          l_def_catv_tbl(l_counter).default_rule := 'NO';
          l_counter := l_counter + 1;
        END LOOP;

        IF l_counter > 1 THEN
          Okl_Cash_Allctn_Rls_Pub.update_cash_allctn_rls
            (p_api_version => p_api_version
            ,p_init_msg_list => p_init_msg_list
            ,x_return_status => l_return_status
            ,x_msg_count => x_msg_count
            ,x_msg_data => x_msg_data
            ,p_catv_tbl => l_def_catv_tbl
            ,x_catv_tbl => x_def_catv_tbl);

          IF(l_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
            OKL_API.SET_MESSAGE(p_app_name => G_APP_NAME,
                                p_msg_name => 'OKL_BPD_CASH_APPLN_LN_ERROR');
            raise okl_api.G_EXCEPTION_ERROR;
          END IF;
        END IF;
      END IF;

      --Validate dates
      l_return_status := validate_dates(l_catv_rec, lx_date_err);
      IF(l_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
        /*OKL_API.SET_MESSAGE(p_app_name => G_APP_NAME,
                            p_msg_name => 'OKL_BPD_CASH_APPLN_DATE_ERROR');*/
        raise G_EXCEPTION_HALT_VALIDATION;
      END IF;

      --update rule hdr and line
      IF (l_return_status = Okl_Api.G_RET_STS_SUCCESS) THEN
        --get hdr version
        FOR cur IN l_cau_obj_ver_csr(l_cauv_rec.id) LOOP
          l_cauv_rec.object_version_number := cur.object_version_number;
        END LOOP;

        --update rule hdr
        okl_csh_allctn_rl_hdr_pub.update_csh_allctn_rl_hdr(
           p_api_version => p_api_version
          ,p_init_msg_list => p_init_msg_list
          ,x_return_status => l_return_status
          ,x_msg_count => x_msg_count
          ,x_msg_data => x_msg_data
          ,p_cauv_rec => l_cauv_rec
          ,x_cauv_rec => lx_cauv_rec);

        IF(l_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
          OKL_API.SET_MESSAGE(p_app_name => G_APP_NAME,
                              p_msg_name => 'OKL_BPD_CASH_APPLN_HDR_ERROR');
          raise okl_api.G_EXCEPTION_ERROR;
        END IF;


        --update rule line
        Okl_Cash_Allctn_Rls_Pub.update_cash_allctn_rls(
           p_api_version => p_api_version
          ,p_init_msg_list => p_init_msg_list
          ,x_return_status => l_return_status
          ,x_msg_count => x_msg_count
          ,x_msg_data => x_msg_data
          ,p_catv_rec => l_catv_rec
          ,x_catv_rec => lx_catv_rec);

        IF(l_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
          OKL_API.SET_MESSAGE(p_app_name => G_APP_NAME,
                              p_msg_name => 'OKL_BPD_CASH_APPLN_LN_ERROR');
          raise okl_api.G_EXCEPTION_ERROR;
        END IF;
      END IF;
    -- sjalasut. case of creating a new rule version
    ELSIF ((l_catv_rec.id IS NULL or l_catv_rec.id = okl_api.g_miss_num) and l_catv_rec.cau_id IS NOT NULL) THEN
      --UPDATE HEADER CREATE LINE ONLY
      --check to see if the version name passed is the same as the original rule
      FOR cur IN l_cau_obj_ver_csr(l_catv_rec.cau_id) LOOP
          l_rule_name := cur.name;

          IF (l_rule_name <> l_catv_rec.name) THEN
          OKL_API.SET_MESSAGE(p_app_name => G_APP_NAME,
                              p_msg_name => 'OKL_BPD_CASH_APPLN_NAME_VER');
          l_return_status := Okl_Api.G_RET_STS_ERROR;
          raise G_EXCEPTION_HALT_VALIDATION;
          END IF;
      END LOOP;

      --check if dates of new version are in the past
      IF((trunc(l_catv_rec.start_date) < trunc(sysdate)) OR
         --(l_catv_rec.end_date = okl_api.g_miss_date) OR
         (nvl(l_catv_rec.end_date, l_catv_rec.start_date) < trunc(sysdate))
         ) THEN
        OKL_API.SET_MESSAGE(p_app_name => G_APP_NAME,
                            p_msg_name => 'OKL_BPD_CASH_APPLN_DATE_PAST');

        l_return_status := Okl_Api.G_RET_STS_ERROR;
        raise G_EXCEPTION_HALT_VALIDATION;
      END IF;

      --Update the end date of previous line to (start date minus 1) of the new line
      FOR cur IN l_prev_line_csr(l_catv_rec.cau_id) LOOP
        l_prev_catv_rec.id := cur.id;
        l_prev_catv_rec.object_version_number := cur.object_version_number;
        l_prev_catv_rec.start_date := cur.start_date;
        l_prev_catv_rec.end_date := trunc(l_catv_rec.start_date) - 1;
        EXIT;
      END LOOP;

      --Validate dates for prev line
      l_return_status := validate_dates(l_prev_catv_rec, lx_date_err);
      IF(l_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
        /*OKL_API.SET_MESSAGE(p_app_name => G_APP_NAME,
                          p_msg_name => 'OKL_BPD_CASH_APPLN_DATE_ERROR');*/
        raise G_EXCEPTION_HALT_VALIDATION;
      END IF;

      --update prev rule line
      Okl_Cash_Allctn_Rls_Pub.update_cash_allctn_rls(
         p_api_version => p_api_version
        ,p_init_msg_list => p_init_msg_list
        ,x_return_status => l_return_status
        ,x_msg_count => x_msg_count
        ,x_msg_data => x_msg_data
        ,p_catv_rec => l_prev_catv_rec
        ,x_catv_rec => lx_prev_catv_rec);

      IF(l_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
        OKL_API.SET_MESSAGE(p_app_name => G_APP_NAME,
                            p_msg_name => 'OKL_BPD_CASH_APPLN_LN_ERROR');
        raise okl_api.G_EXCEPTION_ERROR;
      END IF;
      --check if line is a default line
      --If default rule checkbox was checked then make other rules as
      --non default
      /*
      l_default_cau_id := validate_default_rule(l_catv_rec);
      IF(l_catv_rec.cau_id = l_default_cau_id)THEN
        l_catv_rec.default_rule := 'YES';
        l_catv_rec.end_date := null;
      ELSE
        l_catv_Rec.default_rule := null;
      END IF; */
      IF l_catv_rec.default_rule = 'YES' THEN
        l_counter := 1;
        FOR l_def_rec IN l_def_rule_csr
        LOOP
          l_def_catv_tbl(l_counter).id := l_def_rec.id;
          l_def_catv_tbl(l_counter).default_rule := 'NO';
          l_counter := l_counter + 1;
        END LOOP;

        IF l_counter > 1 THEN
          Okl_Cash_Allctn_Rls_Pub.update_cash_allctn_rls
            (p_api_version => p_api_version
            ,p_init_msg_list => p_init_msg_list
            ,x_return_status => l_return_status
            ,x_msg_count => x_msg_count
            ,x_msg_data => x_msg_data
            ,p_catv_tbl => l_def_catv_tbl
            ,x_catv_tbl => x_def_catv_tbl);

          IF(l_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
            OKL_API.SET_MESSAGE(p_app_name => G_APP_NAME,
                                p_msg_name => 'OKL_BPD_CASH_APPLN_LN_ERROR');
            raise okl_api.G_EXCEPTION_ERROR;
          END IF;
        END IF;
      END IF;

      --Validate dates
      l_return_status := validate_dates(l_catv_rec, lx_date_err);
      IF(l_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
        /*OKL_API.SET_MESSAGE(p_app_name => G_APP_NAME,
                            p_msg_name => 'OKL_BPD_CASH_APPLN_DATE_ERROR');*/
        raise G_EXCEPTION_HALT_VALIDATION;
      END IF;

      IF (l_return_status = Okl_Api.G_RET_STS_SUCCESS) THEN
        --get hdr version
        FOR cur IN l_cau_obj_ver_csr(l_cauv_rec.id) LOOP
          l_cauv_rec.object_version_number := cur.object_version_number;
        END LOOP;

        --update rule hdr
        okl_csh_allctn_rl_hdr_pub.update_csh_allctn_rl_hdr(
           p_api_version => p_api_version
          ,p_init_msg_list => p_init_msg_list
          ,x_return_status => l_return_status
          ,x_msg_count => x_msg_count
          ,x_msg_data => x_msg_data
          ,p_cauv_rec => l_cauv_rec
          ,x_cauv_rec => lx_cauv_rec);

        IF(l_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
          OKL_API.SET_MESSAGE(p_app_name => G_APP_NAME,
                              p_msg_name => 'OKL_BPD_CASH_APPLN_HDR_ERROR');
          raise okl_api.G_EXCEPTION_ERROR;
        END IF;


        --create rule line
        Okl_Cash_Allctn_Rls_Pub.insert_cash_allctn_rls(
           p_api_version => p_api_version
          ,p_init_msg_list => p_init_msg_list
          ,x_return_status => l_return_status
          ,x_msg_count => x_msg_count
          ,x_msg_data => x_msg_data
          ,p_catv_rec => l_catv_rec
          ,x_catv_rec => lx_catv_rec);

        IF(l_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
          OKL_API.SET_MESSAGE(p_app_name => G_APP_NAME,
                              p_msg_name => 'OKL_BPD_CASH_APPLN_LN_ERROR');
          raise okl_api.G_EXCEPTION_ERROR;
        END IF;
      END IF;
    ELSE
      null;
    END IF;

    IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
      RAISE okl_api.G_EXCEPTION_ERROR;
    END IF;

    x_catv_rec := lx_catv_rec;
    x_return_status := l_return_status;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      x_return_status := l_return_status;
    WHEN OTHERS THEN
      OKL_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM
                          ,p_token3       => 'Package'
                          ,p_token3_value => G_PKG_NAME
                          ,p_token4       => 'Procedure'
                          ,p_token4_value => l_api_name
                          );
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
  END manipulate_rule;

  ---------------------------------------------------------------------------
  -- PROCEDURE maint_cash_appln_rule
  ---------------------------------------------------------------------------
  PROCEDURE maint_cash_appln_rule(
     p_api_version              IN NUMBER,
     p_init_msg_list            IN VARCHAR2 DEFAULT okl_api.G_FALSE,
     p_catv_tbl                 IN catv_tbl_type,
     x_catv_tbl                 OUT NOCOPY catv_tbl_type,
     x_return_status            OUT NOCOPY VARCHAR2,
     x_msg_count                OUT NOCOPY NUMBER,
     x_msg_data                 OUT NOCOPY VARCHAR2) IS

     l_return_status            VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
     l_api_version              CONSTANT NUMBER := 1;
     l_api_name                 CONSTANT VARCHAR2(30) := 'maint_cash_appln_rule';

     l_catv_rec                 catv_rec_type;
     l_catv_tbl                 catv_tbl_type;

     lx_catv_rec                catv_rec_type;
     lx_catv_tbl                catv_tbl_type;

     cnt                        NUMBER;
  BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              l_return_status);

    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    -- Processing starts
    l_catv_tbl := p_catv_tbl;

    cnt := l_catv_tbl.FIRST;
    WHILE (cnt IS NOT NULL)
    LOOP
      l_catv_rec := l_catv_tbl(cnt);
      --dbms_output.put_line(l_catv_rec.id || ' : ' || l_catv_rec.name);

      --call to api that does record level manipulation
      manipulate_rule(
           p_api_version => l_api_version,
           p_init_msg_list => p_init_msg_list,
           p_catv_rec => l_catv_rec,
           x_catv_rec => lx_catv_rec,
           x_return_status => l_return_status,
           x_msg_count => x_msg_count,
           x_msg_data => x_msg_data);

      IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
        RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
        RAISE okl_api.G_EXCEPTION_ERROR;
      END IF;

      lx_catv_tbl(cnt) := lx_catv_rec;
      cnt := l_catv_tbl.NEXT(cnt);
    END LOOP;

    -- Processing ends
    x_catv_tbl := lx_catv_tbl;
    x_return_status := l_return_status;
    okl_api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END maint_cash_appln_rule;

  ---------------------------------------------------------------------------
  -- FUNCTION get_strm_typ_allocs
  ---------------------------------------------------------------------------
  FUNCTION get_strm_typ_allocs(
     p_cat_id IN NUMBER,
     p_sty_id IN NUMBER,
     p_stream_allc_type IN VARCHAR2,
     p_out_field IN VARCHAR2 DEFAULT 'ALL') RETURN VARCHAR2 IS

    lx_retval VARCHAR2(100) := NULL;
  BEGIN
    SELECT DECODE(p_out_field, 'SEQ', TO_CHAR(sequence_number), 'SAT', stream_allc_type, '$' || sequence_number || '$' || stream_allc_type || '$')
    INTO lx_retval from OKL_STRM_TYP_ALLOCS
    WHERE cat_id = p_cat_id
    AND sty_id = p_sty_id
    AND stream_allc_type = p_stream_allc_type;

    RETURN lx_retval;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN lx_retval;
  END get_strm_typ_allocs;

END OKL_CASH_APPLN_RULE_PVT;

/
