--------------------------------------------------------
--  DDL for Package Body OKL_SUBSIDY_POOL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_SUBSIDY_POOL_PVT" AS
 /* $Header: OKLRSIPB.pls 120.2 2005/09/12 23:45:28 cklee noship $ */

G_WF_EVT_SUBSIDY_POOL_PENDING  CONSTANT wf_events.name%TYPE DEFAULT 'oracle.apps.okl.subsidy_pool.pool_pending_approval';
G_WF_EVT_SUBSIDY_POOL_APPROVED CONSTANT wf_events.name%TYPE DEFAULT 'oracle.apps.okl.subsidy_pool.pool_approved';
G_WF_EVT_SUBSIDY_POOL_REJECTED CONSTANT wf_events.name%TYPE DEFAULT 'oracle.apps.okl.subsidy_pool.pool_rejected';
G_WF_ITM_SUB_POOL_ID  CONSTANT VARCHAR2(30)       := 'SUBSIDY_POOL_ID';

  -- Cursor to fetch the record with the passed id.
  CURSOR   c_get_pool_id (cp_pool_id IN okl_subsidy_pools_b.id%type) IS
   SELECT   id
           ,object_version_number
           ,sfwt_flag
           ,pool_type_code
           ,subsidy_pool_name
           ,short_description
           ,description
           ,effective_from_date
           ,effective_to_date
           ,currency_code
           ,currency_conversion_type
           ,decision_status_code
           ,subsidy_pool_id
           ,reporting_pool_limit
           ,total_budgets
           ,total_subsidy_amount
           ,decision_date
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
   FROM   OKL_SUBSIDY_POOLS_V
   WHERE  id = cp_pool_id;

-------------------------------------------------------------------------------
-- PROCEDURE raise_business_event
-------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : raise_business_event
-- Description     : This procedure is a wrapper that raises a business event
--                 : when ever a subsidy pool record is submitted for approval, approved, rejected
-- Business Rules  : the event is raised based on the decision_status_code passed and
--                   successful updation of the pool record
-- Parameters      :
-- Version         : 1.0
-- History         :
-- End of comments
-----------------------------------------------------------------------------------------
PROCEDURE raise_business_event(p_api_version IN NUMBER,
                               p_init_msg_list IN VARCHAR2,
                               x_return_status OUT NOCOPY VARCHAR2,
                               x_msg_count OUT NOCOPY NUMBER,
                               x_msg_data OUT NOCOPY VARCHAR2,
                               p_event_name IN VARCHAR2,
                               p_event_param_list IN WF_PARAMETER_LIST_T
                               ) IS
  l_event_param_list WF_PARAMETER_LIST_T ;
BEGIN
  x_return_status := OKL_API.G_RET_STS_SUCCESS;
  l_event_param_list := p_event_param_list;

  OKL_WF_PVT.raise_event(p_api_version    => p_api_version,
                         p_init_msg_list  => p_init_msg_list,
                         x_return_status  => x_return_status,
                         x_msg_count      => x_msg_count,
                         x_msg_data       => x_msg_data,
                         p_event_name     => p_event_name,
                         p_parameters     => l_event_param_list);
EXCEPTION
  WHEN OTHERS THEN
  x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
  RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
END raise_business_event;

 ---------------------------------------------------------------------------
 -- PROCEDURE create_sub_pool
 ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : create_sub_pool
  -- Description     : procedure for inserting the records in
  --                   table OKL_SUBSIDY_POOLS_B AND OKL_SUBSIDY_POOLS_TL
  -- Business Rules  : This procedure creates a subsidy pool with the status "new"
  --                   in the table OKL_SUBSIDY_POOLS_B.
  -- Parameters      : p_api_version, p_init_msg_list, x_return_status, x_msg_count,
  --                   x_msg_data, p_sub_pool_rec, x_sub_pool_rec.
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE create_sub_pool     ( p_api_version      IN  NUMBER
                                 ,p_init_msg_list    IN  VARCHAR2
                                 ,x_return_status    OUT NOCOPY VARCHAR2
                                 ,x_msg_count        OUT NOCOPY NUMBER
                                 ,x_msg_data         OUT NOCOPY VARCHAR2
                                 ,p_sub_pool_rec     IN  subsidy_pool_rec
                                 ,x_sub_pool_rec     OUT NOCOPY subsidy_pool_rec
                                ) IS

---------------------------
-- DECLARE Local Variables
---------------------------
  L_MODULE                   CONSTANT fnd_log_messages.module%TYPE := 'okl.plsql.OKL_SUBSIDY_POOL_PVT.CREATE_SUB_POOL';
  L_DEBUG_ENABLED            VARCHAR2(10);
  L_LEVEL_PROCEDURE          fnd_log_messages.log_level%TYPE;
  IS_DEBUG_PROCEDURE_ON      BOOLEAN;
  l_sub_pool_rec             subsidy_pool_rec ;
  l_effective_to_date        OKL_SUBSIDY_POOLS_B.EFFECTIVE_TO_DATE%TYPE ;
  l_total_budgets            OKL_SUBSIDY_POOLS_B.TOTAL_BUDGETS%TYPE ;
  l_system_date              DATE ;
  l_api_version	             NUMBER ;
  l_init_msg_list	     VARCHAR2(1) ;
  l_return_status	     VARCHAR2(1);
  l_msg_count	             NUMBER ;
  l_msg_data	    	     VARCHAR2(2000);
  l_api_name                 CONSTANT VARCHAR2(30) := 'create_sub_pool';

