--------------------------------------------------------
--  DDL for Package Body OKS_ENTITLEMENTS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKS_ENTITLEMENTS_PUB" AS
/* $Header: OKSPENTB.pls 120.2.12010000.3 2010/05/04 10:48:47 vgujarat ship $ */

 PROCEDURE check_coverage_times
	(p_api_version		IN  Number
	,p_init_msg_list		IN  Varchar2
	,p_business_process_id	IN  Number
	,p_request_date		IN  Date
	,p_time_zone_id		IN  Number
      ,p_Dates_In_Input_TZ    IN  VARCHAR2   -- Added for 12.0 ENT-TZ project (JVARGHES)
	,p_contract_line_id	IN  Number
	,x_return_status 		OUT NOCOPY Varchar2
	,x_msg_count		OUT NOCOPY Number
	,x_msg_data			OUT NOCOPY Varchar2
	,x_covered_yn		OUT NOCOPY Varchar2)
 IS
   l_return_status	Varchar2(1);
   l_api_name            CONSTANT VARCHAR2(30) := 'check_coverage_times';
   --l_api_version         CONSTANT NUMBER       := 1.0;
 BEGIN
   l_return_status	:= OKC_API.G_RET_STS_SUCCESS;

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

	OKS_ENTITLEMENTS_PVT.check_coverage_times
			(p_api_version
			,p_init_msg_list
			,p_business_process_id
			,p_request_date
			,p_time_zone_id
                  ,p_Dates_In_Input_TZ     -- Added for 12.0 ENT-TZ project (JVARGHES)
			,p_contract_line_id
			,x_return_status
			,x_msg_count
			,x_msg_data
			,x_covered_yn);

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

 END check_coverage_times;

    /*vgujarat - modified for access hour ER 9675504*/
  PROCEDURE check_reaction_times
	(p_api_version		IN  Number
	,p_init_msg_list		IN  Varchar2
	,p_business_process_id	IN  Number
	,p_request_date		IN  Date
	,p_sr_severity		IN  Number
	,p_time_zone_id		IN  Number
      ,p_Dates_In_Input_TZ    IN  VARCHAR2   -- Added for 12.0 ENT-TZ project (JVARGHES)
	,p_contract_line_id	IN  Number
	,x_return_status 		OUT NOCOPY Varchar2
	,x_msg_count		OUT NOCOPY Number
	,x_msg_data			OUT NOCOPY Varchar2
	,x_react_within		OUT NOCOPY Number
	,x_react_tuom		OUT NOCOPY Varchar2
	,x_react_by_date		OUT NOCOPY Date
        ,P_cust_id                  IN NUMBER DEFAULT NULL
        ,P_cust_site_id             IN NUMBER DEFAULT NULL
        ,P_cust_loc_id              IN NUMBER DEFAULT NULL)
 IS
   l_return_status	Varchar2(1);
   l_api_name            CONSTANT VARCHAR2(30) := 'check_reaction_times';
   --l_api_version         CONSTANT NUMBER       := 1.0;
 BEGIN
   l_return_status	:= OKC_API.G_RET_STS_SUCCESS;

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
    /*vgujarat - modified for access hour ER 9675504*/
	OKS_ENTITLEMENTS_PVT.check_reaction_times
			(p_api_version
			,p_init_msg_list
			,p_business_process_id
			,p_request_date
			,p_sr_severity
			,p_time_zone_id
                  ,p_Dates_In_Input_TZ      -- Added for 12.0 ENT-TZ project (JVARGHES)
			,p_contract_line_id
			,x_return_status
			,x_msg_count
			,x_msg_data
			,x_react_within
			,x_react_tuom
			,x_react_by_date
                        ,P_cust_id
                        ,P_cust_site_id
			,P_cust_loc_id);

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

 END check_reaction_times;

 PROCEDURE get_all_contracts
	(p_api_version		IN  Number
	,p_init_msg_list		IN  Varchar2
	,p_inp_rec			IN  inp_rec_type
	,x_return_status 		OUT NOCOPY Varchar2
	,x_msg_count		OUT NOCOPY Number
	,x_msg_data			OUT NOCOPY Varchar2
	,x_all_contracts		OUT NOCOPY hdr_tbl_type)
 IS
   l_return_status	Varchar2(1);
   l_api_name            CONSTANT VARCHAR2(30) := 'get_all_contracts';
   --l_api_version         CONSTANT NUMBER       := 1.0;
 BEGIN

   l_return_status	:= OKC_API.G_RET_STS_SUCCESS;

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

	OKS_ENTITLEMENTS_PVT.get_all_contracts
			(p_api_version
			,p_init_msg_list
			,p_inp_rec
			,x_return_status
			,x_msg_count
			,x_msg_data
			,x_all_contracts);

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

 END get_all_contracts;

 PROCEDURE get_contract_details
	(p_api_version		IN  Number
	,p_init_msg_list		IN  Varchar2
	,p_contract_line_id	IN  Number
	,x_return_status 		OUT NOCOPY Varchar2
	,x_msg_count		OUT NOCOPY Number
	,x_msg_data			OUT NOCOPY Varchar2
	,x_all_lines		OUT NOCOPY line_tbl_type)
 IS
   l_return_status	Varchar2(1);
   l_api_name            CONSTANT VARCHAR2(30) := 'get_contract_details';
   --l_api_version         CONSTANT NUMBER       := 1.0;
 BEGIN
   l_return_status	:= OKC_API.G_RET_STS_SUCCESS;

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

	OKS_ENTITLEMENTS_PVT.get_contract_details
			(p_api_version
			,p_init_msg_list
			,p_contract_line_id
			,x_return_status
			,x_msg_count
			,x_msg_data
			,x_all_lines);

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

 END get_contract_details;

 PROCEDURE get_coverage_levels
	(p_api_version		IN  Number
	,p_init_msg_list		IN  Varchar2
	,p_contract_line_id	IN  Number
	,x_return_status 		OUT NOCOPY Varchar2
	,x_msg_count		OUT NOCOPY Number
	,x_msg_data			OUT NOCOPY Varchar2
	,x_covered_levels		OUT NOCOPY clvl_tbl_type)
 IS
   l_return_status	Varchar2(1);
   l_api_name            CONSTANT VARCHAR2(30) := 'get_coverage_levels';
   --l_api_version         CONSTANT NUMBER       := 1.0;
 BEGIN
   l_return_status	:= OKC_API.G_RET_STS_SUCCESS;

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

	OKS_ENTITLEMENTS_PVT.get_coverage_levels
			(p_api_version
			,p_init_msg_list
			,p_contract_line_id
			,x_return_status
			,x_msg_count
			,x_msg_data
			,x_covered_levels);


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

 END get_coverage_levels;

 PROCEDURE get_contracts
	(p_api_version		IN  Number
	,p_init_msg_list		IN  Varchar2
	,p_inp_rec			IN  inp_cont_rec
	,x_return_status 		OUT NOCOPY Varchar2
	,x_msg_count		OUT NOCOPY Number
	,x_msg_data			OUT NOCOPY Varchar2
	,x_ent_contracts		OUT NOCOPY ent_cont_tbl)
  IS
   l_return_status	Varchar2(1);
   l_api_name            CONSTANT VARCHAR2(30) := 'get_contracts';
  BEGIN
   l_return_status	:= OKC_API.G_RET_STS_SUCCESS;

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

	OKS_ENTITLEMENTS_PVT.get_contracts
			(p_api_version
			,p_init_msg_list
			,p_inp_rec
			,x_return_status
			,x_msg_count
			,x_msg_data
			,x_ent_contracts);


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
  END get_contracts;

  PROCEDURE get_contacts
	(p_api_version		IN  Number
	,p_init_msg_list		IN  Varchar2
	,p_contract_id		IN  Number
	,p_contract_line_id	IN  Number
	,x_return_status 		OUT NOCOPY Varchar2
	,x_msg_count		OUT NOCOPY Number
	,x_msg_data			OUT NOCOPY Varchar2
	,x_ent_contacts		OUT NOCOPY ent_contact_tbl)
  IS
   l_return_status	Varchar2(1);
   l_api_name            CONSTANT VARCHAR2(30) := 'get_contacts';
  BEGIN
   l_return_status	:= OKC_API.G_RET_STS_SUCCESS;

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

	OKS_ENTITLEMENTS_PVT.get_contacts
			(p_api_version
			,p_init_msg_list
			,p_contract_id
			,p_contract_line_id
			,x_return_status
			,x_msg_count
			,x_msg_data
			,x_ent_contacts);

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
  END get_contacts;

  PROCEDURE get_preferred_engineers
	(p_api_version		IN  Number
	,p_init_msg_list		IN  Varchar2
	,p_contract_line_id	       IN  Number
    ,P_business_process_id		IN		NUMBER		-- added for 11.5.9 (patchset I) enhancement # 2467065
	,P_request_date		      IN		DATE	    -- added for 11.5.9 (patchset I) enhancement # 2467065
	,x_return_status 		out nocopy Varchar2
	,x_msg_count		out nocopy Number
	,x_msg_data			out nocopy Varchar2
	,x_prf_engineers		out nocopy prfeng_tbl_type)
 IS
   l_return_status	Varchar2(1);
   l_api_name            CONSTANT VARCHAR2(30) := 'get_preffered_engineers';
 BEGIN
   l_return_status	:= OKC_API.G_RET_STS_SUCCESS;

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

	OKS_ENTITLEMENTS_PVT.get_preferred_engineers
			(p_api_version
			,p_init_msg_list
			,p_contract_line_id
            ,P_business_process_id
            ,p_request_date
			,x_return_status
			,x_msg_count
			,x_msg_data
			,x_prf_engineers);

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
 END get_preferred_engineers;

 PROCEDURE get_contracts
	(p_api_version		IN  Number
	,p_init_msg_list		IN  Varchar2
	,p_inp_rec			IN  get_contin_rec
	,x_return_status 		OUT NOCOPY Varchar2
	,x_msg_count		OUT NOCOPY Number
	,x_msg_data			OUT NOCOPY Varchar2
	,x_ent_contracts		OUT NOCOPY get_contop_tbl)
  IS
   l_return_status	Varchar2(1);
   l_api_name            CONSTANT VARCHAR2(30) := 'get_contracts';
  BEGIN
   l_return_status	:= OKC_API.G_RET_STS_SUCCESS;

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

	OKS_ENTITLEMENTS_PVT.get_contracts
			(p_api_version
			,p_init_msg_list
			,p_inp_rec
			,x_return_status
			,x_msg_count
			,x_msg_data
			,x_ent_contracts);


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
  END get_contracts;

 --Created For IB
 PROCEDURE get_contracts
	(p_api_version		IN  Number
	,p_init_msg_list		IN  Varchar2
	,p_inp_rec			IN  input_rec_ib
	,x_return_status 		OUT NOCOPY Varchar2
	,x_msg_count		OUT NOCOPY Number
	,x_msg_data			OUT NOCOPY Varchar2
	,x_ent_contracts		OUT NOCOPY output_tbl_ib)
  IS
   l_return_status	Varchar2(1);
   l_api_name            CONSTANT VARCHAR2(30) := 'get_contracts';
  BEGIN
   l_return_status	:= OKC_API.G_RET_STS_SUCCESS;

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

	OKS_ENTITLEMENTS_PVT.get_contracts
			(p_api_version
			,p_init_msg_list
			,p_inp_rec
			,x_return_status
			,x_msg_count
			,x_msg_data
			,x_ent_contracts);


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
  END get_contracts;

