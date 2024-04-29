--------------------------------------------------------
--  DDL for Package Body OKL_SETUP_DISB_RULES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_SETUP_DISB_RULES_PVT" AS
/* $Header: OKLRSDRB.pls 120.10 2007/08/17 09:35:12 gkhuntet noship $ */

  PROCEDURE validate_rule_eff_dates( p_api_version             IN  NUMBER
                                   , p_init_msg_list           IN  VARCHAR2 DEFAULT FND_API.G_FALSE
                                   , x_return_status           OUT NOCOPY VARCHAR2
                                   , x_msg_count               OUT NOCOPY NUMBER
                                   , x_msg_data                OUT NOCOPY VARCHAR2
                                   , p_drav_rec                IN  drav_rec_type
                                   , p_drs_tbl                 IN  drs_tbl_type
                                   , p_drv_tbl                 IN  drv_tbl_type
                                   )
    IS
    l_api_name          CONSTANT VARCHAR2(40) := 'validate_rule_eff_dates';
    l_api_version       CONSTANT NUMBER       := 1;
    l_init_msg_list     VARCHAR2(1);
    sty_count           NUMBER;
    vsite_count         NUMBER;
    l_disb_start_date   OKL_DISB_RULES_B.START_DATE%TYPE;
    l_disb_end_date     OKL_DISB_RULES_B.END_DATE%TYPE;
    l_vsite_start_date  OKL_DISB_RULE_VENDOR_SITES.START_DATE%TYPE;
    l_vsite_end_date    OKL_DISB_RULE_VENDOR_SITES.END_DATE%TYPE;
    l_exist_start_date  OKL_DISB_RULE_VENDOR_SITES.START_DATE%TYPE;
    l_exist_end_date    OKL_DISB_RULE_VENDOR_SITES.END_DATE%TYPE;


    CURSOR vendor_site_eff_dates_csr( p_sty_purpose IN  OKL_DISB_RULE_STY_TYPES.STREAM_TYPE_PURPOSE%TYPE
                                    , p_vendor_id IN  OKL_DISB_RULE_VENDOR_SITES.VENDOR_ID%TYPE
                                    , p_vendor_site_id IN OKL_DISB_RULE_VENDOR_SITES.VENDOR_SITE_ID%TYPE
                                    , p_disb_rule_vendor_site_id IN OKL_DISB_RULE_VENDOR_SITES.DISB_RULE_VENDOR_SITE_ID%TYPE)
      IS
      SELECT disb_vsites.start_date
           , disb_vsites.end_date
      FROM okl_disb_rule_sty_types disb_sty,
           okl_disb_rule_vendor_sites disb_vsites
      WHERE disb_sty.stream_type_purpose = p_sty_purpose
      AND disb_sty.disb_rule_id = disb_vsites.disb_rule_id
      AND disb_vsites.vendor_id = p_vendor_id
      AND disb_vsites.vendor_site_id = p_vendor_site_id
      AND disb_vsites.disb_rule_vendor_site_id <> NVL (p_disb_rule_vendor_site_id , -1);

    BEGIN
      -- Initialization
      x_return_status := OKL_API.G_RET_STS_SUCCESS;

      x_return_status := OKL_API.START_ACTIVITY( l_api_name
                                               , g_pkg_name
                                               , p_init_msg_list
                                               , l_api_version
                                               , p_api_version
                                               , '_PVT'
                                               , x_return_status);
      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      -- Check whether disbursement rule end date is less than start date
      l_disb_start_date := p_drav_rec.start_date;
      l_disb_end_date := p_drav_rec.end_date;

    ----g_debug_proc('DATE from DRAV  ' || l_disb_start_date || '  ' || l_disb_end_date);
    --DBMS_OUTPUT.PUT_LINE('Date count DRAV   ' || l_disb_start_date || '    ' || l_disb_end_date);

    IF ((l_disb_start_date IS NOT NULL) AND (l_disb_start_date <> FND_API.G_MISS_DATE)
           AND (l_disb_end_date IS NOT NULL) AND (l_disb_end_date <> FND_API.G_MISS_DATE)) THEN
        IF (l_disb_end_date < l_disb_start_date) THEN
             OKL_API.SET_MESSAGE( p_app_name => g_app_name
                             , p_msg_name => G_OKL_ST_DISB_EFF_DATE_ERR);
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
      END IF;

      -- Validate vendor sites effective dates
      IF ( p_drv_tbl.COUNT > 0 ) THEN
        FOR vsite_count IN p_drv_tbl.FIRST .. p_drv_tbl.LAST
        LOOP
          -- Check whether disbursement rule vendor site end date is less than start date

          l_vsite_start_date := p_drv_tbl(vsite_count).start_date;
          l_vsite_end_date := p_drv_tbl(vsite_count).end_date;


     --DBMS_OUTPUT.PUT_LINE('Date count  DRV ' || l_vsite_start_date || '    ' || l_vsite_end_date);
     --DBMS_OUTPUT.PUT_LINE('Date count DRAV   ' || l_disb_start_date || '    ' || l_disb_end_date);

          IF ((l_vsite_start_date IS NOT NULL) AND (l_vsite_start_date <> FND_API.G_MISS_DATE)
               AND (l_vsite_end_date IS NOT NULL) AND (l_vsite_end_date <> FND_API.G_MISS_DATE)) THEN
            IF (l_vsite_end_date < l_vsite_start_date) THEN
              OKL_API.SET_MESSAGE( p_app_name => g_app_name
                                 , p_msg_name => G_OKL_ST_DISB_VSITE_DATE_ERR);
              RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;
          END IF;

    ----g_debug_proc('DRV Check');

          -- Check whether vendor sites effective dates are within disbursement rules
          -- effective date range
     ----g_debug_proc('Date from DRV ' || vsite_count || '  ' || l_vsite_start_date || '    ' || l_vsite_end_date);

    --DBMS_OUTPUT.PUT_LINE('DATE COUNTE ');
          IF ((l_vsite_start_date IS NOT NULL) AND (l_vsite_start_date <> FND_API.G_MISS_DATE)
               AND (l_vsite_start_date < l_disb_start_date)) THEN
            OKL_API.SET_MESSAGE( p_app_name => g_app_name
                               , p_msg_name => G_OKL_ST_DISB_VSITE_DATE_ERR);
            --g_debug_proc('1');
            RAISE OKL_API.G_EXCEPTION_ERROR;
          ELSIF ((l_disb_end_date IS NOT NULL) AND (l_disb_end_date <> FND_API.G_MISS_DATE)
                  AND (l_vsite_start_date > l_disb_end_date)) THEN
            OKL_API.SET_MESSAGE( p_app_name => g_app_name
                               , p_msg_name => G_OKL_ST_DISB_VSITE_DATE_ERR);
            --g_debug_proc('2');
            RAISE OKL_API.G_EXCEPTION_ERROR;
          ELSIF ((l_vsite_end_date IS NOT NULL) AND (l_vsite_end_date <> FND_API.G_MISS_DATE)
                  AND (l_vsite_end_date > l_disb_end_date)) THEN
            OKL_API.SET_MESSAGE( p_app_name => g_app_name
                               , p_msg_name => G_OKL_ST_DISB_VSITE_DATE_ERR);
            --g_debug_proc('3');
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;
        END LOOP;
      END IF;

      --g_debug_proc('All Vendor sites effective dates are within disbursement rules dates.');

  --DBMS_OUTPUT.PUT_LINE('D1');
      -- Check whether effective dates overlaps with the existing vendor site effective dates
      -- for the same stream type purpose in any other disbursement rule.
      IF ( (p_drs_tbl.COUNT > 0) AND (p_drv_tbl.COUNT > 0) ) THEN
        FOR sty_count IN p_drs_tbl.FIRST .. p_drs_tbl.LAST
        LOOP
          -- Loop through all the vendor sites for the disbursement rule
          FOR vsite_count IN p_drv_tbl.FIRST .. p_drv_tbl.LAST
          LOOP
            FOR vsite_eff_dates_rec IN vendor_site_eff_dates_csr( p_drs_tbl(sty_count).stream_type_purpose
                                                                , p_drv_tbl(vsite_count).vendor_id
                                                                , p_drv_tbl(vsite_count).vendor_site_id
                                                                , p_drv_tbl(vsite_count).disb_rule_vendor_site_id)
            LOOP
                  --DBMS_OUTPUT.PUT_LINE('D2 a');
              l_exist_start_date := vsite_eff_dates_rec.start_date;
              l_exist_end_date := vsite_eff_dates_rec.end_date;
              l_vsite_start_date := p_drv_tbl(vsite_count).start_date;
              l_vsite_end_date := p_drv_tbl(vsite_count).end_date;
              IF ( (l_exist_start_date IS NOT NULL) AND (l_exist_start_date <> FND_API.G_MISS_DATE)) THEN
                IF ( (l_exist_end_date IS NOT NULL) AND (l_exist_end_date <> FND_API.G_MISS_DATE)) THEN
                  IF ( ((l_vsite_start_date IS NOT NULL) AND (l_vsite_start_date <> FND_API.G_MISS_DATE)
                        AND (l_vsite_start_date BETWEEN l_exist_start_date AND l_exist_end_date))
                                                  OR
                        ((l_vsite_end_date IS NOT NULL) AND (l_vsite_end_date <> FND_API.G_MISS_DATE)
                        AND (l_vsite_end_date BETWEEN l_exist_start_date AND l_exist_end_date)) ) THEN
                    OKL_API.SET_MESSAGE( p_app_name => g_app_name
                                       , p_msg_name => G_OKL_ST_DISB_VSITE_DATE_ERR);
                    RAISE OKL_API.G_EXCEPTION_ERROR;
                  END IF;
                ELSIF ((l_vsite_end_date IS NULL) OR (l_vsite_end_date = FND_API.G_MISS_DATE)
                        OR ( l_vsite_end_date > l_exist_start_date )) THEN
                     --DBMS_OUTPUT.PUT_LINE('D2 b');
                  OKL_API.SET_MESSAGE( p_app_name => g_app_name
                                     , p_msg_name => G_OKL_ST_DISB_VSITE_DATE_ERR);
                  RAISE OKL_API.G_EXCEPTION_ERROR;
                END IF;
              END IF;
            END LOOP;
          END LOOP;
        END LOOP;
      END IF;
   --g_debug_proc('effective dates overlaps with the existing vendor site effective dates');
  --DBMS_OUTPUT.PUT_LINE('D3');
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);

  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS( l_api_name
                                                 , g_pkg_name
                                                 , 'OKL_API.G_RET_STS_ERROR'
                                                 , x_msg_count
                                                 , x_msg_data
                                                 , '_PVT' );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS( l_api_name
                                                 , g_pkg_name
                                                 , 'OKL_API.G_RET_STS_UNEXP_ERROR'
                                                 , x_msg_count
                                                 , x_msg_data
                                                 , '_PVT' );
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS( l_api_name
                                                 , g_pkg_name
                                                 , 'OTHERS'
                                                 , x_msg_count
                                                 , x_msg_data
                                                 , '_PVT' );
  END validate_rule_eff_dates;


  -- Start of comments
  -- API name       : validate_sequence_range
  -- Pre-reqs       : None
  -- Function       : validates disbursement rule vendor sites sequence range.
  -- Parameters     :
  -- IN             : p_api_version - Standard input parameter
  --                  p_init_msg_list - Standard input parameter
  --                  p_drv_rec - record type for OKL_DISB_RULE_VENDOR_SITES
  -- Version        : 1.0
  -- History        : gboomina created.
  -- End of comments

  PROCEDURE validate_sequence_range( p_api_version             IN  NUMBER
                                   , p_init_msg_list           IN  VARCHAR2 DEFAULT FND_API.G_FALSE
                                   , x_return_status           OUT NOCOPY VARCHAR2
                                   , x_msg_count               OUT NOCOPY NUMBER
                                   , x_msg_data                OUT NOCOPY VARCHAR2
                                   , p_drv_tbl                 IN  drv_tbl_type
                                   )
    IS
    l_api_name          CONSTANT VARCHAR2(40) := 'validate_sequence_range';
    l_api_version       CONSTANT NUMBER       := 1;
    l_init_msg_list     VARCHAR2(1);
    vsite_count         NUMBER;
    l_new_seq_start        OKL_DISB_RULE_VENDOR_SITES.INVOICE_SEQ_START%TYPE;
    l_new_seq_end          OKL_DISB_RULE_VENDOR_SITES.INVOICE_SEQ_END%TYPE;
    l_existing_seq_start        OKL_DISB_RULE_VENDOR_SITES.INVOICE_SEQ_START%TYPE;
    l_existing_seq_end          OKL_DISB_RULE_VENDOR_SITES.INVOICE_SEQ_END%TYPE;


    CURSOR vendor_site_seq_range_csr( p_vendor_id IN  OKL_DISB_RULE_VENDOR_SITES.VENDOR_ID%TYPE
                                    , p_vendor_site_id IN OKL_DISB_RULE_VENDOR_SITES.VENDOR_SITE_ID%TYPE
                                    , p_disb_rule_vendor_site_id IN OKL_DISB_RULE_VENDOR_SITES.DISB_RULE_VENDOR_SITE_ID%TYPE)
      IS
      SELECT disb_vsites.invoice_seq_start
           , disb_vsites.invoice_seq_end
      FROM okl_disb_rule_vendor_sites disb_vsites
      WHERE disb_vsites.vendor_id = p_vendor_id
      AND disb_vsites.vendor_site_id = p_vendor_site_id
      AND disb_vsites.disb_rule_vendor_site_id <> NVL (p_disb_rule_vendor_site_id , -1) ;

    BEGIN
      -- Initialization
      x_return_status := OKL_API.G_RET_STS_SUCCESS;

      x_return_status := OKL_API.START_ACTIVITY( l_api_name
                                               , g_pkg_name
                                               , p_init_msg_list
                                               , l_api_version
                                               , p_api_version
                                               , '_PVT'
                                               , x_return_status);
      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
  --DBMS_OUTPUT.PUT_LINE('S1');
      IF (p_drv_tbl.COUNT > 0) THEN
        FOR vsite_count IN p_drv_tbl.FIRST .. p_drv_tbl.LAST
        LOOP
          l_new_seq_start := p_drv_tbl(vsite_count).invoice_seq_start;
          l_new_seq_end := p_drv_tbl(vsite_count).invoice_seq_end;
          -- Check whether new seq end is greater than seq start
          IF ((l_new_seq_start IS NOT NULL) AND (l_new_seq_start <> FND_API.G_MISS_NUM)
               AND (l_new_seq_end IS NOT NULL) AND (l_new_seq_end <> FND_API.G_MISS_NUM)
               AND (l_new_seq_end < l_new_seq_start)) THEN
                OKL_API.SET_MESSAGE( p_app_name => g_app_name
                                   , p_msg_name => G_OKL_ST_DISB_SEQ_RANGE_ERR);
                RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;

            --DBMS_OUTPUT.PUT_LINE('S2  ' || l_new_seq_start || '  ' || l_new_seq_end);
          -- Check whether vendor site seq range overlaps with the any
          -- existing rules vendor site seq range
          FOR vendor_site_seq_range_rec IN vendor_site_seq_range_csr( p_drv_tbl(vsite_count).vendor_id
                                                                    , p_drv_tbl(vsite_count).vendor_site_id
                                                                    , p_drv_tbl(vsite_count).disb_rule_vendor_site_id)
          LOOP
            l_existing_seq_start := vendor_site_seq_range_rec.invoice_seq_start;
            l_existing_seq_end := vendor_site_seq_range_rec.invoice_seq_end;
             --DBMS_OUTPUT.PUT_LINE('S2  ' || l_existing_seq_start || '  ' || l_existing_seq_end);
            IF ( (l_existing_seq_start IS NOT NULL) AND (l_existing_seq_start <> FND_API.G_MISS_NUM)) THEN
              IF ( (l_existing_seq_end IS NOT NULL) AND (l_existing_seq_end <> FND_API.G_MISS_NUM)) THEN
                IF ( ((l_new_seq_start IS NOT NULL) AND (l_new_seq_start <> FND_API.G_MISS_NUM)
                      AND (l_new_seq_start BETWEEN l_existing_seq_start AND l_existing_seq_end))
                                                OR
                      ((l_new_seq_end IS NOT NULL) AND (l_new_seq_end <> FND_API.G_MISS_NUM)
                      AND (l_new_seq_end BETWEEN l_existing_seq_start AND l_existing_seq_end)) ) THEN
                  OKL_API.SET_MESSAGE( p_app_name => g_app_name
                                     , p_msg_name => G_OKL_ST_DISB_SEQ_OVERLAP);
                  RAISE OKL_API.G_EXCEPTION_ERROR;
                END IF;
              ELSIF ((l_new_seq_end IS NULL) OR (l_new_seq_end = FND_API.G_MISS_NUM)
                      OR ( l_new_seq_end > l_existing_seq_start )) THEN
                OKL_API.SET_MESSAGE( p_app_name => g_app_name
                                   , p_msg_name => G_OKL_ST_DISB_SEQ_OVERLAP);
                RAISE OKL_API.G_EXCEPTION_ERROR;
              END IF;
            END IF;
          END LOOP;
        END LOOP;
      END IF;

        --DBMS_OUTPUT.PUT_LINE('S3');
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);

  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS( l_api_name
                                                 , g_pkg_name
                                                 , 'OKL_API.G_RET_STS_ERROR'
                                                 , x_msg_count
                                                 , x_msg_data
                                                 , '_PVT' );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS( l_api_name
                                                 , g_pkg_name
                                                 , 'OKL_API.G_RET_STS_UNEXP_ERROR'
                                                 , x_msg_count
                                                 , x_msg_data
                                                 , '_PVT' );
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS( l_api_name
                                                 , g_pkg_name
                                                 , 'OTHERS'
                                                 , x_msg_count
                                                 , x_msg_data
                                                 , '_PVT' );
  END validate_sequence_range;





  -- Start of comments
  -- API name       : validate_rule_eff_dates
  -- Pre-reqs       : None
  -- Function       : validates disbursement rule vendor sites effective dates.
  -- Parameters     :
  -- IN             : p_api_version - Standard input parameter
  --                  p_init_msg_list - Standard input parameter
  --                  p_drs_tbl - record type for OKL_DISB_RULE_STY_TYPES
  --                  p_drv_rec - record type for OKL_DISB_RULE_VENDOR_SITES
  -- Version        : 1.0
  -- History        : gboomina created.
  -- End of comments

   PROCEDURE del_disb_rule_vendor_sites( p_api_version      IN  NUMBER
                                         , p_init_msg_list    IN  VARCHAR2 DEFAULT FND_API.G_FALSE
                                         , x_return_status    OUT NOCOPY VARCHAR2
                                         , x_msg_count        OUT NOCOPY NUMBER
                                         , x_msg_data         OUT NOCOPY VARCHAR2
                                         , p_disb_rule_id     IN  okl_disb_rules_v.disb_rule_id%TYPE
                                         , p_vendor_id        IN  OKL_DISB_RULE_VENDOR_SITES.vendor_id%TYPE
                                         , p_new_drv_tbl      IN  drv_tbl_type
                                         )
    IS
    l_api_name          CONSTANT VARCHAR2(40) := 'del_disb_rule_vendor_sites';
    l_api_version       CONSTANT NUMBER       := 1;
    l_init_msg_list     VARCHAR2(1);
    i                   NUMBER;
    del_count           NUMBER := 0;
    l_found             VARCHAR2(1) := 'N';
    flag                BOOLEAN ;

    l_drv_del_tbl    drv_tbl_type;


  /*  CURSOR old_disb_vendor_sites_csr( p_disb_rule_id IN OKL_DISB_RULE_VENDOR_SITES.DISB_RULE_ID%TYPE )
    IS
      SELECT disb_rule_vendor_site_id
      FROM okl_disb_rule_vendor_sites
      WHERE disb_rule_id = p_disb_rule_id;
*/

    CURSOR old_disb_vendor_sites_csr( p_disb_rule_id IN OKL_DISB_RULE_VENDOR_SITES.DISB_RULE_ID%TYPE ,
                                      p_vendor_id    IN OKL_DISB_RULE_VENDOR_SITES.vendor_id%TYPE)
     IS
      SELECT disb_rule_vendor_site_id
      FROM okl_disb_rule_vendor_sites
      WHERE disb_rule_id = p_disb_rule_id
      AND   vendor_id = NVL(p_vendor_id , vendor_id);

    old_vendor_site_rec old_disb_vendor_sites_csr%ROWTYPE;

    BEGIN
    -- Initialization
    x_return_status := OKL_API.G_RET_STS_SUCCESS;

    x_return_status := OKL_API.START_ACTIVITY( l_api_name
                                             , g_pkg_name
                                             , p_init_msg_list
                                             , l_api_version
                                             , p_api_version
                                             , '_PVT'
                                             , x_return_status);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- If vendor sites available for the disbursement rule from DB
    -- is not found in the new vendor sites input table then delete it
    -- from the DB table.
   -- IF(p_vendor_id == NULL) THEN
       FOR old_vendor_site_rec IN old_disb_vendor_sites_csr(p_disb_rule_id , p_vendor_id) LOOP
          l_found := 'N';
        IF (p_new_drv_tbl.COUNT > 0 ) THEN
 	FOR i IN p_new_drv_tbl.FIRST .. p_new_drv_tbl.LAST LOOP
            IF (old_vendor_site_rec.disb_rule_vendor_site_id = p_new_drv_tbl(i).disb_rule_vendor_site_id) THEN
                  l_found := 'Y';
            END IF;
          END LOOP;
	END IF;
        IF (l_found = 'N') THEN
            l_drv_del_tbl(del_count).disb_rule_vendor_site_id := old_vendor_site_rec.disb_rule_vendor_site_id;
            l_drv_del_tbl(del_count).disb_rule_id := p_disb_rule_id;
            del_count := del_count + 1;
        END IF;
        END LOOP;

    IF ( l_drv_del_tbl.COUNT > 0 ) THEN
      -- delete record from OKL_DISB_RULE_VENDOR_SITES
      okl_drv_pvt.delete_row( p_api_version   => l_api_version
                            , p_init_msg_list => p_init_msg_list
                            , x_return_status => x_return_status
                            , x_msg_count     => x_msg_count
                            , x_msg_data      => x_msg_data
                            , p_drv_tbl       => l_drv_del_tbl);
      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    END IF;

    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);

  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS( l_api_name
                                                 , g_pkg_name
                                                 , 'OKL_API.G_RET_STS_ERROR'
                                                 , x_msg_count
                                                 , x_msg_data
                                                 , '_PVT' );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS( l_api_name
                                                 , g_pkg_name
                                                 , 'OKL_API.G_RET_STS_UNEXP_ERROR'
                                                 , x_msg_count
                                                 , x_msg_data
                                                 , '_PVT' );
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS( l_api_name
                                                 , g_pkg_name
                                                 , 'OTHERS'
                                                 , x_msg_count
                                                 , x_msg_data
                                                 , '_PVT' );
  END del_disb_rule_vendor_sites;


  -- Start of comments

  -- API name       : create_v_disbursement_rulete_v_disbursement_rule
  -- Pre-reqs       : None
  -- Function       :  Associate the Vendor with the Rule uses
  --                  OKL_DISB_RULES_B, OKL_DISB_RULES_TL,
  --                  OKL_DISB_RULE_STY_TYPES and OKL_DISB_RULE_VENDOR_SITES
  -- Parameters     :
  -- IN             : p_api_version - Standard input parameter
  --                  p_init_msg_list - Standard input parameter
  --                  p_drv_tbl - record type for OKL_DISB_RULE_VENDOR_SITES
  -- Version        : 1.0
  -- History        : gkhuntet created.
  -- End of comments