-------------------
-- DECLARE Cursors
-------------------


BEGIN
   L_DEBUG_ENABLED := Okl_Debug_Pub.CHECK_LOG_ENABLED;
   IF(L_DEBUG_ENABLED='Y') THEN
     L_LEVEL_PROCEDURE :=Fnd_Log.LEVEL_PROCEDURE;
     IS_DEBUG_PROCEDURE_ON := Okl_Debug_Pub.Check_Log_On(L_MODULE, L_LEVEL_PROCEDURE);
   END IF;
   IF(IS_DEBUG_PROCEDURE_ON) THEN
     BEGIN
        Okl_Debug_Pub.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRSIPB.pls call okl_sip_pvt.insert_row ');
     END;
   END IF;

   l_sub_pool_rec := p_sub_pool_rec;
   l_effective_to_date :=  l_sub_pool_rec.effective_to_date;
   l_total_budgets := l_sub_pool_rec.total_budgets;
   l_system_date :=  TRUNC(SYSDATE);
   l_api_version := 1.0;
   l_init_msg_list := OKL_API.g_false;
   l_msg_count := 0;

   SAVEPOINT create_sub_pool_PVT;
   l_return_status := OKL_API.START_ACTIVITY( l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              l_return_status);

   IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
   ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
   END IF;

   -- check trunc(effective to date) < trunc(sysdate)
   IF ((p_sub_pool_rec.EFFECTIVE_TO_DATE is NOT NULL) AND (p_sub_pool_rec.EFFECTIVE_TO_DATE < TRUNC(SYSDATE))) THEN
      -- Message Text: Effective to date must be greater than or equal to system date.
      l_return_status := OKL_API.G_RET_STS_ERROR;
      OKL_API.set_message( p_app_name      => G_APP_NAME,
                           p_msg_name      => 'OKL_AM_DATE_EFF_TO_PAST');
      RAISE G_EXCEPTION_HALT_VALIDATION;
   END IF;

   -- if the totoal budget amount is null set it to zero.
   IF (l_total_budgets = OKL_API.G_MISS_NUM OR l_total_budgets IS NULL) THEN
      l_total_budgets := 0;
   END IF;
   l_sub_pool_rec.total_budgets := l_total_budgets;

   -- TAPI call to create a record for subsidy pool in table OKL_SUBSIDY_POOLS_B.
   okl_sip_pvt.insert_row( l_api_version,
                           l_init_msg_list,
                           l_return_status,
                           l_msg_count,
                           l_msg_data,
                           l_sub_pool_rec,
                           x_sub_pool_rec);

   IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
   ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
   END IF;

   okl_api.END_ACTIVITY(x_msg_count, x_msg_data);
   x_return_status := l_return_status;
   x_msg_data      := l_msg_data;
   x_msg_count     := l_msg_count;

  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        Okl_Debug_Pub.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRSIPB.pls call okl_sip_pvt.insert_row ');
    END;
  END IF;

  EXCEPTION
     WHEN G_EXCEPTION_HALT_VALIDATION THEN
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

     WHEN OTHERS THEN
       x_return_status := OKL_API.HANDLE_EXCEPTIONS
       (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
       );

END create_sub_pool;

 ---------------------------------------------------------------------------
 -- PROCEDURE update_sub_pool
 ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : update_sub_pool
  -- Description     : procedure for updating the records in
  --                   table OKL_SUBSIDY_POOLS_B AND OKL_SUBSIDY_POOLS_TL
  -- Business Rules  : Procedure to update the subsidy pool.
  -- Parameters      : p_api_version, p_init_msg_list, x_return_status, x_msg_count,
  --                   x_msg_data, p_sub_pool_rec, x_sub_pool_rec.
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------

  PROCEDURE update_sub_pool     ( p_api_version      IN  NUMBER
                                 ,p_init_msg_list    IN  VARCHAR2
                                 ,x_return_status    OUT NOCOPY VARCHAR2
                                 ,x_msg_count        OUT NOCOPY NUMBER
                                 ,x_msg_data         OUT NOCOPY VARCHAR2
                                 ,p_sub_pool_rec     IN  subsidy_pool_rec
                                 ,x_sub_pool_rec     OUT NOCOPY subsidy_pool_rec
                                ) IS
---------------------------
-- DECLARE Local Variables
---------------------------
  L_MODULE                   CONSTANT fnd_log_messages.module%TYPE := 'okl.plsql.OKL_SUBSIDY_POOL_PVT.UPDATE_SUB_POOL';
  L_DEBUG_ENABLED            VARCHAR2(10);
  L_LEVEL_PROCEDURE          fnd_log_messages.log_level%TYPE;
  IS_DEBUG_PROCEDURE_ON      BOOLEAN;
  l_sub_pool_rec             subsidy_pool_rec ;
  l_effective_to_date        OKL_SUBSIDY_POOLS_B.EFFECTIVE_TO_DATE%TYPE ;
  l_db_effective_to          OKL_SUBSIDY_POOLS_B.EFFECTIVE_TO_DATE%TYPE ;
  l_trx_date                 OKL_TRX_SUBSIDY_POOLS.TRX_DATE%TYPE;
  l_status_code              OKL_SUBSIDY_POOLS_B.DECISION_STATUS_CODE%TYPE ;
  l_system_date              DATE;
  l_api_version		     NUMBER ;
  l_init_msg_list	     VARCHAR2(1) ;
  l_return_status	     VARCHAR2(1);
  l_msg_count	             NUMBER ;
  l_msg_data	    	     VARCHAR2(2000);
  l_api_name                 CONSTANT VARCHAR2(30) := 'update_sub_pool';
  l_dummy               VARCHAR2(1);
  l_pool_name          okl_subsidy_pools_b.subsidy_pool_name%TYPE ;