---
/*vgujarat - modified for access hour ER 9675504*/
  PROCEDURE get_react_resolve_by_time
    (p_api_version		in  number
    ,p_init_msg_list		in  varchar2
    ,p_inp_rec                  in  grt_inp_rec_type
    ,x_return_status 		out nocopy varchar2
    ,x_msg_count		out nocopy number
    ,x_msg_data			out nocopy varchar2
    ,x_react_rec                out nocopy rcn_rsn_rec_type
    ,x_resolve_rec              out nocopy rcn_rsn_rec_type)
  IS
   l_return_status	Varchar2(1);
   l_api_name            CONSTANT VARCHAR2(30) := 'get_react_resolve_by_time';
   --l_api_version         CONSTANT NUMBER       := 1.0;

 BEGIN
   l_return_status	:= OKC_API.G_RET_STS_SUCCESS;

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

	OKS_ENTITLEMENTS_PVT.get_react_resolve_by_time
	    (p_api_version		=> p_api_version
            ,p_init_msg_list		=> p_init_msg_list
            ,p_inp_rec                  => p_inp_rec
            ,x_return_status 		=> x_return_status
            ,x_msg_count		=> x_msg_count
            ,x_msg_data			=> x_msg_data
            ,x_react_rec                => x_react_rec
            ,x_resolve_rec              => x_resolve_rec
);

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

 END get_react_resolve_by_time;

  --Created For Entitlement Screen

  PROCEDURE Get_Contracts
    (P_API_Version		IN  NUMBER
    ,P_Init_Msg_List		IN  VARCHAR2
    ,P_Inp_Rec			IN  Input_Rec_EntFrm
    ,X_Return_Status 		OUT NOCOPY VARCHAR2
    ,X_Msg_Count		OUT NOCOPY NUMBER
    ,X_Msg_Data			OUT NOCOPY VARCHAR2
    ,X_Ent_Contracts		OUT NOCOPY Output_Tbl_EntFrm)
  IS
   l_return_status	Varchar2(1);
   l_api_name            CONSTANT VARCHAR2(30) := 'get_contracts';
  BEGIN
   l_return_status	:= OKC_API.G_RET_STS_SUCCESS;

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

	OKS_ENTITLEMENTS_PVT.get_contracts
			(P_API_Version     => P_API_Version
			,P_Init_Msg_List   => P_Init_Msg_List
			,P_Inp_Rec	   => P_Inp_Rec
			,X_Return_Status   => X_Return_Status
			,X_Msg_Count       => X_Msg_Count
			,X_Msg_Data        => X_Msg_Data
			,X_Ent_Contracts   => X_Ent_Contracts);


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
  END get_contracts;

