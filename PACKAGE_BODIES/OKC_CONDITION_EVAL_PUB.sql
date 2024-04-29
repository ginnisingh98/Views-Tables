--------------------------------------------------------
--  DDL for Package Body OKC_CONDITION_EVAL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_CONDITION_EVAL_PUB" as
/* $Header: OKCPCEVB.pls 120.0 2005/05/25 22:40:58 appldev noship $ */
	l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

--

-- This procedure evaluates condition attached to a plan.

 PROCEDURE evaluate_plan_condition(
    p_api_version           IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_cnh_id                IN okc_condition_headers_b.id%TYPE,
    p_msg_tab               IN okc_aq_pvt.msg_tab_typ,
    x_sync_outcome_tab      OUT NOCOPY okc_condition_eval_pub.outcome_tab_type
    )
    IS

    l_api_name      CONSTANT VARCHAR2(30) := 'EVALUATE_CONDITION';
    l_return_status VARCHAR2(1)           := OKC_API.G_RET_STS_SUCCESS;
   --
   l_proc varchar2(72) := '  okc_condition_eval_pub.'||'evaluate_condition';
   --

    BEGIN

  IF (l_debug = 'Y') THEN
     okc_debug.Set_Indentation(l_proc);
     okc_debug.Log('10: Entering ',2);
  END IF;

  -- Call start_activity to create savepoint, check compatibility
  -- and initialize message list
     l_return_status := OKC_API.START_ACTIVITY ( l_api_name
						  , p_init_msg_list
						  , '_PUB'
						  , x_return_status
						  );
  -- Check if activity started successfully
     IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_ERROR;
     END IF;

  -- evaluate conditions, build outcomes for true conditions
     OKC_CONDITION_EVAL_PVT.evaluate_plan_condition(
					       p_api_version,
					       p_init_msg_list,
					       x_return_status,
					       x_msg_count,
					       x_msg_data,
					       p_cnh_id,
					       p_msg_tab,
					       x_sync_outcome_tab
					       );