PROCEDURE create_v_disbursement_rule( p_api_version        IN  NUMBER
                                    , p_init_msg_list           IN  VARCHAR2 DEFAULT FND_API.G_FALSE
                                    , x_return_status           OUT NOCOPY VARCHAR2
                                    , x_msg_count               OUT NOCOPY NUMBER
                                    , x_msg_data                OUT NOCOPY VARCHAR2
                                    , p_drv_tbl                 IN  drv_tbl_type
                                    , x_drv_tbl                 OUT NOCOPY drv_tbl_type
                                    )
                                    IS

    l_api_name           CONSTANT VARCHAR2(40) := 'create_v_disbursement_rule';
    l_api_version        CONSTANT NUMBER       := 1;
    l_init_msg_list      VARCHAR2(1);
    i                    NUMBER;
    crt_count            NUMBER := 0;
    updt_count           NUMBER := 0;
    count_csr            NUMBER := 0;
    count_vendor_site_id NUMBER :=0;
    l_vendor_id          NUMBER ;

    l_drav_rec  drav_rec_type;
    l_drs_tbl   drs_tbl_type;
    l_drs_rec   drs_rec_type;
    l_disb_rule_id okl_disb_rules_v.disb_rule_id%TYPE;

    lp_drv_tbl       drv_tbl_type;
    lp_drv_rec       drv_rec_type;
    lx_drv_tbl       drv_tbl_type;
    l_drv_Updt_tbl   drv_tbl_type;
    l_drv_Crt_tbl    drv_tbl_type;
    l_old_start_seq_no OKL_DISB_RULE_VENDOR_SITES.INVOICE_SEQ_START%TYPE;
    l_next_seq_no        OKL_DISB_RULE_VENDOR_SITES.NEXT_INV_SEQ%TYPE;
    l_old_end_seq_no     OKL_DISB_RULE_VENDOR_SITES.INVOICE_SEQ_END%TYPE;

   flag              VARCHAR(50);

    CURSOR get_drav_rec(c_disb_rule_id  OKL_DISB_RULES_B.DISB_RULE_ID%TYPE) IS
     SELECT DISB_RULE_ID ,START_DATE ,end_date ,fee_basis ,fee_option ,fee_amount ,
            fee_percent ,consolidate_by_due_date ,frequency ,day_of_month ,scheduled_month
     FROM  OKL_DISB_RULES_B
     WHERE DISB_RULE_ID = c_disb_rule_id;

   CURSOR get_drs_tbl(c_disb_rule_id  OKL_DISB_RULE_STY_TYPES.DISB_RULE_ID%TYPE) IS
     SELECT DISB_RULE_ID ,STREAM_TYPE_PURPOSE ,DISB_RULE_STY_TYPE_ID
     FROM  OKL_DISB_RULE_STY_TYPES
     WHERE DISB_RULE_ID = c_disb_rule_id;

    CURSOR get_seq_no(c_disb_rule_vendor_site_id OKL_DISB_RULE_VENDOR_SITES.INVOICE_SEQ_START%TYPE) IS
     SELECT INVOICE_SEQ_START ,NEXT_INV_SEQ ,INVOICE_SEQ_END
     FROM OKL_DISB_RULE_VENDOR_SITES
     WHERE DISB_RULE_VENDOR_SITE_ID = c_disb_rule_vendor_site_id;


   /*CURSOR get_count_disb_ruleid(c_disb_rule_vendor_site_id OKL_DISB_RULE_VENDOR_SITES.DISB_RULE_ID%TYPE) IS
     SELECT COUNT(DISB_RULE_VENDOR_SITE_ID)
     FROM OKL_DISB_RULE_VENDOR_SITES
     WHERE DISB_RULE_VENDOR_SITE_ID = c_disb_rule_vendor_site_id;*/

    v_disb_rule_rec get_drav_rec%ROWTYPE;
    v_dsbrule_strm_prpse_rec get_drs_tbl%ROWTYPE;

    BEGIN
    --SAVEPOINT create_v_disbursement_rule;
    ----g_debug_proc('START');
    --DBMS_OUTPUT.PUT_LINE('START   ');
    x_return_status := OKL_API.G_RET_STS_SUCCESS;

    x_return_status := OKL_API.START_ACTIVITY( l_api_name
                                             , g_pkg_name
                                             , p_init_msg_list
                                             , l_api_version
                                             , p_api_version
                                             , '_PVT'
                                             , x_return_status);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