---

  PROCEDURE Get_Coverage_Type
    (P_API_Version		IN  NUMBER
    ,P_Init_Msg_List		IN  VARCHAR2
    ,P_Contract_Line_Id	        IN  NUMBER
    ,X_Return_Status 		OUT NOCOPY VARCHAR2
    ,X_Msg_Count 	        out nocopy NUMBER
    ,X_Msg_Data		        out nocopy VARCHAR2
    ,X_Coverage_Type		OUT NOCOPY CovType_Rec_Type)

  IS

   l_return_status	   Varchar2(1);
   l_api_name              CONSTANT VARCHAR2(30) := 'get_react_resolve_by_time';

  BEGIN
   l_return_status	   := OKC_API.G_RET_STS_SUCCESS;

    l_return_status := OKC_API.START_ACTIVITY(l_api_name
                                             ,p_init_msg_list
                                             ,'_PUB'
                                             ,x_return_status);

    IF l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF l_return_status = OKC_API.G_RET_STS_ERROR THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    OKS_ENTITLEMENTS_PVT.Get_Coverage_Type
      (P_API_Version		=> p_api_version
      ,P_Init_Msg_List		=> p_init_msg_list
      ,P_Contract_Line_Id	=> P_Contract_Line_Id
      ,X_Return_Status 		=> x_return_status
      ,X_Msg_Count 	        => x_msg_count
      ,X_Msg_Data		=> x_msg_data
      ,X_Coverage_Type		=> X_Coverage_Type);

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

  END Get_Coverage_Type;


