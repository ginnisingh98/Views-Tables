--------------------------------------------------------
--  DDL for Package Body OKS_PM_ENTITLEMENTS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKS_PM_ENTITLEMENTS_PUB" AS
/* $Header: OKSPPMEB.pls 120.0 2005/05/25 18:31:48 appldev noship $ */


   PROCEDURE Get_PM_Contracts
    (p_api_version          IN  Number
    ,p_init_msg_list        IN  Varchar2
    ,p_inp_rec              IN  Get_pmcontin_rec
    ,x_return_status        out nocopy Varchar2
    ,x_msg_count            out nocopy Number
    ,x_msg_data             out nocopy Varchar2
    ,x_ent_contracts        out nocopy OKS_ENTITLEMENTS_PUB.get_contop_tbl
    ,x_pm_activities        out nocopy OKS_PM_ENTITLEMENTS_PUB.get_activityop_tbl)
  IS
   l_return_status	Varchar2(1) := OKC_API.G_RET_STS_SUCCESS;
   l_api_name            CONSTANT VARCHAR2(30) := 'get_pm_contracts';
  BEGIN
       l_return_status := OKC_API.START_ACTIVITY(l_api_name
                                                ,p_init_msg_list
                                                ,'_PUB'
                                                ,x_return_status
                                                );
       IF l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF l_return_status = OKC_API.G_RET_STS_ERROR THEN
             RAISE OKC_API.G_EXCEPTION_ERROR;
       END IF;

	OKS_PM_ENTITLEMENTS_PVT.get_pm_contracts
			(p_api_version       => p_api_version
			,p_init_msg_list     => p_init_msg_list
			,p_inp_rec           => p_inp_rec
			,x_return_status     => x_return_status
			,x_msg_count         => x_msg_count
			,x_msg_data          => x_msg_data
			,x_ent_contracts     => x_ent_contracts
            ,x_pm_activities     => x_pm_activities);



       IF x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF x_return_status = OKC_API.G_RET_STS_ERROR THEN
             RAISE OKC_API.G_EXCEPTION_ERROR;
       END IF;

       OKC_API.END_ACTIVITY(x_msg_count,x_msg_data);

    EXCEPTION
       WHEN OKC_API.G_EXCEPTION_ERROR THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PUB');
       WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PUB');
       WHEN OTHERS THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PUB');
  END get_pm_contracts;

  PROCEDURE Get_PM_Schedule
    (p_api_version          IN  Number
    ,p_init_msg_list        IN  Varchar2
    ,p_sch_rec              IN  inp_sch_rec
    ,x_return_status        out nocopy Varchar2
    ,x_msg_count            out nocopy Number
    ,x_msg_data             out nocopy Varchar2
    ,x_pm_schedule          out nocopy pm_sch_tbl_type)
  IS
   l_return_status	Varchar2(1) := OKC_API.G_RET_STS_SUCCESS;
   l_api_name            CONSTANT VARCHAR2(30) := 'Get_PM_Schedule';
  BEGIN
       l_return_status := OKC_API.START_ACTIVITY(l_api_name
                                                ,p_init_msg_list
                                                ,'_PUB'
                                                ,x_return_status
                                                );
       IF l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF l_return_status = OKC_API.G_RET_STS_ERROR THEN
             RAISE OKC_API.G_EXCEPTION_ERROR;
       END IF;