--    lp_drv_tbl := p_drv_tbl;

    -- ----g_debug_proc('Gaurav p_drv_tbl(0).disb_rule_id :'||p_drv_tbl.count);

 ----g_debug_proc('a ' || p_drv_tbl.FIRST);
    IF ( p_drv_tbl.COUNT > 0) THEN
      i := p_drv_tbl.FIRST;
      LOOP
        lp_drv_tbl(i) := p_drv_tbl(i);
        l_disb_rule_id :=p_drv_tbl(i).disb_rule_id;
--      l_vendor_id    :=p_drv_tbl(i).vendor_id;

--     ----g_debug_proc('Gaurav lp_drv_tbl(i).disb_rule_id :'||l_disb_rule_id);
        EXIT WHEN ( i = p_drv_tbl.LAST);
        i := p_drv_tbl.NEXT(i);
      END LOOP;
    END IF;



    IF(FND_API.G_MISS_NUM  = p_drv_tbl(p_drv_tbl.FIRST).disb_rule_vendor_site_id) THEN
       flag :='yes';
    ELSE
        flag :='no';
    END IF;
 ----g_debug_proc('Gaurav  ' || flag || '   ' || p_drv_tbl(p_drv_tbl.FIRST).disb_rule_vendor_site_id);

    --DBMS_OUTPUT.PUT_LINE('A   '  || l_disb_rule_id );

    OPEN get_drav_rec(l_disb_rule_id);
    FETCH get_drav_rec INTO v_disb_rule_rec;
        IF get_drav_rec%FOUND THEN
            --DBMS_OUTPUT.PUT_LINE('Inside Fetch '||v_disb_rule_rec.disb_rule_id);
            l_drav_rec.disb_rule_id := v_disb_rule_rec.disb_rule_id;
            l_drav_rec.START_DATE :=   v_disb_rule_rec.START_DATE;
            l_drav_rec.end_date :=   v_disb_rule_rec.end_date;
            l_drav_rec.fee_basis :=   v_disb_rule_rec.fee_basis;
            l_drav_rec.fee_option :=   v_disb_rule_rec.fee_option;
            l_drav_rec.fee_amount :=   v_disb_rule_rec.fee_amount;
            l_drav_rec.fee_percent :=   v_disb_rule_rec.fee_percent;
            l_drav_rec.consolidate_by_due_date :=   v_disb_rule_rec.consolidate_by_due_date;
            l_drav_rec.frequency :=   v_disb_rule_rec.frequency;
            l_drav_rec.day_of_month :=   v_disb_rule_rec.day_of_month;
            l_drav_rec.scheduled_month :=   v_disb_rule_rec.scheduled_month;
        END IF;
    CLOSE get_drav_rec;

    --DBMS_OUTPUT.PUT_LINE('B  ' || l_drav_rec.START_DATE || '   ' || l_drav_rec.end_date);
    --DBMS_OUTPUT.PUT_LINE('B  ' || v_disb_rule_rec.START_DATE || '   ' || v_disb_rule_rec.end_date);

    ----g_debug_proc('Gaurav   '  || l_drav_rec.disb_rule_id);
    ------g_debug_proc('Gaurav   '  || p_drv_tbl(0).START_DATE);
    ------g_debug_proc('Gaurav   '  || p_drv_tbl(0).end_date);

    --OPEN get_drs_tbl(lp_drv_tbl(0).disb_rule_id);
    FOR v_dsbrule_strm_prpse_rec in get_drs_tbl(l_disb_rule_id)
    LOOP
        l_drs_rec.disb_rule_id := v_dsbrule_strm_prpse_rec.disb_rule_id;
        l_drs_rec.stream_type_purpose := v_dsbrule_strm_prpse_rec.stream_type_purpose;
        l_drs_rec.disb_rule_sty_type_id := v_dsbrule_strm_prpse_rec.disb_rule_sty_type_id;
        l_drs_tbl(count_csr) := l_drs_rec;
        count_csr := count_csr + 1;
    END LOOP;
    --CLOSE get_drs_tbl;

       --DBMS_OUTPUT.PUT_LINE('C');

    ----g_debug_proc('Gaurav 3   '  ||  l_drs_rec.stream_type_purpose);

    del_disb_rule_vendor_sites( p_api_version   => l_api_version
                                , p_init_msg_list => p_init_msg_list
                                , x_return_status => x_return_status
                                , x_msg_count     => x_msg_count
                                , x_msg_data      => x_msg_data
                                , p_disb_rule_id  => l_disb_rule_id
                                , p_vendor_id     => lp_drv_tbl(lp_drv_tbl.FIRST).vendor_id
                                , p_new_drv_tbl   => lp_drv_tbl);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;


        ----g_debug_proc('After Delete');

    -- Do the required validations
    validate_disbursement_rule( p_api_version    => p_api_version
                              , p_init_msg_list  => p_init_msg_list
                              , x_return_status  => x_return_status
                              , x_msg_count      => x_msg_count
                              , x_msg_data       => x_msg_data
                              , p_drav_rec       => l_drav_rec
                              , p_drs_tbl        => l_drs_tbl
                              , p_drv_tbl        => lp_drv_tbl);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;




       -- Only one disbursement rule can exist for one vendor site and stream type
      -- combination for a given range of effective dates
      validate_rule_eff_dates( p_api_version      =>  p_api_version
                             , p_init_msg_list    =>  p_init_msg_list
                             , x_return_status    =>  x_return_status
                             , x_msg_count        =>  x_msg_count
                             , x_msg_data         =>  x_msg_data
                             , p_drav_rec         =>  l_drav_rec
                             , p_drs_tbl          =>  l_drs_tbl
                             , p_drv_tbl          =>  lp_drv_tbl);
      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
  --DBMS_OUTPUT.PUT_LINE('3');


      -- Vendor site, Sequence range must not overlap accross rules

      validate_sequence_range( p_api_version      =>  p_api_version
                             , p_init_msg_list    =>  p_init_msg_list
                             , x_return_status    =>  x_return_status
                             , x_msg_count        =>  x_msg_count
                             , x_msg_data         =>  x_msg_data
                             , p_drv_tbl          =>  lp_drv_tbl);
      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      ----g_debug_proc('Gaurav 4');

   --If disb_rule_vendor_site_id = null then record is inserted else updated.
    FOR i IN lp_drv_tbl.FIRST .. lp_drv_tbl.LAST LOOP
        --gkhuntet added on 22-JUN-2007 START.