/**********************************************************************
 This procedure is for IB to get the contracts for a
 given Customer product and Highest Coverage  Importance level
 ***********************************************************************/

 PROCEDURE Get_HighImp_CP_Contract
    (P_API_Version		    IN  NUMBER
    ,P_Init_Msg_List		IN  VARCHAR2
    ,P_Customer_product_Id	IN  NUMBER
    ,X_Return_Status 		OUT NOCOPY VARCHAR2
    ,X_Msg_Count 	        out nocopy NUMBER
    ,X_Msg_Data		        out nocopy VARCHAR2
    ,X_Importance_Lvl		OUT NOCOPY High_Imp_level_K_rec)

  IS

   l_return_status	   Varchar2(1);
   l_api_name          CONSTANT VARCHAR2(30) := 'Get_HighImp_CP_Contract';

  BEGIN

   l_return_status	   := OKC_API.G_RET_STS_SUCCESS;

    l_return_status := OKC_API.START_ACTIVITY(l_api_name
                                             ,p_init_msg_list
                                             ,'_PUB'
                                             ,x_return_status);

    IF l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF l_return_status = OKC_API.G_RET_STS_ERROR THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;



    OKS_ENTITLEMENTS_PVT.Get_HighImp_CP_Contract
      (P_API_Version		=> p_api_version
      ,P_Init_Msg_List		=> p_init_msg_list
      ,P_Customer_product_Id	=> P_Customer_product_Id
      ,X_Return_Status 		=> x_return_status
      ,X_Msg_Count 	        => x_msg_count
      ,X_Msg_Data		=> x_msg_data
      ,X_Importance_Lvl		=> X_Importance_Lvl);

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

  END Get_HighImp_CP_Contract;



