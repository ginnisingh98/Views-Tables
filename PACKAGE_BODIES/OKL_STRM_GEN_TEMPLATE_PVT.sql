--------------------------------------------------------
--  DDL for Package Body OKL_STRM_GEN_TEMPLATE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_STRM_GEN_TEMPLATE_PVT" as
/* $Header: OKLRTSGB.pls 120.57.12010000.3 2010/03/05 19:52:33 sachandr ship $ */

 FUNCTION GET_LOOKUP_MEANING( p_lookup_type FND_LOOKUPS.LOOKUP_TYPE%TYPE
                             ,p_lookup_code FND_LOOKUPS.LOOKUP_CODE%TYPE)
    RETURN VARCHAR
    IS
    CURSOR fnd_lookup_csr(  p_lookup_type fnd_lookups.lookup_type%type
                           ,p_lookup_code fnd_lookups.lookup_code%type)
    IS
      SELECT MEANING
       FROM  FND_LOOKUPS FND
       WHERE FND.LOOKUP_TYPE = p_lookup_type
         AND FND.LOOKUP_CODE = p_lookup_code;

    l_return_value VARCHAR2(200) := OKL_API.G_MISS_CHAR;
 BEGIN
    IF (  p_lookup_type IS NOT NULL AND p_lookup_code IS NOT NULL )
    THEN
        OPEN fnd_lookup_csr( p_lookup_type, p_lookup_code );
        FETCH fnd_lookup_csr INTO l_return_value;
        CLOSE fnd_lookup_csr;
    END IF;
    return l_return_value;
 END;

  ---------------------------------------------------------------------------
  -- PROCEDURE create_strm_gen_template
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : create_strm_gen_template
  -- Description     : Create Stream Generation Template
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
Procedure create_strm_gen_template(
                     p_api_version             IN  NUMBER
                    ,p_init_msg_list           IN  VARCHAR2 DEFAULT Okc_Api.G_FALSE
                    ,x_return_status           OUT NOCOPY VARCHAR2
                    ,x_msg_count               OUT NOCOPY NUMBER
                    ,x_msg_data                OUT NOCOPY VARCHAR2
                    ,p_gtsv_rec                IN  gtsv_rec_type
                    ,p_gttv_rec                IN  gttv_rec_type
                    ,p_gtpv_tbl                IN  gtpv_tbl_type
                    ,p_gtlv_tbl                IN  gtlv_tbl_type
                    ,x_gttv_rec                OUT NOCOPY gttv_rec_type  -- Return the Template Info
      ) IS

    l_api_name          CONSTANT VARCHAR2(40) := 'create_strm_gen_template';
    l_api_version       CONSTANT NUMBER       := 1.0;
    l_return_status     VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;

    l_init_msg_list     VARCHAR2(1);
    l_msg_count         NUMBER;
    l_msg_data          VARCHAR2(2000);

    l_gtsv_rec_in  gtsv_rec_type;
    l_gttv_rec_in  gttv_rec_type;
    l_gtpv_tbl_in  gtpv_tbl_type;
    l_gtlv_tbl_in  gtlv_tbl_type;

    l_gtsv_rec_out  gtsv_rec_type;
    l_gttv_rec_out  gttv_rec_type;
    l_gtpv_tbl_out  gtpv_tbl_type;
    l_gtlv_tbl_out  gtlv_tbl_type;
    i               NUMBER;
BEGIN
    -- Perform the Initializations
    x_return_status := OKL_API.G_RET_STS_SUCCESS;

    l_return_status := OKL_API.START_ACTIVITY( l_api_name
                                             ,g_pkg_name
                                             ,p_init_msg_list
                                             ,l_api_version
                                             ,p_api_version
                                             ,'_PVT'
                                             ,x_return_status);
   IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
   ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
   END IF;

   l_gtsv_rec_in  := p_gtsv_rec;
   -- Call the insert method of the Stream Generation Template Sets
   okl_gts_pvt.insert_row(
        p_api_version => l_api_version
        ,p_init_msg_list  => p_init_msg_list
        ,x_return_status => l_return_status
        ,x_msg_count => l_msg_count
        ,x_msg_data => l_msg_data
        ,p_gtsv_rec => l_gtsv_rec_in
        ,x_gtsv_rec => l_gtsv_rec_out
   );
   IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
   ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
   END IF;

   -- Populate the Stream Generate Template Records GTS_ID
   -- with the ID returned into the l_gtsv_rec_out
   l_gttv_rec_in := p_gttv_rec;
   l_gttv_rec_in.gts_id := l_gtsv_rec_out.id;
   l_gttv_rec_in.version := '1.0';
   l_gttv_rec_in.tmpt_status := G_INIT_TMPT_STATUS;

   -- Call the insert method of the Stream Generation Template
   okl_gtt_pvt.insert_row(
        p_api_version => l_api_version
        ,p_init_msg_list  => p_init_msg_list
        ,x_return_status => l_return_status
        ,x_msg_count => l_msg_count
        ,x_msg_data => l_msg_data
        ,p_gttv_rec => l_gttv_rec_in
        ,x_gttv_rec => l_gttv_rec_out
   );
   IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
   ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
   END IF;


   -- Now Need to loop through the entire table and update the gtt_id
   -- in the pricing parameters.
   -- Making sure PL/SQL table has records in it before passing
   IF (p_gtpv_tbl.COUNT > 0) THEN

      i := p_gtpv_tbl.FIRST;
      LOOP
        l_gtpv_tbl_in(i) := p_gtpv_tbl(i);
        l_gtpv_tbl_in(i).gtt_id := l_gttv_rec_out.id;
        EXIT WHEN (i = p_gtpv_tbl.LAST);
        i := p_gtpv_tbl.NEXT(i);
      END LOOP;

      -- Call the TAPI Procedcure to perform the actual inserts
      okl_gtp_pvt.insert_row(
            p_api_version   => l_api_version
            ,p_init_msg_list => p_init_msg_list
            ,x_return_status => l_return_status
            ,x_msg_count => l_msg_count
            ,x_msg_data => l_msg_data
            ,p_gtpv_tbl => l_gtpv_tbl_in
            ,x_gtpv_tbl => l_gtpv_tbl_out
      );
      IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
   END IF;

   -- Making sure PL/SQL table has records in it before passing
   IF (p_gtlv_tbl.COUNT > 0) THEN
      i := p_gtlv_tbl.FIRST;
      LOOP
        l_gtlv_tbl_in(i) := p_gtlv_tbl(i);
        l_gtlv_tbl_in(i).gtt_id := l_gttv_rec_out.id;
        l_gtlv_tbl_in(i).primary_yn := G_INIT_PRIMARY_YN_YES;
        EXIT WHEN (i = p_gtlv_tbl.LAST);
        i := p_gtlv_tbl.NEXT(i);
      END LOOP;

      -- Call the TAPI Procedcure to perform the actual inserts
      okl_gtl_pvt.insert_row(
            p_api_version   => l_api_version
            ,p_init_msg_list => p_init_msg_list
            ,x_return_status => l_return_status
            ,x_msg_count => l_msg_count
            ,x_msg_data => l_msg_data
            ,p_gtlv_tbl => l_gtlv_tbl_in
            ,x_gtlv_tbl => l_gtlv_tbl_out
      );
      IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
   END IF;

   x_gttv_rec := l_gttv_rec_out;
   x_return_status := l_return_status;
   OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);


EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (l_api_name,
       G_PKG_NAME,
       'OKL_API.G_RET_STS_ERROR',
       x_msg_count,
       x_msg_data,
       '_PVT');
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      ( l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT');
    WHEN OTHERS THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      ( l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT');
END;

  ---------------------------------------------------------------------------
  -- PROCEDURE update_strm_gen_template
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : update_strm_gen_template
  -- Description     : Update a Stream Generation Template
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------

  PROCEDURE update_strm_gen_template(
             p_api_version             IN  NUMBER
             ,p_init_msg_list           IN  VARCHAR2 DEFAULT Okc_Api.G_FALSE
             ,x_return_status           OUT NOCOPY VARCHAR2
             ,x_msg_count               OUT NOCOPY NUMBER
             ,x_msg_data                OUT NOCOPY VARCHAR2
             ,p_gtsv_rec                IN  gtsv_rec_type
             ,p_gttv_rec                IN  gttv_rec_type
             ,p_gtpv_tbl                IN  gtpv_tbl_type
             ,p_gtlv_tbl                IN  gtlv_tbl_type
             ,x_gttv_rec                OUT NOCOPY gttv_rec_type  -- Return the Template Info
      )IS
    l_api_name          CONSTANT VARCHAR2(40) := 'update_strm_gen_template';
    l_api_version       CONSTANT NUMBER       := 1.0;
    l_return_status     VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;

    l_init_msg_list     VARCHAR2(1);
    l_msg_count         NUMBER;
    l_msg_data          VARCHAR2(2000);

    l_gtsv_rec_in      gtsv_rec_type;
    l_gttv_rec_in      gttv_rec_type;
    l_new_gttv_in_rec  gttv_rec_type;
    l_new_gttv_out_rec gttv_rec_type;
    l_gtpv_tbl_upd_in  gtpv_tbl_type;
    l_gtpv_tbl_ins_in  gtpv_tbl_type;
    l_gtlv_tbl_upd_in  gtlv_tbl_type;
    l_gtlv_tbl_ins_in  gtlv_tbl_type;

    l_gtsv_rec_out      gtsv_rec_type;
    l_gttv_rec_out      gttv_rec_type;
    l_gtpv_tbl_upd_out  gtpv_tbl_type;
    l_gtpv_tbl_ins_out  gtpv_tbl_type;
    l_gtlv_tbl_upd_out  gtlv_tbl_type;
    l_gtlv_tbl_ins_out  gtlv_tbl_type;
    i               NUMBER;
    ins_table_count NUMBER;
    upd_table_count NUMBER;
    l_max_version   NUMBER;

    -- For validating the template
    l_error_msgs_tbl error_msgs_tbl_type;
    l_return_tmpt_status   OKL_ST_GEN_TEMPLATES.TMPT_STATUS%TYPE;

   -- Modified by RGOOTY
   -- Bug 4094361: Start
   CURSOR pdt_for_active_sgt_csr(  p_gts_id OKL_ST_GEN_TMPT_SETS.ID%TYPE )
   IS
    SELECT  PDT.ID PDT_ID
           ,PRODUCT_STATUS_CODE
    FROM OKL_PRODUCTS PDT,
         OKL_AE_TMPT_SETS ATS, OKL_ST_GEN_TMPT_SETS SGT
    WHERE PDT.AES_ID = ATS.ID
      AND ATS.GTS_ID = SGT.ID
      AND SGT.ID = p_gts_id;

   CURSOR fetch_gts_id_csr(  p_gtt_id OKL_ST_GEN_TEMPLATES.ID%TYPE )
   IS
    SELECT  GTT.GTS_ID
     FROM   OKL_ST_GEN_TEMPLATES GTT
      WHERE   GTT.ID = p_gtt_id;

   CURSOR fetch_gtt_dtls_csr(  p_gtt_id OKL_ST_GEN_TEMPLATES.ID%TYPE )
   IS
    SELECT  id, gtt.gts_id, version,  tmpt_status, start_date, end_date
    FROM   OKL_ST_GEN_TEMPLATES GTT
    WHERE   GTT.ID = p_gtt_id;

   CURSOR fetch_gtt_ver_dtls_csr(  p_gts_id OKL_ST_GEN_TEMPLATES.ID%TYPE,
                                   p_version OKL_ST_GEN_TEMPLATES.version%TYPE)
   IS
    SELECT  id, gtt.gts_id, version,  tmpt_status, start_date, end_date
    FROM    OKL_ST_GEN_TEMPLATES GTT
    WHERE   GTT.gts_ID = p_gts_id
    AND     version = p_version;

    CURSOR okl_new_version_date_csr( p_gtt_id IN OKL_ST_GEN_TEMPLATES.id%type) IS
    select max(chr.start_date) MAX_START_DATE
    from okc_k_headers_b chr,
         okl_k_headers khr,
         okl_ae_tmpt_Sets aes,
         okl_st_gen_templates gtt,
         okl_products pdt
    where pdt.id = khr.pdt_id
    and pdt.aes_id = aes.id
    and  aes.gts_id = gtt.gts_id
    and khr.id = chr.id
    and chr.start_date >= gtt.start_date
    and gtt.id = p_gtt_id
--srsreeni Bug5996170 start
    and chr.sts_code in ('APPROVED','BOOKED','COMPLETE','EVERGREEN','BANKRUPTCY_HOLD','UNDER REVISION','LITIGATION_HOLD','TERMINATION_HOLD')
--srsreeni Bug5996170 end
;

   l_sgt_set_id OKL_ST_GEN_TMPT_SETS.ID%TYPE;
   l_version     OKL_ST_GEN_TEMPLATES.version%TYPE;
   l_tmpt_status OKL_ST_GEN_TEMPLATES.tmpt_status%TYPE;
   l_start_date  OKL_ST_GEN_TEMPLATES.start_date%TYPE;
   l_end_date    OKL_ST_GEN_TEMPLATES.end_date%TYPE;
   l_okl_new_version_date_rec okl_new_version_date_csr%ROWTYPE;

   -- Bug 4094361: End
BEGIN
    -- Perform the Initializations
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    l_return_status := OKL_API.START_ACTIVITY( l_api_name
                                             ,g_pkg_name
                                             ,p_init_msg_list
                                             ,l_api_version
                                             ,p_api_version
                                             ,'_PVT'
                                             ,x_return_status);
   IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
   ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
   END IF;

   l_gtsv_rec_in := p_gtsv_rec;
   l_gttv_rec_in := p_gttv_rec;
   IF ( l_gtsv_rec_in.ID IS NOT NULL OR l_gtsv_rec_in.id <> OKL_API.G_MISS_NUM
        AND l_gttv_rec_in.tmpt_status = G_INIT_TMPT_STATUS )
   THEN
       -- Allowing the Updation of the Template sets only in the case of
       -- Duplicated Templates.
       okl_gts_pvt.update_row(
            p_api_version => l_api_version
            ,p_init_msg_list  => p_init_msg_list
            ,x_return_status => l_return_status
            ,x_msg_count => l_msg_count
            ,x_msg_data => l_msg_data
            ,p_gtsv_rec => l_gtsv_rec_in
            ,x_gtsv_rec => l_gtsv_rec_out
       );
       IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;
   END IF;

   -- On Updation of anything change the status of the template will be
   -- Before Update - Status after Update
   --   NEW         -   NEW
   --   COMPLETE    -   INCOMPLETE
   --   INCOMPLETE  -   INCOMPLETE
   --   ACTIVE      -   ACTIVE
   IF (l_gttv_rec_in.tmpt_status = G_STATUS_COMPLETE)
   THEN
     l_gttv_rec_in.tmpt_status := G_STATUS_INCOMPLETE;
   END IF;


   /*
    * Bug 6911509  -> Validation of Eff From and Eff to dates
    * for versions of SGT
    */
   	FOR gts_id_rec IN fetch_gtt_dtls_csr( l_gttv_rec_in.id )
    LOOP
      l_sgt_set_id  := gts_id_rec.gts_id;
      l_version     := gts_id_rec.version;
      l_tmpt_status := gts_id_rec.tmpt_status;
      l_start_date  := gts_id_rec.start_date;
      l_end_date    := gts_id_rec.end_date;
    END LOOP;

    /**
    *
     1. From > To Date. For any active version, the Eff From is RO and "Eff To" is allowed only if next version, if any, is not "Active"
     2. For any new version > 1.0 , the From date can only greater than old value not less
     3. If any new versions From date changes, UPDATE the prev versions end date to one less than this value
     4. If any active versions "to date" changes, it can only be greater than old vlaue and UPDATE next versions "From date" to this val+1 and "To Date" to NULL
    */

    --1.
    IF  l_gttv_rec_in.end_date IS NOT NULL AND l_gttv_rec_in.end_date <> G_MISS_DATE AND
        trunc(l_gttv_rec_in.start_date) > trunc(l_gttv_rec_in.end_date)
    THEN
      okl_api.SET_MESSAGE(   p_app_name     => g_app_name,
                             p_msg_name     => 'OKL_START_DT_LESS_END_DT'
                   );
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    --2.
    IF l_tmpt_status = G_INIT_TMPT_STATUS AND l_gttv_rec_in.version <> '1.0' --meaning its greater than 1.0
    THEN
      l_version := TRIM(TO_CHAR( TO_NUMBER( l_gttv_rec_in.version ) -1 ) ) || '.0';
      --Fetch prev version and check for start date violations
        FOR gts_id_rec IN fetch_gtt_ver_dtls_csr( l_gttv_rec_in.gts_id,l_version)
          LOOP
	     IF trunc(l_gttv_rec_in.start_date) <= trunc(gts_id_rec.end_date) --(prev vers startdate)
             THEN
               --Error from condition 2 above
               okl_api.SET_MESSAGE(   p_app_name     => g_app_name,
                                      p_msg_name     => 'OKL_SGT_PREV_VER_DT_CNFLT'
                            );
               RAISE OKL_API.G_EXCEPTION_ERROR;
             END IF;
          END LOOP;
    END IF;

    --3.
    IF l_tmpt_status = G_INIT_TMPT_STATUS AND l_gttv_rec_in.version <> '1.0' --meaning its greater than 1.0
    THEN
      --Fetch previous version end date and set to one less than this start date
                 l_version := TRIM(TO_CHAR( TO_NUMBER( l_gttv_rec_in.version ) -1 ) ) || '.0';
     	FOR gts_id_rec IN fetch_gtt_ver_dtls_csr( l_gttv_rec_in.gts_id,l_version)
          LOOP
           l_new_gttv_in_rec.id         := gts_id_rec.id;
           l_new_gttv_in_rec.gts_id     := gts_id_rec.gts_id;
           l_new_gttv_in_rec.version    := gts_id_rec.version;
           l_new_gttv_in_rec.end_date   := l_gttv_rec_in.start_date - 1;

           okl_gtt_pvt.update_row
           (
             p_api_version => l_api_version
             ,p_init_msg_list  => p_init_msg_list
             ,x_return_status => l_return_status
             ,x_msg_count => l_msg_count
             ,x_msg_data => l_msg_data
             ,p_gttv_rec => l_new_gttv_in_rec
             ,x_gttv_rec => l_new_gttv_out_rec
           );
         END LOOP;
    END IF;

   --4.
    IF l_tmpt_status = G_STATUS_ACTIVE THEN

      -- Bug 9435866
      SELECT max(to_number(version))
      INTO l_max_version
      FROM OKL_ST_GEN_TEMPLATES
      WHERE gts_id = (SELECT gts_id
                      FROM OKL_ST_GEN_TEMPLATES
                      WHERE id = l_gttv_rec_in.id);
      -- The following check should be done for the latest version
      IF to_number(l_gttv_rec_in.version) = l_max_version THEN
      -- End Bug 9435866
      --Max contract start date which used this SGT
        OPEN okl_new_version_date_csr(l_gttv_rec_in.id);
        FETCH okl_new_version_date_csr INTO l_okl_new_version_date_rec ;
        CLOSE okl_new_version_date_csr;

        IF l_okl_new_version_date_rec.max_start_date IS NULL THEN
          l_okl_new_version_date_rec.max_start_date := l_start_date+1;
        END IF;
        --If SGT date is less than max khr date, error out
        IF l_gttv_rec_in.end_date IS NOT NULL AND l_gttv_rec_in.end_date <> G_MISS_DATE AND
           trunc(l_gttv_rec_in.end_date) < trunc(l_okl_new_version_date_rec.max_start_date)
        THEN
         --Error from condition 4 above
           okl_api.SET_MESSAGE(   p_app_name     => g_app_name,
                                  p_msg_name     => 'OKL_SGT_TO_DATE_BEF_KHR'
                              );
           RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
       END IF;
      END IF;

    IF l_gttv_rec_in.end_date IS NOT NULL AND (trunc(l_gttv_rec_in.end_date) <> trunc(l_end_date)) THEN --Eff to date has changed on this version
    --Fetch next version start date and set to one greater than this end date
       l_version    := TRIM(TO_CHAR( TO_NUMBER( l_gttv_rec_in.version ) +1 ) ) || '.0';
     	FOR gts_id_rec IN fetch_gtt_ver_dtls_csr( l_gttv_rec_in.gts_id,l_version)
          LOOP
           --Cant update Eff To if there are successive versions which are active
           IF gts_id_rec.tmpt_status = G_STATUS_ACTIVE THEN
             okl_api.SET_MESSAGE(   p_app_name     => g_app_name,
                                    p_msg_name     => 'OKL_SGT_NO_UPD_SUCC_ACT_VER'
                                );
             RAISE OKL_API.G_EXCEPTION_ERROR;
           END IF;

           l_new_gttv_in_rec.id         := gts_id_rec.id;
           l_new_gttv_in_rec.gts_id     := gts_id_rec.gts_id;
           l_new_gttv_in_rec.version    := gts_id_rec.version;
           l_new_gttv_in_rec.start_date := l_gttv_rec_in.end_date + 1;

           okl_gtt_pvt.update_row
           (
             p_api_version => l_api_version
             ,p_init_msg_list  => p_init_msg_list
             ,x_return_status => l_return_status
             ,x_msg_count => l_msg_count
             ,x_msg_data => l_msg_data
             ,p_gttv_rec => l_new_gttv_in_rec
             ,x_gttv_rec => l_new_gttv_out_rec
           );
         END LOOP;
    END IF;

   /* end
    * Bug 6911509  -> Validation of Eff From and Eff to dates
    * for versions of SGT
    */


   -- Call the update method of the Stream Generation Template
   okl_gtt_pvt.update_row(
        p_api_version => l_api_version
        ,p_init_msg_list  => p_init_msg_list
        ,x_return_status => l_return_status
        ,x_msg_count => l_msg_count
        ,x_msg_data => l_msg_data
        ,p_gttv_rec => l_gttv_rec_in
        ,x_gttv_rec => l_gttv_rec_out
   );
   IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
   ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
   END IF;

   -- Updating the Templates Pricing Parameters
   IF (p_gtpv_tbl.COUNT > 0) THEN
      ins_table_count :=0;
      upd_table_count :=0;
      FOR i IN p_gtpv_tbl.FIRST .. p_gtpv_tbl.LAST
      LOOP
        -- Decide whether we need to update or insert the Pricing Parameters
        -- record.
        IF (p_gtpv_tbl(i).id = Okl_Api.G_MISS_NUM OR p_gtpv_tbl(i).id IS NULL
             OR p_gtpv_tbl(i).id = 0 )
        THEN
           -- Copy into the Insert table
           l_gtpv_tbl_ins_in(ins_table_count) := p_gtpv_tbl(i);
           l_gtpv_tbl_ins_in(ins_table_count).gtt_id := l_gttv_rec_out.id;
           ins_table_count :=ins_table_count + 1;
        ELSE
           -- Copy into the Update table
           l_gtpv_tbl_upd_in(upd_table_count) := p_gtpv_tbl(i);
           upd_table_count := upd_table_count + 1;
        END IF;
      END LOOP;
      IF (l_gtpv_tbl_ins_in.COUNT > 0 )
      THEN
          -- Call the TAPI Procedcure to perform the actual inserts
          okl_gtp_pvt.insert_row(
                p_api_version   => l_api_version
                ,p_init_msg_list => p_init_msg_list
                ,x_return_status => l_return_status
                ,x_msg_count => l_msg_count
                ,x_msg_data => l_msg_data
                ,p_gtpv_tbl => l_gtpv_tbl_ins_in
                ,x_gtpv_tbl => l_gtpv_tbl_ins_out
          );
          IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;
      END IF;
      IF (l_gtpv_tbl_upd_in.COUNT > 0)
      THEN
          -- Call the TAPI Procedcure to perform the actual updates
          okl_gtp_pvt.update_row(
                p_api_version   => l_api_version
                ,p_init_msg_list => p_init_msg_list
                ,x_return_status => l_return_status
                ,x_msg_count => l_msg_count
                ,x_msg_data => l_msg_data
                ,p_gtpv_tbl => l_gtpv_tbl_upd_in
                ,x_gtpv_tbl => l_gtpv_tbl_upd_out
          );
          IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;
      END IF;
   END IF;

   -- Updating the Template Lines
   IF (p_gtlv_tbl.COUNT > 0) THEN
      ins_table_count :=0;
      upd_table_count :=0;
      FOR i IN p_gtlv_tbl.FIRST .. p_gtlv_tbl.LAST
      LOOP
        -- Decide whether we need to update or insert the Template Lines
        IF (p_gtlv_tbl(i).id = Okl_Api.G_MISS_NUM OR p_gtlv_tbl(i).id IS NULL
             OR p_gtlv_tbl(i).id = 0 )
        THEN
           -- Copy into the Insert table
           l_gtlv_tbl_ins_in(ins_table_count) := p_gtlv_tbl(i);
           l_gtlv_tbl_ins_in(ins_table_count).gtt_id := l_gttv_rec_out.id;
           l_gtlv_tbl_ins_in(ins_table_count).primary_yn := G_INIT_PRIMARY_YN_YES;
           ins_table_count := ins_table_count + 1;
        ELSE
           -- Copy into the Update table
           l_gtlv_tbl_upd_in(upd_table_count) := p_gtlv_tbl(i);
           upd_table_count := upd_table_count + 1;
        END IF;
      END LOOP;
      IF (l_gtlv_tbl_ins_in.COUNT > 0 )
      THEN
          -- Call the TAPI Procedcure to perform the actual inserts
          okl_gtl_pvt.insert_row(
                p_api_version   => l_api_version
                ,p_init_msg_list => p_init_msg_list
                ,x_return_status => l_return_status
                ,x_msg_count => l_msg_count
                ,x_msg_data => l_msg_data
                ,p_gtlv_tbl => l_gtlv_tbl_ins_in
                ,x_gtlv_tbl => l_gtlv_tbl_ins_out
          );
          IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;
      END IF;
      IF (l_gtlv_tbl_upd_in.count > 0 )
      THEN
          -- Call the TAPI Procedcure to perform the actual updates
          okl_gtl_pvt.update_row(
                p_api_version   => l_api_version
                ,p_init_msg_list => p_init_msg_list
                ,x_return_status => l_return_status
                ,x_msg_count => l_msg_count
                ,x_msg_data => l_msg_data
                ,p_gtlv_tbl => l_gtlv_tbl_upd_in
                ,x_gtlv_tbl => l_gtlv_tbl_upd_out
          );
          IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;
      END IF;
   END IF;
  /*
   -- Call the validate_template for an active template
   IF( l_gttv_rec_out.tmpt_status = G_STATUS_ACTIVE )
   THEN
        -- Call the validate_template
        validate_template(
                    p_api_version          => l_api_version
                    ,p_init_msg_list       => p_init_msg_list
                    ,x_return_status       => l_return_status
                    ,x_msg_count           => l_msg_count
                    ,x_msg_data            => l_msg_data
		            ,p_gtt_id              => l_gttv_rec_out.id
        		    ,x_error_msgs_tbl      => l_error_msgs_tbl
        		    ,x_return_tmpt_status  => l_return_tmpt_status
        		    ,p_during_upd_flag     => 'T'
                  );
        -- Modified by RGOOTY
    	-- Bug 4054596: Issue 4: Start
        IF ( l_error_msgs_tbl.count > 0 )
        THEN
            x_return_status := Okl_Api.G_RET_STS_ERROR;
            RAISE Okl_Api.G_EXCEPTION_ERROR;
        END If;
    	-- Bug 4054596: Issue 4: End

	-- Modified by RGOOTY
	-- Bug 4094361: Start
	FOR gts_id_rec IN fetch_gts_id_csr( l_gttv_rec_in.id )
        LOOP
            l_sgt_set_id := gts_id_rec.gts_id;
        END LOOP;
         -- Need to invalidate all the products which use this SGT.
         FOR pdt_rec IN pdt_for_active_sgt_csr( l_sgt_set_id )
         LOOP
            OKL_SETUPPRODUCTS_PVT.update_product_status(
                    p_api_version     => p_api_version,
                    p_init_msg_list   => p_init_msg_list,
                    x_return_status   => l_return_Status,
                    x_msg_count       => x_msg_count,
                    x_msg_data        => x_msg_data,
                    p_pdt_status      => OKL_SETUPPRODUCTS_PVT.G_PDT_STS_INVALID,
                    p_pdt_id          => pdt_rec.pdt_id  );
            IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;
         END LOOP;
         -- Bug 4094361: End
   END IF;
   */
   x_gttv_rec := l_gttv_rec_out;
   x_return_status := l_return_status;
   OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (l_api_name,
       G_PKG_NAME,
       'OKL_API.G_RET_STS_ERROR',
       x_msg_count,
       x_msg_data,
       '_PVT');
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      ( l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT');
    WHEN OTHERS THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      ( l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT');
END;

  ---------------------------------------------------------------------------
  -- PROCEDURE create_version_duplicate
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : create_version_duplicate
  -- Description     : Create a new version of a Template or a Duplicate of
  --                   Template Set.
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------

Procedure create_version_duplicate(
                    p_api_version             IN  NUMBER
                    ,p_init_msg_list           IN  VARCHAR2 DEFAULT Okc_Api.G_FALSE
                    ,x_return_status           OUT NOCOPY VARCHAR2
                    ,x_msg_count               OUT NOCOPY NUMBER
                    ,x_msg_data                OUT NOCOPY VARCHAR2
		            ,p_gtt_id                  IN  okl_st_gen_templates.id%type
		            ,p_mode                    IN  VARCHAR2 DEFAULT G_DEFAULT_MODE
                    ,x_gttv_rec                OUT NOCOPY gttv_rec_type  -- Return the Template Info
      ) IS

    l_gtt_id   OKL_ST_GEN_TEMPLATES.id%type      := p_gtt_id;
    l_mode     VARCHAR2(10)  := p_mode;
    l_api_name          CONSTANT VARCHAR2(40) := 'create_version_duplicate';
    l_api_version       CONSTANT NUMBER       := 1.0;
    l_return_status     VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;

    l_init_msg_list     VARCHAR2(1);
    l_msg_count         NUMBER;
    l_msg_data          VARCHAR2(2000);
    l_max_chr_start_date      DATE := SYSDATE;

    l_gtsv_rec_in      gtsv_rec_type;
    l_gttv_rec_in      gttv_rec_type;
    l_gttv_rec_prev_version_in      gttv_rec_type;
    l_gtpv_tbl_in      gtpv_tbl_type;
    l_gtlv_tbl_pri_in      gtlv_tbl_type;
    l_gtlv_tbl_dep_in      gtlv_tbl_type;

    l_gtsv_rec_out      gtsv_rec_type;
    l_gttv_rec_out      gttv_rec_type;
    l_gttv_rec_prev_version_out      gttv_rec_type;
    l_gtpv_tbl_out      gtpv_tbl_type;
    l_gtlv_tbl_pri_out      gtlv_tbl_type;
    l_gtlv_tbl_dep_out      gtlv_tbl_type;
    i               NUMBER;
    l_dummy VARCHAR2(1) := okl_api.G_FALSE;

    CURSOR okl_st_gen_tmpt_sets_csr(p_gts_id IN OKL_ST_GEN_TMPT_SETS.id%type) IS
    SELECT  ID
           ,NAME
           ,DESCRIPTION
           ,PRODUCT_TYPE
           ,TAX_OWNER
           ,DEAL_TYPE
           ,PRICING_ENGINE
           ,interest_calc_meth_code
           ,revenue_recog_meth_code
           ,days_in_month_code
           ,days_in_yr_code
         --  Added new field by DPSINGH for ER 6274342
           ,isg_arrears_pay_dates_option
    FROM OKL_ST_GEN_TMPT_SETS
    WHERE ID = p_gts_id;

    CURSOR okl_st_gen_templates_csr(p_gtt_id IN OKL_ST_GEN_TEMPLATES.id%type) IS
    SELECT   ID
        ,GTS_ID
        ,VERSION
        ,START_DATE
        ,END_DATE
        ,TMPT_STATUS
    FROM OKL_ST_GEN_TEMPLATES
    where ID = p_gtt_id;

    CURSOR okl_st_gen_prc_params_csr(p_gtt_id IN OKL_ST_GEN_PRC_PARAMS.gtt_id%type) IS
    SELECT   ID
        ,NAME
        ,DESCRIPTION
        ,DISPLAY_YN
        ,UPDATE_YN
        ,PRC_ENG_IDENT
        ,DEFAULT_VALUE
        ,GTT_ID
    FROM    OKL_ST_GEN_PRC_PARAMS
    where GTT_ID = p_gtt_id;

    CURSOR okl_st_gen_tmpt_lns_csr(  p_gtt_id IN OKL_ST_GEN_TMPT_LNS.gtt_id%type
                                    ,p_primary_yn IN OKL_ST_GEN_TMPT_LNS.primary_yn%TYPE) IS
    SELECT   ID
            ,GTT_ID
            ,PRIMARY_YN
            ,PRIMARY_STY_ID
            ,DEPENDENT_STY_ID
            ,PRICING_NAME
    FROM OKL_ST_GEN_TMPT_LNS
    where GTT_ID = p_gtt_id
    AND  PRIMARY_YN = p_primary_yn;

    CURSOR okl_new_version_date_csr( p_gtt_id IN OKL_ST_GEN_TEMPLATES.id%type) IS
    select max(chr.start_date) MAX_START_DATE
    from okc_k_headers_b chr,
         okl_k_headers khr,
         okl_ae_tmpt_Sets aes,
         okl_st_gen_templates gtt,
         okl_products pdt
    where pdt.id = khr.pdt_id
    and pdt.aes_id = aes.id
    and  aes.gts_id = gtt.gts_id
    and khr.id = chr.id
    and chr.start_date >= gtt.start_date
    and gtt.id = p_gtt_id
--srsreeni Bug5996170 start
    and chr.sts_code in ('APPROVED','BOOKED','COMPLETE','EVERGREEN','BANKRUPTCY_HOLD','UNDER REVISION','LITIGATION_HOLD','TERMINATION_HOLD')
--srsreeni Bug5996170 end
;

    l_new_seq_value NUMBER;
    CURSOR okl_new_tmpt_set_copy_no IS
    SELECT OKL_GTS_NAME_SEQ.NEXTVAL next_number
    FROM DUAL;

BEGIN

    -- Perform the Initializations
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    l_return_status := OKL_API.START_ACTIVITY( l_api_name
                                             ,g_pkg_name
                                             ,p_init_msg_list
                                             ,l_api_version
                                             ,p_api_version
                                             ,'_PVT'
                                             ,x_return_status);
   IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
   ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
   END IF;

   l_dummy := Okl_Api.G_FALSE;
   FOR gttv_rec_temp IN okl_st_gen_templates_csr(l_gtt_id)
   LOOP
        l_gttv_rec_in.id := gttv_rec_temp.id;
        l_gttv_rec_in.gts_id := gttv_rec_temp.gts_id;
        l_gttv_rec_in.version := gttv_rec_temp.version;
        l_gttv_rec_in.start_date := gttv_rec_temp.start_date;
        l_gttv_rec_in.end_date := gttv_rec_temp.end_date;
        l_gttv_rec_in.tmpt_status := gttv_rec_temp.tmpt_status;
        l_dummy := Okl_Api.G_TRUE;
   END LOOP;
   IF (l_dummy = okl_api.g_false) THEN
         okl_api.SET_MESSAGE(   p_app_name     => g_app_name,
                                p_msg_name     => g_invalid_value,
                                p_token1       => g_col_name_token,
                                p_token1_value => 'GTT_ID');
         RAISE OKL_API.G_EXCEPTION_ERROR;
   END IF;

   l_dummy := Okl_Api.G_FALSE;
   FOR gtsv_rec_temp IN okl_st_gen_tmpt_sets_csr(l_gttv_rec_in.gts_id)
   LOOP
        l_gtsv_rec_in.id             := gtsv_rec_temp.id;
        l_gtsv_rec_in.name           := gtsv_rec_temp.name;
        l_gtsv_rec_in.description    := gtsv_rec_temp.description;
        l_gtsv_rec_in.product_type   := gtsv_rec_temp.product_type;
        l_gtsv_rec_in.tax_owner      := gtsv_rec_temp.tax_owner;
        l_gtsv_rec_in.deal_type      := gtsv_rec_temp.deal_type;
        l_gtsv_rec_in.pricing_engine := gtsv_rec_temp.pricing_engine;
        l_gtsv_rec_in.interest_calc_meth_code:= gtsv_rec_temp.interest_calc_meth_code;
        l_gtsv_rec_in.revenue_recog_meth_code:= gtsv_rec_temp.revenue_recog_meth_code;
        l_gtsv_rec_in.days_in_month_code:= gtsv_rec_temp.days_in_month_code;
        l_gtsv_rec_in.days_in_yr_code:= gtsv_rec_temp.days_in_yr_code;
        --  Added new field by DJANASWA for ER 6274359(H)
        l_gtsv_rec_in.isg_arrears_pay_dates_option := gtsv_rec_temp.isg_arrears_pay_dates_option;

        l_dummy := Okl_Api.G_TRUE;
   END LOOP;
   IF (l_dummy = okl_api.g_false) THEN
         okl_api.SET_MESSAGE(   p_app_name     => g_app_name,
                                p_msg_name     => g_invalid_value,
                                p_token1       => g_col_name_token,
                                p_token1_value => 'GTS_ID');
         RAISE OKL_API.G_EXCEPTION_ERROR;
   END IF;

   IF p_mode IS NULL OR p_mode = G_DEFAULT_MODE
   THEN
        -- For Duplicate
        l_gtsv_rec_in.id := G_MISS_NUM;   -- New ID will be created
        FOR new_tmpt_set_copy_no In okl_new_tmpt_set_copy_no LOOP
            l_new_seq_value := new_tmpt_set_copy_no.next_number;
        END LOOP;
        l_gtsv_rec_in.name := ( SUBSTR(l_gtsv_rec_in.name, 1, 135) || '-COPY')
        || l_new_seq_value;
        OKL_GTS_PVT.insert_row(
            p_api_version => l_api_version
            ,p_init_msg_list  => p_init_msg_list
            ,x_return_status => l_return_status
            ,x_msg_count => l_msg_count
            ,x_msg_data => l_msg_data
            ,p_gtsv_rec => l_gtsv_rec_in
            ,x_gtsv_rec => l_gtsv_rec_out
        );
       IF (l_return_status = okl_api.G_RET_STS_UNEXP_ERROR) THEN
           RAISE okl_api.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (l_return_status = okl_api.G_RET_STS_ERROR) THEN
           RAISE okl_api.G_EXCEPTION_ERROR;
       END IF;
       -- For Duplicate
       l_gttv_rec_in.gts_id      := l_gtsv_rec_out.id;  -- Id of the New GTS Created
       l_gttv_rec_in.version     := '1.0';     -- VERSION TO 1.0
    ELSE
       -- Fetch the Maximum of Start Date of the contracts using this template

       FOR new_date_rec IN okl_new_version_date_csr(l_gtt_id)
       LOOP
           l_max_chr_start_date := new_date_rec.max_start_date;
       END LOOP;
       IF ( l_max_chr_start_date IS NULL )
       THEN
           -- If no start_date is found, then take the previous version start_date
           -- as the max_Start_date
           l_max_chr_start_date := l_gttv_rec_in.start_date;
       END IF;
       -- Modifications to be done for the current template version
       -- Current version template end_date will be updated with l_max_chr_start_date + 1
       l_gttv_rec_prev_version_in := l_gttv_rec_in;
       l_gttv_rec_prev_version_in.id := l_gtt_id;
       l_gttv_rec_prev_version_in.end_date := l_max_chr_start_date + 1;
       okl_gtt_pvt.update_row(
            p_api_version => l_api_version
            ,p_init_msg_list  => p_init_msg_list
            ,x_return_status => l_return_status
            ,x_msg_count => l_msg_count
            ,x_msg_data => l_msg_data
            ,p_gttv_rec => l_gttv_rec_prev_version_in
            ,x_gttv_rec => l_gttv_rec_prev_version_out
       );
       IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;
       -- Modifications for New Version
       l_gttv_rec_in.version     := TRIM(TO_CHAR( TO_NUMBER( l_gttv_rec_in.version ) + 1 ) ) || '.0';
       l_gttv_rec_in.start_date := l_gttv_rec_prev_version_out.end_date + 1;

    END IF;
    l_gttv_rec_in.id          := G_MISS_NUM;
    l_gttv_rec_in.tmpt_status := G_INIT_TMPT_STATUS; -- Make the New Template Status to NEW
    l_gttv_rec_in.end_date    := G_MISS_DATE;        -- END_DATE as G_MISS_DATE
    okl_gtt_pvt.insert_row(
        p_api_version => l_api_version
        ,p_init_msg_list  => p_init_msg_list
        ,x_return_status => l_return_status
        ,x_msg_count => l_msg_count
        ,x_msg_data => l_msg_data
        ,p_gttv_rec => l_gttv_rec_in
        ,x_gttv_rec => l_gttv_rec_out
    );
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
   -- Fetch all the pricing parameters and call the API
   i := 0;
   FOR gtpv_rec_temp IN okl_st_gen_prc_params_csr(l_gtt_id)
   LOOP
        l_gtpv_tbl_in(i).name          := gtpv_rec_temp.name;
        l_gtpv_tbl_in(i).description   := gtpv_rec_temp.description ;
        l_gtpv_tbl_in(i).display_yn    := gtpv_rec_temp.display_yn ;
        l_gtpv_tbl_in(i).update_yn     := gtpv_rec_temp.update_yn ;
        l_gtpv_tbl_in(i).prc_eng_ident := gtpv_rec_temp.prc_eng_ident ;
        l_gtpv_tbl_in(i).default_value := gtpv_rec_temp.default_value ;
        -- Populate records with the new Template ID
        l_gtpv_tbl_in(i).gtt_id        := l_gttv_rec_out.id;
        i := i + 1;
   END LOOP;
   IF (l_gtpv_tbl_in.COUNT > 0 )
   THEN
       -- Call the TAPI Procedcure to perform the actual inserts
       okl_gtp_pvt.insert_row(
                    p_api_version   => l_api_version
                    ,p_init_msg_list => p_init_msg_list
                    ,x_return_status => l_return_status
                    ,x_msg_count => l_msg_count
                    ,x_msg_data => l_msg_data
                    ,p_gtpv_tbl => l_gtpv_tbl_in
                    ,x_gtpv_tbl => l_gtpv_tbl_out
       );
       IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;
   END IF;

   -- Fetch all the primary streams and call the insert API
   i := 0;
   FOR gtlv_rec_temp IN okl_st_gen_tmpt_lns_csr(l_gtt_id, G_INIT_PRIMARY_YN_YES )
   LOOP
        l_gtlv_tbl_pri_in(i).primary_yn := G_INIT_PRIMARY_YN_YES;
        l_gtlv_tbl_pri_in(i).primary_sty_id := gtlv_rec_temp.primary_sty_id;
        -- Dependent Streams wont be present for this Stream
        --l_gtlv_tbl_in(i).dependent_sty_id := gtlv_rec_temp.dependent_sty_id;
        l_gtlv_tbl_pri_in(i).pricing_name := gtlv_rec_temp.pricing_name;
        -- Populate the Template ID as the new Template Created
        l_gtlv_tbl_pri_in(i).gtt_id := l_gttv_rec_out.id;
        i := i + 1;
   END LOOP;
   IF (l_gtlv_tbl_pri_in.COUNT > 0 )
   THEN
       -- Call the TAPI Procedcure to perform the actual inserts
       okl_gtl_pvt.insert_row(
                    p_api_version   => l_api_version
                    ,p_init_msg_list => p_init_msg_list
                    ,x_return_status => l_return_status
                    ,x_msg_count => l_msg_count
                    ,x_msg_data => l_msg_data
                    ,p_gtlv_tbl => l_gtlv_tbl_pri_in
                    ,x_gtlv_tbl => l_gtlv_tbl_pri_out
       );
       IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;
   END IF;

   -- Fetch all the dependent streams and call the insert API
   i := 0;
   FOR gtlv_rec_temp IN okl_st_gen_tmpt_lns_csr(l_gtt_id, G_INIT_PRIMARY_YN_NO )
   LOOP
        l_gtlv_tbl_dep_in(i).primary_yn := G_INIT_PRIMARY_YN_NO;
        l_gtlv_tbl_dep_in(i).primary_sty_id := gtlv_rec_temp.primary_sty_id;
        l_gtlv_tbl_dep_in(i).dependent_sty_id := gtlv_rec_temp.dependent_sty_id;
        l_gtlv_tbl_dep_in(i).pricing_name := gtlv_rec_temp.pricing_name;
        -- Populate the Template ID as the new Template Created
        l_gtlv_tbl_dep_in(i).gtt_id := l_gttv_rec_out.id;
        i := i + 1;
   END LOOP;
   IF (l_gtlv_tbl_dep_in.COUNT > 0 )
   THEN
       -- Call the TAPI Procedcure to perform the actual inserts
       okl_gtl_pvt.insert_row(
                    p_api_version   => l_api_version
                    ,p_init_msg_list => p_init_msg_list
                    ,x_return_status => l_return_status
                    ,x_msg_count => l_msg_count
                    ,x_msg_data => l_msg_data
                    ,p_gtlv_tbl => l_gtlv_tbl_dep_in
                    ,x_gtlv_tbl => l_gtlv_tbl_dep_out
       );
       IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;
   END IF;

   x_gttv_rec      := l_gttv_rec_out;
   x_return_status := l_return_status;
   OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (l_api_name,
       G_PKG_NAME,
       'OKL_API.G_RET_STS_ERROR',
       x_msg_count,
       x_msg_data,
       '_PVT');
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      ( l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT');
    WHEN OTHERS THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      ( l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT');
END;

 ---------------------------------------------------------------------------
  -- PROCEDURE delete_tmpt_prc_params
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : delete_tmpt_prc_params
  -- Description     : Deletes the Template Pricing Parameters
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------

Procedure delete_tmpt_prc_params(
                    p_api_version             IN  NUMBER
                    ,p_init_msg_list           IN  VARCHAR2 DEFAULT Okc_Api.G_FALSE
                    ,x_return_status           OUT NOCOPY VARCHAR2
                    ,x_msg_count               OUT NOCOPY NUMBER
                    ,x_msg_data                OUT NOCOPY VARCHAR2
                    ,p_gtpv_tbl                IN  gtpv_tbl_type
      ) IS
    l_gtt_id            okl_st_gen_templates.id%type ;
    l_api_name          CONSTANT VARCHAR2(40) := 'delete_tmpt_prc_params';
    l_api_version       CONSTANT NUMBER       := 1.0;
    l_return_status     VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;

    l_init_msg_list     VARCHAR2(1) := p_init_msg_list;
    l_msg_count         NUMBER;
    l_msg_data          VARCHAR2(2000);

    l_gttv_rec         gttv_rec_type;
    l_gtpv_tbl_del_in  gtpv_tbl_type := p_gtpv_tbl;

    l_dummy VARCHAR2(1) := okl_api.G_FALSE;

BEGIN
    -- Perform the Initializations
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    l_return_status := OKL_API.START_ACTIVITY( l_api_name
                                             ,g_pkg_name
                                             ,p_init_msg_list
                                             ,l_api_version
                                             ,p_api_version
                                             ,'_PVT'
                                             ,x_return_status);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
   OKL_GTP_PVT.delete_row(
         p_api_version  => l_api_version
        ,p_init_msg_list => l_init_msg_list
        ,x_return_status => l_return_status
        ,x_msg_count => l_msg_count
        ,x_msg_data => l_msg_data
        ,p_gtpv_tbl => l_gtpv_tbl_del_in
   );
   IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
   ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
   END IF;

   x_return_status := l_return_status;
   OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (l_api_name,
       G_PKG_NAME,
       'OKL_API.G_RET_STS_ERROR',
       x_msg_count,
       x_msg_data,
       '_PVT');
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      ( l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT');
    WHEN OTHERS THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      ( l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT');
END;

 ---------------------------------------------------------------------------
  -- PROCEDURE delete_pri_tmpt_lns
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : delete_pri_tmpt_lns
  -- Description     : Deletes the Primary Template Lines
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------

Procedure delete_pri_tmpt_lns(
                    p_api_version             IN  NUMBER
                    ,p_init_msg_list           IN  VARCHAR2 DEFAULT Okc_Api.G_FALSE
                    ,x_return_status           OUT NOCOPY VARCHAR2
                    ,x_msg_count               OUT NOCOPY NUMBER
                    ,x_msg_data                OUT NOCOPY VARCHAR2
                    ,p_gtlv_tbl                IN  gtlv_tbl_type
      )IS
    l_gtt_id            okl_st_gen_templates.id%type;
    l_api_name          CONSTANT VARCHAR2(40) := 'delete_pri_tmpt_lns';
    l_api_version       CONSTANT NUMBER       := 1.0;
    l_return_status     VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;

    l_init_msg_list     VARCHAR2(1);
    l_msg_count         NUMBER;
    l_msg_data          VARCHAR2(2000);
    l_dummy VARCHAR2(1) := okl_api.G_FALSE;

    l_gttv_rec             gttv_rec_type;
    l_gtlv_pri_tbl_del_in  gtlv_tbl_type;
    l_gtlv_dep_tbl_del_in  gtlv_tbl_type;
    i              NUMBER := 0;

    CURSOR okl_st_gen_tmpt_dep_lns_csr(  p_gtt_id IN OKL_ST_GEN_TMPT_LNS.gtt_id%type
                                        ,p_primary_sty_id IN OKL_ST_GEN_TMPT_LNS.PRIMARY_STY_ID %type) IS
    SELECT  ID
           ,PRIMARY_STY_ID
           ,DEPENDENT_STY_ID
           ,GTT_ID
    FROM   OKL_ST_GEN_TMPT_LNS
    WHERE  PRIMARY_YN = 'N'
      AND  PRIMARY_STY_ID = p_primary_sty_id
      AND  GTT_ID = p_gtt_id;
BEGIN
    -- Perform the Initializations
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    l_return_status := OKL_API.START_ACTIVITY( l_api_name
                                             ,g_pkg_name
                                             ,p_init_msg_list
                                             ,l_api_version
                                             ,p_api_version
                                             ,'_PVT'
                                             ,x_return_status);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

   l_gtlv_pri_tbl_del_in := p_gtlv_tbl;
   FOR J in l_gtlv_pri_tbl_del_in.FIRST .. l_gtlv_pri_tbl_del_in.LAST
   LOOP
        -- Open the cursor for this particular primary_sty_id
        -- and build l_gtlv_dep_tbl_del_in and call the table API.
        i := 1;
        FOR l_gtlv_dep_rec in okl_st_gen_tmpt_dep_lns_csr( l_gtlv_pri_tbl_del_in(j).gtt_id,
                                                          l_gtlv_pri_tbl_del_in(j).primary_sty_id
                                                        )
        LOOP
            l_gtlv_dep_tbl_del_in(i).id               := l_gtlv_dep_rec.id;
            l_gtlv_dep_tbl_del_in(i).gtt_id           := l_gtlv_dep_rec.gtt_id;
            l_gtlv_dep_tbl_del_in(i).primary_sty_id   := l_gtlv_dep_rec.primary_sty_id;
            l_gtlv_dep_tbl_del_in(i).dependent_sty_id := l_gtlv_dep_rec.dependent_sty_id;
            i := i + 1;
        END LOOP;
        IF l_gtlv_dep_tbl_del_in.COUNT > 0
        THEN
            Okl_Gtl_Pvt.delete_row(
                p_api_version   => l_api_version,
                p_init_msg_list => l_init_msg_list,
                x_return_status => l_return_status,
                x_msg_count     => l_msg_count,
                x_msg_data      => l_msg_data,
                p_gtlv_tbl      => l_gtlv_dep_tbl_del_in);

           IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
           ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_ERROR;
           END IF;
           l_gtlv_dep_tbl_del_in.DELETE;
        END IF;
   END LOOP;
   Okl_Gtl_Pvt.delete_row(
    p_api_version   => l_api_version,
    p_init_msg_list => l_init_msg_list,
    x_return_status => l_return_status,
    x_msg_count     => l_msg_count,
    x_msg_data      => l_msg_data,
    p_gtlv_tbl      => l_gtlv_pri_tbl_del_in);

   IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
   ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
   END IF;

   x_return_status := l_return_status;
   OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (l_api_name,
       G_PKG_NAME,
       'OKL_API.G_RET_STS_ERROR',
       x_msg_count,
       x_msg_data,
       '_PVT');
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      ( l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT');
    WHEN OTHERS THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      ( l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT');
END;

  ---------------------------------------------------------------------------
  -- PROCEDURE delete_dep_tmpt_lns
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : delete_dep_tmpt_lns
  -- Description     : Deletes the Dependent Lines of a Template
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------

Procedure delete_dep_tmpt_lns(
                    p_api_version             IN  NUMBER
                    ,p_init_msg_list           IN  VARCHAR2 DEFAULT Okc_Api.G_FALSE
                    ,x_return_status           OUT NOCOPY VARCHAR2
                    ,x_msg_count               OUT NOCOPY NUMBER
                    ,x_msg_data                OUT NOCOPY VARCHAR2
                    ,p_gtlv_tbl                IN  gtlv_tbl_type
      )IS
    l_gtt_id            okl_st_gen_templates.id%type;
    l_api_name          CONSTANT VARCHAR2(40) := 'delete_dep_tmpt_lns';
    l_api_version       CONSTANT NUMBER       := 1.0;
    l_return_status     VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;

    l_init_msg_list     VARCHAR2(1);
    l_msg_count         NUMBER;
    l_msg_data          VARCHAR2(2000);
    l_dummy VARCHAR2(1) := okl_api.G_FALSE;

    l_gttv_rec         gttv_rec_type;
    l_gtlv_tbl_del_in  gtlv_tbl_type := p_gtlv_tbl;
BEGIN
    -- Perform the Initializations
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    l_return_status := OKL_API.START_ACTIVITY( l_api_name
                                             ,g_pkg_name
                                             ,p_init_msg_list
                                             ,l_api_version
                                             ,p_api_version
                                             ,'_PVT'
                                             ,x_return_status);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

   Okl_Gtl_Pvt.delete_row(
    p_api_version   => l_api_version,
    p_init_msg_list => l_init_msg_list,
    x_return_status => l_return_status,
    x_msg_count     => l_msg_count,
    x_msg_data      => l_msg_data,
    p_gtlv_tbl      => l_gtlv_tbl_del_in);

   IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
   ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
   END IF;

   x_return_status := l_return_status;
   OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (l_api_name,
       G_PKG_NAME,
       'OKL_API.G_RET_STS_ERROR',
       x_msg_count,
       x_msg_data,
       '_PVT');
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      ( l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT');
    WHEN OTHERS THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      ( l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT');
END;

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_template
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : validate_template
  -- Description     : Validate a Stream Generation Template
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
FUNCTION belongs_to_ls( p_book_classification IN VARCHAR2 )
    RETURN BOOLEAN
IS
  l_book_classification OKL_ST_GEN_TMPT_SETS.DEAL_TYPE%TYPE := UPPER( p_book_classification );
BEGIN
    IF ( l_book_classification = G_LEASEDF_DEAL_TYPE  OR
         l_book_classification = G_LEASEOP_DEAL_TYPE  OR
         l_book_classification = G_LEASEST_DEAL_TYPE  )
    THEN
        RETURN TRUE;
    ELSE
        RETURN FALSE;
    END IF;
END;

FUNCTION belongs_to_ln( p_book_classification IN VARCHAR2 )
    RETURN BOOLEAN
IS
  l_book_classification OKL_ST_GEN_TMPT_SETS.DEAL_TYPE%TYPE := UPPER( p_book_classification );
BEGIN
    IF (   l_book_classification = G_LOAN_DEAL_TYPE      OR
            l_book_classification = G_LOAN_REV_DEAL_TYPE )
     THEN
        RETURN TRUE;
    ELSE
        RETURN FALSE;
    END IF;
END;

FUNCTION belongs_to_df_st( p_book_classification IN VARCHAR2 )
    RETURN BOOLEAN
IS
  l_book_classification OKL_ST_GEN_TMPT_SETS.DEAL_TYPE%TYPE  := UPPER( p_book_classification );
BEGIN
    IF (   l_book_classification = G_LEASEDF_DEAL_TYPE OR
           l_book_classification = G_LEASEST_DEAL_TYPE )
    THEN
        RETURN TRUE;
    ELSE
        RETURN FALSE;
    END IF;
END;

FUNCTION belongs_to_op( p_book_classification IN VARCHAR2 )
RETURN BOOLEAN
IS
  l_book_classification OKL_ST_GEN_TMPT_SETS.DEAL_TYPE%TYPE  := UPPER( p_book_classification );
BEGIN
    IF (   l_book_classification = G_LEASEOP_DEAL_TYPE )
    THEN
        RETURN TRUE;
    ELSE
        RETURN FALSE;
    END IF;
END;

PROCEDURE put_messages_in_table(  p_msg_name IN VARCHAR2
            		             ,p_during_upd_flag         IN VARCHAR
                                 ,x_msg_out  OUT NOCOPY VARCHAR2
                                 ,p_token1   IN VARCHAR2 DEFAULT NULL
                                 ,p_value1   IN VARCHAR2 DEFAULT NULL
                                 ,p_token2   IN VARCHAR2 DEFAULT NULL
                                 ,p_value2   IN VARCHAR2 DEFAULT NULL
                               )
 IS
    l_msg VARCHAR2(2700);
BEGIN
    FND_MESSAGE.SET_NAME( g_app_name, p_msg_name );
    IF ( p_token1 IS NOT NULL )
    THEN
        FND_MESSAGE.SET_TOKEN(  TOKEN => p_token1,
                                VALUE => p_value1);
    END IF;
    IF ( p_token2 IS NOT NULL )
    THEN
        FND_MESSAGE.SET_TOKEN(  TOKEN => p_token2,
                                VALUE => p_value2 );
    END IF;
    l_msg := FND_MESSAGE.GET;
    IF ( UPPER(p_during_upd_flag) = 'T' )
    THEN
        OKL_API.SET_MESSAGE(  g_app_name
                             ,p_msg_name
                             ,p_token1
                             ,p_value1
                             ,p_token2
                             ,p_value2
                           );
    END IF;
    -- Return the Message
    x_msg_out := l_msg;
END put_messages_in_table;

  ---------------------------------------------------------------------------
  -- PROCEDURE val_ic_rr_day_con_methods
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : val_ic_rr_day_con_methods
  -- Description     : Validates a Stream Generation Template based on IC / Rev Rec methods
  -- Business Rules  : Rule 0. Day convention validations
  --                   Rule 1. If Interest Calculation Method is not Fixed
  --                           or if Revenue Recognition Method is not equal Actual,
  --                           Pricing Engine must be External
  --                   Rule 2/3. If Book classification is LOAN / REVLOAN, billable flag is checked
  --                   Rule 4. For Lease classification, Rent stream must be billable and
  --                           RR only can be Streams and IC can only be Reamort and Float Factor
  --
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------

  PROCEDURE val_ic_rr_day_con_methods(
                     p_api_version             IN  NUMBER
                    ,p_init_msg_list           IN  VARCHAR2 DEFAULT Okc_Api.G_FALSE
                    ,x_return_status           OUT NOCOPY VARCHAR2
                    ,x_msg_count               OUT NOCOPY NUMBER
                    ,x_msg_data                OUT NOCOPY VARCHAR2
                    ,p_gtt_id                  IN  okl_st_gen_templates.id%type
                    ,x_error_msgs_tbl          OUT NOCOPY error_msgs_tbl_type
                    ,p_during_upd_flag         IN VARCHAR
                    ,p_book_classification     IN VARCHAR
            )
  IS
    CURSOR get_revrec_intcalc_meth IS
      SELECT interest_calc_meth_code,
             revenue_recog_meth_code,
             pricing_engine         ,
      days_in_month_code     ,
             days_in_yr_code
      FROM OKL_ST_GEN_TMPT_SETS
      WHERE ID = (
                  SELECT gts_id
                  FROM okl_st_gen_templates
                  WHERE id = p_gtt_id
                  );

    CURSOR get_billable_flag IS
      SELECT stb.stream_type_purpose purpose,
             stb.billable_yn
      FROM   OKL_ST_GEN_TMPT_LNS  gtl
             ,okl_strm_type_b stb
      WHERE
               gtl.gtt_id = p_gtt_id
      AND      gtl.DEPENDENT_STY_ID = stb.id
      AND      gtl.primary_yn = 'N'
      AND      stb.stream_type_purpose IN
      (
        'PRINCIPAL_PAYMENT'
        ,'INTEREST_PAYMENT'
        ,'LOAN_PAYMENT'
      )
      AND   gtl.PRIMARY_STY_ID IN
      (
        SELECT id
        FROM okl_strm_type_b
        WHERE stream_type_purpose='RENT'
      );

    CURSOR get_rent_flag IS
      SELECT stb.stream_type_purpose purpose, stb.billable_yn
      FROM   OKL_ST_GEN_TMPT_LNS  gtl
             ,okl_strm_type_b stb
      WHERE
               gtl.gtt_id = p_gtt_id
      AND gtl.PRIMARY_STY_ID = stb.id
      AND gtl.primary_yn = 'Y'
      AND stb.stream_type_purpose ='RENT';
    --Local variable declarations
    l_interest_calc_meth   OKL_ST_GEN_TMPT_SETS.interest_calc_meth_code%TYPE;
    l_revenue_recog_meth   OKL_ST_GEN_TMPT_SETS.revenue_recog_meth_code%TYPE;
    l_purpose              okl_strm_type_b.billable_yn%TYPE;
    l_billable_yn          okl_strm_type_b.stream_type_purpose%TYPE;
    l_pricing_engine       OKL_ST_GEN_TMPT_SETS.pricing_engine%TYPE;
    l_days_in_month_code   OKL_ST_GEN_TMPT_SETS.days_in_month_code %TYPE;
    l_days_in_yr_code      OKL_ST_GEN_TMPT_SETS.days_in_yr_code%TYPE;
    l_days_month_yr_concat VARCHAR2(2700);
    l_msgs_count           NUMBER := 0;
    l_message              VARCHAR2(2700);
    get_billable_flag_rec  get_billable_flag%ROWTYPE;

  BEGIN
    OPEN get_revrec_intcalc_meth;
    FETCH get_revrec_intcalc_meth INTO l_interest_calc_meth,
                                       l_revenue_recog_meth,
                                       l_pricing_engine,
                                       l_days_in_month_code,
                                       l_days_in_yr_code;
    CLOSE get_revrec_intcalc_meth;
    l_days_month_yr_concat := l_days_in_month_code ||'*'|| l_days_in_yr_code;
    --Rule 0. Day convention validations
    IF NVL(l_pricing_engine,'*') = 'EXTERNAL'
    THEN
      IF    (l_days_month_yr_concat <> '30*360')
       AND (l_days_month_yr_concat <> 'ACTUAL*365')
       AND (l_days_month_yr_concat <> 'ACTUAL*360')
       AND (l_days_month_yr_concat <> '30*365')
       AND (l_days_month_yr_concat <> 'ACTUAL*ACTUAL')
      THEN
        /*Add error to table */
        put_messages_in_table(G_OKL_DAY_CONVEN_VAL_EXT
                              ,p_during_upd_flag
                              ,l_message
                              );
        x_error_msgs_tbl(l_msgs_count).error_message := l_message;
        x_error_msgs_tbl(l_msgs_count).error_type_code := G_TYPE_ERROR;
        x_error_msgs_tbl(l_msgs_count).error_type_meaning := GET_LOOKUP_MEANING( G_CP_SET_OUTCOME, G_TYPE_ERROR);
        l_msgs_count := l_msgs_count + 1;
      END IF;
    ELSIF NVL(l_pricing_engine,'*') = 'INTERNAL'
    THEN
      --Modified by rgooty for bug 8347926 to allow day convention Actual/365 instead of Actual/360
      IF    (l_days_month_yr_concat <> '30*360')
       AND (l_days_month_yr_concat <> 'ACTUAL*365')
       AND (l_days_month_yr_concat <> 'ACTUAL*ACTUAL')
      THEN
        /*Add error to table */
        put_messages_in_table(G_OKL_DAY_CONVEN_VAL_INT
                              ,p_during_upd_flag
                              ,l_message
                              );
        x_error_msgs_tbl(l_msgs_count).error_message := l_message;
        x_error_msgs_tbl(l_msgs_count).error_type_code := G_TYPE_ERROR;
        x_error_msgs_tbl(l_msgs_count).error_type_meaning := GET_LOOKUP_MEANING( G_CP_SET_OUTCOME, G_TYPE_ERROR);
        l_msgs_count := l_msgs_count + 1;
      END IF;
    END IF;
    --Rule 1. If Interest Calculation Method is not Fixed  or if Revenue Recognition Method is not equal Actual,
    --        Pricing Engine must be External
    -- VR Upgrade change. Bug 4756154
    -- Modified Rule is
    --  "If Interest Calculation Method is not Fixed, Fixed-Upgrade or if Revenue Recognition Method
    --    is not STREAMS, then Pricing Engine Must be EXTERNAL."
    IF ( NVL(l_interest_calc_meth,'*') <> 'FIXED' AND
         NVL( l_interest_calc_meth, '*') <> 'FIXED_UPGRADE' )
      OR NVL(l_revenue_recog_meth,'*') <> 'STREAMS'
    THEN
      IF NVL(l_pricing_engine,'*') <> 'EXTERNAL'
      THEN
        put_messages_in_table(G_OKL_IC_RR_PRC_ENG_EXT
                              ,p_during_upd_flag
                              ,l_message
                              );
        x_error_msgs_tbl(l_msgs_count).error_message := l_message;
        x_error_msgs_tbl(l_msgs_count).error_type_code := G_TYPE_ERROR;
        x_error_msgs_tbl(l_msgs_count).error_type_meaning := GET_LOOKUP_MEANING( G_CP_SET_OUTCOME, G_TYPE_ERROR);
        l_msgs_count := l_msgs_count + 1;
      END IF;
    END IF;
    --Rule 2. Loan classification is LOAN / REV LOAN
    IF (belongs_to_ln(p_book_classification)) AND
       l_interest_calc_meth <> 'FIXED_UPGRADE'  -- VR Upgrade. Bug 4756154
    THEN
      FOR get_billable_flag_rec IN get_billable_flag
      LOOP
        /*If Rev Rec is STREAMS, principal, loan payment etc should be defined with appropriate flags*/
        IF l_revenue_recog_meth = 'STREAMS'
        THEN
        /*Check billable flags*/
          IF get_billable_flag_rec.purpose = 'PRINCIPAL_PAYMENT' AND
             get_billable_flag_rec.billable_yn = 'N'
          THEN
            /*Add to error table*/
            put_messages_in_table(   G_OKL_STRM_BILL_FLAG_YN
                                    ,p_during_upd_flag
                                    ,l_message
                                    ,p_token1 => 'STREAM'
                                    ,p_value1 => OKL_ACCOUNTING_UTIL.GET_LOOKUP_MEANING( G_OKL_FIN_DEPENDENT_PURPOSES, 'PRINCIPAL_PAYMENT' )
                                    ,p_token2 => 'BILL_YN'
                                    ,p_value2 => OKL_ACCOUNTING_UTIL.GET_LOOKUP_MEANING( 'OKL_YES_NO', 'Y' )
                                 );
            x_error_msgs_tbl(l_msgs_count).error_message := l_message;
            x_error_msgs_tbl(l_msgs_count).error_type_code := G_TYPE_ERROR;
            x_error_msgs_tbl(l_msgs_count).error_type_meaning := GET_LOOKUP_MEANING( G_CP_SET_OUTCOME, G_TYPE_ERROR);
            l_msgs_count := l_msgs_count + 1;
          ELSIF get_billable_flag_rec.purpose = 'INTEREST_PAYMENT' AND
                get_billable_flag_rec.billable_yn = 'N'
          THEN
            put_messages_in_table(   G_OKL_STRM_BILL_FLAG_YN
                                    ,p_during_upd_flag
                                    ,l_message
                                    ,p_token1 => 'STREAM'
                                    ,p_value1 => OKL_ACCOUNTING_UTIL.GET_LOOKUP_MEANING( G_OKL_FIN_DEPENDENT_PURPOSES, 'INTEREST_PAYMENT' )
                                    ,p_token2 => 'BILL_YN'
                                    ,p_value2 => OKL_ACCOUNTING_UTIL.GET_LOOKUP_MEANING( 'OKL_YES_NO', 'Y' )
                                 );
            x_error_msgs_tbl(l_msgs_count).error_message := l_message;
            x_error_msgs_tbl(l_msgs_count).error_type_code := G_TYPE_ERROR;
            x_error_msgs_tbl(l_msgs_count).error_type_meaning := GET_LOOKUP_MEANING( G_CP_SET_OUTCOME, G_TYPE_ERROR);
            l_msgs_count := l_msgs_count + 1;
          ELSIF get_billable_flag_rec.purpose = 'LOAN_PAYMENT' AND
                get_billable_flag_rec.billable_yn = 'Y'
          THEN
            put_messages_in_table(   G_OKL_STRM_BILL_FLAG_YN
                                    ,p_during_upd_flag
                                    ,l_message
                                    ,p_token1 => 'STREAM'
                                    ,p_value1 => OKL_ACCOUNTING_UTIL.GET_LOOKUP_MEANING( G_OKL_FIN_DEPENDENT_PURPOSES, 'LOAN_PAYMENT' )
                                    ,p_token2 => 'BILL_YN'
                                    ,p_value2 => OKL_ACCOUNTING_UTIL.GET_LOOKUP_MEANING( 'OKL_YES_NO', 'N' )
                                 );
            x_error_msgs_tbl(l_msgs_count).error_message := l_message;
            x_error_msgs_tbl(l_msgs_count).error_type_code := G_TYPE_ERROR;
            x_error_msgs_tbl(l_msgs_count).error_type_meaning := GET_LOOKUP_MEANING( G_CP_SET_OUTCOME, G_TYPE_ERROR);
            l_msgs_count := l_msgs_count + 1;
          END IF;
          /*If Rev Rec is ACTUAL, int calc = FIXED OR REAMORT principal payment etc should be defined with appropriate flags*/
        ELSIF l_revenue_recog_meth = 'ACTUAL' AND (l_interest_calc_meth = 'FIXED' OR l_interest_calc_meth = 'REAMORT')
        THEN
          /*Check billable flags*/
          IF  get_billable_flag_rec.purpose = 'PRINCIPAL_PAYMENT' AND
              get_billable_flag_rec.billable_yn = 'Y'
          THEN
            put_messages_in_table(   G_OKL_STRM_BILL_FLAG_YN
                                    ,p_during_upd_flag
                                    ,l_message
                                    ,p_token1 => 'STREAM'
                                    ,p_value1 => OKL_ACCOUNTING_UTIL.GET_LOOKUP_MEANING( G_OKL_FIN_DEPENDENT_PURPOSES, 'PRINCIPAL_PAYMENT' )
                                    ,p_token2 => 'BILL_YN'
                                    ,p_value2 => OKL_ACCOUNTING_UTIL.GET_LOOKUP_MEANING( 'OKL_YES_NO', 'N' )
                                 );

            x_error_msgs_tbl(l_msgs_count).error_message := l_message;
            x_error_msgs_tbl(l_msgs_count).error_type_code := G_TYPE_ERROR;
            x_error_msgs_tbl(l_msgs_count).error_type_meaning := GET_LOOKUP_MEANING( G_CP_SET_OUTCOME, G_TYPE_ERROR);
            l_msgs_count := l_msgs_count + 1;
          ELSIF get_billable_flag_rec.purpose = 'INTEREST_PAYMENT' AND
                get_billable_flag_rec.billable_yn = 'Y'
          THEN
            put_messages_in_table(   G_OKL_STRM_BILL_FLAG_YN
                                    ,p_during_upd_flag
                                    ,l_message
                                    ,p_token1 => 'STREAM'
                                    ,p_value1 => OKL_ACCOUNTING_UTIL.GET_LOOKUP_MEANING( G_OKL_FIN_DEPENDENT_PURPOSES, 'INTEREST_PAYMENT' )
                                    ,p_token2 => 'BILL_YN'
                                    ,p_value2 => OKL_ACCOUNTING_UTIL.GET_LOOKUP_MEANING( 'OKL_YES_NO', 'N' )
                                 );

            x_error_msgs_tbl(l_msgs_count).error_message := l_message;
            x_error_msgs_tbl(l_msgs_count).error_type_code := G_TYPE_ERROR;
            x_error_msgs_tbl(l_msgs_count).error_type_meaning := GET_LOOKUP_MEANING( G_CP_SET_OUTCOME, G_TYPE_ERROR);
            l_msgs_count := l_msgs_count + 1;
          ELSIF get_billable_flag_rec.purpose = 'LOAN_PAYMENT' AND
                get_billable_flag_rec.billable_yn = 'N'
          THEN
            put_messages_in_table(   G_OKL_STRM_BILL_FLAG_YN
                                    ,p_during_upd_flag
                                    ,l_message
                                    ,p_token1 => 'STREAM'
                                    ,p_value1 => OKL_ACCOUNTING_UTIL.GET_LOOKUP_MEANING( G_OKL_FIN_DEPENDENT_PURPOSES, 'LOAN_PAYMENT' )
                                    ,p_token2 => 'BILL_YN'
                                    ,p_value2 => OKL_ACCOUNTING_UTIL.GET_LOOKUP_MEANING( 'OKL_YES_NO', 'Y' )
                                 );

            x_error_msgs_tbl(l_msgs_count).error_message := l_message;
            x_error_msgs_tbl(l_msgs_count).error_type_code := G_TYPE_ERROR;
            x_error_msgs_tbl(l_msgs_count).error_type_meaning := GET_LOOKUP_MEANING( G_CP_SET_OUTCOME, G_TYPE_ERROR);
            l_msgs_count := l_msgs_count + 1;
          END IF;
        ELSIF l_revenue_recog_meth = 'ACTUAL' AND l_interest_calc_meth = 'FLOAT'
        THEN
          /*Check billable flags*/
          IF  get_billable_flag_rec.purpose = 'PRINCIPAL_PAYMENT' AND
              get_billable_flag_rec.billable_yn = 'Y'
          THEN
            put_messages_in_table(   G_OKL_STRM_BILL_FLAG_YN
                                    ,p_during_upd_flag
                                    ,l_message
                                    ,p_token1 => 'STREAM'
                                    ,p_value1 => OKL_ACCOUNTING_UTIL.GET_LOOKUP_MEANING( G_OKL_FIN_DEPENDENT_PURPOSES, 'PRINCIPAL_PAYMENT' )
                                    ,p_token2 => 'BILL_YN'
                                    ,p_value2 => OKL_ACCOUNTING_UTIL.GET_LOOKUP_MEANING( 'OKL_YES_NO', 'N' )
                                 );
            x_error_msgs_tbl(l_msgs_count).error_message := l_message;
            x_error_msgs_tbl(l_msgs_count).error_type_code := G_TYPE_ERROR;
            x_error_msgs_tbl(l_msgs_count).error_type_meaning := GET_LOOKUP_MEANING( G_CP_SET_OUTCOME, G_TYPE_ERROR);
            l_msgs_count := l_msgs_count + 1;
          ELSIF get_billable_flag_rec.purpose = 'INTEREST_PAYMENT' AND
                get_billable_flag_rec.billable_yn = 'Y'
          THEN
            put_messages_in_table(   G_OKL_STRM_BILL_FLAG_YN
                                    ,p_during_upd_flag
                                    ,l_message
                                    ,p_token1 => 'STREAM'
                                    ,p_value1 => OKL_ACCOUNTING_UTIL.GET_LOOKUP_MEANING( G_OKL_FIN_DEPENDENT_PURPOSES, 'INTEREST_PAYMENT' )
                                    ,p_token2 => 'BILL_YN'
                                    ,p_value2 => OKL_ACCOUNTING_UTIL.GET_LOOKUP_MEANING( 'OKL_YES_NO', 'N' )
                                 );
            x_error_msgs_tbl(l_msgs_count).error_message := l_message;
            x_error_msgs_tbl(l_msgs_count).error_type_code := G_TYPE_ERROR;
            x_error_msgs_tbl(l_msgs_count).error_type_meaning := GET_LOOKUP_MEANING( G_CP_SET_OUTCOME, G_TYPE_ERROR);
            l_msgs_count := l_msgs_count + 1;
          ELSIF get_billable_flag_rec.purpose = 'LOAN_PAYMENT' AND
                get_billable_flag_rec.billable_yn = 'Y'
          THEN
            put_messages_in_table(   G_OKL_STRM_BILL_FLAG_YN
                                    ,p_during_upd_flag
                                    ,l_message
                                    ,p_token1 => 'STREAM'
                                    ,p_value1 => OKL_ACCOUNTING_UTIL.GET_LOOKUP_MEANING( G_OKL_FIN_DEPENDENT_PURPOSES, 'LOAN_PAYMENT' )
                                    ,p_token2 => 'BILL_YN'
                                    ,p_value2 => OKL_ACCOUNTING_UTIL.GET_LOOKUP_MEANING( 'OKL_YES_NO', 'N' )
                                 );
            x_error_msgs_tbl(l_msgs_count).error_message := l_message;
            x_error_msgs_tbl(l_msgs_count).error_type_code := G_TYPE_ERROR;
            x_error_msgs_tbl(l_msgs_count).error_type_meaning := GET_LOOKUP_MEANING( G_CP_SET_OUTCOME, G_TYPE_ERROR);
            l_msgs_count := l_msgs_count + 1;
          END IF;
        ELSIF l_revenue_recog_meth = 'ESTIMATED_AND_BILLED'
        THEN
          /*Check billable flags*/
          IF  get_billable_flag_rec.purpose = 'PRINCIPAL_PAYMENT' AND
              get_billable_flag_rec.billable_yn = 'N'
          THEN
            put_messages_in_table(   G_OKL_STRM_BILL_FLAG_YN
                                    ,p_during_upd_flag
                                    ,l_message
                                    ,p_token1 => 'STREAM'
                                    ,p_value1 => OKL_ACCOUNTING_UTIL.GET_LOOKUP_MEANING( G_OKL_FIN_DEPENDENT_PURPOSES, 'PRINCIPAL_PAYMENT' )
                                    ,p_token2 => 'BILL_YN'
                                    ,p_value2 => OKL_ACCOUNTING_UTIL.GET_LOOKUP_MEANING( 'OKL_YES_NO', 'Y' )
                                 );
            x_error_msgs_tbl(l_msgs_count).error_message := l_message;
            x_error_msgs_tbl(l_msgs_count).error_type_code := G_TYPE_ERROR;
            x_error_msgs_tbl(l_msgs_count).error_type_meaning := GET_LOOKUP_MEANING( G_CP_SET_OUTCOME, G_TYPE_ERROR);
            l_msgs_count := l_msgs_count + 1;
          ELSIF get_billable_flag_rec.purpose = 'INTEREST_PAYMENT'  AND
                get_billable_flag_rec.billable_yn = 'Y'
          THEN
            put_messages_in_table(   G_OKL_STRM_BILL_FLAG_YN
                                    ,p_during_upd_flag
                                    ,l_message
                                    ,p_token1 => 'STREAM'
                                    ,p_value1 => OKL_ACCOUNTING_UTIL.GET_LOOKUP_MEANING( G_OKL_FIN_DEPENDENT_PURPOSES, 'INTEREST_PAYMENT' )
                                    ,p_token2 => 'BILL_YN'
                                    ,p_value2 => OKL_ACCOUNTING_UTIL.GET_LOOKUP_MEANING( 'OKL_YES_NO', 'N' )
                                 );
            x_error_msgs_tbl(l_msgs_count).error_message := l_message;
            x_error_msgs_tbl(l_msgs_count).error_type_code := G_TYPE_ERROR;
            x_error_msgs_tbl(l_msgs_count).error_type_meaning := GET_LOOKUP_MEANING( G_CP_SET_OUTCOME, G_TYPE_ERROR);
            l_msgs_count := l_msgs_count + 1;
          ELSIF get_billable_flag_rec.purpose = 'LOAN_PAYMENT' AND
                get_billable_flag_rec.billable_yn = 'Y'
          THEN
            put_messages_in_table(   G_OKL_STRM_BILL_FLAG_YN
                                    ,p_during_upd_flag
                                    ,l_message
                                    ,p_token1 => 'STREAM'
                                    ,p_value1 => OKL_ACCOUNTING_UTIL.GET_LOOKUP_MEANING( G_OKL_FIN_DEPENDENT_PURPOSES, 'LOAN_PAYMENT' )
                                    ,p_token2 => 'BILL_YN'
                                    ,p_value2 => OKL_ACCOUNTING_UTIL.GET_LOOKUP_MEANING( 'OKL_YES_NO', 'N' )
                                 );
            x_error_msgs_tbl(l_msgs_count).error_message := l_message;
            x_error_msgs_tbl(l_msgs_count).error_type_code := G_TYPE_ERROR;
            x_error_msgs_tbl(l_msgs_count).error_type_meaning := GET_LOOKUP_MEANING( G_CP_SET_OUTCOME, G_TYPE_ERROR);
            l_msgs_count := l_msgs_count + 1;
          END IF;
        END IF;
      END LOOP;
    ELSIF belongs_to_ls(p_book_classification) AND
          l_interest_calc_meth <> 'FIXED_UPGRADE'  -- VR Upgrade. Bug 4756154
    THEN
      --Rule 4. For Lease classification, Rent stream must be billable and
      --RR only can be Streams and IC can only be Reamort and Float Factor
      /* Rent stream must be billable*/
      OPEN get_rent_flag;
      FETCH get_rent_flag INTO l_purpose,l_billable_yn;
      CLOSE get_rent_flag;

      IF l_billable_yn = 'N'
      THEN
        put_messages_in_table( G_OKL_STRM_BILL_FLAG_YN
                                 ,p_during_upd_flag
                                 ,l_message
                                 ,p_token1 => 'STREAM'
                                 ,p_value1 => OKL_ACCOUNTING_UTIL.GET_LOOKUP_MEANING( G_OKL_FIN_PRIMARY_PURPOSES, 'RENT' )
                                 ,p_token2 => 'BILL_YN'
                                 ,p_value2 => OKL_ACCOUNTING_UTIL.GET_LOOKUP_MEANING( 'OKL_YES_NO', 'Y' )
                                 );
        x_error_msgs_tbl(l_msgs_count).error_message := l_message;
        x_error_msgs_tbl(l_msgs_count).error_type_code := G_TYPE_ERROR;
        x_error_msgs_tbl(l_msgs_count).error_type_meaning := GET_LOOKUP_MEANING( G_CP_SET_OUTCOME, G_TYPE_ERROR);
        l_msgs_count := l_msgs_count + 1;
      END IF;
      /*RR only can be Streams and IC can only be Reamort and Float Factor*/
      IF NVL(l_revenue_recog_meth,'*') <> 'STREAMS' OR
        (NVL(l_interest_calc_meth,'*') <> 'REAMORT' AND
         NVL(l_interest_calc_meth,'*') <> 'FIXED'   AND
         NVL(l_interest_calc_meth,'*') <> 'FLOAT_FACTORS' )
      THEN
        put_messages_in_table(   G_OKL_IC_RR_METH_FOR_LS
                                    ,p_during_upd_flag
                                    ,l_message
                                 );
        x_error_msgs_tbl(l_msgs_count).error_message := l_message;
        x_error_msgs_tbl(l_msgs_count).error_type_code := G_TYPE_ERROR;
        x_error_msgs_tbl(l_msgs_count).error_type_meaning := GET_LOOKUP_MEANING( G_CP_SET_OUTCOME, G_TYPE_ERROR);
        l_msgs_count := l_msgs_count + 1;
      END IF;
    END IF;

  END val_ic_rr_day_con_methods;
  ---------------------------------------------------------------------------
  -- PROCEDURE validate_financial_template
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : validate_financial_template
  -- Description     : Validates a Stream Generation Template with Financial
  --                   as Product Type
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------

Procedure validate_financial_template(
                    p_api_version             IN  NUMBER
                    ,p_init_msg_list           IN  VARCHAR2 DEFAULT Okc_Api.G_FALSE
                    ,x_return_status           OUT NOCOPY VARCHAR2
                    ,x_msg_count               OUT NOCOPY NUMBER
                    ,x_msg_data                OUT NOCOPY VARCHAR2
		            ,p_gtt_id                  IN  okl_st_gen_templates.id%type
		            ,x_error_msgs_tbl          OUT NOCOPY error_msgs_tbl_type
		            ,p_during_upd_flag         IN VARCHAR
		            ,p_book_classification     IN VARCHAR

      )IS
   l_gtt_id                   okl_st_gen_templates.id%type := p_gtt_id;
    l_api_name                CONSTANT VARCHAR2(40) := 'validate_financial_template';
    l_api_version             CONSTANT NUMBER       := 1.0;
    l_return_status           VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_error_msgs_tbl          error_msgs_tbl_type;
    l_error_msgs_tbl_val_bill error_msgs_tbl_type;
    l_msgs_count              NUMBER := 1;

    l_init_msg_list     VARCHAR2(1);
    l_msg_count         NUMBER;
    l_msg_data          VARCHAR2(2000);
    l_dummy VARCHAR2(1) := okl_api.G_FALSE;
    l_ins_strms_count NUMBER := 0;

    l_gttv_rec_in   gttv_rec_type;
    l_gttv_rec_out  gttv_rec_type;

    l_message VARCHAR2(2700);


    -- 1. If user selects one of the following Insurance purposes then all the
    -- insurance stream purposes must be defined.
    CURSOR okl_ins_purposes_csr( p_gtt_id IN OKL_ST_GEN_TEMPLATES.id%type) IS
    SELECT count(*) ins_strms_count
    FROM OKL_ST_GEN_TMPT_LNS  gtl
       , okl_strm_type_b stb
    WHERE gtl.primary_sty_id = stb.id
    AND GTL.GTT_ID = p_gtt_id
    AND GTL.primary_yn = 'Y'
    AND stb.stream_type_purpose IN
    (
         'INSURANCE_RECEIVABLE'
         -- Modified by RGOOTY
         -- Bug 4096853: Start
        ,'INSURANCE_ADJUSTMENT'
        -- Bug 4096853: End
        ,'INSURANCE_PAYABLE'
        ,'INSURANCE_ACCRUAL_ADJUSTMENT'
        ,'INSURANCE_EXPENSE_ACCRUAL'
        ,'INSURANCE_INCOME_ACCRUAL'
        ,'INSURANCE_REFUND'
    );

    -- 2.	Only one stream type of the following primary purposes should be defined.
    -- The List contains Purposes for all Book Classifications.
    -- The sql statement checkes whether the purposes mentioned in the set are repeated
    -- or not. So, If they are not defined then that doesnot violoate the logic of the
    -- SQL statement.
    CURSOR fin_only_one_as_primary_csr( p_gtt_id IN OKL_ST_GEN_TEMPLATES.id%type) IS
    SELECT stb.stream_type_purpose purpose, count(stb.stream_type_purpose)
    FROM    OKL_ST_GEN_TMPT_LNS  gtl
           ,okl_strm_type_b stb
    WHERE gtl.primary_sty_id = stb.id
    AND   gtl.primary_yn = 'Y'
    AND stb.stream_type_purpose IN
    (
         'ACTUAL_PROPERTY_TAX'
        ,'REBOOK_BILLING_ADJUSTMENT'
        ,'CURE'
        ,'INSURANCE_ACCRUAL_ADJUSTMENT'
        ,'INSURANCE_ADJUSTMENT'
        ,'INSURANCE_EXPENSE_ACCRUAL'
        ,'INSURANCE_INCOME_ACCRUAL'
        ,'INSURANCE_PAYABLE'
        ,'INSURANCE_RECEIVABLE'
        ,'INSURANCE_REFUND'
        ,'LATE_FEE'
        ,'LATE_INTEREST'
        ,'PREFUNDING_INTEREST_PAYMENT'
        ,'REPAIR_CHARGE'
        ,'USAGE_PAYMENT'
        ,'SERVICE_FEE_AMORT_SCHEDULE'
        ,'SERVICE_FEE_AUDIT_LETTER'
        ,'SERVICE_FEE_VAT_SCHEDULE'
        ,'SERVICE_FEE_VAR_RATE_STMNT'
        ,'SERVICE_FEE_INVOICE_REPRINT'
        ,'SERVICE_FEE_INVOICE_DEMAND'
        ,'SERVICE_FEE_REST_REQUEST'
        ,'SERVICE_FEE_TERM_REQUEST'
        ,'SERVICE_FEE_EXCHG_REQUEST'
        ,'SERVICE_FEE_TRANS_REQUEST'
        ,'SERVICE_FEE_PMT_CHANGE'
        ,'SERVICE_FEE_INTEREST_CONV'
        ,'SERVICE_FEE_GENERAL'
        ,'SERVICE_FEE_DOCUMENT_REQ'
        ,'AMBSPR'
        ,'AMAFEE'
        ,'AMBCOC'
        ,'AMYFEE'
        ,'AMCQDR'
        ,'AMPRTX'
        ,'AMEFEE'
        ,'AMFFEE'
        ,'AMGFEE'
        ,'AMIFEE'
        ,'AMCMIS'
        ,'AMMFEE'
        ,'AMPFEE'
        ,'AMCTOC'
        ,'AMBPOC'
        ,'AMCQFE'
        ,'AMCRFE'
        ,'AMCRIN'
        ,'AMYSAM'
        ,'AMCTPE'
        ,'AMCTUR'
        --bug 4176696 fixed by smahapat
        --,'BILL_ADJST'
        ,'VARIABLE_INTEREST'
        ,'BOOK_DEPRECIATION'
        ,'FEDERAL_DEPRECIATION'
        ,'INVESTOR_PRETAX_INCOME'
        ,'INVESTOR_RENTAL_ACCRUAL'
        ,'RESIDUAL_VALUE'
        ,'STATE_DEPRECIATION'
        ,'VARIABLE_INTEREST_SCHEDULE'
        -- Modified by RGOOTY
        -- Bug 4050701: Start
        ,'SERVICE_EXPENSE'
        -- Bug 4050701: End
        -- Bug 4062730: Start
        ,'RENT'
        -- Bug 4062730: End
        -- Bug 4110239: Start
        ,'GENERAL_LOSS_PROVISION'
        -- Bug 4110239: End
        ,'VENDOR_RESIDUAL_SHARING'
        --Bug 4616460 added new stream type purpose
        ,'ASSET_SALE_RECEIVABLE'
        --Bug 4616460 end
        -- Bug 5730462: Add a new purpose for EB Tax R12 IA
        ,'UPFRONT_TAX_FINANCED'
        ,'UPFRONT_TAX_CAPITALIZED'
        -- Bug 5730462 End
        , 'UPFRONT_TAX_BILLED'  -- bug6619311
    )
    AND GTL.GTT_ID = p_gtt_id
    group by stb.stream_type_purpose
    having count(stb.stream_type_purpose) > 1;

    -- 3.	All of the following primary purposes must be defined
    CURSOR fin_mandatory_pri_all_csr( p_gtt_id IN OKL_ST_GEN_TEMPLATES.id%type) IS
    SELECT LOOKUP_CODE PURPOSE
    FROM   FND_LOOKUPS
    WHERE LOOKUP_TYPE = 'OKL_STREAM_TYPE_PURPOSE'
    AND LOOKUP_CODE IN
    (
        'CURE'
        ,'FUNDING'
        ,'LATE_FEE'
        ,'LATE_INTEREST'
        ,'PREFUNDING_INTEREST_PAYMENT'
        ,'RENT'
        ,'REPAIR_CHARGE'
        ,'SERVICE_FEE_AMORT_SCHEDULE'
        ,'SERVICE_FEE_AUDIT_LETTER'
        ,'SERVICE_FEE_VAT_SCHEDULE'
        ,'SERVICE_FEE_VAR_RATE_STMNT'
        ,'SERVICE_FEE_INVOICE_REPRINT'
        ,'SERVICE_FEE_INVOICE_DEMAND'
        ,'SERVICE_FEE_REST_REQUEST'
        ,'SERVICE_FEE_TERM_REQUEST'
        ,'SERVICE_FEE_EXCHG_REQUEST'
        ,'SERVICE_FEE_TRANS_REQUEST'
        ,'SERVICE_FEE_PMT_CHANGE'
        ,'SERVICE_FEE_INTEREST_CONV'
        ,'SERVICE_FEE_GENERAL'
        ,'SERVICE_FEE_DOCUMENT_REQ'
        ,'QUOTE_PER_DIEM'
        ,'REBOOK_BILLING_ADJUSTMENT' -- VR Upgrade.
    )
    MINUS
    SELECT distinct stb.stream_type_purpose purpose
    FROM OKL_ST_GEN_TMPT_LNS  gtl
           , okl_strm_type_b stb
    WHERE gtl.primary_sty_id = stb.id
    AND   gtl.primary_yn = 'Y'
    AND stb.stream_type_purpose IN
    (
        'CURE'
        ,'FUNDING'
        ,'LATE_FEE'
        ,'LATE_INTEREST'
        ,'PREFUNDING_INTEREST_PAYMENT'
        ,'RENT'
        ,'REPAIR_CHARGE'
        ,'SERVICE_FEE_AMORT_SCHEDULE'
        ,'SERVICE_FEE_AUDIT_LETTER'
        ,'SERVICE_FEE_VAT_SCHEDULE'
        ,'SERVICE_FEE_VAR_RATE_STMNT'
        ,'SERVICE_FEE_INVOICE_REPRINT'
        ,'SERVICE_FEE_INVOICE_DEMAND'
        ,'SERVICE_FEE_REST_REQUEST'
        ,'SERVICE_FEE_TERM_REQUEST'
        ,'SERVICE_FEE_EXCHG_REQUEST'
        ,'SERVICE_FEE_TRANS_REQUEST'
        ,'SERVICE_FEE_PMT_CHANGE'
        ,'SERVICE_FEE_INTEREST_CONV'
        ,'SERVICE_FEE_GENERAL'
        ,'SERVICE_FEE_DOCUMENT_REQ'
        ,'QUOTE_PER_DIEM'
        ,'REBOOK_BILLING_ADJUSTMENT' -- VR Upgrade.
    )
    and GTL.GTT_ID = p_gtt_id;

    CURSOR fin_mandatory_pri_ln_csr( p_gtt_id IN OKL_ST_GEN_TEMPLATES.id%type) IS
    SELECT LOOKUP_CODE PURPOSE
    FROM   FND_LOOKUPS
    WHERE LOOKUP_TYPE = 'OKL_STREAM_TYPE_PURPOSE'
    AND LOOKUP_CODE IN
    (
         'VARIABLE_INTEREST'
    )
    MINUS
    SELECT distinct stb.stream_type_purpose purpose
    FROM OKL_ST_GEN_TMPT_LNS  gtl
           , okl_strm_type_b stb
    WHERE gtl.primary_sty_id = stb.id
    AND   gtl.primary_yn = 'Y'
    AND stb.stream_type_purpose IN
    (
         'VARIABLE_INTEREST'
    )
    and GTL.GTT_ID = p_gtt_id;

    CURSOR fin_mandatory_pri_ls_csr( p_gtt_id IN OKL_ST_GEN_TEMPLATES.id%type) IS
    SELECT LOOKUP_CODE PURPOSE
    FROM   FND_LOOKUPS
    WHERE LOOKUP_TYPE = 'OKL_STREAM_TYPE_PURPOSE'
    AND LOOKUP_CODE IN
    (
        'RESIDUAL_VALUE'
    )
    MINUS
    SELECT distinct stb.stream_type_purpose purpose
    FROM OKL_ST_GEN_TMPT_LNS  gtl
           , okl_strm_type_b stb
    WHERE gtl.primary_sty_id = stb.id
    AND   gtl.primary_yn = 'Y'
    AND stb.stream_type_purpose IN
    (
        'RESIDUAL_VALUE'
    )
    and GTL.GTT_ID = p_gtt_id;

   --Bug 5139013 dpsingh start
   CURSOR fin_mandatory_pri_ic_float_csr( p_gtt_id IN OKL_ST_GEN_TEMPLATES.id%type) IS
   SELECT LOOKUP_CODE PURPOSE
    FROM   FND_LOOKUPS
    WHERE LOOKUP_TYPE = 'OKL_STREAM_TYPE_PURPOSE'
    AND LOOKUP_CODE ='VARIABLE_INTEREST_SCHEDULE'
    MINUS
    SELECT distinct stb.stream_type_purpose purpose
    FROM OKL_ST_GEN_TMPT_LNS  gtl
           , okl_strm_type_b stb
    WHERE gtl.primary_sty_id = stb.id
    AND   gtl.primary_yn = 'Y'
    AND stb.stream_type_purpose ='VARIABLE_INTEREST_SCHEDULE'
    and GTL.GTT_ID = p_gtt_id;
    --Bug 5139013 dpsingh end

    -- Modified by RGOOTY
    -- Bug 4111081: Start
    CURSOR fin_mandatory_pri_op_csr( p_gtt_id IN OKL_ST_GEN_TEMPLATES.id%type) IS
    SELECT LOOKUP_CODE PURPOSE
    FROM   FND_LOOKUPS
    WHERE LOOKUP_TYPE = 'OKL_STREAM_TYPE_PURPOSE'
    AND LOOKUP_CODE IN
    (
        'INVESTOR_RENTAL_ACCRUAL'
    )
    MINUS
    SELECT distinct stb.stream_type_purpose purpose
    FROM OKL_ST_GEN_TMPT_LNS  gtl
           , okl_strm_type_b stb
    WHERE gtl.primary_sty_id = stb.id
    AND   gtl.primary_yn = 'Y'
    AND stb.stream_type_purpose IN
    (
        'INVESTOR_RENTAL_ACCRUAL'
    )
    and GTL.GTT_ID = p_gtt_id;

    CURSOR fin_mandatory_pri_df_n_st_csr( p_gtt_id IN OKL_ST_GEN_TEMPLATES.id%type) IS
    SELECT LOOKUP_CODE PURPOSE
    FROM   FND_LOOKUPS
    WHERE LOOKUP_TYPE = 'OKL_STREAM_TYPE_PURPOSE'
    AND LOOKUP_CODE IN
    (
        'INVESTOR_PRETAX_INCOME'
    )
    MINUS
    SELECT distinct stb.stream_type_purpose purpose
    FROM OKL_ST_GEN_TMPT_LNS  gtl
           , okl_strm_type_b stb
    WHERE gtl.primary_sty_id = stb.id
    AND   gtl.primary_yn = 'Y'
    AND stb.stream_type_purpose IN
    (
        'INVESTOR_PRETAX_INCOME'
    )
    and GTL.GTT_ID = p_gtt_id;
    -- Bug 4111081: End

    -- Modified by RGOOTY
    -- Bug 4129154: Start

    -- 4.	Mandatory Dependent Streams
    CURSOR man_dep_all_rent_csr( p_gtt_id IN OKL_ST_GEN_TEMPLATES.id%type) IS
    SELECT LOOKUP_CODE PURPOSE
    FROM   FND_LOOKUPS
    WHERE LOOKUP_TYPE = 'OKL_STREAM_TYPE_PURPOSE'
    AND LOOKUP_CODE IN
    (
        'ADVANCE_RENT'
    )
    MINUS
    SELECT distinct stb.stream_type_purpose purpose
    FROM OKL_ST_GEN_TMPT_LNS  gtl
       , okl_strm_type_b stb
       , okl_strm_type_b sstb
    WHERE gtl.dependent_sty_id = stb.id
    AND   gtl.primary_yn = 'N'
    AND stb.stream_type_purpose IN
    (
        'ADVANCE_RENT'
    )
    and GTL.GTT_ID = p_gtt_id
    and sstb.id = gtl.primary_sty_id
    and sstb.stream_Type_purpose IN
    (
        'RENT'
    )
    AND EXISTS
    (
        SELECT 1
        FROM OKL_ST_GEN_TMPT_LNS gtlpri
        WHERE primary_yn = 'Y'
         AND  gtlpri.gtt_id = p_gtt_id
         AND  gtlpri.primary_sty_id = gtl.primary_sty_id
    );

    CURSOR man_dep_ln_rent_csr( p_gtt_id IN OKL_ST_GEN_TEMPLATES.id%type) IS
    SELECT LOOKUP_CODE PURPOSE
    FROM   FND_LOOKUPS
    WHERE LOOKUP_TYPE = 'OKL_STREAM_TYPE_PURPOSE'
    AND LOOKUP_CODE IN
    (
         'INTEREST_INCOME'
        ,'INTEREST_PAYMENT'
        ,'LOAN_PAYMENT'
        ,'PRINCIPAL_BALANCE'
	,'PRINCIPAL_CATCHUP'
        ,'PRINCIPAL_PAYMENT'
        ,'UNSCHEDULED_PRINCIPAL_PAYMENT'
    )
    MINUS
    SELECT distinct stb.stream_type_purpose purpose
    FROM OKL_ST_GEN_TMPT_LNS  gtl
       , okl_strm_type_b stb
       , okl_strm_type_b sstb
    WHERE gtl.dependent_sty_id = stb.id
    AND   gtl.primary_yn = 'N'
    AND stb.stream_type_purpose IN
    (
        'INTEREST_INCOME'
        ,'INTEREST_PAYMENT'
        ,'LOAN_PAYMENT'
        ,'PRINCIPAL_BALANCE'
	,'PRINCIPAL_CATCHUP'
        ,'PRINCIPAL_PAYMENT'
        ,'UNSCHEDULED_PRINCIPAL_PAYMENT'
    )
    and GTL.GTT_ID = p_gtt_id
    and sstb.id = gtl.primary_sty_id
    and sstb.stream_Type_purpose IN
    (
        'RENT'
    )
    AND EXISTS
    (
        SELECT 1
        FROM OKL_ST_GEN_TMPT_LNS gtlpri
        WHERE primary_yn = 'Y'
         AND  gtlpri.gtt_id = p_gtt_id
         AND  gtlpri.primary_sty_id = gtl.primary_sty_id
    );

    CURSOR man_dep_ln_vrs_rent_csr( p_gtt_id IN OKL_ST_GEN_TEMPLATES.id%type) IS
    SELECT LOOKUP_CODE PURPOSE
    FROM   FND_LOOKUPS
    WHERE LOOKUP_TYPE = 'OKL_STREAM_TYPE_PURPOSE'
    AND LOOKUP_CODE IN
    (
      'DAILY_INTEREST_PRINCIPAL'
     ,'DAILY_INTEREST_INTEREST'
     ,'UNSCHEDULED_LOAN_PAYMENT'
     ,'VARIABLE_LOAN_PAYMENT'
     ,'EXCESS_PRINCIPAL_PAID'
     ,'EXCESS_INTEREST_PAID'
     ,'EXCESS_LOAN_PAYMENT_PAID'
     ,'ACTUAL_INCOME_ACCRUAL'
    )
    MINUS
    SELECT distinct stb.stream_type_purpose purpose
    FROM OKL_ST_GEN_TMPT_LNS  gtl
       , okl_strm_type_b stb
       , okl_strm_type_b ptb
    WHERE gtl.dependent_sty_id = stb.id
    AND   gtl.primary_yn = 'N'
    AND stb.stream_type_purpose IN
    (
      'DAILY_INTEREST_PRINCIPAL'
     ,'DAILY_INTEREST_INTEREST'
     ,'UNSCHEDULED_LOAN_PAYMENT'
     ,'VARIABLE_LOAN_PAYMENT'
     ,'EXCESS_PRINCIPAL_PAID'
     ,'EXCESS_INTEREST_PAID'
     ,'EXCESS_LOAN_PAYMENT_PAID'
     ,'ACTUAL_INCOME_ACCRUAL'
    )
    and GTL.GTT_ID = p_gtt_id
    and ptb.id = gtl.primary_sty_id
    and ptb.stream_Type_purpose IN
    (
        'RENT'
    )
    AND EXISTS
    (
        SELECT 1
        FROM OKL_ST_GEN_TMPT_LNS gtlpri
        WHERE primary_yn = 'Y'
         AND  gtlpri.gtt_id = p_gtt_id
         AND  gtlpri.primary_sty_id = gtl.primary_sty_id
    );

    CURSOR man_dep_dfstop_vrs_rent_csr( p_gtt_id IN OKL_ST_GEN_TEMPLATES.id%type) IS
    SELECT LOOKUP_CODE PURPOSE
    FROM   FND_LOOKUPS
    WHERE LOOKUP_TYPE = 'OKL_STREAM_TYPE_PURPOSE'
    AND LOOKUP_CODE IN
    (
      'FLOAT_FACTOR_ADJUSTMENT'
    )
    MINUS
    SELECT distinct stb.stream_type_purpose purpose
    FROM OKL_ST_GEN_TMPT_LNS  gtl
       , okl_strm_type_b stb
       , okl_strm_type_b ptb
    WHERE gtl.dependent_sty_id = stb.id
    AND   gtl.primary_yn = 'N'
    AND stb.stream_type_purpose IN
    (
      'FLOAT_FACTOR_ADJUSTMENT'
    )
    and GTL.GTT_ID = p_gtt_id
    and ptb.id = gtl.primary_sty_id
    and ptb.stream_Type_purpose IN
    (
        'RENT'
    )
    AND EXISTS
    (
        SELECT 1
        FROM OKL_ST_GEN_TMPT_LNS gtlpri
        WHERE primary_yn = 'Y'
         AND  gtlpri.gtt_id = p_gtt_id
         AND  gtlpri.primary_sty_id = gtl.primary_sty_id
    );

    CURSOR man_dep_ln_icc_vrs_rent_csr( p_gtt_id IN OKL_ST_GEN_TEMPLATES.id%type) IS
    SELECT LOOKUP_CODE PURPOSE
    FROM   FND_LOOKUPS
    WHERE LOOKUP_TYPE = 'OKL_STREAM_TYPE_PURPOSE'
    AND LOOKUP_CODE IN
    (
      'INTEREST_CATCHUP'
    )
    MINUS
    SELECT distinct stb.stream_type_purpose purpose
    FROM OKL_ST_GEN_TMPT_LNS  gtl
       , okl_strm_type_b stb
       , okl_strm_type_b ptb
    WHERE gtl.dependent_sty_id = stb.id
    AND   gtl.primary_yn = 'N'
    AND stb.stream_type_purpose IN
    (
      'INTEREST_CATCHUP'
    )
    and GTL.GTT_ID = p_gtt_id
    and ptb.id = gtl.primary_sty_id
    and ptb.stream_Type_purpose IN
    (
        'RENT'
    )
    AND EXISTS
    (
        SELECT 1
        FROM OKL_ST_GEN_TMPT_LNS gtlpri
        WHERE primary_yn = 'Y'
         AND  gtlpri.gtt_id = p_gtt_id
         AND  gtlpri.primary_sty_id = gtl.primary_sty_id
    );

    -- rgooty BUG#4290143 start
    CURSOR man_dep_ln_var_int_csr( p_gtt_id IN OKL_ST_GEN_TEMPLATES.id%type) IS
    SELECT LOOKUP_CODE PURPOSE
    FROM   FND_LOOKUPS
    WHERE LOOKUP_TYPE = 'OKL_STREAM_TYPE_PURPOSE'
    AND LOOKUP_CODE =  'VARIABLE_INTEREST_INCOME'
    MINUS
    SELECT distinct stb.stream_type_purpose purpose
    FROM OKL_ST_GEN_TMPT_LNS  gtl
       , okl_strm_type_b stb
       , okl_strm_type_b sstb
    WHERE gtl.dependent_sty_id = stb.id
    AND   gtl.primary_yn = 'N'
    AND stb.stream_type_purpose = 'VARIABLE_INTEREST_INCOME'
    and GTL.GTT_ID = p_gtt_id
    and sstb.id = gtl.primary_sty_id
    and sstb.stream_Type_purpose IN
    (
        'VARIABLE_INTEREST'
    )
    AND EXISTS
    (
        SELECT 1
        FROM OKL_ST_GEN_TMPT_LNS gtlpri
        WHERE primary_yn = 'Y'
         AND  gtlpri.gtt_id = p_gtt_id
         AND  gtlpri.primary_sty_id = gtl.primary_sty_id
    );
    -- rgooty BUG#4290143 end

    CURSOR man_dep_df_st_rent_csr( p_gtt_id IN OKL_ST_GEN_TEMPLATES.id%type) IS
    SELECT LOOKUP_CODE PURPOSE
    FROM   FND_LOOKUPS
    WHERE LOOKUP_TYPE = 'OKL_STREAM_TYPE_PURPOSE'
    AND LOOKUP_CODE IN
    (
        'LEASE_INCOME'
    )
    MINUS
    SELECT distinct stb.stream_type_purpose purpose
    FROM OKL_ST_GEN_TMPT_LNS  gtl
       , okl_strm_type_b stb
       , okl_strm_type_b sstb
    WHERE gtl.dependent_sty_id = stb.id
    AND   gtl.primary_yn = 'N'
    AND stb.stream_type_purpose IN
    (
        'LEASE_INCOME'
    )
    and GTL.GTT_ID = p_gtt_id
    and sstb.id = gtl.primary_sty_id
    and sstb.stream_Type_purpose IN
    (
        'RENT'
    )
    AND EXISTS
    (
        SELECT 1
        FROM OKL_ST_GEN_TMPT_LNS gtlpri
        WHERE primary_yn = 'Y'
         AND  gtlpri.gtt_id = p_gtt_id
         AND  gtlpri.primary_sty_id = gtl.primary_sty_id
    );

    CURSOR man_dep_ls_rent_csr( p_gtt_id IN OKL_ST_GEN_TEMPLATES.id%type) IS
    SELECT LOOKUP_CODE PURPOSE
    FROM   FND_LOOKUPS
    WHERE LOOKUP_TYPE = 'OKL_STREAM_TYPE_PURPOSE'
    AND LOOKUP_CODE IN
    (
         'PASS_THROUGH_EVERGREEN_RENT'
        ,'PV_RENT'
        ,'RENEWAL_RENT'
    )
    MINUS
    SELECT distinct stb.stream_type_purpose purpose
    FROM OKL_ST_GEN_TMPT_LNS  gtl
       , okl_strm_type_b stb
       , okl_strm_type_b sstb
    WHERE gtl.dependent_sty_id = stb.id
    AND   gtl.primary_yn = 'N'
    AND stb.stream_type_purpose IN
    (
         'PASS_THROUGH_EVERGREEN_RENT'
        ,'PV_RENT'
        ,'RENEWAL_RENT'
    )
    and GTL.GTT_ID = p_gtt_id
    and sstb.id = gtl.primary_sty_id
    and sstb.stream_Type_purpose IN
    (
        'RENT'
    )
    AND EXISTS
    (
        SELECT 1
        FROM OKL_ST_GEN_TMPT_LNS gtlpri
        WHERE primary_yn = 'Y'
         AND  gtlpri.gtt_id = p_gtt_id
         AND  gtlpri.primary_sty_id = gtl.primary_sty_id
    );

    CURSOR man_dep_ls_rv_csr( p_gtt_id IN OKL_ST_GEN_TEMPLATES.id%type) IS
    SELECT LOOKUP_CODE PURPOSE
    FROM   FND_LOOKUPS
    WHERE LOOKUP_TYPE = 'OKL_STREAM_TYPE_PURPOSE'
    AND LOOKUP_CODE IN
    (
        'PV_RV'
        ,'PV_RV_GUARANTEED'
        ,'PV_RV_INSURED'
        ,'PV_RV_UNGUARANTEED'
        ,'PV_RV_UNINSURED'
        ,'RESIDUAL_GUARANTEED'
        ,'RV_INSURANCE_PREMIUM'
    )
    MINUS
    SELECT distinct stb.stream_type_purpose purpose
    FROM OKL_ST_GEN_TMPT_LNS  gtl
       , okl_strm_type_b stb
       , okl_strm_type_b sstb
    WHERE gtl.dependent_sty_id = stb.id
    AND   gtl.primary_yn = 'N'
    AND stb.stream_type_purpose IN
    (
        'PV_RV'
        ,'PV_RV_GUARANTEED'
        ,'PV_RV_INSURED'
        ,'PV_RV_UNGUARANTEED'
        ,'PV_RV_UNINSURED'
        ,'RESIDUAL_GUARANTEED'
        ,'RV_INSURANCE_PREMIUM'
    )
    and GTL.GTT_ID = p_gtt_id
    and sstb.id = gtl.primary_sty_id
    and sstb.stream_Type_purpose IN
    (
        'RESIDUAL_VALUE'
    )
    AND EXISTS
    (
        SELECT 1
        FROM OKL_ST_GEN_TMPT_LNS gtlpri
        WHERE primary_yn = 'Y'
         AND  gtlpri.gtt_id = p_gtt_id
         AND  gtlpri.primary_sty_id = gtl.primary_sty_id
    );

    CURSOR man_dep_op_rent_csr( p_gtt_id IN OKL_ST_GEN_TEMPLATES.id%type) IS
    SELECT LOOKUP_CODE PURPOSE
    FROM   FND_LOOKUPS
    WHERE LOOKUP_TYPE = 'OKL_STREAM_TYPE_PURPOSE'
    AND LOOKUP_CODE IN
    (
        'RENT_ACCRUAL'
    )
    MINUS
    SELECT distinct stb.stream_type_purpose purpose
    FROM OKL_ST_GEN_TMPT_LNS  gtl
       , okl_strm_type_b stb
       , okl_strm_type_b sstb
    WHERE gtl.dependent_sty_id = stb.id
    AND   gtl.primary_yn = 'N'
    AND stb.stream_type_purpose IN
    (
        'RENT_ACCRUAL'
    )
    and GTL.GTT_ID = p_gtt_id
    and sstb.id = gtl.primary_sty_id
    and sstb.stream_Type_purpose IN
    (
        'RENT'
    )
    AND EXISTS
    (
        SELECT 1
        FROM OKL_ST_GEN_TMPT_LNS gtlpri
        WHERE primary_yn = 'Y'
         AND  gtlpri.gtt_id = p_gtt_id
         AND  gtlpri.primary_sty_id = gtl.primary_sty_id
    );
    -- Bug 4129154: End

    -- Rule 6. Certain Book classifications can have certain Purposes only.
    CURSOR purposes_for_df_and_st_csr( p_gtt_id IN OKL_ST_GEN_TEMPLATES.id%type) IS
    (
        -- Retrieve the List of Primary Stream Purposes in the Template
        SELECT distinct stb.stream_type_purpose purpose
        FROM OKL_ST_GEN_TMPT_LNS  gtl
               , okl_strm_type_b stb
        WHERE gtl.primary_sty_id = stb.id
        AND   gtl.primary_yn = 'Y'
        AND GTL.GTT_ID = p_gtt_id
        UNION
        -- Retrieve the List of Dependent Stream Purposes in the Template
        SELECT distinct stb.stream_type_purpose purpose
        FROM OKL_ST_GEN_TMPT_LNS  gtl
               , okl_strm_type_b stb
        WHERE gtl.dependent_sty_id = stb.id
        AND   gtl.primary_yn = 'N'
        and GTL.GTT_ID = p_gtt_id
    )
    MINUS
    SELECT LOOKUP_CODE
    FROM   FND_LOOKUPS
    WHERE  LOOKUP_TYPE = 'OKL_STREAM_TYPE_PURPOSE'
    AND LOOKUP_CODE in
    (
         'ACCOUNTING'
        ,'ACCRUED_FEE_EXPENSE'
        ,'ACCRUED_FEE_INCOME'
        ,'ACTUAL_PROPERTY_TAX'
        ,'ADJUSTED_PROPERTY_TAX'
        ,'ADVANCE_RENT'
        ,'AMORTIZED_FEE_EXPENSE'
        ,'AMORTIZE_FEE_INCOME'
        ,'REBOOK_BILLING_ADJUSTMENT'
        ,'CURE'
        ,'ESTIMATED_PROPERTY_TAX'
        ,'EXPENSE'
        ,'FEE_PAYMENT'
        ,'FUNDING'
        ,'INSURANCE_ACCRUAL_ADJUSTMENT'
        ,'INSURANCE_ADJUSTMENT'
        ,'INSURANCE_EXPENSE_ACCRUAL'
        ,'INSURANCE_INCOME_ACCRUAL'
        ,'INSURANCE_PAYABLE'
        ,'INSURANCE_RECEIVABLE'
        ,'INSURANCE_REFUND'
        ,'LATE_FEE'
        ,'LATE_INTEREST'
        ,'PASS_THRU_EXP_ACCRUAL'
        ,'PASS_THROUGH_FEE'
        ,'PASS_THRU_REV_ACCRUAL'
        ,'PASS_THROUGH_SERVICE'
        ,'PASS_THRU_SVC_EXP_ACCRUAL'
        ,'PASS_THRU_SVC_REV_ACCRUAL'
        ,'PREFUNDING_INTEREST_PAYMENT'
        -- Bug 4110239: Start
        --,'PROVISION'
        ,'SPECIFIC_LOSS_PROVISION'
        ,'GENERAL_LOSS_PROVISION'
        -- Bug 4110239: End
        ,'RENT'
        ,'GENERAL'
        ,'REPAIR_CHARGE'
        ,'SECURITY_DEPOSIT'
        ,'SERVICE_EXPENSE'
        ,'SERVICE_INCOME'
        ,'SERVICE_PAYMENT'
        ,'SERVICE_RENEWAL'
        ,'SUBSIDY'
        ,'SUBSIDY_INCOME'
        ,'USAGE_PAYMENT'
        ,'SERVICE_FEE_AMORT_SCHEDULE'
        ,'SERVICE_FEE_AUDIT_LETTER'
        ,'SERVICE_FEE_VAT_SCHEDULE'
        ,'SERVICE_FEE_VAR_RATE_STMNT'
        ,'SERVICE_FEE_INVOICE_REPRINT'
        ,'SERVICE_FEE_INVOICE_DEMAND'
        ,'SERVICE_FEE_REST_REQUEST'
        ,'SERVICE_FEE_TERM_REQUEST'
        ,'SERVICE_FEE_EXCHG_REQUEST'
        ,'SERVICE_FEE_TRANS_REQUEST'
        ,'SERVICE_FEE_PMT_CHANGE'
        ,'SERVICE_FEE_INTEREST_CONV'
        ,'SERVICE_FEE_GENERAL'
        ,'SERVICE_FEE_DOCUMENT_REQ'
        ,'AMBSPR'
        ,'AMAFEE'
        ,'AMBCOC'
        ,'AMYFEE'
        ,'AMCQDR'
        ,'AMPRTX'
        ,'AMEFEE'
        ,'AMFFEE'
        ,'AMGFEE'
        ,'AMIFEE'
        ,'AMCMIS'
        ,'AMMFEE'
        ,'AMPFEE'
        ,'AMCTOC'
        ,'AMBPOC'
        ,'AMCQFE'
        ,'AMCRFE'
        ,'AMCRIN'
        ,'AMYSAM'
        ,'AMCTPE'
        ,'AMCTUR'
        --bug 4176696 fixed by smahapat
        --,'BILL_ADJST'
        -- Missed out in the first
        ,'FINANCED_FEE_PAYMENT'
        ,'PREFUNDING'
        -- Added as per Satyas Mail
        ,'INTEREST_INCOME'
        ,'INTEREST_PAYMENT'
        ,'LOAN_PAYMENT'
        ,'PRINCIPAL_BALANCE'
        ,'PRINCIPAL_PAYMENT'
        -- Purposes specific to LS Type
        ,'BOOK_DEPRECIATION'
        ,'FEDERAL_DEPRECIATION'
        ,'FEE_RENEWAL'
        ,'INVESTOR_PRETAX_INCOME'
        ,'INVESTOR_RENTAL_ACCRUAL'
        ,'PASS_THROUGH_EVERGREEN_FEE'
        ,'PASS_THROUGH_EVERGREEN_RENT'
        ,'PASS_THROUGH_EVERGREEN_SERVICE'
        ,'PV_RENT'
        ,'PV_RENT_SECURITIZED'
        ,'PV_RV'
        ,'PV_RV_GUARANTEED'
        ,'PV_RV_INSURED'
        ,'PV_RV_SECURITIZED'
        ,'PV_RV_UNGUARANTEED'
        ,'PV_RV_UNINSURED'
        ,'RENEWAL_PROPERTY_TAX'
        ,'RENEWAL_RENT'
        ,'RESIDUAL_GUARANTEED'
        ,'RV_INSURANCE_PREMIUM'
        ,'RESIDUAL_VALUE'
        ,'STATE_DEPRECIATION'
        ,'STIP_LOSS_VALUE'
        ,'TERMINATION_VALUE'
        -- Purposes specific to DF,ST type
        ,'LEASE_INCOME'
        ,'PROCESSING_FEE'
        ,'PROCESSING_FEE_ACCRUAL'
        ,'DOWN_PAYMENT'
        ,'INSURANCE_ESTIMATE_PAYMENT'
        ,'VENDOR_RESIDUAL_SHARING'
        ,'QUOTE_PER_DIEM'
        --Bug 4616460 added new stream type purpose
        ,'ASSET_SALE_RECEIVABLE'
        ,'FLOAT_FACTOR_ADJUSTMENT'
        --Bug 4616460 end
	,'CAPITAL_REDUCTION'
--srsreeni 6117982 added
        ,'UPFRONT_TAX_FINANCED'
        ,'UPFRONT_TAX_CAPITALIZED'
--srsreeni 6117982 ends
        , 'UPFRONT_TAX_BILLED'  -- bug6619311
    );

    CURSOR purposes_for_op_csr( p_gtt_id IN OKL_ST_GEN_TEMPLATES.id%type) IS
    (
        -- Retrieve the List of Primary Stream Purposes in the Template
        SELECT distinct stb.stream_type_purpose purpose
        FROM OKL_ST_GEN_TMPT_LNS  gtl
               , okl_strm_type_b stb
        WHERE gtl.primary_sty_id = stb.id
        AND   gtl.primary_yn = 'Y'
        AND GTL.GTT_ID = p_gtt_id
        UNION
        -- Retrieve the List of Dependent Stream Purposes in the Template
        SELECT distinct stb.stream_type_purpose purpose
        FROM OKL_ST_GEN_TMPT_LNS  gtl
               , okl_strm_type_b stb
        WHERE gtl.dependent_sty_id = stb.id
        AND   gtl.primary_yn = 'N'
        and GTL.GTT_ID = p_gtt_id
    )
    MINUS
    SELECT LOOKUP_CODE
    FROM   FND_LOOKUPS
    WHERE  LOOKUP_TYPE = 'OKL_STREAM_TYPE_PURPOSE'
    AND LOOKUP_CODE in
    (
          'ACCOUNTING'
        ,'ACCRUED_FEE_EXPENSE'
        ,'ACCRUED_FEE_INCOME'
        ,'ACTUAL_PROPERTY_TAX'
        ,'ADJUSTED_PROPERTY_TAX'
        ,'ADVANCE_RENT'
        ,'AMORTIZED_FEE_EXPENSE'
        ,'AMORTIZE_FEE_INCOME'
        ,'REBOOK_BILLING_ADJUSTMENT'
        ,'CURE'
        ,'ESTIMATED_PROPERTY_TAX'
        ,'EXPENSE'
        ,'FEE_PAYMENT'
        ,'FUNDING'
        ,'INSURANCE_ACCRUAL_ADJUSTMENT'
        ,'INSURANCE_ADJUSTMENT'
        ,'INSURANCE_EXPENSE_ACCRUAL'
        ,'INSURANCE_INCOME_ACCRUAL'
        ,'INSURANCE_PAYABLE'
        ,'INSURANCE_RECEIVABLE'
        ,'INSURANCE_REFUND'
        ,'LATE_FEE'
        ,'LATE_INTEREST'
        ,'PASS_THRU_EXP_ACCRUAL'
        ,'PASS_THROUGH_FEE'
        ,'PASS_THRU_REV_ACCRUAL'
        ,'PASS_THROUGH_SERVICE'
        ,'PASS_THRU_SVC_EXP_ACCRUAL'
        ,'PASS_THRU_SVC_REV_ACCRUAL'
        ,'PREFUNDING_INTEREST_PAYMENT'
        -- Bug 4110239: Start
        --,'PROVISION'
        ,'SPECIFIC_LOSS_PROVISION'
        ,'GENERAL_LOSS_PROVISION'
        -- Bug 4110239: End
        ,'RENT'
        ,'GENERAL'
        ,'REPAIR_CHARGE'
        ,'SECURITY_DEPOSIT'
        ,'SERVICE_EXPENSE'
        ,'SERVICE_INCOME'
        ,'SERVICE_PAYMENT'
        ,'SERVICE_RENEWAL'
        ,'SUBSIDY'
        ,'SUBSIDY_INCOME'
        ,'USAGE_PAYMENT'
        ,'SERVICE_FEE_AMORT_SCHEDULE'
        ,'SERVICE_FEE_AUDIT_LETTER'
        ,'SERVICE_FEE_VAT_SCHEDULE'
        ,'SERVICE_FEE_VAR_RATE_STMNT'
        ,'SERVICE_FEE_INVOICE_REPRINT'
        ,'SERVICE_FEE_INVOICE_DEMAND'
        ,'SERVICE_FEE_REST_REQUEST'
        ,'SERVICE_FEE_TERM_REQUEST'
        ,'SERVICE_FEE_EXCHG_REQUEST'
        ,'SERVICE_FEE_TRANS_REQUEST'
        ,'SERVICE_FEE_PMT_CHANGE'
        ,'SERVICE_FEE_INTEREST_CONV'
        ,'SERVICE_FEE_GENERAL'
        ,'SERVICE_FEE_DOCUMENT_REQ'
        ,'AMBSPR'
        ,'AMAFEE'
        ,'AMBCOC'
        ,'AMYFEE'
        ,'AMCQDR'
        ,'AMPRTX'
        ,'AMEFEE'
        ,'AMFFEE'
        ,'AMGFEE'
        ,'AMIFEE'
        ,'AMCMIS'
        ,'AMMFEE'
        ,'AMPFEE'
        ,'AMCTOC'
        ,'AMBPOC'
        ,'AMCQFE'
        ,'AMCRFE'
        ,'AMCRIN'
        ,'AMYSAM'
        ,'AMCTPE'
        ,'AMCTUR'
        --bug 4176696 fixed by smahapat
        --,'BILL_ADJST'
        -- Missed out in the first
        ,'FINANCED_FEE_PAYMENT'
        ,'PREFUNDING'
        -- Added as per Satyas Mail
        ,'INTEREST_INCOME'
        ,'INTEREST_PAYMENT'
        ,'LOAN_PAYMENT'
        ,'PRINCIPAL_BALANCE'
        ,'PRINCIPAL_PAYMENT'
        -- Purposes specific to LS Type
        ,'BOOK_DEPRECIATION'
        ,'FEDERAL_DEPRECIATION'
        ,'FEE_RENEWAL'
        ,'INVESTOR_PRETAX_INCOME'
        ,'INVESTOR_RENTAL_ACCRUAL'
        ,'PASS_THROUGH_EVERGREEN_FEE'
        ,'PASS_THROUGH_EVERGREEN_RENT'
        ,'PASS_THROUGH_EVERGREEN_SERVICE'
        ,'PV_RENT'
        ,'PV_RENT_SECURITIZED'
        ,'PV_RV'
        ,'PV_RV_GUARANTEED'
        ,'PV_RV_INSURED'
        ,'PV_RV_SECURITIZED'
        ,'PV_RV_UNGUARANTEED'
        ,'PV_RV_UNINSURED'
        ,'RENEWAL_PROPERTY_TAX'
        ,'RENEWAL_RENT'
        ,'RESIDUAL_GUARANTEED'
        ,'RV_INSURANCE_PREMIUM'
        ,'RESIDUAL_VALUE'
        ,'STATE_DEPRECIATION'
        ,'STIP_LOSS_VALUE'
        ,'TERMINATION_VALUE'
        -- Purposes specific to OP Type
        ,'RENT_ACCRUAL'
        ,'PROCESSING_FEE'
        ,'PROCESSING_FEE_ACCRUAL'
        ,'DOWN_PAYMENT'
        ,'INSURANCE_ESTIMATE_PAYMENT'
        ,'VENDOR_RESIDUAL_SHARING'
        ,'QUOTE_PER_DIEM'
        --Bug 4616460  added new stream type purpose
        ,'ASSET_SALE_RECEIVABLE'
        --Bug 4616460 end
        ,'FLOAT_FACTOR_ADJUSTMENT'
	,'CAPITAL_REDUCTION'
--srsreeni 6117982 added
        ,'UPFRONT_TAX_FINANCED'
        ,'UPFRONT_TAX_CAPITALIZED'
--srsreeni 6117982 ends
        , 'UPFRONT_TAX_BILLED'   -- bug 6619311
    );

    CURSOR purposes_for_ln_csr( p_gtt_id IN OKL_ST_GEN_TEMPLATES.id%type) IS
    (
        -- Retrieve the List of Primary Stream Purposes in the Template
        SELECT distinct stb.stream_type_purpose purpose
        FROM OKL_ST_GEN_TMPT_LNS  gtl
               , okl_strm_type_b stb
        WHERE gtl.primary_sty_id = stb.id
        AND   gtl.primary_yn = 'Y'
        AND GTL.GTT_ID = p_gtt_id
        UNION
        -- Retrieve the List of Dependent Stream Purposes in the Template
        SELECT distinct stb.stream_type_purpose purpose
        FROM OKL_ST_GEN_TMPT_LNS  gtl
               , okl_strm_type_b stb
        WHERE gtl.dependent_sty_id = stb.id
        AND   gtl.primary_yn = 'N'
        and GTL.GTT_ID = p_gtt_id
    )
    MINUS
    SELECT LOOKUP_CODE
    FROM   FND_LOOKUPS
    WHERE  LOOKUP_TYPE = 'OKL_STREAM_TYPE_PURPOSE'
    AND LOOKUP_CODE in
    (
         'ACCOUNTING'
        ,'ACCRUED_FEE_EXPENSE'
        ,'ACCRUED_FEE_INCOME'
        ,'ACTUAL_PROPERTY_TAX'
        ,'ADJUSTED_PROPERTY_TAX'
        ,'ADVANCE_RENT'
        ,'AMORTIZED_FEE_EXPENSE'
        ,'AMORTIZE_FEE_INCOME'
        ,'REBOOK_BILLING_ADJUSTMENT'
        ,'CURE'
        ,'ESTIMATED_PROPERTY_TAX'
        ,'EXPENSE'
        ,'FEE_PAYMENT'
        ,'FUNDING'
        ,'INSURANCE_ACCRUAL_ADJUSTMENT'
        ,'INSURANCE_ADJUSTMENT'
        ,'INSURANCE_EXPENSE_ACCRUAL'
        ,'INSURANCE_INCOME_ACCRUAL'
        ,'INSURANCE_PAYABLE'
        ,'INSURANCE_RECEIVABLE'
        ,'INSURANCE_REFUND'
        ,'LATE_FEE'
        ,'LATE_INTEREST'
        ,'PASS_THRU_EXP_ACCRUAL'
        ,'PASS_THROUGH_FEE'
        ,'PASS_THRU_REV_ACCRUAL'
        ,'PASS_THROUGH_SERVICE'
        ,'PASS_THRU_SVC_EXP_ACCRUAL'
        ,'PASS_THRU_SVC_REV_ACCRUAL'
        ,'PREFUNDING_INTEREST_PAYMENT'
        -- Bug 4110239: Start
        --,'PROVISION'
        ,'SPECIFIC_LOSS_PROVISION'
        ,'GENERAL_LOSS_PROVISION'
        -- Bug 4110239: End
        ,'RENT'
        ,'GENERAL'
        ,'REPAIR_CHARGE'
        ,'SECURITY_DEPOSIT'
        ,'SERVICE_EXPENSE'
        ,'SERVICE_INCOME'
        ,'SERVICE_PAYMENT'
        ,'SERVICE_RENEWAL'
        ,'SUBSIDY'
        ,'SUBSIDY_INCOME'
        ,'USAGE_PAYMENT'
        ,'SERVICE_FEE_AMORT_SCHEDULE'
        ,'SERVICE_FEE_AUDIT_LETTER'
        ,'SERVICE_FEE_VAT_SCHEDULE'
        ,'SERVICE_FEE_VAR_RATE_STMNT'
        ,'SERVICE_FEE_INVOICE_REPRINT'
        ,'SERVICE_FEE_INVOICE_DEMAND'
        ,'SERVICE_FEE_REST_REQUEST'
        ,'SERVICE_FEE_TERM_REQUEST'
        ,'SERVICE_FEE_EXCHG_REQUEST'
        ,'SERVICE_FEE_TRANS_REQUEST'
        ,'SERVICE_FEE_PMT_CHANGE'
        ,'SERVICE_FEE_INTEREST_CONV'
        ,'SERVICE_FEE_GENERAL'
        ,'SERVICE_FEE_DOCUMENT_REQ'
        ,'AMBSPR'
        ,'AMAFEE'
        ,'AMBCOC'
        ,'AMYFEE'
        ,'AMCQDR'
        ,'AMPRTX'
        ,'AMEFEE'
        ,'AMFFEE'
        ,'AMGFEE'
        ,'AMIFEE'
        ,'AMCMIS'
        ,'AMMFEE'
        ,'AMPFEE'
        ,'AMCTOC'
        ,'AMBPOC'
        ,'AMCQFE'
        ,'AMCRFE'
        ,'AMCRIN'
        ,'AMYSAM'
        ,'AMCTPE'
        ,'AMCTUR'
        --bug 4176696 fixed by smahapat
        --,'BILL_ADJST'
        -- Missed out in the first
        ,'FINANCED_FEE_PAYMENT'
        ,'PREFUNDING'
        -- Specific Purposes for Loan And Loan Revolving Deal Type
        ,'INTEREST_INCOME'
        ,'INTEREST_PAYMENT'
        ,'LOAN_PAYMENT'
        ,'PRINCIPAL_BALANCE'
        ,'PRINCIPAL_CATCHUP'
        ,'PRINCIPAL_PAYMENT'
        ,'UNSCHEDULED_PRINCIPAL_PAYMENT'
        ,'VARIABLE_INCOME_NONACCRUAL'
        ,'VARIABLE_INTEREST'
        ,'VARIABLE_INTEREST_INCOME'
        ,'VARIABLE_INTEREST_SCHEDULE'
        -- Bug 4137045: Start
        ,'INVESTOR_INTEREST_INCOME'
        ,'INVESTOR_VARIABLE_INTEREST'
        -- Bug 4137045: End
        ,'PROCESSING_FEE'
        ,'PROCESSING_FEE_ACCRUAL'
        ,'DOWN_PAYMENT'
        ,'INSURANCE_ESTIMATE_PAYMENT'
        ,'DAILY_INTEREST_PRINCIPAL'
        ,'DAILY_INTEREST_INTEREST'
        ,'INTEREST_CATCHUP'
        ,'UNSCHEDULED_LOAN_PAYMENT'
        ,'EXCESS_PRINCIPAL_PAID'
        ,'EXCESS_INTEREST_PAID'
        ,'EXCESS_LOAN_PAYMENT_PAID'
        ,'QUOTE_PER_DIEM'
        --Bug 4616460  added new stream type purpose
        ,'ASSET_SALE_RECEIVABLE'
        --Bug 4616460 end
        --Bug 4664317 adds ACTUAL_INCOME_ACCRUAL
        ,'ACTUAL_INCOME_ACCRUAL'
        --Bug 4677496 adds ACTUAL_INCOME_ACCRUAL
        ,'VARIABLE_LOAN_PAYMENT'
	,'CAPITAL_REDUCTION'
--srsreeni 6117982 added
        ,'UPFRONT_TAX_FINANCED'
        ,'UPFRONT_TAX_CAPITALIZED'
--srsreeni 6117982 ends
        , 'UPFRONT_TAX_BILLED'  -- bug 6619311
    );
    -- Modified by RGOOTY
    -- Bug 4129154: Start
    CURSOR fetch_sgt_info( p_gtt_id IN OKL_ST_GEN_TEMPLATES.id%type)
    IS
      SELECT  gts.revenue_recog_meth_code revenue_recog_meth_code,
              gts.interest_calc_meth_code interest_calc_meth_code
        FROM  OKL_ST_GEN_TMPT_SETS gts,
              OKL_ST_GEN_TEMPLATES gtt
        WHERE gtt.gts_id = gts.id
         AND  gtt.id = p_gtt_id;
    l_rrm              OKL_ST_GEN_TMPT_SETS.revenue_recog_meth_code%TYPE;
    l_icm              OKL_ST_GEN_TMPT_SETS.interest_calc_meth_code%TYPE;

    l_purpose_list      VARCHAR2(10000);
    l_purpose_list_rent VARCHAR2(10000);  -- For Rent Dependents
    l_purpose_list_rv   VARCHAR2(10000);  -- For Residual Value Dependents
    l_purpose_list_vi   VARCHAR2(10000);  -- For Variable Interest Dependents
    i NUMBER := 0;
    -- Bug 4129154: End
BEGIN
    -- Perform the Initializations
   l_return_status := OKL_API.G_RET_STS_SUCCESS;
   -- Get the Interest Calculation Method and Revenue Recognition Method from the SGT
   FOR t_rec IN fetch_sgt_info( p_gtt_id => p_gtt_id )
   LOOP
     l_rrm := t_rec.revenue_recog_meth_code;
     l_icm := t_rec.interest_calc_meth_code;
   END LOOP;
   -- 1. If user selects one of the following Insurance purposes then all the
   -- insurance stream purposes must be defined.
   l_ins_strms_count := 0;
   FOR ins_strm_types_count_rec IN okl_ins_purposes_csr(l_gtt_id)
   LOOP
       l_ins_strms_count := ins_strm_types_count_rec.ins_strms_count;
   END LOOP;
   IF( l_ins_strms_count IS NOT NULL AND l_ins_strms_count <> 0 AND l_ins_strms_count <> 7 ) -- Bug 4096853
   THEN
      -- Violated first condition
      put_messages_in_table(   G_OKL_ST_ALL_INS_PURPOSES
                               ,p_during_upd_flag
                               ,l_message
                            );
      l_error_msgs_tbl(l_msgs_count).error_message := l_message;
      l_error_msgs_tbl(l_msgs_count).error_type_code := G_TYPE_ERROR;
      l_error_msgs_tbl(l_msgs_count).error_type_meaning := GET_LOOKUP_MEANING( G_CP_SET_OUTCOME, G_TYPE_ERROR);
      l_msgs_count := l_msgs_count + 1;
   END IF;
   -- 2. Only one stream type of the following primary purposes should be defined.
   l_purpose_list := '';
   FOR fin_only_one_as_primary_rec IN fin_only_one_as_primary_csr(l_gtt_id)
   LOOP
     IF l_icm = 'FIXED_UPGRADE' AND
        fin_only_one_as_primary_rec.purpose = 'VENDOR_RESIDUAL_SHARING'
     THEN
       -- VR Upgrade. Bug 4756154
       -- OKL.H only introduced the VENDOR_RESIDUAL_SHARING, OKL.G doesnot have this purpose at all.
       -- So, for SGTs with ICM = "Fixed Upgrade", we are removing the validation
       --  which checks the mandatory presence of the VENDOR_RESIDUAL_SHARING purpose streams.
       NULL;
     ELSE
       l_purpose_list := l_purpose_list ||
                         OKL_ACCOUNTING_UTIL.GET_LOOKUP_MEANING
                         ( G_OKL_FIN_PRIMARY_PURPOSES, fin_only_one_as_primary_rec.purpose )
                         || ',';
     END IF;
   END LOOP;
   l_purpose_list := rtrim( l_purpose_list, ',' );
   IF( length(l_purpose_list) > 0 )
   THEN
       put_messages_in_table(     G_OKL_ST_STRM_ONE_PRI_PURPOSE
                                    ,p_during_upd_flag
                                    ,l_message
                                    ,p_token1 => G_PURPOSE_TOKEN
                                    ,p_value1 => l_purpose_list
                                );
       l_error_msgs_tbl(l_msgs_count).error_message := l_message;
       l_error_msgs_tbl(l_msgs_count).error_type_code := G_TYPE_ERROR;
       l_error_msgs_tbl(l_msgs_count).error_type_meaning := GET_LOOKUP_MEANING( G_CP_SET_OUTCOME, G_TYPE_ERROR);
       l_msgs_count := l_msgs_count + 1;
   END IF;

    -- 3.	All of the following primary purposes must be defined
   l_purpose_list := '';
   FOR fin_mandatory_pri_all_rec IN fin_mandatory_pri_all_csr(l_gtt_id)
   LOOP
     -- VR Upgrade. Bug 4756154
     -- In OKL.G, Quote Per Diem is not mandatory and REBOOK_BILLING_ADJUSTMENT is mandatory.
     -- In OKL.H, Quote Per Diem is mandatory and REBOOK_BILLING_ADJUSTMENT is not mandatory.
     IF ( l_icm = 'FIXED_UPGRADE' AND
          fin_mandatory_pri_all_rec.purpose = 'QUOTE_PER_DIEM' ) -- OKL.H Introduced this.
          OR
        ( l_icm <> 'FIXED_UPGRADE' AND
          fin_mandatory_pri_all_rec.purpose = 'REBOOK_BILLING_ADJUSTMENT' ) -- OKL.H Deleted this purpose from the list
     THEN
       -- Donot populate this Purpose to the error list.
       NULL;
     ELSE
       l_purpose_list := l_purpose_list ||
                         OKL_ACCOUNTING_UTIL.GET_LOOKUP_MEANING
                                ( G_OKL_FIN_PRIMARY_PURPOSES,fin_mandatory_pri_all_rec.purpose )
                         || ',';
     END IF;
   END LOOP;

   IF ( belongs_to_ln( p_book_classification ) = TRUE )
   THEN
       FOR fin_mandatory_pri_ln_rec IN fin_mandatory_pri_ln_csr(l_gtt_id)
       LOOP
           l_purpose_list := l_purpose_list ||
                         OKL_ACCOUNTING_UTIL.GET_LOOKUP_MEANING
                                    ( G_OKL_FIN_PRIMARY_PURPOSES,fin_mandatory_pri_ln_rec.purpose )
                         || ',';
       END LOOP;

       --Bug 5139013 dpsingh start
   IF l_icm = 'FLOAT' THEN
     FOR fin_mandatory_pri_ic_float_rec IN fin_mandatory_pri_ic_float_csr(l_gtt_id)
     LOOP
        l_purpose_list := l_purpose_list ||
                                 OKL_ACCOUNTING_UTIL.GET_LOOKUP_MEANING
                                 ( G_OKL_FIN_PRIMARY_PURPOSES,fin_mandatory_pri_ic_float_rec.purpose )
                                 || ',';
     END LOOP;
   END IF;
   --Bug 5139013 dpsingh end
   END IF;
   IF ( belongs_to_ls( p_book_classification ) = TRUE )
   THEN
       FOR fin_mandatory_pri_ls_rec IN fin_mandatory_pri_ls_csr(l_gtt_id)
       LOOP
             l_purpose_list := l_purpose_list ||
                         OKL_ACCOUNTING_UTIL.GET_LOOKUP_MEANING
                                    ( G_OKL_FIN_PRIMARY_PURPOSES	,fin_mandatory_pri_ls_rec.purpose )
                         || ',';
       END LOOP;
   END IF;
   -- Modified by RGOOTY
   -- Bug 4111081: Start
   IF ( p_book_classification = G_LEASEOP_DEAL_TYPE )
   THEN
       FOR fin_mandatory_pri_op_rec IN fin_mandatory_pri_op_csr(l_gtt_id)
       LOOP
             l_purpose_list := l_purpose_list ||
                         OKL_ACCOUNTING_UTIL.GET_LOOKUP_MEANING
                                    ( G_OKL_FIN_PRIMARY_PURPOSES	,fin_mandatory_pri_op_rec.purpose )
                         || ',';
       END LOOP;
   END IF;

   IF ( p_book_classification = G_LEASEDF_DEAL_TYPE OR
        p_book_classification =  G_LEASEST_DEAL_TYPE )
   THEN
       FOR fin_mandatory_pri_df_n_st_rec IN fin_mandatory_pri_df_n_st_csr(l_gtt_id)
       LOOP
             l_purpose_list := l_purpose_list ||
                         OKL_ACCOUNTING_UTIL.GET_LOOKUP_MEANING
                                    ( G_OKL_FIN_PRIMARY_PURPOSES	,fin_mandatory_pri_df_n_st_rec.purpose )
                         || ',';
       END LOOP;
   END IF;
   -- Bug 4111081: End

   l_purpose_list := rtrim( l_purpose_list,',' );
   IF( length(l_purpose_list) > 0 )
   THEN
       put_messages_in_table(  G_OKL_ST_MANDATORY_PRI_PURPOSE
                                    ,p_during_upd_flag
                                    ,l_message
                                    ,p_token1 => G_PURPOSE_TOKEN
                                    ,p_value1 => l_purpose_list
                                  );
       l_error_msgs_tbl(l_msgs_count).error_message := l_message;
       l_error_msgs_tbl(l_msgs_count).error_type_code := G_TYPE_ERROR;
       l_error_msgs_tbl(l_msgs_count).error_type_meaning := GET_LOOKUP_MEANING( G_CP_SET_OUTCOME, G_TYPE_ERROR);
       l_msgs_count := l_msgs_count + 1;
   END IF;

    -- 4.	Dependent Stream Types expected for all these stream types
    -- Modified by RGOOTY
    -- Bug 4129154: Start
   l_purpose_list_rent := '';
   l_purpose_list_rv   := '';
   l_purpose_list_vi   := '';
   FOR man_dep_all_rent_rec IN man_dep_all_rent_csr(l_gtt_id)
   LOOP
       l_purpose_list_rent := l_purpose_list_rent ||
                         OKL_ACCOUNTING_UTIL.GET_LOOKUP_MEANING
                         ( G_OKL_FIN_DEPENDENT_PURPOSES,  man_dep_all_rent_rec.purpose )
                         || ',';
   END LOOP;

   IF ( belongs_to_ln( p_book_classification ) = TRUE )
   THEN
       FOR man_dep_ln_rent_rec IN man_dep_ln_rent_csr(l_gtt_id)
       LOOP
         --BUG :5052810, Modified by dpsingh
	 IF NOT (p_book_classification = G_LOAN_REV_DEAL_TYPE and man_dep_ln_rent_rec.purpose = 'PRINCIPAL_CATCHUP') THEN
	    l_purpose_list_rent := l_purpose_list_rent ||
                         OKL_ACCOUNTING_UTIL.GET_LOOKUP_MEANING
                         ( G_OKL_FIN_DEPENDENT_PURPOSES,  man_dep_ln_rent_rec.purpose )
                         || ',';
         END IF;
	  --BUG :5052810
       END LOOP;

       FOR man_dep_ln_var_int_rec IN man_dep_ln_var_int_csr(l_gtt_id)
       LOOP
            l_purpose_list_vi := l_purpose_list_vi ||
                         OKL_ACCOUNTING_UTIL.GET_LOOKUP_MEANING
                         ( G_OKL_FIN_DEPENDENT_PURPOSES,  man_dep_ln_var_int_rec.purpose )
                         || ',';
       END LOOP;
   END IF;

   IF ( belongs_to_df_st( p_book_classification ) = TRUE )
   THEN
       FOR man_dep_df_st_rent_rec IN man_dep_df_st_rent_csr(l_gtt_id)
       LOOP
          l_purpose_list_rent := l_purpose_list_rent ||
                         OKL_ACCOUNTING_UTIL.GET_LOOKUP_MEANING
                                    ( G_OKL_FIN_DEPENDENT_PURPOSES,  man_dep_df_st_rent_rec.purpose )
                         || ',';
       END LOOP;
   END IF;

   IF ( belongs_to_ls( p_book_classification ) = TRUE )
   THEN
       FOR man_dep_ls_rent_rec IN man_dep_ls_rent_csr(l_gtt_id)
       LOOP
           l_purpose_list_rent := l_purpose_list_rent ||
                       OKL_ACCOUNTING_UTIL.GET_LOOKUP_MEANING
                       ( G_OKL_FIN_DEPENDENT_PURPOSES,  man_dep_ls_rent_rec.purpose )
                         || ',';
       END LOOP;

       FOR man_dep_ls_rv_rec IN man_dep_ls_rv_csr(l_gtt_id)
       LOOP
           l_purpose_list_rv := l_purpose_list_rv ||
                       OKL_ACCOUNTING_UTIL.GET_LOOKUP_MEANING
                       ( G_OKL_FIN_DEPENDENT_PURPOSES,  man_dep_ls_rv_rec.purpose )
                         || ',';
       END LOOP;
   END IF;

   IF ( belongs_to_op( p_book_classification ) = TRUE )
   THEN
       FOR man_dep_op_rent_rec IN man_dep_op_rent_csr(l_gtt_id)
       LOOP
            l_purpose_list_rent := l_purpose_list_rent ||
                      OKL_ACCOUNTING_UTIL.GET_LOOKUP_MEANING
                      ( G_OKL_FIN_DEPENDENT_PURPOSES,  man_dep_op_rent_rec.purpose )
                         || ',';
       END LOOP;
   END IF;

   l_purpose_list_rent := rtrim( l_purpose_list_rent,',' );
   l_purpose_list_rv   := rtrim( l_purpose_list_rv,',' );
   l_purpose_list_vi   := rtrim( l_purpose_list_vi,',' );

   IF( length(l_purpose_list_rent) > 0 )
   THEN
       put_messages_in_table(   G_OKL_ST_MANDATORY_DEP_PURPOSE
                                    ,p_during_upd_flag
                                    ,l_message
                                    ,p_token1 => 'PRISTREAM'
                                    ,p_value1 => OKL_ACCOUNTING_UTIL.GET_LOOKUP_MEANING
                         ( G_OKL_FIN_PRIMARY_PURPOSES, 'RENT' )
                                    ,p_token2 => G_PURPOSE_TOKEN
                                    ,p_value2 => l_purpose_list_rent
                                 );
       l_error_msgs_tbl(l_msgs_count).error_message := l_message;
       l_error_msgs_tbl(l_msgs_count).error_type_code := G_TYPE_ERROR;
       l_error_msgs_tbl(l_msgs_count).error_type_meaning := GET_LOOKUP_MEANING( G_CP_SET_OUTCOME, G_TYPE_ERROR);
       l_msgs_count := l_msgs_count + 1;
   END IF;

   IF( length(l_purpose_list_rv) > 0 )
   THEN
       put_messages_in_table(   G_OKL_ST_MANDATORY_DEP_PURPOSE
                                    ,p_during_upd_flag
                                    ,l_message
                                    ,p_token1 => 'PRISTREAM'
                                    ,p_value1 => OKL_ACCOUNTING_UTIL.GET_LOOKUP_MEANING
                         ( G_OKL_FIN_PRIMARY_PURPOSES, 'RESIDUAL_VALUE' )
                                    ,p_token2 => G_PURPOSE_TOKEN
                                    ,p_value2 => l_purpose_list_rv
                                 );
       l_error_msgs_tbl(l_msgs_count).error_message := l_message;
       l_error_msgs_tbl(l_msgs_count).error_type_code := G_TYPE_ERROR;
       l_error_msgs_tbl(l_msgs_count).error_type_meaning := GET_LOOKUP_MEANING( G_CP_SET_OUTCOME, G_TYPE_ERROR);
       l_msgs_count := l_msgs_count + 1;
   END IF;

   IF( length(l_purpose_list_vi) > 0 )
   THEN
       put_messages_in_table(   G_OKL_ST_MANDATORY_DEP_PURPOSE
                                    ,p_during_upd_flag
                                    ,l_message
                                    ,p_token1 => 'PRISTREAM'
                                    ,p_value1 => OKL_ACCOUNTING_UTIL.GET_LOOKUP_MEANING
                         ( G_OKL_FIN_PRIMARY_PURPOSES, 'VARIABLE_INTEREST' )
                                    ,p_token2 => G_PURPOSE_TOKEN
                                    ,p_value2 => l_purpose_list_vi
                                 );
       l_error_msgs_tbl(l_msgs_count).error_message := l_message;
       l_error_msgs_tbl(l_msgs_count).error_type_code := G_TYPE_ERROR;
       l_error_msgs_tbl(l_msgs_count).error_type_meaning := GET_LOOKUP_MEANING( G_CP_SET_OUTCOME, G_TYPE_ERROR);
       l_msgs_count := l_msgs_count + 1;
   END IF;
   -- Bug 4129154: End
   -- Rule 6. Certain Book Classifications can have certain Purposes Only.
   l_purpose_list := '';
   IF ( p_book_classification = G_LEASEDF_DEAL_TYPE OR
        p_book_classification = G_LEASEST_DEAL_TYPE   )
   THEN
       FOR purposes_for_df_and_st_rec IN purposes_for_df_and_st_csr(l_gtt_id)
       LOOP
           l_purpose_list := l_purpose_list ||
                     OKL_ACCOUNTING_UTIL.GET_LOOKUP_MEANING
                     ( G_OKL_STREAM_TYPE_PURPOSE,  purposes_for_df_and_st_rec.purpose )
                         || ',';
       END LOOP;
   ELSIF ( p_book_classification = G_LEASEOP_DEAL_TYPE )
   THEN
       FOR purposes_for_op_rec IN purposes_for_op_csr(l_gtt_id)
           LOOP
               l_purpose_list := l_purpose_list ||
                    OKL_ACCOUNTING_UTIL.GET_LOOKUP_MEANING
                    (  G_OKL_STREAM_TYPE_PURPOSE,  purposes_for_op_rec.purpose )
                         || ',';
           END LOOP;
   ELSIF ( p_book_classification = G_LOAN_DEAL_TYPE  OR p_book_classification = G_LOAN_REV_DEAL_TYPE  )
   THEN
       FOR purposes_for_ln_rec IN purposes_for_ln_csr(l_gtt_id)
           LOOP
               l_purpose_list := l_purpose_list ||
                    OKL_ACCOUNTING_UTIL.GET_LOOKUP_MEANING
                    ( G_OKL_STREAM_TYPE_PURPOSE,  purposes_for_ln_rec.purpose )
                    || ',';
           END LOOP;
   END IF;
   l_purpose_list := rtrim( l_purpose_list ,',');
   IF( length(l_purpose_list) > 0 )
   THEN
       put_messages_in_table(  G_OKL_ST_INVALID_PURPOSES
                                    ,p_during_upd_flag
                                    ,l_message
                                    ,p_token1 =>  G_PURPOSE_TOKEN
                                    ,p_value1 => l_purpose_list
                                    ,p_token2 => G_DEAL_TYPE_TOKEN
                                    ,p_value2 => OKL_ACCOUNTING_UTIL.GET_LOOKUP_MEANING
                                    ( G_OKL_STREAM_ALL_BOOK_CLASS,  p_book_classification )
                                );
       l_error_msgs_tbl(l_msgs_count).error_message := l_message;
       l_error_msgs_tbl(l_msgs_count).error_type_code := G_TYPE_ERROR;
       l_error_msgs_tbl(l_msgs_count).error_type_meaning := GET_LOOKUP_MEANING( G_CP_SET_OUTCOME, G_TYPE_ERROR);
       l_msgs_count := l_msgs_count + 1;
   END IF;
   -- Rule 7: Part - I
   --  For Loan/Loan-Revolving SGTs with Revenue Recognition = ACTUAL
   --   Following are mandatory dependents of RENT Stream
   --   DAILY_INTEREST_PRINCIPAL,DAILY_INTEREST_INTEREST ,
   --   UNSCHEDULED_LOAN_PAYMENT,VARIABLE_LOAN_PAYMENT
   --   EXCESS_PRINCIPAL_PAID, EXCESS_INTEREST_PAID,
   --   EXCESS_LOAN_PAYMENT_PAID,ACTUAL_INCOME_ACCRUAL
   IF ( p_book_classification = G_LOAN_DEAL_TYPE  OR
        p_book_classification = G_LOAN_REV_DEAL_TYPE  ) AND
        l_rrm = 'ACTUAL'
   THEN
     l_purpose_list := '';
     FOR t_rec IN man_dep_ln_vrs_rent_csr( p_gtt_id => p_gtt_id)
     LOOP
       l_purpose_list := l_purpose_list ||
                         OKL_ACCOUNTING_UTIL.GET_LOOKUP_MEANING
                         ( G_OKL_STREAM_TYPE_PURPOSE,  t_rec.purpose )|| ',';
     END LOOP;
     -- Populate the error messages table if needed.
     l_purpose_list := rtrim( l_purpose_list ,',');
     IF( length(l_purpose_list) > 0 )
     THEN
       put_messages_in_table(
          'OKL_ST_LN_LNR_VR_MAN_DEP_RENT'
         ,p_during_upd_flag
         ,l_message
         ,p_token1 => 'DEPPURPOSELIST'
         ,p_value1 => l_purpose_list
         ,p_token2 =>  'PRIMRENTSTRM'
         ,p_value2 => OKL_ACCOUNTING_UTIL.GET_LOOKUP_MEANING(G_OKL_STREAM_TYPE_PURPOSE,'RENT'));
       l_error_msgs_tbl(l_msgs_count).error_message := l_message;
       l_error_msgs_tbl(l_msgs_count).error_type_code := G_TYPE_ERROR;
       l_error_msgs_tbl(l_msgs_count).error_type_meaning := GET_LOOKUP_MEANING( G_CP_SET_OUTCOME, G_TYPE_ERROR);
       l_msgs_count := l_msgs_count + 1;
     END IF;
   END IF;
   -- Rule 7: Part - II
   -- For Direct Finance/Deal Type/Operating Lease and Interest Calculation Method = Float Factor
   --  The following dependents should be defined for the Rent Primary Stream Type
   --   FLOAT_FACTOR_ADJUSTMENT
   IF ( p_book_classification = G_LEASEDF_DEAL_TYPE  OR
        p_book_classification = G_LEASEST_DEAL_TYPE  OR
        p_book_classification = G_LEASEOP_DEAL_TYPE  ) AND
      l_icm = 'FLOAT_FACTORS'
   THEN
     l_purpose_list := '';
     FOR t_rec IN man_dep_dfstop_vrs_rent_csr( p_gtt_id => p_gtt_id)
     LOOP
       l_purpose_list := l_purpose_list ||
                         OKL_ACCOUNTING_UTIL.GET_LOOKUP_MEANING
                         ( G_OKL_STREAM_TYPE_PURPOSE,  t_rec.purpose )|| ',';
     END LOOP;
     -- Populate the error messages table if needed.
     l_purpose_list := rtrim( l_purpose_list ,',');
     IF( length(l_purpose_list) > 0 )
     THEN
       put_messages_in_table(
          'OKL_ST_OPDFST_VR_MAN_DEP_RENT'
         ,p_during_upd_flag
         ,l_message
         ,p_token1 => 'DEPPURPOSELIST'
         ,p_value1 => l_purpose_list
         ,p_token2 =>  'PRIMRENTSTRM'
         ,p_value2 => OKL_ACCOUNTING_UTIL.GET_LOOKUP_MEANING(G_OKL_STREAM_TYPE_PURPOSE,'RENT'));
       l_error_msgs_tbl(l_msgs_count).error_message := l_message;
       l_error_msgs_tbl(l_msgs_count).error_type_code := G_TYPE_ERROR;
       l_error_msgs_tbl(l_msgs_count).error_type_meaning := GET_LOOKUP_MEANING( G_CP_SET_OUTCOME, G_TYPE_ERROR);
       l_msgs_count := l_msgs_count + 1;
     END IF;
   END IF;
   -- Rule 7: Part - III
   -- For Loans and Interest Calculation Method = Catchup/Cleanup
   --  The following dependents should be defined for the Rent Primary Stream Type
   --   INTEREST_CATCHUP
   IF p_book_classification = G_LOAN_DEAL_TYPE   AND
      l_icm = 'CATCHUP/CLEANUP'
   THEN
     l_purpose_list := '';
     FOR t_rec IN man_dep_ln_icc_vrs_rent_csr( p_gtt_id => p_gtt_id)
     LOOP
       l_purpose_list := l_purpose_list ||
                         OKL_ACCOUNTING_UTIL.GET_LOOKUP_MEANING
                         ( G_OKL_STREAM_TYPE_PURPOSE,  t_rec.purpose )|| ',';
     END LOOP;
     -- Populate the error messages table if needed.
     l_purpose_list := rtrim( l_purpose_list ,',');
     IF( length(l_purpose_list) > 0 )
     THEN
       put_messages_in_table(
          'OKL_ST_LN_VR_MAN_DEP_RENT'
         ,p_during_upd_flag
         ,l_message
         ,p_token1 => 'DEPPURPOSELIST'
         ,p_value1 => l_purpose_list
         ,p_token2 =>  'PRIMRENTSTRM'
         ,p_value2 => OKL_ACCOUNTING_UTIL.GET_LOOKUP_MEANING(G_OKL_STREAM_TYPE_PURPOSE,'RENT'));
       l_error_msgs_tbl(l_msgs_count).error_message := l_message;
       l_error_msgs_tbl(l_msgs_count).error_type_code := G_TYPE_ERROR;
       l_error_msgs_tbl(l_msgs_count).error_type_meaning := GET_LOOKUP_MEANING( G_CP_SET_OUTCOME, G_TYPE_ERROR);
       l_msgs_count := l_msgs_count + 1;
     END IF;
   END IF;
   --Rule 8 : Revenue Rec Meth / IC method validation as part of VR build
   val_ic_rr_day_con_methods(
                     p_api_version            => p_api_version
                    ,p_init_msg_list          => p_init_msg_list
                    ,x_return_status          => x_return_status
                    ,x_msg_count              => x_msg_count
                    ,x_msg_data               => x_msg_data
                    ,p_gtt_id                 => p_gtt_id
                    ,x_error_msgs_tbl         => l_error_msgs_tbl_val_bill
                    ,p_during_upd_flag        => p_during_upd_flag
                    ,p_book_classification    => p_book_classification);
   IF (l_error_msgs_tbl_val_bill.COUNT > 0) THEN
      i := l_error_msgs_tbl_val_bill.FIRST;
      LOOP
        l_error_msgs_tbl(l_msgs_count) := l_error_msgs_tbl_val_bill(i);
        l_msgs_count := l_msgs_count + 1;
        EXIT WHEN (i = l_error_msgs_tbl_val_bill.LAST);
        i := l_error_msgs_tbl_val_bill.NEXT(i);
      END LOOP;
   END IF;
   x_error_msgs_tbl := l_error_msgs_tbl;
   x_return_status := l_return_status;
EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (l_api_name,
       G_PKG_NAME,
       'OKL_API.G_RET_STS_ERROR',
       x_msg_count,
       x_msg_data,
       '_PVT');
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      ( l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT');
    WHEN OTHERS THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      ( l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT');
end validate_financial_template;

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_investor_template
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : validate_investor_template
  -- Description     : Validates a Stream Generation Template with Investor
  --                   as Product Type
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------

Procedure validate_investor_template(
                     p_api_version             IN  NUMBER
                    ,p_init_msg_list           IN  VARCHAR2 DEFAULT Okc_Api.G_FALSE
                    ,x_return_status           OUT NOCOPY VARCHAR2
                    ,x_msg_count               OUT NOCOPY NUMBER
                    ,x_msg_data                OUT NOCOPY VARCHAR2
		            ,p_gtt_id                  IN  okl_st_gen_templates.id%type
		            ,x_error_msgs_tbl          OUT NOCOPY error_msgs_tbl_type
		            ,p_during_upd_flag         IN VARCHAR
      )IS
    l_api_name          CONSTANT VARCHAR2(40) := 'validate_investor_template';
    l_api_version       CONSTANT NUMBER       := 1.0;
    l_return_status     VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_error_msgs_tbl    error_msgs_tbl_type;
    l_msgs_count          NUMBER := 1;

    l_init_msg_list     VARCHAR2(1);
    l_msg_count         NUMBER;
    l_msg_data          VARCHAR2(2000);
    l_dummy VARCHAR2(1) := okl_api.G_FALSE;

    -- 1.	Only one stream type of the following primary purposes should be defined.
    CURSOR inv_only_one_as_primary_csr( p_gtt_id IN OKL_ST_GEN_TEMPLATES.id%type) IS
    SELECT stb.stream_type_purpose purpose, count(stb.stream_type_purpose)
    FROM    OKL_ST_GEN_TMPT_LNS  gtl
           ,okl_strm_type_b stb
    WHERE gtl.primary_sty_id = stb.id
    AND   gtl.primary_yn = 'Y'
    AND stb.stream_type_purpose IN
    (
         'INVESTOR_CNTRCT_OBLIGATION_PAY'
        ,'INVESTOR_DISB_ADJUSTMENT'
        ,'INVESTOR_EVERGREEN_RENT_PAY'
        ,'INVESTOR_INTEREST_PAYABLE'
        ,'INVESTOR_LATE_FEE_PAYABLE'
        ,'INVESTOR_LATE_INTEREST_PAY'
        ,'INVESTOR_PAYABLE'
        ,'INVESTOR_PRINCIPAL_PAYABLE'
        ,'INVESTOR_RECEIVABLE'
        ,'INVESTOR_RENT_BUYBACK'
        ,'INVESTOR_RENT_DISB_BASIS'
        ,'INVESTOR_RENT_PAYABLE'
        ,'INVESTOR_RESIDUAL_BUYBACK'
        ,'INVESTOR_RESIDUAL_DISB_BASIS'
        ,'INVESTOR_RESIDUAL_PAY'
    )
    AND GTL.GTT_ID = p_gtt_id
    group by stb.stream_type_purpose
    having count(stb.stream_type_purpose) > 1;

    -- 3.	All of the following primary purposes must be defined
    CURSOR inv_mandatory_primary_csr( p_gtt_id IN OKL_ST_GEN_TEMPLATES.id%type) IS
    SELECT LOOKUP_CODE PURPOSE
    FROM   FND_LOOKUPS
    WHERE LOOKUP_TYPE = 'OKL_STREAM_TYPE_PURPOSE'
    AND LOOKUP_CODE IN
    (
         'INVESTOR_CNTRCT_OBLIGATION_PAY'
        ,'INVESTOR_DISB_ADJUSTMENT'
        ,'INVESTOR_EVERGREEN_RENT_PAY'
        ,'INVESTOR_LATE_FEE_PAYABLE'
        ,'INVESTOR_LATE_INTEREST_PAY'
        ,'INVESTOR_PAYABLE'
        -- Modified by RGOOTY
        -- Bug 4111470: Start
        --,'INVESTOR_INTEREST_PAYABLE'
        --,'INVESTOR_PRINCIPAL_PAYABLE'
        -- Bug 4111470: End
        ,'INVESTOR_RECEIVABLE'
        ,'INVESTOR_RENT_BUYBACK'
        ,'INVESTOR_RENT_DISB_BASIS'
        ,'INVESTOR_RENT_PAYABLE'
        ,'INVESTOR_RESIDUAL_BUYBACK'
        ,'INVESTOR_RESIDUAL_DISB_BASIS'
        ,'INVESTOR_RESIDUAL_PAY'
        -- Change requested by Satya on Nov 10
        ,'PV_RENT_SECURITIZED'
        ,'PV_RV_SECURITIZED'
    )
    MINUS
    SELECT distinct stb.stream_type_purpose purpose
    FROM OKL_ST_GEN_TMPT_LNS  gtl
           , okl_strm_type_b stb
    WHERE gtl.primary_sty_id = stb.id
    AND   gtl.primary_yn = 'Y'
    AND stb.stream_type_purpose IN
    (
         'INVESTOR_CNTRCT_OBLIGATION_PAY'
        ,'INVESTOR_DISB_ADJUSTMENT'
        ,'INVESTOR_EVERGREEN_RENT_PAY'
        ,'INVESTOR_LATE_FEE_PAYABLE'
        ,'INVESTOR_LATE_INTEREST_PAY'
        ,'INVESTOR_PAYABLE'
        -- Modified by RGOOTY
        -- Bug 4111470: Start
        --,'INVESTOR_INTEREST_PAYABLE'
        --,'INVESTOR_PRINCIPAL_PAYABLE'
        -- Bug 4111470: End
        ,'INVESTOR_RECEIVABLE'
        ,'INVESTOR_RENT_BUYBACK'
        ,'INVESTOR_RENT_DISB_BASIS'
        ,'INVESTOR_RENT_PAYABLE'
        ,'INVESTOR_RESIDUAL_BUYBACK'
        ,'INVESTOR_RESIDUAL_DISB_BASIS'
        ,'INVESTOR_RESIDUAL_PAY'
        -- Change requested by Satya on Nov 10
        ,'PV_RENT_SECURITIZED'
        ,'PV_RV_SECURITIZED'
    )
    and GTL.GTT_ID = p_gtt_id;
    l_message VARCHAR2(2700);
    l_purpose_list VARCHAR2(10000);
BEGIN
    -- Perform the Initializations
   l_return_status := OKL_API.G_RET_STS_SUCCESS;
   -- Only one stream type of the following primary purposes should be defined.
   l_purpose_list := '';
   FOR only_one_as_primary_rec IN inv_only_one_as_primary_csr(p_gtt_id)
   LOOP
       l_purpose_list := l_purpose_list ||
                         OKL_ACCOUNTING_UTIL.GET_LOOKUP_MEANING(
                           G_OKL_INV_PRIMARY_PURPOSES, only_one_as_primary_rec.purpose )
                         || ',';
   END LOOP;
   l_purpose_list := rtrim( l_purpose_list,',' );
   IF( length(l_purpose_list) > 0 )
   THEN
       put_messages_in_table(     G_OKL_ST_STRM_ONE_PRI_PURPOSE
                                    ,p_during_upd_flag
                                    ,l_message
                                    ,p_token1 => G_PURPOSE_TOKEN
                                    ,p_value1 => l_purpose_list
                                );
       l_error_msgs_tbl(l_msgs_count).error_message := l_message;
       l_error_msgs_tbl(l_msgs_count).error_type_code := G_TYPE_ERROR;
       l_error_msgs_tbl(l_msgs_count).error_type_meaning := GET_LOOKUP_MEANING( G_CP_SET_OUTCOME, G_TYPE_ERROR);
       l_msgs_count := l_msgs_count + 1;
   END IF;

   -- All of the following primary purposes must be defined
   l_purpose_list := '';
   FOR okl_mandatory_primary_rec IN inv_mandatory_primary_csr(p_gtt_id)
   LOOP
        l_purpose_list := l_purpose_list ||
                         OKL_ACCOUNTING_UTIL.GET_LOOKUP_MEANING(
                                G_OKL_INV_PRIMARY_PURPOSES, okl_mandatory_primary_rec.purpose )
                         || ',';
   END LOOP;
   l_purpose_list := rtrim( l_purpose_list,',' );
   IF( length(l_purpose_list) > 0 )
   THEN
       put_messages_in_table(  G_OKL_ST_MANDATORY_PRI_PURPOSE
                                   ,p_during_upd_flag
                                   ,l_message
                                   ,p_token1 => G_PURPOSE_TOKEN
                                   ,p_value1 => l_purpose_list
                                 );
       l_error_msgs_tbl(l_msgs_count).error_message := l_message;
       l_error_msgs_tbl(l_msgs_count).error_type_code := G_TYPE_ERROR;
       l_error_msgs_tbl(l_msgs_count).error_type_meaning := GET_LOOKUP_MEANING( G_CP_SET_OUTCOME, G_TYPE_ERROR);
       l_msgs_count := l_msgs_count + 1;
   END IF;
   x_error_msgs_tbl := l_error_msgs_tbl;
   x_return_status := l_return_status;
EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (l_api_name,
       G_PKG_NAME,
       'OKL_API.G_RET_STS_ERROR',
       x_msg_count,
       x_msg_data,
       '_PVT');
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      ( l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT');
    WHEN OTHERS THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      ( l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT');
end validate_investor_template;



 ---------------------------------------------------------------------------
  -- PROCEDURE activate_template
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : activate_template
  -- Description     : Activate a Template
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
Procedure activate_template(
                    p_api_version             IN  NUMBER
                    ,p_init_msg_list           IN  VARCHAR2 DEFAULT Okc_Api.G_FALSE
                    ,x_return_status           OUT NOCOPY VARCHAR2
                    ,x_msg_count               OUT NOCOPY NUMBER
                    ,x_msg_data                OUT NOCOPY VARCHAR2
		            ,p_gtt_id                  IN  okl_st_gen_templates.id%type
      )IS

    l_gtt_id            okl_st_gen_templates.id%type := p_gtt_id;
    l_api_name          CONSTANT VARCHAR2(40) := 'create_strm_gen_template';
    l_api_version       CONSTANT NUMBER       := 1.0;
    l_return_status     VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;

    l_init_msg_list     VARCHAR2(1);
    l_msg_count         NUMBER;
    l_msg_data          VARCHAR2(2000);
    l_dummy VARCHAR2(1) := okl_api.G_FALSE;
    l_gttv_rec_in       gttv_rec_type;
    l_gttv_rec_out      gttv_rec_type;

    CURSOR okl_st_gen_templates_csr(p_gtt_id IN OKL_ST_GEN_TEMPLATES.id%type) IS
    SELECT   ID
        ,GTS_ID
        ,VERSION
        ,START_DATE
        ,END_DATE
        ,TMPT_STATUS
    FROM OKL_ST_GEN_TEMPLATES
    where ID = p_gtt_id;
BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    l_return_status := OKL_API.START_ACTIVITY( l_api_name
                                             ,g_pkg_name
                                             ,p_init_msg_list
                                             ,l_api_version
                                             ,p_api_version
                                             ,'_PVT'
                                             ,x_return_status);
   IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
   ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
   END IF;

   l_dummy := Okl_Api.G_FALSE;
   FOR gttv_rec_temp IN okl_st_gen_templates_csr(l_gtt_id)
   LOOP
        l_gttv_rec_in.id := gttv_rec_temp.id;
        l_gttv_rec_in.gts_id := gttv_rec_temp.gts_id;
        l_gttv_rec_in.version := gttv_rec_temp.version;
        l_gttv_rec_in.start_date := gttv_rec_temp.start_date;
        l_gttv_rec_in.end_date := gttv_rec_temp.end_date;
        l_gttv_rec_in.tmpt_status := gttv_rec_temp.tmpt_status;
        l_dummy := Okl_Api.G_TRUE;
   END LOOP;

   IF (l_dummy = okl_api.g_false) THEN
         okl_api.SET_MESSAGE(   p_app_name     => g_app_name,
                                p_msg_name     => g_invalid_value,
                                p_token1       => g_col_name_token,
                                p_token1_value => 'GTT_ID');
         RAISE OKL_API.G_EXCEPTION_ERROR;
   END IF;

   -- Validations checked until now
   -- 1. Template status should be 'COMPLETE'
   IF ( l_gttv_rec_in.tmpt_status = G_STATUS_COMPLETE )
   THEN
       l_gttv_rec_in.tmpt_status := G_STATUS_ACTIVE;
       okl_gtt_pvt.update_row(
            p_api_version => l_api_version
            ,p_init_msg_list  => p_init_msg_list
            ,x_return_status => l_return_status
            ,x_msg_count => l_msg_count
            ,x_msg_data => l_msg_data
            ,p_gttv_rec => l_gttv_rec_in
            ,x_gttv_rec => l_gttv_rec_out
       );
       IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;
   ELSE
       -- Show a message saying that template status is not complete
       okl_api.SET_MESSAGE(   p_app_name     => g_app_name,
                                p_msg_name     => g_invalid_value,
                                p_token1       => g_col_name_token,
                                p_token1_value => 'TMPT_STATUS');
        RAISE OKL_API.G_EXCEPTION_ERROR;
   END IF;
   x_return_status := l_return_status;
   OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (l_api_name,
       G_PKG_NAME,
       'OKL_API.G_RET_STS_ERROR',
       x_msg_count,
       x_msg_data,
       '_PVT');
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      ( l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT');
    WHEN OTHERS THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      ( l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT');
END;

---------------------------------------------------------------------------
  -- PROCEDURE validate_mandatory_dep
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : validate_for_warnings
  -- Description     : Validates the SGT for any warnings
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
Procedure validate_mandatory_dep(
                    p_api_version             IN  NUMBER
                    ,p_init_msg_list           IN  VARCHAR2 DEFAULT Okc_Api.G_FALSE
                    ,x_return_status           OUT NOCOPY VARCHAR2
                    ,x_msg_count               OUT NOCOPY NUMBER
                    ,x_msg_data                OUT NOCOPY VARCHAR2
		            ,p_gtt_id                  IN  okl_st_gen_templates.id%type
		            ,p_pri_sty_id              IN  okl_st_gen_tmpt_lns.primary_Sty_id%type
		            ,x_missing_deps            OUT NOCOPY VARCHAR2
		            ,x_show_warn_flag          OUT NOCOPY VARCHAR2
		            ,p_deal_type               IN  VARCHAR2
     )IS
    l_gtt_id            okl_st_gen_templates.id%type := p_gtt_id;
    l_api_name          CONSTANT VARCHAR2(40) := 'validate_mandatory_dep';
    l_api_version       CONSTANT NUMBER       := 1.0;
    l_return_status     VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;

    l_purpose_list VARCHAR2(10000);
   -- Cursor to fetch the missed dependent streams for a Primary Stream type
   -- with purpose as 'Fee Payment'
    CURSOR fee_payment_man_dep_csr( p_gtt_id IN OKL_ST_GEN_TEMPLATES.id%type
                                   ,p_pri_sty_id IN OKL_ST_GEN_TMPT_LNS.primary_sty_id%TYPE
                                   ,p_exclude_fr IN VARCHAR2 ) IS
    SELECT LOOKUP_CODE PURPOSE
    FROM   FND_LOOKUPS
    WHERE LOOKUP_TYPE = G_OKL_FIN_DEPENDENT_PURPOSES
    AND LOOKUP_CODE IN
    (
        'AMORTIZE_FEE_INCOME'
        ,'ACCRUED_FEE_INCOME'
        ,'PRINCIPAL_PAYMENT'
        ,'INTEREST_PAYMENT'
        ,'PRINCIPAL_BALANCE'
        ,'INTEREST_INCOME'
        ,'LOAN_PAYMENT'
        ,'FEE_RENEWAL'
        ,'PASS_THRU_REV_ACCRUAL'
        ,'PASS_THRU_EXP_ACCRUAL'
    )
    MINUS
    (
        SELECT  STB.STREAM_TYPE_PURPOSE PURPOSE
        FROM    OKL_ST_GEN_TMPT_LNS GTL
               ,OKL_STRM_TYPE_B STB
        WHERE   GTL.GTT_ID = p_gtt_id
         AND   GTL.PRIMARY_YN = 'N'
         AND   GTL.DEPENDENT_STY_ID = STB.ID
         AND   GTL.PRIMARY_STY_ID = p_pri_sty_id
    )
    MINUS
    (
        SELECT 'FEE_RENEWAL' PURPOSE
        FROM DUAL
        WHERE p_exclude_fr = 'T'
    );
    l_exclude_fr VARCHAR2(1) := OKL_API.G_TRUE;
BEGIN
   l_return_status := OKL_API.G_RET_STS_SUCCESS;

   x_show_warn_flag := OKL_API.G_FALSE;
   l_purpose_list := '';
   IF ( belongs_to_ls(p_deal_type) = TRUE )
   THEN
        l_exclude_fr := 'F';
   END IF;
   FOR fee_payment_man_dep_rec IN fee_payment_man_dep_csr(p_gtt_id,p_pri_sty_id,l_exclude_fr)
   LOOP
        l_purpose_list := l_purpose_list ||
                         OKL_ACCOUNTING_UTIL.GET_LOOKUP_MEANING(
                           G_OKL_FIN_DEPENDENT_PURPOSES, fee_payment_man_dep_rec.purpose )
                         || ',';
        x_show_warn_flag := OKL_API.G_TRUE;
   END LOOP;

   l_purpose_list := rtrim( l_purpose_list,',' );
   x_missing_deps := l_purpose_list;
   x_return_status := l_return_status;
EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (l_api_name,
       G_PKG_NAME,
       'OKL_API.G_RET_STS_ERROR',
       x_msg_count,
       x_msg_data,
       '_PVT');
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      ( l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT');
    WHEN OTHERS THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      ( l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT');
END;

 ---------------------------------------------------------------------------
  -- PROCEDURE validate_for_warnings
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : validate_for_warnings
  -- Description     : Validates the SGT for any warnings
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
Procedure validate_for_warnings(
                    p_api_version             IN   NUMBER
                    ,p_init_msg_list           IN  VARCHAR2 DEFAULT Okc_Api.G_FALSE
                    ,x_return_status           OUT NOCOPY VARCHAR2
                    ,x_msg_count               OUT NOCOPY NUMBER
                    ,x_msg_data                OUT NOCOPY VARCHAR2
		            ,p_gtt_id                  IN  okl_st_gen_templates.id%type
		            ,x_wrn_msgs_tbl            OUT NOCOPY error_msgs_tbl_type
		            ,p_during_upd_flag         IN  VARCHAR
		            ,x_pri_purpose_list        OUT NOCOPY VARCHAR
      )IS

    l_gtt_id            okl_st_gen_templates.id%type := p_gtt_id;
    l_api_name          CONSTANT VARCHAR2(40) := 'validate_for_warnings';
    l_api_version       CONSTANT NUMBER       := 1.0;
    l_return_status     VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_missing_deps      VARCHAR2(10000);
    l_show_warn_flag    VARCHAR2(1) := OKL_API.G_FALSE;
    l_wrn_msgs_tbl      error_msgs_tbl_type;
    l_msgs_count        NUMBER := 1;
    l_message           VARCHAR2(2700);
    l_pri_purpose_list  VARCHAR2(10000);

    -- Cursor to fetch the Primary Stream Types with purpose as 'FEE PAYMENT'
    CURSOR fee_payment_pri_strms_csr( p_gtt_id IN OKL_ST_GEN_TEMPLATES.id%type) IS
    SELECT  GTL.PRIMARY_STY_ID PRI_STY_ID
           ,GTS.DEAL_TYPE DEAL_TYPE
           ,STB.ID STRM_TYPE_ID
           ,STB.CODE STRM_NAME
    FROM    OKL_ST_GEN_TMPT_LNS GTL
           ,OKL_ST_GEN_TMPT_SETS GTS
           ,OKL_ST_GEN_TEMPLATES GTT
           ,OKL_STRM_TYPE_B STB
    WHERE  GTL.GTT_ID = p_gtt_id
     AND   GTL.GTT_ID = GTT.ID
     AND   GTS.ID = GTT.GTS_ID
     AND   GTL.PRIMARY_YN = 'Y'
     AND   GTL.PRIMARY_STY_ID = STB.ID
     AND   STB.STREAM_TYPE_PURPOSE = 'FEE_PAYMENT';
BEGIN
   l_return_status := OKL_API.G_RET_STS_SUCCESS;
   l_pri_purpose_list := '';
   FOR fee_payment_pri_strms_rec IN fee_payment_pri_strms_csr(p_gtt_id)
   LOOP
        validate_mandatory_dep(
                    p_api_version     => p_api_version
                    ,p_init_msg_list  => p_init_msg_list
                    ,x_return_status  => l_return_status
                    ,x_msg_count      => x_msg_count
                    ,x_msg_data       => x_msg_data
		            ,p_gtt_id         => p_gtt_id
		            ,p_pri_sty_id     => fee_payment_pri_strms_rec.strm_type_id
		            ,x_missing_deps   => l_missing_deps
		            ,x_show_warn_flag => l_show_warn_flag
		            ,p_deal_type      => fee_payment_pri_strms_rec.deal_type
        );
        IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
        IF ( l_show_warn_flag <> OKL_API.G_FALSE )
        THEN
           put_messages_in_table( 'OKL_ST_SGT_MAN_DEP_MISSING_WRN'
                                  ,p_during_upd_flag
                                  ,l_message
                                  ,p_token1 => 'PRI_STRM'
                                  ,p_value1 => fee_payment_pri_strms_rec.STRM_NAME
                                  ,p_token2 => 'DEP_STRM'
                                  ,p_value2 => l_missing_deps
             );
            l_wrn_msgs_tbl(l_msgs_count).error_message := l_message;
            l_wrn_msgs_tbl(l_msgs_count).error_type_code := G_TYPE_WARNING;
            l_wrn_msgs_tbl(l_msgs_count).error_type_meaning := GET_LOOKUP_MEANING( G_CP_SET_OUTCOME, G_TYPE_WARNING);
            l_msgs_count := l_msgs_count + 1;
            l_pri_purpose_list := l_pri_purpose_list ||
                                  fee_payment_pri_strms_rec.STRM_NAME ||
                                  ',';
        END IF;
   END LOOP;

   x_wrn_msgs_tbl := l_wrn_msgs_tbl;
   x_pri_purpose_list := rtrim( l_pri_purpose_list,',' );
   x_return_status := l_return_status;
EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (l_api_name,
       G_PKG_NAME,
       'OKL_API.G_RET_STS_ERROR',
       x_msg_count,
       x_msg_data,
       '_PVT');
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      ( l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT');
    WHEN OTHERS THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      ( l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT');
END;
  ---------------------------------------------------------------------------
  -- PROCEDURE validate_template
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : validate_template
  -- Description     : Validates a Stream Generation Template
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------

Procedure validate_template(
                    p_api_version             IN  NUMBER
                    ,p_init_msg_list           IN  VARCHAR2 DEFAULT Okc_Api.G_FALSE
                    ,x_return_status           OUT NOCOPY VARCHAR2
                    ,x_msg_count               OUT NOCOPY NUMBER
                    ,x_msg_data                OUT NOCOPY VARCHAR2
		            ,p_gtt_id                  IN  okl_st_gen_templates.id%type
		            ,x_error_msgs_tbl          OUT NOCOPY error_msgs_tbl_type
		            ,x_return_tmpt_status      OUT NOCOPY VARCHAR2
		            ,p_during_upd_flag         IN  VARCHAR2
      )IS
    l_gtt_id            okl_st_gen_templates.id%type := p_gtt_id;
    l_api_name          CONSTANT VARCHAR2(40) := 'validate_template';
    l_api_version       CONSTANT NUMBER       := 1.0;
    l_return_status     VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_error_msgs_tbl    error_msgs_tbl_type;
    l_wrn_msgs_tbl    error_msgs_tbl_type;

    l_init_msg_list     VARCHAR2(1);
    l_msg_count         NUMBER;
    l_msg_data          VARCHAR2(2000);

    l_dummy VARCHAR2(1) := okl_api.G_FALSE;
    l_pri_purpose_list VARCHAR2(2000);

    l_gttv_rec_in   gttv_rec_type;
    l_gttv_rec_out  gttv_rec_type;

    CURSOR okl_st_gen_templates_csr(p_gtt_id IN OKL_ST_GEN_TEMPLATES.id%type) IS
    SELECT   GTT.ID       ID
            ,GTT.GTS_ID       GTS_ID
            ,GTS.NAME         NAME
            ,GTS.PRODUCT_TYPE PRODUCT_TYPE
            ,GTS.DEAL_TYPE    DEAL_TYPE
            ,GTT.START_DATE   START_DATE
            ,GTT.END_DATE     END_DATE
            ,GTT.TMPT_STATUS  TMPT_STATUS
            ,GTT.VERSION      VERSION
    FROM  OKL_ST_GEN_TEMPLATES GTT
         ,OKL_ST_GEN_TMPT_SETS GTS
    WHERE GTT.GTS_ID = GTS.ID
      AND GTT.ID = p_gtt_id;
    l_tmpt_set_rec okl_st_gen_templates_csr%ROWTYPE;
BEGIN
    -- Perform the Initializations
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    l_return_status := OKL_API.START_ACTIVITY( l_api_name
                                             ,g_pkg_name
                                             ,p_init_msg_list
                                             ,l_api_version
                                             ,p_api_version
                                             ,'_PVT'
                                             ,x_return_status);
   IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
   ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
   END IF;
   l_dummy := Okl_Api.G_FALSE;
   FOR gttv_rec_temp IN okl_st_gen_templates_csr(l_gtt_id)
   LOOP
        l_tmpt_set_rec.id := gttv_rec_temp.id;
        l_tmpt_set_rec.gts_id := gttv_rec_temp.gts_id;
        l_tmpt_set_rec.start_date := gttv_rec_temp.start_date;
        l_tmpt_set_rec.end_date := gttv_rec_temp.end_date;
        l_tmpt_set_rec.tmpt_status := gttv_rec_temp.tmpt_status;
        l_tmpt_set_rec.deal_type := gttv_rec_temp.deal_type;
        l_tmpt_set_rec.product_type := gttv_rec_temp.product_type;
        l_tmpt_set_rec.version := gttv_rec_temp.version;
        l_dummy := Okl_Api.G_TRUE;
   END LOOP;
   IF (l_dummy = okl_api.g_false) THEN
         okl_api.SET_MESSAGE(   p_app_name     => g_app_name,
                                p_msg_name     => g_invalid_value,
                                p_token1       => g_col_name_token,
                                p_token1_value => 'GTT_ID');
         RAISE OKL_API.G_EXCEPTION_ERROR;
   END IF;
   -- If the Product Type is INVESTOR call the validate_investor_template api
   IF ( l_tmpt_set_rec.product_type = G_INVESTOR_PRODUCT )
   THEN
       -- Validate the Investor Template
       validate_investor_template(
                     1.0
                    ,'T'
                    ,l_return_status
                    ,x_msg_count
                    ,x_msg_data
		            ,l_gtt_id
		            ,l_error_msgs_tbl
		            ,p_during_upd_flag  );
   ELSE
       -- Validate the Financial Template
       validate_financial_template(
                     1.0
                    ,'T'
                    ,l_return_status
                    ,x_msg_count
                    ,x_msg_data
		            ,l_gtt_id
		            ,l_error_msgs_tbl
		            ,p_during_upd_flag
                    ,l_tmpt_set_rec.deal_type);
   END IF;
   IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
   ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
   END IF;
   -- Update the template status based on the x_return_status
   -- or l_error_msgs_tbl.COUNT
   l_gttv_rec_in.id := l_tmpt_set_rec.id;
   l_gttv_rec_in.gts_id := l_tmpt_set_rec.gts_id;
   l_gttv_rec_in.version := l_tmpt_set_rec.version;
   l_gttv_rec_in.start_date := l_tmpt_set_rec.start_date;
   l_gttv_rec_in.end_date := l_tmpt_set_rec.end_date;
   -- Determine the status of the Template after the Validation
   IF  ( l_error_msgs_tbl.COUNT IS NULL OR
          l_error_msgs_tbl.COUNT = 0 )
   THEN
       -- When the status of the template getting updated is Active, after
       -- successful validation , the status remains at Active.
       IF (l_tmpt_set_rec.tmpt_status = G_STATUS_ACTIVE)
       THEN
         l_gttv_rec_in.tmpt_status := G_STATUS_ACTIVE;
       ELSE
         -- In all other cases the Template status should be COMPLETE
         l_gttv_rec_in.tmpt_status := G_STATUS_COMPLETE;
       END IF;
   ELSE
       -- Change the template status to INCOMPLETE
       -- Note there is not status as INCOMPLETE available as of now.
       IF (l_tmpt_set_rec.tmpt_status = G_STATUS_ACTIVE)
       THEN
         l_gttv_rec_in.tmpt_status := G_STATUS_ACTIVE;
       ELSE
         -- In all other cases the Template status should be INCOMPLETE
         l_gttv_rec_in.tmpt_status := G_STATUS_INCOMPLETE;
       END IF;
   END IF;
   -- Call the update method of the Stream Generation Template
   okl_gtt_pvt.update_row(
        p_api_version => l_api_version
        ,p_init_msg_list  => p_init_msg_list
        ,x_return_status => l_return_status
        ,x_msg_count => x_msg_count
        ,x_msg_data => x_msg_data
        ,p_gttv_rec => l_gttv_rec_in
        ,x_gttv_rec => l_gttv_rec_out
   );
   IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
   ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
   END IF;
   -- Call the validate_for_Warnings only when
   -- a. If the template is Financial, and its not during Update mode
   IF (  p_during_upd_flag = OKL_API.G_FALSE
     AND l_tmpt_set_rec.product_type <>  G_INVESTOR_PRODUCT )
   THEN
        validate_for_warnings(
                    p_api_version       => p_api_version
                    ,p_init_msg_list    => p_init_msg_list
                    ,x_return_status    => l_return_status
                    ,x_msg_count        => x_msg_count
                    ,x_msg_data         => x_msg_data
		            ,p_gtt_id           => l_gtt_id
		            ,x_wrn_msgs_tbl     => l_wrn_msgs_tbl
		            ,p_during_upd_flag  => OKL_API.G_FALSE
		            ,x_pri_purpose_list => l_pri_purpose_list
        );
       IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;
       -- Add the messages to the errors table
       l_msg_count := l_error_msgs_tbl.COUNT;
       IF ( l_wrn_msgs_tbl.COUNT > 0 )
       THEN
           FOR i in l_wrn_msgs_tbl.FIRST .. l_wrn_msgs_tbl.LAST
           LOOP
                l_msg_count := l_msg_count + 1;
                l_error_msgs_tbl( l_msg_count ).error_message := l_wrn_msgs_tbl(i).error_message;
                l_error_msgs_tbl( l_msg_count ).error_type_code := l_wrn_msgs_tbl(i).error_type_code;
                l_error_msgs_tbl( l_msg_count ).error_type_meaning := l_wrn_msgs_tbl(i).error_type_meaning;
           END LOOP;
        END IF;
   END IF;
   x_error_msgs_tbl := l_error_msgs_tbl;
   x_return_tmpt_status := l_gttv_rec_out.tmpt_status;
   x_return_status := l_return_status;
   OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (l_api_name,
       G_PKG_NAME,
       'OKL_API.G_RET_STS_ERROR',
       x_msg_count,
       x_msg_data,
       '_PVT');
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      ( l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT');
    WHEN OTHERS THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      ( l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT');
END validate_template;

 ---------------------------------------------------------------------------
  -- PROCEDURE update_dep_strms
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : update_dep_strms
  -- Description     : Update Dependent Streams of a Template
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------

  Procedure update_dep_strms(
                     p_api_version             IN  NUMBER
                    ,p_init_msg_list           IN  VARCHAR2 DEFAULT Okc_Api.G_FALSE
                    ,x_return_status           OUT NOCOPY VARCHAR2
                    ,x_msg_count               OUT NOCOPY NUMBER
                    ,x_msg_data                OUT NOCOPY VARCHAR2
                    ,p_gtt_id                  IN  OKL_ST_GEN_TEMPLATES.ID%type
                    ,p_pri_sty_id              IN  OKL_ST_GEN_TMPT_LNS.PRIMARY_STY_ID%TYPE
                    ,p_gtlv_tbl                IN  gtlv_tbl_type
                    ,x_missing_deps            OUT NOCOPY VARCHAR2
                    ,x_show_warn_flag          OUT NOCOPY VARCHAR2
      )IS
    l_api_name          CONSTANT VARCHAR2(40) := 'update_dep_strms';
    l_api_version       CONSTANT NUMBER       := 1.0;
    l_return_status     VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;

    l_init_msg_list     VARCHAR2(1);
    l_msg_count         NUMBER;
    l_msg_data          VARCHAR2(2000);

    l_gttv_rec_in      gttv_rec_type;
    l_gtlv_tbl_upd_in  gtlv_tbl_type;
    l_gtlv_tbl_ins_in  gtlv_tbl_type;

    l_gttv_rec_out      gttv_rec_type;
    l_gtlv_tbl_upd_out  gtlv_tbl_type;
    l_gtlv_tbl_ins_out  gtlv_tbl_type;
    i               NUMBER;
    ins_table_count NUMBER;
    upd_table_count NUMBER;

    --Added by bkatraga on 05-Apr-2005
    l_error_msgs_tbl        error_msgs_tbl_type;
    l_return_tmpt_status    OKL_ST_GEN_TEMPLATES.TMPT_STATUS%TYPE;
    --end changes

    -- Modified by RGOOTY
    -- Bug 4054596: Issue No. 5: Start
    CURSOR okl_dep_purpose_dup_csr( p_gtt_id IN OKL_ST_GEN_TEMPLATES.id%TYPE
                                     ,p_pri_id IN OKL_ST_GEN_TMPT_LNS.primary_Sty_id%TYPE) IS
    SELECT STY.STREAM_TYPE_PURPOSE PURPOSE_CODE,
       ( SELECT MEANING FROM
         FND_LOOKUPS
         WHERE LOOKUP_TYPE = 'OKL_STREAM_TYPE_PURPOSE'
          AND  LOOKUP_CODE = STY.STREAM_TYPE_PURPOSE
        ) PURPOSE_MEANING,
       COUNT( STY.STREAM_TYPE_PURPOSE) streams_count
    FROM OKL_ST_GEN_TMPT_LNS GTL
        ,okl_Strm_Type_b STY
    WHERE GTL.DEPENDENT_STY_ID = STY.ID
     AND  PRIMARY_YN = 'N'
     AND  GTL.GTT_ID = p_gtt_id
     AND  GTL.PRIMARY_STY_ID = p_pri_id
    GROUP BY STY.STREAM_TYPE_PURPOSE
    HAVING COUNT( STREAM_TYPE_PURPOSE) > 1;

    l_found         VARCHAR2(1) := OKL_API.G_FALSE;
    l_gtt_id        OKL_ST_GEN_TMPT_LNS.GTT_ID%TYPE;
    l_pri_sty_id    OKL_ST_GEN_TMPT_LNS.PRIMARY_STY_ID%TYPE;
    l_purp_list     VARCHAR2(250);
    -- Bug 4054596: Issue No. 5: End

    l_tmpt_status       OKL_ST_GEN_TEMPLATES.TMPT_STATUS%TYPE;
    l_deal_type         OKL_ST_GEN_TMPT_SETS.DEAL_TYPE%TYPE;

    CURSOR tmpt_det_csr( p_gtt_id OKL_ST_GEN_TEMPLATES.ID%TYPE ) IS
    SELECT GTS.DEAL_TYPE    DEAL_TYPE
          ,GTT.TMPT_STATUS  TMPT_STATUS
          ,GTS.ID           GTS_ID  -- Bug 4094361, Modified by RGOOTY
    FROM  OKL_ST_GEN_TMPT_SETS GTS
         ,OKL_ST_GEN_TEMPLATES GTT
    WHERE GTS.ID = GTT.GTS_ID
     AND  GTT.ID = p_gtt_id;

    CURSOR tmpt_pri_strm_det_csr( p_gtt_id OKL_ST_GEN_TEMPLATES.ID%TYPE
                                 ,p_pri_sty_id OKL_ST_GEN_TMPT_LNS.PRIMARY_STY_ID%TYPE)
    IS
        SELECT STY.STREAM_TYPE_PURPOSE PRI_STRM_PURPOSE
        FROM  OKL_ST_GEN_TMPT_LNS GTL
             ,OKL_STRM_TYPE_B     STY
        WHERE STY.ID = GTL.PRIMARY_sTY_ID
         AND GTL.PRIMARY_YN = 'Y'
         AND GTL.GTT_ID = p_gtt_id
         AND GTL.PRIMARY_STY_ID = p_pri_sty_id;

   l_missing_deps    VARCHAR2(10000) := OKL_API.G_MISS_CHAR;
   l_show_warn_flag  VARCHAR2(1):= OKL_API.G_FALSE;
   l_pri_strm_purpose OKL_STRM_TYPE_B.STREAM_TYPE_PURPOSE%TYPE;

   -- Modified by RGOOTY
   -- Bug 4094361: Start
   CURSOR pdt_for_active_sgt_csr(  p_gts_id OKL_ST_GEN_TMPT_SETS.ID%TYPE )
   IS
    SELECT  PDT.ID PDT_ID
           ,PRODUCT_STATUS_CODE
    FROM OKL_PRODUCTS PDT,
         OKL_AE_TMPT_SETS ATS, OKL_ST_GEN_TMPT_SETS SGT
    WHERE PDT.AES_ID = ATS.ID
      AND ATS.GTS_ID = SGT.ID
      AND SGT.ID = p_gts_id;

    l_sgt_set_id OKL_ST_GEN_TMPT_SETS.ID%TYPE;
   -- Bug 4094361: End
BEGIN
    -- Perform the Initializations
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    l_return_status := OKL_API.START_ACTIVITY( l_api_name
                                             ,g_pkg_name
                                             ,p_init_msg_list
                                             ,l_api_version
                                             ,p_api_version
                                             ,'_PVT'
                                             ,x_return_status);
   IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
   ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
   END IF;
   -- Updating/Inserting the Template Lines
   IF (p_gtlv_tbl.COUNT > 0) THEN
      ins_table_count :=0;
      upd_table_count :=0;
      FOR i IN p_gtlv_tbl.FIRST .. p_gtlv_tbl.LAST
      LOOP
        -- Decide whether we need to update or insert the Template Lines.
        IF (p_gtlv_tbl(i).id = Okl_Api.G_MISS_NUM OR p_gtlv_tbl(i).id IS NULL
             OR p_gtlv_tbl(i).id = 0 )
        THEN
           -- Copy into the Insert table
           l_gtlv_tbl_ins_in(ins_table_count) := p_gtlv_tbl(i);
           ins_table_count := ins_table_count + 1;
        ELSE
           -- Copy into the Update table
           l_gtlv_tbl_upd_in(upd_table_count) := p_gtlv_tbl(i);
           upd_table_count := upd_table_count + 1;
        END IF;
      END LOOP;
      IF (l_gtlv_tbl_ins_in.COUNT > 0 )
      THEN
          -- Call the TAPI Procedcure to perform the actual inserts
          okl_gtl_pvt.insert_row(
                p_api_version   => l_api_version
                ,p_init_msg_list => p_init_msg_list
                ,x_return_status => l_return_status
                ,x_msg_count => l_msg_count
                ,x_msg_data => l_msg_data
                ,p_gtlv_tbl => l_gtlv_tbl_ins_in
                ,x_gtlv_tbl => l_gtlv_tbl_ins_out
          );
          IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;
      END IF;
      IF (l_gtlv_tbl_upd_in.count > 0 )
      THEN
          -- Call the TAPI Procedcure to perform the actual updates
          okl_gtl_pvt.update_row(
                p_api_version   => l_api_version
                ,p_init_msg_list => p_init_msg_list
                ,x_return_status => l_return_status
                ,x_msg_count => l_msg_count
                ,x_msg_data => l_msg_data
                ,p_gtlv_tbl => l_gtlv_tbl_upd_in
                ,x_gtlv_tbl => l_gtlv_tbl_upd_out
          );
          IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;
      END IF;
   END IF;
   /*

   -- Modified by RGOOTY
   -- Bug 4054596: Issue No. 5: Start
   l_found := OKL_API.G_FALSE;
   l_gtt_id := p_gtt_id;--p_gtlv_tbl( p_gtlv_tbl.FIRST ).gtt_id;
   l_pri_sty_id := p_pri_sty_id; --p_gtlv_tbl( p_gtlv_tbl.FIRST).primary_sty_id;
   l_purp_list := '';
   FOR okl_dep_dup_rec In okl_dep_purpose_dup_csr( l_gtt_id, l_pri_sty_id )
   LOOP
        l_found := OKL_API.G_TRUE;
        l_purp_list := l_purp_list || okl_dep_dup_rec.purpose_meaning || ',';
   END LOOP;
   IF (l_found = Okl_Api.G_TRUE) THEN
        l_purp_list := RTRIM( l_purp_list,',' );
        Okl_Api.SET_MESSAGE(   p_app_name     => g_app_name,
                                p_msg_name     => 'OKL_ST_SGT_DUP_DEP_PURPOSE',
                                p_token1       => 'TEXT',
                                p_token1_value => l_purp_list);
        l_return_status := Okl_Api.G_RET_STS_ERROR;
        RAISE Okl_Api.G_EXCEPTION_ERROR;
   END IF;
   -- Bug 4054596: Issue No. 5: End

    IF( p_gtt_id IS NOT NULL AND p_gtt_id <> OKL_API.G_MISS_NUM AND
        p_pri_sty_id IS NOT NULL AND p_pri_sty_id <> OKL_API.G_MISS_NUM )
    THEN
        FOR tmpt_det_rec IN tmpt_det_csr( p_gtt_id )
        LOOP
            l_deal_type   := tmpt_det_rec.deal_type;
            l_tmpt_status := tmpt_det_rec.tmpt_status;
            l_sgt_set_id     := tmpt_det_rec.gts_id;
        END LOOP;

	    -- Modified by RGOOTY
            -- Bug 4094361: Start
	    -- Need to invalidate all the products which use this Active SGT.
        IF ( l_tmpt_status = G_STATUS_ACTIVE )
        THEN

            -- Added by bkatraga on 05-Apr-2005
                -- Validating the SGT
                validate_template(
                            p_api_version          => l_api_version
                            ,p_init_msg_list       => p_init_msg_list
                            ,x_return_status       => l_return_status
                            ,x_msg_count           => l_msg_count
                            ,x_msg_data            => l_msg_data
	        	    ,p_gtt_id              => p_gtt_id
                	    ,x_error_msgs_tbl      => l_error_msgs_tbl
        	            ,x_return_tmpt_status  => l_return_tmpt_status
        		    ,p_during_upd_flag     => 'T'
                          );
                IF ( l_error_msgs_tbl.count > 0 )
                THEN
                    x_return_status := Okl_Api.G_RET_STS_ERROR;
                    RAISE Okl_Api.G_EXCEPTION_ERROR;
                END If;
            -- end changes by bkatraga

            FOR pdt_rec IN pdt_for_active_sgt_csr( l_sgt_set_id )
            LOOP
                OKL_SETUPPRODUCTS_PVT.update_product_status(
                    p_api_version     => p_api_version,
                    p_init_msg_list   => p_init_msg_list,
                    x_return_status   => l_return_Status,
                    x_msg_count       => x_msg_count,
                    x_msg_data        => x_msg_data,
                    p_pdt_status      => OKL_SETUPPRODUCTS_PVT.G_PDT_STS_INVALID,
                    p_pdt_id          => pdt_rec.pdt_id  );
                IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                    RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
                    RAISE OKL_API.G_EXCEPTION_ERROR;
                END IF;
            END LOOP;
            -- Bug 4094361: End
        END IF;
        l_pri_strm_purpose := '';
        FOR tmpt_pri_strm_det_rec IN tmpt_pri_strm_det_csr( p_gtt_id,p_pri_sty_id)
        LOOP
            l_pri_strm_purpose := tmpt_pri_strm_det_rec.pri_strm_purpose;
        END LOOP;

        IF ( l_tmpt_status = G_STATUS_ACTIVE AND l_pri_strm_purpose = 'FEE_PAYMENT' )
        THEN
            validate_mandatory_dep(
                         p_api_version     => p_api_version
                        ,p_init_msg_list   => p_init_msg_list
                        ,x_return_status   => l_return_status
                        ,x_msg_count       => x_msg_count
                        ,x_msg_data        => x_msg_data
    		            ,p_gtt_id          => p_gtt_id
    		            ,p_pri_sty_id      => p_pri_sty_id
    		            ,x_missing_deps    => l_missing_deps
    		            ,x_show_warn_flag  => l_show_warn_flag
    		            ,p_deal_type       => l_deal_type
            );
            IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;
            x_missing_deps := l_missing_deps;
            x_show_warn_flag := l_show_warn_flag;

       END IF;
    END IF;
   */
   x_return_status := l_return_status;
   OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (l_api_name,
       G_PKG_NAME,
       'OKL_API.G_RET_STS_ERROR',
       x_msg_count,
       x_msg_data,
       '_PVT');
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      ( l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT');
    WHEN OTHERS THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      ( l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT');
END;

  ------------------------------------------------------------------------------------
  -- This API does the following:
  -- 1/ Updates the SGT Set, Version, Pricing Params Info and Primary Stream Types
  -- 2/ Deletes the Dependents, if needed
  -- 3/ Updates/Inserts the Dependants for all Primary
  -- 4/ If Template is in Active Status, Validates it, if any errors found, rollbacks
  --     the entire stuff
  -- 5/ If no validation errors found, proceeds checking the Warnings,
  --     If errors found pushes the warning message onto the FND Stack,
  --       but doesnot rollback
  -- 6/ Updates all the products which use the current SGT, to INVALID status
  ------------------------------------------------------------------------------------
  PROCEDURE update_pri_dep_of_sgt(
              p_api_version             IN  NUMBER
             ,p_init_msg_list           IN  VARCHAR2 DEFAULT Okc_Api.G_FALSE
             ,x_return_status           OUT NOCOPY VARCHAR2
             ,x_msg_count               OUT NOCOPY NUMBER
             ,x_msg_data                OUT NOCOPY VARCHAR2
             ,p_gtsv_rec                IN  gtsv_rec_type
             ,p_gttv_rec                IN  gttv_rec_type
             ,p_gtpv_tbl                IN  gtpv_tbl_type
             ,p_pri_gtlv_tbl            IN  gtlv_tbl_type
             ,p_del_dep_gtlv_tbl        IN  gtlv_tbl_type
             ,p_ins_dep_gtlv_tbl        IN  gtlv_tbl_type
             ,x_gttv_rec                OUT NOCOPY gttv_rec_type
             ,x_pri_purpose_list        OUT NOCOPY VARCHAR2)
  IS
    -- Cursor to fetch the Stream Generation Template Set ID
   CURSOR fetch_gts_id_csr(  p_gtt_id OKL_ST_GEN_TEMPLATES.ID%TYPE )
   IS
    SELECT  GTT.GTS_ID
     FROM   OKL_ST_GEN_TEMPLATES GTT
      WHERE   GTT.ID = p_gtt_id;
   -- Cursor to get the Dependent Stream Purpose Meaning which has been included more than once
   --   for a particular primary Stream
   CURSOR okl_dep_purpose_dup_csr( p_gtt_id IN OKL_ST_GEN_TEMPLATES.id%TYPE )
   IS
    SELECT  STYP.CODE   PRI_STRM_TYPE_NAME,
    -- gboomina Bug 4874272 - Added - Start
            STYP.STREAM_TYPE_PURPOSE PRI_STRM_TYPE_PURPOSE,
    -- gboomina Bug 4874272 - Added - End
            STY.STREAM_TYPE_PURPOSE DEP_PURPOSE_CODE,
            ( SELECT MEANING
               FROM FND_LOOKUPS
              WHERE LOOKUP_TYPE = 'OKL_STREAM_TYPE_PURPOSE'
               AND  LOOKUP_CODE = STY.STREAM_TYPE_PURPOSE
            ) DEP_PURPOSE_MEANING,
            COUNT( STY.STREAM_TYPE_PURPOSE) streams_count
    FROM  OKL_ST_GEN_TMPT_LNS GTL
         ,OKL_ST_GEN_TMPT_LNS GTLP
         ,OKL_STRM_TYPE_B STY
         ,OKL_STRM_TYPE_B STYP
    WHERE GTL.DEPENDENT_STY_ID = STY.ID
     AND  GTLP.PRIMARY_STY_ID = STYP.ID
     AND  GTL.PRIMARY_YN = 'N'
     AND  GTLP.PRIMARY_YN = 'Y'
     AND  GTLP.primary_sty_id = GTL.primary_sty_id
     AND  GTL.GTT_ID = p_gtt_id
     AND  GTLP.GTT_ID = p_gtt_id
    -- gboomina Bug 4874272 - Added STREAM_TYPE_PURPOSE in Group by - Start
    GROUP BY STYP.STREAM_TYPE_PURPOSE, STYP.CODE, STY.STREAM_TYPE_PURPOSE
    -- gboomina Bug 4874272 - Added STREAM_TYPE_PURPOSE in Group by - End
    HAVING COUNT( STY.STREAM_TYPE_PURPOSE) > 1;
    -- Cursor to fetch all the products which uses this SGT
    CURSOR pdt_for_active_sgt_csr(  p_gts_id OKL_ST_GEN_TMPT_SETS.ID%TYPE )
    IS
     SELECT PDT.ID PDT_ID
           ,PRODUCT_STATUS_CODE
     FROM  OKL_PRODUCTS PDT,
           OKL_AE_TMPT_SETS ATS,
           OKL_ST_GEN_TMPT_SETS SGT
     WHERE PDT.AES_ID = ATS.ID
       AND ATS.GTS_ID = SGT.ID
       AND SGT.ID = p_gts_id;

    l_api_name          CONSTANT VARCHAR2(40) := 'update_pri_dep_of_sgt';
    l_api_version       CONSTANT NUMBER       := 1.0;
    l_return_status     VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    -- Local Variables Declaration
    l_missing_deps            VARCHAR2(10000);
    l_show_warn_flag          VARCHAR2(30);
    l_error_msgs_tbl          error_msgs_tbl_type;
    l_return_tmpt_status      OKL_ST_GEN_TEMPLATES.TMPT_STATUS%TYPE;
    l_sgt_set_id              OKL_ST_GEN_TMPT_SETS.ID%TYPE;
    l_pri_purpose_list        VARCHAR2(10000);
    l_found                   VARCHAR2(30);
    l_msg                     VARCHAR2(10000);
    l_pri_stream_name         OKL_STRM_TYPE_B.CODE%TYPE;
    l_dep_purp_list           VARCHAR2(10000);
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    l_return_status := OKL_API.START_ACTIVITY( l_api_name
                                             ,g_pkg_name
                                             ,p_init_msg_list
                                             ,l_api_version
                                             ,p_api_version
                                             ,'_PVT'
                                             ,x_return_status);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- Call the update api which takes care of updating the
    --  SGT Set, Version, Pricing Params and Primary Lines
    --   This API should not validate even the SGT status is active or not !
    IF p_pri_gtlv_tbl IS NOT NULL AND p_pri_gtlv_tbl.COUNT > 0 THEN
      update_strm_gen_template(
        p_api_version      => p_api_version,
        p_init_msg_list    => p_init_msg_list,
        x_return_status    => l_return_status,
        x_msg_count        => x_msg_count,
        x_msg_data         => x_msg_data,
        p_gtsv_rec         => p_gtsv_rec,
        p_gttv_rec         => p_gttv_rec,
        p_gtpv_tbl         => p_gtpv_tbl,
        p_gtlv_tbl         => p_pri_gtlv_tbl,
        x_gttv_rec         => x_gttv_rec);
      IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    END IF;
    -- Call the API which deletes the Dependents
    --  Dependents will be deleted only if the SGT was not in Active Status
    IF p_del_dep_gtlv_tbl IS NOT NULL AND p_del_dep_gtlv_tbl.COUNT > 0
    THEN
      delete_dep_tmpt_lns(
        p_api_version    => p_api_version,
        p_init_msg_list  => p_init_msg_list,
        x_return_status  => l_return_status,
        x_msg_count      => x_msg_count,
        x_msg_data       => x_msg_data,
        p_gtlv_tbl       => p_del_dep_gtlv_tbl);
      IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    END IF;
    -- Call the update API which takes care of updating/inserting the
    --   dependent streams of the Stream Generation Template
    --   This API should not validate even the SGT status is active or not !
    IF p_ins_dep_gtlv_tbl IS NOT NULL AND p_ins_dep_gtlv_tbl.COUNT > 0
    THEN
      update_dep_strms(
        p_api_version      => p_api_version,
        p_init_msg_list    => p_init_msg_list,
        x_return_status    => l_return_status,
        x_msg_count        => x_msg_count,
        x_msg_data         => x_msg_data,
        p_gtt_id           => x_gttv_rec.id, -- SGT Version ID
        p_pri_sty_id       => NULL, -- Not mandatory
        p_gtlv_tbl         => p_ins_dep_gtlv_tbl,
        x_missing_deps     => l_missing_deps,
        x_show_warn_flag   => l_show_warn_flag);
      IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    END IF;
    -- Imposing the following Validation:
    --  RULE:
    --    For a particular Primary Stream, we shouldnot have
    --    two dependant streams with same purpose.
    --  Loop through all the Primary Stream types of this SGT
    l_found := OKL_API.G_FALSE;
    l_pri_stream_name := NULL;
    l_dep_purp_list := ' ';
    FOR t_rec IN okl_dep_purpose_dup_csr( x_gttv_rec.id )
    LOOP
      l_found := OKL_API.G_TRUE;
      IF l_pri_stream_name IS NULL
      THEN
        l_pri_stream_name := t_rec.pri_strm_type_name;
        l_dep_purp_list := t_rec.dep_purpose_meaning;
      END IF;
      IF l_pri_stream_name <> t_rec.pri_strm_type_name
      THEN
        -- Push the messsage into the FND stack
        put_messages_in_table(
          p_msg_name        => 'OKL_ST_SGT_DUP_DEPENDANTS',
          p_during_upd_flag => 'T',
          x_msg_out         => l_msg,
          p_token1          => 'PRISTRMCODE',
          p_value1          => l_pri_stream_name,
          p_token2          => 'DEPPURPOSELIST',
          p_value2          => l_dep_purp_list);
        -- Initialize the pri stream name and the dep purpose list ..
        l_pri_stream_name := t_rec.pri_strm_type_name;
        l_dep_purp_list := t_rec.dep_purpose_meaning;
      ELSIF l_dep_purp_list <> t_rec.dep_purpose_meaning
      THEN
        l_dep_purp_list := l_dep_purp_list || ',' || t_rec.dep_purpose_meaning;
      END IF;
    END LOOP;
    IF l_found = Okl_Api.G_TRUE
    THEN
        -- Push the last messsage into the FND stack
        put_messages_in_table(
          p_msg_name        => 'OKL_ST_SGT_DUP_DEPENDANTS',
          p_during_upd_flag => 'T',
          x_msg_out         => l_msg,
          p_token1          => 'PRISTRMCODE',
          p_value1          => l_pri_stream_name,
          p_token2          => 'DEPPURPOSELIST',
          p_value2          => l_dep_purp_list);
      l_return_status := Okl_Api.G_RET_STS_ERROR;
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    -- Insertion/Updation/Deletion has been done successful.
    -- Now need to check for errors and warnings.
    IF x_gttv_rec.tmpt_status = G_STATUS_ACTIVE
    THEN
      -- Call the Validate API to check for errors only if the SGT is in Active Status
      validate_template(
        p_api_version         => p_api_version,
        p_init_msg_list       => p_init_msg_list,
        x_return_status       => l_return_status,
        x_msg_count           => x_msg_count,
        x_msg_data            => x_msg_data,
		    p_gtt_id              => x_gttv_rec.id,
        x_error_msgs_tbl      => l_error_msgs_tbl,
        x_return_tmpt_status  => l_return_tmpt_status,
        p_during_upd_flag     => 'T' ); -- This Wrapper API will be called only in Update Mode
      -- Check whether the Validate API has been ran successfull or not ?
      IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      -- Now check whether there are no validation errors or not?
      IF  l_error_msgs_tbl.count > 0
      THEN
        x_return_status := Okl_Api.G_RET_STS_ERROR;
        RAISE Okl_Api.G_EXCEPTION_ERROR;
      END If;
      -- Now if there is no Validation Error, check for the Warnings,
      --  but the code shouldnot error out in this case.
      validate_for_warnings(
        p_api_version      => p_api_version,
        p_init_msg_list    => p_init_msg_list,
        x_return_status    => l_return_status,
        x_msg_count        => x_msg_count,
        x_msg_data         => x_msg_data,
        p_gtt_id           => x_gttv_rec.id,
        x_wrn_msgs_tbl     => l_error_msgs_tbl,
        p_during_upd_flag  => 'F', -- Dont push any warnings into the Stack
        x_pri_purpose_list => l_pri_purpose_list );
      IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      -- Whenever the SGT is updated successfull and if its in ACTIVE status
      -- the corresponding products should be made to INVALID status
      FOR gts_id_rec IN fetch_gts_id_csr( x_gttv_rec.id )
      LOOP
        l_sgt_set_id := gts_id_rec.gts_id;
      END LOOP;
      -- Need to invalidate all the products which use this SGT.
      FOR pdt_rec IN pdt_for_active_sgt_csr( l_sgt_set_id )
      LOOP
        OKL_SETUPPRODUCTS_PVT.update_product_status(
          p_api_version     => p_api_version,
          p_init_msg_list   => p_init_msg_list,
          x_return_status   => l_return_Status,
          x_msg_count       => x_msg_count,
          x_msg_data        => x_msg_data,
          p_pdt_status      => OKL_SETUPPRODUCTS_PVT.G_PDT_STS_INVALID,
          p_pdt_id          => pdt_rec.pdt_id  );
        IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
      END LOOP;
    END IF; -- IF x_gttv_rec.tmpt_status = G_ACTIVE
    x_pri_purpose_list := l_pri_purpose_list;
    x_return_status := l_return_status;
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (l_api_name,
       G_PKG_NAME,
       'OKL_API.G_RET_STS_ERROR',
       x_msg_count,
       x_msg_data,
       '_PVT');
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      ( l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT');
    WHEN OTHERS THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
      ( l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT');
END update_pri_dep_of_sgt;

End  okl_strm_gen_template_pvt;

/