IF(lp_drv_tbl(i).disb_rule_vendor_site_id <>  OKL_API.G_MISS_NUM
       OR lp_drv_tbl(i).disb_rule_vendor_site_id IS NOT NULL) THEN
	   OPEN get_seq_no(lp_drv_tbl(i).DISB_RULE_VENDOR_SITE_ID);
            FETCH get_seq_no INTO l_old_start_seq_no ,l_next_seq_no ,l_old_end_seq_no;
          CLOSE get_seq_no;
        IF(lp_drv_tbl(i).INVOICE_SEQ_START IS NOT NULL) THEN
                IF(l_old_start_seq_no IS null) THEN
                        lp_drv_tbl(i).NEXT_INV_SEQ := lp_drv_tbl(i).INVOICE_SEQ_START;
                END IF;
        ELSIF(lp_drv_tbl(i).INVOICE_SEQ_END IS NOT NULL) THEN
                 OKL_API.SET_MESSAGE( p_app_name => g_app_name
                       , p_msg_name => G_OKL_ST_START_SEQ_NO_REQ);
                  RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

        IF((l_old_end_seq_no IS NOT NULL AND lp_drv_tbl(i).INVOICE_SEQ_END IS NULL) OR
                l_old_end_seq_no IS NOT NULL AND lp_drv_tbl(i).INVOICE_SEQ_END < l_old_end_seq_no) THEN
                 OKL_API.SET_MESSAGE( p_app_name => g_app_name
                       , p_msg_name => G_OKL_ST_END_SEQ_NO_LESS);
                  RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

        IF((lp_drv_tbl(i).INVOICE_SEQ_START IS NULL AND l_old_start_seq_no IS NOT NULL) OR
	(l_old_start_seq_no IS NOT NULL AND lp_drv_tbl(i).INVOICE_SEQ_START <> l_old_start_seq_no)) THEN
                OKL_API.SET_MESSAGE( p_app_name => g_app_name
                       , p_msg_name => G_OKL_ST_START_SEQ_LOCK);
                  RAISE OKL_API.G_EXCEPTION_ERROR;
    --    ELSE
    --            lp_drv_tbl(i).INVOICE_SEQ_START := l_old_start_seq_no;


END IF;
      	END IF;