/*Add check return status*/
  -- end activity
    OKC_API.END_ACTIVITY ( x_msg_count
			   , x_msg_data );

  IF (l_debug = 'Y') THEN
     okc_debug.Log('1000: Leaving ',2);
     okc_debug.Reset_Indentation;
  END IF;

    EXCEPTION

	     WHEN OKC_API.G_EXCEPTION_ERROR THEN
			    x_return_status := OKC_API.HANDLE_EXCEPTIONS
						 ( l_api_name,
						 G_PKG_NAME,
						 'OKC_API.G_RET_STS_ERROR',
						 x_msg_count,
						 x_msg_data,
						 '_PUB');
                                                 IF (l_debug = 'Y') THEN
                                                    okc_debug.Log('2000: Leaving ',2);
                                                    okc_debug.Reset_Indentation;
                                                 END IF;

             WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
			    x_return_status :=OKC_API.HANDLE_EXCEPTIONS
						( l_api_name,
						G_PKG_NAME,
						'OKC_API.G_RET_STS_UNEXP_ERROR',
						x_msg_count,
						x_msg_data,
						 '_PUB');
                                                 IF (l_debug = 'Y') THEN
                                                    okc_debug.Log('3000: Leaving ',2);
                                                    okc_debug.Reset_Indentation;
                                                 END IF;

             WHEN OTHERS THEN
	     x_return_status :=OKC_API.HANDLE_EXCEPTIONS
                        ( l_api_name,
						  G_PKG_NAME,
						  'OTHERS',
						  x_msg_count,
						  x_msg_data,
						  '_PUB');
                                                 IF (l_debug = 'Y') THEN
                                                    okc_debug.Log('4000: Leaving ',2);
                                                    okc_debug.Reset_Indentation;
                                                 END IF;

    END evaluate_plan_condition;


 -- This procedure is overloaded to handle sync and async events.
 -- For sync events a table of outcomes are  returned to the calling API.
 PROCEDURE evaluate_condition(
    p_api_version           IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_acn_id                IN okc_actions_b.id%TYPE,
    p_msg_tab               IN okc_aq_pvt.msg_tab_typ,
    x_sync_outcome_tab      OUT NOCOPY okc_condition_eval_pub.outcome_tab_type
    )
    IS
    l_status  VARCHAR2(10);
    l_count   NUMBER := 0;
    l_outcome_tab   okc_condition_eval_pvt.exec_tab_type;
    l_cnh_tab       okc_condition_eval_pvt.id_tab_type;
    l_api_name      CONSTANT VARCHAR2(30) := 'EVALUATE_CONDITION';
    l_return_status VARCHAR2(1)           := OKC_API.G_RET_STS_SUCCESS;
   --
   l_proc varchar2(72) := '  okc_condition_eval_pub.'||'evaluate_condition';
   --
    BEGIN

  IF (l_debug = 'Y') THEN
     okc_debug.Set_Indentation(l_proc);
     okc_debug.Log('10: Entering ',2);
  END IF;

  -- Call start_activity to create savepoint, check compatibility
  -- and initialize message list
     l_return_status := OKC_API.START_ACTIVITY ( l_api_name
						  , p_init_msg_list
						  , '_PUB'
						  , x_return_status
						  );
  -- Check if activity started successfully
     IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      -- RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      null;
     ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      null;-- RAISE OKC_API.G_EXCEPTION_ERROR;
     END IF;

  -- evaluate conditions, build outcomes for true conditions
     OKC_CONDITION_EVAL_PVT.evaluate_condition(
					       p_api_version,
					       p_init_msg_list,
					       x_return_status,
					       x_msg_count,
					       x_msg_data,
					       p_acn_id,
					       p_msg_tab,
					       x_sync_outcome_tab
					       );

  -- end activity
    OKC_API.END_ACTIVITY ( x_msg_count
			   , x_msg_data );

  IF (l_debug = 'Y') THEN
     okc_debug.Log('1000: Leaving ',2);
     okc_debug.Reset_Indentation;
  END IF;


    EXCEPTION

	     WHEN OKC_API.G_EXCEPTION_ERROR THEN
			    x_return_status := OKC_API.HANDLE_EXCEPTIONS
						 ( l_api_name,
						 G_PKG_NAME,
						 'OKC_API.G_RET_STS_ERROR',
						 x_msg_count,
						 x_msg_data,
						 '_PUB');
                                                 IF (l_debug = 'Y') THEN
                                                    okc_debug.Log('2000: Leaving ',2);
                                                    okc_debug.Reset_Indentation;
                                                 END IF;
             WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
			    x_return_status :=OKC_API.HANDLE_EXCEPTIONS
						( l_api_name,
						G_PKG_NAME,
						'OKC_API.G_RET_STS_UNEXP_ERROR',
						x_msg_count,
						x_msg_data,
						 '_PUB');
                                                 IF (l_debug = 'Y') THEN
                                                    okc_debug.Log('3000: Leaving ',2);
                                                    okc_debug.Reset_Indentation;
                                                 END IF;
             WHEN OTHERS THEN
	     x_return_status :=OKC_API.HANDLE_EXCEPTIONS
	                                          ( l_api_name,
						  G_PKG_NAME,
						  'OTHERS',
						  x_msg_count,
						  x_msg_data,
						  '_PUB');
                                                 IF (l_debug = 'Y') THEN
                                                    okc_debug.Log('4000: Leaving ',2);
                                                    okc_debug.Reset_Indentation;
                                                 END IF;
    END evaluate_condition;


 PROCEDURE evaluate_condition(
    p_api_version           IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_acn_id                IN okc_actions_b.id%TYPE,
    p_msg_tab               IN okc_aq_pvt.msg_tab_typ
    )
    IS
    l_status  VARCHAR2(10);
    l_count   NUMBER := 0;
    l_outcome_tab   okc_condition_eval_pvt.exec_tab_type;
    l_cnh_tab       okc_condition_eval_pvt.id_tab_type;
    l_api_name      CONSTANT VARCHAR2(30) := 'EVALUATE_CONDITION';
    l_return_status VARCHAR2(1)           := OKC_API.G_RET_STS_SUCCESS;
   --
   l_proc varchar2(72) := '  okc_condition_eval_pub.'||'evaluate_condition';
   --
    BEGIN

  IF (l_debug = 'Y') THEN
     okc_debug.Set_Indentation(l_proc);
     okc_debug.Log('10: Entering ',2);
  END IF;

  -- Call start_activity to create savepoint, check compatibility
  -- and initialize message list
     l_return_status := OKC_API.START_ACTIVITY ( l_api_name
						  , p_init_msg_list
						  , '_PUB'
						  , x_return_status
						  );
  -- Check if activity started successfully
     IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_ERROR;
     END IF;
  -- evaluate conditions, build outcomes for true conditions and
  -- put them on outcome queue
     OKC_CONDITION_EVAL_PVT.evaluate_condition(
					       p_api_version,
					       p_init_msg_list,
					       x_return_status,
					       x_msg_count,
					       x_msg_data,
					       p_acn_id,
					       p_msg_tab
					       );
    OKC_API.END_ACTIVITY ( x_msg_count
			   , x_msg_data );

  IF (l_debug = 'Y') THEN
     okc_debug.Log('1000: Leaving ',2);
     okc_debug.Reset_Indentation;
  END IF;


    EXCEPTION
	     WHEN OKC_API.G_EXCEPTION_ERROR THEN
			    x_return_status := OKC_API.HANDLE_EXCEPTIONS
						 ( l_api_name,
						 G_PKG_NAME,
						 'OKC_API.G_RET_STS_ERROR',
						 x_msg_count,
						 x_msg_data,
						 '_PUB');
                                                 IF (l_debug = 'Y') THEN
                                                    okc_debug.Log('2000: Leaving ',2);
                                                    okc_debug.Reset_Indentation;
                                                 END IF;
             WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
			    x_return_status :=OKC_API.HANDLE_EXCEPTIONS
						( l_api_name,
						G_PKG_NAME,
						'OKC_API.G_RET_STS_UNEXP_ERROR',
						x_msg_count,
						x_msg_data,
						'_PUB');
                                                 IF (l_debug = 'Y') THEN
                                                    okc_debug.Log('3000: Leaving ',2);
                                                    okc_debug.Reset_Indentation;
                                                 END IF;
             WHEN OTHERS THEN x_return_status :=OKC_API.HANDLE_EXCEPTIONS
	                                          ( l_api_name,
						  G_PKG_NAME,
						  'OTHERS',
						  x_msg_count,
						  x_msg_data,
						  '_PUB');
                                                 IF (l_debug = 'Y') THEN
                                                    okc_debug.Log('4000: Leaving ',2);
                                                    okc_debug.Reset_Indentation;
                                                 END IF;
    END evaluate_condition;

 -- Evaluator for date based actions
 PROCEDURE evaluate_date_condition(
    p_api_version           IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status         OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_cnh_id                IN okc_condition_headers_b.id%TYPE,
    p_msg_tab               IN okc_aq_pvt.msg_tab_typ
    )
    IS
    l_status  VARCHAR2(10);
    l_count   NUMBER := 0;
    l_outcome_tab   okc_condition_eval_pvt.exec_tab_type;
    l_cnh_tab       okc_condition_eval_pvt.id_tab_type;
    l_api_name      CONSTANT VARCHAR2(30) := 'EVALUATE_CONDITION';
    l_return_status VARCHAR2(1)           := OKC_API.G_RET_STS_SUCCESS;
   --
   l_proc varchar2(72) := '  okc_condition_eval_pub.'||'evaluate_date_condition';
   --
    BEGIN

  IF (l_debug = 'Y') THEN
     okc_debug.Set_Indentation(l_proc);
     okc_debug.Log('10: Entering ',2);
  END IF;

  -- Call start_activity to create savepoint, check compatibility
  -- and initialize message list
     l_return_status := OKC_API.START_ACTIVITY ( l_api_name
						  , p_init_msg_list
						  , '_PUB'
						  , l_return_status
						  );
  -- Check if activity started successfully
     IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_ERROR;
     END IF;
  -- evaluate conditions, build outcomes for true conditions and
  -- put them on outcome queue
     OKC_CONDITION_EVAL_PVT.evaluate_date_condition(
					       p_api_version,
					       p_init_msg_list,
					       x_return_status,
					       x_msg_count,
					       x_msg_data,
					       p_cnh_id,
					       p_msg_tab
					       );
    OKC_API.END_ACTIVITY ( x_msg_count
			   , x_msg_data );

  IF (l_debug = 'Y') THEN
     okc_debug.Log('1000: Leaving ',2);
     okc_debug.Reset_Indentation;
  END IF;


    EXCEPTION
	     WHEN OKC_API.G_EXCEPTION_ERROR THEN
			    x_return_status := OKC_API.HANDLE_EXCEPTIONS
						 ( l_api_name,
						 G_PKG_NAME,
						 'OKC_API.G_RET_STS_ERROR',
						 x_msg_count,
						 x_msg_data,
						 '_PUB');
                                                 IF (l_debug = 'Y') THEN
                                                    okc_debug.Log('2000: Leaving ',2);
                                                    okc_debug.Reset_Indentation;
                                                 END IF;
             WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
			    x_return_status :=OKC_API.HANDLE_EXCEPTIONS
						( l_api_name,
						G_PKG_NAME,
						'OKC_API.G_RET_STS_UNEXP_ERROR',
						x_msg_count,
						x_msg_data,
						'_PUB');
                                                 IF (l_debug = 'Y') THEN
                                                    okc_debug.Log('3000: Leaving ',2);
                                                    okc_debug.Reset_Indentation;
                                                 END IF;
             WHEN OTHERS THEN x_return_status :=OKC_API.HANDLE_EXCEPTIONS
	                                          ( l_api_name,
						  G_PKG_NAME,
						  'OTHERS',
						  x_msg_count,
						  x_msg_data,
						  '_PUB');
                                                 IF (l_debug = 'Y') THEN
                                                    okc_debug.Log('4000: Leaving ',2);
                                                    okc_debug.Reset_Indentation;
                                                 END IF;
    END evaluate_date_condition;

END okc_condition_eval_pub;

/
