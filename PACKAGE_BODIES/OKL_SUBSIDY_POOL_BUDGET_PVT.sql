--------------------------------------------------------
--  DDL for Package Body OKL_SUBSIDY_POOL_BUDGET_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_SUBSIDY_POOL_BUDGET_PVT" AS
 /* $Header: OKLRSIBB.pls 120.2 2005/10/30 03:17:02 appldev noship $ */

G_WF_EVT_BUDGET_LINE_PENDING  CONSTANT wf_events.name%TYPE DEFAULT 'oracle.apps.okl.subsidy_pool.budget_line_pending_approval';
G_WF_EVT_BUDGET_LINE_APPROVED CONSTANT wf_events.name%TYPE DEFAULT 'oracle.apps.okl.subsidy_pool.budget_line_approved';
G_WF_EVT_BUDGET_LINE_REJECTED CONSTANT wf_events.name%TYPE DEFAULT 'oracle.apps.okl.subsidy_pool.budget_line_rejected';
G_WF_ITM_SUB_POOL_ID          CONSTANT VARCHAR2(30)    := 'SUBSIDY_POOL_ID';
G_WF_ITM_BUDGET_LINE_ID       CONSTANT VARCHAR2(30)    := 'BUDGET_LINE_ID';

-------------------------------------------------------------------------------
-- PROCEDURE raise_business_event
-------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : raise_business_event
-- Description     : This procedure is a wrapper that raises a business event
--                 : when ever a subsidy pool record is submitted for approval, approved, rejected
-- Business Rules  : the event is raised based on the decision_status_code passed and successful updation of the pool record
-- Parameters      :
-- Version         : 1.0
-- History         :
-- End of comments

PROCEDURE raise_business_event(p_api_version IN NUMBER,
                               p_init_msg_list IN VARCHAR2,
                               x_return_status OUT NOCOPY VARCHAR2,
                               x_msg_count OUT NOCOPY NUMBER,
                               x_msg_data OUT NOCOPY VARCHAR2,
                               p_event_name IN VARCHAR2,
                               p_event_param_list IN WF_PARAMETER_LIST_T
                               ) IS
  l_event_param_list WF_PARAMETER_LIST_T;
BEGIN
  l_event_param_list := p_event_param_list;
  x_return_status := OKL_API.G_RET_STS_SUCCESS;

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
-- Procedures and Functions
---------------------------------------------------------------------------
 ---------------------------------------------------------------------------
 -- PROCEDURE create_budget_line
 ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : create_budget_line
  -- Description     : procedure for inserting the records in
  --                   table OKL_SUBSIDY_POOL_BUDGETS
  -- Business Rules  : This procedure creates budget lines for a subsidy pool
  --                   where subsidy pool id of table OKL_SUBSIDY_POOL_BUDGETS
  --                   represents that pool id.
  -- Parameters      : p_api_version, p_init_msg_list, x_return_status, x_msg_count,
  --                   x_msg_data, p_budget_line_tbl, x_budget_line_tbl.
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------

  PROCEDURE create_budget_line  ( p_api_version      IN  NUMBER
                                 ,p_init_msg_list    IN  VARCHAR2
                                 ,x_return_status    OUT NOCOPY VARCHAR2
                                 ,x_msg_count        OUT NOCOPY NUMBER
                                 ,x_msg_data         OUT NOCOPY VARCHAR2
                                 ,p_budget_line_tbl  IN  budget_line_tbl
                                 ,x_budget_line_tbl  OUT NOCOPY budget_line_tbl
                                ) IS

---------------------------
-- DECLARE Local Variables
---------------------------
  L_MODULE              CONSTANT fnd_log_messages.module%TYPE := 'okl.plsql.OKL_SUBSIDY_POOL_BUDGET_PVT.CREATE_BUDGET_LINE';
  L_DEBUG_ENABLED       VARCHAR2(10);
  L_LEVEL_PROCEDURE     fnd_log_messages.log_level%TYPE;
  IS_DEBUG_PROCEDURE_ON BOOLEAN;
  l_budget_line_rec              budget_line_rec;
  l_budget_line_tbl              budget_line_tbl ;
  l_api_version		             	 NUMBER ;
  l_init_msg_list	              VARCHAR2(1) ;
  l_return_status            		 VARCHAR2(1);
  l_msg_count        	        	 NUMBER ;
  l_msg_data	    	            	 VARCHAR2(2000);
  l_api_name                     CONSTANT VARCHAR2(30) := 'create_budget_line';

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
        Okl_Debug_Pub.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRSIBB.pls call okl_sib_pvt.insert_row');
    END;
  END IF;

   l_budget_line_tbl := p_budget_line_tbl;
   l_api_version := 1.0;
   l_init_msg_list := Okl_Api.g_false;
   l_msg_count := 0;

   SAVEPOINT create_budget_line_PVT;
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
   -- TAPI call which inserts the budget line records in the table OKL_SUBSIDY_POOL_BUDGETS_B.
   okl_sib_pvt.insert_row(l_api_version,
                            l_init_msg_list,
                            l_return_status,
                            l_msg_count,
                            l_msg_data,
                            l_budget_line_tbl,
                            x_budget_line_tbl);

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
        Okl_Debug_Pub.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRSIBB.pls call okl_sib_pvt.insert_row ');
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