--gkhuntet added on 22-JUN-2007 END.

        IF(lp_drv_tbl(i).disb_rule_vendor_site_id = OKL_API.G_MISS_NUM or
                lp_drv_tbl(i).disb_rule_vendor_site_id is null) THEN
            ----g_debug_proc('disb_rule_vendor_site_id ' || lp_drv_tbl(i).disb_rule_vendor_site_id);
            l_drv_Crt_tbl(crt_count) := lp_drv_tbl(i);
            crt_count := crt_count + 1;
        ELSE
            ----g_debug_proc('disb_rule_vendor_site_id ' || lp_drv_tbl(i).disb_rule_vendor_site_id);
            l_drv_Updt_tbl(updt_count) := lp_drv_tbl(i);
            updt_count := updt_count + 1;
        END IF;
    END LOOP;

  --DBMS_OUTPUT.PUT_LINE('COUNT ' || l_drv_Updt_tbl.COUNT || '  ' ||l_drv_Crt_tbl.COUNT);
        -- Update record in OKL_DISB_RULE_VENDOR_SITES
    ----g_debug_proc('Gaurav 5  ' || l_drv_Updt_tbl.COUNT || '  ' ||l_drv_Crt_tbl.COUNT);

     IF ( l_drv_Updt_tbl.COUNT > 0 ) THEN
       okl_drv_pvt.update_row( p_api_version   => l_api_version
                            , p_init_msg_list => p_init_msg_list
                            , x_return_status => x_return_status
                            , x_msg_count     => x_msg_count
                            , x_msg_data      => x_msg_data
                            , p_drv_tbl       => l_drv_Updt_tbl
                            , x_drv_tbl       => lx_drv_tbl);
      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    END IF;

    ----g_debug_proc('Gaurav 6');

      IF ( l_drv_Crt_tbl.COUNT > 0 ) THEN
      -- Create record in OKL_DISB_RULE_VENDOR_SITES
      okl_drv_pvt.insert_row( p_api_version   => l_api_version
                            , p_init_msg_list => p_init_msg_list
                            , x_return_status => x_return_status
                            , x_msg_count     => x_msg_count
                            , x_msg_data      => x_msg_data
                            , p_drv_tbl       => l_drv_Crt_tbl
                            , x_drv_tbl       => lx_drv_tbl);
      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    END IF;

    ----g_debug_proc('Gaurav 7');

    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);

  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
     --ROLLBACK TO create_v_disbursement_rule;
      x_return_status := OKL_API.HANDLE_EXCEPTIONS( l_api_name
                                                 , g_pkg_name
                                                 , 'OKL_API.G_RET_STS_ERROR'
                                                 , x_msg_count
                                                 , x_msg_data
                                                 , '_PVT' );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
     --ROLLBACK TO create_v_disbursement_rule;
      x_return_status := OKL_API.HANDLE_EXCEPTIONS( l_api_name
                                                 , g_pkg_name
                                                 , 'OKL_API.G_RET_STS_UNEXP_ERROR'
                                                 , x_msg_count
                                                 , x_msg_data
                                                 , '_PVT' );
    WHEN OTHERS THEN
     --ROLLBACK TO create_v_disbursement_rule;
      x_return_status := OKL_API.HANDLE_EXCEPTIONS( l_api_name
                                                 , g_pkg_name
                                                 , 'OTHERS'
                                                 , x_msg_count
                                                 , x_msg_data
                                                , '_PVT' );

END create_v_disbursement_rule;







  -- Start of comments
  -- API name       : validate_disb_rule_name
  -- Pre-reqs       : None
  -- Function       : validates disbursement rule name
  -- Parameters     :
  -- IN             : p_api_version - Standard input parameter
  --                  p_init_msg_list - Standard input parameter
  --                  p_disb_rule_name - disbursement rule name
  -- Version        : 1.0
  -- History        : gboomina created.
  -- End of comments

  PROCEDURE validate_disb_rule_name( p_api_version             IN  NUMBER
                                      , p_init_msg_list        IN  VARCHAR2 DEFAULT FND_API.G_FALSE
                                      , x_return_status        OUT NOCOPY VARCHAR2
                                      , x_msg_count            OUT NOCOPY NUMBER
                                      , x_msg_data             OUT NOCOPY VARCHAR2
                                      , p_disb_rule_name       IN  OKL_DISB_RULES_V.RULE_NAME%TYPE
                                      )
    IS
    l_api_name          CONSTANT VARCHAR2(40) := 'validate_disb_rule_name';
    l_api_version       CONSTANT NUMBER       := 1;
    l_init_msg_list     VARCHAR2(1);
    i                   NUMBER;

    -- Cursor to check the unique rule name
    CURSOR disb_rule_name_csr IS
      SELECT 'Y' FROM OKL_DISB_RULES_B
      WHERE RULE_NAME = p_disb_rule_name;

    l_found VARCHAR2(1) := 'N';

    BEGIN
      -- Initialization
      x_return_status := OKL_API.G_RET_STS_SUCCESS;

      x_return_status := OKL_API.START_ACTIVITY( l_api_name
                                               , g_pkg_name
                                               , p_init_msg_list
                                               , l_api_version
                                               , p_api_version
                                               , '_PVT'
                                               , x_return_status);
      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      -- Check whether Rule name is unique accross rules within org
      OPEN disb_rule_name_csr;
      FETCH disb_rule_name_csr INTO l_found;
      CLOSE disb_rule_name_csr;

      IF ( l_found = 'Y') THEN
        OKL_API.SET_MESSAGE( p_app_name => g_app_name
                           , p_msg_name => G_OKL_ST_DISB_NAME_EXIST
                           , p_token1   => G_VALUE
                           , p_token1_value => p_disb_rule_name );
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);

  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS( l_api_name
                                                 , g_pkg_name
                                                 , 'OKL_API.G_RET_STS_ERROR'
                                                 , x_msg_count
                                                 , x_msg_data
                                                 , '_PVT' );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS( l_api_name
                                                 , g_pkg_name
                                                 , 'OKL_API.G_RET_STS_UNEXP_ERROR'
                                                 , x_msg_count
                                                 , x_msg_data
                                                 , '_PVT' );
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS( l_api_name
                                                 , g_pkg_name
                                                 , 'OTHERS'
                                                 , x_msg_count
                                                 , x_msg_data
                                                 , '_PVT' );
  END validate_disb_rule_name;



  -- Start of comments
  -- API name       : validate_disbursement_rule
  -- Pre-reqs       : None
  -- Function       : validates disbursement rule
  -- Parameters     :
  -- IN             : p_api_version - Standard input parameter
  --                  p_init_msg_list - Standard input parameter
  --                  p_drav_rec - record type for OKL_DISB_RULES_V
  --                  p_drs_tbl - record type for OKL_DISB_RULE_STY_TYPES
  --                  p_drv_rec - record type for OKL_DISB_RULE_VENDOR_SITES
  -- Version        : 1.0
  -- History        : gboomina created.
  -- End of comments

  PROCEDURE validate_disbursement_rule( p_api_version             IN  NUMBER
                                      , p_init_msg_list           IN  VARCHAR2 DEFAULT FND_API.G_FALSE
                                      , x_return_status           OUT NOCOPY VARCHAR2
                                      , x_msg_count               OUT NOCOPY NUMBER
                                      , x_msg_data                OUT NOCOPY VARCHAR2
                                      , p_drav_rec                IN  drav_rec_type
                                      , p_drs_tbl                 IN  drs_tbl_type
                                      , p_drv_tbl                 IN  drv_tbl_type
                                      )
    IS
    l_api_name          CONSTANT VARCHAR2(40) := 'validate_disbursement_rule';
    l_api_version       CONSTANT NUMBER       := 1;
    l_init_msg_list     VARCHAR2(1);
    i                   NUMBER;

    BEGIN
      -- Initialization

      x_return_status := OKL_API.G_RET_STS_SUCCESS;

      x_return_status := OKL_API.START_ACTIVITY( l_api_name
                                               , g_pkg_name
                                               , p_init_msg_list
                                               , l_api_version
                                               , p_api_version
                                               , '_PVT'
                                               , x_return_status);
      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;


      -- Rule must have atleast one Stream Type defined

      IF ( p_drs_tbl.COUNT <= 0 ) THEN
        OKL_API.SET_MESSAGE( p_app_name => g_app_name
                           , p_msg_name => G_OKL_ST_DISB_RUL_STY_MISSING );
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      -- If Fee Basis is selected then Option is mandatory
      IF ( p_drav_rec.fee_basis <> OKL_API.G_MISS_CHAR AND p_drav_rec.fee_basis IS NOT NULL ) THEN
        IF ( p_drav_rec.fee_option = OKL_API.G_MISS_CHAR OR p_drav_rec.fee_option IS NULL ) THEN
          OKL_API.SET_MESSAGE( p_app_name => g_app_name
                             , p_msg_name => G_OKL_ST_DISB_FEE_OPTION_REQ);
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
       --g_debug_proc('Fee Basis   ' ||  p_drav_rec.fee_basis);
       --g_debug_proc('Fee Amount   ' || p_drav_rec.fee_amount);
       --g_debug_proc('Fee Percent   ' || p_drav_rec.fee_percent);
        -- If Fee Basis is 'Amount' then Fee Amount is mandatory

