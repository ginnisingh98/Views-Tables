--------------------------------------------------------
--  DDL for Package Body OKL_LEASEAPP_TEMPLATE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_LEASEAPP_TEMPLATE_PVT" AS
  /* $Header: OKLRLATB.pls 120.21.12010000.2 2008/12/20 01:37:21 smereddy ship $ */

  -- bug 4741121 - smadhava  - Modified - Start
  G_PROF_FE_APPROVAL_PROCESS CONSTANT VARCHAR2(30) := 'OKL_SO_APPROVAL_PROCESS';
  G_WF_EVT_LAT_PENDING    CONSTANT wf_events.name%TYPE DEFAULT 'oracle.apps.okl.sales.leaseapplication.template_approved';
  G_WF_LAT_VERSION_ID     CONSTANT  VARCHAR2(50)       := 'VERSION_ID';
  -- bug 4741121 - smadhava  - Modified - Start

  -------------------------------------------------------------------------------
  -- FUNCTION check_unique_combination
  -------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : check_unique_combination
  -- Description     : Check unique combination of fields Lease Application Type,
  --                 : Credit Classification,Credit Classification, Industry,
  --                 : Contract Template and Contract Template while creation and
  --                 : updation of Lease application Templates
  --
  -- Business Rules  :
  --
  -- Parameters      :
  -- Version         : 1.0
  -- History         : 20-MAY-2005 SKGAUTAM created
  -- End of comments
  FUNCTION check_unique_combination(p_latv_rec           IN latv_rec_type,
                                    p_lavv_rec           IN lavv_rec_type)
  RETURN VARCHAR2 IS

  -- Variables Declarations
    l_api_version CONSTANT NUMBER       DEFAULT 1.0;
    l_api_name    CONSTANT VARCHAR2(30) DEFAULT 'CHECK_UNIQUE_COMBINATION';
    l_return_status        VARCHAR2(1)  := OKL_API.G_RET_STS_SUCCESS;
    l_check_tmplt_comb     VARCHAR2(1);
  CURSOR c_chk_tmlt_cmbntn IS
       SELECT 'x'
       FROM   Okl_Leaseapp_Templates LATV,
              OKL_LEASEAPP_TEMPL_VERSIONS_V LAVV
       WHERE  LATV.ID                             = LAVV.LEASEAPP_TEMPLATE_ID
       AND    LATV.CREDIT_REVIEW_PURPOSE          = p_latv_rec.CREDIT_REVIEW_PURPOSE
       AND    LATV.CUST_CREDIT_CLASSIFICATION     = p_latv_rec.CUST_CREDIT_CLASSIFICATION
-- Bug 5149659 udhenuko : Start - Uncommenting industry values check
--Commented the industry values for checking uniqueness due to issue with data model
--industry values are stired at header and it will be same always accross versions
--for a given template
       AND    NVL(LATV.INDUSTRY_CODE, OKL_API.G_MISS_CHAR)         = NVL(p_latv_rec.INDUSTRY_CODE, OKL_API.G_MISS_CHAR)
       AND    NVL(LATV.INDUSTRY_CLASS, OKL_API.G_MISS_CHAR)        = NVL(p_latv_rec.INDUSTRY_CLASS, OKL_API.G_MISS_CHAR)