END create_budget_line;

 ---------------------------------------------------------------------------
 -- PROCEDURE update_budget_line
 ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : update_budget_line
  -- Description     : procedure for updating the records in
  --                   table OKL_SUBSIDY_POOL_BUDGETS
  -- Business Rules  : This procedure updates the existing budget lines
  --                   only when the budget line status is "new".
  -- Parameters      : p_api_version, p_init_msg_list, x_return_status, x_msg_count,
  --                   x_msg_data, p_budget_line_tbl, x_budget_line_tbl.
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------

  PROCEDURE update_budget_line  ( p_api_version      IN  NUMBER
                                 ,p_init_msg_list    IN  VARCHAR2
                                 ,x_return_status    OUT NOCOPY VARCHAR2
                                 ,x_msg_count        OUT NOCOPY NUMBER
                                 ,x_msg_data         OUT NOCOPY VARCHAR2
                                 ,p_budget_line_tbl  IN  budget_line_tbl
                                 ,x_budget_line_tbl  OUT NOCOPY budget_line_tbl
                                ) IS

---------------------------
-- DECLARE Local Variables
---------------------------
  L_MODULE              CONSTANT fnd_log_messages.module%TYPE := 'okl.plsql.OKL_SUBSIDY_POOL_BUDGET_PVT.UPDATE_BUDGET_LINE';
  L_DEBUG_ENABLED       VARCHAR2(10);
  L_LEVEL_PROCEDURE     fnd_log_messages.log_level%TYPE;
  IS_DEBUG_PROCEDURE_ON BOOLEAN;
  l_budget_line_rec              budget_line_rec;
  l_budget_line_tbl              budget_line_tbl ;
  l_api_version			              NUMBER ;
  l_init_msg_list                VARCHAR2(1) ;
  l_return_status		             VARCHAR2(1);
  l_msg_count                 	 NUMBER ;
  l_msg_data	    	            	 VARCHAR2(2000);
  l_api_name                     CONSTANT VARCHAR2(30) := 'create_budget_line';
  i NUMBER DEFAULT 0;
  l_currency_code  okl_subsidy_pools_v.currency_code%TYPE DEFAULT NULL;

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
         Okl_Debug_Pub.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRSIBB.pls call okl_sib_pvt.update_row ');
     END;
   END IF;

   l_budget_line_tbl := p_budget_line_tbl;
   l_api_version := 1.0;
   l_init_msg_list := Okl_Api.g_false;
   l_msg_count := 0;

   SAVEPOINT update_budget_line_PVT;
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

   -- TAPI call which updates the budget line records in the table OKL_SUBSIDY_POOL_BUDGETS_B.
   okl_sib_pvt.update_row  (l_api_version,
                            l_init_msg_list,
                            l_return_status,
                            l_msg_count,
                            l_msg_data,
                            l_budget_line_tbl,
                            x_budget_line_tbl);

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
        Okl_Debug_Pub.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRSIBB.pls call okl_sib_pvt.update_row ');
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
END update_budget_line;

 ---------------------------------------------------------------------------
 -- PROCEDURE set_decision_status_code
 ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : set_decision_status_code
  -- Description     : procedure for updating the decision status code
  --                   table OKL_SUBSIDY_POOL_BUDGETS_B.
  -- Business Rules  : This procedure sets the value of column desicion_status_code
  --                   with the value passed to this procedure for the given line id.
  --                   decision_status_code is a status of the corresponding budget line.
  -- Parameters      : p_api_version, p_init_msg_list, x_return_status, x_msg_count,
  --                   x_msg_data, p_sub_pool_budget_id, p_decision_status_code.
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------