-------------------
-- DECLARE Cursors
-------------------
  -- cursor to fetch the effective to date of the pool id passed.
  CURSOR   c_get_to_date (cp_pool_id IN okl_subsidy_pools_b.id%type) IS
   SELECT   effective_to_date
   FROM okl_subsidy_pools_v
   WHERE id = cp_pool_id;

  -- Cursor to check whether the subsidies dates overlap with the subsidy pool dates.
  CURSOR c_get_subsidy_date (cp_effective_to okl_subsidy_pools_b.effective_to_date%TYPE, cp_pool_id okl_subsidy_pools_B.id%TYPE) IS
    SELECT   'X'
    FROM   okl_subsidy_pools_v pool, okl_subsidies_b sub
    WHERE  sub.subsidy_pool_id = pool.id
    AND    pool.id = cp_pool_id
    AND  (
         NOT  ((pool.effective_from_date BETWEEN sub.effective_from_date AND NVL(sub.effective_to_date,(TO_DATE('1','j') + 5300000)))
          OR (sub.effective_from_date BETWEEN pool.effective_from_date AND cp_effective_to))
        );

  -- Cursor for fetching the transaction date for the subsidy pool.
  CURSOR   c_get_trx_date (cp_pool_id IN okl_subsidy_pools_b.id%type) IS
  SELECT max(TRUNC(trx_date))
  FROM okl_trx_subsidy_pools
  WHERE subsidy_pool_id = cp_pool_id;



BEGIN
   L_DEBUG_ENABLED := Okl_Debug_Pub.CHECK_LOG_ENABLED;
   IF(L_DEBUG_ENABLED='Y') THEN
     L_LEVEL_PROCEDURE :=Fnd_Log.LEVEL_PROCEDURE;
     IS_DEBUG_PROCEDURE_ON := Okl_Debug_Pub.Check_Log_On(L_MODULE, L_LEVEL_PROCEDURE);
   END IF;
   IF(IS_DEBUG_PROCEDURE_ON) THEN
     BEGIN
        Okl_Debug_Pub.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRSIPB.pls call okl_sip_pvt.update_row ');
     END;
   END IF;
   l_sub_pool_rec := p_sub_pool_rec;
   l_effective_to_date := l_sub_pool_rec.effective_to_date;
   l_status_code := l_sub_pool_rec.decision_status_code;
--START:cklee 09/12/2005
--cklee 09/12/2005   l_sub_pool_rec.decision_status_code := TRUNC(SYSDATE);
   l_system_date := TRUNC(SYSDATE);