/**********************************************************************
 This procedure is for CSI to return if a valid contract exits for a given System
 ***********************************************************************/


 PROCEDURE OKS_VALIDATE_SYSTEM
    (P_API_Version	        IN  NUMBER
    ,P_Init_Msg_List		IN  VARCHAR2
    ,P_System_Id	        IN  NUMBER
    ,P_Request_Date	        IN  DATE
    ,P_Update_Only_Check        IN  VARCHAR2
    ,X_Return_Status 		OUT NOCOPY VARCHAR2
    ,X_Msg_Count 	        out nocopy NUMBER
    ,X_Msg_Data		        out nocopy VARCHAR2
    ,X_System_Valid		OUT NOCOPY VARCHAR2)

  IS

   l_return_status	   Varchar2(1);
   l_api_name          CONSTANT VARCHAR2(30) := 'oks_validate_system';
   lx_csi              VARCHAR2(1);

  BEGIN

   l_return_status	   := OKC_API.G_RET_STS_SUCCESS;
   lx_csi                  := 'F';


    l_return_status := OKC_API.START_ACTIVITY(l_api_name
                                             ,p_init_msg_list
                                             ,'_PUB'
                                             ,x_return_status);

    IF l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF l_return_status = OKC_API.G_RET_STS_ERROR THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;


    OKS_ENTITLEMENTS_PVT.OKS_VALIDATE_SYSTEM(P_API_Version		=> p_api_version
                                                      ,P_Init_Msg_List		=> p_init_msg_list
                                                      ,P_System_Id	        => P_System_Id
                                                      ,P_Request_Date       => P_Request_Date
                                                      ,P_Update_Only_Check  => P_Update_Only_Check
                                                      ,X_Return_Status 		=> x_return_status
                                                      ,X_Msg_Count 	        => x_msg_count
                                                      ,X_Msg_Data		    => x_msg_data
                                                      ,X_SYSTEM_VALID		=> X_SYSTEM_VALID);

    IF x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF x_return_status = OKC_API.G_RET_STS_ERROR THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    OKC_API.END_ACTIVITY(x_msg_count,x_msg_data);
    --return lx_csi;

  EXCEPTION

     WHEN OKC_API.G_EXCEPTION_ERROR THEN

       x_return_status := OKC_API.HANDLE_EXCEPTIONS
                            (l_api_name,
                             G_PKG_NAME,
                             'OKC_API.G_RET_STS_ERROR',
                             x_msg_count,
                             x_msg_data,
                             '_PUB');
      --  return lx_csi;
     WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

       x_return_status := OKC_API.HANDLE_EXCEPTIONS
                            (l_api_name,
                             G_PKG_NAME,
                             'OKC_API.G_RET_STS_UNEXP_ERROR',
                             x_msg_count,
                             x_msg_data,
                             '_PUB');
     --   return lx_csi;
     WHEN OTHERS THEN

       x_return_status := OKC_API.HANDLE_EXCEPTIONS
                            (l_api_name,
                             G_PKG_NAME,
                             'OTHERS',
                             x_msg_count,
                             x_msg_data,
                             '_PUB');
    --return lx_csi;
 END OKS_VALIDATE_SYSTEM;

 /**********************************************************************
 This procedure is for CSI to get the default contracts for a given System ER#2279911
 ***********************************************************************/


  PROCEDURE Default_Contline_System
    (P_API_Version		    IN  NUMBER
    ,P_Init_Msg_List		IN  VARCHAR2
    ,P_System_Id	        IN  NUMBER
    ,P_Request_Date         IN  DATE
    ,X_Return_Status 		OUT NOCOPY VARCHAR2
    ,X_Msg_Count 	        out nocopy NUMBER
    ,X_Msg_Data		        out nocopy VARCHAR2
    ,X_Ent_Contracts		OUT NOCOPY Default_Contline_System_Rec)
  IS
   l_return_status	Varchar2(1);
   l_api_name            CONSTANT VARCHAR2(30) := 'Default_Contline_System';
  BEGIN
   l_return_status	:= OKC_API.G_RET_STS_SUCCESS;

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

       OKS_ENTITLEMENTS_PVT.Default_Contline_System
                    (P_API_Version		    => p_api_version
                    ,P_Init_Msg_List		=> p_Init_msg_list
                    ,P_System_Id	        => p_system_id
                    ,P_Request_Date         => p_request_date
                    ,X_Return_Status 		=> x_return_status
                    ,X_Msg_Count 	        => x_msg_count
                    ,X_Msg_Data		        => x_msg_data
                    ,X_Ent_Contracts		=> X_Ent_Contracts);


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
  END  Default_Contline_System;

