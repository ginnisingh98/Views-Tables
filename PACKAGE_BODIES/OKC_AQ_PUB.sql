--------------------------------------------------------
--  DDL for Package Body OKC_AQ_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_AQ_PUB" AS
/* $Header: OKCPAQB.pls 120.0 2005/05/25 19:35:47 appldev noship $ */
	l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  -- TYPES
  ---------------------------------------------------------------------------
  -- CONSTANTS
  ---------------------------------------------------------------------------
  -- PUBLIC VARIABLES
  ---------------------------------------------------------------------------
  -- EXCEPTIONS
  ---------------------------------------------------------------------------
-----------------------------------
-- Private procedures and functions
-----------------------------------

  ---------------------------------------------------------------------------
  -- Procedures and Functions
  ---------------------------------------------------------------------------

PROCEDURE send_message
    (p_api_version   IN  NUMBER,
     p_init_msg_list IN  VARCHAR2 ,
     p_commit        IN  VARCHAR2 ,
     x_msg_count     OUT NOCOPY NUMBER,
     x_msg_data      OUT NOCOPY VARCHAR2,
     x_return_status OUT NOCOPY VARCHAR2,
     p_corrid_rec    IN  okc_aq_pub.corrid_rec_typ,
     p_msg_tab       IN  okc_aq_pub.msg_tab_typ,
     p_queue_name    IN  VARCHAR2,
     p_delay         IN  INTEGER
     )
IS
  l_api_name	  CONSTANT VARCHAR2(30)	:= 'SEND_MESSAGE';
  l_api_version	  CONSTANT NUMBER 	:= 1.0;
  l_return_status VARCHAR2(1)           := OKC_API.G_RET_STS_SUCCESS;
  l_xml_clob      system.okc_aq_msg_typ;
   --
   l_proc varchar2(72) := '  OKC_AQ_PUB.'||'send_message';
   --

BEGIN
  IF (l_debug = 'Y') THEN
     okc_debug.Set_Indentation(l_proc);
     okc_debug.Log('10: Entering ',2);
  END IF;

  -- Call start_activity to create savepoint, check compatibility
  -- and initialize message list
 l_return_status := OKC_API.START_ACTIVITY ( l_api_name
    	                                     , g_pkg_name
		                             , p_init_msg_list
				             , l_api_version
					     , p_api_version
				             , '_PUB'
					     , x_return_status
					    );

  IF (l_debug = 'Y') THEN
     okc_debug.Log('30: l_return_status : '||l_return_status,2);
  END IF;

  -- Check if activity started successfully
  IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_ERROR;
  END IF;

  IF (l_debug = 'Y') THEN
     okc_debug.Log('40: Calling okc_aq_pvt.send_message ',2);
  END IF;

  okc_aq_pvt.send_message (
                          p_api_version ,
                          p_init_msg_list ,
                          p_commit        ,
                          x_msg_count     ,
                          x_msg_data      ,
                          x_return_status ,
                          p_corrid_rec    ,
                          p_msg_tab       ,
                          p_queue_name    ,
                          p_delay
                          );

  IF (l_debug = 'Y') THEN
     okc_debug.Log('50: After Call To okc_aq_pvt.send_message ',2);
     okc_debug.Log('50: x_msg_count : '||x_msg_count,2);
     okc_debug.Log('50: x_msg_data : '||x_msg_data,2);
     okc_debug.Log('50: x_return_status : '||x_return_status,2);
  END IF;

  -- end activity
  OKC_API.END_ACTIVITY ( x_msg_count
		       , x_msg_data );

  IF (l_debug = 'Y') THEN
     okc_debug.Log('1000: Leaving ',2);
     okc_debug.Reset_Indentation;
  END IF;

EXCEPTION
  WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    x_return_status := OKC_API.HANDLE_EXCEPTIONS (
                         l_api_name
                       , g_pkg_name
                       , 'OKC_API.G_RET_STS_ERROR'
                       , x_msg_count
                       , x_msg_data
                       , '_PUB'
		             );
                      IF (l_debug = 'Y') THEN
                         okc_debug.Log('2000: Leaving ',2);
                         okc_debug.Reset_Indentation;
                      END IF;
  WHEN OTHERS THEN
    x_return_status := OKC_API.HANDLE_EXCEPTIONS (
			 l_api_name
		       , g_pkg_name
		       , 'OTHERS'
		       , x_msg_count
		       , x_msg_data
		       , '_PUB'
		       );
                      IF (l_debug = 'Y') THEN
                         okc_debug.Log('3000: Leaving ',2);
                         okc_debug.Reset_Indentation;
                      END IF;

END send_message;


/*PROCEDURE send_message
    (p_api_version   IN  NUMBER,
     p_init_msg_list IN  VARCHAR2 ,
     p_commit        IN  VARCHAR2 ,
     x_msg_count     OUT NOCOPY NUMBER,
     x_msg_data      OUT NOCOPY VARCHAR2,
     x_return_status OUT NOCOPY VARCHAR2,
     p_msg           IN  VARCHAR2,
     p_queue_name    IN  VARCHAR2,
     p_delay         IN  NUMBER ,
     )
IS
  l_api_name	  CONSTANT VARCHAR2(30)	:= 'SEND_MESSAGE';
  l_api_version	  CONSTANT NUMBER 	:= 1.0;
  l_return_status VARCHAR2(1)           := OKC_API.G_RET_STS_SUCCESS;
  l_char_clob     system.okc_aq_msg_typ;

BEGIN
  IF p_msg IS NOT NULL THEN
  -- Call start_activity to create savepoint, check compatibility
  -- and initialize message list
  l_return_status := OKC_API.START_ACTIVITY ( l_api_name
    	                                    , g_pkg_name
			                    , p_init_msg_list
				            , l_api_version
					    , p_api_version
				            , '_PUB'
					    , x_return_status
					    );
  -- Check if activity started successfully
  IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_ERROR;
  END IF;

  okc_aq_pvt.send_message (
                          p_api_version   ,
                          p_init_msg_list ,
                          p_commit        ,
                          x_msg_count     ,
                          x_msg_data      ,
                          x_return_status ,
                          p_msg           ,
                          p_queue_name    ,
                          p_delay
                          );

  -- end activity
  OKC_API.END_ACTIVITY ( x_msg_count
		       , x_msg_data );
  END IF;
EXCEPTION
  WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    x_return_status := OKC_API.HANDLE_EXCEPTIONS (
                         l_api_name
                       , g_pkg_name
                       , 'OKC_API.G_RET_STS_ERROR'
                       , x_msg_count
		       , x_msg_data
		       , '_PUB'
		       );
  WHEN OTHERS THEN
    x_return_status := OKC_API.HANDLE_EXCEPTIONS (
			 l_api_name
		       , g_pkg_name
		       , 'OTHERS'
		       , x_msg_count
		       , x_msg_data
		       , '_PUB'
		       );
END send_message;*/

END okc_aq_pub;

/