--END:cklee 09/12/2005
   l_api_version := 1.0;
   l_init_msg_list := OKL_API.g_false;
   l_msg_count := 0;
   l_pool_name := l_sub_pool_rec.subsidy_pool_name;

   SAVEPOINT update_sub_pool_PVT;
   l_return_status := OKL_API.START_ACTIVITY( l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              l_return_status);

   IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
   ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
   END IF;

   OPEN c_get_to_date(l_sub_pool_rec.id);
    FETCH c_get_to_date INTO l_db_effective_to;
    CLOSE c_get_to_date;

   -- if user updates a effective to date of subsidy pool to less than the system date
   -- then set the status of pool to "expired" otherwise update the subsidy pool.
   IF  ((l_effective_to_date is not null) AND
        (nvl(l_db_effective_to,okl_accounting_util.g_final_date) <> l_effective_to_date)AND
        (l_effective_to_date < l_system_date)) THEN
     -- effective to date cannot be less than the system date if pool status is "NEW"
     -- if pool status is "ACTIVE" and effective to date is less than system date then change
     -- the pool status to "EXPIRED".
     IF(l_sub_pool_rec.decision_status_code = 'NEW') THEN
        l_return_status := OKL_API.G_RET_STS_ERROR;
        OKL_API.set_message( p_app_name      => G_APP_NAME,
                             p_msg_name      => 'OKL_AM_DATE_EFF_TO_PAST');
        RAISE G_EXCEPTION_HALT_VALIDATION;
     ELSE
       l_status_code := 'EXPIRED';
     END IF;
   END IF;

   l_sub_pool_rec.decision_status_code :=  l_status_code;

   -- If effective to date of subsidy pool is updated, and the effective dates of the subsidies
   -- attached to the pool do not overlap then throw an error that the date cannot be updated.
   IF  ((l_effective_to_date is not null) AND
        (nvl(l_db_effective_to,okl_accounting_util.g_final_date) <> l_effective_to_date)) THEN
      OPEN c_get_subsidy_date(l_effective_to_date,l_sub_pool_rec.id);
      FETCH c_get_subsidy_date INTO l_dummy;
      IF (c_get_subsidy_date%FOUND) THEN
          CLOSE c_get_subsidy_date;
          x_return_status := OKC_API.G_RET_STS_ERROR;
          OKC_API.set_message( p_app_name      => G_APP_NAME,
                               p_msg_name      => 'OKL_SUB_POOL_NO_DATE_OVERLAP',
                               p_token1       => 'POOL_NAME',
                               p_token1_value => l_pool_name);
          RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
         CLOSE c_get_subsidy_date;
      END IF;
   END IF;

   -- If the effective to date is less than the transation date for the subsidy pool
   -- then throw error that user cannot modify the effective to date less than the transaction date.
   IF  ((l_effective_to_date is not null) AND
        (nvl(l_db_effective_to,okl_accounting_util.g_final_date) <> l_effective_to_date)) THEN
      OPEN c_get_trx_date(l_sub_pool_rec.id);
      FETCH c_get_trx_date INTO l_trx_date;
      IF (c_get_trx_date%FOUND AND l_effective_to_date < l_trx_date) THEN
          CLOSE c_get_trx_date;
          x_return_status := OKC_API.G_RET_STS_ERROR;
          OKC_API.set_message( p_app_name      => G_APP_NAME,
                               p_msg_name      => 'OKL_SUB_POOL_TRX_DATE',
                               p_token1       => 'POOL_NAME',
                               p_token1_value => l_sub_pool_rec.subsidy_pool_name,
                               p_token2       => 'TRX_DATE',
                               p_token2_value => l_trx_date);
          RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
          CLOSE c_get_trx_date;
      END IF;
  END IF;

   -- TAPI call to update the subsidy pool in table OKL_SUBSIDY_POOLS_B.
   okl_sip_pvt.update_row(l_api_version,
                          l_init_msg_list,
                          l_return_status,
                          l_msg_count,
                          l_msg_data,
                          l_sub_pool_rec,
                          x_sub_pool_rec);

   IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
   ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
   END IF;

   okl_api.END_ACTIVITY(x_msg_count, x_msg_data);
   x_return_status := l_return_status;
   x_msg_data      := l_msg_data;
   x_msg_count     := l_msg_count;

  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        Okl_Debug_Pub.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRSIPB.pls call okl_sip_pvt.update_row ');
    END;
  END IF;

  EXCEPTION
     WHEN G_EXCEPTION_HALT_VALIDATION THEN
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

     WHEN OTHERS THEN
       x_return_status := OKL_API.HANDLE_EXCEPTIONS
       (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
       );
END update_sub_pool;

 ---------------------------------------------------------------------------
 -- PROCEDURE expire_sub_pool
 ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : expire_sub_pool
  -- Description     : procedure for validating that if the records exist in the
  --                   table OKL_SUBSIDY_POOLS_B then set its status to expire.
  -- Business Rules  : This procedure sets the pool status to "expire"and this is
  --                   an autonomous transaction.
  -- Parameters      : p_api_version, p_init_msg_list, x_return_status, x_msg_count,
  --                   x_msg_data, p_subsidy_pool_id.
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------

 PROCEDURE expire_sub_pool ( p_api_version                  IN  NUMBER,
                             p_init_msg_list                IN  VARCHAR2,
                             x_return_status                OUT NOCOPY VARCHAR2,
                             x_msg_count                    OUT NOCOPY NUMBER,
                             x_msg_data                     OUT NOCOPY VARCHAR2,
                             p_subsidy_pool_id              IN  okl_subsidy_pools_b.id%TYPE) IS
---------------------------
-- DECLARE Local Variables
---------------------------
  L_MODULE              CONSTANT fnd_log_messages.module%TYPE := 'okl.plsql.OKL_SUBSIDY_POOL_PVT.EXPIRE_SUB_POOL';
  L_DEBUG_ENABLED       VARCHAR2(10);
  L_LEVEL_PROCEDURE     fnd_log_messages.log_level%TYPE;
  IS_DEBUG_PROCEDURE_ON BOOLEAN;
  l_sub_pool_rec        subsidy_pool_rec;
  l_subsidy_pool_id     OKL_SUBSIDY_POOLS_B.ID%TYPE ;
  x_sub_pool_rec        subsidy_pool_rec;
  l_row_found	        BOOLEAN ;
  l_api_version	        NUMBER ;
  l_init_msg_list       VARCHAR2(1) ;
  l_return_status       VARCHAR2(1);
  l_msg_count	        NUMBER ;
  l_msg_data	    	VARCHAR2(2000);
  l_api_name            CONSTANT VARCHAR2(30) := 'expire_sub_pool';