-- Commented by gkhuntet For Disbursement phase 1.
 /*      IF (p_drav_rec.fee_basis = 'AMOUNT') THEN
          IF ( p_drav_rec.fee_amount = OKL_API.G_MISS_NUM OR p_drav_rec.fee_amount IS NULL ) THEN
            OKL_API.SET_MESSAGE( p_app_name => g_app_name
                               , p_msg_name => G_OKL_ST_DISB_FEE_AMNT_REQ);
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;
        END IF;
        IF (p_drav_rec.fee_basis = 'PERCENT') THEN  -- If Fee Basis is 'Percent' then Fee Percent is mandatory
          IF ( p_drav_rec.fee_percent = OKL_API.G_MISS_NUM OR p_drav_rec.fee_percent IS NULL ) THEN
            OKL_API.SET_MESSAGE( p_app_name => g_app_name
                               , p_msg_name => G_OKL_ST_DISB_FEE_PERCENT_REQ);
            RAISE OKL_API.G_EXCEPTION_ERROR;
          -- Fee Percent should have value between 0 and 100
          ELSIF ( p_drav_rec.fee_percent < 0 OR p_drav_rec.fee_percent > 100 ) THEN
            OKL_API.SET_MESSAGE( p_app_name => g_app_name
                               , p_msg_name => G_OKL_ST_DISB_FEE_PERCENT_ERR);
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;
        END IF;
*/
  END IF;
   --DBMS_OUTPUT.PUT_LINE('1');
      -- If 'Consolidated by Invoice date' is checked then Frequency, Scheduled Day of Month and
      -- Scheduled Month are mandatory.
      IF ((p_drav_rec.consolidate_by_due_date <> OKL_API.G_MISS_CHAR) AND
          (p_drav_rec.consolidate_by_due_date IS NOT NULL) AND
          (p_drav_rec.consolidate_by_due_date = 'Y')) THEN
        IF (p_drav_rec.frequency = OKL_API.G_MISS_CHAR OR p_drav_rec.frequency IS NULL) THEN
          OKL_API.SET_MESSAGE( p_app_name => g_app_name
                             , p_msg_name => G_OKL_ST_DISB_FREQ_REQ);
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
        IF (p_drav_rec.day_of_month = OKL_API.G_MISS_NUM OR p_drav_rec.day_of_month IS NULL) THEN
          OKL_API.SET_MESSAGE( p_app_name => g_app_name
                             , p_msg_name => G_OKL_ST_DISB_DAY_MON_REQ);
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
        IF (p_drav_rec.scheduled_month = OKL_API.G_MISS_CHAR OR p_drav_rec.scheduled_month IS NULL) THEN
          OKL_API.SET_MESSAGE( p_app_name => g_app_name
                             , p_msg_name => G_OKL_ST_DISB_SCHED_MON_REQ);
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
      END IF;
   --DBMS_OUTPUT.PUT_LINE('2 ..');
      -- Only one disbursement rule can exist for one vendor site and stream type
      -- combination for a given range of effective dates
  /*    validate_rule_eff_dates( p_api_version      =>  p_api_version
                             , p_init_msg_list    =>  p_init_msg_list
                             , x_return_status    =>  x_return_status
                             , x_msg_count        =>  x_msg_count
                             , x_msg_data         =>  x_msg_data
                             , p_drav_rec         =>  p_drav_rec
                             , p_drs_tbl          =>  p_drs_tbl
                             , p_drv_tbl          =>  p_drv_tbl);
      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
  --DBMS_OUTPUT.PUT_LINE('3');
      -- Vendor site, Sequence range must not overlap accross rules
      validate_sequence_range( p_api_version      =>  p_api_version
                             , p_init_msg_list    =>  p_init_msg_list
                             , x_return_status    =>  x_return_status
                             , x_msg_count        =>  x_msg_count
                             , x_msg_data         =>  x_msg_data
                             , p_drv_tbl          =>  p_drv_tbl);
      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;*/
  --DBMS_OUTPUT.PUT_LINE('4');
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);

  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS( l_api_name
                                                 , g_pkg_name
                                                 , 'OKL_API.G_RET_STS_ERROR'
                                                 , x_msg_count
                                                 , x_msg_data
                                                 , '_PVT' );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS( l_api_name
                                                 , g_pkg_name
                                                 , 'OKL_API.G_RET_STS_UNEXP_ERROR'
                                                 , x_msg_count
                                                 , x_msg_data
                                                 , '_PVT' );
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS( l_api_name
                                                 , g_pkg_name
                                                 , 'OTHERS'
                                                 , x_msg_count
                                                 , x_msg_data
                                                 , '_PVT' );
  END validate_disbursement_rule;


  -- Start of comments
  -- API name       : create_disbursement_rule
  -- Pre-reqs       : None
  -- Function       : create disbursement rule in the following tables
  --                  OKL_DISB_RULES_B, OKL_DISB_RULES_TL,
  --                  OKL_DISB_RULE_STY_TYPES and OKL_DISB_RULE_VENDOR_SITES
  -- Parameters     :
  -- IN             : p_api_version - Standard input parameter
  --                  p_init_msg_list - Standard input parameter
  --                  p_drav_rec - record type for OKL_DISB_RULES_V
  --                  p_drs_tbl - record type for OKL_DISB_RULE_STY_TYPES
  --                  p_drv_rec - record type for OKL_DISB_RULE_VENDOR_SITES
  -- Version        : 1.0
  -- History        : gboomina created.
  -- End of comments

  PROCEDURE create_disbursement_rule( p_api_version             IN  NUMBER
                                    , p_init_msg_list           IN  VARCHAR2 DEFAULT FND_API.G_FALSE
                                    , x_return_status           OUT NOCOPY VARCHAR2
                                    , x_msg_count               OUT NOCOPY NUMBER
                                    , x_msg_data                OUT NOCOPY VARCHAR2
                                    , p_drav_rec                IN  drav_rec_type
                                    , p_drs_tbl                 IN  drs_tbl_type
                                    , p_drv_tbl                 IN  drv_tbl_type
                                    , x_drav_rec                OUT NOCOPY drav_rec_type
                                    )
    IS
    l_api_name          CONSTANT VARCHAR2(40) := 'create_disbursement_rule';
    l_api_version       CONSTANT NUMBER       := 1;
    l_init_msg_list     VARCHAR2(1);
    i                   NUMBER;

    l_drav_rec  drav_rec_type;
    l_drs_tbl   drs_tbl_type;
    l_drv_tbl   drv_tbl_type;

    lx_drav_rec  drav_rec_type;
    lx_drs_tbl   drs_tbl_type;
    lx_drv_tbl   drv_tbl_type;

    BEGIN
    -- Initialization
    x_return_status := OKL_API.G_RET_STS_SUCCESS;

    x_return_status := OKL_API.START_ACTIVITY( l_api_name
                                             , g_pkg_name
                                             , p_init_msg_list
                                             , l_api_version
                                             , p_api_version
                                             , '_PVT'
                                             , x_return_status);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;



    -- Validate disbursement rule before inserting
    -- Check whether Rule name is unique accross rules within org
    validate_disb_rule_name( p_api_version      =>  p_api_version
                           , p_init_msg_list    =>  p_init_msg_list
                           , x_return_status    =>  x_return_status
                           , x_msg_count        =>  x_msg_count
                           , x_msg_data         =>  x_msg_data
                           , p_disb_rule_name   =>  p_drav_rec.rule_name);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
  --DBMS_OUTPUT.PUT_LINE('Validated Rule Name');
  --g_debug_proc('Validated Rule Name');
    -- Do the required validations
    validate_disbursement_rule( p_api_version    => p_api_version
                              , p_init_msg_list  => p_init_msg_list
                              , x_return_status  => x_return_status
                              , x_msg_count      => x_msg_count
                              , x_msg_data       => x_msg_data
                              , p_drav_rec       => p_drav_rec
                              , p_drs_tbl        => p_drs_tbl
                              , p_drv_tbl        => p_drv_tbl);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

  l_drav_rec := p_drav_rec;

      --DBMS_OUTPUT.PUT_LINE('Validated Rule');

  -- Only one disbursement rule can exist for one vendor site and stream type
      -- combination for a given range of effective dates
      validate_rule_eff_dates( p_api_version      =>  p_api_version
                             , p_init_msg_list    =>  p_init_msg_list
                             , x_return_status    =>  x_return_status
                             , x_msg_count        =>  x_msg_count
                             , x_msg_data         =>  x_msg_data
                             , p_drav_rec         =>  p_drav_rec
                             , p_drs_tbl          =>  p_drs_tbl
                             , p_drv_tbl          =>  p_drv_tbl);
      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;




        --g_debug_proc('Validated Rule');
    -- insert record in to OKL_DISB_RULES_B and TL
    okl_dra_pvt.insert_row( p_api_version   => l_api_version
                          , p_init_msg_list => p_init_msg_list
                          , x_return_status => x_return_status
                          , x_msg_count     => x_msg_count
                          , x_msg_data      => x_msg_data
                          , p_drav_rec      => l_drav_rec
                          , x_drav_rec      => lx_drav_rec);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
  --DBMS_OUTPUT.PUT_LINE('Rule Inserted');
    --g_debug_proc('Rule Inserted');
    -- populate the OKL_DISB_RULE_STY_TYPES table with the
    -- disb rule id returned from the okl_dra_pvt.insert_row
    IF ( p_drs_tbl.COUNT > 0) THEN
      i := p_drs_tbl.FIRST;
      LOOP
        l_drs_tbl(i) := p_drs_tbl(i);
        l_drs_tbl(i).disb_rule_id := lx_drav_rec.disb_rule_id;
        EXIT WHEN ( i = p_drs_tbl.LAST);
        i := p_drs_tbl.NEXT(i);
      END LOOP;

      -- insert record in to OKL_DISB_RULE_STY_TYPES
      okl_drs_pvt.insert_row( p_api_version   => l_api_version
                            , p_init_msg_list => p_init_msg_list
                            , x_return_status => x_return_status
                            , x_msg_count     => x_msg_count
                            , x_msg_data      => x_msg_data
                            , p_drs_tbl       => l_drs_tbl
                            , x_drs_tbl       => lx_drs_tbl);
      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

    END IF;
    --g_debug_proc('Stream Inserted');
    -- populate the OKL_DISB_RULE_VENDOR_SITES table with the
    -- disb rule id returned from the okl_dra_pvt.insert_row
    IF ( p_drv_tbl.COUNT > 0) THEN
      i := p_drv_tbl.FIRST;
      LOOP
        l_drv_tbl(i) := p_drv_tbl(i);
        l_drv_tbl(i).disb_rule_id := lx_drav_rec.disb_rule_id;
        EXIT WHEN ( i = p_drv_tbl.LAST);
        i := p_drv_tbl.NEXT(i);
      END LOOP;

      -- insert record in to OKL_DISB_RULE_STY_TYPES
      okl_drv_pvt.insert_row( p_api_version   => l_api_version
                            , p_init_msg_list => p_init_msg_list
                            , x_return_status => x_return_status
                            , x_msg_count     => x_msg_count
                            , x_msg_data      => x_msg_data
                            , p_drv_tbl       => l_drv_tbl
                            , x_drv_tbl       => lx_drv_tbl);
      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

    END IF;
    --g_debug_proc('VendorSites Inserted');
    x_drav_rec := lx_drav_rec;

    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);

  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS( l_api_name
                                                 , g_pkg_name
                                                 , 'OKL_API.G_RET_STS_ERROR'
                                                 , x_msg_count
                                                 , x_msg_data
                                                 , '_PVT' );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS( l_api_name
                                                 , g_pkg_name
                                                 , 'OKL_API.G_RET_STS_UNEXP_ERROR'
                                                 , x_msg_count
                                                 , x_msg_data
                                                 , '_PVT' );
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS( l_api_name
                                                 , g_pkg_name
                                                 , 'OTHERS'
                                                 , x_msg_count
                                                 , x_msg_data
                                                 , '_PVT' );
  END create_disbursement_rule;



  -- Start of comments
  -- API name       : delete_disb_rule_sty_types
  -- Pre-reqs       : None
  -- Function       : deletes stream types which are not present in the input
  --                  p_drs_tbl but in the OKL_DISB_RULE_STY_TYPES
  --                  for a disbursement rule. This API deletes stream types from
  --                  OKL_DISB_RULE_STY_TYPES table which user had deleted during
  --                  update operation.
  -- Parameters     :
  -- IN             : p_api_version - Standard input parameter
  --                  p_init_msg_list - Standard input parameter
  --                  p_disb_rule_id - disbursement rule id
  --                  p_drs_tbl - record type for OKL_DISB_RULE_STY_TYPES
  -- Version        : 1.0
  -- History        : gboomina created.
  -- End of comments

  PROCEDURE delete_disb_rule_sty_types( p_api_version     IN  NUMBER
                                      , p_init_msg_list    IN  VARCHAR2 DEFAULT FND_API.G_FALSE
                                      , x_return_status    OUT NOCOPY VARCHAR2
                                      , x_msg_count        OUT NOCOPY NUMBER
                                      , x_msg_data         OUT NOCOPY VARCHAR2
                                      , p_disb_rule_id     IN  okl_disb_rules_v.disb_rule_id%type
                                      , p_new_drs_tbl      IN  drs_tbl_type
                                      )
    IS
    l_api_name          CONSTANT VARCHAR2(40) := 'delete_disb_rule_sty_types';
    l_api_version       CONSTANT NUMBER       := 1;
    l_init_msg_list     VARCHAR2(1);
    i                   NUMBER;
    del_count           NUMBER := 0;
    l_found             VARCHAR2(1) := 'N';

    l_drs_del_tbl   drs_tbl_type;

    CURSOR old_disb_sty_types_csr( p_disb_rule_id IN OKL_DISB_RULE_STY_TYPES.DISB_RULE_ID%TYPE )
    IS
      SELECT disb_rule_sty_type_id
      FROM okl_disb_rule_sty_types
      WHERE disb_rule_id = p_disb_rule_id;

    old_sty_type_rec old_disb_sty_types_csr%rowtype;

    BEGIN
    -- Initialization
    x_return_status := OKL_API.G_RET_STS_SUCCESS;

    x_return_status := OKL_API.START_ACTIVITY( l_api_name
                                             , g_pkg_name
                                             , p_init_msg_list
                                             , l_api_version
                                             , p_api_version
                                             , '_PVT'
                                             , x_return_status);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- If stream types available for the disbursement rule from DB
    -- is not found in the new stream types table then delete it
    -- from the DB table.
    FOR old_sty_type_rec IN old_disb_sty_types_csr(p_disb_rule_id) LOOP
      l_found := 'N';
      FOR i IN p_new_drs_tbl.FIRST .. p_new_drs_tbl.LAST LOOP
        IF (old_sty_type_rec.disb_rule_sty_type_id = p_new_drs_tbl(i).disb_rule_sty_type_id) THEN
          l_found := 'Y';
        END IF;
      END LOOP;
      IF (l_found = 'N') THEN
        l_drs_del_tbl(del_count).disb_rule_sty_type_id := old_sty_type_rec.disb_rule_sty_type_id;
        l_drs_del_tbl(del_count).disb_rule_id := p_disb_rule_id;
        del_count := del_count + 1;
      END IF;
    END LOOP;

    IF ( l_drs_del_tbl.COUNT > 0 ) THEN
      -- delete record from OKL_DISB_RULE_STY_TYPES
      okl_drs_pvt.delete_row( p_api_version   => l_api_version
                            , p_init_msg_list => p_init_msg_list
                            , x_return_status => x_return_status
                            , x_msg_count     => x_msg_count
                            , x_msg_data      => x_msg_data
                            , p_drs_tbl       => l_drs_del_tbl);

      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    END IF;

    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);

  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS( l_api_name
                                                 , g_pkg_name
                                                 , 'OKL_API.G_RET_STS_ERROR'
                                                 , x_msg_count
                                                 , x_msg_data
                                                 , '_PVT' );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS( l_api_name
                                                 , g_pkg_name
                                                 , 'OKL_API.G_RET_STS_UNEXP_ERROR'
                                                 , x_msg_count
                                                 , x_msg_data
                                                 , '_PVT' );
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS( l_api_name
                                                 , g_pkg_name
                                                 , 'OTHERS'
                                                 , x_msg_count
                                                 , x_msg_data
                                                 , '_PVT' );
  END delete_disb_rule_sty_types;


  -- Start of comments
  -- API name       : del_disb_rule_vendor_sites
  -- Pre-reqs       : None
  -- Function       : deletes vendor sites which are not present in the input
  --                  p_drv_tbl but in the OKL_DISB_RULE_VENDOR_SITES
  --                  for a disbursement rule. This API deletes stream types from
  --                  OKL_DISB_RULE_VENDOR_SITES table which user had deleted during
  --                  update operation.
  -- Parameters     :
  -- IN             : p_api_version - Standard input parameter
  --                  p_init_msg_list - Standard input parameter
  --                  p_disb_rule_id - disbursement rule id
  --                  p_drv_tbl - record type for OKL_DISB_RULE_VENDOR_SITES
  -- Version        : 1.0
  -- History        : gboomina created.
  -- End of comments



  -- Start of comments
  -- API name       : update_disbursement_rule
  -- Pre-reqs       : None
  -- Function       : update disbursement rule in the following tables
  --                  OKL_DISB_RULES_B, OKL_DISB_RULES_TL,
  --                  OKL_DISB_RULE_STY_TYPES and OKL_DISB_RULE_VENDOR_SITES
  -- Parameters     :
  -- IN             : p_api_version - Standard input parameter
  --                  p_init_msg_list - Standard input parameter
  --                  p_drav_rec - record type for OKL_DISB_RULES_V
  --                  p_drs_tbl - record type for OKL_DISB_RULE_STY_TYPES
  --                  p_drv_rec - record type for OKL_DISB_RULE_VENDOR_SITES
  -- Version        : 1.0
  -- History        : gboomina created.
  -- End of comments

  PROCEDURE update_disbursement_rule( p_api_version             IN  NUMBER
                                    , p_init_msg_list           IN  VARCHAR2 DEFAULT FND_API.G_FALSE
                                    , x_return_status           OUT NOCOPY VARCHAR2
                                    , x_msg_count               OUT NOCOPY NUMBER
                                    , x_msg_data                OUT NOCOPY VARCHAR2
                                    , p_drav_rec                IN  drav_rec_type
                                    , p_drs_tbl                 IN  drs_tbl_type
                                    , p_drv_tbl                 IN  drv_tbl_type
                                    , x_drav_rec                OUT NOCOPY drav_rec_type
                                    )
    IS
    l_api_name          CONSTANT VARCHAR2(40) := 'update_disbursement_rule';
    l_api_version       CONSTANT NUMBER       := 1;
    l_init_msg_list     VARCHAR2(1);
    i                   NUMBER;
    ins_count           NUMBER;
    upd_count           NUMBER;

    l_drav_rec      drav_rec_type;
    l_drs_ins_tbl   drs_tbl_type;
    l_drs_upd_tbl   drs_tbl_type;
    l_drv_ins_tbl   drv_tbl_type;
    l_drv_upd_tbl   drv_tbl_type;

    lx_drav_rec  drav_rec_type;
    lx_drs_ins_tbl   drs_tbl_type;
    lx_drs_upd_tbl   drs_tbl_type;
    lx_drv_ins_tbl   drv_tbl_type;
    lx_drv_upd_tbl   drv_tbl_type;


    BEGIN
    -- Initialization
    x_return_status := OKL_API.G_RET_STS_SUCCESS;

    x_return_status := OKL_API.START_ACTIVITY( l_api_name
                                             , g_pkg_name
                                             , p_init_msg_list
                                             , l_api_version
                                             , p_api_version
                                             , '_PVT'
                                             , x_return_status);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- Do the required validations before updating
    validate_disbursement_rule( p_api_version    => p_api_version
                              , p_init_msg_list  => p_init_msg_list
                              , x_return_status  => x_return_status
                              , x_msg_count      => x_msg_count
                              , x_msg_data       => x_msg_data
                              , p_drav_rec       => p_drav_rec
                              , p_drs_tbl        => p_drs_tbl
                              , p_drv_tbl        => p_drv_tbl);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

   --g_debug_proc('Update Validated');


      -- Only one disbursement rule can exist for one vendor site and stream type
      -- combination for a given range of effective dates
      validate_rule_eff_dates( p_api_version      =>  p_api_version
                             , p_init_msg_list    =>  p_init_msg_list
                             , x_return_status    =>  x_return_status
                             , x_msg_count        =>  x_msg_count
                             , x_msg_data         =>  x_msg_data
                             , p_drav_rec         =>  p_drav_rec
                             , p_drs_tbl          =>  p_drs_tbl
                             , p_drv_tbl          =>  p_drv_tbl);
      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;


    l_drav_rec := p_drav_rec;
    --g_debug_proc('DRA PArams ' || l_drav_rec.description || ' , ' || l_drav_rec.scheduled_month);

    -- update record in to OKL_DISB_RULES_B and TL
    okl_dra_pvt.update_row( p_api_version   => l_api_version
                          , p_init_msg_list => p_init_msg_list
                          , x_return_status => x_return_status
                          , x_msg_count     => x_msg_count
                          , x_msg_data      => x_msg_data
                          , p_drav_rec      => l_drav_rec
                          , x_drav_rec      => lx_drav_rec);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

        --g_debug_proc('Update DRA');

   -- Delete the rows from OKL_DISB_RULES_STY_TYPES which
   -- are removed during update operation.
   delete_disb_rule_sty_types( p_api_version   => l_api_version
                             , p_init_msg_list => p_init_msg_list
                             , x_return_status => x_return_status
                             , x_msg_count     => x_msg_count
                             , x_msg_data      => x_msg_data
                             , p_disb_rule_id  => p_drav_rec.disb_rule_id
                             , p_new_drs_tbl   => p_drs_tbl);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
   -- Delete the rows from OKL_DISB_RULES_VENDOR_SITES which
   -- are removed during update operation.
   del_disb_rule_vendor_sites( p_api_version   => l_api_version
                                , p_init_msg_list => p_init_msg_list
                                , x_return_status => x_return_status
                                , x_msg_count     => x_msg_count
                                , x_msg_data      => x_msg_data
                                , p_disb_rule_id  => p_drav_rec.disb_rule_id
                                , p_vendor_id     =>  null
                                , p_new_drv_tbl   => p_drv_tbl);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    --g_debug_proc('Update Del DRS');
    -- Check whether we need to create or update in to OKL_DISB_RULE_STY_TYPES table
    IF ( p_drs_tbl.COUNT > 0) THEN
      ins_count := 0;
      upd_count := 0;
      FOR i in p_drs_tbl.FIRST .. p_drs_tbl.LAST
      LOOP
        IF ( p_drs_tbl(i).disb_rule_sty_type_id = OKL_API.G_MISS_NUM OR
             p_drs_tbl(i).disb_rule_sty_type_id IS NULL ) THEN
          l_drs_ins_tbl(ins_count) := p_drs_tbl(i);
          --g_debug_proc('Insert Disb_Rule_Id ' || l_drs_ins_tbl(ins_count).disb_rule_id || ' , ' || l_drs_ins_tbl(ins_count).object_version_number || l_drs_ins_tbl(ins_count).DISB_RULE_STY_TYPE_ID);
          ins_count := ins_count + 1;
        ELSE
          l_drs_upd_tbl(upd_count) := p_drs_tbl(i);
          --g_debug_proc('Update Disb_Rule_Id ' || l_drs_upd_tbl(upd_count).disb_rule_id || ' , ' || l_drs_upd_tbl(upd_count).object_version_number  || l_drs_upd_tbl(upd_count).DISB_RULE_STY_TYPE_ID);
          upd_count := upd_count + 1;
        END IF;
      END LOOP;

    --g_debug_proc('Count ' || ins_count || ' , ' || upd_count );

      IF ( l_drs_ins_tbl.COUNT > 0 ) THEN
        -- insert record in to OKL_DISB_RULE_STY_TYPES
        okl_drs_pvt.insert_row( p_api_version   => l_api_version
                              , p_init_msg_list => p_init_msg_list
                              , x_return_status => x_return_status
                              , x_msg_count     => x_msg_count
                              , x_msg_data      => x_msg_data
                              , p_drs_tbl       => l_drs_ins_tbl
                              , x_drs_tbl       => lx_drs_ins_tbl);
        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
      END IF;

    --g_debug_proc('Update Insert DRS');
      IF ( l_drs_upd_tbl.COUNT > 0 ) THEN
        -- update record in to OKL_DISB_RULE_STY_TYPES
        okl_drs_pvt.update_row( p_api_version   => l_api_version
                              , p_init_msg_list => p_init_msg_list
                              , x_return_status => x_return_status
                              , x_msg_count     => x_msg_count
                              , x_msg_data      => x_msg_data
                              , p_drs_tbl       => l_drs_upd_tbl
                              , x_drs_tbl       => lx_drs_upd_tbl);
        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
      END IF;

    END IF;
    --g_debug_proc('Update DRS');

    -- Check whether we need to create or update in to OKL_DISB_RULE_VENDOR_SITES table
    IF ( p_drv_tbl.COUNT > 0) THEN
      ins_count := 0;
      upd_count := 0;
      FOR i in p_drv_tbl.FIRST .. p_drv_tbl.LAST
      LOOP
        IF ( p_drv_tbl(i).disb_rule_vendor_site_id = OKL_API.G_MISS_NUM OR
             p_drv_tbl(i).disb_rule_vendor_site_id IS NULL ) THEN
          l_drv_ins_tbl(ins_count) := p_drv_tbl(i);
          ins_count := ins_count + 1;
        ELSE
          l_drv_upd_tbl(upd_count) := p_drv_tbl(i);
          upd_count := upd_count + 1;
        END IF;
      END LOOP;

      IF ( l_drv_ins_tbl.COUNT > 0 ) THEN
        -- insert record in to OKL_DISB_RULE_VENDOR_SITES
        okl_drv_pvt.insert_row( p_api_version   => l_api_version
                              , p_init_msg_list => p_init_msg_list
                              , x_return_status => x_return_status
                              , x_msg_count     => x_msg_count
                              , x_msg_data      => x_msg_data
                              , p_drv_tbl       => l_drv_ins_tbl
                              , x_drv_tbl       => lx_drv_ins_tbl);
        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
      END IF;

        --g_debug_proc('Update Insert DRV');

      IF ( l_drv_upd_tbl.COUNT > 0 ) THEN
        -- update record in to OKL_DISB_RULE_VENDOR_SITES
        okl_drv_pvt.update_row( p_api_version   => l_api_version
                              , p_init_msg_list => p_init_msg_list
                              , x_return_status => x_return_status
                              , x_msg_count     => x_msg_count
                              , x_msg_data      => x_msg_data
                              , p_drv_tbl       => l_drv_upd_tbl
                              , x_drv_tbl       => lx_drv_upd_tbl);
        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
      END IF;
    END IF;

       -- g_debug_proc('Update DRV');

    x_drav_rec := lx_drav_rec;

    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);

  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS( l_api_name
                                                 , g_pkg_name
                                                 , 'OKL_API.G_RET_STS_ERROR'
                                                 , x_msg_count
                                                 , x_msg_data
                                                 , '_PVT' );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS( l_api_name
                                                 , g_pkg_name
                                                 , 'OKL_API.G_RET_STS_UNEXP_ERROR'
                                                 , x_msg_count
                                                 , x_msg_data
                                                 , '_PVT' );
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS( l_api_name
                                                 , g_pkg_name
                                                 , 'OTHERS'
                                                 , x_msg_count
                                                 , x_msg_data
                                                 , '_PVT' );
  END update_disbursement_rule;


END OKL_SETUP_DISB_RULES_PVT;

/