procedure Get_cov_txn_groups
	(p_api_version		IN  Number
	,p_init_msg_list		IN  Varchar2
	,p_inp_rec_bp		IN  inp_rec_bp
    ,x_return_status 		OUT NOCOPY Varchar2
	,x_msg_count		OUT NOCOPY Number
	,x_msg_data			OUT NOCOPY Varchar2
	,x_cov_txn_grp_lines		OUT NOCOPY output_tbl_bp)
  IS
   l_return_status	Varchar2(1);
   l_api_name            CONSTANT VARCHAR2(30) := 'Get_cov_txn_groups';
  BEGIN
   l_return_status	:= OKC_API.G_RET_STS_SUCCESS;

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


       OKS_ENTITLEMENTS_PVT.Get_cov_txn_groups
	       (p_api_version		=> p_api_version
        	,p_init_msg_list    => p_init_msg_list
        	,p_inp_rec_bp	    => p_inp_rec_bp
        	,x_return_status    => x_return_status
        	,x_msg_count	    => x_msg_count
        	,x_msg_data		    => x_msg_data
        	,x_cov_txn_grp_lines	    => x_cov_txn_grp_lines);


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
  END  Get_cov_txn_groups;


  PROCEDURE Get_txn_billing_types
    (p_api_version		IN  Number
	,p_init_msg_list	IN  Varchar2
	,p_cov_txngrp_line_id	IN  Number
    ,p_return_bill_rates_YN   IN  Varchar2
	,x_return_status 	OUT NOCOPY Varchar2
	,x_msg_count		OUT NOCOPY Number
	,x_msg_data		OUT NOCOPY Varchar2
	,x_txn_bill_types		OUT NOCOPY output_tbl_bt
    ,x_txn_bill_rates   out nocopy output_tbl_br)
  IS
   l_return_status	Varchar2(1);
   l_api_name            CONSTANT VARCHAR2(30) := 'Get_txn_billing_types';
  BEGIN
   l_return_status	:= OKC_API.G_RET_STS_SUCCESS;

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


       OKS_ENTITLEMENTS_PVT.Get_txn_billing_types
	       (p_api_version		=> p_api_version
	       ,p_init_msg_list     => p_init_msg_list
           ,p_cov_txngrp_line_id	        => p_cov_txngrp_line_id
           ,p_return_bill_rates_YN   => p_return_bill_rates_YN
           ,x_return_status     => x_return_status
           ,x_msg_count         => x_msg_count
           ,x_msg_data	        => x_msg_data
           ,x_txn_bill_types	        => x_txn_bill_types
           ,x_txn_bill_rates    => x_txn_bill_rates);


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
  END  Get_txn_billing_types;


  PROCEDURE Search_Contracts
    (p_api_version         IN  Number
    ,p_init_msg_list       IN  Varchar2
    ,p_contract_rec        IN  inp_cont_rec_type
    ,p_clvl_id_tbl         IN  covlvl_id_tbl
    ,x_return_status       out nocopy Varchar2
    ,x_msg_count           out nocopy Number
    ,x_msg_data            out nocopy Varchar2
    ,x_contract_tbl        out nocopy output_tbl_contract) IS

   l_return_status	Varchar2(1);
   l_api_name            CONSTANT VARCHAR2(30) := 'search_contracts';

  BEGIN
   l_return_status	:= OKC_API.G_RET_STS_SUCCESS;

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

	OKS_ENTITLEMENTS_PVT.search_contracts
			(p_api_version
			,p_init_msg_list
			,p_contract_rec
            ,p_clvl_id_tbl
	        ,x_return_status
	        ,x_msg_count
	        ,x_msg_data
	        ,x_contract_tbl);

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
  END  Search_Contracts;

  PROCEDURE Get_Contracts_Expiration
    (p_api_version              IN  Number
    ,p_init_msg_list            IN  Varchar2
    ,p_contract_id              IN  Number
    ,x_return_status            out nocopy Varchar2
    ,x_msg_count                out nocopy Number
    ,x_msg_data                 out nocopy Varchar2
    ,x_contract_end_date        out nocopy date
    ,x_Contract_Grace_Duration  out nocopy number
    ,x_Contract_Grace_Period    out nocopy VARCHAR2)

   IS
    l_return_status	Varchar2(1);
    l_api_name            CONSTANT VARCHAR2(30) := 'Get_Contracts_Expiration';

  BEGIN
    l_return_status	:= OKC_API.G_RET_STS_SUCCESS;

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

	OKS_ENTITLEMENTS_PVT.Get_Contracts_Expiration
			(p_api_version
			,p_init_msg_list
			,p_contract_id
	        ,x_return_status
	        ,x_msg_count
	        ,x_msg_data
	        ,x_contract_end_date
            ,x_Contract_Grace_Period
            ,x_Contract_Grace_Duration);


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
  END  Get_Contracts_Expiration;

  --============================================

  PROCEDURE VALIDATE_CONTRACT_LINE
    (p_api_version          IN  NUMBER
    ,p_init_msg_list        IN  VARCHAR2
    ,p_contract_line_id     IN  NUMBER
    ,p_busiproc_id          IN  NUMBER
    ,p_request_date         IN  DATE
    ,p_covlevel_tbl_in      IN covlevel_tbl_type
    ,p_verify_combination   IN VARCHAR2
    ,x_return_status        out nocopy Varchar2
    ,x_msg_count            out nocopy Number
    ,x_msg_data             out nocopy Varchar2
    ,x_covlevel_tbl_out     OUT NOCOPY  covlevel_tbl_type
    ,x_combination_valid    OUT NOCOPY VARCHAR2)
    IS

    l_return_status	Varchar2(1);
    l_api_name            CONSTANT VARCHAR2(30) := 'VALIDATE_CONTRACT_LINE';

    BEGIN
    l_return_status	:= OKC_API.G_RET_STS_SUCCESS;

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

       OKS_ENTITLEMENTS_PVT.VALIDATE_CONTRACT_LINE(p_api_version
                                                  ,p_init_msg_list
                                                  ,p_contract_line_id
                                                  ,p_busiproc_id
                                                  ,p_request_date
                                                  ,p_covlevel_tbl_in
                                                  ,p_verify_combination
                                                  ,x_return_status
                                                  ,x_msg_count
                                                  ,x_msg_data
                                                  ,x_covlevel_tbl_out
                                                  ,x_combination_valid  );


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

  END VALIDATE_CONTRACT_LINE;


  PROCEDURE Search_Contract_lines
    (p_api_version         		IN  Number
    ,p_init_msg_list       		IN  Varchar2
    ,p_contract_rec        		IN  srchline_inpcontrec_type
    ,p_contract_line_rec	    IN  srchline_inpcontlinerec_type
    ,p_clvl_id_tbl         		IN  srchline_covlvl_id_tbl
    ,x_return_status       		out nocopy Varchar2
    ,x_msg_count           		out nocopy Number
    ,x_msg_data            		out nocopy Varchar2
    ,x_contract_tbl        		out nocopy output_tbl_contractline)
    IS

    l_return_status	Varchar2(1);
    l_api_name            CONSTANT VARCHAR2(30) := 'Search_Contract_Lines';

  BEGIN

    l_return_status	:= OKC_API.G_RET_STS_SUCCESS;

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

       OKS_ENTITLEMENTS_PVT.Search_Contract_lines
               (    p_api_version,
                    p_init_msg_list,
                    p_contract_rec,
                    p_contract_line_rec,
                    p_clvl_id_tbl,
                    x_return_status,
                    x_msg_count,
                    x_msg_data,
                    x_contract_tbl);


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
END Search_Contract_lines;

END OKS_ENTITLEMENTS_PUB;

/