PROCEDURE set_decision_status_code ( p_api_version                  IN  NUMBER,
                                     p_init_msg_list                IN  VARCHAR2,
                                     x_return_status                OUT NOCOPY VARCHAR2,
                                     x_msg_count                    OUT NOCOPY NUMBER,
                                     x_msg_data                     OUT NOCOPY VARCHAR2,
                                     p_sub_pool_budget_id           IN  okl_subsidy_pool_budgets_b.id%TYPE,
                                     p_decision_status_code         IN OUT NOCOPY okl_subsidy_pool_budgets_b.decision_status_code%TYPE)IS
---------------------------
-- DECLARE Local Variables
---------------------------
  L_MODULE              CONSTANT fnd_log_messages.module%TYPE := 'okl.plsql.OKL_SUBSIDY_POOL_BUDGET_PVT.SET_DECISION_STATUS_CODE';
  L_DEBUG_ENABLED       VARCHAR2(10);
  L_LEVEL_PROCEDURE     fnd_log_messages.log_level%TYPE;
  IS_DEBUG_PROCEDURE_ON BOOLEAN;
  l_budget_line_rec        budget_line_rec;
  l_sub_pool_budget_id     OKL_SUBSIDY_POOL_BUDGETS_B.ID%TYPE ;
  x_budget_line_rec        budget_line_rec;
  l_row_found		   BOOLEAN;
  l_api_version		   NUMBER ;
  l_init_msg_list	   VARCHAR2(1) ;
  l_return_status	   VARCHAR2(1);
  l_msg_count	           NUMBER ;
  l_msg_data	    	   VARCHAR2(2000);
  l_api_name               CONSTANT VARCHAR2(30) := 'set_decision_status_code';
  l_parameter_list WF_PARAMETER_LIST_T;
  l_event_name      wf_events.name%TYPE;
  l_system_date              DATE ;