-------------------
-- DECLARE Cursors
-------------------

  -- this procedure uses autonomous transaction, which will always be commited
  -- irrespective of the calling procedure.

  PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
  L_DEBUG_ENABLED := Okl_Debug_Pub.CHECK_LOG_ENABLED;
  IF(L_DEBUG_ENABLED='Y') THEN
    L_LEVEL_PROCEDURE :=Fnd_Log.LEVEL_PROCEDURE;
    IS_DEBUG_PROCEDURE_ON := Okl_Debug_Pub.Check_Log_On(L_MODULE, L_LEVEL_PROCEDURE);
  END IF;
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        Okl_Debug_Pub.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRSIPB.pls call okl_sip_pvt.update_row ');
    END;
  END IF;
  l_subsidy_pool_id :=  p_subsidy_pool_id;
  l_row_found := FALSE;
  l_api_version := 1.0;
  l_init_msg_list := OKL_API.g_false;
  l_msg_count := 0;

  SAVEPOINT expire_sub_pool_PVT;
  l_return_status := OKL_API.START_ACTIVITY( l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              l_return_status);

  IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
     RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
     RAISE OKL_API.G_EXCEPTION_ERROR;
  END IF;

  -- fetch the record with the passed id .
  OPEN c_get_pool_id(l_subsidy_pool_id);
   FETCH c_get_pool_id INTO l_sub_pool_rec;
   l_row_found := c_get_pool_id%FOUND;
  CLOSE c_get_pool_id;

  -- If a row exists then set the status of pool to "expired" and commit it.
  -- this is an autonomous transaction and will get commited irrespective of the calling procedure.
  IF l_row_found THEN
    l_sub_pool_rec.decision_status_code := 'EXPIRED';
    okl_sip_pvt.update_row(l_api_version,
                           l_init_msg_list,
                           l_return_status,
                           l_msg_count,
                           l_msg_data,
                           l_sub_pool_rec,
                           x_sub_pool_rec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
  END IF;
   okl_api.END_ACTIVITY(x_msg_count, x_msg_data);
   x_return_status := l_return_status;
   x_msg_data      := l_msg_data;
   x_msg_count     := l_msg_count;

   COMMIT;
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        Okl_Debug_Pub.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRSIPB.pls call okl_sip_pvt.update_row ');
    END;
  END IF;

  EXCEPTION
     WHEN G_EXCEPTION_HALT_VALIDATION THEN
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

     WHEN OTHERS THEN
       x_return_status := OKL_API.HANDLE_EXCEPTIONS
       (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
       );
 END expire_sub_pool;

 ---------------------------------------------------------------------------
 -- PROCEDURE update_total_budget
 ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : update_total_budget
  -- Description     : procedure for updating the total budget amount
  --                   table OKL_SUBSIDY_POOLS_B.
  -- Business Rules  : As soon as any of the budget line attached to a subsisy pool gets
  --                   approved this procedure is called to update the total budgets of the pool
  -- Parameters      : p_api_version, p_init_msg_list, x_return_status, x_msg_count,
  --                   x_msg_data, p_subsidy_pool_id,p_total_budget_amt.
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------

PROCEDURE update_total_budget ( p_api_version                  IN  NUMBER,
                                p_init_msg_list                IN  VARCHAR2,
                                x_return_status                OUT NOCOPY VARCHAR2,
                                x_msg_count                    OUT NOCOPY NUMBER,
                                x_msg_data                     OUT NOCOPY VARCHAR2,
                                p_subsidy_pool_id              IN  okl_subsidy_pools_b.id%TYPE,
                                p_total_budget_amt             IN  okl_subsidy_pools_b.total_budgets%TYPE ) IS
---------------------------
-- DECLARE Local Variables
---------------------------
  L_MODULE              CONSTANT fnd_log_messages.module%TYPE := 'okl.plsql.OKL_SUBSIDY_POOL_PVT.UPDATE_TOTAL_BUDGET';
  L_DEBUG_ENABLED       VARCHAR2(10);
  L_LEVEL_PROCEDURE     fnd_log_messages.log_level%TYPE;
  IS_DEBUG_PROCEDURE_ON BOOLEAN;
  l_sub_pool_rec        subsidy_pool_rec;
  l_subsidy_pool_id     OKL_SUBSIDY_POOLS_B.ID%TYPE ;
  x_sub_pool_rec        subsidy_pool_rec;
  l_row_found	        BOOLEAN ;
  l_api_version	        NUMBER ;
  l_init_msg_list	VARCHAR2(1) ;
  l_return_status	VARCHAR2(1);
  l_msg_count	        NUMBER ;
  l_msg_data	    	VARCHAR2(2000);
  l_api_name            CONSTANT VARCHAR2(30) := 'update_total_budget';

-------------------
-- DECLARE Cursors
-------------------

BEGIN
  L_DEBUG_ENABLED := Okl_Debug_Pub.CHECK_LOG_ENABLED;
  IF(L_DEBUG_ENABLED='Y') THEN
    L_LEVEL_PROCEDURE :=Fnd_Log.LEVEL_PROCEDURE;
    IS_DEBUG_PROCEDURE_ON := Okl_Debug_Pub.Check_Log_On(L_MODULE, L_LEVEL_PROCEDURE);
  END IF;
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        Okl_Debug_Pub.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRSIPB.pls call okl_sip_pvt.update_row ');
    END;
  END IF;
  l_subsidy_pool_id := p_subsidy_pool_id;
  l_row_found := FALSE;
  l_api_version := 1.0;
  l_init_msg_list := OKL_API.g_false;
  l_msg_count := 0;

  SAVEPOINT update_total_budget_PVT;
  l_return_status := OKL_API.START_ACTIVITY( l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              l_return_status);

  IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
     RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
     RAISE OKL_API.G_EXCEPTION_ERROR;
  END IF;

  -- fetch the record with the passed id.
  OPEN c_get_pool_id(l_subsidy_pool_id);
   FETCH c_get_pool_id INTO l_sub_pool_rec;
   l_row_found := c_get_pool_id%FOUND;
  CLOSE c_get_pool_id;

  -- if row is found then update the total budget amount with the amount passed to it as a parameter.
  IF l_row_found THEN
    l_sub_pool_rec.total_budgets := p_total_budget_amt;
    okl_sip_pvt.update_row(l_api_version,
                           l_init_msg_list,
                           l_return_status,
                           l_msg_count,
                           l_msg_data,
                           l_sub_pool_rec,
                           x_sub_pool_rec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
  END IF;
   okl_api.END_ACTIVITY(x_msg_count, x_msg_data);
   x_return_status := l_return_status;
   x_msg_data      := l_msg_data;
   x_msg_count     := l_msg_count;

  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        Okl_Debug_Pub.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRSIPB.pls call okl_sip_pvt.update_row ');
    END;
  END IF;

  EXCEPTION
     WHEN G_EXCEPTION_HALT_VALIDATION THEN
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

     WHEN OTHERS THEN
       x_return_status := OKL_API.HANDLE_EXCEPTIONS
       (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
       );
 END update_total_budget;

 ---------------------------------------------------------------------------
 -- PROCEDURE update_subsidy_amount
 ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : update_subsidy_amount
  -- Description     : procedure for updating the total subsidy amount
  --                   table OKL_SUBSIDY_POOLS_B.
  -- Business Rules  : subsidy amount is updated when the contract is booked, rebooked or a
  --                   quote is created, or a contract is reversed.
  -- Parameters      : p_api_version, p_init_msg_list, x_return_status, x_msg_count,
  --                   x_msg_data, p_subsidy_pool_id, p_total_subsidy_amt.
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------

PROCEDURE update_subsidy_amount ( p_api_version            IN  NUMBER,
                                  p_init_msg_list                IN  VARCHAR2,
                                  x_return_status                OUT NOCOPY VARCHAR2,
                                  x_msg_count                    OUT NOCOPY NUMBER,
                                  x_msg_data                     OUT NOCOPY VARCHAR2,
                                  p_subsidy_pool_id              IN  okl_subsidy_pools_b.id%TYPE,
                                  p_total_subsidy_amt            IN  okl_subsidy_pools_b.total_subsidy_amount%TYPE) IS

---------------------------
-- DECLARE Local Variables
---------------------------
  L_MODULE              CONSTANT fnd_log_messages.module%TYPE := 'okl.plsql.OKL_SUBSIDY_POOL_PVT.UPDATE_SUBSIDY_AMOUNT';
  L_DEBUG_ENABLED       VARCHAR2(10);
  L_LEVEL_PROCEDURE     fnd_log_messages.log_level%TYPE;
  IS_DEBUG_PROCEDURE_ON BOOLEAN;
  l_sub_pool_rec        subsidy_pool_rec;
  l_subsidy_pool_id     OKL_SUBSIDY_POOLS_B.ID%TYPE ;
  x_sub_pool_rec        subsidy_pool_rec;
  l_row_found	        BOOLEAN ;
  l_api_version	        NUMBER ;
  l_init_msg_list       VARCHAR2(1);
  l_return_status       VARCHAR2(1);
  l_msg_count	        NUMBER;
  l_msg_data	        VARCHAR2(2000);
  l_api_name            CONSTANT VARCHAR2(30) := 'update_subsidy_amount';

-------------------
-- DECLARE Cursors
-------------------

BEGIN
  L_DEBUG_ENABLED := Okl_Debug_Pub.CHECK_LOG_ENABLED;
  IF(L_DEBUG_ENABLED='Y') THEN
    L_LEVEL_PROCEDURE :=Fnd_Log.LEVEL_PROCEDURE;
    IS_DEBUG_PROCEDURE_ON := Okl_Debug_Pub.Check_Log_On(L_MODULE, L_LEVEL_PROCEDURE);
  END IF;
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        Okl_Debug_Pub.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRSIPB.pls call okl_sip_pvt.update_row ');
    END;
  END IF;
  l_subsidy_pool_id := p_subsidy_pool_id;
  l_row_found := FALSE;
  l_api_version := 1.0;
  l_init_msg_list := OKL_API.g_false;
  l_msg_count := 0;

  SAVEPOINT update_subsidy_amount_PVT;
  l_return_status := OKL_API.START_ACTIVITY( l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              l_return_status);

  IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
     RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
     RAISE OKL_API.G_EXCEPTION_ERROR;
  END IF;

  OPEN c_get_pool_id(l_subsidy_pool_id);
   FETCH c_get_pool_id INTO l_sub_pool_rec;
   l_row_found := c_get_pool_id%FOUND;
  CLOSE c_get_pool_id;

  -- if a row is found then update the total subsidy amount to the amount passed.
  IF l_row_found THEN
    l_sub_pool_rec.total_subsidy_amount := p_total_subsidy_amt;
    okl_sip_pvt.update_row(l_api_version,
                           l_init_msg_list,
                           l_return_status,
                           l_msg_count,
                           l_msg_data,
                           l_sub_pool_rec,
                           x_sub_pool_rec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
  END IF;
   okl_api.END_ACTIVITY(x_msg_count, x_msg_data);
   x_return_status := l_return_status;
   x_msg_data      := l_msg_data;
   x_msg_count     := l_msg_count;

  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        Okl_Debug_Pub.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRSIPB.pls call okl_sip_pvt.update_row ');
    END;
  END IF;

  EXCEPTION
     WHEN G_EXCEPTION_HALT_VALIDATION THEN
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

     WHEN OTHERS THEN
       x_return_status := OKL_API.HANDLE_EXCEPTIONS
       (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
       );
 END update_subsidy_amount;

 ---------------------------------------------------------------------------
 -- PROCEDURE set_decision_status_code
 ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : set_decision_status_code
  -- Description     : procedure for updating the decision status code
  --                   table OKL_SUBSIDY_POOLS_B.
  -- Business Rules  : Procedure sets the decision_status_code to the value passed to this procedure.
  --                   this is a status of a pool.
  -- Parameters      : p_api_version, p_init_msg_list, x_return_status, x_msg_count,
  --                   x_msg_data, p_subsidy_pool_id, p_total_subsidy_amt,p_decision_status_code.
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------

PROCEDURE set_decision_status_code ( p_api_version            IN  NUMBER,
                                     p_init_msg_list                IN  VARCHAR2,
                                     x_return_status                OUT NOCOPY VARCHAR2,
                                     x_msg_count                    OUT NOCOPY NUMBER,
                                     x_msg_data                     OUT NOCOPY VARCHAR2,
                                     p_subsidy_pool_id              IN  okl_subsidy_pools_b.id%TYPE,
                                     p_decision_status_code         IN OUT NOCOPY okl_subsidy_pools_b.decision_status_code%TYPE) IS

---------------------------
-- DECLARE Local Variables
---------------------------
  L_MODULE              CONSTANT fnd_log_messages.module%TYPE := 'okl.plsql.OKL_SUBSIDY_POOL_PVT.SET_DECISION_STATUS_CODE';
  L_DEBUG_ENABLED       VARCHAR2(10);
  L_LEVEL_PROCEDURE     fnd_log_messages.log_level%TYPE;
  IS_DEBUG_PROCEDURE_ON BOOLEAN;
  l_sub_pool_rec        subsidy_pool_rec;
  l_subsidy_pool_id     OKL_SUBSIDY_POOLS_B.ID%TYPE ;
  x_sub_pool_rec        subsidy_pool_rec;
  l_row_found		BOOLEAN	;
  l_api_version		NUMBER ;
  l_init_msg_list       VARCHAR2(1) ;
  l_return_status       VARCHAR2(1);
  l_msg_count	        NUMBER ;
  l_msg_data	        VARCHAR2(2000);
  l_api_name            CONSTANT VARCHAR2(30) := 'set_decision_status_code';
  l_parameter_list WF_PARAMETER_LIST_T;
  l_event_name      wf_events.name%TYPE;
  l_system_date          CONSTANT DATE DEFAULT TRUNC(SYSDATE);
-------------------
-- DECLARE Cursors
-------------------

BEGIN
  L_DEBUG_ENABLED := Okl_Debug_Pub.CHECK_LOG_ENABLED;
  IF(L_DEBUG_ENABLED='Y') THEN
    L_LEVEL_PROCEDURE :=Fnd_Log.LEVEL_PROCEDURE;
    IS_DEBUG_PROCEDURE_ON := Okl_Debug_Pub.Check_Log_On(L_MODULE, L_LEVEL_PROCEDURE);
  END IF;
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        Okl_Debug_Pub.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRSIPB.pls call okl_sip_pvt.update_row ');
    END;
  END IF;
  l_subsidy_pool_id := p_subsidy_pool_id;
  l_row_found := FALSE;
  l_api_version := 1.0;
  l_init_msg_list := OKL_API.g_false;
  l_msg_count := 0;

  SAVEPOINT set_decision_status_code_PVT;
  l_return_status := OKL_API.START_ACTIVITY( l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              l_return_status);

  IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
     RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
     RAISE OKL_API.G_EXCEPTION_ERROR;
  END IF;

  OPEN c_get_pool_id(l_subsidy_pool_id);
   FETCH c_get_pool_id INTO l_sub_pool_rec;
   l_row_found := c_get_pool_id%FOUND;
  CLOSE c_get_pool_id;

  -- update the status of the pool with the valus passed to it.
  IF l_row_found THEN
    l_sub_pool_rec.decision_status_code := p_decision_status_code;
    l_sub_pool_rec.decision_date := l_system_date;
    okl_sip_pvt.update_row(l_api_version,
                           l_init_msg_list,
                           l_return_status,
                           l_msg_count,
                           l_msg_data,
                           l_sub_pool_rec,
                           x_sub_pool_rec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    IF(l_sub_pool_rec.decision_status_code = 'PENDING')THEN
       -- add subsidy pool id and subsidy pool to the parameter list and call the corresponding business event.
       wf_event.AddParameterToList(G_WF_ITM_SUB_POOL_ID, l_sub_pool_rec.id, l_parameter_list);
       l_event_name := G_WF_EVT_SUBSIDY_POOL_PENDING;
    ELSIF(l_sub_pool_rec.decision_status_code = 'ACTIVE')THEN
       -- add subsidy pool id and subsidy pool to the parameter list call the corresponding business event.
       wf_event.AddParameterToList(G_WF_ITM_SUB_POOL_ID, l_sub_pool_rec.id, l_parameter_list);
       l_event_name := G_WF_EVT_SUBSIDY_POOL_APPROVED;
    ELSIF(l_sub_pool_rec.decision_status_code = 'REJECTED')THEN
       -- add subsidy pool id and subsidy pool to the parameter list call the corresponding business event.
       wf_event.AddParameterToList(G_WF_ITM_SUB_POOL_ID, l_sub_pool_rec.id, l_parameter_list);
       l_event_name := G_WF_EVT_SUBSIDY_POOL_REJECTED;
    END IF;
    IF (l_event_name IS NOT NULL) THEN
      raise_business_event(p_api_version     => p_api_version,
                           p_init_msg_list   => p_init_msg_list,
                           x_return_status   => x_return_status,
                           x_msg_count       => x_msg_count,
                           x_msg_data        => x_msg_data,
                           p_event_name      => l_event_name,
                           p_event_param_list => l_parameter_list
                          );
    END IF;
  END IF;
   okl_api.END_ACTIVITY(x_msg_count, x_msg_data);
   x_return_status := l_return_status;
   x_msg_data      := l_msg_data;
   x_msg_count     := l_msg_count;

  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        Okl_Debug_Pub.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRSIPB.pls call okl_sip_pvt.update_row ');
    END;
  END IF;

  EXCEPTION
     WHEN G_EXCEPTION_HALT_VALIDATION THEN
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

     WHEN OTHERS THEN
       x_return_status := OKL_API.HANDLE_EXCEPTIONS
       (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
       );
 END set_decision_status_code;


 ---------------------------------------------------------------------------
 -- PROCEDURE validate_sub_pool
 ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : validate_sub_pool
  -- Description     : procedure for validating the records in
  --                   table OKL_SUBSIDY_POOLS_B AND OKL_SUBSIDY_POOLS_TL
  -- Business Rules  : Validates the record passed to it.
  -- Parameters      : p_api_version, p_init_msg_list, x_return_status, x_msg_count,
  --                   x_msg_data, p_sub_pool_rec.
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------

PROCEDURE validate_sub_pool( p_api_version                  IN  NUMBER,
                            p_init_msg_list                IN  VARCHAR2,
                            x_return_status                OUT NOCOPY VARCHAR2,
                            x_msg_count                    OUT NOCOPY NUMBER,
                            x_msg_data                     OUT NOCOPY VARCHAR2,
                            p_sub_pool_rec                 IN  subsidy_pool_rec) IS

---------------------------
-- DECLARE Local Variables
---------------------------
  L_MODULE              CONSTANT fnd_log_messages.module%TYPE := 'okl.plsql.OKL_SUBSIDY_POOL_PVT.VALIDATE_SUB_POOL';
  L_DEBUG_ENABLED       VARCHAR2(10);
  L_LEVEL_PROCEDURE     fnd_log_messages.log_level%TYPE;
  IS_DEBUG_PROCEDURE_ON BOOLEAN;
  l_api_name	        CONSTANT VARCHAR2(30) := 'VALIDATE_SUBSIDY_POOL';
  l_api_version         NUMBER	;
  l_return_status       VARCHAR2(1) ;
  l_sub_pool_rec        subsidy_pool_rec ;

BEGIN
  L_DEBUG_ENABLED := Okl_Debug_Pub.CHECK_LOG_ENABLED;
  IF(L_DEBUG_ENABLED='Y') THEN
    L_LEVEL_PROCEDURE :=Fnd_Log.LEVEL_PROCEDURE;
    IS_DEBUG_PROCEDURE_ON := Okl_Debug_Pub.Check_Log_On(L_MODULE, L_LEVEL_PROCEDURE);
  END IF;
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        Okl_Debug_Pub.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRSIPB.pls call okl_sip_pvt.validate_row ');
    END;
  END IF;
  l_api_version := 1.0;
  l_return_status := OKL_API.G_RET_STS_SUCCESS;

    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list

    l_return_status := OKL_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => g_api_type,
			x_return_status => x_return_status);

    -- check if activity started successfully
    If (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
       raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (l_return_status = OKL_API.G_RET_STS_ERROR) then
       raise OKL_API.G_EXCEPTION_ERROR;
    End If;

    l_sub_pool_rec := p_sub_pool_rec;

    -- TAPI call to validate the records.
    okl_sip_pvt.validate_row(
	 p_api_version	        => p_api_version,
	 p_init_msg_list	=> p_init_msg_list,
	 x_return_status 	=> x_return_status,
	 x_msg_count     	=> x_msg_count,
	 x_msg_data      	=> x_msg_data,
	 p_sipv_rec	        => l_sub_pool_rec);

    -- check return status
    If x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR Then
	  raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif x_return_status = OKL_API.G_RET_STS_ERROR Then
	  raise OKL_API.G_EXCEPTION_ERROR;
    End If;

    OKL_API.END_ACTIVITY(x_msg_count	=> x_msg_count,
			 x_msg_data		=> x_msg_data);

  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        Okl_Debug_Pub.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRSIPB.pls call okl_sip_pvt.validate_row ');
    END;
  END IF;

  EXCEPTION
    when OKL_API.G_EXCEPTION_ERROR then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OKL_API.G_EXCEPTION_UNEXPECTED_ERROR then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OTHERS then
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);
END validate_sub_pool;

END OKL_SUBSIDY_POOL_PVT;

/
