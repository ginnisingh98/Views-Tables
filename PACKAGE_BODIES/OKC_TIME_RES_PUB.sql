--------------------------------------------------------
--  DDL for Package Body OKC_TIME_RES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_TIME_RES_PUB" AS
/* $Header: OKCPRESB.pls 120.0 2005/05/25 19:47:36 appldev noship $ */
	l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');
  ---------------------------------------------------------------------------
  -- Procedures and Functions
  ---------------------------------------------------------------------------

  PROCEDURE Res_Time_Events (
    x_return_status                OUT NOCOPY VARCHAR2,
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    p_cnh_id                       IN NUMBER,
    p_coe_id                       IN NUMBER,
    p_date                         IN date) IS
    l_msg_count             NUMBER;
    l_msg_data              VARCHAR2(4000);
    l_api_name              CONSTANT VARCHAR2(30) := 'RES_TIME_EVENTS';
  BEGIN
    x_return_status := OKC_API.START_ACTIVITY(l_api_name,
					      p_init_msg_list,
					      '_PUB',
                                        x_return_status);
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;
    OKC_TIME_RES_PVT.Res_Time_Events(
      x_return_status,
      p_api_version	 ,
      p_init_msg_list,
      p_cnh_id ,
      p_coe_id ,
	 p_date);
    OKC_API.END_ACTIVITY(l_msg_count, l_msg_data);
  END  Res_Time_Events ;

  PROCEDURE Res_Time_New_K(
    p_chr_id IN NUMBER,
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status OUT NOCOPY VARCHAR2) IS
    l_msg_count             NUMBER;
    l_msg_data              VARCHAR2(4000);
    l_api_name              CONSTANT VARCHAR2(30) := 'RES_TIME_NEW_K';
  BEGIN
    x_return_status := OKC_API.START_ACTIVITY(l_api_name,
					      p_init_msg_list,
					      '_PUB',
                                        x_return_status);
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;
    OKC_TIME_RES_PVT.Res_Time_New_K(
      p_chr_id ,
      p_api_version	 ,
      p_init_msg_list,
      x_return_status);
    OKC_API.END_ACTIVITY(l_msg_count, l_msg_data);
  END Res_Time_New_K;

  PROCEDURE Res_Time_Extnd_K(
    p_chr_id IN NUMBER,
    p_cle_id IN NUMBER,
    p_start_date IN DATE,
    p_end_date IN DATE,
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status OUT NOCOPY VARCHAR2) IS
    l_msg_count             NUMBER;
    l_msg_data              VARCHAR2(4000);
    l_api_name              CONSTANT VARCHAR2(30) := 'RES_TIME_EXTND_K';
  BEGIN
    x_return_status := OKC_API.START_ACTIVITY(l_api_name,
					      p_init_msg_list,
					      '_PUB',
                                        x_return_status);
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;
    OKC_TIME_RES_PVT.Res_Time_Extnd_K(
      p_chr_id ,
      p_cle_id ,
      p_start_date,
      p_end_date,
      p_api_version	 ,
      p_init_msg_list,
      x_return_status);
    OKC_API.END_ACTIVITY(l_msg_count, l_msg_data);
    END Res_Time_Extnd_K;

  PROCEDURE Res_Time_Termnt_K(
    p_chr_id IN NUMBER,
    p_cle_id IN NUMBER,
    p_end_date IN DATE,
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status OUT NOCOPY VARCHAR2) IS
    l_msg_count             NUMBER;
    l_msg_data              VARCHAR2(4000);
    l_api_name              CONSTANT VARCHAR2(30) := 'RES_TIME_TERMNT_K';
  BEGIN
    x_return_status := OKC_API.START_ACTIVITY(l_api_name,
					      p_init_msg_list,
					      '_PUB',
                                        x_return_status);
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;
    OKC_TIME_RES_PVT.Res_Time_Termnt_K(
      p_chr_id ,
      p_cle_id ,
      p_end_date,
      p_api_version	 ,
      p_init_msg_list,
      x_return_status);
    OKC_API.END_ACTIVITY(l_msg_count, l_msg_data);
    END Res_Time_Termnt_K;

  FUNCTION Check_Res_Time_N_tasks(
	  p_tve_id IN NUMBER,
	  p_date IN DATE)
	 return BOOLEAN  IS
  BEGIN
    return (OKC_TIME_RES_PVT. Check_Res_Time_N_tasks(
	  p_tve_id ,
	  p_date ));
  END Check_Res_Time_N_tasks;

  PROCEDURE Delete_Res_Time_N_Tasks(
    p_tve_id IN NUMBER,
    p_date IN DATE,
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status OUT NOCOPY VARCHAR2) IS
    l_msg_count             NUMBER;
    l_msg_data              VARCHAR2(4000);
    l_api_name              CONSTANT VARCHAR2(30) := 'DELETE_RES_TIME_N_TASKS';
  BEGIN
    x_return_status := OKC_API.START_ACTIVITY(l_api_name,
					      p_init_msg_list,
					      '_PUB',
                                        x_return_status);
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;
      OKC_TIME_RES_PVT.Delete_Res_Time_N_Tasks(
        p_tve_id ,
        p_date ,
        p_api_version,
        p_init_msg_list ,
        x_return_status);
    OKC_API.END_ACTIVITY(l_msg_count, l_msg_data);
    END Delete_Res_Time_N_Tasks;

  PROCEDURE Create_Res_Time_N_Tasks(
    p_tve_id IN NUMBER,
    p_start_date IN DATE,
    p_end_date IN DATE,
    p_api_version	    IN NUMBER,
    p_init_msg_list         IN VARCHAR2 ,
    x_return_status OUT NOCOPY VARCHAR2) IS
    l_msg_count             NUMBER;
    l_msg_data              VARCHAR2(4000);
    l_api_name              CONSTANT VARCHAR2(30) := 'CREATE_RES_TIME_N_TASKS';
  BEGIN
    x_return_status := OKC_API.START_ACTIVITY(l_api_name,
					      p_init_msg_list,
					      '_PUB',
                                        x_return_status);
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      raise OKC_API.G_EXCEPTION_ERROR;
    END IF;
    OKC_TIME_RES_PVT.Create_Res_Time_N_Tasks(
        p_tve_id ,
        p_start_date ,
        p_end_date ,
        p_api_version,
        p_init_msg_list ,
        x_return_status);
    OKC_API.END_ACTIVITY(l_msg_count, l_msg_data);
  END Create_Res_Time_N_Tasks;

  PROCEDURE Batch_Resolve_Time_N_Tasks  IS
   BEGIN
    OKC_TIME_RES_PVT.Batch_Resolve_Time_N_Tasks;
  END Batch_Resolve_Time_N_Tasks;

END OKC_TIME_RES_PUB;

/