/*	OKS_PM_ENTITLEMENTS_PVT.Get_PM_Schedule
			(p_api_version       => p_api_version
			,p_init_msg_list     => p_init_msg_list
			,p_sch_rec           => p_sch_rec
			,x_return_status     => x_return_status
			,x_msg_count         => x_msg_count
			,x_msg_data          => x_msg_data
			,x_pm_schedule       => x_pm_schedule);*/


	OKS_PM_ENTITLEMENTS_PVT.Get_PM_Schedule
			(p_api_version       => p_api_version
			,p_init_msg_list     => p_init_msg_list
			,p_sch_rec           => p_sch_rec
			,x_return_status     => x_return_status
			,x_msg_count         => x_msg_count
			,x_msg_data          => x_msg_data
			,x_pm_schedule       => x_pm_schedule);




       IF x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF x_return_status = OKC_API.G_RET_STS_ERROR THEN
             RAISE OKC_API.G_EXCEPTION_ERROR;
       END IF;

       OKC_API.END_ACTIVITY(x_msg_count,x_msg_data);

    EXCEPTION
       WHEN OKC_API.G_EXCEPTION_ERROR THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PUB');
       WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PUB');
       WHEN OTHERS THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PUB');
  END Get_PM_Schedule;

  PROCEDURE Get_PM_Confirmation
    (p_api_version          IN  Number
    ,p_init_msg_list        IN  Varchar2
    ,p_service_line_id      IN  Number
    ,p_program_id           IN  Number
    ,p_Activity_Id          IN  Number
    ,x_return_status        out nocopy Varchar2
    ,x_msg_count            out nocopy Number
    ,x_msg_data             out nocopy Varchar2
    ,x_pm_conf_reqd         out nocopy Varchar2)
  IS
   l_return_status	Varchar2(1) := OKC_API.G_RET_STS_SUCCESS;
   l_api_name            CONSTANT VARCHAR2(30) := 'Get_PM_Confirmation';
  BEGIN
       l_return_status := OKC_API.START_ACTIVITY(l_api_name
                                                ,p_init_msg_list
                                                ,'_PUB'
                                                ,x_return_status
                                                );
       IF l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF l_return_status = OKC_API.G_RET_STS_ERROR THEN
             RAISE OKC_API.G_EXCEPTION_ERROR;
       END IF;

	OKS_PM_ENTITLEMENTS_PVT.Get_PM_Confirmation
			(p_api_version       => p_api_version
			,p_init_msg_list     => p_init_msg_list
			,p_service_line_id   => p_service_line_id
            ,p_program_id        => p_program_id
            ,p_Activity_Id       => p_activity_id
			,x_return_status     => x_return_status
			,x_msg_count         => x_msg_count
			,x_msg_data          => x_msg_data
			,x_pm_conf_reqd      => x_pm_conf_reqd);


       IF x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF x_return_status = OKC_API.G_RET_STS_ERROR THEN
             RAISE OKC_API.G_EXCEPTION_ERROR;
       END IF;

       OKC_API.END_ACTIVITY(x_msg_count,x_msg_data);

    EXCEPTION
       WHEN OKC_API.G_EXCEPTION_ERROR THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PUB');
       WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PUB');
       WHEN OTHERS THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PUB');
  END Get_PM_Confirmation;

  PROCEDURE Check_PM_Exists
    (p_api_version          IN  Number
    ,p_init_msg_list        IN  Varchar2
    ,p_pm_program_id        IN  Number default null
    ,p_pm_activity_id       IN  Number default null
    ,x_return_status        out nocopy Varchar2
    ,x_msg_count            out nocopy Number
    ,x_msg_data             out nocopy Varchar2
    ,x_pm_reference_exists  out nocopy Varchar2)
      IS
   l_return_status	Varchar2(1) := OKC_API.G_RET_STS_SUCCESS;
   l_api_name            CONSTANT VARCHAR2(30) := 'Check_PM_Exists';
  BEGIN
       l_return_status := OKC_API.START_ACTIVITY(l_api_name
                                                ,p_init_msg_list
                                                ,'_PUB'
                                                ,x_return_status
                                                );
       IF l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF l_return_status = OKC_API.G_RET_STS_ERROR THEN
             RAISE OKC_API.G_EXCEPTION_ERROR;
       END IF;
	OKS_PM_ENTITLEMENTS_PVT.Check_PM_Exists
			(p_api_version       => p_api_version
			,p_init_msg_list     => p_init_msg_list
			,p_pm_program_id     => p_pm_program_id
            ,p_pm_activity_id    => p_pm_activity_id
			,x_return_status     => x_return_status
			,x_msg_count         => x_msg_count
			,x_msg_data          => x_msg_data
			,x_pm_reference_exists => x_pm_reference_exists);


       IF x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF x_return_status = OKC_API.G_RET_STS_ERROR THEN
             RAISE OKC_API.G_EXCEPTION_ERROR;
       END IF;

       OKC_API.END_ACTIVITY(x_msg_count,x_msg_data);

    EXCEPTION
       WHEN OKC_API.G_EXCEPTION_ERROR THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PUB');
       WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PUB');
       WHEN OTHERS THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PUB');
  END Check_PM_Exists;

END OKS_PM_ENTITLEMENTS_PUB;

/
