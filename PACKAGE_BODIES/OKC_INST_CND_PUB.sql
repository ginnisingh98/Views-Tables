--------------------------------------------------------
--  DDL for Package Body OKC_INST_CND_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_INST_CND_PUB" AS
/* $Header: OKCPINCB.pls 120.0 2005/05/26 09:44:50 appldev noship $ */
	l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

/***********************  HAND-CODED  ***************************************/

  ----------------------------------------------------------------------------
  -- PROCEDURE inst_condition
  ----------------------------------------------------------------------------

  PROCEDURE inst_condition(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_instcnd_inp_rec              IN  INSTCND_INP_REC) IS
    l_api_name                     CONSTANT VARCHAR2(30) := 'inst_condition';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
  -- Call start activity to create savepoint ,check compatibility
  -- and initialize the message list
	l_return_status := OKC_API.START_ACTIVITY(l_api_name
									 ,p_init_msg_list
									 ,'_PUB'
									 ,x_return_status
									 );
  -- Check if activity started successfully
    IF l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF l_return_status = OKC_API.G_RET_STS_ERROR THEN
    RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    -- Instantiate the condition, call process api
    okc_inst_cnd_pvt.inst_condition(
    p_api_version      => p_api_version,
    p_init_msg_list    => p_init_msg_list,
    x_return_status    => x_return_status,
    x_msg_count        => x_msg_count,
    x_msg_data         => x_msg_data,
    p_instcnd_inp_rec  => p_instcnd_inp_rec);

    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
	    x_return_status := OKC_API.HANDLE_EXCEPTIONS
					   ( l_api_name,
						G_PKG_NAME,
						'OKC_API.G_RET_STS_ERROR',
						x_msg_count,
						x_msg_data,
						'_PUB');
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
	    x_return_status := OKC_API.HANDLE_EXCEPTIONS
					   ( l_api_name,
						G_PKG_NAME,
						'OKC_API.G_RET_STS_UNEXP_ERROR',
						x_msg_count,
						x_msg_data,
						'_PUB');
      -- notify caller of an unexpected error
	 x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
    WHEN OTHERS THEN
	    x_return_status := OKC_API.HANDLE_EXCEPTIONS
					   ( l_api_name,
						G_PKG_NAME,
						'OTHERS',
						x_msg_count,
						x_msg_data,
						'_PUB');

  END inst_condition;

END OKC_INST_CND_PUB;

/