-------------------
-- DECLARE Cursors
-------------------
   -- cursor to fetch a record with the passed id.
   CURSOR   c_get_budget_id (cp_sub_pool_budget_id IN okl_subsidy_pool_budgets_b.id%type) IS
   SELECT   id
           ,object_version_number
           ,sfwt_flag
           ,note
           ,budget_type_code
           ,effective_from_date
           ,decision_status_code
           ,budget_amount
           ,subsidy_pool_id
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
   FROM   OKL_SUBSIDY_POOL_BUDGETS_V
   WHERE  id = cp_sub_pool_budget_id;

   BEGIN
     L_DEBUG_ENABLED := Okl_Debug_Pub.CHECK_LOG_ENABLED;
     IF(L_DEBUG_ENABLED='Y') THEN
       L_LEVEL_PROCEDURE :=Fnd_Log.LEVEL_PROCEDURE;
       IS_DEBUG_PROCEDURE_ON := Okl_Debug_Pub.Check_Log_On(L_MODULE, L_LEVEL_PROCEDURE);
     END IF;
     IF(IS_DEBUG_PROCEDURE_ON) THEN
       BEGIN
           Okl_Debug_Pub.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRSIBB.pls call okl_sib_pvt.update_row ');
       END;
     END IF;
     l_row_found := FALSE;
     l_api_version := 1.0;
     l_init_msg_list := OKL_API.g_false;
     l_msg_count := 0;
     l_sub_pool_budget_id := p_sub_pool_budget_id;
     l_system_date := TRUNC(SYSDATE);

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
     -- fetch the record with the passed id and check whether the row exists.
     OPEN c_get_budget_id(l_sub_pool_budget_id);
      FETCH c_get_budget_id INTO l_budget_line_rec;
      l_row_found := c_get_budget_id%FOUND;
     CLOSE c_get_budget_id;

     --if row is found then update the decision_status_code with the value passed to this procedure and
     --set the decision date to the system date.
     IF l_row_found THEN
       l_budget_line_rec.decision_status_code := p_decision_status_code;
       l_budget_line_rec.decision_date := l_system_date;
       --TAPI call to update the record.
       okl_sib_pvt.update_row(l_api_version,
                              l_init_msg_list,
                              l_return_status,
                              l_msg_count,
                              l_msg_data,
                              l_budget_line_rec,
                              x_budget_line_rec);
       IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;
       IF(l_budget_line_rec.decision_status_code = 'PENDING')THEN
          -- add subsidy pool id and subsidy pool to the parameter list and raise the corresponding business event.
          wf_event.AddParameterToList(G_WF_ITM_SUB_POOL_ID, l_budget_line_rec.subsidy_pool_id, l_parameter_list);
          wf_event.AddParameterToList(G_WF_ITM_BUDGET_LINE_ID, l_budget_line_rec.id, l_parameter_list);
          l_event_name := G_WF_EVT_BUDGET_LINE_PENDING;
       ELSIF(l_budget_line_rec.decision_status_code = 'ACTIVE') THEN
          -- add subsidy pool id and subsidy pool to the parameter list and raise the corresponding business event.
          wf_event.AddParameterToList(G_WF_ITM_SUB_POOL_ID, l_budget_line_rec.subsidy_pool_id, l_parameter_list);
          wf_event.AddParameterToList(G_WF_ITM_BUDGET_LINE_ID, l_budget_line_rec.id, l_parameter_list);
          l_event_name := G_WF_EVT_BUDGET_LINE_APPROVED;
       ELSIF(l_budget_line_rec.decision_status_code = 'REJECTED')THEN
          -- add subsidy pool id and subsidy pool to the parameter list and raise the corresponding business event.
          wf_event.AddParameterToList(G_WF_ITM_SUB_POOL_ID, l_budget_line_rec.subsidy_pool_id, l_parameter_list);
          wf_event.AddParameterToList(G_WF_ITM_BUDGET_LINE_ID, l_budget_line_rec.id, l_parameter_list);
          l_event_name := G_WF_EVT_BUDGET_LINE_REJECTED;
       END IF;
       IF (l_event_name IS NOT NULL) THEN
         raise_business_event(p_api_version      => p_api_version,
                              p_init_msg_list    => p_init_msg_list,
                              x_return_status    => x_return_status,
                              x_msg_count        => x_msg_count,
                              x_msg_data         => x_msg_data,
                              p_event_name       => l_event_name,
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
        Okl_Debug_Pub.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRSIBB.pls call okl_sib_pvt.update_row ');
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
 -- PROCEDURE validate_budget_line
 ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : validate_budget_line
  -- Description     : procedure for validating the records in
  --                   table OKL_SUBSIDY_POOL_BUDGETS
  -- Business Rules  : Validates the attributes.
  -- Parameters      : p_api_version, p_init_msg_list, x_return_status, x_msg_count,
  --                   x_msg_data, p_budget_line_tbl.
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------

PROCEDURE validate_budget_line( p_api_version                 IN  NUMBER,
                                p_init_msg_list                IN  VARCHAR2,
                                x_return_status                OUT NOCOPY VARCHAR2,
                                x_msg_count                    OUT NOCOPY NUMBER,
                                x_msg_data                     OUT NOCOPY VARCHAR2,
                                p_budget_line_tbl              IN  budget_line_tbl) IS

---------------------------
-- DECLARE Local Variables
---------------------------
  L_MODULE              CONSTANT fnd_log_messages.module%TYPE := 'okl.plsql.OKL_SUBSIDY_POOL_BUDGET_PVT.VALIDATE_BUDGET_LINE';
  L_DEBUG_ENABLED       VARCHAR2(10);
  L_LEVEL_PROCEDURE     fnd_log_messages.log_level%TYPE;
  IS_DEBUG_PROCEDURE_ON BOOLEAN;
  l_api_name            CONSTANT VARCHAR2(30) := 'VALIDATE_BUDGET_LINE';
  l_api_version	        CONSTANT NUMBER	      := 1.0;
  l_return_status	VARCHAR2(1);
  l_budget_line_tbl     budget_line_tbl ;

BEGIN
  L_DEBUG_ENABLED := Okl_Debug_Pub.CHECK_LOG_ENABLED;
  IF(L_DEBUG_ENABLED='Y') THEN
    L_LEVEL_PROCEDURE :=Fnd_Log.LEVEL_PROCEDURE;
    IS_DEBUG_PROCEDURE_ON := Okl_Debug_Pub.Check_Log_On(L_MODULE, L_LEVEL_PROCEDURE);
  END IF;
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        Okl_Debug_Pub.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLRSIBB.pls call okl_sib_pvt.validate_row ');
    END;
  END IF;
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

    l_budget_line_tbl := p_budget_line_tbl;

    -- TAPI call to validate the records passed to it.
    okl_sib_pvt.validate_row(	 p_api_version	     => p_api_version,
                             	 p_init_msg_list	   => p_init_msg_list,
                             	 x_return_status 	  => x_return_status,
                                 x_msg_count     	  => x_msg_count,
                                 x_msg_data      	  => x_msg_data,
                                 p_sibv_tbl	        => l_budget_line_tbl);

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
        Okl_Debug_Pub.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLRSIBB.pls call okl_sib_pvt.validate_row ');
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


END validate_budget_line;

END okl_subsidy_pool_budget_pvt;

/