-- Bug 5149659 udhenuko : End
       AND    NVL(LAVV.CONTRACT_TEMPLATE_ID, OKL_API.G_MISS_NUM) = NVL(p_lavv_rec.CONTRACT_TEMPLATE_ID, OKL_API.G_MISS_NUM)
       AND    NVL(LAVV.CHECKLIST_ID, OKL_API.G_MISS_NUM)         = NVL(p_lavv_rec.CHECKLIST_ID, OKL_API.G_MISS_NUM)
       AND    LAVV.VERSION_STATUS                 = 'ACTIVE'
       AND    LAVV.ID                            <> nvl(p_lavv_rec.id,-99999);
  BEGIN
    -- check for unique Lease Application Template
    OPEN  c_chk_tmlt_cmbntn;
    FETCH c_chk_tmlt_cmbntn INTO l_check_tmplt_comb;
    CLOSE c_chk_tmlt_cmbntn;

    IF l_check_tmplt_comb = 'x' THEN
    OKL_API.SET_MESSAGE(p_app_name  => g_app_name,
                        p_msg_name  => 'OKL_SO_LSEAPP_TMPLT_NOT_UNIQUE');
    -- notify caller of an error
    l_return_status := OKL_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_return_status);
    EXCEPTION
       -- other appropriate handlers
       WHEN OTHERS THEN
         -- store SQL error message on message stack
         OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                              p_msg_name     => G_UNEXPECTED_ERROR,
                              p_token1       => G_SQLCODE_TOKEN,
                              p_token1_value => sqlcode,
                              p_token2       => G_SQLERRM_TOKEN,
                              p_token2_value => sqlerrm);

         -- notify  UNEXPECTED error
       l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
       RETURN  l_return_status;
  END check_unique_combination;

  -- bug 4741121 - smadhava  - Added - Start
  -- Start of comments
  --
  -- Procedure Name  : activate_lat
  -- Description     : Procedure to change the status of LAT once the workflow is approved
  -- Business Rules  : The LAT version and header statuses are moved to ACTIVE.
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  PROCEDURE activate_lat (p_api_version        IN NUMBER,
                          p_init_msg_list      IN VARCHAR2,
                          x_return_status      OUT NOCOPY VARCHAR2,
                          x_msg_count          OUT NOCOPY NUMBER,
                          x_msg_data           OUT NOCOPY VARCHAR2,
                          p_lat_version_id     IN         NUMBER)IS
    l_api_name      CONSTANT VARCHAR2(40)   := 'activate_lat';
    l_api_version   CONSTANT NUMBER         := p_api_version;
    l_init_msg_list          VARCHAR2(1)    := p_init_msg_list;
    l_msg_count              NUMBER         := x_msg_count ;
    l_msg_data               VARCHAR2(2000);
    l_return_status          VARCHAR2(1)    := OKL_API.G_RET_STS_SUCCESS;

    l_latv_rec                 latv_rec_type;
    lx_latv_rec                latv_rec_type;
    l_lavv_rec                 lavv_rec_type;
    lx_lavv_rec                lavv_rec_type;
    l_parameter_list           wf_parameter_list_t;
    p_event_name               VARCHAR2(240)       := 'oracle.apps.okl.sales.leaseapplication.template_activated';

    l_chk_vers_sts VARCHAR2(1);

  -- cursor to get the LAT header information of the particular version
  CURSOR c_get_lat_data( cp_lav_id OKL_LEASEAPP_TEMPL_VERSIONS_V.ID%TYPE) IS
    SELECT LATV.ID LAT_HDR_ID
         , LATV.OBJECT_VERSION_NUMBER HDR_OBJ_VER_NO
         , LAVV.OBJECT_VERSION_NUMBER VER_OBJ_VER_NO
    FROM   OKL_LEASEAPP_TEMPLATES        LATV,
           OKL_LEASEAPP_TEMPL_VERSIONS_V LAVV
    WHERE  LATV.ID  = LAVV.LEASEAPP_TEMPLATE_ID
    AND    LAVV.ID  = cp_lav_id;

  -- cursor to check if all the versions of the LAT are active
  CURSOR c_chk_ver_sts( cp_lat_id OKL_LEASEAPP_TEMPLATES.ID%TYPE) IS
    SELECT 'X'
      FROM OKL_LEASEAPP_TEMPL_VERSIONS_V LAVV
     WHERE LAVV.LEASEAPP_TEMPLATE_ID = cp_lat_id
       AND LAVV.VERSION_STATUS       <> G_STATUS_ACTIVE;

  l_module CONSTANT fnd_log_messages.module%TYPE :='okl.plsql.OKL_LEASEAPP_TEMPLATE_PVT.activate_lat';
  l_debug_enabled VARCHAR2(10);
  is_debug_procedure_on BOOLEAN;
  is_debug_statement_on BOOLEAN;

  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    -- check for logging on PROCEDURE level
    l_debug_enabled := okl_debug_pub.check_log_enabled;
    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := OKL_API.START_ACTIVITY( p_api_name      => l_api_name
                                              ,p_pkg_name      => G_PKG_NAME
                                              ,p_init_msg_list => p_init_msg_list
                                              ,l_api_version   => l_api_version
                                              ,p_api_version   => p_api_version
                                              ,p_api_type      => g_api_type
                                              ,x_return_status => x_return_status);
    -- check if activity started successfully
    IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    OPEN c_get_lat_data(p_lat_version_id);
      FETCH c_get_lat_data INTO l_latv_rec.id
                        , l_latv_rec.object_version_number
                        , l_lavv_rec.object_version_number;
    CLOSE c_get_lat_data;

    -- Change the status of the version and header to ACTIVE
    l_lavv_rec.version_status  := G_STATUS_ACTIVE;
    l_latv_rec.template_status := G_STATUS_ACTIVE;

    l_lavv_rec.id := p_lat_version_id;
    -- call the TAPI insert_row to update lease application template version
    OKL_LAV_PVT.update_row(p_api_version                => p_api_version
                            ,p_init_msg_list              => p_init_msg_list
                            ,x_return_status              => l_return_status
                            ,x_msg_count                  => x_msg_count
                            ,x_msg_data                   => x_msg_data
                            ,p_lavv_rec                   => l_lavv_rec
                            ,x_lavv_rec                   => lx_lavv_rec);
    IF l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF l_return_status = OKL_API.G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

   OPEN c_chk_ver_sts(l_latv_rec.ID);
     FETCH c_chk_ver_sts INTO l_chk_vers_sts;
   CLOSE c_chk_ver_sts;

   IF l_chk_vers_sts IS NULL THEN

      -- call the TAPI update_row to update lease application template
      OKL_LAT_PVT.update_row(p_api_version              => p_api_version
                            ,p_init_msg_list            => p_init_msg_list
                            ,x_return_status            => l_return_status
                            ,x_msg_count                => x_msg_count
                            ,x_msg_data                 => x_msg_data
                            ,p_latv_rec                 => l_latv_rec
                            ,x_latv_rec                 => lx_latv_rec);

    IF l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF l_return_status = OKL_API.G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    END IF;
    -- raise the business event passing the Template id and the version id added to the parameter list
    wf_event.addparametertolist('LAT_ID'
                                 ,l_latv_rec.ID
                                 ,l_parameter_list);

    wf_event.addparametertolist('LAT_VERSION_ID'
                                 ,p_lat_version_id
                                 ,l_parameter_list);

    okl_wf_pvt.raise_event(  p_api_version   =>            p_api_version
                            ,p_init_msg_list =>            p_init_msg_list
                            ,x_return_status =>            x_return_status
                            ,x_msg_count     =>            x_msg_count
                            ,x_msg_data      =>            x_msg_data
                            ,p_event_name    =>            p_event_name
                            ,p_parameters    =>            l_parameter_list);

    IF l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF l_return_status = OKL_API.G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

     x_return_status := l_return_status;
     OKL_API.END_ACTIVITY(x_msg_count     => x_msg_count
                         ,x_msg_data    => x_msg_data);

  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => g_api_type);
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => g_api_type);
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OTHERS',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => g_api_type);
  END activate_lat;
  -- bug 4741121 - smadhava  - Added - End

  -------------------------------------------------------------------------------
  -- PROCEDURE create_lease_app_template
  -------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : create_lease_app_template
  -- Description     : This procedure is a wrapper that creates transaction records for
  --                 : lease application template.
  --
  -- Business Rules  : this procedure is used to create lease application template
  --                   this procedure inserts records into the OKL_LEASEAPP_TEMPLATES and
  --                   OKL_LEASEAPP_TEMPL_VERSIONS_B table
  --
  -- Parameters      :
  -- Version         : 1.0
  -- History         : 12-MAY-2005 SKGAUTAM created
  -- End of comments
  PROCEDURE create_leaseapp_template(p_api_version        IN NUMBER,
                                     p_init_msg_list      IN VARCHAR2,
                                     x_return_status      OUT NOCOPY VARCHAR2,
                                     x_msg_count          OUT NOCOPY NUMBER,
                                     x_msg_data           OUT NOCOPY VARCHAR2,
                                     p_latv_rec           IN latv_rec_type,
                                     x_latv_rec           OUT NOCOPY latv_rec_type,
                                     p_lavv_rec           IN lavv_rec_type,
                                     x_lavv_rec           OUT NOCOPY lavv_rec_type)IS
    -- Variables Declarations
    l_api_version CONSTANT NUMBER       DEFAULT 1.0;
    l_api_name    CONSTANT VARCHAR2(30) DEFAULT 'CREATE_LEASEAPP_TEMPLATE';
    l_return_status        VARCHAR2(1)  := OKL_API.G_RET_STS_SUCCESS;

    -- Record/Table Type Declarations
    l_latv_rec                latv_rec_type;
    lx_latv_rec               latv_rec_type;
    l_lavv_rec                lavv_rec_type;
    lx_lavv_rec               lavv_rec_type;
    l_debug_enabled       VARCHAR2(10);
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    -- check for logging on PROCEDURE level
    l_debug_enabled := okl_debug_pub.check_log_enabled;
    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := OKL_API.START_ACTIVITY( p_api_name      => l_api_name
                                              ,p_pkg_name      => G_PKG_NAME
                                              ,p_init_msg_list => p_init_msg_list
                                              ,l_api_version   => l_api_version
                                              ,p_api_version   => p_api_version
                                              ,p_api_type      => g_api_type
                                              ,x_return_status => x_return_status);
    -- check if activity started successfully
    IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_latv_rec := p_latv_rec;
    l_lavv_rec := p_lavv_rec;

    --set the version and status for lease application template
    l_latv_rec.id := null;
    l_lavv_rec.id := null;
    l_lavv_rec.version_number := 1;
    l_lavv_rec.version_status := G_INIT_TMPLT_STATUS;

    --Synchonrize the template header effective dates and status with
    --headers version details

    --Begin- varangan-bug#4684557 - Version From date validation
    l_lavv_rec.valid_from:=TRUNC(l_lavv_rec.valid_from);
    l_lavv_rec.valid_to:=TRUNC(l_lavv_rec.valid_to);
   --End- varangan-bug#4684557 - Version From date validation

    l_latv_rec.valid_from := l_lavv_rec.valid_from;
    l_latv_rec.valid_to := l_lavv_rec.valid_to;
    l_latv_rec.template_status := l_lavv_rec.version_status;

    --Bug # 5189655 ssdeshpa start
    --Removing check_unique_combination while create/update/duplicate of LAT

    --call function to check the unique combination for lease application template
    /*l_return_status := check_unique_combination(l_latv_rec,
                                                l_lavv_rec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF; */
    --Bug # 5189655 ssdeshpa end

    IF(l_debug_enabled='Y') THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,'okl.plsql.OKL_LAT_PVT.INSERT_ROW'
      ,'begin debug OKLSLATB.pls call insert_row');
    END IF;
    -- call the TAPI insert_row to create a lease application template
    OKL_LAT_PVT.insert_row(p_api_version            => p_api_version
                          ,p_init_msg_list          => p_init_msg_list
                          ,x_return_status          => x_return_status
                          ,x_msg_count              => x_msg_count
                          ,x_msg_data               => x_msg_data
                          ,p_latv_rec               => l_latv_rec
                          ,x_latv_rec               => lx_latv_rec);
    IF(l_debug_enabled='Y') THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,'okl.plsql.OKL_LAT_PVT.INSERT_ROW'
      ,'end debug OKLSLATB.pls call insert_row');
    END IF;
    -- write to log
    IF(NVL(l_debug_enabled,'N')='Y') THEN
       okl_debug_pub.log_debug(FND_LOG.LEVEL_STATEMENT,'okl.plsql.OKL_LAT_PVT.INSERT_ROW',
       ' l_latv_name ' || l_latv_rec.NAME ||
           ' expiring lease application template with ret status ' || x_return_status ||
           ' x_msg_data ' || x_msg_data);
    END IF; -- end of NVL(l_debug_enabled,'N')='Y'

    IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR)THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR)THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    l_lavv_rec.LEASEAPP_TEMPLATE_ID := lx_latv_rec.ID;

    IF(l_debug_enabled='Y') THEN
       okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,'okl.plsql.OKL_LAV_PVT.INSERT_ROW'
       ,'begin debug OKLSLAVB.pls call insert_row');
    END IF;
    -- call the TAPI insert_row to create a lease application template version details
    OKL_LAV_PVT.insert_row(p_api_version             => p_api_version
                          ,p_init_msg_list           => p_init_msg_list
                          ,x_return_status           => x_return_status
                          ,x_msg_count               => x_msg_count
                          ,x_msg_data                => x_msg_data
                          ,p_lavv_rec                => l_lavv_rec
                          ,x_lavv_rec                => lx_lavv_rec);
    IF(l_debug_enabled='Y') THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,'okl.plsql.OKL_LAV_PVT.INSERT_ROW'
      ,'end debug OKLSLAVB.pls call insert_row');
    END IF;
    -- write to log
    IF(NVL(l_debug_enabled,'N')='Y') THEN
       okl_debug_pub.log_debug(FND_LOG.LEVEL_STATEMENT,'okl.plsql.OKL_LAV_PVT.INSERT_ROW',
       'l_lavv_rec.version_number '||to_char(l_lavv_rec.version_number)||
           'l_lavv_rec.version_status '||l_lavv_rec.version_status||
       ' expiring lease application template  with ret status '||x_return_status||' x_msg_data '||x_msg_data);
    END IF; -- end of NVL(l_debug_enabled,'N')='Y'

    IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR)THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR)THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    x_latv_rec := lx_latv_rec;
    x_lavv_rec := lx_lavv_rec;
    OKL_API.END_ACTIVITY(x_msg_count  => x_msg_count
                        ,x_msg_data       => x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => g_api_type);
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => g_api_type);
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OTHERS',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => g_api_type);
  END create_leaseapp_template;

  -------------------------------------------------------------------------------
  -- PROCEDURE upadte_lease_app_template
  -------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : update_lease_app_template
  -- Description     : This procedure is a wrapper thatupdates the transaction records for
  --                 : lease application template.
  --
  -- Business Rules  : this procedure is used to update lease application template
  --                   this procedure updates records of the OKL_LEASEAPP_TEMPLATES and
  --                   OKL_LEASEAPP_TEMPL_VERSIONS_B table.
  --
  -- Parameters      :
  -- Version         : 1.0
  -- History         : 12-MAY-2005 SKGAUTAM created
  -- End of comments
  PROCEDURE update_leaseapp_template(p_api_version        IN NUMBER,
                                     p_init_msg_list      IN VARCHAR2,
                                     x_return_status      OUT NOCOPY VARCHAR2,
                                     x_msg_count          OUT NOCOPY NUMBER,
                                     x_msg_data           OUT NOCOPY VARCHAR2,
                                     p_latv_rec           IN  latv_rec_type,
                                     x_latv_rec           OUT NOCOPY latv_rec_type,
                                     p_lavv_rec           IN lavv_rec_type,
                                     x_lavv_rec           OUT NOCOPY lavv_rec_type,
                                     p_ident_flag         IN VARCHAR2)IS
    -- Variables Declarations
    l_api_version CONSTANT NUMBER       DEFAULT 1.0;
    l_api_name    CONSTANT VARCHAR2(30) DEFAULT 'UPDATE_LEASEAPP_TEMPLATE';
    l_return_status        VARCHAR2(1)  := OKL_API.G_RET_STS_SUCCESS;
    -- Record/Table Type Declarations

    -- Begin - bug#4632503 - varangan- 11-Oct-2005
    l_source_type CONSTANT VARCHAR2(30) DEFAULT 'LEASE_APPL_TEMPLATE';
    -- End - bug#4632503 - varangan- 11-Oct-2005

    l_latv_rec                 latv_rec_type;
    lx_latv_rec                latv_rec_type;
    l_lavv_rec                 lavv_rec_type;
    lx_lavv_rec                lavv_rec_type;
    l_debug_enabled        VARCHAR2(10);
    l_valid_from           DATE;
    l_ident_flag           VARCHAR2(10):= 'U';
    l_max_start_date           DATE;

    --Get the min/max effective dates of versions to synchonize temlate header
    --effective dates
    CURSOR c_get_valid_dates( p_lat_id okl_leaseapp_templates.id%TYPE) IS
    SELECT MIN(LAVV.valid_from) valid_from
    FROM   Okl_Leaseapp_Templates LATV,
           okl_leaseapp_templ_versions_v LAVV
    WHERE  LATV.ID  = LAVV.LEASEAPP_TEMPLATE_ID
    AND    LATV.ID  = p_lat_id
    GROUP BY LATV.ID;

    -- Get the max start date from Lease App and Vendor Prog
    -- for associated lease app template
    CURSOR c_get_max_start_date( p_lat_id okl_leaseapp_templates.id%TYPE) IS
    SELECT MAX(START_DATE) max_start_date
    FROM
      (
         SELECT chr.START_DATE START_DATE
        FROM   okc_k_headers_b chr,
               okl_vp_associations vpa,
               Okl_Leaseapp_Templates lat,
               okl_leaseapp_templ_versions_b lav
        WHERE  chr.scs_code = 'PROGRAM'
          AND  chr.sts_code = 'ACTIVE'
          AND  chr.id = vpa.chr_id
          AND  vpa.ASSOC_OBJECT_TYPE_CODE = 'LA_TEMPLATE'
          AND  vpa.ASSOC_OBJECT_ID = lat.ID
          AND  vpa.ASSOC_OBJECT_VERSION  = lav.VERSION_NUMBER
          AND  LAT.ID = LAV.LEASEAPP_TEMPLATE_ID
          AND  lat.ID          =   p_lat_id
        UNION
        SELECT laa.VALID_FROM START_DATE
        FROM   OKL_LEASE_APPLICATIONS_B laa,
               okl_leaseapp_templates lat,
               okl_leaseapp_templ_versions_v lav
        WHERE  lat.id = lav.leaseapp_template_id
        AND    laa.LEASEAPP_TEMPLATE_ID = lav.ID
        AND    laa.APPLICATION_STATUS IN('CONV-CL','CONV-K','CR-APPROVED','CR-SUBMITTED',
                                         'PR-ACCEPTED','PR-APPROVED','PR-SUBMITTED')
        AND    laa.VALID_FROM >= lav.VALID_FROM
        AND    lat.ID          =   p_lat_id
       ) MY_START_DATE;

  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    -- check for logging on PROCEDURE level
    l_debug_enabled := okl_debug_pub.check_log_enabled;
    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := OKL_API.START_ACTIVITY( p_api_name      => l_api_name
                                              ,p_pkg_name      => G_PKG_NAME
                                              ,p_init_msg_list => p_init_msg_list
                                              ,l_api_version   => l_api_version
                                              ,p_api_version   => p_api_version
                                              ,p_api_type      => g_api_type
                                              ,x_return_status => x_return_status);
    -- check if activity started successfully
    IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_latv_rec := p_latv_rec;
    l_lavv_rec := p_lavv_rec;
    l_ident_flag := p_ident_flag;

    --Synchonrize the template header effective dates and status with
    --headers version details
    OPEN  c_get_valid_dates(l_latv_rec.ID);
    FETCH c_get_valid_dates INTO l_valid_from;
    CLOSE c_get_valid_dates;
    IF l_ident_flag = 'U' THEN
       IF l_lavv_rec.version_number = 1 THEN
          l_latv_rec.valid_from := TRUNC(l_lavv_rec.valid_from);  -- bug#4632503 - varangan- 11-Oct-2005
          l_latv_rec.valid_to := TRUNC(l_lavv_rec.valid_to); -- bug#4632503 - varangan- 11-Oct-2005
          l_latv_rec.template_status := G_INIT_TMPLT_STATUS;
       ELSE
          l_latv_rec.valid_from := TRUNC(l_valid_from); -- bug#4632503 - varangan- 11-Oct-2005
          l_latv_rec.valid_to := TRUNC(l_lavv_rec.valid_to); -- bug#4632503 - varangan- 11-Oct-2005
          l_latv_rec.template_status := G_STATUS_UNDERREVISION;
       END IF;
    ELSIF l_ident_flag = 'V' THEN
          l_latv_rec.valid_from := TRUNC(l_valid_from); -- bug#4632503 - varangan- 11-Oct-2005
          l_latv_rec.template_status := G_STATUS_UNDERREVISION;
    ELSIF l_ident_flag = 'A' THEN
          l_latv_rec.valid_from := TRUNC(l_valid_from); -- bug#4632503 - varangan- 11-Oct-2005
          IF l_lavv_rec.version_status = G_STATUS_ACTIVE THEN
             l_latv_rec.template_status := G_STATUS_ACTIVE;
         -- bug 4741121 - smadhava  - Modified - Start
         -- Commented as Activation process before it calls a workflow for a single version LAT
         -- should have the status of LAT header as 'NEW'
         /*
          ELSE
             l_latv_rec.template_status := G_STATUS_UNDERREVISION;
          */
         -- bug 4741121 - smadhava  - Modified - End
          END IF;
    ELSIF  l_ident_flag = 'UA' THEN

          IF l_lavv_rec.version_number = 1 THEN
          l_latv_rec.valid_from := TRUNC(l_lavv_rec.valid_from);  -- bug#4632503 - varangan- 11-Oct-2005
          l_latv_rec.valid_to := TRUNC(l_lavv_rec.valid_to); -- bug#4632503 - varangan- 11-Oct-2005
          l_latv_rec.template_status := G_STATUS_ACTIVE;
       ELSE
          l_latv_rec.valid_from := TRUNC(l_valid_from); -- bug#4632503 - varangan- 11-Oct-2005
          l_latv_rec.valid_to := TRUNC(l_lavv_rec.valid_to); -- bug#4632503 - varangan- 11-Oct-2005
          l_latv_rec.template_status := G_STATUS_ACTIVE;
       END IF;
    END IF;

    --Bug # 5189655 ssdeshpa start
    --Removing check_unique_combination while create/update/duplicate of LAT

    --call function to check the unique combination for lease application template
    /*l_return_status := check_unique_combination(l_latv_rec,
                                                l_lavv_rec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF; */
    --Bug # 5189655 ssdeshpa end
    --if we are updating an active version, check if the valid to date is greater than or equal to
    --all the lease applications and vendor programs start date which uses this template
    IF l_lavv_rec.version_status = G_STATUS_ACTIVE THEN
        -- Fetch the Maximum of Start Date of the contracts using this template
       FOR r_new_date_rec IN c_get_max_start_date(l_latv_rec.id)
       LOOP
           l_max_start_date := r_new_date_rec.max_start_date;
       END LOOP;

       IF( l_max_start_date IS NULL) THEN
         -- If no start_date is found, then take the this versions start_date
         -- as the max_Start_date
         l_max_start_date := l_lavv_rec.valid_from;
       END IF;
       IF( l_max_start_date< l_lavv_rec.valid_from ) THEN
         -- If no start_date is found, then take the this versions start_date
         -- as the max_Start_date
         l_max_start_date := l_lavv_rec.valid_from;
       END IF;

        IF l_lavv_rec.valid_to <> OKL_API.G_MISS_DATE AND l_lavv_rec.valid_to < l_max_start_date THEN
          OKL_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                              p_msg_name     => 'OKL_LAT_INVALID_VALITO',
                              p_token1       => 'VALID_TO',
                              p_token1_value =>  l_max_start_date);
          RAISE OKL_API.G_EXCEPTION_ERROR;

        END IF;
      --  l_latv_rec.template_status := G_STATUS_ACTIVE;
    END IF;

    IF ((l_latv_rec.ID IS NOT NULL OR l_latv_rec.id <> OKL_API.G_MISS_NUM)) THEN
      IF(l_debug_enabled='Y') THEN
        okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,'okl.plsql.OKL_LAT_PVT.UPADTE_ROW'
        ,'begin debug OKLSLATB.pls call upadte_row');
      END IF;
      -- call the TAPI update_row to create a lease application template
      OKL_LAT_PVT.update_row(p_api_version              => p_api_version
                            ,p_init_msg_list            => p_init_msg_list
                            ,x_return_status            => x_return_status
                            ,x_msg_count                => x_msg_count
                            ,x_msg_data                 => x_msg_data
                            ,p_latv_rec                 => l_latv_rec
                            ,x_latv_rec                 => lx_latv_rec);
      IF(l_debug_enabled='Y') THEN
        okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,'okl.plsql.OKL_LAT_PVT.UPADTE_ROW'
        ,'end debug OKLSLATB.pls call upadte_row');
      END IF;
      -- write to log
      IF(NVL(l_debug_enabled,'N')='Y') THEN
         okl_debug_pub.log_debug(FND_LOG.LEVEL_STATEMENT,'okl.plsql.OKL_LAT_PVT.UPDATE_ROW',
         'l_latv_name '||l_latv_rec.NAME
         ||'lease application template with ret status '||x_return_status||' x_msg_data '||x_msg_data);
      END IF; -- end of NVL(l_debug_enabled,'N')='Y'

      IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR)THEN
         RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR)THEN
         RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    END IF;

    IF ((l_lavv_rec.ID IS NOT NULL OR l_lavv_rec.id <> OKL_API.G_MISS_NUM)) THEN
      IF(l_debug_enabled='Y') THEN
        okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,'okl.plsql.OKL_LAV_PVT.UPADTE_ROW'
        ,'begin debug OKLSLAVB.pls call upadte_row');
      END IF;
      -- call the TAPI insert_row to create a lease application template
      OKL_LAV_PVT.update_row(p_api_version                => p_api_version
                            ,p_init_msg_list              => p_init_msg_list
                            ,x_return_status              => x_return_status
                            ,x_msg_count                  => x_msg_count
                            ,x_msg_data                   => x_msg_data
                            ,p_lavv_rec                   => l_lavv_rec
                            ,x_lavv_rec                   => lx_lavv_rec);
      IF(l_debug_enabled='Y') THEN
        okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,'okl.plsql.OKL_LAV_PVT.UPADTE_ROW'
        ,'end debug OKLSLAVB.pls call upadte_row');
      END IF;
      -- write to log
      IF(NVL(l_debug_enabled,'N')='Y') THEN
         okl_debug_pub.log_debug(FND_LOG.LEVEL_STATEMENT,'okl.plsql.OKL_LAV_PVT.UPDATE_ROW',
         'l_lavv_rec.version_number '||to_char(l_lavv_rec.version_number) ||'l_lavv_rec.version_status '
         ||l_lavv_rec.version_status
         ||'lease application template  with ret status '||x_return_status||'x_msg_data '||x_msg_data);
      END IF; -- end of NVL(l_debug_enabled,'N')='Y'
      IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR)THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR)THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
     END IF;
  -- Begin - Bug#4632503 - Updating Eligibility criteria's end date while updating version end date- varangan- 11-Oct-2005
       OKL_ECC_VALUES_PVT.end_date_eligibility_criteria(p_api_version     => p_api_version
                            ,p_init_msg_list    => p_init_msg_list
                            ,x_return_status    => x_return_status
                            ,x_msg_count        => x_msg_count
                            ,x_msg_data         => x_msg_data
                            ,p_source_id        => l_lavv_rec.ID
                            ,p_source_type      => l_source_type
                            ,p_end_date         => l_lavv_rec.valid_to);
      IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR)THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR)THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
  -- End - Bug#4632503 - Updating Eligibility criteria's end date while updating version end date- varangan- 11-Oct-2005
     x_latv_rec := lx_latv_rec;
     x_lavv_rec := lx_lavv_rec;
     OKL_API.END_ACTIVITY(x_msg_count   => x_msg_count
                         ,x_msg_data    => x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => g_api_type);
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => g_api_type);
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OTHERS',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => g_api_type);
  END update_leaseapp_template;

  -------------------------------------------------------------------------------
  -- PROCEDURE version_duplicate_leaseapp_template
  -------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : version_duplicate_lseapp_tmpl
  -- Description     : This procedure is a wrapper that duplicates and versions records for
  --                 : lease application template.
  --
  -- Business Rules  : this procedure is used to duplicate and version lease application template
  --                   this procedure inserts records into the OKL_LEASEAPP_TEMPLATES and
  --                   OKL_LEASEAPP_TEMPL_VERSIONS_B table
  --
  -- Parameters      :
  -- Version         : 1.0
  -- History         : 13-MAY-2005 SKGAUTAM created
  -- End of comments
  PROCEDURE version_duplicate_lseapp_tmpl( p_api_version   IN   NUMBER,
                                           p_init_msg_list IN  VARCHAR2,
                                           x_return_status OUT NOCOPY VARCHAR2,
                                           x_msg_count     OUT NOCOPY NUMBER,
                                           x_msg_data      OUT NOCOPY VARCHAR2,
                                           p_latv_rec      IN  latv_rec_type,
                                           x_latv_rec      OUT NOCOPY latv_rec_type,
                                           p_lavv_rec      IN  lavv_rec_type,
                                           x_lavv_rec      OUT NOCOPY lavv_rec_type,
                                           p_mode          IN  VARCHAR2)IS
    -- Variables Declarations
    l_api_version  CONSTANT NUMBER       DEFAULT 1.0;
    l_api_name     CONSTANT VARCHAR2(30) DEFAULT 'VERSION_DUP_LEASEAPP_TEMP';
    l_return_status         VARCHAR2(1)  := OKL_API.G_RET_STS_SUCCESS;
    -- Record/Table Type Declarations
    l_latv_rec_old                  latv_rec_type;
    l_latv_rec_new                  latv_rec_type;
    x_latv_rec_old                  latv_rec_type;
    x_latv_rec_new                  latv_rec_type;
    lx_latv_rec                     latv_rec_type;
    l_lavv_rec_old                  lavv_rec_type;
    l_lavv_rec_new                  lavv_rec_type;
    x_lavv_rec_old                  lavv_rec_type;
    x_lavv_rec_new                  lavv_rec_type;
    l_max_start_date        DATE;
    l_new_seq_value         NUMBER;
    l_debug_enabled         VARCHAR2(10);
    -- Declare Cursor Definations
    --asawanka bug 4966317 fix starts
    CURSOR get_latest_activever_dates(p_lat_id IN okl_leaseapp_templates.id%TYPE) IS
     /*  SELECT max(to_number(lav.version_number)), lav.valid_from,lav.valid_to
        FROM   okl_leaseapp_templates lat,
               okl_leaseapp_templ_versions_v lav
        WHERE  lat.id = lav.leaseapp_template_id
        AND    lat.id = p_lat_id
        group by lav.valid_from,lav.valid_to; */
    --Fixed ssdeshpa Bug # 6487421 Start
       SELECT LAV.VERSION_NUMBER
	    , LAV.VALID_FROM
	    , LAV.VALID_TO
       FROM OKL_LEASEAPP_TEMPLATES LAT
          , OKL_LEASEAPP_TEMPL_VERSIONS_B LAV
       WHERE LAT.ID = LAV.LEASEAPP_TEMPLATE_ID
         AND LAT.ID = p_lat_id
         AND TO_NUMBER(LAV.VERSION_NUMBER) = (SELECT MAX(TO_NUMBER(LAV1.VERSION_NUMBER))
                                              FROM OKL_LEASEAPP_TEMPL_VERSIONS_B LAV1
                                              WHERE LAV1.LEASEAPP_TEMPLATE_ID = LAT.ID);
    --Fixed ssdeshpa Bug # 6487421 End
    --asawanka bug 4966317 fix ends
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    -- check for logging on PROCEDURE level
    l_debug_enabled := okl_debug_pub.check_log_enabled;
    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := OKL_API.START_ACTIVITY( p_api_name      => l_api_name
                                              ,p_pkg_name      => G_PKG_NAME
                                              ,p_init_msg_list => p_init_msg_list
                                              ,l_api_version   => l_api_version
                                              ,p_api_version   => p_api_version
                                              ,p_api_type      => g_api_type
                                              ,x_return_status => x_return_status);
    -- check if activity started successfully
    IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    --Bug 5149659 PAGARG Populate old rec from DB for previous version update
    l_latv_rec_new := p_latv_rec;
    l_lavv_rec_new := p_lavv_rec;

    IF p_mode IS NULL OR p_mode = G_DEFAULT_MODE  THEN
    -- Duplicates the lease application template
       l_latv_rec_new.id := NULL;
       l_lavv_rec_new.id := NULL;
       --set the version and status for lease application template
       l_lavv_rec_new.version_number := 1;                          -- New ID will be created
       l_lavv_rec_new.version_status  := G_INIT_TMPLT_STATUS;  -- Make the New Template Status to NEW

       --Begin- varangan-bug#4684557 - Version From date validation
        l_lavv_rec_new.valid_from:=TRUNC(l_lavv_rec_new.valid_from);
        l_lavv_rec_new.valid_to:=TRUNC(l_lavv_rec_new.valid_to);
       --End- varangan-bug#4684557 - Version From date validation

       l_latv_rec_new.valid_from          := l_lavv_rec_new.valid_from;
       l_latv_rec_new.valid_to            := l_lavv_rec_new.valid_to;
       l_latv_rec_new.template_status     := l_lavv_rec_new.version_status;

       IF(l_debug_enabled='Y') THEN
          okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,'okl.plsql.OKL_LEASEAPP_TEMPLATE_PVT.create_leaseapp_template'
          ,'begin debug OKLRLATB.pls call create_leaseapp_template');
       END IF;
       -- call the APLI to create a lease application template
       create_leaseapp_template(p_api_version       => p_api_version
                               ,p_init_msg_list     => p_init_msg_list
                               ,x_return_status     => x_return_status
                               ,x_msg_count         => x_msg_count
                               ,x_msg_data          => x_msg_data
                               ,p_latv_rec          => l_latv_rec_new
                               ,x_latv_rec          => x_latv_rec_new
                               ,p_lavv_rec          => l_lavv_rec_new
                               ,x_lavv_rec          => x_lavv_rec_new);
       IF(l_debug_enabled='Y') THEN
          okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,'okl.plsql.OKL_LEASEAPP_TEMPLATE_PVT.create_leaseapp_template'
          ,'begin debug OKLRLATB.pls call create_leaseapp_template');
       END IF;
       -- write to log
       IF(NVL(l_debug_enabled,'N')='Y') THEN
         okl_debug_pub.log_debug(FND_LOG.LEVEL_STATEMENT,'okl.plsql.OKL_LEASEAPP_TEMPLATE_PVT.create_leaseapp_template',
         ' l_latv_name '||l_latv_rec_new.NAME ||
         ' expiring lease application template  with ret status '||x_return_status||' x_msg_data '||x_msg_data );
       END IF; -- end of NVL(l_debug_enabled,'N')='Y'

       IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR)THEN
         RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR)THEN
         RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;
       x_latv_rec := x_latv_rec_new;
       x_lavv_rec := x_lavv_rec_new;
    ELSE
      l_latv_rec_old := okl_lat_pvt.get_rec(p_latv_rec.id, l_return_status);
      l_lavv_rec_old := okl_lav_pvt.get_rec(p_lavv_rec.id, l_return_status);
       -- Fetch the Maximum of Start Date of the contracts using this template
       max_valid_from_date(p_api_version => p_api_version
                          ,p_init_msg_list    => p_init_msg_list
                          ,x_return_status    => x_return_status
                          ,x_msg_count        => x_msg_count
                          ,x_msg_data         => x_msg_data
                          ,p_latv_rec         => p_latv_rec
                          ,x_latv_rec         => lx_latv_rec);

       IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR)THEN
         RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR)THEN
         RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;

       IF l_lavv_rec_new.valid_from < lx_latv_rec.valid_from THEN
          OKL_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                              p_msg_name     => 'OKL_LAT_INVALID_VALIDFROM',
                              p_token1       => 'VALID_FROM',
                              p_token1_value =>  lx_latv_rec.valid_from);
          RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;
       -- Modifications to be done for the current template version
       -- Current version template end_date will be updated with
       -- new version valid from -1
       l_lavv_rec_old.valid_to := l_lavv_rec_new.valid_from -1;

       FOR r_actver_dates_rec IN get_latest_activever_dates(p_latv_rec.id) LOOP
           l_lavv_rec_old.valid_from := r_actver_dates_rec.valid_from;
       END LOOP;
       --asawanka bug 4966317 fix ends
       IF(l_debug_enabled='Y') THEN
         okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,'okl.plsql.OKL_LAT_PVT.UPADTE_ROW'
         ,'begin debug OKLSLATB.pls call upadte_row');
       END IF;

       IF(l_debug_enabled='Y') THEN
        okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,'okl.plsql.OKL_LEASEAPP_TEMPLATE_PVT.update_leaseapp_template'
        ,'end debug OKLRLATB.pls call update_leaseapp_template');
       END IF;
       --Begin- varangan-bug#4684557 - Version From date validation
                l_lavv_rec_old.valid_from:=TRUNC(l_lavv_rec_old.valid_from);
                l_lavv_rec_old.valid_to:=TRUNC(l_lavv_rec_old.valid_to);
                l_latv_rec_old.valid_from:=TRUNC(l_latv_rec_old.valid_from);
                l_latv_rec_old.valid_to:=TRUNC(l_latv_rec_old.valid_to);
        --End- varangan-bug#4684557 - Version From date validation

       -- call the API to update a lease application template
       update_leaseapp_template(p_api_version => p_api_version
                          ,p_init_msg_list    => p_init_msg_list
                          ,x_return_status    => x_return_status
                          ,x_msg_count        => x_msg_count
                          ,x_msg_data         => x_msg_data
                          ,p_latv_rec         => l_latv_rec_old
                          ,x_latv_rec         => x_latv_rec_old
                          ,p_lavv_rec         => l_lavv_rec_old
                          ,x_lavv_rec         => x_lavv_rec_old
                          ,p_ident_flag       => 'V');
       IF(l_debug_enabled='Y') THEN
         okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,'okl.plsql.OKL_LEASEAPP_TEMPLATE_PVT.update_leaseapp_template'
         ,'end debug OKLRLATB.pls call update_leaseapp_template');
       END IF;
       -- write to log
       IF(NVL(l_debug_enabled,'N')='Y') THEN
          okl_debug_pub.log_debug(FND_LOG.LEVEL_STATEMENT,'okl.plsql.OKL_LEASEAPP_TEMPLATE_PVT.update_leaseapp_template',
          'l_latv_name '||l_latv_rec_old.NAME ||
          'lease application template  with ret status '||x_return_status||' x_msg_data '||x_msg_data);
       END IF; -- end of NVL(l_debug_enabled,'N')='Y'
       IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR)THEN
         RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR)THEN
         RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;

       -- Modifications for New Version
       l_lavv_rec_new.version_number     := l_lavv_rec_old.version_number  + 1 ;
       l_lavv_rec_new.id := NULL;                               -- New ID will be created
       l_lavv_rec_new.version_status := G_INIT_TMPLT_STATUS;  -- Make the New Template Status to NEW
       l_lavv_rec_new.leaseapp_template_id := l_latv_rec_old.ID;

       IF(l_debug_enabled='Y') THEN
         okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,'okl.plsql.OKL_LAV_PVT.INSERT_ROW'
         ,'begin debug OKLSLAVB.pls call insert_row');
       END IF;

      --Begin- varangan-bug#4684557 - Version From date validation
       l_lavv_rec_new.valid_from  := TRUNC(l_lavv_rec_new.valid_from);
       l_lavv_rec_new.valid_to  := TRUNC(l_lavv_rec_new.valid_to);
      --Bug # 5189655 ssdeshpa start
      --Removing check_unique_combination while create/update/duplicate of LAT

      --End- varangan-bug#4684557 - Version From date validation
      --call function to check the unique combination for lease application template
      /* l_return_status := check_unique_combination(l_latv_rec_new,
                                                  l_lavv_rec_new);
      IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF; */
      --Bug # 5189655 ssdeshpa end
       -- call the TAPI insert_row to create a lease application template version
       OKL_LAV_PVT.insert_row(p_api_version                        => p_api_version
                          ,p_init_msg_list                      => p_init_msg_list
                          ,x_return_status                      => x_return_status
                          ,x_msg_count                          => x_msg_count
                          ,x_msg_data                           => x_msg_data
                          ,p_lavv_rec                           => l_lavv_rec_new
                          ,x_lavv_rec                           => x_lavv_rec_new);
       IF(l_debug_enabled='Y') THEN
         okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,'okl.plsql.OKL_LAV_PVT.INSERT_ROW'
         ,'end debug OKLSLAVB.pls call insert_row');
       END IF;
       -- write to log
       IF(NVL(l_debug_enabled,'N')='Y') THEN
          okl_debug_pub.log_debug(FND_LOG.LEVEL_STATEMENT,'okl.plsql.OKL_LAT_PVT.INSERT_ROW',
                  ' l_latv_name '||l_latv_rec_old.NAME ||
          ' expiring lease application template  with ret status '||x_return_status||' x_msg_data '||x_msg_data);
       END IF; -- end of NVL(l_debug_enabled,'N')='Y'

       IF(x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR)THEN
         RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR)THEN
         RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;
       x_latv_rec := x_latv_rec_old;
       x_lavv_rec := x_lavv_rec_new;
     END IF;

     OKL_API.END_ACTIVITY(x_msg_count   => x_msg_count
                         ,x_msg_data    => x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => g_api_type);
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => g_api_type);
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OTHERS',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => g_api_type);
  END version_duplicate_lseapp_tmpl;

  -------------------------------------------------------------------------------
  -- FUNCTION get_lookup_meaning
  -------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Function Name  : get_lookup_meaning
  -- Description     : This function returns the lookup meaning for specified
  --                 : lookup_code and lookup_type
  --
  -- Business Rules  :
  --
  -- Parameters      :
  -- Version         : 1.0
  -- History         : 12-MAY-2005 SKGAUTAM created
  -- End of comments
  FUNCTION get_lookup_meaning( p_lookup_type FND_LOOKUPS.LOOKUP_TYPE%TYPE
                             ,p_lookup_code FND_LOOKUPS.LOOKUP_CODE%TYPE)
    RETURN VARCHAR IS
    CURSOR fnd_lookup_csr(  p_lookup_type fnd_lookups.lookup_type%TYPE
                           ,p_lookup_code fnd_lookups.lookup_code%TYPE) IS
      SELECT MEANING
      FROM  FND_LOOKUPS FND
      WHERE FND.LOOKUP_TYPE = p_lookup_type
      AND   FND.LOOKUP_CODE = p_lookup_code;
    l_return_value VARCHAR2(80) := NULL;
  BEGIN
    IF (  p_lookup_type IS NOT NULL AND p_lookup_code IS NOT NULL )THEN
       OPEN fnd_lookup_csr( p_lookup_type, p_lookup_code );
       FETCH fnd_lookup_csr INTO l_return_value;
       CLOSE fnd_lookup_csr;
    END IF;
    RETURN l_return_value;
  END get_lookup_meaning;

  -------------------------------------------------------------------------------
  -- PROCEDURE put_messages_in_table
  -------------------------------------------------------------------------------
  -- Start of comments
  --
  -- PROCEDURE Name  : put_messages_in_table
  -- Description     : This procedure writes message in error  table
  --
  -- Business Rules  :
  --
  -- Parameters      :
  -- Version         : 1.0
  -- History         : 12-MAY-2005 SKGAUTAM created
  -- End of comments
  PROCEDURE put_messages_in_table(p_msg_name          IN VARCHAR2
                                     ,p_during_upd_flag   IN VARCHAR
                                 ,x_msg_out           OUT NOCOPY VARCHAR2
                                 ,p_token1            IN VARCHAR2 DEFAULT NULL
                                 ,p_value1            IN VARCHAR2 DEFAULT NULL
                                 ,p_token2            IN VARCHAR2 DEFAULT NULL
                                 ,p_value2            IN VARCHAR2 DEFAULT NULL)IS
    l_msg VARCHAR2(2700);
  BEGIN
    FND_MESSAGE.SET_NAME( g_app_name, p_msg_name );
    IF ( p_token1 IS NOT NULL ) THEN
        FND_MESSAGE.SET_TOKEN(  TOKEN => p_token1,
                                VALUE => p_value1);
    END IF;
    IF ( p_token2 IS NOT NULL ) THEN
        FND_MESSAGE.SET_TOKEN(  TOKEN => p_token2,
                                VALUE => p_value2 );
    END IF;
    l_msg := FND_MESSAGE.GET;
    IF ( UPPER(p_during_upd_flag) = 'T' ) THEN
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

  -------------------------------------------------------------------------------
  -- PROCEDURE validate_lease_app_template
  -------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : validate_lease_app_template
  -- Description     : This procedure is a wrapper that validates the asociated
  --                 : checklist , quote and contract templates for
  --                 : lease application template.
  --
  -- Business Rules  : this procedure is used to validate and update lease application template
  --                   this procedure updates records of the OKL_LEASEAPP_TEMPLATES and
  --                   OKL_LEASEAPP_TEMPL_VERSIONS_B  table
  --
  -- Parameters      :
  -- Version         : 1.0
  -- History         : 12-MAY-2005 SKGAUTAM created
  -- End of comments
  PROCEDURE validate_lease_app_template(p_api_version     IN    NUMBER,
                                        p_init_msg_list   IN  VARCHAR2,
                                        x_return_status   OUT NOCOPY VARCHAR2,
                                        x_msg_count       OUT NOCOPY NUMBER,
                                        x_msg_data        OUT NOCOPY VARCHAR2,
                                        p_latv_rec        IN  latv_rec_type,
                                        x_latv_rec        OUT NOCOPY latv_rec_type,
                                        p_lavv_rec        IN  lavv_rec_type,
                                        x_lavv_rec        OUT NOCOPY lavv_rec_type,
                                        p_during_upd_flag IN VARCHAR2,
                                        x_error_msgs_tbl  OUT NOCOPY error_msgs_tbl_type) IS
    -- Variables Declarations
    l_api_version CONSTANT NUMBER       DEFAULT 1.0;
    l_api_name    CONSTANT VARCHAR2(30) DEFAULT 'VALIDATE_LEASEAPP_TEMPLATE';
    l_return_status        VARCHAR2(1)  := OKL_API.G_RET_STS_SUCCESS;
    -- Record/Table Type Declarations
    l_latv_rec                 latv_rec_type;
    lx_latv_rec                latv_rec_type;
    l_lavv_rec                 lavv_rec_type;
    lx_lavv_rec                lavv_rec_type;

    l_error_msgs_tbl     error_msgs_tbl_type;
    l_wrn_msgs_tbl       error_msgs_tbl_type;
    l_msgs_count         NUMBER DEFAULT 0;
    l_message            VARCHAR2(2700);
    l_debug_enabled      VARCHAR2(10);

    --Declare Cursor Definations
    --Validate Checklist template
    CURSOR c_validate_checklist_tmplt(p_lavv_id OKL_LEASEAPP_TEMPL_VERSIONS_V.ID%TYPE) IS
        SELECT CHECKLIST_NUMBER TEMPLATE_NUMBER
        FROM   OKL_CHECKLISTS CHK,
               OKL_LEASEAPP_TEMPLATES LATV,
               OKL_LEASEAPP_TEMPL_VERSIONS_V LAVV
        WHERE  LATV.ID = LAVV.LEASEAPP_TEMPLATE_ID
        AND    LAVV.CHECKLIST_ID = CHK.ID
        AND    ( (LAVV.VALID_FROM NOT BETWEEN NVL(CHK.START_DATE,LAVV.VALID_FROM)
                  AND NVL(CHK.END_DATE,LAVV.VALID_FROM))
                OR CHK.STATUS_CODE <> 'ACTIVE'
                OR CHK.CHECKLIST_PURPOSE_CODE NOT IN ('CHECKLIST_TEMPLATE', 'CHECKLIST_TEMPLATE_GROUP')
                OR CHK.ORG_ID <> LATV.ORG_ID)
        AND    LAVV.ID = p_lavv_id;

    --Validate Contract Template
    CURSOR c_validate_contract_tmplt(p_lavv_id OKL_LEASEAPP_TEMPL_VERSIONS_V.ID%TYPE) IS
        SELECT OKH.CONTRACT_NUMBER TEMPLATE_NUMBER
        FROM   OKC_K_HEADERS_B OKH,
               OKL_LEASEAPP_TEMPLATES LATV,
               OKL_LEASEAPP_TEMPL_VERSIONS_V LAVV,
               OKL_K_HEADERS KHR,
               OKC_STATUSES_V STS
        WHERE  LATV.ID = LAVV.LEASEAPP_TEMPLATE_ID
        AND    LAVV.CONTRACT_TEMPLATE_ID = OKH.ID
        AND    OKH.ID = KHR.ID
        AND    OKH.STS_CODE = STS.CODE
        --Bug#6850094 : Include contract template with any status
        /*
        AND    (TEMPLATE_YN <> 'Y'
                OR STS.STE_CODE <> 'ACTIVE'
                OR NVL(KHR.TEMPLATE_TYPE_CODE, 'X') <> 'LEASEAPP'
                OR OKH.AUTHORING_ORG_ID <> LATV.ORG_ID)
        */
        AND    (OKH.TEMPLATE_YN <> 'Y'
                OR (NVL(KHR.TEMPLATE_TYPE_CODE,'X') ='LEASEAPP' AND STS.STE_CODE <> 'ACTIVE')
                OR NVL(KHR.TEMPLATE_TYPE_CODE, 'X') NOT IN ('LEASEAPP','CONTRACT')
                OR OKH.AUTHORING_ORG_ID <> LATV.ORG_ID)
        --Bug#6850094:End
        AND    LAVV.ID = p_lavv_id;

  -- bug 4741121 - smadhava  - Added - Start
  l_parameter_list WF_PARAMETER_LIST_T;
  l_event_name     wf_events.name%TYPE;
  -- bug 4741121 - smadhava  - Added - End
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    -- check for logging on PROCEDURE level
    l_debug_enabled := okl_debug_pub.check_log_enabled;
    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := OKL_API.START_ACTIVITY( p_api_name      => l_api_name
                                              ,p_pkg_name      => G_PKG_NAME
                                              ,p_init_msg_list => p_init_msg_list
                                              ,l_api_version   => l_api_version
                                              ,p_api_version   => p_api_version
                                              ,p_api_type      => g_api_type
                                              ,x_return_status => x_return_status);
    -- check if activity started successfully
    IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_latv_rec := p_latv_rec;
    l_lavv_rec := p_lavv_rec;
    --Validate the Checklist Template and Poulate the Error Table
    FOR r_validate_checklist_tmplt IN c_validate_checklist_tmplt(l_lavv_rec.ID) LOOP
        l_msgs_count := l_msgs_count+1;
        put_messages_in_table(G_OKL_VAL_CHECKLIST_TEMPLATE
                             ,p_during_upd_flag
                             ,l_message
                             ,p_token1 => G_TEMPLATE_NUMBER
                             ,p_value1 => r_validate_checklist_tmplt.template_number);
        l_error_msgs_tbl(l_msgs_count).error_message      := l_message;
        l_error_msgs_tbl(l_msgs_count).error_type_code    := G_TYPE_ERROR;
        l_error_msgs_tbl(l_msgs_count).error_type_meaning := GET_LOOKUP_MEANING( G_CP_SET_OUTCOME, G_TYPE_ERROR);
    END LOOP;
    --Validate the Contract Template and Populate the Error Table
    FOR r_validate_contract_tmplt IN c_validate_contract_tmplt(l_lavv_rec.ID) LOOP
        l_msgs_count := l_msgs_count+1;
         put_messages_in_table(G_OKL_VAL_CONTRACT_TEMPLATE
                              ,p_during_upd_flag
                              ,l_message
                              ,p_token1 => G_TEMPLATE_NUMBER
                              ,p_value1 => r_validate_contract_tmplt.template_number);
        l_error_msgs_tbl(l_msgs_count).error_message      := l_message;
        l_error_msgs_tbl(l_msgs_count).error_type_code    := G_TYPE_ERROR;
        l_error_msgs_tbl(l_msgs_count).error_type_meaning := GET_LOOKUP_MEANING( G_CP_SET_OUTCOME, G_TYPE_ERROR);
    END LOOP;
    -- Update the template status based on the x_return_status
    -- or l_error_msgs_tbl.COUNT
    -- Determine the status of the Template after the Validation
    IF( l_error_msgs_tbl.COUNT IS NULL OR l_error_msgs_tbl.COUNT = 0 ) THEN
       -- When the status of the template getting updated is Active, after
       -- successful validation , the status remains at Active.
       IF (l_lavv_rec.VERSION_STATUS = G_STATUS_ACTIVE) THEN
           l_lavv_rec.VERSION_STATUS := G_STATUS_ACTIVE;
       ELSE
           -- In all other cases the Template status should be SUBMITED FOR APPROVAL
           -- bug 4741121 - smadhava  - Modified - Start
           l_lavv_rec.VERSION_STATUS  := G_STATUS_SUBMITTEDFORAPPROVAL;
           --raise workflow submit event
           l_event_name := G_WF_EVT_LAT_PENDING;

           -- Add the version id to the wf parameter list
           wf_event.AddParameterToList(G_WF_LAT_VERSION_ID
                              , l_lavv_rec.ID
                              , l_parameter_list);

           -- Check the profile for the AME approval process
           IF NVL(FND_PROFILE.VALUE(G_PROF_FE_APPROVAL_PROCESS),'NONE') = 'NONE' THEN
           activate_lat (p_api_version
                      , p_init_msg_list
                      , l_return_status
                      , x_msg_count
                      , x_msg_data
                      , l_lavv_rec.ID);
           IF l_return_status = OKL_API.G_RET_STS_ERROR THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
           ELSIF l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
           END IF;

         ELSE
           OKL_WF_PVT.raise_event(p_api_version    => p_api_version,
                              p_init_msg_list  => p_init_msg_list,
                              x_return_status  => l_return_status,
                              x_msg_count      => x_msg_count,
                              x_msg_data       => x_msg_data,
                              p_event_name     => l_event_name,
                              p_parameters     => l_parameter_list);
           IF l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
             RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
           ELSIF l_return_status = OKL_API.G_RET_STS_ERROR THEN
             RAISE OKL_API.G_EXCEPTION_ERROR;
           END IF;
         END IF;
           -- bug 4741121 - smadhava  - Modified - End
       END IF;
    ELSE
       -- Change the template status to INVALID
       l_lavv_rec.VERSION_STATUS := G_STATUS_INVALID;

       update_leaseapp_template(p_api_version      => p_api_version
                              ,p_init_msg_list    => p_init_msg_list
                              ,x_return_status    => x_return_status
                              ,x_msg_count        => x_msg_count
                              ,x_msg_data         => x_msg_data
                              ,p_latv_rec         => l_latv_rec
                              ,x_latv_rec         => lx_latv_rec
                              ,p_lavv_rec         => l_lavv_rec
                              ,x_lavv_rec         => lx_lavv_rec
                              ,p_ident_flag       => 'A');
    END IF;

     x_error_msgs_tbl := l_error_msgs_tbl;
     x_latv_rec := l_latv_rec;
     x_lavv_rec := l_lavv_rec;
     OKL_API.END_ACTIVITY(x_msg_count   => x_msg_count
                         ,x_msg_data    => x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => g_api_type);
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => g_api_type);
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OTHERS',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => g_api_type);
  END validate_lease_app_template;

  -------------------------------------------------------------------------------
  -- PROCEDURE max_valid_from_date
  -------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : max_valid_from_date
  -- Description     : This function returns the valid from date after the start dates
  --                 : of all Lease Applications, with statuses 'Submitted to Credit'
  --                 : and greater, and Vendor Programs that use the template.
  --
  -- Business Rules  :
  --
  -- Parameters      :
  -- Version         : 1.0
  -- History         : 12-MAY-2005 SKGAUTAM created
  -- End of comments
  PROCEDURE max_valid_from_date(p_api_version   IN      NUMBER,
                                p_init_msg_list IN  VARCHAR2,
                                x_return_status OUT NOCOPY VARCHAR2,
                                x_msg_count     OUT NOCOPY NUMBER,
                                x_msg_data      OUT NOCOPY VARCHAR2,
                                p_latv_rec      IN  latv_rec_type,
                                x_latv_rec      OUT NOCOPY latv_rec_type)IS
    -- Variables Declarations
    l_api_version CONSTANT NUMBER       DEFAULT 1.0;
    l_api_name    CONSTANT VARCHAR2(30) DEFAULT 'MAX_VALID_FROM_DATE';
    l_return_status        VARCHAR2(1)  := OKL_API.G_RET_STS_SUCCESS;
    -- Record/Table Type Declarations
    l_latv_rec                 latv_rec_type;
    l_max_start_date       DATE;
    l_valid_from           DATE;
    l_valid_to             DATE;
    -- Declare Cursor Definations
    -- Get the max start date from Lease App and Vendor Prog
    -- for associated lease app template
    CURSOR c_get_max_start_date( p_lat_id okl_leaseapp_templates.id%TYPE) IS
    SELECT MAX(START_DATE) max_start_date
    FROM
      (
        SELECT chr.START_DATE START_DATE
        FROM   okc_k_headers_b chr,
               okl_vp_associations vpa,
               Okl_Leaseapp_Templates lat,
               okl_leaseapp_templ_versions_b lav
        WHERE  chr.scs_code = 'PROGRAM'
          AND  chr.sts_code = 'ACTIVE'
          AND  chr.id = vpa.chr_id
          AND  vpa.ASSOC_OBJECT_TYPE_CODE = 'LA_TEMPLATE'
          AND  vpa.ASSOC_OBJECT_ID = lat.ID
          AND  vpa.ASSOC_OBJECT_VERSION  = lav.VERSION_NUMBER
          AND  LAT.ID = LAV.LEASEAPP_TEMPLATE_ID
          AND  lat.ID          =   p_lat_id
        UNION
        SELECT laa.VALID_FROM START_DATE
        FROM   OKL_LEASE_APPLICATIONS_B laa,
               okl_leaseapp_templates lat,
               okl_leaseapp_templ_versions_v lav
        WHERE  lat.id = lav.leaseapp_template_id
        AND    laa.LEASEAPP_TEMPLATE_ID = lav.ID
        AND    laa.APPLICATION_STATUS IN('CONV-CL','CONV-K','CR-APPROVED','CR-SUBMITTED',
                                         'PR-ACCEPTED','PR-APPROVED','PR-SUBMITTED')
        AND    trunc(laa.VALID_FROM) >= trunc(lav.VALID_FROM)
        AND    lat.ID          =   p_lat_id
       ) MY_START_DATE;
    --asawanka bug 4966317 fix starts
    CURSOR get_latest_activever_dates(p_lat_id IN okl_leaseapp_templates.id%TYPE) IS
     /*  SELECT max(to_number(lav.version_number)), lav.valid_from,lav.valid_to
        FROM   okl_leaseapp_templates lat,
               okl_leaseapp_templ_versions_v lav
        WHERE  lat.id = lav.leaseapp_template_id
        AND    lat.id = p_lat_id
        group by lav.valid_from,lav.valid_to;*/
    --Fixed ssdeshpa Bug # 6487421 Start
        SELECT LAV.VERSION_NUMBER
	     , LAV.VALID_FROM
	     , LAV.VALID_TO
	FROM OKL_LEASEAPP_TEMPLATES LAT
	   , OKL_LEASEAPP_TEMPL_VERSIONS_B LAV
	WHERE LAT.ID = LAV.LEASEAPP_TEMPLATE_ID
	  AND LAT.ID = p_lat_id
	  AND TO_NUMBER(LAV.VERSION_NUMBER) = (SELECT MAX(TO_NUMBER(LAV1.VERSION_NUMBER))
	                                       FROM OKL_LEASEAPP_TEMPL_VERSIONS_B LAV1
                                               WHERE LAV1.LEASEAPP_TEMPLATE_ID = LAT.ID);
    --Fixed ssdeshpa Bug # 6487421 End
    --asawanka bug 4966317 fix ends
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := OKL_API.START_ACTIVITY( p_api_name      => l_api_name
                                              ,p_pkg_name      => G_PKG_NAME
                                              ,p_init_msg_list => p_init_msg_list
                                              ,l_api_version   => l_api_version
                                              ,p_api_version   => p_api_version
                                              ,p_api_type      => g_api_type
                                              ,x_return_status => x_return_status);
    -- check if activity started successfully
    IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_latv_rec := p_latv_rec;
    -- Fetch the Maximum of Start Date of the Vendor Program and Lease application using this template
    FOR r_new_date_rec IN c_get_max_start_date(l_latv_rec.id) LOOP
           l_max_start_date := r_new_date_rec.max_start_date;
    END LOOP;
    --asawanka bug 4966317 fix starts
    FOR r_actver_dates_rec IN get_latest_activever_dates(l_latv_rec.id) LOOP
           l_valid_from := r_actver_dates_rec.valid_from;
           l_valid_to   := r_actver_dates_rec.valid_to;
    END LOOP;
    --asawanka bug 4966317 fix ends
    IF(l_max_start_date IS NULL) THEN
       --asawanka bug 4966317 fix starts
       -- If no start_date is found, then take the previous version valid to date,
       -- if present, else take previous version valid from
       -- as the max_Start_date
       IF l_valid_to IS NULL THEN
        l_max_start_date := l_valid_from;
       ELSE
        l_max_start_date := l_valid_to;
       END IF;
    END IF;
    IF l_valid_to IS NOT NULL AND l_valid_to > l_max_start_date THEN
        l_max_start_date := l_valid_to;
    END IF;
    --Bug 5149659 PAGARG If max start date is less than valid from of the current
    --version then set valid from of current version as max start date
    IF l_max_start_date < l_valid_from
    THEN
      l_max_start_date := l_valid_from;
    END IF;
    -- New version template valid from date will be updated with l_max_start_date + 1
    l_latv_rec.valid_from := l_max_start_date + 1;
    --asawanka bug 4966317 fix ends
    x_latv_rec := l_latv_rec;
    OKL_API.END_ACTIVITY(x_msg_count => x_msg_count
                        ,x_msg_data      => x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => g_api_type);
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => g_api_type);
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OTHERS',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => g_api_type);
  END max_valid_from_date;

END OKL_LEASEAPP_TEMPLATE_PVT;

/
